#!/usr/bin/env bash
# Orchestrator — runs all four production-ops drills LIVE and captures their real
# output into evidence/LIVE-OPS-EVIDENCE.txt (committed in the lab).
#
# This is the only "heavy" entry point: drill 4 builds a throwaway Calico kind
# cluster, so the whole run is multi-minute. It is therefore gated behind
# RUN_LIVE=1 so `validate.sh` stays fast by default.
#
#   RUN_LIVE=1 ./run-drills.sh                 # run everything, write evidence
#   RUN_LIVE=1 SKIP_NETPOL=1 ./run-drills.sh   # skip the slow Calico drill
#
# Env:
#   KCTX       context for drills 1-3   (default kind-course)
#   SKIP_NETPOL=1  skip drill 4 (Calico cluster)
set -uo pipefail

if [ "${RUN_LIVE:-0}" != "1" ]; then
  cat >&2 <<'MSG'
run-drills.sh is gated: it stands up live workloads (and a throwaway Calico kind
cluster) and takes several minutes. Re-run with RUN_LIVE=1 to execute:

  RUN_LIVE=1 ./run-drills.sh

(validate.sh runs the static gates without this; it runs the drills only under RUN_LIVE=1.)
MSG
  exit 2
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
EVID="$(cd "$HERE/../.." && pwd)/evidence/LIVE-OPS-EVIDENCE.txt"
KCTX="${KCTX:-kind-course}"
mkdir -p "$(dirname "$EVID")"

# Tee everything to the evidence file AND the terminal.
exec > >(tee "$EVID") 2>&1

echo "##################################################################"
echo "# k8s-production-ops — LIVE OPS EVIDENCE"
echo "# generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "# host kubectl: $(kubectl version --client -o json 2>/dev/null | python3 -c 'import sys,json;print(json.load(sys.stdin)["clientVersion"]["gitVersion"])' 2>/dev/null || echo unknown)"
echo "# drills context (1-3): $KCTX"
echo "# server (kind-course): $(kubectl --context "$KCTX" version -o json 2>/dev/null | python3 -c 'import sys,json;print(json.load(sys.stdin)["serverVersion"]["gitVersion"])' 2>/dev/null || echo unknown)"
echo "##################################################################"
echo

rc_total=0
run() {  # run <label> <script> [args...]
  local label="$1"; shift
  echo
  echo "################################################################"
  echo "# RUN: $label"
  echo "################################################################"
  if KCTX="$KCTX" bash "$@"; then
    echo ">>> $label: EXIT 0 (PASS)"
  else
    local rc=$?
    echo ">>> $label: EXIT $rc (FAIL)"
    rc_total=$((rc_total + 1))
  fi
}

run "Drill 1 — rollout/rollback"        "$HERE/rollout-rollback.sh"
run "Drill 2 — PodDisruptionBudget"     "$HERE/pdb-drain.sh"
run "Drill 3 — ResourceQuota+LimitRange" "$HERE/quota-limit.sh"

if [ "${SKIP_NETPOL:-0}" = "1" ]; then
  echo
  echo "################################################################"
  echo "# SKIP: Drill 4 — NetworkPolicy (SKIP_NETPOL=1)"
  echo "################################################################"
else
  run "Drill 4 — NetworkPolicy (Calico)" "$HERE/networkpolicy.sh"
fi

echo
echo "##################################################################"
if [ "$rc_total" -eq 0 ]; then
  echo "# ALL DRILLS PASSED"
else
  echo "# $rc_total DRILL(S) FAILED"
fi
echo "# evidence written to: $EVID"
echo "##################################################################"
exit "$rc_total"
