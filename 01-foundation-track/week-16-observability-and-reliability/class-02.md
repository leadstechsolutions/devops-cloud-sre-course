# Week 16, Class 2: Reliability, Production Readiness, and Alerting

**Week:** 16 — Observability and Reliability
**Class:** 2 of 2
**Track:** Unified DevOps · Cloud · SRE Track

---

> **▶ Runnable lab for this class:** [`labs/observability/`](../../labs/observability/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Class 16.2: Reliability, Production Readiness, and Alerting**

### Class Purpose

This class introduces students to the operational mindset required before any application should be considered production-ready. Students learn how reliability is *framed*, how to judge whether a service is ready to operate (not just deploy), and — building directly on the signals from Class 1 — how to turn good metrics into **good alerts** rather than noise.

> **Scope boundary (read this first).** This class teaches reliability **framing** plus a **production-readiness checklist** and **alerting quality**. It deliberately stops at the *vocabulary and intuition* of SLI/SLO/SLA/error budgets. The deep reliability *engineering* — error-budget math, choosing SLIs, multi-window multi-burn-rate alerting, and SLO-as-code (OpenSLO/Sloth/Nobl9) — is owned by **Week 21 (SRE Foundations)**. Wherever this class touches SLOs, it hands the depth forward to Week 21 with an explicit pointer. This avoids teaching the SLO material twice and keeps the foundation/specialization relationship correct.

### How This Class Connects to the Overall Course

By Week 16, students have already learned Linux, networking, AWS, Git, scripting, CI/CD, Docker, Kubernetes, Helm, Terraform, security, and — in Class 1 of this week — observability signals (logs, metrics, traces, percentiles, RED/USE). This class connects those skills into one operational question:

```text
Can this system run safely in production, and can the team support it when something goes wrong?
```

It then closes the loop on Class 1: Class 1 gave you the signals; Class 2 decides **which signals should page a human**. The full SRE practice that grows out of this — SLO-driven alerting, error budgets, on-call, incident command, blameless postmortems — is the subject of **Week 21**.

### What Students Will Build, Analyze, or Practice

Students will:

- Analyze production readiness for a sample cloud application
- Frame reliability with SLI/SLO/SLA vocabulary (depth deferred to Week 21)
- Write a real symptom-based alert in **both** a Prometheus alerting rule **and** a CloudWatch alarm
- Reason about alert quality: severity, routing, grouping, inhibition, and the availability-vs-AND nuance
- Identify gaps in monitoring, alerting, backup, runbooks, and rollback plans
- Create a practical production readiness checklist and go-live decision

---

## 2. Class Learning Objectives

By the end of this class, students should be able to:

1. **Explain** reliability, availability, and the *framing* of SLIs, SLOs, SLAs, and error budgets in beginner-friendly terms (deep SLO math and burn-rate alerting are covered in Week 21).
2. **Identify** the difference between a deployed application and a production-ready application.
3. **Identify** good candidate SLIs for a web application (availability, latency, error rate) and explain why they map to user impact.
4. **Write** a symptom-based alert as both a Prometheus alerting rule and a CloudWatch alarm, and **explain** severity, routing, grouping, and inhibition.
5. **Analyze** whether a cloud application has enough monitoring, alerting, backup, and operational ownership.
6. **Compare** AWS CloudWatch, Route 53 health checks, and AWS Backup (and Prometheus/Alertmanager) with Azure and GCP equivalents.
7. **Document** a production readiness checklist and make a go-live decision for a cloud-hosted application.
8. **Recommend** reliability and alerting improvements for a service before production launch.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic Linux commands
- Basic networking concepts such as DNS, ports, HTTP, HTTPS, and load balancers
- AWS account basics
- IAM basics
- EC2, S3, VPC, and RDS concepts
- Docker and Kubernetes basics
- Observability signals from Class 1 of this week: logs, metrics, the metric types (counter/gauge/histogram), percentiles (p95/p99), RED/USE, and basic PromQL/CloudWatch
- Basic CI/CD and deployment concepts
- Terraform at a basic level

### Required Tools Already Installed

Students should have:

- VS Code
- Terminal or command line
- AWS CLI
- Git
- Browser access to AWS Console
- Optional: kubectl, Docker, and Helm for context only

### Required Accounts or Access

Students need one of the following:

- AWS sandbox account with read-only or limited lab access
- Instructor-provided screenshots or sample CloudWatch data
- Local sample files if AWS access is not available

Minimum AWS permissions for live demo or lab:

```text
cloudwatch:DescribeAlarms
cloudwatch:GetMetricData
cloudwatch:ListMetrics
logs:DescribeLogGroups
logs:DescribeLogStreams
logs:GetLogEvents
ec2:DescribeInstances
elasticloadbalancing:DescribeLoadBalancers
elasticloadbalancing:DescribeTargetGroups
elasticloadbalancing:DescribeTargetHealth
route53:ListHealthChecks
backup:ListBackupPlans
```

### Files, Repos, or Sample Code Needed

Recommended sample files:

```text
week16-class2/
  production-readiness-checklist-template.md
  sample-service-metrics.txt
  sample-alert-review.md
  sample-architecture.txt
```

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Reliability | How consistently a system works when users need it | A checkout service must work during peak business hours |
| Availability | Percentage of time a system is usable | A service with 99.9% availability can still have downtime |
| Latency | How long a request takes to complete | A page that loads in 3 seconds may feel slow to customers |
| Error Rate | Percentage of failed requests | A spike in 5xx errors often means users are impacted |
| SLI | Service Level Indicator, a measurement of service behavior | Example: percentage of successful HTTP requests *(depth in Week 21)* |
| SLO | Service Level Objective, an internal reliability target | Example: 99.5% successful requests over 30 days *(math/burn-rate in Week 21)* |
| SLA | Service Level Agreement, a formal promise to customers or business | Usually tied to contracts or business commitments |
| Error Budget | Amount of acceptable unreliability within an SLO period | Decision tool: ship features vs. do reliability work *(error-budget math/policy in Week 21)* |
| Symptom-based alert | An alert on user impact (latency, errors), not a cause (CPU) | "p95 latency high AND 5xx rate high" beats "CPU > 70%" |
| Alertmanager | Prometheus component that routes/groups/silences alerts and sends notifications | Routes a firing rule to PagerDuty/Slack/email by severity |
| Routing | Sending an alert to the right receiver based on labels | `severity=critical` → page on-call; `severity=warning` → Slack |
| Grouping | Collapsing many related alerts into one notification | 50 pods down → one grouped page, not 50 pages |
| Inhibition | Suppressing lower alerts when a higher one is firing | If the whole cluster is down, suppress per-pod alerts |
| Severity | The urgency tier of an alert | `critical` (page now) vs `warning` (look soon) vs `info` |
| On-call / escalation | The rotation of who responds, and who is paged next if no ack | PagerDuty/Opsgenie schedule *(on-call practice in Week 21)* |
| Production Readiness | The state of being ready to run and support a system in production | Includes monitoring, rollback, ownership, backups, and runbooks |
| Runbook | Step-by-step guide for handling a known operational issue | Used during incidents to reduce confusion |
| Dashboard | Visual view of system health | Helps engineers quickly understand service behavior |
| Alert | Notification triggered by a condition | Should represent real risk or user impact |
| Backup | Copy of data or configuration for recovery | Useful only if restore has been tested |
| RTO | Recovery Time Objective, how long downtime can last | Example: restore service within 2 hours |
| RPO | Recovery Point Objective, how much data loss is acceptable | Example: no more than 15 minutes of data loss |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| AWS Console | Used to inspect CloudWatch metrics, logs, alarms, Route 53 health checks, and backup settings |
| AWS CLI | Used to validate AWS identity, inspect services, and show operational commands |
| CloudWatch | Primary AWS service for metrics, logs, dashboards, and alarms |
| Route 53 Health Checks | Introduces DNS-level health monitoring and failover concepts |
| AWS Backup | Introduces backup planning and restore readiness |
| VS Code | Used to edit readiness checklist and documentation files |
| Markdown | Used for student deliverables such as checklists and summaries |
| Browser | Used for console access and dashboard review |
| Git | Optional, used to store checklist and operational documentation |

---

## 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon CloudWatch Metrics | Helps measure CPU, latency, errors, request count, and other reliability indicators |
| CloudWatch Logs | Helps investigate application and infrastructure behavior |
| CloudWatch Alarms | Sends alerts when a metric crosses a threshold |
| CloudWatch Dashboards | Provides a visual view of system health |
| Route 53 Health Checks | Shows how DNS-level health monitoring supports availability and failover |
| AWS Backup | Introduces backup policies, recovery points, and restore readiness |
| EC2 | Used as a familiar compute example for metrics and availability |
| Elastic Load Balancing | Used to discuss target health, request count, latency, and 5xx errors |
| EKS or Kubernetes Concept | Used as a production workload example, even if not fully configured during this class |
| IAM | Used to explain why operational access must be controlled |
| CloudTrail | Briefly referenced for auditing operational actions |

---

## 7. Azure and GCP Comparison Notes

| Reliability Area | AWS | Azure | GCP |
|---|---|---|---|
| Metrics and alerts | CloudWatch | Azure Monitor | Google Cloud Monitoring |
| Logs | CloudWatch Logs | Log Analytics | Cloud Logging |
| Dashboards | CloudWatch Dashboards | Azure Dashboards / Monitor Workbooks | Cloud Monitoring Dashboards |
| Health checks | Route 53 Health Checks | Azure Traffic Manager / Front Door health probes | Cloud Load Balancing health checks |
| Backup | AWS Backup | Azure Backup | Google Cloud Backup and DR |
| DR concepts | Multi-region AWS design | Azure Site Recovery | GCP multi-region and backup/DR patterns |

Teaching point:

```text
The cloud provider names change, but reliability questions stay the same:
Can we detect problems, recover quickly, protect data, and support the system safely?
```

---

## 8. Time-Boxed Instructor Agenda

| Time | Activity |
|---:|---|
| 0:00 to 0:10 | Welcome, Class 1 recap, and why production readiness matters |
| 0:10 to 0:25 | Opening discussion: “What does production-ready mean?” |
| 0:25 to 0:50 | Reliability concepts: availability, latency, errors, saturation |
| 0:50 to 1:10 | SLI/SLO/SLA + error budgets — *framing only* (depth handed to Week 21) |
| 1:10 to 1:20 | Break |
| 1:20 to 1:45 | Alert quality: symptom-based alerting + the availability-vs-AND nuance |
| 1:45 to 2:10 | Demo 12B: build one symptom-based alert end-to-end (Prometheus rule + Alertmanager routing, and the CloudWatch equivalent) |
| 2:10 to 2:25 | Whiteboard: production readiness model for a cloud application |
| 2:25 to 2:50 | Student lab: production readiness checklist + write the alert |
| 2:50 to 2:58 | Discussion and knowledge check |
| 2:58 to 3:00 | Homework explanation and Week 17 / Week 21 preview |

---

## 9. Instructor Lesson Plan

### Step 1: Open the Class

Start by saying:

```text
Today we are moving from “can we deploy it?” to “can we operate it safely in production?”
```

Explain that a system can be technically deployed but still not production-ready.

Ask students:

```text
What could go wrong after an application goes live?
```

Expected answers:

- App goes down
- Users see errors
- Database gets slow
- No one gets alerted
- Team does not know who owns the issue
- Rollback is unclear
- Backups do not work

### Step 2: Connect to Previous Weeks

Remind students:

- Linux helps troubleshoot hosts and services.
- Networking helps diagnose connectivity.
- AWS helps host infrastructure.
- CI/CD helps deliver changes.
- Kubernetes helps run containerized workloads.
- Terraform helps provision infrastructure.
- Monitoring helps detect issues.

Transition:

```text
Reliability combines all of these skills into production operations.
```

### Step 3: Teach Reliability Concepts

Explain four basic reliability signals:

1. Availability
2. Latency
3. Error rate
4. Saturation

Pause and ask:

```text
Which one would a customer notice first?
```

Guide students toward user-impact thinking.

### Step 4: Teach SLI, SLO, SLA, and Error Budget

Use a simple web service example.

Example:

```text
SLI: percentage of successful checkout requests
SLO: 99.5% of checkout requests should succeed over 30 days
SLA: formal business commitment to customers
Error budget: allowed failure before reliability work becomes priority
```

Teaching tip: Do not make the math heavy. Focus on operational decision-making.

### Step 5: Introduce Production Readiness

Explain that production readiness includes monitoring, logging, alerts, ownership, runbooks, backups, restore testing, rollback plan, security, capacity, and cost awareness.

Pause and ask:

```text
Which of these are usually forgotten until an incident happens?
```

### Step 6: Show AWS Reliability Services

Show or explain CloudWatch metrics, CloudWatch logs, CloudWatch alarms, CloudWatch dashboards, Route 53 health checks, and AWS Backup.

Transition:

```text
These tools do not create reliability by themselves. They only help if the team configures and uses them correctly.
```

### Step 7: Whiteboard the Production Readiness Model

Draw a simple cloud application flow:

```text
User -> DNS -> Load Balancer -> App -> Database
```

Then add:

```text
Monitoring, Logs, Alerts, Backups, Runbooks, Ownership
```

### Step 8: Run Instructor Demo

Walk through CloudWatch dashboard and alarm review. Focus on interpretation, not console memorization.

Ask:

```text
Would this alarm help us during a real incident?
```

### Step 9: Run Student Lab

Students complete a readiness checklist for a sample app.

### Step 10: Close the Class

End with:

```text
This week you learned to SEE a system (Class 1: signals, percentiles, RED/USE) and to JUDGE it
(Class 2: production readiness + good alerts). Week 21 (SRE Foundations) builds on this to turn
your alerts into SLO-driven, error-budget-aware paging, and to run real incidents and postmortems.
```

---

## 10. Instructor Lecture Notes

### Reliability Is Not Just Uptime

Students often think reliability means “the system is up.” That is only part of the story.

A system can be technically up but still unreliable if it is too slow, returns errors, drops requests, cannot recover from failure, has missing or noisy alerts, or has backups that were never tested.

Say this out loud:

```text
Production reliability is about user trust. If users cannot complete their work, the system is not reliable, even if the server is technically running.
```

### Availability, Latency, Errors, and Saturation

Use simple examples:

- Availability: Can users reach the service?
- Latency: Is it fast enough?
- Error rate: Are requests succeeding?
- Saturation: Are resources close to limits?

Enterprise context: An internal application may tolerate short downtime during off-hours. A customer-facing checkout system may not. Reliability targets should match business impact.

### SLI, SLO, and SLA

- SLI is the measurement.
- SLO is the target.
- SLA is the formal promise.

Example:

```text
SLI: successful API requests
SLO: 99.5% successful API requests monthly
SLA: contract says customer gets service credit if availability drops below 99.0%
```

Common misconception: Students may think SLA and SLO are the same.

Clarify:

```text
An SLO is usually internal. An SLA is usually external or contractual.
```

> **Hand-off to Week 21.** Keep this at the *framing* level. Do **not** derive error-budget math, burn-rate alerting, or the SLI "menu" here — that is Week 21's job. The one-line teaser you *may* give: "99.9% over 30 days means you can be down about 43 minutes a month; Week 21 turns that budget into alerts that page you only when you're burning it too fast." Then move on.

### Error Budgets

Explain error budgets as a decision tool (framing only — the math and the error-budget *policy* belong to Week 21).

Say:

```text
If the service is healthy and within its error budget, the team may keep releasing features. If the service burns too much error budget, reliability work becomes more important than new features.
```

> **Week 21 will go deep here:** how to compute the budget from the SLO, how *burn-rate alerts* (multi-window, multi-burn-rate) page you when the budget is draining too fast, and what the error-budget *policy* (feature freeze) actually triggers.

### Production Readiness

A production-ready system should answer these questions:

```text
Who owns it?
How do we know it is healthy?
How do we know users are impacted?
Who gets alerted?
What should they do?
Can we roll back?
Can we restore data?
Can we recover from regional or infrastructure failure?
Are secrets protected?
Can we explain cost and capacity?
```

### Alert Quality: Symptom-Based Alerting

This is the heart of Class 2 and the most senior idea in the week.

Poor alert (cause-based, not user-based):

```text
CPU > 70% for 5 minutes
```

Better alert (symptom-based, close to user impact):

```text
p95 latency > 1500 ms AND 5xx error rate > 2% for 10 minutes
```

Why? Because latency and errors are *symptoms users feel*; CPU is a *cause that may or may not matter*. A box can run hot at 90% CPU and serve every request perfectly — paging on that is noise.

#### The availability nuance: don't ONLY use AND

The "latency AND 5xx" formula is good for catching a *degraded* service, but a senior engineer must see its blind spot:

> If the service is completely **down**, it may serve **zero** traffic — so there are **zero** 5xx responses and **no** latency samples. An `AND` of "high latency AND high 5xx" can be silent during a total outage.

So a complete alerting set needs **two complementary alerts**:

1. **Degradation** (the AND): `p95 latency high AND 5xx rate high` — catches "slow and erroring."
2. **Availability** (a separate OR-style signal): a black-box/health-check probe (Route 53 health check, Prometheus `blackbox_exporter`, or "request rate dropped to ~0 / no successful responses") — catches "down with no traffic."

Teach the rule: **alert on the absence of success, not just the presence of errors.**

### AWS Operational View

CloudWatch helps with metrics, logs, alarms, and dashboards; in the OSS world the equivalents are Prometheus alerting rules + Alertmanager. We build the *same* alert in both during the demo and lab.

### Alerting Mechanics: From a Firing Rule to a Human

A good alert *definition* is only half the job. The other half is making sure the right person is notified — once, with context — and not buried in noise. In the Prometheus/Alertmanager model (and conceptually in CloudWatch + SNS + PagerDuty) the moving parts are:

| Mechanic | What it does | Why it matters |
|---|---|---|
| **Severity** | Tags the alert `critical` / `warning` / `info` | `critical` pages a human now; `warning` goes to Slack to look at soon |
| **Routing** | Sends the alert to a receiver based on its labels | `team=payments, severity=critical` → page the payments on-call |
| **Grouping** | Bundles related firing alerts into one notification | 50 pods crash → **one** grouped page, not 50 pages |
| **Inhibition** | Suppresses lower alerts while a higher one fires | "cluster down" suppresses every per-pod alert under it |
| **Silences / maintenance** | Mutes alerts during known work | Don't page during a planned deploy |
| **Runbook link** | Every alert carries a link to its runbook | The 2 AM responder knows *what to do*, not just *that something broke* |

> **Hand-off to Week 21.** On-call rotations, escalation policies, incident command, and blameless postmortems are the *practice* built on top of these mechanics — that is Week 21. Here we make sure a single good alert is correctly defined, routed, and actionable.

### Backups and DR

Say:

```text
A backup that has never been restored is an assumption, not a recovery plan.
```

### Enterprise Context

In enterprise environments, production readiness often involves security review, architecture review, change approval, monitoring standards, support handoff, on-call rotation, runbook approval, backup policy, cost review, and DR classification.

---

## 11. Whiteboard Explanation

### Simple Diagram

```text
                    +----------------------+
                    |        Users         |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |   DNS / Route 53     |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |   Load Balancer      |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Application Service  |
                    | EC2 / EKS / App Pods |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Database / Storage   |
                    | RDS / S3 / EBS       |
                    +----------------------+

        Production Readiness Layer Around the System:
        - Metrics
        - Logs
        - Alerts
        - Dashboards
        - Backups
        - Restore testing
        - Runbooks
        - Rollback plan
        - Ownership
        - Security
        - Cost controls
```

### Step-by-Step Explanation

1. Users interact with the application.
2. DNS or Route 53 directs users to the correct endpoint.
3. Load balancer distributes traffic and checks target health.
4. Application service processes requests.
5. Database or storage stores application data.
6. Monitoring tells the team whether the system is healthy.
7. Alerts notify the team when user impact is likely.
8. Backups and restore testing protect the data.
9. Runbooks guide the team during incidents.
10. Ownership and escalation make sure someone responds.

### Enterprise Version

```text
Customer
  |
  v
Route 53 / DNS
  |
  v
CloudFront / WAF / ALB
  |
  v
EKS or EC2 Application Tier
  |
  v
RDS / S3 / External APIs
  |
  +--> CloudWatch Metrics
  +--> CloudWatch Logs
  +--> Dashboards
  +--> Alarms
  +--> Incident Channel
  +--> Runbooks
  +--> Backup and DR Plan
  +--> Change Management
```

---

## 12. Instructor Demo Script

### Demo Title

**Reviewing Production Readiness Signals in AWS CloudWatch**

### Demo Objective

Show students how to evaluate whether a service has useful reliability signals using CloudWatch metrics, logs, alarms, and dashboards.

### Required Setup

Option A: Live AWS environment with sample EC2, ALB, or application metrics.

Option B: Instructor uses sample data files if AWS access is not available.

Recommended sample CLI validation:

```bash
aws sts get-caller-identity
aws cloudwatch describe-alarms --max-records 5
aws logs describe-log-groups --limit 5
```

### Step 1: Validate AWS Access

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDAEXAMPLE",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student-lab"
}
```

Explain:

```text
Before troubleshooting or reviewing production readiness, always confirm which account and identity you are using.
```

### Step 2: Open CloudWatch Metrics

Console path:

```text
AWS Console -> CloudWatch -> Metrics
```

Show metrics for EC2 CPUUtilization, ALB RequestCount, ALB TargetResponseTime, and ALB HTTPCode_Target_5XX_Count.

### Step 3: Review CloudWatch Logs

Console path:

```text
CloudWatch -> Logs -> Log groups
```

Sample logs:

```text
2026-04-26T10:01:11Z INFO request_id=abc123 path=/checkout status=200 latency_ms=240
2026-04-26T10:04:32Z ERROR request_id=def456 path=/checkout status=500 error="database timeout"
2026-04-26T10:05:05Z WARN request_id=ghi789 path=/checkout latency_ms=1850
```

### Step 4: Review Alarms

```bash
aws cloudwatch describe-alarms --max-records 10
```

Expected partial output:

```json
{
  "MetricAlarms": [
    {
      "AlarmName": "High-5xx-Error-Rate",
      "StateValue": "OK",
      "MetricName": "HTTPCode_Target_5XX_Count",
      "Namespace": "AWS/ApplicationELB"
    }
  ]
}
```

Ask:

```text
Is this alarm connected to user impact?
Would it help us during an incident?
Is the threshold clear?
Who receives the alert?
```

### Step 5: Review a Dashboard

Console path:

```text
CloudWatch -> Dashboards
```

Show availability, latency, error rate, traffic, and resource saturation.

### Step 6: Introduce Route 53 Health Checks

Console path:

```text
Route 53 -> Health checks
```

### Step 7: Introduce AWS Backup

Console path:

```text
AWS Backup -> Backup plans
```

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| AWS CLI not authenticated | Missing credentials or wrong profile | Run `aws configure` or set correct profile |
| No CloudWatch metrics visible | No active resources or wrong region | Switch region or use sample data |
| No log groups | App not configured to send logs | Use sample logs |
| Access denied | IAM permissions too limited | Use instructor account or screenshots |
| CloudWatch dashboard missing | Not created yet | Build discussion around sample dashboard |

### Cleanup Steps

If instructor creates a demo alarm or dashboard:

```bash
aws cloudwatch delete-alarms --alarm-names "demo-high-latency"
aws cloudwatch delete-dashboards --dashboard-names "week16-demo-dashboard"
```

Cost warning:

```text
CloudWatch dashboards, custom metrics, alarms, logs, and retained log data may create cost. Keep lab resources small and clean up demo artifacts.
```

---

## 12B. Instructor Demo Script — Build One Symptom-Based Alert End-to-End

The point of this demo is that students should not just *inspect* an alarm — they should *author* a good one. We build the same symptom-based alert in **both** stacks, then route it.

### Part A: Prometheus alerting rule + Alertmanager (OSS, no cloud cost)

This extends the Prometheus/Grafana stack from Class 1.

A symptom-based alert rule (degradation):

```yaml
# alert.rules.yml
groups:
  - name: checkout-red
    rules:
      # DEGRADATION: slow AND erroring
      - alert: CheckoutDegraded
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket{endpoint="/checkout"}[5m])) by (le)) > 1.5
          and
          (sum(rate(http_requests_total{endpoint="/checkout",status="500"}[5m]))
             / sum(rate(http_requests_total{endpoint="/checkout"}[5m]))) > 0.02
        for: 10m
        labels:
          severity: critical
          team: payments
        annotations:
          summary: "Checkout is slow and erroring (p95 > 1.5s, 5xx > 2%)"
          runbook: "https://runbooks.example.com/checkout-degraded"

      # AVAILABILITY: traffic collapsed (catches a total outage with no errors)
      - alert: CheckoutNoTraffic
        expr: sum(rate(http_requests_total{endpoint="/checkout"}[5m])) < 0.01
        for: 5m
        labels:
          severity: critical
          team: payments
        annotations:
          summary: "Checkout receiving ~no traffic — possible total outage"
          runbook: "https://runbooks.example.com/checkout-no-traffic"
