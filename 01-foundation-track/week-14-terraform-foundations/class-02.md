# Week 14, Class 2 Package
> **▶ Runnable lab for this class:** [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Terraform Variables, Outputs, and State

**Week:** 14
**Class:** 2
**Track:** Unified DevOps · Cloud · SRE Track

---

# 1. Class Overview

## Class Title

**Class 14.2: Terraform Variables, Outputs, and State**

## Class Purpose

This class expands the Terraform foundation from Class 1 by teaching students how to make Terraform code more reusable, organized, and team-friendly using variables, `terraform.tfvars`, outputs, and a deeper understanding of Terraform state.

## How This Class Builds From Class 1

In Class 1, students created a simple AWS S3 bucket using hardcoded Terraform values. They practiced:

- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- `terraform destroy`
- Basic AWS provider configuration
- Basic Terraform state awareness

Class 2 takes that same basic idea and improves it by replacing hardcoded values with variables, exposing useful information through outputs, and explaining how Terraform state supports ongoing infrastructure management.

## What Students Will Build, Analyze, or Practice

Students will:

- Refactor a simple Terraform configuration into multiple files
- Use variables for region, environment, bucket prefix, and owner
- Use `terraform.tfvars` to provide values
- Use outputs to display useful infrastructure information
- Use a random suffix to avoid S3 bucket name conflicts
- Inspect Terraform state more intentionally
- Troubleshoot missing variable values, duplicate names, provider issues, and drift caused by manual console changes

---

# 2. Quick Review of Class 1

## Review Points

1. Terraform is used to define and manage infrastructure as code.
2. The AWS provider allows Terraform to communicate with AWS APIs.
3. A Terraform resource block defines something Terraform manages.
4. `terraform init` initializes the working directory and downloads providers.
5. `terraform plan` previews what Terraform will create, change, or destroy.
6. `terraform apply` creates or changes infrastructure.
7. Terraform state tracks resources Terraform manages.
8. `terraform destroy` removes Terraform-managed resources and must be used carefully.

## Quick Recall Questions

1. What command should you run before using `terraform plan` in a new Terraform folder?  
   **Expected answer:** `terraform init`

2. What does `terraform plan` show you?  
   **Expected answer:** The proposed changes Terraform will make.

3. Why must S3 bucket names be unique?  
   **Expected answer:** S3 bucket names are globally unique across AWS.

## Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students think `validate` checks AWS permissions | Clarify that `validate` checks Terraform syntax and configuration structure, not live AWS permissions |
| Students confuse Terraform local resource name with AWS resource name | Re-explain `aws_s3_bucket.lab_bucket` versus the actual bucket name |
| Students forget to validate AWS credentials first | Reinforce `aws sts get-caller-identity` |
| Students do not fully understand state | Use today’s class to explain state as Terraform’s mapping between code and real resources |
| Students forget cleanup | Make destroy part of the lab validation checklist |

## Bridge Into Class 2

Instructor transition:

> In Class 1, we wrote Terraform that worked, but it was hardcoded. In real teams, hardcoded infrastructure code does not scale. Today we make Terraform reusable using variables, `terraform.tfvars`, and outputs. We will also look more carefully at state, because state is what allows Terraform to manage infrastructure over time.

---

# 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** why variables make Terraform code reusable.
2. **Configure** Terraform variables with types, descriptions, and default values.
3. **Use** `terraform.tfvars` to provide environment-specific values.
4. **Build** a reusable Terraform configuration split across multiple files.
5. **Create** Terraform outputs to display useful infrastructure information.
6. **Validate** Terraform-created resources using outputs, AWS CLI, and AWS Console.
7. **Troubleshoot** missing variables, duplicate S3 bucket names, provider authentication issues, and drift.
8. **Document** why Terraform state should be protected in team and enterprise environments.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 Knowledge

Students should already know:

- What Terraform is
- What the AWS provider does
- What a resource block is
- How to run the basic Terraform workflow
- Why `terraform plan` matters
- Basic meaning of Terraform state
- How to create and destroy a simple S3 bucket

## Required Prior Concepts

Students should understand:

- AWS CLI identity validation
- Basic S3 bucket behavior
- Basic IAM permissions
- Basic terminal navigation
- Basic file editing in VS Code
- Basic Git concepts

## Required Tools Already Installed

Students need:

- Terraform
- AWS CLI
- VS Code
- Terminal
- Git
- Browser access to AWS Console

## Required Files, Repos, Lab Outputs, or Setup From Class 1

Students do not need to reuse the exact Class 1 folder, but they should have successfully completed Class 1.

Recommended starting folder:

```text
terraform-week14-class2/
```

Students should validate access before starting:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

---

# 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Variable | A named input value used by Terraform code | Allows the same Terraform code to work for dev, test, and prod |
| Default Value | A fallback value used when no other value is provided | Useful for safe training defaults, but production values are often explicit |
| `terraform.tfvars` | A file used to provide values for variables | Teams use tfvars files to separate environment-specific values |
| Output | A value Terraform displays after apply | Useful for showing bucket names, IPs, URLs, or IDs |
| Local State | Terraform state stored on the local machine | Fine for beginner labs, risky for teams |
| Remote State | Terraform state stored in a shared backend | Used by teams for collaboration and state protection |
| Drift | When real infrastructure does not match Terraform code or state | Often caused by manual AWS Console changes |
| Type Constraint | A rule that defines what type of value a variable accepts | Helps prevent bad inputs |
| Tag | Metadata attached to a cloud resource | Used for ownership, cost, environment, and governance |
| Reusability | Designing code so it can be used multiple times with different inputs | A core goal of enterprise Terraform modules and patterns |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Terraform | Main IaC tool used to create and manage infrastructure |
| AWS Provider | Allows Terraform to interact with AWS |
| Random Provider | Generates a random suffix to avoid duplicate S3 bucket names |
| AWS CLI | Validates AWS identity and confirms resources |
| AWS Console | Allows visual confirmation of created resources |
| VS Code | Used to write and organize Terraform files |
| Terminal | Used to run Terraform and AWS CLI commands |
| Git | Discussed as the place Terraform code should be stored and reviewed |

---

# 7. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon S3 | Used as the primary resource created with reusable Terraform |
| AWS IAM | Controls whether Terraform can create, list, tag, and delete resources |
| AWS STS | Used to confirm the active AWS identity |
| AWS Regions | Used as a variable to make provider configuration reusable |
| AWS Resource Tags | Used to show enterprise ownership, environment, and governance metadata |

## Cost and Security Warning

This lab uses S3, which is usually low-cost, but students must still destroy resources after the lab. Students should not upload sensitive data to the lab bucket. Students should not submit `terraform.tfstate` files as homework because state can contain sensitive infrastructure data.

---

# 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Provider | `hashicorp/aws` | `hashicorp/azurerm` | `hashicorp/google` |
| Object storage | S3 bucket | Storage Account and Blob Container | Cloud Storage bucket |
| Variable usage | Same Terraform concept | Same Terraform concept | Same Terraform concept |
| State storage option | S3 backend | Azure Storage backend | GCS backend |
| Identity for Terraform | IAM user or role | Service principal or managed identity | Service account |

Instructor note:

> The Terraform workflow is consistent across clouds. What changes are the provider, resource types, identity model, and backend options.

---

# 9. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:15 | Quick review of Class 1 and bridge into reusable Terraform |
| 0:15 to 0:40 | Teach variables, types, defaults, and `terraform.tfvars` |
| 0:40 to 1:00 | Teach outputs and how teams use them |
| 1:00 to 1:10 | Short break |
| 1:10 to 1:35 | Deeper explanation of Terraform state and drift |
| 1:35 to 2:05 | Instructor demo: reusable S3 bucket configuration with variables and outputs |
| 2:05 to 2:40 | Student lab: build reusable Terraform component |
| 2:40 to 2:55 | Troubleshooting activity: missing variable, duplicate bucket, state drift |
| 2:55 to 3:00 | Recap, homework explanation, and Week 15 preview |

---

# 10. Instructor Lesson Plan

## Step 1: Start With Class 1 Review

Ask students:

> Last class, what did we hardcode in our Terraform files?

Expected answers:

- Region
- S3 bucket name
- Tags
- Environment name

Transition:

> Hardcoding is acceptable for a first lab. But real Terraform must support different environments, owners, regions, and naming standards. That is why we use variables.

## Step 2: Introduce Variables

Explain:

> A variable is an input. Instead of writing the value directly into the resource, we define a variable and let the value come from another place.

Show:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

Then show usage:

```hcl
Environment = var.environment
```

Pause and ask:

> What would happen if we wanted this same code for test or prod?

Expected answer:

> We could change the variable value instead of rewriting the resource.

## Step 3: Explain `terraform.tfvars`

Explain:

> `variables.tf` defines what inputs exist. `terraform.tfvars` provides the actual values.

Use a simple analogy:

- `variables.tf` is the form.
- `terraform.tfvars` is the completed form.

Show:

```hcl
environment   = "dev"
bucket_prefix = "terraform-week14"
owner         = "student"
```

## Step 4: Explain Outputs

Explain:

> Outputs are Terraform’s way of showing important information after apply.

Examples:

- Bucket name
- Load balancer DNS name
- EC2 instance public IP
- VPC ID
- Subnet IDs

Show:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.lab_bucket.bucket
}
```

## Step 5: Explain State More Deeply

Keep it beginner-friendly:

> Terraform state is not just a log. It is Terraform’s active mapping between your code and real resources.

Explain that state helps Terraform answer:

- What did I create?
- What is the resource ID?
- What changed?
- What should I update?
- What should I destroy?

Warn:

> Do not edit state manually as a beginner. Do not email state files. Do not upload state files in assignments.

## Step 6: Demonstrate File Organization

Show target folder:

```text
terraform-week14-class2/
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
└── outputs.tf
```

Explain each file:

| File | Purpose |
|---|---|
| `versions.tf` | Terraform and provider version requirements |
| `provider.tf` | AWS provider configuration |
| `variables.tf` | Input variable definitions |
| `terraform.tfvars` | Input values |
| `main.tf` | Resource definitions |
| `outputs.tf` | Useful values displayed after apply |

## Step 7: Run Demo

Build the reusable S3 configuration step by step.

Pause after:

- Creating `variables.tf`
- Creating `terraform.tfvars`
- Running `terraform plan`
- Running `terraform output`
- Showing state list

## Step 8: Student Lab

Students build the same pattern with their own values.

Instructor should support:

- Syntax issues
- Missing variables
- Bucket name conflicts
- Provider issues
- Cleanup validation

## Step 9: Troubleshooting Activity

Introduce three failures:

1. Missing variable value
2. Duplicate bucket name
3. Manual deletion causing drift

Ask students to identify the likely root cause based on the error message.

## Step 10: Close the Week

Summarize:

> Class 1 taught us how Terraform creates infrastructure. Class 2 taught us how to make Terraform reusable and more team-friendly. Next week, we move from local beginner usage into enterprise Terraform workflows, including environment folders, remote state concepts, plan review, and CI/CD integration.

---

# 11. Instructor Lecture Notes

## Opening Notes

“Last class, we created an S3 bucket using Terraform. That was our first step. But the configuration was not reusable. It had hardcoded values. Today we will improve that design.”

“In real teams, Terraform should not be written as one-off code. It should be reusable, readable, reviewable, and safe.”

## Concept: Why Variables Matter

Hardcoded Terraform is difficult to reuse.

Example hardcoded value:

```hcl
bucket = "terraform-week14-demo-jd-001"
```

That works once, but what if:

- Another student needs a different name?
- The environment changes from dev to prod?
- The region changes?
- The owner changes?
- A pipeline needs to pass values dynamically?

Variables solve this by separating logic from values.

Instructor talking point:

> Good Terraform code should describe the pattern. Variables provide the environment-specific details.

## Concept: Variable Definition

A variable usually has:

- Name
- Description
- Type
- Optional default

Example:

```hcl
variable "environment" {
  description = "Environment name such as dev, test, or prod"
  type        = string
  default     = "dev"
}
```

Explain:

- `description` helps humans understand the input.
- `type` helps Terraform validate expected data.
- `default` makes the variable optional.
- No default means the value must be provided.

## Concept: Variable Types Beyond String

Most real configurations need more than strings. Teach these four shapes:

```hcl
variable "enable_versioning" {
  type    = bool
  default = true
}

