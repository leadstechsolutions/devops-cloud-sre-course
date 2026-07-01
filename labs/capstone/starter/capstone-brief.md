# Capstone Brief (student)

> This is your assignment. The `solution/` artifacts in this module are the
> reference answer — **do not read them until you have attempted the brief.**
> Budget: ~2 sessions (Weeks 23 & 24). You are *integrating* modules you already
> built, not writing a system from scratch.

## The goal

Stand up the course application as a **production-ready, observable, operable
service** by wiring together the modules you built in earlier weeks:

| Capability        | Module you reuse                       |
|-------------------|----------------------------------------|
| Infrastructure    | `labs/terraform-aws-foundations`       |
| Container image   | `labs/docker-containers`               |
| Orchestration     | `labs/kubernetes-fundamentals`         |
| Packaging/deploy  | `labs/helm-charts`                     |
| Pipeline          | `labs/cicd-pipelines`                  |
| Observability     | `labs/observability`                   |
| Operations        | `labs/sre-incident-response`           |

You write **minimal new code**. The capstone is about *integration, judgment,
and operability* — diagrams, decisions, a readiness gate, a runbook, and a
single demoable local stack — not new application features.

## Deliverables (what you submit)

1. **`architecture/architecture.mmd`** — a full-system Mermaid diagram showing how
   the seven modules connect (CI/CD → registry → infra → k8s/helm workload →
   observability → SRE). Every box must map to a real module.

2. **Two ADRs** under `adr/`, using `starter/adr/NNNN-template.md`:
   - `0001-record-architecture-decisions.md` — adopt ADRs; explain the format and
     the supersede rule.
   - `0002-managed-vs-self-hosted.md` — a real decision table (control plane,
     registry, Redis, observability, state) with rationale and "revisit when…"
     triggers.

3. **`production-readiness-checklist.md`** — a concrete go/no-go gate. Every item
   ticked `[x]` must point at a real artifact that provides it; honestly mark the
   gaps `[ ]` with what a real launch would still need.

4. **`runbook.md`** — on-call guide: service summary, how to reach things, and a
   playbook per alert (error-budget burn, CrashLoopBackOff, dependency down,
   OOMKilled, high latency) with copy-pasteable commands.

5. **`docker-compose.demo.yaml`** — ONE local stack that brings up the **same app
   image** (built from `labs/docker-containers`) + Redis + an optional Prometheus
   (behind a `metrics` profile), so the whole thing is demoable on a laptop with
   no cloud account. Reuse the image; do not fork it.

6. **A reference checker** that asserts every `labs/<module>` path you cite
   actually exists (so the integration can't silently rot).

## Acceptance — your work is "done" when

- [ ] `./validate.sh` exits 0 (YAML parses, `docker compose config` parses, the
      reference checker passes, shell/py syntax clean).
- [ ] `docker compose -f docker-compose.demo.yaml up --build` brings the app up
      and `curl http://127.0.0.1:8000/healthz` returns `{"status":"ok"}`.
- [ ] Every box in `architecture.mmd` maps to a real module directory.
- [ ] Both ADRs follow the template and record a real decision (not a placeholder).
- [ ] Every `[x]` in the readiness checklist is backed by a real file path.
- [ ] The runbook has at least 4 alert→action playbooks with real commands.

## Constraints

- **Reuse, don't duplicate.** Link to module paths; build the app from the
  existing Dockerfile/context. Copy-pasting another module's files into the
  capstone is a *fail*, not a pass.
- **$0 local.** The demo must run with no cloud spend. Terraform stays plan-only.
- **Honest status.** Mark gaps as gaps. A readiness checklist that ticks
  everything `[x]` without evidence is the failure this course exists to prevent.

## Hints

- Start with the reference checker — it tells you the exact module/file paths to
  cite everywhere else, and fails loudly if you mistype one.
- The app already serves `/healthz` and reads `PORT`/`REDIS_HOST`/`REDIS_PORT`
  from the environment — match that contract in compose and in the k8s ConfigMap.
- For the optional Prometheus, you do not need the full observability stack; a
  tiny scrape config that proves "metrics flowing" is enough for the demo. The
  real rules/dashboards already live in `labs/observability`.
