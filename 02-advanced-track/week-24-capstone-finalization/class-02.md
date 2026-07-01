# Week 24: Capstone Finalization — Production Readiness and Architecture
> **▶ Runnable lab for this class:** [`labs/capstone/`](../../labs/capstone/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package: Capstone Presentation and Technical Defense

**Week:** 24
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 2: Presenting and Defending the DevOps Capstone**

## Class Purpose

This class is the capstone finalization review of the unified track. Students present their capstone project, demonstrate their live end-to-end workflow, defend their architecture decisions against the ADRs, solve a novel open-ended system-design prompt, answer senior behavioral questions, and respond to a realistic failure scenario.

The focus is on professional technical communication, production-style review, troubleshooting discipline, and job-readiness.

## How This Class Builds From Class 1

Class 1 focused on final validation, documentation, demo readiness, and capstone polish.

Class 2 takes that prepared work and turns it into a formal technical review. Students now need to:

- Present the business problem.
- Explain the architecture.
- Demonstrate the workflow.
- Defend design tradeoffs.
- Respond to instructor questions.
- Troubleshoot an injected failure.
- Submit a final portfolio-ready capstone.

## What Students Will Build, Analyze, or Practice

Students will:

- Deliver a capstone presentation.
- Demonstrate at least one working part of their DevOps workflow.
- Explain Git, CI/CD, Docker, ECR, EKS, Helm, Terraform, IAM, CloudWatch, and rollback decisions.
- Diagnose a final injected failure.
- Connect their capstone to real DevOps job responsibilities.
- Submit final project artifacts.

---

# 2. Quick Review of Class 1

## Review Points

1. A capstone is not just an application demo. It is a complete delivery workflow.
2. A strong project must be repeatable, documented, observable, and recoverable.
3. Repository structure should clearly separate app code, pipeline code, Terraform, Helm, docs, and presentation files.
4. Docker builds the application package, ECR stores the image, and EKS runs the workload.
5. Helm helps make Kubernetes deployment repeatable and rollback-friendly.
6. Terraform must be provisioned, not just validated — prove it with a clean `terraform plan` and `terraform state list`, not only `terraform validate`.
7. IAM permissions must be explainable and should avoid broad admin access.
8. CloudWatch or logging evidence proves that the solution can be operated after deployment.

## Quick Recall Questions

1. What command confirms your current AWS identity?

   **Expected answer:**

   ```bash
   aws sts get-caller-identity
   ```

2. What are two common reasons a Kubernetes pod may show `ImagePullBackOff`?

   **Expected answer:**

   Wrong image tag, missing registry authentication, missing ECR permissions, or repository does not exist.

3. Why is a rollback plan required for a DevOps capstone?

   **Expected answer:**

   Because production deployments can fail, and teams need a known recovery path before an incident occurs.

## Common Gaps Students May Still Have From Class 1

Students may still struggle with:

- Explaining the business value of their project.
- Connecting tools into one workflow instead of describing each tool separately.
- Showing evidence instead of only describing what they built.
- Explaining IAM permissions clearly.
- Explaining rollback beyond “I would fix it.”
- Mapping AWS services to Azure or GCP equivalents.
- Presenting in a clear sequence.

## Instructor Bridge Into Class 2

The instructor should say:

> Last class, you validated and polished your capstone. Today, you need to present it like a DevOps engineer in a real technical review. That means you need to explain the problem, show the workflow, defend your choices, and troubleshoot when something breaks.

---

# 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Present** a DevOps capstone using a professional technical review structure.
2. **Demonstrate** the live, deployed workflow — pipeline run, Helm release, dashboard/alert/SLO — with shown evidence, not verbal claims.
3. **Defend** technical decisions (including OIDC, security scanning, environment separation) by reference to the project's ADRs.
4. **Solve** a *novel* open-ended system-design prompt on unfamiliar ground, reasoning aloud under questions.
5. **Respond** to senior behavioral prompts (technical leadership, mentoring, disagreement, incident command) using the STAR structure.
6. **Troubleshoot** an instructor-injected failure using the evidence-first method.
7. **Document** final deliverables and quantify impact (deploy frequency, MTTR, cost) for interview transfer.
8. **Connect** the capstone to real senior DevOps/SRE responsibilities and interview talking points.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 Knowledge

Students should already know how to:

- Validate repository structure.
- Run basic Git, Docker, AWS CLI, kubectl, Helm, and Terraform checks.
- Explain the capstone delivery flow.
- Prepare a demo path.
- Identify common final-demo failure points.
- Explain their rollback plan.

## Required Prior Concepts

Students should understand:

- CI/CD pipeline stages
- Docker image build and tagging
- Amazon ECR image storage
- Kubernetes deployments and services
- Helm releases and values files
- Terraform validation and planning
- IAM permissions and AWS identity
- CloudWatch logs and metrics
- Rollback and runbook basics

## Required Tools Already Installed

- Git
- Docker
- AWS CLI
- kubectl
- Helm
- Terraform
- VS Code
- GitLab or GitHub access
- Presentation tool

## Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should have:

```text
final-capstone/
├── README.md
├── app/
├── helm/
├── terraform/
├── .github/
│   └── workflows/
│       └── deploy.yml                  # GitHub Actions; OIDC keyless auth
├── docs/
│   ├── architecture.md
│   ├── runbook.md
│   ├── rollback-plan.md
│   ├── troubleshooting-notes.md
│   ├── production-readiness-review.md   # PRR checklist with evidence links
│   ├── cost-estimate.md                 # est. monthly cost of the architecture
│   ├── adr/                             # Architecture Decision Records (graded)
│   │   ├── 0001-record-architecture-decisions.md
│   │   ├── 0002-container-orchestration-choice.md
│   │   └── 0003-ci-authentication-oidc-vs-keys.md
│   └── multi-cloud-awareness.md         # OPTIONAL: AWS→Azure/GCP awareness notes
└── presentation/
    └── final-capstone-deck.md
```

Students should also have:

- Architecture diagram
- Final presentation draft
- Validation evidence
- Known limitations
- Demo plan
- Rollback steps
- Troubleshooting notes

---

# 5. Key Terms and Definitions

| Term | Definition | Real-World Context |
|---|---|---|
| Technical Defense | Explaining and justifying design decisions under review | Engineers defend designs during architecture reviews, release reviews, and production readiness reviews |
| Capstone Demo | Live or recorded walkthrough of the working project | Similar to showing stakeholders that a platform workflow is ready |
| Failure Injection | Intentionally introducing or simulating a problem | SRE and DevOps teams use controlled failures to test readiness |
| Tradeoff | A decision where one benefit may come with a cost | Example: faster deployment vs more approval controls |
| Production Readiness | The level of preparation needed before a system can safely support users | Includes monitoring, rollback, access control, documentation, and support model |
| Runbook Walkthrough | Explaining operational steps for support or incident response | Used by on-call engineers during incidents |
| Rollback Demonstration | Showing how to return to a previous working version | Critical when a release causes production impact |
| Artifact | A build output such as a Docker image or package | Pipelines create artifacts that are deployed later |
| Evidence-Based Review | Showing command output, screenshots, logs, or repo files to prove work | Reviewers trust evidence more than verbal claims |
| Known Limitation | A documented gap or future improvement | Professional engineers are honest about what is not complete |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Shows repository history, project structure, and source control maturity |
| GitLab CI or GitHub Actions | Demonstrates automated delivery workflow |
| Docker | Demonstrates application packaging |
| Amazon ECR | Stores and versions Docker images |
| kubectl | Shows Kubernetes workload status and troubleshooting evidence |
| Helm | Demonstrates release management, upgrades, and rollback |
| Terraform | Shows infrastructure as code validation |
| AWS CLI | Confirms AWS identity and service access |
| CloudWatch | Provides logs and monitoring evidence |
| Presentation tool | Helps students communicate architecture, workflow, and tradeoffs |
| Markdown documentation | Used for README, runbook, rollback plan, and troubleshooting notes |

---

# 7. AWS Services Used

| AWS Service | How It Connects to Class 2 |
|---|---|
| Amazon ECR | Students explain or demonstrate where Docker images are stored |
| Amazon EKS | Students explain or demonstrate Kubernetes workload deployment |
| IAM | Students defend access control and pipeline permission design |
| STS | Used to validate the current AWS identity |
| CloudWatch Logs | Used to show application or workload troubleshooting evidence |
| CloudWatch Metrics | Used to explain basic monitoring and production visibility |
| S3, optional | May support Terraform state or artifact storage |
| DynamoDB, optional | May support Terraform state locking |

---

# 8. Azure and GCP Comparison Notes

Keep this section brief during presentations. Students should understand service mapping without shifting away from AWS.

| DevOps Capability | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | ECR | Azure Container Registry | Artifact Registry |
| Managed Kubernetes | EKS | AKS | GKE |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |
| Identity and access | IAM | Microsoft Entra ID, Azure RBAC | Cloud IAM |
| IaC provider | AWS Provider | AzureRM Provider | Google Provider |

Key teaching point:

```text
Git → CI/CD → Image Build → Registry → Kubernetes → Monitoring → Rollback
```

The cloud-specific services change.

---

# 9. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Opening, Class 1 review, Class 2 expectations |
| 0:10 to 0:22 | Instructor walkthrough: present and defend; reference ADRs |
| 0:22 to 0:35 | Whiteboard: technical defense flow + open-ended design flow |
| 0:35 to 1:15 | Student capstone presentations + role-based panel Q&A |
| 1:15 to 1:25 | Break |
| 1:25 to 1:55 | Open-ended system-design exercise (one novel prompt per student) |
| 1:55 to 2:20 | Senior behavioral round: STAR drills (leadership, mentoring, disagreement, incident command) |
| 2:20 to 2:40 | Instructor-injected live troubleshooting |
| 2:40 to 2:52 | Discussion: baseline-vs-future controls; quantified impact |
| 2:52 to 3:00 | Final submission checklist, course wrap-up, next-step guidance |

For larger cohorts, reduce presentation time per student or use team presentations.

Recommended presentation timing:

```text
7 minutes: presentation and demo
3 minutes: instructor questions
2 minutes: feedback
```

---

# 10. Instructor Lesson Plan

## Step 1: Open the Class

Explain:

> Today is your technical review. Your goal is not to show every command you ever ran. Your goal is to tell a clear engineering story: what problem you solved, how your workflow works, how it is operated, and how you recover when it fails.

Ask:

> What is the first thing you want reviewers to understand about your capstone?

## Step 2: Review Class 1 Deliverables

Quickly confirm students have:

- Repository ready
- README ready
- Architecture diagram ready
- Demo path ready
- Rollback plan ready
- Runbook ready
- Presentation ready
- Troubleshooting notes ready

Do not spend too long here. This is just a readiness check.

## Step 3: Teach the Presentation Structure

Show the recommended structure:

```text
1. Business problem
2. Architecture overview
3. Repository structure
4. Pipeline flow
5. Docker and ECR workflow
6. Kubernetes and Helm deployment
7. Terraform usage
8. IAM and security
9. Monitoring and CloudWatch
10. Rollback plan
11. Azure/GCP mapping
12. Lessons learned and improvements
```

Teaching tip:

Tell students that reviewers should never feel lost. Every section should answer, “Why does this matter?”

## Step 4: Whiteboard the Technical Defense Flow

Draw the defense flow:

```text
Problem → Design → Workflow → Evidence → Risks → Recovery → Improvements
```

Explain:

> Do not just say what you used. Explain why you used it and what risk it reduces.

## Step 5: Instructor Demo

Provide a short sample capstone presentation flow. Keep it brief so students have enough presentation time.

Show:

- Example problem statement
- Example architecture
- Example pipeline flow
- Example evidence
- Example tradeoff
- Example known limitation

## Step 6: Student Presentations

Each student or team presents.

Instructor should evaluate:

- Clarity
- Technical accuracy
- Evidence
- Security awareness
- Rollback plan
- Monitoring awareness
- Troubleshooting readiness
- Professional communication

Pause after each presentation for targeted questions.

Example questions:

- Why did you choose this pipeline structure?
- What happens if the ECR push fails?
- How do you know the app is healthy after deployment?
- What is your rollback path?
- What would you improve for production?

## Step 7: Open-Ended System-Design Exercise

Assign each student a **novel** prompt from Concept 7 (one they did *not* build). Give 8–10 minutes at the whiteboard.

Coach them through:

```text
Clarify → Requirements & Scale → High-Level Design → Deep Dive →
Tradeoffs → Failure Modes → Observability/SLOs → Cost → Iterate
```

Interrupt with one or two realistic constraints mid-design ("now it must be multi-region," "now budget is halved") to test adaptation. Reward clarifying questions and named tradeoffs; redirect students who jump straight to a diagram.

## Step 8: Senior Behavioral Round

Pose two of the four behavioral dimensions (leadership, mentoring, disagreement, incident command). Have each student deliver a 90-second STAR answer. Push for a quantified Result and a short Situation. This bridges directly into Week 25 Class 2.

## Step 9: Troubleshooting Injection

Give each student or team one failure to diagnose.

Students should explain:

- Symptom
- Investigation steps
- Root cause
- Fix
- Prevention

## Step 10: Enterprise Readiness Discussion

Ask students what they would add before production.

Expected answers:

- OIDC authentication
- Approval gates
- Dev, stage, prod separation
- Security scans
- Better logging
- SLOs or alerts
- Secret management
- Cost controls
- Automated rollback

## Step 11: Close the Week

End with:

> You now have a project that demonstrates senior DevOps/SRE thinking end to end: keyless automation, packaging, IaC-provisioned infrastructure, a gating security scan, live observability with an SLO, rollback, ADR-backed decisions, and a structured troubleshooting and design method. You can defend what you built *and* reason about systems you have never seen.

---

# 11. Instructor Lecture Notes

## Main Teaching Message

Class 2 is about technical communication and professional judgment. In real DevOps work, building the workflow is only part of the job. You also need to explain it, defend it, troubleshoot it, and improve it.

## Concept 1: A Strong Presentation Starts With the Problem

Students should not begin with tools.

Weak opening:

> I used Docker, Kubernetes, Terraform, and GitHub Actions.

Strong opening:

> The business problem is that manual deployments are slow, inconsistent, and hard to roll back. I built a repeatable CI/CD workflow that packages the app as a Docker image, stores it in ECR, deploys it to Kubernetes using Helm, and documents rollback and troubleshooting steps.

Talking point:

> Tools are not the story. The delivery problem is the story.

## Concept 2: Evidence Builds Trust

Students should show evidence:

- Git repository
- Pipeline file
- Dockerfile
- ECR repository or image tag
- Helm release
- Kubernetes pods and services
- Terraform `plan` (no changes) + `state list` output
- CloudWatch logs
- Runbook
- Rollback plan

Common misconception:

> If I say I built it, that is enough.

Correction:

> In engineering reviews, evidence matters. Show the repo, command output, logs, screenshots, or diagrams.

## Concept 3: Good DevOps Engineers Explain Tradeoffs

Every design has tradeoffs.

Examples:

- Manual approval slows deployment but reduces production risk.
- A shared EKS cluster reduces cost but limits isolation.
- Static credentials are easy for labs but risky for production.
- Helm values simplify environments but require strong review discipline.
- A simple pipeline is easier to understand but may lack advanced gates.

Talking point:

> Senior engineers are not expected to have perfect designs. They are expected to understand tradeoffs.

## Concept 4: Rollback Is a Business Protection Mechanism

Rollback is not just a technical feature. It protects users and business operations.

Students should be able to say:

> If this deployment causes errors, I can roll back using Helm release history or redeploy a previous image tag. I also documented the rollback steps in the runbook.

## Concept 5: Troubleshooting Should Be Structured

Students should not randomly change files during the failure injection.

Use this flow:

```text
Symptom → Layer → Evidence → Root Cause → Fix → Validation → Prevention
```

Example:

- Symptom: Pod is `ImagePullBackOff`
- Layer: Kubernetes pulling image from ECR
- Evidence: `kubectl describe pod`
- Root cause: Wrong image tag
- Fix: Correct Helm values and upgrade release
- Validation: Pod becomes `Running`
- Prevention: Pipeline passes image tag automatically

## Concept 6: Baseline Controls Are In Scope; Only the Heavy Ones Are "Future Work"

Be careful with the "portfolio-ready, not production-ready" line. It is honest about scale, but on a senior track it must not become an excuse for skipping cheap, expected controls. Split the list explicitly:

**Baseline — must be IN the capstone (and demonstrated):**

- OIDC keyless CI/CD authentication (no long-lived AWS keys).
- At least one gating security scan (image or dependency) that fails the build on a critical finding.
- At least one real alert wired to a live signal, plus an SLO.

**Genuinely larger-system work — fair to list as future:**

- Separate AWS accounts / landing-zone multi-account (Week 17).
- Approval gates and change management.
- Disaster recovery / multi-region.
- Centralized audit logging.

Common misconception:

> Everything beyond the running app is "production stuff" I can defer.

Correction:

> OIDC, a gating scan, and one real alert are baseline. If you skipped them, do not claim them — and expect to be asked why they are missing. A sharp interviewer will probe any control you describe but did not implement.

Talking point:

> "We'd add OIDC for production" is a red flag when OIDC is a half-day change. Implement the cheap controls; reserve "future work" for the things that genuinely need a bigger org.

## Concept 7: Open-Ended System Design (Not Just Defending Your Project)

Defending your own capstone is the *easy* interview — you know it cold. The senior bar is designing something unfamiliar, aloud, while someone pokes holes in it. This class gives every student one **novel** system-design prompt in addition to the capstone defense.

Teach the structure (it is the same flow as the capstone defense, applied to a blank page):

```text
Clarify → Requirements & Scale → High-Level Design → Deep Dive →
Tradeoffs → Failure Modes → Observability/SLOs → Cost → Iterate
```

Coaching points:

- **Clarify first.** Ask about scale, latency targets, team size, budget, compliance *before* drawing. Jumping to a diagram is the most common junior mistake.
- **State assumptions out loud.** "I'll assume 50 teams, ~500 deploys/day, single region to start."
- **Name tradeoffs, not just choices.** Every box on the board costs something.
- **Bring reliability in.** What is the SLO? What is the failure mode? How do you roll back? This is where DevOps/SRE candidates separate from generic backend candidates.

Example prompts (assign one per student; they have *not* built these):

1. Design a CI/CD platform that serves 50 engineering teams with self-service golden paths (ties to Week 20).
2. Design a multi-region active-active service with an availability SLO of 99.95% (ties to Weeks 16, 21, 22).
3. Design the observability stack for 200 microservices: metrics, logs, traces, alerting, on-call routing (ties to Week 16).
4. Design secrets and credential management for CI across 30 repos with zero long-lived keys (ties to Weeks 6, 19).
5. Design a cost-aware autoscaling and capacity strategy for a spiky workload (ties to Weeks 18, 22).

Talking point:

> Your capstone proves you can build *one* thing well. The open-ended design proves you can reason about a system you have never seen. Interviewers test the second far more than the first.

## Concept 8: Senior Behavioral Dimensions — Leadership, Mentoring, Incident Command

Senior loops are not only technical. They probe how you operate with people and under pressure. None of this is rehearsed by "explain your project," so practice it explicitly here using **STAR** (Situation, Task, Action, Result).

The four dimensions to drill:

1. **Technical leadership / driving a decision** — a time you pushed a technical direction across a team or owned an ambiguous problem end to end.
2. **Mentoring** — a time you brought a less-experienced engineer up to speed; what you changed in *how* you explained things.
3. **Disagreement / "disagree and commit"** — a technical disagreement you handled professionally; bonus if it ties to a real tradeoff (e.g., defending a release freeze when the error budget is exhausted — Week 21 — to a product manager who wants to ship).
4. **Incident command** — leading or coordinating an incident: how you structured comms, assigned roles, decided to roll back, and ran the blameless postmortem.

Coaching:

- Quantify the **Result** (MTTR dropped from X to Y, deploy frequency rose, the junior shipped solo within a month).
- Keep Situation/Task short; spend the time on **Action** — that is where seniority shows.
- It is fine to draw a behavioral story from the capstone *team* experience or the troubleshooting activity if real workplace examples are thin.

Talking point:

> "Tell me about a disagreement" is not small talk — it is the screen for whether you can be senior on a team. Have two crisp STAR stories ready before you walk in.

---

# 12. Whiteboard Explanation

## Simple Diagram: Class 2 Technical Defense Flow

```text
Class 1: Build and Validate
        |
        v
Class 2: Present and Defend
        |
        v
Business Problem
        |
        v
Architecture
        |
        v
Delivery Workflow
        |
        v
Technical Evidence
        |
        v
Troubleshooting Response
        |
        v
Production Improvements
```

## Step-by-Step Explanation

1. Class 1 prepared the project.
2. Class 2 proves the project can be explained and defended.
3. Students begin with business context.
4. They show architecture and workflow.
5. They provide evidence from repo, CLI, pipeline, and cloud services.
6. They respond to a failure scenario.
7. They explain what would improve in a real enterprise environment.

## Component Meanings

| Component | Meaning |
|---|---|
| Business Problem | Why the project exists |
| Architecture | How major pieces connect |
| Delivery Workflow | How code becomes a running service |
| Technical Evidence | Proof that the workflow works |
| Troubleshooting Response | Proof that student can diagnose failures |
| Production Improvements | Proof that student understands real-world gaps |

## Real-World Enterprise Version

```text
Engineering Leadership Review
        |
        v
Business Need
        |
        v
Architecture Review
        |
        v
Security and IAM Review
        |
        v
Pipeline and Release Review
        |
        v
Operational Readiness Review
        |
        v
Incident and Rollback Readiness
        |
        v
Approval / Improvement Backlog
```

## How Class 2 Extends Class 1

Class 1 answered:

> Is the capstone validated and ready?

Class 2 answers:

> Can the student present, defend, troubleshoot, and explain how this would work in a real organization?

---

# 13. Instructor Demo Script

## Demo Title

**Example DevOps Capstone Presentation and Defense**

## Demo Objective

Model how students should present their capstone clearly and professionally.

## Required Setup

Instructor should have:

- Sample capstone repo
- Sample architecture diagram
- Sample pipeline file
- Sample Dockerfile
- Sample Helm chart
- Sample Terraform files
- kubectl configured
- AWS CLI configured
- Optional EKS and ECR access
- Sample presentation deck

## Step 1: Present the Business Problem

Instructor says:

```text
The business problem is that application deployments are manual, inconsistent, and difficult to roll back. This capstone creates a repeatable DevOps workflow that builds a Docker image, stores it in ECR, deploys to Kubernetes with Helm, validates infrastructure with Terraform, and provides basic monitoring and rollback documentation.
```

Explain:

> Start with why the work matters.

## Step 2: Show Architecture

Display:

```text
Developer → Git → CI/CD → Docker Build → ECR → EKS → CloudWatch
```

Explain each component in one sentence.

## Step 3: Show Repository Structure

Command:

```bash
tree -L 2
```

Expected output:

```text
.
├── README.md
├── app
├── helm
├── terraform
├── docs
├── presentation
└── .gitlab-ci.yml
```

Explain:

> A reviewer should be able to understand the project layout quickly.

Recovery if `tree` is unavailable:

```bash
find . -maxdepth 2 -type f
```

## Step 4: Show Pipeline Flow

Command:

```bash
cat .gitlab-ci.yml
```

Example pipeline structure:

```yaml
stages:
  - validate
  - build
  - package
  - deploy

validate:
  stage: validate
  script:
    - terraform fmt -check
    - terraform validate

docker_build:
  stage: build
  script:
    - docker build -t capstone-app:$CI_COMMIT_SHORT_SHA .

deploy:
  stage: deploy
  script:
    - helm upgrade --install capstone-app ./helm/capstone-app -n capstone
```

Explain:

> This is simplified, but it shows the major delivery stages.

## Step 5: Show AWS Identity

Command:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:role/capstone-deploy-role"
}
```

Explain:

> Before performing AWS actions, always confirm identity and account context.

## Step 6: Show Kubernetes Status

Command:

```bash
kubectl get pods -n capstone
kubectl get svc -n capstone
```

Expected output:

```text
NAME                             READY   STATUS    RESTARTS
capstone-app-abc123              1/1     Running   0
```

Explain:

> This proves the workload is deployed and healthy at a basic level.

## Step 7: Show Helm Release

Command:

```bash
helm list -n capstone
helm history capstone-app -n capstone
```

Expected output:

```text
NAME            NAMESPACE   STATUS
capstone-app    capstone    deployed
```

Explain:

> Helm gives us release tracking and rollback options.

## Step 8: Show Rollback Plan

Command:

```bash
helm rollback capstone-app 1 -n capstone
```

Do not actually run rollback on a shared cluster unless it is safe.

Explain:

> In a real demo, you can show the command and explain when it would be used.

## Step 9: Show Troubleshooting Example

Inject example:

```text
Pod is ImagePullBackOff
```

Investigation commands:

```bash
kubectl describe pod -n capstone <pod-name>
helm get values capstone-app -n capstone
```

Explain:

> The key is to connect symptom to evidence to root cause.

## Common Demo Failure Points

| Failure | Recovery |
|---|---|
| AWS credentials expired | Refresh profile or role credentials |
| Wrong Kubernetes context | Run `kubectl config current-context` and switch context |
| Namespace missing | Create namespace or correct `-n` value |
| Helm release missing | Run `helm list -A` to find release |
| Docker not running | Start Docker Desktop or daemon |
| Terraform not initialized | Run `terraform init` |
| Cloud resource unavailable | Use screenshots or saved command output as backup evidence |

## Cleanup Steps

If demo creates temporary resources:

```bash
kubectl delete ns capstone-demo
docker rmi capstone-app:test
```

Do not delete shared AWS resources unless specifically authorized.

---

# 14. Student Lab Manual

## Lab Title

**Final Capstone Presentation, Defense, and Failure Response**

## Lab Objective

Present your DevOps capstone, defend your design decisions, respond to questions, and troubleshoot a realistic failure scenario.

## Estimated Time

90 to 120 minutes depending on class size

## Student Prerequisites

You must have completed Class 1 preparation:

- Final repository
- README
- Architecture diagram
- Demo plan
- Runbook
- Rollback plan
- Presentation
- Validation evidence
- Troubleshooting notes

## Starting Point From Class 1

You should begin Class 2 with:

```text
A validated capstone project
A prepared presentation
A known demo path
A documented rollback plan
A documented troubleshooting approach
```

## Architecture or Workflow Overview

```text
Business Problem
   ↓
