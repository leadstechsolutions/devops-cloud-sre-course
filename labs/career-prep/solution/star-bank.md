# STAR Story Bank — 12 Reusable Behavioral Stories

> Behavioral interviews ("tell me about a time…") are won by **preparation, not
> improvisation**. This bank holds 12 stories spanning the dimensions every
> DevOps/SRE loop probes: incident command, leadership, conflict, failure,
> ownership, ambiguity, and influence. Each is written in **STAR** so you can
> deliver it in ~2 minutes without rambling.

These are written as **worked exemplars** in the voice of a mid-to-senior
engineer, modeled on the work in this course's labs. **Replace the specifics with
your own true experiences** — the structure transfers, the facts must be yours.
Interviewers can tell a fabricated story from the follow-up questions; only tell
stories you can go three "why"s deep on.

---

## How to use STAR (and why it works)

| Letter | What goes here | Time budget | Common mistake |
|--------|----------------|------------:|----------------|
| **S — Situation** | One-two sentences of context. Who, what system, what was at stake. | ~15s | Spending 90s on backstory. Keep it tight. |
| **T — Task** | *Your* specific responsibility/goal in that situation. | ~10s | Describing the team's task, not yours. |
| **A — Action** | What **you** did, step by step. Use "I", not "we". The bulk of the answer. | ~60s | Saying "we" so the interviewer can't tell what *you* did. |
| **R — Result** | The outcome, quantified, plus what you learned. | ~25s | No metric; or no reflection. |

**Rules of delivery:**
- **"I" not "we."** The interviewer is scoring *you*. Credit the team in Result,
  but own your Actions.
- **Quantify the Result.** Same discipline as `impact-bullets.md`.
- **End on learning.** Especially for failure/conflict stories — the reflection
  is what's actually being assessed.
- **Have a follow-up ready:** the second question is usually "what would you do
  differently?" Pre-write that for every story.

### Tagging stories to questions

One good story answers many prompts. Tag yours so you can pick fast:

| Dimension | Common prompts it answers |
|-----------|---------------------------|
| Incident command | "Tell me about a major outage you handled." "A time under pressure." |
| Leadership | "A time you led without authority." "Drove a project to completion." |
| Conflict | "Disagreement with a coworker / your manager." "Pushed back on a decision." |
| Failure | "Your biggest mistake." "A time you were wrong." "A project that failed." |
| Ownership | "Went above your role." "Saw a problem no one owned and fixed it." |
| Ambiguity | "Unclear requirements." "Made a decision without enough information." |
| Influence | "Convinced others of an idea." "Changed a team's direction." |
| Mentorship | "Helped someone grow." "Gave difficult feedback." |

---

## The 12 stories

### 1. Incident command — the cascading outage
- **Tags:** incident command, pressure, ownership
- **S:** Our payments API started returning 5xx during a Friday-evening traffic
  peak; checkout error rate jumped to ~30% and customers were tweeting at us.
- **T:** I was the on-call SRE and took incident commander for my first Sev-1. My
  job was to restore service and coordinate, not to be the lone hero debugging.
- **A:** I declared the incident, opened a single Slack channel as the source of
  truth, and assigned roles: one engineer on the database, one on the app tier, me
  on comms + coordination. I posted a status update every 10 minutes. We saw
  connection-pool exhaustion in the metrics; rather than guess, I made the call to
  **roll back** the deploy from 30 minutes earlier (the most recent change) while
  the DB engineer scaled the pool, then we'd diagnose root cause after recovery.
- **R:** Error rate dropped to baseline ~12 minutes after rollback; total customer
  impact was ~22 minutes. The blameless postmortem I wrote traced it to an
  un-bounded connection pool introduced in that deploy; we added a pool-size limit
  test to CI. **Learning:** in an incident, restore first, diagnose second — and a
  calm comms cadence keeps five people from debugging in five directions.

### 2. Leadership without authority — the flaky test crusade
- **Tags:** leadership, influence, ownership
- **S:** Our CI suite was ~18% flaky; engineers retried failed builds reflexively
  and trust in green checks was gone. No one owned it; it was "everyone's problem."
- **T:** I wasn't a lead, but I decided to own fixing it because it was costing the
  whole team hours a week.
- **A:** I instrumented the CI to tag and count flaky tests, published a weekly
  "flaky top 10" dashboard, and proposed a rule: a test that flakes twice in a week
  gets quarantined and assigned to its owner. I didn't have authority to mandate
  it, so I built the data, demoed the time cost in dollars at standup, and got the
  EM and two senior engineers to back it. I fixed the worst three myself as proof.
- **R:** Flakiness dropped from ~18% to under 3% in six weeks; "retry the build"
  stopped being a reflex. **Learning:** to lead without a title, lead with data and
  a small visible win — people follow evidence and momentum, not requests.

### 3. Conflict — disagreeing on managed vs. self-hosted
- **Tags:** conflict, influence, judgment
- **S:** A senior teammate wanted to self-host Kafka to "save money and learn it";
  I believed we should use a managed service given we were a 6-person team with no
  streaming experience.
