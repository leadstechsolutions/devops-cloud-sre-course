#!/usr/bin/env bash
# Validation gates for the kubernetes-fundamentals module.
# Run from the module root:  ./validate.sh
# Prints one line per check; exits non-zero if ANY gate FAILS (DEFERRED is OK).
#
# Gates:
#   1. Every manifest is well-formed YAML, multi-doc aware (PyYAML safe_load_all).
#   2. `kubectl kustomize solution/base` renders.
#   3. `kubectl kustomize solution/overlays/prod` renders (and patches replicas).
#   4. Offline structural tests (tests/, stdlib unittest + PyYAML) assert the
#      security/probe/resource/networkpolicy requirements hold in the render.
#   5. Shell syntax of this script (bash -n).
#   6. kubeconform -strict schema validation of the base render, the prod
#      overlay render, and the broken fixtures (runs when `kubeconform` exists).
#   7. LIVE cluster gates (run when a cluster is reachable): apply the base into
#      a unique namespace and observe 2/2 Ready; reproduce the OOMKilled fixture
#      (Reason: OOMKilled, Exit Code: 137); reproduce the never-Ready badprobe
#      fixture (Running but 0/1, empty Service endpoints). Always tears the
#      namespace down. Degrades to DEFER where no cluster is reachable.
#   8. kubectl apply --dry-run=client per manifest — needs a cluster for
#      API RESTMapping, so it is DEFERRED here with the exact command.
set -euo pipefail

cd "$(dirname "$0")"

fail=0
pass=0
defer=0

check() {  # check "label" cmd args...
  local label="$1"; shift
  if "$@" >/tmp/_k8s_check.out 2>&1; then
    printf '  [PASS]  %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL]  %s\n' "$label"
    sed 's/^/          /' /tmp/_k8s_check.out | head -20
    fail=$((fail + 1))
  fi
}

defer_note() {  # defer_note "label" "command to run where the tool exists"
  printf '  [DEFER] %s\n' "$1"
  printf '          run: %s\n' "$2"
  defer=$((defer + 1))
}

echo "== validating kubernetes-fundamentals =="

