# Module: sre-incident-response

> **Status:** Validated — every gate in `./validate.sh` passes in this
> environment (28/28 in fast mode; +1 with `RUN_LIVE=1`). Gates: `py_compile`,
> `unittest` (45 tests), starter-incompleteness check, `bash -n`, YAML parse, the
> k6 bracket/construct sanity check, a real **`k6 run`** against a local
> `payments-api` mock (p95 ≈ 48ms, 0% failed, exit 0), **`kubeconform` on the
> injected-incident drill manifests, `shellcheck` on the drill scripts, and a
> committed live drill timeline** (`solution/drill/LIVE-INCIDENT-EVIDENCE.txt`).
> The heavy **live injected-incident drill** (deploy → inject readiness fault →
> observe outage → roll back → verify) runs against the `kind-course` cluster and
> is gated behind `RUN_LIVE=1` (Gate 11); its captured timeline is committed and
> checked by Gate 10 so the evidence is verified even in fast mode. Tool-guarded
> gates (`k6`+`docker`, `kubeconform`, `shellcheck`) degrade to `[SKIP]`/parse
> fallbacks where the tool is absent. Two full-tool gates remain **DEFERRED**
> (`oslo`, `promtool`); exact commands are documented below.
> **Maps to:** Week 21 Class 0x (SLOs, error budgets, burn-rate alerting) and
> Week 22 Class 0x (incident command, runbooks, blameless postmortems, **injected
> incident drills**, load verification). Reuses the SLO concept from the
> `observability` module but for a different service and focuses on *response*,
> not collection.

## What you will build

A complete reliability + incident-response toolkit for a fictional revenue-critical
`payments-api`: an OpenSLO spec (99.9% availability **and** 99%-under-300ms latency),
multi-window multi-burn-rate Prometheus alerts that protect exactly that budget, two
tested pure-Python tools (`error_budget.py` — budget remaining %, burn rate, and
time-to-exhaustion; `nines_downtime.py` — availability target → allowed downtime per
30d/year), two operational runbooks (high-error-rate triage and an IC/Comms/Ops
incident-command process), a blameless postmortem template, and a k6 load test whose
thresholds mirror the SLOs so a too-slow or too-error-prone service fails the run.

You also run a **real injected-incident drill** on a live `kind` cluster
(`solution/drill/`): deploy a sample service to `ns/lab-incident`, **inject** a
readiness-probe regression (a "v2" whose `/healthz` returns 503) shipped with a
reckless `maxUnavailable: 100%` strategy, **observe** the resulting outage (pods
not-Ready, Service endpoints empty, a failing in-cluster curl, readiness-probe-503
events), **recover** by rolling back and restoring the safe strategy, and capture a
timestamped incident timeline to `LIVE-INCIDENT-EVIDENCE.txt`. From that real
timeline you write a blameless postmortem
(`solution/postmortems/2026-injected-readiness-failure.md`).

## Prerequisites

- `python >= 3.10` (stdlib only — no pip, no network). PyYAML is used **only** by
  the validator, not by the lab scripts.
- `bash >= 4` (for `mapfile` in `validate.sh`).
- For the real load gate: `k6 >= 0.50` **and** `docker` (the gate runs a containerised
  mock target). Both optional — `validate.sh` `[SKIP]`s that gate where they are absent.
- Optional, for the still-DEFERRED gates: `oslo` (OpenSLO CLI) and `promtool`
  (ships with Prometheus).
- **For the injected-incident drill (`solution/drill/`):** `kubectl`, a running
  `kind` cluster (the course ships `kind-course`), and `kubeconform`+`shellcheck`
  for the static drill gates. The drill pulls `nginxinc/nginx-unprivileged:1.27-alpine`
  and uses `python:3.12-alpine` for an in-cluster probe — both into the kind node;
  no host docker images are required. The drill targets context `kind-course` by
  default (override with `KUBE_CONTEXT`); it is pinned so a sibling lab that
  creates/deletes kind clusters cannot make it act on the wrong cluster.
- The SLO/runbook half needs no cloud account and no cluster. The drill half needs
  a kind cluster but no cloud account. Nothing here contacts real cloud infra.