Git Repository
   ↓
CI/CD Pipeline
   ↓
Docker Image
   ↓
Amazon ECR
   ↓
Amazon EKS
   ↓
Helm Release
   ↓
CloudWatch Logs / Metrics
   ↓
Rollback and Runbook
```

## Step 1: Prepare Your Presentation Window

Open:

- Presentation deck
- Git repository
- Terminal
- AWS Console, if needed
- Kubernetes dashboard or CLI, if used
- CloudWatch logs, if used

## Step 2: Present the Business Problem

Use this format:

```text
The problem I solved is:
The team or user impacted is:
The risk of the old process is:
My DevOps workflow improves this by:
```

## Step 3: Present Your Architecture

Show your diagram and explain:

1. Where code starts.
2. How the pipeline runs.
3. Where the Docker image is built.
4. Where the image is stored.
5. Where the app is deployed.
6. Where logs and monitoring are reviewed.
7. How rollback works.

## Step 4: Show Repository Structure

Run:

```bash
find . -maxdepth 2 -type f
```

Expected evidence:

```text
README.md
pipeline file
Dockerfile
Helm chart or Kubernetes YAML
Terraform files
docs/runbook.md
docs/rollback-plan.md
```

## Step 5: Show Pipeline or Pipeline File

Show your GitLab CI or GitHub Actions workflow.

Explain:

```text
This stage validates the code.
This stage builds the image.
This stage pushes the image.
This stage deploys the app.
This stage would be controlled or approved in production.
```

## Step 6: Show Docker or ECR Evidence

Run one or more:

```bash
docker images
aws ecr describe-repositories
aws ecr list-images --repository-name <repo-name>
```

Expected output:

```text
Image tag exists
Repository exists
Image is versioned
```

## Step 7: Show Kubernetes or Helm Evidence

Run:

```bash
kubectl get pods -n capstone
kubectl get svc -n capstone
helm list -n capstone
```

Expected output:

```text
Pod is Running
Service exists
Helm release is deployed
```

## Step 8: Show Terraform-Provisioned Infrastructure

Run:

```bash
terraform fmt -check
terraform validate
terraform plan          # OpenTofu: tofu plan
terraform state list
```

Expected output:

```text
Success! The configuration is valid.
No changes. Your infrastructure matches the configuration.
aws_ecr_repository.app
aws_iam_role.ci_oidc
```

Show the live `plan` (no changes) and `state list` — this proves the infrastructure is provisioned, not just syntactically valid. If you genuinely cannot reach the backend live, show the most recent run output, but a live `plan` is the expected bar.

## Step 9: Show Live Observability

Open your three signals live:

```bash
kubectl logs -n capstone deploy/capstone-app
aws cloudwatch describe-alarms --alarm-names <your-alarm> \
  --query 'MetricAlarms[].[AlarmName,StateValue]' --output table
