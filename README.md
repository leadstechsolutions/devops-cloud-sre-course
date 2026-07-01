# LEADS Academy — DevOps · Cloud Engineering · SRE

A hands-on, job-ready **DevOps, Cloud Engineering, and Site Reliability Engineering** course,
delivered as a single converged **25-week** track: **50 class packages** and **21 runnable lab
modules** you clone, complete, and validate — real files you lint, plan, build, run, and test,
not fenced code blocks inside slides.

> 📚 **Full syllabus:** [`CURRICULUM.md`](CURRICULUM.md) — the complete week-by-week breakdown
> (topics, hands-on lab, and outcome for all 25 weeks).

## What's inside

- **[`01-foundation-track/`](01-foundation-track/)** — Weeks 1–16. The shared engineering
  foundation: Linux, Git, networking, AWS core, scripting, CI/CD, containers, Kubernetes,
  Terraform, and observability.
- **[`02-advanced-track/`](02-advanced-track/)** — Weeks 17–25. Advanced specializations
  (landing zones & governance, FinOps, DevSecOps, platform engineering, SRE, performance),
  a two-week **capstone**, and **resume / interview** preparation.
- **[`labs/`](labs/)** — 21 self-contained, runnable lab modules — the executable half of the
  course. See [`labs/README.md`](labs/README.md).

Every week ships as two class packages (`class-01.md`, `class-02.md`) — 25 weeks, 50 classes —
each linking to its runnable lab under `labs/`.

## How the labs work

Each module under [`labs/`](labs/) is a self-contained project:

| Path | What it is |
|------|------------|
| `starter/` | Your working copy — complete the `TODO(student)` gaps here. |
| `solution/` | The reference implementation — check yourself against it. |
| `tests/` | The automated test suite for the module. |
| `validate.sh` | Runs every gate (lint, tests, build) for the module. |
| `README.md` | Brief, prerequisites, architecture, expected output, troubleshooting, cleanup, and cost notes. |

Typical flow:

```bash
cd labs/<module>
cat README.md                 # read the brief and prerequisites
# ...edit files under starter/ to complete the TODO(student) gaps...
./validate.sh                 # run the checks
# compare against solution/ when you get stuck
```

**Start here:** [`labs/setup-validation/`](labs/setup-validation/) — it verifies your toolchain
is course-ready.

## Prerequisites

- Comfort with a terminal / command line. **No prior DevOps experience required.**
- **Git**, plus the per-lab tools (each lab README lists exactly what it needs — most are free and
  run locally).
- For the **cloud labs**: an **AWS account** (free tier + a small budget). Cloud labs follow a
  **build → verify → destroy** flow to stay cost-safe.

## Tools you'll use

Linux · Bash · Python · Git & GitHub/GitLab · AWS (VPC, EC2, S3, IAM, RDS, Organizations,
CloudWatch…) · Terraform · Docker · Kubernetes · Helm · Ansible · GitHub Actions / GitLab CI ·
Prometheus & Grafana · OpenTelemetry · k6 · OPA/Conftest · Trivy / Grype / Syft · gitleaks · kind.

## Getting started

```bash
git clone <this-repo-url>
cd devops-cloud-sre-course
cd labs/setup-validation && cat README.md   # verify your machine is course-ready
```

Then work week by week: read `class-01.md` / `class-02.md` for the week, then complete its lab.

---

> **Note on the security labs:** the secret-scanning exercises intentionally include the
> well-known **AWS documentation example keys** (`AKIAIOSFODNN7EXAMPLE`) as test fixtures.
> These are non-functional placeholders, not real credentials.
