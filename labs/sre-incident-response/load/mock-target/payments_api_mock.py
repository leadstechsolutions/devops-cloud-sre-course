#!/usr/bin/env python3
"""Minimal stand-in for `payments-api`, used ONLY as a k6 load-test target.

This is NOT the service under study — it is a deterministic, dependency-free
fixture so `load/k6-smoke.js` has something to hit locally (the real service is
fictional). It implements exactly the contract the smoke script asserts:

    GET  /healthz       -> 200 {"status": "ok"}            (liveness probe)
    POST /v1/authorize  -> 200 {"approved": <bool>, ...}   (revenue path)
    anything else       -> 404 {"error": "not found"}

Behaviour knobs (env vars), so the same fixture can demonstrate a passing run
*and* a threshold-breaching run without code changes:

    PORT          TCP port to bind (default 8080)
    HOST          bind address     (default 0.0.0.0)
    DECLINE_RATE  fraction of authorize calls reported approved=false (default 0.05)
    LATENCY_MS    artificial per-authorize delay in ms (default 0) — set high to
                  prove the p95<300ms threshold can FAIL a build

Stdlib only: builds on python:3.x-slim with no package index access. No secrets;
the request body's card_token is read but never logged or stored.
"""
from __future__ import annotations

import json
import os
import random
import signal
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SERVICE_NAME = "payments-api-mock"


def _float_env(name: str, default: float) -> float:
    raw = os.environ.get(name)
    if raw is None or raw == "":
        return default
    return float(raw)


DECLINE_RATE = _float_env("DECLINE_RATE", 0.05)
LATENCY_MS = _float_env("LATENCY_MS", 0.0)


def _port() -> int:
    port = int(os.environ.get("PORT", "8080"))
    if not (1 <= port <= 65535):
        raise ValueError(f"PORT out of range: {port}")
    return port


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "payments-api-mock/1.0"

    def _write_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (name mandated by the base class)
        path = self.path.split("?", 1)[0].rstrip("/") or "/"
        if path == "/healthz":
            self._write_json(200, {"status": "ok"})
        else:
            self._write_json(404, {"error": "not found", "path": path})

    def do_POST(self) -> None:  # noqa: N802
        path = self.path.split("?", 1)[0].rstrip("/") or "/"
        if path != "/v1/authorize":
            self._write_json(404, {"error": "not found", "path": path})
            return

        # Drain the request body (the smoke test sends a small JSON payload). We
        # parse it to be realistic but never log the card_token.
        length = int(self.headers.get("Content-Length", "0") or "0")
        raw = self.rfile.read(length) if length else b""
        try:
            req = json.loads(raw or b"{}")
        except json.JSONDecodeError:
            self._write_json(400, {"error": "invalid json"})
            return

        if LATENCY_MS > 0:
            time.sleep(LATENCY_MS / 1000.0)

        approved = random.random() >= DECLINE_RATE
        self._write_json(
            200,
            {
                "approved": approved,
                "amount_cents": req.get("amount_cents"),
                "currency": req.get("currency"),
                "decline_reason": None if approved else "insufficient_funds",
            },
        )

    def log_message(self, fmt: str, *args) -> None:
        sys.stdout.write("%s - %s\n" % (self.address_string(), fmt % args))
        sys.stdout.flush()


def main() -> int:
    host = os.environ.get("HOST", "0.0.0.0")
    port = _port()
    httpd = ThreadingHTTPServer((host, port), Handler)

    def _shutdown(signum, _frame):
        sys.stdout.write(f"received signal {signum}, shutting down\n")
        sys.stdout.flush()
        httpd.shutdown()

    signal.signal(signal.SIGTERM, _shutdown)
    signal.signal(signal.SIGINT, _shutdown)

    sys.stdout.write(
        f"{SERVICE_NAME} listening on {host}:{port} "
        f"(decline_rate={DECLINE_RATE}, latency_ms={LATENCY_MS})\n"
    )
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    finally:
        httpd.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
