#!/usr/bin/env bash
#
# disk-check.sh — alert when any filesystem's used% exceeds a threshold.
#
# Parses `df -P` (POSIX output: one line per mount, no wrapping), compares each
# mount's Use% against --threshold, prints a report line per breached mount, and
# exits 1 if at least one mount is over threshold (so it is CI/cron friendly).
#
set -euo pipefail

# Resolve this script's directory so `lib/common.sh` is found regardless of CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

THRESHOLD=90

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-t|--threshold N] [-h|--help]

Reports every mounted filesystem whose used percentage is strictly greater than
the threshold. Exits 1 if any mount is breached, 0 otherwise.

Options:
  -t, --threshold N   Percent (0-100) above which a mount is "breached". Default: ${THRESHOLD}.
  -h, --help          Show this help and exit.

Examples:
  $(basename "$0") --threshold 80
  $(basename "$0") -t 95
EOF
}

# --- argument parsing -------------------------------------------------------
# Support both long (--threshold) and short (-t) forms by normalising long
# options into short ones, then using getopts for clean handling.
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

# Validate threshold is an integer in 0..100.
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || ((THRESHOLD < 0 || THRESHOLD > 100)); then
  die "threshold must be an integer between 0 and 100 (got: '$THRESHOLD')"
fi

require_cmd df awk

# --- core logic -------------------------------------------------------------
# `df -P` guarantees the POSIX one-line-per-filesystem format. Columns are:
#   Filesystem  1024-blocks  Used  Available  Capacity(Use%)  Mounted-on
# We skip the header (NR==1), strip the trailing '%' from the capacity column,
# and read the mount point as everything from field 6 onward (mount paths can
# contain spaces, so we must NOT assume $6 is the whole mount).
breached=0
checked=0

# Capture df output once; fail loudly if df errored.
df_out="$(df -P 2>/dev/null)" || die "df -P failed"

while IFS= read -r line; do
  # TODO(student): from each `df -P` data line, extract two values:
  #   usage_pct -> field 5 (e.g. "73%") with the trailing '%' stripped, as an integer
  #   mount     -> field 6..NF (the mount point; it MAY contain spaces, so do NOT
  #                assume it is a single field)
  # Hint: `awk '{gsub(/%/,"",$5); print $5}'` for the percent, and an awk that
  # blanks fields 1-5 then prints the remainder for the mount point.
  usage_pct=""   # TODO(student): replace
  mount=""       # TODO(student): replace

  # Some pseudo filesystems report '-' for capacity; skip non-numeric rows.
  [[ "$usage_pct" =~ ^[0-9]+$ ]] || continue
  checked=$((checked + 1))

  # TODO(student): a mount is "breached" only when its usage is STRICTLY GREATER
  # than THRESHOLD (think carefully: > vs >=). On breach, increment `breached`
  # and print a report line. Remember to QUOTE "$mount" so a path with spaces
  # stays a single printf argument.
  if false; then   # TODO(student): replace `false` with the breach condition
    breached=$((breached + 1))
    printf 'BREACH %3d%% > %d%%  %s\n' "$usage_pct" "$THRESHOLD" "$mount"
  fi
done < <(printf '%s\n' "$df_out" | tail -n +2)

log "INFO" "checked ${checked} mount(s); ${breached} over ${THRESHOLD}%"

if ((breached > 0)); then
  exit 1
fi
exit 0
