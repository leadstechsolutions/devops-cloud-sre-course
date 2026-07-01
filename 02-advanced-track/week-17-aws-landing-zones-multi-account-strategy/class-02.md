# Week 17, Class 2: Governing Multi-Account AWS with Control Tower, SCPs, and Identity

**Track:** Unified DevOps · Cloud · SRE Track  
**Week:** 17  
**Module:** AWS Landing Zones and Multi-Account Strategy  
**Class Duration:** 3 hours  
**Primary Cloud:** AWS  
**Secondary Cloud Exposure:** Azure and GCP  

---

# 1. Class Overview

> **▶ Runnable lab for this class:** [`labs/security-automation/`](../../labs/security-automation/) · [`labs/terraform-aws-foundations/`](../../labs/terraform-aws-foundations/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class Title

**Governing AWS Accounts with Control Tower, SCPs, and Identity Boundaries**

## Class Purpose

This class teaches students how enterprise cloud teams govern the AWS account structure designed in Class 1. Students move from designing account boundaries to understanding how organizations enforce security, access, logging, and operational guardrails across those accounts.

Class 1 answered:

> “How should enterprise AWS accounts be structured?”

Class 2 answers:

> “How do we control, protect, and troubleshoot those accounts after they exist?”

## How This Class Builds From Class 1

In Class 1, students designed a landing zone with accounts such as:

- Management account
- Log archive account
- Security tooling account
- Network account
- Shared services account
- Dev account
- Test account
- Prod account

In Class 2, students extend that design by adding:

- Governance controls
- Service Control Policies
- IAM Identity Center permission sets
- Access boundaries
- Production guardrails
- Troubleshooting flows for access-denied errors

## What Students Will Build, Analyze, or Practice

Students will:

- Add governance controls to their Class 1 landing zone design
- Define access models for platform, security, developer, auditor, and production support teams
- Write plain-English SCP examples
- Analyze the difference between IAM permissions and SCP restrictions
- Troubleshoot an access-denied scenario caused by organizational guardrails
- Create a basic landing zone governance proposal

---

# 2. Quick Review of Class 1

## Review Points

1. An AWS landing zone is a secure, governed cloud foundation, not just a VPC.
2. Enterprises use multiple AWS accounts to reduce blast radius and improve governance.
3. AWS Organizations centrally manages AWS accounts.
4. Organizational Units group accounts by purpose, environment, risk, or ownership.
5. Common enterprise accounts include security, log archive, network, shared services, non-prod, and prod.
6. Production workloads should usually be isolated from development and testing workloads.
7. The management account should not host normal application workloads.
8. AWS accounts are similar to Azure subscriptions and GCP projects as major workload boundaries.

## Quick Recall Questions

1. **Why should production and development workloads usually be in separate AWS accounts?**  
   Expected answer: To reduce blast radius, separate permissions, protect production data, improve auditability, and support stricter production controls.

2. **What is the purpose of a log archive account?**  
   Expected answer: To centrally store audit and security logs in a protected account.

3. **What is an Organizational Unit in AWS Organizations?**  
   Expected answer: A logical grouping of AWS accounts where policies and governance controls can be applied.

## Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students may think account separation alone creates security | Explain that accounts create boundaries, but governance controls enforce behavior |
| Students may confuse OUs with accounts | Reinforce that OUs group accounts, while accounts contain resources |
| Students may think admin access inside an account means unlimited access | Introduce SCPs as organization-level boundaries |
| Students may not understand why production access should be limited | Use real incident examples such as accidental deletion, misconfigured security groups, or public data exposure |
| Students may view governance as bureaucracy | Frame governance as a way to safely scale cloud adoption |

## Instructor Bridge Into Class 2

Say:

> In Class 1, we designed the account structure. Today, we will protect that structure. A multi-account design without governance is just a diagram. Governance is what makes the design safe, repeatable, auditable, and enterprise-ready.

---

# 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** how governance is applied across AWS accounts using AWS Organizations, Control Tower, IAM Identity Center, and SCPs.
2. **Compare** IAM permissions and Service Control Policies.
3. **Document** an access model for platform, security, developer, auditor, and production support teams.
4. **Build** a basic governance table for an AWS landing zone.
5. **Write** plain-English examples of preventive and detective guardrails.
6. **Troubleshoot** access-denied errors caused by IAM permissions, permission sets, SCPs, or account placement.
7. **Validate** whether a blocked cloud action is a problem or an intentional enterprise control.
8. **Recommend** safer alternatives when a workload team requests risky cloud access.
9. **Distinguish** SCPs, RCPs, and declarative policies and choose the right one for a given control.
10. **Design** multi-account networking with Transit Gateway, centralized egress, and AWS RAM sharing.
11. **Roll out** an SCP safely (validate, stage in a sandbox OU, expand) and design a break-glass mechanism.

---

# 4. Prerequisites Students Should Already Know

## Required Class 1 Knowledge

Students should understand:

- What a landing zone is
- Why enterprises use multiple AWS accounts
- Common AWS account types
- Basic AWS Organization structure
- OUs and account placement
- Why production and non-production accounts are separated
- Why log archive and security tooling accounts exist

## Required Prior Concepts

Students should already know:

- Basic IAM users, roles, and policies
- Basic least privilege concepts
- Basic CloudTrail purpose
- Basic production access risk
- Basic AWS CLI identity validation using `aws sts get-caller-identity`
- Basic Git and Markdown documentation

## Required Tools Already Installed

Students should have:

- Browser
- VS Code
- Terminal
- Git
- AWS CLI
- Diagramming tool or Markdown editor

## Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should continue from their Class 1 folder:

```text
week-17-landing-zone/
├── deliverables/
│   ├── account-inventory.md
│   ├── ou-design.md
│   ├── naming-convention.md
│   ├── access-model.md
│   └── multicloud-comparison.md
```

Class 2 will add:

```text
week-17-landing-zone/
├── deliverables/
│   ├── governance-model.md
│   ├── guardrails.md
│   ├── scp-examples.md
│   ├── access-troubleshooting-flow.md
│   └── class-2-summary.md
```

---

# 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Governance | Rules, processes, and controls that guide how cloud resources are used | Enterprises use governance to control risk, cost, security, and compliance |
| Guardrail | A control that prevents or detects unsafe cloud behavior | Example: block public S3 buckets or detect unencrypted storage |
| Preventive Control | A control that blocks an action before it happens | Example: deny disabling CloudTrail |
| Detective Control | A control that identifies a problem after it happens | Example: alert when an S3 bucket becomes public |
| Service Control Policy | An AWS Organizations policy that defines the maximum permissions available to principals in accounts | SCPs can block risky actions even if IAM allows them |
| Resource Control Policy (RCP) | An AWS Organizations policy that caps the maximum permissions on resources, evaluated against any principal including external ones | Used for data-perimeter rules, e.g. "no one outside our org can read our S3 buckets" |
| Declarative Policy | An Organizations policy that enforces a desired service configuration org-wide, including for future resources | Example: enforce EBS encryption-by-default or block public AMIs everywhere |
| Delegated Administration | Moving admin of an org-wide service (GuardDuty, Config, Security Hub) out of the management account into the security account | Keeps the management account minimal, per the AWS Security Reference Architecture |
| Transit Gateway (TGW) | A regional hub that connects many VPCs and accounts with route-table control | The scalable replacement for a VPC-peering mesh; owned in the network account |
| Centralized Egress | Routing all outbound internet traffic through a shared egress/inspection VPC | Fewer NAT gateways to govern and one place to inspect/filter egress |
| AWS RAM | Resource Access Manager — shares resources (TGW, subnets) across accounts in the org | How workload accounts use the network account's TGW or shared VPC |
| Automated Remediation | Auto-fixing non-compliant resources via Config remediation or EventBridge + Lambda/SSM | Detective controls that fix the problem instead of only alerting |
| IAM Policy | A policy that grants or denies permissions to users, groups, or roles inside an AWS account | IAM is used for day-to-day access control |
| Permission Set | An IAM Identity Center template that defines what access a user or group receives in an AWS account | Example: ReadOnly, Developer, PowerUser, ProductionSupport |
| IAM Identity Center | AWS service for centrally managing workforce access to multiple AWS accounts | Enterprises use it instead of creating local IAM users everywhere |
| Explicit Deny | A deny rule that overrides allow permissions | If a policy denies an action, adding another allow usually does not fix it |
| Account Assignment | A mapping that gives a user or group a permission set in a specific AWS account | If a user cannot see an account, they may be missing an account assignment |
| Break-Glass Access | Emergency access used during critical incidents | Should be controlled, logged, approved, and reviewed |
| Least Privilege | Granting only the access required to do a job | Prevents unnecessary risk and accidental damage |
| Permission Boundary | A boundary that limits the maximum permissions a role or user can receive | Useful for delegated administration |
| Account Placement | Which OU an AWS account belongs to | Account placement matters because SCPs and controls may apply at the OU level |

---

# 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | To demonstrate AWS Organizations, Control Tower concepts, IAM Identity Center, and policy placement |
| AWS CLI | To validate identity, account context, and demonstrate access troubleshooting patterns |
| VS Code | To edit governance documents and Markdown deliverables |
| Git | To version control landing zone design and governance proposals |
| Markdown | To document guardrails, access models, and troubleshooting flows |
| Diagramming tool | To extend Class 1 account diagrams with governance layers |
| Spreadsheet or table editor | To organize access models and guardrail matrices |
| IAM Policy Simulator | Optional tool to explain IAM policy evaluation, though SCP behavior may need conceptual explanation |

---

# 7. AWS Services Used

| AWS Service | How It Connects to the Class |
|---|---|
| AWS Organizations | Central structure for accounts, OUs, and SCPs |
| AWS Control Tower | Helps create and govern a landing zone baseline |
| IAM Identity Center | Centralized human access across multiple AWS accounts |
| Service Control Policies | Organization-level maximum permission boundaries on principals |
| Resource Control Policies (RCPs) | Organization-level maximum permission boundaries on resources, including external access |
| Declarative Policies | Org-wide enforcement of a desired service configuration |
| AWS Transit Gateway | Multi-account/multi-VPC routing hub owned in the network account |
| AWS RAM | Shares the Transit Gateway and shared VPC subnets across accounts |
| AWS Network Firewall | Optional inspection/filtering at the centralized egress point |
| Amazon EventBridge + AWS Lambda / SSM Automation | Automated remediation of non-compliant resources |
| IAM Access Analyzer | Validates SCP/IAM policy logic before rollout (policy-as-code testing) |
| IAM | Grants user, role, and service permissions inside accounts |
| STS | Used to confirm the current identity, role, and account |
| CloudTrail | Provides audit logs for account activity |
| AWS Config | Supports detective controls and compliance visibility |
| KMS | Supports encryption governance patterns |
| S3 Block Public Access | Example of a protective control against public exposure |
| AWS Billing and Cost Management | Supports cost governance and budget controls |
| GuardDuty | Example security service for threat detection |

---

# 8. Azure and GCP Comparison Notes

Keep this practical and short.

| Governance Concept | AWS | Azure | GCP |
|---|---|---|---|
| Account grouping | Organizational Units | Management Groups | Folders |
| Workload boundary | AWS Account | Azure Subscription | GCP Project |
| Preventive policy | SCPs, Control Tower controls | Azure Policy | Organization Policy |
| Central identity | IAM Identity Center | Microsoft Entra ID | Cloud Identity and IAM |
| Audit logs | CloudTrail | Azure Activity Log | Cloud Audit Logs |
| Security posture | Security Hub, GuardDuty | Defender for Cloud | Security Command Center |

Teaching point:

> The names are different, but the enterprise goal is the same: centralize access, apply policy, protect logs, control risk, and make cloud environments repeatable.

---

# 9. Time-Boxed Instructor Agenda

| Time | Section | Activity |
|---:|---|---|
| 0:00 to 0:10 | Class 1 review | Review account structure, OUs, and landing zone purpose |
| 0:10 to 0:30 | Governance foundations | Guardrails, preventive vs detective, IAM vs SCP, RCPs and declarative policies |
| 0:30 to 0:50 | Identity + delegated admin | Permission sets, account assignments, delegated administration, break-glass design |
| 0:50 to 1:05 | Multi-account networking | TGW, centralized egress, RAM/shared VPC |
| 1:05 to 1:15 | Break | Short break |
| 1:15 to 1:40 | Instructor demo | Corrected public-S3 SCP, safe rollout, access troubleshooting flow, auto-remediation |
| 1:40 to 2:20 | Student lab | Extend landing zone with governance; hands-on attach/test/remove a real SCP (sandbox) |
| 2:20 to 2:40 | Troubleshooting activity | Pipeline/admin role blocked by SCP or guardrail |
| 2:40 to 2:52 | Discussion | When should a blocked action stay blocked? |
| 2:52 to 3:00 | Recap | Confirm weekly outcomes and assign homework |

---

# 10. Instructor Lesson Plan

## Step 1: Start With a Review

Ask students to open their Class 1 landing zone design.

Say:

> Yesterday or in the previous class, we designed the account structure. Today we will decide how that structure is governed. We are going to answer who gets access, what actions are blocked, what logs must be protected, and how to troubleshoot access failures.

Ask:

- Which accounts should developers access?
- Which accounts should only security or platform teams control?
- Which account should store logs?
- Should production have the same rules as development?

## Step 2: Introduce Governance

Explain:

> Governance is how a company makes sure cloud teams can move quickly without creating unacceptable risk.

Make governance concrete:

- Prevent public data exposure
- Prevent audit logging from being disabled
- Prevent production changes without approval
- Restrict unsupported regions
- Require encryption
- Require ownership tags
- Limit admin access

Teaching tip:

Avoid making governance sound like paperwork. Tie it to actual incidents.

## Step 3: Explain Guardrails

Use a simple framing:

```text
Preventive control = blocks the risky action
Detective control = finds or alerts on risky activity
```

Examples:

| Risk | Preventive Guardrail | Detective Guardrail |
|---|---|---|
| Public S3 bucket | Block public access | Alert if bucket becomes public |
| Disabled audit logging | Deny CloudTrail stop/delete | Alert if logging changes |
| Unapproved region | Deny resource creation outside approved regions | Report resources in unapproved regions |
| Untagged resources | Block creation without tags | Report resources missing tags |

Pause for questions:

> Which risks should be blocked completely, and which should only trigger an alert?

## Step 4: Explain IAM vs SCP

Say:

> IAM answers: “Does this user or role have permission?”  
> SCP answers: “Is this action even allowed in this account or OU?”

Use this simple model:

```text
Final access requires:
IAM allows the action
AND
SCP does not block the action
AND
No other explicit deny applies
```

Important beginner point:

> SCPs do not grant permissions. They only limit the maximum permissions available.

## Step 5: Explain IAM Identity Center

Explain:

> In enterprise AWS, we usually do not create separate IAM users in every account. We use centralized identity and assign permission sets to users or groups.

Examples of permission sets:

- ReadOnly
- Developer
- PowerUserNonProd
- ProductionReadOnly
- ProductionDeployment
- SecurityAudit
- NetworkAdmin
- BreakGlassAdmin

Ask:

> Which permission set should a developer get in dev? What about prod?

## Step 6: Instructor Demo

Walk through:

- AWS Organizations hierarchy
- Where SCPs attach
- Sample SCPs
- IAM Identity Center permission set concept
- Access troubleshooting using `aws sts get-caller-identity`
- Example `AccessDenied` message

## Step 7: Student Lab

Students extend their Class 1 design.

They will create:

- Governance model
- Guardrail table
- Plain-English SCP examples
- Access troubleshooting flow
- Updated access model

Instructor circulates and asks:

- Does every account have the right owner?
- Which actions should be blocked in production?
- Which logs must be protected?
- What should developers be allowed to do?
- What should only platform/security teams do?

## Step 8: Troubleshooting Activity

Give students the scenario:

> A pipeline role has AdministratorAccess in dev, but it cannot create a public S3 bucket.

Students determine:

- Is this a failure?
- Is this a guardrail working correctly?
- Should the control be bypassed?
- What is the safer architecture?

## Step 9: Teach Multi-Account Networking

Because the converged track has no separate enterprise-networking week, the multi-account networking foundation lives here, in the landing zone it belongs to. Cover (see lecture notes Section 11 and whiteboard Section 12):

- The **network account** as the owner of shared connectivity.
- **AWS Transit Gateway (TGW)** as the hub that connects workload VPCs across accounts.
- **Centralized egress** through a shared inspection/egress VPC instead of a NAT gateway per account.
- **AWS RAM (Resource Access Manager)** to share the TGW (and, in shared-VPC designs, subnets) into workload accounts.
- How governance from earlier in this class applies: who may modify routing, and SCPs that protect networking.

## Step 10: Close the Week

End with:

> A good landing zone is not only about account structure. It must also include access, guardrails, logging, policy, networking, and troubleshooting patterns. This is the enterprise foundation the rest of the course builds on — cost operations next week (Week 18), then DevSecOps (Week 19) and platform engineering (Week 20) reuse these guardrails and account-vending patterns directly.

---

# 11. Instructor Lecture Notes

## Opening Talking Point

> Class 1 gave us the shape of the AWS environment. Class 2 gives us the rules. In enterprise cloud engineering, both are required. A landing zone without governance is just a collection of accounts.

## What Governance Really Means

Governance is the practical system of controls that lets many teams use cloud safely.

It answers:

- Who can access which account?
- What actions are never allowed?
- What actions require approval?
- Which logs must be retained?
- Which regions are approved?
- Which resources must be encrypted?
- Which tags are required?
- What happens when someone gets access denied?

Say out loud:

> Governance is not about slowing teams down. Good governance makes safe work faster because teams know the rules before they deploy.

## Guardrails

Guardrails are policies, controls, and processes that keep teams within safe boundaries.

### Preventive Guardrails

Preventive guardrails block unsafe actions.

Examples:

- Deny disabling CloudTrail
- Deny public S3 buckets
- Deny unsupported AWS regions
- Deny unencrypted storage
- Deny deleting backup vaults

### Detective Guardrails

Detective guardrails report or alert after something happens.

Examples:

- Alert when an S3 bucket becomes public
- Report untagged resources
- Detect unencrypted EBS volumes
- Alert on root account usage
- Detect security group open to the internet

Teaching note:

Beginners may think every control should block everything. Explain that too many hard blocks can slow work. Some risks should be blocked, others should be detected and reviewed.

## IAM vs SCP

This is the most important concept in Class 2.

IAM policy:

- Grants or denies permissions inside an AWS account
- Attached to users, groups, roles, or resources
- Used for normal access management

SCP:

- Applied through AWS Organizations
- Attached to root, OU, or account
- Sets the maximum allowed permissions
- Does not grant access by itself
- Can block even administrators

Say out loud:

> IAM is like your badge access inside a building. SCPs are like corporate rules that say certain rooms cannot be used for certain activities, even by managers.

## Access Decision Simplified

```text
Can the principal perform the action?

1. Is the user or role authenticated?
2. Is the user in the correct account?
3. Does IAM allow the action?
4. Is there an explicit deny?
5. Does the SCP allow the action to be available?
6. Are there resource policies or permission boundaries involved?
7. Is the request allowed?
```

## IAM Identity Center

IAM Identity Center supports centralized user access.

Instead of this:

```text
Create IAM user in account 1
Create IAM user in account 2
Create IAM user in account 3
```

Use this:

```text
Central identity provider
  -> Group assignment
  -> Permission set
  -> AWS account access
```

Real-world example:

A developer belongs to the `AppDevelopers` group.

They may receive:

- Developer access in `shipment-dev`
- Power user access in `shipment-test`
- Read-only access in `shipment-prod`
- No access to `log-archive`
- No access to `security-tooling`

## Production Access

Production access should usually be:

- Limited
- Approved
- Audited
- Time-bound when possible
- Role-based
- Routed through pipelines where possible

Common misconception:

> “If I am supporting the app, I need admin access to prod.”

Correction:

> Support often starts with read-only access, logs, dashboards, runbooks, and controlled break-glass procedures. Admin access should not be the default.

## SCP Example in Plain English

```text
Deny disabling CloudTrail in all accounts.
```

Why?

Because audit logs are needed for security investigations.

```text
Deny creation of resources outside approved regions.
```

Why?

Because data residency, cost, and support models may depend on approved regions.

```text
Deny public S3 bucket access unless exception is approved.
```

Why?

Because public data exposure is a common cloud security risk.

## Beyond SCPs: RCPs and Declarative Policies (2026)

SCPs are powerful but they have one blind spot: they only constrain **principals inside your organization**. They do nothing about an *external* principal acting on your resources, and they are not the right tool for setting a baseline *resource* configuration.

- **Resource Control Policies (RCPs)** — GA since late 2024. RCPs are organization policies that set the *maximum permissions on resources*, evaluated against **any** principal (including external accounts and anonymous callers). The classic use is a data-perimeter rule: "no S3 bucket or KMS key in this org may be accessed by a principal outside our org." That is something SCPs structurally cannot do, because SCPs only filter *your* identities. Like SCPs, RCPs are deny-by-effect guardrails enabled as a policy type in Organizations and attached to the root/OU/account.

  Plain-English RCP example: *Deny any S3 or KMS access where the calling principal is not part of our organization (`aws:PrincipalOrgID`), except for known AWS service principals.*

- **Declarative policies** — an Organizations feature that *enforces a desired configuration for a service account-wide and keeps it that way*, even for future resources and even if the underlying API adds new options. Example: a declarative policy that enforces EBS encryption-by-default or that blocks public AMIs across every account in an OU. Unlike a detective rule that alerts after the fact, a declarative policy makes the secure setting the permanent default.

Talking point:

> Senior framing in 2026: SCPs constrain *your people*, RCPs constrain *access to your resources from anyone*, and declarative policies constrain *the configuration of services*. A mature landing zone uses all three.

## Delegated Administration (SRA principle)

The management account should run **no workloads** and host **as few security tools as possible**. Instead, you *delegate administration* of org-wide security services to the dedicated security/audit account:

```bash
# Run from the management account: make the security account the
# delegated admin for org-wide GuardDuty (same pattern for Config,
# Security Hub, IAM Access Analyzer, Macie, Detective, etc.)
aws guardduty enable-organization-admin-account \
  --admin-account-id 222222222222
```

Why it matters:

- Keeps the blast radius of the management account tiny.
- Lets the security team operate GuardDuty/Config/Security Hub org-wide without anyone logging into the management account day to day.
- Is exactly what the AWS Security Reference Architecture (SRA) recommends, and a common senior interview probe ("where does GuardDuty admin live?").

## Automated Remediation: Detective Controls Should Not Stop at "Alert"

A detective control that only alerts depends on a human seeing the alert in time. Senior teams *auto-fix* the well-understood cases. The common pattern:

```text
AWS Config rule (e.g. s3-bucket-public-read-prohibited) detects drift
        │
        ▼
Config remediation action (SSM Automation document)  OR
EventBridge rule on the finding  ->  Lambda / SSM Automation
        │
        ▼
Resource is automatically brought back into compliance
(e.g. re-enable Block Public Access) and the action is logged
```

- **Config + SSM remediation** is the lowest-code path: attach an SSM Automation runbook (e.g. `AWS-DisableS3BucketPublicReadWrite` or `AWS-EnableS3BucketEncryption`) directly to a Config rule, optionally auto-execute.
- **EventBridge + Lambda** is the flexible path for custom logic (notify, tag, quarantine, or remediate).
- Always log the remediation and keep a human-review loop for anything destructive. Auto-remediation that fights an intentional change creates its own incident.

Teaching note: this complements W19 (DevSecOps) — there you scan IaC *before* deploy; here you remediate drift *after* deploy. Defense in depth, not duplication.

## Multi-Account Networking (Re-Homed Here)

Account separation creates a new problem: workloads now live in many VPCs across many accounts, and they still need to talk to each other, to shared services, and to the internet — safely and without per-account sprawl. This is the networking foundation of the landing zone, and it lives here because the converged track has no separate enterprise-networking week.

### Transit Gateway (the hub)

A per-pair VPC-peering mesh does not scale (N-squared peerings, no transitive routing). **AWS Transit Gateway (TGW)** is a regional hub-and-spoke router: each VPC attaches once to the TGW, and TGW route tables decide which spokes can reach which. The TGW is created and owned in the **network account**.

```text
            ┌──────────────────────────┐
            │     Network Account      │
            │   ┌──────────────────┐   │
            │   │  Transit Gateway │   │
            │   └──────────────────┘   │
            └───▲────────▲────────▲────┘
                │        │        │   (VPC attachments)
        ┌───────┘        │        └────────┐
   dev VPC          prod VPC           shared-svcs VPC
 (workload acct)  (workload acct)    (shared-services acct)
```

- **TGW route tables** let you isolate spokes: e.g. a "prod" route table that cannot reach "dev," or a route table that forces all egress through the inspection VPC. This is how you enforce "dev cannot route to prod" at the network layer, complementing the account/SCP boundary.

### Centralized egress

Instead of a NAT gateway in every workload account (expensive, and each one is a separate egress point to govern), route outbound internet traffic from all spokes through a **shared egress/inspection VPC** in the network account. Outbound traffic hits a central NAT gateway and, optionally, **AWS Network Firewall** for inspection and domain filtering.

- Cost note: NAT gateways bill per hour **and per GB processed**. Centralizing reduces the number of NAT gateways but concentrates data-processing charges; for very chatty/high-volume workloads, measure before assuming central egress is cheaper. This ties directly into Week 18 (Cost Optimization).
- Security note: a single inspection point makes egress filtering and logging far easier to govern.

### Sharing the network: AWS RAM and shared VPC

Workload accounts do not own the TGW — it is shared into them with **AWS Resource Access Manager (RAM)**:

```bash
# In the network account: share the Transit Gateway with the whole org
# (sharing within your org needs RAM org-sharing enabled once)
aws ram create-resource-share \
  --name "tgw-shared" \
  --resource-arns "arn:aws:ec2:us-east-1:222222222222:transit-gateway/tgw-0abc123" \
  --principals "arn:aws:organizations::123456789012:organization/o-exampleorgid"
```

Two common designs:

- **TGW-per-VPC (most common):** every account keeps its own VPC and attaches to the shared TGW. Strong account isolation; more route-table management.
- **Shared VPC (VPC sharing via RAM):** the network account owns one VPC and shares *subnets* into workload accounts, so workloads from several accounts run in the same VPC. Fewer VPCs and simpler routing, but weaker network isolation between those accounts — choose deliberately.

Governance tie-in: routing changes are high-blast-radius, so the network account is owned by the platform/network team, app teams get read-only on networking, and an SCP can deny `ec2:DeleteTransitGateway*` / route-table changes outside that team.

## Break-Glass Access (a Real Design, Not Just a Name)

"BreakGlassAdmin" is a permission-set *name* in many decks, but a senior must be able to *design the mechanism*. Break-glass is the emergency path you use when normal SSO/federation is broken or an incident needs an action your guardrails block. Design it deliberately:

- **Dedicated identities, not your daily ones.** A small number (often two) of break-glass principals — either dedicated IAM users in the management/security account or a dedicated Identity Center permission set assigned to a tiny "break-glass" group. They are used *only* during a declared incident.
- **Hardware MFA required**, credentials stored offline (sealed/secrets vault), so using them is a deliberate act.
- **Time-bound / least-standing-privilege.** Prefer assuming a role with a short session (e.g. `PT1H`) rather than long-lived admin. The role exists but is normally assumable by no one.
- **Loud by design.** Every break-glass use must fire an alarm. Wire a CloudTrail → CloudWatch/EventBridge alert on the break-glass principal's `AssumeRole`/console sign-in that pages the security team and the platform lead immediately.
- **Expiry and post-use review.** After use: rotate the credentials, write an incident note, and review *why* a guardrail had to be bypassed (often it reveals a missing safe pattern).

Plain-English CloudTrail alarm intent:

```text
WHEN a sign-in or AssumeRole event uses the break-glass principal
THEN page Security + Platform on-call, and open a review ticket automatically.
```

> Interview-grade summary: break-glass is "rarely used, hard to use by accident, impossible to use quietly, and always reviewed after."

## SCP Safe Rollout and Testing (Don't Lock Out the Org)

The real operational risk with SCPs is not writing a wrong policy — it is *attaching* one broadly and locking everyone out (including yourself). A bad `Deny "*"` at the root has taken down whole organizations. Roll out safely:

1. **Render and review first.** Treat the SCP like Terraform: review the JSON in a PR, run it through `aws accessanalyzer validate-policy` (and/or `check-access-not-granted`) for syntax and logic errors before it ever attaches. Policy-as-code testing (OPA/Conftest, or AWS Access Analyzer checks) belongs here and connects to W19.
2. **Never test in the root or management account first.** Create a **dedicated sandbox OU** with a throwaway account and attach the new SCP *there* only.
3. **Attempt the denied action and the allowed actions.** Confirm the deny fires for what you intended and — critically — that you did **not** accidentally block normal work. Read the `AccessDenied` reason.
4. **Check what is effective.** Use `aws organizations list-policies-for-target` (and, where available, the describe-effective-policy APIs for tag/backup/AI-services policies) to confirm exactly what applies.
5. **Expand gradually.** Move from sandbox OU → non-prod OU → prod OU, watching CloudTrail for unexpected denies at each step.
6. **Always keep an exemption for break-glass and automation.** Many orgs add a condition that exempts the Control Tower execution role or a break-glass role so the guardrail cannot brick the recovery path.

> Render/plan-before-apply discipline applies to org policy exactly as it does to infrastructure: never attach an SCP you have not evaluated and staged.

| Misconception | Correction |
|---|---|
| SCPs grant permissions | SCPs only set boundaries |
| AdministratorAccess bypasses SCPs | SCP explicit deny still wins |
| Every access denied error should be fixed by adding permissions | Some access denied errors are intentional guardrails |
| Developers need permanent prod admin | Production access should be limited and audited |
| Governance only matters in production | Governance also matters in dev, test, and shared accounts |
| Cloud platform teams should disable guardrails to move faster | Better solution is to design safe patterns |

---

# 12. Whiteboard Explanation

## Class 1 Diagram: Account Structure

Start with the Class 1 design:

```text
AWS Organization
│
├── Security OU
│   ├── Log Archive Account
│   └── Security Tooling Account
│
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
│
├── NonProduction OU
│   ├── App Dev Account
│   └── App Test Account
│
└── Production OU
    └── App Prod Account
```

## Class 2 Extension: Governance Layer

Add governance controls:

```text
AWS Organization
│
├── Security OU
│   ├── Log Archive Account
│   └── Security Tooling Account
│   Controls:
│   - Protect audit logs
│   - Restrict delete permissions
│   - Security team access only
│
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
│   Controls:
│   - Limit routing changes
│   - Restrict shared DNS updates
│   - Platform/network team access
│
├── NonProduction OU
│   ├── App Dev Account
│   └── App Test Account
│   Controls:
│   - More flexible developer access
│   - Cost limits
│   - Approved regions
│
└── Production OU
    └── App Prod Account
    Controls:
    - No public S3
    - No disabling CloudTrail
    - Restricted admin access
    - Approved deployment roles only
```

## IAM vs SCP Visual

```text
Engineer or Pipeline
        │
        ▼
IAM Identity Center or IAM Role
        │
        ▼
Permission Set / IAM Policy
        │
        ▼
AWS Account
        │
        ▼
SCP Boundary from OU
        │
        ▼
Final Decision:
Allowed or Denied
```

## Access Decision Flow

```text
Request: Create public S3 bucket
        │
        ▼
Does IAM allow it?
        │
        ├── No  -> Denied by IAM
        │
        └── Yes
             │
             ▼
Does SCP block it?
        │
        ├── Yes -> Denied by SCP
        │
        └── No
             │
             ▼
Allowed, unless another deny applies
```

## Real-World Enterprise Version

```text
Developer Group
│
├── Dev Account
│   └── DeveloperAccess permission set
│
├── Test Account
│   └── PowerUserNonProd permission set
│
└── Prod Account
    └── ReadOnly or DeploymentRole only

Production OU SCPs:
- Deny public S3
- Deny disabling CloudTrail
- Deny unsupported regions
- Deny deleting backup vaults
```

## Multi-Account Networking Layer

The same account boundaries also need to be connected. Draw the hub-and-spoke:

```text
                 ┌───────────────────────────────────┐
                 │          Network Account          │
                 │  ┌─────────────┐  ┌─────────────┐ │
   internet  ◄───┼──┤ Egress VPC  │  │   Transit   │ │
                 │  │ NAT + NFW   │──┤   Gateway   │ │
                 │  └─────────────┘  └──────┬──────┘ │
                 └──────────────────────────┼────────┘
                       shared via AWS RAM    │
            ┌──────────────────┬─────────────┴─────────────┐
            ▼                  ▼                            ▼
     dev VPC (acct)     prod VPC (acct)         shared-services VPC (acct)
   TGW route table:   TGW route table:          (DNS, CI/CD, artifacts)
   can reach shared,  isolated from dev,
   not prod           egress via Network acct
```

Step by step:

1. The **network account** owns the Transit Gateway and the egress/inspection VPC.
2. The TGW is **shared into workload accounts with AWS RAM**; each workload VPC attaches once.
3. **TGW route tables** enforce isolation — e.g. prod cannot route to dev — layering network isolation on top of the account/SCP boundary.
4. **Centralized egress**: spokes route `0.0.0.0/0` to the TGW, which sends it through the shared NAT/Network Firewall, so there is one governed, inspected exit to the internet.
5. Governance applies: only the platform/network team modifies routing; an SCP can deny TGW/route changes elsewhere.

Teaching point:

> Class 1 created the rooms. Class 2 defines who can enter each room, what they are allowed to do there, and how the rooms are wired together.

---

# 13. Instructor Demo Script

## Demo Title

**IAM vs SCP: Why AdministratorAccess May Still Be Denied**

## Demo Objective

Show students how enterprise governance can block risky cloud actions even when an IAM role appears to have broad permissions.

## Required Setup

Use one of the following:

Option 1: Live sandbox AWS Organization with read-only Organizations access  
Option 2: Screenshots and sample policy files  
Option 3: Local files and simulated CLI outputs

Recommended for most classrooms:

- Use simulated policy files and sample outputs
- Avoid modifying real SCPs during class
- Do not create public S3 buckets

## Demo Folder Setup

```bash
mkdir -p week-17-class-2-demo/policies
cd week-17-class-2-demo
```

Expected output:

```text
No output if successful.
```

## Step 1: Validate Current AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AROAXAMPLEID:instructor-session",
  "Account": "111111111111",
  "Arn": "arn:aws:sts::111111111111:assumed-role/ReadOnlyRole/instructor-session"
}
```

Explain:

> Before troubleshooting access, always confirm account and role context.

## Step 2: Show a Permissive IAM Policy

Create sample file:

```bash
cat > policies/iam-admin-example.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AdminAccessExample",
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
```

Explain:

> This looks like full access inside the account, but it still does not bypass organization-level restrictions.

## Step 3: Show an SCP That Prevents Public S3 Exposure

> **Critical correctness point — teach this explicitly.** A very common mistake (and a real footgun) is to deny `s3:PutBucketPublicAccessBlock`. That action is what *turns Block Public Access ON*. Denying it does the opposite of what you want: it stops teams from *enforcing* the protection. The correct guardrail denies the actions that *remove* the protection and denies *making data public*, while the enforcement action stays allowed.

The right pattern has two parts: (1) never let anyone weaken account/bucket Block Public Access, and (2) deny ACL changes that grant public or over-broad access (`authenticated-read` grants read to *any* authenticated AWS principal across all accounts, so it is over-broad even though it is not strictly anonymous/public):

```bash
cat > policies/scp-deny-public-s3-example.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyWeakeningBlockPublicAccess",
      "Effect": "Deny",
      "Action": [
        "s3:DeleteAccountPublicAccessBlock",
        "s3:DeleteBucketPublicAccessBlock"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyPublicBucketAcl",
      "Effect": "Deny",
      "Action": "s3:PutBucketAcl",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": ["public-read", "public-read-write", "authenticated-read"]
        }
      }
    }
  ]
}
EOF
```

Explain, step by step:

- `DeleteAccountPublicAccessBlock` / `DeleteBucketPublicAccessBlock` are denied outright — nobody may *remove* the Block Public Access protection.
- `Put...PublicAccessBlock` is left *allowed* so teams can turn protection ON (and keep it on). We deliberately do **not** deny it — denying it was the original backwards bug, because that action is exactly how you *enforce* the protection.
- The ACL statement blocks setting a bucket ACL to a public or over-broad canned ACL.

> **Why there is no value-based condition on `Put...PublicAccessBlock`.** A tempting "fix" is to allow `Put...PublicAccessBlock` but deny it *only when the new configuration would be all-false*. There is no supported S3 condition key for that — AWS does **not** provide an `s3:PublicAccessBlockConfiguration` (or similar) condition key for `s3:PutAccountPublicAccessBlock` / `s3:PutBucketPublicAccessBlock`, so a `Condition` referencing one would never match and the `Deny` would silently never fire (a no-op). The robust patterns are: (a) deny only the `Delete*PublicAccessBlock` actions (as above), so the protection cannot be torn down; and/or (b) if you must lock down `Put*PublicAccessBlock` too, deny it for everyone *except* an approved admin/automation role using `aws:PrincipalArn`, rather than trying to condition on the config value. Do **not** rely on a value-based condition that does not exist.

> Teaching note: with account-level Block Public Access on (the modern default since S3 changed defaults), a single public bucket policy can no longer take effect anyway. The SCP is defense-in-depth so the *protection itself* cannot be turned off across the org. In a real environment, SCPs must be carefully designed and tested — Section 14 now includes a safe-rollout procedure.

## Step 4: Show the Final Access Decision

Use this text output:

```text
IAM Policy:
Allows s3:PutBucketPolicy

