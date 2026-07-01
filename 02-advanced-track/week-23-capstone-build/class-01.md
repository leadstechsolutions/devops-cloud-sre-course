# Week 23 — Capstone Build
> **▶ Runnable lab for this class:** [`labs/capstone/`](../../labs/capstone/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package: Capstone Build — CI/CD, Containers, and Infrastructure as Code

**Week:** 23
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

## 1. Class Overview

### Class Title

**Building the DevOps Capstone Foundation and CI/CD Workflow**

### Class Purpose

This class starts the final DevOps capstone build. Students begin connecting the major skills learned throughout the course: Git, Docker, CI/CD, AWS IAM, Amazon ECR, security scanning, and documentation.

The goal is not to finish the entire capstone in this class. The goal is to create a strong foundation:

- A clean Git repository structure
- A working Dockerfile
- A Docker image that builds successfully
- An image pushed to Amazon ECR
- A basic CI/CD pipeline with validation, test, build, scan, and push stages
- Initial capstone documentation

### How This Class Connects to the Overall Course

This class pulls together skills from earlier weeks:

| Earlier Course Area | Source Week | How It Is Used in This Class |
|---|---|---|
| Git workflows | Week 3 | Organize capstone repo, branch, commit, push |
| Docker / multi-stage builds | Week 10 | Build a multi-stage, non-root, distroless application image |
| CI/CD fundamentals | Week 9 | Automate validation, testing, scanning, signing, and image push |
| AWS Cloud foundations + CLI | Week 4 | Authenticate, set region, verify identity |
| Cloud Security & IAM | Week 6 | Least-privilege IAM, OIDC keyless CI |
| Terraform foundations + enterprise workflows | Weeks 14–15 | Provision ECR/VPC/EKS as IaC with render-before-apply discipline |
| DevSecOps & secure delivery | Week 19 | Gating scans, SBOM, image signing, provenance |
| Amazon ECR | Weeks 7, 10 | Store the application container image |
| Documentation | Throughout | Start architecture notes and Architecture Decision Records (ADRs) |

### What Students Will Build, Analyze, or Practice

Students will build the first working part of their DevOps capstone delivery workflow:

```text
Code commit
  ↓
CI/CD pipeline starts
  ↓
Pipeline validates project files
  ↓
Pipeline builds Docker image
  ↓
Pipeline scans image
  ↓
Pipeline pushes image to Amazon ECR
```

By the end of this class, students should have a capstone project that is ready to continue into Class 2, where they will deploy the image to EKS using Helm.

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** the end-to-end DevOps capstone delivery workflow.
2. **Organize** a Git repository for application, infrastructure, Helm, documentation, and pipeline files.
3. **Build** a Docker image for the capstone application.
4. **Configure** Amazon ECR as the container image registry.
5. **Validate** AWS identity and ECR access from the CLI.
6. **Provision** the ECR registry (with lifecycle and KMS encryption) as code using Terraform/OpenTofu.
7. **Push** a Docker image to Amazon ECR using correct tagging and OIDC keyless authentication.
8. **Build** a CI/CD pipeline with a gating vulnerability scan, SBOM generation, image signing (cosign), and provenance.
9. **Author** Architecture Decision Records that justify key capstone trade-offs.
10. **Troubleshoot** common failures related to Docker builds, ECR authentication, image tagging, and pipeline permissions.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic Git commands: `clone`, `branch`, `add`, `commit`, `push`
- Basic Docker concepts: image, container, Dockerfile, tag, registry
- Basic AWS concepts: account, region, IAM, CLI profile
- Basic CI/CD concepts: pipeline, stage, job, artifact, environment variable
- Basic YAML syntax
- Basic Linux terminal usage

### Required Tools Already Installed

Students should have:

| Tool | Required For |
|---|---|
| VS Code | Editing project files |
| Git | Source control |
| Docker | Building and testing container images |
| AWS CLI | Authenticating and working with AWS |
| GitLab CLI or GitHub CLI | Optional, not required |
| Terminal | Running commands |
| Trivy | Optional local image scanning |
| Terraform | Not heavily used in Class 1, but repo folder prepared |
| kubectl | Not used deeply until Class 2 |
| Helm | Not used deeply until Class 2 |

### Required Accounts or Access

Students need access to:

- GitLab or GitHub repository
- AWS account or sandbox account
- Permission to create or use an existing ECR repository
- Permission to run `aws sts get-caller-identity`
- Permission to authenticate Docker to ECR
- Permission to push images to ECR

### Required Files, Repos, or Sample Code

Students should have a simple sample application. Example structure:

```text
app/
├── Dockerfile
├── package.json
└── src/
    └── server.js
```

The sample app is deliberately **non-trivial** so the test and scan stages are meaningful: it has real dependencies, real unit tests, env-driven config, and a `/ready` endpoint that depends on a (mockable) datastore. A trivial "echo passed" app makes the pipeline theater — a senior portfolio needs tests and scans that actually exercise something.

#### `app/package.json`

```json
{
  "name": "devops-capstone-app",
  "version": "1.0.0",
  "description": "DevOps capstone application",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "test": "node --test"
  },
  "dependencies": {
    "express": "^4.19.2",
    "pino": "^9.0.0"
  }
}
```

> Note: `node --test` is the built-in Node.js test runner (Node 18+), so the test stage has no extra test-framework dependency to install. Pin exact versions via `package-lock.json` and use `npm ci` (not `npm install`) in CI for reproducible builds.

#### `app/src/server.js`

```javascript
const express = require("express");
const pino = require("pino");

const logger = pino();
const app = express();
const port = process.env.PORT || 8080;
const appVersion = process.env.APP_VERSION || "dev";

// Simple in-memory store stands in for a real datastore (DB/cache).
// Swap STORE_READY=false to simulate a dependency outage for /ready.
const storeReady = process.env.STORE_READY !== "false";

app.get("/", (req, res) => {
  res.json({ message: "DevOps Capstone App is running", version: appVersion });
});

// Liveness: the process itself is up.
app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy", version: appVersion });
});

// Readiness: only ready when downstream dependencies are reachable.
app.get("/ready", (req, res) => {
  if (storeReady) {
    return res.status(200).json({ status: "ready" });
  }
  return res.status(503).json({ status: "not-ready", reason: "store unavailable" });
});

// Trivial business endpoint with input handling (gives tests something real).
app.get("/sum", (req, res) => {
  const a = Number(req.query.a);
  const b = Number(req.query.b);
  if (Number.isNaN(a) || Number.isNaN(b)) {
    return res.status(400).json({ error: "a and b must be numbers" });
  }
  res.json({ result: a + b });
});

if (require.main === module) {
  app.listen(port, () => {
    logger.info({ port, version: appVersion }, "App listening");
  });
}

module.exports = app;
```

#### `app/test/server.test.js`

```javascript
const test = require("node:test");
const assert = require("node:assert");
const http = require("node:http");
const app = require("../src/server");

function request(server, path) {
  return new Promise((resolve) => {
    const { port } = server.address();
    http.get(`http://127.0.0.1:${port}${path}`, (res) => {
      let body = "";
      res.on("data", (c) => (body += c));
      res.on("end", () => resolve({ status: res.statusCode, body: JSON.parse(body) }));
    });
  });
}

test("GET /health returns healthy", async () => {
  const server = app.listen(0);
  const res = await request(server, "/health");
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.body.status, "healthy");
  server.close();
});

test("GET /sum adds two numbers", async () => {
  const server = app.listen(0);
  const res = await request(server, "/sum?a=2&b=3");
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.body.result, 5);
  server.close();
});

