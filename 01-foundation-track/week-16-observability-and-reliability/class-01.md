# Week 16, Class 1: Observability Foundations — Logs, Metrics, and Dashboards

**Week:** 16 — Observability and Reliability
**Class:** 1 of 2
**Track:** Unified DevOps · Cloud · SRE Track

> **▶ Runnable lab for this class:** [`labs/observability/`](../../labs/observability/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## 1. Class Overview

### Class Title

**Class 16.1: Observability Foundations: Logs, Metrics, and Dashboards**

### Class Purpose

This class introduces students to the practical foundations of observability. Students learn how logs, metrics, dashboards, and traces help teams understand application health, troubleshoot production issues, and reduce guesswork during incidents.

The class teaches the **open-source observability stack** that defines the modern SRE/platform role — **Prometheus** (metrics), **Grafana** (dashboards), **Loki** (logs), **Tempo** (traces), and **OpenTelemetry** (vendor-neutral instrumentation) — and uses **Amazon CloudWatch** as the AWS-managed comparison. Azure Monitor and Google Cloud Monitoring are noted briefly as equivalents.

> **Why both?** In 2026 you will meet the Prometheus/Grafana/OpenTelemetry stack in almost every Kubernetes shop (it is what you deployed conceptually in Weeks 11-13), and CloudWatch in almost every AWS account. A senior engineer can move between them because the *concepts* — metric types, percentiles, scraping, dashboards that answer operational questions — are identical. We teach the concepts on the OSS stack and map them to CloudWatch.

### How This Class Connects to the Overall Course

This class builds on earlier course topics:

- **Linux:** Students already understand logs, processes, and system checks.
- **Networking:** Students understand request flow, ports, DNS, and HTTP behavior.
- **AWS:** Students know basic AWS Console and CLI usage.
- **Docker/Kubernetes (Weeks 10-12):** Students have deployed applications and now need to monitor them; `kube-prometheus-stack` ties directly back to Helm (Week 13).
- **Terraform/Cloud Security (Weeks 14-15, 6):** Students understand infrastructure changes and access control.
- **Class 2 of this week:** Prepares students for reliability framing, production readiness, and alerting quality.
- **Week 21 (SRE Foundations):** This week gives students the signals (metrics, logs, traces, percentiles) that Week 21 turns into SLIs/SLOs, error budgets, and burn-rate alerting. We deliberately stop at *measurement* here and hand the *reliability math* to Week 21.

### What Students Will Build, Analyze, or Practice

Students will:

- Distinguish the four core metric types (counter, gauge, histogram, summary) and derive percentiles (p50/p95/p99) from a histogram.
- Run a Prometheus + Grafana stack, scrape a real `/metrics` endpoint, and write basic PromQL using the RED method.
- Instrument a request path with OpenTelemetry and view a distributed trace.
- Inspect application-style logs (CloudWatch Logs and Loki) and design a Grafana/CloudWatch dashboard that answers operational questions.
- Identify visibility gaps and cardinality/cost risks in an application.
- Practice troubleshooting a “slow application” scenario using logs and metrics.

---

## 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the difference between monitoring and observability.
2. **Compare** logs, metrics, and traces and describe when each is useful.
3. **Distinguish** the four metric types (counter, gauge, histogram, summary) and **explain** why percentiles (p95/p99) are derived from histograms, not from averages.
4. **Scrape** a real `/metrics` endpoint with Prometheus and **write** RED-method PromQL queries; **build** a Grafana dashboard.
5. **Instrument** a request path with OpenTelemetry and **inspect** a distributed trace.
6. **Inspect** application logs (CloudWatch Logs / Loki) and **publish/review** correct metrics.
7. **Troubleshoot** a visibility gap when an application is slow but the root cause is unclear.
8. **Explain** cardinality and label hygiene as the primary cost/operational risk in metrics systems.
9. **Compare** the OSS stack with CloudWatch, Azure Monitor, and Google Cloud Monitoring.

---

## 3. Prerequisites Students Should Already Know

### Required Prior Concepts

Students should already understand:

- Basic Linux commands
- Basic application request flow
- HTTP status codes such as 200, 404, 500
- Basic AWS Console navigation
- Basic AWS CLI usage
- Basic cloud resource concepts
- Basic troubleshooting mindset

### Required Tools Already Installed

Students should have:

- VS Code
- Terminal or shell
- AWS CLI
- Git
- Browser
- Text editor
- Optional: jq

### Required Accounts or Access

Students need:

- AWS account access
- Permissions to use CloudWatch Logs, Metrics, and Dashboards
- IAM permissions for:
  - `logs:CreateLogGroup`
  - `logs:CreateLogStream`
  - `logs:PutLogEvents`
  - `logs:DescribeLogStreams`
  - `logs:FilterLogEvents`
  - `logs:DeleteLogGroup`
  - `cloudwatch:PutMetricData`
  - `cloudwatch:GetMetricData`
  - `cloudwatch:PutDashboard`
  - `cloudwatch:DeleteDashboards`

### Files, Repos, or Sample Code Needed

No application repo is required for the base lab.

The instructor can provide or ask students to create:

- `sample-logs.json`
- `dashboard.json`
- Optional shell script: `generate-observability-data.sh`

---

## 4. Key Terms and Definitions

| Term | Beginner-Friendly Definition | Real-World Context |
|---|---|---|
| Monitoring | Watching known signals to check if a system is healthy | CPU alerts, disk alerts, uptime checks |
| Observability | Ability to understand why a system behaves a certain way | Investigating unknown production problems |
| Log | A text event written by an app or system | Error messages, request records, audit events |
| Metric | A numeric value measured over time | CPU usage, request count, error rate, latency |
| Trace | A view of one request as it moves across services | User request goes from frontend to API to database |
| Dashboard | Visual display of key metrics and service health | Used during incidents and daily operations |
| Alert | Notification triggered when a metric crosses a threshold | Pager or Slack notification for high error rate |
| Alert fatigue | When teams receive too many noisy alerts and start ignoring them | A major production risk |
| Latency | Time taken to complete a request | Slow checkout API or slow login response |
| Error rate | Percentage or count of failed requests | HTTP 5xx errors from an API |
| Request count | Number of requests received by a service | Helps identify traffic spikes or drops |
| Visibility gap | Missing signal that prevents troubleshooting | No latency metric, no structured logs, no dashboard |
| Counter | A metric that only ever increases (or resets to 0 on restart) | Total requests served, total errors, bytes sent |
| Gauge | A metric that can go up or down | Current memory in use, in-flight requests, queue depth, temperature |
| Histogram | Counts observations into buckets so percentiles can be computed later | Request duration bucketed into ≤0.1s, ≤0.5s, ≤1s …; enables p95/p99 |
| Summary | Like a histogram but percentiles are computed client-side per instance | Older pattern; cannot be aggregated across instances — prefer histograms |
| Percentile (p50/p95/p99) | The value below which that % of observations fall | p99 latency = "the slowest 1% of users wait at least this long" |
| Average-latency anti-pattern | Reporting only the mean latency, which hides the slow tail | An app with p50=100ms can still have p99=4s; the average looks fine |
| Prometheus | Open-source metrics database that *scrapes* `/metrics` endpoints and runs PromQL | The de-facto Kubernetes metrics system |
| PromQL | Prometheus query language for selecting and aggregating time series | `rate(http_requests_total[5m])` |
| Exporter | A process that exposes metrics in Prometheus format | `node_exporter` (host), `kube-state-metrics` (K8s objects) |
| Scrape | Prometheus pulling metrics from a target on an interval | Prometheus GETs `http://app:8080/metrics` every 15s |
| Grafana | Open-source dashboard/visualization and alerting front-end | Dashboards over Prometheus, Loki, Tempo, CloudWatch |
| Loki | Log aggregation system that indexes labels, not full text (Grafana stack) | Cheap log storage queried with LogQL |
| Tempo | Distributed tracing backend (Grafana stack) | Stores OpenTelemetry traces |
| OpenTelemetry (OTel) | Vendor-neutral standard + SDKs for traces, metrics, and logs | Instrument once, export to Tempo/Jaeger/X-Ray/CloudWatch |
| Span / Trace | A span is one timed operation; a trace is the tree of spans for one request | One request = trace; each service hop = span |
| Cardinality | The number of unique label-value combinations for a metric | High cardinality (e.g. `user_id` as a label) explodes cost and can crash Prometheus |
| RED method | Rate, Errors, Duration — the three signals for a *request-driven* service | Per-endpoint requests/sec, error %, latency percentiles |
| USE method | Utilization, Saturation, Errors — the three signals for a *resource* | CPU/mem/disk/queue: how full, how backed-up, how broken |

---

## 5. Tools Used

| Tool | Why It Is Used |
|---|---|
| Prometheus | Scrapes and stores time-series metrics; runs PromQL (primary OSS metrics tool) |
| Grafana | Builds dashboards and explores metrics/logs/traces across data sources |
| Loki | Aggregates application logs cheaply (label-indexed) |
| Tempo / Jaeger | Stores and displays distributed traces |
| OpenTelemetry SDK + Collector | Instruments apps (traces/metrics) and exports to a backend |
| Docker / Docker Compose | Runs the local Prometheus + Grafana + demo-app stack for the lab |
| AWS Console | Visual way to explore CloudWatch Logs, Metrics, and Dashboards (AWS-managed comparison) |
| AWS CLI (v2) | Allows repeatable creation of logs, metrics, and dashboards |
| CloudWatch Logs / Metrics / Dashboards | AWS-managed equivalents of Loki / Prometheus / Grafana |
| Terminal | Used to run CLI commands |
| VS Code or text editor | Used to create config, manifests, and JSON files |
| Optional jq | Helps format JSON output from AWS CLI |

---

## 6. AWS Services Used

| AWS Service | How It Connects to This Class |
|---|---|
| Amazon CloudWatch Logs | Stores log events from applications, EC2, Lambda, ECS, EKS, and other AWS services |
| Amazon CloudWatch Metrics | Stores metrics such as CPU, request count, error count, and custom application metrics |
| Amazon CloudWatch Dashboards | Provides visual dashboards for operational awareness |
| Amazon CloudWatch Alarms | Introduced briefly, but covered deeper in Class 2 |
| IAM | Controls access to CloudWatch logs, metrics, dashboards, and alarms |
| EC2 Conceptual Review | Used as a familiar example for infrastructure metrics |
| EKS Conceptual Review | Used to connect Kubernetes workloads with observability needs |

---

## 7. Azure and GCP Comparison Notes

Keep this section short during class.

| Concept | Open Source (portable) | AWS | Azure | GCP |
|---|---|---|---|---|
| Metrics | Prometheus | CloudWatch Metrics | Azure Monitor Metrics | Cloud Monitoring Metrics |
| Dashboards | Grafana | CloudWatch Dashboards | Azure Dashboards / Workbooks | Cloud Monitoring Dashboards |
| Logs | Loki | CloudWatch Logs | Azure Monitor Logs / Log Analytics | Cloud Logging |
| Tracing | Tempo / Jaeger | AWS X-Ray | Application Insights | Cloud Trace |
| Instrumentation | OpenTelemetry | OpenTelemetry / ADOT | OpenTelemetry | OpenTelemetry |
| Alerts | Prometheus rules + Alertmanager | CloudWatch Alarms | Azure Monitor Alerts | Cloud Monitoring Alerting |

> **The portable column is the one to learn deeply.** OpenTelemetry is the vendor-neutral instrumentation standard supported by all three clouds (AWS ships ADOT, the AWS Distro for OpenTelemetry). Instrument once with OTel, switch backends later.

### Instructor Note

Tell students:

> The names change across cloud providers, but the operational questions are the same: What happened? When did it happen? Who was impacted? Which component failed? What changed recently?

---

## 8. Time-Boxed Instructor Agenda

| Time | Section | Format |
|---:|---|---|
| 0:00 to 0:10 | Welcome, class goal, production incident framing | Instructor-led |
| 0:10 to 0:30 | Monitoring vs observability | Lecture and discussion |
| 0:30 to 0:55 | Logs, metrics, and traces | Whiteboard |
| 0:55 to 1:10 | What makes a useful dashboard? | Instructor explanation |
| 1:10 to 1:20 | Break | Break |
| 1:20 to 1:55 | AWS CloudWatch Logs and Metrics overview | Console walkthrough |
| 1:55 to 2:25 | Instructor demo: create logs, publish metrics, build dashboard | Demo |
| 2:25 to 2:50 | Student lab: inspect logs, metrics, and dashboard | Hands-on |
| 2:50 to 3:00 | Troubleshooting scenario, recap, homework | Discussion and wrap-up |

---

## 9. Instructor Lesson Plan

### Step 1: Open With a Production Scenario

Start with this:

> Imagine the application team says the website was slow this morning. Users complained, but nobody knows why. The server was running, CPU looked normal, and there was no obvious outage. What do we need to investigate?

Let students answer.

Guide them toward:

- Logs
- Metrics
- Dashboards
- Request latency
- Error count
- Recent deployment
- Dependency health

### Step 2: Explain Monitoring vs Observability

Teaching flow:

1. Monitoring answers: “Is something wrong?”
2. Observability answers: “Why is it wrong?”
3. Monitoring is usually based on known failure patterns.
4. Observability helps during unknown or complex failures.

Pause and ask:

> Can a system be monitored but still hard to troubleshoot?

Expected answer: Yes. For example, CPU is visible but request latency and errors are missing.

### Step 3: Teach Logs, Metrics, and Traces

Explain each signal:

- Logs tell detailed event stories.
- Metrics show trends over time.
- Traces show request paths across services.

Beginner teaching tip:

Use a restaurant analogy:

- Logs are individual customer complaints or kitchen notes.
- Metrics are total orders per hour, failed orders, and average wait time.
- Traces are the full path of one order from waiter to kitchen to delivery.

### Step 4: Introduce Dashboard Thinking

Explain:

A dashboard should not just display random graphs. It should answer operational questions.

Useful dashboard questions:

- Is the app healthy?
- Are users impacted?
- Are errors increasing?
- Is latency increasing?
- Did traffic change?
- Is infrastructure saturated?
- Did this start after a deployment?

### Step 5: Show AWS CloudWatch

Show:

- CloudWatch landing page
- Log groups
- Metrics
- Dashboards
- Basic alarm preview only

Do not go too deep into alarms. Save alert strategy for Class 2.

### Step 6: Run Instructor Demo

Use AWS CLI to create:

- Log group
- Log stream
- Sample log events
- Custom metrics
- Dashboard

Explain each step and connect it back to operations.

### Step 7: Student Lab

Students repeat a simplified version:

- Create log group
- Push sample logs
- Search logs
- Publish metrics
- Create dashboard or dashboard design

### Step 8: Troubleshooting Activity

Scenario:

> The app was slow, but the team only has CPU metrics and raw logs. What is missing?

Expected student answer:

- Latency metric
- Error rate
- Request count
- Deployment marker
- Structured logs
- Dependency health metrics

### Step 9: Recap and Transition to Class 2

End with:

> Today we learned how to see what is happening. In Class 2, we will decide when that information should become an alert, who should be notified, and how to avoid alert fatigue.

---

## 10. Instructor Lecture Notes

### Opening Talking Point

Observability is not just about collecting data. It is about collecting the right data so engineers can make decisions during normal operations and incidents.

### Monitoring vs Observability

Monitoring is useful when you already know what to watch.

Examples:

- CPU above 90%
- Disk above 85%
- HTTP 5xx errors
- Load balancer target unhealthy

Observability is broader. It helps answer unknown questions.

Examples:

- Why is latency high only for some users?
- Why did error rate increase after deployment?
- Why does the application fail only in one region?
- Why is Kubernetes restarting the pod?

### Logs

Logs are detailed events. They are useful for understanding what happened at a specific time.

Examples:

```text
2026-04-26T10:15:10Z INFO request_id=abc123 path=/api/orders status=200 latency_ms=120
2026-04-26T10:16:22Z ERROR request_id=def456 path=/api/orders status=500 message="database timeout"
```

Good logs usually include:

- Timestamp
- Severity
- Request ID
- Service name
- Error message
- User or transaction context, if safe
- Status code
- Latency

Security warning:

Do not log passwords, tokens, access keys, private data, or secrets.

### Metrics

Metrics are numbers measured over time. But "a number over time" is not enough to be useful — the *type* of metric determines what you can ask of it.

#### The four metric types (this is foundational)

| Type | Behavior | Examples | What you do with it |
|---|---|---|---|
| **Counter** | Only goes up; resets to 0 on restart | `http_requests_total`, `errors_total`, bytes sent | Take a **rate**: `rate(http_requests_total[5m])` = requests/sec |
| **Gauge** | Goes up and down | in-flight requests, memory in use, queue depth, temperature | Read the current value; `max`/`avg` over time |
| **Histogram** | Buckets observations (e.g. ≤0.1s, ≤0.5s, ≤1s, ≤2.5s) | request duration, response size | Derive **percentiles** (p50/p95/p99) server-side, aggregatable across instances |
| **Summary** | Computes percentiles *on each instance* | older latency pattern | Avoid for fleets — percentiles can't be re-aggregated across pods |

Teaching emphasis: **a counter never decreases.** If you see a metric named `*_total` go down, it means the process restarted. That is why you almost always wrap counters in `rate()` rather than reading their raw value.

#### Percentiles and the average-latency anti-pattern

This is the single most important metrics lesson in the week.

> **Never report only `AverageLatencyMs`.** The average hides the slow tail — the exact users who are suffering.

Worked example. Ten requests, latency in ms:

```text
100, 100, 110, 120, 120, 130, 140, 150, 160, 4000
```

- **Average** = 513 ms — looks "a bit slow."
- **p50 (median)** = 125 ms — most users are fine.
- **p90** = 160 ms — still fine.
- **p99 / max** ≈ 4000 ms — one request in a hundred is catastrophic.

The average is *dragged up* by the outlier yet still *hides* it. A user hitting that 4-second request does not feel "513 ms." Senior engineers alert and report on **p95/p99**, not averages.

You cannot compute a percentile from a single pushed average — you need the *distribution*. That is exactly what a **histogram** stores. With a Prometheus histogram named `http_request_duration_seconds`, the p95 over 5 minutes is:

```promql
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

In CloudWatch the equivalent is publishing latency as a metric and selecting the **p95 extended statistic** (`p95`) on the widget — *not* publishing a precomputed `AverageLatencyMs` scalar. (We fix exactly this anti-pattern in the demo and lab.)

#### RED and USE: which metrics to even collect

Two memorable frameworks tell you *what* to instrument:

- **RED — for request-driven services (APIs, web apps):**
  - **R**ate: requests per second
  - **E**rrors: failed requests per second (or error %)
  - **D**uration: latency distribution (p50/p95/p99)
- **USE — for resources (CPU, memory, disk, queues, connection pools):**
  - **U**tilization: how busy (CPU %, mem %)
  - **S**aturation: how much work is queued/waiting (run-queue length, queue depth)
  - **E**rrors: error events (disk errors, dropped packets)

A good service dashboard is RED on top (user impact) and USE underneath (resources). This is *why* CPU-only monitoring fails: CPU is one USE signal and tells you nothing about R, E, or D.

#### Cardinality: the #1 cost and reliability failure mode

A metric's **cardinality** is the number of unique label-value combinations. Each combination is a separate stored time series.

```text
http_requests_total{method, status, endpoint}   # bounded: ~ a few hundred series  ✅
http_requests_total{user_id="..."}               # unbounded: one series PER USER    ❌
```

Putting `user_id`, `request_id`, full URLs, or email addresses in metric labels is a **cardinality explosion** — it can balloon storage cost and crash a Prometheus server (OOM). Rule of thumb: labels must be **bounded and low-cardinality**. High-cardinality identifiers belong in **logs and traces**, not metric labels. This is the metrics counterpart to the "logs cost money" lesson.

### Traces

Traces show the path of a request through multiple services. A **trace** is the whole request; each timed operation within it is a **span**, and spans carry a shared trace/context ID propagated across service boundaries.

Example:

```text
Trace: checkout request (trace_id=4bf92f...)
  span: frontend          [============================ 820ms]
    span: orders-api        [================== 540ms]
      span: payment-api       [========= 300ms]
      span: db query          [==== 120ms]
```

Reading this you can see *where* the 820 ms went: the payment call dominated. Logs tell you a payment timeout happened; the trace tells you it was on the critical path and how long each hop took.

In 2026 the standard way to produce traces is **OpenTelemetry (OTel)**: you instrument the app once with the OTel SDK (or auto-instrumentation), spans flow to an **OTel Collector**, and the Collector exports to a backend — **Tempo**, **Jaeger**, or **AWS X-Ray**. We make this hands-on in the demo, not just a diagram.

### Dashboards

A dashboard should show health at a glance.

A basic application dashboard may include:

- Request count
- Error rate
- Latency
- CPU
- Memory
- Database connection count
- Recent deployment marker
- Top errors

Bad dashboard pattern:

- Too many graphs
- No clear ownership
- No user-impact metric
- No labels
- No time correlation

Good dashboard pattern:

- Starts with user-impact metrics
- Then shows application health
- Then shows infrastructure health
- Then shows dependency health

### Common Misconceptions

| Misconception | Correction |
|---|---|
| “CPU is enough to monitor an app.” | CPU is helpful, but user impact often appears in latency, error rate, or failed requests. |
| “More logs means better observability.” | More logs can create noise if they are unstructured or meaningless. |
| “Dashboards are only for managers.” | Engineers use dashboards during incidents and troubleshooting. |
| “If there is no alert, there is no problem.” | Some problems are visible to users before alerts are configured. |
| “CloudWatch is only for AWS infrastructure.” | CloudWatch can also store custom application logs and metrics. |

### Enterprise Context

In an enterprise, observability usually involves multiple teams:

- Application team owns application logs and business metrics.
- Cloud team owns infrastructure metrics and platform visibility.
- SRE team owns reliability signals, SLOs, and incident response.
- Security team cares about audit logs and sensitive data handling.
- Management wants service health and business impact visibility.

---

## 11. Whiteboard Explanation

### Simple Diagram: Observability Signals Across an Application

```text
User
 |
 |  Request latency
 |  Error experience
 v
Load Balancer
 |
 |  Request count
 |  4xx / 5xx
 |  Target response time
 v
Application Service
 |
 |  Application logs
 |  Error logs
 |  CPU / memory
 |  Custom metrics
 v
Database / Dependency
 |
 |  Query latency
 |  Connection count
 |  Timeout errors
```

### Step-by-Step Explanation

1. A user makes a request.
2. The request reaches a load balancer.
3. The load balancer forwards traffic to the application.
4. The application may call a database or external dependency.
5. Each layer should provide useful signals.
6. During an incident, engineers correlate signals across layers.

### What Each Component Means

| Component | What to Observe |
|---|---|
| User | Latency, failures, transaction success |
| Load balancer | HTTP status codes, target health, response time |
| Application | Logs, exceptions, request processing time |
| Database | Query latency, connection count, errors |
| Infrastructure | CPU, memory, network, disk |

### Enterprise Version

```text
Users
  |
Route 53 / DNS
  |
CloudFront or Public Load Balancer
  |
Kubernetes Ingress / API Gateway
  |
Application Pods / Services
  |
RDS / External APIs / Queues
  |
Monitoring and Logging Platform
  |
Dashboards, Alerts, Runbooks, Incident Response
```

### Instructor Emphasis

Say:

> In real enterprises, troubleshooting is rarely one graph or one log line. It is correlation across user impact, app behavior, infrastructure health, and recent changes.

---

## 12. Instructor Demo Script

### Demo Title

**Creating Basic Observability Signals in AWS CloudWatch**

### Demo Objective

Show students how logs, metrics, and dashboards work together in AWS CloudWatch.

### Required Setup

Instructor needs:

- AWS CLI configured
- AWS account with CloudWatch permissions
- Region selected, for example `us-east-1`
- Terminal
- Browser access to AWS Console

Set variables:

```bash
export AWS_REGION="us-east-1"
export LOG_GROUP="/devops-course/week16/sample-app"
export LOG_STREAM="class-16-1-demo"
export DASHBOARD_NAME="Week16-Observability-Demo"
```

Validate identity:

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "AIDA...",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/student-user"
}
```

### Step 1: Create CloudWatch Log Group

```bash
aws logs create-log-group \
  --log-group-name "$LOG_GROUP" \
  --region "$AWS_REGION"
```

Expected output:

```text
No output means the command succeeded.
```

If the log group already exists:

```text
An error occurred (ResourceAlreadyExistsException)
```

Recovery:

```bash
echo "Log group already exists. Continue to next step."
```

### Step 2: Create Log Stream

```bash
aws logs create-log-stream \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --region "$AWS_REGION"
```

Expected output:

```text
No output means the command succeeded.
```

### Step 3: Create Sample Log Events

Create timestamp variable:

```bash
NOW=$(date +%s000)
```

Create `events.json`:

```bash
cat > events.json <<EOF
[
  {
    "timestamp": $NOW,
    "message": "INFO service=orders-api request_id=req-1001 path=/api/orders status=200 latency_ms=120"
  },
  {
    "timestamp": $((NOW+1000)),
    "message": "INFO service=orders-api request_id=req-1002 path=/api/orders status=200 latency_ms=135"
  },
  {
    "timestamp": $((NOW+2000)),
    "message": "ERROR service=orders-api request_id=req-1003 path=/api/orders status=500 latency_ms=2200 error=\"database timeout\""
  },
  {
    "timestamp": $((NOW+3000)),
    "message": "WARN service=orders-api request_id=req-1004 path=/api/orders status=200 latency_ms=950 warning=\"slow dependency response\""
  }
]
EOF
```

### Step 4: Push Logs to CloudWatch

```bash
aws logs put-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --log-events file://events.json \
  --region "$AWS_REGION"
```

Expected output:

```json
{
  "nextSequenceToken": "496563..."
}
```

### Step 5: Search for Error Logs

```bash
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --filter-pattern "ERROR" \
  --region "$AWS_REGION"
```

Expected output should include:

```text
ERROR service=orders-api request_id=req-1003 path=/api/orders status=500 latency_ms=2200 error="database timeout"
```

Explain:

- This log gives the request path.
- It gives the status code.
- It gives a request ID.
- It gives latency.
- It gives a likely symptom: database timeout.

### Step 6: Publish Custom Metrics

Publish request count:

```bash
aws cloudwatch put-metric-data \
  --namespace "DevOpsCourse/SampleApp" \
  --metric-name "RequestCount" \
  --value 4 \
  --unit Count \
  --region "$AWS_REGION"
```

Publish error count:

```bash
aws cloudwatch put-metric-data \
  --namespace "DevOpsCourse/SampleApp" \
  --metric-name "ErrorCount" \
  --value 1 \
  --unit Count \
  --region "$AWS_REGION"
```

Publish latency **as individual observations, not a precomputed average**. We publish each request's latency so CloudWatch can compute percentiles (p50/p95/p99) itself. This is the corrected pattern — never publish an `AverageLatencyMs` scalar.

```bash
# Publish the raw latency values from the four sample requests (120, 135, 2200, 950 ms).
# CloudWatch will derive p50/p95/p99 from these observations.
for v in 120 135 2200 950; do
  aws cloudwatch put-metric-data \
    --namespace "DevOpsCourse/SampleApp" \
    --metric-name "RequestLatencyMs" \
    --value "$v" \
    --unit Milliseconds \
    --region "$AWS_REGION"
done
```

Alternative (more efficient — one call using a statistic set, which still lets CloudWatch compute percentiles when you publish values+counts):

```bash
aws cloudwatch put-metric-data \
  --namespace "DevOpsCourse/SampleApp" \
  --region "$AWS_REGION" \
  --metric-data '[
    {
      "MetricName": "RequestLatencyMs",
      "Unit": "Milliseconds",
      "Values": [120, 135, 2200, 950],
      "Counts": [1, 1, 1, 1]
    }
  ]'
```

Explain:

- Metrics show trends; logs explain details; both are needed.
- We published **observations**, not an average. On the dashboard we will select the **p95** statistic — the slow `2200 ms` request must not be hidden by a friendly-looking mean.
- This is how a histogram-style metric works: store the distribution, derive the percentile at query time.

### Step 7: Create a CloudWatch Dashboard

Create `dashboard.json`:

```bash
cat > dashboard.json <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ "DevOpsCourse/SampleApp", "RequestCount" ],
          [ ".", "ErrorCount" ]
        ],
        "period": 60,
        "stat": "Sum",
        "region": "$AWS_REGION",
        "title": "Sample App Request and Error Count"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ "DevOpsCourse/SampleApp", "RequestLatencyMs", { "stat": "p50", "label": "p50" } ],
          [ "...", { "stat": "p95", "label": "p95" } ],
          [ "...", { "stat": "p99", "label": "p99" } ]
        ],
        "period": 60,
        "region": "$AWS_REGION",
        "title": "Sample App Latency (p50/p95/p99 — NOT average)"
      }
    },
    {
      "type": "text",
      "x": 0,
      "y": 6,
      "width": 16,
      "height": 3,
      "properties": {
        "markdown": "# Week 16 Observability Demo\nRequest volume, errors, and **latency percentiles**. We chart p50/p95/p99 because an average would hide the slow 2200 ms request."
      }
    }
  ]
}
EOF
```

Create dashboard:

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --dashboard-body file://dashboard.json \
  --region "$AWS_REGION"
```

Expected output:

```json
{
  "DashboardValidationMessages": []
}
```

### Step 8: Open Dashboard in Console

Console actions:

1. Open AWS Console.
2. Go to CloudWatch.
3. Select Dashboards.
4. Open `Week16-Observability-Demo`.
5. Show request count, error count, and latency.

### What to Explain During Demo

- Logs answer “what happened?”
- Metrics answer “how often and how much?”
- Dashboards answer “what is the current health?”
- Missing metrics create blind spots.
- A useful dashboard starts with user impact.

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| AccessDenied | IAM permissions missing | Use instructor account or update IAM policy |
| ResourceAlreadyExistsException | Log group or stream already exists | Continue or use a new name |
| InvalidParameterException | Timestamp too old or malformed JSON | Regenerate timestamp and JSON |
| Metrics not visible immediately | CloudWatch delay | Wait a few minutes or refresh |
| Dashboard empty | Metric namespace mismatch | Confirm namespace and metric names |

### Cleanup Steps

Delete dashboard:

```bash
aws cloudwatch delete-dashboards \
  --dashboard-names "$DASHBOARD_NAME" \
  --region "$AWS_REGION"
```

Delete log group:

```bash
aws logs delete-log-group \
  --log-group-name "$LOG_GROUP" \
  --region "$AWS_REGION"
```

Delete local files:

```bash
rm -f events.json dashboard.json
```

### Cost Warning

CloudWatch custom metrics, dashboards, and stored logs may create small costs. Use a lab account, keep the data minimal, and clean up at the end.

---

## 12B. Instructor Demo Script — The Open-Source Stack (Prometheus + Grafana + OpenTelemetry)

This is the demo that makes the week senior-credible. It runs entirely **locally with Docker** (no cloud cost) and shows the same concepts — metric types, percentiles, RED, dashboards, traces — on the portable OSS stack.

### Demo Objective

Scrape a real `/metrics` endpoint with Prometheus, query it with PromQL using the RED method, visualize it in Grafana, and view an OpenTelemetry trace.

### Required Setup

- Docker and Docker Compose installed
- Ports 3000 (Grafana), 9090 (Prometheus), 8080 (demo app) free

### Step 1: A demo app that exposes Prometheus metrics

The instructor provides a tiny instrumented app. Any language works; this is Python with the official `prometheus_client`. The key teaching point is the **metric types**:

```python
# app.py
import random, time
from flask import Flask
from prometheus_client import Counter, Gauge, Histogram, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)

