# System Design Model Answer — Observability Pipeline

> Reference answer for the `observability-pipeline` prompt: design the system that
> ingests, processes, stores, and queries **metrics, logs, and traces** for a large
> fleet. This is the most DevOps/SRE-native of the five and where domain depth
> shows: cardinality, retention tiering, sampling, and back-pressure. Use
> `scoring-rubric.md`. Connects directly to this course's `labs/observability`.

The trap in this problem is treating it like a generic data pipeline. The
*observability-specific* concerns — high-cardinality metrics, log volume vs cost,
trace sampling, and not falling over during the incident you exist to observe —
are what's being tested.

---

## 1. Requirements clarification (~3 min)

**Functional:**
- Ingest the **three pillars**: **metrics** (time series), **logs** (structured
  events), **traces** (distributed request spans) from a fleet of services.
- Process/enrich (add metadata, parse, derive), store with appropriate retention,
  and serve **queries + dashboards + alerts**.

**Non-functional (the drivers):**
- **High, spiky ingest volume** — and it spikes *exactly during incidents*, when
  you need it most. The pipeline must not collapse under the load it's built to
  observe.
- **Query latency** — dashboards and alert evaluation must be fast (sub-second to
  seconds) over recent data.
- **Cost** — observability data is enormous; retention and sampling are
  cost-control levers, not afterthoughts.
- **Reliability of the pipeline itself** — losing telemetry during an incident is a
  failure of the whole point.

**Clarifying questions:**
- Fleet size / events-per-second per pillar? Retention requirements per pillar
  (and any compliance-driven log retention)?
- Real-time alerting latency requirement (how stale can alert data be)?
- Build vs buy — are we designing a self-hosted stack or integrating a vendor
  (Datadog/Grafana Cloud)? (Affects where the hard parts live.)

---

## 2. Capacity math (~4 min)

Telemetry volume is huge — the math is the point. Suppose **5,000 hosts/services**:

- **Metrics:** say 1,000 series/host × 5k hosts = **5M active series**, scraped
  every 15 s → **~330k samples/sec**. Cardinality is the killer (see §4).
- **Logs:** 5k services × ~100 log lines/sec × ~500 B = **~250 MB/s ≈ 21 TB/day**
  raw. This dwarfs metrics and is the dominant cost.
