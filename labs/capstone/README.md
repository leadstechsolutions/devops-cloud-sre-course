# Module: capstone

> **Status:** Validated — the validation gates below were **run in this
> environment and pass** (`./validate.sh` → 7/7, exit 0), and the demo stack was
> actually brought up here: the app and Redis reported `healthy`, Prometheus
> started, and `curl /healthz` returned `{"status": "ok"}` (output captured under
> [Validation](#validation)). This is an **integration** module: it adds minimal
> new code and wires together the seven modules built in earlier weeks.
> **Maps to:** Week 23 Class 01–02 and Week 24 Class 01–02 (production-readiness
> capstone). Reuses modules 4–12.

## What you will build

A production-readiness **capstone** that takes the course application from "a pile
of independent modules" to "one operable, observable, demoable system." You
provision infrastructure with `terraform-aws-foundations`, ship the same hardened
image from `docker-containers`, deploy it on Kubernetes via
`kubernetes-fundamentals` + `helm-charts`, build and release it with
`cicd-pipelines`, watch it with `observability`, and operate it with
`sre-incident-response`. The concrete deliverables are a full-system architecture
diagram, two real ADRs, a ticked production-readiness checklist, an on-call
runbook, and a single `docker-compose.demo.yaml` that brings up **app + Redis +
optional Prometheus** on a laptop with zero cloud cost — building the *same* image
the cluster runs, not a fork.

## Prerequisites

- `docker >= 24` with the Compose v2 plugin (`docker compose version`) — for the
  local demo stack and the `docker compose config` gate.
- `python3 >= 3.10` with **PyYAML** — for the YAML-parse gates and the validator.
- `bash >= 4` — `validate.sh` and `tests/check_references.sh`.
- Optional, only for the cloud profile: `terraform >= 1.6`, `kubectl`, `helm`, and
  an AWS account. **None of these is needed to validate or demo this module.**
- **Prior modules whose output this one reuses** (must exist on disk — the
  reference checker enforces it): `terraform-aws-foundations`, `docker-containers`,
  `kubernetes-fundamentals`, `helm-charts`, `cicd-pipelines`, `observability`,
  `sre-incident-response`.

## Architecture

Full-system diagram: [`architecture/architecture.mmd`](architecture/architecture.mmd)
(Mermaid). Render it at <https://mermaid.live> or with
`mmdc -i architecture/architecture.mmd -o architecture.svg`.

A developer pushes code; **CI/CD** lints, tests, builds, and scans the image, then
`helm upgrade`s it onto a **Kubernetes** cluster that **Terraform** provisioned.
The workload (Deployment + Service + Ingress + HPA + Redis sidecar, guarded by a
default-deny NetworkPolicy) serves `/healthz`. **Prometheus** scrapes it and
evaluates multi-burn-rate SLO rules; when a rule fires, **Alertmanager** pages the
on-call, who works the **runbook** and tracks the **error budget**. Every box in
the diagram maps to exactly one course module.

## Repository layout

```
architecture/architecture.mmd        # full-system Mermaid diagram
adr/0001-record-architecture-decisions.md
adr/0002-managed-vs-self-hosted.md   # real ADRs (Nygard format)
production-readiness-checklist.md     # go/no-go gate, ticked against real artifacts
runbook.md                            # on-call playbooks
docker-compose.demo.yaml              # ONE local stack: app + redis + (optional) prometheus
prometheus/prometheus.demo.yml        # minimal scrape config the demo mounts
starter/capstone-brief.md             # the student assignment
starter/adr/NNNN-template.md          # empty ADR template for students
tests/check_references.sh             # asserts every referenced labs/ path exists
validate.sh                           # runs this module's validation gates
```

There is no `solution/` source tree because this module **writes almost no new
code** — its "solution" is the set of integration documents above plus the demo
compose, and the application/infra code it reuses lives in the seven sibling
modules. The intentionally-incomplete student starting point lives in `starter/`.

## Setup

From a fresh clone, with Docker running:

```bash
cd labs/capstone

# 1) Validate everything (no Docker daemon needed for gates 1–5):
./validate.sh

# 2) Bring up the local demo (app + redis):
docker compose -f docker-compose.demo.yaml up --build -d

# 3) Smoke test:
curl -fsS http://127.0.0.1:8000/healthz      # -> {"status": "ok"}
curl -fsS http://127.0.0.1:8000/             # -> {"hostname","service","port"}

# 4) Optional: add Prometheus (metrics profile):
docker compose -f docker-compose.demo.yaml --profile metrics up --build -d
#   then open http://127.0.0.1:9090/targets

# 5) Tear down (see Cleanup):
docker compose -f docker-compose.demo.yaml --profile metrics down -v
```

## Lab tasks

The full assignment is in [`starter/capstone-brief.md`](starter/capstone-brief.md).
Summary with acceptance checks:

1. **Reference checker first.** Write/inspect `tests/check_references.sh` so every
   `labs/<module>` path you cite is asserted to exist.
   *Done when:* `bash tests/check_references.sh` exits 0 and lists every module.
2. **Architecture diagram.** Author `architecture/architecture.mmd`; every box maps
   to a real module.
   *Done when:* the diagram parses as Mermaid and each subgraph names its module.
3. **Two ADRs** from `starter/adr/NNNN-template.md`: adopt-ADRs, and
   managed-vs-self-hosted with a real decision table + "revisit when…" triggers.
   *Done when:* both files follow the template and record a real decision.
4. **Production-readiness checklist.** Tick each `[x]` against a real artifact path;
   mark gaps `[ ]` honestly.
   *Done when:* every `[x]` resolves to a file that provides it.
5. **Runbook** with ≥4 alert→action playbooks and copy-pasteable commands.
   *Done when:* error-budget-burn, CrashLoop, dependency-down, and OOM playbooks exist.
6. **Demo stack.** `docker-compose.demo.yaml` builds the **same** app image from
   `labs/docker-containers` (no fork) and adds Redis + optional Prometheus.
   *Done when:* `docker compose ... up` is healthy and `/healthz` returns 200.

## Validation

`./validate.sh` runs the gates below. **Real output captured in this environment:**

```
== validating capstone ==
  [PASS] yaml: docker-compose.demo.yaml parses
  [PASS] yaml: prometheus/prometheus.demo.yml parses
  [PASS] refs: every referenced labs/<module> path exists
  [PASS] shell: validate.sh syntax
  [PASS] shell: tests/check_references.sh syntax
  [PASS] docker: compose config (default profile)
  [PASS] docker: compose config (metrics profile)
== 7 passed, 0 failed, 0 deferred ==
```

Individual gate commands and expected output:

| Gate | Command | Expected |
|------|---------|----------|
| YAML demo | `python3 -c "import yaml; list(yaml.safe_load_all(open('docker-compose.demo.yaml')))"` | exit 0 |
| YAML prom | `python3 -c "import yaml; list(yaml.safe_load_all(open('prometheus/prometheus.demo.yml')))"` | exit 0 |
| References | `bash tests/check_references.sh` | `PASS: every referenced labs/ path resolves.`, exit 0 |
| Compose (default) | `docker compose -f docker-compose.demo.yaml config` | renders merged config, exit 0 |
| Compose (metrics) | `docker compose -f docker-compose.demo.yaml --profile metrics config` | includes `prometheus`, exit 0 |

**End-to-end run captured here** (`up --profile metrics`, then `curl`):

```
capstone-demo-redis-1  ... Up (healthy)
capstone-demo-app-1    ... Up (healthy)   127.0.0.1:8000->8000/tcp
capstone-demo-prometheus-1 ... Up         127.0.0.1:9090->9090/tcp
$ curl -fsS http://127.0.0.1:8000/healthz
{"status": "ok"}
$ curl -fsS http://127.0.0.1:8000/
{"hostname": "1fd4791c91e2", "service": "docker-containers-demo", "port": 8000}
```

**Tooling note (honest):** `promtool check config prometheus/prometheus.demo.yml`
is the canonical validator for the scrape config but `promtool` is not installed
in this build environment; the config is validated here by `docker compose config`
(it mounts and the Prometheus container starts cleanly) and by the YAML parse gate.
Run `promtool` where Prometheus is installed, or in a container:
`docker run --rm -v "$PWD/prometheus:/p" prom/prometheus:v2.53.0 promtool check config /p/prometheus.demo.yml`.

## Expected results

- `./validate.sh` → `7 passed, 0 failed, 0 deferred`, exit 0.
- `docker compose ... up` → all services `healthy`/`Up`; only `127.0.0.1:8000`
  (and `:9090` with the metrics profile) published.
- `GET /healthz` → HTTP 200, body `{"status": "ok"}`.
- `GET /` → HTTP 200, body with `hostname`, `service`, `port`.
- Redis has **no** published port (internal-only over `appnet`).

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `validate.sh` gate 3 prints `[MISS] labs/<x>` and exits 1 | a referenced module was renamed/moved/deleted | restore the module or fix the path in `tests/check_references.sh` — this is the gate doing its job (the capstone must not reference dead paths). |
| `docker compose build` fails on `COPY app/ ...` | wrong build context | the context is `../docker-containers`; run compose from `labs/capstone`, not elsewhere. |
| `curl: (7) Connection refused` on `:8000` | app still starting, or you skipped `--build` | wait for `depends_on: redis healthy`; check `docker compose ... ps` and `logs app`. |
| Prometheus container restarts / `/-/ready` slow | first-run TSDB init can take >15 s | give it ~20 s; it starts cleanly (`read_only` root + `tmpfs:/prometheus`). |
| `capstone-app` Prometheus target shows **DOWN** | the demo app serves `/healthz` (JSON), not `/metrics` | expected — instrumenting `/metrics` is the `labs/observability` exercise; the target is declared to document intent. |

There is no `broken/` fixture in this module by design: the capstone's "broken
state" is a **dangling reference**, and `tests/check_references.sh` is the
reproducible detector for it (delete or rename a referenced path and re-run gate 3
to see it fail). Per-component broken fixtures live in their own modules (e.g.
`labs/kubernetes-fundamentals/broken/deployment-oomkilled.yaml`).

## Cleanup

Idempotent teardown of everything the demo creates:

```bash
# Remove containers, the named network, and volumes for BOTH profiles:
docker compose -f docker-compose.demo.yaml --profile metrics down -v

# Confirm nothing is left:
docker compose -f docker-compose.demo.yaml ps           # -> no rows
docker network ls | grep capstone-demo || echo "no capstone networks"

# Optional: remove the built image:
docker image rm capstone-app:demo 2>/dev/null || true
```

The **cloud profile** is plan-only by default: nothing is applied unless you run
`terraform apply` in `labs/terraform-aws-foundations` yourself. If you did,
tear it down there: `terraform destroy` (and confirm with `terraform plan` showing
"No changes"). This module provisions **no cloud resources** on its own.

## Security considerations

- **Non-root, hardened by default:** the app runs as UID 10001; both services use
  `read_only` root filesystems, `cap_drop: [ALL]`, and `no-new-privileges`. The
  same controls are restated in the k8s manifests.
- **Least exposure:** only `127.0.0.1:8000` (and `:9090` with metrics) is
  published; Redis has no host port. Never bind these to `0.0.0.0` on a shared box.
- **No secrets committed:** the demo uses no credentials; the cloud profile keeps
  secrets in k8s Secrets / a secrets manager (see the checklist gap) and never in
  images or git. `.dockerignore`/`.gitignore` keep build context and state clean.
- **Image scanning** happens in CI (`labs/cicd-pipelines`), not here; the demo
  image is intentionally tooling-free (no curl/wget/shell extras → smaller CVE
  surface).

## Cost considerations

- **Local demo: $0.** Pure containers; CPU/memory limits cap resource use. No
  cloud account, no network egress beyond pulling base images once.
- **Cloud profile:** costs money only if **you** run `terraform apply` in
  `labs/terraform-aws-foundations` (an EKS cluster + NAT is the main driver, very
  roughly tens of dollars/month if left running). It is plan-only by default. To
  stay at $0, never apply, or `terraform destroy` immediately after a demo and add
  the budget alarm noted in the readiness checklist.

## Instructor answer key

The reference implementation **is** this module's committed files (there is no
separate `solution/` because the capstone integrates rather than re-codes):
`architecture/architecture.mmd`, both `adr/*.md`, `production-readiness-checklist.md`,
`runbook.md`, `docker-compose.demo.yaml`, and `tests/check_references.sh`. The
student works from `starter/capstone-brief.md` + `starter/adr/NNNN-template.md`.

Non-obvious grading points:

- **Reuse, not duplication.** The demo must *build* the image from
  `../docker-containers` (the build context proves it). A submission that copies
  app source into the capstone fails the "integration" intent — dock it.
- **Honest checklist.** Every `[x]` must resolve to a real path. A checklist that
  ticks everything green with no evidence is the exact anti-pattern the course
  artifact standard forbids; cap the score.
- **ADRs record a real trade-off.** ADR-0002 must name what is *rejected* and a
  "revisit when…" trigger, not just assert a choice.
- **Reference checker actually fails.** Have students delete a referenced path and
  re-run gate 3 to prove the detector works.

Common wrong answers: forking the app instead of reusing it; a "production-ready"
claim with single-replica + no DR honestly unmarked; a runbook of prose with no
runnable commands; Mermaid boxes that don't map to real modules.