SCP:
Denies s3:PutBucketPolicy

Final Result:
Denied
```

Explain:

> Explicit deny wins. This is why adding more IAM permissions does not fix every access issue.

## Step 5: Show a Common AccessDenied Message

```text
An error occurred (AccessDenied) when calling the PutBucketPolicy operation:
User is not authorized to perform this action because an explicit deny exists in a service control policy.
```

Explain:

> This message is a clue. It tells you the issue is not simply missing IAM permission. The organization policy is blocking the action.

## Step 6: Show CLI Troubleshooting Checklist

Create a troubleshooting note:

```bash
cat > access-troubleshooting-checklist.md <<'EOF'
# AWS Access Troubleshooting Checklist

1. Confirm current identity:
   aws sts get-caller-identity

2. Confirm expected account ID.

3. Confirm expected role or permission set.

4. Check whether IAM allows the action.

5. Check whether an SCP blocks the action.

6. Check whether permission boundaries apply.

7. Check whether resource policy applies.

8. Decide whether the action should be allowed or redesigned.
EOF
```

## Step 7: Optional Organizations CLI Demo

Only if instructor has permissions:

```bash
aws organizations list-policies --filter SERVICE_CONTROL_POLICY
```

Expected output example:

```json
{
  "Policies": [
    {
      "Id": "p-example123",
      "Name": "DenyPublicS3",
      "Description": "Prevents public S3 configurations",
      "Type": "SERVICE_CONTROL_POLICY",
      "AwsManaged": false
    }
  ]
}
```

Explain:

> This shows available SCPs, not necessarily which account they are attached to.

Optional:

```bash
aws organizations list-policies-for-target \
  --target-id ou-exampleid \
  --filter SERVICE_CONTROL_POLICY
