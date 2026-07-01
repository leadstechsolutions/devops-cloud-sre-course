# Week 6: AWS IAM and Security Foundations
> **▶ Runnable lab for this class:** [`labs/security-automation/`](../../labs/security-automation/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package

**Week:** 6  
**Class:** Class 6.1  
**Class Title:** Class 6.1: IAM Users, Groups, Policies, Roles, and Least Privilege  
**Track:** Unified DevOps · Cloud · SRE Track  
**Duration:** 3 hours  
**Course:** Enterprise DevOps, Cloud Engineering, and SRE Program  
**Primary Cloud:** AWS  
**Secondary Cloud Exposure:** Azure and GCP

---

# 1. Class Overview

## Class Title

**Class 6.1: IAM Users, Groups, Policies, Roles, and Least Privilege**

## Class Purpose

This class introduces students to AWS Identity and Access Management from a practical security and operations perspective. Students learn how AWS decides who can access what, how IAM policies work, why least privilege is one of the most important cloud security principles, and how **IAM roles and temporary credentials** (not long-lived access keys) are the way real workloads and pipelines authenticate to AWS.

## How This Class Connects to the Overall Course

This class builds directly on Week 4 (AWS Cloud Foundations), where students learned AWS account/identity basics, AWS CLI, billing safety, and the shared responsibility model, and on Week 5 (Networking & VPC). IAM is the security foundation for almost everything students will do later in the course, including:

- AWS CLI access
- Terraform deployments (Week 14-15)
- CI/CD pipelines (Week 9, secured with OIDC instead of stored keys)
- Kubernetes/EKS access (Week 11-13)
- Secrets management (Class 2 of this week)
- CloudTrail auditing
- Production troubleshooting
- Enterprise access governance (Week 17 Landing Zones)

This class covers IAM users, groups, policies, least privilege, **and** the core role model: IAM roles, `sts:AssumeRole`, trust policies, and EC2 instance profiles. Class 2 builds on this with secrets management (KMS, Secrets Manager, Parameter Store) and governance, and the role concepts you learn here are reused everywhere from CI/CD to Kubernetes service accounts.

## What Students Will Build, Analyze, or Practice

Students will:

- Read basic IAM JSON policies
- Identify overly broad permissions
- Create a least-privilege S3 read-only policy
- Test permissions using IAM Policy Simulator or AWS CLI
- Troubleshoot a missing S3 permission issue
- Analyze risky IAM policy examples
- Create an **IAM role with a trust policy** and assume it with `sts:AssumeRole`
- Attach a role to an EC2 instance via an **instance profile** (concept + lab)
- Add a `Condition` block (require MFA / restrict by source IP) to a policy
- Reason through **policy evaluation order** (identity allow + SCP/boundary deny)
- Run **IAM Access Analyzer** to find unused or externally-shared access

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the purpose of AWS IAM and why it matters in cloud security.
2. **Compare** IAM users, groups, roles, and policies.
3. **Read** basic IAM JSON policy structure, including a `Condition` block.
4. **Identify** overly broad permissions such as `Action: "*"` and `Resource: "*"`.
5. **Build** a least-privilege policy for controlled S3 read-only access.
6. **Create** an IAM role with a trust policy and **assume** it using `sts:AssumeRole`.
7. **Explain** how EC2 instance profiles and temporary credentials replace long-lived access keys.
8. **Validate** permissions using IAM Policy Simulator or AWS CLI.
9. **Reason** through IAM policy evaluation order (identity, resource, SCP, permission boundary, explicit deny).
10. **Troubleshoot** access issues caused by missing IAM permissions or a misconfigured trust policy.
11. **Document** the security risk of excessive permissions and long-lived credentials in enterprise AWS accounts.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand:

- Basic AWS account structure from Week 4
- AWS Regions and Availability Zones at a high level
- AWS Console navigation basics
- AWS CLI profile basics
- Basic JSON syntax
- Basic cloud security responsibility model
- Basic terminal usage

## Required Tools Already Installed

Students should have:

- Browser
- Terminal
- AWS CLI
- VS Code or text editor
- Git, optional for saving lab files

## Required Accounts or Access

Students need one of the following:

- A sandbox AWS account
- A classroom AWS account
- An instructor-provided AWS environment
- IAM permissions to view IAM and create customer-managed IAM policies

Minimum recommended permissions for the lab:

```json
{
  "Effect": "Allow",
  "Action": [
    "iam:CreatePolicy",
    "iam:GetPolicy",
    "iam:GetPolicyVersion",
    "iam:ListPolicies",
    "iam:DeletePolicy",
    "iam:CreateRole",
    "iam:GetRole",
    "iam:DeleteRole",
    "iam:AttachRolePolicy",
    "iam:DetachRolePolicy",
    "iam:PutRolePolicy",
    "iam:DeleteRolePolicy",
    "iam:SimulateCustomPolicy",
    "sts:AssumeRole",
    "sts:GetCallerIdentity",
    "access-analyzer:ListAnalyzers",
    "access-analyzer:CreateAnalyzer",
    "access-analyzer:ListFindings"
  ],
  "Resource": "*"
}
```

> **Teaching callout (read this out loud):** This sandbox permission set uses `"Resource": "*"` on powerful `iam:*` actions. That is intentionally *not* least-privilege — it is a convenience for a throwaway training account. In a real account, IAM-administration permissions are tightly scoped (often behind a permission boundary so that even an admin role cannot grant itself more than the boundary allows). We are about to spend the whole class arguing for least privilege, so it is worth naming the irony now: bootstrap/admin permissions are exactly the ones you scope hardest in production.

## Files, Repos, or Sample Code Needed

Students should create a local folder:

```bash
mkdir -p week-06-iam/class-01
cd week-06-iam/class-01
```

Recommended files:

```text
s3-readonly-policy.json
broken-s3-policy.json
policy-analysis-notes.md
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| IAM | AWS Identity and Access Management. It controls who can access AWS and what they can do. | Every AWS environment depends on IAM for security. |
| Authentication | Proving who you are. | Logging in with username, password, MFA, or federated identity. |
| Authorization | Deciding what you are allowed to do. | A user may log in but still be denied access to S3. |
| IAM User | A long-term identity in AWS. | Used less often in enterprises for humans because federation is preferred. |
| IAM Group | A collection of IAM users with shared permissions. | Used to manage access for multiple users in simple environments. |
| IAM Policy | A JSON document that defines allowed or denied actions. | Used to control access to AWS services and resources. |
| Managed Policy | A reusable policy that can be attached to multiple identities. | Preferred over inline policies for easier management. |
| Inline Policy | A policy embedded directly into one user, group, or role. | Harder to reuse and manage at scale. |
| Least Privilege | Giving only the access required to perform a task. | A support engineer should read logs, not delete databases. |
| Explicit Deny | A deny rule that overrides allow rules. | Used to block risky actions even if another policy allows them. |
| Action | The AWS API operation being allowed or denied. | Example: `s3:GetObject`, `ec2:StartInstances`. |
| Resource | The AWS object the policy applies to. | Example: one S3 bucket or one group of objects. |
| ARN | Amazon Resource Name, a unique identifier for AWS resources. | Used inside IAM policies to scope permissions. |
| IAM Policy Simulator | AWS tool used to test whether a policy allows or denies actions. | Useful for troubleshooting access before production changes. |
| IAM Role | An identity with permissions that has **no permanent credentials** and is meant to be *assumed* temporarily by a trusted principal. | EC2 instances, Lambda functions, CI/CD pipelines, and humans-via-SSO all use roles instead of access keys. |
| Trust Policy | The policy attached to a role that says **WHO is allowed to assume it** (the principal), separate from what the role can do. | A role for EC2 trusts `ec2.amazonaws.com`; a CI/CD role trusts a GitHub OIDC provider. |
| Permission Policy | The policy attached to a role that says **WHAT the role can do** once assumed. | Same JSON structure as a user policy (Effect/Action/Resource). |
| STS (Security Token Service) | The AWS service that issues **short-lived temporary credentials** when a role is assumed. | `sts:AssumeRole` returns an access key, secret key, and session token that expire (default 1 hour). |
| Temporary Credentials | Access keys that automatically expire, issued by STS. | Far safer than long-lived IAM user access keys because a leak has a short blast-radius window. |
| Instance Profile | A container that attaches an IAM role to an EC2 instance so code on the instance gets credentials automatically. | Application on EC2 calls AWS with no stored keys; the SDK fetches temporary credentials from instance metadata. |
| Condition | An optional policy element that only grants/denies when extra criteria are met (MFA present, source IP, region, tags). | `"Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}` requires MFA. |
| ABAC | Attribute-Based Access Control: granting access by matching tags on the principal and the resource. | `aws:PrincipalTag/team` must equal `aws:ResourceTag/team`. Scales better than writing a policy per resource. |
| Permission Boundary | A policy that sets the **maximum** permissions an identity can ever have, even if other policies grant more. | Used so a delegated admin can create roles but never exceed a ceiling. |
| SCP (Service Control Policy) | An AWS Organizations guardrail that caps permissions for **every** identity in an account. | A `Deny` SCP can block a region or a service org-wide regardless of IAM policy. Taught fully in Week 17. |
| IAM Access Analyzer | A service that finds resources shared with external principals and reports unused access/permissions. | Modern way to automate least-privilege reviews instead of reading every policy by hand. |
| OIDC Federation | Letting an external identity provider (e.g. GitHub Actions) assume an AWS role via short-lived OIDC tokens, with **no stored AWS keys**. | The 2026 standard for keyless CI/CD. Hands-on preview in this class; reused in Week 9 CI/CD. |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | Used to view IAM, create policies, and demonstrate access control visually. |
| AWS CLI | Used to validate identity and optionally test access from terminal. |
| IAM Policy Simulator | Used to test whether policy actions are allowed or denied. |
| VS Code or text editor | Used to write and review IAM JSON policy files. |
| Terminal | Used for AWS CLI commands and local file work. |
| Browser | Used for AWS Console and documentation access. |
| Git, optional | Used to save policy files and notes as part of student portfolio. |

---

# 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| IAM | Main service for identities, groups, roles, and policies. |
| S3 | Used as the sample service for read-only access control. |
| STS | Used hands-on to assume a role and receive temporary credentials (`aws sts assume-role`). |
| IAM Access Analyzer | Used in a short demo to surface unused access and externally-shared resources. |
| EC2 / Instance Profile | Used to explain (and optionally demo) how a role attaches to a compute instance with no stored keys. |
| CloudTrail, preview only | Mentioned as the audit trail for IAM activity and access decisions. |

## Cost Warning

IAM policy creation is free. IAM Policy Simulator is free.  
Avoid creating unnecessary S3 buckets unless the instructor specifically wants live bucket testing.

## Security Warning

Use a sandbox account. Do not test IAM policies in production accounts. Do not grant `AdministratorAccess` to students unless the environment is intentionally isolated and temporary.

---

# 7. Azure and GCP Comparison Notes

Keep this short during Class 1.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Identity and access service | IAM | Microsoft Entra ID + Azure RBAC | Cloud IAM |
| Permission document | IAM Policy JSON | Role assignment / custom role | IAM role binding |
| Human identity | IAM user or federated identity | Entra ID user | Google identity |
| Resource-level access | Resource ARNs and policies | Resource scope hierarchy | Resource hierarchy and IAM bindings |

## Instructor Note

Do not spend too much time here. The main teaching goal is AWS IAM. Mention that all major clouds have identity, permissions, and least-privilege concepts, but each implements them differently.

---

# 8. Time-Boxed Instructor Agenda

| Time | Segment | Activity |
|---:|---|---|
| 0:00 to 0:10 | Opening | Review Week 4 account safety and explain why IAM matters |
| 0:10 to 0:25 | Concept teaching | Authentication vs authorization, IAM overview |
| 0:25 to 0:40 | IAM identities | Users, groups, policies — and why human users are fading |
| 0:40 to 1:00 | Policy structure | IAM JSON policy anatomy, including a `Condition` block |
| 1:00 to 1:10 | Short break | 10-minute break |
| 1:10 to 1:30 | Least privilege | Good vs bad permission examples; policy evaluation order |
| 1:30 to 2:00 | IAM roles & STS | Roles, trust policies, `sts:AssumeRole`, instance profiles, OIDC keyless CI/CD preview |
| 2:00 to 2:20 | Instructor demo | Create/test S3 read-only policy; assume a role; Access Analyzer |
| 2:20 to 2:50 | Student lab | Least-privilege policy + create-and-assume-a-role + MFA condition |
| 2:50 to 2:57 | Troubleshooting activity | Missing `s3:ListBucket`; trust-policy assume-role failure |
| 2:57 to 3:00 | Recap | Review takeaways and homework |

---

# 9. Instructor Lesson Plan

## Step 1: Open With the Business Problem

Say:

> In AWS, almost every action is an API call. IAM decides whether that API call is allowed or denied. If IAM is wrong, users may be blocked from doing their job, or worse, they may have too much access.

Explain that today’s class covers the full IAM access model:

- Users
- Groups
- Policies
- Least privilege
- Policy troubleshooting
- **Roles, trust policies, STS, and temporary credentials**

Teach users/groups/policies/least-privilege first to build the mental model, then move to roles in the back third — roles are where everything real (EC2, Lambda, CI/CD, Kubernetes, cross-account) actually lives.

## Step 2: Connect Back to Week 4

Ask students:

- What happens if someone gets access to your AWS account?
- Why did we create budget alerts back in Week 4?
- Why is shared responsibility important for IAM?

Transition:

> AWS secures the cloud infrastructure, but we are responsible for controlling access inside our AWS account.

## Step 3: Explain IAM at a High Level

Show the simple mental model:

```text
Who are you?          Authentication
What can you do?      Authorization
What did you do?      Auditing
```

Tell students that Class 1 is mostly about authorization.

## Step 4: Explain Users, Groups, and Policies

Use an office building analogy:

- User: employee badge
- Group: department
- Policy: access rule
- Resource: room or system
- Action: what the employee can do

Pause and ask:

> If a finance intern needs to read reports, should they also be able to delete reports?

Use this to introduce least privilege.

## Step 5: Teach IAM Policy JSON

Open VS Code and show a simple policy.

Walk through each field:

- `Version`
- `Statement`
- `Effect`
- `Action`
- `Resource`
- `Condition`

Teaching tip: Do not try to explain every IAM condition operator. Focus on reading policy structure, then show **one** real `Condition` so students see it is not magic:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireMFAForS3",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*",
      "Condition": {
        "Bool": { "aws:MultiFactorAuthPresent": "true" }
      }
    }
  ]
}
```

Read it as: "allow these actions **only if** the caller authenticated with MFA in this session." Mention two other common keys you will use later: `aws:SourceIp` (lock access to an office/VPN CIDR) and `aws:RequestedRegion` (block actions outside an approved region). Conditions are the bridge from coarse least-privilege to ABAC (attribute-based access control), where access is decided by matching tags like `aws:PrincipalTag/team`.

## Step 6: Show Bad Policy vs Better Policy

Show this bad policy:

```json
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}
```

Ask students:

> What could go wrong if this policy is attached to a normal user?

Then show a better S3 scoped policy.

## Step 7: Instructor Demo

Create or display a customer-managed policy for S3 read-only access.

Use the IAM Policy Simulator to show:

- Read actions allowed
- Write/delete actions denied

## Step 8: Student Lab

Students create and validate their own least-privilege policy.

Instructor should circulate and check:

- Did students use correct bucket ARN?
- Did students understand bucket-level vs object-level permissions?
- Did they test both allowed and denied actions?

## Step 9: Troubleshooting Activity

Give students a broken policy missing `s3:ListBucket`.

Let them investigate before revealing the fix.

## Step 10: Teach IAM Roles and Temporary Credentials

This is the senior-readiness core of the class. Open with the problem:

> A user has long-lived access keys. If those keys leak — committed to Git, pasted in Slack, left on a laptop — an attacker has them until someone notices and rotates them. How do we give an application or a pipeline access **without** any permanent secret?

Answer: **IAM roles.** A role is an identity with permissions but **no permanent credentials**. A trusted principal *assumes* the role and receives short-lived credentials from STS that expire automatically.

Teach the two-policy mental model — this is the #1 thing students confuse:

```text
A ROLE HAS TWO POLICIES:

1. Trust policy   -> WHO can assume this role   (the "principal")
2. Permission policy -> WHAT the role can do once assumed
```

Show a trust policy that lets a specific user assume the role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowUserToAssume",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789012:user/devops-student" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Then show a trust policy that lets **EC2** assume the role (this is what an instance profile uses):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Explain instance profiles in one breath:

> When you launch EC2 and attach a role, AWS wraps that role in an *instance profile*. The SDK/CLI on the instance automatically fetches temporary credentials from the instance metadata service — your code never stores a key. This is why production apps on EC2 have no access keys in them.

## Step 11: Teach Federation, SSO, and OIDC Keyless CI/CD (Awareness + Preview)

Students will not stand up an identity provider today, but they must leave knowing the 2026 access model:

- **Humans** in mature orgs do not get IAM users. They log in through **IAM Identity Center** (formerly AWS SSO) or a corporate IdP (Entra ID, Okta) via SAML/OIDC, and are mapped to **permission sets** that become roles in each account.
- **CI/CD pipelines** do not store AWS access keys. GitHub Actions / GitLab present a short-lived **OIDC token**, and an AWS role's trust policy lets that specific repo/branch assume the role — **keyless CI/CD**.

Show the shape of a GitHub OIDC trust policy (students will use this for real in Week 9):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
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
    }
  ]
}
```

