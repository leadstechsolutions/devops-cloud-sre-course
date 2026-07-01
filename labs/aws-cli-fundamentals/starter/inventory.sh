#!/usr/bin/env bash
#
# inventory.sh — a READ-ONLY account snapshot across EC2 / S3 / IAM. (STARTER)
#
# Implement the TODO(student) gaps. Reference: ../solution/inventory.sh.
# Every call MUST be a List/Describe verb — never create, tag, or delete.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-h|--help]
Read-only inventory: EC2 instances, S3 buckets, IAM users for the current account.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") : ;;
  *) usage; die "unknown argument: $1" ;;
esac

require_cmd aws
require_aws_creds

region="$(aws_region)"

printf '=== EC2 instances (region: %s) ===\n' "${region:-<unset>}"
# TODO(student): ec2:DescribeInstances -> flatten Reservations[].Instances[] and
# select [InstanceId, InstanceType, State.Name, Placement.AvailabilityZone] as
# --output text. Print "(none)" when empty; otherwise a sorted aligned table and
# a count-by-state summary. die() on API failure.

printf '\n=== S3 buckets (global) ===\n'
# TODO(student): s3api:ListBuckets -> [Name, CreationDate]. Print "(none)" or a
# sorted table plus a total count.

printf '\n=== IAM users (global) ===\n'
# TODO(student): iam:ListUsers -> [UserName, CreateDate]. Print "(none)" or a
# sorted table plus a total count.
