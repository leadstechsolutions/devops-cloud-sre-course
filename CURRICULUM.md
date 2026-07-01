# DevOps · Cloud Engineering · SRE — Curriculum
### A 25-Week, Hands-On, Job-Ready Program
*Presented by LEADS ACADEMY — DevOps, Cloud & SRE Training · leadsacademy.org*
---
## Program Overview
The LEADS Academy DevOps, Cloud & SRE Engineering Program is a structured 25-week journey from technical foundations to production-focused engineering. Students gain practical experience across Linux, networking, cloud infrastructure, infrastructure as code, CI/CD, containers, Kubernetes, security, observability, and reliability. The AWS-first curriculum also introduces Azure and GCP perspectives, while 21 hands-on lab modules and two end-to-end projects provide measurable evidence of technical capability.
| | |
|---|---|
| **Duration** | 25 weeks · 2 classes/week · 3 hours/class |
| **Format** | Instructor-led, hands-on; ~6–8 hours of labs/homework per week |
| **Live support** | Everyday live whiteboard sessions + a monthly one-on-one mentoring session with your instructor |
| **Primary cloud** | AWS (Azure & GCP comparison notes) |
| **Projects** | 21 validated lab modules + a production-ready final project + a platform golden-path project |
| **Outcome** | Job-ready for DevOps / Cloud / Platform roles, on an SRE track |
| **Prerequisites** | Basic computer literacy and comfort learning the command line; an AWS account (free tier + a small budget). No prior DevOps experience required. |

---

## Contents

### Track 1 — Foundation (Weeks 1–16)

**Phase A · Foundations**
- **Week 1** — DevOps, Cloud & SRE Foundations: Roles, Workflows, and Your First Toolchain
- **Week 2** — Linux Fundamentals for Cloud & DevOps: Files, Permissions & System Troubleshooting
- **Week 3** — Git Workflows & Team Collaboration for DevOps, Cloud & SRE

**Phase B · Cloud Core**
- **Week 4** — AWS Cloud Foundations: Accounts, Identity, CLI & Cost Safety
- **Week 5** — Networking Foundations & AWS VPC Architecture
- **Week 6** — Cloud Security & IAM: Identity, Least Privilege, and Secrets Management on AWS
- **Week 7** — EC2 Compute, AWS Storage, and Managed Databases

**Phase C · Automation & Delivery**
- **Week 8** — Scripting and Automation: Production Bash and Python for DevOps
- **Week 9** — CI/CD Pipelines with GitHub Actions: From Quality Gates to Keyless AWS Deployment
- **Week 10** — Docker Containers: Runtime Operations to Production Image Builds

**Phase D · Container Orchestration**
- **Week 11** — Kubernetes Fundamentals: Workloads, Services & Production-Ready Manifests
- **Week 12** — Kubernetes Production Troubleshooting: Workloads, Services & Networking
- **Week 13** — Helm: Packaging, Templating & Production Release Workflows for Kubernetes

**Phase E · Infrastructure as Code & Observability**
- **Week 14** — Terraform Foundations: Infrastructure as Code on AWS
- **Week 15** — Terraform Enterprise Workflows: Modules, Remote State & CI/CD
- **Week 16** — Observability & Reliability: Metrics, Tracing, Alerting & Production Readiness

### Track 2 — Advanced & Final Project (Weeks 17–25)

**Phase F · Advanced Cloud, Security & SRE**
- **Week 17** — AWS Landing Zones & Multi-Account Governance at Enterprise Scale
- **Week 18** — Cloud Cost Optimization & FinOps Operations
- **Week 19** — DevSecOps & Secure Software Supply Chain
- **Week 20** — Platform Engineering & Golden Paths: Building Developer Self-Service
- **Week 21** — SRE Foundations: SLIs, SLOs, Error Budgets & Incident Response
- **Week 22** — Performance Engineering, Capacity Planning & Production Scaling

**Phase G · Final Project & Career**
- **Week 23** — Final Project — Build: Secure CI/CD Supply Chain to EKS with GitOps & Observability
- **Week 24** — Final Project — Finalization: Production Readiness, Defense & Interview Prep
- **Week 25** — Job-Ready: Resume, Portfolio & DevOps/Cloud/SRE Interview Mastery

---

## Detailed Curriculum

### Week 1 · DevOps, Cloud & SRE Foundations: Roles, Workflows, and Your First Toolchain
*You gain a clear map of the DevOps, Cloud Engineering, and SRE career landscape and leave with a validated, course-ready local toolchain you can confidently troubleshoot.*

**What you'll learn**
- DevOps, Cloud, SRE, Platform & Production Support roles compared
- How code moves from commit to production
- Push-based CI/CD vs pull-based GitOps (Argo CD / Flux awareness)
- DORA metrics: deployment frequency, lead time, change failure rate, MTTR
- What junior vs senior looks like in each track
- Enterprise team workflow and software delivery lifecycle
- AWS Console, Regions, and Availability Zones orientation
- AWS vs Azure vs GCP service comparison (console, CLI, IAM, compute)
- Terminal basics: pwd, ls, mkdir, cd, touch, and version checks
- Validating Git, AWS CLI, Docker, and Terraform installs
- AWS CLI authentication with IAM Identity Center (SSO) and short-lived credentials
- Terraform vs OpenTofu and Dev Containers / Codespaces awareness
- Classifying setup errors: install vs PATH vs credentials vs daemon
- Cloud cost safety and the observe-only production mindset

**Hands-on lab:** Backed by the 'setup-validation' lab, you implement the missing numeric version-comparison logic in a Bash toolchain checker, run it against your machine to confirm Git, AWS CLI, Docker, Terraform, and VS Code are present and current, reproduce a real "3.9 ranks above 3.10" bug, and gate your work with the included test suite and validate.sh.

**Outcome:** By the end you can explain how DevOps, Cloud, and SRE roles collaborate to deliver reliable software, navigate the AWS Console safely, and validate, document, and systematically troubleshoot your engineering workstation.

### Week 2 · Linux Fundamentals for Cloud & DevOps: Files, Permissions & System Troubleshooting
*You gain practical command-line fluency on Linux servers, learning to manage files and permissions, triage logs, and troubleshoot failed services the way DevOps Engineers, Cloud Engineers, and SREs do on real cloud hosts.*

**What you'll learn**
- Filesystem Navigation With pwd, ls, and cd
- File and Directory Operations: mkdir, touch, cp, mv, rm
- Pipes, Redirection (>, >>, 2>), and find
- Log Triage With grep, cut, sort, uniq, wc, awk, and sed
- Symbolic and Octal Permissions (755, 644, 600) Plus umask
- Users, Groups, Ownership, and chmod/chown
- Editing Over SSH With vim Survival Commands and nano
- Fixing 'Permission Denied': chmod +x vs Running an Interpreter
- Processes and System Health: ps, top, free, uptime, nproc
- Managing Services With systemctl and Confirming Listeners via ss -tulnp
- Reading systemd Logs With journalctl
- Keyless EC2 Access With SSM Session Manager (SSH as Break-Glass)
- Scheduling Recurring Jobs With cron and systemd Timers
- Evidence-Based Troubleshooting of a Disk-Full Service Failure