variable "allowed_envs" {
  type    = list(string)
  default = ["dev", "test", "prod"]
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "bucket_config" {
  type = object({
    force_destroy = bool
    sse_algorithm = string
  })
  default = {
    force_destroy = false
    sse_algorithm = "AES256"
  }
}
```

Talking points:

> `bool` is a true/false switch. `list(string)` is an ordered set of values. `map(string)` is a set of key/value pairs — perfect for tags. `object({...})` is a structured record where each field has its own type, which is how you pass a whole bundle of related settings as one variable.

> You combine maps with the built-in `merge()` function. In today's demo, `merge({...standard tags...}, var.extra_tags)` produces one tag map: the standard tags plus whatever the caller added. This is the most common real-world use of a map variable.

A teaser for next week: `for_each` and `for` expressions iterate over lists and maps to create many resources from one block. We do not build that today, but mention it exists — it is built on exactly these complex types.

## Concept: Type Validation

A `validation` block lets a variable reject bad input before any AWS call:

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}
```

Talking point:

> This fails fast at plan time with a clear message instead of creating a mis-tagged resource. Type constraints plus validation are how you make a reusable component safe for other teams to call.

## Concept: Sensitive Outputs

Outputs print to the terminal, to CI logs, and to pull-request comments. Anything secret must be marked:

```hcl
output "db_password" {
  value     = aws_db_instance.example.password
  sensitive = true
}
```

Talking points:

> With `sensitive = true`, `terraform output` shows `<sensitive>` instead of the value, and the value is masked in apply output and CI logs. You can still read one on purpose with `terraform output db_password`.

> Two warnings. First, `sensitive` only controls *display* — the value is still stored in plaintext in the state file, which is why state must be protected regardless. Second, the matching helper `nonsensitive()` exists to strip the flag inside an expression, but use it rarely and deliberately.

## Concept: `terraform.tfvars`

A `terraform.tfvars` file is commonly used to provide values.

Example:

```hcl
aws_region    = "us-east-1"
environment   = "dev"
bucket_prefix = "terraform-week14"
owner         = "student"
```

Real-world connection:

> In enterprise repos, teams may have separate tfvars files for dev, test, stage, and prod.

Example:

```text
dev.tfvars
test.tfvars
prod.tfvars
```

Students do not need to implement this yet. That comes in Week 15.

## Concept: Outputs

Outputs make useful information visible after Terraform applies changes.

Examples:

- S3 bucket name
- EC2 public IP
- Load balancer DNS name
- VPC ID
- Database endpoint

Instructor talking point:

> Outputs are especially useful when one team creates infrastructure and another team needs to consume the result.

Example:

```hcl
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.bucket
}
```

## Concept: State

Terraform state is one of the most important concepts in Terraform.

State tracks:

- Resource type
- Resource name
- Provider
- Resource ID
- Attributes
- Dependencies

Beginner-friendly explanation:

> Terraform state is the map between your `.tf` files and the real AWS resources.

Common misconception:

> “If I can see the resource in AWS, Terraform will automatically know about it.”

Correction:

> Terraform manages resources it knows about through state. Existing resources must be imported (`terraform import`, covered in Week 15) or defined and tracked properly. Just seeing a resource in the console does not put it under Terraform's management.

Show the state file once so the warning is concrete. `terraform.tfstate` is plain JSON:

```json
{
  "version": 4,
  "terraform_version": "1.9.0",
  "outputs": {
    "bucket_name": {
      "value": "terraform-week14-demo-dev-a1b2c3d4",
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "aws_s3_bucket",
      "name": "lab_bucket",
      "instances": [
        { "attributes": { "id": "terraform-week14-demo-dev-a1b2c3d4" } }
      ]
    }
  ]
}
```

Core state commands students should know:

```bash
terraform state list                       # what is tracked
terraform state show aws_s3_bucket.lab_bucket   # one resource's attributes
terraform show -json | jq .                 # full state as JSON
```

Critical talking point:

> Every attribute is stored in clear text — including database passwords, tokens, and any output you marked `sensitive`. `sensitive` hides values in console output, not in state. That is exactly why you never commit `terraform.tfstate`, never email it, and in real teams store it in an encrypted, access-controlled remote backend (Week 15).

## Concept: Drift

Drift means the real infrastructure changed outside Terraform.

Example:

1. Terraform creates an S3 bucket.
2. Someone manually changes tags in AWS Console.
3. Terraform code still expects the original tags.
4. The next `terraform plan` may show a change.

Instructor talking point:

> Drift is one reason enterprise teams discourage manual console changes.

## Enterprise Context

In a real enterprise workflow:

- Variables standardize inputs.
- Outputs expose useful information.
- Tags support cost and ownership.
- State is stored remotely.
- State access is restricted.
- Infrastructure changes go through Git review.
- Production applies require approval.
- Manual changes create drift and operational risk.

---

# 12. Whiteboard Explanation

## Class 1 to Class 2 Progression

```text
Class 1:
Hardcoded Terraform
        |
        v
One S3 bucket
        |
        v
Local state


Class 2:
Reusable Terraform
        |
        v
Variables + tfvars
        |
        v
S3 bucket with standard tags
        |
        v
Outputs
        |
        v
Better state understanding
```

## Simple Diagram

```text
variables.tf
Defines allowed inputs
        |
        v
terraform.tfvars
Provides actual values
        |
        v
main.tf
Uses var.environment, var.owner, var.bucket_prefix
        |
        v
terraform plan/apply
        |
        v
AWS S3 bucket
        |
        v
outputs.tf
Displays useful results
        |
        v
terraform.tfstate
Tracks created resource
```

## Step-by-Step Flow

1. Instructor defines variables in `variables.tf`.
2. Student provides values in `terraform.tfvars`.
3. `main.tf` uses those values with `var.<name>`.
4. Terraform creates an AWS S3 bucket.
5. Outputs display the bucket name and environment.
6. Terraform state records the created bucket.
7. Future plans compare code, state, and AWS.

## What Each Component Means

| Component | Meaning |
|---|---|
| `variables.tf` | Defines expected inputs |
| `terraform.tfvars` | Supplies values |
| `main.tf` | Defines resources |
| `outputs.tf` | Shows useful results |
| `terraform.tfstate` | Tracks infrastructure Terraform manages |
| AWS S3 | The actual cloud resource created |

## Real-World Enterprise Version

```text
Application Team Request
        |
        v
Reusable Terraform Module
        |
        v
Environment Values
dev.tfvars / test.tfvars / prod.tfvars
        |
        v
Terraform Plan in CI/CD
        |
        v
Review and Approval
        |
        v
Terraform Apply
        |
        v
AWS Infrastructure
        |
        v
Remote State Backend
        |
        v
Outputs consumed by apps, pipelines, or documentation
```

Instructor talking point:

> Today we are not building full modules yet, but variables and outputs are the foundation of reusable modules.

---

# 13. Instructor Demo Script

## Demo Title

**Create a Reusable S3 Bucket Configuration with Variables and Outputs**

## Demo Objective

Show students how to refactor hardcoded Terraform into a reusable configuration using variables, `terraform.tfvars`, outputs, and state inspection.

## Required Setup

Instructor must have:

- Terraform installed
- AWS CLI installed
- AWS credentials configured
- Permission to create and delete S3 buckets
- Empty demo directory

Validate:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

Expected output from identity check:

```json
{
  "UserId": "AIDAEXAMPLE123456",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/training-user"
}
```

## Step 1: Create Project Folder

```bash
mkdir terraform-week14-class2-demo
cd terraform-week14-class2-demo
```

Explain:

> We are creating a clean Terraform project with multiple files, like a real repository would have.

## Step 2: Create `versions.tf`

```bash
touch versions.tf
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

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

Explain:

> Today we use both the AWS provider and the random provider. The random provider helps us create a unique suffix for the S3 bucket name.

## Step 3: Create `provider.tf`

```bash
touch provider.tf
```

Add:

```hcl
provider "aws" {
  region = var.aws_region
}
```

Explain:

> In Class 1, the region was hardcoded. Today the region comes from a variable.

## Step 4: Create `variables.tf`

```bash
touch variables.tf
```

Add:

```hcl
variable "aws_region" {
  description = "AWS region for lab resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name such as dev, test, or prod"
  type        = string
  default     = "dev"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
}

# A bool: simple on/off switch.
variable "enable_versioning" {
  description = "Whether to enable S3 object versioning"
  type        = bool
  default     = true
}

# A map(string): arbitrary extra tags merged onto every resource.
variable "extra_tags" {
  description = "Additional tags to merge onto resources"
  type        = map(string)
  default     = {}
}

# An object: a structured group of related settings with typed fields.
variable "bucket_config" {
  description = "Structured S3 bucket settings"
  type = object({
    force_destroy = bool
    sse_algorithm = string
  })
  default = {
    force_destroy = false
    sse_algorithm = "AES256"
  }
}
```

Explain:

> `bucket_prefix` and `owner` do not have defaults, so Terraform requires us to provide them. The new variables show types beyond `string`: a `bool` (true/false), a `map(string)` (a set of key/value pairs — used here for extra tags), and an `object` (a structured record with named, typed fields). Real configurations use these constantly; you almost never get far with only strings.

## Step 5: Create `terraform.tfvars`

```bash
touch terraform.tfvars
```

Add:

```hcl
aws_region    = "us-east-1"
environment   = "dev"
bucket_prefix = "terraform-week14-demo"
owner         = "instructor"
```

Explain:

> This file provides the values for our variables.

## Step 6: Create `main.tf`

```bash
touch main.tf
```

Add:

```hcl
resource "random_id" "suffix" {
  byte_length = 4
}

# Read-only lookup: the account running this configuration.
data "aws_caller_identity" "current" {}

# A local value computes the common tag set once and reuses it.
# merge() combines our standard tags with any caller-supplied extra_tags.
locals {
  common_tags = merge(
    {
      Name             = "${var.bucket_prefix}-${var.environment}"
      Environment      = var.environment
      Owner            = var.owner
      ManagedBy        = "terraform"
      Course           = "devops-cloud-sre"
      CreatedByAccount = data.aws_caller_identity.current.account_id
    },
    var.extra_tags
  )
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket        = "${var.bucket_prefix}-${var.environment}-${random_id.suffix.hex}"
  force_destroy = var.bucket_config.force_destroy

  tags = local.common_tags
}

# Secure-by-default companions (same baseline as Class 1).
resource "aws_s3_bucket_public_access_block" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.bucket_config.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_versioning" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
```

Explain:

> The bucket name is built from variables plus a random suffix to avoid duplicate S3 bucket names. Notice how the complex types are now in use: `var.bucket_config.sse_algorithm` reads a field from the object, `var.enable_versioning` (a bool) drives a conditional expression, and `merge(..., var.extra_tags)` folds a `map(string)` into the standard tags. We also carried the Class 1 secure-by-default baseline forward — public-access-block, encryption, and versioning — so the reusable component is secure, not just parameterized.

## Step 7: Create `outputs.tf`

```bash
touch outputs.tf
```

Add:

```hcl
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.arn
}

