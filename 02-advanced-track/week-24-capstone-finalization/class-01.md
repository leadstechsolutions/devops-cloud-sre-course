# Week 24: Capstone Finalization — Production Readiness and Architecture
> **▶ Runnable lab for this class:** [`labs/capstone/`](../../labs/capstone/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package: Capstone Finalization: Production Readiness and Architecture

**Week:** 24
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 1: Finalizing the DevOps Capstone for Production-Style Review**

## Class Purpose

This class helps students complete the final technical polish of their DevOps capstone before the final presentation. The focus is not to redesign the project, but to validate that the project works end to end, is documented clearly, and can be explained in a professional technical review.

Students will review their Git repository, CI/CD pipeline, Docker image workflow, ECR integration, Kubernetes or EKS deployment, Helm release, Terraform validation, IAM assumptions, CloudWatch evidence, rollback plan, and presentation flow.

## How This Class Connects to the Overall Course

This class is the final preparation step before students present their capstone. It connects the major skills learned throughout the unified DevOps · Cloud · SRE track:

- Git workflow from Week 3
- AWS cloud foundations, networking, security, and IAM from Weeks 4 to 7
- Bash and Python automation from Week 8
- CI/CD fundamentals from Week 9
- Docker and containers from Week 10
- Kubernetes fundamentals and troubleshooting from Weeks 11 and 12
- Helm from Week 13
- Terraform foundations and enterprise workflows from Weeks 14 and 15
- Observability and reliability from Week 16
- Landing zones, cost optimization, and cloud operations from Weeks 17 and 18
- DevSecOps and secure delivery from Week 19
- Platform engineering and golden paths from Week 20
- SRE foundations (SLI/SLO/error budgets/incidents) from Week 21
- Performance, capacity, and scalability from Week 22
- Capstone build from Week 23 (the project you finalize today)

## What Students Will Build, Analyze, or Practice

Students will:

- Validate their capstone repository structure.
- Run final checks on their pipeline, Docker build, Helm chart, Terraform files, and Kubernetes deployment.
- Confirm AWS service integration with ECR, EKS, IAM, and CloudWatch.
- Prepare their technical presentation and demo path.
- Practice explaining tradeoffs, rollback strategy, and operational readiness.
- Troubleshoot one final pre-presentation failure scenario.

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Validate** an end-to-end DevOps capstone workflow from Git commit to a *live, deployed* Kubernetes workload — confirming real artifacts, not notes that describe them.
2. **Provision** infrastructure with `terraform plan`/`apply` (or OpenTofu) and prove it with real resource IDs and state, not just `terraform validate`.
3. **Demonstrate** observability against live signals: at least one working dashboard, one alert rule (firing or cleared), and one SLO status — not screenshots-as-checkbox.
4. **Author** a set of Architecture Decision Records (ADRs) that capture the real decisions, options considered, and tradeoffs behind the capstone.
5. **Execute** a structured production-readiness review (PRR) against a checklist that requires *demonstrated* evidence for security, reliability, operability, and cost.
6. **Troubleshoot** common final-demo failures related to Docker, ECR, Helm, Kubernetes, Terraform, or IAM using the evidence-first method (symptom → evidence → root cause → fix → validate).
7. **Defend** DevOps tradeoffs related to automation, keyless CI (OIDC), security scanning, repeatability, monitoring, and rollback.
8. **Identify** the highest-priority gaps before the capstone presentation and rank them by risk.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Git repositories, branches, commits, and pull or merge requests
- CI/CD pipeline stages
- Docker images and Dockerfiles
- Container registries
- Kubernetes deployments, services, pods, and namespaces
- Helm charts, releases, values files, upgrades, and rollbacks
- Terraform plan, apply, validate, variables, and modules
- AWS IAM roles and permissions
- CloudWatch logs and basic metrics
- Basic incident troubleshooting flow

## Required Tools Already Installed

Students should have:

- VS Code
- Git
- Docker
- kubectl
- Helm
- Terraform
- AWS CLI
- GitLab CLI or GitHub CLI, optional
- Access to GitLab or GitHub
- Terminal or shell environment

## Required Accounts or Access

Students should have access to at least one of the following:

- AWS account with lab permissions
- ECR repository or ability to create one
- EKS cluster or shared classroom cluster
- IAM role or credentials for pipeline deployment
- CloudWatch logs access
- GitLab or GitHub repository

## Required Files, Repos, or Sample Code

Students should have their capstone repository ready.

Recommended repo structure:

```text
final-capstone/
├── README.md
├── app/
│   ├── Dockerfile
│   └── src/
├── helm/
│   └── capstone-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── environments/
├── .github/
│   └── workflows/
│       └── deploy.yml            # GitHub Actions; OIDC keyless auth, no static keys
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

> 2026 note: `.github/workflows/deploy.yml` (GitHub Actions) is the primary path. If a cohort still uses GitLab CI, the equivalent file is `.gitlab-ci.yml` — the stages and OIDC pattern map one to one.

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Capstone | Final project that proves students can apply multiple course skills together | Similar to a portfolio project or internal engineering proof-of-concept |
| CI/CD | Automated process for building, testing, and deploying code | Used by DevOps teams to reduce manual deployment risk |
| Pipeline | A sequence of automated stages such as validate, build, test, package, and deploy | Enterprise teams use pipelines to standardize delivery |
| Docker Image | A packaged application with dependencies | Allows the same app to run consistently across environments |
| Amazon ECR | AWS container image registry | Stores versioned Docker images for EKS deployments |
| Amazon EKS | AWS managed Kubernetes service | Used to run containerized workloads in production |
| Helm | Kubernetes package manager | Helps deploy applications with reusable charts and environment values |
| Terraform | Infrastructure as Code tool | Used to provision AWS infrastructure through version-controlled code |
| IAM | AWS identity and access management service | Controls who or what can deploy, read, or modify cloud resources |
| CloudWatch | AWS monitoring and logging service | Helps teams inspect application logs, alarms, and metrics |
| Rollback | Returning to a previous working version | Critical during failed production releases |
| Runbook | Step-by-step operational guide | Used by support, DevOps, and SRE teams during incidents |
| Architecture Diagram | Visual representation of system components and flow | Helps teams explain design, dependencies, and failure points |
| Production-Style Review | Technical review that checks readiness, security, repeatability, and operations | Similar to architecture review or production readiness review |
| ADR (Architecture Decision Record) | A short, dated, immutable record of one significant decision: context, options considered, the choice, and consequences | Senior teams keep `docs/adr/` in-repo so future engineers know *why*, not just *what* |
| Production Readiness Review (PRR) | A gated checklist run before a service is allowed to take production traffic, requiring demonstrated evidence | Google SRE and most platform teams run a PRR before go-live |
| SLO / Error Budget | Service Level Objective (target reliability) and the budget of allowed failure derived from it | Drives release decisions and the freeze/ship conversation (Week 21) |
| OIDC Keyless Auth | CI authenticates to the cloud with a short-lived federated token instead of long-lived access keys | GitHub Actions → AWS IAM role via OIDC; the 2026 default for CI credentials |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Version control for app code, Terraform, Helm charts, and documentation |
| GitLab CI or GitHub Actions | Automates build, test, image push, and deployment stages |
| Docker | Builds and runs the containerized application |
| Amazon ECR | Stores Docker images for deployment to Kubernetes |
| kubectl | Validates Kubernetes resources and troubleshoots workloads |
| Helm | Deploys and manages Kubernetes application releases |
| Terraform | Validates and manages infrastructure as code |
| AWS CLI | Confirms AWS identity, ECR, EKS, and account access |
| CloudWatch | Reviews logs and monitoring evidence |
| VS Code | Edits code, YAML, Terraform, Markdown, and docs |
| Presentation tool | Used to explain the final design and demo flow |

---

# 6. AWS Services Used

| AWS Service | How It Connects to Class |
|---|---|
| Amazon ECR | Stores the Docker image built by the pipeline |
| Amazon EKS | Hosts the Kubernetes workload |
| IAM | Provides access control for students, pipelines, ECR, EKS, and CloudWatch |
| CloudWatch Logs | Stores application, container, or cluster logs |
| CloudWatch Metrics | Provides basic operational visibility |
| STS | Used to validate AWS identity with `aws sts get-caller-identity` |
| S3, optional | May be used for Terraform state backend or artifacts |
| DynamoDB, optional | May be used for Terraform state locking |

---

# 7. Azure and GCP Comparison Notes

This is **awareness only and not a graded deliverable.** The course teaches AWS; do not require students to produce a deep multi-cloud mapping for a cloud they never used. The single transferable idea below is enough. Spend at most two minutes here.

| AWS Component | Azure Equivalent | GCP Equivalent |
|---|---|---|
| ECR | Azure Container Registry | Artifact Registry |
| EKS | Azure Kubernetes Service | Google Kubernetes Engine |
| IAM | Microsoft Entra ID and Azure RBAC | Cloud IAM |
| CloudWatch | Azure Monitor | Cloud Monitoring |
| Terraform AWS Provider | AzureRM Provider | Google Provider |

Instructor note:

Students should be able to explain that the same DevOps pattern exists across clouds:

```text
Git → CI/CD → Container Image → Registry → Kubernetes → Monitoring → Rollback
```

The specific services change, but the delivery workflow remains similar.

---

# 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Welcome, class purpose, final capstone expectations |
| 0:10 to 0:25 | Review required capstone components and grading focus |
| 0:25 to 0:45 | Key concepts: production-style DevOps review |
| 0:45 to 1:05 | Whiteboard: end-to-end capstone delivery workflow |
| 1:05 to 1:30 | Instructor demo: final validation workflow |
| 1:30 to 1:40 | Break |
| 1:40 to 2:25 | Student lab: final capstone polish and demo dry run |
| 2:25 to 2:45 | Troubleshooting activity: final pre-presentation failure |
| 2:45 to 2:55 | Peer review and discussion |
| 2:55 to 3:00 | Recap, homework, and Class 2 readiness checklist |

---

# 9. Instructor Lesson Plan

## Step 1: Open the Class

Explain:

> Today is not about adding major new features. Today is about proving your capstone is clear, repeatable, documented, and ready to present.

Remind students that a strong capstone is not judged only by whether the app runs once. It is judged by:

- Repeatability
- Automation
- Documentation
- Security awareness
- Troubleshooting readiness
- Monitoring visibility
- Ability to explain decisions

Pause for questions:

Ask students:

> What part of your capstone are you least confident about presenting?

## Step 2: Review Capstone Requirements

Show the required components:

```text
Git repository
CI/CD pipeline
Dockerfile
Container registry workflow
Kubernetes or EKS deployment
Helm chart or manifests
Terraform code
IAM explanation
CloudWatch or monitoring evidence
Runbook
Rollback plan
Architecture diagram
Presentation deck
Azure/GCP mapping notes
```

Teaching tip:

For beginners, explain that each component is one part of a delivery system. Do not let them think the capstone is only “an app running in Kubernetes.”

## Step 3: Explain Production-Style Review

Explain that enterprise reviews usually ask:

- Can this be repeated?
- Can another engineer understand it?
- Can it be deployed safely?
- Can it be rolled back?
- Can it be monitored?
- Are permissions controlled?
- What breaks first?
- What would you improve next?

Transition:

> Now that we know what reviewers care about, let’s draw the full workflow.

## Step 4: Whiteboard the Delivery Flow

Draw the flow from developer commit to CloudWatch monitoring.

Pause and ask:

> Where would a failure most likely happen in this workflow?

Expected answers:

- Pipeline credentials
- Docker build
- ECR push
- Kubernetes image pull
- Helm values
- Terraform variables
- IAM permissions
- App startup failure

## Step 5: Instructor Demo

Demonstrate the validation workflow using a sample repo or instructor reference project.

Show:

- Git status
- Repo structure
- Docker build
- AWS identity
- ECR check
- kubectl checks
- Helm checks
- Terraform validation
- Logs check
- Rollback check

Teaching tip:

Narrate your reasoning out loud. Students need to hear not just the command, but why you run it.

## Step 6: Student Lab

Students work on their own capstone projects.

Instructor circulates and checks:

- Is repo organized?
- Does README explain the project?
- Does pipeline have clear stages?
- Does Docker build?
- Does Helm deploy?
- Does Terraform validate?
- Is rollback documented?
- Is the demo flow realistic?

## Step 7: Troubleshooting Activity

Inject or assign a final failure scenario.

Students investigate and report:

- Symptom
- Evidence
- Root cause
- Fix
- Prevention

## Step 8: Peer Review

Pair students or teams.

Each student gives a 3-minute walkthrough:

- Problem
- Architecture
- Pipeline
- Deployment
- Monitoring
- Rollback

Peer gives feedback:

- What was clear?
- What was missing?
- What question would leadership ask?

## Step 9: Wrap-Up

End with Class 2 expectations:

Students must be ready to present and defend the project.

---

# 10. Instructor Lecture Notes

## Opening Talking Point

> Your capstone is your proof that you can think like a DevOps engineer. The application itself matters, but the delivery system around the application matters more. In real companies, DevOps engineers are trusted because they make delivery safer, faster, more repeatable, and easier to troubleshoot.

## Concept 1: The Capstone Is a Delivery System

Students may think the capstone is complete when the app runs. Clarify that the app is only one part.

A real DevOps platform includes:

- Source control
- Automated pipeline
- Build process
- Artifact registry
- Deployment process
- Infrastructure definition
- Access control
- Monitoring
- Rollback
- Documentation

Talking point:

> If another engineer cannot understand or repeat your deployment, the system is not production-ready yet.

## Concept 2: Repository Quality Matters

A clean repo shows engineering maturity.

A weak repo may have:

- Random files
- No README
- Hardcoded values
- No folder structure
- No explanation of how to run or deploy
- No troubleshooting notes

A strong repo has:

- Clear README
- Logical folders
- Clean pipeline file
- Helm and Terraform separated
- Documentation folder
- Runbook
- Rollback plan

Talking point:

> Your repository is often the first thing another engineer reviews. It should tell the story before you speak.

## Concept 3: CI/CD Must Be Explainable

Students do not need the most complex pipeline. They need a pipeline they can explain.

A good beginner-to-intermediate pipeline includes:

```text
validate → build → test → docker build → push image → deploy
```

Enterprise additions may include:

- Security scanning
- Approval gates
- Environment promotion
- Artifact retention
- Rollback jobs
- Policy checks
- OIDC authentication

Common misconception:

> A pipeline is good if it has many stages.

Correction:

> A pipeline is good if each stage has a clear purpose and reduces delivery risk.

## Concept 4: Docker and ECR Are the Artifact Layer

Explain:

Docker creates a deployable package. ECR stores that package. EKS pulls that package.

Without a registry, Kubernetes cannot reliably pull versioned application images.

Talking point:

> Do not say “Docker deploys to Kubernetes.” Docker builds the image. Kubernetes runs the container. ECR stores the image in between.

## Concept 5: Helm Makes Kubernetes Deployment Repeatable

Helm helps students avoid manually editing raw YAML for every environment.

Explain:

- Templates define the Kubernetes objects.
- Values files customize environments.
- Releases track deployment history.
- Rollback can return to a prior release.

Common misconception:

> Helm replaces Kubernetes.

Correction:

> Helm packages Kubernetes resources. Kubernetes still runs the workload.

## Concept 6: Terraform Is for Infrastructure, Not App Runtime Logic

Students should explain what they used Terraform for.

Examples:

- ECR repository
- IAM role
- EKS cluster, if included
- VPC or networking, if included
- S3 backend concept
- Supporting AWS resources

Teaching note:

Do not require every student to build a full EKS cluster from scratch if the course used a shared cluster. The key is that they understand where Terraform fits.

## Concept 7: IAM Is a Core DevOps Concern

Explain that pipelines should not use broad admin credentials.

Students should be able to explain:

- What identity runs the pipeline?
- What permissions does it need?
- What permissions should it not have?
- How would this be improved in enterprise?

Enterprise talking point:

> In production, we would prefer OIDC-based temporary credentials over static access keys.

## Concept 8: Observability Must Be Live, Not Described

A screenshot of a log line is not observability. For this finalization the bar is **three live signals**, consistent with Weeks 16 and 21:

1. **One dashboard** that renders real data (CloudWatch dashboard, or Grafana fed by Prometheus/OpenTelemetry).
2. **One alert rule** that has actually evaluated — show it firing *or* cleared, with the threshold and the metric it watches.
3. **One SLO status** — an availability or latency SLO with its current attainment and remaining error budget.

Students should answer:

- Where would you look if the app fails, and can you open that view right now?
- What metric indicates poor health, and what threshold did you set?
- What is your SLO, and how much error budget is left this window?

Common misconception:

> Monitoring is a checkbox I satisfy with a screenshot.

Correction:

> Monitoring is proven by opening the live dashboard, pointing at an alert that has evaluated, and reading the current SLO status out loud. If you cannot do that, you have not instrumented the system — you have described it.

Acceptance criterion (graded): "a dashboard URL + an alert rule that has evaluated + a current SLO status," **not** "notes exist." This closes the W16/W21 reliability loop in the flagship project.

## Concept 9: Rollback Is Part of Deployment

A deployment plan without rollback is incomplete.

Students should explain:

- How to return to a prior image tag
- How to use Helm rollback
- How to revert a Git change
- How to stop a bad pipeline deployment
- How to communicate a failed release

Talking point:

> In production, rollback should not be invented during an outage.

## Concept 10: Infrastructure Must Be Provisioned, Not Just Validated

`terraform validate` only proves syntax. A student who wrote three resources they never applied passes it identically to one who built real infrastructure. That is syntax-over-substance and it is not the senior bar.

The real IaC bar for finalization is one of:

- A clean `terraform plan` against the *actual* configuration (no errors, the plan reflects the intended resources), **and**
- Evidence of a prior `terraform apply` — real resource IDs, `terraform state list` output, or console proof that the resources exist.

Talking point:

> "It validates" tells me your HCL parses. "Here is the plan and here is `state list`" tells me the infrastructure is real and reproducible. We grade the second one.

Note: OpenTofu (`tofu plan` / `tofu apply`) is a drop-in alternative to Terraform and is accepted identically. State must live in a remote backend (S3 + DynamoDB lock, or equivalent), never committed to Git.

## Concept 11: ADRs Are How Seniors Record Decisions

Every "defend your tradeoffs" moment in this week is easier — and far more credible — if the decision was written down *when it was made*. That artifact is the Architecture Decision Record.

An ADR is short (half a page), dated, and immutable. When a decision changes, you write a new ADR that supersedes the old one; you do not edit history. The minimum set for this capstone is **three ADRs** covering the decisions with the most consequence, for example:

- Orchestration choice (e.g., EKS vs ECS vs plain EC2) and why.
- CI authentication (OIDC keyless vs static access keys) and why.
- State/backend, environment-separation, or rollback strategy.

ADR template (use MADR-style; put each in `docs/adr/NNNN-title.md`):

```markdown
# 2. Use EKS for container orchestration

Date: 2026-06-30
Status: Accepted

## Context
What problem are we deciding about? What constraints (team size, budget,
existing skills, course scope) shape the decision?

## Options Considered
- Option A: EKS — managed Kubernetes
- Option B: ECS on Fargate
- Option C: plain EC2 + systemd

## Decision
We chose Option A (EKS) because ...

## Consequences
Positive: ... (e.g., portable manifests, ecosystem, Helm).
Negative / cost: ... (e.g., control-plane cost, operational complexity).
Follow-ups: ... (what this forces us to also do).
```

Talking point:

> If you cannot point to the ADR, the interviewer assumes you reverse-engineered the justification after the fact. ADRs are the cheapest senior signal you can add — and they feed your Week 25 interview stories directly.

## Concept 12: Drop the "Portfolio, Not Production" Excuse for Core Controls

It is honest to say a capstone is smaller than a real production system. It is *not* acceptable, on an advanced/senior track, to wave away the controls that are cheap and expected:

- **OIDC keyless CI** — no long-lived AWS access keys in the pipeline. This is a half-day change, not a production luxury.
- **One gating security scan** — image scan (e.g., Trivy) or dependency scan that *fails the build* on a critical finding.
- **One real alert** wired to a real signal.

Common misconception:

> It's just a portfolio project, so missing OIDC, scanning, and alerts is fine.

Correction:

> Those three are baseline, not stretch goals. Talking about controls you never implemented is the fastest way to get exposed in an interview. Implement the cheap ones; *then* honestly list what a larger system would add (multi-account, DR, change management, audit pipelines).

---

# 11. Whiteboard Explanation

## Simple Diagram

```text
Developer
   |
   | git push
   v
Git Repository
   |
   | pipeline trigger
   v
CI/CD Pipeline
   |
   | build + test
   v
Docker Image
   |
   | push
   v
Amazon ECR
   |
   | image pull
   v
Amazon EKS
   |
   | deploy with Helm
   v
Kubernetes Workload
   |
   | logs + metrics
   v
Amazon CloudWatch
```

## Step-by-Step Flow

1. Developer pushes code to Git.
2. Git triggers the CI/CD pipeline.
3. Pipeline validates code and configuration.
4. Pipeline builds a Docker image.
5. Pipeline pushes the image to Amazon ECR.
6. Helm deploys or upgrades the Kubernetes release.
7. EKS runs the application workload.
8. CloudWatch collects logs or metrics.
9. If deployment fails, rollback returns to a known good version.

## What Each Component Means

| Component | Meaning |
|---|---|
| Developer | Person making code or configuration changes |
| Git Repository | Source of truth for app, pipeline, Terraform, and Helm |
| CI/CD Pipeline | Automated delivery workflow |
| Docker Image | Packaged application artifact |
| Amazon ECR | Registry that stores images |
| Amazon EKS | Kubernetes platform where app runs |
| Helm | Deployment packaging and release tool |
| CloudWatch | Monitoring and logging layer |

## Enterprise Version of the Diagram

```text
Developer Team
   |
   v
Merge Request / Pull Request
   |
   | code review + approval
   v
CI/CD Pipeline
   |
   | test + scan + build
   v
Artifact Registry: ECR
   |
   | approved deploy
   v
EKS Non-Prod
   |
   | validation + promotion
   v
EKS Production
   |
   | logs, metrics, alerts
   v
CloudWatch / Observability Platform
   |
   | incident response if needed
   v
Runbook + Rollback + Postmortem
```

Instructor explanation:

> In an enterprise, the workflow usually has approvals, environment separation, security scans, audit logs, and production monitoring. Your capstone is a simplified but realistic version of that delivery system.

---

# 12. Instructor Demo Script

## Demo Title

**Final DevOps Capstone Validation Walkthrough**

## Demo Objective

Show students how to perform a structured final validation of a DevOps capstone before presenting it.

## Required Setup

Instructor should have:

- Sample capstone repository
- Docker running locally
- AWS CLI configured
- Access to ECR
- Access to EKS or local Kubernetes fallback
- kubectl configured
- Helm installed
- Terraform installed

## Step 1: Validate Repository Structure

Command:

```bash
tree -L 3
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

> This tells me whether another engineer can quickly understand the project layout.

Failure point:

`tree` is not installed.

Recovery:

```bash
find . -maxdepth 3 -type f
```

## Step 2: Check Git Status

Command:

```bash
git status
git log --oneline -5
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

Explain:

> A clean working tree helps prevent accidental demo issues.

Failure point:

Uncommitted files.

Recovery:

Students can commit, stash, or intentionally document unfinished files.

## Step 3: Review README

Command:

```bash
cat README.md
```

Expected README sections:

```text
Project Overview
Architecture
Tools Used
AWS Services Used
Deployment Steps
Rollback Plan
Troubleshooting
Azure/GCP Mapping
```

Explain:

> The README should answer the questions a reviewer would ask first.

## Step 4: Validate Docker Build

Command:

```bash
cd app
docker build -t capstone-app:test .
```

Expected output:

```text
Successfully built <image-id>
Successfully tagged capstone-app:test
```

Explain:

> If the image cannot build locally, it will likely fail in CI too.

Failure points:

- Docker not running
- Bad Dockerfile path
- Missing dependency
- Wrong base image
- Build context issue

Recovery:

```bash
docker system df
docker images
docker build --no-cache -t capstone-app:test .
```

## Step 5: Run Container Locally

Command:

```bash
docker run --rm -p 8080:8080 capstone-app:test
```

In another terminal:

```bash
curl http://localhost:8080
```

Expected output:

```text
HTTP 200 response or application welcome message
```

Explain:

> This proves the image starts before we blame Kubernetes.

Failure points:

- Wrong container port
- App binds to localhost only
- Missing environment variable

Recovery:

```bash
docker ps
docker logs <container-id>
```

## Step 6: Validate AWS Identity

Command:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDA...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student-lab"
}
```

Explain:

> Before debugging ECR or EKS, always confirm who AWS thinks you are.

Failure points:

- Wrong profile
- Expired credentials
- Missing region
- No permission

Recovery:

```bash
aws configure list
export AWS_PROFILE=<profile-name>
aws sts get-caller-identity
```

## Step 7: Validate ECR Repository

Command:

```bash
aws ecr describe-repositories
```

Expected output:

```text
repositoryName: capstone-app
repositoryUri: 123456789012.dkr.ecr.us-east-1.amazonaws.com/capstone-app
```

Explain:

> ECR is where the pipeline stores the deployable container image.

Failure point:

No ECR permission.

Recovery:

Check IAM permission for:

```text
ecr:DescribeRepositories
ecr:GetAuthorizationToken
ecr:PutImage
ecr:InitiateLayerUpload
```

## Step 8: Validate Kubernetes Context

Command:

```bash
kubectl config current-context
kubectl get nodes
```

Expected output:

```text
eks-capstone-cluster
NAME               STATUS   ROLES
ip-10-0-1-10       Ready    <none>
```

Explain:

> Always confirm you are pointing to the expected cluster before deploying.

Failure points:

- Wrong kubeconfig
- Expired token
- No cluster access
- Wrong namespace

Recovery:

```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
kubectl get ns
```

## Step 9: Validate Helm Chart

Command:

```bash
helm lint helm/capstone-app
helm template capstone-app helm/capstone-app
```

Expected output:

```text
1 chart(s) linted, 0 chart(s) failed
```

Explain:

> Lint and template checks catch many issues before deployment.

Failure points:

- Bad indentation
- Missing value
- Invalid template syntax

Recovery:

Review:

```bash
helm template capstone-app helm/capstone-app --debug
```

## Step 10: Check Helm Release

Command:

```bash
helm list -n capstone
helm status capstone-app -n capstone
```

Expected output:

```text
NAME            NAMESPACE   STATUS
capstone-app    capstone    deployed
```

Explain:

> Helm status tells us whether Kubernetes accepted the release.

## Step 11: Validate Kubernetes Workload

Command:

```bash
kubectl get pods -n capstone
kubectl get svc -n capstone
kubectl get deploy -n capstone
```

Expected output:

```text
NAME                            READY   STATUS    RESTARTS
capstone-app-abc123             1/1     Running   0
```

Explain:

> Running is good, but readiness and logs tell us more.

## Step 12: Check Logs

Command:

```bash
kubectl logs -n capstone deploy/capstone-app
```

Expected output:

```text
Application started on port 8080
Health endpoint enabled
```

Explain:

> Logs are the first place to check application startup problems.

## Step 13: Prove Infrastructure Is Provisioned (not just valid)

Validate is the floor, not the bar. Show syntax checks, then prove the infrastructure is real.

Command:

```bash
cd terraform
terraform fmt -check
terraform init
terraform validate
terraform plan        # OpenTofu: tofu plan
```

Expected output:

```text
Success! The configuration is valid.

No changes. Your infrastructure matches the configuration.
```

> A clean plan showing "No changes" means what is declared is already applied — that is the strongest finalization signal. A plan that wants to *create* resources means you never applied; a plan that wants to *destroy/replace* means drift to investigate.

Then prove the resources exist:

```bash
terraform state list
aws ecr describe-repositories --query 'repositories[].repositoryName'
```

Expected output:

```text
aws_ecr_repository.app
aws_iam_role.ci_oidc
...
```

Explain:

> "It validates" only proves the HCL parses. `plan` + `state list` proves the infrastructure is real, reproducible, and not drifted. This is the bar we grade.

Failure points:

- Missing provider, variable, or wrong backend config (validate/init fails).
- Plan wants to create everything → never applied; the "infra" is just text.
- Plan wants to replace resources → drift or hand edits in the console.

Recovery:

```bash
terraform fmt
terraform init -reconfigure
terraform validate
terraform plan -out tfplan
# If the resources should exist but don't, this is a real apply (cost!):
terraform apply tfplan
```

Cost / security warning: `terraform apply` creates billable resources. Use small instance types, tear down with `terraform destroy` after grading, and never commit state or `*.tfvars` containing secrets.

## Step 14: Show Rollback Evidence

Command:

```bash
helm history capstone-app -n capstone
```

Expected output:

```text
REVISION    UPDATED                  STATUS      CHART
1           earlier-time             superseded
2           current-time             deployed
```

Explain:

> Rollback is part of production safety.

Rollback command:

```bash
helm rollback capstone-app 1 -n capstone
```

## Step 15: Validate Live Observability (dashboard + alert + SLO)

Do not accept a screenshot. Open the live signals.

```bash
# Confirm the alarm/alert rule exists and has actually evaluated:
aws cloudwatch describe-alarms \
  --alarm-names capstone-app-5xx-rate \
  --query 'MetricAlarms[].[AlarmName,StateValue,StateUpdatedTimestamp]' \
  --output table

# Confirm the dashboard exists (open its URL in the console to show live data):
aws cloudwatch list-dashboards --query 'DashboardEntries[].DashboardName'
```

Expected output:

```text
----------------------------------------------------------
| AlarmName                | StateValue | StateUpdatedTimestamp |
| capstone-app-5xx-rate    | OK         | 2026-06-30T13:02:11Z  |
----------------------------------------------------------
```

> `StateValue` of `OK` or `ALARM` (not `INSUFFICIENT_DATA`) proves the alert has real data flowing and has evaluated its threshold. For a Prometheus/Grafana stack, show the firing/cleared rule in Alertmanager and the dashboard panel rendering live.

SLO check — read the current attainment and remaining error budget out loud:

```text
SLO: 99.0% of requests < 500ms over 7 days
Current attainment: 99.4%
Error budget remaining: 60% (well within budget → safe to ship)
```

Explain:

> This is the W16/W21 loop closing: a real metric → a real alert that has evaluated → an SLO that drives the ship/freeze decision. If any of the three is missing, the system is described, not operated.

## Step 16: Review ADRs and Run the Production-Readiness Review

```bash
ls docs/adr/
cat docs/adr/0003-ci-authentication-oidc-vs-keys.md
cat docs/production-readiness-review.md
```

Explain, walking the PRR checklist (Section 13 lab) item by item:

> Each PRR line must point to *demonstrated* evidence — a command, a URL, a resource ID — not a promise. "Evidence or explanation" is not acceptable here; it must be evidence.

## Step 17: Cleanup Steps

If demo created local Docker artifacts:

```bash
docker images
docker rmi capstone-app:test
```

If demo deployed temporary namespace:

```bash
kubectl delete ns capstone-demo
```

Cost warning:

Do not delete shared classroom EKS clusters or shared ECR repositories unless specifically instructed.

---

# 13. Student Lab Manual

## Lab Title

**Final Capstone Polish and Demo Dry Run**

## Lab Objective

Finalize and validate your DevOps capstone so it is ready for the final presentation and technical defense.

## Estimated Time

60 to 75 minutes

## Student Prerequisites

You should already have:

- Capstone repository
- Dockerfile
- CI/CD pipeline file
- Helm chart or Kubernetes manifests
- Terraform code
- AWS CLI access
- ECR and EKS access, or approved local Kubernetes fallback
- Draft README
- Draft architecture diagram
- Draft presentation

## Architecture or Workflow Overview

```text
Git Repository
   ↓
CI/CD Pipeline
   ↓
Docker Build
   ↓
Amazon ECR
   ↓
Helm Deploy
   ↓
Amazon EKS
   ↓
CloudWatch Logs / Metrics
   ↓
Rollback Plan
```

## Step 1: Confirm Repository Is Clean

Run:

```bash
git status
git log --oneline -5
```

Expected output:

```text
nothing to commit, working tree clean
```

If you have uncommitted changes, decide whether to commit them or document them as unfinished.

## Step 2: Confirm Folder Structure

Run:

```bash
find . -maxdepth 3 -type f
```

Your repo should include:

```text
README.md
Dockerfile
pipeline file
helm chart or Kubernetes manifests
Terraform files
docs/runbook.md
docs/rollback-plan.md
docs/troubleshooting-notes.md
architecture diagram
presentation draft
```

## Step 3: Validate README

Your README should answer:

1. What does this project do?
2. What problem does it solve?
3. What tools are used?
4. What AWS services are used?
5. How does the pipeline work?
6. How is the app deployed?
7. How do you troubleshoot it?
8. How do you roll back?
9. How would it map to Azure or GCP?

## Step 4: Build Docker Image

From your app directory:

```bash
docker build -t capstone-app:test .
```

Expected output:

```text
Successfully tagged capstone-app:test
```

## Step 5: Run Docker Container Locally

Run:

```bash
docker run --rm -p 8080:8080 capstone-app:test
```

In a second terminal:

```bash
curl http://localhost:8080
```

Expected output:

```text
HTTP 200 response or application output
```

Troubleshooting:

If it fails, check:

```bash
docker ps
docker logs <container-id>
```

## Step 6: Confirm AWS Identity

Run:

```bash
aws sts get-caller-identity
```

Expected output should show your lab AWS account.

If it fails:

```bash
aws configure list
export AWS_PROFILE=<your-profile>
```

## Step 7: Confirm ECR Repository

Run:

```bash
aws ecr describe-repositories
```

Expected output should include your capstone repository.

If your image push is part of the pipeline, confirm that your documentation explains how the image gets pushed.

## Step 8: Confirm Kubernetes Access

Run:

```bash
kubectl config current-context
kubectl get ns
kubectl get nodes
```

Expected output:

```text
Cluster context is visible
Namespaces are listed
Nodes are Ready
```

If using local Kubernetes, confirm kind or minikube is running.

## Step 9: Validate Helm Chart

Run:

```bash
helm lint helm/capstone-app
helm template capstone-app helm/capstone-app
```

Expected output:

```text
0 chart(s) failed
```

If not using Helm, validate Kubernetes YAML:

```bash
kubectl apply --dry-run=client -f k8s/
```

## Step 10: Check Deployment

Run:

```bash
kubectl get pods -n capstone
kubectl get svc -n capstone
kubectl get deploy -n capstone
```

Expected output:

```text
Pods should show Running or Completed
Deployment should show available replicas
Service should show expected port
```

## Step 11: Check Application Logs

Run:

```bash
kubectl logs -n capstone deploy/capstone-app
```

Expected output:

```text
Application startup logs
No repeated crash errors
```

## Step 12: Prove Terraform-Provisioned Infrastructure

Validation is the floor. Show the infrastructure is actually provisioned.

From the Terraform directory:

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan          # OpenTofu users: tofu plan
terraform state list
```

Expected output:

```text
Success! The configuration is valid.

No changes. Your infrastructure matches the configuration.

aws_ecr_repository.app
aws_iam_role.ci_oidc
...
```

A clean `plan` with "No changes" plus a non-empty `state list` is your proof the infra is real and reproducible. If `plan` wants to create everything, you have not applied yet — apply it (mind the cost) or document why it is intentionally not provisioned.

If needed:

```bash
terraform init -reconfigure
terraform fmt
terraform plan -out tfplan
terraform apply tfplan   # creates billable resources — destroy after grading
```

## Step 13: Confirm Rollback Plan

Your rollback plan should explain at least one of these:

```bash
helm history capstone-app -n capstone
helm rollback capstone-app <revision> -n capstone
```

Or:

```text
Revert image tag to previous version
Re-run pipeline with previous artifact
Revert Git commit
Redeploy previous Helm values
```

## Step 14: Verify Live Observability

Open your three signals and confirm each is real:

```bash
aws cloudwatch describe-alarms --alarm-names <your-alarm-name> \
  --query 'MetricAlarms[].[AlarmName,StateValue]' --output table
aws cloudwatch list-dashboards --query 'DashboardEntries[].DashboardName'
```

Confirm:

```text
[ ] Dashboard URL opens and renders live data (not a saved image)
[ ] Alert StateValue is OK or ALARM (not INSUFFICIENT_DATA)
[ ] SLO status is written down: target, current attainment, error budget remaining
```

If you are on Prometheus/Grafana/OpenTelemetry instead of CloudWatch, show the rule in Alertmanager and the panel rendering live; the bar is identical.

## Step 15: Write or Finalize Your ADRs

Create at least three records in `docs/adr/` using the MADR template:

```text
docs/adr/0001-record-architecture-decisions.md
docs/adr/0002-container-orchestration-choice.md
docs/adr/0003-ci-authentication-oidc-vs-keys.md
```

Each ADR must contain: Context, Options Considered, Decision, Consequences (including cost). Keep them short and dated. These become your Week 25 interview stories.

## Step 16: Run Your Production-Readiness Review

Fill in `docs/production-readiness-review.md`. Every row must link to **demonstrated evidence** (a command output, a URL, a resource ID) — not "I would" or "notes exist".

| PRR area | Required evidence | Pass criterion |
|---|---|---|
| Build & deploy is repeatable | Successful pipeline run URL/log | Green run from commit to deploy |
| CI authentication | Workflow uses OIDC role; no static keys in repo/secrets | No `AWS_ACCESS_KEY_ID` long-lived secret |
| Security scanning | Image/dependency scan in pipeline that gates on critical | Build fails on an injected critical finding |
| Infrastructure as code | `terraform plan` (no changes) + `state list` | Resources exist and match config |
| Observability | Dashboard URL + alert state + SLO status | All three live |
| Reliability | SLO defined; error budget readable | Current budget stated |
| Rollback | `helm history` + a tested rollback | Rollback demonstrated, not just described |
| Secrets management | Secrets in Secrets Manager/SSM, not in Git | No plaintext secrets in repo |
| Cost | `docs/cost-estimate.md` with monthly figure | Estimate present and defensible |
| Operability | Runbook covers top 3 failure modes | Runbook reviewed |

## Step 17: Prepare Demo Flow

Write your demo flow:

```text
1.  Show business problem
2.  Show architecture diagram and reference the ADRs behind it
3.  Show repo structure
4.  Explain pipeline stages (highlight OIDC auth + gating scan)
5.  Show the pipeline run / Docker image build evidence
6.  Show the ECR image (live)
7.  Show the live Kubernetes deployment
8.  Show Helm release and history
9.  Show terraform plan (no changes) + state list — provisioned, not just valid
10. Open the live dashboard, show the alert state, read the SLO status
11. Demonstrate rollback (not just describe it)
12. Walk one ADR decision and one PRR row of evidence
```

## Validation Checklist

Note: these are pass/fail on **demonstrated** evidence. "Documented but not shown" does not pass the rows marked (demo).

| Item | Complete |
|---|---|
| Repo is clean |  |
| README is complete |  |
| Architecture diagram exists and matches the ADRs |  |
| At least 3 ADRs exist in `docs/adr/` (graded) |  |
| Pipeline uses OIDC keyless auth (no static keys) |  |
| Pipeline has a gating security scan |  |
| Docker image builds (demo) |  |
| ECR image exists (demo) |  |
| Kubernetes deployment is live (demo) |  |
| Helm chart validates and release is deployed (demo) |  |
| `terraform plan` clean + `state list` non-empty (demo) |  |
| IAM/security explanation exists |  |
| Live dashboard + alert state + SLO status (demo) |  |
| Rollback demonstrated, not just described (demo) |  |
| Runbook exists and covers top 3 failure modes |  |
| `docs/production-readiness-review.md` complete with evidence |  |
| `docs/cost-estimate.md` present |  |
| Presentation draft exists |  |

## Cleanup Steps

Local Docker cleanup:

```bash
docker ps
docker images
docker rmi capstone-app:test
```

Temporary Kubernetes cleanup only if instructed:

```bash
kubectl delete ns capstone-demo
```

Do not delete:

- Shared EKS cluster
- Shared ECR repository
- Shared IAM roles
- Shared Terraform backend

## Reflection Questions

1. Which part of your capstone is the strongest?
2. Which part would need more work before production?
3. What failure are you most prepared to troubleshoot?
4. What would you automate next?
5. How would your solution change in a larger enterprise?

## Optional Challenge Task

Add a `docs/final-review-checklist.md` file that includes:

```text
Pre-deployment checks
Deployment checks
Post-deployment checks
Rollback checks
Monitoring checks
Security checks
Known limitations
Future improvements
```

---

# 14. Troubleshooting Activity

## Incident Title

**Final Demo Fails During Capstone Dry Run**

## Business Impact

The DevOps team is scheduled to present a new automated deployment workflow to engineering leadership. During the final dry run, the deployment fails. If the issue is not resolved, the team cannot prove the workflow is reliable or ready for adoption.

## Symptoms

Students may receive one assigned symptom:

1. Docker image builds locally but fails in CI.
2. ECR push fails with an authentication error.
3. Helm deployment succeeds, but pods enter `CrashLoopBackOff`.
4. Kubernetes service exists, but the app is unreachable.
5. Terraform validation fails due to a missing variable.
6. CloudWatch logs are missing.
7. Pipeline deploy stage fails with an IAM access error.

## Starting Evidence

Example 1: ECR authentication failure

```text
denied: Your authorization token has expired. Reauthenticate and try again.
```

Example 2: Kubernetes image pull failure

```text
Failed to pull image "123456789012.dkr.ecr.us-east-1.amazonaws.com/capstone-app:v2"
```

Example 3: Helm values issue

```text
Error: template: capstone-app/templates/deployment.yaml: image.repository is required
```

Example 4: Terraform variable issue

```text
Error: No value for required variable
The root module input variable "environment" is not set.
```

## Student Investigation Steps

Students should follow this sequence:

1. Identify which layer is failing:
   - Git
   - CI/CD
   - Docker
   - ECR
   - Terraform
   - Helm
   - Kubernetes
   - AWS IAM
   - Monitoring

2. Check recent changes:

```bash
git log --oneline -5
git diff
```

3. Check AWS identity:

```bash
aws sts get-caller-identity
```

4. Check Docker:

```bash
docker build -t capstone-app:test .
docker images
```

5. Check ECR:

```bash
aws ecr describe-repositories
```

6. Check Kubernetes:

```bash
kubectl get pods -n capstone
kubectl describe pod -n capstone <pod-name>
kubectl logs -n capstone <pod-name>
```

7. Check Helm:

```bash
helm lint helm/capstone-app
helm status capstone-app -n capstone
helm get values capstone-app -n capstone
```

8. Check Terraform:

```bash
terraform fmt -check
terraform validate
```

## Expected Root Cause Examples

| Symptom | Expected Root Cause |
|---|---|
| ImagePullBackOff | Image tag in Helm values does not match ECR image tag |
| ECR push denied | IAM role lacks ECR push permission or login expired |
| Terraform variable error | Required variable missing from tfvars or pipeline variable |
| App unreachable | Service selector does not match pod labels |
| CrashLoopBackOff | Missing environment variable or app startup command issue |
| CloudWatch logs missing | Logging not configured or IAM permission missing |

## Correct Resolution Examples

Image tag mismatch:

```yaml
image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/capstone-app
  tag: v1.0.0
```

Then:

```bash
helm upgrade capstone-app helm/capstone-app -n capstone
kubectl get pods -n capstone
```

Missing Terraform variable:

```bash
terraform plan -var="environment=dev"
```

Or add to `terraform.tfvars`:

```hcl
environment = "dev"
```

Expired ECR login:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

## Common Wrong Paths

Students may:

- Rebuild Docker image without checking the actual Kubernetes error.
- Change random YAML values without reading `kubectl describe`.
- Blame AWS before checking local configuration.
- Re-run the whole pipeline repeatedly without isolating the failure.
- Delete resources instead of diagnosing them.
- Use admin permissions instead of fixing least-privilege access.
- Ignore namespace mismatches.

## Instructor Hints

Use hints gradually:

1. “Which layer is failing?”
2. “What command gives you evidence?”
3. “What changed since the last successful run?”
4. “Does the image tag in Kubernetes match the image tag in ECR?”
5. “Are you checking the correct namespace?”
6. “Does your IAM identity have the permission required for this action?”

## Preventive Action

Students should document:

- Pre-demo validation checklist
- Image tag strategy
- Required IAM permissions
- Helm values review process
- Terraform variable checklist
- Rollback steps
- Monitoring/logging verification
- Known limitations

---

# 15. Scenario-Based Discussion Questions

## Question 1

**What matters more in a final DevOps review: a successful one-time deployment or a repeatable deployment process?**

Expected response themes:

- Repeatability is more important.
- Manual success does not prove production readiness.
- CI/CD, IaC, versioning, and rollback reduce risk.

Follow-up:

> How would you prove your deployment is repeatable?

## Question 2

**Why should the Docker image be pushed to ECR instead of only built locally?**

Expected response themes:

- Kubernetes needs a registry to pull images.
- ECR provides versioned image storage.
- Pipelines and clusters need shared access to artifacts.

Follow-up:

> What can go wrong if image tags are not managed carefully?

## Question 3

**What IAM risks exist in CI/CD pipelines?**

Expected response themes:

- Overly broad admin permissions
- Long-lived access keys
- Missing least privilege
- Lack of auditability

Follow-up:

> How would OIDC improve this in an enterprise setup?

## Question 4

**Why is rollback planning part of DevOps and not just operations?**

Expected response themes:

- Deployment failures are expected.
- Rollback reduces business impact.
- DevOps owns safe delivery, not just automation.

Follow-up:

> What rollback method does your capstone support?

## Question 5

**What should be monitored after deployment?**

Expected response themes:

- Application logs
- Error rate
- Latency
- Pod restarts
- CPU and memory
- Deployment status
- HTTP health

Follow-up:

> What alert would be useful without creating alert fatigue?

## Question 6

**How would this design change for a real enterprise production environment?**

Expected response themes:

- Separate accounts or environments
- Approval gates
- Security scans
- Secrets management
- Stronger monitoring
- Cost controls
- Access reviews

Follow-up:

> What would you improve first if given one more week?

## Question 7

**How does the same pattern map to Azure or GCP?**

Expected response themes:

- ECR becomes ACR or Artifact Registry.
- EKS becomes AKS or GKE.
- CloudWatch becomes Azure Monitor or Cloud Monitoring.
- The workflow pattern remains similar.

Follow-up:

> What part is cloud-specific and what part is cloud-agnostic?

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

Which component stores the Docker image before Kubernetes pulls it?

A. Terraform  
B. Amazon ECR  
C. CloudWatch  
D. Route 53  

**Answer:** B  
**Explanation:** Amazon ECR is the AWS container registry used to store Docker images.

## Question 2: Multiple Choice

Which command confirms the AWS identity currently being used?

A. `aws iam list-users`  
B. `aws sts get-caller-identity`  
C. `aws eks list-nodegroups`  
D. `aws configure clear`  

**Answer:** B  
**Explanation:** `aws sts get-caller-identity` shows the current AWS account, user, or role.

## Question 3: True or False

A successful local Docker build guarantees the application will run correctly in Kubernetes.

**Answer:** False  
**Explanation:** Kubernetes may still fail due to image pull issues, missing environment variables, wrong ports, probes, or service configuration.

## Question 4: Multiple Choice

What is the main purpose of Helm in this capstone?

A. To replace Docker  
B. To package and manage Kubernetes deployments  
C. To create IAM users  
D. To store CloudWatch logs  

**Answer:** B  
**Explanation:** Helm packages Kubernetes manifests and manages releases, upgrades, and rollbacks.

## Question 5: Short Answer

Why should a final capstone include a rollback plan?

**Answer:** A rollback plan explains how to recover from a failed deployment by returning to a previous working version.  
**Explanation:** Real production systems need recovery steps before incidents happen.

## Question 6: Troubleshooting Multiple Choice

A pod shows `ImagePullBackOff`. What should you check first?

A. Whether the image repository and tag are correct  
B. Whether CloudWatch dashboard exists  
C. Whether Terraform has outputs  
D. Whether the README has screenshots  

**Answer:** A  
**Explanation:** `ImagePullBackOff` usually means Kubernetes cannot pull the image due to bad tag, registry auth, or repository access.

## Question 7: Troubleshooting Short Answer

Terraform reports: `No value for required variable "environment"`. What is the likely fix?

**Answer:** Provide the variable through `terraform.tfvars`, command-line `-var`, environment variable, or pipeline variable.  
**Explanation:** Terraform requires values for variables without defaults.

## Question 8: True or False

CloudWatch is only useful after production release and does not matter for a capstone.

**Answer:** False  
**Explanation:** CloudWatch or logging evidence shows operational readiness and troubleshooting awareness.

## Question 9: Multiple Choice

Which pair is the closest Azure and GCP equivalent of Amazon EKS?

A. Azure Blob Storage and Cloud Storage  
B. Azure Kubernetes Service and Google Kubernetes Engine  
C. Azure Monitor and Cloud Monitoring  
D. Azure Functions and Cloud Run  

**Answer:** B  
**Explanation:** AKS and GKE are managed Kubernetes services like EKS.

## Question 10: Short Answer

Name two things a reviewer may ask during a DevOps capstone defense.

**Answer:** Examples include: How does your pipeline work? How do you roll back? How are permissions managed? How do you monitor the app? How would this scale in enterprise?  
**Explanation:** Reviewers focus on design decisions, reliability, security, and operational readiness.

---

# 17. Homework Assignment

## Assignment Title

**Final DevOps Capstone Readiness Package**

## Scenario

You are preparing to present your DevOps delivery platform to engineering leadership. The team wants proof that your workflow is repeatable, secure, documented, and ready for operational review.

## Student Tasks

Complete and submit:

1. Final repository cleanup.
2. README update.
3. Architecture diagram.
4. CI/CD pipeline using OIDC keyless auth with a gating security scan.
5. Docker build + live ECR image evidence.
6. Live Kubernetes/Helm deployment evidence.
7. Terraform/OpenTofu provisioning evidence: clean `plan` + `state list`.
8. IAM and security explanation.
9. Live observability: dashboard URL + alert state + SLO status.
10. At least 3 Architecture Decision Records in `docs/adr/`.
11. `docs/production-readiness-review.md` with demonstrated evidence per row.
12. `docs/cost-estimate.md` with estimated monthly cost.
13. Runbook (top 3 failure modes).
14. Rollback plan (demonstrated).
15. Troubleshooting notes.
16. Draft final presentation.
17. Optional: AWS→Azure/GCP awareness notes (not graded).

## Expected Deliverables

```text
README.md
architecture diagram
.github/workflows/deploy.yml   (OIDC keyless auth + gating scan)
Dockerfile
Helm chart or Kubernetes manifests
Terraform/OpenTofu files
docs/runbook.md
docs/rollback-plan.md
docs/troubleshooting-notes.md
docs/production-readiness-review.md
docs/cost-estimate.md
docs/adr/0001-*.md, 0002-*.md, 0003-*.md
presentation deck
```

## Submission Format

Students submit:

- Git repository link
- Presentation file or link
- Short summary of known limitations
- Screenshot or text evidence of successful validation commands

## Estimated Completion Time

2 to 4 hours

## Grading Criteria

Grading is **evidence-first**: a row only earns full marks when the capability is *demonstrated* (command output, URL, resource ID), not merely described.

| Criteria | Weight |
|---|---:|
| Repository organization & README | 10% |
| CI/CD: OIDC keyless auth + gating security scan (demonstrated) | 15% |
| Docker + ECR workflow (live image) | 10% |
| Kubernetes/Helm deployment (live) | 15% |
| Terraform/OpenTofu provisioned: clean `plan` + `state list` | 10% |
| Live observability: dashboard + alert + SLO status | 10% |
| Architecture Decision Records (3+, graded) | 10% |
| Production-Readiness Review complete with evidence | 10% |
| Rollback demonstrated + runbook quality | 5% |
| Cost estimate (`docs/cost-estimate.md`) | 5% |

## Optional Advanced Challenge

Add one of the following:

- Pipeline security scan
- Manual approval gate
- Automated Helm rollback job
- OIDC-based AWS authentication design
- CloudWatch alarm example
- Environment-specific Helm values for dev and prod

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Treating the capstone as only an app demo | Students focus on the application instead of the delivery workflow | Emphasize Git, pipeline, image, deploy, monitor, rollback |
| Missing README details | Students assume the instructor knows the project | Use README checklist |
| Hardcoding values in YAML | Students rush to make it work | Use Helm values and variables |
| Using latest image tag | Beginner habit from local testing | Use versioned tags like `v1.0.0` |
| Not validating AWS identity | Students debug wrong issue | Always run `aws sts get-caller-identity` first |
| Wrong Kubernetes namespace | Common kubectl mistake | Use `kubectl get ns` and `-n capstone` |
| Forgetting Terraform variables | Variables exist but values are not passed | Use tfvars or pipeline variables |
| No rollback plan | Students think deployment success is enough | Require rollback section in docs |
| No monitoring evidence | Students forget operational side | Add logs, metrics, or CloudWatch screenshots |
| Overly broad IAM permissions | Easier during labs | Explain least privilege and production risk |
| Unclear presentation flow | Students show tools randomly | Use business problem → architecture → workflow → demo → tradeoffs |

---

# 19. Real-World Enterprise Scenario

## Scenario

A mid-sized enterprise is modernizing its application delivery process. Application teams currently deploy manually using inconsistent scripts. Releases are slow, rollback is unclear, and operations teams struggle to troubleshoot failures because there is limited logging and no standard deployment process.

The DevOps team is asked to create a repeatable delivery workflow for containerized applications.

## Constraints

- Developers must use Git-based workflows.
- Pipeline changes must be reviewed.
- Docker images must be stored in a trusted registry.
- Kubernetes deployments must be repeatable.
- AWS credentials must not be hardcoded.
- Monitoring must show basic application health.
- Rollback must be documented.
- Production changes may require approvals.
- Cost should be controlled in non-production environments.
- Documentation must allow another team to operate the workflow.

## How the Class Topic Applies

Students are acting as DevOps engineers preparing the delivery platform for review.

They need to prove:

- The workflow starts from Git.
- The pipeline builds and packages the application.
- Images are stored in ECR.
- The application deploys to EKS.
- Helm makes deployment repeatable.
- Terraform manages infrastructure-related resources.
- IAM is considered.
- CloudWatch supports troubleshooting.
- Rollback is planned.
- Documentation is complete.

## What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build pipeline, Docker workflow, Helm deployment, rollback process |
| Cloud Engineer | Validate AWS resources, IAM access, ECR, EKS, network assumptions |
| SRE | Review monitoring, logs, reliability, incident response, and runbook quality |

---

# 20. Instructor Tips

## Teaching Tips

- Keep students focused on validation, not adding new features.
- Ask students to explain why each tool exists in the workflow.
- Use the phrase “show evidence” often.
- Encourage simple, working, explainable designs over complex unfinished designs.
- Remind students that documentation is part of engineering.

## Pacing Tips

- Do not spend too long lecturing. This class needs lab time.
- Keep the whiteboard explanation to about 20 minutes.
- Keep demo commands focused on final validation.
- Start student lab by the halfway point.
- Leave at least 15 minutes for troubleshooting and peer review.

## Lab Support Tips

When helping a student, ask:

1. What are you trying to validate?
2. What command did you run?
3. What output did you get?
4. What layer is failing?
5. What changed since it last worked?

## How to Help Struggling Students

For struggling students, narrow the scope:

- Validate README.
- Validate Docker build.
- Validate one Kubernetes deployment.
- Validate one Terraform command.
- Write a clear rollback plan.
- Prepare a simple presentation.

Do not let them attempt major redesigns during Class 1.

## How to Challenge Advanced Students

Ask advanced students to add:

- Environment-specific Helm values
- Pipeline approval stage
- Security scan
- OIDC design
- CloudWatch alarm
- Rollback automation
- Multi-cloud architecture mapping
- Production readiness checklist

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- What problem their capstone solves
- How their Git workflow works
- What each pipeline stage does
- How Docker image creation works
- Why ECR is used
- How the app deploys to Kubernetes
- Why Helm is useful
- What Terraform manages
- How IAM permissions affect the workflow
- Where logs or metrics can be found
- How rollback works
- How the design maps to Azure or GCP

## Students Should Be Able to Build or Configure

- A clean repository structure
- A working or explainable CI/CD pipeline
- A Docker image
- An ECR image workflow
- Kubernetes manifests or Helm chart
- Terraform validation workflow
- Basic documentation
- Runbook
- Rollback plan
- Presentation flow

## Students Should Be Able to Troubleshoot

- Failed Docker builds
- ECR authentication problems
- Wrong image tags
- Kubernetes pod failures
- Helm template errors
- Terraform variable errors
- IAM permission issues
- Missing logs or monitoring evidence
- Namespace or context mistakes

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

Confirm students have:

- Reviewed capstone requirements
- Validated repo structure
- Practiced key validation commands
- Worked through lab checklist
- Investigated at least one troubleshooting scenario
- Drafted final presentation flow
- Understood Class 2 presentation expectations

## Student Checklist Before Leaving Class

| Item | Complete |
|---|---|
| Repo cleaned up |  |
| README updated |  |
| Architecture diagram ready and matches ADRs |  |
| 3+ ADRs written in `docs/adr/` |  |
| Pipeline uses OIDC + gating scan |  |
| Docker build validated |  |
| ECR image live |  |
| Kubernetes/Helm deployment live |  |
| `terraform plan` clean + `state list` checked |  |
| IAM/security notes written |  |
| Live dashboard + alert + SLO status prepared |  |
| Rollback demonstrated |  |
| Runbook written |  |
| Production-readiness review completed |  |
| Cost estimate written |  |
| Troubleshooting notes updated |  |
| Presentation draft ready |  |

## Items to Verify Before Moving to Class 2

Students should be ready to present:

1. Business problem
2. Architecture
3. Repository
4. Pipeline
5. Docker and ECR
6. Kubernetes and Helm
7. Terraform
8. IAM and security
9. Monitoring
10. Rollback
11. Troubleshooting
12. Azure/GCP mapping
13. Lessons learned
14. Known limitations
15. Next improvements

---

## Class Artifacts & Validation

These are the **on-disk, validated** artifacts of the backing capstone module that
this class's demo (Section 12) and lab (Section 13) actually drive. All paths are
relative to the repo root and were verified to exist. The integration module writes
almost no new code; its "solution" is the set of integration documents plus the demo
compose, so artifact rows point at the real files (there is no `solution/` source tree
— see `labs/capstone/README.md`). Static gates below were **run in this environment**.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/capstone/validate.sh | bash | Runs the module's 7 validation gates (YAML parse, reference checker, shell syntax, compose config ×2) | `cd labs/capstone && ./validate.sh` | PASS — `7 passed, 0 failed, 0 deferred`, exit 0 |
| 2 | labs/capstone/tests/check_references.sh | bash | Reference checker: asserts every `labs/<module>` path the capstone cites exists (the reproducible "broken state" detector) | `bash labs/capstone/tests/check_references.sh` | PASS — `22 found, 0 missing`, exit 0 |
| 3 | labs/capstone/docker-compose.demo.yaml | docker compose | ONE local demo stack: app (built from `../docker-containers`, not forked) + Redis + optional Prometheus | `docker compose -f docker-compose.demo.yaml config` | PASS (default + `--profile metrics`), exit 0 |
| 4 | labs/capstone/prometheus/prometheus.demo.yml | prometheus config | Minimal scrape config the demo mounts | `promtool check config labs/capstone/prometheus/prometheus.demo.yml` | PASS — `SUCCESS: ... is valid prometheus config file syntax` |
| 5 | labs/capstone/architecture/architecture.mmd | mermaid | Full-system architecture diagram; every box maps to one course module | render at <https://mermaid.live> / `mmdc -i architecture.mmd -o architecture.svg` | DEFERRED — renders where `mmdc` is available (`mmdc` not installed in this build env); subgraph→module mapping verified by gate #2 |
| 6 | labs/capstone/adr/0001-record-architecture-decisions.md | markdown ADR | Nygard-format ADR: adopt ADRs (the "Author ADRs" objective) | manual review against `starter/adr/NNNN-template.md` | PASS — present, follows template |
| 7 | labs/capstone/adr/0002-managed-vs-self-hosted.md | markdown ADR | Nygard-format ADR with a real decision table + "revisit when…" triggers | manual review (names what is rejected + revisit trigger) | PASS — present, records a real trade-off |
| 8 | labs/capstone/production-readiness-checklist.md | markdown | Go/no-go PRR gate, ticked against real artifact paths; gaps honestly left `[ ]` | manual review — every `[x]` resolves to a real file | PASS — present, evidence-linked |
| 9 | labs/capstone/runbook.md | markdown | On-call runbook with ≥4 alert→action playbooks (error-budget burn, CrashLoop, dependency-down, OOM) and copy-pasteable commands | manual review | PASS — present, ≥4 runnable playbooks |

> **Live-evidence note (honest):** This class's *teaching bar* is a live, deployed
> capstone (real `terraform plan`/`apply` + state, a live dashboard/alert/SLO, a
> demonstrated rollback). The backing module is **static-validated only** in this
> environment: `validate.sh` passes 7/7 and the local `docker compose` demo was
> brought up here (app + Redis `healthy`, `curl /healthz` → `{"status": "ok"}`,
> captured in `labs/capstone/README.md` §Validation). There is **no committed
> `LIVE-AWS-VALIDATION.txt` / `LIVE-*EVIDENCE*.txt`** for a real AWS apply/destroy or
> live cluster operation. The live signals (EKS deploy, CloudWatch alarm state,
> `terraform state list`) are produced by the **student on their own capstone**, not
> shipped as evidence in this repo.

## Definition of Done

Ticked honestly for this class against the backing `labs/capstone` module.

- [x] Every technology taught ships at least one **runnable file on disk** (compose stack, scrape config, validator, reference checker — not just fences).
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (`validate.sh` 7/7; `promtool check config` SUCCESS; compose config exit 0).
- [ ] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions. *Partial:* `starter/capstone-brief.md` + `starter/adr/NNNN-template.md` exist; there is **no `solution/` tree** — by design the committed integration docs *are* the reference (README §Instructor answer key). Counts as starter+answer-key, not the standard starter/solution pair.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent (`docker compose ... --profile metrics down -v`; cloud profile is plan-only, `terraform destroy` documented).
- [x] **Instructor answer key** exists — the committed integration files are the reference; non-obvious grading points are documented in README §Instructor answer key.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — a **dangling reference** detected by `tests/check_references.sh` gate 3 (delete/rename a path → gate fails). Per-component broken fixtures live in sibling modules.
- [x] **Expected outputs** are shown for the demo and lab (compose `healthy`, `/healthz` → 200, validator line output).
- [x] **Cost & security warnings** present (local demo $0; cloud profile plan-only with destroy guidance; non-root/`read_only`/`cap_drop`; no secrets committed).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Weeks 3–23 mapped; reuses modules 4–12; verified by the reference checker).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves.
- [ ] **Live operation evidence** (real AWS apply/destroy, live alert/rollback) committed in-repo. *Not met:* module is static-validated; live ops are the student's to perform. This is the cap on the week's score.
