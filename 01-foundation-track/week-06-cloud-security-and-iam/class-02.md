# Week 6: AWS IAM and Security Foundations
> **▶ Runnable lab for this class:** [`labs/security-automation/`](../../labs/security-automation/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package

**Week:** 6  
**Class:** Class 6.2  
**Class Title:** Class 6.2: Securing Applications with KMS, Secrets Manager, and Governance  
**Track:** Unified DevOps · Cloud · SRE Track  
**Duration:** 3 hours  
**Course:** Enterprise DevOps, Cloud Engineering, and SRE Program  
**Primary Cloud:** AWS  
**Secondary Cloud Exposure:** Azure and GCP

---

# 1. Class Overview

## Class Title

**Class 6.2: Securing Applications with KMS, Secrets Manager, and Governance**

## Class Purpose

This class teaches students how applications should securely access sensitive values such as database passwords, API keys, tokens, and service credentials in AWS. Students will learn why secrets should not be stored in code, Git repositories, container images, Terraform files, Slack messages, or plain text configuration files.

The class focuses on the practical relationship between:

- IAM permissions
- AWS KMS encryption
- AWS Secrets Manager
- Systems Manager Parameter Store
- Runtime secret retrieval
- Common access-denied troubleshooting

## How This Class Connects to the Overall Course

This class builds directly on **Class 6.1 (IAM Users, Groups, Policies, Roles, and Least Privilege)**. In Class 1 you learned how IAM decides who can do what, and — critically — how **IAM roles** issue temporary credentials so workloads never store long-lived keys. This class applies that same role model to **secrets**: how an application uses its role to fetch a database password or API key at runtime, encrypted by KMS.

Prerequisites are intentionally light: you only need Class 6.1 (IAM and roles), Week 4 (AWS account/CLI basics), and basic JSON. You do **not** need scripting, CI/CD, Docker, Kubernetes, Helm, or Terraform yet — those come later and are referenced here only as **forward previews**, not requirements:

- **Week 9 (CI/CD)** — pipelines will retrieve build/deploy secrets using OIDC-assumed roles (previewed below).
- **Week 10 (Docker)** — why baking secrets into container images is dangerous (previewed below).
- **Week 11-13 (Kubernetes/Helm)** — Kubernetes Secrets are only base64-encoded by default; external secrets integrations pull from Secrets Manager (previewed below).
- **Week 14-15 (Terraform)** — never commit secrets in `.tfvars`; reference them from a secret store (previewed below).
- **Week 17 (Landing Zones)** and **Week 18 (Cloud Operations)** — account-level governance, guardrails, and audit at scale.

When you see Docker / Kubernetes / Terraform mentioned in this class, treat them as "here is where this will matter later," not as something you should already know.

## What Students Will Build, Analyze, or Practice

Students will:

- Create a test secret in AWS Secrets Manager
- Retrieve a secret using AWS CLI
- Understand required IAM permissions
- Compare Secrets Manager and Parameter Store
- Review how KMS protects secrets
- Troubleshoot access errors involving `secretsmanager:GetSecretValue` and `kms:Decrypt`
- Document a secrets management recommendation for an application team

---

# 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why secrets should not be stored in source code, Git history, container images, or plain text files.
2. **Compare** AWS Secrets Manager and Systems Manager Parameter Store for application configuration and sensitive values.
3. **Describe** how IAM permissions and KMS encryption work together when retrieving secrets.
4. **Configure** a test secret in AWS Secrets Manager using safe lab values.
5. **Retrieve** a secret securely using AWS CLI.
6. **Validate** whether the correct AWS region, secret name, and IAM identity are being used.
7. **Troubleshoot** common secret access errors such as missing `GetSecretValue` or `kms:Decrypt`.
8. **Document** a basic cloud secrets management recommendation for an application environment.

---

# 3. Prerequisites Students Should Already Know

## Required Prior Concepts

Students should already understand (all from Class 6.1 and Week 4):

- Basic AWS Console navigation
- AWS CLI profiles and regions
- IAM users, **roles, trust policies, and `sts:AssumeRole`** (taught in Class 6.1)
- IAM policies and least privilege (taught in Class 6.1)
- Basic JSON structure
- Linux terminal usage
- Environment variables
- Basic application configuration concepts
- Why credentials and API keys are sensitive

> Note: You do **not** need Docker, Kubernetes, Helm, Terraform, scripting, or CI/CD for this class. Where those appear, they are forward previews of where secrets management will matter, not prerequisites.

## Required Tools Already Installed

Students should have:

- VS Code
- Terminal or shell
- AWS CLI v2
- Git
- Browser access to AWS Console
- Optional: Python 3 for discussion or extension examples

## Required AWS Account or Access

Students need access to an AWS lab account with permission to use:

- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- AWS KMS read/list permissions
- IAM read-only access, if possible
- CloudTrail event history read access, if available

For a controlled classroom, the instructor can provide a pre-created lab IAM role.

## Files, Repos, or Sample Code Needed

No full repository is required for the main lab.

Optional instructor sample file:

```bash
secret-demo/
├── README.md
├── get-secret.sh
└── sample-policy.json
```

Example `get-secret.sh`:

```bash
#!/usr/bin/env bash

SECRET_ID="dev/student-app/db-credentials"
AWS_REGION="us-east-1"

aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text
```

---

# 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Secret | A sensitive value such as a password, token, API key, or private key | A database password used by an application should be treated as a secret |
| IAM | AWS identity and access management system | Controls who or what can access AWS resources |
| IAM Role | Temporary identity that can be assumed by a user, application, EC2 instance, Lambda function, or pipeline | Applications should use roles instead of hardcoded access keys |
| IAM Policy | JSON document that allows or denies actions | A policy may allow `secretsmanager:GetSecretValue` for one specific secret |
| Least Privilege | Granting only the permissions needed | An app that reads one secret should not have access to all secrets |
| AWS Secrets Manager | AWS service for storing, retrieving, and rotating secrets | Commonly used for database credentials, API keys, and application credentials |
| Systems Manager Parameter Store | AWS service for storing configuration values and simple secure parameters | Often used for app configuration such as `/dev/app/log-level` or small secrets |
| KMS | AWS Key Management Service | Encrypts secrets and helps control who can decrypt them |
| Encryption at Rest | Encrypting stored data | Secrets Manager stores secrets encrypted |
| Encryption in Transit | Encrypting data while it moves across a network | TLS protects secret retrieval over HTTPS |
| Secret Rotation | Changing secrets on a defined schedule or event | Rotating database passwords reduces long-term credential risk |
| AccessDeniedException | AWS error showing the identity lacks permission | Common when an app role cannot read or decrypt a secret |
| Secret ARN | Unique AWS resource identifier for a secret | IAM policies often reference secret ARNs |
| Resource Policy | Policy attached to a resource | A secret can have a policy controlling who may access it |
| Customer-Managed KMS Key | KMS key created and controlled by the customer | Provides more control but requires explicit decrypt permissions |

---

# 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | Used to create and inspect secrets visually |
| AWS CLI | Used to retrieve secrets and validate access from the command line |
| Terminal | Used to run AWS CLI commands and scripts |
| VS Code | Used to view sample scripts, JSON policies, and notes |
| JSON | Used for secret values and IAM policies |
| IAM Policy Simulator, optional | Helps test whether a user or role has required permissions |
| CloudTrail, optional preview | Helps show that secret access is auditable |
| Git, discussion only | Used to explain why secrets must not be committed to source control |

---

# 6. AWS Services Used

| AWS Service | How It Connects to the Class |
|---|---|
| AWS Secrets Manager | Main service used to store and retrieve sensitive application secrets |
| AWS Systems Manager Parameter Store | Compared with Secrets Manager for configuration and secure strings |
| AWS KMS | Encrypts secrets and controls decrypt permissions |
| AWS IAM | Controls which users, roles, applications, or pipelines can read secrets |
| AWS STS | Provides temporary credentials when roles are assumed |
| AWS CloudTrail | Records secret access and AWS API activity for audit purposes |
| Amazon EC2, concept only | Example workload that may need to retrieve secrets at runtime |
| AWS Lambda, concept only | Example serverless workload that may retrieve secrets |
| Amazon EKS, concept only | Example Kubernetes workload where pods may retrieve secrets using an approved integration |

---

# 7. Azure and GCP Comparison Notes

Keep this short during class. The main teaching flow remains AWS-first.

| Need | AWS | Azure | GCP |
|---|---|---|---|
| Store secrets | Secrets Manager | Azure Key Vault | Secret Manager |
| Store config values | Parameter Store | App Configuration or Key Vault | Secret Manager or Runtime Config alternatives |
| Manage encryption keys | KMS | Key Vault keys | Cloud KMS |
| Audit secret access | CloudTrail | Azure Activity Log and diagnostic logs | Cloud Audit Logs |
| Assign workload identity | IAM roles | Managed identities | Service accounts and workload identity |

Teaching point:

The names differ, but the core pattern is similar:

```text
Workload identity + permission + secret store + encryption + audit log
```

---

# 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:15 | Opening scenario: hardcoded database password causes a production incident |
| 0:15 to 0:35 | Review IAM, least privilege, roles, and policy permissions |
| 0:35 to 1:00 | Explain cloud secrets, unsafe storage locations, and runtime retrieval |
| 1:00 to 1:25 | Explain AWS KMS, encryption at rest, encryption in transit, and key ownership |
| 1:25 to 1:35 | Break |
| 1:35 to 2:00 | Compare Secrets Manager and Systems Manager Parameter Store |
| 2:00 to 2:25 | Instructor demo: create and retrieve a secret |
| 2:25 to 2:50 | Student lab: store and retrieve secrets securely |
| 2:50 to 3:00 | Wrap-up, knowledge check, and homework briefing |

---

# 9. Instructor Lesson Plan

## 0:00 to 0:15: Opening Scenario

Start with a realistic incident:

> “A developer committed a database password into a Git repository. The repo was later shared with a contractor. Two weeks later, the production database showed suspicious login attempts.”

Explain that the technical issue is not only the exposed password. The operational issues are:

- Git history preserves deleted secrets
- Many people may have cloned the repository
- The team may not know who accessed the secret
- The password must be rotated
- The incident must be documented
- The application may go down if rotation is not coordinated

Pause and ask:

> “Where have you seen teams accidentally place secrets?”

Expected answers:

- `.env` files
- Git repos
- Dockerfiles
- CI/CD variables without protection
- Kubernetes YAML files
- Terraform variables
- Slack messages
- Tickets
- Screenshots

## 0:15 to 0:35: IAM Recall (from Class 6.1)

This is a quick recall, not a re-teach — students built roles and assumed them last class. Reconnect:

- IAM controls access (who can do what)
- **Roles** are preferred for workloads; they issue temporary credentials via STS (Class 6.1)
- A role's **trust policy** says who may assume it; its **permission policy** says what it can do
- Policies define allowed actions
- Least privilege is the target
- Secret access should be narrow — a workload role should read only its own secret

Show a simple IAM permission:

```json
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:dev/student-app/db-credentials-*"
}
```

Teaching tip:

Do not over-teach IAM policy syntax here. Students learned roles and policies in Class 6.1. Focus on how IAM controls secret access, and connect it to the role they assumed last class: that same role would carry a `secretsmanager:GetSecretValue` permission to read a secret.

Transition:

> “IAM decides whether the workload can ask for the secret. KMS may also decide whether the workload can decrypt it.”

## 0:35 to 1:00: Cloud Secrets

Explain what counts as a secret:

- Passwords
- API keys
- OAuth tokens
- Private keys
- Database credentials
- Webhook tokens
- Third-party service credentials

Explain unsafe locations:

```text
Bad places for secrets:
- Source code
- Git repositories
- Docker images
- Plain text files
- Terraform tfvars committed to Git
- Kubernetes manifests committed to Git
- Chat messages
- Screenshots
- Shared spreadsheets
```

Explain safer approach:

```text
Store secret in secret manager.
Grant workload permission using IAM.
Retrieve secret at runtime.
Audit access.
Rotate when needed.
```

Pause for question:

> “Why is deleting a secret from Git not enough?”

Expected answer:

Git history can still contain the secret.

## 1:00 to 1:25: KMS and Encryption

Explain KMS in simple terms:

> “KMS is not where you store your database password. KMS manages encryption keys that protect sensitive data.”

Cover:

- Secrets Manager encrypts secrets
- Parameter Store SecureString can use KMS
- AWS-managed keys are simpler
- Customer-managed keys give more control
- Customer-managed keys may require explicit `kms:Decrypt`

Simple explanation:

```text
Secrets Manager stores the secret.
KMS protects the encrypted secret.
IAM controls who can request the secret.
KMS permissions control who can decrypt the secret.
```

Common misconception:

> “If I have Secrets Manager permission, I always can read the secret.”

Correction:

If the secret uses a customer-managed KMS key, the identity may also need `kms:Decrypt`.

## 1:25 to 1:35: Break

Use the break to verify demo resources and AWS region.

## 1:35 to 2:00: Secrets Manager vs Parameter Store

Explain the practical difference.

| Use Case | Better Fit |
|---|---|
| Database password with rotation | Secrets Manager |
| Third-party API key | Secrets Manager |
| Simple app config value | Parameter Store |
| Feature flag-like configuration | Parameter Store |
| Hierarchical config such as `/dev/app/url` | Parameter Store |
| Secret with managed rotation | Secrets Manager |

Beginner-friendly summary:

> “Secrets Manager is usually better for sensitive credentials that may need rotation. Parameter Store is useful for configuration values and simple secure parameters.”

Cost note:

Secrets Manager may have a recurring cost per secret. Parameter Store standard parameters are often used for lightweight configuration. Students should clean up Secrets Manager lab resources after class.

## 2:00 to 2:25: Instructor Demo

Perform the demo from Section 12.

Instructor should explain:

- Secret naming convention
- Secret value format
- AWS region
- CLI retrieval
- IAM policy needed
- KMS decrypt issue
- Cleanup expectations

## 2:25 to 2:50: Student Lab

Students complete the lab from Section 13.

Instructor should walk the room or monitor chat for:

- Wrong AWS region
- Missing permissions
- AWS CLI profile errors
- Students using real passwords
- Students forgetting cleanup

## 2:50 to 3:00: Wrap-Up

Ask three recap questions:

1. What AWS service stores secrets?
2. What AWS service manages encryption keys?
3. What IAM action is usually needed to retrieve a secret?

Preview Week 7 and beyond:

> “You have now completed the security foundation: identities, roles, least privilege, and secrets. Next week (Week 7) you move into EC2, storage, and databases — the workloads that will *use* the roles and secrets you just learned. The governance side of this — CloudTrail audit at scale, tagging standards, and guardrails — is expanded in Week 17 (Landing Zones) and Week 18 (Cloud Operations).”

---

# 10. Instructor Lecture Notes

## Opening Talking Point

“Security is not something we add only at the end. In cloud engineering and DevOps, security is part of how we deliver and operate applications. Secrets management is one of the most common areas where beginner teams make mistakes.”

## Why Secrets Management Matters

Applications need sensitive values to connect to databases, APIs, message queues, third-party systems, and internal platforms. If those values are stored directly in code or configuration files, they become easy to leak.

A leaked secret can lead to:

- Unauthorized database access
- Cloud resource misuse
- Data exposure
- Unexpected cloud cost
- Incident response effort
- Credential rotation pressure
- Loss of trust with security and business teams

## Real-World Example

A team builds a small internal API and places the database password in a `.env` file. The file is accidentally committed to Git. Later, the repo is made visible to another team. Even if the password is removed in a later commit, the secret still exists in Git history.

The fix is not only “delete the line.” The team must:

- Rotate the database password
- Search Git history
- Review access logs
- Identify who may have cloned the repo
- Update the application configuration
- Update CI/CD or runtime secret injection
- Write an incident note
- Prevent recurrence with secret scanning

## IAM, KMS, and Secrets Manager Working Together

Students often mix up these services. Keep this explanation simple:

- IAM answers: “Who is allowed?”
- Secrets Manager answers: “Where is the secret stored?”
- KMS answers: “How is it encrypted and decrypted?”
- CloudTrail answers: “Who did what, and when?”

Talk track:

> “When an app reads a secret, the app is not logging in with a username and password. It should use a role. That role has a policy. The policy allows access to a specific secret. If the secret is encrypted with a customer-managed KMS key, the role also needs decrypt permission.”

## Where This Goes Next (Forward Previews — Not Required Today)

Students do not need these tools yet, but it helps to name where secrets management will show up later in the track. Frame each as "remember this when you get there":

- **CI/CD (Week 9):** A pipeline should not store `AWS_ACCESS_KEY_ID`. Using the **OIDC keyless** pattern from Class 6.1, the pipeline assumes a role and that role has `secretsmanager:GetSecretValue` for the specific secret it needs. Distinguish **build-time** secrets (signing keys, registry creds) from **runtime** secrets (the app's DB password, fetched by the workload itself, not the pipeline).
- **Docker (Week 10):** Never `COPY` a `.env` or bake a password into an image layer — image layers are inspectable and cached. Inject secrets at runtime instead.
- **Kubernetes / Helm (Week 11-13):** Kubernetes `Secret` objects are only **base64-encoded**, not encrypted, by default. Enterprises enable encryption at rest and often use an **external secrets** integration that pulls from AWS Secrets Manager into the cluster.
- **Terraform (Week 14-15):** Never commit secrets in `.tfvars` or state. Reference a `data` source for the secret, or inject it from the secret store at apply time; remember Terraform **state can contain secret values**, so the state backend must be encrypted and access-controlled.

The common thread is identical to Class 6.1: **workload identity (a role) + a narrow permission + a secret store + encryption + an audit trail.**

## Secrets Manager vs Parameter Store

Secrets Manager is usually chosen when the value is highly sensitive and may require rotation. Parameter Store is often chosen for structured application configuration or simple secure strings.

Do not present one as always better. Teach students to choose based on requirement.

Example:

- `/prod/payment-api/db-password`: Secrets Manager
- `/prod/payment-api/log-level`: Parameter Store
- `/prod/payment-api/external-api-token`: Secrets Manager
- `/dev/payment-api/max-retries`: Parameter Store

## Common Misconceptions

| Misconception | Correction |
|---|---|
| “Environment variables are always safe.” | They can leak through logs, process inspection, crash dumps, or deployment manifests |
| “Deleting a secret from Git fixes it.” | Git history may still contain the value |
| “Any app in AWS can read Secrets Manager.” | The app identity needs IAM permission |
| “Secrets Manager and KMS are the same thing.” | Secrets Manager stores secrets. KMS manages encryption keys |
| “Admin access is fine for lab apps.” | Least privilege should be practiced early |
| “Only security engineers need to care about secrets.” | DevOps, Cloud Engineers, and SREs all handle production risk |

## Enterprise Context

In enterprise environments, secrets management usually involves:

- Approved secret storage services
- Naming standards
- Environment separation
- Access review
- Secret rotation
- Audit logging
- Break-glass procedures
- CI/CD integration
- Kubernetes integration
- Security scanning
- Documentation

A DevOps Engineer may secure pipeline variables.  
A Cloud Engineer may design IAM and KMS access.  
An SRE may investigate secret-related incidents or failed runtime access.

---

# 11. Whiteboard Explanation

## Simple Diagram: Secure Runtime Secret Access

```text
Application Runtime
EC2 / Lambda / EKS Pod / CI Job
        |
        | Uses IAM role or temporary credentials
        v
AWS IAM
        |
        | Allows secretsmanager:GetSecretValue
        v
AWS Secrets Manager
        |
        | Secret is encrypted
        v
AWS KMS
        |
        | Allows kms:Decrypt if required
        v
Application receives secret at runtime
```

## Step-by-Step Flow

1. The application starts.
2. The application uses its assigned IAM role.
3. The application calls Secrets Manager.
4. IAM checks whether the role can call `GetSecretValue`.
5. Secrets Manager retrieves the encrypted secret.
6. KMS decrypts the secret if the role is allowed to use the key.
7. The application receives the secret at runtime.
8. CloudTrail can record the AWS API activity.

## What Each Component Means

| Component | Meaning |
|---|---|
| Application Runtime | The workload that needs the secret |
| IAM Role | The identity assigned to the workload |
| IAM Policy | The permission that allows or denies access |
| Secrets Manager | The storage location for sensitive values |
| KMS | The encryption key system |
| CloudTrail | The audit trail for API activity |

## Enterprise Version of the Diagram

```text
Application Team
      |
      | Requests secret access through approved workflow
      v
Cloud Platform / Security Review
      |
      | Creates or approves IAM role and secret policy
      v
Workload Runtime
      |
      | Assumes IAM role
      v
Secrets Manager
      |
      | Uses approved KMS key
      v
Application gets secret
      |
      v
CloudTrail records access
      |
      v
Security / SRE / Cloud team can audit and troubleshoot
```

## Instructor Emphasis

Tell students:

> “The goal is not only to make the app work. The goal is to make the app work securely, repeatably, and audibly.”

---

# 12. Instructor Demo Script

## Demo Title

**Create and Retrieve an Application Secret Securely in AWS**

## Demo Objective

Demonstrate how to create a lab secret in AWS Secrets Manager, retrieve it with AWS CLI, and explain the IAM and KMS permissions required.

## Required Setup

Instructor needs:

- AWS lab account
- AWS CLI configured
- Region selected, preferably `us-east-1`
- Permission to create and delete Secrets Manager secrets
- Permission to view or explain KMS key usage
- Optional CloudTrail read access

Verify identity:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDAEXAMPLE",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/instructor"
}
```

Verify region:

```bash
aws configure get region
```

Expected output:

```text
us-east-1
```

## Demo Step 1: Create a Secret Using AWS CLI

Use lab-only fake credentials.

```bash
aws secretsmanager create-secret \
  --name dev/demo-app/db-credentials \
  --description "Demo database credentials for Week 6 Class 2" \
  --secret-string '{"username":"demo_user","password":"DoNotUseInProduction123!"}' \
  --tags Key=Application,Value=demo-app Key=Environment,Value=dev Key=Owner,Value=instructor Key=ManagedBy,Value=manual \
  --region us-east-1
```

Expected output:

```json
{
  "ARN": "arn:aws:secretsmanager:us-east-1:123456789012:secret:dev/demo-app/db-credentials-AbCdEf",
  "Name": "dev/demo-app/db-credentials",
  "VersionId": "example-version-id"
}
```

What to explain:

- The secret has a path-like name.
- The value is JSON.
- Tags help ownership and governance.
- This is fake data for lab purposes.
- Never use a real password in classroom examples.

## Demo Step 2: Retrieve the Secret

```bash
aws secretsmanager get-secret-value \
  --secret-id dev/demo-app/db-credentials \
  --region us-east-1
```

Expected output includes:

```json
{
  "Name": "dev/demo-app/db-credentials",
  "SecretString": "{\"username\":\"demo_user\",\"password\":\"DoNotUseInProduction123!\"}"
}
```

Cleaner output:

```bash
aws secretsmanager get-secret-value \
  --secret-id dev/demo-app/db-credentials \
  --query SecretString \
  --output text \
  --region us-east-1
```

Expected output:

```json
{"username":"demo_user","password":"DoNotUseInProduction123!"}
```

What to explain:

- The secret is retrieved at runtime.
- In real applications, avoid printing secrets to logs.
- The CLI output is for demonstration only.

## Demo Step 3: Show Required IAM Permission

Show this sample policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlySpecificDemoSecret",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:dev/demo-app/db-credentials-*"
    }
  ]
}
```

What to explain:

- This allows only one secret.
- It does not allow reading every secret.
- It follows least privilege better than `Resource: "*"`.

## Demo Step 4: Explain KMS Permission

If using a customer-managed KMS key, show this example:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDecryptForSpecificKey",
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/example-key-id"
    }
  ]
}
```

What to explain:

- AWS-managed keys are simpler for labs.
- Customer-managed keys give more control.
- More control also means more permission troubleshooting.

## Demo Step 5: Compare Parameter Store

Create a secure string:

```bash
aws ssm put-parameter \
  --name "/dev/demo-app/api-key" \
  --value "fake-api-key-123" \
  --type "SecureString" \
  --description "Demo secure parameter for Week 6 Class 2" \
  --region us-east-1
