# Week 1, Class 1: Understanding DevOps, Cloud Engineering, and SRE Roles

**Course:** Enterprise DevOps, Cloud Engineering, and Site Reliability Engineering Program  
**Week:** 1  
**Module:** DevOps, Cloud, and SRE Career Foundations  
**Class:** 1 of 2  
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

This class introduces students to the professional world of **DevOps Engineering, Cloud Engineering, Site Reliability Engineering, Platform Engineering, and Production Support**.

Students will learn how these roles fit together in an enterprise technology organization and how work moves from application code to production systems. The class focuses on role clarity, team collaboration, production mindset, and the high-level toolchain students will use throughout the course.

This is not a deep technical lab class yet. The goal is to help students understand the career paths, the purpose of the course, and why tools like Git, terminal, AWS, Docker, Terraform, Kubernetes, and monitoring platforms matter.

By the end of class, students should be able to clearly explain what each role does and how DevOps, Cloud Engineering, and SRE work together to deliver reliable software.

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. Explain what DevOps means in a real enterprise environment.
2. Describe the difference between DevOps Engineer, Cloud Engineer, SRE, Platform Engineer, and Production Support Engineer.
3. Understand how application teams, infrastructure teams, security teams, and operations teams work together.
4. Explain the basic software delivery lifecycle.
5. Understand why automation, reliability, monitoring, and collaboration are core themes in the course.

---

## 3. Prerequisites Students Should Already Know

Students do not need prior DevOps or cloud experience.

They should be comfortable with:

| Area | Expected Beginner Knowledge |
|---|---|
| Computer basics | Opening applications, using files and folders |
| Internet basics | Understanding websites, browsers, and URLs |
| Basic software idea | Knowing that applications are built, tested, and released |
| Problem solving | Willingness to troubleshoot errors step by step |
| Learning mindset | Comfortable making mistakes and asking questions |

Helpful but not required:

- Basic command-line exposure
- Basic understanding of servers
- Basic understanding of software development
- Any previous AWS, Azure, or GCP experience

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Enterprise Context |
|---|---|---|
| DevOps | A way of improving how software is built, tested, released, and operated | Helps teams deploy faster and safer |
| Cloud Engineering | Designing, building, and managing cloud infrastructure | Supports applications with secure, scalable infrastructure |
| SRE | Site Reliability Engineering, focused on reliability and production health | Keeps systems stable, observable, and recoverable |
| Platform Engineering | Building reusable internal tools and templates for developers | Reduces repeated work and standardizes delivery |
| Production | The live environment used by real users or customers | Mistakes can affect customers and business operations |
| CI/CD | Continuous Integration and Continuous Delivery or Deployment | Automates build, test, and release workflows |
| Infrastructure | Servers, networks, databases, storage, security, and cloud resources | Foundation that applications run on |
| Automation | Using scripts, pipelines, or tools to reduce manual work | Reduces errors and improves repeatability |
| Observability | Ability to understand system health through logs, metrics, and traces | Helps teams detect and troubleshoot issues |
| Incident | An unplanned service issue affecting users or business operations | Requires triage, communication, and resolution |
| Runbook | Step-by-step operational guide for handling tasks or incidents | Helps teams respond consistently |
| Postmortem | Review after an incident to learn and improve | Focuses on prevention, not blame |
| AWS Region | A geographic AWS location where services run | Example: `us-east-1` |
| AWS Availability Zone | Isolated data center zone inside a region | Used for high availability |
| Git | Version control system for tracking changes | Used for code, scripts, Terraform, Kubernetes YAML, and documentation |
| Terminal | Command-line interface for running commands | Common tool for DevOps, cloud, and SRE work |

---

## 5. Tools Used

| Tool | Purpose in This Class | Used Later For |
|---|---|---|
| VS Code | Show where students write code, scripts, notes, YAML, and Terraform | Editing labs, scripts, Terraform, Kubernetes manifests |
| Terminal | Show command-line interface | Linux, Git, AWS CLI, Docker, Terraform, Kubernetes |
| Git | Introduce version control | Repositories, collaboration, CI/CD, IaC |
| Browser | Access cloud consoles and documentation | AWS Console, GitHub/GitLab, documentation |
| AWS Console | High-level cloud interface overview | IAM, VPC, EC2, S3, CloudWatch, EKS |
| AWS CLI | Introduced as command-line access to AWS | AWS automation and validation |
| Docker | Show container tool conceptually | Containerization in Week 10 |
| Terraform | Show Infrastructure as Code conceptually | Infrastructure as Code in Weeks 14 and 15 |

---

## 6. AWS Services Used

This class uses AWS mostly as an overview, not hands-on service creation.

| AWS Service or Concept | How It Appears in Class |
|---|---|
| AWS Console | Introduced as the browser-based management interface |
| AWS Regions | Explained as geographic service locations |
| Availability Zones | Explained as isolated locations inside a region |
| IAM | Mentioned as identity and access management |
| EC2 | Mentioned as virtual servers in AWS |
| S3 | Mentioned as cloud object storage |
| CloudWatch | Mentioned as monitoring and logging service |
| EKS | Mentioned as AWS-managed Kubernetes |
| AWS CLI | Introduced as command-line access to AWS |

**Instructor note:** Do not have students create AWS resources in Class 1 unless the environment is already cost-controlled. This class is primarily orientation and toolchain awareness.

---

## 7. Azure and GCP Comparison Notes