Talk track:

> Notice there is no secret here. The trust policy says: "only the `main` branch of `my-org/my-repo` may assume this role, and only with a GitHub-issued token meant for AWS STS." A leaked token is useless because it is short-lived and audience-bound. This is why storing `AWS_ACCESS_KEY_ID` in CI secrets is now considered a smell.

## Step 12: Teach Policy Evaluation Order and Access Analyzer

Students must reason about precedence, not memorize "deny wins." Walk the chain:

```text
1. Explicit DENY anywhere (identity, resource, SCP, boundary, session) -> DENIED. Always.
2. Otherwise, an SCP must ALLOW (org guardrail ceiling).
3. AND a permission boundary, if attached, must ALLOW (max-permission ceiling).
4. AND an identity or resource policy must explicitly ALLOW.
5. If nothing allows -> implicit DENY (default).
```

Then introduce **IAM Access Analyzer** as the modern least-privilege tool: it finds resources shared with external accounts and reports *unused* permissions/roles so teams can trim access automatically instead of reading every policy by hand. (10-minute demo in Section 12.)

## Step 13: Wrap Up

End with:

> IAM is not just a security topic. It is also a troubleshooting topic. Many real AWS issues are caused by missing permission, wrong resource ARN, explicit deny, or a trust policy that does not name the right principal.

Transition to Class 2:

> Next class, we apply IAM to **secrets**: AWS KMS, Secrets Manager, and Parameter Store — how applications retrieve credentials at runtime using the role model you learned today, and the governance controls around them.

---

# 10. Instructor Lecture Notes

## IAM Is the Front Door of AWS Security

IAM controls access to AWS services and resources. Whenever someone uses AWS Console, AWS CLI, Terraform, CI/CD, SDKs, or applications, IAM is involved.

Say:

> Every click in the AWS Console and every AWS CLI command eventually becomes an AWS API call. IAM decides if that API call is allowed.

## Authentication vs Authorization

Authentication answers:

> Who are you?

Authorization answers:

> What are you allowed to do?

Example:

A user successfully logs into AWS. That means authentication worked. But when they try to list S3 buckets, they receive `AccessDenied`. That means authorization failed.

## IAM Users

IAM users are identities inside an AWS account. They can have passwords for console access and access keys for programmatic access.

Enterprise context:

Human IAM users are less preferred in mature AWS environments. Larger companies usually use federation through IAM Identity Center or identity providers. However, IAM users are still useful for learning the basic model.

## IAM Groups

Groups help assign permissions to multiple users. A group does not call AWS APIs by itself. It only helps organize user permissions.

Example groups:

- ReadOnlyUsers
- Developers
- SecurityAuditors
- BillingViewers

## IAM Policies

IAM policies define permissions. They are written in JSON.

A policy statement usually says:

> Allow or deny these actions on these resources under these conditions.

## Policy Anatomy

