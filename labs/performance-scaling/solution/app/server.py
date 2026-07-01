#!/usr/bin/env python3
"""CPU-burner HTTP service — Python standard library only.

A deliberately CPU-hungry endpoint so a Horizontal Pod Autoscaler has a real,
controllable signal to scale on. No third-party dependencies, so the image
builds without reaching a package index (the only network pull is the base).

Routes:
    GET /healthz       -> 200 {"status": "ok"}        (liveness/readiness probe; cheap)
    GET /              -> 200 {"hostname", "service", "port"}
    GET /burn          -> 200 {"hostname","iterations","ms"}   (BURNS CPU)
        query params:
            ms     busy-loop for at least this many wall-clock milliseconds
                   (default BURN_MS, capped at BURN_MS_MAX). This is the knob k6
                   turns: each request pins one CPU thread for ~ms milliseconds,
                   so request rate maps directly to CPU utilisation.
    anything else      -> 404 {"error": "not found"}

Configuration (environment):
    PORT        TCP port to bind                       (default 8000)
    HOST        bind address                           (default 0.0.0.0)
    BURN_MS     default busy-loop duration per /burn    (default 50)
    BURN_MS_MAX hard ceiling on ?ms= so one request    (default 2000)
                cannot wedge a worker forever

Why a busy loop and not time.sleep(): sleep yields the CPU and would drive
*zero* utilisation — the HPA would never scale. We do real arithmetic in a
tight loop so the container actually consumes the CPU it requested, and the
metrics-server reports it.
"""
from __future__ import annotations

import json
import math
import os
import signal
import socket
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

SERVICE_NAME = "cpu-burner"


def _int_env(name: str, default: int, lo: int, hi: int) -> int:
    """Read an int env var, failing loudly on garbage or out-of-range values.

    A misconfigured BURN_MS is an operator error we want surfaced at startup,
    not silently clamped — so int() is allowed to raise and exit the process.
    """
    raw = os.environ.get(name, str(default))
    val = int(raw)
    if not (lo <= val <= hi):
        raise ValueError(f"{name} out of range [{lo},{hi}]: {val}")
    return val


def _port() -> int:
    # PORT=0 is allowed and means "let the OS pick a free ephemeral port" — handy
    # for tests that must not collide with an already-bound port. The actual port
    # chosen is printed at startup (see main()).
    return _int_env("PORT", 8000, 0, 65535)


def burn(ms: int) -> int:
    """Busy-loop doing real FP work for at least ``ms`` milliseconds.

    Returns the number of iterations completed (kept so the optimiser cannot
    elide the loop and so the response can prove work was done). We re-check the
    monotonic clock every CHUNK iterations rather than every iteration to keep
    the clock-read overhead small relative to the arithmetic.
    """
    deadline = time.monotonic() + ms / 1000.0
    iterations = 0
    acc = 0.0
    CHUNK = 1000
    while True:
        for _ in range(CHUNK):
            # Real arithmetic the interpreter cannot constant-fold away.
            acc += math.sqrt(iterations * 2.0 + 1.0) * math.sin(iterations)
            iterations += 1
        if time.monotonic() >= deadline:
            break
    # Touch acc so a future optimiser keeps the work; value is otherwise unused.
    if math.isnan(acc):  # never true, but the read is load-bearing
        sys.stderr.write("unreachable\n")
    return iterations


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "cpu-burner/1.0"

    # Defaults read once at import so every request is cheap to dispatch.
    burn_ms_default = _int_env("BURN_MS", 50, 1, 60000)
    burn_ms_max = _int_env("BURN_MS_MAX", 2000, 1, 60000)

    def _write_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (name mandated by BaseHTTPRequestHandler)
        parts = urlsplit(self.path)
        path = parts.path.rstrip("/") or "/"

        if path == "/healthz":
            # Cheap on purpose: the probe must NOT do CPU work or it would make
            # the pod look unhealthy under load and trigger needless restarts.
            self._write_json(200, {"status": "ok"})
            return

        if path == "/burn":
            qs = parse_qs(parts.query)
            try:
                ms = int(qs.get("ms", [self.burn_ms_default])[0])
            except (ValueError, IndexError):
                self._write_json(400, {"error": "ms must be an integer"})
                return
            ms = max(1, min(ms, self.burn_ms_max))
            start = time.monotonic()
            iters = burn(ms)
            elapsed_ms = round((time.monotonic() - start) * 1000.0, 1)
            self._write_json(
                200,
                {
                    "hostname": socket.gethostname(),
                    "iterations": iters,
                    "ms": elapsed_ms,
                },
            )
            return

        if path == "/":
            self._write_json(
                200,
                {
                    "hostname": socket.gethostname(),
                    "service": SERVICE_NAME,
                    "port": _port(),
                },
            )
            return

        self._write_json(404, {"error": "not found", "path": path})

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

    # When PORT=0 the OS assigned a real port; report it so callers/tests can
    # discover where to connect. The "PORT=" prefix is a stable parse anchor.
    bound_port = httpd.server_address[1]
    sys.stdout.write(
        f"listening on {host}:{bound_port} as {SERVICE_NAME} "
        f"(PORT={bound_port}, BURN_MS={Handler.burn_ms_default}, "
        f"BURN_MS_MAX={Handler.burn_ms_max})\n"
    )
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    finally:
        httpd.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