output "aws_region" {
  description = "AWS region used for deployment"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# A sensitive output: Terraform masks this in console output and CI logs.
# (The ARN is not truly secret; we mark it here purely to demonstrate the
# behavior. In real configs you mark passwords, connection strings, tokens.)
output "bucket_domain_name" {
  description = "Regional domain name of the bucket (marked sensitive for demo)"
  value       = aws_s3_bucket.lab_bucket.bucket_regional_domain_name
  sensitive   = true
}
```

Explain:

> Outputs help us quickly find important values after apply.

## Step 8: Run Terraform Init

```bash
terraform init
```

Expected output:

```text
Terraform has been successfully initialized!
```

Explain:

> Terraform downloaded the AWS and random providers.

## Step 9: Format and Validate

```bash
terraform fmt
terraform validate
```

Expected validation output:

```text
Success! The configuration is valid.
```

Explain:

> Formatting helps consistency. Validation checks Terraform syntax and configuration structure.

## Step 10: Generate Plan

```bash
terraform plan
```

Expected output excerpt:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

Explain:

> Terraform will create five resources: the random suffix, the S3 bucket, and its three security controls. The `data.aws_caller_identity.current` lookup is read-only, so it is resolved during planning and does not count as an action.

## Step 11: Apply

```bash
terraform apply
```

When prompted:

```text
yes
```

Expected output:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

aws_region = "us-east-1"
bucket_arn = "arn:aws:s3:::terraform-week14-demo-dev-a1b2c3d4"
bucket_domain_name = <sensitive>
bucket_name = "terraform-week14-demo-dev-a1b2c3d4"
environment = "dev"
```

## Step 12: View Outputs

```bash
terraform output
```

Expected output:

```text
aws_region = "us-east-1"
bucket_arn = "arn:aws:s3:::terraform-week14-demo-dev-a1b2c3d4"
bucket_domain_name = <sensitive>
bucket_name = "terraform-week14-demo-dev-a1b2c3d4"
environment = "dev"
```

Explain:

> Outputs give us useful values without searching through the AWS Console. Notice `bucket_domain_name = <sensitive>` — because we marked that output `sensitive = true`, Terraform masks it in the console and in CI logs. This matters because outputs are printed everywhere (terminal, pull-request comments, pipeline logs), so any password, token, or connection string surfaced as an output must be marked sensitive.

To deliberately reveal one sensitive output value when you genuinely need it:

```bash
terraform output bucket_domain_name
```

Expected output:

```text
"terraform-week14-demo-dev-a1b2c3d4.s3.us-east-1.amazonaws.com"
```

> Asking for a specific output by name shows its real value. Marking an output sensitive does NOT encrypt it in state — the value is still plaintext in `terraform.tfstate`. It only controls console/log display. The reverse helper, `nonsensitive()`, exists for the rare case where you must strip the sensitive flag inside an expression.

## Step 13: Validate in AWS CLI

```bash
aws s3 ls | grep terraform-week14-demo
```

Expected output:

```text
2026-04-26 14:10:25 terraform-week14-demo-dev-a1b2c3d4
```

## Step 14: Inspect State

```bash
terraform state list
```

Expected output:

```text
aws_s3_bucket.lab_bucket
aws_s3_bucket_public_access_block.lab_bucket
aws_s3_bucket_server_side_encryption_configuration.lab_bucket
aws_s3_bucket_versioning.lab_bucket
random_id.suffix
```

Inspect one resource:

```bash
terraform state show aws_s3_bucket.lab_bucket
```

Then open `terraform.tfstate` and look at the `outputs` section. Even though we marked `bucket_domain_name` as `sensitive`, its value is stored in plaintext in state:

```json
"outputs": {
  "bucket_domain_name": {
    "value": "terraform-week14-demo-dev-a1b2c3d4.s3.us-east-1.amazonaws.com",
    "type": "string",
    "sensitive": true
  }
}
```

Explain:

> State now tracks all five resources. Critically, `sensitive = true` only hides the value in console/log output — in the state file it is still clear text. This is the concrete proof behind the rule we keep repeating: protect state, never commit it, store it in an encrypted remote backend (Week 15).

## Step 15: Cleanup

```bash
terraform destroy
```

Type:

```text
yes
```

Expected output:

```text
Destroy complete! Resources: 5 destroyed.
```

## Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| Missing variable prompt | Required variable not in `terraform.tfvars` | Add missing value |
| `BucketAlreadyExists` | Bucket name still not unique | Change prefix or rerun with random suffix |
| Provider error | AWS credentials or region issue | Run `aws sts get-caller-identity` |
| Random provider not found | `terraform init` not run after adding provider | Run `terraform init` again |
| Output missing | `outputs.tf` not saved or apply not run | Save file and rerun plan/apply |
| Destroy fails | Bucket has objects inside | Empty bucket first if objects were added |

---

# 14. Student Lab Manual

## Lab Title

**Build a Reusable Terraform Component With Variables and Outputs**

## Lab Objective

You will create a reusable Terraform configuration that creates an AWS S3 bucket using variables, `terraform.tfvars`, tags, outputs, and a random suffix.

## Estimated Time

50 to 60 minutes

## Student Prerequisites

You must have:

- Completed Class 1 lab
- Terraform installed
- AWS CLI installed
- AWS credentials configured
- Permission to create and delete S3 buckets

Validate:

```bash
terraform version
aws sts get-caller-identity
```

## Starting Point From Class 1

In Class 1, you created an S3 bucket with hardcoded values.

In this lab, you will improve that pattern by using:

- `variables.tf`
- `terraform.tfvars`
- `outputs.tf`
- Standard tags
- Random suffix for uniqueness

## Architecture or Workflow Overview

```text
Student Variable Values
        |
        v
Terraform Configuration
        |
        v
AWS Provider
        |
        v
AWS S3 Bucket
        |
        v
Terraform Outputs
        |
        v
Terraform State
```

## Step 1: Create Lab Folder

```bash
mkdir terraform-week14-class2-lab
cd terraform-week14-class2-lab
```

## Step 2: Create Required Files

```bash
touch versions.tf provider.tf variables.tf terraform.tfvars main.tf outputs.tf .gitignore
```

Your folder should look like:

```text
terraform-week14-class2-lab/
├── .gitignore
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
└── outputs.tf
```

Add this `.gitignore` first — it keeps state and secret value files out of version control:

```gitignore
# Terraform working files and state — never commit
.terraform/
*.tfstate
*.tfstate.*

# Local/secret variable files — commit a non-secret terraform.tfvars or
# an example file instead, but keep these out
*.tfvars.local
secrets.auto.tfvars

# Provider lock file: commit this in real repos for reproducible versions.
# (Left tracked on purpose; do NOT add .terraform.lock.hcl here.)
```

## Step 3: Add `versions.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

## Step 4: Add `provider.tf`

```hcl
provider "aws" {
  region = var.aws_region
}
```

## Step 5: Add `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region for lab resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name such as dev, test, or prod"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
}

