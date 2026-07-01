# Week 25, Class 2 Package
> **▶ Runnable lab for this class:** [`labs/career-prep/`](../../labs/career-prep/)
>
> The **on-disk, validated** version of this class's work — clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check against `solution/`, then run `./validate.sh`.

## Technical and Behavioral Interview Preparation

**Week:** 25
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Technical and Behavioral Interview Preparation**

## Class Purpose

This class prepares students for the full DevOps/Cloud/SRE interview loop and elevates it to a senior bar: a technical screen, a system/architecture design round, a live troubleshooting/debugging round, a behavioral round, a take-home assignment, and salary negotiation — closing with a runnable mock-interview protocol and feedback rubric. The artifacts from Class 1 (resume + portfolio) become the source material: every bullet is now a STAR story and every repo is a design-defense.

## Class Purpose — the senior elevation

A junior loop tests "can you do the task." A senior loop tests "can you own the system, reason about failure domains and tradeoffs, drive a decision, and lead under pressure." This class teaches both layers and makes the senior layer explicit in every section.

## How This Class Builds From Class 1

Class 1 produced legible artifacts that *get* the interview. Class 2 *wins* it. The resume bullets, capstone, and portfolio ADRs from Class 1 are the raw material for STAR stories, the system-design defense, and the troubleshooting narrative here. Mis-leveling fixed in Class 1's resume must hold up in Class 2's loop.

## What Students Will Build, Analyze, or Practice

- A personal technical-screen answer bank (Linux/networking/containers/K8s/IaC/CI-CD).
- A worked system-design walkthrough at junior and senior altitude.
- A timed live-troubleshooting reasoning script.
- A STAR story bank including senior dimensions (incident command, mentoring, conflict, technical decisions).
- A take-home plan and a salary-negotiation script.
- A recorded/peer-reviewed mock interview with a completed feedback rubric.

---

# 2. Quick Review of Class 1

**Review points (5–8):**
- The 2026 screening funnel: parser → LLM screener → recruiter → hiring manager → loop.
- ATS-safe single-column formatting; paste-to-text test.
- X-Y-Z quantified bullets and DORA metrics.
- Junior/mid/senior positioning by scope, ownership, decisions, people.
- LinkedIn optimization and a senior-signal GitHub portfolio (READMEs, diagrams, ADRs).
- Certifications strategy (SAA → Terraform Associate → CKA).

**Quick recall questions:**
1. What does each bullet need to be "strong"? *(An outcome + a metric + how.)*
2. Name two senior signals a bullet can carry. *(Scope, ownership, technical decision, mentoring.)*
3. Why do ADRs matter in a portfolio? *(Top senior differentiator: shows tradeoff reasoning.)*

**Common gaps from Class 1:** bullets still vague or un-numbered; level claimed not yet defensible; portfolio repo not interview-ready.

**Bridge into Class 2:** "Your resume earned the interview. Now we make every claim survive a senior who will probe it. The bullet you wrote yesterday is today's STAR story and today's design-defense."

---

# 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Answer** core technical-screen questions (Linux, networking, containers, K8s, IaC, CI/CD) with correct, concise model answers.
2. **Walk through** a system-design prompt out loud, scoping requirements, sketching architecture, and reasoning about HA, scale, SLOs, and cost.
3. **Debug** a live broken scenario (pipeline / pod / networking) using the symptom→evidence→root-cause→fix→validate method while narrating.
4. **Construct** STAR stories spanning technical and senior behavioral dimensions.
5. **Plan** a take-home assignment: scope, structure, README, and submission.
6. **Negotiate** an offer using leveling, comp bands, and a counter-offer script.
7. **Run** a mock interview as both candidate and interviewer and give rubric-based feedback.

---

# 4. Prerequisites Students Should Already Know

- **From Class 1:** finished resume, portfolio link, metrics log, claimed level.
- **Foundation + advanced content (Weeks 1–22):** Linux (W2), networking/VPC (W5), security/IAM (W6), CI/CD (W9), Docker (W10), Kubernetes + troubleshooting (W11–12), Terraform/OpenTofu (W14–15), observability (W16), SRE/SLOs (W21), performance/capacity (W22).
- **Capstone (Weeks 23–24)** as the primary STAR + design-defense source.
- **Tools:** a working laptop with kubectl/Docker/terraform for the live drill; a way to record the mock (phone/Zoom).

---

# 5. Key Terms and Definitions

- **Technical screen** — a 30–60 min call (often the first technical filter) testing breadth with rapid Q&A and sometimes a small hands-on task.
- **System design round** — open-ended "design X" prompt; evaluated on requirements scoping, architecture, tradeoffs, failure handling, and communication — not a single right answer.
- **Altitude** — the level you operate at in a design discussion. Junior altitude lists components; senior altitude reasons about failure domains, SLOs, scale math, and cost tradeoffs.
- **Live troubleshooting / debugging round** — a broken environment you must diagnose while narrating your reasoning.
- **STAR** — Situation, Task, Action, Result: the structure for behavioral answers. Senior STARs add decision, scope, and people dimensions.
- **Incident command** — leading an incident response: roles, comms, mitigation, postmortem.
- **Take-home** — an offline assignment (build a pipeline, fix a Terraform repo, containerize an app) evaluated on correctness, clarity, and judgment.
- **Leveling** — a company's job ladder (e.g., L3/L4/L5; SDE I/II/Senior). Comp bands attach to levels; negotiation often means negotiating the *level*.
- **Total comp (TC)** — base + bonus + equity (RSUs/options) + sign-on. The number that matters, not base alone.
- **Blameless postmortem** — incident review focused on systems/process, not individual fault.

---

# 6. Tools Used

