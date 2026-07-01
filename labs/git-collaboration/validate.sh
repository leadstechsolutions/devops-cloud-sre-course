#!/usr/bin/env bash
# Validation runner for the git-collaboration module.
# Prints one line per gate; exits non-zero if ANY gate fails.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

fail=0
pass=0

check() {
  local label="$1"; shift
  if "$@" >/tmp/_gitcollab_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_gitcollab_check.out | head -20
    fail=$((fail + 1))
  fi
}

echo "== validating git-collaboration =="

# --- Gate 1: shell syntax on every .sh and hook (solution + starter) -------
while IFS= read -r -d '' f; do
  check "bash -n ${f#./}" bash -n "$f"
done < <(find solution starter tests -type f \( -name '*.sh' -o -path '*/hooks/*' \) -print0)

# --- Gate 2: behaviour tests (hooks block secrets/big files; scenario) -----
check "tests/test_hooks.sh (hook + scenario behaviour)" bash tests/test_hooks.sh

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
