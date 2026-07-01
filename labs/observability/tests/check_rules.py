#!/usr/bin/env python3
"""Semantic linter for multi-window, multi-burn-rate SLO alert files.

`promtool check rules` validates SYNTAX. It happily accepts a single-window alert with a
nonsensical threshold. This checker encodes the SEMANTIC invariants of a correct
multi-window multi-burn-rate alert so the broken/ fixture is actually caught:

  1. The fast-burn (severity: page) and slow-burn (severity: ticket) alerts both exist.
  2. Each burn-rate alert combines TWO windows with `and` (multiwindow), referencing a
     long window and a short window.
  3. The threshold is expressed relative to the error budget (`* 0.001`, i.e. burn_rate
     times the 99.9% budget) — NOT an absolute number like `14.4`, which a fraction can
     never exceed.

Usage:
  python3 tests/check_rules.py FILE [FILE ...]
Exit code 0 if every file passes; non-zero if any file fails (used as a gate). The
broken fixture is expected to FAIL — validate.sh inverts the exit code for it.
"""
import re
import sys

import yaml

# Windows that may legitimately appear as long/short in a burn-rate expression.
LONG_WINDOWS = ("rate1h", "rate6h", "rate3d", "rate2h", "rate1d")
SHORT_WINDOWS = ("rate5m", "rate30m", "rate2h", "rate6h")


def alerts_in(path):
    with open(path) as fh:
        doc = yaml.safe_load(fh)
    for group in (doc or {}).get("groups", []):
        for rule in group.get("rules", []):
            if "alert" in rule:
                yield rule


def check_burn_rate_alert(rule):
    """Return a list of problems for one burn-rate alert (empty list = OK)."""
    problems = []
    name = rule.get("alert", "<unnamed>")
    expr = " ".join(rule.get("expr", "").split())  # collapse whitespace/newlines

    # (2) multiwindow: must combine two windows with `and`.
    if " and " not in expr:
        problems.append(f"{name}: not multi-window — no `and` joining two windows")
    has_long = any(w in expr for w in LONG_WINDOWS)
    has_short = any(w in expr for w in SHORT_WINDOWS)
    if not (has_long and has_short):
        problems.append(
            f"{name}: needs both a long and a short window "
            f"(saw long={has_long}, short={has_short})"
        )

    # (3) threshold must be budget-relative: a `* 0.001` (or 0.0144/0.006 literal) and
    #     NOT a bare integer like `> 14.4` that a [0,1] ratio can never reach.
    budget_relative = ("* 0.001" in expr) or ("0.0144" in expr) or ("0.006" in expr)
    # bare threshold > 1 applied to a ratio series (the classic units bug)
    bare_gt_one = re.search(r">\s*(\d+(?:\.\d+)?)", expr)
    if not budget_relative:
        if bare_gt_one and float(bare_gt_one.group(1)) > 1:
            problems.append(
                f"{name}: threshold `> {bare_gt_one.group(1)}` is an absolute number; "
                f"an error RATIO is in [0,1] and can never exceed it — multiply the "
                f"burn rate by the budget (e.g. 14.4 * 0.001)"
            )
        else:
            problems.append(
                f"{name}: threshold is not expressed relative to the error budget "
                f"(expected `burn_rate * 0.001`)"
            )
    return problems


def check_file(path):
    rules = list(alerts_in(path))
    burn_alerts = [
        r for r in rules
        if "burn" in r.get("alert", "").lower()
        or r.get("labels", {}).get("slo") == "availability"
    ]
    problems = []
    if not burn_alerts:
        problems.append(f"{path}: no burn-rate (availability SLO) alerts found")
    severities = {r.get("labels", {}).get("severity") for r in burn_alerts}
    if "page" not in severities:
        problems.append(f"{path}: missing a `severity: page` fast-burn alert")
    if "ticket" not in severities:
        problems.append(f"{path}: missing a `severity: ticket` slow-burn alert")
    for r in burn_alerts:
        problems.extend(check_burn_rate_alert(r))
    return problems


def main(argv):
    if len(argv) < 2:
        print("usage: check_rules.py FILE [FILE ...]", file=sys.stderr)
        return 2
    any_fail = False
    for path in argv[1:]:
        problems = check_file(path)
        if problems:
            any_fail = True
            print(f"[FAIL] {path}")
            for p in problems:
                print(f"         - {p}")
        else:
            print(f"[PASS] {path}: valid multi-window multi-burn-rate alerts")
    return 1 if any_fail else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
