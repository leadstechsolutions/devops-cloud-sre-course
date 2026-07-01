#!/usr/bin/env bash
# Validation gates for the helm-charts module.
# Run from the module root:  ./validate.sh
# Prints one line per check; exits non-zero if ANY gate fails.
#
# Gates that run locally (no helm binary required):
#   1. Chart.yaml is well-formed YAML and declares apiVersion v2.
#   2. values.yaml and values-prod.yaml are well-formed YAML.
#   3. Offline prerender: every template under templates/ strips its Go-template
#      actions and the remaining static skeleton parses as YAML (tests/prerender.py).
#   4. Prerender unit tests pass (tests/test_prerender.py) — proves the gate has
#      teeth: it rejects a broken-indentation template.
#   5. The broken/ fixture is genuinely broken (prerender FAILS on it).
#   6. _helpers.tpl exists and defines the name/labels helpers the templates use.
#   7. validate.sh own shell syntax.
#
# Authoritative gates (run wherever the tool exists; DEFER otherwise):
#   helm lint solution/chart/webapp
#   helm template webapp solution/chart/webapp                                  (default)
#   helm template webapp solution/chart/webapp -f .../values-prod.yaml          (prod)
#   helm template ... | kubeconform -strict -summary                            (default + prod)
#   helm template ... | kubectl --context kind-course apply --dry-run=server -f -  (real API)
# Override the cluster context with KUBE_CONTEXT=... (default: kind-course).
set -uo pipefail

cd "$(dirname "$0")"

CHART=solution/chart/webapp

fail=0
pass=0
defer=0

check() {
  local label="$1"; shift
  if "$@" >/tmp/_hc_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_hc_check.out | head -20
    fail=$((fail + 1))
  fi
}

# Inverted check: the command is EXPECTED to fail (non-zero). Used for the
# broken fixture so a "fixed" fixture would itself fail the suite.
check_fails() {
  local label="$1"; shift
  if "$@" >/tmp/_hc_check.out 2>&1; then
    printf '  [FAIL] %s (command unexpectedly succeeded)\n' "$label"
    fail=$((fail + 1))
  else
    printf '  [PASS] %s (correctly rejected)\n' "$label"
    pass=$((pass + 1))
  fi
}

defer_note() {
  printf '  [DEFER] %s\n' "$1"
  defer=$((defer + 1))
}

echo "== validating helm-charts =="

# --- Gate 1: Chart.yaml -------------------------------------------------------
check "yaml: Chart.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('$CHART/Chart.yaml')))"
check "Chart.yaml declares apiVersion v2" \
  python3 -c "import yaml,sys; d=yaml.safe_load(open('$CHART/Chart.yaml')); sys.exit(0 if d.get('apiVersion')=='v2' else 1)"

# --- Gate 2: values files -----------------------------------------------------
check "yaml: values.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('$CHART/values.yaml')))"
check "yaml: values-prod.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('$CHART/values-prod.yaml')))"
check "yaml: starter values.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('starter/chart/webapp/values.yaml')))"

# --- Gate 3: offline prerender of all templates -------------------------------
check "prerender: all solution templates parse after stripping {{...}}" \
  python3 tests/prerender.py

# --- Gate 4: prerender unit tests ---------------------------------------------
check "python: prerender unit tests (unittest discover)" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# --- Gate 5: broken fixture must fail -----------------------------------------
check_fails "prerender: broken/deployment.yaml is rejected" \
  python3 tests/prerender.py broken/deployment.yaml

# --- Gate 6: helpers present --------------------------------------------------
check "helpers: _helpers.tpl defines webapp.fullname + webapp.labels" \
  bash -c 'grep -q "define \"webapp.fullname\"" '"$CHART"'/templates/_helpers.tpl && grep -q "define \"webapp.labels\"" '"$CHART"'/templates/_helpers.tpl'

# --- Gate 7: this script's shell syntax ---------------------------------------
check "shell: validate.sh syntax" bash -n validate.sh

# --- Authoritative gates (need helm / kubeconform / a cluster) ----------------
# These were previously DEFERRED because the tools were absent from the base
# image. They now RUN wherever the tool exists and degrade gracefully (DEFER)
# where it does not. Each piped gate enables `pipefail` so a failure on the LEFT
# of the pipe (e.g. helm template erroring) is NOT masked by a clean summary on
# the right.
KCONTEXT="${KUBE_CONTEXT:-kind-course}"

if command -v helm >/dev/null 2>&1; then
  check "helm: lint $CHART" helm lint "$CHART"
  check "helm: template default values" \
    bash -c "set -o pipefail; helm template webapp '$CHART' >/dev/null"
  check "helm: template prod values" \
    bash -c "set -o pipefail; helm template webapp '$CHART' -f '$CHART/values-prod.yaml' >/dev/null"

  if command -v kubeconform >/dev/null 2>&1; then
    check "kubeconform: default render is schema-valid (-strict)" \
      bash -c "set -o pipefail; helm template webapp '$CHART' | kubeconform -strict -summary"
    check "kubeconform: prod render is schema-valid (-strict)" \
      bash -c "set -o pipefail; helm template webapp '$CHART' -f '$CHART/values-prod.yaml' | kubeconform -strict -summary"
  else
    defer_note "kubeconform (default) — run: helm template webapp $CHART | kubeconform -strict -summary"
    defer_note "kubeconform (prod)    — run: helm template webapp $CHART -f $CHART/values-prod.yaml | kubeconform -strict -summary"
  fi

  # Real API validation: server-side dry-run apply against a live cluster. Only
  # runs when kubectl exists AND the context can reach an apiserver; otherwise
  # it degrades to a DEFER note instead of failing on machines with no cluster.
  if command -v kubectl >/dev/null 2>&1 \
     && kubectl --context "$KCONTEXT" version >/dev/null 2>&1; then
    check "kubectl: default render passes server-side dry-run (real API)" \
      bash -c "set -o pipefail; helm template webapp '$CHART' | kubectl --context '$KCONTEXT' apply --dry-run=server -f - >/dev/null"
    check "kubectl: prod render passes server-side dry-run (real API)" \
      bash -c "set -o pipefail; helm template webapp '$CHART' -f '$CHART/values-prod.yaml' | kubectl --context '$KCONTEXT' apply --dry-run=server -f - >/dev/null"
  else
    defer_note "kubectl server-side dry-run — run (with a cluster): helm template webapp $CHART | kubectl --context $KCONTEXT apply --dry-run=server -f -"
  fi
else
  defer_note "helm lint   — run: helm lint $CHART"
  defer_note "helm template (default) — run: helm template webapp $CHART"
  defer_note "helm template (prod)    — run: helm template webapp $CHART -f $CHART/values-prod.yaml"
  defer_note "kubeconform — run: helm template webapp $CHART | kubeconform -strict -summary"
  defer_note "kubectl server-side dry-run — run: helm template webapp $CHART | kubectl apply --dry-run=server -f -"
fi

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
