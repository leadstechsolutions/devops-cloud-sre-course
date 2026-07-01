# Module: helm-charts

> **Status:** Validated — `./validate.sh` runs **all 17 gates** and exits `0`
> (`17 passed, 0 failed, 0 deferred`) in this environment with `helm v3.16.3`,
> `kubeconform v0.6.7`, and `kubectl v1.34.2` against the live `kind-course` cluster.
> The seven authoritative gates are now part of the runner: `helm lint`, `helm template`
> for default **and** prod values, `helm template | kubeconform -strict` for default and
> prod, and a **real server-side API validation** (`helm template | kubectl --context
> kind-course apply --dry-run=server -f -`) for both value sets. Each is guarded by
> `command -v` (and the kubectl gate by apiserver reachability) so it still degrades to a
> `[DEFER]` note on a host without the tool or a cluster. See [Validation](#validation)
> for the captured output.
> **Maps to:** Week 13 Class 01–04 (Helm chart anatomy, templating/values, conditional
> resources, chart testing). Consumes the container image patterns from
> [`docker-containers`](../docker-containers/) (W10) and the raw manifests from
> [`kubernetes-fundamentals`](../kubernetes-fundamentals/) (W11/W12); the chart is
> reused by the [`capstone`](../capstone/) (W23/W24) to deploy the sample app.

## What you will build
A production-shaped Helm chart, `chart/webapp/`, that packages a stateless HTTP app into
a single installable unit. From one set of values it renders a `Deployment` (with liveness
and readiness probes, CPU/memory requests+limits, a non-root pod/container security
context, and a config-checksum annotation that rolls pods when config changes), a
`Service`, a `ServiceAccount`, and a `ConfigMap` consumed via `envFrom`. Two resources are
**conditional**: an `Ingress` (rendered only when `ingress.enabled`) and a
`HorizontalPodAutoscaler` (only when `autoscaling.enabled`). A `values-prod.yaml` override
flips both on, pins the image tag, raises resources, and adds TLS + pod anti-affinity. A
`helm test` hook (`templates/tests/test-connection.yaml`) smoke-tests the Service. The end
state: `helm template webapp ./chart/webapp` renders 5 valid manifests with defaults and 7
with `-f values-prod.yaml`, all passing `kubeconform -strict`.

## Prerequisites
- `python3 >= 3.10` with **PyYAML** (used by the offline pre-render gate). Present here.
- `bash >= 4` (the `validate.sh` runner).
- **For the authoritative gates:** `helm >= 3.12`, `kubeconform >= 0.6`, and `kubectl`
  with a reachable cluster (here: context `kind-course`). `validate.sh` runs these when
  present and skips them gracefully (`[DEFER]`) otherwise, so none is required to complete
  the lab's offline gates.
- Prior modules whose output this reuses: `kubernetes-fundamentals` (you should already be
  comfortable with Deployment/Service/Ingress/HPA manifests — this module templates them).

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid). In short: `Chart.yaml` +
`values*.yaml` + `_helpers.tpl` feed Helm's renderer, which emits the Kubernetes objects.
The `ConfigMap` is mounted into the `Deployment` via `envFrom`; the `Service` selects the
Deployment's pods by the shared selector labels; the `Ingress` backends to the `Service`;
the `HPA` targets the `Deployment`; and the `helm test` pod `wget`s the `Service`. Two
objects (`Ingress`, `HPA`) only appear when their feature flag is set.

## Repository layout
```
solution/chart/webapp/        # reference chart — check yourself against this
  Chart.yaml                  # apiVersion v2, name/version/appVersion, kubeVersion
  values.yaml                 # dev defaults: image, replicas, resources, probes, ingress,
                              #   autoscaling, podSecurityContext, config
  values-prod.yaml            # prod override: ingress+TLS on, HPA on, anti-affinity
  .helmignore
  templates/
    _helpers.tpl              # name / fullname / labels / selectorLabels / image helpers
    deployment.yaml           # probes, resources, securityContext, config checksum
    service.yaml              # ClusterIP :80 -> :8080
    ingress.yaml              # gated on .Values.ingress.enabled
    hpa.yaml                  # gated on .Values.autoscaling.enabled
    configmap.yaml            # range over .Values.config
    serviceaccount.yaml       # gated on .Values.serviceAccount.create
    NOTES.txt                 # post-install usage notes
    tests/test-connection.yaml# helm test hook (wget the Service)
starter/chart/webapp/         # SAME chart, but deployment.yaml has 4 TODO gaps
tests/
  prerender.py               # offline {{...}}-stripping YAML structural checker
  test_prerender.py          # unit tests proving the pre-render gate has teeth
broken/
  deployment.yaml            # injected indentation/toYaml bug for the troubleshooting lab
docs/architecture.mmd
validate.sh                  # runs all gates; exits non-zero on any failure
```

