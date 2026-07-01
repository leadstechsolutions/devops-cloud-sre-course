# Week 19: DevSecOps and Secure Software Delivery
> **▶ Runnable lab for this class:** [`labs/security-automation/`](../../labs/security-automation/) · [`labs/cicd-pipelines/`](../../labs/cicd-pipelines/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package

**Week:** 19
**Track:** Unified DevOps · Cloud · SRE Track

## Class Title

**Class 2: Container and IaC Scanning for Secure Delivery**

---

## 1. Class Overview

### Class Purpose

This class extends Class 1 from source-level scanning into the secure delivery of the deployable artifact and the infrastructure it runs on. Students scan the **built** container image (not a stand-in), harden the Dockerfile, scan Terraform with both Checkov and policy-as-code (OPA/Conftest), and then close the 2026 senior gap: **supply-chain integrity** — generating an SBOM, signing the image with Sigstore/cosign, attaching SLSA provenance, and verifying signatures at deploy time with a Kubernetes admission controller (Kyverno).

The class focuses on secure delivery for AWS-based containerized applications using CI/CD, Trivy, Grype, Checkov, OPA/Conftest, cosign, syft, Kyverno, ECR scan-on-push, IAM, and Secrets Manager. Every gate in this class **actually blocks** — `allow_failure` is never used as the graded end state.

### How This Class Builds From Class 1

Class 1 introduced:

- DevSecOps concepts
- Shift-left security
- Security gates
- Secret scanning
- Pipeline IAM and least privilege
- Basic pipeline failure and recovery

Class 2 builds on that foundation by adding:

- Container image vulnerability scanning
- Terraform and IaC security scanning
- AWS ECR image scanning concepts
- Secure pipeline promotion logic
- Blocking deployments based on vulnerability or policy findings
- Secure delivery policy design

Class 1 answered:

> “How do we add basic security gates into CI/CD?”

Class 2 answers:

> “How do we scan the actual container image and infrastructure code before deploying to AWS?”

### What Students Will Build, Analyze, or Practice

Students will:

- Build a hardened, non-root, digest-pinned, multi-stage image and Trivy-scan the **image they built**.
- Interpret vulnerability scan results and cross-check Trivy with Grype.
- Run Checkov **and** OPA/Conftest policy-as-code against Terraform code.
- Generate an SBOM (syft), sign the image with cosign, attach SLSA provenance, and verify the signature.
- Write a Kyverno admission policy that rejects unsigned images at deploy time.
- Add container, IaC, and supply-chain stages to a CI/CD pipeline that **actually blocks** (no `allow_failure`).
- Analyze a blocked deployment caused by a critical vulnerability and an open SSH rule, and decide fix-vs-exception.
- Create a secure delivery policy for a containerized application.

---

## 2. Quick Review of Class 1

### Review Points

1. DevSecOps means integrating security into normal delivery workflows.
2. Security gates are pipeline decision points.
3. Secret scanning helps prevent credentials from being committed to Git.
4. Not every finding should block deployment, but critical risks often should.
5. Pipeline IAM should follow least privilege.
6. Real leaked secrets should be rotated, not just deleted from Git.
7. CI/CD pipelines should provide fast, automated feedback.
8. Security controls should reduce risk without making delivery impossible.

### Quick Recall Questions

#### Question 1

What is a security gate?

**Expected answer:**  
A security gate is a pipeline checkpoint that decides whether the pipeline should continue, warn, block, or require approval based on scan results or policy.

#### Question 2

Why is committing an AWS secret to Git dangerous even if it is deleted later?

**Expected answer:**  
Because it may still exist in Git history or may already have been copied, viewed, or used. A real exposed secret should be rotated.

#### Question 3

Why should CI/CD pipelines avoid using AWS AdministratorAccess?

**Expected answer:**  
Because a compromised pipeline could gain broad control of the AWS account. Least privilege reduces blast radius.

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students may think scanning is only about secrets | Explain that secrets are one risk type. Class 2 covers images and infrastructure code |
| Students may think all findings are equal | Reinforce severity, exploitability, and environment context |
| Students may not understand why images need scanning | Explain that images include OS packages and libraries, not just app code |
| Students may confuse container scanning and dependency scanning | Clarify container scanning checks image layers and installed packages |
| Students may not understand IaC risk | Show examples like open SSH, public buckets, and unencrypted storage |
| Students may focus only on tool output | Remind them the engineer must interpret results and decide action |

### Instructor Bridge Into Class 2

Use this transition:

> “In Class 1, we added a simple gate that caught a secret-like value before the pipeline moved forward. That was one type of risk. Today we go deeper. Even if there are no secrets in Git, the container image may contain critical vulnerabilities, and the Terraform code may create insecure cloud infrastructure. DevSecOps has to cover the full delivery path: code, image, infrastructure, secrets, and deployment permissions.”

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Build** a hardened Dockerfile (multi-stage, non-root, minimal/distroless base, pinned digest) and scan the built image.
2. **Configure** a Trivy image scan as a blocking gate and cross-check with Grype.
3. **Interpret** vulnerability scan output and severity levels and decide fix-vs-exception.
4. **Configure** policy-as-code with both Checkov and OPA/Conftest against Terraform.
5. **Generate, sign, and verify** a software supply chain: SBOM (syft), image signing (cosign), SLSA provenance.
6. **Enforce** signed-image-only deployment with a Kyverno admission policy.
7. **Explain** ECR scan-on-push + EventBridge as a registry-level control point.
8. **Document** a secure delivery policy for containerized applications.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should already understand:

- What DevSecOps means
- What a security gate does
- How CI/CD stages work
- Why secrets should not be committed to Git
- Why pipelines need least-privilege permissions
- How to read a basic failed pipeline log

### Required Prior Concepts

Students should also know:

- Basic Docker image concepts
- Basic Dockerfile structure
- Basic Terraform workflow: `fmt`, `validate`, `plan`, `apply`
- Basic Git workflow
- Basic YAML syntax
- Basic AWS IAM concepts
- Basic container registry concept

### Required Tools Already Installed

Recommended:

- Git
- VS Code
- Terminal
- Docker
- GitLab CI or GitHub Actions access
- Optional: Trivy installed locally
- Optional: Checkov installed locally
- Optional: AWS CLI

### Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should have access to a repo similar to:

```text
devsecops-week19/
├── .gitlab-ci.yml
├── Dockerfile
├── app/
│   └── main.py
├── terraform/
│   ├── main.tf
│   └── variables.tf
├── policy/
│   └── terraform.rego        # OPA/Conftest policy (added in Class 2)
└── README.md
```

Class 1 pipeline should already include:

```yaml
stages:
  - test
  - security
  - build
```

Class 2 will expand the `security` stage with:

- Container image scanning
- Terraform/IaC scanning

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Container Image | A packaged application with runtime, libraries, and OS layers | The image is what gets deployed to Docker, Kubernetes, ECS, or EKS |
| Base Image | The starting image used in a Dockerfile | Old base images often contain vulnerable packages |
| Vulnerability | A known weakness that could be exploited | Security scanners detect known CVEs in packages |
| CVE | Common Vulnerabilities and Exposures identifier | Example: a known OpenSSL vulnerability listed in public databases |
| Severity | Risk rating such as LOW, MEDIUM, HIGH, or CRITICAL | Teams often block production deployment for critical findings |
| Trivy | Open-source scanner for containers, filesystems, IaC, and dependencies | Commonly used in CI/CD pipelines |
| Amazon ECR | AWS container registry | Stores container images and can scan them for vulnerabilities |
| IaC | Infrastructure as Code | Terraform and Kubernetes YAML are common IaC examples |
| Checkov | IaC scanning tool | Finds insecure Terraform, Kubernetes, and cloud configuration |
| Policy Violation | A configuration that breaks a security rule | Example: security group allows SSH from `0.0.0.0/0` |
| Image Promotion | Moving an approved image from dev/test toward production | Only scanned, signed, and approved images should be promoted |
| Exception | Approved temporary bypass for a known risk | Should be documented, time-limited, and owned |
| SBOM | Software Bill of Materials — an inventory of every component in an artifact | Lets you answer "am I affected by CVE-X?" without rebuilding; generated by syft (CycloneDX/SPDX) |
| Image Signing | Cryptographically signing an image so its origin and integrity can be verified | cosign/Sigstore proves the image is the one your pipeline built and was not swapped |
| SLSA Provenance | Signed metadata describing how and where an artifact was built | Defends against tampered builds (the SolarWinds class of attack) |
| Attestation | A signed statement *about* an artifact (its SBOM, scan result, or provenance) | cosign attaches attestations to an image in the registry |
| Policy-as-Code | Security/compliance rules expressed as code and enforced automatically | OPA/Rego + Conftest let you write custom rules beyond Checkov's built-ins |
| Admission Control | A Kubernetes gate that accepts/rejects resources at deploy time | Kyverno/Gatekeeper can reject unsigned or unscanned images before they run |
| Distroless / Minimal Base | A base image with no shell or package manager, only the runtime | Shrinks attack surface and CVE count dramatically |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| Git | Stores application, pipeline, Docker, and Terraform code |
| GitHub Actions or GitLab CI | Runs automated security scans in the pipeline |
| Docker (BuildKit) | Builds hardened, multi-stage container images |
| Trivy | Scans the built container image for vulnerabilities |
| Grype | Second SCA scanner; cross-checks Trivy findings |
| Checkov | Scans Terraform and IaC files for insecure configuration |
| **OPA / Conftest** | Policy-as-code: writes custom Rego rules Checkov does not cover |
| **syft** | Generates the image SBOM (CycloneDX/SPDX) |
| **cosign (Sigstore)** | Signs and verifies images; attaches SBOM and SLSA provenance attestations |
| **Kyverno** | Kubernetes admission controller that rejects unsigned/unscanned images at deploy time |
| Terraform / OpenTofu | Represents cloud infrastructure as code (OpenTofu is the open-source drop-in) |
| YAML | Defines pipeline stages and jobs |
| AWS CLI v2 | Interacts with ECR and AWS services |
| Amazon ECR | AWS registry; scan-on-push + EventBridge as a control point |
| AWS IAM | Controls pipeline access (OIDC keyless preferred over static keys) |
| AWS Secrets Manager | Stores secrets outside application code and Git |

---

## 7. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon ECR | Stores container images; scan-on-push (basic or enhanced/Inspector) as a control point |
| Amazon EventBridge | Reacts to ECR scan findings to block/flag image promotion |
| IAM | Controls what the CI/CD pipeline can do in AWS (OIDC keyless preferred) |
| STS | Supports temporary credentials and role assumption patterns |
| Secrets Manager | Stores application and pipeline secrets securely |
| CloudTrail | Helps audit AWS activity if credentials or pipeline roles are misused |
| EKS | Deployment target; Kyverno admission control enforces signed images |
| S3 | Pipeline artifacts, SBOM storage, or Terraform/OpenTofu backend |
| DynamoDB | Terraform state locking with S3 backend (Terraform < 1.10; newer uses S3-native locking) |
| KMS | Encrypts secrets, artifacts, and can back cosign signing keys |

### AWS Teaching Point

A secure AWS delivery workflow should answer three questions:

1. Is the code safe enough to build?
2. Is the container image safe enough to deploy?
3. Is the infrastructure code safe enough to apply?

---

## 8. Azure and GCP Comparison Notes

| Secure Delivery Concept | AWS | Azure | GCP |
|---|---|---|---|
| Container registry | Amazon ECR | Azure Container Registry | Artifact Registry |
| Image scanning | ECR scan-on-push / Inspector | Microsoft Defender for Cloud / ACR scanning | Artifact Analysis |
| Secret storage | Secrets Manager | Azure Key Vault | Secret Manager |
| IaC policy scanning | Checkov, tfsec, OPA/Conftest | Checkov/tfsec with AzureRM | Checkov/tfsec with Google provider |
| Image signing / verify | cosign (Sigstore), ECR + Notation | cosign / Notation, ACR content trust | cosign, Binary Authorization (signature enforcement) |
| Admission control | Kyverno/Gatekeeper on EKS | Kyverno/Gatekeeper or Azure Policy for AKS | Binary Authorization / Kyverno on GKE |
| Deployment policy | IAM, SCPs, approvals, CI/CD gates | Azure Policy, RBAC, approvals | Org Policy, IAM, Binary Authorization |

Note: cosign/Sigstore and Kyverno are cloud-agnostic — the same signing and admission-control workflow runs on EKS, AKS, and GKE. That portability is itself a senior selling point.

Teaching note:

Keep the comparison brief. The workflow is cloud-agnostic, but the class examples should stay AWS-first.

---

## 9. Time-Boxed Instructor Agenda

| Time | Duration | Activity |
|---:|---:|---|
| 0:00 to 0:10 | 10 min | Quick review of Class 1: gates, real scanners, SBOM |
| 0:10 to 0:30 | 20 min | Container image risk + hardened Dockerfile (multi-stage, non-root, distroless, digest pin) |
| 0:30 to 0:55 | 25 min | Demo Part 1: build hardened image, Trivy-scan the **built** image, cross-check with Grype |
| 0:55 to 1:10 | 15 min | ECR scan-on-push + EventBridge as a control point |
| 1:10 to 1:20 | 10 min | Break |
| 1:20 to 1:40 | 20 min | IaC policy-as-code: Checkov **and** OPA/Conftest |
| 1:40 to 2:05 | 25 min | Demo Part 2: supply chain — SBOM (syft), sign + verify (cosign), SLSA provenance, Kyverno admission |
| 2:05 to 2:35 | 30 min | Student lab: blocking image + IaC + signing gate (no `allow_failure`) |
| 2:35 to 2:55 | 20 min | Troubleshooting activity: deployment blocked by vulnerability and IaC issue |
| 2:55 to 3:00 | 5 min | Recap, homework, end-of-week summary |

---

## 10. Instructor Lesson Plan

### Step 1: Start With Class 1 Continuity

Say:

> “Last class, we built a simple security gate that detected a secret-like string. Today we are expanding that idea. A secure pipeline should not only check the source code. It should also check the container image and the infrastructure code.”

Show this flow:

```text
Class 1:
Code -> Secret/SAST/SCA Scan -> Gate -> SBOM

Class 2:
Code -> IaC Scan (Checkov + OPA) -> Build Hardened Image -> Image Scan (Trivy+Grype)
     -> Sign + Attest (cosign/SLSA) -> Gate -> Deploy (Kyverno verifies signature)
```

Pause for questions.

### Step 2: Explain Why Container Images Need Scanning

Explain that a container image includes more than application code.

A container image may include:

- Linux packages
- Runtime dependencies
- Language libraries
- Configuration files
- Application binaries
- Shell tools
- Certificates
- User and permission settings

Talking point:

> “Even if your application code is perfect, a vulnerable base image can still make the deployment risky.”

### Step 3: Introduce Trivy

Explain:

- Trivy scans images for known vulnerabilities.
- It reports severity.
- It can fail the pipeline if HIGH or CRITICAL issues are found.
- Teams can tune policies based on risk.

Show simple command (against the image the pipeline built — always scan your own artifact):

```bash
trivy image devsecops-demo:class2
```

Then show stricter command:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 devsecops-demo:class2
```

Note for the instructor: emphasize that a public image like `nginx:latest` is only ever a throwaway example. The gate must scan the image you build and ship.

### Step 4: Explain ECR Image Scanning

Explain the AWS flow:

```text
Build image -> Push to ECR -> Scan image -> Review findings -> Promote or block
```

Clarify:

- ECR scanning identifies vulnerabilities.
- It does not automatically fix images.
- Teams must rebuild images with patched packages or base images.
- A secure pipeline should use scan results before deployment.

### Step 5: Explain IaC Security Risk

Give examples:

- Security group allows SSH from everywhere
- S3 bucket is public
- EBS encryption disabled
- IAM policy uses wildcard permissions
- Kubernetes pod runs privileged
- Database publicly accessible

Talking point:

> “Infrastructure code is production code. A bad Terraform change can create a security incident just like bad application code.”

### Step 6: Introduce Checkov

Explain:

- Checkov scans Terraform and IaC files.
- It identifies policy violations.
- It is useful before `terraform plan` or before `terraform apply`.
- Findings should be reviewed and fixed or documented.

### Step 7: Demo the Full Secure-Delivery Chain

Run the instructor demo end to end: build the hardened image, Trivy-scan **the built image**, cross-check with Grype, run Checkov + OPA/Conftest on Terraform, then the supply-chain steps (syft SBOM, cosign sign + verify, SLSA provenance, Kyverno admission).

Pause after each scan and ask students:

- What failed?
- Why did it fail?
- Should this block production?
- What would you fix?
- Could you *prove* to an auditor what is in this image and who built it?

### Step 7b: Add Supply-Chain Controls

Walk through signing and verification explicitly. Emphasize that signing proves origin/integrity, not safety, and that Kyverno is what makes the signature mean something at deploy time.

### Step 8: Student Lab

Students add Trivy and Checkov jobs to the existing pipeline.

Instructor should support:

- YAML indentation
- Docker-in-Docker confusion
- Tool image usage
- Checkov path issues
- Trivy command failures
- Interpreting scan results

### Step 9: Troubleshooting Activity

Give students a failed deployment scenario with both:

- Critical OpenSSL vulnerability in image
- Terraform security group open to internet

Students decide how to fix and document.

### Step 10: Wrap Up

End with:

> “Class 1 gave us the basic security gate. Class 2 expanded that gate to the actual deployable artifact and the infrastructure it runs on. This is how DevSecOps becomes real in enterprise delivery.”

---

## 11. Instructor Lecture Notes

### Concept 1: Secure Delivery Is More Than Code Scanning

“Many beginners think security scanning means scanning source code only. In real delivery workflows, that is not enough. Production risk can come from source code, third-party dependencies, container images, infrastructure code, pipeline credentials, secrets, and cloud configuration.”

“Today we focus on two important areas: the container image and the Terraform code.”

### Concept 2: Container Image Risk

A container image can be risky because it may contain:

- An old operating system layer
- Vulnerable packages
- Unnecessary tools
- Hardcoded files
- Root user configuration
- Outdated runtime
- Exposed secrets in build layers

Example:

A Python Flask app may have only 20 lines of code, but the image could still contain hundreds of packages inherited from the base image.

Talking point:

> “Small app does not always mean small risk.”

### Concept 3: Trivy

“Trivy is commonly used because it is easy to run locally and easy to add to CI/CD. It can scan images and report known vulnerabilities.”

Basic command (against the image you built, by its immutable tag — never a stand-in public image):

```bash
trivy image devsecops-demo:class2
```

Policy-style command:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 devsecops-demo:class2
```

Explain:

- `--severity HIGH,CRITICAL` focuses on serious findings.
- `--exit-code 1` causes pipeline failure.
- This turns scanner output into a security gate.
- Scan the artifact you ship. Scanning `nginx:latest` while shipping `devsecops-demo:class2` tells you nothing about your release.
- Cross-check high-stakes findings with a second scanner (`grype devsecops-demo:class2`); tools disagree because their databases differ.

Common misconception:

Students may think the scanner fixes the issue.

Clarify:

> “The scanner does not fix the image. It tells you what to fix.”

### Concept 4: Amazon ECR Image Scanning

“Amazon ECR is where AWS teams commonly store Docker images. ECR can scan images and report vulnerabilities. In enterprise workflows, the pipeline may build the image, push it to ECR, scan it, and only deploy if the result meets policy.”

ECR helps with:

- Central image storage
- Image scanning
- Tagging
- Access control through IAM
- Integration with EKS, ECS, and CI/CD

Teaching point:

> “Do not treat the registry as just a storage location. Treat it as a control point.”

### Concept 5: Infrastructure as Code Risk

Infrastructure code creates real cloud resources.

A Terraform mistake can create:

- Publicly exposed database
- Open SSH access
- Unencrypted storage
- Excessive IAM permissions
- Missing logging
- Missing backup
- Internet-facing workload that should be private

Talking point:

> “Terraform code is not just a text file. It is a future cloud environment.”

### Concept 6: Checkov

“Checkov checks infrastructure code against known security and compliance rules. For example, it may tell you that an S3 bucket is public, encryption is missing, or a security group is too open.”

Example command:

```bash
checkov -d terraform/
```

Common misconception:

Students may think every Checkov finding is equally urgent.

Clarify:

> “Findings need review. Some should block immediately. Some should become backlog items. Some may be accepted temporarily with approval.”

### Concept 7: Secure Pipeline Design

A secure pipeline should have ordered checks:

```text
validate -> security -> build -> scan image -> deploy
```

A stronger version:

```text
lint/test -> secret scan -> IaC scan -> build image -> image scan -> push -> deploy approval -> deploy
```

Enterprise context:

Production deployment may require:

- Protected branch
- Approval
- Change ticket
- Passing security scans
- Least-privilege IAM role
- CloudTrail audit trail
- Rollback plan

### Concept 8: Dockerfile Hardening — Shrink the Attack Surface

Scanning finds CVEs; hardening prevents most of them from ever existing. Four levers, in order of impact:

1. **Multi-stage build** — build tools (compilers, package managers) stay in the build stage and never ship in the runtime image.
2. **Minimal / distroless base** — `gcr.io/distroless/*` or `*-slim` images have far fewer packages, so far fewer CVEs and no shell for an attacker to use.
3. **Non-root `USER`** — a compromised process should not be root inside the container.
4. **Digest pinning** — `FROM image@sha256:...` makes the build reproducible; the image you scanned is the image you run.

Talking point:

> “The cheapest vulnerability to fix is the one you never installed. Hardening the base does more than any scanner.”

### Concept 9: Supply-Chain Integrity — SBOM, Signing, Provenance

After SolarWinds (tampered build) and Log4Shell (a deep transitive dependency), passing SAST is not enough. Three controls answer the two senior questions — *what is in this artifact?* and *can I prove it was not tampered with?*

- **SBOM (syft)** — the inventory. When the next CVE drops, you query SBOMs instead of rebuilding to find out who is affected.
- **Signing (cosign/Sigstore)** — proves the image is the one your pipeline produced. Keyless signing uses your OIDC identity and a public transparency log (Rekor), so there is no long-lived private key to leak.
- **SLSA provenance** — signed metadata about *how and where* the artifact was built, defending against tampered builds.

These are worthless unless something *checks* them. That is admission control:

- **Kyverno / Gatekeeper** on Kubernetes reject any image that is not signed by your pipeline, even if it reached the registry. This is defense-in-depth at deploy time, complementing the CI gate.

Common misconception:

> Students think signing an image scans it for vulnerabilities. Clarify: signing proves *origin and integrity*, not *safety*. You still scan; signing just proves the scanned thing is what runs.

### Concept 10: ECR as a Control Point, Not Just Storage

Enable **scan-on-push** on the ECR repo (basic, or enhanced via Amazon Inspector). Then an **EventBridge** rule on the scan-complete event can flag or block promotion when CRITICAL findings appear. The CI scan gives early feedback; the registry scan is a second control point that also re-scans stored images as new CVEs are published.

### Short Talking Points Instructors Can Say Out Loud

- “A secure pipeline checks both the code and the thing that gets deployed.”
- “A container image can be vulnerable even if the app code looks clean.”
- “Scan the image you built, not a public stand-in.”
- “Terraform can create security incidents if we do not scan it.”
- “Signing proves where it came from. Scanning proves it is (reasonably) safe. You need both.”
- “An SBOM is how you answer ‘are we affected?’ in minutes instead of days.”
- “A signature nobody verifies is theater — admission control is what makes it real.”
- “The goal is not to block everything. The goal is to block unacceptable risk.”

---

## 12. Whiteboard Explanation

### Simple Class 2 Diagram

```text
Developer Push
   |
   v
CI Pipeline
   |
   |-- Unit Tests
   |-- Secret Scan       ← Class 1
   |-- Terraform Scan    ← Class 2
   |-- Docker Build
   |-- Image Scan        ← Class 2
   |
   v
Security Gate
   |
   |-- Pass: push image / deploy
   |-- Fail: block and fix
   |-- Exception: approval required
   |
   v
AWS Delivery
   |
   |-- ECR
   |-- EKS / ECS / EC2
   |-- IAM Role
   |-- Secrets Manager
```

### Step-by-Step Flow

1. Developer pushes code.
2. Pipeline runs normal validation.
3. Secret scan checks for leaked credentials.
4. Terraform scan checks cloud configuration.
5. Docker image is built.
6. Image scan checks OS and package vulnerabilities.
7. Security gate reviews results.
8. Approved image is pushed to ECR.
9. Deployment proceeds to AWS environment.

### What Each Component Means

| Component | Meaning |
|---|---|
| Secret Scan | Prevents credentials from entering Git or pipeline flow |
| Terraform Scan | Prevents insecure AWS infrastructure from being created |
| Docker Build | Creates deployable application image |
| Image Scan | Checks image layers for known vulnerabilities |
| Security Gate | Decides whether the release can continue |
| ECR | Stores AWS container images |
| EKS/ECS/EC2 | Possible runtime targets |
| IAM Role | Controls pipeline access |
| Secrets Manager | Stores secrets outside Git |

### How Class 2 Extends Class 1

```text
Class 1 Focus:
Can we stop secrets from entering delivery?

Class 2 Focus:
Can we stop vulnerable images and insecure infrastructure from being deployed?
```

### Enterprise Version of the Diagram

```text
Feature Branch
   |
   v
Merge Request
   |
   |-- Code Review
   |-- Secret Scan
   |-- SAST / Dependency Scan
   |
   v
CI Pipeline
   |
   |-- terraform fmt
   |-- terraform validate
   |-- Checkov + OPA/Conftest IaC Scan
   |-- Docker Build (hardened, non-root, pinned)
   |-- Trivy + Grype Image Scan
   |-- syft SBOM + cosign sign + SLSA provenance
   |
   v
Approval Gate
   |
   |-- Dev: automatic
   |-- Staging: team approval
   |-- Prod: change approval + security evidence
   |
   v
AWS
   |
   |-- Assume IAM Role (OIDC keyless)
   |-- Push to ECR (scan-on-push + EventBridge)
   |-- Deploy to EKS (Kyverno verifies cosign signature at admission)
   |-- Read Secrets from Secrets Manager
   |-- Log API Calls in CloudTrail
```

---

## 13. Instructor Demo Script

### Demo Title

**Add Container and Terraform Security Scanning to a CI/CD Pipeline**

### Demo Objective

Demonstrate how to scan a Docker image with Trivy, scan Terraform code with Checkov, and use scan results as pipeline security gates.

### Required Setup

Instructor should prepare:

```text
devsecops-week19/
├── .gitlab-ci.yml
├── Dockerfile
├── app/
│   └── main.py
├── terraform/
│   ├── main.tf
│   └── variables.tf
├── policy/
│   └── terraform.rego
└── README.md
```

Optional local tools:

```bash
trivy --version
grype version
syft version
cosign version
conftest --version
checkov --version
docker --version
```

If local installation is not available, use containerized scanner images in CI/CD.

### Sample Dockerfiles: Vulnerable vs Hardened

Start with a deliberately weak Dockerfile so students see *why* hardening matters, then show the hardened version.

**Weak (what NOT to ship):**

```dockerfile
# Unpinned 'latest', full distro base, runs as root, no multi-stage
FROM nginx:latest
COPY app/ /usr/share/nginx/html/
```

Problems: `latest` is unpinned and non-reproducible; the full base carries hundreds of OS packages (large CVE surface); the container runs as root.

**Hardened (the senior version):**

```dockerfile
# syntax=docker/dockerfile:1
# --- Build stage ---
FROM python:3.12-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/deps -r requirements.txt
COPY app/ /app/

# --- Runtime stage: distroless, no shell, non-root ---
FROM gcr.io/distroless/python3-debian12:nonroot
WORKDIR /app
ENV PYTHONPATH=/app/deps
COPY --from=build /app /app
USER nonroot
EXPOSE 8080
ENTRYPOINT ["python", "main.py"]
```

Hardening applied: multi-stage build (build tools never reach the runtime image), distroless runtime (no shell or package manager to exploit), explicit non-root `USER`, and a small reproducible base. Pin to an immutable **digest** for production:

```dockerfile
FROM gcr.io/distroless/python3-debian12:nonroot@sha256:<digest>
```

Teaching note:

`latest` is non-reproducible. Tags move; digests do not. Production images should be pinned by digest so the artifact you scanned is the artifact you run.

### Sample Terraform File With an Issue

Create `terraform/main.tf`:

```hcl
resource "aws_security_group" "demo_sg" {
  name        = "demo-open-ssh-sg"
  description = "Demo security group with intentionally open SSH"

  ingress {
    description = "SSH from anywhere - intentionally insecure for class"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Demo Part 1: Run Trivy Locally

#### Step 1: Build Image

```bash
docker build -t devsecops-demo:class2 .
```

Expected output:

```text
Successfully built <image_id>
Successfully tagged devsecops-demo:class2
```

Explain:

The image is now built locally and ready to scan.

#### Step 2: Run Basic Trivy Scan

```bash
trivy image devsecops-demo:class2
```

Expected output example:

```text
devsecops-demo:class2 (debian 12.x)
====================================
Total: 12 (UNKNOWN: 0, LOW: 3, MEDIUM: 5, HIGH: 3, CRITICAL: 1)
```

Explain:

The exact findings may vary. Focus students on severity, package, installed version, and fixed version.

#### Step 3: Run Policy-Style Trivy Scan

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 devsecops-demo:class2
```

Expected behavior:

If HIGH or CRITICAL findings exist, command exits with code `1`.

Explain:

This is how a scanner becomes a gate. The command result can pass or fail the pipeline. Critically — this scans **the image we just built** (`devsecops-demo:class2`), not some unrelated public image. The gate must map to the artifact the student is shipping.

#### Step 4: Cross-Check with Grype

Run a second SCA scanner on the same built image and compare:

```bash
grype devsecops-demo:class2 --fail-on critical
```

Explain: scanners use different vulnerability databases and matching logic, so they sometimes disagree. A senior cross-checks high-stakes findings rather than trusting a single tool. Reconcile by CVE ID, not by raw counts.

### Demo Part 2: Run Checkov Locally

#### Step 1: Run Checkov

```bash
checkov -d terraform/
```

Expected output example:

```text
FAILED for resource: aws_security_group.demo_sg
Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0/0 to port 22"
File: /terraform/main.tf
```

Explain:

Checkov found that SSH is open to the internet.

#### Step 2: Fix Terraform Issue

Change:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

To a safer placeholder:

```hcl
cidr_blocks = ["10.0.0.0/8"]
```

Or explain that in real environments, this should be restricted to an approved corporate CIDR, VPN, or removed in favor of AWS Systems Manager Session Manager.

#### Step 3: Re-run Checkov

```bash
checkov -d terraform/
```

Expected result:

```text
Passed checks: ...
Failed checks: ...
```

Explain:

There may still be other findings. The important point is students understand how to read and address the specific failed check.

#### Step 4: Add Policy-as-Code with OPA/Conftest

Checkov ships hundreds of built-in rules, but every org has rules Checkov does not cover (naming standards, mandatory tags, an approved-CIDR allowlist). That is where policy-as-code with **OPA/Rego + Conftest** comes in. Conftest evaluates structured config against Rego policies you write.

Generate a machine-readable plan to evaluate, then write a policy. Convert the Terraform plan to JSON:

```bash
cd terraform
terraform init -backend=false
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > ../plan.json
cd ..
```

Create `policy/terraform.rego` — deny any security group rule that opens port 22 to the world:

```rego
package main

deny[msg] {
    rc := input.resource_changes[_]
    rc.type == "aws_security_group"
    rule := rc.change.after.ingress[_]
    rule.from_port <= 22
    rule.to_port >= 22
    rule.cidr_blocks[_] == "0.0.0.0/0"
    msg := sprintf("SG '%s' allows SSH (22) from 0.0.0.0/0", [rc.address])
}
```

Run Conftest against the plan:

```bash
conftest test plan.json --policy policy/
```

Expected output:

```text
FAIL - plan.json - main - SG 'aws_security_group.demo_sg' allows SSH (22) from 0.0.0.0/0
1 test, 0 passed, 0 warnings, 1 failure
```

Teaching point: this is the "plan before apply" discipline applied to security — you evaluate policy against the *rendered plan*, not the raw `.tf`, so you catch what the change will actually create. Checkov and Conftest are complementary: Checkov for the broad managed ruleset, OPA/Conftest for org-specific rules.

### Demo Part 3: Add Pipeline Jobs

#### GitLab CI Example

This pipeline **builds the image first**, then scans **that built image** — not `nginx:latest`. IaC is checked by Checkov and OPA/Conftest. No `allow_failure` anywhere: a finding blocks.

```yaml
stages:
  - test
  - iac
  - build
  - scan
  - supply-chain

variables:
  IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA   # immutable, per-commit tag

unit_test:
  stage: test
  image: alpine:latest
  script:
    - echo "Tests passed"

checkov_scan:
  stage: iac
  image: bridgecrew/checkov:latest
  script:
    - checkov -d terraform/ --compact

conftest_scan:
  stage: iac
  image:
    name: openpolicyagent/conftest:latest
    entrypoint: [""]
  script:
    # custom Rego rules in policy/ that Checkov's built-ins don't cover
    - conftest test terraform/ --policy policy/

build_image:
  stage: build
  image: docker:27
  services:
    - docker:27-dind
  script:
    - docker build -t "$IMAGE" .
    - docker push "$IMAGE"

container_scan:
  stage: scan
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    # scan the image WE built and pushed, by its immutable tag
    - trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE"

sign_and_attest:
  stage: supply-chain
  image:
    name: gcr.io/projectsigstore/cosign:latest
    entrypoint: [""]
  variables:
    COSIGN_YES: "true"          # non-interactive
  id_tokens:
    SIGSTORE_ID_TOKEN:           # GitLab OIDC token for keyless signing
      aud: sigstore
  script:
    - syft "$IMAGE" -o cyclonedx-json=sbom.cdx.json
    - cosign sign "$IMAGE"                                  # keyless (Fulcio/Rekor)
    - cosign attest --predicate sbom.cdx.json --type cyclonedx "$IMAGE"
  artifacts:
    paths: [sbom.cdx.json]
```

### Demo Part 4: Supply-Chain Integrity — SBOM, Signing, Provenance, and Admission Control

This is the 2026 senior differentiator. After SolarWinds and Log4Shell, "my code passed SAST" is no longer enough — you must be able to prove *what is in* what you shipped and that *nobody tampered with it*. Four steps, all runnable locally against the image we built.

#### Step 1: Generate an SBOM (syft)

```bash
syft devsecops-demo:class2 -o cyclonedx-json=sbom.cdx.json
syft devsecops-demo:class2 -o table   # quick human view
```

The SBOM is the inventory. When the next critical CVE drops, you query SBOMs instead of rebuilding everything to find out if you are affected.

#### Step 2: Sign the Image Keylessly (cosign / Sigstore)

`cosign` signs without managing private keys: it gets a short-lived certificate from Fulcio tied to your OIDC identity and records the signature in the Rekor transparency log.

```bash
# Keyless signing (uses OIDC; in CI the pipeline's OIDC token is used automatically)
COSIGN_YES=true cosign sign devsecops-demo:class2
```

(Key-based alternative for air-gapped environments: `cosign generate-key-pair` then `cosign sign --key cosign.key`, with the key stored in KMS.)

#### Step 3: Attach SBOM + SLSA Provenance as Attestations

```bash
# Attach the SBOM as a signed attestation
cosign attest --predicate sbom.cdx.json --type cyclonedx devsecops-demo:class2

# Attach SLSA provenance (how/where it was built)
cosign attest --predicate provenance.json --type slsaprovenance devsecops-demo:class2
```

In GitHub Actions, provenance can be generated automatically with `actions/attest-build-provenance`, which produces a signed SLSA provenance attestation tied to the workflow run.

#### Step 4: Verify the Signature

```bash
cosign verify devsecops-demo:class2 \
  --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer-regexp ".*"
```

Expected output (abridged):

```text
Verification for devsecops-demo:class2 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The code-signing certificate was verified using trusted certificate authority certificates
```

> In production, pin `--certificate-identity` and `--certificate-oidc-issuer` to *your* pipeline's exact identity, so only images signed by your CI verify. The `.*` regexes above are for the demo only.

#### Step 5: Enforce Signed-Images-Only at Deploy Time (Kyverno)

Signing is worthless if the cluster runs unsigned images. A Kyverno admission policy on EKS rejects any pod whose image is not signed by your pipeline:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  validationFailureAction: Enforce   # reject, don't just audit
  webhookTimeoutSeconds: 30
  rules:
    - name: verify-cosign-signature
      match:
        any:
          - resources:
              kinds: [Pod]
      verifyImages:
        - imageReferences:
            - "<account>.dkr.ecr.<region>.amazonaws.com/*"
          attestors:
            - entries:
                - keyless:
                    issuer: "https://token.actions.githubusercontent.com"
                    subject: "https://github.com/<org>/<repo>/.github/workflows/*"
                    rekor:
                      url: https://rekor.sigstore.dev
```

Demonstrate: `kubectl run test --image=<unsigned-image>` is **rejected** at admission; the signed image is **admitted**. This is defense-in-depth — even if a bad image reaches ECR, the cluster refuses to run it.

(Gatekeeper/OPA is the alternative admission controller; Kyverno is shown here because its policies are plain YAML and it has first-class cosign image verification.)

### What to Explain During Each Step

| Step | Explanation |
|---|---|
| Build image | The pipeline creates the artifact that will run in production |
| Scan image | Vulnerabilities are checked before deployment |
| Scan Terraform | Cloud configuration is checked before apply |
| Exit code 1 | Pipeline fails when policy threshold is violated |
| Fix finding | Engineers remediate or document exception |
| Re-run pipeline | Verification is required after the fix |

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Docker not running | Docker Desktop or daemon stopped | Start Docker or use CI-only demo |
| Trivy install missing | Tool not installed locally | Use Trivy container image |
| Checkov install missing | Python package not installed | Use Checkov container image |
| Scan output differs | Vulnerability database changes over time | Explain that scanner output is dynamic |
| Pipeline image entrypoint issue | Container image expects scanner command directly | Add `entrypoint: [""]` in GitLab |
| Checkov fails on many findings | Terraform sample has multiple issues | Focus on one specific finding |
| Network issue downloading DB | Scanner cannot update vulnerability database | Use cached results or show prepared output |

### Cleanup Steps

Remove local image:

```bash
docker rmi devsecops-demo:class2
```

Remove demo branch if needed:

```bash
git checkout main
git branch -d demo/class2-secure-delivery
git push origin --delete demo/class2-secure-delivery
```

Cost warning:

This demo does not require creating AWS cloud resources. If using ECR, remind students to delete test images and repositories after class.

Security warning:

Never scan or publish real secrets in a public training repository.

---

## 14. Student Lab Manual

### Lab Title

**Add Container and Terraform Security Scanning to a CI/CD Pipeline**

### Lab Objective

Students will extend the Class 1 pipeline by adding container image scanning and Terraform/IaC scanning. They will review scan output, identify failures, and recommend fixes.

### Estimated Time

35 to 45 minutes

### Student Prerequisites

Students should have:

- Completed Class 1 lab or have starter repo
- Basic CI/CD pipeline file
- Git branch access
- Dockerfile
- Terraform folder
- GitLab or GitHub Actions access

### Starting Point From Class 1

Students should already have:

```text
stages:
  - test
  - security
  - build
```

Class 2 adds:

```text
security stage:
  - secret_scan
  - iac_scan
  - container_scan
```

### Architecture or Workflow Overview

```text
Student Repo
   |
   v
Pipeline
   |
   |-- test
   |-- checkov_scan + conftest_scan   (IaC gate -- blocks before build)
   |-- build_image                    (only if IaC passes)
   |-- container_scan                 (scans the image we built)
   |-- sign + SBOM attest (supply chain)
   |
   v
Block on any failure (no allow_failure)
```

### Step-by-Step Student Instructions

#### Step 1: Create a New Branch

```bash
git checkout -b lab/class2-secure-delivery
```

Expected output:

```text
Switched to a new branch 'lab/class2-secure-delivery'
```

#### Step 2: Confirm Project Structure

```bash
ls
```

Expected files:

```text
Dockerfile
app
terraform
.gitlab-ci.yml
README.md
```

#### Step 3: Add a Hardened Dockerfile

Create a `Dockerfile`. Start from a pinned, minimal base and run as non-root — do **not** use `nginx:latest`:

```dockerfile
# Pin a specific minor tag (pin by digest for real production)
FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY app/ /usr/share/nginx/html/
# nginx-unprivileged already runs as a non-root user on port 8080
EXPOSE 8080
```

> Compare for yourself: build this and `nginx:latest`, then `trivy image` each — the alpine/unprivileged base typically reports far fewer findings and does not run as root. That difference is the value of hardening.

Create app content if needed:

```bash
mkdir -p app
echo "DevSecOps Week 19 Class 2 Demo" > app/index.html
```

#### Step 4: Add Terraform Sample

Create `terraform/main.tf`:

```bash
mkdir -p terraform
cat > terraform/main.tf <<'EOF'
resource "aws_security_group" "demo_sg" {
  name        = "demo-open-ssh-sg"
  description = "Demo security group with intentionally open SSH"

  ingress {
    description = "SSH from anywhere - intentionally insecure for class"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
EOF
```

#### Step 4b: Add an OPA/Conftest Policy

Write a custom Rego rule so you enforce a policy Checkov does not ship. Create `policy/terraform.rego`:

```bash
mkdir -p policy
cat > policy/terraform.rego <<'EOF'
package main

# Conftest's HCL2 parser renders main.tf as a nested document, NOT a flat array:
#   input.resource.aws_security_group.<name> = { ingress = {...}, ... }
# A single ingress block is parsed as an object; multiple ingress blocks become
# an array. The ingress_rules helper normalizes both shapes to an array so the
# rule fires either way.
deny[msg] {
    sg := input.resource.aws_security_group[name]
    rule := ingress_rules(sg)[_]
    rule.from_port <= 22
    rule.to_port >= 22
    rule.cidr_blocks[_] == "0.0.0.0/0"
    msg := sprintf("SG '%s' allows SSH (22) from 0.0.0.0/0", [name])
}

ingress_rules(sg) = rules {
    is_array(sg.ingress)
    rules := sg.ingress
}

ingress_rules(sg) = rules {
    is_object(sg.ingress)
    rules := [sg.ingress]
}
EOF
```

> The rule above runs Conftest directly against the HCL via Conftest's built-in parser for lab speed, so it walks the parser's nested shape (`input.resource.aws_security_group.<name>.ingress`). Note that Conftest's HCL2 parser emits a single `ingress` block as an object and multiple blocks as an array, which is why the helper normalizes both. For the senior version, evaluate the rendered `terraform plan -json` instead of the raw `.tf` (as in the demo) so you catch what the change actually creates — that input is structured differently (`input.resource_changes[_].change.after.ingress`, always an array), which is why the demo policy walks `resource_changes`.

#### Step 5: Update GitLab CI Pipeline

Update `.gitlab-ci.yml`. **The gate must block.** There is no `allow_failure` here — a finding fails the job and stops the pipeline. You also **build the image and scan the image you built**, not a public image.

```yaml
stages:
  - test
  - iac
  - build
  - scan

variables:
  IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

unit_test:
  stage: test
  image: alpine:latest
  script:
    - echo "Tests passed"

checkov_scan:
  stage: iac
  image: bridgecrew/checkov:latest
  script:
    - checkov -d terraform/ --compact

conftest_scan:
  stage: iac
  image:
    name: openpolicyagent/conftest:latest
    entrypoint: [""]
  script:
    - conftest test terraform/ --policy policy/

build_image:
  stage: build
  image: docker:27
  services:
    - docker:27-dind
  script:
    - docker build -t "$IMAGE" .
    - docker push "$IMAGE"

container_scan:
  stage: scan
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    # scan the image we BUILT, by its immutable per-commit tag
    - trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE"
```

Teaching note for students:

A security gate that does not stop the pipeline is not a gate — it is a logger. If you want a *non-blocking warm-up* run while you read findings, you may temporarily add `allow_failure: true`, but the **graded end state is a blocking gate**. Removing `allow_failure` is not the optional challenge; it is the requirement.

If you cannot run Docker-in-Docker in your lab environment, scan a filesystem instead of an image (`trivy fs --severity HIGH,CRITICAL --exit-code 1 .`) so the gate still maps to *your* code, not a public image.

#### Step 6: Commit and Push

```bash
git add .
git commit -m "Add container and IaC scanning jobs"
git push origin lab/class2-secure-delivery
```

#### Step 7: Review Pipeline Results

Open the pipeline in GitLab or GitHub.

Expected outcomes with the open-SSH Terraform still in place:

```text
unit_test       passed
checkov_scan    failed   (CKV_AWS_24: SSH open to 0.0.0.0/0)
conftest_scan   failed   (custom Rego: SG allows SSH from 0.0.0.0/0)
build_image     skipped  (blocked by the failed iac stage)
container_scan  skipped
```

Because there is **no `allow_failure`**, the failed IaC stage stops the pipeline before the image is even built. That is the gate working: insecure infrastructure never reaches the build/scan/deploy steps. After you fix the Terraform (Step 10), the IaC stage passes, the image builds, and `container_scan` runs against the image you built.

#### Step 8: Review Checkov Output

Look for a finding similar to:

```text
Check: CKV_AWS_24
Ensure no security groups allow ingress from 0.0.0.0/0 to port 22
FAILED for resource: aws_security_group.demo_sg
```

Answer:

- What resource failed?
- What is the risk?
- Should this block production?
- What is the recommended fix?

#### Step 9: Review Trivy Output

Look for output similar to:

```text
Total: 8 (LOW: 2, MEDIUM: 3, HIGH: 2, CRITICAL: 1)
```

Answer:

- How many high or critical findings exist?
- What package is affected?
- Is a fixed version available?
- Should the image be deployed?

#### Step 10: Fix the Terraform Finding

Change this:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

To this:

```hcl
cidr_blocks = ["10.0.0.0/8"]
```

Or document that SSH should be removed and replaced with AWS Systems Manager Session Manager in a production design.

Commit and push:

```bash
git add terraform/main.tf
git commit -m "Restrict SSH ingress in Terraform example"
git push origin lab/class2-secure-delivery
```

#### Step 11: Validate Again

Re-run or review the pipeline.

Expected improvement:

```text
The specific open SSH finding should no longer appear in Checkov OR Conftest.
The pipeline now proceeds to build_image and container_scan.
```

There may still be other findings depending on scanner rules.

#### Step 12: Sign and Verify (Supply-Chain Step)

Locally (or as a CI job), produce an SBOM, sign the built image keylessly, and verify it:

```bash
# SBOM for the image you built
syft "$IMAGE" -o cyclonedx-json=sbom.cdx.json

# Keyless sign (uses your OIDC identity; opens a browser locally, automatic in CI)
COSIGN_YES=true cosign sign "$IMAGE"
cosign attest --predicate sbom.cdx.json --type cyclonedx "$IMAGE"

# Verify
cosign verify "$IMAGE" \
  --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer-regexp ".*"
```

Stretch: apply the Kyverno `require-signed-images` policy (from the demo) to a kind/minikube cluster and confirm an unsigned image is rejected at admission.

### Validation Checklist

Students should verify:

- [ ] Pipeline includes Checkov **and** Conftest (OPA) IaC jobs.
- [ ] Pipeline **builds the image and scans the built image** (not `nginx:latest`).
- [ ] **No `allow_failure`** on any scan job — the gate blocks.
- [ ] Failed IaC stage stops the pipeline before build.
- [ ] Trivy reports image vulnerabilities; Grype cross-check attempted.
- [ ] An SBOM was generated (syft) and the image was signed + verified (cosign).
- [ ] Student can explain at least one finding and whether it should block or warn.
- [ ] Student fixed or documented one IaC issue and understands the supply-chain controls.

### Troubleshooting Tips

| Problem | Possible Cause | Fix |
|---|---|---|
| Pipeline YAML fails | Indentation issue | Validate YAML and use spaces |
| Checkov cannot find files | Wrong path | Confirm `terraform/` folder exists |
| Trivy command fails | Image entrypoint issue | Use `entrypoint: [""]` in GitLab |
| Trivy scan takes long | Vulnerability DB download | Wait or retry |
| Docker local build fails | Docker not running | Start Docker |
| Pipeline does not run | Branch or CI config issue | Check CI/CD trigger settings |
| Too many findings | Scanner is doing its job | Focus on one high-impact finding |
| Fix does not show | Changes not committed or pushed | Check `git status` |

### Cleanup Steps

Local cleanup (remove the image you built and the generated SBOM):

```bash
docker image rm "$IMAGE" 2>/dev/null || true
rm -f sbom.cdx.json
```

Branch cleanup, if instructed:

```bash
git switch main
git branch -d lab/class2-secure-delivery
git push origin --delete lab/class2-secure-delivery
```

AWS cleanup (cost/security):

If students pushed to ECR, delete the test repository and its images so they do not accrue storage cost or leave scannable artifacts behind:

```bash
aws ecr delete-repository --repository-name devsecops-week19 --force
```

### Reflection Questions

1. Why should images be scanned before deployment?
2. Why is `nginx:latest` not ideal for production?
3. What is risky about SSH from `0.0.0.0/0`?
4. Should Checkov findings always block production?
5. How does ECR scanning fit into the delivery workflow?
6. What would your team do if a critical vulnerability is found during an emergency release?

### Optional Challenge Task

Pick one:

- Add a `sign_and_attest` CI job (cosign keyless + syft SBOM attestation) and a separate `verify` job that fails if the signature is missing.
- Deploy the Kyverno `require-signed-images` policy to a local kind cluster and prove an unsigned image is rejected.
- Add environment-specific severity: dev warns on HIGH, prod blocks on HIGH and CRITICAL, using GitLab `rules:` per branch.
- Wire ECR scan-on-push: push the image to ECR and use an EventBridge rule on the scan-complete event to flag CRITICAL findings.

---

## 15. Troubleshooting Activity

### Incident Title

**Production Deployment Blocked by Container Vulnerability and Insecure Terraform Rule**

### Business Impact

A production release is delayed. The business wants to deploy a customer-facing update, but the DevSecOps pipeline blocks the release because the image scan reports a critical vulnerability and the Terraform scan reports open SSH access.

### Symptoms

Pipeline summary:

```text
unit_test        passed
secret_scan      passed
iac_scan         failed
container_scan   failed
build_app        skipped
deploy_prod      skipped
```

Container scan output:

```text
CRITICAL vulnerability found
Package: openssl
Installed version: 1.1.1x
Fixed version: 1.1.1y
Result: Deployment blocked
```

Checkov output:

```text
FAILED for resource: aws_security_group.demo_sg
Check: CKV_AWS_24
Reason: Security group allows ingress from 0.0.0.0/0 to port 22
File: terraform/main.tf
```

### Starting Evidence

Students receive:

```text
Failed stages:
- container_scan
- iac_scan

Deployment target:
- production

Business request:
- release should go out today

Security policy:
- critical image vulnerabilities block production
- open SSH to internet blocks production
```

### Student Investigation Steps

Students should:

1. Identify which pipeline stages failed.
2. Determine whether the failure is application code, container image, or infrastructure code.
3. Review the vulnerability severity.
4. Review the Terraform failed check.
5. Decide whether production should remain blocked.
6. Recommend remediation for the image vulnerability.
7. Recommend remediation for the Terraform issue.
8. Document whether an exception should be allowed.
9. Explain who should approve any exception.
10. Re-run pipeline after fixes.

### Expected Root Cause

There are two root causes:

1. The container image includes a package with a critical vulnerability.
2. The Terraform code allows SSH from the public internet.

### Correct Resolution

For the image:

- Update the base image.
- Pin to a safer version.
- Rebuild the image.
- Re-run Trivy or ECR scan.
- Deploy only after the critical finding is resolved or an approved exception exists.

For Terraform:

- Remove public SSH access.
- Restrict ingress to an approved CIDR.
- Use VPN, bastion, or preferably AWS Systems Manager Session Manager.
- Re-run Checkov.
- Apply only after approval.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Disable Trivy | Removes security control |
| Disable Checkov | Allows insecure infrastructure |
| Mark all findings as false positives | Avoids real risk analysis |
| Deploy anyway without approval | Violates production control |
| Use `latest` image tag forever | Reduces repeatability and control |
| Open SSH only “temporarily” without tracking | Temporary exceptions often become permanent |
| Use admin role to bypass policy | Creates larger security risk |
| Ignore scanner output because app tests pass | App tests do not validate security posture |

### Instructor Hints

Use hints gradually:

1. “Are both failures from the same type of problem?”
2. “Which finding is in the container image?”
3. “Which finding is in Terraform?”
4. “What would happen if this security group was applied to production?”
5. “What is the safer way to access EC2 instances without public SSH?”
6. “Who owns the risk if the team requests an exception?”

### Preventive Action

Students should recommend:

- Pin base images by digest and harden the Dockerfile (multi-stage, non-root, distroless).
- Rebuild and re-scan images regularly; re-scan stored images as new CVEs publish.
- Scan the **built** image before deployment; cross-check Trivy with Grype.
- Use ECR scan-on-push + EventBridge as a second control point.
- Add Checkov + OPA/Conftest before Terraform apply (evaluate the plan).
- Generate an SBOM (syft) and sign images (cosign); enforce signed-only with Kyverno.
- Block critical findings in production; restrict SG ingress; prefer SSM Session Manager over open SSH.
- Define a time-bound exception process with an owner and expiry.
- Use OIDC keyless auth and least-privilege pipeline IAM.
- Track findings in a vulnerability-management system with owners, severity SLAs, and dedup.

---

## 16. Scenario-Based Discussion Questions

### Question 1

A container image has one critical vulnerability, but the application team says the vulnerable package is not used by the app. Should deployment be blocked?

Expected response themes:

- Context matters.
- Critical severity is serious.
- Reachability and exploitability should be reviewed.
- Production policy may require blocking.
- Exception may be possible with approval.
- The fix should still be tracked.

Follow-up:

> “Who should approve the risk if the team wants to deploy anyway?”

### Question 2

The Terraform scan finds SSH open to the internet, but the engineer says, “It is only for testing.” Is that acceptable?

Expected response themes:

- Testing patterns often reach production accidentally.
- Public SSH increases attack surface.
- Use approved CIDR or SSM Session Manager.
- Temporary exceptions need expiration.

Follow-up:

> “How would you make this safe for a short troubleshooting window?”

### Question 3

Should image scanning happen before or after pushing to ECR?

Expected response themes:

- Both are possible.
- CI scan gives earlier feedback.
- ECR scan provides registry-level visibility.
- Production promotion should use approved scan results.

Follow-up:

> “What is the advantage of scanning at both places?”

### Question 4

A scanner produces too many findings and developers stop reading the results. What should the team do?

Expected response themes:

- Tune severity thresholds.
- Prioritize exploitable and critical risks.
- Create ownership.
- Reduce false positives.
- Separate blocking vs non-blocking findings.

Follow-up:

> “Which findings should block immediately?”

### Question 5

Is it better to fail the pipeline or allow the pipeline to pass and create a ticket?

Expected response themes:

- Depends on severity and environment.
- Dev may warn.
- Production may block.
- Policy should be clear.
- Exceptions should be documented.

Follow-up:

> “Would your answer differ for dev, staging, and prod?”

### Question 6

A production hotfix is blocked by a vulnerability scan during a major outage. What should happen?

Expected response themes:

- Follow emergency change process.
- Risk acceptance by proper owner.
- Time-bound exception.
- Post-incident remediation.
- Document decision.

Follow-up:

> “What evidence would you require before allowing the exception?”

### Question 7

Who owns DevSecOps controls in an enterprise team?

Expected response themes:

- Shared ownership.
- Security defines policy.
- DevOps implements pipeline gates.
- Developers fix code and dependencies.
- Cloud engineers secure IAM and infrastructure.
- SRE ensures controls do not harm incident response.

Follow-up:

> “How do you prevent DevSecOps from becoming everyone’s problem but nobody’s responsibility?”

### Question 8

How can DevSecOps improve reliability, not just security?

Expected response themes:

- Prevents risky releases.
- Reduces emergency incidents.
- Improves confidence in deployments.
- Makes rollback and release decisions clearer.
- Adds repeatable controls.

Follow-up:

> “What security finding could also cause an outage?”

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What does Trivy commonly scan in a DevSecOps pipeline?

A. Only Git branch names  
B. Container images and other artifact types  
C. AWS billing dashboards only  
D. DNS records only  

**Answer:** B  
**Explanation:** Trivy is commonly used to scan container images and can also support other scan types.

### Question 2: Multiple Choice

What does Checkov primarily help detect?

A. Broken unit tests  
B. Insecure infrastructure as code configuration  
C. High CPU usage  
D. DNS propagation delay  

**Answer:** B  
**Explanation:** Checkov scans IaC such as Terraform and Kubernetes YAML for policy and security issues.

### Question 3: Multiple Choice

A Terraform security group allows SSH from `0.0.0.0/0`. What is the main risk?

A. The instance cannot reach the internet  
B. SSH is open from anywhere on the internet  
C. Terraform will not format the file  
D. Docker image build will fail  

**Answer:** B  
**Explanation:** `0.0.0.0/0` means all IPv4 addresses, which exposes SSH broadly.

### Question 4: Multiple Choice

Which AWS service stores container images?

A. Amazon ECR  
B. Amazon Route 53  
C. AWS CloudTrail  
D. AWS Budgets  

**Answer:** A  
**Explanation:** Amazon Elastic Container Registry stores container images.

### Question 5: True or False

A container image can have vulnerabilities even if the application code is simple.

**Answer:** True  
**Explanation:** Images include OS packages, runtimes, and dependencies that may contain vulnerabilities.

### Question 6: True or False

ECR image scanning automatically fixes vulnerable images.

**Answer:** False  
**Explanation:** Scanning identifies issues. Engineers must rebuild or patch the image.

### Question 7: Short Answer

How does Class 2 extend the security gate concept from Class 1?

**Answer:**  
Class 1 focused on basic security gates and secret scanning. Class 2 extends that by adding container image scanning and Terraform/IaC scanning before deployment.

### Question 8: Short Answer

Name two actions a team can take when a critical image vulnerability is found.

**Answer:**  
Update the base image, update the vulnerable package, rebuild the image, re-run the scan, block deployment, or request a documented exception if appropriate.

### Question 9: Troubleshooting

A pipeline fails in `iac_scan` with a finding that SSH is open to `0.0.0.0/0`. What should the team do?

**Answer:**  
Restrict SSH to an approved CIDR, remove SSH access, or use a safer access method such as AWS Systems Manager Session Manager. Re-run the IaC scan after the fix.

### Question 10: Troubleshooting

A Trivy scan fails after detecting a CRITICAL vulnerability in the base image. Unit tests passed. Should the team ignore the scan because tests passed?

**Answer:**  
No. Unit tests validate application behavior, not image security. The vulnerability should be fixed, reviewed, or handled through an approved exception process.

### Question 11: AWS-Related

Why might a team use ECR scanning in addition to CI-based Trivy scanning?

**Answer:**  
CI scanning gives early feedback, while ECR scanning provides registry-level visibility and helps track vulnerabilities in stored images.

### Question 12: Class 1 and Class 2 Connection

What do secret scanning, image scanning, and IaC scanning have in common?

**Answer:**  
They are all automated DevSecOps controls that can be added to CI/CD pipelines to detect risk before deployment.

---

## 18. Homework Assignment

### Assignment Title

**Secure Delivery Policy for a Containerized Application**

### Scenario

Your organization deploys containerized applications to AWS. The security team requires a written policy explaining which pipeline checks are required before production deployment.

### Student Tasks

Create a secure delivery policy that includes:

1. Required pipeline stages (blocking, not `allow_failure`)
2. Secret scanning rules (gitleaks/trufflehog)
3. Container image scanning rules (scan the **built** image; Trivy + Grype)
4. Dockerfile hardening standard (multi-stage, non-root, distroless, digest-pinned)
5. IaC policy-as-code rules (Checkov + OPA/Conftest)
6. Supply-chain rules: SBOM (syft), image signing + verification (cosign), SLSA provenance
7. Admission-control rule (Kyverno: signed-images-only) and ECR scan-on-push
8. Severity thresholds and what blocks vs warns
9. Exception approval process (owner, expiry)
10. IAM least-privilege / OIDC keyless expectations
11. Secrets Manager usage expectations
12. Production approval rules and audit evidence

### Expected Deliverables

Submit a Markdown file:

```text
secure-delivery-policy.md
```

Required structure:

```text
# Secure Delivery Policy

## Application Context
## Required Pipeline Stages (blocking)
## Secret Scanning Rules
## Container Scanning Rules (built image; Trivy + Grype)
## Dockerfile Hardening Standard
## IaC Policy-as-Code Rules (Checkov + OPA/Conftest)
## Supply-Chain Rules (SBOM, cosign signing/verification, SLSA provenance)
## Admission Control (Kyverno signed-images-only)
## AWS Controls (ECR scan-on-push, OIDC, IAM, Secrets Manager)
## Blocking Criteria
## Warning Criteria
## Exception Process
## Production Approval Requirements
## Summary
```

### Submission Format

Markdown or PDF.

### Estimated Completion Time

90 minutes

### Grading Criteria

| Criteria | Weight |
|---|---:|
| Includes Class 1 and Class 2 controls | 20% |
| Clearly defines blocking vs warning rules | 20% |
| Includes AWS ECR, IAM, and Secrets Manager guidance | 20% |
| Includes realistic exception process | 15% |
| Includes practical production approval logic | 15% |
| Clear formatting and professional quality | 10% |

### Optional Advanced Challenge

Add a sample pipeline YAML snippet with:

- `secret_scan`
- `iac_scan`
- `container_scan`
- Manual production approval
- Separate dev and prod rules

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking app tests replace security scans | Students confuse functional tests with security validation | Explain different validation types |
| Assuming simple apps have no image risk | Students focus only on source code | Show image layers and OS packages |
| Using `latest` tags in production examples | It is convenient during labs | Teach pinned versions and controlled updates |
| Treating every scan finding as equal | Students may not understand severity | Teach severity, context, and exposure |
| Ignoring IaC security | Terraform looks like config, not code | Emphasize Terraform creates real resources |
| Disabling scans to make pipeline pass | Students focus on green pipeline only | Teach risk ownership and remediation |
| Opening SSH to the world | Common beginner shortcut | Use approved CIDR or SSM Session Manager |
| Not reading scanner output carefully | Output can be long | Teach students to find severity, resource, and file path |
| Forgetting to commit fixes | Git workflow gap | Use `git status` before push |
| Not cleaning up ECR images | Students forget registry cost/storage | Add cleanup checklist |

---

## 20. Real-World Enterprise Scenario

### Scenario

A retail company deploys a containerized order-processing application to AWS EKS. The DevOps team owns the pipeline. The Cloud Engineering team owns AWS infrastructure. The Security team owns policy. The SRE team owns production reliability.

A new release is ready for production, but the pipeline blocks the deployment because:

1. Trivy detects a critical vulnerability in the container base image.
2. Checkov detects an open SSH rule in Terraform.
3. The application team wants an urgent release before a business deadline.

### Constraints

- Production deployment requires approval.
- Security policy blocks critical vulnerabilities.
- Open SSH from the internet is not allowed.
- Pipeline roles must use least privilege.
- Secrets must come from Secrets Manager.
- Business wants release speed.
- SRE wants rollback safety.
- Cloud Engineering wants secure network standards.
- Security wants evidence and auditability.

### How the Class Topic Applies

The team must:

- Review image scan results.
- Patch or rebuild the container image.
- Fix Terraform security group rules.
- Re-run pipeline scans.
- Decide whether an exception is justified.
- Document risk acceptance if needed.
- Ensure AWS IAM permissions are scoped.
- Confirm the image pushed to ECR is approved.
- Keep deployment evidence for audit.

### What Each Role Would Do

| Role | Action |
|---|---|
| DevOps Engineer | Updates pipeline gates, runs scans, coordinates release |
| Cloud Engineer | Fixes Terraform network and IAM controls |
| SRE | Validates production risk, monitoring, and rollback readiness |
| Security Engineer | Reviews vulnerability and exception request |
| Developer | Updates application dependencies or base image |
| Engineering Manager | Approves business risk if exception is needed |

---

## 21. Instructor Tips

### Teaching Tips

- Keep Class 2 connected to Class 1.
- Reuse the phrase “security gate” throughout.
- Show that Class 2 adds deeper checks, not a new workflow.
- Use one clear image finding and one clear Terraform finding.
- Avoid turning the class into a vulnerability research lecture.
- Keep students focused on delivery decisions.

### Pacing Tips

- Do not spend more than 20 minutes on Trivy theory.
- Do not spend more than 20 minutes on Checkov theory.
- Prioritize hands-on interpretation of results.
- Leave enough time for troubleshooting discussion.
- Keep Azure/GCP comparison under 5 minutes.

### Lab Support Tips

Students may struggle with:

- YAML indentation
- Scanner output length
- Tool image entrypoints (`entrypoint: [""]`)
- Checkov/Conftest file paths
- Trivy database download time
- Docker-in-Docker setup for building the image (offer the `trivy fs` fallback)
- cosign keyless OIDC flow on first run

Help them by asking:

> “Which stage failed, what command failed, and what file or package did the scanner mention?”

### Helping Struggling Students

For students who are behind:

- Give them a working `.gitlab-ci.yml`.
- Ask them to focus only on reading the scan output.
- Pair them with another student.
- Let them submit a written analysis if their pipeline does not run.

### Challenging Advanced Students

Ask advanced students to:

- Add cosign keyless signing + verification and enforce it with Kyverno admission control.
- Generate and attach SLSA provenance (`actions/attest-build-provenance` on GitHub).
- Add branch-specific severity rules for production.
- Add ECR scan-on-push + EventBridge gating.
- Replace the base image with distroless and pin by digest; compare the CVE count before/after.
- Write an org-specific Conftest/Rego rule (mandatory tags, approved CIDR allowlist).
- Compare Trivy with Grype and reconcile disagreements by CVE.

---

## 22. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] Why container images need vulnerability scanning, and why you scan the built image
- [ ] What Trivy and Grype do and why you cross-check
- [ ] How to harden a Dockerfile (multi-stage, non-root, distroless, digest pin)
- [ ] What Checkov vs OPA/Conftest cover (managed rules vs custom Rego)
- [ ] What an SBOM, cosign signing, and SLSA provenance are and why they matter
- [ ] How Kyverno admission control enforces signed-images-only
- [ ] What ECR scan-on-push + EventBridge adds
- [ ] How Class 2 extends Class 1 gates; when a finding should block or warn

### Students Should Be Able to Build or Configure

- [ ] Build a hardened image and add a blocking container-scan job (built image)
- [ ] Add Checkov and OPA/Conftest IaC jobs
- [ ] Run/interpret Trivy and Grype image scans
- [ ] Generate an SBOM (syft) and sign + verify an image (cosign)
- [ ] Write a Kyverno signed-images-only admission policy
- [ ] Fix a Terraform security issue and document a secure delivery policy

### Students Should Be Able to Troubleshoot

- [ ] Failed container scan
- [ ] Failed IaC scan
- [ ] Scanner command failure
- [ ] YAML syntax issue
- [ ] Open security group finding
- [ ] Vulnerable base image finding
- [ ] Pipeline warning vs blocking behavior

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Reviewed Class 1 concepts
- [ ] Explained why container images need scanning
- [ ] Demonstrated Trivy scan or reviewed prepared output
- [ ] Explained ECR image scanning concepts
- [ ] Explained why IaC needs scanning
- [ ] Demonstrated Checkov scan or reviewed prepared output
- [ ] Gave students lab time
- [ ] Completed troubleshooting activity
- [ ] Assigned secure delivery policy homework
- [ ] Connected Class 2 back to Class 1
- [ ] Summarized end-of-week outcomes

### Student Checklist Before Leaving Class

- [ ] I understand how Class 2 builds from Class 1.
- [ ] I can explain why image scanning matters.
- [ ] I can explain why Terraform scanning matters.
- [ ] I can read basic Trivy output.
- [ ] I can read basic Checkov output.
- [ ] I can explain why open SSH is risky.
- [ ] I can explain what ECR image scanning does.
- [ ] I understand the homework deliverable.

### Items to Verify Before Closing the Week

Students should have:

- [ ] Completed or reviewed Class 1 secret scanning gate.
- [ ] Completed or reviewed Class 2 image scanning gate.
- [ ] Completed or reviewed Class 2 IaC scanning gate.
- [ ] Understood blocking vs warning behavior.
- [ ] Understood AWS services involved in secure delivery.
- [ ] Started or understood the secure delivery policy homework.

---

## 24. End-of-Week Summary

### What Students Learned This Week

This week, students learned how DevSecOps adds security controls into CI/CD pipelines. They practiced the idea that security should not be a final manual step after deployment. Instead, security should be part of the delivery workflow through automated checks, clear gates, least-privilege permissions, and documented policies.

Students learned about:

- DevSecOps as an operated scanning program (not just definitions)
- Threat modeling (STRIDE) and shift-left security
- Blocking security gates (no `allow_failure`) and exception handling
- Real SAST/SCA/secret scanning: semgrep, trivy, grype, gitleaks
- Pipeline identity: OIDC keyless auth and least privilege
- Hardened Dockerfiles: multi-stage, non-root, distroless, digest-pinned
- Container image scanning of the built artifact + Grype cross-check
- Policy-as-code: Checkov **and** OPA/Conftest
- Supply-chain integrity: SBOM (syft), signing + verification (cosign), SLSA provenance
- Admission control (Kyverno) and ECR scan-on-push
- Vulnerability-management lifecycle and secure delivery documentation

### How Class 1 and Class 2 Connect

Class 1 introduced the pipeline security gate using a simple secret scanning example.

Class 2 expanded that gate to cover:

- The built container image (hardened, scanned, signed)
- Terraform code via Checkov and OPA/Conftest policy-as-code
- Supply-chain integrity: SBOM, cosign signing/verification, SLSA provenance
- Admission control (Kyverno) and ECR scan-on-push
- Policy-based, signed-image-only deployment decisions

Together, both classes show that DevSecOps is not one tool. It is a delivery approach that checks multiple risk points before production.

### How This Week Prepares Students for the Next Week

This week prepares students for **Week 20: Platform Engineering and Golden Paths**.

Students now understand why platform teams create reusable secure templates, including:

- Standard pipeline stages
- Required scan jobs
- Approved base images
- Reusable Terraform modules
- Secure Helm charts
- Secrets handling patterns
- IAM role templates
- Production approval gates

Week 20 can build on this by showing how organizations turn DevSecOps controls (blocking gates, signed images, admission policies, golden Dockerfiles) into reusable golden paths for application teams.

### What Students Should Review Before the Next Module

Students should review:

- CI/CD stages and jobs
- Git branch and merge request workflows
- Secret scanning concepts
- Trivy scan output
- Checkov scan output
- AWS ECR basics
- AWS IAM least privilege
- AWS Secrets Manager basics
- Blocking vs warning security policy decisions

Final takeaway:

> “A secure delivery workflow checks code, secrets, images, infrastructure, identity, and deployment decisions before production risk reaches customers.”

---

## Class Artifacts & Validation

This class's runnable, on-disk artifacts live in
[`labs/cicd-pipelines/`](../../labs/cicd-pipelines/) (the advanced container-scan pipeline,
its GitLab mirror, and the hardened image) and
[`labs/security-automation/`](../../labs/security-automation/) (the OPA/Conftest
policy-as-code gate). Commands below were run in this environment. Static gates are `PASS`;
the live image scan (Trivy) is `DEFERRED` because Trivy is not installed here and no
captured live-scan evidence file exists — it is the documented command wired into the
pipeline, not a verified run.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/cicd-pipelines/solution/.github/workflows/ci-advanced.yml` | github-actions | The W19 depth pipeline: `lint → test → build IMAGE → scan`, with a **hard Trivy image gate** (`exit-code: "1"` on HIGH/CRITICAL) — the blocking image scan this class teaches | `actionlint solution/.github/workflows/ci-advanced.yml` + `python3 -m unittest discover -s tests` (TestCiAdvancedScanGate) | PASS (actionlint 1.7.3 clean; 24 workflow tests OK) |
| 2 | `labs/cicd-pipelines/solution/app/Dockerfile` | docker | Hardened, non-root (`appuser` uid 10001) image that is the scan target | `docker build -t app solution/app` + `/health` smoke test (in `validate.sh`) | PASS (~184 MB, HTTP 200) |
| 3 | `labs/cicd-pipelines/solution/.gitlab-ci.yml` | gitlab-ci | GitLab mirror of the advanced pipeline; `scan:trivy` with `allow_failure: false` — the GitLab equivalent of a hard gate | `yamllint -c .yamllint.yml solution/.gitlab-ci.yml` + `python3 -m unittest discover -s tests` | PASS (yamllint 1.38.0 clean; workflow tests OK) |
| 4 | `labs/security-automation/solution/policies/opa/s3_deny_public.rego` | rego | Policy-as-code rule denying public S3 access — the OPA/Conftest gate this class runs against config/infra | `opa test solution/policies/opa/s3_deny_public.rego solution/policies/opa/s3_deny_public_test.rego` + `conftest test --namespace s3.deny_public <fixture>` | PASS (opa 5/5; conftest denies bad, allows good) |
| 5 | `labs/security-automation/solution/policies/opa/fixtures/public-bucket-policy.json` | json | Pass/fail input the rego gate is graded against | `python3 -m json.tool` + `conftest test` (exit 1 = denied) | PASS |
| 6 | `labs/cicd-pipelines/broken/ci-bad-needs.yml` | github-actions | Reproducible broken fixture for the job-graph troubleshooting drill | `! actionlint broken/ci-bad-needs.yml` (must be rejected) | PASS (correctly rejected) |
| — | both labs, full suite | — | every gate in each module | `labs/cicd-pipelines/validate.sh` and `labs/security-automation/validate.sh` | PASS (31/0 + 6 DEFERRED; 24/0/0) |

**DEFERRED / NOT on disk in these backing labs (taught in prose this class, no runnable artifact here):**
- `trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 app` — the **live** image
  scan. Trivy is not installed in this env and no captured scan output exists, so this is
  DEFERRED, not PASS. The hard-gate *structure* (`exit-code: "1"`, no soft-fail) is asserted
  statically by `TestCiAdvancedScanGate`.
- **Terraform + Checkov** scanning, **cosign** image signing, **SLSA provenance**, and the
  **Kyverno** admission controller are discussed conceptually but ship **no** `.tf`, cosign, or
  Kyverno manifest in these two labs. They are Explained, not Practiced — reflected in the score.

## Definition of Done

Ticked honestly for this class against the standard's §5 checklist.

- [x] Every technology taught **that ships an artifact** has a **runnable file on disk** — `ci-advanced.yml`, the hardened `Dockerfile`, `.gitlab-ci.yml`, and the OPA rego are real files.
- [x] Each on-disk artifact passes (or documents) its **validation gate** from §3 — `actionlint`, `docker build` + `/health`, `yamllint`, `opa test`, and `conftest` all ran green above.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — both modules ship `starter/` (the `scan` job / `needs:` are TODO) and a reference `solution/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — both module READMEs do.
- [x] **Cleanup/teardown** is provided and idempotent — both labs are local/`$0`; the docker gate removes its image and caches.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — `solution/` + the README answer-key sections; this class file carries the homework/quiz keys.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/cicd-pipelines/broken/ci-bad-needs.yml`.
- [x] **Expected outputs** are shown — `validate.sh` transcripts, the ~184 MB image / HTTP 200 `/health`, and `opa test` 5/5 are captured in the READMEs.
- [x] **Cost & security warnings** present — both READMEs cover non-root images, no long-lived keys, ECR/Fargate cost notes.
- [x] **Cross-references** correct — links to W9 (advanced variant), W10 (container), W20 (golden paths) verified.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`; all six rows resolve.
- [ ] **Live image-scan / signing / admission-control evidence** — *not done.* The live Trivy image scan is DEFERRED (no Trivy, no captured run), and Terraform/Checkov, cosign signing, SLSA provenance, and Kyverno ship **no** runnable artifact in these labs (prose only). This is the honest gap that caps the score.
