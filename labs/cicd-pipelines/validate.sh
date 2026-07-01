#!/usr/bin/env bash
# Helper functions below (parse_yaml, smoke_docker, ylint, ...) are invoked
# indirectly via the `check` wrapper, which shellcheck cannot trace — silence
# the resulting false-positive SC2317 "unreachable command" notes file-wide.
# shellcheck disable=SC2317
#
# Validation runner for the cicd-pipelines module.
#
# Gates (one line each; non-zero exit if ANY fails):
#   1. Every workflow YAML parses (PyYAML).
#   2. Each job's `needs` resolves to a real job and the graph is acyclic
#      (check_job_graph.py) — and the broken fixture is correctly REJECTED.
#   3. Workflow unit tests pass (security invariants + gate behaviour).
#   4. The Flask app compiles (py_compile) and its pytest unit tests pass.
#   5. actionlint validates every GitHub Actions workflow (and rejects the
#      broken fixture).
#   6. yamllint validates the GitLab CI files and the workflows under a relaxed,
#      CI-idiomatic ruleset.
#   7. Optional: a real docker build + /health smoke test of the image.
#
# actionlint, yamllint, docker, and pytest gates are guarded by `command -v` /
# capability checks so they run where the tool exists and SKIP (not fail) where
# it does not. ruff, gitleaks, the live pip-audit SCA run, glab ci lint,
# hadolint, and the live trivy image scan remain DEFERRED (documented in the
# README and wired into the workflows — those tools are not installed here).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE" || exit 1

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
    sed 's/^/         /' /tmp/_lab_check.out | head -30
    fail=$((fail + 1))
  fi
}

echo "== validating cicd-pipelines =="

# --- 1. YAML well-formedness for every workflow (PyYAML) -------------------
parse_yaml() {
  python3 -c "import yaml,sys; list(yaml.safe_load_all(open(sys.argv[1])))" "$1"
}
check "yaml parses: solution/.github/workflows/ci.yml"          parse_yaml solution/.github/workflows/ci.yml
check "yaml parses: solution/.github/workflows/ci-advanced.yml" parse_yaml solution/.github/workflows/ci-advanced.yml
check "yaml parses: solution/.github/workflows/cd.yml"          parse_yaml solution/.github/workflows/cd.yml
check "yaml parses: solution/.gitlab-ci.yml"                    parse_yaml solution/.gitlab-ci.yml
check "yaml parses: starter/.github/workflows/ci.yml"           parse_yaml starter/.github/workflows/ci.yml
check "yaml parses: starter/.github/workflows/ci-advanced.yml"  parse_yaml starter/.github/workflows/ci-advanced.yml
check "yaml parses: starter/.github/workflows/cd.yml"           parse_yaml starter/.github/workflows/cd.yml
check "yaml parses: broken/ci-bad-needs.yml"                    parse_yaml broken/ci-bad-needs.yml

# --- 2. Job-graph gate: every `needs` references a real job, acyclic --------
check "job graph valid: solution ci.yml + ci-advanced.yml + cd.yml" \
  python3 tests/check_job_graph.py \
    solution/.github/workflows/ci.yml \
    solution/.github/workflows/ci-advanced.yml \
    solution/.github/workflows/cd.yml

# The broken fixture MUST be rejected — invert the exit code (PASS = detected).
check "job graph gate REJECTS broken/ci-bad-needs.yml (expected)" \
  bash -c '! python3 tests/check_job_graph.py broken/ci-bad-needs.yml'

# --- 3. Workflow unit tests (security invariants, gate behavior) ------------
check "workflow unit tests (unittest)" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# --- 4. Flask app compiles and its tests pass -------------------------------
# py_compile is the always-runnable gate for the Flask app (no Flask import).
check "python compiles: solution/app/main.py"     python3 -m py_compile solution/app/main.py
check "python compiles: solution/app/__init__.py" python3 -m py_compile solution/app/__init__.py

# The pytest gate imports Flask, so it only runs where Flask is installed.
# Tests run from the solution root so `from app.main import ...` resolves.
if python3 -c "import flask" >/dev/null 2>&1 && python3 -c "import pytest" >/dev/null 2>&1; then
  check "app unit tests (pytest)" \
    bash -c 'cd solution && python3 -m pytest -q'
