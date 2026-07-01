#!/usr/bin/env bash
# Validation runner for the python-automation module.
# Gates (per 07-templates/00-artifact-standard.md, "Python automation" row):
#   1. python3 -m py_compile on every .py (syntax)
#   2. python3 -m unittest discover -s tests (stdlib unit tests, no AWS/boto3/network)
# Contract: one line per check; exits non-zero if ANY gate fails.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

fail=0
pass=0

check() {
  local label="$1"; shift
  if "$@" >/tmp/_pyauto_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_pyauto_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating python-automation =="

# Gate 1: every .py compiles (solution, tests, and starter-after-completion).
# The starter is intentionally incomplete on LOGIC but must still be syntactically
# valid, so we compile it too.
mapfile -t PY_FILES < <(find solution tests starter -name '*.py' | sort)
check "py_compile: all .py files (syntax)" python3 -m py_compile "${PY_FILES[@]}"

# Gate 2: stdlib unit tests against the reference solution. PYTHONPATH points at
# solution/ so `import tag_audit` etc. resolve. No pip, no boto3, no network.
check "unittest: solution passes all tests" \
  env PYTHONPATH="$HERE/solution" python3 -m unittest discover -s tests -p 'test_*.py'

# Gate 3 (sanity): the starter MUST FAIL the tests -- if it passes, the lab has no
# gaps left for the student. This inverts the exit code on purpose.
if env PYTHONPATH="$HERE/starter" python3 -m unittest discover -s tests -p 'test_*.py' \
     >/tmp/_pyauto_starter.out 2>&1; then
  printf '  [FAIL] %s\n' "starter must be incomplete (tests should FAIL but passed)"
  fail=$((fail + 1))
else
  printf '  [PASS] %s\n' "starter is incomplete (tests fail until TODOs are done)"
  pass=$((pass + 1))
fi

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
