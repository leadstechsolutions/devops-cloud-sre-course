# Week 14, Class 1 Package
> **▶ Runnable lab for this class:** [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Terraform Fundamentals and First Resources

**Week:** 14
**Class:** 1
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 14.1: Terraform Fundamentals and First Resources**

## Class Purpose

This class introduces students to Terraform as an Infrastructure as Code tool. Students will learn why cloud teams use Terraform, how Terraform connects to AWS, and how to create a simple AWS resource using the standard Terraform workflow.

## How This Class Connects to the Overall Course

Students have already learned AWS foundations, IAM, VPC, EC2, S3, Linux, Git, Bash, Python, CI/CD, Docker, and Kubernetes basics. This class begins the Infrastructure as Code portion of the course.

This class prepares students for:

- Week 14 Class 2: Terraform variables, outputs, and state
- Week 15: Terraform enterprise workflows (modules, remote state, CI/CD)
- Week 19 DevSecOps: Terraform security scanning and policy-as-code
- Week 17 AWS Landing Zones: multi-account infrastructure provisioning
- Week 16 Observability and Week 21 SRE: reliable, repeatable infrastructure operations

## What Students Will Build, Analyze, or Practice

Students will:

- Create a basic Terraform project
- Configure the AWS provider
- Create a simple AWS S3 bucket
- Run `terraform init`, `fmt`, `validate`, `plan`, `apply`, and `destroy`
- Inspect Terraform state
- Troubleshoot common authentication and configuration errors

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** what Infrastructure as Code is and why Terraform is used in cloud teams.
2. **Describe** the difference between manual cloud changes and declarative infrastructure.
3. **Configure** the Terraform AWS provider.
4. **Build** a simple Terraform configuration using provider and resource blocks.
5. **Run** the standard Terraform workflow: `init`, `fmt`, `validate`, `plan`, `apply`, and `destroy`.
6. **Validate** that Terraform-created infrastructure exists in AWS.
7. **Troubleshoot** basic provider authentication, region, and resource naming errors.
8. **Document** the purpose of Terraform state and why it must be protected.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic AWS Console navigation
- Basic AWS CLI usage
- IAM user, role, and permission concepts
- S3 bucket basics
- Git repository basics
- Linux or terminal commands
- Basic file and folder structure

## Required Tools Already Installed

Students should have:

- VS Code
- Terminal or shell
- Git
- AWS CLI
- Terraform
- Browser access to AWS Console

## Required Accounts or Access

Students need:

- AWS lab account
- IAM permissions to create, list, and delete S3 buckets
- AWS CLI credentials configured locally
- Access to a default AWS region, preferably `us-east-1`

## Files, Repos, or Sample Code Needed

For this class, students can start from an empty folder.

Optional starter repo structure:

```text
terraform-week14-class1/
├── provider.tf
└── main.tf
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Infrastructure as Code | Managing infrastructure through files instead of manual console clicks | Teams review infrastructure changes the same way they review application code |
| Terraform | A tool that creates and manages infrastructure from configuration files | Used by DevOps and Cloud Engineering teams to provision cloud resources |
| Provider | A plugin that allows Terraform to communicate with a platform like AWS | The AWS provider allows Terraform to create AWS resources |
| Resource | A cloud object Terraform manages, such as an S3 bucket, EC2 instance, or VPC | A resource block defines what Terraform should create |
| State | Terraform’s record of what it manages | State helps Terraform compare desired configuration with real infrastructure |
| Plan | A preview of what Terraform will create, update, or delete | Teams review plans before allowing production infrastructure changes |
| Apply | The command that makes the planned changes | Usually restricted or approval-based in enterprise environments |
| Destroy | The command that removes Terraform-managed resources | Useful in labs, but dangerous in production |
| Declarative Code | Code that describes the desired end state | Terraform figures out the actions needed to reach that state |
| Drift | When real infrastructure no longer matches Terraform state or code | Usually caused by manual console changes |
| OpenTofu | An open-source, drop-in fork of Terraform governed by the Linux Foundation | Created after HashiCorp moved Terraform to the BSL license in 2023; some teams standardize on it instead of Terraform |
| Data Source | A read-only block that looks up existing information instead of creating a resource | Used to read the current AWS account ID, the latest AMI, or an existing VPC |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Terraform | Main tool for defining and provisioning infrastructure |
| AWS Provider | Allows Terraform to communicate with AWS APIs |
| AWS CLI | Used to validate credentials and confirm created resources |
| AWS Console | Used for visual verification of resources |
| VS Code | Used to create and edit Terraform files |
| Terminal | Used to run Terraform and AWS CLI commands |
| Git | Introduced as the place Terraform code should be stored and reviewed |

---

# 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon S3 | Used as the simple first AWS resource created with Terraform |
| AWS IAM | Required because Terraform uses AWS credentials and permissions |
| AWS STS | Used through `aws sts get-caller-identity` to validate identity |
| AWS Regions | Students must understand where Terraform creates resources |
| AWS Console | Used to confirm the S3 bucket exists |

## Cost and Security Warning

S3 is generally low-cost for this lab, but students must still delete resources after the lab. In real cloud environments, every created resource should have ownership tags, cost visibility, and cleanup expectations.

---

# 7. Azure and GCP Comparison Notes

Keep this section short during class.

| Terraform Concept | AWS | Azure | GCP |
|---|---|---|---|
| Provider | `hashicorp/aws` | `hashicorp/azurerm` | `hashicorp/google` |
| Object Storage Example | S3 bucket | Azure Storage Account and Blob Container | Cloud Storage bucket |
| Identity Used by Terraform | IAM user or role | Service principal or managed identity | Service account |
| Region Concept | AWS Region | Azure Region | GCP Region |

Instructor note:

> Terraform workflow is mostly the same across clouds. The provider changes, the resource names change, and the identity model changes.

---

# 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Welcome, class goal, and where Terraform fits in the course |
| 0:10 to 0:25 | Manual infrastructure vs Infrastructure as Code |
| 0:25 to 0:45 | Terraform overview: provider, resource, state, workflow |
| 0:45 to 1:05 | AWS provider and authentication explanation |
| 1:05 to 1:15 | Break |
| 1:15 to 1:45 | Instructor demo: create S3 bucket with Terraform |
| 1:45 to 2:20 | Student lab: create first AWS resource |
| 2:20 to 2:40 | Troubleshooting activity: authentication and resource errors |
| 2:40 to 2:50 | Discussion: why plan review matters |
| 2:50 to 3:00 | Recap, homework explanation, readiness check for Class 2 |

---

# 9. Instructor Lesson Plan

## Step 1: Open the Class

Start with a practical question:

> Last week, if you needed an S3 bucket, EC2 instance, or VPC, how would you create it?

Expected answers:

- AWS Console
- AWS CLI
- Maybe scripts
- Maybe Terraform if students have heard of it

Then explain:

> Manual work is fine for learning. But enterprise teams need infrastructure that can be reviewed, repeated, audited, and recovered. That is where Terraform comes in.

## Step 2: Connect to Previous Weeks

Remind students:

- AWS IAM controls who can create resources.
- AWS CLI proves local credentials work.
- Git stores team-reviewed code.
- Terraform uses all of these foundations.

Transition:

> Terraform is not replacing AWS knowledge. Terraform depends on AWS knowledge. If you do not understand what an S3 bucket or IAM permission is, Terraform will not hide that from you.

## Step 3: Explain Infrastructure as Code

Use simple comparison:

| Manual Console | Terraform |
|---|---|
| Clicks in browser | Configuration files |
| Hard to review | Code review possible |
| Hard to repeat | Repeatable |
| Easy to forget steps | Steps are stored as code |
| Drift is common | Drift can be detected |

Teaching tip:

Avoid saying Terraform is “automation only.” Explain that Terraform is declarative infrastructure management.

## Step 4: Introduce Terraform Core Concepts

Explain these in this order:

1. Provider
2. Resource
3. State
4. Plan
5. Apply
6. Destroy

Pause after each term and ask students for a plain-English explanation.

## Step 5: Show Basic Project Structure

Show:

```text
terraform-week14-class1/
├── provider.tf
└── main.tf
```

Explain that Terraform loads all `.tf` files in the current directory.

## Step 6: Explain AWS Authentication Before Demo

Run:

```bash
aws sts get-caller-identity
```

Explain:

> Before blaming Terraform, always confirm AWS CLI credentials work.

## Step 7: Run Instructor Demo

Perform demo slowly.

Pause at:

- After `terraform init`
- Before `terraform apply`
- After state file appears
- Before `terraform destroy`

## Step 8: Run Student Lab

Students repeat the process with their own unique bucket name.

Instructor should walk around or monitor:

- AWS credentials
- Terraform installation
- Bucket naming issues
- Region mismatch
- Missing permissions

## Step 9: Troubleshooting Activity

Give students a broken scenario before showing the fix.

Ask:

> What would you check first: Terraform file syntax, AWS credentials, or S3 bucket name?

## Step 10: Close the Class

Summarize:

- Terraform code defines desired infrastructure.
- Provider connects Terraform to AWS.
- Plan previews changes.
- Apply creates changes.
- State tracks what Terraform manages.
- Destroy cleans up resources.

Transition to Class 2:

> Next class, we make this less hardcoded by adding variables, outputs, and a better understanding of state.

---

# 10. Instructor Lecture Notes

## Opening Talking Points

“Today we are moving from manually creating cloud resources to defining cloud resources as code. This is one of the biggest shifts from basic cloud usage to real DevOps and Cloud Engineering work.”

“Terraform is used heavily because teams need predictable infrastructure delivery. If every engineer clicks through the AWS Console differently, environments become inconsistent.”

## Concept: Why Infrastructure as Code Matters

In real companies, infrastructure is not just created once. It changes constantly.

Examples:

- New dev environment
- New production environment
- New S3 bucket
- New IAM role
- New VPC
- New Kubernetes cluster
- New database subnet group
- Updated security group rule

Without IaC:

- It is hard to know who changed what.
- It is hard to recreate an environment.
- It is hard to review changes.
- It is hard to recover from accidental deletion.
- Production and non-production drift apart.

With Terraform:

- Infrastructure is defined in files.
- Changes can go through Git review.
- Teams can preview changes.
- Environments can be recreated.
- Standards can be reused.

## Concept: Terraform Is Declarative

Terraform is not like a Bash script where every line is a step.

A Bash script says:

> Do step 1, then step 2, then step 3.

Terraform says:

> This is the infrastructure I want.

Terraform then compares:

- Code
- State
- Real infrastructure

And decides what actions are needed.

## Concept: Provider

A provider is the connector between Terraform and the platform.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Instructor talking point:

> Terraform itself does not know how to create an S3 bucket. The AWS provider knows how to call AWS APIs.

## Concept: Resource

A resource block defines something Terraform manages.

Example:

```hcl
resource "aws_s3_bucket" "lab_bucket" {
  bucket = "example-bucket-name"
}
```

Explain the format:

```text
resource "<provider_resource_type>" "<local_name>" {
  arguments = values
}
```

Important:

- `aws_s3_bucket` is the resource type.
- `lab_bucket` is the Terraform local name.
- The local name is used inside Terraform code.
- It is not always the cloud resource name.

## Concept: Resource Dependencies and the Dependency Graph

This is the single most important difference between Terraform and a shell script, and it is worth demonstrating, not just asserting.

When one resource references another resource's attribute, Terraform builds an implicit dependency. Terraform reads the whole configuration, builds a **dependency graph**, and then creates resources in the correct order automatically.

Example:

```hcl
resource "aws_s3_bucket" "lab_bucket" {
  bucket = "example-unique-bucket-name"
}

resource "aws_s3_bucket_versioning" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

Talking point:

> Notice `aws_s3_bucket.lab_bucket.id`. Because the versioning resource reads the bucket's `id`, Terraform knows the bucket must exist first. We never wrote "create the bucket, then enable versioning" as steps. We described the relationship, and Terraform figured out the order. A Bash script would force you to sequence those calls by hand.

When there is no attribute to reference but an order still matters, you can declare it explicitly with `depends_on`. Prefer implicit references; reach for `depends_on` only when Terraform cannot infer the relationship.

You can inspect the graph after `init`:

```bash
terraform graph
```

## Concept: Data Sources

A **resource** creates or manages something. A **data source** only reads existing information. Data sources never change infrastructure.

Example used in today's demo:

```hcl
data "aws_caller_identity" "current" {}
```

This reads the AWS account ID, user ID, and ARN of whoever is running Terraform. We reference it the same way as a resource, but with a `data.` prefix:

```hcl
tags = {
  CreatedByAccount = data.aws_caller_identity.current.account_id
}
```

Talking point:

> Data sources are how Terraform reads the world it did not build. The most common ones a junior engineer meets first are `aws_caller_identity` (who am I?), `aws_region` (where am I?), and `aws_ami` (what is the latest base image?).

## Concept: State

State is often confusing for beginners.

Simple explanation:

> Terraform state is Terraform’s memory. It records what Terraform created and how those resources map to your code.

Common misconception:

> “If I delete the `.tf` file, the resource is deleted.”

Correction:

> No. Deleting code does not automatically delete AWS resources. Terraform needs state and a plan/apply action to manage changes.

## Concept: Plan

The plan is the safety checkpoint.

Say:

> In real companies, you do not just apply infrastructure changes blindly. You generate a plan, review it, and then apply it after approval.

## Concept: Apply

Apply makes the change.

Emphasize:

- In labs, students can apply directly.
- In production, apply is usually controlled.
- Some companies require manual approvals.
- Some use CI/CD pipelines.
- Some restrict who can apply.

## Concept: Destroy

Destroy removes resources.

Warning:

> In labs, destroy helps avoid cost. In production, destroy can cause outages.

## Concept: Terraform vs OpenTofu in 2026

Students will see two binaries in the wild, so name this early.

In 2023 HashiCorp changed Terraform's license from the open-source MPL to the Business Source License (BSL). In response, the community forked the last MPL version into **OpenTofu**, now governed by the Linux Foundation. OpenTofu is a **drop-in replacement**: the HCL syntax, the `init/plan/apply/destroy` workflow, and the AWS provider are all the same. The command is `tofu` instead of `terraform`.

Talking point:

> Everything you learn this week applies to both. If you can write Terraform, you can write OpenTofu — the language and workflow are identical. The differences are licensing, governance, and a few newer features. The practical question on a real team is just "which binary does this shop run?" If a job posting says Terraform, that almost always includes OpenTofu skills.

We teach with the `terraform` CLI in this course because it is still the most common in job postings, but mention `tofu` so students recognize it.

## Concept: Plan Before Apply (the same discipline as Helm)

Callback to Week 13:

> Remember `helm template` and `helm install --dry-run` before `helm install`? `terraform plan` before `terraform apply` is the exact same discipline: render and review the desired state before you let a tool change anything. Both Helm and Terraform are "declare the end state, then reconcile" tools. Plan/render first, apply second — every time.

## Enterprise Context

In a real platform team:

- Terraform code is stored in Git.
- Merge requests are reviewed.
- Terraform plans are posted in pipelines.
- Applies are approval-based.
- Remote state is protected.
- Manual console changes are discouraged.
- Tags are required for ownership and cost.

---

# 11. Whiteboard Explanation

## Simple Diagram

```text
Developer or Cloud Engineer
        |
        v
Terraform Code
        |
        v
terraform init
        |
        v
Terraform Provider
        |
        v
AWS API
        |
        v
AWS Resource Created
        |
        v
Terraform State Updated
```

## Step-by-Step Flow

1. Engineer writes Terraform code.
2. Terraform initializes provider plugins.
3. Terraform validates the configuration.
4. Terraform creates a plan.
5. Engineer reviews the plan.
6. Terraform applies the change.
7. AWS creates the resource.
8. Terraform records the resource in state.

## What Each Component Means

| Component | Meaning |
|---|---|
| Engineer | Person writing infrastructure code |
| Terraform Code | Desired infrastructure definition |
| Provider | Plugin that talks to AWS |
| AWS API | Interface used to create or change resources |
| AWS Resource | The actual cloud object |
| Terraform State | Terraform’s record of managed resources |

## Enterprise Version of Diagram

```text
Engineer
   |
   v
Feature Branch
   |
   v
Merge Request / Pull Request
   |
   v
Terraform fmt / validate / plan
   |
   v
Peer Review and Approval
   |
   v
Controlled terraform apply
   |
   v
AWS Infrastructure
   |
   v
Remote Terraform State
   |
   v
Audit, Monitoring, and Cost Tags
```

Instructor talking point:

> Today we are doing the local beginner version. In Week 15, we move toward the enterprise version.

---

# 12. Instructor Demo Script

## Demo Title

**Create Your First AWS Resource with Terraform**

## Demo Objective

Show students how to create, validate, inspect, and destroy an AWS S3 bucket using Terraform.

## Required Setup

Instructor must have:

- Terraform installed
- AWS CLI installed
- AWS credentials configured
- IAM permissions for S3 bucket creation and deletion
- Region selected, such as `us-east-1`

Validate before class:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

Expected AWS identity output:

```json
{
    "UserId": "AIDAEXAMPLE123456",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/training-user"
}
```

## Step 1: Create Demo Folder

```bash
mkdir terraform-week14-class1-demo
cd terraform-week14-class1-demo
```

Explain:

> Terraform works from the current folder. Keep one Terraform project in one clean directory.

Expected output:

```text
No output if the command succeeds.
```

## Step 2: Create `provider.tf`

```bash
touch provider.tf
```

Add:

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
  region = "us-east-1"
}
```

Explain:

- `required_version` controls Terraform CLI compatibility.
- `required_providers` tells Terraform which provider to download.
- `provider "aws"` sets AWS-specific configuration.

## Step 3: Create `main.tf`

```bash
touch main.tf
```

Add:

```hcl
# Read-only lookup: who is running Terraform right now?
data "aws_caller_identity" "current" {}

