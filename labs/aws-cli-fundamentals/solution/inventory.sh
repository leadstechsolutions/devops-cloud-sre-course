#!/usr/bin/env bash
#
# inventory.sh — a READ-ONLY account snapshot across three services.
#
#   EC2 : ec2:DescribeInstances   -> count by state + id/type/AZ table
#   S3  : s3api:ListBuckets       -> bucket names + creation dates
#   IAM : iam:ListUsers           -> user names + creation dates
#
# Nothing is created, tagged, or deleted. Every call is a List/Describe verb.
# Output is grouped per service on stdout; diagnostics go to stderr.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-h|--help]

Prints a read-only inventory of the current account/region:
  - EC2 instances (id, type, state, AZ) and a count by state
  - S3 buckets (name, creation date) — global, not region-scoped
  - IAM users (name, creation date) — global

Honours AWS_PROFILE / AWS_REGION. Requires ec2:DescribeInstances,
s3:ListAllMyBuckets, and iam:ListUsers. Read-only; mutates nothing.
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

# DescribeInstances: flatten reservations -> instances. One TAB row per instance.
ec2_rows="$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Placement.AvailabilityZone]' \
  --output text 2>/dev/null)" || die "ec2:DescribeInstances failed (permissions or region?)"

if [[ -z "$ec2_rows" ]]; then
  printf '  (none)\n'
else
  {
    printf 'INSTANCE-ID\tTYPE\tSTATE\tAZ\n'
    printf '%s\n' "$ec2_rows" | sort
  } | awk -F'\t' '{ printf "  %-21s  %-13s  %-12s  %s\n", $1, $2, $3, $4 }'
  # Count by state for a quick at-a-glance summary.
  printf '%s\n' "$ec2_rows" | awk -F'\t' '{ c[$3]++ } END { for (s in c) printf "  state %-12s : %d\n", s, c[s] }' | sort
fi

printf '\n=== S3 buckets (global) ===\n'
s3_rows="$(aws s3api list-buckets \
  --query 'Buckets[].[Name,CreationDate]' --output text 2>/dev/null)" \
  || die "s3:ListAllMyBuckets failed (check permissions)"
if [[ -z "$s3_rows" ]]; then
  printf '  (none)\n'
else
  printf '%s\n' "$s3_rows" | sort | awk -F'\t' '{ printf "  %-40s  %s\n", $1, $2 }'
  printf '  total: %d bucket(s)\n' "$(printf '%s\n' "$s3_rows" | grep -c .)"
fi

printf '\n=== IAM users (global) ===\n'
iam_rows="$(aws iam list-users \
  --query 'Users[].[UserName,CreateDate]' --output text 2>/dev/null)" \
  || die "iam:ListUsers failed (check permissions)"
if [[ -z "$iam_rows" ]]; then
  printf '  (none)\n'
else
  printf '%s\n' "$iam_rows" | sort | awk -F'\t' '{ printf "  %-30s  %s\n", $1, $2 }'
  printf '  total: %d user(s)\n' "$(printf '%s\n' "$iam_rows" | grep -c .)"
fi

log "INFO" "inventory complete (read-only)"