test("GET /sum rejects non-numeric input", async () => {
  const server = app.listen(0);
  const res = await request(server, "/sum?a=x&b=3");
  assert.strictEqual(res.status, 400);
  server.close();
});
```

#### `app/Dockerfile` (multi-stage, non-root, distroless)

```dockerfile
# ---- Stage 1: build / install production dependencies ----
FROM node:20-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
# npm ci = reproducible install from the lockfile. --omit=dev replaces the
# deprecated --only=production (npm 7+).
RUN npm ci --omit=dev
COPY src/ ./src/

# ---- Stage 2: minimal runtime ----
# Distroless has no shell/package manager: smaller image, smaller attack surface.
# The :nonroot tag runs as UID 65532 (no root) by default.
FROM gcr.io/distroless/nodejs20-debian12:nonroot
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY package.json ./
USER nonroot
EXPOSE 8080
# distroless nodejs image's entrypoint is "node", so pass the script only.
CMD ["src/server.js"]
```

> Pinning to a digest (`FROM node:20-bookworm-slim@sha256:...`) is even stronger — it makes the base image immutable. Show students how to resolve a digest with `docker buildx imagetools inspect`.

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Capstone | Final project that combines multiple course skills | Used as a portfolio project for interviews |
| CI/CD | Automation that validates, builds, tests, and deploys code | Used by teams to reduce manual deployment work |
| Pipeline | A sequence of automated jobs | Example: test, build, scan, push, deploy |
| Stage | A major phase inside a pipeline | Build stage, test stage, deploy stage |
| Job | A specific task inside a stage | Example: `docker build` |
| Dockerfile | File that describes how to build a container image | Standard way to package apps for Kubernetes |
| Container image | Packaged application plus runtime dependencies | Stored in a registry and deployed to servers or Kubernetes |
| Registry | Storage location for container images | Amazon ECR, Docker Hub, Azure Container Registry |
| Amazon ECR | AWS container image registry | Stores images that EKS can later deploy |
| Image tag | Version label for a container image | Avoid using only `latest` in production |
| Commit SHA | Unique Git commit identifier | Commonly used as a reliable image tag |
| IAM | AWS identity and access control service | Controls what users, roles, and pipelines can do |
| Least privilege | Granting only the permissions required | Critical for secure enterprise pipelines |
| Security scan | Check for vulnerabilities or secrets | Helps prevent risky code or images from reaching production |
| Artifact | Output created by a pipeline job | Could be a Docker image, report, or package |
| Environment variable | Runtime value passed into a command or pipeline | Used for account ID, region, image name, secrets |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Version control for application, pipeline, Helm, Terraform, and docs |
| GitLab CI or GitHub Actions | Automates build, test, scan, and image push workflow |
| Docker | Builds and tests the capstone application image |
| AWS CLI | Authenticates to AWS and manages ECR |
| Amazon ECR CLI commands | Create repo, login, push images |
| Trivy | Scans container images for vulnerabilities |
| VS Code | Edits project files and pipeline YAML |
| Terminal | Runs local commands |
| YAML | Defines pipeline configuration |
| Markdown | Documents architecture, runbook, and capstone decisions |

---

## 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon ECR | Stores the Docker image built by the pipeline |
| AWS IAM | Controls who or what can push images to ECR |
| AWS STS | Validates the active AWS identity using `aws sts get-caller-identity` |
| Amazon EKS | Not deployed to in Class 1, but image will be used by EKS in Class 2 |
| CloudWatch | Not configured deeply in Class 1, but students begin documenting future monitoring expectations |
| S3 backend concept | Mentioned as future Terraform remote state storage pattern |

### Minimum IAM Permissions for ECR Push

For a beginner lab, students need permissions similar to:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRAuth",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRPushPull",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:CreateRepository",
        "ecr:DescribeRepositories",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "*"
    }
  ]
}
```

Instructor note: In a real enterprise, scope the ECR resource ARN instead of using `"Resource": "*"` for push permissions.

---

## 7. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Kubernetes service | Amazon EKS | Azure Kubernetes Service | Google Kubernetes Engine |
| Pipeline platform | GitLab/GitHub, CodePipeline | Azure DevOps Pipelines, GitHub Actions | Cloud Build, GitHub Actions |
| Identity for pipeline | IAM role, OIDC, STS | Managed identity, federated credentials | Workload Identity Federation |

Practical explanation:

- The workflow is cloud-portable.
- The registry, Kubernetes platform, and IAM model change by cloud provider.
- The DevOps pattern stays the same: build, scan, store, deploy, monitor.

---

## 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Opening, capstone expectations, Class 1 goal |
| 0:10 to 0:25 | Review Week 23 capstone architecture |
| 0:25 to 0:45 | Whiteboard: code to image to ECR workflow |
| 0:45 to 1:05 | Repository structure and documentation expectations |
| 1:05 to 1:25 | Dockerfile and image tagging strategy |
| 1:25 to 1:35 | Break |
| 1:35 to 2:05 | Instructor demo: build and push image to ECR |
| 2:05 to 2:25 | CI/CD pipeline structure: validate, test, build, scan, push |
| 2:25 to 2:45 | Student lab work |
| 2:45 to 2:55 | Troubleshooting activity |
| 2:55 to 3:00 | Recap, homework, Class 2 readiness checklist |

---

## 9. Instructor Lesson Plan

### Step 1: Open the Class

Explain:

> Today we are starting the DevOps capstone build. The goal is to turn course knowledge into a working delivery workflow. By the end of class, your application should build as a Docker image and be pushed into Amazon ECR.

Pause and ask:

- What pieces do we need before Kubernetes can deploy an app?
- Why do we need an image registry?
- Why is a pipeline better than manually building on a laptop?

### Step 2: Review the Capstone Workflow

Show this flow:

```text
Git commit
  ↓
Pipeline
  ↓
Docker build
  ↓
Security scan
  ↓
Amazon ECR
  ↓
Class 2: Helm deploy to EKS
```

Teaching tip:

Beginner students may think CI/CD means only deployment. Clarify that delivery starts earlier: validate, test, build, package, scan, and store.

### Step 3: Explain Repository Structure

Show the recommended structure:

```text
devops-capstone/
├── app/
├── helm/
├── terraform/
├── docs/
└── .gitlab-ci.yml
```

Explain each folder:

- `app/`: application code and Dockerfile
- `helm/`: Kubernetes deployment package for Class 2
- `terraform/`: infrastructure code or structure
- `docs/`: architecture, runbook, rollback, decisions
- `.gitlab-ci.yml`: pipeline definition

Pause for questions before moving to Docker.

### Step 4: Explain Docker Build and Tagging

Explain:

- The Dockerfile defines how the image is built.
- The image must have a registry-compatible tag.
- `latest` is easy but not reliable for production.
- Commit SHA tags are better for traceability.

Example:

```text
devops-capstone-app:latest
devops-capstone-app:a1b2c3d
```

Enterprise talking point:

> In production, if someone asks which version is running, you should be able to trace it back to the exact Git commit.

### Step 5: Demo ECR Push

Show:

1. AWS identity validation
2. ECR repository creation
3. Docker build
4. Docker login to ECR
5. Docker tag
6. Docker push

Pause after each major command and explain expected output.

### Step 6: Introduce CI/CD Pipeline

Explain pipeline stages:

```text
validate → test → build → scan → push
```

Show where environment variables are used:

- `AWS_REGION`
- `AWS_ACCOUNT_ID`
- `ECR_REPOSITORY`
- `IMAGE_TAG`

Teaching tip:

Do not overload beginners with full production OIDC setup unless the class is ready. Explain that real enterprises should avoid long-lived static access keys and use OIDC or managed identity patterns.

