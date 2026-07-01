# Week 4: AWS Cloud Foundations
> **▶ Runnable lab for this class:** [`labs/aws-cli-fundamentals/`](../../labs/aws-cli-fundamentals/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2: AWS CLI Setup, Cost Controls, Tagging, and First Operational Checks

**Week:** 4 · Class 2  
**Track:** Unified DevOps · Cloud · SRE Track  
**Duration:** 3 hours  
**Audience:** Beginner to intermediate  
**Primary cloud:** AWS  
**Secondary comparison:** Azure and GCP  
**Class type:** Instructor-led with review, demo, student lab, troubleshooting, discussion, and knowledge check

---

## 1. Class Overview

### Class Title

**AWS CLI Setup, Cost Controls, Tagging, and First Operational Checks**

### Class Purpose

This class teaches students how to safely work with AWS from the command line, understand basic cost controls, create a beginner-friendly tagging standard, and troubleshoot common AWS CLI access issues.

Class 1 focused on AWS account structure, Regions, Availability Zones, the AWS Console, and the shared responsibility model. Class 2 turns that foundation into practical operational habits.

### How This Class Builds From Class 1

In Class 1, students learned to confirm:

```text
Account
Region
Identity
```

In Class 2, students will use those checks more deliberately through the AWS CLI. They will also learn why cloud engineers must care about cost controls, resource ownership, and basic operational hygiene before creating cloud resources.

### What Students Will Build, Analyze, or Practice

Students will:

- Validate AWS CLI installation
- Inspect AWS CLI configuration
- Confirm AWS identity using STS
- Understand CLI profiles and Regions
- Review or create AWS budget alerts
- Create a simple tagging standard
- Run safe read-only AWS CLI commands
- Troubleshoot common CLI errors

---

## 2. Quick Review of Class 1

### Review Points

Students should remember:

1. An **AWS Account** is a billing, security, resource, and governance boundary.
2. A **Region** is a geographic area where AWS services run.
3. An **Availability Zone** is one or more discrete data centers (with independent power, cooling, and networking) inside a Region.
4. Some services are **global**, such as IAM.
5. Some services are **regional**, such as EC2.
6. The **shared responsibility model** means AWS secures the cloud, while customers secure what they configure in the cloud.
7. Before creating anything, students should confirm account, Region, and identity.
8. AWS Account, Azure Subscription, and GCP Project are similar beginner-level containers for resources, access, and cost.

### 3 Quick Recall Questions

#### Question 1

What command confirms the AWS identity used by the CLI?

Expected answer:

```bash
aws sts get-caller-identity
```

#### Question 2

Why does Region matter in AWS?

Expected answer:

```text
Many AWS resources are regional. If you are in the wrong Region, resources may appear missing or commands may run in the wrong location.
```

#### Question 3

What does the shared responsibility model mean?

Expected answer:

```text
AWS secures the underlying cloud infrastructure. Customers are responsible for securing identities, data, applications, network access, and configurations.
```

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students confuse account and user | Explain that the account is the container, while a user or role is an identity inside or associated with that account |
| Students think Console access means CLI access automatically works | Explain that browser login and CLI credentials are separate unless using CloudShell or SSO-based workflows |
| Students confuse authentication and authorization | Authentication confirms who you are; authorization controls what you can do |
| Students forget Region selection | Reinforce that Region must be checked before troubleshooting missing resources |
| Students think cost only matters in production | Explain that lab environments can also create real cost |

### Bridge Into Class 2

Instructor transition:

```text
In Class 1, we learned how to identify where we are in AWS. In Class 2, we will practice how cloud engineers use the terminal to validate access, avoid mistakes, apply cost awareness, and document ownership before doing real infrastructure work.
```

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Validate** AWS CLI installation and configuration.
2. **Explain** AWS CLI profiles, credentials, Regions, and output formats.
3. **Run** safe read-only AWS CLI commands.
4. **Troubleshoot** common AWS CLI errors related to credentials, profiles, permissions, and Regions.
5. **Explain** why AWS Budgets and cost alerts are important.
6. **Document** a basic tagging standard for lab and enterprise resources.
7. **Compare** AWS cost and tagging concepts with Azure and GCP equivalents.
8. **Apply** a safe operational checklist before creating or changing AWS resources.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should already know:

- AWS Account basics
- Region vs Availability Zone
- Global vs regional services
- Shared responsibility model
- AWS Console navigation
- How to find the AWS account ID
- Basic meaning of IAM identity
- Why account, Region, and identity checks matter

### Required Prior Concepts

Students should understand:

- Basic terminal commands
- Basic Linux or command prompt navigation
- Environment variables at a basic level
- Basic authentication and authorization concepts
- Basic cloud cost awareness

### Required Tools Already Installed

Students should have:

- AWS CLI v2
- Terminal or command prompt
- Browser
- VS Code
- Access to AWS Console or AWS CloudShell

### Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should have recorded:

```text
AWS Account ID:
Current Region:
IAM User or Role ARN:
CLI Profile, if available:
```

Optional student notes file:

```text
week4-class1-aws-identity-notes.md
```

For Class 2, students can create:

```text
week4-class2-aws-cli-cost-tags.md
```

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| AWS CLI | Command-line tool used to interact with AWS services | DevOps, Cloud, and SRE teams use it for automation, validation, and troubleshooting |
| CLI Profile | A named AWS CLI configuration | Engineers use profiles to switch between dev, test, prod, sandbox, or shared services accounts |
| Credentials | Information used by AWS CLI to authenticate | Can come from access keys, SSO, environment variables, CloudShell, or assumed roles |
| Region | AWS geographic location used by many service commands | If the wrong Region is configured, CLI commands may not find expected resources |
| Output Format | How AWS CLI displays command results | Common formats are JSON, table, and text |
| STS | Security Token Service | Used to confirm identity or assume temporary roles |
| Budget | AWS cost tracking and alerting tool | Helps prevent unexpected charges in lab and enterprise accounts |
| Cost Alert | Notification triggered when spending reaches a threshold | Useful for students, teams, and finance governance |
| Tag | Key-value metadata attached to resources | Used for ownership, cost allocation, automation, and governance |
| Cost Center | Business or accounting label used to track spending | Enterprises often require cost center tags |
| AccessDenied | AWS error showing that the identity lacks permission | The user may be authenticated but not authorized |
| ExpiredToken | AWS error showing temporary credentials expired | Common with SSO or assumed role sessions |
| Least Privilege | Granting only the permissions needed | Reduces security and operational risk |
| IAM Identity Center (SSO) | AWS service that issues short-lived sign-in credentials across accounts; configured via `aws configure sso` / `aws sso login` | The standard 2026 way to get CLI credentials — replaces long-lived access keys |
| JMESPath / `--query` | Query language built into the AWS CLI for filtering JSON output server-side | `aws ec2 describe-regions --query "Regions[].RegionName"` pulls one field; everyday CLI skill |
| jq | Command-line JSON processor used to parse and reshape CLI output locally | `aws ... | jq -r '.Regions[].RegionName'`; the de facto JSON tool in scripts and pipelines |
| Cost Anomaly Detection | ML-based AWS service that flags unusual spend without a fixed threshold | Catches runaway cost a static budget might miss; configured in Week 18 |
| Budget Action | A budget that takes action (apply restrictive policy, stop instances) at a threshold | How a budget enforces rather than only alerts; configured in Week 18 |
| Tag Policy / Tag Enforcement | Org-level controls (Tag Policies, SCPs, IAM `aws:RequestTag` conditions, Config rules) that require tags to exist | How enterprises guarantee tags instead of relying on manual tagging; Week 17 |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS CLI | Main tool for validating account identity, Region, and safe AWS operations |
| AWS Console | Used to review Billing, Budgets, tags, and account settings visually |
| Terminal | Used to run AWS CLI commands |
| AWS CloudShell | Optional fallback when local CLI setup fails |
| VS Code | Used to document lab results and create tagging checklist |
| Browser | Used to access AWS Console and AWS documentation |
| Markdown file | Used to submit lab notes and homework |

---

## 7. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| IAM | Identity and access concepts behind CLI commands |
| STS | Used through `aws sts get-caller-identity` to validate identity |
| AWS Budgets | Used to understand budget alerts and cost controls |
| Billing and Cost Management | Used to review spending and cost visibility |
| Cost Explorer | Introduced as a tool for cost analysis |
| EC2 | Used for safe read-only Region commands |
| S3 | Used for safe read-only bucket listing if permissions allow |
| Resource Groups and Tag Editor | Introduced as a way to view and manage tags |
| AWS Organizations | Mentioned as enterprise-level account and cost governance context |

---

## 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| CLI tool | AWS CLI | Azure CLI | gcloud CLI |
| Cost alerting | AWS Budgets | Azure Cost Management Budgets | Cloud Billing Budgets |
| Resource metadata | Tags | Tags | Labels |
| Resource container | AWS Account | Azure Subscription | GCP Project |
| Identity permissions | IAM | Azure RBAC | Cloud IAM |

Instructor note:

```text
Keep the comparison simple. Students should know that every major cloud has CLI tools, cost controls, and resource metadata. The exact implementation differs by provider.
```

---

## 9. Time-Boxed Instructor Agenda

| Time | Segment | Activity |
|---:|---|---|
| 0:00 to 0:15 | Class 1 Review | Account, Region, identity, shared responsibility |
| 0:15 to 0:35 | Concept Teaching | AWS CLI, credentials, profiles, Regions, output formats |
| 0:35 to 1:00 | Instructor Demo Part 1 | Validate AWS CLI, config, identity, Region |
| 1:00 to 1:15 | Guided Practice | Students run initial CLI validation commands |
| 1:15 to 1:25 | Break | Short break |
| 1:25 to 1:50 | Concept Teaching | Budgets, cost risks, lab cost safety |
| 1:50 to 2:10 | Instructor Demo Part 2 | Budget review and tagging strategy |
| 2:10 to 2:40 | Student Lab | CLI validation, budget review, tagging standard |
| 2:40 to 2:55 | Troubleshooting Activity | Diagnose CLI profile, credentials, Region, and permission failures |
| 2:55 to 3:00 | Wrap-Up | Homework, checklist, preview of Week 6 IAM |

---

## 10. Instructor Lesson Plan

### Step 1: Open With Continuity From Class 1

Instructor says:

```text
Last class, we learned how to safely identify the AWS account, Region, and identity. Today we will do the same thing from the command line and add two professional habits: cost awareness and tagging.
```

Teaching point:

- The CLI is powerful.
- A wrong CLI command in the wrong account can cause real impact.
- Students should build safe habits before automation.

### Step 2: Review Account, Region, Identity

Ask students:

```text
What three things should you confirm before creating or changing anything in AWS?
```

Expected answer:

```text
Account, Region, identity.
```

Then connect to CLI:

```text
The AWS CLI gives us a repeatable way to confirm all three.
```

### Step 3: Explain AWS CLI Configuration

Explain that the AWS CLI needs:

1. Credentials or SSO session
2. Region
3. Output format
4. Optional profile

Show:

```bash
aws configure list
```

Explain:

- It shows where configuration is coming from.
- It does not always mean the user has permission to do everything.
- CLI configuration can come from files, environment variables, SSO, CloudShell, or IAM role.

Pause for questions:

```text
Why might your browser login work while your terminal command fails?
```

Expected answer:

```text
The Console and CLI may use different authentication methods or different identities.
```

### Step 4: Teach AWS Profiles

Explain:

```text
A profile is a named configuration. In real teams, engineers may have separate profiles for sandbox, dev, test, prod, and shared services.
```

Example:

```bash
aws sts get-caller-identity --profile dev
```

Enterprise caution:

```text
A profile named prod should be treated carefully. Always confirm identity before running commands.
```

### Step 4b: Set Up an SSO-Backed Profile (the 2026 default)

This is the primary way to create a profile in a real organization. Long-lived access keys are the legacy fallback, not the starting point.

Walk through `aws configure sso`:

```bash
aws configure sso
```

The CLI prompts:

```text
SSO session name (Recommended): my-org
SSO start URL: https://my-org.awsapps.com/start
SSO region: us-east-1
SSO registration scopes [sso:account:access]:
```

It opens a browser, you authenticate (with MFA), then pick the account and permission set. The CLI offers to name the profile, e.g. `dev-admin`. This writes a `~/.aws/config` block like:

```ini
[sso-session my-org]
sso_start_url = https://my-org.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile dev-admin]
sso_session = my-org
sso_account_id = 123456789012
sso_role_name = DevAdmin
region = us-east-1
output = json
```

Notice there are **no access keys in that file**. Day to day you only run:

```bash
aws sso login --sso-session my-org
aws sts get-caller-identity --profile dev-admin
```

Contrast with the legacy path (mention, do not lead with it):

```bash
# Legacy / last resort only — creates a long-lived secret on disk
aws configure --profile legacy
```

Teaching point:

```text
The SSO profile stores a reference to a session, not a secret. "aws sso login" mints a
short-lived token that expires (you will eventually see ExpiredToken and just log in again).
A "aws configure" profile stores a static access key + secret that never expires on its own —
that is the thing we are moving away from. When you see job postings say "OIDC keyless CI"
or "no static keys," this is the same idea applied to pipelines (we cover that in Week 9 and
Week 19).
```

### Step 5: Instructor Demo Part 1

Students already saw `aws --version`, `aws configure list`, and `aws sts get-caller-identity` in Week 1 and again in Class 1 — do not re-explain the basics from scratch. Run them quickly as a recap, then spend the time on what is new this class: profiles, Region handling, and output shaping with `--query`/`jq`.

Demo (recap, fast):

- `aws sts get-caller-identity` (who/where am I)
- `aws configure list-profiles`
- `aws configure get region`

Demo (new this class, go slow):

- `aws ec2 describe-regions --output table`
- `aws ec2 describe-regions --query "Regions[].RegionName" --output text` (JMESPath)
- piping JSON into `jq` (see Demo Part 1 Step 7b)

Explain each new command before running it.

### Step 6: Guided Student Practice

Students run the same safe commands.

Instructor should check for:

- CLI missing
- Credentials missing
- Wrong profile
- Wrong Region
- Access denied
- Expired token

### Step 7: Teach Cost Controls

Transition:

```text
Now that we can safely identify where we are, we need to talk about what happens when resources are left running.
```

Explain:

- Cloud resources can create cost quickly.
- Budget alerts are a guardrail, not a replacement for cleanup.
- Students must learn cost responsibility early.

Three layers of cost guardrails (introduce all three, even though we only set up budgets today):

```text
1. AWS Budgets (alert)            -> emails you when actual or forecast spend crosses a threshold.
2. AWS Budgets ACTIONS (enforce)  -> a budget can TAKE ACTION at a threshold: apply a restrictive
                                     IAM/SCP policy, or stop/target EC2/RDS instances. This is how a
                                     budget can actually slow runaway spend, not just warn.
3. AWS Cost Anomaly Detection     -> machine-learning monitor that flags unusual spend automatically,
                                     without you guessing a dollar threshold. Catches the "someone
                                     left a GPU instance on" case that a fixed budget might miss.
```

Teaching point:

```text
A plain budget is alert-only. Budget ACTIONS and Cost Anomaly Detection are the next step up.
We name them now and configure them properly in Week 18 (Cost Optimization & Cloud Operations).
Today: every student sets at least a basic budget.
```

Common AWS cost risks:

- EC2 instances
- NAT Gateways
- Load balancers
- RDS databases
- EBS volumes
- Snapshots
- CloudWatch logs
- Unattached Elastic IPs

### Step 8: Teach Tagging

Explain:

```text
Tags answer basic operational questions: who owns this, what environment is it for, what app does it support, and how should cost be tracked?
```

Recommended lab tags:

```text
Environment = training
Owner = student-name
Application = devops-course
ManagedBy = manual-lab
CostCenter = training
```

Enterprise tags:

```text
Environment
Application
Owner
CostCenter
ManagedBy
DataClassification
BusinessUnit
Criticality
```

Manual tagging is a stopgap — say this out loud:

```text
Typing tags by hand does not scale and is exactly what fails in real accounts (untagged EC2
and RDS show up in every cost review). Enterprises ENFORCE tags with:
- Tag Policies (AWS Organizations) — define allowed tag keys/values org-wide
- Service Control Policies / IAM conditions (aws:RequestTag, aws:TagKeys) — deny creating a
  resource unless required tags are present
- AWS Config rules — flag or auto-remediate non-compliant (untagged) resources
Also: tags do not show up in cost reports until you ACTIVATE them as "cost allocation tags"
in Billing, after which Cost Explorer can group spend by Owner, Environment, or CostCenter.
We configure enforcement in Week 17 (Landing Zones) and cost allocation in Week 18.
```

### Step 9: Instructor Demo Part 2

Show:

- Billing and Cost Management
- Budgets
- Cost Explorer overview
- Resource tags on any existing safe resource if available
- Resource Groups and Tag Editor if available

Do not create expensive resources.

### Step 10: Student Lab

Students validate CLI, document identity, review budget area, and create a tagging standard.

### Step 11: Troubleshooting Activity

Use realistic CLI errors and have students classify:

- Authentication issue
- Authorization issue
- Region issue
- Profile issue
- Expired session issue

### Step 12: Wrap-Up and Bridge to Week 6

Instructor says:

```text
This week gave us safe access habits. Next week we go deeper into IAM, where we learn how permissions actually work and why least privilege matters.
```

---

## 11. Instructor Lecture Notes

### AWS CLI Is a Professional Cloud Skill

The AWS Console is useful for learning and visual inspection, but the AWS CLI is essential for automation and troubleshooting.

Instructor talking point:

```text
DevOps Engineers, Cloud Engineers, and SREs often use the CLI because it is repeatable, scriptable, and easier to capture in documentation and runbooks.
```

Examples of real CLI usage:

- Validate identity before deployment
- List resources
- Check service status
- Troubleshoot permissions
- Automate inventory reports
- Run commands in CI/CD pipelines
- Support incident response

### Credentials, Profiles, and Regions

The AWS CLI needs to know:

```text
Who am I?
Where am I working?
How should output be displayed?
```

Explain:

- Credentials answer “who”.
- Region answers “where”.
- Output format answers “how results are shown”.
- Profile helps manage multiple configurations.

Example:

```bash
aws configure list
```

This command helps students see configuration sources.

Common misconception:

```text
Students may think AWS CLI is connected automatically because they can log in to the Console. That is not always true.
```

### Authentication vs Authorization

Use this simple explanation:

```text
Authentication means AWS knows who you are.
Authorization means AWS allows you to perform the action.
```

Example:

- `Unable to locate credentials` means the CLI cannot authenticate.
- `AccessDenied` means the CLI authenticated, but the identity lacks permission.

Instructor talking point:

```text
AccessDenied is not always bad. In enterprise environments, AccessDenied often means least privilege is working.
```

### Profiles in Enterprise Work

Profiles help separate accounts and roles.

Example profile names:

```text
sandbox
dev
test
prod-readonly
shared-services
security-audit
```

Caution:

```text
Never assume a profile is safe based on its name. Always validate the account ID and ARN.
```

### Cost Control Is Part of Cloud Engineering

Cost is not only a finance concern. It is an engineering concern.

Real-world examples:

- A NAT Gateway left running in a lab account creates unexpected monthly cost.
- RDS left running overnight costs money even when unused.
- Load balancers bill hourly.
- Old snapshots accumulate storage cost.
- Long CloudWatch log retention increases cost.

Instructor talking point:

```text
A good cloud engineer thinks about cost before, during, and after deployment.
```

### AWS Budgets

AWS Budgets can alert when cost reaches a threshold.

Teaching points:

- Budgets do not automatically stop resources.
- Budgets help detect unexpected spend.
- Alerts should go to someone who will act.
- Labs should have low budget thresholds.

Example:

```text
Budget amount: 10 USD
Alert threshold: 80%
Notification: student or instructor email
```

### Tagging Is Operational Metadata

Tags help answer:

```text
Who owns this?
What app is this for?
What environment is this?
Can we delete it?
Is it managed manually or by Terraform?
What cost center pays for it?
```

Common misconception:

```text
Students may think tags are optional labels. In enterprises, tags are often required for cost allocation, automation, compliance, and cleanup.
```

### Class 2 Main Message

By the end of class, students should understand:

```text
Safe cloud work is not just logging in. It means validating identity, using the right Region, controlling cost, tagging resources, and understanding permission boundaries.
```

---

## 12. Whiteboard Explanation

### Simple Flow: Safe AWS CLI Workflow

```text
Start AWS Work
      │
      ▼
Check CLI Installed
aws --version
      │
      ▼
Check Configuration
aws configure list
      │
      ▼
Check Active Profile
echo $AWS_PROFILE
      │
      ▼
Check Identity
aws sts get-caller-identity
      │
      ▼
Check Region
aws configure get region
      │
      ▼
Run Read-Only Command
aws ec2 describe-regions
      │
      ▼
Confirm Cost Guardrails
Budget alerts and cleanup plan
      │
      ▼
Apply Tagging Standard
Owner, Environment, Application
      │
      ▼
Create or Change Resources Only When Approved
```

### What Each Component Means

| Component | Meaning |
|---|---|
| CLI installed | The AWS command tool is available |
| Configuration | CLI knows where credentials and Region settings come from |
| Active profile | CLI may be using a named account or role profile |
| Identity | The user or role AWS sees for commands |
| Region | The location where regional commands run |
| Read-only command | Safe command that does not create, update, or delete resources |
| Budget guardrail | Alert system for unexpected cost |
| Tagging standard | Ownership and governance metadata |

### How Class 2 Extends Class 1

Class 1 taught:

```text
Know your AWS account, Region, and identity.
```

Class 2 adds:

```text
Use the CLI to validate account, Region, and identity.
Add cost controls and tags before real infrastructure work.
```

### Enterprise Version of the Diagram

```text
Engineer
  │
  ▼
SSO Login or Role Assumption
  │
  ▼
AWS CLI Profile
  │
  ▼
Account Validation
  │
  ├── Dev Account
  ├── Test Account
  ├── Prod Read-Only Account
  └── Shared Services Account
  │
  ▼
Cost Guardrails
  │
  ├── Budgets
  ├── Cost Explorer
  └── Required Tags
  │
  ▼
Approved Change Workflow
  │
  ├── Git review
  ├── Terraform plan
  ├── Approval
  └── Apply or deploy
```

Instructor explanation:

```text
In a real company, CLI access is usually part of a controlled workflow. Engineers validate who they are, use least privilege, follow tagging standards, and make changes through approved workflows.
```

---

## 13. Instructor Demo Script

### Demo Title

**Validate AWS CLI Access, Review Budget Controls, and Define Tags**

### Demo Objective

Demonstrate how a cloud engineer safely validates AWS CLI access, checks Region and identity, reviews cost controls, and defines a tagging standard.

### Required Setup

Instructor needs:

- AWS CLI installed
- AWS sandbox or training account
- AWS Console access
- AWS CLI credentials, SSO, role, or CloudShell access
- Approved training Region, such as `us-east-1`
- Budget permissions if creating or showing AWS Budgets

### Demo Part 1: AWS CLI Validation

#### Step 1: Validate CLI Installation

Command:

```bash
aws --version
```

Expected output:

```text
aws-cli/2.x.x Python/3.x.x ...
```

Explain:

```text
This confirms the AWS CLI is installed. It does not confirm that we are authenticated.
```

#### Step 2: Check CLI Configuration

Command:

```bash
aws configure list
```

Expected output example (SSO-backed profile, the path we want):

```text
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile               dev-admin           manual    --profile
access_key     ****************XYZW              sso         sso
secret_key     ****************WXYZ              sso         sso
    region                us-east-1      config-file    ~/.aws/config
```

Explain:

```text
Read the Type/Location column first. "sso" means short-lived credentials from IAM Identity
Center that expire on their own. If you instead see "shared-credentials-file" for the keys,
those are static long-lived keys — the legacy pattern we avoid. This command does not prove
you have permission, only where your credentials come from.
```

#### Step 3: List Available Profiles

Command:

```bash
aws configure list-profiles
```

Expected output example:

```text
default
dev
training
```

Explain:

```text
Profiles help engineers separate accounts and roles.
```

#### Step 4: Check Active Environment Profile

Linux/macOS/Git Bash:

```bash
echo $AWS_PROFILE
```

PowerShell:

```powershell
echo $env:AWS_PROFILE
```

Expected output examples:

```text
training
```

or blank if no profile is set.

Explain:

```text
If AWS_PROFILE is set, the CLI may use that named profile instead of default settings.
```

#### Step 5: Confirm Caller Identity

Command:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDAEXAMPLE123456789",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student-user"
}
```

Explain:

```text
This tells us which AWS account and identity our terminal is using.
```

#### Step 6: Check Configured Region

Command:

```bash
aws configure get region
```

Expected output:

```text
us-east-1
```

If blank, set Region:

```bash
aws configure set region us-east-1
```

Explain:

```text
Many AWS commands need a Region. A missing or wrong Region is a common beginner issue.
```

#### Step 7: Run Safe Read-Only Commands

Command:

```bash
aws ec2 describe-regions --output table
```

Expected output:

```text
-------------------------------------------------
|                DescribeRegions                |
+------------------------------------------------+
||                   Regions                    ||
|+----------------+-----------------------------+|
||  RegionName    |  us-east-1                  ||
||  RegionName    |  us-west-2                  ||
|+----------------+-----------------------------+|
```

Optional command if permitted:

```bash
aws s3 ls
```

Expected outcomes:

- Bucket list if allowed
- `AccessDenied` if not authorized

Explain:

```text
AccessDenied does not always mean the CLI is broken. It may mean the identity does not have permission.
```

#### Step 7b: Shape Output with --query (JMESPath) and jq

This is a high-ROI, frequently-interviewed skill. The AWS CLI returns JSON; you rarely want all of it.

Server-side filtering with `--query` (JMESPath, built into the CLI — no extra tool):

```bash
# Just the Region names, as plain text
aws ec2 describe-regions --query "Regions[].RegionName" --output text

