#!/usr/bin/env bash
# Drill 4 — NetworkPolicy ENFORCEMENT, proven on a Calico cluster.
#
# kindnet (the course cluster's CNI) does NOT enforce NetworkPolicy: a
# default-deny is silently ignored, so you cannot prove anything on kind-course.
# This drill therefore creates its OWN single-node kind cluster with the default
# CNI disabled, installs Calico, and proves enforcement end to end:
#
#   step A  client -> server curl:           ALLOWED (no policy yet)        exit 0
#   step B  apply default-deny-ingress, curl: BLOCKED (times out)           exit !=0
#   step C  apply allow-client-to-server, curl: ALLOWED again               exit 0
#
# Exit codes of the in-pod curl are the proof and are printed verbatim.
# The cluster is ALWAYS deleted on exit (trap), even on failure.
#
# Heavy: creating the cluster + installing Calico takes a few minutes. Run it
# directly or via run-drills.sh (RUN_LIVE=1).
#
# Env:
#   CLUSTER_NAME   kind cluster name              (default netpol)
#   CALICO_VERSION Calico manifest tag            (default v3.27.4)
#   KEEP_CLUSTER=1 skip teardown (debugging only)
set -uo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-netpol}"
CALICO_VERSION="${CALICO_VERSION:-v3.27.4}"
CTX="kind-${CLUSTER_NAME}"
NS="netpol-demo"
HERE="$(cd "$(dirname "$0")" && pwd)"
NPDIR="$(cd "$HERE/../manifests/netpol" && pwd)"
CALICO_URL="https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/calico.yaml"

k() { kubectl --context "$CTX" "$@"; }

# shellcheck disable=SC2317  # invoked via trap, not statically reachable
cleanup() {
  if [ "${KEEP_CLUSTER:-0}" = "1" ]; then
    echo "KEEP_CLUSTER=1 -> leaving cluster '$CLUSTER_NAME' up (delete it yourself)."
    return
  fi
  echo "--- tearing down kind cluster '$CLUSTER_NAME' ---"
  kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=================================================================="
echo "DRILL 4: NetworkPolicy enforcement on Calico   (cluster=$CLUSTER_NAME)"
echo "=================================================================="

# Idempotency: if a stale cluster of this name exists, remove it first.
kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true

echo "--- creating kind cluster with default CNI DISABLED ---"
kind create cluster --name "$CLUSTER_NAME" --config "$NPDIR/kind-calico.yaml" || {
  echo "FATAL: kind create failed"; exit 1; }

echo
echo "--- installing Calico ${CALICO_VERSION} ---"
k apply -f "$CALICO_URL" || { echo "FATAL: could not apply Calico manifest from $CALICO_URL"; exit 1; }

echo "--- waiting for Calico to be ready (calico-node + calico-kube-controllers) ---"
k -n kube-system rollout status ds/calico-node --timeout=240s || {
  echo "FATAL: calico-node did not become ready"; k -n kube-system get pods; exit 1; }
k wait --for=condition=Ready node --all --timeout=120s
echo "nodes:"; k get nodes -o wide

# Side-load the images the workload needs so we don't depend on the cluster
# pulling them under policy (and so cpu-burner:1.0.0, which is local-only, exists).
echo
echo "--- side-loading workload images into '$CLUSTER_NAME' ---"
for img in cpu-burner:1.0.0 curlimages/curl:8.10.1; do
  if ! docker image inspect "$img" >/dev/null 2>&1; then
    echo "  pulling $img ..."; docker pull "$img" >/dev/null 2>&1 || true
  fi
  echo "  loading $img ..."; kind load docker-image "$img" --name "$CLUSTER_NAME" >/dev/null 2>&1 \
    || echo "  WARN: could not preload $img (cluster may still pull it)"
done

echo
echo "--- deploying server + client into ns/$NS ---"
k create ns "$NS" >/dev/null 2>&1 || true
k -n "$NS" apply -f "$NPDIR/workload.yaml" >/dev/null
k -n "$NS" wait --for=condition=Ready pod/server --timeout=120s || {
  echo "FATAL: server pod not Ready"; k -n "$NS" describe pod server | tail -25; exit 1; }
k -n "$NS" wait --for=condition=Ready pod/client --timeout=120s || {
  echo "FATAL: client pod not Ready"; k -n "$NS" describe pod client | tail -25; exit 1; }
k -n "$NS" get pods -o wide

# curl server Service from inside the client pod. --max-time bounds the BLOCKED
# case so a dropped packet shows up as a timeout (curl exit 28) not a hang.
probe() {  # prints the in-pod curl result; sets global PROBE_RC
  local out
  out=$(k -n "$NS" exec client -- sh -c \
        'curl -s -o /dev/null -w "%{http_code}" --max-time 6 http://server:8000/healthz' 2>&1)
  PROBE_RC=$?
  printf 'http_code=%s  curl_exit=%s\n' "${out:-<none>}" "$PROBE_RC"
}

echo
echo "=================================================================="
echo "STEP A: NO policy yet -> client->server should be ALLOWED"
echo "=================================================================="
probe; A_RC=$PROBE_RC
if [ "$A_RC" -ne 0 ]; then
  echo "FATAL: baseline connectivity failed (curl_exit=$A_RC) before any policy"
  exit 1
fi
echo "  -> ALLOWED (curl exit 0) as expected with no NetworkPolicy."

echo
echo "=================================================================="
echo "STEP B: apply default-deny-ingress -> client->server should be BLOCKED"
echo "=================================================================="
k -n "$NS" apply -f "$NPDIR/default-deny.yaml"
echo "(giving Calico a moment to program the deny)"; sleep 5
probe; B_RC=$PROBE_RC
if [ "$B_RC" -eq 0 ]; then
  echo "FATAL: traffic still flowed AFTER default-deny — CNI is not enforcing policy"
  exit 1
fi
echo "  -> BLOCKED (curl exit $B_RC; 28=timeout) — Calico enforced the default-deny."

echo
echo "=================================================================="
echo "STEP C: apply allow-client-to-server -> client->server ALLOWED again"
echo "=================================================================="
k -n "$NS" apply -f "$NPDIR/allow-client-to-server.yaml"
echo "(giving Calico a moment to program the allow)"; sleep 5
probe; C_RC=$PROBE_RC
if [ "$C_RC" -ne 0 ]; then
  echo "FATAL: allow policy did not restore connectivity (curl_exit=$C_RC)"
  k -n "$NS" get networkpolicy
  exit 1
fi
echo "  -> ALLOWED again (curl exit 0) — the explicit allow re-opened only this flow."

echo
echo "--- NetworkPolicies in effect ---"
k -n "$NS" get networkpolicy

echo
echo "=================================================================="
echo "RESULT: PASS — enforcement proven."
echo "  STEP A (no policy)     curl_exit=$A_RC  (ALLOWED)"
echo "  STEP B (default-deny)  curl_exit=$B_RC  (BLOCKED)"
echo "  STEP C (allow policy)  curl_exit=$C_RC  (ALLOWED)"
echo "=================================================================="
exit 0
