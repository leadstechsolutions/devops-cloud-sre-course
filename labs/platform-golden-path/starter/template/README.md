# __SERVICE_NAME__ (generated from the STARTER template)

This service was scaffolded from the **starter** golden-path template, which is
intentionally incomplete. Finish the TODOs in the source template before relying
on this service:

- `app/main.py` — `build_payload()`, `/readyz`, graceful shutdown
- `Dockerfile` — non-root user, copy-from-build, HEALTHCHECK
- `chart/templates/deployment.yaml` — securityContext, probes, writable `/tmp`
- `.github/workflows/ci.yml` — lint / helm / build-scan jobs

## Run locally

```bash
PORT=8080 python -m app.main
curl localhost:8080/healthz
```

## Test

```bash
python -m unittest discover -s tests -p 'test_*.py' -v
```

Compare against `solution/template/README.md` for the finished documentation.
