# Module: kubernetes-fundamentals

> **Status:** Validated (live kind cluster) — every gate now runs and PASSES
> here. Offline gates: YAML parse, `kubectl kustomize` render of base + prod
> overlay, the structural test suite, and `kubeconform -strict` schema
> validation of both renders and the broken fixtures. **Live gates** (on a real
> `kind` cluster, Kubernetes v1.31): the base applies into a unique namespace
> and reaches **2/2 Ready** under the `restricted` Pod Security Standard, the
> OOMKilled fixture reproduces **Reason: OOMKilled, Exit Code: 137**, and the
> bad-probe fixture reproduces a **Running-but-never-Ready** pod with **empty
> Service endpoints**. See the [Validation](#validation) section for captured
> output. The only remaining `DEFERRED` line is `kubectl apply
> --dry-run=client`, which the live apply fully supersedes.
>
> **Maps to:** Week 11 Class 01–04 (deploy the app to Kubernetes: Deployment,
> Service, ConfigMap/Secret, probes, resources, HPA, Ingress, NetworkPolicy,
> Kustomize base/overlays) and Week 12 Class 01–02 (troubleshooting: OOMKilled
> and never-Ready pods). Reuses the image built in
> [`../docker-containers`](../docker-containers/) (`docker-containers-demo`).

## What you will build

A production-shaped Kubernetes deployment of the stdlib HTTP service from the
`docker-containers` module: a hardened **Deployment** (2 replicas; liveness +
readiness probes on `/healthz`; CPU/memory requests **and** limits;
`runAsNonRoot`, `readOnlyRootFilesystem: true` with an `emptyDir` mounted at
`/tmp`; no privilege escalation, all capabilities dropped, `seccomp:
RuntimeDefault`), fronted by a **ClusterIP Service** and an **Ingress**,
configured by a **ConfigMap** and a (clearly fake) **Secret**, autoscaled by an
**HPA** at 70% CPU, and locked down by **NetworkPolicies** (default-deny plus an
allow-from-ingress and a DNS-egress hole). It is assembled with **Kustomize**: a
`base/` and a `prod/` overlay that patches the replica count. You then practise
**Week-12 troubleshooting** against two `broken/` fixtures that fail only at
runtime: an OOMKilled crash loop and a pod that never becomes Ready.

## Prerequisites

- `kubectl >= 1.27` (this repo validated with v1.34.2; built-in Kustomize v5).
- `python3 >= 3.10` with `PyYAML` (used by `validate.sh` and the test suite).
- `kubeconform` (optional but recommended; the schema-validation gates in
  `validate.sh` run when it is on `PATH` and `DEFER` cleanly when it is not).
  Validated here with v0.6.7.
- The container image `docker-containers-demo:1.0.0`. Build it from the
  [`docker-containers`](../docker-containers/) module:
  `docker build -f labs/docker-containers/solution/Dockerfile -t docker-containers-demo:1.0.0 labs/docker-containers`.
  (Only needed for an actual cluster apply; the local gates don't need the image.)
- **For the cluster-apply / troubleshooting parts (optional):** a Kubernetes
  cluster. A local [`kind`](https://kind.sigs.k8s.io/) or `minikube` is enough.
  `metrics-server` for the HPA and an `ingress-nginx` controller for the Ingress
  and the NetworkPolicy `allow-from-ingress` rule. NetworkPolicy enforcement
  requires a CNI that implements it (Calico/Cilium); kind's default CNI does not
  enforce, so the policies apply but are no-ops there.
- Prior module: [`docker-containers`](../docker-containers/) (the image).

## Architecture

See [`docs/architecture.mmd`](docs/architecture.mmd) (Mermaid). External HTTP
hits the **ingress-nginx** controller, which the **Ingress** object routes to
the **ClusterIP Service `web`** (port 80 → container port 8000). The Service
load-balances across the **two Deployment pods** — but only pods passing the
**readiness probe** receive traffic. Pods run **non-root with a read-only root
filesystem** and a writable `emptyDir` at `/tmp`. The **HPA** scales the
Deployment 2→6 on CPU. **NetworkPolicies** deny all traffic by default and open
exactly two holes: ingress from the controller on 8000, and DNS egress.

```
external client → ingress-nginx → Service(web,ClusterIP:80) → Pods(:8000, ready only)
                                         ▲ HPA scales 2..6 on CPU 70%
ConfigMap + Secret → envFrom → Pods       NetworkPolicy: default-deny + allow-ingress + allow-dns
```

## Repository layout

```
solution/
  base/                 # the full app, environment-agnostic
    namespace.yaml      #   Namespace (PSA: restricted enforced)
    configmap.yaml      #   non-secret config (PORT/HOST/...)
    secret.yaml         #   FAKE example Secret (stringData)
    deployment.yaml     #   2 replicas, probes, resources, hardened securityContext
    service.yaml        #   ClusterIP, port 80 -> targetPort http(8000)
    hpa.yaml            #   HorizontalPodAutoscaler, CPU 70%, 2..6
    ingress.yaml        #   Ingress (ingressClassName: nginx)
    networkpolicy.yaml  #   default-deny + allow-from-ingress + allow-dns (3 docs)
    kustomization.yaml  #   ties the base together
  overlays/
    prod/
      kustomization.yaml # references base, namePrefix prod-, patch replicas->4
starter/
  deployment.yaml       # solution Deployment with probes/securityContext/resources TODO'd
broken/
  deployment-oomkilled.yaml  # Week-12: memory limit 4Mi -> OOMKilled crash loop
  deployment-badprobe.yaml   # Week-12: readiness on port 9999 -> never Ready
docs/
  architecture.mmd      # Mermaid diagram
tests/
  test_manifests.py     # offline structural assertions over the kustomize render
validate.sh             # runs this module's validation gates
```

## Setup

From a fresh clone, everything you need for the **local** gates is already
present (kubectl + python3 + PyYAML):

```bash
cd labs/kubernetes-fundamentals
./validate.sh                      # parse + render + structural tests
kubectl kustomize solution/base    # eyeball the rendered objects
```

For the optional **cluster** parts:

```bash
# 1. Build the image (from the docker-containers module) and load it into kind:
docker build -f ../docker-containers/solution/Dockerfile \
  -t docker-containers-demo:1.0.0 ../docker-containers
kind create cluster --name k8s-fundamentals
kind load docker-image docker-containers-demo:1.0.0 --name k8s-fundamentals

# 2. Apply the base (creates the namespace and everything in it):
kubectl apply -k solution/base
kubectl -n web rollout status deploy/web
```

## Lab tasks

Do the lab in `starter/deployment.yaml`; check yourself against
`solution/base/deployment.yaml`.

1. **Complete the pod securityContext.** Add `runAsNonRoot: true`,
   `runAsUser/runAsGroup/fsGroup: 10001`, and `seccompProfile.type:
   RuntimeDefault`.
   *Done when:* `python3 -m unittest tests.test_manifests.TestBaseRender.test_pod_security_context_runs_as_non_root`
   passes after you copy your finished file over `solution/base/deployment.yaml`
   (or point the test at your file).
2. **Add liveness + readiness probes** on `/healthz`, port `http`. (Optional:
   a `startupProbe`.)
   *Done when:* both probes exist with `path: /healthz` and the target port is
   `http` or `8000` — `...test_probes_on_healthz` passes. Getting the port wrong
   is exactly the bug in `broken/deployment-badprobe.yaml`.
3. **Add resources** requests **and** limits for cpu and memory (suggested
   `50m/64Mi` requests, `250m/128Mi` limits).
   *Done when:* `...test_resources_requests_and_limits` passes. Too-low memory
   is the bug in `broken/deployment-oomkilled.yaml`.
4. **Add the container securityContext**: `allowPrivilegeEscalation: false`,
   `readOnlyRootFilesystem: true`, `privileged: false`,
   `capabilities.drop: [ALL]`. The writable `/tmp` `emptyDir` is already wired.
   *Done when:* `...test_container_hardening` and
   `...test_readonly_rootfs_has_writable_tmp` pass.
5. **Render and diff the prod overlay.** `kubectl kustomize
   solution/overlays/prod` — confirm objects are `prod-`-prefixed and the
   Deployment has `replicas: 4`.
   *Done when:* `...TestProdOverlay` passes.
6. **(Cluster, optional) Troubleshoot the broken fixtures** — see
   [Troubleshooting](#troubleshooting). *Done when:* you can state
   symptom→cause→fix for each and the patched version becomes Ready.

Full acceptance: `./validate.sh` exits 0. Offline-only (no cluster, no
`kubeconform`) it reports `5 passed, 0 failed` with the cluster/kubeconform
gates `DEFER`red; with `kubeconform` on `PATH` and a reachable cluster it reports
`11 passed, 0 failed, 1 deferred` (the live gates run in a throwaway namespace
that is torn down on exit).

## Validation

`./validate.sh` runs the gates below. **Captured output from this environment:**

```
== validating kubernetes-fundamentals ==
  [PASS]  yaml: all manifests parse (multi-doc)
  [PASS]  kustomize: solution/base renders
  [PASS]  kustomize: solution/overlays/prod renders
  [PASS]  tests: unittest discover -s tests (structural assertions)
  [PASS]  shell: validate.sh syntax
  [PASS]  kubeconform: -strict on solution/base render
  [PASS]  kubeconform: -strict on solution/overlays/prod render
  [PASS]  kubeconform: -strict on broken fixtures
  [PASS]  cluster: apply base into ns lab-k8s-validate + 2/2 Ready
  [PASS]  cluster: reproduce OOMKilled fixture (Reason OOMKilled, exit 137)
  [PASS]  cluster: reproduce never-Ready probe fixture (empty endpoints)
  [DEFER] kubectl: apply --dry-run=client per manifest (superseded by live apply)
== 11 passed, 0 failed, 1 deferred ==
```

The live gates run only when a cluster is reachable (`kubectl cluster-info`),
go into a **unique namespace** (`lab-k8s-validate`, override with `LAB_NS=...`),
and are **torn down on exit** — re-runs leave nothing behind. `kubeconform`
gates run wherever the binary is on `PATH` and degrade to `DEFER` otherwise.

`tests/test_manifests.py` (16 tests, all PASS) renders the base/overlay exactly
as kubectl would and asserts: `restricted` PSA on the namespace; 2 replicas;
`runAsNonRoot` + non-root UID + seccomp; `allowPrivilegeEscalation:false`,
`readOnlyRootFilesystem:true`, dropped caps; a writable `emptyDir` at `/tmp`;
liveness+readiness on `/healthz`; requests+limits; ClusterIP Service; HPA CPU
70%; a default-deny NetworkPolicy and an allow-from-ingress rule; the prod
overlay's `replicas:4` and `prod-` prefix; and that the broken fixtures carry
their documented defects.

### Authoritative gate evidence (captured here)

**`kubeconform -strict`** — schema validation of every object kubectl would send:

```console
$ kubectl kustomize solution/base | kubeconform -strict -summary
Summary: 10 resources found parsing stdin - Valid: 10, Invalid: 0, Errors: 0, Skipped: 0
$ kubectl kustomize solution/overlays/prod | kubeconform -strict -summary
Summary: 10 resources found parsing stdin - Valid: 10, Invalid: 0, Errors: 0, Skipped: 0
$ kubeconform -strict -summary broken/deployment-oomkilled.yaml broken/deployment-badprobe.yaml
Summary: 3 resources found in 2 files - Valid: 3, Invalid: 0, Errors: 0, Skipped: 0
```

**Live apply → 2/2 Ready** (into a throwaway namespace; the base hardcodes `web`,
so `validate.sh` re-namespaces the render to `$LAB_NS` for an isolated apply):

```console
$ kubectl -n lab-k8s rollout status deploy/web
deployment "web" successfully rolled out
$ kubectl -n lab-k8s get pods
NAME                   READY   STATUS    RESTARTS   AGE
web-55cdb67489-ff5px   1/1     Running   0          9s
web-55cdb67489-t52vz   1/1     Running   0          9s
$ kubectl -n lab-k8s get endpoints web
NAME   ENDPOINTS
web    10.244.0.5:8000,10.244.0.6:8000
$ kubectl -n lab-k8s exec web-55cdb67489-ff5px -- \
    python -c "import urllib.request;print(urllib.request.urlopen('http://127.0.0.1:8000/healthz').read().decode())"
{"status": "ok"}
```

The hardened pod (non-root UID 10001, `readOnlyRootFilesystem`, all caps
dropped, `seccomp: RuntimeDefault`) passes the namespace's **`restricted` PSA
enforcement** — the apply is not just schema-valid, it is admitted and Ready.

**Reproduce OOMKilled** (`broken/deployment-oomkilled.yaml`):

```console
$ kubectl -n lab-k8s get pods -l app.kubernetes.io/name=web-oom
NAME                       READY   STATUS      RESTARTS   AGE
web-oom-7545dbc7dc-c8d4t   0/1     OOMKilled   2          31s
$ kubectl -n lab-k8s describe pod web-oom-7545dbc7dc-c8d4t   # Last State excerpt
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
    Restart Count:  2
```

> **Fixture note:** this gate exposed a real defect in the original fixture. At
> the previously-shipped `4Mi` limit the OCI runtime's own `init` is OOM-killed
> *before the app starts*, surfacing as `Reason: StartError, Exit Code: 128`
> (`container init was OOM-killed (memory limit too low?)`) — **not** the
> `OOMKilled / 137` the README and the fixture comments promise. The limit was
> raised to **`12Mi`**, the value verified on this cluster to reproduce the
> documented runtime OOM kill (sweep: ≤8Mi → StartError/128; 12Mi →
> OOMKilled/137; ≥16Mi → Running). The structural test
> `test_oomkilled_has_tiny_memory_limit` now asserts `12Mi`.

**Reproduce never-Ready probe** (`broken/deployment-badprobe.yaml`):

```console
$ kubectl -n lab-k8s get pods -l app.kubernetes.io/name=web-badprobe
NAME                            READY   STATUS    RESTARTS   AGE
web-badprobe-776f57bbdb-s8p4g   0/1     Running   0          29s
$ kubectl -n lab-k8s describe pod web-badprobe-776f57bbdb-s8p4g   # Events excerpt
  Warning  Unhealthy  ...  Readiness probe failed: Get
    "http://10.244.0.15:9999/healthz": dial tcp ...:9999: connect: connection refused
$ kubectl -n lab-k8s get endpoints web-badprobe
NAME           ENDPOINTS   AGE
web-badprobe   <none>      29s
```

`Running` with **0 restarts** (liveness on 8000 is fine, so no crash), but
readiness on `9999` is refused forever → the pod stays `0/1` and is held out of
the Service endpoints, so the Service routes nowhere.

### Remaining deferred line — exact command

| Gate | Why deferred | Command |
|------|--------------|---------|
| `kubectl apply --dry-run=client` per manifest | The **live apply** above already proves the API server accepts and admits every object, so client dry-run adds nothing here; it stays documented for environments without the live path. (`--dry-run=client` still contacts the API server for RESTMapping, so it cannot run with no cluster at all.) | `for f in solution/base/*.yaml broken/*.yaml; do kubectl apply --dry-run=client --validate=false -f "$f"; done` |

## Expected results

- `kubectl kustomize solution/base` renders **10 objects**: Namespace,
  ConfigMap, Secret, Service, Deployment, HorizontalPodAutoscaler, Ingress, and
  **3** NetworkPolicies (`default-deny-all`, `allow-from-ingress`,
  `allow-dns-egress`).
- `kubectl kustomize solution/overlays/prod` renders the same set, every object
  renamed with the `prod-` prefix, and the Deployment at **`replicas: 4`**.
- On a cluster: `kubectl -n web get deploy web` shows `2/2` Ready;
  `kubectl -n web port-forward svc/web 8080:80` then
  `curl -s localhost:8080/healthz` returns `{"status": "ok"}` (HTTP 200);
  `curl -s localhost:8080/` returns `{"hostname": ..., "service":
  "docker-containers-demo", "port": 8000}`.

## Troubleshooting

Both fixtures are **structurally valid and apply cleanly** — they fail only at
**runtime**, which is the whole point. Reproduce them against a cluster.

### `broken/deployment-oomkilled.yaml` — CrashLoopBackOff / OOMKilled

- **Symptom:** `kubectl -n web get pods` shows `web-oom-...  0/1
  CrashLoopBackOff`. `kubectl -n web describe pod web-oom-...` shows
  `Last State: Terminated, Reason: OOMKilled, Exit Code: 137`.
- **Cause:** the container's **memory limit is `12Mi`**, below the Python
  runtime's working set. The kernel cgroup memory controller kills the process
  (SIGKILL → exit `137` = 128+9) the moment it exceeds the limit. Memory is an
  *incompressible* resource: unlike CPU (throttled), exceeding it is fatal.
- **Aside (verified on cluster):** push the limit *even lower* (≤ `8Mi`) and the
  symptom changes — the OCI runtime's own `init` is OOM-killed before the app
  runs, so you get `Reason: StartError, Exit Code: 128` (`container init was
  OOM-killed`) instead of the runtime `OOMKilled / 137`. `12Mi` is deliberately
  chosen so the *running* process is the one that gets killed.
- **Fix:** raise `resources.limits.memory` to a realistic value (the base uses
  `128Mi`) keeping `requests <= limits`. The container then stays Ready.

### `broken/deployment-badprobe.yaml` — pod Running but never Ready

- **Symptom:** `kubectl -n web get pods` shows `web-badprobe-...  0/1
  Running` (note: **Running, not** CrashLoop — liveness is fine, so no
  restarts). `kubectl -n web describe pod ...` shows
  `Readiness probe failed: ... :9999/healthz: connect: connection refused`.
  `kubectl -n web get endpoints web-badprobe` shows `ENDPOINTS <none>`, so the
  Service routes nowhere.
- **Cause:** the **readiness probe targets port `9999`**, but the app only
  listens on `8000`. The probe is refused forever, so the pod never reports
  Ready and is kept out of the Service endpoints. Liveness correctly targets
  `8000`, which is why the container is not restarted.
- **Fix:** point `readinessProbe.httpGet.port` at the real port — use the named
  port `http` (best; survives renumbering) or `8000`. Endpoints populate and
  traffic flows.

### General first moves

`kubectl -n web describe pod <p>` (Events + Last State),
`kubectl -n web logs <p> --previous` (last crashed container),
`kubectl -n web get events --sort-by=.lastTimestamp`.

## Cleanup

Local gates create nothing. For a cluster:

```bash
kubectl delete -f broken/deployment-oomkilled.yaml --ignore-not-found
kubectl delete -f broken/deployment-badprobe.yaml  --ignore-not-found
kubectl delete -k solution/base --ignore-not-found   # removes the namespace + all objects
# If you used kind just for this:
kind delete cluster --name k8s-fundamentals
```

Confirm nothing is left: `kubectl get ns web` returns `NotFound`. The commands
are idempotent (`--ignore-not-found`); re-running them is safe.

## Security considerations

- **Secret hygiene:** `solution/base/secret.yaml` contains **clearly fake,
  labelled** placeholder values and exists only so the lab applies
  self-contained. **Never commit a real Secret.** In production create it
  out-of-band (`kubectl create secret`) or via Sealed Secrets / External Secrets
  / SOPS so only an encrypted form is ever in git, and enable etcd
  encryption-at-rest. `data`/`stringData` is base64 — encoding, not encryption.
- **Least privilege at runtime:** pods run as a fixed non-root UID (10001) with
  `runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`,
  all Linux capabilities dropped, and `seccompProfile: RuntimeDefault`. The
  namespace **enforces** the `restricted` Pod Security Standard as a backstop.
- **Network least privilege:** `default-deny-all` denies all ingress/egress;
  only the ingress controller (on 8000) and cluster DNS (53) are allowed.
  Requires an enforcing CNI — verify yours enforces NetworkPolicy.
- **Image:** pin a real tag (`:1.0.0`), never `:latest`, so rollouts are
  deterministic and image provenance is auditable. Scan the image in CI.
- **Do NOT commit:** real secrets, kubeconfigs, or `*.tfstate`-style state.

## Cost considerations

**$0 by default.** Nothing here provisions cloud resources. The local gates
(`./validate.sh`) only parse/render files. A local `kind`/`minikube` cluster is
free (uses your machine's CPU/RAM). **If** you adapt this to a managed cluster
(EKS/GKE/AKS), you pay for the control plane (~$0.10/hr ≈ $72/mo on EKS) plus
nodes and any LoadBalancer the Ingress controller provisions — out of scope for
this lab. Stay at $0 by using `kind` and deleting it when done (see Cleanup).

## Instructor answer key

Reference solution: [`solution/base/`](solution/base/) (full app) and
[`solution/overlays/prod/`](solution/overlays/prod/) (replica patch). The starter
gaps map 1:1 to the four `# TODO(student)` blocks in
[`starter/deployment.yaml`](starter/deployment.yaml).

**Non-obvious grading points / common wrong answers:**

- **`readOnlyRootFilesystem: true` without a writable `/tmp`.** The pod will
  crash or error the first time it writes a temp file. The `emptyDir` mounted at
  `/tmp` is mandatory, not optional — graded by `test_readonly_rootfs_has_writable_tmp`.
- **Probe targets the Service port (80) instead of the container port.** Probes
  hit the *container*, so they must use the named `http` port (8000), not 80.
  Using a literal wrong port is the `broken/deployment-badprobe.yaml` failure.
- **Only `limits`, no `requests` (or vice-versa).** Requests drive scheduling
  and the HPA's utilisation math (70% *of the request*); limits cap usage.
  Missing requests breaks the HPA. Both are required.
- **`runAsNonRoot: true` but no `runAsUser`,** relying on the image's USER.
  Acceptable if the image sets a non-root USER (this one does, UID 10001), but
  setting it explicitly is safer and is what the answer key expects.
- **Secret with real-looking values committed.** Auto-fail the security
  checklist; the provided values are labelled FAKE for a reason.
- **Troubleshooting:** for OOMKilled, students must identify **exit 137 /
  Reason: OOMKilled** and that **memory is incompressible** (not "increase CPU").
  For never-Ready, they must connect **0/1 Running** + **empty endpoints** to a
  **wrong probe port** (not a crash) and prefer the **named port** in the fix.
- **Homework/quiz answers** live alongside the Week 11/12 class packages; the
  troubleshooting answer key is the symptom→cause→fix in
  [Troubleshooting](#troubleshooting) above and the comment headers in each
  `broken/` file.
```
