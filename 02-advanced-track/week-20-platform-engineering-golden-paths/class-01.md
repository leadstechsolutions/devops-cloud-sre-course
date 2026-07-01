# Week 20: Platform Engineering and Golden Paths
> **▶ Runnable lab for this class:** [`labs/helm-charts/`](../../labs/helm-charts/) · [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package

**Week:** 20  
**Track:** Unified DevOps · Cloud · SRE Track  
**Class title:** Introduction to Platform Engineering, Golden Paths, and Developer Self-Service  
**Duration:** 3 hours  
**Audience:** Beginner to intermediate DevOps, Cloud Engineering, and SRE learners  
**Primary cloud:** AWS  
**Secondary exposure:** Azure and GCP

---

# 1. Class Overview

## Class Title

**Class 1: Introduction to Platform Engineering, Golden Paths, and Developer Self-Service**

## Class Purpose

This class introduces students to platform engineering as a practical DevOps evolution. Students learn how platform teams reduce repeated manual work by creating reusable, documented, secure, and supported paths for application teams.

The class focuses on the design side of golden paths before students build a simple golden path template in Class 2.

## How This Class Connects to the Overall Course

This class builds directly on prior course topics:

| Prior Topic | How It Connects |
|---|---|
| Git and collaboration (Week 3) | Golden paths are stored, versioned, and reviewed in Git; templates ship as Git repos |
| CI/CD Fundamentals (Week 9) | Pipeline templates become part of the platform (reusable workflows, `workflow_call`, GitLab `include`) |
| Docker / Containers (Week 10) | Container image standards (multi-stage, distroless, non-root) become reusable defaults |
| Kubernetes (Weeks 11–12) and Helm (Week 13) | Deployment patterns are packaged as a real chart for app teams; GitOps deploys them |
| Terraform (Weeks 14–15) | Infrastructure modules become reusable platform building blocks behind simple inputs |
| Cloud Security & IAM (Week 6) and Landing Zones (Week 17) | OIDC keyless CI and least-privilege roles are baked in as enforced defaults |
| Observability & Reliability (Week 16) | Runbooks, dashboards, SLOs, and ownership are included in the golden path |
| DevSecOps & Secure Delivery (Week 19) | Trivy/Checkov scanning and policy gates are wired in as paved-road defaults |
| Cost Optimization (Week 18) | Required tags, cost-center metadata, and right-sized defaults thread through the template |
| SRE Foundations (Week 21, next) | DORA/DX metrics and operational readiness extend platform-as-product into reliability |

## What Students Will Build, Analyze, or Practice

Students will:

1. Analyze a sample golden path repository structure.
2. Design a golden path workflow for a new containerized application.
3. Identify what belongs in a reusable platform template.
4. Practice documenting developer onboarding steps.
5. Troubleshoot a scenario where an app team misuses a platform template because documentation and inputs are unclear.

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** what platform engineering is and why organizations use it.
2. **Compare** DevOps, platform engineering, and SRE responsibilities.
3. **Describe** golden paths, paved roads, and developer self-service.
4. **Identify** repeated DevOps tasks that should become reusable platform patterns.
5. **Analyze** a golden path repository structure.
6. **Design** a basic onboarding workflow for a containerized application.
7. **Document** required inputs, ownership, deployment flow, and support expectations.
8. **Troubleshoot** a scenario where unclear golden path documentation causes deployment confusion.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic Git workflow: clone, branch, commit, pull request or merge request
- Basic CI/CD stages: validate, build, test, deploy
- Docker image basics
- Kubernetes deployment basics
- Helm values concept
- Terraform module concept
- AWS IAM, ECR, EKS, VPC, and CloudWatch at a beginner level
- Basic production support concepts such as runbooks and ownership

## Required Tools Already Installed

Students should have:

- VS Code
- Git
- Terminal or command prompt
- Docker Desktop or Docker Engine, optional for this class
- AWS CLI, optional for this class
- Terraform CLI, optional for this class
- Helm CLI, optional for this class
- kubectl, optional for this class

## Required Accounts or Access

For Class 1, students do **not** need to create live AWS resources.

Recommended access:

- GitHub or GitLab account
- Local workstation
- Optional AWS sandbox account for instructor reference only

## Files, Repos, or Sample Code Needed

Instructor should prepare a sample folder named:

```text
golden-path-container-app/
```

Students can create their own local folder during the lab:

```text
student-golden-path-design/
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Platform Engineering | Building reusable tools, templates, and workflows that help developers deliver software faster and safer | A platform team creates standard CI/CD templates, Terraform modules, Helm charts, dashboards, and onboarding docs |
| Golden Path | The recommended and supported way to build, deploy, and operate an application | A company may say: “For containerized apps, use this repo template, pipeline, Helm chart, and EKS deployment process” |
| Paved Road | A supported path that makes the right way easier than the risky way | Teams can customize safely, but they start from approved defaults |
| Developer Self-Service | Allowing developers to complete common tasks without waiting on manual tickets | A developer can create a service from a template, deploy to dev, and view logs without asking DevOps each time |
| Internal Developer Platform (IDP) | The integrated layer (portal + catalog + templates + automation) developers use to self-serve software delivery | Backstage, Port, Cortex, or Spotify Portal; this is the *substance* of a 2026 platform, not an optional add-on |
| Service Catalog | A governed inventory of services, owners, and platform offerings with scorecards/maturity levels | Backstage Software Catalog entries (`catalog-info.yaml`) with ownership, lifecycle, and dependency metadata |
| Software Template / Scaffolder | The mechanism that turns a developer's button-click into a real repo with pipeline, chart, and IaC wired in | Backstage Software Templates, Cookiecutter, `copier`; this is *self-service*, not hand-copying a folder |
| Control Plane | Infrastructure exposed as Kubernetes APIs so platforms provision cloud resources declaratively | Crossplane Compositions/Claims, the Operator pattern, Cluster API — the modern alternative to CI-driven Terraform |
| GitOps | Deploy by reconciling cluster state to Git as the single source of truth | Argo CD / Flux watch a repo and apply the golden-path chart; no `kubectl apply` from a laptop |
| DORA Metrics | Four key delivery metrics: deployment frequency, lead time, change-failure rate, time to restore | The standard scorecard for whether a golden path actually improves delivery |
| DX / SPACE | Frameworks measuring developer experience and productivity beyond raw throughput | Developer surveys, onboarding time, time-to-first-deploy, satisfaction — platform-as-product success signals |
| Reusable Template | A prebuilt file or workflow that teams can copy or reference | CI/CD templates, GitHub Actions reusable workflows, GitLab includes, Helm starter charts |
| Terraform Module | A reusable package of infrastructure code | A module can standardize ECR, IAM roles, CloudWatch dashboards, or EKS namespace creation |
| Helm Chart | A reusable Kubernetes application package | Platform teams can give app teams a chart with standard deployment, service, probes, and resources |
| Guardrail | A control that keeps teams safe without blocking all progress | Required approval before prod deploy, image scanning, IAM least privilege, required tags |
| Ownership Metadata | Information that identifies the team responsible for a service | Team name, email, Slack channel, cost center, app owner, escalation path |
| Operational Handoff | The process of ensuring a service is supportable after deployment | Includes runbooks, dashboards, logs, alerts, ownership, and rollback process |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Golden path templates should be version-controlled and reviewed |
| GitHub or GitLab | Used to host reusable templates, pipelines, and application repos |
| VS Code | Used to inspect and edit repo files, Markdown, YAML, and documentation |
| Terminal | Used to create folders, inspect files, and run basic validation commands |
| Markdown | Used for README files, onboarding guides, and runbooks |
| YAML | Used for CI/CD pipeline templates and Helm values |
| Terraform | Used conceptually for reusable infrastructure modules |
| Helm | Used conceptually for reusable Kubernetes deployment templates |
| Backstage / Port (IDP) | The core of the week: developer portal, software catalog, and software templates (scaffolder) that make self-service real |
| Crossplane / Operators | Control-plane model that exposes cloud infrastructure as Kubernetes APIs (compared against Terraform-module self-service) |
| Argo CD / Flux (GitOps) | The 2026 deploy mechanism for golden-path apps: reconcile cluster state from Git |
| Cookiecutter / copier | Lightweight scaffolding engines for generating a service repo when a full IDP is not yet in place |
| AWS CLI v2 | Used to show ECR, EKS, IAM/OIDC, and CloudWatch references; v2 is the current supported major version |

---

# 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon ECR | Standard container registry used in the golden path for storing application images |
| Amazon EKS | Target Kubernetes platform for deploying containerized applications |
| IAM | Controls pipeline roles, deployment permissions, and least-privilege access |
| VPC | Provides the network foundation where EKS workloads run |
| CloudWatch | Collects logs, metrics, dashboards, and alarms for applications |
| S3, optional concept | Can store pipeline artifacts or Terraform state in more advanced workflows |
| Systems Manager, optional concept | Can support operational automation and secure access patterns |

## AWS Teaching Point

The golden path is not just a CI/CD file. In AWS, it usually connects:

```text
Git repo
→ CI/CD pipeline
→ IAM role
→ Docker image
→ Amazon ECR
→ Amazon EKS
→ CloudWatch logs and metrics
→ Runbook and ownership documentation
```

---

# 7. Azure and GCP Comparison Notes

Keep this short during class.

| Platform Concept | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Kubernetes | Amazon EKS | Azure AKS | Google GKE |
| Identity and access | IAM | Azure RBAC / Managed Identity | Cloud IAM |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |
| Developer portal | Backstage on AWS or self-hosted | Backstage with Azure integrations | Backstage with GCP integrations |

## Instructor Note

The platform engineering concept is cloud-agnostic. The implementation changes by cloud provider.

---

# 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:15 | Class opening, week context, and review of prior CI/CD, Terraform, Helm, and Kubernetes concepts |
| 0:15 to 0:40 | Explain platform engineering and why teams use it |
| 0:40 to 1:05 | Compare DevOps, platform engineering, and SRE responsibilities |
| 1:05 to 1:25 | Explain golden paths, paved roads, and developer self-service |
| 1:25 to 1:35 | Break |
| 1:35 to 2:05 | The Internal Developer Platform: portal, catalog, software templates; control-plane vs CI-driven self-service; GitOps as the deploy path |
| 2:05 to 2:25 | Whiteboard: new service onboarding flow (scaffold → catalog → GitOps) |
| 2:25 to 2:45 | Instructor demo: reviewing a golden path repo structure and a Backstage software template |
| 2:45 to 3:00 | Operationalizing DORA/DX metrics, discussion, recap, and homework explanation |

---

# 9. Instructor Lesson Plan

## 0:00 to 0:15 - Opening and Context

### Instructor Should Explain

Start by connecting this class to earlier course topics:

- “You already learned Git, CI/CD, Docker, Kubernetes, Helm, Terraform, IAM, and monitoring.”
- “Platform engineering combines these into reusable patterns for application teams.”
- “Instead of solving the same deployment problem over and over, platform teams package the solution.”

### Ask Students

- “What tasks would become painful if every application team did them differently?”
- “What repeated tasks have we done in previous weeks?”

Expected answers:

- Pipeline setup
- Docker image creation
- Kubernetes deployment
- IAM permissions
- Monitoring
- Rollbacks
- Documentation

## 0:15 to 0:40 - What Is Platform Engineering?

### Instructor Should Explain

Platform engineering is about building internal products for developers.

Emphasize:

- Developers are the customers of the platform.
- The platform team provides reusable paths.
- Good platforms reduce tickets, confusion, security gaps, and inconsistent deployments.

### Show

Draw this simple comparison:

```text
Without platform:
Every app team reinvents delivery.

With platform:
App teams use approved templates and workflows.
```

### Pause for Questions

Ask:

- “Is platform engineering the same as DevOps?”
- “Who owns the app code?”
- “Who owns the reusable deployment pattern?”

## 0:40 to 1:05 - DevOps vs Platform Engineering vs SRE

### Instructor Should Explain

| Role | Main Focus |
|---|---|
| DevOps Engineer | Automates build, test, deploy, release, and infrastructure workflows |
| Platform Engineer | Builds reusable internal platforms, templates, and paved roads |
| SRE | Improves reliability, observability, incident response, and production readiness |

### Teaching Tip

Tell students these roles overlap in real companies. The difference is usually the primary responsibility, not the toolset.

## 1:05 to 1:25 - Golden Paths and Developer Self-Service

### Instructor Should Explain

A golden path should answer:

1. How do I create a new service?
2. Where does my code live?
3. How does the pipeline work?
4. Where does the image go?
5. How does it deploy?
6. How do I view logs?
7. How do I roll back?
8. Who supports what?

### Show

```text
New app request
→ template repo
→ standard pipeline
→ Docker build
→ ECR push
→ Helm deploy to EKS
→ CloudWatch dashboard
→ runbook and ownership
```

## 1:25 to 1:35 - Break

Keep the break short. Ask students to return with one example of a task they would standardize.

## 1:35 to 2:05 - The Internal Developer Platform (IDP)

### Instructor Should Explain

This is the heart of the week. In 2026, a platform is not a folder of templates — it is an **Internal Developer Platform**: an integrated layer developers self-serve through. Teach the three planes:

1. **Developer-experience plane (portal + catalog).** Backstage, Port, or Cortex. Developers discover services, see who owns what, view docs (TechDocs), and *invoke* templates. The catalog is a governed system (ownership, lifecycle, scorecards/maturity), not a single YAML stub.
2. **Integration / scaffolding plane (software templates).** Backstage Software Templates (or Cookiecutter/`copier`) take a button-click and produce a real repo with the pipeline, chart, IaC, and ownership already wired in. This is what makes self-service *self-service* instead of a hand-copied folder.
3. **Resource / control plane.** Two competing models the student must be able to contrast in an interview:
   - **CI-driven (Terraform modules).** The pipeline runs `terraform apply` against reusable modules. Simpler, familiar, but drift and day-2 reconciliation are manual.
   - **Control-plane (Crossplane / Operators / Cluster API).** Infrastructure is exposed as Kubernetes APIs. App teams submit a **Claim** (e.g. "I need a Postgres + an ECR repo"); a **Composition** reconciles the real cloud resources continuously, like any other controller. This is the modern self-service infrastructure model and is increasingly the default for mature platforms.

### Show: control-plane vs CI-driven self-service

```text
CI-driven self-service              Control-plane self-service
-------------------------           ----------------------------
developer edits .tfvars             developer submits a Claim (CRD)
   |                                   |
pipeline runs terraform apply       Crossplane Composition reconciles
   |                                   |
resources created (then drift)      resources created AND kept in sync
   |                                   |
day-2 = re-run pipeline             day-2 = controller self-heals
```

### Show: GitOps as the deploy path

The golden-path app does not reach EKS via `kubectl apply` from a laptop or a pipeline `helm upgrade` placeholder. It reaches the cluster through **GitOps**:

```text
Pipeline builds image → pushes to ECR → bumps image tag in a Git "deploy" repo
   |
Argo CD (or Flux) watches that repo
   |
Argo CD reconciles the golden-path Helm chart onto EKS
   |
drift is corrected automatically; rollback = git revert
```

### Teaching Tip

Name the tradeoff honestly: a full Backstage instance is real operational work. Many teams start with **Port** (hosted) or even a **Cookiecutter** scaffolder + a service catalog YAML convention, and adopt Crossplane/GitOps incrementally. The point students must carry into interviews is the *shape* of the platform (portal → scaffolder → control plane → GitOps), not one vendor.

## 2:05 to 2:25 - Whiteboard Flow

Use the whiteboard section below.

Pause after drawing the first version and ask:

- “Where would IAM fit?”
- “Where would monitoring fit?”
- “Where would documentation fit?”
- “Where would production approval fit?”

## 2:25 to 2:45 - Instructor Demo

Demo the sample golden path repo structure, then show a **Backstage software template** (`template.yaml`) and a `catalog-info.yaml` so students see that the repo is *scaffolded and registered*, not hand-built. See Section 12.

Important: Do not deploy live resources in this class. Keep it focused on structure, the scaffolder, catalog registration, and flow.

## 2:45 to 3:00 - DORA/DX Metrics, Recap, and Homework

Close by operationalizing success (see new lecture note Concept 6): tie the golden path to **DORA** (deployment frequency, lead time for changes, change-failure rate, time to restore) and **DX/SPACE** signals (time-to-first-deploy, onboarding time, developer satisfaction, adoption rate). Show that "platform as a product" means measuring it like a product.

Recap:

- Platform engineering packages repeatable DevOps work.
- Golden paths reduce confusion and ticket volume.
- Documentation and ownership are part of the platform.
- Templates must have safe defaults and clear customization points.

Assign homework: design a developer onboarding workflow for a new service.

---

# 10. Instructor Lecture Notes

## Opening Talking Point

“Today we are shifting from doing DevOps tasks one by one to thinking like a platform team. A platform team asks: what do application teams need repeatedly, and how can we make that safe, reusable, and easy?”

## Concept 1: Platform Engineering

Platform engineering is not just building tools. It is building a supported experience.

A platform can include:

- Templates
- Pipelines
- Infrastructure modules
- Documentation
- Developer portals
- Support model
- Security guardrails
- Operational standards

### Real-World Example

A company has 40 application teams. Each team needs:

- A repo
- A pipeline
- An ECR repository
- An EKS namespace
- A Helm deployment
- Secrets
- Monitoring
- Logs
- Runbooks

If every team opens tickets for these, the platform team becomes a bottleneck. Platform engineering turns these repeated requests into a reusable workflow.

## Concept 2: Golden Paths

A golden path is the approved way to do something.

Example:

“For a containerized application, use this service template, this CI/CD template, this Helm chart, this Terraform module, and this monitoring pattern.”

A golden path should be:

- Easy to understand
- Secure by default
- Documented
- Version-controlled
- Supported
- Flexible where needed
- Opinionated where safety matters

### Common Misconception

Students may think a golden path means “no customization allowed.”

Clarify:

A good golden path allows controlled customization. For example, teams may change replica count or environment variables, but they should not bypass image scanning or production approval.

## Concept 3: Paved Roads

A paved road is similar to a golden path, but emphasizes making the right behavior easy.

For example:

- Default pipeline includes image scanning.
- Default Helm chart includes probes.
- Default Terraform module includes required tags.
- Default CloudWatch dashboard is created automatically.

The goal is to make safe behavior the easiest option.

## Concept 4: Developer Self-Service

Self-service does not mean developers have unlimited access.

It means developers can complete approved actions without waiting for manual intervention.

Examples:

- Create a new service from a template
- Deploy to dev
- View logs
- Request a namespace through an approved workflow
- Use a standard Terraform module
- Use a reusable pipeline template

### Security Context

Self-service must still respect:

- IAM least privilege
- Approval gates
- Audit logs
- Separation of duties
- Environment boundaries
- Production controls

## Concept 5: Platform as a Product

Tell students:

“Platform engineering works best when the platform team treats internal developers like customers.”

This means:

- Clear onboarding
- Good documentation
- Feedback loops
- Versioning
- Support channels
- Usage metrics
- Improvement backlog

## Concept 6: The Internal Developer Platform Is the Product

A golden path is *delivered through* an IDP. The IDP has three planes students must be able to name:

- **Portal + catalog** (Backstage / Port / Cortex): discover services, owners, docs, scorecards.
- **Scaffolder / software templates**: a button-click produces a wired-up repo (the self-service trigger).
- **Resource/control plane**: either CI-driven Terraform modules or a Kubernetes control plane (Crossplane/Operators).

A minimal Backstage **software template** (`template.yaml`) — the artifact behind "create a new service":

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: containerized-service
  title: Containerized Service (Golden Path)
  description: Scaffold a service with CI, Helm chart, Terraform inputs, and runbooks
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service details
      required: [name, owner, ownerEmail]
      properties:
        name: { title: Service name, type: string, pattern: "^[a-z][a-z0-9-]+$" }
        owner: { title: Owning team, type: string }
        ownerEmail: { title: Owner email, type: string }
  steps:
    - id: fetch
      name: Fetch skeleton
      action: fetch:template
      input:
        url: ./skeleton            # contains ci/, helm/, terraform/, runbooks/
        values:
          name: ${{ parameters.name }}
          owner: ${{ parameters.owner }}
          ownerEmail: ${{ parameters.ownerEmail }}
    - id: publish
      name: Publish repo
      action: publish:github
      input:
        repoUrl: github.com?owner=acme&repo=${{ parameters.name }}
    - id: register
      name: Register in catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml
```

**Common misconception:** "Backstage is just a wiki." Clarify: the catalog enforces ownership and the scaffolder *generates and registers* the repo, so the golden path is invoked, not copied.

## Concept 7: Control Plane vs CI-Driven Self-Service

The two models for self-service infrastructure, and the senior talking point:

| | CI-driven (Terraform modules) | Control plane (Crossplane / Operators) |
|---|---|---|
| Trigger | Edit `.tfvars`, pipeline runs `terraform apply` | Submit a Kubernetes **Claim** (CRD) |
| Day-2 reconciliation | Manual re-run; drift undetected | Continuous; controller self-heals |
| Mental model | Imperative-ish pipeline step | Declarative Kubernetes API |
| Best when | Team already lives in Terraform; simpler estate | K8s-native platform, many tenants, want self-healing |

Students do not need to memorize Crossplane syntax, but they must be able to say *why* a platform might expose a `kind: PostgresInstance` Claim instead of asking app teams to write Terraform.

## Concept 8: GitOps Is the Deploy Path

Golden-path apps reach EKS via **Argo CD / Flux**, not laptop `kubectl`. The pipeline's job ends at "push image + update the desired tag in Git"; the GitOps controller reconciles the cluster. This gives drift correction, audit (every change is a commit), and rollback-by-revert — and it is the connection point to the W11–W13 Kubernetes/Helm weeks and the capstone.

## Concept 9: Platform as a Product Means You Measure It (DORA + DX)

"Platform as a product" is hollow without metrics. Operationalize with:

- **DORA (delivery):** deployment frequency, lead time for changes, change-failure rate, time to restore service.
- **DX / SPACE (experience):** time-to-first-deploy for a new service, onboarding time, golden-path adoption rate, developer satisfaction (survey), ticket-deflection rate.
- **Service scorecards** in the catalog: each service scored on maturity (has runbook? has SLO? scanned? owned?) so the platform team can drive adoption objectively.

Show leadership the *DORA trend after golden-path adoption* and the *adoption rate* — those are the numbers that fund a platform team.

## Practical Enterprise Context

In an enterprise, a platform team may reduce ticket volume by creating:

- A software template (scaffolder) that produces the whole service repo
- A service catalog with ownership and scorecards
- Standard EKS namespace request workflow (Claim or Terraform module)
- Standard ECR creation module / Composition
- Standard least-privilege IAM role via OIDC (no static keys)
- Standard CloudWatch dashboard and SLO
- Standard rollback runbook and GitOps Application
- Standard production approval process

The goal is not only speed. It is consistency, reliability, security, supportability, and a measurable improvement in DORA/DX.

---

# 11. Whiteboard Explanation

## Simple Diagram: Golden Path Delivery Flow

```text
Application Team
   |
   | 1. Starts from approved service template
   v
Golden Path Repository
   |
   | 2. Uses standard CI/CD pipeline
   v
Build and Validation
   |
   | 3. Builds Docker image
   v
Amazon ECR
   |
   | 4. Deploys with Helm
   v
Amazon EKS
   |
   | 5. Sends logs and metrics
   v
Amazon CloudWatch
   |
   | 6. Uses runbooks and ownership docs
   v
Production Support Ready
```

## Step-by-Step Explanation

1. **Application Team**  
   Owns the application code and business logic.

2. **Golden Path Repository**  
   Provides the approved starter structure, pipeline template, docs, and runbooks.

3. **Build and Validation**  
   Pipeline validates code, builds image, runs tests, and checks basic standards.

4. **Amazon ECR**  
   Stores the approved container image.

5. **Amazon EKS**  
   Runs the containerized workload.

6. **Amazon CloudWatch**  
   Provides logs, metrics, dashboards, and alerts.

7. **Production Support Ready**  
   The app has ownership, runbook, rollback process, and monitoring.

## Enterprise Version of the Diagram

```text
Developer Team
   |
   | submits onboarding request or uses service catalog
   v
Developer Portal / Service Catalog
   |
   | creates repo from template
   | applies approved inputs
   v
GitHub or GitLab Repository
   |
   | reusable pipeline template
   | security scanning
   | approvals
   v
CI/CD Platform
   |
   | assumes IAM role
   | builds image
   | pushes to ECR
   v
AWS Platform Layer
   |
   | ECR
   | EKS namespace
   | IAM role
   | VPC networking
   | CloudWatch dashboard
   v
Operational Handoff
   |
   | runbook
   | alerts
   | rollback
   | owner metadata
   | support channel
```

## Instructor Prompt

Ask students:

“What could go wrong if the golden path only includes the pipeline, but not monitoring or ownership?”

Expected response:

- No one knows who owns the app.
- Alerts may go nowhere.
- Support team lacks runbooks.
- Rollback steps are unclear.
- Production incidents take longer to resolve.

---

# 12. Instructor Demo Script

## Demo Title

**Reviewing a Golden Path Repository Structure**

## Demo Objective

Show students what a simple enterprise golden path repository could include and explain how each part supports application teams.

## Required Setup

Instructor should have a local folder ready or create it live.

```bash
mkdir -p golden-path-container-app/{docs,app/src,ci,helm/app-chart/templates,terraform/modules/ecr,terraform/modules/iam-role,terraform/modules/cloudwatch,terraform/environments/dev,terraform/environments/prod,runbooks}
cd golden-path-container-app
touch README.md
touch docs/onboarding.md docs/architecture.md docs/troubleshooting.md
touch app/Dockerfile app/src/index.html
touch ci/gitlab-ci-template.yml ci/github-actions-template.yml
touch helm/app-chart/Chart.yaml helm/app-chart/values.yaml helm/app-chart/values-dev.yaml helm/app-chart/values-prod.yaml
touch terraform/environments/dev/example.tfvars terraform/environments/prod/example.tfvars
touch runbooks/deployment-failure.md runbooks/rollback.md runbooks/high-error-rate.md
```

## Step 1: Show Folder Structure

### Command

```bash
tree golden-path-container-app
```

If `tree` is not installed:

```bash
find golden-path-container-app -maxdepth 4 -type f | sort
```

### Expected Output

```text
golden-path-container-app/
├── README.md
├── app/
│   ├── Dockerfile
│   └── src/
│       └── index.html
├── ci/
│   ├── gitlab-ci-template.yml
│   └── github-actions-template.yml
├── docs/
│   ├── architecture.md
│   ├── onboarding.md
│   └── troubleshooting.md
├── helm/
│   └── app-chart/
│       ├── Chart.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── values.yaml
├── runbooks/
│   ├── deployment-failure.md
│   ├── high-error-rate.md
│   └── rollback.md
└── terraform/
    ├── environments/
    └── modules/
```

### Explain

“This repo is not just code. It is a product for application teams. It includes how to build, deploy, observe, troubleshoot, and support a service.”

## Step 2: Add README Content

### Command

```bash
cat > README.md <<'README_EOF'
# Golden Path for Containerized Application Delivery

## Purpose
This template helps application teams deploy a containerized service using an approved enterprise delivery pattern.

## What This Provides
- Dockerfile starter
- CI/CD pipeline template
- ECR image push pattern
- Helm deployment structure
- Terraform input examples
- CloudWatch monitoring expectations
- Rollback and troubleshooting runbooks

## Target Users
Application teams deploying containerized services to Amazon EKS.

## Required Inputs
- application_name
- environment
- aws_region
- ecr_repository_name
- eks_namespace
- owner_team
- owner_email
- support_channel

## Supported Customization
- Application code
- Image tag
- Environment variables
- Replica count within approved limits
- Resource requests and limits within approved limits

## Unsupported Changes
- Removing security scan stage
- Bypassing production approval
- Using personal AWS credentials
- Disabling logging or monitoring
README_EOF
```

### Explain

“The README is the front door. If this is unclear, teams will misuse the template.”

## Step 3: Add Conceptual Pipeline Template

### Command

```bash
cat > ci/gitlab-ci-template.yml <<'PIPELINE_EOF'
stages:
  - validate
  - test
  - build
  - scan
  - push
  - deploy_dev
  - approve_prod
  - deploy_prod

variables:
  AWS_REGION: "us-east-1"
  APP_NAME: "sample-app"
  ECR_REPOSITORY: "sample-app"

validate:
  stage: validate
  script:
    - echo "Validating required files"
    - test -f app/Dockerfile
    - test -f helm/app-chart/values-dev.yaml

test:
  stage: test
  script:
    - echo "Running application tests"

build:
  stage: build
  script:
    - echo "Building Docker image"

scan:
  stage: scan
  script:
    - echo "Scanning image and dependencies"

push:
  stage: push
  script:
    - echo "Pushing image to Amazon ECR"

deploy_dev:
  stage: deploy_dev
  script:
    - echo "Deploying to dev using Helm"

approve_prod:
  stage: approve_prod
  when: manual
  script:
    - echo "Manual approval required for production"

deploy_prod:
  stage: deploy_prod
  script:
    - echo "Deploying to prod using Helm"
PIPELINE_EOF
```

### Explain

“This is not meant to be a fully working production pipeline yet. It shows the standard stages that a platform team may provide.”

## Step 4: Add Helm Values Example

### Command

```bash
cat > helm/app-chart/values-dev.yaml <<'HELM_EOF'
appName: sample-app
namespace: dev

image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/sample-app
  tag: "dev-latest"

replicaCount: 2

service:
  port: 80

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

owner:
  team: platform-training
  email: platform-training@example.com
  supportChannel: "#platform-support"
HELM_EOF
```

### Explain

“Helm values are where teams customize deployment behavior. A golden path should make these inputs obvious and safe.”

## Step 5: Add Terraform Input Example

### Command

```bash
cat > terraform/environments/dev/example.tfvars <<'TFVARS_EOF'
application_name = "sample-app"
environment      = "dev"
aws_region       = "us-east-1"

ecr_repository_name = "sample-app"
eks_namespace       = "sample-app-dev"
pipeline_role_name  = "sample-app-dev-pipeline-role"

owner_team    = "platform-training"
owner_email   = "platform-training@example.com"
cost_center   = "training"
data_class    = "internal"
TFVARS_EOF
```

### Explain

“Terraform modules should hide complexity and expose clear inputs. The app team should not need to understand every IAM or ECR detail.”

## Step 6: Add Rollback Runbook

### Command

```bash
cat > runbooks/rollback.md <<'RUNBOOK_EOF'
# Rollback Runbook

## When to Use
Use this runbook when a deployment causes errors, latency, failed health checks, or customer impact.

## Steps
1. Confirm the current failed release.
2. Check application logs.
3. Check CloudWatch metrics or dashboard.
4. Identify the last known good image tag.
5. Roll back the Helm release.
6. Validate pods are running.
7. Confirm the service endpoint returns healthy response.
8. Notify application owner and support channel.
9. Document what happened.

## Validation Commands
kubectl get pods -n <namespace>
kubectl describe deployment <deployment-name> -n <namespace>
kubectl logs deployment/<deployment-name> -n <namespace>
helm history <release-name> -n <namespace>
helm rollback <release-name> <revision> -n <namespace>
RUNBOOK_EOF
```

### Explain

“Runbooks are part of production readiness. A deployment template without rollback guidance is incomplete.”

## Step 7: Show the Scaffolder and Catalog Entry (the self-service part)

This is the step that distinguishes describing self-service from showing it. The repo above is the *skeleton*; the scaffolder turns it into a registered service.

### Command

```bash
mkdir -p platform-templates/containerized-service
cat > platform-templates/containerized-service/template.yaml <<'TEMPLATE_EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: containerized-service
  title: Containerized Service (Golden Path)
  description: Scaffold a service repo with CI, Helm chart, Terraform inputs, runbooks
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Service details
      required: [name, owner, ownerEmail]
      properties:
        name:
          title: Service name
          type: string
          pattern: "^[a-z][a-z0-9-]+$"
        owner:
          title: Owning team
          type: string
        ownerEmail:
          title: Owner email
          type: string
  steps:
    - id: fetch
      name: Fetch skeleton
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          owner: ${{ parameters.owner }}
          ownerEmail: ${{ parameters.ownerEmail }}
    - id: publish
      name: Publish repo
      action: publish:github
      input:
        repoUrl: github.com?owner=acme&repo=${{ parameters.name }}
    - id: register
      name: Register in catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml
TEMPLATE_EOF
```

Then show the catalog entry that lands in every scaffolded repo (this is the *governed ownership* record, not a throwaway stub):

```bash
cat > golden-path-container-app/catalog-info.yaml <<'CATALOG_EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: sample-app
  description: Containerized service delivered via the golden path
  annotations:
    backstage.io/techdocs-ref: dir:.
    github.com/project-slug: acme/sample-app
  tags:
    - golden-path
spec:
  type: service
  lifecycle: production
  owner: platform-training
  system: delivery-platform
CATALOG_EOF
```

### Explain

“In Backstage or Port, a developer fills in three fields and clicks Create. The scaffolder fetches this skeleton, fills the values, publishes a new repo, and registers it in the catalog with its owner. *That* is self-service — the developer never hand-copies a folder, and the platform always knows who owns the service.”

If a full Backstage instance is not available, point students to the equivalent **Cookiecutter** approach (`cookiecutter.json` + a `{{cookiecutter.name}}/` skeleton, run with `cookiecutter ./containerized-service`) so the concept is reproducible locally.

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `tree` not found | Tool not installed | Use `find . -maxdepth 4 -type f` |
| Permission denied creating files | Folder permissions issue | Use a user-writable directory |
| YAML indentation looks wrong | Manual copy error | Open in VS Code and format carefully |
| Students think this deploys live resources | Demo is conceptual | Clarify this is a golden path structure demo |
| Too much time spent on YAML | Class goal is design | Keep code review high-level |

## Cleanup Steps

```bash
cd ..
rm -rf golden-path-container-app
```

If you want to keep the demo for Class 2, do not delete it.

---

# 13. Student Lab Manual

## Lab Title

**Design a Golden Path for a New Containerized Application**

## Lab Objective

Create a basic golden path design package that explains how an application team should onboard, build, deploy, monitor, and support a containerized service.

## Estimated Time

45 to 60 minutes

## Student Prerequisites

Students should understand:

- Basic Git repo structure
- Basic CI/CD pipeline stages
- Docker image concept
- ECR and EKS concepts
- Helm values concept
- Terraform module concept
- CloudWatch logs and metrics concept

## Architecture or Workflow Overview

```text
Developer
   |
   | uses approved template
   v
Git Repository
   |
   | pipeline runs
   v
Build, Test, Scan
   |
   | image pushed
   v
Amazon ECR
   |
   | Helm deploys
   v
Amazon EKS
   |
   | logs and metrics
   v
Amazon CloudWatch
   |
   | documented runbooks
   v
Supportable Service
```

## Step-by-Step Student Instructions

### Step 1: Create Lab Folder

```bash
mkdir -p student-golden-path-design/{docs,ci,helm,terraform,runbooks}
cd student-golden-path-design
touch README.md
```

### Step 2: Create the README

Open `README.md` and add:

```markdown
# Golden Path Design for Containerized App Delivery

## Purpose
This golden path helps application teams deploy a standard containerized service to Kubernetes using approved DevOps and cloud patterns.

## Target Users
Application teams building containerized web applications or APIs.

## Supported Platform
- GitHub or GitLab
- Docker
- Amazon ECR
- Amazon EKS
- Helm
- Terraform
- Amazon CloudWatch

## Required Inputs
| Input | Description | Example |
|---|---|---|
| application_name | Name of the service | orders-api |
| environment | Deployment environment | dev |
| owner_team | Team responsible for app | payments |
| owner_email | Support contact | payments@example.com |
| aws_region | AWS deployment region | us-east-1 |
| ecr_repository | Container image repository | orders-api |
| eks_namespace | Kubernetes namespace | orders-dev |

## Supported Customization
- Image tag
- Replica count
- Environment variables
- Resource requests and limits
- Dev and prod values files

## Unsupported Changes
- Removing security scan stage
- Bypassing production approval
- Using personal AWS access keys
- Disabling logs or monitoring
```

### Step 3: Create a Pipeline Flow File

Create:

```bash
touch ci/pipeline-flow.md
```

Add:

```markdown
# Pipeline Flow

1. validate
2. test
3. build image
4. scan image
5. push image to Amazon ECR
6. deploy to dev using Helm
7. manual approval for prod
8. deploy to prod using Helm
9. publish deployment notes
```

### Step 4: Create Helm Values Example

Create:

```bash
touch helm/values-dev.yaml
```

Add:

```yaml
appName: orders-api
namespace: orders-dev

image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/orders-api
  tag: "dev-latest"

replicaCount: 2

service:
  port: 8080

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

owner:
  team: payments
  email: payments@example.com
  supportChannel: "#payments-support"
```

### Step 5: Create Terraform Input Example

Create:

```bash
touch terraform/sample-inputs.tfvars
```

Add:

```hcl
application_name = "orders-api"
environment      = "dev"
aws_region       = "us-east-1"

ecr_repository_name = "orders-api"
eks_namespace       = "orders-dev"
pipeline_role_name  = "orders-api-dev-pipeline-role"

owner_team    = "payments"
owner_email   = "payments@example.com"
cost_center   = "finance-platform"
data_class    = "internal"
```

### Step 6: Create Onboarding Checklist

Create:

```bash
touch docs/onboarding-checklist.md
```

Add:

```markdown
# New Service Onboarding Checklist

## Application Information
- [ ] Application name provided
- [ ] Owner team provided
- [ ] Owner email provided
- [ ] Support channel provided
- [ ] Environment selected

## Platform Requirements
- [ ] Git repo created
- [ ] CI/CD template added
- [ ] ECR repository requested or created
- [ ] EKS namespace requested or created
- [ ] IAM pipeline role configured
- [ ] Helm values completed
- [ ] CloudWatch logs enabled
- [ ] Dashboard linked
- [ ] Rollback runbook completed
```

### Step 7: Create Troubleshooting Runbook

Create:

```bash
touch runbooks/template-misuse.md
```

Add:

```markdown
# Template Misuse Troubleshooting Runbook

## Problem
Application team used the golden path but deployment failed.

## Common Causes
- Required values missing
- Wrong namespace
- Wrong image tag
- Missing owner metadata
- IAM role not available
- Pipeline variable not set
- Helm values file changed incorrectly

## Investigation Steps
1. Check pipeline failed stage.
2. Check required variables.
3. Review Helm values file.
4. Confirm ECR image repository and tag.
5. Confirm namespace.
6. Check README instructions.
7. Escalate to platform team if template issue is confirmed.

## Prevention
- Add validation stage.
- Add required inputs table.
- Add examples.
- Add FAQ.
```

## Commands Students Should Run

```bash
find . -maxdepth 3 -type f | sort
```

Expected output:

```text
./README.md
./ci/pipeline-flow.md
./docs/onboarding-checklist.md
./helm/values-dev.yaml
./runbooks/template-misuse.md
./terraform/sample-inputs.tfvars
```

## Validation Checklist

| Item | Expected Result |
|---|---|
| README explains purpose | Clear and beginner-friendly |
| Required inputs are documented | Inputs table exists |
| Pipeline flow is listed | At least validate, build, scan, push, deploy |
| Helm values file exists | Includes image, namespace, replica count, owner |
| Terraform input file exists | Includes app, environment, region, owner |
| Onboarding checklist exists | Covers repo, CI/CD, ECR, EKS, IAM, monitoring |
| Troubleshooting runbook exists | Includes common failure causes and investigation steps |

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| Folder structure does not match | Created files in wrong directory | Run `pwd` and `find . -maxdepth 3 -type f` |
| YAML looks broken | Indentation issue | Use two spaces and avoid tabs |
| Required input missing | README incomplete | Add input to required inputs table |
| Helm file missing owner | Ownership metadata skipped | Add team, email, support channel |
| Terraform values too vague | Inputs not enterprise-ready | Add cost center, data class, owner |

## Cleanup Steps

```bash
cd ..
rm -rf student-golden-path-design
```

Students can skip cleanup if they want to keep the folder for Class 2.

## Reflection Questions

1. Which part of your golden path would help developers the most?
2. Which part would reduce platform team tickets?
3. What would happen if owner information is missing?
4. What validation should be automated?
5. What should be customizable and what should be locked down?

## Optional Challenge Task

Add a `docs/aws-architecture.md` file with this diagram:

```text
Git Repo
→ CI/CD Pipeline
→ IAM Role
→ Amazon ECR
→ Amazon EKS
→ CloudWatch
→ Runbook
```

Explain each step in one sentence.

---

# 14. Troubleshooting Activity

## Incident Title

**Application Team Misuses Golden Path Template Due to Missing Documentation**

## Business Impact

A development team attempted to onboard a new service using the platform team’s golden path. The deployment failed, and the team opened several support tickets.

Impact:

- Delayed dev environment deployment
- Increased platform team support load
- Confusion around ownership and required inputs
- Reduced trust in the platform template

## Symptoms

Students receive this incident summary:

```text
The payments team used the golden path template for a new service called payments-api.
The pipeline validated successfully.
The Docker image build stage completed.
The deploy stage failed.
The developer does not know which Helm values file to update.
The README does not explain required fields.
The EKS namespace name is inconsistent across files.
The owner_email field is missing.
The platform support team received three tickets asking for help.
```

## Starting Evidence

### Failed Pipeline Message

```text
ERROR: deployment failed
Reason: required value .owner.email is missing
Reason: namespace payments-dev not found
Reason: image repository value is empty
```

### Helm Values File

```yaml
appName: payments-api
namespace: payment-dev

image:
  repository: ""
  tag: "latest"

replicaCount: 1

owner:
  team: payments
```

### README Excerpt

```markdown
# Golden Path Template

Update the values file and run the pipeline.
Contact platform team if there are issues.
```

## Student Investigation Steps

Students should identify:

1. Which fields are missing or incorrect?
2. Which documentation gaps caused confusion?
3. Which validation should happen earlier in the pipeline?
4. Which values should have examples?
5. Which fields should be required?
6. Which support instructions are missing?

## Expected Root Cause

The golden path template technically exists, but it is not usable enough. Required inputs are undocumented, examples are incomplete, and validation does not catch missing values before deployment.

## Correct Resolution

Students should recommend:

1. Add required inputs table to README.
2. Add example `values-dev.yaml` and `values-prod.yaml`.
3. Add Helm lint or schema validation.
4. Standardize namespace naming.
5. Require owner metadata.
6. Add a troubleshooting guide.
7. Add support and escalation instructions.
8. Add pipeline validation before deploy.

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Blaming only the app team | The template failed to guide users clearly |
| Manually fixing the one deployment only | Does not prevent repeat issues |
| Giving app team admin access | Creates security risk |
| Removing required fields | Reduces operational readiness |
| Skipping validation | Allows the same problem to happen again |

## Instructor Hints

Use these hints if students get stuck:

- “Where should required inputs be documented?”
- “What could the pipeline check before deployment?”
- “Why does owner metadata matter?”
- “What is the difference between fixing this service and improving the platform?”

## Preventive Action

A better golden path should include:

- Clear README
- Required input table
- Example values files
- Validation stage
- Ownership metadata
- Runbooks
- FAQ
- Support path
- Versioned template releases

---

# 15. Scenario-Based Discussion Questions

## Question 1

**Should a golden path be mandatory for all application teams?**

Expected themes:

- Mandatory for production-critical standards
- Flexible for app-specific needs
- Guardrails should protect security and reliability
- Exceptions need review

Follow-up:

“What parts should never be bypassed?”

## Question 2

**What should be customizable in a golden path?**

Expected themes:

- Image tag
- Replica count within limits
- Environment variables
- App-specific config
- Resource requests within approved boundaries

Follow-up:

“What should not be customizable?”

## Question 3

**How does platform engineering reduce ticket volume?**

Expected themes:

- Reusable templates reduce repeated setup requests
- Self-service reduces waiting
- Documentation reduces support questions
- Standardization reduces troubleshooting complexity

Follow-up:

“What tickets would still require human review?”

## Question 4

**What security risks can come from poor golden path design?**

Expected themes:

- Overly broad IAM roles
- Hardcoded secrets
- Disabled scanning
- Missing approvals
- Untracked production changes

Follow-up:

“How can the platform team build security into the default path?”

## Question 5

**How should platform teams measure whether a golden path is successful?**

Expected themes:

- Adoption rate
- Reduced onboarding time
- Fewer support tickets
- Deployment success rate
- Fewer incidents
- Developer satisfaction

Follow-up:

“What metric would you show leadership?”

## Question 6

**What happens if documentation is treated as optional?**

Expected themes:

- More tickets
- More mistakes
- Slower onboarding
- Higher incident risk
- Inconsistent usage

Follow-up:

“How can documentation be tested or validated?”

## Question 7

**How do AWS costs connect to golden path design?**

Expected themes:

- Default resource sizes matter
- Logging retention impacts cost
- NAT Gateways and load balancers can add cost
- Tags help chargeback and reporting
- Environments should have cleanup rules

Follow-up:

“What cost guardrails would you add?”

## Question 8

**How does platform engineering support SRE goals?**

Expected themes:

- Standard dashboards
- Runbooks
- Ownership
- Alerting standards
- Rollback process
- Production readiness

Follow-up:

“What SRE requirement should be included in every golden path?”

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the main goal of platform engineering?

A. Replace developers  
B. Build reusable internal tools and workflows for application teams  
C. Remove all production approvals  
D. Avoid using cloud services  

**Answer:** B  
**Explanation:** Platform engineering helps developers deliver safely and efficiently through reusable internal platforms and workflows.

## Question 2: Multiple Choice

Which item is the best example of a golden path?

A. A one-time manual deployment  
B. A personal script stored on one engineer’s laptop  
C. A documented service template with CI/CD, Helm, Terraform inputs, and runbooks  
D. A production admin password shared in chat  

**Answer:** C  
**Explanation:** A golden path should be reusable, documented, secure, and supported.

## Question 3: True or False

A golden path should remove all flexibility from application teams.

**Answer:** False  
**Explanation:** A good golden path provides safe defaults and supported customization points.

## Question 4: Short Answer

Name three components that should be included in a golden path for containerized application delivery.

**Answer:** Examples include CI/CD template, Dockerfile, ECR image push, Helm chart, Terraform inputs, CloudWatch dashboard, runbook, ownership metadata.  
**Explanation:** A complete golden path covers build, deploy, operate, and support workflows.

## Question 5: Multiple Choice

In an AWS-based golden path, which service is commonly used to store container images?

A. CloudWatch  
B. IAM  
C. Amazon ECR  
D. Route 53  

**Answer:** C  
**Explanation:** Amazon ECR stores container images.

## Question 6: Multiple Choice

Which AWS service is most directly related to application logs and metrics in this class?

A. Amazon CloudWatch  
B. Amazon VPC  
C. Amazon Route 53  
D. AWS Organizations  

**Answer:** A  
**Explanation:** CloudWatch is used for logs, metrics, alarms, and dashboards.

## Question 7: Troubleshooting

A team uses a golden path template, but deployment fails because `owner_email` is missing. What should the platform team improve?

**Answer:** Add required input documentation and automated validation before deployment.  
**Explanation:** The issue should be prevented by clear documentation and pipeline checks.

## Question 8: Troubleshooting

A pipeline deploy stage fails because the Helm values file references namespace `payment-dev`, but the approved namespace is `payments-dev`. What is the likely issue?

**Answer:** Inconsistent or incorrect environment configuration.  
**Explanation:** Golden paths should provide clear naming standards and validation for required fields.

## Question 9: True or False

Documentation is part of the platform product.

**Answer:** True  
**Explanation:** Without documentation, reusable templates are difficult to use correctly.

## Question 10: Short Answer

What is developer self-service?

**Answer:** Developer self-service allows application teams to complete approved tasks using standard tools and workflows without waiting for manual tickets every time.  
**Explanation:** It improves speed while still using guardrails.

## Question 11: Multiple Choice

Which of the following is a poor golden path practice?

A. Required tags  
B. Clear README  
C. Production approval gate  
D. Using personal AWS access keys in the pipeline  

**Answer:** D  
**Explanation:** Pipelines should use secure IAM roles or approved identity patterns, not personal long-lived credentials.

## Question 12: Short Answer

Why does ownership metadata matter?

**Answer:** It identifies who owns the service, who receives alerts, who supports incidents, and who is accountable for cost and operational readiness.  
**Explanation:** Ownership is essential in enterprise production environments.

---

# 17. Homework Assignment

## Assignment Title

**Design a Developer Onboarding Workflow for a New Service**

## Scenario

Your company has a platform team that supports many application teams. Developers often open tickets asking how to create repos, set up pipelines, push Docker images, deploy to EKS, configure IAM, and view logs.

The platform team wants to reduce manual support by creating a standard onboarding workflow for new containerized services.

## Student Tasks

Create a 1 to 2 page onboarding workflow that includes:

1. Intake questions
2. Required application information
3. Repository creation process
4. CI/CD template selection
5. Docker image naming convention
6. Amazon ECR repository requirement
7. Amazon EKS namespace requirement
8. IAM pipeline role requirement
9. Helm values needed
10. CloudWatch monitoring and logging requirements
11. Required runbooks
12. Ownership metadata
13. Support and escalation path
14. Final handoff checklist

## Expected Deliverables

Students submit:

1. A Markdown or Word document
2. A simple workflow diagram
3. A required input table
4. A checklist for production readiness

## Submission Format

Acceptable formats:

- Markdown file
- PDF
- Word document
- Screenshot of diagram plus written explanation

## Estimated Completion Time

1.5 to 2 hours

## Grading Criteria

| Criteria | Points |
|---|---:|
| Clear onboarding workflow | 20 |
| Required inputs are complete | 20 |
| AWS services are correctly included | 15 |
| Security and IAM considerations included | 15 |
| Monitoring and runbook expectations included | 15 |
| Diagram is clear and useful | 10 |
| Professional formatting | 5 |
| Total | 100 |

## Optional Advanced Challenge

Pick one:

1. Add a section called `Supported vs Unsupported Customization` with at least 5 supported and 5 unsupported changes.
2. Reframe your onboarding workflow as a **scaffolder invocation**: write a Backstage `template.yaml` (or `cookiecutter.json`) whose parameters are your "intake questions," so onboarding becomes a button-click that produces a registered repo instead of a manual checklist.
3. Add a **platform scorecard**: define 6–8 DORA/DX measures (deployment frequency, lead time, change-failure rate, time to restore, adoption rate, time-to-first-deploy) and state the target and data source for each.

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Treating a golden path as only a CI/CD file | Students focus on pipelines from prior weeks | Explain that golden paths include docs, IaC, deployment, monitoring, ownership, and support |
| Skipping documentation | Students think code is enough | Emphasize README and runbooks as part of the product |
| Missing ownership metadata | Students focus only on deployment | Require owner team, email, support channel, and escalation path |
| Giving pipelines too much access | Students use admin permissions to avoid IAM issues | Teach least privilege and role-based access |
| Not separating dev and prod | Students simplify environments too much | Use separate values files and approval gates |
| Forgetting rollback | Students focus only on successful deployment | Require rollback runbook in every golden path |
| No validation | Students assume users will follow docs perfectly | Add pipeline validation, Helm lint, input checks |
| Overengineering the first version | Advanced students may add too much | Start with a simple supported path, then improve iteratively |
| Making the template too rigid | Students may lock every setting | Define supported customization points |
| Ignoring cost | Students forget cloud cost impact | Add tags, resource defaults, cleanup, and environment rules |

---

# 19. Real-World Enterprise Scenario

## Scenario

A mid-sized financial services company has 25 application teams. Every team deploys services differently.

Current problems:

- Some teams use GitHub Actions, others use GitLab CI
- Some Docker images are stored in public registries
- Some apps deploy to EKS manually
- IAM permissions are inconsistent
- CloudWatch logs are missing for several services
- There is no standard rollback process
- Platform team receives repeated tickets for the same setup tasks
- Security team is concerned about secrets and production approvals
- Finance wants better tagging for cost visibility

## How This Class Topic Applies

The platform team decides to create a golden path for containerized applications.

The golden path includes:

- Standard service repo template
- Standard pipeline template
- Amazon ECR image registry
- Amazon EKS deployment using Helm
- IAM role-based pipeline deployment
- CloudWatch logs and dashboards
- Required tags
- Rollback runbook
- Owner metadata
- Support channel
- Production approval gate

## Constraints

| Constraint | Example |
|---|---|
| Access control | App teams cannot have broad admin access |
| Security | No hardcoded secrets, image scanning required |
| Cost | Environments must be tagged and sized appropriately |
| Reliability | Apps must include probes, logs, and rollback steps |
| Production impact | Prod deployment requires approval |
| Team workflow | Changes must go through pull request or merge request review |

## Role Responsibilities

| Role | What They Would Do |
|---|---|
| DevOps Engineer | Build reusable CI/CD templates, Docker workflow, Helm deployment pattern |
| Cloud Engineer | Provide ECR, EKS, IAM, VPC, and Terraform module patterns |
| SRE | Define monitoring, alerting, runbooks, rollback, and production readiness expectations |

---

# 20. Instructor Tips

## Teaching Tips

- Use the phrase “platform as a product” early.
- Keep reminding students that the developer is the customer.
- Connect every platform concept to a problem students already saw in earlier weeks.
- Use examples from CI/CD, Terraform, Helm, and Kubernetes to make the topic concrete.
- Make the IDP (Backstage or Port) central, not a footnote: the portal + catalog + scaffolder is what a 2026 senior platform interview probes. Keep one vendor as the worked example but teach the *shape* (portal → scaffolder → control plane → GitOps) so students are not vendor-locked.
- Always contrast control-plane self-service (Crossplane/Operators) with CI-driven Terraform modules, and name GitOps (Argo CD/Flux) as the deploy path.

## Pacing Tips

- Do not spend too much time explaining every possible platform tool.
- Spend more time on golden path thinking and onboarding workflow.
- Keep AWS comparisons practical.
- Keep Class 1 design-oriented. Class 2 will focus more on building the template.

## Lab Support Tips

Students may struggle with:

- Knowing what belongs in README
- Separating app team ownership from platform team ownership
- Understanding what should be customizable
- Connecting ECR, EKS, IAM, and CloudWatch into one flow

Use the validation checklist to guide them.

## Helping Struggling Students

Give them this simplified pattern:

```text
Code
→ Build
→ Image
→ Deploy
→ Monitor
→ Support
```

Then ask them to fill in:

```text
Git
→ CI/CD
→ ECR
→ EKS
→ CloudWatch
→ Runbook
```

## Challenging Advanced Students

Ask advanced students to add:

- Helm values schema validation
- GitLab reusable includes
- GitHub reusable workflows
- Terraform module README
- Backstage catalog metadata
- CloudWatch dashboard template
- Security scan stage
- Cost tagging standard

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What platform engineering is
- [ ] Why golden paths exist
- [ ] Difference between DevOps, platform engineering, and SRE
- [ ] What developer self-service means
- [ ] Why documentation is part of the platform
- [ ] How golden paths reduce ticket volume
- [ ] How AWS services fit into a containerized app delivery path

## Students Should Be Able to Build or Configure

- [ ] A basic golden path design document
- [ ] A required inputs table
- [ ] A basic pipeline flow outline
- [ ] A sample Helm values file
- [ ] A sample Terraform input file
- [ ] An onboarding checklist
- [ ] A basic troubleshooting runbook

## Students Should Be Able to Troubleshoot

- [ ] Missing template inputs
- [ ] Inconsistent namespace names
- [ ] Missing owner metadata
- [ ] Confusing README instructions
- [ ] Missing validation stages
- [ ] Poor support and escalation instructions

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Explained platform engineering clearly
- [ ] Compared DevOps, platform engineering, and SRE
- [ ] Explained golden paths and paved roads
- [ ] Walked through AWS-based delivery flow
- [ ] Completed whiteboard diagram
- [ ] Completed golden path repo demo
- [ ] Started or completed student lab
- [ ] Reviewed troubleshooting scenario
- [ ] Assigned homework
- [ ] Explained how Class 2 will build on this design

## Student Checklist Before Leaving Class

- [ ] I can explain what a golden path is
- [ ] I can describe why platform teams create templates
- [ ] I can identify what belongs in a golden path
- [ ] I created or started a golden path design folder
- [ ] I understand the homework assignment
- [ ] I know how this connects to CI/CD, Terraform, Helm, ECR, EKS, IAM, and CloudWatch

## Items to Verify Before Moving to Class 2

Students should have:

- [ ] A basic golden path workflow idea
- [ ] A README draft or outline
- [ ] A list of required inputs
- [ ] A simple delivery flow diagram
- [ ] A basic understanding of what Class 2 will build
- [ ] Awareness that golden paths require documentation, validation, and ownership, not just code

---

## Class Artifacts & Validation

This class is design-focused: students **analyze** a real, on-disk golden path
repository (the `platform-golden-path` module) and the packaged deployment
pattern it embeds (the `helm-charts` module) before building their own in Class 2.
The artifacts below are the ones this class reads and walks through. Every path is
real and every command was run in this environment; results are honest.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/platform-golden-path/README.md` | docs | The sample golden-path module README students analyze (layout, paved-road defaults, tasks) | `test -f labs/platform-golden-path/README.md` | PASS |
| 2 | `labs/platform-golden-path/docs/golden-path.md` | docs | Paved-road explainer + ADR-001 (the design rationale this class teaches) | `test -f labs/platform-golden-path/docs/golden-path.md` | PASS |
| 3 | `labs/platform-golden-path/docs/architecture.mmd` | mermaid | Architecture diagram of the scaffold → build → scan → deploy flow | `grep -q 'graph' labs/platform-golden-path/docs/architecture.mmd` | PASS |
| 4 | `labs/platform-golden-path/solution/scaffold.sh` | shell | The generator students inspect as the "self-service" entry point | `shellcheck labs/platform-golden-path/solution/scaffold.sh` | PASS |
| 5 | `labs/platform-golden-path/solution/template/` | template | The paved-road service template (app, Dockerfile, chart, CI) inherited by every generated service | `cd labs/platform-golden-path && ./validate.sh` | PASS (32 passed, 0 failed) |
| 6 | `labs/helm-charts/solution/chart/webapp/` | helm | The packaged Kubernetes deployment pattern golden paths reuse (probes, limits, securityContext, conditional Ingress/HPA) | `helm lint labs/helm-charts/solution/chart/webapp` | PASS (1 linted, 0 failed) |

To reproduce the aggregate gates:

```bash
cd labs/platform-golden-path && ./validate.sh   # 32 passed, 0 failed (+ DEFERRED ruff/trivy/live-drill)
cd labs/helm-charts        && ./validate.sh     # 17 passed, 0 failed, 0 deferred
```

## Definition of Done

Ticked honestly for **this** class (design/analysis class backed by two validated modules):

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence) — the `platform-golden-path` and `helm-charts` modules are real on disk.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `validate.sh` runs above are green; helm/shellcheck gates re-run for this manifest.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — both modules ship `starter/` and `solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — present in both module READMEs.
- [x] **Cleanup/teardown** is provided and idempotent — `validate.sh`/`drill.sh` clean up temp dirs, images, and the kind namespace; `helm uninstall` documented.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — `solution/` is the reference; module READMEs carry the instructor answer keys; this class file carries the homework/quiz keys above.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `platform-golden-path` starter template is itself the reproducible broken state (pod rejected by `runAsNonRoot`); `helm-charts/broken/deployment.yaml` is an injected fault.
- [x] **Expected outputs** are shown for demos and labs — captured `validate.sh` output and `docs/evidence/drill-output.txt`.
- [x] **Cost & security warnings** present — both module READMEs document `$0` (all local) and least-privilege defaults.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — header links to the modules; the connection table verifies week numbers (Weeks 3/9/10/11–13/14–15/16–19/21).
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `test -f`/`ls` above.
