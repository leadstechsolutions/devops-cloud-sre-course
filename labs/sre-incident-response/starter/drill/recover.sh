#!/usr/bin/env bash
# recover.sh (STARTER) -- restore service after the injected incident.
#
# YOUR JOB: implement the two-step recovery in the TODO(student) block:
#   1) mitigate fast with `kubectl rollout undo` (revert to the last-good
#      revision -- v1 config, /healthz=200);
#   2) then re-apply manifests/20-deployment.yaml to restore the SAFE rollout
#      strategy. (Gotcha: `rollout undo` reverts the pod template but NOT
#      .spec.strategy, so the reckless maxUnavailable=100% would otherwise
#      persist and re-arm the trap on the next deploy.)
# Check yourself against solution/drill/recover.sh.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

require_cluster

if ! kc get deploy "$DEP" >/dev/null 2>&1; then
  echo "ERROR: deploy/$DEP not found in ns/$NS -- nothing to recover (run inject.sh first)." >&2
  exit 1
fi

# ---- Recovery -----------------------------------------------------------------
# TODO(student): implement the two-step recovery described in the header.
#   step 1: kc rollout undo "deploy/$DEP"   (then wait for rollout status Ready)
#   step 2: kubectl apply -f "$MANIFESTS/20-deployment.yaml"  (restore strategy)
# After each step, wait with: kc rollout status "deploy/$DEP" --timeout=120s
echo "TODO(student): implement recovery here (see the TODO block above)" >&2
exit 3

# Verify the customer-facing signal is actually back (leave this in place once
# you've implemented the steps above).
PROBE="$(probe_service /healthz || true)"
log "RECOVER: in-cluster probe -> ${PROBE:-<no answer>}"
EP="$(ready_endpoints)"
log "RECOVER: ready endpoints=$EP  readyReplicas=$(ready_replicas)"

if [ "$PROBE" = "HTTP 200" ] && [ "$EP" -gt 0 ]; then
  log "RECOVER: verdict = RECOVERED"
  exit 0
fi
log "RECOVER: verdict = NOT FULLY RECOVERED (endpoints=$EP, probe=$PROBE)"
exit 1
