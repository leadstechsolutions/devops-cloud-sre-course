#!/usr/bin/env bash
#
# disk-check-broken.sh — Week-2 TROUBLESHOOTING FIXTURE. DO NOT use in production.
#
# This is a deliberately broken copy of solution/disk-check.sh. It contains TWO
# real, reproducible bugs for the learner to find and fix. See the module README
# "Troubleshooting" section for the symptom -> cause -> fix walkthrough.
#
#   BUG 1 (word-splitting): the mount point is used UNQUOTED, so a mount path
#          containing a space (e.g. "/mnt/data backup") is split into two fields
#          and the report line is mangled / argument count is wrong.
#   BUG 2 (off-by-one): the comparison uses >= instead of >, so a mount sitting
#          exactly AT the threshold is wrongly reported as breached, and the exit
#          status is 1 when it should be 0.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source the shared lib from the sibling solution/ tree.
# shellcheck source-path=SCRIPTDIR
# shellcheck source=../solution/lib/common.sh
source "${SCRIPT_DIR}/../solution/lib/common.sh"

THRESHOLD=90

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-t|--threshold N] [-h|--help]
(broken troubleshooting fixture — see README)
EOF
}

ARGS=()
while (($#)); do
  case "$1" in
    --threshold) ARGS+=("-t"); shift ;;
    --threshold=*) ARGS+=("-t" "${1#*=}"); shift ;;
    --help) ARGS+=("-h"); shift ;;
    --) shift; while (($#)); do ARGS+=("$1"); shift; done ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

while getopts ":t:h" opt; do
  case "$opt" in
    t) THRESHOLD="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) die "option -$OPTARG requires an argument" ;;
    \?) usage; die "unknown option: -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || ((THRESHOLD < 0 || THRESHOLD > 100)); then
  die "threshold must be an integer between 0 and 100 (got: '$THRESHOLD')"
fi

require_cmd df awk

breached=0
checked=0

df_out="$(df -P 2>/dev/null)" || die "df -P failed"

while IFS= read -r line; do
  usage_pct="$(awk '{gsub(/%/,"",$5); print $5}' <<<"$line")"
  mount="$(awk '{ $1=$2=$3=$4=$5=""; sub(/^ +/,""); print }' <<<"$line")"

  [[ "$usage_pct" =~ ^[0-9]+$ ]] || continue
  checked=$((checked + 1))

  # BUG 2: `>=` should be `>`. A mount exactly at the threshold is not a breach.
  if ((usage_pct >= THRESHOLD)); then
    breached=$((breached + 1))
    # BUG 1: $mount is UNQUOTED. A mount path with a space word-splits into two
    # printf arguments, corrupting the report (and can shift the %s alignment).
    printf 'BREACH %3d%% > %d%%  %s\n' "$usage_pct" "$THRESHOLD" $mount
  fi
done < <(printf '%s\n' "$df_out" | tail -n +2)

log "INFO" "checked ${checked} mount(s); ${breached} over ${THRESHOLD}%"

if ((breached > 0)); then
  exit 1
fi
exit 0
