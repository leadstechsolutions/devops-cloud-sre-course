"""Unit tests for the sample-api metrics registry and exposition format.

These exercise the Metrics class directly (no socket bound), so they are fast and
deterministic. They prove the two RED instruments emit VALID Prometheus text
exposition format -- the contract Prometheus and the recording rules depend on.

Run:  python3 -m pytest tests/test_app.py
  or: python3 -m unittest discover -s tests -p 'test_*.py'
"""
from __future__ import annotations

import re
import sys
import unittest
from pathlib import Path

# Make solution/app importable without packaging.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "solution" / "app"))

import app as sample_app  # noqa: E402


class TestMetrics(unittest.TestCase):
    def setUp(self) -> None:
        self.m = sample_app.Metrics()

    def test_counter_increments_per_observation(self) -> None:
        self.m.observe("GET", "/", 200, 0.01)
        self.m.observe("GET", "/", 200, 0.02)
        self.m.observe("GET", "/error", 500, 0.001)
        out = self.m.render()
        self.assertIn('http_requests_total{method="GET",path="/",status="200"} 2', out)
        self.assertIn('http_requests_total{method="GET",path="/error",status="500"} 1', out)

    def test_help_and_type_lines_present_once(self) -> None:
        self.m.observe("GET", "/", 200, 0.01)
        out = self.m.render()
        self.assertEqual(out.count("# TYPE http_requests_total counter"), 1)
        self.assertEqual(out.count("# TYPE http_request_duration_seconds histogram"), 1)
        self.assertEqual(out.count("# HELP http_requests_total"), 1)

    def test_histogram_buckets_are_cumulative_and_have_inf(self) -> None:
        # Two fast (<=0.05s) and one slow (0.3s) request.
        for d in (0.01, 0.02, 0.3):
            self.m.observe("GET", "/", 200, d)
        out = self.m.render()
        # le="0.05" must contain the two fast requests (cumulative).
        self.assertRegex(
            out,
            r'http_request_duration_seconds_bucket\{method="GET",path="/",le="0\.05"\} 2',
        )
        # +Inf bucket holds all three and equals _count.
        self.assertRegex(
            out,
            r'http_request_duration_seconds_bucket\{method="GET",path="/",le="\+Inf"\} 3',
        )
        self.assertRegex(
            out,
            r'http_request_duration_seconds_count\{method="GET",path="/"\} 3',
        )

    def test_inf_bucket_equals_count(self) -> None:
        for d in (0.001, 0.5, 1.5, 3.0, 9.0):  # last two exceed all finite buckets
            self.m.observe("GET", "/slow", 200, d)
        out = self.m.render()
        inf = int(re.search(r'le="\+Inf"\} (\d+)', out).group(1))
        count = int(
            re.search(r"http_request_duration_seconds_count\{[^}]*\} (\d+)", out).group(1)
        )
        self.assertEqual(inf, count)
        self.assertEqual(count, 5)

    def test_histogram_buckets_monotonic_nondecreasing(self) -> None:
        for d in (0.001, 0.03, 0.2, 0.8, 2.0):
            self.m.observe("GET", "/", 200, d)
        out = self.m.render()
        vals = [
            int(v)
            for v in re.findall(
                r'http_request_duration_seconds_bucket\{method="GET",path="/",le="[^"]+"\} (\d+)',
                out,
            )
        ]
        # Cumulative buckets must never decrease as le grows.
        self.assertTrue(all(b >= a for a, b in zip(vals, vals[1:])), vals)
        self.assertEqual(vals[-1], 5)  # +Inf bucket holds everything

    def test_sum_accumulates_durations(self) -> None:
        self.m.observe("GET", "/", 200, 0.25)
        self.m.observe("GET", "/", 200, 0.75)
        out = self.m.render()
        # 0.25 + 0.75 = 1.0 -> formatted as int "1" by _fmt.
        self.assertRegex(
            out, r'http_request_duration_seconds_sum\{method="GET",path="/"\} 1\b'
        )


class TestHandlerRoutes(unittest.TestCase):
    """Drive the handler logic via a fake request, asserting which routes are
    measured and which (infra) routes are excluded from the RED metrics."""

    def _call(self, path: str):
        import io
        from http.server import BaseHTTPRequestHandler

        metrics = sample_app.Metrics()
        handler_cls = sample_app.make_handler(metrics, slow_ms=1)

        captured = {}

        class FakeHandler(handler_cls):  # type: ignore[valid-type, misc]
            def __init__(self):  # bypass BaseHTTPRequestHandler socket setup
                self.path = path
                self.command = "GET"
                self.wfile = io.BytesIO()

            def send_response(self, code, message=None):
                captured["status"] = code

            def send_header(self, *a, **k):
                pass

            def end_headers(self):
                pass

        FakeHandler().do_GET()
        return captured.get("status"), metrics

    def test_root_is_200_and_counted(self) -> None:
        status, metrics = self._call("/")
        self.assertEqual(status, 200)
        self.assertIn('path="/",status="200"', metrics.render())

    def test_error_route_is_500_and_counted(self) -> None:
        status, metrics = self._call("/error")
        self.assertEqual(status, 500)
        self.assertIn('path="/error",status="500"', metrics.render())

    def test_metrics_endpoint_not_self_counted(self) -> None:
        status, metrics = self._call("/metrics")
        self.assertEqual(status, 200)
        self.assertNotIn('path="/metrics"', metrics.render())

    def test_healthz_not_counted(self) -> None:
        status, metrics = self._call("/healthz")
        self.assertEqual(status, 200)
        self.assertNotIn('path="/healthz"', metrics.render())

    def test_unknown_route_is_404_and_counted(self) -> None:
        status, metrics = self._call("/nope")
        self.assertEqual(status, 404)
        self.assertIn('path="/nope",status="404"', metrics.render())


if __name__ == "__main__":
    unittest.main()
