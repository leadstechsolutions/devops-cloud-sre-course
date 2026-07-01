#!/usr/bin/env bash
# Validation runner for the security-automation module.
# Gates (per 07-templates/00-artifact-standard.md):
#   1. bash -n on every .sh (shell syntax)                       [Linux/shell row]
#   2. python3 -m py_compile on every .py (python syntax)        [Python row]
#   3. python3 -m unittest against solution/ (IAM auditor tests) [Python row]
#   4. starter/ MUST FAIL the same tests (proves it has gaps)    [starter/solution]
#   5. every policy JSON parses (json.tool)                      [Policy-as-code row]
#   6. behaviour: iam_policy_audit flags bad-policy.json (exit 1) and passes
#      good-policy.json (exit 0)                                 [app-under-test row]
#   7. behaviour: s3_public_check.sh flags a public policy/ACL, passes a private one
#   8. behaviour: secret_scan.sh finds the planted key in broken/, clean on solution/
#   9. OPA rego: `opa test` on the rego files (real tool); conftest test on the
#      good/bad bucket-policy fixtures (good passes, bad fails). Guarded by
#      `command -v` so it runs where the tool exists, degrades where it does not.
# Contract: one line per check; exits non-zero if ANY gate fails.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

fail=0
pass=0
defer=0

check() {
  # check "<label>" <command...>   -- gate must succeed (exit 0)
  local label="$1"; shift
  if "$@" >/tmp/_sec_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_sec_check.out | head -30
    fail=$((fail + 1))
  fi
}

check_exit() {
  # check_exit "<label>" <expected_code> <command...> -- gate must exit with code
  local label="$1"; local want="$2"; shift 2
  local got=0
  "$@" >/tmp/_sec_check.out 2>&1 || got=$?
  if [[ "$got" -eq "$want" ]]; then
    printf '  [PASS] %s (exit %s)\n' "$label" "$got"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s (wanted exit %s, got %s)\n' "$label" "$want" "$got"
    sed 's/^/         /' /tmp/_sec_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating security-automation =="

# --- Gate 1: shell syntax on every .sh (solution + starter) ----------------
while IFS= read -r sh; do
  check "bash -n: $sh" bash -n "$sh"
done < <(find solution starter -name '*.sh' | sort)

# --- Gate 2: python syntax on every .py ------------------------------------
mapfile -t PY_FILES < <(find solution starter tests -name '*.py' | sort)
check "py_compile: all .py files (syntax)" python3 -m py_compile "${PY_FILES[@]}"

# --- Gate 3: stdlib unit tests against the reference solution --------------
check "unittest: solution passes IAM auditor tests" \
  env PYTHONPATH="$HERE/solution" python3 -m unittest discover -s tests -p 'test_*.py'

# --- Gate 4: the starter MUST FAIL the same tests --------------------------
if env PYTHONPATH="$HERE/starter" python3 -m unittest discover -s tests -p 'test_*.py' \
     >/tmp/_sec_starter.out 2>&1; then
  printf '  [FAIL] %s\n' "starter must be incomplete (tests should FAIL but passed)"
  fail=$((fail + 1))
else
  printf '  [PASS] %s\n' "starter is incomplete (tests fail until TODOs are done)"
  pass=$((pass + 1))
fi

# --- Gate 5: every policy JSON is well-formed ------------------------------
while IFS= read -r j; do
  check "json.tool: $j" bash -c "python3 -m json.tool < '$j' >/dev/null"
done < <(find solution/policies broken -name '*.json' | sort)

# --- Gate 6: IAM auditor behaviour -----------------------------------------
check_exit "iam_policy_audit flags bad-policy.json" 1 \
  python3 solution/iam_policy_audit.py solution/policies/iam/bad-policy.json
check_exit "iam_policy_audit passes good-policy.json" 0 \
  python3 solution/iam_policy_audit.py solution/policies/iam/good-policy.json

# --- Gate 7: s3_public_check behaviour -------------------------------------
check_exit "s3_public_check flags public bucket policy" 1 \
  bash solution/s3_public_check.sh policy solution/policies/opa/fixtures/public-bucket-policy.json
check_exit "s3_public_check passes private bucket policy" 0 \
  bash solution/s3_public_check.sh policy solution/policies/opa/fixtures/private-bucket-policy.json
check_exit "s3_public_check flags public bucket ACL" 1 \
  bash solution/s3_public_check.sh acl solution/policies/opa/fixtures/public-bucket-acl.json

# --- Gate 8: secret_scan behaviour -----------------------------------------
check_exit "secret_scan finds planted key in broken/" 1 \
  bash solution/secret_scan.sh dir broken
check_exit "secret_scan is clean on solution/" 0 \
  bash solution/secret_scan.sh dir solution

# --- Gate 9: OPA rego -- real `opa test` + conftest on the fixtures --------
# Structural sanity is always cheap to run and catches a typo even where the
# tools are absent.
if grep -q '^package s3.deny_public' solution/policies/opa/s3_deny_public.rego \
   && grep -q '^test_' solution/policies/opa/s3_deny_public_test.rego; then
  printf '  [PASS] opa rego: package line + test_ rules present (structural)\n'
  pass=$((pass + 1))
else
  printf '  [FAIL] opa rego missing package or test rules\n'
  fail=$((fail + 1))
fi

# `opa test` over the rego files ONLY. We pass the two .rego paths explicitly
# instead of the directory: pointing `opa test` at the whole opa/ dir makes OPA
# load the JSON conftest fixtures as `data` documents, and the two bucket-policy
# fixtures share top-level keys (Version/Statement) -> "merge error". The
# fixtures are conftest *inputs*, not OPA data, so we keep them out of the load.
if command -v opa >/dev/null 2>&1; then
  check "opa test: s3_deny_public rego (5/5 tests pass)" \
    opa test solution/policies/opa/s3_deny_public.rego \
             solution/policies/opa/s3_deny_public_test.rego
else
  printf '  [DEFER] opa test: opa not installed; run `opa test solution/policies/opa/*.rego`\n'
  defer=$((defer + 1))
fi

# conftest enforces the same rego against real bucket-policy JSON. The policy
# lives in package s3.deny_public, so conftest needs --namespace (its default is
# `main`). Good fixture => 0 failures (exit 0); bad fixture => >=1 failure (exit 1).
if command -v conftest >/dev/null 2>&1; then
  check_exit "conftest: public bucket policy is DENIED (bad fails)" 1 \
    conftest test --policy solution/policies/opa --namespace s3.deny_public \
      solution/policies/opa/fixtures/public-bucket-policy.json
  check_exit "conftest: private bucket policy is ALLOWED (good passes)" 0 \
    conftest test --policy solution/policies/opa --namespace s3.deny_public \
      solution/policies/opa/fixtures/private-bucket-policy.json
else
  printf '  [DEFER] conftest: not installed; run `conftest test --policy solution/policies/opa --namespace s3.deny_public <fixture>`\n'
  defer=$((defer + 1))
fi

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
