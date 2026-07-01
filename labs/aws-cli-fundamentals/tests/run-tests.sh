#!/usr/bin/env bash
#
# run-tests.sh — OFFLINE functional tests for the aws-cli-fundamentals scripts.
#
# These scripts call the live AWS API, but we have NO credentials in CI. So we
# test the parts that are observable WITHOUT a real account:
#
#   1. With no/forced-bad credentials, every solution script EXITS NON-ZERO with
#      a clear "credentials are not usable" message (no false success).
#   2. The broken/ fixture, by contrast, FALSELY exits 0 even with no creds — the
#      exact fault the troubleshooting exercise teaches. (Proven against a stub.)
#   3. require_aws_creds() actually succeeds when sts works, and the resolved
#      identity/region helpers behave — proven with a fake `aws` on PATH so no
#      network or real account is touched.
#   4. --help works and exits 0 for every script.
#   5. Static guarantee: no solution script contains a mutating AWS verb.
#
# A FAKE `aws` binary is placed on PATH for the stubbed cases, so these tests run
# fully offline, touch no real account, and create/destroy nothing in AWS.
#
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOL="${TESTS_DIR}/../solution"
BROKEN="${TESTS_DIR}/../broken"

PASS=0
FAIL=0
ok()  { printf '  [PASS] %s\n' "$1"; PASS=$((PASS + 1)); }
bad() { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }

assert_eq() {
  if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1 (expected [$2], got [$3])"; fi
}
assert_contains() {
  if [[ "$2" == *"$3"* ]]; then ok "$1"; else bad "$1 (output lacked [$3])"; fi
}

WORK="$(mktemp -d)"
# SC2317: invoked indirectly by the EXIT trap, not inline.
# shellcheck disable=SC2317
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

echo "== aws-cli-fundamentals tests (sandbox: $WORK) =="

# ---------------------------------------------------------------------------
# A FAKE `aws` that FAILS sts (simulates "no credentials"). Everything else it
# is asked to do also fails, since auth is the gate. Used to prove scripts die.
# ---------------------------------------------------------------------------
FAKEBIN_FAIL="$WORK/bin-fail"
mkdir -p "$FAKEBIN_FAIL"
cat > "$FAKEBIN_FAIL/aws" <<'STUB'
#!/usr/bin/env bash
# Fake aws: any sts get-caller-identity fails like a missing-credentials CLI.
if [[ "$1" == "sts" && "$2" == "get-caller-identity" ]]; then
  echo "Unable to locate credentials. You can configure credentials by running \"aws configure\"." >&2
  exit 255
fi
# configure get region -> empty (no region configured)
if [[ "$1" == "configure" && "$2" == "get" ]]; then
  exit 0
fi
echo "fake-aws: unexpected call: $*" >&2
exit 255
STUB
chmod +x "$FAKEBIN_FAIL/aws"

# ---------------------------------------------------------------------------
# A FAKE `aws` that SUCCEEDS at sts and answers the read-only describe/list calls
# with canned data. Proves the happy path WITHOUT a real account.
# ---------------------------------------------------------------------------
FAKEBIN_OK="$WORK/bin-ok"
mkdir -p "$FAKEBIN_OK"
cat > "$FAKEBIN_OK/aws" <<'STUB'
#!/usr/bin/env bash
# Fake aws: minimal canned responses for the read-only calls this lab makes.
svc="$1"; op="$2"; shift 2 || true
q=""; out="text"
while (($#)); do
  case "$1" in
    --query) q="$2"; shift 2 ;;
    --output) out="$2"; shift 2 ;;
    *) shift ;;
  esac
done

case "$svc:$op" in
  sts:get-caller-identity)
    if [[ "$q" == "Account" ]]; then echo "123456789012";
    elif [[ "$q" == "Arn" ]]; then echo "arn:aws:iam::123456789012:user/lab-reader";
    elif [[ "$q" == "UserId" ]]; then echo "AIDAEXAMPLEUSERID";
    else echo '{"Account":"123456789012","Arn":"arn:aws:iam::123456789012:user/lab-reader","UserId":"AIDAEXAMPLEUSERID"}'; fi
    ;;
  configure:get) [[ "$3" == "region" || "$1" == "region" ]] && echo "eu-west-1" ; ;;
  ec2:describe-regions) printf 'eu-west-1\topt-in-not-required\tec2.eu-west-1.amazonaws.com\nus-east-1\topt-in-not-required\tec2.us-east-1.amazonaws.com\n' ;;
  ec2:describe-instances) printf 'i-0abc\tt3.micro\trunning\teu-west-1a\n' ;;
  ec2:describe-nat-gateways) : ;;
  ec2:describe-addresses) : ;;
  ec2:describe-volumes) : ;;
  s3api:list-buckets) printf 'lab-bucket\t2024-01-02T00:00:00+00:00\n' ;;
  iam:list-users) printf 'lab-reader\t2024-01-01T00:00:00+00:00\n' ;;
  *) echo "fake-aws-ok: unhandled $svc:$op" >&2; exit 9 ;;