- **T:** I needed to resolve the disagreement without it becoming personal or
  stalling the project, and land on the right decision for the business.
- **A:** Instead of arguing in the abstract, I proposed we write it up as an ADR
  with a decision table: operational burden, on-call load, cost at our actual
  volume, and time-to-value. I did the cost math honestly — at our volume the
  managed service was ~$400/mo, versus an estimated 1–2 engineer-days/month of
  ops we couldn't spare. I genuinely engaged with his "we'll learn it" point and
  proposed a learning spike as a separate, non-blocking track.
- **R:** Seeing the numbers, he agreed managed was right *for now*, and we recorded
  a "revisit when volume > X or cost > Y" trigger in the ADR. We shipped two weeks
  faster. **Learning:** turn opinion conflicts into a shared artifact with
  criteria; people disagree with *you* but agree with *evidence*, and naming the
  "revisit when" condition lets the other person save face and be right later.

### 4. Failure — the migration I broke
- **Tags:** failure, ownership, learning
- **S:** I ran a database engine upgrade in production over a weekend. I'd tested in
  staging, but staging had a fraction of the data.
- **T:** My task was a zero-downtime upgrade; I owned the plan and the execution.
- **A:** The upgrade ran far longer than my staging test predicted because of a
  table-rewrite on a large table, and I blew past my maintenance window into Monday
  morning traffic with the DB in a degraded state. The mistake was mine: I hadn't
  rehearsed against production-scale data and my rollback plan assumed I could
  abort mid-migration, which I couldn't. I stopped trying to push forward, escalated
  immediately rather than hiding it, restored from the pre-upgrade snapshot, and
  brought us back on the old version, losing ~40 min of availability.
- **R:** We were down ~40 minutes — a real customer impact I owned in the
  postmortem. I then rebuilt the process: a production-sized data clone for
  rehearsal, a tested point-of-no-return checklist, and a true backout step.
  The re-run two weeks later was clean. **Learning:** "tested in staging" is
  worthless if staging isn't production-shaped; and the instinct to escalate early
  beats the instinct to save face.

### 5. Ownership — the alert no one wanted
- **Tags:** ownership, ambiguity, judgment
- **S:** We had a noisy alert that paged on-call ~nightly; everyone had learned to
  ignore it, which is how you miss the real one.
- **T:** Nobody owned it. I decided to, because an ignored alert is worse than no
  alert.
- **A:** I pulled three months of that alert's firings and correlated them with
  actual incidents — it had a ~2% true-positive rate. I rewrote it from a static
  threshold to a multi-window burn-rate alert tied to the service's SLO, so it only
  pages when we're actually burning error budget fast. I socialized the change and
  the reasoning so people would trust alerts again.
- **R:** Pages from that alert dropped ~95%, and the ones that remained were real.
  On-call sleep and morale measurably improved (fewer 3am pages on the rotation).
  **Learning:** alert quality is a product you own; an alert that's ignored is a
  bug, and the fix is tying it to user-facing impact, not a static number.

### 6. Ambiguity — the project with no spec
- **Tags:** ambiguity, leadership, communication
- **S:** Leadership asked us to "improve deployment safety" with no further
  definition, a vague goal handed to my two-person team.
- **T:** I had to turn a one-line ask into a scoped, shippable plan.
- **A:** Rather than wait for clarity, I made the ambiguity concrete: I interviewed
  five engineers about their worst recent deploy, found the common thread (no
  automated rollback, no pre-deploy checks), and wrote a one-page proposal defining
  "deployment safety" as three measurable things: a CI gate, automated health
  checks post-deploy, and one-command rollback. I took it back to leadership to
  confirm I'd aimed at the right target before building.
- **R:** They agreed, and we shipped the three in a month; failed deploys requiring
  manual intervention dropped ~70%. **Learning:** ambiguity is a request to *define
  the problem*, not a blocker — turn the vague ask into a measurable definition and
  confirm it before building.

### 7. Influence — selling the team on IaC
- **Tags:** influence, leadership, technical judgment
- **S:** Our infra was click-ops in the AWS console; only one person knew how it
  was wired, and changes were scary and unrepeatable.
- **T:** I wanted us to adopt Terraform, but the team saw it as overhead that
  slowed them down.
- **A:** I didn't try to convert everything at once. I picked one painful, recurring
  task — spinning up a new test environment, a ~2-day manual ordeal — and codified
  *just that* in Terraform, getting it to 25 minutes. I demoed it live, then handed
  the module to a skeptic and watched them spin up an environment themselves. I
  paired the rollout with a short brown-bag so it didn't feel imposed.
- **R:** That one win flipped the team; we incrementally brought VPC, EKS, and RDS
  under Terraform over a quarter, with peer-reviewed changes. **Learning:** you
  influence engineers with a working demo on a pain they feel, not a slide deck
  about best practices.

### 8. Mentorship — leveling up a junior
- **Tags:** mentorship, leadership, communication
- **S:** A new-grad on my team was strong at coding but froze during on-call and
  would escalate everything immediately without triaging.
