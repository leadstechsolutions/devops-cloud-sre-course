#!/usr/bin/env bash
#
# whoami.sh — answer "who am I to AWS?" using sts:GetCallerIdentity.
#
# Prints the account ID, the caller ARN, the resolved user/role name, and the
# region the CLI will target. READ-ONLY: the only API call is
# sts:GetCallerIdentity (always allowed, never billed, never mutates).
#
# Exit status:
#   0  credentials resolved; identity printed
#   1  no usable credentials (clear, actionable error — NOT a silent success)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-h|--help]

Prints the AWS identity the CLI resolves for the active profile/credentials:
  account, ARN, principal name, and target region.

Honours AWS_PROFILE / AWS_REGION / AWS_DEFAULT_REGION exactly as the AWS CLI does.
Fails with a clear, non-zero error if no usable credentials are present.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") : ;;
  *) usage; die "unknown argument: $1" ;;
esac

require_cmd aws

# Verify credentials FIRST. require_aws_creds prints the real CLI error and
# exits 1 if the caller is not authenticated — we never report success on failure.
require_aws_creds

# Fetch identity once as JSON. We avoid `jq` (not guaranteed present) and use the
# CLI's own --query/--output text to pull individual fields. Each call below is
# guaranteed to succeed because require_aws_creds already proved auth works.
account="$(aws sts get-caller-identity --query 'Account' --output text)"
arn="$(aws sts get-caller-identity --query 'Arn' --output text)"
userid="$(aws sts get-caller-identity --query 'UserId' --output text)"
region="$(aws_region)"
[[ -n "$region" ]] || region="(unset — pass --region or set AWS_REGION)"

# Derive a friendly principal name from the ARN's final path segment
# (e.g. arn:aws:iam::123:user/alice -> alice ; .../assumed-role/Admin/sess -> Admin/sess).
principal="${arn##*:}"      # strip everything up to the last colon
principal="${principal#*/}" # strip the leading "user/" | "assumed-role/" prefix

printf 'Account : %s\n' "$account"
printf 'ARN     : %s\n' "$arn"
printf 'UserId  : %s\n' "$userid"
printf 'Name    : %s\n' "$principal"
printf 'Profile : %s\n' "${AWS_PROFILE:-default}"
printf 'Region  : %s\n' "$region"

log "INFO" "identity resolved for account ${account}"