## Setup
From a fresh clone, no build step is needed — the chart is plain text.
```bash
cd labs/helm-charts
python3 -c "import yaml; print('PyYAML', yaml.__version__)"   # confirm the one dependency
./validate.sh                                                 # run the local gates
```
To do the lab, edit under `starter/chart/webapp/` and re-run the pre-render against it:
```bash
python3 tests/prerender.py starter/chart/webapp/templates/*.yaml
```
To render for real (where helm exists):
```bash
helm template webapp solution/chart/webapp                    # defaults
helm template webapp solution/chart/webapp -f solution/chart/webapp/values-prod.yaml
```

## Lab tasks
Work in `starter/chart/webapp/templates/deployment.yaml`. Each TODO has a "done when".

1. **TODO 1 — render the container image and pull policy.** Use the `webapp.image`
   helper (it defaults the tag to `.Chart.AppVersion` when `image.tag` is empty) and quote
   it; set `imagePullPolicy` from `.Values.image.pullPolicy`.
   *Done when:* `helm template` (or the pre-render) shows
   `image: "nginxinc/nginx-unprivileged:1.27.0"` and `imagePullPolicy: IfNotPresent`.
2. **TODO 2 — declare the named container port.** It must be named `http` (probes and the
   Service reference it by name) on `.Values.containerPort`, protocol `TCP`.
   *Done when:* the rendered Deployment has `ports: [{name: http, containerPort: 8080}]`
   and `helm template` no longer errors.
3. **TODO 3 — add the liveness and readiness probes.** Render each from the matching
   values block with `toYaml ... | nindent 12`.
   *Done when:* the Deployment shows both probes with `httpGet.port: http`.
4. **TODO 4 — add the resources block** (requests + limits) from `.Values.resources` with
   `toYaml ... | nindent 12`.
   *Done when:* the Deployment is `Guaranteed`/`Burstable` (has limits) and
   `kubeconform -strict` reports it valid.

Acceptance for the whole lab: `./validate.sh` is green AND `diff` of your rendered output
against the solution's is empty:
```bash
helm template webapp starter/chart/webapp  > /tmp/mine.yaml
helm template webapp solution/chart/webapp > /tmp/ref.yaml
diff /tmp/mine.yaml /tmp/ref.yaml && echo "MATCH"
```

## Validation
`./validate.sh` runs the gates below. **Real captured output from this environment:**

```
== validating helm-charts ==
  [PASS] yaml: Chart.yaml parses
  [PASS] Chart.yaml declares apiVersion v2
  [PASS] yaml: values.yaml parses
  [PASS] yaml: values-prod.yaml parses
  [PASS] yaml: starter values.yaml parses
  [PASS] prerender: all solution templates parse after stripping {{...}}
  [PASS] python: prerender unit tests (unittest discover)
  [PASS] prerender: broken/deployment.yaml is rejected (correctly rejected)
  [PASS] helpers: _helpers.tpl defines webapp.fullname + webapp.labels
  [PASS] shell: validate.sh syntax
  [PASS] helm: lint solution/chart/webapp
  [PASS] helm: template default values
  [PASS] helm: template prod values
  [PASS] kubeconform: default render is schema-valid (-strict)
  [PASS] kubeconform: prod render is schema-valid (-strict)
  [PASS] kubectl: default render passes server-side dry-run (real API)
  [PASS] kubectl: prod render passes server-side dry-run (real API)
== 17 passed, 0 failed, 0 deferred ==
```

### The authoritative gates, run for real (captured output)
A Helm template is not valid YAML on its own (it is YAML interleaved with Go `{{ ... }}`
actions), so the *offline* gate uses `tests/prerender.py` to strip the template actions and
confirm the remaining static skeleton parses — a fast linter aid that catches the common
indentation bug without helm. The **authoritative** gates below actually render and validate
the chart; they are wired into `validate.sh`, each guarded by `command -v <tool>` (and the
kubectl gate by apiserver reachability) so they `[PASS]` where the tooling exists and
`[DEFER]` where it does not. Real output, captured here with `helm v3.16.3`,
`kubeconform v0.6.7`, `kubectl v1.34.2`:

```text
$ helm lint solution/chart/webapp
==> Linting solution/chart/webapp
[INFO] Chart.yaml: icon is recommended
1 chart(s) linted, 0 chart(s) failed                          # exit 0

$ helm template webapp solution/chart/webapp | kubeconform -strict -summary
Summary: 5 resources found parsing stdin - Valid: 5, Invalid: 0, Errors: 0, Skipped: 0   # exit 0

$ helm template webapp solution/chart/webapp -f solution/chart/webapp/values-prod.yaml \
    | kubeconform -strict -summary
Summary: 7 resources found parsing stdin - Valid: 7, Invalid: 0, Errors: 0, Skipped: 0   # exit 0

# Real API validation against the live kind-course cluster (server-side dry-run).
# Persists nothing; the namespace below was created/deleted only to scope the run.
$ helm template webapp solution/chart/webapp \
    | kubectl --context kind-course apply --dry-run=server -f -
serviceaccount/webapp created (server dry run)
configmap/webapp-config created (server dry run)
service/webapp created (server dry run)
deployment.apps/webapp created (server dry run)
pod/webapp-test-connection created (server dry run)                                       # exit 0

$ helm template webapp solution/chart/webapp -f solution/chart/webapp/values-prod.yaml \
    | kubectl --context kind-course apply --dry-run=server -f -
serviceaccount/webapp created (server dry run)
configmap/webapp-config created (server dry run)
service/webapp created (server dry run)
deployment.apps/webapp created (server dry run)
horizontalpodautoscaler.autoscaling/webapp created (server dry run)
ingress.networking.k8s.io/webapp created (server dry run)
pod/webapp-test-connection created (server dry run)                                       # exit 0
```

Render counts confirm the conditional logic: **defaults → 5 objects** (ServiceAccount,
ConfigMap, Service, Deployment, + helm-test Pod hook; **no Ingress, no HPA**); **prod →
7 objects** (adds Ingress + HorizontalPodAutoscaler). The server-side dry-run is the
strongest gate: unlike `kubeconform` (offline schema check) it runs the manifests through the
real apiserver's admission and validation, persisting nothing.

## Expected results
- `./validate.sh` exits `0` with `17 passed, 0 failed, 0 deferred` where `helm`,
  `kubeconform`, `kubectl`, and the `kind-course` cluster are present (the seven
  authoritative gates degrade to `[DEFER]` on a host missing those tools/cluster).
- `helm template` of the default values renders the Deployment with
  `image: "nginxinc/nginx-unprivileged:1.27.0"`, both probes on the `http` port, a
  `runAsNonRoot: true` pod security context, a `readOnlyRootFilesystem: true` container
  context with three `emptyDir` scratch mounts, and CPU/memory requests **and** limits.
- Default render contains **no** `kind: Ingress` and **no** `kind: HorizontalPodAutoscaler`;
  the prod render contains exactly one of each, with `minReplicas: 3`, `maxReplicas: 20`,
  TLS secret `webapp-prod-tls`, and host `webapp.prod.example.com`.
- `kubeconform -strict` reports `Invalid: 0, Errors: 0` for both value sets.

## Troubleshooting
A real, reproducible broken state lives in [`broken/deployment.yaml`](broken/deployment.yaml).
It is the solution's Deployment template with two classic Helm bugs injected:

| Bug | Symptom | Cause | Fix |
|-----|---------|-------|-----|
| `resources: {{- toYaml .Values.resources }}` with **no** `nindent` | rendered block lands at column 0 and corrupts the container mapping | `toYaml` emits a flat block; without `nindent N` it is not re-indented under its key | add `| nindent 12` |
| `ports:` list item under-indented; `containerPort` no longer a child of the list item | `helm template \| kubeconform` → `error while parsing: missing 'kind' key`; offline pre-render → `expected <block end>, but found '?'` | a static-YAML indentation slip that the Go templater happily passes through (helm does not validate rendered YAML structure) | restore the two-space indentation so `containerPort`/`protocol` sit under `- name: http` |

