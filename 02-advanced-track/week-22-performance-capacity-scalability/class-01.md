# Week 22: Performance, Capacity, and Scalability
> **▶ Runnable lab for this class:** [`labs/performance-scaling/`](../../labs/performance-scaling/) · [`labs/sre-incident-response/`](../../labs/sre-incident-response/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 1: Latency, Throughput, Saturation, and Bottlenecks

**Course:** Enterprise DevOps, Cloud Engineering, and Site Reliability Engineering Program
**Track:** Unified DevOps · Cloud · SRE Track
**Week:** 22
**Class:** 1 of 2
**Duration:** 3 hours
**Primary Cloud:** AWS
**Secondary Cloud Exposure:** Azure and GCP
**Audience:** Intermediate learners preparing for DevOps Engineer, Cloud Engineer, and Site Reliability Engineer roles

---

## 1. Class Overview

### Class Title

**Latency, Throughput, Saturation, and Bottlenecks**

### Class Purpose

This class teaches students how to *measure* and *reason about* the performance of a production system, and then how to *locate the bottleneck* using evidence rather than guesswork. Performance is one of the most senior-relevant skill areas in the course: it shows up in incident response, in cost reviews, in capacity planning, and in nearly every system-design interview.

The core thesis of the week — reinforced in both classes — is:

> **A performance problem is not always a scaling problem. Identify the bottleneck first, prove it with evidence, then choose the safest fix.**

In this class students will (1) learn the vocabulary and statistics of performance (latency percentiles, throughput, saturation, the RED and USE methods, Little's Law), (2) *generate* load against a real service using a runnable k6 script, (3) *read* the resulting metrics, and (4) *trace* a slow request to its root cause using profiling and distributed tracing. Class 2 then builds on this to do capacity planning and scaling.

### How This Class Connects to the Overall Course

| Earlier / Later Week | Connection |
|---|---|
| Week 10 (Docker) / Week 11–13 (Kubernetes, Helm) | We load-test a containerized app running on Kubernetes. |
| Week 16 (Observability & Reliability) | We reuse Prometheus, Grafana, and OpenTelemetry to read latency and saturation. |
| Week 21 (SRE Foundations: SLI/SLO/Error Budgets) | Latency percentiles are the raw material of latency SLIs and SLOs. |
| Week 22 Class 2 (Capacity & Scaling) | The metrics and load tests from this class feed the capacity plan and autoscaling decisions. |
| Week 23–24 (Capstone) | The load-test harness built here is reused to validate the capstone under load. |

### What Students Will Build, Analyze, or Practice

- A runnable **k6 load test** (ramping, steady, and soak profiles) against a containerized demo API.
- A read-back of **p50/p95/p99 latency, throughput, error rate, and saturation** from k6 output and Grafana.
- A **bottleneck investigation** that distinguishes an app-CPU bottleneck from a database-connection bottleneck.
- A **connection-pool sizing calculation** using Little's Law.
- A **flame graph / trace** walkthrough to attribute latency to a specific span.

---

## 2. Class Learning Objectives

By the end of this class, students will be able to:

1. **Explain** the difference between latency, throughput, and saturation, and why p99 latency is not the average.
2. **Apply** the RED method (Rate, Errors, Duration) and the USE method (Utilization, Saturation, Errors) to triage a service.
3. **Build and run** a k6 load test with ramp, steady-state, and soak stages, and **interpret** its output.
4. **Distinguish** open-model from closed-model load generation and explain coordinated omission.
5. **Calculate** a target connection-pool / concurrency size using Little's Law.
6. **Locate** a bottleneck using profiling (flame graphs) and distributed tracing (spans) rather than dashboard metrics alone.
7. **Troubleshoot** a high-latency, low-CPU incident and recommend an evidence-based fix.
8. **Document** an investigation using the symptom → evidence → root-cause → fix → validate methodology.

---

## 3. Prerequisites Students Should Already Know

**Prior concepts**
- Basic Kubernetes objects: Pods, Deployments, Services (Week 11).
- Reading metrics in Prometheus/Grafana and the idea of a histogram metric (Week 16).
- The SLI/SLO vocabulary from Week 21 (availability, latency objective, error budget).
- Basic HTTP, status codes, and the request/response model.

**Tools already installed**
- `kubectl` configured against a working cluster (local `kind`/`minikube`, or an EKS dev cluster).
- `k6` (`brew install k6`, `winget install k6`, or the Docker image `grafana/k6`).
- `helm` (Week 13) and `docker` (Week 10).
- AWS CLI v2 configured via IAM Identity Center / SSO (`aws sso login`) — only needed for the optional CloudWatch read-back.

**Accounts / access**
- A Kubernetes cluster you can deploy to (a local cluster is sufficient and free).
- Optional: an AWS account via SSO for the CloudWatch comparison (stay in free-tier-eligible resources).

**Files / repos**
- The class lab repo `week-22-perf-lab/` (provided), containing the demo app manifests and the k6 scripts shown below. Students who completed earlier weeks can also point the load test at their own capstone API.

> **Cost & security note:** The primary lab runs entirely on a local cluster and costs nothing. The optional AWS read-back uses CloudWatch (free-tier metrics) and EKS — if you spin up EKS for this, follow the cleanup steps at the end of Class 2 to avoid node-hours charges. Never run a load test against a production system or a third-party service you do not own.

---

## 4. Key Terms and Definitions

| Term | Beginner-friendly definition | Real-world context |
|---|---|---|
| **Latency** | How long *one* request takes, end to end. | A checkout call that normally takes 200 ms now takes 3 s. |
| **Throughput** | How *many* requests the system completes per unit time (req/s, RPS). | The API serves 1,200 RPS at peak. |
| **Percentile (p50/p95/p99)** | The value below which that % of requests fall. p99 = "the slowest 1% are at least this slow." | p50 = 150 ms but p99 = 4 s means 1 in 100 users has a terrible experience. |
| **Saturation** | How "full" a resource is — its queue depth or how close it is to its limit. | DB connection pool at 98% of max; run queue length > number of CPUs. |
| **Utilization** | The fraction of time a resource was busy. | CPU 80% utilized. (Different from saturation: a resource can be 60% utilized but have a deep wait queue.) |
| **Error rate** | Fraction of requests that fail (5xx, timeouts). | 4.8% of requests returned 503 during peak. |
| **Bottleneck** | The single most constrained resource that caps overall throughput. | The DB, not the app, is the bottleneck — adding pods won't help. |
| **RED method** | Rate, Errors, Duration — the three signals to watch *per service* (request-driven). | Grafana row per service: RPS, error %, p95 latency. |
| **USE method** | Utilization, Saturation, Errors — the three signals to watch *per resource* (resource-driven). | Per node/disk/pool: % busy, queue depth, error count. |
| **Little's Law** | Concurrency (L) = Throughput (λ) × Latency (W). | If you serve 500 RPS at 200 ms latency, ~100 requests are in flight at once. |
| **Coordinated omission** | When a load tester *waits* for a slow response before sending the next request, it under-counts how bad latency really is. | A closed-model test reports better p99 than users actually experience. |
| **Open vs closed model** | Open = arrivals happen at a fixed rate regardless of responses (models real users). Closed = a fixed number of virtual users loop (models a connection pool). | Use open-model when modeling internet traffic; closed-model when modeling a downstream caller with N connections. |
| **Profiling** | Sampling where CPU time / allocations are spent inside a process, usually visualized as a flame graph. | `pprof`, `async-profiler`, Pyroscope. |
| **Distributed tracing** | Following one request across services as a tree of timed spans. | OpenTelemetry trace shows 90% of latency is in the `db.query` span. |
| **Warm-up / ramp / soak** | Warm-up lets JIT/caches/connection pools stabilize; ramp increases load gradually; soak holds load for a long time to expose leaks. | A 30-min soak surfaces a memory leak that a 2-min test hides. |

---

## 5. Tools Used

| Tool | Why it is used |
|---|---|
| **k6** (Grafana) | Scriptable, open-model-capable load generator. Writes tests in JavaScript, emits percentiles natively, easy to put in CI. |
| **Locust** (mentioned/alternative) | Python-based load tool; useful when teams prefer Python or need complex user behavior. |
| **kubectl** | Inspect pods, events, logs, `kubectl top` for live CPU/memory. |
| **Prometheus + Grafana** | Read RED/USE signals over time; histogram_quantile for p95/p99. |
| **OpenTelemetry + Jaeger/Tempo** | Distributed tracing to attribute latency to a span. |
| **pprof / async-profiler / Pyroscope** | CPU and heap profiling → flame graphs to find hot code. |
| **AWS CloudWatch** (optional) | Cross-check RDS connections / CPU and ALB target response time. |

---

## 6. AWS Services Used

| AWS Service | How it connects to this class |
|---|---|
| **CloudWatch Metrics** | ALB `TargetResponseTime`, `HTTPCode_Target_5XX_Count`, RDS `DatabaseConnections`, `CPUUtilization` — the production version of the metrics we read from k6/Grafana. |
| **CloudWatch Logs / Container Insights** | Pod-level CPU/memory and structured logs during an investigation. |
| **Amazon EKS** | Where the load-tested workload runs in the AWS version of the lab. |
| **Amazon RDS** | The database whose connection saturation is the canonical "scaling won't help" bottleneck. |
| **AWS X-Ray** | AWS-native distributed tracing alternative to Jaeger/Tempo for latency attribution. |

---

## 7. Azure and GCP Comparison Notes

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Metrics & dashboards | CloudWatch | Azure Monitor | Cloud Monitoring |
| Managed Kubernetes | EKS | AKS | GKE |
| Managed DB metrics | RDS metrics | Azure SQL / PostgreSQL metrics | Cloud SQL metrics |
| Distributed tracing | X-Ray (or OTel→Tempo) | Application Insights | Cloud Trace |
| Load balancer latency metric | ALB `TargetResponseTime` | App Gateway latency | Cloud Load Balancing latency |

Keep AWS as the primary example. The percentile math, RED/USE, Little's Law, and k6 are cloud-agnostic.

---

## 8. Time-Boxed Instructor Agenda

| Time | Topic |
|---:|---|
| 0:00 – 0:10 | Opening scenario: API slows during peak; "do we just add pods?" |
| 0:10 – 0:35 | Performance statistics: latency vs throughput vs saturation; why p99 ≠ average; coordinated omission |
| 0:35 – 0:55 | The RED and USE methods; Little's Law (and the connection-pool calculation) |
| 0:55 – 1:20 | Load testing concepts: open vs closed model, warm-up/ramp/steady/soak; walk the k6 script |
| 1:20 – 1:35 | **Break** |
| 1:35 – 2:00 | Instructor demo: run the k6 test, read p95/p99/throughput, watch saturation in Grafana |
| 2:00 – 2:15 | Profiling & tracing: flame graphs and spans to locate the bottleneck |
| 2:15 – 2:50 | Student lab: load test the demo app, find the bottleneck, size the pool with Little's Law |
| 2:50 – 3:00 | Troubleshooting recap, discussion, homework |

---

## 9. Instructor Lesson Plan

1. **Hook (10 min).** Show the opening scenario metrics table (Section 14). Ask the room: "What do you do first?" Capture answers. Most will say "add pods." Note them — you will revisit at the end.
2. **Statistics (25 min).** Teach percentiles using a concrete list of 10 latencies (Section 11 lecture notes). Stress that **averages hide tail latency** and that a user's session touches many requests, so the *tail* is what they feel. Introduce coordinated omission. Pause for questions.
3. **Frameworks (20 min).** Name RED and USE explicitly and map each onto the request path. Derive Little's Law and *use it on the board* to compute a connection-pool target. This is the math the old version of this class kept gesturing at but never showed.
4. **Load-test design (25 min).** Walk the k6 script line by line. Explain `stages`, `thresholds`, `http_req_duration{p(95)}`, and open vs closed model (`ramping-vus` is closed; `ramping-arrival-rate` is open). Emphasize warm-up and soak.
5. **Break (15 min).**
6. **Demo (25 min).** Run k6 live against the demo app (Section 12). Read the summary. Switch to Grafana and correlate: throughput plateaus while p99 climbs — classic saturation knee. Pause for questions.
7. **Profiling/tracing (15 min).** Open a trace; show that the slow span is `db.query`, not app CPU. Show a flame graph and identify the hot frame.
8. **Lab (35 min).** Students run the test, fill the metrics table, locate the bottleneck, and compute a pool size. Circulate.
9. **Recap (10 min).** Return to the hook: the right first move was *measure and locate*, not *add pods*. Assign homework.

**Teaching tip:** keep redirecting "the server is slow" to "*which resource* is saturated, and *what evidence* shows it?"

---

## 10. Instructor Lecture Notes

### 10.1 Latency vs throughput vs saturation

> "Latency is *per request*. Throughput is *per second*. Saturation is *how full the queue is*. They move together but they are not the same — and confusing them is the #1 junior mistake."

A useful mental model is a highway. **Throughput** is cars per minute through a toll plaza. **Latency** is how long *your* car takes to get through. **Saturation** is the length of the queue at the booth. As you add cars, throughput rises — until the booths saturate. After that, throughput flattens (or drops) and latency explodes. That inflection is the **knee** of the curve, and finding it is the whole point of load testing.

### 10.2 Why p99 is not the average (the most important 5 minutes)

Take ten request latencies (ms): `100, 110, 120, 120, 130, 140, 150, 160, 900, 1000`.
- **Average** = 293 ms. Looks bad-ish.
- **p50 (median)** = ~130 ms. Looks great.
- **p90** ≈ 900 ms. **p99** ≈ ~1000 ms. The *truth* for your unhappiest users.

The average is dragged around by outliers and hides them at the same time. **The median lies about the tail; the average lies about the typical.** Percentiles tell you both. And because a single user page-load fans out into *many* backend calls, the probability that *at least one* of them hits the slow tail is high — so **tail latency is what users actually feel**. This is why latency SLOs (Week 21) are written as "p99 < 300 ms," never "average < 300 ms."

**Common misconception:** "p99 of 1 s is fine, it's only 1% of requests." If a page makes 50 backend calls, the chance *none* of them is in the slow 1% is `0.99^50 ≈ 60%` — so ~40% of page loads hit at least one slow call. The tail dominates the user experience.

**Coordinated omission:** if your load generator sends a request, waits for the (slow) response, and only *then* sends the next one, it never measures the requests that *would have* arrived during the stall. Real users (and real queues) don't wait politely. Tools mitigate this with open-model / constant-arrival-rate generation. Always know which model your test uses.

### 10.3 RED and USE — name them

- **RED (request-centric, per service):** **R**ate (RPS), **E**rrors (failed/sec or %), **D**uration (latency distribution). This is how you watch a *service*. It maps cleanly to SLIs.
- **USE (resource-centric, per resource):** **U**tilization (% busy), **S**aturation (queue depth / how much work is waiting), **E**rrors (e.g., dropped packets, ENOMEM). This is how you watch a *resource* (CPU, disk, NIC, connection pool, thread pool).

> "RED tells you *the service is unhappy*. USE tells you *which resource is the reason*. You need both: RED finds the symptom, USE finds the cause."

### 10.4 Little's Law — the math under "tune the pool"

`L = λ × W` where **L** = average concurrency (requests in flight), **λ** = throughput (RPS), **W** = average latency (seconds).

Worked example: a service handles **λ = 500 RPS** with average latency **W = 40 ms = 0.04 s** at the database call. Concurrent in-flight DB calls `L = 500 × 0.04 = 20`. So a connection pool of ~20–25 (add headroom) is right. If you size the pool at 200 "to be safe," you don't get more throughput — you get 200 connections hammering the DB, more context switching, and a *worse* bottleneck. **Little's Law is how you turn "tune the pool" into an actual number.**

Same law sizes thread pools and explains the saturation knee: once `L` exceeds the number of available workers/connections, new requests *queue*, `W` climbs, and throughput stops rising.

### 10.5 Locating the bottleneck: dashboards → traces → flame graphs

Dashboards (RED/USE) tell you *where* roughly. To get to the line of code:
- **Distributed tracing** (OpenTelemetry → Jaeger/Tempo/X-Ray) breaks one request into spans. If the `db.query` span is 1.8 s of a 2 s request, the app code is innocent.
- **Profiling** (pprof for Go, async-profiler for JVM, Pyroscope continuous profiling) produces a **flame graph**: width = time spent. A wide frame on `json.Marshal` or `regexp.Compile` is your hot path.
- **eBPF tools** (e.g., `bpftrace`, Parca, Pixie) profile without code changes — increasingly standard in 2026.

> "Metrics say *the database is slow*. A trace says *which query*. A flame graph says *which function*. Stop at the level that lets you fix it."

**Talking point:** "High latency with low CPU almost always means *waiting*, not *computing* — waiting on a lock, a pool, a downstream call, or GC. CPU profiling shows the computing; tracing shows the waiting."

---

## 11. Whiteboard Explanation

### Topic 1: The throughput/latency curve (find the knee)

```text
 Latency (p99)                          Throughput (RPS)
   ^                                        ^
   |                  /                      |        ____________
   |                 /                       |       /            (plateau)
   |                /                        |      /
   |        ______/   <- "knee"             |     /
   |  _____/                                 |    /
   +---------------------> offered load      +-----------------> offered load
                                             ^
                                  knee is at the SAME offered load:
                       throughput stops rising AND p99 starts exploding
```

**Flow:** Increase offered load left→right. Before the knee, throughput rises and latency is flat. *At* the knee, a resource saturates. After the knee, throughput plateaus (booths are full) while latency rockets (queue grows). **Capacity planning = stay left of the knee with headroom.**

### Topic 2: The request path and where to look (RED on top, USE underneath)

```text
User ──► DNS ──► Load Balancer ──► Ingress/Service ──► App Pod ──► DB / Cache / External API
                  (RED: rate,         (RED here too)     |            (USE: DB conns, locks,
                   errors,                               ├─ CPU         disk I/O, replica lag)
                   duration)                             ├─ Memory/GC
                                                         ├─ Thread pool   (USE: queue depth)
                                                         └─ Conn pool     (USE: % of max in use)
```

**Enterprise version:** add OpenTelemetry spans on every hop, Prometheus scraping each component for USE, and a Grafana RED row per service. The trace ID ties a single slow request to the exact saturated resource.

---

## 12. Instructor Demo Script

### Demo Title
**Load-testing a service and reading p95/p99, throughput, and saturation**

### Demo Objective
Generate real load against a containerized API, read the latency distribution and throughput from k6, then correlate the saturation knee in Grafana and confirm the bottleneck is the DB, not app CPU.

### Required Setup
- A running cluster with the demo app deployed (manifests in the lab repo). The demo app is a small HTTP API backed by Postgres with an intentionally small connection pool.
- Prometheus + Grafana installed (Week 16 `kube-prometheus-stack`).
- `k6` installed locally.

Deploy the demo app:

```bash
kubectl create namespace perf-lab
kubectl -n perf-lab apply -f demo-app/        # Deployment + Service + Postgres
kubectl -n perf-lab rollout status deploy/demo-api
kubectl -n perf-lab port-forward svc/demo-api 8080:80 &
```

### The k6 script (`loadtest.js`)

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

// OPEN model: arrivals happen at a fixed rate regardless of response time.
// This avoids coordinated omission and models real internet traffic.
export const options = {
  scenarios: {
    ramp_steady_soak: {
      executor: 'ramping-arrival-rate',
      startRate: 10,            // start at 10 requests/second
      timeUnit: '1s',
      preAllocatedVUs: 50,      // worker pool k6 can use to hit the rate
      maxVUs: 500,
      stages: [
        { target: 10,  duration: '30s' },  // warm-up: let caches/pools stabilize
        { target: 200, duration: '2m'  },  // ramp: climb toward the knee
        { target: 200, duration: '3m'  },  // steady state at peak
        { target: 350, duration: '2m'  },  // push past the knee on purpose
        { target: 0,   duration: '30s' },  // ramp down
      ],
    },
  },
  thresholds: {
    http_req_failed:   ['rate<0.01'],                 // <1% errors
    http_req_duration: ['p(95)<300', 'p(99)<800'],    // latency SLO gates
  },
};

export default function () {
  const res = http.get('http://localhost:8080/api/orders');
  check(res, { 'status is 200': (r) => r.status === 200 });
}
```

Run it:

```bash
k6 run loadtest.js
```

### Expected Output (read this with the class)

```text
     scenarios: (100.00%) 1 scenario, 500 max VUs, 8m0s max duration

     http_req_duration..............: avg=410ms min=22ms med=180ms max=4.1s p(90)=820ms p(95)=1.4s p(99)=3.6s
     http_req_failed................: 3.10%  ✓ 2914      ✗ 91086
     http_reqs......................: 94000  ~196/s
     ✗ http_req_duration............: p(95)=1.4s   (threshold p(95)<300 FAILED)
     ✗ http_req_failed..............: 3.10%        (threshold rate<0.01 FAILED)
```

**What to explain at each step:**
- **avg=410ms but p(99)=3.6s** — say it out loud: "the average looks survivable; the tail is on fire. This is exactly why we read percentiles."
- **http_reqs ~196/s while we asked for up to 350/s** — k6 *could not* sustain the arrival rate. Throughput plateaued: we are past the knee.
- **Failed thresholds** — k6 exits non-zero, so the same script gates a CI pipeline.

Now correlate in Grafana:
- App pod CPU (USE: utilization) stays ~50% — **not** the bottleneck.
- Postgres `connections in use / max` (USE: saturation) pins at 100% the moment p99 climbs — **this** is the bottleneck.

### Common Demo Failure Points & Recovery
- **`port-forward` drops under load.** Use a NodePort/Ingress or run k6 *inside* the cluster as a Job (`grafana/k6` image) against the in-cluster Service DNS `http://demo-api.perf-lab.svc`.
- **k6 hits its own local CPU limit before the app saturates.** Note this is a *generator* bottleneck (watch k6's `dropped_iterations`), and run k6 distributed or in-cluster.
- **No saturation appears.** The demo pool may be too large; reduce `DB_POOL_MAX` in the Deployment env to make the knee obvious.

### Cleanup

```bash
# stop the background port-forward
kill %1 2>/dev/null
kubectl delete namespace perf-lab
```

---

## 13. Student Lab Manual

### Lab Title
**Generate load, read the percentiles, and find the bottleneck**

### Lab Objective
Run a k6 load test against the demo API, capture the latency distribution and throughput, identify the saturated resource using USE, and compute a correct connection-pool size with Little's Law.

### Estimated Time
35 minutes

### Student Prerequisites
- Cluster with `demo-app` deployed (instructor provides) and Grafana reachable.
- `k6` installed; `loadtest.js` from the repo.

### Architecture Overview

```text
k6 (open model) ──► demo-api (Deployment, N pods) ──► Postgres (small conn pool)
        ▲                     │                              │
        └── reads p50/p95/p99 │ Prometheus scrapes USE on both
            throughput, errors▼
                            Grafana
```

### Step-by-Step Instructions

1. Confirm the app is up:
   ```bash
   kubectl -n perf-lab get pods
   kubectl -n perf-lab port-forward svc/demo-api 8080:80 &
   ```
2. Run a short **warm-up only** sanity test:
   ```bash
   k6 run --vus 5 --duration 30s loadtest.js
   ```
   Confirm `http_req_failed` is ~0 and p95 is low. This is your baseline.
3. Run the full ramp/steady/soak test:
   ```bash
   k6 run loadtest.js
   ```
4. Record the results in this table:

   | Metric | Warm-up baseline | At peak (push stage) |
   |---|---:|---:|
   | Throughput (req/s) | | |
   | p50 latency | | |
   | p95 latency | | |
   | p99 latency | | |
   | Error rate | | |
   | App pod CPU (Grafana) | | |
   | DB connections in use / max (Grafana) | | |

5. In Grafana, open the **USE** panels for the app pod and Postgres. Note the *exact moment* p99 starts climbing and which resource saturates at that moment.
6. **Compute the pool size with Little's Law.** Using your measured peak throughput `λ` and the *average DB call latency* `W` from the trace/metrics:
   ```text
   L = λ × W
   Example: λ = 200 req/s, W (db call) = 0.05 s  →  L = 10 in-flight DB calls
   Target pool ≈ L + headroom  →  ~12–15 connections
   ```
   Write your number and justify it.

### Expected Outputs / Findings
- p99 ≫ p50 and ≫ average — the tail is far worse than the typical request.
- Throughput plateaus while offered load keeps rising (the knee).
- **App CPU stays moderate; the DB connection pool saturates first.** The bottleneck is the DB connection layer, not app CPU.
- Adding pods would *increase* DB connections and make it worse (foreshadow Class 2).

### Validation Checklist
- [ ] k6 ran all stages and printed a percentile summary.
- [ ] Table filled with baseline and peak values.
- [ ] You can name the saturated resource and cite the metric that proves it.
- [ ] You produced a Little's-Law pool target with headroom.

### Troubleshooting Tips
- High `dropped_iterations` in k6 → the *generator* is the bottleneck; run k6 in-cluster.
- Flat, perfect latency at high load → load isn't reaching the app (check port-forward/Service).

### Cleanup
```bash
kill %1 2>/dev/null   # stop port-forward
# leave demo-app deployed for Class 2, OR:
# kubectl delete namespace perf-lab
```

### Reflection Questions
1. If you only had the *average* latency, what would you have concluded — and how would it have been wrong?
2. Why does adding app pods not raise throughput once the DB pool is saturated?
3. What would change in your k6 script to model a downstream caller with exactly 50 connections (closed model)?

### Optional Challenge
Add an OpenTelemetry trace to the demo app (or open the provided Jaeger UI), find a slow request by trace ID, and report which span owns most of the latency. Then run a CPU profile (`pprof`/Pyroscope) and confirm whether the time is *computing* or *waiting*.

---

## 14. Troubleshooting Activity

### Incident Title
**Checkout API latency spikes during peak — but CPU is fine**

### Business Impact
Checkout p99 latency went from 250 ms to 4 s during a promotion; ~5% of checkouts errored. Estimated lost revenue and abandoned carts make this a Sev-2.

### Symptoms
- Users report slow/failed checkout.
- p99 latency: 250 ms → 4 s (p50 only moved 180 ms → 260 ms).
- 5xx error rate: <1% → 5%.
- App pod CPU: 52% (barely moved).
- App memory: stable.

### Starting Evidence (give students this table)

| Metric | Normal | During incident |
|---|---:|---:|
| Request rate | 200 req/min | 900 req/min |
| Average latency | 180 ms | 1.8 s |
| p50 latency | 150 ms | 260 ms |
| p95 latency | 350 ms | 2.6 s |
| p99 latency | 600 ms | 4.0 s |
| App CPU | 45% | 52% |
| App memory | 60% | 62% |
| Pod replicas | 3 | 3 |
| DB CPU | 55% | 88% |
| **DB connections in use** | 60% | **98%** |
| 5xx errors | 0.2% | 4.8% |

### Student Investigation Steps (symptom → evidence → root cause → fix → validate)
1. **RED:** Rate up 4.5×, Errors up, Duration tail exploded — service is unhappy.
2. **USE per resource:** App CPU/mem flat → app compute is *not* saturated. DB connections at 98% → that resource is saturated.
3. **Hypothesis:** Connection-pool saturation; requests queue waiting for a free connection, so latency is *waiting time*, which is why CPU is low.
4. **Confirm with a trace:** the slow span is "acquire connection" / `db.query`, not app handler CPU.
5. **Little's Law check:** at 900 req/min ≈ 15 req/s and ~50 ms DB latency, in-flight `L ≈ 0.75`... but if each request makes several DB calls or the pool is mis-sized at, say, 5, the pool is the cap. Compute and compare to configured `max`.

### Expected Root Cause
Database **connection-pool saturation** driven by increased traffic (and likely an undersized pool / chatty queries). The DB connection layer is the bottleneck; CPU is a red herring.

### Correct Resolution
- Short term: shed/queue load gracefully (rate limit), reduce per-request DB calls, raise the pool *only* if the DB can take more connections (check DB `max_connections` first).
- Right-size the pool with Little's Law; add a connection-saturation alert.
- Long term: query tuning, caching repeated reads (Class 2), read replicas if read-heavy.
- **Do not** scale app pods first — more pods = more connections = worse.

### Common Wrong Paths
- "CPU is 52%, so add CPU / scale pods." (Worsens DB saturation.)
- "Average latency is 1.8 s, restart everything." (Misses the tail story and the real resource.)
- Raising the pool to a huge number without checking the DB's `max_connections`.

### Instructor Hints
- Point students at the *one* metric that moved to ~100% (DB connections).
- Ask: "Is the time being *spent* (CPU) or *waited* (queue)? Which tool shows which?"

### Preventive Action
- USE alert on pool saturation; load test before promotions; document a runbook; size pools with Little's Law in code review.

---

## 15. Scenario-Based Discussion Questions

1. **A service is slow but CPU is 40%. Give five distinct reasons.** *Themes:* connection/thread-pool exhaustion, lock contention, downstream/external latency, GC pauses, disk/network I/O wait. *Follow-up:* which tool confirms each?
2. **Your load test reports p99 = 300 ms but users complain. What's wrong with the test?** *Themes:* coordinated omission / closed model; test not at production concurrency; missing warm-up; testing a cached path. *Follow-up:* how would you switch to an open model?
3. **When is a high average latency acceptable but a high p99 not — and vice versa?** *Themes:* batch vs interactive; fan-out amplifying the tail; SLOs target percentiles for a reason.
4. **Should latency SLOs be averages or percentiles? Why?** *Themes:* averages hide tails; percentiles reflect user pain; Week 21 link.
5. **You can either cut p50 by 50% or cut p99 by 50%. Which matters more, and when?** *Themes:* user-perceived performance, fan-out, retries/timeouts triggered by the tail.
6. **Where would you put load generation in CI/CD?** *Themes:* k6 thresholds as gates, soak in pre-prod, non-prod environment parity, cost.
7. **A flame graph shows 40% of CPU in JSON serialization. What are your options?** *Themes:* fewer fields, faster codec, caching, pagination — fix the hot path, don't just scale.

---

## 16. Knowledge Check (with Answer Key)

1. **(MC)** Which best describes saturation? a) % of requests that fail b) requests per second c) how full/queued a resource is d) average response time. **→ c.** Saturation is queueing/fullness, distinct from utilization.
2. **(T/F)** The average latency is a reliable indicator of worst-case user experience. **→ False.** It hides the tail; use p95/p99.
3. **(MC)** RED stands for: a) Rate, Errors, Duration b) Requests, Errors, Disk c) Reliability, Efficiency, Durability. **→ a.**
4. **(MC)** USE stands for: a) Uptime, Saturation, Errors b) Utilization, Saturation, Errors c) Usage, Speed, Errors. **→ b.**
5. **(Short)** A service does 400 RPS at 25 ms latency. How many requests are in flight (Little's Law)? **→ L = 400 × 0.025 = 10.**
6. **(Short)** Define coordinated omission in one sentence. **→ A load test that waits for slow responses before issuing the next request under-measures latency because it skips the requests that would have queued during the stall.**
7. **(MC)** Open-model load generation means: a) source code is open b) arrivals occur at a fixed rate regardless of responses c) a fixed VU count loops. **→ b.**
8. **(T/F)** If app CPU is low, the app cannot be the cause of high latency. **→ False.** Low CPU + high latency usually means *waiting* (locks, pools, downstream, GC) — still inside the app's behavior.
9. **(Troubleshooting)** p99 spikes, p50 barely moves, CPU flat, DB connections at 99%. Most likely bottleneck? **→ DB connection-pool saturation.**
10. **(Troubleshooting)** Your k6 run shows rising `dropped_iterations` and offered RPS not being met, but the app looks idle. What's saturated? **→ The load generator (k6) itself — run it distributed/in-cluster.**
11. **(AWS)** Which CloudWatch metrics would you check to confirm a DB-connection bottleneck on RDS and ALB-side latency? **→ RDS `DatabaseConnections` (and `CPUUtilization`) and ALB `TargetResponseTime` / `HTTPCode_Target_5XX_Count`.**
12. **(AWS)** What AWS service gives per-request span-level latency attribution? **→ AWS X-Ray (or OpenTelemetry exporting to X-Ray/Tempo).**

