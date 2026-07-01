# Week 15: Terraform Enterprise Workflows  
> **▶ Runnable lab for this class:** [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package: Remote State, Drift, and Terraform in CI/CD

**Week:** 15
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

## 1. Class Overview

### Class Title

**Class 2: Safe Terraform Delivery with Remote State, Drift Detection, and CI/CD**

### Class Purpose

This class teaches students how Terraform is safely used in real teams after the repository structure has been created. In Class 1, students built the foundation: modules, environment folders, and `tfvars`. In Class 2, students learn the safety controls around that structure:

- Remote state
- State locking
- Plan review
- Drift detection
- Git-based approvals
- CI/CD pipeline integration

The goal is to help students understand that enterprise Terraform is not just about writing infrastructure code. It is about safely changing shared infrastructure without breaking environments, overwriting state, or bypassing review.

### How This Class Builds From Class 1

Class 1 focused on organizing Terraform:

```text
modules/
environments/dev/
environments/prod/
terraform.tfvars
```

Class 2 adds the operational workflow around that structure:

```text
remote state
state locking
terraform plan review
drift detection
pipeline validation
manual approval for production
```

Class 1 answered:

> How should Terraform code be organized?

Class 2 answers:

> How should Terraform changes be delivered safely by a team?

### What Students Will Build, Analyze, or Practice

Students will:

- Add sample backend configuration for dev and prod.
- Explain S3 remote state and **native S3 state locking** (`use_lockfile`); recognize DynamoDB locking as the legacy approach.
- Create a safe Terraform workflow document.
- Build a simple CI/CD pipeline design for Terraform.
- Analyze Terraform drift caused by manual AWS Console changes.
- Write a drift response process.
- Compare AWS remote state with Azure and GCP remote state options.

---

## 2. Quick Review of Class 1

### Review Points

1. Terraform code should be stored in Git for version control and review.
2. `modules/` contains reusable infrastructure building blocks.
3. `environments/` contains deployable environment-specific configuration.
4. Dev and prod can use the same module but pass different input values.
5. `terraform.tfvars` stores environment-specific values such as CIDR, tags, and region.
6. Production should have stricter review than dev.
7. Copying dev values into prod can create real architecture problems.
8. `terraform validate` checks syntax and configuration validity, but not business safety.

### Quick Recall Questions

1. What is the difference between a reusable module and an environment folder?
2. Why should dev and prod have separate `terraform.tfvars` files?
3. Why is it risky to apply Terraform changes directly from a laptop?

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students confuse module files with environment files | Re-draw the folder tree and repeat: modules are reusable, environments are executable |
| Students think `terraform validate` means the design is safe | Explain that validation checks syntax, not architecture approval |
| Students do not understand why prod needs stricter controls | Use business impact examples such as outage, public exposure, or wrong CIDR |
| Students may not understand state yet | Tell them Class 2 explains why Terraform must remember what it created |
| Students think CI/CD is only for application code | Explain that infrastructure code also needs automated checks and approvals |

### Bridge Into Class 2

Use this transition:

> In Class 1, we organized Terraform code so teams can reuse modules and separate environments. But structure alone is not enough. Today we add safety. We will look at where Terraform state lives, how teams avoid two people changing the same infrastructure at the same time, how drift happens, and how CI/CD pipelines help enforce review before changes reach production.

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** what Terraform state is and why it must be protected.
2. **Configure** example remote backend files for dev and prod using AWS S3 backend concepts.
3. **Describe** how **native S3 state locking** (`use_lockfile`) prevents simultaneous Terraform changes (DynamoDB locking is the legacy mechanism).
4. **Analyze** Terraform plan output to identify creates, updates, deletes, and replacements.
5. **Troubleshoot** drift caused by manual infrastructure changes outside Terraform.
6. **Build** a simple Terraform CI/CD workflow with `fmt`, `validate`, `plan`, and manual `apply`.
7. **Compare** AWS, Azure, and GCP remote state storage options.
8. **Document** a safe enterprise Terraform change process.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should already understand:

- Terraform repository structure
- Difference between `modules/` and `environments/`
- Root module concept
- Environment-specific `terraform.tfvars`
- Dev/prod separation
- Git-based review concept
- Basic Terraform commands

### Required Prior Concepts

Students should already understand:

- Basic AWS account and region concepts
- Basic IAM permission concepts
- Basic S3 concept
- Basic Git workflow
- Basic YAML syntax
- Basic CI/CD stages
- Basic terminal navigation

### Required Tools Already Installed

Students should have:

- Terraform
- Git
- VS Code
- AWS CLI
- Terminal or shell
- Optional GitLab or GitHub account

### Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should use the Class 1 repo:

```text
terraform-enterprise-workflow/
├── modules/
│   └── vpc/
├── environments/
│   ├── dev/
│   └── prod/
└── README.md
```

If students do not have the repo from Class 1, the instructor should provide a starter copy.

Important note:

Students do **not** need to create real AWS resources for the main version of this class. Backend files can be created as examples. Live backend creation can be optional for advanced students or instructor demo only.

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Terraform State | A file that records what Terraform believes it manages | Terraform uses state to map code resources to real AWS resources |
| Local State | State stored on one person’s machine | Risky for teams because others cannot safely share it |
| Remote State | State stored in a shared backend such as S3 | Enterprise teams use remote state so pipelines and engineers share the same source of truth |
| State Locking | A protection that prevents two Terraform operations from modifying state at the same time | Prevents two engineers or pipelines from applying changes simultaneously |
| Backend | Terraform configuration that defines where state is stored | AWS teams often use S3 as the backend |
| S3 Backend | Terraform backend that stores state files in an S3 bucket | Common AWS enterprise remote state pattern |
| S3 Native State Locking | `use_lockfile` (Terraform >= 1.10) takes an S3 lock object via conditional writes — no DynamoDB table needed | Prevents state corruption / conflicting applies; DynamoDB locking is the legacy pattern |
| Terraform Plan | A preview of what Terraform will create, update, delete, or replace | Teams review plans before approving infrastructure changes |
| Drift | A difference between Terraform code/state and real infrastructure | Often caused by manual console changes |
| Manual Console Change | A change made directly in AWS Console instead of Terraform | Can create drift and bypass review |
| CI/CD Pipeline | Automated workflow that runs checks and deployment steps | Terraform pipelines run `fmt`, `validate`, `plan`, and sometimes `apply` |
| Manual Approval | A required human approval before a risky action | Common for production Terraform applies |
| Protected Branch | A branch with restrictions on who can merge or deploy from it | Used to protect production infrastructure workflows |
| Change Control | A process for reviewing and approving changes before production impact | Important in regulated or enterprise environments |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Terraform | Main tool for infrastructure as code workflow |
| Git | Tracks infrastructure changes and supports review |
| VS Code | Used to edit Terraform, YAML, and documentation files |
| Terminal | Used to run commands and inspect folders |
| AWS CLI | Used to validate identity and optionally inspect AWS resources |
| GitLab CI or GitHub Actions | Used to model safe Terraform automation |
| YAML | Used to define CI/CD pipeline configuration |
| AWS Console | Optional for showing S3 and DynamoDB backend concepts |
| Markdown | Used to document the enterprise Terraform change process |

---

## 7. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon S3 | Used as the primary example for storing Terraform remote state |
| S3 native locking (`use_lockfile`) | Primary, modern Terraform state-locking mechanism (Terraform >= 1.10); DynamoDB is the legacy option |
| AWS IAM | Controls who or what can read state, write state, and apply infrastructure changes |
| AWS STS | Commonly used by CI/CD pipelines to assume roles securely |
| Amazon VPC | Example infrastructure managed by Terraform from Class 1 |
| AWS CloudTrail | Useful for investigating manual console changes that caused drift |
| AWS KMS | Can encrypt S3 state bucket contents in enterprise environments |

### Cost and Security Warning

- S3 and DynamoDB can create small costs if students create real resources.
- Terraform state can contain sensitive values, depending on resources used.
- Never commit `.tfstate` files to Git.
- Never store secrets directly in Terraform code or `tfvars`.
- Production state buckets should be encrypted, access-controlled, versioned, and protected.

---

## 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Remote State Storage | S3 bucket | Azure Storage Account blob container | Google Cloud Storage bucket |
| Locking | S3 native lock (`use_lockfile`); DynamoDB legacy | Azure Blob lease locking | Backend/workflow locking behavior |
| Identity for Pipeline | IAM role, OIDC, STS | Managed identity, service principal, OIDC | Service account, workload identity federation |
| Audit | CloudTrail | Azure Activity Log | Cloud Audit Logs |

Instructor talking point:

> The Terraform workflow is similar across clouds. The backend service and authentication method change, but the principles stay the same: protect state, review plans, avoid manual drift, and require approval for risky changes.

---

## 9. Time-Boxed Instructor Agenda

| Time | Segment | Format |
|---:|---|---|
| 0:00 to 0:15 | Quick review of Class 1 repo structure | Guided review |
| 0:15 to 0:40 | Terraform state, local state, and remote state | Lecture with examples |
| 0:40 to 1:05 | S3 backend and native S3 locking (`use_lockfile`); DynamoDB legacy | Whiteboard |
| 1:05 to 1:25 | Terraform plan review and production approval workflow | Instructor-led walkthrough |
| 1:25 to 1:35 | Break | Break |
| 1:35 to 2:00 | Drift detection and manual console change risks | Lecture and scenario |
| 2:00 to 2:25 | Instructor demo: backend examples, plan review, drift concept | Live demo |
| 2:25 to 2:50 | Student lab: safe Terraform workflow design | Hands-on |
| 2:50 to 3:00 | Troubleshooting activity, discussion, recap | Group review |

---

## 10. Instructor Lesson Plan

### Step 1: Start With Class 1 Continuity

Open with:

> Last class, we created a structure that separates reusable modules from environment-specific configuration. Today, we are going to protect that structure with remote state, locking, review, drift detection, and CI/CD automation.

Show the Class 1 structure:

```text
terraform-enterprise-workflow/
├── modules/
│   └── vpc/
└── environments/
    ├── dev/
    └── prod/
```

Ask:

> If two engineers both run Terraform against prod at the same time, what could go wrong?

Expected responses:

- Conflicting changes
- State corruption
- Unexpected overwrites
- Production outage
- Hard to know whose change won

Transition:

> That is why state and locking matter.

### Step 2: Explain Terraform State

Explain:

> Terraform state is Terraform’s memory. It remembers what Terraform created and how that code maps to real cloud resources.

Use example:

```text
Terraform code:
aws_vpc.main

Terraform state:
aws_vpc.main = vpc-0abc123example
```

Emphasize:

- State is required for Terraform to know what exists.
- State should not be edited manually.
- State can contain sensitive values.
- Local state is not safe for teams.
- Remote state is the enterprise pattern.

Pause for questions:

> Why would storing state only on one engineer’s laptop be risky?

### Step 3: Explain Remote State

Show the AWS backend pattern:

```text
Terraform CLI or pipeline
        |
        v
S3 bucket stores terraform.tfstate
        |
        v
DynamoDB table locks state during apply
```

Explain:

> Remote state gives the team one shared state file. State locking helps prevent two applies at the same time.

Important beginner explanation:

- S3 stores the state file.
- DynamoDB stores the lock record.
- IAM controls access.
- KMS can encrypt state.
- Versioning helps recover from state mistakes.

### Step 4: Explain Plan Review

Show plan symbols:

```text
+ create
~ update
- destroy
-/+ replace
```

Explain:

> `terraform plan` is not just a technical output. It is a review document. In enterprise teams, engineers review the plan before approving a change.

Ask:

> Which symbol should make you slow down the most?

Expected answer:

- `- destroy`
- `-/+ replace`

Teaching tip:

Students often assume every plan is safe. Reinforce that plans must be reviewed with context.

### Step 5: Explain Drift

Explain:

> Drift happens when real infrastructure changes outside Terraform.

Give example:

- Terraform code says security group allows port 80.
- Someone changes it in AWS Console to port 443.
- Terraform plan now detects a difference.

Say:

> Drift is not always bad, but it must be investigated. Sometimes it is an emergency fix. Sometimes it is an unauthorized change.

### Step 6: Connect Drift to Git and CI/CD

Explain:

> Git stores the intended infrastructure design. Terraform state stores what Terraform last knew. The cloud provider has the actual infrastructure. Drift is when these no longer line up.

Draw:

```text
Git code          Terraform state          AWS actual resource
   |                    |                         |
 desired           last known                  real
```

### Step 7: Introduce CI/CD Workflow

Show stages:

```text
fmt -> validate -> plan -> review -> approve -> apply
```

Explain:

- `fmt` enforces formatting.
- `validate` checks configuration.
- `plan` previews changes.
- Review catches risk.
- Manual approval protects production.
- Apply should be controlled.

Transition:

> Now let’s demo how these pieces look in files and workflow.

---

## 11. Instructor Lecture Notes

### Concept 1: Terraform State Is Terraform’s Memory

Terraform state is one of the most important concepts in Terraform.

Say:

> Terraform does not just read your `.tf` files and magically know everything in AWS. It also needs state. State tells Terraform what it already created.

Example:

If Terraform created a VPC, it stores the mapping:

```text
aws_vpc.main -> vpc-0123456789abcdef0
```

Without state, Terraform may not know that the VPC already exists.

Common misconception:

> “If the code exists, Terraform knows what exists.”

Correction:

> Terraform uses both code and state. Code describes what should exist. State records what Terraform currently knows about what exists.

### Concept 2: Local State Is Fine for Learning, But Risky for Teams

Local state is often created as:

```text
terraform.tfstate
```

This may be okay in a beginner lab, but it is risky in enterprise teams.

Risks:

- Only one person has the state file.
- State can be lost if the laptop is lost.
- State can accidentally be committed to Git.
- Other engineers cannot safely collaborate.
- Pipelines cannot share the same state.
- State may contain sensitive data.

Talking point:

> Local state is like keeping the company’s building blueprint on one person’s laptop. Remote state puts the blueprint in a controlled shared location.

### Concept 3: S3 Backend and State Locking

> **⚠️ 2025+ update — teach this first.** The S3 backend now does state locking **natively**
> with `use_lockfile = true` (Terraform >= 1.10 / OpenTofu >= 1.10): it writes a lock object
> in the **same S3 bucket** using conditional writes, so a **separate DynamoDB table is no
> longer required** — the old `dynamodb_table` lock argument is **legacy/deprecated**. Modern
> backend config:
> ```hcl
> terraform {
>   backend "s3" {
>     bucket       = "my-tfstate"
>     key          = "env/terraform.tfstate"
>     region       = "us-east-1"
>     encrypt      = true
>     use_lockfile = true   # native S3 lock — no DynamoDB needed
>   }
> }
> ```
> The DynamoDB walkthrough below is kept for context (you'll still see it in older codebases),
> but lead with `use_lockfile` for any new project.

The classic (now legacy) AWS pattern, for context:

```text
S3 bucket = stores state  (modern: also stores the native lock object via use_lockfile)
DynamoDB table = stores lock  (LEGACY — replaced by use_lockfile)
IAM role = controls access
KMS = encrypts state
```

Talking point:

> Modern Terraform: S3 holds the state **and** the native lock (`use_lockfile`). In older
> repos you'll see a DynamoDB table doing the locking — same goal, now built into S3.

Important enterprise notes:

- Enable S3 versioning.
- Enable encryption.
- Restrict bucket access.
- Use separate state paths per app and environment.
- Do not allow broad human access to prod state.
- Use IAM roles for CI/CD pipelines.

### Concept 4: Why State Locking Matters

Without locking:

```text
Engineer A starts terraform apply
Engineer B starts terraform apply
Both try to update the same state
Result: conflict, corruption, or unpredictable infrastructure
```

With locking:

```text
Engineer A starts apply
Terraform creates lock
Engineer B tries apply
Terraform says state is locked
Engineer B waits or investigates
```

Talking point:

> Locking does not prevent all bad changes, but it prevents simultaneous state writes.

### Concept 5: Terraform Plan Review

A plan tells the team what Terraform wants to do.

Plan symbols:

```text
+ create
~ update
- destroy
-/+ replace
```

Instructor talking point:

> A Terraform plan is like a change request written by Terraform. The team still needs to decide whether the change is expected, safe, and approved.

Questions reviewers should ask:

1. Is anything being destroyed?
2. Is anything being replaced?
3. Are IAM permissions changing?
4. Are network rules changing?
5. Are production resources affected?
6. Are tags correct?
7. Is this the right environment?
8. Does this match the ticket or request?

### Concept 6: Drift Detection

Drift is common in real environments.

Drift can happen because:

- Emergency console changes
- Manual fixes
- Unapproved changes
- Other tools modifying infrastructure
- Cloud provider defaults changing
- Imported resources not fully represented in code

Talking point:

> Drift is not just a Terraform problem. Drift is an operations problem. It tells us the real world no longer matches our documented intent.

Drift response should not be automatic for beginners.

Recommended process:

1. Run `terraform plan`.
2. Identify unexpected changes.
3. Confirm if manual change occurred.
4. Check change ticket or incident history.
5. Decide whether code should be updated or manual change reverted.
6. Apply only after approval.
7. Document the drift.

### Concept 7: CI/CD for Terraform

CI/CD for Terraform helps standardize safe behavior.

Basic pipeline:

```text
terraform fmt
terraform validate
terraform plan
manual approval
terraform apply
```

Enterprise pipeline may also include:

- Static analysis
- Security scanning
- Cost estimation
- Policy-as-code
- Environment approvals
- OIDC-based cloud authentication
- Separate credentials per environment

Talking point:

> The pipeline should make the safe path the easy path.

### Concept 8: The Plan-Artifact Handoff (the crux of safe Terraform CI)

The single most important pattern in Terraform CI is **separating plan from apply with a saved artifact**:

```bash
terraform plan -out=tfplan          # compute and SAVE the plan
terraform show -no-color tfplan     # render it for a human reviewer
# ... human reviews and approves ...
terraform apply tfplan              # apply the SAVED plan, byte-for-byte
```

Why it matters:

- `apply tfplan` does **not** recompute the plan. It applies exactly what was reviewed. If state or inputs changed since the plan, `apply tfplan` errors out (stale plan) instead of silently doing something new.
- Contrast with `terraform apply -auto-approve` (no saved plan): it computes a *fresh* plan at apply time and applies it unattended. The reviewed plan and the applied plan can differ. This is the defect in the unsafe pipeline.

Evidence-first framing (course methodology):

> The saved `tfplan` is your **evidence**. The review is the **root-cause check** ("does this change match the ticket?"). `apply tfplan` is the **fix**. A follow-up `plan` showing "No changes" is the **validation**. Render/plan before apply — always.

### Concept 9: OIDC Keyless Auth from CI to AWS (the 2026 default)

Static AWS access keys stored as CI variables are a flagged anti-pattern: they are long-lived, leak easily, and are hard to rotate. The modern pattern is **OIDC short-lived role assumption** — the CI provider (GitHub Actions, GitLab) presents a signed JWT, and an AWS IAM role trusts that issuer and mints temporary credentials per run.

The AWS side is an IAM role with a trust policy on the CI provider's OIDC identity provider. Example for GitHub Actions:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::111122223333:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:my-org/my-repo:ref:refs/heads/main"
      }
    }
  }]
}
```

The `sub` condition is the security boundary: only workflows from `my-org/my-repo` on `main` can assume the role. The GitHub Actions side then needs only:

```yaml
permissions:
  id-token: write   # allow the workflow to request the OIDC token
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::111122223333:role/terraform-ci
      aws-region: us-east-1
  # No aws-access-key-id / aws-secret-access-key anywhere.
