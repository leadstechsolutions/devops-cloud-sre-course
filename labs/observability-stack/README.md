# Module: observability-stack

> **Status:** Validated — `./validate.sh` exits 0 (59 gates pass, 1 documented
> live DEFER). The burn-rate alert is proven to FIRE on synthetic data by
> `promtool test rules`, and the whole stack was deployed to the live
> `kind-course` cluster: `run-demo.sh` scraped real `/metrics`, the RED recording
> rules returned non-zero data over the Prometheus HTTP API, and all three
> alerting rules loaded in the running server. The captured run is committed as
> [`LIVE-OBS-EVIDENCE.txt`](LIVE-OBS-EVIDENCE.txt).
> **Maps to:** Week 16 (metrics, RED, dashboards, recording rules) and Week 21
> (SLOs, error budgets, multi-window multi-burn-rate alerting). This lab differs
> from the sibling [`observability`](../observability/) lab, which *authors* rules
> offline; here you **run the stack** on Kubernetes.

## What you will build
A complete, runnable metrics pipeline on kind in namespace `lab-obs`:

- **`sample-api`** — a tiny, dependency-free Python service that exposes Prometheus
  text exposition format on `/metrics` with the two classic RED instruments:
  a `http_requests_total` **counter** and a `http_request_duration_seconds`
  **histogram**. Routes include `/error` (500s) so you can drive a real error ratio.
- **Prometheus** — a single Deployment + ConfigMap (no kube-prometheus-stack, no
  operator) that discovers the app pods via Kubernetes pod service-discovery and
  scrapes `/metrics`.
- **RED recording rules** — rate, error-ratio (over 5m/30m/1h/6h windows) and
  p50/p99 latency, computed once so the alerts and the dashboard agree.
- **A multi-window, multi-burn-rate alerting rule** for a 99.9% availability SLO,
  plus a `promtool` **unit test** that feeds synthetic series and asserts the
  fast-burn alert FIRES (and stays silent when healthy) — deterministic evidence
  the alert works, with no live cluster.
- **A Grafana RED dashboard** (JSON) reading the recording rules.
- **`run-demo.sh`** — deploys everything to kind, drives load, queries PromQL, and
  captures the real output to a committed evidence file.

## Prerequisites
- `python >= 3.10` (the app and tests are stdlib-only — no `pip install`).
- `promtool >= 2.5` (Prometheus) — the headline gate.
- `kubeconform >= 0.6`, `yamllint`, `shellcheck`, `hadolint` — schema/style gates.
- For the live demo only: `docker >= 24`, `kind >= 0.24`, `kubectl`, and a running
  kind cluster (the course cluster `kind-course` is used by default).
- No cloud account, no credentials, **$0**. Everything runs locally.

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd). In short: the app pods carry
`prometheus.io/{scrape,port,path}` annotations; Prometheus (running under a
least-privilege namespaced ServiceAccount/Role) uses `kubernetes_sd_configs`
role `pod` to discover and scrape them; recording rules distil the raw metrics
into RED signals; the burn-rate alerting rules and the Grafana dashboard both read
those recording rules so they can never disagree about what "error rate" means.

## Repository layout
```
starter/      # intentionally incomplete — TODOs in app.py, the rules, prometheus.yml, dashboard
  app/        #   app.py (instrument /metrics), Dockerfile
  prometheus/ #   prometheus.yml (+ rules/) with the sample-api job + burn-rate alert stubbed out
  k8s/        #   manifests (sample-api pod is missing its scrape annotations)
  grafana/    #   one panel wired; add the rest
solution/     # reference implementation — complete and validated
  app/        #   app.py, Dockerfile, .dockerignore
  prometheus/ #   prometheus.yml, rules/{recording,alerting}.rules.yml  (source of truth)
  k8s/        #   00-namespace .. 40-prometheus (30-prometheus-config is GENERATED)
grafana/      # solution dashboard JSON
tests/        # burn_rate_test.yml (promtool) + test_app.py (app unit tests)
scripts/      # gen-configmap.py (derives the ConfigMap), loadgen.py (demo traffic)
run-demo.sh   # RUN_LIVE=1 live drive on kind -> LIVE-OBS-EVIDENCE.txt
validate.sh   # fast offline gates (this is what marks the lab Validated)
LIVE-OBS-EVIDENCE.txt  # committed output of a real run-demo.sh run
```

## Setup
From a fresh clone, the offline gates need no setup:
```bash
cd labs/observability-stack
./validate.sh            # ~10s, exits 0
```
For the live demo you need a kind cluster. The course cluster works as-is:
```bash
kubectl config use-context kind-course
RUN_LIVE=1 ./run-demo.sh   # builds the image, deploys, queries, tears down
```

## Lab tasks
Work in `starter/`; check yourself against `solution/`.

1. **Instrument the app.** Implement `Metrics.observe` and `Metrics.render` in
   `starter/app/app.py` so `/metrics` emits valid exposition format.
   *Done when:* `python3 -m pytest tests/test_app.py` passes (point it at the
   starter by editing the import, or copy your file over the solution path).
