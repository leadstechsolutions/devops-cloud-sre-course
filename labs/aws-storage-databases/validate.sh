#!/usr/bin/env bash
# Validation gates for the aws-storage-databases module.
# Runs the same gates the README documents and exits non-zero if ANY gate fails.
# No `terraform apply` is ever run here — these gates are plan-free and cost $0.
# (The orchestrator runs the live apply -> destroy separately.)
set -uo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$MODULE_DIR" || exit 1

fail=0
pass=0

check() {
  # check "<label>" <command...>
  local label="$1"
  shift
  if "$@" >/tmp/_lab_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_lab_check.out | head -25
    fail=$((fail + 1))
  fi
}

# A gate that is expected to FAIL the wrapped command (negative test).
check_fails() {
  local label="$1"
  shift
  if "$@" >/tmp/_lab_check.out 2>&1; then
    printf '  [FAIL] %s (command unexpectedly succeeded)\n' "$label"
    fail=$((fail + 1))
  else
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  fi
}

# shellcheck disable=SC2317  # body invoked indirectly via the `check` helper.
tf_init_validate() {
  # Init without a backend, then validate, in the given directory.
  local dir="$1"
  terraform -chdir="$dir" init -backend=false -input=false -no-color >/dev/null &&
    terraform -chdir="$dir" validate -no-color
}

echo "== validating $(basename "$MODULE_DIR") =="

# --- Terraform formatting (solution + starter + broken) ---
check "terraform fmt -check -recursive (solution)" \
  terraform fmt -check -recursive solution
check "terraform fmt -check -recursive (starter)" \
  terraform fmt -check -recursive starter
check "terraform fmt -check -recursive (broken)" \
  terraform fmt -check -recursive broken

# --- init + validate ---
check "terraform validate (solution)" tf_init_validate solution
check "terraform validate (starter)" tf_init_validate starter
# The broken fixture is intentionally a SECURITY defect, not a syntax error, so
# it must still validate cleanly (the problem is found by checkov, below).
check "terraform validate (broken — syntax is valid by design)" \
  tf_init_validate broken

# --- Structural unit tests (stdlib only, no network) ---
check "python unittest (tests/)" \
  python3 -m unittest discover -s tests

# --- IaC security scan (checkov) ---
# Static security analysis. Runs only where checkov is installed; degrades
# gracefully (skips, does not fail) where it is not. Genuine findings are fixed
# in source (access logging, lifecycle); intentional teaching choices carry a
# narrow, documented `checkov:skip=` comment (SSE-S3 vs CMK, cross-region repl).
if command -v checkov >/dev/null 2>&1; then
  check "checkov (solution — clean)" \
    checkov -d solution --compact --quiet
  # The broken fixture MUST trip checkov (the troubleshooting exercise).
  check_fails "checkov (broken fixture fails — expected, public bucket)" \
    checkov -d broken --compact --quiet
else
  printf '  [SKIP] checkov (not installed)\n'
fi

echo "== $pass passed, $fail failed =="
exit $((fail > 0 ? 1 : 0))
