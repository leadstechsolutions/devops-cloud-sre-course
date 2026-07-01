# Module: k8s-production-ops

> **Status:** Validated — all four drills ran live on `kind-course` (and a throwaway
> Calico kind cluster for the NetworkPolicy drill) in this environment; static gates
> (`yamllint`, multi-doc YAML parse, `kubeconform -strict`, `bash -n`, `shellcheck`)
> all pass and `./validate.sh` exits 0. Captured output is committed in
> [`evidence/LIVE-OPS-EVIDENCE.txt`](evidence/LIVE-OPS-EVIDENCE.txt).
> **Maps to:** Week 12 (Kubernetes operations) and Week 21 (senior K8s / production
> reliability). Reuses the `cpu-burner:1.0.0` image built in
> [`../performance-scaling`](../performance-scaling).

## What you will build

A set of **production-operations drills** on Kubernetes, each a script that runs on
kind and captures real cluster output. You operate a sample Deployment + Service
(the `cpu-burner` image) and exercise four things a senior on-call engineer must do
correctly under pressure:

1. **Rollout / rollback** — ship a bad image, watch the rollout get *stuck*
   (`ImagePullBackOff`, `kubectl rollout status` fails) while the old pods keep
   serving, then `kubectl rollout undo` back to health.
2. **PodDisruptionBudget** — prove a PDB(`minAvailable: 2`) gates *voluntary*
   disruptions through the eviction API (HTTP 429 when it would breach the budget)
   and that a direct `kubectl delete pod` (*involuntary*) bypasses it.
3. **ResourceQuota + LimitRange** — show the API server **rejecting** a pod that
   exceeds the limits and **admitting** a compliant one.
4. **NetworkPolicy enforcement** — on a Calico cluster, prove a `default-deny` plus
   an explicit `allow` policy actually move traffic from ALLOWED → BLOCKED → ALLOWED
   (kindnet does not enforce policy, so this drill builds its own cluster).

## Prerequisites

- `kubectl >= 1.29` with a context for the course cluster (`kind-course`).
- `kind >= 0.24`, `docker >= 24`.
- The `cpu-burner:1.0.0` image loadable by the cluster. It is built in
  `../performance-scaling/solution/app`. Load it with:
  ```bash
  kind load docker-image cpu-burner:1.0.0 --name course
  ```
  (It is already present on `kind-course` in this environment.)
- For drill 4 only: outbound network access to fetch the Calico manifest and the
  `curlimages/curl` image, and permission to create/delete a second kind cluster.
- Validators (optional but used by `validate.sh`): `yamllint`, `kubeconform`,
  `shellcheck`, `python3` with PyYAML.

## Architecture

See [`docs/architecture.mmd`](docs/architecture.mmd). Drills 1–3 run on the shared
`kind-course` cluster (kindnet CNI), each in its **own unique namespace** that is
deleted on exit. Drill 4 stands up a **separate single-node kind cluster** with the
default CNI disabled and Calico installed (kindnet silently ignores NetworkPolicy,
so enforcement cannot be proven on `kind-course`); that cluster is deleted when the
drill finishes.

## Repository layout

```
starter/manifests/        # the lab: PDB + both NetworkPolicies are TODO stubs;
                          #   the supporting manifests are provided so you can run
                          #   the drills against your own answers
solution/manifests/       # reference manifests (Deployment, Service, PDB, quota,
                          #   LimitRange, over/compliant pods, netpol/*)
solution/drills/          # the four drill scripts + run-drills.sh orchestrator
docs/architecture.mmd     # Mermaid diagram
evidence/                 # LIVE-OPS-EVIDENCE.txt — committed captured output
validate.sh               # static gates always; live drills under RUN_LIVE=1
.yamllint.yml             # lint config for these manifests
```

## Setup

```bash
cd labs/k8s-production-ops
# 1. confirm the sample image is in the cluster (build/load it if not):
kubectl --context kind-course get nodes
docker image inspect cpu-burner:1.0.0 >/dev/null || \
  ( cd ../performance-scaling/solution/app && docker build -t cpu-burner:1.0.0 . )
kind load docker-image cpu-burner:1.0.0 --name course   # idempotent
# 2. run the fast static gates:
./validate.sh
```

## Lab tasks