# Counter: only goes up  -> use rate() to get req/s and error/s  (the R and E of RED)
REQS = Counter("http_requests_total", "Total HTTP requests", ["endpoint", "status"])
# Histogram: buckets durations -> derive p50/p95/p99  (the D of RED)
LAT  = Histogram("http_request_duration_seconds", "Request latency", ["endpoint"],
                 buckets=(0.05, 0.1, 0.25, 0.5, 1, 2.5, 5))
# Gauge: goes up and down -> current in-flight requests
INFLIGHT = Gauge("http_requests_in_flight", "Requests currently being served")

@app.route("/checkout")
def checkout():
    INFLIGHT.inc()
    start = time.time()
    # Simulate a normal request, with a slow tail 5% of the time.
    delay = random.uniform(0.05, 0.2) if random.random() > 0.05 else random.uniform(2.0, 4.0)
    time.sleep(delay)
    status = "500" if random.random() < 0.03 else "200"
    LAT.labels(endpoint="/checkout").observe(time.time() - start)
    REQS.labels(endpoint="/checkout", status=status).inc()
    INFLIGHT.dec()
    return ("error\n", 500) if status == "500" else ("ok\n", 200)

# /metrics is exposed by prometheus_client for Prometheus to scrape
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {"/metrics": make_wsgi_app()})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