**Hands-on lab:** Using the linux-shell-automation lab, you build an application-style directory tree, fix a non-executable deploy script, lock down a secret to mode 600, run a log-triage pipeline, then complete and validate real shell scripts (disk-check, log-rotate, backup) and capture a Linux health report covering processes, services, listening ports, logs, disk, and memory.

**Outcome:** By the end you can navigate and secure a Linux server, set correct file permissions, and systematically diagnose a failed service using process, port, log, disk, and memory evidence.

### Week 3 · Git Workflows & Team Collaboration for DevOps, Cloud & SRE
*You gain command of the full Git workflow used by real engineering teams, from local commits and branches to pull requests, code review, branch protection, and resolving merge conflicts safely.*

**What you'll learn**
- Git Mental Model: Working Directory, Staging Area, Local and Remote Repos
- Configuring Git Identity and init.defaultBranch=main
- Staging, Inspecting with git diff, and Writing Clear Commit Messages
- Feature Branches with git switch and Undoing Edits with git restore
- Authoring a .gitignore to Keep Secrets and Terraform State Out of Git
- Remote Authentication via gh auth login or an ed25519 SSH Key
- Pushing Branches and Opening Pull Requests and Merge Requests
- Code Review, Branch Protection, and CODEOWNERS Required Reviewers
- Merge vs Rebase vs Squash and Keeping a Linear History
- Safe Force-Pushing with --force-with-lease and git pull --rebase
- Resolving Merge Conflicts in VS Code and with git mergetool
- GitOps and Trunk-Based Development at an Awareness Level
- Secret Safety: Rotate-First Response and a pre-commit Hook That Blocks Keys
- Troubleshooting Identity, Untracked Files, Wrong Branch, and Failed Push

**Hands-on lab:** Using the git-collaboration lab, you build a complete local-to-team workflow end to end, commit through a feature branch, open a PR/MR, and deliberately create and resolve a merge conflict, while installing and validating a pre-commit hook that refuses to commit AWS keys, private keys, and oversized files.

**Outcome:** By the end you can run a professional Git workflow on your own: branch, commit, review via PR/MR with branch protection and CODEOWNERS, rebase and force-push safely, and resolve merge conflicts without leaking secrets.

### Week 4 · AWS Cloud Foundations: Accounts, Identity, CLI & Cost Safety
*You gain the safe-entry habits every cloud engineer needs first: confirming which AWS account, Region, and identity you are in, driving AWS from the CLI, and applying cost and tagging guardrails before you ever create a resource.*

**What you'll learn**
- AWS Accounts as Billing, Security, and Governance Boundaries
- Regions, Availability Zones, and AZ IDs
- Global vs Regional Services (IAM vs EC2)
- AWS Shared Responsibility Model
- Navigating the AWS Console and CloudShell Safely
- Validating Identity with aws sts get-caller-identity
- IAM Identity Center (SSO) vs Long-Lived Access Keys
- AWS CLI Profiles, Credentials, and Region Configuration
- Shaping CLI Output with --query (JMESPath) and jq
- AWS Budgets, Budget Actions, and Cost Anomaly Detection
- Building a Resource Tagging Standard for Ownership and Cost
- Authentication vs Authorization Troubleshooting
- Diagnosing Credential, Profile, Region, and AccessDenied Errors
- Multi-Account Patterns and AWS Organizations Awareness

**Hands-on lab:** Using the 'aws-cli-fundamentals' lab, you complete the read-only toolkit by finishing the starter scripts (region precedence, credential checks, whoami, and a DescribeRegions table), run an offline test suite and ShellCheck via ./validate.sh, and reproduce a deliberately broken script that swallows a no-credentials error and falsely succeeds.

**Outcome:** By the end you can safely enter any AWS account, prove your active account/Region/identity from the CLI, set up SSO-backed profiles, apply budget and tagging guardrails, and methodically troubleshoot credential, profile, Region, and permission failures.

### Week 5 · Networking Foundations & AWS VPC Architecture
*You gain the ability to reason about how traffic actually flows from a browser to a cloud app, diagnose connectivity failures layer by layer, and design and build a production-shaped, multi-AZ AWS VPC with public/private subnets, routing, NAT, and security controls.*

**What you'll learn**
- IP addressing, public vs private IPs, and CIDR notation
- Subnet math: usable hosts, AWS-reserved addresses, and address planning
- Ports, protocols, TCP vs UDP, HTTP/HTTPS, and TLS
- DNS resolution, record types (A, AAAA, CNAME, alias), and TTL/failover
- Layered troubleshooting with dig, nslookup, ping, nc, curl, and ss
- Separating DNS, port, firewall, and application failures with evidence
- TCP three-way handshake and connection states (LISTEN, ESTABLISHED, TIME-WAIT)
- VPCs, route tables, local routes, and Internet Gateways
- Public vs private subnets defined by routing, not naming
- Multi-AZ VPC design with public and private subnets per Availability Zone
- NAT Gateway and egress-only IGW for private outbound without inbound exposure
- Security Groups vs NACLs: stateful vs stateless filtering
- Gateway and Interface VPC Endpoints (PrivateLink) for private AWS access
- VPC Flow Logs as troubleshooting evidence and hybrid connectivity (peering, Transit Gateway, VPN, Direct Connect)

**Hands-on lab:** Using the terraform-aws-foundations lab, you build a production-shaped multi-AZ AWS VPC with public and private subnets per AZ, an Internet Gateway, route tables and associations, an optional NAT Gateway with Elastic IP, an S3 Gateway Endpoint, and VPC Flow Logs, then apply and destroy it against a real AWS account.

**Outcome:** By the end you can plan a non-overlapping CIDR address space, build and validate a multi-AZ AWS VPC with correct public/private routing and security controls, and isolate networking failures by layer using DNS, port, HTTP, and Flow Log evidence.

### Week 6 · Cloud Security & IAM: Identity, Least Privilege, and Secrets Management on AWS
*You gain the security foundation of cloud engineering: how to control who can access AWS, enforce least privilege with IAM roles and temporary credentials, and store, encrypt, and retrieve application secrets safely instead of hardcoding them.*

**What you'll learn**
- Authentication vs Authorization and the IAM Access Model
- IAM Users, Groups, Managed and Inline Policies
- Reading IAM JSON Policy Structure (Effect, Action, Resource, Condition)
- Least-Privilege Design and Scoped S3 Read-Only Policies
- IAM Roles, Trust Policies, and sts:AssumeRole
- Temporary Credentials via STS and EC2 Instance Profiles
- OIDC Keyless CI/CD and Federation Preview
- Policy Evaluation Order (Explicit Deny, SCPs, Permission Boundaries)
- IAM Access Analyzer for Unused and Externally-Shared Access
- Validating Permissions with the IAM Policy Simulator
- AWS KMS Encryption at Rest, in Transit, and Key Ownership
- Secrets Manager vs Systems Manager Parameter Store
- Runtime Secret Retrieval and secretsmanager:GetSecretValue / kms:Decrypt
- Troubleshooting AccessDenied for Missing Permissions and Trust Mismatches

