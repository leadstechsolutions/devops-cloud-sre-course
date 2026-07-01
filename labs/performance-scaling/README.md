# Module: performance-scaling

> **Status:** Validated (live kind) — `PERF_E2E=1 ./validate.sh` ran the full demo
> (`solution/run-demo.sh`) on a live `kind` cluster and observed the
> HorizontalPodAutoscaler scale the Deployment **1 → 3 → 5 replicas** under k6 load
> (CPU peaked at 105–108%/50% target), then scale back in (5 → 4 → … → 1) after the
> load stopped — captured in [`LIVE-DEMO-EVIDENCE.txt`](LIVE-DEMO-EVIDENCE.txt).
> The routine `./validate.sh` passes **13/13** offline gates (YAML parse,
> `kubeconform -strict`, `k6 inspect`, structural unit tests, `shellcheck`,
> `py_compile` + a local `/burn` smoke test, `hadolint`) and **defers** the ~3-min
> live e2e by default; pass `PERF_E2E=1` to gate it inline (then 14/14 pass).
> **Maps to:** Week 22 Class 01–02 (Performance & Scaling / Autoscaling). Reuses the
> hardened-container pattern from `labs/docker-containers` and the HPA concept first
> introduced in `labs/kubernetes-fundamentals` (here it is *operated under load*, not
> just declared).

## What you will build
A horizontally autoscaling service on Kubernetes and a load test that proves it
scales. You deploy a small **CPU-burner** (a Python stdlib HTTP service whose
`/burn` endpoint pins a CPU thread for a controllable number of milliseconds), front
it with a Service, and attach a **HorizontalPodAutoscaler** targeting **50% CPU
utilisation, min 1 / max 5**. You then drive it with a **k6 ramping load test**
(ramp to 20 VUs, hold, ramp down) with a **p95 latency threshold** and **checks**,
and watch `kubectl get hpa` report **REPLICAS rising 1 → >1** as CPU climbs past the
target — then fall back as the load drains. The end state is a repeatable,
single-command demo (`run-demo.sh`) that installs metrics-server on kind, runs the
whole loop, captures the scaling, and tears everything down.

## Prerequisites
- `kubectl >= 1.28` pointed at a cluster (this lab is validated on **kind** with the
  context `kind-course`; any cluster with a working metrics-server will do).
- `kind >= 0.24` **and** `docker` (to build + side-load the cpu-burner image).
- `k6 >= 0.50` for the load test.
- `kubeconform`, `shellcheck`, `python3 >= 3.10` (+ `PyYAML`) for the offline gates.
- Internet access **once**, to pull `registry.k8s.io/metrics-server/metrics-server`
  and the `python:3.12-alpine` base image. After that the demo is offline.
- Prior modules reused: `labs/docker-containers` (the non-root, hardened container
  pattern) and `labs/kubernetes-fundamentals` (Deployment/Service/HPA basics).

## Architecture
See [`docs/architecture.mmd`](docs/architecture.mmd). k6 sends `/burn` requests
through a `kubectl port-forward` to the ClusterIP Service, which load-balances across
the cpu-burner pods. Each request burns CPU, so request rate maps to CPU utilisation.
`metrics-server` scrapes per-pod CPU from the kubelet; the HPA reads that through the
metrics API and adds pods when average CPU exceeds 50% of the pod's **request**
(100m), up to 5. When load drops, the HPA scales back in after a stabilisation window.

```
k6 → port-forward → Service(cpu-burner:80) → pods(1..5) ──burn CPU──┐
                                                                     │
metrics-server ──scrapes kubelet CPU──────────────────────────────┘
        ▲                                                            │
        └────────── HPA reads CPU util ──────────────────────────────┘
                    HPA scales the Deployment (min 1 / max 5)
```