aws cloudwatch list-dashboards --query 'DashboardEntries[].DashboardName'
```

Then open the dashboard URL and read the SLO status aloud:

```text
SLO: 99.0% of requests < 500ms (7d) — current 99.4%, error budget 60% remaining
```

Explain:

> This is where I look if the app fails — and here is the alert that would page me and the SLO that governs whether I am allowed to ship. Show it live; a saved image does not count.

## Step 10: Explain Rollback

Show one rollback option:

```bash
helm history capstone-app -n capstone
helm rollback capstone-app <revision> -n capstone
```

Or explain Git/image rollback:

```text
Revert to previous image tag
Re-run deploy stage
Validate app health
Communicate status
Document incident
```

## Step 11: Respond to Instructor Questions

Be ready to answer:

- Why did you design the pipeline this way?
- What would fail first?
- How are credentials handled?
- How would you separate dev and prod?
- How would you monitor this?
- How would you roll back?
- How does this map to Azure or GCP?

## Step 12: Complete Failure Response

When assigned a failure, fill out:

```text
Symptom:
Evidence:
Likely layer:
Root cause:
Fix:
Validation:
Prevention:
```

## Step 13: Open-Ended System Design

You will receive a prompt for a system you did **not** build (e.g., "a CI/CD platform for 50 teams"). Work it at the whiteboard using:

```text
Clarify → Requirements & Scale → High-Level Design → Deep Dive →
Tradeoffs → Failure Modes → Observability/SLOs → Cost → Iterate
```

Capture your design notes:

```text
Clarifying questions I asked:
Assumptions (scale, latency, budget, team size):
High-level components:
The one deep-dive I went into:
Two tradeoffs I named:
Top failure mode + mitigation:
SLO I would set:
Rough cost driver:
```

## Step 14: Senior Behavioral STAR Drills

Draft two STAR answers from these dimensions (you will reuse them in Week 25 Class 2):

```text
Dimension (leadership / mentoring / disagreement / incident command):
Situation (1-2 sentences):
Task:
Action (the bulk — what YOU did):
Result (quantified: MTTR, deploy freq, time-to-onboard, $ saved):
```

Prepare at least one of:

- A time you drove a technical decision or owned an ambiguous problem.
- A time you mentored a less-experienced engineer.
- A technical disagreement you handled (bonus: defending a release freeze on an exhausted error budget).
- An incident you led or coordinated (comms, roles, rollback decision, blameless postmortem).

## Validation Checklist

Items marked (show) require demonstrated evidence, not a verbal claim.

| Item | Complete |
|---|---|
| Presented business problem |  |
| Explained architecture and referenced ADRs |  |
| Showed repository |  |
| Explained pipeline (OIDC + gating scan) |  |
| Showed live Docker/ECR image (show) |  |
| Showed live Kubernetes/Helm deployment (show) |  |
| Showed `terraform plan` + `state list` (show) |  |
| Explained IAM and security |  |
| Showed live dashboard + alert + SLO (show) |  |
| Demonstrated rollback (show) |  |
| Completed open-ended system-design exercise |  |
| Delivered 2 STAR behavioral answers |  |
| Answered technical questions |  |
| Completed troubleshooting response |  |
| Submitted final deliverables |  |

## Troubleshooting Tips

- Start with the symptom, not the tool.
- Confirm AWS identity before debugging permissions.
- Confirm Kubernetes namespace before checking resources.
- Use `kubectl describe` for pod scheduling or image pull issues.
- Use `kubectl logs` for application startup issues.
- Use `helm get values` for image tag and environment configuration.
- Use `terraform validate` for syntax and variable issues.

## Cleanup Steps

Only clean up temporary local or demo resources.

Local cleanup:

```bash
docker ps
docker images
docker rmi capstone-app:test
```

Temporary Kubernetes cleanup, if instructed:

```bash
kubectl delete ns capstone-demo
```

Do not delete:

- Shared EKS cluster
- Shared ECR repository
- Shared IAM roles
- Terraform backend
- Other students’ resources

## Reflection Questions

1. What was your strongest technical decision?
2. What part of your project would need improvement before production?
3. What did you learn from the troubleshooting scenario?
4. What would you automate next?
5. How would you explain this project in an interview?

## Optional Challenge Task

Create a final `portfolio-summary.md` file:

```markdown
# DevOps Capstone Portfolio Summary