Explain at the whiteboard: **one counter, one histogram, one gauge** — that is RED plus a USE-style gauge, in three lines.

### Step 2: Tell Prometheus to scrape it

```yaml
# prometheus.yml
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: "demo-app"
    static_configs:
      - targets: ["app:8080"]      # Prometheus PULLS http://app:8080/metrics
```

### Step 3: Bring up the stack with Docker Compose

```yaml
# docker-compose.yml
services:
  app:
    build: .
    ports: ["8080:8080"]
  prometheus:
    image: prom/prometheus:v2.54.1
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    ports: ["9090:9090"]
  grafana:
    image: grafana/grafana:11.2.0
    environment:
      - GF_AUTH_ANONYMOUS_ENABLED=true
      - GF_AUTH_ANONYMOUS_ORG_ROLE=Admin
    ports: ["3000:3000"]
```

```bash
docker compose up -d --build
# generate some traffic
for i in $(seq 1 200); do curl -s localhost:8080/checkout >/dev/null; done
```

### Step 4: Write RED-method PromQL (open http://localhost:9090)

```promql
# RATE: requests per second over the last 5 minutes
sum(rate(http_requests_total[5m])) by (endpoint)

# ERRORS: error ratio (5xx as a fraction of all requests)
sum(rate(http_requests_total{status="500"}[5m]))
  /
sum(rate(http_requests_total[5m]))

# DURATION: p95 latency derived from the histogram (NOT an average!)
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))
```

