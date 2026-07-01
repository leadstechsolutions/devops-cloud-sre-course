#!/usr/bin/env bash
# Validation gates for the capstone (integration) module.
# Run from the module root:  ./validate.sh
# Prints one line per check; exits non-zero if ANY gate fails.
#
# Gates:
#   1. docker-compose.demo.yaml is well-formed YAML (PyYAML safe_load_all)
#   2. prometheus/prometheus.demo.yml is well-formed YAML
#   3. reference checker: every labs/<module> path the capstone cites exists
#   4. shell syntax of validate.sh and tests/check_references.sh
#   5. docker compose config parses (default profile)
#   6. docker compose config parses (metrics profile)
#
# Gates 5 and 6 need the Docker CLI. If Docker is unavailable they are reported
# DEFERRED (not failed), with the exact command, so the lighter gates still gate.
set -uo pipefail

cd "$(dirname "$0")"

fail=0
pass=0
defer=0

check() {
  local label="$1"; shift
  if "$@" >/tmp/_cap_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_cap_check.out | head -25
    fail=$((fail + 1))
  fi
}

defer_note() {
  printf '  [DEFER] %s\n' "$1"
  defer=$((defer + 1))
}

echo "== validating capstone =="

# --- Gate 1+2: YAML well-formed ----------------------------------------------
check "yaml: docker-compose.demo.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('docker-compose.demo.yaml')))"
check "yaml: prometheus/prometheus.demo.yml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('prometheus/prometheus.demo.yml')))"

# --- Gate 3: referenced labs/ paths exist ------------------------------------
check "refs: every referenced labs/<module> path exists" \
  bash tests/check_references.sh

# --- Gate 4: shell syntax ----------------------------------------------------
check "shell: validate.sh syntax" bash -n validate.sh
check "shell: tests/check_references.sh syntax" bash -n tests/check_references.sh

# --- Gates needing Docker ----------------------------------------------------
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  check "docker: compose config (default profile)" \
    docker compose -f docker-compose.demo.yaml config
  check "docker: compose config (metrics profile)" \
    docker compose -f docker-compose.demo.yaml --profile metrics config
else
  defer_note "docker: compose config (default) — run: docker compose -f docker-compose.demo.yaml config"
  defer_note "docker: compose config (metrics) — run: docker compose -f docker-compose.demo.yaml --profile metrics config"
fi

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
