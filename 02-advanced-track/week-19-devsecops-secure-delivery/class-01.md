# Week 19: DevSecOps and Secure Software Delivery
> **▶ Runnable lab for this class:** [`labs/security-automation/`](../../labs/security-automation/) · [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package

**Week:** 19
**Track:** Unified DevOps · Cloud · SRE Track

## Class Title

**Class 1: DevSecOps Foundations and Security Gates**

---

## 1. Class Overview

### Class Purpose

This class establishes DevSecOps as an engineering discipline that senior DevOps, platform, and SRE engineers are expected to own end to end. The goal is not to make every engineer a full-time security specialist, but a senior engineer is expected to *operate a scanning program*: choose and tune the right tools, run real SAST/SCA/secret scanning, decide what blocks versus warns, route findings into a vulnerability-management lifecycle, and reason about supply-chain integrity. In this class students run real scanners (gitleaks for secrets, semgrep for SAST, trivy/grype for dependencies) against a sample repo, build a pipeline gate that actually blocks risky commits, and produce a lightweight threat model that explains *why* each control exists. Class 2 then extends this to container images and infrastructure as code, plus artifact signing and supply-chain provenance.

### How This Class Connects to the Overall Course

This class builds directly on earlier course topics:

| Previous Topic | Connection to This Class |
|---|---|
| Git (Week 3) | Security checks run on commits, branches, merge requests, and pull requests; signed commits and branch protection are enforced controls |
| CI/CD fundamentals (Week 9) | Security gates become part of pipeline stages |
| Docker/Containers (Week 10) | Container images need vulnerability scanning (deepened in Class 2) |
| Terraform Foundations (Week 14) and Enterprise Workflows (Week 15) | Infrastructure code needs policy and security validation; scanning is the enforcement layer over the IaC you already write |
| Cloud Security & IAM (Week 6) | Pipelines need least-privilege access to AWS; KMS and Secrets Manager back secure secret storage |
| AWS Cloud Foundations (Week 4) | OIDC keyless authentication replaces static access keys for CI |
| Production readiness | Security gates reduce production and compliance risk |

This week prepares students for the secure-delivery patterns enterprise teams depend on, and it feeds directly into **Week 20 (Platform Engineering & Golden Paths)**, where these controls are packaged into reusable golden paths, and **Week 21 (SRE Foundations)**, where a security finding that causes an outage is treated as a reliability concern.

### What Students Will Build, Analyze, or Practice

Students will:

- Analyze where security checks fit in a CI/CD pipeline and produce a lightweight STRIDE threat model.
- Run a real secret scanner (`gitleaks`) and tune a false positive with `.gitleaksignore`.
- Run a real SAST scan (`semgrep`) and a real dependency/SCA scan (`trivy fs` and `grype`) against a sample repo and triage the findings.
- Add a blocking security stage to a pipeline, trigger a failed pipeline with a planted secret, fix it, and re-run.
- Generate a software bill of materials (SBOM) with `syft` and explain how it is consumed downstream.
- Decide when a finding should block, warn, or follow an exception, and route findings into a vulnerability-management lifecycle (owner, severity, SLA-to-remediate).
- Create a DevSecOps pipeline security checklist and scanning-program policy.

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** what DevSecOps means as an operated scanning program, not just a vocabulary list.
2. **Build** a lightweight STRIDE threat model for a delivery pipeline and map controls to threats.
3. **Run** real SAST (semgrep), dependency/SCA (trivy fs, grype), and secret scanning (gitleaks), and triage the findings.
4. **Configure** a blocking security stage in a CI/CD pipeline that fails on real findings.
5. **Generate** and explain an SBOM (syft) and where it is consumed in the supply chain.
6. **Troubleshoot** a failed pipeline caused by a detected secret, including Git-history exposure and rotation.
7. **Operate** a vulnerability-management lifecycle: severity, ownership, SLA-to-remediate, and exception handling.
8. **Explain** why pipeline identity should use OIDC keyless auth and least-privilege IAM.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic Git commands: `clone`, `branch`, `add`, `commit`, `push`
- Merge request or pull request workflow
- Basic YAML structure
- CI/CD stages and jobs
- Basic Linux commands
- Environment variables
- Basic AWS IAM concepts
- Basic secrets management concepts
- Why production deployments need controls

### Required Tools Already Installed

Students should have:

- Git
- VS Code
- Terminal or shell
- GitLab or GitHub account
- Access to a sample repository
- Docker installed, optional for this class
- AWS CLI installed, optional for this class

### Required Accounts or Access

Required:

- GitLab or GitHub repository access
- Ability to create branches and push commits
- Ability to run a CI/CD pipeline

Optional:

- AWS account with read-only IAM access
- AWS Secrets Manager view-only access for instructor demo
- ECR access for preview discussion only

### Files, Repos, or Sample Code Needed

Instructor should provide a simple repo:

```text
devsecops-class1-sample/
├── .gitlab-ci.yml
├── .gitleaks.toml          # optional allowlist tuning
├── requirements.txt        # has a known-vulnerable pinned dep for SCA demo
├── README.md
├── app/
│   └── main.py             # contains one intentional SAST finding
└── config/
    └── application.properties
```

For GitHub Actions version:

```text
devsecops-class1-sample/
├── .github/
│   └── workflows/
│       └── pipeline.yml
├── .gitleaks.toml
├── requirements.txt
├── README.md
├── app/
│   └── main.py
└── config/
    └── application.properties
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| DevSecOps | Adding security practices into DevOps workflows | Security checks run automatically during development and deployment |
| Security Gate | A pipeline checkpoint that decides whether work can continue | A pipeline may block production deployment if a critical issue is found |
| SAST | Static Application Security Testing, scans source code for insecure patterns | Finds risky code before the app is built or deployed |
| Dependency Scanning | Checks third-party libraries for known vulnerabilities | Finds vulnerable packages like old Python, Node, Java, or OS dependencies |
| Secret Scanning | Detects passwords, tokens, keys, or credentials in code | Prevents AWS keys or database passwords from being committed to Git |
| Container Scanning | Checks container images for vulnerable packages | Finds vulnerable base images before deployment to Kubernetes |
| IaC Scanning | Scans Terraform, Kubernetes YAML, or CloudFormation for insecure config | Detects open security groups, public buckets, or unencrypted storage |
| Least Privilege | Giving only the minimum required permissions | A pipeline role should not have full admin access |
| False Positive | A scan finding that looks risky but is not actually a real issue | Teams must tune scans so developers do not ignore noisy results |
| Exception Process | A documented approval to temporarily allow a known risk | Used when a deployment must proceed despite a controlled vulnerability |
| Protected Variable | A CI/CD variable only available to protected branches or environments | Helps prevent secrets from being exposed in untrusted branches |
| Pipeline Identity | The user, token, or cloud role used by the pipeline | In AWS, this may be an IAM role assumed by GitLab or GitHub Actions |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | To manage source code and simulate secure delivery workflows |
| GitHub Actions or GitLab CI | To run automated pipeline stages |
| YAML | To define pipeline jobs and stages |
| VS Code | To edit pipeline files and sample app files |
| Terminal | To run Git commands and scanners locally |
| **gitleaks** | Real secret scanner (entropy + regex rulesets); replaces naive `grep` matching |
| **semgrep** | Real SAST engine; finds insecure code patterns (injection, hardcoded creds, unsafe exec) |
| **trivy** | Multi-target scanner; used here as `trivy fs` for filesystem/dependency (SCA) scanning |
| **grype** | Dependency/SCA scanner; cross-checks Trivy findings against a second vulnerability DB |
| **syft** | Generates an SBOM (CycloneDX/SPDX) from the repo or image |
| AWS IAM, conceptual | To explain least-privilege pipeline access |
| AWS Secrets Manager, conceptual | To explain where secrets should live instead of Git |
| AWS CLI v2, optional | To show how cloud access is validated without exposing credentials |
| TruffleHog, optional alternative | Alternative secret scanner with live-credential verification |

---

## 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| IAM | Used to explain least-privilege access for pipeline roles |
| STS | Used conceptually to explain temporary credentials and role assumption |
| Secrets Manager | Used to explain safe secret storage outside the codebase |
| ECR | Introduced as the container registry where images may later be scanned |
| CloudTrail | Mentioned as the audit trail for cloud API activity |
| S3 | Mentioned as a possible artifact storage location |
| KMS | Mentioned as the encryption layer behind secure secret and artifact storage |

### AWS-First Teaching Point

In an enterprise AWS workflow, a secure pipeline should avoid static AWS access keys when possible. A better pattern is to use short-lived credentials through an IAM role, such as GitLab OIDC or GitHub Actions OIDC, scoped to only the actions required by the pipeline.

---

## 7. Azure and GCP Comparison Notes

Keep this section short during class.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Secrets storage | AWS Secrets Manager | Azure Key Vault | Secret Manager |
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Cloud IAM | IAM | Azure RBAC / Microsoft Entra ID | Cloud IAM |
| Security posture | Security Hub / GuardDuty concepts | Microsoft Defender for Cloud | Security Command Center |
| DevSecOps tooling | ECR scanning, CodeGuru concepts, IAM | Defender for DevOps | Artifact Analysis, Binary Authorization concepts |

Teaching note:

Do not spend too much time comparing clouds in Class 1. The main focus is the DevSecOps workflow. Azure and GCP provide similar concepts, but AWS remains the primary example.

---

## 8. Time-Boxed Instructor Agenda

| Time | Duration | Activity |
|---:|---:|---|
| 0:00 to 0:10 | 10 min | Welcome, Week 19 context, why DevSecOps is a senior competency |
| 0:10 to 0:20 | 10 min | Review CI/CD pipeline flow (Week 9) and shift-left security |
| 0:20 to 0:40 | 20 min | Lightweight threat modeling (STRIDE) for a delivery pipeline |
| 0:40 to 1:05 | 25 min | Scan types in practice: SAST, SCA/dependency, secret, IaC, container; plus SBOM and supply chain |
| 1:05 to 1:20 | 15 min | Security gates: block, warn, approve, exception; vulnerability-management lifecycle |
| 1:20 to 1:30 | 10 min | Break |
| 1:30 to 1:45 | 15 min | Pipeline identity: OIDC keyless auth and least-privilege IAM |
| 1:45 to 2:15 | 30 min | Instructor demo: run gitleaks, semgrep, trivy fs, grype, syft; build a blocking gate |
| 2:15 to 2:45 | 30 min | Student lab: run real scanners and build a gate that actually blocks |
| 2:45 to 2:55 | 10 min | Troubleshooting activity: pipeline blocked by detected secret |
| 2:55 to 3:00 | 5 min | Recap, homework, Class 2 preview |

---

## 9. Instructor Lesson Plan

### Step 1: Open With the Business Problem

Start with this message:

> “In many companies, security issues are found too late. A developer pushes code, the pipeline deploys it, and only after production does someone discover a leaked secret, vulnerable dependency, or open cloud permission. DevSecOps tries to catch those issues earlier, automatically, and repeatedly.”

Explain that the class focuses on security as part of delivery, not security as a separate final approval step.

Pause and ask:

> “Where in a pipeline would you want to catch a leaked password?”

Expected answers:

- Before merge
- Before build
- Before deploy
- Before production

### Step 2: Connect to Previous CI/CD Learning

Draw a simple pipeline:

```text
commit -> test -> build -> deploy
```

Then add security:

```text
commit -> test -> security scan -> build -> deploy
```

Explain that DevSecOps does not replace CI/CD. It improves CI/CD by adding security controls.

### Step 3: Introduce DevSecOps and Shift Left

Explain:

- Traditional model: security review at the end
- DevSecOps model: security checks throughout delivery
- Shift-left means earlier detection
- Earlier detection usually means lower cost and less production risk

Teaching tip:

Use a simple analogy:

> “Finding a leaked key during a commit is like catching a wrong address before mailing a package. Finding it after production is like trying to recover the package after it was delivered to the wrong place.”

### Step 3b: Lightweight Threat Modeling (STRIDE)

Before talking about tools, ask: *what are we defending against?* A senior engineer does not bolt on scanners randomly; they map controls to threats. Introduce STRIDE as a simple checklist applied to the delivery pipeline:

| STRIDE Category | Pipeline Threat Example | Control That Addresses It |
|---|---|---|
| **S**poofing | A forged commit or impersonated CI job pushes to prod | Signed commits, OIDC pipeline identity, branch protection |
| **T**ampering | An attacker modifies a build artifact between build and deploy | Artifact signing (cosign), SLSA provenance |
| **R**epudiation | No record of who deployed what | CloudTrail, signed/attested builds, audit logs |
| **I**nformation disclosure | A secret is committed or printed in logs | Secret scanning (gitleaks), Secrets Manager, masked variables |
| **D**enial of service | A vulnerable dependency enables resource exhaustion | SCA scanning (trivy/grype), patching SLAs |
| **E**levation of privilege | Pipeline role has admin and is compromised | Least-privilege IAM, per-environment roles |

Draw a simple data-flow diagram (developer → repo → CI → registry → cloud) and ask students to mark a *trust boundary* at each arrow. The controls in this week sit on those boundaries.

Teaching tip:

> “Threat modeling does not have to be a week-long exercise. Two questions get you 80% of the value: ‘What are the trust boundaries?’ and ‘What is the worst thing that crosses each one?’”

### Step 4: Explain Scan Types

Walk through each scan type, and for each one name the tool students will actually run today or in Class 2:

1. SAST — `semgrep` (source code patterns)
2. Dependency / SCA — `trivy fs`, `grype` (known CVEs in third-party packages)
3. Secret scanning — `gitleaks` (entropy + regex, not `grep`)
4. Container scanning — `trivy image` (Class 2)
5. IaC scanning — `checkov`, `conftest`/OPA (Class 2)
6. Supply-chain integrity — `syft` (SBOM), `cosign` (signing, Class 2)

Keep each explanation practical and tied to a tool and a real incident class. This is a senior-level week — do not water the definitions down; instead connect each scan type to a named breach pattern (for example: SCA → Log4Shell; secret scanning → leaked cloud keys; supply chain → SolarWinds).

Pause after each scan type and ask:

> “What kind of real incident could this prevent, and how would you operate it without drowning developers in noise?”

### Step 5: Explain Security Gates

Show four possible outcomes from a scan:

```text
Pass -> continue
Warning -> continue but create ticket
Fail -> block pipeline
Exception -> continue with approval
```

Explain that not every finding must block delivery. The pipeline policy should define severity thresholds.

### Step 6: Explain Pipeline IAM and Least Privilege

Use AWS example:

Bad pattern:

```text
Pipeline role = AdministratorAccess
```

Better pattern:

```text
Pipeline role =
- push image to one ECR repo
- read one secret
- deploy to one environment
- write logs
```

Explain that compromised pipeline credentials can become a major cloud incident.

### Step 7: Run Instructor Demo

Run the five scanners by hand first (Demo Part 0), then wire gitleaks into the pipeline as a blocking gate.

Show the pipeline passing first.

Then add a fake secret (AWS documentation example key).

Show the pipeline failing (gitleaks fires, `build_app` is skipped via `needs`).

Remove the fake secret and explain Git-history rotation.

Show the pipeline passing again, then generate the SBOM with syft.

### Step 8: Student Lab

Students perform the same workflow in their own repo or lab branch.

Instructor circulates and helps with:

- YAML indentation
- branch push issues
- pipeline not triggering
- scanner image entrypoint issues (`entrypoint: [""]`)
- gitleaks false positives (use `.gitleaksignore`)
- file path mistakes

### Step 9: Troubleshooting Activity

Give students a failed pipeline log and ask them to identify:

- Which stage failed
- Why it failed
- What file caused the issue
- Whether the finding is real
- How to fix it
- What should happen if it was a real secret

### Step 10: Wrap Up

End with:

> “DevSecOps is not about making developers afraid of security. It is about creating guardrails so teams can move faster with less risk.”

Preview Class 2:

- Trivy container scanning
- Checkov IaC scanning
- ECR image scanning
- Secure delivery policy

---

## 10. Instructor Lecture Notes

### Opening Talking Points

“Last week, we talked about delivery workflows and production readiness. This week, we add security into that delivery flow. In real companies, security teams cannot manually review every commit, every container image, every Terraform change, and every deployment. Automation is necessary.”

“DevSecOps means security becomes part of how software is built and deployed. It does not mean every developer becomes a security expert. It means the delivery system includes guardrails.”

### Concept 1: Why DevSecOps Exists

Security issues often happen because of speed and complexity.

Examples:

- A developer commits an AWS key by accident.
- A Docker image uses an old base image.
- A Terraform file opens SSH to the world.
- A pipeline deploys to production using admin permissions.
- A secret gets printed in pipeline logs.
- A vulnerable dependency is deployed because no one checked it.

In enterprise environments, these issues can lead to:

- Data exposure
- Outages
- Failed audits
- Compliance violations
- Emergency patching
- Loss of customer trust

Talking point:

> “The earlier we catch a problem, the cheaper and safer it is to fix.”

### Concept 2: Shift-Left Security

Shift-left means moving security earlier in the delivery lifecycle.

Traditional pattern:

```text
Develop -> Build -> Deploy -> Security Review -> Incident
```

Better pattern:

```text
Develop -> Scan -> Build -> Scan -> Deploy with Approval -> Monitor
```

Common misconception:

Students may think shift-left means security is only the developer’s responsibility.

Clarify:

> “Shift-left does not remove security teams. It gives developers and DevOps teams faster feedback while security teams define policies, tools, and exception processes.”

### Concept 3: Security Gates

A security gate is a decision point.

Examples:

| Finding | Gate Decision |
|---|---|
| No issues | Continue |
| Low severity dependency | Warn and create backlog item |
| Critical remote code execution vulnerability | Block deployment |
| Secret committed to Git | Block and rotate secret |
| Public S3 bucket in Terraform | Block or require approval |
| Open SSH to internet | Block unless exception approved |

Talking point:

> “The goal is not to block everything. The goal is to block the right things.”

### Concept 4: SAST

SAST scans source code.

Example findings:

- SQL injection patterns
- Hardcoded credentials
- Insecure random number usage
- Unsafe command execution
- Poor input validation

Beginner explanation:

> “SAST looks at your code before the application runs.”

### Concept 5: Dependency Scanning

Most applications use third-party packages.

Examples:

- Python packages from PyPI
- Node packages from npm
- Java dependencies from Maven
- Linux packages in container images

Dependency scanning checks whether those packages have known vulnerabilities.

Talking point:

> “A secure application can still become risky if one of its dependencies is vulnerable.”

### Concept 6: Secret Scanning

Secret scanning finds sensitive values in code.

Examples:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
database_password
private_key
api_token
client_secret
```

Important teaching point:

If a real secret is committed, deleting it from the latest commit may not be enough. It may still exist in Git history. The secret should be rotated.

Say this out loud:

> “If the secret touched Git, assume it may be exposed. Rotate it.”

### Concept 7: Pipeline IAM

Pipelines often need cloud access.

Examples:

- Push image to ECR
- Deploy to EKS
- Read secret from Secrets Manager
- Upload artifact to S3
- Run Terraform plan or apply

Risky pattern:

```text
One pipeline token has admin access to every environment.
```

Better pattern:

```text
Separate roles per environment:
- dev pipeline role
- staging pipeline role
- prod pipeline role

Each role has only required permissions.
```

Enterprise context:

In mature organizations, production deployment may require:

- Protected branch
- Approved merge request
- Manual approval
- Change ticket
- Pipeline role with limited scope
- CloudTrail auditability
- Security scan evidence

### Concept 8: Where Findings Go — Vulnerability-Management Lifecycle

Running scanners is the easy part. The senior question is: *what happens to a finding after the scanner prints it?* A finding that scrolls past in a CI log is not managed. A managed finding has:

1. **An owner** — a team or person responsible for fixing it.
2. **A severity** — normalized across tools (a CRITICAL from Trivy and a HIGH from Grype for the same CVE should not double-count).
3. **An SLA-to-remediate** — e.g. CRITICAL in 7 days, HIGH in 30, MEDIUM in 90. The SLA is what makes "we'll get to it" measurable.
4. **A state** — open / in-progress / fixed / risk-accepted (with an expiry).
5. **Deduplication** — the same CVE across many images/services is one finding with many instances, not hundreds of tickets.

Tools that do this: GitHub/GitLab code scanning (SARIF ingestion), or a dedicated aggregator like **DefectDojo**. The pipeline gate stops the *worst* things at merge; the lifecycle handles the long tail.

Talking point:

> “A scanner tells you what is wrong today. A vulnerability-management program tells you what is still wrong in 30 days and who owns it.”

### Concept 9: Supply-Chain Security and SBOMs (Preview)

Post-SolarWinds and Log4Shell, the question shifted from "is *my* code safe?" to "can I prove what is *in* what I shipped, and that nobody tampered with it?" Three building blocks:

- **SBOM (Software Bill of Materials)** — an inventory of every component in your artifact, generated with `syft` (CycloneDX/SPDX). When the next Log4Shell drops, you query SBOMs instead of guessing.
- **Provenance / attestations (SLSA)** — signed metadata proving *how* and *where* an artifact was built.
- **Signing (Sigstore/cosign)** — proving the artifact is the one your pipeline produced and was not swapped.

Today you generate an SBOM with syft. Class 2 adds signing, verification, and SLSA provenance for container images.

---

## 11. Whiteboard Explanation

### Simple DevSecOps Pipeline Diagram

```text
Developer
   |
   v
Git Commit
   |
   v
Merge Request / Pull Request
   |
   v
CI Pipeline
   |
   |-- Code Quality Check
   |-- Unit Tests
   |-- SAST
   |-- Secret Scan
   |-- Dependency Scan
   |
   v
Security Gate
   |
   |-- Pass: Continue
   |-- Warn: Continue + Create Ticket
   |-- Fail: Block Pipeline
   |-- Exception: Approval Required
   |
   v
Build Artifact / Container Image
   |
   v
Deploy to Environment
```

### Step-by-Step Explanation

1. Developer writes code.
2. Code is pushed to a Git branch.
3. A merge request or pull request is opened.
4. Pipeline starts automatically.
5. Pipeline runs normal checks like tests.
6. Pipeline runs security checks.
7. Security gate evaluates results.
8. Pipeline either continues, warns, blocks, or requires approval.
9. Only approved code moves toward deployment.

### What Each Component Means

| Component | Meaning |
|---|---|
| Developer | Person making code or infrastructure change |
| Git Commit | Versioned change |
| Merge Request | Review point before merging |
| CI Pipeline | Automated validation process |
| Security Scan | Automated security inspection |
| Security Gate | Decision point |
| Deploy | Release to environment |

### Enterprise Version of the Diagram

```text
Developer Branch
   |
   v
Merge Request
   |
   |-- Peer Review
   |-- CODEOWNERS Review
   |-- Security Scan Evidence
   |
   v
CI Pipeline
   |
   |-- Unit Tests
   |-- SAST
   |-- Dependency Scan
   |-- Secret Scan
   |-- IaC Policy Check
   |
   v
Approval Gate
   |
   |-- Dev: automatic deploy
   |-- Staging: team approval
   |-- Production: change approval + protected role
   |
   v
AWS Deployment
   |
   |-- IAM Role Assumption
   |-- Secrets Manager
   |-- ECR
   |-- EKS / EC2 / Lambda
   |
   v
CloudTrail + Monitoring
```

### Enterprise Teaching Point

In real environments, DevSecOps includes more than scanning. It also includes audit trails, approvals, identity controls, secrets handling, environment separation, and production monitoring.

---

## 12. Instructor Demo Script

### Demo Title

**Run Real Scanners (gitleaks, semgrep, trivy fs, grype, syft) and Build a Blocking Security Gate**

### Demo Objective

Run real, industry-standard scanners against a sample repo, interpret their findings, generate an SBOM, then wire a secret scan into a CI/CD pipeline so a planted secret actually *blocks* the pipeline before build or deployment.

### Demo Part 0: Run the Scanners Locally First

Before touching the pipeline, run each scanner by hand so students see real output. All five tools ship as static binaries or container images, so no language runtime is required.

```bash
# Versions (install via official docs; brew/apt or the official containers)
gitleaks version
semgrep --version
trivy --version
grype version
syft version
```

**1. Secret scanning with gitleaks (NOT grep).** `grep` is a string match — it misses high-entropy tokens and any key whose variable name you did not anticipate, and it false-positives on the string appearing in docs. `gitleaks` uses entropy + curated regex rulesets and scans Git history, not just the working tree:

```bash
# Scan the working tree AND full Git history
gitleaks detect --source . --redact --verbose
```

Expected output (when a real-looking key is present):

```text
Finding:     AKIA************
Secret:      [REDACTED]
RuleID:      aws-access-token
Entropy:     3.84
File:        config/application.properties
Commit:      a1b2c3d
```

Tune a genuine false positive with an allowlist rather than disabling the rule. Create `.gitleaksignore` (paste the exact `Fingerprint` gitleaks prints) or add an allowlist regex to `.gitleaks.toml`:

```toml
# .gitleaks.toml
[allowlist]
description = "Known-safe example values in documentation"
regexes = [
  '''EXAMPLE_KEY_DO_NOT_USE''',
]
paths = [
  '''docs/.*\.md''',
]
```

> Teaching point: tuning a false positive with an allowlist is a senior skill. Disabling the whole rule is not.

**2. SAST with semgrep.** Run the curated default ruleset against the source:

```bash
semgrep scan --config=auto --error .
```

Expected output (example):

```text
app/main.py
  python.lang.security.audit.dangerous-subprocess-use
     23┊ subprocess.call(user_input, shell=True)
1 Code Finding(s)
```

`--error` makes semgrep exit non-zero when findings exist — that is what turns it into a gate.

**3. Dependency / SCA with trivy fs and grype.** Scan the project's dependency manifests for known CVEs. Run two tools so students see that scanners disagree and that cross-checking matters:

```bash
trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 .
grype dir:.
```

Expected trivy output (example):

```text
requirements.txt (pip)
Total: 2 (HIGH: 1, CRITICAL: 1)
┌──────────┬────────────────┬──────────┬───────────────┬───────────────┐
│ Library  │ Vulnerability  │ Severity │ Installed Ver │ Fixed Version │
├──────────┼────────────────┼──────────┼───────────────┼───────────────┤
│ requests │ CVE-2023-32681 │ HIGH     │ 2.19.0        │ 2.31.0        │
└──────────┴────────────────┴──────────┴───────────────┴───────────────┘
```

**4. SBOM with syft.** Produce a software bill of materials in CycloneDX JSON. The SBOM is the inventory every downstream control (signing, policy, vuln re-scanning) depends on:

```bash
syft dir:. -o cyclonedx-json=sbom.cdx.json
```

Discussion — "what do you do with an SBOM?": store it as a build artifact, attach/attest it to the image (Class 2), re-scan it against new CVEs *after* release (so yesterday's clean build is re-checked when a new CVE drops), and hand it to customers/auditors who now contractually require one.

### Original (toy) approach — what NOT to ship

The earlier version of this lab used `grep -R "AWS_SECRET_ACCESS_KEY" .` as the "scanner." Keep this only as a teaching contrast: show it once, then show how gitleaks catches a key that grep misses (different variable name, high-entropy token in a `.env`). A senior never ships grep as a secret scanner.

### Required Setup

Instructor should have:

- GitLab or GitHub repo
- Basic sample app
- Working pipeline runner
- Permission to push a branch
- `.gitlab-ci.yml` or GitHub Actions workflow file

### Option A: GitLab CI Demo

Initial file: `.gitlab-ci.yml`. Note: the scanner jobs use real tool images and **no `allow_failure`** — a finding fails the job, the job failure blocks the stage, and `build_app` never runs. That is the whole point of a gate.

```yaml
stages:
  - test
  - security
  - build

unit_test:
  stage: test
  image: alpine:latest
  script:
    - echo "Running unit tests..."
    - echo "Tests passed"

secret_scan:
  stage: security
  image:
    name: zricethezav/gitleaks:latest
    entrypoint: [""]
  script:
    # gitleaks exits non-zero when it finds a leak -> job fails -> pipeline blocked
    - gitleaks detect --source . --redact --verbose

sast_scan:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    # --error makes semgrep exit non-zero on findings
    - semgrep scan --config=auto --error .

dependency_scan:
  stage: security
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    # --exit-code 1 turns the SCA scan into a gate on HIGH/CRITICAL CVEs
    - trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 .

build_app:
  stage: build
  image: alpine:latest
  needs: ["secret_scan", "sast_scan", "dependency_scan"]
  script:
    - echo "Building application..."
    - echo "Build completed"
```

### Step-by-Step Demo Commands

#### Step 1: Clone Repo

```bash
git clone <REPO_URL>
cd devsecops-class1-sample
```

Expected output:

```text
Cloning into 'devsecops-class1-sample'...
```

Explain:

The repo represents a simple application that will be validated by CI/CD.

#### Step 2: Create Demo Branch

```bash
git checkout -b demo/devsecops-security-gate
```

Expected output:

```text
Switched to a new branch 'demo/devsecops-security-gate'
```

Explain:

In enterprise teams, changes are made on branches and reviewed before merging.

#### Step 3: Add Pipeline File

Create or update `.gitlab-ci.yml` with the demo pipeline.

```bash
git add .gitlab-ci.yml
git commit -m "Add basic DevSecOps security gate"
git push origin demo/devsecops-security-gate
```

Expected output:

```text
[demo/devsecops-security-gate abc123] Add basic DevSecOps security gate
```

Explain:

This pipeline now includes a security stage before build.

#### Step 4: Show Passing Pipeline

Open GitLab pipeline page.

Expected result:

```text
unit_test         passed
secret_scan       passed
sast_scan         passed
dependency_scan   passed
build_app         passed
```

Explain:

No fake secret exists yet, and the demo repo's dependencies and code are clean, so the gate passes.

#### Step 5: Add Fake Secret

Create or edit:

```bash
mkdir -p config
cat > config/application.properties <<'EOF'
app.name=demo-app
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF
```

Important:

These are AWS's published **non-functional documentation example keys** — they match gitleaks' AWS rule (so the scan fires) but are not live credentials. Tell students never to commit a real key, even briefly.

#### Step 6: Commit and Push

```bash
git add config/application.properties
git commit -m "Add sample config file"
git push origin demo/devsecops-security-gate
```

Expected pipeline result:

```text
secret_scan       failed
  Finding:   AKIA************
  RuleID:    aws-access-token
  File:      config/application.properties
sast_scan         passed
dependency_scan   passed
build_app         skipped
```

Explain:

gitleaks detected the AWS key pattern, exited non-zero, the `secret_scan` job failed, and because `build_app` declares `needs: [secret_scan, ...]` it was skipped. The pipeline blocked the workflow because a credential was committed.

#### Step 7: Fix the Issue

```bash
cat > config/application.properties <<'EOF'
app.name=demo-app
secret_reference=aws-secrets-manager://dev/demo-app/db-password
EOF

git add config/application.properties
git commit -m "Replace hardcoded secret with secret reference"
git push origin demo/devsecops-security-gate
```

Expected result:

```text
secret_scan       passed
sast_scan         passed
dependency_scan   passed
build_app         passed
```

Explain:

The secret value was removed from the working tree. **But the key is still in Git history** (commit `a1b2c3d`) — `gitleaks` scans history, so if you only fixed the latest commit it would still fail. In real life: rotate the key immediately, then scrub history (`git filter-repo` / BFG) only after rotation. Store the real value in Secrets Manager or a masked CI/CD variable. (See the Git-history note in Concept 6 and the troubleshooting activity.)

### Option B: GitHub Actions Demo

File: `.github/workflows/devsecops.yml`. Uses official scanner actions. Each job fails the workflow on findings (no `continue-on-error`), so `build` only runs after every gate passes. The `permissions` block follows least privilege.

```yaml
name: DevSecOps Class 1 Pipeline

on:
  push:
  pull_request:

permissions:
  contents: read           # least privilege; only read the repo

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0    # full history so gitleaks scans past commits too
      - name: gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITLEAKS_VERSION: latest

  sast-scan:
    runs-on: ubuntu-latest
    container: returntocorp/semgrep:latest
    steps:
      - uses: actions/checkout@v4
      - run: semgrep scan --config=auto --error .

  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: trivy fs (SCA)
        uses: aquasecurity/trivy-action@0.28.0
        with:
          scan-type: fs
          scanners: vuln
          severity: HIGH,CRITICAL
          exit-code: '1'

  build:
    needs: [secret-scan, sast-scan, dependency-scan]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Build only runs after all gates pass"
```

OIDC keyless note: when `build` later needs to push to ECR or deploy, add `permissions: id-token: write` to *that* job and use `aws-actions/configure-aws-credentials` with a `role-to-assume`. Never store static `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` in repo secrets.

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Pipeline does not start | Wrong branch trigger or runner issue | Check CI/CD settings and branch rules |
| YAML error | Indentation issue | Validate YAML spacing |
| gitleaks/trivy image won't run in GitLab | Image has an entrypoint that swallows the script | Add `entrypoint: [""]` under the `image:` key |
| semgrep `--config=auto` can't reach registry | No network egress on runner | Pre-pull a ruleset or use `--config=p/ci` from a local copy |
| False positive in gitleaks | Example key appears in docs | Add a `.gitleaksignore` fingerprint or `.gitleaks.toml` allowlist — do not disable the rule |
| trivy fs slow on first run | Downloading vulnerability DB | Cache `~/.cache/trivy`; expected on first run |
| Git push rejected | Branch protection or no permission | Use a personal lab repo or allowed branch |

Senior tuning note:

Resolve false positives with a scoped allowlist (`.gitleaksignore`, a semgrep `# nosemgrep:` annotation with a reason, or a Trivy `.trivyignore` with an expiry comment) — never by deleting the rule or the whole job.

### Cleanup Steps

Remove fake secret file or replace content:

```bash
cat > config/application.properties <<'EOF'
app.name=demo-app
secret_reference=aws-secrets-manager://dev/demo-app/db-password
EOF

git add config/application.properties
git commit -m "Clean up demo secret pattern"
git push
```

Delete demo branch after class if desired:

```bash
git checkout main
git branch -d demo/devsecops-security-gate
git push origin --delete demo/devsecops-security-gate
```

---

## 13. Student Lab Manual

### Lab Title

**Create a Basic DevSecOps Security Gate in a CI/CD Pipeline**

### Lab Objective

Add a simple security stage to a CI/CD pipeline, trigger a pipeline failure using a fake secret pattern, then fix the issue and validate that the pipeline passes.

### Estimated Time

25 to 35 minutes

### Student Prerequisites

You should already know how to:

- Clone a Git repository
- Create a branch
- Edit YAML files
- Commit and push changes
- View pipeline results in GitLab or GitHub

### Architecture or Workflow Overview

```text
Student Branch
   |
   v
Pipeline Trigger
   |
   v
Test Stage
   |
   v
Security Stage
   |
   |-- Secret detected: fail pipeline
   |-- No secret detected: continue
   |
   v
Build Stage
```

### Step-by-Step Student Instructions

#### Step 1: Clone the Repository

```bash
git clone <REPO_URL>
cd devsecops-class1-sample
```

Expected output:

```text
Cloning into 'devsecops-class1-sample'...
```

#### Step 2: Create a New Branch

```bash
git checkout -b lab/devsecops-security-gate
```

Expected output:

```text
Switched to a new branch 'lab/devsecops-security-gate'
```

#### Step 3: Create or Update the Pipeline File

For GitLab, create `.gitlab-ci.yml`. You are building a gate that *actually blocks* — there is no `allow_failure` here. A real scanner (gitleaks), not `grep`, is the secret detector:

```yaml
stages:
  - test
  - security
  - build

unit_test:
  stage: test
  image: alpine:latest
  script:
    - echo "Running unit tests..."
    - echo "Tests passed"

secret_scan:
  stage: security
  image:
    name: zricethezav/gitleaks:latest
    entrypoint: [""]
  script:
    - gitleaks detect --source . --redact --verbose

sast_scan:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    - semgrep scan --config=auto --error .

dependency_scan:
  stage: security
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    - trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 .

build_app:
  stage: build
  image: alpine:latest
  needs: ["secret_scan", "sast_scan", "dependency_scan"]
  script:
    - echo "Building application..."
    - echo "Build completed"
```

#### Step 4: Commit and Push

```bash
git add .gitlab-ci.yml
git commit -m "Add basic security gate"
git push origin lab/devsecops-security-gate
```

#### Step 5: Validate the Pipeline Passes

Go to your pipeline page.

Expected result:

```text
unit_test         passed
secret_scan       passed
sast_scan         passed
dependency_scan   passed
build_app         passed
```

#### Step 6: Add a Fake Secret Pattern

Create a config file using AWS's published documentation example keys (they match gitleaks' rule but are not live):

```bash
mkdir -p config
cat > config/application.properties <<'EOF'
app.name=student-demo-app
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF
```

#### Step 7: Commit and Push the Fake Secret Pattern

```bash
git add config/application.properties
git commit -m "Add sample config with fake secret pattern"
git push origin lab/devsecops-security-gate
```

#### Step 8: Validate the Pipeline Fails

Expected result:

```text
secret_scan       failed   (gitleaks: RuleID aws-access-token in config/application.properties)
build_app         skipped  (needs: secret_scan)
```

#### Step 9: Fix the Issue

Replace the fake secret with a safe reference:

```bash
cat > config/application.properties <<'EOF'
app.name=student-demo-app
secret_reference=aws-secrets-manager://dev/student-demo-app/db-password
EOF
```

Commit and push:

```bash
git add config/application.properties
git commit -m "Replace hardcoded secret with secret reference"
git push origin lab/devsecops-security-gate
```

#### Step 10: Validate the Pipeline Passes Again

Expected result:

```text
unit_test         passed
secret_scan       passed
sast_scan         passed
dependency_scan   passed
build_app         passed
```

> Note: removing the key from the working tree fixes the *current* commit. Because gitleaks scans history, on a real leak you must also rotate the credential and (only after rotation) scrub history. In this lab the key never landed on `main`, so a clean working tree is enough.

#### Step 11: Generate an SBOM (Supply-Chain Step)

Produce a bill of materials for the repo and inspect it:

```bash
syft dir:. -o cyclonedx-json=sbom.cdx.json
syft dir:. -o table        # human-readable summary
```

Commit the SBOM as an artifact (or attach it in CI). In Class 2 you will sign an image and attach this SBOM as an attestation.

### Validation Checklist

Students should verify:

- [ ] Branch was created successfully.
- [ ] Pipeline file was added with **no `allow_failure`** on the scan jobs.
- [ ] Pipeline passed before adding the fake secret.
- [ ] Pipeline **failed and blocked `build_app`** after adding the fake secret pattern.
- [ ] Pipeline passed again after removing the fake secret pattern.
- [ ] gitleaks (not grep) was used as the secret scanner.
- [ ] semgrep and trivy fs ran as additional gates.
- [ ] An SBOM (`sbom.cdx.json`) was generated with syft.
- [ ] Student can explain why the security gate blocked the pipeline.
- [ ] Student can explain where real secrets should be stored and why rotation is required.

### Troubleshooting Tips

| Problem | Possible Cause | Fix |
|---|---|---|
| Pipeline does not run | CI/CD not enabled or wrong branch | Check repo pipeline settings |
| YAML error | Indentation problem | Use spaces, not tabs |
| gitleaks flags an example string in docs | Legitimate documentation false positive | Add a `.gitleaksignore` fingerprint or `.gitleaks.toml` allowlist scoped to `docs/` |
| Git push fails | No permission or branch protection | Use allowed branch or fork |
| Pipeline passes even with fake secret | File not committed or key format invalid | Confirm the AKIA-format key is committed; gitleaks needs a real-looking pattern |
| trivy/gitleaks job errors immediately | Image entrypoint swallows the script | Ensure `entrypoint: [""]` is set on the `image:` |

### Cleanup Steps

Remove the lab branch if instructed:

```bash
git checkout main
git branch -d lab/devsecops-security-gate
git push origin --delete lab/devsecops-security-gate
```

Or keep the branch for homework evidence if required.

### Reflection Questions

1. Why should secrets not be committed to Git?
2. Why is deleting a secret from the latest commit not always enough?
3. What should happen if a real AWS key is committed?
4. Should a secret scan block all deployments?
5. Where should application secrets be stored in AWS?

### Optional Challenge Task

Pick one and implement it:

1. **Add a pre-commit hook** so secrets are caught *before* they ever reach the server. Install `pre-commit` and add a gitleaks hook to `.pre-commit-config.yaml`:

   ```yaml
   repos:
     - repo: https://github.com/gitleaks/gitleaks
       rev: v8.18.0
       hooks:
         - id: gitleaks
   ```

   Then `pre-commit install`. Discuss why a server-side gate is still required (developers can `--no-verify`).

2. **Add TruffleHog with live verification** as a second secret scanner and compare its output to gitleaks:

   ```bash
   trufflehog git file://. --only-verified
   ```

3. **Wire findings into a vulnerability-management view**: export trivy/grype results to SARIF (`--format sarif`) and upload to GitHub code scanning (`github/codeql-action/upload-sarif`) so findings get an owner, severity, and remediation SLA instead of scrolling past in a log.

---

## 14. Troubleshooting Activity

### Incident Title

**Pipeline Blocked Because a Secret Was Detected Before Deployment**

### Business Impact

A production deployment is delayed because the CI/CD pipeline failed during the security stage. The application team says the change is urgent, but the security team requires all secret findings to be resolved before deployment.

### Symptoms

Pipeline output:

```text
gitleaks detect --source . --redact --verbose
  Finding:   AKIA************
  RuleID:    aws-access-token
  File:      config/application.properties
  Commit:    a1b2c3d
1 leak found
ERROR: Job failed: exit code 1
```

Pipeline stage status:

```text
unit_test      passed
secret_scan    failed
build_app      skipped
deploy_dev     skipped
```

### Starting Evidence

Students receive:

```text
Failed job: secret_scan
Failed file: config/application.properties
Pattern detected: AWS_SECRET_ACCESS_KEY
Deployment status: blocked
```

### Student Investigation Steps

Students should:

1. Identify the failed pipeline stage.
2. Review the failed job logs.
3. Identify the file that triggered the scan.
4. Determine whether the secret is real or fake.
5. Explain why the pipeline blocked the deployment.
6. Replace the hardcoded value with a safe reference.
7. Re-run the pipeline.
8. Document what would happen if this were a real secret.

### Expected Root Cause

A secret-like value was committed into a repository file.

### Correct Resolution

1. Remove the secret from the file.
2. Store the secret in a proper secret system.
3. Reference the secret securely from the app or pipeline.
4. Re-run the pipeline.
5. If the secret was real, rotate it immediately.
6. Review Git history and access logs if necessary.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Disable the security scan | Removes the control instead of fixing the issue |
| Rename the variable to hide it | Avoids detection but leaves risk |
| Put the secret in another file | Still stores the secret in Git |
| Print secret in logs for debugging | Makes exposure worse |
| Use admin pipeline credentials | Increases blast radius |
| Assume fake-looking keys are safe | Real incidents often begin with assumptions |

### Instructor Hints

Use these hints only if students are stuck:

1. “Which pipeline stage failed?”
2. “What file path appears in the job log?”
3. “Is the problem with the build or with a security rule?”
4. “Where should this value live instead of Git?”
5. “What would you do differently if this were a real AWS key?”

### Preventive Action

Students should recommend:

- Enable secret scanning on merge requests.
- Use protected CI/CD variables.
- Store runtime secrets in AWS Secrets Manager.
- Rotate secrets that were exposed.
- Avoid printing secrets in logs.
- Add pre-commit hooks for local detection.
- Educate developers on safe secret handling.
- Use least-privilege IAM roles for pipelines.

---

## 15. Scenario-Based Discussion Questions

### Question 1

A developer says, “This is only a dev environment secret, so it is okay to commit it.” How should the team respond?

Expected themes:

- Dev secrets can still expose systems.
- Dev often has access to test data or internal services.
- Bad habits move from dev to prod.
- Secrets in Git history can spread.

Follow-up:

> “Would your answer change if the secret was already expired?”

### Question 2

Should all security scan findings block the pipeline?

Expected themes:

- Critical findings may block.
- Low findings may create backlog tickets.
- Context matters.
- Policies should define severity thresholds.
- False positives must be handled.

Follow-up:

> “Who should approve an exception for production?”

### Question 3

A pipeline uses AWS AdministratorAccess because it is easier. What is the risk?

Expected themes:

- Compromised pipeline can control the account.
- Blast radius is too large.
- Violates least privilege.
- Harder to audit and govern.

Follow-up:

> “What permissions might a pipeline actually need?”

### Question 4

Security scans are slowing down the pipeline. What should the team do?

Expected themes:

- Run fast checks early.
- Run deeper scans at scheduled times or before release.
- Cache dependencies.
- Tune policies.
- Avoid disabling controls completely.

Follow-up:

> “Which scans must happen before merge versus before production?”

### Question 5

A real AWS secret was committed but removed five minutes later. What should happen?

Expected themes:

- Rotate the secret.
- Check Git history.
- Review CloudTrail.
- Notify security if needed.
- Do not assume deletion fixes exposure.

Follow-up:

> “What would you check in AWS after rotating the key?”

### Question 6

Should developers be responsible for fixing security findings?

Expected themes:

- Developers own code issues.
- DevOps owns pipeline and automation.
- Security defines policy and standards.
- Platform team provides reusable controls.

Follow-up:

> “How can teams avoid turning security into blame?”

### Question 7

A scan blocks a production hotfix during an outage. What should the process be?

Expected themes:

- Emergency exception process
- Risk acceptance
- Approval from correct owner
- Documented follow-up
- Time-bound exception

Follow-up:

> “What should be reviewed after the incident?”

### Question 8

Should secret scanning happen locally, in CI, or both?

Expected themes:

- Local scanning catches issues early.
- CI scanning enforces team policy.
- Both are useful.
- Server-side controls prevent bypass.

Follow-up:

> “What happens if a developer skips local hooks?”

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is the main goal of DevSecOps?

A. Replace security teams with developers  
B. Add security checks into software delivery workflows  
C. Remove approvals from production deployments  
D. Make pipelines slower  

**Answer:** B  
**Explanation:** DevSecOps integrates security into normal development and delivery workflows.

### Question 2: Multiple Choice

Which scan is most directly used to detect committed credentials?

A. SAST  
B. Secret scanning  
C. Load testing  
D. Unit testing  

**Answer:** B  
**Explanation:** Secret scanning looks for keys, tokens, passwords, and other sensitive values.

### Question 3: Multiple Choice

A pipeline blocks deployment because `AWS_SECRET_ACCESS_KEY` appears in a config file. What should be done first?

A. Disable the scan  
B. Move the secret to another Git file  
C. Remove the secret and use a secure secret store  
D. Rename the variable  

**Answer:** C  
**Explanation:** Secrets should not be stored in Git. They should be stored in systems such as AWS Secrets Manager or CI/CD protected variables.

### Question 4: Multiple Choice

Which AWS service is commonly used to store application secrets?

A. AWS Secrets Manager  
B. Amazon Route 53  
C. Amazon CloudFront  
D. AWS Budgets  

**Answer:** A  
**Explanation:** AWS Secrets Manager is designed to store and manage secrets securely.

### Question 5: True or False

If a real secret is committed to Git and then deleted in the next commit, no further action is needed.

**Answer:** False  
**Explanation:** The secret may still exist in Git history. It should be rotated.

### Question 6: True or False

Every security finding should always block every deployment.

**Answer:** False  
**Explanation:** Teams should define policies. Critical findings may block, while lower-risk findings may create tickets or warnings.

### Question 7: Short Answer

What does “least privilege” mean for a CI/CD pipeline?

**Answer:**  
The pipeline should only have the permissions required to perform its job, such as pushing to a specific ECR repository or deploying to a specific environment, instead of broad administrator access.

### Question 8: Short Answer

Name three types of security checks that can be added to a CI/CD pipeline.

**Answer:**  
Examples include SAST, dependency scanning, secret scanning, container scanning, and IaC scanning.

### Question 9: Troubleshooting

A pipeline fails in the `secret_scan` stage, but the build stage never runs. Why?

**Answer:**  
The security gate failed first, so later stages were skipped. The pipeline is designed to block the build or deployment when a secret is detected.

### Question 10: Troubleshooting

A student’s secret scan fails even after removing the fake secret from `config/application.properties`. What might be the cause?

**Answer:**  
The pattern may still exist in another file such as README, pipeline logs, sample docs, or Git metadata. The scan path may need tuning, or the student may not have committed the fix.

### Question 11: AWS-Related

Why is using AWS AdministratorAccess for a deployment pipeline risky?

**Answer:**  
If the pipeline is compromised, an attacker may gain broad access to the AWS account. Least privilege reduces the blast radius.

### Question 12: AWS-Related

What AWS service records API activity and can help investigate whether a leaked key was used?

**Answer:**  
AWS CloudTrail.  
**Explanation:** CloudTrail records AWS API activity and can help investigate suspicious access.

---

## 17. Homework Assignment

### Assignment Title

**Create a DevSecOps Pipeline Security Checklist**

### Scenario

Your company is deploying a containerized application using a CI/CD pipeline. The security team has asked the DevOps team to define required security checks before production deployment.

### Student Tasks

Create a checklist that includes:

1. Required pipeline stages
2. Secret scanning requirements (name the tool — gitleaks/trufflehog, not grep)
3. SAST requirements (semgrep)
4. Dependency / SCA scanning requirements (trivy fs / grype)
5. Container scanning requirements
6. Infrastructure as code scanning requirements
7. SBOM generation and retention (syft) requirements
8. Pipeline identity: OIDC keyless auth and IAM least-privilege rules
9. Secret storage rules
10. Severity levels that should block deployment
11. Vulnerability-management lifecycle: owner, severity SLA, exception/expiry per control
12. Evidence required before production release

### Expected Deliverables

Submit a Markdown document with:

```text
devsecops-checklist.md
```

Required sections:

```text
# DevSecOps Pipeline Security Checklist

## Application Context
## Required Security Checks
## Blocking Rules
## Warning Rules
## Secret Handling
## Pipeline IAM Rules
## Exception Process
## Production Approval Requirements
## Summary
```

### Submission Format

Markdown file or PDF.

### Estimated Completion Time

60 to 90 minutes

### Grading Criteria

| Criteria | Weight |
|---|---:|
| Includes all required scan types | 25% |
| Defines clear blocking and warning rules | 20% |
| Includes AWS secret and IAM guidance | 20% |
| Includes realistic exception process | 15% |
| Clear formatting and practical wording | 10% |
| Enterprise relevance | 10% |

### Optional Advanced Challenge

Add a sample CI/CD pipeline snippet showing where the security stage belongs.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking DevSecOps is only security team work | Students may separate security from delivery | Explain shared responsibility across Dev, Sec, Ops |
| Adding scans after deployment | Students may not understand shift-left | Put scans before build and deploy stages |
| Blocking every finding | Students may think stricter is always better | Teach severity thresholds and exception process |
| Ignoring critical findings | Students may prioritize speed over risk | Tie findings to production impact |
| Hardcoding fake or real secrets | Students may not understand Git history risk | Use safe references and secret managers |
| Using admin credentials in pipelines | It is easier during labs | Explain blast radius and least privilege |
| YAML indentation errors | YAML is spacing-sensitive | Use two spaces and validate syntax |
| Not checking pipeline logs | Beginners may only look at pass/fail status | Teach log-first troubleshooting |
| Confusing SAST with dependency scanning | Both are “security scans” | Compare code patterns vs package vulnerabilities |
| Assuming scanner output is always perfect | Tools can have false positives | Teach review, tuning, and risk-based decisions |

---

## 19. Real-World Enterprise Scenario

### Scenario

A logistics company has several application teams deploying containerized applications to AWS. The DevOps team owns the CI/CD templates. The security team recently found that one application had a hardcoded API token in a repository, and another application deployed a container image with a critical vulnerability.

Leadership now requires security checks in every production deployment pipeline.

### Constraints

- Developers need fast feedback.
- Security team requires evidence of scanning.
- Production deployments need approval.
- Pipelines must not use admin credentials.
- Secrets must not be stored in Git.
- False positives should not completely stop delivery.
- Critical findings must be handled before production.
- Cloud costs should not increase significantly from scanning tools.

### How the Class Topic Applies

The team implements:

- Secret scanning on merge requests
- SAST before build
- Container scanning before image promotion
- IaC scanning before Terraform apply
- Protected variables for sensitive values
- AWS Secrets Manager for application secrets
- Least-privilege IAM roles for pipelines
- Manual approval for production deployment
- Exception process for urgent releases

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Add security stages to CI/CD templates |
| Cloud Engineer | Define IAM roles and secure AWS access patterns |
| SRE | Ensure security gates do not break production response workflows |
| Security Engineer | Define policies, severity thresholds, and exception rules |
| Developer | Fix code, dependency, and secret findings |
| Platform Engineer | Provide reusable pipeline templates and documentation |

---

## 20. Instructor Tips

### Teaching Tips

- Keep the class practical, but pitch it at the senior bar: students should leave able to *operate* a scanning program, not just name scan types.
- Make students run real scanners (gitleaks, semgrep, trivy, grype, syft) — do not let them coast on definitions.
- Make students read scanner output and pipeline logs instead of guessing.
- Keep reinforcing “security gates are guardrails” and “block the right things, not everything.”
- Tie every control back to a threat (use the STRIDE table) and a real breach class.

### Pacing Tips

- Spend the definition time mapping each scan type to a tool and a breach pattern, not on abstract vocabulary.
- Keep the demo tight: run the five scanners once by hand, then wire one into the gate.
- Give students enough lab time to make mistakes and fix them.
- Save container scanning, IaC scanning, signing, and SLSA provenance for Class 2.

### Lab Support Tips

Common help requests:

- YAML syntax errors
- Pipeline not triggering
- Git branch confusion
- gitleaks flagging example values in docs (allowlist tuning)
- Students not finding pipeline logs

Recommended instructor response:

> “Start with the failed stage, then read the logs from top to bottom. The log usually tells you what file or command caused the failure.”

### Helping Struggling Students

For students who are stuck:

- Pair them with a student who finished early.
- Give them the working pipeline file.
- Ask them to explain the pipeline flow verbally.
- Focus on one success: make the scan fail and then pass.

### Challenging Advanced Students

Ask advanced students to:

- Add a pre-commit gitleaks hook and explain why a server-side gate is still needed.
- Add protected branch rules and required signed commits.
- Add separate dev and prod gates with different severity thresholds.
- Export scanner output to SARIF and upload it to code scanning.
- Write a time-bound exception with an owner and expiry.
- Add a second SCA tool (grype) and reconcile disagreements with Trivy.

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] What DevSecOps means
- [ ] Why security should shift left
- [ ] What a security gate is
- [ ] Difference between SAST, dependency scanning, secret scanning, container scanning, and IaC scanning
- [ ] Why secrets do not belong in Git
- [ ] Why pipeline IAM should use least privilege
- [ ] When a finding should block versus warn

