# Scoring Rubric — Observability Pipeline

> Score 0–2 per dimension. Max **20**. This problem rewards **domain depth**:
> cardinality, sampling, retention tiering, and pipeline self-reliability. A
> candidate who designs a generic ETL pipeline without the observability-specific
> concerns is below the bar for an SRE/observability role.

| # | Dimension | What a 2 looks like | Pts |
|--:|-----------|---------------------|----:|
| 1 | **Requirements & scoping** | Names the three pillars, asks for fleet size/EPS and retention per pillar, and the alerting-latency requirement. | /2 |
| 2 | **Capacity math** | Estimates metrics samples/sec, log TB/day, trace volume; concludes it's a volume+cost+cardinality problem. | /2 |
| 3 | **Collection layer** | Agent/OTel collector at the edge that batches, enriches, redacts, and samples before shipping. | /2 |
| 4 | **Durable buffer / back-pressure** | Puts a queue (Kafka) between ingest and storage for spike absorption, decoupling, and replay. | /2 |
| 5 | **Per-pillar storage** | Different stores for metrics (TSDB), logs (Loki/Elastic), traces (Tempo/Jaeger) with justification for each shape. | /2 |
| 6 | **Cardinality control** | Identifies high-cardinality labels as the #1 metrics failure mode and proposes bounded labels / guardrails. | /2 |
| 7 | **Trace sampling** | Compares head vs tail sampling; prefers tail for errors/slow traces with a head baseline. | /2 |
| 8 | **Retention / cost tiering** | Hot/warm/cold tiers + metric downsampling tied explicitly to cost. | /2 |
| 9 | **Pipeline reliability under load** | Recognizes the pipeline spikes during incidents and designs it to degrade gracefully (queue, rate limits, shed low-value data). | /2 |
| 10 | **Communication & structure** | Scoped first, separated the three pillars, clear pipeline diagram, time-managed; bonus for trace_id correlation. | /2 |

**Total: ___ / 20**

### Bands
- **17–20** — Strong hire. Cardinality, tail sampling, buffered back-pressure, and tiering all present.
- **13–16** — Hire. Solid pipeline and storage, missed one observability-specific concern.
- **9–12** — Mixed. Built a generic pipeline; weak on cardinality or sampling or back-pressure.
- **< 9** — Below bar. Treated it as one big database; no sampling, no cardinality awareness, no buffer.

### Red flags (cap the score)
- One store for all three pillars ("just put it in Elasticsearch").
- No mention of metric cardinality.
- Stores 100% of traces with no sampling story at 50k req/sec.
- No buffer between ingest and storage → telemetry lost when storage hiccups.
- No retention/cost story for 20+ TB/day of logs.

### Green flags (senior signal)
- Cardinality explosion called out unprompted with collector-level guardrails.
- Tail sampling for error/latency traces + low head baseline.
- "The pipeline is busiest during the incident it observes" — designs for that.
- Correlates pillars via trace_id / exemplars for one-request pivoting.
- Reasons build-vs-buy from the volume math.