- **Whiteboard / Excalidraw / draw.io** — for the system-design round.
- **A pre-broken repo/cluster** (provided) — for the live troubleshooting drill (a failing pod or a broken pipeline).
- **kubectl / docker / terraform / git** — to run the drill.
- **Recording tool (Zoom/phone)** — to capture the mock for self-review.
- **Mock-interview kit (Section 14/22)** — interviewer script + candidate rubric + debrief template.
- **levels.fyi / Glassdoor (reference)** — comp-band research for negotiation.

---

# 7. AWS Services Used

Interview content draws on services from the course; expect to defend any you listed (Class 1):
- **VPC, subnets, route tables, security groups, NAT** (W5) — networking design + troubleshooting prompts.
- **IAM, KMS, Secrets Manager** (W6) — security questions; OIDC keyless CI.
- **EC2, autoscaling, ELB/ALB, RDS, S3** (W7, W22) — HA/scale design.
- **EKS, ECR** (W10–13) — container/K8s design and debugging.
- **CloudWatch** (W16, W21) — observability/SLO/alerting design.
- **Cost Explorer / Budgets** (W18) — cost-tradeoff reasoning in design.

---

# 8. Azure and GCP Comparison Notes

- Map terms on demand: EKS→AKS/GKE, IAM→Entra ID/Cloud IAM, CloudWatch→Azure Monitor/Cloud Monitoring, S3→Blob/GCS. Interviewers at Azure/GCP shops appreciate "the AWS pattern is X; on Azure that's Y."
- In system design, principles are cloud-agnostic (failure domains, multi-AZ/region, load balancing, queues, SLOs). Lead with principles, then name the specific service.
- Don't claim hands-on with a cloud you haven't used; say "concepts transfer; I'd ramp on the specifics."

---

# 9. Time-Boxed Instructor Agenda (3 hours)

| Time | Segment | Activity |
|------|---------|----------|
| 0:00–0:10 | Review Class 1 + bridge | Recall Qs; "bullet → STAR → design-defense." |
| 0:10–0:20 | The full interview loop overview | Section 10.1 map; what each round tests. |
| 0:20–0:45 | Technical screen: question bank drill | Rapid Q&A across domains (Section 10.2). |
| 0:45–1:20 | System design, worked live | Design a CI/CD platform; then HA/SLO layer (Section 10.3); rubric. |
| 1:20–1:30 | **Break** | — |
| 1:30–2:00 | **Live troubleshooting drill (lab)** | Broken pipeline / failing pod; narrate reasoning (Section 13). |
| 2:00–2:20 | Behavioral: STAR + senior dimensions | Build 2 STARs live (Section 10.4). |
| 2:20–2:35 | Take-home prep + negotiation module | Scoping a take-home; comp-band + counter script (Section 10.5–10.6). |
| 2:35–2:55 | **Mock interview round** | Pairs run the kit; rubric feedback (Section 14). |
| 2:55–3:00 | Recap, homework, end-of-week summary | Section 24. |

---

# 10. Instructor Lesson Plan

**Step 1 — Review + frame the loop (20 min).** Recall Class 1; draw the loop (Section 11). State what each round actually evaluates so students stop guessing.

**Step 2 — Technical screen drill (25 min).** Fire questions from the bank (10.2); have students answer in 60–90 seconds. Teach the shape of a good answer: direct answer → one level of depth → a real example. Pause after each domain for the model answer.

**Step 3 — System design, worked (35 min).** Take "Design a CI/CD platform" and work it on the board using the 6-step method (10.3.1). Then layer the senior bar: HA, multi-region, SLO-driven design (W21), capacity/scale math (W22), cost tradeoffs (W18). Show the rubric and altitude guidance. Pause for "what would you ask the interviewer?" (requirements scoping is graded).

**Step 4 — Live troubleshooting (30 min, lab).** Students hit a pre-broken scenario and narrate. Coach the symptom→evidence→root-cause→fix→validate loop and *thinking aloud*. The grading is on method, not speed.

**Step 5 — Behavioral STAR + senior (20 min).** Convert a resume bullet into a STAR live. Then a senior STAR (incident command / mentoring / conflict / decision). Emphasize Result with a metric and the "what I learned" close.

**Step 6 — Take-home + negotiation (15 min).** Scope a sample take-home; show the README/submission standard. Then the negotiation module: never give the first number, anchor on total comp, the counter-offer script, negotiating level.

**Step 7 — Mock interviews (20 min).** Pairs run the kit (one interviews, one answers, then swap); each fills the rubric and gives a structured debrief.

**Step 8 — Recap + end-of-week summary (5 min).**

---

# 11. Whiteboard Explanation

**The DevOps/Cloud/SRE interview loop:**

```
Recruiter screen ─► Technical screen ─► [ Take-home (optional) ]
        │                                      │
        ▼                                      ▼
  System design ─► Live troubleshooting ─► Behavioral ─► Offer/Negotiation
```

What each round tests:
- Technical screen: breadth + correctness, fast.
- Take-home: judgment, code/IaC quality, communication, scoping.
- System design: requirements scoping, architecture, tradeoffs, failure domains, SLOs, cost, communication.
- Live troubleshooting: methodical debugging + reasoning aloud + calm under pressure.
- Behavioral: ownership, collaboration, leadership, learning (STAR).
- Offer/negotiation: leveling + total comp.

Enterprise version: at a large company these are separate panel interviewers with a shared scorecard and a hiring-committee debrief; "altitude" and "signal" are the words on the scorecard.

---

# 12. Instructor Lecture Notes

## 10.1 / 12.1 The interview loop and what each round rewards

Talking point: *"Interviewers aren't looking for the right answer; they're looking for the right *thinking*. Narrate it."*

## 10.2 / 12.2 Technical screen — question bank with model answers