---

## 17. Homework Assignment

### Title
**Load-test report + Performance Investigation Runbook**

### Scenario
Your team is preparing a service for a traffic spike. Leadership wants evidence it can handle peak, plus a reusable triage runbook.

### Student Tasks
1. Run the k6 ramp/steady/soak test against the demo app (or your capstone API) and capture the percentile summary.
2. Produce a short report: throughput vs offered-load curve, p50/p95/p99, the identified bottleneck (with the USE metric that proves it), and a Little's-Law pool/concurrency recommendation.
3. Write a one-page **Performance Investigation Runbook** using symptom → evidence → root-cause → fix → validate, covering: user-facing symptoms, RED signals, USE signals per resource, K8s checks (`kubectl top`, events, logs), DB checks, deployment-history check, immediate mitigations, and long-term fixes — and a section on **when scaling helps vs makes it worse.**

### Expected Deliverables
- `loadtest-report.md` (with the k6 summary pasted) + one curve diagram.
- `perf-runbook.md` (one page).

### Submission Format
Markdown in the course repo under `homework/week-22-class-01/`.

### Estimated Time
2–3 hours.

### Grading Criteria
- Correct percentile interpretation (not average-only) — 25%
- Bottleneck identified *with evidence* — 25%
- Little's-Law calculation correct — 20%
- Runbook follows the evidence-first methodology — 20%
- Clarity / reproducibility — 10%

