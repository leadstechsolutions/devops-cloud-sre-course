"""Tiny Flask service — the build target for the Week 9 CI pipeline.

Deliberately small: one pure function (`add`) and one HTTP endpoint
(`/health`). That is enough for the pipeline to do real work — lint it with
ruff, unit-test it with pytest, and package it into a tarball artifact — while
staying readable in a 2-hour lab. This is the SAME app you containerize in
Week 10, so the runtime dependency (Flask) is intentionally real.
"""
from __future__ import annotations

from flask import Flask

# Surfaced via the release process; lets a deploy be verified end-to-end later.
VERSION = "1.0.0"

app = Flask(__name__)


def add(a: int, b: int) -> int:
    """Trivial pure function so the test gate has something real to assert."""
    return a + b


@app.get("/health")
def health() -> tuple[dict[str, str], int]:
    """Liveness endpoint returned as JSON with an explicit 200 status."""
    return {"status": "ok", "version": VERSION}, 200


if __name__ == "__main__":
    # Bind to localhost for local runs only; the container overrides the host.
    app.run(host="127.0.0.1", port=8000)
