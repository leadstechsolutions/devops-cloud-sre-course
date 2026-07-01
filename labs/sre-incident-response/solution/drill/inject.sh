#!/usr/bin/env bash
# inject.sh -- deploy the healthy payments-web app to ns lab-incident, then
# INJECT a fault: roll out a "v2" whose /healthz returns 503, so the readiness
# probe fails, new pods never become Ready, and the Service endpoints empty out.
#
# The fault is a config-driven regression (swap to the bad ConfigMap) shipped
# with a reckless rollout strategy (maxUnavailable=100%) -- the combination that
# turns a failing readiness probe into a full outage instead of a safe stall.
# That reckless strategy is itself an action item in the postmortem.
#
# Usage:
#   ./inject.sh            # deploy healthy, wait Ready, then inject the fault
#   ./inject.sh --healthy  # deploy/ensure ONLY the healthy baseline (no fault)
#
# Idempotent: re-running applies the same manifests; the namespace is created
# if absent. Cleanup is run-drill.sh's job (or: kubectl delete ns lab-incident).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

MODE="${1:-inject}"

require_cluster

log "INJECT: applying healthy baseline manifests to ns/$NS (context=${KUBE_CONTEXT:-<current>})"
k apply -f "$MANIFESTS/00-namespace.yaml"
k apply -f "$MANIFESTS/10-configmap-healthy.yaml"
k apply -f "$MANIFESTS/11-configmap-bad.yaml"
k apply -f "$MANIFESTS/20-deployment.yaml"

log "INJECT: waiting for healthy rollout to become Ready"
if ! kc rollout status "deploy/$DEP" --timeout=120s; then
  echo "ERROR: healthy baseline did not become Ready; aborting before fault injection." >&2
  exit 1
fi
log "INJECT: baseline healthy -- readyReplicas=$(ready_replicas), endpoints=$(ready_endpoints)"

if [ "$MODE" = "--healthy" ]; then
  log "INJECT: --healthy requested; leaving baseline running WITHOUT injecting a fault"
  exit 0
fi

# ---- The fault ----------------------------------------------------------------
# 1) Point the config volume at the BAD ConfigMap (the /healthz-503 regression).
# 2) Bump the config-version annotation so the template actually changes and a
#    new rollout starts (a ConfigMap swap in a volume needs a template change).
# 3) Loosen the rollout strategy to maxUnavailable=100% so old healthy pods are
#    torn down immediately -> endpoints reach ZERO (a true outage, not a stall).
log "INJECT: shipping bad rollout v2 (config-version=v2, /healthz now 503, maxUnavailable=100%)"
kc patch "deploy/$DEP" --type=strategic -p '{
  "spec": {
    "strategy": {"rollingUpdate": {"maxSurge": "100%", "maxUnavailable": "100%"}},
    "template": {
      "metadata": {"annotations": {"config-version": "v2"}},
      "spec": {"volumes": [{"name": "nginx-conf", "configMap": {"name": "payments-web-config-v2"}}]}
    }
  }
}'

# Record the bad rollout for the timeline (change-cause shows in rollout history).
kc annotate "deploy/$DEP" \
  kubernetes.io/change-cause="ship payments-web v2 (REGRESSION: /healthz returns 503)" \
  --overwrite >/dev/null

log "INJECT: bad rollout in progress; readiness probe will fail on the new pods"
log "INJECT: (this is the fault -- run observe.sh to capture the symptom)"
