# syntax=docker/dockerfile:1
#
# STARTER — this is a deliberately NAIVE, single-stage image. It works, but it
# is everything you should not ship: it runs as root, has no healthcheck, no
# multi-stage trimming, and (in some variants) pulls in build tooling. Your job
# is to harden it into the multi-stage, non-root, healthchecked image described
# in the lab tasks. Check yourself against solution/Dockerfile when done.
#
# Build from the MODULE ROOT (so `COPY app/` resolves):
#     docker build -f starter/Dockerfile -t dc-naive .

FROM python:3.12

WORKDIR /app

# Copies the whole context (no .dockerignore discipline yet) and runs as root.
COPY app/ /app/

# TODO(student): This image runs as root (the python base image's default).
#   Create a non-root user/group and switch to it with USER before the app runs.
#   Hint: groupadd/useradd with a fixed high UID, then `USER 10001:10001`.

# TODO(student): There is no HEALTHCHECK. Add one that runs the stdlib probe
#   app/healthcheck.py so the orchestrator can tell when the app is live.
#   (Do NOT apt-get install curl just for this — keep the image lean.)

# TODO(student): Document the port. Add an EXPOSE instruction for the port the
#   server binds (default 8000, from the PORT env var).

# TODO(student): Convert this to a MULTI-STAGE build whose final stage is
#   python:3.12-slim, copying only the application from an earlier `build`
#   stage. Goal: final image < 60 MB and no build tooling in it.

# shell form is used here on purpose (another thing to fix): prefer exec form
# so PID 1 is python and receives SIGTERM directly.
CMD python /app/server.py