```

## Step 8: Show Auto-Remediation (Detective → Self-Healing)

Make the point that detective controls should not stop at "alert." Show the Config rule + SSM remediation pattern conceptually, then the EventBridge rule that catches an S3 public-access finding and triggers an SSM Automation runbook:

```bash
cat > policies/eventbridge-s3-public-remediation.json <<'EOF'
{
  "source": ["aws.config"],
  "detail-type": ["Config Rules Compliance Change"],
  "detail": {
    "messageType": ["ComplianceChangeNotification"],
    "configRuleName": ["s3-bucket-public-read-prohibited"],
    "newEvaluationResult": { "complianceType": ["NON_COMPLIANT"] }
  }
}
EOF
```

Explain:

> A Config rule detects the non-compliant bucket; this EventBridge rule pattern matches the finding and (as the target) invokes an SSM Automation document such as `AWS-DisableS3BucketPublicReadWrite`. The drift is fixed automatically and the action is logged. Always keep a human-review loop for anything destructive.

## Step 9: Show the Break-Glass Alarm Intent

Show why every break-glass use must be loud. Conceptually, a CloudTrail event for the break-glass principal feeds an EventBridge/CloudWatch alarm that pages on-call:

```bash
cat > policies/breakglass-cloudtrail-alarm.json <<'EOF'
{
  "source": ["aws.signin", "aws.sts"],
  "detail-type": ["AWS Console Sign In via CloudTrail", "AWS API Call via CloudTrail"],
  "detail": {
    "userIdentity": {
      "arn": ["arn:aws:iam::111111111111:role/BreakGlassAdmin"]
    }
  }
}
EOF
```

Explain:

> Break-glass is impossible to use quietly: any sign-in or AssumeRole with the break-glass principal pages Security and Platform on-call and opens a review ticket. After use, rotate credentials and review why a guardrail had to be bypassed.

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `AccessDeniedException` for Organizations commands | Instructor does not have management account permissions | Use sample outputs |
| Students think SCP grants permissions | Repeat that SCPs only limit maximum permissions |
| Students focus only on JSON syntax | Bring discussion back to risk and governance |
| Live environment differs from example | Use diagrams and sample files |
| Students ask how to bypass SCPs | Reframe as exception process and safer design |

## Cleanup Steps

If local demo files were created:

```bash
cd ..
rm -rf week-17-class-2-demo
```

No AWS cleanup is required if the demo is read-only or simulated.

---

# 14. Student Lab Manual

## Lab Title

**Add Governance, Guardrails, and Access Controls to Your AWS Landing Zone**

## Lab Objective

Extend the Class 1 landing zone design by adding governance controls, access models, and troubleshooting documentation.

## Estimated Time

45 to 60 minutes

## Student Prerequisites

Students should have completed or started the Class 1 landing zone design.

## Starting Point From Class 1

Students should have:

```text
week-17-landing-zone/
├── deliverables/
│   ├── account-inventory.md
│   ├── ou-design.md
│   ├── naming-convention.md
│   ├── access-model.md
│   └── multicloud-comparison.md
```

## Architecture or Workflow Overview

Students will add a governance layer to their landing zone:

```text
Account Design
    +
