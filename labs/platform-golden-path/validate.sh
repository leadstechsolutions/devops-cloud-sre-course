#!/usr/bin/env bash
# Helper functions (parse_yaml, gen_service, smoke_docker, ...) are invoked
# indirectly via the `check` wrapper, which shellcheck cannot trace — silence
# the resulting false-positive SC2317 "unreachable command" notes file-wide.
# shellcheck disable=SC2317
#
# Validation runner for the platform-golden-path module. Fast by default; the
# heavy live drive (kind deploy + helm test) lives in drill.sh behind RUN_LIVE=1.
#
# Gates (non-zero exit if ANY fails):
#   1. scaffold.sh is shellcheck-clean (generator + starter).
#   2. scaffold.sh RUNS: generates a fresh service into a temp dir, leaves NO
#      __SERVICE_NAME__ placeholder, and rejects an invalid name + a name clash.
#   3. The committed solution/example-service matches a fresh generation.
#   4. App compiles (py_compile) and unit tests pass — template AND example.
#   5. hadolint the Dockerfile (template + example).
#   6. actionlint the workflow (template + example).
#   7. helm lint + helm template + kubeconform on the GENERATED chart (default
#      and autoscaling/netpol-enabled renders).
#   8. kubeconform the plain k8s manifests (example).
#   9. yamllint workflows / values / k8s manifests (relaxed ruleset).
#  10. Optional (guarded): docker build the GENERATED service + run it + curl
#      /healthz == 200 — the true end-to-end "the path works" gate.
#
# Tool gates are guarded with `command -v`: they run where the tool exists and
# SKIP (not fail) where it does not. Trivy + ruff are DEFERRED (not installed
# here) and documented in the README + wired into ci.yml.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE" || exit 1

SOL="solution"
TMPL="$SOL/template"
EX="$SOL/example-service"
SCAFFOLD="$SOL/scaffold.sh"
GEN_ROOT=""   # temp workspace, cleaned on exit

cleanup() {
  [[ -n "$GEN_ROOT" && -d "$GEN_ROOT" ]] && rm -rf "$GEN_ROOT"
  # py_compile + unittest leave bytecode in the committed solution dirs; remove
  # it so the working tree stays clean after a validate run.
  find "$SOL" -name __pycache__ -type d -prune -exec rm -rf {} + 2>/dev/null || true
}
trap cleanup EXIT

fail=0
pass=0

