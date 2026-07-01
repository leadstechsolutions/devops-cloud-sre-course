#!/usr/bin/env python3
"""sample-api: a tiny instrumented HTTP service for the observability-stack lab.

It exposes the Prometheus text exposition format on ``/metrics`` with two
classic RED-method instruments, built from the Python standard library only
(no prometheus_client dependency), so the container image builds hermetically
and the metric names are fully under our control:

  * http_requests_total      -- a COUNTER, labelled by method/path/status, that
                                counts every request the server handled. Rate +
                                error-ratio (the R and E of RED) come from this.
  * http_request_duration_seconds
                             -- a HISTOGRAM (cumulative ``_bucket`` series plus
                                ``_sum`` and ``_count``) of request latency. The
                                D of RED -- p50/p90/p99 -- come from this via
                                histogram_quantile() over the buckets.

Exposition-format rules this implements (so promtool/Prometheus accept it):
  * each metric family is preceded by exactly one ``# HELP`` and ``# TYPE`` line;
  * histogram ``_bucket`` series carry a ``le`` label and include ``le="+Inf"``;
  * buckets are cumulative -- a 0.25s request counts in the 0.25, 0.5, 1, ...,
    and +Inf buckets;
  * ``_count`` of a histogram equals the ``+Inf`` bucket value.

Routes:
  GET /                  -> 200, a trivial JSON body (the "work")
  GET /slow              -> 200 after an artificial delay (fills high latency buckets)
  GET /error             -> 500 (drives the error ratio so the burn-rate alert can fire)
  GET /healthz           -> 200 liveness/readiness probe (NOT counted in RED metrics)
  GET /metrics           -> 200, Prometheus exposition format

Env:
  PORT (default 8000), HOST (default 0.0.0.0), SLOW_MS (default 750).

This file is import-safe: building the registry and handler has no side effects,
so ``tests/test_app.py`` exercises it without binding a socket.
"""
from __future__ import annotations

import json
import os
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# Histogram bucket upper bounds in seconds. Chosen to bracket a ~50ms-1s web
# service: tight near the SLO-relevant latencies, with a final +Inf bucket that
# the exposition writer appends. These MUST match what the recording rules and
# the Grafana dashboard assume.
BUCKETS_SECONDS = (0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0)


class Metrics:
    """A minimal, thread-safe counter + histogram registry.

    Kept deliberately small: just enough to emit valid exposition format for the
    two RED instruments. A real service would use prometheus_client; we hand-roll
    it so the lab's metric contract is explicit and dependency-free.
    """

    def __init__(self, buckets: tuple[float, ...] = BUCKETS_SECONDS) -> None:
        self._lock = threading.Lock()
        # counter: (method, path, status) -> count
        self._requests: dict[tuple[str, str, str], int] = {}
        # histogram, keyed by (method, path): cumulative bucket counts, sum, count
        self._buckets = tuple(sorted(buckets))
        self._hist_bucket: dict[tuple[str, str], list[int]] = {}
        self._hist_sum: dict[tuple[str, str], float] = {}
        self._hist_count: dict[tuple[str, str], int] = {}

    def observe(self, method: str, path: str, status: int, duration_s: float) -> None:
        """Record one completed request: bump the counter and the histogram."""
        ckey = (method, path, str(status))
        hkey = (method, path)
        with self._lock:
            self._requests[ckey] = self._requests.get(ckey, 0) + 1
            if hkey not in self._hist_bucket:
                self._hist_bucket[hkey] = [0] * len(self._buckets)
                self._hist_sum[hkey] = 0.0
                self._hist_count[hkey] = 0
            # Cumulative buckets: increment every bucket whose upper bound the
            # observation does not exceed. Prometheus histograms are cumulative.
            for i, ub in enumerate(self._buckets):
                if duration_s <= ub:
                    self._hist_bucket[hkey][i] += 1
            self._hist_sum[hkey] += duration_s
            self._hist_count[hkey] += 1

    @staticmethod
    def _fmt(v: float) -> str:
        """Format a float the way Prometheus does (ints without a trailing .0)."""
        if v == int(v):
            return str(int(v))
        return repr(v)

    def render(self) -> str:
        """Serialize the registry to Prometheus text exposition format."""
        with self._lock:
            requests = dict(self._requests)
            hist_bucket = {k: list(v) for k, v in self._hist_bucket.items()}
            hist_sum = dict(self._hist_sum)
            hist_count = dict(self._hist_count)

        lines: list[str] = []

        # ---- counter: http_requests_total ----
        lines.append("# HELP http_requests_total Total HTTP requests handled, by method/path/status.")
        lines.append("# TYPE http_requests_total counter")
        for (method, path, status), count in sorted(requests.items()):
            lines.append(
                f'http_requests_total{{method="{method}",path="{path}",status="{status}"}} {count}'
            )

        # ---- histogram: http_request_duration_seconds ----
        lines.append("# HELP http_request_duration_seconds HTTP request latency in seconds.")
        lines.append("# TYPE http_request_duration_seconds histogram")
        for (method, path) in sorted(hist_bucket):
            cumulative = 0
            for i, ub in enumerate(self._buckets):
                cumulative = hist_bucket[(method, path)][i]
                lines.append(
                    "http_request_duration_seconds_bucket"
                    f'{{method="{method}",path="{path}",le="{self._fmt(ub)}"}} {cumulative}'
                )
            total = hist_count[(method, path)]
            # +Inf bucket: every observation falls into it; equals _count.
            lines.append(
                "http_request_duration_seconds_bucket"
                f'{{method="{method}",path="{path}",le="+Inf"}} {total}'
            )
            lines.append(
                "http_request_duration_seconds_sum"
                f'{{method="{method}",path="{path}"}} {self._fmt(hist_sum[(method, path)])}'
            )
            lines.append(
                "http_request_duration_seconds_count"
                f'{{method="{method}",path="{path}"}} {total}'
            )

        return "\n".join(lines) + "\n"


def make_handler(metrics: Metrics, slow_ms: int) -> type[BaseHTTPRequestHandler]:
    """Build a request handler bound to a specific metrics registry.

    Returned as a class (BaseHTTPRequestHandler is instantiated per request by
    the server), closing over ``metrics`` and ``slow_ms``.
    """

    class Handler(BaseHTTPRequestHandler):
        # Quieter, single-line access log; the real signal is in /metrics.
        def log_message(self, fmt: str, *args: object) -> None:  # noqa: A003
            return

        def _send(self, status: int, body: bytes, content_type: str) -> None:
            self.send_response(status)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(body)

        def do_GET(self) -> None:  # noqa: N802 (stdlib API name)
            path = self.path.split("?", 1)[0]
            start = time.perf_counter()

            # /metrics and /healthz are infra endpoints: serve them but do NOT
            # fold them into the RED metrics (they would pollute request rate
            # and error ratio with scrape/probe traffic).
            if path == "/metrics":
                body = metrics.render().encode("utf-8")
                self._send(200, body, "text/plain; version=0.0.4; charset=utf-8")
                return
            if path == "/healthz":
                self._send(200, b'{"status":"ok"}', "application/json")
                return

            # Application routes -- these ARE measured.
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

        # Allow HEAD for probes/load tools without separate logic.
        do_HEAD = do_GET  # noqa: N815

    return Handler


def build_server(host: str, port: int, slow_ms: int) -> ThreadingHTTPServer:
    metrics = Metrics()
    handler = make_handler(metrics, slow_ms)
    server = ThreadingHTTPServer((host, port), handler)
    # Stash the registry so tests can introspect it.
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
