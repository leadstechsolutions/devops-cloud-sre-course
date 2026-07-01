#!/usr/bin/env bash
# s3_public_check.sh -- detect public grants in an S3 bucket policy or ACL.
#
# Usage:
#   ./s3_public_check.sh policy <bucket-policy.json>
#   ./s3_public_check.sh acl    <bucket-acl.json>
#
# "policy" mode flags any statement that is Effect=Allow AND
#   Principal == "*"  (or {"AWS":"*"})  -> anyone on the internet.
# "acl" mode flags any grant to the predefined groups
#   AllUsers            (everyone) or
#   AuthenticatedUsers  (any AWS account -- still effectively public).
#
# Exit codes:
#   0  no public grant found
#   1  at least one public grant found
#   2  usage / parse error
#
# JSON is parsed with python3 (jq is not assumed present). The heavy lifting is
# a tiny embedded python snippet so the detection logic is exact, not a fragile
# grep over JSON text.
set -euo pipefail

usage() {
  echo "usage: $0 {policy|acl} <file.json>" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage
mode="$1"
file="$2"

[[ -f "$file" ]] || { echo "error: no such file: $file" >&2; exit 2; }

case "$mode" in
  policy)
    # A Principal is "public" when it is the string "*" or an object whose
    # "AWS" value is (or contains) "*". We only care about Allow statements.
    python3 - "$file" <<'PY'
import json, sys

with open(sys.argv[1], encoding="utf-8") as fh:
    doc = json.load(fh)

stmts = doc.get("Statement", [])
if isinstance(stmts, dict):
    stmts = [stmts]

def principal_is_public(principal) -> bool:
    if principal == "*":
        return True
    if isinstance(principal, dict):
        aws = principal.get("AWS")
        vals = aws if isinstance(aws, list) else [aws]
        return any(v == "*" for v in vals)
    return False

findings = []
for i, s in enumerate(stmts):
    if not isinstance(s, dict):
        continue
    if s.get("Effect") != "Allow":
        continue
    if principal_is_public(s.get("Principal")):
        sid = s.get("Sid") or f"#{i}"
        actions = s.get("Action")
        findings.append(f"  [PUBLIC] statement Sid={sid} allows Principal '*' "
                        f"for Action={actions}")

if findings:
    print(f"PUBLIC bucket policy: {len(findings)} public Allow statement(s):")
    print("\n".join(findings))
    sys.exit(1)

print("OK: bucket policy has no public (Principal '*') Allow statements.")
sys.exit(0)
PY
    ;;

  acl)
    python3 - "$file" <<'PY'
import json, sys

with open(sys.argv[1], encoding="utf-8") as fh:
    doc = json.load(fh)

PUBLIC_GROUPS = {
    "http://acs.amazonaws.com/groups/global/AllUsers": "AllUsers (everyone)",
    "http://acs.amazonaws.com/groups/global/AuthenticatedUsers":
        "AuthenticatedUsers (any AWS account)",
}

grants = doc.get("Grants", [])
findings = []
for g in grants:
    grantee = g.get("Grantee", {})
    uri = grantee.get("URI")
    if grantee.get("Type") == "Group" and uri in PUBLIC_GROUPS:
        findings.append(f"  [PUBLIC] {PUBLIC_GROUPS[uri]} granted "
                        f"{g.get('Permission')}")

if findings:
    print(f"PUBLIC bucket ACL: {len(findings)} public grant(s):")
    print("\n".join(findings))
    sys.exit(1)

print("OK: bucket ACL grants nothing to AllUsers/AuthenticatedUsers.")
sys.exit(0)
PY
    ;;

  *)
    usage
    ;;
esac