Answer shape: **direct answer → one level deeper → a concrete example from your work.**

**Linux**
- *What happens when a Linux box is "out of memory" but `free` shows free memory?* — Likely the **page cache** holds it; available memory (the `available` column) is what matters, since cache is reclaimable. If processes still OOM, check `dmesg` for the OOM killer and per-cgroup limits (containers). Example: a pod OOMKilled despite node free memory → its cgroup memory limit was too low (W12).
- *How do you find what's using a port / a runaway process?* — `ss -tlnp` (or `lsof -i`), `ps aux --sort=-%cpu | head`, `top`/`htop`. Then `journalctl -u <svc>` for service logs.
- *Difference between a hard and soft link?* — Hard link shares the inode (same file, survives original deletion); symlink is a path pointer (breaks if target moves).

**Networking**
- *A service in a private subnet can't reach the internet. Why?* — No route to a **NAT gateway** in the route table, or NAT in the wrong subnet, or NACL/SG egress blocked. Walk the path: SG egress → subnet route table → NAT in a public subnet → IGW (W5).
- *TCP vs UDP, and when each in infra?* — TCP reliable/ordered (HTTP, DBs); UDP low-overhead (DNS, metrics like StatsD, some VPN). 
- *What is a /24 and how many usable hosts?* — 256 addresses, 254 usable (AWS reserves 5 per subnet, so 251).
- *DNS resolution path?* — resolver → root → TLD → authoritative; cache/TTL at each hop. In K8s, CoreDNS resolves `svc.namespace.svc.cluster.local`.

**Containers**
- *Why multi-stage Docker builds?* — Build deps stay in the build stage; the final image ships only the artifact → smaller, fewer CVEs, faster pulls. Pair with **distroless/non-root** for security (W10, W19).
- *Difference between `CMD` and `ENTRYPOINT`?* — ENTRYPOINT is the executable; CMD provides default args (overridable). Use ENTRYPOINT for the binary, CMD for defaults.
- *Container vs VM?* — Containers share the host kernel (lightweight, fast); VMs virtualize hardware (stronger isolation, heavier).

**Kubernetes**
- *Walk through a CrashLoopBackOff diagnosis.* — `kubectl get pods` → `describe pod` (events) → `logs --previous` → check probes, env/ConfigMap/Secret, image tag, resources. Common causes: bad command, missing config, failing readiness probe, OOMKilled (W12).
- *Readiness vs liveness probe?* — Readiness gates traffic (remove from Service endpoints when not ready); liveness restarts a hung container. Misusing liveness as readiness causes restart storms.
- *Service vs Ingress?* — Service gives stable in-cluster networking (ClusterIP/NodePort/LoadBalancer); Ingress is L7 HTTP routing to Services via a controller.
- *How does a rolling update stay safe?* — `maxUnavailable`/`maxSurge`, readiness probes gating new pods, and a rollback path (`kubectl rollout undo`).

**IaC (Terraform/OpenTofu)**
- *What does `terraform plan` do and why always run it?* — Computes the diff between desired config and state; "render/plan before apply" prevents surprise destroys. Note OpenTofu is the open-source fork; commands map 1:1 (W14–15).
- *Why remote state + locking?* — Shared source of truth; state locking (e.g., DynamoDB/S3 or a backend) prevents concurrent corruption.
- *Modules — why?* — Reuse, consistency, blast-radius control; a golden-path pattern (W20).
- *How do you handle secrets in Terraform?* — Never in state in plaintext if avoidable; use a secrets manager + data sources, mark `sensitive`, and restrict state access (W6).

**CI/CD**
- *Describe a secure pipeline.* — build → test → SAST/dependency scan → multi-stage Docker → image scan → sign → push to ECR → deploy (progressive) → verify. Use **OIDC keyless** auth to the cloud (no long-lived keys) (W9, W19).
- *Blue-green vs canary vs rolling?* — Rolling replaces gradually; blue-green swaps two full environments (instant rollback); canary shifts a % of traffic and watches SLOs before proceeding.
- *How do you prevent a bad deploy reaching all users?* — Progressive delivery + automated rollback on SLO/health regression; error-budget gating (W21).

Misconception to correct: candidates dump everything they know. Coach: answer the question asked, then offer to go deeper.

## 10.3 / 12.3 System design — worked

### 10.3.1 The 6-step method
1. **Clarify requirements** (functional + non-functional: scale, latency, availability target/SLO, budget). *Ask questions — this is graded.*
2. **Define API/interfaces & constraints.**
3. **High-level architecture** (draw it).
4. **Deep-dive a component** the interviewer cares about.
5. **Address non-functionals:** HA/failure domains, scaling, observability/SLOs, security, cost.
6. **State tradeoffs** and what you'd do next.

### 10.3.2 Worked prompt A — "Design a CI/CD platform for 200 microservices"
- **Clarify:** how many teams/services? deploy frequency target? compliance? cloud (AWS)? self-serve required? Non-functional: deploys must be safe (low change-failure rate), fast lead time, auditable.
- **High-level:** Git repos → CI runners (GitHub Actions, ephemeral OIDC-auth runners) → build/test/scan stages → artifact store (ECR + signed images) → GitOps (Argo CD) reconciling to EKS → progressive delivery (Argo Rollouts) → observability (Prometheus/Grafana/OTel) feeding SLO gates.
- **Self-serve / golden paths (W20):** templated pipelines + Terraform/OpenTofu modules so a team onboards a service in minutes, not weeks.
- **Non-functionals:** runner autoscaling for build capacity; multi-AZ EKS; secrets via OIDC + Secrets Manager (no static keys); audit via signed commits + image provenance.
- **Tradeoffs:** centralized golden path (consistency, less flexibility) vs per-team pipelines (flexibility, drift). GitOps pull (auditable, no cluster creds in CI) vs push.