**Hands-on lab:** Backed by the 'security-automation' lab, you build and simulate a least-privilege S3 policy, create an IAM role with a trust policy and assume it to inspect temporary credentials, then store and retrieve an encrypted secret in Secrets Manager and Parameter Store via the AWS CLI, and run automated security gates including a credential scanner, an S3 public-exposure check, and a least-privilege IAM policy auditor.

**Outcome:** By the end you can design and validate least-privilege IAM policies and roles, replace long-lived access keys with temporary credentials, securely manage application secrets with KMS and Secrets Manager, and diagnose access-denied failures across IAM, trust policies, and KMS.

### Week 7 · EC2 Compute, AWS Storage, and Managed Databases
*You gain the ability to launch, secure, and troubleshoot real EC2 web servers and to correctly place application data across EBS, S3, and RDS in a production-shaped AWS architecture.*

**What you'll learn**
- Launching EC2: AMIs, instance types, key pairs, and Graviton
- EC2 pricing models: On-Demand, Spot, and Savings Plans right-sizing
- Bootstrapping a web server with user data and cloud-init
- Security group design for SSH and HTTP access
- Keyless access with SSM Session Manager and IAM instance profiles
- Enforcing IMDSv2 and encrypting EBS root volumes
- EBS volume types (gp3, io2, st1/sc1) and launch templates
- S3 object storage: buckets, keys, versioning, and Block Public Access
- S3 storage classes, lifecycle policies, and SSE-KMS encryption
- EBS vs S3 vs RDS vs EFS vs DynamoDB storage decisions
- Provisioning RDS with private subnet groups and Secrets Manager passwords
- Backups and recovery: EBS/RDS snapshots, point-in-time restore, RTO/RPO
- Auto Scaling concepts: min/desired/max capacity and health checks
- Troubleshooting unreachable web apps, S3 AccessDenied, and RDS timeouts

**Hands-on lab:** Using the 'aws-storage-databases' lab, you launch an Amazon Linux EC2 instance that auto-deploys Apache via user data, connect to it keylessly through SSM Session Manager, then build an S3 bucket and a private RDS PostgreSQL database, proving an end-to-end EC2-to-S3-to-RDS application flow on a real AWS account.

**Outcome:** By the end you can stand up a secure EC2 web server, store application files in S3 and relational data in RDS, and diagnose why running infrastructure still fails to serve an application.

### Week 8 · Scripting and Automation: Production Bash and Python for DevOps
*You gain a practical, two-language automation toolkit, writing safe, scheduled Bash health checks and structured-data Python validators that mirror how real DevOps, Cloud, and SRE teams replace repetitive manual work.*

**What you'll learn**
- Bash Script Structure, Shebang, and Execution Methods
- Variables, Quoting, and Command Substitution
- Conditionals With if/elif/case and [[ ]] vs [ ]
- Exit Codes as Automation and Pipeline Gates
- Production-Safety Idioms: set -euo pipefail and trap Cleanup
- Functions, Loops, and Arrays in Bash
- Text Processing With grep, sed, and awk
- Linting With ShellCheck and Scheduling via Cron and systemd Timers
- Building a Hardened, Scheduled Fleet Health Report
- Python Virtual Environments, Lists, Dictionaries, and Functions
- Reading and Parsing JSON Configuration Files
- Validating Required Fields and Allowed Values
- Error Handling With try/except for Missing Files, Bad JSON, and Missing Keys
- Read-Only AWS Inventory Preview With boto3 and STS

**Hands-on lab:** In the linux-shell-automation lab you build and lint a hardened Linux health check and a scheduled fleet-report script (safety header, trap, loops, awk, retention cleanup), and in the python-automation lab you build a JSON configuration validator that checks required fields and allowed values with clear error handling, completing the TODO gaps in starter/ and verifying against solution/ with ./validate.sh.

**Outcome:** By the end you can write production-grade Bash scripts that fail safely, lint clean, and run unattended on a schedule, and Python automation that safely loads, validates, and reports on JSON config and read-only cloud inventory.

### Week 9 · CI/CD Pipelines with GitHub Actions: From Quality Gates to Keyless AWS Deployment
*You gain the ability to build a real, end-to-end CI/CD pipeline in GitHub Actions that lints, tests, scans, and packages an app, then deploys it to AWS with keyless authentication and human-gated approval.*

**What you'll learn**
- Continuous Integration vs Continuous Delivery vs Continuous Deployment
- Pipeline anatomy: jobs, steps, stages, runners, and artifacts
- Writing GitHub Actions workflow YAML and avoiding indentation errors
- Lint, test, build, and security gate pipeline on a real Flask app
- Matrix builds across Python 3.11 and 3.12 in parallel
- Secret scanning with gitleaks and dependency (SCA) scanning with pip-audit
- SHA-tagged build artifacts for provenance and rollback
- Branch protection and required status checks that enforce the gate
- Variables vs secrets and secure secret handling
- Keyless OIDC federation from GitHub Actions to an AWS IAM role
- Publishing artifacts to S3 through a gated production environment with required reviewers
- Deployment strategies: rolling, blue/green, and canary with rollback
- DORA metrics: deployment frequency, lead time, change-failure rate, and MTTR
- Evidence-first troubleshooting of pipeline, OIDC trust-policy, and artifact failures

**Hands-on lab:** Using the 'cicd-pipelines' lab, you build a real GitHub Actions pipeline that lints with ruff, runs pytest, scans with gitleaks and pip-audit, and uploads a commit-SHA-tagged tarball, enforce it with branch protection, then add a keyless OIDC deploy job that assumes an AWS IAM role and publishes the artifact to a private S3 bucket behind a required-reviewer production environment.

**Outcome:** By the end you can design, build, enforce, and troubleshoot a production-grade CI/CD pipeline that validates code, blocks bad merges, and deploys to AWS securely with no stored credentials.

### Week 10 · Docker Containers: Runtime Operations to Production Image Builds
*You gain the ability to run, troubleshoot, and operate containers locally and then package your own application into a hardened, scanned, registry-ready Docker image the way modern DevOps and SRE teams ship software.*

**What you'll learn**
- Containers vs Virtual Machines and the Docker Architecture
- Image, Container, Engine, Registry, and Tag Concepts
- Running, Listing, Inspecting, and Removing Containers with the Docker CLI
- Port Mapping, Environment Variables, Logs, and Bind Mounts
- Multi-Service Local Stacks with Docker Compose and Service DNS
- Image Architecture, --platform, and Multi-Arch Builds
- Writing a Dockerfile: FROM, WORKDIR, COPY, RUN, EXPOSE, CMD
- Multi-Stage Builds with a Non-Root User and HEALTHCHECK
- Build-Time vs Runtime, Layer Caching, and .dockerignore
- Tagging, Pinning by Digest, and the Amazon ECR Push Workflow
- Image Vulnerability Scanning with Trivy and Gating on HIGH/CRITICAL
- SBOM Generation with Syft and Image Signing Concepts (cosign)
- Evidence-First Container Troubleshooting (ps -a, logs, inspect)
- Cleanup Discipline, Cost Awareness, and Secrets Safety

