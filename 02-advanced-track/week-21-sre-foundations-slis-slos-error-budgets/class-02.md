# Week 21: SRE Foundations, SLIs, SLOs, and Error Budgets
> **▶ Runnable lab for this class:** [`labs/sre-incident-response/`](../../labs/sre-incident-response/) · [`labs/observability/`](../../labs/observability/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2 Package

**Week:** 21
**Track:** Unified DevOps · Cloud · SRE Track
**Class title:** SLOs, Error Budgets, On-Call, Incident Response, and Postmortems
**Class:** 2 of 2
**Duration:** 3 hours
**Audience:** Intermediate to advanced DevOps, Cloud Engineering, and SRE learners
**Primary cloud:** AWS
**Secondary exposure:** Azure and GCP

---

> **W16 vs W21 boundary.** W16 owns *observability framing* (instrumentation, dashboards, alert delivery). **W21 owns SLO depth**: error-budget math, burn-rate alerting policy, the error-budget governance document, and the operational practices (toil, on-call, incidents, postmortems) that the budget drives. When this class writes an alert, the *delivery* (PagerDuty/Opsgenie/SNS wiring) is W16 plumbing; the *burn-rate logic* is W21.

---

# 1. Class Overview

**Class title:** SLOs, Error Budgets, On-Call, Incident Response, and Postmortems

**Class purpose.** This class turns the SLIs from Class 1 into an operating system for reliability. Students learn to: convert availability targets into **downtime/event budgets** (not flat percentages), alert on **burn rate** with the multi-window multi-burn-rate method, codify SLOs as code (OpenSLO / Sloth), write an **error-budget policy** that says what *actually happens* when the budget is gone, measure and cap **toil**, run an **on-call rotation**, command an **incident** with defined roles, and write a **blameless postmortem**.

**How this class builds from Class 1.** Class 1 produced SLIs (good/valid events) and a nines→downtime intuition. Class 2 attaches a *target* (SLO), derives the *budget*, and builds the entire decision-and-response machine around spending that budget responsibly.

**What students will build, analyze, or practice.**
- Error-budget math in **minutes of allowed downtime** and **allowed failed events** per window, with budget *remaining* after consumption.
- A **multi-window multi-burn-rate** alert pair in both **PromQL** and **CloudWatch**.
- An **SLO-as-code** definition (OpenSLO and Sloth).
- A written **error-budget policy** (triggers, freeze scope, decision owner, override path).
- A **blameless postmortem** for a provided incident (full template + writing lab).

---

# 2. Quick Review of Class 1

**Review points.**
1. Reliability is user-perceived; uptime is the weakest proxy.
2. The four golden signals: latency, traffic, errors, saturation.
3. An SLI is *good events / valid events* over a window (specification vs implementation).
4. Latency SLIs use thresholds/percentiles, not averages.
5. SLI → SLO (target) → SLA (looser contractual promise).
6. SLOs are owned at the **critical user journey**, not per microservice.
7. 99.9% over 30 days ≈ 43m 12s of allowed downtime.

**Quick recall questions.** (1) Name the four golden signals. (2) What's the difference between an SLI specification and its implementation? (3) Why must the SLA be looser than the SLO?

**Common gaps from Class 1.** Students often still report flat percentages and haven't internalized that the budget is *time/events you can spend*. Bridge: "Last class you measured reliability. Today you'll *spend* the gap and decide what to do when it runs out."

---

# 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Convert** an SLO into an error budget expressed in allowed downtime minutes and allowed failed events per window, and compute budget *remaining*.
2. **Design** a multi-window, multi-burn-rate alerting strategy and implement it in PromQL and CloudWatch.
3. **Codify** an SLO as code using OpenSLO and Sloth.
4. **Write** an error-budget policy specifying triggers, freeze scope, decision owner, and override path.
5. **Define and measure** toil and apply the ~50% toil cap.
6. **Explain** on-call models (rotations, paging hygiene, escalation, follow-the-sun, human factors).
7. **Run** an incident with defined roles (Incident Commander, Communications, Ops/Scribe) and severity levels.
8. **Write** a blameless postmortem with actionable, owned follow-ups.

---

# 4. Prerequisites Students Should Already Know

- **Class 1:** SLIs as good/valid events, golden signals, nines→downtime table, CUJs.
- **W16:** Prometheus/PromQL, recording rules, alert routing (Alertmanager), CloudWatch alarms and SNS.
- **W9 CI/CD:** how a release gate works (the error-budget policy can gate deploys here).
- Tools installed: AWS CLI v2 (SSO), `kubectl` + a cluster (for Sloth, optional), a Prometheus stack from W16, and (optional) the `sloth` CLI or `opentofu`/`terraform` for IaC alarms.
- Lab outputs from Class 1: at least one written SLI specification.

---

# 5. Key Terms and Definitions

| Term | Definition | Real-world context |
|---|---|---|
| **Error budget** | Allowed unreliability = `(1 − SLO) × window`, expressed in downtime minutes or failed events. | The spendable currency of reliability. |
| **Budget burn** | The fraction of the error budget consumed so far in the window. | "We've burned 90% in 10 days." |
| **Burn rate** | How fast the budget is being consumed relative to "even" spend (1× = exactly on pace to exhaust at window end). | A 14.4× burn rate exhausts a 30-day budget in ~2 hours. |
| **Multi-window multi-burn-rate (MWMBR)** | Alerting that pairs a fast/high-burn short window with a slow/low-burn long window to catch both acute and chronic erosion with few false pages. | SRE Workbook ch. 5 canonical method. |
| **Error-budget policy** | A written, agreed governance document stating what happens when the budget is exhausted (e.g., feature freeze). | The artifact product + eng pre-commit to, removing per-incident arguments. |
| **SLO-as-code** | SLO definitions stored as version-controlled config (OpenSLO/Sloth) that generates alerts/recording rules. | Reliability becomes reviewable, diff-able, CI-gated. |
| **Toil** | Manual, repetitive, automatable, tactical work that scales with service growth and has no enduring value. | Capped at ~50% of an SRE's time. |
| **On-call** | The rotation responsible for responding to pages for a service. | Has sustainable limits and compensation/human-factor rules. |
| **Incident Commander (IC)** | The single person coordinating an incident's response (decides, delegates; does not fix hands-on). | The role that prevents chaos, not seniority. |
| **Blameless postmortem** | A written incident retrospective focused on systemic causes and fixes, not individual blame. | The cultural keystone of SRE. |
| **MTTD / MTTR** | Mean Time To Detect / To Recover. | Targets for incident-response improvement. |

---

# 6. Tools Used

| Tool | Why |
|---|---|
| **PromQL + recording rules** | Compute error ratio and burn rate; back MWMBR alerts. |
| **Alertmanager** (W16) | Route fast/slow burn alerts to page vs ticket. |
| **AWS CloudWatch alarms + metric math + composite alarms** | AWS-native burn-rate alerting. |
| **OpenSLO** | Vendor-neutral SLO spec language. |
| **Sloth** | Generates Prometheus SLO recording + MWMBR alert rules from a small spec. |
| **PagerDuty / Opsgenie / Amazon SNS** | Paging and escalation (delivery is W16 plumbing). |
| **A docs repo / runbook system** | Error-budget policy, runbooks, postmortems as version-controlled artifacts. |

---

# 7. AWS Services Used

| Service | Connection |
|---|---|
| **CloudWatch Alarms** | Threshold alarms on burn rate over short/long windows. |
| **CloudWatch metric math** | Compute burn rate = error ratio / (1 − SLO). |
| **CloudWatch composite alarms** | AND/OR-combine short+long-window alarms into one MWMBR page. |
| **Amazon SNS** | Deliver alarm notifications to paging integrations. |
| **AWS Chatbot / Incident Manager (AWS Systems Manager Incident Manager)** | Optional native incident response: escalation plans, runbooks, response teams. |

---

# 8. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Burn-rate alerting | CloudWatch metric math + composite alarms | Azure Monitor metric alerts | **Cloud Monitoring native burn-rate SLO alerts** |
| SLO objects | composite alarms / SLO-as-code tools | Azure Monitor SLOs (preview) | first-class SLO + error budget objects |
| Incident tooling | SSM Incident Manager | Azure Monitor + Logic Apps | Cloud Monitoring + PagerDuty integrations |

GCP again has native burn-rate SLO alerting; on AWS you assemble it from metric math + composite alarms or use Sloth/OpenSLO. Keep AWS primary.

---

# 9. Time-Boxed Instructor Agenda (3 hours)

| Time | Activity |
|---:|---|
| 0:00 – 0:12 | Review of Class 1; "spend the gap" framing |
| 0:12 – 0:35 | Error-budget **math**: downtime minutes, event budget, remaining budget |
| 0:35 – 1:05 | **Burn rate** + multi-window multi-burn-rate alerting (PromQL + CloudWatch) |
| 1:05 – 1:15 | Break |
| 1:15 – 1:35 | **SLO-as-code** (OpenSLO / Sloth) demo |
| 1:35 – 1:55 | **Error-budget policy** (the governance artifact) |
| 1:55 – 2:15 | **Toil** + **on-call** (rotations, paging, escalation, human factors) |
| 2:15 – 2:40 | **Incident response & command** (severity, roles) + **blameless postmortems** |
| 2:40 – 3:00 | Postmortem-writing lab kickoff, discussion, knowledge check, week recap |

A break is built in at 1:05.

---

# 10. Instructor Lesson Plan

1. **Review + reframe (0:00).** Recap SLIs; state today's thesis: *the error budget is a budget you spend, and everything else in SRE is the machinery for spending it well.*
2. **Budget math (0:12).** Move from "0.1%" to "43m12s" and to "N allowed failed requests," then to *remaining* budget. Pause: "If we've used 30 of 43 minutes, what's left?"
3. **Burn rate + MWMBR (0:35).** Build burn rate from first principles (1× = on pace), then derive the fast/slow pair. Show PromQL and CloudWatch. This is the Critical content — protect the time.
4. **Break (1:05).**
5. **SLO-as-code (1:15).** Show a Sloth/OpenSLO spec generating the alerts you just hand-wrote. "Reliability in version control."
6. **Error-budget policy (1:35).** Emphasize: an alert without a *policy* is noise. Walk the policy template.
7. **Toil + on-call (1:55).** Define toil precisely, the 50% cap, then rotations/paging/escalation and human factors (sleep, compensation, sustainable load).
8. **Incidents + postmortems (2:15).** Severity levels, IC/Comms/Ops/Scribe, status cadence; then the blameless norm and template.
9. **Lab + recap (2:40).** Kick off the postmortem-writing lab; close the week.

---

# 11. Instructor Lecture Notes

**Error budgets are time and events, not a percentage.** *"0.1% means nothing to a human. Say it as 43 minutes and 12 seconds a month, or 'we can serve 1,000 failed requests out of a million.' Now product and on-call both understand the stakes."* Build the three forms live:
- **Downtime budget:** `(1 − SLO) × window`. 99.9% over 30 days → 0.001 × 43,200 min = **43.2 min** (= 43m12s; here a 30-day window is 30×24×60 = 43,200 min).
- **Event budget:** `(1 − SLO) × valid events`. 99.9% over 1,000,000 valid requests → **1,000** allowed failures.
- **Remaining budget:** `allowed − consumed`. Burned 33 min of 43 → **~10 min left**; this is what the *policy* keys off.

**Burn rate (the senior concept).** Define burn rate as *how many times faster than even-pace* you're spending. A burn rate of **1×** exhausts the budget exactly at window end. So:
- 30-day budget, burn rate **14.4×** → exhausted in 30 days / 14.4 ≈ **2 days**? No — be careful: 14.4× is calibrated to **consume 2% of a 30-day budget in 1 hour** (the canonical fast-burn page). General rule: *time-to-exhaustion = window / burn_rate*. At 14.4×, 30 days/14.4 ≈ **50 hours**, and in **1 hour** it burns 1/(30×24)×14.4 = **2%** of the budget — hence the 1-hour fast page.

**Multi-window multi-burn-rate (MWMBR).** One threshold is a trap: too sensitive = pager fatigue; too slow = you miss outages. The canonical answer pairs windows:
- **Fast burn (page now):** burn rate ≥ **14.4×** over **1h** AND over **5m** (the short window confirms it's *current*, killing alerts for an outage that already ended).
- **Slow burn (ticket):** burn rate ≥ **6×** over **6h** AND over **30m** — catches chronic erosion that never trips the fast alert.
- (Many shops add a third tier: **3×** over **24h/2h**.)
*"Two windows so you don't page on a blip and don't sleep through a slow bleed."*

**Error-budget policy is the point.** *"An alert tells you the budget is burning. A policy tells you what you're allowed to do about it — before anyone is emotional at 2 a.m."* The policy names the trigger (e.g., budget exhausted), the consequence (freeze non-essential feature deploys; reliability work becomes top priority), the decision owner, and the override path.

**Toil.** Define crisply: manual, repetitive, automatable, tactical, no enduring value, scales with the service. *"If a script could do it and you'll do it again next week, it's toil."* Cap ~50% of an SRE's time; the rest is engineering that reduces future toil. Measure it (toil surveys, ticket categorization).

**On-call & human factors.** Rotations sized so pages are sustainable (a common heuristic: ≤ ~2 actionable pages per on-call shift); compensation/time-off-in-lieu; clear **escalation** (primary → secondary → manager); **follow-the-sun** to avoid night pages; every page must be **actionable** and link a **runbook**. *"A page that doesn't need a human is a bug in your alerting."*

**Incident response.** Severity levels (SEV1 customer-facing major outage → SEV3 minor). Roles: **Incident Commander** (coordinates, decides, never head-down fixing), **Communications lead** (stakeholder/status updates on a cadence), **Ops lead** (hands-on remediation), **Scribe** (timeline). Status updates on a fixed cadence even when "no change."

**Blameless postmortems.** Blameless ≠ accountability-free; it means we assume people acted reasonably with the info they had and we fix the *system*. Every postmortem yields **owned, dated action items**. *"The output of an incident is a better system, not a worse engineer."*

**Dependency ceiling.** You cannot be more available than the product of your hard dependencies. DB 99.9% × payment 99.95% ≈ **99.85%** ceiling before your own failures — so don't promise 99.99% on top of a 99.9% dependency.

---

# 12. Whiteboard Explanation

**Topic: From SLO to budget to burn-rate alert to decision.**

```text
SLO: 99.9% success over 30 days (rolling)
        |
        v
Error budget = (1 - 0.999) x window
   time:   0.001 x 43,200 min  = 43.2 min / 30 days
   events: 0.001 x 1,000,000   = 1,000 failed reqs / 30 days
        |
        v
Burn rate = (current error ratio) / (1 - SLO)
   error ratio 1.44%  ->  0.0144 / 0.001 = 14.4x   (FAST: page)
   error ratio 0.6%   ->  0.006  / 0.001 = 6x       (SLOW: ticket)
        |
        v
MWMBR ALERT
   FAST page : 14.4x over 1h AND over 5m
   SLOW tick : 6x   over 6h AND over 30m
        |
        v
ERROR-BUDGET POLICY
   budget exhausted -> freeze non-essential feature deploys,
                       reliability work = P0, IC for any SEV1
        |
        v
DECISION: ship feature? -> check remaining budget + policy, not opinion
```

**Step by step.** SLO → budget (time + events) → burn rate (error ratio normalized by 1−SLO) → MWMBR alerts (fast page / slow ticket) → policy converts a burning budget into an agreed action → the decision becomes data-driven.

**Enterprise version.** The Sloth/OpenSLO spec *generates* the recording rules and both alert tiers; Alertmanager routes fast→PagerDuty, slow→Jira; the policy is linked in the deploy pipeline (W9) so a deploy during an exhausted budget requires an explicit override.

---

# 13. Instructor Demo Script

**Demo title:** SLO-as-code → generated burn-rate alerts (Sloth), plus the equivalent CloudWatch alarm.

**Demo objective.** Show that one small spec produces the recording rules and MWMBR alerts you'd otherwise hand-write — and show the AWS-native equivalent.

**Required setup.** Prometheus + Alertmanager from W16; `sloth` CLI (`sloth version`). Optional AWS account for the CloudWatch path.

### Step 1 — Write the SLO spec (Sloth)
```yaml
# order-api-slo.yaml
version: "prometheus/v1"
service: "order-api"
labels:
  team: "orders-sre"
slos:
  - name: "requests-availability"
    objective: 99.9          # SLO target (%)
    description: "Order status requests succeed (non-5xx)."
    sli:
      events:
        error_query: sum(rate(http_requests_total{job="order-api",code=~"5..",handler!="/healthz"}[{{.window}}]))
        total_query: sum(rate(http_requests_total{job="order-api",handler!="/healthz"}[{{.window}}]))
    alerting:
      name: OrderApiHighErrorBudgetBurn
      page_alert:   { labels: { severity: page } }
      ticket_alert: { labels: { severity: ticket } }
```

### Step 2 — Generate rules
```bash
sloth generate -i order-api-slo.yaml -o order-api-slo-rules.yaml
```
**Expected output:** a Prometheus rules file containing recording rules for the error ratio over multiple windows AND the MWMBR alert pairs (14.4×/1h+5m page, 6×/6h+30m ticket, etc.) — generated, not hand-typed.

### Step 3 — The hand-written PromQL equivalent (so students see what Sloth made)
```promql
# Fast-burn page: 14.4x over BOTH 1h and 5m
(
  sum(rate(http_requests_total{job="order-api",code=~"5..",handler!="/healthz"}[1h]))
  / sum(rate(http_requests_total{job="order-api",handler!="/healthz"}[1h]))
) > (14.4 * 0.001)
and
(
  sum(rate(http_requests_total{job="order-api",code=~"5..",handler!="/healthz"}[5m]))
  / sum(rate(http_requests_total{job="order-api",handler!="/healthz"}[5m]))
) > (14.4 * 0.001)
```
(`0.001` = 1 − 0.999 = the budget. Slow-burn page swaps `14.4→6`, `1h→6h`, `5m→30m`.)

### Step 4 — CloudWatch equivalent (AWS-native burn-rate alarm)
```bash
# Burn rate metric math: error_ratio / (1 - SLO).  m1=5xx count, m2=request count.
aws cloudwatch put-metric-alarm \
  --alarm-name order-api-fastburn-1h \
  --alarm-description "Fast burn 14.4x over 1h" \
  --metrics '[
    {"Id":"m1","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"HTTPCode_Target_5XX_Count","Dimensions":[{"Name":"LoadBalancer","Value":"app/order-api/abc123"}]},"Period":3600,"Stat":"Sum"},"ReturnData":false},
    {"Id":"m2","MetricStat":{"Metric":{"Namespace":"AWS/ApplicationELB","MetricName":"RequestCount","Dimensions":[{"Name":"LoadBalancer","Value":"app/order-api/abc123"}]},"Period":3600,"Stat":"Sum"},"ReturnData":false},
    {"Id":"burn","Expression":"(m1/m2)/0.001","Label":"BurnRate","ReturnData":true}
  ]' \
  --evaluation-periods 1 --threshold 14.4 \
  --comparison-operator GreaterThanThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions arn:aws:sns:us-east-1:111122223333:sre-paging
```
Create a second alarm `order-api-fastburn-5m` (Period 300), then AND them with a **composite alarm** so you only page when *both* the 1h and 5m windows breach:
```bash
aws cloudwatch put-composite-alarm \
  --alarm-name order-api-fastburn \
  --alarm-rule "ALARM(order-api-fastburn-1h) AND ALARM(order-api-fastburn-5m)" \
  --alarm-actions arn:aws:sns:us-east-1:111122223333:sre-paging
```

**What to explain.** The composite alarm is the AWS realization of "multi-window" — the 5m confirms the burn is *current*. `treat-missing-data notBreaching` avoids paging when traffic is zero (division by tiny denominators).

**Common failure points & recovery.** Composite alarm references a non-existent alarm (create child alarms first); `m1/m2` division-by-zero on low traffic (use `notBreaching` + a minimum request-count guard); Sloth `--window` errors if `error_query`/`total_query` omit the `{{.window}}` template.

**Cleanup (avoid lingering alarm cost — alarms are cheap but clean up):**
```bash
aws cloudwatch delete-alarms --alarm-names order-api-fastburn order-api-fastburn-1h order-api-fastburn-5m
```
**Security/cost note:** the SNS topic for paging should have a least-privilege policy; CloudWatch alarms cost ~$0.10/alarm/month — delete demo alarms.

---

# 14. Student Lab Manual

**Lab title:** Error-budget math, an MWMBR alert, an error-budget policy, and a blameless postmortem.

**Lab objective.** Produce the four core SRE artifacts for the Shipping Status API.

**Estimated time:** 60–75 minutes (postmortem may extend into homework).

**Starting point from Class 1.** Use your SLI specification(s) from Class 1.

**Provided metrics (rolling 30 days):**
```text
Total valid requests:   500,000
Failed (5xx) requests:  1,100
p95 latency:            380 ms
Availability SLI:       99.78%
```

### Part A — Budget math (compute, don't guess)
Assume SLO = **99.9%** availability over 30 days.
1. Allowed downtime minutes: `(1 − 0.999) × 43,200 = ____ min`.
2. Allowed failed events: `(1 − 0.999) × 500,000 = ____`.
3. Actual failed events: `1,100`. **Budget remaining (events):** `500 − 1,100 = ____` → over budget by ____.
4. State whether the SLO is met and by how much.

*Expected:* 43.2 min; 500 allowed; remaining = −600 (budget blown; actual is 99.78% < 99.9%).

### Part B — MWMBR alert
Write the **fast-burn page** condition for this SLO in PromQL **or** as a CloudWatch composite alarm (use Section 13 as a template; budget = 0.001). Include both the 1h and 5m windows.

### Part C — Error-budget policy (governance artifact)
Complete this template:
```text
Service: Shipping Status API
SLO: 99.9% availability (rolling 30 days)   Error budget: 43.2 min / 500 events

Triggers & consequences:
  - Budget > 0 remaining        -> normal: ship features freely.
  - Budget exhausted (<=0)      -> FREEZE non-essential feature deploys;
                                    reliability work becomes P0;
                                    only reliability/security fixes deploy.
  - Fast-burn page fires        -> declare incident, page on-call, assign IC.
Decision owner: Orders SRE lead + Product owner (joint).
Override path:  VP Eng written approval, time-boxed, with a reliability
               remediation plan attached.
Review cadence: weekly SLO review; policy revisited each quarter.
```

### Part D — Blameless postmortem (use the incident in Section 15)
Fill the postmortem template in Section 21-adjacent (provided below in Part D template):
```text
# Postmortem: Shipping Status API stale-data outage
Status: final | Severity: SEV2 | Authors: <you> | Date: <date>

## Summary (<= 3 sentences)
## Impact (users, duration, budget consumed in minutes/events)
## Timeline (UTC; detect -> mitigate -> resolve)
## Root cause(s) (systemic, not "person X")
## Detection (how found? MTTD? what should have caught it sooner?)
## Resolution / recovery
## What went well
## What went poorly
## Action items (each: owner, due date, type=prevent/detect/mitigate)
## Lessons learned
```

### Validation checklist
- [ ] Budget computed in minutes AND events, with remaining.
- [ ] MWMBR alert has two windows and uses `budget = 1 − SLO`.
- [ ] Policy names trigger, freeze scope, decision owner, override path.
- [ ] Postmortem is blameless and has owned, dated action items.

### Cleanup
Delete any CloudWatch alarms you created (Section 13 cleanup). No other resources.

### Reflection questions
1. Your budget is blown by 600 events. What does your *policy* require right now?
2. Why two windows instead of one threshold?
3. Find one action item in your postmortem that prevents recurrence vs merely detects it faster.

### Optional challenge
Express the SLO as **OpenSLO** YAML and wire the policy into a CI/CD release gate (W9): block deploys when remaining budget ≤ 0 unless an override label is present.

---

# 15. Troubleshooting Activity

**Incident title:** SEV2 — Shipping Status API serving stale/failed status during peak; on-call not paged.

**Business impact.** ~8% of status checks fail or are 2–3 days stale for 71 hours; support volume up 3×; trust damage in peak season.

**Symptoms.**
- Availability SLI fell to 99.72% (SLO 99.9%) — budget exhausted mid-month.
- CPU alarm fired 18× (noise); no *user-facing* alert fired during two real incidents.
- Worker `last_success_timestamp` = 71 hours ago.

**Starting evidence.**
```text
CloudWatch alarm: order-api-cpu-high  -> 18 firings (CPU > 80%)
Burn-rate alarm:  (none configured)
notification_worker queue depth: 240,000 and climbing
Availability SLI (rolling 30d): 99.72%
```

**Student investigation steps.**
1. Why didn't anyone get paged? (Alerting is on CPU, not on burn rate / SLI.)
2. Compute burn rate: error ratio 0.28% / budget 0.1% = **2.8×** sustained — would the slow-burn (6× / 6h) page have fired? (Not at 2.8×, but a 3×/24h tier would — discuss tier choice.) The *fast* path missed because the burn was chronic, not acute — exactly what the slow window exists for.
3. Was there a *freshness/saturation* SLI? (No — same gap as Class 1's worker.)
4. What does the error-budget policy say once the budget is exhausted? (Freeze — but no policy existed.)

**Expected root cause.** Alerting was infrastructure-centric (CPU), there was no burn-rate alert on the SLI, no freshness SLI for the async path, and no error-budget policy — so a chronic, budget-exhausting failure ran for 71 hours unpaged and undecided.

**Correct resolution.**
- Add MWMBR burn-rate alerts on the availability SLI (and a 3×/24h slow tier for chronic burn).
- Add a freshness SLI + saturation alert on the worker queue.
- Delete/relegate the CPU alarm to diagnostics (not paging).
- Adopt the error-budget policy so exhaustion triggers a freeze and reliability P0.

**Common wrong paths.** Tuning the CPU threshold; adding API replicas; declaring "alerts are fine."

**Instructor hints.** "Acute vs chronic burn — which window catches a slow bleed?" and "Was the page even actionable?"

**Preventive action.** SLO-as-code generates the alert tiers; policy linked in the deploy pipeline; freshness SLI for async.

---

# 16. Scenario-Based Discussion Questions

1. **90% of the monthly budget burned in 10 days; product wants to ship a big feature.** *Theme:* invoke the policy, assess risk, canary/staged rollout, data over emotion. *Follow-up:* "What does your written policy *require* vs *recommend*?"
2. **A single hard-threshold alert pages 40×/week.** *Theme:* MWMBR reduces noise; every page must be actionable. *Follow-up:* "Which firings would the 5m confirmation window have suppressed?"
3. **An engineer caused the outage with a bad deploy.** *Theme:* blameless — fix the deploy guardrail, not the engineer. *Follow-up:* "What systemic change prevents the *next* person from doing this?"
4. **On-call is paged 6× a night.** *Theme:* unsustainable; human factors; follow-the-sun; alert hygiene. *Follow-up:* "What's the cap, and what do you cut first?"
5. **Toil is 70% of the team's week.** *Theme:* 50% cap; identify the top automatable task; protect engineering time. *Follow-up:* "Which toil, automated, frees the most hours?"
6. **SLA = SLO = 99.9%, and you just missed it.** *Theme:* no margin; contract breach; widen the gap. *Follow-up:* "What should each number become?"
7. **Leadership wants 99.99% but a hard dependency is 99.9%.** *Theme:* dependency ceiling; you can't exceed the product of hard deps. *Follow-up:* "What's the real ceiling, and what would raising it cost?"

---

# 17. Knowledge Check (with Answer Key)

1. (Calc) 99.9% over 30 days → allowed downtime? **≈ 43m12s (43.2 min = 0.001 × 43,200).**
2. (Calc) 99.9% over 2,000,000 valid requests → allowed failures? **2,000.**
3. (Short) Define burn rate. **Error ratio normalized by the budget (error_ratio / (1−SLO)); 1× exhausts the budget exactly at window end.**
4. (MC) MWMBR fast-burn page is typically: (a) 1× over 30d (b) **14.4× over 1h AND 5m** (c) CPU > 80% (d) any 5xx. 
5. (Short) Why use two windows? **The short window confirms the burn is *current*, suppressing alerts for outages that already ended; the long window avoids paging on blips.**
6. (T/F) An error-budget policy is just the alert threshold. **False — it's the governance doc stating consequences, owner, override.**
7. (Short) Define toil and its cap. **Manual/repetitive/automatable/tactical work with no enduring value that scales with the service; cap ~50% of time.**
8. (MC) The Incident Commander's job is to: (a) write all the code fixes (b) **coordinate and decide, delegating hands-on work** (c) talk to the press (d) approve budgets.
9. (Short) What makes a postmortem blameless? **Focus on systemic causes/fixes, assuming people acted reasonably; produces owned action items, not punishment.**
10. (Connect C1↔C2) You wrote an SLI in Class 1; what two things must you add to make it operable? **An SLO target and an error-budget policy + burn-rate alerting.**
11. (AWS, troubleshooting) Your CloudWatch burn-rate alarm pages constantly at low traffic. Fix? **`treat-missing-data notBreaching` and/or a minimum request-count guard to avoid tiny-denominator division.**
12. (AWS, connect) How do you realize "multi-window" in CloudWatch? **A composite alarm AND-combining a 1h and a 5m child alarm.**

---

# 18. Homework Assignment

**Title:** Complete the SRE operating package for your service.

**Scenario.** Continue with the service you chose in Class 1's homework.

**Tasks.**
1. SLO(s) with **error budget in minutes and events** and current remaining.
2. **MWMBR alert** (PromQL or CloudWatch composite alarm), both windows, both tiers (fast page + slow ticket).
3. **SLO-as-code** (Sloth or OpenSLO YAML).
4. **Error-budget policy** (trigger, freeze scope, decision owner, override path, review cadence).
5. **On-call summary** (rotation length, escalation chain, paging hygiene rule).
6. **Blameless postmortem** for a realistic incident (full template, owned/dated action items).

**Deliverables.** Markdown in the course repo: `week-21-class-02-sre-package-<name>.md` plus the SLO-as-code YAML file.

**Estimated time:** 2–3 hours.

**Grading criteria.** Budget in minutes+events with remaining (15%); valid MWMBR alert, two windows, two tiers (20%); SLO-as-code that would generate rules (15%); complete policy (20%); on-call summary (10%); blameless postmortem with owned action items (20%).

**Advanced challenge.** Wire the budget policy into a CI/CD gate (W9) and add a 3×/24h chronic-burn tier.

---

# 19. Common Student Mistakes

| Mistake | Why | Fix |
|---|---|---|
| Reporting budget as a flat % | Stops at 1−SLO | Convert to minutes AND events; track remaining |
| Single-threshold burn alert | Simpler to write | Use MWMBR (fast page + slow ticket) |
| Alert but no policy | Think the alert is the deliverable | The policy says what to *do*; without it the alert is noise |
| Blameful postmortem | Reflex to find "who" | Fix the system; assume good faith; owned action items |
| Treating toil as inevitable | It's the day job | Measure it, cap at 50%, automate the top item |
| IC does the fixing | Seniority = hands-on instinct | IC coordinates; Ops lead fixes |
| Promising > dependency ceiling | Ignoring hard deps | Multiply hard-dependency availabilities first |

---

# 20. Real-World Enterprise Scenario

A fintech's payments team has burned 95% of its monthly error budget by day 12 after a noisy third-party integration. Product wants to ship a redesigned checkout. Because the team had pre-agreed an **error-budget policy**, there is no argument: budget-near-exhaustion triggers a freeze on non-essential feature deploys and makes reliability P0; the redesign waits behind a canary plan. The on-call rotation (6-person, weekly, follow-the-sun across two regions) is protected from the resulting incident load because MWMBR alerts page only on actionable burn, not CPU noise. The fast-burn page during the integration outage triggered a SEV1 with a named IC, a comms lead posting 15-minute status updates, and a scribe; the resulting **blameless postmortem** produced three owned action items (circuit-breaker on the integration, a freshness SLI, a budget-aware deploy gate). The override path existed but wasn't used — leadership agreed the data didn't justify it. This is SRE working as designed: codified targets, automated burn detection, a pre-agreed policy, sustainable on-call, disciplined incident command, and a learning loop.

---

# 21. Instructor Tips

- **Protect the burn-rate block** — it's the Critical content; if pressed, cut the comparison tables, not MWMBR.
- **Make budget math concrete:** have students say "43 minutes," never "0.1%."
- **Struggling students:** give them the filled policy template and have them only change triggers/owners.
- **Advanced students:** OpenSLO + CI/CD gate + chronic-burn tier.
- **Lab support:** the common CloudWatch trap is the composite alarm referencing not-yet-created child alarms; create children first.
- **Postmortem culture:** model blamelessness yourself in how you discuss the lab incident.

---

# 22. Student Outcome Checklist

**Can explain:** error budgets as time/events; burn rate and MWMBR; why a policy is required; toil and the 50% cap; on-call/escalation/human factors; incident roles and severity; blameless postmortems; the dependency ceiling.

**Can build/configure:** budget math with remaining; an MWMBR alert in PromQL and CloudWatch (composite alarm); an SLO-as-code spec (Sloth/OpenSLO); an error-budget policy; a blameless postmortem.

**Can troubleshoot:** infrastructure-centric alerting gaps; chronic vs acute burn; noisy single-threshold alerts; missing-policy and missing-freshness scenarios.

---

# 23. Class Completion Checklist

**Instructor before ending:** budget math (minutes+events) taught; MWMBR shown in PromQL AND CloudWatch; SLO-as-code demoed; policy walked; toil/on-call/incident/postmortem all covered; postmortem lab kicked off.

**Student before leaving:** computed a budget with remaining; wrote one MWMBR alert; drafted a policy; started a blameless postmortem.

**Verify before closing the week:** every student has the four artifacts (budget math, burn-rate alert, policy, postmortem) at least in draft.

---

# 24. End-of-Week Summary

**What students learned this week.** Reliability is user-perceived and measurable; the four golden signals; SLIs as good/valid-event specifications; SLO targets and the nines→downtime budget; error budgets as spendable time/events; multi-window multi-burn-rate alerting; SLO-as-code; the error-budget policy; toil, on-call, incident command, and blameless postmortems.

**How Class 1 and Class 2 connect.** Class 1 *defines and measures* reliability (SLIs, golden signals, CUJs). Class 2 *operates* it — attaching targets, deriving budgets, alerting on burn, codifying SLOs, governing with policy, and running the human practices (on-call, incidents, postmortems) that spend the budget responsibly.

**How this prepares students for the next module.** W22 (Performance, Capacity & Scalability) takes the **saturation** signal named here and engineers it — load testing, capacity planning, autoscaling — directly extending the SLOs and budgets defined this week. These SLOs also feed platform golden paths (W20) and CI/CD release gating (W9), and the capstone (W23–W24) expects an SLO + error-budget policy as a portfolio artifact.

**What to review before the next module.** The nines→downtime table; the burn-rate formula and the fast/slow window pair; the difference between an SLI specification and its implementation; and your own service's error-budget policy.

---

## Class Artifacts & Validation

This class's runnable artifacts span three module repos:
[`labs/sre-incident-response/`](../../labs/sre-incident-response/) (budget math,
multi-window multi-burn-rate alerts, runbooks, the postmortem from a **live injected
incident**), [`labs/observability-stack/`](../../labs/observability-stack/) (a burn-rate
alert that is **proven to fire** by a `promtool` unit test on a live stack), and
[`labs/k8s-production-ops/`](../../labs/k8s-production-ops/) (the **live incident-response
operations** — rollout/rollback, PDB eviction, quota rejection, NetworkPolicy
enforcement). Commands run from each module's root.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/sre-incident-response/solution/scripts/error_budget.py | python | Error-budget math: consumed/remaining %, **burn rate**, time-to-exhaustion | `PYTHONPATH=solution/scripts python3 -m unittest discover -s tests -p 'test_error_budget.py'` | PASS (23 tests; starter intentionally fails) |
| 2 | labs/sre-incident-response/solution/slo/burn-rate-alerts.yaml | promql | Multi-window multi-burn-rate Prometheus alerts (14.4×/1h+5m page, 6×/6h+30m ticket) over the 0.001 budget | `promtool check rules solution/slo/burn-rate-alerts.yaml` | PASS (11 rules) |
| 3 | labs/sre-incident-response/broken/burn-rate-alerts.broken.yaml | promql | Troubleshooting fixture: parses as valid YAML but the page **never fires** (2 injected defects) | `diff broken/burn-rate-alerts.broken.yaml solution/slo/burn-rate-alerts.yaml` | PASS (both defects reproduce; documented in README) |
| 4 | labs/observability-stack/solution/prometheus/rules/alerting.rules.yml + tests/burn_rate_test.yml | promtool | A burn-rate alert plus a unit test that **asserts it FIRES** on a synthetic 5% error series (and stays silent when healthy) | `promtool test rules tests/burn_rate_test.yml` | PASS |
| 5 | labs/sre-incident-response/solution/runbooks/incident-command.md + high-error-rate.md + solution/postmortem-template.md | markdown | IC/Comms/Ops incident-command runbook, high-error-rate triage, blameless postmortem template | reviewed against README "Instructor answer key"; referenced by `error_budget.py` for budget-spent | PASS (artifacts present) |
| 6 | labs/sre-incident-response/solution/drill/run-drill.sh → LIVE-INCIDENT-EVIDENCE.txt | shell + evidence | **Live injected-incident drill** on `kind-course`: inject 503 readiness fault → observe outage (endpoints=0) → `rollout undo` → verify HTTP 200; postmortem written from the real timeline | `RUN_LIVE=1 ./solution/drill/run-drill.sh` (captured) | PASS — see labs/sre-incident-response/solution/drill/LIVE-INCIDENT-EVIDENCE.txt |
| 7 | labs/sre-incident-response/solution/postmortems/2026-injected-readiness-failure.md | markdown | Blameless postmortem grounded in the real drill timeline (trigger vs latent `maxUnavailable: 100%` condition, owned/dated action items) | cross-checked against `LIVE-INCIDENT-EVIDENCE.txt` timestamps | PASS |
| 8 | labs/k8s-production-ops/solution/drills/run-drills.sh → evidence/LIVE-OPS-EVIDENCE.txt | shell + evidence | **Live incident operations** on kind: rollout/rollback (stuck `ImagePullBackOff` → `undo`), PDB eviction `429`, quota `Forbidden`, NetworkPolicy ALLOW→BLOCK→ALLOW | `RUN_LIVE=1 ./solution/drills/run-drills.sh` (captured) | PASS — see labs/k8s-production-ops/evidence/LIVE-OPS-EVIDENCE.txt |

Backing-lab status banners: `labs/sre-incident-response/README.md` (Validated; live
injected-incident drill committed), `labs/observability-stack/README.md` (Validated;
burn-rate alert proven to FIRE), `labs/k8s-production-ops/README.md` (Validated; all
four drills ran live on `kind-course` + a Calico cluster). The SRE lab's `oslo` and
`promtool` gates were marked **DEFERRED** in its README at authoring time; `promtool`
is in fact present here and row 2 above passes — `oslo` (OpenSLO CLI) remains the only
deferred gate, with `python3 -c "import yaml; ..."` as the lighter local parse check.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — burn-rate math (Python), MWMBR alert rules (PromQL), runbooks/postmortem (Markdown), and live drill scripts (Shell) on disk, not fences.
- [x] Each artifact passes (or documents) its **validation gate** from §3; output captured (rows 1–8; live runs captured in two committed `LIVE-*-EVIDENCE.txt` files).
- [x] Lab has **starter** (intentionally incomplete — `error_budget.py` burn-rate TODOs, drill fault-injection/recovery TODOs, PDB/NetworkPolicy stubs) and **solution** versions.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** (all three module READMEs).
- [x] **Cleanup/teardown** is provided and idempotent — every live drill deletes its namespace on exit via a `trap` (`ns/lab-incident`, `prodops-*`, the throwaway Calico cluster); CloudWatch demo alarms have a documented delete.
- [x] **Instructor answer key** exists — all three module READMEs' "Instructor answer key" sections; this class's §17 knowledge check and §14 lab (Parts A–D) have answer keys.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — the SRE `broken/burn-rate-alerts.broken.yaml` fixture (2 valid-but-dead-alert defects) **and** the live injected 503/`maxUnavailable: 100%` incident, plus the k8s drills' injected faults (bad image, over-budget eviction, over-quota pod, blocked traffic).
- [x] **Expected outputs** are shown for the demo and lab (§13 Sloth/CloudWatch outputs; §14 budget math expected values; module READMEs' "Expected results").
- [x] **Cost & security warnings** present — all three labs are `$0`/local-kind; the CloudWatch alarm demo notes ~$0.10/alarm/month and a least-privilege SNS topic, with a delete command.
- [x] **Cross-references** to the module repos and to prior/next weeks are correct (Class 1 SLIs → SLOs/budgets here; W16 alert delivery; W22 saturation; W9 release gate).
- [x] The **artifact manifest** (§4.2) is present and every path resolves (verified with `ls`).
- [ ] *Not claimed:* the AWS-native CloudWatch composite-alarm path (§13 Step 4) and SSM Incident Manager are **documented commands**, not live-validated here — there is no committed live-AWS evidence for this class. The validated live evidence is the Prometheus/kind injected-incident drill and the kind production-ops drills (rows 6 and 8). Sloth/OpenSLO generation (§13 Step 1–2) is **DEFERRED** (`sloth`/`oslo` not installed); the equivalent hand-written PromQL alert (row 2) passes `promtool check rules`.
