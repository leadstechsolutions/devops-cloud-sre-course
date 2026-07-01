# shellcheck shell=bash
# lib/common.sh — shared helpers sourced by every script in this module.
#
# This file is meant to be *sourced*, not executed. It deliberately does NOT set
# `set -euo pipefail` itself: each entrypoint script owns its own shell options.
# Functions here only define behaviour.
#
# Provided functions:
#   log <level> <msg...>     structured, timestamped line to stderr
#   die <msg...>             log at ERROR and exit 1
#   require_cmd <cmd...>     ensure each named command exists on PATH, else die
#   aws_region               echo the region the AWS CLI will actually use
#   require_aws_creds        verify caller identity resolves, else die clearly
#   aws_json <args...>       run `aws --output json <args>` and pass through
#
# DESIGN: every script in this module is READ-ONLY. The only AWS verbs used are
# sts:GetCallerIdentity, ec2:Describe*, s3:List*/ls, and iam:List*. Nothing here
# creates, modifies, tags, or deletes anything. Diagnostic output goes to STDERR
# so a script's STDOUT stays clean for data a caller may want to pipe.

# Guard against double-sourcing.
if [[ -n "${_COMMON_SH_SOURCED:-}" ]]; then
  # SC2317: this IS reachable — it runs whenever the file is sourced a second
  # time (the guard's whole purpose). ShellCheck can't see the indirect re-entry,
  # so the false positive is disabled narrowly on this single statement.
  # shellcheck disable=SC2317
  return 0 2>/dev/null || true
fi
_COMMON_SH_SOURCED=1

# log LEVEL MESSAGE...
# Emits: 2026-06-30T12:00:00+00:00 [LEVEL] message  (to stderr)
log() {
  local level="$1"; shift
  local ts
  ts="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  printf '%s [%s] %s\n' "$ts" "$level" "$*" >&2
}

# die MESSAGE...  — log at ERROR then exit non-zero.
die() {
  log "ERROR" "$@"
  exit 1
}

# require_cmd CMD...  — fail fast if any dependency is missing.
require_cmd() {
  local cmd
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      die "required command not found on PATH: $cmd"
    fi
  done
}

# aws_region — resolve the region the CLI will use, honouring (in CLI precedence):
#   AWS_REGION -> AWS_DEFAULT_REGION -> the active profile's configured region.
# Emits the region on stdout, or an empty string if none is set. Never mutates.
aws_region() {
  local r
  if [[ -n "${AWS_REGION:-}" ]]; then
    printf '%s' "$AWS_REGION"; return 0
  fi
  if [[ -n "${AWS_DEFAULT_REGION:-}" ]]; then
    printf '%s' "$AWS_DEFAULT_REGION"; return 0
  fi
  # `aws configure get region` reads the resolved profile (honours AWS_PROFILE).
  r="$(aws configure get region 2>/dev/null || true)"
  printf '%s' "$r"
}

# require_aws_creds — verify the caller's credentials actually resolve.
#
# CRITICAL: `aws sts get-caller-identity` is the canonical "am I authenticated"
# probe. We must NOT swallow its exit status: if it fails (no creds, expired SSO
# token, bad profile), we surface the real error and die non-zero. This is the
# exact bug the broken/ fixture demonstrates by ignoring this failure.
require_aws_creds() {
  local err
  if ! err="$(aws sts get-caller-identity --output json 2>&1)"; then
    log "ERROR" "AWS credentials are not usable for this command."
    log "ERROR" "active profile: ${AWS_PROFILE:-default}; region: $(aws_region)"
    # Surface the real CLI error (expired token, no credentials, etc.) verbatim.
    printf '%s\n' "$err" | sed 's/^/         aws: /' >&2
    log "ERROR" "fix: run 'aws sso login' (SSO) or 'aws configure' (static keys),"
    log "ERROR" "     or export the right AWS_PROFILE. See sso-config.md."
    exit 1
  fi
}

# aws_json ARGS... — thin wrapper that forces JSON output for stable parsing.
# Returns the CLI's own exit status so callers can react to API errors.
aws_json() {
  aws --output json "$@"
}