**Hands-on lab:** Using the 'docker-containers' lab you run and inspect Nginx and Alpine containers (ports, env vars, bind mounts, a Compose web+Redis stack), then build, run, scan, and tag your own multi-stage non-root Flask image with a HEALTHCHECK, validating it end to end against a real Docker daemon.

**Outcome:** By the end you can build a hardened, vulnerability-scanned Docker image from a Dockerfile, run and operate containers locally with Compose, push images toward a registry like Amazon ECR, and troubleshoot build and runtime failures using an evidence-first method.

### Week 11 · Kubernetes Fundamentals: Workloads, Services & Production-Ready Manifests
*You gain the ability to deploy, expose, harden, and troubleshoot containerized applications on Kubernetes using production-grade manifests that a senior reviewer would approve.*

**What you'll learn**
- Kubernetes architecture: control plane, API server, scheduler, kubelet, and worker nodes
- Deployment, ReplicaSet, and Pod relationship with desired-state reconciliation
- Authoring Deployment manifests in YAML with namespaces, labels, and selectors
- Resource requests and limits, OOMKilled, and CPU throttling
- Readiness, liveness, and startup probes
- Hardening Pods with securityContext and Pod Security Standards (restricted)
- Scaling declaratively vs imperatively and avoiding config drift
- Horizontal Pod Autoscaler (HPA) and why it needs resource requests
- Self-healing: deleting Pods and watching Kubernetes recreate them
- Services: ClusterIP, NodePort, and LoadBalancer
- Port vs targetPort, endpoints, and EndpointSlices
- Testing apps locally with kubectl port-forward
- Mounting ConfigMaps and injecting Secrets into a Deployment
- Exposing apps with Ingress and an intro to the Gateway API
- Evidence-first troubleshooting of selector, label, image, and port mismatches

**Hands-on lab:** Using the 'kubernetes-fundamentals' lab, you deploy a hardened non-root NGINX Deployment to a local cluster, scale it, watch it self-heal, then front it with a ClusterIP Service, wire in a ConfigMap and Secret, expose it through an Ingress, and diagnose broken selectors, bad image tags, and wrong targetPorts.

**Outcome:** By the end you can deploy a production-ready, security-hardened application to Kubernetes, expose it through Services and Ingress, and methodically troubleshoot why a Pod is running but unreachable.

### Week 12 · Kubernetes Production Troubleshooting: Workloads, Services & Networking
*You gain a repeatable, evidence-based method for diagnosing and fixing real Kubernetes failures - from crashing pods to unreachable Services - the way an on-call DevOps/SRE engineer does in production EKS.*

**What you'll learn**
- Evidence-First Troubleshooting: Symptom vs Root Cause vs Fix vs Validation
- Pod Lifecycle and Failure States (Pending, CrashLoopBackOff, ImagePullBackOff)
- Diagnosing Workloads With kubectl get, describe, logs --previous, and events
- OOMKilled Containers and Reading Last State / Exit Code 137
- Unschedulable Pending Pods From Oversized Resource Requests
- CreateContainerConfigError From Missing ConfigMaps and Secrets
- Debugging Shell-Less Distroless Images With kubectl debug Ephemeral Containers
- Live Resource Usage With kubectl top and metrics-server
- Service Routing: Labels, Selectors, Endpoints, and port vs targetPort
- Kubernetes DNS and Service Discovery (NXDOMAIN, Namespaced Names, FQDNs)
- Readiness vs Liveness Probes and Diagnosing Liveness Restart Loops
- NetworkPolicy Default-Deny and Service Mesh / mTLS Awareness
- Connectivity Testing With port-forward and Temporary Test Pods
- Mapping Local Troubleshooting to EKS, ECR, IAM, ALB, and CloudWatch

**Hands-on lab:** Using the kubernetes-fundamentals and k8s-production-ops labs on a live kind cluster, you reproduce and fix eleven broken workloads across two sessions - five pod faults (bad image, CrashLoop, missing ConfigMap, Pending, OOMKilled exit 137) and six reachability faults (selector mismatch, wrong targetPort, readiness failure, liveness restart loop, NetworkPolicy block, broken DNS) - capturing the evidence that proves each root cause and validating recovery with rollout status and curl.

**Outcome:** By the end you can take an unhealthy Kubernetes deployment, follow status -> describe -> events -> logs -> manifest evidence to the true root cause, apply the smallest safe fix, validate recovery, and communicate a clear incident update - whether the failure is in the pod, the Service, DNS, probes, or network policy.

### Week 13 · Helm: Packaging, Templating & Production Release Workflows for Kubernetes
*You gain the ability to package Kubernetes applications into reusable, version-controlled Helm charts and run safe, production-grade deploy, upgrade, and rollback workflows across multiple environments.*

**What you'll learn**
- Chart anatomy: Chart.yaml, values.yaml, templates/, _helpers.tpl, NOTES.txt
- Authoring Go templates: .Values, if/else, range, with, and named templates
- Whitespace control and indentation with nindent, toYaml, and chomps
- Rendering and validating locally with helm template, helm lint --strict, and dry-run
- Chart vs release: one chart, many releases and environments
- Helm vs Kustomize: when to template vs patch, and how they coexist
- Subcharts, dependencies, Chart.lock, and OCI registry distribution
- Environment-specific values files for dev and prod
- Safe upgrades with helm upgrade --install, --atomic, --wait, --cleanup-on-fail
- Plan-before-apply using the helm diff plugin
- Release history and rolling back with helm history and helm rollback
- Helm hooks, helm test, and ordered DB-migration jobs
- Secrets handling with External Secrets Operator, Sealed Secrets, and SOPS
- GitOps reality: where helm rollback causes drift and git revert wins

**Hands-on lab:** Using the backing 'helm-charts' lab, you complete the TODO gaps in a starter chart, author templates with conditionals/loops/helpers, render and lint it, then deploy separate dev and prod releases, perform an upgrade, inspect history, and prove --atomic auto-rolls-back a broken image tag — all validated against a live kind cluster with kubeconform and server-side dry-run.

**Outcome:** By the end you can author, lint, and render a production-grade Helm chart and run a safe multi-environment deploy/upgrade/rollback workflow that fails closed instead of leaving a broken release running.

### Week 14 · Terraform Foundations: Infrastructure as Code on AWS
*You go from clicking around the AWS Console to defining real cloud infrastructure as reusable, reviewable code, mastering the full Terraform workflow and writing secure-by-default, variable-driven configurations a team can trust.*

