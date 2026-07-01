#!/usr/bin/env bash
#
# print-report.sh — summarise the toolchain in a compact table the student can
# paste into a setup-help thread. Reuses lib/check.sh for detection so the
# version parsing matches setup-check.sh exactly.
#
# Output: a fixed-width table of TOOL / FOUND / MIN / STATUS, then a one-line
# verdict. With --md it emits a GitHub-flavoured Markdown table instead, handy
# for issues/PRs. Exit code mirrors setup-check.sh: non-zero if a REQUIRED tool
# is missing or too old.
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/check.sh
source "${SCRIPT_DIR}/lib/check.sh"

FORMAT="text"
for arg in "$@"; do
  case "$arg" in
    --md|--markdown) FORMAT="md" ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'unknown argument: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

# Tool matrix mirrors setup-check.sh:  name|cmd|min|required|version-args
# (version-args are space-joined; "-" means use the default --version).
TOOLS=(
  "git|git|2.30|required|-"
  "python3|python3|3.10|required|--version"
  "docker|docker|24|required|-"
  "terraform|terraform|1.6|required|version"
  "aws|aws|2|required|-"
  "kubectl|kubectl|1.27|required|version --client -o json"
  "helm|helm|3.12|optional|version --short"
  "kind|kind|0.20|optional|-"
)

missing_required=0

emit_text() {
  printf '%-11s %-12s %-8s %s\n' "TOOL" "FOUND" "MIN" "STATUS"
  printf '%-11s %-12s %-8s %s\n' "----" "-----" "---" "------"
}

emit_md() {
  printf '| Tool | Found | Min | Status |\n'
  printf '|------|-------|-----|--------|\n'
}

row_text() { printf '%-11s %-12s %-8s %s\n' "$1" "$2" "$3" "$4"; }
row_md()   { printf '| %s | %s | %s | %s |\n' "$1" "$2" "$3" "$4"; }

if [[ "$FORMAT" == md ]]; then emit_md; else emit_text; fi

for spec in "${TOOLS[@]}"; do
  IFS='|' read -r name cmd min required vargs <<<"$spec"
  # Expand version args ("-" -> default).
  local_args=()
  if [[ "$vargs" != "-" ]]; then
    # shellcheck disable=SC2206  # deliberate word-split of a controlled string
    local_args=($vargs)
  fi

  if ver="$(detect_version "$cmd" "${local_args[@]}")"; then
    if version_ge "$ver" "$min"; then
      status="ok"
    else
      status="too-old"
      [[ "$required" == required ]] && missing_required=1
    fi
    found="$ver"
  else
    ver=""
    found="-"
    if [[ "$required" == required ]]; then
      status="MISSING"
      missing_required=1
    else
      status="missing(opt)"
    fi
  fi

  if [[ "$FORMAT" == md ]]; then
    row_md "$name" "$found" "$min" "$status"
  else
    row_text "$name" "$found" "$min" "$status"
  fi
done

echo
if (( missing_required )); then
  echo "verdict: NOT READY — one or more required tools are missing or too old."
  echo "run ./setup-check.sh for per-tool remediation hints."
  exit 1
fi
echo "verdict: READY — required toolchain satisfied."
exit 0