```

Retrieve it:

```bash
aws ssm get-parameter \
  --name "/dev/demo-app/api-key" \
  --with-decryption \
  --region us-east-1
```

Expected output:

```json
{
  "Parameter": {
    "Name": "/dev/demo-app/api-key",
    "Type": "SecureString",
    "Value": "fake-api-key-123",
    "Version": 1
  }
}
```

What to explain:

- Parameter Store works well for structured configuration.
- SecureString values can be encrypted.
- Secrets Manager has stronger secret lifecycle and rotation features.

## Common Demo Failure Points

| Failure | Likely Cause | Recovery |
|---|---|---|
| `AccessDeniedException` | Instructor role lacks permission | Use correct lab role or pre-create secret |
| `ResourceExistsException` | Secret name already exists | Use a unique name or delete old secret |
| `ResourceNotFoundException` | Wrong secret name or region | Check `--region` and secret name |
| CLI returns wrong account | Wrong AWS profile | Run `aws sts get-caller-identity` |
| Parameter creation fails | Missing SSM permission | Skip Parameter Store demo or use console |
| Secret scheduled for deletion | Same name was deleted recently | Use a new name with suffix |

## Cleanup Steps

Delete demo secret:

```bash
aws secretsmanager delete-secret \
  --secret-id dev/demo-app/db-credentials \
  --force-delete-without-recovery \
  --region us-east-1