Have the class compare the **p95** result to `rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])` (the average). The average looks fine; the p95 reveals the 2-4s slow tail. This is the average-latency anti-pattern, demonstrated live.

### Step 5: Build a RED dashboard in Grafana (http://localhost:3000)

1. Add a Prometheus data source: URL `http://prometheus:9090`.
2. New dashboard → three panels using the three queries above (Rate, Error %, p95 Duration).
3. Discuss panel order: **user-impact (RED) on top**, resource (USE) below — same dashboard philosophy taught in Section 9.

### Step 6 (optional): OpenTelemetry trace

Add OTel auto-instrumentation and a Tempo backend so a `/checkout` request produces a span tree:

```bash
pip install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap -a install
OTEL_TRACES_EXPORTER=otlp \
OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo:4317 \
OTEL_SERVICE_NAME=checkout-frontend \
  opentelemetry-instrument python app.py
```

In Grafana → Explore → Tempo, open a trace and show the `frontend → orders-api → payment-api → db` span tree from the lecture — now a real artifact, not a diagram.

### Common Demo Failure Points

| Failure | Cause | Recovery |
|---|---|---|
| Prometheus target "DOWN" | App not reachable on `app:8080` | Check `docker compose ps`; targets use the compose service name, not `localhost` |
| `histogram_quantile` returns empty | No `_bucket` series yet / no traffic | Generate traffic first; confirm the metric is a Histogram, not a Gauge |
| Grafana shows "No data" | Wrong data-source URL | Use `http://prometheus:9090` (in-network), not `localhost:9090` |
| p95 == average | Misread; they should differ | Confirm you used `histogram_quantile`, and that the slow-tail path fired |