# Region name + endpoint as a 2-column table
aws ec2 describe-regions \
  --query "Regions[].[RegionName,Endpoint]" \
  --output table

# Pull a single field from your identity
aws sts get-caller-identity --query "Account" --output text
```

Client-side filtering with `jq` (the de facto JSON tool; install with your package manager, e.g. `sudo apt-get install jq` / `brew install jq`):

```bash
# Same result, but parsing the raw JSON locally
aws ec2 describe-regions | jq -r '.Regions[].RegionName'

# Count how many Regions came back
aws ec2 describe-regions | jq '.Regions | length'
```

Explain:

```text
--query filters on the AWS side before the data is printed (less to download, works even
without jq installed). jq filters JSON locally and is far more powerful for reshaping,
combining, and scripting. Senior engineers reach for --query for quick field extraction and
jq when they need real transformation. Both are everyday tools — and a common interview ask is
"get just the instance IDs from describe-instances," which is exactly this pattern:
aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text
```

### Demo Part 2: Budget Review

#### Console Steps

1. Open AWS Console.
2. Search for **Billing and Cost Management**.
3. Open **Budgets**.
4. Show existing budget or create a simple budget if permitted.

Suggested training budget:

```text
Budget name: student-training-budget
Budget amount: 10 USD
Alert threshold: 80 percent
Notification: instructor or student email
```

Explain:

```text
A budget is an alerting mechanism. It does not automatically stop all AWS usage.
```

#### Show (don't necessarily configure) the next two layers

After the basic budget, point the screen at two things so students know they exist:

1. **Budget actions.** When creating/editing a budget, scroll to **Configure thresholds → Attach actions**. Show that an action can apply a restrictive IAM policy or SCP, or stop/target EC2/RDS instances when a threshold is crossed. Say: "This is how a budget can actually enforce, not just email."
2. **Cost Anomaly Detection.** In Billing and Cost Management, open **Cost Anomaly Detection**. Show that you create a *monitor* (e.g. by AWS service) and an *alert subscription*; AWS uses ML to flag unusual spend without you picking a dollar figure.

Explain:

```text
We are only LOOKING today. Configuring budget actions and anomaly monitors is Week 18.
The point now is: a fixed budget alert is the floor, not the ceiling, of cost safety.
```

### Demo Part 3: Tagging Review

#### Console Steps

1. Open any safe existing resource if available.
2. Show the Tags tab or tag section.
3. Explain key-value format.

Recommended tags:

```text
Environment = training
Owner = instructor-name
Application = devops-course
ManagedBy = manual-lab
CostCenter = training
```

If no resources exist, show a tagging standard in VS Code instead.

### Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| AWS CLI not found | Not installed or PATH issue | Use AWS CloudShell |
| Unable to locate credentials | CLI not configured | Use CloudShell or instructor-approved setup |
| ExpiredToken | SSO or temporary session expired | Reauthenticate |
| AccessDenied | Missing permission | Explain authorization and continue with permitted commands |
| No Region configured | Region missing | Set Region with `aws configure set region us-east-1` |
| Budget page unavailable | Permission or account type limitation | Show screenshot or instructor demo account |
| `aws s3 ls` denied | No S3 list permission | Explain least privilege and move on |

### Cleanup Steps

No cloud resources should be created unless the instructor intentionally creates a budget.

If budget was created only for demo and should be removed:

1. Open Billing and Cost Management.
2. Go to Budgets.
3. Select demo budget.
4. Delete budget if not needed.

Do not delete real training budget alerts.

---

## 14. Student Lab Manual

### Lab Title

**AWS CLI Validation, Budget Awareness, and Tagging Standard**

### Lab Objective

Students will validate AWS CLI access, document their active identity and Region, review AWS budget controls, and create a tagging standard for future labs.

### Estimated Time

45 to 60 minutes

### Student Prerequisites

Students need:

- AWS Console access
- AWS CLI installed or AWS CloudShell access
- Approved AWS Region from instructor
- Class 1 notes with AWS account and Region
- Terminal access

### Starting Point From Class 1

Students should already know:

```text
AWS Account ID:
AWS Region:
IAM user or role ARN:
```

They will now verify this from the AWS CLI.

### Workflow Overview

```text
Open terminal
   │
   ▼