```

Delete demo parameter:

```bash
aws ssm delete-parameter \
  --name "/dev/demo-app/api-key" \
  --region us-east-1
```

Security warning:

For real production secrets, do not use `--force-delete-without-recovery` casually. It is acceptable here only because this is a disposable lab secret.

Cost warning:

Secrets Manager can create recurring cost if lab secrets are left behind. Always clean up classroom secrets.

---

# 13. Student Lab Manual

## Lab Title

**Store and Retrieve an Application Secret Using AWS Secrets Manager**

## Lab Objective

You will create a lab secret in AWS Secrets Manager, retrieve it using AWS CLI, compare it with Parameter Store, and validate common troubleshooting checks.

## Estimated Time

25 minutes

## Student Prerequisites

Before starting, confirm you have:

- AWS CLI installed
- AWS credentials configured
- AWS Console access
- Permission to use Secrets Manager
- Region selected, preferably `us-east-1`

Run:

```bash
aws sts get-caller-identity
```

Expected output should show your AWS account and identity.

## Architecture or Workflow Overview

```text
Student Terminal
      |
      | AWS CLI command
      v
AWS Secrets Manager
      |
      | Secret encrypted by KMS
      v
Secret value returned to terminal
```

## Step 1: Set Your Region

```bash
export AWS_REGION="us-east-1"
```

Validate:

```bash
echo $AWS_REGION
```

Expected output:

```text
us-east-1
```

## Step 2: Confirm AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "example",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student"
}
```

