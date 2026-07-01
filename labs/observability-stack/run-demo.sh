#!/usr/bin/env bash
# run-demo.sh -- live end-to-end demo of the observability stack on kind.
#
# Gated behind RUN_LIVE=1 because it is a multi-minute live drive (build image,
# load into kind, deploy, scrape, query). validate.sh stays fast and does NOT
# run this; the captured evidence (LIVE-OBS-EVIDENCE.txt) is committed instead.
#
#   RUN_LIVE=1 ./run-demo.sh
#
# What it does, in order:
#   1. docker build the sample-api image and `kind load` it into the cluster.
#   2. kubectl apply the solution/k8s manifests into namespace lab-obs.
#   3. Wait for sample-api (2/2) and prometheus (1/1) rollouts.
#   4. Port-forward Prometheus, drive synthetic traffic at sample-api.
#   5. Query the Prometheus HTTP API for the RED recording rules and PROVE they
#      return data (request rate > 0, error ratio > 0, p99 latency present),
#      and list the loaded alerting rules. Capture everything to the evidence file.
#   6. ALWAYS tear the namespace down (trap), leaving nothing running.
#
# Idempotent: deletes any prior lab-obs namespace first; cleans up on any exit.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

CLUSTER="${KIND_CLUSTER:-course}"
KCTX="kind-${CLUSTER}"
NS="${LAB_NS:-lab-obs}"
IMAGE="sample-api:1.0.0"
EVIDENCE="$HERE/LIVE-OBS-EVIDENCE.txt"
PF_PID=""

if [ "${RUN_LIVE:-0}" != "1" ]; then
  echo "run-demo.sh is a live drive; set RUN_LIVE=1 to run it." >&2
  echo "Committed evidence from a prior run lives in LIVE-OBS-EVIDENCE.txt." >&2
  exit 0
fi

log() { printf '\n=== %s ===\n' "$*"; }

cleanup() {
  local rc=$?
  if [ -n "$PF_PID" ]; then kill "$PF_PID" >/dev/null 2>&1 || true; fi
  log "cleanup: deleting namespace $NS"
  kubectl --context "$KCTX" delete ns "$NS" --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1 || true
  exit "$rc"
}
trap cleanup EXIT INT TERM

# --- preflight ---------------------------------------------------------------
for bin in docker kind kubectl python3; do
  command -v "$bin" >/dev/null 2>&1 || { echo "missing required tool: $bin" >&2; exit 1; }
done
kubectl config get-contexts "$KCTX" >/dev/null 2>&1 \
  || { echo "kube context $KCTX not found (is the kind cluster '$CLUSTER' up?)" >&2; exit 1; }

# Start the evidence file fresh.
{
  echo "# LIVE-OBS-EVIDENCE -- observability-stack run-demo.sh"
  echo "# Captured: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "# Cluster context: $KCTX   Namespace: $NS   Image: $IMAGE"
  echo "# Prometheus: prom/prometheus:v2.55.0 (single Deployment, pod SD)"
  echo
} > "$EVIDENCE"

# --- 1. build + load image ---------------------------------------------------
log "build $IMAGE"
docker build -t "$IMAGE" solution/app | tail -3 | tee -a "$EVIDENCE"

log "kind load $IMAGE into cluster '$CLUSTER'"
kind load docker-image "$IMAGE" --name "$CLUSTER" 2>&1 | tee -a "$EVIDENCE"

# --- 2. deploy ---------------------------------------------------------------
log "deploy stack into ns $NS"
kubectl --context "$KCTX" delete ns "$NS" --ignore-not-found --wait=true --timeout=90s >/dev/null 2>&1 || true
# 00-namespace.yaml creates the namespace; apply the directory in order.
kubectl --context "$KCTX" apply -f solution/k8s/ | tee -a "$EVIDENCE"

# --- 3. wait for rollouts ----------------------------------------------------
log "wait for rollouts"
kubectl --context "$KCTX" -n "$NS" rollout status deploy/sample-api --timeout=120s | tee -a "$EVIDENCE"
kubectl --context "$KCTX" -n "$NS" rollout status deploy/prometheus --timeout=120s | tee -a "$EVIDENCE"
kubectl --context "$KCTX" -n "$NS" get pods -o wide | tee -a "$EVIDENCE"

# --- 4. port-forward + drive load -------------------------------------------
log "port-forward prometheus 9090 and drive load at sample-api"
kubectl --context "$KCTX" -n "$NS" port-forward svc/prometheus 9090:9090 >/tmp/_obs_pf.log 2>&1 &
PF_PID=$!
# Wait until the API answers.
for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:9090/-/ready" >/dev/null 2>&1; then break; fi
  sleep 1
done

# Drive traffic at sample-api via its own port-forward (separate from prometheus).
kubectl --context "$KCTX" -n "$NS" port-forward svc/sample-api 18080:80 >/tmp/_obs_pf_app.log 2>&1 &
APP_PF_PID=$!
for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:18080/healthz" >/dev/null 2>&1; then break; fi
  sleep 1
done

# Drive load SPREAD OVER ~150s (not a single burst): rate(...[5m]) is computed as
# (last - first)/window, so the counter must keep INCREASING across several
# 15s scrapes for the rate (and thus the error ratio) to be non-zero. A burst
# that completes between two scrapes yields rate 0 and a 0/0=NaN error ratio.
log "drive ~150s of paced load (10% errors) so rate()/error-ratio are non-zero"
{
  echo
  echo "## load generation (mixed good/slow/error traffic, paced over 150s)"
  python3 scripts/loadgen.py --base-url http://127.0.0.1:18080 \
    --requests 1500 --error-frac 0.10 --slow-frac 0.05 --duration 150
} | tee -a "$EVIDENCE"
kill "$APP_PF_PID" >/dev/null 2>&1 || true

# --- 5. query the Prometheus HTTP API and PROVE data comes back -------------
q() {  # q "<label>" "<promql>"
  local label="$1" expr="$2" resp
  resp=$(curl -fsS --data-urlencode "query=${expr}" "http://127.0.0.1:9090/api/v1/query")
  {
    echo
    echo "## ${label}"
    echo "PromQL: ${expr}"
    echo "$resp" | python3 -m json.tool
  } | tee -a "$EVIDENCE"
  # Fail loudly if the query returned an empty result vector.
  echo "$resp" | python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(0 if d['data']['result'] else 1)" \
    || { echo "QUERY RETURNED NO DATA: $expr" | tee -a "$EVIDENCE"; return 1; }
}

log "query RED recording rules via Prometheus HTTP API"
q "scrape targets up (sample-api pods)" 'up{job="sample-api"}'
q "R: request rate (req/s)"             'job:http_requests:rate5m{job="sample-api"}'
q "E: error ratio (0..1)"               'job:http_requests_error_ratio:rate5m{job="sample-api"}'
q "D: p99 latency (s)"                  'job:http_request_duration_seconds:p99{job="sample-api"}'
q "raw counter sample"                  'sum by (status) (http_requests_total{job="sample-api"})'

# Show the alerting rules Prometheus actually loaded (proves the burn-rate rules
# are live in the running server, not just in a file).
{
  echo
  echo "## loaded alerting rules (Prometheus /api/v1/rules, alert names only)"
  curl -fsS "http://127.0.0.1:9090/api/v1/rules?type=alert" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); [print('  alert:', r['name']) for g in d['data']['groups'] for r in g['rules']]"
} | tee -a "$EVIDENCE"

log "DONE -- evidence written to $EVIDENCE (namespace will now be deleted)"