### Optional Advanced Challenge
Add the k6 run to a GitHub Actions job using `thresholds` as pass/fail gates so a regression fails the build. Include the workflow YAML.

---

## 18. Common Student Mistakes

1. **Reading averages only.** Why: averages are intuitive. Fix: always pull p95/p99; teach the "10-latency list."
2. **Scaling pods before locating the bottleneck.** Why: scaling feels like action. Fix: USE first — find the saturated resource.
3. **Closed-model test → false confidence.** Why: default examples loop VUs. Fix: use `ramping-arrival-rate` (open model); watch for coordinated omission.
4. **No warm-up/soak.** Why: short tests are quick. Fix: include warm-up (pools/JIT/caches) and a soak (leaks).
5. **Sizing pools by guess.** Why: nobody taught the math. Fix: Little's Law + headroom.
6. **Confusing utilization with saturation.** Why: both feel like "busy." Fix: utilization = % busy; saturation = queue depth.
7. **Ignoring the load generator as a bottleneck.** Fix: watch `dropped_iterations`; run k6 in-cluster.

---

## 19. Real-World Enterprise Scenario

A retail platform team is 3 weeks from a Black-Friday-scale promotion. A *small* promo last month already pushed checkout p99 to 4 s while app CPU sat at 52%. The SRE on call resisted the reflex to scale pods, opened a trace, and saw the latency was in "acquire DB connection." Prometheus confirmed the RDS connection pool pinned at 98%. Using Little's Law against measured throughput, they found the pool was sized at 5 when ~20 were needed, and that a chatty endpoint made 6 DB round-trips per request. The fix: right-size the pool, batch the queries, add a connection-saturation alert, and **load-test with k6 in pre-prod before the real event** rather than discovering the knee in production. Constraints: changes go through change-management/approval, RDS `max_connections` caps how high the pool can go (so query reduction matters more than pool size), and cost rules out simply buying a bigger DB instance the week before peak.

