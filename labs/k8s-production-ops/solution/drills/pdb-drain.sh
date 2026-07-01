#!/usr/bin/env bash
# Drill 2 — PodDisruptionBudget behaviour.
#
# A real `kubectl drain` on a 1-node kind cluster would try to evict the system
# pods on the only node and is not a clean demo. Instead we exercise the PDB the
# way a drain WOULD: directly against the eviction API.
#
# We show, with real cluster output:
#   1. PDB object: minAvailable=2, currentHealthy=3, ALLOWED DISRUPTIONS=1.
#   2. A VOLUNTARY disruption via the eviction API:
#        - first eviction (3 -> would leave 2 ready): ALLOWED.
#        - second eviction while only 2 are ready:    DENIED (HTTP 429, the exact
#          error `kubectl drain` would surface and back off on).
#   3. An INVOLUNTARY disruption (`kubectl delete pod`) BYPASSES the PDB — proving
#      a PDB protects voluntary disruptions only.
#
# Usage:  ./pdb-drain.sh [NAMESPACE]
# Env:    KCTX (default kind-course)
set -uo pipefail

KCTX="${KCTX:-kind-course}"
NS="${1:-prodops-pdb-$$}"
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFESTS="$(cd "$HERE/../manifests" && pwd)"
k() { kubectl --context "$KCTX" "$@"; }

