# Resume Rubric — ATS, Human, and LLM-Screener Scored Checklist

> Use this to grade a DevOps/Cloud/SRE resume against the three readers it must
> survive, in order: an **ATS parser**, an **LLM screener**, and a **human**
> (recruiter first ~7 seconds, then hiring manager ~2 minutes). Score each
> dimension, sum, and act on the lowest-scoring dimension first.

A resume is a **filter-passing document**, not an autobiography. Its only job is
to get you a phone screen. Every line either advances that goal or wastes space.

---

## How to score

Each of the three readers has a sub-checklist. Award the points listed for each
item only if it is **fully** true — partial credit rounds down. Total is **100**.

| Reader               | Max points | Why it matters                                   |
|----------------------|-----------:|--------------------------------------------------|
| 1. ATS parseability  |         25 | If the parser mangles you, no human ever sees it |
| 2. LLM screener      |         30 | Increasingly the first "reader"; keyword + signal |
| 3. Human (recruiter) |         25 | The 7-second scan: title, scope, recency         |
| 4. Human (hiring mgr)|         20 | The 2-minute read: impact, depth, credibility    |

**Bands:**
- **90–100** — Send it. Strong across all readers.
- **75–89** — Send after fixing the single lowest item.
- **60–74** — One reader will reject you; rework that section before applying.
- **< 60** — Do not apply yet. Rebuild using `impact-bullets.md`.

---

## 1. ATS parseability (25 pts)

The Applicant Tracking System (Greenhouse, Lever, Workday, Taleo, iCIMS) ingests
your file and tries to map it to fields. Fancy formatting breaks this silently.

| # | Check | Pts |
|--:|-------|----:|
| 1 | Single-column layout. **No** tables, text boxes, or multi-column sections for content (Workday/Taleo read top-to-bottom and scramble columns). | 5 |
| 2 | Submitted as **`.pdf` generated from a text source** (not a scanned image, not exported-as-image). Text is selectable when you ctrl-F the PDF. | 4 |
| 3 | Standard section headers spelled conventionally: `Experience`, `Skills`, `Education`, `Projects`. No "What I've Shipped" cleverness — the parser keys on the literal words. | 3 |
| 4 | Contact line is plain text: name, city/region, email, phone, one URL each for GitHub/LinkedIn. **No icons** as the only label (an icon with no text = unparseable). | 3 |
| 5 | Dates in a consistent `MMM YYYY – MMM YYYY` (or `YYYY–YYYY`) format, right-aligned or after the title — parser extracts tenure from these. | 3 |
| 6 | No critical info in headers/footers — many parsers drop the header/footer region entirely. | 3 |
| 7 | Job entries use reverse-chronological order with company, title, dates on the **first** line of each entry. | 2 |
| 8 | Standard fonts (Calibri, Arial, Helvetica, Georgia, Times). No font that renders as glyphs/ligatures the parser can't decode. | 2 |

**Verify it:** copy-paste the whole PDF into a plain text editor. If the order
is jumbled, dates vanish, or bullets merge into paragraphs, an ATS sees the same
mess. Also run it through [an ATS-parse test] (any free resume-parser preview)
and confirm Title, Company, Dates, and Skills populate correctly.

---

## 2. LLM screener (30 pts)

Recruiters now paste the job description + your resume into an LLM and ask "is
this candidate a fit, score 1–10, list gaps." You optimize for this by making
the **match obvious and the evidence concrete** — an LLM rewards specificity and
penalizes vagueness and unsupported superlatives.

| # | Check | Pts |
|--:|-------|----:|
| 1 | The **exact technologies in the JD** that you actually know appear verbatim (`Kubernetes`, `Terraform`, `Prometheus`, `GitHub Actions`, `AWS`) — not synonyms only ("container orchestration" without "Kubernetes" loses the keyword match). | 6 |
| 2 | Each skill is **demonstrated in a bullet**, not just listed. An LLM cross-checks the Skills list against Experience; "Terraform" in Skills but never in a bullet reads as padding. | 5 |
| 3 | Bullets are **quantified** (numbers, %, time, scale). LLMs are trained to treat "reduced deploy time 45 min → 6 min" as strong signal and "improved deployment process" as noise. | 5 |
| 4 | Seniority signal matches the role: scope words (`owned`, `led`, `designed`, `on-call for`, `incident commander`) for senior; `built`, `automated`, `contributed` for mid. Mismatched scope makes the LLM down-rank fit. | 4 |
| 5 | **No unverifiable superlatives** ("expert", "guru", "world-class", "passionate"). LLMs discount these and good screeners are told to. | 3 |
| 6 | Recency: current/most-recent role carries the most relevant keywords. LLMs weight recent experience higher for "can do the job now." | 3 |
| 7 | No keyword **stuffing** (a hidden white-text keyword block, or a 40-item flat skill dump). Modern screeners flag density anomalies and a human told "they stuffed keywords" rejects. | 2 |
| 8 | One coherent **narrative**: the roles tell a progression story toward the target role, not a random walk. LLMs asked "is this a logical career path for X" reward coherence. | 2 |