Check AWS CLI version
   │
   ▼
Inspect AWS CLI configuration
   │
   ▼
Check profile and Region
   │
   ▼
Confirm caller identity
   │
   ▼
Run safe read-only commands
   │
   ▼
Review budget controls
   │
   ▼
Create tagging standard
   │
   ▼
Document results
```

### Step-by-Step Student Instructions

#### Step 1: Create Lab Notes File

Create a file named:

```text
week4-class2-aws-cli-cost-tags.md
```

Add this template:

```markdown
# Week 4 Class 2 Lab Notes

## AWS CLI Validation
AWS CLI version:
CLI profile:
Configured Region:
Account ID:
ARN:
UserId:

## Budget Review
Budget exists:
Budget name:
Budget amount:
Alert threshold:
Notification target:

## Tagging Standard
Environment:
Owner:
Application:
ManagedBy:
CostCenter:

## Troubleshooting Notes
Issue encountered:
Cause:
Fix:
```

#### Step 2: Validate AWS CLI Installation

Run:

```bash
aws --version
```

Expected output:

```text
aws-cli/2.x.x Python/3.x.x ...
```

Record the version in your notes.

If the command fails, use AWS CloudShell (the terminal icon in the Console top bar) — it needs no credentials. Do not create access keys to "fix" a local CLI problem. If your lab uses IAM Identity Center, sign in first with `aws sso login --sso-session my-org`.

#### Step 3: Inspect AWS CLI Configuration

Run:

```bash
aws configure list
```

Look at the **Type/Location** column for `access_key`/`secret_key` and record what it says:

```text
- "sso"                      -> short-lived Identity Center credentials (good, the default we want)
- "shared-credentials-file"  -> static long-lived access keys (legacy; fine for a lab, not ideal)
- not set / from CloudShell  -> CloudShell injects temporary credentials for you
```

Record:

```text
Profile:
Credential source (Type/Location column):
Region:
```

#### Step 4: List CLI Profiles

Run:

```bash
aws configure list-profiles
```

Expected output example:

```text
default
training
```

If no profiles appear, write:

```text
No named profiles configured.
```

#### Step 5: Check Active Profile

Linux/macOS/Git Bash:

```bash
echo $AWS_PROFILE
```

PowerShell:

```powershell
echo $env:AWS_PROFILE
```

If blank, write:

```text
No AWS_PROFILE environment variable set.
```

#### Step 6: Confirm Caller Identity

Run:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDAEXAMPLE123456789",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student-user"
}
```

