#!/usr/bin/env bash
# validate.sh — gates for the aws-cli-fundamentals module.
# Prints one line per check; exits non-zero if ANY gate fails.
#
# These scripts are READ-ONLY and call the live AWS API, but this gate runs with
# NO AWS credentials: it validates statically (syntax + lint) and functionally
# against an offline `aws` stub. The orchestrator runs them live (read-only,
# $0 cost) against the sandbox afterward.
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

fail=0
pass=0

check() {
  # check "<label>" <command...>
  local label="$1"; shift
  if "$@" >/tmp/_awscli_lab_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_awscli_lab_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating aws-cli-fundamentals =="

# Gate 1: shell syntax on every .sh in solution/, starter/, broken/, tests/.
while IFS= read -r -d '' f; do
  check "bash -n ${f#./}" bash -n "$f"
done < <(find . -name '*.sh' -type f -print0 | sort -z)

# Gate 2: offline functional suite (uses an `aws` stub; touches no real account).
check "tests/run-tests.sh (offline functional)" bash tests/run-tests.sh

# Gate 3: shellcheck static analysis (-x to follow sourced lib/common.sh).
# Guarded by `command -v shellcheck` so the module still validates where the
# linter is not installed. solution/, validate.sh, tests/, AND the broken/ fixture
# must all be lint-CLEAN (the broken fixture's fault is BEHAVIOURAL — a swallowed
# error — which shellcheck cannot see, so it must still pass the linter). The
# starter/ scripts are intentionally incomplete and reported for info only.
if command -v shellcheck >/dev/null 2>&1; then
  echo "-- shellcheck $(shellcheck --version | awk '/version:/{print $2}')"

  while IFS= read -r -d '' f; do
    check "shellcheck -x ${f#./} (clean)" shellcheck -x "$f"
  done < <(find ./solution -name '*.sh' -type f -print0 | sort -z)
  check "shellcheck -x broken/whoami-broken.sh (clean — bug is behavioural)" \
    shellcheck -x broken/whoami-broken.sh
  check "shellcheck -x tests/run-tests.sh (clean)" shellcheck -x tests/run-tests.sh
  check "shellcheck -x validate.sh (clean)" shellcheck -x validate.sh

  # starter/ is incomplete by design — report findings, never fail.
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

# Gate 4: documentation artifact exists (the SSO walkthrough).
check "sso-config.md present" test -f solution/sso-config.md

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
