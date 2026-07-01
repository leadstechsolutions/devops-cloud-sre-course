# Week 1, Class 2: Lab Environment Setup and First Cloud Toolchain Validation

**Course:** Enterprise DevOps, Cloud Engineering, and Site Reliability Engineering Program  
**Week:** 1  
**Module:** DevOps, Cloud, and SRE Career Foundations  
**Class:** 2 of 2  
**Track:** Unified DevOps · Cloud · SRE Track  
**Duration:** 3 hours  
**Primary cloud:** AWS  
**Secondary cloud exposure:** Azure and GCP  
**Audience:** Beginner to intermediate learners  

---

> **▶ Runnable lab for this class:** [`labs/setup-validation/`](../../labs/setup-validation/)
>
> The **on-disk, validated** version of this class's work — clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check against `solution/`, then run `./validate.sh`.

## 1. Class Overview

Class 2 continues directly from Class 1. In Class 1, students learned what DevOps Engineers, Cloud Engineers, SREs, Platform Engineers, and Production Support Engineers do in a real enterprise environment.

Class 2 turns that role awareness into a practical starting point by helping students validate the tools they will use throughout the course.

Students will work with the terminal, VS Code, Git, AWS CLI, Docker, Terraform, and browser-based cloud consoles. They will not go deep into each tool yet. The goal is to confirm that the local workstation is ready, understand why each tool matters, and troubleshoot common beginner setup issues.

By the end of Class 2, students should have a basic course folder, a setup validation file, and a clear understanding of how their laptop connects to Git and cloud environments.

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. Validate required local tools.
2. Understand why each tool is used in DevOps, Cloud, and SRE work.
3. Use basic terminal commands.
4. Understand AWS Console, regions, and Availability Zones at a high level.
5. Compare AWS Console, Azure Portal, and GCP Console at a beginner level.
6. Troubleshoot common setup issues.

---

## 3. Quick Review of Class 1

### Review Goal

Reconnect Class 2 to Class 1 before moving into hands-on setup validation.

### Instructor Review Points

In Class 1, students learned:

| Role | Main Focus |
|---|---|
| DevOps Engineer | Automates build, test, deployment, and release workflows |
| Cloud Engineer | Designs and manages cloud infrastructure, networking, IAM, storage, and security |
| SRE | Improves reliability, observability, incident response, and production readiness |
| Platform Engineer | Builds reusable internal platforms, templates, and golden paths |
| Production Support Engineer | Helps operate, troubleshoot, and support live systems |

### Key Connection to Class 2

Class 1 answered:

```text
What do these roles do?
```

Class 2 answers:

```text
What tools do these roles use every day, and is my workstation ready to start learning them?
```

### Short Instructor Prompt

Ask students:

1. Which role focuses most on CI/CD and automation?
2. Which role focuses most on cloud infrastructure?
3. Which role focuses most on production reliability?
4. Which tools did you see in Class 1 that you already recognize?
5. Which tools are completely new to you?

---

## 4. Prerequisites Students Should Already Know

Students should already understand from Class 1:

| Area | Expected Understanding |
|---|---|
| Role awareness | Basic difference between DevOps, Cloud Engineering, and SRE |
| Production mindset | Live systems require careful changes and troubleshooting |
| Toolchain awareness | DevOps and cloud roles use terminal, Git, cloud consoles, CLI tools, and documentation |
| Course expectation | Students will learn by doing labs, troubleshooting, and documenting work |

Students do **not** need to already know:

- Linux administration
- AWS CLI configuration
- Docker usage
- Terraform syntax
- Kubernetes
- CI/CD pipelines

Those topics will be taught later.

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Why It Matters |
|---|---|---|
| Workstation | The student’s laptop or desktop used for labs | This is the control center for course work |
| Terminal | A command-line tool used to run commands | DevOps, cloud, and SRE work often starts here |
| Shell | The program that interprets terminal commands | Examples include Bash, Zsh, PowerShell |
| CLI | Command-Line Interface | Used to automate and interact with tools |
| PATH | System setting that tells the terminal where to find commands | Missing PATH entries cause “command not found” errors |
| Version command | A command that checks if a tool is installed | Example: `git --version` |
| Git repository | A folder tracked by Git | Used for scripts, code, infrastructure, and documentation |
| AWS CLI | Command-line tool for AWS | Used to inspect and automate AWS resources |
| AWS Console | Browser-based AWS interface | Useful for learning, inspection, and administration |
| AWS Region | Geographic AWS location where services run | Example: `us-east-1` |
| Availability Zone | Isolated data center zone inside an AWS Region | Used for high availability |
| Docker | Tool for building and running containers | Used later for application packaging |
| Terraform | Infrastructure as Code tool | Used later to provision AWS resources |
| Cloud profile | Named set of cloud CLI credentials and configuration | Helps separate environments and accounts |
| Validation | Confirming something works as expected | Essential in troubleshooting |
| Expected output | The result a student should see after running a command | Helps students know whether they are on track |

---

## 6. Tools Used

| Tool | Used in Class 2 For | Used Later For |
|---|---|---|
| Terminal | Running setup and validation commands | Linux, Git, AWS CLI, Docker, Terraform, Kubernetes |
| VS Code | Creating and editing course files | Scripts, YAML, Terraform, Kubernetes manifests, documentation |
| Git | Initializing a local repository and tracking files | Collaboration, CI/CD, Infrastructure as Code |
| AWS CLI | Validating installation and optional identity check | AWS automation and troubleshooting |
| AWS Console | High-level navigation and region awareness | IAM, VPC, EC2, S3, EKS, CloudWatch |
| Docker | Validating container tool availability | Container labs in Week 10 |
| Terraform | Validating IaC tool availability | Infrastructure labs in Weeks 14 and 15 |
| Browser | Accessing AWS Console and documentation | Cloud portals, Git platforms, documentation |

---

## 7. AWS Services Used

Class 2 uses AWS mainly for orientation and validation.

| AWS Service or Concept | How It Is Used |
|---|---|
| AWS Console | Students learn how to navigate the main console |
| AWS Regions | Students learn where resources are created |
| Availability Zones | Students learn the basic high-availability concept |
| IAM | Mentioned as the service behind access and identity |
| STS | Optional `aws sts get-caller-identity` command if credentials are configured |
| Billing/Budgets | Mentioned as part of cost safety |
| EC2 | Shown as a compute service students will use later |
| S3 | Shown as storage service students will use later |
| CloudWatch | Shown as monitoring service students will use later |

Important note: Students should not create AWS resources in this class unless the instructor has already provided a controlled lab environment.

---

## 8. Azure/GCP Comparison Notes