Write down:

- Account ID
- IAM user or role
- Region you are using

## Step 3: Create a Lab Secret

Use only fake lab values.

Replace `studentname` with your name or initials.

```bash
aws secretsmanager create-secret \
  --name dev/studentname-app/db-credentials \
  --description "Student lab secret for Week 6 Class 2" \
  --secret-string '{"username":"student_user","password":"ChangeMe123!"}' \
  --tags Key=Application,Value=student-app Key=Environment,Value=dev Key=Owner,Value=studentname Key=ManagedBy,Value=manual \
  --region $AWS_REGION
```

Expected output:

```json
{
  "ARN": "arn:aws:secretsmanager:us-east-1:123456789012:secret:dev/studentname-app/db-credentials-AbCdEf",
  "Name": "dev/studentname-app/db-credentials",
  "VersionId": "example-version-id"
}
```

## Step 4: Retrieve the Secret

```bash
aws secretsmanager get-secret-value \
  --secret-id dev/studentname-app/db-credentials \
  --region $AWS_REGION
```

Expected output includes:

```json
"SecretString": "{\"username\":\"student_user\",\"password\":\"ChangeMe123!\"}"
```

## Step 5: Retrieve Only the Secret String

```bash
aws secretsmanager get-secret-value \
  --secret-id dev/studentname-app/db-credentials \
  --query SecretString \
  --output text \
  --region $AWS_REGION
```

