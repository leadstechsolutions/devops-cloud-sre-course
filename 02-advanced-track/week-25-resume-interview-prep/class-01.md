# Week 25, Class 1 Package
> **▶ Runnable lab for this class:** [`labs/career-prep/`](../../labs/career-prep/)
>
> The **on-disk, validated** version of this class's work — clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check against `solution/`, then run `./validate.sh`.

## Resume, LinkedIn, and Portfolio for DevOps / Cloud / SRE Roles

**Week:** 25
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Resume, LinkedIn, and Portfolio for DevOps / Cloud / SRE Roles**

## Class Purpose

This class turns 24 weeks of skills and the capstone project (Weeks 23–24) into the three artifacts a hiring pipeline actually reads: a one-page, machine-parseable resume; a recruiter-discoverable LinkedIn profile; and a public GitHub portfolio that proves the work. The goal is not "make a nice document" — it is to build artifacts that survive a 2026 screening funnel (automated ATS + LLM resume screeners → recruiter skim → hiring-manager review) and that position the candidate at the correct level: junior, mid, or senior.

This is the program's career payoff. Everything technical the student learned only converts to an offer if it is *legible* to the people and systems doing the hiring.

## How This Class Connects to the Overall Course

This class is the bridge between learning and getting hired. It consumes the entire course as raw material:

- **Capstone (Weeks 23–24)** — the flagship portfolio project and the source of the strongest resume bullets and the GitHub showcase.
- **CI/CD (Week 9), Docker (Week 10), Kubernetes (Weeks 11–12), Helm (Week 13)** — concrete delivery-engineering bullets.
- **Terraform/OpenTofu (Weeks 14–15), Landing Zones (Week 17)** — Infrastructure-as-Code and multi-account scope bullets.
- **Observability (Week 16), SRE Foundations (Week 21), Performance/Capacity (Week 22)** — reliability, SLO, and on-call bullets that distinguish an SRE candidate.
- **Cloud Security/IAM (Week 6), DevSecOps (Week 19)** — security/governance bullets.
- **Cost Optimization (Week 18), Platform Engineering (Week 20)** — FinOps and platform/golden-path bullets.

Class 2 (interview prep) then defends these artifacts: every resume bullet and portfolio repo becomes a STAR story and a design-defense in the interview loop.

## What Students Will Build, Analyze, or Practice

By the end of this class each student will have:

- A finished, one-page, ATS-friendly resume draft using the provided template.
- 8–10 quantified impact bullets mapped to specific course weeks/labs.
- A self-assessed positioning level (junior / mid / senior) with the bullets rewritten to match.
- An optimized LinkedIn headline, About section, and Skills/Featured sections.
- A portfolio README for the capstone repo, plus a pinned-repo and ADR plan.
- A 12-month certifications plan calibrated to their target role.

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Structure** a one-page, ATS-friendly resume with the correct section order for DevOps/Cloud/SRE roles.
2. **Write** quantified impact bullets using the X-Y-Z formula (accomplished X, measured by Y, by doing Z).
3. **Map** the capstone and weekly labs to specific, metric-bearing resume bullets.
4. **Explain** how 2026 ATS and LLM resume screeners parse and rank a resume, and format to survive them.
5. **Differentiate** junior, mid, and senior positioning (scope, ownership, leadership, technical decision-making) and rewrite a bullet for each level.
6. **Optimize** a LinkedIn profile (headline, About, skills, Featured) for recruiter discoverability.
7. **Build** a senior-signal GitHub portfolio (READMEs, architecture diagrams, pinned repos, ADRs, tradeoff writeups).
8. **Compare** AWS/CKA/Terraform certifications and decide which ones to pursue and when.

---

# 3. Prerequisites Students Should Already Know

**Required prior concepts**
- Completed the capstone (Weeks 23–24), or have a substantial project to write about.
- Familiarity with the full course toolchain (Git, Docker, Kubernetes, Terraform/OpenTofu, CI/CD, AWS).
- Understanding of what they built and *why* — the architectural decisions, not just the commands.

**Required tools already installed / accounts**
- A GitHub account with the capstone repository pushed.
- A LinkedIn account.
- A word processor or Markdown/LaTeX editor for the resume (Google Docs, Word, or a Markdown-to-PDF flow).
- Optional: a diagramming tool (draw.io / Excalidraw / Mermaid) for architecture diagrams.

**Files / repos needed**
- The capstone repo and its README.
- A running list of metrics from labs (deploy times, MTTR, cost deltas, test coverage, image sizes) gathered during the course. If the student did not record these, this class includes a worksheet to reconstruct reasonable estimates.

---

# 4. Key Terms and Definitions

- **ATS (Applicant Tracking System)** — software (Greenhouse, Lever, Workday, Ashby) that ingests, parses, stores, and ranks resumes. It extracts text and maps it to fields; if it can't parse your file, a human may never see it. Real-world context: a large company can receive 200+ applications per req; the ATS is the first filter.
- **LLM resume screener** — a 2026-era layer where a large language model summarizes/ranks candidates against the job description. It reads prose, so keyword *stuffing* (white text, keyword walls) backfires; it rewards clear, relevant, contextual language.
- **X-Y-Z bullet formula** — "Accomplished **X** as measured by **Y** by doing **Z**." Forces every bullet to carry an outcome and a metric, not just a task.
- **Quantified impact** — a number that shows business or reliability value: deployment frequency, MTTR (mean time to recovery), lead time for changes, % cost reduced, uptime/availability, error-rate reduction, build-time reduction.
- **DORA metrics** — the four industry-standard delivery metrics: deployment frequency, lead time for changes, change failure rate, MTTR. Hiring managers recognize them instantly; speaking in them signals maturity.
- **Positioning / leveling** — matching how you describe your work to the target level. Junior = "did the task"; senior = "owned the system, decided the approach, reduced risk, raised the team."
- **Scope** — the blast radius of your work: one service vs. a platform; one team vs. cross-team; a script vs. an architecture.
- **ADR (Architecture Decision Record)** — a short markdown doc capturing a decision, its context, the options considered, and the tradeoff chosen. A strong senior portfolio signal.
- **Keyword/JD alignment** — tailoring resume language to the exact terms in the job description (e.g., the JD says "EKS," your resume should say "EKS," not just "Kubernetes").
- **Featured section (LinkedIn)** — a pinned area at the top of a profile for showcasing the capstone repo, a blog post, or a diagram.

