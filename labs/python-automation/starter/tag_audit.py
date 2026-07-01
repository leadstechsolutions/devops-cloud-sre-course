#!/usr/bin/env python3
"""Tag-compliance audit.

Pure logic
----------
``audit_resources`` takes a list of already-fetched resource dicts and a set of
required tag keys and returns the resources that are missing one or more required
tags. No AWS calls happen here, so it is fully unit-testable offline.

A resource dict looks like::

    {"id": "i-0abc", "type": "ec2:instance",
     "tags": {"Name": "web-1", "Owner": "team-x"}}

The ``tags`` value is a plain ``{key: value}`` mapping. The CLI normalizes the
AWS API's ``[{"Key": ..., "Value": ...}]`` shape into that mapping before calling
the pure function (see ``normalize_tag_list``).

CLI
---
``python tag_audit.py --required Owner CostCenter Environment`` lists every EC2
instance missing any of those tags. The live path needs boto3; the audit logic
does not.
"""
from __future__ import annotations

import argparse
import json
import sys
from typing import Dict, Iterable, List, Mapping, Sequence

# A tag value of "" (empty string) counts as MISSING: AWS lets you create a tag
# with an empty value, which usually means someone wired up automation wrong.
_EMPTY_TAG_VALUES = {"", None}


def normalize_tag_list(tag_list: Iterable[Mapping[str, str]]) -> Dict[str, str]:
    """Convert AWS ``[{"Key": k, "Value": v}, ...]`` into ``{k: v}``.

    Boto3 returns tags as a list of ``{"Key", "Value"}`` dicts. The pure audit
    logic works on a flat mapping, so the CLI calls this first. Kept as a
    separate, testable function rather than inline in the CLI.
    """
    out: Dict[str, str] = {}
    for entry in tag_list:
        key = entry.get("Key")
        if key is None:
            continue
        out[key] = entry.get("Value", "")
    return out


def missing_tags(resource: Mapping[str, object], required: Sequence[str]) -> List[str]:
    """Return the sorted list of required tag keys absent (or empty) on a resource.

    A key counts as missing when it is not present at all OR its value is empty
    (``""``/``None``). The return is sorted for stable, diff-friendly output.
    """
    tags = resource.get("tags") or {}
    if not isinstance(tags, Mapping):
        raise TypeError(
            f"resource {resource.get('id')!r} has non-mapping tags: {type(tags).__name__}"
        )
    # TODO(student): Build `missing` -- the list of keys from `required` that are
    # either absent from `tags` OR present but with an empty value. A tag whose
    # value is in `_EMPTY_TAG_VALUES` ({"", None}) counts as MISSING. Return the
    # result sorted() so output is stable and diff-friendly.
    #   Hint: a single list comprehension over `required` reads cleanly here.
    missing: List[str] = []  # replace this stub
    return sorted(missing)


def audit_resources(
    resources: Iterable[Mapping[str, object]],
    required: Sequence[str],
) -> List[Dict[str, object]]:
    """Return one record per resource that is missing required tags.

    Each record is ``{"id", "type", "missing": [keys...]}``. Compliant resources
    are omitted, so an empty result means "everything is compliant". The order of
    the input is preserved.
    """
    if not required:
        raise ValueError("`required` must list at least one tag key")
    findings: List[Dict[str, object]] = []
    for resource in resources:
        gaps = missing_tags(resource, required)
        if gaps:
            findings.append(
                {
                    "id": resource.get("id", "<unknown>"),
                    "type": resource.get("type", "<unknown>"),
                    "missing": gaps,
                }
            )
    return findings


def format_report(findings: Sequence[Mapping[str, object]]) -> str:
    """Render audit findings as a human-readable text block."""
    if not findings:
        return "OK: all resources carry the required tags."
    lines = [f"NON-COMPLIANT: {len(findings)} resource(s) missing required tags", ""]
    for record in findings:
        missing = ", ".join(record["missing"])  # type: ignore[arg-type]
        lines.append(f"  {record['id']} ({record['type']}): missing {missing}")
    return "\n".join(lines)


# --------------------------------------------------------------------------- #
# CLI / live AWS path (needs boto3; not exercised by the offline unit tests).
# --------------------------------------------------------------------------- #
def _fetch_ec2_resources(region: str, profile: str | None) -> List[Dict[str, object]]:
    """Fetch EC2 instances and shape them into audit-ready resource dicts.

    Imported lazily so ``python3 -m py_compile`` and the unit tests never require
    boto3.
    """
    from lib.awsclient import get_client, paginate  # local import on purpose

    ec2 = get_client("ec2", profile=profile, region=region)
    reservations = paginate(ec2, "describe_instances", "Reservations")
    resources: List[Dict[str, object]] = []
    for reservation in reservations:
        for instance in reservation.get("Instances", []):
            resources.append(
                {
                    "id": instance["InstanceId"],
                    "type": "ec2:instance",
                    "tags": normalize_tag_list(instance.get("Tags", [])),
                }
            )
    return resources


def _parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit EC2 instances for required tags.")
    parser.add_argument(
        "--required",
        nargs="+",
        required=True,
        metavar="TAG",
        help="Required tag keys, e.g. --required Owner CostCenter Environment",
    )
    parser.add_argument("--region", default="us-east-1", help="AWS region")
    parser.add_argument("--profile", default=None, help="AWS named profile")
    parser.add_argument(
        "--json", action="store_true", help="Emit findings as JSON instead of text"
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    args = _parse_args(argv)
    resources = _fetch_ec2_resources(args.region, args.profile)
    findings = audit_resources(resources, args.required)
    if args.json:
        print(json.dumps(findings, indent=2))
    else:
        print(format_report(findings))
    # Non-zero exit on non-compliance so CI/cron can gate on it.
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