else
  echo "  [SKIP] app unit tests (Flask or pytest not installed) — pip install -r solution/requirements-dev.txt"
fi

# --- 5. Optional: real docker build + /health smoke test --------------------
# Skipped (not failed) when docker or a network to pull the base image is
# unavailable. Where it runs, it is a real gate: the image must build AND serve
# /health with HTTP 200.
if command -v docker >/dev/null 2>&1; then
  smoke_docker() {
    local img="cicd-pipelines-validate:local"
    docker build -t "$img" solution/app >/dev/null || return 1
    local cid
    cid="$(docker run -d -p 0:8000 "$img")" || return 1
    sleep 3
    local rc=0
    docker exec "$cid" python -c \
      "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health').status==200 else 1)" \
      || rc=1
    docker rm -f "$cid" >/dev/null 2>&1
    docker rmi "$img" >/dev/null 2>&1
    return "$rc"
  }
  check "docker build + /health smoke test (solution/app)" smoke_docker
else
  echo "  [SKIP] docker build + /health smoke test (docker not installed)"
fi

# --- 6. actionlint: validate every GitHub Actions workflow ------------------
# Real GitHub Actions linter (expression syntax, job-needs, shellcheck of run
# steps, action input validation). Guarded so it SKIPS where actionlint is
# absent and runs as a hard gate where it is installed.
if command -v actionlint >/dev/null 2>&1; then
  for wf in \
    solution/.github/workflows/ci.yml \
    solution/.github/workflows/ci-advanced.yml \
    solution/.github/workflows/cd.yml \
    starter/.github/workflows/ci.yml \
    starter/.github/workflows/ci-advanced.yml \
    starter/.github/workflows/cd.yml; do
    check "actionlint: $wf" actionlint "$wf"
  done
  # The broken fixture has dangling `needs:` (test->unit, scan->buld). actionlint
  # MUST reject it; invert the exit code so PASS == "correctly detected", mirroring
  # the check_job_graph gate above. This is a teaching fixture, not a real bug.
  check "actionlint REJECTS broken/ci-bad-needs.yml (expected)" \
    bash -c '! actionlint broken/ci-bad-needs.yml'
else
  echo "  [SKIP] actionlint (not installed) — run where actionlint is available"
fi

# --- 7. yamllint: validate pipeline YAML (relaxed, CI-idiomatic ruleset) -----
# .yamllint.yml relaxes Actions/GitLab idioms (the `on:` key, no `---` start,
# long explanatory comments) but KEEPS structural checks (indentation, duplicate
# keys, trailing whitespace). Guarded so it SKIPS where yamllint is absent.
if command -v yamllint >/dev/null 2>&1; then
  ylint() { yamllint -c .yamllint.yml "$1"; }
  for f in \
    solution/.gitlab-ci.yml \
    starter/.gitlab-ci.yml \
    solution/.github/workflows/ci.yml \
    solution/.github/workflows/ci-advanced.yml \
    solution/.github/workflows/cd.yml \
    starter/.github/workflows/ci.yml \
    starter/.github/workflows/ci-advanced.yml \
    starter/.github/workflows/cd.yml \
    broken/ci-bad-needs.yml; do
    check "yamllint: $f" ylint "$f"
  done
else
  echo "  [SKIP] yamllint (not installed) — run where yamllint is available"
fi

# --- DEFERRED gates (tool absent in this environment) -----------------------
echo "  [DEFERRED] ruff check .                          (Python lint; pip install ruff==0.8.4)"
echo "  [DEFERRED] gitleaks detect --no-git              (secret scan; runs in ci.yml security job)"
echo "  [DEFERRED] pip-audit -r requirements.txt         (SCA; needs python3-venv to resolve)"
echo "  [DEFERRED] glab ci lint                          (GitLab pipeline lint; needs a GitLab project)"
echo "  [DEFERRED] hadolint app/Dockerfile               (run where hadolint is installed)"
echo "  [DEFERRED] trivy image ... --exit-code 1         (advanced variant; run where Trivy + an image exist)"

echo "== $pass passed, $fail failed (plus 6 DEFERRED — see README) =="
exit $(( fail > 0 ? 1 : 0 ))
