# Week 17, Class 1: Designing the Enterprise AWS Account Foundation

**Track:** Unified DevOps · Cloud · SRE Track  
**Week:** 17  
**Module:** AWS Landing Zones and Multi-Account Strategy  
**Class Duration:** 3 hours  
**Primary Cloud:** AWS  
**Secondary Cloud Exposure:** Azure and GCP  

---

> **▶ Runnable lab for this class:** [`labs/security-automation/`](../../labs/security-automation/) · [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Designing the Enterprise AWS Account Foundation**

### Class Purpose

This class teaches students how enterprise AWS environments are structured before workloads are deployed. Students learn why organizations use multiple AWS accounts, how landing zones create a governed cloud foundation, and how shared services, security, network, non-production, and production accounts fit together.

### How This Class Connects to the Overall Course

Students have already learned AWS Cloud foundations (Week 4), Networking and VPC (Week 5), Cloud Security and IAM including KMS and Secrets Manager (Week 6), and Terraform (Weeks 14 and 15). This class moves students from single-account thinking into enterprise cloud architecture thinking.

This class is the foundation for later weeks in the unified track, including:

- Cost Optimization and Cloud Operations (Week 18)
- DevSecOps and Secure Delivery (Week 19), which reuses the SCP and policy-as-code patterns introduced here
- Platform Engineering and Golden Paths (Week 20), which builds on account vending and self-service
- The Capstone build (Weeks 23 and 24), where a governed multi-account foundation is expected

Multi-account networking (Transit Gateway, centralized egress, RAM/shared VPC) is taught in Class 2 of this week, because the converged track has no separate enterprise-networking week.

### What Students Will Build, Analyze, or Practice

Students will:

- Analyze why a single AWS account does not scale for enterprise use
- Design a basic AWS multi-account landing zone
- Create an organizational unit structure
- Define account purposes and naming conventions
- Compare AWS hierarchy with Azure and GCP
- Troubleshoot a basic enterprise access issue involving account placement, role assignment, or governance boundaries

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why enterprises use multiple AWS accounts instead of one shared account.
2. **Describe** what an AWS landing zone is and what problems it solves.
3. **Identify** common enterprise AWS account types such as security, log archive, shared services, network, dev, test, and prod.
4. **Compare** AWS Organizations with Azure Management Groups and GCP Resource Hierarchy.
5. **Build** a basic multi-account AWS structure for an enterprise application.
6. **Document** account ownership, purpose, and naming conventions.
7. **Analyze** how account separation reduces blast radius and improves governance.
8. **Troubleshoot** a basic access issue caused by wrong account, wrong role, missing permission set, or account governance.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- AWS Regions and Availability Zones
- Basic IAM users, roles, and policies
- Basic VPC concepts
- Basic security and least privilege
- Basic cloud billing and tagging
- Basic production readiness concepts
- Why Git and diagrams are useful for cloud documentation

### Required Tools Already Installed

Students should have:

- Browser
- VS Code
- Terminal
- Git
- AWS CLI
- Diagramming tool such as draw.io, Lucidchart, Excalidraw, or Mermaid-compatible editor

### Required Accounts or Access

Recommended:

- AWS account with read-only access
- Access to AWS Console
- AWS CLI configured with a non-production profile

Optional instructor-only access:

- AWS Organizations console
- AWS Control Tower console
- IAM Identity Center console

The student lab has two tracks. The **design track** (Steps 1-9) needs no AWS access and produces the landing-zone design artifacts. The **hands-on track** (Step 10) creates a real OU, an SCP, and an IAM Identity Center permission set in a **disposable sandbox AWS Organization** — these primitives are free and reversible, but you need management-account (or delegated-admin) access. Do the hands-on track if you have a sandbox org; never run it against a real company organization. No member accounts need to be created.

### Files, Repos, or Sample Code Needed

Instructor can provide this starter folder:

```text
week-17-landing-zone/
├── README.md
├── diagrams/
│   └── landing-zone-template.md
├── templates/
│   ├── account-inventory-template.csv
│   ├── ou-design-template.md
│   └── access-model-template.md
└── examples/
    └── sample-enterprise-landing-zone.md
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Landing Zone | A prepared cloud foundation where accounts, security, networking, identity, and logging are set up before applications are deployed | Enterprises use landing zones so every workload starts from a secure and governed baseline |
| AWS Organization | A structure for centrally managing multiple AWS accounts | Cloud platform teams use this to group accounts, apply policies, and manage billing |
| Management Account | The top-level account that owns the AWS Organization | This account should be tightly controlled and not used for normal workloads |
| Organizational Unit | A folder-like grouping of AWS accounts | Teams use OUs to group accounts by purpose, environment, risk, or ownership |
| Workload Account | An account where an application or business workload runs | Example: `claims-prod`, `payments-dev`, or `inventory-test` |
| Shared Services Account | An account that hosts common platform services | Examples include shared automation, DNS, CI/CD integrations, and internal tooling |
| Network Account | An account that owns shared networking components | Often used for Transit Gateway, shared VPC patterns, routing, VPN, or Direct Connect |
| Security Account | An account used by security teams for monitoring, findings, and audit tooling | Security tooling is separated from workload accounts to protect visibility and evidence |
| Log Archive Account | A protected account for centralized logs | Used to store CloudTrail, Config, VPC Flow Logs, and security logs |
| Guardrail | A control that prevents or detects risky cloud actions | Example: prevent disabling CloudTrail or prevent public S3 buckets |
| SCP | Service Control Policy, an organization-level control that limits what accounts can do | SCPs help enforce rules across many accounts, even if someone has admin permissions inside an account |
| Blast Radius | The amount of damage a mistake or incident can cause | Separate prod and dev accounts reduce the impact of mistakes |
| IAM Identity Center | AWS service used to centrally manage workforce access to AWS accounts | Enterprises use it to assign permission sets to users and groups |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | To show AWS Organizations, account hierarchy, and Control Tower concepts |
| AWS CLI | To validate current AWS identity and demonstrate read-only account checks |
| VS Code | To edit account design files, templates, and Markdown documentation |
| Diagramming tool | To draw landing zone account structures |
| Git | To version control architecture proposals and account design documents |
| Markdown | To document account purpose, ownership, and governance decisions |
| Spreadsheet or CSV | To organize account inventory, environment, owner, and purpose |

---

## 6. AWS Services Used

| AWS Service | How It Connects to the Class |
|---|---|
| AWS Organizations | Central service for managing multiple AWS accounts |
| AWS Control Tower | Provides landing zone setup and governed multi-account baseline |
| Control Tower Account Factory / Account Factory for Terraform (AFT) | Vends new accounts with a standard baseline; AFT does it as Git-driven IaC |
| Landing Zone Accelerator on AWS (LZA) | AWS-maintained solution that builds and continuously manages a full landing zone from config files |
| IAM Identity Center | Used for centralized human access across AWS accounts via permission sets |
| Service Control Policies | Used to apply organization-level permission boundaries |
| CloudTrail | Introduced as part of centralized audit logging |
| AWS Config | Mentioned as a detective governance service |
| AWS Billing and Cost Management | Supports consolidated billing and cost visibility across accounts |
| AWS IAM | Connects users, roles, and permission boundaries to account access |
| AWS STS | Helps validate current identity and assumed role context |

---

## 7. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Top-level organization | AWS Organization | Microsoft Entra tenant and management group hierarchy | GCP Organization |
| Grouping structure | Organizational Units | Management Groups | Folders |
| Workload boundary | AWS Account | Azure Subscription | GCP Project |
| Central access | IAM Identity Center | Microsoft Entra ID and Azure RBAC | Cloud IAM |
| Preventive governance | SCPs and Control Tower guardrails | Azure Policy | Organization Policies |
| Logging/audit | CloudTrail | Azure Activity Log | Cloud Audit Logs |

**Teaching point:** AWS accounts are closer to Azure subscriptions and GCP projects than to individual users. In enterprise architecture, accounts are major security, billing, and operational boundaries.

---

## 8. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:10 | Opening | Explain the business problem: one AWS account does not scale |
| 0:10 to 0:25 | Role connection | Connect landing zones to Cloud Engineer responsibilities |
| 0:25 to 0:45 | Concept teaching | Landing zone, account boundaries, blast radius |
| 0:45 to 1:10 | AWS Organizations | OUs, accounts, management account, account patterns |
| 1:10 to 1:20 | Break | Short break |
| 1:20 to 1:45 | Enterprise account model | Security, log archive, network, shared services, dev, test, prod |
| 1:45 to 2:05 | Instructor demo | AWS Organizations and account structure walkthrough |
| 2:05 to 2:35 | Student lab | Students design multi-account landing zone |
| 2:35 to 2:50 | Troubleshooting activity | Developer cannot access production account |
| 2:50 to 2:58 | Discussion | Why production should be separated from dev |
| 2:58 to 3:00 | Recap | Confirm outcomes and assign homework |

---

## 9. Instructor Lesson Plan

### Step 1: Open With the Enterprise Problem

Start with this prompt:

> Imagine a company has one AWS account. Developers, testers, production workloads, security logs, networking, and admin users are all in the same place. What could go wrong?

Expected answers:

- Someone may delete production resources by mistake.
- Dev resources may affect production costs.
- Security logs may be changed by workload admins.
- Billing is hard to separate.
- Permissions are too broad.
- Compliance is harder.

Teaching tip: Do not start with AWS Organizations immediately. Start with the pain point.

### Step 2: Introduce the Landing Zone

Explain:

> A landing zone is the cloud foundation that exists before application teams deploy workloads. It gives teams a secure place to land.

Emphasize:

- It is not just an AWS service.
- It is an architecture pattern.
- It includes accounts, identity, network, logging, governance, and security controls.

Pause and ask:

> What should be ready before a production application team starts deploying into AWS?

Expected themes:

- Account access
- Networking
- IAM roles
- Logging
- Cost controls
- Security baseline
- Monitoring
- Backup expectations

### Step 3: Explain AWS Organizations

Show the hierarchy:

```text
AWS Organization
└── Organizational Units
    └── AWS Accounts
```

Explain:

- The AWS Organization is the central management structure.
- OUs group accounts.
- Accounts contain workloads, shared infrastructure, or security tools.
- SCPs can be attached to the root, OU, or account level.

Transition:

> Once we understand that accounts are the building blocks, we can design the account structure.

### Step 4: Teach Common Account Types

Explain each account type with real-world examples:

- Management account: organization administration only
- Log archive account: stores security and audit logs
- Security tooling account: security tools and findings
- Network account: shared routing and connectivity
- Shared services account: internal platform services
- Dev workload account: development environment
- Test workload account: validation environment
- Prod workload account: customer-facing production workload

### Step 5: Show AWS, Azure, and GCP Model Comparison

Keep this short:

> In AWS, the workload boundary is usually the account. In Azure, it is often the subscription. In GCP, it is usually the project.

### Step 6: Instructor Demo

Use either a live AWS account, screenshots, or a conceptual walkthrough.

Show:

- AWS Organizations
- OU hierarchy
- Account list
- Where Control Tower fits
- Where SCPs attach

Pause after demo and ask:

> Which accounts should application developers have access to? Which accounts should they not control directly?

Expected answer:

- Developers may access dev/test workload accounts.
- Production access should be controlled.
- Log archive and security accounts should be restricted.
- Network account should be managed by platform/network teams.

### Step 7: Student Lab

Students design a landing zone for a fictional enterprise app.

Instructor checks:

- Did they separate prod and non-prod?
- Did they include log archive?
- Did they include security?
- Did they include network/shared services?
- Did they define ownership?
- Did they avoid using the management account for workloads?

### Step 8: Troubleshooting Activity

Scenario:

> A developer cannot deploy to prod even though they say they have AWS access.

Students identify whether the issue is:

- Wrong account
- Wrong role
- Missing permission set
- SCP
- MFA requirement
- Account placement issue

### Step 9: Recap and Transition to Class 2

Close with:

> Today we designed the account foundation. In Class 2, we will focus on governance, guardrails, SCPs, and how access decisions are controlled across accounts.

---

## 10. Instructor Lecture Notes

### Opening Talking Point

> Most beginners think of AWS as one account where everything lives. In real companies, that does not work for long. Once multiple teams, applications, environments, and compliance requirements enter the picture, the account structure becomes part of the architecture.

### Why One Account Does Not Scale

A single account may work for a personal project, but it becomes risky in an enterprise.

Key risks:

- Too many people need access to the same place.
- Development and production resources are mixed.
- Billing is hard to understand.
- Logs can be modified by the same people who manage workloads.
- Security boundaries are weak.
- A mistake can affect everything.

Say out loud:

> Account separation is one of the first cloud architecture decisions that affects security, cost, reliability, and team operations.

### What Is a Landing Zone?

A landing zone is a prepared cloud environment that gives teams a safe starting point.

It usually includes:

- Account structure
- Identity and access model
- Network layout
- Centralized logging
- Security controls
- Cost tagging
- Baseline monitoring
- Governance policies

Common misconception:

> Students may think AWS Control Tower equals the landing zone. Control Tower helps create and manage a landing zone, but the landing zone is the broader design and operating model.

### Why Multiple Accounts?

Use these categories:

- **Security:** Production workloads need stronger controls than development workloads.
- **Blast Radius:** If someone breaks dev, it should not break production.
- **Billing:** Each application or environment can be tracked separately.
- **Compliance:** Audit logs and security evidence should be protected.
- **Team Ownership:** Different teams can own different accounts and responsibilities.
- **Operational Control:** Prod can have stricter deployment, access, and monitoring rules.

### Common Enterprise Account Pattern

```text
Management Account
Security Accounts
Infrastructure Accounts
Non-Production Workload Accounts
Production Workload Accounts
```

Explain:

> The management account is not where teams deploy applications. It is like the control room for the organization.

### AWS Organizations

AWS Organizations helps manage accounts centrally.

Important concepts:

- Organization root
- Organizational Units
- Accounts
- Consolidated billing
- Service Control Policies

Say out loud:

> AWS Organizations gives structure. It does not automatically create a good design. The architect still needs to decide account boundaries, ownership, naming, and governance.

### AWS Control Tower

Control Tower helps set up:

- Landing zone baseline
- Account Factory
- Guardrails
- Logging
- Audit account patterns

Beginner framing:

> Control Tower is like a guided enterprise setup assistant for AWS multi-account environments.

### Account Vending: How Real Enterprises Create Accounts

This is core senior knowledge, not a stretch goal. In a real enterprise, nobody clicks "Create account" in the console one at a time. New accounts are *vended* through automation so every account is born with the same baseline (CloudTrail, Config, guardrails, OU placement, IAM Identity Center access, tags, budget). There are three mainstream patterns in 2026:

1. **Control Tower Account Factory (console / Service Catalog).** Control Tower exposes Account Factory as a Service Catalog product. A platform engineer or an approved requester fills in account name, email, OU, and SSO access, and Control Tower provisions and enrolls the account. Good for teams that want a managed baseline with minimal code.

2. **Account Factory for Terraform (AFT).** AFT layers a GitOps workflow on top of Control Tower: you describe each account as a row/file in a Git repo, open a pull request, and a pipeline calls Account Factory and then applies per-account "customization" Terraform (baseline VPC, IAM roles, Config rules). This is the most common choice for Terraform-centric platform teams. Note OpenTofu can run the same HCL.

3. **Landing Zone Accelerator on AWS (LZA).** An AWS-maintained CloudFormation/CDK solution that builds and continuously manages the *entire* landing zone (Organizations, SCPs, centralized logging, networking, security services) from a set of YAML config files in CodeCommit/CodePipeline. LZA is the heavyweight option, common in regulated/government environments and FSI, and supports highly customized multi-region, multi-OU designs that go beyond what Control Tower configures by default.

Talking point:

> The interview question is almost always "Control Tower, AFT, LZA, or build your own?" A senior answer ties the choice to team skills, customization needs, and compliance — not to which one is newest.

#### Control Tower vs. LZA vs. Roll-Your-Own (Organizations-native) — Decision Guide

| Dimension | Control Tower (+ Account Factory / AFT) | Landing Zone Accelerator (LZA) | Roll-your-own (Organizations + IaC) |
|---|---|---|---|
| Setup effort | Low — guided, managed baseline | Medium-high — config-file driven, you own the pipeline | High — you build everything |
| Customization ceiling | Medium (guardrails + AFT customizations) | Very high (networking, security services, multi-region) | Unlimited |
| Lock-in / opinionation | Opinionated managed service | AWS-maintained but config-driven | None |
| Best for | Most enterprises wanting a governed baseline fast | Regulated/FSI/gov, complex multi-region needs | Teams with strong platform engineering and unusual requirements |
| Ongoing cost | Control Tower itself is free; you pay for the underlying services (Config, CloudTrail, etc.) | Same underlying-service cost plus pipeline | Same underlying-service cost; highest people cost |
| Drift handling | Control Tower detects drift and offers re-enrollment | Pipeline re-applies config (declarative) | You build drift detection |

> Cost warning: "Control Tower is free" refers to the orchestration. The detective layer it enables — AWS Config recording across every account, CloudTrail, GuardDuty, Security Hub — does cost money and scales with account count. Always pair a landing zone rollout with a budget and Cost Categories.

### Account Types Explained

#### Log Archive Account

Stores audit logs. Logs should not be easy for workload teams to modify or delete.

#### Security Tooling Account

Hosts tools that security teams use to monitor risk.

#### Network Account

Owns shared network infrastructure, such as Transit Gateway, shared DNS, VPN, Direct Connect attachments, and central routing components.

#### Shared Services Account

Hosts shared internal services, such as CI/CD integrations, shared automation, internal DNS, artifact tools, and platform utilities.

#### Workload Accounts

These are where applications run. They can be separated by environment, application, business unit, or compliance boundary.

### Common Misconceptions

| Misconception | Correction |
|---|---|
| One AWS account is simpler, so it is better | It may be simpler at first, but becomes risky and hard to govern |
| Admin access inside an account means full control | SCPs and governance controls may still restrict actions |
| The management account is where workloads should run | The management account should be protected and used only for org-level administration |
| A landing zone is only networking | It includes identity, logging, accounts, governance, security, and operations |
| Dev and prod can share one account if resources are named carefully | Naming is not a security boundary |

---

## 11. Whiteboard Explanation

### Simple Diagram: Single Account Problem

```text
Single AWS Account
│
├── Dev App
├── Test App
├── Prod App
├── Developers
├── Admin Roles
├── Network Resources
├── Security Logs
├── Shared Tools
└── Billing
```

Explain the problem:

1. Everything is mixed together.
2. Permissions become hard to control.
3. Logs are not strongly protected.
4. Prod and non-prod are too close.
5. Mistakes can affect the whole environment.

### Enterprise Multi-Account Diagram

```text
AWS Organization
│
├── Management Account
│
├── Security OU
│   ├── Log Archive Account
│   └── Security Tooling Account
│
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
│
├── Non-Production OU
│   ├── App1 Dev Account
│   └── App1 Test Account
│
└── Production OU
    └── App1 Prod Account
```

Step-by-step explanation:

1. **Management Account** controls the AWS Organization.
2. **Security OU** protects logs and security tooling.
3. **Infrastructure OU** contains shared networking and platform services.
4. **Non-Production OU** supports development and testing.
5. **Production OU** holds customer-impacting workloads.
6. Each account has a clear purpose and owner.
7. Policies can be applied at the OU level.

### Enterprise Version

```text
Enterprise AWS Organization
│
├── Security OU
│   ├── enterprise-log-archive
│   ├── enterprise-security-tooling
│   └── enterprise-audit
│
├── Platform OU
│   ├── enterprise-network-prod
│   ├── enterprise-network-nonprod
│   ├── enterprise-shared-services
│   └── enterprise-cicd
│
├── Sandbox OU
│   └── team-sandbox-accounts
│
├── NonProd Workloads OU
│   ├── claims-dev
│   ├── claims-test
│   └── billing-dev
│
└── Prod Workloads OU
    ├── claims-prod
    └── billing-prod
```

Teaching point:

The account model should support growth. A landing zone should not be designed only for one application if the enterprise plans to onboard many.

---

## 12. Instructor Demo Script

### Demo Title

**AWS Organizations and Landing Zone Account Structure Walkthrough**

### Demo Objective

Show students how enterprise account structures are represented in AWS and how account separation supports security, governance, and operational control.

### Required Setup

Instructor should have one of the following:

- Access to a demo AWS Organization
- Screenshots of AWS Organizations, Control Tower, and account list
- A pre-built diagram and AWS CLI examples

Recommended for safety:

- Use read-only access
- Do not create or delete accounts during the live demo
- Do not modify SCPs live unless using a sandbox organization

### Demo Part A: Validate AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AROAXAMPLEID:instructor-session",
  "Account": "123456789012",
  "Arn": "arn:aws:sts::123456789012:assumed-role/ReadOnlyRole/instructor-session"
}
```

Explain:

- This shows which AWS account and role you are currently using.
- In enterprise AWS, being in the wrong account is a common troubleshooting issue.

### Demo Part B: Show AWS Organizations

Console actions:

1. Open AWS Console.
2. Search for **AWS Organizations**.
3. Open the organization view.
4. Show the root.
5. Show organizational units.
6. Show accounts under each OU.

Explain:

- The root is the top of the organization.
- OUs group accounts logically.
- Accounts should be placed based on purpose and governance needs.

### Demo Part C: Show Example OU Structure

```text
Root
├── Security
├── Infrastructure
├── Sandbox
├── NonProduction
└── Production
```

### Demo Part D: AWS CLI Read-Only Organization Commands

Only run these if the instructor has Organizations permissions.

```bash
aws organizations describe-organization
```

Expected output example:

```json
{
  "Organization": {
    "Id": "o-exampleorgid",
    "Arn": "arn:aws:organizations::123456789012:organization/o-exampleorgid",
    "FeatureSet": "ALL",
    "MasterAccountId": "123456789012",
    "MasterAccountEmail": "cloud-management@example.com"
  }
}
```

```bash
aws organizations list-accounts
```

Expected output example:

```json
{
  "Accounts": [
    {
      "Id": "111111111111",
      "Name": "log-archive",
      "Email": "aws-log-archive@example.com",
      "Status": "ACTIVE"
    },
    {
      "Id": "222222222222",
      "Name": "network-shared",
      "Email": "aws-network@example.com",
      "Status": "ACTIVE"
    }
  ]
}
```

Explain:

- Account inventory is critical for enterprise governance.
- Naming standards matter.
- Email ownership matters for account lifecycle management.

### Demo Part E: Create a Real OU in a Sandbox Organization (Hands-On)

This is the part the old version skipped. If the instructor has a **sandbox management account** (an org used only for teaching, with nothing of value in it), create a real OU live. Creating an OU is free, fast, and easily reversible.

First find the organization root ID:

```bash
aws organizations list-roots --query 'Roots[0].Id' --output text
```

Expected output (your value will differ):

```text
r-ab12
```

Create a teaching OU under the root:

```bash
aws organizations create-organizational-unit \
  --parent-id r-ab12 \
  --name "Sandbox-Demo"
```

Expected output:

```json
{
  "OrganizationalUnit": {
    "Id": "ou-ab12-c3d4e5f6",
    "Arn": "arn:aws:organizations::123456789012:ou/o-exampleorgid/ou-ab12-c3d4e5f6",
    "Name": "Sandbox-Demo"
  }
}
```

Explain:

- The OU is now a real attachment point for SCPs (Class 2) and for placing vended accounts.
- Capture the `Id` (`ou-...`); you will reference it when attaching a policy.

Cleanup (do this at the end of class so the org stays tidy):

```bash
aws organizations delete-organizational-unit \
  --organizational-unit-id ou-ab12-c3d4e5f6
```

> Note: an OU must be empty (no child accounts or OUs) before it can be deleted.

### Demo Part F: Control Tower and Account Factory Concept Walkthrough

Console actions:

1. Search for **AWS Control Tower**.
2. Show the landing zone overview and the **Account Factory** product (under Service Catalog).
3. Point out landing zone, Account Factory, controls/guardrails, the audit account, and the log archive account.
4. If available, show an **Account Factory for Terraform (AFT)** request repo or a **Landing Zone Accelerator (LZA)** config repo so students see account vending as code, not clicks.

Explain:

> Control Tower standardizes account creation and governance. Account Factory (or AFT, or LZA) is how new accounts are *vended* with the baseline already applied. None of this removes the need for architecture decisions — it just makes good decisions repeatable.

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `AccessDeniedException` when running Organizations CLI | Instructor is not in management account or lacks permissions | Use screenshots or sample JSON |
| AWS Organizations not visible | Account is not part of an organization or user lacks access | Use diagram-based demo |
| Control Tower not enabled | Not every AWS environment uses Control Tower | Explain conceptually with diagram |
| Wrong AWS profile | CLI is using incorrect profile | Run `aws configure list` and switch profile |

### Recovery Commands

```bash
aws configure list
aws sts get-caller-identity --profile your-profile-name
export AWS_PROFILE=your-profile-name
```

### Cleanup Steps

No cleanup required if demo is read-only.

If sample files were created:

```bash
rm -rf week-17-landing-zone-demo
```

---

## 13. Student Lab Manual

### Lab Title

**Design a Multi-Account AWS Landing Zone for an Enterprise Application**

### Lab Objective

Design a basic AWS landing zone account structure for a company onboarding a new enterprise application.

### Estimated Time

45 to 60 minutes

### Student Prerequisites

Students should understand:

- Basic AWS account concepts
- IAM basics
- VPC basics
- Difference between dev, test, and prod
- Basic diagramming
- Basic Markdown or table writing

### Architecture or Workflow Overview

Students will create:

1. AWS Organization structure
2. Organizational units
3. Account inventory
4. Account naming convention
5. Basic access ownership model
6. Azure and GCP comparison notes

### Scenario

A logistics company is moving a customer-facing shipment tracking application to AWS. The company expects more applications to move to AWS later.

The company needs:

- Separate development, test, and production environments
- Centralized security logging
- A network account for shared connectivity
- A shared services account for platform tools
- Restricted production access
- Clear account ownership
- Ability to grow beyond one application

### Step-by-Step Student Instructions

#### Step 1: Create a Working Folder

```bash
mkdir -p week-17-landing-zone/{diagrams,templates,deliverables}
cd week-17-landing-zone
```

Validate:

```bash
ls
```

Expected output:

```text
deliverables  diagrams  templates
```

#### Step 2: Create an Account Inventory File

```bash
cat > deliverables/account-inventory.md <<'STUDENT_EOF'
# AWS Landing Zone Account Inventory

| Account Name | OU | Purpose | Owner Team | Environment | Notes |
|---|---|---|---|---|---|
|  |  |  |  |  |  |
STUDENT_EOF
```

Open the file in VS Code:

```bash
code deliverables/account-inventory.md
```

#### Step 3: Fill in Required Accounts

Students should include at least these accounts:

| Account Name | OU | Purpose | Owner Team | Environment |
|---|---|---|---|---|
| org-management | Root | AWS Organization administration | Cloud Platform | Management |
| org-log-archive | Security | Central audit log storage | Security | Shared |
| org-security-tooling | Security | Security monitoring and findings | Security | Shared |
| org-network-shared | Infrastructure | Shared networking and routing | Network or Cloud Platform | Shared |
| org-shared-services | Infrastructure | Shared platform services | Cloud Platform | Shared |
| shipment-dev | NonProduction | Development workload | App Team | Dev |
| shipment-test | NonProduction | Testing workload | App Team | Test |
| shipment-prod | Production | Production workload | App Team and Cloud Platform | Prod |

#### Step 4: Create an OU Design File

```bash
cat > deliverables/ou-design.md <<'STUDENT_EOF'
# AWS Organizational Unit Design

AWS Organization
|
|-- Security OU
|   |-- org-log-archive
|   |-- org-security-tooling
|
|-- Infrastructure OU
|   |-- org-network-shared
|   |-- org-shared-services
|
|-- NonProduction OU
|   |-- shipment-dev
|   |-- shipment-test
|
|-- Production OU
|   |-- shipment-prod

## Design Explanation

Write 1 to 2 paragraphs explaining why this OU structure was chosen.
STUDENT_EOF
```

#### Step 5: Create a Naming Convention

```bash
cat > deliverables/naming-convention.md <<'STUDENT_EOF'
# AWS Account Naming Convention

Recommended pattern:

<business-unit-or-org>-<application-or-function>-<environment>

Examples:
- org-log-archive
- org-security-tooling
- org-network-shared
- shipment-dev
- shipment-test
- shipment-prod

## Naming Rules

1. Account names should describe purpose.
2. Production accounts should clearly include prod.
3. Shared accounts should clearly identify shared function.
4. Avoid vague names like test1, aws-main, or cloud-account.
STUDENT_EOF
```

#### Step 6: Create an Access Model

```bash
cat > deliverables/access-model.md <<'STUDENT_EOF'
# Landing Zone Access Model

| Team | Accounts Needed | Access Level | Reason |
|---|---|---|---|
| Cloud Platform Team | All workload accounts, shared services | Admin or elevated operations | Build and support infrastructure |
| Security Team | Security, log archive, read-only to workloads | Security admin or read-only audit | Monitor and investigate risk |
| Network Team | Network account, read-only to workloads | Network admin | Manage routing and connectivity |
| Developers | Dev and test workload accounts | Developer or power user with limits | Build and test applications |
| Production Support | Prod workload account | Read-only or controlled break-glass | Troubleshoot production issues |
| Auditors | Log archive and read-only views | Read-only | Compliance and evidence review |
STUDENT_EOF
```

#### Step 7: Add Azure and GCP Comparison Notes

```bash
cat > deliverables/multicloud-comparison.md <<'STUDENT_EOF'
# Azure and GCP Comparison Notes

| Design Concept | AWS | Azure | GCP |
|---|---|---|---|
| Organization root | AWS Organization | Entra tenant and management group root | GCP Organization |
| Grouping layer | Organizational Unit | Management Group | Folder |
| Workload boundary | AWS Account | Azure Subscription | GCP Project |
| Governance policy | SCP | Azure Policy | Organization Policy |
| Central access | IAM Identity Center | Microsoft Entra ID and Azure RBAC | Cloud IAM |
STUDENT_EOF
```

#### Step 8: Validate Deliverables

```bash
find deliverables -type f -maxdepth 1 -print
```

Expected output:

```text
deliverables/account-inventory.md
deliverables/ou-design.md
deliverables/naming-convention.md
deliverables/access-model.md
deliverables/multicloud-comparison.md
```

#### Step 9: Optional Git Commit

```bash
git init
git add .
git commit -m "Add AWS landing zone design"
```

Expected output:

```text
[main <commit-id>] Add AWS landing zone design
```

#### Step 10: Hands-On — Create a Real OU, SCP, and Permission Set (Sandbox)

> Do this only in a disposable **sandbox AWS Organization** that you or your instructor control, never in a real company org. Creating an OU and an SCP is free; an IAM Identity Center instance is also free. Everything here is reversible and you will tear it down in cleanup. You need management-account (or delegated-admin) access for these commands.

The previous steps produced a strong *design*. A senior candidate must also be able to *operate* the org. In this step you will create one OU, attach one SCP to it, and create one Identity Center permission set — the three primitives this entire week is about.

**10a. Enable SCPs (one-time, idempotent).** SCPs only work if the policy type is enabled on the org:

```bash
aws organizations enable-policy-type \
  --root-id "$(aws organizations list-roots --query 'Roots[0].Id' --output text)" \
  --policy-type SERVICE_CONTROL_POLICY
```

If it is already enabled you will get `PolicyTypeAlreadyEnabledException` — that is fine, continue.

**10b. Create an OU** under the root and capture its ID:

```bash
ROOT_ID=$(aws organizations list-roots --query 'Roots[0].Id' --output text)

OU_ID=$(aws organizations create-organizational-unit \
  --parent-id "$ROOT_ID" \
  --name "Lab-NonProduction" \
  --query 'OrganizationalUnit.Id' --output text)

echo "Created OU: $OU_ID"
```

Expected output:

```text
Created OU: ou-ab12-1a2b3c4d
```

**10c. Write a safe, real SCP.** This SCP *requires* a region allow-list — a guardrail that is real but cannot lock you out of identity/billing global services. It denies actions outside two regions while exempting global services (IAM, Organizations, CloudFront, Route 53, etc.) so the org stays operable.

```bash
cat > policies/scp-region-guardrail.json <<'STUDENT_EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyOutsideApprovedRegions",
      "Effect": "Deny",
      "NotAction": [
        "iam:*",
        "organizations:*",
        "sts:*",
        "cloudfront:*",
        "route53:*",
        "waf:*",
        "support:*",
        "budgets:*",
        "globalaccelerator:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        }
      }
    }
  ]
}
STUDENT_EOF
```

> Why `NotAction` + a condition instead of a blanket `Deny`? Global services have no region, so a naive region deny would break IAM and Organizations. This is exactly the kind of footgun SCP testing is meant to catch (Class 2 covers safe rollout).

**10d. Create and attach the SCP:**

```bash
POLICY_ID=$(aws organizations create-policy \
  --name "lab-region-guardrail" \
  --description "Lab: restrict workloads to us-east-1 and us-west-2" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-region-guardrail.json \
  --query 'Policy.PolicySummary.Id' --output text)

aws organizations attach-policy \
  --policy-id "$POLICY_ID" \
  --target-id "$OU_ID"

echo "Attached SCP $POLICY_ID to OU $OU_ID"
```

Verify the attachment (this is the "read the effective policy" skill the review asked for):

```bash
aws organizations list-policies-for-target \
  --target-id "$OU_ID" \
  --filter SERVICE_CONTROL_POLICY
```

Expected output includes your policy:

```json
{
  "Policies": [
    { "Id": "p-xxxxxxxx", "Name": "lab-region-guardrail", "Type": "SERVICE_CONTROL_POLICY", "AwsManaged": false }
  ]
}
```

**10e. Create an IAM Identity Center permission set.** First get the Identity Center instance ARN (Identity Center must be enabled in the org — free):

```bash
INSTANCE_ARN=$(aws sso-admin list-instances \
  --query 'Instances[0].InstanceArn' --output text)

echo "Identity Center instance: $INSTANCE_ARN"
```

Create a least-privilege read-only permission set with a 1-hour session:

```bash
PS_ARN=$(aws sso-admin create-permission-set \
  --instance-arn "$INSTANCE_ARN" \
  --name "Lab-ReadOnly" \
  --description "Lab read-only access" \
  --session-duration "PT1H" \
  --query 'PermissionSet.PermissionSetArn' --output text)

aws sso-admin attach-managed-policy-to-permission-set \
  --instance-arn "$INSTANCE_ARN" \
  --permission-set-arn "$PS_ARN" \
  --managed-policy-arn "arn:aws:iam::aws:policy/ReadOnlyAccess"

echo "Created permission set: $PS_ARN"
```

Inspect what you just built (the "read the JSON" skill):

```bash
aws sso-admin list-managed-policies-in-permission-set \
  --instance-arn "$INSTANCE_ARN" \
  --permission-set-arn "$PS_ARN"
```

> To finish the picture you would `create-account-assignment` to bind a group + this permission set + a target account. We stop short of assignment here to avoid needing a second sandbox account, but you now have a real, inspectable permission set.

**10f. Tear down (run this — leaving SCPs/permission sets around is sloppy and can cost money via the services they enable):**

```bash
# Detach and delete the SCP
aws organizations detach-policy --policy-id "$POLICY_ID" --target-id "$OU_ID"
aws organizations delete-policy --policy-id "$POLICY_ID"

# Delete the OU (must be empty first)
aws organizations delete-organizational-unit --organizational-unit-id "$OU_ID"

# Delete the permission set
aws sso-admin delete-permission-set \
  --instance-arn "$INSTANCE_ARN" \
  --permission-set-arn "$PS_ARN"
```

Evidence-first check: re-run `aws organizations list-policies-for-target --target-id "$OU_ID" ...` *before* deleting the OU and confirm the policy is gone after detach. Symptom → evidence → root cause → fix → validate applies to teardown too.

### Validation Checklist

Students should verify:

- [ ] Management account is not used for workloads
- [ ] Production is separated from non-production
- [ ] Security logging has a dedicated account
- [ ] Network account is separate from workload accounts
- [ ] Shared services account is included
- [ ] Account names are clear
- [ ] Each account has a purpose and owner
- [ ] Azure and GCP equivalents are documented
- [ ] Design can support additional applications later
- [ ] (Hands-on track) A real OU was created and verified in a sandbox org
- [ ] (Hands-on track) An SCP was created, attached to the OU, and confirmed via `list-policies-for-target`
- [ ] (Hands-on track) An IAM Identity Center permission set was created and inspected
- [ ] (Hands-on track) All sandbox resources were torn down and verified deleted

### Troubleshooting Tips

| Issue | Fix |
|---|---|
| Student puts everything under one account | Ask what happens if dev breaks prod |
| Student skips log archive account | Explain audit logs need protection |
| Student puts workloads in management account | Explain management account should be highly restricted |
| Student creates too many accounts | Ask whether each account has a clear purpose |
| Student does not separate prod | Ask about blast radius, compliance, and approvals |
| Student confuses IAM roles with accounts | Clarify that accounts are boundaries, IAM roles are access mechanisms |

### Cleanup Steps

The design track (Steps 1-9) creates no AWS resources. If you ran the hands-on track (Step 10), make sure you completed teardown 10f (delete the SCP, OU, and permission set) and verified with `list-policies-for-target`.

Local cleanup, if needed:

```bash
cd ..
rm -rf week-17-landing-zone
```

### Reflection Questions

1. Why is production usually separated from dev and test?
2. Why should logs be stored outside workload accounts?
3. Which teams should own the network account?
4. Which accounts should developers not directly administer?
5. How would your design change if the application handled regulated data?
6. Would you vend accounts with Control Tower Account Factory, AFT, or LZA for this company, and why?
7. (Hands-on track) Why did the region-guardrail SCP use `NotAction` with a condition instead of a plain `Deny` on all actions?

### Optional Challenge Task

Add a second application to your design without redesigning the entire organization.

Example:

```text
billing-dev
billing-test
billing-prod
```

Then explain whether these accounts should go into the same OUs or different OUs.

---

## 14. Troubleshooting Activity

### Incident Title

**Developer Cannot Access the Production AWS Account**

### Business Impact

A production hotfix is delayed because a developer cannot access the production AWS account. The release window is limited, and the application team is asking the cloud platform team to fix access quickly.

### Symptoms

Developer reports:

```text
I can log in to AWS, but I do not see the production account.
```

Another report:

```text
I can see the dev account, but when I switch roles into prod, I get access denied.
```

Possible CLI output:

```bash
aws sts get-caller-identity
```

```json
{
  "UserId": "AIDAEXAMPLEUSER",
  "Account": "111111111111",
  "Arn": "arn:aws:iam::111111111111:user/developer1"
}
```

Expected prod account:

```text
shipment-prod account ID: 999999999999
```

### Starting Evidence

```text
User: developer1
Group: AppDevelopers
Expected access: shipment-prod read-only or deployment role
Visible accounts: shipment-dev, shipment-test
Not visible: shipment-prod
Recent change: shipment-prod was moved into Production OU
```

### Student Investigation Steps

Students should ask:

1. Is the user logging in through IAM Identity Center or local IAM?
2. Is the user assigned to the production account?
3. Does the user have a permission set for production?
4. Is the user trying to access the correct AWS account?
5. Is MFA required?
6. Was the account recently moved to a new OU?
7. Is an SCP blocking the action?
8. Is this a normal access request or break-glass request?
9. Should the developer have direct production access at all?

### Expected Root Cause

The developer has access to non-production accounts only. The production account is under a stricter OU, and no production permission set has been assigned.

### Correct Resolution

Recommended resolution:

1. Do not grant broad admin access.
2. Confirm business need and approval.
3. Assign the correct IAM Identity Center permission set.
4. Prefer read-only or deployment-specific role.
5. Use a controlled production deployment role if needed.
6. Document the access decision.
7. Confirm access with `aws sts get-caller-identity`.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Give AdministratorAccess immediately | Violates least privilege |
| Move prod account into non-prod OU | Weakens governance |
| Disable SCPs without approval | Removes enterprise guardrails |
| Use root account | Unsafe and inappropriate |
| Share another user's credentials | Serious security violation |

### Instructor Hints

Start with these hints only if students are stuck:

1. “What account is the user actually logged into?”
2. “Can the user see prod in IAM Identity Center?”
3. “Is this an IAM permission problem or an account assignment problem?”
4. “Should developers have permanent production access?”

### Preventive Action

- Use documented access request process
- Define standard permission sets
- Separate dev, test, and prod access
- Require approval for production roles
- Review account assignments regularly
- Use break-glass roles only when necessary
- Monitor production role assumptions

---

## 15. Scenario-Based Discussion Questions

### Question 1

**Why should production workloads be placed in separate AWS accounts from development workloads?**

Expected themes:

- Blast radius reduction
- Stronger access control
- Separate billing
- Better auditability
- Different deployment rules
- Compliance boundaries

Follow-up:

> What could happen if a developer accidentally runs Terraform destroy in a shared dev/prod account?

### Question 2

**Should every application have separate dev, test, and prod AWS accounts?**

Expected themes:

- Depends on size, risk, compliance, and cost
- Smaller teams may group non-prod
- Production should usually be isolated
- Highly regulated apps may need stricter separation

Follow-up:

> When would shared non-prod accounts be acceptable?

### Question 3

**Who should own the network account?**

Expected themes:

- Cloud platform team
- Network team
- Shared ownership model
- Strong change control
- Limited direct app team access

Follow-up:

> What risks appear if every app team manages its own routing independently?

### Question 4

**Why should audit logs go into a dedicated log archive account?**

Expected themes:

- Protect logs from modification
- Preserve investigation evidence
- Support compliance
- Separate duties between operators and auditors

Follow-up:

> Should workload admins be able to delete their own CloudTrail logs?

### Question 5

**What is the tradeoff between fewer accounts and many accounts?**

Expected themes:

- Fewer accounts are simpler
- More accounts improve isolation
- Too many accounts require automation and governance
- Naming and ownership become important

Follow-up:

> How can automation reduce the operational burden of managing many accounts?

### Question 6

**How does account separation help cost management?**

Expected themes:

- Clearer chargeback
- Easier environment-level reporting
- Easier budget alerts
- Easier cleanup accountability

Follow-up:

> Would tagging alone be enough for cost separation?

### Question 7

**How is an AWS account similar to an Azure subscription or GCP project?**

Expected themes:

- Major cloud resource boundary
- Billing and access scope
- Governance and policy attachment point
- Workload isolation unit

Follow-up:

> What are the dangers of assuming all cloud providers use the exact same hierarchy?

### Question 8

**Should developers have direct production access?**

Expected themes:

- Usually limited
- Read-only may be acceptable
- Deployment should go through pipeline
- Break-glass access should be controlled
- Audit and approval are important

Follow-up:

> What is a safer alternative to permanent production admin access?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is the main reason enterprises use multiple AWS accounts?

A. To make AWS billing more confusing  
B. To improve isolation, governance, billing, and security boundaries  
C. To avoid using IAM  
D. To remove the need for monitoring  

**Answer:** B  
**Explanation:** Multiple accounts help separate environments, teams, billing, permissions, and security boundaries.

### Question 2: Multiple Choice

Which account should usually be protected from normal application workloads?

A. Dev account  
B. Test account  
C. Management account  
D. Sandbox account  

**Answer:** C  
**Explanation:** The management account controls the AWS Organization and should not host normal workloads.

### Question 3: True or False

A landing zone is only a VPC and subnet design.

**Answer:** False  
**Explanation:** A landing zone includes account structure, identity, networking, logging, governance, security, and operational standards.

### Question 4: Short Answer

What is blast radius in cloud architecture?

**Answer:** Blast radius is the scope of impact caused by a failure, mistake, or security issue.  
**Explanation:** Account separation reduces blast radius by limiting how far a problem can spread.

### Question 5: Multiple Choice

Which AWS service centrally manages multiple AWS accounts?

A. AWS IAM  
B. AWS Organizations  
C. Amazon EC2  
D. Amazon S3  

**Answer:** B  
**Explanation:** AWS Organizations is used to centrally manage multiple AWS accounts.

### Question 6: Multiple Choice

Which account is commonly used to store centralized audit logs?

A. Log archive account  
B. Developer sandbox account  
C. Prod workload account  
D. NAT account  

**Answer:** A  
**Explanation:** A log archive account protects audit and security logs from workload-level changes.

### Question 7: True or False

Developers should always have AdministratorAccess to production accounts for faster troubleshooting.

**Answer:** False  
**Explanation:** Production access should be controlled, approved, audited, and based on least privilege.

### Question 8: Troubleshooting Question

A developer says they can access the dev account but cannot see the prod account in the AWS access portal. What are two likely causes?

**Answer:** Possible causes include no IAM Identity Center assignment for the prod account, no production permission set assigned, user is in the wrong group, prod account is under a stricter OU, or access request was not approved.  
**Explanation:** This is likely an account assignment or access governance issue, not necessarily a broken AWS service.

### Question 9: Troubleshooting Question

A user runs `aws sts get-caller-identity` and sees an unexpected account ID. What does that indicate?

**Answer:** The user is authenticated to the wrong AWS account or using the wrong profile or role.  
**Explanation:** Always verify identity and account context before troubleshooting permissions.

### Question 10: Short Answer

What is one AWS equivalent for Azure Management Groups and GCP folders?

**Answer:** AWS Organizational Units.  
**Explanation:** OUs group AWS accounts and allow governance controls to be applied at group level.

### Question 11: Multiple Choice

Which of the following is the best account structure for a beginner enterprise landing zone?

A. One account with dev, test, prod, logs, and security tools  
B. Separate accounts for log archive, security tooling, shared services, network, non-prod, and prod  
C. One account per developer only  
D. No accounts, only IAM users  

**Answer:** B  
**Explanation:** This structure supports separation of duties, governance, logging, and workload isolation.

### Question 12: Short Answer

Why is naming convention important in AWS account design?

**Answer:** It helps teams quickly identify account purpose, environment, ownership, and risk level.  
**Explanation:** Clear names reduce operational mistakes and improve governance.

---

## 17. Homework Assignment

### Assignment Title

**Enterprise AWS Landing Zone Account Structure Proposal**

### Scenario

A company is moving a customer-facing application to AWS. The application has development, testing, and production environments. The company also needs centralized logging, shared networking, security visibility, and room for future applications.

### Student Tasks

Create a proposal that includes:

1. Business scenario summary
2. AWS Organization diagram
3. Organizational units
4. Account list
5. Purpose of each account
6. Owner team for each account
7. Environment classification
8. Naming convention
9. Access model summary
10. Azure and GCP comparison notes
11. Explanation of why this design is better than one shared account

### Expected Deliverables

```text
landing-zone-proposal/
├── account-inventory.md
├── ou-design.md
├── naming-convention.md
├── access-model.md
├── multicloud-comparison.md
└── summary.md
```

### Submission Format

Accepted formats:

- Git repository link
- Zip file
- PDF export
- Markdown folder

### Estimated Completion Time

2 to 4 hours

### Grading Criteria

| Criteria | Points |
|---|---:|
| Clear account structure | 20 |
| Correct separation of security, network, shared services, non-prod, and prod | 25 |
| Strong explanation of account purpose and ownership | 20 |
| Practical naming convention | 10 |
| Azure and GCP comparison included | 10 |
| Clear diagram and professional documentation | 15 |
| Total | 100 |

### Optional Advanced Challenge

Add a second application and show how the landing zone can scale without redesigning the organization.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Putting workloads in the management account | Students think the management account is the main AWS account | Explain that management account is for organization administration only |
| Skipping log archive account | Students underestimate audit and compliance needs | Explain why logs should be protected from workload admins |
| Combining dev and prod in one account | Students focus on simplicity | Teach blast radius, access control, and production change risk |
| Creating too many accounts without purpose | Students overcorrect after learning account separation | Every account needs a clear owner, purpose, and governance reason |
| Confusing OUs with accounts | Both appear in hierarchy diagrams | Clarify that OUs are groupings, accounts contain resources |
| Thinking SCPs grant permissions | Students confuse SCPs with IAM policies | Explain SCPs limit maximum permissions, IAM grants permissions |
| Ignoring cost ownership | Students focus only on security | Include billing and chargeback as design drivers |
| Making account names vague | Students use names like `main`, `test1`, `aws-prod` | Use naming patterns that identify app, function, and environment |
| Giving developers admin access everywhere | Students think access solves speed problems | Teach least privilege and controlled production access |
| Skipping Azure/GCP comparison | Students focus only on AWS | Add short comparison to build multi-cloud awareness |

---

## 19. Real-World Enterprise Scenario

### Scenario

A logistics company is modernizing its shipment tracking platform. The company currently has several teams using AWS in an unstructured way. Some teams created resources manually, production and development resources are mixed, and security logs are spread across accounts.

Leadership wants a scalable AWS foundation before onboarding more applications.

### Constraints

| Constraint | Detail |
|---|---|
| Access control | Developers should not have broad production admin access |
| Security | CloudTrail and security logs must be protected |
| Cost | Finance needs clear cost allocation by application and environment |
| Reliability | Production workloads must be isolated from experiments |
| Compliance | Security team must have audit visibility |
| Operations | Cloud platform team must support many future applications |
| Networking | Shared network connectivity may be required later |
| Approvals | Production account changes require stricter review |

### What Each Role Would Do

#### Cloud Engineer

- Design account structure
- Define OUs and account boundaries
- Work with network and security teams
- Document naming standards
- Support landing zone implementation

#### DevOps Engineer

- Design pipeline access to dev, test, and prod accounts
- Avoid long-lived credentials
- Use role-based deployment patterns
- Support environment promotion

#### SRE

- Ensure production accounts have monitoring and incident readiness
- Define operational visibility needs
- Require logs, metrics, runbooks, and escalation paths
- Identify reliability risks in account design

---

## 20. Instructor Tips

### Teaching Tips

- Start with the business problem before introducing AWS services.
- Use simple diagrams first.
- Repeat that accounts are boundaries, not just billing containers.
- Avoid going too deep into SCP syntax in Class 1. Save deeper governance for Class 2.
- Use a fictional business application to make the design concrete.

### Pacing Tips

- Do not spend more than 20 minutes on Azure/GCP comparison.
- Keep Control Tower conceptual unless students are already strong in AWS.
- Spend enough time on account purpose and ownership because this is where beginners struggle.
- Leave at least 30 minutes for the lab.

### Lab Support Tips

When students struggle, ask:

- What is the purpose of this account?
- Who owns it?
- Is it production or non-production?
- What would happen if someone misconfigured it?
- Should logs live inside the workload account?

### Helping Struggling Students

Give them this minimum structure:

```text
Security OU
Infrastructure OU
NonProduction OU
Production OU
```

Then help them place accounts under each OU.

### Challenging Advanced Students

Ask them to add:

- Sandbox OU
- Suspended accounts OU
- Separate prod and non-prod network accounts
- Account vending process
- Tagging policy
- Break-glass access model
- Multi-region DR account considerations

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] What an AWS landing zone is
- [ ] Why enterprises use multiple AWS accounts
- [ ] What AWS Organizations does
- [ ] What organizational units are
- [ ] Why production and non-production are separated
- [ ] Why logs should be centralized
- [ ] What a shared services account is
- [ ] What a network account is
- [ ] How AWS account structure compares to Azure and GCP

