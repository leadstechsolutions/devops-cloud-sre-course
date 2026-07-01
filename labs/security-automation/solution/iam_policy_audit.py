#!/usr/bin/env python3
"""Audit an AWS IAM policy document for over-broad (wildcard) grants.

Pure-function core (`audit_policy`) + a thin CLI (`main`). No boto3, no network:
it operates on an IAM policy *document* that you already have as JSON, so it is
fully unit-testable offline.

What it flags (only on Allow statements -- a wildcard inside a Deny is not a
privilege-escalation risk, it is a broad guardrail, so we do not flag those):

  * WILDCARD_ACTION     - Action contains "*" (e.g. "*" or "s3:*" or "iam:Put*").
                          Any action wildcard is flagged: "s3:*" still grants
                          every S3 call, including bucket deletion.
  * WILDCARD_RESOURCE   - Resource is over-broad: it is literally "*", or the
                          *resource-id* part of the ARN is a wildcard
                          (e.g. "arn:aws:s3:::*"). A trailing object-key wildcard
                          on a NAMED bucket -- "arn:aws:s3:::my-bucket/*" -- is
                          legitimate least-privilege and is NOT flagged.
  * NOT_ACTION          - statement uses NotAction (allow-all-except: easy to get
                          wrong, grants every *future* action you did not list)
  * NOT_RESOURCE        - statement uses NotResource (same blast-radius problem)

Severity: a statement that is "*"/"*" (full admin) is HIGH; a scoped wildcard
like "s3:*" or "arn:aws:s3:::*" is MEDIUM; NotAction/NotResource are MEDIUM.

Exit codes (CLI):
  0  no findings
  1  one or more findings (use --fail-on to gate a pipeline)
  2  usage / parse error
"""
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict, dataclass


# --- finding model ----------------------------------------------------------

@dataclass(frozen=True)
class Finding:
    """One problem found in one statement."""
    sid: str            # statement id, or "#<index>" if the statement has no Sid
    code: str           # machine code, e.g. "WILDCARD_ACTION"
    severity: str       # "HIGH" | "MEDIUM"
    detail: str         # human-readable explanation incl. the offending value


def _as_list(value) -> list:
    """IAM allows a string OR a list almost everywhere. Normalise to a list.

    Returns [] for None so callers can iterate unconditionally.
    """
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def _has_wildcard(values: list) -> str | None:
    """Return the first value containing a '*' (or '?'), else None.

    '?' is a single-char wildcard in IAM and is just as dangerous in a grant,
    so we treat it the same way. Used for the *Action* axis, where any wildcard
    is worth flagging ("s3:*" still grants every S3 call).
    """
    for v in values:
        if isinstance(v, str) and ("*" in v or "?" in v):
            return v
    return None


def _resource_is_overbroad(resource: str) -> bool:
    """True if an ARN matches *all* resources of its type, not one named thing.

    Over-broad:
      "*"                       -- everything, every service
      "arn:aws:s3:::*"          -- every bucket (resource-id is just "*")
      "arn:aws:iam::123:role/*" -- every role in the account
    NOT over-broad (legitimate least-privilege):
      "arn:aws:s3:::my-bucket"          -- one named bucket
      "arn:aws:s3:::my-bucket/*"        -- objects under one named bucket
      "arn:aws:iam::123:role/app-*"     -- a named prefix of roles

    Rule: an ARN is over-broad when the resource-id segment (everything after the
    5th ':') is exactly "*" OR starts with "*"/"?" (so the *type* of resource is
    unconstrained). A wildcard that appears only *after* some literal characters
    is a scoped pattern and is allowed.
    """
    if resource == "*":
        return True
    # arn:partition:service:region:account:resource-id  -> 6 fields, 5 colons.
    parts = resource.split(":", 5)
    if len(parts) < 6:
        # Not a well-formed ARN; if it contains a bare "*" treat as over-broad.
        return resource.strip() in ("*", "")
    resource_id = parts[5]
    # The resource-id may itself be "type/name" or "type:name". A leading
    # wildcard on the whole id means "any resource of any/every type".
    return resource_id.startswith("*") or resource_id.startswith("?")


def _first_overbroad_resource(values: list) -> str | None:
    """Return the first over-broad Resource string, else None."""
    for v in values:
        if isinstance(v, str) and _resource_is_overbroad(v):
            return v
    return None


# --- pure core --------------------------------------------------------------

