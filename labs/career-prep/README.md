# Module: career-prep

> **Status:** Validated — all required artifacts are present on disk and pass the
> presence/structure/substance gates in `./validate.sh` (exit 0) in this
> environment. This is a **non-code** module (Week 25 career prep); per
> the course's artifact standard §4 a non-technical class is exempt from
> runnable code but must still ship concrete, substantive artifacts as real files —
> which it does, and which the validator enforces with word-count and structure
> checks so a stub cannot pass.
> **Maps to:** Week 25 Class 01–02 (`02-advanced-track/week-25-resume-interview-prep/`).
> Reuses every earlier module as portfolio evidence (see `solution/portfolio-checklist.md`).

## What you will build

A complete, reusable **job-search toolkit** for a DevOps/Cloud/SRE role: a scored
resume rubric (ATS + LLM-screener + human readers), an impact-bullet playbook with
ten before/after rewrites, a bank of twelve STAR behavioral stories, five full
system-design prompts each with a model answer and a scoring rubric, a realistic
take-home assignment with a grading key, a mock-interview protocol, a compensation
negotiation guide, and a portfolio checklist that maps **this course's own labs and
capstone** to the competencies a hiring manager checks. You finish the lab with a
graded resume, your own STAR worksheet filled in, and a self-scored system-design
attempt.

## Prerequisites

- No tools or accounts required. Everything here is Markdown you read, fill in, and
  self-grade. `bash` + coreutils (for `./validate.sh`) — already present.
- Recommended prior work: the rest of `labs/` and the `labs/capstone`, because they
  **are** your portfolio and the source of your real impact bullets and STAR
  stories. You can do this module without them, but it's far stronger with them.
- Optional: a partner (or an LLM) to run mock interviews against.

## Architecture

This is a document module, not a system, so the "architecture" is how the artifacts
reference each other — your portfolio is the hub the rest point at:

```
                 ┌──────────────────────┐
                 │  portfolio-checklist  │◀── maps to labs/* + labs/capstone
                 │  (your evidence hub)  │
                 └───────────┬──────────┘
        proves bullets ┌─────┴─────┐ proves stories
                       ▼           ▼
            ┌──────────────┐  ┌───────────┐
            │ resume-rubric│  │ star-bank │
            │ impact-bullets│ │ (12 STAR) │
            └──────┬───────┘  └─────┬─────┘
                   │   used in mocks │
                   ▼                 ▼
            ┌────────────────────────────────┐
            │   mock-interview-protocol       │──uses──▶ system-design/ (5 prompts,
            │   (behavioral · design ·        │          each model-answer +
            │    deep-dive · coding)          │          scoring-rubric)
            └────────────────────────────────┘
   take-home-brief ──graded by──▶ take-home-solution-outline
   negotiation ◀── after you pass the loop
```

## Repository layout

```
starter/                       # intentionally incomplete — you do the lab here
  resume-template.md           #   ATS-safe single-column template with TODO gaps
  star-worksheet.md            #   blank STAR worksheet (copy per story)
  design-worksheet.md          #   blank 45-min system-design scaffold
solution/                      # reference artifacts — check yourself against these
  resume-rubric.md             #   scored ATS + LLM-screener + human checklist
  impact-bullets.md            #   X-Y-Z formula + 10 before/after rewrites
  star-bank.md                 #   12 STAR stories (incident, conflict, failure, ...)
  take-home-brief.md           #   realistic ~4h take-home assignment
  take-home-solution-outline.md#   grading key for the take-home
  mock-interview-protocol.md   #   how to run/score practice loops
  negotiation.md               #   compensation negotiation playbook
  portfolio-checklist.md       #   maps this course's labs/capstone -> competencies
  system-design/
    url-shortener/             #   model-answer.md + scoring-rubric.md
    rate-limiter/              #   model-answer.md + scoring-rubric.md
    multi-region-web-app/      #   model-answer.md + scoring-rubric.md
    observability-pipeline/    #   model-answer.md + scoring-rubric.md
    cicd-platform/             #   model-answer.md + scoring-rubric.md
validate.sh                    # presence + structure + substance gates
```

## Setup

```bash
cd labs/career-prep
cat README.md
# Read the solution artifacts to learn the frameworks, then do the lab in starter/.
./validate.sh           # confirms all artifacts are present and substantive
```

No build, no install, no services.

## Lab tasks

1. **Grade a resume.** Read `solution/resume-rubric.md`. Fill in
   `starter/resume-template.md` with your real experience, then score it against the
   rubric. **Done when:** your resume scores ≥ 90, or you've fixed the
   single lowest-scoring dimension and documented why.
2. **Rewrite your bullets.** Using `solution/impact-bullets.md`, convert every
   activity bullet on your resume to an X-Y-Z impact bullet with a defensible number.
   **Done when:** every bullet has X (outcome), Y (metric), and Z (method).
3. **Build your STAR bank.** Copy `starter/star-worksheet.md` per story and write at
   least one each of: incident, failure, conflict, leadership, ownership — using
   `solution/star-bank.md` as exemplars (your own true stories). **Done when:** you
   have ≥ 8 stories, each in "I"-voice, quantified, ending on a learning, that times
   out at ~2 minutes spoken aloud.
4. **Attempt a system design.** Pick a prompt, do it cold in
   `starter/design-worksheet.md` with a 45-min timer, then self-grade against that
   prompt's `scoring-rubric.md`, then read its `model-answer.md`. **Done when:** you
   score ≥ 13/20 and can name the one dimension to drill next.