# --- Gate 1: YAML well-formed (multi-doc aware) -------------------------------
yaml_parse() {
  python3 - "$@" <<'PY'
import sys, yaml
bad = 0
for f in sys.argv[1:]:
    try:
        with open(f) as fh:
            list(yaml.safe_load_all(fh))
    except Exception as e:  # noqa: BLE001
        print(f"PARSE ERROR {f}: {e}")
        bad += 1
sys.exit(1 if bad else 0)
PY
}
check "yaml: all manifests parse (multi-doc)" \
  yaml_parse \
    solution/base/*.yaml \
    solution/overlays/prod/*.yaml \
    broken/*.yaml \
    starter/deployment.yaml

# --- Gates 2 & 3: kustomize renders -------------------------------------------
if command -v kubectl >/dev/null 2>&1; then
  check "kustomize: solution/base renders" \
    kubectl kustomize solution/base
  check "kustomize: solution/overlays/prod renders" \
    kubectl kustomize solution/overlays/prod
else
  defer_note "kustomize: solution/base renders" "kubectl kustomize solution/base"
  defer_note "kustomize: solution/overlays/prod renders" "kubectl kustomize solution/overlays/prod"
fi

# --- Gate 4: offline structural tests -----------------------------------------
check "tests: unittest discover -s tests (structural assertions)" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# --- Gate 5: shell syntax -----------------------------------------------------
check "shell: validate.sh syntax" bash -n validate.sh

# --- Gate 6: kubeconform offline schema validation ----------------------------
# Strict JSON-schema validation of every object kubectl would actually send to
# the API server (the base render, the prod overlay render, and the broken
# fixtures). Runs wherever `kubeconform` is installed; degrades to DEFER if not.
if command -v kubeconform >/dev/null 2>&1 && command -v kubectl >/dev/null 2>&1; then
  kc_base() { kubectl kustomize solution/base | kubeconform -strict -summary; }
  kc_prod() { kubectl kustomize solution/overlays/prod | kubeconform -strict -summary; }
  kc_broken() { kubeconform -strict -summary broken/deployment-oomkilled.yaml broken/deployment-badprobe.yaml; }
  check "kubeconform: -strict on solution/base render" kc_base
  check "kubeconform: -strict on solution/overlays/prod render" kc_prod
  check "kubeconform: -strict on broken fixtures" kc_broken
else
  defer_note "kubeconform: -strict schema validation of the render" \
    "kubectl kustomize solution/base | kubeconform -strict -summary"
fi

# --- Gate 7: LIVE cluster gates (apply + runtime troubleshooting) --------------
# Runs only when a Kubernetes cluster is reachable. Everything goes into a
# unique namespace and is torn down at the end, so re-runs leave nothing behind.
# Requires the image docker-containers-demo:1.0.0 to be loadable by the cluster
# (e.g. `kind load docker-image docker-containers-demo:1.0.0`); if it is absent
# the rollout gate FAILS loudly rather than hiding it.
LAB_NS="${LAB_NS:-lab-k8s-validate}"

live_cleanup() {
  kubectl delete ns "$LAB_NS" --ignore-not-found --wait=false >/dev/null 2>&1 || true
}

# Render the base into $LAB_NS (the base hardcodes namespace `web`): rename the
# Namespace object to $LAB_NS and set metadata.namespace on every other object.
# Note: `kubectl kustomize` output is written to a temp file first; we cannot
# both pipe it into `python3 -` AND pass the program on stdin (a heredoc would
# shadow the piped data), so we transform from a file instead.
render_into_ns() {
  local raw rendered
  raw="$(mktemp)"; rendered="$(mktemp)"
  kubectl kustomize solution/base >"$raw" || { rm -f "$raw" "$rendered"; return 1; }
  python3 - "$raw" "$rendered" "$LAB_NS" <<'PY' || { rm -f "$raw" "$rendered"; return 1; }
import sys, yaml
src, dst, ns = sys.argv[1], sys.argv[2], sys.argv[3]
docs = [d for d in yaml.safe_load_all(open(src)) if d]
for d in docs:
    if d.get("kind") == "Namespace":
        d["metadata"]["name"] = ns          # keep PSA `restricted` labels
    else:
        d.setdefault("metadata", {})["namespace"] = ns
with open(dst, "w") as fh:
    yaml.safe_dump_all(docs, fh, sort_keys=False)
PY
  cat "$rendered"
  rm -f "$raw" "$rendered"
}

live_happy_path() {
  render_into_ns | kubectl apply -f - >/dev/null || return 1
  kubectl -n "$LAB_NS" rollout status deploy/web --timeout=120s || return 1
  # Assert 2/2 Ready replicas.
  local ready
  ready=$(kubectl -n "$LAB_NS" get deploy web -o jsonpath='{.status.readyReplicas}')
  [ "$ready" = "2" ] || { echo "expected 2 ready replicas, got '${ready:-0}'"; return 1; }
  echo "deploy/web is ${ready}/2 Ready in ns $LAB_NS"
}

live_oomkilled() {
  sed 's/namespace: web/namespace: '"$LAB_NS"'/' broken/deployment-oomkilled.yaml \
    | kubectl apply -f - >/dev/null || return 1
  # Wait up to 90s for the documented runtime OOM kill (Reason OOMKilled / 137).
  local i pod reason ec
  for i in $(seq 1 30); do
    pod=$(kubectl -n "$LAB_NS" get pod -l app.kubernetes.io/name=web-oom \
            -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    reason=$(kubectl -n "$LAB_NS" get pod "$pod" \
              -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' 2>/dev/null)
    ec=$(kubectl -n "$LAB_NS" get pod "$pod" \
          -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}' 2>/dev/null)
    if [ "$reason" = "OOMKilled" ] && [ "$ec" = "137" ]; then
      echo "$pod: Reason=OOMKilled Exit Code=137 (CrashLoopBackOff)"
      kubectl -n "$LAB_NS" delete deploy web-oom --ignore-not-found --wait=false >/dev/null 2>&1
      return 0
    fi
    sleep 3
  done
  echo "did not observe OOMKilled/137 (last: reason='$reason' exit='$ec')"
  kubectl -n "$LAB_NS" delete deploy web-oom --ignore-not-found --wait=false >/dev/null 2>&1
  return 1
}

live_badprobe() {
  sed 's/namespace: web/namespace: '"$LAB_NS"'/' broken/deployment-badprobe.yaml \
    | kubectl apply -f - >/dev/null || return 1
  # Pod should become Running but never Ready (readiness on 9999), and the
  # Service should have NO endpoints. Sample a stable window (~30s).
  local i pod phase ready eps
  for i in $(seq 1 12); do
    pod=$(kubectl -n "$LAB_NS" get pod -l app.kubernetes.io/name=web-badprobe \
            -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    phase=$(kubectl -n "$LAB_NS" get pod "$pod" -o jsonpath='{.status.phase}' 2>/dev/null)
    ready=$(kubectl -n "$LAB_NS" get pod "$pod" \
              -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
    if [ "$phase" = "Running" ] && [ "$ready" = "false" ] && [ "$i" -ge 4 ]; then
      # The endpoints object may list the pod under notReadyAddresses; what must
      # be empty is the READY addresses (.subsets[*].addresses) — that is what
      # makes `kubectl get endpoints` show ENDPOINTS <none> and routes no traffic.
      eps=$(kubectl -n "$LAB_NS" get endpoints web-badprobe \
              -o jsonpath='{.subsets[*].addresses}' 2>/dev/null)
      [ -z "$eps" ] || { echo "expected no ready endpoints, got: $eps"; return 1; }
      echo "$pod: Running but 0/1 Ready; Service web-badprobe ready endpoints = <none>"
      kubectl -n "$LAB_NS" delete deploy web-badprobe svc web-badprobe \
        --ignore-not-found --wait=false >/dev/null 2>&1
      return 0
    fi
    sleep 4
  done
  echo "did not observe stable Running-but-not-Ready (phase='$phase' ready='$ready')"
  kubectl -n "$LAB_NS" delete deploy web-badprobe svc web-badprobe \
    --ignore-not-found --wait=false >/dev/null 2>&1
  return 1
}

if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
  trap live_cleanup EXIT
  live_cleanup                         # start from a clean slate
  kubectl create ns "$LAB_NS" >/dev/null 2>&1 || true
  check "cluster: apply base into ns $LAB_NS + 2/2 Ready" live_happy_path
  check "cluster: reproduce OOMKilled fixture (Reason OOMKilled, exit 137)" live_oomkilled
  check "cluster: reproduce never-Ready probe fixture (empty endpoints)" live_badprobe
  live_cleanup
else
  defer_note "cluster: apply base + observe 2/2 Ready pods (no cluster reachable)" \
    "kubectl apply -k solution/base && kubectl -n web rollout status deploy/web"
  defer_note "cluster: reproduce OOMKilled fixture (no cluster reachable)" \
    "kubectl apply -f broken/deployment-oomkilled.yaml && kubectl -n web get pods -w"
  defer_note "cluster: reproduce never-Ready probe fixture (no cluster reachable)" \
    "kubectl apply -f broken/deployment-badprobe.yaml && kubectl -n web get endpoints web-badprobe"
fi

# --- Gate 8: kubectl client dry-run (needs a cluster for RESTMapping) ----------
# `kubectl apply --dry-run=client` contacts the API server to map Kinds to
# resources, so it adds nothing the LIVE apply above does not already prove;
# documented here for environments without the kustomize/kubeconform path:
defer_note "kubectl: apply --dry-run=client per manifest (superseded by live apply)" \
  "for f in solution/base/*.yaml broken/*.yaml; do kubectl apply --dry-run=client --validate=false -f \"\$f\"; done"

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