# bool type: toggles S3 versioning on/off.
variable "enable_versioning" {
  description = "Whether to enable S3 object versioning"
  type        = bool
  default     = true
}

# map(string) type: extra tags merged onto the bucket.
variable "extra_tags" {
  description = "Additional tags to merge onto resources"
  type        = map(string)
  default     = {}
}
```

## Step 6: Add `terraform.tfvars`

Replace `your-name` with your name or initials.

```hcl
aws_region    = "us-east-1"
environment   = "dev"
bucket_prefix = "terraform-week14-your-name"
owner         = "your-name"

extra_tags = {
  CostCenter = "training"
  Team       = "platform"
}
```

Example:

```hcl
bucket_prefix = "terraform-week14-jd"
owner         = "jd"
```

## Step 7: Add `main.tf`

```hcl
resource "random_id" "suffix" {
  byte_length = 4
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = merge(
    {
      Name             = "${var.bucket_prefix}-${var.environment}"
      Environment      = var.environment
      Owner            = var.owner
      ManagedBy        = "terraform"
      Course           = "devops-cloud-sre"
      CreatedByAccount = data.aws_caller_identity.current.account_id
    },
    var.extra_tags
  )
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "${var.bucket_prefix}-${var.environment}-${random_id.suffix.hex}"

  tags = local.common_tags
}