### Step 7: Student Lab

Give students time to build their repo, image, ECR push, and pipeline skeleton.

Instructor should circulate and check:

- Dockerfile path
- AWS region
- ECR repository name
- image tag format
- ECR login command
- pipeline YAML indentation

### Step 8: Troubleshooting Activity

Present a failed ECR push error. Have students diagnose the layer:

- AWS identity?
- ECR repo?
- Docker login?
- Image tag?
- IAM permission?

### Step 9: Recap and Prepare for Class 2

End with:

> Class 2 will use this image and deploy it to EKS using Helm. If your image is not in ECR, Class 2 will be blocked.

---

## 10. Instructor Lecture Notes

### Capstone Mindset

This is the transition from learning isolated tools to building a real workflow. In actual DevOps work, engineers rarely use tools independently. Git, CI/CD, Docker, AWS, Kubernetes, Terraform, and monitoring are connected.

A common beginner mistake is thinking the capstone is about getting one command to work. Instead, students should think like engineers building a repeatable delivery system.

Talking point:

> The goal is not just to deploy once. The goal is to create a workflow that another engineer can understand, run, troubleshoot, and improve.

### Why Repository Structure Matters

A messy repository becomes hard to maintain. Enterprise teams need predictable layout because multiple people may work on the same project:

- Developers work in `app/`
- DevOps engineers work on `.gitlab-ci.yml`
- Platform engineers work on Terraform modules
- Kubernetes engineers work on Helm charts
- SREs review runbooks and monitoring docs

Talking point:

> A good repo structure is part of operational readiness. If your repo is confusing, your support process will also be confusing.

### Why Use ECR

Amazon ECR is AWS’s managed container image registry. In Class 2, EKS needs somewhere to pull the application image from. ECR is the natural AWS-first choice.

Common misconception:

> Docker image exists on my laptop, so Kubernetes can use it.

Correction:

> Kubernetes nodes cannot pull images from your laptop. The image must be available from a registry that the cluster can access.

### Why Tagging Matters

Using only `latest` causes confusion. If `latest` changes, teams may not know exactly what version is deployed. Using commit SHA gives traceability.

Example:

```text
Bad for production traceability:
devops-capstone-app:latest

Better:
devops-capstone-app:4f8a91c
```

Talking point:

> When production breaks, you need to know exactly what changed. Image tags help connect running code back to Git history.

### Why Security Scanning Is Included

Security scanning is not only a security team concern. DevOps engineers are often responsible for adding security checks into delivery workflows.

In this class, scanning is basic. Students may use Trivy to scan the image before pushing.

Talking point:

> A security scan does not make an application secure by itself, but it gives the team earlier visibility into known risks.

### Enterprise Context

In a company, a pipeline may need:

- Approval before production
- Separate dev, staging, and prod environments
- Least-privilege AWS role
- Secret management
- Audit logs
- Security scans
- Rollback process
- Monitoring and alerting
- Documentation

This class starts with build and push. Class 2 continues into deployment.

---

## 11. Whiteboard Explanation

### Simple Diagram

```text
[Developer Laptop]
      |
      | git push
      v
[Git Repository]
      |
      | pipeline triggered
      v
[CI/CD Pipeline]
      |
      | docker build
      v
[Docker Image]
      |
      | trivy scan
      v
[Security Check]
      |
      | docker push
      v
[Amazon ECR]
      |
      | used in Class 2
      v
[Amazon EKS Deployment]
```

### Step-by-Step Flow

1. Developer commits code to Git.
2. GitLab or GitHub starts the pipeline.
3. Pipeline checks project files.
4. Pipeline runs tests.
5. Pipeline builds a Docker image.
6. Pipeline scans the image.
7. Pipeline authenticates to AWS.
8. Pipeline pushes the image to ECR.
9. Class 2 uses that image for Kubernetes deployment.

### What Each Component Means

| Component | Meaning |
|---|---|
| Developer laptop | Where code may be written, but not the source of truth |
| Git repository | Source of truth for app, pipeline, infrastructure, and docs |
| CI/CD pipeline | Automation engine |
| Docker image | Packaged application |
| Security check | Basic risk gate |
| Amazon ECR | Registry for approved image |
| Amazon EKS | Future deployment target |

### Enterprise Version

```text
[Developer]
   |
   v
[Merge Request]
   |
   v
[Code Review + Pipeline Validation]
   |
   v
[Build + Unit Test + Scan]
   |
   v
[Amazon ECR]
   |
   v
[Dev Deployment]
   |
   v
[Approval Gate]
   |
   v
[Staging / Production Deployment]
   |
   v
[CloudWatch + Runbooks + Rollback]
```

Enterprise talking point:

> In real teams, production delivery usually includes approvals, audit trails, separation of duties, and rollback planning.

---

## 12. Instructor Demo Script

### Demo Title

**Build, Scan, and Push the Capstone Docker Image to Amazon ECR**

### Demo Objective

Show students how to manually perform the same workflow that the CI/CD pipeline will later automate.

### Required Setup

Instructor needs:

- AWS CLI configured
- Docker running
- ECR permissions
- Sample app folder
- Terminal access
- AWS account ID
- Region selected, example: `us-east-1`

Set variables:

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID="<ACCOUNT_ID>"
export ECR_REPOSITORY="devops-capstone-app"
export IMAGE_TAG="class1-demo"
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
```

### Step 1: Validate AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDAEXAMPLE",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student"
}
```

Explain:

> This confirms which AWS account and identity we are using. Always check identity before creating or pushing resources.

### Step 2: Create ECR Repository

```bash
aws ecr describe-repositories   --repository-names $ECR_REPOSITORY   --region $AWS_REGION
```

If repository does not exist:

```bash
aws ecr create-repository   --repository-name $ECR_REPOSITORY   --region $AWS_REGION
```

Expected output includes:

```json
{
  "repository": {
    "repositoryName": "devops-capstone-app",
    "repositoryUri": "123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app"
  }
}
```

Explain:

> ECR is the storage location for the image. Kubernetes will pull from here later.

### Step 3: Build Docker Image

```bash
docker build -t $ECR_REPOSITORY:$IMAGE_TAG ./app
```

Expected output:

```text
Successfully built <image_id>
Successfully tagged devops-capstone-app:class1-demo
```

Explain:

> The image exists locally now, but EKS cannot use it until it is pushed to a registry.

### Step 4: Test Container Locally

```bash
docker run --rm -p 8080:8080 $ECR_REPOSITORY:$IMAGE_TAG
```

Open another terminal:

```bash
curl http://localhost:8080/health
```

Expected output:

```json
{"status":"healthy"}
```

Explain:

> Before pushing an image, validate it actually runs.

Stop the container with `Ctrl+C`.

### Step 5: Authenticate Docker to ECR

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

Expected output:

```text
Login Succeeded
```

Explain:

> Docker needs temporary authentication to push to the private ECR registry.

### Step 6: Tag Image for ECR

```bash
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
```

Validate:

```bash
docker images | grep $ECR_REPOSITORY
```

Expected output:

```text
devops-capstone-app                                      class1-demo
123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app class1-demo
```

Explain:

> The tag must include the full ECR URI. Without the correct tag, Docker does not know where to push the image.

### Step 7: Gating Image Scan With Trivy (fail on Critical)

Show both the visibility scan and the **gating** scan the pipeline runs:

```bash
# Full report (visibility)
trivy image $ECR_REPOSITORY:$IMAGE_TAG

# Gate: this is what CI enforces — non-zero exit on any CRITICAL
trivy image --severity CRITICAL --exit-code 1 $ECR_REPOSITORY:$IMAGE_TAG
echo "Trivy gate exit code: $?"
```

