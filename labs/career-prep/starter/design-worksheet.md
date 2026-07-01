# System Design Worksheet (blank)

> Use this scaffold to practice any of the 5 prompts in
> `../solution/system-design/` (url-shortener, rate-limiter, multi-region-web-app,
> observability-pipeline, cicd-platform). Work top to bottom — the order is the
> method. Set a **45-minute timer**. Talk out loud. Then grade yourself against
> that prompt's `scoring-rubric.md`.
>
> The biggest scoring mistake is jumping to the diagram (section 4) before doing
> sections 1-2. Requirements and capacity math first, always.

---

**Prompt I'm practicing:** <url-shortener | rate-limiter | multi-region-web-app | observability-pipeline | cicd-platform>
**Timer set for 45 min:** [ ]

---

## 1. Requirements (~5 min) — clarify before designing

**Functional requirements** (what it must do):
<!-- TODO: list the core capabilities. -->
- <...>

**Non-functional requirements** (the design DRIVERS — scale, latency, availability,
consistency, cost):
<!-- TODO: these determine the architecture. Be specific with numbers/targets. -->
- <...>

**Clarifying questions I'd ask the interviewer:**
<!-- TODO: at least 3. These show you scope before building. -->
- <...>

**Out of scope** (state it explicitly):
- <...>

## 2. Capacity / back-of-envelope math (~5 min)

<!-- TODO: state assumptions OUT LOUD. The method matters more than the exact number.
Compute the ones relevant to your prompt: -->
- **Traffic:** writes/sec, reads/sec (read:write ratio?), peak vs average:
  <...>
- **Storage:** records × size × retention:
  <...>
- **Memory / cache:** what's hot, how much fits in RAM:
  <...>
- **Bandwidth / other:** <...>
- **One-line conclusion:** what KIND of problem is this? (latency? storage?
  cardinality? coordination? cost?)
  <...>

## 3. API design (~3 min)

<!-- TODO: the key endpoints / interfaces, request/response shapes, status codes. -->
```
<METHOD> /<path>   -> <response / status codes>
...
```

## 4. Data model (~3 min)

<!-- TODO: entities, keys, indexes, what's the primary access pattern. -->
<...>

## 5. High-level architecture (~8 min)

<!-- TODO: draw the boxes and arrows. Client -> edge -> app -> data. Label each
component and WHY it's there. Show the read path and the write path. -->
```
<your diagram>
```

## 6. Deep dive on the crux (~10 min)

<!-- TODO: every prompt has a hard part. Go deep on it:
  url-shortener -> key generation + caching
  rate-limiter -> distributed coordination + atomicity + fail-open/closed
  multi-region -> consistency per data class + failover/fencing
  observability-pipeline -> cardinality + sampling + back-pressure
  cicd-platform -> multi-tenancy + ephemeral runners + supply-chain
-->
<...>

## 7. Scaling & failure (~5 min)

<!-- TODO: how does it scale horizontally? What's the SPOF? What breaks at 10x?
What happens when a key component dies? -->
- **Scale horizontally by:** <...>
- **Single points of failure + mitigation:** <...>
- **What breaks at 10x traffic:** <...>

## 8. Trade-offs (~5 min) — the senior signal

<!-- TODO: name the real choices and justify them. There is no single "right"
answer — interviewers reward weighing alternatives. -->
- <trade-off>: chose <X> over <Y> because <...>
- <trade-off>: <...>

---

## Self-grade (after the timer)

Open `../solution/system-design/<prompt>/scoring-rubric.md` and score yourself
0-2 on each of the 10 dimensions. Be honest.

- **My score:** ___ / 20
- **Lowest dimension(s):** <...>
- **The one thing to drill before next attempt:** <...>

<!-- Then read ../solution/system-design/<prompt>/model-answer.md and note where
your approach diverged and why. -->
