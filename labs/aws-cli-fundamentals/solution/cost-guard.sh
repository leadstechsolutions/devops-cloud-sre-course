#!/usr/bin/env bash
#
# cost-guard.sh — flag the usual money-burning leftovers in the current region.
#
# READ-ONLY. Detects four classic "I forgot to clean up" cost sinks:
#   1. Running EC2 instances            (ec2:DescribeInstances)
#   2. NAT gateways in 'available'      (ec2:DescribeNatGateways) — ~$32+/mo each
#   3. Unattached / unassociated EIPs   (ec2:DescribeAddresses)   — billed when idle
#   4. 'available' (detached) EBS vols  (ec2:DescribeVolumes)     — billed by GiB-month
#
# Prints a finding line per offender and a summary. Exits NON-ZERO if ANY finding
# is present, so it is usable directly as a CI / scheduled cost gate.
#
# NOTE: this scans ONE region (the resolved region). EIPs, EBS, NAT, and EC2 are
# all regional, so run it per region you care about (loop over `regions.sh`).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-h|--help]

Read-only scan of the resolved region for cost-burning leftovers:
  running EC2 instances, available NAT gateways, idle Elastic IPs, and
  detached (available) EBS volumes.

Exits 1 if ANY finding is present (CI/cron-friendly cost gate), 0 if clean.
Honours AWS_PROFILE / AWS_REGION. Mutates nothing.
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

# --- 1. running EC2 instances ----------------------------------------------
printf -- '-- running EC2 instances\n'
running="$(aws ec2 describe-instances \
  --filters 'Name=instance-state-name,Values=running' \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,Placement.AvailabilityZone]' \
  --output text 2>/dev/null)" || die "ec2:DescribeInstances failed"
if [[ -n "$running" ]]; then
  while IFS=$'\t' read -r id type az; do
    [[ -n "$id" ]] || continue
    printf '  [BURN] running instance %s (%s) in %s\n' "$id" "$type" "$az"
    findings=$((findings + 1))
  done <<<"$running"
else
  printf '  (none)\n'
fi

# --- 2. available NAT gateways ---------------------------------------------
printf -- '-- NAT gateways (available)\n'
nats="$(aws ec2 describe-nat-gateways \
  --filter 'Name=state,Values=available' \
  --query 'NatGateways[].[NatGatewayId,VpcId]' \
  --output text 2>/dev/null)" || die "ec2:DescribeNatGateways failed"
if [[ -n "$nats" ]]; then
  while IFS=$'\t' read -r nat vpc; do
    [[ -n "$nat" ]] || continue
    printf '  [BURN] NAT gateway %s in %s (~32 USD+/mo even when idle)\n' "$nat" "$vpc"
    findings=$((findings + 1))
  done <<<"$nats"
else
  printf '  (none)\n'
fi

# --- 3. idle Elastic IPs (allocated but not associated) --------------------
printf -- '-- Elastic IPs (idle / unassociated)\n'
# An EIP with no AssociationId is unattached. The JMESPath `null` literal MUST be
# single-quoted (it is JMESPath syntax, not a shell expansion), so SC2016 here is
# a deliberate, correct non-expansion.
# shellcheck disable=SC2016
eips="$(aws ec2 describe-addresses \
  --query 'Addresses[?AssociationId==`null`].[AllocationId,PublicIp]' \
  --output text 2>/dev/null)" || die "ec2:DescribeAddresses failed"
if [[ -n "$eips" ]]; then
  while IFS=$'\t' read -r alloc ip; do
    [[ -n "$alloc" ]] || continue
    printf '  [BURN] idle Elastic IP %s (%s) — billed hourly while unattached\n' "$ip" "$alloc"
    findings=$((findings + 1))
  done <<<"$eips"
else
  printf '  (none)\n'
fi

# --- 4. detached (available) EBS volumes -----------------------------------
printf -- '-- EBS volumes (available / detached)\n'
vols="$(aws ec2 describe-volumes \
  --filters 'Name=status,Values=available' \
  --query 'Volumes[].[VolumeId,Size,VolumeType]' \
  --output text 2>/dev/null)" || die "ec2:DescribeVolumes failed"
if [[ -n "$vols" ]]; then
  while IFS=$'\t' read -r vol size vtype; do
    [[ -n "$vol" ]] || continue
    printf '  [BURN] detached EBS volume %s (%s GiB, %s) — billed per GiB-month\n' "$vol" "$size" "$vtype"
    findings=$((findings + 1))
  done <<<"$vols"
else
  printf '  (none)\n'
fi

printf '== %d finding(s) ==\n' "$findings"
if ((findings > 0)); then
  log "WARN" "${findings} cost-burning leftover(s) found in region ${region:-<unset>}"
  exit 1
fi
log "INFO" "no cost-burning leftovers found in region ${region:-<unset>}"
exit 0
