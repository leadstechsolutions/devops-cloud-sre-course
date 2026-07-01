# Week 15: Terraform Enterprise Workflows  
> **▶ Runnable lab for this class:** [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package: Structuring Terraform with Modules and Environments

**Week:** 15
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 1: Structuring Terraform for Teams, Environments, and Reuse**

## Class Purpose

This class teaches students how Terraform is organized in real enterprise teams. Instead of writing all Terraform code in one folder, students learn how to separate reusable infrastructure modules from environment-specific deployments such as `dev`, `stage`, and `prod`.

The goal is to help students move from beginner Terraform usage to team-ready Terraform structure.

## How This Class Connects to the Overall Course

In Week 14 (Terraform Foundations), students learned Terraform basics:

- Providers
- Resources
- Variables
- Outputs
- State
- `terraform init`
- `terraform plan`
- `terraform apply`

This class builds on those basics and introduces enterprise workflow patterns used by DevOps Engineers, Cloud Engineers, and SREs.

This class prepares students for Class 2, where they will learn:

- Remote state
- State locking
- Drift detection
- Plan review
- CI/CD integration

## What Students Will Build, Analyze, or Practice

Students will:

- Build a reusable Terraform repository layout.
- Separate `modules` from `environments`.
- Create separate `dev` and `prod` folders.
- Use `terraform.tfvars` for environment-specific values.
- Document a team-based Terraform workflow.
- Analyze a bad Terraform folder structure and improve it.

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why enterprise Terraform projects need structure, standards, and review workflows.
2. **Compare** a beginner Terraform layout with an enterprise Terraform layout.
3. **Build** a Terraform repository structure using `modules` and `environments`.
4. **Configure** separate `dev` and `prod` environment folders.
5. **Use** `terraform.tfvars` to manage environment-specific values.
6. **Document** a Terraform repository structure for a team.
7. **Troubleshoot** common mistakes caused by copied folders, duplicated code, and wrong environment values.
8. **Validate** a basic Terraform folder structure using Terraform commands.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic Terraform workflow:
  - `terraform init`
  - `terraform fmt`
  - `terraform validate`
  - `terraform plan`
  - `terraform apply`
- Terraform providers
- Terraform resources
- Terraform variables
- Terraform outputs
- Basic AWS concepts:
  - Region
  - VPC
  - CIDR
  - Tags
  - IAM access
- Basic Git concepts:
  - Repository
  - Branch
  - Commit
  - Merge request or pull request
- Basic Linux or terminal navigation

## Required Tools Already Installed

Students should have:

- VS Code
- Git
- Terraform
- AWS CLI
- Terminal or shell
- Optional: GitHub or GitLab account

## Required Accounts or Access

For this class:

- AWS account is helpful but not strictly required.
- Students do **not** need to create real AWS resources in Class 1.
- Terraform examples are AWS-based, but students should avoid running `terraform apply` unless instructed.

## Files, Repos, or Sample Code Needed

Instructor can provide a starter folder, or students can create it during the lab.

Recommended starter repo name:

```text
terraform-enterprise-workflow
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Terraform | An infrastructure as code tool used to define and manage cloud resources using configuration files | Teams use Terraform to create AWS VPCs, IAM roles, databases, Kubernetes clusters, and other infrastructure |
| Infrastructure as Code | Managing infrastructure using code instead of manual console clicks | Allows teams to review, version, repeat, and audit infrastructure changes |
| Module | A reusable Terraform package that creates one infrastructure pattern | A platform team may create a reusable VPC module used by many application teams |
| Root Module | The folder where Terraform is executed directly | `environments/dev` or `environments/prod` is often a root module |
| Environment | A separate deployment target such as dev, test, stage, or prod | Enterprises separate environments to reduce risk and protect production |
| `tfvars` File | A file that provides values for Terraform variables | Dev and prod can use the same code but different values |
| Variable | A configurable input used by Terraform | Example: `vpc_cidr`, `environment`, `aws_region` |
| Output | A value Terraform prints or exposes after creating resources | Example: VPC ID, subnet IDs, load balancer DNS name |
| Provider | A Terraform plugin that lets Terraform talk to a platform like AWS, Azure, or GCP | The AWS provider lets Terraform manage AWS resources |
| Repository Structure | The folder layout used to organize Terraform code | Good structure helps teams avoid duplication and mistakes |
| Code Review | A process where another engineer reviews changes before merging | Infrastructure changes should be reviewed before they affect shared environments |
| Environment Separation | Keeping dev, stage, and prod configuration separate | Reduces the risk of accidentally changing production |
| Reusable Pattern | A standard infrastructure design that teams can apply repeatedly | Example: every application VPC uses the same module but different CIDR ranges |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Terraform | Main tool for creating and organizing infrastructure as code |
| Git | Tracks infrastructure changes and supports team review |
| VS Code | Used to edit Terraform files and README documentation |
| Terminal | Used to create folders and run Terraform commands |
| AWS CLI | Used later for AWS validation and authentication; introduced here as part of the workflow |
| GitHub or GitLab | Used conceptually for merge requests, pull requests, and team review workflows |
| HCL | HashiCorp Configuration Language used to write Terraform configuration |

---

# 6. AWS Services Used

This class is mostly focused on Terraform structure, but AWS is used as the primary cloud example.

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon VPC | Used as the example reusable module |
| AWS IAM | Discussed as part of future team permissions and Terraform access |
| Amazon S3 | Mentioned as a future remote state backend for Class 2 |
| S3 native locking (`use_lockfile`) | Modern state locking covered in Class 2; DynamoDB noted as the legacy mechanism |
| AWS Tags | Used in examples to show enterprise ownership, environment, and cost tracking |
| AWS Regions | Used in environment configuration examples |

## Cost Warning

Students should not run `terraform apply` in this class unless the instructor explicitly allows it. The focus is repository structure, not creating live AWS resources.

---

# 7. Azure and GCP Comparison Notes

Keep this short during class.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Provider | AWS Provider | AzureRM Provider | Google Provider |
| Example Network Resource | VPC | Virtual Network | VPC Network |
| Remote State Storage | S3 | Azure Storage Account | Google Cloud Storage |
| State Locking | S3 native (`use_lockfile`); DynamoDB legacy | Blob lease locking | Backend/workflow-based locking behavior |
| Environment Separation | dev/prod folders or workspaces | same concept | same concept |

Instructor talking point:

> Terraform structure is mostly cloud-agnostic. The folder design, module pattern, and Git review workflow stay similar across AWS, Azure, and GCP. What changes are the provider, resource names, authentication method, and backend configuration.

---

# 8. Time-Boxed Instructor Agenda

| Time | Segment |
|---:|---|
| 0:00 to 0:15 | Review and class goals |
| 0:15 to 0:35 | Enterprise Terraform workflow |
| 0:35 to 1:05 | Repository structure patterns |
| 1:05 to 1:30 | Modules, root modules, and environment folders |
| 1:30 to 1:40 | Break |
| 1:40 to 2:05 | `tfvars` and environment values |
| 2:05 to 2:30 | Instructor demo |
| 2:30 to 2:50 | Student lab |
| 2:50 to 3:00 | Troubleshooting, discussion, recap |

---

# 9. Instructor Lesson Plan

## Step 1: Open the Class

Start with:

> Last week, we learned how Terraform creates infrastructure. Today, we are learning how Terraform is organized when more than one person, one environment, or one team is involved.

Explain that the class is not about writing advanced AWS resources yet. It is about **structure and workflow**.

Ask students:

- What could go wrong if every engineer keeps Terraform files on their laptop?
- What could go wrong if dev and prod are in the same folder?
- What could go wrong if teams copy and paste Terraform code for every app?

Pause for 2 to 3 responses.

## Step 2: Review Week 14 Basics

Review:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Explain:

> These commands are still used in enterprise workflows, but they are wrapped with structure, Git review, remote state, and approvals.

Teaching tip:

Do not spend too much time reteaching the Week 14 Terraform basics. The goal is to connect old knowledge to team workflow.

## Step 3: Explain Why Enterprise Terraform Is Different

Use this comparison:

| Beginner Terraform | Enterprise Terraform |
|---|---|
| One folder | Structured repo |
| Local state | Remote state |
| Manual apply | Pipeline or reviewed apply |
| One user | Team workflow |
| Console fixes | Code-reviewed changes |
| No approval | Approval for production |
| Duplicated code | Reusable modules |

Say:

> Terraform in a company is not only a technical tool. It is also part of change management, audit, security, and operational safety.

Pause for questions.

## Step 4: Introduce Repository Structure

Show this layout:

```text
terraform-enterprise-app/
├── modules/
│   └── vpc/
└── environments/
    ├── dev/
    └── prod/
```

Explain:

- `modules/` contains reusable building blocks.
- `environments/` contains deployment-specific configuration.
- `dev/` and `prod/` may call the same module but use different values.

Teaching tip:

Use a simple analogy:

> A module is like a reusable recipe. The environment folder is where you decide whether you are cooking for a small test kitchen or a large production restaurant.

## Step 5: Explain Modules

Show:

```text
modules/vpc/
├── main.tf
├── variables.tf
└── outputs.tf
```

Explain:

- `main.tf` contains the resources.
- `variables.tf` defines inputs.
- `outputs.tf` exposes useful results.

Mention:

> A platform team may create modules, and application teams may consume them.

## Step 6: Explain Environment Folders

Show:

```text
environments/dev/
├── main.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
└── outputs.tf
```

Explain:

- This folder is where Terraform is executed.
- It calls reusable modules.
- It provides environment-specific values.

Pause and ask:

> If dev and prod use the same VPC module, what values might still be different?

Expected answers:

- CIDR
- Tags
- Region
- Instance sizes
- Backup settings
- Monitoring settings
- Naming conventions

## Step 7: Demonstrate `tfvars`

Show dev:

```hcl
environment = "dev"
aws_region  = "us-east-1"
vpc_cidr    = "10.10.0.0/16"
```

Show prod:

```hcl
environment = "prod"
aws_region  = "us-east-1"
vpc_cidr    = "10.20.0.0/16"
```

Say:

> Same code. Different values. That is one of the most important ideas in reusable infrastructure design.

## Step 8: Run Instructor Demo

Build the repo live.

Keep the demo simple. Do not create real AWS resources unless you intentionally choose to.

## Step 9: Student Lab

Students create their own repo layout.

Walk around or monitor:

- Folder structure
- Naming
- `tfvars` content
- README clarity

## Step 10: Troubleshooting Activity

Present the copied dev-to-prod problem.

Ask students to identify what went wrong and how to prevent it.

## Step 11: Wrap Up

End with:

> Class 1 teaches structure. Class 2 teaches safety. Once we have a clean repo layout, we can add remote state, locking, drift detection, and CI/CD review.

---

# 10. Instructor Lecture Notes

## Concept 1: Why Terraform Structure Matters

Terraform becomes risky when teams treat it like a personal script.

In a real company, Terraform may control:

- Production VPCs
- IAM roles
- Security groups
- Kubernetes clusters
- Load balancers
- Databases
- DNS records

A small mistake can cause an outage, security exposure, or cost increase.

Talking point:

> In enterprise cloud teams, Terraform code is production-impacting code. It deserves the same review discipline as application code.

Common misconception:

> “Terraform is just automation, so if the code runs, it is fine.”

Correct explanation:

> Terraform changes real infrastructure. A valid Terraform plan can still be a bad business or security decision.

## Concept 2: Modules vs Environment Folders

A common beginner mistake is putting everything into one `main.tf`.

That works for small labs, but it does not scale.

Enterprise Terraform usually separates:

```text
Reusable logic: modules/
Deployment-specific configuration: environments/
```

Talking point:

> Modules should answer: what pattern are we building? Environment folders should answer: where and with what values are we deploying it?

Example:

The VPC module defines how to create a VPC. The dev environment decides the dev CIDR. The prod environment decides the prod CIDR.

## Concept 3: Why Dev and Prod Should Be Separate

Dev and prod should be separated because they have different risk levels.

Dev can tolerate more change. Prod usually needs:

- More review
- Better logging
- Stronger access control
- Backup and recovery
- More restrictive networking
- Change approval
- Stable naming and tagging

Talking point:

> Dev is where we learn. Prod is where the business depends on us.

## Concept 4: Why `tfvars` Files Matter

Variables define what can change. `tfvars` files define actual values.

Example variable:

```hcl
variable "environment" {
  description = "Deployment environment name"
  type        = string
}
```

Example dev value:

```hcl
environment = "dev"
```

Example prod value:

```hcl
environment = "prod"
```

Talking point:

> If you copy and paste the same code everywhere, you create maintenance problems. If you use variables and modules properly, you create controlled reuse.

## Concept 5: Git-Based Review

Terraform code should be stored in Git.

Git gives teams:

- History
- Review
- Rollback context
- Collaboration
- Audit trail
- Change discussion

Talking point:

> The pull request or merge request is where the team catches problems before Terraform changes the cloud.

Examples of problems review can catch:

- Wrong CIDR
- Wrong region
- Missing tags
- Public exposure
- Overly broad IAM
- Accidental deletion
- Wrong environment
- Copy/paste mistake

## Concept 6: Enterprise Context

In enterprise teams, Terraform structure often reflects:

- Business units
- Application teams
- Environments
- Shared services
- Cloud accounts
- Regions
- Compliance boundaries
- Cost centers

Example enterprise layout:

```text
cloud-platform/
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── iam-role/
└── environments/
    ├── account-a-dev/
    ├── account-a-prod/
    ├── account-b-dev/
    └── account-b-prod/
```

Talking point:

> The exact folder structure can vary, but the principle is consistent: reusable patterns should be separated from environment-specific deployment.

## Concept 7: Environment Separation Strategies (and Their Tradeoffs)

The `dev/` + `prod/` folder pattern we build in the lab is the most common *first* pattern, but it is not the only one — and it has a well-known weakness that the troubleshooting activity exposes: **the per-env folders are near-identical copies, so a copy-paste mistake (same CIDR, wrong region) is easy and `terraform validate` will not catch it.** A senior engineer is expected to know the alternatives and when to reach for each.

| Strategy | How it works | Pros | Cons / footguns |
|---|---|---|---|
| **(a) Per-env folders + shared module** (this lab) | Each env is its own root module that calls `../../modules/*`; differences live only in `terraform.tfvars` and `backend` | Simple, explicit, easy to read, isolated state per env | Boilerplate is duplicated across folders → copy-paste drift; the very bug in our incident |
| **(b) Single root module + `-var-file` + per-env backend** | One root config; you select the environment at run time with `-var-file=envs/prod.tfvars` and `-backend-config=envs/prod.s3.tfbackend` | Almost no duplication; one source of truth | Easy to apply to the *wrong* environment if you forget the flag; backend selection must be disciplined |
| **(c) Terragrunt** | A thin wrapper (`terragrunt.hcl`) that keeps backend + provider + inputs DRY and generates them per env; calls a single module | Strongest DRY for many envs/accounts; remote-state config generated automatically | Extra tool to learn and install; another abstraction layer |
| **(d) Terraform/OpenTofu workspaces** | One backend, multiple named state instances (`terraform workspace new prod`); code branches on `terraform.workspace` | Built-in, no extra tooling | **Anti-pattern for prod-vs-dev separation** — shared backend, shared IAM, easy to apply to the wrong workspace from the same checkout; HashiCorp itself advises against using workspaces for strong env isolation. Fine for short-lived/ephemeral envs |

Talking point:

> Folders (a) are the easiest to *teach* and the easiest to *get wrong*. The duplication you see between `dev/` and `prod/` is exactly why teams graduate to (b), Terragrunt (c), or — for ephemeral environments only — workspaces (d). We build (a) so you can feel the pain, then name the cures.

Workspaces footgun, said plainly:

> `terraform workspace select prod` followed by `terraform apply` looks identical to a dev apply. There is no separate folder, no separate backend, no separate credentials — one fat-finger and you have applied dev intent to prod state. That is why workspaces are good for ephemeral/preview envs and bad for the dev↔prod boundary.

## Concept 8: Module Sources and Versioning (Local, Git, Registry)

In the lab the module `source` is always a local relative path (`../../modules/vpc`). That is correct for a module that lives in the same repo, but real teams consume modules from three kinds of sources, and a senior must know all three plus how to **pin a version**.

```hcl
# 1) Local path — module lives in this repo (what the lab uses)
module "vpc" {
  source = "../../modules/vpc"
}

# 2) Git source — module lives in another repo, PINNED to an immutable ref
module "vpc" {
  source = "git::https://github.com/my-org/terraform-modules.git//vpc?ref=v1.4.0"
}

# 3) Terraform Registry (public or private) — versioned, the 2026 default for VPCs
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"   # pin a major; ~> 5.0 allows 5.x, blocks 6.0
}
```

Key senior points:

- **Always pin.** A bare `git::...` (no `?ref=`) tracks the default branch — your infra changes when someone else merges. Pin to a tag (`?ref=v1.4.0`) or a commit SHA. For registry modules, set `version`.
- **`~>` is the pessimistic constraint operator.** `~> 5.0` means `>= 5.0.0, < 6.0.0`. Use it to take patches/minors but block breaking majors.
- **Consume vs build.** In 2026, most teams do *not* hand-roll a production VPC; they consume the community module `terraform-aws-modules/vpc/aws` (subnets, route tables, NAT, IGW, flow logs — all parameterized). Hand-rolling is for learning or for genuinely org-specific patterns.
- **`terraform init` downloads modules**, and `.terraform.lock.hcl` records *provider* versions (not module versions — module versions are pinned in code).

Teaching note about *this* lab's module:

> The `aws_vpc`-only module we build is a deliberate teaching **stub** — one resource so the structure is visible. A real reusable VPC module also creates subnets, route tables, an internet gateway, and NAT. Rather than re-derive all of that, point students at `terraform-aws-modules/vpc/aws` as the production-grade reference.

## Concept 9: `for_each` and `count` — Instantiating Many Things

Real environments rarely create one of anything. `for_each` (preferred) and `count` let one block create N resources or call a module N times.

```hcl
# Create N subnets from a map (for_each → stable keys, safe to add/remove)
variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, { Name = "${var.environment}-${each.key}" })
}
```

```hcl
# tfvars
subnets = {
  app-a = { cidr = "10.10.1.0/24", az = "us-east-1a" }
  app-b = { cidr = "10.10.2.0/24", az = "us-east-1b" }
}
```

Senior talking points:

> Prefer `for_each` over `count` for anything keyed by identity (subnets, accounts, users). With `count`, removing the *middle* item renumbers the index and Terraform will plan to destroy/recreate everything after it. With `for_each`, each instance is keyed by a stable map key, so removing one only touches that one. Reach for `count` only for simple "make N identical copies" or a `count = var.enabled ? 1 : 0` feature toggle.

---

# 11. Whiteboard Explanation

## Simple Diagram

```text
                 Git Repository
                      |
                      v
        --------------------------------
        |                              |
        v                              v
    modules/                      environments/
        |                              |
        v                              v
  reusable code                  dev/       prod/
        |                         |           |
        |                         v           v
        |                  terraform.tfvars  terraform.tfvars
        |                         |           |
        ---------- called by ------           |
                                  |           |
                                  v           v
                            AWS Dev Env   AWS Prod Env
```

## Step-by-Step Flow

1. Engineers write reusable infrastructure patterns in `modules/`.
2. Each environment has its own folder under `environments/`.
3. The dev environment calls modules with dev values.
4. The prod environment calls the same modules with prod values.
5. Git review checks changes before merge.
6. Terraform is run from the correct environment folder.
7. The same pattern is reused safely across environments.

## What Each Component Means

| Component | Meaning |
|---|---|
| Git Repository | Central place where Terraform code is stored and reviewed |
| `modules/` | Reusable infrastructure building blocks |
| `environments/dev` | Dev deployment configuration |
| `environments/prod` | Prod deployment configuration |
| `terraform.tfvars` | Environment-specific values |
| AWS Dev Env | Lower-risk environment for testing |
| AWS Prod Env | Production environment requiring stricter control |

## Enterprise Version

```text
Enterprise Terraform Repository
│
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── s3/
│   ├── rds/
│   └── iam-role/
│
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── docs/
│   ├── change-process.md
│   └── naming-standards.md
│
└── .gitlab-ci.yml or .github/workflows/
```

Enterprise message:

> The repository is not just code. It also contains standards, documentation, and workflow automation.

---

# 12. Instructor Demo Script

## Demo Title

**Build a Multi-Environment Terraform Repository Layout**

## Demo Objective

Show students how to organize Terraform code for reusable modules and separate dev/prod environments.

## Required Setup

Instructor machine should have:

```bash
terraform version
git --version
aws --version
code --version
```

Expected examples:

```text
Terraform v1.x.x
git version 2.x.x
aws-cli/2.x.x
```

## Step 1: Create the Repo Folder

```bash
mkdir terraform-enterprise-app
cd terraform-enterprise-app
git init
```

Expected output:

```text
Initialized empty Git repository
```

Explain:

> We are starting the way a team would start: with a Git repository.

## Step 2: Create Folder Structure

```bash
mkdir -p modules/vpc
mkdir -p environments/dev
mkdir -p environments/prod
mkdir docs
```

Validate:

```bash
find . -maxdepth 3 -type d
```

Expected output:

```text
.
./modules
./modules/vpc
./environments
./environments/dev
./environments/prod
./docs
```

Explain:

> The module folder will hold reusable code. The environment folders will hold deployment-specific configuration.

## Step 3: Create Module Files

```bash
touch modules/vpc/main.tf
touch modules/vpc/variables.tf
touch modules/vpc/outputs.tf
```

Open in VS Code:

```bash
code .
```

## Step 4: Add VPC Module Variables

File:

```text
modules/vpc/variables.tf
```

Content:

```hcl
variable "environment" {
  description = "Environment name such as dev or prod"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
}
```

Explain:

> These variables make the module reusable. The module does not hardcode dev or prod values.

## Step 5: Add VPC Module Resource Example

File:

```text
modules/vpc/main.tf
```

Content:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}
```

Explain:

> This module creates an AWS VPC. The CIDR and tags come from the environment folder.

Security/cost note:

> A VPC itself does not usually create direct hourly cost, but related resources such as NAT Gateways, load balancers, and endpoints can create cost. Today, we are not applying this code.

## Step 6: Add VPC Module Output

File:

```text
modules/vpc/outputs.tf
```

Content:

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
```

Explain:

> Outputs allow other modules or environment code to reference values created by this module.

## Step 7: Create Dev Environment Files

```bash
touch environments/dev/main.tf
touch environments/dev/provider.tf
touch environments/dev/variables.tf
touch environments/dev/terraform.tfvars
touch environments/dev/outputs.tf
```

File:

```text
environments/dev/provider.tf
```

Content:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

File:

```text
environments/dev/variables.tf
```

Content:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
```

File:

```text
environments/dev/main.tf
```

Content:

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  tags        = var.tags
}
```

File:

```text
environments/dev/terraform.tfvars
```

Content:

```hcl
environment = "dev"
aws_region  = "us-east-1"
vpc_cidr    = "10.10.0.0/16"

tags = {
  Environment = "dev"
  Owner       = "platform-team"
  ManagedBy   = "terraform"
  CostCenter  = "training"
}
```

File:

```text
environments/dev/outputs.tf
```

Content:

```hcl
output "vpc_id" {
  description = "VPC ID from the VPC module"
  value       = module.vpc.vpc_id
}
```

## Step 8: Create Prod Environment Files

Copy dev to prod for teaching, but emphasize careful review:

```bash
cp environments/dev/provider.tf environments/prod/provider.tf
cp environments/dev/variables.tf environments/prod/variables.tf
cp environments/dev/main.tf environments/prod/main.tf
cp environments/dev/outputs.tf environments/prod/outputs.tf
```

Create prod values:

```text
environments/prod/terraform.tfvars
```

```hcl
environment = "prod"
aws_region  = "us-east-1"
vpc_cidr    = "10.20.0.0/16"

tags = {
  Environment = "prod"
  Owner       = "platform-team"
  ManagedBy   = "terraform"
  CostCenter  = "production"
  Criticality = "high"
}
```

Explain:

> Copying structure is okay. Blindly copying values is dangerous. Prod must have reviewed values.

## Step 9: Run Terraform Format

From repo root:

```bash
terraform fmt -recursive
```

Expected output may show formatted files or no output.

Explain:

> Formatting keeps Terraform code consistent across the team.

## Step 10: Validate Dev Folder

```bash
cd environments/dev
terraform init
terraform validate
```

Expected output:

```text
Terraform has been successfully initialized!
Success! The configuration is valid.
```

Do not run apply.

Explain:

> Validation confirms syntax and provider configuration. It does not prove the design is safe. Humans still review the plan.

## Step 11: Show a Registry Module as the Production Alternative (Discussion / Optional Init)

Make the point that the hand-built VPC module is a teaching stub by showing what a real team would consume instead. Create a throwaway file `environments/dev/registry-example.tf.disabled` (the `.disabled` suffix keeps Terraform from loading it) and walk through it:

```hcl
# Production teams usually consume the community VPC module instead of hand-rolling one.
module "vpc_real" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true   # cost control for non-prod

  tags = var.tags
}
```

Explain:

> This one block creates the VPC, subnets, route tables, an internet gateway, and a NAT gateway — all the things our teaching stub leaves out. Notice `version = "~> 5.0"`: we pin the major so a future `6.0` cannot silently change our network.

Cost warning:

> A NAT gateway is **not** free — it bills hourly plus per-GB. `single_nat_gateway = true` reduces dev cost, but do not `apply` this in class. If you ever do apply it, run `terraform destroy` afterward and confirm the NAT gateway is gone in the VPC console.

If you want to show `init` downloading the module, copy the block into a real `.tf` file in a scratch folder and run `terraform init` (it downloads from the registry), then `terraform validate`. Do **not** apply.

## Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `terraform: command not found` | Terraform not installed or PATH issue | Use installed terminal, fix PATH, or show expected output |
| `code: command not found` | VS Code command not added to PATH | Open folder manually in VS Code |
| `terraform init` fails | Internet or provider download issue | Explain provider download and continue with code review |
| `terraform validate` fails | Typo in HCL | Use error message to teach debugging |
| AWS credentials error during plan | AWS CLI not configured | Do not run plan; stay with validate and structure |
| Students run apply accidentally | Misunderstood instruction | Stop, run cleanup if resources created |

## Cleanup Steps

If no apply was run:

```bash
cd ../../
rm -rf terraform-enterprise-app
```

If students created real AWS resources accidentally:

```bash
cd environments/dev
terraform destroy
```

Then verify in AWS Console.

---

# 13. Student Lab Manual

## Lab Title

**Create a Multi-Environment Terraform Repository Layout**

## Lab Objective

Create a Terraform repository that separates reusable modules from environment-specific configuration for `dev` and `prod`.

## Estimated Time

30 to 40 minutes

## Student Prerequisites

You should already know:

- Basic Terraform files
- Basic Git commands
- Terminal navigation
- AWS region and VPC concept
- Basic variables and outputs

## Architecture or Workflow Overview

You will create this structure:

```text
terraform-enterprise-workflow/
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── provider.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
└── README.md
```

## Step 1: Create the Project Folder

```bash
mkdir terraform-enterprise-workflow
cd terraform-enterprise-workflow
git init
```

Expected output:

```text
Initialized empty Git repository
```

## Step 2: Create Folder Structure

```bash
mkdir -p modules/vpc
mkdir -p environments/dev
mkdir -p environments/prod
```

Validate:

```bash
find . -maxdepth 3 -type d
```

Expected output:

```text
.
./modules
./modules/vpc
./environments
./environments/dev
./environments/prod
```

## Step 3: Create VPC Module Files

```bash
touch modules/vpc/main.tf
touch modules/vpc/variables.tf
touch modules/vpc/outputs.tf
```

Add this to `modules/vpc/variables.tf`:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
```

Add this to `modules/vpc/main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}
```

Add this to `modules/vpc/outputs.tf`:

```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.main.cidr_block
}
```

## Step 4: Create Dev Environment Files

```bash
touch environments/dev/main.tf
touch environments/dev/provider.tf
touch environments/dev/variables.tf
touch environments/dev/terraform.tfvars
touch environments/dev/outputs.tf
```

Add this to `environments/dev/provider.tf`:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

Add this to `environments/dev/variables.tf`:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
```

Add this to `environments/dev/main.tf`:

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  tags        = var.tags
}
```

Add this to `environments/dev/terraform.tfvars`:

```hcl
environment = "dev"
aws_region  = "us-east-1"
vpc_cidr    = "10.10.0.0/16"

tags = {
  Environment = "dev"
  Owner       = "platform-team"
  ManagedBy   = "terraform"
  CostCenter  = "training"
}
```

Add this to `environments/dev/outputs.tf`:

```hcl
output "vpc_id" {
  description = "VPC ID from module"
  value       = module.vpc.vpc_id
}
```

## Step 5: Create Prod Environment Files

```bash
cp environments/dev/main.tf environments/prod/main.tf
cp environments/dev/provider.tf environments/prod/provider.tf
cp environments/dev/variables.tf environments/prod/variables.tf
cp environments/dev/outputs.tf environments/prod/outputs.tf
touch environments/prod/terraform.tfvars
```

Add this to `environments/prod/terraform.tfvars`:

```hcl
environment = "prod"
aws_region  = "us-east-1"
vpc_cidr    = "10.20.0.0/16"

tags = {
  Environment = "prod"
  Owner       = "platform-team"
  ManagedBy   = "terraform"
  CostCenter  = "production"
  Criticality = "high"
}
```

## Step 6: Format the Terraform Files

From the project root:

```bash
terraform fmt -recursive
```

Expected output:

```text
modules/vpc/main.tf
environments/dev/main.tf
environments/prod/main.tf
```

Output may vary. No output is also okay if files are already formatted.

## Step 7: Validate the Dev Environment

```bash
cd environments/dev
terraform init
terraform validate
```

Expected output:

```text
Terraform has been successfully initialized!
Success! The configuration is valid.
```

Do **not** run `terraform apply`.

## Step 8: Validate the Prod Environment

```bash
cd ../prod
terraform init
terraform validate
```

Expected output:

```text
Terraform has been successfully initialized!
Success! The configuration is valid.
```

Do **not** run `terraform apply`.

## Step 9: Create README Documentation

Return to repo root:

```bash
cd ../../
touch README.md
```

Add:

```markdown
# Terraform Enterprise Workflow

## Purpose

This repository demonstrates a Terraform structure for reusable modules and separate environments.

## Folder Structure

- modules/: reusable infrastructure modules
- environments/dev/: dev environment deployment
- environments/prod/: prod environment deployment

## Change Process

1. Create a branch.
2. Update Terraform code.
3. Run terraform fmt.
4. Run terraform validate.
5. Open a pull request or merge request.
6. Review the Terraform plan before apply.
7. Require approval for production changes.

## Environment Notes

Dev and prod use the same VPC module but different values.
```

## Validation Checklist

Students should verify:

- `modules/vpc` exists.
- `environments/dev` exists.
- `environments/prod` exists.
- Dev and prod have different CIDR blocks.
- Dev and prod have different tags.
- `terraform fmt -recursive` runs successfully.
- `terraform validate` succeeds in dev.
- `terraform validate` succeeds in prod.
- README explains the repo purpose.

## Troubleshooting Tips

| Problem | Fix |
|---|---|
| `terraform init` fails | Check internet connection and provider block |
| `terraform validate` says variable not declared | Add missing variable to `variables.tf` |
| Module source not found | Check relative path: `../../modules/vpc` |
| HCL syntax error | Check quotes, braces, commas, and equals signs |
| Dev and prod values are the same | Update `terraform.tfvars` to use different environment-specific values |

## Cleanup Steps

If you did not apply resources:

```bash
cd ..
rm -rf terraform-enterprise-workflow
```

If you accidentally ran `terraform apply`:

```bash
cd environments/dev
terraform destroy
```

Then repeat for prod if needed:

```bash
cd ../prod
terraform destroy
```

## Reflection Questions

1. Why should reusable Terraform code be placed in modules?
2. Why should dev and prod have separate folders?
3. What values should usually be different between dev and prod?
4. Why is copying dev values into prod dangerous?
5. How does Git review reduce Terraform risk?

## Optional Challenge Task

**Challenge A — Add a third environment.** Add `environments/stage/` (copy the structure, then change the values — deliberately practice *not* copy-pasting the CIDR):

```hcl
environment = "stage"
vpc_cidr    = "10.15.0.0/16"
```

**Challenge B — Add `for_each` subnets to the module.** Extend `modules/vpc` so it creates multiple subnets from a map variable instead of just the VPC:

Add to `modules/vpc/variables.tf`:

```hcl
variable "subnets" {
  description = "Map of subnet name to {cidr, az}"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {}
}
```

Add to `modules/vpc/main.tf`:

```hcl
resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, { Name = "${var.environment}-${each.key}" })
}
```

Pass subnets from `environments/dev/main.tf` and `environments/dev/terraform.tfvars`, then run `terraform validate`. Notice that adding or removing a *named* subnet only changes that subnet's plan — that is the `for_each` advantage over `count`.

**Challenge C — Pin a registry module.** Replace your local VPC module call with `terraform-aws-modules/vpc/aws` (`version = "~> 5.0"`) in a scratch folder, run `terraform init` to watch it download, and compare what it creates versus your stub. Do **not** apply.

---

# 14. Troubleshooting Activity

## Incident Title

**Prod VPC Accidentally Uses Dev CIDR Range**

## Business Impact

A production environment cannot be approved by the networking team because its CIDR overlaps with the dev environment. This delays the application release and creates a potential routing conflict.

## Symptoms

- Terraform files validate successfully.
- Architecture review fails.
- Networking team says prod CIDR overlaps with dev.
- Dev and prod both show similar values in `terraform.tfvars`.

## Starting Evidence

Dev `terraform.tfvars`:

```hcl
environment = "dev"
vpc_cidr    = "10.10.0.0/16"
```

Prod `terraform.tfvars`:

```hcl
environment = "prod"
vpc_cidr    = "10.10.0.0/16"
```

Architecture review comment:

```text
Rejected: Production VPC CIDR overlaps with existing development VPC allocation.
```

## Student Investigation Steps

1. Compare `environments/dev/terraform.tfvars` and `environments/prod/terraform.tfvars`.
2. Identify values that should be environment-specific.
3. Check if prod was copied from dev.
4. Check README or documentation for expected CIDR ranges.
5. Determine whether the module is the problem or the input values are the problem.
6. Recommend a safe correction.

## Expected Root Cause

The prod folder was copied from dev, but the `vpc_cidr` value was not changed.

## Correct Resolution

Update prod:

```hcl
environment = "prod"
vpc_cidr    = "10.20.0.0/16"
```

Then run:

```bash
terraform fmt -recursive
cd environments/prod
terraform validate
terraform plan
```

Do not apply until the change is reviewed.

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Editing the module | The module is reusable and not the source of the bad CIDR |
| Ignoring the review comment | CIDR overlap can cause real routing issues |
| Applying anyway | This creates production risk |
| Using random CIDR | CIDR allocation should follow network standards |
| Deleting dev | Dev is not the problem |

## Instructor Hints

Use these hints gradually:

1. “Which file contains environment-specific values?”
2. “Are dev and prod using the same module or the same values?”
3. “Is the module broken, or was it called with the wrong input?”
4. “Would Terraform validation catch a bad enterprise design decision?”

## Preventive Action

- Require CIDR review before production apply.
- Maintain an IP allocation document.
- Use separate `tfvars` files per environment.
- Add code review checklist for environment-specific values.
- Consider variable validation rules.
- Require architecture approval for network changes.

Example validation idea:

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}
```

---

# 15. Scenario-Based Discussion Questions

## Question 1

Why should prod Terraform changes require more review than dev changes?

Expected themes:

- Higher business impact
- Customer-facing risk
- Security concerns
- Outage prevention
- Compliance and audit

Follow-up:

> What types of Terraform changes should always require senior review?

## Question 2

Should every application team create its own Terraform modules from scratch?

Expected themes:

- Reusable modules reduce duplication
- Platform teams can standardize patterns
- Teams still need flexibility
- Shared modules require ownership and versioning

Follow-up:

> What could go wrong if every team writes its own VPC module?

## Question 3

When is copying Terraform code acceptable, and when is it risky?

Expected themes:

- Copying structure may be acceptable
- Copying values blindly is risky
- Duplicated logic becomes hard to maintain
- Modules reduce copy/paste

Follow-up:

> What review checklist would catch copy/paste mistakes?

## Question 4

Who should own shared Terraform modules in an enterprise?

Expected themes:

- Platform engineering team
- Cloud engineering team
- Security review involvement
- Application team feedback
- Clear ownership model

Follow-up:

> How should application teams request changes to shared modules?

## Question 5

Should Terraform repository structure be organized by application, account, environment, or cloud provider?

Expected themes:

- It depends on organization size and operating model
- Application-based repos work well for app ownership
- Account-based repos work well for platform foundations
- Hybrid models are common
- State boundaries matter

Follow-up:

> How would your answer change for a multi-account AWS organization?

## Question 6

What is the risk of putting dev and prod in the same Terraform state?

Expected themes:

- Accidental prod changes
- Harder access control
- Larger blast radius
- Harder rollback
- Risk of deleting wrong resources

Follow-up:

> How does environment separation reduce blast radius?

## Question 7

Why is documentation important in a Terraform repository?

Expected themes:

- Helps new engineers
- Explains workflow
- Reduces misuse
- Supports audit
- Clarifies ownership and review process

Follow-up:

> What should every Terraform README include?

## Question 8

How does this Terraform structure support DevOps, Cloud Engineering, and SRE roles differently?

Expected themes:

- DevOps: pipeline and automation workflow
- Cloud Engineering: infrastructure standards and environment design
- SRE: reliability, safe change, drift prevention, operational clarity

Follow-up:

> Which role is most affected when Terraform structure is poor?

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the main purpose of a reusable Terraform module?

A. To store Terraform state  
B. To avoid using variables  
C. To package reusable infrastructure logic  
D. To replace Git

**Answer:** C  
**Explanation:** A module packages reusable infrastructure logic, such as a VPC or EC2 pattern.

## Question 2: Multiple Choice

Which folder is usually executed directly with Terraform commands in this class structure?

A. `modules/vpc`  
B. `environments/dev`  
C. `.git`  
D. `docs`

**Answer:** B  
**Explanation:** Environment folders act as root modules where Terraform is executed.

## Question 3: True or False

Dev and prod can use the same reusable module but pass different input values.

**Answer:** True  
**Explanation:** This is one of the main benefits of modules and `tfvars`.

## Question 4: Short Answer

Name three values that may be different between dev and prod.

**Answer:** Examples include CIDR range, tags, instance size, backup settings, region, replica count, and monitoring settings.  
**Explanation:** Environments often share structure but differ in scale, risk, and configuration.

## Question 5: Multiple Choice

What file commonly stores environment-specific Terraform variable values?

A. `outputs.tf`  
B. `main.tf`  
C. `terraform.tfvars`  
D. `.gitignore`

**Answer:** C  
**Explanation:** `terraform.tfvars` provides values for declared variables.

## Question 6: True or False

If `terraform validate` succeeds, the infrastructure design is guaranteed to be safe for production.

**Answer:** False  
**Explanation:** Validation checks syntax and configuration validity, not business safety, security review, or architecture correctness.

## Question 7: Troubleshooting Question

Prod accidentally uses the same CIDR as dev. Which file should you check first?

**Answer:** `environments/prod/terraform.tfvars`  
**Explanation:** CIDR is an environment-specific input value.

## Question 8: Troubleshooting Question

Terraform says the module source path cannot be found. What should you check?

**Answer:** Check the relative path in the module block, such as `source = "../../modules/vpc"`.  
**Explanation:** Incorrect module source paths are a common folder structure issue.

## Question 9: AWS Question

Which AWS service is used as the example resource in the reusable module?

A. Lambda  
B. VPC  
C. CloudFront  
D. RDS

**Answer:** B  
**Explanation:** The class uses a VPC module as the example reusable infrastructure pattern.

## Question 10: AWS Question

Why are AWS tags included in the Terraform examples?

A. Tags are required to run Terraform  
B. Tags help with ownership, environment identification, cost tracking, and governance  
C. Tags replace IAM permissions  
D. Tags automatically create resources

**Answer:** B  
**Explanation:** Tags are important for enterprise governance and operations.

## Question 11: Short Answer

Why should Terraform code be stored in Git?

**Answer:** Git provides version history, collaboration, review, audit trail, and rollback context.  
**Explanation:** Terraform changes should be treated like production-impacting code.

## Question 12: Multiple Choice

Which statement best describes the relationship between modules and environments?

A. Modules store environment-specific values, and environments store reusable code  
B. Modules and environments are the same thing  
C. Modules contain reusable logic, and environments call modules with specific values  
D. Environments should never use modules

**Answer:** C  
**Explanation:** This is the core design pattern of the class.

---

# 17. Homework Assignment

## Assignment Title

**Design a Terraform Repository Structure for a Multi-Environment Application**

## Scenario

Your company is onboarding a new internal application to AWS. The application will have three environments:

- `dev`
- `stage`
- `prod`

The cloud platform team wants a Terraform structure that supports reuse, review, and safe production changes.

## Student Tasks

Create a proposed Terraform repository structure that includes:

1. `modules/vpc`
2. `modules/ec2`
3. `modules/s3`
4. `environments/dev`
5. `environments/stage`
6. `environments/prod`
7. README documentation
8. A basic change review process

## Expected Deliverables

Submit:

1. Folder structure diagram.
2. Short explanation of each folder.
3. Example `terraform.tfvars` for dev.
4. Example `terraform.tfvars` for prod.
5. Explanation of how production changes should be reviewed.
6. List of values that must be different across environments.
7. Short paragraph explaining why modules are useful.

## Submission Format

Submit as one of the following:

- Markdown file
- PDF
- Git repository link
- Text document

Recommended file name:

```text
week15-class1-terraform-repo-design.md
```

## Estimated Completion Time

60 to 90 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Clear folder structure | 20 |
| Correct separation of modules and environments | 20 |
| Good examples of dev/prod values | 15 |
| Practical production review workflow | 15 |
| Clear explanation of module purpose | 10 |
| Enterprise awareness: tags, ownership, approvals, environment safety | 10 |
| Formatting and documentation quality | 10 |

## Optional Advanced Challenge

Add a `README.md` section titled:

```text
Production Change Safety Rules
```

Include at least five rules, such as:

- Production applies require approval.
- Prod must use separate state.
- Prod CIDR must be approved by networking.
- IAM changes require security review.
- All resources must include required tags.

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Putting all Terraform code in one `main.tf` | Beginner labs often start this way | Teach separation of modules and environments |
| Copying dev to prod without changing values | Students focus on folder structure but forget environment inputs | Compare `terraform.tfvars` files carefully |
| Running `terraform apply` during a structure lab | Students associate Terraform with apply | Clearly state this class is design and validation focused |
| Confusing module folder with environment folder | Both contain `.tf` files | Repeat: modules are reusable, environments are executable |
| Hardcoding values inside modules | Students do not yet understand reuse | Move environment-specific values into variables |
| Forgetting tags | Tags may seem optional to beginners | Explain cost, ownership, and governance value |
| Incorrect module source path | Relative paths can be confusing | Draw folder tree and count directory levels |
| Thinking validation means production safe | Terraform validates syntax, not architecture quality | Use review examples and bad CIDR scenario |
| Treating prod like dev | Students do not yet understand production impact | Discuss approvals, business impact, and blast radius |
| Skipping README documentation | Students focus only on code | Explain documentation as part of enterprise handoff |

---

# 19. Real-World Enterprise Scenario

## Scenario

A company has five application teams. Each team needs AWS infrastructure for dev and prod. Historically, engineers created resources manually in the AWS Console. This caused inconsistent naming, missing tags, duplicated VPC designs, and unclear ownership.

The cloud platform team decides to introduce a standard Terraform workflow.

## Constraints

- Production changes require approval.
- Every resource must include required tags.
- Networking team must approve VPC CIDR ranges.
- Security team must review IAM changes.
- Application teams can deploy dev changes faster than prod changes.
- Terraform code must be stored in Git.
- Infrastructure changes must be documented.
- Cost center tags are required for chargeback.
- Shared modules must be owned by the platform team.

## How the Class Topic Applies

The class teaches the foundation for this operating model:

- `modules/` stores reusable platform-approved infrastructure patterns.
- `environments/dev` and `environments/prod` separate risk levels.
- `terraform.tfvars` stores environment-specific values.
- Git review catches issues before changes are applied.
- README documentation explains how teams should use the repo.

## What Each Role Would Do

| Role | Responsibilities |
|---|---|
| DevOps Engineer | Integrates Terraform workflow into CI/CD and ensures application teams can deploy safely |
| Cloud Engineer | Designs modules, network patterns, IAM models, and environment structure |
| SRE | Reviews production risk, blast radius, rollback planning, and operational readiness |

---

# 20. Instructor Tips

## Teaching Tips

- Start with the problem before the solution.
- Use real examples: wrong CIDR, missing tags, accidental prod apply.
- Repeat the difference between modules and environments multiple times.
- Avoid introducing remote state too deeply in Class 1. Save that for Class 2.
- Keep the AWS resource example simple. VPC is enough.

## Pacing Tips

- Do not spend more than 15 minutes reviewing Week 14.
- Keep the whiteboard explanation visual.
- Keep the demo focused on structure.
- If students struggle, pause the lab and rebuild the folder tree together.
- If time runs short, move README completion to homework.

## Lab Support Tips

Watch for:

- Wrong folder nesting
- Incorrect module source path
- Missing variables
- Same CIDR in dev and prod
- Students running `terraform apply`
- Syntax errors in maps

## Helping Struggling Students

Use these prompts:

- “Which folder are you in right now?”
- “Are you editing the reusable module or the environment?”
- “Where should dev-specific values live?”
- “Is this value the same for prod?”
- “What does the error message say?”

## Challenging Advanced Students

Ask them to add:

- `stage` environment
- Variable validation
- Required tags validation
- `.gitignore`
- README change process
- Example merge request checklist

Suggested `.gitignore`:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
crash.log
*.tfvars.local
```

Instructor note:

> In real teams, `.terraform.lock.hcl` is often committed to pin provider versions. For beginner explanation, clarify your class standard. If you include it in `.gitignore`, explain why. If you commit it, explain provider consistency.

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- Why enterprise Terraform needs structure.
- Difference between a module and a root module.
- Why environment folders are useful.
- Why dev and prod should be separated.
- Why `terraform.tfvars` is useful.
- Why Git review matters for Terraform.
- Why validation does not guarantee production safety.
- Why copied environment values can create production risk.

## Students Should Be Able to Build or Configure

- A Terraform repo with `modules/` and `environments/`.
- A reusable VPC module.
- A dev environment folder.
- A prod environment folder.
- Separate `terraform.tfvars` files.
- Basic provider configuration.
- Basic module calls.
- README documentation for the Terraform workflow.

## Students Should Be Able to Troubleshoot

- Incorrect module source paths.
- Missing variable declarations.
- Same dev/prod CIDR values.
- Basic HCL syntax issues.
- Confusion between module code and environment configuration.
- Failed `terraform validate` caused by missing or incorrect files.

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

Verify that students understand:

- `modules/` means reusable building blocks.
- `environments/` means deployable environment configuration.
- Dev and prod can use the same module with different values.
- `terraform.tfvars` stores environment-specific values.
- Terraform code should be reviewed through Git.
- Production changes need stricter controls.
- Class 2 will introduce remote state, locking, drift, and CI/CD.

Ask students:

1. Where does reusable Terraform code live?
2. Where do dev and prod values live?
3. What is dangerous about copying dev into prod?
4. Why should Terraform changes be reviewed?

## Student Checklist Before Leaving Class

Students should have:

- Created the repo folder.
- Created `modules/vpc`.
- Created `environments/dev`.
- Created `environments/prod`.
- Added Terraform files.
- Added dev and prod `terraform.tfvars`.
- Run `terraform fmt -recursive`.
- Run `terraform validate` in dev or know how to do it.
- Written or started README documentation.
- Understood not to run `terraform apply` unless instructed.

## Items to Verify Before Moving to Class 2

Before Class 2, students should be comfortable with:

- Folder structure
- Modules
- Environment folders
- `tfvars`
- Git review concept
- Why production changes require extra safety

Class 2 will build on this by adding:

- Remote state
- S3 backend concept
- Native S3 state locking (`use_lockfile`); DynamoDB locking as legacy
- Drift detection
- Terraform plan review
- CI/CD workflow integration

---

## Class Artifacts & Validation

The on-disk, validated versions of everything taught above live in the backing lab
[`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/). This class —
*structuring Terraform with a reusable root module that calls a child module* — maps to the
**VPC root module** and its child `modules/vpc`. Run every gate at once with
`cd labs/terraform-aws-foundations && ./validate.sh` (**10 passed, 0 failed**, exit 0).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/terraform-aws-foundations/solution/main.tf | terraform | Root module that composes the reusable child module via `module "vpc" { source = "./modules/vpc" }` — the team-ready "call a module" pattern this class teaches | `terraform -chdir=solution init -backend=false && terraform -chdir=solution validate` | PASS — `Success! The configuration is valid.` |
| 2 | labs/terraform-aws-foundations/solution/modules/vpc/main.tf | terraform | The reusable child VPC module (VPC, public/private subnets, IGW, route tables, optional NAT, deny-all default SG, flow logs) — the unit of reuse | `terraform -chdir=solution/modules/vpc init -backend=false && terraform -chdir=solution/modules/vpc validate` | PASS — `Success! The configuration is valid.` |
| 3 | labs/terraform-aws-foundations/solution/variables.tf | terraform | Typed, validated input variables (`project`, `environment` constrained to dev/staging/prod, `vpc_cidr`, `az_count`) — how environments are parameterized instead of copy-pasted | covered by row 1 `terraform validate` | PASS |
| 4 | labs/terraform-aws-foundations/solution/providers.tf | terraform | Provider config with `default_tags` (Project/Environment/ManagedBy) so every resource is tagged from one place | covered by row 1 `terraform validate` | PASS |
| 5 | labs/terraform-aws-foundations/solution/versions.tf | terraform | `required_version >= 1.6` + pinned `hashicorp/aws ~> 5.0` — version discipline for a shared repo | covered by row 1 `terraform validate` | PASS |
| 6 | labs/terraform-aws-foundations/solution/terraform.tfvars.example | terraform vars | Example per-environment variable values (committed as `*.example`; real `tfvars` are git-ignored) | `terraform fmt -check -recursive solution` | PASS |
| 7 | labs/terraform-aws-foundations/validate.sh | shell | One-command gate runner (fmt + init/validate of root, vpc module, and secure-s3 example + structural tests + broken fixture + checkov) | `bash -n validate.sh` then `./validate.sh` | PASS — `== 10 passed, 0 failed ==` |
| 8 | labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt | evidence | Real AWS apply/destroy of this VPC module: `Apply complete! Resources: 19 added` then `Destroy complete! Resources: 19 destroyed`, API-verified and confirmed clean (account 071146695791, us-east-1, $0) | n/a (captured live run) | PASS — see labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt |

> The `tests/` structural suite (`python3 -m unittest discover -s tests`, `Ran 18 tests … OK`)
> additionally asserts the module structure and that the subnet CIDR offset avoids overlap.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (Terraform `.tf` for the root module and child `modules/vpc`, not just fences).
- [x] Each artifact passes its **validation gate** from §3 (`terraform fmt -check`, `init -backend=false`, `terraform validate`); output captured above and in the lab README's [Validation](../../labs/terraform-aws-foundations/README.md#validation) section.
- [x] Lab has **starter** (`starter/modules/vpc/main.tf` with 5 `TODO(student)` blocks) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent (`terraform destroy` for applied infra; `find … -name '.terraform' -prune -exec rm -rf` for local state); the live run above was destroyed clean.
- [x] **Instructor answer key** exists (README "Instructor answer key" → Lab B VPC module grading points).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* (`broken/` fixture: unindexed `aws_nat_gateway.this.id` reference that fails `terraform validate`).
- [x] **Expected outputs** are shown (README "Expected results": resource counts for default and `enable_nat_gateway=true`).
- [x] **Cost & security warnings** present (NAT ~$32/mo gated off by default; deny-all default SG; never commit `tfvars`/state).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct (Week 14 foundations → Week 15 → Week 16; capstone reuse in Weeks 23/24).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves.