Expected output:

```json
{"username":"student_user","password":"ChangeMe123!"}
```

Important:

Do not copy this output into Git, screenshots, public notes, or chat messages in real work.

## Step 6: Describe the Secret

```bash
aws secretsmanager describe-secret \
  --secret-id dev/studentname-app/db-credentials \
  --region $AWS_REGION
```

Look for:

- Name
- ARN
- KmsKeyId, if present
- Tags
- CreatedDate

## Step 7: Optional Parameter Store Comparison

Create a secure parameter:

```bash
aws ssm put-parameter \
  --name "/dev/studentname-app/api-key" \
  --value "fake-api-key-123" \
  --type "SecureString" \
  --description "Student secure parameter for Week 6 Class 2" \
  --region $AWS_REGION
```

Retrieve it:

```bash
aws ssm get-parameter \
  --name "/dev/studentname-app/api-key" \
  --with-decryption \
  --region $AWS_REGION
```

Expected output:

```json
{
  "Parameter": {
    "Name": "/dev/studentname-app/api-key",
    "Type": "SecureString",
    "Value": "fake-api-key-123",
    "Version": 1
  }
}
```

## Validation Checklist

Before finishing the lab, verify:

- [ ] I confirmed my AWS identity using `aws sts get-caller-identity`
- [ ] I created a lab secret using fake values only
- [ ] I retrieved the secret using AWS CLI
- [ ] I identified the `SecretString`
- [ ] I described the secret metadata
- [ ] I understand which IAM action allows secret retrieval
- [ ] I understand that KMS may require decrypt permission
- [ ] I cleaned up lab resources

## Troubleshooting Tips

| Problem | What to Check |
|---|---|
| `AccessDeniedException` | Your IAM user or role may not have Secrets Manager permission |
| `ResourceNotFoundException` | Secret name or AWS region may be wrong |
| `UnrecognizedClientException` | AWS credentials may be invalid or expired |
| `You must specify a region` | Set `AWS_REGION` or use `--region` |
| `ParameterAlreadyExists` | Use a unique parameter name |
| Secret creation succeeds but retrieval fails | Check IAM policy and KMS permissions |

## Cleanup Steps

Delete the secret:

```bash
aws secretsmanager delete-secret \
  --secret-id dev/studentname-app/db-credentials \
  --force-delete-without-recovery \
  --region $AWS_REGION
```

Delete optional parameter:

```bash
aws ssm delete-parameter \
  --name "/dev/studentname-app/api-key" \
  --region $AWS_REGION
```

Verify deletion:

```bash
aws secretsmanager describe-secret \
  --secret-id dev/studentname-app/db-credentials \
  --region $AWS_REGION
```

Expected result after deletion may show an error or deletion status.

## Reflection Questions

1. Why is Secrets Manager safer than storing a password in Git?
2. What IAM action is needed to retrieve a secret?
3. When might you use Parameter Store instead of Secrets Manager?
4. Why might a secret retrieval fail even if the secret exists?
5. Why should applications avoid printing secrets to logs?

## Optional Challenge Task

Write a small shell script named `get-secret.sh` that retrieves your lab secret.

Example:

```bash
#!/usr/bin/env bash

SECRET_ID="dev/studentname-app/db-credentials"
AWS_REGION="us-east-1"

aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --query SecretString \
  --output text \
  --region "$AWS_REGION"
```

Make it executable:

```bash
chmod +x get-secret.sh
```

Run it:

```bash
./get-secret.sh
```

---

# 14. Troubleshooting Activity

## Incident Title

**Application Cannot Read Database Secret from AWS Secrets Manager**

## Business Impact

The payment API cannot start after deployment because it cannot retrieve its database credentials. The deployment is blocked, and the release team cannot promote the application to the test environment.

## Symptoms

Application logs show:

```text
ERROR Failed to load database credentials
AccessDeniedException: User: arn:aws:sts::123456789012:assumed-role/dev-payment-api-role/app-session is not authorized to perform: secretsmanager:GetSecretValue on resource: prod/payment-api/db-password
```

A second environment shows:

```text
AccessDeniedException: User is not authorized to perform: kms:Decrypt on resource arn:aws:kms:us-east-1:123456789012:key/abcd-1234
```

## Starting Evidence

Students receive:

```text
Secret name expected by app:
prod/payment-api/db-password

App role:
arn:aws:iam::123456789012:role/dev-payment-api-role

AWS region used by app:
us-east-1

IAM policy attached to app role:
Allows secretsmanager:GetSecretValue on arn:aws:secretsmanager:us-east-1:123456789012:secret:dev/payment-api/*

KMS key:
Customer-managed key used by production secret
```

## Student Investigation Steps

Students should investigate:

1. Is the app using the correct IAM role?
2. Is this dev app role trying to access a prod secret?
3. Does the IAM policy allow the correct secret ARN?
4. Is the secret name correct?
5. Is the AWS region correct?
6. Does the role have `secretsmanager:GetSecretValue`?
7. Does the secret use a customer-managed KMS key?
8. Does the role have `kms:Decrypt` for that KMS key?
9. Is there a resource policy on the secret?
10. Is this an access design issue or just a typo?

## Expected Root Cause

There are two likely root causes:

1. The application is using the wrong environment secret. A dev role is trying to access a prod secret.
2. The role does not have `kms:Decrypt` permission for the customer-managed KMS key.

## Correct Resolution