Keep this section brief. The goal is to help students recognize that the same ideas exist in other cloud providers.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Browser console | AWS Console | Azure Portal | Google Cloud Console |
| CLI | AWS CLI | Azure CLI | gcloud CLI |
| Account boundary | AWS Account | Azure Subscription | GCP Project |
| Geographic location | Region | Region | Region |
| Data center zone | Availability Zone | Availability Zone | Zone |
| Identity and access | IAM | Microsoft Entra ID and Azure RBAC | Cloud IAM |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |

Instructor guidance:

> Every cloud has a console, CLI, identity system, regions, and monitoring. This course teaches AWS first, then uses Azure and GCP comparisons so students can recognize similar patterns in other environments.

---

## 9. Time-Boxed Instructor Agenda

| Time | Topic | Instructor Goal |
|---:|---|---|
| 0:00 to 0:15 | Review of Class 1 and homework expectations | Connect role awareness to tool usage |
| 0:15 to 0:40 | Local environment checklist | Explain required tools and why they matter |
| 0:40 to 1:05 | Terminal basics and command validation | Build comfort with basic command-line use |
| 1:05 to 1:30 | Git, AWS CLI, Docker, Terraform validation | Validate key tools |
| 1:30 to 1:40 | Break | Reset |
| 1:40 to 2:05 | AWS Console, regions, and Availability Zones overview | Introduce AWS navigation safely |
| 2:05 to 2:25 | Azure Portal and GCP Console high-level comparison | Build multi-cloud awareness |
| 2:25 to 2:50 | Guided troubleshooting lab | Diagnose common setup problems |
| 2:50 to 3:00 | Recap and Week 2 preparation | Confirm readiness for Linux fundamentals |

---

## 10. Instructor Lesson Plan

### Opening Review: 0:00 to 0:15

#### Instructor Goal

Help students connect Class 1 role concepts to today’s hands-on setup work.

#### Instructor Script

> In Class 1, we talked about the roles: DevOps, Cloud Engineering, SRE, Platform Engineering, and Production Support. Today we start preparing the workstation that supports all of those roles. The tools may look simple today, but these are the same types of tools engineers use in real environments.

#### Instructor Actions

Ask students to answer:

- What does Git help us do?
- Why do cloud engineers use CLI tools?
- Why does an SRE need terminal skills?
- Why do we document setup issues?

#### Reinforcement

Tell students that setup errors are not failures. They are the first troubleshooting exercises of the course.

---

### Segment 1: Local Environment Checklist: 0:15 to 0:40

#### Instructor Goal

Explain the required tools and how they fit into the full course.

#### Required Tools

| Tool | Why Students Need It |
|---|---|
| VS Code | Write and edit files |
| Terminal | Run commands |
| Git | Track changes |
| AWS CLI | Interact with AWS |
| Docker | Build and run containers |
| Terraform | Provision infrastructure |
| Browser | Access AWS Console and documentation |

#### Instructor Explanation

Students should understand:

- These tools will not all be mastered today.
- Today is only validation and orientation.
- Missing tools should be documented clearly.
- Version differences are normal, but very old versions may create issues later.

#### Enterprise Context

In an enterprise team, onboarding a new engineer often includes validating:

- Laptop setup
- Access permissions
- CLI tools
- Repository access
- Cloud account access
- Security tools
- Documentation links

This class simulates the beginning of that onboarding process.

#### Awareness Note: Cloud and Containerized Dev Environments

Installing tools locally is the most common starting point, and it is what most of this course assumes. But students should know that many 2026 teams avoid local tool sprawl (and the "works on my machine" problem this class spends time on) by using a **standardized, containerized development environment**:

- **Dev Containers (`.devcontainer`)**: a definition checked into the repo that describes the exact tools, versions, and extensions; VS Code (or another editor) builds that container so everyone gets an identical environment.
- **GitHub Codespaces**: a cloud-hosted dev container you open in the browser or your editor, so the toolchain runs on a remote machine instead of your laptop.

The benefit is consistency: the AWS CLI, Docker, Terraform, and Git versions are pinned for the whole team. The course teaches local setup so students understand what is happening under the hood; recognize that dev containers and Codespaces are the production-grade way teams solve the setup problem.

---

### Segment 2: Terminal Basics and Command Validation: 0:40 to 1:05

#### Instructor Goal

Build comfort with basic command-line navigation and version checks.

#### Teach These Commands

| Command | Purpose |
|---|---|
| `pwd` | Print current directory |
| `ls` | List files on macOS/Linux/Git Bash |
| `dir` | List files on Windows PowerShell or Command Prompt |
| `mkdir` | Create directory |
| `cd` | Change directory |
| `touch` | Create file on macOS/Linux/Git Bash |
| `New-Item` | Create file in PowerShell |
| `--version` | Common way to check installed tool version |

#### Demo Commands

```bash
pwd
mkdir devops-cloud-sre-course
cd devops-cloud-sre-course
pwd
```

Expected output example:

```text
/Users/student/devops-cloud-sre-course
```

Windows PowerShell example:

```powershell
mkdir devops-cloud-sre-course
cd devops-cloud-sre-course
Get-Location
```

Expected output example:

```text
Path
----
C:\Users\student\devops-cloud-sre-course
```

#### Instructor Emphasis

The terminal is not just for developers. Cloud engineers and SREs use terminal commands constantly for validation, automation, and troubleshooting.

---

### Segment 3: Git, AWS CLI, Docker, and Terraform Validation: 1:05 to 1:30

#### Instructor Goal

Have students validate whether core tools are installed and working.

#### Instructor Demo Commands

```bash
git --version
aws --version
docker --version
terraform version
code --version
```

#### Expected Output Examples

Git:

```text
git version 2.43.0
```

AWS CLI:

```text
aws-cli/2.15.0 Python/3.11.0
```

Docker:

```text
Docker version 25.0.0
```

Terraform:

```text
Terraform v1.6.0
```

VS Code:

```text
1.85.0
```

#### Instructor Notes

Students may see different versions. That is acceptable as long as the command works and the version is reasonably current.

Do not spend the entire class fixing every installation issue. Have students document issues and continue with the conceptual flow.

---

### Break: 1:30 to 1:40

Encourage students to save their setup notes.

---

### Segment 4: AWS Console, Regions, and Availability Zones: 1:40 to 2:05

#### Instructor Goal

Introduce AWS Console navigation safely and explain regions and Availability Zones.

#### Teach

AWS Console is the browser-based management interface for AWS services.

Students should understand:

- AWS services are accessed from the console search bar.
- Many resources are regional.
- Always check the selected region before creating or inspecting resources.
- Availability Zones are isolated locations inside a region.
- Cloud costs can occur if resources are created and left running.

#### AWS Region Explanation

```text
AWS Region:
A geographic area where AWS hosts cloud services.

Example:
us-east-1 means US East, Northern Virginia.
```

#### Availability Zone Explanation

```text
Availability Zone:
An isolated data center location inside a region.

Example:
us-east-1a, us-east-1b, us-east-1c
```

