#!/usr/bin/env python3
"""Cost report: group + total AWS Cost Explorer rows by service.

Pure logic
----------
``summarize`` takes Cost Explorer-shaped rows and returns per-service totals
(sorted by cost, descending) plus a grand total. ``format_table`` renders that
into an aligned, monospaced table. Neither touches AWS, so both are unit-testable
offline.

A Cost Explorer "row" here is the flattened group shape the API gives back inside
``ResultsByTime[].Groups[]``::

    {"Keys": ["Amazon Elastic Compute Cloud - Compute"],
     "Metrics": {"UnblendedCost": {"Amount": "123.45", "Unit": "USD"}}}

The CLI calls ``ce.get_cost_and_usage(... GroupBy=[{Type:DIMENSION,Key:SERVICE}])``
and feeds the resulting groups straight into ``summarize``.

CLI
---
``python cost_report.py --start 2026-06-01 --end 2026-07-01`` would call Cost
Explorer via boto3; that path is isolated and not exercised by offline tests.
"""
from __future__ import annotations

import argparse
import sys
from typing import Iterable, List, Mapping, Sequence

_METRIC = "UnblendedCost"


def parse_row(row: Mapping[str, object]) -> tuple[str, float]:
    """Extract ``(service, amount)`` from one Cost Explorer group row.

    Raises:
        ValueError: if the amount cannot be parsed as a float (corrupt row),
            so a bad API response fails loudly instead of silently scoring $0.
    """
    keys = row.get("Keys") or []
    if not isinstance(keys, Sequence) or not keys:
        raise ValueError(f"row has no Keys: {row!r}")
    service = str(keys[0])

    metrics = row.get("Metrics")
    if not isinstance(metrics, Mapping) or _METRIC not in metrics:
        raise ValueError(f"row {service!r} missing {_METRIC} metric")
    amount_raw = metrics[_METRIC].get("Amount")  # type: ignore[union-attr]
    try:
        amount = float(amount_raw)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"row {service!r} has non-numeric amount {amount_raw!r}") from exc
    return service, amount


def summarize(rows: Iterable[Mapping[str, object]]) -> dict:
    """Group rows by service and total them.

    The same service can appear more than once (e.g. one group per day across a
    multi-day window), so amounts are accumulated, not overwritten.

    Returns:
        ``{"services": [{"service", "amount"}...sorted desc],
           "total": <grand total float>}``
    """
    totals: dict[str, float] = {}
    for row in rows:
        service, amount = parse_row(row)
        totals[service] = totals.get(service, 0.0) + amount

    # Sort by cost desc, then name asc for stable ties.
    ordered = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    services = [{"service": s, "amount": round(a, 2)} for s, a in ordered]
    grand = round(sum(totals.values()), 2)
    return {"services": services, "total": grand}


def format_table(summary: Mapping[str, object], currency: str = "USD") -> str:
    """Render a summary from :func:`summarize` as an aligned text table."""
    services: List[Mapping[str, object]] = list(summary.get("services", []))  # type: ignore[arg-type]
    total = float(summary.get("total", 0.0))  # type: ignore[arg-type]

    if not services:
        return "No cost data for the selected period."

    name_w = max(len("SERVICE"), *(len(str(s["service"])) for s in services))
    amount_strs = {id(s): f"{float(s['amount']):,.2f}" for s in services}
    amount_w = max(
        len(f"COST ({currency})"),
        len(f"{total:,.2f}"),
        *(len(v) for v in amount_strs.values()),
    )

    sep = f"+-{'-' * name_w}-+-{'-' * amount_w}-+"
    header = f"| {'SERVICE':<{name_w}} | {'COST (' + currency + ')':>{amount_w}} |"
    lines = [sep, header, sep]
    for s in services:
        lines.append(
            f"| {str(s['service']):<{name_w}} | {amount_strs[id(s)]:>{amount_w}} |"
        )
    lines.append(sep)
    lines.append(f"| {'TOTAL':<{name_w}} | {f'{total:,.2f}':>{amount_w}} |")
    lines.append(sep)
    return "\n".join(lines)


# --------------------------------------------------------------------------- #
# CLI / live AWS path (needs boto3 + Cost Explorer; not in the offline tests).
# --------------------------------------------------------------------------- #
def _fetch_cost_rows(start: str, end: str, profile: str | None) -> list:
    """Pull SERVICE-grouped unblended cost for ``[start, end)`` from Cost Explorer.

    Cost Explorer is a global endpoint pinned to us-east-1. Imported lazily so
    tests and py_compile never need boto3.
    """
    from lib.awsclient import get_client

    ce = get_client("ce", profile=profile, region="us-east-1")
    rows: list = []
    next_token: str | None = None
    while True:
        kwargs = {
            "TimePeriod": {"Start": start, "End": end},
            "Granularity": "MONTHLY",
            "Metrics": [_METRIC],
            "GroupBy": [{"Type": "DIMENSION", "Key": "SERVICE"}],
        }
        if next_token:
            kwargs["NextPageToken"] = next_token
        resp = ce.get_cost_and_usage(**kwargs)
        for block in resp.get("ResultsByTime", []):
            rows.extend(block.get("Groups", []))
        next_token = resp.get("NextPageToken")
        if not next_token:
            break
    return rows


def _parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Summarize AWS cost by service.")
    parser.add_argument("--start", required=True, help="Inclusive start date YYYY-MM-DD")
    parser.add_argument("--end", required=True, help="Exclusive end date YYYY-MM-DD")
    parser.add_argument("--profile", default=None)
    return parser.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    args = _parse_args(argv)
    rows = _fetch_cost_rows(args.start, args.end, args.profile)
    summary = summarize(rows)
    print(format_table(summary))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
