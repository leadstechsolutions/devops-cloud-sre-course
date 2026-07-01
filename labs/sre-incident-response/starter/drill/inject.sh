#!/usr/bin/env bash
# inject.sh (STARTER) -- deploy the healthy payments-web app, then INJECT a
# readiness-probe fault so the Service degrades.
#
# The healthy-deploy half is done for you. YOUR JOB is the fault injection:
# fill the TODO(student) block so a bad "v2" rollout actually empties the
# Service endpoints. Check yourself against solution/drill/inject.sh.
#
# Usage:
#   ./inject.sh            # deploy healthy, then inject the fault
#   ./inject.sh --healthy  # deploy ONLY the healthy baseline (no fault)
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
# TODO(student): inject the readiness-probe fault by patching the Deployment to:
#   1) point the `nginx-conf` volume at the BAD ConfigMap (payments-web-config-v2)
#      -- the one whose /healthz returns 503 (you wrote it in
#      manifests/11-configmap-bad.yaml);
#   2) bump the pod-template annotation `config-version` to "v2" so the template
#      actually changes and a NEW rollout starts (swapping a ConfigMap referenced
#      by a volume does NOT restart pods on its own);
#   3) set the rollout strategy to maxUnavailable=100% (and maxSurge=100%) so the
#      old healthy pods are torn down immediately -> endpoints reach ZERO (a true
#      outage you can observe), instead of a partial stall.
#
# Hint: one `kc patch deploy/$DEP --type=strategic -p '{...}'` does all three.
# Verify against solution/drill/inject.sh.
#
# Replace the line below with your patch:
echo "TODO(student): inject the fault here (see the TODO block above)" >&2
exit 3

log "INJECT: bad rollout in progress; readiness probe will fail on the new pods"
log "INJECT: (this is the fault -- run observe.sh to capture the symptom)"