Keep these comparisons brief. The goal is awareness, not multi-cloud depth.

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Web console | AWS Console | Azure Portal | Google Cloud Console |
| Identity | IAM | Microsoft Entra ID and Azure RBAC | Cloud IAM |
| Compute | EC2 | Azure Virtual Machines | Compute Engine |
| Object storage | S3 | Blob Storage | Cloud Storage |
| Kubernetes | EKS | AKS | GKE |
| Monitoring | CloudWatch | Azure Monitor | Cloud Monitoring |
| Account boundary | AWS Account | Azure Subscription | GCP Project |

**Instructor note:** Explain that this course is AWS-first, but students will see Azure and GCP comparisons because real enterprise environments are often hybrid or multi-cloud.

---

## 8. Time-Boxed Instructor Agenda

| Time | Topic | Instructor Goal |
|---:|---|---|
| 0:00 to 0:15 | Welcome, course purpose, expectations | Set context and reduce anxiety |
| 0:15 to 0:35 | What problems DevOps, Cloud, and SRE solve | Explain why these roles exist |
| 0:35 to 1:05 | DevOps Engineer role explained | Show how DevOps improves delivery |
| 1:05 to 1:30 | Cloud Engineer role explained | Show how cloud infrastructure supports apps |
| 1:30 to 1:40 | Break | Reset |
| 1:40 to 2:05 | SRE role explained | Show how reliability and incident response fit in |
| 2:05 to 2:25 | Platform Engineering and Production Support overview | Clarify adjacent roles |
| 2:25 to 2:45 | Enterprise team workflow example | Connect roles to real work |
| 2:45 to 2:55 | What "senior" looks like + DORA metrics + GitOps awareness | Set the seniority bar and industry vocabulary |
| 2:55 to 3:00 | Discussion, recap, and knowledge check | Confirm understanding |

---

## 9. Instructor Lesson Plan

### Opening: 0:00 to 0:15

**Instructor goal:** Welcome students, explain the course direction, and set expectations.

**Instructor script:**

> Welcome to Week 1. This course is designed to help you become job-ready for DevOps, Cloud Engineering, and SRE roles. Today is not about memorizing tools. Today is about understanding the job landscape, the team structure, and why these tools exist.

Cover:

- Course goal
- Weekly format
- Two classes per week
- Hands-on labs
- Troubleshooting mindset
- AWS-first approach
- Azure and GCP comparison exposure
- A single unified 25-week track (DevOps · Cloud · SRE) culminating in a capstone and interview prep

**Instructor emphasis:** Students may feel overwhelmed by the number of tools. Reassure them that tools will be introduced gradually.

---

### Segment 1: What Problems DevOps, Cloud, and SRE Solve: 0:15 to 0:35

**Instructor goal:** Explain why these roles exist in modern IT organizations.

Before DevOps and cloud maturity, many companies had problems like:

- Manual deployments
- Slow release cycles
- Development and operations silos
- Unclear ownership
- Poor monitoring
- Frequent production incidents
- Inconsistent environments
- Security added too late
- No repeatable infrastructure process

**Enterprise example:**

A company manually deploys a customer portal every Friday night. One engineer copies files to a server, another restarts services, and someone checks logs manually. If something breaks, no one knows exactly what changed.

How DevOps, Cloud Engineering, and SRE improve this:

| Problem | Improvement |
|---|---|
| Manual deployment | CI/CD pipeline |
| Inconsistent servers | Infrastructure as Code |
| Poor visibility | Monitoring and logging |
| Slow troubleshooting | Runbooks and dashboards |
| Fragile systems | Reliability engineering |
| Security gaps | IAM, secrets, scanning, governance |

---

### Segment 2: DevOps Engineer Role: 0:35 to 1:05

**Instructor goal:** Explain DevOps as a delivery and automation role, not just a tool title.

A DevOps Engineer often works on:

- CI/CD pipelines
- Git workflows
- Build automation
- Test automation
- Deployment automation
- Container build and delivery
- Infrastructure automation
- Release workflows
- Environment promotion
- Rollback planning

**Example workflow:**

```text
Developer commits code
        ↓
CI pipeline runs tests
        ↓
Application is packaged
        ↓
Docker image is built
        ↓
Image is pushed to registry
        ↓
Deployment pipeline updates environment
        ↓
Monitoring confirms health
```

**Clarify misconception:** DevOps does not mean “the person who does everything.” DevOps means improving collaboration, automation, and delivery reliability.

---

### Segment 3: Cloud Engineer Role: 1:05 to 1:30

**Instructor goal:** Explain cloud engineering as infrastructure design, implementation, security, and operations.

A Cloud Engineer often works on:

- AWS accounts
- IAM roles and permissions
- VPCs and subnets
- Routing and DNS
- EC2, containers, databases, and storage
- Load balancers
- Security controls
- Cost controls
- Backup and disaster recovery
- Terraform infrastructure

**AWS example:**

```text
Users
  ↓
Route 53 DNS
  ↓
Load Balancer
  ↓
Application servers or Kubernetes
  ↓
Database
  ↓
Logs and metrics
```

The Cloud Engineer helps design and build the cloud foundation so the application can run securely and reliably.

**Clarify misconception:** Cloud Engineering is not just clicking around in the AWS Console. In enterprise environments, cloud work usually requires design, automation, governance, documentation, and cost awareness.

---

### Break: 1:30 to 1:40

Encourage students to write down one question about each role.

---

### Segment 4: SRE Role: 1:40 to 2:05

**Instructor goal:** Explain reliability engineering and production health.

An SRE often works on:

- Monitoring
- Alerting
- Dashboards
- Incident response
- On-call operations
- SLIs and SLOs
- Error budgets
- Runbooks
- Postmortems
- Reliability improvements
- Automation to reduce toil
- Performance and capacity analysis

**SRE example:**

A service becomes slow during peak usage. The SRE asks:

- Is the service down or degraded?
- How many users are affected?
- Which metric changed?
- Did a deployment happen recently?
- Are there errors in logs?
- Is the database saturated?
- Is the service meeting its SLO?
- What should we fix now?
- What should we improve later?

**Clarify misconception:** SRE is not only support. SRE combines software engineering, operations, monitoring, automation, and reliability practices.

---

### Segment 5: Platform Engineering and Production Support: 2:05 to 2:25

**Instructor goal:** Explain adjacent roles that students will hear about in real jobs.

Platform Engineering focuses on reusable internal platforms and standards.

Examples:

- Standard CI/CD templates
- Terraform modules
- Kubernetes deployment templates
- Developer self-service portals
- Golden paths
- Standard monitoring templates
- Secure baseline patterns

Production Support focuses on keeping existing systems running and helping resolve issues.

Examples:

- Ticket triage
- Application support
- Log review
- Escalation
- Restart procedures
- Known issue documentation
- User impact communication

Many students may start in support, cloud operations, or junior infrastructure roles. These are valid stepping stones into DevOps, Cloud Engineering, and SRE.

---

### Segment 6: Enterprise Team Workflow Example: 2:25 to 2:45

**Instructor goal:** Show how all roles work together.

**Scenario:** A company is launching a new internal order tracking application.

| Team | Responsibility |
|---|---|
| Application team | Builds the application |
| DevOps team | Builds CI/CD pipeline |
| Cloud Engineering team | Creates AWS infrastructure |
| Security team | Reviews IAM, secrets, encryption, and compliance |
| SRE team | Defines monitoring, alerts, runbooks, and reliability checks |
| Platform team | Provides reusable templates |
| Operations team | Supports incidents and service requests |

**Lifecycle:**

```text
Business request
  ↓
Application design
  ↓
Cloud architecture
  ↓
Security review
  ↓
CI/CD setup
  ↓
Infrastructure provisioning
  ↓
Application deployment
  ↓
Monitoring and alerting
  ↓
Production support
  ↓
Incident review and improvement
```

---

### Segment 6.5: What a Senior Engineer in These Roles Looks Like, and How the Industry Measures Delivery: 2:45 to 2:55

**Instructor goal:** Set the bar for where this course is heading and introduce the vocabulary hiring managers use in 2026. Keep it at an awareness level; depth arrives in later weeks.

#### What "senior" actually means in each track

Students should understand from Day 1 that these roles have a ladder. Junior engineers execute tasks; senior, staff, and principal engineers own outcomes, design systems, and set standards for others.

| Role | Junior signal | Senior signal (what hiring managers look for) |
|---|---|---|
| DevOps / Platform Engineer | Follows a pipeline template, fixes a failing build | Designs the org-wide CI/CD and golden-path standards, defines branching/release policy, mentors teams, reduces lead time across many teams |
| Cloud Engineer | Creates resources from a runbook | Owns multi-account architecture, landing zones, network and IAM design, cost guardrails, and reviews others' infrastructure-as-code |
| SRE | Acknowledges alerts, follows a runbook | Defines SLOs and error budgets with product owners, leads incident command, drives blameless postmortems, eliminates classes of toil through automation |
| Production Support | Triages and escalates tickets | Builds the runbooks and known-issue knowledge base, identifies recurring root causes, and feeds reliability work back to engineering |

Senior interview signals across all three tracks:

- Can reason about trade-offs (cost vs. reliability vs. speed), not just tools.
- Can lead an incident calmly and run a blameless postmortem.
- Can define and defend standards (security, IaC review, deployment policy) for an organization.
- Can mentor and unblock other engineers.
- Speaks in outcomes and metrics, not task lists.

> Use this phrase: "Junior engineers complete tickets. Senior engineers remove the reason the ticket existed."

#### DORA metrics: how modern teams measure delivery performance

The DORA (DevOps Research and Assessment) metrics are the industry-standard way to talk about software delivery health. Hiring managers in 2026 expect candidates to recognize these four:

| Metric | Question it answers | Direction of "good" |
|---|---|---|
| **Deployment frequency** | How often does the team ship to production? | Higher (e.g., on-demand / many times per day) |
| **Lead time for changes** | How long from code committed to running in production? | Lower (hours, not weeks) |
| **Change failure rate** | What percentage of deployments cause a failure needing remediation? | Lower |
| **Mean time to recovery (MTTR)** | How quickly do we recover when something breaks? | Lower |

The first two measure **throughput** (speed). The last two measure **stability**. Strong teams improve both at once; weak teams trade one for the other.

> Use this phrase: "Speed and stability are not opposites. The best teams are fast AND reliable, and DORA gives us the numbers to prove it."

These metrics connect directly to later weeks: error budgets and MTTR are formalized in SRE Foundations (Week 21), deployment frequency and lead time are driven by the CI/CD work starting in Week 9, and cost-aware operations appear in Week 18.

#### GitOps and pull-based delivery (awareness only)

The code-to-production whiteboard later in this class shows a **push** pipeline: a CI/CD system reaches out and pushes changes into the environment. There is a second dominant pattern students should simply recognize by name now:

- **GitOps / pull-based delivery:** the desired state of the system lives in a Git repository, and an in-cluster agent (for example Argo CD or Flux) continuously pulls that repository and reconciles the live environment to match it. Git becomes the single source of truth, and "deploy" means "merge a change."

Both patterns appear in real jobs. The course teaches push-based CI/CD first (Week 9 onward) and revisits GitOps when it covers Kubernetes and platform engineering. For now, students only need the mental model: **declare the desired state in Git, and let automation make reality match it.**

---

