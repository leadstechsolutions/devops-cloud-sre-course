#!/usr/bin/env bash
# validate.sh — gates for the linux-shell-automation module.
# Prints one line per check; exits non-zero if ANY gate fails.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

fail=0
pass=0

check() {
  # check "<label>" <command...>
  local label="$1"; shift
  if "$@" >/tmp/_lab_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_lab_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating linux-shell-automation =="

# Gate 1: shell syntax on every .sh in solution/, starter/, broken/, tests/.
while IFS= read -r -d '' f; do
  check "bash -n ${f#./}" bash -n "$f"
done < <(find . -name '*.sh' -type f -print0 | sort -z)

# Gate 2: the solution scripts behave correctly under the functional test suite.
check "tests/run-tests.sh (functional)" bash tests/run-tests.sh

# Gate 3: shellcheck static analysis.
# Guarded by `command -v shellcheck` so the module still validates where the
# linter is not installed (it prints a SKIP line and the gate is not counted).
#
# The authoritative checks (solution/, validate.sh, tests/) must be lint-CLEAN.
# The broken/ fixture is REQUIRED to keep tripping SC2086 (its intentional
# word-splitting bug, "Bug 1"); if that warning ever disappears, the
# troubleshooting fixture has been silently fixed and the gate fails.
# The starter/ scripts are intentionally incomplete (TODO student gaps) and so
# legitimately trip SC2034 "appears unused" on not-yet-consumed variables; they
# are reported for information only and never fail this gate.
if command -v shellcheck >/dev/null 2>&1; then
  echo "-- shellcheck $(shellcheck --version | awk '/version:/{print $2}')"

  # 3a: every authoritative script is lint-clean.
  while IFS= read -r -d '' f; do
    check "shellcheck -x ${f#./} (clean)" shellcheck -x "$f"
  done < <(find ./solution -name '*.sh' -type f -print0 | sort -z)
  check "shellcheck -x validate.sh (clean)" shellcheck -x validate.sh
  check "shellcheck -x tests/run-tests.sh (clean)" shellcheck -x tests/run-tests.sh

  # 3b: the broken fixture must STILL flag SC2086 (Bug 1: unquoted $mount).
  # Capture the output first, then grep the string — piping `shellcheck | grep -q`
  # would give grep an early-exit that SIGPIPEs shellcheck and trips `pipefail`.
  broken_out="$(shellcheck -x broken/disk-check-broken.sh 2>&1 || true)"
  if [[ "$broken_out" == *SC2086* ]]; then
    printf '  [PASS] %s\n' "shellcheck broken/ still reports SC2086 (intentional Bug 1)"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "shellcheck broken/ no longer reports SC2086 — fixture was silently fixed"
    fail=$((fail + 1))
  fi

  # 3c: starter/ is incomplete by design — report findings, never fail.
  while IFS= read -r -d '' f; do
    if shellcheck -x "$f" >/dev/null 2>&1; then
      printf '  [INFO] shellcheck %s clean\n' "${f#./}"
    else
      codes="$(shellcheck -x "$f" 2>&1 | grep -oE 'SC[0-9]+' | sort -u | paste -sd, -)"
      printf '  [INFO] shellcheck %s: %s (expected — TODO student gaps)\n' "${f#./}" "$codes"
    fi
  done < <(find ./starter -name '*.sh' -type f -print0 | sort -z)
else
  printf '  [SKIP] shellcheck not installed — install it to run the lint gate\n'
fi

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