### 10.3.3 Worked prompt B (senior elevation) — "Design the same platform for HA + observability across regions, with SLOs and a cost budget"
- **SLO-driven (W21):** define platform SLOs (e.g., pipeline success rate 99%, deploy lead time p95 < 15 min); error budgets gate risky rollouts.
- **Failure domains / HA:** multi-AZ by default; multi-region for the control plane state (Git is the source of truth; Argo CD per region); registry replication (ECR cross-region). What fails if a region dies? — region-local Argo reconciles from replicated Git/registry; DNS/traffic shift for app workloads.
- **Capacity/scale math (W22):** 200 services × N deploys/day × build minutes → required runner concurrency; size autoscaling and queue depth so p95 queue time stays under SLO. Show the back-of-envelope.
- **Observability:** golden signals + RED/USE; OTel traces across the pipeline; dashboards + alerting on SLO burn rate, not raw thresholds.
- **Cost tradeoffs (W18):** spot/ephemeral runners, cache layers to cut build minutes, rightsizing; quantify the savings vs reliability tradeoff.
- **Security:** OIDC keyless everywhere, signed images, least-privilege per-pipeline roles.

### 10.3.4 Evaluation rubric (system design)
| Dimension | Junior | Senior |
|---|---|---|
| Requirements scoping | lists some | drives scale/SLO/budget assumptions explicitly |
| Architecture | names components | clean diagram, clear data flow |
| Failure domains/HA | mentions "redundancy" | multi-AZ/region reasoning; "what fails if X dies" |
| Scale | hand-wave | capacity math, autoscaling, queue depth |
| Observability/SLOs | "add monitoring" | SLOs + error budgets + burn-rate alerts |
| Cost | ignores | explicit tradeoffs, quantified |
| Communication | dumps | structured, checks in, states tradeoffs |

**Altitude guidance for senior:** lead with assumptions and SLOs, reason about failure domains and cost out loud, and end every component with its tradeoff. Saying "I'd choose Argo CD over Jenkins push because pull-based GitOps removes cluster creds from CI and gives an audit trail, at the cost of more upfront setup" is the senior signal.

## 10.4 / 12.4 Behavioral — STAR + senior dimensions

STAR = Situation, Task, Action (**you**, specific), Result (**metric**), + "what I learned." Keep it ~2 minutes.

**Worked STAR (technical, from capstone):**
- *S:* In the capstone, deploys failed intermittently with image-pull errors. *T:* I owned getting deploys reliable. *A:* Using an evidence-first method (events/logs), I traced it to `:latest` tag caching and enforced commit-SHA image tags in the pipeline + a digest pin. *R:* Image-pull failures dropped to zero; deploys became reproducible. *Learned:* immutable tags are non-negotiable.

**Senior behavioral bank (with model angles):**
- *Lead an incident:* "Tell me about a time you ran an incident." → Take incident command: declare severity, assign roles, communicate status, mitigate first/RCA later, run a **blameless postmortem** with action items (W21). Result: MTTR + recurrence reduced.
- *Mentoring:* "How have you grown others?" → paired with a junior on K8s debugging, created a runbook, they later resolved a similar incident solo. Result: team MTTR/independence up.
- *Conflict / driving a decision against pushback:* "A time you disagreed technically." → proposed GitOps over manual deploys; addressed objections with a small spike + an ADR documenting tradeoffs; aligned the team on data. Result: change-failure rate down.
- *Defending a release freeze on error-budget grounds:* "Tell me about a hard call." → SLO error budget exhausted; held the feature release, communicated the why with data, prioritized reliability work. Result: budget recovered, no major incident.
- *Failure / learning:* "A time you failed." → own it, show the systemic fix, no blame.

Coach: senior STARs emphasize **decision + scope + people + outcome**, not just task completion.

## 10.5 / 12.5 Take-home assignment preparation

Common 2026 take-homes: build a small CI/CD pipeline; fix/refactor a broken Terraform/OpenTofu repo; containerize an app; deploy to K8s with a Helm chart.

Approach:
1. **Scope to the time-box.** Do the asked thing well; don't gold-plate. State assumptions in the README.
2. **Communicate judgment.** A README with *Decisions* and *What I'd do with more time* often outscores extra code — it shows senior reasoning.
3. **Ship quality signals:** tests, a Makefile/task runner, `terraform plan` output or CI passing, no secrets committed, cleanup instructions, a diagram.
4. **Make it run.** Clear setup steps; the reviewer must reproduce it in minutes.
5. **Use the course discipline:** plan-before-apply, multi-stage/distroless, evidence-first notes if you fixed something.

Anti-patterns: over-engineering, no README, secrets in repo, "works on my machine," ignoring the stated constraints.

## 10.6 / 12.6 Salary negotiation module

Principles:
- **Never give the first number.** Deflect: "I'd like to learn more about the role and level; what range is budgeted for this position?"
- **Anchor on total comp** (base + bonus + equity + sign-on), not base.
- **Negotiate the level.** Comp bands attach to levels; getting bumped a level is worth more than haggling base within a band. If the loop showed senior signal, push for senior leveling.
- **Research bands** (levels.fyi/Glassdoor/peers) before the call.
- **Use competing offers honestly**, never bluff a number you don't have.
- **It's a relationship, stay collaborative.** "I'm excited; I want to make this work. Based on my research for this level and my competing situation, I was hoping for X total comp — is there flexibility?"

**Counter-offer script (worked):**
> "Thank you — I'm genuinely excited about this team. Based on my research for this scope/level and the value I bring (cite a portfolio metric), I was targeting around **$X total comp**. The base is a bit below that; is there room on base, or could we look at sign-on or equity to close the gap? I'm confident we can find a number that works for both of us."

