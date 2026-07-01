# System Design Model Answer — CI/CD Platform

> Reference answer for the `cicd-platform` prompt: design a CI/CD platform that
> serves many teams — builds, tests, and deploys hundreds of services safely, at
> scale, securely. This is a **platform engineering** problem and the most
> DevOps-flavored of the five: the hard parts are the build-runner fleet,
> artifact/cache strategy, deployment safety, and supply-chain security. Use
> `scoring-rubric.md`. Connects to this course's `labs/cicd-pipelines`.

The interview trap is describing *a pipeline* (build → test → deploy) when the
question is *a platform that runs thousands of pipelines for many teams*. The
multi-tenancy, runner autoscaling, caching, secrets, and deploy-safety concerns
are the actual content.

---

## 1. Requirements clarification (~3 min)

**Functional:**
- Teams define pipelines (as code, in their repo) that trigger on push/PR/tag.
- Pipeline runs: **build** → **test** → **scan** → **publish artifact** → **deploy**
  to environments (dev → staging → prod) with **gates/approvals**.
- Support many languages/build types; provide logs, status, and re-run.

**Non-functional (the drivers):**
- **Scale:** hundreds of services, thousands of builds/day, spiky (everyone pushes
  before lunch). Build capacity must **autoscale** and not idle-burn money.
- **Speed:** fast feedback (developers wait on CI). Caching and parallelism are
  first-class.
- **Isolation / multi-tenancy:** one team's build can't read another's secrets,
  starve their capacity, or escape into the platform (untrusted code runs here).
- **Security / supply chain:** secrets handling, artifact provenance, image
  signing, SBOMs — CI is a prime attack target (it has prod credentials).
- **Reliability of deploys:** safe rollout strategies + automated rollback.

**Clarifying questions:**
- Build vs buy (GitHub Actions/GitLab CI/Jenkins vs build our own orchestrator)?
- Mono-repo or many repos? (Changes caching + change-detection strategy.)
- Who can deploy to prod, and what gates are mandatory (approvals, scans)?
- Self-hosted runners (control, cost) vs hosted (simple, pay-per-minute)?

---

## 2. Capacity math (~3 min)

- **2,000 builds/day**, avg build 8 min → ~16,000 build-minutes/day. Spiky: maybe
  **50 concurrent builds** at peak, near-zero overnight.
- Runner fleet sizing: 50 concurrent × (2 vCPU, 4 GB typical) = ~100 vCPU at peak,
  but **autoscaled to ~0 off-peak** — this is why a static fleet wastes money and
  ephemeral autoscaling matters.
- **Cache/artifact storage:** dependency caches + build artifacts + container
  images. Images especially: hundreds of services × many tags × ~200 MB → **TBs**
  in a registry; needs retention/GC.
- **Conclusion to voice:** the cost and speed levers are **ephemeral autoscaling
  runners** (don't pay for idle) and **aggressive caching** (don't rebuild what
  didn't change). Throughput is easy; *cost-per-build* and *feedback latency* are
  the optimization targets.

---

## 3. High-level architecture

```
  ┌──────────┐  webhook   ┌─────────────────┐   schedule    ┌────────────────────────┐
  │ Git (push│───────────▶│ Orchestrator /  │──────────────▶│ Runner fleet (ephemeral)│
  │ /PR/tag) │            │ control plane   │   jobs        │ - k8s pods / VMs        │
  └──────────┘            │ - parse pipeline│◀──────────────│ - autoscaled (KEDA/ASG) │
                          │ - queue jobs    │   status      │ - isolated per job      │
                          │ - enforce gates │               └──────────┬─────────────┘
                          │ - RBAC          │                          │ pull
                          └───────┬─────────┘                          ▼
                                  │                          ┌────────────────────┐
                       ┌──────────┴──────────┐               │ Cache (deps)       │
                       ▼                     ▼               │ Artifact store     │
              ┌────────────────┐   ┌──────────────────┐      │ Container registry │
              │ Secrets (Vault)│   │ Audit log / DB   │      │ (signed, SBOM'd)   │
              └────────────────┘   └──────────────────┘      └─────────┬──────────┘
                                                                       ▼  deploy
                                              ┌───────────────────────────────────────┐
                                              │ Deploy targets: dev → staging → prod    │
                                              │ (Argo CD / Helm; canary/blue-green;     │
                                              │  auto-rollback on SLO breach)           │
                                              └───────────────────────────────────────┘
```

**Components:**
- **Control plane / orchestrator:** receives webhooks, parses the pipeline-as-code,
  builds a job DAG, enqueues jobs, enforces RBAC and gates, records audit. Stateful
  (a queue + DB); must be HA — it's the SPOF for *all* CI.
- **Runner fleet (the crux):** **ephemeral, isolated** workers — ideally a fresh
  pod/VM per job so there's no state leakage between tenants and no "works because
  of leftover cache from another job." **Autoscaled** (Kubernetes + KEDA scaling on
  queue depth, or a VM autoscaling group) so capacity tracks demand and idles to
  near-zero. Each job runs untrusted code, so isolate hard (separate namespaces/
  network policies/no host access; gVisor/Kata or per-VM for stronger isolation).
