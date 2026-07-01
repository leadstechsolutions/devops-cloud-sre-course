#!/usr/bin/env bash
#
# log-rotate.sh — gzip log files older than N days in a directory.
#
# Finds regular files in --dir whose mtime is older than --days days, and
# compresses each with gzip (which removes the original and leaves NAME.gz).
# Already-compressed (*.gz) files are skipped so re-runs are idempotent.
# --dry-run prints what would happen without touching anything.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

DIR=""
DAYS=14
DRY_RUN=0

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") -d|--dir DIR [-n|--days N] [--dry-run] [-h|--help]

Compresses (gzip) regular files in DIR whose modification time is older than N
days. Files already ending in .gz are skipped. Idempotent.

Options:
  -d, --dir DIR    Directory to scan (required).
  -n, --days N     Age threshold in days. Default: ${DAYS}.
      --dry-run    Show what would be compressed; change nothing.
  -h, --help       Show this help and exit.

Examples:
  $(basename "$0") --dir /var/log/myapp --days 7
  $(basename "$0") -d ./logs -n 30 --dry-run
EOF
}

ARGS=()
while (($#)); do
  case "$1" in
    --dir) ARGS+=("-d"); shift ;;
    --dir=*) ARGS+=("-d" "${1#*=}"); shift ;;
    --days) ARGS+=("-n"); shift ;;
    --days=*) ARGS+=("-n" "${1#*=}"); shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help) ARGS+=("-h"); shift ;;
    --) shift; while (($#)); do ARGS+=("$1"); shift; done ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

while getopts ":d:n:h" opt; do
  case "$opt" in
    d) DIR="$OPTARG" ;;
    n) DAYS="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) die "option -$OPTARG requires an argument" ;;
    \?) usage; die "unknown option: -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

[[ -n "$DIR" ]] || { usage; die "--dir is required"; }
[[ -d "$DIR" ]] || die "not a directory: $DIR"
if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
  die "--days must be a non-negative integer (got: '$DAYS')"
fi

require_cmd find gzip

# --- core logic -------------------------------------------------------------
rotated=0
while IFS= read -r -d '' f; do
  if ((DRY_RUN)); then
    log "INFO" "[dry-run] would gzip: $f"
  else
    # TODO(student): compress the file in place with gzip (this removes the
    # original and leaves "$f.gz"), then log what happened.
    :
  fi
  rotated=$((rotated + 1))
# TODO(student): drive the loop from `find`. You need regular files in "$DIR"
# that are (a) NOT already *.gz and (b) older than DAYS days (mtime +DAYS).
# Emit them NUL-separated (-print0) so the `read -d ''` above is space-safe.
done < <(find "$DIR" -type f -print0)   # TODO(student): add the ! -name and -mtime filters

if ((DRY_RUN)); then
  log "INFO" "[dry-run] ${rotated} file(s) older than ${DAYS}d would be rotated in ${DIR}"
else
  log "INFO" "rotated ${rotated} file(s) older than ${DAYS}d in ${DIR}"
fi
exit 0
