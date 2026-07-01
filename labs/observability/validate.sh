#!/usr/bin/env bash
# Validation runner for the observability module.
# Gates run locally in this environment:
#   - every *.yml / *.yaml parses (PyYAML)
#   - the Grafana dashboard JSON parses (python3 -m json.tool) and is a valid model
#   - structural unit tests (dashboard panels/targets, RED recording rules, burn-rate
#     alert windows/thresholds, OpenSLO 99.9% objective)
#   - the semantic burn-rate linter ACCEPTS the solution and REJECTS the broken fixture
# Authoritative tool gates (run when the tool is on PATH; skipped gracefully if not):
#   - yamllint -c .yamllint on every rules/config YAML (module .yamllint config)
#   - promtool check config on prometheus.yml
#   - promtool check rules on every recording + alerting rules file (solution + starter)
#   - promtool test rules on tests/alerting_test.yaml (unit-tests the burn-rate alerts)
# Still DEFERRED (those tools are not installed here — documented in README):
#   - otelcol validate, oslo validate, grafana dashboard import lint
# Contract: one line per check, non-zero exit if ANY gate fails.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

fail=0
pass=0

check() {
  # check "<label>" <command...>
  local label="$1"; shift
  if "$@" >/tmp/_obs_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_obs_check.out | head -30
    fail=$((fail + 1))
  fi
}

parse_yaml() {
  python3 -c "import yaml,sys; list(yaml.safe_load_all(open(sys.argv[1])))" "$1"
}
parse_json() {
  python3 -m json.tool < "$1" >/dev/null
}

echo "== validating observability =="

# --- 1. YAML well-formedness for every rules/config file (solution + starter) ----
while IFS= read -r f; do
  check "yaml parses: $f" parse_yaml "$f"
done < <(find solution starter broken tests \( -name '*.yml' -o -name '*.yaml' \) | sort)

# --- 2. Grafana dashboard JSON parses (json.tool) --------------------------------
check "json parses: solution grafana dashboard" parse_json solution/grafana/dashboards/service-overview.json
check "json parses: starter grafana dashboard"  parse_json starter/grafana/dashboards/service-overview.json

# --- 3. Structural invariants (dashboard model, RED rules, burn-rate, OpenSLO) ----
check "structural unit tests (unittest)" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# --- 4. Semantic burn-rate linter ------------------------------------------------
check "burn-rate linter ACCEPTS solution/alerting.rules.yml" \
  python3 tests/check_rules.py solution/prometheus/rules/alerting.rules.yml

# The broken fixture MUST be rejected — invert the exit code (PASS = fault detected).
check "burn-rate linter REJECTS broken/alerting.rules.broken.yml (expected)" \
  bash -c '! python3 tests/check_rules.py broken/alerting.rules.broken.yml'

# The unfilled starter MUST also be rejected (proves the TODOs are real gaps).
check "burn-rate linter REJECTS unfilled starter (expected)" \
  bash -c '! python3 tests/check_rules.py starter/prometheus/rules/alerting.rules.yml'

# --- 5. yamllint on every rules/config YAML (authoritative; module .yamllint) ----
# Guarded by command -v so the module still validates where yamllint is absent.
if command -v yamllint >/dev/null 2>&1; then
  while IFS= read -r f; do
    check "yamllint: $f" yamllint -c .yamllint --strict "$f"
  done < <(find solution starter broken tests \( -name '*.yml' -o -name '*.yaml' \) | sort)
else
  echo "  [SKIP] yamllint not on PATH — install yamllint to run the YAML style gate"
fi

# --- 6. promtool: config + rules + unit tests (authoritative Prometheus gates) ----
if command -v promtool >/dev/null 2>&1; then
  # 6a. The server config must be valid (this also loads + checks both rule files).
  check "promtool check config: solution/prometheus/prometheus.yml" \
    promtool check config solution/prometheus/prometheus.yml
  check "promtool check config: starter/prometheus/prometheus.yml" \
    promtool check config starter/prometheus/prometheus.yml

  # 6b. Every recording + alerting rules file must pass `promtool check rules`.
  while IFS= read -r rf; do
    check "promtool check rules: $rf" promtool check rules "$rf"
  done < <(find solution starter broken \
              \( -path '*/rules/*.yml' -o -name 'alerting.rules*.yml' \) | sort)

  # 6c. Unit-test the burn-rate alerts end to end (fires on 5% errors, silent when healthy).
  check "promtool test rules: tests/alerting_test.yaml" \
    promtool test rules tests/alerting_test.yaml
else
  echo "  [SKIP] promtool not on PATH — install Prometheus to run check config/rules/test"
fi

# --- Still DEFERRED gates (those tools are absent in this environment) ------------
echo "  [DEFERRED] otelcol-contrib validate --config solution/otel/otel-collector-config.yaml"
echo "  [DEFERRED] oslo validate -f solution/slo/slo.yaml                      (OpenSLO CLI)"

echo "== $pass passed, $fail failed (plus 2 DEFERRED — see README) =="
exit $(( fail > 0 ? 1 : 0 ))