**What you'll learn**
- Infrastructure as Code and Declarative vs Manual Provisioning
- Configuring the AWS Provider and Validating Identity with STS
- The Core Terraform Workflow: Init, Fmt, Validate, Plan, Apply, Destroy
- Provider, Resource, and Data Source Blocks
- The Dependency Graph and Implicit vs Explicit Dependencies
- Secure-by-Default S3: Public Access Block, SSE Encryption, and Versioning
- Reading and Protecting Terraform State (Plaintext Secrets Risk)
- Input Variables with Types, Descriptions, Defaults, and Validation
- Complex Types: Bool, List, Map, and Object, Plus merge() and locals
- Providing Values with terraform.tfvars Across Environments
- Outputs and Marking Sensitive Values for CI and PR Safety
- Generating Unique Names with the Random Provider
- Detecting and Reasoning About Configuration Drift
- Terraform vs OpenTofu and Enterprise Plan-Review Discipline

**Hands-on lab:** Using the backing lab 'terraform-aws-foundations', you build a secure-by-default S3 bucket (public-access block, encryption, versioning) and then refactor it into a reusable, variable-driven configuration with tfvars and outputs, running the full init/plan/apply/destroy cycle, inspecting state, and completing the starter's TODO security controls before checking against the validated solution and running ./validate.sh.

**Outcome:** By the end you can write, validate, and apply clean Terraform that provisions real, securely-configured AWS resources, parameterize it with variables and outputs for reuse, inspect and protect state, and safely tear everything down.

### Week 15 · Terraform Enterprise Workflows: Modules, Remote State & CI/CD
*You will learn to structure Terraform the way real platform teams do and deliver changes safely with remote state, plan review, drift detection, and a CI/CD pipeline.*

**What you'll learn**
- Modules vs. Environments: enterprise repository structure
- Reusable VPC module with typed, validated input variables
- Per-environment dev/prod folders driven by terraform.tfvars
- Module sources and version pinning (local, Git ref, registry)
- for_each vs. count for instantiating many resources safely
- Environment-separation strategies and their tradeoffs (folders, var-files, Terragrunt, workspaces)
- Terraform state, remote S3 backends, and DynamoDB state locking
- Reading terraform plan: create, update, destroy, and replace
- Drift detection and a safe drift-response process
- The plan-artifact handoff: plan -out=tfplan then apply tfplan
- Safe Terraform CI/CD pipelines with fmt, validate, scan, plan, and gated apply
- OIDC keyless authentication from CI to AWS (no static keys)
- Policy-as-code scanning with tfsec, Checkov, and OPA/Conftest
- Native terraform test, force-unlock, and managed TACOS platforms

**Hands-on lab:** Using the terraform-aws-foundations lab, you build a multi-environment repo with a reusable VPC root-and-child module, parameterize dev/prod via tfvars, then add S3/DynamoDB backend configs, a security-scanned plan-artifact GitLab CI pipeline, and a native terraform test, validating it all with ./validate.sh.

**Outcome:** By the end you can structure a team-ready Terraform repository and deliver infrastructure changes safely with remote state, locking, plan review, drift handling, and a reviewed CI/CD apply.

### Week 16 · Observability & Reliability: Metrics, Tracing, Alerting & Production Readiness
*You gain the ability to instrument, visualize, and alert on real services using both the portable open-source stack (Prometheus, Grafana, Loki, Tempo, OpenTelemetry) and AWS CloudWatch, then judge whether a system is truly ready to run in production.*

**What you'll learn**
- Monitoring Vs Observability and the Three Pillars (Logs, Metrics, Traces)
- The Four Metric Types: Counter, Gauge, Histogram, Summary
- Percentiles (p50/p95/p99) and the Average-Latency Anti-Pattern
- Scraping a /metrics Endpoint with Prometheus and Writing RED-Method PromQL
- Deriving p95 Latency with histogram_quantile
- Building RED Dashboards in Grafana
- Distributed Tracing with OpenTelemetry, Spans, and Tempo
- Cardinality, Label Hygiene, and Metric Cost Control
- RED and USE Methods for Choosing What to Instrument
- CloudWatch Logs, Metrics, Dashboards, and Custom Metrics via AWS CLI
- Reliability Framing: SLI, SLO, SLA, and Error Budgets
- Symptom-Based Alerting and the Availability-Vs-AND Nuance
- Prometheus Alerting Rules and Alertmanager Routing, Grouping, and Inhibition
- Production-Readiness Checklists, Runbooks, Backups, and Go-Live Decisions

**Hands-on lab:** Backed by the 'observability' and 'observability-stack' labs, you run a local Prometheus + Grafana + OpenTelemetry stack against an instrumented demo app, push logs/metrics/dashboards to real CloudWatch via the AWS CLI, then author and validate symptom-based Prometheus alerting rules (with a behavioral promtool test and a deliberately broken fixture) plus a CloudWatch alarm, and complete a production-readiness checklist with a go-live decision.

**Outcome:** By the end you can instrument a service, build dashboards and traces that reveal real user impact, write symptom-based alerts that page on the right signals, and assess a service's production readiness with a defensible go-live recommendation.

### Week 17 · AWS Landing Zones & Multi-Account Governance at Enterprise Scale
*You learn to design, govern, and operate a secure multi-account AWS foundation — the account structure, guardrails, identity, and networking that every enterprise workload lands on.*

**What you'll learn**
- AWS Organizations, OUs, and the management account
- Enterprise account model: log archive, security, network, shared services, dev/test/prod
- Blast radius reduction and account separation strategy
- Account vending with Control Tower Account Factory, AFT, and Landing Zone Accelerator
- IAM Identity Center permission sets and account assignments
- Service Control Policies (SCPs) vs IAM permissions and explicit deny
- Resource Control Policies, declarative policies, and delegated administration
- Preventive vs detective guardrails (block public S3, protect CloudTrail)
- Safe SCP rollout: validate, stage in a sandbox OU, then expand
- Break-glass access design with hardware MFA and CloudTrail alarms
- Multi-account networking: Transit Gateway, centralized egress, and AWS RAM
- Automated remediation with AWS Config, EventBridge, and SSM
- Access-denied troubleshooting across accounts, roles, and policies
- AWS vs Azure vs GCP account/governance hierarchy comparison

**Hands-on lab:** In a disposable sandbox AWS Organization you create a real OU, author and attach a region-guardrail SCP, build and inspect an IAM Identity Center permission set, then validate and tear it all down — backed by the 'security-automation' lab (SCP/IAM policy-as-code and a least-privilege auditor) and the 'terraform-aws-foundations' lab (a VPC account baseline you apply and destroy on a real AWS account).

**Outcome:** By the end you can design a governed multi-account AWS landing zone and enforce it with OUs, SCPs, Identity Center permission sets, and shared networking, then troubleshoot access-denied failures across the organization.