```

Talking point:

> If you ever see `AWS_SECRET_ACCESS_KEY` in CI variables for Terraform in 2026, that is a finding. Short-lived OIDC creds are the expectation; static keys are the exception that needs justification.

### Concept 10: Policy-as-Code — Catching Bad Infra Before It Ships

`terraform validate` checks syntax; it does **not** check security or policy. Policy-as-code tools scan the config (or the plan) and fail the pipeline on violations. The common 2026 stack:

- **`tfsec` / `Checkov` / `Trivy`** — opinionated scanners with hundreds of built-in rules (unencrypted S3, public security groups, open `0.0.0.0/0` ingress, missing logging). Drop-in, no rules to write.
- **OPA / Conftest** — write *your own* org policies in Rego against the JSON plan.
- **Sentinel** — HashiCorp's policy engine in Terraform Cloud/Enterprise.

A Conftest/OPA example — "deny any S3 bucket without encryption" — run against the plan:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
conftest test plan.json --policy policy/
```

```rego
# policy/s3_encryption.rego
package main

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration
  msg := sprintf("S3 bucket %s must have encryption enabled", [resource.address])
}
```

Talking point:

> A scanner like `tfsec` is your zero-config baseline; OPA/Conftest is for *your* rules ("every bucket encrypted, every resource tagged with a cost center"). Run them in the `scan` stage **before** `plan` is approved, so a violation blocks the merge — not a 2am page.