Record:

```text
Account ID:
ARN:
UserId:
```

#### Step 7: Confirm Region

Run:

```bash
aws configure get region
```

Expected output:

```text
us-east-1
```

If blank, set the instructor-approved Region:

```bash
aws configure set region us-east-1
```

Then run again:

```bash
aws configure get region
```

#### Step 8: Run Safe Read-Only Command

Run:

```bash
aws ec2 describe-regions --output table
```

Expected output:

```text
A table listing AWS Regions.
```

Now shape the output two ways and record the results.

With `--query` (JMESPath, built into the CLI):

```bash
aws ec2 describe-regions --query "Regions[].RegionName" --output text
```

With `jq` (if installed):

```bash
aws ec2 describe-regions | jq -r '.Regions[].RegionName'
```

Both should print the same list of Region names. In your notes, write one sentence on the difference: `--query` filters on the AWS side; `jq` parses the JSON locally.

Optional, if instructor permits:

```bash
aws s3 ls
```

If you receive `AccessDenied`, document it. Do not try to bypass permissions.

#### Step 9: Review Budget Controls

In AWS Console:

1. Open **Billing and Cost Management**.
2. Open **Budgets**.
3. Check if a training budget exists.
4. Record:

```text
Budget exists:
Budget name:
Budget amount:
Alert threshold:
Notification target:
```