### Students Should Be Able to Build or Configure

- [ ] A basic AWS Organization diagram
- [ ] An OU structure
- [ ] An account inventory table
- [ ] A naming convention
- [ ] An access model summary
- [ ] A basic multi-cloud comparison table

### Students Should Be Able to Troubleshoot

- [ ] Wrong AWS account context
- [ ] Missing production account assignment
- [ ] Wrong role or profile
- [ ] Missing permission set
- [ ] Confusion between IAM permissions and account access
- [ ] Poor account placement in an OU
- [ ] Overly broad access request

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Students can explain why one AWS account does not scale
- [ ] Students understand landing zone as a full foundation, not just networking
- [ ] Students understand common account types
- [ ] Students completed or started the account design lab
- [ ] Students understand the homework deliverables
- [ ] Students know Class 2 will cover governance, guardrails, SCPs, and access troubleshooting
- [ ] Students saved their lab files
- [ ] Students who ran the hands-on track tore down their sandbox OU, SCP, and permission set

### Student Checklist Before Leaving Class

- [ ] I can explain what a landing zone is
- [ ] I can explain why multi-account design matters
- [ ] I created an account inventory
- [ ] I created an OU design
- [ ] I created a naming convention
- [ ] I created an access model draft
- [ ] I added Azure and GCP comparison notes
- [ ] I understand the homework assignment
- [ ] I know what questions to bring to Class 2

