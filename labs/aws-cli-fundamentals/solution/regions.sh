#!/usr/bin/env bash
#
# regions.sh — list AWS regions visible to this account as a table.
#
# Uses ec2:DescribeRegions (READ-ONLY). By default the API returns only regions
# that are enabled/opt-in-not-required for the account; pass --all to include
# opt-in regions that are not yet enabled.
#
# Output is a fixed-width table on stdout:
#   REGION              OPT-IN-STATUS         ENDPOINT
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

ALL=0

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-a|--all] [-h|--help]

Lists AWS regions (ec2:DescribeRegions) as a table: region, opt-in status, endpoint.

Options:
  -a, --all    Include regions not enabled for the account (all-regions=true).
  -h, --help   Show this help and exit.
EOF
}

while (($#)); do
  case "$1" in
    -a|--all) ALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage; die "unknown argument: $1" ;;
  esac
done

require_cmd aws
require_aws_creds

# Build the query args. --all-regions returns disabled opt-in regions too.
region_args=(ec2 describe-regions --query 'Regions[].[RegionName,OptInStatus,Endpoint]' --output text)
if ((ALL)); then
  region_args+=(--all-regions)
fi

# `--output text` gives one TAB-separated row per region. We sort by name and
# format into aligned columns with awk. Capture first so an API error is fatal.
rows="$(aws "${region_args[@]}")" || die "ec2:DescribeRegions failed (check IAM permissions)"

if [[ -z "$rows" ]]; then
  die "no regions returned — unexpected; check account state and permissions"
fi

# Header + body, aligned. Field separator from `--output text` is a literal TAB.
{
  printf 'REGION\tOPT-IN-STATUS\tENDPOINT\n'
  printf '%s\n' "$rows" | sort
} | awk -F'\t' '{ printf "%-18s  %-22s  %s\n", $1, $2, $3 }'

count="$(printf '%s\n' "$rows" | grep -c .)"
log "INFO" "listed ${count} region(s)$([[ $ALL -eq 1 ]] && echo ' (including disabled opt-in)')"
