# Scoring Rubric — CI/CD Platform

> Score 0–2 per dimension. Max **20**. This is a **platform engineering** problem.
> The bar is multi-tenancy, ephemeral autoscaled runners, caching, supply-chain
> security, and safe deploys. A candidate who designs a single build→test→deploy
> pipeline without the platform/multi-tenant concerns is below the bar.

| # | Dimension | What a 2 looks like | Pts |
|--:|-----------|---------------------|----:|
| 1 | **Requirements & scoping** | Frames it as a multi-team platform; asks build-vs-buy, mono/multi-repo, prod-deploy gates, runner ownership. | /2 |
| 2 | **Capacity math** | Estimates builds/day, peak concurrency, cache/registry storage; concludes cost-per-build and feedback latency are the targets. | /2 |
| 3 | **Control plane** | Orchestrator that parses pipeline-as-code, queues a job DAG, enforces RBAC/gates, audits; recognizes it as an HA SPOF. | /2 |
| 4 | **Runner fleet** | Ephemeral, isolated, autoscaled-on-queue-depth workers; scale-to-zero; Spot for non-critical. | /2 |
| 5 | **Multi-tenancy & isolation** | Per-job isolation, scoped secrets per tenant, fairness quotas so one team can't starve others; treats CI as untrusted-code execution. | /2 |
| 6 | **Caching & speed** | Dependency cache by lockfile hash, layer/remote build cache, change-detection/affected-targets, parallelism. | /2 |
| 7 | **Secrets handling** | Secrets manager, per-job scoped + short-lived (OIDC federation), never logged; no static long-lived prod keys. | /2 |
| 8 | **Supply-chain security** | In-pipeline scans as failing gates + sign (cosign) + SBOM (syft) + verify-at-deploy. | /2 |
| 9 | **Deployment safety** | Progressive delivery (canary/blue-green), promotion gates, automated rollback on SLO breach. | /2 |
| 10 | **Communication & structure** | Scoped first, separated control plane / runners / deploy, clear diagram, time-managed. | /2 |

**Total: ___ / 20**

### Bands
- **17–20** — Strong hire. Multi-tenant, ephemeral autoscaling, supply-chain, and safe deploys all present.
- **13–16** — Hire. Solid platform, missed isolation depth or supply-chain or rollback.
- **9–12** — Mixed. Designed a good single pipeline but didn't reach platform/multi-tenant scale.
- **< 9** — Below bar. One pipeline, static runners, secrets in env vars, big-bang deploys.

### Red flags (cap the score)
- Designs one pipeline, never addresses many teams / multi-tenancy.
- Static always-on runner fleet (wastes money, queues on spikes).
- Long-lived prod credentials sitting in CI env vars.
- No artifact signing / SBOM / scan gates — ignores CI as an attack surface.
- Big-bang prod deploys with no canary or rollback.
- Shared runner state between tenants (isolation/leakage ignored).

### Green flags (senior signal)
- Treats CI as untrusted-code execution with prod creds; isolates + scopes secrets.
- Ephemeral runners autoscaled on queue depth; Spot for non-critical builds.
- OIDC short-lived deploy creds instead of static keys.
- Sign + SBOM + verify-at-deploy supply-chain chain.
- Automated rollback on SLO breach, tying CI/CD to observability and SRE.
- Per-tenant fairness quotas; names the orchestrator as the platform-wide SPOF.
