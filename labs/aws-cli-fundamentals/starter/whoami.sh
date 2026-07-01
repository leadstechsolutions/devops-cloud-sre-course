#!/usr/bin/env bash
#
# whoami.sh — answer "who am I to AWS?" using sts:GetCallerIdentity. (STARTER)
#
# Implement the TODO(student) gaps. Reference: ../solution/whoami.sh.
# READ-ONLY: the only API call is sts:GetCallerIdentity.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-h|--help]
Prints the resolved AWS identity (account, ARN, name, region) for the active profile.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") : ;;
  *) usage; die "unknown argument: $1" ;;
esac

require_cmd aws

# TODO(student): verify credentials BEFORE doing anything else. Call the helper
# that probes sts:GetCallerIdentity and dies clearly if there are no usable creds.
# Hint: you wrote it in lib/common.sh.

# TODO(student): fetch the identity fields. Use the AWS CLI's own --query/--output
# text so you do not need jq. Pull:
#   account -> 'Account'   arn -> 'Arn'   userid -> 'UserId'
account=""   # TODO(student): replace
arn=""       # TODO(student): replace
userid=""    # TODO(student): replace

# TODO(student): resolve the region using your aws_region helper; fall back to a
# clear placeholder if it is unset.
region=""    # TODO(student): replace

# Derive a friendly principal name from the ARN's last path segment.
principal="${arn##*:}"
principal="${principal#*/}"

printf 'Account : %s\n' "$account"
printf 'ARN     : %s\n' "$arn"
printf 'UserId  : %s\n' "$userid"
printf 'Name    : %s\n' "$principal"
printf 'Profile : %s\n' "${AWS_PROFILE:-default}"
printf 'Region  : %s\n' "$region"