# The bucket itself. Note: since AWS provider v4, a bare aws_s3_bucket
# is private by default, but the security controls below are SEPARATE
# resources you must add explicitly. We add them from day one.
resource "aws_s3_bucket" "lab_bucket" {
  bucket = "terraform-week14-demo-REPLACE-WITH-UNIQUE-NAME"

  tags = {
    Name             = "week14-demo-bucket"
    Environment      = "training"
    ManagedBy        = "terraform"
    CreatedByAccount = data.aws_caller_identity.current.account_id
  }
}

# Block ALL public access. This is the single most important S3 control.
resource "aws_s3_bucket_public_access_block" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt objects at rest with SSE. SSE-S3 (AES256) requires no key setup.
resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Keep object version history so accidental overwrites/deletes are recoverable.
resource "aws_s3_bucket_versioning" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

Instructor note:

Replace the bucket name before demo. S3 bucket names must be globally unique.

Example:

```hcl
bucket = "terraform-week14-demo-jd-20260426-001"
```

Teaching point — this is the secure-by-default baseline:

> A bare `aws_s3_bucket` with nothing else is exactly the misconfiguration that shows up in breach post-mortems and that a hiring manager will flag instantly. Since AWS provider v4, public-access-block, encryption, and versioning are *separate resources* — they do not come for free. We add all three now so students never learn the insecure shape. Notice every security resource references `aws_s3_bucket.lab_bucket.id` — that is the dependency graph in action: Terraform creates the bucket first, then attaches these. This same secure pattern is reinforced in Week 19 (DevSecOps).

