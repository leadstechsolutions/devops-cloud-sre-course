# sample-api image for the observability-stack lab.
#
# Single stage on python:3.12-slim. The app is pure standard library, so there
# is NO pip install step -- the build never touches a package index and is fully
# reproducible offline. A fixed non-root UID is baked in so the Kubernetes
# Deployment can set runAsNonRoot/runAsUser and have the kubelet honour it.
FROM python:3.12-slim

# Create a non-root user the manifest pins to (UID/GID 10001).
RUN groupadd --gid 10001 appuser \
 && useradd --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY app.py /app/app.py

ENV PORT=8000 \
    HOST=0.0.0.0 \
    SLOW_MS=750 \
    PYTHONUNBUFFERED=1

USER 10001:10001
EXPOSE 8000

# Container-native healthcheck hitting the same /healthz the kubelet probes use.
HEALTHCHECK --interval=10s --timeout=2s --start-period=3s --retries=3 \
  CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/healthz', timeout=1).status==200 else 1)"

ENTRYPOINT ["python", "/app/app.py"]