After the counter: get the final offer **in writing**; evaluate base/bonus/equity vesting/sign-on/PTO/remote/learning budget as a package; respond within the stated window.

Misconception: "Negotiating risks the offer." Rescinds over a polite, researched counter are rare; most companies expect one round.

---

# 13. Instructor Demo Script / Live Troubleshooting Drill

**Demo / drill title:** Debug a failing deployment under interview conditions.

**Objective:** practice diagnosing aloud with the symptom→evidence→root-cause→fix→validate method.

**Required setup (instructor pre-breaks one):**
- **Scenario A (failing pod):** a Deployment referencing a ConfigMap key that doesn't exist → CrashLoopBackOff; or a too-low memory limit → OOMKilled.
- **Scenario B (broken pipeline):** a GitHub Actions workflow pushing an image tagged `:latest` with a failing image-scan gate, or missing OIDC permissions (`id-token: write`) so the cloud auth step fails.
- **Scenario C (networking):** a pod can't reach a service / a private-subnet host can't egress (missing NAT route).

**Steps (Scenario A, demonstrated):**
1. **Symptom:** `kubectl get pods` → `CrashLoopBackOff`. Narrate: "I see restarts; I need evidence before guessing."
2. **Evidence:** `kubectl describe pod <p>` (read Events) → `kubectl logs <p> --previous`. Expected: an event/log line like "couldn't find key APP_CONFIG in ConfigMap" or "OOMKilled."
3. **Root cause:** missing ConfigMap key (or memory limit too low).
4. **Fix:** add the key / raise `resources.limits.memory`; `kubectl apply`.
5. **Validate:** `kubectl get pods` Running; `kubectl rollout status deploy/<d>`.

**Expected outputs:** the failing event surfaced; pod Running after fix.

**Common failure points & recovery:** students guess before reading events → redirect to `describe`. They edit live and lose track → fix in the manifest, re-apply.

**Pipeline (Scenario B) commands to reason through:**
```bash
# read the failure, not the summary
gh run view --log-failed
# common senior catch: OIDC perms missing in the workflow
#   permissions: { id-token: write, contents: read }
# and immutable tags instead of :latest
docker build -t $ECR/app:${GITHUB_SHA} .
```

**Cleanup:** delete the practice namespace/cluster resources and any pushed images to avoid cost: `kubectl delete ns drill`; remove test ECR images.

**Coaching the narration (the actual skill being graded):**
- State your hypothesis and what evidence would confirm/deny it.
- Read errors out loud; don't skim.
- Say what you'd check next *before* you check it.
- When fixed, state how you'd *prevent* recurrence (readiness probe, resource requests, immutable tags) — the senior close.

---

# 14. Student Lab Manual

**Lab title:** Run a full mini-loop: technical answers, a design walkthrough, a troubleshooting drill, and a mock interview.

**Lab objective:** rehearse the loop end to end and get rubric-based feedback.

**Estimated time:** 50 minutes in class + homework.

**Student prerequisites:** Class 1 artifacts; a partner; a recording device; the broken scenario from Section 13.

**Starting point from Class 1:** your resume bullets and capstone — your STAR + design source.

**Architecture/workflow overview:** candidate ↔ interviewer using the mock kit, scored by the rubric.

**Steps:**
1. **Technical screen (8 min):** partner asks 6 questions from Section 10.2; answer in the direct→deeper→example shape.
2. **System design (12 min):** answer "Design a CI/CD platform," then the interviewer adds "make it HA across regions with SLOs and a cost budget." Use the 6-step method; draw it.
3. **Troubleshooting (10 min):** diagnose the pre-broken scenario aloud (symptom→evidence→root-cause→fix→validate).
4. **Behavioral (8 min):** deliver one technical STAR and one senior STAR (incident/mentoring/decision).
5. **Swap roles** and repeat as interviewer; fill the rubric (Section 22).
6. **Debrief (5 min):** each gives 1 strength + 2 specific improvements.

**Commands students should run (troubleshooting):**
```bash
kubectl get pods -n drill
kubectl describe pod -n drill <pod>
kubectl logs -n drill <pod> --previous
kubectl rollout status deploy/<d> -n drill
```

**Expected outputs:** a completed rubric per candidate; a recording for self-review.

**Validation checklist:**
- [ ] Technical answers used the direct→deeper→example shape.
- [ ] Design clarified requirements *before* drawing.
- [ ] Design reached the senior layer (failure domains, SLOs, scale math, cost).
- [ ] Troubleshooting read evidence before guessing and stated a prevention.
- [ ] STARs had a metric Result and (for senior) a decision/people dimension.
- [ ] Rubric completed; debrief delivered.

**Troubleshooting tips (for the drill):** if stuck, return to `describe`/`logs`; verbalize the next check.

**Cleanup steps:** `kubectl delete ns drill`; delete any test cloud resources/images (cost + security hygiene).

**Reflection questions:**
1. Where did your design first drop below senior altitude?
2. Did you guess before reading evidence? Where?
3. Which STAR needs a stronger Result metric?

**Optional challenge task:** record a full 45-minute mock and self-score it against the rubric; redo the weakest round.

---

# 15. Troubleshooting Activity

**Incident title:** "Frozen in the design round."

**Business impact (candidate):** strong resume, but failing on-site at the system-design and live-debug rounds; offers stall at the loop.

**Symptoms:**
- In design, jumps straight to drawing boxes without clarifying scale/SLO/budget.
- Lists components but never discusses failure domains, scale math, or cost.
- In the live drill, starts changing things before reading any logs/events.
- Behavioral answers are vague ("we improved things") with no metric and no personal action.

