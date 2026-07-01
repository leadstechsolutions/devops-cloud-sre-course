# System Design Model Answer — Distributed Rate Limiter

> Reference answer for the `rate-limiter` prompt. This problem rewards knowing the
> **algorithms** cold and reasoning about the **distributed coordination** problem
> (counters shared across many instances). Use `scoring-rubric.md` alongside.

A rate limiter is a deceptively deep problem: the single-node version is a
warm-up; the real interview is "now you have 50 API gateway instances and the
limit must hold globally."

---

## 1. Requirements clarification (~3 min)

**Functional:**
- Allow a client (by API key / user ID / IP) up to **N requests per time window**;
  reject the rest with **HTTP 429 Too Many Requests** + a `Retry-After` header.
- Limits configurable per route and per tier (free vs paid).

**Non-functional (the design drivers):**
- **Low added latency** — the limiter is on every request's critical path; it must
  add **< 1–2 ms**.
- **Distributed correctness** — the limit must hold across all gateway instances,
  not per-instance.
- **High availability** — and a clear **fail-open vs fail-closed** decision when the
  limiter's backing store is down.
- **Accuracy vs cost** trade-off — perfectly precise global counting is expensive;
  how much imprecision is acceptable?

**Clarifying questions to ask:**
- What's the limit dimension — per user, per IP, per API key, per endpoint, or a
  combination?
- Hard limit (reject) or soft (throttle/queue)?
- Is a small amount of over-admission acceptable in exchange for lower latency?
- Where does it run — at the edge/API gateway, or per-service?

---

## 2. Capacity math (~3 min)

- Suppose **1M users**, **10k requests/sec** peak across the fleet of **50 gateway
  instances** (~200 req/s each).
- Each rate-limit check is a counter read+increment. If centralized in Redis:
  **10k ops/sec** — trivial for a single Redis (handles 100k+ ops/sec).
- **Memory:** one counter per active client per window. 1M active users × (key ~50B
  + counter/state ~50B) ≈ **~100 MB** — fits easily in RAM. Sliding-window-log is
  heavier (stores timestamps) — that's a reason to prefer counters.
- **Conclusion to voice:** throughput is easy; the hard parts are (a) keeping
  per-request latency tiny and (b) making the count correct across 50 instances
  without a network round trip per request becoming the bottleneck.

---

## 3. The algorithms — know these cold

| Algorithm | How it works | Pros | Cons |
|-----------|--------------|------|------|
| **Fixed window counter** | Count requests per fixed window (e.g. per minute); reset at boundary. | Trivial, cheap (one INT). | **Boundary burst**: 2N requests across a window edge (last sec of one window + first sec of next). |
| **Sliding window log** | Store a timestamp per request; count those within the trailing window. | Exact. | Memory grows with request rate; expensive at scale. |
| **Sliding window counter** ✅ | Weighted blend of current + previous fixed-window counts to approximate a sliding window. | Smooths the boundary burst; cheap (2 ints). | Slight approximation. |
| **Token bucket** ✅ | A bucket refills at a steady rate up to a cap; each request consumes a token; empty → reject. | Allows controlled **bursts** up to bucket size; smooth; widely used. | Two values (tokens + last-refill ts) and refill math. |
| **Leaky bucket** | Requests enter a fixed-size queue drained at a constant rate; overflow → reject. | Smooths output to a constant rate. | Adds queueing latency; bursts get delayed, not allowed. |

**Recommended default:** **token bucket** (allows legitimate bursts, what most APIs
actually want) or **sliding window counter** (if you need a strict per-window cap
without the boundary-burst flaw of fixed window). State which and why.

---

## 4. The distributed coordination problem (the crux)

The single-node counter is easy. The interview is: **50 instances, one global
limit.** Options, worst → best:

1. **Per-instance local counters** — fast (in-memory, no network) but **wrong**:
   the global limit becomes N × instances. Only acceptable if you divide the limit
   by instance count *and* traffic is evenly load-balanced (it isn't).
2. **Centralized store (Redis)** ✅ — every instance does an atomic increment in a
   shared Redis. Correct and simple. The whole token-bucket/sliding-window logic
   runs as a **single atomic Redis Lua script** so the read-decide-write can't race
   between instances. Cost: one Redis round trip (~0.2–0.5 ms) per request. This is
   the standard answer.
3. **Local cache + async sync** — each instance keeps a local counter and
   periodically reconciles with the central store. Lower latency, but allows
   **temporary over-admission** between syncs. Good when a little imprecision is
   acceptable and latency is paramount.

**Recommended:** centralized **Redis with an atomic Lua script** as the default;
mention the local-cache + sync hybrid as the optimization when the Redis round trip
becomes the latency bottleneck or you need to survive Redis being slow.

**Atomicity matters:** "GET counter, check, INCR" as three separate calls races
under concurrency (two instances both read 99, both allow, count hits 101). Doing
it in **one atomic operation** (Lua script, or Redis `INCR` with `EXPIRE`) is the
whole point.

---

## 5. API / integration

The limiter is middleware, not a user-facing API. Conceptually:

```
allow(key, route) -> { allowed: bool, remaining: int, reset_at: ts, retry_after: s }
```

On reject, the gateway returns:
```
HTTP 429 Too Many Requests
Retry-After: 30
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1699999999
```

Returning the remaining/reset headers (good API citizenship) lets well-behaved
clients self-throttle.

---

## 6. Data model (Redis)

```
key:   ratelimit:{api_key}:{route}:{window}     -- or token-bucket key per client
value: token-bucket → { tokens: float, last_refill: ts }   (a hash)
       sliding-window → counts for current + previous window
TTL:   set EXPIRE on the key = 2× window, so idle clients' keys self-clean
```

The Lua script atomically: refills tokens based on elapsed time, checks ≥1 token,
decrements, and returns allow/deny + remaining.

---

## 7. Availability & the fail-open/fail-closed decision

**If Redis is down, do you allow or block all traffic?** This is the single most
important judgment call in this design and you must take a position:

- **Fail-open** (allow) — favors availability; risk: an unprotected backend during
  the Redis outage (a traffic spike could take you down). Usually correct for a
  rate limiter whose job is *protection, not gatekeeping* — better to admit traffic
  than to take a self-inflicted outage.
- **Fail-closed** (block) — favors protection; risk: you've turned a Redis blip into
  a full outage. Correct when the limiter guards something that *must not* be
  overrun (e.g. a fragile downstream, or abuse-prevention where over-admission is
  worse than rejection).

**Recommended:** **fail-open with a local fallback** — when central Redis is
unreachable, fall back to a conservative per-instance local limit (so you're not
fully unprotected) rather than fully open or fully closed. State the reasoning.

Other availability concerns: Redis HA (replica + sentinel/cluster); the limiter
adds latency to every request, so a slow Redis hurts everything — set a tight
timeout and fall back rather than block on it.

---

## 8. Key trade-offs to articulate

- **Algorithm:** token bucket (allows bursts) vs sliding-window counter (strict cap,
  no boundary burst) vs fixed window (cheapest, has the boundary-burst bug).
- **Accuracy vs latency:** centralized Redis (correct, +1 round trip) vs local +
  async sync (fast, slightly over-admits).
- **Fail-open vs fail-closed** when the store is down — the headline judgment call.
- **Where it runs:** edge/gateway (protects everything, one place) vs per-service
  (finer-grained, more places to configure).
- **Atomicity:** the Lua-script atomic op is non-negotiable for correctness under
  concurrency — be ready to explain the race it prevents.

---

## 9. What a great candidate adds (senior signal)

- Identifies the **read-check-write race** and solves it with an atomic op,
  unprompted.
- Takes a clear, reasoned **fail-open** stance and explains the blast-radius logic.
- Notes the **fixed-window boundary burst** as a real bug, not a footnote.
- Differentiates limit dimensions (per-user vs per-IP) and the abuse cases each
  defends against (IP-based defends against credential stuffing; key-based against
  a paying customer's runaway script).
- Mentions returning `Retry-After` / rate-limit headers for client cooperation.
- Observability: 429 rate per route/tier, Redis latency, fallback-mode activations.
