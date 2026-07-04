# Week 1 · Class 1 — Understanding DevOps, Cloud & SRE Roles

**Student Handout** · Enterprise DevOps, Cloud Engineering & SRE Program · 3 hours · AWS-first

Welcome! Today you'll get a clear picture of five real tech careers — DevOps, Cloud, SRE, Platform, and Production Support — and how they team up to move software safely to production. You'll also check the five main tools on your own laptop, so you leave knowing exactly what's ready and what needs a fix before we start building.

> **This is a soft start.** You are *not* expected to master any tools today. We're building the map first; the real hands-on work begins in Week 2 (Linux). Errors are normal — troubleshooting is one of the actual job skills.

---

## Today's Agenda

- **Welcome & why these roles exist** — the problems (manual deploys, silos, outages) that DevOps, Cloud, and SRE were invented to solve.
- **The DevOps Engineer & Cloud Engineer roles** — who automates delivery, and who builds the cloud foundation apps run on.
- **☕ Short break** — jot down one question about each role.
- **The SRE, Platform, and Production Support roles** — reliability, reusable internal tooling, and keeping live systems healthy.
- **How it all fits together** — one enterprise example, how code reaches production, DORA metrics, and what "senior" looks like.
- **Your lab + wrap-up** — check your five tools, record the results, and a quick knowledge check.

---

## Key Terms

Keep this glossary handy — these words come up all course long.

| Term | What it means (plain version) |
|---|---|
| **DevOps** | A way of improving how software is built, tested, released, and operated. |
| **Cloud Engineering** | Designing, building, and managing cloud infrastructure. |
| **SRE** | Site Reliability Engineering — focused on reliability and production health. |
| **Platform Engineering** | Building reusable internal tools and templates for developers. |
| **Production** | The live environment used by real users or customers. |
| **CI/CD** | Continuous Integration and Continuous Delivery/Deployment — automating build, test, and release. |
| **Infrastructure** | Servers, networks, databases, storage, security, and cloud resources. |
| **Automation** | Using scripts, pipelines, or tools to reduce manual work. |
| **Observability** | Understanding system health through logs, metrics, and traces. |
| **Incident** | An unplanned service issue affecting users or business operations. |
| **Runbook** | A step-by-step guide for handling a task or incident. |
| **Postmortem** | A review after an incident to learn and improve — focused on prevention, not blame. |

---

## The Five Roles in One Line Each

Each role has a ladder. Junior engineers execute tasks; senior engineers own outcomes and set standards. Here's the one-liner plus a "what senior looks like" cue for each.

| Role | In one line | What *senior* looks like |
|---|---|---|
| **DevOps Engineer** | Automates how code gets built, tested, and delivered. | Designs the org-wide CI/CD and golden-path standards, defines release policy, reduces lead time across many teams. |
| **Cloud Engineer** | Builds and secures the cloud foundation apps run on. | Owns multi-account architecture, network and IAM design, and cost guardrails; reviews others' infrastructure-as-code. |
| **SRE** | Keeps production reliable, observable, and recoverable. | Defines SLOs and error budgets, leads incident command, runs blameless postmortems, automates away whole classes of toil. |
| **Platform Engineer** | Makes the right way the easy way with reusable templates. | Builds the self-service platform and golden paths other teams build on. |
| **Production Support** | Keeps live systems running; triages and escalates issues. | Builds the runbooks and known-issue knowledge base and feeds recurring root causes back to engineering. |

> A phrase worth remembering: *"Junior engineers complete tickets. Senior engineers remove the reason the ticket existed."*

---

## How Code Reaches Production

There are two common delivery styles. Right now you only need to **recognize the names** — we teach push-based CI/CD first (from Week 9), and revisit GitOps later with Kubernetes.

**Push-based CI/CD.** A developer commits code to Git, a pipeline builds and tests it, then a deployment step *pushes* the change out into the environment. The pipeline reaches into the environment to make the change happen. This is the classic Jenkins / GitHub Actions style.

**Pull-based GitOps.** The desired state of the system lives in a Git repository as the single source of truth. An agent running *inside* the platform (for example Argo CD or Flux) continuously pulls that repo and reconciles the live environment to match it. Here "deploy" simply means "merge a change" — the environment reaches out and keeps itself in sync.

