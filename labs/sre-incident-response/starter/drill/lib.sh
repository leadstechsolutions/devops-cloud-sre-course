#!/usr/bin/env bash
# Shared helpers for the injected-incident drill (inject/observe/recover/run-drill).
# Source this; do not execute it directly.
#
# Conventions:
#   NS         - the dedicated, disposable namespace for the drill.
#   DEP        - the Deployment under test.
#   SVC        - the Service whose endpoints we watch degrade and recover.
#   MANIFESTS  - directory holding the declarative manifests.
#   PROBE_IMG  - an image already present in the kind node (no network pull),
#                used for an in-cluster curl-equivalent so we exercise the real
#                Service ClusterIP/DNS path, not just kubectl status.
#
# Everything is namespaced to NS and nothing here touches other namespaces.

# shellcheck disable=SC2034  # these are consumed by the sourcing scripts.
NS="${NS:-lab-incident}"
DEP="${DEP:-payments-web}"
SVC="${SVC:-payments-web}"
PROBE_IMG="${PROBE_IMG:-python:3.12-alpine}"

# KUBE_CONTEXT pins every kubectl call to a specific context, so the drill is
# robust to ambient current-context churn (e.g. a sibling lab that runs
# `kind create/delete cluster` and rewrites ~/.kube/config). Defaults to the
# course cluster; set KUBE_CONTEXT="" to fall back to the current context.
KUBE_CONTEXT="${KUBE_CONTEXT-kind-course}"

# Resolve the manifests dir relative to this lib regardless of caller CWD.
_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="${MANIFESTS:-$_LIB_DIR/manifests}"

# k: kubectl with the pinned context (if any). EVERY kubectl call in the drill
# goes through this so the context cannot drift mid-run.
k() {
  if [ -n "$KUBE_CONTEXT" ]; then
    kubectl --context "$KUBE_CONTEXT" "$@"
  else
    kubectl "$@"
  fi
}

# kc: like k() but also pinned to the drill namespace. A single chokepoint so no
# command can accidentally run against another namespace.
kc() { k -n "$NS" "$@"; }

# ts: ISO-8601 UTC timestamp for the incident timeline.
ts() { date -u +'%Y-%m-%dT%H:%M:%SZ'; }

# log: timestamped line to stdout AND (if EVIDENCE is set) appended to the
# evidence file, so run-drill.sh builds a real incident timeline as it goes.
log() {
  local line
  line="$(ts)  $*"
  printf '%s\n' "$line"
  [ -n "${EVIDENCE:-}" ] && printf '%s\n' "$line" >>"$EVIDENCE"
  return 0
}

# cap: run a command, echo its output to stdout AND (if EVIDENCE is set) append
# it to the evidence file, so the committed timeline contains the real kubectl
# tables (pods/endpoints), not just the narration lines. Never fails the caller.
cap() {
  local out
  out="$("$@" 2>&1)" || true
  printf '%s\n' "$out"
  [ -n "${EVIDENCE:-}" ] && printf '%s\n' "$out" >>"$EVIDENCE"
  return 0
}

# require_cluster: fail fast if kubectl cannot reach a cluster. Keeps the drill
# from leaving half-applied state when there is no cluster at all.
require_cluster() {
  if [ -n "$KUBE_CONTEXT" ] && ! kubectl config get-contexts -o name 2>/dev/null \
       | grep -qx "$KUBE_CONTEXT"; then
    echo "ERROR: kube context '$KUBE_CONTEXT' not found." >&2
    echo "       Set KUBE_CONTEXT to an existing context (kubectl config get-contexts)," >&2
    echo "       or KUBE_CONTEXT= to use the current one." >&2
    return 1
  fi
  if ! k version >/dev/null 2>&1; then
    echo "ERROR: kubectl cannot reach a cluster via context '${KUBE_CONTEXT:-<current>}'." >&2
    echo "       Start one with: kind create cluster   (or use the course cluster)." >&2
    return 1
  fi
}

# ready_endpoints: count of ready endpoint addresses behind the Service. This is
# THE signal that the incident is real: it drops to 0 on the bad rollout and
# returns to replica-count on recovery. Works on both the v1 Endpoints API and
# (defensively) returns 0 when the object exists but has no subsets.
ready_endpoints() {
  kc get endpoints "$SVC" -o json 2>/dev/null \
    | python3 -c '
import json,sys
try:
    d=json.load(sys.stdin)
except Exception:
    print(0); sys.exit(0)
n=0
for s in d.get("subsets") or []:
    n+=len(s.get("addresses") or [])
print(n)
'
}

# ready_replicas: Deployment .status.readyReplicas (0 if unset).
ready_replicas() {
  kc get deploy "$DEP" -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -E '^[0-9]+$' || echo 0
}

# unhealthy_events: the most recent "Unhealthy" (probe-failed) events in NS --
# the breadcrumb that says WHY pods are not Ready (e.g. "statuscode: 503").
unhealthy_events() {
  kc get events --field-selector reason=Unhealthy --sort-by=.lastTimestamp 2>/dev/null | tail -6
}

# probe_service: in-cluster HTTP probe of the Service over its ClusterIP/DNS,
# using an image already cached in the node. Prints one of:
#   HTTP <code>        - the Service answered (e.g. 200 healthy, 503 degraded)
#   DOWN <reason>      - no ready backend / connection refused / timeout
# Exit status mirrors success(0)/failure(1) so callers can gate on it.
probe_service() {
  local path="${1:-/healthz}" out rc=0
  if out="$(kc run "drill-probe-$RANDOM" \
        --image="$PROBE_IMG" --image-pull-policy=IfNotPresent \
        --restart=Never --rm -i --quiet --command -- \
        python3 -c "
import urllib.request as u, urllib.error, sys
try:
    r=u.urlopen('http://$SVC$path', timeout=4)
    print('HTTP', r.status); sys.exit(0 if r.status==200 else 1)
except urllib.error.HTTPError as e:
    print('HTTP', e.code); sys.exit(1)
except Exception as e:
    print('DOWN', type(e).__name__); sys.exit(1)
" 2>/dev/null)"; then
    rc=0
  else
    rc=1
  fi
  # The run pod prints the python output; surface its last HTTP/DOWN line.
  printf '%s\n' "$out" | grep -E '^(HTTP|DOWN)' | tail -1
  return "$rc"
}