- **T:** As their informal mentor, I wanted to build their incident confidence
  without leaving users exposed to a slow response.
- **A:** I paired them on-call with me as a shadow for two rotations, then flipped
  it: they drove and I shadowed, only stepping in if user impact grew. Afterward we
  did a five-minute debrief on each page: what was the signal, what did you check,
  what would you do next time. I also wrote a triage runbook *with* them so they
  had a scaffold, not just my voice in their head.
- **R:** Within two months they ran their own rotation confidently and later told me
  the debriefs were the thing that clicked. **Learning:** people grow from scaffolded
  reps plus reflection, not from being told the answer; mentorship is building their
  judgment, not lending them yours.

### 9. Conflict with a manager — pushing back on a deadline
- **Tags:** conflict, communication, judgment
- **S:** My manager committed us to shipping a feature in two weeks that I believed
  would require cutting the security review and load testing.
- **T:** I needed to push back honestly without being insubordinate or just being
  the "no" person.
- **A:** I didn't say "that's impossible." I laid out the scope as a list and showed
  what fit in two weeks and what didn't, and made the **risk** explicit and the
  manager's to own: "we can hit the date if we ship without the security review,
  here's the specific exposure that creates; or we move the date a week and ship it
  safe — your call, here's my recommendation and why." I offered a middle path:
  ship a feature-flagged beta to internal users on the date, GA a week later.
- **R:** My manager took the middle path; we hit the date with a safe internal beta
  and GA'd cleanly a week later. **Learning:** disagreeing up means presenting
  options and trade-offs, not absolutes — give the decision-maker the information to
  own the risk, and offer a creative third option.

### 10. Resilience under pressure — the recurring 3am page
- **Tags:** pressure, ownership, failure-then-fix
- **S:** A batch job failed and paged me at 3am three nights running; each night I
  restarted it manually, exhausted, and went back to bed without fixing the cause.
- **T:** After the third night I owned actually killing it, not band-aiding it.
- **A:** I admitted to myself the manual restart was the wrong response and forced
  myself to root-cause it tired-but-properly: the job died on a transient upstream
  timeout with no retry. I added bounded exponential-backoff retries and an alert
  that only paged after retries were exhausted, plus a dead-letter path so a single
  bad record couldn't kill the whole run. I documented it so the next on-call
  wasn't ambushed.
- **R:** The 3am pages stopped entirely; the job's success rate went to ~100%.
  **Learning:** the manual fix that lets you go back to sleep is a trap — the second
  time you do toil, automate it; the third time, you've already failed.

### 11. Cross-team collaboration — the noisy-neighbor cost fight
- **Tags:** influence, conflict, ownership
- **S:** Our shared Kubernetes cluster was overspending, and a costly workload
  belonged to a different team that didn't see the bill.
- **T:** I owned cluster cost but not their workload, so I had to drive change
  across a team boundary without authority over them.
- **A:** I built per-namespace cost visibility so the spend was attributable, then
  brought the other team the data privately rather than naming-and-shaming in a
  group channel. I framed it as "here's an easy ~$6k/mo win for you" — right-sizing
  their requests and moving their batch tier to Spot — and offered to pair on it.
- **R:** They cut their footprint ~40%; total cluster spend dropped ~$8k/mo, and we
  set up a recurring cost-review so it didn't regress. **Learning:** cross-team
  change lands when you make the cost *theirs to see*, bring a solution not a
  complaint, and let them take the win.

### 12. Initiative / strategic — the postmortem culture shift
- **Tags:** leadership, influence, ownership
- **S:** After incidents, our team did blame-y "who pushed the bad change" hallway
  conversations and the same classes of failure kept recurring.
- **T:** No one asked me to, but I wanted to shift us to blameless postmortems
  because we weren't learning from outages.
- **A:** I wrote a blameless postmortem template and, after the next incident, ran
  the review myself — explicitly framing it as "the system let a human make this
  mistake; what in the system do we fix." I tracked action items to completion in a
  shared doc rather than letting them evaporate, and reported the closure rate to
  the team so the process visibly produced results.
- **R:** Within a quarter, postmortems became standard, action-item closure went
  from near-zero to ~80%, and we saw repeat-incident classes decline. **Learning:**
  culture changes by doing the new behavior once, visibly, and showing it produces
  results — not by proposing it in the abstract.

---

## Practice protocol

1. Pick your real experiences and slot them into these 12 dimensions. Aim for
   **8–10 genuinely strong stories**; one story can cover multiple dimensions.
2. Write each in STAR using `../starter/star-worksheet.md`. Keep Action in **"I."**
3. **Time yourself** out loud — target 2 minutes. If you run long, your Situation
   is too detailed.
4. For each story, pre-write the **"what would you do differently?"** follow-up.
5. Record yourself or run a mock (`mock-interview-protocol.md`) and check: did the
   listener know exactly what *you* did, and what the measurable result was?
6. Never tell a story you can't go three "why"s deep on. Authenticity survives
   follow-ups; fabrication does not.