#### Instructor Console Tour

Show:

1. AWS Console landing page
2. Region selector
3. Search bar
4. IAM service
5. EC2 service
6. S3 service
7. CloudWatch service
8. Billing or Budgets area, if permitted

#### Cost Safety Message

Students should not create random resources. Every cloud lab must include a cleanup step.

---

### Segment 5: Azure Portal and GCP Console Comparison: 2:05 to 2:25

#### Instructor Goal

Give students enough multi-cloud context without distracting from AWS.

#### Teach

Most enterprise cloud tools have similar categories:

| Category | AWS | Azure | GCP |
|---|---|---|---|
| Console | AWS Console | Azure Portal | Google Cloud Console |
| CLI | AWS CLI | Azure CLI | gcloud CLI |
| Identity | IAM | Entra ID / RBAC | Cloud IAM |
| Compute | EC2 | Virtual Machines | Compute Engine |
| Storage | S3 | Blob Storage | Cloud Storage |
| Kubernetes | EKS | AKS | GKE |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |

#### Instructor Talking Point

Once students understand the cloud pattern in AWS, it becomes easier to understand similar services in Azure and GCP.

---

### Segment 6: Guided Troubleshooting Lab: 2:25 to 2:50

#### Instructor Goal

Turn setup errors into structured troubleshooting practice.

#### Troubleshooting Process

Teach this simple flow:

```text
1. What command did you run?
2. What exact error did you receive?
3. Is the tool installed?
4. Is it available in PATH?
5. Are you in the right terminal?
6. Did the terminal need to be restarted?
7. Is the issue credentials, permissions, or installation?
8. What is the next safest step?
```

#### Common Issues

| Symptom | Likely Category |
|---|---|
| `command not found` | Tool missing or PATH issue |
| `Unable to locate credentials` | AWS CLI installed but not configured |
| `Cannot connect to Docker daemon` | Docker installed but not running |
| `Author identity unknown` | Git username/email not configured |
| `terraform: command not found` | Terraform missing or PATH issue |

#### Instructor Emphasis

Students should document problems clearly. In real enterprise work, a good issue report is often more useful than a vague “it does not work.”

---

### Wrap-Up: 2:50 to 3:00

#### Instructor Goal

Confirm students are ready for Week 2 Linux Fundamentals.

#### Wrap-Up Points

Students should have:

- A course folder
- A setup validation file
- Version output for key tools
- A list of any missing tools or errors
- Basic AWS Console awareness
- Understanding of region and Availability Zone concepts

#### Preview Week 2

Week 2 will begin Linux fundamentals, including:

- Files and directories
- Permissions
- Users and groups
- Processes
- Services
- Logs
- SSH
- Basic troubleshooting

---

## 11. Instructor Lecture Notes

### Main Teaching Message

Class 2 is about turning role awareness into tool readiness. Students should leave with confidence that they can open a terminal, run validation commands, document results, and troubleshoot common setup problems.

Do not try to teach all of Git, AWS, Docker, or Terraform in depth. This class introduces the tools so students recognize them when they appear in later weeks.

### Lecture Notes: Why Setup Validation Matters

In real enterprise environments, engineers cannot work effectively if they do not have the right tools or access. A new engineer joining a cloud platform team may spend the first few days validating:

- Laptop tools
- VPN or network access
- Git repository access
- Cloud account access
- CLI credentials
- Security permissions
- Documentation links
- Team communication channels

The same principle applies to this course. Before students can build infrastructure, write scripts, deploy containers, or troubleshoot Kubernetes, they need a reliable local environment.

### Lecture Notes: Terminal as a Core Skill

The terminal is a common interface across DevOps, Cloud Engineering, and SRE roles.

DevOps engineers use terminal commands to:

- Run Git commands
- Trigger local scripts
- Test build commands
- Debug pipelines

Cloud engineers use terminal commands to:

- Run AWS CLI checks
- Execute Terraform
- Validate network connectivity
- Inspect configuration

SREs use terminal commands to:

- Inspect logs
- Check services
- Query metrics
- Troubleshoot incidents
- Run operational scripts

Use this phrase:

> The terminal is not advanced magic. It is just a direct way to ask the system questions and tell it what to do.

### Lecture Notes: AWS Console vs AWS CLI

The AWS Console is useful for:

- Learning services visually
- Inspecting resources
- Understanding relationships
- Quick demonstrations
- Reviewing dashboards

The AWS CLI is useful for:

- Automation
- Repeatability
- Scripting
- Bulk inspection
- Troubleshooting
- Working in pipelines

Both matter. Students should not think console is “bad” or CLI is “only for experts.” Real engineers use both, but production changes should become automated, reviewed, and repeatable over time.

### Lecture Notes: Region Awareness

One of the earliest cloud mistakes is checking or creating resources in the wrong region.

Example:

A student creates an EC2 instance in `us-east-1`, but later looks for it in `us-west-2` and thinks it disappeared.

In enterprise environments, region choice affects:

- Latency
- Availability
- Disaster recovery
- Cost
- Compliance
- Data residency
- Service availability

For Week 1, keep the message simple:

> Always check your region before creating or troubleshooting cloud resources.

### Lecture Notes: Troubleshooting Setup Issues

Setup problems are the first safe troubleshooting exercises. They do not affect production systems, but they teach important habits:

- Read the exact error
- Copy the command that failed
- Identify what changed
- Separate installation issues from credential issues
- Document the fix
- Ask clear questions

Use this phrase:

> A good engineer does not just say, “It failed.” A good engineer says, “I ran this command, got this error, checked these things, and I think the next step is this.”

---

## 12. Whiteboard Explanation

### Whiteboard Topic

**Student Laptop as the DevOps Control Center**

```text
Student Laptop
    |
    |-- VS Code
    |     |-- Write notes
    |     |-- Edit scripts
    |     |-- Edit YAML
    |     |-- Edit Terraform
    |
    |-- Terminal
    |     |-- Run commands
    |     |-- Validate tools
    |     |-- Troubleshoot errors
    |
    |-- Git
    |     |-- Track changes
    |     |-- Collaborate
    |     |-- Store course work
    |
    |-- AWS CLI
    |     |-- Query AWS identity
    |     |-- Inspect resources
    |     |-- Automate tasks
    |
    |-- Docker
    |     |-- Build containers
    |     |-- Run containers locally
    |
    |-- Terraform
          |-- Define infrastructure
          |-- Plan changes
          |-- Apply changes
```

### Cloud Connection Diagram

```text
Student Laptop
    |
    |-- Browser ------------------> AWS Console
    |
    |-- AWS CLI ------------------> AWS APIs
    |
    |-- Terraform ----------------> AWS APIs
    |
    |-- Git ----------------------> GitHub or GitLab
    |
    |-- Docker -------------------> Local container runtime / registry later
```