# Secure-by-default companions (same baseline as Class 1).
resource "aws_s3_bucket_public_access_block" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}
```

## Step 8: Add `outputs.tf`

```hcl
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.arn
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# Sensitive output: masked in console/CI output. Try `terraform output`
# and notice it shows <sensitive>.
output "bucket_domain_name" {
  description = "Regional domain name of the bucket (marked sensitive to demo masking)"
  value       = aws_s3_bucket.lab_bucket.bucket_regional_domain_name
  sensitive   = true
}
```

## Step 9: Initialize Terraform

```bash
terraform init
```

Expected output:

```text
Terraform has been successfully initialized!
```

## Step 10: Format and Validate

```bash
terraform fmt
terraform validate
```

Expected output:

```text
Success! The configuration is valid.
```

## Step 11: Review Plan

```bash
terraform plan
```

Expected result:

```text
Plan: 5 to add, 0 to change, 0 to destroy.
```

You should see:

- `random_id.suffix`
- `aws_s3_bucket.lab_bucket`
- `aws_s3_bucket_public_access_block.lab_bucket`
- `aws_s3_bucket_server_side_encryption_configuration.lab_bucket`
- `aws_s3_bucket_versioning.lab_bucket`

## Step 12: Apply

```bash
terraform apply
```

When prompted:

```text
yes
```

Expected output:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

## Step 13: View Outputs

```bash
terraform output
```

Expected output example:

```text
bucket_arn = "arn:aws:s3:::terraform-week14-jd-dev-a1b2c3d4"
bucket_domain_name = <sensitive>
bucket_name = "terraform-week14-jd-dev-a1b2c3d4"
environment = "dev"
```

Notice `bucket_domain_name` shows `<sensitive>` because you marked that output `sensitive = true`. To reveal a single sensitive value on purpose:

```bash
terraform output bucket_domain_name
```

## Step 14: Validate in AWS

```bash
aws s3 ls | grep terraform-week14
```

Expected output:

```text
2026-04-26 14:10:25 terraform-week14-jd-dev-a1b2c3d4
```

## Step 15: Inspect State

```bash
terraform state list
```

Expected output:

```text
aws_s3_bucket.lab_bucket
aws_s3_bucket_public_access_block.lab_bucket
aws_s3_bucket_server_side_encryption_configuration.lab_bucket
aws_s3_bucket_versioning.lab_bucket
random_id.suffix
```

Open `terraform.tfstate` in your editor and find the `outputs` section. Confirm that `bucket_domain_name` is stored in plaintext even though it is marked `sensitive` — `sensitive` only masks console/log display, it does not protect state.

## Step 16: Make a Small Tag Change

In `main.tf`, add one more tag inside the `locals.common_tags` map:

```hcl
Purpose = "week14-class2-lab"
```

Run:

```bash
terraform fmt
terraform validate
terraform plan
```

Expected result:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Apply the change:

```bash
terraform apply
```

## Step 17: Cleanup

Destroy the resources:

```bash
terraform destroy
```

Type:

```text
yes
```

Expected output:

```text
Destroy complete! Resources: 5 destroyed.
```

## Validation Checklist

Confirm:

```text
[ ] I created all required Terraform files (including .gitignore).
[ ] I used variables in provider.tf and main.tf.
[ ] I used a complex type (map(string) extra_tags) and a bool (enable_versioning).
[ ] I provided values in terraform.tfvars.
[ ] I used outputs in outputs.tf, including one sensitive output.
[ ] My bucket has public-access-block, encryption, and versioning.
[ ] terraform init succeeded.
[ ] terraform validate succeeded.
[ ] terraform plan showed expected resources.
[ ] terraform apply created the bucket.
[ ] terraform output displayed useful values.
[ ] terraform state list showed managed resources.
[ ] terraform destroy removed the resources.
```

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| Terraform asks for variable input | Missing value in `terraform.tfvars` | Add missing value |
| `BucketAlreadyExists` | Bucket name conflict | Use unique prefix or random suffix |
| `No valid credential sources found` | AWS credentials missing | Run `aws sts get-caller-identity` |
| Random provider error | Did not rerun `terraform init` | Run `terraform init` |
| Output does not appear | `outputs.tf` missing or not applied | Save file and rerun apply |
| Plan shows unexpected delete | Code changed or state mismatch | Stop and ask instructor |

## Cleanup Steps

Confirm resources are removed:

```bash
aws s3 ls | grep terraform-week14
```

No output means your bucket was removed.

Optional local cleanup:

```bash
cd ..
rm -rf terraform-week14-class2-lab
```

Do not delete your folder until after submitting homework, if you need it.

## Reflection Questions

1. Why is using variables better than hardcoding values?
2. What is the difference between `variables.tf` and `terraform.tfvars`?
3. Why are outputs useful?
4. What did Terraform state track in this lab?
5. What changed when you added a new tag?
6. What could go wrong if someone manually changed this bucket in AWS Console?

## Optional Challenge Task

Create a second variable named `project_name`.

Add it to your tags:

```hcl
Project = var.project_name
```

Add a value in `terraform.tfvars`.

Run:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

---

# 15. Troubleshooting Activity

## Incident Title

**Terraform Plan Fails Because Required Variable Is Missing**

## Business Impact

A DevOps engineer is preparing reusable Terraform code for a new development environment. The code works on the engineer’s laptop, but another team member cannot run it because a required variable value is missing.

This blocks environment creation and delays application testing.

## Symptoms

Student runs:

```bash
terraform plan
```

Terraform prompts:

```text
var.bucket_prefix
  Prefix for the S3 bucket name

  Enter a value:
```

or fails in automation because no interactive input is allowed.

Another possible error:

```text
Error: No value for required variable

The root module input variable "owner" is not set, and has no default value.
```

## Starting Evidence

`variables.tf` contains:

```hcl
variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
}
```

But `terraform.tfvars` contains only:

```hcl
aws_region  = "us-east-1"
environment = "dev"
```

## Student Investigation Steps

Students should:

1. Read the exact error message.
2. Identify which variable is missing.
3. Open `variables.tf`.
4. Identify variables without default values.
5. Open `terraform.tfvars`.
6. Compare required variables to provided values.
7. Add missing values.
8. Rerun:

```bash
terraform fmt
terraform validate
terraform plan
```

## Expected Root Cause

`bucket_prefix` and/or `owner` are required variables because they do not have default values, but they are missing from `terraform.tfvars`.

## Correct Resolution

Update `terraform.tfvars`:

```hcl
aws_region    = "us-east-1"
environment   = "dev"
bucket_prefix = "terraform-week14-student"
owner         = "student-name"
```

Then rerun:

```bash
terraform validate
terraform plan
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Editing the provider block | The provider is not the issue |
| Reinstalling Terraform | Terraform is working correctly |
| Removing the variable from `variables.tf` | This weakens the reusable design |
| Hardcoding the bucket name in `main.tf` | This defeats the purpose of Class 2 |
| Running apply without understanding the prompt | Dangerous habit for pipelines and production |

## Instructor Hints

Hint 1:

> Which variables have defaults, and which ones do not?

Hint 2:

> Where do we provide values for variables?

Hint 3:

> What file acts like the completed form for our inputs?

## Preventive Action

- Always keep `variables.tf` and `terraform.tfvars` aligned.
- Use clear variable descriptions.
- Provide example tfvars files for teams.
- In enterprise repos, include a documented `example.tfvars`.
- In CI/CD, pass all required variables explicitly.
- Avoid interactive prompts in automated pipelines.

---

# 16. Scenario-Based Discussion Questions

## Question 1

Why should teams avoid hardcoding values like region, environment, and owner directly in Terraform resources?

Expected themes:

- Reusability
- Environment separation
- Easier maintenance
- Reduced duplication
- Better standardization

Instructor follow-up:

> What happens when dev and prod need different values?

## Question 2

Should `terraform.tfvars` always be committed to Git?

Expected themes:

- It depends
- Non-sensitive values may be committed
- Sensitive values should not be committed
- Teams may use example tfvars files
- Secrets should come from secure systems

Instructor follow-up:

> What types of values should never go into Git?

## Question 3

