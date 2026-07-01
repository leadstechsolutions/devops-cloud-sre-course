#!/usr/bin/env python3
"""Convert an availability target ("how many nines") into allowed downtime.

Pure logic
----------
Given an availability target as a fraction (``0.999`` == 99.9% == "three
nines"), compute the maximum downtime you can have over a period and still meet
the SLO::

    allowed_downtime = (1 - target) * period

This is the inverse framing of an error budget: the error budget is a *time*
budget when your SLI is uptime. The functions return downtime in seconds and a
human-readable string for the standard reporting periods (30 days and 365
days), plus an arbitrary-period helper.

No I/O, no clock, no network -> deterministic and unit-testable offline.

CLI
---
``python nines_downtime.py --target 0.999``
``python nines_downtime.py --target 0.9999 --json``
"""
from __future__ import annotations

import argparse
import json
import sys
from typing import Sequence

SECONDS_PER_MINUTE = 60
SECONDS_PER_HOUR = 3600
SECONDS_PER_DAY = 86_400
# Reporting periods. 30-day is the rolling SLO window; 365-day is the annual view.
PERIOD_30D_SECONDS = 30 * SECONDS_PER_DAY      # 2_592_000
PERIOD_YEAR_SECONDS = 365 * SECONDS_PER_DAY    # 31_536_000


def allowed_downtime_seconds(target: float, period_seconds: float) -> float:
    """Allowed downtime in seconds for ``target`` availability over a period.

    Args:
        target: availability as a fraction in ``[0, 1)`` (0.999 == 99.9%).
        period_seconds: length of the reporting period in seconds (> 0).

    Raises:
        ValueError: if ``target`` is out of ``[0, 1)`` or ``period_seconds <= 0``.
    """
    if not (0.0 <= target < 1.0):
        raise ValueError(f"target must be in [0, 1), got {target!r}")
    if period_seconds <= 0:
        raise ValueError(f"period_seconds must be > 0, got {period_seconds!r}")
    return (1.0 - target) * period_seconds


def humanize_seconds(seconds: float) -> str:
    """Render a non-negative duration as 'Xd Yh Zm Ws', dropping zero leaders.

    Examples: ``0`` -> '0s'; ``90`` -> '1m 30s'; ``93784`` -> '1d 2h 3m 4s'.
    Sub-second remainders are rounded to whole seconds.
    """
    if seconds < 0:
        raise ValueError(f"seconds must be >= 0, got {seconds!r}")
    total = int(round(seconds))
    days, rem = divmod(total, SECONDS_PER_DAY)
    hours, rem = divmod(rem, SECONDS_PER_HOUR)
    minutes, secs = divmod(rem, SECONDS_PER_MINUTE)
    parts = []
    if days:
        parts.append(f"{days}d")
    if hours:
        parts.append(f"{hours}h")
    if minutes:
        parts.append(f"{minutes}m")
    # Always show seconds when nothing larger printed, or when there is a remainder.
    if secs or not parts:
        parts.append(f"{secs}s")
    return " ".join(parts)


def downtime_budget(target: float) -> dict:
    """Allowed downtime for the standard reporting periods.

    Returns a dict with ``target``, ``nines`` (a label like ``"three nines"``),
    and per-period ``seconds`` + ``human`` for 30 days and 365 days.
    """
    per_30d = allowed_downtime_seconds(target, PERIOD_30D_SECONDS)
    per_year = allowed_downtime_seconds(target, PERIOD_YEAR_SECONDS)
    return {
        "target": target,
        "target_pct": round(target * 100, 6),
        "nines": nines_label(target),
        "per_30d": {"seconds": per_30d, "human": humanize_seconds(per_30d)},
        "per_year": {"seconds": per_year, "human": humanize_seconds(per_year)},
    }


def nines_label(target: float) -> str:
    """Approximate 'N nines' label for common targets; '' if not a clean nines value.

    Recognises 90% .. 99.9999% (one through six nines). Mixed targets such as
    99.95% return '' because they are not a whole number of nines.
    """
    words = {1: "one nine", 2: "two nines", 3: "three nines",
             4: "four nines", 5: "five nines", 6: "six nines"}
    for n in range(1, 7):
        # n nines == 1 - 10**(-n): 0.9, 0.99, 0.999, ...
        if abs(target - (1.0 - 10 ** (-n))) < 1e-12:
            return words[n]
    return ""


def format_report(budget: dict) -> str:
    """Render :func:`downtime_budget` output as an aligned text block."""
    nines = budget["nines"]
    nines_suffix = f"  ({nines})" if nines else ""
    return "\n".join([
        f"Availability target  : {budget['target_pct']:g}%{nines_suffix}",
        f"Allowed downtime/30d : {budget['per_30d']['human']}",
        f"Allowed downtime/year: {budget['per_year']['human']}",
    ])


def _parse_args(argv: Sequence[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Convert an availability target into allowed downtime per 30d/year."
    )
    p.add_argument("--target", type=float, required=True,
                   help="availability target as a fraction, e.g. 0.999 for 99.9%%")
    p.add_argument("--json", action="store_true",
                   help="emit the budget as JSON instead of a table")
    return p.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    args = _parse_args(argv)
    try:
        budget = downtime_budget(args.target)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(budget, indent=2))
    else:
        print(format_report(budget))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