### Instructor Explanation

Explain the key idea:

- The browser helps students inspect and learn.
- The terminal helps students validate, automate, and troubleshoot.
- Git helps students track all work.
- AWS CLI and Terraform interact with AWS APIs.
- Docker helps package applications.
- These same patterns will appear throughout the entire course.

### AWS Region Sketch

```text
AWS Region: us-east-1
    |
    |-- Availability Zone: us-east-1a
    |-- Availability Zone: us-east-1b
    |-- Availability Zone: us-east-1c
```

### Instructor Explanation

A region is a geographic AWS location. Availability Zones are isolated locations inside that region. Later, when students build VPCs and deploy applications, they will place resources across Availability Zones for reliability.

---

## 13. Instructor Demo Script

### Demo Title

**Validating the Course Workstation**

### Demo Goal

Show students how to verify their workstation and create their first course workspace.

### Demo Prerequisites

Instructor should have:

- Terminal open
- VS Code installed
- Git installed
- AWS CLI installed
- Docker installed or ready to discuss if not running
- Terraform installed
- Browser available
- AWS Console access if possible

---

### Demo Part 1: Create Course Workspace

#### Instructor Command

```bash
pwd
mkdir devops-cloud-sre-course
cd devops-cloud-sre-course
pwd
```

#### Expected Output Example

```text
/Users/instructor/devops-cloud-sre-course
```

#### Instructor Talking Points

This folder will become the student’s local workspace for notes, scripts, labs, and later Git repositories.

---

### Demo Part 2: Create Basic Setup File

#### macOS/Linux/Git Bash

```bash
touch setup-validation.md
ls
```

#### Windows PowerShell

```powershell
New-Item setup-validation.md
dir
```

#### Expected Output Example

```text
setup-validation.md
```

#### Instructor Talking Points

Engineers document setup status because it helps with support, onboarding, and troubleshooting.

---

### Demo Part 3: Validate Git

#### Command

```bash
git --version
```

#### Expected Output Example

```text
git version 2.43.0
```

#### Optional Git Initialization

```bash
git init
git status
```

#### Expected Output Example

```text
Initialized empty Git repository
On branch main

No commits yet
```

#### Instructor Talking Points

Git will track everything we build: scripts, Terraform, Kubernetes YAML, documentation, and project work.

---

### Demo Part 4: Validate AWS CLI

#### Command

```bash
aws --version
```

#### Expected Output Example

```text
aws-cli/2.15.0 Python/3.11.0
```

#### Optional Command if Credentials Are Configured

```bash
aws sts get-caller-identity
```

#### Expected Output Example

```json
{
    "UserId": "AIDAEXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/example-user"
}
```

#### Instructor Talking Points

Today, `aws --version` is enough to validate installation. The identity command only works if credentials are already configured.

#### Important Warning

Do not have students configure random personal credentials without clear lab account guidance.

#### The Right Way to Authenticate in 2026: IAM Identity Center (SSO)

Earlier versions of this lesson said "do not configure random credentials" but never showed the correct path. Here it is, at an awareness level. The modern, recommended way to give the AWS CLI credentials is **AWS IAM Identity Center (formerly AWS SSO)**, which issues **short-lived credentials** that refresh automatically. This avoids long-lived IAM access keys, which are a security liability (they leak, they never expire, they are hard to rotate).

The one-time setup, when an instructor or organization has Identity Center enabled, looks like this:

```bash
aws configure sso
```

This walks through an interactive prompt for the SSO start URL, SSO region, the AWS account and permission set (role) you are allowed to use, and a profile name. After setup, you log in with:

```bash
aws sso login --profile my-sso-profile
```

A browser window opens for you to approve the login, and the CLI receives temporary credentials. You then run commands against that profile:

```bash
aws sts get-caller-identity --profile my-sso-profile
```

When the temporary session expires, you simply run `aws sso login` again. No access keys are stored on disk.

> Instructor note: This is awareness only in Week 1. Do NOT require students to complete SSO setup today, because it depends on an Identity Center directory that is created in Week 4 (AWS Cloud Foundations) and built on in Week 6 (Cloud Security & IAM). The teaching point now is simply: when this course or a real employer asks you to authenticate the CLI, the answer is SSO / Identity Center with short-lived credentials, not pasting long-lived access keys.

---

### Demo Part 5: Validate Docker

#### Command

```bash
docker --version
```

#### Expected Output Example

```text
Docker version 25.0.0
```

#### Optional Command

```bash
docker info
```

#### Possible Error

```text
Cannot connect to the Docker daemon
```

#### Instructor Talking Points

If `docker --version` works but `docker info` fails, Docker may be installed but not running. That is a different problem than Docker not being installed.

---

### Demo Part 6: Validate Terraform

#### Command

```bash
terraform version
```

#### Expected Output Example

```text
Terraform v1.6.0
```

#### Instructor Talking Points

Terraform will be used later to create cloud infrastructure from code. Today we only confirm the command is available.

#### OpenTofu Awareness Note

Any 2026 candidate should know that Terraform's license changed (HashiCorp moved Terraform to the Business Source License in 2023), which led to a community fork called **OpenTofu** (`tofu`). OpenTofu is an open-source, drop-in alternative whose CLI mirrors Terraform's: `tofu init`, `tofu plan`, `tofu apply`. This course standardizes on Terraform for teaching, but the workflow and HCL you learn transfer directly to OpenTofu. If a student has `tofu` installed instead of `terraform`, that is acceptable, run `tofu version`. Deeper Terraform/OpenTofu work begins in Week 14.

---

### Demo Part 7: Validate VS Code Command

#### Command

```bash
code --version
```

#### Expected Output Example

```text
1.85.0
```

#### Possible Issue

If the command fails, VS Code may still be installed, but the terminal command is not configured.

#### Instructor Talking Points

This is a common PATH issue. We can still use VS Code manually, but adding the `code` command is helpful.

---

### Demo Part 8: AWS Console Tour

#### Instructor Actions

Open AWS Console and show:

1. Console home page
2. Region selector
3. Service search
4. IAM
5. EC2
6. S3
7. CloudWatch
8. Billing or Budgets, if available

#### Instructor Talking Points

Today we are observing. We are not creating resources. Cloud cost awareness starts from Day 1.

---

### Demo Wrap-Up

End with this summary:

```text
A ready workstation should have:
- A working terminal
- VS Code available
- Git available
- AWS CLI available
- Docker available or documented issue
- Terraform available
- Browser access to cloud consoles
- A setup validation file
```

---

## 14. Student Lab Manual

### Lab Title

**Week 1 Workstation Validation Lab**

### Lab Objective

Validate your local workstation and create a documented setup report for the course.

### Estimated Time

45 to 60 minutes

### Student Role