Recommended fix:

- Update the application configuration to reference the dev secret if running in dev.
- Keep dev and prod secrets separate.
- Do not allow dev roles to read prod secrets.
- Add least-privilege permission for the correct secret only.
- Add `kms:Decrypt` only for the required KMS key if needed.

Example corrected policy for dev:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadDevPaymentSecret",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:dev/payment-api/db-password-*"
    },
    {
      "Sid": "DecryptDevSecretKey",
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/dev-key-id"
    }
  ]
}
```

## Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Granting `secretsmanager:*` on all resources | Too broad and violates least privilege |
| Giving app admin access | Fixes symptom but creates major security risk |
| Copying prod secret into dev | Breaks environment separation |
| Hardcoding the password as a quick fix | Reintroduces the original security problem |
| Ignoring KMS permissions | Secret access may still fail |
| Rotating the secret before understanding access | May cause more outages if app config is wrong |

## Instructor Hints

Use hints gradually:

1. “Check which role the application is using.”
2. “Look carefully at `dev` vs `prod` in the secret path.”
3. “Does the policy resource match the secret ARN?”
4. “What extra permission might be required if a customer-managed KMS key is used?”
5. “Would you allow a dev workload to read a prod secret?”

## Preventive Action

Students should recommend:

- Environment-specific secret naming
- IAM policies scoped by environment
- Separate dev/test/prod KMS keys if required
- Secret access reviews
- CI/CD validation for secret references
- Secret scanning in repositories
- Documentation for application secret dependencies
- CloudTrail review for sensitive secret access

---

# 15. Scenario-Based Discussion Questions

## Question 1

A developer wants to store an API key in a `.env` file and commit it to a private Git repository. Is that acceptable?

Expected response themes:

- Private repos can still leak secrets
- Git history keeps secrets
- Repo access may expand over time
- Use Secrets Manager or another approved secret store
- Add secret scanning

Instructor follow-up:

> “What if the repository is only accessible to five people?”

## Question 2

An application team asks for access to all secrets in the account to avoid future permission issues. What should the cloud team do?

Expected response themes:

- Reject wildcard access
- Apply least privilege
- Scope access by application and environment
- Use naming conventions
- Review permissions during onboarding

Instructor follow-up:

> “How would you design the secret naming standard?”

## Question 3

The application can read the secret in dev but fails in prod. What could be different?

Expected response themes:

- Different IAM role
- Different secret name
- Different KMS key
- Different region
- Different resource policy
- SCP or permission boundary
- Prod has stricter controls

Instructor follow-up:

> “Which difference would you check first?”

## Question 4

Should DevOps pipelines be allowed to read production secrets?

Expected response themes:

- Depends on use case
- Usually avoid exposing prod secrets to build jobs
- Deployment roles may need limited access
- Runtime workloads should retrieve secrets
- Use protected environments and approvals

Instructor follow-up:

> “What is the difference between build-time and runtime secret access?”

## Question 5

A student says, “We can just put secrets in Kubernetes Secrets.” What is missing from that answer?

Expected response themes:

- Kubernetes Secrets are base64-encoded, not automatically safe by default
- Need encryption at rest
- Need RBAC controls
- Need external secret integration in many enterprises
- Need audit and rotation process

Instructor follow-up:

> “How could Kubernetes retrieve secrets from AWS Secrets Manager?”

## Question 6

A secret was accidentally printed in application logs. What should the team do?

Expected response themes:

- Treat as exposure
- Rotate the secret
- Restrict log access
- Remove or redact logs if possible
- Fix application logging
- Review who accessed logs

Instructor follow-up:

> “Is deleting the log line from future code enough?”

## Question 7

Secrets Manager costs more than a plain text config file. Why would an enterprise still use it?

Expected response themes:

- Security risk reduction
- Auditability
- Access control
- Rotation
- Central management
- Incident prevention
- Compliance expectations

Instructor follow-up:

> “How would you explain this tradeoff to a manager?”

---

# 16. Knowledge Check or Mini-Quiz With Answer Key

## Question 1: Multiple Choice

Which AWS service is primarily used to store and retrieve sensitive values such as database passwords?

A. Amazon S3  
B. AWS Secrets Manager  
C. Amazon CloudFront  
D. AWS Budgets  

**Answer:** B  
**Explanation:** AWS Secrets Manager is designed for storing, retrieving, and rotating secrets.

## Question 2: Multiple Choice

Which IAM action is commonly required to retrieve a secret from AWS Secrets Manager?

A. `s3:GetObject`  
B. `ec2:DescribeInstances`  
C. `secretsmanager:GetSecretValue`  
D. `cloudwatch:GetMetricData`  

**Answer:** C  
**Explanation:** `secretsmanager:GetSecretValue` allows an identity to retrieve the secret value.

## Question 3: True or False

It is safe to commit secrets to a private Git repository if only the DevOps team has access.

**Answer:** False  
**Explanation:** Private repositories can still expose secrets through access changes, clones, backups, or Git history.

## Question 4: Multiple Choice

What does AWS KMS primarily manage?

A. Encryption keys  
B. Public DNS zones  
C. EC2 user accounts  
D. Docker images  

**Answer:** A  
**Explanation:** KMS manages encryption keys used to protect data.

## Question 5: Short Answer

What is one reason deleting a secret from the latest Git commit may not fully remove the risk?

**Answer:** The secret may still exist in Git history, clones, forks, or backups.  
**Explanation:** Once committed, a secret should be considered exposed and rotated.

## Question 6: Troubleshooting Multiple Choice

An application receives this error:

```text
AccessDeniedException: not authorized to perform secretsmanager:GetSecretValue
```

What is the most likely issue?

A. The database is down  
B. The IAM role lacks permission to read the secret  
C. The application has too much memory  
D. The Docker image is too large  

**Answer:** B  
**Explanation:** The error directly indicates missing Secrets Manager permission.

## Question 7: Troubleshooting Short Answer

An app has `secretsmanager:GetSecretValue` but still receives a `kms:Decrypt` access error. What is likely missing?

**Answer:** Permission to use the KMS key that encrypts the secret.  
**Explanation:** Customer-managed KMS keys may require explicit `kms:Decrypt` permission.

## Question 8: True or False

Parameter Store can store both plain configuration values and encrypted secure strings.

**Answer:** True  
**Explanation:** Parameter Store supports String, StringList, and SecureString parameter types.

## Question 9: Multiple Choice

Which is the best example of least privilege?

A. Allow all apps to read all secrets  
B. Allow a dev app role to read only its required dev secret  
C. Give every pipeline admin access  
D. Store one shared password for all environments  

**Answer:** B  
**Explanation:** Least privilege limits access to only what is required.

## Question 10: Short Answer

Name one Azure and one GCP service comparable to AWS Secrets Manager.

**Answer:** Azure Key Vault and GCP Secret Manager.  
**Explanation:** Both provide managed secret storage capabilities in their respective clouds.

## Question 11: Multiple Choice

Which item should usually not be printed in application logs?

A. Request count  
B. Application version  
C. Secret value  
D. HTTP status code  

**Answer:** C  
**Explanation:** Secret values in logs can expose credentials to anyone with log access.

## Question 12: Short Answer

What should a team do if a production secret is accidentally exposed?

**Answer:** Rotate the secret, review access logs, remove exposure if possible, update the application, and document the incident.  
**Explanation:** Exposed secrets should be treated as compromised.

---

# 17. Homework Assignment

## Assignment Title

**Cloud Secrets Management Checklist for a New Application**

## Scenario

A development team is building a new internal API that connects to a database and a third-party payment service. They ask the cloud platform team where to store the database password and API token.

You are acting as the DevOps, Cloud Engineering, or SRE representative helping define a secure approach.

## Student Tasks

Create a 1 to 2 page checklist that explains:

1. Where application secrets should be stored
2. Where secrets should not be stored
3. How the application should access secrets at runtime
4. Which IAM permissions are required
5. Whether KMS permissions may be needed
6. How dev, test, and prod secrets should be separated
7. How secret access should be audited
8. What should happen if a secret is leaked
9. When to use Secrets Manager vs Parameter Store
10. Azure and GCP equivalent services

## Expected Deliverables

Submit a document titled:

```text
Cloud Secrets Management Checklist for a New Application
```

Required sections:

```text
1. Overview
2. Approved Secret Storage
3. Unsafe Secret Storage Locations
4. IAM and Least Privilege
5. KMS and Encryption
6. Environment Separation
7. Audit and Monitoring
8. Secret Leak Response
9. AWS, Azure, and GCP Comparison
10. Final Recommendation
```

## Submission Format

Acceptable formats:

- Markdown file
- Word document
- PDF
- Shared document link, if permitted by the instructor

## Estimated Completion Time

60 to 90 minutes

## Grading Criteria

| Criteria | Points |
|---|---:|
| Correct explanation of secrets management risks | 20 |
| Clear AWS Secrets Manager and Parameter Store recommendation | 20 |
| IAM and KMS permissions explained accurately | 20 |
| Practical environment separation and audit guidance | 15 |
| Azure and GCP comparison included | 10 |
| Clear structure and professional writing | 10 |
| Optional advanced recommendation | 5 |

## Optional Advanced Challenge

Add a proposed naming standard for secrets.

Example:

```text
/{environment}/{application}/{component}/{secret-name}
```

Example secrets:

```text
/dev/payment-api/database/password
/test/payment-api/database/password
/prod/payment-api/database/password
```

---

# 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Using real passwords in labs | Students try to make examples realistic | Always use fake lab-only values |
| Forgetting AWS region | AWS CLI defaults may differ from Console region | Set `AWS_REGION` and use `--region` |
| Using wrong AWS profile | Multiple accounts or credentials are configured | Run `aws sts get-caller-identity` first |
| Printing secrets to logs | Students focus on debugging output | Teach masking, redaction, and careful logging |
| Using wildcard IAM permissions | Easier than scoping access | Start with specific secret ARN patterns |
| Confusing KMS and Secrets Manager | Both are security-related services | Reinforce: KMS manages keys, Secrets Manager stores secrets |
| Forgetting cleanup | Students may not know Secrets Manager has cost | End lab with cleanup checklist |
| Thinking Parameter Store and Secrets Manager are identical | Both can store sensitive values | Compare rotation, lifecycle, cost, and use cases |
| Copying secret values into notes | Students want proof of lab completion | Ask for command evidence without secret values |
| Using prod-like names in labs | Students copy enterprise examples too literally | Use clearly labeled `dev` or `training` names |

---

# 19. Real-World Enterprise Scenario

## Scenario

A company is modernizing a legacy application. The old application stored database credentials in a configuration file on an EC2 instance. The application team is now moving to containers and CI/CD.

The security team raises concerns:

- Passwords exist in old config files
- Developers may have copied secrets locally
- CI/CD pipelines may expose variables in logs
- Kubernetes manifests may include credentials
- Production and non-production secrets are not clearly separated
- No one knows who accessed the secrets

## Constraints

| Constraint | Impact |
|---|---|
| Access control | Only approved app roles should read secrets |
| Approvals | Production secret access requires review |
| Cost | Avoid unnecessary secret sprawl |
| Security | Secrets must not be stored in Git or images |
| Reliability | Secret rotation must not break the app |
| Audit | CloudTrail should show access history |
| Operations | SREs need runbooks for secret access failures |

## What Each Role Would Do

### DevOps Engineer

- Remove secrets from CI/CD pipeline logs
- Use protected variables only where appropriate
- Ensure builds do not bake secrets into images
- Help integrate runtime secret retrieval
- Add secret scanning to pipelines

### Cloud Engineer

- Design IAM role permissions
- Create Secrets Manager structure
- Define KMS usage
- Apply tags and naming standards
- Ensure dev/test/prod separation

### SRE

- Monitor application startup failures caused by secret access
- Create a runbook for secret retrieval errors
- Review CloudTrail during incidents
- Help plan safe secret rotation
- Add alerts for repeated access failures

---

# 20. Instructor Tips

## Teaching Tips

- Keep the first half conceptual and the second half hands-on.
- Avoid deep cryptography. Focus on practical KMS usage.
- Repeat the four-part model: identity, permission, secret store, encryption.
- Use fake values only.
- Show both Console and CLI if possible.
- Emphasize that “working” is not the same as “secure.”

## Pacing Tips

- Do not spend more than 20 minutes reviewing IAM.
- Keep KMS explanation practical.
- Start the demo by the 2-hour mark.
- Reserve at least 20 minutes for students to complete the lab.
- Keep the Azure/GCP comparison under 5 minutes.

## Lab Support Tips

Common student support checks:

```bash
aws sts get-caller-identity
aws configure get region
echo $AWS_REGION
```

Ask students:

- What region are you using?
- What exact secret name did you create?
- What identity does AWS CLI show?
- What is the exact error message?
- Did you clean up?

## Helping Struggling Students

For students who are stuck:

- Have them use AWS Console first, then CLI
- Give them a known-good command
- Help them check region and identity
- Pair them with a student who finished early
- Let them complete only Secrets Manager and skip Parameter Store

## Challenging Advanced Students

Ask advanced students to:

- Write a least-privilege IAM policy
- Add KMS-specific permissions
- Compare Parameter Store and Secrets Manager costs
- Draft a Kubernetes external secrets pattern
- Write a script that retrieves and parses the JSON secret safely
- Explain how they would rotate secrets without downtime

---

# 21. Student Outcome Checklist

## Students Should Be Able to Explain

- [ ] What a secret is
- [ ] Why secrets should not be stored in Git
- [ ] What AWS Secrets Manager is used for
- [ ] What Parameter Store is used for
- [ ] What KMS does
- [ ] How IAM controls secret access
- [ ] Why least privilege matters
- [ ] Why KMS decrypt permission may be required
- [ ] How AWS compares with Azure Key Vault and GCP Secret Manager

## Students Should Be Able to Build or Configure

- [ ] Create a lab secret in AWS Secrets Manager
- [ ] Add basic tags to a secret
- [ ] Retrieve a secret using AWS CLI
- [ ] Create a SecureString parameter in Parameter Store, if permissions allow
- [ ] Retrieve a secure parameter with decryption
- [ ] Clean up lab secrets and parameters

## Students Should Be Able to Troubleshoot

- [ ] Wrong AWS region
- [ ] Wrong AWS profile
- [ ] Missing `secretsmanager:GetSecretValue`
- [ ] Missing `kms:Decrypt`
- [ ] Wrong secret name or ARN
- [ ] Secret scheduled for deletion
- [ ] Unsafe secret exposure in logs or Git

---

# 22. Class Completion Checklist

## Instructor Checklist Before Ending Class

- [ ] Students understand the difference between Secrets Manager and Parameter Store
- [ ] Students can explain IAM role-based secret access
- [ ] Students understand KMS at a practical level
- [ ] Demo secret was deleted
- [ ] Demo parameter was deleted, if created
- [ ] Students were warned about Secrets Manager cost
- [ ] Students understand not to use real secrets in labs
- [ ] Homework assignment was explained
- [ ] Week 7 preview and the governance forward-pointer (Week 17/18) were provided

## Student Checklist Before Leaving Class

- [ ] I verified my AWS identity
- [ ] I created a fake lab secret
- [ ] I retrieved the secret with AWS CLI
- [ ] I understand what permission is needed to retrieve a secret
- [ ] I understand why KMS may require decrypt permission
- [ ] I cleaned up my lab secret
- [ ] I cleaned up my optional parameter
- [ ] I noted my homework assignment
- [ ] I can explain why secrets should not be committed to Git

## Items to Verify Before Moving to Week 7

Students should be ready to move on if they can answer:

1. What is a secret?
2. Why is Git a bad place for secrets?
3. What does Secrets Manager do?
4. What does KMS do?
5. What does IAM control, and how does a workload role read a secret?
6. What error might appear if permission is missing?
7. Why does audit logging matter for secret access?

The governance topics introduced here build naturally, later in the track, into:

- CloudTrail and audit logging at scale (Week 17-18)
- Tagging standards and resource ownership (Week 17-18)
- Governance controls and policy guardrails / SCPs (Week 17 Landing Zones)
- Compliance basics (Week 19 DevSecOps)

---

## Class Artifacts & Validation

The runnable, on-disk artifacts this class uses live in
[`labs/security-automation/`](../../labs/security-automation/). They make the secret-hygiene
and governance lessons above executable: a **secret scanner** that blocks credentials
before they reach Git (the core "never commit secrets" rule), a **public-exposure check**
for S3, and the **least-privilege auditor + org SCP guardrail** that gate who may read a
secret. Every row below was run in this environment; reproduce them all at once with
`cd labs/security-automation && ./validate.sh` (24 pass, 0 deferred).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/security-automation/solution/secret_scan.sh` | shell | Credential-pattern scanner (AWS keys, PEM, tokens, password assignments); pre-commit/CI gate that enforces "no secrets in Git" | `bash -n …/secret_scan.sh` + `bash …/secret_scan.sh dir broken` (exit 1) / `dir solution` (exit 0) | PASS (syntax OK; flags planted key, clean on solution) |
| 2 | `labs/security-automation/broken/leaky_config.env` | fixture | Reproducible broken state: a planted (fake, AWS-documented example) key for the secret-scan exercise | `bash …/secret_scan.sh dir broken` | PASS (detected, exit 1) |
| 3 | `labs/security-automation/solution/s3_public_check.sh` | shell | Detects public S3 grants (`Principal "*"`, ACL `AllUsers`/`AuthenticatedUsers`) — the public-exposure risk for secret/data buckets | `bash -n …` + policy/acl fixtures (public → exit 1, private → exit 0) | PASS (flags public policy & ACL; passes private) |
| 4 | `labs/security-automation/solution/iam_policy_audit.py` | python | Least-privilege auditor — the gate that keeps a secret-reader role scoped (`secretsmanager:GetSecretValue` + `kms:Decrypt`, not `*`) | `PYTHONPATH=solution python3 -m unittest discover -s tests` | PASS (14 tests, OK) |
| 5 | `labs/security-automation/solution/policies/scp/deny-leave-org.json` | json | Org-root **SCP guardrail** — the governance / policy-guardrail artifact this class previews (Week 17 Landing Zones) | `python3 -m json.tool < …` | PASS (well-formed; reference guardrail) |