Expected output:

```text
devops-capstone-app:class1-demo
Total: 0 (CRITICAL: 0)
Trivy gate exit code: 0
```

Explain:

> A scan that always passes is theater. In CI we set `--exit-code 1` for Critical so a Critical CVE fails the build. Exceptions go in `.trivyignore` with a ticket and an expiry — never `|| true`.

### Step 8: Push Image to ECR

```bash
docker push $ECR_URI:$IMAGE_TAG
```

Expected output:

```text
class1-demo: digest: sha256:... size: ...
```

Explain:

> The image is now available in ECR and can be used by the deployment workflow in Class 2.

### Step 9: Confirm Image in ECR

```bash
aws ecr list-images   --repository-name $ECR_REPOSITORY   --region $AWS_REGION
```

Expected output:

```json
{
  "imageIds": [
    {
      "imageTag": "class1-demo"
    }
  ]
}
```

### Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `Unable to locate credentials` | AWS CLI not configured | Run `aws configure` or use correct profile |
| `repository does not exist` | ECR repo missing or wrong region | Create repo or correct region |
| `no basic auth credentials` | Docker not logged into ECR | Re-run ECR login command |
| `denied: not authorized` | IAM permission missing | Add required ECR permissions |
| Docker build fails | Bad Dockerfile or wrong build path | Check `./app` path and Dockerfile |
| App fails locally | App dependency or port issue | Check logs and Dockerfile CMD |

### Cleanup Steps

Optional cleanup if this is a temporary demo:

```bash
docker rmi $ECR_REPOSITORY:$IMAGE_TAG
docker rmi $ECR_URI:$IMAGE_TAG
```

Do not delete the ECR repository if students need it for Class 2.

---

## 13. Student Lab Manual

### Lab Title

**Create the DevOps Capstone Repository and Push a Docker Image to Amazon ECR**

### Lab Objective

Build the first working part of the DevOps capstone pipeline by creating a structured repository, building a Docker image, scanning it, and pushing it to Amazon ECR.

### Estimated Time

45 to 60 minutes

### Student Prerequisites

You should already have:

- Git installed
- Docker installed and running
- AWS CLI configured
- Access to an AWS account
- Permission to create or use ECR
- A GitLab or GitHub repository
- Basic terminal knowledge

### Architecture or Workflow Overview

```text
Local app code
  ↓
Docker build
  ↓
Local container test
  ↓
Security scan
  ↓
ECR login
  ↓
Docker tag
  ↓
Docker push to Amazon ECR
  ↓
Pipeline foundation committed to Git
```

### Step 1: Create Repository Structure

Inside your capstone repo, create:

```bash
mkdir -p app/src
mkdir -p helm/capstone-app/templates
mkdir -p terraform/environments/dev
mkdir -p terraform/environments/prod
mkdir -p terraform/modules
mkdir -p docs
```

Create documentation placeholders, including the **ADR (Architecture Decision Record)** folder — a graded deliverable that carries into Week 24 (capstone finalization) and Week 25 (interview prep):

```bash
touch docs/architecture.md
touch docs/runbook.md
touch docs/rollback-plan.md
touch docs/class1-notes.md
mkdir -p docs/adr
touch docs/adr/0001-record-architecture-decisions.md
touch docs/adr/0002-why-eks-over-ecs.md
touch docs/adr/0003-why-commit-sha-image-tagging.md
```

Expected structure:

```text
devops-capstone/
├── app/
├── helm/
├── terraform/
├── docs/
└── .gitlab-ci.yml or .github/workflows/
```

### Step 2: Add Sample Application

Use the non-trivial sample app from Section 3 (Prerequisites). At minimum create:

- `app/package.json` (Express + pino, `test` runs `node --test`)
- `app/src/server.js` (with `/health`, `/ready`, and a `/sum` endpoint that is unit-tested)
- `app/test/server.test.js` (three real assertions)
- `app/Dockerfile` (multi-stage, non-root, distroless — copied below)

Generate a lockfile so CI can use `npm ci`:

```bash
cd app
npm install            # creates package-lock.json locally
npm test               # confirm the unit tests pass before containerizing
cd ..
```

Create `app/Dockerfile`:

```dockerfile
# ---- Stage 1: build / install production dependencies ----
FROM node:20-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src/ ./src/

# ---- Stage 2: minimal non-root runtime ----
FROM gcr.io/distroless/nodejs20-debian12:nonroot
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY package.json ./
USER nonroot
EXPOSE 8080
CMD ["src/server.js"]
```

### Step 3: Set Environment Variables

Replace `<ACCOUNT_ID>` with your AWS account ID.

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID="<ACCOUNT_ID>"
export ECR_REPOSITORY="devops-capstone-app"
export IMAGE_TAG="$(git rev-parse --short HEAD 2>/dev/null || echo manual)"
export ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
```

Validate:

```bash
echo $ECR_URI
```

Expected output:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app
```

### Step 4: Validate AWS Identity

```bash
aws sts get-caller-identity
```

Expected output includes your account ID.

### Step 5: Provision the ECR Repository with Terraform (Infrastructure as Code)

The registry is infrastructure, so it must be **code**, not a one-off CLI command. This is the difference between "I created a repo" and "anyone can recreate my whole environment from `git clone && terraform apply`." Create `terraform/registry/main.tf`:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # For team use, configure an S3 backend + DynamoDB/S3 lockfile here.
  # backend "s3" { ... }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "repository_name" {
  type    = string
  default = "devops-capstone-app"
}

resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE" # commit-SHA tags can never be overwritten
  force_delete         = true        # lab convenience; remove for production

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}

# Keep storage (and cost) bounded: expire untagged images after 14 days.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}

output "repository_url" {
  value = aws_ecr_repository.app.repository_url
}
```

Render and apply with the "plan before apply" discipline:

```bash
cd terraform/registry
terraform init
terraform fmt -check
terraform validate
terraform plan -out tfplan       # render: review what will change BEFORE applying
terraform apply tfplan
terraform output repository_url   # use this as your $ECR_URI
cd ../..
```

> OpenTofu note: every command above works identically with `tofu` (the open-source Terraform fork) — substitute `tofu` for `terraform`.

> Cost & cleanup: a single empty ECR repo is effectively free; you pay for stored image data (~$0.10/GB-month) and KMS. The lifecycle policy above bounds growth. To tear everything down at the end of the week: `terraform destroy` from `terraform/registry`.

Confirm the repo exists:

```bash
aws ecr describe-repositories   --repository-names $ECR_REPOSITORY   --region $AWS_REGION
```

### Step 6: Build Docker Image

```bash
docker build -t $ECR_REPOSITORY:$IMAGE_TAG ./app
```

Expected output:

```text
Successfully tagged devops-capstone-app:<tag>
```

### Step 7: Test the Container Locally

```bash
docker run --rm -p 8080:8080 $ECR_REPOSITORY:$IMAGE_TAG
```

In another terminal:

```bash
curl http://localhost:8080/health
```

Expected output:

```json
{"status":"healthy"}
```

Stop the container with `Ctrl+C`.

### Step 8: Authenticate Docker to ECR

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

Expected output:

```text
Login Succeeded
```

### Step 9: Tag Image for ECR

```bash
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
```

Validate:

```bash
docker images | grep $ECR_REPOSITORY
```

### Step 10: Optional Security Scan

If Trivy is installed:

```bash
trivy image $ECR_REPOSITORY:$IMAGE_TAG
```

If Trivy is not installed, document this as a future pipeline enhancement in `docs/class1-notes.md`.

### Step 11: Push Image to ECR

```bash
docker push $ECR_URI:$IMAGE_TAG
```

Expected output:

```text
digest: sha256:...
```

### Step 12: Confirm Image Exists in ECR

```bash
aws ecr list-images   --repository-name $ECR_REPOSITORY   --region $AWS_REGION
```

Expected output includes your image tag.

### Step 13: Add the CI Pipeline (Gating Scan + SBOM + Signing + Provenance)

A senior-grade pipeline does not just build and push — it builds a **secure software supply chain**: it fails on Critical vulnerabilities (with a documented exception path), produces an SBOM, signs the image, and attaches provenance. Create `.gitlab-ci.yml`:

```yaml
stages:
  - validate
  - test
  - build-push
  - scan
  - sbom
  - sign

