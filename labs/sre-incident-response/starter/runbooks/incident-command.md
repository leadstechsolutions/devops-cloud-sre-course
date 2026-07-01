# Runbook: Incident Command (roles & process)

> A generic incident-management runbook based on the **Incident Command System
> (ICS)** as adapted for software ops (PagerDuty / Google SRE). It defines who
> does what during an incident so responders coordinate instead of colliding.
> Use this alongside the symptom-specific runbooks (e.g. `high-error-rate.md`).

## When to declare an incident

Declare when **any** of these is true:
- A `severity: page` SLO alert is firing and not self-resolving within 5 min.
- Customer-visible impact is confirmed (errors, data loss, security exposure).
- You are unsure how bad it is — **declaring early is cheap; under-reacting is not.**

Declaring means: open the incident channel (`#inc-<date>-<short-name>`), start a
shared timeline doc, and assign the roles below. One person may hold multiple
roles in a small incident, but the **IC role is always explicitly held by one
named person.**

## Roles

### Incident Commander (IC)
The single decision-maker and coordinator. The IC does **not** fix the problem
themselves — they run the response.
- Owns the incident: declares severity, drives toward mitigation, decides when
  to escalate, and declares the incident resolved.
- Maintains the shared picture: what's broken, what we've tried, what's next.
- Delegates investigation/mitigation to Ops; delegates updates to Comms.
- Runs by **directed questions** ("Ops, can you roll back in 5 min? Yes/no?"),
  not open discussion.
- Hands off explicitly ("I am handing IC to <name>; <name>, do you accept?") and
  announces it in-channel. Never let IC lapse silently.

### Communications Lead (Comms)
The interface between the response and everyone outside it.
- Posts regular status updates (cadence set by IC, typically every 15–30 min)
  to stakeholders and, when needed, the public status page.
- Shields the Ops responders from "any update?" interruptions.
- Drafts customer-facing messaging for the IC to approve.
- Records key decisions and timestamps into the timeline doc.

### Operations Lead (Ops)
The hands-on responder(s) who actually change the system.
- Executes diagnosis and mitigation steps from the relevant runbook.
- **Only Ops makes changes to production during the incident** — this prevents
  conflicting fixes. Anyone else with a change proposes it to Ops via the IC.
- Reports findings and the effect of each action back to the IC.
- Calls out when they need more hands or a specific subject-matter expert.

### (Optional) Scribe / Subject-Matter Experts
- **Scribe:** keeps the timeline if Comms is saturated.
- **SMEs:** pulled in by the IC for a specific subsystem (DB, network, vendor).
  They advise/act under Ops coordination; they do not freelance changes.

## The loop the IC runs

```
1. Assess     -> current impact + severity (re-evaluate every few minutes)
2. Coordinate -> assign Ops a concrete next action with a time box
3. Communicate-> Comms pushes a status update on cadence
4. Mitigate   -> restore service (rollback/scale/failover) BEFORE root-causing
5. Verify     -> SLO signals recover and hold; alert clears
6. Resolve    -> IC declares resolved; schedule the postmortem
```

Mitigation beats diagnosis: get customers working again first (roll back, fail
over, shed load), then find the root cause at leisure.

## Severity guide

| SEV | Meaning | Examples | Response |
|-----|---------|----------|----------|
| SEV1 | Critical, broad customer impact | full outage, data loss, security breach | Page IC + Ops + Comms + leadership; all-hands |
| SEV2 | Significant impact, degraded | fast error-budget burn, one region down | Page IC + Ops; Comms on standby |
| SEV3 | Minor / contained | slow burn, single non-critical feature | Ticket; handle in business hours |

## Handoff & resolution checklist

- [ ] IC role is held by exactly one person and is currently active.
- [ ] Ops is the only party changing production.
- [ ] Comms has posted within the agreed cadence.
- [ ] Mitigation applied; SLO signals recovered and stable for 15 min.
- [ ] Timeline doc is complete enough to write the postmortem.
- [ ] IC has declared the incident **resolved** in-channel.
- [ ] A **blameless postmortem** is scheduled (use `postmortem-template.md`).

## Anti-patterns

- No named IC → everyone assumes someone else is coordinating.
- Multiple people changing prod at once → you can't tell what fixed/broke it.
- Root-causing before mitigating → customers stay broken while you debug.
- Silent IC handoff → coordination drops on a shift change.
- Blame in-channel → people stop sharing what they actually did.
