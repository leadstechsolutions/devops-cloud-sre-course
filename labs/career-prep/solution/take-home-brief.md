# Take-Home Assignment Brief — Deploy & Operate a Service

> A realistic take-home of the kind DevOps/Cloud/SRE loops actually send. It is
> deliberately scoped to **~4 hours** and tests judgment, not just typing. The
> companion `take-home-solution-outline.md` is the grader's key — **do not read it
> until you have attempted the brief.**

This brief intentionally mirrors what you already built in this course's labs, so
your capstone and module work *is* your practice for the real thing. If you can do
the capstone, you can do this.

---

## The scenario

You've joined **Acme**, a small SaaS company. The team has a containerized HTTP
service (a simple JSON API — provided, or use any stateless app that exposes
`/healthz` and `/`). It currently runs as a single container on one VM that a
previous engineer SSHes into to restart when it dies. There is no monitoring, no
pipeline, and no runbook. Your job is to make it **deployable, observable, and
operable** like a real production service.

You are **not** asked to write a new application. You are asked to demonstrate the
operational engineering that turns "a container someone runs by hand" into "a
service a team can operate."

---

## What to deliver (a Git repo)

A single Git repository containing the following. **Quality and judgment beat
completeness** — a smaller, well-reasoned, working submission beats a sprawling
broken one. If you run out of time, document what you'd do next (we grade your
README's honesty too).

1. **Containerization** — a production-quality `Dockerfile` for the service:
   multi-stage, small final image, non-root user, healthcheck, pinned base. A
   `.dockerignore`. (Reference: `labs/docker-containers`.)

2. **Local stack** — a `compose.yaml` (or equivalent) that brings the service up
   locally with one command, including any dependency (e.g. Redis) it needs, so a
   reviewer can run it without your laptop. (Reference: `labs/docker-containers`,
   `labs/capstone`.)

3. **Infrastructure as code** *(plan-only is fine — do not require us to apply)* —
   Terraform (or your IaC of choice) that *describes* where this would run (a VM or
   a small cluster + networking). It must `terraform validate` cleanly and be
   formatted. We will **not** run `apply`; we read it for structure and judgment.
   (Reference: `labs/terraform-aws-foundations`.)

4. **CI pipeline** — a CI config (`.github/workflows/*.yml` or `.gitlab-ci.yml`)
   that on push: lints, builds the image, **scans it for vulnerabilities (failing
   the build on critical/high)**, and (describe) deploys. Show the security gate.
   (Reference: `labs/cicd-pipelines`, `labs/security-automation`.)

5. **Observability** — define the **3–4 signals** you would alert on for this
   service and why (think RED/USE), as either Prometheus alert rules or a clear
   written spec with the PromQL. State an **SLO** (e.g. 99.9% availability, p99
   latency) and the rationale. (Reference: `labs/observability`,
   `labs/sre-incident-response`.)

6. **Runbook** — a one-page on-call runbook: how to reach the service, the
   dashboards/queries, and a short playbook for **at least 3 alerts** (service
   down, high latency, high error rate) with copy-pasteable commands.
   (Reference: `labs/sre-incident-response`, `labs/capstone`.)

7. **README** — ties it together: how to run it, the architecture (a diagram is
   ideal), the **decisions you made and why**, the **trade-offs**, and an honest
   **"what I'd do with more time / what's not production-ready yet"** section.

---

## Constraints & rules

- **Time-box to ~4 hours.** We mean it. We'd rather see a focused, honest 4-hour
  submission than a polished 20-hour one — partly because we're testing
  prioritization. Note in the README where you stopped and why.
- **No cloud account required to evaluate.** Everything we *run* must run locally
  (compose up). Cloud IaC is read, not applied.
- **Don't gold-plate.** Reaching for a full multi-region Kubernetes platform for a
  single small service is a *negative* signal (poor judgment about scope).
- **Use any tools/languages you like**, but justify non-obvious choices in the README.
- **Cite anything you didn't write** (snippets, AI assistance) — we care about your
  reasoning, and we *will* ask you to walk through it in the follow-up call.

---

## How we evaluate (so you can self-grade)

We score on the dimensions in `take-home-solution-outline.md`. In short, we are
looking for, in priority order:

1. **Does it work?** Can we `compose up` and hit a healthy endpoint?
2. **Operability** — could we actually run this on-call? (runbook + alerts + SLO).
3. **Security** — non-root image, scanning gate, no secrets committed.
4. **Judgment** — scoped right for a small service; trade-offs articulated; honest
   about gaps.
5. **Craft** — clean IaC/CI that validates; readable README; sensible structure.

A submission that **runs, is scoped sensibly, and is honest about its gaps** scores
higher than a larger one that doesn't run or over-engineers. The follow-up call is
a conversation about *your decisions*, so be ready to defend every one.

---

## Submission

Push to a Git repo (or zip it) with a clear commit history. Include the README at
the root. Expect a **30–45 minute follow-up call** where you walk us through it and
we ask "why did you…?" about your choices.