- **Traces:** 50k req/sec, one trace each, ~10 spans × ~500 B = a lot — which is
  exactly why you **sample** (you don't store 100% of traces).
- **Retention tiering:** you cannot keep 21 TB/day of logs hot forever. Tier it:
  hot (7–15 days, fast query), warm/compressed (30–90 days), cold/object-storage
  archive (compliance), then delete. Metrics: high-res recent, downsampled
  (rolled-up) for long-term.
- **Conclusion to voice:** this is a **volume + cost + cardinality** problem.
  Storage tiering and sampling aren't optimizations here — they're load-bearing.

---

## 3. High-level architecture

```
 services/hosts          collection            buffer/transport        storage + query
 ┌───────────┐    ┌──────────────────┐    ┌───────────────┐    ┌──────────────────────┐
 │  app +    │    │ agent / collector│    │ message queue │    │ Metrics TSDB         │
 │  OTel SDK │───▶│ (OTel Collector, │───▶│  (Kafka)      │───▶│ (Prometheus/Mimir/   │
 │  metrics  │    │  Fluent Bit,     │    │  = buffer +   │    │  Cortex/VictoriaM.)  │
 │  logs     │    │  Prom agent)     │    │  back-pressure│    ├──────────────────────┤
 │  traces   │    │ - batch          │    │  + replay     │───▶│ Logs store           │
 └───────────┘    │ - sample         │    └───────────────┘    │ (Loki/Elastic/OpenS.)│
                  │ - enrich/redact  │                         ├──────────────────────┤
                  └──────────────────┘                         │ Trace store          │
                                                               │ (Tempo/Jaeger)       │
                                                               └──────────┬───────────┘
                                                                          ▼
                                              dashboards (Grafana) · alerting (Alertmanager)
```

**Why each layer:**
- **Collection (agent/collector):** an **OpenTelemetry Collector** (or Fluent Bit
  for logs, Prometheus agent for metrics) runs near the workload. It **batches,
  samples, enriches (adds k8s/host metadata), and redacts** before shipping. Doing
  this at the edge cuts volume and cost early.
- **Buffer / transport (Kafka):** the most important reliability decision. A durable
  queue **decouples ingest from storage**, absorbs spikes (the incident spike
  doesn't crush the TSDB), provides **back-pressure**, and lets you **replay** if a
  storage backend is down. Without it, a storage hiccup = lost telemetry.
- **Storage, per pillar (they have different shapes):**
  - **Metrics** → a TSDB (Prometheus + remote-write to Mimir/Cortex/Thanos, or
    VictoriaMetrics) — optimized for time-series, downsampling, range queries.
  - **Logs** → an index/store tuned for high write + text search (Loki, which is
    cheap because it indexes labels not full text; or Elastic/OpenSearch when you
    need rich full-text search and can pay for it).
  - **Traces** → a trace store (Tempo, Jaeger) keyed by trace ID.
- **Query/serve:** Grafana for dashboards across all three; Alertmanager for routing.

---

## 4. The observability-specific hard parts

These distinguish a real answer from a generic data-pipeline answer:

### a) Metric cardinality — the silent killer
Each unique combination of label values is a separate time series. Adding a
high-cardinality label (`user_id`, `request_id`, `full URL path`) to a metric can
explode 5M series into hundreds of millions, OOM the TSDB, and blow up cost. **Rule:
labels must be bounded** (HTTP method, status class, route *template* not raw path,
region). High-cardinality dimensions belong in **logs/traces**, not metric labels.
A strong candidate names this unprompted and proposes guardrails (cardinality
limits, dropping offending labels at the collector).

### b) Trace sampling
You can't store 100% of traces at 50k req/sec — and you don't need to.
- **Head sampling:** decide at the start (e.g. keep 1%). Cheap, but you might drop
  the one trace that mattered.
- **Tail sampling:** buffer the full trace, then keep it **if it's interesting**
  (errored, slow > p99). Far better signal-to-cost, but needs the collector to hold
  spans until the trace completes. **Prefer tail sampling for error/latency
  traces** + a low baseline head sample for the happy path.

### c) Pipeline self-reliability under load (back-pressure)
The pipeline is busiest during the incident it must observe. The Kafka buffer is
what saves you: ingest writes to Kafka (fast, durable); storage consumes at its own
pace. If storage falls behind, data queues in Kafka instead of being lost, and you
catch up after. Set ingest rate limits / drop policies (shed low-value telemetry
first) so the pipeline degrades gracefully rather than dying.

### d) Cost / retention tiering
Already covered in capacity. The lever: hot (queryable, expensive) → warm
(compressed) → cold (object storage, compliance) → delete. Downsample old metrics
(1-minute rollups don't need 15-second resolution after a week).

---

## 5. Data model notes

- **Metrics:** `(metric_name, {bounded labels}) → [(timestamp, value)]`. Bounded
  label sets are everything.
- **Logs:** structured JSON events; index a *few* labels (service, level, host),
  not the full body (Loki's model) unless full-text search is a hard requirement.
- **Traces:** a trace = a tree of spans sharing a `trace_id`; each span has
  `span_id`, `parent_id`, service, duration, attributes. Stored keyed by trace ID
  for lookup; sampled on the way in.
- **Correlation:** propagate `trace_id` into logs and exemplars into metrics so you
  can pivot metric → trace → logs for one request. This is the payoff of unifying
  the three pillars.

---

## 6. Key trade-offs to articulate

- **Build vs buy:** self-hosted (Prometheus/Loki/Tempo/Grafana — control + cost
  at scale, ops burden) vs vendor (Datadog/Grafana Cloud — fast, expensive at
  volume, less control). The volume math drives this.
- **Sampling vs completeness:** tail sampling keeps signal at lower cost but risks
  dropping something; 100% is honest but unaffordable at scale.
- **Index-everything (Elastic) vs index-labels (Loki):** rich search & cost vs cheap
  & label-scoped.
- **Retention vs cost:** how long hot, when to downsample/archive — a direct dollar
  dial.
- **Cardinality control vs developer freedom:** bounded labels protect the system
  but constrain what teams can slice by; you trade flexibility for stability.

---

## 7. What a great candidate adds (senior signal)

- Names **cardinality explosion** as the #1 metrics failure mode and proposes
  collector-level guardrails — the clearest senior signal on this problem.
- Chooses **tail sampling** for traces with a reasoned head-sample baseline.
- Puts a **durable queue (Kafka) as a buffer** and explains back-pressure + replay,
  i.e. designs the pipeline to survive the incident it observes.
- Tiers retention with explicit hot/warm/cold and metric downsampling.
- Correlates the three pillars via `trace_id`/exemplars for one-request pivoting.
- Connects to real practice: this is exactly what `labs/observability` builds in
  miniature (Prometheus rules, RED metrics, burn-rate alerts).