2. **Write the RED recording rules.** Add the 30m/1h/6h error-ratio rules and the
   p99/p50 duration rules in `starter/prometheus/rules/recording.rules.yml`.
   *Done when:* `promtool check rules` reports all 8 rules.
3. **Write the burn-rate alert.** Add `SampleApiErrorBudgetBurnFast` (14.4x,
   1h+5m) and `SampleApiErrorBudgetBurnSlow` (6x, 6h+30m) in the starter alerting
   file. *Done when:* `promtool test rules tests/burn_rate_test.yml` passes —
   the fast-burn alert fires on the synthetic 5% error series.
4. **Add pod discovery.** Add the `sample-api` scrape job (pod SD + relabels) to
   `starter/prometheus/prometheus.yml`, and the `prometheus.io/*` annotations to
   the pod template in `starter/k8s/10-sample-api.yaml`.
   *Done when:* `promtool check config` passes and (live) `up{job="sample-api"}`
   returns `1` for both pods.
5. **Finish the dashboard.** Add the error-ratio, latency, and burn-rate panels to
   `starter/grafana/sample-api-red.json`. *Done when:* `python3 -m json.tool`
   parses it and every panel references a recording rule.
6. **Run it.** `RUN_LIVE=1 ./run-demo.sh` and confirm the RED queries return data.
   *Done when:* your `LIVE-OBS-EVIDENCE.txt` shows non-zero rate and error ratio.

## Validation
`./validate.sh` runs all offline gates. Key commands and expected output:

| Gate | Command | Expected |
|------|---------|----------|
| App compiles | `python3 -m py_compile solution/app/app.py` | exit 0 |
| App tests | `python3 -m unittest discover -s tests` | 11 tests OK |
| Rules valid | `promtool check rules solution/prometheus/rules/*.yml` | `SUCCESS: 8 rules`, `SUCCESS: 3 rules` |
| Config valid | `cd solution/prometheus && promtool check config prometheus.yml` | `SUCCESS: ... valid prometheus config` |
| **Alert fires** | `promtool test rules tests/burn_rate_test.yml` | `SUCCESS` |
| Manifests | `kubeconform -strict -summary solution/k8s/*.yaml` | `Valid: 9` |
| Dashboard | `python3 -m json.tool grafana/sample-api-red.json` | parses |
| Dockerfile | `hadolint solution/app/Dockerfile` | no findings |

The single source of truth for the Prometheus config + rules is
`solution/prometheus/`; the in-cluster ConfigMap (`k8s/30-prometheus-config.yaml`)
is **generated** from it by `scripts/gen-configmap.py`. `validate.sh` regenerates
and diffs it, so editing a rule without regenerating fails the "configmap in sync"
gate. Regenerate with `python3 scripts/gen-configmap.py --variant solution`.

## Expected results
- `./validate.sh` → `== 59 passed, 0 failed, 1 deferred ==`, exit 0.
- `promtool test rules` → `SUCCESS` (the fast-burn alert fires at a synthetic 5%
  error ratio = 50x the budget; healthy traffic fires nothing).
- Live demo (`LIVE-OBS-EVIDENCE.txt`): `up{job="sample-api"}` = `1` for 2 pods;
  `job:http_requests:rate5m` ≈ 4 req/s; `job:http_requests_error_ratio:rate5m`
  ≈ 0.099 (the injected 10%); `job:http_request_duration_seconds:p99` present;
  and `/api/v1/rules` lists `SampleApiErrorBudgetBurnFast/Slow` +
  `SampleApiHighLatencyP99` as loaded alerts.

## Troubleshooting
Real, reproducible failures observed while building this lab:

- **`rate()` / error ratio return `0` / `NaN` right after a load burst.**
  Symptom: `job:http_requests:rate5m` is `0` and `error_ratio` is `NaN` even
  though `http_requests_total` shows 800 requests. Cause: `rate(x[5m])` is
  `(last - first)/window`; if all traffic lands between two scrapes the counter
  is flat across every sample in the window, so the increase is `0` and `0/0 =
  NaN`. Fix: drive load **spread over time** (`loadgen.py --duration 150`) so the
  counter increases across several 15s scrapes. This is why `run-demo.sh` paces
  the load instead of bursting it.
- **Pods discovered but `up == 1` while metrics are missing.** Cause: the
  `prometheus.io/scrape` annotation is on the wrong object. It must be on the
  **pod template** (`spec.template.metadata.annotations`), not the Deployment or
  Service — pod SD reads pod annotations. The starter omits these on purpose
  (task 4); the `starter incomplete` gate proves the gap is real.
- **`promtool test rules` fails with an annotation mismatch.** Cause:
  `exp_annotations` must match the rule's *rendered* template exactly, including
  `{{ $value | humanizePercentage }}`. With a sustained 5% ratio it renders as
  `5%`; any drift in the rule's `description` breaks the test. This is a feature:
  the test pins the human-facing alert text, not just the firing condition.