---

## 20. Instructor Tips

- **Pacing:** the statistics block (10.2) is the highest-value 10 minutes — don't rush it. Cut the Azure/GCP table before cutting percentiles.
- **Lab support:** the most common blocker is port-forward dropping under load; have the in-cluster k6 Job manifest ready.
- **Struggling students:** give them the filled USE panels and just ask "which line hits 100% first?"
- **Advanced students:** point them at the tracing + flame-graph challenge and at coordinated omission in their own tests.

---

## 21. Student Outcome Checklist

**Can explain:** latency vs throughput vs saturation; why p99 ≠ average; RED vs USE; Little's Law; coordinated omission; open vs closed model.
**Can build/configure:** a k6 ramp/steady/soak test with thresholds; read p50/p95/p99 and throughput; read USE panels in Grafana.
**Can troubleshoot:** a high-latency/low-CPU incident to a saturated resource using evidence, and size a pool with Little's Law.

---

## 22. Class Completion Checklist

**Instructor before ending:** percentiles taught with the concrete example; RED/USE named; Little's Law computed on the board; k6 demo run live; bottleneck shown to be DB not CPU.
**Student before leaving:** ran k6, filled the metrics table, named the saturated resource with evidence, produced a pool target.
**Verify before Class 2:** demo app still deployed (or re-deployable), students understand "find the bottleneck before scaling" — the foundation for capacity planning and autoscaling in Class 2.