- **Cache + artifacts:** a shared dependency cache (keyed by lockfile hash), an
  artifact store (build outputs), and a **container registry** for images. Layer
  caching + remote build cache are the biggest speed wins.
- **Secrets:** a secrets manager (Vault / cloud KMS) injected **per job, scoped to
  the tenant**, short-lived, never written to logs. Never long-lived prod creds
  sitting in env vars.
- **Deploy layer:** GitOps (Argo CD) or Helm-based, with progressive delivery.

---

## 4. The platform-specific hard parts

### a) Multi-tenancy & isolation
Many teams share the platform and CI runs **untrusted code with access to
credentials** — a top supply-chain attack target. Requirements:
- **Per-job isolation:** ephemeral runner, no shared filesystem/network between
  tenants, no access to the control plane's creds.
- **Scoped secrets:** team A's pipeline can only fetch team A's secrets (RBAC on
  the secrets manager, OIDC-federated short-lived creds, not static keys).
- **Fairness:** per-tenant concurrency quotas so one team's 500-job push doesn't
  starve everyone else (priority queues / quotas).

### b) Runner autoscaling & cost
Static fleets waste money off-peak and queue during spikes. Scale runners on
**queue depth** (KEDA/custom autoscaler), use **Spot/preemptible** for non-critical
builds, and make runners **ephemeral** so scale-to-zero is safe. This is the
headline cost lever.

### c) Caching & speed
Developers wait on CI, so feedback latency is a product metric. Levers:
- **Dependency cache** keyed by lockfile hash (don't re-download the world).
- **Layer/remote build cache** for containers (BuildKit cache).
- **Change detection / affected-targets** (especially in mono-repos): only build
  and test what changed (Bazel/Nx/Turborepo style), not the whole repo.
- **Parallelism / test sharding** across runners.

### d) Deployment safety (the SRE concern)
A platform that can deploy fast can break prod fast. Mandatory safety:
- **Progressive delivery:** canary or blue-green, not big-bang.
- **Automated rollback** on health/SLO breach (tie to the observability pipeline).
- **Gates:** required approvals for prod, mandatory passing scans, environment
  promotion (dev → staging → prod), and a freeze mechanism.

### e) Supply-chain security
CI is where SolarWinds-class attacks happen. Build in:
- **Scan in-pipeline** (deps, image, IaC, secrets) as failing gates — exactly what
  `labs/security-automation` builds.
- **Sign artifacts** (cosign) and generate **SBOMs** (syft) for provenance.
- **Verify signatures at deploy** so only signed, scanned artifacts reach prod.
- **Least-privilege, short-lived deploy creds** via OIDC federation, not static
  long-lived keys in CI.

---

## 5. Data model / state

- **Pipeline definition:** as code in each repo (`.github/workflows`, `.gitlab-ci.yml`,
  or a custom DSL) — versioned with the app, reviewed in PRs.
- **Run state:** orchestrator DB — runs, jobs, statuses, logs pointer, who
  triggered, artifacts produced, audit trail (who deployed what to prod, when).
- **Artifacts:** content-addressed where possible; registry with retention/GC.
- **Cache:** keyed by content hash (lockfile, layer digest) for correctness.

---

## 6. Key trade-offs to articulate

- **Build vs buy:** managed (GitHub Actions/GitLab) = fast, less control, per-minute
  cost; self-hosted runners/orchestrator = control + cost-at-scale + ops burden.
  Most orgs use a managed control plane with **self-hosted runners** — best of both.
- **Ephemeral vs persistent runners:** ephemeral = clean isolation + scale-to-zero,
  but cold-start cost and cache warming; persistent = fast but state leakage and
  weaker isolation.
- **Isolation strength vs speed/cost:** per-VM/gVisor isolation is safest but slower
  and pricier than shared-kernel containers.
- **Cache aggressiveness vs correctness:** stale caches cause "works on CI, fails in
  prod"; key caches by content hash to stay correct.
- **Deploy speed vs safety:** canary/gates add minutes but prevent outages — the
  whole point of progressive delivery.

---

## 7. What a great candidate adds (senior signal)

- Frames it as a **platform for many tenants**, not a single pipeline — multi-tenancy
  and fairness quotas up front.
- Treats CI as **untrusted-code execution with prod credentials** and isolates +
  scopes secrets accordingly (the supply-chain mindset).
- Makes runners **ephemeral + autoscaled on queue depth** as the cost lever, with
  Spot for non-critical builds.
- Bakes **scan/sign/SBOM/verify-at-deploy** into the platform (not bolted on) and
  uses **OIDC short-lived deploy creds**.
- Ties deploys to **progressive delivery + automated rollback on SLO breach**,
  connecting CI/CD to observability and SRE.
- Notes the orchestrator is the platform-wide SPOF and makes it HA.
