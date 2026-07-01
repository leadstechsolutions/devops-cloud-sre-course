#!/usr/bin/env bash
# cleanup()/hpa_watch()/require() are invoked indirectly (EXIT trap, background
# job), which ShellCheck's SC2317 reachability heuristic cannot see; suppress it.
# shellcheck disable=SC2317
#
# run-demo.sh — end-to-end HPA scaling demo on a kind cluster.
#
# What it does, in order:
#   1. Install metrics-server (vendored manifest) and patch it for kind
#      (--kubelet-insecure-tls), then wait until `kubectl top pod` works.
#   2. Create namespace lab-perf and apply k8s/ (Deployment + Service + HPA).
#   3. Wait for the HPA to read real CPU metrics (TARGETS no longer <unknown>).
#   4. Port-forward the Service and drive k6 load at /burn.
#   5. Sample `kubectl get hpa` during the load and capture replicas scaling UP
#      (REPLICAS 1 -> >1).
#   6. Stop the load, let the HPA scale back down, then DELETE ns lab-perf and
#      UNINSTALL metrics-server. Always cleans up, even on failure/Ctrl-C.
#
# Prerequisites (the script checks them):
#   - kubectl pointed at a cluster (override with KUBECONFIG / kubectl context).
#   - kind with the cpu-burner:1.0.0 image side-loaded:
#       docker build -t cpu-burner:1.0.0 solution/app
#       kind load docker-image cpu-burner:1.0.0 --name <cluster>
#   - k6 on PATH.
#
# Idempotent: safe to re-run. Leaves nothing behind.
set -euo pipefail

cd "$(dirname "$0")"

NS="${NS:-lab-perf}"
# Fewer VUs doing a longer CPU burn each: this drives the HPA just as hard
# (CPU-seconds, not connection count, is what matters) while putting far less
# concurrency pressure on the single `kubectl port-forward`, which can reset
# connections under heavy load. Override via env for a harsher test.
PEAK_VUS="${PEAK_VUS:-20}"
BURN_MS="${BURN_MS:-120}"
PF_PORT="${PF_PORT:-18080}"
METRICS_MANIFEST="k8s/metrics-server.yaml"

PF_PID=""
SCALED=0          # set to 1 once REPLICAS > 1 is observed
MS_INSTALLED=0    # set to 1 once we apply metrics-server, so cleanup uninstalls it

log()  { printf '\n=== %s ===\n' "$*"; }
info() { printf '    %s\n' "$*"; }

cleanup() {
  local rc=$?
  log "cleanup"
  if [ -n "$PF_PID" ] && kill -0 "$PF_PID" 2>/dev/null; then
    kill "$PF_PID" 2>/dev/null || true
    wait "$PF_PID" 2>/dev/null || true
    info "stopped port-forward (pid $PF_PID)"
  fi
  kubectl delete ns "$NS" --ignore-not-found --wait=false >/dev/null 2>&1 || true
  info "deleted namespace $NS"
  if [ "$MS_INSTALLED" = "1" ]; then
    kubectl delete -f "$METRICS_MANIFEST" --ignore-not-found --wait=false \
      >/dev/null 2>&1 || true
    info "uninstalled metrics-server"
  fi
  exit "$rc"
}
trap cleanup EXIT INT TERM

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' not found on PATH" >&2; exit 2; }
}
require kubectl
require k6

kubectl cluster-info >/dev/null 2>&1 || {
  echo "ERROR: no reachable cluster (check kubectl context / KUBECONFIG)" >&2
  exit 2
}

# --- 1. metrics-server -------------------------------------------------------
log "installing metrics-server (kind-patched)"
kubectl apply -f "$METRICS_MANIFEST" >/dev/null
MS_INSTALLED=1
# kind kubelets serve metrics over a self-signed cert metrics-server won't trust
# by default; --kubelet-insecure-tls skips that verification. REQUIRED on kind;
# do NOT use it on a real cluster — there you fix the kubelet serving certs.
kubectl -n kube-system patch deployment metrics-server --type=json -p \
  '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' \
  >/dev/null
kubectl -n kube-system rollout status deployment/metrics-server --timeout=120s

info "waiting for the metrics API to serve pod metrics (kubectl top)…"
for i in $(seq 1 40); do
  if kubectl top nodes >/dev/null 2>&1; then
    info "metrics API is serving after ~$((i * 5))s"
    break
  fi
  [ "$i" = 40 ] && { echo "ERROR: metrics-server never served metrics" >&2; exit 1; }
  sleep 5
done

# --- 2. apply workload + HPA -------------------------------------------------
log "applying workload into ns $NS"
# Apply the kustomization (it creates the Namespace and pins everything into it).
kubectl apply -k k8s/ >/dev/null
kubectl -n "$NS" rollout status deploy/cpu-burner --timeout=120s

# --- 3. wait for the HPA to read metrics -------------------------------------
log "waiting for the HPA to read CPU metrics (TARGETS != <unknown>)"
for i in $(seq 1 40); do
  targets=$(kubectl -n "$NS" get hpa cpu-burner \
    -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null || true)
  if [ -n "${targets:-}" ]; then
    info "HPA is reading metrics (current ${targets}% of request) after ~$((i * 5))s"
    break
  fi
  [ "$i" = 40 ] && { echo "ERROR: HPA never read CPU metrics" >&2; exit 1; }
  sleep 5