### Students Should Be Able to Build or Configure

- [ ] A basic CI/CD security stage
- [ ] A simple secret scan job
- [ ] A pipeline that fails when a risky pattern is found
- [ ] A pipeline that passes after the issue is fixed
- [ ] A simple DevSecOps checklist

### Students Should Be Able to Troubleshoot

- [ ] Failed security stage
- [ ] YAML syntax issue
- [ ] Pipeline not triggering
- [ ] Secret pattern found in wrong file
- [ ] False positive scan result
- [ ] Missing or unsafe secret handling pattern

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Explained DevSecOps in practical delivery terms
- [ ] Connected DevSecOps to prior CI/CD lessons
- [ ] Explained common scan types
- [ ] Explained security gates
- [ ] Explained least privilege for pipeline identities
- [ ] Completed demo successfully or walked through expected output
- [ ] Gave students lab time
- [ ] Reviewed troubleshooting activity
- [ ] Assigned homework
- [ ] Previewed Class 2 topics

### Student Checklist Before Leaving Class

- [ ] I can explain what DevSecOps means.
- [ ] I can identify where security scans fit in a pipeline.
- [ ] I created or reviewed a basic security stage.
- [ ] I understand why a secret scan can block deployment.
- [ ] I know that real leaked secrets must be rotated.
- [ ] I understand why pipelines should not use admin credentials.
- [ ] I know what homework to submit.