## Step 4: Initialize Terraform

```bash
terraform init
```

Expected output excerpt:

```text
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

Explain:

> Terraform downloaded the AWS provider. No infrastructure has been created yet.

## Step 5: Format Files

```bash
terraform fmt
```

Expected output:

```text
provider.tf
main.tf
```

or no output if already formatted.

Explain:

> Formatting keeps code consistent across teams.

## Step 6: Validate Syntax

```bash
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

Explain:

> Validation checks syntax and configuration structure. It does not guarantee AWS permissions are correct.

## Step 7: Generate Plan

```bash
terraform plan
```

Expected output excerpt:

```text
Terraform will perform the following actions:

  # aws_s3_bucket.lab_bucket will be created
  + resource "aws_s3_bucket" "lab_bucket" {
      + bucket = "terraform-week14-demo-jd-20260426-001"
      + id     = (known after apply)
      + arn    = (known after apply)
      + tags   = {
          + "CreatedByAccount" = "123456789012"
          + "Environment"      = "training"
          + "ManagedBy"        = "terraform"
          + "Name"             = "week14-demo-bucket"
        }
    }

  # aws_s3_bucket_public_access_block.lab_bucket will be created
  + resource "aws_s3_bucket_public_access_block" "lab_bucket" {
      + block_public_acls       = true
      + block_public_policy     = true
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.lab_bucket will be created
  # aws_s3_bucket_versioning.lab_bucket will be created

Plan: 4 to add, 0 to change, 0 to destroy.
```

