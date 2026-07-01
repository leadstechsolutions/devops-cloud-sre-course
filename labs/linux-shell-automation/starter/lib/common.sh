# shellcheck shell=bash
# lib/common.sh — shared helpers sourced by every script in this module.
#
# This file is meant to be *sourced*, not executed. It deliberately does NOT set
# `set -euo pipefail` itself: each entrypoint script owns its own shell options.
# Functions here only define behaviour.
#
# Provided functions:
#   log <level> <msg...>   structured, timestamped line to stderr
#   die <msg...>           log at ERROR and exit 1
#   require_cmd <cmd...>   ensure each named command exists on PATH, else die
#
# All diagnostic output goes to STDERR so a script's STDOUT stays clean for data
# (e.g. report lines) that a caller may want to pipe.

# Guard against double-sourcing.
if [[ -n "${_COMMON_SH_SOURCED:-}" ]]; then
  return 0 2>/dev/null || true
fi
_COMMON_SH_SOURCED=1

# log LEVEL MESSAGE...
# Emits: 2026-06-30T12:00:00+00:00 [LEVEL] message
log() {
  local level="$1"; shift
  local ts
  ts="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  printf '%s [%s] %s\n' "$ts" "$level" "$*" >&2
}

# die MESSAGE...  — log at ERROR then exit non-zero.
die() {
  # TODO(student): log the message at level "ERROR" using log() above,
  # then exit with a non-zero status so callers stop on failure.
  : # remove this no-op once implemented
}

# require_cmd CMD...  — fail fast if any dependency is missing.
require_cmd() {
  local cmd
  for cmd in "$@"; do
    # TODO(student): if `command -v "$cmd"` does NOT find the command on PATH,
    # call die() with a clear "required command not found" message naming $cmd.
    : # remove this no-op once implemented
  done
}
