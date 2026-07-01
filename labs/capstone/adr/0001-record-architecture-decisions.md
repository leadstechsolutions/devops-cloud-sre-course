# 1. Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Capstone team (platform + SRE)
- **Tags:** process, documentation

## Context

The capstone integrates seven previously independent modules (Terraform infra,
container image, Kubernetes/Helm workload, CI/CD, observability, and SRE
operations). During the integration we make decisions that are expensive to
reverse — the orchestrator, where state lives, what is managed vs self-hosted,
how secrets flow — and that future maintainers will otherwise have to
reverse-engineer from the code.

When such decisions live only in a pull-request thread or someone's head, two
failure modes follow:

1. The same question gets re-litigated every few months because nobody recorded
   *why* the choice was made or *what alternatives were rejected*.
2. New team members change something load-bearing without understanding the
   constraint it was satisfying, and reintroduce a problem the decision solved.

## Decision

We will keep **Architecture Decision Records (ADRs)** in this repository under
`labs/capstone/adr/`, one Markdown file per decision, using the lightweight
Nygard format (Context / Decision / Consequences) seen in this file.

Rules:

- ADRs are **immutable once Accepted**. We do not edit the decision; we supersede
  it with a new, higher-numbered ADR and set the old one's status to
  `Superseded by ADR-NNNN`.
- Files are numbered monotonically: `NNNN-short-kebab-title.md`.
- Each ADR has a `Status` of `Proposed`, `Accepted`, `Rejected`, `Deprecated`,
  or `Superseded by ADR-NNNN`.
- An ADR is required for any decision that is (a) costly to reverse, (b) affects
  more than one module, or (c) trades off a non-functional requirement
  (security, cost, availability, operability).

## Consequences

**Positive**

- The reasoning behind load-bearing choices is discoverable in version control,
  reviewed in the same PR as the change it justifies.
- Onboarding is faster: `adr/` is a reading list for "why is it like this?".
- Superseding (not editing) preserves the historical record of how thinking
  evolved.

**Negative / costs**

- Small ongoing discipline cost: a decision worth making is a decision worth
  writing down, which adds a few minutes to a PR.
- Risk of ADR rot if the team stops writing them; mitigated by making "is there
  an ADR?" a checklist item for architecturally significant PRs (see
  `production-readiness-checklist.md`).

## Related

- ADR-0002 — Managed vs self-hosted for stateful and platform components.
- `production-readiness-checklist.md` — references ADR coverage as a gate.
