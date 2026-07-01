#!/usr/bin/env python3
"""Container healthcheck probe — stdlib only, no curl/wget in the final image.

`python:3.12-slim` does not ship curl or wget, and we deliberately do NOT add
them (smaller image, fewer CVEs). Instead the Docker HEALTHCHECK runs this
script, which hits GET /healthz and exits 0 only on a 200 with status "ok".

Exit codes:
    0  healthy   (200 and body {"status": "ok"})
    1  unhealthy (wrong status code, body, or connection refused/timeout)
"""
from __future__ import annotations

import json
import os
import sys
import urllib.request

TIMEOUT_SECONDS = 3


def main() -> int:
    port = os.environ.get("PORT", "8000")
    url = f"http://127.0.0.1:{port}/healthz"
    try:
        with urllib.request.urlopen(url, timeout=TIMEOUT_SECONDS) as resp:
            if resp.status != 200:
                sys.stderr.write(f"unhealthy: status {resp.status}\n")
                return 1
            body = json.loads(resp.read().decode("utf-8"))
    except Exception as exc:  # noqa: BLE001 - any failure means unhealthy
        sys.stderr.write(f"unhealthy: {exc}\n")
        return 1

    if body.get("status") == "ok":
        return 0
    sys.stderr.write(f"unhealthy: unexpected body {body!r}\n")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
