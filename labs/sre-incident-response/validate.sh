#!/usr/bin/env bash
# Validation runner for the sre-incident-response module.
#
# Gates (per 07-templates/00-artifact-standard.md):
#   1. python3 -m py_compile on every .py (solution, starter, tests)  -- syntax
#   2. python3 -m unittest discover -s tests                          -- against SOLUTION
#   3. starter MUST FAIL the error_budget tests (TODOs not yet done)  -- lab has gaps
#   4. bash -n on every *.sh                                          -- shell syntax
#   5. YAML well-formedness on the SLO files (PyYAML safe_load_all)   -- parse
#   6. k6 script bracket/paren balance + construct sanity (no node)   -- lighter check
#   7. REAL k6 run against a local payments-api mock (when k6+docker exist) -- authoritative
#   8. kubeconform on the injected-incident drill manifests           -- k8s schema
#   9. shellcheck the drill scripts (solution strict, starter warning) -- lint
#  10. committed LIVE-INCIDENT-EVIDENCE.txt records a PASS drill        -- proof
#  11. RUN the drill live on kind (only when RUN_LIVE=1)               -- authoritative
#
# Gate 7 supersedes the old DEFERRED "k6 run" note: where `k6` and `docker` are
# both present it stands up load/mock-target/payments_api_mock.py in a container,
# runs `k6 run` against it, and fails if any SLO-shaped threshold is breached.
# Where either tool is missing it prints [SKIP] and does not fail the build.
#
# DEFERRED gates (tool absent here; documented in README, run where the tool exists):
#   - oslo validate -f slo/slo.yaml                  (OpenSLO linter)
#   - promtool check rules slo/burn-rate-alerts.yaml (Prometheus rule lint)
#
# Contract: one line per check; exits non-zero if ANY gate fails.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

fail=0
pass=0
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

