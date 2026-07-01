#!/usr/bin/env bash
#
# setup-check.sh — verify the student toolchain is present at the right versions.
#
# For each tool it: detects the binary, parses its version, compares against a
# minimum (numeric semver-ish, so 3.10 > 3.9), and prints PASS/FAIL/WARN with a
# one-line remediation hint. Exits non-zero if ANY *required* tool is missing or
# too old. Optional tools (helm, kind) only WARN and never fail the run.
#
# Usage:
#   ./setup-check.sh              # check the live toolchain
#   ./setup-check.sh --quiet      # only print failures + the summary
#
# This script intentionally does NOT need root, network, or any cloud creds.
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/check.sh
source "${SCRIPT_DIR}/lib/check.sh"

QUIET=0
for arg in "$@"; do
  case "$arg" in
    --quiet|-q) QUIET=1 ;;
    -h|--help)
      sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) printf 'unknown argument: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Tool matrix. Each row: NAME CMD MIN REQUIRED HINT [VERSION-ARGS...]
#
# MIN is the lowest version this course is validated against. REQUIRED tools
# fail the run when missing/old; OPTIONAL tools only warn. The version args
# default to "--version"; override where a tool needs something else.
# ---------------------------------------------------------------------------

run_checks() {
  check_tool "git"       "git"       "2.30" "required" \
    "install git: https://git-scm.com/downloads (apt install git / brew install git)"

  check_tool "python3"   "python3"   "3.10" "required" \
    "install Python 3.10+: https://www.python.org/downloads/ (or pyenv)" \
    --version

  check_tool "docker"    "docker"    "24"   "required" \
    "install Docker Engine/Desktop: https://docs.docker.com/get-docker/"

  check_tool "terraform" "terraform" "1.6"  "required" \
    "install Terraform 1.6+: https://developer.hashicorp.com/terraform/install" \
    version

  check_tool "aws"       "aws"       "2"    "required" \
    "install AWS CLI v2: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"

  check_tool "kubectl"   "kubectl"   "1.27" "required" \
    "install kubectl: https://kubernetes.io/docs/tasks/tools/" \
    version --client -o json

  # --- optional tooling: warns but never fails the suite ---
  check_tool "helm"      "helm"      "3.12" "optional" \
    "install Helm 3: https://helm.sh/docs/intro/install/" \
    version --short

  check_tool "kind"      "kind"      "0.20" "optional" \
    "install kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
}

echo "== toolchain check =="

if (( QUIET )); then
  # Capture, then surface only FAIL/WARN lines + their hints, but keep counters.
  out="$(run_checks)"
  printf '%s\n' "$out" | grep -E '\[(FAIL|WARN)\]|hint:' || true
else
  run_checks
fi

echo
echo "== summary: ${CHECK_PASS} pass, ${CHECK_FAIL} fail, ${CHECK_WARN} warn =="

if (( CHECK_FAIL > 0 )); then
  echo "RESULT: NOT READY — fix the FAIL items above, then re-run." >&2
  exit 1
fi
echo "RESULT: READY — required toolchain satisfied."
exit 0
