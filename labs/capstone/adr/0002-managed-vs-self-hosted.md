# 2. Managed vs self-hosted for platform and stateful components

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Capstone team (platform + SRE)
- **Tags:** infrastructure, cost, operability, availability
- **Context for:** Kubernetes control plane, Redis, Prometheus/Grafana, image registry

## Context

The capstone deploys a stateless app, a Redis dependency, and an observability
stack onto Kubernetes, provisioned by `labs/terraform-aws-foundations`. For each
platform/stateful component we must choose **managed** (cloud provider runs it)
vs **self-hosted** (we run it on our own nodes).

The decision drivers, in priority order for this course/product stage:

1. **Operability** — a small team should not be paged for control-plane patching,
   storage failover, or registry availability.
2. **Cost** — the lab must be able to run at **$0** locally (see "Local profile")
   and at a predictable, small monthly figure in a real account.
3. **Blast radius / data durability** — losing the Redis cache is survivable;
   losing cluster state or audit logs is not.
4. **Portability** — we should not hard-bind to one provider's proprietary API
   where a portable option is comparable.

We have two target profiles:

- **Local profile** (the demo in this repo): everything self-hosted in containers
  via `docker-compose.demo.yaml` / `kind`. Zero cloud cost, fast iteration.
- **Cloud profile** (what production looks like): provisioned by Terraform.

## Decision

| Component            | Cloud profile          | Local profile        | Rationale |
|---------------------|------------------------|----------------------|-----------|
| Kubernetes control plane | **Managed** (EKS)  | self-hosted `kind`   | Control-plane HA, etcd backups, and patching are undifferentiated heavy lifting; managed removes our most dangerous on-call surface. Locally `kind` is free and good enough. |
| Container registry  | **Managed** (ECR)      | local daemon cache   | Registry uptime and vuln scanning are commodity; running our own (Harbor) adds an availability dependency we'd have to operate. |
| Redis (cache)       | self-hosted on cluster, **or** managed (ElastiCache) if it becomes a system of record | self-hosted sidecar | It is a **cache** here — data loss is tolerable, so the cheap self-hosted sidecar is fine. The moment it holds non-reconstructable state, switch to managed for backups/failover (revisit via a new ADR). |
| Metrics/observability | self-hosted Prometheus + Grafana on cluster | self-hosted | Prometheus is operationally simple at this scale and self-hosting avoids per-series SaaS billing surprises; revisit if cardinality/retention outgrows a single node. |
| Object/state storage (TF state) | **Managed** (S3 with native `use_lockfile` locking) | local backend | Terraform state is system-of-record; managed remote state gives durability + locking that a local file cannot. |

**Default rule going forward:** prefer **managed** for anything whose failure
pages us at 3am or whose loss is unrecoverable (control plane, registry, TF
state); prefer **self-hosted** for stateless or reconstructable components where
cost and portability win (cache, in-cluster Prometheus).

## Consequences

**Positive**

- On-call surface shrinks to the application and its in-cluster dependencies; the
  control plane, registry, and state storage are someone else's pager.
- The local profile stays $0 and fully self-hosted, so the lab is runnable with
  no account.
- Each choice has an explicit "revisit when…" trigger, so growth doesn't silently
  invalidate the decision.

**Negative / costs**

- Managed services create provider coupling (EKS/ECR/S3 are AWS-specific). The
  Terraform module isolates this behind variables so a port is mechanical, not a
  rewrite.
- Self-hosted Redis/Prometheus mean *we* own their capacity, upgrades, and
  failure modes in production — acceptable at this scale, but a known liability
  to track in the readiness checklist.
- Two profiles (local vs cloud) mean two code paths to keep in sync; mitigated by
  sharing the same app image and the same `/healthz` + env contract across both.

## Related

- ADR-0001 — why we record decisions this way.
- `labs/terraform-aws-foundations` — provisions the managed components.
- `production-readiness-checklist.md` — durability/backup items reference this ADR.