You are a new cloud platform team member. Your first task is to validate your workstation before receiving production-level tasks.

### Tools Required

- Terminal
- VS Code
- Git
- AWS CLI
- Docker
- Terraform
- Browser

---

### Lab Safety Notes

Do not create AWS resources in this lab.

This lab only validates tools and explores the AWS Console at a high level.

---

### Step 1: Open Terminal

Open the correct terminal for your operating system.

| Operating System | Recommended Terminal |
|---|---|
| Windows | Windows Terminal, PowerShell, Git Bash, or WSL |
| macOS | Terminal |
| Linux | Terminal |

---

### Step 2: Create Your Course Folder

Run:

```bash
mkdir devops-cloud-sre-course
cd devops-cloud-sre-course
```

Validate your location:

```bash
pwd
```

Expected output example on macOS/Linux:

```text
/Users/student/devops-cloud-sre-course
```

Expected output example on Windows Git Bash:

```text
/c/Users/student/devops-cloud-sre-course
```

Expected output example on Windows PowerShell:

```text
C:\Users\student\devops-cloud-sre-course
```

---

### Step 3: Create a Setup Validation File

macOS/Linux/Git Bash:

```bash
touch setup-validation.md
```

Windows PowerShell:

```powershell
New-Item setup-validation.md
```

Open the file in VS Code.

```bash
code setup-validation.md
```

If `code` does not work, open VS Code manually and open the file from the folder.

---

### Step 4: Add Setup Report Template

Copy this into `setup-validation.md`:

```markdown
# Week 1 Setup Validation

Name:
Date:
Operating system:
Terminal used:

## Tool Validation

| Tool | Command | Installed? | Version or Output | Issue |
|---|---|---|---|---|
| Git | git --version |  |  |  |
| AWS CLI | aws --version |  |  |  |
| Docker | docker --version |  |  |  |
| Docker Info | docker info |  |  |  |
| Terraform | terraform version |  |  |  |
| VS Code CLI | code --version |  |  |  |

## AWS Console Check

Can access AWS Console? Yes/No:
Region selected:
Services observed:

## Issues Found

1.
2.
3.

## Troubleshooting Steps Tried

1.
2.
3.

## Questions for Instructor

1.
2.
```

---

### Step 5: Validate Git

Run:

```bash
git --version
```

Expected output example:

```text
git version 2.43.0
```

Record the result in your setup file.

---

### Step 6: Initialize a Git Repository

Run:

```bash
git init
git status
```

Expected output example:

```text
Initialized empty Git repository
On branch main

No commits yet
```

Now add your setup file:

```bash
git add setup-validation.md
git status
```

Expected output example:

```text
Changes to be committed:
  new file: setup-validation.md
```

Do not worry if your default branch says `master` instead of `main`. That can be adjusted later.

---

### Step 7: Validate AWS CLI

Run:

```bash
aws --version
```

Expected output example:

```text
aws-cli/2.15.0 Python/3.11.0
```

Record your result.

Optional only if your instructor has already provided credentials:

```bash
aws sts get-caller-identity
```

Expected output example:

```json
{
    "UserId": "EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/student"
}
```

If you see this error:

```text
Unable to locate credentials
```

That means AWS CLI is installed but not configured with credentials. Record it. This is not a failure for Week 1 unless credentials were required by your instructor.

---

### Step 8: Validate Docker

Run:

```bash
docker --version
```

Expected output example:

```text
Docker version 25.0.0
```

Then run:

```bash
docker info
```

If Docker is running, you will see information about the Docker client and server.

If Docker is not running, you may see:

```text
Cannot connect to the Docker daemon
```

Record the result.

---

### Step 9: Validate Terraform

Run:

```bash
terraform version
```

Expected output example:

```text
Terraform v1.6.0
```

Record your result.

---

### Step 10: Validate VS Code CLI

Run:

```bash
code --version
```

Expected output example:

```text
1.85.0
```

If this fails, VS Code may still be installed, but the command-line launcher is not configured. Record it.

---

### Step 11: AWS Console Orientation

Open the AWS Console in your browser.

Complete the following:

1. Identify the current AWS Region.
2. Search for IAM.
3. Search for EC2.
4. Search for S3.
5. Search for CloudWatch.
6. Do not create any resources.

Record:

```text
AWS Console accessible:
Current region:
Services found:
1.
2.
3.
4.
```

---

### Step 12: Final Lab Check

Your folder should contain:

```text
devops-cloud-sre-course/
  setup-validation.md
```

If you initialized Git, run:

```bash
git status
```

Expected output may show your file staged or modified.

---

### Lab Deliverable

Submit:

1. `setup-validation.md`
2. Screenshot or copied output of tool validation commands
3. Any error messages you encountered
4. A short note explaining what you need help fixing before Week 2

---

### Lab Success Criteria

You completed the lab if:

| Requirement | Complete |
|---|---|
| Created course folder | Yes/No |
| Created setup validation file | Yes/No |
| Ran Git validation | Yes/No |
| Ran AWS CLI validation | Yes/No |
| Ran Docker validation | Yes/No |
| Ran Terraform validation | Yes/No |
| Checked AWS Console region | Yes/No |
| Documented issues clearly | Yes/No |

---

## 15. Troubleshooting Activity

### Activity Title

**Classify and Resolve Setup Errors**

### Objective

Students will practice diagnosing setup problems using real error messages.

### Troubleshooting Method

For every error, students should answer:

```text
1. What command was run?
2. What was the exact error?
3. Is this an installation issue?
4. Is this a PATH issue?
5. Is this a credentials issue?
6. Is this a service-not-running issue?
7. What is the next safe troubleshooting step?
```

---

### Scenario 1: AWS CLI Not Found

#### Command

```bash
aws --version
```

#### Error

```text
command not found: aws
```

#### Likely Cause

AWS CLI is not installed or not available in PATH.

#### Troubleshooting Steps

1. Confirm AWS CLI installation.
2. Restart terminal.
3. Check PATH.
4. Confirm correct terminal is being used.
5. Reinstall AWS CLI if needed.

#### Instructor Explanation

This is not an AWS permissions problem. The local machine cannot find the `aws` command.

---

### Scenario 2: AWS CLI Installed but Credentials Missing

#### Command

```bash
aws sts get-caller-identity
```

#### Error

```text
Unable to locate credentials
```

#### Likely Cause

AWS CLI is installed, but credentials are not configured.

#### Troubleshooting Steps

1. Confirm whether credentials were required for this class.
2. Check configured profiles:

```bash
aws configure list
```

3. Confirm with instructor before adding credentials. When credentials ARE required (Week 4 onward), the correct path is IAM Identity Center: `aws configure sso` once, then `aws sso login --profile <name>`, which provides short-lived credentials. Do not create or paste long-lived access keys.

#### Instructor Explanation

