<!--
This is the required README shape for every module under labs/.
Copy it, fill every section, delete this comment. Do not leave a heading empty —
if a section genuinely does not apply, write "Not applicable" and one line of why.
-->

# Module: <name>

> **Status:** Validated | Structurally validated | Scaffolded — _state which and why._
> **Maps to:** Week <NN> Class <0Y> (and any later weeks that reuse this).

## What you will build
One paragraph: the end state, in concrete terms (a VPC + tagged subnets; a multi-stage
image under 50 MB that serves `/healthz`; a pipeline that fails the build on a CVE).

## Prerequisites
- Tools + versions (e.g. `terraform >= 1.6`, `python >= 3.10`, `docker >= 24`).
- Accounts/access (e.g. an AWS account with a budget alarm; none).
- Prior modules whose output this one reuses.

## Architecture
A Mermaid diagram (`docs/architecture.mmd`) or a text diagram, plus 2–4 sentences.

## Repository layout
```
starter/    # intentionally incomplete — you do the lab here
solution/   # reference implementation — check yourself against this
tests/      # automated checks where applicable
validate.sh # runs this module's validation gates
```

## Setup
Exact commands to get to a runnable state from a fresh clone.

## Lab tasks
Numbered, each with an explicit "done when" acceptance check.

## Validation
The exact commands and their **expected output**. `./validate.sh` runs them.

## Expected results
What success looks like (output snippets, resource counts, HTTP codes).

## Troubleshooting
Real, reproducible failure → symptom → cause → fix. Reference any `broken/` fixture.

## Cleanup
Idempotent teardown for everything created. For cloud: the destroy command + how to
confirm nothing is left running.

## Security considerations
Secrets handling, least privilege, what NOT to commit, image/dependency scanning.

## Cost considerations
What (if anything) costs money, the rough monthly figure, and how to stay at $0.

## Instructor answer key
Pointer to `solution/` plus the non-obvious grading points and common wrong answers.