If you do not have permission to view Budgets, record:

```text
I do not have permission to view AWS Budgets.
```

Then answer:

```text
Why might students not have billing permissions in a shared enterprise account?
```

Expected answer:

```text
Billing access may be restricted to finance, cloud platform, or admin teams.
```

#### Step 10: Create a Tagging Standard

Create a tagging standard for future labs:

```text
Environment = training
Owner = your-name
Application = devops-course
ManagedBy = manual-lab
CostCenter = training
```

Add two additional tags:

```text
Class = week4
Purpose = aws-foundations
```

#### Step 11: Final Safety Checklist

Add this checklist to your notes:

```text
Before creating AWS resources, I will check:
[ ] AWS account ID
[ ] AWS Region
[ ] AWS CLI identity
[ ] Active CLI profile
[ ] Whether the command creates cost
[ ] Required tags
[ ] Cleanup steps
```

### Expected Outputs

Students should produce:

1. CLI version
2. CLI configuration summary
3. Caller identity output
4. Region output
5. Budget review notes
6. Tagging standard
7. Troubleshooting notes if errors occurred

### Validation Checklist

```text
[ ] I ran aws --version.
[ ] I ran aws configure list.
[ ] I checked AWS profiles.
[ ] I checked active AWS_PROFILE.
[ ] I ran aws sts get-caller-identity.
[ ] I confirmed my AWS Region.
[ ] I ran a safe read-only AWS CLI command.
[ ] I reviewed budget settings or documented lack of access.
[ ] I created a tagging standard.
[ ] I documented safety checks before creating resources.
```

### Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `aws: command not found` | CLI missing or PATH issue | Use CloudShell or install AWS CLI |
| `Unable to locate credentials` | No credentials configured | Use approved setup or CloudShell |
| `The config profile could not be found` | Wrong profile name | Run `aws configure list-profiles` |
| `You must specify a region` | Region missing | Run `aws configure set region us-east-1` |
| `AccessDenied` | Missing permission | Confirm identity and ask instructor |
| `ExpiredToken` | Temporary credentials expired | Reauthenticate |
| Empty profile output | No profile set | Use default or configure approved profile |

### Cleanup Steps

No AWS resources should be created in this lab.

Optional local cleanup if you set a temporary profile:

Linux/macOS/Git Bash:

```bash
unset AWS_PROFILE
```

PowerShell:

```powershell
Remove-Item Env:AWS_PROFILE
```

Do not delete shared budgets or real account settings.

### Reflection Questions

1. Why is `aws sts get-caller-identity` a safe first command?
2. Why can Console access work while CLI access fails?
3. Why should lab resources have tags?
4. Why are budgets useful even if they do not stop resources automatically?
5. Why is `AccessDenied` sometimes a good sign in enterprise environments?

### Optional Challenge Task

Create a named CLI profile if your instructor allows it. Prefer the SSO-backed path (the 2026 default):

```bash
aws configure sso
# follow the prompts: SSO session name, start URL, SSO region, then pick account + permission set
aws sso login --sso-session my-org
aws sts get-caller-identity --profile <profile-name-it-created>
```

Only if your lab cannot use Identity Center, fall back to a key-based profile (legacy):

```bash
aws configure --profile training
aws sts get-caller-identity --profile training
```

Document how a named profile differs from the default profile, and why the SSO profile (short-lived token, no secret on disk) is safer than the key-based one.

---

## 15. Troubleshooting Activity

### Incident Title

**AWS CLI Works for One Student but Fails for Another**

### Business Impact

A team of new cloud engineers is preparing for AWS labs. Some students can validate AWS CLI access, but others cannot. The instructor cannot move into IAM and VPC labs until students can reliably confirm their account, Region, and identity.

### Symptoms

Student A runs:

```bash
aws sts get-caller-identity
```