check() {
  local label="$1"; shift
  if "$@" >/tmp/_pgp_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"; pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_pgp_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating platform-golden-path =="

# --- 1. shellcheck the generator(s) -----------------------------------------
if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck: solution/scaffold.sh" shellcheck "$SCAFFOLD"
  check "shellcheck: starter/scaffold.sh"  shellcheck starter/scaffold.sh
  check "shellcheck: drill.sh"             shellcheck drill.sh
else
  echo "  [SKIP] shellcheck (not installed)"
fi

# --- 2. scaffold.sh RUNS and behaves -----------------------------------------
GEN_ROOT="$(mktemp -d)"
gen_service() { "$SCAFFOLD" "$1" "$GEN_ROOT/$1" >/dev/null; }

check "scaffold generates a service (validate-svc)" gen_service validate-svc
check "generated service has NO placeholder" \
  bash -c '! grep -rIl __SERVICE_NAME__ "'"$GEN_ROOT"'/validate-svc"'
# Invalid name must be rejected (uppercase + underscore).
check "scaffold REJECTS invalid name 'Bad_Name' (expected)" \
  bash -c '! "'"$SCAFFOLD"'" Bad_Name "'"$GEN_ROOT"'/bad" >/dev/null 2>&1'
# Re-running into an existing dir must be refused.
check "scaffold REFUSES to overwrite existing dir (expected)" \
  bash -c '! "'"$SCAFFOLD"'" validate-svc "'"$GEN_ROOT"'/validate-svc" >/dev/null 2>&1'

# --- 3. committed example-service == fresh generation ------------------------
# Regenerate example-service into the temp dir and diff against the committed
# copy (ignoring __pycache__). Proves example-service is the genuine output and
# was not hand-edited out of sync with the template.
regen_example_matches() {
  "$SCAFFOLD" example-service "$GEN_ROOT/example-service" >/dev/null
  diff -ruN \
    --exclude='__pycache__' --exclude='*.pyc' --exclude='.pytest_cache' \
    "$EX" "$GEN_ROOT/example-service"
}
check "committed example-service matches fresh scaffold output" regen_example_matches

# --- 4. app compiles + unit tests (template AND example) ---------------------
check "py_compile: template/app"          python3 -m compileall -q "$TMPL/app"
check "py_compile: example-service/app"   python3 -m compileall -q "$EX/app"
unit() { ( cd "$1" && python3 -m unittest discover -s tests -p 'test_*.py' ); }
check "unit tests: template"        unit "$TMPL"
check "unit tests: example-service" unit "$EX"

# --- 5. hadolint -------------------------------------------------------------
if command -v hadolint >/dev/null 2>&1; then
  check "hadolint: template/Dockerfile"        hadolint "$TMPL/Dockerfile"
  check "hadolint: example-service/Dockerfile" hadolint "$EX/Dockerfile"
else
  echo "  [SKIP] hadolint (not installed)"
fi

# --- 6. actionlint -----------------------------------------------------------
if command -v actionlint >/dev/null 2>&1; then
  check "actionlint: template ci.yml" actionlint "$TMPL/.github/workflows/ci.yml"
  check "actionlint: example ci.yml"  actionlint "$EX/.github/workflows/ci.yml"
else
  echo "  [SKIP] actionlint (not installed)"
fi

# --- 7. helm lint + template + kubeconform on the GENERATED chart ------------
# The template chart's Chart.yaml name is the placeholder, so helm gates run on
# the GENERATED example-service chart (a valid chart), which is the real artifact.
if command -v helm >/dev/null 2>&1; then
  check "helm lint: example-service/chart" helm lint "$EX/chart"
  check "helm template (default) renders" \
    bash -c "set -o pipefail; helm template example-service '$EX/chart' >/dev/null"
  check "helm template (autoscaling+netpol) renders" \
    bash -c "set -o pipefail; helm template example-service '$EX/chart' --set autoscaling.enabled=true --set networkPolicy.enabled=true >/dev/null"
  if command -v kubeconform >/dev/null 2>&1; then
    check "kubeconform: default render (-strict)" \
      bash -c "set -o pipefail; helm template example-service '$EX/chart' | kubeconform -strict -summary"
    check "kubeconform: autoscaling+netpol render (-strict)" \
      bash -c "set -o pipefail; helm template example-service '$EX/chart' --set autoscaling.enabled=true --set networkPolicy.enabled=true | kubeconform -strict -summary"
  else
    echo "  [DEFERRED] kubeconform — helm template example-service $EX/chart | kubeconform -strict -summary"
  fi
else
  echo "  [DEFERRED] helm lint/template — run where helm is installed"
fi

# --- 8. kubeconform the plain k8s manifests ----------------------------------
if command -v kubeconform >/dev/null 2>&1; then
  check "kubeconform: example-service/k8s (-strict)" \
    kubeconform -strict -summary "$EX/k8s/"
else
  echo "  [DEFERRED] kubeconform k8s — kubeconform -strict $EX/k8s/"
fi

# --- 9. yamllint workflows / values / k8s (relaxed; templates excluded) ------
if command -v yamllint >/dev/null 2>&1; then
  ylint() { yamllint -c .yamllint.yml "$1"; }
  for f in \
    "$TMPL/.github/workflows/ci.yml" "$EX/.github/workflows/ci.yml" \
    "$TMPL/chart/values.yaml"        "$EX/chart/values.yaml" \
    "$TMPL/chart/Chart.yaml" \
    "$TMPL/k8s/deployment.yaml"      "$EX/k8s/deployment.yaml" \
    "$TMPL/k8s/service.yaml"         "$EX/k8s/service.yaml"; do
    check "yamllint: $f" ylint "$f"
  done
else
  echo "  [SKIP] yamllint (not installed)"
fi

# --- 10. Optional end-to-end: build the GENERATED service + curl /healthz ----
# The headline gate: prove the paved road produces a service that actually
# builds and serves traffic. Skipped (not failed) where docker is unavailable.
if command -v docker >/dev/null 2>&1; then
  smoke_path() {
    local img="pgp-validate:local"
    docker build -t "$img" "$GEN_ROOT/validate-svc" >/dev/null || return 1
    local cid rc=0
    cid="$(docker run -d -p 0:8080 "$img")" || { docker rmi "$img" >/dev/null 2>&1; return 1; }
    sleep 2
    docker exec "$cid" python -c \
      "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8080/healthz').status==200 else 1)" \
      || rc=1
    docker rm -f "$cid" >/dev/null 2>&1
    docker rmi "$img" >/dev/null 2>&1
    return "$rc"
  }
  check "END-TO-END: docker build generated svc + /healthz == 200" smoke_path
else
  echo "  [SKIP] end-to-end docker build + /healthz (docker not installed)"
fi

# --- DEFERRED gates (tool absent here; wired into ci.yml) --------------------
echo "  [DEFERRED] ruff check app tests                  (Python lint; pip install ruff==0.8.4)"
echo "  [DEFERRED] trivy image ... --severity HIGH,CRITICAL --exit-code 1  (image CVE scan in ci.yml)"
echo "  [DEFERRED] live kind deploy + helm test          (run: RUN_LIVE=1 ./drill.sh)"

echo "== $pass passed, $fail failed (plus DEFERRED — see README) =="
exit $(( fail > 0 ? 1 : 0 ))
