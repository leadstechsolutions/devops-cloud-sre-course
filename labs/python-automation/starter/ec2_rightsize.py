#!/usr/bin/env python3
"""EC2 right-sizing recommendation.

Pure logic
----------
``recommend`` takes CPU and memory utilization samples (lists of percentages,
0-100) for one instance and returns one of ``"smaller"``, ``"keep"`` or
``"larger"`` based on configurable thresholds. No CloudWatch calls happen in the
decision logic, so it is unit-testable offline.

Decision rule (using the *peak* of each metric, because right-sizing on the
average hides spikes and causes throttling/OOM after you downsize):

* ``larger``  if peak CPU >= ``high`` OR peak memory >= ``high``  (something is hot)
* ``smaller`` if peak CPU <  ``low``  AND peak memory <  ``low``   (everything cold)
* ``keep``    otherwise

CLI
---
``python ec2_rightsize.py`` would pull CloudWatch metrics via boto3; that path is
isolated in ``_fetch_utilization`` and not exercised by the offline tests.
"""
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from typing import Sequence

# Defaults: downsize when peak < 20% on both, upsize when peak >= 80% on either.
DEFAULT_LOW = 20.0
DEFAULT_HIGH = 80.0

SMALLER = "smaller"
KEEP = "keep"
LARGER = "larger"


@dataclass(frozen=True)
class Thresholds:
    """Right-sizing thresholds, expressed as utilization percentages (0-100)."""

    low: float = DEFAULT_LOW
    high: float = DEFAULT_HIGH

    def __post_init__(self) -> None:
        if not (0 <= self.low < self.high <= 100):
            raise ValueError(
                f"thresholds must satisfy 0 <= low < high <= 100; "
                f"got low={self.low}, high={self.high}"
            )


def _peak(samples: Sequence[float]) -> float:
    """Return the maximum of a non-empty sample list.

    Raises on empty input: a recommendation with no data would be a silent lie,
    so we force the caller to handle "no metrics" explicitly.
    """
    if not samples:
        raise ValueError("utilization sample list is empty; cannot recommend")
    return max(samples)


def recommend(
    cpu_samples: Sequence[float],
    mem_samples: Sequence[float],
    thresholds: Thresholds | None = None,
) -> str:
    """Recommend ``smaller`` / ``keep`` / ``larger`` for one instance.

    Args:
        cpu_samples: CPU-utilization percentages over the observation window.
        mem_samples: Memory-utilization percentages over the same window.
        thresholds: Low/high cut-offs; defaults to 20/80.

    Returns:
        One of :data:`SMALLER`, :data:`KEEP`, :data:`LARGER`.
    """
    t = thresholds or Thresholds()
    cpu_peak = _peak(cpu_samples)
    mem_peak = _peak(mem_samples)

    # TODO(student): Implement the right-sizing decision using PEAK values and the
    # thresholds in `t` (t.low, t.high). The rules, in order:
    #   1. return LARGER  if either peak is >= t.high   (something is hot)
    #   2. return SMALLER if BOTH peaks are <  t.low     (everything is cold)
    #   3. otherwise return KEEP
    # Watch the boundaries: `>=` for high (inclusive), `<` for low (strict). The
    # tests pin both edges (peak == 80 -> LARGER, peak == 20 -> KEEP).
    raise NotImplementedError("implement recommend() decision rule")


def recommend_fleet(
    instances: Sequence[dict],
    thresholds: Thresholds | None = None,
) -> list[dict]:
    """Apply :func:`recommend` across a fleet.

    Each input dict needs ``id``, ``cpu`` (list), ``mem`` (list). Returns a list
    of ``{"id", "action", "cpu_peak", "mem_peak"}`` records preserving input order.
    """
    t = thresholds or Thresholds()
    out: list[dict] = []
    for inst in instances:
        action = recommend(inst["cpu"], inst["mem"], t)
        out.append(
            {
                "id": inst["id"],
                "action": action,
                "cpu_peak": _peak(inst["cpu"]),
                "mem_peak": _peak(inst["mem"]),
            }
        )
    return out


# --------------------------------------------------------------------------- #
# CLI / live AWS path (needs boto3 + CloudWatch; not in the offline tests).
# --------------------------------------------------------------------------- #
def _fetch_utilization(instance_id: str, region: str, profile: str | None) -> dict:
    """Pull CPU + memory utilization for an instance from CloudWatch.

    Memory is not a default EC2 metric; it requires the CloudWatch agent, so the
    mem list may be empty on instances without it. Imported lazily so tests and
    py_compile never need boto3.
    """
    from datetime import datetime, timedelta, timezone

    from lib.awsclient import get_client

    cw = get_client("cloudwatch", profile=profile, region=region)
    end = datetime.now(timezone.utc)
    start = end - timedelta(days=14)

    def _series(namespace: str, metric: str) -> list[float]:
        resp = cw.get_metric_statistics(
            Namespace=namespace,
            MetricName=metric,
            Dimensions=[{"Name": "InstanceId", "Value": instance_id}],
            StartTime=start,
            EndTime=end,
            Period=3600,
            Statistics=["Average"],
        )
        return [pt["Average"] for pt in resp.get("Datapoints", [])]

    return {
        "id": instance_id,
        "cpu": _series("AWS/EC2", "CPUUtilization"),
        "mem": _series("CWAgent", "mem_used_percent"),
    }


def _parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Recommend EC2 right-sizing actions.")
    parser.add_argument("instance_ids", nargs="+", help="EC2 instance IDs")
    parser.add_argument("--region", default="us-east-1")
    parser.add_argument("--profile", default=None)
    parser.add_argument("--low", type=float, default=DEFAULT_LOW)
    parser.add_argument("--high", type=float, default=DEFAULT_HIGH)
    parser.add_argument("--json", action="store_true")
    return parser.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    args = _parse_args(argv)
    thresholds = Thresholds(low=args.low, high=args.high)
    instances = [_fetch_utilization(i, args.region, args.profile) for i in args.instance_ids]
    results = recommend_fleet(instances, thresholds)
    if args.json:
        print(json.dumps(results, indent=2))
    else:
        for r in results:
            print(
                f"{r['id']}: {r['action']:<7} "
                f"(cpu_peak={r['cpu_peak']:.1f}%, mem_peak={r['mem_peak']:.1f}%)"
            )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
