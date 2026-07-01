# Week 4: AWS Cloud Foundations
> **▶ Runnable lab for this class:** [`labs/aws-cli-fundamentals/`](../../labs/aws-cli-fundamentals/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1: Understanding AWS Accounts, Global Infrastructure, and Cloud Responsibility

**Week:** 4 · Class 1  
**Track:** Unified DevOps · Cloud · SRE Track  
**Duration:** 3 hours  
**Audience:** Beginner to intermediate  
**Primary cloud:** AWS  
**Secondary comparison:** Azure and GCP  
**Class type:** Instructor-led with demo, lab, troubleshooting, and discussion

---

## 1. Class Overview

### Class Title

**Understanding AWS Accounts, Global Infrastructure, and Cloud Responsibility**

### Class Purpose

This class introduces students to the foundational AWS concepts they need before they start creating infrastructure. The goal is not to deploy complex AWS resources yet. The goal is to help students safely understand where they are working, what account they are using, what Region they are in, what AWS is responsible for, and what the customer is responsible for.

### How This Class Connects to the Overall Course

This class begins the AWS foundation phase of the course. Previous weeks covered Linux (Week 2) and Git (Week 3). This week connects those skills to cloud operations. Networking and VPC come next, in Week 5, so this week stays high-level about networking and does not assume students have built a VPC yet.

Students will use AWS throughout the rest of the course for IAM (Week 6), VPC (Week 5), EC2/Storage/Databases (Week 7), CI/CD (Week 9), Docker (Week 10), Kubernetes (Weeks 11-13), Terraform (Weeks 14-15), observability (Week 16), security (Week 19), and SRE/incident response (Week 21). Before doing any of that, they need safe account habits.

### What Students Will Build, Analyze, or Practice

Students will:

- Navigate the AWS Console
- Identify the current AWS account
- Identify the active AWS Region
- Understand Regions and Availability Zones
- Run safe AWS CLI identity checks
- Compare AWS account structure with Azure and GCP
- Practice basic cloud account safety habits

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** what AWS is and how enterprises use cloud accounts.
2. **Describe** AWS Regions, Availability Zones, and edge locations.
3. **Compare** AWS Accounts, Azure Subscriptions, and GCP Projects.
4. **Explain** the AWS shared responsibility model.
5. **Navigate** the AWS Console safely.
6. **Validate** the active AWS account identity using the AWS CLI.
7. **Identify** common beginner mistakes that create security or cost risk.
8. **Document** the account, Region, and identity information needed before working in AWS.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic terminal usage
- Basic Git concepts
- Basic networking concepts such as IPs, DNS, ports, and HTTP
- Basic Linux command-line navigation
- Difference between local machine and remote/cloud environment

### Required Tools Already Installed

Students should have:

- VS Code
- Terminal or command prompt
- Git
- AWS CLI v2
- Browser access to AWS Console

### Required Accounts or Access

Students need one of the following:

- AWS lab account
- AWS sandbox account
- Instructor-provided AWS account access
- AWS IAM user, IAM role, or SSO access

### Files, Repos, or Sample Code Needed

No application code is required for this class.

Optional class file:

```text
week4-class1-aws-identity-notes.md
```

Students can use this file to record:

```text
AWS Account ID:
AWS Region:
IAM User or Role ARN:
CLI Profile:
Cloud Provider Comparison Notes:
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| AWS | Amazon Web Services, a cloud platform used to run infrastructure and applications | Enterprises use AWS to host apps, databases, networks, storage, Kubernetes, and automation |
| AWS Account | A container for AWS resources, billing, access control, and governance | Companies usually separate dev, test, prod, security, and shared services into different accounts |
| Region | A geographic area where AWS runs cloud services | Example: `us-east-1` is a commonly used Region in North Virginia |
| Availability Zone | One or more discrete data centers (not a single building) with independent power, cooling, and networking inside a Region | Apps can run across multiple AZs for better availability. Note: AZ *names* like `us-east-1a` are mapped per account, so one account's `us-east-1a` is not guaranteed to be the same physical AZ as another account's `us-east-1a`. The stable identifier is the AZ *ID* (e.g. `use1-az1`). |
| Edge Location | A location closer to users, often used by services like CloudFront | Helps reduce latency for global users |
| IAM | Identity and Access Management | Controls who can access AWS and what they can do |
| ARN | Amazon Resource Name, a unique identifier for AWS resources and identities | Used to identify users, roles, policies, buckets, and other resources |
| Shared Responsibility Model | AWS secures the cloud infrastructure, while customers secure what they build in AWS | AWS protects the data centers; customers protect IAM, data, network rules, and app configuration |
| AWS Console | Web interface for managing AWS services | Useful for learning, viewing resources, and performing guided admin tasks |
| AWS CLI | Command-line tool for interacting with AWS | Used heavily in DevOps, automation, troubleshooting, and scripting |
| Billing Boundary | A separation point for tracking cost | AWS accounts help separate billing by team, app, or environment |
| Security Boundary | A separation point for controlling access and blast radius | A production account should not be treated like a sandbox account |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | To visually explore AWS services, account settings, Regions, IAM, and billing areas |
| AWS CLI | To validate account identity and introduce command-line cloud operations |
| Terminal | To run AWS CLI commands and inspect configuration |
| Browser | To access AWS Console and AWS documentation |
| VS Code | To document notes, commands, and class observations |
| Text/Markdown file | To capture lab evidence and student findings |

---

## 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| AWS Management Console | Main web interface students use to explore AWS safely |
| IAM | Introduced as the identity and access foundation of AWS |
| STS | Used through `aws sts get-caller-identity` to confirm the active identity |
| Billing and Cost Management | Introduced to build cost awareness early |
| AWS Budgets | Previewed as a cost control mechanism |
| EC2 | Used lightly to explain Region-specific services |
| S3 | Mentioned as a common global-name service with regional placement |
| AWS Organizations | Introduced conceptually for enterprise account management |

---

## 7. Azure and GCP Comparison Notes

Keep this section short during class. The goal is awareness, not deep multi-cloud design.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Primary cloud container | AWS Account | Azure Subscription | GCP Project |
| Organization-level grouping | AWS Organizations | Management Groups | Resource Hierarchy |
| Web portal | AWS Console | Azure Portal | Google Cloud Console |
| CLI | AWS CLI | Azure CLI | gcloud CLI |
| Identity system | IAM | Microsoft Entra ID / Azure RBAC | Cloud IAM |

Instructor talking point:

```text
For now, think of an AWS Account, Azure Subscription, and GCP Project as the place where cloud resources live, access is controlled, and cost is tracked. They are not identical, but they serve a similar beginner-level purpose.
```

---

## 8. Time-Boxed Instructor Agenda

| Time | Segment | Activity |
|---:|---|---|
| 0:00 to 0:10 | Opening | Welcome, Week 4 context, why AWS foundations matter |
| 0:10 to 0:25 | Review | Connect Linux (W2) and Git (W3) to cloud work; preview that networking is W5 |
| 0:25 to 0:50 | Concept | AWS overview and enterprise usage |
| 0:50 to 1:15 | Concept | Regions, Availability Zones, and global infrastructure |
| 1:15 to 1:25 | Break | Short break |
| 1:25 to 1:50 | Concept | AWS account model and enterprise account separation |
| 1:50 to 2:15 | Concept | Shared responsibility model |
| 2:15 to 2:35 | Demo | AWS Console navigation and identity validation |
| 2:35 to 2:50 | Student Lab | Students validate account, Region, and identity |
| 2:50 to 3:00 | Wrap-Up | Troubleshooting recap, discussion, homework explanation |

---

## 9. Instructor Lesson Plan

### Step 1: Open the Class

Start with:

```text
Today we are moving from general DevOps foundations into AWS. Before we create infrastructure, we need to learn how to safely enter AWS, confirm where we are, understand who we are logged in as, and avoid common security and cost mistakes.
```

Teaching tip:

- Do not start with EC2 or VPC creation.
- Beginners often want to click around and create things.
- Reinforce that cloud safety comes before cloud deployment.

### Step 2: Connect Previous Weeks

Explain:

- Linux skills (Week 2) help students manage cloud servers.
- Git skills (Week 3) help students manage Terraform, Kubernetes manifests, and CI/CD pipelines.
- Networking is taught next week (Week 5). Today we only need a high-level intuition that Regions and Availability Zones are *where* resources live; the deep VPC/subnet/routing work comes in Week 5.

Transition:

```text
AWS is where many of these earlier skills come together. The terminal, networking knowledge, and Git workflow all become part of cloud engineering work.
```

### Step 3: Explain AWS at a High Level

Cover:

- AWS is a cloud platform with hundreds of services.
- Most cloud engineers do not use every service.
- The course will focus on practical services used in DevOps, Cloud Engineering, and SRE roles.

Mention examples:

- IAM for access
- VPC for networking
- EC2 for compute
- S3 for storage
- RDS for databases
- CloudWatch for monitoring
- EKS for Kubernetes
- Terraform for infrastructure automation

Pause for questions:

```text
Which AWS services have you heard of before, even if you have not used them?
```

### Step 4: Teach Global Infrastructure

Draw Region and AZ structure.

Explain:

```text
A Region is a geographic area. An Availability Zone (AZ) is one or more discrete data centers inside that Region, each with independent power, cooling, and networking. AZs in a Region are physically separated but connected by low-latency links. We use multiple AZs to make applications more reliable.
```

Beginner analogy:

```text
Think of a Region like a city, and Availability Zones like separate campuses in that city, each with its own power and water. If one campus has a problem, another campus can continue operating. An AZ is not a single building, and it is not a single server room. It is one or more whole data centers.
```

Precision caveat to mention once (do not over-explain to beginners):

```text
The AZ name you see (us-east-1a) is mapped independently for each AWS account, so your us-east-1a may be a different physical AZ than someone else's. The stable physical identifier is the AZ ID (use1-az1), which you can see with:
aws ec2 describe-availability-zones --query "AvailabilityZones[].[ZoneName,ZoneId]" --output table
This matters when two accounts (for example shared-services and a workload account) try to place resources in "the same" AZ.
```

### Step 5: Teach AWS Account Structure

Explain that an AWS account is not just a login. It is a boundary.

An AWS account is:

- A billing boundary
- A security boundary
- A resource boundary
- A governance boundary

Enterprise example:

```text
A company may have separate AWS accounts for dev, test, prod, shared networking, security logging, and sandbox experimentation.
```

Pause and ask:

```text
Why would production resources be separated from development resources?
```

Expected answers:

- Reduce accidental changes
- Improve access control
- Track cost
- Limit blast radius
- Improve auditability

### Step 6: Teach Shared Responsibility

Use a simple table.

AWS handles:

- Physical data centers
- Hardware
- Global infrastructure
- Managed service infrastructure

Customer handles:

- IAM access
- Application security
- Data protection
- Network rules
- EC2 patching
- Cost controls

Important misconception:

```text
A service being hosted in AWS does not automatically mean it is secure. AWS gives us secure building blocks, but we still have to configure them correctly.
```

### Step 6b: Teach How You Actually Sign In (Identity Center / SSO, not access keys)

This is the single most important habit in this class. Beginners reach for "create an access key" because every old tutorial shows it. In 2026 that is the wrong default.

Explain the credential hierarchy from best to worst:

```text
1. AWS CloudShell           -> zero setup, no credentials on your laptop, temporary
2. IAM Identity Center SSO  -> aws configure sso / aws sso login, short-lived tokens
3. IAM role assumption      -> sts:AssumeRole, temporary credentials
4. Long-lived access keys   -> AVOID. Only when nothing above is possible.
```

Why long-lived access keys are discouraged:

```text
- They are static secrets. If leaked (committed to Git, pasted in a ticket, left in
  ~/.aws/credentials on a shared laptop) they keep working until someone rotates them.
- They do not expire on their own.
- They are the #1 source of real AWS account compromises.
```

What to use instead. IAM Identity Center (formerly "AWS SSO") issues short-lived credentials that expire automatically. Configure it once:

```bash
aws configure sso
```

The CLI prompts for:

```text
SSO session name (Recommended): my-org
SSO start URL: https://my-org.awsapps.com/start
SSO region: us-east-1
SSO registration scopes [sso:account:access]:
```

It opens a browser to log in, then lets you pick the account and permission set. Day to day, you only run:

```bash
aws sso login --sso-session my-org
```

This refreshes a temporary token. There is no secret key stored on disk.

Teaching point:

```text
If your instructor's lab uses Identity Center, you will run "aws sso login" each day.
If it does not, use CloudShell in the browser. Creating personal access keys should be
a last resort and only with explicit instructor approval. We will see all three paths
in the demo.
```

### Step 7: Instructor Demo

Show AWS Console, Region selector, account menu, service search, CloudShell, and CLI identity check.

Pause after demo and ask:

```text
Before creating a resource in AWS, what should you confirm first?
```

Expected answer:

```text
Account, Region, and identity.
```

### Step 8: Student Lab

Have students complete the account identity worksheet.

Walk around or monitor chat for issues:

- AWS CLI not installed
- Wrong Region
- No credentials
- Access denied
- Browser logged into wrong account

### Step 9: Troubleshooting Review

Use errors such as:

```text
Unable to locate credentials
AccessDenied
You must specify a region
```

Explain difference between:

- Authentication: Who are you?
- Authorization: What are you allowed to do?
- Region configuration: Where are you trying to operate?

### Step 10: Wrap-Up

End with:

```text
Today was about safe entry into AWS. In Class 2, we will go deeper into AWS CLI setup, budget alerts, tagging, and safe operational habits.
```

---

## 10. Instructor Lecture Notes

### Opening Talking Points

```text
In real cloud jobs, one of the first skills is not creating infrastructure. It is knowing where you are, what access you have, what environment you are touching, and what risk your action creates.
```

```text
A beginner mistake in AWS can create cost, security exposure, or accidental changes. This week builds safe habits before we move into deeper IAM, networking, compute, and Terraform.
```

### AWS as an Enterprise Platform

AWS is not just a place to launch servers. In enterprise environments, AWS becomes a platform for:

- Hosting applications
- Storing data
- Running Kubernetes
- Managing networking
- Automating infrastructure
- Monitoring systems
- Enforcing security controls
- Supporting disaster recovery

Students should understand that cloud engineering is not only about clicking buttons. It is about controlled, repeatable, secure operations.

### Regions and Availability Zones

AWS Regions allow teams to place resources closer to users or meet compliance needs.

Examples:

- A US-based company may use `us-east-1` or `us-east-2`.
- A European workload may use `eu-west-1`.
- Some services may not be available in every Region.
- Costs can vary by Region.

Availability Zones provide isolation within a Region.

Practical point:

```text
Running an application in one AZ may be okay for a lab. Running production across multiple AZs is a common reliability pattern.
```

### AWS Account as a Boundary

Do not describe an AWS account as only a login. It is broader than that.

An AWS account contains:

- IAM identities
- Resources
- Billing data
- Service quotas
- CloudTrail logs
- Security configuration
- Network resources

Enterprise account patterns:

```text
Sandbox Account: experimentation
Dev Account: development workloads
Test Account: QA and integration testing
Prod Account: customer-facing workloads
Shared Services Account: DNS, networking, shared tools
Security Account: audit logs, security monitoring
```

### Shared Responsibility Model

Key teaching point:

```text
AWS is responsible for security of the cloud. Customers are responsible for security in the cloud.
```

Examples:

- AWS protects the physical data center.
- Customer protects IAM access.
- AWS manages S3 infrastructure.
- Customer controls S3 bucket permissions.
- AWS provides EC2 infrastructure.
- Customer patches the EC2 operating system.

Common misconception:

```text
Students may think managed services remove all customer responsibility. They do not. Managed services reduce operational burden, but customers still configure access, data protection, networking, and monitoring.
```

### Cost Awareness

Even though this class is not a billing deep dive, emphasize that cost awareness starts immediately.

Common costly mistakes:

- Leaving EC2 running
- Creating NAT Gateways unnecessarily
- Leaving load balancers active
- Keeping unattached EBS volumes
- Retaining snapshots
- Creating RDS databases and forgetting them
- Not cleaning up labs

Talking point:

```text
In enterprise work, cloud engineers are expected to think about cost, security, and reliability together.
```

---

## 11. Whiteboard Explanation

### Simple Diagram: AWS Organization and Accounts

```text
Company / Enterprise
│
├── AWS Organization
│   │
│   ├── Security Account
│   │   └── Audit logs, security tools
│   │
│   ├── Shared Services Account
│   │   └── DNS, networking, shared platform services
│   │
│   ├── Dev Account
│   │   └── Development resources
│   │
│   ├── Test Account
│   │   └── QA and integration testing
│   │
│   └── Prod Account
│       └── Production applications and databases
```

### Step-by-Step Explanation

1. The company owns the cloud organization.
2. The organization contains multiple AWS accounts.
3. Each account separates access, cost, and resources.
4. Dev and prod are separated to reduce risk.
5. Security and shared services often have dedicated accounts.
6. Engineers must know which account they are working in before making changes.

The *mechanism* that makes multi-account safety real is **Service Control Policies (SCPs)** in AWS Organizations: org-level guardrails that set the maximum permissions any account (even its admins) can use — for example, "no account may disable CloudTrail" or "deny all actions outside approved Regions." SCPs are a one-line mention here; we build them in **Week 17 (Landing Zones & Multi-Account)**.

### Simple Region and AZ Diagram

```text
AWS Region: us-east-1
│
├── Availability Zone: us-east-1a
│   └── Subnets, EC2, load balancer targets
│
├── Availability Zone: us-east-1b
│   └── Subnets, EC2, load balancer targets
│
└── Availability Zone: us-east-1c
    └── Subnets, EC2, load balancer targets
```

### Enterprise Version

```text
Production Application
│
├── Public Load Balancer across multiple AZs
│
├── App servers or Kubernetes nodes across multiple AZs
│
├── Private database subnets across multiple AZs
│
└── Monitoring, logging, backup, and security controls
```

Instructor explanation:

```text
The beginner version is understanding Regions and AZs. The enterprise version is designing applications to survive failures, control access, and operate safely across multiple environments.
```

---

## 12. Instructor Demo Script

### Demo Title

**Safely Navigating AWS and Validating Account Identity**

### Demo Objective

Show students how to safely enter AWS, confirm the current account, identify the active Region, and validate identity using the AWS CLI.

### Required Setup

Instructor needs:

- AWS Console access
- AWS CLI configured
- A safe sandbox or training account
- No production account access for demo
- Approved Region, such as `us-east-1`

### Step-by-Step Demo

#### Step 1: Open AWS Console

Console actions:

1. Log in to AWS Console.
2. Show the top navigation bar.
3. Point out:
   - Search bar
   - Region selector
   - Account menu
   - Recently visited services

Explain:

```text
Before we create or inspect anything, we need to know which account and Region we are using.
```

#### Step 2: Show Region Selector

Console actions:

1. Open Region dropdown.
2. Select approved training Region, for example `us-east-1`.

Explain:

```text
Some resources are regional. If you create an EC2 instance in us-east-1, you will not see it in us-west-2.
```

#### Step 3: Open IAM

Console actions:

1. Search for IAM.
2. Open IAM dashboard.
3. Show that IAM is global.

Explain:

```text
IAM is a global service. It controls access across the account, not just one Region.
```

#### Step 4: Open EC2

Console actions:

1. Search for EC2.
2. Open EC2 dashboard.
3. Point out that EC2 is Region-specific.

Explain:

```text
EC2 resources belong to a Region. Always check the Region when troubleshooting missing resources.
```

#### Step 5: Open AWS CloudShell (the no-credentials on-ramp)

Before touching local CLI setup, demo the option that needs no credentials at all.

Console actions:

1. In the AWS Console top bar, click the **CloudShell** icon (terminal icon, next to the Region selector).
2. Wait for the shell to start.
3. Run:

```bash
aws sts get-caller-identity
```

Explain:

```text
CloudShell already has credentials — it runs as the identity you logged in with, using
short-lived credentials AWS injects for you. There is no access key on disk. This is the
fastest safe way for a beginner to run AWS commands, and it is the fallback whenever local
CLI setup fails. The same aws commands work here as on your laptop.
```

#### Step 6: Check CLI Configuration (Identity Center / SSO is the default we want)

We already covered `aws --version` and basic installation in Week 1 — do not re-walk it here; assume the CLI is installed and jump to *where credentials come from*.

Command:

```bash
aws configure list
```

Expected output when using IAM Identity Center / SSO (the recommended path):

```text
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile               my-sso-profile           manual    --profile
access_key     ****************XYZW              sso         sso
secret_key     ****************WXYZ              sso         sso
    region                us-east-1      config-file    ~/.aws/config
```

Explain:

```text
Note the Type/Location column says "sso", not "shared-credentials-file". That tells us the
CLI is using short-lived credentials minted by IAM Identity Center, which expire on their
own. Compare with a legacy setup, where access_key/secret_key show "shared-credentials-file"
— those are static, long-lived keys we are trying to avoid. The source column is the first
thing a careful engineer reads: it answers "are my credentials temporary or permanent?"
```

If the SSO token has expired you will see an error like `Error loading SSO Token` — fix it with:

```bash
aws sso login --sso-session my-org
```

#### Step 7: Validate Caller Identity

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
This is one of the safest first commands in AWS. It answers: who am I and which account am I connected to?
```

#### Step 8: List AWS Regions

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
||  Endpoint      |  ec2.us-east-1.amazonaws.com||
||  RegionName    |  us-east-1                  ||
|+----------------+-----------------------------+|
```

Explain:

```text
We are using EC2 here to ask AWS which Regions are available.
```

Then shape the output with `--query` (JMESPath) so students see that the CLI can filter server-side:

```bash
aws ec2 describe-regions --query "Regions[].RegionName" --output text
```

Explain:

```text
--query uses JMESPath to pull only the fields we want out of the JSON, before it is printed.
Regions[].RegionName means "from the Regions list, give me each RegionName". This is a core,
frequently-interviewed CLI skill — we will use it heavily in Class 2 and the rest of the course.
```

#### Step 9: Show CloudTrail (prove "every action is logged")

We keep saying AWS is auditable. Make it concrete with a 5-minute console look.

Console actions:

1. Search for **CloudTrail**, open it.
2. Open **Event history**.
3. Point out recent events. Find the `GetCallerIdentity` / `ConsoleLogin` events you just generated.
4. Click one event and show the **Event record** JSON: who (the identity ARN), what (the API call), when, and source IP.

Explain:

```text
CloudTrail records management API activity in your account by default for the last 90 days
(Event history). Every "who did what, when" question in an incident starts here. When we say
"AWS is auditable," this is the mechanism. Later (Week 17) we send CloudTrail to a central
security account so logs survive even if a single account is compromised.
```

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `aws: command not found` | AWS CLI not installed or PATH issue | Use CloudShell or reinstall AWS CLI |
| `Unable to locate credentials` | CLI credentials not configured | Configure credentials or use SSO/CloudShell |
| `AccessDenied` | Identity exists but lacks permission | Explain authorization vs authentication |
| Wrong account ID | Wrong profile or login session | Switch profile or account |
| Wrong Region | Region not set or incorrect | Set Region with `aws configure set region us-east-1` |

### Cleanup Steps

No AWS resources should be created in this demo. No cleanup is required.

---

## 13. Student Lab Manual

### Lab Title

**Validate AWS Account, Region, and Identity**

### Lab Objective

Students will safely navigate AWS Console and use AWS CLI commands to confirm the active account, Region, and identity before creating any cloud resources.

### Estimated Time

30 to 40 minutes

### Student Prerequisites

Students need:

- AWS Console access
- AWS CLI installed
- Terminal access
- Approved AWS Region from instructor
- Basic terminal skills

### Workflow Overview

```text
Log in to AWS Console
        │
        ▼
Check AWS account ID
        │
        ▼
Check selected Region
        │
        ▼
Open terminal
        │
        ▼
Validate AWS CLI
        │
        ▼
Check CLI configuration
        │
        ▼
Run caller identity command
        │
        ▼
Record findings
```

### Step-by-Step Instructions

#### Step 1: Log in to AWS Console

Open the AWS Console in your browser.

Record:

```text
AWS Account Alias or Account Name:
AWS Account ID:
```

#### Step 2: Confirm Region

Look at the Region selector in the top-right corner.

Record:

```text
Current Region:
Instructor-approved Region:
```

If your Region is wrong, change it to the instructor-approved Region.

Example:

```text
us-east-1
```

#### Step 3: Open IAM

Search for:

```text
IAM
```

Answer:

```text
Is IAM regional or global?
```

Expected answer:

```text
IAM is global.
```

#### Step 4: Open EC2

Search for:

```text
EC2
```

Answer:

```text
Is EC2 regional or global?
```

Expected answer:

```text
EC2 is regional.
```

#### Step 5: Open a Terminal (CloudShell is the easiest)

You have two options. If you have any trouble with local setup, use **CloudShell** — it needs no credentials.

Option A — AWS CloudShell (recommended for beginners):

1. In the Console top bar, click the **CloudShell** terminal icon.
2. Wait for it to start. You are already authenticated as your console identity.

Option B — Local terminal: open your terminal. If your lab uses IAM Identity Center, sign in first:

```bash
aws sso login --sso-session my-org
```

Either way, confirm the CLI is available:

```bash
aws --version
```

Expected output:

```text
aws-cli/2.x.x ...
```

If this fails on your laptop, switch to CloudShell (Option A) — do not create access keys to "fix" it.

#### Step 6: Check CLI Configuration

Run:

```bash
aws configure list
```

Record:

```text
Profile:
Access key source:
Region:
Output format:
```

#### Step 7: Confirm Caller Identity

Run:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDA...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/your-user"
}
```

Record:

```text
Account ID:
ARN:
UserId:
```

#### Step 8: List AWS Regions

Run:

```bash
aws ec2 describe-regions --output table
```

Expected result:

A table of AWS Regions.

Now shape the same data with `--query` (JMESPath) so you only get the Region names:

```bash
aws ec2 describe-regions --query "Regions[].RegionName" --output text
```

Record one Region name from the output. You will use `--query` constantly in Class 2 and beyond.

#### Step 9: Document Safety Checks

Create a short note:

```text
Before I create anything in AWS, I should confirm:
1.
2.
3.
```

Expected answer:

```text
1. AWS account
2. AWS Region
3. AWS identity or role
```

### Validation Checklist

Students should complete:

```text
[ ] I can log in to AWS Console.
[ ] I can identify the AWS account ID.
[ ] I can identify the current AWS Region.
[ ] I can explain whether IAM is global or regional.
[ ] I can explain whether EC2 is global or regional.
[ ] I can run aws --version.
[ ] I can run aws configure list.
[ ] I can run aws sts get-caller-identity.
[ ] I can record my account, Region, and ARN.
```

### Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| AWS CLI command not found | CLI not installed or PATH issue | Use CloudShell or reinstall CLI |
| Unable to locate credentials | CLI not configured | Configure CLI or use instructor-provided method |
| AccessDenied | You are authenticated but not authorized | Ask instructor to confirm permissions |
| Wrong account shown | Browser or CLI is using wrong profile/account | Switch account or profile |
| No Region configured | CLI Region missing | Run `aws configure set region us-east-1` |

### Cleanup Steps

No resources are created in this lab. No AWS cleanup required.

Local cleanup optional:

```bash
unset AWS_PROFILE
```

Only run this if you set `AWS_PROFILE` manually.

### Reflection Questions

1. Why should you confirm the AWS account before creating resources?
2. Why does Region matter in AWS?
3. What is the difference between authentication and authorization?
4. Why should lab resources never be created in a production account?
5. What could happen if a beginner has full admin access with no budget alert?

### Optional Challenge Task

Use a named AWS CLI profile if your instructor allows it.

Run:

```bash
aws configure list-profiles
```

Then run:

```bash
aws sts get-caller-identity --profile PROFILE_NAME
```

Document the difference between default profile and named profile behavior.

---

## 14. Troubleshooting Activity

### Incident Title

**New Engineer Cannot Validate AWS CLI Access**

### Business Impact

A new cloud engineer has joined the team and needs to verify access to the company’s AWS training account. They cannot proceed with onboarding labs because AWS CLI commands are failing.

### Symptoms

The engineer reports:

```text
I can log in to the AWS Console, but my terminal commands are failing.
```

They run:

```bash
aws sts get-caller-identity
```

And receive:

```text
Unable to locate credentials. You can configure credentials by running "aws configure".
```

Another student receives:

```text
You must specify a region. You can also configure your region by running "aws configure".
```

Another student receives:

```text
An error occurred (AccessDenied) when calling the GetCallerIdentity operation: User is not authorized
```

### Starting Evidence

Commands to inspect:

```bash
aws --version
aws configure list
aws configure list-profiles
echo $AWS_PROFILE
aws sts get-caller-identity
```

### Student Investigation Steps

Students should determine:

1. Is AWS CLI installed?
2. Are credentials configured?
3. Is a named profile required?
4. Is `AWS_PROFILE` set incorrectly?
5. Is a Region configured?
6. Is the issue authentication or authorization?
7. Is the student in the correct AWS account?

### Expected Root Cause

Possible root causes:

- AWS CLI is installed but credentials are missing.
- The student is using the wrong CLI profile.
- The Region is not configured.
- The student is authenticated but does not have permission.
- Browser console access and CLI access are using different identities.

### Correct Resolution

For missing Region:

```bash
aws configure set region us-east-1
```

For wrong profile:

```bash
aws configure list-profiles
aws sts get-caller-identity --profile correct-profile
```

For missing credentials:

- Use instructor-approved configuration method.
- Use AWS CloudShell if local credentials are not available.
- Do not create personal access keys unless the instructor explicitly allows it.

For AccessDenied:

- Confirm identity with instructor.
- Check whether the role or user has permission.
- Do not attempt to bypass permissions.

### Common Wrong Paths

Students may incorrectly:

- Reinstall AWS CLI without checking credentials.
- Assume AWS is down.
- Switch Regions randomly.
- Create new access keys without approval.
- Use root credentials.
- Confuse Console login with CLI configuration.
- Think `AccessDenied` means they are not logged in.

### Instructor Hints

Use these hints gradually:

```text
What does aws configure list show?
```

```text
Can you prove which AWS identity your terminal is using?
```

```text
Is this an authentication problem or an authorization problem?
```

```text
Are your browser and terminal using the same account?
```

### Preventive Action

Students should always begin AWS work with:

```bash
aws configure list
aws sts get-caller-identity
aws configure get region
```

They should document:

```text
Account:
Region:
Profile:
ARN:
```

---

## 15. Scenario-Based Discussion Questions

### Question 1

**Why should a new engineer avoid using the AWS root user for daily tasks?**

Expected response themes:

- Root user has full account control
- High security risk
- No least privilege
- Harder to audit safely
- Should be reserved for limited account-level tasks

Follow-up:

```text
What should engineers use instead of root access?
```

Expected answer:

```text
IAM users, IAM roles, or SSO-based access with least privilege.
```

### Question 2

**Why do companies separate dev, test, and prod into different AWS accounts?**

Expected response themes:

- Reduce blast radius
- Improve cost tracking
- Separate permissions
- Protect production
- Support governance

Follow-up:

```text
What could go wrong if dev and prod are in the same account?
```

### Question 3

**What is the risk of running AWS CLI commands without checking the active account first?**

Expected response themes:

- Accidental changes in production
- Resource creation in wrong account
- Unexpected cost
- Security impact
- Troubleshooting confusion

Follow-up:

```text
What command helps confirm the active AWS identity?
```

Expected answer:

```bash
aws sts get-caller-identity
```

### Question 4

**Why does Region matter when troubleshooting cloud resources?**

Expected response themes:

- Resources may exist in one Region but not another
- CLI may query wrong Region
- Costs and service availability vary
- Troubleshooting can fail if looking in the wrong place

Follow-up:

```text
Which services are global, and which are regional?
```

### Question 5

**What does the shared responsibility model mean for a cloud engineer?**

Expected response themes:

- AWS handles infrastructure
- Customer handles configuration, access, data, and apps
- Misconfiguration is still customer responsibility
- Cloud security is shared

Follow-up:

```text
Who is responsible if an S3 bucket is accidentally made public?
```

Expected answer:

```text
The customer is responsible for bucket permissions and data exposure.
```

### Question 6

**Why should students create budget alerts early in the course?**

Expected response themes:

- Prevent surprise costs
- Build professional habits
- Learn cloud cost awareness
- Catch forgotten resources

Follow-up:

```text
Which AWS services commonly cause unexpected lab costs?
```

### Question 7

**How does AWS Account compare to Azure Subscription and GCP Project?**

Expected response themes:

- All are resource and billing containers
- Identity and governance models differ
- Cloud hierarchy is different in each provider

Follow-up:

```text
Why is it useful for AWS-focused students to understand Azure and GCP equivalents?
```

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

Which command safely shows the AWS identity currently used by your CLI?

A. `aws iam delete-user`  
B. `aws sts get-caller-identity`  
C. `aws ec2 terminate-instances`  
D. `aws s3 rm --recursive`

**Answer:** B  
**Explanation:** `aws sts get-caller-identity` safely returns the active AWS identity and account.

### Question 2: Multiple Choice

Which AWS concept is most similar to an Azure Subscription at a beginner level?

A. Availability Zone  
B. AWS Account  
C. Security Group  
D. S3 Bucket

**Answer:** B  
**Explanation:** AWS Account and Azure Subscription both act as major containers for access, billing, and resources.

### Question 3: True/False

IAM is a Region-specific AWS service.

**Answer:** False  
**Explanation:** IAM is global. It controls access across the AWS account.

### Question 4: True/False

EC2 resources are Region-specific.

**Answer:** True  
**Explanation:** EC2 instances are created in specific Regions and Availability Zones.

### Question 5: Short Answer

What are three things you should confirm before creating AWS resources?

**Answer:** Account, Region, and identity/role.  
**Explanation:** These checks reduce the risk of creating resources in the wrong place or with the wrong access.

### Question 6: Multiple Choice

In the shared responsibility model, which item is usually the customer’s responsibility?

A. Physical data center security  
B. AWS hardware maintenance  
C. IAM permissions and access control  
D. Power and cooling in AWS facilities

**Answer:** C  
**Explanation:** AWS manages physical infrastructure, while customers manage IAM, data, network rules, and application configuration.

### Question 7: Troubleshooting

A student runs `aws sts get-caller-identity` and gets:

```text
Unable to locate credentials
```

What is the likely issue?

**Answer:** AWS CLI credentials are not configured or the CLI cannot find them.  
**Explanation:** The CLI is installed, but it does not have credentials available for authentication.

### Question 8: Troubleshooting

A student says they created an EC2 instance, but they cannot find it in the Console. What should they check first?

**Answer:** They should check the selected AWS Region and AWS account.  
**Explanation:** EC2 is regional. The instance may exist in a different Region or account.

### Question 9: Multiple Choice

Which of the following is a common AWS cost risk for beginners?

A. Running `aws --version`  
B. Leaving EC2, NAT Gateway, RDS, or load balancers running  
C. Opening the AWS Console  
D. Reading AWS documentation

**Answer:** B  
**Explanation:** Running infrastructure can create ongoing charges if not cleaned up.

### Question 10: Short Answer

Why do enterprises often use multiple AWS accounts?

**Answer:** To separate environments, improve security, track cost, reduce blast radius, and support governance.  
**Explanation:** Multi-account design is a common enterprise practice for managing cloud environments safely.

---

## 17. Homework Assignment

### Assignment Title

**AWS Account, Region, and Responsibility Comparison Brief**

### Scenario

You are a new cloud engineer joining an enterprise cloud platform team. Your manager asks you to prepare a short onboarding note that explains how to safely begin working in AWS and how AWS account structure compares with Azure and GCP.

### Student Tasks

Create a 1 to 2 page document covering:

1. What an AWS Account is
2. Why AWS Regions matter
3. What Availability Zones are used for
4. What the shared responsibility model means
5. Why engineers should avoid root user access
6. How to confirm AWS CLI identity
7. How AWS Account compares to:
   - Azure Subscription
   - GCP Project
8. Three AWS safety checks before creating resources
9. Three AWS cost risks beginners should avoid

### Expected Deliverables

Submit one document in Markdown, Word, or PDF format.

Suggested structure:

```text
Title:
Summary:
AWS Account:
Regions and Availability Zones:
Shared Responsibility:
CLI Identity Check:
AWS vs Azure vs GCP:
Safety Checklist:
Cost Risks:
Questions I Still Have:
```

### Submission Format

File name:

```text
week4-class1-aws-foundations-homework-yourname.md
```

### Estimated Completion Time

45 to 60 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Correct explanation of AWS account and Region | 20 |
| Correct shared responsibility explanation | 20 |
| CLI identity validation included | 15 |
| Azure/GCP comparison included | 15 |
| Cost and security safety checks included | 20 |
| Clear writing and organization | 10 |

### Optional Advanced Challenge

Add a simple diagram showing:

```text
AWS Organization
  ├── Dev Account
  ├── Test Account
  ├── Prod Account
  ├── Shared Services Account
  └── Security Account
```

Explain why this structure is safer than using one account for everything.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Not checking AWS account before working | Students assume Console and CLI use same account | Always run `aws sts get-caller-identity` |
| Confusing Region with Availability Zone | Both are new cloud infrastructure terms | Use diagram: Region contains AZs |
| Thinking IAM is regional | Many AWS services are regional, so students assume IAM is too | Emphasize IAM is global |
| Using root user casually | Beginners may not understand privilege risk | Teach root user is for limited account-level tasks |
| Ignoring cost controls | Students think small labs are always free | Discuss EC2, NAT Gateway, RDS, load balancer costs |
| Confusing authentication and authorization | Errors look similar to beginners | Authentication means who you are; authorization means what you can do |
| Running commands without reading them | Students copy/paste commands blindly | Require students to explain each command before running |
| Looking for resources in wrong Region | Console Region dropdown is easy to miss | Always confirm Region during troubleshooting |
| Creating resources too early | Students want hands-on activity immediately | Start with read-only checks first |
| Treating Azure/GCP as identical to AWS | Similar concepts are not exact matches | Use comparison as awareness, not one-to-one mapping |

---

## 19. Real-World Enterprise Scenario

### Scenario

A new cloud engineer joins a company’s cloud platform team. The company uses AWS as the primary cloud provider and has separate AWS accounts for dev, test, prod, shared services, and security.

The engineer receives access to the dev AWS account first. Before they are allowed to deploy anything, they must validate:

- Which AWS account they can access
- Which Region the team uses
- Whether their CLI is configured
- Whether they are using an IAM user, IAM role, or SSO session
- Whether budget alerts and tagging standards exist
- Whether they understand what actions are safe in a sandbox versus production

### Constraints

| Constraint | Example |
|---|---|
| Access control | New engineer does not receive production admin access |
| Cost | Lab resources must be cleaned up daily |
| Security | Root user is not allowed for daily work |
| Reliability | Production account changes require approval |
| Governance | Resources must include required tags |
| Audit | CloudTrail records identity and API activity |

### What Each Role Would Do

#### DevOps Engineer

- Validates CLI profile before running deployment pipelines
- Confirms pipeline role and environment
- Avoids deploying to wrong account or Region

#### Cloud Engineer

- Reviews account structure and Region standards
- Confirms IAM access and governance boundaries
- Helps define safe account access patterns

#### SRE

- Confirms monitoring and incident access
- Checks which account owns production resources
- Ensures operational visibility before supporting a service

---

## 20. Instructor Tips

### Teaching Tips

- Repeat the phrase: **account, Region, identity**.
- Use diagrams for Region and AZ explanations.
- Avoid too much IAM depth. Week 6 covers IAM deeply.
- Explain cloud cost risk early without scaring students.
- Keep Azure/GCP comparison short and practical.

### Pacing Tips

- Do not spend too long clicking through every AWS service.
- Focus on mental models:
  - AWS Account
  - Region
  - AZ
  - Identity
  - Responsibility
  - Cost safety

### Lab Support Tips

When students struggle, ask:

```text
What account are you in?
What Region are you in?
What identity does the CLI show?
What exact error are you getting?
```

### Helping Struggling Students

Use simple analogies:

- AWS Account = separate workspace with its own bill and permissions
- Region = geographic area
- AZ = one or more discrete data centers (independent power/cooling/networking) inside a Region
- IAM = access control system
- CLI identity = who your terminal is acting as

### Challenging Advanced Students

Ask advanced students to:

- Compare AWS Organizations, Azure Management Groups, and GCP Resource Hierarchy
- Explain account separation for dev/test/prod
- Identify which services are global vs regional
- Create an enterprise AWS account diagram

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

```text
[ ] What AWS is used for in enterprise environments
[ ] What an AWS Account is
[ ] What a Region is
[ ] What an Availability Zone is
[ ] What the shared responsibility model means
[ ] Why root user should not be used for daily tasks
[ ] Why account and Region checks matter
[ ] How AWS Account compares to Azure Subscription and GCP Project
```

### Students Should Be Able to Build or Configure

```text
[ ] Open AWS Console
[ ] Select the correct AWS Region
[ ] Open IAM and EC2 service pages
[ ] Open a terminal
[ ] Run aws --version
[ ] Run aws configure list
[ ] Run aws sts get-caller-identity
[ ] Document account ID, Region, and ARN
```

### Students Should Be Able to Troubleshoot

```text
[ ] AWS CLI not installed
[ ] Missing credentials
[ ] Wrong profile
[ ] Wrong Region
[ ] AccessDenied error
[ ] Resource not visible because wrong Region is selected
[ ] Console and CLI identity mismatch
```

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

```text
[ ] Students understand AWS Account, Region, and AZ.
[ ] Students understand shared responsibility at a beginner level.
[ ] Students saw AWS Console navigation.
[ ] Students saw aws sts get-caller-identity demo.
[ ] Students completed identity validation lab.
[ ] Common CLI errors were reviewed.
[ ] Homework was explained.
[ ] Students know Class 2 will cover AWS CLI, budgets, tagging, and safe operations.
```

### Student Checklist Before Leaving Class

```text
[ ] I can log in to AWS Console.
[ ] I can identify my AWS account ID.
[ ] I can identify my current Region.
[ ] I can explain Region vs Availability Zone.
[ ] I can explain AWS shared responsibility.
[ ] I can run aws --version.
[ ] I can run aws configure list.
[ ] I can run aws sts get-caller-identity.
[ ] I recorded my Account ID, Region, and ARN.
[ ] I understand why cost and security safety matter.
```

### Items to Verify Before Moving to Class 2

Before Class 2, students should have:

```text
[ ] AWS CLI installed or access to AWS CloudShell
[ ] AWS Console access working
[ ] Account ID documented
[ ] Region documented
[ ] CLI identity command tested
[ ] Homework started or completed
[ ] No unexpected AWS resources created
```

Class 2 can then continue into **AWS CLI setup, budget alerts, tagging, cost awareness, and safe operational checks**.

---

## Class Artifacts & Validation

Backing module: [`labs/aws-cli-fundamentals/`](../../labs/aws-cli-fundamentals/). This class
uses the **identity / credentials / region** half of the read-only toolkit (the demo's
caller-identity check, the regions table, and the SSO sign-in model) plus the
false-success credential-probe fixture that drives the troubleshooting activity. All gates
were run in this environment (AWS CLI v2.32.11, bash 5.1, ShellCheck 0.10.0); see the lab
[Validation](../../labs/aws-cli-fundamentals/README.md#validation) section.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/aws-cli-fundamentals/solution/lib/common.sh | shell | shared `log/die/require_cmd/aws_region/require_aws_creds` helpers (the credential + region precedence chain taught here) | `shellcheck -x` + `bash -n` (via `./validate.sh`) | PASS |
| 2 | labs/aws-cli-fundamentals/solution/whoami.sh | shell | `sts:GetCallerIdentity` identity probe (the demo's "who am I" check; fails closed without creds) | `bash tests/run-tests.sh`; `shellcheck -x` | PASS (offline suite); live read = $0, no live evidence captured |
| 3 | labs/aws-cli-fundamentals/solution/regions.sh | shell | `ec2:DescribeRegions` aligned table (the "list AWS Regions" demo/lab step) | `bash tests/run-tests.sh`; `shellcheck -x` | PASS (offline suite); live read = $0, no live evidence captured |
| 4 | labs/aws-cli-fundamentals/solution/sso-config.md | docs | `aws configure sso` walkthrough — the Identity Center / SSO sign-in model taught in Step 6b | gate: file present (`./validate.sh`) | PASS |
| 5 | labs/aws-cli-fundamentals/broken/whoami-broken.sh | shell | troubleshooting fixture: swallows the no-credentials error and falsely exits 0, ignoring `AWS_PROFILE` (drives the §14 incident) | `bash tests/run-tests.sh` reproduces the false-success; `shellcheck -x` (clean — bug is behavioural) | PASS (bug reproduced by suite) |
| 6 | labs/aws-cli-fundamentals/tests/run-tests.sh | shell | 50 offline functional assertions using an `aws` stub (no real account) | `bash tests/run-tests.sh` | PASS (50/50, exit 0) |
| 7 | labs/aws-cli-fundamentals/validate.sh | shell | module gate runner (`bash -n` + offline suite + `shellcheck -x`) | `./validate.sh` | PASS (26 passed, 0 failed, exit 0) |

> **Honesty note on "live."** Every script is **read-only** and the live read against a
> real account is **$0**, but no live-account run was captured for this week —
> `labs/aws-cli-fundamentals/LIVE-AWS-VALIDATION.txt` is empty. The only live-CLI evidence
> on disk is the **no-credentials failure path** (the `require_aws_creds` hard-fail shown in
> the README), which is exactly the behaviour the troubleshooting fixture violates. Validation
> here is **static + offline-functional**, not a live operation.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** (not just a fence) — the identity/region/SSO scripts live in `labs/aws-cli-fundamentals/`.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `bash -n`, the 50-assertion offline suite, and `shellcheck -x` all pass via `./validate.sh` (26 passed, 0 failed).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `starter/` gaps `aws_region()`/`require_aws_creds()`/`whoami.sh`/`regions.sh`; `solution/` is the reference.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — all present.
- [x] **Cleanup/teardown** is provided and idempotent — toolkit is strictly read-only (creates nothing); README documents `aws sso logout` for shared hosts.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — lab key in `README` "Instructor answer key"; quiz key in §16; troubleshooting root cause/fix in §14.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/whoami-broken.sh` swallows the no-creds error and falsely exits 0; reproduced by the offline suite.
- [x] **Expected outputs** are shown for demos and labs — README "Expected results" plus per-step expected output in §12/§13.
- [x] **Cost & security warnings** present — README "Cost considerations" ($0, read-only) and "Security considerations" (least privilege, no secrets, fail-closed).
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/aws-cli-fundamentals/` and forward to Week 6 (IAM) verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — all rows `ls`-verified.
- [ ] **Live operation against a real account is NOT captured** — `LIVE-AWS-VALIDATION.txt` is empty; only the no-credentials failure path is on disk. Validation is static + offline-functional only.
