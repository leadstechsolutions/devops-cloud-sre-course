#!/usr/bin/env python3
"""sample-api STARTER: a tiny HTTP service you will INSTRUMENT for Prometheus.

The HTTP routing already works. Your job is to make ``/metrics`` emit valid
Prometheus text exposition format for the two RED instruments:

  * http_requests_total            (COUNTER, labels: method, path, status)
  * http_request_duration_seconds  (HISTOGRAM: _bucket{le=...}, _sum, _count)

Follow the TODOs below. When you are done:

    python3 -m pytest tests/test_app.py        # the registry tests must pass
    promtool check rules ...                    # (rules come later)

Reference implementation: solution/app/app.py (peek only after you have tried).
"""
from __future__ import annotations

import json
import os
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

BUCKETS_SECONDS = (0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0)


class Metrics:
    """A minimal counter + histogram registry. COMPLETE THE TODOs."""

    def __init__(self, buckets: tuple[float, ...] = BUCKETS_SECONDS) -> None:
        self._lock = threading.Lock()
        self._requests: dict[tuple[str, str, str], int] = {}
        self._buckets = tuple(sorted(buckets))
        self._hist_bucket: dict[tuple[str, str], list[int]] = {}
        self._hist_sum: dict[tuple[str, str], float] = {}
        self._hist_count: dict[tuple[str, str], int] = {}

    def observe(self, method: str, path: str, status: int, duration_s: float) -> None:
        ckey = (method, path, str(status))
        hkey = (method, path)
        with self._lock:
            # TODO 1: increment the request counter for ckey.
            # TODO 2: lazily initialise the histogram state for hkey
            #         (a zeroed bucket list, a 0.0 sum, a 0 count).
            # TODO 3: for each bucket upper bound, increment the bucket when
            #         duration_s <= upper bound (cumulative histogram).
            # TODO 4: add duration_s to the sum and bump the count.
            raise NotImplementedError("implement Metrics.observe (TODOs 1-4)")

    @staticmethod
    def _fmt(v: float) -> str:
        if v == int(v):
            return str(int(v))
        return repr(v)

    def render(self) -> str:
        """Serialize to Prometheus text exposition format. COMPLETE THE TODOs."""
        # TODO 5: emit a single '# HELP' and '# TYPE ... counter' for
        #         http_requests_total, then one line per (method,path,status).
        # TODO 6: emit '# HELP' and '# TYPE ... histogram' for
        #         http_request_duration_seconds, then for each (method,path):
        #           - one _bucket line per le (cumulative), plus an le="+Inf"
        #             line equal to _count;
        #           - a _sum line and a _count line.
        # Return the joined text ending in a newline.
        raise NotImplementedError("implement Metrics.render (TODOs 5-6)")


def make_handler(metrics: Metrics, slow_ms: int) -> type[BaseHTTPRequestHandler]:
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, fmt: str, *args: object) -> None:  # noqa: A003
            return

        def _send(self, status: int, body: bytes, content_type: str) -> None:
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(body)

        def do_GET(self) -> None:  # noqa: N802
            path = self.path.split("?", 1)[0]
            start = time.perf_counter()

            if path == "/metrics":
                body = metrics.render().encode("utf-8")
                self._send(200, body, "text/plain; version=0.0.4; charset=utf-8")
                return
            if path == "/healthz":
                self._send(200, b'{"status":"ok"}', "application/json")
                return

            if path == "/":
                status, body = 200, b'{"service":"sample-api","ok":true}'
            elif path == "/slow":
                time.sleep(slow_ms / 1000.0)
                status, body = 200, b'{"service":"sample-api","slow":true}'
            elif path == "/error":
                status, body = 500, b'{"error":"synthetic failure"}'
            else:
                status, body = 404, b'{"error":"not found"}'

            duration = time.perf_counter() - start
            metrics.observe("GET", path, status, duration)
            self._send(status, body, "application/json")

        do_HEAD = do_GET  # noqa: N815

    return Handler


def build_server(host: str, port: int, slow_ms: int) -> ThreadingHTTPServer:
    metrics = Metrics()
    handler = make_handler(metrics, slow_ms)
    server = ThreadingHTTPServer((host, port), handler)
    server.metrics = metrics  # type: ignore[attr-defined]
    return server


def main() -> None:
    host = os.environ.get("HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", "8000"))
    slow_ms = int(os.environ.get("SLOW_MS", "750"))
    server = build_server(host, port, slow_ms)
    print(f"sample-api listening on {host}:{port} (slow_ms={slow_ms})", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
