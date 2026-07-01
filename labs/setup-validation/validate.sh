#!/usr/bin/env bash
# validate.sh — gates for the setup-validation module.
# Prints one line per check; exits non-zero if ANY gate fails.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

fail=0
pass=0

check() {
  # check "<label>" <command...>
  local label="$1"; shift
  if "$@" >/tmp/_setup_lab_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_setup_lab_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating setup-validation =="

# ---------------------------------------------------------------------------
# Gate 1: shell syntax on every .sh in the module.
# ---------------------------------------------------------------------------
while IFS= read -r -d '' f; do
  check "bash -n ${f#./}" bash -n "$f"
done < <(find . -name '*.sh' -type f -print0 | sort -z)

# ---------------------------------------------------------------------------
# Gate 2: functional test suite (unit + integration + broken-fixture regression).
# ---------------------------------------------------------------------------
check "tests/run-tests.sh (functional)" bash tests/run-tests.sh

# ---------------------------------------------------------------------------
# Gate 3: the real checker runs against THIS machine's toolchain. In this
# course environment git/python3/docker/terraform/aws/kubectl are installed and
# meet the minimums, so setup-check.sh must exit 0 (READY). If a required tool
# is genuinely missing on the runner this gate fails — which is correct: the
# point of the script is to fail loudly when the toolchain is wrong.
# ---------------------------------------------------------------------------
check "solution/setup-check.sh exits 0 (toolchain READY)" bash solution/setup-check.sh

# ---------------------------------------------------------------------------
# Gate 4: print-report.sh renders and agrees with setup-check.sh (exit 0).
# ---------------------------------------------------------------------------
check "solution/print-report.sh exits 0" bash solution/print-report.sh

# ---------------------------------------------------------------------------
# Gate 5: shellcheck static analysis (guarded so the module still validates
# where the linter is absent — it prints SKIP and is not counted).
#
#   5a. Authoritative scripts (solution/, validate.sh, tests/) must be CLEAN.
#   5b. The broken/ fixture must STILL pass shellcheck (its bug is behavioural,
#       not a lint finding) — if shellcheck ever flags it, note it but do not
#       fail; the behavioural proof lives in the test suite (Gate 2).
#   5c. starter/ has an intentional unfinished version_ge (returns 1, the TODO):
#       reported for information only, never fails this gate.
# ---------------------------------------------------------------------------
if command -v shellcheck >/dev/null 2>&1; then
  echo "-- shellcheck $(shellcheck --version | awk '/version:/{print $2}')"

  # 5a: every authoritative script is lint-clean (-x follows `source`).
  while IFS= read -r -d '' f; do
    check "shellcheck -x ${f#./} (clean)" shellcheck -x "$f"
  done < <(find ./solution -name '*.sh' -type f -print0 | sort -z)
  check "shellcheck -x validate.sh (clean)" shellcheck -x validate.sh
  check "shellcheck -x tests/run-tests.sh (clean)" shellcheck -x tests/run-tests.sh
  check "shellcheck -x broken/setup-check-broken.sh (clean)" \
    shellcheck -x broken/setup-check-broken.sh

  # 5c: starter/ is incomplete by design — report findings, never fail.
  while IFS= read -r -d '' f; do
    if shellcheck -x "$f" >/dev/null 2>&1; then
      printf '  [INFO] shellcheck %s clean\n' "${f#./}"
    else
      codes="$(shellcheck -x "$f" 2>&1 | grep -oE 'SC[0-9]+' | sort -u | paste -sd, -)"
      printf '  [INFO] shellcheck %s: %s (expected — TODO student gap)\n' "${f#./}" "$codes"
    fi
  done < <(find ./starter -name '*.sh' -type f -print0 | sort -z)
else
  printf '  [SKIP] shellcheck not installed — install it to run the lint gate\n'
fi

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