**Starting evidence:**
- Interviewer feedback: "couldn't assess seniority — no tradeoffs, no failure reasoning."
- Recording shows 0 clarifying questions and 0 stated assumptions in the first 3 minutes.
- The debug attempt: edits a manifest before `kubectl describe`.

**Student investigation steps (symptom→evidence→root-cause→fix→validate):**
1. Symptom: low "seniority/communication" scores. Evidence: no clarifying questions/tradeoffs. Root cause: skipping requirements scoping and altitude.
2. Symptom: failed live debug. Evidence: changed state before reading evidence. Root cause: not using the evidence-first method.
3. Symptom: weak behavioral. Evidence: no metric/no "I". Root cause: STAR missing Result + personal Action.

**Expected root cause:** good knowledge, wrong *process* — no scoping, no altitude, no evidence-first discipline, no quantified ownership.

**Correct resolution:** open every design with assumptions + non-functionals; end each component with a tradeoff; in debugging, evidence before action and a prevention close; in behavioral, "I" + a metric.

**Common wrong paths:** memorizing one reference architecture; speed-debugging by guessing; rehearsing STARs without numbers.

**Instructor hints:** make them ask 3 clarifying questions before drawing; enforce "read the event aloud before touching anything."

**Preventive action:** a pre-interview checklist (Section 22) taped to the desk: clarify → assumptions → tradeoffs → evidence-first → metric.

---

# 16. Scenario-Based Discussion Questions

1. You don't know the answer in a technical screen. What do you do? *(Theme: reason from fundamentals, say what you'd check; honesty > bluffing. Follow-up: how to show learning ability.)*
2. In system design, the interviewer keeps adding scale. How do you stay senior? *(Theme: capacity math, failure domains, SLO + cost tradeoffs. Follow-up: when to say "this needs multi-region.")*
3. A take-home asks for "production-ready" in 4 hours. How do you scope? *(Theme: do the core well, document tradeoffs/"with more time." Follow-up: what quality signals matter most?)*
4. Behavioral: "Tell me about a conflict." You're junior with few stories. *(Theme: use capstone/team labs; focus on a decision + outcome. Follow-up: how to make it senior-flavored.)*
5. Recruiter asks your salary expectation first. *(Theme: deflect, ask the band, anchor on TC. Follow-up: the exact words.)*
6. You get two offers, one higher base, one higher equity. *(Theme: evaluate total comp + risk + growth. Follow-up: how to use one to negotiate the other honestly.)*
7. Live debug: you fixed the symptom but not the cause. *(Theme: state the difference; propose the real fix + prevention. Follow-up: how interviewers score this.)*

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

1. (MC) The first thing to do in a system-design round is:
   a) draw the architecture  b) **clarify requirements/assumptions (scale, SLO, budget)**  c) pick a database  d) list tools
   **B.**

2. (T/F) In a live-debug round, speed of fixing matters more than method. **False.** Method + reasoning aloud is what's graded.

3. (Short, troubleshooting) Pod is CrashLoopBackOff. First two commands? **`kubectl describe pod` (events) then `kubectl logs --previous`.**

4. (MC) A senior system-design answer must include:
   a) the most tools  b) **failure domains, SLOs, scale reasoning, and cost tradeoffs**  c) a specific cloud only  d) code
   **B.**

5. (Short) STAR's Result should always include __. **A metric/outcome (and ideally a prevention/learning).**

6. (MC, AWS) Private-subnet host can't reach the internet. Most likely cause?
   a) wrong AMI  b) **no route to a NAT gateway / NAT misplaced**  c) IAM policy  d) DNS TTL
   **B.** Walk SG egress → route table → NAT in public subnet → IGW.

7. (T/F) You should give your salary number first to "anchor high." **False.** Deflect and get the band; anchor on total comp, and negotiate the level.

8. (Short, troubleshooting) A GitHub Actions job fails at the cloud-auth step with an OIDC error. Likely fix? **Add `permissions: id-token: write` (and `contents: read`) and configure the OIDC role trust.**

9. (MC, AWS) Best image-tagging practice for reproducible deploys:
   a) `:latest`  b) **commit-SHA / digest-pinned tags**  c) random  d) date only
   **B.** Immutable tags prevent pull/caching surprises.

10. (Short) Why prefer GitOps pull (Argo CD) over CI push in a senior design? **No cluster creds in CI, auditable desired-state in Git, easy rollback — at the cost of more setup.**

11. (Connect C1↔C2) Your Class 1 resume bullet says "cut MTTR 40%." How does it appear in Class 2? **As a STAR story (and possibly a design-defense / SLO discussion) you must defend with specifics.**

12. (Connect C1↔C2) Why must your claimed level (Class 1) match your loop performance (Class 2)? **Leveling mismatch surfaces in the loop and in negotiation; calibrate scope to claim.**

---

# 18. Homework Assignment

**Title:** Interview-ready loop kit.

**Scenario:** You have an on-site loop next week.

**Student tasks:**
1. Build a STAR bank: 6 stories (3 technical, 3 senior: incident, mentoring, decision/conflict) — each with a metric Result.
2. Write a one-page worked solution to one system-design prompt (CI/CD platform *or* an SRE SLO+alerting design that uses W21), reaching the senior layer.
3. Record yourself doing the Section 13 live-debug drill, narrating; self-score.
4. Prepare a take-home plan: how you'd scope/structure/submit a "fix this Terraform repo" task.
5. Write your negotiation script (deflection + counter) with researched comp bands for your target level.
6. Complete one full recorded mock with a peer and the rubric.

**Expected deliverables:** STAR bank (md), design writeup (md + diagram), drill recording link + self-score, take-home plan, negotiation script, completed mock rubric.

**Submission format:** one markdown file with links.

**Estimated completion time:** 4–6 hours.