Example:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadObjects",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::company-reports/*"
    }
  ]
}
```

Explain:

- `Effect`: Allow or Deny
- `Action`: API action
- `Resource`: Target resource
- `Sid`: Optional statement label

## Least Privilege

Least privilege means granting the minimum permissions needed.

Bad request:

> Give this user S3 access.

Better request:

> Give this support engineer read-only access to objects in the `company-reports` bucket for troubleshooting.

Best request:

> Give this support engineer `s3:ListBucket` on `company-reports` and `s3:GetObject` on `company-reports/*`, with no write or delete permissions.

## IAM Roles vs IAM Users

This is the most important distinction for real work.

| | IAM User | IAM Role |
|---|---|---|
| Credentials | Long-lived access keys / password | None stored; temporary credentials issued by STS on assume |
| Who uses it | A specific human or legacy script | Anything *trusted* by the role: EC2, Lambda, CI/CD, another account, a federated human |
| Leak blast radius | Large — valid until rotated | Small — temporary credentials expire (default 1 hour) |
| Preferred in 2026 | Rarely, mostly break-glass | Yes — the default for workloads and (via SSO) humans |

A role carries **two** policies, and mixing them up is the classic beginner error:

- **Trust policy** = WHO may assume the role (`Principal` + `sts:AssumeRole`). If the trust policy does not name your principal, you get `AccessDenied` on the *assume*, before any permission is even evaluated.
- **Permission policy** = WHAT the role can do once assumed (normal `Effect`/`Action`/`Resource`).

When a principal assumes a role, **STS** returns three values: an access key ID, a secret access key, and a **session token**. All three expire. This is why temporary credentials are safer than IAM user keys.

## How Workloads Actually Authenticate (No Stored Keys)

- **EC2** → attach a role via an **instance profile**; the SDK fetches credentials from instance metadata.
- **Lambda / ECS / EKS** → an execution role / IAM Roles for Service Accounts (IRSA); same temporary-credential pattern.
- **CI/CD (GitHub Actions, GitLab)** → **OIDC federation**: the pipeline presents a short-lived OIDC token and assumes a role via `sts:AssumeRoleWithWebIdentity`. No `AWS_ACCESS_KEY_ID` stored anywhere. This is the 2026 standard and you will configure it for real in Week 9.
- **Humans** → **IAM Identity Center** (or Entra ID / Okta via SAML/OIDC) maps each person to **permission sets** that become assumable roles per account. This replaces creating an IAM user per person.

## Policy Evaluation Order

When AWS evaluates a request it applies this precedence (simplified but accurate):

1. An **explicit Deny** anywhere (identity policy, resource policy, SCP, permission boundary, session policy) wins immediately.
2. An **SCP** (AWS Organizations guardrail) must allow the action — it is a ceiling, not a grant.
3. A **permission boundary**, if attached, must allow the action — also a ceiling.
4. An **identity** or **resource** policy must explicitly **Allow**.
5. If nothing allows the action, the result is an **implicit Deny** (the default).

Senior candidates are expected to reason through this chain — "the identity policy allows it, so why is it denied?" is often answered by an SCP or boundary higher up.

## Common Misconceptions

| Misconception | Correction |
|---|---|
| If someone can log in, they can use AWS services | Login only proves identity. Authorization still controls access. |
| `s3:GetObject` allows listing a bucket | Listing a bucket requires `s3:ListBucket`. |
| One S3 ARN covers both bucket and objects | Bucket and object ARNs are different. |
| `Resource: "*"` is always fine for read-only | It may expose too many resources. Scope it when possible. |
| Allow always means access is granted | Explicit deny, boundaries, SCPs, and resource policies can still block access. |

## Enterprise Context

In enterprise environments, IAM is connected to:

- Access request workflows
- Security approvals
- Audit logs
- Cloud governance
- CI/CD deployment permissions
- Terraform execution roles
- Incident response
- Separation of duties

A DevOps engineer, Cloud Engineer, or SRE does not need to memorize every IAM action. They need to know how to read policies, reason about access, and troubleshoot denied requests.

---

# 11. Whiteboard Explanation

## Simple Diagram: IAM Access Decision

```text
Person or Tool
     |
     v
AWS API Request
     |
     v
IAM checks:
  1. Who is calling?
  2. What action are they requesting?
  3. Which resource are they targeting?
  4. Is there an Allow?
  5. Is there an Explicit Deny?
     |
     v
Allowed or Denied
```

## Example Flow

```text
User: junior-support-user
Action: s3:ListBucket
Resource: arn:aws:s3:::company-reports

IAM checks attached policies
        |
        v
Policy allows s3:ListBucket on company-reports?
        |
        v
Yes -> Access allowed
No  -> Access denied
```

## Bucket vs Object ARN

```text
Bucket itself:
arn:aws:s3:::company-reports

Objects inside bucket:
arn:aws:s3:::company-reports/*
```

## Enterprise Version

```text
Support Engineer
      |
      v
AWS Console / AWS CLI
      |
      v
IAM Identity
      |
      v
Group or Permission Set
      |
      v
IAM Policy
      |
      v
Allowed access to approved resources only
      |
      v
CloudTrail records activity
```

## Instructor Explanation

In a real company, access is usually not random. A support engineer may request access through a ticket. Security or platform engineering approves a specific permission. IAM enforces that permission. CloudTrail records what happened.

---

# 12. Instructor Demo Script

## Demo Title

**Create and Test a Least-Privilege S3 Read-Only IAM Policy**

## Demo Objective

Show students how to move from a risky broad policy to a scoped least-privilege policy.

## Required Setup

Instructor needs:

- AWS sandbox account
- Access to IAM Console
- AWS CLI configured
- Optional S3 bucket name for examples

Recommended sample bucket name:

```text
example-lab-bucket
```

This bucket does not need to exist if using policy simulation only.

## Step-by-Step Demo

### Step 1: Validate AWS Identity

Run:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDAEXAMPLE123456789",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/instructor-user"
}
```

Explain:

> Before testing IAM, always confirm which AWS account and identity you are using.

### Step 2: Show a Risky Policy

Open VS Code and create:

```bash
cat > bad-admin-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TooMuchAccess",
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
```

Explain:

> This policy allows every action on every resource. It is simple, but it is dangerous.

Ask:

> Would this be acceptable for a support engineer who only needs to read one S3 bucket?

Expected answer: No.

### Step 3: Create Least-Privilege Policy File

Create:

```bash
cat > s3-readonly-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListSpecificBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::example-lab-bucket"
    },
    {
      "Sid": "ReadObjectsInSpecificBucket",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-lab-bucket/*"
    }
  ]
}
EOF
```

Explain:

> We split bucket-level access and object-level access because S3 uses different resource patterns for the bucket and the objects inside it.

### Step 4: Validate JSON Locally

Optional command:

```bash
python -m json.tool s3-readonly-policy.json
```

Expected output:

Formatted JSON without errors.

If it fails, explain:

> IAM policies are JSON. A missing comma or bracket can break the policy before IAM even evaluates permissions.

### Step 5: Create the IAM Policy

Use a unique policy name:

```bash
aws iam create-policy \
  --policy-name Week6Class1S3ReadOnlyPolicy \
  --policy-document file://s3-readonly-policy.json
```

Expected output includes:

```json
{
  "Policy": {
    "PolicyName": "Week6Class1S3ReadOnlyPolicy",
    "Arn": "arn:aws:iam::123456789012:policy/Week6Class1S3ReadOnlyPolicy"
  }
}
```

Explain:

> This creates a reusable customer-managed IAM policy.

### Step 6: Test Policy Logic With Simulation

Use CLI simulation:

```bash
aws iam simulate-custom-policy \
  --policy-input-list file://s3-readonly-policy.json \
  --action-names s3:ListBucket s3:GetObject s3:PutObject s3:DeleteObject \
  --resource-arns arn:aws:s3:::example-lab-bucket arn:aws:s3:::example-lab-bucket/test.txt
```

Expected concepts in output:

```json
"EvalActionName": "s3:ListBucket",
"EvalDecision": "allowed"
```

```json
"EvalActionName": "s3:PutObject",
"EvalDecision": "implicitDeny"
```

Explain:

- `allowed` means the policy grants access.
- `implicitDeny` means no policy allowed the action.
- Explicit deny would override allow.

### Step 7: Show Console Alternative

In AWS Console:

1. Go to IAM.
2. Open Policies.
3. Review created policy.
4. Open Policy Simulator.
5. Select S3 actions.
6. Test list/read/write/delete actions.

### Step 8: Create and Assume a Role

Now show the role model live. First create a trust policy that lets the current account's caller assume the role.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${ACCOUNT_ID}:root" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

> Teaching note: `Principal: ...:root` trusts any IAM identity *in this account* that also has `sts:AssumeRole` permission in its own policy — convenient for a sandbox demo. In production you name a specific role, user, or service. To require MFA on the assume, you would add `"Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}` — we leave it off here so the demo assumes cleanly regardless of how the instructor authenticated.

Create the role and attach the S3 read-only policy as its permission policy:

```bash
aws iam create-role \
  --role-name Week6Class1S3ReaderRole \
  --assume-role-policy-document file://trust-policy.json

aws iam put-role-policy \
  --role-name Week6Class1S3ReaderRole \
  --policy-name S3ReadOnlyInline \
  --policy-document file://s3-readonly-policy.json
```

Assume the role and inspect the temporary credentials:

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::${ACCOUNT_ID}:role/Week6Class1S3ReaderRole \
  --role-session-name demo-session
```

Expected output (values truncated):

```json
{
  "Credentials": {
    "AccessKeyId": "ASIA...",
    "SecretAccessKey": "....",
    "SessionToken": "....",
    "Expiration": "2026-06-30T12:00:00Z"
  },
  "AssumedRoleUser": {
    "Arn": "arn:aws:sts::123456789012:assumed-role/Week6Class1S3ReaderRole/demo-session"
  }
}
```

Explain:

- The `AccessKeyId` starts with `ASIA` (temporary) instead of `AKIA` (long-lived user key).
- There is a `SessionToken` and an `Expiration` — these credentials self-destruct.
- The caller's identity is now `assumed-role/.../demo-session`, not the original user.

### Step 9: IAM Access Analyzer (10-minute demo)

Create an analyzer scoped to the account and list findings:

```bash
aws accessanalyzer create-analyzer \
  --analyzer-name week6-demo-analyzer \
  --type ACCOUNT

aws accessanalyzer list-findings \
  --analyzer-arn $(aws accessanalyzer list-analyzers \
      --query "analyzers[?name=='week6-demo-analyzer'].arn" --output text)
```

Explain:

- Access Analyzer reports resources (S3 buckets, IAM roles, KMS keys, etc.) shared with **external** principals — a fast way to catch accidental public/cross-account exposure.
- It also surfaces **unused** access (roles, permissions, access keys not used recently) so teams can trim toward least privilege automatically.
- This is how mature teams review least privilege at scale instead of reading every JSON policy by hand.

### Step 10: Cleanup

Detach/delete the role policy, delete the role, delete the policy, and delete the analyzer:

```bash
aws iam delete-role-policy \
  --role-name Week6Class1S3ReaderRole \
  --policy-name S3ReadOnlyInline

aws iam delete-role --role-name Week6Class1S3ReaderRole

aws iam delete-policy \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/Week6Class1S3ReadOnlyPolicy

aws accessanalyzer delete-analyzer --analyzer-name week6-demo-analyzer
```

Replace account ID with the actual account ID if not using the `${ACCOUNT_ID}` variable.

> Cost note: an account-level Access Analyzer is free. Delete it anyway to keep the sandbox tidy. Roles, policies, and trust policies incur no charge, but cleaning up keeps the IAM console readable for the next class.

## Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| `Unable to locate credentials` | AWS CLI not configured | Run `aws configure` or switch profile |
| `AccessDenied` when creating policy | Instructor lacks IAM permission | Use console with correct admin/sandbox role |
| JSON parse error | Invalid JSON | Run `python -m json.tool` |
| Policy name already exists | Duplicate policy name | Add date or initials to policy name |
| Simulation result confusing | Multiple resources tested together | Test one action and one resource at a time |
| `AccessDenied` on `sts:assume-role` | Trust policy does not name the caller, or caller lacks `sts:AssumeRole` | Check the role's **trust** policy `Principal`, then the caller's identity policy |
| `MalformedPolicyDocument` on `create-role` | Trust policy JSON invalid | The `--assume-role-policy-document` is the trust policy; validate it with `python -m json.tool` |
| Role assume "works" but S3 still denied | Permission policy missing/incomplete | Trust governs the assume; the **permission** policy governs what the session can do |

---

# 13. Student Lab Manual

## Lab Title

**Create and Validate a Least-Privilege S3 Read-Only IAM Policy**

## Lab Objective

Create a customer-managed IAM policy that allows read-only access to one S3 bucket and denies write/delete access.

## Estimated Time

30 minutes

## Student Prerequisites

Students should have:

- AWS CLI configured
- IAM console access
- Permission to create IAM policies in a sandbox account
- Basic JSON knowledge

## Architecture or Workflow Overview

```text
Student
   |
   v
Creates IAM Policy JSON
   |
   v
AWS IAM Customer Managed Policy
   |
   v
Policy Simulator
   |
   v
Allowed: List and read one bucket
Denied: Write and delete actions
```

## Step-by-Step Student Instructions

### Step 1: Create Lab Folder

```bash
mkdir -p week-06-iam/class-01
cd week-06-iam/class-01
```

### Step 2: Confirm AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/your-user"
}
```

Write down:

```text
AWS Account ID:
IAM identity ARN:
AWS CLI profile used:
```

### Step 3: Create Policy File

Create:

```bash
cat > s3-readonly-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListSpecificBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::example-lab-bucket"
    },
    {
      "Sid": "ReadObjectsInSpecificBucket",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-lab-bucket/*"
    }
  ]
}
EOF
```

### Step 4: Validate JSON Syntax

```bash
python -m json.tool s3-readonly-policy.json
```

Expected result:

The JSON prints back in formatted form with no error.

### Step 5: Create IAM Policy

Use your initials to avoid duplicate names:

```bash
aws iam create-policy \
  --policy-name Week6Class1S3ReadOnlyPolicy-YOURINITIALS \
  --policy-document file://s3-readonly-policy.json
```

Expected output:

```json
{
  "Policy": {
    "PolicyName": "Week6Class1S3ReadOnlyPolicy-YOURINITIALS",
    "Arn": "arn:aws:iam::123456789012:policy/Week6Class1S3ReadOnlyPolicy-YOURINITIALS"
  }
}
```

Copy the policy ARN.

### Step 6: Simulate Allowed and Denied Actions

Run:

```bash
aws iam simulate-custom-policy \
  --policy-input-list file://s3-readonly-policy.json \
  --action-names s3:ListBucket s3:GetObject s3:PutObject s3:DeleteObject \
  --resource-arns arn:aws:s3:::example-lab-bucket arn:aws:s3:::example-lab-bucket/test.txt
```

Expected decision patterns:

| Action | Expected Decision |
|---|---|
| `s3:ListBucket` | allowed for bucket ARN |
| `s3:GetObject` | allowed for object ARN |
| `s3:PutObject` | implicitDeny |
| `s3:DeleteObject` | implicitDeny |

### Step 7: Record Results

Create:

```bash
cat > policy-analysis-notes.md << 'EOF'
# Week 6 Class 1 IAM Policy Analysis

## Policy Name


## Allowed Actions


## Denied Actions


## Bucket ARN


## Object ARN


## What least privilege means in this lab


## What I would avoid in production


EOF
```

Fill in the answers.

### Step 8: Cleanup

Delete the policy if instructed by the instructor.

Replace the ARN with your actual policy ARN:

```bash
aws iam delete-policy \
  --policy-arn arn:aws:iam::123456789012:policy/Week6Class1S3ReadOnlyPolicy-YOURINITIALS
```

## Validation Checklist

Students should confirm:

- AWS CLI identity is correct.
- JSON policy file is valid.
- IAM policy was created.
- `s3:ListBucket` is allowed.
- `s3:GetObject` is allowed.
- `s3:PutObject` is denied.
- `s3:DeleteObject` is denied.
- Cleanup completed if required.

## Troubleshooting Tips

| Problem | Likely Cause | Fix |
|---|---|---|
| `Unable to locate credentials` | AWS CLI not configured | Configure AWS CLI or select correct profile |
| `MalformedPolicyDocument` | Bad JSON or wrong IAM syntax | Run `python -m json.tool` and review structure |
| `EntityAlreadyExists` | Policy name already exists | Add initials or timestamp |
| `AccessDenied` | Student lacks IAM permissions | Ask instructor for sandbox role/access |
| Unexpected deny for `s3:GetObject` | Wrong object ARN | Use `arn:aws:s3:::bucket-name/*` |
| Unexpected deny for `s3:ListBucket` | Wrong bucket ARN | Use `arn:aws:s3:::bucket-name` |

## Reflection Questions

1. Why does S3 need separate bucket-level and object-level ARNs?
2. Why is `Resource: "*"` risky?
3. Why is `s3:*` too broad for a read-only use case?
4. How would this policy change if a user needed upload access?
5. What would you document before giving this access in a real company?

## Optional Challenge Task

Modify the policy to allow uploads but still deny deletes.

Hint:

- Add `s3:PutObject`
- Do not add `s3:DeleteObject`

## Lab Part B: Create and Assume a Role (Required)

This part is the senior-readiness core. You will create a role, give it the S3 read-only permission policy, assume it, and observe temporary credentials.

### Step B1: Build a Trust Policy

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account: $ACCOUNT_ID"

cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${ACCOUNT_ID}:root" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

### Step B2: Create the Role with the Trust Policy

```bash
aws iam create-role \
  --role-name Week6Class1S3ReaderRole-YOURINITIALS \
  --assume-role-policy-document file://trust-policy.json
```

### Step B3: Attach the Permission Policy

Reuse the `s3-readonly-policy.json` you wrote earlier as the role's inline permission policy:

```bash
aws iam put-role-policy \
  --role-name Week6Class1S3ReaderRole-YOURINITIALS \
  --policy-name S3ReadOnlyInline \
  --policy-document file://s3-readonly-policy.json
```

### Step B4: Assume the Role

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::${ACCOUNT_ID}:role/Week6Class1S3ReaderRole-YOURINITIALS \
  --role-session-name lab-session
```

Confirm the output has a `SessionToken` and an `Expiration`, and that `AccessKeyId` begins with `ASIA` (temporary), not `AKIA` (permanent user key).

### Step B5: Record in Your Notes

In `policy-analysis-notes.md`, answer:

- What is the difference between the **trust** policy and the **permission** policy of this role?
- Why does the temporary access key start with `ASIA`?
- How would the trust policy change to let **EC2** assume this role instead of you? (Hint: `Principal: { "Service": "ec2.amazonaws.com" }`.)

### Step B6: Cleanup for Part B

```bash
aws iam delete-role-policy \
  --role-name Week6Class1S3ReaderRole-YOURINITIALS \
  --policy-name S3ReadOnlyInline

aws iam delete-role \
  --role-name Week6Class1S3ReaderRole-YOURINITIALS
```

## Lab Part C: Add an MFA Condition (Optional, Advanced)

Take your `s3-readonly-policy.json` and add a `Condition` so the read access only applies when the session used MFA:

```json
"Condition": {
  "Bool": { "aws:MultiFactorAuthPresent": "true" }
}
```

Add it inside the `s3:GetObject` statement, re-validate the JSON with `python -m json.tool`, and explain in your notes what happens to a non-MFA session that tries to read the object. (Answer: it is denied, because the condition is not satisfied.)

---

# 14. Troubleshooting Activity

## Incident Title

**Support User Cannot List S3 Bucket Contents**

## Business Impact

A support engineer needs to review application log files stored in S3 during a production issue. They can authenticate to AWS, but they cannot list the bucket contents. Incident response is delayed because they cannot inspect the files.

## Symptoms

The user runs:

```bash
aws s3 ls s3://example-lab-bucket
```

They receive:

```text
An error occurred (AccessDenied) when calling the ListObjectsV2 operation: Access Denied
```

## Starting Evidence

The user has this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadObjectsOnly",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-lab-bucket/*"
    }
  ]
}
```

## Student Investigation Steps

Students should check:

1. What action is the user trying to perform?
2. Which S3 API does `aws s3 ls` require?
3. Does the policy allow `s3:ListBucket`?
4. Is the resource ARN correct for bucket-level access?
5. Is the object ARN being confused with the bucket ARN?
6. Is there any explicit deny?
7. Would `s3:GetObject` alone allow listing?

## Expected Root Cause

The policy allows object reads using `s3:GetObject`, but it does not allow bucket listing using `s3:ListBucket`.

## Correct Resolution

Add this statement:

```json
{
  "Sid": "ListSpecificBucket",
  "Effect": "Allow",
  "Action": "s3:ListBucket",
  "Resource": "arn:aws:s3:::example-lab-bucket"
}
```

Final corrected policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListSpecificBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::example-lab-bucket"
    },
    {
      "Sid": "ReadObjectsOnly",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-lab-bucket/*"
    }
  ]
}
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Add `s3:*` | Grants too much access. |
| Change resource to `*` | Allows access beyond the intended bucket. |
| Assume login is broken | Authentication worked. Authorization failed. |
| Add admin access | Solves the symptom but creates security risk. |
| Ignore object vs bucket ARN difference | S3 permissions often require both. |

## Instructor Hints

Give hints in this order:

1. What exact command failed?
2. What action does that command need?
3. Does the policy include that action?
4. Is the resource bucket-level or object-level?
5. What does least privilege look like here?

## Preventive Action

Create an S3 read-only access template that includes both:

- `s3:ListBucket` on the bucket ARN
- `s3:GetObject` on the object ARN

Require IAM changes to be peer-reviewed before production use.

## Second Incident: Pipeline Cannot Assume Its Deployment Role

### Business Impact

A CI/CD pipeline that deploys to a sandbox account suddenly fails at the very first step — before any deployment — with an assume-role error. Releases are blocked.

### Symptoms

```text
An error occurred (AccessDenied) when calling the AssumeRole operation:
User: arn:aws:iam::123456789012:user/ci-deployer is not authorized to perform:
sts:AssumeRole on resource: arn:aws:iam::123456789012:role/deploy-role
```

### Starting Evidence

The role's **trust policy** is:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789012:user/old-ci-user" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

The pipeline now runs as `user/ci-deployer`, not `user/old-ci-user`.

### Student Investigation Steps (evidence-first)

1. **Symptom:** what exact operation failed? (`sts:AssumeRole`, not the deploy itself.)
2. **Evidence:** which principal is making the call? (`user/ci-deployer`.)
3. **Evidence:** which principal does the **trust** policy allow? (`user/old-ci-user`.)
4. **Root cause:** the trust policy names a different principal than the one calling — this is an *authorization on the assume*, not a missing permission policy.
5. **Fix:** update the trust policy `Principal` to the current caller (or, better, federate the pipeline via OIDC so no IAM user is involved at all).
6. **Validate:** re-run `aws sts assume-role` and confirm temporary credentials are returned.

### Correct Resolution

Update the trust policy to name the correct principal:

```json
"Principal": { "AWS": "arn:aws:iam::123456789012:user/ci-deployer" }
```

Senior follow-up: the *best* fix is to eliminate the long-lived `ci-deployer` user entirely and use **GitHub OIDC** (`sts:AssumeRoleWithWebIdentity` with a `sub` condition pinning the repo/branch), which you will configure in Week 9.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Add more permissions to `deploy-role` | The assume failed; the role's own permissions were never reached |
| Give `ci-deployer` `AdministratorAccess` | Does not fix a trust-policy mismatch and creates risk |
| Recreate the role | Loses history; the only change needed is the trust policy `Principal` |
| Assume login/credentials are broken | Authentication worked; the **trust** policy denied the assume |

---

# 15. Scenario-Based Discussion Questions

## Question 1

A developer asks for `AdministratorAccess` because they are blocked from reading one S3 bucket. What should the cloud team do?

Expected response themes:

- Do not grant admin access.
- Identify the required action.
- Scope permission to the specific bucket.
- Use least privilege.
- Test with simulator.

Instructor follow-up:

> What information would you ask the developer for before granting access?

## Question 2

A support engineer needs temporary access to production logs. Should access be broad or scoped?

Expected response themes:

- Scoped access.
- Time-bound access where possible.
- Read-only access.
- Audit access.
- Remove access after use.

Instructor follow-up:

> How would this change during a high-severity incident?

## Question 3

Why is `Resource: "*"` risky even for read-only permissions?

Expected response themes:

- May expose data across many resources.
- Violates least privilege.
- Creates audit risk.
- Makes access hard to reason about.

Instructor follow-up:

> Are there any AWS actions where `Resource: "*"` is unavoidable?

## Question 4

A junior engineer commits access keys to Git by accident. How does IAM policy design help or not help?

Expected response themes:

- Policy limits blast radius.
- Keys should be deactivated/rotated.
- CloudTrail should be reviewed.
- Long-lived credentials are risky.
- The real fix is to stop using long-lived keys: use roles + temporary credentials (and OIDC for CI/CD), as covered earlier in this class.

Instructor follow-up:

> What would your immediate incident response steps be?

## Question 5

A team says security reviews slow down delivery. How can least privilege support both security and speed?

Expected response themes:

- Reusable access templates.
- Clear request process.
- Pre-approved patterns.
- Automation.
- Policy review in Git.

Instructor follow-up:

> How could platform engineering make secure access easier for app teams?

## Question 6

Should students test IAM policies directly in production?

Expected response themes:

- No.
- Use sandbox/test accounts.
- Use Policy Simulator.
- Peer review changes.
- Apply change management.

Instructor follow-up:

> What could happen if an IAM policy is wrong in production?

## Question 7

A user can list a bucket but cannot download files. What might be missing?

Expected response themes:

- `s3:GetObject`.
- Object ARN with `/*`.
- Possible bucket policy deny.
- Encryption/KMS permissions if encrypted.

Instructor follow-up:

> What extra permission may be needed if objects are encrypted with KMS?

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

What does IAM primarily control in AWS?

A. Monthly billing only  
B. Identity and access permissions  
C. Physical data center security  
D. DNS routing only  

**Answer:** B  
**Explanation:** IAM controls who can access AWS and what actions they can perform.

## Question 2: Multiple Choice

Which IAM policy field defines the AWS API operation being allowed or denied?

A. Resource  
B. Effect  
C. Action  
D. Version  

**Answer:** C  
**Explanation:** `Action` defines operations such as `s3:GetObject` or `ec2:StartInstances`.

## Question 3: True or False

If a user can log into AWS, they automatically have access to all AWS services.

**Answer:** False  
**Explanation:** Logging in proves authentication. Authorization is controlled separately by IAM permissions.

## Question 4: Multiple Choice

Which permission is required to list objects in an S3 bucket?

A. `s3:GetObject`  
B. `s3:PutObject`  
C. `s3:ListBucket`  
D. `s3:DeleteObject`  

**Answer:** C  
**Explanation:** Listing bucket contents requires `s3:ListBucket`.

## Question 5: Multiple Choice

Which resource ARN applies to all objects inside an S3 bucket named `company-reports`?

A. `arn:aws:s3:::company-reports`  
B. `arn:aws:s3:::company-reports/*`  
C. `arn:aws:iam:::company-reports`  
D. `arn:aws:s3:*:*:company-reports`  

**Answer:** B  
**Explanation:** Object-level permissions require the bucket ARN followed by `/*`.

## Question 6: True or False

An explicit deny overrides an allow.

**Answer:** True  
**Explanation:** In AWS policy evaluation, explicit deny has priority over allow.

## Question 7: Short Answer

What does least privilege mean?

**Answer:**  
Least privilege means granting only the permissions required to perform a specific task and nothing extra.

**Explanation:**  
This limits security risk and reduces the blast radius of mistakes or compromised credentials.

## Question 8: Troubleshooting

A user has `s3:GetObject` on `arn:aws:s3:::app-logs/*` but cannot run `aws s3 ls s3://app-logs`. What is likely missing?

**Answer:**  
`s3:ListBucket` on `arn:aws:s3:::app-logs`.

**Explanation:**  
The user can read objects if they know the object path, but listing the bucket requires bucket-level list permission.

## Question 9: Troubleshooting

A student receives `MalformedPolicyDocument` when creating an IAM policy. What should they check first?

**Answer:**  
Check JSON syntax and policy structure.

**Explanation:**  
Missing commas, brackets, quotes, or invalid fields commonly cause this error.

## Question 10: Multiple Choice

Why is this policy risky?

```json
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}
```

A. It only allows read-only access  
B. It allows all actions on all resources  
C. It denies all AWS access  
D. It only applies to S3  

**Answer:** B  
**Explanation:** This is full access across all AWS services and resources unless another control blocks it.

## Question 11: Short Answer

Name two tools that can help troubleshoot IAM permission issues.

**Answer:**  
IAM Policy Simulator and AWS CLI.

**Explanation:**  
The simulator tests policy decisions. AWS CLI shows real command errors and identity context.

## Question 12: Multiple Choice

Which AWS service can record API activity for auditing?

A. CloudTrail  
B. S3  
C. Route 53  
D. EBS  

**Answer:** A  
**Explanation:** CloudTrail records AWS API activity and helps audit who did what.

## Question 13: Multiple Choice

Which part of an IAM role decides **who** is allowed to assume it?

A. The permission policy  
B. The trust policy  
C. The bucket policy  
D. The instance profile  

**Answer:** B  
**Explanation:** The trust policy (the `--assume-role-policy-document`) defines the allowed `Principal` for `sts:AssumeRole`. The permission policy defines what the role can do once assumed.

## Question 14: Multiple Choice

What is the main security advantage of an IAM role over an IAM user with access keys?

A. Roles are cheaper  
B. Roles use temporary credentials that expire automatically  
C. Roles cannot be denied access  
D. Roles do not need policies  

**Answer:** B  
**Explanation:** Assuming a role returns short-lived STS credentials (default 1 hour), so a leak has a small blast-radius window compared with long-lived user keys.

## Question 15: True or False

A GitHub Actions workflow must store an `AWS_ACCESS_KEY_ID` secret to deploy to AWS.

**Answer:** False  
**Explanation:** With OIDC federation, the workflow presents a short-lived OIDC token and assumes a role via `sts:AssumeRoleWithWebIdentity`. No long-lived AWS keys are stored.

## Question 16: Troubleshooting Short Answer

A caller gets `AccessDenied ... sts:AssumeRole on resource ... role/deploy-role`, but the role's permission policy clearly allows the deployment actions. What should you check?

**Answer:**  
The role's **trust** policy — whether its `Principal` allows the calling identity. The assume is denied before the permission policy is ever evaluated.

## Question 17: Multiple Choice

In IAM policy evaluation, which of the following always wins?

A. An identity-policy Allow  
B. An explicit Deny anywhere in the evaluation  
C. A resource-policy Allow  
D. The most recently created policy  

**Answer:** B  
**Explanation:** An explicit Deny in any policy (identity, resource, SCP, permission boundary, or session) overrides all Allows.

---

# 17. Homework Assignment

## Assignment Title

**Analyze and Improve IAM Policies for Least Privilege**

## Scenario

A company is reviewing IAM access after a security audit. Three policies were found in a sandbox AWS account. Your job is to analyze the risk, explain what each policy allows, and improve one policy using least-privilege principles.

## Student Tasks

Analyze the following policies.

### Policy A

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
```

### Policy B

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "*"
    }
  ]
}
```

### Policy C

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::company-reports/*"
    }
  ]
}
```

## Expected Deliverables

Students submit a markdown file:

```text
week-06-class-01-homework.md
```

The file must include:

1. Risk level for each policy: Low, Medium, High, Critical
2. What each policy allows
3. What is overly broad or missing
4. Corrected version of at least one policy
5. Short explanation of least privilege
6. One paragraph explaining why IAM policy review matters in production

## Submission Format

Markdown file or shared document.

## Estimated Completion Time

60 to 90 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Correctly identifies policy risks | 25 |
| Correctly explains allowed actions | 20 |
| Identifies missing or overly broad permissions | 20 |
| Provides a valid corrected policy | 20 |
| Explains least privilege clearly | 10 |
| Clear formatting and professionalism | 5 |

## Optional Advanced Challenge

Write a corrected policy that allows:

- List only the `company-reports` bucket
- Read objects only under `reports/2026/`
- No write or delete access

Example resource path:

```text
arn:aws:s3:::company-reports/reports/2026/*
```

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Using `Action: "*"` | Students want to make access work quickly | Start with the exact task and map it to required actions |
| Using `Resource: "*"` unnecessarily | Students do not know ARN formats yet | Teach bucket ARN vs object ARN clearly |
| Forgetting `s3:ListBucket` | Students think `GetObject` includes list access | Explain bucket-level and object-level permissions |
| Bad JSON syntax | New students are not used to JSON | Validate with `python -m json.tool` |
| Testing in the wrong AWS account | Multiple profiles or accounts confuse students | Always run `aws sts get-caller-identity` first |
| Confusing authentication and authorization | Students think login means access | Repeat: login is who you are, IAM policy is what you can do |
| Creating policies but not deleting them | Students forget cleanup | Use cleanup checklist |
| Assuming all denies are from identity policy | IAM has many policy layers | Introduce resource policies, explicit deny, boundaries, and SCPs at a high level |

---

# 19. Real-World Enterprise Scenario

## Scenario

A logistics company has a production application that writes operational reports to an S3 bucket called:

```text
prod-shipment-reports
```

The application support team needs read-only access to troubleshoot missing customer reports. Security does not want the support team to upload, delete, or modify files. The company also requires all production access to be auditable.

## Constraints

- Support users need read-only access.
- Access must be limited to one bucket.
- No delete or upload permissions.
- Production changes require approval.
- CloudTrail must record access.
- Access should be reviewed quarterly.
- IAM policy should be reusable and documented.

## How the Class Topic Applies

Students use the same pattern from the class:

- Identify the business need.
- Convert the need into specific AWS actions.
- Scope the resource to the specific bucket.
- Avoid broad permissions.
- Validate the policy before use.
- Document the access decision.

## Role-Based Responsibilities

| Role | What They Would Do |
|---|---|
| DevOps Engineer | Add policy review into Git workflow or pipeline access process. |
| Cloud Engineer | Create and manage IAM policy standards for workload accounts. |
| SRE | Ensure support access helps incident response without creating production risk. |
| Security Engineer | Review least-privilege policy and audit CloudTrail activity. |
| Platform Team | Provide reusable IAM templates for common access patterns. |

---

# 20. Instructor Tips

## Teaching Tips

- Use simple analogies first, then move to AWS policy JSON.
- Keep reminding students that IAM is both a security topic and troubleshooting topic.
- Do not overwhelm students with every IAM policy type at once.
- Teach users, groups, policies, and least privilege first, *then* roles/STS — roles land much better once students have the policy mental model.
- Keep federation/SSO and OIDC at the awareness/preview level here; they are configured for real in Week 9 (CI/CD) and Week 17 (Landing Zones).

## Pacing Tips

- Do not spend more than 20 minutes on IAM theory before showing a policy.
- Use the S3 example because it clearly shows bucket vs object permissions.
- Keep the demo short enough that students have time to practice.
- Leave at least 10 minutes for troubleshooting discussion.

## Lab Support Tips

When students get stuck, ask:

1. What identity are you using?
2. What action are you trying to perform?
3. What resource are you trying to access?
4. Does the policy allow that action?
5. Is the ARN correct?
6. Is there a deny?

## Helping Struggling Students

Give them this simple structure:

```text
Effect: Allow or Deny
Action: What can be done
Resource: Where it can be done
```

Have them read policies one line at a time.

## Challenging Advanced Students

Ask advanced students to:

- Add conditions to limit access by IP or MFA.
- Create a policy for a specific S3 prefix only.
- Compare identity policy and bucket policy.
- Explain where explicit deny might be useful.

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- What IAM does
- Authentication vs authorization
- IAM users, groups, roles, and policies
- The difference between a role's trust policy and permission policy
- Why temporary credentials (STS) are safer than long-lived access keys
- How EC2 instance profiles and OIDC keyless CI/CD avoid stored keys (at awareness level)
- Least privilege and policy evaluation order
- Explicit deny
- IAM policy JSON structure and a basic `Condition` block
- S3 bucket ARN vs object ARN
- Why broad permissions are risky

## Students Should Be Able to Build or Configure

- A valid IAM JSON policy
- A customer-managed IAM policy
- A least-privilege S3 read-only policy
- An IAM role with a trust policy and a permission policy
- An `aws sts assume-role` call that returns temporary credentials
- A policy simulation test
- A basic policy analysis document

## Students Should Be Able to Troubleshoot

- Missing `s3:ListBucket`
- Wrong S3 resource ARN
- A trust policy that names the wrong principal (assume-role `AccessDenied`)
- Bad JSON policy syntax
- Incorrect AWS CLI profile
- Access denied caused by missing permission
- Overly broad permission risk

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- Confirm students understand authentication vs authorization.
- Confirm students can read basic IAM policy JSON.
- Confirm students understand `Action`, `Resource`, and `Effect`.
- Confirm students know why `*:*` style access is risky.
- Confirm students completed or understood the lab.
- Review the missing `s3:ListBucket` troubleshooting scenario.
- Confirm students created and assumed a role and saw temporary credentials.
- Assign homework.
- Preview Class 2: secrets management with KMS, Secrets Manager, and Parameter Store, plus governance.

## Student Checklist Before Leaving Class

Students should have:

- Created a local lab folder
- Created `s3-readonly-policy.json`
- Validated JSON syntax
- Created or reviewed an IAM policy
- Simulated allowed and denied actions
- Completed policy analysis notes
- Understood cleanup steps
- Written down questions for Class 2

## Items to Verify Before Moving to Class 2

Students should be comfortable with:

- IAM policy structure
- Least privilege and policy evaluation order
- S3 read-only policy pattern
- IAM roles, trust policies, and `sts:AssumeRole`
- Difference between bucket and object permissions
- Basic `AccessDenied` troubleshooting (including trust-policy assume failures)

Class 2 then builds on the role model to cover:

- Why secrets must never live in code, Git, images, or plain config
- AWS KMS and encryption at rest/in transit
- AWS Secrets Manager and Systems Manager Parameter Store
- How a workload role retrieves secrets at runtime (`secretsmanager:GetSecretValue` + `kms:Decrypt`)
- Governance: tagging, auditing, and least-privilege secret access

---

## Class Artifacts & Validation

The runnable, on-disk artifacts this class uses live in
[`labs/security-automation/`](../../labs/security-automation/). They turn the IAM
concepts taught above — least privilege, wildcard/`NotAction` grants, policy evaluation
order, and the `Deny` guardrail / SCP pattern — into real files an instructor can lint,
test, and gate a pipeline on. Every row below was run in this environment; reproduce them
all at once with `cd labs/security-automation && ./validate.sh` (24 pass, 0 deferred).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/security-automation/solution/iam_policy_audit.py` | python | IAM least-privilege auditor: flags wildcard `Action`/`Resource` and `NotAction`/`NotResource`, ignores `Deny` guardrails; CLI exits non-zero to fail a pipeline | `PYTHONPATH=solution python3 -m unittest discover -s tests` | PASS (14 tests, OK) |
| 2 | `labs/security-automation/solution/policies/iam/bad-policy.json` | json | Over-broad policy fixture (`*`/`s3:*` + `NotAction`) — the "what not to write" example | `python3 -m json.tool < …` then `python3 solution/iam_policy_audit.py …/bad-policy.json` | PASS (well-formed; auditor reports 6 findings, exit 1) |
| 3 | `labs/security-automation/solution/policies/iam/good-policy.json` | json | Least-privilege reference policy (named ARNs, scoped actions, region-pinned `Deny` guardrail) | `python3 solution/iam_policy_audit.py …/good-policy.json` | PASS (0 findings, exit 0) |
| 4 | `labs/security-automation/solution/policies/scp/deny-leave-org.json` | json | Org-root **SCP guardrail** illustrating the "deny overrides allow" / boundary-deny evaluation order taught in this class | `python3 -m json.tool < …` | PASS (well-formed; reference artifact, not scanned) |
| 5 | `labs/security-automation/solution/policies/opa/s3_deny_public.rego` | rego | Policy-as-code expression of the same least-privilege rule (deny public principal), with passing/failing test fixtures | `opa test solution/policies/opa/s3_deny_public.rego solution/policies/opa/s3_deny_public_test.rego` | PASS (opa 0.68.0, 5/5 tests) |

> **Live-op status (honest):** these gates are **static / offline** — bash + python +
> `opa` against fixture files, no AWS account and no real IAM apply. The class also walks
> through `aws iam`/`sts:AssumeRole` and IAM Access Analyzer against a live account, but
> those steps are **instructor-run in a real account**, not captured as committed
> evidence in this repo (no `LIVE-*.txt` exists for this lab). Score accordingly.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the IAM auditor (`*.py`), policy fixtures (`*.json`), SCP guardrail, and OPA policy (`*.rego`) are real files, not fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (table above; `./validate.sh` → 24 pass / 0 deferred in this env).
- [x] Lab has **starter** (intentionally incomplete `TODO(student)` gaps) and **solution** (reference) versions — see `labs/security-automation/{starter,solution}/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** provided and idempotent — and trivially so: the lab provisions **no** cloud or local resources ($0, offline), so cleanup is just removing `__pycache__`/temp files and `git checkout -- starter/`.
- [x] **Instructor answer key** exists — `labs/security-automation/solution/` plus the README "Instructor answer key" section (resource-wildcard nuance, `Deny`-ignored, severity mapping).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `starter/` `TODO` gaps and the `arn:aws:s3:::my-bucket/*` false-positive trap are reproducible faults (README Troubleshooting table).
- [x] **Expected outputs** are shown for the auditor on `good`/`bad` policies (README "Expected results").
- [x] **Cost & security warnings** present — README Security/Cost sections (least privilege, wildcards-in-`Deny`-are-fine, never commit real secrets).
- [x] **Cross-references** to the module repo and prior/next weeks are correct (Week 4/5 prerequisites; reused in Week 19 as CI gates — verified).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (`ls`-verified).
- [ ] **Live IAM operation captured as committed evidence** — NOT done: `sts:AssumeRole` and Access Analyzer are instructor-run against a real account; no `LIVE-*.txt` is committed for this lab. This is the gap that keeps the class out of the 8–10 band.
