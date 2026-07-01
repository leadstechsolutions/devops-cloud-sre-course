"""Stdlib-only tests for the HTTP service.

Runs an actual ThreadingHTTPServer on an ephemeral port in a background thread
and hits it with urllib — no third-party deps, no Docker needed. This is the
fast inner loop; the Docker build/run is the integration check.

Run from the module root:
    python3 -m unittest discover -s tests
"""
import json
import os
import sys
import threading
import unittest
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer

# Make the app package importable when tests run from the module root.
APP_DIR = os.path.join(os.path.dirname(__file__), "..", "app")
sys.path.insert(0, os.path.abspath(APP_DIR))

import server  # noqa: E402  (path set above)


class ServerTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Bind to port 0 -> the OS picks a free ephemeral port.
        cls.httpd = ThreadingHTTPServer(("127.0.0.1", 0), server.Handler)
        cls.port = cls.httpd.server_address[1]
        # The handler reads PORT from the env for the "/" payload; align it.
        os.environ["PORT"] = str(cls.port)
        cls.thread = threading.Thread(target=cls.httpd.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = f"http://127.0.0.1:{cls.port}"

    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown()
        cls.httpd.server_close()
        cls.thread.join(timeout=5)

    def _get(self, path):
        with urllib.request.urlopen(self.base + path, timeout=5) as resp:
            return resp.status, json.loads(resp.read().decode("utf-8"))

    def test_healthz_returns_ok(self):
        status, body = self._get("/healthz")
        self.assertEqual(status, 200)
        self.assertEqual(body, {"status": "ok"})

    def test_healthz_ignores_query_string(self):
        status, body = self._get("/healthz?probe=1")
        self.assertEqual(status, 200)
        self.assertEqual(body["status"], "ok")

    def test_root_returns_hostname_and_port(self):
        status, body = self._get("/")
        self.assertEqual(status, 200)
        self.assertIn("hostname", body)
        self.assertEqual(body["service"], server.SERVICE_NAME)
        self.assertEqual(body["port"], self.port)

    def test_unknown_path_is_404(self):
        with self.assertRaises(urllib.error.HTTPError) as ctx:
            self._get("/nope")
        self.assertEqual(ctx.exception.code, 404)

    def test_port_env_validation(self):
        old = os.environ.get("PORT")
        try:
            os.environ["PORT"] = "70000"  # out of range
            with self.assertRaises(ValueError):
                server._port()
            os.environ["PORT"] = "not-a-number"
            with self.assertRaises(ValueError):
                server._port()
        finally:
            if old is not None:
                os.environ["PORT"] = old


if __name__ == "__main__":
    unittest.main()
