# Week 9: CI/CD Fundamentals
# Class 2 Package: Building Practical CI/CD Workflows for Real Teams

**Week:** 9
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

> **▶ Runnable lab for this class:** [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Class 2: Building Practical CI/CD Workflows for Real Teams**

### Class Purpose

This class builds on the real CI pipeline students created in Class 1 (lint, test, build artifact, security gate). Class 2 makes the **CD half real**: variables and secrets, **keyless OIDC authentication to AWS**, a **real artifact publish to S3** with **GitHub Environments + required-reviewer approval**, and the core **deployment strategies** every senior is asked about — rolling, blue/green, and canary — with rollback.

The goal is no longer "simulate a deploy with echo." By the end, students will have actually published a versioned artifact to a real cloud target through a gated promotion, and will be able to explain and sketch each deployment strategy.

### How This Class Builds From Class 1

In Class 1, students learned:

- What CI/CD means
- How pipelines are triggered
- How jobs and stages work
- How to create a real lint, test, build, and security-gate pipeline
- How to troubleshoot basic YAML and artifact errors

Class 2 extends that by adding:

- Pipeline variables and real secrets handling
- Build provenance / traceability (commit SHA, not just a timestamp)
- Keyless OIDC authentication from GitHub Actions to AWS (no stored keys)
- A real CD target: publishing the build artifact to S3 with environment promotion
- GitHub Environments with required-reviewer approval gates
- Deployment strategies: rolling, blue/green, canary — and rollback
- DORA metrics framing (deployment frequency, lead time, change-fail rate, MTTR)
- More realistic troubleshooting scenarios

### What Students Will Build, Analyze, or Practice

Students will:

- Enhance their Class 1 pipeline with variables and real build provenance.
- Configure keyless OIDC auth from GitHub Actions to AWS (an IAM role, no static keys).
- Publish the build artifact to a real S3 bucket through a gated `production` environment.
- Configure a GitHub Environment with a required reviewer (real approval, not an echo).
- Analyze and diagram rolling, blue/green, and canary deployments, and rollback.
- Troubleshoot OIDC trust, artifact path, and environment-gating failures using the evidence-first method.

---

## 2. Quick Review of Class 1

### Review Points

1. A CI/CD pipeline is an automated workflow made of jobs and steps.
2. CI is a real gate: install, lint, unit tests (exit-code-driven), build artifact, security scans.
3. CD prepares or performs delivery and deployment.
4. A runner executes pipeline commands.
5. The build artifact was tagged with the commit SHA for traceability.
6. Security gates (gitleaks, pip-audit) fail the build on findings.
7. Job logs are the first place to investigate failures (read top-to-bottom).
8. Branch protection with required status checks is what *enforces* the gate.

### Quick Recall Questions

#### Question 1

What is the difference between a job and a stage?

**Expected answer:**  
A job is a specific task. A stage is a group or phase that organizes jobs.

#### Question 2

What caused the pipeline in Class 1 to start?

**Expected answer:**  
A push or merge request triggered the pipeline.

#### Question 3

Why did we tag the Class 1 artifact with the commit SHA?

**Expected answer:**  
For traceability — so we can tie the artifact to the exact commit and roll back to a known-good version later.

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students may still confuse CI and CD | Re-explain CI as validation and CD as delivery or deployment. |
| Students may not fully understand runners | Remind them that the runner is the machine executing commands. |
| Students may treat YAML as ordinary text | Reinforce indentation and structure. |
| Students may not read job logs carefully | Model how to read logs from top to bottom. |
| Students may not see why provenance matters | Connect SHA-tagging to rollback. |

### Bridge Into Class 2

Instructor transition:

> Last class, we built a real CI gate: lint, tests, a SHA-tagged artifact, and security scans, enforced by branch protection. Today we make the CD half real — keyless OIDC auth to AWS, publishing that artifact to S3 through a gated `production` environment with a reviewer, and the deployment strategies (rolling, blue/green, canary) every senior is asked about.

---

## 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** how a build artifact moves through a CI/CD workflow and why commit-SHA provenance beats a timestamp.
2. **Compare** normal variables and secrets, and explain why OIDC keyless auth is preferred over stored AWS keys.
3. **Configure** OIDC federation from GitHub Actions to an AWS IAM role with `aws-actions/configure-aws-credentials`.
4. **Build** a real CD job that publishes a versioned artifact to S3 behind a gated `production` environment with a required reviewer.
5. **Describe and diagram** rolling, blue/green, and canary deployment strategies, including how each rolls back.
6. **Frame** delivery health using DORA metrics (deployment frequency, lead time, change-failure rate, MTTR).
7. **Troubleshoot** OIDC trust-policy, environment-gating, and artifact failures using the evidence-first method.
8. **Document** a branch-based promotion workflow (dev → staging → production) with approvals.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should understand:

- What CI/CD means
- The Class 1 CI gate (lint, test, build artifact, security scans) on the Flask app
- How to trigger a workflow by pushing / opening a PR
- How to view workflow job logs
- That the build artifact is tagged with the commit SHA
- That branch protection enforces the gate

### Required Prior Concepts

Students should already know:

- Basic Git workflow (Week 3)
- Basic terminal commands (Week 2)
- Basic YAML indentation
- Basic branch and pull request concepts
- Basic idea of dev, staging, and production environments
- Basic AWS IAM (Week 6) helps when reading the OIDC trust policy

### Required Tools Already Installed

Students need:

- Git and Python 3.11+
- AWS CLI v2 (for the one-time OIDC + S3 setup)
- VS Code
- Terminal
- Browser
- GitHub account (primary)

### Required Files, Repos, or Setup From Class 1

Students should have one working repository from Class 1.

Expected repository (the GitHub Actions project from Class 1, primary):

```text
week-09-student-ci/
├── README.md
├── requirements-dev.txt
├── app/
│   ├── __init__.py
│   └── main.py
├── tests/
│   └── test_main.py
└── .github/
    └── workflows/
        └── ci.yml
```

Expected Class 1 pipeline stages:

```text
lint -> test -> build -> security
```

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Variable | A reusable value used inside a pipeline. | Teams use variables for app names, environment names, image tags, and paths. |
| Secret | A sensitive value protected by the CI/CD platform. | AWS keys, tokens, passwords, and registry credentials must be stored securely. |
| Environment | A target location where code may run, such as dev, staging, or prod. | Teams promote changes through environments to reduce risk. |
| Approval Gate | A manual checkpoint before a risky action. | Production deployments often require approval. |
| Artifact Expiration | A rule that deletes saved artifacts after a period of time. | Helps control storage usage and cost. |
| Branch Rule | A pipeline condition based on branch name. | Feature branches may test only, while main may deploy. |
| Protected Branch | A branch with restrictions on who can push or merge. | Main and production branches are usually protected. |
| Pipeline Promotion | Moving a build from one environment to another. | Example: dev to staging to production. |
| OIDC Federation | Keyless cloud auth: CI presents a short-lived OIDC token, the cloud trusts it and returns temporary role credentials. | GitHub Actions assumes an AWS IAM role with NO stored access keys. |
| GitHub Environment | A named deployment target (e.g. `production`) that can require reviewers and hold environment-scoped secrets. | Used to gate prod with a human approval. |
| Rolling Deployment | Replace instances/pods a few at a time so there is no full outage. | Default for Kubernetes Deployments. |
| Blue/Green Deployment | Run two full environments (blue=live, green=new); switch traffic all at once; roll back by switching back. | Fast rollback, double the resources during cutover. |
| Canary Deployment | Send a small % of traffic to the new version, watch metrics, then ramp up or abort. | Limits blast radius of a bad release. |
| Rollback | Returning to a known-good previous version after a bad deploy. | Re-deploy the previous artifact/tag, or switch traffic back. |
| DORA Metrics | Four delivery-health metrics: deployment frequency, lead time, change-failure rate, MTTR. | How teams/SREs measure whether delivery is fast AND safe. |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Tracks code and triggers pipelines through commits and pushes. |
| GitHub Actions (primary) | Runs the CI/CD workflow, including the real OIDC deploy job. |
| `aws-actions/configure-aws-credentials@v4` | Performs OIDC `AssumeRoleWithWebIdentity` — keyless AWS auth. |
| AWS CLI v2 | One-time setup (OIDC provider, role, bucket) and the `s3 cp` publish. |
| GitHub Environments | Real production gate with a required reviewer. |
| GitLab CI (comparison only) | Same OIDC/deploy concept with `rules:` (not legacy `only:`). |
| YAML | Defines pipeline behavior. |
| VS Code / Terminal / Browser | Edit files, run commands, review runs and artifacts. |

---

## 7. AWS Services Used

This class uses **real AWS resources** in the OIDC + S3 publish lab: an IAM OIDC identity provider, one IAM role, and one S3 bucket. These are all free-tier-friendly (a tiny object in S3 costs effectively nothing), but you MUST run the cleanup steps.

> Cost and security warning: the S3 bucket and IAM role are real. Leaving an over-permissive IAM role or a public bucket around is a real security risk. Use a least-privilege policy (shown in the demo), keep the bucket private, and delete everything in the cleanup section. There are NO long-lived access keys in this lab — that is the entire point of OIDC.

| AWS Service | How It Connects to Class 2 |
|---|---|
| IAM (OIDC provider + role) | Trusts GitHub's OIDC token so the pipeline assumes a role with NO stored keys. |
| STS | Issues the short-lived credentials when `configure-aws-credentials` assumes the role. |
| Amazon S3 | The real CD target — the pipeline publishes the versioned build artifact here. |
| Amazon ECR | Where Week 10 pipelines will push Docker images (named here, built next week). |
| CloudWatch | Where deployments send logs/metrics for operational visibility (Week 16). |

### Security Warning

Do not place AWS access keys directly in `.gitlab-ci.yml` or GitHub workflow files.

Bad example:

```yaml
variables:
  AWS_ACCESS_KEY_ID: "AKIA..."
  AWS_SECRET_ACCESS_KEY: "secret..."
```

Better approach:

- Use CI/CD protected variables.
- Use masked secrets.
- Use IAM roles or OIDC-based role assumption in later advanced modules.

---

## 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Pipeline identity | IAM role, STS, OIDC | Managed Identity, Service Connection | Service Account, Workload Identity |
| Artifact storage | S3 | Blob Storage | Cloud Storage |
| Container registry | ECR | Azure Container Registry | Artifact Registry |
| CI/CD platform | GitLab CI or GitHub Actions with AWS | Azure DevOps Pipelines | Cloud Build |

Practical note for students:

> The CI/CD concepts are portable. The syntax and cloud permissions change, but the workflow idea stays similar.

---

## 9. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:10 | Class 1 review | Recap the real CI gate and branch protection |
| 0:10 to 0:25 | Variables, secrets, provenance | Reusable values vs secrets; commit-SHA traceability |
| 0:25 to 0:50 | OIDC keyless auth to AWS | Why no static keys; how the trust + role assumption works |
| 0:50 to 1:20 | Deployment strategies | Rolling, blue/green, canary, rollback (diagrams + tradeoffs) |
| 1:20 to 1:30 | Break | Short break |
| 1:30 to 2:05 | Instructor demo | Real CD: OIDC → publish artifact to S3 → gated `production` environment with approval |
| 2:05 to 2:45 | Student lab | Students wire OIDC + S3 publish + environment approval |
| 2:45 to 2:55 | Troubleshooting | Diagnose an OIDC trust-policy failure (evidence-first) |
| 2:55 to 3:00 | DORA + recap | Frame delivery health; close the week |

---

## 10. Instructor Lesson Plan

### Step 1: Start With Class 1 Continuity

Open the class by showing the basic pipeline from Class 1:

```text
lint -> test -> build -> security
```

Explain:

> This was our first quality gate. Today we make it closer to what teams actually use.

Pause and ask:

> What was missing from our first pipeline?

Expected answers:

- No variables
- No secrets
- No branch behavior
- No approval
- No real environment concept

### Step 2: Explain Why Variables Matter

Show a hardcoded value:

```yaml
script:
  - echo "Building demo-app for dev"
```

Then show a variable-based version:

```yaml
variables:
  APP_NAME: "demo-app"
  ENVIRONMENT: "dev"

script:
  - echo "Building $APP_NAME for $ENVIRONMENT"
```

Explain:

> Variables make pipelines reusable. Instead of rewriting the pipeline for every app or environment, teams pass values into the pipeline.

### Step 3: Explain Secrets Without Exposing Real Secrets

Explain:

> Secrets are variables, but not all variables are secrets. Application name is not secret. AWS credentials are secret.

Show examples:

| Normal Variable | Secret |
|---|---|
| `APP_NAME` | `AWS_SECRET_ACCESS_KEY` |
| `ENVIRONMENT` | `DATABASE_PASSWORD` |
| `BUILD_DIR` | `API_TOKEN` |

Teaching tip: do not ask students to create real AWS secrets in this class.

### Step 4: Explain Artifacts and Provenance

In Class 1, the artifact was a SHA-tagged tarball. In Class 2 we publish it to S3 alongside a `PROVENANCE` file that records:

- The exact commit SHA
- The build run ID
- (Advanced) an SBOM of what shipped

Explain:

> Real release evidence is provenance, not a timestamp. "Which commit is in prod, and what was in it?" must be answerable months later — and it is what makes rollback to a known-good SHA possible.

### Step 5: Explain Branch-Based Workflow

Draw:

```text
feature/* -> validate and test
develop   -> deploy to dev
release/* -> deploy to staging
main      -> production approval
```

Teaching tip: keep this conceptual. Students do not need a complex branch rules implementation yet.

### Step 6: Explain OIDC Keyless Auth (the modern replacement for keys)

Explain the problem with stored keys, then the OIDC fix:

> Old way: paste an AWS access key into CI secrets. If it leaks, an attacker has long-lived access. New way: GitHub Actions presents a short-lived OIDC token for this exact repo/branch; AWS trusts GitHub as an identity provider and hands back temporary credentials that expire in an hour. Nothing long-lived is ever stored.

Draw the flow:

```text
GitHub Actions job
   | (1) requests an OIDC token (id-token: write)
   v
GitHub OIDC issuer  token.actions.githubusercontent.com
   | (2) signed token: "repo=ORG/REPO, ref=refs/heads/main"
   v
AWS STS  AssumeRoleWithWebIdentity
   | (3) trust policy checks issuer + sub condition
   v
Temporary AWS credentials (expire ~1h)  -> used by the deploy job
```

Pause and ask:

> What stops ANY GitHub repo from assuming our role?

Expected answer: the IAM trust policy's `sub` condition pins it to our specific repo (and optionally branch/environment).

### Step 7: Explain Deployment Strategies

Teach the three core strategies and when to use each (full diagrams in the Lecture Notes and Whiteboard sections):

- **Rolling** — replace a few instances at a time. Default, cheap, slow rollback.
- **Blue/Green** — two full environments, switch all traffic at once, instant rollback by switching back. Doubles resources briefly.
- **Canary** — send a small % of traffic to the new version, watch metrics, ramp or abort. Smallest blast radius, needs good observability.

Emphasize rollback for each. Note these are realized concretely later with Kubernetes (Weeks 11-12) and Argo Rollouts-style tooling, but the decision-making is a senior-screen staple now.

### Step 8: Explain Manual Approvals as Real GitHub Environments

Explain:

> Manual approval is not anti-automation; it is controlling production risk. In GitHub Actions this is a real feature: a **GitHub Environment** named `production` with a **required reviewer**. The deploy job declares `environment: production` and pauses until a named human approves.

Common production approval reasons: change window, business approval, security requirement, incident freeze, high-risk deployment.

### Step 9: Run Instructor Demo

Build the real CD path: enhance the Class 1 pipeline with variables + provenance, configure OIDC to AWS, and add a `deploy` job that publishes the artifact to S3 — gated by the `production` environment.

### Step 10: Student Lab

Students wire OIDC + S3 publish + environment approval on their own repo.

Support order:

1. Confirm the IAM OIDC provider and role exist
2. Confirm the trust policy `sub` matches their repo
3. Confirm `permissions: id-token: write` is set on the job
4. Confirm the `environment: production` reviewer is configured
5. Confirm the artifact path matches what gets uploaded to S3

### Step 11: Troubleshooting Activity

Give students a pipeline whose OIDC role assumption fails (trust-policy `sub` mismatch / missing `id-token: write`). Ask them to read the exact STS error first.

### Step 12: Close the Week with DORA

Frame the week's work with DORA metrics, then:

> Next week (Week 10) we use this exact pipeline with Docker: the artifact becomes a container image pushed to ECR, deployed with the strategies we diagrammed today.

---

## 11. Instructor Lecture Notes

### Opening Notes

> Class 1 gave us a basic pipeline. Class 2 is about making that pipeline behave more like something a real team would use.

> In real teams, the same pipeline often supports multiple branches, multiple environments, multiple applications, and controlled production releases.

### Artifacts

Artifacts are saved outputs from pipeline jobs.

In beginner labs, artifacts may be simple text files. In real environments, they may include:

- Application packages
- Test reports
- Build logs
- Security scan reports
- Terraform plan files
- Generated documentation
- Deployment manifests

Talking point:

> Artifacts create traceability — but only if they carry real provenance. A timestamp alone is weak. Real traceability ties the artifact to the exact **commit SHA**, the build run, and ideally an **SBOM** (the inventory of what is inside). That is how a team answers, months later: which commit is running in prod, and what dependencies shipped with it?

So in Class 2 we tag the artifact with the commit SHA (`${GITHUB_SHA}`), not just `$(date)`.

### Variables

Variables reduce hardcoding.

Example hardcoded pipeline problem:

```text
The app name is written in five places.
The environment name is written in three places.
The build folder path is repeated in every job.
```

If those values change, the team must edit the pipeline in multiple places.

With variables:

```yaml
variables:
  APP_NAME: "demo-ci-app"
  ENVIRONMENT: "dev"
  BUILD_DIR: "build"
```

The pipeline becomes easier to maintain.

### Secrets

Secrets are sensitive values.

Examples:

- AWS credentials
- Database password
- Container registry token
- API key
- SSH private key
- Deployment token

Important talking point:

> Never commit secrets to Git. If a secret is in Git history, assume it is compromised.

Beginner-friendly phrasing:

> A normal variable is okay to show. A secret is something you would not want posted in Slack, email, or a public GitHub repo.

### Approvals

Manual approvals are common in production workflows.

Explain:

> Automation should reduce manual work, but it should not remove judgment from risky production changes.

Examples of approval gates:

- Production deployment approval
- Infrastructure apply approval
- Security exception approval
- Database migration approval
- Emergency release approval

### Branch-Based Workflows

Common simple pattern:

| Branch Type | Pipeline Behavior |
|---|---|
| `feature/*` | Validate and test |
| `develop` | Validate, test, package, deploy to dev |
| `release/*` | Deploy to staging |
| `main` | Deploy to production after approval |

Explain:

> Branch rules let teams map code workflow to environment workflow.

### AWS Integration Context (Now Real via OIDC)

We DO implement a real AWS deployment today — publishing the artifact to S3 — using keyless OIDC so there are no stored credentials.

| Pipeline Step | AWS Connection (this class) |
|---|---|
| Package artifact | Publish to S3 (real, this class) |
| Pipeline identity | Assume an IAM role via OIDC (real, this class) |
| Build Docker image | Push to ECR (Week 10) |
| Deploy job | Deploy to EKS, ECS, or Lambda (Weeks 11-12) |
| Secrets | GitHub Environment secrets / AWS Secrets Manager (Week 6) |

### Deployment Strategies

Every senior screen probes these. Teach the tradeoff, not just the name.

```text
ROLLING
  v1 v1 v1 v1   ->   v2 v1 v1 v1   ->   v2 v2 v1 v1   ->   v2 v2 v2 v2
  Replace a few at a time. No extra environment.
  Rollback = roll forward/back through the same slow process.

BLUE/GREEN
  [ blue v1 ] <- 100% traffic        [ blue v1 ] <- 0%
  [ green v2 ] <- 0% (warming)  ==>   [ green v2 ] <- 100% (flip the router)
  Instant cutover, instant rollback (flip back). Costs 2x during cutover.

CANARY
  v2 gets 5% -> watch error rate/latency -> 25% -> 50% -> 100%
  (abort and route back to v1 at any step if metrics regress)
  Smallest blast radius. Requires good observability (Week 16).
```

| Strategy | Rollback | Extra cost | Best when |
|---|---|---|---|
| Rolling | Slow (re-roll) | None | Stateless services, low risk |
| Blue/Green | Instant (flip) | ~2x briefly | Need fast, clean rollback |
| Canary | Abort + route back | Small | High-risk change, good metrics |

> Rollback is the question behind the question. Whatever strategy you name, be ready to say exactly how you undo a bad release. In CI/CD terms, the simplest rollback is "re-deploy the previous artifact/tag" — which is why SHA-tagged artifacts matter.

### Delivery Health: DORA Metrics

For the SRE audience, frame pipeline value with the four DORA metrics:

| Metric | What it measures |
|---|---|
| Deployment frequency | How often you ship |
| Lead time for changes | Commit → running in prod |
| Change-failure rate | % of deploys that cause an incident/rollback |
| MTTR (time to restore) | How fast you recover from a bad change |

A good pipeline improves all four at once: fast (frequency, lead time) AND safe (change-failure rate, MTTR via easy rollback).

### Common Misconceptions

| Misconception | Correction |
|---|---|
| Variables and secrets are the same | Secrets are sensitive and must be protected. |
| Manual approval means no automation | Approval is a controlled checkpoint inside automation. |
| Artifacts are only for compiled apps | Artifacts can also be reports, plans, manifests, or logs. |
| Branch rules are only for developers | DevOps and cloud teams use branch rules for infrastructure changes too. |
| A pipeline should deploy everything automatically from day one | Start simple, then automate safely. |

---

## 12. Whiteboard Explanation

### Class 1 Pipeline

```text
Code Push
   |
   v
Pipeline
   |
   |-- validate
   |-- test
   |-- package
   |
   v
Artifact
```

### Class 2 Extended Pipeline

```text
Code Push (main)
   |
   v
CI (Class 1): lint -> test -> build SHA-tagged artifact -> security scan
   |
   v
deploy-production job
   |
   |-- permissions: id-token: write
   |-- OIDC -> AWS STS AssumeRoleWithWebIdentity (no stored keys)
   |-- environment: production  ==> PAUSE for required reviewer
   |
   v
Approved -> aws s3 cp artifact + provenance -> S3
```

### Environment Promotion Flow

```text
Feature Branch
   |
   | validate and test
   v
Merge Request
   |
   | review and approve
   v
Develop Branch
   |
   | deploy to dev
   v
Release Branch
   |
   | deploy to staging
   v
Main Branch
   |
   | manual approval
   v
Production
```

### Real-World Enterprise Version

```text
Developer
   |
   v
Feature Branch
   |
   v
Merge Request
   |
   v
CI Pipeline
   |
   |-- Code validation
   |-- Unit tests
   |-- Security scan
   |-- Build artifact
   |-- Store artifact
   |
   v
Code Review
   |
   v
Environment Promotion
   |
   |-- Dev
   |-- Staging
   |-- Production Approval
   |
   v
Production Deployment
```

### How Class 2 Extends Class 1

| Class 1 | Class 2 |
|---|---|
| CI gate (lint/test/build/scan) | Real CD: publish to AWS |
| SHA-tagged artifact built in CI | Same artifact published to S3 with provenance |
| Static config | Keyless OIDC auth (no stored keys) |
| Branch protection enforces merge | `production` environment + reviewer enforces deploy |
| No deployment strategy | Rolling / blue-green / canary + rollback |
| Import/test troubleshooting | OIDC trust-policy troubleshooting |

---

## 13. Instructor Demo Script

### Demo Title

**Real CD: Keyless OIDC to AWS, Publish a SHA-Tagged Artifact to S3, Gated by a `production` Environment**

### Demo Objective

Turn the Class 1 CI pipeline into a real CD pipeline that:

- Builds a SHA-tagged artifact (real provenance, not a timestamp)
- Authenticates to AWS via OIDC (no stored keys)
- Publishes the artifact to a real S3 bucket
- Gates the publish behind a `production` GitHub Environment with a required reviewer

### Required Setup

Instructor needs:

- The Class 1 GitHub repo (`week-09-ci-demo`) with the working CI pipeline
- AWS CLI v2 configured locally with admin (for one-time setup only)
- An AWS account ID handy

> Note: OpenTofu is a drop-in open-source alternative to Terraform; everything below is plain AWS CLI v2 so it is tool-agnostic.

### Step 1: One-Time AWS Setup — OIDC Provider, Role, and Bucket

Do this once, locally. These are real resources; cleanup is at the end.

```bash
export AWS_REGION=us-east-1
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export BUCKET="w9-ci-demo-${ACCOUNT_ID}"     # globally unique
export GH_ORG="<YOUR_GH_USER_OR_ORG>"
export GH_REPO="week-09-ci-demo"

# 1. Create the GitHub OIDC identity provider (idempotent: errors if it already exists, which is fine)
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 1c58a3a8518e8759bf075b76b750d4f2df264fcd

# 2. Trust policy: ONLY this repo's main branch may assume the role
cat > trust.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
      "StringLike": { "token.actions.githubusercontent.com:sub": "repo:${GH_ORG}/${GH_REPO}:ref:refs/heads/main" }
    }
  }]
}
EOF
aws iam create-role --role-name w9-ci-deploy --assume-role-policy-document file://trust.json

# 3. Create a private bucket (block public access is on by default in current AWS)
aws s3api create-bucket --bucket "$BUCKET" --region "$AWS_REGION"

# 4. Least-privilege policy: write ONLY to this bucket
cat > policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:PutObject"],
    "Resource": "arn:aws:s3:::${BUCKET}/artifacts/*"
  }]
}
EOF
aws iam put-role-policy --role-name w9-ci-deploy --policy-name w9-s3-put --policy-document file://policy.json

echo "Role ARN: arn:aws:iam::${ACCOUNT_ID}:role/w9-ci-deploy"
echo "Bucket:   ${BUCKET}"
```

Explain each part:

- The OIDC provider tells AWS to trust tokens from GitHub.
- The trust policy's `sub` condition pins assumption to **this repo, main branch** — no other repo can use the role.
- The inline policy grants **only** `s3:PutObject` to **one** bucket prefix — least privilege.

> Security warning: scope the `sub` as tightly as you can. `repo:ORG/*` would let any repo in the org assume the role.

### Step 2: Store Non-Secret Config as Repo Variables

In GitHub: **Settings → Secrets and variables → Actions → Variables** — add `AWS_ROLE_ARN` and `S3_BUCKET`. These are not secrets (the ARN/bucket name are not sensitive), and there is no access key to store anywhere.

### Step 3: Create the `production` Environment with a Reviewer

In GitHub: **Settings → Environments → New environment → `production`**. Add yourself (or a co-instructor) under **Required reviewers**. Now any job that targets this environment pauses for approval.

### Step 4: Add the Deploy Job to the Workflow

Add to `.github/workflows/ci.yml` (the CI jobs from Class 1 stay as-is):

```yaml
  deploy-production:
    needs: [lint-test-build, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production          # <-- pauses for the required reviewer
    permissions:
      id-token: write                # <-- REQUIRED for OIDC
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Build SHA-tagged artifact
        run: |
          mkdir -p dist
          tar -czf "dist/app-${GITHUB_SHA::7}.tar.gz" app requirements.txt
          echo "commit=${GITHUB_SHA}"  > dist/PROVENANCE
          echo "run=${GITHUB_RUN_ID}" >> dist/PROVENANCE

      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Publish artifact to S3
        run: |
          aws s3 cp "dist/app-${GITHUB_SHA::7}.tar.gz" \
            "s3://${{ vars.S3_BUCKET }}/artifacts/app-${GITHUB_SHA::7}.tar.gz"
          aws s3 cp dist/PROVENANCE \
            "s3://${{ vars.S3_BUCKET }}/artifacts/app-${GITHUB_SHA::7}.provenance"
```

Explain:

- `id-token: write` is mandatory — without it the OIDC token request fails.
- `configure-aws-credentials@v4` performs `AssumeRoleWithWebIdentity` and exports temporary creds for the rest of the job.
- `environment: production` makes the job wait for the human reviewer — a real approval gate, not an echo.
- The artifact and a `PROVENANCE` file are keyed by commit SHA — that is what makes rollback ("re-publish/re-deploy the previous SHA") possible.

### Step 5: Push, Approve, Verify

```bash
git add .github/workflows/ci.yml
git commit -m "Add real OIDC + S3 deploy gated by production environment"
git push
```

1. Open **Actions**; CI runs, then `deploy-production` shows **Waiting** for review.
2. Click **Review deployments → Approve**.
3. Watch the OIDC step succeed and the S3 copy run.
4. Verify the object exists:

```bash
aws s3 ls "s3://${BUCKET}/artifacts/"
```

Expected:

```text
2026-06-30 14:05:00     1234 app-1a2b3c4.provenance
2026-06-30 14:05:00    20480 app-1a2b3c4.tar.gz
```

### Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `Error: Could not assume role ... Not authorized to perform sts:AssumeRoleWithWebIdentity` | Trust policy `sub` does not match repo/branch | Match `repo:ORG/REPO:ref:refs/heads/main` exactly |
| `Error: Credentials could not be loaded ... OIDC` | Missing `id-token: write` permission on the job | Add it under `permissions:` |
| `AccessDenied` on `s3:PutObject` | Inline policy prefix mismatch | Confirm the policy resource matches the `s3 cp` key prefix |
| Deploy job never runs | `if: github.ref == 'refs/heads/main'` and you pushed a branch | Merge to main, or run from main |
| Job stuck "Waiting" | Required reviewer not approving | Approve under Review deployments |

### Cleanup Steps

> Cost/security: leftover IAM roles and buckets are real liabilities. Delete them.

```bash
aws s3 rm "s3://${BUCKET}" --recursive
aws s3api delete-bucket --bucket "$BUCKET"
aws iam delete-role-policy --role-name w9-ci-deploy --policy-name w9-s3-put
aws iam delete-role --role-name w9-ci-deploy
# Delete the OIDC provider only if no other repo/role uses it:
# aws iam delete-open-id-connect-provider \
#   --open-id-connect-provider-arn arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com
```

### Comparison Appendix: The Same Deploy in GitLab CI (with `rules:`, not legacy `only:`)

GitLab CI also supports OIDC to AWS. The key modernization: use `rules:` for conditional execution, not the deprecated `only:`/`except:`.

```yaml
deploy_production:
  stage: deploy
  image: amazon/aws-cli:2.17.0
  id_tokens:
    AWS_OIDC_TOKEN:
      aud: sts.amazonaws.com
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'   # modern replacement for `only: - main`
      when: manual                        # manual approval gate
  script:
    - >
      export $(aws sts assume-role-with-web-identity
      --role-arn "$AWS_ROLE_ARN"
      --role-session-name gitlab-ci
      --web-identity-token "$AWS_OIDC_TOKEN"
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text | awk '{print "AWS_ACCESS_KEY_ID="$1" AWS_SECRET_ACCESS_KEY="$2" AWS_SESSION_TOKEN="$3}')
    - aws s3 cp "dist/app-${CI_COMMIT_SHORT_SHA}.tar.gz" "s3://$S3_BUCKET/artifacts/"
```

> Do not use `only:`/`except:` in new GitLab pipelines — they are legacy. `rules:` is the supported mechanism and is what 2026 employers expect to see.

---

## 14. Student Lab Manual

### Lab Title

**Real CD: Wire OIDC to AWS and Publish a SHA-Tagged Artifact to S3 Behind a Gated `production` Environment**

### Lab Objective

Extend your Class 1 GitHub Actions pipeline so it authenticates to AWS with **no stored keys** (OIDC), publishes the build artifact to a real **S3** bucket, and requires a **human approval** via a GitHub Environment before publishing.

### Estimated Time

40 to 45 minutes

### Student Prerequisites

Students should have:

- Completed the Class 1 lab (working CI pipeline on the Flask app)
- AWS CLI v2 configured locally (for one-time setup only)
- Their GitHub repo from Class 1

> Cost/security warning: this lab creates a real IAM role and S3 bucket. They are free-tier-friendly but MUST be deleted in the cleanup step. No long-lived AWS keys are created — that is the point of OIDC.

### Workflow Overview

```text
Class 1 CI (lint, test, build, security)
   |
   v
One-time AWS setup: OIDC provider + IAM role (scoped to your repo) + S3 bucket
   |
   v
Add deploy-production job (OIDC -> assume role -> aws s3 cp)
   |
   v
production environment requires YOUR approval
   |
   v
Approve -> artifact lands in S3 (verify with aws s3 ls)
```

### Step 1: One-Time AWS Setup

Run the setup script from the Instructor Demo Script, Step 1, substituting your GitHub user/org and repo name. It creates:

- the GitHub OIDC provider (if not already present),
- an IAM role `w9-ci-deploy` whose trust policy `sub` is pinned to `repo:<YOU>/<REPO>:ref:refs/heads/main`,
- a private S3 bucket,
- a least-privilege inline policy allowing only `s3:PutObject` to that bucket's `artifacts/*` prefix.

Note the printed Role ARN and bucket name.

### Step 2: Add Repo Variables and the `production` Environment

1. **Settings → Secrets and variables → Actions → Variables**: add `AWS_ROLE_ARN` (the role ARN) and `S3_BUCKET` (the bucket name).
2. **Settings → Environments → New environment → `production`**: add yourself as a **Required reviewer**.

### Step 3: Add the Deploy Job

Append to `.github/workflows/ci.yml`:

```yaml
  deploy-production:
    needs: [lint-test-build, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Build SHA-tagged artifact
        run: |
          mkdir -p dist
          tar -czf "dist/app-${GITHUB_SHA::7}.tar.gz" app
          echo "commit=${GITHUB_SHA}" > dist/PROVENANCE

      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Publish artifact to S3
        run: |
          aws s3 cp "dist/app-${GITHUB_SHA::7}.tar.gz" \
            "s3://${{ vars.S3_BUCKET }}/artifacts/app-${GITHUB_SHA::7}.tar.gz"
          aws s3 cp dist/PROVENANCE \
            "s3://${{ vars.S3_BUCKET }}/artifacts/app-${GITHUB_SHA::7}.provenance"
```

### Step 4: Push, Approve, Verify

```bash
git add .github/workflows/ci.yml
git commit -m "Add OIDC + S3 deploy gated by production"
git push
```

1. In **Actions**, the `deploy-production` job shows **Waiting**.
2. Click **Review deployments → Approve**.
3. Verify the upload:

```bash
aws s3 ls "s3://${BUCKET}/artifacts/"
```

### Expected Outputs

The OIDC step logs a successful role assumption (no keys printed), and the S3 listing shows your artifact:

```text
2026-06-30 14:05:00     1234 app-1a2b3c4.provenance
2026-06-30 14:05:00    20480 app-1a2b3c4.tar.gz
```

### Validation Checklist

Students should confirm:

- The deploy job has `permissions: id-token: write`.
- OIDC role assumption succeeds (no stored AWS keys anywhere).
- The `production` environment paused the job for approval.
- The artifact is named with the commit SHA and lands in S3.
- The IAM policy only allows `s3:PutObject` to one bucket prefix (least privilege).
- No secrets are hardcoded in YAML.

### Troubleshooting Tips

| Problem | What to Check (evidence first) |
|---|---|
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` | Trust policy `sub` must match `repo:<YOU>/<REPO>:ref:refs/heads/main` |
| `OIDC` / credentials could not be loaded | Is `id-token: write` set on the deploy job? |
| `AccessDenied` on PutObject | Does the IAM policy prefix match your `s3 cp` key? |
| Deploy job skipped | `if: github.ref == 'refs/heads/main'` — are you on main? |
| Job stuck "Waiting" | Approve under Review deployments |
| Pipeline did not start | Did you push the workflow file? |

### Cleanup Steps

Real AWS resources were created — delete them.

```bash
aws s3 rm "s3://${BUCKET}" --recursive
aws s3api delete-bucket --bucket "$BUCKET"
aws iam delete-role-policy --role-name w9-ci-deploy --policy-name w9-s3-put
aws iam delete-role --role-name w9-ci-deploy
cd ..
rm -rf week-09-student-ci
```

Delete the GitHub repo if you no longer need it.

### Reflection Questions

1. With OIDC, what exactly is GitHub sending to AWS, and why is it safer than a stored access key?
2. What in the IAM trust policy stops another repo from assuming your role?
3. Why tag the artifact with the commit SHA instead of just a timestamp?
4. What did the `production` environment add that a plain `if:` branch check did not?
5. If this deploy were live and bad, which deployment strategy would give you the fastest rollback, and why?

### Optional Challenge Task

Generate an SBOM and publish it alongside the artifact for full provenance:

```yaml
      - name: Generate SBOM (syft)
        uses: anchore/sbom-action@v0
        with:
          path: .
          output-file: dist/sbom.spdx.json
      - name: Publish SBOM to S3
        run: aws s3 cp dist/sbom.spdx.json "s3://${{ vars.S3_BUCKET }}/artifacts/app-${GITHUB_SHA::7}.sbom.json"
```

Advanced students: add a second environment `staging` (auto-deploy, no reviewer) and promote staging → production.

---

## 15. Troubleshooting Activity

### Incident Title

**Deploy Job Fails at the OIDC Step: "Not authorized to perform sts:AssumeRoleWithWebIdentity"**

### Business Impact

CI is green, but the `deploy-production` job fails before it can publish. The release is blocked and the team suspects "AWS is down" — it is not.

### Symptoms

The Actions log shows:

```text
Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

or, in a different run:

```text
Error: Credentials could not be loaded, please check your action inputs:
OIDC token could not be requested
```

### Starting Evidence

Broken deploy job + trust policy:

```yaml
  deploy-production:
    needs: [lint-test-build, security]
    runs-on: ubuntu-latest
    environment: production
    permissions:
      contents: read          # <-- note: no id-token here
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - run: aws s3 cp dist/app.tar.gz "s3://${{ vars.S3_BUCKET }}/artifacts/"
```

Trust policy on the role:

```json
"Condition": {
  "StringLike": { "token.actions.githubusercontent.com:sub": "repo:acme/some-other-repo:*" }
}
```

### Student Investigation Steps

Apply the evidence-first method:

1. Which step failed *first*? (The OIDC/credentials step, before any S3 call.)
2. Two distinct errors are possible — distinguish them:
   - "OIDC token could not be requested" → the *job* could not even mint a token → missing `id-token: write`.
   - "Not authorized to perform sts:AssumeRoleWithWebIdentity" → token minted, but *AWS refused it* → trust policy `sub` mismatch.
3. Compare the trust policy `sub` to the actual repo/branch running the job.

### Expected Root Cause

Two independent defects:

1. The job is missing `id-token: write`, so GitHub never issues the OIDC token.
2. The trust policy `sub` points at `repo:acme/some-other-repo:*`, not the repo actually running the workflow — so even with a token, STS rejects it.

### Correct Resolution

```yaml
    permissions:
      id-token: write     # mint the OIDC token
      contents: read
```

```json
"Condition": {
  "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
  "StringLike":   { "token.actions.githubusercontent.com:sub": "repo:<YOU>/week-09-student-ci:ref:refs/heads/main" }
}
```

After fixing, re-run; the OIDC step succeeds and the S3 copy runs.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Adding a static AWS access key as a secret | Defeats the entire purpose of OIDC; reintroduces a leakable credential. |
| Widening the trust `sub` to `repo:ORG/*` | Lets any repo in the org assume the role — over-broad. |
| Granting the role `s3:*` on `*` | Violates least privilege; the bucket prefix scope is correct. |
| Assuming AWS is down | The error is an authorization decision, not an outage. |

### Instructor Hints

1. "Read the first failed line — token request, or authorization?"
2. "Did the job request an OIDC token? Check `permissions`."
3. "Does the trust policy `sub` match THIS repo and branch?"
4. "Is the audience (`aud`) `sts.amazonaws.com`?"

### Preventive Action

Students should learn to:

- Always set `id-token: write` on OIDC deploy jobs.
- Pin the trust `sub` to the exact repo and branch (or environment).
- Keep IAM policies least-privilege (one action, one resource prefix).
- Never fall back to static keys to "make it work."
- Distinguish "token not minted" from "AWS rejected token" by reading the exact error.

---

## 16. Scenario-Based Discussion Questions

### Question 1

**Why do real teams use variables instead of hardcoding values in pipeline files?**

Expected themes:

- Easier maintenance
- Reusability
- Environment flexibility
- Less duplication

Follow-up:

> What values would change between dev and production?

### Question 2

**Which pipeline values are safe as normal variables, and which should be secrets?**

Expected themes:

- App name is safe
- Environment name is safe
- AWS credentials are secrets
- Tokens and passwords are secrets

Follow-up:

> What happens if a secret is committed to Git?

### Question 3

**Why might production deployment require manual approval?**

Expected themes:

- Change control
- Business risk
- Compliance
- Incident freeze
- Customer impact

Follow-up:

> What approvals might be needed for infrastructure changes?

### Question 4

**Should dev deployments be automatic?**

Expected themes:

- Often yes
- Speeds feedback
- Lower risk than production
- Depends on team maturity

Follow-up:

> What checks should pass before dev deployment?

### Question 5

**How can artifacts help during troubleshooting?**

Expected themes:

- Show what was built
- Preserve reports
- Provide evidence
- Help compare builds

Follow-up:

> What artifact would help troubleshoot a failed Terraform pipeline?

### Question 6

**How does CI/CD support reliability from an SRE perspective?**

Expected themes:

- Reduces unsafe changes
- Creates audit trail
- Enables rollback planning
- Connects changes to incidents

Follow-up:

> How could pipeline history help during an outage?

### Question 7

**What is the tradeoff between fast delivery and production safety?**

Expected themes:

- Faster pipelines improve speed
- Missing checks increase risk
- Approval gates slow delivery but reduce risk
- Automation and observability improve confidence

Follow-up:

> How do mature teams keep delivery fast without being reckless?

### Question 8

**You must ship a high-risk change to a service with good metrics. Which deployment strategy do you choose, and how do you roll back?**

Expected themes:

- Canary to limit blast radius (small % first, watch error rate/latency)
- Abort and route back to the previous version if metrics regress
- Blue/green is a valid alternative if you want an instant full cutover/rollback
- Rolling is cheapest but slow to roll back
- Rollback always returns to a known-good artifact/SHA

Follow-up:

> What metric would you watch to decide whether to promote or abort the canary, and where does that metric come from (Week 16 observability)?

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is the main benefit of using variables in a pipeline?

A. They make Git unnecessary  
B. They make values reusable and easier to maintain  
C. They automatically deploy to production  
D. They remove the need for runners  

**Answer:** B  
**Explanation:** Variables reduce hardcoding and make pipelines easier to reuse.

### Question 2: Multiple Choice

Which of the following should be treated as a secret?

A. Application name  
B. Build directory  
C. AWS secret access key  
D. Environment name  

**Answer:** C  
**Explanation:** AWS secret access keys are sensitive credentials.

### Question 3: True or False

A manual approval job can still be part of an automated pipeline.

**Answer:** True  
**Explanation:** Manual approval can be a controlled checkpoint inside an automated workflow.

### Question 4: True or False

Artifacts are only useful for compiled programming languages.

**Answer:** False  
**Explanation:** Artifacts can include reports, logs, metadata, Terraform plans, or deployment files.

### Question 5: Short Answer

How does Class 2 extend the pipeline created in Class 1?

**Answer:**  
Class 2 adds variables, SHA-tagged build provenance, keyless OIDC auth to AWS, a real S3 publish gated by a `production` environment with a required reviewer, and deployment strategies (rolling, blue/green, canary).

**Explanation:** Class 1 focused on basic CI structure. Class 2 makes it more realistic.

### Question 6: Short Answer

What is the difference between a normal variable and a secret?

**Answer:**  
A normal variable stores non-sensitive values. A secret stores sensitive values such as passwords, tokens, or cloud credentials.

**Explanation:** Secrets require protection and should not be committed to source control.

### Question 7: Troubleshooting

A pipeline fails with:

```text
cannot create build/app-info.txt: Directory nonexistent
```

What is the likely fix?

**Answer:**  
Create the directory before writing the file:

```bash
mkdir -p build
```

**Explanation:** The file cannot be written because the folder does not exist.

### Question 8: Troubleshooting

A job creates:

```text
build/app-info.txt
```

But the artifact path is:

```text
output/app-info.txt
```

What will likely happen?

**Answer:**  
The artifact upload will fail or report no files found.

**Explanation:** The artifact path must match the actual generated file location.

### Question 9: AWS-Related

Which AWS service would commonly store Docker images built by a CI/CD pipeline?

A. Amazon ECR  
B. Amazon Route 53  
C. AWS Budgets  
D. AWS CloudTrail  

**Answer:** A  
**Explanation:** Amazon ECR is AWS’s container image registry.

### Question 10: AWS-Related

With GitHub Actions OIDC to AWS, which workflow permission must the deploy job declare?

A. `contents: write`  
B. `id-token: write`  
C. `packages: write`  
D. None — OIDC needs no permissions  

**Answer:** B  
**Explanation:** `id-token: write` lets the job request the OIDC token that AWS STS exchanges for temporary credentials.

### Question 11: Deployment Strategy

Which deployment strategy gives the fastest rollback by keeping a full previous environment live and switching traffic back?

A. Rolling  
B. Canary  
C. Blue/green  
D. Recreate  

**Answer:** C  
**Explanation:** Blue/green keeps both environments; rollback is flipping traffic back to the old (blue) version. It costs ~2x resources during cutover.

### Question 12: Troubleshooting

A deploy job fails with `Not authorized to perform sts:AssumeRoleWithWebIdentity`. The job has `id-token: write`. What is the most likely cause?

**Answer:**  
The IAM role's trust-policy `sub` condition does not match the repo/branch running the workflow.

**Explanation:** The token was minted (permission present) but AWS rejected it — that is an authorization decision in the trust policy, not a missing permission.

### Question 13: Class 1 and Class 2 Connection

In Class 1 the artifact was built in CI. What does Class 2 add to that same artifact?

**Answer:**  
It is published to a real S3 target via OIDC, gated by a `production` environment, and accompanied by a `PROVENANCE` file tying it to the exact commit SHA.

**Explanation:** This turns a build artifact into a traceable, gated release — and the SHA makes rollback possible.

### Question 14: Class 1 and Class 2 Connection

In Class 1, the pipeline used hardcoded messages. In Class 2, those values are moved into what?

**Answer:**  
Variables (and, for sensitive values, secrets).

**Explanation:** Variables make the pipeline easier to update and reuse; secrets protect sensitive values.

---

## 18. Homework Assignment

### Assignment Title

**Design a Practical CI/CD Workflow for Dev, Test, and Production**

### Scenario

A development team is building a containerized web application. They want every merge request to run validation and tests. When code merges to `develop`, it should deploy to dev. When code merges to `main`, it should require approval before production deployment. Artifacts should be stored after each build. Secrets must not be hardcoded in the repository.

### Student Tasks

Students must create a design document that includes:

1. Pipeline workflow diagram
2. Branch strategy
3. Pipeline stages
4. Required variables
5. Required secrets
6. Artifact strategy
7. Approval points
8. Three possible failure points
9. One AWS service that could be used later
10. Explanation of how the workflow protects production

### Expected Deliverables

Students submit:

- Markdown or PDF document
- Pipeline diagram
- Stage table
- Variable and secret table
- Failure scenario list
- Short AWS integration section

### Submission Format

Accepted:

- `.md`
- `.pdf`
- `.docx`
- Git repo `README.md`

### Estimated Completion Time

90 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Clear workflow diagram | 15 |
| Correct branch strategy | 15 |
| Practical pipeline stages | 20 |
| Variables and secrets correctly separated | 15 |
| Artifact strategy included | 10 |
| Approval gates explained | 10 |
| AWS integration idea included | 10 |
| Failure points identified | 5 |

### Optional Advanced Challenge

Implement the design as a working GitHub Actions workflow that includes:

- A SHA-tagged build artifact
- OIDC auth to AWS (no stored keys)
- A real S3 publish gated by a `production` environment with a required reviewer
- A one-paragraph note on which deployment strategy you would use and how you would roll back

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Forgetting `$` before variable name | Students are new to shell syntax | Use `$APP_NAME` in shell commands |
| Creating artifact in one path but uploading another | Path mismatch | Align script output and artifact path |
| Not creating the build directory | Directory does not exist by default | Add `mkdir -p $BUILD_DIR` |
| Treating secrets as normal variables | Students do not understand credential risk yet | Explain secret exposure with examples |
| Forgetting `id-token: write` on the deploy job | OIDC permission is opt-in per job | Add it under `permissions:` |
| Trust policy `sub` too broad or mismatched | Copy-pasting without pinning the repo | Pin `repo:ORG/REPO:ref:refs/heads/main` exactly |
| Falling back to static AWS keys when OIDC fails | Frustration | Debug the trust policy; never reintroduce long-lived keys |
| Expecting the gated job to run automatically | Environment requires reviewer action | Explain GitHub Environment approval behavior |
| Assuming all branches should deploy | Beginners may not know environment strategy | Map branch behavior to environment risk |

---

## 20. Real-World Enterprise Scenario

### Scenario

A logistics company has a web application used by internal operations teams. Developers are merging changes quickly, but QA and operations teams are concerned about untested changes reaching production.

The platform team is asked to create a standard CI/CD workflow that publishes signed, traceable artifacts to AWS and can later support Docker, AWS ECR, and Kubernetes deployments.

### Constraints

- Feature branches must run validation and tests.
- Dev deployment can be automatic; production requires a human approval.
- AWS credentials must NOT be stored anywhere — OIDC keyless auth only.
- Build artifacts must be retained and traceable to a commit SHA.
- Pipeline logs must support incident review (DORA: MTTR).
- The workflow must be understandable by developers, DevOps engineers, cloud engineers, and SREs.

### How the Class Topic Applies

Class 2 introduces the controls needed for this scenario:

- Variables for reusable configuration; secrets handled correctly
- SHA-tagged artifacts for traceability and rollback
- Keyless OIDC auth to AWS (no stored credentials)
- Branch-based promotion with a gated `production` environment
- A real S3 publish behind a required reviewer
- Deployment-strategy choice (rolling/blue-green/canary) with a rollback plan

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Build pipeline templates, variables, artifacts, and approvals. |
| Cloud Engineer | Design secure AWS access for future deploy jobs. |
| SRE | Ensure pipeline supports reliability, traceability, and incident investigation. |
| Developer | Use branches and fix failed checks before merge. |
| Security Engineer | Validate secret handling and access controls. |
| Engineering Manager | Decide approval policy and production release expectations. |

---

## 21. Instructor Tips

### Teaching Tips

- Keep the pipeline simple but real — the OIDC + S3 path is the centerpiece.
- Use the Class 1 pipeline as the starting point.
- Do the one-time AWS setup yourself live so students see the trust policy `sub` being pinned.
- Stress: NO static AWS keys, ever. OIDC is the whole point.
- Reinforce that manual approvals (GitHub Environments) are normal and are a real feature, not an echo.

### Pacing Tips

- Spend no more than 15 minutes on variables/secrets recap.
- Budget real time for OIDC and deployment strategies — these are the senior-screen topics.
- Reserve at least 35 minutes for the student lab; AWS setup eats time.
- Use the OIDC troubleshooting activity as a group exercise if students are stuck.

### Lab Support Tips

When a student gets stuck, check (evidence first):

1. Did the deploy job request a token (`id-token: write`)?
2. Does the trust policy `sub` match their repo/branch?
3. Is the IAM policy prefix aligned with the `s3 cp` key?
4. Is the `production` reviewer configured?
5. Are they on `main`?

### Helping Struggling Students

Give them a minimal OIDC deploy job to verify just the auth path before adding S3:

```yaml
  oidc-check:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1
      - run: aws sts get-caller-identity
```

If `get-caller-identity` prints the assumed-role ARN, the trust is correct; then add the S3 step.

### Challenging Advanced Students

Ask advanced students to:

- Add a `staging` environment (auto, no reviewer) and promote staging → production
- Generate and publish an SBOM (syft) alongside the artifact
- Pin the trust policy `sub` to a GitHub *environment* instead of a branch
- Add a `concurrency:` group to cancel superseded deploys
- Sketch a canary rollout for this artifact and define the metric that would abort it

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

- Why variables are useful in pipelines
- Difference between variables and secrets
- Why artifacts matter
- Why manual approvals are used
- How branch-based workflows support environment promotion
- How AWS services like ECR, S3, IAM, and STS connect to future pipelines

### Students Should Be Able to Build or Configure

- Pipeline variables
- A SHA-tagged build artifact with provenance
- OIDC keyless auth from GitHub Actions to an AWS IAM role
- A real S3 publish job
- A GitHub `production` environment with a required reviewer
- A least-privilege IAM trust policy and inline policy

### Students Should Be Able to Troubleshoot

- OIDC token / `id-token: write` failures
- Trust-policy `sub` mismatches (`AssumeRoleWithWebIdentity` denied)
- IAM `AccessDenied` on S3 (policy prefix mismatch)
- Environment-gated jobs stuck waiting for approval
- Artifact path mismatches
- Pipeline not triggering after push

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

Confirm that students can:

- Explain variables vs secrets, and why OIDC beats stored keys
- Explain how OIDC role assumption works (token → trust policy → STS)
- Explain and diagram rolling, blue/green, and canary, with rollback
- Explain why production uses a gated environment with a reviewer
- Troubleshoot an OIDC trust failure

Confirm most students have:

- Configured OIDC + an IAM role scoped to their repo
- Published a SHA-tagged artifact to S3 through a gated environment
- Approved a deployment via the `production` environment
- Completed the OIDC troubleshooting activity
- Run the AWS cleanup steps

### Student Checklist Before Leaving Class

Students should verify:

- My deploy job uses OIDC with `id-token: write` (no stored AWS keys).
- My trust policy is pinned to my repo and branch.
- My artifact published to S3 and is named with the commit SHA.
- The `production` environment required my approval before publishing.
- I can explain rolling vs blue/green vs canary and how each rolls back.
- I ran the AWS cleanup steps.

### Items to Verify Before Closing the Week

Before moving to Week 10, students should understand:

- CI/CD validates AND delivers changes (this week shipped a real artifact to S3).
- OIDC is the modern, keyless way pipelines authenticate to the cloud.
- Artifacts must carry provenance (commit SHA) to support rollback.
- Deployment strategies (rolling/blue-green/canary) trade off speed, cost, and blast radius.
- Production gates (environments + reviewers) control risk without killing automation.
- DORA metrics measure whether delivery is fast AND safe.

---

## 24. End-of-Week Summary

### What Students Learned This Week

Students built a real CI/CD pipeline: a genuine integration gate (lint, test, build, security) AND a real delivery path that publishes a traceable artifact to AWS through a gated approval.

They learned:

- CI vs Continuous Delivery vs Continuous Deployment
- Real gates: lint, unit tests (exit-code-driven), build artifact, security scans (gitleaks, pip-audit)
- Branch protection / required status checks as enforcement
- SHA-tagged artifacts and provenance
- Keyless OIDC authentication to AWS
- A real S3 publish gated by a GitHub Environment with a reviewer
- Deployment strategies: rolling, blue/green, canary, and rollback
- DORA metrics framing
- Evidence-first troubleshooting (including OIDC trust failures)

### How Class 1 and Class 2 Connect

| Class 1 | Class 2 |
|---|---|
| Real CI gate on a Flask app | Real CD: publish to AWS via OIDC |
| lint → test → build → security scan | OIDC → S3 publish → gated `production` |
| Branch protection enforces the gate | Environment reviewer enforces the deploy |
| SHA-tagged build artifact | Same artifact, published with provenance to S3 |
| Troubleshot import/test failures | Troubleshot OIDC trust-policy failures |

### How This Week Prepares Students for the Next Week

Week 10 covers **Docker and Container Fundamentals**.

This CI/CD week prepares students because next week's pipeline reuses the *same* Flask app and pipeline, but the artifact becomes a container image:

- Build Docker images (multi-stage, distroless/non-root)
- Tag images with the commit SHA (same provenance idea)
- Push images to Amazon ECR via the same OIDC role pattern
- Deploy with the strategies (rolling/blue-green/canary) diagrammed this week

### What Students Should Review Before the Next Module

Students should review:

- Git branches and commits (Week 3)
- The CI gate stages and what each catches
- How OIDC role assumption works
- Why artifacts carry a commit SHA
- The three deployment strategies and their rollback behavior
- Why a container image is just another build artifact in modern delivery

---

## Class Artifacts & Validation

All paths are relative to the repo root. This class builds the **CD half**: the
keyless OIDC deploy `cd.yml` (`id-token: write` + `configure-aws-credentials` with
`role-to-assume`, no static keys), the `production` environment + reviewer gate, and
the GitLab `rules:`-based mirror for a platform comparison. Static gates below were run
in this environment; the **deploy itself is DEFERRED** (see note).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/cicd-pipelines/solution/.github/workflows/cd.yml | CI/CD (GitHub Actions) | Deploy on `v*` tags via **OIDC** → ECR → gated `production` environment; no `aws-access-key-id` | `actionlint solution/.github/workflows/cd.yml` | PASS (actionlint 1.7.3, 0 errors) |
| 2 | labs/cicd-pipelines/solution/.github/workflows/cd.yml | CI/CD invariants | Workflow unit tests assert `id-token: write`, `role-to-assume` present, and **no static key inputs** (`TestCdOidc`) | `python3 -m unittest discover -s tests` | PASS (24 tests) |
| 3 | labs/cicd-pipelines/solution/.github/workflows/cd.yml | Job graph | Deploy job `needs:` resolve; DAG acyclic | `python3 tests/check_job_graph.py solution/.github/workflows/cd.yml` | PASS |
| 4 | labs/cicd-pipelines/solution/.gitlab-ci.yml | CI/CD (GitLab) | GitLab mirror with `rules:` (not legacy `only:`) and `allow_failure: false` hard gate — the platform-comparison artifact | `yamllint -c .yamllint.yml solution/.gitlab-ci.yml` | PASS (yamllint 1.38.0, 0 errors) |
| 5 | labs/cicd-pipelines/solution/.gitlab-ci.yml | YAML well-formed | GitLab pipeline parses | `python3 -c "import yaml; list(yaml.safe_load_all(open('solution/.gitlab-ci.yml')))"` | PASS |
| 6 | labs/cicd-pipelines/validate.sh | Shell automation | One command that runs every local gate (incl. the OIDC/no-keys invariants) | `./validate.sh` | PASS (31 passed, 0 failed) |
| 7 | labs/cicd-pipelines/README.md | Docs / answer key | OIDC trust-policy, `production` environment, ECR/S3 cleanup, cost & security notes, grading key | reviewed; cross-refs verified | PASS |

**Live operations that are DEFERRED (documented, not run here — no live-evidence file exists for this week):**
the real OIDC `sts:AssumeRoleWithWebIdentity` against an AWS account, the actual
artifact publish (the class demo targets **S3**; the lab `cd.yml` targets **ECR/ECS**),
the human-approval gate on a live `production` environment, and `glab ci lint` against a
real GitLab project. The exact one-time AWS setup and the run/approve/verify steps are
in §13 here and in `labs/cicd-pipelines/README.md`. The deploy pipeline is
**static-validated and OIDC-correct on disk**, but it has **not** been executed against
a live cloud account in this environment.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — `cd.yml` (GitHub Actions OIDC deploy) and `.gitlab-ci.yml` (GitLab mirror) exist as real files.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `actionlint` (cd.yml), `yamllint` (.gitlab-ci.yml), the `TestCdOidc` no-keys invariant, the job-graph check, and YAML parse all PASS (see table + `./validate.sh`: 31 passed, 0 failed).
- [x] Lab has **starter** (OIDC perms + `configure-aws-credentials` are TODO) and **solution** (reference) versions — `labs/cicd-pipelines/starter/.github/workflows/cd.yml` and `labs/cicd-pipelines/solution/...`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — `labs/cicd-pipelines/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — README "Cleanup" covers deleting the ECR images, scaling/deleting ECS, and removing the OIDC role; the demo's S3 bucket teardown is in §13.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — README "Instructor answer key" + §16/§17 here.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the OIDC trust-policy failure drill (§15) plus the shared `broken/ci-bad-needs.yml` graph fixture; the gate is proven to reject the fixture.
- [x] **Expected outputs** are shown for demos and labs — README "Expected results"; §14 "Expected Outputs" here.
- [x] **Cost & security warnings** present — README + §7 "Security Warning"; OIDC = no long-lived keys; cost note flags the running ECS/Fargate task as the real charge ($0 if AWS side not applied).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/cicd-pipelines/`; builds on Class 1 (`ci.yml`), feeds Week 10 (ECR push via same OIDC role) and the capstone.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`/gate runs above.
- [ ] **Mastered / live-operated** — the OIDC assume-role, the live artifact publish, and the production approval gate are NOT yet exercised against a real AWS account (no live-evidence file). Capped accordingly in the score.
