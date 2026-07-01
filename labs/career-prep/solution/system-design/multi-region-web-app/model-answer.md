# System Design Model Answer — Multi-Region Web Application

> Reference answer for the `multi-region-web-app` prompt. This is the classic
> **availability + data consistency across geography** problem and the one where
> DevOps/SRE candidates are expected to shine: failover, replication lag, the
> CAP trade-off made concrete, and DNS/traffic steering. Use `scoring-rubric.md`.

The whole problem is a tension: **users worldwide want low latency and the app
must survive a whole region dying — but your data can only be strongly consistent
in one place at a time.** How you resolve that tension is the interview.

---

## 1. Requirements clarification (~3 min)

**Functional:**
- Serve a web application (think e-commerce / SaaS dashboard) to users on multiple
  continents with low latency.
- Survive the loss of an **entire region** (provider AZ-wide or region-wide outage)
  with minimal downtime.

**Non-functional (the drivers):**
- **Availability target:** e.g. **99.99%** (~52 min/year). Drives multi-region.
- **Latency:** users served from a nearby region; p95 page < 200 ms.
- **RTO / RPO:** Recovery Time Objective (how fast you fail over) and Recovery Point
  Objective (how much data you can lose). These two numbers determine the entire
  data architecture — **ask for them explicitly.**
- **Consistency needs:** which data must be strongly consistent (payments,
  inventory, account balance) vs which tolerates eventual consistency (product
  catalog, user profile, view counts)?

**Clarifying questions:**
- Active-active (all regions serve writes) or active-passive (one primary, others
  standby/read)? This is *the* fork.
- What's the read/write ratio? (Most web apps are heavily read-skewed → favors
  read replicas in every region.)
- Are there data-residency/compliance constraints (GDPR — EU data stays in EU)?

---

## 2. Capacity / availability math (~3 min)

- Suppose **10M DAU**, **50k requests/sec** peak globally, read:write ≈ **20:1** →
  ~47.5k reads/sec, ~2.5k writes/sec.
- Availability arithmetic: a single region at 99.9% (~8.8 hr/yr down). Two regions,
  *independent failures*, with fast failover → combined unavailability ≈ 0.001² ≈
  **99.9999%** in theory — but real failover is imperfect (DNS TTL, replication
  catch-up, cold caches), so you realistically target **99.99%**. State that the
  gap between theory and reality *is* the failover machinery.
- **Replication lag budget:** cross-region async replication is typically tens to
  low-hundreds of ms. That lag **is your RPO** in active-passive: if the primary
  dies, you lose whatever hadn't replicated. Quantify it.
- **Bandwidth/cost:** cross-region data transfer is a real, recurring cost line —
  call it out; replicating all writes to N regions multiplies egress.

---

## 3. The architecture fork: active-passive vs active-active

| | **Active-Passive (recommended default)** | **Active-Active** |
|--|------------------------------------------|-------------------|
| Writes | One **primary** region; others are warm standbys / read replicas. | All regions accept writes. |
| Reads | Served locally from each region's replica. | Served locally. |
| Failover | Promote a standby to primary on outage (RTO = detection + promotion + DNS). | No failover for writes — already everywhere. |
| Consistency | Strong within primary; replicas eventually consistent. | **Hard:** concurrent writes in two regions conflict. Needs conflict resolution (CRDTs, last-write-wins, or per-row region ownership). | 
| Complexity | Moderate. | High — most teams underestimate this. |
| When | Most apps. Write volume is low; a few-minute RTO is acceptable. | Truly global write latency requirements, or can't tolerate any write-region outage. |

**Recommended:** **active-passive with read replicas in every region** for most
systems — reads are local and fast, writes go to one primary (cross-region write
latency is acceptable because writes are rare), and you fail over the primary on a
region loss. **Reach for active-active only when** the write-latency or
write-availability requirement genuinely forces it, and then be honest about the
conflict-resolution cost.

---

## 4. High-level architecture

