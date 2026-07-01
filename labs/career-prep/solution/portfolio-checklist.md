# Portfolio Checklist — Turning This Course Into Hireable Evidence

> Your portfolio is the **proof** behind your resume bullets and STAR stories. A
> hiring manager who can `git clone` your work and see it run trusts you in a way no
> bullet point can earn. The good news: **you've already built it** — this course's
> labs and capstone are your portfolio. This checklist turns that work into
> presentable, hireable evidence and maps each piece to the skill it proves.

The principle from this course's own artifact standard applies to your portfolio
too: *a skill is "demonstrated" only when someone can execute it.* A portfolio of
runnable, validated projects beats a portfolio of READMEs describing projects you
"would" build.

---

## The mapping — each lab proves a specific competency

Every module you completed maps to a competency a JD will list and an interviewer
will probe. Check off what you can **demonstrate running**, not just what you read.

| Competency (JD keyword) | This course's artifact | Proof it provides | Done? |
|-------------------------|------------------------|-------------------|:-----:|
| Linux / shell automation | `labs/linux-shell-automation` | Idempotent, `shellcheck`-clean scripts with tests | [ ] |
| Python automation / tooling | `labs/python-automation` | Real CLI/automation + `pytest` suite | [ ] |
| Git / collaboration workflow | `labs/git-collaboration` | Branching, hooks, reviewed history | [ ] |
| Infrastructure as Code (Terraform/AWS) | `labs/terraform-aws-foundations` | Validated, formatted modules (VPC/etc.), plan-only safe | [ ] |
| CI/CD pipelines | `labs/cicd-pipelines` | GitHub Actions + GitLab CI with a security gate | [ ] |
| Containers / Docker | `labs/docker-containers` | Multi-stage, small, non-root image + compose stack | [ ] |
| Kubernetes | `labs/kubernetes-fundamentals` | Manifests with probes/limits, `kubeconform`-clean | [ ] |
| Helm / packaging | `labs/helm-charts` | A chart that lints, templates, and validates | [ ] |
| Config management (Ansible) | `labs/ansible-config-mgmt` | Playbooks/roles, `ansible-lint`-clean, `--check` runs | [ ] |
| Observability / monitoring | `labs/observability` | Prometheus rules, RED metrics, Grafana dashboards | [ ] |
| Security / supply chain | `labs/security-automation` | Scan gates (Trivy/Checkov/Gitleaks), policy as code | [ ] |
| SRE / incident response | `labs/sre-incident-response` | SLOs, error budgets, runbooks, k6 load tests | [ ] |
| **System integration & operability** | **`labs/capstone`** | **The whole stack wired together, demoable, with ADRs + runbook + readiness gate** | [ ] |

**The capstone is your flagship.** It's the one project that shows you can
*integrate and operate*, not just build a single component — the difference between
a 7 and a 9 on this course's own scoring ladder, and the difference between "junior"
and "mid/senior" to a hiring manager. Lead your portfolio with it.

---

## Make each project presentable

A project isn't portfolio-ready just because the code exists. For **each** project
you'll show:

- [ ] **A README that a stranger can run.** Prerequisites, one-command setup, what
      it does, and what success looks like. (You already wrote these for the labs —
      reuse the structure.)
- [ ] **An architecture diagram** (Mermaid is fine — the capstone has one). A
      picture earns trust fast.
- [ ] **It actually runs / validates** from a clean clone. Re-run `./validate.sh`.
      A broken demo is worse than no demo.
- [ ] **A "decisions & trade-offs" note** — even a short ADR. This is what signals
      *judgment*, the thing senior interviews actually test. The capstone's `adr/`
      is your model.
- [ ] **A short "what I'd do next / what's not production-ready"** honesty section —
      shows you know the difference between a portfolio piece and production.
- [ ] **Clean commit history** — small, meaningful commits read as professional;
      one "final commit" of everything reads as a code dump.

---

## The portfolio README (your front page)

Create one top-level `README.md` (or a GitHub profile README / personal site) that
is the **index** recruiters and hiring managers land on:

- [ ] A one-paragraph **summary**: who you are, your stack, what you're looking for.
- [ ] A **project list**, capstone first, each with: one line on what it is, the
      tech, and a link. Lead with impact ("a production-ready, observable service
      wiring together IaC, CI/CD, k8s, and SRE practices"), not a file list.
- [ ] **Direct links** to the runnable repos and (where possible) a live demo,
      recorded walkthrough (a 3-min Loom of you running the capstone is gold), or
      screenshots of the Grafana dashboards.
- [ ] Your **contact + resume link** (the resume from `resume-rubric.md`).

---

## Connecting the portfolio to the rest of your job search

Your portfolio is the hub the other career artifacts point at:

- [ ] **Resume** (`resume-rubric.md`): your Projects/Portfolio line links here; your
      impact bullets (`impact-bullets.md`) are drawn from this work — and now they're
      *defensible* because the code is public.
- [ ] **STAR stories** (`star-bank.md`): the incident, failure, and ownership
      stories you tell can reference real artifacts ("I added the burn-rate alert —
      it's in my observability repo").
- [ ] **System design** (`system-design/`): the observability-pipeline and
      cicd-platform prompts are the *scaled-up* version of your `labs/observability`
      and `labs/cicd-pipelines` work — you've built the small version, so you can
      reason about the big one credibly.
- [ ] **Take-home** (`take-home-brief.md`): the brief deliberately mirrors your
      capstone — your portfolio *is* your take-home practice.
- [ ] **GitHub profile**: pinned repos = capstone + 2–3 strongest labs. A green
      contribution graph and clean repos are themselves a signal.

---

## Final portfolio gate (before you put the link on a resume)

- [ ] Every linked repo **clones and runs/validates** from scratch (you tested it on
      a clean machine, not just yours).
- [ ] The **capstone is front and center** and demonstrably runs.
- [ ] Each project has a runnable README, a diagram, and a decisions note.
- [ ] No secrets, keys, or `.env` files committed anywhere (run a secret scan —
      `labs/security-automation` taught you how).
- [ ] A stranger could land on your front page and, in 60 seconds, know what you do
      and click into something that runs.
- [ ] Every resume bullet that cites this work points to a real, public, running
      artifact.

> The portfolio's whole job is to make your claims **checkable**. When a hiring
> manager can verify you can do the work by running it, the interview stops being
> "can this person do it?" and becomes "let's talk about how they did it" — which
> is exactly the conversation you want.
