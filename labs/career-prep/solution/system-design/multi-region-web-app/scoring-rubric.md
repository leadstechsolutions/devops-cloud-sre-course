# Scoring Rubric — Multi-Region Web Application

> Score 0–2 per dimension. Max **20**. This problem separates candidates on
> **data consistency across regions** and **failover mechanics**. Anyone can draw
> two regions; the bar is reasoning about replication lag, the CAP choice, and a
> tested failover with fencing.

| # | Dimension | What a 2 looks like | Pts |
|--:|-----------|---------------------|----:|
| 1 | **Requirements & scoping** | Asks for availability target, RTO/RPO, and which data must be strongly consistent; surfaces data-residency constraints. | /2 |
| 2 | **Capacity / availability math** | Estimates traffic, read/write skew, replication-lag-as-RPO; explains why real failover undershoots theoretical availability. | /2 |
| 3 | **Active-passive vs active-active** | Compares them, defaults to passive with reasoning, and names when active-active is actually justified. | /2 |
| 4 | **Traffic steering / DNS** | Latency-based routing + health-checked failover; understands DNS TTL lag vs global LB/Anycast. | /2 |
| 5 | **Stateless app tier** | App tier stateless + sessions externalized so regions are independent and horizontally scalable. | /2 |
| 6 | **Per-data-class consistency** | Assigns strong vs eventual consistency by data type (payments strong, catalog eventual) rather than one global choice. | /2 |
| 7 | **CAP / partition behavior** | Makes an explicit CP-or-AP choice for the partition case and owns its consequence (refuse writes vs resolve conflicts). | /2 |
| 8 | **Failover mechanics** | Breaks RTO into detect/promote/redirect/warm; raises replica promotion, fencing/split-brain, and low TTL. | /2 |
| 9 | **Trade-offs & cost** | Sync-vs-async replication (RPO vs latency), cross-region egress cost, and that failover must be tested. | /2 |
| 10 | **Communication & structure** | Scoped first, drew a clear two-region diagram, separated read and write paths, managed time. | /2 |

**Total: ___ / 20**

### Bands
- **17–20** — Strong hire. Per-data consistency, CAP choice, and fenced/tested failover all present.
- **13–16** — Hire. Solid topology and failover, missed a consistency nuance.
- **9–12** — Mixed. Drew two regions but treated data as one consistency blob or hand-waved failover.
- **< 9** — Below bar. "Just deploy to two regions" with no replication, consistency, or failover story.

### Red flags (cap the score)
- Treats all data as one consistency model (everything strong, or everything eventual).
- Active-active proposed with no conflict-resolution story.
- No RTO/RPO discussion; replication lag never mentioned.
- Failover hand-waved ("DNS will handle it") with no fencing/split-brain awareness.
- Session state in app memory, breaking region independence.

### Green flags (senior signal)
- Raises read-your-own-writes and routes recent writers to the primary.
- Names split-brain and fences the old primary on promotion.
- Quantifies RPO as the replication lag and frames it as a business decision.
- Insists failover be drilled (game days); names the untested-DR trap.
- Brings up GDPR/data residency as a hard design constraint.
