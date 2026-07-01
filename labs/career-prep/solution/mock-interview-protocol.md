# Mock Interview Protocol

> A repeatable protocol for running realistic practice loops with a partner (or
> for self-practice). Mock interviews are the single highest-ROI prep activity:
> they convert knowledge you *have* into performance you can *deliver under
> pressure*. This protocol makes them structured and feedback-rich instead of
> vague.

The goal of a mock is **not** to "get it right." It's to surface your failure
modes — rambling, no structure, "we" instead of "I", skipping requirements,
freezing on hints — somewhere it's safe, so you fix them before the real loop.

---

## The four interview types (run each at least twice)

A typical DevOps/Cloud/SRE loop has these rounds. Practice each distinctly.

| Round | Duration | What it tests | Material to use |
|-------|---------:|---------------|-----------------|
| **System design** | 45 min | Scoping, capacity math, trade-offs, communication | `system-design/` (5 prompts + rubrics) |
| **Behavioral** | 45 min | Ownership, collaboration, judgment, self-awareness | `star-bank.md` (12 stories) |
| **Technical deep-dive** | 45 min | Depth in your stack; debugging; "how does X work" | your resume bullets + `labs/` work |
| **Coding / scripting** | 45 min | Practical automation (parse logs, call an API, a small tool) | `labs/python-automation`, `labs/linux-shell-automation` |

---

## Roles in a mock

- **Interviewer** — drives the session, stays in character, gives hints sparingly,
  takes notes against the rubric. Does **not** help beyond what a real interviewer
  would.
- **Candidate** — treats it as real: no pausing to look things up, no "I'd just
  Google this." Think out loud.
- **Observer** (optional, ideal) — silent during, takes notes on *delivery*
  (structure, time, filler words, "we" vs "I"), gives feedback after.

Self-practice: record yourself answering, then watch it back as the observer. The
cringe is the lesson.

---

## Session structure (45 min, applies to all types)

| Phase | Time | What happens |
|-------|-----:|--------------|
| 0. Setup | 2 min | Interviewer sets the scenario; candidate confirms format. |
| 1. The interview | 35 min | Run it for real, in character. Interviewer notes, doesn't rescue. |
| 2. Self-assessment | 3 min | **Candidate first:** "How do you think that went? What would you change?" Self-awareness is itself a scored trait. |
| 3. Scored feedback | 5 min | Interviewer/observer give rubric-based feedback (below). |

Keep it strict on time — the time pressure *is* the skill being practiced.

---

## Type-specific protocols

### System design mock
1. Interviewer picks a prompt from `system-design/` (don't tell the candidate which
   rubric you're using).
2. Candidate must, in order: **clarify requirements → capacity math → high-level
   design → deep-dive → trade-offs**. The interviewer should *withhold* details
   until asked (forces the candidate to drive).
3. ~10 min in, the interviewer injects a curveball: *"now it's 10x traffic"* or *"the
   primary region just died"* — tests adaptability.
4. Score with that prompt's `scoring-rubric.md` (each is 0–2 × 10 = /20).

### Behavioral mock
1. Interviewer asks 4–5 questions across dimensions (incident, conflict, failure,
   leadership, ambiguity) — use the tag table in `star-bank.md`.
2. Candidate answers in **STAR**, "I" not "we", ≤ 2 min each.
3. Interviewer **always** asks the follow-up: *"what would you do differently?"* and
   one *"why did you make that call?"* — this is where prepared-but-shallow stories
   collapse.
4. Score on: structure (STAR present?), ownership (clear "I"?), quantified result?,
   reflection/learning?, and authenticity (survived follow-ups?).

### Technical deep-dive mock
1. Interviewer picks a bullet from the candidate's resume or a `labs/` topic and
   goes **deep**: *"you said you cut deploy time — walk me through exactly how the
   pipeline worked, and what you'd do if it got slow again."*
2. Drill until the candidate hits the edge of their knowledge (that's the point —
   find the depth boundary). A good candidate says "I don't know, but here's how I'd
   find out" rather than bluffing.
3. Score on: depth, accuracy, ability to reason from fundamentals, honesty at the
   boundary.

### Coding / scripting mock
1. A small, practical task (~30 min): parse a log file and report top error sources;
   call an API and summarize; write a script that retries with backoff.
2. Candidate writes runnable code, talks through it, handles edge cases (empty
   input, malformed lines, failures).
3. Score on: working solution, clarity, edge-case handling, testing instinct,
   communication while coding.

---

## Universal feedback rubric (score 1–5 each)

After every mock, the interviewer/observer scores these and gives **one concrete
thing to change** per low score:

| Dimension | 1 (poor) | 5 (strong) |
|-----------|----------|------------|
| **Structure** | Rambled, no framework | Clear framework (requirements→design, or STAR), easy to follow |
| **Communication** | Mumbled, filler, hard to follow | Clear, paced, thought out loud, used the whiteboard well |
| **Drove the conversation** | Waited to be led | Owned the direction, asked good clarifying questions |
| **Technical depth** | Surface-level, hand-wavy | Correct, deep where it mattered, reasoned from fundamentals |
| **Trade-off awareness** | Presented one "right" answer | Weighed alternatives, justified choices |
| **Self-awareness** | Defensive or oblivious in self-assessment | Accurately named own strengths/gaps before being told |
| **Time management** | Ran out / rushed | Paced to finish with trade-offs covered |

**The one rule of feedback:** be specific and actionable. "Be more confident" is
useless. "You said 'we' eight times in the incident story — re-tell it in 'I'" is
useful.

---

## Self-practice without a partner

- **System design:** set a 45-min timer, pick a prompt, talk out loud / write to a
  doc, then grade yourself against the `scoring-rubric.md`. Brutal honesty.
- **Behavioral:** record yourself answering each `star-bank.md` dimension; watch
  back checking for "we", missing metrics, and >2-min sprawl.
- **LLM as interviewer:** prompt an LLM: *"You are a senior SRE interviewer.
  Conduct a 45-minute system design interview on [prompt]. Ask one question at a
  time, withhold details until I ask, inject one curveball, and at the end score me
  against [paste the rubric]. Do not help me."* Effective and available 24/7.

---

## A 2-week mock schedule (example)

| Day | Mock | Focus |
|-----|------|-------|
| 1 | Behavioral | 5 stories, time them, kill the "we"s |
| 3 | System design | url-shortener + rate-limiter (fundamentals) |
| 5 | Technical deep-dive | your two strongest resume bullets |
| 7 | Coding | log-parsing / API script |
| 9 | System design | multi-region + observability-pipeline (the hard two) |
| 11 | Behavioral | failure + conflict stories (the uncomfortable ones) |
| 13 | System design | cicd-platform + a repeat of your weakest from day 3/9 |
| 14 | Full loop | back-to-back: behavioral + design + coding, like the real day |

End each with: *what's my single biggest weakness right now, and what's the one
drill to fix it before the next mock?*
