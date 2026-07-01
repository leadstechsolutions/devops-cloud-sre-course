# Scoring Rubric — Distributed Rate Limiter

> Score 0–2 per dimension. Max **20**. The differentiator on this problem is the
> **distributed coordination** and the **fail-open/closed** judgment call — a
> candidate who only solves the single-node version is below the senior bar.

| # | Dimension | What a 2 looks like | Pts |
|--:|-----------|---------------------|----:|
| 1 | **Requirements & scoping** | Pins the limit dimension (user/IP/key/route), hard-vs-soft, latency budget, and asks whether over-admission is tolerable. | /2 |
| 2 | **Capacity math** | Estimates ops/sec and per-client memory; concludes throughput is easy and the real problems are latency + global correctness. | /2 |
| 3 | **Algorithms** | Names ≥3 of fixed/sliding-log/sliding-counter/token/leaky bucket and their trade-offs; picks one with justification. | /2 |
| 4 | **Boundary-burst awareness** | Calls out the fixed-window 2N boundary burst and why sliding-window or token bucket avoids it. | /2 |
| 5 | **Distributed coordination** | Recognizes per-instance counters are globally wrong; proposes centralized Redis (or local+sync) with reasoning. | /2 |
| 6 | **Atomicity / race** | Identifies the read-check-write race across instances and solves with an atomic op (Lua script / atomic INCR+EXPIRE). | /2 |
| 7 | **Fail-open vs fail-closed** | Takes a clear position on Redis-down behavior and justifies it by blast radius; bonus for local-fallback hybrid. | /2 |
| 8 | **API / response semantics** | Returns 429 + `Retry-After` + rate-limit headers so clients can self-throttle. | /2 |
| 9 | **Availability & latency** | Redis HA; tight timeout + fallback so a slow store doesn't stall every request. | /2 |
| 10 | **Communication & structure** | Scoped first, separated single-node from distributed, managed time, clear diagram. | /2 |

**Total: ___ / 20**

### Bands
- **17–20** — Strong hire. Nailed coordination, atomicity, and the fail-open call.
- **13–16** — Hire. Solid algorithms and distributed story, missed one judgment call.
- **9–12** — Mixed. Solved single-node well but hand-waved global correctness.
- **< 9** — Below bar. Only a per-instance counter, or unaware of the race/boundary bug.

### Red flags (cap the score)
- Per-instance local counters presented as globally correct.
- Three-step GET/check/INCR with no acknowledgment of the concurrency race.
- No position on what happens when Redis is down ("it just works").
- Fixed-window counter with no awareness of the boundary burst.
- Treats it purely as throughput ("Redis is fast, done") and never addresses latency-on-every-request.

### Green flags (senior signal)
- Atomic Lua-script solution proposed unprompted.
- Reasoned fail-open + conservative local fallback.
- Distinguishes IP vs key limiting by the abuse case each defends.
- Returns `Retry-After`/rate-limit headers as good API citizenship.
- Names observability signals (429 rate, store latency, fallback activations).
