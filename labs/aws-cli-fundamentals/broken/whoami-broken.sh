#!/usr/bin/env bash
#
# whoami-broken.sh — Week-4 TROUBLESHOOTING FIXTURE. DO NOT use in production.
#
# This is a deliberately broken copy of solution/whoami.sh. It contains TWO real,
# reproducible bugs. See the module README "Troubleshooting" section for the
# symptom -> cause -> fix walkthrough.
#
#   BUG 1 (swallowed failure / false success): the credential probe is run as
#          `aws sts get-caller-identity 2>/dev/null || true`. The `|| true`
#          DISCARDS the non-zero exit status, and `2>/dev/null` hides the real
#          error. With NO credentials (or an expired SSO token) the script keeps
#          going and prints an empty/garbage identity, then exits 0 — falsely
#          reporting success. A monitoring/CI gate built on this exit code would
#          never fire. The fix is to NOT swallow the status and to die() on it.
#
#   BUG 2 (ignores AWS_PROFILE): the region is read from a hard-coded default
#          instead of resolving the active profile/env. Because the script also
#          unsets nothing and never consults AWS_PROFILE for context, the printed
#          "Profile" line lies (always shows 'default') even when AWS_PROFILE is
#          set, so an operator cannot tell which account they actually queried.
#
# Both bugs are BEHAVIOURAL — the file parses cleanly (`bash -n` passes) and even
# `shellcheck` is mostly clean, which is exactly why the fault is dangerous: tools
# do not catch "I ignored the error on purpose".
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source the shared lib from the sibling solution/ tree.
# shellcheck source-path=SCRIPTDIR
# shellcheck source=../solution/lib/common.sh
source "${SCRIPT_DIR}/../solution/lib/common.sh"

require_cmd aws

# BUG 1: the credential check's exit status is swallowed by `|| true` and its
# stderr is hidden by 2>/dev/null. A failed probe (no creds) is treated as OK.
identity="$(aws sts get-caller-identity --output json 2>/dev/null || true)"

# A correct script would `die` here when $identity is empty. This one only logs a
# note and keeps going — so the empty case still flows through to a "success".
if [[ -z "$identity" ]]; then
  log "WARN" "no identity returned (but continuing anyway — this is the bug)"
fi

# Because $identity may be empty, these --query calls also produce empty strings
# rather than failing. The script marches on and prints blanks as if all is well.
account="$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null || true)"
arn="$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || true)"

# BUG 2: region is hard-coded and AWS_PROFILE is ignored entirely.
region="us-east-1"

printf 'Account : %s\n' "$account"
printf 'ARN     : %s\n' "$arn"
printf 'Profile : %s\n' "default"   # BUG 2: lies — never reflects $AWS_PROFILE
printf 'Region  : %s\n' "$region"

# BUG 1 (continued): unconditional success. Even with no credentials the caller
# sees exit 0. A scheduled "is my access still valid?" check would silently pass.
log "INFO" "identity check complete"
exit 0