### Concept 11: Automated Testing — Native `terraform test`

Since Terraform 1.6 (and in OpenTofu), there is a built-in test framework using `.tftest.hcl` files. It runs `plan` or `apply` against your module and asserts on outputs/attributes — no Go, unlike terratest.

```hcl
# tests/vpc.tftest.hcl  — run with: terraform test
run "vpc_uses_correct_cidr" {
  command = plan

  variables {
    environment = "test"
    vpc_cidr    = "10.99.0.0/16"
    tags        = { Environment = "test" }
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.99.0.0/16"
    error_message = "VPC CIDR did not match the input variable"
  }
}
```

```bash
terraform test          # runs every *.tftest.hcl in tests/
```

Talking point:

> `command = plan` tests are cheap and create nothing — perfect for CI. `command = apply` tests create real resources and tear them down, so gate those behind a dedicated test account. **terratest** (Go) is the heavier alternative for integration testing across modules; native `terraform test` covers most module-level needs.

### Concept 12: `terraform force-unlock` — Mechanics and When It Is Safe

State locking (Concept 4) can leave a *stale* lock if an apply is killed mid-run (CI runner crashed, laptop slept). Terraform then refuses to run and prints a **lock ID**:

```text
Error: Error acquiring the state lock
Lock Info:
  ID:        a1b2c3d4-...
  Who:       ci-runner@host
  Created:   2026-06-30 14:02:11 UTC
```

To clear it:

```bash
terraform force-unlock a1b2c3d4-...
```

When it is safe — and the discipline (evidence-first):

> Only force-unlock after you have **confirmed no apply is still running**. Check the CI job status and the DynamoDB lock's `Who`/`Created` fields. If another apply is genuinely in flight, force-unlocking lets a second apply corrupt the state — the exact thing locking prevents. Evidence first: prove the lock is stale before you break it.

### Concept 13: Managed TACOS — You Don't Have to Hand-Roll This

Most shops in 2026 do not maintain a bespoke GitLab/Actions Terraform pipeline by hand. They use a **TACOS** (Terraform/OpenTofu Automation and Collaboration Software) platform that productizes plan/apply-in-PR:

- **Terraform Cloud / HCP Terraform** (HashiCorp), **Spacelift**, **env0**, **Atlantis** (open-source, self-hosted).

They give you remote state, plan-in-PR comments, policy enforcement (OPA/Sentinel), drift detection, and approval gates out of the box.

Talking point:

> The hand-built pipeline we wrote teaches you *what* a TACOS does under the hood. On the job you will often configure Atlantis or HCP Terraform instead of writing this YAML — but you must understand the plan-artifact and OIDC mechanics to operate them safely.

---

## 12. Whiteboard Explanation

### Simple Diagram: Extending Class 1

Class 1 structure:

```text
Git Repo
├── modules/
└── environments/
    ├── dev/
    └── prod/
```

Class 2 adds safety:

```text
Git Repo
├── modules/
└── environments/
    ├── dev/
    │   └── backend.tf  ---> S3 state path for dev
    └── prod/
        └── backend.tf  ---> S3 state path for prod

CI/CD Pipeline
    |
    v
fmt -> validate -> plan -> approval -> apply
                            |
                            v
                      Plan review by team

Remote State
    |
    v
S3 bucket stores state
DynamoDB table locks state
```

### Step-by-Step Flow

1. Engineer creates a branch.
2. Engineer changes Terraform code.
3. CI pipeline runs `terraform fmt`.
4. CI pipeline runs `terraform validate`.
5. CI pipeline runs `terraform plan`.
6. Team reviews plan output.
7. Production apply requires manual approval.
8. Terraform uses remote state in S3.
9. DynamoDB lock prevents simultaneous apply.
10. State is updated after apply.

### What Each Component Means

| Component | Meaning |
|---|---|
| Git Repo | Stores Terraform code and review history |
| `backend.tf` | Tells Terraform where state should live |
| S3 State Bucket | Stores Terraform state remotely |
| DynamoDB Lock Table | Prevents simultaneous writes to state |
| Pipeline | Runs checks consistently |
| Plan Review | Human review of intended infrastructure changes |
| Manual Approval | Safety gate before production apply |
| Drift Detection | Process to find real infrastructure changes outside Terraform |

### Enterprise Version

```text
Developer Branch
      |
      v
Merge Request
      |
      v
Pipeline:
  terraform fmt
  terraform validate
  security scan
  terraform plan
      |
      v
Plan reviewed by:
  DevOps Engineer
  Cloud Engineer
  Security reviewer for IAM/network changes
      |
      v
Approved merge to main
      |
      v
Manual production apply
      |
      v
Remote state stored in encrypted S3
      |
      v
CloudTrail, tickets, and Git history provide audit trail
```

### How Class 2 Extends Class 1

Class 1 gave students a clean repo. Class 2 teaches how to operate that repo safely in a team setting.

---

## 13. Instructor Demo Script

### Demo Title

**Remote State Concepts, Plan Review, and Simulated Drift**

### Demo Objective

Show how backend configuration, plan review, drift detection, and CI/CD workflow fit into an enterprise Terraform delivery process.

### Required Setup

Instructor should have:

- Class 1 repo or starter repo
- Terraform installed
- Git installed
- VS Code installed
- Optional AWS CLI configured

Check tools:

```bash
terraform version
git --version
aws --version
```

Expected output:

```text
Terraform v1.x.x
git version 2.x.x
aws-cli/2.x.x
```

### Important Demo Safety Note

For the standard classroom demo, do **not** create real backend resources unless already prepared.

Use:

- `backend.tf.example`
- `terraform init -backend=false`
- Plan examples
- Drift scenario as a controlled text simulation

This keeps the demo safe, fast, and low-cost.

### Step 1: Open the Class 1 Repo

```bash
cd terraform-enterprise-workflow
code .
```

Explain:

> This is the repo structure we created in Class 1. Now we will add enterprise safety concepts.

### Step 2: Create Backend Example for Dev

Create:

```text
environments/dev/backend.tf.example
```

Add:

```hcl
terraform {
  backend "s3" {
    bucket         = "example-company-terraform-state-dev"
    key            = "sample-app/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-company-terraform-locks"
    encrypt        = true
  }
}
```

Explain each line:

| Setting | Meaning |
|---|---|
| `bucket` | S3 bucket where state will be stored |
| `key` | Path to the state file inside the bucket |
| `region` | AWS Region where the backend bucket exists |
| `dynamodb_table` | DynamoDB table used for locking |
| `encrypt` | Enables encryption at rest |

Instructor note:

> This file is named `.example` so students do not accidentally initialize against a backend that does not exist.

### Step 3: Create Backend Example for Prod

Create:

```text
environments/prod/backend.tf.example
```

Add:

```hcl
terraform {
  backend "s3" {
    bucket         = "example-company-terraform-state-prod"
    key            = "sample-app/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-company-terraform-locks"
    encrypt        = true
  }
}
```

Explain:

> Notice dev and prod use different state paths or buckets. Production state should be protected more strictly.

Locking note (2026):

> The classic pattern adds `dynamodb_table` for locking. As of Terraform 1.10 / OpenTofu, the S3 backend also supports a **native S3 lock file** via `use_lockfile = true`, which can replace the DynamoDB table entirely. For this course we show DynamoDB (still the most common in existing repos) and mention `use_lockfile` as the newer, simpler option.

### Step 3b: Bootstrap the Backend (the chicken-and-egg, optional live demo)

Students always ask: *"If Terraform stores state in S3, who creates the S3 bucket — and where is **its** state?"* This is the bootstrap problem. The standard answer: create the backend resources **once** with a tiny, separately-managed config (often with local state, applied by a platform admin), then every other config uses them as a remote backend.

If you choose to run this live (incurs trivial cost — clean up after), bootstrap with the AWS CLI rather than Terraform to keep it simple:

```bash
# 1) State bucket (versioned + encrypted)
aws s3api create-bucket \
  --bucket example-company-terraform-state-dev \
  --region us-east-1
aws s3api put-bucket-versioning \
  --bucket example-company-terraform-state-dev \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption \
  --bucket example-company-terraform-state-dev \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'
aws s3api put-public-access-block \
  --bucket example-company-terraform-state-dev \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# 2) Lock table (PAY_PER_REQUEST so there is no idle cost)
aws dynamodb create-table \
  --table-name example-company-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

The DynamoDB **partition key must be exactly `LockID`** (string) — the S3 backend hard-codes that name.

> Cost/security warning: an empty S3 bucket and a PAY_PER_REQUEST DynamoDB table cost effectively nothing at rest, but **do not leave them lying around** in a shared account. Cleanup is in the Cleanup Steps section. Never point a class lab at a real company state bucket.

### Step 3c: Initialize Against the REAL Backend (rename `.example` → `backend.tf`)

To actually use the backend (only if you bootstrapped it in 3b), rename the example file and init:

```bash
cd environments/dev
cp backend.tf.example backend.tf
terraform init        # NO -backend=false — this migrates to the S3 backend
```

Expected output:

```text
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Terraform has been successfully initialized!
```

Demonstrate locking live (optional, two terminals):

```bash
# Terminal 1: hold a lock by starting an apply and pausing at the prompt
terraform apply         # leave it sitting at "Enter a value:"

# Terminal 2: try to run simultaneously
terraform plan
# -> Error: Error acquiring the state lock ... ID: <lock-id> ... Who: ...
```

This is the concurrency story from the lecture, made real. Cancel Terminal 1 with Ctrl-C (answer `no`) to release the lock cleanly. If a lock is left stale, clear it with `terraform force-unlock <lock-id>` (see Concept 12).

### Step 4: Run Safe Init Without Backend

From dev environment:

```bash
cd environments/dev
terraform init -backend=false
```

Expected output:

```text
Terraform has been successfully initialized!
```

Explain:

> We are skipping backend initialization because this is a safe classroom demo. In a real environment, the S3 bucket and DynamoDB table must exist first.

### Step 5: Validate Configuration

```bash
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

Explain:

> Validate confirms the syntax and provider configuration are valid. It does not confirm that the remote backend exists, and it does not approve production safety.

### Step 6: Show Plan Review Symbols

Run plan only if AWS credentials are configured and the instructor is comfortable. Otherwise show sample output.

Command:

```bash
terraform plan
```

Possible expected plan snippet:

```text
Terraform will perform the following actions:

  # module.vpc.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + cidr_block = "10.10.0.0/16"
      + tags       = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

Explain:

> The most important line in a plan is often the summary: add, change, destroy. In production, every destroy or replacement must be reviewed carefully.

If AWS credentials are unavailable, show this as a sample output and do not run the command.

### Step 7: Simulate Drift

Show this scenario:

Terraform code says:

```hcl
vpc_cidr = "10.10.0.0/16"
```

Manual AWS Console change or external change results in actual infrastructure differing from code.

Example drift plan:

```text
~ resource "aws_security_group_rule" "app_ingress" {
      from_port = 80 -> 443
      to_port   = 80 -> 443
  }
```

Explain:

> Terraform plan is showing that the real resource does not match what Terraform expects. Now the team must decide whether to update the code or revert the manual change.

### Step 8: First, Show the UNSAFE Pipeline — and Why It Is Wrong

Before building the real pipeline, show students the pipeline they must **never** ship, so they can recognize it in code review:

```yaml
# ANTI-PATTERN — do not use. Shown for contrast only.
terraform_apply:
  stage: apply
  when: manual
  script:
    - cd environments/dev
    - terraform init -backend=false          # (1) no remote state!
    - terraform apply -auto-approve           # (2) applies a plan nobody reviewed
```

Walk through the two fatal flaws:

1. **`-backend=false`** means Terraform uses throwaway *local* state inside the CI runner. The runner is ephemeral, so after the job ends the state is gone — but the AWS resources it created still exist. You have just **orphaned real infrastructure** with no state to manage or destroy it.
2. **`apply -auto-approve` with no saved plan** re-runs `plan` implicitly at apply time. So *what was reviewed is not what gets applied* — if anything drifted or a variable changed between the review and the apply, the apply silently does something different.

Talking point:

> A pipeline that applies a plan nobody reviewed, against state that disappears when the job ends, is worse than no pipeline. The whole point of CI for Terraform is: **the reviewed plan is the applied plan, against durable shared state.**

### Step 9: Build the SAFE Pipeline (plan artifact → reviewed apply → real backend)

This is the deliverable. The key idea is the **plan-artifact handoff**: `plan -out=tfplan` saves the exact plan, CI stores it as an artifact, a human reviews it, and `apply tfplan` applies *that saved plan* — never a freshly computed one.

Create `.gitlab-ci.yml` at repo root:

```yaml
stages:
  - validate
  - scan
  - plan
  - apply

variables:
  TF_ROOT: "environments/dev"
  # No static AWS keys here — auth is via OIDC (see id_tokens below).

default:
  image: hashicorp/terraform:1.9   # OpenTofu users: ghcr.io/opentofu/opentofu

# GitLab issues a short-lived JWT the AWS role trusts (OIDC). No long-lived secrets.
.aws_oidc: &aws_oidc
  id_tokens:
    AWS_ID_TOKEN:
      aud: https://gitlab.com
  before_script:
    - >
      export $(aws sts assume-role-with-web-identity
      --role-arn "$AWS_TF_ROLE_ARN"
      --role-session-name "ci-$CI_PIPELINE_ID"
      --web-identity-token "$AWS_ID_TOKEN"
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text | awk '{print "AWS_ACCESS_KEY_ID="$1"\nAWS_SECRET_ACCESS_KEY="$2"\nAWS_SESSION_TOKEN="$3}')

fmt_validate:
  stage: validate
  script:
    - cd "$TF_ROOT"
    - terraform fmt -check -recursive
    - terraform init -input=false        # real remote backend (backend.tf present in CI)
    - terraform validate

security_scan:
  stage: scan
  image: aquasec/tfsec:latest
  script:
    - tfsec "$TF_ROOT" --minimum-severity HIGH
  # Swap for Checkov or Trivy if your org standardizes on those.

tf_plan:
  stage: plan
  <<: *aws_oidc
  script:
    - cd "$TF_ROOT"
    - terraform init -input=false
    - terraform plan -input=false -out=tfplan      # SAVE the exact plan
    - terraform show -no-color tfplan > tfplan.txt  # human-readable for the MR
  artifacts:
    paths:
      - $TF_ROOT/tfplan        # binary plan — the source of truth for apply
      - $TF_ROOT/tfplan.txt    # readable plan for reviewers
    expire_in: 1 day

tf_apply:
  stage: apply
  <<: *aws_oidc
  when: manual                 # human gate AFTER reviewing tfplan.txt
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'   # prod-style applies only from main
  script:
    - cd "$TF_ROOT"
    - terraform init -input=false
    - terraform apply -input=false tfplan  # apply the SAVED plan — not a fresh one
