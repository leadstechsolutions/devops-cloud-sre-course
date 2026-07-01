#!/usr/bin/env bash
#
# tag-audit.sh — list resources missing required tag keys. (STARTER)
#
# Implement the TODO(student) gaps. Reference: ../solution/tag-audit.sh.
# READ-ONLY. Exit NON-ZERO if any resource is missing any required tag.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REQUIRED_TAGS="Owner,Environment,Project"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-r|--require KEY1,KEY2,...] [-h|--help]
Audits EC2 instances + EBS volumes for required tag keys. Default: ${REQUIRED_TAGS}.
Exits 1 if any resource is missing any required tag.
EOF
}

while (($#)); do
  case "$1" in
    -r|--require) REQUIRED_TAGS="${2:?--require needs a value}"; shift 2 ;;
    --require=*) REQUIRED_TAGS="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage; die "unknown argument: $1" ;;
  esac
done

require_cmd aws awk
require_aws_creds

# TODO(student): split $REQUIRED_TAGS (comma-separated) into an array REQ[],
# trimming whitespace and dropping empties. die() if REQ ends up empty.
REQ=()   # TODO(student): replace

region="$(aws_region)"
violations=0

printf '== tag-audit (region: %s) — required: %s ==\n' "${region:-<unset>}" "${REQ[*]:-<none>}"

# audit_resource <label> <id> <present-keys-newline-separated>
# TODO(student): for each required key not present in $3, record it as missing.
# If any are missing, print a [MISSING] line listing them and add to $violations.
audit_resource() {
  : # TODO(student): implement the missing-key comparison
}

# TODO(student): EC2 instances — ec2:DescribeInstances selecting
#   [InstanceId, Tags[].Key]; for each instance build a newline list of present
#   tag keys (handle the "None" case) and call audit_resource "instance" ...

# TODO(student): EBS volumes — ec2:DescribeVolumes selecting [VolumeId, Tags[].Key];
#   same handling, call audit_resource "volume" ...

printf '== %d missing-tag violation(s) ==\n' "$violations"
if ((violations > 0)); then
  exit 1
fi
exit 0