Access Model
    +
Guardrails
    +
SCP Examples
    +
Troubleshooting Flow
    =
Governed Landing Zone Proposal
```

## Step-by-Step Student Instructions

### Step 1: Open Your Class 1 Folder

```bash
cd week-17-landing-zone
```

Validate:

```bash
ls deliverables
```

Expected output:

```text
account-inventory.md
ou-design.md
naming-convention.md
access-model.md
multicloud-comparison.md
```

If your filenames are different, continue with your own names.

### Step 2: Create a Governance Model File

```bash
cat > deliverables/governance-model.md <<'EOF'
# AWS Landing Zone Governance Model

## Governance Goals

1. Protect production workloads.
2. Protect audit and security logs.
3. Enforce least privilege access.
4. Reduce accidental public exposure.
5. Support cost visibility and ownership.
6. Support future application onboarding.

## Governance Table

| Area | Control | Applies To | Control Type | Owner Team | Reason |
|---|---|---|---|---|---|
| Audit logging | Prevent disabling CloudTrail | All accounts | Preventive | Security | Protect audit trail |
| S3 public access | Block public bucket exposure | All workload accounts | Preventive | Security / Cloud Platform | Reduce data exposure risk |
| Approved regions | Restrict resource creation to approved regions | All accounts | Preventive | Cloud Platform | Control compliance and cost |
| Required tags | Detect missing owner and environment tags | All accounts | Detective | Cloud Platform / Finance | Improve accountability |
| Production access | Limit admin access in prod | Production OU | Preventive | Cloud Platform | Reduce production risk |
EOF
```

### Step 3: Create a Guardrails File

```bash
cat > deliverables/guardrails.md <<'EOF'
# Recommended Landing Zone Guardrails