---

## Class Artifacts & Validation

The runnable artifacts this class uses live in [`labs/performance-scaling/`](../../labs/performance-scaling/) (the k6 load test and the autoscaling service whose CPU saturates under load) and in [`labs/sre-incident-response/`](../../labs/sre-incident-response/) (the k6 smoke test whose thresholds gate a build — the "load testing in CI" idea from §15/§17). The inline `loadtest.js`, demo-app, and HPA snippets above are *teaching excerpts*; the on-disk, validated versions are below.

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/performance-scaling/solution/load/load.js | k6 (JS) | Ramping load test (ramp → hold → ramp-down) with a `burn_duration p(95)<1500` threshold and checks — the on-disk version of the §12 `loadtest.js` | `k6 inspect solution/load/load.js` | PASS — reports 3 `stages` |
| 2 | labs/performance-scaling/solution/app/server.py | python | `/burn` CPU-burner service whose request rate maps to CPU utilisation (the "load → saturation" demo target) | `python3 -m py_compile solution/app/server.py` | PASS |
| 3 | labs/performance-scaling/solution/app/Dockerfile | docker | Non-root, pinned-base image for the burner | `hadolint solution/app/Dockerfile` | PASS — no findings |
| 4 | labs/performance-scaling/solution/k8s/hpa.yaml | kubernetes | HorizontalPodAutoscaler (CPU `Utilization` 50%, min 1 / max 5) — proves "throughput plateaus, resource saturates" under load | `kubeconform -strict -summary solution/k8s/{deployment,service,hpa,namespace}.yaml` | PASS — `Valid: 4` |
| 5 | labs/performance-scaling/broken/deployment-no-cpu-request.yaml | kubernetes | Reproducible broken state for the §14 troubleshooting activity: HPA `TARGETS <unknown>` because no CPU request → no saturation denominator | structural test asserts the fixture stays broken: `python3 -m unittest discover -s tests` | PASS — `OK` (12 tests) |
| 6 | labs/performance-scaling/LIVE-DEMO-EVIDENCE.txt | evidence | Captured live `kind` run: HPA scaled the Deployment **1 → 3 → 5** as CPU hit 108%/50% under k6 load, then scaled back in — the saturation knee, operated, not just described | `PERF_E2E=1 ./validate.sh` (or `./solution/run-demo.sh`) | PASS — see labs/performance-scaling/LIVE-DEMO-EVIDENCE.txt |
| 7 | labs/sre-incident-response/solution/load/k6-smoke.js | k6 (JS) | Smoke test whose `p(95)<300` / `http_req_failed rate<0.001` thresholds mirror an SLO so a too-slow service fails the build (the §15/§17 "k6 in CI" answer) | `python3 tests/check_k6_balance.py solution/load/k6-smoke.js` (and real `k6 run` in `validate.sh` Gate 7) | PASS — brackets balanced, constructs present; live `k6 run` p(95)≈48ms exit 0 (see lab README) |

