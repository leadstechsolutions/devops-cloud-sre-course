# Week 18, Class 2 Package
**Track:** Unified DevOps · Cloud · SRE Track
> **▶ Runnable lab for this class:** [`labs/python-automation/`](../../labs/python-automation/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2: Rightsizing, Cleanup, Reserved Capacity, and Cost Reporting

---

## 1. Class Overview

### Class Title

**Rightsizing, Idle Cleanup, Reserved Capacity, and Cloud Operations Reporting**

### Class Purpose

This class teaches students how to move from cloud cost visibility to safe optimization action. In Class 1, students learned how to identify cost drivers, missing tags, ownership gaps, and budget needs. In Class 2, students learn how to turn those findings into practical recommendations: rightsizing, idle cleanup, reserved capacity review, log retention review, and monthly cloud operations reporting.

### How This Class Builds From Class 1

Class 1 answered:

```text
Where is the cloud cost coming from?
Who owns it?
Which services increased?
Which tags are missing?
Which budget alerts are needed?
```

Class 2 answers:

```text
What should we safely do about it?
Which resources can be cleaned up?
Which resources need rightsizing?
Which costs are valid business costs?
How do we report recommendations to finance and leadership?
```

### What Students Will Build, Analyze, or Practice

Students will:

- Review cost findings from Class 1.
- Analyze sample resource utilization data.
- Identify rightsizing candidates.
- Identify idle cleanup candidates.
- Create safe optimization recommendations.
- Build a monthly cloud operations report.
- Draft a finance-friendly cost update.
- Investigate an unexpected AWS bill increase after non-prod testing.

---

## 2. Quick Review of Class 1

### Review Points

1. Cloud cost is an engineering and operations responsibility, not only a finance concern.
2. AWS Cost Explorer helps analyze spend by service, account, usage type, region, and tag.
3. Tags connect resources to owners, applications, environments, and cost centers.
4. AWS Budgets provide alerts, but alerts require owners and response actions.
5. Missing tags make cost investigations slower and less reliable.
6. Not every cost increase is bad. Some increases reflect valid business growth.
7. Cost optimization should be evidence-based, not guess-based.
8. Cleanup without validation can cause outages, data loss, or compliance issues.

### Quick Recall Questions

1. **Which AWS service helps analyze spend by service or usage type?**  
   Expected answer: AWS Cost Explorer.

2. **Why is the `Owner` tag important?**  
   Expected answer: It identifies who is accountable for the resource and who should respond to cost questions.

3. **What is the risk of deleting an expensive resource without validation?**  
   Expected answer: It may cause outage, data loss, or loss of required logs, snapshots, or backups.

### Common Gaps Students May Still Have From Class 1

| Gap | Instructor Response |
|---|---|
| Students may think optimization means cutting every cost | Reinforce that optimization means reducing waste while protecting business value |
| Students may not distinguish expected growth from waste | Use production growth vs idle non-prod examples |
| Students may not understand NAT Gateway cost | Explain hourly cost plus data processing cost |
| Students may think tags automatically appear in billing reports | Explain that AWS cost allocation tags often need activation |
| Students may recommend cleanup without approval | Require every recommendation to include risk and owner validation |

### Bridge Into Class 2

Instructor transition:

```text
In Class 1, we learned how to see cloud cost. Today we focus on what to do after we see it. Cost visibility gives us the evidence. Class 2 turns that evidence into safe engineering actions, reports, and recommendations.
```

---

## 3. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** common cloud waste patterns such as idle resources, oversized compute, excessive logs, and unused storage.
2. **Analyze** cost and utilization data to identify rightsizing and cleanup candidates.
3. **Design** a commitment strategy across On-Demand, Spot, Compute/EC2 Savings Plans, and Reserved Instances, reasoning about coverage, utilization, 1yr/3yr terms, and laddering.
4. **Use** AWS Compute Optimizer and Trusted Advisor concepts to support optimization decisions.
5. **Document** a monthly cloud operations report with cost, tagging, risk, and action items.
6. **Troubleshoot** an unexpected AWS bill increase using service, usage, tag, and ownership evidence.
7. **Recommend** safe optimization actions that consider production impact, security, and reliability.
8. **Communicate** cost findings clearly to finance, leadership, cloud platform, and application teams.

---

## 4. Prerequisites Students Should Already Know

### Required Class 1 Knowledge

Students should already understand:

- AWS Cost Explorer purpose
- AWS Budgets purpose
- Common AWS cost drivers
- Required tagging strategy
- Actual vs forecasted spend
- Cost ownership and escalation
- Basic cloud cost investigation process

### Required Prior Concepts

Students should know:

- EC2, EBS, S3, RDS, NAT Gateway, ALB/NLB, and CloudWatch basics
- Production vs non-production environments
- IAM and read-only access concepts
- Basic spreadsheet analysis
- Basic operational reporting
- Risk of deleting resources without approval

### Required Tools Already Installed

Students should have:

- VS Code
- Terminal, Git Bash, or PowerShell
- AWS CLI
- Spreadsheet tool such as Excel, Google Sheets, or LibreOffice Calc
- Browser access to AWS Console, if available
- Git, optional

### Required Files, Repos, Lab Outputs, or Setup From Class 1

Students should bring or receive:

```text
week18-class1/
├── sample-aws-cost-report.csv
├── sample-untagged-resources.csv
└── cost-analysis-report-template.md
```

Class 2 adds:

```text
week18-class2/
├── sample-resource-utilization.csv
├── sample-idle-resource-report.csv
├── sample-monthly-cloud-ops-report-template.md
├── sample-finance-update-template.md
└── optimization-action-tracker.csv
```

---

## 5. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Rightsizing | Matching a resource size to actual workload demand | Moving an oversized EC2 instance to a smaller type after utilization review |
| Idle resource | A cloud resource running but not actively used | An unused ALB, unattached EBS volume, or old test instance |
| Underutilized resource | A resource that is used far below its provisioned capacity | EC2 instance averaging 3% CPU for several weeks |
| Reserved Instance (RI) | A capacity/price commitment for a specific instance family (and Region/size for Standard RIs) | Steady, well-known workloads; Convertible RIs trade some discount for flexibility |
| Compute Savings Plan | A $/hour commitment that applies across EC2, Fargate, and Lambda regardless of family, size, OS, or Region | The most flexible commitment; the default starting point in 2026 |
| EC2 Instance Savings Plan | A $/hour commitment locked to one instance family in one Region (size/OS-flexible) | Slightly deeper discount than Compute SP in exchange for less flexibility |
| Spot Instance | Spare EC2 capacity at up to ~90% off, reclaimable with a 2-minute warning | Interruption-tolerant work: batch, CI runners, stateless web, K8s worker nodes |
| Coverage | The share of eligible usage covered by a commitment (RI/SP) | Target steadily, e.g. 70–85%; commit only the durable baseline, leave the spiky top on-demand |
| Utilization | The share of a purchased commitment that is actually used | Aim near 100%; unused commitment is pure waste (you pay whether or not you use it) |
| Laddering | Buying commitments in staggered tranches with different end dates | Avoids a single cliff renewal and locks in baseline incrementally as confidence grows |
| Graviton | AWS ARM-based processors (e.g. m7g, c7g, r7g) | Typically ~20% better price/performance vs comparable x86; a top 2026 cost lever |
| Savings Plan | AWS commitment-based discount model for predictable compute spend | Useful after baseline usage is understood |
| AWS Compute Optimizer | AWS service that recommends rightsizing for compute resources | Helps identify overprovisioned or underprovisioned resources |
| AWS Trusted Advisor | AWS service that provides best-practice checks | Can identify cost, security, reliability, and performance opportunities |
| Optimization recommendation | A proposed action to reduce waste or improve cost efficiency | Example: reduce non-prod log retention from 90 days to 14 days |
| Risk statement | A note explaining possible impact of an optimization action | Example: reducing logs may affect troubleshooting history |
| Exception | A documented reason not to optimize a costly resource | Example: high availability requirement justifies extra capacity |
| Monthly cloud operations report | A recurring report summarizing cost, ownership, risks, and actions | Shared with finance, leadership, platform teams, and application owners |
| Action tracker | A list of optimization tasks with owners, due dates, and status | Prevents cost findings from being forgotten |

---

## 6. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Cost Explorer | Review spend trends and validate whether changes reduce cost |
| AWS Budgets | Track spend against monthly thresholds |
| AWS Compute Optimizer | Review rightsizing recommendations |
| AWS Trusted Advisor | Review cost optimization and best-practice findings |
| AWS CLI | Query identity, resource metadata, and cost data where permissions allow |
| Spreadsheet tool | Analyze utilization, idle resource, and monthly report data |
| VS Code | Edit Markdown reports and templates |
| Git, optional | Version-control report templates, standards, and action trackers |
| Terminal or PowerShell | Run local commands and AWS CLI examples |

---

## 7. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| AWS Cost Explorer | Validates cost trends and shows where spend changed |
| AWS Budgets | Tracks actual and forecasted spend against thresholds |
| AWS Compute Optimizer | Provides rightsizing recommendations |
| AWS Trusted Advisor | Provides cost optimization and best-practice checks |
| EC2 | Common rightsizing and scheduling target |
| EBS | Common idle storage and snapshot cleanup target |
| Elastic Load Balancing | Common idle non-prod cost driver |
| NAT Gateway | Common networking cost driver, especially with private subnet egress |
| CloudWatch Logs | Common cost driver due to ingestion and retention |
| RDS | Common rightsizing and reserved capacity discussion point |
| S3 | Storage lifecycle and retention discussion point |
| AWS Organizations, overview | Helps enterprises analyze spend across multiple accounts |
| Resource Groups Tagging API, overview | Supports tag compliance investigation |

---

## 8. Azure and GCP Comparison Notes

| Optimization Area | AWS | Azure | GCP |
|---|---|---|---|
| Rightsizing recommendations | Compute Optimizer | Azure Advisor | Google Cloud Recommender |
| Best-practice recommendations | Trusted Advisor | Azure Advisor | Active Assist |
| Cost analysis | Cost Explorer | Azure Cost Management | Cloud Billing Reports |
| Budget alerts | AWS Budgets | Azure Budgets | GCP Budgets and alerts |
| Tags or labels | Tags | Tags | Labels |
| Commitment discounts | Reserved Instances, Savings Plans | Reservations, Savings Plans | Committed Use Discounts |

Instructor note:

Keep this brief. The main pattern is the same across clouds:

```text
Detect → Investigate → Classify → Recommend → Approve → Implement → Validate
```

---

## 9. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Welcome and Class 1 review |
| 0:10 to 0:25 | Quick recall questions and bridge to optimization actions |
| 0:25 to 0:50 | Common cloud waste patterns and optimization categories |
| 0:50 to 1:15 | Rightsizing, idle cleanup, reserved capacity, and Savings Plans |
| 1:15 to 1:25 | Short break |
| 1:25 to 1:55 | Instructor demo: Compute Optimizer, Trusted Advisor, and cleanup review |
| 1:55 to 2:35 | Student lab: Build a monthly cloud operations report |
| 2:35 to 2:50 | Troubleshooting activity: Unexpected bill increase after non-prod testing |
| 2:50 to 3:00 | Discussion, recap, homework explanation, and week closure |

---

## 10. Instructor Lesson Plan

### Step 1: Start With Class 1 Continuity

Begin with:

```text
Last class, we found cost drivers. Today we decide what actions are safe, useful, and realistic.
```

Ask students:

```text
If NAT Gateway, logs, EBS, and load balancers increased, what should we investigate before recommending cleanup?
```

Expected answers:

- Owner
- Environment
- Production impact
- Usage pattern
- Tags
- Traffic source
- Retention needs
- Whether resources are still needed

### Step 2: Explain Optimization Categories

Teach that cloud optimization actions usually fall into these categories:

1. Rightsize
2. Cleanup
3. Schedule
4. Retain less
5. Use commitment discounts
6. Redesign architecture
7. Improve governance

Mapping example:

| Finding | Possible Action |
|---|---|
| EC2 low CPU | Rightsize, or schedule stop/start for non-prod |
| Non-prod running 24/7 | Automate stop/start (Instance Scheduler or EventBridge + Lambda) |
| Unattached EBS | Snapshot if needed, then delete |
| gp2 volumes | Migrate to gp3 (online, ~20% cheaper) |
| Old snapshots | Apply retention / lifecycle policy as code |
| Cold S3 data | S3 lifecycle / Intelligent-Tiering as code |
| NAT Gateway spike | Analyze traffic, consider VPC endpoints |
| Logs growing fast | Adjust log level or retention |
| Idle ALB | Confirm ownership, then remove |
| x86 workload that runs on ARM | Migrate to Graviton (~20% better price/performance) |
| Interruption-tolerant compute | Move to Spot (batch, CI runners, stateless/K8s workers) |
| Steady compute baseline | Compute Savings Plan; RIs for RDS/ElastiCache/Redshift |

### Step 3: Teach Rightsizing Carefully

Explain:

```text
Rightsizing does not mean choosing the smallest instance. It means choosing the right amount of capacity for the workload.
```

Data needed before rightsizing:

- CPU utilization
- Memory utilization, where available
- Network throughput
- Disk I/O
- Request volume
- Business seasonality
- Production criticality
- Recent deployment or traffic changes

Pause and ask:

```text
Why could rightsizing based only on CPU be dangerous?
```

Expected responses:

- Memory may be the bottleneck.
- Traffic may be seasonal.
- Production workloads may need headroom.
- Some apps spike during batch windows.

### Step 4: Teach Idle Cleanup

Explain that idle resources are common in non-prod environments.

Examples:

- EC2 instances left running after testing
- EBS volumes left after instance deletion
- Load balancers created for temporary demos
- Snapshots with no retention policy
- Unused Elastic IPs
- Old log groups

Teaching point:

```text
Cloud resources continue charging until they are stopped, deleted, or lifecycle-managed.
```

### Step 5: Teach Reserved Capacity and Savings Plans

Keep it practical.

Explain:

- On-demand is flexible but more expensive.
- Commitment discounts are cheaper for predictable usage.
- Do not commit before analyzing usage.
- Non-prod and experimental workloads may not be good candidates.
- Production workloads with steady demand are better candidates.

Warning:

```text
Commitment discounts should usually come after waste cleanup, not before.
```

### Step 6: Instructor Demo

Show AWS Compute Optimizer and Trusted Advisor conceptually or with screenshots/sample data.

Focus on interpretation:

- What does the recommendation say?
- What evidence supports it?
- What risk exists?
- Who must approve it?
- How would we validate after the change?

### Step 7: Student Lab

Students build a monthly cloud operations report using sample data.

Instructor reminder:

```text
A useful report does not only say what is expensive. It explains what changed, why it matters, who owns it, what action is recommended, and what risk exists.
```

### Step 8: Troubleshooting Activity

Students investigate the unexpected bill increase scenario and classify each issue as:

- Expected growth
- Waste
- Misconfiguration
- Needs owner validation
- Needs architecture review

### Step 9: Wrap-Up

Close with:

```text
Cost optimization is a recurring operational practice. The report, action tracker, and review process are just as important as the tool findings.
```

---

## 11. Instructor Lecture Notes

### Visibility Becomes Action

Class 1 focused on identifying cost drivers. Class 2 focuses on taking safe, responsible action.

A beginner mistake is thinking:

```text
High cost = delete or downsize immediately
```

Correct thinking is:

```text
High cost = investigate, classify, validate ownership, assess risk, recommend action
```

Example:

An unattached EBS volume may look unused, but it may contain data needed for rollback, audit, or recovery. A cloud engineer should not delete it blindly.

Recommended process:

1. Identify the resource.
2. Identify the owner.
3. Confirm business need.
4. Confirm backup or retention requirements.
5. Document risk.
6. Take approved action.
7. Validate savings and service health.

Talking point:

```text
Cost optimization without governance can become an outage.
```

### Common Cloud Waste Patterns

Cloud waste often happens because resource creation is easy, but cleanup is inconsistent.

Common waste patterns:

- Temporary test environments become permanent.
- Developers enable debug logging and forget to disable it.
- Load balancers remain after apps are removed.
- EBS volumes remain after EC2 instances are terminated.
- Old snapshots accumulate.
- NAT Gateway traffic grows unexpectedly.
- Teams overprovision because they fear outages.
- Non-prod runs 24/7 even when only used during business hours.

Talking point:

```text
Cloud waste is usually not caused by bad intent. It is caused by missing ownership, missing automation, and missing review process.
```

### Rightsizing Requires Context

A resource with low CPU may be oversized, but CPU alone is not enough.

Ask:

- Is memory high?
- Is this production?
- Is traffic seasonal?
- Does the workload spike at night?
- Is this a failover node?
- Is this intentionally overprovisioned for reliability?

Talking point:

```text
A cheap system that cannot handle traffic is not optimized. It is just underbuilt.
```

### Reserved Capacity and Savings Plans: The Mechanics

The decision pattern (commit on steady baseline, after cleanup) is necessary but not sufficient at a senior bar. You are expected to **run** a commitment strategy, which means knowing the instruments and the math.

**The four pricing models, cheapest-but-riskiest to most-flexible:**

| Model | Discount vs on-demand | Flexibility | Best for |
|---|---|---|---|
| **Spot** | up to ~90% | Can be reclaimed with a 2-min warning | Interruption-tolerant: batch, CI runners, stateless web, K8s workers |
| **EC2 Instance Savings Plan** | high (~up to ~72%) | Locked to one family + Region; size/OS flexible | A large, durable, stable family footprint |
| **Compute Savings Plan** | high (slightly less than EC2 SP) | Spans EC2 + Fargate + Lambda, any family/Region | The default modern commitment |
| **Standard / Convertible RI** | high / moderate | Family-locked / exchangeable | Steady EC2 or RDS/ElastiCache/Redshift/OpenSearch (which SPs do NOT cover) |

Key nuance to teach: **Savings Plans cover EC2, Fargate, and Lambda — but not RDS, ElastiCache, Redshift, or OpenSearch.** For those, Reserved Instances/Nodes are still the commitment tool. So a real strategy usually mixes a Compute SP for compute plus RIs for databases.

**Term and payment options:** commitments are **1-year or 3-year**, with **No / Partial / All upfront** payment. Longer term and more upfront = deeper discount, but more lock-in risk.

**Coverage and utilization — the two numbers a senior watches:**

```text
Coverage    = (eligible usage covered by a commitment) / (total eligible usage)
              Target ~70–85%. Cover the durable BASELINE; leave the spiky top on on-demand/Spot.
Utilization = (commitment actually used) / (commitment purchased)
              Target ~100%. Unused commitment is pure waste — you pay for it regardless.
```

If coverage is low you are leaving discount on the table; if utilization drops below ~100% you over-committed.

**Laddering:** instead of buying one big 3-year commitment, buy in staggered tranches (e.g. some each quarter) with different end dates. This avoids a single renewal "cliff," lets you lock baseline incrementally as confidence grows, and keeps you from over-committing early.

**Where the recommendations come from:** Cost Explorer has a built-in **Savings Plans recommendations** page (and an RI recommendations page) that analyzes 7/30/60-day lookbacks and proposes a commitment with estimated savings, coverage, and utilization. Teach students to read it, sanity-check the lookback against seasonality, and start conservative (commit less than the tool's "max savings" number).

```text
Cost Management → Savings Plans → Recommendations  (choose Compute SP, 1-year, No upfront to start)
```

Talking point:

```text
Clean up first, commit second. Then: Spot for anything interruptible, a Compute Savings Plan for the steady baseline, RIs for the databases SPs don't cover, and ladder the purchases so you never face a single renewal cliff. Coverage ~80%, utilization ~100%.
```

### The Highest-ROI 2026 Levers: Graviton, Spot, and gp2 → gp3

Beyond commitments, three levers give large, defensible savings and come up in every senior cost interview:

**1. Graviton / ARM migration.** AWS Graviton (ARM) instances — `m7g`, `c7g`, `r7g`, Graviton RDS/ElastiCache, Lambda on ARM — typically deliver roughly **20% better price/performance** than comparable x86. The catch is the workload must run on ARM: most managed services and interpreted languages (Python, Node, Java, Go) are trivial; native binaries and some vendor agents need a rebuild/multi-arch image. The migration path: build a multi-arch container image, test on a Graviton node/canary, then shift. (This connects directly to the multi-stage/`--platform` Docker work from Week 10.)

**2. Spot for interruption-tolerant compute.** Up to ~90% off for work that tolerates a 2-minute reclaim warning: CI/CD runners, batch/ETL, rendering, and **stateless Kubernetes worker nodes** (via Karpenter or a managed node group with capacity-rebalance). The rule: never put a stateful singleton on a single Spot instance; do diversify across instance types and AZs so the pool rarely runs dry.

**3. gp2 → gp3 EBS migration.** This is the classic instant-savings move. `gp3` is roughly **20% cheaper per GB than `gp2`** and decouples IOPS/throughput from volume size (gp3 includes a 3,000 IOPS / 125 MB/s baseline you can tune independently). For most volumes the migration is an online `modify-volume` with no downtime:

```bash
# Find gp2 volumes (do this account-wide; gp2 is pure legacy cost for most workloads)
aws ec2 describe-volumes \
  --filters Name=volume-type,Values=gp2 \
  --query "Volumes[].{ID:VolumeId,SizeGiB:Size,AZ:AvailabilityZone}" \
  --output table

# Migrate one volume to gp3 (online, no detach needed; verify app IOPS needs first)
aws ec2 modify-volume --volume-id vol-0123456789abcdef0 --volume-type gp3
```

Cost/safety note:

```text
Check the volume's real IOPS/throughput needs before migrating: gp2 above ~1 TiB gets more
than 3,000 baseline IOPS for free, so a few large high-IOPS gp2 volumes may need gp3 IOPS/throughput
tuned up (a small added cost) to avoid a performance regression. For the vast majority of volumes,
gp3 at the 3,000/125 baseline is both cheaper and adequate.
```

Talking point:

```text
If an interviewer asks for a quick win, say gp2 to gp3 — it's an online change, ~20% off block storage, and almost no risk. Then talk Graviton and Spot for the structural savings.
```

### Automate the Fix: Stop Ending at a Manual Ticket

The biggest non-prod waste is environments running 24/7 when they are used ~50 hours a week. The fix is **scheduling automation**, not a recurring cleanup ticket. Two standard patterns:

- **AWS Instance Scheduler** — an AWS-provided solution that stops/starts EC2 and RDS on a tag-driven schedule (you tag a resource with a schedule name like `Schedule=office-hours`).
- **EventBridge + Lambda** — roll your own: a cron-scheduled rule invokes a Lambda that stops tagged instances in the evening and starts them in the morning.

Illustrative EventBridge Scheduler + Lambda skeleton (the point is the pattern, not production-perfect code):

```python
# stop_nonprod.py — Lambda triggered by an EventBridge cron schedule (e.g. cron(0 19 ? * MON-FRI *))
import boto3

ec2 = boto3.client("ec2")

def handler(event, context):
    # Only touch resources explicitly opted in via tag — never blanket-stop an account
    resp = ec2.describe_instances(
        Filters=[
            {"Name": "tag:Schedule", "Values": ["office-hours"]},
            {"Name": "instance-state-name", "Values": ["running"]},
        ]
    )
    ids = [i["InstanceId"] for r in resp["Reservations"] for i in r["Instances"]]
    if ids:
        ec2.stop_instances(InstanceIds=ids)
    return {"stopped": ids}
```

```hcl
# Terraform: schedule that fires the stop Lambda every weekday at 19:00 UTC
resource "aws_scheduler_schedule" "stop_nonprod" {
  name                = "stop-nonprod-office-hours"
  flexible_time_window { mode = "OFF" }
  schedule_expression = "cron(0 19 ? * MON-FRI *)"
  target {
    arn      = aws_lambda_function.stop_nonprod.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
```

Stopping non-prod for the ~118 non-office hours per week is roughly a **65% compute saving** on those environments — with zero impact, because no one is using them.

Other remediation that should be IaC, not tickets:

- **S3 lifecycle / Intelligent-Tiering** as code (transition or expire objects automatically) — see the lab.
- **Auto-tagging remediation** via an EventBridge rule on resource creation, or AWS Config rules with remediation.

Talking point:

```text
For an advanced week, 'open a cleanup ticket' is a weak ending. The senior answer is: tag it, schedule it, and let the scheduler do it every night forever.
```

Warning:

```text
Savings Plans can reduce cost, but they do not fix waste — and they do not cover RDS/ElastiCache/Redshift/OpenSearch (use RIs for those). Always clean up and rightsize BEFORE committing, or you will lock in your own waste for a year.
```

### Monthly Cloud Operations Reporting

A monthly cloud operations report turns technical findings into business communication.

Good reports include:

- Executive summary
- Month-over-month cost trend
- Top cost drivers
- Tag compliance
- Idle resource candidates
- Rightsizing candidates
- Budget status
- Risks and exceptions
- Recommended actions
- Owners and due dates

Talking point:

```text
The report is not only for finance. It is a working document for engineering accountability.
```

### Common Misconceptions

| Misconception | Correction |
|---|---|
| Compute Optimizer recommendations should always be applied | Recommendations need human review and workload context |
| Idle means safe to delete | Ownership and retention must be confirmed |
| Savings Plans are always good | They are good only when usage is predictable |
| Cost reports are finance documents | They are operational documents for engineering decisions |
| Non-prod does not need governance | Non-prod often needs stronger cleanup rules |
| Reducing logs is always safe | Logs may be required for incident response, audit, or security |

---

## 12. Whiteboard Explanation

### Simple Diagram: Class 1 to Class 2 Flow

```text
Class 1: Cost Visibility
------------------------
Cost Explorer
Budgets
Tags
Cost Drivers
Ownership Gaps
      |
      v
Class 2: Optimization Actions
-----------------------------
Rightsize
Cleanup
Retention Policy
Reserved Capacity
Architecture Review
Monthly Ops Report
      |
      v
Operational Outcome
-------------------
Lower Waste
Clear Owners
Safer Decisions
Action Tracker
Leadership Reporting
```

### Cost Optimization Workflow

```text
1. Detect
   |
   v
Cost Explorer, Budgets, Cost Reports

2. Investigate
   |
   v
Service, Account, Region, Tag, Usage Type

3. Classify
   |
   v
Expected Growth vs Waste vs Misconfiguration

4. Recommend
   |
   v
Rightsize, Cleanup, Schedule, Commit, Redesign

5. Approve
   |
   v
Application Owner, Cloud Team, Finance, Security

6. Implement
   |
   v
Terraform, Console, CLI, Automation

7. Validate
   |
   v
Cost Trend, Performance, Reliability, Audit
```

### What Each Component Means

| Step | Meaning |
|---|---|
| Detect | Find that something changed |
| Investigate | Identify where and why the change happened |
| Classify | Decide whether it is expected, waste, or misconfiguration |
| Recommend | Propose a practical action |
| Approve | Confirm owner and risk |
| Implement | Make the change safely |
| Validate | Confirm cost improved and service still works |

### Enterprise Version

```text
Finance
  |
  v
Monthly Cost Review Request
  |
  v
Cloud Platform Team
  |
  +--> Cost Explorer Review
  +--> Tag Compliance Report
  +--> Idle Resource Report
  +--> Rightsizing Candidates
  +--> Budget Status
  |
  v
Application Owner Review
  |
  v
Approved Actions
  |
  +--> Terraform Change
  +--> Cleanup Ticket
  +--> Retention Update
  +--> Savings Plan Review
  |
  v
Monthly Cloud Operations Report
  |
  v
Leadership, Finance, Engineering Teams
```

### How This Extends Class 1

Class 1 answered:

```text
Where is the cost coming from?
```

Class 2 answers:

```text
What should we safely do about it, who owns the action, and how do we report it?
```

---

## 13. Instructor Demo Script

### Demo Title

**From Cost Finding to Optimization Recommendation**

### Demo Objective

Show students how to interpret cost and utilization findings, then convert them into safe optimization recommendations and report entries.

### Required Setup

Preferred:

- AWS account with:
  - Cost Explorer enabled
  - Compute Optimizer enabled
  - Trusted Advisor access
  - Billing read-only access
  - Read-only resource access

Safe classroom alternative:

- Screenshots of AWS Cost Explorer, Compute Optimizer, and Trusted Advisor
- Sample CSV files
- Mock AWS CLI outputs

### Demo Part 1: Confirm AWS Identity

Command:

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

Explain:

```text
Before investigating cloud resources, always confirm which account and identity you are using.
```

### Demo Part 2: Review Service Cost Increase

Command, if Cost Explorer permissions are available:

```bash
aws ce get-cost-and-usage   --time-period Start=2026-04-01,End=2026-04-26   --granularity MONTHLY   --metrics "UnblendedCost"   --group-by Type=DIMENSION,Key=SERVICE
```

Expected output shape:

```json
{
  "ResultsByTime": [
    {
      "Groups": [
        {
          "Keys": ["Amazon Virtual Private Cloud"],
          "Metrics": {
            "UnblendedCost": {
              "Amount": "3100.00",
              "Unit": "USD"
            }
          }
        },
        {
          "Keys": ["AmazonCloudWatch"],
          "Metrics": {
            "UnblendedCost": {
              "Amount": "1800.00",
              "Unit": "USD"
            }
          }
        }
      ]
    }
  ]
}
```

Explain:

```text
This tells us the cost category. It does not yet tell us whether the cost is valid, waste, or misconfiguration.
```

### Demo Part 3: Show Compute Optimizer

Console path:

```text
AWS Console → Compute Optimizer → EC2 instances
```

Show or describe columns:

```text
Instance ID
Finding
Current instance type
Recommended instance type
Estimated monthly savings
CPU utilization
Memory utilization, if available
```

Example recommendation:

```text
Instance: i-0123456789abcdef0
Finding: Over-provisioned
Current type: m5.2xlarge
Recommended type: m5.large
Estimated monthly savings: $180
Risk: Review memory and production traffic before applying
```

Explain:

```text
Compute Optimizer is a recommendation tool, not an automatic approval system.
```

Critical real-world caveat (teach this — it trips up juniors):

```text
By default Compute Optimizer only sees CPU, network, and disk from the standard EC2 metrics.
It does NOT see memory unless the CloudWatch agent is installed and publishing the memory
metric. Without memory data, a "downsize" recommendation can be dangerous — the instance
may be memory-bound, not CPU-bound. Always confirm whether memory metrics are present before
trusting a rightsizing recommendation. Compute Optimizer also needs ~14 days of metrics to
produce findings, and can use up to 3 months of history (enhanced lookback) for better accuracy.
```

Also note the Graviton angle:

```text
Compute Optimizer can surface Graviton (ARM) instance recommendations alongside same-arch
ones. If the workload runs on ARM, that is often the largest single rightsizing saving.
```

### Demo Part 4: Show Trusted Advisor

Console path:

```text
AWS Console → Trusted Advisor → Cost Optimization
```

Example checks:

```text
Low utilization EC2 instances
Idle load balancers
Underutilized EBS volumes
Unassociated Elastic IP addresses
Amazon RDS idle DB instances
```

Important note:

```text
Trusted Advisor checks vary by support plan. If the account does not show all checks, use sample screenshots or exported data.
```

### Demo Part 5: Review Idle Resource Report

Show sample data:

```csv
ResourceId,ResourceType,Environment,Owner,MonthlyCostUSD,LastUsed,Recommendation,Risk
vol-aaa111,EBS Volume,dev,unknown,85,Unknown,Confirm and delete if unused,Possible data retention requirement
alb-bbb222,ALB,test,app-team-c,120,No traffic in 21 days,Confirm and remove,May still be used for testing
snap-ccc333,EBS Snapshot,dev,unknown,45,Created 180 days ago,Apply retention policy,May be needed for rollback
```

Explain:

```text
Idle resources should become action items, not random deletions.
```

### Demo Part 6: Build One Optimization Recommendation

Use this format:

```text
Finding:
Non-prod NAT Gateway cost increased by 65% month over month.

Evidence:
Cost Explorer shows increased NAT Gateway data processing in us-east-1.

Likely Cause:
Private subnet workloads may be pulling artifacts or updates through NAT Gateway.

Recommendation:
Review traffic source. Add VPC endpoints for S3 and ECR if private workloads use those services frequently.

Risk:
Changing egress paths without testing may break private workload access.

Owner:
Cloud Platform and application team.

Priority:
High.

Validation:
Review NAT Gateway cost trend after change.
```

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Cost Explorer CLI denied | Missing `ce:GetCostAndUsage` permission | Use screenshots or sample JSON |
| Compute Optimizer has no data | Not enabled or not enough metrics | Use sample recommendation file |
| Trusted Advisor checks missing | Support plan limitation | Explain limitation and use sample checks |
| Tags missing from reports | Cost allocation tags not active | Explain activation and use sample CSV |
| Students want to apply recommendations immediately | Misunderstanding of risk | Reinforce approval and validation process |

### Cleanup Steps

If no AWS resources are created, no AWS cleanup is required.

If local demo files were created:

```bash
rm -rf week18-class2-demo
```

If a demo budget or report was created in AWS, remove it after class only if it is not needed:

```text
AWS Console → Billing and Cost Management → Budgets → Select demo budget → Delete
```

---

## 14. Student Lab Manual

### Lab Title

**Create a Monthly Cloud Operations Report**

### Lab Objective

Students will create a practical monthly cloud operations report using sample cost, utilization, and idle resource data.

### Estimated Time

40 minutes

### Student Prerequisites

Students should understand:

- Class 1 cost visibility concepts
- Required tags
- Budget thresholds
- Common AWS cost drivers
- Difference between expected growth and waste

### Starting Point From Class 1

Students should reuse:

- Top cost drivers from Class 1
- Missing tag findings from Class 1
- Budget recommendation from Class 1
- Cost analysis report draft from Class 1

### Architecture or Workflow Overview

```text
Class 1 Cost Findings
       |
       v
Class 2 Utilization and Idle Resource Data
       |
       v
Classify Findings
Expected Growth / Waste / Misconfiguration / Needs Review
       |
       v
Create Recommendations
Rightsize / Cleanup / Retention / Commitment / Architecture Review
       |
       v
Monthly Cloud Operations Report
       |
       v
Action Tracker for Owners
```

### Files Provided

```text
week18-class2/
├── sample-resource-utilization.csv
├── sample-idle-resource-report.csv
├── sample-monthly-cloud-ops-report-template.md
├── sample-finance-update-template.md
└── optimization-action-tracker.csv
```

### Sample File 1: `sample-resource-utilization.csv`

```csv
ResourceId,ResourceType,Environment,Owner,Application,CurrentSize,AvgCPUPercent,AvgMemoryPercent,MonthlyCostUSD,Recommendation
i-001,EC2,prod,app-team-a,orders-api,m5.2xlarge,18,42,280,Review rightsizing to m5.xlarge
i-002,EC2,dev,unknown,unknown,t3.large,2,8,75,Stop or schedule if not needed
i-003,EC2,test,app-team-c,inventory-ui,t3.medium,5,12,38,Schedule outside business hours
db-001,RDS,prod,app-team-a,orders-db,db.m5.large,35,60,520,Keep current size
log-001,CloudWatch Logs,nonprod,app-team-b,claims-api,NA,NA,NA,1800,Reduce retention and review debug logging
nat-001,NAT Gateway,nonprod,unknown,unknown,NA,NA,NA,3100,Analyze traffic and consider VPC endpoints
```

### Sample File 2: `sample-idle-resource-report.csv`

```csv
ResourceId,ResourceType,Environment,Owner,MonthlyCostUSD,LastUsed,TagStatus,RecommendedAction,Risk
vol-aaa111,EBS Volume,dev,unknown,85,Unknown,Missing,Confirm owner and delete if unused,Possible data retention requirement
vol-bbb222,EBS Volume,test,app-team-c,60,45 days ago,Partial,Snapshot then delete if approved,May be needed for rollback
alb-ccc333,Load Balancer,test,app-team-c,120,No traffic in 21 days,Partial,Confirm and remove if unused,May still support testing
snap-ddd444,Snapshot,dev,unknown,45,Created 180 days ago,Missing,Apply retention policy,May be needed for audit or recovery
eip-eee555,Elastic IP,dev,unknown,15,Unassociated,Missing,Release if not needed,Could be reserved for external allowlist
```

### Step-by-Step Student Instructions

#### Step 1: Create a Working Folder

```bash
mkdir -p week18-class2-lab
cd week18-class2-lab
```

Expected result:

```text
You are now inside the week18-class2-lab folder.
```

#### Step 2: Open the Provided Files

Open these files in VS Code or a spreadsheet tool:

```text
sample-resource-utilization.csv
sample-idle-resource-report.csv
sample-monthly-cloud-ops-report-template.md
optimization-action-tracker.csv
```

#### Step 3: Identify Rightsizing Candidates

From `sample-resource-utilization.csv`, identify resources with:

```text
AvgCPUPercent below 20%
AvgMemoryPercent below 50%
Non-prod environment
High monthly cost
```

Expected findings:

```text
i-001: Possible rightsizing candidate, but production. Needs careful review.
i-002: Strong stop/schedule candidate because dev, unknown owner, very low utilization.
i-003: Schedule candidate because test workload has low utilization.
```

#### Step 4: Identify Idle Cleanup Candidates

From `sample-idle-resource-report.csv`, list resources that may be cleaned up.

Expected findings:

```text
vol-aaa111: Missing owner, possible delete after validation
vol-bbb222: Snapshot then delete if approved
alb-ccc333: Remove if no longer needed
snap-ddd444: Apply retention policy
eip-eee555: Release if not needed
```

#### Step 5: Classify Each Finding

Use this classification:

```text
Expected growth
Waste
Misconfiguration
Needs owner validation
Architecture review
```

Example:

```text
NAT Gateway increase: Architecture review
Unattached EBS volume: Needs owner validation
Idle ALB: Waste, pending owner confirmation
Production RDS cost: Expected cost
CloudWatch Logs spike: Misconfiguration or logging policy issue
```

#### Step 6: Create Optimization Recommendations

Each recommendation must include:

```text
Finding
Evidence
Recommended action
Risk
Owner
Priority
Validation method
```

Example:

```markdown
## Recommendation 1: Reduce Non-Prod CloudWatch Log Cost

Finding:
CloudWatch Logs cost increased from $400 to $1,800 for claims-api non-prod.

Evidence:
Sample cost data shows large increase after debug logging was enabled.

Recommended Action:
Review log level and reduce non-prod retention to 14 days unless longer retention is required.

Risk:
Reducing retention may limit troubleshooting history.

Owner:
app-team-b and cloud platform.

Priority:
High.

Validation:
Review CloudWatch Logs cost next billing cycle.
```

#### Step 7: Build the Monthly Cloud Operations Report

Use this structure:

```markdown
# Monthly Cloud Operations Report

## 1. Executive Summary

## 2. Monthly Spend Overview

## 3. Top Cost Drivers

## 4. Month-over-Month Changes

## 5. Tagging Compliance

## 6. Idle Resource Findings

## 7. Rightsizing Candidates

## 8. Budget Status

## 9. Risks and Exceptions

## 10. Recommended Actions

## 11. Owners and Next Steps
```

#### Step 8: Fill the Action Tracker

Use this format:

```csv
ActionId,Finding,RecommendedAction,Owner,Priority,Risk,DueDate,Status
A1,NAT Gateway spike,Analyze traffic and evaluate VPC endpoints,Cloud Platform,High,May affect private subnet egress,Next 2 weeks,Open
A2,CloudWatch Logs spike,Review debug logging and retention,app-team-b,High,May affect troubleshooting history,This week,Open
A3,Idle ALB,Confirm if still needed and remove,app-team-c,Medium,May affect test users,This week,Open
A4,Unattached EBS,Confirm ownership and delete if safe,Unknown,Medium,Possible data retention issue,Next 2 weeks,Open
```

#### Step 9: Draft a Short Finance Update

Use this template:

```text
The monthly cloud cost increase appears to be driven mainly by non-prod NAT Gateway traffic, increased CloudWatch Logs usage, idle load balancers, and storage cleanup gaps. We are separating valid production spend from avoidable waste. Immediate actions include owner validation, non-prod log retention review, idle resource cleanup, and a NAT Gateway traffic review. We will provide an updated status after owners confirm cleanup actions.
```

#### Step 10: Validate Your Work

### Validation Checklist

- [ ] Report includes executive summary
- [ ] Top cost drivers are listed
- [ ] Rightsizing candidates are identified
- [ ] Idle resources are identified
- [ ] Each recommendation has risk documented
- [ ] Owners are assigned where known
- [ ] Unknown owners are clearly marked
- [ ] Budget status is included
- [ ] Action tracker is filled out
- [ ] Finance update is written in plain English

### Troubleshooting Tips

| Problem | Fix |
|---|---|
| Not sure if a resource is waste | Mark it as “Needs owner validation” |
| Not sure whether to rightsize production | Recommend review and testing, not immediate change |
| Missing owner | Mark as governance gap and recommend tag enforcement |
| Cost is high but production-critical | Document as exception or expected spend |
| Unsure how to prioritize | Prioritize high cost, non-prod, missing owner, and fast cleanup candidates |

### Cleanup Steps

No AWS resources are created in this lab.

Optional local cleanup:

```bash
cd ..
rm -rf week18-class2-lab
```

Recommended:

Keep the report and action tracker for portfolio use.

### Reflection Questions

1. Which recommendation creates the fastest safe savings?
2. Which recommendation has the highest operational risk?
3. Which finding requires an application owner before action?
4. Which issue should become an automation opportunity?
5. How would you explain the findings to a non-technical finance partner?

### Optional Challenge Task

Pick one or more of the following — each turns a manual finding into automation or a concrete commitment decision.

**A. Tagging requirement (governance):**

```hcl
variable "tags" {
  type = map(string)

  validation {
    condition = alltrue([
      contains(keys(var.tags), "Application"),
      contains(keys(var.tags), "Environment"),
      contains(keys(var.tags), "Owner"),
      contains(keys(var.tags), "CostCenter"),
      contains(keys(var.tags), "ManagedBy")
    ])
    error_message = "Tags must include Application, Environment, Owner, CostCenter, and ManagedBy."
  }
}
```

**B. S3 lifecycle policy as code (replace "review storage" with automation):**

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "reports" {
  bucket = aws_s3_bucket.reports.id

  rule {
    id     = "tier-and-expire-non-prod-logs"
    status = "Enabled"
    filter { prefix = "logs/" }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration { days = 365 }
  }
}
```

**C. Write a one-paragraph commitment recommendation** using the Cost Explorer Savings Plans recommendation page concept. State: chosen instrument (Compute SP vs EC2 SP vs RI), term (1yr vs 3yr) and payment option, target coverage %, why you are NOT covering 100%, and the laddering plan. Note explicitly which spend an SP does not cover (RDS/ElastiCache/Redshift) and how you'll cover it.

**D. gp2 → gp3 quick win:** write the `describe-volumes` + `modify-volume` commands (see lecture notes) and a one-line risk note about checking IOPS needs on large volumes first.

**E. Kubernetes rightsizing note:** if the workload is on EKS, describe how you would right-size at the cluster level — tune pod `requests`/`limits` (over-set requests waste reserved capacity), let the Cluster Autoscaler/Karpenter consolidate nodes, and use a VPA in recommendation mode to size requests from real usage. Note that OpenCost/Kubecost (introduced in Class 1) provides the per-namespace cost to target.

---

## 15. Troubleshooting Activity

### Incident Title

**Unexpected AWS Bill Increase After Non-Prod Testing**

### Business Impact

Finance reports that monthly AWS spend exceeded forecast by $9,000. Engineering leadership wants a clear explanation, immediate containment actions, and a prevention plan.

### Symptoms

```text
Monthly AWS bill increased from $18,000 to $27,000.

Largest increases:
- NAT Gateway
- EBS
- CloudWatch Logs
- Elastic Load Balancing
- Snapshots

Other issues:
- Several resources are missing Owner and Environment tags
- Test environment was created three weeks ago
- No cleanup ticket was completed after testing
```

### Starting Evidence

```text
Cost changes:
- NAT Gateway: $900 to $3,100
- CloudWatch Logs: $400 to $1,800
- EBS: $200 to $950
- Snapshots: $100 to $700
- Load Balancing: $150 to $750

Resource findings:
- 2 load balancers with no traffic for 21 days
- 5 unattached EBS volumes
- 12 old snapshots older than 180 days
- Debug logging enabled in non-prod
- NAT Gateway data processing increased after test environment launch
```

### Student Investigation Steps

Students should:

1. Identify the largest cost increases in dollar value.
2. Determine which increases are tied to non-prod.
3. Identify which resources are missing owner tags.
4. Separate likely waste from expected production cost.
5. Identify actions that require owner approval.
6. Identify actions that require architecture review.
7. Write a short explanation for finance.
8. Create preventive action items.

### Expected Root Cause

The cost increase was caused by multiple operational gaps:

```text
1. Non-prod test resources remained active after testing.
2. NAT Gateway traffic increased from private subnet workloads.
3. CloudWatch debug logs generated high ingestion cost.
4. EBS volumes and snapshots were not cleaned up.
5. Idle load balancers continued running.
6. Missing tags made ownership unclear.
7. No monthly cleanup process or action tracker existed.
```

### Correct Resolution

Immediate actions:

```text
1. Confirm ownership of test environment.
2. Disable or reduce debug logging where safe.
3. Review CloudWatch log retention for non-prod.
4. Identify and remove idle load balancers after owner approval.
5. Snapshot and delete unattached EBS volumes if safe.
6. Apply snapshot retention policy.
7. Review NAT Gateway traffic sources.
8. Create budget alerts for non-prod.
```

Longer-term actions:

```text
1. Enforce required tags through Terraform or CI/CD checks.
2. Create monthly cloud operations report.
3. Create idle resource cleanup process.
4. Add owner review for non-prod environments.
5. Evaluate VPC endpoints for S3 and ECR traffic.
6. Create action tracker with owners and due dates.
```

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Delete all non-prod resources immediately | Could break active testing or shared services |
| Downsize production without testing | Could cause performance issues |
| Buy Savings Plans before cleanup | Commits spend before removing waste |
| Ignore missing tags | Ownership problem will happen again |
| Reduce all log retention to 1 day | May harm troubleshooting and security investigations |
| Blame only NAT Gateway | The issue has multiple cost drivers |
| Send finance raw technical data only | Finance needs a clear explanation and action plan |

### Instructor Hints

If students are stuck, ask:

1. “Which costs increased the most in dollars?”
2. “Which findings are non-prod?”
3. “Which actions can be taken quickly but safely?”
4. “Which actions need owner approval?”
5. “Which actions prevent recurrence?”
6. “Would this recommendation create reliability or security risk?”

### Preventive Action

The best prevention plan includes:

```text
Required tags
Budget alerts
Monthly cloud operations report
Idle resource cleanup review
Owner validation workflow
Terraform or pipeline tag enforcement
Non-prod retention standards
Action tracker with due dates
```

### Second Scenario (Structurally Different): Production Data-Transfer / Autoscaling Surprise

The non-prod cleanup scenario above is the common case. A senior also has to handle a **production** cost surprise where deletion is NOT the answer — the spend is real, tied to traffic, and the fix is architectural. Use this to broaden the pattern library.

**Symptoms (evidence-first):**

```text
Cost Anomaly Detection paged overnight: "EC2-Other / Data Transfer up 220% vs baseline."
No non-prod test was launched. Production traffic is healthy and customer-facing.
Cost per 1,000 requests (unit cost) ROSE 40% — so this is NOT efficient growth.
```

**Starting evidence:**

```text
- CUR (Athena) shows the spike is in inter-AZ data transfer (usage type *-DataTransfer-Regional-Bytes),
  not internet egress.
- A new microservice was deployed last week; its pods/instances are spread across 3 AZs and
  chat constantly with a database whose primary is in a single AZ.
- A Kubernetes HPA scaled the new service from 6 to 40 pods under load, multiplying cross-AZ chatter.
```

**Expected root cause:**

```text
Cross-AZ ("regional") data transfer is billed in BOTH directions (~$0.01/GB each way). A chatty
new service spread across AZs talking to a single-AZ datastore generated large cross-AZ volume,
amplified by autoscaling. The cost is real and load-driven — the architecture, not waste, is the issue.
```

**Correct resolution (architecture, not deletion):**

```text
1. Use topology-aware routing / same-AZ read replicas so callers prefer an in-AZ endpoint.
2. Add caching to cut chatty round-trips.
3. Consider VPC endpoints / gateway endpoints where the chatter is to AWS services.
4. Set the HPA/scaling so it does not over-fan-out across AZs unnecessarily.
5. Keep multi-AZ for resilience — do NOT collapse to one AZ to save transfer; that trades cost for an outage risk.
```

**Why this scenario matters:** it teaches that (a) anomaly detection, not month-end, surfaced it; (b) unit economics confirmed it was waste, not growth; (c) CUR/Athena located the exact usage type; and (d) the senior fix is architectural, with reliability explicitly protected. "Delete the expensive thing" would have been exactly wrong.

---

## 16. Scenario-Based Discussion Questions

### Question 1

**Should a cloud team apply every Compute Optimizer recommendation?**

Expected response themes:

- No, recommendations need context.
- Production workloads require testing.
- Memory, network, and business traffic patterns matter.
- App owners should approve risky changes.

Follow-up:

```text
What data would you request before rightsizing a production EC2 instance?
```

### Question 2

**Is an expensive production database automatically a cost problem?**

Expected response themes:

- Not necessarily.
- It may support critical business traffic.
- Cost must be compared with business value and performance needs.
- Optimization may still be possible, but carefully.

Follow-up:

```text
How would you document this as an exception?
```

### Question 3

**Why might buying Savings Plans too early be a mistake?**

Expected response themes:

- Commits spend before usage is understood.
- Waste may still exist.
- Architecture may change.
- Workloads may be temporary.

Follow-up:

```text
What should be done before making a commitment-based purchase?
```

### Question 4

**What is the safest way to handle unattached EBS volumes?**

Expected response themes:

- Confirm owner.
- Confirm retention requirement.
- Snapshot if needed.
- Delete only after approval.
- Track action.

Follow-up:

```text
What could go wrong if you delete first and ask later?
```

### Question 5

**How should teams balance log cost and troubleshooting needs?**

Expected response themes:

- Production may need longer retention.
- Non-prod can often have shorter retention.
- Security logs may require compliance retention.
- Structured logs can reduce noise.

Follow-up:

```text
Who should approve log retention changes?
```

### Question 6

**What makes a monthly cloud operations report useful to leadership?**

Expected response themes:

- Clear summary
- Cost trend
- Business impact
- Owners
- Recommended actions
- Risks
- Progress since last month

Follow-up:

```text
What should be excluded from an executive summary?
```

### Question 7

**How can DevOps pipelines help prevent future cost problems?**

Expected response themes:

- Enforce tags
- Validate Terraform modules
- Require cost center input
- Run policy checks
- Create cleanup metadata for temporary environments

Follow-up:

```text
What tag checks would you add to a Terraform pipeline?
```

### Question 8

**When is spending more the correct engineering decision?**

Expected response themes:

- High availability
- Security logging
- Disaster recovery
- Performance under peak load
- Compliance requirements

Follow-up:

```text
How would you explain that to finance?
```

---

## 17. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

Which AWS service provides rightsizing recommendations for EC2 and other compute resources?

A. AWS Cost Explorer  
B. AWS Compute Optimizer  
C. AWS CloudTrail  
D. AWS Route 53  

**Answer:** B  
**Explanation:** AWS Compute Optimizer provides recommendations based on utilization patterns.

### Question 2: True or False

An idle resource should always be deleted immediately.

**Answer:** False  
**Explanation:** Ownership, data retention, and business impact should be validated before deletion.

### Question 3: Short Answer

Name three examples of common idle or waste resources in AWS.

**Answer:** Unattached EBS volumes, idle load balancers, old snapshots, unused Elastic IPs, unused EC2 instances, and unused log groups are valid examples.  
**Explanation:** These resources can continue to create cost even when not actively used.

### Question 4: Multiple Choice

Which finding is the best candidate for a cleanup review?

A. Production RDS database with steady traffic  
B. Test ALB with no traffic for 21 days  
C. Production app with increased customer usage  
D. Security log archive required by policy  

**Answer:** B  
**Explanation:** A test load balancer with no traffic is likely idle, but still needs owner confirmation.

### Question 5: Short Answer

How does Class 2 build on Class 1?

**Answer:** Class 1 identifies cost drivers and ownership gaps. Class 2 turns those findings into optimization actions, reports, and action trackers.  
**Explanation:** Visibility comes first, action comes second.

### Question 6: Multiple Choice

Which is the safest first step before rightsizing a production EC2 instance?

A. Resize it immediately  
B. Delete it  
C. Review utilization, performance risk, owner approval, and testing plan  
D. Ignore it forever  

**Answer:** C  
**Explanation:** Production rightsizing should be reviewed carefully to avoid performance or reliability problems.

### Question 7: Troubleshooting Question

A non-prod CloudWatch Logs cost increased from $400 to $1,800 after debug logging was enabled. What actions should you recommend?

**Answer:** Review log volume, reduce debug logging if no longer needed, set appropriate non-prod retention, confirm owner approval, and validate cost trend after changes.  
**Explanation:** The issue may be caused by excessive ingestion and retention.

### Question 8: AWS-Related Multiple Choice

Which AWS service can show checks such as low utilization EC2 instances or idle load balancers, depending on support plan?

A. Trusted Advisor  
B. Route 53  
C. IAM Identity Center  
D. CloudFormation  

**Answer:** A  
**Explanation:** Trusted Advisor provides best-practice checks, including cost optimization checks.

### Question 9: True or False

Savings Plans should usually be evaluated after understanding baseline usage.

**Answer:** True  
**Explanation:** Commitment discounts work best when usage is predictable.

### Question 10: Class 1 and Class 2 Connection Question

Why are tags important when creating a monthly cloud operations report?

**Answer:** Tags help group cost by owner, application, environment, and cost center, making the report actionable.  
**Explanation:** Without tags, reports show cost but not accountability.

### Question 11: Troubleshooting Question

An AWS bill increased after a test environment was created. What evidence would help determine if the test environment caused the increase?

**Answer:** Environment tags, creation dates, Cost Explorer filters, service-level increases, usage type, owner tags, and resource activity such as ALB traffic or NAT data processing.  
**Explanation:** These data points connect the cost increase to a workload or environment.

### Question 12: Short Answer

What should every optimization recommendation include?

**Answer:** Finding, evidence, recommended action, risk, owner, priority, and validation method.  
**Explanation:** This makes recommendations actionable and safe.

### Question 13: Multiple Choice

Which commitment instrument applies across EC2, Fargate, and Lambda regardless of instance family or Region?

A. Standard Reserved Instance  
B. EC2 Instance Savings Plan  
C. Compute Savings Plan  
D. Spot Instance  

**Answer:** C  
**Explanation:** A Compute Savings Plan is the most flexible commitment; an EC2 Instance SP is locked to one family/Region, and an RI is family-specific.

### Question 14: Short Answer

Define commitment *coverage* and *utilization*, and give a healthy target for each.

**Answer:** Coverage is the share of eligible usage covered by a commitment (target ~70–85%, covering the durable baseline). Utilization is the share of the purchased commitment actually used (target ~100%, since unused commitment is wasted).  
**Explanation:** Low coverage leaves discount unclaimed; sub-100% utilization means you over-committed.

### Question 15: True or False

A Compute Savings Plan will discount your Amazon RDS spend.

**Answer:** False  
**Explanation:** Savings Plans cover EC2, Fargate, and Lambda. RDS, ElastiCache, Redshift, and OpenSearch require their own Reserved Instances/Nodes.

### Question 16: Troubleshooting Question

Compute Optimizer recommends downsizing an EC2 instance from r6i.xlarge to r6i.large based on low CPU. What must you verify before applying it?

**Answer:** Whether memory metrics are present (the CloudWatch agent must publish them); the instance may be memory-bound, not CPU-bound. Also confirm it is not a failover/seasonal/production-headroom case and test before applying.  
**Explanation:** Compute Optimizer does not see memory by default, so a CPU-only "downsize" can cause an outage.

### Question 17: Multiple Choice

Which is the lowest-risk, fastest cost win among these?

A. Move a production database to Spot  
B. Migrate gp2 EBS volumes to gp3 (online, after checking IOPS needs)  
C. Buy a 3-year All-upfront Savings Plan immediately  
D. Delete all snapshots older than 30 days  

**Answer:** B  
**Explanation:** gp2→gp3 is an online modify-volume with ~20% savings and minimal risk; Spot on a database, blind commitments, and blanket snapshot deletion are all risky.

---

## 18. Homework Assignment

### Assignment Title

**Create a Monthly Cloud Operations Report Template**

### Scenario

Your cloud platform team has been asked to provide a monthly cloud operations report to finance, leadership, and application teams. The report must summarize cloud spend, top cost drivers, tagging compliance, idle resources, rightsizing candidates, risks, and action items.

### Student Tasks

Create a reusable monthly cloud operations report template.

The report must include:

1. Executive summary
2. Monthly spend overview
3. Month-over-month cost trend
4. Top 5 cost drivers
5. Top 5 cost increases
6. Environment-level cost breakdown
7. Tagging compliance section
8. Budget status section
9. Idle resource findings
10. Rightsizing recommendations
11. Risk and exception section
12. Action item tracker
13. Azure and GCP comparison notes
14. Plain-English finance update section

### Expected Deliverables

Students submit:

```text
monthly-cloud-operations-report-template.md
```

Optional supporting file:

```text
optimization-action-tracker.csv
```

### Submission Format

```text
Name:
Week:
Class:
Assignment title:
Files submitted:
Short summary:
```

### Estimated Completion Time

90 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Executive summary is clear and business-friendly | 15 |
| Cost drivers and increases are well organized | 15 |
| Tagging compliance section is practical | 10 |
| Budget status section is included | 10 |
| Idle resource and rightsizing sections are useful | 15 |
| Risks and exceptions are documented | 10 |
| Action tracker includes owners and priorities | 15 |
| Azure/GCP notes are concise and relevant | 5 |
| Overall professionalism and clarity | 5 |
| Total | 100 |

### Optional Advanced Challenge

Add a sample automation idea for generating part of the report.

Example AWS CLI command to list EC2 instances with tags:

```bash
aws ec2 describe-instances   --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,InstanceType:InstanceType,Tags:Tags}"   --output table
```

Expected output shape:

```text
---------------------------------------------------------
|                   DescribeInstances                   |
+----------------------+----------+--------------+------+
| InstanceId           | State    | InstanceType | Tags |
+----------------------+----------+--------------+------+
| i-001example         | running  | t3.large     | ...  |
+----------------------+----------+--------------+------+
```

---

## 19. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Applying recommendations without validation | Students trust tools too much | Require owner review, risk statement, and testing plan |
| Treating all high-cost resources as waste | Students focus only on dollar amount | Compare cost with business value and environment |
| Buying commitment discounts before cleanup | Students think discounts solve cost problems | Clean waste first, then evaluate steady usage |
| Ignoring non-prod scheduling | Students focus on production | Teach that non-prod should often run only when needed |
| Forgetting log retention impact | Logs feel invisible | Review ingestion and retention separately |
| Not assigning owners | Students produce findings but no accountability | Every action must have owner or “unknown owner” finding |
| Writing reports too technically | Students write for engineers only | Include executive summary and plain-English explanation |
| Omitting risk | Students focus on savings only | Require risk statement for each recommendation |
| Confusing rightsizing with downsizing | Students assume smaller is always better | Teach performance, reliability, and business context |
| Not validating after changes | Students stop after recommendation | Require post-action validation method |

---

## 20. Real-World Enterprise Scenario

### Scenario

A logistics company runs multiple AWS workloads across production, non-production, shared services, and data accounts. Finance notices that monthly cloud spend increased from $180,000 to $240,000 over three months.

The cloud platform team is asked to provide a monthly cloud operations report and action plan.

Findings include:

- NAT Gateway data processing increased in non-prod.
- Several test ALBs have no traffic.
- CloudWatch Logs cost increased after debug logging was enabled.
- EBS volumes remain after EC2 instances were deleted.
- Production RDS spend increased, but traffic also increased.
- Some resources are missing `Owner`, `Application`, and `CostCenter` tags.
- Engineering teams do not have a consistent cleanup process.

### Constraints

- Cloud platform cannot delete app-owned resources without approval.
- Production reliability cannot be reduced for short-term savings.
- Security requires some logs to be retained.
- Finance wants a simple monthly summary.
- Application teams want specific action items, not generic cost complaints.
- Leadership wants trend, risk, and accountability.

### What Each Role Would Do

#### Cloud Engineer

- Analyze Cost Explorer and utilization data.
- Identify idle and underutilized resources.
- Build monthly cloud operations report.
- Recommend VPC endpoints if NAT cost is caused by AWS service traffic.
- Create tagging and cleanup governance process.

#### DevOps Engineer

- Add tagging standards to Terraform modules.
- Add policy checks in CI/CD.
- Automate cleanup of temporary environments where safe.
- Add environment metadata to pipeline deployments.

#### SRE

- Review log retention and alerting impact.
- Ensure optimization does not reduce incident response capability.
- Validate performance after rightsizing.
- Help define operational risk and exceptions.

---

## 21. Instructor Tips

### Teaching Tips

- Keep reminding students that tools provide recommendations, not final decisions.
- Use practical language: finding, evidence, risk, owner, action.
- Connect every cost issue to an operational process.
- Do not let the class become a pricing lecture.
- Encourage students to write for non-technical stakeholders.

### Pacing Tips

- Keep Class 1 review under 15 minutes.
- Spend enough time on rightsizing vs downsizing.
- Keep reserved capacity overview practical and short.
- Protect 40 minutes for the report lab.
- Leave at least 10 minutes for discussion and week closure.

### Lab Support Tips

Students may need help with:

- Prioritizing findings
- Writing risk statements
- Assigning owners
- Separating waste from expected growth
- Writing executive summaries

Use this coaching prompt:

```text
What is the finding?
What evidence supports it?
Who owns it?
What action is safe?
What is the risk?
How will you validate the result?
```

### How to Help Struggling Students

Give them a smaller report:

1. Executive summary
2. Top 3 cost drivers
3. Top 3 action items
4. Risks
5. Owners

### How to Challenge Advanced Students

Ask them to add:

- Terraform tag validation
- AWS CLI inventory commands
- VPC endpoint recommendation for NAT cost
- Cost anomaly detection idea
- Automation workflow for non-prod cleanup
- Dashboard mockup for monthly operations reporting

---

## 22. Student Outcome Checklist

By the end of Class 2, students should be able to:

### Explain

- [ ] Difference between cost visibility and optimization
- [ ] Common AWS waste patterns
- [ ] Rightsizing vs downsizing
- [ ] When Reserved Instances or Savings Plans make sense
- [ ] Why cleanup requires owner approval
- [ ] Why monthly operations reporting matters

### Build or Configure

- [ ] Monthly cloud operations report template
- [ ] Optimization action tracker
- [ ] Rightsizing recommendation
- [ ] Idle cleanup recommendation
- [ ] Finance-friendly cost update
- [ ] Risk statement for each action

### Troubleshoot

- [ ] Unexpected AWS bill increase
- [ ] Non-prod cost spike
- [ ] Idle load balancer cost
- [ ] CloudWatch Logs cost increase
- [ ] Missing tag ownership problem
- [ ] NAT Gateway cost growth

---

## 23. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Class 1 review completed.
- [ ] Students understand optimization categories.
- [ ] Rightsizing and cleanup risks were explained.
- [ ] Compute Optimizer and Trusted Advisor were introduced.
- [ ] Student lab was completed or started.
- [ ] Troubleshooting activity was reviewed.
- [ ] Homework assignment was explained.
- [ ] End-of-week summary was completed.

### Student Checklist Before Leaving Class

- [ ] I can explain how Class 2 builds on Class 1.
- [ ] I can identify rightsizing and cleanup candidates.
- [ ] I can explain why owner approval matters.
- [ ] I can create a monthly cloud operations report.
- [ ] I can write a clear optimization recommendation.
- [ ] I can include risk and validation in my recommendations.
- [ ] I understand the homework assignment.

### Items to Verify Before Closing the Week

Students should have:

- A cost visibility understanding from Class 1
- A monthly cloud operations report draft from Class 2
- An action tracker with owners and priorities
- At least 3 optimization recommendations
- At least 1 finance-friendly summary
- Understanding of AWS, Azure, and GCP cost tooling parallels

---

## 24. End-of-Week Summary

### What Students Learned This Week

Students learned how cloud teams manage cloud cost as an operational responsibility.

They practiced:

- Identifying cloud cost drivers
- Understanding tagging and ownership
- Creating budget recommendations
- Investigating unexpected spend
- Identifying waste and rightsizing candidates
- Building monthly cloud operations reports
- Communicating cost findings clearly
- Balancing cost savings with security, reliability, and production safety

### How Class 1 and Class 2 Connect

Class 1 focused on visibility:

```text
What is driving the cost?
Who owns it?
Which tags are missing?
Which budget alerts are needed?
```

Class 2 focused on action:

```text
What should we do about it?
What is safe to clean up?
What requires approval?
What should be rightsized?
How do we report progress?
```

Together, both classes give students a practical cloud operations workflow:

```text
Detect cost issue
Investigate evidence
Identify ownership
Recommend action
Document risk
Assign owner
Track progress
Validate result
```

### How This Week Prepares Students for the Next Week

This week prepares students for capstone build work by teaching them how to include cloud operations maturity in their final project.

Students should now be able to add the following to a capstone:

- Cost visibility section
- Required tagging standard
- Budget alert strategy
- Idle resource cleanup process
- Monthly operations report
- Risk-aware optimization recommendations
- Azure/GCP comparison notes

### What Students Should Review Before the Next Module

Students should review:

1. AWS Cost Explorer concepts
2. AWS Budgets concepts
3. Required tagging standards
4. Common AWS cost drivers
5. Rightsizing vs downsizing
6. Idle resource cleanup process
7. NAT Gateway, CloudWatch Logs, EBS, snapshots, and load balancer cost patterns
8. How to write risk-aware recommendations
9. Monthly cloud operations report structure
10. How to explain cloud cost findings to non-technical stakeholders

---

## Class Artifacts & Validation

This class's rightsizing and monthly-reporting work is backed by the runnable
[`labs/python-automation/`](../../labs/python-automation/) module. Two artifacts map
directly to this class: `ec2_rightsize.py` (the peak-based `larger`/`keep`/`smaller`
rule that makes §11's "rightsizing requires context" point executable instead of just
discussed) and `cost_report.py` (group + total Cost Explorer rows by service — the
machine-checkable core of the Monthly Cloud Operations Report in §14). The pure logic is
unit-tested offline; the live CLI paths are read-only.

All commands below were run from `labs/python-automation/`. The `Result` column reflects
this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/python-automation/solution/ec2_rightsize.py | python | Pure `recommend`: peak-based rule (`>=` high → larger, both `<` low → smaller, else keep) — rightsizes on max, not average | `PYTHONPATH=solution python3 -m unittest tests.test_ec2_rightsize` | PASS — `Ran 14 tests ... OK` |
| 2 | labs/python-automation/solution/cost_report.py | python | Pure `summarize`: accumulate per-service totals across time buckets, sort desc, render table + grand total | `PYTHONPATH=solution python3 -m unittest tests.test_cost_report` | PASS — `Ran 13 tests ... OK` |
| 3 | labs/python-automation/starter/ec2_rightsize.py | python | Intentionally-incomplete student version (`recommend` is `TODO`) — the reproducible broken state for rightsizing | `python3 -m py_compile starter/ec2_rightsize.py` (syntax) | PASS (compiles; tests fail until TODO done — by design) |
| 4 | labs/python-automation/starter/cost_report.py | python | Intentionally-incomplete student version (`summarize` is `TODO`) — broken state for cost reporting | `python3 -m py_compile starter/cost_report.py` (syntax) | PASS (compiles; tests fail until TODO done — by design) |
| 5 | labs/python-automation/tests/test_ec2_rightsize.py | python (unittest) | Pins boundary cases (`>=` high inclusive, `<` low strict) and "peak not average" | `PYTHONPATH=solution python3 -m unittest tests.test_ec2_rightsize` | PASS — `Ran 14 tests ... OK` |
| 6 | labs/python-automation/tests/test_cost_report.py | python (unittest) | Pins "accumulate don't overwrite" (EC2 appears twice) and sort/round behavior | `PYTHONPATH=solution python3 -m unittest tests.test_cost_report` | PASS — `Ran 13 tests ... OK` |
| 7 | labs/python-automation/validate.sh | shell | Module gate runner: `py_compile` all `.py` + `unittest` solution (42 tests) + assert starter is incomplete | `./validate.sh` | PASS — `3 passed, 0 failed` |

Live `cost_report.py` / `ec2_rightsize.py` CLIs against a real account
(`pip install -r requirements.txt && PYTHONPATH=. python3 cost_report.py`) are
**DEFERRED** — they require AWS credentials with read-only `ce:GetCostAndUsage`,
`ec2:DescribeInstances`, and `cloudwatch:GetMetricStatistics` (and `GetCostAndUsage`
bills $0.01/request). No live-account evidence is captured in this repo; the offline
gates above are what is proven here.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — `ec2_rightsize.py` and `cost_report.py` (+ tests) are real `.py` files, not fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `unittest` PASS (`Ran 14`/`Ran 13`/`42` total `... OK`); live CLIs documented as DEFERRED.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `starter/ec2_rightsize.py` and `starter/cost_report.py` have TODO'd logic; `solution/` is the reference.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, cost notes — all present in `labs/python-automation/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — lab writes no cloud/local state beyond `__pycache__/`; live paths are read-only (nothing to destroy). Documented in the README Cleanup section.
- [x] **Instructor answer key** exists for the lab (README "Instructor answer key" — boundary, peak-not-average, accumulate-don't-overwrite), quiz (§17), homework (§18), and troubleshooting (§15).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `starter/` compiles but `ec2_rightsize`/`cost_report` tests fail with concrete assertions until the TODOs are done; class §15 adds two narrative incident scenarios.
- [x] **Expected outputs** are shown — README "Expected results" shows the `ec2_rightsize` and `cost_report` sample tables; class §14 shows the expected report.
- [x] **Cost & security warnings** present — README Security (read-only least-privilege IAM, no hard-coded creds) and Cost (Cost Explorer $0.01/request) sections; class §11/§13 cost-control framing.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — header links to `labs/python-automation/`; lab maps to Week 08 Class 02–03 and recurs in Week 21; class builds on Week 18 Class 1.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified by `ls`; all seven rows resolve.
- [ ] **Mastered (live/operated)** — NOT claimed: no real AWS apply/destroy or live operation evidence exists for this class; the lab is static-validated only.