### Segment 7: Recap and Knowledge Check: 2:55 to 3:00

Ask students:

1. Which role focuses most on CI/CD?
2. Which role focuses most on cloud infrastructure?
3. Which role focuses most on reliability and incident response?
4. Why do all three roles need troubleshooting skills?
5. Why does Git matter for cloud infrastructure?

---

## 10. Instructor Lecture Notes

### Main Teaching Message

This class should help students understand that DevOps, Cloud Engineering, and SRE are not isolated job titles. They are connected disciplines that support modern software delivery.

The instructor should repeatedly connect concepts back to real enterprise outcomes:

- Faster releases
- Safer deployments
- More reliable systems
- Better visibility
- Lower operational risk
- Stronger security
- Repeatable infrastructure
- Better collaboration

### DevOps Lecture Notes

DevOps is about reducing friction between development and operations. In older environments, developers would write code and “throw it over the wall” to operations. Operations would then be responsible for deploying and supporting it, often without enough context.

DevOps improves this by introducing:

- Shared responsibility
- Automated pipelines
- Version-controlled changes
- Repeatable deployment process
- Feedback loops
- Monitoring after deployment

Use this phrase:

> DevOps is not only about deploying faster. It is about deploying faster with control, visibility, and repeatability.

### Cloud Engineering Lecture Notes

Cloud Engineering provides the infrastructure foundation. A Cloud Engineer must think about security, networking, compute, storage, cost, and reliability.

In AWS, this may include:

- Who can access the environment?
- Which network should the application run in?
- Should the app be public or private?
- How does traffic reach the application?
- Where are logs stored?
- How is data backed up?
- How do we avoid unnecessary cost?
- How do we provision the same environment again?

Use this phrase:

> Cloud Engineering is not just creating resources. It is designing the foundation that applications depend on.

### SRE Lecture Notes

SRE focuses on reliability in production. A system is not successful just because it deployed. It must be observable, supportable, resilient, and understandable during failure.

SRE adds discipline around:

- What does healthy mean?
- How do we measure reliability?
- What alerts matter?
- Who responds when something fails?
- What is the user impact?
- How do we prevent repeat incidents?

Use this phrase:

> SRE starts where deployment ends. Once something is live, we need to know whether it is healthy and how to respond when it is not.

### Production Mindset Lecture Notes

Students should learn early that production environments require discipline.

Production work requires:

- Careful changes
- Peer review
- Documentation
- Rollback planning
- Monitoring
- Clear communication
- Ownership

Explain that in real jobs, a technically correct change may still be risky if it lacks communication, testing, or rollback planning.

---

## 11. Whiteboard Explanation

### Whiteboard Topic: How Work Moves From Code to Production

Modern teams use one of two delivery styles. Draw both so students recognize each by name. We teach push-based CI/CD first (Week 9 onward) and revisit GitOps with Kubernetes and platform engineering.

**Push-based CI/CD (a pipeline pushes the change into the environment):**

```text
Developer writes code
        |
        v
Git repository
        |
        v
CI pipeline
        |
        v
Build and test
        |
        v
Container image or application artifact
        |
        v
CD pipeline PUSHES the change ----> Cloud infrastructure / Kubernetes platform
        |
        v
Production deployment
        |
        v
Monitoring, alerts, incidents, improvement
```

**Pull-based GitOps (an in-cluster agent pulls desired state from Git):**

```text
Developer writes code + desired state (manifests)
        |
        v
Git repository  <--- single source of truth
        ^
        | continuously reconciles
GitOps agent (Argo CD / Flux) running INSIDE the platform
        |
        v
Cloud infrastructure / Kubernetes platform matches Git
        |
        v
Monitoring, alerts, incidents, improvement
```

Key contrast to verbalize: in push, the pipeline reaches into the environment; in pull, the environment reaches out and keeps itself in sync with Git. Both are valid and appear in real jobs.

### Role Mapping

```text
Developer:
- Writes application code

DevOps Engineer:
- Builds CI/CD pipeline
- Automates build, test, package, and deployment

Cloud Engineer:
- Builds AWS infrastructure
- Manages IAM, networking, compute, storage, and security

SRE:
- Defines reliability targets
- Builds monitoring and alerting
- Responds to incidents
- Improves production readiness

Platform Engineer:
- Builds reusable internal templates and golden paths

Production Support:
- Helps investigate live issues
- Follows runbooks
- Escalates when needed
```

### AWS-Focused Architecture Sketch

```text
User
 |
 v
Route 53
 |
 v
Load Balancer
 |
 v
Application on EC2 or EKS
 |
 v
Database or Storage
 |
 v
CloudWatch Logs and Metrics
```

### Instructor Explanation

Use this diagram to explain:

- DevOps helps move code through the pipeline.
- Cloud Engineering builds the AWS environment where the application runs.
- SRE makes sure the live application is reliable and observable.
- Platform Engineering standardizes the process.
- Production Support helps with day-to-day operational issues.

---

## 12. Instructor Demo Script

### Demo Title

**Tour of a Real DevOps, Cloud, and SRE Toolchain**

### Demo Goal

Show students the tools they will use throughout the course and explain how each tool connects to real job responsibilities.

### Demo Setup

Instructor should have:

- VS Code installed
- Terminal available
- Git installed
- AWS CLI installed
- Docker installed, if possible
- Terraform installed, if possible
- Browser open
- AWS Console access, if available

### Demo Part 1: Open VS Code

Open VS Code and show an empty course folder.

**Talking points:**

> VS Code is where we will write scripts, YAML files, Terraform code, Kubernetes manifests, documentation, and lab notes.

### Demo Part 2: Open Terminal

Run:

```bash
pwd
ls
mkdir week-01-demo
cd week-01-demo
```

Expected output will vary by system, but students should see the current folder and then move into a new folder.

**Talking points:**

> The terminal is one of the main interfaces for DevOps, Cloud, and SRE work. Many production tasks begin with simple commands.

### Demo Part 3: Validate Git

Run:

```bash
git --version
```

Expected output example:

```text
git version 2.43.0
```

Then run:

```bash
git init
echo "# Week 1 Demo" > README.md
git status
```

Expected output example:

```text
Initialized empty Git repository
On branch main

Untracked files:
  README.md
```

**Talking points:**

> Git tracks changes. Later, we will use Git for scripts, Terraform, Kubernetes YAML, CI/CD, and documentation.

### Demo Part 4: Show AWS CLI

Run:

```bash
aws --version
```

Expected output example:

```text
aws-cli/2.x.x Python/3.x.x
```

If credentials are configured, optionally run:

```bash
aws sts get-caller-identity
```

Expected output example:

```json
{
  "UserId": "AIDAEXAMPLE",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/example-user"
}
```

**Talking points:**

> The AWS CLI allows us to interact with AWS from the command line. Later, we will use it to validate identity, inspect resources, and support automation.

**Important:** If students do not have credentials yet, do not require `aws sts get-caller-identity` in Class 1.

**Modern credential note (awareness only):** In 2026 the recommended way to authenticate the AWS CLI is **AWS IAM Identity Center (SSO)**, using `aws configure sso` and `aws sso login` to obtain short-lived, automatically refreshed credentials tied to a named profile. This replaces the old habit of creating long-lived IAM access keys. The example ARN above shows an IAM user only because it is the simplest illustration; do not create or hand out access keys here. Hands-on SSO setup and identity work arrive in Week 4 (AWS Cloud Foundations) and Week 6 (Cloud Security & IAM). For Class 1, students only need to know the right path exists.

### Demo Part 5: Show Docker

Run:

```bash
docker --version
```

Expected output example:

```text
Docker version 25.x.x
```

**Talking points:**

> Docker packages applications into containers. Later in the course, we will build images and deploy them to Kubernetes.

### Demo Part 6: Show Terraform

Run:

```bash
terraform version
```

Expected output example:

```text
Terraform v1.x.x
```

**Talking points:**

> Terraform lets us define infrastructure as code. Instead of manually creating cloud resources, we describe them in files and apply them in a repeatable way.

### Demo Part 7: AWS Console Tour

Show:

1. AWS Console home page
2. Region selector
3. Search bar
4. IAM service page
5. EC2 service page
6. S3 service page
7. CloudWatch service page

**Talking points:**

> Today we are not creating resources. We are learning how to recognize the AWS environment and understand where major services live.

### Demo Wrap-Up

```text
VS Code = where we write
Terminal = where we run commands
Git = how we track changes
AWS Console = where we inspect cloud resources
AWS CLI = how we automate cloud tasks
Docker = how we package applications
Terraform = how we define infrastructure
Monitoring tools = how we understand production health
```

---

## 13. Student Lab Manual

### Lab Title

**Identify Your DevOps, Cloud, and SRE Toolchain**

### Lab Objective

Students will inspect their local machine and identify whether key course tools are installed.

### Estimated Time

30 to 40 minutes

### Skills Practiced

- Opening terminal
- Running version commands
- Recording command output
- Identifying missing tools
- Understanding each tool’s purpose

### Tools Required

- Terminal
- VS Code
- Git
- AWS CLI
- Docker
- Terraform
- Browser

### Student Instructions

#### Step 1: Open Terminal

Open your terminal application.

| Operating System | Terminal Option |
|---|---|
| Windows | PowerShell, Windows Terminal, Git Bash, or WSL terminal |
| macOS | Terminal |
| Linux | Terminal |

#### Step 2: Create a Course Folder

Run:

```bash
mkdir devops-cloud-sre-course
cd devops-cloud-sre-course
```

Validate with:

```bash
pwd
```

Expected output example:

```text
/Users/student/devops-cloud-sre-course
```

or on Windows:

```text
C:\Users\student\devops-cloud-sre-course
```

#### Step 3: Check Git

Run:

```bash
git --version
```

Expected output example:

```text
git version 2.43.0
```

Record your result:

```text
Git installed: Yes/No
Git version:
Issue found:
```

#### Step 4: Check AWS CLI

Run:

```bash
aws --version
```

Expected output example:

```text
aws-cli/2.15.0 Python/3.11.0
```

Record your result:

```text
AWS CLI installed: Yes/No
AWS CLI version:
Issue found:
```

Optional only if AWS credentials are already configured:

```bash
aws sts get-caller-identity
```

#### Step 5: Check Docker

Run:

```bash
docker --version
```

Expected output example:

```text
Docker version 25.0.0
```

Record your result:

```text
Docker installed: Yes/No
Docker version:
Issue found:
```

If Docker is installed, also try:

```bash
docker info
```

If this fails, Docker may be installed but not running.

#### Step 6: Check Terraform

Run:

```bash
terraform version
```

Expected output example:

```text
Terraform v1.6.0
```

Record your result:

```text
Terraform installed: Yes/No
Terraform version:
Issue found:
```

#### Step 7: Check VS Code

Run:

```bash
code --version
```

Expected output example:

```text
1.85.0
```

If this command fails, VS Code may still be installed but the `code` command may not be added to PATH.

Record your result:

```text
VS Code installed: Yes/No
VS Code command works: Yes/No
Issue found:
```

#### Step 8: Create Setup Report

Create a file named:

```text
setup-validation.md
```

Terminal option:

```bash
touch setup-validation.md
```

On Windows PowerShell, use:

```powershell
New-Item setup-validation.md
```

Add the following content:

```text
# Week 1 Setup Validation

Name:
Operating system:

## Tool Validation

Git version:
AWS CLI version:
Docker version:
Terraform version:
VS Code version:

## Issues Found

1.
2.
3.

## Questions for Instructor

1.
2.
```

#### Step 9: Submit Lab Result

Submit:

- `setup-validation.md`
- Screenshot or copied output of tool version commands
- Any error messages you received

### Lab Success Criteria

You successfully complete the lab if:

- You opened terminal successfully.
- You ran at least 4 version-check commands.
- You documented installed and missing tools.
- You identified at least one troubleshooting step if a command failed.
- You created `setup-validation.md`.

---

## 14. Troubleshooting Activity

### Activity Title

**Diagnosing Missing CLI Tools and Basic Terminal Issues**

### Scenario

A new student is preparing for the course. They try to validate their setup, but several commands fail.

Students must diagnose what type of problem is happening.

### Problem 1: AWS CLI Command Not Found

Command:

```bash
aws --version
```

Error:

```text
command not found: aws
```

Likely causes:

- AWS CLI is not installed.
- AWS CLI is installed but not in PATH.
- Terminal was not restarted after installation.
- Student followed instructions for the wrong operating system.

Student questions:

1. Is AWS CLI installed?
2. Can you find the AWS CLI application on the machine?
3. Did you restart terminal after installation?
4. Is the install location included in PATH?
5. Are you using the expected shell?

Instructor guidance: Classify the issue as one of the following:

```text
Installation issue
PATH issue
Terminal session issue
Operating system instruction mismatch
```

### Problem 2: Git Commit Fails

Command:

```bash
git commit -m "Initial commit"
```

Error:

```text
Author identity unknown
```

Cause: Git username and email are not configured.

Fix:

```bash
git config --global user.name "Student Name"
git config --global user.email "student@example.com"
```

Validation:

```bash
git config --global --list
```

Expected output example:

```text
user.name=Student Name
user.email=student@example.com
```

### Problem 3: Docker Installed but Not Running

Command:

```bash
docker info
```

Error example:

```text
Cannot connect to the Docker daemon
```

Likely causes:

- Docker Desktop is not running.
- Docker service is stopped.
- User lacks permission.
- WSL integration is not enabled on Windows.

Instructor guidance: Do not spend too much time fixing Docker in Class 1. Help students classify the issue and document it for setup follow-up.

### Problem 4: Terraform Command Not Found

Command:

```bash
terraform version
```

Error:

```text
terraform: command not found
```

Likely causes:

- Terraform is not installed.
- Terraform binary is not in PATH.
- Terminal was not restarted.
- Command was typed incorrectly.

Student fix direction: Students should document the issue and verify installation instructions before Class 2.

### Activity Deliverable

Students complete this table:

| Failed Command | Error Message | Likely Cause | Next Troubleshooting Step |
|---|---|---|---|
| `aws --version` |  |  |  |
| `git commit` |  |  |  |
| `docker info` |  |  |  |
| `terraform version` |  |  |  |

---

## 15. Scenario-Based Discussion Questions

### Discussion Question 1

A company allows developers to deploy manually from their laptops to production. What could go wrong?

Expected themes:

- No audit trail
- Manual mistakes
- Different laptop configurations
- No consistent testing
- Security risk
- No repeatable rollback
- Difficult troubleshooting

### Discussion Question 2

An application is deployed successfully, but users complain that it is slow. Which role is most likely to lead the reliability investigation?

Expected answer: The SRE or production engineering team would likely lead the reliability investigation, working with DevOps, Cloud Engineering, and application teams.

### Discussion Question 3

A team needs a new AWS environment with networking, IAM, storage, and monitoring. Which role is most directly involved?

Expected answer: Cloud Engineering is most directly involved, though DevOps and SRE may contribute pipeline and monitoring requirements.

### Discussion Question 4

A company has 50 application teams all creating their own deployment pipelines differently. What problem does Platform Engineering solve here?

Expected themes:

- Standard templates
- Reusable golden paths
- Consistent security
- Faster onboarding
- Fewer duplicated efforts
- Better governance

### Discussion Question 5

Why do DevOps, Cloud Engineering, and SRE all need Git?

Expected themes:

- Version control
- Collaboration
- Review history
- Infrastructure as Code
- Pipeline definitions
- Kubernetes manifests
- Documentation

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### 1. What is the main purpose of DevOps?

A. To replace developers  
B. To improve software delivery through collaboration, automation, and feedback  
C. To only manage cloud billing  
D. To manually deploy applications  

**Answer:** B  
**Explanation:** DevOps improves software delivery by combining collaboration, automation, repeatability, and feedback.

### 2. Which role is most focused on cloud networking, IAM, and infrastructure design?

A. Cloud Engineer  
B. Frontend Developer  
C. Business Analyst  
D. Scrum Master  

**Answer:** A  
**Explanation:** Cloud Engineers design and manage cloud infrastructure such as IAM, VPCs, routing, compute, storage, and security.

### 3. Which role is most focused on SLIs, SLOs, monitoring, and incident response?

A. UI Designer  
B. Database Analyst  
C. SRE  
D. Sales Engineer  

**Answer:** C  
**Explanation:** SRE focuses on reliability, observability, incident response, and production readiness.

### 4. What does CI/CD help teams do?

A. Avoid using Git  
B. Automate build, test, and deployment workflows  
C. Remove the need for monitoring  
D. Replace cloud infrastructure  