```
                         ┌─────────────────────┐
            user ───────▶│  Global DNS / Anycast│  (Route 53 / Cloud DNS,
                         │  latency + health    │   health-checked failover)
                         └──────┬───────┬───────┘
                  ┌─────────────┘       └─────────────┐
                  ▼                                   ▼
        ╔══════ REGION A (primary) ══════╗  ╔══════ REGION B (standby) ══════╗
        ║ CDN → LB → stateless app tier  ║  ║ CDN → LB → stateless app tier  ║
        ║          │            │        ║  ║          │            │        ║
        ║      ┌───▼───┐    ┌───▼────┐   ║  ║      ┌───▼───┐    ┌───▼────┐   ║
        ║      │ cache │    │ DB     │   ║  ║      │ cache │    │ DB     │   ║
        ║      │(Redis)│    │PRIMARY │───╫──╫─────▶│(Redis)│    │REPLICA │   ║
        ║      └───────┘    └────────┘   ║  ║      └───────┘    └────────┘   ║
        ╚════════════════════════════════╝  ╚════════════════════════════════╝
                              └── async cross-region replication ──┘
   Static assets: CDN (multi-region edge). Object storage: cross-region replicated.
```

- **Traffic steering:** global DNS (Route 53 / Cloud DNS) with **latency-based
  routing** + **health checks** that pull a region out of rotation when it fails.
  Anycast or a global load balancer is the lower-TTL alternative to DNS failover.
- **App tier:** stateless in every region → trivially horizontally scalable and
  region-independent. Sessions in a shared/replicated store (Redis) or stateless
  JWTs, *not* in app memory.
- **Data tier:** primary DB in region A, async read replicas in B (and beyond).
  Writes route to the primary; reads served locally.
- **Static/blob:** CDN for assets; object storage with cross-region replication.

---

## 5. Data, consistency, and the CAP trade-off made concrete

This is where the design is won. Be specific about **which data gets which
consistency**:

- **Strong consistency (single primary):** payments, inventory decrements, account
  balances. These route to the primary; cross-region write latency is acceptable
  because they're rare and correctness > latency.
- **Eventual consistency (read replicas everywhere):** product catalog, profiles,
  search index, view counts. Local reads, replicated asynchronously. A user seeing
  a 200-ms-stale catalog is fine; a double-charged card is not.
- **Read-your-own-writes:** the gotcha. A user who just placed an order then reads
  from a lagging local replica may not see it. Fix: route a user's reads to the
  primary for a short window after they write, or read from primary for that user's
  session, or use sticky/causal consistency.

**CAP in this context:** during a network partition between regions you must choose.
Active-passive chooses **CP** for writes (only the primary accepts writes; a
partitioned standby refuses to write rather than diverge) — it sacrifices write
availability in the minority partition to keep data consistent. Active-active
typically chooses **AP** (both sides keep writing) and pays for it with conflict
resolution. **Name the choice and own its consequence.**

---

## 6. Failover — the part SREs are expected to nail

RTO is the sum of: **detect** (health checks, ~10–30 s) + **decide/promote** (promote
replica to primary) + **redirect** (DNS TTL or global LB cutover) + **warm** (caches
cold in the new region).

- **Detection:** health checks on the DNS/global-LB layer; don't rely on a human.
- **DB promotion:** automated replica promotion (and crucially, **fencing** the old
  primary so you don't get split-brain if it comes back). This is the dangerous
  step — a botched promotion causes data divergence.
- **DNS TTL:** keep it low (30–60 s) so clients re-resolve to the surviving region
  quickly; or use a global LB / Anycast to avoid DNS-cache lag entirely.
- **RPO:** equals the replication lag at the moment of failure — the un-replicated
  writes are lost. State this honestly; reducing it means synchronous replication,
  which costs write latency.
- **Test it:** the failover you've never tested doesn't work. Game-day drills.

---

## 7. Key trade-offs to articulate

- **Active-passive vs active-active** — the headline fork; default to passive,
  justify active only when forced.
- **Strong vs eventual consistency, per data class** — don't apply one globally.
- **CAP choice during partition** — CP (refuse minority writes) vs AP (write both,
  resolve conflicts).
- **RTO/RPO vs cost** — synchronous replication shrinks RPO to ~0 but adds
  cross-region write latency and cost; async is cheaper but loses data on failover.
- **DNS failover vs global LB/Anycast** — TTL lag vs cost/complexity.
- **Data residency** — compliance may *forbid* replicating EU user data to other
  regions, constraining the whole design.

---

## 8. What a great candidate adds (senior signal)

- Separates consistency requirements **per data type** instead of one global choice.
- Raises **read-your-own-writes** and split-brain/fencing unprompted.
- Quantifies RPO as the replication lag and ties it to a business decision.
- Insists failover must be **tested** (game days) — names the "untested DR" trap.
- Brings up data residency/GDPR as a hard constraint, not an afterthought.
- Notes cross-region egress as a real cost line and a reason not to over-replicate.
