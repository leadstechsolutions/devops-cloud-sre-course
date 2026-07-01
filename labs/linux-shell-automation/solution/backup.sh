#!/usr/bin/env bash
#
# backup.sh — create a timestamped tar.gz of a source directory and prune old
#             backups, keeping only the newest N.
#
# Writes  <dest>/<basename>-YYYYmmdd-HHMMSS.tar.gz  then deletes all but the
# newest --keep archives that match the same basename prefix.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

SRC=""
DEST=""
KEEP=7

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") -s|--src DIR -o|--dest DIR [-k|--keep N] [-h|--help]

Creates DEST/<name>-<timestamp>.tar.gz from SRC, then keeps only the newest N
archives sharing that name prefix and deletes the rest (retention pruning).

Options:
  -s, --src DIR    Directory to back up (required).
  -o, --dest DIR   Where to write the archive (required; created if missing).
  -k, --keep N     Number of archives to retain. Default: ${KEEP}.
  -h, --help       Show this help and exit.

Example:
  $(basename "$0") --src /etc --dest /var/backups --keep 5
EOF
}

ARGS=()
while (($#)); do
  case "$1" in
    --src) ARGS+=("-s"); shift ;;
    --src=*) ARGS+=("-s" "${1#*=}"); shift ;;
    --dest) ARGS+=("-o"); shift ;;
    --dest=*) ARGS+=("-o" "${1#*=}"); shift ;;
    --keep) ARGS+=("-k"); shift ;;
    --keep=*) ARGS+=("-k" "${1#*=}"); shift ;;
    --help) ARGS+=("-h"); shift ;;
    --) shift; while (($#)); do ARGS+=("$1"); shift; done ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

while getopts ":s:o:k:h" opt; do
  case "$opt" in
    s) SRC="$OPTARG" ;;
    o) DEST="$OPTARG" ;;
    k) KEEP="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) die "option -$OPTARG requires an argument" ;;
    \?) usage; die "unknown option: -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

[[ -n "$SRC" ]]  || { usage; die "--src is required"; }
[[ -n "$DEST" ]] || { usage; die "--dest is required"; }
[[ -d "$SRC" ]]  || die "source is not a directory: $SRC"
if ! [[ "$KEEP" =~ ^[0-9]+$ ]] || ((KEEP < 1)); then
  die "--keep must be a positive integer (got: '$KEEP')"
fi

require_cmd tar gzip find sort

mkdir -p "$DEST"

# --- create the archive -----------------------------------------------------
name="$(basename "$(cd "$SRC" && pwd)")"
ts="$(date '+%Y%m%d-%H%M%S')"
archive="${DEST}/${name}-${ts}.tar.gz"

# -C cds into the parent so the archive holds relative paths (no leading /).
parent="$(cd "$SRC" && cd .. && pwd)"
tar -czf "$archive" -C "$parent" "$name"
log "INFO" "created ${archive} ($(du -h "$archive" | cut -f1))"

# --- retention pruning ------------------------------------------------------
# List archives for THIS source, newest first, drop the first KEEP, delete rest.
# Sorting by name works because the timestamp is zero-padded and lexicographic.
mapfile -t archives < <(find "$DEST" -maxdepth 1 -type f \
  -name "${name}-*.tar.gz" -printf '%f\n' 2>/dev/null | sort -r)

pruned=0
if ((${#archives[@]} > KEEP)); then
  for old in "${archives[@]:KEEP}"; do
    rm -f -- "${DEST}/${old}"
    log "INFO" "pruned old backup: ${old}"
    pruned=$((pruned + 1))
  done
fi

log "INFO" "retention: kept up to ${KEEP}, pruned ${pruned}, total now $(( ${#archives[@]} - pruned ))"
exit 0