**Verify it:** paste the target JD and your resume into an LLM with the prompt
*"You are a technical recruiter. Score this candidate 1–10 against this JD, list
the top 3 matching strengths and the top 3 gaps, and decide phone-screen
yes/no."* If it can't name your strengths in concrete terms, neither can a human.

---

## 3. Human — recruiter 7-second scan (25 pts)

The recruiter is not technical and is scanning 200 resumes. They look at the
**top third** and decide pass/reject in seconds.

| # | Check | Pts |
|--:|-------|----:|
| 1 | Current **title + target title** are legible at a glance and aligned to the role (a "DevOps Engineer" applying to an "SRE" role names SRE-adjacent work up top). | 5 |
| 2 | A **2–3 line summary** at the top states: years of experience, core stack, and the one thing you're known for. No objective statement ("seeking a role where I can grow"). | 5 |
| 3 | Most-recent company + dates are immediately visible; **no unexplained gaps** > 6 months. | 4 |
| 4 | Length: **1 page** for < 8 yrs experience, **2 pages** max otherwise. Page 3 is never read. | 4 |
| 5 | Scannable: bullets ≤ 2 lines each, ≤ 6 bullets per role, whitespace present. A wall of text gets skipped. | 4 |
| 6 | Zero typos, consistent tense (past for past roles, present for current), consistent punctuation. One typo = "careless." | 3 |

**Verify it:** show the resume to someone for **7 seconds**, take it away, and
ask "what role are they going for and what are they good at?" If they can't
answer, the top third is failing.

---

## 4. Human — hiring manager 2-minute read (20 pts)

The hiring manager **is** technical and is deciding "would this person be useful
on my team in 30 days." They read for depth, judgment, and credibility.

| # | Check | Pts |
|--:|-------|----:|
| 1 | Bullets show **impact and outcome**, not just activity: the X-Y-Z form (accomplished X measured by Y by doing Z) — see `impact-bullets.md`. | 6 |
| 2 | At least 2–3 bullets show **ownership of an outcome** (reliability, cost, lead time, MTTR), not just task completion. | 4 |
| 3 | Evidence of **operating, not just building**: on-call, incidents handled, things kept running — the difference between a 7 and a 9 in this course's scoring ladder. | 4 |
| 4 | A **Projects / Portfolio** line links to real, runnable work (this course's capstone, a GitHub with infra-as-code). Maps to `portfolio-checklist.md`. | 3 |
| 5 | Claims are **credible and specific** — numbers that pass the "how would you know that?" test in an interview. Nothing you can't defend in the system-design / behavioral round. | 3 |

**Verify it:** for each quantified claim, ask yourself *"if they ask me 'walk me
through how you measured that,' can I?"* If not, soften or cut it — an
indefensible number is worse than none.

---

## Worked example: scoring one bullet across all readers

> ❌ Before: *"Responsible for CI/CD and improving the deployment process."*
> - ATS: parses fine. LLM: vague, no keyword for the tool, no metric — low signal.
> - Recruiter: forgettable. Hiring manager: tells me nothing about depth.

> ✅ After: *"Cut mean deploy time from 42 min to 6 min for 30 microservices by
> replacing hand-rolled bash with a reusable GitHub Actions matrix pipeline (build
> → Trivy scan → Helm deploy), eliminating ~4 failed Friday deploys/month."*
> - ATS: parses. LLM: `GitHub Actions`, `Helm`, `Trivy` keywords + 42→6 metric +
>   scope (30 services) = strong fit signal. Recruiter: "fast deploys, owns CI/CD."
>   Hiring manager: real tooling, real outcome, defensible in interview.

---

## Common rejections and the fix

| Symptom | Root cause | Fix |
|---------|------------|-----|
| "Never hear back from applications" | ATS mangles a 2-column template | Switch to single-column, re-test parse |
| "Recruiter screens me but I'm 'not senior enough'" | Activity bullets, no ownership/scope words | Rewrite with X-Y-Z + scope (`owned`, `led`) |
| "LLM screen scores me low on a JD I match" | Skills in head, not on page; synonyms not keywords | Mirror the JD's exact tech terms in bullets |
| "Hiring manager says 'looks junior'" | All build, no operate; no incidents/on-call | Add reliability/MTTR/on-call bullets |
| "Resume is 3 pages" | Listing every task ever done | Cut to outcomes; 1 page < 8 yrs |

---

## Final gate before sending

- [ ] Plain-text paste of the PDF is readable and ordered (ATS).
- [ ] LLM screen against the real JD returns phone-screen **yes** with your
      strengths named correctly.
- [ ] 7-second test: a stranger can name your target role and strength.
- [ ] Every number is defensible in an interview.
- [ ] Total score ≥ 90, or you've fixed the lowest-scoring dimension.