---

# 5. Tools Used

- **Resume template (provided in this class, Section 11/Lab)** — a plain, single-column, ATS-safe layout. Used because complex tables/columns/graphics break ATS parsing.
- **GitHub** — hosts the portfolio; pinned repos and READMEs are the proof-of-work layer.
- **LinkedIn** — the recruiter discovery surface; the headline and Skills drive search matching.
- **Markdown + Mermaid / draw.io / Excalidraw** — for portfolio READMEs and architecture diagrams.
- **A "metrics log"** (spreadsheet or notes file) — to capture the numbers that become bullet metrics.
- **jobscan-style keyword check (manual)** — paste the JD and your resume side by side; verify the key nouns appear. (No specific paid tool required; a manual diff works.)

---

# 6. AWS Services Used

This class is not hands-on AWS, but the resume/portfolio should *name* the AWS services the student actually used, because ATS/recruiters search for them:

- **EC2, S3, RDS, VPC** (Weeks 5, 7) — core compute/storage/network/database.
- **IAM, KMS, Secrets Manager** (Week 6) — identity and secrets; security bullets.
- **EKS, ECR** (Weeks 10–13) — managed Kubernetes and container registry.
- **CloudWatch** (Week 16) — observability/metrics/logs.
- **Organizations, Control Tower, IAM Identity Center** (Week 17) — multi-account/landing-zone scope.
- **Cost Explorer / Budgets** (Week 18) — FinOps bullets.

Guidance: list only services you can speak to in an interview. A service on the resume is an invitation to be questioned on it (covered in Class 2).

---

# 7. Azure and GCP Comparison Notes

- If targeting an Azure shop, mirror the AWS terms: EC2→VM, S3→Blob Storage, EKS→AKS, IAM→Entra ID, CloudWatch→Azure Monitor. For GCP: GCE, GCS, GKE, IAM, Cloud Monitoring.
- Recruiters search by the cloud named in the JD. If the JD says "Azure" and your experience is AWS, add a line: "AWS-native; transferable to Azure (concepts map 1:1: AKS, Entra ID, Azure Monitor)." Do not claim hands-on Azure you don't have.
- Multi-cloud on a resume is a double-edged signal: it reads as breadth for senior roles but can read as unfocused for a junior. Match it to the JD.

---

# 8. Time-Boxed Instructor Agenda (3 hours)

| Time | Segment | Activity |
|------|---------|----------|
| 0:00–0:10 | Kickoff | Why this class is the payoff; the 2026 screening funnel diagram (Section 11). |
| 0:10–0:35 | Lecture: Resume anatomy + ATS/LLM mechanics | Section order, formatting do's/don'ts, how screeners parse. |
| 0:35–1:00 | Lecture + worked examples: X-Y-Z bullets, DORA metrics, capstone→bullet mapping | Build 2–3 bullets live from a course lab. |
| 1:00–1:20 | Lecture: junior vs mid vs senior positioning | Same bullet rewritten at 3 levels; scope/ownership/leadership signals. |
| 1:20–1:30 | **Break** | — |
| 1:30–2:15 | **Lab Part A** | Students draft their resume from the template; instructor floats. |
| 2:15–2:35 | Lecture + demo: LinkedIn + GitHub portfolio (READMEs, diagrams, ADRs, pinned repos) | Live profile/README walkthrough. |
| 2:35–2:50 | **Lab Part B + peer review** | Swap resumes; run the resume rubric checklist. |
| 2:50–2:58 | Certifications strategy + personal brand | 12-month cert plan; blog/OSS/meetup. |
| 2:58–3:00 | Recap + homework | Outcome checklist, homework assignment. |

---

# 9. Instructor Lesson Plan

**Step 1 — Frame the funnel (10 min).** Draw the screening funnel (Section 11). The point: a brilliant engineer with an unparseable resume never reaches a human. Pause for the room to react; ask "how many of you have a resume in a two-column template?" (Most will.)

**Step 2 — Resume anatomy and ATS mechanics (25 min).** Walk the section order. Explain *why* single-column, standard headings, no tables/text-boxes/headers-footers/graphics, standard fonts, .docx or text-based PDF. Show what an ATS "sees" when it parses a two-column resume (interleaved garbage). Then explain the LLM-screener layer and why keyword stuffing now backfires. Pause for questions.

**Step 3 — Impact bullets, live (25 min).** Introduce X-Y-Z and DORA. Take a real course lab (e.g., the Week 9 CI/CD pipeline) and build a weak bullet → strong bullet on the board. Repeat with a Week 12 troubleshooting lab and a Week 18 cost lab. Hand out the capstone→bullet mapping table (Section 11). Teaching tip: students chronically undersell — push them for a number every time.

