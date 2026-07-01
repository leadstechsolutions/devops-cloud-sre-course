# Container image for the Flask service (built/scanned by the ADVANCED variant
# ci-advanced.yml and reused in Week 10). slim base keeps the attack surface
# (and Trivy findings) small. Build context is this `app/` directory.
FROM python:3.12-slim AS base

# Don't write .pyc, don't buffer stdout (so container logs are immediate).
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install deps first for layer caching. requirements.txt is runtime-only (Flask).
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app package (main.py + __init__.py).
COPY __init__.py main.py ./

# Run as a non-root user — least privilege inside the container.
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8000

# Bind to all interfaces inside the container so the published port is reachable.
ENV FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=8000

# Container-native healthcheck hits the same endpoint CI verifies.
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health').status==200 else 1)"

# `flask run` serves app.main:app on 0.0.0.0:8000.
CMD ["flask", "--app", "main:app", "run", "--host", "0.0.0.0", "--port", "8000"]
