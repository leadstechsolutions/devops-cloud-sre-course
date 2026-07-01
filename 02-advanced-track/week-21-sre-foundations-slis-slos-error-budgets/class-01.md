# Week 21: SRE Foundations, SLIs, SLOs, and Error Budgets
> **▶ Runnable lab for this class:** [`labs/sre-incident-response/`](../../labs/sre-incident-response/) · [`labs/observability/`](../../labs/observability/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1 Package

**Week:** 21
**Track:** Unified DevOps · Cloud · SRE Track
**Class title:** Introduction to SRE: Reliability, SLIs, SLOs, and SLAs
**Class:** 1 of 2
**Duration:** 3 hours
**Audience:** Intermediate to advanced DevOps, Cloud Engineering, and SRE learners
**Primary cloud:** AWS
**Secondary exposure:** Azure and GCP

---

> **Where this week sits.** Week 16 (Observability & Reliability) gave you the *instrumentation* layer: metrics, logs, traces, Prometheus/Grafana, OpenTelemetry, dashboards, and alert plumbing. Week 21 is the *reliability engineering* layer that sits on top of that telemetry: how to choose what "reliable" means in numbers (SLIs/SLOs), how to spend an error budget, and how to run on-call, incidents, and postmortems. **W16 owns "how do I see the system." W21 owns "how do I decide what good enough is and what to do when we miss it."** Wherever this week needs a metric, assume you compute it from the Prometheus / CloudWatch sources you stood up in W16.

---

# 1. Class Overview

**Class title:** Introduction to SRE: Reliability, SLIs, SLOs, and SLAs

**Class purpose.** This class establishes the conceptual and quantitative foundation of Site Reliability Engineering. Students learn what SRE teams actually do, why reliability must be defined from the *user's* point of view, and how to express reliability as measurable quantities (SLIs) with targets (SLOs) and business promises (SLAs). The class culminates in students writing an SLI **specification** — the precise good-events / valid-events definition that real SLO tooling (Sloth, OpenSLO, Datadog, CloudWatch) requires.

**How this class connects to the course.** By Week 21 students have already built and operated services (Docker W10, Kubernetes W11–W12, Helm W13, Terraform W14–W15) and instrumented them (Observability W16). This is the *only* dedicated SRE block in the program, so it is where reliability stops being a vibe ("the service feels slow") and becomes an engineered, codified contract. The SLOs designed here feed directly into platform golden paths (W20), CI/CD release gating (W9), and performance/capacity planning (W22).

**What students will build, analyze, or practice.**
- A named map of the **four golden signals** onto concrete SLIs for a real service.
- An **SLI specification** in good-events / valid-events form (the format SLO-as-code tools consume).
- A **nines → downtime budget** intuition (what 99.9% actually costs you per month).
- A critical-user-journey (CUJ) driven SLI selection for an order-tracking platform, computed from real metric data (CloudWatch Metrics Insights / Prometheus `rate()`), not a spreadsheet guess.

---

# 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the SRE discipline and how it differs from traditional operations (error budgets, toil reduction, SLO-driven decisions, software engineering applied to ops).
2. **Distinguish** reliability, availability, and uptime, and argue why user-journey signals beat resource metrics.
3. **Name and apply** the four golden signals (latency, traffic, errors, saturation) and map each to a concrete SLI.
4. **Write** an SLI as a formal specification: *good events / valid events* over a measurement window (request-based vs window-based).
5. **Differentiate** SLI, SLO, and SLA, and **justify** why the contractual SLA should be looser than the internal SLO.
6. **Convert** an availability target into an allowed downtime budget per month using the nines table.
7. **Select** SLIs from critical user journeys (CUJs) rather than from infrastructure dashboards.
8. **Compute** an availability and a latency SLI from raw metric data using a CloudWatch Metrics Insights or Prometheus query.

---

# 3. Prerequisites Students Should Already Know

**Prior concepts**
- Observability fundamentals from **Week 16** (metrics vs logs vs traces, Prometheus, Grafana, CloudWatch, alerting basics, OpenTelemetry).
- HTTP status code semantics (2xx/3xx/4xx/5xx) and the request/response model.
- Percentiles vs averages (p50/p95/p99) at a basic level.
- Kubernetes service exposure (W11) and the idea of a load balancer in front of an app.

**Tools already installed**
- AWS CLI v2 (`aws --version` should report 2.x), authenticated via IAM Identity Center / SSO (`aws sso login`).
- A running Prometheus + Grafana stack from W16 (local kube-prometheus-stack, or Amazon Managed Prometheus/Grafana), OR access to CloudWatch with a sample metric source.
- `git` (use `git switch` / `git restore`, not the legacy checkout flow).

**Accounts / access**
- An AWS account reachable through IAM Identity Center with permission to read CloudWatch metrics. **No resources are created in this class** beyond optional read-only dashboards — cost is effectively zero.

**Files / repos**
- The course sample repo containing the **Order Tracking Platform** service description (used in the lab) and, if available, an exported metric set (request counts by status code, latency histogram).

---

# 4. Key Terms and Definitions

| Term | Definition | Real-world context |
|---|---|---|
| **SRE** | Engineering discipline that applies software-engineering practice to operations to make systems reliable, scalable, and operable. | "What happens when you ask a software engineer to design an ops team." Error budgets, automation, and SLOs are its signature tools. |
| **Reliability** | The probability that the service does the right thing for the user over a period of time. | A 200 response with the *wrong* order status is still unreliable. |
| **Availability** | The fraction of valid attempts that the service serves successfully. | Usually the headline SLI for request-driven services. |
| **Uptime** | Raw time a process/host is running. | The weakest reliability proxy — a host can be "up" while every request 500s. |
| **Golden signals** | Latency, traffic, errors, saturation — the four signals Google recommends measuring for any user-facing system. | The single most-quoted SRE interview concept. |
| **SLI** | Service Level Indicator — a quantitative measure of service behavior, ideally expressed as *good events / valid events*. | "Proportion of HTTP requests served in < 300 ms that returned non-5xx." |
| **SLI specification** | The precise definition of what counts as a *good event* and a *valid event*, plus the measurement window. | What SLO tooling (Sloth, OpenSLO, Datadog) actually ingests. |
| **SLI implementation** | The concrete query/metric source that produces the SLI number. | A Prometheus `rate()` ratio or a CloudWatch Metrics Insights query. |
| **SLO** | Service Level Objective — a target value (or range) for an SLI over a window. | "99.9% of valid requests succeed over a rolling 30 days." |
| **SLA** | Service Level Agreement — a contractual promise, usually with financial penalties (service credits). | Sold to customers; deliberately looser than the SLO. |
| **Error budget** | The allowed amount of unreliability: `1 − SLO`, expressed as failures or downtime over the window. | The spendable currency that balances feature velocity vs reliability (depth in Class 2). |
| **Critical User Journey (CUJ)** | An end-to-end path a user takes that the business cares about (e.g., "check order status"). | The unit SLOs should be designed around, not individual microservices. |
| **Measurement window** | The time span the SLI is evaluated over; **rolling** (last N days, moves continuously) vs **calendar** (resets monthly). | Rolling windows avoid "month-end amnesty"; calendar windows align with contracts. |

---

# 5. Tools Used

| Tool | Why it is used |
|---|---|
| **Prometheus + PromQL** | Primary open-source SLI source; `rate()` and recording rules compute good/valid event ratios (from W16). |
| **Grafana** | Visualize SLIs and (in Class 2) burn rate; SLO panels and dashboards. |
| **AWS CloudWatch (Metrics, Metrics Insights, Dashboards, Alarms)** | AWS-native SLI source and alerting; Metrics Insights (SQL-like) computes availability from counts. |
| **AWS CLI v2** | Pull metric data (`aws cloudwatch get-metric-data`) to compute SLIs from the terminal. |
| **A text editor / Git repo** | Author the SLI specification as a versioned artifact (SLO-as-code preview). |
| **Whiteboard / diagram tool** | Map golden signals and CUJs onto the request path. |

---

# 6. AWS Services Used

| Service | How it connects to this class |
|---|---|
| **Amazon CloudWatch Metrics** | Stores request counts, error counts, and latency statistics that become SLI inputs. |
| **CloudWatch Metrics Insights** | SQL-like queries over metrics; computes availability ratios without exporting to a spreadsheet. |
| **CloudWatch Dashboards** | Render the golden signals and the computed SLIs for a service. |
| **CloudWatch Alarms** | Introduced here, used heavily in Class 2 for burn-rate alerting. |
| **Application Load Balancer (ALB) metrics** | `RequestCount`, `HTTPCode_Target_5XX_Count`, `TargetResponseTime` are ready-made golden-signal sources for web services. |
| **Amazon Managed Service for Prometheus / Grafana** | Managed alternative if students prefer the Prometheus path on AWS. |

---

# 7. Azure and GCP Comparison Notes

| Reliability area | AWS | Azure | GCP |
|---|---|---|---|
| Metrics | CloudWatch Metrics | Azure Monitor Metrics | Cloud Monitoring Metrics |
| Logs | CloudWatch Logs | Azure Monitor Logs (KQL) | Cloud Logging |
| Alerts | CloudWatch Alarms | Azure Monitor Alerts | Cloud Monitoring Alerting |
| Native SLO objects | (composite alarms / custom) | Azure Monitor SLOs (preview) | **Cloud Monitoring Service Monitoring SLOs** (first-class SLI/SLO/error-budget objects) |

GCP's Cloud Monitoring has the most mature *native* SLO object model (good-events/total-events SLIs, burn-rate alerts built in). The concepts are identical across clouds; only the SLI math is portable, the implementation is not. Keep AWS as the primary teaching platform.

---

# 8. Time-Boxed Instructor Agenda (3 hours)

| Time | Activity |
|---:|---|
| 0:00 – 0:10 | Opening: "What does *reliable* mean?" + where SRE sits vs W16 observability |
| 0:10 – 0:30 | SRE role, error-budget mindset, how SRE differs from classic ops |
| 0:30 – 0:50 | Reliability vs availability vs uptime; "up but broken" teaching point |
| 0:50 – 1:15 | **The four golden signals** (latency, traffic, errors, saturation) mapped to SLIs |
| 1:15 – 1:25 | Break |
| 1:25 – 1:55 | SLI **specification**: good/valid events, request-based vs window-based; latency thresholds vs averages |
| 1:55 – 2:15 | SLI / SLO / SLA distinction; nines→downtime table; why SLA < SLO |
| 2:15 – 2:35 | Demo: compute availability + latency SLI from real metrics (Prometheus / CloudWatch) |
| 2:35 – 3:00 | Lab kickoff (CUJ-driven SLI selection), discussion, knowledge check, recap |

A short break is built in at 1:15. Lab work continues as homework if time runs short.

---

# 9. Instructor Lesson Plan

1. **Open with a provocation (0:00).** Ask: "Our status page is green and CPU is 30%. Are we reliable?" Collect answers, then reveal a screenshot of users getting 500s. Anchor the whole class on *user-perceived* reliability. Tie back to W16: "You can already *see* the system; today we decide what *good* means."
2. **Define SRE (0:10).** Explain that SRE applies software engineering to operations and that its distinguishing feature is the **error budget** — a quantified permission to be imperfect. Pause for questions: "How is this different from the ops team you've seen?"
3. **Reliability vs availability vs uptime (0:30).** Walk the table, then the "EC2 up, ALB healthy, CPU normal, users getting 500s" example. Teaching tip: keep returning to "the user does not feel CPU."
4. **Golden signals (0:50).** Introduce all four by name. **Flag the sequencing honestly:** saturation gets full treatment in W22 (capacity), but it must be *named* here so the four are taught as a set. Map each signal to a concrete SLI on the whiteboard. Pause for questions.
5. **Break (1:15).**
6. **SLI specification (1:25).** This is the senior-level core. Introduce *good events / valid events*. Show that "request success rate" is incomplete until you say what a *valid* request is (exclude 4xx? exclude health checks? exclude load tests?). Contrast **request-based** SLIs (ratio of events) with **window-based** SLIs (ratio of good *time slices*). Then attack latency: averages lie; teach threshold-based latency SLIs ("proportion of valid requests faster than 300 ms").
7. **SLI/SLO/SLA + nines (1:55).** Walk the nines→downtime table aloud (let students feel that 99.9% ≈ 43 min/month). Then state the rule: **SLA must be looser than the SLO** so you have a safety margin before you owe credits.
8. **Demo (2:15).** Run the availability + latency SLI computation live (Section 12).
9. **Lab + wrap (2:35).** Kick off the CUJ lab; reserve the last 10 minutes for the knowledge check and recap.

Transitions: each section ends with one sentence connecting forward ("now that we can *name* the signal, let's *specify* it precisely…").

---

# 10. Instructor Lecture Notes

**SRE is operations with an engineering contract.** The thing that makes SRE different from "ops with a new title" is that it refuses to chase 100%. It says: pick a target (SLO), measure honestly (SLI), and treat the gap (error budget) as a *budget you are allowed to spend* on shipping features and tolerating risk. Talking point: *"100% is the wrong target for almost everything. The right target is the lowest reliability your users won't notice — anything beyond that is money you could have spent on features."*

**Reliability is a user-side property.** A request that returns HTTP 200 with stale or wrong data is a reliability failure even though every host is green. Common misconception: "the dashboards are green so we're fine." Counter it with the order-status example — the API returns 200 but the status is 3 days stale because the worker is wedged.

**The four golden signals (name them, every time).**
- **Latency** — how long requests take. *Split successful vs failed latency* — a fast 500 is not a win, and slow errors inflate your "good" latency if you don't separate them.
- **Traffic** — demand on the system (requests/sec, sessions, queue enqueue rate). Context for everything else.
- **Errors** — rate of requests that fail (explicit 5xx, wrong content, policy-violating slowness).
- **Saturation** — how "full" the system is (the most constrained resource). *We name it here; we engineer it in W22.* Misconception: students think CPU% = saturation. Saturation is about the bottleneck resource and headroom, and it's a *leading* signal of future failure.

**SLI specification vs implementation.** *"An SLI isn't 'success rate.' An SLI is: the number of HTTP requests that returned non-5xx within 1000 ms, divided by the number of HTTP requests that weren't health checks or internal probes, over the last 30 days."* The first is a vibe; the second is something Sloth/OpenSLO can compile and CloudWatch can alarm on. Always force the question: **what is a valid event, and what makes an event good?**

**Why averages lie (latency).** If 95% of requests take 50 ms and 5% take 8 seconds, the average might be ~450 ms — which describes *nobody's* experience. Teach threshold SLIs: "proportion of valid requests faster than 300 ms" — a count of good events, alarmable, percentile-honest.

**SLA looser than SLO.** Enterprise context: you publish an SLO of 99.9% internally but sign an SLA of 99.5% with customers. The 0.4% gap is your **safety margin** — you can miss your internal goal and still not owe service credits, which buys time to react before it becomes a financial/legal event. Talking point: *"Never let your SLA equal your SLO. The day they're equal, every internal miss is a contract breach."*

**Composite / dependency reliability (preview).** You cannot be more available than your hard dependencies multiplied together. If your API depends on a DB at 99.9% and a payment provider at 99.95%, your ceiling is ≈ 99.85% before you even add your own failures. (Math detail lands in Class 2.)

---

# 11. Whiteboard Explanation

**Topic: Mapping the four golden signals onto a real request path.**

```text
        TRAFFIC (req/s)                       SATURATION (how full?)
            |                                  - DB connections in use
            v                                  - worker queue depth
   User --> ALB --> API Service --> Database   - CPU/mem headroom (W22)
            |          |               |
            |          |               +--> LATENCY (DB query time)
            |          +--> ERRORS (5xx, timeouts, wrong data)
            |          +--> LATENCY (p95 / p99 request time)
            +--> AVAILABILITY = good responses / valid responses
```

**Step by step**
1. **Traffic** enters at the ALB — measure request rate; it frames every other number.
2. **Errors** are counted at the API: 5xx, timeouts, and *semantic* failures (200 with wrong data).
3. **Latency** is measured per request — track p95/p99 of **successful** requests, plus a threshold SLI ("% under 300 ms").
4. **Saturation** is the most-constrained resource (DB connections, queue depth, CPU headroom) — the leading indicator.
5. **Availability SLI** = good events / valid events at the user-facing boundary.

**Enterprise version.** In production this path fans out: ALB → API → cache → primary DB + read replica → async worker → external shipping API. Each hop has its own golden signals, but the SLO is owned at the **CUJ boundary** ("user can check order status"), not at each microservice. Draw the CUJ as a box wrapping the whole path.

---

# 12. Instructor Demo Script

**Demo title:** Compute a real availability SLI and a latency-threshold SLI from live metrics.

**Demo objective.** Move students off spreadsheets — show that an SLI is a *query*, not a hand-typed number.

**Required setup.** Either (A) a Prometheus stack from W16 scraping an app that exposes `http_requests_total{status=...}` and a latency histogram `http_request_duration_seconds_bucket`, OR (B) an AWS ALB emitting CloudWatch metrics. Read-only; no resources created.

### Option A — Prometheus / PromQL

**Availability SLI (request-based, good/valid):**
```promql
# good events = non-5xx responses ; valid events = all responses except health checks
sum(rate(http_requests_total{job="order-api", code!~"5..", handler!="/healthz"}[30d]))
/
sum(rate(http_requests_total{job="order-api", handler!="/healthz"}[30d]))
```
Expected output: a value like `0.9987` → **99.87%** availability SLI over 30 days.

**Latency SLI (threshold-based — % of requests under 300 ms):**
```promql
sum(rate(http_request_duration_seconds_bucket{job="order-api", le="0.3"}[30d]))
/
sum(rate(http_request_duration_seconds_count{job="order-api"}[30d]))
```
Expected output: e.g. `0.962` → **96.2% of requests served under 300 ms**. Explain why this beats reporting an average.

### Option B — AWS CloudWatch (CLI v2 + Metrics Insights)

**Pull request and 5xx counts (last 30 days, daily):**
```bash
aws cloudwatch get-metric-data \
  --start-time "$(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time   "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --metric-data-queries '[
    {"Id":"reqs","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"RequestCount","Dimensions":[{"Name":"LoadBalancer","Value":"app/order-api/abc123"}]},"Period":86400,"Stat":"Sum"}},
    {"Id":"err5xx","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"HTTPCode_Target_5XX_Count","Dimensions":[{"Name":"LoadBalancer","Value":"app/order-api/abc123"}]},"Period":86400,"Stat":"Sum"}},
    {"Id":"availability","Expression":"(SUM(reqs)-SUM(err5xx))/SUM(reqs)","Label":"Availability SLI"}
  ]'
```
Expected output: a `Values` array; the `availability` series resolves to ~`0.9987`. Explain that `Expression` is doing the good/valid math *server-side* — no spreadsheet.

**Latency:** add a `TargetResponseTime` metric with `Stat: "p95"` and show p95 directly; note CloudWatch percentile stats and that p95 ≠ average.

**What to explain at each step.** (1) The denominator is *valid* events — we excluded health checks. (2) We separated 5xx from 4xx (client errors usually aren't *our* SLO breach). (3) The query is the artifact; it can live in version control.

**Common demo failure points & recovery.**
- *Empty metric data:* wrong `LoadBalancer` dimension value — run `aws elbv2 describe-load-balancers` to get the ARN suffix.
- *PromQL returns NaN:* the metric/label doesn't exist — `curl localhost:9090/api/v1/label/__name__/values` to confirm names.
- *Clock/date flag:* `date -u -d` is GNU; on macOS use `date -u -v-30d`.

**Cleanup.** None — read-only. If you created a temporary dashboard, delete it: `aws cloudwatch delete-dashboards --dashboard-names order-api-slo-demo`.

---

# 13. Student Lab Manual

**Lab title:** CUJ-driven SLI selection and specification for the Order Tracking Platform.

**Lab objective.** Choose SLIs from *critical user journeys*, then write at least one as a formal good/valid-events specification and compute it from data.

**Estimated time:** 45–60 minutes.

**Student prerequisites.** Sections 4 and 12 of this class; read access to CloudWatch or the provided metric export.

**Architecture overview**
```text
Application: Order Tracking Platform
Components:
- Web frontend (static + API calls)
- Order Tracking REST API
- PostgreSQL database
- Background notification worker
- External shipping provider API

Critical User Journeys (CUJs):
  CUJ-1: Customer opens the page and sees current order status   (most important)
  CUJ-2: Customer receives a shipment notification               (async)
Business requirement: customers can check order status quickly and reliably.
```

### Step-by-step instructions

**Step 1 — Identify CUJs.** Write down the 1–2 journeys the business actually cares about. (Start from the user, not the architecture.)

**Step 2 — Map golden signals to CUJ-1.** For "see current order status," fill this table:

| Golden signal | What it means for CUJ-1 | Candidate SLI |
|---|---|---|
| Traffic | Status-check requests/sec | (context only) |
| Errors | Status request returns 5xx / wrong/stale status | Request success rate |
| Latency | Time to render status | % of requests < 300 ms |
| Saturation | DB connection pool / worker queue full | (W22 depth) |

**Step 3 — Write one SLI as a specification.** Complete this template (this is the deliverable that matters):

```text
SLI name: Order-status availability
Good event:   HTTP response with code != 5xx AND served in < 1000 ms
Valid event:  any request to GET /orders/{id}/status that is NOT a health
              check (/healthz) and NOT an internal load test (header X-Loadtest)
Request- or window-based: request-based
Measurement window: rolling 30 days
SLI = good events / valid events
```

**Step 4 — Compute it.** Run the PromQL or CloudWatch query from Section 12 (adapt the handler/dimension to `/orders/{id}/status`). Record the number.

**Commands students should run** (Prometheus path):
```promql
# `loadtest` is a series label the exporter sets from the X-Loadtest request header
# (loadtest="true" for synthetic traffic). The handler is already scoped to the
# orders status route, so no /healthz term is needed in either clause.
sum(rate(http_requests_total{handler="/orders/:id/status", loadtest="false", code!~"5.."}[30d]))
/
sum(rate(http_requests_total{handler="/orders/:id/status", loadtest="false"}[30d]))
```

**Expected output.** A ratio between 0 and 1, e.g. `0.9981` → 99.81% — note whether that would pass a 99.9% SLO (it would *miss*).

### Validation checklist
- [ ] At least one SLI per CUJ, sourced from a golden signal.
- [ ] One SLI written in full good/valid-events specification form.
- [ ] The specification names what is *excluded* from valid events.
- [ ] The SLI was computed from data, not guessed.
- [ ] A latency SLI uses a *threshold*, not an average.

### Troubleshooting tips
- If your SLI is suspiciously 100%, you probably forgot to count failures (check the numerator filter).
- If it's near 0%, your label filter likely matches nothing — list label values first.

### Cleanup
None — read-only queries. Delete any temporary dashboard you created.

### Reflection questions
1. Why did you exclude health checks from *valid* events? What breaks if you don't?
2. Which CUJ would you defend first if you could only have one SLO? Why?
3. Your latency SLI is 96% under 300 ms; is that good? What would the *user* say?

### Optional challenge
Express the same SLI as a **window-based** SLI (good *minutes* / valid *minutes*, where a minute is "good" if its error ratio < 1%) and discuss when window-based beats request-based (low-traffic services).

---

# 14. Troubleshooting Activity

**Incident title:** "Everything is green, but customers can't see their orders."

**Business impact.** Support tickets spike; customers believe orders are lost; trust erodes during peak shipping season.

**Symptoms.**
- Status page: green. CPU: 30%. ALB health checks: passing. No CloudWatch alarms firing.
- Support reports: ~8% of customers see "status unavailable" or a status that is 2–3 days stale.

**Starting evidence.**
```text
ALB RequestCount: normal
HTTPCode_Target_5XX_Count: near zero
TargetResponseTime p95: 180 ms (healthy)
Worker queue depth (custom metric): 240,000 and climbing
notification_worker_last_success_timestamp: 71 hours ago
```

**Student investigation steps.**
1. Ask: which *golden signal* is unmonitored here? (Saturation of the worker queue; freshness of async data.)
2. Map the symptom to a CUJ — is the failing journey CUJ-1 (status read) or CUJ-2 (notification/freshness)?
3. Check whether the existing SLIs even *cover* staleness. (They don't — availability and latency look perfect.)
4. Determine why no alarm fired (no SLI exists for data freshness / queue saturation).

**Expected root cause.** The worker is wedged; status data is stale. The team measured request-path golden signals (errors/latency/traffic) but never defined a **freshness** SLI or a **saturation** SLI for the async path, so the failing CUJ is invisible.

**Correct resolution.**
- Add a **freshness SLI**: "≥ 99% of orders have a status updated within 5 minutes of the source event."
- Add a **saturation SLI/alert** on worker queue depth.
- Restart/scale the worker; backfill stale statuses.

**Common wrong paths.** Chasing CPU; adding more API replicas (the API was never the problem); concluding "monitoring is fine because nothing is red."

**Instructor hints.** "Green dashboards measured the wrong journey." Point at the four golden signals: which one had no SLI?

**Preventive action.** Design SLIs from CUJs (including async/freshness) up front; include saturation as a leading signal even before W22's deep dive.

---

# 15. Scenario-Based Discussion Questions

1. **Product asks for 100% uptime.** *Theme:* 100% is the wrong target; reliability has marginal cost; pick the lowest reliability users won't notice. *Follow-up:* "What would 99.99% cost you in architecture vs 99.9%?"
2. **Your SLA and SLO are both 99.9%.** *Theme:* no safety margin; every internal miss is a breach. *Follow-up:* "Where should each number sit, and why?"
3. **An engineer reports availability as a monthly average of daily uptimes.** *Theme:* averaging hides bad days; rolling windows; good/valid events. *Follow-up:* "How does that differ from good-events/valid-events?"
4. **Should a 200 with stale data count as a success?** *Theme:* semantic correctness, freshness SLIs. *Follow-up:* "How would you measure 'fresh'?"
5. **Two teams want one SLO each per microservice.** *Theme:* SLOs belong to CUJs, not services; sprawl. *Follow-up:* "Which user journey are you actually protecting?"
6. **Latency SLO written as 'average < 300 ms'.** *Theme:* averages lie; threshold/percentile SLIs. *Follow-up:* "Rewrite it so it describes a real user."
7. **You depend on a payment API at 99.95% and a DB at 99.9%.** *Theme:* dependency ceiling; you can't exceed the product of hard deps. *Follow-up:* "What's your realistic max before your own failures?"

---

# 16. Knowledge Check (with Answer Key)

1. (MC) The four golden signals are: (a) CPU, memory, disk, network (b) **latency, traffic, errors, saturation** (c) SLI, SLO, SLA, error budget (d) p50, p95, p99, max.
2. (T/F) An SLI should be expressed as good events divided by valid events. **True.**
3. (Short) Why should the SLA be looser than the SLO? **To create a safety margin so an internal miss doesn't immediately breach the contract.**
4. (MC) Which is a *window-based* SLI? (a) % of requests under 300 ms (b) **% of 1-minute slices with error ratio < 1%** (c) total request count (d) average latency.
5. (T/F) A request returning HTTP 200 always counts as a good event. **False — stale/wrong content can be a failure (semantic correctness/freshness).**
6. (Short) Why do averages mislead for latency? **They hide tail behavior; a small slow tail can make the average describe no real user.**
7. (Calc) An availability SLO of 99.9% over 30 days allows how much downtime? **≈ 43 minutes 12 seconds** (0.001 × 30 × 24 × 60 = 43.2 min). (See nines table below.)
8. (MC) Saturation measures: (a) error rate (b) request rate (c) **how full the most-constrained resource is** (d) latency percentile.
9. (Short, troubleshooting) Dashboards are green but customers see stale data and no alarm fires. What SLI is missing? **A freshness (and/or async saturation) SLI.**
10. (Short, troubleshooting) Your availability SLI reads 100% during a known outage. Likely cause? **The numerator/denominator filter is wrong — failures aren't counted, or health checks dominate valid events.**
11. (AWS) Which CloudWatch feature computes availability from request and 5xx counts without exporting data? **Metrics Insights / metric math `Expression`.**
12. (AWS) Which ALB metrics give you errors and latency golden signals? **`HTTPCode_Target_5XX_Count` and `TargetResponseTime`.**

**Nines → downtime budget (memorize this):**

| Availability SLO | Downtime / 30 days | Downtime / year |
|---|---|---|
| 99% (two nines) | ~7h 12m | ~3d 15h |
| 99.9% (three nines) | ~43m 12s | ~8h 46m |
| 99.95% | ~21m 36s | ~4h 23m |
| 99.99% (four nines) | ~4m 19s | ~52m 36s |
| 99.999% (five nines) | ~25s | ~5m 15s |

---

# 17. Homework Assignment

**Title:** SLI specification for a service of your choice.

**Scenario.** You are the SRE for one of: Login API, Payment API, Reporting dashboard, File upload service, or Notification worker. Product wants to know whether it is reliable.

**Tasks.**
1. Identify the 1–2 **critical user journeys**.
2. Map all **four golden signals** to the service (name each).
3. Write **three SLIs**, at least one as a full good/valid-events **specification** (with exclusions and window).
4. Include one **latency** SLI expressed as a threshold (not an average).
5. Identify one metric that would be a **bad SLI** and explain why.
6. State the **measurement window** (rolling vs calendar) and justify it.

**Deliverables.** A Markdown document:
```text
Service Name:
Critical User Journeys:
Golden signals (latency / traffic / errors / saturation): mapping for each
SLI 1 (full specification): good event / valid event / window
SLI 2:
SLI 3 (latency threshold):
Bad SLI example + why:
Measurement window + justification:
```

**Submission format.** Markdown in the course repo, filename `week-21-class-01-sli-spec-<name>.md`.

**Estimated time:** 60–90 minutes.

**Grading criteria.** CUJ identified (15%); all four golden signals named & mapped (20%); at least one valid good/valid spec with exclusions (30%); latency expressed as threshold (15%); bad SLI justified (10%); window justified (10%).

**Advanced challenge.** Write the strongest SLI as **SLO-as-code** stub (Sloth or OpenSLO YAML) — you will complete the SLO/burn-rate portion in Class 2.

---

# 18. Common Student Mistakes

| Mistake | Why it happens | Fix |
|---|---|---|
| Picking CPU as the primary SLI | CPU is easy and familiar | Use CPU as a *diagnostic*; SLIs come from CUJs/golden signals |
| "Success rate" with no valid-event definition | They stop at the vibe | Always define good *and* valid events, including exclusions |
| Counting health checks / load tests in the denominator | Default scrape includes them | Exclude probes/synthetic traffic from *valid* events |
| Reporting latency as an average | Averages feel intuitive | Use threshold or percentile SLIs |
| SLA = SLO | They don't see the margin | Keep SLA looser than SLO |
| One SLO per microservice | Architecture-first thinking | Own SLOs at the CUJ boundary |
| Treating 200 as always-good | Status code ≠ correctness | Add freshness/correctness checks where it matters |

---

# 19. Real-World Enterprise Scenario

A retailer's product team demands "100% uptime" for the order-tracking platform because customers depend on it during peak season. The SRE team, instead of refusing, reframes the conversation with data: they identify the CUJ ("check order status"), map golden signals, and propose an internal **SLO of 99.9%** (≈ 43 min/month error budget) with a contractual **SLA of 99.5%** for the safety margin. They also discover the real risk isn't the request path (which is healthy) but **data freshness** from the async worker, so they add a freshness SLI. Constraints in play: a multi-region rebuild for 99.99% would cost ~6× the infrastructure and add operational toil, which leadership decides isn't justified for this journey. The SRE's job here is not to build the most reliable system — it's to find the *right* reliability and make the trade-off explicit, measurable, and codified.

---

# 20. Instructor Tips

- **Pacing:** the golden signals and SLI specification are the senior payload — don't let the SLI/SLO/SLA definitions (which students may know) eat the clock.
- **Lab support:** the most common stuck point is an empty query result; have students list label/dimension values *first*.
- **Struggling students:** give them the filled CUJ table and have them only write the good/valid spec.
- **Advanced students:** push them to the SLO-as-code stub and the window-based SLI challenge.
- **Honesty about sequencing:** name saturation now; tell students W22 engineers it. Tell them W16 is where the metrics they're querying come from.

---

# 21. Student Outcome Checklist

**Can explain:** SRE vs ops; reliability vs availability vs uptime; the four golden signals by name; SLI vs SLO vs SLA; why SLA < SLO; rolling vs calendar windows.

**Can build/configure:** an SLI specification in good/valid-events form; a PromQL or CloudWatch query that computes an availability and a latency-threshold SLI; a CUJ→golden-signal→SLI mapping.

**Can troubleshoot:** "green but broken" scenarios; identify which golden signal lacks an SLI; spot a wrong numerator/denominator in an SLI query.

---

# 22. Class Completion Checklist

**Instructor before ending:** golden signals taught as a named set; SLI specification (good/valid) demonstrated; nines→downtime table shown; demo computed a real SLI; lab kicked off.

**Student before leaving:** wrote one SLI as a specification; computed at least one SLI from data; can recite the four golden signals and the 99.9% downtime budget.

**Verify before Class 2:** every student has at least one written SLI specification — Class 2 turns these SLIs into SLOs, error budgets, and burn-rate alerts.

---

## Class Artifacts & Validation

The runnable artifacts this class uses live in two module repos:
[`labs/sre-incident-response/`](../../labs/sre-incident-response/) (the SLI/SLO spec
and the SLI math tools) and [`labs/observability-stack/`](../../labs/observability-stack/)
(the live Prometheus stack whose RED recording rules *are* the SLI implementation the
demo and lab query). Commands are run from each module's root. Tool-guarded gates
degrade to a `[SKIP]`/parse fallback where the tool is absent.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/sre-incident-response/solution/slo/slo.yaml | yaml (OpenSLO) | The SLI **specification** as code — 99.9% availability + 99%-under-300ms latency objectives (good/valid events) | `python3 -c "import yaml; list(yaml.safe_load_all(open('solution/slo/slo.yaml')))"` | PASS |
| 2 | labs/sre-incident-response/solution/scripts/nines_downtime.py | python | Availability target → allowed downtime per 30d/year (the nines→downtime table, computed not memorized) | `python3 -m py_compile solution/scripts/nines_downtime.py` + `python3 -m unittest discover -s tests -p 'test_nines.py'` | PASS |
| 3 | labs/sre-incident-response/solution/scripts/error_budget.py | python | Computes an availability SLI (good/total) and budget consumed/remaining from raw event counts | `PYTHONPATH=solution/scripts python3 -m unittest discover -s tests -p 'test_error_budget.py'` | PASS (solution; starter intentionally fails) |
| 4 | labs/observability-stack/solution/prometheus/rules/recording.rules.yml | promql | RED recording rules — the **SLI implementation** (rate, error-ratio, p50/p99) the demo's PromQL queries read | `promtool check rules solution/prometheus/rules/recording.rules.yml` | PASS (8 rules) |
| 5 | labs/observability-stack/solution/app/app.py + tests/test_app.py | python | Instrumented `/metrics` app exposing `http_requests_total` + duration histogram — the SLI data source | `python3 -m py_compile solution/app/app.py` + `python3 -m unittest discover -s tests` | PASS (11 tests) |
| 6 | labs/observability-stack/LIVE-OBS-EVIDENCE.txt | evidence | Real `run-demo.sh` run on `kind-course`: the availability/latency SLIs queried live over the Prometheus HTTP API (`error_ratio ≈ 0.099`) | `RUN_LIVE=1 ./run-demo.sh` (captured) | PASS — see labs/observability-stack/LIVE-OBS-EVIDENCE.txt |

Backing-lab status banners: `labs/sre-incident-response/README.md` (Validated;
28/28 fast-mode gates) and `labs/observability-stack/README.md` (Validated; 59 gates
pass, live kind run committed). Two full-tool gates in the SRE lab were marked
**DEFERRED** for `oslo` (OpenSLO CLI, not installed); the `slo.yaml` parse gate above
is the lighter local check that still runs.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — OpenSLO `slo.yaml`, two Python SLI tools, the live Prometheus recording rules + instrumented app (not fences).
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (rows 1–6 above; live SLI query captured in `LIVE-OBS-EVIDENCE.txt`).
- [x] Lab has **starter** (intentionally incomplete — `error_budget.py` TODOs, app/rule stubs) and **solution** (reference) versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** (both module READMEs).
- [x] **Cleanup/teardown** is provided and idempotent — the live obs demo always deletes `ns/lab-obs` on exit; the SLI/tools half creates no resources.
- [x] **Instructor answer key** exists — both module READMEs' "Instructor answer key" sections; this class's §16 knowledge check and §13 lab have answer keys.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — this class's §14 "green but broken" maps onto the obs lab's real `rate()`/`NaN` and pod-SD-annotation failures, plus the SRE lab's `broken/burn-rate-alerts.broken.yaml` fixture (carried into Class 2).
- [x] **Expected outputs** are shown for the demo and lab (§12 PromQL/CloudWatch outputs; module READMEs' "Expected results").
- [x] **Cost & security warnings** present — both labs are `$0`/local; this class's CloudWatch path is read-only (no resources created).
- [x] **Cross-references** to the module repos and to prior/next weeks are correct (W16 source of metrics; Class 2 turns these SLIs into SLOs/budgets/alerts).
- [x] The **artifact manifest** (§4.2) is present and every path resolves (verified with `ls`).
- [ ] *Not claimed:* the AWS CloudWatch Metrics Insights demo path (§12 Option B) is **read-only and account-dependent**; there is no committed live AWS evidence for this class — the validated live evidence is the Prometheus/kind path only.