This is not an installation problem. The CLI exists, but it does not know which AWS identity to use.

---

### Scenario 3: Git Author Identity Unknown

#### Command

```bash
git commit -m "Initial commit"
```

#### Error

```text
Author identity unknown
```

#### Likely Cause

Git username and email are not configured.

#### Fix

```bash
git config --global user.name "Student Name"
git config --global user.email "student@example.com"
```

#### Validate

```bash
git config --global --list
```

Expected output:

```text
user.name=Student Name
user.email=student@example.com
```

---

### Scenario 4: Docker Daemon Not Running

#### Command

```bash
docker info
```

#### Error

```text
Cannot connect to the Docker daemon
```

#### Likely Cause

Docker is installed, but the Docker service is not running.

#### Troubleshooting Steps

1. Start Docker Desktop.
2. Wait for Docker to finish starting.
3. Run `docker info` again.
4. On Windows, check WSL integration if using WSL.
5. On Linux, check Docker service status if applicable.

#### Instructor Explanation

This is different from `docker: command not found`. Here the command exists, but the background service is not available.

---

### Scenario 5: VS Code Command Not Found

#### Command

```bash
code --version
```

#### Error

```text
command not found: code
```

#### Likely Cause

VS Code may be installed, but the `code` command is not configured in PATH.

#### Troubleshooting Steps

1. Open VS Code manually.
2. Check if the command-line launcher is installed.
3. Restart terminal.
4. Document the issue.

#### Instructor Explanation

This issue does not block students from using VS Code manually.

---

### Activity Deliverable

Students complete this table:

| Scenario | Command | Error | Issue Type | Next Step |
|---|---|---|---|---|
| AWS CLI missing | `aws --version` |  |  |  |
| AWS credentials missing | `aws sts get-caller-identity` |  |  |  |
| Git identity missing | `git commit` |  |  |  |
| Docker not running | `docker info` |  |  |  |
| VS Code CLI missing | `code --version` |  |  |  |

---

## 16. Scenario-Based Discussion Questions

### Question 1

A new cloud engineer joins an enterprise team. Their AWS Console access works, but AWS CLI commands fail with missing credentials. What should they check first?

#### Expected Themes

- Confirm AWS CLI installation.
- Check whether credentials or SSO login are configured.
- Run `aws configure list`.
- Confirm expected authentication method with the team.
- Avoid creating personal access keys without guidance.

---

### Question 2

A DevOps engineer says, “I can just use the AWS Console for everything. I do not need the CLI.” What are the risks of that mindset?

#### Expected Themes

- Manual work is hard to repeat.
- Console-only changes are harder to automate.
- It may create inconsistent environments.
- It may bypass review processes.
- It may increase risk of drift.

---

### Question 3

A student can run `docker --version`, but `docker info` fails. What does that tell you?

#### Expected Answer

Docker is installed, but the Docker daemon or Docker Desktop may not be running.

---

### Question 4

Why should setup issues be documented instead of just fixed silently?

#### Expected Themes

- Helps instructor support students.
- Creates troubleshooting history.
- Builds professional documentation habits.
- Helps other students with similar issues.
- Mirrors enterprise onboarding and support practices.

---

### Question 5

Why is region awareness important in AWS?

#### Expected Themes

- Resources are often regional.
- Looking in the wrong region causes confusion.
- Costs may be created in unexpected places.
- Region choice affects latency, availability, compliance, and DR.

---

### Question 6

In an enterprise, why might a team prefer Terraform over manually creating resources in the AWS Console?

#### Expected Themes

- Repeatability
- Version control
- Review and approval
- Consistency across environments
- Auditability
- Reduced manual errors

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1

Which command checks whether Git is installed?

A. `git install`  
B. `git --version`  
C. `check git`  
D. `git start`

**Answer:** B  
**Explanation:** `git --version` prints the installed Git version if Git is available.

---

### Question 2

What does `pwd` usually show?

A. Current logged-in AWS user  
B. Current working directory  
C. Current Docker image  
D. Current Git branch only

**Answer:** B  
**Explanation:** `pwd` prints the current working directory.

---

### Question 3

What does `command not found: aws` usually mean?

A. AWS is down  
B. AWS credentials are expired  
C. The AWS CLI command is not installed or not in PATH  
D. The AWS account is deleted

**Answer:** C  
**Explanation:** The terminal cannot find the `aws` command locally.

---

### Question 4

What does `Unable to locate credentials` usually mean when running AWS CLI?

A. AWS CLI is not installed  
B. AWS CLI is installed but no credentials are configured  
C. Docker is not running  
D. Terraform is broken

**Answer:** B  
**Explanation:** The CLI exists, but it does not have credentials configured.

---

### Question 5

Which tool is mainly used for Infrastructure as Code?

A. Terraform  
B. Browser  
C. Slack  
D. PowerPoint

**Answer:** A  
**Explanation:** Terraform is used to define and provision infrastructure using code.

---

### Question 6

Which tool is used to build and run containers?

A. Git  
B. Docker  
C. CloudWatch  
D. Route 53

**Answer:** B  
**Explanation:** Docker is used to build and run containers.

---

### Question 7

What is an AWS Region?

A. A billing dashboard  
B. A geographic location where AWS services run  
C. A Git branch  
D. A Docker network

**Answer:** B  
**Explanation:** AWS Regions are geographic areas where AWS provides cloud services.

---

### Question 8

What is an AWS Availability Zone?

A. An isolated location inside a region  
B. A user permission policy  
C. A billing alert  
D. A Git repository

**Answer:** A  
**Explanation:** Availability Zones are isolated locations inside an AWS Region.

---

### Question 9

True or False: If `docker --version` works, Docker Desktop or the Docker daemon is always running.

**Answer:** False  
**Explanation:** `docker --version` only confirms the client command exists. `docker info` confirms whether Docker can communicate with the daemon.

---

### Question 10

True or False: It is safe to create random AWS resources during setup validation.

**Answer:** False  
**Explanation:** Random resources can create unnecessary cost and security risk.

---

### Question 11

Short Answer: Name one reason engineers use the CLI instead of only using the console.

**Answer:** Automation, repeatability, scripting, troubleshooting, or pipeline usage.

---

### Question 12

Short Answer: What file should students create in this lab to document setup results?

**Answer:** `setup-validation.md`

---

## 18. Homework Assignment

### Homework Title

**Complete Setup Validation and Prepare for Linux Fundamentals**

### Objective

Students will finish validating their local environment and document any setup issues before Week 2.

### Required Deliverables

Students must submit:

1. `setup-validation.md`
2. Output or screenshots of version commands
3. List of unresolved setup issues
4. Short reflection on why terminal skills matter for DevOps, Cloud Engineering, and SRE

### Required Commands to Run

```bash
git --version
aws --version
docker --version
docker info
terraform version
code --version
```