All commands run from the respective lab root (`labs/performance-scaling/` or `labs/sre-incident-response/`). The live e2e scaling gate (#6) is deferred by default in `./validate.sh` because it is a ~3-min demo; its committed transcript is checked on every run.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — k6 (`load.js`, `k6-smoke.js`), the burner service (`server.py`), the HPA and Deployment manifests; no class-only fences are the sole artifact.
- [x] Each artifact passes (or documents) its **validation gate** — `k6 inspect`, `py_compile`, `hadolint`, `kubeconform`, structural unit tests, and the k6 bracket check all PASS (captured above); the live scaling demo is captured in `LIVE-DEMO-EVIDENCE.txt`.
- [x] Lab has **starter** (intentionally incomplete: HPA + k6 stages TODO'd) and **solution** (reference) versions — `labs/performance-scaling/{starter,solution}`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — see `labs/performance-scaling/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — `run-demo.sh` tears down `ns/lab-perf` + metrics-server on exit (even Ctrl-C); manual idempotent commands documented.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — README "Instructor answer key" + §16 answer key + §14 expected root cause.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/deployment-no-cpu-request.yaml` reproduces `TARGETS <unknown>`; a structural test asserts it stays broken.
- [x] **Expected outputs** are shown for demos and labs — §12 expected k6 summary and the `LIVE-DEMO-EVIDENCE.txt` transcript (REPLICAS 1→5, p95=690ms).
- [x] **Cost & security warnings** present — README cost ($0 local kind) and security (non-root pod, `--kubelet-insecure-tls` is dev-only) notes; §3 cost/security note on never load-testing prod.
- [x] **Cross-references** to the module repo and prior/next weeks are correct — §1 links Weeks 10–13, 16, 21, and Class 2 / Capstone.
- [x] The **artifact manifest** (§4.2) is present and every path resolves — verified with `ls`; all seven paths exist.
