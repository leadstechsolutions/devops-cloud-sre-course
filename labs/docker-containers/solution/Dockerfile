# syntax=docker/dockerfile:1
#
# Multi-stage build for the stdlib HTTP service.
#
# Why multi-stage here, even with no pip install? It demonstrates the pattern
# and guarantees the final image carries ONLY the application source on top of
# a slim runtime — no build context cruft, no tooling. With real dependencies
# the `build` stage is where you'd `pip install --prefix=/install ...` and then
# copy only the resulting site-packages into the runtime stage.

# ---------------------------------------------------------------------------
# Stage 1: build — assemble exactly the files the runtime needs.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS build

WORKDIR /build

# Copy only the application package. (A real project would also copy
# requirements.txt and run: pip install --no-cache-dir --prefix=/install -r requirements.txt)
COPY app/ ./app/

# Byte-compile to catch syntax errors at build time and ship .pyc alongside.
RUN python -m compileall -q ./app

# ---------------------------------------------------------------------------
# Stage 2: runtime — slim, non-root, no build tooling.
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS runtime

# OCI metadata so `docker inspect` / registries show provenance.
LABEL org.opencontainers.image.title="docker-containers-demo" \
      org.opencontainers.image.description="Stdlib HTTP service: GET /healthz and GET /" \
      org.opencontainers.image.source="https://example.com/devops-cloud-sre/labs/docker-containers" \
      org.opencontainers.image.licenses="MIT"

# Hardening: no interactive pip cache, no .pyc churn, unbuffered logs so
# `docker logs` is real-time.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000

# Create an unprivileged user/group. We do NOT run as root.
# 10001 is a high, fixed UID so the same identity maps predictably on hosts
# and in Kubernetes runAsUser policies.
RUN groupadd --gid 10001 appuser \
 && useradd  --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

# Copy the build artifacts from stage 1. --chown sets ownership in one layer.
COPY --from=build --chown=appuser:appuser /build/app/ /app/

# Drop privileges. Everything after this runs as appuser (UID 10001).
USER 10001:10001

EXPOSE 8000

# Healthcheck uses the stdlib probe (no curl/wget present, by design).
# --start-period gives the server a moment to bind before failures count.
HEALTHCHECK --interval=15s --timeout=5s --start-period=5s --retries=3 \
    CMD ["python", "/app/healthcheck.py"]

# exec form -> PID 1 is python, so it receives SIGTERM directly for clean stop.
ENTRYPOINT ["python", "/app/server.py"]
