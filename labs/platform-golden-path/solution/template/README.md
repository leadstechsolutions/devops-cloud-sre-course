# __SERVICE_NAME__

> Generated from the platform **golden path**. This is a production-shaped,
> stdlib-only Python microservice with a secure container image, a Helm chart,
> and CI wired in. Edit the app; the paved road carries the rest.

## Endpoints

| Method | Path       | Purpose                                   |
|--------|------------|-------------------------------------------|
| GET    | `/`        | JSON hello payload echoing the service name |
| GET    | `/healthz` | Liveness — process is up                  |
| GET    | `/readyz`  | Readiness — 200 ready / 503 draining      |
| GET    | `/metrics` | Prometheus text exposition (request count) |

## Run locally

```bash
PORT=8080 python -m app.main
curl localhost:8080/healthz   # {"status":"ok"}
curl localhost:8080/          # {"service":"__SERVICE_NAME__", ...}
```

## Test

```bash
python -m compileall -q app
python -m unittest discover -s tests -p 'test_*.py' -v
```

## Build the image

```bash
docker build -t __SERVICE_NAME__:dev .
docker run --rm -p 8080:8080 __SERVICE_NAME__:dev
```

The image is multi-stage, runs as UID 10001 (non-root), has a read-only root
filesystem, drops all Linux capabilities, and ships only the app code.

## Deploy with Helm

```bash
helm lint chart
helm template __SERVICE_NAME__ chart           # render
helm install __SERVICE_NAME__ chart -n __SERVICE_NAME__ --create-namespace
helm test __SERVICE_NAME__ -n __SERVICE_NAME__ # in-cluster smoke test
```

Or apply the plain manifests under `k8s/`:

```bash
kubectl apply -f k8s/ -n __SERVICE_NAME__
```

## CI

`.github/workflows/ci.yml` runs on every PR: `ruff` + `hadolint` (lint),
`unittest` (test), `helm lint`/`template`/`kubeconform` (chart), then
`docker build` + `trivy` image scan that fails on HIGH/CRITICAL CVEs.

## What you must change

1. Replace the `build_payload()` body in `app/main.py` with your real handler.
2. Point `chart/values.yaml` `image.repository` at your registry.
3. Set real resource requests/limits once you have load data.