Explain:

> This is the most important review step. The `+` symbol means "create." Terraform wants to add four resources: the bucket plus its three security controls. Later (Week 15) you will also see `~` for in-place updates and `-/+` for resources that must be destroyed and recreated — read those symbols carefully before approving any plan. The `data.aws_caller_identity.current` lookup is read-only, so it does not appear as an action; it was already resolved during the plan (that is why the account ID shows as `123456789012` and not `(known after apply)`).

## Step 8: Apply

```bash
terraform apply
```

When prompted:

```text
Do you want to perform these actions?
  Enter a value:
```

Type:

```text
yes
```

Expected output:

```text
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

Explain:

> Terraform has now called AWS and created the S3 bucket plus its three security controls, in dependency order.

## Step 9: Validate with AWS CLI

```bash
aws s3 ls | grep terraform-week14-demo
```

Expected output:

```text
2026-04-26 14:10:25 terraform-week14-demo-jd-20260426-001
```

Explain:

> This confirms the resource exists in AWS.

Optionally confirm the security controls actually applied:

```bash
aws s3api get-public-access-block --bucket terraform-week14-demo-jd-20260426-001
aws s3api get-bucket-encryption --bucket terraform-week14-demo-jd-20260426-001
```

Expected (public access fully blocked, encryption on):

```text
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

## Step 10: Show State File

```bash
ls
```

Expected output:

```text
main.tf
provider.tf
terraform.tfstate
.terraform
.terraform.lock.hcl
```

Explain:

> The state file appeared after apply. This is Terraform’s local record of the resources.

List what Terraform is tracking:

```bash
terraform state list
```

Expected output:

```text
aws_s3_bucket.lab_bucket
aws_s3_bucket_public_access_block.lab_bucket
aws_s3_bucket_server_side_encryption_configuration.lab_bucket
aws_s3_bucket_versioning.lab_bucket
```

Inspect one resource's tracked attributes:

```bash
terraform state show aws_s3_bucket.lab_bucket
```

Expected output excerpt:

```text
# aws_s3_bucket.lab_bucket:
resource "aws_s3_bucket" "lab_bucket" {
    arn                 = "arn:aws:s3:::terraform-week14-demo-jd-20260426-001"
    bucket              = "terraform-week14-demo-jd-20260426-001"
    id                  = "terraform-week14-demo-jd-20260426-001"
    region              = "us-east-1"
    tags                = {
        "CreatedByAccount" = "123456789012"
        "Environment"      = "training"
        "ManagedBy"        = "terraform"
        "Name"             = "week14-demo-bucket"
    }
}
```

Now show the raw state JSON once so the "state can contain secrets" warning becomes concrete:

```bash
terraform show -json terraform.tfstate | jq '.values.root_module.resources[0].values'
```

Or just open `terraform.tfstate` in the editor. It is plain JSON and looks like this (trimmed):

```json
{
  "version": 4,
  "terraform_version": "1.9.0",
  "resources": [
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "lab_bucket",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "arn": "arn:aws:s3:::terraform-week14-demo-jd-20260426-001",
            "bucket": "terraform-week14-demo-jd-20260426-001",
            "id": "terraform-week14-demo-jd-20260426-001",
            "tags": {
              "Environment": "training",
              "ManagedBy": "terraform"
            }
          }
        }
      ]
    }
  ]
}
```

Critical talking point:

> Every attribute Terraform reads back is stored here in plaintext. For an S3 bucket that is harmless, but for an `aws_db_instance` the state would contain the database password, and for an `aws_secretsmanager_secret_version` it would contain the secret value — in clear text. That is *why* state must be protected: never commit `terraform.tfstate` to Git, never email it, and in real teams store it in an encrypted remote backend (Week 15) with restricted access.

## Step 11: Destroy Resource

```bash
terraform destroy
```

Type:

```text
yes
```

Expected output:

```text
Destroy complete! Resources: 4 destroyed.
```

Explain:

> For labs, cleanup is required. In production, destroy must be controlled carefully. Terraform destroys in reverse dependency order — the security controls first, then the bucket last.

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `No valid credential sources found` | AWS credentials missing | Run `aws configure` or set correct profile |
| `AccessDenied` | IAM permission missing | Use account with S3 permissions |
| `BucketAlreadyExists` | S3 name is not unique | Change bucket name |
| `Invalid provider configuration` | Region missing or invalid | Set valid AWS region |
| `terraform command not found` | Terraform not installed or PATH issue | Reinstall or fix PATH |

## Demo Cleanup Steps

Confirm bucket is gone:

```bash
aws s3 ls | grep terraform-week14-demo
```

If no output appears, cleanup succeeded.

Optional local cleanup:

```bash
cd ..
rm -rf terraform-week14-class1-demo
```

---

# 13. Student Lab Manual

## Lab Title

**Create Your First AWS Resource with Terraform**

## Lab Objective

In this lab, you will create an AWS S3 bucket using Terraform, validate the deployment, inspect Terraform state, and clean up the resource.

## Estimated Time

45 to 60 minutes

## Student Prerequisites

Before starting, confirm:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

You should see valid versions and AWS identity output.

## Architecture or Workflow Overview

```text
Terraform Code
    |
    v
AWS Provider
    |
    v
AWS API
    |
    v
S3 Bucket
    |
    v
Terraform State
```

## Step 1: Create Lab Folder

```bash
mkdir terraform-week14-class1-lab
cd terraform-week14-class1-lab
```

Expected output:

```text
No output means the folder was created successfully.
```

## Step 2: Create `provider.tf`

Create the file:

```bash
touch provider.tf
```

Add this content:

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
  region = "us-east-1"
}
```

## Step 3: Create `main.tf`

Create the file:

```bash
touch main.tf
```

Add this content.

Important: replace the bucket name with something unique. You will create the bucket plus three security controls (public-access-block, encryption, versioning) — this is the secure-by-default baseline every S3 bucket should have.

```hcl
# Read-only: identify the AWS account running this configuration.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "terraform-week14-student-REPLACE-WITH-YOUR-NAME-001"

  tags = {
    Name             = "week14-student-lab-bucket"
    Environment      = "training"
    ManagedBy        = "terraform"
    CreatedByAccount = data.aws_caller_identity.current.account_id
  }
}

# Block all public access (the most important S3 control).
resource "aws_s3_bucket_public_access_block" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt objects at rest (SSE-S3 / AES256).
resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Keep version history so deletes/overwrites are recoverable.
resource "aws_s3_bucket_versioning" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

Example:

```hcl
bucket = "terraform-week14-student-jd-20260426-001"
```

## Step 4: Initialize Terraform

```bash
terraform init
```

Expected output:

```text
Terraform has been successfully initialized!
```

## Step 5: Format Terraform Files

```bash
terraform fmt
```

Expected output may show formatted files:

```text
main.tf
provider.tf
```

No output is also acceptable if files were already formatted.

## Step 6: Validate Configuration

```bash
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

## Step 7: Review Terraform Plan

```bash
terraform plan
```

Expected output should include:

```text
Plan: 4 to add, 0 to change, 0 to destroy.
```

You are adding the bucket plus its three security controls. Do not continue if the plan shows unexpected deletes (a `-` or `-/+` symbol).

## Step 8: Apply Terraform

```bash
terraform apply
```

When prompted, type:

```text
yes
```

Expected output:

```text
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

## Step 9: Validate the S3 Bucket

Use AWS CLI:

```bash
aws s3 ls | grep terraform-week14
```

Expected output:

```text
2026-04-26 14:10:25 terraform-week14-student-yourname-001
```

You can also check the AWS Console:

```text
AWS Console > S3 > Buckets
```

## Step 10: Inspect Terraform State

List files:

```bash
ls
```

Expected files:

```text
main.tf
provider.tf
terraform.tfstate
.terraform
.terraform.lock.hcl
```

Run:

```bash
terraform state list
```

Expected output:

```text
aws_s3_bucket.lab_bucket
aws_s3_bucket_public_access_block.lab_bucket
aws_s3_bucket_server_side_encryption_configuration.lab_bucket
aws_s3_bucket_versioning.lab_bucket
```

Inspect one resource in detail:

```bash
terraform state show aws_s3_bucket.lab_bucket
```

Then open `terraform.tfstate` in your editor. It is plain JSON. Find the `attributes` block and notice every value is stored in clear text.

> Security note: for this bucket the contents are harmless, but a database or secret resource would store its password here in plaintext. This is exactly why you must never commit `terraform.tfstate` to Git or submit it as homework.

## Step 11: Clean Up

Destroy the S3 bucket:

```bash
terraform destroy
```

When prompted, type:

```text
yes
```

Expected output:

```text
Destroy complete! Resources: 4 destroyed.
```

## Validation Checklist

Before finishing, confirm:

- Terraform initialized successfully.
- Terraform validation passed.
- Terraform plan showed four resources to add (bucket + 3 security controls).
- Terraform apply completed successfully.
- S3 bucket appeared in AWS.
- Public access was blocked and encryption was enabled.
- Terraform state file was created.
- All resources were destroyed successfully.

## Troubleshooting Tips

| Problem | What to Check |
|---|---|
| Terraform command not found | Terraform installation and PATH |
| AWS credentials error | `aws sts get-caller-identity` |
| Access denied | IAM permissions |
| Bucket already exists | Use a globally unique bucket name |
| Region error | Confirm provider region |
| Apply fails after partial creation | Run `terraform plan` again and inspect state |

## Reflection Questions

1. What did `terraform init` do?
2. Why did you run `terraform plan` before `terraform apply`?
3. What resource did Terraform create?
4. What is stored in Terraform state?
5. Why should you clean up lab resources?

## Optional Challenge Task

Add one more tag to the bucket:

```hcl
Owner = "your-name"
```

Then run:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Observe whether Terraform adds, changes, or deletes anything.

---

# 14. Troubleshooting Activity

## Incident Title

**Terraform Cannot Authenticate to AWS**

## Business Impact

A cloud engineer is trying to create infrastructure for a new development environment. The Terraform deployment cannot proceed, which blocks the application team from starting testing.

## Symptoms

Student runs:

```bash
terraform plan
```

and receives:

```text
Error: configuring Terraform AWS Provider: no valid credential sources for Terraform AWS Provider found.
```

or:

```text
Error: NoCredentialProviders: no valid providers in chain
```

## Starting Evidence

Commands and outputs:

```bash
aws sts get-caller-identity
```

Possible failed output:

```text
Unable to locate credentials. You can configure credentials by running "aws configure".
```

or:

```bash
aws configure list
```

Possible output:

```text
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key                <not set>             None    None
secret_key                <not set>             None    None
    region                us-east-1      config-file    ~/.aws/config
```

## Student Investigation Steps

Students should check:

1. Is AWS CLI installed?

```bash
aws --version
```

2. Is Terraform installed?

```bash
terraform version
```

3. Does AWS CLI identity work?

```bash
aws sts get-caller-identity
```

4. Is the correct profile configured?

```bash
aws configure list-profiles
```

5. If using a profile, is it exported?