**Answer:** B  
**Explanation:** CI/CD automates software delivery workflows.

### 5. What is the AWS Console?

A. A programming language  
B. A browser-based interface for managing AWS resources  
C. A database engine  
D. A monitoring-only tool  

**Answer:** B  
**Explanation:** The AWS Console is the web interface for accessing and managing AWS services.

### 6. What is one reason production changes require discipline?

A. Production systems affect real users  
B. Production systems do not need monitoring  
C. Production changes are always free  
D. Production systems cannot fail  

**Answer:** A  
**Explanation:** Production changes can affect real users, business operations, revenue, and customer trust.

### 7. True or False: DevOps only means using Jenkins or GitHub Actions.

**Answer:** False  
**Explanation:** DevOps includes culture, collaboration, automation, CI/CD, monitoring, feedback, and operational practices.

### 8. True or False: Cloud Engineering is only clicking buttons in the AWS Console.

**Answer:** False  
**Explanation:** Enterprise cloud engineering includes design, automation, security, networking, governance, cost control, and operations.

### 9. Short Answer: Name one tool used for version control.

**Answer:** Git

### 10. Short Answer: Name one AWS service used for monitoring.

**Answer:** Amazon CloudWatch

---

## 17. Homework Assignment

### Homework Title

**Compare DevOps, Cloud Engineering, and SRE Roles**

### Assignment Objective

Students will demonstrate that they understand the difference between the major career paths introduced in Class 1.

### Instructions

Write a 1-page reflection answering the following questions:

1. What does a DevOps Engineer do?
2. What does a Cloud Engineer do?
3. What does an SRE do?
4. What is Platform Engineering?
5. Which role sounds most interesting to you right now and why?
6. What skills do all of these roles share?
7. Why is troubleshooting important in all three paths?

### Required Format

Submit as:

```text
week-01-role-reflection.md
```

or as a PDF/document if required by the instructor.

### Expected Length

500 to 800 words.

### Grading Criteria

| Criteria | Points |
|---|---:|
| Explains DevOps accurately | 20 |
| Explains Cloud Engineering accurately | 20 |
| Explains SRE accurately | 20 |
| Identifies shared skills | 15 |
| Includes personal reflection | 10 |
| Uses clear writing and organization | 10 |
| Mentions enterprise or production context | 5 |
| Total | 100 |

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | Instructor Response |
|---|---|---|
| Thinking DevOps means only CI/CD | Many job posts focus heavily on pipelines | Explain DevOps includes collaboration, automation, reliability, and feedback |
| Thinking Cloud Engineer only creates resources in console | Beginners often see the console first | Explain enterprise cloud uses design, automation, governance, and security |
| Thinking SRE is only support | SRE often responds to incidents | Explain SRE uses engineering practices to improve reliability |
| Confusing SRE and DevOps | Both use automation and monitoring | Compare delivery focus vs reliability focus |
| Ignoring documentation | Beginners focus only on tools | Explain documentation is part of real engineering work |
| Panicking when commands fail | New students may see errors as failure | Normalize troubleshooting as part of the job |
| Creating AWS resources randomly | Curiosity without cost awareness | Reinforce cloud cost safety early |
| Treating Azure/GCP comparisons as separate courses | Multi-cloud terms can distract beginners | Keep comparisons brief and AWS-first |

---

## 19. Real-World Enterprise Scenario

### Scenario Title

**New Customer Portal Launch**

A logistics company is launching a new customer portal where customers can view shipment status, invoices, and delivery updates.

The application team has built the first version of the portal. Now the organization needs to prepare it for production.

### Teams Involved

| Team | Responsibility |
|---|---|
| Application Development | Builds the portal features |
| DevOps | Creates CI/CD pipeline and release workflow |
| Cloud Engineering | Builds AWS infrastructure |
| Security | Reviews access, secrets, encryption, and compliance |
| SRE | Defines monitoring, alerts, SLOs, and incident response |
| Platform Engineering | Provides reusable templates and standards |
| Production Support | Helps triage issues after go-live |

### Enterprise Flow

```text
Business requests customer portal
        ↓
Application team builds code
        ↓
DevOps creates CI/CD pipeline
        ↓
Cloud Engineering provisions AWS foundation
        ↓
Security reviews access and secrets
        ↓
SRE creates monitoring and runbooks
        ↓
Application goes live
        ↓
Production Support and SRE handle incidents
        ↓
Teams review and improve
```

### Instructor Discussion

Ask students:

- What could go wrong if there is no DevOps process?
- What could go wrong if cloud infrastructure is poorly designed?
- What could go wrong if there is no monitoring?
- What could go wrong if no team owns incident response?
- Why do these teams need to collaborate?

---

## 20. Instructor Tips

### Teaching Tips

1. Keep role definitions simple at first.
2. Use diagrams more than long verbal explanations.
3. Repeat that students are not expected to master tools in Week 1.
4. Connect every role to a real business problem.
5. Normalize troubleshooting and errors.
6. Encourage students to ask beginner questions.
7. Avoid going too deep into AWS services during Class 1.
8. Keep Azure and GCP comparisons brief.
9. Use the same example application throughout the class.
10. Remind students that the course will build gradually.

### Suggested Instructor Phrases

- “DevOps improves how software moves to production.”
- “Cloud Engineering builds the foundation the application runs on.”
- “SRE keeps production reliable and measurable.”
- “Platform Engineering makes the right way the easy way.”
- “Production Support helps keep live systems operating and escalates when needed.”
- “Troubleshooting is not a side skill. It is one of the main skills.”

### Pacing Warning

Do not spend too much time installing tools during Class 1. Tool setup validation is introduced here, but deeper setup and troubleshooting continue in Class 2.

