# Impact Bullets — The X-Y-Z Formula with 10 Before/After Examples

> The single highest-leverage edit you can make to a DevOps/SRE resume is
> rewriting activity bullets as **impact bullets**. This file gives you the
> formula, the anti-patterns, and 10 real before→after rewrites drawn from the
> work you do in this course's labs.

---

## The formula

Google's coaching popularized the **X-Y-Z** form, and it holds up because it
forces all three things a strong bullet needs:

> **"Accomplished [X] as measured by [Y] by doing [Z]."**

- **X — the accomplishment / outcome.** What got better in the world? (deploy
  speed, reliability, cost, lead time, toil removed). Not "worked on."
- **Y — the metric.** A number that proves X. Percentage, time, count, scale,
  dollars. This is what makes the claim falsifiable and therefore credible.
- **Z — the method.** *How* you did it — the technologies and approach. This is
  where your keywords and your technical depth live.

You don't have to write the words in X-Y-Z order, but **all three must be
present**. A bullet missing Y reads as a hobby; missing Z reads as luck; missing
X reads as a job description.

### The verb opens the bullet

Start with a strong past-tense verb that signals the *level* of ownership:

| Level signal | Verbs |
|--------------|-------|
| Designed / owned (senior) | `Designed`, `Architected`, `Owned`, `Led`, `Drove`, `Established` |
| Built / improved (mid) | `Built`, `Automated`, `Reduced`, `Cut`, `Migrated`, `Implemented`, `Hardened` |
| Contributed (junior) | `Contributed`, `Added`, `Wrote`, `Fixed`, `Configured` |

Avoid weak openers entirely: `Responsible for`, `Worked on`, `Helped with`,
`Involved in`, `Assisted`. They describe presence, not impact.

---

## Anti-patterns (and why they fail)

| Anti-pattern | Example | Why it fails |
|--------------|---------|--------------|
| Duty list | "Responsible for maintaining Kubernetes clusters." | A job description, not an achievement. No X, Y, or Z. |
| Activity без outcome | "Wrote Terraform modules for the team." | Has Z, missing X and Y. So what changed? |
| Vague improvement | "Improved system reliability significantly." | Has a fake X, no Y. "Significantly" is not a number. |
| Tool name-drop | "Used Prometheus, Grafana, and Loki." | Skills-list disguised as a bullet. No outcome. |
| Unfalsifiable | "Reduced costs by a huge amount." | A number you can't defend is worse than none. |
| Buzzword soup | "Leveraged synergies to drive cloud-native excellence." | Says nothing. An LLM screener discounts it; a human cringes. |

**Quantify even when you "have no numbers."** You almost always do, you just
haven't measured:
- Time: how long did the thing take before vs. after?
- Frequency: how often did it break / page someone / get done manually?
- Scale: how many services / hosts / environments / requests?
- People: how many engineers were unblocked / no longer needed?
- Money: instance hours saved, a tier you avoided, a vendor you dropped.

If you truly can't get a hard number, use a **defensible estimate** and say so in
the interview ("roughly, based on the deploy logs"). An honest estimate beats
"significantly."

---

## 10 before → after rewrites

These are drawn from the kinds of work in this course's labs (`docker-containers`,
`cicd-pipelines`, `kubernetes-fundamentals`, `terraform-aws-foundations`,
`observability`, `sre-incident-response`, `security-automation`). Use them as
templates, then swap in **your** real numbers.

### 1. CI/CD pipeline (→ `labs/cicd-pipelines`)
- ❌ **Before:** "Responsible for the CI/CD pipeline and making deployments faster."
- ✅ **After:** "Cut mean deploy time from 42 min to 6 min across 30 microservices
  by replacing hand-rolled bash with a reusable GitHub Actions matrix pipeline
  (build → Trivy scan → Helm deploy), removing ~4 failed Friday deploys/month."
- *X:* faster, more reliable deploys · *Y:* 42→6 min, 30 services, −4 failures/mo
  · *Z:* GitHub Actions matrix, Trivy, Helm.

### 2. Container image hardening (→ `labs/docker-containers`)
- ❌ **Before:** "Worked on Docker images for our services."
- ✅ **After:** "Shrank the base service image from 1.2 GB to 180 MB and cut cold
  start ~35% by moving to a multi-stage distroless build, which also dropped the
  image's known-CVE count from 60+ to 0 high/critical."
- *X:* smaller, faster, safer image · *Y:* 1.2 GB→180 MB, −35% cold start, CVEs
  60→0 · *Z:* multi-stage distroless build.

### 3. Kubernetes reliability (→ `labs/kubernetes-fundamentals`)
- ❌ **Before:** "Maintained Kubernetes clusters and fixed pod issues."
- ✅ **After:** "Eliminated recurring CrashLoopBackOff incidents (≈6/week) by
  adding correct liveness/readiness probes and resource requests/limits to 24
  Deployments, raising the workload's rolling-update success rate to ~99%."