variables:
  AWS_REGION: "us-east-1"
  ECR_REPOSITORY: "devops-capstone-app"
  IMAGE_TAG: "$CI_COMMIT_SHORT_SHA"
  IMAGE: "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$CI_COMMIT_SHORT_SHA"

# Authenticate to AWS via OIDC (keyless) — no long-lived access keys in CI.
# In GitLab this uses an ID token; the assumed role trusts the GitLab OIDC provider.
.oidc_login: &oidc_login
  - >
    export AWS_WEB_IDENTITY_TOKEN_FILE=$(mktemp);
    echo "$GITLAB_OIDC_TOKEN" > "$AWS_WEB_IDENTITY_TOKEN_FILE";
    CREDS=$(aws sts assume-role-with-web-identity
      --role-arn "$CI_DEPLOY_ROLE_ARN"
      --role-session-name "gitlab-ci-$CI_PIPELINE_ID"
      --web-identity-token "$(cat $AWS_WEB_IDENTITY_TOKEN_FILE)"
      --query 'Credentials' --output json);
    export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r .AccessKeyId);
    export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r .SecretAccessKey);
    export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r .SessionToken)

validate:
  stage: validate
  image: alpine:latest
  script:
    - echo "Validating repository structure"
    - test -d app
    - test -f app/Dockerfile
    - test -d docs
    - test -d docs/adr            # ADRs are a required deliverable
    - test -d terraform/registry  # registry must be provisioned as IaC

test:
  stage: test
  image: node:20-bookworm-slim
  script:
    - cd app
    - npm ci                       # reproducible install from the lockfile
    - npm test                     # real unit tests (node --test)

build-push:
  stage: build-push
  image: docker:27
  services:
    - docker:27-dind
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.com
  before_script:
    - apk add --no-cache aws-cli jq
    - *oidc_login
    - aws sts get-caller-identity
    - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
  script:
    # Build with SLSA provenance attestation attached to the image.
    - docker buildx create --use
    - docker buildx build --provenance=true --sbom=true -t "$IMAGE" --push ./app
    # Capture the immutable digest for downstream signing/verification.
    - DIGEST=$(aws ecr describe-images --repository-name $ECR_REPOSITORY --image-ids imageTag=$IMAGE_TAG --query 'imageDetails[0].imageDigest' --output text)
    - echo "IMAGE_DIGEST=$DIGEST" > build.env
  artifacts:
    reports:
      dotenv: build.env

scan:
  stage: scan
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    # GATE: exit non-zero on any unignored CRITICAL finding -> pipeline fails.
    # HIGH is reported but does not block (severity policy below).
    - trivy image --severity HIGH --exit-code 0 --ignorefile .trivyignore "$IMAGE"
    - trivy image --severity CRITICAL --exit-code 1 --ignorefile .trivyignore "$IMAGE"
  allow_failure: false

sbom:
  stage: sbom
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    # Generate a CycloneDX SBOM and keep it as a build artifact.
    - trivy image --format cyclonedx --output sbom.cdx.json "$IMAGE"
  artifacts:
    paths:
      - sbom.cdx.json
    expire_in: 90 days

sign:
  stage: sign
  image: bitnami/cosign:latest
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  script:
    # Keyless signing via Sigstore: identity comes from the CI OIDC token,
    # signature + attestation are stored in the registry/Rekor transparency log.
    - cosign sign --yes "$IMAGE@$IMAGE_DIGEST"
    - cosign attest --yes --predicate sbom.cdx.json --type cyclonedx "$IMAGE@$IMAGE_DIGEST"
  needs:
    - job: build-push
      artifacts: true
    - job: sbom
      artifacts: true
```

Create the scan **exception allowlist** `.trivyignore` (the documented exception path — every entry should reference a ticket and an expiry the team revisits):

```text
# .trivyignore — documented, time-boxed exceptions to the fail-on-CRITICAL gate.
# Each line: CVE id, with a comment giving the reason + tracking ticket + review date.
# Example (remove if not applicable):
# CVE-2024-XXXXX  # no fix available upstream; not reachable in our code; CAP-123; review 2026-09-01
```

**Documented scan-gating policy** (put this in `docs/architecture.md` and reference it from an ADR):

| Severity | Pipeline behavior | Rationale |
|---|---|---|
| CRITICAL | **Fail the build** (`--exit-code 1`) | Highest blast radius; must be fixed or explicitly waived in `.trivyignore` |
| HIGH | Report, do not block | Tracked as backlog tickets; blocking all HIGH stalls delivery |
| MEDIUM / LOW | Report only | Visibility without noise |
| Exception | Add CVE to `.trivyignore` with ticket + expiry | Time-boxed, auditable, revisited |

Security notes:

- **OIDC keyless CI** (shown above) replaces long-lived AWS access keys. The CI role's trust policy should restrict the OIDC `sub` to your project/branch.
- **Keyless cosign signing** ties the signature to the CI identity via Sigstore — no private keys to store or rotate.
- The discussion in Section 15 (Q4) now matches the pipeline: the pipeline answers "yes, Critical blocks — with a documented exception path."

### Step 14: Write Architecture Decision Records (ADRs)

ADRs are a **graded senior deliverable** — they prove you can justify decisions, not just produce YAML. They feed directly into the Week 24 capstone defense and the Week 25 interview prep. Use the lightweight MADR-style template. Create `docs/adr/0001-record-architecture-decisions.md`:

```markdown
# 1. Record architecture decisions

- Status: accepted
- Date: 2026-06-30

## Context
We need a durable, reviewable record of significant architecture decisions so
future engineers (and interviewers) understand *why*, not just *what*.

## Decision
We will keep Architecture Decision Records as numbered Markdown files in
`docs/adr/`. Each ADR captures Context, Decision, Consequences, and Alternatives.

## Consequences
- Decisions are versioned with the code and reviewed in pull requests.
- Onboarding and incident review are faster.
- Superseded decisions are kept (status changed), never deleted.
```

Then write at least two more decision ADRs. Each must include **Alternatives considered** and **Consequences (trade-offs)** — that is the part interviewers probe:

```markdown
# 3. Use commit-SHA image tags (not `latest`)

- Status: accepted
- Date: 2026-06-30

## Context
We need to trace exactly which build is running in any environment and avoid
mutable tags silently changing what is deployed.

## Decision
Tag every image with the short Git commit SHA. The ECR repo is set to IMMUTABLE
so a tag can never be overwritten.

## Alternatives considered
- `latest`: simple, but untraceable and mutable — rejected for prod.
- Semantic version tags: good for released libraries; overkill per-commit here.

