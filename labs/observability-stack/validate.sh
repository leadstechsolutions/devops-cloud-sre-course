#!/usr/bin/env bash
# Validation gates for the observability-stack module.
# Run from the module root:  ./validate.sh
# Prints one line per check; exits non-zero if ANY gate FAILS (DEFERRED is OK).
#
# This validator is FAST by design (no cluster, no image build). The heavy live
# end-to-end drive lives in run-demo.sh (RUN_LIVE=1) and its captured output is
# committed as LIVE-OBS-EVIDENCE.txt.
#
# Gates:
#   1. py_compile the sample-api app (solution + starter).
#   2. App unit tests (registry + exposition format + route accounting).
#   3. Every rules/config/manifest YAML is well-formed (PyYAML, multi-doc aware).
#   4. yamllint -c .yamllint --strict on every YAML (where yamllint exists).
#   5. promtool check config (solution + starter prometheus.yml).
#   6. promtool check rules on every recording + alerting rules file.
#   7. promtool TEST rules -- the burn-rate alert FIRES on synthetic 5% errors
#      and stays SILENT when healthy. This is the deterministic alert proof.
#   8. The STARTER is provably incomplete: its alerting file defines NO alert
#      (so the burn-rate test could not pass against it) -- proves the TODO is real.
#   9. Grafana dashboard JSON parses (python3 -m json.tool), solution + starter.
#  10. The generated ConfigMaps are in sync with their source files (no drift):
#      re-run the generator and diff. Also assert the embedded prometheus.yml +
#      rule files parse as YAML.
#  11. kubeconform -strict schema validation of every manifest (where it exists).
#  12. shellcheck + bash -n on the shell scripts (where shellcheck exists).
#  13. hadolint on the Dockerfile (where hadolint exists).
#  14. LIVE deploy is DEFERRED here (documented) -- run via RUN_LIVE=1 ./run-demo.sh.
# shellcheck disable=SC2317  # helpers below are invoked indirectly via `check`
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE" || exit 2

fail=0
pass=0
defer=0

check() {  # check "label" cmd args...
  local label="$1"; shift
  if "$@" >/tmp/_obsstack_check.out 2>&1; then
    printf '  [PASS]  %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL]  %s\n' "$label"
    sed 's/^/          /' /tmp/_obsstack_check.out | head -30
    fail=$((fail + 1))
  fi
}

defer_note() {  # defer_note "label" "command to run where the tool/cluster exists"
  printf '  [DEFER] %s\n' "$1"
  printf '          run: %s\n' "$2"
  defer=$((defer + 1))
}

parse_yaml() { python3 -c "import yaml,sys; list(yaml.safe_load_all(open(sys.argv[1])))" "$1"; }
parse_json() { python3 -m json.tool < "$1" >/dev/null; }

echo "== validating observability-stack =="

# --- Gate 1: py_compile the app ----------------------------------------------
check "py_compile: solution/app/app.py" python3 -m py_compile solution/app/app.py
check "py_compile: starter/app/app.py"  python3 -m py_compile starter/app/app.py
check "py_compile: scripts/*.py" \
  python3 -m py_compile scripts/gen-configmap.py scripts/loadgen.py

# --- Gate 2: app unit tests --------------------------------------------------
check "tests: app registry + exposition format (unittest)" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# --- Gate 3: YAML well-formed (multi-doc aware) ------------------------------
while IFS= read -r f; do
  check "yaml parses: $f" parse_yaml "$f"
done < <(find solution starter tests \( -name '*.yml' -o -name '*.yaml' \) | sort)

# --- Gate 4: yamllint --------------------------------------------------------
if command -v yamllint >/dev/null 2>&1; then
  while IFS= read -r f; do
    check "yamllint: $f" yamllint -c .yamllint --strict "$f"
  done < <(find solution starter tests \( -name '*.yml' -o -name '*.yaml' \) | sort)
else
  defer_note "yamllint: style gate on every YAML" "yamllint -c .yamllint --strict <file>"
fi

