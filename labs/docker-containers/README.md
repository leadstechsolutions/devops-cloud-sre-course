# Module: docker-containers

> **Status:** Validated — all 16 local gates PASS against a real Docker daemon in
> this environment. The **stdlib (offline default)** image builds with no package
> index, is 43 MB < 60 MB, runs as non-root and its HEALTHCHECK reaches
> `healthy`, and the full `app + redis` compose stack comes up healthy. The
> **W10 lecture (Flask) variant** ([`solution/Dockerfile.flask`](solution/Dockerfile.flask))
> also builds (Flask + gunicorn from PyPI), is **45 MB**, runs as non-root
> (UID 10001), reaches `healthy`, and serves `GET /` and `GET /health`. Both
> Dockerfiles pass **hadolint** with no findings. Real **grype** CVE scans report
> **0 CRITICAL** on *both* images (7 HIGH each — all in the `python:3.12-slim`
> base image; the Flask dependency tree adds **0** HIGH/CRITICAL — see
> [Image scanning & SBOM](#image-scanning--sbom)), and a real **syft** SBOM
> (96 packages, SPDX-2.3) is committed at
> [`solution/sbom.spdx.json`](solution/sbom.spdx.json). See [Validation](#validation).
> **Maps to:** Week 10 Class 01–02 (Docker images, multi-stage builds, image
> hardening, CVE scanning + SBOM, Compose). The **W10 Class 02 lecture builds a
> Flask app** → use [`solution/Dockerfile.flask`](solution/Dockerfile.flask); the
> **stdlib app is the no-network default** (see
> [W10 lecture mapping](#w10-lecture-flask-vs-stdlib-default)). First
> containerization module; its image is consumed by
> [`kubernetes-fundamentals`](../kubernetes-fundamentals/) (W11/W12) and the
> [`capstone`](../capstone/) (W23/W24).

## What you will build
A tiny standalone HTTP service (Python **stdlib only** — no Flask, so the image
builds with **zero** package-index access) that serves `GET /healthz -> 200
{"status":"ok"}` and `GET / -> {"hostname", ...}`, reading its port from `$PORT`.
You package it into a **multi-stage** image whose final stage is
`python:3.12-slim`, runs as a **non-root** user (UID 10001), declares a
`HEALTHCHECK` that hits `/healthz` using a stdlib probe (no curl/wget in the
image), `EXPOSE`s its port, and carries no build tooling — final image **< 60 MB**
(this reference is **43 MB**). You then wire it together with a `redis:7-alpine`
sidecar via `compose.yaml` with healthchecks, a private bridge network (no
host-mode), per-service resource limits, dropped capabilities, and **no
published Redis port**.

You also build a **second image, the W10 lecture (Flask) variant**
([`solution/Dockerfile.flask`](solution/Dockerfile.flask)), which packages the
tiny Flask app from `solution/app-flask/` (`GET /` and `GET /health`, served by
**gunicorn**). It installs Flask + gunicorn from PyPI in a build stage, copies
only the installed prefix into a slim non-root runtime, and runs the **image CVE
scan (grype/Trivy) + SBOM (syft)** steps the lecture demonstrates against a real
third-party dependency tree. See
[W10 lecture mapping](#w10-lecture-flask-vs-stdlib-default).

## Prerequisites
- `docker >= 24` with Compose v2 (`docker compose`, not the legacy
  `docker-compose`). Built and validated here with Docker **29.1.2** /
  Compose **v5.0.0**.
- `python3 >= 3.10` for the local unit tests and YAML parse (PyYAML).
- Network access **only** to pull the two base images (`python:3.12-slim`,
  `redis:7-alpine`). The application itself installs nothing from PyPI.
- No prior module is required. This module's image is *reused* downstream by
  `kubernetes-fundamentals` and `capstone`.

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid). In words: a
client reaches the **app** container only via `127.0.0.1:8000` on the host. The
app talks to **redis** over a private bridge network (`appnet`); Redis publishes
**no** host port, so it is reachable only from inside that network. Both
containers run as non-root with `cap_drop: ALL`, `no-new-privileges`, and a
read-only root filesystem.

```
client ──GET /healthz, / ──▶ app (python:3.12-slim, UID 10001, HEALTHCHECK ▶ /healthz)
                                  │  redis:6379 (internal only)
                                  ▼
                              redis (redis:7-alpine, UID 999, no published port)
        published 127.0.0.1:8000 only        ── both on private bridge `appnet` ──
```

## W10 lecture (Flask) vs stdlib default

This module ships **two** application+image pairs that teach the *same*
hardening pattern; pick by whether you have network access to a package index:

| | **stdlib app — OFFLINE DEFAULT** | **Flask app — W10 LECTURE** |
|---|---|---|
| Source | [`app/`](app/) (`server.py`) | [`solution/app-flask/`](solution/app-flask/) (`app.py`) |
| Dockerfile | [`solution/Dockerfile`](solution/Dockerfile) | [`solution/Dockerfile.flask`](solution/Dockerfile.flask) |
| Routes | `GET /healthz`, `GET /` (JSON) | `GET /`, `GET /health` (text) |
| Port | 8000 | 5000 |
| Server | Python stdlib `http.server` | **gunicorn** (production WSGI) |
| Build-time network | **none** — installs nothing from PyPI | needs PyPI (installs Flask + gunicorn) |
| Used by | `compose.yaml`, k8s/capstone downstream | the W10 Class 02 lecture demo + CVE-scan/SBOM steps |

**Why both?** The Week-10 **Class 02 lecture builds a Flask app**, then scans the
image for CVEs (grype/Trivy) and generates an SBOM (syft). Those steps are only
meaningful against a *real third-party dependency tree*, so the lecture variant
installs Flask + gunicorn from PyPI — `solution/Dockerfile.flask` is the runnable
file that matches the lecture. The **stdlib app is the no-network default**: it
installs nothing, so the image (and the rest of this lab, including the Compose
stack and the downstream k8s/capstone reuse) builds even in an air-gapped or
offline grading environment. Both images use the *same* hardening: multi-stage,
`python:3.12-slim`, fixed-UID non-root user (10001), stdlib HEALTHCHECK (no curl),
`EXPOSE`, exec-form entrypoint.

> **W10 lecture (Flask) → `solution/Dockerfile.flask`.** The **stdlib app is the
> no-network default → `solution/Dockerfile`**.

## Repository layout
```
app/             # the stdlib HTTP service (server.py) + healthcheck probe (healthcheck.py)
.dockerignore    # keeps the build context tiny (context = module root)
starter/         # intentionally incomplete — you do the lab here
  Dockerfile     #   a naive single-stage ROOT image to harden (TODO gaps)
  compose.yaml   #   compose with TODO gaps (non-root, healthcheck, limits)
solution/        # reference implementation — check yourself against this
  Dockerfile        # stdlib app (OFFLINE DEFAULT): multi-stage, slim, non-root, HEALTHCHECK, EXPOSE
  Dockerfile.flask  # W10 LECTURE (Flask) variant: installs Flask+gunicorn from PyPI, multi-stage, non-root
  app-flask/        #   the W10 lecture Flask app
    app.py          #     GET / and GET /health (Flask)
    healthcheck.py  #     stdlib HEALTHCHECK probe (no curl in image)
    requirements.txt#     pinned Flask + gunicorn (the dependency tree the CVE scan/SBOM cover)
  compose.yaml      # app + redis, healthchecks, limits, private net, no host-mode (uses stdlib image)
broken/          # troubleshooting fixture: builds but stays "unhealthy"
tests/           # stdlib unittest for the app (no Docker needed)
docs/            # architecture.mmd
validate.sh      # runs this module's validation gates
```

## Setup
From a fresh clone, everything runs from the **module root**
(`labs/docker-containers/`) because the Dockerfiles use that directory as their
build context (so `COPY app/ ...` resolves):

```bash
cd labs/docker-containers
python3 -m unittest discover -s tests      # fast inner loop, no Docker
./validate.sh                               # full gate set (uses Docker if present)
```

To run the reference stack (stdlib app + redis):

```bash
docker compose -f solution/compose.yaml up --build     # Ctrl-C to stop
curl -s http://127.0.0.1:8000/healthz                  # {"status": "ok"}
curl -s http://127.0.0.1:8000/                         # {"hostname": ...}
docker compose -f solution/compose.yaml down -v        # teardown
```

To build and run the **W10 lecture (Flask) variant** (needs PyPI at build time):

```bash
docker build -f solution/Dockerfile.flask -t dc-flask:latest .   # build context = module root
docker run -d --name dc-flask -p 127.0.0.1:5000:5000 dc-flask:latest
curl -s http://127.0.0.1:5000/                         # Hello from Docker Demo App! Environment: local
curl -s http://127.0.0.1:5000/health                   # healthy
docker inspect --format '{{.State.Health.Status}}' dc-flask   # -> healthy after ~6s
docker rm -f dc-flask                                  # teardown
```

## Lab tasks
Work in `starter/`. Each task has an explicit *done when* check.

1. **Run as non-root.** The starter `Dockerfile` runs as root (the base image
   default). Create a fixed-UID user/group and switch to it with `USER`.
   *Done when:* `docker build -f starter/Dockerfile -t dc-naive . && docker run
   --rm dc-naive id` prints `uid=10001` (not `uid=0(root)`).
2. **Add a HEALTHCHECK** that runs the stdlib probe `app/healthcheck.py` (do
   **not** `apt-get install curl`). *Done when:* after `docker run -d`, `docker
   inspect --format '{{.State.Health.Status}}' <id>` becomes `healthy`.
3. **EXPOSE the port** the server binds (8000). *Done when:* `docker image
   inspect dc-naive --format '{{.Config.ExposedPorts}}'` shows `8000/tcp`.
4. **Convert to multi-stage** with a `python:3.12-slim` final stage that copies
   only the app from an earlier `build` stage. *Done when:* `docker image
   inspect <img> --format '{{.Size}}'` is **< 60 MB** and the final image has no
   build tooling.
5. **Harden Compose** (`starter/compose.yaml`): publish the app only on
   `127.0.0.1`, make `app` wait on `redis` being `service_healthy`, add an app
   healthcheck + `deploy.resources` limits. *Done when:* `docker compose -f
   starter/compose.yaml config` parses and `up` brings both services to
   `healthy` with no published Redis port (`docker port <redis>` is empty).

Check your work against `solution/`.

## Validation
`./validate.sh` runs every gate below and exits non-zero on any failure. Gates
that need Docker are auto-skipped as `DEFER` (with the exact command printed)
when no daemon is present; here a daemon **was** present, so all ran.

| Gate | Command | Result here |
|------|---------|-------------|
| Python compiles (stdlib) | `python3 -m py_compile app/server.py app/healthcheck.py` | PASS |
| Python compiles (Flask) | `python3 -m py_compile solution/app-flask/app.py solution/app-flask/healthcheck.py` | PASS |
| Unit tests | `python3 -m unittest discover -s tests -p 'test_*.py'` | PASS (5 tests) |
| YAML well-formed | `python3 -c "import yaml; list(yaml.safe_load_all(open('solution/compose.yaml')))"` | PASS |
| Compose parses | `docker compose -f solution/compose.yaml config` | PASS |
| Image builds (stdlib) | `docker build -f solution/Dockerfile -t dc-test .` | PASS |
| Image size < 60 MB (stdlib) | `docker image inspect dc-test --format '{{.Size}}'` | PASS (43 MB) |
| Dockerfile lint (stdlib) | `hadolint solution/Dockerfile` | PASS (no findings) |
| CVE scan (stdlib) | `grype dc-test:validate` | PASS (0 CRITICAL; 7 HIGH base-image) |
| SBOM | `syft dc-test:validate -o spdx-json` | PASS (96 pkgs, SPDX-2.3) |
| Dockerfile lint (Flask) | `hadolint solution/Dockerfile.flask` | PASS (no findings) |
| Image builds (Flask) | `docker build -f solution/Dockerfile.flask -t dc-flask .` | PASS |
| Image size < 80 MB (Flask) | `docker image inspect dc-flask --format '{{.Size}}'` | PASS (45 MB) |
| CVE scan (Flask) | `grype dc-flask:validate` | PASS (0 CRITICAL; 7 HIGH base-image, deps add 0) |

Real `./validate.sh` output captured in this environment:

```
== validating docker-containers ==
  [PASS] python: app/server.py + app/healthcheck.py compile
  [PASS] python: solution/app-flask/*.py compile (W10 lecture variant)
  [PASS] python: unittest discover -s tests
  [PASS] yaml: solution/compose.yaml parses
  [PASS] yaml: starter/compose.yaml parses
  [PASS] shell: validate.sh syntax
  [PASS] hadolint: solution/Dockerfile (no findings)
  [PASS] hadolint: solution/Dockerfile.flask (W10 lecture variant, no findings)
  [PASS] docker: compose -f solution/compose.yaml config
  [PASS] docker: build solution/Dockerfile
  [PASS] docker: final image size budget (43 MB < 60 MB)
  [PASS] grype: CVE scan dc-test:validate (0 CRITICAL, 7 HIGH base-image — see README)
  [PASS] syft: SBOM (SPDX-JSON) (96 packages -> solution/sbom.spdx.json)
  [PASS] docker: build solution/Dockerfile.flask (W10 lecture/Flask)
  [PASS] docker: flask image size budget (45 MB < 80 MB)
  [PASS] grype: CVE scan dc-flask:validate (0 CRITICAL, 7 HIGH, 91 total — base-image; see README)
== 16 passed, 0 failed, 0 deferred ==
```

The hadolint, grype, and syft gates are `command -v`-guarded in `validate.sh`,
so they run wherever the tool is installed and degrade to `DEFER` (with the
exact command printed) where it is not.

### Image scanning & SBOM

These gates were previously documented as "run where available" because the env
had no `hadolint`/`trivy`; the toolchain is now installed and they run for real.

**hadolint (Dockerfile lint)** — clean, no findings:
```
$ hadolint solution/Dockerfile
$ echo $?
0
```

**grype (CVE scan of the built image)** — `0 CRITICAL`, `7 HIGH`. Crucially,
**every HIGH is in the `python:3.12-slim` base image, not in code this module
controls**, and is unfixable without changing the base:
```
$ grype dc-test:validate
NAME       INSTALLED         FIXED-IN                    SEVERITY   VULNERABILITY
libc-bin   2.41-12+deb13u3   (won't fix)                 High       CVE-2026-0915
libc-bin   2.41-12+deb13u3   (won't fix)                 High       CVE-2026-0861
libc-bin   2.41-12+deb13u3   (won't fix)                 High       CVE-2025-15281
libc6      2.41-12+deb13u3   (won't fix)                 High       CVE-2026-0915
libc6      2.41-12+deb13u3   (won't fix)                 High       CVE-2026-0861
libc6      2.41-12+deb13u3   (won't fix)                 High       CVE-2025-15281
python     3.12.13           3.13.11, 3.14.1, 3.15.0     High       CVE-2025-13836
(+ 19 Medium / 4 Low / 49 Negligible / 10 Unknown — 89 total)
```
- 6 of the 7 HIGH are glibc CVEs that **Debian marks `won't fix`** — there is no
  patched package to install; they ship with `python:3.12-slim` (Debian 13).
- The 7th (`CVE-2025-13836`, the CPython interpreter) is fixed only in Python
  **3.13.11+** — i.e. a base-image *major-series* bump, not an `apt upgrade`.

This is the intended teaching point, not a regression: **the base image is the
CVE surface, and the application can't `apt upgrade` it away.** We deliberately
keep `python:3.12-slim` pinned because this image is *reused downstream* by
`kubernetes-fundamentals` and `capstone`; bumping it here would churn three
modules. The `validate.sh` grype gate therefore **fails on CRITICAL** (of which
there are none) and **reports — but does not fail on — HIGH**, with this
justification. In a real CI pipeline you would instead enforce a
`--fail-on high` policy; against this image that policy **would fail the build**,
forcing either a base-image bump (to a newer python-slim or a distroless/UBI
base) or an explicit, time-boxed `.grype.yaml` ignore per CVE with a ticket.
That is exactly the trade-off this module teaches; the fix is a base change, so
it is left as a documented, narrow non-failing report rather than a silent skip.

**W10 lecture (Flask) image** — `grype dc-flask:validate` reports the **same**
profile: `0 CRITICAL`, `7 HIGH` (91 total). All 7 HIGH are the identical
`python:3.12-slim` base-image CVEs above (glibc `won't fix` + the interpreter).
The Flask dependency tree the lecture installs — `Flask 3.1.0`, `Werkzeug 3.1.8`,
`Jinja2 3.1.6`, `gunicorn 23.0.0`, `MarkupSafe`, `click`, `blinker`,
`itsdangerous`, `packaging` — adds **0 HIGH/CRITICAL**. The teaching point: a
third-party dependency tree is exactly what `grype`/Trivy and `syft` exist to
inventory and gate on, and pinning current versions keeps that surface clean,
even though the base image still dominates the report:
```
$ grype dc-flask:validate
NAME       INSTALLED         FIXED-IN                    SEVERITY   VULNERABILITY
libc-bin   2.41-12+deb13u3   (won't fix)                 High       CVE-2026-0915
libc6      2.41-12+deb13u3   (won't fix)                 High       CVE-2026-0861
python     3.12.13           3.13.11, 3.14.1, 3.15.0     High       CVE-2025-13836
(7 High total — all base image; Flask/Werkzeug/gunicorn/Jinja2 = 0 High/Critical)
```

**syft (SBOM)** — a real Software Bill of Materials is produced and committed:
```
$ syft dc-test:validate -o spdx-json > solution/sbom.spdx.json
$ python3 -c "import json; d=json.load(open('solution/sbom.spdx.json')); \
    print(d['spdxVersion'], len(d['packages']), 'packages')"
SPDX-2.3 96 packages
```
The SBOM is checked in at [`solution/sbom.spdx.json`](solution/sbom.spdx.json)
so downstream consumers and `grype sbom:./solution/sbom.spdx.json` can scan
without rebuilding. Regenerate it any time with the command above (it is also
rewritten by `./validate.sh` on every run).

## Expected results
- `GET /healthz` -> HTTP **200**, body `{"status": "ok"}`.
- `GET /` -> HTTP **200**, body `{"hostname": "<container id>", "service":
  "docker-containers-demo", "port": 8000}`.
- `GET /anything-else` -> HTTP **404**, `{"error": "not found", ...}`.
- Inside the container: `id` -> `uid=10001(appuser)` (verified here).
- `docker inspect --format '{{.State.Health.Status}}'` reaches `healthy` for both
  app and redis (verified here).
- Final image **43 MB** (target **< 60 MB**). `redis-7-alpine` publishes no host
  port (`docker port <redis>` empty — verified here).

**W10 lecture (Flask) variant** (`dc-flask`, port 5000 — verified here):
- `GET /` -> HTTP **200**, body `Hello from Docker Demo App! Environment: local`.
- `GET /health` -> HTTP **200**, body `healthy`.
- Inside the container: `id` -> `uid=10001(appuser)`; HEALTHCHECK reaches
  `healthy` in ~6s. Final image **45 MB** (target **< 80 MB**).

## Troubleshooting
A real, reproducible broken state ships in [`broken/Dockerfile`](broken/Dockerfile).

| Step | Observation |
|------|-------------|
| **Reproduce** | `docker build -f broken/Dockerfile -t dc-broken . && docker run -d --name dc-broken -p 127.0.0.1:18080:8000 dc-broken` |
| **Symptom** | After ~30s, `docker inspect --format '{{.State.Health.Status}}' dc-broken` -> `unhealthy`, even though `curl http://127.0.0.1:18080/healthz` returns `{"status":"ok"}`. |
| **Diagnose** | `docker inspect --format '{{range .State.Health.Log}}{{.ExitCode}} {{.Output}}{{end}}' dc-broken` shows `/bin/sh: 1: curl: not found` (exit 127→1). |
| **Cause** | The `HEALTHCHECK` calls `curl`, but `python:3.12-slim` does **not** ship curl/wget. Every probe fails; after `retries` the container is marked unhealthy. The app is fine — the *probe* is broken. |
| **Fix** | Replace the curl probe with the stdlib probe: `HEALTHCHECK ... CMD ["python", "/app/healthcheck.py"]` — exactly what `solution/Dockerfile` does. (Adding curl would also "fix" it but bloats the image and adds CVEs.) |

This was reproduced in this environment: the broken container reported
`unhealthy` with `curl: not found` in the probe log; the solution container
reported `healthy`.

## Cleanup
Idempotent teardown (nothing here costs money; this just frees local resources):
```bash
docker compose -f solution/compose.yaml down -v             # stop stack + remove volumes/network
docker rm -f dc-smoke dc-broken dc-flask dc-flask-smoke 2>/dev/null || true  # any manual run containers
docker image rm dc-test dc-flask dc-broken dc-naive 2>/dev/null || true
docker image rm dc-test:validate dc-flask:validate 2>/dev/null || true
docker image prune -f                                       # dangling build layers
# Confirm nothing is left:
docker ps -a --filter name=docker-containers-lab            # should be empty
```

## Security considerations
- **Non-root by default:** both images run as fixed high UIDs (10001 app, 999
  redis). Compose restates `user:` and adds `no-new-privileges`, `cap_drop:
  ALL`, and `read_only` root filesystems — defense in depth.
- **No curl/wget in the final image:** the healthcheck uses a stdlib probe, so
  there is no shell-out tooling for an attacker to abuse and a smaller CVE
  surface.
- **No build tooling in the runtime stage:** the multi-stage split keeps
  compilers/pip out of the shipped image.
- **Least exposure:** only `127.0.0.1:8000` is published; Redis is internal to a
  private bridge network with **no** host port and **no** `network_mode: host`.
- **What NOT to commit:** real `.env` files, credentials, or a Redis password.
  The stack uses no secrets; if you add a `REDIS_PASSWORD`, inject it via an
  env/secret, never bake it into the image or commit it.
- **Scanning:** `hadolint` (Dockerfile lint), `grype` (CVE scan), and `syft`
  (SBOM) all run as real gates in `./validate.sh` here — see
  [Image scanning & SBOM](#image-scanning--sbom). hadolint is clean; grype finds
  **0 CRITICAL** and **7 HIGH that all live in the `python:3.12-slim` base
  image** (Debian `won't fix` glibc + the interpreter), which the app cannot
  patch away. In CI you would enforce `grype --fail-on high`; against this image
  that policy **fails the build** until the base image is bumped or each base
  CVE is given an explicit, ticketed ignore — the intended lesson about base-image
  CVE surface. A committed SBOM ([`solution/sbom.spdx.json`](solution/sbom.spdx.json))
  lets you re-scan or audit provenance without a rebuild.

## Cost considerations
**$0.** Everything runs locally in Docker; no cloud resources are created. The
only network usage is pulling two public base images once (cached afterward). To
stay at $0, never `docker push` these images to a paid registry and don't run
the stack on a billed cloud VM that you forget to stop — `down -v` releases all
local resources.

## Instructor answer key
The reference is [`solution/`](solution/). Non-obvious grading points:
1. **Multi-stage actually trims** — students sometimes "add a build stage" but
   still `COPY . .` everything into runtime; check `docker history`/size and that
   the final stage is `slim` with no apt build tooling. Target **< 60 MB**.
2. **Healthcheck must not add curl** — a correct answer uses the stdlib probe (or
   `python -c` one-liner). Installing curl "to make it pass" is the *wrong*
   answer and should lose points (image bloat + CVEs).
3. **`USER` before `ENTRYPOINT`, with a numeric UID** — `USER appuser` works but
   `USER 10001:10001` is preferred so Kubernetes `runAsNonRoot` policies can
   verify it without resolving a name.
4. **Exec-form `ENTRYPOINT`/`CMD`** so PID 1 is python and receives SIGTERM
   (clean `docker stop`). Shell form (the starter's `CMD python ...`) makes
   `/bin/sh` PID 1 and swallows the signal.
5. **Compose**: app must `depends_on` redis with `condition: service_healthy`
   (not bare `depends_on`), publish only on `127.0.0.1`, and define
   `deploy.resources` limits. Common wrong answer: publishing Redis's 6379 to
   the host — there is no reason to, and it widens the attack surface.

Common wrong answers: leaving the `python:3.12` (non-slim) base in the final
stage (~1 GB); forgetting `EXPOSE`; healthcheck that hits `/` instead of
`/healthz`; running as root "because it's just a lab."