```bash
export AWS_PROFILE=your-profile-name
```

6. Is the region configured?

```bash
aws configure get region
```

7. Does Terraform provider specify a valid region?

```hcl
provider "aws" {
  region = "us-east-1"
}
```

## Expected Root Cause

AWS credentials are missing, expired, or configured under a different profile than the one Terraform is using.

## Correct Resolution

Configure AWS credentials or select the correct profile.

Example:

```bash
aws configure
```

or:

```bash
export AWS_PROFILE=training
aws sts get-caller-identity
terraform plan
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Editing the S3 resource block first | The issue is authentication, not resource syntax |
| Reinstalling Terraform immediately | Terraform is working, but AWS auth is not |
| Changing the bucket name | Bucket naming is not the current error |
| Running `terraform apply` repeatedly | Apply will not work until credentials are fixed |
| Using admin credentials without approval | Bad security habit in enterprise environments |

## Instructor Hints

Start with:

> What command proves AWS credentials are working before Terraform runs?

Then guide students to:

```bash
aws sts get-caller-identity
```

## Preventive Action

- Validate AWS credentials before every lab.
- Use named AWS profiles.
- Avoid hardcoding credentials in Terraform files.
- Use IAM roles or federated access in enterprise environments.
- In pipelines, use short-lived credentials instead of static access keys.

---

# 15. Scenario-Based Discussion Questions

## Question 1

Why should a team use Terraform instead of manually creating resources in the AWS Console?

Expected themes:

- Repeatability
- Review process
- Auditability
- Reduced human error
- Environment consistency

Instructor follow-up:

> What could go wrong if dev, test, and prod are manually created by different engineers?

## Question 2

Why is `terraform plan` important in a production environment?

Expected themes:

- Preview changes
- Prevent accidental deletes
- Review with teammates
- Understand blast radius

Instructor follow-up:

> Would you allow automatic apply to production without approval?

## Question 3

What risks exist if Terraform state is lost or corrupted?

Expected themes:

- Terraform loses track of resources
- Drift becomes harder to manage
- Duplicate resources may be created
- Manual repair may be needed

Instructor follow-up:

> Why might teams use remote state instead of local state?

## Question 4

Should every engineer have permission to run `terraform destroy`?

Expected themes:

- No, not in production
- Access should be controlled
- Destructive actions require approval
- Least privilege matters

Instructor follow-up:

> How would you restrict destructive operations in a real team?

## Question 5

How does Terraform support DevOps team collaboration?

Expected themes:

- Git-based workflow
- Pull requests
- Standard modules
- Shared patterns
- Repeatable environments

Instructor follow-up:

> What should reviewers look for in a Terraform pull request?

## Question 6

What cost risks can Terraform introduce?

Expected themes:

- Easy to create resources quickly
- Forgotten resources
- Expensive services
- Duplicate environments

Instructor follow-up:

> What tags or guardrails would help control cost?

## Question 7

How is Terraform different from a Bash script that runs AWS CLI commands?

Expected themes:

- Declarative vs procedural
- State tracking
- Plan preview
- Dependency graph
- Resource lifecycle management

Instructor follow-up:

> When might a script still be useful?

## Question 8

What should happen if someone changes a Terraform-managed resource manually in the AWS Console?

Expected themes:

- This creates drift
- Team should investigate
- Terraform plan may detect it
- Manual changes should be avoided or documented

Instructor follow-up:

> Should Terraform overwrite the manual change automatically?

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the main purpose of Terraform?

A. Monitor application logs  
B. Define and manage infrastructure as code  
C. Replace all cloud providers  
D. Store application source code  

**Answer:** B  
**Explanation:** Terraform defines and manages infrastructure using configuration files.

## Question 2: Multiple Choice

Which Terraform command downloads required providers?

A. `terraform apply`  
B. `terraform destroy`  
C. `terraform init`  
D. `terraform output`  

**Answer:** C  
**Explanation:** `terraform init` initializes the working directory and downloads providers.

## Question 3: Multiple Choice

What does `terraform plan` do?

A. Deletes all infrastructure  
B. Shows proposed infrastructure changes  
C. Formats Terraform files  
D. Logs into AWS  

**Answer:** B  
**Explanation:** `plan` previews what Terraform will create, update, or delete.

## Question 4: True or False

Terraform state tracks resources managed by Terraform.

**Answer:** True  
**Explanation:** State maps Terraform configuration to real infrastructure.

## Question 5: True or False

If `terraform validate` succeeds, AWS permissions are guaranteed to be correct.

**Answer:** False  
**Explanation:** Validation checks Terraform configuration syntax, not whether AWS permissions are sufficient.

## Question 6: Short Answer

What is a Terraform provider?

**Answer:** A provider is a plugin that allows Terraform to interact with a platform such as AWS, Azure, or GCP.  
**Explanation:** The AWS provider allows Terraform to call AWS APIs.

## Question 7: Short Answer

Why must S3 bucket names be unique?

**Answer:** S3 bucket names are globally unique across AWS, so no two accounts can use the same bucket name.  
**Explanation:** A bucket name conflict causes `BucketAlreadyExists`.

## Question 8: Troubleshooting Multiple Choice

A student runs `terraform plan` and gets `No valid credential sources found`. What should they check first?

A. Whether the bucket name is unique  
B. Whether AWS credentials are configured  
C. Whether `terraform fmt` was run  
D. Whether Git is installed  

**Answer:** B  
**Explanation:** This error means Terraform cannot find valid AWS credentials.

## Question 9: Troubleshooting Short Answer

A student manually deletes a Terraform-created S3 bucket in the AWS Console. What problem does this create?

**Answer:** It creates drift between Terraform state and real AWS infrastructure.  
**Explanation:** Terraform believes it manages a resource that may no longer exist.

## Question 10: AWS-Related Multiple Choice

Which AWS command validates the identity Terraform is likely using locally?

A. `aws s3 ls`  
B. `aws iam list-users`  
C. `aws sts get-caller-identity`  
D. `aws configure reset`  

**Answer:** C  
**Explanation:** `aws sts get-caller-identity` confirms the current AWS caller identity.

## Question 11: Multiple Choice

Which command removes Terraform-managed resources?

A. `terraform delete`  
B. `terraform destroy`  
C. `terraform remove`  
D. `terraform clean`  

**Answer:** B  
**Explanation:** `terraform destroy` removes resources managed by the current Terraform state.

## Question 12: True or False

In enterprise environments, Terraform code is commonly reviewed through pull requests or merge requests.

**Answer:** True  
**Explanation:** Git-based review helps teams approve and audit infrastructure changes.

---

# 17. Homework Assignment

## Assignment Title

**Terraform Workflow Reflection and First Configuration Submission**

## Scenario

You joined a cloud platform team that is beginning to move away from manually creating AWS resources. Your team lead asks you to create a simple Terraform configuration and document the workflow so other junior engineers can understand it.

## Student Tasks

Students must:

1. Create a Terraform folder named:

```text
terraform-week14-homework
```

2. Create:

```text
provider.tf
main.tf
```

3. Configure the AWS provider for `us-east-1`.

4. Define one S3 bucket with tags:

```hcl
Environment = "training"
ManagedBy   = "terraform"
Owner       = "your-name"
```

   And add the three secure-by-default companion resources (as in the lab):
   - `aws_s3_bucket_public_access_block`
   - `aws_s3_bucket_server_side_encryption_configuration`
   - `aws_s3_bucket_versioning`

5. Run:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

6. Do not submit AWS credentials or sensitive files.

7. Answer the following:

```text
1. What problem does Terraform solve?
2. What does terraform init do?
3. Why should terraform plan be reviewed before apply?
4. What is Terraform state?
5. Why should Terraform code be stored in Git?
```

## Expected Deliverables

Students submit:

- `provider.tf`
- `main.tf`
- Screenshot or copied output of:
  - `terraform validate`
  - `terraform plan`
- Written answers to the five questions
- Confirmation that any created resources were destroyed

## Submission Format

Submit as one of the following:

- Git repository link
- Zip file without `.terraform/` folder
- Markdown document with code snippets and command output

Do not submit:

```text
.aws credentials
terraform.tfstate
terraform.tfstate.backup
.terraform folder
```

## Estimated Completion Time

60 to 90 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Correct provider configuration | 15 |
| Valid S3 bucket resource | 15 |
| Secure-by-default controls (public-access-block + SSE + versioning) | 20 |
| Proper Terraform workflow output | 15 |
| Tags included | 10 |
| Written explanations are clear | 15 |
| Cleanup confirmation | 10 |

## Optional Advanced Challenge

Add a `versions.tf` file and move the Terraform required provider configuration into it.

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Forgetting to run `terraform init` | Students try to plan before providers are downloaded | Always run `init` first in a new Terraform folder |
| Using a non-unique S3 bucket name | Students do not know S3 names are global | Add initials, date, or random suffix |
| Missing AWS credentials | AWS CLI was not configured | Run `aws sts get-caller-identity` before Terraform |
| Wrong AWS profile | Multiple profiles exist locally | Set `AWS_PROFILE` explicitly |
| Invalid HCL syntax | Missing quote, bracket, or equals sign | Use `terraform fmt` and `terraform validate` |
| Confusing resource local name with AWS name | Terraform syntax is new | Explain `aws_s3_bucket.lab_bucket` vs actual bucket name |
| Forgetting cleanup | Students focus on creation only | Add cleanup as required lab step |
| Uploading state files to homework | Students do not know state can be sensitive | Warn students not to submit state files |
| Running commands from wrong directory | Terraform cannot find `.tf` files | Always `cd` into project folder |
| Assuming validate checks AWS permissions | Misunderstanding validation | Explain validate checks configuration, not access |

---

# 19. Real-World Enterprise Scenario

## Scenario

A company has multiple application teams creating cloud resources manually in AWS. Each team creates S3 buckets, security groups, IAM roles, and EC2 instances differently. Some resources are missing tags. Some resources are not documented. A few production resources were changed manually, and nobody knows exactly what changed.

Leadership asks the cloud platform team to standardize infrastructure delivery.

## How This Class Topic Applies

Terraform provides a way to:

- Store infrastructure definitions in Git
- Review changes before applying them
- Reuse standard patterns
- Apply consistent tags
- Reduce manual console drift
- Improve auditability
- Recreate environments if needed

## Enterprise Constraints

| Constraint | Example |
|---|---|
| Access control | Not everyone can apply Terraform to production |
| Approvals | Production plans require review |
| Cost | Every resource must have owner and environment tags |
| Security | Credentials cannot be hardcoded |
| Reliability | Manual changes can cause outages |
| Audit | Teams must know who changed infrastructure and when |

## Role-Based Responsibilities

### DevOps Engineer

- Adds Terraform checks to CI/CD
- Helps app teams provision infrastructure through pipelines
- Reviews Terraform plans during deployment workflows

### Cloud Engineer

- Builds reusable Terraform infrastructure patterns
- Defines AWS provider standards
- Ensures networking, IAM, and tagging are correct

### SRE

- Uses Terraform-managed infrastructure for reliable operations
- Detects drift that may affect production
- Ensures infrastructure changes support observability and recovery

---

# 20. Instructor Tips

## Teaching Tips

- Start with manual AWS Console pain points before introducing Terraform.
- Use S3 first because it is simpler than VPC or EC2.
- Do not introduce modules in Class 1.
- Do not go too deep into remote state yet.
- Repeat the phrase: “Plan before apply.”
- Explain state carefully and more than once.

## Pacing Tips

- Keep concept lecture under 45 minutes.
- Spend more time on demo and lab.
- Leave at least 20 minutes for troubleshooting.
- Do not rush `terraform plan`. This is the most important habit.

## Lab Support Tips

When students are stuck, ask:

1. What folder are you in?
2. Did `terraform init` succeed?
3. Did `terraform validate` succeed?
4. Does `aws sts get-caller-identity` work?
5. Is the bucket name unique?
6. What does the exact error say?

## Helping Struggling Students

For students new to CLI:

- Pair them with a stronger student.
- Give them the exact folder structure.
- Have them copy one file at a time.
- Ask them to run commands slowly and paste output.

## Challenging Advanced Students

Ask advanced students to:

- Add a `versions.tf` file
- Add more tags
- Explain why local state is risky
- Compare Terraform with AWS CloudFormation
- Add Git tracking with `.gitignore`

Recommended `.gitignore` discussion:

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
```