Output:

```text
Unable to locate credentials. You can configure credentials by running "aws configure".
```

Student B runs:

```bash
aws ec2 describe-regions
```

Output:

```text
You must specify a region. You can also configure your region by running "aws configure".
```

Student C runs:

```bash
aws s3 ls
```

Output:

```text
An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied
```

Student D runs:

```bash
aws sts get-caller-identity --profile training
```

Output:

```text
The config profile (training) could not be found
```

### Starting Evidence

Students can inspect:

```bash
aws --version
aws configure list
aws configure list-profiles
aws configure get region
aws sts get-caller-identity
```

Linux/macOS/Git Bash:

```bash
echo $AWS_PROFILE
```

PowerShell:

```powershell
echo $env:AWS_PROFILE
```

### Student Investigation Steps

Students should classify each issue:

1. Is AWS CLI installed?
2. Are credentials available?
3. Is a Region configured?
4. Is a named profile being used?
5. Does the named profile exist?
6. Is the identity authenticated?
7. Is the identity authorized for that specific command?

### Expected Root Cause

| Student | Expected Root Cause |
|---|---|
| Student A | Missing credentials |
| Student B | Missing Region |
| Student C | Authenticated but not authorized for S3 list |
| Student D | Profile name does not exist |

### Correct Resolution

#### Student A

Use instructor-approved credential setup or AWS CloudShell.

```bash
aws configure list
```

#### Student B

Set approved Region:

```bash
aws configure set region us-east-1
```

Validate:

```bash
aws configure get region
```

#### Student C

Confirm identity:

```bash
aws sts get-caller-identity
```

Explain:

```text
This is an authorization issue, not necessarily an authentication issue.
```

Do not request admin access unless required for the lab.

#### Student D

List valid profiles:

```bash
aws configure list-profiles
```

Use an existing profile:

```bash
aws sts get-caller-identity --profile existing-profile-name
```

### Common Wrong Paths

Students may:

- Reinstall AWS CLI unnecessarily
- Use root credentials
- Create new access keys without approval
- Randomly switch Regions
- Assume AccessDenied means AWS is broken
- Try commands in production
- Ignore `AWS_PROFILE`
- Delete configuration files without understanding the impact

### Instructor Hints

Use in order:

```text
What command proves which identity your terminal is using?
```

```text
Is the error about missing credentials or missing permission?
```

```text
Which profile is the CLI trying to use?
```

```text
Does the command need a Region?
```

```text
Is the command read-only or could it change something?
```

### Preventive Action

Create a standard AWS CLI pre-check:

```bash
aws --version
aws configure list
aws configure list-profiles
aws configure get region
aws sts get-caller-identity
```

Students should document:

```text
Account:
Region:
Profile:
ARN:
Permission issue, if any:
```

---

## 16. Scenario-Based Discussion Questions

### Question 1

**Why should a cloud engineer validate AWS CLI identity before running any command?**

Expected response themes:

- Avoid wrong account
- Avoid wrong identity
- Prevent accidental production changes
- Improve troubleshooting
- Support auditability

Follow-up prompt:

```text
What could happen if your CLI is pointed to production but you think it is using sandbox?
```

### Question 2

**Is `AccessDenied` always a bad thing?**

Expected response themes:

- Not always
- It may show least privilege is working
- It helps prevent unsafe actions
- It should be investigated, not bypassed

Follow-up prompt:

```text
How do you decide whether AccessDenied is a problem or expected behavior?
```

### Question 3

**Why are budget alerts important in a training account?**

Expected response themes:

- Prevent surprise cost
- Catch forgotten resources
- Build professional habits
- Help instructors manage shared environments

Follow-up prompt:

```text
Why is a budget alert not the same as automatic cleanup?
```

### Question 4

**Why do enterprises require tags on cloud resources?**

Expected response themes:

- Ownership
- Cost allocation
- Cleanup
- Automation
- Compliance
- Reporting

Follow-up prompt:

```text
What problem happens when resources have no Owner or Environment tag?
```

### Question 5

**Should beginner students have administrator access in AWS labs?**

Expected response themes:

- Easier for labs but risky
- Least privilege is safer
- Sandbox accounts reduce risk
- Permissions should match the lab
- Admin access should not be used in production

Follow-up prompt:

```text
How can instructors balance learning access with security?
```

### Question 6

**How does Class 2 build on Class 1?**

Expected response themes:

- Class 1 taught account, Region, identity
- Class 2 validates those with CLI
- Class 2 adds cost and tagging
- Both build safe cloud habits

Follow-up prompt:

```text
What is the most important habit from Week 4?
```

### Question 7

**What is the difference between a CLI profile and an AWS account?**

Expected response themes:

- Account is the cloud container
- Profile is local CLI configuration
- A profile may point to an identity in an account
- Multiple profiles can exist for different accounts or roles

Follow-up prompt:

```text
Why can profile names be misleading?
```

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

Which command shows the installed AWS CLI version?

A. `aws version show`  
B. `aws --version`  
C. `aws cli check`  
D. `aws sts version`

**Answer:** B  
**Explanation:** `aws --version` confirms the AWS CLI is installed and displays version information.

### Question 2: Multiple Choice

Which command confirms the AWS account and identity used by the CLI?

A. `aws configure get region`  
B. `aws sts get-caller-identity`  
C. `aws ec2 describe-regions`  
D. `aws iam list-users`

**Answer:** B  
**Explanation:** `aws sts get-caller-identity` returns the account ID, user ID, and ARN.

### Question 3: True/False

AWS Budgets automatically stops all resources when the budget threshold is reached.

**Answer:** False  
**Explanation:** AWS Budgets sends alerts. It does not automatically stop all resources by default.

### Question 4: True/False

A CLI profile is the same thing as an AWS account.

**Answer:** False  
**Explanation:** A profile is local CLI configuration. An AWS account is the cloud resource, billing, and security boundary.

### Question 5: Short Answer

Name three things students should check before creating AWS resources.

**Answer:** Account, Region, and identity.  
**Explanation:** This continues the Class 1 safety model and applies it in CLI workflows.

### Question 6: Troubleshooting

A student runs:

```text
aws sts get-caller-identity
```

And receives:

```text
Unable to locate credentials
```

What is the likely issue?

**Answer:** The AWS CLI cannot find credentials.  
**Explanation:** The CLI may be installed, but authentication is not configured or available.

### Question 7: Troubleshooting

A student runs:

```text
aws s3 ls
```

And receives:

```text
AccessDenied
```

Does this always mean the CLI is broken?

**Answer:** No.  
**Explanation:** The student may be authenticated but not authorized to list S3 buckets.

### Question 8: Multiple Choice

Which tag is most useful for identifying who is responsible for a resource?

A. Color  
B. Owner  
C. Random  
D. VersionOnly

**Answer:** B  
**Explanation:** The Owner tag helps identify the person or team responsible for the resource.

### Question 9: Class 1 and Class 2 Connection

Class 1 taught students to identify the AWS account and Region in the Console. What does Class 2 add?

**Answer:** Class 2 teaches students to validate account, Region, and identity using the AWS CLI, then add cost and tagging awareness.  
**Explanation:** Class 2 operationalizes Class 1 concepts.

### Question 10: Class 1 and Class 2 Connection

Why does the shared responsibility model connect to CLI usage?

**Answer:** Because customers are responsible for how they configure access, credentials, permissions, and resource changes made through the CLI.  
**Explanation:** AWS provides the CLI and platform, but the customer must use them safely.

### Question 11: Short Answer

Name three AWS services or areas that can create unexpected lab cost.