**Grading criteria:** STARs have metrics + senior dimensions; design reaches senior altitude (failure domains/SLO/scale/cost); drill shows evidence-first method + prevention; negotiation anchors on TC + level; mock rubric completed.

**Optional advanced challenge:** do a second design prompt at a higher altitude (multi-region, capacity math) and defend three tradeoffs in writing.

---

# 19. Common Student Mistakes

- **Skipping requirements scoping in design.** Why: eager to draw. Fix: ask 3 clarifying questions first; state assumptions.
- **Component-listing instead of tradeoff reasoning.** Why: junior altitude. Fix: end each component with its tradeoff; add failure domains/SLO/cost.
- **Guessing in the live drill.** Why: pressure. Fix: evidence-first; read events/logs aloud before acting.
- **Vague STARs, no metric, no "I".** Why: under-rehearsed. Fix: quantify Result; use first person; add prevention/learning.
- **Over-building the take-home.** Why: trying to impress. Fix: scope to the time-box; document tradeoffs in the README.
- **Giving the salary number first / negotiating base within a band.** Why: nervousness. Fix: deflect, anchor TC, negotiate the level.
- **Brain-dumping in the technical screen.** Why: anxiety. Fix: answer the question, then offer depth.

---

# 20. Real-World Enterprise Scenario

A platform team at a fintech runs a 5-round senior SRE loop with a shared scorecard: technical screen, system design ("design our deploy + SLO platform"), a live K8s debug, two behavioral (one with an EM on incident leadership), and a hiring-committee debrief. Comp is banded by level (L4/L5).

A course graduate enters the loop. In design they open with assumptions (deploy frequency, availability SLO 99.9%, budget), reach the senior layer (multi-AZ, error-budget gating, runner capacity math, spot-cost tradeoffs), and end components with tradeoffs. In the live debug they read events before touching anything and close with a prevention (readiness probe + immutable tags). In behavioral they tell an incident-command STAR with a blameless-postmortem follow-through and a quantified MTTR result. The committee scores "clear L5 signal." In negotiation the candidate deflects the first-number ask, anchors on total comp for L5, and gets a level bump worth more than any base haggle.

What the DevOps/Cloud/SRE engineer does here: treats the loop as a system to be reasoned about — scope, tradeoffs, evidence, and leadership — exactly the disciplines the whole course taught, now performed under interview constraints.

---

# 21. Instructor Tips

- **Teaching tip:** the single highest-leverage coaching note is "ask clarifying questions and state assumptions before you draw."
- **Pacing:** protect the system-design and mock segments — they carry the most signal. Don't let the technical Q&A run long.
- **Lab support:** for the live drill, redirect every guess back to `describe`/`logs`; reward narration over speed.
- **Struggling students:** give them a STAR template and the 6-step design card; have them fill before performing.
- **Advanced students:** push the senior layer — multi-region, capacity math, error-budget gating, and an incident-command STAR; have them defend tradeoffs against pushback.

---

# 22. Student Outcome Checklist

Students should be able to **explain**:
- What each interview round evaluates and how to show seniority.
- The 6-step system-design method and the senior altitude markers.
- A negotiation strategy anchored on level + total comp.

Students should be able to **build/configure**:
- A STAR bank with technical and senior stories (metric Results).
- A worked system-design solution reaching failure domains, SLOs, scale, and cost.
- A take-home submission with README/decisions/diagram/cleanup.

Students should be able to **troubleshoot**:
- A failing pod, broken pipeline, or networking issue aloud, evidence-first, with a prevention close.

### Pre-interview checklist (tape to desk)
clarify → state assumptions → architecture → tradeoffs each component → failure domains/SLO/scale/cost → (debug) evidence before action + prevention → (behavioral) "I" + metric.

### Mock-interview kit
- **Interviewer script:** ask 6 technical Qs → 1 design prompt + 1 senior follow-up → 1 live-debug → 2 STAR prompts. Probe one answer deeper. Stay neutral.
- **Candidate rubric (score 1–5 each):** technical correctness · requirements scoping · architecture/tradeoffs · failure/scale/SLO/cost reasoning · debugging method · communication/altitude · behavioral (metric + ownership).
- **Debrief template:** 1 strength · 2 specific improvements · 1 thing to redo before next mock.

---

# 23. Class Completion Checklist

**Instructor before ending class:**
- [ ] Every student completed at least one mock round as candidate and interviewer.
- [ ] Every student has a started STAR bank and one worked design.
- [ ] Live-debug drill run with evidence-first coaching.
- [ ] Negotiation script drafted.

**Student before leaving:**
- [ ] Completed mock rubric received.
- [ ] STAR bank started (incl. one senior story).
- [ ] Pre-interview checklist saved.

**Verify before closing the week:**
- [ ] Resume/portfolio (Class 1) and loop prep (Class 2) are consistent on level.
- [ ] Homework (full loop kit) assigned.

---

# 24. End-of-Week Summary

**What students learned this week:** how to convert 24 weeks of skills into hiring outcomes — an ATS-safe, quantified resume, an optimized LinkedIn and senior-signal portfolio (Class 1), and how to win the full interview loop: technical screen, senior-altitude system design, evidence-first live troubleshooting, STAR + senior behavioral stories, take-home strategy, and leveling-aware negotiation (Class 2).

**How Class 1 and Class 2 connect:** Class 1's artifacts are Class 2's ammunition — every resume bullet becomes a STAR and a design-defense; the claimed level must hold across both.

**How this week prepares students for what's next:** this is the capstone of the program — the transition from learner to hired engineer. With the capstone (Weeks 23–24) as proof and these artifacts + loop skills, students are ready to apply, interview, and negotiate at the level their scope supports.