**Step 4 — Positioning by level (20 min).** Show the same accomplishment written for junior, mid, and senior. Make the senior signals explicit: ownership ("led," "owned," "decided"), scope ("across 4 teams," "platform serving 30 services"), risk reduction ("cut blast radius," "reduced MTTR"), and people ("mentored 2 engineers"). Caution against over-claiming — leveling mismatch gets you rejected fast in the screen.

**Step 5 — Lab Part A (45 min).** Students fill the template. Instructor floats; the #1 intervention is "add a number" and "what was the *outcome*?"

**Step 6 — LinkedIn + GitHub (20 min).** Live-edit a sample LinkedIn headline and About. Open a sample capstone repo and show a great README, a Mermaid architecture diagram, an ADR, and pinned repos. Tie ADRs back to the capstone (Weeks 23–24).

**Step 7 — Peer review (15 min).** Pairs swap resumes and run the rubric (Section 22). Each gives one "keep" and two "fix."

**Step 8 — Certs + brand + recap (10 min).** 12-month cert plan; one personal-brand action. Assign homework.

---

# 10. Instructor Lecture Notes

## 10.1 The 2026 screening funnel

Talking point: *"Your resume has three readers, in this order: a parser, a model, and a human. You have to pass all three, and they want different things."*

- **The parser (ATS)** wants clean structure. It extracts text and maps it to fields (name, title, dates, skills). Two-column layouts, tables, text boxes, images, and content in headers/footers routinely parse as scrambled text or get dropped. Standard section headings ("Experience," "Skills," "Projects," "Education") help it map correctly.
- **The LLM screener** wants relevant, honest prose. It reads context, so it rewards bullets that clearly match the JD and *penalizes* keyword walls because they read as low-signal. The 2024-era trick of stuffing invisible keywords is now a liability.
- **The human** (recruiter then hiring manager) spends 10–30 seconds on the first pass. They scan top-third, titles, companies, and numbers. Lead with impact.

Common misconception: *"A beautiful designed resume stands out."* For DevOps/Cloud/SRE it usually gets *filtered* out. Design is for designers; we ship plain text that parses. (Note the irony: this course teaches in tables for readability, but the resume itself must be single-column.)

## 10.2 Resume anatomy (section order)

1. **Header** — name, target title, city/remote, email, phone, GitHub URL, LinkedIn URL. No photo, no full street address.
2. **Professional summary** (2–3 lines, optional for juniors) — role + years/scope + 1–2 signature strengths. Senior candidates should keep it; juniors can drop it in favor of more project space.
3. **Skills / Technical proficiencies** — grouped (Cloud, Containers/Orchestration, IaC, CI/CD, Observability, Languages). Use the JD's exact terms.
4. **Experience** (if any) — reverse-chronological, X-Y-Z bullets.
5. **Projects** — for career-changers/juniors this is the star section; lead with the capstone.
6. **Certifications** — only real, current ones.
7. **Education** — degree(s); keep short.

One page for <10 years experience. Reverse chronological is the only safe format for ATS (functional/skills-based resumes parse poorly and signal "hiding something").

## 10.3 The X-Y-Z / quantified-impact formula

Talking point: *"Every bullet is a tiny case study: what got better, by how much, and how you did it."*

- **X (what you accomplished / the outcome)** — the business or reliability result.
- **Y (the metric)** — the number proving it.
- **Z (how)** — the technical action/tools.

The DORA metrics give juniors a credible numeric vocabulary even from labs:
- Deployment frequency (per day/week)
- Lead time for changes (commit → prod)
- Change failure rate (% of deploys causing incidents)
- MTTR (time to recover)
Plus: % cost reduced, uptime/availability (e.g., 99.9%), build/test time reduced, image size reduced, coverage increased.

Honesty rule: lab/capstone numbers are *project* numbers — phrase them as such ("In a capstone project…"). Never invent production numbers for a job you didn't hold. Fabrication collapses in the interview (Class 2).

## 10.4 Weak → strong bullet examples (worked)

- Weak: *"Built a CI/CD pipeline with GitHub Actions."*
  Strong: *"Cut deploy lead time from ~30 min of manual steps to under 6 min by building a GitHub Actions pipeline (build → test → multi-stage Docker → push to ECR → deploy), enabling multiple deploys per day (capstone, W9/W23)."*
- Weak: *"Worked on Kubernetes troubleshooting."*
  Strong: *"Reduced pod startup failures to zero by diagnosing a CrashLoopBackOff to a missing ConfigMap key using an evidence-first method (kubectl describe/logs/events) and adding a readiness probe (W12)."*
- Weak: *"Used Terraform for infrastructure."*
  Strong: *"Provisioned a reproducible 3-tier AWS environment (VPC, EKS, RDS) as code in Terraform/OpenTofu with remote state + plan-before-apply review, cutting environment setup from days to ~15 min (W14–15/W23)."*

## 10.5 Positioning: junior vs mid vs senior

Same accomplishment, three altitudes:
- **Junior:** *"Implemented a GitHub Actions pipeline that builds, tests, and deploys a containerized service to EKS."* (Did the task.)
- **Mid:** *"Designed and owned a CI/CD pipeline for a containerized service, cutting deploy lead time ~80% and adding automated rollback on failed health checks."* (Owned outcome + reliability.)
- **Senior:** *"Led the design of a standardized CI/CD golden path adopted across multiple services, reducing change failure rate and onboarding time, and mentored 2 engineers on safe deploy practices; chose trunk-based + progressive delivery after evaluating Git-flow tradeoffs (documented in an ADR)."* (Scope, leadership, technical decision, mentoring, tradeoff reasoning.)

