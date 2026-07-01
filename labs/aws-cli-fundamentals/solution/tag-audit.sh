#!/usr/bin/env bash
#
# tag-audit.sh — list resources missing one or more REQUIRED tag keys.
#
# READ-ONLY. Scans taggable resources in the resolved region and reports any that
# are missing a required tag key. Defaults to the common governance trio
# (Owner, Environment, Project) but the set is overridable with --require.
#
# Covered resources (all via Describe verbs, no mutation):
#   EC2 instances   ec2:DescribeInstances
#   EBS volumes     ec2:DescribeVolumes
# (Easily extended; these two cover the bulk of tag-policy violations and keep
#  the audit fast and inexpensive.)
#
# Exits NON-ZERO if any resource is missing any required tag (governance gate).
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

Audits taggable resources (EC2 instances, EBS volumes) in the resolved region
and lists any missing a required tag key.

Options:
  -r, --require LIST   Comma-separated required tag keys. Default: ${REQUIRED_TAGS}
  -h, --help           Show this help and exit.

Exits 1 if any resource is missing any required tag, 0 if all compliant.
Honours AWS_PROFILE / AWS_REGION. Read-only; mutates nothing.
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

# Normalise required keys into a newline list, trimming whitespace.
mapfile -t REQ < <(printf '%s' "$REQUIRED_TAGS" | tr ',' '\n' | awk 'NF{gsub(/^[ \t]+|[ \t]+$/,""); print}')
((${#REQ[@]} > 0)) || die "no required tag keys given"

region="$(aws_region)"
violations=0

printf '== tag-audit (region: %s) — required: %s ==\n' "${region:-<unset>}" "${REQ[*]}"

# audit_resource <human-label> <resource-id> <present-keys-newline-separated>
# Compares present keys against REQ; prints a finding for each missing key.
audit_resource() {
  local label="$1" rid="$2" present="$3" key missing=()
  for key in "${REQ[@]}"; do
    # Match whole-line so "Owner" doesn't match "OwnerEmail".
    if ! grep -qxF "$key" <<<"$present"; then
      missing+=("$key")
    fi
  done
  if ((${#missing[@]} > 0)); then
    local IFS=,
    printf '  [MISSING] %-9s %-22s -> %s\n' "$label" "$rid" "${missing[*]}"
    violations=$((violations + ${#missing[@]}))
  fi
}

# --- EC2 instances ---------------------------------------------------------
printf -- '-- EC2 instances\n'
# Emit "instanceId<TAB>tagKey" per tag (or instanceId<TAB> with empty key if
# the instance has no tags at all), so untagged instances are still audited.
ec2_pairs="$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId, Tags[].Key]' \
  --output text 2>/dev/null)" || die "ec2:DescribeInstances failed"
if [[ -n "$ec2_pairs" ]]; then
  # `--output text` puts the InstanceId then its tag keys on one TAB-separated
  # line (or just the id + "None" when there are no tags). Parse per line.
  while IFS=$'\t' read -r rid rest; do
    [[ -n "$rid" ]] || continue
    keys=""
    if [[ -n "$rest" && "$rest" != "None" ]]; then
      keys="$(printf '%s' "$rest" | tr '\t' '\n')"
    fi
    audit_resource "instance" "$rid" "$keys"
  done <<<"$ec2_pairs"
else
  printf '  (no instances)\n'
fi

# --- EBS volumes -----------------------------------------------------------
printf -- '-- EBS volumes\n'
vol_pairs="$(aws ec2 describe-volumes \
  --query 'Volumes[].[VolumeId, Tags[].Key]' \
  --output text 2>/dev/null)" || die "ec2:DescribeVolumes failed"
if [[ -n "$vol_pairs" ]]; then
  while IFS=$'\t' read -r rid rest; do
    [[ -n "$rid" ]] || continue
    keys=""
    if [[ -n "$rest" && "$rest" != "None" ]]; then
      keys="$(printf '%s' "$rest" | tr '\t' '\n')"
    fi
    audit_resource "volume" "$rid" "$keys"
  done <<<"$vol_pairs"
else
  printf '  (no volumes)\n'
fi

printf '== %d missing-tag violation(s) ==\n' "$violations"
if ((violations > 0)); then
  log "WARN" "${violations} required-tag violation(s) in region ${region:-<unset>}"
  exit 1
fi
log "INFO" "all audited resources carry required tags: ${REQ[*]}"
exit 0
