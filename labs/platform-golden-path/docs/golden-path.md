# The Paved Road: a self-service golden path

## What a golden path is

A **golden path** (or "paved road") is the *supported, opinionated, well-lit*
way to build and run a service in your organization. It is not a mandate and
not a cage — teams may leave the road — but on the road they get security,
observability, CI, and deployment *for free* and *correct by default*. Off the
road, they own all of it themselves.

The point is **leverage**: the platform team encodes its hard-won best
practices once, in a template, and every new service inherits them. A developer
who has never written a `securityContext` still ships a non-root, read-only,
capability-dropped pod, because the template already did.

## This implementation

```
solution/
  template/          the paved road, as a parametrized skeleton
    app/             a stdlib-only Python HTTP service (zero runtime deps)
    tests/           unittest suite (probes, routing, draining)
    Dockerfile       multi-stage, non-root (uid 10001), read-only rootfs
    chart/           Helm chart: probes, resource limits, securityContext,
                     ServiceAccount (token not mounted), optional HPA + NetPol
    k8s/             plain-manifest equivalent for teams not yet on Helm
    .github/workflows/ci.yml   lint (ruff+hadolint) -> test -> helm+kubeconform
                               -> docker build + Trivy scan
    README.md        per-service docs
  scaffold.sh        the generator: copy template/ -> new dir, substitute
                     __SERVICE_NAME__, validate, fail on leftover placeholder
  example-service/   the OUTPUT of `./scaffold.sh example-service` — the end
                     state a reviewer can read without running anything
```

### Why these defaults are the defaults

| Default                                   | Why it is on the paved road                                  |
|-------------------------------------------|--------------------------------------------------------------|
| Non-root user (uid 10001)                 | A container escape lands as an unprivileged user, not root.  |
| `readOnlyRootFilesystem: true` + `/tmp`   | Stops attackers writing tools/payloads into the container.   |
| `capabilities: drop: [ALL]`               | Removes `NET_RAW` etc. — the app needs none of them.         |
| `allowPrivilegeEscalation: false`         | Blocks setuid escalation inside the container.               |
| `automountServiceAccountToken: false`     | The app calls no Kubernetes API; don't hand it a credential. |
| Resource requests **and** limits          | Scheduler can bin-pack; one service can't starve a node.     |
| Liveness `/healthz` + readiness `/readyz` | Restart wedged pods; gate traffic during startup/drain.      |
| `terminationGracePeriodSeconds: 30`       | Readiness flips on SIGTERM, then drains before SIGKILL.      |
| CI scan fails on HIGH/CRITICAL CVEs       | A vulnerable base image cannot reach production silently.    |
| Stdlib-only app (no `requirements.txt`)   | Trivially auditable supply chain; image builds with no pip.  |

### How the generator works

`scaffold.sh <name> [out]`:

1. **Validates** `<name>` as a DNS-1123 label (`^[a-z0-9]([a-z0-9-]*[a-z0-9])?$`,
   `<= 53` chars). This is the single most valuable thing the paved road does:
   it makes an *invalid* service impossible to create. A bad name would later
   blow up `helm install`, image tags, and DNS — caught here in 1 ms instead.
2. **Refuses to overwrite** an existing output directory.
3. **Copies** `template/` and **substitutes** `__SERVICE_NAME__` in every text
   file via `sed`. The placeholder is chosen to be a no-op token: the template
   files still parse/lint/compile *as-is*, so the template itself is validated
   in CI — you never ship a template that generates broken services.
4. **Post-condition**: greps for any surviving placeholder and fails if found.

### Extending the road

- Swap the stdlib app for FastAPI: edit `app/main.py`, add `requirements.txt`,
  add a `pip install` layer to the Dockerfile. Nothing else changes.
- Add a sidecar (e.g. an OTEL collector): add it to `chart/templates/deployment.yaml`.
- Add a new mandatory gate (e.g. `cosign` signing): add a job to `ci.yml`; every
  service regenerated or rebased onto the new template inherits it.

---

## ADR-001: Provide a service template + generator (golden path)

**Status:** Accepted
**Date:** 2026-06-30
**Deciders:** Platform Engineering

### Context

New microservices were being created by copy-pasting from whatever existing
service a developer happened to know. The result: drift. Some services ran as
root; some had no resource limits and triggered OOM cascades; some had no
readiness probe and dropped requests during rollouts; CVE scanning was present
in a few pipelines and absent in others. Every incident review produced the
same root cause — "this service didn't have the thing the platform team
recommends" — and the same fix — a one-off PR that did not prevent the next
service from repeating the mistake. Reviewers spent hours re-checking the same
baseline on every new service.

### Decision

We provide a **golden path**: a single parametrized service template plus a
`scaffold.sh` generator. `scaffold.sh <name>` produces a complete, production-
ready service with security context, probes, resource limits, CI, and packaging
already correct. The template lives in version control and is itself validated
in CI (lint/test/build of the generated output), so the paved road can never
regress unnoticed.

We deliberately make the generated service **self-service and standalone** (the
generated repo owns its files; it does not depend on a runtime platform library
to start). Teams may diverge after generation; the template is the *starting*
point, not a permanent coupling.

### Alternatives considered

1. **A shared base Helm chart / library chart only.** Solves Kubernetes drift
   but not app scaffolding, Dockerfile hardening, CI, or naming validation.
   Rejected as too narrow.
2. **A platform that injects sidecars/policies at admission time** (service
   mesh + OPA/Gatekeeper). Powerful and complementary, but it constrains
   *running* services rather than *bootstrapping* them, and it does not give a
   developer a working repo on day one. We treat this as a later layer, not a
   replacement.
3. **A wiki page of "best practices."** Zero enforcement, immediate rot. This
   was effectively the status quo that failed.

### Consequences

**Positive:** A new service is correct-by-default in minutes. Security/probe/
limit review becomes "did you scaffold from the template?" instead of a manual
audit. Improvements to the template propagate to every team that rebases.
Invalid service names are impossible.

**Negative:** The template is now a shared dependency the platform team must
maintain and version; a bad template change could break many teams (mitigated
by the template's own CI gates). Generated services *fork* the template at
creation time, so propagating a later fix requires the team to re-apply it —
we accept this and may add a `scaffold.sh --upgrade` diff helper later.

**Follow-ups:** image signing (cosign) in CI; an `--upgrade` mode that
re-renders the template over an existing service and shows a diff; a service
catalog (Backstage) entry generated alongside the code.
