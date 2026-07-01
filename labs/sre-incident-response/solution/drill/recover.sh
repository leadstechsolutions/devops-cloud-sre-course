#!/usr/bin/env bash
# recover.sh -- restore service the way an on-call engineer would: roll back the
# bad deploy first (mitigate before root-causing), confirm recovery, THEN fix the
# latent risk that made it catastrophic (the reckless rollout strategy).
#
# Two-step recovery, mirroring the runbook (runbooks/high-error-rate.md s2.1):
#   1) `kubectl rollout undo` -> fast revert to the last-good pod template
#      (v1 config, /healthz=200). This is the mitigation that stops the bleeding.
#   2) re-apply 20-deployment.yaml -> restores the SAFE rollout strategy
#      (maxUnavailable=1). `rollout undo` reverts the pod template but NOT the
#      Deployment .spec.strategy, so the reckless 100% strategy would otherwise
#      persist -- a real, easily-missed gotcha. This is the durable fix.
#
# Exits non-zero if the service does not return to Ready.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

require_cluster

if ! kc get deploy "$DEP" >/dev/null 2>&1; then
  echo "ERROR: deploy/$DEP not found in ns/$NS -- nothing to recover (run inject.sh first)." >&2
  exit 1
fi

log "RECOVER: step 1/2 -- kubectl rollout undo (mitigate: revert to last-good revision)"
kc rollout undo "deploy/$DEP"

log "RECOVER: waiting for rollback to become Ready"
if ! kc rollout status "deploy/$DEP" --timeout=120s; then
  echo "ERROR: rollback did not reach Ready within timeout." >&2
  kc get pods -l app="$DEP" -o wide || true
  exit 1
fi
log "RECOVER: mitigated -- readyReplicas=$(ready_replicas), endpoints=$(ready_endpoints)"

log "RECOVER: step 2/2 -- re-apply manifest to restore the SAFE rollout strategy"
# `rollout undo` does not revert .spec.strategy, so re-apply the declarative
# manifest to bring maxUnavailable back to 1 (and re-pin the v1 config volume).
k apply -f "$MANIFESTS/20-deployment.yaml"
if ! kc rollout status "deploy/$DEP" --timeout=120s; then
  echo "ERROR: deployment did not settle after restoring safe strategy." >&2
  exit 1
fi

# Verify the customer-facing signal is actually back.
PROBE="$(probe_service /healthz || true)"
log "RECOVER: in-cluster probe -> ${PROBE:-<no answer>}"
EP="$(ready_endpoints)"
log "RECOVER: ready endpoints=$EP  readyReplicas=$(ready_replicas)"

if [ "$PROBE" = "HTTP 200" ] && [ "$EP" -gt 0 ]; then
  log "RECOVER: verdict = RECOVERED (healthy endpoints restored, /healthz=200, safe strategy)"
  exit 0
fi
log "RECOVER: verdict = NOT FULLY RECOVERED -- investigate (endpoints=$EP, probe=$PROBE)"
exit 1
