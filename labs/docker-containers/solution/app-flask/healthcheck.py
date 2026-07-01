#!/usr/bin/env python3
"""Container healthcheck probe for the Flask variant — stdlib only.

`python:3.12-slim` ships no curl/wget and we deliberately do NOT add them
(smaller image, fewer CVEs). The Docker HEALTHCHECK runs this script, which
hits GET /health and exits 0 only on a 200 whose body is "healthy".

Exit codes:
    0  healthy   (200 and body "healthy")
    1  unhealthy (wrong status, body, or connection refused/timeout)
"""
from __future__ import annotations

import os
import sys
import urllib.request

TIMEOUT_SECONDS = 3


def main() -> int:
    port = os.environ.get("PORT", "5000")
    url = f"http://127.0.0.1:{port}/health"
    try:
        with urllib.request.urlopen(url, timeout=TIMEOUT_SECONDS) as resp:
            if resp.status != 200:
                sys.stderr.write(f"unhealthy: status {resp.status}\n")
                return 1
            body = resp.read().decode("utf-8").strip()
    except Exception as exc:  # noqa: BLE001 - any failure means unhealthy
        sys.stderr.write(f"unhealthy: {exc}\n")
        return 1

    if body == "healthy":
        return 0
    sys.stderr.write(f"unhealthy: unexpected body {body!r}\n")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