> **Live-op status (honest):** these gates are **static / offline** — bash + python
> against fixture files, no AWS account. The class teaches `aws secretsmanager`/`kms`,
> CloudTrail audit, and a real access-denied scenario, but those are **instructor-run in a
> live account** and are **not** captured as committed evidence here (no `LIVE-*.txt`
> exists for this lab). Score accordingly.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the secret scanner and S3-public check (`*.sh`), the IAM auditor (`*.py`), the broken fixture, and the SCP guardrail (`*.json`) are real files, not fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (table above; `./validate.sh` → 24 pass / 0 deferred in this env).
- [x] Lab has **starter** (intentionally incomplete `TODO(student)` gaps — e.g. the `PATTERNS` table and `principal_is_public()`) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** provided and idempotent — the lab provisions **no** cloud or local resources ($0, offline); the planted credential is the *fake* AWS example key, so there is nothing to rotate.
- [x] **Instructor answer key** exists — `labs/security-automation/solution/` plus the README "Instructor answer key" (TAB-separated `PATTERNS` pitfall, public-Principal detection).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/leaky_config.env` (planted key) and the starter `PATTERNS`-TODO that makes `secret_scan.sh dir broken` exit 0 until fixed (README Troubleshooting table).
- [x] **Expected outputs** are shown for `secret_scan.sh` and `s3_public_check.sh` (README "Expected results").
- [x] **Cost & security warnings** present — README Security/Cost: never commit real secrets, rotate immediately if leaked, secrets belong in Secrets Manager/SSM/Vault, $0 cost.
- [x] **Cross-references** correct — builds on Class 6.1 (roles); previews Week 9/10/11–13/14–15 and Week 17–19; reused as CI gates in Week 19 (verified).
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (`ls`-verified).
- [ ] **Live secret retrieval / KMS / CloudTrail captured as committed evidence** — NOT done: `secretsmanager:GetSecretValue` + `kms:Decrypt` and the access-denied/audit walkthrough are instructor-run against a real account; no `LIVE-*.txt` is committed. This is the gap that keeps the class out of the 8–10 band.
