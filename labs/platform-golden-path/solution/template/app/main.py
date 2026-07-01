"""__SERVICE_NAME__ — a production-shaped microservice from the golden path.

Implemented with the Python standard library only (http.server) so the
generated service has ZERO runtime dependencies: the container image builds
and runs without a `pip install` step, which keeps the paved road fast and
its supply chain trivially auditable. Swap in FastAPI/Flask later by editing
this file and adding a requirements.txt — the rest of the path is unchanged.

Endpoints:
  GET /healthz   liveness  — process is up (always 200 while serving)
  GET /readyz    readiness — service is ready to take traffic
  GET /          a tiny JSON hello payload that echoes the service name
  GET /metrics   minimal Prometheus-style text exposition (request counter)

Configuration is read from the environment (12-factor):
  PORT           TCP port to bind          (default 8080)
  SERVICE_NAME   name reported in payloads (default "__SERVICE_NAME__")
  LOG_LEVEL      logging level             (default INFO)
"""
from __future__ import annotations

import json
import logging
import os
import signal
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

SERVICE_NAME = os.environ.get("SERVICE_NAME", "__SERVICE_NAME__")
PORT = int(os.environ.get("PORT", "8080"))
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO").upper()

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL, logging.INFO),
    format='{"ts":"%(asctime)s","level":"%(levelname)s","msg":"%(message)s"}',
)
log = logging.getLogger(SERVICE_NAME)

# Process-wide readiness flag. Flipped to False on SIGTERM so the readiness
# probe fails and Kubernetes stops sending new traffic during shutdown.
_ready = threading.Event()
_ready.set()

# Trivial request counter exposed on /metrics. A lock keeps it correct under
# the threaded server.
_metrics_lock = threading.Lock()
_request_total = 0


def _count() -> None:
    global _request_total
    with _metrics_lock:
        _request_total += 1


def build_payload() -> dict[str, Any]:
    """The root JSON body. Pure function so it is trivially unit-testable."""
    return {"service": SERVICE_NAME, "message": "hello from the golden path"}


class Handler(BaseHTTPRequestHandler):
    """Routes a handful of GET endpoints. No third-party framework."""

    server_version = "__SERVICE_NAME__/1.0"

    def _send_json(self, status: int, body: dict[str, Any]) -> None:
        payload = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def _send_text(self, status: int, body: str) -> None:
        payload = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; version=0.0.4")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:  # noqa: N802 (http.server API)
        _count()
        if self.path == "/healthz":
            self._send_json(HTTPStatus.OK, {"status": "ok"})
        elif self.path == "/readyz":
            if _ready.is_set():
                self._send_json(HTTPStatus.OK, {"status": "ready"})
            else:
                self._send_json(
                    HTTPStatus.SERVICE_UNAVAILABLE, {"status": "draining"}
                )
        elif self.path == "/metrics":
            with _metrics_lock:
                total = _request_total
            self._send_text(
                HTTPStatus.OK,
                "# HELP http_requests_total Total HTTP requests served.\n"
                "# TYPE http_requests_total counter\n"
                f"http_requests_total {total}\n",
            )
        elif self.path == "/":
            self._send_json(HTTPStatus.OK, build_payload())
        else:
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "not found"})

    def log_message(self, fmt: str, *args: Any) -> None:
        # Route http.server's access log through our structured logger.
        log.info("access %s", fmt % args)


def make_server() -> ThreadingHTTPServer:
    return ThreadingHTTPServer(("", PORT), Handler)


def main() -> None:
    httpd = make_server()

    def _graceful(signum: int, _frame: Any) -> None:
        log.info("received signal %s, draining", signum)
        _ready.clear()  # fail readiness so traffic stops
        # shutdown() must run from another thread than serve_forever().
        threading.Thread(target=httpd.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, _graceful)
    signal.signal(signal.SIGINT, _graceful)
    log.info("listening on :%s as service=%s", PORT, SERVICE_NAME)
    httpd.serve_forever()
    httpd.server_close()
    log.info("stopped")


if __name__ == "__main__":
    main()