Why are outputs useful in real infrastructure projects?

Expected themes:

- Show important resource values
- Help other teams consume infrastructure
- Useful in documentation
- Useful in pipelines
- Useful after apply

Instructor follow-up:

> What outputs might be useful after creating a VPC or load balancer?

## Question 4

What risks exist when Terraform state is stored only on one engineer’s laptop?

Expected themes:

- Team cannot collaborate safely
- State can be lost
- State can be corrupted
- No shared source of truth
- Sensitive data may be exposed

Instructor follow-up:

> Why do teams use remote state backends?

## Question 5

What should a team do if someone manually changes a Terraform-managed resource in AWS Console?

Expected themes:

- Investigate drift
- Run plan
- Decide whether to accept or revert change
- Avoid automatic assumptions
- Improve process to prevent future manual changes

Instructor follow-up:

> Should Terraform always overwrite the manual change?

## Question 6

How do tags help enterprise cloud teams?

Expected themes:

- Cost allocation
- Ownership
- Environment identification
- Compliance
- Automation
- Cleanup

Instructor follow-up:

> What tags should be mandatory in a company?

## Question 7

How does Class 2 improve the Terraform code from Class 1?

Expected themes:

- Variables replace hardcoded values
- Outputs expose useful information
- File organization is better
- State is better understood
- Code is closer to team-ready

Instructor follow-up:

> What is still missing before this is enterprise-ready?

## Question 8

What might go wrong if a CI/CD pipeline runs Terraform code that prompts for missing variable values?

Expected themes:

- Pipeline hangs or fails
- Deployment blocked
- Inconsistent automation
- Poor variable management
- Need explicit inputs

Instructor follow-up:

> How should pipeline variables be handled safely?

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the purpose of a Terraform variable?

A. To delete unused resources  
B. To provide reusable input values  
C. To store logs  
D. To replace the AWS provider  

**Answer:** B  
**Explanation:** Variables make Terraform code reusable by allowing input values to change.

## Question 2: Multiple Choice

Which file commonly provides values for Terraform variables?

A. `outputs.tf`  
B. `terraform.tfvars`  
C. `.terraform.lock.hcl`  
D. `terraform.tfstate`  

**Answer:** B  
**Explanation:** `terraform.tfvars` commonly provides values for variables.

## Question 3: True or False

A variable without a default value must receive a value from somewhere else.

**Answer:** True  
**Explanation:** Terraform requires a value for variables that do not have defaults.

## Question 4: Multiple Choice

What is the purpose of Terraform outputs?

A. To display useful values after apply  
B. To delete local files  
C. To install providers  
D. To replace variables  

**Answer:** A  
**Explanation:** Outputs show useful values such as bucket names, IP addresses, and ARNs.

## Question 5: Class 1 and Class 2 Connection

In Class 1, the AWS region was hardcoded. In Class 2, what improved this design?

A. Removing the provider  
B. Using a variable for the region  
C. Deleting the state file  
D. Running destroy first  

**Answer:** B  
**Explanation:** Using `var.aws_region` makes the provider configuration reusable.

## Question 6: AWS-Related Multiple Choice

Why did this lab use a random suffix for the S3 bucket name?

A. To encrypt the bucket  
B. To reduce the chance of a globally unique name conflict  
C. To make the bucket public  
D. To avoid using tags  

**Answer:** B  
**Explanation:** S3 bucket names must be globally unique.

## Question 7: Troubleshooting Question

Terraform prompts for `var.owner` during `terraform plan`. What is the likely cause?

**Answer:** The `owner` variable has no default value and is missing from `terraform.tfvars`.  
**Explanation:** Required variables must be supplied through tfvars, CLI input, environment variables, or another supported method.

## Question 8: Troubleshooting Question

A student manually deletes a Terraform-created bucket in the AWS Console. What issue might appear during the next Terraform plan?

**Answer:** Terraform may detect drift and propose to recreate the missing bucket.  
**Explanation:** Terraform state still tracks the resource, but the real resource no longer exists.

## Question 9: True or False

Terraform state should be treated carefully because it may contain sensitive infrastructure information.

**Answer:** True  
**Explanation:** State can contain resource attributes and sometimes sensitive values.

## Question 10: AWS-Related Short Answer

What AWS CLI command should students use to confirm their current AWS identity?

**Answer:** `aws sts get-caller-identity`  
**Explanation:** This command shows the AWS identity being used locally.

## Question 11: Class 1 and Class 2 Connection

What did Class 2 add to the basic Terraform workflow from Class 1?

**Answer:** Variables, `terraform.tfvars`, outputs, better file organization, random suffix usage, and deeper state understanding.  
**Explanation:** Class 2 made the Terraform configuration more reusable and team-friendly.

## Question 12: Multiple Choice

Which command displays Terraform output values after apply?

A. `terraform show-outputs`  
B. `terraform output`  
C. `terraform values`  
D. `terraform print`  

**Answer:** B  
**Explanation:** `terraform output` displays configured output values.

---

# 18. Homework Assignment

## Assignment Title

**Create a Reusable Terraform Component With Variables and Outputs**

## Scenario

You are a junior cloud engineer on a platform team. Your team is creating reusable Terraform examples for application teams. You have been asked to create a simple S3 bucket Terraform component that can be reused across environments by changing variable values instead of rewriting resource code.

## Student Tasks

Create a Terraform project named:

```text
terraform-week14-reusable-component
```

Your project must include:

```text
.gitignore
versions.tf
provider.tf
variables.tf
terraform.tfvars
main.tf
outputs.tf
README.md
```

Your Terraform code must:

1. Configure the AWS provider using a region variable.
2. Define variables for:
   - `aws_region`
   - `environment`
   - `bucket_prefix`
   - `owner`
   - `project_name`
   - At least one complex type: an `extra_tags` variable of type `map(string)`
3. Use a random suffix for the S3 bucket name.
4. Create one S3 bucket plus its secure-by-default companions:
   - `aws_s3_bucket_public_access_block`
   - `aws_s3_bucket_server_side_encryption_configuration`
   - `aws_s3_bucket_versioning`
5. Add tags (merge your standard tags with `var.extra_tags`):
   - `Name`
   - `Environment`
   - `Owner`
   - `Project`
   - `ManagedBy`
6. Create outputs for:
   - Bucket name
   - Bucket ARN
   - Environment
   - One output marked `sensitive = true`
7. Add a `.gitignore` that excludes `.terraform/`, `*.tfstate`, `*.tfstate.*`, and secret tfvars.
8. Run:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

9. Optional, if allowed by instructor: run `terraform apply` and `terraform destroy`.

## Expected Deliverables

Students submit:

- All `.tf` files
- `terraform.tfvars` with non-sensitive lab values
- `README.md`
- Output of:
  - `terraform fmt`
  - `terraform validate`
  - `terraform plan`
- Short written answers:
  1. What is the purpose of `variables.tf`?
  2. What is the purpose of `terraform.tfvars`?
  3. What is the purpose of `outputs.tf`?
  4. Why should Terraform state be protected?
  5. Why are tags important in enterprise AWS environments?

## Submission Format

Submit as:

- Git repository link, or
- Zip file without `.terraform/`, `terraform.tfstate`, or credential files

Do not submit:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
AWS credentials
Secrets
Access keys
```

## Estimated Completion Time

90 to 120 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Correct file structure (including `.gitignore`) | 10 |
| Variables properly defined (incl. one complex `map(string)` type) | 15 |
| `terraform.tfvars` values provided | 10 |
| S3 bucket uses variables and random suffix | 15 |
| Secure-by-default controls (public-access-block + SSE + versioning) | 15 |
| Outputs are correct (including one `sensitive` output) | 15 |
| Tags are complete (merged with `extra_tags`) | 10 |
| README explanation is clear | 10 |

## Optional Advanced Challenge

Add a `dev.tfvars` and `prod.tfvars` file with different values.

Run:

```bash
terraform plan -var-file="dev.tfvars"
terraform plan -var-file="prod.tfvars"
```

Do not apply prod unless the instructor explicitly allows it.

### Extra challenge: a first local module

Wrap the bucket and its security controls into a tiny local module so you see how variables + outputs become a reusable building block (the full module workflow is Week 15):

```text
terraform-week14-reusable-component/
├── main.tf            # calls the module
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── modules/
    └── secure_bucket/
        ├── main.tf      # bucket + public-access-block + SSE + versioning
        ├── variables.tf # bucket_prefix, environment, owner, extra_tags...
        └── outputs.tf   # bucket_name, bucket_arn
