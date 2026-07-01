#!/usr/bin/env python3
"""Tiny standalone HTTP service built on the Python standard library only.

No third-party dependencies (no Flask/FastAPI), so the container image builds
without ever reaching a package index — the only network pull is the base image.

Routes:
    GET /healthz -> 200 {"status": "ok"}          (liveness/readiness probe)
    GET /        -> 200 {"hostname", "service", "port"}
    anything else -> 404 {"error": "not found"}

Configuration:
    PORT  TCP port to bind (default 8000)
    HOST  bind address     (default 0.0.0.0 so it is reachable from outside
          the container; override to 127.0.0.1 for local-only)
"""
from __future__ import annotations

import json
import os
import signal
import socket
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SERVICE_NAME = "docker-containers-demo"


def _port() -> int:
    """Read PORT from the environment, falling back to 8000.

    A non-integer PORT is a configuration error we want to fail loudly on,
    not silently ignore — so we let int() raise and the process exit non-zero.
    """
    raw = os.environ.get("PORT", "8000")
    port = int(raw)
    if not (1 <= port <= 65535):
        raise ValueError(f"PORT out of range: {port}")
    return port


class Handler(BaseHTTPRequestHandler):
    # Keep the default HTTP/1.0 behaviour off; HTTP/1.1 lets the healthcheck
    # client reuse semantics cleanly and reports keep-alive correctly.
    protocol_version = "HTTP/1.1"
    server_version = "stdlib-http/1.0"

    def _write_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (name mandated by BaseHTTPRequestHandler)
        # Strip any query string so "/healthz?probe=1" still matches.
        path = self.path.split("?", 1)[0].rstrip("/") or "/"

        if path == "/healthz":
            self._write_json(200, {"status": "ok"})
        elif path == "/":
            self._write_json(
                200,
                {
                    "hostname": socket.gethostname(),
                    "service": SERVICE_NAME,
                    "port": _port(),
                },
            )
        else:
            self._write_json(404, {"error": "not found", "path": path})

    def log_message(self, fmt: str, *args) -> None:
        # Structured-ish access log to stdout so `docker logs` / compose shows it.
        sys.stdout.write("%s - %s\n" % (self.address_string(), fmt % args))
        sys.stdout.flush()


def main() -> int:
    host = os.environ.get("HOST", "0.0.0.0")
    port = _port()
    httpd = ThreadingHTTPServer((host, port), Handler)

    def _shutdown(signum, _frame):
        # Containers receive SIGTERM on `docker stop`; exit cleanly so the
        # orchestrator does not have to escalate to SIGKILL.
        sys.stdout.write(f"received signal {signum}, shutting down\n")
        sys.stdout.flush()
        httpd.shutdown()

    signal.signal(signal.SIGTERM, _shutdown)
    signal.signal(signal.SIGINT, _shutdown)

    sys.stdout.write(f"listening on {host}:{port} as {SERVICE_NAME}\n")
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    finally:
        httpd.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