## Problem Solved

## Architecture

## Tools Used

## AWS Services Used

## What I Built

## What I Troubleshot

## Security Considerations (OIDC, scanning, secrets)

## Monitoring, SLOs, and Rollback

## Quantified Impact (deploy frequency, MTTR, cost saved)

## Key Decisions (link to ADRs)

## What I Would Improve Next
```

---

# 15. Troubleshooting Activity

## Incident Title

**Final Review Failure Injection: Deployment Workflow Breaks During Demo**

## Business Impact

The DevOps team is presenting a new delivery workflow to engineering leadership. During the review, one part of the workflow fails. The student must show they can troubleshoot calmly, isolate the issue, and explain how the failure would be handled in production.

## Symptoms

Instructor assigns one of the following:

1. Pipeline deploy stage fails.
2. ECR image push fails.
3. EKS pod shows `ImagePullBackOff`.
4. Pod shows `CrashLoopBackOff`.
5. Service is unreachable.
6. Helm release fails.
7. Terraform validation fails.
8. CloudWatch logs are missing.

## Starting Evidence

### Example A: Wrong Image Tag

```text
Warning  Failed  kubelet  Failed to pull image "123456789012.dkr.ecr.us-east-1.amazonaws.com/capstone-app:v9"
```

### Example B: Missing Environment Variable

```text
Error: required environment variable APP_PORT is not set
```

### Example C: Helm Template Failure

```text
Error: template: capstone-app/templates/deployment.yaml: nil pointer evaluating interface {}.repository
```

### Example D: IAM Failure

```text
An error occurred (AccessDeniedException) when calling the PutImage operation:
User is not authorized to perform: ecr:PutImage
```

### Example E: Terraform Failure

```text
Error: Missing required argument
The argument "region" is required, but no definition was found.
```

## Student Investigation Steps

Students should use this method:

```text
1. Identify the symptom
2. Identify the failing layer
3. Gather evidence
4. Confirm root cause
5. Apply or explain fix
6. Validate recovery
7. Explain prevention
```

Useful commands:

```bash
aws sts get-caller-identity
aws ecr describe-repositories
aws ecr list-images --repository-name <repo-name>