## Repository layout
```
solution/
  app/            cpu-burner: server.py (/burn, /healthz) + Dockerfile (non-root)
  k8s/            namespace, deployment, service, hpa, kustomization,
                  metrics-server.yaml (vendored v0.8.1)
  load/load.js    k6 ramping load test (stages + p95 threshold + checks)
  run-demo.sh     one-command end-to-end demo (install MS → load → scale → teardown)
starter/
  k8s/hpa.yaml    HPA with the min/max/metric/behaviour TODO'd
  load/load.js    k6 script with the stages + thresholds TODO'd
  k8s/*.yaml      the Deployment/Service/Namespace are given complete
broken/
  deployment-no-cpu-request.yaml   reproduces the "TARGETS <unknown>" HPA failure
tests/            offline structural assertions (unittest + PyYAML)
docs/architecture.mmd
validate.sh       runs every gate; defers the live e2e unless PERF_E2E=1
LIVE-DEMO-EVIDENCE.txt   captured transcript of a real 1→5 scaling run on kind
```

## Setup
From a fresh clone, on a machine with a kind cluster running:
```bash
cd labs/performance-scaling

# 1. Build the cpu-burner image and side-load it into kind (deterministic; no
#    runtime pull). Replace "course" with your kind cluster name if different.
docker build -t cpu-burner:1.0.0 solution/app
kind load docker-image cpu-burner:1.0.0 --name course

# 2. Run everything (installs metrics-server, applies k8s/, loads, captures
#    scaling, then deletes ns lab-perf and uninstalls metrics-server):
./solution/run-demo.sh
```
`run-demo.sh` is idempotent and always cleans up, even on Ctrl-C.

## Lab tasks
Work in `starter/`. Check yourself against `solution/`.

1. **Complete the HPA** (`starter/k8s/hpa.yaml`). Set `minReplicas: 1`,
   `maxReplicas: 5`, and a `metrics:` block targeting CPU `Utilization` at `50`.
   *Done when:* `kubectl -n lab-perf get hpa cpu-burner` shows
   `TARGETS  cpu: <n>%/50%` (a number, **not** `<unknown>`) and `MINPODS/MAXPODS 1/5`.

2. **Design the k6 load profile** (`starter/load/load.js`). Fill in three ramping
   `stages` (ramp up ~30s → hold ~60s → ramp down ~20s) and the `thresholds`
   (`burn_duration p(95)<1500`, `http_req_failed rate<0.03`, `checks rate>0.95`).
   The failure/checks budgets are slightly loose because the demo reaches the
   Service through a single `kubectl port-forward`, which can reset a few
   connections under load — that is the test rig, not the service. Through a real
   LoadBalancer/Ingress you would tighten them to `<0.01` / `>0.99`.
   *Done when:* `k6 inspect starter/load/load.js` shows 3 stages and `k6 run …`
   exits 0 with the thresholds satisfied.

3. **Force a scale-out and observe it.** Apply your manifests into `lab-perf`,
   port-forward the Service, run k6, and watch the HPA.
   *Done when:* `kubectl -n lab-perf get hpa cpu-burner -w` shows `REPLICAS` rise
   above 1 while CPU is above 50%.

4. **Observe scale-in.** Stop the load and watch replicas return toward 1.
   *Done when:* `REPLICAS` falls back to `minReplicas` after the scale-down window.

5. **Reproduce and fix the broken HPA.** Apply `broken/deployment-no-cpu-request.yaml`
   into a throwaway namespace, confirm `TARGETS <unknown>`, then explain the fix.
   *Done when:* you can state *why* it shows `<unknown>` and what one line fixes it.

## Validation
`./validate.sh` runs the gates below. Exact commands you can also run by hand:

| Gate | Command | Expected |
|------|---------|----------|
| YAML parse | `python3 -c "import yaml; list(yaml.safe_load_all(open('solution/k8s/hpa.yaml')))"` | no error |
| Schema | `kubeconform -strict -summary solution/k8s/{deployment,service,hpa,namespace}.yaml` | `Valid: 4` |
| k6 parse + stages | `k6 inspect solution/load/load.js` | JSON with 3 `stages` |
| Structural tests | `python3 -m unittest discover -s tests -p 'test_*.py'` | `OK` |
| Shell lint | `shellcheck -x validate.sh solution/run-demo.sh` | no output |
| App compile + smoke | `python3 -m py_compile solution/app/server.py` + local `/burn` | `iterations > 0` |
| Dockerfile | `hadolint solution/app/Dockerfile` | no errors |
| **LIVE scaling** | `PERF_E2E=1 ./validate.sh` (or `./solution/run-demo.sh`) | `REPLICAS 1 → >1`, exit 0 |

The routine `./validate.sh` runs all offline gates and **defers** the ~3-min live
e2e (it is a demo, too slow to block every run), pointing at the captured
[`LIVE-DEMO-EVIDENCE.txt`](LIVE-DEMO-EVIDENCE.txt). Set `PERF_E2E=1` to gate the live
scaling inline; with a reachable cluster + `k6` that turns the suite 14/14.

## Expected results
From the validated live run (`PERF_E2E=1 ./validate.sh` → `solution/run-demo.sh`),
full transcript in [`LIVE-DEMO-EVIDENCE.txt`](LIVE-DEMO-EVIDENCE.txt):
```
=== waiting for the HPA to read CPU metrics (TARGETS != <unknown>) ===
NAME         REFERENCE               TARGETS       MINPODS  MAXPODS  REPLICAS  AGE
cpu-burner   Deployment/cpu-burner   cpu: 1%/50%   1        5        1         30s
...
    [hpa-watch] REPLICAS rose to 3
    [hpa-watch] REPLICAS rose to 5
...
   ✓ burn_duration ... p(95)=690.64ms        (threshold p(95)<1500 PASS)
   ✓ checks ......... 100.00% 7198/7198
   ✓ http_req_failed  0.00% 0/3600
=== HPA state after load ===
NAME         REFERENCE               TARGETS         MINPODS  MAXPODS  REPLICAS  AGE
cpu-burner   Deployment/cpu-burner   cpu: 108%/50%   1        5        5         2m19s
    RESULT: HPA scaled UP (1 -> 5). Autoscaling demonstrated.
=== stopping load; observing scale-down ===
    scale-IN observed (REPLICAS 5 -> 4); HPA continues toward 1
```
Success = `REPLICAS` climbs above `minReplicas` under load, k6 thresholds pass, and
replicas fall back afterward.

## Troubleshooting
Real, reproducible failure modes (the first two are by far the most common):

- **HPA shows `TARGETS <unknown>/50%` and never scales — no metrics-server.**
  *Symptom:* `kubectl top pod` errors with `Metrics API not available`.
  *Cause:* the metrics API has no backend. On kind it also fails even when installed,
  because the kubelet serves metrics over a self-signed cert metrics-server won't
  trust. *Fix:* install metrics-server **and** add `--kubelet-insecure-tls` to its
  args (exactly what `run-demo.sh` does). On a real cluster, fix the kubelet serving
  certificates instead of using the insecure flag.

- **HPA shows `TARGETS <unknown>/50%` even WITH metrics-server — no CPU request.**
  *Reproduce:* `kubectl create ns brk && kubectl -n brk apply -f
  broken/deployment-no-cpu-request.yaml`, then `kubectl -n brk describe hpa
  cpu-burner-broken` → `FailedGetResourceMetric … did not specify CPU request`.
  *Cause:* a `Utilization` target is a **percentage of the request**; with no
  `resources.requests.cpu` there is no denominator. *Fix:* add a CPU request to the
  container (see `solution/k8s/deployment.yaml`). Clean up: `kubectl delete ns brk`.

- **k6 can't connect (`target not reachable at .../healthz`).**
  *Cause:* the `kubectl port-forward` isn't up or is on a different port.
  *Fix:* confirm `kubectl -n lab-perf port-forward svc/cpu-burner 18080:80` is
  running and `BASE_URL` matches; `run-demo.sh` waits for `/healthz` before loading.

