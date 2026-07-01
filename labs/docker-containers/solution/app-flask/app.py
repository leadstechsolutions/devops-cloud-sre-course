#!/usr/bin/env python3
"""Tiny Flask app — the W10 lecture variant (Week 10 Class 02).

This mirrors the application the Week-10 *lecture* builds (a Flask service with
`/` and `/health`), so the lecture's "build a hardened multi-stage image, scan
it, generate an SBOM" walkthrough is runnable against a real file on disk.

It deliberately requires a network-available package index (Flask is installed
from PyPI at build time) — that is the whole point of the CVE-scan / SBOM
lesson: a third-party dependency tree is exactly what you scan. For the
no-network / offline default, use the stdlib service in ``app/`` and the
top-level ``solution/Dockerfile`` instead.

Routes (kept identical to the lecture so it is recognisable):
    GET /        -> 200 "Hello from {APP_NAME}! Environment: {APP_ENV}"
    GET /health  -> 200 "healthy"            (liveness/readiness probe target)

Configuration (env vars, read at request time so they are container-friendly):
    APP_NAME  display name        (default "Docker Demo App")
    APP_ENV   environment label   (default "local")
    PORT      TCP port to bind    (default 5000)
"""
from __future__ import annotations

import os

from flask import Flask

app = Flask(__name__)


@app.route("/")
def home() -> str:
    app_name = os.getenv("APP_NAME", "Docker Demo App")
    app_env = os.getenv("APP_ENV", "local")
    return f"Hello from {app_name}! Environment: {app_env}"


@app.route("/health")
def health() -> tuple[str, int]:
    # A real readiness check would verify downstream dependencies; for the lab
    # a static 200 is enough to demonstrate Docker HEALTHCHECK -> K8s probes.
    return "healthy", 200


if __name__ == "__main__":
    # 0.0.0.0 so the port is reachable from outside the container. This dev
    # server is fine for the lab; the image runs the app under gunicorn (a
    # production WSGI server) instead — see Dockerfile.flask.
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
