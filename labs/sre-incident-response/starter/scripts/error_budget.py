#!/usr/bin/env python3
"""Error-budget math for an SLO, over a measurement window.

STARTER: this file is intentionally incomplete. Search for `TODO(student)` and
fill in the burn-rate / time-to-exhaustion math. The unit tests in ../tests will
fail until you do. Check yourself against ../../solution/scripts/error_budget.py.

Pure logic
----------
Given an SLO target (e.g. ``0.999``) and observed ``good``/``total`` event
counts over a window, this computes:

* ``error_budget`` -- the failures you are allowed to spend, in events and as a
  fraction of total (``1 - target``).
* ``budget_remaining`` -- how much of that allowance is left, as a fraction
  (``1.0`` = untouched, ``0.0`` = exhausted, negative = blown).
* ``burn_rate`` -- how fast you are spending budget relative to "even" spend.
  ``1.0`` means you will exhaust the budget exactly at the end of the window;
  ``> 1.0`` means faster (e.g. ``14.4`` is the classic 1h fast-burn page
  threshold for a 30-day window); ``0`` means no errors at all.
* ``time_to_exhaustion`` -- at the *current* burn rate, how long until the
  remaining budget hits zero, expressed in hours over the window.

All of this is arithmetic on counts: no Prometheus, no network, no clock. That
makes every function deterministic and unit-testable offline. The CLI layer
parses args and prints a report; it imports nothing beyond the stdlib.

Definitions (matching Google SRE workbook conventions)
------------------------------------------------------
Let ``target`` be the SLO objective as a fraction in ``[0, 1)`` and let
``total`` and ``good`` be event counts over the window, ``bad = total - good``.

* allowed error fraction         = ``1 - target``                  (the budget)
* allowed bad events             = ``(1 - target) * total``
* observed error fraction (SLI complement) = ``bad / total``
* budget consumed (fraction)     = ``observed_error / allowed_error``
* budget remaining (fraction)    = ``1 - budget_consumed``
* burn rate                      = ``observed_error / allowed_error``
  (burn rate and "budget consumed so far" share the same ratio because, over a
  full window, spending the whole budget == burning at 1x for the whole window.)

CLI
---
``python error_budget.py --target 0.999 --good 998500 --total 1000000``
``python error_budget.py --target 0.995 --good 9900 --total 10000 --window-hours 720``
"""
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict, dataclass
from typing import Sequence

# A 30-day window in hours: the default SLO window in this lab. 30 * 24 = 720.
DEFAULT_WINDOW_HOURS = 30 * 24


@dataclass(frozen=True)
class BudgetReport:
    """The full error-budget picture for one window. All fractions, not %."""

    target: float
    good: int
    total: int
    bad: int
    allowed_error_fraction: float   # 1 - target
    allowed_bad_events: float       # (1 - target) * total
    observed_error_fraction: float  # bad / total
    budget_consumed: float          # observed_error / allowed_error
    budget_remaining: float         # 1 - budget_consumed
    burn_rate: float                # observed_error / allowed_error
    window_hours: float
    time_to_exhaustion_hours: float | None  # None == "never" (burn_rate == 0)


def _validate(target: float, good: int, total: int, window_hours: float) -> None:
    if not (0.0 <= target < 1.0):
        raise ValueError(f"target must be in [0, 1), got {target!r}")
    if total <= 0:
        raise ValueError(f"total must be > 0, got {total!r}")
    if good < 0:
        raise ValueError(f"good must be >= 0, got {good!r}")
    if good > total:
        raise ValueError(f"good ({good}) cannot exceed total ({total})")
    if window_hours <= 0:
        raise ValueError(f"window_hours must be > 0, got {window_hours!r}")


def burn_rate(target: float, good: int, total: int) -> float:
    """Return the error-budget burn rate (dimensionless multiple).

    ``burn_rate = observed_error_fraction / allowed_error_fraction``.

    * ``1.0`` -> spending budget exactly as fast as allowed; the budget lasts the
      whole window.
    * ``> 1.0`` -> spending faster than allowed (``14.4`` is the canonical
      fast-burn page threshold for a 30-day budget measured over 1h).
    * ``0.0`` -> no errors observed; nothing is being spent.

    Raises:
        ValueError: on out-of-range inputs (see :func:`_validate`).
    """
    _validate(target, good, total, DEFAULT_WINDOW_HOURS)
    allowed_error = 1.0 - target
    observed_error = (total - good) / total
    if allowed_error == 0.0:
        # target == 1.0 is rejected by _validate, so this is unreachable; kept
        # as a guard so the math never divides by zero.
        raise ValueError("target of 1.0 (100%) leaves a zero error budget")
    # TODO(student): return the burn rate.
    #   burn_rate = observed_error_fraction / allowed_error_fraction
    #   i.e. how the observed error rate compares to the budgeted error rate.
    #   The variables `observed_error` and `allowed_error` above are what you need.
    #   Expected: burn_rate(0.999, 999_000, 1_000_000) == 1.0  (spending the budget at 1x)
    #             burn_rate(0.999, 1_000_000, 1_000_000) == 0.0 (no errors)
    raise NotImplementedError("burn_rate: compute observed_error / allowed_error")


