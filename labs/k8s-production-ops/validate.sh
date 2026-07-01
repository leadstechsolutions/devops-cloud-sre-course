#!/usr/bin/env bash
# Validation gates for the k8s-production-ops module.
# Run from the module root:  ./validate.sh
#
# STATIC gates (always, fast, tool-guarded — degrade to DEFER if a tool is absent):
#   1. yamllint -s on all manifests (config: .yamllint.yml).
#   2. Every manifest is well-formed multi-doc YAML (PyYAML safe_load_all).
#   3. kubeconform -strict schema validation of every SOLUTION manifest at the
#      cluster's k8s version. Starter manifests are SKIPPED on purpose: they ship
#      `spec: {}` TODO stubs that are intentionally schema-invalid.
#   4. shell: bash -n + shellcheck on every drill script and this file.
#
# LIVE gate (only under RUN_LIVE=1): runs solution/drills/run-drills.sh, which
#   executes all four drills on kind and writes evidence/LIVE-OPS-EVIDENCE.txt.
#   Heavy (drill 4 builds a throwaway Calico kind cluster), so it is OFF by
#   default to keep this script fast.
#
# Exits non-zero if ANY gate FAILS. DEFERRED is OK (tool missing).
set -uo pipefail

cd "$(dirname "$0")" || exit 2
ROOT="$(pwd)"
KVER="${KVER:-1.31.0}"   # schema version for kubeconform (matches kind-course)

fail=0; pass=0; defer=0

check() {  # check "label" cmd args...
  local label="$1"; shift
  if "$@" >/tmp/_kpo_check.out 2>&1; then
    printf '  [PASS]  %s\n' "$label"; pass=$((pass + 1))
  else
    printf '  [FAIL]  %s\n' "$label"
    sed 's/^/          /' /tmp/_kpo_check.out | head -30
    fail=$((fail + 1))
  fi
}
defer_note() {  # defer_note "label" "command to run where the tool exists"
  printf '  [DEFER] %s\n' "$1"
  printf '          run: %s\n' "$2"
  defer=$((defer + 1))
}

echo "== validating k8s-production-ops =="

# Collect manifest files. Solution = schema-valid; starter = has TODO stubs.
mapfile -t SOLUTION_YAML < <(find solution/manifests -name '*.yaml' | sort)
mapfile -t ALL_YAML < <(find solution starter docs -name '*.yaml' -o -name '*.mmd' 2>/dev/null | grep -E '\.yaml$' | sort)

# --- Gate 1: yamllint ----------------------------------------------------------
if command -v yamllint >/dev/null 2>&1; then
  check "yamllint -s on solution/ starter/ (config .yamllint.yml)" \
    yamllint -s -c .yamllint.yml solution starter
else
  defer_note "yamllint -s on manifests" "yamllint -s -c .yamllint.yml solution starter"
fi

# --- Gate 2: YAML well-formed (multi-doc aware) --------------------------------
# shellcheck disable=SC2317  # invoked indirectly via check()
yaml_parse() {
  python3 - "$@" <<'PY'
import sys, yaml
bad = 0
for f in sys.argv[1:]:
    try:
        with open(f) as fh:
            list(yaml.safe_load_all(fh))
    except Exception as e:  # noqa: BLE001
        print(f"PARSE ERROR {f}: {e}"); bad += 1
sys.exit(1 if bad else 0)
PY
}
check "yaml: all manifests parse (multi-doc)" yaml_parse "${ALL_YAML[@]}"

# --- Gate 3: kubeconform -strict on SOLUTION manifests -------------------------
# Skip the kind cluster config (kind.x-k8s.io is not a Kubernetes API type) and
# the namespace-scoped objects validate fine. Starter stubs are intentionally
# excluded (they are incomplete by design).
if command -v kubeconform >/dev/null 2>&1; then
  # shellcheck disable=SC2317  # invoked indirectly via check()
  kc_solution() {
    # kind-calico.yaml is a kind Cluster config, not a k8s object -> skip it.
    local files=()
    for f in "${SOLUTION_YAML[@]}"; do
      case "$f" in */netpol/kind-calico.yaml) continue;; esac
      files+=("$f")
    done
    kubeconform -strict -summary -kubernetes-version "$KVER" "${files[@]}"
  }
  check "kubeconform: -strict on solution manifests (k8s $KVER)" kc_solution
else
  defer_note "kubeconform: -strict on solution manifests" \
    "kubeconform -strict -summary -kubernetes-version $KVER solution/manifests/*.yaml solution/manifests/netpol/{workload,default-deny,allow-client-to-server}.yaml"
fi

# --- Gate 4: shell syntax + shellcheck -----------------------------------------
mapfile -t SCRIPTS < <(find solution/drills -name '*.sh' | sort; echo validate.sh)
for s in "${SCRIPTS[@]}"; do
  check "shell: bash -n $s" bash -n "$s"
done
if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck: all drill scripts + validate.sh" shellcheck -x "${SCRIPTS[@]}"
else
  defer_note "shellcheck: all drill scripts" "shellcheck -x solution/drills/*.sh validate.sh"
fi

# --- LIVE gate (RUN_LIVE=1 only) -----------------------------------------------
if [ "${RUN_LIVE:-0}" = "1" ]; then
  echo "  -- RUN_LIVE=1: executing live drills (multi-minute; builds a Calico kind cluster) --"
  check "live: run-drills.sh (all 4 drills -> evidence)" \
    env RUN_LIVE=1 bash "$ROOT/solution/drills/run-drills.sh"
else
  defer_note "live: run-drills.sh (all 4 drills, writes evidence/LIVE-OPS-EVIDENCE.txt)" \
    "RUN_LIVE=1 ./solution/drills/run-drills.sh"
fi

echo "== $pass passed, $fail failed, $defer deferred =="
exit $(( fail > 0 ? 1 : 0 ))