```

Point out the two rules embody the availability-vs-AND nuance from the lecture.

Wire the rule file into Prometheus and add Alertmanager:

```yaml
# prometheus.yml (additions)
rule_files:
  - /etc/prometheus/alert.rules.yml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]
```

```yaml
# alertmanager.yml — routing, grouping, inhibition
route:
  group_by: ["alertname", "team"]      # GROUPING: collapse related alerts
  group_wait: 30s
  group_interval: 5m
  receiver: slack-default
  routes:
    - matchers: [ 'severity="critical"' ]   # ROUTING by severity
      receiver: pagerduty-oncall
receivers:
  - name: slack-default
    slack_configs:
      - channel: "#alerts"
        api_url: "https://hooks.slack.com/services/REPLACE/ME"
  - name: pagerduty-oncall
    pagerduty_configs:
      - routing_key: "REPLACE_WITH_PD_ROUTING_KEY"
inhibit_rules:                          # INHIBITION
  - source_matchers: [ 'alertname="CheckoutNoTraffic"' ]
    target_matchers: [ 'alertname="CheckoutDegraded"' ]
    equal: ["team"]
```

```bash
# add alertmanager to docker-compose, then:
docker compose up -d
# Trigger the degradation rule by raising error/latency, then watch it fire:
#   Prometheus UI -> Alerts (http://localhost:9090/alerts)
#   Alertmanager UI -> grouped notifications (http://localhost:9093)
```

Explain at each UI: a rule goes **pending** during its `for:` window, then **firing**; Alertmanager then **groups**, **routes** by severity, and **inhibits** the degraded alert when the no-traffic alert is active.

### Part B: The same alert as a CloudWatch alarm (AWS-managed)

```bash
# 5xx error-rate alarm wired to an SNS topic that on-call is subscribed to.
aws sns create-topic --name oncall-critical --region "$AWS_REGION"
# (subscribe a real endpoint, e.g. an email or PagerDuty integration, to the topic)