esac
exit 0
STUB
chmod +x "$FAKEBIN_OK/aws"

# ---------------------------------------------------------------------------
# 1. No credentials -> every solution script exits non-zero with a clear error.
# ---------------------------------------------------------------------------
echo "-- no-credentials behaviour (must FAIL clearly, never false-success)"
for s in whoami regions inventory cost-guard tag-audit; do
  set +e
  out="$(PATH="$FAKEBIN_FAIL:$PATH" AWS_PROFILE=nope "$SOL/$s.sh" 2>&1)"; rc=$?
  set -e
  assert_eq "$s.sh: exits non-zero with no creds" "1" "$rc"
  assert_contains "$s.sh: prints a clear credentials error" "$out" "credentials are not usable"
  assert_contains "$s.sh: surfaces the real CLI error" "$out" "Unable to locate credentials"
done

# ---------------------------------------------------------------------------
# 2. The BROKEN fixture FALSELY succeeds with no creds (the teachable defect).
# ---------------------------------------------------------------------------
echo "-- broken/whoami-broken.sh (must reproduce the false-success bug)"
set +e
bout="$(PATH="$FAKEBIN_FAIL:$PATH" AWS_PROFILE=set-but-ignored "$BROKEN/whoami-broken.sh" 2>&1)"; brc=$?
set -e
assert_eq "broken: FALSELY exits 0 despite no credentials (BUG 1)" "0" "$brc"
assert_contains "broken: prints empty Account (swallowed failure)" "$bout" "Account :"
# BUG 2: it always prints Profile 'default' even though AWS_PROFILE was set.
if printf '%s\n' "$bout" | grep -qx 'Profile : default'; then
  ok "broken: ignores AWS_PROFILE, always says 'default' (BUG 2)"
else
  bad "broken: expected the 'Profile : default' lie (BUG 2)"
fi

# ---------------------------------------------------------------------------
# 3. Happy path against the OK stub: identity resolves, region honoured.
# ---------------------------------------------------------------------------
echo "-- stubbed happy path (no real AWS account touched)"
set +e
wout="$(PATH="$FAKEBIN_OK:$PATH" AWS_REGION=eu-west-1 "$SOL/whoami.sh" 2>/dev/null)"; wrc=$?
set -e
assert_eq "whoami: exits 0 when sts succeeds" "0" "$wrc"
assert_contains "whoami: prints the account"  "$wout" "123456789012"
assert_contains "whoami: prints the ARN"      "$wout" "user/lab-reader"
assert_contains "whoami: derives the name"    "$wout" "Name    : lab-reader"
assert_contains "whoami: honours AWS_REGION"  "$wout" "Region  : eu-west-1"

set +e
rout="$(PATH="$FAKEBIN_OK:$PATH" AWS_REGION=eu-west-1 "$SOL/regions.sh" 2>/dev/null)"; rrc=$?
set -e
assert_eq "regions: exits 0 on stub"          "0" "$rrc"
assert_contains "regions: has a header"        "$rout" "REGION"
assert_contains "regions: lists eu-west-1"     "$rout" "eu-west-1"
assert_contains "regions: lists us-east-1"     "$rout" "us-east-1"

set +e
iout="$(PATH="$FAKEBIN_OK:$PATH" AWS_REGION=eu-west-1 "$SOL/inventory.sh" 2>/dev/null)"; irc=$?
set -e
assert_eq "inventory: exits 0 on stub"         "0" "$irc"
assert_contains "inventory: shows EC2 section"  "$iout" "EC2 instances"
assert_contains "inventory: lists instance"     "$iout" "i-0abc"
assert_contains "inventory: counts by state"    "$iout" "state running"
assert_contains "inventory: lists S3 bucket"    "$iout" "lab-bucket"
assert_contains "inventory: lists IAM user"     "$iout" "lab-reader"

# cost-guard against the OK stub: one running instance, nothing else -> 1 finding.
set +e
cout="$(PATH="$FAKEBIN_OK:$PATH" AWS_REGION=eu-west-1 "$SOL/cost-guard.sh" 2>/dev/null)"; crc=$?
set -e
assert_eq "cost-guard: exits 1 when a running instance exists" "1" "$crc"
assert_contains "cost-guard: flags running instance" "$cout" "running instance i-0abc"
assert_contains "cost-guard: clean NAT section"      "$cout" "NAT gateways"

