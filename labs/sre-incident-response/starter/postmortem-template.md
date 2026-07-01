# Postmortem: <Incident title> — <YYYY-MM-DD>

> **Blameless.** This document explains *what the system and process did*, not
> *who to blame*. Assume everyone acted with good intent and the information they
> had at the time. We fix systems and processes, not people. If a human action
> contributed, the question is "what made that action easy/likely?" — that is a
> system gap, and that is the action item.

| Field | Value |
|-------|-------|
| Status | Draft / In review / Final |
| Severity | SEV1 / SEV2 / SEV3 |
| Incident commander | <name> |
| Authors | <names> |
| Date of incident | <YYYY-MM-DD> |
| Detection → mitigation → resolution | <HH:MM> → <HH:MM> → <HH:MM> (UTC) |
| Duration of customer impact | <Xh Ym> |
| Postmortem due | within 5 business days of resolution |

## 1. Summary
Two or three sentences a stakeholder can read in 30 seconds: what broke, who was
affected, how long, and how it was resolved.

## 2. Impact
- **Customer-facing:** which users/features, for how long, what they saw.
- **Quantified SLO impact:** how much error budget this consumed. Compute it:
  ```
  python scripts/error_budget.py --target 0.999 --good <good> --total <total>
  ```
  Record the burn rate and the % of the monthly budget spent. If the budget is
  exhausted, note the freeze on risky changes until it recovers.
- **Business impact:** revenue, SLA penalties, support load (if known).

## 3. Timeline (UTC)
Facts with timestamps. No interpretation here — that goes in §5.

| Time | Event |
|------|-------|
| HH:MM | Trigger / first symptom (what fired, what users noticed) |
| HH:MM | Alert `PaymentsAPIErrorBudgetFastBurn` paged on-call |
| HH:MM | Incident declared; IC = <name> |
| HH:MM | Action taken (e.g. rolled back deploy abc123) and its effect |
| HH:MM | Mitigation confirmed; SLO signals recovering |
| HH:MM | Incident resolved |

## 4. Root cause(s)
What actually caused the incident. Go past the proximate trigger to the
underlying condition. A short causal chain or a "5 whys" is fine. Distinguish:
- **Trigger** — the change/event that set it off.
- **Root cause** — the latent condition that made the trigger harmful.
- **Contributing factors** — things that made it worse or slower to resolve.

## 5. What went well / what went poorly
- **Went well:** fast detection, clean rollback, good comms — name them so we
  keep doing them.
- **Went poorly:** gaps in detection, missing runbook step, slow escalation,
  noisy/insufficient alerting. These map directly to action items.
- **Where we got lucky:** things that could have been much worse but weren't.

## 6. Detection
- How was it detected (alert / customer report / dashboard)?
- Time from impact start to detection. If this was slow, that's an action item
  (better SLI, tighter burn-rate alert).

## 7. Action items
Concrete, owned, dated, and tracked. Prefer *prevention* and *faster detection/
mitigation* over "be more careful". Every item is a ticket.

| # | Action | Type (prevent/detect/mitigate/process) | Owner | Ticket | Due |
|---|--------|----------------------------------------|-------|--------|-----|
| 1 | <e.g. add canary + automatic rollback on error-ratio breach> | prevent | <name> | JIRA-### | <date> |
| 2 | <e.g. add p95-latency burn alert at 6x> | detect | <name> | JIRA-### | <date> |
| 3 | <e.g. add db-failover step to high-error-rate runbook> | mitigate | <name> | JIRA-### | <date> |

## 8. Lessons learned
One or two durable takeaways for the broader org — what should other teams change
because of this?

---
*Reviewed in the postmortem meeting on <date>. Action items are tracked to
completion; this document is not "done" until they are closed or explicitly
de-scoped with a reason.*