Senior signal checklist: **scope** (platform/cross-team), **ownership** (led/owned/drove), **technical decision-making** (chose X over Y, documented why), **risk reduction** (blast radius, MTTR, error budget), **people** (mentored, set standards). Leveling honesty: claim the level your scope supports — over-claiming gets caught in the screen; under-claiming leaves money and title on the table (Class 2 negotiation).

## 10.6 LinkedIn optimization

- **Headline** — not just "DevOps Engineer." Pack role + stack + value: *"DevOps / Cloud Engineer | AWS · Kubernetes · Terraform · CI/CD | Building reliable, cost-aware delivery platforms."* Headlines are heavily weighted in recruiter search.
- **About** — first 2 lines show before "see more"; lead with value. 3–5 short paragraphs: who you are, core stack, a signature accomplishment with a metric, what you're looking for.
- **Skills** — fill all relevant; endorsements and skill-match drive recruiter filtering. Mirror JD terms.
- **Featured** — pin the capstone repo, an architecture diagram, or a blog post.
- **Open to Work** — enable the recruiter-only setting; set target titles and locations (incl. Remote).
- Custom public URL; professional photo; consistent title with the resume.

## 10.7 GitHub portfolio hygiene (and senior signals)

Baseline: clean READMEs, pinned repos (6 best), descriptive repo names, no secrets in history, sensible commit messages.

What *senior* reviewers actually look for:
- A README that states the **problem, architecture, decisions, and how to run it** — with a diagram (Mermaid/draw.io).
- **ADRs** in `/docs/adr/` capturing real tradeoffs (e.g., "Helm vs raw manifests," "single-region vs multi-region," "OpenTofu vs Terraform"). This is the highest-leverage senior signal and closes the ADR thread from the capstone (Weeks 23–24).
- **IaC quality** — modular Terraform/OpenTofu, remote state, no hardcoded secrets, plan output discipline.
- A **tradeoff / incident writeup** — a short "what broke and how I fixed it" using the course's symptom→evidence→root-cause→fix→validate method.
- Tests/CI badges; a `Makefile` or task runner; cleanup instructions for any cloud resources (cost/security hygiene).

## 10.8 Certifications strategy

Talking point: *"Certs open doors at the ATS/recruiter stage; the portfolio closes them at the hiring-manager stage. You need both, in the right order."*

- **AWS Solutions Architect Associate (SAA)** — broad cloud literacy; the highest ATS keyword value for Cloud/DevOps roles. Best first cert.
- **AWS SysOps / Developer Associate** — ops/CI-CD leaning; good second.
- **CKA (Certified Kubernetes Administrator)** — hands-on K8s; strong signal for platform/SRE roles. CKAD for app-deploy focus.
- **HashiCorp Terraform Associate** — quick win, validates IaC literacy.
- When they matter: certs help most for juniors/career-changers passing screens and for consultancies/MSPs that require them. For senior roles, demonstrated scope and the portfolio outweigh certs (but SAA + CKA still help). Don't collect certs in place of building — a 12-month plan of SAA → Terraform Associate → CKA alongside the portfolio beats a wall of badges with no projects.

---

# 11. Whiteboard Explanation

**The 2026 screening funnel (draw top-to-bottom):**

```
        200+ applicants
               |
       [ ATS / parser ]  -- drops unparseable resumes (tables, columns, images)
               |   keyword + field extraction, rank
               v
     [ LLM screener / summarizer ]  -- ranks vs JD; penalizes keyword walls
               |
               v
        [ Recruiter skim ]  -- 10-30s: top third, titles, numbers
               |
               v
     [ Hiring manager review ]  -- reads bullets + portfolio/GitHub
               |
               v
          INTERVIEW LOOP  -> (Class 2)
```

What each stage means and what wins it:
- Parser: clean single-column structure + standard headings.
- LLM: honest, JD-relevant prose; no stuffing.
- Recruiter: impact in the top third; numbers jump out.
- Hiring manager: X-Y-Z bullets + a real portfolio with diagrams/ADRs.

Enterprise version: at a large company these stages map to Workday/Greenhouse (ATS) → an internal LLM-assisted ranker → a sourcer/recruiter → the hiring manager and panel. Same funnel, more automation.

**Resume layout sketch (single column, ATS-safe):**

```
NAME — Target Title
City / Remote · email · phone · github.com/you · linkedin.com/in/you
-------------------------------------------------------------------
SUMMARY: 2-3 lines, role + scope + signature strengths
-------------------------------------------------------------------
SKILLS: Cloud | Containers/Orchestration | IaC | CI/CD | Observability | Languages
-------------------------------------------------------------------
EXPERIENCE / PROJECTS (reverse chronological, X-Y-Z bullets, numbers)
-------------------------------------------------------------------
CERTIFICATIONS | EDUCATION
```

---

# 12. Instructor Demo Script

**Demo title:** From lab to bullet to portfolio — building one accomplishment end to end.

**Demo objective:** Show how a single capstone feature becomes (a) a strong resume bullet, (b) a LinkedIn Featured item, and (c) a GitHub README + ADR.

**Required setup:** A sample capstone repo open in the browser/IDE; a blank copy of the resume template; a sample LinkedIn profile in edit mode.

**Steps:**

