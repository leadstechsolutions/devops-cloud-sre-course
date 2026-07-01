# syntax=docker/dockerfile:1
#
# BROKEN FIXTURE — for the troubleshooting exercise. This image BUILDS fine but
# the container never becomes healthy. Reproduce, diagnose, and fix it.
#
# Reproduce (from the module root):
#     docker build -f broken/Dockerfile -t dc-broken .
#     docker run -d --name dc-broken -p 127.0.0.1:8080:8000 dc-broken
#     sleep 30 && docker inspect --format '{{.State.Health.Status}}' dc-broken
#     # -> "unhealthy"   (expected: "healthy")
#     docker inspect --format '{{json .State.Health}}' dc-broken | python3 -m json.tool
#
# The bug: the HEALTHCHECK below calls `curl`, but python:3.12-slim does NOT
# ship curl (or wget). Every probe exits 127 ("command not found"), so after
# `retries` the container is marked unhealthy even though the server is serving
# /healthz perfectly. See README "Troubleshooting" for the full walkthrough and
# the fix (use the stdlib probe app/healthcheck.py — what solution/ does).

FROM python:3.12-slim AS runtime

ENV PYTHONUNBUFFERED=1 PORT=8000
WORKDIR /app
COPY app/ /app/

RUN groupadd --gid 10001 appuser \
 && useradd  --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin appuser
USER 10001:10001

EXPOSE 8000

# BUG: curl is not installed in the slim base image -> probe always fails.
HEALTHCHECK --interval=10s --timeout=3s --start-period=3s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8000/healthz || exit 1

ENTRYPOINT ["python", "/app/server.py"]