# ---------------------------------------------------------------------------
# 3b. tag-audit parsing against a mixed-tag stub: fully-tagged resources are
#     silent; an untagged ("None") resource flags ALL required keys; a partially
#     tagged one flags only the missing keys.
# ---------------------------------------------------------------------------
echo "-- tag-audit parsing (mixed tag states)"
FAKEBIN_TAGS="$WORK/bin-tags"
mkdir -p "$FAKEBIN_TAGS"
cat > "$FAKEBIN_TAGS/aws" <<'STUB'
#!/usr/bin/env bash
svc="$1"; op="$2"; shift 2 || true
while (($#)); do case "$1" in --query) shift 2;; --output) shift 2;; *) shift;; esac; done
case "$svc:$op" in
  sts:get-caller-identity) echo '{"Account":"1","Arn":"a","UserId":"u"}' ;;
  configure:get) echo "eu-west-1" ;;
  ec2:describe-instances) printf 'i-full\tOwner\tEnvironment\tProject\ni-bare\tNone\ni-part\tOwner\n' ;;
  ec2:describe-volumes) printf 'vol-full\tOwner\tEnvironment\tProject\nvol-bare\tNone\n' ;;
  *) echo "unhandled $svc:$op" >&2; exit 9 ;;
esac
exit 0
STUB
chmod +x "$FAKEBIN_TAGS/aws"
set +e
tout="$(PATH="$FAKEBIN_TAGS:$PATH" AWS_REGION=eu-west-1 "$SOL/tag-audit.sh" 2>/dev/null)"; trc=$?
set -e
assert_eq "tag-audit: exits 1 when violations exist" "1" "$trc"
if printf '%s\n' "$tout" | grep -q 'i-full'; then bad "tag-audit: fully tagged instance wrongly flagged"; else ok "tag-audit: fully-tagged instance is silent"; fi
# Match id + arrow-target on the same line, spacing-agnostically.
if printf '%s\n' "$tout" | grep -Eq 'i-bare .*-> Owner,Environment,Project'; then
  ok "tag-audit: untagged instance flags all required keys"; else
  bad "tag-audit: untagged instance flags all required keys"; fi
if printf '%s\n' "$tout" | grep -Eq 'i-part .*-> Environment,Project'; then
  ok "tag-audit: partial instance flags only the missing keys"; else
  bad "tag-audit: partial instance flags only the missing keys"; fi
assert_contains "tag-audit: untagged volume flagged" "$tout" "vol-bare"
assert_contains "tag-audit: counts 8 violations" "$tout" "8 missing-tag violation(s)"
# Custom --require narrows the key set.
set +e
tout2="$(PATH="$FAKEBIN_TAGS:$PATH" AWS_REGION=eu-west-1 "$SOL/tag-audit.sh" --require Owner 2>/dev/null)"; trc2=$?
set -e
assert_eq "tag-audit: --require Owner -> only bare resources fail" "1" "$trc2"
if printf '%s\n' "$tout2" | grep -q 'i-part'; then bad "tag-audit: --require Owner wrongly flags Owner-tagged i-part"; else ok "tag-audit: --require Owner does not flag Owner-tagged resource"; fi

# ---------------------------------------------------------------------------
# 4. --help works for every script and exits 0.
# ---------------------------------------------------------------------------
echo "-- --help exits 0"
for s in whoami regions inventory cost-guard tag-audit; do
  set +e
  "$SOL/$s.sh" --help >/dev/null 2>&1; rc=$?
  set -e
  assert_eq "$s.sh: --help exits 0" "0" "$rc"
done

# ---------------------------------------------------------------------------
# 5. STATIC read-only guarantee: no solution script invokes a mutating verb.
# ---------------------------------------------------------------------------
echo "-- read-only guarantee (no mutating AWS verbs in solution/)"
# Match `aws <service> <create|delete|...>`; allowlist describe/list/get/ls.
mutating_re='aws[[:space:]]+[a-z0-9-]+[[:space:]]+(create|delete|terminate|run-instances|put|modify|update|attach|detach|associate|disassociate|release|start-instances|stop-instances|reboot|authorize|revoke|tag-resources|untag)'
if grep -rEn "$mutating_re" "$SOL"/*.sh "$SOL"/lib/*.sh >/dev/null 2>&1; then
  bad "solution scripts contain a MUTATING aws verb:"
  grep -rEn "$mutating_re" "$SOL"/*.sh "$SOL"/lib/*.sh | sed 's/^/        /'
else
  ok "solution scripts use only read-only (describe/list/get/ls) verbs"
fi

# ---------------------------------------------------------------------------
echo "== ${PASS} passed, ${FAIL} failed =="
exit $((FAIL > 0 ? 1 : 0))