1. **Pick the accomplishment.** "We added a GitHub Actions pipeline that builds a multi-stage Docker image, scans it, pushes to ECR, and deploys to EKS." Explain: choose the feature with the clearest measurable outcome.
2. **Build the bullet live.** Start weak ("Made a CI/CD pipeline"), then add X-Y-Z and a number. Expected output: the strong bullet from 10.4. Explain each added element (outcome, metric, how).
3. **Drop it into the template.** Paste under Projects → Capstone. Show the single-column formatting staying intact.
4. **Write the README section.** In the repo, add a "What this does / Architecture / Decisions / Run it" structure. Add a Mermaid diagram:
   ```mermaid
   flowchart LR
     dev[Commit] --> gha[GitHub Actions]
     gha --> build[Build + Test] --> img[Multi-stage Docker] --> scan[Image scan]
     scan --> ecr[(ECR)] --> deploy[Deploy to EKS] --> svc[Service]
   ```
   Expected output: a rendered diagram on GitHub.
5. **Write an ADR.** Create `docs/adr/0001-trunk-based-delivery.md` with Context / Decision / Options / Consequences. Explain why this is the senior differentiator.
6. **Feature it on LinkedIn.** Add the repo to Featured; update the headline to include the stack.

**Expected outputs:** one strong bullet, a README with a rendered diagram, one ADR, an updated LinkedIn Featured/headline.

**Common demo failure points & recovery:**
- Mermaid not rendering → check the code-fence language tag is `mermaid`; GitHub renders it natively.
- Two-column template "looks nicer" temptation → show the parsed-garbage example to re-anchor.
- Over-claiming a metric → reframe as a project metric ("in the capstone").

**Cleanup:** none (documents only). If a student spun up cloud resources to capture a metric, tear them down (see capstone cleanup, Weeks 23–24) to avoid cost.

---

# 13. Student Lab Manual

**Lab title:** Build your resume, portfolio README, and LinkedIn profile.

**Lab objective:** Produce a complete, ATS-safe resume draft; a portfolio README with a diagram and one ADR; and an optimized LinkedIn headline + About.

**Estimated time:** 60 minutes in class + homework to finish.

**Student prerequisites:** capstone repo pushed; a metrics log (or use the reconstruction worksheet below).

**Architecture / workflow overview:** lab artifacts → screening funnel. You are producing the three artifacts each funnel stage reads.

### ATS-friendly resume template (copy into a plain single-column doc)

```text
JANE DOE
DevOps / Cloud Engineer | Site Reliability Engineer
Austin, TX (Open to Remote) · jane@email.com · (555) 555-0100
github.com/janedoe · linkedin.com/in/janedoe

SUMMARY
Cloud-focused engineer building reliable, cost-aware delivery platforms on AWS.
Hands-on with Kubernetes, Terraform/OpenTofu, and CI/CD; evidence-first
troubleshooter. [If senior: + scope/leadership line.]

SKILLS
Cloud: AWS (EC2, S3, RDS, VPC, IAM, EKS, ECR, CloudWatch, Organizations)
Containers/Orchestration: Docker, Kubernetes, Helm
IaC: Terraform, OpenTofu, CloudFormation
CI/CD: GitHub Actions, GitLab CI, Argo CD
Observability: Prometheus, Grafana, OpenTelemetry, CloudWatch
Security: IAM, KMS, Secrets Manager, image scanning, OIDC keyless CI
Languages/Tools: Bash, Python, Git, Linux

PROJECTS
Capstone: Cloud-Native Delivery Platform (github.com/janedoe/capstone)
- <X-Y-Z bullet 1, with a number>
- <X-Y-Z bullet 2, with a number>
- <X-Y-Z bullet 3, with a number>

EXPERIENCE   [if applicable; else expand Projects]
Company — Title (dates)
- <X-Y-Z bullet>

CERTIFICATIONS
AWS Solutions Architect Associate (in progress) · Terraform Associate

EDUCATION
B.S. <field>, <school>, <year>
```

### Capstone → bullet mapping worksheet

| Course asset | Metric to capture | Draft bullet (X-Y-Z) |
|---|---|---|
| W9/W23 CI/CD pipeline | deploy lead time, deploy freq | Cut lead time from __ to __ by building a GHA pipeline … |
| W10 Docker | image size, build time | Reduced image size __% via multi-stage + distroless non-root … |
| W11–12 K8s | failed-pod rate, MTTR | Cut CrashLoopBackOff incidents to zero by … (evidence-first) |
| W14–15 Terraform/OpenTofu | env setup time | Provisioned VPC/EKS/RDS as code with remote state + plan review … |
| W16/W21 Observability/SRE | MTTR, alert noise | Defined SLOs + dashboards cutting MTTR __% / alert noise __% |
| W18 Cost | % cost saved | Reduced monthly cloud cost __% via rightsizing + Budgets |
| W19 DevSecOps | vulns blocked | Added image scanning + OIDC keyless CI, blocking __ critical CVEs |

### Steps

1. Copy the template into a plain single-column document.
2. Fill the metrics worksheet from your metrics log (or reconstruct conservatively).
3. Write 8–10 X-Y-Z bullets; ensure every bullet has a number.
4. Self-assess your level (junior/mid/senior) using the Section 10.5 checklist; rewrite your top 3 bullets to match.
5. Tailor the Skills section to a real target JD: paste the JD, highlight its nouns, make sure your resume uses the same terms.
6. In your capstone repo, add/upgrade the README (Problem / Architecture + diagram / Decisions / Run it / Cleanup) and one ADR in `docs/adr/`.
7. Update LinkedIn: headline (role + stack + value), About (value-first), Skills, and add the capstone to Featured.

### Commands students should run (portfolio)

