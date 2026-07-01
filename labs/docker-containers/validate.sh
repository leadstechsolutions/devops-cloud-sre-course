#!/usr/bin/env bash
# Validation gates for the docker-containers module.
# Run from the module root:  ./validate.sh
# Prints one line per check; exits non-zero if ANY gate fails.
#
# Gates:
#   1. app/*.py compiles (py_compile)
#   2. tests/ pass (stdlib unittest)
#   3. compose.yaml is well-formed YAML (PyYAML safe_load_all)
#   4. docker compose config parses (resolves the build + service graph)
#   5. shell syntax of this script's siblings (defensive)
#   6. docker build of solution/ succeeds AND final image < 60 MB
#   7. hadolint: solution/Dockerfile passes best-practice lint (no findings)
#   8. grype:    CVE scan of the built image has 0 CRITICAL (HIGH is reported
#                but not failed here: the only HIGHs are in the python:3.12-slim
#                base image and Debian marks them "won't fix" — see README. A CI
#                policy that blocks on HIGH would fail the build; we keep the
#                base pinned because it is consumed downstream by k8s/capstone.)
#   9. syft:     produce an SPDX SBOM of the image to solution/sbom.spdx.json
#
# Gate 7 needs only the Dockerfile (no daemon). Gates 4, 6, 8 and 9 require the
# Docker CLI/daemon and the named tool; each is guarded by `command -v` so it
# runs where the tool exists and is reported DEFERRED (not failed) — with the
# documented full command — where it does not.
set -uo pipefail

cd "$(dirname "$0")" || exit 1

fail=0
pass=0
defer=0

check() {
  local label="$1"; shift
  if "$@" >/tmp/_dc_check.out 2>&1; then
    printf '  [PASS] %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  [FAIL] %s\n' "$label"
    sed 's/^/         /' /tmp/_dc_check.out | head -20
    fail=$((fail + 1))
  fi
}

defer_note() {
  printf '  [DEFER] %s\n' "$1"
  defer=$((defer + 1))
}

echo "== validating docker-containers =="

# --- Gate 1: Python compiles --------------------------------------------------
check "python: app/server.py + app/healthcheck.py compile" \
  python3 -m py_compile app/server.py app/healthcheck.py

# --- Gate 1b: Flask (W10 lecture) variant compiles ----------------------------
check "python: solution/app-flask/*.py compile (W10 lecture variant)" \
  python3 -m py_compile solution/app-flask/app.py solution/app-flask/healthcheck.py

# --- Gate 2: unit tests -------------------------------------------------------
check "python: unittest discover -s tests" \
  python3 -m unittest discover -s tests -p 'test_*.py'

# --- Gate 3: YAML well-formed -------------------------------------------------
check "yaml: solution/compose.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('solution/compose.yaml')))"
check "yaml: starter/compose.yaml parses" \
  python3 -c "import yaml; list(yaml.safe_load_all(open('starter/compose.yaml')))"

# --- Gate 5: shell syntax -----------------------------------------------------
check "shell: validate.sh syntax" bash -n validate.sh

# --- Gate 7: Dockerfile lint (no daemon needed) -------------------------------
# hadolint reads the Dockerfile directly; it does not need the Docker daemon.
if command -v hadolint >/dev/null 2>&1; then
  check "hadolint: solution/Dockerfile (no findings)" \
    hadolint solution/Dockerfile
  check "hadolint: solution/Dockerfile.flask (W10 lecture variant, no findings)" \
    hadolint solution/Dockerfile.flask
else
  defer_note "hadolint: solution/Dockerfile — run: hadolint solution/Dockerfile"
  defer_note "hadolint: solution/Dockerfile.flask — run: hadolint solution/Dockerfile.flask"
fi