## Consequences
- (+) Any running pod maps to an exact Git commit; clean rollback story.
- (+) Immutable tags prevent supply-chain tampering after push.
- (-) More tags to manage; mitigated by the ECR lifecycle policy.
```

Suggested starter ADRs for the capstone: why EKS over ECS (0002), why commit-SHA tagging (0003), why Helm over raw manifests, why GitOps over push-based deploy, why distroless/non-root.

### Step 15: Commit and Push

```bash
git status
git add .
git commit -m "Build capstone foundation: IaC ECR, gating CI, SBOM, signing, ADRs"
git push
```

### Validation Checklist

Students should confirm:

- [ ] Repository structure exists
- [ ] App files exist
- [ ] Dockerfile builds successfully
- [ ] Container runs locally
- [ ] `/health` endpoint responds
- [ ] ECR repository exists
- [ ] Docker login to ECR succeeds
- [ ] ECR repository provisioned via Terraform (not CLI)
- [ ] Image is pushed to ECR
- [ ] Image tag is visible in ECR
- [ ] Pipeline file exists with a gating scan stage
- [ ] `.trivyignore` exception file exists
- [ ] SBOM generated and image signed with cosign
- [ ] At least 2 ADRs written in docs/adr/
- [ ] Documentation draft started (incl. scan-gating policy)

### Troubleshooting Tips

| Problem | What to Check |
|---|---|
| Docker build fails | Dockerfile path, missing package file, build context |
| `aws sts` fails | AWS CLI config, profile, credentials |
| ECR login fails | Region, account ID, IAM permission |
| Push denied | ECR permissions |
| Repo not found | ECR repository name and region |
| Pipeline YAML fails | indentation, image names, missing variables |

### Cleanup Steps

Do not delete ECR image if needed for Class 2.

Optional local cleanup:

```bash
docker ps
docker images
docker rmi $ECR_REPOSITORY:$IMAGE_TAG
docker rmi $ECR_URI:$IMAGE_TAG
```

### Reflection Questions

1. Why does the image need to be stored in ECR?
2. Why is a commit SHA better than only using `latest`?
3. What parts of the workflow should be automated by CI/CD?
4. What security risk exists if AWS access keys are stored as plain variables?
5. What must be completed before Class 2 deployment to EKS?

### Optional Challenge Task

Add a second image tag called `dev`:

```bash
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_URI:dev
docker push $ECR_URI:dev
```

Then document when `dev`, `latest`, and commit SHA tags should or should not be used.

---

## 14. Troubleshooting Activity

### Incident Title

**Pipeline Fails While Pushing Docker Image to Amazon ECR**

### Business Impact

The DevOps team cannot publish the new application image. Because the image is missing from ECR, the Kubernetes deployment planned for Class 2 cannot proceed.

### Symptoms

Pipeline output shows one of the following:

```text
no basic auth credentials
```

or:

```text
denied: User is not authorized to perform: ecr:PutImage
```

or:

```text
repository does not exist
```

or:

```text
An error occurred (UnrecognizedClientException) when calling the GetAuthorizationToken operation
```

### Starting Evidence

Students receive this failed pipeline snippet:

```text
$ docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app:a1b2c3d
The push refers to repository [123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-capstone-app]
no basic auth credentials
ERROR: Job failed: exit code 1
```

### Student Investigation Steps

Students should check:

1. Was AWS identity validated?

```bash
aws sts get-caller-identity
```

2. Does ECR repo exist?

```bash
aws ecr describe-repositories   --repository-names devops-capstone-app   --region us-east-1
```

3. Did Docker login succeed?

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

4. Is image tagged correctly?

```bash
docker images
```

5. Does IAM allow ECR push?

Required actions include:

```text
ecr:GetAuthorizationToken
ecr:BatchCheckLayerAvailability
ecr:InitiateLayerUpload
ecr:UploadLayerPart
ecr:CompleteLayerUpload
ecr:PutImage
```

### Expected Root Cause

Most likely root cause:

```text
Docker was not authenticated to ECR before running docker push.
```

Secondary possible causes:

- Wrong AWS account ID
- Wrong AWS region
- ECR repository does not exist
- Pipeline IAM role lacks ECR push permission

### Correct Resolution

Add or fix the ECR login step before `docker push`:

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
```

Then confirm the image tag:

```bash
docker tag $ECR_REPOSITORY:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
```

Then push again:

```bash
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG
```

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Rebuilding the image repeatedly | The image may build fine. The issue is registry authentication |
| Changing app code | App code is not related to ECR push auth |
| Changing Dockerfile | Dockerfile is not the issue if build succeeded |
| Switching AWS regions randomly | Can create more confusion if repo exists in only one region |
| Giving admin access immediately | Fix the specific missing permission instead |

### Instructor Hints

Start with:

1. Did the build fail, or did the push fail?
2. What system is rejecting the request?
3. Is Docker logged in to ECR?
4. Is the registry URL correct?
5. Which AWS identity is the pipeline using?

### Preventive Action

Students should add a pre-push validation checklist:

```text
- Confirm AWS identity
- Confirm AWS region
- Confirm ECR repository exists
- Confirm Docker login succeeded
- Confirm image tag includes ECR URI
- Confirm IAM role has least-privilege ECR push permissions
```

---

## 15. Scenario-Based Discussion Questions

### Question 1

Should production images be tagged only as `latest`?

Expected response themes:

- No, `latest` is hard to trace.
- Commit SHA or version tags are better.
- `latest` may be useful for local testing, but not production.

Instructor follow-up:

“What would you tell an incident commander who asks which version is currently running?”

### Question 2

Should every developer have permission to push directly to ECR?

Expected response themes:

- Usually no.
- Pipeline should push after validation.
- Direct access should be limited.
- Least privilege matters.

Instructor follow-up:

“How would you separate developer permissions from pipeline permissions?”

### Question 3

What is the risk of storing AWS access keys directly in pipeline variables?

Expected response themes:

- Keys can leak.
- Rotation becomes hard.
- Long-lived credentials increase blast radius.
- OIDC or short-lived credentials are safer.

Instructor follow-up:

“What would an enterprise security team prefer instead?”

### Question 4

Should a vulnerability scan block every deployment? (Our pipeline answers: yes for Critical, with a documented exception path.)

Expected response themes:

- Depends on severity and policy — our policy fails on Critical, reports High.
- Critical vulnerabilities block the build (`--exit-code 1`).
- Medium or low issues create backlog tickets, not blocks.
- Exceptions are time-boxed entries in `.trivyignore` with a ticket and a review date — not `|| true`.

Instructor follow-up:

“What happens if the scan blocks an urgent production hotfix? (Answer: use the documented exception — add a tracked, expiring `.trivyignore` entry — not a blanket bypass.)”

### Question 5

Why do we build the image before deploying to Kubernetes?

Expected response themes:

- Kubernetes deploys images, not raw source code.
- Image is the deployment artifact.
- Registry makes image available to cluster nodes.

Instructor follow-up:

“What happens if EKS cannot pull the image?”

### Question 6

How should teams handle different environments like dev, staging, and prod?

Expected response themes:

- Use separate variables, values files, or environments.
- Avoid hardcoding.
- Use approvals for higher environments.
- Keep the same artifact across environments when possible.

Instructor follow-up:

“Should you rebuild the image for prod, or promote the same image?”

### Question 7

What makes a capstone pipeline enterprise-ready?

Expected response themes:

- Version control
- Automated stages
- Security checks
- Least privilege
- Approval gates
- Documentation
- Rollback plan
- Observability

Instructor follow-up:

“Which of these are required for Class 1, and which continue in Class 2?”

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is the main purpose of Amazon ECR in this class?

A. Run Kubernetes pods  
B. Store Docker container images  
C. Create IAM roles  
D. Monitor application logs  

**Answer:** B  
**Explanation:** ECR is a managed container registry used to store Docker images.

