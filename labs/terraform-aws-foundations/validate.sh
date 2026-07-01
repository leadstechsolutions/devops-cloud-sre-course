#!/usr/bin/env bash
# Validation gates for the terraform-aws-foundations module.
# Runs the same gates the README documents and exits non-zero if ANY gate fails.
# No `terraform apply` is ever run — these gates are plan-free and cost $0.
set -uo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$MODULE_DIR"

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

tf_init_validate() {
  # Init without a backend, then validate, in the given directory.
  local dir="$1"
  terraform -chdir="$dir" init -backend=false -input=false -no-color >/dev/null &&
    terraform -chdir="$dir" validate -no-color
}

echo "== validating $(basename "$MODULE_DIR") =="

# --- Terraform formatting (whole module, recursive) ---
check "terraform fmt -check -recursive (solution)" \
  terraform fmt -check -recursive solution

# --- Solution root module: init + validate ---
check "terraform validate (solution root)" \
  tf_init_validate solution

# --- VPC child module standalone: init + validate ---
check "terraform validate (solution/modules/vpc)" \
  tf_init_validate solution/modules/vpc

# --- Week 14 lecture example: secure S3 (init + validate) ---
# Self-contained root config matching the Week 14 secure-S3 lecture workflow.
check "terraform validate (solution/examples/secure-s3)" \
  tf_init_validate solution/examples/secure-s3

# --- Structural unit tests (stdlib only, no network) ---
check "python unittest (tests/)" \
  python3 -m unittest discover -s tests

# --- Broken fixture must FAIL validate (troubleshooting exercise) ---
check_fails "broken/ fixture fails terraform validate (expected)" \
  tf_init_validate broken

# --- IaC security scan (checkov) ---
# Static security analysis of the Terraform. Runs only where checkov is
# installed; degrades gracefully (skips, does not fail) where it is not.
# Genuine findings are fixed in the source (e.g. VPC flow logs, encrypted
# log group); intentional teaching choices carry a narrow, documented
# `checkov:skip=` comment (the public subnet's map_public_ip_on_launch).
# --compact keeps output terse; non-zero exit on any unsuppressed finding.
if command -v checkov >/dev/null 2>&1; then
  check "checkov (solution)" \
    checkov -d solution --compact --quiet
  check "checkov (solution/modules/vpc)" \
    checkov -d solution/modules/vpc --compact --quiet
  check "checkov (solution/examples/secure-s3)" \
    checkov -d solution/examples/secure-s3 --compact --quiet --framework terraform
  # Negative gate: the STARTER secure-s3 has the security controls TODO'd out,
  # so checkov MUST report failures on it. If it passes, the starter is no
  # longer a meaningful lab gap.
  check_fails "starter/examples/secure-s3 checkov fails (controls TODO, expected)" \
    checkov -d starter/examples/secure-s3 --compact --quiet --framework terraform
else
  printf '  [SKIP] checkov (not installed)\n'
fi

echo "== $pass passed, $fail failed =="
exit $((fail > 0 ? 1 : 0))