def audit_statement(statement: dict, index: int) -> list[Finding]:
    """Audit ONE statement dict. Pure: no I/O. Returns a list of Findings.

    Only `Effect == "Allow"` statements are inspected; a wildcard inside a
    Deny is a guardrail, not a risk.
    """
    findings: list[Finding] = []

    # A statement without an explicit Effect defaults to "Deny" in IAM, but a
    # missing Effect is itself a smell; treat absent as not-Allow (skip).
    if statement.get("Effect") != "Allow":
        return findings

    sid = str(statement.get("Sid") or f"#{index}")

    actions = _as_list(statement.get("Action"))
    resources = _as_list(statement.get("Resource"))
    not_actions = _as_list(statement.get("NotAction"))
    not_resources = _as_list(statement.get("NotResource"))

    # Wildcard Action -- HIGH when it is literally "*", else MEDIUM.
    bad_action = _has_wildcard(actions)
    if bad_action is not None:
        sev = "HIGH" if bad_action == "*" else "MEDIUM"
        findings.append(Finding(
            sid=sid, code="WILDCARD_ACTION", severity=sev,
            detail=f'Allow statement grants wildcard Action "{bad_action}"',
        ))

    # Over-broad Resource -- HIGH when it is literally "*" (all services),
    # else MEDIUM (all resources of one type, e.g. "arn:aws:s3:::*"). A trailing
    # object-key wildcard on a NAMED bucket is least-privilege and not flagged.
    bad_resource = _first_overbroad_resource(resources)
    if bad_resource is not None:
        sev = "HIGH" if bad_resource == "*" else "MEDIUM"
        findings.append(Finding(
            sid=sid, code="WILDCARD_RESOURCE", severity=sev,
            detail=f'Allow statement grants over-broad Resource "{bad_resource}"',
        ))

    # NotAction on an Allow -> "everything except"; grants unlisted/future actions.
    if not_actions:
        findings.append(Finding(
            sid=sid, code="NOT_ACTION", severity="MEDIUM",
            detail=("Allow statement uses NotAction: grants every action EXCEPT "
                    f"{not_actions}, including actions added by AWS in the future"),
        ))

    # NotResource on an Allow -> same blast-radius problem on the resource axis.
    if not_resources:
        findings.append(Finding(
            sid=sid, code="NOT_RESOURCE", severity="MEDIUM",
            detail=("Allow statement uses NotResource: applies to every resource "
                    f"EXCEPT {not_resources}"),
        ))

    return findings


def audit_policy(policy: dict) -> list[Finding]:
    """Audit a whole IAM policy document. Pure: no I/O.

    `policy["Statement"]` may be a single dict or a list of dicts (both are
    valid IAM). Returns findings in statement order.
    """
    statements = policy.get("Statement")
    if statements is None:
        raise ValueError("policy document has no 'Statement' key")
    if isinstance(statements, dict):
        statements = [statements]
    if not isinstance(statements, list):
        raise ValueError("'Statement' must be an object or an array")

    findings: list[Finding] = []
    for i, stmt in enumerate(statements):
        if not isinstance(stmt, dict):
            raise ValueError(f"statement #{i} is not an object")
        findings.extend(audit_statement(stmt, i))
    return findings


# --- CLI --------------------------------------------------------------------

def _load_policy(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def _render_text(findings: list[Finding]) -> str:
    if not findings:
        return "OK: no wildcard or NotAction/NotResource grants found."
    lines = [f"{len(findings)} finding(s):"]
    for f in findings:
        lines.append(f"  [{f.severity}] {f.code} (Sid={f.sid}): {f.detail}")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Flag wildcard / NotAction grants in an IAM policy JSON.")
    parser.add_argument("policy", help="path to an IAM policy document (JSON)")
    parser.add_argument("--json", action="store_true",
                        help="emit findings as JSON instead of text")
    parser.add_argument("--fail-on", choices=["any", "high", "never"],
                        default="any",
                        help="exit non-zero when findings at/above this level "
                             "exist (default: any)")
    args = parser.parse_args(argv)

    try:
        policy = _load_policy(args.policy)
    except FileNotFoundError:
        print(f"error: no such file: {args.policy}", file=sys.stderr)
        return 2
    except json.JSONDecodeError as exc:
        print(f"error: {args.policy} is not valid JSON: {exc}", file=sys.stderr)
        return 2

    try:
        findings = audit_policy(policy)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    if args.json:
        print(json.dumps([asdict(f) for f in findings], indent=2))
    else:
        print(_render_text(findings))

    if args.fail_on == "never":
        return 0
    if args.fail_on == "high":
        return 1 if any(f.severity == "HIGH" for f in findings) else 0
    # "any"
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