kubectl get pods -n capstone
kubectl describe pod -n capstone <pod-name>
kubectl logs -n capstone <pod-name>
kubectl get svc -n capstone

helm list -n capstone
helm status capstone-app -n capstone
helm get values capstone-app -n capstone
helm template capstone-app helm/capstone-app --debug

terraform fmt -check
terraform validate
terraform plan
```

## Expected Root Cause

The root cause depends on the injected issue.

| Symptom | Likely Root Cause |
|---|---|
| `ImagePullBackOff` | Wrong image tag, missing ECR auth, or image not pushed |
| `CrashLoopBackOff` | Missing environment variable, bad command, or app startup failure |
| Service unreachable | Service selector or target port mismatch |
| ECR access denied | Missing IAM permission |
| Helm template error | Missing value or bad template reference |
| Terraform error | Missing variable, backend issue, or provider config issue |
| Logs missing | Logging not configured or wrong log group checked |

## Correct Resolution

Example resolution for wrong image tag:

```bash
helm get values capstone-app -n capstone
aws ecr list-images --repository-name capstone-app
```

Correct `values.yaml`:

```yaml
image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/capstone-app
  tag: v1.0.0
```

Apply:

```bash
helm upgrade capstone-app helm/capstone-app -n capstone
kubectl get pods -n capstone
```

## Common Wrong Paths

Students may:

- Restart everything without reading the error.
- Change the Dockerfile when the issue is a Helm value.
- Blame Kubernetes when the image was never pushed.
- Use admin permissions instead of correcting least privilege.
- Check the wrong namespace.
- Delete resources during a demo.
- Ignore logs.
- Skip validation after applying a fix.

## Instructor Hints

Use these in order:

1. “What layer is failing?”
2. “What command gives you evidence?”
3. “Is the image tag in Kubernetes the same tag that exists in ECR?”
4. “Are you in the correct namespace?”
5. “What identity is your AWS CLI using?”
6. “What would you document so this does not happen again?”

## Preventive Action

Students should recommend:

- Versioned image tags
- Pipeline-passed image tag values
- Helm lint and template checks
- Terraform validation before apply
- Least-privilege IAM policy review
- Pre-demo validation checklist
- CloudWatch log verification
- Rollback documentation
- Environment-specific values files

---

# 16. Scenario-Based Discussion Questions

## Question 1

**Which controls should a senior-track capstone include outright, and which are fair to defer as larger-system work?**

Expected response themes:

- Baseline (must be in it): OIDC keyless CI, a gating security scan, one real alert + SLO, IaC-provisioned infra, rollback.
- Fair to defer: multi-account/landing zone, approval/change management, DR/multi-region, centralized audit.
- Do not claim controls you did not implement — interviewers probe exactly those.

Follow-up:

> Of the baseline controls, which did you implement, and how did you demonstrate it?

## Question 2

**How should a DevOps engineer respond when a live demo fails?**

Expected response themes:

- Stay calm.
- Identify the failing layer.
- Gather evidence.
- Explain thought process.
- Avoid random changes.
- Document root cause and prevention.

Follow-up:

> What behavior would reduce confidence during an incident?

## Question 3

**Why is IAM design important in a CI/CD workflow?**

Expected response themes:

- Pipelines can change production.
- Permissions should be least privilege.
- Static keys are risky.
- Role-based temporary access is safer.

Follow-up:

> How would OIDC improve this design?

## Question 4

**What is the difference between a rollback plan and a troubleshooting guide?**

Expected response themes:

- Rollback restores service to a known good state.
- Troubleshooting investigates root cause.
- During an outage, rollback may happen before full root cause analysis.

Follow-up:

> When would you rollback instead of continuing to debug?

## Question 5

**What evidence would convince leadership that your delivery workflow is reliable?**

Expected response themes:

- Successful pipeline runs
- Repeatable deployments
- Monitoring evidence
- Rollback plan
- Clear documentation
- Test results
- Failure response

Follow-up:

> What evidence matters most to operations teams?

## Question 6

**How would the solution change if the company required separate dev, staging, and production environments?**

Expected response themes:

- Separate namespaces or clusters
- Separate AWS accounts
- Separate Helm values
- Approval gates
- Different IAM roles
- Promotion process

Follow-up:

> What should be shared and what should be separated?

## Question 7

**How does your AWS-based workflow map to Azure or GCP?**

Expected response themes:

- ECR maps to ACR or Artifact Registry.
- EKS maps to AKS or GKE.
- CloudWatch maps to Azure Monitor or Cloud Monitoring.
- IAM maps to Azure RBAC or Cloud IAM.
- Terraform remains similar with different providers.

Follow-up:

> What part of your workflow is most portable across clouds?

## Question 8

**You are asked to design a CI/CD platform for 50 teams (a system you have not built). What do you do in the first two minutes?**

Expected response themes:

- Ask clarifying questions before drawing: scale, deploy frequency, compliance, existing tooling, budget.
- State assumptions explicitly.
- Sketch a high-level design, then pick one area to deep-dive.
- Name tradeoffs (self-service vs guardrails, shared vs isolated runners).

Follow-up:

> Where would reliability/SLOs and cost enter your design?

## Question 9

**Tell me about a time you disagreed with a teammate or stakeholder on a technical decision. (Behavioral)**

Expected response themes:

- STAR structure with a short Situation and a substantive Action.
- Professional handling: data over ego, "disagree and commit" if overruled.
- A real tradeoff (e.g., release freeze vs ship under an exhausted error budget).
- A quantified or concrete Result.

Follow-up:

> What would you do differently, and how did the relationship hold up afterward?

## Question 10

**Describe an incident you led or coordinated. (Behavioral)**

Expected response themes:

- Clear comms and role assignment (incident commander, scribe, comms).
- Decision to mitigate/rollback before full root cause.
- Blameless postmortem and a concrete prevention action.

Follow-up:

> What was the MTTR, and what did the postmortem change?

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the best opening for a DevOps capstone presentation?

A. “I used Docker and Kubernetes.”  
B. “The business problem was manual, inconsistent deployments, so I built a repeatable delivery workflow.”  
C. “My YAML file is working.”  
D. “I used AWS because it is popular.”  

**Answer:** B  
**Explanation:** A strong presentation starts with the problem and business value.

## Question 2: True or False

A capstone can be considered production-ready just because the app runs once.

**Answer:** False  
**Explanation:** Production readiness also requires repeatability, security, monitoring, rollback, documentation, and support readiness.

## Question 3: Multiple Choice

Which command is most useful when diagnosing why a Kubernetes pod cannot pull an image?

A. `terraform fmt`  
B. `kubectl describe pod <pod-name> -n <namespace>`  
C. `git status`  
D. `aws s3 ls`  

**Answer:** B  
**Explanation:** `kubectl describe pod` shows events such as image pull failures and registry errors.

## Question 4: Short Answer

How does Class 2 build on Class 1?

**Answer:** Class 1 validates and prepares the capstone. Class 2 presents, defends, troubleshoots, and submits it.  
**Explanation:** Class 2 turns preparation into a professional technical review.

## Question 5: Multiple Choice

What AWS service is used to store Docker images for this capstone workflow?

A. CloudWatch  
B. ECR  
C. IAM  
D. Route 53  

**Answer:** B  
**Explanation:** Amazon ECR stores container images.

## Question 6: True or False

During a failure injection, students should immediately change multiple files until something works.

**Answer:** False  
**Explanation:** Students should gather evidence, isolate the failing layer, identify root cause, then apply a targeted fix.

## Question 7: Short Answer

Name two things a student should include in a rollback explanation.

**Answer:** Previous image tag, Helm rollback command, Git revert, pipeline redeploy, validation steps, and communication plan are all valid.  
**Explanation:** Rollback needs clear recovery steps and validation.

## Question 8: Multiple Choice

Which Azure and GCP services are closest to Amazon EKS?

A. Azure Blob Storage and Cloud Storage  
B. Azure Kubernetes Service and Google Kubernetes Engine  
C. Azure Monitor and Cloud Monitoring  
D. Azure Functions and Cloud Functions  

**Answer:** B  
**Explanation:** AKS and GKE are managed Kubernetes services like EKS.

## Question 9: Short Answer

What does evidence-based review mean?

**Answer:** It means using command outputs, logs, screenshots, repo files, diagrams, or pipeline runs to prove that the work functions as described.  
**Explanation:** Technical reviewers need proof, not just claims.

## Question 10: Multiple Choice

A pipeline fails while pushing to ECR with `AccessDeniedException`. What is the most likely issue?

A. Wrong Kubernetes namespace  
B. Missing IAM permission  
C. Bad Helm chart indentation  
D. Missing README  

**Answer:** B  
**Explanation:** ECR access denied errors usually indicate missing or incorrect IAM permissions.

## Question 11: Short Answer

What is one enterprise improvement students could add after the capstone?

**Answer:** OIDC authentication, approval gates, security scanning, environment separation, CloudWatch alarms, Secrets Manager, cost controls, or automated rollback.  
**Explanation:** These make the workflow closer to real production standards.

## Question 12: True or False

The workflow pattern Git → CI/CD → Registry → Kubernetes → Monitoring exists across AWS, Azure, and GCP.

**Answer:** True  
**Explanation:** The services differ, but the delivery pattern is cloud-portable.

---

# 18. Homework Assignment

## Assignment Title

**Final Capstone Submission and Portfolio Summary**

## Scenario

You have presented your DevOps capstone to an engineering review panel. Now you must submit the final project package and write a short portfolio summary that explains the project in a way suitable for interviews, LinkedIn, or a resume discussion.

## Student Tasks

Submit:

1. Final Git repository link.
2. Final README.
3. Architecture diagram.
4. CI/CD pipeline file.
5. Dockerfile.
6. Helm chart or Kubernetes manifests.
7. Terraform files.
8. Runbook.
9. Rollback plan.
10. Troubleshooting notes.
11. CloudWatch or log evidence.
12. Final presentation.
13. Portfolio summary.
14. Optional (awareness only, not graded): Azure/GCP mapping notes.

## Expected Deliverables

```text
README.md
architecture/
app/
helm/
terraform/
docs/runbook.md
docs/rollback-plan.md
docs/troubleshooting-notes.md
docs/production-readiness-review.md
docs/cost-estimate.md
docs/adr/
docs/multi-cloud-awareness.md   # OPTIONAL: awareness only, not graded
presentation/
portfolio-summary.md
```

## Submission Format

Students submit:

- Git repository URL
- Final presentation file or link
- `portfolio-summary.md`
- Any required screenshots or command outputs

## Estimated Completion Time

2 to 3 hours

## Grading Criteria

Grading is **evidence-first**: capabilities must be *shown* (output, URL, resource ID), not described.

| Criteria | Weight |
|---|---:|
| Presentation clarity (problem-first, ADR-referenced) | 15% |
| Live deployment shown: Docker/ECR + Kubernetes/Helm | 15% |
| CI/CD: OIDC keyless + gating scan (shown) | 10% |
| Terraform/OpenTofu provisioned: `plan` + `state list` | 10% |
| Live observability: dashboard + alert + SLO | 10% |
| Open-ended system-design exercise | 10% |
| Senior behavioral STAR answers (2) | 10% |
| Troubleshooting response | 10% |
| Documentation, ADRs, and portfolio summary | 10% |

## Optional Advanced Challenge

Add one final improvement backlog section:

```markdown
## Future Improvements

