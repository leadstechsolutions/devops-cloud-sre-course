# Module: platform-golden-path

> **Status:** Validated — `./validate.sh` exits 0 with **32 gates passing** in
> this environment (shellcheck, scaffold run + behaviour, example==fresh-output
> diff, py_compile + unittest, hadolint, actionlint, helm lint/template,
> kubeconform on chart + plain manifests, yamllint, and a real `docker build` of
> the generated service whose `/healthz` returns 200). The full live drive
> (`RUN_LIVE=1 ./drill.sh`) was executed against the `kind-course` cluster: the
> generated chart installed, both pods went `1/1 Running` with the expected
> non-root/read-only/caps-dropped securityContext, and `helm test` reached
> `Phase: Succeeded`. Captured output is committed at
> `docs/evidence/drill-output.txt`. `ruff` and `trivy` are **DEFERRED** (not
> installed here) — they are wired into the generated CI and documented below.
> **Maps to:** Week 20 (2nd portfolio project — platform/golden-path). Reuses the
> hardening patterns from `docker-containers`, `helm-charts`, and `cicd-pipelines`.

## What you will build

A self-service **golden path**: a parametrized service *template* plus a
generator (`scaffold.sh`) that turns it into a complete, production-ready
microservice. `./scaffold.sh orders` produces — in seconds — a service dir
containing a stdlib-only Python HTTP app with `/healthz`, `/readyz`, `/metrics`;
a multi-stage **non-root** Dockerfile (uid 10001, read-only rootfs, all caps
dropped); a Helm chart with probes, resource requests+limits, securityContext,
a token-less ServiceAccount, and optional HPA/NetworkPolicy; plain k8s manifests;
a GitHub Actions CI pipeline (`ruff`+`hadolint` lint → `unittest` → `helm
lint/template/kubeconform` → `docker build` + `trivy` scan that fails on
HIGH/CRITICAL CVEs); and a README. The committed `solution/example-service/` is
the literal output of running the generator, so reviewers see the end state.

## Prerequisites

- `bash >= 5`, `shellcheck`, `python >= 3.10`
- `docker >= 24` (for the build gate and the drill)
- `helm >= 3.16`, `kubeconform >= 0.6`, `yamllint`, `hadolint`, `actionlint`
- For the live drill only: `kind` + the `kind-course` cluster (context
  `kind-course`)
- Prior modules whose patterns this reuses: `docker-containers` (multi-stage,
  non-root), `helm-charts` (chart shape), `cicd-pipelines` (CI gates)

## Architecture

See `docs/architecture.mmd` (Mermaid). In short: a developer runs
`scaffold.sh <name>`, which copies `template/` and substitutes the
`__SERVICE_NAME__` placeholder, emitting a working service. That service's CI
builds and scans an image, pushes to a registry, and the chart deploys it to
Kubernetes. The paved-road defaults (security, probes, limits, scanning) are
baked into the template, so every generated service inherits them. The design
rationale + an ADR are in `docs/golden-path.md`.

## Repository layout

```
starter/                 intentionally incomplete — you implement the TODOs
  scaffold.sh            generator with 4 TODOs
  template/              skeleton with gaps (app, Dockerfile, chart, CI)
  README.md
solution/                reference implementation
  scaffold.sh            the working generator
  template/              the paved road (parametrized with __SERVICE_NAME__)
  example-service/       the OUTPUT of `./scaffold.sh example-service`
docs/
  golden-path.md         paved-road explainer + ADR-001
  architecture.mmd       Mermaid diagram
  evidence/drill-output.txt   captured live drive (committed)
drill.sh                 RUN_LIVE=1 end-to-end drive (build+kind+helm test)
validate.sh              fast gates (exit non-zero on failure)
.yamllint.yml            relaxed CI-idiomatic yamllint ruleset
```

## Setup

From a fresh clone, nothing to install for the template/app (stdlib only):

```bash
cd labs/platform-golden-path
./validate.sh          # runs all fast gates
```

## Lab tasks

Work in `starter/`. Each task has an acceptance check.