```

Root `main.tf`:

```hcl
module "artifacts" {
  source        = "./modules/secure_bucket"
  bucket_prefix = var.bucket_prefix
  environment   = var.environment
  owner         = var.owner
  extra_tags    = var.extra_tags
}
```

Reference the module's outputs as `module.artifacts.bucket_name`. Run `terraform init` again after adding a module so Terraform registers it.

### OpenTofu try-it

Everything in this homework runs identically on OpenTofu. If you have `tofu` installed, try `tofu init && tofu plan` in the same folder and confirm the output matches `terraform`. This is the drop-in compatibility discussed in Class 1.

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | Fix or Prevention |
|---|---|---|
| Forgetting to add required variable values | Students define variables but do not provide values | Compare `variables.tf` with `terraform.tfvars` |
| Putting variable values in `variables.tf` incorrectly | Confusion between definition and assignment | Explain that `variables.tf` defines inputs, `tfvars` provides values |
| Hardcoding values in `main.tf` | Students fall back to Class 1 pattern | Replace hardcoded values with `var.<name>` |
| Forgetting to rerun `terraform init` after adding random provider | Provider list changed | Run `terraform init` again |
| Not using unique bucket prefix | S3 naming conflict | Use name, date, or random suffix |
| Expecting outputs before apply | Outputs depend on created resources | Run apply first or explain known-after-apply behavior |
| Deleting state file to “fix” errors | Misunderstanding state | Stop and ask instructor before touching state |
| Submitting state file with homework | Students do not understand sensitivity | Add explicit submission warning |
| Ignoring plan output | Students rush to apply | Require students to explain plan before applying |
| Manually changing AWS resource | Console habits from earlier weeks | Explain drift and team workflow risk |

---

# 20. Real-World Enterprise Scenario

## Scenario

A company is onboarding several application teams to AWS. Each team needs an S3 bucket for application artifacts, logs, or integration files. Initially, engineers create buckets manually in the AWS Console. Over time, naming becomes inconsistent, tags are missing, and nobody knows which team owns which bucket.

The cloud platform team decides to create a reusable Terraform pattern.

## How This Class Topic Applies

Variables allow each team to provide:

- Environment
- Owner
- Project name
- Region
- Bucket prefix

Outputs allow the platform team to expose:

- Bucket name
- Bucket ARN
- Environment
- Other values needed by pipelines or applications

State allows Terraform to track what was created.

## Enterprise Constraints

| Constraint | Example |
|---|---|
| Access control | Only platform engineers or approved pipelines can apply Terraform |
| Approvals | Production bucket creation requires merge request approval |
| Cost | Every bucket needs owner and project tags |
| Security | Bucket policies and encryption will be standardized later |
| Reliability | Infrastructure must be repeatable across environments |
| Audit | Changes must be visible in Git history and CloudTrail |
| Production impact | Accidental destroy could break applications depending on the bucket |

## What Each Role Would Do

### DevOps Engineer

- Adds Terraform validation and plan stages to CI/CD
- Passes environment-specific variables through pipelines
- Ensures application teams can request infrastructure safely

### Cloud Engineer

- Builds reusable Terraform patterns
- Defines tagging and naming standards
- Designs remote state and access control strategy

### SRE

- Reviews infrastructure for operational risk
- Ensures outputs support monitoring, runbooks, and incident response
- Watches for drift that could cause production issues

---

# 21. Instructor Tips

## Teaching Tips

- Use Class 1 as the anchor: “same resource, better design.”
- Keep variables concrete. Avoid abstract examples at first.
- Explain `variables.tf` and `terraform.tfvars` as “form” and “completed form.”
- Revisit state several times using simple language.
- Do not introduce modules deeply yet. Mention that modules come later.
- Keep remote state at concept level, since Week 15 covers enterprise workflows.

## Pacing Tips

- Keep review short, about 15 minutes.
- Spend no more than 25 minutes on variables before showing code.
- Give students enough lab time.
- Save at least 15 minutes for troubleshooting.
- Do not let advanced questions about modules derail the class.

## Lab Support Tips

When helping students, check in this order:

1. Are they in the correct folder?
2. Did they save all files?
3. Did they run `terraform init`?
4. Did they add both providers?
5. Are required variables in `terraform.tfvars`?
6. Does `aws sts get-caller-identity` work?
7. Is the plan output expected?

## Helping Struggling Students

For students who are stuck:

- Ask them to explain one file at a time.
- Have them compare their file structure to the expected structure.
- Give them a working `variables.tf` and ask them to complete `terraform.tfvars`.
- Pair them with a student who completed Class 1 comfortably.

## Challenging Advanced Students

Ask advanced students to:

- Add input validation to variables
- Create separate `dev.tfvars` and `prod.tfvars`
- Add a `README.md`
- Create a `.gitignore`
- Explain why remote state is needed for teams
- Compare Terraform variables with CI/CD pipeline variables

Example variable validation:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}
```

---

# 22. Student Outcome Checklist

## Students Should Be Able to Explain

```text
[ ] Why variables make Terraform reusable
[ ] Difference between variables.tf and terraform.tfvars
[ ] What outputs are used for
[ ] Why state is important
[ ] What drift means
[ ] Why manual cloud changes are risky
[ ] Why tags matter in enterprise AWS environments
[ ] How Class 2 extends Class 1
```

## Students Should Be Able to Build or Configure

```text
[ ] A multi-file Terraform project
[ ] variables.tf with typed variables
[ ] terraform.tfvars with input values
[ ] provider.tf using a region variable
[ ] main.tf using variables
[ ] outputs.tf with useful outputs
[ ] S3 bucket with standard tags
[ ] Random suffix for bucket uniqueness
```

## Students Should Be Able to Troubleshoot

```text
[ ] Missing variable values
[ ] Duplicate S3 bucket name
[ ] AWS credential issues
[ ] Missing provider initialization
[ ] Output not appearing
[ ] Unexpected plan output
[ ] Basic drift scenario
[ ] Local state awareness issues
```

---

# 23. Class Completion Checklist

## Instructor Checklist Before Ending Class

Confirm students understand:

```text
[ ] Variables reduce hardcoding.
[ ] terraform.tfvars provides variable values.
[ ] Outputs expose useful resource information.
[ ] State maps Terraform code to real infrastructure.
[ ] Manual changes can cause drift.
[ ] S3 bucket names must be globally unique.
[ ] Terraform code should be stored and reviewed in Git.
[ ] State files should not be casually shared or submitted.
```

Confirm students practiced:

```text
[ ] Creating versions.tf
[ ] Creating provider.tf
[ ] Creating variables.tf
[ ] Creating terraform.tfvars
[ ] Creating main.tf
[ ] Creating outputs.tf
[ ] Running terraform init
[ ] Running terraform fmt
[ ] Running terraform validate
[ ] Running terraform plan
[ ] Running terraform apply
[ ] Running terraform output
[ ] Running terraform state list
[ ] Running terraform destroy
```

## Student Checklist Before Leaving Class

Students should confirm:

```text
[ ] I completed the lab.
[ ] I created a reusable Terraform project.
[ ] I used variables instead of hardcoded values.
[ ] I provided values in terraform.tfvars.
[ ] I created outputs.
[ ] I viewed Terraform outputs.
[ ] I inspected state with terraform state list.
[ ] I cleaned up AWS resources.
[ ] I understand the homework assignment.
[ ] I know what to review before Week 15.
```

## Items to Verify Before Closing the Week

Before moving to Week 15, students should be comfortable with:

- Terraform workflow commands
- Provider configuration
- Resource blocks
- Variables
- `terraform.tfvars`
- Outputs
- Local state
- Basic drift concept
- AWS credential validation
- Basic Terraform troubleshooting

---

# 24. End-of-Week Summary

## What Students Learned This Week

During Week 14, students learned how to use Terraform to provision basic AWS infrastructure.

They learned:

- What Infrastructure as Code means, and that Terraform and OpenTofu are interchangeable for everything in this week
- Why Terraform is used by DevOps, Cloud Engineering, and SRE teams
- How to configure the AWS provider
- How to define AWS resources, including the secure-by-default S3 baseline (public-access-block, encryption, versioning)
- How resource references build the dependency graph, and how data sources read existing information
- How to run the Terraform workflow
- How to use variables (including `bool`, `map`, and `object` types) and `terraform.tfvars`
- How to create outputs, including `sensitive = true` outputs
- How Terraform state tracks managed infrastructure, what the `tfstate` JSON looks like, and the core state commands (`state list`, `state show`)
- How to troubleshoot common Terraform errors

## How Class 1 and Class 2 Connect

Class 1 focused on the basic Terraform lifecycle:

```text
provider + resource + init + plan + apply + state + destroy
```

Class 2 improved that foundation with reusable design:

```text
variables + tfvars + outputs + better file organization + deeper state understanding
```

Together, the two classes move students from “I can create one resource with Terraform” to “I can start writing reusable Terraform code that looks closer to real team workflows.”

## How This Week Prepares Students for the Next Week

Week 15 will focus on **Terraform for Enterprise Cloud Workflows**.

Students will build on Week 14 by learning:

- Environment folders
- Dev and prod separation
- Reusable modules
- Remote state concepts
- State locking concepts
- Git-based review
- Terraform plan review
- Drift detection
- CI/CD integration

## What Students Should Review Before the Next Module

Students should review:

```text
[ ] Terraform init, fmt, validate, plan, apply, destroy
[ ] Provider blocks
[ ] Resource blocks and the dependency graph
[ ] Data sources (read-only lookups)
[ ] Variable definitions and complex types (bool, list, map, object)
[ ] terraform.tfvars
[ ] Outputs, including sensitive outputs
[ ] Local state, the tfstate JSON, and state list/show
[ ] AWS credentials and profiles
[ ] S3 bucket uniqueness and the secure-by-default baseline
[ ] Why manual changes cause drift
[ ] That Terraform and OpenTofu share the same workflow
```

Recommended practice before Week 15:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform output
terraform state list
```

Final instructor closing message:

> This week was about learning the Terraform building blocks. Next week is about using those building blocks the way real teams do: with environments, review workflows, state safety, and CI/CD integration.

## Class Artifacts & Validation

This class is backed by the **`labs/terraform-aws-foundations`** module. Class 02 (variables,
outputs, state, reusable patterns) maps to the **VPC root module** (`solution/` calling
`solution/modules/vpc/`) — typed variables with validation, `sensitive` outputs, remote-state
wiring, and a child module. The static gates are **plan-free** ($0) and were run here via
`./validate.sh` (`10 passed, 0 failed`, exit 0). The VPC module was additionally **applied to
and destroyed from a real AWS account** — see row 8.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/terraform-aws-foundations/solution/main.tf` | terraform | VPC root module: calls `modules/vpc`, wires VPC + public/private subnets per AZ, IGW, route tables, optional NAT, deny-all default SG, flow logs | `terraform -chdir=solution init -backend=false && terraform -chdir=solution validate` | PASS — `Success! The configuration is valid.` |
| 2 | `labs/terraform-aws-foundations/solution/variables.tf` | terraform | Typed input variables (`bool`/`number`/`map`) incl. `az_count` and `enable_nat_gateway`, with type validation — the Class 02 variables topic | `terraform -chdir=solution validate` | PASS |
| 3 | `labs/terraform-aws-foundations/solution/outputs.tf` | terraform | Outputs (`vpc_id`, subnet id lists); demonstrates the outputs + `sensitive` topic | `terraform -chdir=solution validate` | PASS |
| 4 | `labs/terraform-aws-foundations/solution/terraform.tfvars.example` | terraform | `terraform.tfvars` example — the variable-values file taught in Class 02 (real `.tfvars` is git-ignored) | `terraform -chdir=solution validate` (consumes the var schema) | PASS |
| 5 | `labs/terraform-aws-foundations/solution/backend.tf.example` | terraform | Commented S3 + DynamoDB remote-state backend — the "state safety" preview for Week 15 | `terraform fmt -check -recursive solution` | PASS |
| 6 | `labs/terraform-aws-foundations/solution/modules/vpc/main.tf` | terraform | Reusable child module — `cidrsubnet()` non-overlapping subnets, `count`-gated NAT, flow logs to encrypted CloudWatch | `terraform -chdir=solution/modules/vpc init -backend=false && terraform -chdir=solution/modules/vpc validate` | PASS — `Success! The configuration is valid.` |
| 7 | `labs/terraform-aws-foundations/broken/main.tf` | terraform | Troubleshooting fixture — `aws_nat_gateway.this.id` referenced without `[0]` on a counted resource; MUST fail validate | `terraform -chdir=broken init -backend=false && terraform -chdir=broken validate` | PASS (negative gate — **fails by design**: `Error: Missing resource instance key`) |
| 8 | `labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt` | evidence | Real `apply`/`destroy` of the VPC module on AWS account 071146695791 (us-east-1) | n/a — captured log of a live `terraform apply` then `destroy` | PASS — `Apply complete! Resources: 19 added` (VPC+4 subnets+IGW+3 RTs, API-verified) then `Destroy complete! Resources: 19 destroyed`, confirmed clean; lifetime ~90s, cost $0 (NAT off) |
| 9 | `labs/terraform-aws-foundations/solution/` + `solution/modules/vpc/` | terraform | IaC security scan of the VPC module | `checkov -d solution --compact --quiet` and `checkov -d solution/modules/vpc --compact --quiet` | PASS — root `48/0/1`, vpc module `45/0/1` (1 documented `CKV_AWS_130` public-subnet skip) |
| 10 | `labs/terraform-aws-foundations/tests/test_terraform_structure.py` | python | Stdlib structural tests incl. `test_private_subnet_offset_avoids_overlap` | `python3 -m unittest discover -s tests` | PASS — `Ran 18 tests ... OK` |
| 11 | `labs/terraform-aws-foundations/validate.sh` | bash | Single entrypoint running all 10 static gates | `./validate.sh` | PASS — `10 passed, 0 failed` (exit 0) |

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (the VPC root + child module `*.tf` under `solution/`, not just fences).
- [x] Each artifact passes (or documents) its **validation gate** from §3 — `terraform fmt -check` + `init -backend=false` + `validate` all green on root and module; `checkov` clean; output captured above and in the lab README.
- [x] Lab has **starter** (`starter/modules/vpc/main.tf` with five `TODO(student)` blocks) and **solution** (`solution/modules/vpc/`) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, and cost notes.
- [x] **Cleanup/teardown** is provided and idempotent — `terraform destroy` + EIP/NAT release verification; static gates create only local files; the live run was destroyed clean (row 8).
- [x] **Instructor answer key** exists for Lab B (VPC module), the homework, the quiz, and the troubleshooting exercise (lab README "Instructor answer key" + this class file's quiz/assignment keys).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `broken/` fixture that fails `terraform validate` with `Missing resource instance key`.
- [x] **Expected outputs** are shown for the demo and lab (`Success! The configuration is valid.`, the live `Apply complete! Resources: 19 added` / `Destroy complete! Resources: 19 destroyed`).
- [x] **Cost & security warnings** present — NAT ~$32/mo (off by default), flow-log KMS ~$1/mo, deny-all default SG, flow logs, never-commit-state notes.
- [x] **Cross-references** to the module repo, Class 01, and Weeks 15 / 23–24 (capstone reuse of this VPC module) are correct.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (verified with `ls`).
