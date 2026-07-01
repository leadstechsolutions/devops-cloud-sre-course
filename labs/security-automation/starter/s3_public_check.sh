#!/usr/bin/env bash
# s3_public_check.sh -- detect public grants in an S3 bucket policy or ACL.
#
# STARTER -- the public-Principal detection is TODO'd (see the python snippet
# in "policy" mode). Complete it, then verify:
#
#   ./s3_public_check.sh policy policies/opa/fixtures/public-bucket-policy.json   # exit 1
#   ./s3_public_check.sh policy policies/opa/fixtures/private-bucket-policy.json  # exit 0
#
# Usage:
#   ./s3_public_check.sh policy <bucket-policy.json>
#   ./s3_public_check.sh acl    <bucket-acl.json>
#
# Exit codes: 0 none found / 1 public grant found / 2 usage|parse error
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
    python3 - "$file" <<'PY'
import json, sys

with open(sys.argv[1], encoding="utf-8") as fh:
    doc = json.load(fh)

stmts = doc.get("Statement", [])
if isinstance(stmts, dict):
    stmts = [stmts]

def principal_is_public(principal) -> bool:
    # TODO(student): return True when `principal` makes the bucket public:
    #   - principal == "*"                              -> public
    #   - principal == {"AWS": "*"}                     -> public
    #   - principal == {"AWS": ["...", "*"]}            -> public (any "*" in list)
    # otherwise return False.
    raise NotImplementedError("complete principal_is_public")

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
