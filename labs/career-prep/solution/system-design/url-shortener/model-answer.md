# System Design Model Answer — URL Shortener

> Reference answer for the `url-shortener` prompt. Treat this as **one strong
> path**, not the only correct one — interviewers reward judgment and trade-off
> awareness, not memorized diagrams. Use the `scoring-rubric.md` alongside it.

The interview signal here is mostly **read-heavy system design fundamentals**:
clarifying scope, doing capacity math, choosing a key-generation strategy without
collisions, and caching a hot read path.

---

## 1. Requirements clarification (do this first — ~3 min)

**Functional:**
- `POST` a long URL → return a short URL (`https://sho.rt/abc123`).
- `GET` a short URL → HTTP 301/302 redirect to the long URL.
- Optional: custom aliases (`sho.rt/my-brand`), expiration (TTL), per-link click
  analytics.

**Non-functional (the ones that drive the design):**
- **Read-heavy.** Reads (redirects) vastly outnumber writes (creations) —
  assume **100:1**.
- **Low latency** on redirect (it's in the user's critical path): p99 < 50 ms.
- **High availability** for redirects (a dead link is a broken product); creation
  can tolerate slightly less.
- **Short, non-guessable-ish, permanent** short codes.

**Out of scope (state it):** auth/accounts beyond basic API keys, payment, full
analytics warehouse. Park these to keep the design focused.

**Key clarifying questions to ask the interviewer:**
- Redirect type: **301 (permanent, cacheable)** vs **302 (temporary)**? 301 is
  cheaper (browsers/CDN cache it) but kills per-click analytics and you can't
  change the target. Pick 302 if analytics matter.
- Do short codes need to be unguessable (security) or just unique?
- Custom aliases required? Expiration required?

---

## 2. Capacity / back-of-envelope math (~4 min)

State your assumptions out loud; the number matters less than the method.

- **New URLs:** 100M/month ≈ **~40 writes/sec** average (100M / 2.6M s). Peak ~3–5x
  → call it **~200 writes/sec**.
- **Reads:** 100:1 → **~4,000 reads/sec** average, **~20,000/sec** peak.
- **Storage:** 100M/month × 12 × 5 years ≈ **6B URLs**. Per record ≈ short code (7B)
  + long URL (~500B) + metadata (~100B) ≈ **~600 B**. → 6B × 600B ≈ **~3.6 TB**.
  Comfortably fits in a single sharded database; not "big data."
- **Key space:** base62 (`[a-zA-Z0-9]`) at **7 characters** = 62^7 ≈ **3.5 trillion**
  combinations — far more than 6B, so 7 chars is plenty with room for the future.
  (6 chars = 56B, also enough; 7 gives headroom.)
- **Cache:** the access pattern is heavily skewed (a few links go viral). Caching
  the **hot 20%** absorbs most reads. 20% of daily reads ≈ small; even caching
  the hottest few million entries at ~600B is a few GB of RAM.
- **Bandwidth:** reads 20k/sec × ~600B ≈ ~12 MB/s — trivial.

**Takeaway you should voice:** this is a *latency and read-scaling* problem, not a
storage or write-throughput problem. The whole dataset fits on a laptop; the
challenge is serving 20k redirects/sec at <50ms with high availability.

---

## 3. API design

```
POST /api/v1/urls
  body: { "long_url": "https://...", "custom_alias": "optional", "ttl_days": 365 }
  201:  { "short_url": "https://sho.rt/abc1234", "code": "abc1234", "expires_at": "..." }
  409:  custom_alias already taken

GET /{code}
  302:  Location: <long_url>          (or 301 if analytics not needed)
  404:  unknown / expired code

GET /api/v1/urls/{code}/stats          (optional analytics)
  200:  { "code": "abc1234", "clicks": 1042, "created_at": "..." }
```

Auth on writes via an API key/JWT; reads are public.

---

## 4. Data model

A key-value access pattern (`code → long_url`). A relational table works fine at
this scale, or a wide-column/KV store (DynamoDB/Cassandra) for effortless
horizontal scaling.

```
urls
  code          VARCHAR(7)  PRIMARY KEY     -- the short code
  long_url      TEXT        NOT NULL
  created_at    TIMESTAMP
  expires_at    TIMESTAMP   NULL            -- NULL = never
  owner_id      VARCHAR     NULL            -- API key owner
  -- click_count handled separately (see analytics, below)
```