aws cloudwatch put-metric-alarm \
  --alarm-name "Checkout-5xx-High" \
  --alarm-description "5xx error count high for checkout ALB target group" \
  --namespace "AWS/ApplicationELB" \
  --metric-name "HTTPCode_Target_5XX_Count" \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "arn:aws:sns:${AWS_REGION}:123456789012:oncall-critical" \
  --region "$AWS_REGION"
```

Discuss `--treat-missing-data`: choosing `notBreaching` vs `breaching` is the CloudWatch equivalent of the availability nuance — decide deliberately what "no data" means for a down service.

### Cleanup (Part B)

```bash
aws cloudwatch delete-alarms --alarm-names "Checkout-5xx-High" --region "$AWS_REGION"
aws sns delete-topic --topic-arn "arn:aws:sns:${AWS_REGION}:123456789012:oncall-critical" --region "$AWS_REGION"
docker compose down -v   # Part A
```

> **Cost/security note:** the SNS topic and alarm are low-cost but real — delete them. Never commit a real Slack webhook or PagerDuty routing key; use a placeholder or a secret reference (Secrets Manager / env var), consistent with Week 6.

---

## 13. Student Lab Manual

### Lab Title

**Create a Production Readiness Checklist for a Cloud Application**

### Lab Objective

Students will evaluate a sample cloud application and document whether it is ready for production.

### Estimated Time

35 to 45 minutes

### Student Prerequisites

Students should understand basic AWS services, monitoring terms, application architecture, incident concepts, and Markdown editing.

### Architecture or Workflow Overview

```text
Users
  |
  v