### Cleanup Steps

```bash
docker compose down -v
```

No cloud resources are created in this demo, so there is **no cloud cost** — the only cost is local CPU/RAM while the stack runs.

---

## 13. Student Lab Manual

### Lab Title

**Explore Logs, Metrics, and Dashboards in CloudWatch**

### Lab Objective

Create basic observability data in AWS CloudWatch and use it to understand application behavior.

### Estimated Time

30 to 40 minutes

### Student Prerequisites

Students should have:

- AWS CLI configured
- CloudWatch permissions
- Terminal access
- Basic AWS Console familiarity

### Architecture or Workflow Overview

```text
Student Terminal
   |
   | AWS CLI
   v
CloudWatch Logs
   |
   v
CloudWatch Metrics
   |
   v
CloudWatch Dashboard
```

### Step 1: Set Environment Variables

```bash
export AWS_REGION="us-east-1"
export LOG_GROUP="/devops-course/week16/student-app-$USER"
export LOG_STREAM="lab-stream"
export DASHBOARD_NAME="Week16-Student-Observability-$USER"
```

If `$USER` is not available, use your initials:

```bash
export LOG_GROUP="/devops-course/week16/student-app-jd"
export DASHBOARD_NAME="Week16-Student-Observability-jd"
```

### Step 2: Validate AWS Access

```bash
aws sts get-caller-identity
```

Expected output:

```json
{
  "UserId": "...",
  "Account": "...",
  "Arn": "..."
}
```

Validation:

- The command should return your AWS identity.
- If it fails, check your AWS profile, credentials, and region.

### Step 3: Create a Log Group

```bash
aws logs create-log-group \
  --log-group-name "$LOG_GROUP" \
  --region "$AWS_REGION"
```

Expected output:

```text
No output means success.
```

### Step 4: Create a Log Stream

```bash
aws logs create-log-stream \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --region "$AWS_REGION"
```

Expected output:

```text
No output means success.
```

### Step 5: Create Sample Application Logs

```bash
NOW=$(date +%s000)

cat > student-events.json <<EOF
[
  {
    "timestamp": $NOW,
    "message": "INFO service=checkout-api request_id=req-2001 path=/checkout status=200 latency_ms=180"
  },
  {
    "timestamp": $((NOW+1000)),
    "message": "INFO service=checkout-api request_id=req-2002 path=/checkout status=200 latency_ms=210"
  },
  {
    "timestamp": $((NOW+2000)),
    "message": "WARN service=checkout-api request_id=req-2003 path=/checkout status=200 latency_ms=1100 warning=\"slow payment dependency\""
  },
  {
    "timestamp": $((NOW+3000)),
    "message": "ERROR service=checkout-api request_id=req-2004 path=/checkout status=500 latency_ms=2500 error=\"payment API timeout\""
  }
]
EOF
```

### Step 6: Send Logs to CloudWatch

```bash
aws logs put-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$LOG_STREAM" \
  --log-events file://student-events.json \
  --region "$AWS_REGION"
```

Expected output:

```json
{
  "nextSequenceToken": "..."
}
```

### Step 7: Search for Errors

```bash
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --filter-pattern "ERROR" \
  --region "$AWS_REGION"
```

Expected output should include:

```text
ERROR service=checkout-api request_id=req-2004 path=/checkout status=500 latency_ms=2500 error="payment API timeout"
```

### Step 8: Search for Slow Requests

```bash
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --filter-pattern "latency_ms" \
  --region "$AWS_REGION"
```

Review the output and identify:

- Fastest request
- Slowest request
- Request with warning
- Request with error

### Step 9: Publish Custom Metrics

Request count:

```bash
aws cloudwatch put-metric-data \
  --namespace "DevOpsCourse/StudentApp" \
  --metric-name "RequestCount" \
  --value 4 \
  --unit Count \
  --region "$AWS_REGION"
```

Error count:

```bash
aws cloudwatch put-metric-data \
  --namespace "DevOpsCourse/StudentApp" \
  --metric-name "ErrorCount" \
  --value 1 \
  --unit Count \
  --region "$AWS_REGION"
```

Latency — publish the **raw observations** (180, 210, 1100, 2500 ms), not an average, so CloudWatch can compute percentiles:

```bash
for v in 180 210 1100 2500; do
  aws cloudwatch put-metric-data \
    --namespace "DevOpsCourse/StudentApp" \
    --metric-name "RequestLatencyMs" \
    --value "$v" \
    --unit Milliseconds \
    --region "$AWS_REGION"
done
```