Work in `starter/manifests/`. The supporting manifests are provided; you complete the
two TODO stubs and then run the drills against them.

1. **Write the PodDisruptionBudget** (`starter/manifests/pdb.yaml`).
   *Done when:* `kubectl get pdb cpu-burner` shows `ALLOWED DISRUPTIONS = 1` with 3
   healthy pods, and `solution/drills/pdb-drain.sh` reaches `RESULT: PASS`.
2. **Write the default-deny-ingress NetworkPolicy**
   (`starter/manifests/netpol/default-deny.yaml`).
   *Done when:* on the Calico cluster, the client→server curl times out (curl exit 28).
3. **Write the allow-client-to-server NetworkPolicy**
   (`starter/manifests/netpol/allow-client-to-server.yaml`).
   *Done when:* after the default-deny **and** this policy are applied, the
   client→server curl succeeds again (curl exit 0, HTTP 200), and
   `solution/drills/networkpolicy.sh` reaches `RESULT: PASS`.
4. **Run the rollout/rollback and quota drills** and read the captured evidence to
   understand *why* the old pods kept serving and *why* the over-quota pod was
   rejected.

Check yourself against `solution/`.

## Validation

`./validate.sh` runs the static gates always and the live drills only under
`RUN_LIVE=1`:

```bash
./validate.sh                 # fast: yamllint, YAML parse, kubeconform, bash -n, shellcheck
RUN_LIVE=1 ./validate.sh      # also runs all four drills (multi-minute) + writes evidence
# or drive the drills directly:
RUN_LIVE=1 ./solution/drills/run-drills.sh        # all four, writes evidence/LIVE-OPS-EVIDENCE.txt
RUN_LIVE=1 SKIP_NETPOL=1 ./solution/drills/run-drills.sh   # skip the slow Calico drill
bash solution/drills/rollout-rollback.sh          # one drill at a time
```

Expected `./validate.sh` tail (static, no cluster mutation):

```
  [PASS]  yamllint -s on solution/ starter/ (config .yamllint.yml)
  [PASS]  yaml: all manifests parse (multi-doc)
  [PASS]  kubeconform: -strict on solution manifests (k8s 1.31.0)
  [PASS]  shell: bash -n solution/drills/...    (x5)
  [PASS]  shellcheck: all drill scripts + validate.sh
  [DEFER] live: run-drills.sh (all 4 drills ...)
== 10 passed, 0 failed, 1 deferred ==
```

## Expected results

- **Drill 1:** with a bad image the new ReplicaSet pod is `ImagePullBackOff`,
  `kubectl rollout status` exits non-zero, and `readyReplicas` stays **3** (old pods
  keep serving because `maxUnavailable: 0`). After `rollout undo` → 3/3 on
  `cpu-burner:1.0.0`; rollout history shows the new revision.
- **Drill 2:** PDB shows `ALLOWED DISRUPTIONS = 1`. First eviction → `Success/201`.
  A second eviction of a distinct healthy pod while the budget is 0 →
  `Error from server (TooManyRequests): Cannot evict pod as it would violate the
  pod's disruption budget.` A direct `kubectl delete pod` succeeds regardless.
- **Drill 3:** over-quota pod →
  `Error from server (Forbidden): ... maximum cpu usage per Container is 500m, but
  limit is 2`; compliant pod → `pod/compliant created`, Running; quota
  `pods USED=1 / HARD=5`.
- **Drill 4:** `curl_exit=0` (no policy) → `curl_exit=28` (after default-deny) →
  `curl_exit=0` (after allow). All three are printed in `RESULT: PASS`.

Real captured output for all four is in
[`evidence/LIVE-OPS-EVIDENCE.txt`](evidence/LIVE-OPS-EVIDENCE.txt).

## Troubleshooting

Real, reproducible failures these drills are built around:

| Symptom | Cause | Fix |
|--------|-------|-----|
| `kubectl rollout status` hangs then `error: timed out waiting for the condition` | New pod is `ImagePullBackOff` (bad image tag); with `maxUnavailable: 0` the rollout will not retire a healthy old pod | `kubectl rollout undo deploy/<name>`; fix the image tag; never deploy `:latest` |
| `Error from server (TooManyRequests): Cannot evict pod ...` during `kubectl drain` | The eviction would drop Ready pods below the PDB `minAvailable` | Expected — `drain` backs off and retries; ensure the Deployment can schedule replacements (capacity, image present) so the budget recovers |
| `kubectl delete pod` ignores the PDB | Direct delete is an *involuntary* disruption; PDBs guard only *voluntary* ones (eviction API) | Use `kubectl drain` / the eviction API for safe maintenance; do not `delete pod` on a budgeted workload |
| `pods "x" is forbidden: maximum cpu usage per Container is 500m` | Pod exceeds the `LimitRange` max (or the `ResourceQuota`) | Size requests/limits within the namespace policy |
| `pods "x" is forbidden: failed quota: must specify requests.cpu` | A `ResourceQuota` tracks `requests.cpu` but the pod declares none and no `LimitRange` default applies | Add a `LimitRange` with `defaultRequest`, or set requests explicitly |
| Default-deny NetworkPolicy has no effect; traffic still flows | The CNI does not enforce NetworkPolicy (e.g. **kindnet**) | Use an enforcing CNI (Calico/Cilium); this lab's drill 4 builds a Calico kind cluster precisely for this reason |

A worked broken-state walkthrough lives inside the drills themselves: each injects a
real fault (bad image / over-budget eviction / over-quota pod / blocked traffic) and
asserts the expected failure before recovering.

## Cleanup

Every drill creates a **unique namespace** and deletes it on exit (`trap ... EXIT`),
so re-runs leave nothing behind. Drill 4 deletes its throwaway Calico cluster on exit.
Manual belt-and-suspenders cleanup:

```bash
# stray drill namespaces on the course cluster (none should remain):
kubectl --context kind-course get ns | grep '^prodops-' || echo "clean"
kubectl --context kind-course delete ns -l app.kubernetes.io/part-of=k8s-production-ops --ignore-not-found
# the netpol cluster (none should remain):
kind get clusters | grep -x netpol && kind delete cluster --name netpol || echo "clean"
```

## Security considerations

- All workloads run under the **`restricted`** Pod Security Standard: non-root
  (UID 10001), `readOnlyRootFilesystem`, `allowPrivilegeEscalation: false`, all
  capabilities dropped, `seccompProfile: RuntimeDefault`. The namespace template
  carries the PSA `enforce: restricted` labels.
- Images are pinned by tag (`cpu-burner:1.0.0`, `curlimages/curl:8.10.1`), never
  `:latest`, so rollouts and drills are deterministic.
- The default-deny NetworkPolicy demonstrates the zero-trust baseline: deny all
  ingress, then add explicit allows. Do not commit secrets; nothing here needs any.
- `ResourceQuota` + `LimitRange` are themselves a security control — they cap a
  namespace's blast radius so one team cannot starve the cluster.

## Cost considerations

**$0.** Everything runs locally on kind. No cloud resources, no AWS, nothing billable.
Drill 4 briefly runs a second local kind cluster (extra CPU/RAM for a few minutes)
and deletes it; the only "cost" is the one-time image/manifest download.

## Instructor answer key

- Reference manifests: [`solution/manifests/`](solution/manifests/) — the two graded
  TODOs are `pdb.yaml` (`minAvailable: 2`, selector on `app.kubernetes.io/name:
  cpu-burner`) and `netpol/{default-deny,allow-client-to-server}.yaml`.
- Non-obvious grading points:
  - The PDB must use `minAvailable` (or `maxUnavailable`) but **not both**;
    `apiVersion` must be `policy/v1` (not the removed `policy/v1beta1`).
  - The default-deny must use an **empty** `podSelector: {}` and list `Ingress` in
    `policyTypes` with **no** ingress rules — a common wrong answer adds an empty
    `ingress: []` (still valid) or, worse, an `ingress` block that allows everything.
  - The allow policy's `podSelector` scopes the **destination** (server); the
    `ingress.from.podSelector` scopes the **source** (client). Students frequently
    invert these.
  - Drill 4 only proves enforcement on an **enforcing CNI**. If a student "validates"
    a NetworkPolicy on kindnet and sees traffic still flow, that is the expected
    non-enforcement, not a broken policy — mark understanding of *why*.
- Common wrong answers: deploying `:latest` (breaks rollback determinism); expecting
  a PDB to stop `kubectl delete pod`; assuming a `ResourceQuota` alone lets a
  request-less pod through (it needs a `LimitRange` default).