- Prior modules: conceptually follows `observability` (where the SLIs are scraped).

## Architecture

See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid). In short:

`slo/slo.yaml` defines the reliability targets. `slo/burn-rate-alerts.yaml`
implements multi-window multi-burn-rate alerting against the 99.9% budget; a fast
burn pages on-call. The page drops the responder into `runbooks/incident-command.md`
(roles) and `runbooks/high-error-rate.md` (diagnose → mitigate → verify).
`scripts/error_budget.py` quantifies how much budget an incident consumed for the
blameless `postmortem-template.md`. `scripts/nines_downtime.py` translates targets
into downtime intuition. `load/k6-smoke.js` verifies the service against the same
latency/error thresholds the SLO encodes.

## Repository layout

```
starter/    # intentionally incomplete — burn-rate math AND drill fault injection are TODO'd
  scripts/  error_budget.py (TODOs), nines_downtime.py
  slo/      slo.yaml, burn-rate-alerts.yaml
  runbooks/ high-error-rate.md, incident-command.md
  load/     k6-smoke.js, run-load.sh
  drill/    inject.sh (fault-injection TODO), observe.sh, recover.sh (TODO),
            run-drill.sh, lib.sh, manifests/ (11-configmap-bad.yaml is TODO'd)
  postmortem-template.md
solution/   # reference implementation — check yourself against this (same shape, complete)
  drill/    inject.sh, observe.sh, recover.sh, run-drill.sh, lib.sh,
            manifests/{00-namespace,10-configmap-healthy,11-configmap-bad,20-deployment}.yaml,
            LIVE-INCIDENT-EVIDENCE.txt  # committed real drill timeline
  postmortems/2026-injected-readiness-failure.md  # blameless PM from the drill timeline
tests/      # stdlib unittest (test_error_budget.py, test_nines.py) + check_k6_balance.py
broken/     # burn-rate-alerts.broken.yaml — troubleshooting fixture (2 injected defects)
docs/       # architecture.mmd
load/       # mock-target/payments_api_mock.py — local k6 target (stdlib HTTP; NOT
            #   the service under study, just a fixture so `k6 run` has something to hit)
validate.sh # runs every gate; exits non-zero on any failure
```

## Setup

From a fresh clone, no installation is required for the local gates:

```bash
cd labs/sre-incident-response
./validate.sh            # runs all 12 local gates
```

To work the lab, edit files under `starter/` and re-run the tests:

```bash
PYTHONPATH=starter/scripts python3 -m unittest discover -s tests
```

## Lab tasks

1. **Complete the error-budget math (Week 21).** In
   `starter/scripts/error_budget.py`, fill the three `TODO(student)` gaps:
   `burn_rate`, `time_to_exhaustion_hours`, and the `consumed`/`remaining`/`rate`
   lines in `compute`.
   *Done when:* `PYTHONPATH=starter/scripts python3 -m unittest discover -s tests -p 'test_error_budget.py'` is green (23 tests).

2. **Read and sanity-check the SLO + alerts.** Confirm `slo/slo.yaml` encodes both
   objectives (0.999 availability, 0.99 latency) and that every threshold in
   `slo/burn-rate-alerts.yaml` is expressed as `<multiple> * 0.001` (the error
   budget fraction).
   *Done when:* you can state why `14.4 * 0.001` is the page threshold and which
   recording rule each alert reads.

3. **Run the troubleshooting exercise (Week 22).** Diff `broken/burn-rate-alerts.broken.yaml`
   against `solution/slo/burn-rate-alerts.yaml`, find both injected defects, and
   write one sentence each on how a CI check would have caught them.
   *Done when:* you have identified the never-firing threshold and the missing
   recording rule (see Troubleshooting below to verify).

4. **Verify with load (Week 22).** Read `load/k6-smoke.js`; map each threshold to an
   SLO objective. If you have k6, run it against any local service.
   *Done when:* you can explain how a p95 > 300ms makes `k6 run` exit non-zero, and
   thus how this becomes a CI gate.

5. **Operate the runbooks.** Tabletop the IC/Comms/Ops roles for a simulated fast
   burn using `runbooks/incident-command.md`, then fill `postmortem-template.md`
   for the scenario, using `error_budget.py` to quantify the budget spent.
   *Done when:* the postmortem has a timeline, a root cause, and owned action items.