```

Explain each safety property:

| Property | How this pipeline gets it right |
|---|---|
| Reviewed plan == applied plan | `plan -out=tfplan` (artifact) then `apply tfplan` — no implicit re-plan |
| Durable shared state | `terraform init` uses the real S3 backend (`backend.tf` present in CI), not `-backend=false` |
| No long-lived secrets | OIDC `assume-role-with-web-identity` mints short-lived creds per run |
| Security gate | `tfsec` scan stage fails the pipeline on HIGH findings before any apply |
| Human gate | `when: manual` + branch rule means a person approves, and only from `main` |

Talking point:

> Notice the apply stage takes **no `-auto-approve`** — it does not need it, because `apply tfplan` applies a plan that was already approved. `-auto-approve` is only ever needed when you are applying *without* a saved plan, which is exactly what we are avoiding.

OpenTofu note:

> Everything above works identically with **OpenTofu** (the Linux-Foundation, MPL-licensed fork of Terraform created after the 2023 BSL license change). Swap the `terraform` binary for `tofu` and the image for `ghcr.io/opentofu/opentofu`. State, backend, plan-artifact, and OIDC all behave the same. Many orgs adopted OpenTofu specifically to keep an open-source license; a senior should know the fork exists and that `.tf` files are cross-compatible.

### Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `terraform init` fails | Backend bucket does not exist | Use `terraform init -backend=false` |
| `terraform plan` fails | AWS credentials missing | Use sample plan output instead |
| Provider download fails | Network issue | Continue using code walkthrough |
| YAML indentation error | Invalid `.gitlab-ci.yml` spacing | Use indentation as teaching moment |
| Students ask why apply is manual | Explain production approval and change control |
| State lock error shown in real backend | Another process holds lock | Explain lock behavior, do not force unlock unless instructor controls environment |

### Cleanup Steps

If no real resources were created:

```bash
rm -rf .terraform
rm -f .terraform.lock.hcl
```

If accidental AWS resources were created:

```bash
terraform destroy
```

Then verify in AWS Console.

If backend resources were created as an optional advanced demo, clean up only after ensuring state is not needed:

```bash
aws s3 rm s3://example-company-terraform-state-dev --recursive
aws s3 rb s3://example-company-terraform-state-dev
aws dynamodb delete-table --table-name example-company-terraform-locks
```

Instructor warning:

> Never delete a real state bucket in a real company unless you have explicit approval and backup.

---

## 14. Student Lab Manual

### Lab Title

**Design a Safe Terraform Delivery Workflow With Remote State, Plan Review, and Drift Response**

### Lab Objective

Extend the Class 1 Terraform repo by adding backend examples, a CI/CD workflow design, and a documented drift detection process.

### Estimated Time

35 to 45 minutes

### Student Prerequisites

You should already have:

- Class 1 repo structure
- Dev and prod environment folders
- VPC module
- Terraform installed
- Git installed
- VS Code installed

### Starting Point From Class 1

Use this repo:

```text
terraform-enterprise-workflow/
├── modules/
│   └── vpc/
├── environments/
│   ├── dev/
│   └── prod/
└── README.md
```

### Architecture or Workflow Overview

You will add:

```text
backend.tf.example files
pipeline example
drift detection process
change management documentation
```

Target workflow:

```text
Git change
   |
   v
terraform fmt
   |
   v
terraform validate
   |
   v
terraform plan
   |
   v
review and approval
   |
   v
terraform apply
   |
   v
remote state updated
```

### Step 1: Open Your Repo

```bash
cd terraform-enterprise-workflow
code .
```

### Step 2: Add Dev Backend Example

Create:

```text
environments/dev/backend.tf.example
```

Add:

```hcl
terraform {
  backend "s3" {
    bucket         = "example-company-terraform-state-dev"
    key            = "sample-app/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-company-terraform-locks"
    encrypt        = true
  }
}
```

### Step 3: Add Prod Backend Example

Create:

```text
environments/prod/backend.tf.example
```

Add:

```hcl
terraform {
  backend "s3" {
    bucket         = "example-company-terraform-state-prod"
    key            = "sample-app/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-company-terraform-locks"
    encrypt        = true
  }
}
```

Reflection:

- Why should dev and prod state be separated?
- Why should prod state have stricter access?

### Step 4: Add a Safe Terraform Workflow Section to README

Open:

```text
README.md
```

Add:

```markdown
## Terraform Change Workflow

1. Create a feature branch.
2. Update Terraform code.
3. Run terraform fmt.
4. Run terraform validate.
5. Run terraform plan.
6. Open a pull request or merge request.
7. Review the plan output.
8. Require approval for production changes.
9. Apply only after approval.
10. Document the change.
```

### Step 5: Add Drift Detection Process to README

Add:

```markdown
## Drift Detection Process

Drift happens when real infrastructure changes outside Terraform.

Recommended process:

1. Run terraform plan on a regular schedule.
2. Review unexpected changes.
3. Confirm whether the change was approved.
4. If the manual change is valid, update Terraform code.
5. If the manual change is not valid, revert it through Terraform.
6. Re-run terraform plan.
7. Document the drift event.
```

### Step 6: Add the SAFE Pipeline (plan artifact → reviewed apply)

Create `.gitlab-ci.yml` at repo root. This is the **safe** version — it saves the plan as an artifact and applies *that exact plan*, scans with `tfsec`, and uses OIDC (no static keys). It mirrors the demo:

```yaml
stages:
  - validate
  - scan
  - plan
  - apply

variables:
  TF_ROOT: "environments/dev"

default:
  image: hashicorp/terraform:1.9   # OpenTofu: ghcr.io/opentofu/opentofu

.aws_oidc: &aws_oidc
  id_tokens:
    AWS_ID_TOKEN:
      aud: https://gitlab.com
  before_script:
    - >
      export $(aws sts assume-role-with-web-identity
      --role-arn "$AWS_TF_ROLE_ARN"
      --role-session-name "ci-$CI_PIPELINE_ID"
      --web-identity-token "$AWS_ID_TOKEN"
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text | awk '{print "AWS_ACCESS_KEY_ID="$1"\nAWS_SECRET_ACCESS_KEY="$2"\nAWS_SESSION_TOKEN="$3}')

fmt_validate:
  stage: validate
  script:
    - cd "$TF_ROOT"
    - terraform fmt -check -recursive
    - terraform init -input=false
    - terraform validate

security_scan:
  stage: scan
  image: aquasec/tfsec:latest
  script:
    - tfsec "$TF_ROOT" --minimum-severity HIGH

tf_plan:
  stage: plan
  <<: *aws_oidc
  script:
    - cd "$TF_ROOT"
    - terraform init -input=false
    - terraform plan -input=false -out=tfplan
    - terraform show -no-color tfplan > tfplan.txt
  artifacts:
    paths:
      - $TF_ROOT/tfplan
      - $TF_ROOT/tfplan.txt
    expire_in: 1 day

tf_apply:
  stage: apply
  <<: *aws_oidc
  when: manual
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
  script:
    - cd "$TF_ROOT"
    - terraform init -input=false
    - terraform apply -input=false tfplan   # apply the SAVED, reviewed plan
```

Why this is safe (verify you understand each line):

- `plan -out=tfplan` + `apply tfplan` → the reviewed plan is the applied plan.
- `terraform init` (no `-backend=false`) → durable shared remote state.
- OIDC `assume-role-with-web-identity` → short-lived creds, **no `AWS_SECRET_ACCESS_KEY` in CI**.
- `tfsec` scan stage → blocks HIGH-severity findings before apply.
- `when: manual` + branch rule → a human approves, only from `main`.
- **No `-auto-approve`** anywhere — `apply tfplan` does not need it.

> Compare this to the anti-pattern (`apply -auto-approve` + `-backend=false`) from the demo. If you ever see that in a real MR, flag it: it applies an unreviewed plan against state that vanishes when the job ends.

### Step 7: Run Local Checks

From repo root:

```bash
terraform fmt -recursive
```

Expected output may be blank or list formatted files.

Validate dev:

```bash
cd environments/dev
terraform init -backend=false
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

Validate prod:

```bash
cd ../prod
terraform init -backend=false
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

### Step 7b: Scan With a Policy-as-Code Tool (`tfsec`)

Run a security scanner over your config locally — the same check the pipeline runs:

```bash
# from repo root; install once via: brew install tfsec   (or use the docker image)
tfsec environments/dev
```

`tfsec` may flag real issues even in this small repo (for example, the VPC has no flow logs). Read each finding and decide: fix it, or suppress with a documented `#tfsec:ignore:<rule>` and a reason. This is the policy-as-code habit: **machine-checked guardrails before human review.**

> If `tfsec` is not installed, run it via Docker: `docker run --rm -v "$PWD:/src" aquasec/tfsec /src/environments/dev`. Checkov (`checkov -d environments/dev`) and Trivy (`trivy config environments/dev`) are drop-in alternatives.

### Step 7c: Write One Native Terraform Test

Create a cheap, plan-only test that asserts the VPC uses the CIDR you pass in:

```text
environments/dev/tests/vpc.tftest.hcl
```

```hcl
run "vpc_uses_input_cidr" {
  command = plan

  variables {
    environment = "test"
    aws_region  = "us-east-1"
    vpc_cidr    = "10.99.0.0/16"
    tags        = { Environment = "test" }
  }

  assert {
    condition     = module.vpc.vpc_cidr == "10.99.0.0/16"
    error_message = "VPC CIDR did not match the input variable"
  }
}
```

