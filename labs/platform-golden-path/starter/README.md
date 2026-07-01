# Starter — platform-golden-path

You are building a **golden path**: a service template plus a generator that
turns it into a production-ready microservice. This `starter/` tree is
intentionally incomplete. Finish the TODOs, then check yourself against
`../solution/`.

## What's already here

- `template/` — a service skeleton with placeholders (`__SERVICE_NAME__`) and
  several deliberate gaps (see TODOs).
- `scaffold.sh` — the generator, with four TODOs.

## Your tasks

1. **`scaffold.sh`** — complete TODO 1–4: validate the name (DNS-1123, <=53),
   refuse to overwrite, substitute the placeholder in all text files, and fail
   on any leftover placeholder.
2. **`template/app/main.py`** — implement `build_payload()`, the `/readyz`
   branch, and graceful SIGTERM handling so `tests/test_main.py` passes.
3. **`template/Dockerfile`** — make it non-root (uid 10001), copy only app code
   from the build stage, add a HEALTHCHECK.
4. **`template/chart/templates/deployment.yaml`** — add the pod + container
   `securityContext`, the liveness/readiness probes, and the writable `/tmp`.
5. **`template/.github/workflows/ci.yml`** — add the `lint`, `helm`, and
   `build-scan` jobs.

## Done when

```bash
# generator works and leaves no placeholder
./scaffold.sh demo /tmp/demo-svc && ! grep -rIl __SERVICE_NAME__ /tmp/demo-svc

# generated service passes every gate
cd /tmp/demo-svc
python -m unittest discover -s tests -p 'test_*.py'
hadolint Dockerfile
helm lint chart && helm template demo chart | kubeconform -strict -summary
docker build -t demo:dev .
```

Then run the module's `../validate.sh` — it must exit 0.
