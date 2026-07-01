# Scoring Rubric — URL Shortener Design

> Score the candidate (or yourself) 0–2 on each dimension. **0** = missing/wrong,
> **1** = mentioned but shallow, **2** = solid with trade-offs. Max **20**.
> This problem is a *fundamentals* check — strong candidates clear it cleanly and
> spend their energy on the key-generation and caching trade-offs.

| # | Dimension | What a 2 looks like | Pts |
|--:|-----------|---------------------|----:|
| 1 | **Requirements & scoping** | Establishes read-heavy (≈100:1), latency-critical redirect, and asks the 301-vs-302 question unprompted. Names what's out of scope. | /2 |
| 2 | **Capacity math** | Derives writes/sec, reads/sec, 5-yr storage (~few TB), and the base62 key-space sizing (62^7 ≫ rows). Concludes it's a latency/read problem, not a storage problem. | /2 |
| 3 | **API design** | Clean create + redirect + (optional) stats endpoints; correct status codes (302/301, 404, 409 for alias clash). | /2 |
| 4 | **Data model** | KV access pattern; `code` as primary key/index; handles expiry and (if asked) custom aliases. | /2 |
| 5 | **Key generation** | Compares hash vs counter vs random; picks one and **justifies collision handling**. Senior: counter+range with a bijective scramble for unguessability. | /2 |
| 6 | **Caching** | Identifies cache as the primary read-scaling lever; reasons about hit rate from the skewed access pattern; write-through/populate-on-miss. | /2 |
| 7 | **Scaling & availability** | Stateless app tier + LB; DB sharding/replicas; CDN caching of 301s; what breaks at 10x. | /2 |
| 8 | **Analytics handled correctly** | Does **not** put a synchronous counter write on the redirect path; uses async events / Redis INCR. (Score 1 if analytics out of scope but reasoning sound.) | /2 |
| 9 | **Trade-offs articulated** | Explicitly states 301/302, SQL/NoSQL, consistency, and SPOF trade-offs rather than presenting one "right" answer. | /2 |
| 10 | **Communication & structure** | Drove the interview, stated assumptions, managed time, drew a clear diagram, didn't rat-hole. | /2 |

**Total: ___ / 20**

### Bands
- **17–20** — Strong hire signal. Cleared fundamentals and showed depth on keys/caching.
- **13–16** — Hire / lean hire. Solid but missed a trade-off or hand-waved capacity.
- **9–12** — Mixed. Got a working design but shallow on the crux (keys or caching).
- **< 9** — Below bar. Jumped to a diagram without scoping or math, or had collisions/SPOFs unaddressed.

### Red flags (cap the score)
- Jumps straight to boxes-and-arrows without clarifying read/write ratio or doing math.
- Hash-based keys with no collision handling, presented as if collisions can't happen.
- Synchronous click-count write on every redirect (kills the hot path).
- "Just use a database" with no caching story for a 20k-reads/sec read-heavy system.
- Can't answer "what breaks at 10x traffic."

### Green flags (senior signal)
- Raises 301-vs-302 and the analytics consequence unprompted.
- Pre-allocated ID ranges to avoid per-write coordination.
- Brings up abuse/phishing scanning and rate-limiting the create endpoint.
- Names the ID-coordinator as the SPOF and mitigates it.