> Notice the slow `2500 ms` request. If you charted the **average** (~998 ms) you would never see how bad the worst requests are. We chart **p95** instead.

### Step 10: Create a Dashboard

```bash
cat > student-dashboard.json <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ "DevOpsCourse/StudentApp", "RequestCount" ],
          [ ".", "ErrorCount" ]
        ],
        "period": 60,
        "stat": "Sum",
        "region": "$AWS_REGION",
        "title": "Student App Requests and Errors"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ "DevOpsCourse/StudentApp", "RequestLatencyMs", { "stat": "p50", "label": "p50" } ],
          [ "...", { "stat": "p95", "label": "p95" } ],
          [ "...", { "stat": "p99", "label": "p99" } ]
        ],
        "period": 60,
        "region": "$AWS_REGION",
        "title": "Student App Latency (p50/p95/p99)"
      }
    }
  ]
}
EOF
```

Create the dashboard:

```bash
aws cloudwatch put-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --dashboard-body file://student-dashboard.json \
  --region "$AWS_REGION"
```

Expected output:

```json
{
  "DashboardValidationMessages": []
}
```

### Step 11: View Dashboard in AWS Console

1. Open AWS Console.
2. Search for CloudWatch.
3. Go to Dashboards.
4. Open your dashboard.
5. Review request count, error count, and latency.

### Validation Checklist

Students should verify:

- AWS CLI identity works.
- Log group exists.
- Log stream exists.
- Logs were sent successfully.
- Error logs can be searched.
- Custom metrics were published.
- Dashboard was created.
- Dashboard shows at least two widgets.

### Troubleshooting Tips

| Problem | Possible Cause | Fix |
|---|---|---|
| AWS CLI fails | Credentials missing | Run `aws configure` or check profile |
| AccessDenied | IAM permission missing | Ask instructor for correct lab permissions |
| Log group exists | Same name already used | Use a unique log group name |
| Metrics not visible | CloudWatch delay | Wait a few minutes and refresh |
| Dashboard missing data | Namespace or metric name mismatch | Check `DevOpsCourse/StudentApp` spelling |
| JSON error | Bad formatting | Recreate JSON file carefully |

### Cleanup Steps

Delete dashboard:

```bash
aws cloudwatch delete-dashboards \
  --dashboard-names "$DASHBOARD_NAME" \
  --region "$AWS_REGION"
```

Delete log group:

```bash
aws logs delete-log-group \
  --log-group-name "$LOG_GROUP" \
  --region "$AWS_REGION"
```

Remove local files:

```bash
rm -f student-events.json student-dashboard.json
```

### Reflection Questions

1. Which log message was most useful for troubleshooting?
2. Which metric would be most useful during an incident?
3. What important signal is still missing?
4. Would CPU alone tell you whether users are impacted?
5. What would you add before this app goes to production?

### Optional Challenge Task

Add a fourth metric called `SlowRequestCount` with a value of `2`, then update the dashboard to include it.

```bash
aws cloudwatch put-metric-data \
  --namespace "DevOpsCourse/StudentApp" \
  --metric-name "SlowRequestCount" \
  --value 2 \
  --unit Count \
  --region "$AWS_REGION"
```

### Optional Challenge Task — Open-Source Stack (no cloud cost)

Run the local Prometheus + Grafana stack from Demo 12B (`docker compose up -d --build`), generate traffic, then in the Prometheus UI write the three **RED** queries and confirm the **p95** differs from the average:

```promql
sum(rate(http_requests_total[5m])) by (endpoint)                                  # Rate
sum(rate(http_requests_total{status="500"}[5m])) / sum(rate(http_requests_total[5m]))  # Errors
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) # Duration p95
```

Build a 3-panel RED dashboard in Grafana (`http://localhost:3000`). Tear down with `docker compose down -v`.

---

## 14. Troubleshooting Activity

### Incident Title

**The Application Was Slow, But Nobody Knows Why**

### Business Impact

Customer support reports that users experienced slow checkout between 8:00 AM and 8:30 AM. No outage was declared, but several customers abandoned the checkout process.

### Symptoms

- Users report slow checkout.
- No clear application outage.
- CPU stayed below 60%.
- No alert fired.
- Support tickets mention “checkout spinning” and “payment timeout.”

### Starting Evidence

Available log examples:

```text
INFO service=checkout-api request_id=req-3011 path=/checkout status=200 latency_ms=240
WARN service=checkout-api request_id=req-3012 path=/checkout status=200 latency_ms=1900 warning="slow payment dependency"
ERROR service=checkout-api request_id=req-3013 path=/checkout status=500 latency_ms=3100 error="payment API timeout"
INFO service=checkout-api request_id=req-3014 path=/checkout status=200 latency_ms=260
```

Available metrics:

```text
CPUUtilization: 55%
MemoryUtilization: Not available
RequestCount: Not available
ErrorRate: Not available
Latency: Not available
PaymentAPITimeoutCount: Not available
```

### Student Investigation Steps

Students should identify:

1. What signals are available?
2. What signals are missing?
3. Are logs searchable?
4. Are logs structured?
5. Is there a latency metric?
6. Is there an error rate metric?
7. Is dependency health visible?
8. Was there a deployment or configuration change?
9. What dashboard would help?
10. What alert could catch this next time?

### Expected Root Cause

The actual issue appears related to slow or failing payment API calls, but the monitoring setup is incomplete.

The team only has infrastructure-level CPU data. They do not have:

- Checkout latency metric
- Error rate metric
- Dependency timeout metric
- Request count
- Dashboard showing user impact
- Alert based on failed checkout or high latency

### Correct Resolution

Immediate actions:

1. Search logs for payment timeout errors.
2. Identify impacted time window.
3. Check payment dependency status.
4. Confirm if checkout error or latency increased.
5. Notify app and dependency owners.

Preventive actions:

1. Add checkout latency metric.
2. Add checkout error count metric.
3. Add payment timeout metric.
4. Create dashboard for checkout health.
5. Add alert for high checkout error rate or latency.
6. Improve log structure with request IDs and dependency names.

### Common Wrong Paths

| Wrong Path | Why It Is Wrong |
|---|---|
| Restart the server immediately | No evidence server is the issue |
| Focus only on CPU | CPU is not showing user impact |
| Declare no issue because no alert fired | Alerts may be missing or poorly designed |
| Ignore logs because the app is still running | Logs contain the best evidence |
| Blame network without evidence | Need metrics and logs before guessing |

### Instructor Hints

Use these hints if students get stuck:

- What would prove users were impacted?
- Which metric would show checkout health?
- What does latency tell you that CPU does not?
- Which log line gives the strongest clue?
- What is missing from the dashboard?

### Preventive Action

Create an observability improvement backlog:

1. Add structured application logs.
2. Add request latency metric.
3. Add request count metric.
4. Add HTTP 5xx count metric.
5. Add dependency timeout metric.
6. Create CloudWatch dashboard.
7. Add alerting strategy in Class 2.
8. Create runbook for checkout latency.

---

## 15. Scenario-Based Discussion Questions

### Question 1

A dashboard shows CPU and memory, but users say checkout is slow. What else should be on the dashboard?

Expected themes:

- Latency
- Error rate
- Request count
- Dependency health
- HTTP status codes

Follow-up:

> Which of these is closest to user impact?

### Question 2

Should every error log trigger an alert?

Expected themes:

- No
- Some errors are expected
- Alert on patterns, rates, or user impact
- Avoid alert fatigue

Follow-up:

> When should an error become a critical alert?

### Question 3

Who should own application logs in an enterprise?

Expected themes:

- Application team owns application log quality
- Platform team may provide logging pipeline
- SRE defines reliability needs
- Security reviews sensitive data handling

Follow-up:

> What happens if logs contain secrets?

### Question 4

Why might infrastructure metrics be insufficient for troubleshooting?

Expected themes:

- Infrastructure may look healthy while app fails
- CPU does not show business transaction failures
- Need service-level metrics
- Need dependency metrics

Follow-up:

> Can an application fail while EC2 or Kubernetes looks healthy?

### Question 5

What is the cost risk of collecting too many logs?

Expected themes:

- Storage cost
- Ingestion cost
- Search cost
- Noise
- Retention management needed