Instructor note: In many real Terraform repos, `.terraform.lock.hcl` is committed. For beginner labs, discuss it but do not overcomplicate. In enterprise practice, provider lock files are often committed for consistent provider versions.

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- What Infrastructure as Code means
- Why Terraform is used
- What a provider is
- What a resource is
- What Terraform state is
- What `terraform plan` does
- Why blindly applying changes is risky
- Why Terraform code should be stored in Git

## Students Should Be Able to Build or Configure

- A basic Terraform project folder
- An AWS provider configuration
- A simple S3 bucket resource
- Basic resource tags
- A successful Terraform workflow

## Students Should Be Able to Troubleshoot

- Missing Terraform installation
- Missing AWS credentials
- Wrong AWS profile
- Invalid region
- Invalid Terraform syntax
- Duplicate S3 bucket name
- Basic state awareness issues

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

Confirm that students understand:

- Terraform is declarative.
- Provider connects Terraform to AWS.
- Resource blocks define cloud resources.
- State tracks managed resources.
- Plan must be reviewed before apply.
- Destroy removes resources and must be used carefully.

Confirm students have practiced:

- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- `terraform destroy`
- `aws sts get-caller-identity`
- `terraform state list`

## Student Checklist Before Leaving Class

Students should confirm:

```text
[ ] I created a Terraform project folder.
[ ] I created provider.tf.
[ ] I created main.tf.
[ ] I ran terraform init successfully.
[ ] I ran terraform validate successfully.
[ ] I reviewed terraform plan.
[ ] I created an S3 bucket using terraform apply.
[ ] I validated the bucket in AWS.
[ ] I inspected Terraform state.
[ ] I destroyed the bucket.
[ ] I understand the homework assignment.
```