### Week 18 · Cloud Cost Optimization & FinOps Operations
*You gain the FinOps skills to see, explain, and safely reduce AWS spend, turning a runaway cloud bill into evidence-based optimization actions and a monthly cloud operations report.*

**What you'll learn**
- Cloud Cost Visibility With AWS Cost Explorer And Budgets
- Tagging Standards And Cost Allocation Tags
- The FinOps Framework: Inform, Optimize, Operate
- Unit Economics And Cost Per Business Unit
- Cost Anomaly Detection And Budget Alerts With Owners
- CUR 2.0 And Athena For Cost Analysis At Scale
- Organizations Tag Policies For Governance
- Rightsizing With Compute Optimizer And Trusted Advisor
- Idle Resource Cleanup: EBS, Snapshots, ALBs, Elastic IPs
- Commitment Strategy: Spot, Savings Plans, And Reserved Instances
- Coverage, Utilization, And Commitment Laddering
- Graviton Migration And gp2-to-gp3 Quick Wins
- Non-Prod Scheduling Automation With EventBridge And Lambda
- Monthly Cloud Operations Reporting And Action Trackers

**Hands-on lab:** Using the 'python-automation' lab you complete and validate three pure, unit-tested Python tools (tag_audit.py to flag resources missing required tags, ec2_rightsize.py to recommend resize actions from CPU/memory data, and cost_report.py to summarize Cost Explorer spend), then analyze sample cost and utilization data to build a finance-ready monthly cloud operations report with a prioritized optimization action tracker.

**Outcome:** By the end you can investigate an unexpected AWS bill, separate real business growth from avoidable waste, and recommend safe, owner-approved cost optimizations backed by tagging, budgets, commitment strategy, and automation.

### Week 19 · DevSecOps & Secure Software Supply Chain
*You learn to operate a real DevSecOps scanning program end to end, wiring SAST, dependency, secret, container, and IaC scanners into blocking CI/CD gates and proving supply-chain integrity with SBOMs, signing, and admission control.*

**What you'll learn**
- Shift-Left Security and STRIDE Threat Modeling for Pipelines
- Secret Scanning with Gitleaks and False-Positive Tuning
- SAST with Semgrep and Dependency/SCA Scanning with Trivy and Grype
- Building Blocking Security Gates That Stop the Pipeline (No allow_failure)
- Vulnerability-Management Lifecycle: Owner, Severity, and Remediation SLAs
- OIDC Keyless Pipeline Identity and Least-Privilege IAM
- Hardened Dockerfiles: Multi-Stage, Non-Root, Distroless, Digest-Pinned
- Container Image Scanning with Trivy and Cross-Checking with Grype
- IaC Policy-as-Code with Checkov and OPA/Conftest (Rego)
- SBOM Generation with Syft (CycloneDX/SPDX)
- Image Signing and Attestation with Cosign/Sigstore and SLSA Provenance
- Kyverno Admission Control to Enforce Signed-Images-Only Deployment
- Amazon ECR Scan-on-Push and EventBridge as a Control Point
- Secret Rotation, Git-History Exposure, and Secure Delivery Policy Design

**Hands-on lab:** Backed by the security-automation and cicd-pipelines labs, you run gitleaks, semgrep, trivy, grype, and syft against a sample repo and build a CI/CD pipeline whose secret-scan gate actually blocks a planted AWS key, then in Class 2 you build a hardened distroless image, scan it, enforce Checkov + OPA/Conftest policy on Terraform, and sign/verify the image with cosign behind a Kyverno admission policy.

**Outcome:** By the end you can design and operate a blocking DevSecOps pipeline that scans code, dependencies, secrets, container images, and infrastructure, then signs and verifies artifacts so only attested, low-risk releases reach an AWS environment.

### Week 20 · Platform Engineering & Golden Paths: Building Developer Self-Service
*You learn to think and build like a platform team, packaging repeatable DevOps work into a reusable, secure-by-default golden path that lets application teams self-serve their way from a new repo to a running service on EKS.*

**What you'll learn**
- Platform Engineering vs DevOps vs SRE Responsibilities
- Golden Paths, Paved Roads, and Developer Self-Service
- Internal Developer Platforms: Portal, Catalog, and Scaffolder (Backstage / Port)
- Backstage Software Templates and catalog-info.yaml Service Registration
- Control-Plane (Crossplane) vs CI-Driven Terraform Self-Service
- Reusable CI/CD: GitHub workflow_call and GitLab include Templates
- Building a Real Helm Chart with Probes, Non-Root securityContext, and values.schema.json
- Enforced Security Gates: Trivy Image Scan and Checkov IaC/Helm Scan
- OIDC Keyless AWS Authentication with Least-Privilege Pipeline Roles
- Reusable Terraform Module for ECR, IAM Roles, and Required Cost Tags
- GitOps Deploy Path with Argo CD: selfHeal, prune, and Rollback-by-Revert
- Onboarding Docs, Ownership Metadata, and Rollback Runbooks
- Operationalizing Platform-as-a-Product with DORA and DX/SPACE Metrics
- Troubleshooting Template Misuse from Missing Inputs and Weak Validation

**Hands-on lab:** Using the platform-golden-path and helm-charts labs, you build a complete golden-path starter template from scratch, scaffolding the repo structure, a real installable Helm chart (Chart.yaml, templates, and a values.schema.json that fails bad inputs at render time), a reusable GitHub workflow with enforced Trivy/Checkov scans and OIDC auth, a Terraform module that provisions an ECR repo and least-privilege pipeline role, and an Argo CD Application, then validate it with helm lint, helm template, and terraform plan.

**Outcome:** By the end you can design and ship a secure, self-service golden path that takes an application team from a scaffolded repo through a reusable scanning pipeline to a GitOps-deployed service on EKS, with ownership, runbooks, and DORA/DX metrics baked in.

### Week 21 · SRE Foundations: SLIs, SLOs, Error Budgets & Incident Response
*You learn to define reliability as measurable numbers (SLIs/SLOs), turn them into spendable error budgets with burn-rate alerting, and run the on-call, incident-command, and postmortem practices that keep production reliable.*

**What you'll learn**
- The Four Golden Signals: Latency, Traffic, Errors, Saturation
- Reliability vs Availability vs Uptime and User-Perceived Reliability
- Writing SLIs as Good-Events / Valid-Events Specifications
- Request-Based vs Window-Based SLIs and Threshold Latency SLIs
- SLI vs SLO vs SLA and Why the SLA Stays Looser Than the SLO
- Critical User Journey (CUJ) Driven SLI Selection
- Nines-to-Downtime Budgets (What 99.9% Really Costs)
- Computing SLIs from Real Metrics with PromQL and CloudWatch Metrics Insights
- Error Budgets as Spendable Downtime Minutes and Failed Events
- Burn Rate and Multi-Window Multi-Burn-Rate (MWMBR) Alerting
- SLO-as-Code with Sloth and OpenSLO
- Writing an Error-Budget Policy (Triggers, Freeze Scope, Decision Owner, Override)
- Toil, the 50% Cap, On-Call Rotations, and Escalation
- Incident Command Roles, Severity Levels, and Blameless Postmortems