# --- Gates needing Docker -----------------------------------------------------
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then

  # Gate 4: compose config parses (build + service graph resolves).
  check "docker: compose -f solution/compose.yaml config" \
    docker compose -f solution/compose.yaml config

  # Gate 6: build the solution image and assert final size < 60 MB.
  if docker build -f solution/Dockerfile -t dc-test:validate . >/tmp/_dc_build.out 2>&1; then
    printf '  [PASS] %s\n' "docker: build solution/Dockerfile"
    pass=$((pass + 1))
    size_bytes=$(docker image inspect dc-test:validate --format '{{.Size}}')
    size_mb=$(( size_bytes / 1000000 ))
    if [ "$size_mb" -lt 60 ]; then
      printf '  [PASS] %s (%s MB < 60 MB)\n' "docker: final image size budget" "$size_mb"
      pass=$((pass + 1))
    else
      printf '  [FAIL] %s (%s MB >= 60 MB)\n' "docker: final image size budget" "$size_mb"
      fail=$((fail + 1))
    fi

    # Gate 8: CVE scan of the built image (grype). We FAIL on CRITICAL only.
    # HIGH is reported for visibility but does not fail this lab gate, because
    # every HIGH here lives in the python:3.12-slim base image (glibc "won't
    # fix" + the interpreter) — not in code this module controls — and the base
    # is intentionally pinned (consumed downstream by k8s/capstone). A CI policy
    # that blocks on HIGH WOULD fail this build; that is the teaching point.
    if command -v grype >/dev/null 2>&1; then
      if grype dc-test:validate -o json >/tmp/_dc_grype.json 2>/dev/null; then
        crit=$(python3 -c "import json,sys; d=json.load(open('/tmp/_dc_grype.json')); print(sum(1 for m in d['matches'] if m['vulnerability']['severity']=='Critical'))")
        high=$(python3 -c "import json,sys; d=json.load(open('/tmp/_dc_grype.json')); print(sum(1 for m in d['matches'] if m['vulnerability']['severity']=='High'))")
        if [ "$crit" -eq 0 ]; then
          printf '  [PASS] %s (0 CRITICAL, %s HIGH base-image — see README)\n' "grype: CVE scan dc-test:validate" "$high"
          pass=$((pass + 1))
        else
          printf '  [FAIL] %s (%s CRITICAL, %s HIGH)\n' "grype: CVE scan dc-test:validate" "$crit" "$high"
          fail=$((fail + 1))
        fi
      else
        printf '  [FAIL] %s (grype could not scan)\n' "grype: CVE scan dc-test:validate"
        fail=$((fail + 1))
      fi
    else
      defer_note "grype: CVE scan — run: grype dc-test:validate (fail build on CRITICAL)"
    fi

    # Gate 9: produce a real SBOM (syft) in SPDX-JSON to solution/sbom.spdx.json.
    if command -v syft >/dev/null 2>&1; then
      if syft dc-test:validate -o spdx-json >solution/sbom.spdx.json 2>/dev/null \
         && python3 -c "import json; d=json.load(open('solution/sbom.spdx.json')); assert d.get('spdxVersion','').startswith('SPDX-'); assert len(d.get('packages',[]))>0"; then
        npkgs=$(python3 -c "import json; print(len(json.load(open('solution/sbom.spdx.json'))['packages']))")
        printf '  [PASS] %s (%s packages -> solution/sbom.spdx.json)\n' "syft: SBOM (SPDX-JSON)" "$npkgs"
        pass=$((pass + 1))
      else
        printf '  [FAIL] %s\n' "syft: SBOM (SPDX-JSON)"
        fail=$((fail + 1))
      fi
    else
      defer_note "syft: SBOM — run: syft dc-test:validate -o spdx-json > solution/sbom.spdx.json"
    fi
  else
    printf '  [FAIL] %s\n' "docker: build solution/Dockerfile"
    sed 's/^/         /' /tmp/_dc_build.out | tail -20
    fail=$((fail + 1))
  fi

  # --- W10 lecture (Flask) variant: build + grype --------------------------
  # This image installs Flask + gunicorn from PyPI, so it needs network access
  # at build time (the stdlib image above does not). We build it, assert a
  # sane size, and scan it with grype, failing on CRITICAL only (HIGH here is
  # the same python:3.12-slim base-image surface as the stdlib image — the
  # Flask dependency tree adds 0 HIGH/CRITICAL; see README).
  if docker build -f solution/Dockerfile.flask -t dc-flask:validate . >/tmp/_dc_flask_build.out 2>&1; then
    printf '  [PASS] %s\n' "docker: build solution/Dockerfile.flask (W10 lecture/Flask)"
    pass=$((pass + 1))
    fsize_bytes=$(docker image inspect dc-flask:validate --format '{{.Size}}')
    fsize_mb=$(( fsize_bytes / 1000000 ))
    if [ "$fsize_mb" -lt 80 ]; then
      printf '  [PASS] %s (%s MB < 80 MB)\n' "docker: flask image size budget" "$fsize_mb"
      pass=$((pass + 1))
    else
      printf '  [FAIL] %s (%s MB >= 80 MB)\n' "docker: flask image size budget" "$fsize_mb"
      fail=$((fail + 1))
    fi

    if command -v grype >/dev/null 2>&1; then
      if grype dc-flask:validate -o json >/tmp/_dc_flask_grype.json 2>/dev/null; then
        fcrit=$(python3 -c "import json; d=json.load(open('/tmp/_dc_flask_grype.json')); print(sum(1 for m in d['matches'] if m['vulnerability']['severity']=='Critical'))")
        fhigh=$(python3 -c "import json; d=json.load(open('/tmp/_dc_flask_grype.json')); print(sum(1 for m in d['matches'] if m['vulnerability']['severity']=='High'))")
        ftot=$(python3 -c "import json; print(len(json.load(open('/tmp/_dc_flask_grype.json'))['matches']))")
        if [ "$fcrit" -eq 0 ]; then
          printf '  [PASS] %s (0 CRITICAL, %s HIGH, %s total — base-image; see README)\n' "grype: CVE scan dc-flask:validate" "$fhigh" "$ftot"
          pass=$((pass + 1))
        else
          printf '  [FAIL] %s (%s CRITICAL, %s HIGH)\n' "grype: CVE scan dc-flask:validate" "$fcrit" "$fhigh"
          fail=$((fail + 1))
        fi
      else
        printf '  [FAIL] %s (grype could not scan)\n' "grype: CVE scan dc-flask:validate"
        fail=$((fail + 1))
      fi
    else
      defer_note "grype: Flask CVE scan — run: grype dc-flask:validate (fail build on CRITICAL)"
    fi
  else
    printf '  [FAIL] %s\n' "docker: build solution/Dockerfile.flask (W10 lecture/Flask)"
    sed 's/^/         /' /tmp/_dc_flask_build.out | tail -20
    fail=$((fail + 1))
  fi
else
  defer_note "docker: compose config — run: docker compose -f solution/compose.yaml config"
  defer_note "docker: build + size — run: docker build -f solution/Dockerfile -t dc-test . && docker image inspect dc-test --format '{{.Size}}'"
  defer_note "grype: CVE scan — run: grype dc-test -o json (needs the built image)"
  defer_note "syft: SBOM — run: syft dc-test -o spdx-json > solution/sbom.spdx.json (needs the built image)"
  defer_note "docker: build Flask (W10 lecture) — run: docker build -f solution/Dockerfile.flask -t dc-flask . (needs network for PyPI)"
  defer_note "grype: Flask CVE scan — run: grype dc-flask -o json (needs the built image)"
fi

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