- **Pods scale up but k6 p95 threshold fails.**
  *Cause:* per-pod CPU `limits` too low, or the burn is too heavy for the node.
  *Fix:* lower `BURN_MS` / `PEAK_VUS`, or raise the container CPU `limit`. The
  threshold is intentionally strict so a degraded run fails loudly.

## Cleanup
`run-demo.sh` tears down everything it created on exit (including Ctrl-C). If a run
was killed hard, clean up manually — both commands are idempotent:
```bash
kubectl delete ns lab-perf --ignore-not-found
kubectl delete -f solution/k8s/metrics-server.yaml --ignore-not-found
# Confirm nothing is left:
kubectl get ns lab-perf 2>&1 | grep -q NotFound && echo "ns gone"
kubectl -n kube-system get deploy metrics-server 2>&1 | grep -q NotFound && echo "MS gone"
```
The side-loaded `cpu-burner:1.0.0` image stays in the kind node cache (harmless);
remove the kind cluster to reclaim it.

## Security considerations
- The cpu-burner runs **non-root** (UID 10001), `readOnlyRootFilesystem`,
  `allowPrivilegeEscalation: false`, all Linux capabilities dropped, and a
  `RuntimeDefault` seccomp profile — it satisfies the `baseline` PSA the namespace
  enforces and most of `restricted`.
- The image is built from a pinned base and uses **no third-party packages**, so the
  build never reaches a package index (smaller supply-chain surface). Tags are pinned
  (`cpu-burner:1.0.0`, `metrics-server:v0.8.1`) — never `:latest`.
- **`--kubelet-insecure-tls` is a kind/dev convenience only.** It disables TLS
  verification between metrics-server and the kubelet. Do **not** use it on a real
  cluster; provision proper kubelet serving certificates instead.
- Nothing secret is committed: no credentials, tokens, or kubeconfigs. The `/burn`
  endpoint is CPU-only and exposed solely via an in-cluster ClusterIP + port-forward.

## Cost considerations
**$0.** Everything runs on a local `kind` cluster and local `k6`. No cloud resources
are created. The only network cost is a one-time pull of two public container images
(~70 MB total). On a managed cluster, an HPA that scales to `maxReplicas` costs the
node capacity those replicas consume — cap `maxReplicas` and use Cluster Autoscaler
limits in production so a load spike (or a load *test*) can't scale you into a large
bill.

## Instructor answer key
- **Reference solution:** `solution/` is complete and correct. `solution/k8s/hpa.yaml`
  is the model answer for Task 1; `solution/load/load.js` for Task 2.
- **Grading points (non-obvious):**
  - The HPA target is a **% of the request**, not of a core — the single most common
    misconception. A student who sets `request` too high will see CPU stay under 50%
    and *no* scaling; too low and one request saturates it.
  - Probes must hit `/healthz`, **not** `/burn`. A CPU-heavy readiness probe fails the
    pod precisely under load and triggers restart storms — dock points if they probe
    `/burn`.
  - The k6 **hold** stage must be long enough (~60s) for metrics-server to publish
    elevated CPU and the HPA's 15s sync to react. A pure spike with no hold often
    shows no scale-up before the test ends — a real, gradeable gotcha.
  - `behavior.scaleDown.stabilizationWindowSeconds` exists to prevent thrashing;
    students who omit it will see flapping. Full marks acknowledge the up/down asymmetry.
- **Common wrong answers:** hardcoding `replicas:` in the Deployment alongside the HPA
  (they fight); targeting `AverageValue` instead of `Utilization`; forgetting
  metrics-server entirely; using `:latest` image tags.
- **Broken-fixture answer:** `broken/deployment-no-cpu-request.yaml` shows `<unknown>`
  because the container declares only `limits`, no `requests.cpu`. One added line
  (`requests: { cpu: 100m }`) fixes it. `tests/test_manifests.py` asserts the fixture
  stays broken so the exercise can't silently rot.