Optional if AWS credentials are already configured:

```bash
aws sts get-caller-identity
```

### Reflection Questions

Answer in 250 to 400 words:

1. Which tools are working on your machine?
2. Which tools are missing or not fully working?
3. What troubleshooting steps did you try?
4. Why is the terminal important for DevOps, Cloud Engineering, and SRE roles?
5. What do you need to fix before Week 2?

### Submission Format

Submit a folder or zip file named:

```text
week-01-class-02-setup-validation
```

Folder contents:

```text
week-01-class-02-setup-validation/
  setup-validation.md
  screenshots-or-command-output.txt
  reflection.md
```

### Grading Criteria

| Criteria | Points |
|---|---:|
| Setup validation file completed | 30 |
| Required commands attempted | 25 |
| Errors documented clearly | 20 |
| Reflection completed | 15 |
| Organized submission | 10 |
| Total | 100 |

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | Instructor Response |
|---|---|---|
| Confusing installation issues with credentials issues | Students see all errors as the same | Teach them to classify errors by type |
| Thinking `aws --version` means AWS access is configured | Version only checks installation | Explain difference between installed tool and authenticated tool |
| Creating AWS resources during exploration | Students click around out of curiosity | Reinforce cost safety and “observe only” rule |
| Ignoring selected AWS Region | Console defaults may vary | Ask students to always check region first |
| Thinking Docker is broken when only the daemon is stopped | Docker client may be installed but service stopped | Explain client vs daemon at a simple level |
| Getting stuck on `code --version` | VS Code app works but CLI command is missing | Tell students this does not block the course |
| Using different terminals inconsistently | PATH and environment differ across shells | Encourage one primary terminal for labs |
| Not documenting errors | Beginners want to skip errors | Explain documentation is part of professional troubleshooting |
| Trying to master all tools immediately | Tool list feels overwhelming | Reinforce that each tool will be taught later |
| Copying commands without reading output | Common beginner behavior | Ask students to explain what each command returned |

---

## 20. Real-World Enterprise Scenario

### Scenario Title

**New Cloud Platform Engineer Onboarding**

A new engineer joins the cloud platform team at a mid-size enterprise. Before they can work on infrastructure tickets, they must validate their workstation and confirm access to required systems.

### Business Context

The company uses:

- AWS as the primary cloud
- GitLab for source control
- Terraform for infrastructure
- Docker for application packaging
- Kubernetes for container orchestration
- CloudWatch and dashboards for monitoring

The engineer cannot start project work until their environment is validated.

### Required Onboarding Checks

| Area | Validation |
|---|---|
| Editor | VS Code installed |
| Terminal | Can run commands |
| Git | Can clone and commit |
| AWS CLI | Installed and ready for configuration |
| Docker | Installed and running |
| Terraform | Installed and available |
| AWS Console | Login works and region awareness confirmed |
| Documentation | Setup issues recorded clearly |

### Incident-Like Twist

The engineer says:

```text
AWS does not work on my laptop.
```

After investigation, the team finds:

- `aws --version` works
- `aws sts get-caller-identity` fails
- Error is `Unable to locate credentials`

### Correct Diagnosis

AWS CLI is installed, but credentials are not configured.

### Enterprise Lesson

A vague issue report slows down support. A clear issue report speeds up resolution.

Better report:

```text
I ran aws sts get-caller-identity.
The command failed with Unable to locate credentials.
aws --version works.
I think AWS CLI is installed, but credentials are not configured.
Can you confirm the expected authentication method for this course?
```

---

## 21. Instructor Tips

### Teaching Tips

1. Keep the tone calm and practical. Setup issues can frustrate beginners.
2. Reinforce that errors are expected.
3. Avoid spending too long fixing one student’s machine during live class.
4. Use errors as teaching moments.
5. Ask students to share exact commands and exact errors.
6. Separate “tool installed” from “tool authenticated” from “tool running.”
7. Keep AWS resource creation out of this class unless the lab environment is controlled.
8. Remind students that Docker and Terraform depth comes later.
9. Encourage students to keep a setup journal.
10. Use the same course folder structure for consistency.

### Suggested Instructor Phrases

- “The first troubleshooting skill is reading the exact error.”
- “Installed does not always mean configured.”
- “Configured does not always mean authorized.”
- “A command failing is not a failure. It is data.”
- “In cloud work, always check the region.”
- “Do not create resources unless the lab tells you to.”
- “Good documentation makes you easier to help.”

### Pacing Tips

If many students have setup issues:

- Prioritize Git and terminal first.
- Validate AWS CLI installation, not credentials.
- Let Docker issues be documented if they take too long.
- Let `code --version` issues be documented if VS Code opens manually.
- Make a follow-up setup support list instead of blocking the whole class.

---

## 22. Student Outcome Checklist

By the end of Class 2, students should be able to say:

| Outcome | Can Student Do It? |
|---|---|
| I can open a terminal | Yes/No |
| I can create and navigate into a folder | Yes/No |
| I can create a setup validation file | Yes/No |
| I can run version commands | Yes/No |
| I can check whether Git is installed | Yes/No |
| I can check whether AWS CLI is installed | Yes/No |
| I can explain the difference between AWS CLI installed and AWS CLI authenticated | Yes/No |
| I can check whether Docker is installed | Yes/No |
| I can identify whether Docker is not running | Yes/No |
| I can check whether Terraform is installed | Yes/No |
| I can open AWS Console and identify the selected region | Yes/No |
| I can explain Region vs Availability Zone at a high level | Yes/No |
| I can document setup errors clearly | Yes/No |
| I can explain why CLI tools matter in DevOps, Cloud, and SRE work | Yes/No |

---

## 23. Class Completion Checklist

### Instructor Completion Checklist

Before ending Class 2, confirm that:

| Item | Complete |
|---|---|
| Class 1 was reviewed briefly | Yes/No |
| Local environment checklist was explained | Yes/No |
| Terminal basics were demonstrated | Yes/No |
| Course folder creation was demonstrated | Yes/No |
| Git validation was demonstrated | Yes/No |
| AWS CLI validation was demonstrated | Yes/No |
| Docker validation was demonstrated | Yes/No |
| Terraform validation was demonstrated | Yes/No |
| VS Code CLI validation was discussed | Yes/No |
| AWS Console navigation was shown | Yes/No |
| Region and Availability Zone concepts were explained | Yes/No |
| Azure/GCP comparison was briefly covered | Yes/No |
| Troubleshooting activity was completed | Yes/No |
| Homework was assigned | Yes/No |
| Week 2 preview was provided | Yes/No |

### Student Completion Checklist

Students should have:

| Deliverable | Complete |
|---|---|
| Created `devops-cloud-sre-course` folder | Yes/No |
| Created `setup-validation.md` | Yes/No |
| Ran `git --version` | Yes/No |
| Ran `aws --version` | Yes/No |
| Ran `docker --version` | Yes/No |
| Ran `docker info` | Yes/No |
| Ran `terraform version` | Yes/No |
| Ran or attempted `code --version` | Yes/No |
| Checked AWS Console region | Yes/No |
| Documented issues and questions | Yes/No |

---

## 24. End-of-Week Summary

### Week 1 Summary

Week 1 introduced students to the professional world of DevOps, Cloud Engineering, and SRE.

In Class 1, students learned:

- What DevOps Engineers do
- What Cloud Engineers do
- What SREs do
- What Platform Engineers do
- What Production Support Engineers do
- How software moves from code to production
- Why automation, reliability, monitoring, and troubleshooting matter

In Class 2, students validated:

- Terminal usage
- VS Code availability
- Git installation
- AWS CLI installation
- Docker installation and runtime status
- Terraform installation
- AWS Console navigation
- Region and Availability Zone awareness
- Setup issue documentation

### Key Week 1 Takeaways

Students should now understand:

1. DevOps improves software delivery through automation, collaboration, and feedback.
2. Cloud Engineering builds secure, scalable, and reliable cloud foundations.
3. SRE improves production reliability through monitoring, incident response, SLOs, and automation.
4. Platform Engineering creates reusable patterns for teams.
5. Production Support helps operate and troubleshoot live systems.
6. The terminal is a core engineering tool.
7. Git tracks technical work and supports collaboration.
8. AWS Console and AWS CLI are both important.
9. Setup issues should be documented clearly.
10. Troubleshooting starts with exact commands and exact errors.

### Readiness for Week 2

Students are ready for Week 2 if they can:

- Open terminal
- Create and navigate folders
- Run simple validation commands
- Document command output
- Understand basic role differences
- Explain why Linux skills matter for cloud and DevOps work
- Bring unresolved setup issues to the instructor clearly

### Preview of Week 2

Week 2 will focus on:

- Linux filesystem
- Files and directories
- Users and groups
- Permissions
- Processes
- Services
- Package management
- Logs
- SSH
- Basic Linux troubleshooting

Week 2 shifts from orientation and setup into the first major technical foundation: **Linux for Cloud and DevOps work**.

---

## Class Artifacts & Validation

This is the **hands-on lab class** for Week 1. The runnable artifacts live in the [`labs/setup-validation/`](../../labs/setup-validation/) module: students complete the `version_ge` gap in `starter/`, check against `solution/`, reproduce the `broken/` bug, and gate everything with `validate.sh`. Paths are repo-relative; commands run from `labs/setup-validation/`.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/setup-validation/starter/lib/check.sh` | shell | the lab's starting point — `version_ge` is `TODO(student)`; learners implement correct numeric version comparison | `bash -n starter/lib/check.sh` | PASS — parses (intentional `SC2034` open-gap marker on the unfinished function; lint is INFO, never failed) |
| 2 | `labs/setup-validation/solution/lib/check.sh` | shell | reference version-comparison library (`version_ge`, `normalize_version`, `extract_version`, `detect_version`, `check_tool`) | `bash -n solution/lib/check.sh` | PASS — parses (shellcheck lint gate DEFERRED — `shellcheck` not installed here; runs where available) |
| 3 | `labs/setup-validation/solution/setup-check.sh` | shell | toolchain preflight checker run in Lab Task 2; non-zero exit if a required tool is missing/old | `./solution/setup-check.sh; echo $?` | PASS — exits `0` here (`RESULT: READY`, 8 pass / 0 fail) |
| 4 | `labs/setup-validation/solution/print-report.sh` | shell | renders the text/Markdown version report captured into the `setup-validation.md` deliverable | `./solution/print-report.sh --md; echo $?` | PASS — renders report table, exits `0` here |
| 5 | `labs/setup-validation/broken/setup-check-broken.sh` | shell | troubleshooting fixture — the real string-compare bug (`3.9` ranks above `3.10`); the reproducible broken state for the §troubleshooting exercise | `bash tests/run-tests.sh` (pins the bug intact) | PASS — suite asserts the fixture still mis-ranks `3.9 >= 3.10` |
| 6 | `labs/setup-validation/tests/run-tests.sh` | shell | functional test suite over fake versions + the broken fixture (lab Task 4) | `bash tests/run-tests.sh` | PASS — `47 passed, 0 failed` in this env (README banner cites 44; suite was extended, all green) |
| 7 | `labs/setup-validation/validate.sh` | shell | module gate runner — `bash -n` on every script, functional suite, exit-code checks, plus `shellcheck` lint | `./validate.sh; echo $?` | PASS — `12 passed, 0 failed`, exit `0` here (`shellcheck` rows SKIPPED — tool absent; `18 passed` on an instructor machine with shellcheck) |

> **Honest note on counts.** The lab README banner states `44` test assertions and `18` validate gates; in this environment the suite runs `47` assertions (all pass) and `validate.sh` runs `12` gates (all pass) because `shellcheck` is not installed so its 6 lint rows self-skip. No gate is red — the missing lint rows are DEFERRED, and they pass on an instructor machine that has `shellcheck 0.10.0`.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the complete Bash lab (`starter/`, `solution/`, `broken/`, `tests/`, `validate.sh`); nothing the class teaches lives only in a fence.
- [x] Each artifact passes (or documents) its **validation gate** — `bash -n` passes for all scripts; `tests/run-tests.sh` is `47/0`; `setup-check.sh`/`print-report.sh` exit `0`; `validate.sh` is `12/0` exit `0`; `shellcheck` lint gate DEFERRED (tool absent in this env), documented above.
- [x] Lab has **starter** (intentionally incomplete — `version_ge` TODO'd) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — all present in `labs/setup-validation/README.md`.
- [x] **Cleanup/teardown** — N/A by design and documented: the scripts create no files/processes/cloud resources; the test suite removes its `mktemp -d` sandbox via an `EXIT` trap; re-runnable (idempotent).
- [x] **Instructor answer key** exists — for the lab (`version_ge` solution + grading points in the lab README), the quiz (§17) and homework (§18) in this class, and the troubleshooting fixture (`broken/`), with every test assertion labelled by the behaviour it pins.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/setup-check-broken.sh`, the lexicographic-compare bug; `tests/run-tests.sh` pins it so a silent "fix" fails the suite.
- [x] **Expected outputs** are shown — the `READY` checker run, the Markdown report table, and the `[FAIL] terraform ... too old` broken output are captured in the lab README and this class.
- [x] **Cost & security warnings** present — $0 (purely local shell), no secrets/credentials read, untrusted-`PATH` caveat noted; covered in the week's Cost and Safety note and the lab's security section.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/setup-validation/`, the Class 1 recap, and the Week 2 (Linux) preview verified.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (`ls`-checked).
