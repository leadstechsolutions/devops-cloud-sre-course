# Week 18, Class 1 Package
**Track:** Unified DevOps · Cloud · SRE Track
> **▶ Runnable lab for this class:** [`labs/python-automation/`](../../labs/python-automation/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1: Cloud Cost Visibility, Tagging, and Budgets

---

## 1. Class Overview

### Class Title

**Understanding Cloud Spend, Tags, Budgets, and Cost Visibility**

### Class Purpose

This class teaches students how cloud teams understand, track, and control AWS spending before it becomes a business problem. Students learn how cost visibility works, why tags matter, how budgets support early warning, and how cloud engineers explain cloud spend to finance, leadership, and application teams.

### How This Class Connects to the Overall Course

Earlier in the course, students learned AWS fundamentals, IAM, VPC, compute, storage, databases, Terraform, security, monitoring, and production operations. This class connects those technical skills to **cloud operations and financial accountability**.

Students now move from “how to build cloud resources” to “how to operate cloud resources responsibly.”

### What Students Will Build, Analyze, or Practice

Students will:

- Analyze sample AWS cost data.
- Identify top cost-driving services.
- Find missing or weak tagging.
- Recommend budget alert thresholds.
- Investigate a simulated AWS bill increase.
- Create a short cloud cost analysis report.
- Explain findings in business-friendly language.

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** why cloud cost visibility is part of cloud engineering and operations.
2. **Identify** common AWS cost drivers such as EC2, NAT Gateway, EBS, CloudWatch Logs, snapshots, and load balancers.
3. **Analyze** sample cloud cost data by service, environment, owner, and tag status.
4. **Compare** AWS Cost Explorer and AWS Budgets with similar Azure and GCP cost tools.
5. **Document** a practical tagging standard for cloud resources.
6. **Recommend** budget alert thresholds for non-production and production environments.
7. **Troubleshoot** an unexpected AWS bill increase using cost evidence.
8. **Communicate** cloud cost findings clearly to technical and non-technical stakeholders.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- AWS account basics
- AWS Regions and Availability Zones
- IAM users, roles, and permissions at a basic level
- EC2, EBS, S3, RDS, VPC, NAT Gateway, ALB, and CloudWatch basics
- Difference between dev, test, staging, and production
- Basic tagging concepts
- Basic spreadsheet analysis
- Basic CLI usage

### Required Tools Already Installed

Students should have:

- VS Code
- Terminal, PowerShell, or Git Bash
- AWS CLI
- Git, optional
- Spreadsheet tool such as Excel, Google Sheets, or LibreOffice Calc
- Browser access to AWS Console, if available

### Required Accounts or Access

Recommended:

- AWS account with billing read-only access
- Cost Explorer access, if available
- AWS Budgets access, if available

Safe classroom alternative:

- Use instructor-provided sample cost files instead of real AWS billing data.

### Files, Repos, or Sample Code Needed

Instructor should provide:

```text
week18-class1/
├── sample-aws-cost-report.csv
├── sample-untagged-resources.csv
├── cost-analysis-report-template.md
├── tagging-standard-template.md
└── budget-recommendation-template.md
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Cloud cost visibility | The ability to see where cloud money is being spent | Helps teams understand which services, apps, teams, or environments drive cost |
| Cost driver | A cloud service or usage pattern that contributes heavily to cost | NAT Gateway, EC2, EBS, RDS, CloudWatch Logs, and ALBs are common cost drivers |
| AWS Cost Explorer | AWS tool for analyzing cost and usage trends | Used by cloud teams to investigate spending by service, account, region, or tag |
| AWS Budgets | AWS tool for setting cost or usage thresholds and alerts | Helps teams receive early warnings before spend exceeds expectations |
| Tag | A key-value label added to a cloud resource | Used to identify owner, application, environment, and cost center |
| Required tag | A tag every resource must have | Common required tags include `Application`, `Owner`, `Environment`, and `CostCenter` |
| Actual spend | Cost already incurred | Shows how much has already been spent in the current period |
| Forecasted spend | Predicted future cost based on current usage trend | Useful for identifying likely budget overruns |
| Showback | Showing teams their cloud cost without directly billing them | Often used to create awareness and accountability |
| Chargeback | Billing teams or departments for their cloud usage | More formal financial accountability model |
| Untagged resource | A resource missing required ownership or cost metadata | Makes cost investigations slower and less reliable |
| Cost allocation tag | Tag activated for billing and cost reporting | Helps AWS cost tools group spend by business metadata |
| FinOps | The cultural and operational practice of bringing financial accountability to cloud spend | The recognized 2026 discipline; engineering, finance, and product share cost decisions |
| FinOps Framework | The FinOps Foundation model of phases (Inform → Optimize → Operate) and a maturity scale (Crawl → Walk → Run) | The common vocabulary cost-focused roles are expected to use |
| Unit economics | Cost expressed per unit of business value (per customer, per transaction, per tenant, per 1,000 requests) | Ties cloud spend to value; "is our cost-per-order going up or down?" matters more than the absolute bill |
| Cost Anomaly Detection | AWS ML-based service that learns spend patterns and alerts on unusual changes | Replaces "wait for the monthly spike, then investigate" with automated, near-real-time detection |
| Cost and Usage Report (CUR / CUR 2.0) | AWS's most detailed billing export, delivered to S3, queryable in Athena | The senior toolchain for cost analysis at scale, beyond the Cost Explorer console |
| Tag policy | An AWS Organizations governance control that enforces tag keys/values across accounts | Catches console-created and drifted resources that Terraform validation alone misses |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Cost Explorer | Analyze cost by service, account, region, usage type, and tags |
| AWS Budgets | Create monthly cost thresholds and alert recommendations |
| AWS Billing and Cost Management Console | Access cost, billing, budget, and reporting tools |
| AWS CLI | Validate account identity and optionally query cost or resource data |
| Spreadsheet tool | Analyze sample cost data and calculate increases |
| VS Code | Edit Markdown templates and report files |
| Terminal or PowerShell | Run AWS CLI and local file commands |
| Git, optional | Store reports, standards, and templates in version control |

---

## 6. AWS Services Used

| AWS Service | How It Connects to the Class |
|---|---|
| AWS Cost Explorer | Primary AWS service for cost analysis |
| AWS Budgets | Used for alerting and budget threshold planning |
| AWS Billing and Cost Management | Central billing area for AWS cost tools |
| AWS Organizations, overview | Explains cost visibility across multiple AWS accounts |
| EC2 | Common compute cost driver |
| EBS | Common storage cost driver, especially unattached volumes |
| S3 | Common storage service where lifecycle policies affect cost |
| RDS | Common database cost driver |
| NAT Gateway | Common networking cost driver due to hourly and data processing charges |
| Elastic Load Balancing | Common recurring cost if ALBs or NLBs are left idle |
| CloudWatch Logs | Common cost driver due to log ingestion and retention |
| AWS Resource Groups Tagging API, overview | Useful for identifying tagged and untagged resources |

---

## 7. Azure and GCP Comparison Notes

Keep this section short during class.

| Capability | AWS | Azure | GCP |
|---|---|---|---|
| Cost analysis | AWS Cost Explorer | Azure Cost Management | Cloud Billing Reports |
| Budget alerts | AWS Budgets | Azure Budgets | GCP Budgets and alerts |
| Tags or labels | Tags | Tags | Labels |
| Recommendations | Trusted Advisor, Compute Optimizer | Azure Advisor | Active Assist, Recommender |
| Organization model | AWS Organizations and accounts | Management groups and subscriptions | Organizations, folders, projects |

Instructor note:

AWS remains the main teaching platform. Azure and GCP should be used only to show that the same cost visibility principles apply across clouds.

---

## 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Welcome, class goal, and connection to Week 18 |
| 0:10 to 0:25 | Opening discussion: Why cloud bills grow unexpectedly |
| 0:25 to 0:45 | Cost optimization mindset: finance, engineering, and shared ownership |
| 0:45 to 1:10 | AWS cost visibility: Cost Explorer, service cost, usage type, linked accounts, and tags |
| 1:10 to 1:20 | Short break |
| 1:20 to 1:45 | Tagging strategy: ownership, environment, application, cost center, and business unit |
| 1:45 to 2:10 | Instructor demo: Cost Explorer and AWS Budgets |
| 2:10 to 2:40 | Student lab: Analyze sample spend and create budget recommendations |
| 2:40 to 2:55 | Troubleshooting activity: Monthly AWS bill increased by 40% |
| 2:55 to 3:00 | Recap, homework explanation, and Class 2 preview |

---

## 9. Instructor Lesson Plan

### Step 1: Open With a Real-World Problem

Start with:

```text
Finance says the AWS bill increased by 40% this month. They do not want a generic answer. They want to know what changed, who owns it, whether it is expected, and what we are doing about it.
```

Ask students:

```text
What cloud resources can silently increase cost if no one reviews them?
```

Expected answers:

- EC2 instances
- NAT Gateways
- EBS volumes
- Snapshots
- CloudWatch Logs
- Load balancers
- RDS databases
- S3 storage
- Kubernetes clusters

Teaching point:

Cloud cost is created by engineering decisions. Finance reports the bill, but engineering often explains and controls the usage.

### Step 2: Explain the Cost Optimization Mindset

Explain that cost optimization does not mean “make everything cheap.”

It means:

- Know what is running.
- Know who owns it.
- Know why it exists.
- Know whether the cost is expected.
- Reduce waste without harming reliability, security, or performance.

Say:

```text
Good cost optimization starts with visibility. Before we resize, delete, or redesign anything, we need evidence.
```

### Step 3: Teach AWS Cost Visibility

Explain how AWS spend can be grouped by:

- Service
- Region
- Linked account
- Usage type
- Tag
- Environment
- Application
- Owner

Examples:

```text
NAT Gateway tells us networking cost increased.
Usage type tells us whether the increase came from hourly cost or data processing.
Tags tell us which app or environment caused it.
```

Pause for questions after explaining service and usage type.

### Step 4: Teach Tagging Strategy

Explain that tags create accountability.

Recommended required tags:

```text
Application
Environment
Owner
CostCenter
BusinessUnit
ManagedBy
Criticality
DataClassification
```

Bad examples:

```text
Owner = test
Environment = misc
Application = app
```

Good examples:

```text
Owner = cloud-platform
Environment = nonprod
Application = account-search
CostCenter = IT-Cloud-1001
ManagedBy = terraform
```

Teaching tip:

For beginners, compare tags to labels on storage boxes. If nothing is labeled, no one knows what it is, who owns it, or whether it can be cleaned up.

### Step 5: Instructor Demo

Demo Cost Explorer and Budgets using either a real AWS account or sample screenshots.

Focus on:

- Service-level cost
- Usage type
- Tag-based grouping
- Actual vs forecasted cost
- Budget thresholds
- Alert recipients
- Owner accountability

### Step 6: Student Lab

Students analyze sample cost data and produce recommendations.

Remind them:

```text
Every cost recommendation should include evidence, owner, action, and risk.
```

Walk around and help students avoid jumping directly to deletion.

### Step 7: Troubleshooting Activity

Present the 40% AWS bill increase scenario.

Ask students to identify:

- What changed?
- Which services increased?
- Which costs are non-prod?
- Which resources lack ownership?
- What should be done immediately?
- What process would prevent this next month?

### Step 8: Wrap Up and Bridge to Class 2

Close with:

```text
Today we focused on cost visibility. In Class 2, we will move from visibility to action: rightsizing, idle cleanup, reserved capacity, and monthly cloud operations reporting.
```

---

## 10. Instructor Lecture Notes

### Cloud Cost Is an Operational Signal

Cloud cost is not just a finance number. It tells us something about architecture, usage, ownership, governance, and operational discipline.

A monthly cost increase may indicate:

- Real business growth
- New application traffic
- Overprovisioned resources
- Unused resources
- Missing cleanup
- Excessive logging
- Poor tagging
- Architecture inefficiency

Talking point:

```text
A cloud bill is a production signal. It tells us how our systems are being used and how well our teams are governing them.
```

### The FinOps Framework (Name It Out Loud)

In 2026, cost work has a recognized name and vocabulary: **FinOps**. Senior engineers are expected to use it. FinOps is the operational practice of giving engineering, finance, and product **shared accountability** for cloud spend. The FinOps Foundation defines a framework built on three iterative phases:

| Phase | Question it answers | This week's activities |
|---|---|---|
| **Inform** | Where is the money going, and who owns it? | Cost Explorer analysis, cost allocation tags, showback, budgets, anomaly detection (Class 1) |
| **Optimize** | What can we safely change to spend less for the same value? | Rightsizing, idle cleanup, commitments, scheduling, Graviton, storage tiering (Class 2) |
| **Operate** | How do we make this a repeatable, governed practice? | Monthly reporting, action trackers, tag policies, owner accountability (both classes) |

The framework also uses a **Crawl → Walk → Run** maturity model. A team starting out (Crawl) has basic tagging and a budget. A maturing team (Walk) has allocation, anomaly alerts, and showback. A mature team (Run) ties spend to unit economics, automates remediation, and runs commitment strategy continuously.

Talking point:

```text
This whole week is the FinOps Framework. Class 1 is mostly Inform. Class 2 is Optimize. The reporting and ownership process is Operate. When an interviewer asks how you approach cost, name the phases.
```

### Unit Economics: Cost per Unit of Business Value

The single most important senior FinOps concept is **unit economics** — expressing spend per unit of business value, not just in absolute dollars.

```text
Absolute view:   "The bill went up $9,000 this month."   (alarming, but incomplete)
Unit-cost view:  "Cost per 1,000 shipment lookups fell from $0.42 to $0.31, even though
                  total spend rose, because traffic grew 60%."   (this is the senior answer)
```

Common unit metrics:

- Cost per customer / per active user
- Cost per transaction or per 1,000 requests
- Cost per tenant (multi-tenant SaaS)
- Cost per environment per deploy

To compute a unit cost you need (1) allocated cost from tags/CUR and (2) a business volume metric from the application or a data warehouse. Rising absolute cost with **falling** unit cost is often healthy growth; **flat** traffic with rising cost is the real waste signal.

Talking point:

```text
Finance does not fear a bigger bill if the cost per order is going down. Always try to put a denominator under the dollars.
```

### Cost Anomaly Detection Is a Core Control, Not an Advanced Extra

Waiting for the monthly 40% spike and then investigating is reactive and slow. **AWS Cost Anomaly Detection** uses machine learning to learn each service's normal spend pattern and alerts within roughly a day of an unusual change. This is a core 2026 control, not a "nice to have."

How it is structured:

- A **monitor** defines what to watch (all AWS services, a specific service, a linked account, or a cost-allocation tag/cost category).
- An **alert subscription** defines the threshold (for example, alert when an anomaly's total or percentage impact exceeds a value) and the recipients (email or SNS).

Setup is free to enable. Teach students to create at least an account-wide monitor plus a per-service monitor for known volatile services (NAT Gateway, CloudWatch Logs, data transfer).

```text
AWS Console → Cost Management → Cost Anomaly Detection → Create monitor → Alert subscription
```

Talking point:

```text
An anomaly monitor turns "we found out at month-end" into "we got paged the next morning." Pair it with an owner, exactly like a budget alert.
```

### CUR + Athena: How Cost Is Analyzed at Scale

The Cost Explorer console is fine for quick investigation, but most enterprises analyze cost at scale through the **Cost and Usage Report (CUR / CUR 2.0)**. The CUR is the most granular billing data AWS produces — line items per resource per hour — delivered to an S3 bucket and queried with **Athena** (or visualized in **QuickSight**).

The flow:

```text
Billing → CUR 2.0 export (Parquet) → S3 bucket → Glue/Athena table → SQL queries / QuickSight dashboard
```

A canned Athena query students can read (do not over-explain SQL; the point is "cost is just data you can query"):

```sql
SELECT
  line_item_product_code            AS service,
  resource_tags_user_environment    AS environment,
  ROUND(SUM(line_item_unblended_cost), 2) AS cost_usd
FROM   cur_database.cur_table
WHERE  bill_billing_period_start_date = DATE '2026-06-01'
GROUP BY 1, 2
ORDER BY cost_usd DESC
LIMIT 20;
```

Talking point:

```text
Cost Explorer is the dashboard. CUR-in-Athena is the database. When someone asks 'show me cost per tenant by hour for the last 90 days,' you reach for the CUR, not the console.
```

### Allocating Shared Kubernetes Cost

This curriculum is container-heavy (Weeks 10–13, plus platform work in Week 20), so a top senior question is: **a single EKS cluster runs five teams' workloads — how do you split the bill?** AWS billing shows the cluster's EC2/Fargate cost as one lump; tags on nodes cannot see inside the cluster.

The answer is in-cluster cost allocation:

- **OpenCost** — the open-source CNCF standard; allocates cost by namespace, label, deployment, or pod using each workload's CPU/memory **requests** and actual usage.
- **Kubecost** — a commercial product built on OpenCost with a richer UI and more cloud-billing integration.

Both produce a "cost per namespace / per label" breakdown that becomes showback for each team. This is also why accurate **requests/limits** matter for cost, not just scheduling.

Talking point:

```text
If you cannot answer 'which namespace drove the cluster cost,' you cannot do chargeback in a container shop. OpenCost or Kubecost is how you get inside the cluster's bill.
```

### Finance Reports Cost, Engineering Explains Usage

Finance may say:

```text
The AWS bill increased by $9,000 this month.
```

Engineering needs to answer:

```text
Which services increased?
Which applications caused it?
Which environments caused it?
Who owns those resources?
Is the increase expected?
What action should we take?
```

This is why cloud engineers need cost visibility skills.

### Visibility Comes Before Optimization

Students may want to jump immediately into cleanup. Explain why that is risky.

Examples:

- Deleting an unattached EBS volume may remove recovery data.
- Reducing log retention may hurt incident investigation.
- Removing a NAT Gateway may break private subnet workloads.
- Downsizing a database may hurt performance.

Talking point:

```text
Optimization without evidence can become an outage.
```

### Tags Are Operational Metadata

Tags are not cosmetic. In enterprise environments, tags support:

- Cost reporting
- Ownership
- Incident response
- Automation
- Cleanup
- Security classification
- Compliance
- Chargeback and showback

Without tags, a report may say:

```text
EC2 increased by $8,000.
```

With tags, it can say:

```text
EC2 increased by $8,000 for Application=orders-api, Environment=nonprod, Owner=app-team-a.
```

The second version creates accountability.

### Budget Alerts Need Owners

AWS Budgets can send alerts, but alerts do not fix the problem by themselves.

A useful budget alert needs:

- Threshold
- Recipient
- Owner
- Escalation path
- Expected response
- Review process

Poor example:

```text
Budget alert goes to a shared mailbox no one checks.
```

Better example:

```text
Budget alert goes to cloud platform, application owner, and finance contact with a documented response process.
```

### Common Misconceptions

| Misconception | Correction |
|---|---|
| Cost is only finance’s problem | Engineering creates and controls much of the usage |
| Tags are optional | Enterprise cloud operations depends on metadata |
| Budget alerts prevent overspending | Budget alerts warn people, but people and automation act |
| All cost increases are bad | Some increases reflect valid business growth |
| Non-prod cost does not matter | Non-prod is often where forgotten resources create waste |
| Expensive means waste | Expensive may be valid if tied to critical business need |
| Cleanup should be immediate | Cleanup should be approved and risk-aware |

---

## 11. Whiteboard Explanation

### Simple Diagram: Cost Visibility Flow

```text
Application Teams
      |
      v
Cloud Resources
EC2, EBS, RDS, S3, NAT Gateway, ALB, CloudWatch Logs
      |
      v
Tags and Account Structure
Application, Owner, Environment, CostCenter
      |
      v
AWS Cost Tools
Cost Explorer, Budgets, Cost Reports
      |
      v
Cloud Operations Review
What changed? Who owns it? Is it expected?
      |
      v
Action Plan
Budget alert, tagging fix, cleanup review, rightsizing review
```

### Step-by-Step Explanation

1. Application teams create or request cloud resources.
2. Those resources generate cost.
3. Tags and account structure help identify ownership.
4. AWS cost tools show spending trends.
5. The cloud operations team reviews the data.
6. Teams decide what actions are safe and useful.

### Enterprise Version

```text
Business Unit
   |
   v
Application Portfolio
   |
   v
AWS Accounts
dev / test / staging / prod / shared services
   |
   v
Tagged Resources
Application, Owner, Environment, CostCenter, ManagedBy
   |
   v
Cost Reporting
Cost Explorer, Budgets, CUR, dashboards
   |
   v
Governance Process
Monthly review, budget alerts, exceptions, cleanup backlog
   |
   v
Engineering Actions
Terraform updates, owner review, cleanup, retention changes
```

### What Each Component Means

| Component | Meaning |
|---|---|
| Business Unit | The group funding or requesting the workload |
| Application Portfolio | Applications that generate cloud usage |
| AWS Accounts | Boundaries used for isolation, access, and reporting |
| Tagged Resources | Resources with metadata for ownership and reporting |
| Cost Reporting | Tools and reports used to analyze spend |
| Governance Process | Monthly review and ownership workflow |
| Engineering Actions | Practical fixes or changes based on evidence |

---

## 12. Instructor Demo Script

### Demo Title

**Using AWS Cost Explorer, Tags, and Budgets to Investigate Cloud Spend**

### Demo Objective

Show how a cloud engineer investigates AWS spending trends, identifies cost drivers, and recommends basic budget controls.

### Required Setup

Preferred:

- AWS account with Cost Explorer enabled
- Billing read-only permissions
- Budget permissions
- Sample tagged resources or historical billing data

Safe classroom alternative:

- Instructor screenshots
- Sample CSV files
- Mock AWS CLI outputs

### Demo Step 1: Confirm AWS Account Identity

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
Always confirm which AWS account you are using before reviewing billing or resources.
```

### Demo Step 2: Open AWS Billing and Cost Management

Console path:

```text
AWS Console → Billing and Cost Management
```

Explain:

```text
This is the starting point for cost visibility, budgets, reports, and billing settings.
```

### Demo Step 3: Open AWS Cost Explorer

Console path:

```text
Billing and Cost Management → Cost Explorer
```

Show:

- Monthly cost trend
- Daily cost trend
- Forecasted spend

Explain:

```text
First, look at the trend. Did cost grow gradually, or did it spike suddenly?
```

### Demo Step 4: Group Cost by Service

Console action:

```text
Group by → Service
```

Common services to discuss:

```text
EC2
EC2-Other
Amazon VPC
Amazon CloudWatch
Amazon RDS
Elastic Load Balancing
Amazon S3
```

Explain:

```text
Grouping by service tells us what category of cloud usage is driving the bill.
```

### Demo Step 5: Group by Usage Type

Console action:

```text
Group by → Usage Type
```

Examples:

- NAT Gateway data processing
- NAT Gateway hourly charge
- EBS volume storage
- EBS snapshot storage
- Load balancer hours
- CloudWatch log ingestion
- CloudWatch log storage

Explain:

```text
Service tells us the category. Usage type tells us the behavior.
```

### Demo Step 6: Filter by Tag

Console action:

```text
Filter → Tag → Environment → nonprod
```

Explain:

```text
If tags are clean, we can separate production growth from non-production waste.
```

Warning:

```text
If cost allocation tags are not activated, they may not appear in billing reports.
```

### Demo Step 6b: Activate Cost Allocation Tags

Tags do not appear in billing/Cost Explorer grouping until they are **activated** as cost allocation tags (and activation is not retroactive — it applies from activation forward). Show the path:

```text
Billing and Cost Management → Cost allocation tags → User-defined cost allocation tags
→ Select Application, Environment, Owner, CostCenter → Activate
```

Explain:

```text
Activating a tag tells AWS to break out cost by that tag key. Until you do this, your beautifully tagged resources still show up as one undifferentiated lump in the bill.
```

### Demo Step 6c: Enforce Tags With an Organizations Tag Policy

Terraform validation only catches resources created through Terraform. Console-created and drifted resources slip through. **AWS Organizations tag policies** define which tag keys (and optionally allowed values) are expected across accounts, and report non-compliant resources org-wide.

Show a sample tag policy document:

```json
{
  "tags": {
    "Environment": {
      "tag_key": { "@@assign": "Environment" },
      "tag_value": { "@@assign": ["prod", "staging", "test", "dev", "nonprod"] },
      "enforced_for": { "@@assign": ["ec2:instance", "ec2:volume", "rds:db"] }
    },
    "Owner": {
      "tag_key": { "@@assign": "Owner" }
    },
    "CostCenter": {
      "tag_key": { "@@assign": "CostCenter" }
    }
  }
}
```

Console path:

```text
AWS Organizations → Policies → Tag policies → Create policy → Attach to OU or account
```

Explain:

```text
Tag policies are case-sensitive on the key and report compliance across every account, not just the ones using your Terraform. Use Terraform validation to PREVENT bad tags at creation, and tag policies to DETECT drift everywhere else. They are complementary, not redundant.
```

Cost/safety note:

```text
A tag policy with enforced_for can BLOCK noncompliant resource creation/modification. Start in report-only mode (no enforced_for) so you do not break a team's deploy before they have remediated.
```

### Demo Step 6d: Enable Cost Anomaly Detection

```text
Cost Management → Cost Anomaly Detection → Create monitor
  Monitor type: AWS services (recommended account-wide baseline)
  Add a second monitor scoped to Linked account or a Cost allocation tag for per-team detection
→ Create alert subscription
  Threshold: absolute (e.g. > $200 anomaly impact) OR percentage (e.g. > 40% above expected)
  Frequency: Individual alerts (immediate) for high thresholds; Daily/Weekly summary for low-noise
  Recipients: cloud-platform@example.com (or an SNS topic)
```

Explain:

```text
Enabling anomaly detection costs nothing. The ML baseline needs about 10 days of history to become accurate. Tie each alert to an owner and a response step, the same way we do for budgets.
```

### Demo Step 7: Create a Sample Budget

Console path:

```text
Billing and Cost Management → Budgets → Create budget
```

Sample budget:

```text
Budget type: Cost budget
Period: Monthly
Budget amount: $5,000
Alert 1: 50% actual
Alert 2: 80% actual
Alert 3: 100% forecasted
Recipients: cloud-platform@example.com, app-owner@example.com
```

Explain:

```text
A budget is only useful if the alert reaches someone who knows what action to take.
```

### Optional AWS CLI Cost Query

Command:

```bash
aws ce get-cost-and-usage   --time-period Start=2026-04-01,End=2026-04-26   --granularity MONTHLY   --metrics "UnblendedCost"   --group-by Type=DIMENSION,Key=SERVICE
```

Expected output shape:

```json
{
  "ResultsByTime": [
    {
      "TimePeriod": {
        "Start": "2026-04-01",
        "End": "2026-04-26"
      },
      "Groups": [
        {
          "Keys": ["Amazon Elastic Compute Cloud - Compute"],
          "Metrics": {
            "UnblendedCost": {
              "Amount": "1250.42",
              "Unit": "USD"
            }
          }
        }
      ]
    }
  ]
}
```

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Cost Explorer has no data | New account or Cost Explorer not enabled | Use sample screenshots or CSV |
| Access denied | Missing billing permissions | Use mock data and explain required access |
| Budget creation fails | Missing Budgets permission | Show concept with screenshots |
| Tags not visible | Cost allocation tags not activated | Explain activation requirement |
| CLI command fails | Wrong profile or credentials | Run `aws configure list` and `aws sts get-caller-identity` |

### Cleanup Steps

If a real demo budget was created:

```text
AWS Console → Billing and Cost Management → Budgets → Select demo budget → Delete
```

If local demo files were created:

```bash
rm -rf week18-class1-demo
```

---

## 13. Student Lab Manual

### Lab Title

**Analyze Cloud Spend and Recommend Cost Controls**

### Lab Objective

Students analyze sample AWS cost data and create a short cost visibility report with tagging, budget, and ownership recommendations.

### Estimated Time

30 to 40 minutes

### Student Prerequisites

Students should know:

- Basic AWS services
- Basic tagging concepts
- Basic spreadsheet filtering
- Difference between production and non-production
- Basic cost ownership concepts

### Architecture or Workflow Overview

```text
Sample AWS Cost Data
       |
       v
Analyze by Service, Environment, Owner, Tag Status
       |
       v
Identify Cost Drivers and Missing Ownership
       |
       v
Recommend Budgets and Tagging Controls
       |
       v
Create Short Cost Analysis Report
```

### Files Provided

```text
sample-aws-cost-report.csv
sample-untagged-resources.csv
cost-analysis-report-template.md
```

### Sample File: `sample-aws-cost-report.csv`

```csv
Service,Environment,Owner,Application,Region,MonthlyCostUSD,PreviousMonthUSD,TagStatus
EC2,prod,app-team-a,orders-api,us-east-1,4200,3900,Complete
NAT Gateway,nonprod,unknown,unknown,us-east-1,3100,900,Missing
CloudWatch Logs,nonprod,app-team-b,claims-api,us-east-1,1800,400,Partial
EBS,dev,unknown,unknown,us-east-1,950,200,Missing
Elastic Load Balancing,test,app-team-c,inventory-ui,us-east-1,750,150,Partial
RDS,prod,app-team-a,orders-db,us-east-1,5200,5100,Complete
S3,prod,data-team,reports,us-east-1,600,580,Complete
Snapshots,dev,unknown,unknown,us-east-1,700,100,Missing
```

### Step 1: Create a Working Folder

```bash
mkdir -p week18-class1-lab
cd week18-class1-lab
```

Expected result:

```text
You are now inside the week18-class1-lab folder.
```

### Step 2: Open the Cost Report

Open `sample-aws-cost-report.csv` in a spreadsheet tool or VS Code.

### Step 3: Identify Top Cost Drivers

Sort by `MonthlyCostUSD` descending.

Expected top services:

```text
RDS: 5200
EC2: 4200
NAT Gateway: 3100
CloudWatch Logs: 1800
EBS: 950
```

### Step 4: Calculate Month-over-Month Increase

Create a new column:

```text
IncreaseUSD = MonthlyCostUSD - PreviousMonthUSD
```

Expected increases:

```text
NAT Gateway: 2200
CloudWatch Logs: 1400
EBS: 750
Snapshots: 600
Elastic Load Balancing: 600
```

### Step 5: Group Costs by Environment

Expected totals:

```text
prod: 10000
nonprod: 4900
dev: 1650
test: 750
```

### Step 5b: Calculate a Unit-Economics Metric

Absolute dollars are only half the story. Compute a **unit cost** so you can tell growth apart from waste. Use this sample business-volume data for the same month:

```text
shipment-lookups this month:   24,000,000  (last month: 15,000,000)
total bill this month:         $16,300     (last month: $11,930)
```

Compute cost per 1,000 shipment lookups:

```text
This month:  16,300 / (24,000,000 / 1,000) = $0.68 per 1,000 lookups
Last month:  11,930 / (15,000,000 / 1,000) = $0.795 per 1,000 lookups
```

Interpretation:

```text
The absolute bill rose 37%, but cost per 1,000 lookups FELL ~14%. The customer-serving
(prod) growth is efficient. That means the suspicious increase is concentrated in the
non-prod / untagged lines, not in the workload serving real traffic.
```

Write one sentence for finance that uses the unit metric, not just the total.

### Step 6: Identify Missing or Partial Tags

Filter `TagStatus` for:

```text
Missing
Partial
```

Expected findings:

```text
NAT Gateway
CloudWatch Logs
EBS
Elastic Load Balancing
Snapshots
```

### Step 7: Recommend Budget Thresholds

Create a non-prod budget recommendation.

Example:

```text
Budget name: monthly-nonprod-budget
Monthly budget amount: $5,000
Alert 1: 50% actual spend
Alert 2: 80% actual spend
Alert 3: 100% forecasted spend
Recipients: cloud platform team, app owner, finance contact
```

### Step 8: Create Cost Control Recommendations

Students should create at least 5 recommendations.

Example recommendations:

```text
1. Investigate NAT Gateway traffic in non-prod.
2. Add VPC endpoints for S3 and ECR if private workloads are pulling large AWS artifacts.
3. Review CloudWatch log retention for non-prod claims-api logs.
4. Identify and delete unattached EBS volumes after owner approval.
5. Review old dev snapshots and define a retention policy.
6. Confirm whether the test ALB is still required.
7. Enforce required tags through Terraform AND an Organizations tag policy (catch console/drifted resources).
8. Activate Application/Environment/Owner/CostCenter as cost allocation tags so the bill can be broken out.
9. Enable Cost Anomaly Detection (account-wide monitor + a NAT Gateway / CloudWatch Logs monitor) so the next spike pages an owner instead of surfacing at month-end.
10. If shared Kubernetes clusters are in scope, deploy OpenCost or Kubecost to allocate cluster cost by namespace/label (raw EC2 cost alone cannot tell you which team's pods drove it).
```

### Step 9: Complete the Report Template

Use this Markdown structure:

```markdown
# Cloud Cost Analysis Report

## Executive Summary

## Top Cost Drivers

## Month-over-Month Changes

## Missing Tag Findings

## Budget Recommendations

## Optimization Recommendations

## Risks and Considerations

## Owners and Next Steps
```

### Expected Output Example

```text
Executive Summary:
The largest cost increases appear to be non-prod NAT Gateway traffic, increased CloudWatch Logs, dev EBS storage, snapshots, and test load balancing. Several cost drivers are missing owner or environment tags, making ownership unclear. Recommended actions include owner validation, budget alerts, required tag enforcement, log retention review, and cleanup of idle resources after approval.
```

### Validation Checklist

- [ ] Top 5 cost drivers identified
- [ ] Month-over-month increase calculated
- [ ] Costs grouped by environment
- [ ] Missing and partial tags identified
- [ ] Budget thresholds recommended
- [ ] At least 5 cost control recommendations created
- [ ] Risks documented
- [ ] Owners or ownership gaps documented
- [ ] Report written in clear business-friendly language

### Troubleshooting Tips

| Problem | Fix |
|---|---|
| Cannot calculate increase | Use `MonthlyCostUSD - PreviousMonthUSD` |
| Owner is unknown | Mark as ownership gap and recommend tag remediation |
| Unsure whether resource is waste | Mark as “needs owner validation” |
| Production cost looks high | Do not assume waste. Check business usage |
| Tags are missing | Recommend required tag enforcement |
| NAT cost is confusing | Look for private subnet outbound traffic or artifact downloads |

### Cleanup Steps

No AWS resources are created in this lab.

Optional local cleanup:

```bash
cd ..
rm -rf week18-class1-lab
```

Recommended:

Keep the report for Class 2 because it becomes the starting point for optimization actions.

### Reflection Questions

1. Which service had the largest suspicious increase?
2. Which costs may be valid production costs?
3. Which costs look like avoidable waste?
4. How did missing tags affect your investigation?
5. What would you tell finance in plain English?

### Optional Challenge Task

Create a Markdown file:

```text
cloud-cost-tagging-standard.md
```

Include:

- Required tags
- Example tag values
- Budget thresholds
- Alert recipients
- Cleanup expectations
- Escalation process

---

## 14. Troubleshooting Activity

### Incident Title

**AWS Bill Increased by 40% This Month**

### Business Impact

Finance reports that AWS spend increased beyond forecast. Engineering leadership wants a clear explanation before approving next month’s cloud budget.

### Symptoms

```text
Month-over-month AWS spend increased by 40%.

Largest increases:
- NAT Gateway
- EBS
- CloudWatch Logs
- Elastic Load Balancing
- Snapshots
```

### Starting Evidence

```text
Known recent changes:
- New test environment created three weeks ago
- Debug logging enabled for claims-api
- Several load balancers created for testing
- No cleanup ticket completed after testing
- Multiple resources missing Owner and Environment tags
```

Sample cost increase:

```text
NAT Gateway: $900 → $3,100
CloudWatch Logs: $400 → $1,800
EBS: $200 → $950
Snapshots: $100 → $700
Elastic Load Balancing: $150 → $750
```

### Student Investigation Steps

Students should:

1. Identify which services increased the most.
2. Separate production spend from non-production spend.
3. Check whether increased services have owners.
4. Identify missing or partial tags.
5. Determine likely waste vs expected growth.
6. Recommend immediate actions.
7. Recommend preventive governance controls.
8. Draft a short update to finance and leadership.

### Expected Root Cause

The likely cause is a combination of:

- Non-prod test environment left running
- High NAT Gateway data processing from private subnet workloads
- Debug logs increasing CloudWatch ingestion
- Unattached or unused EBS volumes
- Old snapshots retained without policy
- Idle load balancers from test environments
- Weak tagging and cleanup process

### Correct Resolution

Immediate actions:

```text
1. Identify owner for non-prod test environment.
2. Review NAT Gateway traffic source.
3. Reduce non-prod CloudWatch log retention if appropriate.
4. Confirm and delete idle load balancers after approval.
5. Review unattached EBS volumes and old snapshots.
6. Add required missing tags.
7. Create budget alerts for non-prod environments.
```

Preventive actions:

```text
1. Enforce required tags in Terraform modules.
2. Add cleanup checklist for temporary environments.
3. Create monthly cloud operations review.
4. Route budget alerts to accountable owners.
5. Create reports for untagged and idle resources.
```

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Delete all expensive resources immediately | Could cause outages or data loss |
| Blame finance for the bill | Finance reports cost, but engineering controls usage |
| Ignore non-prod | Non-prod often creates major waste |
| Focus only on EC2 | NAT, logs, snapshots, and load balancers can be major drivers |
| Assume tags are cosmetic | Tags support ownership, cleanup, automation, and reporting |
| Reduce log retention without approval | Could harm troubleshooting or compliance |

### Instructor Hints

Use these prompts if students are stuck:

```text
Which service increased the most in dollars?
Which resources have no owner?
Which costs are in non-prod?
What action is safe right now?
What action needs approval?
What process would prevent this next month?
```

### Preventive Action

The strongest preventive action is a repeatable process:

```text
Required tags + budget alerts + monthly review + owner accountability + cleanup workflow
```

---

## 15. Scenario-Based Discussion Questions

### Question 1

**Who should own cloud cost: finance, cloud platform, application teams, or all of them?**

Expected themes:

- Finance tracks and forecasts spend.
- Cloud platform owns standards and reporting.
- Application teams own workload-level usage.
- Leadership owns prioritization.

Follow-up:

```text
What happens if only finance receives budget alerts?
```

### Question 2

**When should a team not reduce cloud cost even if a service is expensive?**

Expected themes:

- Reliability requirements
- Security logging
- Compliance retention
- Peak traffic capacity
- Disaster recovery needs

Follow-up:

```text
What evidence would justify keeping the higher cost?
```

### Question 3

**Why are tags important beyond billing?**

Expected themes:

- Ownership
- Incident response
- Automation
- Cleanup
- Security classification
- Cost allocation

Follow-up:

```text
How would missing Owner tags slow down an incident or cleanup effort?
```

### Question 4

**What is the risk of aggressive cleanup in a production account?**

Expected themes:

- Data loss
- Outage
- Compliance issue
- Broken dependencies
- Loss of forensic evidence

Follow-up:

```text
What approval steps should exist before deleting cloud resources?
```

### Question 5

**What makes non-prod environments hard to control?**

Expected themes:

- Temporary environments become permanent.
- Debug logging is left enabled.
- Cleanup is forgotten.
- Ownership is unclear.
- Monitoring may be weaker.

Follow-up:

```text
How can automation reduce non-prod waste?
```

### Question 6

**Should every application team see its own cloud cost?**

Expected themes:

- Improves accountability.
- Helps teams design better.
- Requires accurate tags.
- Reports must be easy to understand.

Follow-up:

```text
Would you start with showback or chargeback?
```

### Question 7

**How do budget alerts fail in real companies?**

Expected themes:

- Sent to the wrong people
- No owner
- Too many alerts
- No response process
- Alerts arrive too late

Follow-up:

```text
What should happen after an 80% budget alert?
```

### Question 8

**How do cost, reliability, and security trade off?**

Expected themes:

- Redundancy costs more but improves reliability.
- Logs cost more but support troubleshooting.
- Security tools cost money but reduce risk.
- Cheap architecture may create operational risk.

Follow-up:

```text
Give an example where spending more is the correct engineering decision.
```

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

Which AWS service is primarily used to analyze cloud spend by service, usage type, account, or tag?

A. CloudTrail  
B. Cost Explorer  
C. Systems Manager  
D. Route 53  

**Answer:** B  
**Explanation:** AWS Cost Explorer is used to analyze cost and usage trends.

### Question 2: Multiple Choice

Which tag is most useful for identifying who should respond to a cloud cost question?

A. Color  
B. Owner  
C. RandomId  
D. CreatedByConsole  

**Answer:** B  
**Explanation:** The `Owner` tag identifies the team or person accountable for the resource.

### Question 3: True or False

AWS Budgets automatically reduces cloud spend when a threshold is reached.

**Answer:** False  
**Explanation:** AWS Budgets sends alerts. It does not automatically reduce spend unless separate automation is configured.

### Question 4: Short Answer

Name three common AWS services that can cause unexpected cost increases.

**Answer:** NAT Gateway, EC2, EBS, CloudWatch Logs, RDS, ALB/NLB, snapshots, and S3 are valid examples.  
**Explanation:** These services can grow due to usage, misconfiguration, retention, or missing cleanup.

### Question 5: Multiple Choice

A NAT Gateway cost spike is often related to which issue?

A. Too many IAM users  
B. High outbound data processing from private subnets  
C. Too many Route 53 hosted zones only  
D. Missing MFA  

**Answer:** B  
**Explanation:** NAT Gateway charges include hourly cost and data processing cost.

### Question 6: Troubleshooting Question

Finance reports a 40% AWS bill increase. Cost Explorer shows CloudWatch Logs increased from $400 to $1,800. What should you check first?

**Answer:** Check log ingestion volume, retention settings, recent debug logging changes, and which application or environment owns the log groups.  
**Explanation:** Logging cost often increases because debug logs or high-volume logs are enabled.

### Question 7: True or False

Missing tags make it harder to identify cost ownership.

**Answer:** True  
**Explanation:** Without tags such as Application, Owner, and Environment, teams cannot map resources to business ownership.

### Question 8: Multiple Choice

Which is the best first response before deleting an unattached EBS volume?

A. Delete it immediately  
B. Confirm ownership, backup needs, and whether it is safe to remove  
C. Ignore it forever  
D. Rename it  

**Answer:** B  
**Explanation:** Even unattached volumes may contain data needed for rollback, recovery, audit, or investigation.

### Question 9: Short Answer

What is the difference between showback and chargeback?

**Answer:** Showback shows teams their cloud cost without directly billing them. Chargeback directly assigns or bills costs to teams or cost centers.  
**Explanation:** Showback is often used first to build awareness.

### Question 10: AWS-Related Short Answer

What are three useful budget alert thresholds for a monthly AWS budget?

**Answer:** 50% actual spend, 80% actual spend, and 100% forecasted spend.  
**Explanation:** These thresholds provide early warning, serious warning, and projected overrun warning.

### Question 11: Troubleshooting Question

A test environment was created three weeks ago and the AWS bill increased. What evidence would help determine if the test environment caused the increase?

**Answer:** Environment tags, service-level cost, linked account, resource creation dates, usage type, owner tags, and Cost Explorer filtered by environment or application.  
**Explanation:** The investigation needs ownership, time, and usage evidence.

### Question 12: Multiple Choice

Which GCP concept is closest to AWS tags for cost reporting?

A. Labels  
B. Security Groups  
C. VPC Endpoints  
D. Buckets  

**Answer:** A  
**Explanation:** GCP labels are commonly used for organizing and reporting cloud resources.

---

## 17. Homework Assignment

### Assignment Title

**Create a Cloud Cost Visibility and Tagging Standard**

### Scenario

Your company’s AWS bill has increased several months in a row. Finance can see the total bill, but engineering teams cannot clearly identify which application, environment, or owner is responsible for each cost increase. Leadership asks the cloud platform team to create a simple tagging and budget standard.

### Student Tasks

Create a 1 to 2 page standard that includes:

1. Purpose of cloud cost visibility
2. Required tags
3. Optional tags
4. Example tag values
5. Tagging rules for production and non-production
6. Budget alert thresholds
7. Budget alert recipients
8. Monthly cost review process
9. Untagged resource handling process
10. Azure and GCP comparison notes

### Expected Deliverables

Submit one Markdown or Word document.

Suggested file name:

```text
cloud-cost-visibility-tagging-standard.md
```

### Submission Format

```text
Name:
Week:
Class:
Assignment title:
Document link or uploaded file:
```

### Estimated Completion Time

60 to 90 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Required tags are clearly defined | 20 |
| Budget alert strategy is practical | 20 |
| Ownership and escalation process is included | 20 |
| Examples are realistic | 15 |
| Azure/GCP comparison is concise and relevant | 10 |
| Document is clear and professional | 15 |
| Total | 100 |

### Optional Advanced Challenge

Add a Terraform variable validation example that enforces required tags.

```hcl
variable "required_tags" {
  type = map(string)

  validation {
    condition = alltrue([
      contains(keys(var.required_tags), "Application"),
      contains(keys(var.required_tags), "Environment"),
      contains(keys(var.required_tags), "Owner"),
      contains(keys(var.required_tags), "CostCenter")
    ])
    error_message = "Required tags must include Application, Environment, Owner, and CostCenter."
  }
}
```

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid It |
|---|---|---|
| Treating cost as only a finance problem | Students separate billing from engineering | Reinforce that architecture and usage create cost |
| Recommending deletion too quickly | Students want immediate savings | Require owner approval and risk review |
| Ignoring NAT Gateway cost | NAT cost is less visible than EC2 | Teach service and usage type analysis |
| Thinking tags are cosmetic | Tags look like simple labels | Show how tags support ownership and automation |
| Creating too many required tags | Students over-design standards | Keep required tags minimal and useful |
| Forgetting non-prod budgets | Students focus only on production | Explain that non-prod often creates waste |
| Not documenting risk | Students focus only on savings | Require a risk statement for each recommendation |
| Confusing actual and forecasted spend | Billing terms are new | Explain actual means already spent, forecasted means projected |
| Assuming all cost increases are bad | Growth can be valid | Separate business growth from waste |
| Missing Azure/GCP equivalents | AWS-first focus can create tunnel vision | Add short comparison notes without changing the main flow |

---

## 19. Real-World Enterprise Scenario

### Scenario

A mid-size enterprise has 70 AWS accounts across development, testing, staging, production, shared services, and data platforms. Finance reports that monthly AWS spend increased by 28% over the last quarter.

The cloud platform team investigates and finds:

- Many non-prod resources have no owner tag.
- Several test ALBs are idle.
- NAT Gateway traffic increased in two non-prod VPCs.
- CloudWatch Logs retention is set to never expire for multiple test applications.
- EBS volumes remain after EC2 instances were deleted.
- Application teams say they did not know they were responsible for cleanup.

### Constraints

- Cloud platform cannot delete application resources without owner approval.
- Production reliability must not be impacted.
- Security requires certain logs to be retained.
- Finance wants monthly reporting.
- Application teams want simple reports, not raw billing exports.
- Leadership wants a repeatable governance process.

### What Each Role Would Do

#### Cloud Engineer

- Analyze Cost Explorer data.
- Identify untagged and idle resources.
- Recommend tagging standards.
- Create budget alerts.
- Review NAT Gateway and VPC endpoint options.
- Build monthly reporting process.

#### DevOps Engineer

- Add required tags to Terraform modules.
- Add CI/CD checks for missing tags.
- Automate non-prod cleanup where safe.
- Ensure pipelines pass ownership metadata.

#### SRE

- Review logging cost against incident response needs.
- Recommend environment-specific retention.
- Ensure cost reductions do not reduce reliability.
- Add operational checks to runbooks where needed.

---

## 20. Instructor Tips

### Teaching Tips

- Start with a business problem before showing tools.
- Keep the focus on visibility, ownership, and reporting.
- Avoid going too deep into pricing models in Class 1.
- Emphasize that cost decisions need risk awareness.
- Use plain-English explanations because students will need to talk to non-technical stakeholders.

### Pacing Tips

- Keep Azure/GCP comparison under 10 minutes.
- Do not spend too long on every Cost Explorer filter.
- Protect at least 30 minutes for the student lab.
- Leave time for the troubleshooting activity because it builds job readiness.

### Lab Support Tips

Students may struggle with:

- Sorting cost data
- Calculating increases
- Knowing what is waste
- Writing business-friendly recommendations

Coach them with:

```text
What changed?
Who owns it?
Is it prod or non-prod?
Is this expected growth or avoidable waste?
What action is safe?
```

### How to Help Struggling Students

Give them a smaller goal:

1. Find the top 3 cost increases.
2. Identify which ones lack tags.
3. Write one recommendation per finding.

### How to Challenge Advanced Students

Ask them to add:

- Terraform tag validation
- Budget escalation workflow
- NAT Gateway investigation steps
- VPC endpoint recommendation
- Cost anomaly detection concept
- Tag compliance dashboard idea

---

## 21. Student Outcome Checklist

By the end of class, students should be able to:

### Explain

- [ ] Why cloud cost is an engineering responsibility
- [ ] What AWS Cost Explorer is used for
- [ ] What AWS Budgets are used for
- [ ] Why tags matter for ownership and reporting
- [ ] How AWS, Azure, and GCP cost tools compare at a high level

### Build or Configure

- [ ] Create a basic tagging standard
- [ ] Recommend budget thresholds
- [ ] Build a short cloud cost analysis report
- [ ] Group sample costs by service and environment
- [ ] Identify missing ownership metadata

### Troubleshoot

- [ ] Investigate a cloud bill increase
- [ ] Identify suspicious cost drivers
- [ ] Separate expected growth from likely waste
- [ ] Recommend safe next steps
- [ ] Communicate findings to finance or leadership

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Students understand why cost visibility comes before optimization.
- [ ] Students can name common AWS cost drivers.
- [ ] Students completed or started the cost analysis lab.
- [ ] Students understand required tags.
- [ ] Students understand budget alert thresholds.
- [ ] Troubleshooting scenario was reviewed.
- [ ] Homework instructions were explained.
- [ ] Class 2 was previewed.

### Student Checklist Before Leaving Class

- [ ] I can explain what caused the sample cost increase.
- [ ] I can identify missing tags in a cost report.
- [ ] I can recommend budget thresholds.
- [ ] I can explain why deleting resources without approval is risky.
- [ ] I understand the homework assignment.
- [ ] I saved my lab report or notes for Class 2.

### Items to Verify Before Moving to Class 2

Students should have:

- A basic cost analysis report draft
- A list of top cost drivers
- A list of missing tag findings
- Budget recommendation notes
- Understanding of cost visibility, tagging, and ownership

Class 2 should build from this by focusing on rightsizing, idle cleanup, reserved capacity, and monthly cloud operations reporting.

---

## Class Artifacts & Validation

This class's tagging/visibility hands-on work is backed by the runnable
[`labs/python-automation/`](../../labs/python-automation/) module. The artifact this
class uses is `tag_audit.py` — find resources missing required tags (`Owner`,
`CostCenter`, `Environment`, `Application`), the same gap the cost-report and
untagged-resources exercises in §13 surface manually. The pure logic is unit-tested
offline (no boto3, no AWS); the live CLI path is read-only (`ec2:DescribeInstances`).

All commands below were run from `labs/python-automation/`. The `Result` column reflects
this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/python-automation/solution/tag_audit.py | python | Pure `missing_tags` / `audit_resources`: flags required tags that are absent or empty | `PYTHONPATH=solution python3 -m unittest tests.test_tag_audit` | PASS — `Ran 15 tests ... OK` |
| 2 | labs/python-automation/starter/tag_audit.py | python | Intentionally-incomplete student version (core tag logic is `TODO`) — the reproducible broken state | `python3 -m py_compile starter/tag_audit.py` (syntax) | PASS (compiles; tests fail until TODO done — by design) |
| 3 | labs/python-automation/tests/test_tag_audit.py | python (unittest) | Pins "empty tag value = missing" and sorted-output behavior | `PYTHONPATH=solution python3 -m unittest tests.test_tag_audit` | PASS — `Ran 15 tests ... OK` |
| 4 | labs/python-automation/solution/lib/awsclient.py | python | The single boto3 importer (guarded `try/except ImportError`) so pure logic + tests run with no SDK | `python3 -c "from lib import awsclient; print(awsclient.boto3_available())"` (from `solution/`) | PASS — imports cleanly |
| 5 | labs/python-automation/validate.sh | shell | Module gate runner: `py_compile` all `.py` + `unittest` solution + assert starter is incomplete | `./validate.sh` | PASS — `3 passed, 0 failed` |
| 6 | labs/python-automation/README.md | markdown | Lab guide: prerequisites, tasks, validation, troubleshooting, cleanup, security & cost notes, answer key | (reference) | present |

Live `tag_audit.py` CLI against a real account (`PYTHONPATH=. python3 tag_audit.py
--required Owner CostCenter Environment`) is **DEFERRED** — it requires AWS credentials
with read-only `ec2:DescribeInstances`. No live-account evidence is captured in this
repo; the offline gates above are what is proven here.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — `tag_audit.py` (+ wrapper, tests) are real `.py` files, not fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured — `py_compile` + `unittest` PASS (`Ran 15 tests ... OK`); live CLI documented as DEFERRED.
- [x] Lab has **starter** (intentionally incomplete) and **solution** (reference) versions — `starter/tag_audit.py` has the TODO'd logic; `solution/tag_audit.py` is the reference.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, validation commands, expected outputs, troubleshooting, cleanup, security notes, cost notes — all present in `labs/python-automation/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — lab writes no cloud/local state beyond `__pycache__/`; live paths are read-only (nothing to destroy). Documented in the README Cleanup section.
- [x] **Instructor answer key** exists for the lab (README "Instructor answer key"), quiz (§16), homework (§17), and troubleshooting (§14).
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the `starter/` compiles but its `tag_audit` tests fail with concrete assertions until the TODO is done (README states this explicitly); the class §14 incident is a separate scenario.
- [x] **Expected outputs** are shown — README "Expected results" shows the `tag_audit` sample output; the class lab (§13) shows expected report output.
- [x] **Cost & security warnings** present — README Security (least-privilege read-only IAM, no hard-coded creds) and Cost ($0 offline; Cost Explorer caveat) sections; class §12/§13 cost-control framing.
- [x] **Cross-references** to the module repo and to prior/next weeks are correct — header links to `labs/python-automation/`; lab maps to Week 08 Class 02–03; week bridges to Class 2 (rightsizing/reporting).
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified by `ls`; all six rows resolve.
- [ ] **Mastered (live/operated)** — NOT claimed: no real AWS apply/destroy or live operation evidence exists for this class; the lab is static-validated only.