Route 53 DNS
  |
  v
Application Load Balancer
  |
  v
Application running on EC2 or Kubernetes
  |
  v
RDS database
  |
  v
CloudWatch metrics and logs
```

Current known state:

```text
- Application is deployed
- Basic CPU alarm exists
- Logs are being collected
- No formal runbook exists
- Backups are enabled but restore has not been tested
- Rollback process is manual
- Ownership is unclear after business hours
```

### Step-by-Step Student Instructions

#### Step 1: Create Lab Folder

```bash
mkdir -p week16-class2/readiness-lab
cd week16-class2/readiness-lab
```

#### Step 2: Create Checklist File

```bash
touch production-readiness-checklist.md
code production-readiness-checklist.md
```

#### Step 3: Add Checklist Template

```markdown
# Production Readiness Checklist

## Application Name
Sample Customer Web Application

## Business Purpose
This application supports customer-facing transactions during business hours.

## Readiness Review

| Area | Current Status | Risk | Recommendation | Owner |
|---|---|---|---|---|
| Monitoring |  |  |  |  |
| Logging |  |  |  |  |
| Alerting |  |  |  |  |
| Dashboard |  |  |  |  |
| Backup |  |  |  |  |
| Restore Testing |  |  |  |  |
| Rollback Plan |  |  |  |  |
| Runbook |  |  |  |  |
| Security and IAM |  |  |  |  |
| Secrets |  |  |  |  |
| Capacity |  |  |  |  |
| Cost |  |  |  |  |
| Ownership |  |  |  |  |
| DR |  |  |  |  |

