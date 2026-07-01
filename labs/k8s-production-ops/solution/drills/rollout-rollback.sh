#!/usr/bin/env bash
# Drill 1 — Rollout / rollback.
#
# Deploy cpu-burner v1 (good) at 3 replicas, wait for a healthy rollout, then
# `kubectl set image` to a NON-EXISTENT tag. With maxUnavailable:0 the new
# ReplicaSet's pod wedges in ImagePullBackOff/ErrImagePull and `kubectl rollout
# status` FAILS (the old pods keep serving). We then `kubectl rollout undo` and
# show the deployment healthy again. Captures rollout history + get pods.
#
# Usage:  ./rollout-rollback.sh [NAMESPACE]
# Env:    KCTX (kube context, default kind-course)
# Output: human-readable to stdout; the caller (run-drills.sh) tees it to evidence.
set -uo pipefail

KCTX="${KCTX:-kind-course}"
NS="${1:-prodops-rollout-$$}"
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFESTS="$(cd "$HERE/../manifests" && pwd)"
k() { kubectl --context "$KCTX" "$@"; }

# shellcheck disable=SC2317  # invoked via trap, not statically reachable
cleanup() { k delete ns "$NS" --ignore-not-found --wait=false >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "=================================================================="
echo "DRILL 1: rollout / rollback   (ns=$NS  ctx=$KCTX)"
echo "=================================================================="

# --- v1 good deploy -------------------------------------------------------------
k create ns "$NS" >/dev/null 2>&1 || true
k -n "$NS" apply -f "$MANIFESTS/deployment.yaml" >/dev/null
k -n "$NS" apply -f "$MANIFESTS/service.yaml"   >/dev/null
echo "--- [v1] waiting for healthy rollout of cpu-burner:1.0.0 ---"
if ! k -n "$NS" rollout status deploy/cpu-burner --timeout=120s; then
  echo "FATAL: v1 never became healthy; is cpu-burner:1.0.0 loaded in the cluster?"
  echo "  fix: docker pull/build cpu-burner:1.0.0 && kind load docker-image cpu-burner:1.0.0 --name <cluster>"
  exit 1
fi
echo
echo "--- [v1] pods (expect 3/3 Running) ---"
k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner -o wide

# --- push a BAD image -----------------------------------------------------------
echo
echo "--- [v2-BAD] set image to a non-existent tag -> rollout must get STUCK ---"
k -n "$NS" set image deploy/cpu-burner cpu-burner=cpu-burner:nonexistent-v2 --record >/dev/null 2>&1 \
  || k -n "$NS" set image deploy/cpu-burner cpu-burner=cpu-burner:nonexistent-v2 >/dev/null
echo "rollout status (expected to FAIL within the timeout):"
if k -n "$NS" rollout status deploy/cpu-burner --timeout=45s; then
  echo "UNEXPECTED: rollout reported success with a bad image"
  exit 1
else
  ROLLOUT_RC=$?
  echo "  -> kubectl rollout status exited non-zero ($ROLLOUT_RC) as designed."
fi

echo
echo "--- [v2-BAD] pods: new ReplicaSet pod should be ImagePullBackOff/ErrImagePull ---"
k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner -o wide
echo
echo "--- [v2-BAD] waiting-state reasons across pods ---"
k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}' \
  | sed 's/\t$/\t<running>/'
echo
echo "--- [v2-BAD] still-Ready replicas (old v1 pods keep serving) ---"
READY_DURING=$(k -n "$NS" get deploy cpu-burner -o jsonpath='{.status.readyReplicas}')
echo "readyReplicas during stuck rollout = ${READY_DURING:-0} (availability preserved by maxUnavailable:0)"

echo
echo "--- rollout history BEFORE undo ---"
k -n "$NS" rollout history deploy/cpu-burner

# --- rollback -------------------------------------------------------------------
echo
echo "--- [undo] kubectl rollout undo -> back to last good revision ---"
k -n "$NS" rollout undo deploy/cpu-burner
if ! k -n "$NS" rollout status deploy/cpu-burner --timeout=120s; then
  echo "FATAL: rollback did not converge"
  exit 1
fi
echo
echo "--- [undo] pods (expect 3/3 Running on cpu-burner:1.0.0) ---"
k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner -o wide
echo
echo "--- [undo] images on the live ReplicaSet ---"
k -n "$NS" get deploy cpu-burner -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
echo
echo "--- rollout history AFTER undo ---"
k -n "$NS" rollout history deploy/cpu-burner

READY_FINAL=$(k -n "$NS" get deploy cpu-burner -o jsonpath='{.status.readyReplicas}')
IMG_FINAL=$(k -n "$NS" get deploy cpu-burner -o jsonpath='{.spec.template.spec.containers[0].image}')
echo
if [ "$READY_FINAL" = "3" ] && [ "$IMG_FINAL" = "cpu-burner:1.0.0" ]; then
  echo "RESULT: PASS — rollback healthy (3/3 Ready on $IMG_FINAL)."
  exit 0
else
  echo "RESULT: FAIL — after undo readyReplicas=$READY_FINAL image=$IMG_FINAL"
  exit 1
fi
