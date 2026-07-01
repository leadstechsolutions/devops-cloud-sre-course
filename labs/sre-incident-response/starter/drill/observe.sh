#!/usr/bin/env bash
# observe.sh -- capture the SYMPTOM of the injected incident. This is what an
# on-call engineer would run to confirm "yes, the service is degraded":
#   * kubectl get pods            -> new pods 0/1, not-Ready (readiness failing)
#   * kubectl get endpoints       -> the Service has lost its ready backends
#   * kubectl rollout status      -> the rollout is stalled / over deadline
#   * an in-cluster curl          -> the Service itself fails (DOWN / non-200)
#   * recent pod events           -> "Readiness probe failed: HTTP 503"
#
# It returns NON-ZERO when it observes a degraded state, so run-drill.sh and CI
# can assert "the fault was actually detectable". With --expect-healthy it
# inverts that (used to confirm recovery).
#
# Usage:
#   ./observe.sh                 # expect degraded; exit 1 if healthy
#   ./observe.sh --expect-healthy# expect healthy; exit 1 if degraded
set -uo pipefail   # NOTE: not -e; we run diagnostics that may legitimately fail.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

EXPECT="${1:-degraded}"
require_cluster || exit 2

echo "================ OBSERVE: payments-web in ns/$NS ================"

log "OBSERVE: deployment summary"
cap kc get deploy "$DEP" -o wide

log "OBSERVE: pods (look for 0/1 NotReady on the new ReplicaSet)"
cap kc get pods -l app="$DEP" -o wide

log "OBSERVE: service endpoints (ready backends behind the ClusterIP)"
cap kc get endpoints "$SVC" -o wide

EP="$(ready_endpoints)"
RR="$(ready_replicas)"
log "OBSERVE: ready endpoints=$EP  readyReplicas=$RR"

log "OBSERVE: rollout status (non-zero == stalled / over progress deadline)"
if kc rollout status "deploy/$DEP" --timeout=8s >/dev/null 2>&1; then
  ROLLOUT="complete"
else
  ROLLOUT="stalled-or-degraded"
fi
log "OBSERVE: rollout=$ROLLOUT"

log "OBSERVE: in-cluster probe of the Service (the customer-facing symptom)"
PROBE="$(probe_service /healthz || true)"
log "OBSERVE: probe result -> ${PROBE:-<no answer>}"

log "OBSERVE: recent readiness-probe events (root-cause breadcrumb)"
cap unhealthy_events

echo "================================================================"

# ---- verdict ------------------------------------------------------------------
# Degraded iff endpoints are gone OR the Service probe did not return HTTP 200.
degraded=0
case "$PROBE" in
  HTTP\ 200) : ;;             # service answered healthy
  *) degraded=1 ;;            # DOWN, 503, 500, or no answer
esac
[ "$EP" -eq 0 ] && degraded=1

if [ "$EXPECT" = "--expect-healthy" ]; then
  if [ "$degraded" -eq 0 ]; then
    log "OBSERVE: verdict = HEALTHY (as expected after recovery)"
    exit 0
  fi
  log "OBSERVE: verdict = STILL DEGRADED (expected healthy) -- recovery did NOT take"
  exit 1
fi

if [ "$degraded" -eq 1 ]; then
  log "OBSERVE: verdict = DEGRADED (incident confirmed: empty endpoints and/or failing probe)"
  exit 1
fi
log "OBSERVE: verdict = HEALTHY (no incident detected) -- did the fault injection run?"
exit 0