| Guardrail | Preventive or Detective | Applies To | Why It Matters |
|---|---|---|---|
| Deny disabling CloudTrail | Preventive | All accounts | Protects audit evidence |
| Deny deleting log buckets | Preventive | Log archive account | Protects investigation history |
| Deny public S3 bucket policies | Preventive | All workload accounts | Reduces data exposure |
| Detect unencrypted storage | Detective | All workload accounts | Supports security and compliance |
| Detect missing required tags | Detective | All accounts | Improves cost ownership |
| Restrict production admin access | Preventive | Production accounts | Reduces production risk |
| Alert on root account usage | Detective | All accounts | Detects risky access |
EOF
```

### Step 4: Create Plain-English SCP Examples

```bash
cat > deliverables/scp-examples.md <<'EOF'
# Plain-English SCP Examples

## SCP 1: Protect Audit Logging

Deny stopping, deleting, or modifying CloudTrail in all AWS accounts.

Business reason:
Audit logs are required for security investigation and compliance.

## SCP 2: Restrict Approved Regions

Deny resource creation outside approved AWS regions.

Business reason:
The company wants to control cost, supportability, and data residency.

## SCP 3: Protect Production From Risky Actions

Deny deleting production backup vaults, disabling encryption, or making storage public.

Business reason:
Production systems require stricter protection than development systems.

## SCP 4: Prevent Public S3 Exposure

Deny public bucket policies or public ACL changes unless approved through an exception process.

Business reason:
Public data exposure is a major security risk.
EOF
```

### Step 5: Create a Sample SCP JSON File

This is a simplified teaching example.

```bash
mkdir -p policies
cat > policies/deny-cloudtrail-changes.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyCloudTrailStopDeleteUpdate",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```

Validate JSON formatting if `python` is available:

```bash
python -m json.tool policies/deny-cloudtrail-changes.json
```

Expected output:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyCloudTrailStopDeleteUpdate",
            "Effect": "Deny",
            "Action": [
                "cloudtrail:StopLogging",
                "cloudtrail:DeleteTrail",
                "cloudtrail:UpdateTrail"
            ],
            "Resource": "*"
        }
    ]
}
```

### Step 6: Create an Access Model by Team

```bash
cat > deliverables/access-model-class-2.md <<'EOF'
# Landing Zone Access Model

| Team | Account Access | Permission Type | Notes |
|---|---|---|---|
| Cloud Platform | Shared services, network, workload accounts | Admin or elevated operations | Responsible for infrastructure standards |
| Security | Security tooling, log archive, read-only across workloads | Security admin / audit | Responsible for visibility and investigation |
| Network | Network account, read-only to workload networking | Network admin | Responsible for routing and connectivity |
| Developers | Dev and test workload accounts | Developer / PowerUser with limits | Should not control security or logs |
| Production Support | Prod workload account | Read-only or controlled break-glass | Troubleshooting production issues |
| Auditors | Log archive and read-only views | Read-only | Compliance evidence review |
EOF
```

### Step 7: Create an Access Troubleshooting Flow

```bash
cat > deliverables/access-troubleshooting-flow.md <<'EOF'
# AWS Access Troubleshooting Flow

## Scenario

A user or pipeline receives AccessDenied in an AWS account.

## Troubleshooting Steps

1. Confirm the current AWS identity.
   Command:
   aws sts get-caller-identity

2. Confirm the account ID is the expected account.

3. Confirm the user or role is assigned to the account.

4. Confirm the correct permission set or IAM role is being used.

5. Check whether IAM allows the requested action.

6. Check whether a permission boundary limits the action.

7. Check whether an SCP blocks the action.

8. Check whether a resource policy blocks the action.

9. Decide whether the action should be allowed or redesigned.

## Key Question

Is the access failure a mistake, or is the guardrail working as intended?
EOF
```

### Step 8: Create a Class 2 Summary

```bash
cat > deliverables/class-2-summary.md <<'EOF'
# Class 2 Summary

In Class 2, we added governance to our AWS landing zone design.

We defined:
- Guardrails
- Preventive controls
- Detective controls
- Access model by team
- Plain-English SCP examples
- Access troubleshooting flow

The most important lesson:
IAM can allow an action, but an SCP can still block it.
EOF
```

### Step 9: Hands-On — Attach, Test, and Remove a Real SCP (Sandbox)

> Run this only in a disposable **sandbox AWS Organization** you control, ideally against a throwaway **sandbox OU/account** — never a real company org or the management account. Creating/attaching SCPs is free and reversible. This is the step that turns "I read about SCPs" into "I have operated SCPs."

You will reuse the corrected public-S3 guardrail, attach it, *prove* it blocks the right thing, read the deny, then remove it — the full symptom → evidence → root-cause → fix → validate loop.

**9a. Confirm SCPs are enabled and pick a target OU.** (If you did Class 1 Step 10 the policy type is already on.)

```bash
ROOT_ID=$(aws organizations list-roots --query 'Roots[0].Id' --output text)

# Create a throwaway sandbox OU to test against (do NOT attach to root)
OU_ID=$(aws organizations create-organizational-unit \
  --parent-id "$ROOT_ID" --name "Lab-SCP-Test" \
  --query 'OrganizationalUnit.Id' --output text)
echo "Test OU: $OU_ID"
```

**9b. Use the corrected public-S3 SCP** (the same JSON from the demo — note it does NOT deny the enforcement action):

```bash
mkdir -p policies
cat > policies/scp-deny-public-s3.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyWeakeningBlockPublicAccess",
      "Effect": "Deny",
      "Action": [
        "s3:DeleteAccountPublicAccessBlock",
        "s3:DeleteBucketPublicAccessBlock"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyPublicBucketAcl",
      "Effect": "Deny",
      "Action": "s3:PutBucketAcl",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": ["public-read", "public-read-write", "authenticated-read"]
        }
      }
    }
  ]
}
EOF
```

**9c. Validate the policy BEFORE attaching (render/plan-before-apply):**

```bash
aws accessanalyzer validate-policy \
  --policy-type SERVICE_CONTROL_POLICY \
  --policy-document file://policies/scp-deny-public-s3.json
```

Expected output: an empty `findings` array (or only low-severity suggestions) means it is syntactically and logically sound.

```json
{ "findings": [] }
```

**9d. Create and attach to the test OU only:**

```bash
POLICY_ID=$(aws organizations create-policy \
  --name "lab-deny-public-s3" \
  --description "Lab: prevent weakening S3 public-access protection" \
  --type SERVICE_CONTROL_POLICY \
  --content file://policies/scp-deny-public-s3.json \
  --query 'Policy.PolicySummary.Id' --output text)

aws organizations attach-policy --policy-id "$POLICY_ID" --target-id "$OU_ID"
```

**9e. Prove it works (evidence).** From a principal in an account *inside* `Lab-SCP-Test`, attempt a denied action against a test bucket you own:

```bash
# This SHOULD fail because of the SCP, even with broad IAM permissions
aws s3api delete-bucket-public-access-block --bucket your-sandbox-test-bucket
```

Expected output (the deny — read it carefully):

```text
An error occurred (AccessDenied) when calling the DeletePublicAccessBlock operation:
User: arn:aws:sts::... is not authorized to perform: s3:DeleteBucketPublicAccessBlock
with an explicit deny in a service control policy
```

Confirm the *enforcement* action is still allowed (turning protection ON must NOT be blocked — this is the bug we fixed):

```bash
# This SHOULD succeed (or be a no-op) — enforcement is allowed
aws s3api put-public-access-block --bucket your-sandbox-test-bucket \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

**9f. Confirm what is effective:**

```bash
aws organizations list-policies-for-target \
  --target-id "$OU_ID" --filter SERVICE_CONTROL_POLICY
```

**9g. Tear down (mandatory):**

```bash
aws organizations detach-policy --policy-id "$POLICY_ID" --target-id "$OU_ID"
aws organizations delete-policy --policy-id "$POLICY_ID"
aws organizations delete-organizational-unit --organizational-unit-id "$OU_ID"
```

Validate teardown: re-run the `list-policies-for-target` from 9f *before* deleting the OU and confirm the policy is gone after detach.

### Step 10: Validate Deliverables

```bash
find deliverables policies -type f -print
```

Expected output:

```text
deliverables/account-inventory.md
deliverables/ou-design.md
deliverables/naming-convention.md
deliverables/access-model.md
deliverables/multicloud-comparison.md
deliverables/governance-model.md
deliverables/guardrails.md
deliverables/scp-examples.md
deliverables/access-model-class-2.md
deliverables/access-troubleshooting-flow.md
deliverables/class-2-summary.md
policies/deny-cloudtrail-changes.json
```

(If you completed the hands-on Step 9, you will also have `policies/scp-deny-public-s3.json`.)

### Step 11: Optional Git Commit

```bash
git add .
git commit -m "Add landing zone governance model"
```

Expected output:

```text
[main <commit-id>] Add landing zone governance model
```

## Validation Checklist

Students should verify:

- [ ] Governance model exists
- [ ] Guardrails include preventive and detective controls
- [ ] Production has stricter controls than non-production
- [ ] Log archive account is protected
- [ ] Access model separates platform, security, developer, auditor, and support access
- [ ] At least two plain-English SCP examples are included
- [ ] At least one sample SCP JSON file exists
- [ ] Troubleshooting flow includes IAM and SCP checks
- [ ] Azure and GCP comparison remains short and relevant
- [ ] (Hands-on track) The public-S3 SCP was validated with `accessanalyzer validate-policy` before attaching
- [ ] (Hands-on track) The SCP was attached to a sandbox OU, the denied action failed, and the enforcement action still succeeded
- [ ] (Hands-on track) The SCP and sandbox OU were detached/deleted and verified gone

## Troubleshooting Tips

| Issue | Fix |
|---|---|
| Student writes SCPs as if they grant access | Remind them SCPs only limit permissions |
| Student gives developers prod admin access | Ask what safer access model could support troubleshooting |
| Student blocks too many actions in dev | Explain that dev needs flexibility but still needs safety controls |
| Student forgets detective controls | Explain that not every risk must be blocked immediately |
| Student writes vague guardrails | Make them tie each guardrail to a risk |
| JSON validation fails | Check commas, brackets, and quotes |

## Cleanup Steps

The document steps create no AWS resources. If you ran the hands-on Step 9, confirm you completed teardown 9g (detach + delete the SCP, delete the sandbox OU) and verified with `list-policies-for-target`. Leaving guardrails attached to the wrong target is exactly the kind of drift this week teaches you to avoid.

Optional local cleanup:

```bash
cd ..
rm -rf week-17-landing-zone
```

## Reflection Questions

1. Which guardrails should apply to every account?
2. Which guardrails should only apply to production?
3. Why might dev accounts need more flexibility than prod accounts?
4. When should an access denied error be escalated?
5. When should an access denied error be treated as a successful control?
6. What access should developers have in production?
7. What information should be included in an access request?

## Optional Challenge Task

Add one advanced guardrail category:

- Region restriction
- Tag enforcement
- Encryption enforcement
- Backup protection
- Root account usage alerting
- Public internet exposure detection

For the chosen guardrail, document:

1. Risk
2. Control type
3. Accounts or OUs affected
4. Owner team
5. Exception process
6. Troubleshooting impact

---

# 15. Troubleshooting Activity

## Incident Title

**Deployment Role Has Admin Access but Still Cannot Create a Public S3 Bucket**

## Business Impact

A development team is blocked during environment deployment. The team says their deployment role has `AdministratorAccess`, but the pipeline fails when trying to configure a public S3 bucket for static content.

The release is delayed, and the team asks the cloud platform team to “fix the permission issue.”

## Symptoms

Pipeline output:

```text
Error: AccessDenied

Action: s3:PutBucketPolicy
Resource: arn:aws:s3:::shipment-static-assets-dev

Message:
User is not authorized to perform this action because an explicit deny exists in a service control policy.
```

Terraform-like output:

```text
Error: putting S3 Bucket Policy (shipment-static-assets-dev):
operation error S3: PutBucketPolicy,
https response error StatusCode: 403,
api error AccessDenied: Access Denied
```

Developer statement:

```text
The role has AdministratorAccess, so this must be an AWS problem or platform issue.
```

## Starting Evidence

```text
Account: shipment-dev
OU: NonProduction
Role: cicd-deployment-role
IAM policy: AdministratorAccess
Recent organization change: Public S3 bucket guardrail applied to NonProduction and Production OUs
Application requirement: Serve static files publicly
```

## Student Investigation Steps

Students should investigate:

1. What exact action failed?
2. What AWS account is the pipeline using?
3. What role is the pipeline assuming?
4. Does IAM allow the action?
5. Does the error mention explicit deny?
6. Is there an SCP attached to the OU or account?
7. Is the public bucket requirement valid?
8. Can the design use a safer alternative?
9. Should the guardrail be removed, changed, or kept?
10. Is an exception process needed?

## Expected Root Cause

The deployment role has broad IAM permissions, but an SCP attached to the OU denies public S3 bucket policy changes. The guardrail is intentionally preventing public S3 exposure.

## Correct Resolution

Recommended resolution:

1. Do not remove the guardrail just to make the pipeline pass.
2. Confirm whether public bucket access is truly required.
3. Prefer safer design:
   - Keep S3 bucket private
   - Use CloudFront
   - Use Origin Access Control
   - Use signed URLs if needed
4. Update the Terraform or deployment design.
5. Document the guardrail and application design decision.
6. If public access is absolutely required, follow exception approval process.

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Attach more IAM permissions | IAM already allows it. SCP blocks it |
| Disable SCP for the OU | Removes protection for many accounts |
| Move account to another OU | Bypasses governance and creates audit risk |
| Use root credentials | Unsafe and unacceptable |
| Make the bucket public manually | Violates policy and creates drift |
| Blame AWS service outage | Error message clearly points to access denial |

## Instructor Hints

Use these only if students are stuck:

1. “What does the error message say about explicit deny?”
2. “Does AdministratorAccess override SCPs?”
3. “Is the requested design safe?”
4. “Can static files be served without making the bucket public?”
5. “Should this be fixed by permission change or architecture change?”

## Preventive Action

- Document approved static hosting patterns
- Provide reusable Terraform module for private S3 plus CloudFront
- Add pipeline pre-checks for blocked patterns
- Publish guardrail documentation
- Create exception request process
- Train app teams on SCP behavior
- Add meaningful error guidance to platform templates

---

# 16. Scenario-Based Discussion Questions

## Question 1

**A developer has AdministratorAccess in a workload account but still receives AccessDenied. What should you check before adding more permissions?**

Expected response themes:

- Confirm account and role
- Check error message for explicit deny
- Review SCPs
- Check permission boundaries
- Check resource policies
- Determine whether the denial is intentional

Follow-up:

> What clue in the error message tells you this might be an SCP issue?

## Question 2

**Should production and non-production accounts have the same guardrails?**

Expected response themes:

- Some baseline controls should apply everywhere
- Production usually needs stricter controls
- Dev may need flexibility
- Security and logging protections should be consistent
- Cost controls may differ

Follow-up:

> Which guardrail would you apply to every account, including sandbox?

## Question 3

**When is it better to use a detective control instead of a preventive control?**

Expected response themes:

- When blocking would slow development too much
- When the risk is lower
- When teams need flexibility
- When visibility is enough initially
- When introducing governance gradually

Follow-up:

> Give an example of a control you would detect first and block later.

## Question 4

**A team wants public S3 access for static files. Should the platform team approve it?**

Expected response themes:

- Understand requirement first
- Prefer private S3 plus CloudFront
- Avoid public buckets by default
- Use exception process if needed
- Consider security and audit impact

Follow-up:

> What safer architecture could meet the same business need?

## Question 5

**How can governance improve developer speed instead of slowing it down?**

Expected response themes:

- Clear rules reduce confusion
- Reusable templates reduce rework
- Approved patterns speed delivery
- Guardrails prevent late security rejection
- Self-service with boundaries helps teams move faster

Follow-up:

> What documentation would help developers avoid blocked deployments?

## Question 6

**Who should approve production break-glass access?**

Expected response themes:

- Cloud platform lead
- Security or incident commander
- App owner
- Manager approval depending on severity
- Access should be logged and reviewed

Follow-up:

> How should break-glass access differ during a Sev 1 incident?

## Question 7

**How do Class 1 account boundaries and Class 2 governance controls work together?**

Expected response themes:

- Accounts isolate environments
- OUs group accounts
- SCPs apply rules at OU or account level
- Identity Center controls who can access accounts
- Governance makes account design enforceable

Follow-up:

> What happens if you have account separation but no guardrails?

## Question 8

**What is the risk of letting each application team create its own cloud governance rules?**

Expected response themes:

- Inconsistent security
- Audit gaps
- Increased operational complexity
- Harder incident response
- Uneven cost controls
- Duplicate patterns

Follow-up:

> Which controls should be centralized by the cloud platform team?

## Question 9

**A partner needs cross-account access to one of your S3 buckets, but security requires that no other external principal can ever reach your data. SCP alone, RCP, or both?**

Expected response themes:

- SCPs only constrain your own principals, so they cannot stop external access
- An RCP enforces an org-wide data perimeter on the resource
- Combine: RCP for the perimeter, a narrow resource policy or scoped grant for the partner
- `aws:PrincipalOrgID` as the common condition key

Follow-up:

> What does an RCP protect against that an SCP structurally cannot?

## Question 10

**Where should multi-account networking live, and who should be allowed to change routing?**

Expected response themes:

- Transit Gateway and centralized egress owned in the network account
- TGW shared into workload accounts with RAM
- TGW route tables isolate prod from dev at the network layer
- Only platform/network team modifies routing; SCP can deny TGW/route changes elsewhere
- Cost tradeoff of centralized vs per-account NAT

Follow-up:

> How does network isolation via TGW route tables complement the account/SCP boundary?

---

# 17. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What is the purpose of a Service Control Policy?

A. To grant IAM permissions to users  
B. To create EC2 instances automatically  
C. To define the maximum available permissions for accounts in an organization  
D. To replace CloudTrail logging  

**Answer:** C  
**Explanation:** SCPs set permission boundaries at the AWS Organization, OU, or account level. They do not grant permissions.

## Question 2: True or False

If a user has AdministratorAccess in an AWS account, an SCP can still block their action.

**Answer:** True  
**Explanation:** SCPs can restrict actions even when IAM allows them.

## Question 3: Short Answer

What is the difference between IAM and SCP?

**Answer:** IAM grants or denies permissions inside an AWS account. SCPs define the maximum permissions available to an account or OU.  
**Explanation:** IAM is identity-level access. SCP is organization-level governance.

## Question 4: Multiple Choice

A developer cannot see the production account in the AWS access portal. What is the most likely issue?

A. EC2 is down  
B. The user lacks an IAM Identity Center account assignment or permission set  
C. S3 is unavailable  
D. The VPC route table is missing  

**Answer:** B  
**Explanation:** If the account is not visible in the access portal, the issue is usually assignment or permission set related.

## Question 5: Multiple Choice

Which is an example of a preventive guardrail?

A. Alert when a bucket becomes public  
B. Report untagged resources monthly  
C. Deny disabling CloudTrail  
D. Send cost report every Friday  

**Answer:** C  
**Explanation:** A preventive guardrail blocks an unsafe action before it happens.

## Question 6: True or False

A detective control blocks an action before it happens.

**Answer:** False  
**Explanation:** A detective control identifies or alerts on a condition after it occurs.

## Question 7: Troubleshooting Question

A pipeline role has AdministratorAccess but fails with:  
`explicit deny exists in a service control policy`.  
Should you fix this by adding more IAM permissions?

**Answer:** No.  
**Explanation:** IAM permissions will not override an SCP explicit deny. You must review the SCP and determine whether the action should be allowed or redesigned.

## Question 8: Troubleshooting Question