## Items to Verify Before Moving to Class 2

Before Class 2, students should be comfortable with:

- Terraform project folder structure
- Provider block
- Resource block
- Terraform workflow commands
- AWS CLI identity check
- Basic meaning of state
- Basic troubleshooting of AWS authentication

Class 2 will build on this by introducing:

- Variables
- `terraform.tfvars`
- Outputs
- Better file organization
- Deeper state discussion
- Reusable Terraform patterns

## Class Artifacts & Validation

This class is backed by the **`labs/terraform-aws-foundations`** module. Class 01 (Terraform
fundamentals + your first AWS resource) maps to the on-disk, validated **secure-S3 example**
(`solution/examples/secure-s3/`) — the secure-by-default S3 bucket the lecture and lab build,
hardened to a senior baseline. All gates below are **plan-free** (no `terraform apply`, $0) and
were run in this environment via `./validate.sh` (`10 passed, 0 failed`, exit 0).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/terraform-aws-foundations/solution/examples/secure-s3/main.tf` | terraform | Secure S3 bucket: public-access-block (4 flags), SSE-KMS w/ customer-managed key, versioning, deny-non-TLS/deny-unencrypted bucket policy, multipart-abort lifecycle, access logging, EventBridge notifications | `terraform -chdir=solution/examples/secure-s3 init -backend=false && terraform -chdir=solution/examples/secure-s3 validate` | PASS — `Success! The configuration is valid.` |
| 2 | `labs/terraform-aws-foundations/solution/examples/secure-s3/variables.tf` | terraform | `bucket_name` variable with two validation blocks (length 3–63 + DNS-shape regex) — fail-fast at plan time | `terraform -chdir=solution/examples/secure-s3 validate` | PASS |
| 3 | `labs/terraform-aws-foundations/solution/examples/secure-s3/outputs.tf` | terraform | `bucket_arn` / `kms_key_arn` outputs marked `sensitive` so they are not echoed into CI logs | `terraform -chdir=solution/examples/secure-s3 validate` | PASS |
| 4 | `labs/terraform-aws-foundations/starter/examples/secure-s3/main.tf` | terraform | Starter with the six security controls left as `TODO(student)` — the Lab A worksheet | `checkov -d starter/examples/secure-s3 --compact --quiet --framework terraform` | PASS (negative gate — **fails by design**: `Failed checks: 7` until the TODOs are done) |
| 5 | `labs/terraform-aws-foundations/solution/examples/secure-s3/` (whole dir) | terraform | IaC security scan of the finished example | `checkov -d solution/examples/secure-s3 --compact --quiet --framework terraform` | PASS — `Passed: 46, Failed: 0, Skipped: 3` (3 documented teaching skips) |
| 6 | `labs/terraform-aws-foundations/broken/main.tf` | terraform | Troubleshooting fixture — one reproducible defect (`aws_nat_gateway.this.id` without `[0]` index) that MUST fail validate | `terraform -chdir=broken init -backend=false && terraform -chdir=broken validate` | PASS (negative gate — **fails by design**: `Error: Missing resource instance key`) |
| 7 | `labs/terraform-aws-foundations/tests/test_terraform_structure.py` | python | Stdlib structural tests (incl. `SecureS3Example` asserting the controls, the sensitive output, and that the starter TODOs are present) | `python3 -m unittest discover -s tests` | PASS — `Ran 18 tests ... OK` |
| 8 | `labs/terraform-aws-foundations/validate.sh` | bash | Single entrypoint running all 10 gates above | `./validate.sh` | PASS — `10 passed, 0 failed` (exit 0) |

> **Live-apply note:** The secure-S3 example itself was **not** applied to a real account here
> (it would create billable KMS/S3 resources). The companion VPC module in the same lab *was*
> applied to and destroyed from a real AWS account — see `labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt`
> (used by **Class 02**). The secure-S3 gates above are static-validate only.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (the secure-S3 `*.tf` under `solution/examples/secure-s3/`, not just fences).
- [x] Each artifact passes (or documents) its **validation gate** from §3 — `terraform fmt -check` + `init -backend=false` + `validate` all green; `checkov` clean (46/0/3); output captured above and in the lab README's Validation section.
- [x] Lab has **starter** (`starter/examples/secure-s3/` with six `TODO(student)` controls) and **solution** (`solution/examples/secure-s3/`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent — local `.terraform`/state cleanup, plus `terraform destroy` (with `force_destroy` guidance for the versioned bucket) for anyone who applies.
- [x] **Instructor answer key** exists for Lab A (secure S3), the homework, the quiz, and the troubleshooting exercise (lab README "Instructor answer key" + this class file's quiz/assignment keys).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `broken/` fixture that fails `terraform validate` with `Missing resource instance key`.
- [x] **Expected outputs** are shown for the demo and lab (`Success! The configuration is valid.`, `checkov` Passed/Failed/Skipped counts).
- [x] **Cost & security warnings** present — KMS ~$1/mo once applied, empty buckets free; deny-non-TLS policy, SSE-KMS, sensitive outputs, never-commit-state notes.
- [x] **Cross-references** to the module repo and to Class 02 / Weeks 15, 19, 23–24 are correct.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (verified with `ls`).