# --- Gates 5-7: promtool config / rules / TEST -------------------------------
if command -v promtool >/dev/null 2>&1; then
  check "promtool check config: solution/prometheus/prometheus.yml" \
    bash -c 'cd solution/prometheus && promtool check config prometheus.yml'
  check "promtool check config: starter/prometheus/prometheus.yml" \
    bash -c 'cd starter/prometheus && promtool check config prometheus.yml'

  while IFS= read -r rf; do
    check "promtool check rules: $rf" promtool check rules "$rf"
  done < <(find solution starter -path '*/rules/*.yml' | sort)

  # The headline gate: the burn-rate alert fires on synthetic data.
  check "promtool TEST rules: burn-rate alert fires on 5% errors / silent when healthy" \
    promtool test rules tests/burn_rate_test.yml
else
  defer_note "promtool check config/rules + test rules" \
    "promtool check config solution/prometheus/prometheus.yml && promtool test rules tests/burn_rate_test.yml"
fi

# --- Gate 8: starter is provably incomplete ----------------------------------
# The starter alerting file must define NO alert (the burn-rate TODO is unfilled),
# so promtool would report zero rules / the test could not pass against it.
starter_has_no_alert() {
  ! grep -qE '^\s*-?\s*alert:' starter/prometheus/rules/alerting.rules.yml
}
check "starter incomplete: no burn-rate alert defined yet (TODO is real)" \
  starter_has_no_alert

# --- Gate 9: dashboard JSON --------------------------------------------------
check "json parses: solution grafana dashboard" parse_json grafana/sample-api-red.json
check "json parses: starter grafana dashboard"  parse_json starter/grafana/sample-api-red.json

# --- Gate 10: ConfigMap sync (no drift) + embedded parse ---------------------
cm_in_sync() {  # cm_in_sync <variant>
  python3 scripts/gen-configmap.py --variant "$1" --check \
    | diff - "$1/k8s/30-prometheus-config.yaml" >/dev/null
}
check "configmap in sync with source: solution" cm_in_sync solution
check "configmap in sync with source: starter"  cm_in_sync starter
# The embedded prometheus.yml + rule files inside the ConfigMap must themselves parse.
cm_embedded_parses() {  # cm_embedded_parses <variant>
  python3 - "$1/k8s/30-prometheus-config.yaml" <<'PY'
import sys, yaml
cm = yaml.safe_load(open(sys.argv[1]))
for k, v in cm["data"].items():
    yaml.safe_load(v)  # raises on bad YAML
PY
}
check "configmap embeds valid YAML: solution" cm_embedded_parses solution
check "configmap embeds valid YAML: starter"  cm_embedded_parses starter

# --- Gate 11: kubeconform schema validation ----------------------------------
if command -v kubeconform >/dev/null 2>&1; then
  check "kubeconform -strict: solution/k8s/*.yaml" \
    kubeconform -strict -summary solution/k8s/00-namespace.yaml solution/k8s/10-sample-api.yaml \
      solution/k8s/20-prometheus-rbac.yaml solution/k8s/30-prometheus-config.yaml solution/k8s/40-prometheus.yaml
  check "kubeconform -strict: starter/k8s/*.yaml" \
    kubeconform -strict -summary starter/k8s/00-namespace.yaml starter/k8s/10-sample-api.yaml \
      starter/k8s/20-prometheus-rbac.yaml starter/k8s/30-prometheus-config.yaml starter/k8s/40-prometheus.yaml
else
  defer_note "kubeconform -strict on manifests" "kubeconform -strict -summary solution/k8s/*.yaml"
fi

# --- Gate 12: shell lint -----------------------------------------------------
check "shell syntax: validate.sh" bash -n validate.sh
check "shell syntax: run-demo.sh" bash -n run-demo.sh
if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck: validate.sh" shellcheck validate.sh
  check "shellcheck: run-demo.sh" shellcheck run-demo.sh
else
  defer_note "shellcheck: validate.sh, run-demo.sh" "shellcheck validate.sh run-demo.sh"
fi

# --- Gate 13: Dockerfile lint ------------------------------------------------
if command -v hadolint >/dev/null 2>&1; then
  check "hadolint: solution/app/Dockerfile" hadolint solution/app/Dockerfile
else
  defer_note "hadolint: solution/app/Dockerfile" "hadolint solution/app/Dockerfile"
fi

# --- Gate 14: LIVE deploy (heavy; gated) -------------------------------------
defer_note "live deploy + PromQL query on kind (multi-minute build/deploy)" \
  "RUN_LIVE=1 ./run-demo.sh   # captures LIVE-OBS-EVIDENCE.txt"

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
