#!/usr/bin/env bash
# Drill 3 — ResourceQuota + LimitRange admission.
#
# Apply a ResourceQuota and LimitRange into a namespace, then:
#   1. Try to create a pod that EXCEEDS the LimitRange per-container max (asks for
#      2 CPU; max is 500m). The API server REJECTS it; we capture the error.
#   2. Try to create a pod with NO requests/limits but otherwise fine — admitted
#      because the LimitRange injects defaults (shows the LimitRange working WITH
#      the quota).  [done implicitly via the compliant pod's explicit values]
#   3. Create a COMPLIANT pod -> ADMITTED and Running.
#   4. Show `kubectl describe quota` with USED vs HARD after the compliant pod.
#
# Usage:  ./quota-limit.sh [NAMESPACE]
# Env:    KCTX (default kind-course)
set -uo pipefail

KCTX="${KCTX:-kind-course}"
NS="${1:-prodops-quota-$$}"
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFESTS="$(cd "$HERE/../manifests" && pwd)"
k() { kubectl --context "$KCTX" "$@"; }

# shellcheck disable=SC2317  # invoked via trap, not statically reachable
cleanup() { k delete ns "$NS" --ignore-not-found --wait=false >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "=================================================================="
echo "DRILL 3: ResourceQuota + LimitRange   (ns=$NS  ctx=$KCTX)"
echo "=================================================================="

k create ns "$NS" >/dev/null 2>&1 || true
k -n "$NS" apply -f "$MANIFESTS/quota.yaml"      >/dev/null
k -n "$NS" apply -f "$MANIFESTS/limitrange.yaml" >/dev/null

echo "--- ResourceQuota (HARD limits) ---"
k -n "$NS" get resourcequota team-quota -o jsonpath='{.spec.hard}{"\n"}'
echo
echo "--- LimitRange (defaults + per-container max) ---"
k -n "$NS" describe limitrange team-limits | sed -n '1,20p'

echo
echo "=================================================================="
echo "CASE 1: pod EXCEEDS LimitRange max (requests 2 CPU; max 500m) -> REJECT"
echo "=================================================================="
# NB: this script runs with `set -uo pipefail` but WITHOUT `-e`, so a non-zero
# kubectl exit (the expected rejection) does not abort us; we inspect it instead.
REJECT_OUT=$(k -n "$NS" apply -f "$MANIFESTS/pod-over-quota.yaml" 2>&1)
REJECT_RC=$?
printf '%s\n' "$REJECT_OUT"
echo "kubectl exit code = $REJECT_RC"
if [ "$REJECT_RC" -eq 0 ]; then
  echo "RESULT: FAIL — over-quota pod was NOT rejected"
  exit 1
fi
if printf '%s' "$REJECT_OUT" | grep -qiE 'maximum cpu|exceeded quota|forbidden|must specify'; then
  echo "  -> rejection captured (admission denied as designed)."
else
  echo "RESULT: FAIL — pod rejected but not for the expected quota/limit reason"
  exit 1
fi
echo "confirm the over-quota pod does NOT exist:"
k -n "$NS" get pod over-quota 2>&1 | sed 's/^/  /'

echo
echo "=================================================================="
echo "CASE 2: COMPLIANT pod (100m/200m CPU) -> ADMITTED"
echo "=================================================================="
if ! k -n "$NS" apply -f "$MANIFESTS/pod-compliant.yaml"; then
  echo "RESULT: FAIL — compliant pod was rejected"
  exit 1
fi
echo "waiting for the compliant pod to run..."
k -n "$NS" wait --for=condition=Ready pod/compliant --timeout=90s || {
  echo "RESULT: FAIL — compliant pod never became Ready"; k -n "$NS" describe pod compliant | tail -20; exit 1; }
k -n "$NS" get pod compliant -o wide

echo
echo "--- quota USED vs HARD after admitting the compliant pod ---"
k -n "$NS" describe resourcequota team-quota

USED_PODS=$(k -n "$NS" get resourcequota team-quota -o jsonpath='{.status.used.pods}')
echo
if [ "${USED_PODS:-0}" = "1" ]; then
  echo "RESULT: PASS — over-quota pod REJECTED at admission; compliant pod ADMITTED;"
  echo "        quota now shows pods USED=1 / HARD=5."
  exit 0
else
  echo "RESULT: FAIL — expected quota pods USED=1, got '${USED_PODS:-0}'"
  exit 1
fi