**Hands-on lab:** Using the sre-incident-response and observability-stack labs, you author and compute an SLI specification for the Order Tracking Platform, then build error-budget math, multi-window burn-rate alert rules, an error-budget policy, and a blameless postmortem driven by a live injected-incident drill (inject a 503 readiness fault on a kind cluster, observe the outage, roll back, and verify recovery).

**Outcome:** By the end you can define SLIs/SLOs for a critical user journey, convert them into an error budget with multi-window burn-rate alerts in PromQL and CloudWatch, codify them as SLO-as-code, and command an incident through to a blameless postmortem with owned action items.

### Week 22 · Performance Engineering, Capacity Planning & Production Scaling
*You learn to measure system performance with evidence, locate the true bottleneck before reacting, and plan capacity and autoscaling that holds up under real load instead of just adding pods.*

**What you'll learn**
- Latency, Throughput, and Saturation: Why p99 Is Not the Average
- Latency Percentiles (p50/p95/p99) and Tail Latency
- The RED and USE Methods for Triaging Services and Resources
- Little's Law for Connection-Pool and Concurrency Sizing
- Open vs Closed Load Models and Coordinated Omission
- k6 Load Testing with Ramp, Steady-State, and Soak Stages
- Finding the Saturation Knee in Throughput vs Latency Curves
- Bottleneck Hunting with Distributed Tracing and Flame Graphs
- Horizontal Pod Autoscaler: CPU, Custom Metrics, and Target-vs-Request
- Vertical Pod Autoscaler, metrics-server, and PodDisruptionBudgets
- Cluster Autoscaler vs Karpenter for Node Capacity
- Event-Driven Scaling and Scale-to-Zero with KEDA on SQS
- Caching Patterns: CDN Edge Caching and Cache-Aside Redis
- Scalability Patterns: Read Replicas, Sharding, Queues, Backpressure, Circuit Breakers, and Retry-with-Jitter
- Headroom, Forecasting, and Cost-Aware Capacity Planning

**Hands-on lab:** Using the 'performance-scaling' lab, you deploy a real HorizontalPodAutoscaler with metrics-server on a Kubernetes cluster, drive it with a k6 ramp/steady/soak load test, watch pods scale 1 to 5 under live load, and observe the second-order effect where the app scales but the database connection pool saturates, then size the pool with Little's Law and write an evidence-based, cost-aware capacity plan.

**Outcome:** By the end you can load-test a production-style service, prove which resource is the real bottleneck with metrics and traces, size pools and replicas with Little's Law and headroom math, and configure HPA/VPA/KEDA scaling that fixes the right layer instead of making latency worse.

### Week 23 · Final Project — Build: Secure CI/CD Supply Chain to EKS with GitOps & Observability
*You combine every skill from the course into one end-to-end delivery system: build and sign a container image through a secure CI/CD pipeline, store it in Terraform-provisioned ECR, and deploy it to EKS with Helm, GitOps, and SLO-backed monitoring.*

**What you'll learn**
- Final Project Repository Structure for App, Helm, Terraform, and Docs
- Multi-Stage, Non-Root, Distroless Dockerfile Builds
- Provisioning ECR as Code with Terraform (KMS, Immutable Tags, Lifecycle Policy)
- Commit-SHA Image Tagging and ECR Authentication
- OIDC Keyless CI/CD with No Long-Lived AWS Keys
- Gating Trivy Vulnerability Scans with a Documented Exception Path
- SBOM Generation, Cosign Image Signing, and SLSA Provenance
- Authoring Architecture Decision Records (ADRs) for Key Trade-Offs
- Provisioning EKS, VPC, Node Groups, and IRSA with Terraform
- Building a Helm Chart with Probes, Resource Limits, and Values
- Deploying with helm upgrade --install and Rollback via Helm History
- Ingress, AWS Load Balancer Controller, and TLS via ACM
- GitOps Continuous Deployment with Argo CD
- Deployed Observability: Prometheus, Grafana, and an SLO Burn Alert
- Troubleshooting ImagePullBackOff, Probe Failures, and Service Selector Issues

**Hands-on lab:** Using the 'final-project' lab, you build a non-trivial Node.js app into a distroless image, provision ECR with Terraform, run it through an OIDC-authenticated pipeline that scans, signs, and generates an SBOM, then provision an EKS cluster and deploy the app via a Helm chart with GitOps, Ingress/TLS, and a Prometheus alert wired to a 99.5% availability SLO.

**Outcome:** By the end you can take an application from a Git commit to a signed, scanned image running in EKS through a fully automated, observable, and rollback-ready delivery pipeline you can defend in an interview.

### Week 24 · Final Project — Finalization: Production Readiness, Defense & Interview Prep
*You finalize your end-to-end DevOps final-project into a portfolio- and interview-ready project, then present and defend it under a realistic senior technical review with live evidence.*

**What you'll learn**
- End-to-End Final Project Validation From Git Commit to Live Kubernetes Workload
- Running a Production-Readiness Review (PRR) Against an Evidence-First Checklist
- Authoring MADR-Style Architecture Decision Records (ADRs)
- Proving Infrastructure Is Provisioned With terraform plan and state list, Not Just validate
- OIDC Keyless CI Authentication and Gating Security Scans as Baseline Controls
- Live Observability: Dashboard, Alert Rule, and SLO With Error Budget
- Helm Release History, Rollback, and Recovery Demonstration
- Docker Build, ECR, and EKS Artifact-to-Deployment Workflow Checks
- IAM Least-Privilege Design and AWS Identity Validation
- Evidence-First Troubleshooting of ImagePullBackOff, CrashLoopBackOff, and IAM/ECR Failures
- Presenting the Business Problem, Architecture, and Tradeoffs Professionally
- Open-Ended System Design on Unfamiliar Prompts (Clarify, Scale, Tradeoffs, Failure Modes)
- Senior Behavioral STAR Drills: Leadership, Mentoring, Disagreement, Incident Command
- Quantifying Impact (Deploy Frequency, MTTR, Cost) and Building a Portfolio Summary

**Hands-on lab:** Using the backing 'final-project' lab, you polish and validate your full delivery pipeline (Docker, ECR, EKS, Helm, Terraform, IAM, CloudWatch), prove the infrastructure is really provisioned, wire up live observability and a tested rollback, then present and defend the project while diagnosing an instructor-injected failure.

**Outcome:** By the end you can ship, validate, and defend a complete production-style DevOps final-project with keyless CI, IaC-provisioned infrastructure, live SLO-backed monitoring, and rollback, while reasoning through novel system-design and behavioral interview questions under pressure.

### Week 25 · Job-Ready: Resume, Portfolio & DevOps/Cloud/SRE Interview Mastery
*You turn 24 weeks of skills and your final-project into hireable artifacts and the interview performance to win the offer, positioned at junior, mid, or senior level.*

