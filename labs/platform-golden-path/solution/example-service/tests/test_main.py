"""Unit + black-box tests for the example-service service.

Pure-stdlib (unittest) so they run in CI with no extra dependencies. We start
the real server on an ephemeral port in a background thread and hit it over
HTTP — this exercises routing, status codes, and the readiness/shutdown logic
exactly as Kubernetes probes would.
"""
import json
import threading
import unittest
import urllib.request
from http.server import ThreadingHTTPServer

from app import main


def _get(port: int, path: str):
    url = f"http://127.0.0.1:{port}{path}"
    try:
        resp = urllib.request.urlopen(url, timeout=5)  # noqa: S310 (localhost)
        return resp.status, resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:  # readyz returns 503 when draining
        return exc.code, exc.read().decode("utf-8")


class TestPayload(unittest.TestCase):
    def test_payload_echoes_service_name(self):
        body = main.build_payload()
        self.assertIn("service", body)
        self.assertIn("message", body)


class TestServer(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Bind :0 to get a free port; reuse the real handler.
        cls.httpd = ThreadingHTTPServer(("127.0.0.1", 0), main.Handler)
        cls.port = cls.httpd.server_address[1]
        cls.thread = threading.Thread(target=cls.httpd.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown()
        cls.httpd.server_close()
        cls.thread.join(timeout=5)

    def setUp(self):
        # Each test assumes the service starts ready.
        main._ready.set()

    def test_healthz_ok(self):
        status, body = _get(self.port, "/healthz")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(body)["status"], "ok")

    def test_readyz_ready(self):
        status, body = _get(self.port, "/readyz")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(body)["status"], "ready")

    def test_readyz_503_when_draining(self):
        main._ready.clear()
        status, body = _get(self.port, "/readyz")
        self.assertEqual(status, 503)
        self.assertEqual(json.loads(body)["status"], "draining")

    def test_root_payload(self):
        status, body = _get(self.port, "/")
        self.assertEqual(status, 200)
        self.assertIn("hello from the golden path", body)

    def test_metrics_exposes_counter(self):
        status, body = _get(self.port, "/metrics")
        self.assertEqual(status, 200)
        self.assertIn("http_requests_total", body)

    def test_unknown_path_404(self):
        status, _ = _get(self.port, "/nope")
        self.assertEqual(status, 404)


if __name__ == "__main__":
    unittest.main()
