# shellcheck shell=bash
# lib/common.sh — shared helpers sourced by every script in this module.
#
# STARTER: log(), die(), require_cmd(), and aws_json() are provided. You must
# implement aws_region() and require_aws_creds() (the TODO blocks below). The
# reference is in ../../solution/lib/common.sh — try it yourself first.
#
# This file is meant to be *sourced*, not executed, and deliberately does NOT set
# shell options; each entrypoint script owns its own `set -euo pipefail`.

if [[ -n "${_COMMON_SH_SOURCED:-}" ]]; then
  # shellcheck disable=SC2317
  return 0 2>/dev/null || true
fi
_COMMON_SH_SOURCED=1

log() {
  local level="$1"; shift
  local ts
  ts="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  printf '%s [%s] %s\n' "$ts" "$level" "$*" >&2
}

die() {
  log "ERROR" "$@"
  exit 1
}

require_cmd() {
  local cmd
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      die "required command not found on PATH: $cmd"
    fi
  done
}

# aws_region — echo the region the CLI will actually use.
# TODO(student): honour AWS CLI precedence:
#   1. $AWS_REGION  2. $AWS_DEFAULT_REGION  3. `aws configure get region`
# Print the resolved region (or empty string) on stdout. Do NOT mutate anything.
aws_region() {
  : # TODO(student): replace with the precedence chain above
}

# require_aws_creds — die clearly if the caller is NOT authenticated.
# TODO(student): run `aws sts get-caller-identity` and check its EXIT STATUS.
# On failure you MUST:
#   - print the real CLI error (do NOT discard stderr, do NOT `|| true`)
#   - call die() / exit non-zero so a CI gate can detect the failure
# This is the exact mistake the broken/ fixture makes — do not repeat it.
require_aws_creds() {
  : # TODO(student): implement the credential probe with no swallowed failures
}

aws_json() {
  aws --output json "$@"
}