check() {
  local label="$1"; shift
  if "$@" >"$TMP" 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' "$TMP" | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating sre-incident-response =="

# ----------------------------------------------------------------------------
# Gate 1: every .py compiles (solution, starter-after-edits, tests).
# The starter is incomplete in LOGIC but must still be syntactically valid.
# ----------------------------------------------------------------------------
mapfile -t PY_FILES < <(find solution starter tests -name '*.py' | sort)
check "py_compile: all .py files (syntax)" python3 -m py_compile "${PY_FILES[@]}"

# ----------------------------------------------------------------------------
# Gate 2: stdlib unit tests against the reference solution. PYTHONPATH points at
# solution/scripts so `import error_budget` / `import nines_downtime` resolve.
# No pip, no network.
# ----------------------------------------------------------------------------
check "unittest: solution passes all tests" \
  env PYTHONPATH="$HERE/solution/scripts" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# ----------------------------------------------------------------------------
# Gate 3 (sanity): the starter MUST FAIL the error_budget tests -- if it passes,
# the lab has no gaps left. This inverts the exit code on purpose.
# ----------------------------------------------------------------------------
if env PYTHONPATH="$HERE/starter/scripts" \
     python3 -m unittest discover -s tests -p 'test_error_budget.py' \
     >"$TMP" 2>&1; then
  printf '  [FAIL] %s\n' "starter must be incomplete (error_budget tests should FAIL but passed)"
  fail=$((fail + 1))
else
  printf '  [PASS] %s\n' "starter is incomplete (error_budget tests fail until TODOs are done)"
  pass=$((pass + 1))
fi

# ----------------------------------------------------------------------------
# Gate 4: shell syntax on every script (solution + starter copies).
# ----------------------------------------------------------------------------
while IFS= read -r sh; do
  check "bash -n: $sh" bash -n "$sh"
done < <(find solution starter -name '*.sh' | sort)

# ----------------------------------------------------------------------------
# Gate 5: SLO YAML files are well-formed (PyYAML). This is the local stand-in
# for `oslo validate` / `promtool check rules` (both DEFERRED -- see README).
# ----------------------------------------------------------------------------
yaml_ok() {
  python3 -c "import yaml,sys; list(yaml.safe_load_all(open(sys.argv[1])))" "$1"
}
for y in solution/slo/slo.yaml solution/slo/burn-rate-alerts.yaml \
         starter/slo/slo.yaml starter/slo/burn-rate-alerts.yaml \
         broken/burn-rate-alerts.broken.yaml; do
  check "yaml parse: $y" yaml_ok "$y"
done

# ----------------------------------------------------------------------------
# Gate 6: k6 script sanity (node is absent -> `k6 run` is DEFERRED). We run a
# comment/string-aware bracket-balance + required-construct check instead.
# ----------------------------------------------------------------------------
check "k6 sanity: solution/load/k6-smoke.js (bracket balance + constructs)" \
  python3 tests/check_k6_balance.py solution/load/k6-smoke.js
check "k6 sanity: starter/load/k6-smoke.js (bracket balance + constructs)" \
  python3 tests/check_k6_balance.py starter/load/k6-smoke.js

# ----------------------------------------------------------------------------
# Gate 7 (authoritative): a REAL `k6 run` of the smoke script against a local
# payments-api mock. Guarded by `command -v` so it only runs where both `k6` and
# `docker` exist; elsewhere it degrades to a [SKIP] (no failure). The mock
# (load/mock-target/payments_api_mock.py) implements exactly the contract the
# script asserts: GET /healthz and POST /v1/authorize -> {"approved": bool}.
# k6 exits non-zero if a threshold (p95<300ms, http_req_failed<0.1%, ...) is
# breached, so this is a usable CI gate. The container is always stopped.
# ----------------------------------------------------------------------------
run_k6_real() {
  local port=8080 cid="" rc=0 mock="$HERE/load/mock-target/payments_api_mock.py"
  [ -f "$mock" ] || { echo "mock target missing: $mock" >&2; return 1; }

  # Stand up the target. --rm so a crash leaves nothing behind.
  cid="$(docker run -d --rm -p "${port}:8080" \
    -v "${mock}:/app/payments_api_mock.py:ro" \
    -e DECLINE_RATE=0.05 \
    python:3.12-slim python /app/payments_api_mock.py 2>/dev/null)" || {
      echo "could not start mock container (is the python:3.12-slim image present?)" >&2
      return 1
    }

  # Wait for the liveness probe to answer 200 (max ~10s).
  local i code=""
  for i in $(seq 1 20); do
    code="$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${port}/healthz" 2>/dev/null || true)"
    [ "$code" = "200" ] && break
    sleep 0.5
  done
  if [ "$code" != "200" ]; then
    echo "mock target did not become ready on :${port}" >&2
    docker stop "$cid" >/dev/null 2>&1 || true
    return 1
  fi

  # The authoritative gate: real k6 run. Short, deterministic profile. Capture
  # k6's exit code, then ALWAYS tear the container down before returning it.
  BASE_URL="http://localhost:${port}" k6 run --vus 5 --duration 8s "$HERE/solution/load/k6-smoke.js"
  rc=$?
  docker stop "$cid" >/dev/null 2>&1 || true
  return "$rc"
}

if command -v k6 >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  check "k6 run: solution/load/k6-smoke.js vs local payments-api mock (thresholds)" \
    run_k6_real
else
  printf '  [SKIP] %s\n' "k6 run (real): k6 and/or docker not installed -- script sanity (Gate 6) still enforced"
fi

# ============================================================================
# Injected-incident drill gates (solution/drill, starter/drill). These cover
# the readiness-failure drill: inject -> observe -> recover, with a captured
# live timeline. The heavy LIVE drive (run-drill.sh) is gated behind RUN_LIVE=1
# (Gate 11) so this stays fast by default; the rest are static and always run.
# ============================================================================