Reproduce and diagnose:
```bash
# Offline gate (always available here):
python3 tests/prerender.py broken/deployment.yaml      # FAILS, exit 1 — see the parse error

# Authoritative gate (where helm + kubeconform exist):
cp -r solution/chart/webapp /tmp/brokenchart
cp broken/deployment.yaml /tmp/brokenchart/templates/deployment.yaml
helm template webapp /tmp/brokenchart | kubeconform -strict -summary    # Errors: 1, exit 1
```
Key lesson: `helm template` and even `helm lint` can *render* a structurally-broken chart
(helm lint only WARNs here, exit 0). The gate that hard-fails is
`helm template | kubeconform` (or `kubectl apply --dry-run=server`). Always run a schema
validator in CI, not just `helm lint`.

## Cleanup
Nothing in this lab creates cloud or cluster resources — `helm template` only renders to
stdout. If you went further and actually installed the chart into a cluster:
```bash
helm uninstall webapp --namespace <ns>            # removes all chart-managed objects
kubectl get all,ingress,hpa,cm,sa -n <ns> -l app.kubernetes.io/instance=webapp
#   ^ should return "No resources found" — confirms a clean teardown
helm test webapp -n <ns>                          # only valid while the release exists
```
The commands are idempotent: `helm uninstall` of an absent release exits non-zero but
changes nothing; re-running the `kubectl get` to confirm is safe. Remove the downloaded
helm/kubeconform binaries from `/tmp` if you fetched them.

## Security considerations
- **Non-root, least-privilege by default.** The pod runs as UID/GID 101
  (`nginxinc/nginx-unprivileged`), `runAsNonRoot: true`, `seccompProfile: RuntimeDefault`;
  the container drops **all** capabilities, disallows privilege escalation, and uses a
  **read-only root filesystem** (writable paths are explicit `emptyDir` mounts).
- **No secrets in `values.yaml` or the ConfigMap.** The `config` map is for non-sensitive
  settings only (it is rendered into a `ConfigMap`, which is **not** encrypted). For
  secrets, reference an externally-managed `Secret` (e.g. External Secrets Operator /
  Sealed Secrets) — never `helm install --set password=...` (it lands in release history).
- **Do not commit** rendered manifests containing real hostnames/tokens, real TLS material,
  or a populated `imagePullSecrets`. The TLS `secretName` in `values-prod.yaml` references a
  Secret created out-of-band (e.g. by cert-manager), it does not embed a key.
- **Pin image tags** in prod (`values-prod.yaml` sets `1.27.0`); never `:latest`.
- **Scan the chart in CI**: `helm template ... | kubeconform -strict` for schema, plus a
  policy scanner (`checkov`/`kube-score`/`conftest`) for the security posture above.

## Cost considerations
**$0.** This module renders templates locally; it provisions no cloud resources and starts
no long-running processes. If you optionally install the chart into a cluster you already
pay for, the workload requests `50m` CPU / `64Mi` memory per replica (dev) — negligible,
and removed entirely by `helm uninstall`. To stay at $0, stop at `helm template`/the local
gates and do not install into a paid cluster.

## Instructor answer key
The complete reference is [`solution/chart/webapp/`](solution/chart/webapp/). The starter
differs only in `templates/deployment.yaml` (4 TODOs). Grading points and common wrong
answers:

- **TODO 1 (image):** must use the `webapp.image` helper (so the appVersion fallback
  works), and **quote** the value — otherwise a tag like `1.27` is parsed as a float.
  Common error: hard-coding `image: nginx:latest`, defeating the values abstraction.
- **TODO 2 (port name):** the port **must** be named `http`; the probes and Service refer
  to it by name. A numeric `port:` in the probe instead of `port: http` is the usual slip.
- **TODO 3 (probes):** both `livenessProbe` and `readinessProbe` required, each with
  `| nindent 12`. Forgetting `nindent` reproduces the `broken/` bug. A frequent mistake is
  giving liveness too aggressive a `failureThreshold`, causing crash loops under load.
- **TODO 4 (resources):** **limits are mandatory** — without them the pod is BestEffort and
  the HPA's `targetCPUUtilizationPercentage` has no request to compute a percentage against,
  so autoscaling silently never triggers. This is the highest-value teaching point.
- **Conditional resources:** verify the student understands gating by asking them to render
  with and without `-f values-prod.yaml` and count objects (5 vs 7).
- **Troubleshooting exercise** answer key is the table in [Troubleshooting](#troubleshooting);
  the canonical fix is `| nindent 12` on `resources` and restoring the `ports` indentation.