```bash
# Verify no secrets are committed before sharing the repo
git switch -c portfolio-polish
git log --oneline | head
# Add a diagram + ADR
mkdir -p docs/adr
# (create README with mermaid block + docs/adr/0001-*.md in your editor)
git add README.md docs/adr/0001-trunk-based-delivery.md
git commit -m "docs: add architecture diagram and first ADR"
git push -u origin portfolio-polish
```

### Expected outputs
- A one-page resume with 8–10 numbered bullets.
- A capstone README rendering a diagram on GitHub + one ADR.
- An updated LinkedIn headline, About, Skills, Featured.

### Validation checklist
- [ ] Resume is single column, standard headings, no tables/text boxes/images.
- [ ] Saved as a text-based PDF and a .docx.
- [ ] Every experience/project bullet has a number.
- [ ] Skills mirror a real JD's terms.
- [ ] Level claimed matches scope described.
- [ ] README has a rendered diagram + Decisions section.
- [ ] At least one ADR exists.
- [ ] No secrets in repo history.
- [ ] LinkedIn headline includes role + stack + value; Featured set.

### Troubleshooting tips
- ATS test: copy-paste your PDF into a plain text editor. If the order scrambles or text is missing, your formatting is unsafe — switch to single column.
- Mermaid not rendering on GitHub → use a ```mermaid fenced block.
- "No metrics" → estimate from lab observations and label as a project metric.

### Cleanup steps
- None for documents. Tear down any cloud resources spun up to capture metrics (see capstone cleanup, Weeks 23–24) to avoid cost and reduce attack surface.

### Reflection questions
1. Which single bullet best demonstrates *senior* scope, and why?
2. What would a hiring manager learn about you in the first 10 seconds?
3. Which JD term is missing from your Skills section?

### Optional challenge task
Write a second resume variant positioned one level up (e.g., mid → senior), and a 400-word technical blog post (a tradeoff or an incident writeup) linked from LinkedIn Featured.

---

# 14. Troubleshooting Activity

**Incident title:** "My applications vanish into the void" — strong engineer, zero callbacks.

**Business impact (to the candidate):** 60 applications, no responses; momentum and morale dropping; offer timeline slipping.

**Symptoms:**
- Resume is a polished two-column template with a sidebar and icons.
- Bullets are task lists ("Responsible for…") with no numbers.
- LinkedIn headline says only "DevOps Engineer"; "Open to Work" is off.
- Applying to senior reqs with junior-scoped bullets (and vice versa for some).

**Starting evidence:**
- Pasting the PDF into a text editor produces interleaved, out-of-order text (the parser sees garbage).
- A JD says "EKS, Terraform, Argo CD"; the resume says "Kubernetes" and omits Terraform/Argo entirely.
- No portfolio link; GitHub has unnamed repos and no READMEs.

**Student investigation steps (symptom → evidence → root-cause → fix → validate):**
1. Reproduce the parser view (paste-to-text). Evidence: scrambled order → root cause: two-column layout.
2. Diff resume terms vs JD terms. Evidence: missing keywords → root cause: no JD tailoring.
3. Inspect bullets for numbers. Evidence: none → root cause: no quantified impact.
4. Check leveling. Evidence: scope/level mismatch → root cause: wrong positioning.
5. Check discoverability. Evidence: weak headline, OTW off → root cause: invisible to recruiters.

**Expected root cause:** Unparseable formatting + un-tailored, un-quantified, mis-leveled content + invisible profile. The candidate is being filtered before any human reads them.

**Correct resolution:** Single-column rebuild from the template; tailor Skills to the JD; add numbers to every bullet; fix leveling; rewrite the LinkedIn headline and enable Open to Work; add a portfolio link with a real README.

**Common wrong paths:**
- "Make it prettier" (worsens parsing).
- Keyword-stuff the JD terms (LLM screener penalizes; interview catches it).
- Apply to *more* reqs without fixing the artifact (more noise, same filter).

**Instructor hints:** Run the paste-to-text demo first — it's the "aha." Then the JD diff.

**Preventive action:** Maintain a master resume + per-application tailoring; keep the metrics log current; quarterly LinkedIn refresh.

---

# 15. Scenario-Based Discussion Questions

1. A JD asks for 5 years and you have 2 years + this course. Apply anyway, or not? *(Theme: 60% match is enough; leveling honesty; transferable scope. Follow-up: how do you frame the capstone as production-credible without lying?)*
2. Is it ethical/effective to put lab metrics on a resume? *(Theme: yes, labeled as project metrics; never fabricate prod numbers. Follow-up: what happens in the interview if you inflate?)*
3. Two-column designer resume vs plain single-column — for whom is each right? *(Theme: design roles vs DevOps; ATS reality. Follow-up: how do you test parseability?)*
4. You're targeting both DevOps and SRE roles. One resume or two? *(Theme: tailoring; SRE leans reliability/SLO/on-call, DevOps leans delivery. Follow-up: which bullets move between them?)*
5. Certs vs portfolio for a career-changer with no industry job. *(Theme: both, certs first to pass screens. Follow-up: which cert first and why?)*
6. How much should a senior candidate's resume emphasize people vs tech? *(Theme: scope + technical decisions + mentoring; balance. Follow-up: a bullet that shows both.)*
7. Recruiter says "you look junior." How do you respond on the spot? *(Theme: reframe scope/ownership; ask what signal they're missing. Follow-up: how to fix the resume after.)*

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

1. (MC) Which resume format is safest for ATS parsing?
   a) Two-column with sidebar  b) **Single-column, standard headings**  c) Infographic  d) Functional/skills-based
   **B.** Single column + standard headings parse reliably; the others scramble or signal hiding gaps.

2. (T/F) In 2026, stuffing invisible keywords reliably beats LLM screeners. **False.** LLM screeners read context and penalize low-signal keyword walls.

3. (MC) X-Y-Z stands for:
   a) eXperience-Years-Zone  b) **accomplished X measured by Y by doing Z**  c) a date format  d) a skills matrix
   **B.**

4. (Short) Name three DORA metrics usable from labs. **Deployment frequency, lead time for changes, change failure rate, MTTR (any three).**

5. (MC) The strongest *senior* signal in a bullet is:
   a) listing more tools  b) **scope + ownership + a technical decision/tradeoff**  c) a longer summary  d) more certifications
   **B.**

6. (T/F) You should list every AWS service you've ever touched. **False.** List only services you can defend in an interview.

7. (Short, troubleshooting) Your PDF pastes into a text editor with scrambled order. Root cause and fix? **Multi-column/table layout; rebuild single-column.**

8. (Short, troubleshooting) 60 apps, 0 callbacks; bullets have no numbers and headline is "DevOps Engineer." First two fixes? **Add quantified impact to bullets; rewrite headline (role+stack+value) and enable Open to Work; tailor to JDs.**

9. (MC, AWS) A JD says "EKS." Your resume should say:
   a) "Kubernetes" only  b) **"EKS (managed Kubernetes)"**  c) "containers"  d) nothing
   **B.** Mirror the JD's exact term while keeping it accurate.

10. (MC, AWS) Best *first* cert for a Cloud/DevOps screen-pass:
    a) AWS Specialty  b) **AWS Solutions Architect Associate**  c) CKS  d) none
    **B.** Broadest keyword value and literacy signal.

11. (T/F) A senior portfolio benefits from ADRs and tradeoff writeups. **True.** They're a top senior differentiator.

12. (Short) Why does over-claiming your level backfire? **It mismatches the screen and collapses in the interview; calibrate to your actual scope.**

---

# 17. Homework Assignment

**Title:** Job-ready artifact pack.

**Scenario:** You are applying to three real DevOps/Cloud/SRE roles this week.

**Student tasks:**
1. Finalize the one-page resume (single column, 8–10 numbered bullets, leveled correctly).
2. Pick three real JDs; produce a tailored Skills/summary variant for each.
3. Upgrade the capstone README (Problem / Architecture + diagram / Decisions / Run / Cleanup) and add at least one ADR.
4. Update LinkedIn (headline, About, Skills, Featured, Open to Work).
5. Draft a 12-month certification plan.
6. (Optional) Publish a 300–500 word technical writeup and link it from Featured.

**Expected deliverables:** resume PDF + .docx; three tailored variants; updated repo URL; LinkedIn URL; cert plan.

**Submission format:** a single markdown file with links + the resume attached.

**Estimated completion time:** 3–4 hours.

**Grading criteria:** parseability (single column, passes paste-to-text); every bullet quantified; correct leveling; JD tailoring present; README has diagram + Decisions + at least one ADR; LinkedIn optimized.

**Optional advanced challenge:** produce a second resume positioned one level higher and defend the leveling in two sentences.

---

# 18. Common Student Mistakes

- **Two-column "pretty" templates.** Why: design instinct. Fix: single column; run the paste-to-text test.
- **Task bullets, no numbers.** Why: undersell + "I don't have metrics." Fix: use the worksheet; estimate and label project metrics.
- **Tool soup in Skills.** Why: fear of omission. Fix: group + tailor to the JD; only list what you can defend.
- **Leveling mismatch.** Why: ambition or timidity. Fix: match scope to claimed level.
- **Generic LinkedIn headline + Open to Work off.** Why: defaults. Fix: role+stack+value; enable OTW.
- **Empty/secret-leaking GitHub.** Why: never cleaned up. Fix: pinned repos, READMEs, scan history for secrets.
- **No ADRs/tradeoffs.** Why: didn't know it mattered. Fix: add ADRs — the senior differentiator.

---

# 19. Real-World Enterprise Scenario

A mid-size SaaS company opens a "Senior DevOps Engineer" req. The hiring manager uses Greenhouse with an LLM-assisted ranker. 180 people apply in 48 hours. The recruiter and manager will personally read maybe 15.

A course graduate applies. Their resume is single-column, mirrors the JD ("EKS, Terraform, Argo CD, SLOs"), and leads with a quantified capstone bullet ("cut deploy lead time ~80%, defined SLOs cutting MTTR ~40%"). Their GitHub (linked) has a capstone with an architecture diagram and two ADRs. The LLM ranker surfaces them as high-relevance; the recruiter sees numbers in the top third; the manager opens the repo, reads the ADR on multi-region tradeoffs, and thinks "this person reasons like a senior."

A DevOps/Cloud/SRE engineer here treats their resume and portfolio as production artifacts: versioned, tailored per req, honest, and evidence-backed — because the constraint (180 applicants, 15 reads) means *legibility is the bottleneck*, not skill.

---

# 20. Instructor Tips

- **Teaching tip:** the paste-to-text demo converts skeptics faster than any lecture — lead with it.
- **Pacing:** the lab is the heart of the class; protect the full 45+15 minutes. Lecture is setup, not the event.
- **Lab support:** the two interventions that fix 80% of resumes are "add a number" and "raise/lower the level to match scope."
- **Struggling students** (no metrics): walk them through reconstructing one number from a lab they remember.
- **Advanced students:** push the senior layer — ADRs, a blog post, a second leveled-up resume, and a tradeoff defense.

---

# 21. Student Outcome Checklist

Students should be able to **explain**:
- The 2026 screening funnel and what each stage rewards.
- Why single-column/ATS-safe formatting matters.
- The difference between junior, mid, and senior positioning.

Students should be able to **build/configure**:
- An ATS-friendly one-page resume with quantified X-Y-Z bullets.
- An optimized LinkedIn profile (headline, About, Skills, Featured).
- A portfolio README with an architecture diagram and at least one ADR.

Students should be able to **troubleshoot**:
- An unparseable resume (paste-to-text → single-column rebuild).
- A "no callbacks" pipeline (quantify, tailor, re-level, make discoverable).

---

# 22. Class Completion Checklist

**Instructor before ending class:**
- [ ] Every student has a single-column resume draft started from the template.
- [ ] Every student has at least 3 quantified bullets.
- [ ] Peer review (resume rubric) completed in pairs.
- [ ] Homework + the certification-plan task assigned.

**Student before leaving:**
- [ ] Resume draft saved (PDF + .docx) and passes paste-to-text.
- [ ] LinkedIn headline updated; Open to Work enabled.
- [ ] Capstone README + one ADR in progress.

**Verify before Class 2:**
- [ ] Each student has a portfolio link and a metrics log — Class 2 turns these into STAR stories and a design-defense.

### Resume rubric (peer review)
| Criterion | Pass |
|---|---|
| Single column, standard headings, no tables/images | ☐ |
| One page, reverse chronological | ☐ |
| Every bullet quantified (X-Y-Z) | ☐ |
| Skills mirror a target JD | ☐ |
| Level matches scope | ☐ |
| Portfolio link present; repo has README + diagram + ADR | ☐ |
| LinkedIn headline = role + stack + value | ☐ |

---

## Class Artifacts & Validation

This is a **non-technical (career-prep) class** — per the course's artifact standard §4 it is exempt from runnable code but still ships concrete, reusable documents as real files. The validation gate is `./validate.sh`, which enforces presence + structure + word-count *substance* checks (a stub cannot pass). It requires no external tools and runs offline; there is no live cloud op to capture (cost: $0). The rows below are the artifacts **this class (resume / LinkedIn / portfolio)** uses.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/career-prep/solution/resume-rubric.md | markdown | Scored ATS + LLM-screener + human-reader resume rubric | `cd labs/career-prep && ./validate.sh` | PASS — `./validate.sh` exit 0 (32 passed, 0 failed) |
| 2 | labs/career-prep/solution/impact-bullets.md | markdown | X-Y-Z impact-bullet playbook with 10 before/after rewrites | `cd labs/career-prep && ./validate.sh` | PASS — substance + `X-Y-Z` / ≥10-examples markers asserted |
| 3 | labs/career-prep/solution/portfolio-checklist.md | markdown | Maps this course's `labs/*` + `labs/capstone` to hiring competencies | `cd labs/career-prep && ./validate.sh` | PASS — capstone + labs cross-reference markers asserted |
| 4 | labs/career-prep/starter/resume-template.md | markdown | ATS-safe single-column starter template with `TODO(student)` gaps | `cd labs/career-prep && ./validate.sh` | PASS — present, ≥200 words, TODO gaps intact |
| 5 | labs/career-prep/README.md | markdown | Lab guide: prerequisites, tasks, validation, cleanup, security/cost, answer key | `cd labs/career-prep && ./validate.sh` | PASS — Status banner = Validated |
| 6 | labs/career-prep/validate.sh | shell | Presence + structure + substance gate for all module artifacts | `bash -n labs/career-prep/validate.sh && cd labs/career-prep && ./validate.sh` | PASS — `bash -n` clean; exit 0 |

> No `LIVE-*EVIDENCE*.txt` / `LIVE-AWS-VALIDATION.txt` exists for this module and none is applicable: the lab provisions no cloud or local resources and performs no operated workload — the only evidence is the static validator passing.

## Definition of Done

Ticked honestly for this class. Boxes that do not apply to a non-code class are marked **N/A** with the reason.

- [ ] ~~Every technology taught ships at least one runnable file on disk (not just a fence).~~ **N/A** — non-technical class; ships documents/templates/rubrics as real files instead (standard §4 exemption).
- [x] Each artifact passes (or documents) its **validation gate** — `./validate.sh` exits 0 (32 passed, 0 failed); output captured above.
- [x] Lab has **starter** (`starter/resume-template.md`, intentionally incomplete with `TODO` gaps) and **solution** (`solution/resume-rubric.md`, `impact-bullets.md`, `portfolio-checklist.md`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** — N/A and stated: the module creates no processes, containers, or cloud resources; README documents "Nothing to clean up" (idempotent by construction).
- [x] **Instructor answer key** exists — `solution/` reference artifacts + README "Instructor answer key" section; the take-home has `take-home-solution-outline.md` as its grading key.
- [x] **Troubleshooting exercise** uses a real, reproducible broken state — truncating any `solution/` file below its word floor makes `./validate.sh` fail honestly (documented in README); the "broken state" is a stub artifact.
- [x] **Expected outputs** are shown — README shows the `== 32 passed, 0 failed ==` / `exit=0` tail and the per-task "Done when" criteria.
- [x] **Cost & security warnings** present — README "Security considerations" (no PII/secrets in portfolio repos; secret-scan before linking) and "Cost considerations" ($0).
- [x] **Cross-references** to the module repo and prior weeks are correct — links to `labs/career-prep/` and capstone Weeks 23–24; "How This Class Connects" cites Weeks 6/9/10/11–12/13/14–15/16/17/18/19/20/21/22 (verified).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (`ls`-verified).
