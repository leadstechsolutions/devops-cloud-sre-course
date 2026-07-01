# Week 20: Platform Engineering and Golden Paths
> **▶ Runnable lab for this class:** [`labs/helm-charts/`](../../labs/helm-charts/) · [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package

**Week:** 20  
**Track:** Unified DevOps · Cloud · SRE Track  
**Class title:** Building Golden Path Templates and Self-Service  

---

# 1. Class Overview

## Class Title

**Class 2: Building Reusable Golden Path Templates with CI/CD, Terraform, Helm, and AWS**

## Class Purpose

Class 2 takes the golden path design concepts from Class 1 and turns them into a practical starter template. Students will build a reusable structure that an application team could use to deliver a containerized application using CI/CD, Terraform inputs, Helm values, and AWS service patterns.

This class is not focused on creating a full production platform. It is focused on teaching students how platform teams package repeatable delivery workflows into usable templates.

## How This Class Builds from Class 1

Class 1 introduced:

- Platform engineering
- Golden paths
- Paved roads
- Developer self-service
- Developer onboarding workflows
- Template misuse due to unclear documentation

Class 2 continues by helping students build the actual template pieces:

- README
- Pipeline template
- Helm values files
- Terraform input file
- Runbooks
- Validation checklist
- Troubleshooting guidance

## What Students Will Build, Analyze, or Practice

Students will:

1. Build a simple golden path folder structure.
2. Create a reusable CI/CD pipeline template outline.
3. Create Helm values for dev and prod.
4. Create Terraform sample inputs.
5. Create deployment failure and rollback runbooks.
6. Validate the golden path template.
7. Troubleshoot a failed deployment caused by missing Helm values and weak validation.

---

# 2. Quick Review of Class 1

## Review Points

1. Platform engineering packages repeated DevOps work into reusable patterns.
2. Golden paths are the recommended, supported way to deliver software.
3. Developer self-service should be safe, documented, and controlled.
4. A golden path includes more than code. It includes documentation, ownership, runbooks, and validation.
5. AWS-based golden paths often connect Git, CI/CD, IAM, ECR, EKS, Helm, Terraform, and CloudWatch.
6. Poor documentation causes support tickets, failed deployments, and inconsistent usage.
7. Platform teams should treat internal developers as customers.
8. Golden paths should provide safe defaults and supported customization points.

## Quick Recall Questions

1. What is the difference between a golden path and a one-time deployment script?
2. Why does ownership metadata matter in a production service?
3. What AWS services were part of the golden path flow from Class 1?

## Common Gaps Students May Still Have

| Gap | How to Bridge It |
|---|---|
| Students may think platform engineering is only CI/CD | Remind them that it includes templates, infrastructure, docs, security, monitoring, and support |
| Students may not understand what should be customizable | Use supported vs unsupported customization examples |
| Students may focus only on successful deployment | Keep emphasizing rollback, logs, ownership, and runbooks |
| Students may confuse app team ownership and platform team ownership | Use a responsibility split table |
| Students may overbuild the template | Keep the first version simple and usable |

## Bridge Into Class 2

Instructor transition:

> In Class 1, we designed what a golden path should include. In Class 2, we will build a simple version of that golden path. The goal is not to create a perfect enterprise platform today. The goal is to understand how reusable templates are structured and how they help teams deliver applications safely.

---

# 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Build** a basic golden path folder structure for containerized application delivery.
2. **Configure** a conceptual CI/CD pipeline template with standard delivery stages.
3. **Create** Helm values files for dev and prod environments.
4. **Document** Terraform input examples for AWS resources used in the golden path.
5. **Explain** how ECR, EKS, IAM, VPC, and CloudWatch fit into the workflow.
6. **Validate** whether a golden path template has required documentation and inputs.
7. **Troubleshoot** a template misuse scenario caused by missing Helm values and weak validation.
8. **Improve** a golden path with documentation, validation, and runbooks.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 Knowledge

Students should understand:

- What platform engineering is
- What golden paths and paved roads are
- Why developer self-service matters
- Why documentation is part of a platform
- How app teams and platform teams share responsibilities
- Why missing documentation causes support tickets

## Required Prior Concepts

Students should already know:

- Basic Git repo structure
- Basic CI/CD stages
- Docker image concepts
- Amazon ECR purpose
- Amazon EKS purpose
- Helm values concept
- Terraform input variables concept
- CloudWatch logs and metrics concept
- IAM least privilege basics

## Required Tools Already Installed

Students should have:

- VS Code
- Git
- Terminal
- Optional: Docker
- Optional: Terraform
- Optional: Helm
- Optional: kubectl
- Optional: AWS CLI

This class can be completed locally without creating live AWS resources.

## Required Files, Repos, or Lab Outputs from Class 1

Students may use their Class 1 design folder if available:

```text
student-golden-path-design/
```

If they do not have it, they can start fresh in Class 2.

---

# 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Starter Template | A reusable project structure that gives teams a ready starting point | A platform team provides a repo template for new microservices |
| Pipeline Template | A reusable CI/CD workflow definition | GitLab CI includes or GitHub reusable workflows standardize build and deploy |
| Helm Values | Configuration files that customize a Helm chart | Dev and prod may use different replica counts, image tags, and resource limits |
| Terraform Inputs | Values passed into Terraform modules | App name, environment, region, ECR repo, IAM role, and tags |
| Required Inputs | Values that must be provided for the template to work correctly | Missing namespace or owner email can break deployment or support |
| Validation | Automated checks that catch mistakes early | Pipeline checks for missing Dockerfile, missing Helm values, or invalid YAML |
| Manual Approval | A required human approval before production deployment | Common for prod releases in regulated or enterprise environments |
| Rollback Runbook | A step-by-step guide to return to a known good version | Used when a deployment causes errors or downtime |
| Safe Defaults | Preconfigured settings that follow good practices | Default resource limits, required tags, logging enabled, scan stage enabled |
| Unsupported Customization | Changes teams should not make because they create risk | Removing security scanning, bypassing approval, disabling logging |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| VS Code | Edit README, YAML, Terraform input files, and runbooks |
| Terminal | Create folders, inspect files, and validate structure |
| Git | Version control for templates and application onboarding |
| GitLab CI or GitHub Actions | Represents reusable pipeline templates |
| YAML | Used for pipeline definitions and Helm values |
| Markdown | Used for README files, runbooks, and documentation |
| Terraform | Represents reusable infrastructure input patterns |
| Helm | Represents Kubernetes deployment standardization |
| AWS CLI, optional | Can validate AWS account identity or show conceptual AWS integration |
| Backstage, overview only | Example of a service catalog or developer portal |

---

# 7. AWS Services Used

| AWS Service | How It Connects |
|---|---|
| Amazon ECR | Stores container images built by the pipeline |
| Amazon EKS | Runs the Kubernetes workload deployed by Helm |
| IAM | Provides pipeline deployment permissions through roles |
| VPC | Network foundation where EKS and related resources run |
| CloudWatch | Provides logs, metrics, dashboards, and alerting |
| S3, optional | Can store artifacts or Terraform state in advanced versions |
| DynamoDB, optional | Can support Terraform state locking in advanced workflows |
| Secrets Manager, optional | Can support secure runtime configuration |

## AWS Flow for Class 2

```text
Git repo
→ CI/CD template
→ IAM deployment role
→ Docker image build
→ Amazon ECR
→ Helm deployment
→ Amazon EKS
→ CloudWatch logs and metrics
→ Runbook and ownership
```

---

# 8. Azure and GCP Comparison Notes

| Platform Need | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Kubernetes platform | Amazon EKS | Azure Kubernetes Service | Google Kubernetes Engine |
| Identity | IAM roles | Managed Identity / Azure RBAC | Cloud IAM |
| Observability | CloudWatch | Azure Monitor | Cloud Monitoring |
| Infrastructure as Code | Terraform AWS Provider | Terraform AzureRM Provider | Terraform Google Provider |

Instructor note:

Do not spend too much time here. Reinforce that the **golden path pattern** is cloud-agnostic, while implementation details change by provider.

---

# 9. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:15 | Review Class 1 golden path concepts |
| 0:15 to 0:40 | Anatomy of a golden path template |
| 0:40 to 1:10 | CI/CD reusable template design |
| 1:10 to 1:30 | Terraform module inputs and Helm chart standardization |
| 1:30 to 1:40 | Break |
| 1:40 to 2:20 | Instructor demo: build a simple golden path template |
| 2:20 to 2:50 | Student lab: build golden path template |
| 2:50 to 3:00 | Review, discussion, homework, and week closeout |

---

# 10. Instructor Lesson Plan

## 0:00 to 0:15 - Review Class 1

### Explain

Start with a short recap:

> Last class, we designed a golden path. Today, we will build the starter version of that golden path.

Review the Class 1 delivery flow:

```text
Developer
→ Git template
→ CI/CD pipeline
→ ECR
→ EKS
→ CloudWatch
→ Runbook
```

### Ask

- What should every golden path include?
- Why is documentation not optional?
- What happens when required inputs are unclear?

---

## 0:15 to 0:40 - Anatomy of a Golden Path Template

### Explain

A usable golden path template should include:

1. README
2. CI/CD template
3. Helm values
4. Terraform inputs
5. Runbooks
6. Validation checklist
7. Ownership metadata

### Show

Display this starter structure:

```text
simple-golden-path/
├── README.md
├── ci/
├── helm/
├── terraform/
└── runbooks/
```

### Teaching Tip

Keep it simple. Students do not need to build a full production platform. They need to understand reusable structure.

---

## 0:40 to 1:10 - CI/CD Reusable Template Design

### Explain

A reusable CI/CD template should have predictable stages:

```text
validate
test
build
scan
push
deploy-dev
approve-prod
deploy-prod
rollback
```

Explain each stage:

| Stage | Purpose |
|---|---|
| validate | Check required files and inputs |
| test | Run app tests |
| build | Build container image |
| scan | Check for vulnerabilities or secrets |
| push | Push image to ECR |
| deploy-dev | Deploy to non-prod |
| approve-prod | Require manual approval |
| deploy-prod | Deploy production |
| rollback | Restore last known good version |

### Pause for Questions

Ask:

> What should fail early before deployment starts?

Expected answers:

- Missing Dockerfile
- Missing Helm values
- Missing image repository
- Missing namespace
- Missing owner metadata

---

## 1:10 to 1:30 - Terraform Inputs and Helm Standardization

### Explain

Terraform and Helm help standardize two different layers:

| Layer | Tool | What It Standardizes |
|---|---|---|
| Infrastructure | Terraform | ECR, IAM role, namespace request, CloudWatch dashboard |
| Kubernetes app deployment | Helm | Deployment values, image, replicas, resources, service port |

### Show

Explain the difference:

```text
Terraform inputs answer:
What cloud resources does this service need?

Helm values answer:
How should this app run in Kubernetes?
```

---

## 1:30 to 1:40 - Break

Ask students to return ready to build their own golden path template.

---

## 1:40 to 2:20 - Instructor Demo

The instructor builds the template live using commands and file examples from Section 13.

### Teaching Tip

Narrate the “why” for every file:

- README reduces confusion
- Pipeline template creates consistency
- Helm values control runtime behavior
- Terraform inputs standardize cloud resources
- Runbooks support production operations

---

## 2:20 to 2:50 - Student Lab

Students build their own template.

Instructor should walk around or monitor chat for:

- Wrong folder nesting
- YAML indentation issues
- Missing required inputs
- No ownership metadata
- No rollback steps

---

## 2:50 to 3:00 - Wrap-Up

Recap:

- Golden paths must be usable, not just technically correct.
- Templates need documentation and validation.
- AWS resources should be referenced through clear inputs.
- Runbooks and ownership make services supportable.

Preview next module or capstone:

> This week prepares you to build your DevOps capstone because your capstone should not just deploy an app. It should demonstrate a repeatable delivery pattern.

---

# 11. Instructor Lecture Notes

## Opening Talking Point

> Class 1 was about the design of a golden path. Class 2 is about packaging that design into something an application team could actually use.

## Concept 1: A Template Is a Product

A platform template is not just a folder of files. It is a product used by developers.

A good template should answer:

- What is this for?
- Who should use it?
- What inputs are required?
- What is safe to customize?
- What should not be changed?
- How do I deploy?
- How do I troubleshoot?
- Who supports this?

### Common Misconception

Students may think “if the YAML works, the template is done.”

Clarify:

A template that works only when the platform engineer explains it manually is not a good self-service template.

---

## Concept 2: Pipeline Templates Need Guardrails

A pipeline template should not only deploy. It should protect teams from mistakes.

Examples:

- Validate required files
- Check that Helm values exist
- Check that image repository is set
- Scan for secrets or vulnerabilities
- Require approval for production
- Prevent deployments from untrusted branches

### Talking Point

> The best time to catch an error is before deployment, not after production is broken.

---

## Concept 3: Terraform Inputs Should Hide Complexity

Application teams should not need to understand every detail of IAM, ECR, or CloudWatch to onboard a service.

Terraform modules help platform teams expose simplified inputs:

```hcl
application_name = "orders-api"
environment      = "dev"
owner_team       = "payments"
```

Behind those inputs, the platform team can create consistent resources.

### Enterprise Context

In a real company, standard Terraform modules also enforce:

- Tags
- Naming conventions
- Encryption
- IAM boundaries
- Logging
- Cost allocation

---

## Concept 4: Helm Values Should Be Clear and Safe

Helm values give app teams controlled customization.

Examples:

- Image tag
- Replica count
- Environment variables
- CPU and memory
- Service port
- Owner metadata

Students should understand that Helm values are powerful, but unsafe values can break deployments.

---

## Concept 5: Runbooks Complete the Delivery Pattern

A delivery template is incomplete without operational guidance.

Every golden path should include:

- Deployment failure runbook
- Rollback runbook
- Where to find logs
- Who to contact
- How to validate the service
- What to do during an incident

### Talking Point

> Production readiness is not just whether the app deploys. It is whether the team can support it when something goes wrong.

---

## Concept 6: Reusability Is the Whole Point — Build It, Don't Hand-Copy It

A template that each team copies is not a golden path; it is shared toil. Real reusability uses a single source the platform owns and services *consume*:

- **GitHub:** a reusable workflow called with `uses: acme/golden-path/.github/workflows/reusable-deliver.yml@v1` (`on: workflow_call`).
- **GitLab:** a shared file consumed with `include: { project: 'acme/golden-path', file: '/Golden-Path.gitlab-ci.yml' }`.
- **Helm:** one chart (`Chart.yaml` + `templates/`) consumed by every service via its own `values.yaml`, optionally as a chart dependency.

Because the app team never owns the scan/auth stages, they *cannot* remove them — the paved road is enforced, not suggested.

## Concept 7: Wire In Security as Enforced Defaults (W19 + W17), Not Placeholders

The golden path is where DevSecOps controls stop being optional:

- **Trivy** image scan with `exit-code: "1"` and **Checkov** IaC/Helm scan with `soft_fail: false` — the build *fails* on CRITICAL/HIGH or policy violations.
- **OIDC keyless auth (W17):** CI assumes a role via `aws-actions/configure-aws-credentials@v4` with `permissions: id-token: write`. No long-lived `AWS_ACCESS_KEY_ID` secrets anywhere.
- **values.schema.json:** bad Helm inputs fail at `helm lint`/`helm template`, before any cluster is touched.

This is the concrete answer to "how does your golden path make the safe path the easy path."

## Concept 8: GitOps Is the Deploy Mechanism

CI's responsibility ends at "build, scan, push, update desired state in Git." **Argo CD / Flux** reconciles the chart onto EKS with `selfHeal` and `prune`. Benefits to state in an interview: drift correction, full audit trail (every change is a commit), rollback-by-revert, and clean multi-tenancy via Argo CD `ApplicationSet`. This connects the golden path to the Week 11–13 Kubernetes/Helm material and the capstone.

---

# 12. Whiteboard Explanation

## Simple Diagram: Class 2 Template Build

```text
Class 1 Design
   |
   | turns into
   v
Golden Path Template
   |
   | includes
   v
README + CI/CD + Helm + Terraform + Runbooks
   |
   | supports
   v
Application Team Delivery
   |
   | through
   v
ECR + EKS + IAM + CloudWatch
```

## Step-by-Step Flow

1. **README**  
   Explains who should use the template and how.

2. **CI/CD Template**  
   Defines repeatable build, scan, push, and deploy stages.

3. **Terraform Inputs**  
   Define required cloud resource inputs.

4. **Helm Values**  
   Define how the application runs in Kubernetes.

5. **Runbooks**  
   Explain what to do when deployment or production support fails.

6. **AWS Services**  
   ECR stores images, EKS runs workloads, IAM controls access, CloudWatch provides visibility.

---

## Enterprise Version

```text
Developer Portal / Service Catalog
   |
   | creates service from template
   v
GitHub or GitLab Repo
   |
   | reusable workflow
   v
CI/CD Platform
   |
   | assumes IAM role
   | validates inputs
   | builds image
   | scans image
   | pushes image
   v
Amazon ECR
   |
   | deploys through Helm
   v
Amazon EKS
   |
   | sends logs and metrics
   v
Amazon CloudWatch
   |
   | links to
   v
Runbooks + Ownership + Support Channel
```

## How Class 2 Extends Class 1

| Class 1 | Class 2 |
|---|---|
| Defined golden path concept | Builds golden path structure |
| Designed onboarding workflow | Creates template files |
| Discussed documentation gaps | Writes README and runbooks |
| Reviewed misuse scenario | Adds validation and required inputs |
| Mapped AWS services conceptually | Places AWS services into template workflow |

---

# 13. Instructor Demo Script

## Demo Title

**Building a Basic Golden Path Template**

## Demo Objective

Build a simple local golden path template that includes CI/CD, Helm, Terraform input examples, README documentation, and runbooks.

## Required Setup

Instructor needs:

- Terminal
- VS Code
- No live AWS resources required
- Optional Git repository

## Step 1: Create Folder Structure

```bash
mkdir -p simple-golden-path/{ci,helm,terraform,runbooks,docs}
cd simple-golden-path
touch README.md
touch ci/pipeline-template.yml
touch helm/values-dev.yaml helm/values-prod.yaml
touch terraform/sample-inputs.tfvars
touch runbooks/deployment-failure.md runbooks/rollback.md
```

## Expected Output

```bash
find . -maxdepth 3 -type f | sort
```

```text
./README.md
./ci/pipeline-template.yml
./docs
./helm/values-dev.yaml
./helm/values-prod.yaml
./runbooks/deployment-failure.md
./runbooks/rollback.md
./terraform/sample-inputs.tfvars
```

## Explain

> This is the minimum structure for today. In a real enterprise, this may become a Git repo template or service catalog template.

---

## Step 2: Create README

```bash
cat > README.md <<'README_EOF'
# Simple Golden Path for Containerized App Delivery

## Purpose
This template helps application teams deploy a containerized application using approved DevOps and AWS platform patterns.

## Supported Workflow
1. Validate required files
2. Build container image
3. Scan image
4. Push image to Amazon ECR
5. Deploy to dev using Helm
6. Require approval for production
7. Deploy to production
8. Use runbooks for troubleshooting and rollback

## Required Inputs
| Input | Description | Example |
|---|---|---|
| application_name | Name of the service | orders-api |
| environment | Deployment environment | dev |
| aws_region | AWS region | us-east-1 |
| ecr_repository | ECR repository name | orders-api |
| eks_namespace | EKS namespace | orders-dev |
| owner_team | Responsible team | payments |
| owner_email | Support contact | payments@example.com |
| support_channel | Support channel | #payments-support |

## Supported Customization
- Image tag
- Replica count within approved limits
- Environment variables
- Resource requests and limits
- Dev and prod values files

## Unsupported Changes
- Removing security scan stages
- Bypassing production approval
- Using personal AWS credentials
- Disabling logs or monitoring
- Removing ownership metadata
README_EOF
```

## Explain

> The README is the front door. If this file is unclear, the template will create more support tickets instead of reducing them.

---

## Step 3: Create Pipeline Template

```bash
cat > ci/pipeline-template.yml <<'PIPELINE_EOF'
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
  APP_NAME: "orders-api"
  ECR_REPOSITORY: "orders-api"

validate:
  stage: validate
  script:
    - echo "Validating required files"
    - test -f README.md
    - test -f helm/values-dev.yaml
    - test -f helm/values-prod.yaml
    - test -f terraform/sample-inputs.tfvars

test:
  stage: test
  script:
    - echo "Running application tests"

build:
  stage: build
  script:
    - echo "Building Docker image for $APP_NAME"

scan:
  stage: scan
  script:
    - echo "Running image and dependency scans"

push:
  stage: push
  script:
    - echo "Pushing image to Amazon ECR repository $ECR_REPOSITORY"

deploy_dev:
  stage: deploy_dev
  script:
    - echo "Deploying to dev using Helm"

approve_prod:
  stage: approve_prod
  when: manual
  script:
    - echo "Manual approval required before production deployment"

deploy_prod:
  stage: deploy_prod
  script:
    - echo "Deploying to production using Helm"
PIPELINE_EOF
```

## Expected Output

```bash
cat ci/pipeline-template.yml
```

The file should show pipeline stages from validation through production deployment.

## Explain

> This `echo` pipeline shows the *stage shape* only. In Steps 10–12 we replace it with a real reusable GitHub workflow (`workflow_call`) that actually scans (Trivy/Checkov), authenticates with OIDC, pushes to ECR, and deploys via GitOps. Treat this file as the storyboard; the runnable version comes later in the demo.

---

## Step 4: Create Helm Dev Values

```bash
cat > helm/values-dev.yaml <<'DEV_VALUES_EOF'
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
DEV_VALUES_EOF
```

## Step 5: Create Helm Prod Values

```bash
cat > helm/values-prod.yaml <<'PROD_VALUES_EOF'
appName: orders-api
namespace: orders-prod

image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/orders-api
  tag: "1.0.0"

replicaCount: 3

service:
  port: 8080

resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
  limits:
    cpu: "1000m"
    memory: "1Gi"

owner:
  team: payments
  email: payments@example.com
  supportChannel: "#payments-support"
PROD_VALUES_EOF
```

## Explain

> Dev and prod values are separated because production usually needs different replicas, resource sizing, image tags, and approval gates.

---

## Step 6: Create Terraform Inputs

```bash
cat > terraform/sample-inputs.tfvars <<'TFVARS_EOF'
application_name = "orders-api"
environment      = "dev"
aws_region       = "us-east-1"

ecr_repository_name = "orders-api"
eks_namespace       = "orders-dev"
pipeline_role_name  = "orders-api-dev-pipeline-role"

owner_team      = "payments"
owner_email     = "payments@example.com"
support_channel = "#payments-support"
cost_center     = "finance-platform"
data_class      = "internal"
TFVARS_EOF
```

## Explain

> These inputs could feed reusable Terraform modules that create ECR, IAM roles, dashboards, tags, or namespace-related resources.

---

## Step 7: Create Deployment Failure Runbook

```bash
cat > runbooks/deployment-failure.md <<'FAILURE_EOF'
# Deployment Failure Runbook

## Symptoms
- Pipeline deploy stage failed
- Helm command failed
- Pods are not starting
- Service endpoint is unavailable

## Investigation Steps
1. Check the failed pipeline stage.
2. Confirm Helm values file exists.
3. Confirm image repository and tag are correct.
4. Confirm namespace is correct.
5. Check application owner metadata.
6. Review Kubernetes events.
7. Review application logs.

## Common Causes
- Missing required Helm value
- Wrong namespace
- Wrong image tag
- IAM role does not have required permissions
- Image was not pushed to ECR
- Resource limits too low

## Escalation
Contact the application owner and platform support channel.
FAILURE_EOF
```

---

## Step 8: Create Rollback Runbook

```bash
cat > runbooks/rollback.md <<'ROLLBACK_EOF'
# Rollback Runbook

## When to Use
Use this runbook when a deployment causes errors, failed health checks, or customer impact.

## Steps
1. Confirm the current failed release.
2. Identify the last known good image tag or Helm release revision.
3. Review current error rate and logs.
4. Roll back using the approved deployment process.
5. Validate pods are healthy.
6. Confirm the service endpoint works.
7. Notify owner team and support channel.
8. Document the incident notes.

## Example Commands
helm history <release-name> -n <namespace>
helm rollback <release-name> <revision> -n <namespace>
kubectl get pods -n <namespace>
kubectl logs deployment/<deployment-name> -n <namespace>
ROLLBACK_EOF
```

---

---

## Step 9: Make the Helm Chart REAL (so `helm template` renders and `helm install` works)

The values files above are not a chart — there is no `Chart.yaml` and no `templates/`, so nothing can install. Build the actual chart now. This is the difference between describing a golden path and shipping one.

```bash
mkdir -p helm/app-chart/templates
cat > helm/app-chart/Chart.yaml <<'CHART_EOF'
apiVersion: v2
name: app-chart
description: Golden-path Helm chart for a containerized service
type: application
version: 0.1.0
appVersion: "1.0.0"
CHART_EOF
```

Default values (paved-road defaults: non-root, probes, requests/limits, owner metadata):

```bash
cat > helm/app-chart/values.yaml <<'VALUES_EOF'
appName: sample-app
namespace: default
replicaCount: 2

image:
  repository: public.ecr.aws/nginx/nginx
  tag: "stable"
  pullPolicy: IfNotPresent

service:
  port: 80
  targetPort: 80

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
VALUES_EOF
```

Deployment template (non-root securityContext, liveness/readiness probes, owner labels):

```bash
cat > helm/app-chart/templates/deployment.yaml <<'DEPLOY_EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}
  labels:
    app: {{ .Values.appName }}
    owner: {{ .Values.owner.team }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: {{ .Values.appName }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          volumeMounts:
            # readOnlyRootFilesystem: true, so give the default nginx image
            # writable paths via emptyDir or it CrashLoopBackOffs on a real install.
            - name: cache
              mountPath: /var/cache/nginx
            - name: run
              mountPath: /var/run
          readinessProbe:
            httpGet:
              path: /
              port: {{ .Values.service.targetPort }}
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: {{ .Values.service.targetPort }}
            initialDelaySeconds: 15
            periodSeconds: 20
          resources:
            requests:
              cpu: {{ .Values.resources.requests.cpu | quote }}
              memory: {{ .Values.resources.requests.memory | quote }}
            limits:
              cpu: {{ .Values.resources.limits.cpu | quote }}
              memory: {{ .Values.resources.limits.memory | quote }}
      volumes:
        - name: cache
          emptyDir: {}
        - name: run
          emptyDir: {}
DEPLOY_EOF
```

Service template:

```bash
cat > helm/app-chart/templates/service.yaml <<'SVC_EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}
  labels:
    app: {{ .Values.appName }}
spec:
  selector:
    app: {{ .Values.appName }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
SVC_EOF
```

A `values.schema.json` so bad inputs fail at `helm template`, not in production (this is the enforced validation the review asked for):

```bash
cat > helm/app-chart/values.schema.json <<'SCHEMA_EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["appName", "image", "owner"],
  "properties": {
    "appName": { "type": "string", "minLength": 1 },
    "replicaCount": { "type": "integer", "minimum": 1 },
    "image": {
      "type": "object",
      "required": ["repository", "tag"],
      "properties": {
        "repository": { "type": "string", "minLength": 1 },
        "tag": { "type": "string", "minLength": 1 }
      }
    },
    "owner": {
      "type": "object",
      "required": ["team", "email"],
      "properties": {
        "team": { "type": "string", "minLength": 1 },
        "email": { "type": "string", "format": "email", "minLength": 1 }
      }
    }
  }
}
SCHEMA_EOF
```

### Render it (this actually runs)

```bash
helm lint helm/app-chart
helm template sample-app helm/app-chart \
  --set appName=orders-api --set owner.team=payments --set owner.email=payments@example.com
```

The empty `image.repository` or missing `owner.email` from the troubleshooting scenario now fails at render time because of the schema — shift-left validation made real.

> Cost/safety note: `helm template` and `helm lint` are local and free. `helm install` against a real cluster creates resources — only run it against a throwaway kind/minikube cluster or a sandbox EKS namespace, and `helm uninstall sample-app -n <ns>` when done.

---

## Step 10: Make the CI Template REAL and REUSABLE (GitHub `workflow_call`)

The `echo` pipeline is not reusable — every service hand-copies it. A golden-path CI template is a **reusable workflow** another repo calls, with W19 scanning and W17 OIDC keyless auth as enforced defaults (no static AWS keys).

The reusable workflow (lives in the platform repo, e.g. `acme/golden-path/.github/workflows/deliver.yml`):

```bash
mkdir -p .github/workflows
cat > .github/workflows/reusable-deliver.yml <<'REUSABLE_EOF'
name: golden-path-deliver
on:
  workflow_call:
    inputs:
      app_name:      { required: true,  type: string }
      ecr_repository: { required: true,  type: string }
      aws_region:    { required: false, type: string, default: us-east-1 }
    secrets:
      aws_role_arn:  { required: true }   # OIDC role to assume (W17), no static keys

permissions:
  contents: read
  id-token: write   # REQUIRED for OIDC keyless auth (W17)

jobs:
  deliver:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate required golden-path files
        run: |
          test -f helm/app-chart/Chart.yaml
          test -f helm/app-chart/values.yaml

      - name: Helm lint (enforces values.schema.json)
        uses: azure/setup-helm@v4
      - run: helm lint helm/app-chart

      - name: Checkov IaC + Helm scan (W19 enforced gate)
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: .
          soft_fail: false        # fail the build on policy violations

      - name: Build image
        run: docker build -t "${{ inputs.app_name }}:${{ github.sha }}" .

      - name: Trivy image scan (W19 enforced gate)
        uses: aquasecurity/trivy-action@0.28.0
        with:
          image-ref: "${{ inputs.app_name }}:${{ github.sha }}"
          severity: CRITICAL,HIGH
          exit-code: "1"          # block on CRITICAL/HIGH findings

      - name: Configure AWS via OIDC (W17 — keyless, no long-lived keys)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.aws_role_arn }}
          aws-region: ${{ inputs.aws_region }}

      - name: Login to ECR and push
        run: |
          aws ecr get-login-password --region "${{ inputs.aws_region }}" \
            | docker login --username AWS --password-stdin \
              "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${{ inputs.aws_region }}.amazonaws.com"
          ECR="$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${{ inputs.aws_region }}.amazonaws.com/${{ inputs.ecr_repository }}"
          docker tag "${{ inputs.app_name }}:${{ github.sha }}" "$ECR:${{ github.sha }}"
          docker push "$ECR:${{ github.sha }}"
REUSABLE_EOF
```

The **caller** workflow in a service repo — this is all an app team writes (the self-service surface is ~10 lines):

```bash
cat > .github/workflows/ci.yml <<'CALLER_EOF'
name: ci
on:
  push:
    branches: [main]
jobs:
  golden-path:
    uses: acme/golden-path/.github/workflows/reusable-deliver.yml@v1
    with:
      app_name: orders-api
      ecr_repository: orders-api
    secrets:
      aws_role_arn: ${{ secrets.GOLDEN_PATH_OIDC_ROLE_ARN }}
CALLER_EOF
```

### Explain

> The app team gets scanning (Trivy + Checkov), OIDC keyless auth, lint, and schema validation *for free and enforced* — they cannot remove the scan stage because they never own it. `soft_fail: false` and `exit-code: "1"` mean the paved road actually blocks the unsafe path. (GitLab equivalent: a `Golden-Path.gitlab-ci.yml` consumed via `include: { project: 'acme/golden-path', file: '/Golden-Path.gitlab-ci.yml' }`.)

---

## Step 11: Make the Terraform a REAL Module (so `terraform plan` works)

The `.tfvars` file has no module behind it, so nothing plans. Build a minimal real module that provisions the ECR repo and the OIDC-assumable pipeline role, with required tags from W18.

```bash
mkdir -p terraform/modules/service terraform/environments/dev
cat > terraform/modules/service/variables.tf <<'TFVAR_EOF'
variable "application_name" { type = string }
variable "environment"      { type = string }
variable "aws_region"       { type = string }
variable "owner_team"       { type = string }
variable "cost_center"      { type = string }
variable "github_org_repo"  { type = string } # e.g. acme/orders-api, for OIDC trust
TFVAR_EOF

cat > terraform/modules/service/main.tf <<'TFMAIN_EOF'
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Application = var.application_name
    Environment = var.environment
    Owner       = var.owner_team
    CostCenter  = var.cost_center
    ManagedBy   = "golden-path-terraform"
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.application_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true        # W19: registry scanning on by default
  }
  tags = local.common_tags
}

# OIDC provider for GitHub Actions keyless auth (W17). One per account; referenced here.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${var.application_name}-${var.environment}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = local.common_tags
}

# Least-privilege: push to this repo only (W6/W17)
resource "aws_iam_role_policy" "ecr_push" {
  name = "ecr-push"
  role = aws_iam_role.pipeline.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
      { Effect = "Allow",
        Action = ["ecr:BatchCheckLayerAvailability","ecr:PutImage","ecr:InitiateLayerUpload","ecr:UploadLayerPart","ecr:CompleteLayerUpload"],
        Resource = aws_ecr_repository.this.arn }
    ]
  })
}

output "ecr_repository_url" { value = aws_ecr_repository.this.repository_url }
output "pipeline_role_arn"  { value = aws_iam_role.pipeline.arn }
TFMAIN_EOF
```

Environment wiring that consumes the module:

```bash
cat > terraform/environments/dev/main.tf <<'TFENV_EOF'
module "service" {
  source           = "../../modules/service"
  application_name = "orders-api"
  environment      = "dev"
  aws_region       = "us-east-1"
  owner_team       = "payments"
  cost_center      = "finance-platform"
  github_org_repo  = "acme/orders-api"
}
TFENV_EOF
```

### Render before apply (the plan/render discipline)

```bash
cd terraform/environments/dev
terraform init
terraform validate
terraform plan      # render and review BEFORE any apply
# terraform apply   # only in a sandbox account; creates a billable ECR repo + IAM role
cd -
```

> Cost/security note: `init`/`validate`/`plan` make no changes. `apply` creates a real ECR repository (storage cost) and an IAM role — run only in a sandbox. Tear down with `terraform destroy` from `terraform/environments/dev`. OpenTofu users can substitute `tofu` for every `terraform` command; the configuration is identical.

---

## Step 12: Add the GitOps Deploy Path (Argo CD Application)

The pipeline pushes the image; **Argo CD** reconciles the chart onto EKS. No `helm upgrade` from CI, no laptop `kubectl`.

```bash
mkdir -p gitops
cat > gitops/application.yaml <<'ARGO_EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: orders-api
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/acme/orders-api.git
    targetRevision: main
    path: helm/app-chart
    helm:
      valueFiles:
        - ../../helm/values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: orders-dev
  syncPolicy:
    automated:
      prune: true        # remove resources deleted from Git
      selfHeal: true     # correct drift automatically
    syncOptions:
      - CreateNamespace=true
ARGO_EOF
```

### Explain

> Rollback is now `git revert`; drift is corrected by `selfHeal`; every deploy is an auditable commit. This is how the golden-path app actually reaches EKS in 2026, and it connects directly to the Week 11–13 Kubernetes/Helm work and the Week 23–24 capstone.

---

## Step 13: Validate Files

```bash
find . -maxdepth 4 -type f | sort
```

Expected output now includes the real artifacts:

```text
./.github/workflows/ci.yml
./.github/workflows/reusable-deliver.yml
./README.md
./ci/pipeline-template.yml
./gitops/application.yaml
./helm/app-chart/Chart.yaml
./helm/app-chart/templates/deployment.yaml
./helm/app-chart/templates/service.yaml
./helm/app-chart/values.schema.json
./helm/app-chart/values.yaml
./helm/values-dev.yaml
./helm/values-prod.yaml
./runbooks/deployment-failure.md
./runbooks/rollback.md
./terraform/environments/dev/main.tf
./terraform/modules/service/main.tf
./terraform/modules/service/variables.tf
./terraform/sample-inputs.tfvars
```

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| YAML indentation errors | Copy or spacing issue | Open file in VS Code and fix spacing |
| Folder missing | Command run from wrong directory | Run `pwd` and recreate missing folders |
| `cat > file` not working in PowerShell | Shell difference | Use VS Code manual file creation |
| Students think pipeline is production-ready | Demo is conceptual | Explain where real Docker, AWS CLI, and Helm commands would go |
| Too much time spent on exact syntax | Class goal is template thinking | Keep focus on reusable structure |

## Cleanup Steps

```bash
cd ..
rm -rf simple-golden-path
```

If using the demo in future classes or capstone examples, keep the folder.

---

# 14. Student Lab Manual

## Lab Title

**Build a Simple Golden Path Template for Containerized App Delivery**

## Lab Objective

Students will build a local golden path starter template with pipeline stages, Helm values, Terraform sample inputs, documentation, and runbooks.

## Estimated Time

35 to 45 minutes

## Student Prerequisites

Students should understand:

- Class 1 golden path design
- Basic folder structures
- Basic YAML and Markdown
- Basic CI/CD stages
- Basic Helm values
- Basic Terraform inputs

## Starting Point from Class 1

Students may continue from:

```text
student-golden-path-design/
```

Or start fresh:

```text
student-golden-path/
```

## Architecture or Workflow Overview

```text
Application Code
   |
   v
CI/CD Template
   |
   | build and scan
   v
Amazon ECR
   |
   | deploy with Helm
   v
Amazon EKS
   |
   | observe
   v
Amazon CloudWatch
   |
   | support
   v
Runbooks and Owner Metadata
```

---

## Step 1: Create Folder Structure

```bash
mkdir -p student-golden-path/{ci,helm,terraform,runbooks,docs}
cd student-golden-path
touch README.md
touch ci/pipeline-template.yml
touch helm/values-dev.yaml
touch helm/values-prod.yaml
touch terraform/sample-inputs.tfvars
touch runbooks/deployment-failure.md
touch runbooks/rollback.md
```

## Step 2: Add README Content

Add to `README.md`:

```markdown
# Student Golden Path Template

## Purpose
This golden path helps application teams deploy a containerized service using approved DevOps and AWS platform patterns.

## Supported Application Type
- Containerized web application
- Containerized API service

## Supported AWS Services
- Amazon ECR
- Amazon EKS
- IAM
- CloudWatch

## Required Inputs
| Input | Description | Example |
|---|---|---|
| application_name | Service name | inventory-api |
| environment | Deployment environment | dev |
| aws_region | AWS region | us-east-1 |
| ecr_repository | Container image repository | inventory-api |
| eks_namespace | Kubernetes namespace | inventory-dev |
| owner_team | Responsible team | inventory |
| owner_email | Support contact | inventory@example.com |
| support_channel | Support channel | #inventory-support |

## Supported Customization
- Image tag
- Replica count
- Environment variables
- Resource requests and limits

## Unsupported Changes
- Removing scanning
- Bypassing production approval
- Using personal AWS keys
- Removing monitoring
- Removing owner metadata
```

---

## Step 3: Add Pipeline Template

Add to `ci/pipeline-template.yml`:

```yaml
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
  APP_NAME: "inventory-api"
  ECR_REPOSITORY: "inventory-api"

validate:
  stage: validate
  script:
    - echo "Checking required golden path files"
    - test -f README.md
    - test -f helm/values-dev.yaml
    - test -f helm/values-prod.yaml
    - test -f terraform/sample-inputs.tfvars

test:
  stage: test
  script:
    - echo "Running tests"

build:
  stage: build
  script:
    - echo "Building Docker image"

scan:
  stage: scan
  script:
    - echo "Scanning container image"

push:
  stage: push
  script:
    - echo "Pushing image to Amazon ECR"

deploy_dev:
  stage: deploy_dev
  script:
    - echo "Deploying to dev with Helm"

approve_prod:
  stage: approve_prod
  when: manual
  script:
    - echo "Approval required for production"

deploy_prod:
  stage: deploy_prod
  script:
    - echo "Deploying to production with Helm"
```

---

## Step 4: Add Dev Helm Values

Add to `helm/values-dev.yaml`:

```yaml
appName: inventory-api
namespace: inventory-dev

image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/inventory-api
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
  team: inventory
  email: inventory@example.com
  supportChannel: "#inventory-support"
```

---

## Step 5: Add Prod Helm Values

Add to `helm/values-prod.yaml`:

```yaml
appName: inventory-api
namespace: inventory-prod

image:
  repository: 123456789012.dkr.ecr.us-east-1.amazonaws.com/inventory-api
  tag: "1.0.0"

replicaCount: 3

service:
  port: 8080

resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
  limits:
    cpu: "1000m"
    memory: "1Gi"

owner:
  team: inventory
  email: inventory@example.com
  supportChannel: "#inventory-support"
```

---

## Step 6: Add Terraform Sample Inputs

Add to `terraform/sample-inputs.tfvars`:

```hcl
application_name = "inventory-api"
environment      = "dev"
aws_region       = "us-east-1"

ecr_repository_name = "inventory-api"
eks_namespace       = "inventory-dev"
pipeline_role_name  = "inventory-api-dev-pipeline-role"

owner_team      = "inventory"
owner_email     = "inventory@example.com"
support_channel = "#inventory-support"
cost_center     = "supply-chain"
data_class      = "internal"
```

---

## Step 7: Add Deployment Failure Runbook

Add to `runbooks/deployment-failure.md`:

```markdown
# Deployment Failure Runbook

## Symptoms
- Pipeline deploy stage failed
- Helm deploy failed
- Pods are not running
- Service is unavailable

## Investigation Steps
1. Check failed pipeline stage.
2. Confirm required files exist.
3. Confirm Helm values are complete.
4. Confirm ECR repository and image tag.
5. Confirm namespace value.
6. Confirm owner metadata.
7. Check logs and events.

## Common Fixes
- Correct missing Helm values.
- Fix namespace mismatch.
- Use correct image tag.
- Restore required owner metadata.
- Escalate IAM issue to platform team.
```

---

## Step 8: Add Rollback Runbook

Add to `runbooks/rollback.md`:

```markdown
# Rollback Runbook

## When to Use
Use this runbook when a release causes errors, failed health checks, latency, or customer impact.

## Steps
1. Identify failed release.
2. Find last known good version.
3. Roll back using Helm.
4. Validate pods are healthy.
5. Confirm endpoint works.
6. Notify owner team.
7. Document what happened.

## Example Commands
helm history <release-name> -n <namespace>
helm rollback <release-name> <revision> -n <namespace>
kubectl get pods -n <namespace>
kubectl logs deployment/<deployment-name> -n <namespace>
```

---

---

## Step 9: Make Your Chart Real and Render It

So far you have `values-dev.yaml` but no chart. Build the minimal real chart from the demo (Section 13, Step 9) so it actually renders:

```bash
mkdir -p helm/app-chart/templates
# Create Chart.yaml, values.yaml, templates/deployment.yaml, templates/service.yaml,
# and values.schema.json exactly as shown in the instructor demo Step 9.
```

Then run the validation that proves it works (this is the deliverable — a chart that renders, not a values file):

```bash
helm lint helm/app-chart
helm template myapp helm/app-chart \
  --set appName=inventory-api \
  --set owner.team=inventory --set owner.email=inventory@example.com
```

Confirm the output contains a `Deployment` and a `Service`. Then prove the schema enforces inputs — this should FAIL:

```bash
helm template myapp helm/app-chart --set owner.email=""   # expect a schema validation error
```

> Local only: `helm lint`/`helm template` create nothing in any cloud and cost nothing. Do not `helm install` unless you have a throwaway kind/minikube cluster.

## Step 10: Consume the Reusable Workflow (don't hand-author it)

Create the *caller* only — the platform owns the reusable workflow. This is the self-service surface:

```bash
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'CALLER_EOF'
name: ci
on:
  push:
    branches: [main]
jobs:
  golden-path:
    uses: acme/golden-path/.github/workflows/reusable-deliver.yml@v1
    with:
      app_name: inventory-api
      ecr_repository: inventory-api
    secrets:
      aws_role_arn: ${{ secrets.GOLDEN_PATH_OIDC_ROLE_ARN }}
CALLER_EOF
```

Note how short it is: the app team gets Trivy/Checkov scanning, OIDC keyless auth, helm lint, and ECR push *without writing any of it*, and cannot disable the scans.

---

## Commands Students Should Run

```bash
helm lint helm/app-chart
find . -maxdepth 4 -type f | sort
```

Expected output:

```text
./.github/workflows/ci.yml
./README.md
./ci/pipeline-template.yml
./helm/app-chart/Chart.yaml
./helm/app-chart/templates/deployment.yaml
./helm/app-chart/templates/service.yaml
./helm/app-chart/values.schema.json
./helm/app-chart/values.yaml
./helm/values-dev.yaml
./helm/values-prod.yaml
./runbooks/deployment-failure.md
./runbooks/rollback.md
./terraform/sample-inputs.tfvars
```

Optional validation:

```bash
grep -R "owner" .
grep -R "approve_prod" ci/pipeline-template.yml
grep -R "ecr_repository" README.md terraform/sample-inputs.tfvars
```

---

## Validation Checklist

| Check | Expected Result |
|---|---|
| README exists | Explains purpose, inputs, supported and unsupported customization |
| Pipeline template exists | Contains validate, build, scan, push, deploy, approval stages |
| Dev Helm values exist | Uses dev namespace and dev image tag |
| Prod Helm values exist | Uses prod namespace and versioned image tag |
| Terraform inputs exist | Includes app, environment, region, ECR, namespace, IAM role, owner |
| Deployment failure runbook exists | Has symptoms, investigation, and fixes |
| Rollback runbook exists | Has rollback steps and validation commands |
| Ownership metadata exists | Team, email, and support channel are included |
| Helm chart renders | `helm lint` passes and `helm template` outputs a Deployment + Service |
| Schema enforces inputs | `helm template` fails when `owner.email` is empty |
| CI caller consumes reusable workflow | `ci.yml` uses `acme/golden-path/...@v1` with OIDC role secret, no static keys |

---

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `find` output missing files | Folder not created correctly | Recreate missing files |
| YAML indentation issue | Tabs or inconsistent spacing | Use spaces only |
| Pipeline missing approval | Stage was skipped | Add `approve_prod` stage |
| Owner metadata missing | Student focused only on deployment | Add owner team, email, support channel |
| Dev and prod values identical | Environments not separated | Adjust namespace, image tag, replicas, resources |
| Terraform file lacks tags | Enterprise context missed | Add owner, cost center, data class |

## Cleanup Steps

```bash
cd ..
rm -rf student-golden-path
```

Students should keep the folder if they want to use it for homework or capstone reference.

## Reflection Questions

1. Which file is most important for developer usability?
2. Which file is most important for deployment consistency?
3. Which file is most important during an incident?
4. What validation should be automated?
5. What should be locked down before production deployment?

## Optional Challenge Task

Add a file:

```text
docs/service-catalog-entry.yaml
```

Example:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: inventory-api
  description: Inventory service deployed through the golden path
  annotations:
    owner: inventory
spec:
  type: service
  lifecycle: production
  owner: inventory
```

---

# 15. Troubleshooting Activity

## Incident Title

**Golden Path Deployment Fails Because Required Helm Values Were Removed**

## Business Impact

An application team used the golden path template to deploy a new API service. The build and image push succeeded, but the deployment failed.

Impact:

- Dev deployment delayed
- Platform team receives support tickets
- Application team loses confidence in the template
- Release timeline is at risk
- Template may be reused incorrectly by other teams

## Symptoms

```text
Pipeline stage: deploy_dev failed
Build stage: passed
Scan stage: passed
Push stage: passed
Deploy stage: failed
```

## Starting Evidence

### Pipeline Error

```text
Error: Helm values validation failed
Missing required value: image.repository
Missing required value: owner.email
Invalid namespace: inv-devv
Deployment aborted before applying manifests
```

### Broken Helm Values

```yaml
appName: inventory-api
namespace: inv-devv

image:
  repository: ""
  tag: "latest"

replicaCount: 1

owner:
  team: inventory
```

### README Issue

```markdown
# Golden Path

Update values file and deploy.
Ask platform team if needed.
```

## Student Investigation Steps

Students should answer:

1. Which required fields are missing?
2. Which field has a typo?
3. Why did build and push succeed but deploy fail?
4. What should the README have explained?
5. What validation should happen before deploy?
6. What template improvements would prevent this issue?

## Expected Root Cause

The application team removed or failed to populate required Helm values because the template did not clearly document required fields and did not validate values early enough.

## Correct Resolution

Students should recommend:

1. Fix `image.repository`.
2. Fix namespace from `inv-devv` to `inventory-dev`.
3. Add `owner.email`.
4. Add required inputs table to README.
5. Add example `values-dev.yaml`.
6. Add Helm lint or schema validation.
7. Add a pipeline validation stage before deploy.
8. Add stronger troubleshooting documentation.

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Re-running the pipeline without changes | Same failure will happen again |
| Blaming only the developer | Template did not guide the user well |
| Removing required owner metadata | Makes service unsupportable |
| Disabling validation | Allows broken config into deployment |
| Giving admin access | Does not solve missing values and creates security risk |
| Manually deploying outside pipeline | Bypasses audit and repeatability |

## Instructor Hints

- Which values would Helm need before deployment?
- Which values would support teams need during an incident?
- Where should required fields be documented?
- How can a pipeline catch this before deploy?
- Is this a one-service issue or a platform template issue?

## Preventive Action

The platform team should add:

- Required input table
- Example values files
- Helm values validation
- Namespace naming convention
- Owner metadata requirement
- Pipeline validate stage
- Clear support and escalation section
- Release notes for template versions

---

# 16. Scenario-Based Discussion Questions

## Question 1

**Should every golden path include a production approval gate?**

Expected themes:

- Yes for production environments
- Maybe not for dev or sandbox
- Approval supports change control and risk reduction
- Too many approvals can slow delivery

Follow-up:

> What kind of changes should require approval?

---

## Question 2

**What is more important: a perfect template or a usable template?**

Expected themes:

- Usability matters because developers must adopt it
- Perfect but confusing templates increase support tickets
- Start simple and improve iteratively

Follow-up:

> How would you collect feedback from app teams?

---

## Question 3

**Which parts of this golden path should the platform team own?**

Expected themes:

- Pipeline template
- Terraform modules
- Helm base chart
- Security guardrails
- Documentation standards

Follow-up:

> Which parts should the application team own?

---

## Question 4

**How can golden paths improve production reliability?**

Expected themes:

- Standard probes
- Standard rollback
- Standard dashboards
- Required owner metadata
- Approved deployment flow

Follow-up:

> What SRE practice should be built into every template?

---

## Question 5

**What cost controls should be included in a golden path?**

Expected themes:

- Required tags
- Default resource limits
- Environment cleanup guidance
- Logging retention
- Avoid unnecessary load balancers or NAT gateways

Follow-up:

> What cost issue might happen if every dev service creates its own load balancer?

---

## Question 6

**Should teams be allowed to bypass golden paths?**

Expected themes:

- Exceptions may be needed
- Exceptions should be reviewed
- Unsupported paths increase operational risk
- Platform team should document support boundaries

Follow-up:

> What would make an exception valid?

---

## Question 7

**How does this Class 2 template build from the Class 1 design?**

Expected themes:

- Class 1 defined the workflow
- Class 2 created the template files
- Design becomes reusable implementation
- Troubleshooting now focuses on template validation

Follow-up:

> What part of your Class 1 design became a file in Class 2?

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

Which file is usually the front door for developers using a golden path template?

A. values-dev.yaml  
B. README.md  
C. rollback.md  
D. sample-inputs.tfvars  

**Answer:** B  
**Explanation:** The README should explain purpose, inputs, usage, support, and customization.

---

## Question 2: Multiple Choice

Which stage should catch missing required files before deployment?

A. deploy_prod  
B. approve_prod  
C. validate  
D. push  

**Answer:** C  
**Explanation:** The validate stage should catch missing files and required inputs early.

---

## Question 3: True or False

Dev and prod Helm values should always be exactly the same.

**Answer:** False  
**Explanation:** Dev and prod often differ in namespace, image tag, replica count, resources, and approval expectations.

---

## Question 4: Short Answer

Name two AWS services commonly included in a containerized application golden path.

**Answer:** Amazon ECR and Amazon EKS. CloudWatch and IAM are also valid.  
**Explanation:** ECR stores images, EKS runs workloads, IAM controls access, and CloudWatch supports observability.

---

## Question 5: Multiple Choice

What is the purpose of `terraform/sample-inputs.tfvars` in this class?

A. To deploy Kubernetes pods directly  
B. To show sample inputs for reusable infrastructure modules  
C. To replace the README  
D. To store application logs  

**Answer:** B  
**Explanation:** Terraform input files show values that modules can use to create standard cloud resources.

---

## Question 6: Troubleshooting

The pipeline build and push stages pass, but deploy fails because `image.repository` is empty. What should be improved?

**Answer:** Add required input validation before deployment and document `image.repository` in the README with examples.  
**Explanation:** This should be caught before Helm deploy starts.

---

## Question 7: Troubleshooting

A Helm values file has namespace `inv-devv`, but the approved namespace is `inventory-dev`. What kind of issue is this?

**Answer:** Configuration or naming mismatch.  
**Explanation:** Golden paths should include naming standards and validation.

---

## Question 8: True or False

A rollback runbook is optional because CI/CD pipelines should never fail.

**Answer:** False  
**Explanation:** Failures happen in real systems. Rollback runbooks are required for operational readiness.

---

## Question 9: Short Answer

How does Class 2 build on Class 1?

**Answer:** Class 1 designed the golden path concept and onboarding workflow. Class 2 turns that design into reusable template files, pipeline stages, Helm values, Terraform inputs, and runbooks.  
**Explanation:** Class 2 is the implementation continuation of Class 1.

---

## Question 10: Multiple Choice

Which is an unsafe golden path practice?

A. Required owner metadata  
B. Manual approval before prod  
C. Using personal AWS access keys in pipeline  
D. CloudWatch logging  

**Answer:** C  
**Explanation:** Pipelines should use approved IAM roles or identity federation, not personal long-lived credentials.

---

## Question 11: Short Answer

Why should owner metadata be included in Helm values or template inputs?

**Answer:** It identifies who supports the service, who receives alerts, who owns cost, and who responds during incidents.  
**Explanation:** Ownership metadata is critical for production support.

---

## Question 12: Multiple Choice

Which file is most directly related to operational recovery after a failed release?

A. rollback.md  
B. values-dev.yaml  
C. sample-inputs.tfvars  
D. pipeline-template.yml  

**Answer:** A  
**Explanation:** The rollback runbook explains how to recover from a bad release.

---

# 18. Homework Assignment

## Assignment Title

**Improve the Golden Path Template for Developer Self-Service**

## Scenario

Your platform team tested the first version of the golden path template with an application team. The team was able to understand the basic structure, but they still had questions about required inputs, supported customization, production approval, troubleshooting, and rollback.

Your job is to improve the template so it is easier and safer for application teams to use.

## Student Tasks

Students must improve their Class 2 lab output by adding:

1. A quick-start guide in `README.md`
2. A required inputs table
3. Supported vs unsupported customization section
4. A troubleshooting FAQ
5. A deployment flow diagram
6. A rollback runbook
7. A production approval explanation
8. A short AWS service mapping section
9. A cost and tagging section
10. A security notes section

## Expected Deliverables

Students submit:

```text
student-golden-path/
├── README.md
├── .github/workflows/ci.yml          # caller of the reusable golden-path workflow
├── ci/pipeline-template.yml          # storyboard of stages
├── helm/app-chart/Chart.yaml         # real, rendering chart
├── helm/app-chart/values.yaml
├── helm/app-chart/values.schema.json
├── helm/app-chart/templates/deployment.yaml
├── helm/app-chart/templates/service.yaml
├── helm/values-dev.yaml
├── helm/values-prod.yaml
├── terraform/sample-inputs.tfvars
├── runbooks/deployment-failure.md
└── runbooks/rollback.md
```

Plus one short reflection:

```text
What did you improve, and how does it reduce support tickets?
```

## Submission Format

- Zip file
- Git repo link
- Markdown files copied into submission portal
- Instructor-approved format

## Estimated Completion Time

2 hours

## Grading Criteria

| Criteria | Points |
|---|---:|
| README is clear and usable | 20 |
| Pipeline stages are logical | 15 |
| Helm dev and prod values are complete | 15 |
| Terraform inputs are practical | 15 |
| Runbooks are actionable | 15 |
| AWS services are correctly mapped | 10 |
| Security, cost, and ownership included | 10 |
| Total | 100 |

## Optional Advanced Challenge

Add one of the following (build it, do not stub it):

1. A real `values.schema.json` and prove it rejects a bad value with `helm template`.
2. A GitLab `include:` equivalent of the reusable GitHub workflow.
3. A Backstage `template.yaml` (scaffolder) whose parameters generate this repo, plus a `catalog-info.yaml`.
4. An Argo CD `Application` (GitOps) pointing at your chart, with `selfHeal` and `prune`.
5. A Crossplane `Claim` example (e.g. `kind: PostgresInstance`) and one paragraph on when you'd use it instead of the Terraform module.
6. A DORA/DX scorecard: define targets and data sources for deployment frequency, lead time, change-failure rate, time to restore, and golden-path adoption rate.

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Creating files without explaining them | Students focus on structure only | Require README explanations for every major component |
| Pipeline has deploy but no validation | Students think deployment is the goal | Add validate stage before build or deploy |
| Dev and prod values are identical | Students do not understand environment separation | Change namespace, image tag, replicas, resources |
| Missing owner metadata | Students focus on technical deployment only | Require owner team, email, and support channel |
| No rollback runbook | Students assume successful deployments | Require rollback steps and validation commands |
| Terraform inputs are vague | Students do not connect IaC to platform templates | Include app, env, region, ECR, namespace, IAM, tags |
| Using personal AWS credentials | Students do not understand pipeline identity | Explain IAM roles and least privilege |
| Treating template as fully production-ready | Students overestimate conceptual examples | Clarify this is a training template and needs real implementation |
| Ignoring cost | Students forget cloud operations impact | Include tags, resource limits, cleanup guidance |
| Overengineering | Advanced students add too much too early | Start with a simple supported workflow |

---

# 20. Real-World Enterprise Scenario

## Scenario

A retail company has 60 application teams. Every team deploys containerized services differently.

Current problems:

- Some teams manually create ECR repositories.
- Some teams use personal AWS credentials in pipelines.
- Some teams deploy to EKS with copied Helm files.
- Some services do not have CloudWatch dashboards.
- Production rollbacks are inconsistent.
- Platform team receives repetitive onboarding tickets.
- Security requires standardized scanning and approval.
- Finance requires owner and cost center tags.

## How the Class Topic Applies

The platform team creates a golden path template with:

- Standard README
- CI/CD template
- IAM role pattern
- ECR repository input
- EKS namespace input
- Helm dev and prod values
- CloudWatch expectations
- Rollback runbook
- Required owner and cost metadata
- Production approval stage

## Constraints

| Constraint | Example |
|---|---|
| Access control | App teams cannot use admin credentials |
| Security | Image scanning and approval are required |
| Cost | Every service needs cost center tags |
| Reliability | Every service needs rollback and monitoring |
| Production impact | Prod deploys require approval |
| Team workflow | All changes go through pull requests |

## Role Responsibilities

| Role | What They Do |
|---|---|
| DevOps Engineer | Builds reusable pipeline template and release flow |
| Cloud Engineer | Creates IAM, ECR, EKS, VPC, and Terraform module patterns |
| SRE | Defines runbooks, dashboards, rollback, and operational readiness |

---

# 21. Instructor Tips

## Teaching Tips

- Keep reminding students that the template is for other people to use.
- Ask “Would a new developer understand this without you explaining it?”
- Connect every file to a real enterprise need.
- Use mistakes as teaching moments, especially YAML and missing inputs.
- Keep AWS examples concrete, but avoid live cloud complexity in this class.

## Pacing Tips

- Do not let the demo consume the whole class.
- Keep the pipeline template conceptual.
- Spend more time on README, inputs, validation, and runbooks.
- Lab should be short enough for students to complete in class.

## Lab Support Tips

Watch for:

- Missing files
- Wrong folder names
- Incomplete README
- Missing owner metadata
- No prod approval stage
- No rollback steps
- Helm YAML indentation issues

## Helping Struggling Students

Give them this simple mapping:

```text
README = how to use it
Pipeline = how to deliver it
Helm = how it runs
Terraform = what cloud resources it needs
Runbook = how to fix it
```

## Challenging Advanced Students

Ask advanced students to add:

- Helm schema validation
- CI/CD reusable include syntax
- OIDC-based AWS role assumption concept
- Trivy scan stage
- Checkov scan stage
- Backstage catalog metadata
- CloudWatch dashboard JSON placeholder
- Terraform module README

---

# 22. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] How Class 2 builds from Class 1
- [ ] What belongs in a golden path template
- [ ] Why pipeline validation matters
- [ ] Why Helm values should be environment-specific
- [ ] Why Terraform inputs help standardize cloud resources
- [ ] Why runbooks are part of production readiness
- [ ] How ECR, EKS, IAM, VPC, and CloudWatch fit into the workflow

## Students Should Be Able to Build or Configure

- [ ] A basic golden path folder structure
- [ ] A README with required inputs
- [ ] A pipeline template outline
- [ ] Dev and prod Helm values files
- [ ] Terraform sample input file
- [ ] Deployment failure runbook
- [ ] Rollback runbook

## Students Should Be Able to Troubleshoot

- [ ] Missing Helm values
- [ ] Wrong namespace
- [ ] Missing owner metadata
- [ ] Missing pipeline validation
- [ ] Confusing README instructions
- [ ] Missing rollback guidance
- [ ] Unsafe customization

---

# 23. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Reviewed Class 1 concepts
- [ ] Explained anatomy of golden path template
- [ ] Explained reusable CI/CD stages
- [ ] Explained Terraform inputs and Helm values
- [ ] Completed instructor demo
- [ ] Students completed or started lab
- [ ] Reviewed troubleshooting activity
- [ ] Assigned homework
- [ ] Connected this class to DevOps capstone readiness

## Student Checklist Before Leaving Class

- [ ] I created a golden path folder structure
- [ ] I created a README
- [ ] I created a pipeline template
- [ ] I created dev and prod Helm values
- [ ] I created Terraform sample inputs
- [ ] I created at least one runbook
- [ ] I understand the troubleshooting scenario
- [ ] I understand the homework assignment

## Items to Verify Before Closing the Week

Students should have:

- [ ] A working local template folder
- [ ] Clear understanding of golden path implementation
- [ ] Awareness of documentation and validation requirements
- [ ] Ability to explain AWS service mapping
- [ ] Ability to identify platform template weaknesses
- [ ] Homework plan for improving the template

---

# 24. End-of-Week Summary

## What Students Learned This Week

Students learned how platform engineering helps application teams deliver software faster and safer through reusable patterns.

They covered:

- Platform engineering purpose
- Golden paths and paved roads
- Developer self-service
- Golden path design
- Reusable template structure
- CI/CD template stages
- Terraform input patterns
- Helm values standardization
- AWS service mapping
- Documentation and runbooks
- Troubleshooting template misuse

## How Class 1 and Class 2 Connect

| Class 1 | Class 2 |
|---|---|
| Explained platform engineering | Built a simple platform template |
| Designed golden path workflow | Created golden path files |
| Discussed developer self-service | Created README and required inputs |
| Identified documentation gaps | Added runbooks and validation ideas |
| Mapped AWS flow conceptually | Created ECR, EKS, IAM, and CloudWatch references |

## How This Week Prepares Students for the Next Week

This week prepares students for capstone work by teaching them to think beyond one-off scripts and deployments.

In the capstone, students should be able to show:

- A repeatable delivery workflow
- Clear documentation
- Safe deployment stages
- Environment separation
- AWS service mapping
- Operational readiness
- Troubleshooting and rollback process

## What Students Should Review Before the Next Module

Students should review:

1. CI/CD pipeline stages
2. Docker image build and registry flow
3. Amazon ECR and EKS concepts
4. Helm values files
5. Terraform input variables
6. IAM role-based access concepts
7. CloudWatch logs and metrics
8. Runbook and rollback basics
9. Their Week 20 homework template
10. How their golden path could become part of the Week 23–24 capstone

---

## Class Artifacts & Validation

This is the **build** class: students assemble a reusable golden-path template
(scaffold/generator, hardened Dockerfile, CI pipeline, and dev/prod Helm values)
and prove it works end to end. The artifacts below are the ones this class
produces and operates. Every path is real; every command was run in this
environment. Live results cite the committed evidence file.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/platform-golden-path/solution/scaffold.sh` | shell | The self-service generator that turns the template into a complete service | `shellcheck labs/platform-golden-path/solution/scaffold.sh` | PASS |
| 2 | `labs/platform-golden-path/solution/template/app/main.py` | python | Stdlib HTTP app with `/healthz` `/readyz` `/metrics` (graceful SIGTERM) | `python3 -m py_compile .../app/main.py` + `python3 -m unittest` (7 tests) | PASS |
| 3 | `labs/platform-golden-path/solution/template/Dockerfile` | docker | Multi-stage **non-root** image (uid 10001, read-only rootfs, caps dropped) | `hadolint .../solution/example-service/Dockerfile` | PASS |
| 4 | `labs/platform-golden-path/solution/template/chart/values.yaml` | helm | Paved-road chart values: probes, requests+limits, securityContext, optional HPA/NetworkPolicy | `helm lint .../solution/example-service/chart` | PASS (1 linted, 0 failed) |
| 5 | `labs/platform-golden-path/solution/template/.github/workflows/ci.yml` | gha | Reusable CI: lint → unittest → helm/kubeconform → docker build → trivy scan | `actionlint .../solution/example-service/.github/workflows/ci.yml` | PASS |
| 6 | `labs/platform-golden-path/solution/example-service/k8s/` | k8s | Plain manifests rendered by the template | `kubeconform -strict .../example-service/k8s/*.yaml` | PASS (Valid: 2) |
| 7 | `labs/helm-charts/solution/chart/webapp/values.yaml` | helm | **Dev** Helm values (the dev half of the dev/prod split this class teaches) | `helm template ... \| kubeconform -strict` | PASS (Valid: 5) |
| 8 | `labs/helm-charts/solution/chart/webapp/values-prod.yaml` | helm | **Prod** override: Ingress+TLS on, HPA on, pinned tag, anti-affinity | `helm template ... -f values-prod.yaml \| kubeconform -strict` | PASS (Valid: 7) |
| 9 | `labs/platform-golden-path/validate.sh` | shell | Fast gate runner (shellcheck, scaffold behaviour, diff, helm/kubeconform, real docker build of generated svc) | `cd labs/platform-golden-path && ./validate.sh` | PASS (32 passed, 0 failed) |
| 10 | `labs/platform-golden-path/drill.sh` + `docs/evidence/drill-output.txt` | shell + evidence | Live end-to-end drive: scaffold → docker build → **kind deploy** → `helm test` | `RUN_LIVE=1 ./drill.sh` | **PASS (live)** — see `labs/platform-golden-path/docs/evidence/drill-output.txt` |

Live evidence (committed `docs/evidence/drill-output.txt`, run id `drill-20260630-103115`):
generated image built, `/healthz → 200`; both pods `1/1 Running` in `kind-course`;
effective container securityContext
`{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":10001}`;
`helm test` → `Phase: Succeeded`. The `helm-charts` module additionally passes a
real server-side dry-run against the live cluster (`kubectl --context kind-course
apply --dry-run=server`) for both value sets.

To reproduce:

```bash
cd labs/platform-golden-path && ./validate.sh                 # 32 passed, 0 failed
cd labs/helm-charts          && ./validate.sh                 # 17 passed, 0 failed (incl. live server dry-run)
cd labs/platform-golden-path && RUN_LIVE=1 ./drill.sh         # rebuilds the committed evidence above
```

## Definition of Done

Ticked honestly for **this** class (the hands-on build/operate class):

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence) — shell generator, Python app, Dockerfile, GitHub Actions CI, Helm chart, and k8s manifests all exist on disk.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — re-run for this manifest (shellcheck/py_compile+unittest/hadolint/actionlint/helm lint/kubeconform) plus the green `validate.sh` runs.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `platform-golden-path` ships `starter/` (4 scaffold TODOs + deliberately broken Dockerfile/deployment) and `solution/`; `helm-charts` ships `starter/` (4 deployment TODOs) and `solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — present in both module READMEs.
- [x] **Cleanup/teardown** is provided and idempotent — `validate.sh`/`drill.sh` remove temp dirs, the built image, the container, and the kind namespace on exit; `helm uninstall` documented.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — `solution/` is the reference and both module READMEs carry detailed answer keys (grading points + common wrong answers); this class file carries the homework/quiz keys.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `platform-golden-path` starter Dockerfile/deployment generate a pod rejected by `runAsNonRoot`; `helm-charts/broken/deployment.yaml` injects the classic `nindent`/indentation bugs.
- [x] **Expected outputs** are shown — captured `validate.sh` output and the live `docs/evidence/drill-output.txt`.
- [x] **Cost & security warnings** present — both READMEs document `$0` (all local: kind + local docker) and least-privilege defaults (non-root, read-only rootfs, caps dropped, no SA token).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — header links the modules; week mapping (CI/CD W9, Docker W10, K8s/Helm W11–13, Terraform W14–15, capstone W23–24) verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`/`test`/gate re-runs above.