## Top 5 Risks

1.
2.
3.
4.
5.

## Recommended Go-Live Decision

Choose one:
- Ready for production
- Ready with conditions
- Not ready

## Explanation

Write 5 to 8 sentences explaining your decision.
```

#### Step 4: Review Sample Evidence

```text
Application: Customer Web Portal
Environment: AWS
Compute: EC2 or EKS
Database: RDS
Monitoring: CloudWatch basic metrics
Logs: Application logs available
Alerting: CPU alarm only
Backups: RDS automated backups enabled
Restore test: Not performed
Runbook: Missing
Rollback: Manual and undocumented
On-call: Not defined
Dashboard: Basic infrastructure dashboard only
Security: IAM roles configured, but access review not completed
Secrets: Stored in Secrets Manager
DR: No tested DR plan
```

#### Step 5: Fill Out Checklist

Example:

```markdown
| Alerting | CPU alarm only | App errors may be missed | Add latency, 5xx, availability, and database connection alarms | SRE / DevOps |
```

#### Step 6: Identify Top 5 Risks

Recommended risks:

```text
1. No runbook
2. No restore testing
3. Alerting only covers CPU
4. Rollback process is manual and undocumented
5. No defined on-call or escalation owner
```

#### Step 7: Make Go-Live Recommendation

Choose one:

```text
Ready for production
Ready with conditions
Not ready
```

#### Step 8: Optional AWS CLI Review

```bash
aws cloudwatch describe-alarms --max-records 5
aws logs describe-log-groups --limit 5
aws backup list-backup-plans
```

### Validation Checklist

- [ ] Checklist file exists
- [ ] All readiness areas are filled in
- [ ] Top 5 risks are identified
- [ ] Go-live recommendation is included
- [ ] Recommendations are specific
- [ ] At least one monitoring improvement is included
- [ ] At least one backup or restore improvement is included
- [ ] At least one ownership or escalation improvement is included

### Troubleshooting Tips

| Issue | Likely Cause | Fix |
|---|---|---|
| `code` command not found | VS Code shell command not installed | Open file manually in VS Code |
| AWS CLI access denied | Missing permissions | Continue with sample evidence |
| Empty CloudWatch results | Wrong region or no resources | Change region or use sample data |
| Unsure what to write | Thinking only technically | Consider operations, ownership, and recovery |

### Cleanup Steps

```bash
cd ..
rm -rf readiness-lab
```

Only clean up if instructor says the lab files do not need to be submitted.

### Reflection Questions

1. What is the biggest production risk in the sample application?
2. Why is CPU-only alerting not enough?
3. Why does restore testing matter?
4. Who should own the runbook?
5. Would you approve this system for production? Why or why not?

### Optional Challenge Task

Create an improved CloudWatch alarm strategy with at least five alarms:

```text
1. High 5xx error rate
2. High p95 latency
3. Low healthy target count
4. High database connections
5. Backup failure or missing backup
```

### Optional Challenge Task — Write the Alert in the OSS Stack

Using the stack from Class 1's Demo 12B, write a Prometheus alerting rule for the **degradation** symptom (p95 latency high AND 5xx rate high) **and** a separate **availability** rule (request rate ≈ 0), then add an Alertmanager route that pages `severity=critical` and Slacks `severity=warning`. Explain in two sentences why you need *both* the degradation and the availability rule (the availability-vs-AND nuance). Tear down with `docker compose down -v`.

---

## 14. Troubleshooting Activity

### Incident or Problem Title

**Production Readiness Review Finds Service Is Not Operationally Ready**

### Business Impact

A customer-facing application is scheduled to launch next week. If launched without readiness gaps fixed, the business may experience missed incidents, long recovery time, customer complaints, data recovery risk, confusion about ownership, and failed rollback during release problems.

### Symptoms

```text
- Application is deployed and reachable
- Only CPU monitoring exists
- No latency or error-rate alarm exists
- RDS backups exist but restore was never tested
- No runbook exists
- Rollback process is manual
- No clear after-hours owner
- Dashboard does not show user impact
```

### Starting Evidence

```text
CloudWatch Alarm:
AlarmName: HighCPU
Metric: CPUUtilization
Threshold: GreaterThan 80%
Period: 5 minutes
Notification: Unknown