> The mental model for both: **declare the desired state in Git, and let automation make reality match it.**

---

## DORA Metrics

The DORA (DevOps Research and Assessment) metrics are the industry-standard way to talk about delivery health. Hiring managers expect you to recognize these four.

| Metric | Question it answers | "Good" direction |
|---|---|---|
| **Deployment frequency** | How often does the team ship to production? | Higher (many times per day) |
| **Lead time for changes** | How long from code committed to running in production? | Lower (hours, not weeks) |
| **Change failure rate** | What % of deployments cause a failure needing remediation? | Lower |
| **Mean time to recovery (MTTR)** | How quickly do we recover when something breaks? | Lower |

The first two measure **throughput** (speed); the last two measure **stability**. Strong teams improve both at once.

> *"Speed and stability are not opposites. The best teams are fast AND reliable — and DORA gives us the numbers to prove it."*

---

## Today's Lab — Check Your Five Tools

**Goal:** find out which course tools are installed on your machine. Open your terminal (Windows: PowerShell / Windows Terminal / Git Bash / WSL · macOS: Terminal · Linux: Terminal) and run each command below, then fill in the record block.

**1. Git**
```bash
git --version
```
```text
Installed (Y/N): ___    Version: ___________    Issue: ______________
```

**2. AWS CLI**
```bash
aws --version
```
```text
Installed (Y/N): ___    Version: ___________    Issue: ______________
```

**3. Docker**
```bash
docker --version
```
```text
Installed (Y/N): ___    Version: ___________    Issue: ______________
```

**4. Terraform**
```bash
terraform version
```
```text
Installed (Y/N): ___    Version: ___________    Issue: ______________
```

**5. VS Code**
```bash
code --version
```
```text
Installed (Y/N): ___    Version: ___________    Issue: ______________
```

**Then create your report.** Make a file named `setup-validation.md` and record your name, OS, the five tool versions, any issues found, and any questions for the instructor. (`touch setup-validation.md` on macOS/Linux, or `New-Item setup-validation.md` in PowerShell.)

**Handy reference — versions we're targeting** (yours may differ slightly; that's fine):

| Tool | Minimum | Example seen on the instructor machine |
|---|---|---|
| Git | ≥ 2.30 | 2.34.1 |
| AWS CLI | ≥ 2 | 2.32.11 (Python 3.13.9) |
| Docker | ≥ 24 | 29.1.2 |
| Terraform | ≥ 1.6 | 1.14.1 |
| VS Code | — | 1.106.3 |

> **If a command fails, don't panic — document it.** `command not found` usually means the tool isn't installed or isn't on your PATH, or the terminal needs a restart. If `docker info` fails, Docker may be installed but not running. If `code` fails, VS Code may be installed but the `code` command isn't on PATH. Note the exact error in your issue line and we'll sort it out. (Tools like *helm* and *kind* are optional and **not needed for Week 1**.)

---

## Homework — Role Reflection

Write a short reflection comparing the roles you learned about today.

- **Filename:** `week-01-role-reflection.md`
- **Length:** 500–800 words

Answer all seven questions:

1. What does a DevOps Engineer do?
2. What does a Cloud Engineer do?
3. What does an SRE do?
4. What is Platform Engineering?
5. Which role sounds most interesting to you right now and why?
6. What skills do all of these roles share?
7. Why is troubleshooting important in all three paths?

**Grading (out of 100):**

| Criteria | Points |
|---|---:|
| Explains DevOps accurately | 20 |
| Explains Cloud Engineering accurately | 20 |
| Explains SRE accurately | 20 |
| Identifies shared skills | 15 |
| Includes personal reflection | 10 |
| Uses clear writing and organization | 10 |
| Mentions enterprise or production context | 5 |
| **Total** | **100** |

---

## Bring to Class 2

- ☐ Your working tools — **or** a written list of which ones failed and the exact error messages.
- ☐ Your completed `setup-validation.md` file.
- ☐ Any questions you have about setup, the roles, or the course.

*See you next class — we'll get everyone's environment green and start on the terminal.*
