#!/usr/bin/env python3
"""Drive synthetic traffic at sample-api so its RED metrics populate.

Used by run-demo.sh after the stack is up: it hits the app through the
port-forward, mixing good, slow, and error requests so that
  * http_requests_total grows (rate > 0),
  * a measurable fraction are 5xx (error ratio > 0),
  * latency buckets fill (p99 > p50).
Pure standard library so it runs anywhere python3 does.

Usage:  python3 scripts/loadgen.py --base-url http://127.0.0.1:8000 \
            --requests 600 --error-frac 0.10 --slow-frac 0.05
"""
from __future__ import annotations

import argparse
import sys
import time
import urllib.error
import urllib.request
from collections import Counter


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-url", default="http://127.0.0.1:8000")
    ap.add_argument("--requests", type=int, default=600)
    ap.add_argument("--error-frac", type=float, default=0.10)
    ap.add_argument("--slow-frac", type=float, default=0.05)
    ap.add_argument("--timeout", type=float, default=5.0)
    ap.add_argument(
        "--duration",
        type=float,
        default=0.0,
        help="if >0, spread the requests evenly over this many seconds so the "
        "counter INCREASES across multiple scrapes (rate()/rate over [5m] needs "
        "the increase spread across the window, not delivered in one burst).",
    )
    args = ap.parse_args()

    counts: Counter[int] = Counter()
    n = args.requests
    # Deterministic interleaving (no RNG) so the demo is reproducible: every
    # 1/error_frac-th request is an error, every 1/slow_frac-th is slow.
    err_every = max(1, round(1 / args.error_frac)) if args.error_frac > 0 else 0
    slow_every = max(1, round(1 / args.slow_frac)) if args.slow_frac > 0 else 0

    # Pace requests over --duration so each scrape interval sees fresh increase.
    interval = (args.duration / n) if (args.duration > 0 and n > 0) else 0.0
    start = time.monotonic()

    for i in range(1, n + 1):
        if err_every and i % err_every == 0:
            path = "/error"
        elif slow_every and i % slow_every == 0:
            path = "/slow"
        else:
            path = "/"
        try:
            with urllib.request.urlopen(args.base_url + path, timeout=args.timeout) as r:
                counts[r.status] += 1
        except urllib.error.HTTPError as e:
            counts[e.code] += 1
        except Exception as e:  # noqa: BLE001
            print(f"request {i} to {path} failed: {e}", file=sys.stderr)
            counts[0] += 1
        if interval:
            # Sleep until this request's scheduled offset (drift-free pacing).
            target = start + i * interval
            delay = target - time.monotonic()
            if delay > 0:
                time.sleep(delay)

    total = sum(counts.values())
    errors = sum(v for k, v in counts.items() if k >= 500 or k == 0)
    print(f"sent {total} requests; status breakdown: {dict(sorted(counts.items()))}")
    if total:
        print(f"observed error fraction: {errors / total:.3f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