Application Logs:
INFO /login 200 latency=220ms
INFO /checkout 200 latency=340ms
WARN /checkout 200 latency=1800ms
ERROR /checkout 500 error="database timeout"

Backup:
RDS automated backups enabled
Retention: 7 days
Last restore test: never

Runbook:
Missing

Rollback:
Manual redeploy required
No documented steps
```

### Student Investigation Steps

1. Identify what is currently monitored.
2. Identify what user-impact signals are missing.
3. Review whether logs are useful.
4. Review backup and restore readiness.
5. Review rollback readiness.
6. Identify ownership and escalation gaps.
7. Decide whether production launch should proceed.
8. Recommend immediate fixes before launch.

### Expected Root Cause

The system is deployed but not production-ready because operational readiness controls are incomplete.

Main root causes:

```text
- Monitoring focuses only on infrastructure CPU, not user impact
- Backup exists but restore has not been validated
- No runbook or rollback documentation exists
- No clear support ownership or escalation process exists
```

### Correct Resolution

Before production launch, the team should add user-impact alarms, create a dashboard, write a runbook, test database restore, document rollback, assign support ownership, review IAM and secrets access, and define basic SLOs.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Only increasing CPU threshold | Does not address missing user-impact monitoring |
| Assuming backups are fine because they are enabled | Restore has not been tested |
| Saying the app is ready because it responds to HTTP | Production readiness requires supportability |
| Adding more dashboards without alerts | Dashboards help only when someone knows to look |
| Ignoring ownership | Incidents fail when no one knows who should respond |

### Instructor Hints

```text
Hint 1: What would users notice first?
Hint 2: If the database failed, how would the team recover?
Hint 3: Who gets notified when the service is unhealthy?
Hint 4: Could a new engineer follow a document to fix this issue?
Hint 5: Is CPU enough to tell whether checkout is working?
```

### Preventive Action

Create a production readiness review process before every major launch. Include monitoring review, alert review, backup and restore validation, runbook review, rollback validation, ownership confirmation, security review, and cost and capacity review.

---

## 15. Scenario-Based Discussion Questions

1. **A service has 99.9% uptime but users often complain that it is slow. Is the service reliable?**
   - Expected themes: Uptime alone is not enough; latency affects user experience.
   - Follow-up: What SLI would better capture the user experience?

2. **The product team wants 100% availability. How should an engineering team respond?**
   - Expected themes: 100% availability is usually unrealistic; higher reliability costs more.
   - Follow-up: What tradeoffs come with moving from 99.9% to 99.99%?

3. **The only alert for a production app is CPU above 80%. What is missing?**
   - Expected themes: Error rate, latency, availability, healthy host count, database metrics.
   - Follow-up: Which alert would best represent customer impact?

4. **A backup policy exists, but no one has tested restore. Is the data protected?**
   - Expected themes: Not fully; backup without restore testing is risky.
   - Follow-up: How often should restore testing happen for a critical system?

5. **Who should own production readiness: developers, DevOps, Cloud Engineering, or SRE?**
   - Expected themes: Shared responsibility.
   - Follow-up: What should each team own before go-live?

6. **Should a team launch if monitoring is incomplete but the business deadline is urgent?**
   - Expected themes: Depends on business risk; known risks must be documented.
   - Follow-up: What minimum controls would you require before launch?

7. **An alert fires every night but no real issue occurs. What should the team do?**
   - Expected themes: Tune threshold, check actionability, avoid alert fatigue.
   - Follow-up: What makes an alert actionable?

8. **A dashboard has 40 graphs. During an incident, engineers still cannot find the issue. What went wrong?**
   - Expected themes: Dashboard is overloaded and does not prioritize user impact.
   - Follow-up: What 5 metrics should be at the top of a useful service dashboard?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

1. **Which term describes a measurable signal of service behavior?**
   - A. SLA
   - B. SLO
   - C. SLI
   - D. Runbook
   - **Answer:** C
   - **Explanation:** An SLI is a Service Level Indicator.

2. **Which AWS service is most directly used for metrics, logs, alarms, and dashboards?**
   - A. IAM
   - B. CloudWatch
   - C. Route 53
   - D. AWS Backup
   - **Answer:** B
   - **Explanation:** CloudWatch provides AWS metrics, logs, alarms, and dashboards.

3. **True or False: A service is production-ready as soon as it is successfully deployed.**
   - **Answer:** False
   - **Explanation:** Production readiness requires monitoring, alerts, rollback, backups, runbooks, ownership, and support readiness.

4. **Which metric is closest to user impact for a web application?**
   - A. CPU utilization
   - B. Disk size
   - C. p95 latency
   - D. Number of IAM users
   - **Answer:** C
   - **Explanation:** p95 latency shows how slow requests are for users.

5. **What is the difference between an SLO and an SLA?**
   - **Answer:** An SLO is an internal reliability target. An SLA is a formal agreement or promise.
   - **Explanation:** SLOs are usually internal, while SLAs are usually contractual.

6. **Which readiness gap is most dangerous for data recovery?**
   - A. Missing dashboard color theme
   - B. Backup enabled but restore never tested
   - C. Too many Git branches
   - D. Low CPU usage
   - **Answer:** B
   - **Explanation:** Backups are only useful if the team can restore from them.

7. **A service has a CPU alarm, but users are seeing checkout failures. What additional alerts should be considered?**
   - **Answer:** HTTP 5xx rate, checkout failure rate, p95 latency, healthy target count, database connection saturation, and availability checks.
   - **Explanation:** CPU alone may not detect user-facing failures.

8. **True or False: An error budget helps teams balance feature delivery and reliability work.**
   - **Answer:** True
   - **Explanation:** If too much error budget is consumed, reliability work becomes a higher priority.

9. **What is one use of Route 53 health checks?**
   - **Answer:** Route 53 health checks can monitor endpoint health and support DNS-based failover patterns.
   - **Explanation:** They help detect whether an endpoint is healthy from a DNS routing perspective.

10. **A dashboard shows CPU, memory, and disk, but no error rate or latency. What is the problem?**
    - **Answer:** It focuses only on infrastructure health and does not show whether users are impacted.
    - **Explanation:** A production dashboard should include user-impact indicators.

11. **What should a runbook include?**
    - A. Only the application logo
    - B. Symptoms, investigation steps, escalation, recovery, and validation
    - C. Only the developer’s name
    - D. Only monthly cost data
    - **Answer:** B
    - **Explanation:** A runbook guides responders during operational issues.

12. **Why is ownership important for production readiness?**
    - **Answer:** Someone must be responsible for alerts, decisions, escalation, and maintenance.
    - **Explanation:** Without ownership, incidents can be delayed or ignored.

---

## 17. Homework Assignment

### Assignment Title

**Production Readiness Checklist for a Cloud Application**

### Scenario

Your team is preparing to launch a customer-facing application hosted on AWS. The app is deployed and working in a test environment, but leadership wants to know whether it is ready for production.

The architecture includes:

```text
Route 53 -> Application Load Balancer -> App Tier -> RDS Database
```

Current setup:

```text
- Basic CloudWatch metrics
- CPU alarm only
- RDS backups enabled
- No restore test
- No formal runbook
- Manual rollback
- No documented on-call owner
- Secrets stored in AWS Secrets Manager
```

### Student Tasks

Create a production readiness checklist covering monitoring, logging, alerting, dashboards, backup, restore testing, rollback, runbooks, security and IAM, secrets, capacity, cost, ownership, and DR.

### Expected Deliverables

Submit:

1. Completed production readiness checklist
2. Top 5 production risks
3. Go-live recommendation
4. 5 to 8 sentence explanation
5. At least 3 recommended alerts — and for **one** of them, write the actual **symptom-based alert definition** (a Prometheus alerting rule OR a CloudWatch `put-metric-alarm` command), plus a one-sentence note on its severity/routing
6. One sentence explaining how you would *also* detect a total outage that produces no errors (the availability-vs-AND nuance)
7. At least 3 recommended runbook sections

### Submission Format

```text
week16-class2-production-readiness-[student-name].md
```

### Estimated Completion Time

60 to 90 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Checklist completeness | 25 |
| Quality of risk identification | 20 |
| Practical recommendations | 20 |
| Understanding of reliability concepts | 15 |
| AWS relevance | 10 |
| Clarity and professionalism | 10 |
| Total | 100 |

### Optional Advanced Challenge

Propose three candidate SLIs and three draft SLOs for the service (framing only), and one basic DR recommendation with RTO and RPO. Note where each SLO would be turned into a *burn-rate alert* — and flag that the error-budget math and burn-rate alerting are developed in **Week 21 (SRE Foundations)**.

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking deployed means production-ready | Students focus on build and deploy success | Reinforce operational readiness checklist |
| Choosing only CPU alerts | CPU is easy to understand | Teach user-impact metrics like latency and error rate |
| Ignoring restore testing | Students assume backup means recovery | Explain that restore proves backup usefulness |
| Writing vague recommendations | Beginners may say “improve monitoring” | Require specific metrics, alarms, and owners |
| Forgetting ownership | Students focus only on tools | Ask “who responds at 2 AM?” |
| Confusing SLA, SLI, and SLO | Terms sound similar | Use repeated simple examples |
| Making dashboards too large | Students think more graphs equal better visibility | Teach service-level dashboard design |
| Ignoring cost | Reliability improvements can increase cost | Include cost and business tradeoffs |
| Ignoring security | Monitoring and access often require permissions | Include IAM and least privilege review |
| Treating Azure/GCP as separate courses | Multi-cloud comparisons can distract | Keep AWS first and compare only when useful |

---

## 19. Real-World Enterprise Scenario

### Scenario

A logistics company is preparing to launch a customer shipment tracking portal. The application is hosted on AWS and supports both internal users and external customers.

Architecture:

```text
Route 53 -> Public ALB -> Application Tier on EKS -> RDS PostgreSQL -> S3 for documents
```

### Constraints

- Production launch is scheduled for next Monday.
- Security team requires IAM least privilege and secrets stored outside code.
- Operations team requires CloudWatch dashboards and alarms.
- Database team requires backup and restore validation.
- Business team requires support during peak hours.
- Change management requires rollback documentation.
- Cloud team wants to avoid unnecessary costs from over-alerting and oversized resources.
- SRE team requires a runbook and incident escalation path.

### How This Class Topic Applies

Students must evaluate observability, alerts, recoverability, rollback documentation, support ownership, secrets handling, and reliability targets.

### Role Responsibilities

| Role | Responsibility |
|---|---|
| DevOps Engineer | Ensures deployment, rollback, pipeline, and release readiness |
| Cloud Engineer | Validates infrastructure, networking, backups, IAM, and cost controls |
| SRE | Defines SLIs/SLOs, alerting, dashboards, runbooks, and incident response process |

---

## 20. Instructor Tips

### Teaching Tips

- Keep definitions simple and repeat them.
- Use user-impact examples instead of abstract reliability theory.
- Ask students what customers would notice.
- Show that reliability is a team responsibility.
- Avoid going too deep into SLO math in Class 1.

### Pacing Tips

- Do not let SLAs, SLOs, and error budgets consume the entire class.
- Keep Azure/GCP comparisons short.
- Reserve incident response and SLO/burn-rate depth for Week 21 (SRE Foundations).
- Spend enough time on the checklist because it is the main student deliverable.

### Lab Support Tips

- Some students may struggle with what to write in the checklist.
- Give them examples of specific risks and recommendations.
- Encourage practical answers over perfect terminology.
- Pair stronger students with students who need help.

### How to Help Struggling Students

Ask guiding questions:

```text
How would you know the app is down?
Who would get alerted?
What would you check first?
Can you recover the database?
Where are the rollback steps?
```

### How to Challenge Advanced Students

Ask advanced students to define actual SLIs/SLOs, propose alert thresholds, add RTO/RPO, design a dashboard layout, create a risk-based go-live recommendation, and compare AWS design with Azure or GCP equivalents.

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] Reliability
- [ ] Availability
- [ ] Latency
- [ ] Error rate
- [ ] SLI
- [ ] SLO
- [ ] SLA
- [ ] Error budget
- [ ] Production readiness
- [ ] Backup vs restore
- [ ] Basic RTO and RPO concepts
- [ ] Why CPU-only alerting is not enough

### Students Should Be Able to Build or Configure

- [ ] A production readiness checklist
- [ ] A basic monitoring recommendation
- [ ] A basic alerting recommendation
- [ ] A dashboard improvement plan
- [ ] A backup and restore validation recommendation
- [ ] A go-live risk summary

### Students Should Be Able to Troubleshoot

- [ ] Missing monitoring coverage
- [ ] Poor alert design
- [ ] Unclear ownership
- [ ] Missing rollback plan
- [ ] Backup without restore testing
- [ ] Dashboard that does not show user impact
- [ ] Production readiness gaps before launch

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Students understand the difference between deployed and production-ready
- [ ] Students can explain SLI, SLO, SLA, and error budget
- [ ] Students reviewed AWS CloudWatch reliability signals
- [ ] Students completed or started the readiness checklist
- [ ] Students identified top production risks
- [ ] Students understand homework expectations
- [ ] Students know Week 21 (SRE Foundations) goes deep on SLO/error-budget alerting, incident response, and postmortems

### Student Checklist Before Leaving Class

- [ ] I can explain what production readiness means
- [ ] I can explain at least three SLIs
- [ ] I can describe why SLOs matter
- [ ] I can identify weak alerting
- [ ] I can explain why restore testing matters
- [ ] I started my production readiness checklist
- [ ] I understand the homework deliverable
- [ ] I can write one good symptom-based alert (Prometheus rule and/or CloudWatch alarm)
- [ ] I understand that the incident simulation and SLO/burn-rate alerting come in Week 21

### Items to Verify Before Closing the Week

Students should have:

- [ ] Completed production readiness checklist draft
- [ ] Identified at least five risks
- [ ] Written a go-live recommendation
- [ ] Written at least one good symptom-based alert (Prometheus rule and/or CloudWatch alarm)
- [ ] Understood basic incident vocabulary
- [ ] Understood that Week 21 (SRE Foundations) will simulate a production incident and add SLO/burn-rate alerting
- [ ] Reviewed both the OSS stack (Prometheus/Grafana/Alertmanager) and CloudWatch reliability signals

---

## 24. End-of-Week Summary

### What Students Learned This Week

- **Class 1 (Observability Foundations):** how to *see* a system — the three pillars (logs/metrics/traces), the four metric types (counter/gauge/histogram/summary), why latency must be reported as **percentiles (p95/p99)** and never as an average, the **RED** and **USE** methods, **cardinality**/cost hygiene, and the portable OSS stack (Prometheus, Grafana, Loki, Tempo, OpenTelemetry) alongside CloudWatch.
- **Class 2 (Reliability, Production Readiness, and Alerting):** how to *judge* a system — reliability framing (SLI/SLO/SLA/error budget at the vocabulary level), the deployed-vs-production-ready distinction, a production-readiness checklist and go-live decision, and **alert quality**: symptom-based alerting, the availability-vs-AND nuance, and alert mechanics (severity, routing, grouping, inhibition) built end-to-end in Prometheus/Alertmanager and CloudWatch.

### How Class 1 and Class 2 Connect

Class 1 produces the **signals**; Class 2 decides **which signals should page a human** and whether the service is **safe to operate**. Good alerts are impossible without good metrics — which is why observability comes first.

### How This Week Prepares Students for What Comes Next

This week is the on-ramp to **Week 21 (SRE Foundations)**, which takes the signals and alerts built here and adds the reliability *engineering*: choosing SLIs, computing error budgets, **multi-window multi-burn-rate** alerting, SLO-as-code (OpenSLO/Sloth/Nobl9), on-call rotations, incident command, and blameless postmortems. The metrics and alerting skills also feed **Week 22 (Performance, Capacity & Scalability)**.

### What Students Should Review Before the Next Module

- The four metric types and how `histogram_quantile` derives a percentile.
- The RED and USE methods.
- Why an average hides the tail, and why an `AND`-only alert can miss a total outage.
- The structure of a production-readiness checklist.

---

## Class Artifacts & Validation

This class *authors* alerts, so its load-bearing artifacts are the Prometheus alerting
rules in [`labs/observability/`](../../labs/observability/) — and, critically, the
**behavioral** test and the **broken fixture** that prove an alert fires when it should and
that a plausible-looking alert can be silently wrong (the availability-vs-`AND` nuance from
§10/§14). The §13 lab ships a reusable **production-readiness checklist** document; the §12B
CloudWatch alarm + SNS topic are created live against the student's own AWS account. The
multi-window/multi-burn-rate *depth* is owned by Week 21, but the rule files and behavioral
test already exist on disk and pass here. All paths below exist; every command was run in
this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/observability/solution/prometheus/rules/alerting.rules.yml | monitoring (PromQL) | Symptom-based / multi-burn-rate alerting rules (the §12B `CheckoutDegraded`-style rules realized on disk) (Obj. 4) | `promtool check rules` | PASS (3 rules) |
| 2 | labs/observability/solution/prometheus/prometheus.yml | monitoring | Config that wires in the rule files (the §12B `rule_files`/`alerting` additions) (Obj. 4) | `promtool check config` | PASS (2 rule files, valid syntax) |
| 3 | labs/observability/tests/alerting_test.yaml | monitoring (promtool unit test) | Behavioral test — fast-burn alert **fires** on a sustained 5% error series, stays silent when healthy (Obj. 4) | `promtool test rules tests/alerting_test.yaml` | PASS (SUCCESS) |
| 4 | labs/observability/tests/check_rules.py | python | Semantic linter — rejects single-window and absolute-threshold alerts (encodes the availability-vs-`AND` nuance) (Obj. 4) | `python3 tests/check_rules.py solution/prometheus/rules/alerting.rules.yml` | PASS (accepts solution) |
| 5 | labs/observability/broken/alerting.rules.broken.yml | monitoring (fixture) | Reproducible **broken** alert with two injected faults (never-fires + flaps) for the §14 troubleshooting drill | `python3 tests/check_rules.py broken/alerting.rules.broken.yml` (must FAIL) + `promtool check rules` (passes — syntax only) | PASS (correctly rejected by linter; passes promtool by design) |
| 6 | 01-foundation-track/week-16-observability-and-reliability/class-02.md §13 (production-readiness checklist template) | document (reusable) | The readiness review table + Top-5-risks + go-live decision template the student fills in (Obj. 7) | student completes `production-readiness-checklist.md`; answer key in §13 / §16 | PASS (template + answer key present) |

The §12B CloudWatch alarm (`Checkout-5xx-High`) and `oncall-critical` SNS topic are created
live via the AWS CLI against the student's account and **deleted in the §12B cleanup**
(`delete-alarms` / `delete-topic`). `labs/observability/validate.sh` exits `0` (**38 passed,
0 failed**, 2 DEFERRED: `otelcol`/`oslo`). The sibling [`labs/observability-stack/`](../../labs/observability-stack/)
proves the same burn-rate alert loads and fires on a **live kind cluster**
(`LIVE-OBS-EVIDENCE.txt` lists `SampleApiErrorBudgetBurnFast/Slow` as loaded alerts).

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — Prometheus alerting rules + config + behavioral test, a semantic linter, a broken fixture, and a reusable readiness-checklist document, not just fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (`promtool check rules/config`, `promtool test rules`, `check_rules.py` — all PASS; the CloudWatch alarm is a live AWS-CLI op the student runs and tears down).
- [x] Lab has **starter** (alerting exprs TODO'd) and **solution** (reference) versions in `labs/observability/`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes**.
- [x] **Cleanup/teardown** is provided and idempotent — the §12B cleanup deletes the CloudWatch alarm and SNS topic; the readiness lab is a local Markdown file (`docker compose down -v` for the optional Part A stack).
- [x] **Instructor answer key** exists — `labs/observability/solution/`, the §16 quiz answer key, and the §13 readiness-checklist worked answer.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/observability/broken/alerting.rules.broken.yml` (never-fires + flaps faults), diagnosed in §14.
- [x] **Expected outputs** are shown — `promtool test rules` → `SUCCESS`, the linter's PASS/FAIL lines, and the §13 filled-in checklist exemplar.
- [x] **Cost & security warnings** present — §12B warns the SNS topic/alarm are real (delete them) and never to commit a Slack webhook or PagerDuty routing key; lab README adds least-privilege/no-secrets notes.
- [x] **Cross-references** to the module repo and to Class 1 / Week 21 (which owns the SLO/burn-rate depth) are correct (numbers verified).
- [x] The **artifact manifest** (§4.2) above is present and every path resolves (`ls`-verified).