**What you'll learn**
- ATS-Safe, Single-Column Resume Anatomy for the 2026 Screening Funnel
- X-Y-Z Quantified Impact Bullets and DORA Metrics
- Mapping Final Project and Weekly Labs to Metric-Bearing Resume Bullets
- Junior vs Mid vs Senior Positioning by Scope, Ownership, and Decisions
- LinkedIn Optimization: Headline, About, Skills, and Featured
- Senior-Signal GitHub Portfolio: READMEs, Diagrams, ADRs, and Pinned Repos
- AWS/CKA/Terraform Certification Strategy and 12-Month Plan
- The Full Interview Loop: Screen, Design, Debug, Behavioral, Take-Home
- Technical Screen Q&A: Linux, Networking, Containers, K8s, IaC, CI/CD
- 6-Step System Design Method with Failure Domains, SLOs, and Cost Tradeoffs
- Live Troubleshooting with the Symptom-Evidence-Root-Cause-Fix-Validate Method
- STAR Behavioral Stories Including Incident Command and Mentoring
- Take-Home Assignment Scoping and Submission Quality Signals
- Salary Negotiation: Leveling, Total Comp, and Counter-Offer Scripts

**Hands-on lab:** Backed by the 'career-prep' lab, you build a complete job-ready artifact pack (ATS-safe resume from the template, a portfolio README with an architecture diagram and an ADR, and an optimized LinkedIn profile), then run a full peer mock-interview loop, diagnose a pre-broken pod/pipeline/networking scenario aloud, and score yourself against the provided rubrics with ./validate.sh.

**Outcome:** By the end you can produce a quantified, correctly-leveled resume and senior-signal portfolio that survive automated screening, and confidently work through technical, system-design, live-debugging, behavioral, and salary-negotiation rounds.

---

## Hands-On Projects & Portfolio

- **21 runnable, validated lab modules** — Every hands-on technology ships as real files you clone, complete, and validate — not slides. Each module has a starter, a reference solution, and an automated validate.sh.
- **Live AWS infrastructure** — Provision a production-shaped multi-AZ VPC and a secure S3 + DynamoDB data layer with Terraform on a real AWS account — then tear it down cleanly (cost-safe: build → verify → destroy).
- **Live Kubernetes operations** — On a real cluster: autoscale under load (HPA), perform a rolling update and rollback, enforce a PodDisruptionBudget and a NetworkPolicy, and reproduce & fix OOMKilled / failing-probe pods.
- **Observability & incident response** — Deploy Prometheus + Grafana, define SLOs and burn-rate alerts, fire a real alert, then run an injected production incident — detect, mitigate, recover, and write a blameless postmortem.
- **Final Project: production-ready system** — Integrate IaC + containers + Kubernetes + CI/CD + observability into one deployable, documented system with Architecture Decision Records and a production-readiness review.
- **Platform golden path** — Build a self-service service template + generator that produces a production-ready microservice (Dockerfile, Helm chart, CI, manifests) — your second portfolio project.

---

## Tools & Technologies You'll Master

- **Operating System & Scripting:** Linux, Bash, Python, YAML, JSON, cron / systemd timers
- **Version Control & Collaboration:** Git, GitHub, GitLab, pre-commit hooks, PR/MR review, branch protection, CODEOWNERS
- **Cloud (AWS-first):** IAM Identity Center (SSO), VPC, EC2, S3, EBS, DynamoDB, RDS, Organizations & SCPs, Budgets, CloudWatch, Cost Explorer
- **Infrastructure as Code:** Terraform (OpenTofu-compatible), Checkov security scanning, modules, remote state with native S3 locking
- **Containers:** Docker, multi-stage & distroless images, Docker Compose, Hadolint
- **Orchestration:** Kubernetes, Helm, Kustomize, HPA autoscaling, NetworkPolicy (Calico), kind
- **CI/CD:** GitHub Actions, GitLab CI, OIDC keyless deploys, build & deploy strategies
- **Configuration Management:** Ansible — playbooks, roles, ansible-lint
- **Observability & SRE:** Prometheus, Grafana, PromQL, SLOs & error budgets, multi-burn-rate alerting, k6 load testing, OpenTelemetry Collector config
- **Security & Supply Chain:** OPA / Conftest policy-as-code, Grype CVE scanning, Syft SBOM, gitleaks secret scanning, IAM least-privilege
- **Platform Engineering:** Self-service golden-path scaffolding — a service template + generator that emits a production-ready microservice

*Also introduced (concepts & awareness):* GitOps (Argo CD / Flux), OpenTofu, image signing (Cosign / Sigstore), Backstage / Crossplane, and DORA / SPACE metrics — covered as concepts so the vocabulary and trade-offs transfer, with hands-on depth focused on the tools above.

---

## Learning Outcomes

By the end of this program you can:

- Provision cloud infrastructure as code with Terraform and validate it with policy and security scans
- Design and build a secure, multi-AZ AWS network and apply IAM least-privilege and cost guardrails
- Containerize applications with secure, minimal images and scan them for vulnerabilities
- Deploy, scale, upgrade, roll back, and troubleshoot workloads on Kubernetes
- Package and ship applications with Helm and Kustomize
- Build CI/CD pipelines with automated tests and security gates that fail bad builds
- Automate configuration and servers with Ansible and Python/Bash
- Instrument services with Prometheus/Grafana, define SLOs, and alert on error budgets
- Lead an incident response and write a blameless postmortem
- Run load tests and make capacity, performance, and reliability decisions
- Apply DevSecOps: SBOMs, policy-as-code, CVE scanning, and supply-chain security
- Present a real, runnable portfolio and pass technical and system-design interviews

---

## Why This Program

- **You build it, you run it, you prove it** — Most courses stop at slides and copy-paste snippets. Here, every lab is a real, executable project validated by automated checks — and the toughest skills are demonstrated on live AWS and a live Kubernetes cluster.
- **You're never stuck alone** — Everyday live whiteboard sessions let you work through concepts and problems together in real time, and a monthly one-on-one with your instructor keeps your progress, code, and portfolio on track.
- **AWS-first, multi-cloud aware** — Deep, practical AWS skills with Azure and GCP comparison notes so concepts transfer to any cloud.
- **A 2026-modern stack** — IAM Identity Center & OIDC (not long-lived keys), native S3 state locking, OpenTelemetry, SBOM & policy-as-code, modern Kubernetes autoscaling, and CVE scanning that gates builds.
- **A portfolio that gets interviews** — You graduate with two substantial projects, a validated infrastructure repo, an observability + incident-response story, and Architecture Decision Records — concrete proof for hiring managers.
- **Job-ready by design** — The final track is dedicated to resume, portfolio, system-design, and interview preparation with model answers and mock interviews.

---

## Ready to Build the Infrastructure Engineering Skills Companies Need Today?

Apply or request program details:

**admissions@leadsacademy.org** | **(804) GOLEADS · (804) 465-3237**

*LEADS ACADEMY · DevOps, Cloud & SRE Training · leadsacademy.org*