done
kubectl -n "$NS" get hpa cpu-burner

# --- 4. port-forward + load --------------------------------------------------
log "starting port-forward svc/cpu-burner -> localhost:$PF_PORT"
kubectl -n "$NS" port-forward svc/cpu-burner "${PF_PORT}:80" >/dev/null 2>&1 &
PF_PID=$!
# Give the forward a moment, then confirm it is actually serving.
for i in $(seq 1 10); do
  if curl -fsS --max-time 3 "http://localhost:${PF_PORT}/healthz" >/dev/null 2>&1; then
    info "port-forward is serving /healthz"
    break
  fi
  [ "$i" = 10 ] && { echo "ERROR: port-forward never became ready" >&2; exit 1; }
  sleep 1
done

log "running k6 load (peak ${PEAK_VUS} VUs, burn ${BURN_MS}ms/request)"
# Watch the HPA in the background while k6 runs, recording the peak replica count.
hpa_watch() {
  local max=1 rep
  while :; do
    rep=$(kubectl -n "$NS" get hpa cpu-burner -o jsonpath='{.status.currentReplicas}' 2>/dev/null || echo 1)
    [ -n "$rep" ] || rep=1
    if [ "$rep" -gt "$max" ] 2>/dev/null; then
      max="$rep"
      printf '    [hpa-watch] REPLICAS rose to %s\n' "$max"
    fi
    echo "$max" >/tmp/_perf_maxrep
    sleep 5
  done
}
echo 1 >/tmp/_perf_maxrep
hpa_watch &
WATCH_PID=$!

set +e
BASE_URL="http://localhost:${PF_PORT}" BURN_MS="$BURN_MS" PEAK_VUS="$PEAK_VUS" \
  k6 run load/load.js
K6_RC=$?
set -e

kill "$WATCH_PID" 2>/dev/null || true
wait "$WATCH_PID" 2>/dev/null || true

# --- 5. capture scaling ------------------------------------------------------
log "HPA state after load"
kubectl -n "$NS" get hpa cpu-burner
kubectl -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner -o wide
MAXREP=$(cat /tmp/_perf_maxrep 2>/dev/null || echo 1)
info "peak observed REPLICAS during load: $MAXREP"
if [ "${MAXREP:-1}" -gt 1 ] 2>/dev/null; then
  SCALED=1
  info "RESULT: HPA scaled UP (1 -> $MAXREP). Autoscaling demonstrated."
else
  info "RESULT: no scale-up observed (peak REPLICAS=$MAXREP). See troubleshooting."
fi

# --- 6. scale back down (observe) --------------------------------------------
log "stopping load; observing scale-down (HPA scaleDown stabilisation ~60s)"
# Stop the port-forward now so no stray load lingers.
if [ -n "$PF_PID" ] && kill -0 "$PF_PID" 2>/dev/null; then
  kill "$PF_PID" 2>/dev/null || true
  wait "$PF_PID" 2>/dev/null || true
  PF_PID=""
fi
# Watch for the HPA to start scaling back in. We exit as soon as we observe the
# FIRST decrement below the peak (that proves scale-in works) OR we reach
# minReplicas, capped at SCALEDOWN_BUDGET seconds so the e2e gate stays bounded.
# Set FULL_SCALEDOWN=1 to instead wait all the way back to 1 (slower).
SCALEDOWN_BUDGET="${SCALEDOWN_BUDGET:-150}"
elapsed=0
start_rep="$MAXREP"
while [ "$elapsed" -lt "$SCALEDOWN_BUDGET" ]; do
  rep=$(kubectl -n "$NS" get hpa cpu-burner -o jsonpath='{.status.currentReplicas}' 2>/dev/null || echo "?")
  info "t+${elapsed}s after load: REPLICAS=$rep"
  if [ "$rep" = "1" ]; then
    info "scaled back down to minReplicas (1)"
    break
  fi
  if [ "${FULL_SCALEDOWN:-0}" != "1" ] && [ "$rep" != "?" ] \
     && [ "$rep" -lt "$start_rep" ] 2>/dev/null; then
    info "scale-IN observed (REPLICAS $start_rep -> $rep); HPA will continue toward 1"
    break
  fi
  sleep 10
  elapsed=$((elapsed + 10))
done
kubectl -n "$NS" get hpa cpu-burner

# Cleanup runs from the EXIT trap (delete ns + uninstall metrics-server).
log "demo complete"
if [ "$SCALED" = "1" ] && [ "$K6_RC" = "0" ]; then
  info "SUCCESS: scaling observed and k6 thresholds passed."
  exit 0
elif [ "$SCALED" = "1" ]; then
  info "Scaling observed, but k6 thresholds failed (rc=$K6_RC) — investigate latency."
  exit "$K6_RC"
else
  info "No scale-up observed — failing so this is not a silent pass."
  exit 1
fi
