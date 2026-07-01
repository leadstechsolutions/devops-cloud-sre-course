# Take-Home Solution Outline & Grading Key

> Grader's key for `take-home-brief.md`. This is **not** a single "correct"
> submission — it's the outline of what a strong one contains, the common failure
> modes, and a scored rubric. Use it to self-grade your attempt or to evaluate a
> candidate. **Candidates: attempt the brief before reading this.**

The brief is testing **operational judgment under a time box**, not the ability to
produce a perfect production system. The best submissions are *small, working,
honest, and well-reasoned*.

---

## What a strong submission looks like (component by component)

### 1. Containerization
- **Multi-stage** Dockerfile: a build stage, a slim final stage (distroless or
  `-slim`/`-alpine`), final image well under a few hundred MB.
- **Non-root** `USER`, a `HEALTHCHECK`, **pinned** base image (digest or specific
  tag, not `latest`), minimal layers, `.dockerignore` present.
- **Red flags:** runs as root; `FROM ubuntu:latest`; 1 GB+ image; secrets or build
  tooling left in the final layer; no healthcheck.

### 2. Local stack
- One command (`docker compose up`) brings up the service **and its dependency**
  with a healthcheck and sensible defaults; reviewer needs nothing but Docker.
- **Red flags:** requires manual steps, hardcoded localhost assumptions, doesn't
  actually come up healthy, depends on the author's machine state.

### 3. Infrastructure as code (plan-only)
- Formatted (`terraform fmt`), `terraform validate` clean, `init -backend=false`
  works. Sensible modules/variables; networking and the compute target described;
  tags. No hardcoded secrets; remote state mentioned even if not wired.
- **Red flags:** doesn't validate; copy-pasted from a tutorial with dead resources;
  secrets in `.tf`; over-built (a full EKS + multi-AZ + RDS HA stack for one tiny
  stateless service = poor scope judgment).

### 4. CI pipeline
- On push: lint → build → **vulnerability scan that fails on critical/high** →
  (described) deploy. The **security gate is the key tested element** — a build
  that scans but doesn't fail on findings misses the point.
- Bonus: caching, matrix, SBOM, image signing, separate deploy gate for prod.
- **Red flags:** no scan, or a scan that's purely informational; secrets printed in
  logs; deploy with long-lived static creds.

### 5. Observability
- Names the right signals (RED for a request service: **Rate, Errors, Duration**;
  plus saturation/USE for the host). 3–4 concrete alerts with thresholds tied to
  user impact, not arbitrary CPU numbers.
- A stated **SLO** (e.g. 99.9% availability, p99 < 300 ms) with rationale, ideally a
  **burn-rate** alert rather than a static threshold.
- **Red flags:** "alert on CPU > 80%" with no link to user impact; no SLO; alerting
  on causes instead of symptoms; vanity metrics.

### 6. Runbook
- Service summary, how to reach it, dashboard/query links, and a **per-alert
  playbook** (service down / high latency / high error rate) with copy-pasteable
  commands and an escalation path.
- **Red flags:** generic "check the logs" with no commands; no escalation; nothing
  an actual on-call could follow at 3am.

### 7. README & judgment
- How to run it; architecture (diagram a plus); **decisions + trade-offs**; an
  honest **"what I'd do with more time / not production-ready yet"** section.
- **This honesty section is a strong positive signal** — it shows the candidate
  knows the difference between a take-home and production and can prioritize.
- **Red flags:** claims production-readiness it doesn't have; no rationale for
  choices; no acknowledgment of gaps.

---

## Scoring rubric (100 pts)

| Dimension | What earns full marks | Pts |
|-----------|-----------------------|----:|
| **It works** | `compose up` yields a healthy endpoint we can curl | 20 |
| **Operability** | SLO + symptom-based alerts + a runbook an on-call could follow | 20 |
| **Security** | non-root image + failing scan gate + no committed secrets + least-priv creds | 15 |
| **Containerization craft** | multi-stage, small, pinned, healthcheck, .dockerignore | 10 |
| **IaC craft** | validates, formatted, sensibly scoped, no secrets | 10 |
| **CI craft** | clean pipeline, security gate fails correctly, sensible stages | 10 |
| **Judgment & scope** | right-sized for a small service; trade-offs articulated; honest gaps | 10 |
| **Communication** | clear README + diagram + decision log | 5 |

**Bands:**
- **85–100** — Strong hire. Works, operable, secure, sensibly scoped, honest.
- **70–84** — Hire. Works and shows good instincts; missing depth in one area.
- **55–69** — Mixed. Works but thin on operability or security, or over-engineered.
- **< 55** — Below bar. Doesn't run, or no operational/security thinking, or wildly
  over/under-scoped.

---

## The follow-up call (what we probe)

A strong submission can still fail the call, and a modest one can shine on it. We ask:

- *"Walk me through a request from the browser to a response."* (Do they understand
  their own system?)
- *"Why did you pick X over Y?"* for 2–3 of their choices. (Judgment, not recall.)
- *"This is 3am and the error-rate alert fires — what do you do?"* (Operability,
  ties to `star-bank.md` incident stories.)
- *"What's the first thing that breaks at 10x traffic?"* (Scaling instinct.)
- *"What did you cut for time, and what's the risk of shipping it as-is?"* (Honesty
  + prioritization — the single most predictive question.)

The candidate who is **honest about gaps and can defend every decision** beats the
one with a bigger submission they can't explain.

---

## How to self-grade your own attempt

1. Run your own `compose up` on a clean machine/container. Does it come up healthy?
2. Run `terraform fmt -check` + `validate` and your CI locally — green?
3. Hand your README to someone and ask them to run it with no help. Could they?
4. For every decision, can you answer "why not the alternative?" out loud?
5. Did you write the honest "not production-ready because…" section? If not, add it
   — its absence is a bigger red flag than any technical gap.