Run it (plan-only, creates nothing):

```bash
cd environments/dev
terraform test
```

Expected output:

```text
tests/vpc.tftest.hcl... in progress
  run "vpc_uses_input_cidr"... pass
tests/vpc.tftest.hcl... teardown
Success! 1 passed, 0 failed.
```

> `command = plan` tests never touch AWS, so they are safe in any CI. Use `command = apply` tests only in a dedicated throwaway test account.

### Step 8: Create a Plan Review Checklist

In `README.md`, add:

```markdown
## Terraform Plan Review Checklist

Before approving a Terraform plan, check:

- Are any resources being destroyed?
- Are any resources being replaced?
- Is this the correct environment?
- Are IAM permissions changing?
- Are security group rules changing?
- Are network routes changing?
- Are tags correct?
- Does the plan match the requested change?
- Has production approval been provided?
```

### Step 9: Commit Your Changes

From repo root:

```bash
git status
git add .
git commit -m "Add safe Terraform workflow documentation"
```

Expected output:

```text
[main abc1234] Add safe Terraform workflow documentation
```

If Git identity is not configured:

```bash
git config user.name "Student Name"
git config user.email "student@example.com"
```

### Validation Checklist

Students should verify:

- `backend.tf.example` exists in dev.
- `backend.tf.example` exists in prod.
- README includes change workflow.
- README includes drift detection process.
- README includes plan review checklist.
- `.gitlab-ci.yml` exists and uses `plan -out=tfplan` + `apply tfplan` (NOT `apply -auto-approve`).
- The pipeline uses OIDC (no `AWS_SECRET_ACCESS_KEY` anywhere) and a `tfsec` scan stage.
- `tfsec` ran locally and findings were reviewed.
- `terraform test` passes.
- Terraform validation succeeds with `-backend=false`.
- Student can explain why `apply` is manual and why `apply tfplan` needs no `-auto-approve`.

### Troubleshooting Tips

| Problem | Fix |
|---|---|
| `terraform init` tries to use real backend | Use `terraform init -backend=false` |
| Backend bucket error | Backend resources are not created, use example file only |
| YAML error | Check indentation |
| Git commit fails | Configure Git username and email |
| Terraform validate fails | Check missing variables and module source path |
| Student accidentally creates `backend.tf` instead of example | Rename to `backend.tf.example` unless backend exists |

### Cleanup Steps

If no AWS resources were created:

```bash
rm -rf .terraform
```

Do not delete your repo if it will be used for homework.

If you accidentally created AWS resources, ask the instructor before deleting.

### Reflection Questions

1. Why is remote state safer than local state for teams?
2. What problem does state locking solve?
3. Why should Terraform plan be reviewed before apply?
4. Why should production apply be manual?
5. How should a team respond to drift?

### Optional Challenge Task

Add a GitHub Actions version of the safe pipeline:

```text
.github/workflows/terraform.yml
```

Use OIDC (no static keys) and the plan-artifact handoff. Skeleton:

```yaml
name: terraform
on: [pull_request, push]

permissions:
  id-token: write   # required for OIDC
  contents: read

jobs:
  plan:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: environments/dev
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::111122223333:role/terraform-ci
          aws-region: us-east-1
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check -recursive
      - run: terraform init -input=false
      - run: terraform validate
      - run: terraform plan -input=false -out=tfplan
      - uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: environments/dev/tfplan
```

Then add an `apply` job gated by a GitHub **Environment** with required reviewers that downloads the `tfplan` artifact and runs `terraform apply tfplan`. Document in the README:

- Why the GitHub Environment protection rule is the manual-approval gate.
- Why `id-token: write` is required (OIDC token issuance).
- Why the apply job applies the downloaded `tfplan` rather than re-planning.

---

## 15. Troubleshooting Activity

### Incident Title

**Unexpected Terraform Drift After Manual Security Group Change**

### Business Impact

A production application was manually updated during an incident to allow HTTPS traffic. The emergency change restored service, but Terraform now shows unexpected drift. The team must decide whether to update Terraform code or revert the manual change.

### Symptoms

- Terraform plan shows a change that no one expected in the code review.
- Security group rule differs from Terraform code.
- The application is currently working.
- The incident ticket mentions an emergency console change.

### Starting Evidence

Terraform plan output:

```text
~ resource "aws_security_group_rule" "app_ingress" {
      from_port = 80 -> 443
      to_port   = 80 -> 443
      protocol  = "tcp"
  }

Plan: 0 to add, 1 to change, 0 to destroy.
```

Incident note:

```text
During outage, engineer updated app security group in AWS Console to allow 443.
Terraform code was not updated yet.
```

Git code still says:

```hcl
from_port = 80
to_port   = 80
```

### Student Investigation Steps

1. Check whether Terraform code changed.
2. Review the plan output.
3. Identify whether the change came from Terraform or outside Terraform.
4. Check incident notes for emergency changes.
5. Decide whether HTTPS on 443 is now the correct desired state.
6. Recommend whether to update Terraform code or revert the console change.
7. Document the drift and resolution.

### Expected Root Cause

A manual AWS Console change created drift. The emergency change may be valid, but Terraform code was not updated to match the new desired state.

### Correct Resolution

If HTTPS on 443 is valid:

1. Update Terraform code:

```hcl
from_port = 443
to_port   = 443
```

2. Run:

```bash
terraform fmt
terraform validate
terraform plan
```

3. Review the plan.
4. Merge through Git review.
5. Apply after approval.
6. Close the drift ticket with documentation.

If the manual change was not valid:

1. Revert the manual change through Terraform.
2. Run plan and apply after approval.
3. Document the unauthorized drift.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Automatically reverting the change | It may have been a valid emergency fix |
| Ignoring the drift | Terraform will keep detecting it |
| Updating production manually again | Continues bypassing review |
| Force unlocking state | The issue is drift, not a lock problem |
| Editing state manually | Dangerous and unnecessary |
| Approving the plan without context | Could reintroduce an outage |

### Instructor Hints

Use these hints gradually:

1. “Did the code change?”
2. “Did the real AWS resource change?”
3. “Was there an incident?”
4. “Should Terraform represent the desired state?”
5. “What should be documented after this?”

### Preventive Action

- Require emergency changes to be followed by Terraform code updates.
- Run scheduled drift detection.
- Review CloudTrail for manual changes.
- Restrict direct console changes in production.
- Create an emergency change process.
- Add security group changes to plan review checklist.
- Use runbooks for incident response.

---

## 16. Scenario-Based Discussion Questions

### Question 1

Should emergency production fixes be allowed through the AWS Console?

Expected response themes:

- Sometimes necessary during urgent incidents
- Should be controlled and documented
- Must be followed by Terraform reconciliation
- Should not become normal practice

Follow-up:

> What should happen after the emergency is over?

### Question 2

Should Terraform automatically apply drift fixes?

Expected response themes:

- Auto-fixing drift can be risky
- Manual changes may have business context
- Human review protects production
- Teams need drift policy

Follow-up:

> Which drift changes might be safe to auto-correct, and which should always require review?

### Question 3

Who should have access to production Terraform state?

Expected response themes:

- Limited platform or pipeline roles
- Read-only access for some reviewers
- Write access should be tightly controlled
- State may contain sensitive data

Follow-up:

> Should application developers have direct write access to prod state?

### Question 4

Why is manual approval important before production apply?

Expected response themes:

- Reduces outage risk
- Supports change control
- Allows review of destructive changes
- Provides accountability

Follow-up:

> What plan changes should block approval?

### Question 5

What is the risk of two engineers running Terraform apply at the same time?

Expected response themes:

- State corruption
- Conflicting changes
- Unpredictable results
- Last-write-wins behavior
- Production impact

Follow-up:

> How does state locking reduce this risk?

### Question 6

Should dev and prod use the same state bucket?

Expected response themes:

- They may use same bucket with different keys, or separate buckets
- Prod should have stricter controls
- Separation reduces blast radius
- Access policies matter

Follow-up:

> What are the pros and cons of separate buckets per environment?

### Question 7

How does CI/CD improve Terraform safety?

Expected response themes:

- Consistent checks
- Repeatable workflow
- Reviewable plan output
- Manual approval
- Reduced local laptop risk
- Audit trail

Follow-up:

> What risks still exist even with CI/CD?

### Question 8

What should happen if Terraform plan shows a resource will be destroyed?

Expected response themes:

- Stop and review
- Confirm business requirement
- Check environment
- Check dependencies
- Require approval
- Back up if needed

Follow-up:

> Which resource types should trigger extra review before destroy?

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is Terraform state used for?

A. Formatting Terraform files  
B. Storing the mapping between Terraform resources and real infrastructure  
C. Replacing Git history  
D. Encrypting AWS credentials

**Answer:** B  
**Explanation:** Terraform state maps Terraform configuration to real resources.

### Question 2: True or False

Local state is usually the best option for enterprise teams.

**Answer:** False  
**Explanation:** Enterprise teams typically use remote state for collaboration, safety, and pipeline access.