**Answer:** Examples include EC2, NAT Gateway, RDS, load balancers, EBS volumes, snapshots, CloudWatch logs, and unattached Elastic IPs.  
**Explanation:** These services can continue billing if left running or retained.

### Question 12: Multiple Choice

Which command checks the configured AWS Region?

A. `aws configure get region`  
B. `aws region show`  
C. `aws iam get-region`  
D. `aws sts get-region`

**Answer:** A  
**Explanation:** `aws configure get region` returns the configured Region.

---

## 18. Homework Assignment

### Assignment Title

**AWS CLI Safety, Budget Awareness, and Tagging Checklist**

### Scenario

You are joining an enterprise cloud platform team. Before you are allowed to deploy infrastructure, your team lead asks you to create a practical checklist that proves you can safely use the AWS CLI, understand basic cost controls, and apply a tagging standard.

### Student Tasks

Create a 1 to 2 page checklist that includes:

1. How to verify AWS CLI is installed
2. How to check AWS CLI configuration
3. How to identify the active CLI profile
4. How to confirm AWS account and identity
5. How to confirm the configured Region
6. How to identify whether an error is authentication or authorization related
7. Why budget alerts matter
8. At least five common AWS lab cost risks
9. A required tagging standard for future labs
10. A cleanup reminder before ending each lab

### Expected Deliverables

Submit a Markdown, Word, or PDF document.

Suggested format:

```markdown
# AWS CLI Safety, Budget, and Tagging Checklist

## CLI Validation Commands

## Account and Region Checks

## Authentication vs Authorization

## Budget and Cost Safety

## Required Tags

## Cleanup Checklist

## Questions I Still Have
```

### Submission Format

File name:

```text
week4-class2-aws-cli-safety-yourname.md
```

### Estimated Completion Time

45 to 60 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| CLI validation commands included | 20 |
| Account, Region, and identity checks included | 20 |
| Authentication vs authorization explanation | 15 |
| Budget and cost risks included | 20 |
| Tagging standard included | 15 |
| Clear formatting and practical usefulness | 10 |

### Optional Advanced Challenge

Add a profile-based workflow example:

```bash
aws configure list-profiles
aws sts get-caller-identity --profile training
aws configure get region --profile training
```

Then explain how named profiles help engineers avoid working in the wrong account.

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Assuming Console access means CLI access works | Students do not realize Console and CLI can use different auth methods | Always validate CLI separately |
| Forgetting to check active profile | Profiles are new to beginners | Run `aws configure list-profiles` and check `AWS_PROFILE` |
| Running commands in wrong Region | Region is easy to overlook | Run `aws configure get region` before labs |
| Treating `AccessDenied` as a broken CLI | Students confuse auth and permissions | Explain authentication vs authorization |
| Creating access keys without approval | Students try to fix CLI quickly | Use instructor-approved setup or CloudShell |
| Using root credentials | Students may not understand root risk | Root should not be used for daily work |
| Ignoring budget alerts | Students think labs are always free | Teach common cost risks early |
| Using vague tags | Students do not know enterprise tagging standards | Provide required tags |
| Leaving resources running | Cleanup habits are not automatic | End every lab with cleanup checklist |
| Copying CLI commands blindly | Students want quick completion | Ask students to explain commands before running |

---

## 20. Real-World Enterprise Scenario

### Scenario

A company has recently created AWS sandbox accounts for new DevOps, Cloud Engineering, and SRE team members. Before engineers can work on real environments, they must prove they can use AWS CLI safely, understand cost controls, and follow tagging rules.

The cloud platform team has seen previous issues:

- Resources created in the wrong account
- Test resources left running over the weekend
- Untagged EC2 and RDS resources
- CLI commands run against production by mistake
- Engineers requesting admin permissions for simple tasks
- Budget alerts ignored until finance escalates

### Constraints

| Constraint | Example |
|---|---|
| Access control | Students only receive limited sandbox permissions |
| Cost | Budget threshold is low and monitored |
| Security | No root user usage allowed |
| Governance | Required tags must be applied to future resources |
| Reliability | Production access requires separate approval |
| Audit | All API activity is logged |
| Team workflow | CLI use must be documented in runbooks or lab notes |

### How the Class Topic Applies

This class teaches the operational foundation for avoiding those issues:

- Validate identity before commands
- Confirm account and Region
- Use profiles carefully
- Review budget controls
- Apply tags consistently
- Understand AccessDenied as part of least privilege

### Role Responsibilities

#### DevOps Engineer

- Validates CLI identity before running deployment pipelines
- Uses profiles or roles for environment-specific access
- Ensures deployment resources are tagged

#### Cloud Engineer

- Defines tagging standards and cost guardrails
- Helps teams configure safe CLI access
- Reviews account and Region usage

#### SRE

- Uses CLI during incident response
- Confirms identity before operational actions
- Checks whether missing permissions affect incident response workflows

---

## 21. Instructor Tips

### Teaching Tips

- Repeat: **account, Region, identity, cost, tags**.
- Keep CLI commands safe and read-only.
- Explain each command before students run it.
- Use real error messages to reduce fear of troubleshooting.
- Do not go too deep into IAM policy syntax yet. That is Week 6.

### Pacing Tips

- Keep the Class 1 review short.
- Spend enough time on CLI errors because many beginners get stuck there.
- Do not let budget setup consume the entire class if permissions vary.
- If students cannot access Billing, turn it into a discussion and documentation task.

### Lab Support Tips

Ask struggling students:

```text
What exact command did you run?
What exact error did you receive?
What does aws configure list show?
What does aws sts get-caller-identity show?
Which Region are you using?
```

### Helping Struggling Students

Use simple explanations:

- Credentials = how your CLI proves who you are
- Profile = named CLI setup
- Region = where AWS command runs
- AccessDenied = you are known, but not allowed
- Budget = cost alert, not automatic shutdown
- Tag = label for ownership and governance

### Challenging Advanced Students

Ask advanced students to:

- Create a profile naming standard
- Compare AWS tags, Azure tags, and GCP labels
- Explain temporary credentials vs long-lived access keys
- Draft an enterprise CLI access policy
- Identify which commands are safe read-only commands

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

```text
[ ] What the AWS CLI is used for.
[ ] What an AWS CLI profile is.
[ ] Why Region matters in CLI commands.
[ ] What credentials are used for.
[ ] Difference between authentication and authorization.
[ ] Why AWS Budgets matter.
[ ] Why tagging is important.
[ ] How Class 2 builds from Class 1 account, Region, and identity checks.
```

### Students Should Be Able to Build or Configure

```text
[ ] Run aws --version.
[ ] Run aws configure list.
[ ] Run aws configure list-profiles.
[ ] Check active AWS_PROFILE.
[ ] Run aws sts get-caller-identity.
[ ] Check configured Region.
[ ] Set Region if needed.
[ ] Run safe read-only CLI commands.
[ ] Review budget settings or document lack of access.
[ ] Create a tagging standard.
```

### Students Should Be Able to Troubleshoot

```text
[ ] AWS CLI not installed.
[ ] Missing credentials.
[ ] Wrong or missing profile.
[ ] Missing Region.
[ ] AccessDenied error.
[ ] ExpiredToken error.
[ ] Console and CLI identity mismatch.
[ ] Budget access denied.
```

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

```text
[ ] Students completed Class 1 review.
[ ] Students understand AWS CLI purpose.
[ ] Students ran aws --version.
[ ] Students ran aws configure list.
[ ] Students checked profile behavior.
[ ] Students ran aws sts get-caller-identity.
[ ] Students checked or set Region.
[ ] Students reviewed budget concepts.
[ ] Students created a tagging standard.
[ ] Troubleshooting activity was completed.
[ ] Homework was explained.
[ ] Week 6 IAM preview was given.
```