def time_to_exhaustion_hours(
    budget_remaining: float, rate: float, window_hours: float
) -> float | None:
    """Hours until the remaining budget reaches zero at the current burn rate.

    At burn rate ``r``, the *entire* budget is consumed in ``window_hours / r``
    (burning at 1x consumes it in exactly one window). With ``budget_remaining``
    of the budget left, time left is ``budget_remaining * window_hours / r``.

    Returns ``None`` when ``rate <= 0`` (no burn -> never exhausts) or when the
    budget is already exhausted (``budget_remaining <= 0`` -> 0.0).
    """
    if budget_remaining <= 0.0:
        return 0.0
    if rate <= 0.0:
        return None  # not burning; budget never runs out
    # TODO(student): return the hours until the remaining budget hits zero.
    #   At burn rate `rate`, the WHOLE budget is consumed in `window_hours / rate`.
    #   You have `budget_remaining` (a fraction) of the budget left, so scale by it.
    #   Expected: time_to_exhaustion_hours(0.5, 0.5, 720) == 720.0
    #             time_to_exhaustion_hours(1.0, 2.0, 720) == 360.0
    raise NotImplementedError("time_to_exhaustion_hours: budget_remaining * window_hours / rate")


def compute(
    target: float,
    good: int,
    total: int,
    window_hours: float = DEFAULT_WINDOW_HOURS,
) -> BudgetReport:
    """Compute the full :class:`BudgetReport` for one window.

    Args:
        target: SLO objective as a fraction in ``[0, 1)`` (0.999 == 99.9%).
        good: count of good events in the window.
        total: count of total events in the window (> 0).
        window_hours: length of the SLO window in hours (default 720 = 30d).

    Raises:
        ValueError: on out-of-range inputs.
    """
    _validate(target, good, total, window_hours)
    bad = total - good
    allowed_error = 1.0 - target
    allowed_bad = allowed_error * total
    observed_error = bad / total
    # TODO(student): fill in the three lines below.
    #   consumed  = fraction of the error budget used so far  (observed/allowed)
    #   remaining = 1.0 - consumed
    #   rate      = the burn rate (reuse your burn_rate(...) function, or the same
    #               observed/allowed ratio). Then time_to_exhaustion_hours wires it up.
    #   Expected: compute(0.999, 999_500, 1_000_000) -> remaining 0.5, burn_rate 0.5,
    #             time_to_exhaustion_hours 720.0
    consumed = None   # TODO(student): observed_error / allowed_error
    remaining = None  # TODO(student): 1.0 - consumed
    rate = None       # TODO(student): observed_error / allowed_error
    tte = time_to_exhaustion_hours(remaining, rate, window_hours)
    return BudgetReport(
        target=target,
        good=good,
        total=total,
        bad=bad,
        allowed_error_fraction=allowed_error,
        allowed_bad_events=allowed_bad,
        observed_error_fraction=observed_error,
        budget_consumed=consumed,
        budget_remaining=remaining,
        burn_rate=rate,
        window_hours=window_hours,
        time_to_exhaustion_hours=tte,
    )


def _fmt_hours(hours: float | None) -> str:
    """Human-readable duration: 'never', '0h0m', '13h12m', or '4d 3h'."""
    if hours is None:
        return "never (no errors)"
    if hours <= 0:
        return "0h (exhausted)"
    days, rem = divmod(hours, 24)
    h, frac = divmod(rem, 1)
    minutes = round(frac * 60)
    if days >= 1:
        return f"{int(days)}d {int(h)}h{minutes:02d}m"
    return f"{int(h)}h{minutes:02d}m"


def status_for(r: BudgetReport) -> str:
    """Coarse health label driven by how much budget is left in the window.

    Over a *full* SLO window (the framing this lab uses, where good/total cover
    the whole window) burn rate > 1.0 is exactly equivalent to having spent the
    whole budget, so status keys off ``budget_remaining``:

    * ``EXHAUSTED``  -- no budget left (<= 0): freeze risky changes.
    * ``AT RISK``    -- under 25% left: slow down, review the burn.
    * ``HEALTHY``    -- 25% or more left.
    """
    if r.budget_remaining <= 0.0:
        return "EXHAUSTED"
    if r.budget_remaining < 0.25:
        return "AT RISK"
    return "HEALTHY"


def format_report(r: BudgetReport) -> str:
    """Render a :class:`BudgetReport` as an aligned human-readable block."""
    remaining_pct = r.budget_remaining * 100.0
    consumed_pct = r.budget_consumed * 100.0
    status = status_for(r)
    lines = [
        f"SLO target           : {r.target * 100:.4g}%",
        f"Window               : {r.window_hours:.0f}h",
        f"Events good/total    : {r.good:,} / {r.total:,}  (bad: {r.bad:,})",
        f"Allowed bad events   : {r.allowed_bad_events:,.1f}",
        f"Error budget         : {r.allowed_error_fraction * 100:.4g}% of requests",
        f"Budget consumed      : {consumed_pct:.2f}%",
        f"Budget remaining     : {remaining_pct:.2f}%",
        f"Burn rate            : {r.burn_rate:.2f}x",
        f"Time to exhaustion   : {_fmt_hours(r.time_to_exhaustion_hours)}",
        f"Status               : {status}",
    ]
    return "\n".join(lines)


def _parse_args(argv: Sequence[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Compute error budget remaining, burn rate, and time to exhaustion."
    )
    p.add_argument("--target", type=float, required=True,
                   help="SLO target as a fraction, e.g. 0.999 for 99.9%%")
    p.add_argument("--good", type=int, required=True,
                   help="count of good (successful) events in the window")
    p.add_argument("--total", type=int, required=True,
                   help="count of total events in the window")
    p.add_argument("--window-hours", type=float, default=DEFAULT_WINDOW_HOURS,
                   help="SLO window length in hours (default 720 = 30 days)")
    p.add_argument("--json", action="store_true",
                   help="emit the full report as JSON instead of a table")
    return p.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    args = _parse_args(argv)
    try:
        report = compute(args.target, args.good, args.total, args.window_hours)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(asdict(report), indent=2))
    else:
        print(format_report(report))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