### Items to Verify Before Moving to Class 2

Students should be ready for Class 2 if they can:

- Read basic CI/CD YAML
- Understand pipeline stages
- Explain what a security gate does
- Interpret a failed security scan log
- Explain why container and Terraform scanning are the next logical controls
- Understand that AWS ECR, IAM, and Secrets Manager will be used as AWS examples in secure delivery workflows

---

## Class Artifacts & Validation

The runnable, on-disk artifacts this class uses live in the two backing modules
[`labs/security-automation/`](../../labs/security-automation/) (shift-left scanners +
policy-as-code) and [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/) (the blocking
CI security gate and OIDC deploy). Commands below were run in this environment; results
are honest (static gates `PASS`; the live SaaS-scanner steps that need tools not present
here are marked `DEFERRED` with the exact command and where they run).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/security-automation/solution/secret_scan.sh` | shell | Credential-pattern scanner (AWS keys, PEM, tokens, password assignments); wireable as a pre-commit hook — the secret-gate this class builds | `bash -n solution/secret_scan.sh` + behavioural (`secret_scan.sh dir broken` exits 1; `dir solution` exits 0) | PASS |
| 2 | `labs/security-automation/solution/iam_policy_audit.py` | python | IAM least-privilege auditor (flags wildcard `Action`/`Resource` + `NotAction`), exits non-zero so it can fail a pipeline | `PYTHONPATH=solution python3 -m unittest discover -s tests` | PASS (14 tests, OK) |
| 3 | `labs/security-automation/solution/s3_public_check.sh` | shell | Public S3 policy/ACL detector — a least-privilege guardrail | `bash -n` + behavioural (exit 1 on public fixture, 0 on private) | PASS |
| 4 | `labs/cicd-pipelines/solution/.github/workflows/ci.yml` | github-actions | The PRIMARY blocking pipeline: `lint → test → tarball` **plus** a hard `security` job (gitleaks + pip-audit, no `continue-on-error`/`\|\| true`) that fails the merge on a finding | `actionlint solution/.github/workflows/ci.yml` + `python3 -m unittest discover -s tests` (TestCiSecurityGate) | PASS (actionlint 1.7.3 clean; 24 workflow tests OK) |
| 5 | `labs/cicd-pipelines/solution/.github/workflows/cd.yml` | github-actions | OIDC keyless deploy (`id-token: write` + `role-to-assume`, **no** `aws-access-key-id`) → ECR → gated `production` — the least-privilege pipeline identity this class argues for | `actionlint solution/.github/workflows/cd.yml` + `python3 -m unittest discover -s tests` (TestCdOidc) | PASS |
| 6 | `labs/cicd-pipelines/broken/ci-bad-needs.yml` | github-actions | Reproducible broken fixture (two dangling `needs:`) for the troubleshooting drill | `! actionlint broken/ci-bad-needs.yml` (must be rejected) | PASS (correctly rejected) |
| — | both labs, full suite | — | every gate in each module | `labs/security-automation/validate.sh` and `labs/cicd-pipelines/validate.sh` | PASS (24/0/0 and 31/0 + 6 DEFERRED) |

**DEFERRED (tool not installed in this build env; wired into `ci.yml` and run in real CI):**
the live `gitleaks detect --source solution --no-git` secret scan, `pip-audit -r requirements.txt`
SCA scan, and `ruff check solution` lint. No LIVE evidence file is captured for these, so they
are **not** claimed as PASS. The structure that makes them a *hard* gate (non-zero exit, no
soft-fail, required status check) is asserted statically by the workflow unit tests above.

## Definition of Done

Ticked honestly for this class against the standard's §5 checklist.

- [x] Every technology taught ships at least one **runnable file on disk** — the secret/IAM/S3 scanners and the `ci.yml`/`cd.yml` workflows are real files, not fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `bash -n`, `unittest`, `actionlint`, and the broken-fixture rejection all ran green above; SaaS-scanner steps are documented as DEFERRED with the exact command.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — both modules ship `starter/` with `TODO(student)` gaps and a reference `solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — both module READMEs do.
- [x] **Cleanup/teardown** is provided and idempotent — both labs are local/`$0`; cleanup steps remove caches/temp files (nothing cloud is provisioned).
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — `solution/` + the "Instructor answer key" sections in each README; this class file carries the homework/quiz keys.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/cicd-pipelines/broken/ci-bad-needs.yml` (two dangling `needs:`) and the planted secret in `labs/security-automation/broken/leaky_config.env`.
- [x] **Expected outputs** are shown for demos and labs — captured `validate.sh` transcripts and per-gate expected results in both READMEs.
- [x] **Cost & security warnings** present — both READMEs have Security and Cost sections; the planted credential is the fake AWS doc example key.
- [x] **Cross-references** to the module repo and prior/next weeks are correct — links to W9 (CI/CD), W6 (IAM), W20/W21 verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`; all six rows resolve.
- [ ] **Live SaaS-scanner / cloud operation evidence** — *not done.* gitleaks/pip-audit/ruff and any real AWS OIDC deploy are DEFERRED (tools absent here, no `cd.yml` apply); no live-evidence file exists. The gate is structurally validated, not operated live.