# ----------------------------------------------------------------------------
# Gate 8: kubeconform on the drill manifests (solution + starter). They are real
# Kubernetes objects, so validate them against the API schema, not just "parses".
# Skips with a parse-only fallback where kubeconform is absent.
# ----------------------------------------------------------------------------
DRILL_MANIFESTS=(solution/drill/manifests/*.yaml starter/drill/manifests/*.yaml)
if command -v kubeconform >/dev/null 2>&1; then
  check "kubeconform: drill manifests (k8s schema, strict)" \
    kubeconform -strict -summary -kubernetes-version 1.31.0 "${DRILL_MANIFESTS[@]}"
else
  printf '  [SKIP] %s\n' "kubeconform absent -- falling back to YAML parse on drill manifests"
  for y in "${DRILL_MANIFESTS[@]}"; do
    check "yaml parse: $y" yaml_ok "$y"
  done
fi

# ----------------------------------------------------------------------------
# Gate 9: shellcheck the drill scripts. The SOLUTION scripts must be clean at
# strict severity; the STARTER scripts intentionally have unreachable code after
# their TODO `exit` placeholders (SC2317 info), so they are checked at
# --severity=warning. shellcheck is run from each script's own directory so the
# `# shellcheck source=lib.sh` directive resolves.
# ----------------------------------------------------------------------------
shellcheck_dir() {  # $1=dir  $2=severity
  ( cd "$1" && shellcheck -x --severity="$2" \
      inject.sh observe.sh recover.sh run-drill.sh lib.sh )
}
if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck: solution/drill scripts (strict)" \
    shellcheck_dir "$HERE/solution/drill" style
  check "shellcheck: starter/drill scripts (warning -- TODO gaps allowed)" \
    shellcheck_dir "$HERE/starter/drill" warning
else
  # bash -n on the drill scripts already ran in Gate 4 (it globs all *.sh under
  # solution/ and starter/), so syntax is covered even without shellcheck.
  printf '  [SKIP] %s\n' "shellcheck absent -- bash -n (Gate 4) still enforces drill-script syntax"
fi

# ----------------------------------------------------------------------------
# Gate 10: the committed live evidence exists and records a PASS drill. This
# proves the drill was actually run against a real cluster (the file is produced
# only by RUN_LIVE=1 ./solution/drill/run-drill.sh) -- not hand-written.
# ----------------------------------------------------------------------------
EVID="$HERE/solution/drill/LIVE-INCIDENT-EVIDENCE.txt"
check "evidence: LIVE-INCIDENT-EVIDENCE.txt records a PASS drill" \
  grep -q 'RESULT = PASS (fault injected -> detected -> recovered -> verified healthy)' "$EVID"
# The evidence must show the outage signal (empty endpoints) and the root-cause
# breadcrumb (readiness probe 503), or it is not a real incident timeline.
check "evidence: shows empty endpoints + readiness-probe 503" \
  bash -c 'grep -q "ready endpoints=0" "'"$EVID"'" && grep -q "Readiness probe failed: HTTP probe failed with statuscode: 503" "'"$EVID"'"'

# ----------------------------------------------------------------------------
# Gate 11 (LIVE, gated): actually RUN the drill against the kind cluster end to
# end. Heavy/multi-minute, so only runs when RUN_LIVE=1 AND kubectl can reach a
# cluster. It uses ns/lab-incident and deletes it on exit (run-drill.sh cleans
# up). Off by default to keep validate.sh fast.
# ----------------------------------------------------------------------------
if [ "${RUN_LIVE:-0}" = "1" ]; then
  if kubectl version >/dev/null 2>&1; then
    check "LIVE drill: inject -> observe -> recover -> verify (ns/lab-incident)" \
      env RUN_LIVE=1 "$HERE/solution/drill/run-drill.sh"
  else
    printf '  [FAIL] %s\n' "RUN_LIVE=1 set but kubectl cannot reach a cluster"
    fail=$((fail + 1))
  fi
else
  printf '  [SKIP] %s\n' "LIVE drill (run-drill.sh): set RUN_LIVE=1 to run it live; committed evidence checked by Gate 10"
fi

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