Index: primary key on `code` (the only lookup that's in the hot path). If you
support custom aliases, they live in the same table (alias *is* the code) and a
unique constraint enforces no collision.

---

## 5. Key generation — the crux of this problem

Three viable strategies; know the trade-offs:

| Strategy | How | Pros | Cons |
|----------|-----|------|------|
| **Hash + truncate** | `base62(md5(long_url))[:7]` | Stateless, dedupes identical URLs | Collisions need a check-and-retry loop; same URL → same code (sometimes a feature, sometimes not) |
| **Counter + base62 encode** ✅ | Global auto-increment ID → base62. Hand out ID ranges to each app server (e.g. a "ticket server"/Zookeeper/DB sequence gives each box a block of 10k IDs). | **No collisions ever**, short codes, write-scalable via pre-allocated ranges | Codes are sequential/guessable unless you also bijectively scramble the ID (Feistel/`* prime mod 62^7`) |
| **Random + check** | Generate random 7-char base62, check uniqueness, retry on collision | Unguessable | Extra read per write; retry rate climbs as table fills |

**Recommended:** the **counter + base62** approach with **pre-allocated ID ranges**
per app server. It guarantees uniqueness without a per-write coordination round
trip (each server burns through its local block, only hitting the coordinator when
it needs a new block). If guessability is a concern, run the integer ID through a
reversible bijection (e.g. a Feistel network or multiply-by-coprime mod 62^7)
before base62-encoding, so codes look random but never collide.

---

## 6. High-level architecture & scaling

```
        ┌─────────┐     ┌──────────────┐     ┌───────────────┐
client ─▶│   CDN   │────▶│ Load Balancer │────▶│ App servers   │  (stateless)
        └─────────┘     └──────────────┘     └──────┬────────┘
            ▲ caches 301s                            │
            │                                        ▼
            │                              ┌──────────────────┐
            │                              │  Cache (Redis)   │  hot codes
            │                              └────────┬─────────┘
            │                                       ▼
            │                              ┌──────────────────┐
            └──────────────────────────────│  DB (sharded by  │
                                           │  code; replicas) │
                                           └──────────────────┘
```

**Read path (the one that must be fast):**
1. CDN/edge: if using 301, the CDN caches the redirect and most reads never reach
   you. (If 302 for analytics, CDN can't cache — design for it.)
2. App server checks **Redis** (`code → long_url`, LRU). ~95%+ hit rate given the
   skew → most reads are a single in-memory lookup.
3. On cache miss, read the DB, populate the cache, redirect.

**Write path:**
1. App server takes a code from its pre-allocated ID block (no coordination).
2. Insert into DB, write-through to cache.

**Scaling levers:**
- **App tier:** stateless → scale horizontally behind the LB; the ID-range scheme
  means more servers don't increase coordination.
- **Cache:** the primary read-scaling tool. Redis cluster, replicas for the hottest
  keys. This is what lets one modest DB serve 20k reads/sec.
- **DB:** shard by `code` (hash-partition the key space). Read replicas for the
  long tail of cache misses. At 3.6 TB / 6B rows this is comfortable.
- **Geo:** put read replicas + caches in multiple regions; redirects are served
  from the nearest edge.

---

## 7. Analytics (if in scope)

Don't increment a `click_count` column synchronously on the redirect path — that
makes every read a write and serializes on hot keys. Instead: fire an async event
(to Kafka/Kinesis/a log) on each redirect and aggregate offline; or use Redis
`INCR` on a counter key and flush periodically. Keep the redirect path read-only
and fast.

---

## 8. Key trade-offs to articulate

- **301 vs 302:** 301 is cacheable (cheaper, faster) but kills analytics and is
  permanent; 302 keeps you in the loop but costs you the CDN cache. **Name which
  you chose and why.**
- **Hash vs counter for keys:** hash is stateless but needs collision handling;
  counter is collision-free but needs the range-allocation machinery and a
  scramble for unguessability. Recommend counter+range.
- **SQL vs NoSQL:** the access pattern is pure KV, so NoSQL (DynamoDB/Cassandra)
  gives effortless horizontal scale; SQL is simpler operationally and fine at this
  size. Either is defensible — justify by team familiarity and scale.
- **Consistency:** redirects tolerate eventual consistency (a just-created link
  being readable a few ms later is fine); custom-alias uniqueness needs a strong
  check at write time. Mixed consistency is appropriate.
- **Single point of failure:** the ID-range coordinator. Mitigate by pre-allocating
  large blocks (a server can run for a long time on one block) and replicating the
  coordinator; a brief coordinator outage doesn't stop writes mid-block.

---

## 9. What a great candidate adds (senior signal)

- Rate limiting on the create endpoint (abuse: someone shortening millions of URLs).
- Abuse/safety: scan target URLs against a phishing/malware blocklist before
  redirecting — a URL shortener is a phishing vector.
- Observability: redirect latency p99, cache hit rate, 404 rate, and writes/sec as
  the core dashboards; alert on cache-hit-rate drop (your read scaling is failing).
- The "what breaks at 10x" answer: cache becomes the bottleneck before the DB does;
  shard the cache and push 301s to the CDN.