- *X:* stopped recurring outages · *Y:* 6/week→0, 24 deployments, ~99% · *Z:*
  probes + resource requests/limits.

### 4. Infrastructure as code (→ `labs/terraform-aws-foundations`)
- ❌ **Before:** "Used Terraform to manage AWS infrastructure."
- ✅ **After:** "Replaced click-ops provisioning with version-controlled Terraform
  modules for VPC/EKS/RDS, cutting new-environment spin-up from ~2 days to 25 min
  and giving us reproducible, peer-reviewed infra across 3 environments."
- *X:* reproducible, fast, reviewable infra · *Y:* 2 days→25 min, 3 envs · *Z:*
  Terraform modules for VPC/EKS/RDS.

### 5. Observability (→ `labs/observability`)
- ❌ **Before:** "Set up monitoring and dashboards with Prometheus and Grafana."
- ✅ **After:** "Cut mean time to detect (MTTD) from ~30 min to under 2 min by
  instrumenting the payments service with RED-method metrics and Prometheus
  multi-window burn-rate alerts, replacing the 'a customer told us' detection path."
- *X:* we find problems before customers do · *Y:* MTTD 30 min→<2 min · *Z:* RED
  metrics + multi-window burn-rate alerts.

### 6. Incident response / SRE (→ `labs/sre-incident-response`)
- ❌ **Before:** "Participated in on-call and helped resolve incidents."
- ✅ **After:** "Acted as incident commander for 12 Sev-2 incidents over 6 months,
  cutting mean time to resolve from ~90 min to ~35 min by introducing a triage
  runbook and a single-channel comms protocol; wrote the blameless postmortems."
- *X:* faster, calmer incident resolution · *Y:* 12 incidents, MTTR 90→35 min ·
  *Z:* triage runbook + comms protocol + blameless postmortems.

### 7. SLOs / error budgets (→ `labs/sre-incident-response`)
- ❌ **Before:** "Defined SLAs for the services."
- ✅ **After:** "Established the first SLOs (99.9% availability, p99 < 300 ms) for 4
  tier-1 services and an error-budget policy that gated risky releases, reducing
  customer-facing incidents ~40% quarter over quarter."
- *X:* a reliability bar that actually changed behavior · *Y:* 99.9%, p99<300 ms,
  −40% incidents · *Z:* SLOs + error-budget release-gating policy.

### 8. Security automation (→ `labs/security-automation`)
- ❌ **Before:** "Helped improve security in the pipeline."
- ✅ **After:** "Reduced critical/high vulnerabilities reaching production by ~85%
  by adding a failing CI gate (Trivy image scan + tfsec/Checkov on IaC + Gitleaks
  secret scan) that blocks merge, covering all 30 service repos."
- *X:* vulns stopped before prod · *Y:* −85% crit/high, 30 repos · *Z:* Trivy +
  Checkov/tfsec + Gitleaks failing CI gate.

### 9. Cost optimization (FinOps)
- ❌ **Before:** "Reduced our AWS bill."
- ✅ **After:** "Cut monthly AWS spend ~$18k (−22%) by right-sizing over-provisioned
  EKS node groups, moving batch workloads to Spot, and deleting orphaned EBS/ELB
  resources surfaced by a weekly cost-anomaly report I automated."
- *X:* materially cheaper infra · *Y:* −$18k/mo, −22% · *Z:* right-sizing + Spot +
  orphan cleanup + automated anomaly report.

### 10. Developer experience / toil reduction
- ❌ **Before:** "Created scripts to help the team."
- ✅ **After:** "Eliminated ~10 engineer-hours/week of manual environment setup by
  building a one-command bootstrap (Makefile + Docker Compose + seed data) adopted
  by all 8 developers, cutting new-hire time-to-first-PR from ~5 days to 1."
- *X:* less toil, faster onboarding · *Y:* −10 hr/week, 8 devs, 5 days→1 · *Z:*
  Makefile + Compose + seed-data bootstrap.

---

## Self-check before you commit a bullet

For every bullet, ask:

1. **Does it have X, Y, and Z?** If any is missing, it's not done.
2. **Could I defend the number?** If an interviewer asks "how did you measure
   that," do I have an answer? (See `star-bank.md` — your bullets become STAR
   stories.)
3. **Does it start with a strong verb at the right seniority level?**
4. **Would it survive the LLM-screener test in `resume-rubric.md`?** (concrete
   keywords + a metric).
5. **Is it ≤ 2 lines?** If not, cut adjectives, not facts.

> Rule of thumb: every bullet on your resume should be a 30-second story you'd be
> happy to be asked about. If you'd dread the follow-up question, fix the bullet.
