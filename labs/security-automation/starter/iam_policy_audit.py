#!/usr/bin/env python3
"""Audit an AWS IAM policy document for over-broad (wildcard) grants.

STARTER -- this file is intentionally incomplete. Fill in every
`# TODO(student): ...` block so the tests under ../tests/ pass:

    cd ..                      # module root: labs/security-automation
    PYTHONPATH=starter python3 -m unittest discover -s tests   # should FAIL now

When you are done, the same command should report OK, and:

    PYTHONPATH=solution python3 -m unittest discover -s tests   # the reference

should also pass. Compare against solution/iam_policy_audit.py only after you
have tried.

Pure-function core (`audit_policy`) + a thin CLI (`main`). No boto3, no network.

What it must flag (only on Allow statements -- a wildcard inside a Deny is a
broad guardrail, not a risk, so do NOT flag those):

  * WILDCARD_ACTION     - Action contains "*" (e.g. "*" or "s3:*"). ANY action
                          wildcard is flagged.
  * WILDCARD_RESOURCE   - Resource is over-broad: "*", or the resource-id part of
                          the ARN is a wildcard (e.g. "arn:aws:s3:::*"). A
                          trailing object-key wildcard on a NAMED bucket
                          ("arn:aws:s3:::my-bucket/*") is least-privilege and is
                          NOT flagged.
  * NOT_ACTION          - statement uses NotAction
  * NOT_RESOURCE        - statement uses NotResource

Severity: literal "*" -> HIGH; a scoped wildcard like "s3:*" or
"arn:aws:s3:::*" -> MEDIUM; NotAction/NotResource -> MEDIUM.
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
    sid: str
    code: str
    severity: str
    detail: str


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
    """Return the first value containing a '*' or '?' wildcard, else None.

    Both '*' (multi-char) and '?' (single-char) are IAM wildcards and are
    equally dangerous inside an Action grant.
    """
    # TODO(student): iterate `values`; return the first item that is a str AND
    # contains '*' or '?'. Return None if none match. (3-4 lines.)
    raise NotImplementedError("complete _has_wildcard")


def _resource_is_overbroad(resource: str) -> bool:
    """True if an ARN matches *all* resources of its type, not one named thing.

    Over-broad:  "*", "arn:aws:s3:::*", "arn:aws:iam::123:role/*"
    Scoped (OK): "arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"

    Rule: over-broad when `resource == "*"`, OR the resource-id segment
    (everything after the 5th ':') is exactly "*" / starts with "*" or "?".
    A wildcard appearing only AFTER literal characters is a scoped pattern.
    """
    if resource == "*":
        return True
    # TODO(student): split the ARN on ':' into at most 6 fields
    # (arn:partition:service:region:account:resource-id). If there are fewer
    # than 6 fields it is not a normal ARN -> treat a bare "*"/"" as over-broad,
    # else not. Otherwise take field[5] (the resource-id) and return True when it
    # startswith "*" or "?".  (~5 lines.)
    raise NotImplementedError("complete _resource_is_overbroad")


def _first_overbroad_resource(values: list) -> str | None:
    """Return the first over-broad Resource string, else None."""
    for v in values:
        if isinstance(v, str) and _resource_is_overbroad(v):
            return v
    return None


# --- pure core --------------------------------------------------------------

def audit_statement(statement: dict, index: int) -> list[Finding]:
    """Audit ONE statement dict. Pure: no I/O. Returns a list of Findings.

    Only Effect == "Allow" statements are inspected.
    """
    findings: list[Finding] = []

    if statement.get("Effect") != "Allow":
        return findings

    sid = str(statement.get("Sid") or f"#{index}")

    actions = _as_list(statement.get("Action"))
    resources = _as_list(statement.get("Resource"))
    not_actions = _as_list(statement.get("NotAction"))
    not_resources = _as_list(statement.get("NotResource"))

    # TODO(student): wildcard Action.
    # Use _has_wildcard(actions). If it returns a value, append a Finding with
    # code="WILDCARD_ACTION". Severity is "HIGH" when the offending value is
    # exactly "*", otherwise "MEDIUM". Detail text should name the offending value.

    # TODO(student): over-broad Resource.
    # Use _first_overbroad_resource(resources). If it returns a value, append a
    # Finding with code="WILDCARD_RESOURCE". Severity is "HIGH" when the value is
    # exactly "*", otherwise "MEDIUM".

    # NotAction on an Allow -> grants everything except the listed actions.
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

    `policy["Statement"]` may be a single dict or a list of dicts.
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
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
