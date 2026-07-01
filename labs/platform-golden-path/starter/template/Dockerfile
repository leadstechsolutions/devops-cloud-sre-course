# syntax=docker/dockerfile:1
# STARTER multi-stage image for __SERVICE_NAME__. Complete the TODOs so the
# final image is multi-stage AND runs as a non-root user.

# --- build stage ------------------------------------------------------------
FROM python:3.12-slim AS build
WORKDIR /build
COPY app/ ./app/
RUN python -m compileall -q app

# --- runtime stage ----------------------------------------------------------
FROM python:3.12-slim AS runtime

# TODO: create a non-root user/group (uid/gid 10001) and switch to it with USER.
# TODO: copy ONLY the app code from the build stage (COPY --from=build ...).

WORKDIR /app
ENV PYTHONUNBUFFERED=1 PORT=8080 SERVICE_NAME=__SERVICE_NAME__
EXPOSE 8080

# TODO: add a HEALTHCHECK that hits /healthz.

ENTRYPOINT ["python", "-m", "app.main"]