1. **Complete `scaffold.sh`** (TODO 1–4): validate the name as a DNS-1123 label
   (`<= 53` chars), refuse to overwrite, substitute `__SERVICE_NAME__` in every
   text file, fail on any leftover placeholder.
   *Done when:* `./scaffold.sh demo /tmp/demo && ! grep -rIl __SERVICE_NAME__ /tmp/demo`
2. **Finish the app** (`template/app/main.py`): `build_payload()`, the `/readyz`
   200/503 logic, graceful SIGTERM.
   *Done when:* `cd /tmp/demo && python -m unittest discover -s tests` passes (7 tests).
3. **Harden the Dockerfile**: non-root uid 10001, copy only app code, HEALTHCHECK.
   *Done when:* `hadolint Dockerfile` is clean and `docker run ... id` shows uid 10001.
4. **Harden the chart Deployment**: pod+container `securityContext`, liveness +
   readiness probes, writable `/tmp` emptyDir.
   *Done when:* `helm template demo chart | kubeconform -strict -summary` is valid.
5. **Complete CI** (`template/.github/workflows/ci.yml`): add `lint`, `helm`,
   `build-scan` jobs.
   *Done when:* `actionlint .github/workflows/ci.yml` is clean.

Then run the module `./validate.sh` — it must exit 0.

## Validation

`./validate.sh` runs these gates (fast; the heavy drive is in `drill.sh`):

```bash
./validate.sh
```

Key gates and **expected output**:

```
[PASS] scaffold generates a service (validate-svc)
[PASS] generated service has NO placeholder
[PASS] scaffold REJECTS invalid name 'Bad_Name' (expected)
[PASS] scaffold REFUSES to overwrite existing dir (expected)
[PASS] committed example-service matches fresh scaffold output
[PASS] unit tests: example-service          # 7 tests
[PASS] hadolint: example-service/Dockerfile
[PASS] actionlint: example ci.yml
[PASS] helm lint: example-service/chart
[PASS] kubeconform: default render (-strict)            # Valid: 4
[PASS] kubeconform: autoscaling+netpol render (-strict) # Valid: 6
[PASS] END-TO-END: docker build generated svc + /healthz == 200
== 32 passed, 0 failed (plus DEFERRED — see README) ==
```

The full live drive (multi-minute; needs docker + kind):

```bash
RUN_LIVE=1 ./drill.sh          # scaffold -> build -> run -> kind deploy -> helm test
RUN_LIVE=1 SKIP_K8S=1 ./drill.sh   # scaffold -> build -> run only
```

## Expected results

- `validate.sh` → `32 passed, 0 failed`, exit 0.
- Generated image size ≈ **177 MB** (python:3.12-slim base; stdlib app, no wheels).
- Container runs as `uid=10001(app)`; `/healthz` → `200 {"status":"ok"}`.
- In-cluster: 2/2 pods `1/1 Running`; effective container securityContext is
  `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001}`;
  `helm test` → `Phase: Succeeded`. (All captured in `docs/evidence/drill-output.txt`.)

## Troubleshooting

Real, reproducible failures from building this lab:

| Symptom | Cause | Fix |
|---------|-------|-----|
| `CreateContainerConfigError` / pod won't start, events show *"container has runAsNonRoot and image will run as root"* | Image `USER` not set (or set to a name the runtime can't resolve to a numeric uid) while the pod sets `runAsNonRoot: true`. | Set a **numeric** `USER 10001:10001` in the Dockerfile, matching `runAsUser` in values. The starter Dockerfile omits `USER` on purpose — that is the bug to fix in task 3. |
| App crashes writing logs/temp, `Read-only file system` | `readOnlyRootFilesystem: true` with no writable mount. | Mount an `emptyDir` at `/tmp` (the chart does this; the starter deployment omits it — task 4). |
| `helm lint` fails: *"chart name must match a DNS-1123…"* run **on the template** | The template's `Chart.yaml` name is the literal `__SERVICE_NAME__` placeholder, which is not a valid chart name. | This is expected — helm gates run on the **generated** chart, not the template. `validate.sh` lints `example-service/chart`, never `template/chart`. |
| `scaffold.sh` leaves `__SERVICE_NAME__` in some files | `sed` only rewrote a subset, or a binary file was skipped. | The post-condition `grep -rIl __SERVICE_NAME__` catches this and exits non-zero; ensure the substitution loop covers all text files. |
| Generated service name like `My_Svc` blows up later in `helm install` | No name validation. | `scaffold.sh` rejects non-DNS-1123 names up front (task 1); try `./solution/scaffold.sh Bad_Name /tmp/x` — it exits 1 with a clear message. |