A user runs `aws sts get-caller-identity` and sees the dev account ID, but they expected prod. What should they do?

**Answer:** Switch to the correct AWS profile, role, or account assignment and validate identity again.  
**Explanation:** Many access issues are caused by using the wrong account or role context.

## Question 9: Class 1 and Class 2 Connection

How does an OU design from Class 1 affect SCP behavior in Class 2?

**Answer:** SCPs can be attached to OUs, so accounts inside that OU inherit those controls.  
**Explanation:** Account placement matters because governance may be inherited from the OU.

## Question 10: Class 1 and Class 2 Connection

Why is separating production into its own OU useful for governance?

**Answer:** It allows stricter controls to be applied to production accounts without applying the same restrictions to development accounts.  
**Explanation:** Production usually requires stronger change, access, and security controls.

## Question 11: Multiple Choice

Which team should usually have primary control over the log archive account?

A. Every developer  
B. Security or audit team  
C. External users  
D. No one  

**Answer:** B  
**Explanation:** Logs should be protected and controlled by security or audit-aligned teams.

## Question 12: Short Answer

Give one example of a safer alternative to public S3 bucket access.

**Answer:** Use private S3 with CloudFront and Origin Access Control.  
**Explanation:** This allows content delivery without exposing the bucket directly to the public internet.

## Question 13: Multiple Choice

You want to prevent an SCP from accidentally blocking the *enforcement* of S3 Block Public Access. Which action must you NOT deny?

A. `s3:DeleteBucketPublicAccessBlock`  
B. `s3:PutBucketPublicAccessBlock` (when setting the config to true)  
C. `s3:PutBucketAcl` with a public canned ACL  
D. `s3:DeleteAccountPublicAccessBlock`  

**Answer:** B  
**Explanation:** `PutBucketPublicAccessBlock` is what turns the protection ON. Denying it outright (a common bug) blocks teams from *enforcing* Block Public Access. Deny the *delete* actions and public ACLs instead.

## Question 14: Short Answer

You must prevent any principal *outside your AWS organization* from reading your S3 buckets. Which Organizations policy type is the right tool, and why can't an SCP do it?

**Answer:** A Resource Control Policy (RCP). SCPs only constrain principals inside your organization, so they cannot restrict external or anonymous principals acting on your resources; RCPs cap permissions on the resources themselves against any principal.  
**Explanation:** RCPs (GA since late 2024) are the data-perimeter tool; SCPs are the identity-perimeter tool.

## Question 15: Short Answer

In a multi-account network, why is a Transit Gateway preferred over full-mesh VPC peering, and how is it made available to workload accounts?

**Answer:** TGW is a hub that provides transitive routing and scales without N-squared peerings, with route tables to isolate spokes; it is owned in the network account and shared into workload accounts using AWS RAM.  
**Explanation:** This is the standard scalable multi-account connectivity pattern.

## Question 16: True or False

A safe way to test a new SCP is to attach it to the organization root first so it covers everything at once.

**Answer:** False  
**Explanation:** Attaching to the root can lock out the whole org. Validate the policy first, then stage it on a dedicated sandbox OU before expanding to non-prod and prod.

---

# 18. Homework Assignment

## Assignment Title

**Governance and Guardrail Plan for an Enterprise AWS Landing Zone**

## Scenario

Your company is onboarding a new customer-facing application into the AWS landing zone you designed in Class 1. Security, finance, and platform teams have asked you to define governance rules before the application team starts deploying workloads.

## Student Tasks

Students must create a governance proposal that includes:

1. Updated AWS Organization and OU diagram
2. Account placement by OU
3. Access model by team
4. Permission set recommendations
5. At least five guardrails
6. Preventive vs detective classification for each guardrail
7. At least two plain-English SCP examples
8. One sample SCP JSON file
9. Access troubleshooting flowchart
10. Azure and GCP governance comparison
11. Short explanation of how Class 1 account structure supports Class 2 governance
12. One RCP or declarative-policy example (plain English) with the risk it addresses that an SCP cannot
13. A multi-account networking diagram (network account + TGW + centralized egress + RAM sharing)
14. A break-glass access design (dedicated identity, MFA, time-bound, CloudTrail alarm, expiry, post-use review)
15. An SCP safe-rollout plan (validate → sandbox OU → non-prod → prod, with break-glass/automation exemption)

## Expected Deliverables

```text
landing-zone-governance-proposal/
├── account-inventory.md
├── ou-design.md
├── governance-model.md
├── guardrails.md
├── access-model.md
├── scp-examples.md
├── policies/
│   └── sample-scp.json
├── rcp-and-declarative-policy.md
├── networking-design.md
├── break-glass-design.md
├── scp-rollout-plan.md
├── access-troubleshooting-flow.md
├── multicloud-comparison.md
└── summary.md
```

## Submission Format

Accepted formats:

- Git repository link
- Zip file
- Markdown folder
- PDF export with diagrams

## Estimated Completion Time

3 to 5 hours

## Grading Criteria

| Criteria | Points |
|---|---:|
| Clear governance model tied to Class 1 account structure | 15 |
| Practical access model by team | 10 |
| Strong guardrail selection with preventive/detective classification | 15 |
| Correct explanation of IAM vs SCP (and where RCP/declarative policy fit) | 15 |
| Break-glass design (dedicated identity, MFA, time-bound, alarm, expiry, review) | 10 |
| SCP safe-rollout plan (validate → sandbox OU → expand, with exemptions) | 10 |
| Multi-account networking design (TGW, centralized egress, RAM) | 10 |
| Useful troubleshooting flow | 5 |
| Azure/GCP comparison included without distracting from AWS | 3 |
| Professional documentation and diagram quality | 7 |
| Total | 100 |

## Optional Advanced Challenge

Create a production exception process for blocked actions.

Include:

1. Who requests the exception
2. Who approves it
3. Required business justification
4. Risk review
5. Expiration date
6. Logging and monitoring requirements
7. Rollback plan

---

# 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking SCPs grant permissions | SCPs look like IAM policies because they use JSON | Repeat that SCPs define maximum permissions only |
| Trying to fix SCP deny by adding IAM permissions | Students are used to IAM-only troubleshooting | Teach explicit deny and policy evaluation order |
| Applying strict production controls to dev without thought | Students think stricter is always better | Explain different risk profiles by environment |
| Not protecting log archive accounts | Students focus on workload accounts | Explain audit evidence and separation of duties |
| Giving developers permanent prod admin | Students optimize for speed | Teach controlled deployment roles, read-only access, and break-glass |
| Writing vague guardrails | Students do not tie controls to risks | Require each guardrail to have a business reason |
| Skipping detective controls | Students focus only on blocking | Explain visibility, reporting, and gradual enforcement |
| Confusing account assignment with IAM role permission | Both affect access | Separate “Can I see the account?” from “What can I do inside it?” |
| Bypassing guardrails instead of redesigning | Students treat all denied actions as problems | Teach that some blocked actions are correct outcomes |
| Overcomplicating SCP JSON | Students focus too much on syntax | Allow plain-English SCPs first, then show simple JSON examples |
| Denying `s3:PutBucketPublicAccessBlock` to "prevent public S3" | It reads like the public-access action but it is the *enforcement* action | Deny the `Delete...PublicAccessBlock` and public ACL/policy actions instead; keep enforcement allowed |
| Writing a blanket region `Deny` that breaks IAM/Organizations | Global services have no region | Use `NotAction` for global services with an `aws:RequestedRegion` condition |
| Attaching a new SCP to the root to "test it everywhere" | Students want fast coverage | Validate first, attach to a sandbox OU, then expand gradually |
| Assuming an SCP can block external principals | SCPs look all-powerful | Use an RCP for resource/data-perimeter controls against external principals |
| Treating break-glass as just a role name | Decks list "BreakGlassAdmin" without a mechanism | Design dedicated identity, MFA, time-bound access, CloudTrail alarm, and post-use review |

---

# 20. Real-World Enterprise Scenario

## Scenario

A financial services company has adopted AWS across several teams. Initially, teams created their own accounts and managed access manually. Over time, the company experienced several problems:

- Developers had too much production access
- Some S3 buckets were accidentally made public
- CloudTrail was disabled in one workload account
- Finance could not map cloud spend to owners
- Security could not consistently audit activity
- App teams were confused by inconsistent access models

The cloud platform team is now asked to implement a governed landing zone.

## Constraints

| Constraint | Detail |
|---|---|
| Access control | Production access must be limited and auditable |
| Security | CloudTrail must not be disabled |
| Cost | All resources must have owner and environment tags |
| Reliability | Backup and monitoring controls must protect production |
| Compliance | Logs must be retained in a protected account |
| Team workflow | Developers need enough access in dev/test to move quickly |
| Approvals | Risky production actions require approval |
| Multi-cloud | Leadership wants comparable governance patterns in Azure and GCP |

## What Each Role Would Do

### Cloud Engineer

- Design OU-level governance
- Define SCPs and guardrails
- Build account access patterns
- Document account placement
- Support Control Tower or account vending model

### DevOps Engineer

- Ensure CI/CD roles follow least privilege
- Avoid long-lived credentials
- Update pipelines to work within guardrails
- Redesign deployments that violate policy

### SRE

- Ensure production accounts have logging, alerts, runbooks, and break-glass procedures
- Validate incident response access
- Help define safe operational access
- Ensure guardrails do not block emergency response without an approved path

---

# 21. Instructor Tips

## Teaching Tips

- Keep coming back to the phrase: “Is the denial a bug, or is the guardrail working?”
- Use real examples like public S3, disabled CloudTrail, unapproved regions, and production admin access.
- Teach plain-English policy intent before showing JSON.
- Make students explain the business reason behind each guardrail.
- Reinforce that governance is part of architecture, not an afterthought.

## Pacing Tips

- Spend enough time on IAM vs SCP. This is the hardest concept.
- Do not spend too long on JSON syntax.
- Keep Azure/GCP comparison under 10 minutes.
- Leave at least 35 minutes for the lab.
- Use the troubleshooting activity to make the lesson practical.

## Lab Support Tips

When students are stuck, ask:

- What risk are you trying to reduce?
- Which OU does this account belong to?
- Should this be blocked or just detected?
- Who owns this account?
- Who should approve production access?
- What would happen if this control did not exist?

## How to Help Struggling Students

Give them a starter guardrail set:

```text
1. Deny disabling CloudTrail
2. Deny public S3 access
3. Detect missing required tags
4. Restrict production admin access
5. Alert on root account usage
```

Then ask them to map each guardrail to:

- Account or OU
- Preventive or detective
- Owner team
- Business reason

## How to Challenge Advanced Students

Ask them to design:

- Separate prod and non-prod SCP strategy
- Exception process
- Break-glass access model
- Account vending workflow
- CI/CD deployment role standard
- Guardrail rollout plan
- Terraform module for standard account baseline
- Multi-cloud governance mapping

