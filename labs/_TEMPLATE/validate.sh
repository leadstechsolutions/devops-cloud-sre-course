#!/usr/bin/env bash
# Template validation runner for a labs/ module.
# Copy into each module and replace the checks with the module's real gates.
# Contract: prints one line per check, exits non-zero if ANY gate fails.
set -uo pipefail

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
    sed 's/^/         /' /tmp/_lab_check.out | head -20
    fail=$((fail + 1))
  fi
}

echo "== validating $(basename "$(pwd)") =="

# Example gates — replace per module:
# check "shell syntax: solution/deploy.sh" bash -n solution/deploy.sh
# check "terraform validate"              bash -c 'cd solution && terraform init -backend=false >/dev/null && terraform validate'
# check "python compiles"                  python3 -m py_compile solution/app.py
# check "yaml parses"                      python3 -c "import yaml,glob,sys; [list(yaml.safe_load_all(open(f))) for f in glob.glob('solution/**/*.yaml',recursive=True)]"

echo "== $pass passed, $fail failed =="
exit $(( fail > 0 ? 1 : 0 ))