- **`promtool check config` can't find the rule files.** The `rule_files` paths in
  `solution/prometheus/prometheus.yml` are **relative** (`rules/...`) and resolve
  from that directory — run `promtool check config` from inside
  `solution/prometheus/`. The generated ConfigMap rewrites them to the absolute
  in-cluster mount path `/etc/prometheus/rules/...`.

## Cleanup
`run-demo.sh` always deletes the `lab-obs` namespace on exit (via a `trap`), so a
normal run leaves nothing behind. If a run was interrupted:
```bash
kubectl --context kind-course delete ns lab-obs --ignore-not-found
docker rmi sample-api:1.0.0 2>/dev/null || true     # remove the demo image
```
The lab never creates a kind cluster (it reuses `kind-course`), so there is no
cluster to delete. Confirm clean state:
```bash
kubectl --context kind-course get ns | grep lab-obs   # (no output = clean)
```

## Security considerations
- **No secrets** are committed or required; the app needs none.
- **Least privilege:** Prometheus runs under a namespaced `Role` (not a
  `ClusterRole`) granting only `get/list/watch` on `pods/services/endpoints` in
  `lab-obs`, so a compromised Prometheus cannot enumerate the whole cluster.
- **Hardened pods:** both Deployments run `runAsNonRoot` with a fixed non-root
  UID, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, and all
  capabilities dropped; the namespace enforces the PSA `restricted` profile.
- **Image:** built `FROM python:3.12-slim` with no third-party packages, so the
  build touches no package index and pulls in no transitive CVEs from app deps.
  Scan it with `grype sample-api:1.0.0` / generate an SBOM with `syft` in CI.
- **Do not commit** the local `sample-api:1.0.0` image or any kube context files.

## Cost considerations
**$0.** Everything runs on a local kind cluster; no cloud resources are created.
The only local footprint is a ~177 MB container image (removed by cleanup) and an
ephemeral `emptyDir` TSDB that disappears with the Prometheus pod. There is nothing
to bill and nothing left running after cleanup.

## Instructor answer key
The reference implementation is `solution/`. Non-obvious grading points:

1. **The burn-rate test is the load-bearing artifact.** A learner can write a
   plausible-looking alert that never fires (e.g. `or` instead of `and`, or a
   single window). `promtool test rules tests/burn_rate_test.yml` is the gate
   that catches it — require a PASS, not just `check rules`.
2. **Recording rules must be the single source of truth.** Dock points if the
   alert or the dashboard recomputes the error ratio inline instead of reading
   `job:http_requests_error_ratio:rate*` — that is how alerts and graphs drift.
3. **Annotations are tested.** The `exp_annotations` block pins the rendered
   alert text; a correct firing condition with a wrong/incomplete `description`
   still fails. This is intentional (the runbook URL and humanized value matter
   on-call).
4. **Pod-SD annotations belong on the pod template.** Common wrong answer: putting
   `prometheus.io/scrape` on the Service or Deployment metadata — pod SD won't see
   it. The live `up{job="sample-api"}` check (in `run-demo.sh`) catches this.
5. **ConfigMap drift.** If a learner hand-edits `30-prometheus-config.yaml` instead
   of the source + regenerator, the `configmap in sync` gate fails. The intended
   workflow is edit `solution/prometheus/*` then
   `python3 scripts/gen-configmap.py`.
6. **Live vs. offline split.** The heavy kind drive is correctly gated behind
   `RUN_LIVE=1`; `validate.sh` stays fast. Evidence of a real run is committed in
   `LIVE-OBS-EVIDENCE.txt` — confirm its query results are non-zero.

### Class Artifacts & Validation
| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | solution/app/app.py | python | Instrumented `/metrics` app (counter + histogram) | `python3 -m py_compile solution/app/app.py` | PASS |
| 2 | tests/test_app.py | python | App registry + exposition-format unit tests | `python3 -m unittest discover -s tests` | PASS (11 tests) |
| 3 | solution/prometheus/rules/recording.rules.yml | promql | RED recording rules | `promtool check rules` | PASS (8 rules) |
| 4 | solution/prometheus/rules/alerting.rules.yml | promql | Multi-burn-rate SLO alerts | `promtool check rules` | PASS (3 rules) |
| 5 | tests/burn_rate_test.yml | promtool | Unit test: burn-rate alert FIRES on synthetic 5% errors | `promtool test rules tests/burn_rate_test.yml` | PASS |
| 6 | solution/prometheus/prometheus.yml | promql | Scrape config (pod SD) + rule_files | `promtool check config` | PASS |
| 7 | solution/k8s/*.yaml | kubernetes | Namespace, app, RBAC, Prometheus, ConfigMap | `kubeconform -strict` | PASS (9 resources) |
| 8 | grafana/sample-api-red.json | dashboard | RED + burn-rate Grafana dashboard | `python3 -m json.tool` | PASS |
| 9 | solution/app/Dockerfile | docker | Non-root, dependency-free app image | `hadolint` | PASS |
| 10 | run-demo.sh + LIVE-OBS-EVIDENCE.txt | shell | Live deploy + PromQL query on kind | `RUN_LIVE=1 ./run-demo.sh` | PASS (evidence committed) |