---

# 22. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What cloud governance means
- [ ] What a guardrail is
- [ ] Difference between preventive and detective controls
- [ ] Difference between IAM and SCP
- [ ] Why SCPs do not grant permissions
- [ ] Why AdministratorAccess may still be blocked
- [ ] How IAM Identity Center supports multi-account access
- [ ] Why production access should be controlled
- [ ] When to use an SCP vs an RCP vs a declarative policy
- [ ] Why delegated administration keeps the management account minimal
- [ ] How multi-account networking works (TGW, centralized egress, RAM/shared VPC)
- [ ] What a real break-glass mechanism includes and why it must be loud
- [ ] How to roll out an SCP safely without locking out the org
- [ ] How Class 1 account structure supports Class 2 governance

## Students Should Be Able to Build or Configure

- [ ] Governance model table
- [ ] Guardrail list
- [ ] Preventive and detective control classification
- [ ] Access model by team
- [ ] Plain-English SCP examples
- [ ] Sample SCP JSON file
- [ ] Access troubleshooting flow
- [ ] Updated landing zone documentation

## Students Should Be Able to Troubleshoot

- [ ] Wrong AWS account context
- [ ] Wrong role or profile
- [ ] Missing IAM Identity Center account assignment
- [ ] Missing permission set
- [ ] IAM allow but SCP deny
- [ ] Guardrail blocking risky action
- [ ] Public S3 deployment failure
- [ ] Production access request issues
- [ ] A misconfigured SCP that denies the enforcement action instead of the risky one
- [ ] A region-restriction SCP that accidentally blocks global services
- [ ] Whether to add permission or redesign the architecture

---

# 23. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Reviewed Class 1 account structure
- [ ] Explained governance as a practical enterprise control system
- [ ] Explained IAM vs SCP clearly
- [ ] Explained preventive vs detective controls
- [ ] Demonstrated access-denied troubleshooting flow
- [ ] Students extended their landing zone design with governance
- [ ] Students completed or started guardrail documentation
- [ ] Students understand homework requirements
- [ ] Students understand that some blocked actions are intentional
- [ ] Students understand the multi-account networking foundation (TGW, centralized egress, RAM/shared VPC)
- [ ] Students understand how this foundation feeds Week 18 (Cost) and Weeks 19-20 (DevSecOps and Platform Engineering)

## Student Checklist Before Leaving Class

- [ ] I understand the difference between IAM and SCP
- [ ] I understand that SCPs do not grant permissions
- [ ] I created a governance model
- [ ] I created a guardrail list
- [ ] I classified guardrails as preventive or detective
- [ ] I created plain-English SCP examples
- [ ] I created or reviewed a sample SCP JSON file
- [ ] I created an access troubleshooting flow
- [ ] I know what to submit for homework
- [ ] I understand how Class 1 and Class 2 connect

## Items to Verify Before Closing the Week

- [ ] Students can explain landing zone structure
- [ ] Students can explain governance controls
- [ ] Students can connect OU placement to SCP inheritance
- [ ] Students can explain production access risks
- [ ] Students can troubleshoot basic access-denied scenarios
- [ ] Students have a complete landing zone design draft
- [ ] Students are ready for Week 18: Cost Optimization and Cloud Operations

---

# 24. End-of-Week Summary

## What Students Learned This Week

This week, students learned how enterprise AWS environments are structured and governed.

They learned:

- Why enterprises use multi-account AWS designs
- What a landing zone is
- How AWS Organizations and OUs structure accounts
- Why shared services, network, security, log archive, non-prod, and prod accounts are separated
- How governance controls protect cloud environments
- How SCPs differ from IAM policies, and how RCPs and declarative policies extend governance
- How accounts are vended as code (Control Tower Account Factory, AFT, LZA)
- How multi-account networking works (Transit Gateway, centralized egress, RAM/shared VPC)
- How delegated administration, automated remediation, and break-glass fit the operating model
- How IAM Identity Center supports centralized access
- How to troubleshoot access-denied issues in governed accounts and roll out SCPs safely

## How Class 1 and Class 2 Connect

Class 1 focused on structure:

```text
Accounts
OUs
Account purpose
Account ownership
Landing zone design
```

Class 2 focused on governance:

```text
Access model
Guardrails
SCPs
Permission sets
Troubleshooting
Production controls
```

Together, they form the foundation of enterprise cloud engineering:

```text
Landing Zone = Account Structure + Identity + Governance + Logging + Security + Operations
```

## How This Week Prepares Students for the Next Week

Week 18 focuses on:

**Cost Optimization and Cloud Operations**

The governed multi-account foundation built this week is exactly what cost management acts on. Students are now ready to ask:

- How do we allocate spend per account/environment using consolidated billing and Cost Categories?
- Where do the cost levers from this week live — NAT/centralized egress, AWS Config recording across every account, GuardDuty/Security Hub per account?
- Which guardrails can also enforce cost (region restriction, instance-type limits, required tags)?
- How does account-level separation make budgets, anomaly detection, and chargeback possible?

The networking, account-vending, and guardrail patterns from this week also feed Week 19 (DevSecOps reuses SCP/policy-as-code) and Week 20 (Platform Engineering reuses account vending and golden paths).

## What Students Should Review Before the Next Module

Students should review:

1. Their landing zone account diagram
2. Their network account purpose and the TGW / centralized-egress / RAM design
3. Their shared services account purpose
4. The cost-bearing services a landing zone enables (Config, CloudTrail, GuardDuty, NAT)
5. IAM vs SCP vs RCP vs declarative policy notes
6. The SCP safe-rollout and break-glass designs
7. Access troubleshooting flow
8. Homework governance proposal

Final weekly outcome:

Students should now be able to design and explain a basic enterprise AWS landing zone with account structure, governance controls, access model, and troubleshooting approach.

---

## Class Artifacts & Validation

This is the governance class, and its **policy-as-code** is the runnable core: the corrected deny-public-S3 guardrail (demo Step 3 / lab Step 9), the IAM least-privilege auditor, the S3 public-exposure detector, and the OPA/conftest rule that enforces the same intent in CI. These ship as real, validated files in the `security-automation` module repo (which the README maps to **Week 06 and reuses in Week 19** as CI gates). The VPC account-baseline row links the governed account back to its on-disk infra. All paths resolve; all results were re-run in this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/security-automation/solution/policies/opa/s3_deny_public.rego` | rego | Policy-as-code rule that **denies a public S3 bucket policy** — the OPA/Access-Analyzer "validate before attach" step in the SCP safe-rollout (lab Step 9c) | `opa test labs/security-automation/solution/policies/opa/s3_deny_public.rego labs/security-automation/solution/policies/opa/s3_deny_public_test.rego` | PASS (5/5) |
| 2 | `labs/security-automation/solution/policies/opa/fixtures/public-bucket-policy.json` | json | Public-bucket fixture the rule must DENY; `conftest` enforces the rule against it | `conftest test --policy labs/security-automation/solution/policies/opa --namespace s3.deny_public labs/security-automation/solution/policies/opa/fixtures/public-bucket-policy.json` (exit 1 = denied, as intended) | PASS |
| 3 | `labs/security-automation/solution/s3_public_check.sh` | shell | Detector for public S3 `Principal "*"` / public ACL — the detective control behind the public-S3 guardrail | `bash -n labs/security-automation/solution/s3_public_check.sh` + behavioural (exit 1 on the public fixture) | PASS |
| 4 | `labs/security-automation/solution/iam_policy_audit.py` | python | IAM wildcard/`NotAction` auditor — gates over-broad grants (the IAM-vs-SCP least-privilege lesson) in CI | `PYTHONPATH=labs/security-automation/solution python3 -m unittest discover -s labs/security-automation/tests` | PASS (14 tests, OK) |
| 5 | `labs/security-automation/solution/policies/scp/deny-leave-org.json` | json (SCP) | Org-root guardrail SCP — reference for the preventive SCPs students write (deny-CloudTrail, region, deny-public-S3) | `python3 -m json.tool < labs/security-automation/solution/policies/scp/deny-leave-org.json` | PASS |
| 6 | `labs/security-automation` (full module) | mixed | The complete shift-left toolkit (3 scanners + policy-as-code), `./validate.sh` runs every gate including `opa`+`conftest` with the real tools | `./labs/security-automation/validate.sh` | PASS — 24 passed, 0 failed, 0 deferred |
| 7 | `labs/terraform-aws-foundations/solution` | terraform | The VPC account-baseline the governed account is built on; applied to and destroyed from a real AWS account (account 071146695791, us-east-1) | `terraform -chdir=labs/terraform-aws-foundations/solution validate` + live apply/destroy | PASS — `Success! The configuration is valid.`; live run in `labs/terraform-aws-foundations/LIVE-AWS-VALIDATION.txt` |

> Note: the in-class hands-on (lab Step 9: `accessanalyzer validate-policy`, `create-policy`/`attach-policy`, attempting the denied vs. enforcement S3 action) runs against a **live sandbox AWS Organization** and is not captured as a committed evidence file. The committed, repeatable artifacts above are the policy-as-code files that encode and test the same guardrail intent offline.

## Definition of Done

Ticked honestly for **this class**. Governance is taught as policy-as-code with real, validated files in the backing module repo; this class reuses those artifacts rather than introducing a new lab of its own.

- [x] Every technology taught ships at least one **runnable file on disk** — the rego rule, conftest fixtures, IAM auditor, S3 detector, and SCP JSON are all real files under `labs/security-automation/`, plus the VPC Terraform module.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `opa test`, `conftest test`, `bash -n`, `python3 -m unittest`, `json.tool`, and `terraform validate` were re-run here (see manifest).
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `security-automation` ships `starter/` (detection logic TODO'd) and `solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — the `security-automation` README covers all of these.
- [x] **Cleanup/teardown** is provided and idempotent — lab Step 9g (mandatory SCP/OU detach+delete) here; the backing lab provisions nothing (`$0`, fixture-driven) and documents a pristine-tree reset.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — Sections 15–18 here, plus the `Instructor answer key` in the `security-automation` README.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — Section 15 (admin role blocked by SCP explicit deny) here; the backing lab adds a `broken/` planted-secret fixture and the documented backwards-`PutBucketPublicAccessBlock` footgun.
- [x] **Expected outputs** are shown for demos and labs — `AccessDenied` text, `validate-policy` empty-findings output, and `opa`/`conftest` results throughout Sections 13–14 and the manifest.
- [x] **Cost & security warnings** present — sandbox SCP/OU ops are free and reversible; NAT/centralized-egress and Config/GuardDuty cost notes (Section 11); the public-S3 footgun and break-glass security notes.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/security-automation/` and `labs/terraform-aws-foundations/`, and to Weeks 18/19/20, verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`/validation above.