# shellcheck disable=SC2317  # invoked via trap, not statically reachable
cleanup() { k delete ns "$NS" --ignore-not-found --wait=false >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "=================================================================="
echo "DRILL 2: PodDisruptionBudget   (ns=$NS  ctx=$KCTX)"
echo "=================================================================="

k create ns "$NS" >/dev/null 2>&1 || true
k -n "$NS" apply -f "$MANIFESTS/deployment.yaml" >/dev/null
k -n "$NS" apply -f "$MANIFESTS/pdb.yaml"        >/dev/null
echo "--- waiting for 3/3 cpu-burner pods ---"
k -n "$NS" rollout status deploy/cpu-burner --timeout=120s || { echo "FATAL: deploy not ready"; exit 1; }

echo
echo "--- PDB object (note ALLOWED DISRUPTIONS) ---"
k -n "$NS" get pdb cpu-burner
echo
echo "--- PDB status (machine-readable) ---"
k -n "$NS" get pdb cpu-burner \
  -o jsonpath='minAvailable={.spec.minAvailable}{"\n"}currentHealthy={.status.currentHealthy}{"\n"}desiredHealthy={.status.desiredHealthy}{"\n"}disruptionsAllowed={.status.disruptionsAllowed}{"\n"}'
ALLOWED=$(k -n "$NS" get pdb cpu-burner -o jsonpath='{.status.disruptionsAllowed}')
if [ "${ALLOWED:-x}" != "1" ]; then
  echo "FATAL: expected disruptionsAllowed=1 with 3 healthy / minAvailable 2, got '${ALLOWED:-}'"
  exit 1
fi
echo "  -> ALLOWED DISRUPTIONS = 1  (currentHealthy 3 - minAvailable 2)"

# evict POD via the eviction subresource (this is what `kubectl drain` does).
evict() {  # evict <pod>; prints HTTP-ish result, returns 0 on 200, 1 on 429
  local pod="$1" out rc
  out=$(k -n "$NS" create -f - --raw "/api/v1/namespaces/$NS/pods/$pod/eviction" 2>&1 <<JSON
{"apiVersion":"policy/v1","kind":"Eviction","metadata":{"name":"$pod","namespace":"$NS"}}
JSON
)
  rc=$?
  printf '%s\n' "$out"
  return $rc
}

# Capture the three current pod names up front so disruption #2 targets a
# DISTINCT, still-healthy pod (not the one we just evicted).
mapfile -t PODS < <(k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner \
                      -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
POD1="${PODS[0]}"
echo
echo "--- VOLUNTARY disruption #1: evict $POD1 (3 healthy -> 2; budget allows) ---"
if evict "$POD1"; then
  echo "  -> eviction ALLOWED (budget had 1 disruption to give)."
else
  echo "FATAL: first eviction was denied but the budget should have allowed it"
  exit 1
fi

# disruptionsAllowed is now 0 until the replacement for POD1 becomes Ready. While
# it is 0, evicting a DISTINCT still-healthy pod MUST be refused with HTTP 429 —
# the exact condition `kubectl drain` backs off on. The replacement can become
# Ready in a few seconds, so we attempt the denied eviction in a tight, bounded
# loop and REQUIRE that we observe at least one 429 before the budget recovers.
echo
echo "--- disruptionsAllowed immediately after eviction #1 ---"
k -n "$NS" get pdb cpu-burner -o jsonpath='disruptionsAllowed={.status.disruptionsAllowed}{"\n"}'

echo
echo "--- VOLUNTARY disruption #2: evict a DISTINCT healthy pod while budget=0 -> MUST be DENIED ---"
DENIED=0
for attempt in 1 2 3 4 5 6 7 8; do
  # pick a still-existing pod that is NOT POD1
  TARGET=""
  for p in "${PODS[@]}"; do
    [ "$p" = "$POD1" ] && continue
    if k -n "$NS" get pod "$p" >/dev/null 2>&1; then TARGET="$p"; break; fi
  done
  [ -z "$TARGET" ] && { sleep 1; mapfile -t PODS < <(k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); continue; }
  echo "attempt $attempt: evict $TARGET"
  if EVOUT=$(evict "$TARGET" 2>&1); then
    printf '  %s\n' "$EVOUT"
    echo "  (allowed — budget had recovered; retrying to catch the budget=0 window)"
  else
    printf '  %s\n' "$EVOUT"
    if printf '%s' "$EVOUT" | grep -qiE 'disruption budget|TooManyRequests|429'; then
      echo "  -> eviction DENIED (HTTP 429 'Cannot evict ... violate the disruption budget')."
      echo "     This is exactly what 'kubectl drain' backs off and retries on."
      DENIED=1
      break
    fi
  fi
done
if [ "$DENIED" -ne 1 ]; then
  echo "FATAL: never observed the PDB denying an over-budget eviction"
  exit 1
fi

# Let the deployment recover to 3/3 so the involuntary-delete demo starts clean.
k -n "$NS" rollout status deploy/cpu-burner --timeout=120s >/dev/null 2>&1 || true

echo
echo "--- INVOLUNTARY disruption: 'kubectl delete pod' BYPASSES the PDB entirely ---"
# Target a currently-Running pod so the demo deletes a HEALTHY replica (budget=1).
DPOD=$(k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner \
        --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
[ -n "$DPOD" ] || DPOD=$(k -n "$NS" get pods -l app.kubernetes.io/name=cpu-burner -o jsonpath='{.items[0].metadata.name}')
echo "deleting healthy pod $DPOD directly (no eviction API => no budget check):"
k -n "$NS" delete pod "$DPOD" --wait=false
echo "  -> delete accepted regardless of the budget; a PDB does NOT stop direct deletes,"
echo "     node failures, kernel OOM, or other INVOLUNTARY disruptions."

echo
echo "--- deployment self-heals back to 3 replicas ---"
k -n "$NS" rollout status deploy/cpu-burner --timeout=120s || true
k -n "$NS" get pdb cpu-burner

FINAL_HEALTHY=$(k -n "$NS" get pdb cpu-burner -o jsonpath='{.status.currentHealthy}')
echo
if [ "${FINAL_HEALTHY:-0}" -ge 2 ]; then
  echo "RESULT: PASS — PDB observed: ALLOWED=1 at rest, eviction gated by minAvailable,"
  echo "        direct delete bypasses the budget, deployment recovered (currentHealthy=$FINAL_HEALTHY)."
  exit 0
else
  echo "RESULT: FAIL — PDB currentHealthy ended at ${FINAL_HEALTHY:-0}"
  exit 1
fi