| Priority | Improvement | Reason | Expected Benefit |
|---|---|---|---|
| High | Add OIDC authentication | Avoid static AWS keys | Improved security |
| High | Add security scanning | Catch vulnerabilities early | Safer releases |
| Medium | Add approval gates | Protect production | Reduced deployment risk |
```

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Starting with tools instead of business problem | Students are proud of the tools they used | Start with the problem and why the workflow matters |
| Showing too many commands with no story | Students confuse demo with presentation | Use a clear flow: problem, architecture, evidence, tradeoffs |
| Not explaining tradeoffs | Students think only the final answer matters | Ask “why this design?” and “what would you improve?” |
| Freezing during troubleshooting | Students fear live failure | Use structured troubleshooting: symptom, layer, evidence, fix |
| Ignoring IAM | Students focus on app deployment | Ask what identity the pipeline uses and what permissions it needs |
| No clear rollback explanation | Students assume redeploy is enough | Require specific rollback steps |
| Weak monitoring explanation | Students show app running but not operable | Include logs, metrics, or CloudWatch evidence |
| Overclaiming production readiness | Students want to sound confident | Teach honest limitations and future improvements |
| Not mapping to Azure/GCP | Students forget comparison requirement | Include a short mapping slide |
| Running risky cleanup commands | Students panic during demo | Do not delete shared resources without approval |

---

# 20. Real-World Enterprise Scenario

## Scenario

A company’s application teams currently deploy manually through inconsistent scripts. Deployments depend on individual engineers, rollback is unclear, and production troubleshooting takes too long because logs and deployment history are not easy to find.

The DevOps team builds a standard delivery workflow and presents it to engineering leadership.

## Constraints

- Production deployments require auditability.
- Cloud access must follow least privilege.
- Images must be stored in an approved registry.
- Deployments must be repeatable.
- Rollback must be documented.
- Monitoring must be available after release.
- Costs must be controlled in non-production environments.
- The design should eventually support dev, staging, and production.
- Security team will review credentials and image scanning.
- Operations team needs runbooks.

## How the Class Topic Applies

Class 2 simulates the review where DevOps engineers present the workflow, answer questions, and demonstrate readiness.

## What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Present pipeline, deployment workflow, rollback, and automation |
| Cloud Engineer | Validate AWS architecture, IAM, ECR, EKS, and environment design |
| SRE | Challenge monitoring, incident response, reliability, and runbook quality |
| Security Reviewer | Ask about credentials, permissions, secrets, and scanning |
| Engineering Manager | Ask about repeatability, risk, supportability, and next steps |

---

# 21. Instructor Tips

## Teaching Tips

- Keep the focus on communication and technical defense.
- Encourage students to explain why, not only what.
- Ask realistic review questions.
- Praise honest limitations when students also explain improvements.
- Remind students that troubleshooting behavior matters as much as the final fix.

## Pacing Tips

- Use strict presentation time boxes.
- Keep instructor demo short.
- Do not allow one student’s issue to consume the entire class.
- Use group feedback if the class is large.
- Reserve time for final submission instructions.

## Lab Support Tips

During student presentations, track:

- Did they explain the problem?
- Did they show architecture?
- Did they show evidence?
- Did they explain rollback?
- Did they handle questions clearly?
- Did they connect the project to enterprise use?

## How to Help Struggling Students

Allow struggling students to present a simplified but clear version:

- Problem
- Architecture
- Repo
- One working demo
- Rollback plan
- Known limitations
- What they would improve

Do not force them into live commands if screenshots or saved output are more stable.

## How to Challenge Advanced Students

Ask advanced students:

- How would you implement OIDC?
- How would you separate dev, staging, and prod?
- How would you add security scanning?
- How would you handle failed production release communication?
- How would you reduce deployment blast radius?
- How would you support multiple application teams?

---

# 22. Student Outcome Checklist

## Students Should Be Able to Explain

- Business problem solved by the capstone
- End-to-end DevOps workflow
- Pipeline stages and purpose
- Docker and ECR relationship
- Kubernetes and Helm deployment flow
- Terraform usage
- IAM and security considerations
- CloudWatch or logging approach
- Rollback strategy
- Known limitations and which baseline controls were implemented vs deferred
- How they would approach an open-ended system-design prompt (clarify → design → tradeoffs → reliability → cost)
- Two STAR behavioral stories (leadership/mentoring/disagreement/incident command)
- Quantified impact (deploy frequency, MTTR, cost) of their work

## Students Should Be Able to Build or Configure

- Final repository package
- Presentation deck
- Documentation set
- Pipeline file
- Dockerfile
- Helm chart or Kubernetes manifests
- Terraform files
- Runbook
- Rollback plan
- Troubleshooting notes
- Portfolio summary

## Students Should Be Able to Troubleshoot

- ECR authentication failures
- Image tag mismatch
- Kubernetes pod failures
- Helm values problems
- Terraform validation errors
- IAM access denied errors
- Missing logs
- Wrong namespace or cluster context
- Failed pipeline stages

---

# 23. Class Completion Checklist

## Instructor Checklist Before Ending Class

Confirm:

- Students presented their capstone or scheduled final presentation completion.
- Students answered technical questions.
- Students completed or participated in troubleshooting injection.
- Students understand final submission requirements.
- Students know what artifacts must be in the repo.
- Students understand how to discuss the project in interviews.
- Students know the difference between portfolio-ready and production-ready.

## Student Checklist Before Leaving Class

| Item | Complete |
|---|---|
| Final presentation delivered or rehearsed |  |
| Instructor questions answered |  |
| Troubleshooting scenario completed |  |
| Final repo ready |  |
| README complete |  |
| Architecture diagram included |  |
| Pipeline file included |  |
| Dockerfile included |  |
| Helm or Kubernetes files included |  |
| Terraform files included |  |
| Runbook included |  |
| Rollback plan included |  |
| CloudWatch/log evidence included |  |
| Portfolio summary drafted |  |
| Azure/GCP mapping (optional, awareness only) |  |

## Items to Verify Before Closing the Week

Students should have a final capstone that includes:

```text
Git repository
CI/CD workflow
Docker image workflow
ECR or registry evidence
Kubernetes or EKS deployment evidence
Helm or manifest deployment approach
Terraform `plan` + `state list` evidence (provisioned, not just valid)
IAM and security explanation
Monitoring/logging evidence
Rollback plan
Runbook
Troubleshooting notes
Presentation
Portfolio summary
Azure/GCP comparison (optional, awareness only)
```

---

# 24. End-of-Week Summary

## What Students Learned This Week

Students learned how to finalize, validate, present, and defend a DevOps capstone project. They practiced moving beyond “I built something” into “I can explain, operate, troubleshoot, and improve this delivery workflow.”

## How Class 1 and Class 2 Connect

Class 1 focused on:

- Final validation
- Documentation
- Demo readiness
- Pre-presentation troubleshooting

Class 2 focused on:

- Presentation
- Technical defense
- Failure response
- Final submission
- Portfolio readiness

Together, both classes simulate a real enterprise review process.

## How This Week Prepares Students for the Next Step

This is the capstone finalization week of the unified track. Students now have a senior-grade artifact — IaC-provisioned, instrumented with live SLOs/alerts, secured with OIDC and a gating scan, and ADR-backed — plus rehearsed open-ended system-design and senior behavioral answers. Week 25 (Resume & Interview Prep) turns this into resume bullets, interview stories, and final loop practice.

They can explain:

- CI/CD workflow design
- Container build and registry usage
- Kubernetes deployment
- Helm release management
- Terraform infrastructure validation
- IAM and security awareness
- Monitoring and rollback readiness
- Troubleshooting approach

## What Students Should Review After This Module

Students should review:

1. Their final project README.
2. Their architecture diagram.
3. Their pipeline file.
4. Their Dockerfile.
5. Their Helm chart or Kubernetes manifests.
6. Their Terraform code.
7. Their IAM explanation.
8. Their CloudWatch or logging evidence.
9. Their rollback plan.
10. Their troubleshooting notes.
11. Their portfolio summary.
12. Their Azure/GCP mapping (optional, awareness only).

Final reminder for students:

> Be ready to explain not just what you built, but why you built it that way, how it fails, how you recover, and what you would improve next.

---

## Class Artifacts & Validation

This presentation/defense class **reuses** the same backing `labs/capstone` module as
Class 1 — it does not produce new code. The artifacts below are the ones a student
actually *presents and defends* in this class: the architecture they walk, the ADRs
they justify, the PRR checklist they answer questions against, the runbook for the
operability defense, the assignment brief they present from, and the reference checker
that proves the capstone **integrates** the seven prior modules rather than forking
them. All paths are relative to the repo root and were verified to exist; static gates
were **run in this environment**.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/capstone/architecture/architecture.mmd | mermaid | Full-system diagram the student walks in the presentation; every box maps to one course module | render at <https://mermaid.live> / `mmdc -i architecture.mmd -o architecture.svg` | DEFERRED — renders where `mmdc` is available (not installed in this build env); box→module mapping verified by artifact #6 |
| 2 | labs/capstone/adr/0001-record-architecture-decisions.md | markdown ADR | "Adopt ADRs" decision the student defends in the technical-defense Q&A | manual review against `starter/adr/NNNN-template.md` | PASS — present, follows template |
| 3 | labs/capstone/adr/0002-managed-vs-self-hosted.md | markdown ADR | Managed-vs-self-hosted trade-off (names the rejected option + "revisit when…") — the core "defend your decision" artifact | manual review | PASS — present, records a real trade-off |
| 4 | labs/capstone/production-readiness-checklist.md | markdown | Go/no-go PRR the instructor walks row-by-row demanding demonstrated evidence | manual review — every `[x]` resolves to a real file; gaps left `[ ]` | PASS — present, evidence-linked |
| 5 | labs/capstone/runbook.md | markdown | On-call runbook (≥4 alert→action playbooks) backing the failure-scenario and operability defense | manual review | PASS — present, ≥4 runnable playbooks |
| 6 | labs/capstone/tests/check_references.sh | bash | Reference checker — the "no fork, real integration" proof a defender must be able to run | `bash labs/capstone/tests/check_references.sh` | PASS — `22 found, 0 missing`, exit 0 |
| 7 | labs/capstone/starter/capstone-brief.md | markdown | The graded assignment brief the student presents and submits against | manual review (acceptance checks enumerated) | PASS — present |
| 8 | labs/capstone/validate.sh | bash | Whole-module gate suite the student re-runs to prove the deliverables still validate before submission | `cd labs/capstone && ./validate.sh` | PASS — `7 passed, 0 failed, 0 deferred`, exit 0 |

> **Live-evidence note (honest):** The grading bar for this class is **evidence-first**:
> the student must *show* a live deployment, a live dashboard/alert/SLO, a `terraform
> plan` (no changes) + `state list`, and a demonstrated rollback on **their own**
> capstone. Those live signals are **not** committed to this repo — there is no
> `LIVE-AWS-VALIDATION.txt` / `LIVE-*EVIDENCE*.txt`. What this repo ships and what was
> validated here is **static**: the integration documents above plus a local
> `docker compose` demo (`validate.sh` 7/7; `curl /healthz` → `{"status": "ok"}`,
> captured in `labs/capstone/README.md`). Do not read the presentation rubric's "live"
> language as live evidence shipped in the course material.

## Definition of Done

Ticked honestly for this class against the backing `labs/capstone` module. This is a
**presentation/defense** class (per §4, a discussion class is exempt from *new*
runnable code but must ship concrete reusable artifacts — rubrics, question banks,
templates — which it does, plus it reuses the validated module).

- [x] Every technology taught ships at least one **runnable file on disk** — reused from `labs/capstone` (compose stack, validator, reference checker), not new fences.
- [x] Each artifact passes (or documents) its **validation gate**; output captured (`validate.sh` 7/7; reference checker `22 found, 0 missing`).
- [ ] Lab has **starter** and **solution** versions. *Partial:* `starter/capstone-brief.md` + `starter/adr/NNNN-template.md` exist; there is **no `solution/` tree** by design — the committed integration docs are the reference (README §Instructor answer key).
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent (`docker compose ... down -v`; cloud profile plan-only, `terraform destroy` documented).
- [x] **Instructor answer key** exists — README §Instructor answer key + this class's grading rubric, question banks, and expected response themes (Sections 14–16) are real, ticked artifacts.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the dangling-reference detector (`check_references.sh` gate 3) plus this class's injected live-demo failure scenario.
- [x] **Expected outputs** are shown for the reused demo/lab and for the presentation/defense evidence rows.
- [x] **Cost & security warnings** present (local demo $0; cloud plan-only with destroy guidance; non-root/`read_only` hardening; no secrets committed).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (closes the W16/W21 loop; feeds Week 25; verified by the reference checker).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves.
- [ ] **Live operation evidence** (live deploy/alert/rollback, AWS apply/destroy) committed in-repo. *Not met:* the live signals are produced by the student during the defense, not shipped as evidence. This caps the week's score.