Follow-up:

> How would you decide log retention?

### Question 6

Should dashboards be designed by SREs only?

Expected themes:

- No
- App, DevOps, cloud, SRE, and support teams all contribute
- Dashboard should support shared troubleshooting

Follow-up:

> What would each team want to see?

### Question 7

What makes a log message useful during an incident?

Expected themes:

- Timestamp
- Service name
- Request ID
- Error message
- Status code
- Latency
- Dependency name

Follow-up:

> What should never be included in logs?

### Question 8

How would you compare CloudWatch, Azure Monitor, and Google Cloud Monitoring to a beginner?

Expected themes:

- Same purpose, different platform
- Logs, metrics, dashboards, and alerts exist in all three
- AWS-first class uses CloudWatch
- Skills transfer across clouds

Follow-up:

> What concepts stay the same across clouds?

---

## 16. Knowledge Check or Mini-Quiz With Answer Key

### Question 1: Multiple Choice

What is the best definition of observability?

A. A tool that sends alerts  
B. The ability to understand system behavior using signals like logs, metrics, and traces  
C. A dashboard with CPU and memory only  
D. A replacement for incident response  

**Answer:** B  
**Explanation:** Observability helps engineers understand why systems behave a certain way.

### Question 2: Multiple Choice

Which signal is best for showing numeric trends over time?

A. Log  
B. Metric  
C. Trace  
D. Ticket  

**Answer:** B  
**Explanation:** Metrics are numeric time-series data such as request count, latency, and CPU.

### Question 3: Multiple Choice

Which AWS service is the primary service used in this class?

A. Amazon S3  
B. Amazon CloudWatch  
C. Amazon Route 53  
D. AWS Lambda  

**Answer:** B  
**Explanation:** CloudWatch provides logs, metrics, dashboards, and alarms.

### Question 4: True or False

CPU utilization alone can always tell whether users are impacted.

**Answer:** False  
**Explanation:** CPU can be normal while users experience errors, latency, or dependency failures.

### Question 5: True or False

Logs should safely include passwords and access tokens if they help troubleshooting.

**Answer:** False  
**Explanation:** Logs must never include secrets, passwords, tokens, or sensitive data.

### Question 6: Short Answer

Name three useful fields in an application log.

**Answer:** Timestamp, service name, request ID, status code, latency, error message, dependency name.  
**Explanation:** These fields help engineers search, correlate, and understand incidents.

### Question 7: Short Answer

What is one difference between monitoring and observability?

**Answer:** Monitoring tells whether something known is wrong. Observability helps explain why something is happening.  
**Explanation:** Monitoring is often alert/check based. Observability supports deeper investigation.

### Question 8: Troubleshooting

An app is slow, but CPU is only 40%. What metrics should you check next?

**Answer:** Latency, error rate, request count, dependency latency, database connections, memory, network, and recent deployments.  
**Explanation:** CPU alone does not show full service health.

### Question 9: Troubleshooting

CloudWatch dashboard shows no data after publishing metrics. What are two possible causes?

**Answer:** Metrics may take a few minutes to appear, or the dashboard uses the wrong namespace/metric name.  
**Explanation:** CloudWatch metric visibility is not always immediate, and names must match exactly.

### Question 10: Multiple Choice

Which cloud service is most similar to AWS CloudWatch?

A. Azure Monitor  
B. Azure Blob Storage  
C. GCP BigQuery  
D. Amazon ECR  

**Answer:** A  
**Explanation:** Azure Monitor provides metrics, logs, dashboards, and alerts similar to CloudWatch.

---

## 17. Homework Assignment

### Assignment Title

**Design an Observability Dashboard for a Web Application**

### Scenario

You are supporting a web application called `orders-api`. The application runs in AWS and supports order lookup and order submission. Users recently reported slow responses, but the team had limited visibility.

### Student Tasks

Create a one-page observability design that includes:

1. Application name and purpose.
2. The three **RED** metrics for the service, and for each, state its **metric type** (counter / gauge / histogram). The latency metric MUST be a histogram and MUST be reported as **p95/p99**, not an average — explain in one sentence why.
3. One **USE** signal for an underlying resource (e.g. CPU utilization or DB connection-pool saturation).
4. Three useful log patterns.
5. One dashboard layout (RED on top, USE below).
6. One visibility gap you want to fix.
7. One **cardinality** risk (a label you must NOT add) and where that data should live instead.
8. One security warning about logs.
9. The OpenTelemetry/Prometheus/Grafana equivalent, plus the Azure Monitor and Google Cloud Monitoring equivalents.

### Expected Deliverables

Students submit a markdown file or PDF containing:

- Dashboard design
- Metric list
- Log pattern list
- Short explanation of why each signal matters

### Submission Format

Recommended file name:

```text
week16-class1-observability-dashboard.md
```

### Estimated Completion Time

45 to 60 minutes

### Grading Criteria

| Criteria | Points |
|---|---:|
| Includes useful service-level metrics | 25 |
| Includes meaningful log patterns | 20 |
| Dashboard design supports troubleshooting | 25 |
| Includes security consideration | 10 |
| Includes Azure/GCP comparison | 10 |
| Clear writing and formatting | 10 |

Total: 100 points

### Optional Advanced Challenge

Add a section explaining how traces would help if `orders-api` calls:

```text
frontend -> orders-api -> payment-api -> database
```

---

## 18. Common Student Mistakes

| Mistake | Why It Happens | How to Fix or Avoid |
|---|---|---|
| Thinking CPU is enough | Beginners often focus on infrastructure metrics only | Teach service-level metrics first |
| Creating too many dashboard widgets | Students think more graphs means better visibility | Ask what question each widget answers |
| Forgetting cleanup | Students may leave CloudWatch resources behind | Use cleanup checklist before class ends |
| Logging sensitive data | Students may not understand security risk | Reinforce no secrets, tokens, or passwords in logs |
| Confusing logs and metrics | Both are observability signals but serve different purposes | Use examples and compare side by side |
| Not using request IDs | Students do not yet understand correlation | Show how request IDs connect events |
| Ignoring cloud costs | Logs and metrics can cost money | Use minimal data and short retention |
| Not checking region | AWS resources are region-specific | Confirm region at start of lab |
| Expecting metrics instantly | CloudWatch may delay custom metric display | Wait and refresh |
| Treating dashboards as decoration | Students may design pretty but useless dashboards | Focus on incident questions |

---

## 19. Real-World Enterprise Scenario

### Scenario

A retail company runs a customer-facing checkout service on AWS. The service is deployed on Kubernetes and uses a database plus an external payment provider.

The support team reports that customers sometimes abandon checkout during peak hours. The application team says the app is running. The cloud team says the infrastructure looks healthy. Leadership wants to know whether this is a real production issue.

### Constraints

- Application logs exist, but they are not structured consistently.
- CPU and memory dashboards exist, but no checkout-specific dashboard exists.
- Payment provider latency is not tracked.
- CloudWatch retention is not standardized.
- Security team prohibits logging card numbers, tokens, or customer private data.
- The company wants better visibility without creating excessive CloudWatch cost.

### How the Class Topic Applies

Students learn that the team needs:

- Checkout request count
- Checkout latency
- Checkout error rate
- Payment API timeout count
- Structured logs with request IDs
- Dashboard focused on user impact
- Clear ownership between app, cloud, and SRE teams

### What Each Role Would Do

| Role | Responsibility |
|---|---|
| DevOps Engineer | Add observability into deployment workflow and dashboards |
| Cloud Engineer | Ensure CloudWatch, IAM, retention, and log routing are configured safely |
| SRE | Define service health signals, SLOs, dashboards, and incident response needs |

---

## 20. Instructor Tips

### Teaching Tips

- Start with incident stories, not tool screens.
- Use simple examples before enterprise diagrams.
- Repeat this phrase: “Metrics show patterns. Logs explain events. Traces show flow.”
- Ask students what they would check before showing the answer.
- Keep AWS Console navigation slow and deliberate.

### Pacing Tips

- Do not spend too much time on CloudWatch alarm details. Save that for Class 2.
- Keep tracing conceptual unless students are advanced.
- Spend enough time on dashboard quality, not just dashboard creation.
- Leave at least 25 minutes for hands-on practice.

