#!/usr/bin/env bash
#
# cost-guard.sh — flag money-burning leftovers in the current region. (STARTER)
#
# Implement the TODO(student) gaps. Reference: ../solution/cost-guard.sh.
# READ-ONLY. Exit NON-ZERO if any finding is present (CI/cron cost gate).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-h|--help]
Read-only scan for running EC2, available NAT gateways, idle EIPs, detached EBS volumes.
Exits 1 if any finding is present.
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
findings=0

printf '== cost-guard scan (region: %s) ==\n' "${region:-<unset>}"

# TODO(student): 1. running EC2 instances — ec2:DescribeInstances with a
#   'instance-state-name=running' filter. For each, print a [BURN] line and
#   increment $findings.

# TODO(student): 2. NAT gateways in state 'available' — ec2:DescribeNatGateways.

# TODO(student): 3. idle Elastic IPs — ec2:DescribeAddresses; an EIP is idle when
#   it has no AssociationId (use a JMESPath filter: Addresses[?AssociationId==`null`]).

# TODO(student): 4. detached EBS volumes — ec2:DescribeVolumes, status=available.

printf '== %d finding(s) ==\n' "$findings"
if ((findings > 0)); then
  exit 1
fi
exit 0