5. **Run a mock loop.** Follow `solution/mock-interview-protocol.md` for a behavioral
   and a design round (partner or LLM). **Done when:** you have rubric-scored
   feedback and one concrete fix per low dimension.
6. **Do the take-home.** Attempt `solution/take-home-brief.md` (time-boxed ~4h)
   without reading the outline; then grade yourself with
   `solution/take-home-solution-outline.md`. **Done when:** your submission runs
   (`compose up` healthy) and self-scores ≥ 70/100.
7. **Assemble your portfolio.** Work through `solution/portfolio-checklist.md`,
   mapping your `labs/` and `labs/capstone` work to competencies. **Done when:**
   every linked repo clones-and-runs and your front page passes the 60-second test.

## Validation

`./validate.sh` runs presence + structure + substance gates (no external tools
required). It asserts every required file exists, exceeds a minimum word count (so
stubs fail), the five design prompts each ship a model answer **and** a rubric, the
starter worksheets contain their `TODO` gaps, and the key frameworks are actually
present (X-Y-Z in impact bullets, the STAR letters in the bank, ATS/LLM in the
resume rubric, capstone/labs references in the portfolio checklist).

```bash
./validate.sh; echo "exit=$?"
```

**Expected output (tail):**

```
-- structure / framework markers --
  [PASS] impact-bullets: X-Y-Z formula present
  ...
== 41 passed, 0 failed ==
exit=0
```

## Expected results

- `./validate.sh` exits **0** with every line `[PASS]`.
- After the lab tasks: a resume scoring ≥ 90 on the rubric, ≥ 8 STAR stories drafted,
  at least one system-design attempt self-scored ≥ 13/20, and a portfolio front page
  that links to runnable course work.

## Troubleshooting

Real, reproducible failures from this module's own gates:

| Symptom (`./validate.sh`) | Cause | Fix |
|---------------------------|-------|-----|
| `[FAIL] ... looks like a stub` | A file is below its word floor — it's a placeholder, not a real artifact. | Write the real content; the floors are set so substantive docs clear them comfortably. |
| `[FAIL] missing: solution/system-design/<x>/scoring-rubric.md` | A design prompt shipped a model answer but no rubric (or vice-versa). | Every prompt directory needs **both** files. |
| `[FAIL] impact-bullets: X-Y-Z formula present` | The X-Y-Z framework string isn't in the file. | The impact-bullets doc must teach the literal X-Y-Z formula, not just give examples. |
| `[FAIL] starter star-worksheet: has TODO gaps` | The starter worksheet was filled in / lost its TODO markers. | Starter files are **intentionally incomplete** — restore the `TODO` placeholders. |
| `Permission denied` running `./validate.sh` | Execute bit missing. | `chmod +x validate.sh`. |

There is no `broken/` fixture for this module: the "broken state" the validator
catches is a **stub artifact** (a file present but too thin to teach from), which is
the exact failure mode the course's artifact standard exists to prevent.
Truncate any solution file and re-run `./validate.sh` to see it fail honestly.

## Cleanup

Nothing to clean up — this module creates no processes, containers, namespaces,
cloud resources, or files outside `labs/career-prep/`. The lab is purely documents
you read and worksheets you fill in locally. (`./validate.sh` writes nothing
outside its own directory.)

## Security considerations

- **Do not commit personal data or secrets.** When you fill in
  `starter/resume-template.md` and the worksheets with real names, employers, or
  contact details, keep your filled-in copies **out of any shared/public repo** —
  treat them as personal documents.
- **Portfolio hygiene:** before linking any repo on your resume, run a secret scan
  (you learned how in `labs/security-automation`) — no `.env`, keys, or tokens in
  history. A leaked credential in a portfolio repo is a hard fail in a security-aware
  hiring loop.
- **Negotiation honesty:** `solution/negotiation.md` is explicit that fabricating
  competing offers or comp is both unethical and easily verified — don't.

## Cost considerations

**$0.** This module provisions nothing and requires no accounts or paid tools.
Everything is local Markdown plus an optional partner/LLM for mock interviews. There
is no cloud spend to monitor and nothing to tear down.

## Instructor answer key

The reference artifacts live in `solution/`. Non-obvious grading points:

- **Resume task:** the common wrong answer is a beautiful two-column template that
  an ATS shreds — grade the **plain-text paste order** first (rubric dimension 1),
  not the visual design. Watch for skills listed but never demonstrated in a bullet.
- **Impact bullets:** the frequent miss is a bullet with Z (tools) and X (vague
  outcome) but **no Y (metric)** — "improved reliability using Prometheus." Require a
  defensible number on every bullet.
- **STAR:** dock for "we" instead of "I" and for stories with no quantified Result or
  no learning. The failure/conflict stories are where authenticity is tested — probe
  follow-ups; a fabricated story collapses on "what would you do differently?"
- **System design:** each `scoring-rubric.md` lists the **red flags** (e.g. URL
  shortener: synchronous click-count write on the redirect path; rate-limiter:
  per-instance counters presented as globally correct; multi-region: one consistency
  model for all data; observability: no cardinality story; CI/CD: a single pipeline
  instead of a multi-tenant platform) and **green flags** for senior signal. Grade
  the *crux deep-dive*, not the diagram polish.
- **Take-home:** the single most predictive question is *"what did you cut for time,
  and what's the risk of shipping it as-is?"* — `take-home-solution-outline.md`
  rewards honesty about gaps over a larger broken or over-engineered submission.
- **Portfolio:** the capstone is the flagship; a portfolio of READMEs describing
  projects that don't run scores below a small portfolio of projects that do.