### Lab Support Tips

- Have students validate AWS identity first.
- Watch for region mismatch.
- Watch for IAM permission issues.
- Have backup screenshots or pre-created dashboard ready.
- Pair struggling students with someone who completed the CLI setup.

### Helping Struggling Students

Simplify to three questions:

1. What happened?
2. How often did it happen?
3. Who was impacted?

Then map:

- Logs answer what happened.
- Metrics answer how often.
- Dashboards help show impact.

### Challenging Advanced Students

Ask them to:

- Add metric filters from logs.
- Add structured JSON logs.
- Add trace design.
- Create a dashboard with service-level and dependency-level views.
- Propose log retention and cost controls.

---

## 21. Student Outcome Checklist

### Students Should Be Able to Explain

- [ ] Monitoring vs observability
- [ ] Logs vs metrics vs traces
- [ ] Why dashboards matter
- [ ] Why CPU alone is not enough
- [ ] Why alert fatigue begins with poor signal design
- [ ] How CloudWatch compares with Azure Monitor and Google Cloud Monitoring

### Students Should Be Able to Build or Configure

- [ ] CloudWatch log group
- [ ] CloudWatch log stream
- [ ] Sample log events
- [ ] Custom CloudWatch metrics
- [ ] Basic CloudWatch dashboard
- [ ] Simple dashboard layout for a web application

### Students Should Be Able to Troubleshoot

- [ ] Missing logs
- [ ] Missing metrics
- [ ] Dashboard with no data
- [ ] Unclear production symptom
- [ ] Slow app with insufficient observability
- [ ] Region or permission issues in AWS CLI

---

## 22. Class Completion Checklist

### Instructor Checklist Before Ending Class

- [ ] Students can define monitoring and observability.
- [ ] Students can explain logs, metrics, and traces.
- [ ] Demo was completed or backup demo was shown.
- [ ] Students completed basic lab tasks.
- [ ] Students cleaned up lab resources.
- [ ] Troubleshooting activity was reviewed.
- [ ] Homework was explained.
- [ ] Class 2 connection was previewed.

### Student Checklist Before Leaving Class

- [ ] I can explain the difference between monitoring and observability.
- [ ] I can describe logs, metrics, and traces.
- [ ] I created or reviewed CloudWatch logs.
- [ ] I published or reviewed CloudWatch metrics.
- [ ] I created or designed a dashboard.
- [ ] I understand what visibility gaps are.
- [ ] I cleaned up my CloudWatch dashboard and log group.
- [ ] I understand the homework assignment.

### Items to Verify Before Moving to Class 2

Students should understand:

- Why logs and metrics are needed before useful alerts can exist.
- Why not every metric should become an alert.
- Why user-impact metrics are more valuable than noisy infrastructure-only alerts.
- How dashboards support incident response.
- Why Class 2 will focus on alerting strategy, thresholds, severity, and alert fatigue.

---

## Class Artifacts & Validation

The runnable, on-disk artifacts behind this class's metrics/RED/dashboard/OpenTelemetry
content live in two sibling labs: [`labs/observability/`](../../labs/observability/) *authors*
the Prometheus rules, Grafana dashboard, and OTel config offline (the files shown in the
demos and §13 lab), and [`labs/observability-stack/`](../../labs/observability-stack/) *runs*
the same RED pipeline on a live kind cluster — it scrapes a real `/metrics` endpoint and
returns non-zero rate/error-ratio/p99 over the Prometheus HTTP API (Objective 4). All paths
below exist; every command was run in this environment.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/observability/solution/prometheus/rules/recording.rules.yml | monitoring (PromQL) | RED recording rules — request rate, error ratio, p99 via `histogram_quantile … by (job, le)` (Obj. 3–4) | `promtool check rules` | PASS (9 rules) |
| 2 | labs/observability/solution/prometheus/prometheus.yml | monitoring | Scrape config that loads both rule files; drops high-cardinality series (Obj. 4, 8) | `promtool check config` | PASS (2 rule files, valid syntax) |
| 3 | labs/observability/solution/grafana/dashboards/service-overview.json | dashboard (JSON) | Grafana RED dashboard model — schemaVersion 39, 4 panels with real PromQL `targets[].expr` (Obj. 4) | `python3 -m json.tool` + `python3 -m unittest discover -s tests` | PASS (parses; 15 structural tests OK) |
| 4 | labs/observability/solution/otel/otel-collector-config.yaml | monitoring (OTel) | OpenTelemetry Collector pipeline OTLP in → memory_limiter → batch → resource → exporters (Obj. 5) | `python3 -c "import yaml,sys; list(yaml.safe_load_all(open('labs/observability/solution/otel/otel-collector-config.yaml')))"` | PASS (parses); `otelcol-contrib validate` DEFERRED — binary not installed here |
| 5 | labs/observability/solution/queries/red-method.promql | monitoring (PromQL) | Commented RED-method PromQL cookbook (Obj. 4) | `python3 -m unittest discover -s tests` | PASS |
| 6 | labs/observability/docs/architecture.mmd | diagram (Mermaid) | Stack architecture: app → OTel Collector / Prometheus → rules → Grafana (Obj. 5) | renders in Mermaid; matches §1 description | PASS (renders) |
| 7 | labs/observability-stack/solution/app/app.py | python | Instrumented sample service exposing `/metrics` (counter + histogram) — the **real `/metrics` endpoint** scraped live (Obj. 4) | `python3 -m py_compile` + `python3 -m unittest discover -s tests` | PASS (11 tests) |
| 8 | labs/observability-stack/grafana/sample-api-red.json | dashboard (JSON) | Live-stack RED + burn-rate Grafana dashboard reading the recording rules (Obj. 4) | `python3 -m json.tool` | PASS |
| 9 | labs/observability-stack/run-demo.sh + labs/observability-stack/LIVE-OBS-EVIDENCE.txt | shell + evidence | Deploys the stack to kind, drives load, queries PromQL; captured run shows `up{job="sample-api"}=1` (2 pods), `rate5m≈4.3 req/s`, `error_ratio≈0.099`, `p99` present (Obj. 4) | `RUN_LIVE=1 ./run-demo.sh` | PASS — live evidence: labs/observability-stack/LIVE-OBS-EVIDENCE.txt |

The §13 CloudWatch lab is exercised live by the student against their own AWS account via the
AWS CLI steps shown; it creates a log group, log stream, metrics, and a dashboard, and the
§13 cleanup deletes them. `labs/observability/validate.sh` exits `0` (**38 passed, 0 failed**,
2 DEFERRED: `otelcol`/`oslo`); `labs/observability-stack/validate.sh` exits `0` (**59 passed,
0 failed**, 1 live DEFER captured in `LIVE-OBS-EVIDENCE.txt`).

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — Prometheus rules/config, Grafana dashboard JSON, OTel config, PromQL cookbook, and an instrumented `/metrics` app (`.py`), not just fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (`promtool check rules/config`, `json.tool`, `py_compile`, unittest — all PASS; `otelcol-contrib validate` honestly DEFERRED with the exact command in the lab README).
- [x] Lab has **starter** (intentionally incomplete — the p99/burn-rate TODOs and the missing pod-scrape annotations) and **solution** (reference) versions in both labs.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** (both lab READMEs).
- [x] **Cleanup/teardown** is provided and idempotent — the §13 CloudWatch lab deletes its log group/dashboard; `run-demo.sh` deletes the `lab-obs` namespace on a `trap`.
- [x] **Instructor answer key** exists — `solution/` in both labs, plus §16 quiz answer key and the §14 troubleshooting walkthrough.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `labs/observability/broken/alerting.rules.broken.yml` (two injected semantic faults) and the §14 "slow application" visibility-gap drill.
- [x] **Expected outputs** are shown for demos and labs (validate.sh transcripts, the live PromQL query results in `LIVE-OBS-EVIDENCE.txt`).
- [x] **Cost & security warnings** present — cardinality/cost hygiene (Obj. 8), no-secrets/TLS/least-exposure notes in the lab READMEs and the §13 AWS cleanup.
- [x] **Cross-references** to the module repos and to Class 2 / Week 21 are correct (numbers verified).
- [x] The **artifact manifest** (§4.2) above is present and every path resolves (`ls`-verified).