---

## 21. Student Outcome Checklist

By the end of Class 1, students should be able to say:

| Outcome | Can Student Do It? |
|---|---|
| I can explain what DevOps means | Yes/No |
| I can describe what a Cloud Engineer does | Yes/No |
| I can describe what an SRE does | Yes/No |
| I can explain what Platform Engineering is | Yes/No |
| I can explain what Production Support does | Yes/No |
| I can describe how code moves toward production | Yes/No |
| I can name at least five tools used in the course | Yes/No |
| I can explain why AWS is the primary cloud in this course | Yes/No |
| I can explain why monitoring and incident response matter | Yes/No |
| I can describe why troubleshooting is important | Yes/No |

---

## 22. Class Completion Checklist

### Instructor Checklist

Before ending Class 1, confirm that:

| Item | Complete |
|---|---|
| Course goals were explained | Yes/No |
| DevOps role was explained | Yes/No |
| Cloud Engineering role was explained | Yes/No |
| SRE role was explained | Yes/No |
| Platform Engineering was introduced | Yes/No |
| Production Support was introduced | Yes/No |
| Software delivery lifecycle was whiteboarded | Yes/No |
| AWS-first approach was explained | Yes/No |
| Azure/GCP comparison was briefly covered | Yes/No |
| Toolchain demo was completed | Yes/No |
| Student lab instructions were introduced | Yes/No |
| Troubleshooting activity was discussed | Yes/No |
| Homework was assigned | Yes/No |
| Class 2 expectations were previewed | Yes/No |

### Student Submission Checklist

Students should submit or prepare:

| Deliverable | Required |
|---|---|
| Setup validation notes | Yes |
| Role reflection homework | Yes |
| Questions about missing tools | Optional |
| List of tools installed or missing | Yes |

### Transition to Class 2

Class 2 will continue from this foundation by focusing on:

- Lab environment setup
- Tool validation
- Terminal basics
- Git, AWS CLI, Docker, and Terraform checks
- AWS Console orientation
- Common setup troubleshooting
- Preparing students for Week 2 Linux fundamentals

---

## Class Artifacts & Validation

This class is orientation plus the **toolchain demo** the instructor runs live (§ toolchain tour). The runnable artifacts it uses live in the [`labs/setup-validation/`](../../labs/setup-validation/) module — the same module the Class 1 homework and Class 2 lab build on. Paths below are repo-relative; commands run from `labs/setup-validation/`.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | `labs/setup-validation/solution/setup-check.sh` | shell | the toolchain preflight checker the instructor demos live (PASS/FAIL/WARN per tool, non-zero exit if a required tool is missing/old) | `bash -n solution/setup-check.sh` and `./solution/setup-check.sh; echo $?` | PASS — parses; exits `0` here (full course toolchain present, `RESULT: READY`) |
| 2 | `labs/setup-validation/solution/lib/check.sh` | shell | the sourced version-comparison library (`version_ge`, `normalize_version`, `extract_version`, `detect_version`, `check_tool`) the demo depends on — the reusable "is my tool new enough?" primitive | `bash -n solution/lib/check.sh` | PASS — parses (shellcheck lint gate DEFERRED — `shellcheck` not installed in this env; runs where available, see `validate.sh`) |
| 3 | `labs/setup-validation/solution/print-report.sh` | shell | renders the paste-ready text/Markdown version report the homework asks students to capture into `setup-validation.md` | `./solution/print-report.sh --md; echo $?` | PASS — renders the report table, exits `0` here |
| 4 | `labs/setup-validation/README.md` | docs | module README (prerequisites, architecture, tasks, validation, troubleshooting, cleanup, security, cost) linked from this class | `ls labs/setup-validation/README.md` | PASS — exists |

> **Note on the lint gate.** `labs/setup-validation/validate.sh` includes `shellcheck -x` gates. In *this* environment `shellcheck` is not installed, so `validate.sh` self-skips those rows and reports `12 passed, 0 failed` (exit `0`); on an instructor machine with `shellcheck 0.10.0` it reports `18 passed, 0 failed`. No gate fails — the missing ones are DEFERRED, never red.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the Bash toolchain checker (`solution/setup-check.sh` + `lib/check.sh` + `print-report.sh`); no class concept lives only in a fence.
- [x] Each artifact passes (or documents) its **validation gate** — `bash -n` passes for all; `./solution/setup-check.sh` and `./solution/print-report.sh` exit `0` here; `shellcheck` lint gate DEFERRED (tool absent in this env), documented above.
- [x] Lab has **starter** (intentionally incomplete — `version_ge` TODO'd) and **solution** (reference) versions in `labs/setup-validation/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** — N/A by design: the scripts create no files, processes, or cloud resources; the README documents this and the test suite cleans its own `mktemp -d` sandbox via an `EXIT` trap.
- [x] **Instructor answer key** exists — this class ships answer keys for the quiz (§16) and homework (§17); the lab's `version_ge` answer key and graded test suite live in `labs/setup-validation/README.md` and `tests/run-tests.sh`.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/setup-validation/broken/setup-check-broken.sh` (the string-compare bug that mis-ranks `3.9 > 3.10`), pinned by the test suite.
- [x] **Expected outputs** are shown — the `READY` checker run and the Markdown report table are captured in the lab README and demoed in this class.
- [x] **Cost & security warnings** present — $0 (purely local shell), no secrets/credentials read; covered in the week's Cost and Safety note and the lab's security section.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — links to `labs/setup-validation/` and the Class 2 / Week 2 transition verified.
- [x] The **artifact manifest** (§4.2) is present above and every path resolves (`ls`-checked).