### Student Checklist Before Leaving Class

```text
[ ] I documented my AWS CLI version.
[ ] I documented my AWS profile.
[ ] I documented my configured Region.
[ ] I documented my AWS account ID.
[ ] I documented my ARN.
[ ] I understand common CLI errors.
[ ] I understand why budget alerts matter.
[ ] I created a tagging standard.
[ ] I know what to check before creating AWS resources.
```

### Items to Verify Before Closing the Week

```text
[ ] Students can access AWS Console or CloudShell.
[ ] Students can validate AWS CLI identity.
[ ] Students know the approved training Region.
[ ] Students understand budget and cost warnings.
[ ] Students understand required tags for future labs.
[ ] No unnecessary AWS resources were created.
[ ] Students are prepared for Week 6 IAM and Security Foundations.
```

---

## 24. End-of-Week Summary

### What Students Learned This Week

During Week 4, students learned:

- What AWS is and how enterprises use it
- How AWS accounts, Regions, and Availability Zones work
- How the AWS shared responsibility model applies to cloud work
- How to navigate the AWS Console safely
- How to validate AWS CLI access
- How to confirm account, Region, and identity
- How to recognize common CLI errors
- Why budget alerts and cost awareness matter
- Why tagging is important for ownership and governance
- How AWS account concepts compare with Azure subscriptions and GCP projects

### How Class 1 and Class 2 Connect

Class 1 introduced the AWS mental model:

```text
Account
Region
Identity
Responsibility
```

Class 2 made that model operational:

```text
Validate account with CLI
Validate Region with CLI
Validate identity with STS
Add budget awareness
Add tagging standards
Troubleshoot access issues
```

### How This Week Prepares Students for the Next Week

Week 6 focuses on **AWS IAM and Security Foundations**.

Students are now ready to learn IAM because they already understand:

- AWS accounts
- Identities
- CLI access
- Permissions errors
- Shared responsibility
- Least privilege at a beginner level
- Why access control matters

### What Students Should Review Before the Next Module

Students should review:

```text
[ ] AWS Account vs IAM identity
[ ] AWS Region vs Availability Zone
[ ] aws sts get-caller-identity
[ ] aws configure list
[ ] Authentication vs authorization
[ ] AccessDenied meaning
[ ] Shared responsibility model
[ ] Root user risk
[ ] Budget and cost risks
[ ] Tagging standards
```

Week 6 will build directly on this by teaching IAM users, groups, roles, policies, MFA, STS, and least privilege.

---

## Class Artifacts & Validation

Backing module: [`labs/aws-cli-fundamentals/`](../../labs/aws-cli-fundamentals/). This class
**reuses** the identity/region/SSO scripts from Class 1 and adds the **cost & tag governance**
half of the toolkit: `cost-guard.sh` (flags running EC2 / available NAT gateways / idle EIPs /
detached EBS — and exits non-zero so it works as a scheduled cost gate), `tag-audit.sh` (lists
resources missing required `Owner,Environment,Project` tags and exits non-zero on a violation),
and the read-only `inventory.sh` snapshot. All gates were run in this environment (AWS CLI
v2.32.11, bash 5.1, ShellCheck 0.10.0); see the lab
[Validation](../../labs/aws-cli-fundamentals/README.md#validation) section.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/aws-cli-fundamentals/solution/cost-guard.sh | shell | flags running EC2 / available NAT / idle EIP / detached EBS leftovers; **exits 1 on a finding** so it works as a cron/CI cost gate | `bash tests/run-tests.sh` (stub data: `[BURN]` lines + non-zero exit); `shellcheck -x` | PASS (offline suite); live read = $0, no live evidence captured |
| 2 | labs/aws-cli-fundamentals/solution/tag-audit.sh | shell | lists EC2 + EBS missing required governance tags; **exits 1 on any violation** | `bash tests/run-tests.sh` (stub: violations listed + non-zero exit); `shellcheck -x` | PASS (offline suite); live read = $0, no live evidence captured |
| 3 | labs/aws-cli-fundamentals/solution/inventory.sh | shell | read-only EC2 + S3 + IAM snapshot with `(none)` handling and per-section totals | `bash tests/run-tests.sh`; `shellcheck -x` | PASS (offline suite); live read = $0, no live evidence captured |
| 4 | labs/aws-cli-fundamentals/solution/whoami.sh | shell | reused from Class 1 — confirm WHO/WHERE before any read (the safe-workflow first step) | `bash tests/run-tests.sh`; `shellcheck -x` | PASS (offline suite); live read = $0, no live evidence captured |
| 5 | labs/aws-cli-fundamentals/solution/lib/common.sh | shell | shared `aws_region()` / `require_aws_creds()` profile + region precedence chain used by every script | `shellcheck -x` + `bash -n` (via `./validate.sh`) | PASS |
| 6 | labs/aws-cli-fundamentals/solution/sso-config.md | docs | `aws configure sso` walkthrough — the SSO-backed profile set up in Step 4b | gate: file present (`./validate.sh`) | PASS |
| 7 | labs/aws-cli-fundamentals/tests/run-tests.sh | shell | 50 offline functional assertions (stub `aws`, no real account) including the read-only static gate over `solution/` | `bash tests/run-tests.sh` | PASS (50/50, exit 0) |
| 8 | labs/aws-cli-fundamentals/validate.sh | shell | module gate runner (`bash -n` + offline suite + `shellcheck -x`) | `./validate.sh` | PASS (26 passed, 0 failed, exit 0) |

> **Honesty note on "live."** `cost-guard.sh` / `tag-audit.sh` / `inventory.sh` are validated
> **only** against canned stub data in the offline suite — they have **not** been run against a
> real account this week (`labs/aws-cli-fundamentals/LIVE-AWS-VALIDATION.txt` is empty). Every
> verb is read-only and the live read is **$0**, but there is no live cost-finding or tag-violation
> evidence on disk. Treat the PASS marks as **static + offline-functional**, not a live operation.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence) — `cost-guard.sh`, `tag-audit.sh`, `inventory.sh`, and the reused identity/region scripts live in `labs/aws-cli-fundamentals/`.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `bash -n`, the 50-assertion offline suite (including cost/tag exit-code and read-only static gates), and `shellcheck -x` all pass via `./validate.sh` (26 passed, 0 failed).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `starter/cost-guard.sh` and `starter/tag-audit.sh` gap the detection/parsing blocks; `solution/` is the reference.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — all present.
- [x] **Cleanup/teardown** is provided and idempotent — toolkit is strictly read-only (creates nothing; only *reports* cost/tag findings); README documents `aws sso logout`.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — lab key in `README` "Instructor answer key" (cost/tag exit codes, read-only-only, no `create-tags` remediation); quiz key in §17; troubleshooting resolution in §15.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the false-success credential probe (`broken/whoami-broken.sh`) plus the profile/region confusion drive the §15 incident; reproduced by the offline suite.
- [x] **Expected outputs** are shown for demos and labs — README "Expected results" (`== N finding(s) ==` / `== N missing-tag violation(s) ==`) plus §13/§14 expected outputs.
- [x] **Cost & security warnings** present — README "Cost considerations" (the lab itself is $0; `cost-guard.sh` exists to *save* money) and "Security considerations" (least privilege, read-only by construction, no secrets).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links back to Class 1 and `labs/aws-cli-fundamentals/`, forward to Week 6 (IAM) verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — all rows `ls`-verified.
- [ ] **Live operation against a real account is NOT captured** — `LIVE-AWS-VALIDATION.txt` is empty; cost/tag findings are exercised only against stub data. Validation is static + offline-functional only.
