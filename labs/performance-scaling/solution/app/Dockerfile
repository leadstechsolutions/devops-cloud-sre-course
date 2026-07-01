# CPU-burner image for the performance-scaling lab.
# Single-stage, distro-slim Python base; no third-party packages so the build
# never touches a package index. Runs as a fixed non-root UID so the manifests'
# `runAsNonRoot` security context is satisfiable.
FROM python:3.12-alpine

# Non-root user baked in so the Deployment can pin runAsUser/runAsGroup to it.
RUN addgroup -g 10001 appuser \
 && adduser -D -u 10001 -G appuser appuser

WORKDIR /app
COPY server.py /app/server.py

ENV PORT=8000 \
    HOST=0.0.0.0 \
    BURN_MS=50 \
    BURN_MS_MAX=2000 \
    PYTHONUNBUFFERED=1

USER 10001:10001
EXPOSE 8000

ENTRYPOINT ["python", "/app/server.py"]
