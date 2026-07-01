# syntax=docker/dockerfile:1
# Multi-stage, non-root image for example-service.
#
# Stage 1 (build) compiles the app to bytecode so the final image fails fast on
# a syntax error and starts a touch quicker. The app is stdlib-only, so there is
# no `pip install` and no wheels to copy — the supply chain is just Python + our
# code. Stage 2 is a slim runtime that runs as an unprivileged user with a
# read-only-friendly layout.

# --- build stage ------------------------------------------------------------
FROM python:3.12-slim AS build
WORKDIR /build
COPY app/ ./app/
# Byte-compile; this is our earliest "does it even parse" gate inside the image.
RUN python -m compileall -q app

# --- runtime stage ----------------------------------------------------------
FROM python:3.12-slim AS runtime

# Create an unprivileged user/group up front so we never run as root.
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --home /app app

WORKDIR /app
# Copy only the application code from the build stage. No build tooling, caches,
# or test files reach the runtime image.
COPY --from=build --chown=app:app /build/app/ ./app/

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080 \
    SERVICE_NAME=example-service

EXPOSE 8080
USER 10001:10001

# Container-level healthcheck mirrors the k8s liveness probe. Uses stdlib only.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8080/healthz').status==200 else 1)"

ENTRYPOINT ["python", "-m", "app.main"]
