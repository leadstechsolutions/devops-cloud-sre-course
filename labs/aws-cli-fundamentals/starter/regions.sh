#!/usr/bin/env bash
#
# regions.sh — list AWS regions as a table. (STARTER)
#
# Implement the TODO(student) gaps. Reference: ../solution/regions.sh.
# Uses ec2:DescribeRegions (READ-ONLY).
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
Lists AWS regions (ec2:DescribeRegions) as a table. --all includes disabled opt-in regions.
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

# TODO(student): build the describe-regions argument array. Use a --query that
# returns [RegionName, OptInStatus, Endpoint] and --output text. When $ALL is 1,
# append --all-regions so disabled opt-in regions are included too.
region_args=()   # TODO(student): replace with the real arg list

# TODO(student): run the CLI, capturing output. die() on a non-zero exit so an
# IAM/permission error is fatal rather than silently empty.
rows=""          # TODO(student): replace

# TODO(student): print a header row, then the sorted body, formatted into aligned
# columns with awk (the field separator from --output text is a literal TAB).