### Question 3: AWS Question

Which AWS service is commonly used to store Terraform remote state?

A. EC2  
B. S3  
C. Route 53  
D. CloudFront

**Answer:** B  
**Explanation:** S3 is commonly used as a Terraform remote state backend in AWS.

### Question 4: AWS Question

Which AWS service is commonly used for Terraform state locking with the S3 backend pattern?

A. DynamoDB  
B. Lambda  
C. ECR  
D. RDS

**Answer:** A  
**Explanation:** DynamoDB is commonly used to provide locking for Terraform state in AWS.

### Question 5: Multiple Choice

What does this Terraform plan symbol usually mean?

```text
- destroy
```

A. Terraform will create a resource  
B. Terraform will delete a resource  
C. Terraform will format a file  
D. Terraform will skip the resource

**Answer:** B  
**Explanation:** The minus symbol means Terraform plans to destroy a resource.

### Question 6: Troubleshooting Question

Terraform plan shows unexpected security group changes, but no one changed the Terraform code. What is the likely issue?

**Answer:** Infrastructure drift caused by a manual or external change.  
**Explanation:** If real infrastructure changed outside Terraform, the next plan can show unexpected changes.

### Question 7: Troubleshooting Question

A student runs `terraform init` and gets an error that the S3 bucket does not exist. What should they do in this class lab?

**Answer:** Use `terraform init -backend=false` or keep the backend file as `backend.tf.example`.  
**Explanation:** The class lab uses backend examples unless actual S3 and DynamoDB backend resources are prepared.

### Question 8: Class 1 and Class 2 Connection

How does the `environments/prod` folder from Class 1 connect to remote state in Class 2?

**Answer:** The prod environment should have its own backend configuration or state path so prod state is separated and protected.  
**Explanation:** Class 1 separated environments. Class 2 protects each environment’s state and workflow.

### Question 9: Class 1 and Class 2 Connection

Why is a clean module and environment structure important before adding CI/CD?

**Answer:** CI/CD needs predictable folders and commands so it can run `fmt`, `validate`, `plan`, and `apply` consistently.  
**Explanation:** Poor repo structure makes pipeline automation harder and riskier.

### Question 10: Short Answer

Name three checks reviewers should perform before approving a Terraform plan.

**Answer:** Examples: check for destroys, replacements, IAM changes, network changes, correct environment, required tags, and whether the plan matches the ticket.  
**Explanation:** Plan review prevents unexpected production impact.

### Question 11: True or False

A CI/CD pipeline removes the need for human review in production Terraform workflows.

**Answer:** False  
**Explanation:** CI/CD automates checks, but production changes usually still require human approval.

### Question 12: Short Answer

What is the main purpose of state locking?

**Answer:** To prevent multiple Terraform operations from modifying the same state at the same time.  
**Explanation:** Locking reduces the chance of state corruption or conflicting applies.

---

## 18. Homework Assignment

### Assignment Title

**Enterprise Terraform Workflow Proposal**

### Scenario

Your company is standardizing Terraform usage for application teams. You already have a reusable repo structure from Class 1. Now leadership wants a safe workflow for remote state, plan review, CI/CD, and drift management.

### Student Tasks

Create a written proposal that includes:

1. Recommended repository structure.
2. Environment separation strategy (state which of the strategies from Class 1 you chose — folders, single-root + var-files, Terragrunt, or workspaces — and why).
3. Remote state backend design (including how the backend is **bootstrapped**).
4. State locking design (DynamoDB or native `use_lockfile`).
5. Git branching and merge request process.
6. Terraform plan review process, using the **`plan -out=tfplan` → review → `apply tfplan`** handoff.
7. Production approval process.
8. CI authentication design using **OIDC short-lived role assumption** (no static keys); include the IAM trust-policy `sub` condition concept.
9. A **policy-as-code** stage (`tfsec`/Checkov/Trivy and/or one OPA/Conftest rule).
10. An **automated testing** approach (native `terraform test` and/or terratest).
11. Drift detection process.
12. Emergency manual change process.
13. AWS, Azure, and GCP remote state comparison.
14. A note on OpenTofu and on at least one TACOS platform (Atlantis / HCP Terraform / Spacelift) you would consider instead of hand-rolling the pipeline.

### Expected Deliverables

Submit one document with:

- Architecture/workflow diagram
- Backend design table
- CI/CD stage list
- Plan review checklist
- Drift response process
- Short explanation of production approval rules
- Cloud comparison table

### Required Cloud Comparison Table

| Cloud | Remote State Storage | Locking Option | Notes |
|---|---|---|---|
| AWS | S3 | DynamoDB | Common enterprise pattern |
| Azure | Azure Storage Account | Blob lease locking | Common AzureRM backend pattern |
| GCP | Google Cloud Storage | Backend/workflow locking behavior | Common Google backend pattern |

### Submission Format

Submit as:

```text
week15-class2-terraform-workflow-proposal.md
```

or PDF.

### Estimated Completion Time

90 to 120 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Clear remote state design | 15 |
| Correct state locking explanation | 15 |
| Practical CI/CD workflow | 15 |
| Strong plan review checklist | 15 |
| Drift detection and response process | 15 |
| Production approval and security awareness | 10 |
| AWS-first with useful Azure/GCP comparison | 10 |
| Documentation quality | 5 |

### Optional Advanced Challenge

Go beyond the hand-rolled pipeline:

- Configure the same workflow on a TACOS platform — stand up **Atlantis** (open-source, self-hosted) or describe an **HCP Terraform** / **Spacelift** setup — and explain what it gives you for free (state, plan-in-PR comments, policy sets, drift detection).
- Add an **Infracost** stage so the merge request shows the cost delta of the plan (ties into Week 18 Cost Optimization).
- Write one **OPA/Conftest** policy ("deny S3 bucket without encryption" or "every resource must carry a `CostCenter` tag") and run it against `terraform show -json tfplan`.
- Add a `command = apply` `terraform test` that runs in a dedicated throwaway account and tears itself down.

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Thinking state is optional | Beginners focus only on `.tf` files | Explain state as Terraform’s memory |
| Committing `.tfstate` to Git | Students do not know state may be sensitive | Add `.gitignore` and explain remote state |
| Running backend init without backend resources | Backend examples are copied as real files | Use `backend.tf.example` or `terraform init -backend=false` |
| Confusing state locking with IAM permissions | Both are security-related concepts | Explain locking prevents simultaneous state writes |
| Ignoring plan output | Students rush to apply | Require plan review checklist |
| Treating every drift as bad | Drift may be an emergency fix | Investigate before deciding |
| Auto-applying prod changes | Students over-trust automation | Add manual approval and protected branches |
| Using same state path for dev and prod | Students do not understand state boundaries | Use separate keys or buckets |
| Not encrypting or protecting state | Students think state is harmless | Explain state can contain sensitive values |
| Force unlocking state casually | Students see lock as an error to clear | Explain force unlock can be dangerous |

---

## 20. Real-World Enterprise Scenario

### Scenario

A cloud platform team supports 20 application teams using AWS. Each application has dev and prod environments. In the past, engineers ran Terraform from laptops using local state. Over time, the company experienced:

- Lost state files
- Conflicting applies
- Unreviewed production changes
- Manual console drift
- Missing tags
- Security group changes with no audit trail
- Production outages after accidental applies

The platform team introduces a standard Terraform delivery workflow.

### Constraints

- Production applies require approval.
- Terraform state must be stored remotely.
- State must be encrypted.
- Pipeline roles must use least privilege.
- Manual console changes must be documented.
- Drift must be reviewed weekly.
- Security group and IAM changes require extra review.
- Application teams can submit Terraform changes, but platform team reviews shared modules.
- Cost center tags are mandatory.
- Production state access is limited.

### How the Class Topic Applies

Class 2 directly addresses this scenario:

- S3 remote state prevents laptop-only state.
- DynamoDB locking prevents simultaneous applies.
- CI/CD makes checks consistent.
- Plan review catches risky changes.
- Manual approval protects production.
- Drift detection finds console changes.
- Documentation creates repeatable team process.

### Role Responsibilities

| Role | What They Would Do |
|---|---|
| DevOps Engineer | Build CI/CD pipeline for Terraform plan and apply workflow |
| Cloud Engineer | Design S3 backend, DynamoDB locking, IAM access, and environment state strategy |
| SRE | Review change risk, drift impact, incident response process, and production safety controls |

---

## 21. Instructor Tips

### Teaching Tips

- Keep connecting every concept back to Class 1 structure.
- Use the phrase: “Class 1 gave us structure. Class 2 gives us safety.”
- Do not turn this into a deep AWS backend build unless students are ready.
- Explain state with simple analogies before showing backend code.
- Use drift as an operations story, not just a Terraform story.

### Pacing Tips

- Keep review under 15 minutes.
- Spend enough time on state because it is the hardest concept.
- Keep Azure/GCP comparison short.
- Use the troubleshooting scenario to reinforce drift.
- If the demo fails because AWS credentials are not configured, continue with sample outputs.

### Lab Support Tips

Watch for:

- Students creating `backend.tf` instead of `backend.tf.example`
- Students running `terraform init` without `-backend=false`
- YAML indentation errors
- Students not understanding why apply is manual
- Students confusing drift with syntax error
- Students trying to fix drift by editing state

### Helping Struggling Students

Ask:

- “What does Terraform state remember?”
- “Where would state live on a team?”
- “What does the plan say Terraform wants to do?”
- “Was this change made in code or directly in AWS?”
- “Should we update Terraform code or revert the manual change?”

### Challenging Advanced Students

Ask them to add:

- Separate pipeline jobs for dev and prod
- Manual approval for prod only
- OIDC role assumption concept
- Policy check stage
- Cost estimation stage
- Drift detection scheduled pipeline
- Backend bootstrap design

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

- What Terraform state is
- Why local state is risky for teams
- Why remote state is used
- Why state locking matters
- How S3 and DynamoDB support Terraform backend workflows
- What drift is
- Why plan review matters
- Why production apply should require approval
- How CI/CD makes Terraform safer

### Students Should Be Able to Build or Configure

- `backend.tf.example` for dev
- `backend.tf.example` for prod
- README section for Terraform change workflow
- README section for drift detection process
- README plan review checklist
- Simple GitLab CI pipeline example
- Safe local validation with `terraform init -backend=false`

### Students Should Be Able to Troubleshoot

- Missing backend bucket errors
- Terraform state confusion
- Unexpected plan output
- Drift caused by manual changes
- YAML pipeline indentation issues
- Missing variables or module paths
- Unsafe production apply workflow
- Accidental local state files

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

Verify students can answer:

1. What is Terraform state?
2. Why should state be remote for teams?
3. What does DynamoDB locking prevent?
4. What does `terraform plan` show?
5. What is drift?
6. What should happen after emergency console changes?
7. Why should production apply be manual?
8. How does Class 2 extend the Class 1 repo structure?

### Student Checklist Before Leaving Class

Students should have:

- Added backend examples for dev and prod.
- Added Terraform workflow documentation.
- Added drift detection documentation.
- Added plan review checklist.
- Created or reviewed `.gitlab-ci.yml`.
- Run `terraform fmt -recursive`.
- Run `terraform init -backend=false`.
- Run `terraform validate`.
- Understood not to commit real `.tfstate`.
- Understood why production apply needs approval.

### Items to Verify Before Closing the Week

Students should be comfortable with:

- Enterprise Terraform repo structure
- Environment separation
- Remote state purpose
- State locking purpose
- Drift detection
- Plan review
- Manual production approval
- CI/CD workflow stages

---

## 24. End-of-Week Summary

### What Students Learned This Week

This week, students learned how Terraform is used in enterprise team workflows.

They learned:

- How to structure Terraform repositories
- How to separate modules from environments
- How to use `tfvars` for dev and prod differences
- Why Terraform state matters
- Why remote state is safer for teams
- How state locking prevents simultaneous changes
- How Terraform plan review supports safe changes
- How drift happens and how to respond
- How CI/CD pipelines standardize Terraform workflows

### How Class 1 and Class 2 Connect

Class 1 focused on structure:

```text
modules/
environments/dev/
environments/prod/
terraform.tfvars
```

Class 2 focused on safety:

```text
remote state
state locking
plan review
drift detection
CI/CD approval workflow
```

Together, these classes teach students that enterprise Terraform requires both:

1. Clean code organization
2. Safe operational workflow

### How This Week Prepares Students for the Next Week

Week 15 prepares students for Week 16: **Observability & Reliability**.

Students are now ready to discuss:

- Instrumenting the infrastructure they now deliver safely
- Metrics, logs, and traces (Prometheus / Grafana / OpenTelemetry)
- Why "render/plan before apply" discipline pairs with "observe before you trust"
- How drift detection feeds operational signals
- Pipeline and deployment telemetry
- Secure delivery workflows that carry forward into DevSecOps (Week 19)

The IAM, KMS, Secrets Manager, and CloudTrail concepts touched here were established in Week 6 (Cloud Security & IAM) and are revisited in Week 19 (DevSecOps & Secure Delivery).

### What Students Should Review Before the Next Module

Students should review:

- IAM basics from Week 6
- Terraform repo structure from Class 1
- Remote state and locking from Class 2
- Why state can be sensitive
- Why pipelines should avoid long-lived credentials
- AWS KMS, Secrets Manager, and CloudTrail concepts at a high level

---

## Class Artifacts & Validation

The on-disk, validated versions of everything taught above live in the backing lab
[`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/). This class —
*remote state, S3+DynamoDB locking, drift, plan review, and CI/CD safety* — maps to the
**S3/DynamoDB backend config**, the **`.gitignore` that keeps state out of git**, the
**`broken/` troubleshooting fixture** (the kind of unindexed-reference defect a plan review
catches), and the **live apply/destroy** that proves the module is operated, not just written.
Run every gate with `cd labs/terraform-aws-foundations && ./validate.sh`
(**10 passed, 0 failed**, exit 0).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/terraform-aws-foundations/solution/backend.tf.example | terraform | The **S3 remote state + DynamoDB lock** backend block (`backend "s3"` with `dynamodb_table`, `encrypt = true`) — the exact pattern this class teaches; committed as `*.example` so the lab gates can `init -backend=false` | `terraform fmt -check -recursive solution` (copy to `backend.tf` to enable) | PASS (fmt/parse); backend wiring DEFERRED — runs where a real S3 bucket + lock table exist (README "Remote state" section gives the `aws s3api`/`dynamodb create-table` commands) |
| 2 | labs/terraform-aws-foundations/solution/.gitignore | config | Keeps `terraform.tfvars`, `backend.tf`, `.terraform/`, and `*.tfstate` out of git — the "state is sensitive, never commit it" control discussed in this class | `git check-ignore` / inspection | PASS |
| 3 | labs/terraform-aws-foundations/solution/outputs.tf | terraform | Module outputs (`vpc_id`, subnet IDs, `nat_gateway_id`) — the shared values a pipeline reads back from remote state | `terraform -chdir=solution init -backend=false && terraform -chdir=solution validate` | PASS — `Success! The configuration is valid.` |
| 4 | labs/terraform-aws-foundations/broken/main.tf | terraform | Reproducible defect fixture: `aws_route.private_nat` references the counted `aws_nat_gateway.this.id` without `[0]` — the class of error a **plan/validate gate in CI** must catch before apply | `terraform -chdir=broken init -backend=false && terraform -chdir=broken validate` (expected to FAIL) | PASS (gate) — validate exits 1 with `Missing resource instance key`, the intended negative result |
| 5 | labs/terraform-aws-foundations/validate.sh | shell | The CI gate runner this class's "plan/validate before apply" discipline maps to — fmt + init/validate + structural tests + broken-fixture negative gate + checkov security scan | `bash -n validate.sh` then `./validate.sh` | PASS — `== 10 passed, 0 failed ==` |
| 6 | labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt | evidence | Real AWS `apply` then `destroy` of the module (`19 added` → API-verified → `19 destroyed`, confirmed clean, $0) — evidence the infrastructure is **operated**, the precondition for meaningful drift detection | n/a (captured live run) | PASS — see labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt |

> Honest scope note: this class teaches the remote-state and locking **backend** and the
> drift/CI workflow at the concept level. The S3 backend block (row 1) is shipped and
> fmt-clean but is **DEFERRED** for end-to-end execution because standing up a real state
> bucket + lock table needs an AWS account; the README documents the exact one-time setup.
> Drift detection itself is taught as a process, not run as a live `terraform plan` against
> a deployed stack in this repo.

## Definition of Done

- [x] Every technology taught ships at least one **runnable/real file on disk** (S3+DynamoDB `backend.tf.example`, `.gitignore`, `outputs.tf`, the `broken/` fixture — not just fences).
- [x] Each artifact passes (or honestly documents) its **validation gate**: `terraform validate` on the solution, the negative `broken/` gate, and `fmt -check` on the backend example; the backend's live wiring is **DEFERRED** (documented) as noted above.
- [x] Lab has **starter** and **solution** versions (the backend example is a documented copy-to-enable file; the VPC lab has `starter/` with `TODO(student)` gaps).
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** (including a dedicated "Remote state" setup section).
- [x] **Cleanup/teardown** is provided and idempotent (`terraform destroy`; state/`.terraform` removal); remote-state bucket + lock table teardown is documented; the live run was destroyed clean.
- [x] **Instructor answer key** exists (README "Instructor answer key" → troubleshooting fixture fix: `aws_nat_gateway.this[0].id` + `count`-gate the route).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* (`broken/` — exactly the unindexed-counted-resource defect a CI plan gate exists to catch).
- [x] **Expected outputs** are shown (README "Validation" + "Expected results"; the broken fixture's exact error message is documented).
- [x] **Cost & security warnings** present (S3/DynamoDB can incur small charges; state is sensitive — restrict bucket IAM to the CI role; pipelines should avoid long-lived credentials).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Class 1 structure → Class 2 safety → Week 16 observability; KMS/Secrets/CloudTrail from Week 6, revisited Week 19).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves.