**Broken-state drill:** the `starter/template/chart/templates/deployment.yaml`
and `starter/template/Dockerfile` are themselves the reproducible broken state —
they generate a service whose pod is rejected by `runAsNonRoot` and whose chart
lacks probes/limits. Scaffold from the starter, deploy, observe the failure,
then fix per tasks 3–4 and re-deploy.

## Cleanup

`validate.sh` and `drill.sh` clean up after themselves (temp dirs, the built
image, the container, and the kind namespace are removed on exit). To confirm
nothing is left:

```bash
kubectl --context kind-course get ns | grep pgp- || echo "no namespaces left"
docker images | grep pgp-                          || echo "no images left"
kind get clusters                                  # only 'course'
find . -name __pycache__                            # none (gitignored + cleaned)
```

If a drill was interrupted, remove its namespace and image manually:

```bash
kubectl --context kind-course delete ns -l '' --field-selector metadata.name=<pgp-...>
docker rmi pgp-drill:<run-id>
```

## Security considerations

- **Never commit secrets.** The generated app reads config from env vars only.
- **Least privilege everywhere:** non-root uid, read-only rootfs, all Linux
  capabilities dropped, `allowPrivilegeEscalation: false`, `seccompProfile:
  RuntimeDefault`, and `automountServiceAccountToken: false` (the app needs no
  Kubernetes API access).
- **Supply chain:** the runtime app is stdlib-only (no `requirements.txt`), so
  there are no third-party runtime packages to audit; the only deps are
  developer/CI tools in `requirements-dev.txt`. The generated CI runs a `trivy`
  image scan that **fails the build** on HIGH/CRITICAL CVEs (`--ignore-unfixed`).
- **Image hygiene:** `.dockerignore` keeps tests, chart, and `.git` out of the
  build context; the runtime stage copies only `app/` from the build stage.
- A default-deny `NetworkPolicy` is provided (off by default; needs a
  policy-enforcing CNI such as Calico/Cilium).

## Cost considerations

**$0.** Everything runs locally: a local `kind` cluster and local `docker`
builds. No cloud resources, no AWS, nothing billable. The generated CI runs on
GitHub-hosted runners (free tier for public repos); the `trivy`/`hadolint`
actions pull public images only.

## Instructor answer key

- Reference implementation: `solution/` (generator, template, and the generated
  `example-service/`). `validate.sh` gate 3 **diffs** `example-service` against a
  fresh `scaffold.sh` run, so the committed output is provably the real output.
- Non-obvious grading points:
  - **The placeholder must be a no-op token.** `__SERVICE_NAME__` is chosen so
    every template file still parses/compiles/lints *before* substitution — that
    is why `template/` is itself validated (py_compile, hadolint, actionlint,
    yamllint) in `validate.sh`. A learner who uses `{{SERVICE_NAME}}` or `$NAME`
    breaks that property (Python won't compile, YAML may not parse). Accept any
    no-op placeholder; dock for one that makes the template un-lintable.
  - **Helm gates belong on the *generated* chart**, not the template (whose name
    is the placeholder). A submission that runs `helm lint template/chart` and
    "fixes" it by hardcoding a name has missed the point.
  - **Name validation is the highest-value gate.** Rejecting `Bad_Name` up front
    is worth more than any single manifest field — it prevents a class of
    downstream failures. Full marks require both the regex *and* the length cap.
  - **Non-root requires a numeric `USER`** matching `runAsUser`; a named user or
    a missing `USER` with `runAsNonRoot: true` yields `CreateContainerConfigError`.
- Common wrong answers: forgetting the writable `/tmp` under
  `readOnlyRootFilesystem`; omitting `automountServiceAccountToken: false`;
  setting resource requests but not limits (or vice-versa); a `scaffold.sh` that
  substitutes contents but not paths (harmless here, but brittle if the template
  grows placeholder-named files — the solution handles both).