6. **Run the injected-incident drill (Week 22).** Complete the two `TODO(student)`
   gaps in the starter drill, then run it for real:
   - Write the bad nginx config in `starter/drill/manifests/11-configmap-bad.yaml`
     so `/healthz` returns 503 (the readiness regression).
   - Fill the fault-injection patch in `starter/drill/inject.sh` (swap to the bad
     ConfigMap, bump `config-version`, set `maxUnavailable: 100%`).
   - Implement the two-step recovery in `starter/drill/recover.sh` (`rollout undo`,
     then re-apply the manifest to restore the safe strategy).

   Then drive it live and read the timeline:
   ```bash
   RUN_LIVE=1 ./solution/drill/run-drill.sh   # reference, end-to-end
   cat solution/drill/LIVE-INCIDENT-EVIDENCE.txt
   ```
   *Done when:* `run-drill.sh` prints `RESULT = PASS`, the timeline shows
   `ready endpoints=0` during the fault and `HTTP 200` after recovery, and
   `ns/lab-incident` is deleted on exit. See [The injected-incident
   drill](#the-injected-incident-drill) below for the mechanics.

7. **Write the blameless postmortem from the drill (Week 22).** Using your drill's
   `LIVE-INCIDENT-EVIDENCE.txt`, fill `postmortem-template.md` (or compare against
   `solution/postmortems/2026-injected-readiness-failure.md`).
   *Done when:* the postmortem's timeline matches the captured timestamps, the root
   cause distinguishes trigger (the 503 regression) from the latent condition
   (`maxUnavailable: 100%`), and every action item is owned and dated.

## The injected-incident drill

`solution/drill/` is a self-contained, live chaos drill on `kind`. Four scripts
share `lib.sh` (all kubectl calls are pinned to `KUBE_CONTEXT`, default
`kind-course`, and namespaced to `lab-incident`):

| Script | Role | What it does |
|--------|------|--------------|
| `inject.sh` | inject | Applies the healthy baseline (`nginxinc/nginx-unprivileged`, readiness probe on `/healthz`), waits Ready, then ships a bad **v2** (swap to the 503 ConfigMap, `maxUnavailable: 100%`). |
| `observe.sh` | observe | Captures the symptom — pods `0/1`, endpoints empty, rollout stalled, an in-cluster probe returning `DOWN`, and `Readiness probe failed … statuscode: 503` events. Exits non-zero on a degraded state (invert with `--expect-healthy`). |
| `recover.sh` | recover | `kubectl rollout undo` to mitigate, then re-applies the manifest to restore the safe strategy (rollout undo does **not** revert `.spec.strategy`). |
| `run-drill.sh` | orchestrate | `RUN_LIVE=1`-gated. Runs inject → observe → recover → verify with timestamps, writes `LIVE-INCIDENT-EVIDENCE.txt`, and **always deletes `ns/lab-incident` on exit** (even on Ctrl-C). |

Run a single phase by hand (e.g. to inspect the broken state yourself):
```bash
./solution/drill/inject.sh            # deploy healthy, then inject the fault
./solution/drill/observe.sh           # see the outage (exits 1 == degraded)
kubectl -n lab-incident get pods,endpoints   # poke around
./solution/drill/recover.sh           # roll back + restore safe strategy
kubectl delete ns lab-incident        # clean up if you didn't use run-drill.sh
```

The full `RUN_LIVE=1 ./solution/drill/run-drill.sh` captured a real outage and
recovery against `kind-course` — empty endpoints, a `DOWN` probe, and the
readiness-probe-503 events — then recovered to `HTTP 200`, in
[`solution/drill/LIVE-INCIDENT-EVIDENCE.txt`](solution/drill/LIVE-INCIDENT-EVIDENCE.txt).
That timeline is the source of truth for the blameless postmortem in
[`solution/postmortems/2026-injected-readiness-failure.md`](solution/postmortems/2026-injected-readiness-failure.md).

## Validation

`./validate.sh` runs these gates. Expected tail in this environment:
`== 28 passed, 0 failed ==` in fast mode (the live drill is `[SKIP]`'d but its
committed evidence is still checked); `RUN_LIVE=1 ./validate.sh` adds the live
drill for `== 29 passed, 0 failed ==`. Tool-guarded gates degrade to `[SKIP]` or a
lighter fallback where the tool is absent.

| Gate | Command (run by `validate.sh`) | Result here |
|------|--------------------------------|-------------|
| Python syntax | `python3 -m py_compile` on all `.py` | PASS |
| Unit tests (solution) | `PYTHONPATH=solution/scripts python3 -m unittest discover -s tests` | PASS (45 tests) |
| Starter incompleteness | starter `error_budget` tests must FAIL | PASS (they fail) |
| Shell syntax | `bash -n` on every `*.sh` | PASS |
| SLO YAML well-formed | `python3 -c "import yaml; list(yaml.safe_load_all(open(F)))"` | PASS |
| k6 sanity (no node) | `python3 tests/check_k6_balance.py load/k6-smoke.js` | PASS |
| **k6 execution (real)** | starts `load/mock-target/payments_api_mock.py` in a container, then `BASE_URL=… k6 run --vus 5 --duration 8s solution/load/k6-smoke.js` | **PASS** — see evidence below |
| **kubeconform (drill)** | `kubeconform -strict -kubernetes-version 1.31.0` on `solution/drill/manifests/*` and `starter/drill/manifests/*` | **PASS** (5+5 resources valid) |
| **shellcheck (drill)** | solution drill scripts at `--severity=style`; starter at `--severity=warning` (TODO gaps allow unreachable code) | **PASS** |
| **Live drill evidence** | `LIVE-INCIDENT-EVIDENCE.txt` records `RESULT = PASS`, `ready endpoints=0`, and a readiness-probe `statuscode: 503` | **PASS** |
| **Live injected-incident drill** | `RUN_LIVE=1 solution/drill/run-drill.sh` — inject → observe → recover → verify against `kind-course`; deletes `ns/lab-incident` | **PASS** (RUN_LIVE=1; `[SKIP]` by default) |
| **OpenSLO lint** | `oslo validate -f slo/slo.yaml` | **DEFERRED** — `oslo` not installed |
| **Prometheus rule lint** | `promtool check rules slo/burn-rate-alerts.yaml` | **DEFERRED** — `promtool` not installed |

### Real injected-incident drill evidence

`RUN_LIVE=1 ./solution/drill/run-drill.sh` against `kind-course` produced this
timeline (excerpt from the committed
[`solution/drill/LIVE-INCIDENT-EVIDENCE.txt`](solution/drill/LIVE-INCIDENT-EVIDENCE.txt)):

```
14:52:07Z  INJECT: baseline healthy -- readyReplicas=3, endpoints=3
14:52:07Z  INJECT: shipping bad rollout v2 (/healthz now 503, maxUnavailable=100%)
14:52:08Z  OBSERVE: service endpoints (ready backends behind the ClusterIP)
NAME           ENDPOINTS   AGE
payments-web   <none>      8s
14:52:09Z  OBSERVE: ready endpoints=0  readyReplicas=0
14:52:21Z  OBSERVE: probe result -> DOWN URLError
...  Warning  Unhealthy  pod/payments-web-...  Readiness probe failed: HTTP probe failed with statuscode: 503
14:52:21Z  OBSERVE: verdict = DEGRADED (incident confirmed)
14:52:21Z  RECOVER: step 1/2 -- kubectl rollout undo
14:52:26Z  RECOVER: mitigated -- readyReplicas=3, endpoints=3
14:52:29Z  RECOVER: in-cluster probe -> HTTP 200
14:52:35Z  DRILL: RESULT = PASS (fault injected -> detected -> recovered -> verified healthy)
14:52:47Z  CLEANUP: ns/lab-incident deleted
```

The drill is a usable failure gate: `observe.sh` exits non-zero on a degraded
state and `run-drill.sh` exits non-zero unless the fault is detected AND recovery
is verified — so a recovery that didn't actually work fails the drill.

### Real `k6 run` evidence

`validate.sh` Gate 7 (guarded by `command -v k6 && command -v docker`) stands up a
local `payments-api` mock — `load/mock-target/payments_api_mock.py`, stdlib-only, no
network pull beyond the `python:3.x-slim` base — implementing exactly the contract the
smoke script asserts (`GET /healthz` and `POST /v1/authorize` → `{"approved": bool}`),
then runs the real load test against it. Captured here (k6 v0.54.0):

```
$ BASE_URL=http://localhost:8080 k6 run --vus 5 --duration 8s solution/load/k6-smoke.js
     ✓ healthz is 200
     ✓ healthz fast (<100ms)
     ✓ authorize is 200
     ✓ authorize returns JSON
     ✓ authorize has decision

   ✓ checks.........................: 100.00% 200 out of 200
   ✓ http_req_duration..............: avg=24.25ms ... p(95)=48.26ms   (threshold p(95)<300)
   ✓ http_req_failed................: 0.00%   0 out of 80               (threshold rate<0.001)
   ✓ payment_declines...............: 5.00%   2 out of 40               (threshold rate<0.20)
     http_reqs......................: 80      9.51/s
     iterations.....................: 40      4.76/s
# exit 0
```

The thresholds are real CI gates, not decoration: re-running the same script against
the mock with `LATENCY_MS=400` drives `http_req_duration p(95)≈449ms`, crosses the
`p(95)<300` threshold, and **k6 exits 99 (non-zero)** — exactly how a too-slow service
would fail the build:

```
$ LATENCY_MS=400 BASE_URL=http://localhost:8081 k6 run --vus 5 --duration 6s solution/load/k6-smoke.js
   ✗ http_req_duration..............: ... p(95)=449.5ms
   level=error msg="thresholds on metrics 'http_req_duration' have been crossed"
# exit 99
```

To run the real load test by hand against any target (the script reads `BASE_URL`
via `__ENV`):

```bash
# Against the in-repo mock:
docker run -d --rm -p 8080:8080 \
  -v "$PWD/load/mock-target/payments_api_mock.py:/app/payments_api_mock.py:ro" \
  python:3.12-slim python /app/payments_api_mock.py
BASE_URL=http://localhost:8080 k6 run solution/load/k6-smoke.js
# ...or against your own staging payments-api:
BASE_URL=https://staging.example.com k6 run solution/load/k6-smoke.js
# Docker-only k6 (no local install): pipe the script in via stdin.
docker run --rm -i grafana/k6 run - < solution/load/k6-smoke.js
```

Run a single tool directly:

```bash
python3 solution/scripts/error_budget.py --target 0.999 --good 998500 --total 1000000
python3 solution/scripts/nines_downtime.py --target 0.999
```

## Expected results

`error_budget.py` on a blown budget (1500 bad of 1,000,000 against a 0.1% budget):

```
SLO target           : 99.9%
Window               : 720h
Events good/total    : 998,500 / 1,000,000  (bad: 1,500)
Allowed bad events   : 1,000.0
Error budget         : 0.1% of requests
Budget consumed      : 150.00%
Budget remaining     : -50.00%
Burn rate            : 1.50x
Time to exhaustion   : 0h (exhausted)
Status               : EXHAUSTED
```

`nines_downtime.py --target 0.999` (the canonical three-nines numbers):

```
Availability target  : 99.9%  (three nines)
Allowed downtime/30d : 43m 12s
Allowed downtime/year: 8h 45m 36s
```

The unittest run prints `Ran 45 tests` / `OK`. A real `k6 run` ends with a
per-threshold ✓/✗ summary and exits non-zero if `http_req_duration p95<300` or
`http_req_failed rate<0.001` is breached — captured against the local mock in
[Real `k6 run` evidence](#real-k6-run-evidence) above (passing run: exit 0;
latency-injected run: exit 99).

## Troubleshooting

**Real, reproducible fixture: `broken/burn-rate-alerts.broken.yaml`.** It parses as
valid YAML (so a naive parse gate passes) but the page will never fire. Two defects:

| # | Symptom | Cause | Fix |
|---|---------|-------|-----|
| 1 | `PaymentsAPIErrorBudgetFastBurn` never fires even at 100% errors | threshold is `> 14.4` (the burn *multiple*) but the recorded value is an error *ratio* in `[0,1]`, which can never exceed 14.4 | compare against the ratio: `> (14.4 * 0.001)` |
| 2 | The 6x page alert is silently dead (no data) | it reads `ratio_rate30m`, but no `...ratio_rate30m` recording rule exists in the group | add the missing recording rule (see `solution/slo/burn-rate-alerts.yaml`) |

Confirm your diagnosis:

```bash
diff broken/burn-rate-alerts.broken.yaml solution/slo/burn-rate-alerts.yaml
# Defect 1: '> 14.4' should be '> (14.4 * 0.001)'
# Defect 2: ratio_rate30m is referenced but never recorded
```

**How CI catches each:** `promtool check rules` flags neither (both are *valid*
PromQL), which is the lesson — semantic SLO bugs need **unit tests on the rules**:
`promtool test rules` with a series fixture that drives the error ratio above the
budget and asserts the alert fires. Defect 2 is also caught by a lint that checks
every referenced recording-rule name is defined.

**Second real fixture: the injected-incident drill itself.** `inject.sh` produces
a *live*, reproducible broken state on the cluster (not a hypothetical):

| Symptom | Cause | Where you see it |
|---------|-------|------------------|
| `kubectl -n lab-incident get endpoints payments-web` → `<none>` | the v2 readiness probe fails, so no pod is added to the Service | `observe.sh`, evidence file |
| pods stuck `0/1`, `RESTARTS` climbing | `/healthz` returns 503 → both readiness *and* liveness fail | `kubectl -n lab-incident get pods` |
| in-cluster curl gets connection-refused / `DOWN` | the Service has zero ready backends | `observe.sh` probe line |
| `Readiness probe failed: HTTP probe failed with statuscode: 503` | the v2 `/healthz` regression — the root cause | `kubectl -n lab-incident get events` |
| after `rollout undo` the next deploy is *still* reckless | `rollout undo` reverts the pod template but **not** `.spec.strategy` (`maxUnavailable` stays 100%) | re-apply the manifest (recover.sh step 2) |

**Other common failures:**
- `NotImplementedError: burn_rate...` when running the starter tests → you haven't
  filled the `TODO(student)` gaps yet. That is expected before the lab is done.
- `run-load.sh` prints `k6 is not installed` and exits 127 → install k6 (commands
  in the script's error message) or use the Docker one-liner.
- `inject.sh` / `run-drill.sh` print `kube context 'kind-course' not found` → no
  such context. Create/start the cluster, or run with `KUBE_CONTEXT=<your-context>`
  (or `KUBE_CONTEXT=` to use the current context).
- Starter `./inject.sh` exits 3 with `TODO(student): inject the fault here` → you
  haven't filled the fault-injection patch yet; see `solution/drill/inject.sh`.

## Cleanup

The SLO/runbook/k6 half creates no cloud, cluster, or long-lived local resources.
The **injected-incident drill** creates a single namespace, `ns/lab-incident`, on
the kind cluster — and `run-drill.sh` **always deletes it on exit** (success,
failure, or Ctrl-C, via a trap). If a drill was interrupted in a way that skipped
the trap, tear it down idempotently:

```bash
kubectl delete ns lab-incident --ignore-not-found   # the only cluster resource the lab creates
```

To remove generated local artifacts:

```bash
find . -name '__pycache__' -type d -prune -exec rm -rf {} +
rm -f load/result.json load/summary.json load/*.html   # only if you ran k6 with --out
```

These are idempotent (safe to run when nothing exists). The committed
`solution/drill/LIVE-INCIDENT-EVIDENCE.txt` is intentionally kept (it is the
captured evidence); re-running the drill overwrites it. `./validate.sh` itself
writes only to a `mktemp` file it deletes on exit, and the drill never touches any
namespace other than `lab-incident`.

## Security considerations

- **No secrets in this repo.** `k6-smoke.js` uses a fake card token
  (`tok_test_visa`); never put a real PAN, token, or API key in the script — pass
  them via env vars at run time and keep them out of version control.
- **Runbooks reference production access** (`kubectl rollout undo`, gateway
  rate-limits). Those are least-privilege operations for on-call; the runbook does
  not embed credentials and assumes the responder authenticates through your normal
  SSO/RBAC path.
- **Postmortems are blameless** — also a *data-handling* posture: do not paste
  customer PII or raw payment data into the timeline; reference IDs instead.
- **Alert `runbook_url`s are relative paths** in this lab; in production point them
  at an access-controlled wiki, not a public URL.
- **The drill app runs as non-root.** `solution/drill/manifests/20-deployment.yaml`
  uses `nginxinc/nginx-unprivileged` with `runAsNonRoot`, `runAsUser: 101`,
  `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, and
  `seccompProfile: RuntimeDefault` — a least-privilege pod even for a throwaway
  drill. The drill creates no Secrets and no externally-reachable Service
  (ClusterIP only); it is confined to `ns/lab-incident`.
- **The injected fault is intentional and local.** Only run the drill on a kind /
  scratch cluster you own. Never run `inject.sh` against a shared or production
  cluster — it deliberately breaks a Deployment.

## Cost considerations

$0. There are no cloud resources. The injected-incident drill runs on a **local
kind cluster** — no cloud spend, and it tears its namespace down on exit. The only
thing that could cost money is running the k6 load test **against a real paid
endpoint you own** — load tests generate real traffic, so point `BASE_URL` at a
staging/throwaway target and keep the VU count modest (the smoke profile peaks at
10 VUs for ~1 minute). Never load-test a third party's service without
authorization.

## Instructor answer key

- **Reference solution:** everything under `solution/`. The starter has
  `TODO(student)` gaps in `scripts/error_budget.py` (3), `drill/inject.sh` (fault
  injection), `drill/recover.sh` (two-step recovery), and
  `drill/manifests/11-configmap-bad.yaml` (the 503 config).
- **Grading points (non-obvious):**
  - `burn_rate == observed_error / allowed_error`; over a full window this is
    identical to `budget_consumed`. A common wrong answer divides by `target`
    instead of `(1 - target)`.
  - `time_to_exhaustion = budget_remaining * window_hours / rate`. Students often
    forget to scale by `budget_remaining`, giving the time to burn the *whole*
    budget instead of the *remaining* budget.
  - Edge cases the tests enforce: `rate == 0` → `None` ("never"); already-exhausted
    → `0.0`, not negative.
  - `nines_downtime`: three nines = **43m 12s / 30d** and **8h 45m 36s / year** are
    the canonical numbers; a target that isn't a whole number of nines (e.g. 99.95%)
    must return an empty `nines` label.
- **Troubleshooting answer:** both defects in `broken/` above; the key insight is
  that *valid* PromQL can be *operationally* wrong, so rule **unit tests**
  (`promtool test rules`) — not just `check rules` — are required.
- **k6 grading:** the thresholds (`p(95)<300`, `rate<0.001`) must map to the two SLO
  objectives; a script without `thresholds` cannot fail a build and is worth less.
- **Drill grading (non-obvious):**
  - The single most-tested concept: **a readiness probe protects users but not
    capacity.** Kubernetes correctly keeps the broken v2 pods *out* of the Service,
    so users never get 503s *from* a bad pod — but `maxUnavailable: 100%` removes
    all the good pods first, so the Service still goes fully down. Credit a student
    who explains that the *combination* (bad probe + reckless strategy) is the
    outage; the probe alone, with a safe strategy, would only *stall*.
  - **`rollout undo` is not a full undo.** It reverts the pod template, not
    `.spec.strategy`. A solution that stops at `rollout undo` leaves the reckless
    strategy armed — `recover.sh` must also re-apply the manifest. This is the
    most common incomplete answer.
  - The fault must be *observable*: `observe.sh` has to exit non-zero on the
    degraded state (empty endpoints OR non-200 probe), or the drill cannot be a CI
    gate. A drill that always exits 0 is worth less.
  - The postmortem must be **blameless** and grounded in the *real captured
    timeline* (`LIVE-INCIDENT-EVIDENCE.txt`), with action items that distinguish
    the trigger (the 503 regression) from the latent condition
    (`maxUnavailable: 100%`) — see
    `solution/postmortems/2026-injected-readiness-failure.md`.