### Question 2: Multiple Choice

Which command confirms the AWS identity currently being used?

A. `aws iam list-users`  
B. `aws configure`  
C. `aws sts get-caller-identity`  
D. `aws ecr list-images`  

**Answer:** C  
**Explanation:** `aws sts get-caller-identity` shows the active AWS account and identity.

### Question 3: True or False

A Docker image that exists only on your laptop can be pulled directly by EKS worker nodes.

**Answer:** False  
**Explanation:** EKS nodes need access to an image registry such as ECR.

### Question 4: Multiple Choice

Which image tag is best for production traceability?

A. `latest`  
B. `test`  
C. Git commit SHA  
D. Empty tag  

**Answer:** C  
**Explanation:** A commit SHA connects the image to a specific source code version.

### Question 5: Short Answer

Why should a pipeline use least-privilege IAM permissions?

**Answer:** To reduce risk by allowing the pipeline to perform only the actions it needs.  
**Explanation:** If credentials are misused or leaked, least privilege limits the blast radius.

### Question 6: Troubleshooting

A pipeline fails with:

```text
no basic auth credentials
```

What is the most likely issue?

**Answer:** Docker is not authenticated to Amazon ECR.  
**Explanation:** The pipeline needs an ECR login step before pushing the image.

### Question 7: Troubleshooting

A Docker push fails with:

```text
repository does not exist
```

List two things to check.

**Answer:** Check whether the ECR repository exists and whether the AWS region is correct.  
**Explanation:** ECR repositories are regional, so a repo in one region is not available in another region.

### Question 8: Multiple Choice

Which pipeline stage usually checks for container vulnerabilities?

A. validate  
B. scan  
C. push  
D. deploy  

**Answer:** B  
**Explanation:** The scan stage is commonly used for image, dependency, or secret scanning.

### Question 9: True or False

Using `latest` is always the best tagging strategy for production deployments.

**Answer:** False  
**Explanation:** `latest` makes version tracking difficult. Commit SHA or semantic version tags are better.

### Question 10: Short Answer

What are the minimum Class 1 outcomes before students move to Class 2?

**Answer:** Repo structure, working Docker build, image pushed to ECR, initial pipeline file, and documentation draft.  
**Explanation:** Class 2 depends on the image and repository foundation created in Class 1.

---

## 17. Homework Assignment

### Assignment Title

**DevOps Capstone Class 1 Documentation and Pipeline Draft**

### Scenario

You are part of a DevOps team building a production-style delivery workflow for a business application. Before deployment can happen, your team must prove that the application can be packaged as a Docker image, scanned, and pushed to Amazon ECR through a repeatable workflow.

### Student Tasks

Complete the following:

1. Finalize capstone repository structure.
2. Confirm Dockerfile builds successfully.
3. Push at least one image tag to Amazon ECR.
4. Create or update the CI/CD pipeline file.
5. Add basic validation, test, build, scan, and push stages.
6. Document the image tagging strategy.
7. Document the ECR repository and AWS region used.
8. Document IAM permissions required.
9. Document known issues or blockers.
10. Prepare questions or blockers for Class 2.

### Expected Deliverables

Students submit:

```text
1. Git repository link or exported folder
2. Screenshot or logs showing Docker image built successfully
3. Screenshot or logs showing image pushed to ECR
4. Pipeline YAML file (gating scan + SBOM + signing)
5. terraform/registry that provisions the ECR repo (plan/apply output)
6. SBOM artifact (sbom.cdx.json) and cosign signature/verify output
7. docs/architecture.md draft (including the scan-gating policy table)
8. docs/adr/ with at least 2 completed ADRs
9. docs/class1-notes.md
10. docs/rollback-plan.md draft placeholder
11. List of known issues and next steps
```

### Submission Format

Submit either:

- Git repository link, or
- Zip file of repository, plus screenshots or command outputs

### Estimated Completion Time

1.5 to 2.5 hours

### Grading Criteria

| Criteria | Points |
|---|---:|
| Repository structure is clean and complete | 15 |
| Dockerfile builds successfully | 15 |
| Container runs locally and health check works | 15 |
| Image pushed to ECR | 20 |
| Pipeline file includes required stages | 20 |
| Documentation draft is clear and useful | 15 |
| Total | 100 |

### Optional Advanced Challenge

Implement commit SHA tagging in the pipeline and document how the image can be traced back to the Git commit.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | Fix or Avoidance |
|---|---|---|
| Building from the wrong directory | Student runs Docker build from incorrect path | Use `docker build -t name:tag ./app` |
| Forgetting ECR login | Students think AWS CLI login is enough | Run `aws ecr get-login-password` with `docker login` |
| Wrong AWS region | ECR repo exists in a different region | Set and verify `AWS_REGION` |
| Wrong account ID | Copy/paste error | Confirm with `aws sts get-caller-identity` |
| Using only `latest` | It is simple and common in examples | Add commit SHA or version tags |
| Bad YAML indentation | YAML is whitespace-sensitive | Use editor validation |
| Missing Docker daemon | Docker Desktop not running | Start Docker and run `docker ps` |
| Overly broad IAM permissions | Easier during labs | Explain least privilege and restrict later |
| Skipping local container test | Students rush to push | Test `/health` before push |
| Not documenting blockers | Students assume they will remember | Write blockers in `docs/class1-notes.md` |

---

## 19. Real-World Enterprise Scenario

### Scenario

A logistics company is modernizing an internal shipment tracking application. The application team writes code, but the DevOps team is responsible for creating a standard delivery workflow.

The business wants faster releases, but the security team requires image scanning and controlled AWS access. The platform team requires all container images to be stored in Amazon ECR before they can be deployed to EKS.

### Constraints

| Constraint | Example |
|---|---|
| Access control | Developers should not have broad AWS admin permissions |
| Security | Images must be scanned before deployment |
| Cost | Resources should be reused and cleaned up when no longer needed |
| Reliability | Pipeline should produce repeatable artifacts |
| Auditability | Every image should map back to a Git commit |
| Production impact | Broken images should not reach Kubernetes deployments |

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build pipeline, image workflow, scanning, and registry push |
| Cloud Engineer | Provide ECR, IAM role, AWS account access, and network foundation |
| SRE | Review deployment readiness, logs, rollback, and future monitoring expectations |

### How This Class Applies

This class creates the artifact foundation. Without a reliable image build and registry process, deployment automation becomes fragile.

---

## 20. Instructor Tips

### Teaching Tips

- Keep reminding students that Class 1 is about the image supply chain.
- Do not let students jump too early into Kubernetes deployment.
- Use the whiteboard flow repeatedly.
- Ask students to identify which layer failed: Git, pipeline, Docker, AWS, ECR, or IAM.
- Encourage documentation while building, not after everything is finished.

### Pacing Tips

- Keep Docker build explanation short if students already know Docker.
- Spend more time on ECR tagging and authentication because it causes many failures.
- Keep security scanning simple.
- Avoid deep IAM theory, but explain least privilege clearly.
- Save Helm and EKS deployment depth for Class 2.

### Lab Support Tips

When students are stuck, ask:

1. What command failed?
2. What exact error did it return?
3. Which system returned the error?
4. What identity are you using?
5. What region are you using?
6. What changed since the last successful step?

### Helping Struggling Students

Give them a minimum success path:

1. Build image locally.
2. Run image locally.
3. Push image to ECR manually.
4. Commit repo structure.
5. Add pipeline skeleton even if pipeline is not fully working yet.

### Challenging Advanced Students

Ask them to add:

- Commit SHA image tagging (done by default in the pipeline)
- A gating Trivy stage with a `.trivyignore` exception workflow
- GitLab OIDC to AWS role assumption (keyless CI)
- ECR lifecycle policy provisioned in Terraform
- SBOM generation (CycloneDX) as a pipeline artifact
- Keyless image signing + SBOM attestation with cosign, then `cosign verify`
- SLSA provenance via `docker buildx --provenance=true`
- Pinning the base image to a digest
- A third ADR (e.g., "why distroless/non-root base image")
- Separate dev and prod image tags
- README badge or pipeline status documentation

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] Why a container registry is required
- [ ] What Amazon ECR does
- [ ] Why image tags matter
- [ ] Why `latest` is risky for production
- [ ] How CI/CD stages connect together
- [ ] Why least-privilege pipeline access matters
- [ ] How Class 1 prepares for EKS deployment in Class 2

### Students Should Be Able to Build or Configure

- [ ] Capstone repository structure
- [ ] Basic sample application
- [ ] Dockerfile
- [ ] Docker image
- [ ] Local container health check
- [ ] ECR repository
- [ ] ECR image push
- [ ] Basic CI/CD pipeline file
- [ ] Documentation draft

### Students Should Be Able to Troubleshoot

- [ ] Docker build failure
- [ ] Local container failure
- [ ] AWS CLI credential issue
- [ ] ECR repository missing
- [ ] Docker ECR login failure
- [ ] Image tag mismatch
- [ ] Pipeline YAML syntax issue
- [ ] Missing IAM permission

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

Confirm students understand:

- [ ] Capstone Class 1 objective
- [ ] Repository structure
- [ ] Docker build process
- [ ] ECR login and push process
- [ ] Pipeline stage structure
- [ ] Common ECR push failures
- [ ] Homework expectations
- [ ] What must be ready for Class 2

### Student Checklist Before Leaving Class

Students should have:

- [ ] Created or updated capstone repository
- [ ] Added app folder
- [ ] Added Dockerfile
- [ ] Built Docker image locally
- [ ] Tested container locally
- [ ] Created or used ECR repository
- [ ] Logged in to ECR
- [ ] Pushed image to ECR
- [ ] Started pipeline YAML
- [ ] Started documentation draft

### Items to Verify Before Moving to Class 2

Class 2 depends on these items:

```text
Required before Class 2:
- ECR repository exists
- Docker image is pushed to ECR
- Image tag is known
- Helm folder exists or is ready to be created
- Pipeline file has at least build and push workflow started
- Documentation includes architecture and known blockers
```

If a student does not complete ECR push before Class 2, they can still participate, but they should use an instructor-provided image temporarily while continuing to fix their own pipeline.

---

## Class Artifacts & Validation

This class is the **build-and-publish** half of the capstone. The on-disk, validated
artifacts live in the integration module [`labs/capstone/`](../../labs/capstone/), which
*reuses* (does not re-code) the supply-chain artifacts built in earlier weeks. The rows
below are the artifacts **this class uses** — the demo stack that builds the same image,
the supply-chain/IaC files the pipeline produces, and the capstone's own integration
checks. Every path was `ls`-verified and every command was run in this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/capstone/validate.sh` | shell | Capstone gate runner (YAML parse, reference check, shell syntax, compose config ×2) | `cd labs/capstone && ./validate.sh` | PASS — `7 passed, 0 failed, 0 deferred`, exit 0 |
| 2 | `labs/capstone/docker-compose.demo.yaml` | compose | Local demo that **builds the same image** from `../docker-containers` (no fork) + Redis + optional Prometheus | `docker compose -f docker-compose.demo.yaml config` | PASS (default + `--profile metrics`); narrated `up`/`curl /healthz → {"status":"ok"}` in the lab README §Validation |
| 3 | `labs/capstone/tests/check_references.sh` | shell | Asserts every sibling-module path the capstone wires together exists (the "dangling reference" detector) | `bash tests/check_references.sh` | PASS — `every referenced labs/ path resolves`, exit 0 |
| 4 | `labs/terraform-aws-foundations/solution/main.tf` | terraform | The IaC registry/VPC/EKS foundation the capstone provisions on (Step 5 ECR-as-code) | `terraform init -backend=false && terraform validate` | PASS — `Success! The configuration is valid.`, `fmt -check` clean |
| 5 | `labs/cicd-pipelines/solution/.github/workflows/ci.yml` | gha | The CI pipeline (lint/test/build/scan) this class's pipeline mirrors | YAML parse: `python3 -c "import yaml;list(yaml.safe_load_all(open(f)))"` | PASS (parses); enforced by capstone gate 3 (path-exists) |
| 6 | `labs/cicd-pipelines/solution/.github/workflows/cd.yml` | gha | The CD pipeline (`helm upgrade --install`) the supply chain hands off to | YAML parse (as above) | PASS (parses); enforced by capstone gate 3 |
| 7 | `labs/capstone/adr/0002-managed-vs-self-hosted.md` | markdown | A real ADR (decision table + "revisit when…" triggers) — the graded senior deliverable | manual review vs. `starter/adr/NNNN-template.md` | PASS — records a real trade-off with a rejected alternative |
| 8 | `labs/capstone/architecture/architecture.mmd` | mermaid | Full-system diagram; every box maps to one course module | `mmdc -i … -o …` (render) | DEFERRED — `mmdc` not installed here; structurally valid `flowchart TB`; render at <https://mermaid.live> |

> **Honesty note.** There is **no separate `solution/` source tree** in `labs/capstone` by
> design — the README states the capstone "writes almost no new code"; its reference
> implementation *is* the committed integration files (demo compose, ADRs, checklist,
> runbook, reference checker). The student starting point is `labs/capstone/starter/`.
> The end-to-end `docker compose up` + `curl` run is **documented in the lab README** but
> is **not committed as a captured live-evidence file**; the reproducible static gate is
> `docker compose config` (PASS here) plus the YAML-parse and reference gates.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence): demo `docker-compose.demo.yaml`, `validate.sh`, `check_references.sh`, plus the reused Terraform/CI/CD solution files.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured: `./validate.sh` 7/7, `terraform validate` Success, `docker compose config` ×2 PASS; Mermaid render **DEFERRED** (`mmdc` absent — documented).
- [x] Lab has **starter** (intentionally incomplete `starter/capstone-brief.md` + `starter/adr/NNNN-template.md`) and a reference **solution** (the committed integration files; no separate `solution/` tree by design — README explains why).
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent: `docker compose … --profile metrics down -v`; cloud profile is plan-only (`terraform destroy` documented).
- [x] **Instructor answer key** exists: README §"Instructor answer key" plus the in-class mini-quiz answer key (Section 16) and troubleshooting resolution (Section 14).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state*: the capstone's broken state is a **dangling reference** — delete/rename a referenced path and re-run gate 3 (`check_references.sh`) to see it fail.
- [x] **Expected outputs** are shown for the demo and gates (e.g., `/healthz → {"status":"ok"}`, `7 passed, 0 failed`).
- [x] **Cost & security warnings** present: $0 local demo, plan-only cloud, non-root/read-only/cap-drop, localhost-only ports, no secrets committed.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct: reuses Weeks for Docker/CI-CD/Terraform; hands off to Class 2 and Week 24.
- [x] The **artifact manifest** (§4.2) is present and every cited path resolves (verified with `ls` and `check_references.sh`).
- [ ] **Live cloud apply/destroy** evidence committed — *not done*: the cloud profile is plan-only by default and no captured `terraform apply`/`destroy` or live `up`+`curl` log is committed in `labs/capstone`. This is the honest gap that caps the score (see scoring).