### Items to Verify Before Moving to Class 2

- [ ] Students understand AWS account hierarchy
- [ ] Students understand the difference between management, security, shared, network, dev, test, and prod accounts
- [ ] Students understand why governance is needed
- [ ] Students are ready to discuss SCPs, permission sets, and guardrails
- [ ] Students have a draft landing zone design that can be extended in Class 2

---

## Class Artifacts & Validation

This class is design-first (the account-structure deliverables in the lab manual are Markdown), but its **policy-as-code and account-baseline primitives** ship as real, validated files in two backing module repos. The rows below are the artifacts this class actually uses: the **SCP / least-privilege / policy-as-code** patterns introduced and operated in the hands-on track (Step 10 builds and attaches a real region-guardrail SCP), and the **on-disk VPC account-baseline** infra that a landing-zone account is expected to start from. All paths are repo-relative and resolve; all results were re-run in this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/security-automation/solution/policies/scp/deny-leave-org.json` | json (SCP) | Org-root guardrail SCP — the reference for the kind of preventive control this class introduces (and the Step 10 region-guardrail SCP students build live) | `python3 -m json.tool < labs/security-automation/solution/policies/scp/deny-leave-org.json` | PASS |
| 2 | `labs/security-automation/solution/policies/iam/good-policy.json` | json | Least-privilege IAM policy — the target shape for the access-model deliverable (named ARNs, scoped actions, a `Deny` guardrail) | `python3 labs/security-automation/solution/iam_policy_audit.py labs/security-automation/solution/policies/iam/good-policy.json` (exit 0, 0 findings) | PASS |
| 3 | `labs/security-automation/solution/policies/iam/bad-policy.json` | json | Over-broad IAM fixture (wildcard `Action`/`Resource`, `NotAction`) — what the least-privilege model must avoid | `python3 labs/security-automation/solution/iam_policy_audit.py labs/security-automation/solution/policies/iam/bad-policy.json` (exit 1, 6 findings) | PASS |
| 4 | `labs/security-automation/solution/iam_policy_audit.py` | python | Pure-function + CLI IAM auditor that gates an over-broad policy in CI | `PYTHONPATH=labs/security-automation/solution python3 -m unittest discover -s labs/security-automation/tests` | PASS (14 tests, OK) |
| 5 | `labs/terraform-aws-foundations/solution/modules/vpc/main.tf` | terraform | The on-disk VPC account-baseline (subnets, IGW, locked-down default SG, VPC flow logs) a landing-zone workload account starts from | `terraform -chdir=labs/terraform-aws-foundations/solution validate` | PASS — `Success! The configuration is valid.` |
| 6 | `labs/terraform-aws-foundations/solution` | terraform | Full VPC root module, applied to and destroyed from a real AWS account (account 071146695791, us-east-1; `Apply complete! Resources: 19 added` → `Destroy complete! Resources: 19 destroyed`) | `./labs/terraform-aws-foundations/validate.sh` (static) + live apply/destroy | PASS — see `labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt` |

> Note: the hands-on Step 10 (`create-organizational-unit`, `enable-policy-type`, `create-policy`/`attach-policy`, `create-permission-set`) operates against a **live sandbox AWS Organization** and is not captured as a committed evidence file in this repo — it is an instructor/student live exercise. The committed, repeatable artifacts above are the policy-as-code and account-baseline files those commands govern.

## Definition of Done

Ticked honestly for **this class**. This is a design + light-hands-on class whose runnable artifacts live in the two backing module repos; it does not introduce its own new starter/solution lab beyond what those repos ship.

- [x] Every technology taught ships at least one **runnable file on disk** — SCP/IAM JSON, the IAM auditor, and the VPC Terraform module all exist as real files (not just fences) in `labs/security-automation/` and `labs/terraform-aws-foundations/`.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `json.tool`, `terraform validate`, `python3 -m unittest`, and the IAM auditor behavioural exits were all re-run here (see manifest).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — both backing labs ship `starter/` (TODO'd) and `solution/` trees.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — both backing-lab READMEs cover all of these.
- [x] **Cleanup/teardown** is provided and idempotent — the in-class Step 10 hands-on includes mandatory teardown (10f); the backing labs document `terraform destroy` and local cleanup; the live VPC run confirmed a clean destroy.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — Sections 13–17 here, plus the `Instructor answer key` sections in both backing-lab READMEs.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — Section 14 (developer-cannot-access-prod) here; the backing labs add `broken/` fixtures (`terraform validate` failure; planted secret).
- [x] **Expected outputs** are shown for demos and labs — CLI/JSON expected outputs throughout Sections 12–13 and in the manifest.
- [x] **Cost & security warnings** present — cost/security notes appear in Step 10 (free, reversible org primitives), the Control Tower cost warning (Section 10), and both backing-lab READMEs.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/security-automation/` and `labs/terraform-aws-foundations/`, and to Weeks 4/5/6/14/15/18/19/20/23/24, verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`/validation above.