**What students should review before applying:** the capstone architecture and decisions (for design-defense and STARs), the W12 troubleshooting method (for the live drill), W21 SLOs/error budgets and W22 capacity reasoning (for senior system design), and their own metrics log.

---

## Class Artifacts & Validation

This is a **non-technical (interview-prep) class** — per the course's artifact standard §4 it is exempt from runnable code but still ships concrete, reusable documents (STAR bank, system-design prompts with model answers + rubrics, take-home brief + grading key, mock protocol, negotiation guide) as real files. The validation gate is `./validate.sh`, which enforces presence + structure + word-count *substance* checks, including that each of the five design prompts ships **both** a model answer and a scoring rubric. It needs no external tools and runs offline ($0). The rows below are the artifacts **this class (the interview loop)** uses.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/career-prep/solution/star-bank.md | markdown | 12 STAR behavioral stories (incident, failure, conflict, leadership, ownership) | `cd labs/career-prep && ./validate.sh` | PASS — STAR-letters + failure-story markers asserted |
| 2 | labs/career-prep/solution/system-design/url-shortener/model-answer.md | markdown | System-design model answer (≥600 words) + paired `scoring-rubric.md` | `cd labs/career-prep && ./validate.sh` | PASS — model-answer + rubric present, ≥ word floors |
| 3 | labs/career-prep/solution/system-design/rate-limiter/model-answer.md | markdown | System-design model answer + paired `scoring-rubric.md` | `cd labs/career-prep && ./validate.sh` | PASS — both files asserted |
| 4 | labs/career-prep/solution/system-design/multi-region-web-app/model-answer.md | markdown | System-design model answer + paired `scoring-rubric.md` | `cd labs/career-prep && ./validate.sh` | PASS — both files asserted |
| 5 | labs/career-prep/solution/system-design/observability-pipeline/model-answer.md | markdown | System-design model answer + paired `scoring-rubric.md` | `cd labs/career-prep && ./validate.sh` | PASS — both files asserted |
| 6 | labs/career-prep/solution/system-design/cicd-platform/model-answer.md | markdown | System-design model answer + paired `scoring-rubric.md` | `cd labs/career-prep && ./validate.sh` | PASS — both files asserted |
| 7 | labs/career-prep/solution/take-home-brief.md | markdown | Realistic ~4h take-home assignment | `cd labs/career-prep && ./validate.sh` | PASS — present, ≥ word floor |
| 8 | labs/career-prep/solution/take-home-solution-outline.md | markdown | Grading key / answer key for the take-home | `cd labs/career-prep && ./validate.sh` | PASS — present, ≥ word floor |
| 9 | labs/career-prep/solution/mock-interview-protocol.md | markdown | How to run/score behavioral + design + debug mock loops | `cd labs/career-prep && ./validate.sh` | PASS — present, ≥ word floor |
| 10 | labs/career-prep/solution/negotiation.md | markdown | Leveling-aware compensation negotiation playbook | `cd labs/career-prep && ./validate.sh` | PASS — present, ≥ word floor |
| 11 | labs/career-prep/starter/star-worksheet.md | markdown | Blank STAR worksheet with `TODO` gaps (copy per story) | `cd labs/career-prep && ./validate.sh` | PASS — present, TODO gaps intact |
| 12 | labs/career-prep/starter/design-worksheet.md | markdown | Blank 45-min system-design scaffold with `TODO` gaps | `cd labs/career-prep && ./validate.sh` | PASS — present, TODO gaps intact |

> No `LIVE-*EVIDENCE*.txt` / `LIVE-AWS-VALIDATION.txt` exists for this module and none is applicable: the lab provisions and operates nothing — the only evidence is the static validator passing (`./validate.sh` exit 0, 32 passed, 0 failed).

## Definition of Done

Ticked honestly for this class. Boxes that do not apply to a non-code class are marked **N/A** with the reason.

- [ ] ~~Every technology taught ships at least one runnable file on disk (not just a fence).~~ **N/A** — non-technical class; ships STAR bank, design prompts + rubrics, take-home + key, mock protocol, and negotiation guide as real files (standard §4 exemption).
- [x] Each artifact passes (or documents) its **validation gate** — `./validate.sh` exits 0 (32 passed, 0 failed), including the "every design prompt has model answer **and** rubric" check; output captured above.
- [x] Lab has **starter** (`starter/star-worksheet.md`, `starter/design-worksheet.md`, intentionally incomplete with `TODO` gaps) and **solution** (`star-bank.md`, `system-design/*`, `take-home-brief.md`, `mock-interview-protocol.md`, `negotiation.md`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** — N/A and stated: the module creates no processes, containers, or cloud resources; README documents "Nothing to clean up."
- [x] **Instructor answer key** exists — `take-home-solution-outline.md` is the take-home grading key; each design prompt ships a `scoring-rubric.md`; README "Instructor answer key" lists non-obvious grading points (red/green flags per prompt).
- [x] **Troubleshooting exercise** uses a real, reproducible broken state — truncating any `solution/` file below its word floor, or removing one of a design prompt's two files, makes `./validate.sh` fail honestly (documented in README).
- [x] **Expected outputs** are shown — README shows the `== 32 passed, 0 failed ==` / `exit=0` tail and per-task "Done when" criteria (e.g. design self-score ≥ 13/20, take-home self-score ≥ 70/100).
- [x] **Cost & security warnings** present — README "Security considerations" (no PII/secrets; negotiation-honesty note) and "Cost considerations" ($0).
- [x] **Cross-references** to the module repo and prior weeks are correct — links to `labs/career-prep/` and capstone Weeks 23–24; review pointers cite W12 (troubleshooting), W21 (SLOs/error budgets), W22 (capacity) — verified.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (`ls`-verified).
