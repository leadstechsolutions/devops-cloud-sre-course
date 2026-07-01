# Production Readiness Checklist

A go/no-go gate before this system serves real traffic. Each item is **ticked
against the artifact in this course that satisfies it** — `[x]` means a real,
validated file provides it; `[ ]` means it is a known gap a real production
deployment must still close (the capstone is a learning system, not a 24/7
service, so some operational items are honestly left open).

Legend: ✅ provided by a lab artifact · ⚠️ partially provided / demo-grade · ❌ gap.

---

## 1. Reliability & resilience

- [x] ✅ **Liveness/readiness health endpoint** — `GET /healthz` served by the app
  (`labs/docker-containers/app/server.py`) and probed in
  `labs/kubernetes-fundamentals/solution/base/deployment.yaml`.
- [x] ✅ **Container restart on failure** — `restart: unless-stopped` (compose) and
  Deployment `restartPolicy` defaults (k8s).
- [x] ✅ **Horizontal autoscaling** — HPA in
  `labs/kubernetes-fundamentals/solution/base/hpa.yaml` and
  `labs/helm-charts/solution/chart/webapp/templates/hpa.yaml`.
- [x] ✅ **Resource requests/limits set** — both compose (`deploy.resources`) and
  k8s manifests define CPU/memory bounds (no noisy-neighbor / OOM-without-limit).
- [x] ✅ **Graceful shutdown on SIGTERM** — handled in `server.py` so rollouts drain
  cleanly instead of escalating to SIGKILL.
- [ ] ⚠️ **Multi-AZ / multi-replica in prod** — manifests support `replicas > 1`;
  the demo runs a single replica. Production sets `replicas >= 2` across AZs.
- [ ] ❌ **Disaster recovery / backup-restore drill** — not exercised in the lab
  (Redis here is a cache; see ADR-0002).

## 2. Security

- [x] ✅ **Runs as non-root** — UID 10001, enforced in the Dockerfile (`USER 10001`)
  and restated in compose/k8s (`runAsNonRoot` / `user:`).
- [x] ✅ **Read-only root filesystem + dropped capabilities** — `read_only: true`,
  `cap_drop: [ALL]`, `no-new-privileges` across compose and k8s securityContext.
- [x] ✅ **Default-deny network policy** — `labs/kubernetes-fundamentals/solution/base/networkpolicy.yaml`.
- [x] ✅ **No secrets in images or git** — secrets via k8s Secret / env;
  `.dockerignore` + `.gitignore` keep state and creds out of the build context and repo.
- [x] ✅ **Image vulnerability scan in CI** — scan stage in
  `labs/cicd-pipelines/solution/.github/workflows/ci.yml`.
- [x] ✅ **Least-privilege image** — slim base, no curl/wget/shell tooling shipped;
  stdlib-only healthcheck.
- [ ] ⚠️ **TLS / cert management at the edge** — Ingress is declared; cert-manager /
  TLS termination is a documented prod add-on, not in the lab.
- [ ] ❌ **Secret rotation + external secrets store** — uses static k8s Secrets;
  production wires a secrets manager (revisit per ADR process).

## 3. Observability

- [x] ✅ **Metrics scrape configured** — `labs/observability/solution/prometheus/prometheus.yml`
  and the demo `prometheus/prometheus.demo.yml`.
- [x] ✅ **RED-method recording + alerting rules** —
  `labs/observability/solution/prometheus/rules/`.
- [x] ✅ **Dashboard** — `labs/observability/solution/grafana/dashboards/service-overview.json`.
- [x] ✅ **SLOs defined with error budget** — `labs/observability/solution/slo/slo.yaml`
  + `labs/sre-incident-response/solution/scripts/error_budget.py`.
- [x] ✅ **Multi-burn-rate SLO alerts** — `alerting.rules.yml` (fast + slow burn).
- [x] ✅ **Structured logs to stdout** — app logs access lines to stdout for
  `docker logs` / cluster log collection.
- [ ] ⚠️ **App exposes `/metrics`** — the demo app serves `/healthz` (JSON), not an
  OpenMetrics page; instrumenting `/metrics` is the observability-module exercise.
- [ ] ❌ **Distributed tracing wired end-to-end** — OTel collector config exists
  (`labs/observability/solution/otel/`); app-side spans are a documented extension.

## 4. Delivery & operations

- [x] ✅ **CI: lint + unit tests + build + scan** — `cicd-pipelines/solution/.github/workflows/ci.yml`.
- [x] ✅ **CD: deploy via Helm** — `cicd-pipelines/solution/.github/workflows/cd.yml`
  performs `helm upgrade --install` against the chart in `labs/helm-charts`.
- [x] ✅ **Infrastructure as code, plan-reviewed** — `labs/terraform-aws-foundations`
  (`terraform validate` passes; apply is gated/manual).
- [x] ✅ **Versioned, repeatable image** — single Dockerfile reused by demo, k8s,
  and helm; image tag set by the release process.
- [x] ✅ **Runbook for the on-call** — `runbook.md` (this module).
- [x] ✅ **Architecture decisions recorded** — `adr/0001`, `adr/0002`.
- [ ] ⚠️ **Automated rollback on failed deploy** — `helm rollback` is documented in
  the runbook; auto-rollback on health-gate failure is a CD extension.
- [ ] ❌ **On-call rotation + paging integration** — Alertmanager routing is
  configured; a real PagerDuty/Opsgenie integration is account-specific.

## 5. Cost

- [x] ✅ **Local profile runs at $0** — `docker-compose.demo.yaml` (no cloud).
- [x] ✅ **Resource limits prevent runaway spend** — CPU/memory caps everywhere.
- [x] ✅ **Terraform is plan-only by default** — nothing applies (and bills) without
  an explicit, reviewed `terraform apply`.
- [ ] ⚠️ **Cost alarm / budget** — documented in the terraform module's README as a
  required add-on; not provisioned by default.

---

## Go / No-Go summary

| Area            | Provided (✅) | Demo-grade (⚠️) | Gap (❌) |
|-----------------|:-------------:|:---------------:|:--------:|
| Reliability     | 5             | 1               | 1        |
| Security        | 6             | 1               | 1        |
| Observability   | 6             | 1               | 1        |
| Delivery/Ops    | 6             | 1               | 1        |
| Cost            | 3             | 1               | 0        |

**Verdict for the course capstone:** GO for the *learning* deployment — every
core reliability, security, observability, and delivery control is backed by a
real, validated artifact. The ⚠️/❌ rows are the honest production hardening
backlog (multi-AZ, DR drill, TLS, secret rotation, tracing, auto-rollback,
paging, budget alarm) that a real launch must close, each traceable to the
module that would own it.
