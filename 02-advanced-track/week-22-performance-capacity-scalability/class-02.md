# Week 22: Performance, Capacity, and Scalability
> **▶ Runnable lab for this class:** [`labs/performance-scaling/`](../../labs/performance-scaling/) · [`labs/sre-incident-response/`](../../labs/sre-incident-response/)
>
> These are the **on-disk, validated** versions of the code shown inline below — not just fenced snippets. Clone the module, do the lab in `starter/` (complete the `TODO(student)` gaps), check yourself against `solution/`, then run `./validate.sh`. Each module README has prerequisites, architecture, expected outputs, troubleshooting, cleanup, security, and cost notes.

## Class 2: Capacity Planning and Scaling Production Systems

**Course:** Enterprise DevOps, Cloud Engineering, and Site Reliability Engineering Program
**Track:** Unified DevOps · Cloud · SRE Track
**Week:** 22
**Class:** 2 of 2
**Duration:** 3 hours
**Primary Cloud:** AWS
**Secondary Cloud Exposure:** Azure and GCP
**Audience:** Intermediate learners preparing for DevOps Engineer, Cloud Engineer, and Site Reliability Engineer roles

---

## 1. Class Overview

### Class Title

**Capacity Planning and Scaling Production Systems**

### Class Purpose

Class 1 taught students to *measure* performance and *locate* the bottleneck. Class 2 teaches what to do about it: **capacity planning** (how much headroom you need and how to forecast it) and **scaling** (the actual Kubernetes and AWS mechanisms — HPA, VPA, Cluster Autoscaler vs Karpenter, KEDA — plus the architecture patterns that make a system scalable: caching, read replicas, sharding, queues/backpressure, circuit breakers, and retries with jitter).

The week's thesis carries straight through:

> **Scaling is not the first step. Understanding the bottleneck is the first step — and some bottlenecks (a saturated database) get *worse* when you scale the layer in front of them.**

This class is deliberately hands-on. Students deploy a **working HPA** (with metrics-server), see a **VPA recommendation**, compare **Cluster Autoscaler and Karpenter** for node capacity, wire a **KEDA ScaledObject** to a queue, and run the Class-1 k6 test to *validate* a capacity plan instead of guessing.

### How This Class Builds From Class 1
- Reuses the k6 load test, the demo app, and the RED/USE + Little's-Law framing from Class 1.
- The "high latency, low CPU, DB saturated" lesson becomes the cornerstone of *why autoscaling alone can make things worse*.
- Class 1 found the knee; Class 2 plans capacity to stay left of it with headroom.

### What Students Will Build, Analyze, or Practice
- A deployed `HorizontalPodAutoscaler` (CPU + custom request-rate metric) and a `VerticalPodAutoscaler` in recommendation mode.
- A comparison of **Cluster Autoscaler vs Karpenter** for node provisioning, and a **KEDA ScaledObject** scaling a worker on SQS/queue depth.
- A **caching design** (CloudFront CDN + ElastiCache/Redis cache-aside) and **scalability patterns** (read replicas, sharding, queue-based load leveling, circuit breaker, retry-with-jitter).
- A **capacity plan** with headroom math and cost-aware scaling, **validated by a load test**.

---

## 2. Quick Review of Class 1

**Review points**
1. Latency (per request), throughput (per second), saturation (queue depth) are distinct.
2. p99 ≠ average; the tail is what users feel; SLOs use percentiles.
3. RED (Rate/Errors/Duration) per service; USE (Utilization/Saturation/Errors) per resource.
4. Little's Law: `L = λ × W` sizes pools and explains the saturation knee.
5. Locate the bottleneck with dashboards → traces → flame graphs before acting.
6. A DB-connection bottleneck shows as high latency with *low* app CPU.

**Quick recall questions**
1. Why can a service be slow when CPU is only 40%?
2. What does Little's Law compute, and what does it size?
3. Which method (RED or USE) finds the symptom, and which finds the cause?

**Common gaps to bridge:** students may still equate "scale" with "add pods." Reinforce that scaling the app in front of a saturated DB *adds connections* and worsens it — the bridge into HPA/VPA/KEDA and architecture patterns.

---

## 3. Class Learning Objectives

By the end of this class, students will be able to:

1. **Compare** vertical, horizontal, manual, scheduled, dynamic, and predictive scaling.
2. **Deploy and configure** a working HPA (CPU and custom/external metrics) and explain the metrics-server requirement and the HPA-target-vs-request relationship.
3. **Explain and apply** VPA (recommendation vs auto) and PodDisruptionBudgets.
4. **Compare** Cluster Autoscaler and Karpenter for node scaling and choose appropriately.
5. **Configure** event/queue-driven scaling with KEDA (e.g., SQS depth) using the external-metrics API.
6. **Design** a caching layer (CDN + cache-aside Redis) and **select** scalability patterns (read replicas, sharding, queue-based load leveling, backpressure, circuit breakers, retries with jitter).
7. **Produce** a capacity plan with headroom/forecast math and cost-aware scaling, **validated** by a load test.
8. **Troubleshoot** a scaling incident where autoscaling shifts pressure to a downstream bottleneck.

---

## 4. Prerequisites Students Should Already Know

- Class 1: percentiles, RED/USE, Little's Law, the k6 lab, the demo app.
- Kubernetes Deployments/Services and `kubectl` (Week 11); Helm (Week 13).
- Prometheus/Grafana (Week 16); cost basics & right-sizing (Week 18).
- **Tools installed:** `kubectl`, `helm`, `k6`, AWS CLI v2 (via SSO). For the full autoscaling labs: a cluster with `metrics-server`; optionally Karpenter and KEDA installed (instructor-provided on the shared EKS dev cluster).
- **Files/repos:** the Week 22 lab repo (demo app, HPA/VPA/KEDA manifests, k6 scripts) from Class 1.

> **Cost & security note:** HPA/VPA/metrics-server and KEDA run on a **local cluster for free**. Karpenter and the SQS/KEDA path require AWS (EKS + SQS). EKS control plane and EC2 node-hours **cost money** — use the shared dev cluster, prefer Spot for worker nodes, and **follow the cleanup steps in Section 23**. Scope IAM via IRSA/OIDC (keyless); never attach broad admin to autoscalers.

---

## 5. Key Terms and Definitions

| Term | Definition | Real-world context |
|---|---|---|
| **HPA** | Horizontal Pod Autoscaler — adds/removes *pod replicas* based on metrics. | Scale `demo-api` 3→10 when CPU or RPS rises. |
| **VPA** | Vertical Pod Autoscaler — recommends/sets *requests & limits* per pod. | "This pod needs 250m CPU / 512Mi, not 1 CPU / 2Gi." |
| **metrics-server** | Cluster component that serves pod/node CPU/memory to HPA/`kubectl top`. | HPA on CPU does nothing without it. |
| **Cluster Autoscaler** | Adds/removes *nodes* by changing Auto Scaling Group desired count when pods are unschedulable. | Node-group-based, mature, slower. |
| **Karpenter** | AWS open-source node autoscaler that provisions right-sized EC2 directly (no node groups), fast, Spot-aware. | 2026 default for EKS node scaling. |
| **KEDA** | Kubernetes Event-Driven Autoscaling — scales (incl. to zero) on external signals via the external-metrics API. | Scale workers on SQS queue depth or Kafka lag. |
| **Headroom** | Spare capacity kept above expected peak as a safety buffer. | Run peak at ~60–70% so a node failure or spike is survivable. |
| **Forecast** | Projected future demand (linear/seasonal/event-driven). | "+30% YoY plus a 2× holiday spike." |
| **Cache-aside** | App checks cache; on miss, reads DB and populates cache. | Most common Redis/ElastiCache read pattern. |
| **Read replica** | Read-only DB copy; offloads reads from the primary. | RDS read replica for a read-heavy catalog. |
| **Sharding** | Partition data across DBs by a key so each holds a slice. | Shard orders by `customer_id`. |
| **Queue-based load leveling** | Put a queue between producer and consumer so spikes don't overload the backend. | SQS in front of workers; consumers pull at a safe rate. |
| **Backpressure** | Signaling/refusing work when downstream is full, instead of collapsing. | Bounded queues, 429s, load shedding. |
| **Circuit breaker** | Stop calling a failing dependency for a cooldown to let it recover. | Open the breaker after N failures; serve a fallback. |
| **Retry with jitter** | Retry failed calls with exponential backoff plus randomness to avoid synchronized retry storms. | `sleep = min(cap, base*2^attempt) ± random`. |
| **PodDisruptionBudget (PDB)** | Limits how many pods can be voluntarily evicted at once. | Keep ≥2 replicas available during node scale-down/upgrades. |
| **Predictive / scheduled scaling** | Scale ahead of known/forecast demand instead of reacting. | Pre-scale before a 9 AM spike or a known sale. |

---

## 6. Tools Used

| Tool | Why |
|---|---|
| **kubectl + metrics-server** | Deploy/inspect HPA/VPA; `kubectl top`. |
| **HPA / VPA** | Pod-level horizontal and vertical scaling. |
| **Cluster Autoscaler / Karpenter** | Node-level capacity. |
| **KEDA** | Event/queue-driven and scale-to-zero. |
| **Helm** | Install Karpenter/KEDA/metrics-server. |
| **k6** | Validate the capacity plan under load (from Class 1). |
| **Prometheus/Grafana** | Observe scaling behavior and second-order effects. |
| **Redis/ElastiCache, CloudFront** | Caching layers. |

---

## 7. AWS Services Used

| AWS Service | Connection to this class |
|---|---|
| **Amazon EKS** | Where HPA/VPA/Karpenter/KEDA run. |
| **EC2 Auto Scaling / Karpenter** | Node capacity behind pod scaling. |
| **Amazon SQS** | Queue-depth signal for KEDA / queue-based load leveling. |
| **Amazon RDS (+ read replicas)** | DB scaling: vertical, replicas, storage autoscaling. |
| **Amazon ElastiCache (Redis)** | Cache-aside layer to offload the DB. |
| **Amazon CloudFront** | CDN edge caching for static/cacheable responses. |
| **CloudWatch (+ Container Insights)** | Metrics/alarms for scaling decisions and validation. |
| **IAM Identity Center / IRSA (OIDC)** | Keyless, least-privilege access for Karpenter/KEDA. |

---

## 8. Azure and GCP Comparison Notes

| AWS | Azure | GCP |
|---|---|---|
| EC2 Auto Scaling / Karpenter | VM Scale Sets / AKS node autoprovision | Managed Instance Groups / GKE node auto-provisioning |
| EKS HPA / VPA | AKS HPA / VPA | GKE HPA / VPA |
| KEDA on EKS | KEDA on AKS (native add-on) | KEDA on GKE |
| SQS | Service Bus / Queue Storage | Pub/Sub |
| ElastiCache | Azure Cache for Redis | Memorystore |
| CloudFront | Azure Front Door / CDN | Cloud CDN |
| RDS read replicas | Azure SQL read replicas | Cloud SQL read replicas |

KEDA is cross-cloud, which is part of why it's the standard event-driven scaler. Keep AWS primary.

---

## 9. Time-Boxed Instructor Agenda

| Time | Topic |
|---:|---|
| 0:00 – 0:15 | Review Class 1; "holiday traffic doubles" scenario |
| 0:15 – 0:40 | Scaling taxonomy; pod scaling (HPA) + the metrics-server/requests relationship; VPA |
| 0:40 – 1:05 | Node scaling: Cluster Autoscaler vs Karpenter; PDBs |
| 1:05 – 1:30 | Event-driven scaling with KEDA (SQS); scale-to-zero |
| 1:30 – 1:45 | **Break** |
| 1:45 – 2:10 | Caching (CDN + cache-aside Redis) and scalability patterns (replicas, sharding, queues, circuit breaker, retry+jitter) |
| 2:10 – 2:25 | Capacity-planning math: headroom, forecast, cost-aware scaling (Spot/right-sizing, ties to W18) |
| 2:25 – 2:50 | Lab: deploy HPA, load-test it, watch second-order effects, write the capacity plan |
| 2:50 – 3:00 | Troubleshooting recap, homework, end-of-week summary |

---

## 10. Instructor Lesson Plan

1. **Review + scenario (15 min).** Recap Class 1; present the holiday scenario (Section 11.1). Ask "can we handle 2×?" — answer with evidence, not vibes.
2. **Pod scaling (25 min).** Walk the HPA manifest; stress the **target-utilization vs request** relationship (HPA % is measured against the *request*, so wrong requests = wrong scaling). Show VPA recommendation mode and why HPA+VPA on the *same* CPU metric conflict.
3. **Node scaling (25 min).** Pods can't schedule if no node has room. Compare Cluster Autoscaler (ASG-based, node groups) vs Karpenter (provisions right-sized EC2 directly, Spot-aware, fast). Add PDBs so scale-down/upgrade doesn't break availability.
4. **KEDA (25 min).** For workers, CPU is the wrong signal; queue depth is right. Show the ScaledObject on SQS and scale-to-zero. This is the answer to Class-1's "request count beats CPU."
5. **Break (15 min).**
6. **Caching + patterns (25 min).** Cache-aside with Redis, CDN at the edge, stampede protection. Then the pattern menu: read replicas, sharding, queue-based load leveling/backpressure, circuit breaker, retry+jitter. These are system-design-interview core.
7. **Capacity math (15 min).** Headroom %, forecast, and **cost-aware** scaling (Spot, right-sizing, scale-to-zero) — connect to Week 18 FinOps.
8. **Lab (25 min).** Deploy HPA, run the k6 test, watch it scale, watch the DB saturate (second-order effect), write the plan.
9. **Recap (10 min).** Troubleshooting activity, homework, end-of-week summary.

---

## 11. Instructor Lecture Notes

### 11.1 The scenario (carry it through the class)
A retail app expects holiday traffic to roughly double: now 500 req/min, peak target 1,000+; 3 pods at 65% CPU; p95 700 ms; RDS CPU 70%, connections 75%. The question "can we handle 2×?" forces students to scale *the right layer*, not reflexively add pods into an already-stressed DB.

### 11.2 Scaling taxonomy
Vertical (bigger pod/instance), horizontal (more replicas), manual, scheduled (known time patterns), dynamic (metric-driven), predictive (forecast-driven). Horizontal is the default for stateless services; vertical/right-sizing fixes wrong requests; scheduled/predictive front-runs known spikes (holiday, 9 AM).

### 11.3 HPA — and the part everyone gets wrong
HPA changes **replica count** to keep a metric near a target. **The CPU target is a percentage of the pod's CPU _request_, not of the node.** If your request is wildly wrong, HPA scales wrongly — this is the bridge to VPA. Requirements: `metrics-server` for CPU/memory; Prometheus Adapter or KEDA for custom/external metrics. HPA needs a `resources.requests.cpu` on the Deployment or CPU-based HPA can't compute a ratio.

> "HPA without correct requests is a thermostat reading the wrong thermometer."

### 11.4 VPA
VPA recommends (or sets) requests/limits from observed usage. Run it in **`Off`/recommendation mode** first to *learn* the right requests, then feed those into HPA. **Don't run VPA in `Auto` and HPA on CPU for the same workload** — they fight (VPA changes the denominator HPA divides by). Common pattern: VPA for right-sizing requests, HPA on RPS/custom metric.

### 11.5 Node scaling: Cluster Autoscaler vs Karpenter
HPA can ask for 20 pods, but if no node has room they sit `Pending`. Node autoscalers fix that:
- **Cluster Autoscaler:** scales pre-defined node groups (ASGs). Mature, predictable, but you must define instance types up front and it can be slow.
- **Karpenter (2026 default on EKS):** watches `Pending` pods and provisions *right-sized* EC2 instances directly from a `NodePool`/`EC2NodeClass`, bin-packs aggressively, consolidates underused nodes, and is Spot-native — usually faster and cheaper.

Add a **PodDisruptionBudget** so consolidation/upgrades don't evict too many replicas at once.

### 11.6 KEDA — event/queue-driven scaling
For a queue worker, scaling on CPU is wrong: a backlog can build with low CPU. KEDA scales on the **backlog itself** (SQS `ApproximateNumberOfMessages`, Kafka lag, etc.) via the external-metrics API, and can **scale to zero** when the queue is empty (cost win). This is exactly the "request count / queue depth beats CPU" idea from Class 1, made real.

### 11.7 Caching (named-but-absent in the old class — now taught)
- **CDN (CloudFront):** cache cacheable responses at the edge; cuts latency and origin load dramatically. Set sane `Cache-Control`/TTLs.
- **Cache-aside (Redis/ElastiCache):** app reads cache → on miss reads DB and populates cache → returns. Offloads read-heavy DBs (our Class-1 bottleneck!).
- **Pitfalls:** invalidation ("there are only two hard problems…"), and **cache stampede** — when a hot key expires and thousands of requests hit the DB at once. Mitigate with TTL jitter, request coalescing/locks, or `stale-while-revalidate`.

### 11.8 Scalability patterns (system-design core)
- **Read replicas:** offload reads; mind **replication lag** (a just-written value may not be on the replica yet).
- **Sharding:** partition by key for write scaling; adds rebalancing/cross-shard-query complexity.
- **Queue-based load leveling + backpressure:** absorb spikes in a queue; bound it and shed/429 when full so the spike never reaches the DB.
- **Circuit breaker:** after N failures to a dependency, "open" and fail fast (with a fallback) for a cooldown so you don't pile onto a struggling service.
- **Timeouts + retries with jitter:** every remote call needs a timeout; retries need exponential backoff **plus jitter** or synchronized retries become a self-inflicted DDoS. Add **bulkheads** (isolate pools per dependency) so one slow dependency can't exhaust all threads.

> "Autoscaling adds capacity. Patterns keep a failure in one place from becoming an outage everywhere."

### 11.9 Capacity math + cost-aware scaling
- **Headroom:** run peak at ~60–70% of capacity so a node loss or spike doesn't tip you over the knee (Class 1). Replica target ≈ `ceil(peak_load / per_pod_safe_capacity / target_utilization)`.
- **Forecast:** baseline × growth × spike factor; pick the worst plausible.
- **Cost-aware (Week 18 link):** prefer **Spot** for stateless/interruptible work (Karpenter does this well), **right-size** requests with VPA, **scale to zero** with KEDA off-hours, and remember **scaling the app into a maxed DB just spends money to make latency worse.**

---

## 12. Whiteboard Explanation

### Topic: The full scaling stack (extends Class 1's request path)

```text
                        ┌──────────── KEDA (queue depth / events) ───────────┐
                        │                                                     ▼
 Users ─► CloudFront(CDN cache) ─► ALB ─► [ HPA: pods 3..N ] demo-api ─► Redis(cache-aside) ─► RDS primary
                                              ▲    │                                              │
                                              │    └─ VPA right-sizes requests          read replicas ◄┘ (offload reads)
                              Karpenter/Cluster Autoscaler                                SQS ─► workers (KEDA, scale-to-zero)
                              add NODES when pods are Pending                             circuit breaker + retry/jitter on
                              (PDB protects availability)                                 every cross-service call
```

**Flow:** CDN absorbs cacheable traffic at the edge → ALB → HPA scales pods (VPA keeps requests honest) → app hits Redis first, DB on miss → reads go to replicas, writes to primary → spiky/async work goes through SQS to KEDA-scaled workers (scale to zero when idle). When pods can't fit, Karpenter/CA add nodes; PDBs keep enough replicas during churn. Circuit breakers + retries-with-jitter stop a slow dependency from cascading.

**Enterprise version:** add Prometheus/Grafana on every box (USE), OTel traces end-to-end, IRSA-scoped IAM for Karpenter/KEDA, and Spot node pools for cost.

---

## 13. Instructor Demo Script

### Demo Title
**Deploy a real HPA, drive it with k6, and watch the second-order effect**

### Demo Objective
Show a working HPA scaling pods under load, then show that scaling the app pushes the *DB* to saturation — proving "autoscaling is not a reliability strategy by itself."

### Required Setup
- Cluster from Class 1 with the demo app; `metrics-server` installed.
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl -n kube-system rollout status deploy/metrics-server
  ```

### Step 1 — Deploy the HPA (CPU-based, correct requests)

`hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-api
  namespace: perf-lab
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60   # 60% of the pod's CPU *request*
  behavior:                         # 2026: tune scale up/down to avoid flapping
    scaleUp:
      stabilizationWindowSeconds: 0
      policies: [{ type: Percent, value: 100, periodSeconds: 30 }]
    scaleDown:
      stabilizationWindowSeconds: 120
      policies: [{ type: Percent, value: 50, periodSeconds: 60 }]
```

The Deployment must declare requests (or CPU HPA can't compute a ratio):
```yaml
        resources:
          requests: { cpu: "250m", memory: "256Mi" }
          limits:   { cpu: "500m", memory: "512Mi" }
```

Apply and watch:
```bash
kubectl -n perf-lab apply -f hpa.yaml
kubectl -n perf-lab get hpa demo-api -w
```

Expected (idle):
```text
NAME       REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS
demo-api   Deployment/demo-api   8%/60%    3         10        3
```

### Step 2 — Drive load with k6 (from Class 1)
```bash
k6 run loadtest.js
```
Watch HPA climb:
```text
demo-api   Deployment/demo-api   142%/60%   3   10   3   →   7   →   10
```

### Step 3 — Show the second-order effect in Grafana
- Pods scale 3→10, **app CPU drops** (load spread out) — HPA "worked."
- **But** RDS `connections` hit 100% and p99 *stays* bad: 10 pods × pool size = far more DB connections. **This is the Class-1 bottleneck, made worse by scaling.**

### Step 4 — Custom-metric HPA (request rate, the better signal)
```yaml
  metrics:
    - type: Pods
      pods:
        metric: { name: http_requests_per_second }
        target: { type: AverageValue, averageValue: "50" }   # via Prometheus Adapter/KEDA
```
Explain: RPS-based scaling reacts before CPU does and matches user demand (Class-1 RED).

### Step 5 — Event-driven scaling with KEDA (SQS depth, scale-to-zero)

For an async worker, CPU is the wrong signal — a backlog builds at low CPU. KEDA scales on the **queue depth** itself and can scale **to zero** when the queue is empty.

First, a `TriggerAuthentication` that uses **IRSA** (keyless OIDC) so the worker's ServiceAccount carries `sqs:GetQueueAttributes`/`sqs:ReceiveMessage` — never static keys:

`keda-sqs.yaml`:
```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: keda-sqs-auth
  namespace: perf-lab
spec:
  podIdentity:
    provider: aws            # KEDA reads the IRSA-assumed role from the workload's ServiceAccount
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: order-worker
  namespace: perf-lab
spec:
  scaleTargetRef:
    name: order-worker            # the worker Deployment
  minReplicaCount: 0              # scale-to-zero when the queue is empty (cost win)
  maxReplicaCount: 20
  cooldownPeriod: 120            # wait 120s of no events before scaling back to zero
  pollingInterval: 15            # how often KEDA checks the queue
  triggers:
    - type: aws-sqs-queue
      authenticationRef:
        name: keda-sqs-auth
      metadata:
        queueURL: https://sqs.us-east-1.amazonaws.com/123456789012/order-events
        awsRegion: us-east-1
        queueLength: "10"        # target backlog per replica: aim for ~10 in-flight messages each
```

How it works: KEDA reads SQS `ApproximateNumberOfMessages` via the external-metrics API and creates/manages an HPA under the hood. With `queueLength: "10"`, a backlog of 200 messages targets ~20 replicas (capped at `maxReplicaCount`); an empty queue scales the worker to **zero** after `cooldownPeriod`.

> The worker's ServiceAccount must be annotated with the IRSA role ARN (`eks.amazonaws.com/role-arn`); scope that role to *only* the one queue's ARN — never broad `sqs:*` on `*`.

Apply and watch:
```bash
kubectl -n perf-lab apply -f keda-sqs.yaml
kubectl -n perf-lab get scaledobject order-worker
kubectl -n perf-lab get hpa -w        # KEDA-managed HPA: keda-hpa-order-worker
```

Drive the queue and watch workers appear, then drain to zero:
```bash
for i in $(seq 1 200); do
  aws sqs send-message --queue-url "$QUEUE_URL" --message-body "order-$i" >/dev/null
done
# replicas climb toward maxReplicaCount; once drained and past cooldownPeriod, scale to 0
```

### Common Failure Points & Recovery
- HPA shows `TARGETS <unknown>` → metrics-server missing or no `requests` set. Fix both.
- HPA scales but pods stay `Pending` → no node capacity → this is the node-autoscaler (Karpenter/CA) story; on local clusters note it and move on.

### Cleanup
```bash
kubectl -n perf-lab delete -f hpa.yaml
kubectl -n perf-lab delete -f keda-sqs.yaml 2>/dev/null   # if you ran the KEDA step
```

---

## 14. Student Lab Manual

### Lab Title
**Holiday-traffic capacity lab: real manifests + load test + plan**

### Lab Objective
Deploy autoscaling, validate it under load with k6, observe the second-order DB effect, and write an evidence-based, cost-aware capacity plan for 2× holiday traffic.

### Estimated Time
40 minutes

### Student Prerequisites
- Demo app + `metrics-server` deployed; `hpa.yaml` from the demo; `loadtest.js` from Class 1.

### Starting Point From Class 1
Reuse the same demo app and k6 script. You already know the DB connection pool is the bottleneck — now plan around it.

### Architecture Overview
See the Section 12 whiteboard: HPA on the app, DB behind it, k6 generating open-model load.

### Step-by-Step Instructions
1. Deploy HPA and confirm baseline:
   ```bash
   kubectl -n perf-lab apply -f hpa.yaml
   kubectl -n perf-lab get hpa demo-api
   ```
2. Run the k6 ramp/steady/soak test:
   ```bash
   k6 run loadtest.js
   ```
3. Record scaling + impact:

   | Metric | Before load | At peak |
   |---|---:|---:|
   | Pod replicas | 3 | |
   | App CPU (avg) | | |
   | Throughput (req/s) | | |
   | p95 / p99 latency | | |
   | DB connections in use / max | | |
   | Error rate | | |

4. **Headroom math:** from your measured *safe* per-pod throughput, compute replicas needed for 2× peak at 60% target utilization:
   ```text
   replicas = ceil( peak_RPS / per_pod_safe_RPS / 0.60 )
   ```
5. **Decide the real fix.** Given the DB saturates, write which of these you'd apply *before* raising `maxReplicas`, and why: add Redis cache-aside, add a read replica, reduce per-request DB calls, right-size the pool (Little's Law), add KEDA for async work, move static assets to CloudFront.
6. **Cost-aware note:** state how you'd keep this affordable (Spot via Karpenter, scale-to-zero workers via KEDA, right-size requests via VPA).
7. Write a **one-page capacity plan** (baseline, forecast, risks, scaling actions, caching/pattern actions, monitoring/alerts, cost tradeoff, leadership recommendation).

### Expected Outputs / Findings
- HPA scales pods up; app CPU falls; **DB connections saturate and p99 stays bad** — scaling the app alone fails.
- The correct plan caps app replicas, **fixes the DB layer (cache/replica/pool)**, and validates with a load test before the event.

### Validation Checklist
- [ ] HPA deployed and observed scaling under load.
- [ ] Metrics table filled; second-order DB effect captured.
- [ ] Headroom replica count computed.
- [ ] Plan addresses the DB bottleneck, not just pod count.
- [ ] Cost-aware option included.

### Troubleshooting Tips
- `TARGETS <unknown>` → metrics-server / missing requests.
- HPA never scales → load not reaching pods, or target set too high.

### Cleanup
```bash
kubectl -n perf-lab delete -f hpa.yaml
# Full teardown (also see Section 23):
# kubectl delete namespace perf-lab
```

### Reflection Questions
1. HPA "worked" but latency didn't improve — what does that prove about autoscaling?
2. Why is request-rate (or queue depth) often a better HPA signal than CPU?
3. Where would a circuit breaker have helped during this incident?

### Optional Challenge
Add a **KEDA ScaledObject** that scales a worker Deployment on SQS depth and scales to zero when empty (use the `keda-sqs.yaml` manifest from the Section 13 demo, Step 5, and the repo). Drive the queue and watch workers appear/disappear.

---

## 15. Troubleshooting Activity

### Incident Title
**Autoscaling did not prevent peak-time latency**

### Business Impact
During the promo, checkout stayed slow despite autoscaling; ~5% error rate, abandoned carts, Sev-2.

### Symptoms
- HPA scaled pods 3 → 10 (worked technically).
- Latency still high; error rate up.
- **DB CPU 95%, DB connections at max.**
- App CPU *dropped* after scaling.

### Starting Evidence
`kubectl get hpa` shows `10/10` replicas. Grafana: app CPU 40%, RDS connections 100%, p99 4 s. Trace: latency in "acquire connection" / `db.query`.

### Student Investigation Steps
1. **Did HPA work?** Yes — replicas scaled, app CPU fell. So the app isn't the constraint.
2. **What saturated?** DB connections at 100% (USE saturation) — the new bottleneck.
3. **Why did scaling worsen it?** 10 pods × pool size = far more DB connections than the DB can serve. Little's Law: more concurrency than the DB can absorb → queueing → latency.
4. **What should've been tested?** A load test at projected peak *with HPA enabled* in pre-prod (Class 1) would have surfaced this knee.

### Expected Root Cause
Autoscaling shifted pressure downstream: the DB was not sized/tuned/offloaded for the connection count that scaled pods produce.

### Correct Resolution
- Cap `maxReplicas` to what the DB can support; size the pool with Little's Law.
- **Offload the DB:** Redis cache-aside for hot reads, read replicas for read-heavy traffic, reduce per-request queries.
- Move async work behind **SQS + KEDA** so it doesn't compete for DB connections at peak.
- Add **circuit breaker + retry-with-jitter** so a slow DB doesn't cause retry storms.
- Add DB connection/latency alerts; load-test before the next event.

### Common Wrong Paths
- Raise `maxReplicas` further (more connections, worse DB).
- Raise the DB pool blindly past `max_connections`.
- Treat autoscaling as the whole reliability plan.

### Instructor Hints
- "Which resource went to 100% *after* scaling?" → DB connections.
- "If the app got *less* busy, is the app the problem?"

### Preventive Action
- Capacity plan includes the DB; pre-prod load test with autoscaling on; caching + replicas; saturation alerts; documented runbook.

---

## 16. Scenario-Based Discussion Questions

1. **Should every service use HPA? Why/why not?** *Themes:* great for variable stateless load; useless for the real bottleneck; stateful services need care; cost; needs correct requests + load testing.
2. **CPU vs request-rate vs queue-depth as a scaling metric — when each?** *Themes:* CPU for CPU-bound; RPS for latency-sensitive APIs (RED); queue depth/KEDA for async workers.
3. **Cluster Autoscaler or Karpenter for a new EKS platform in 2026? Why?** *Themes:* Karpenter for speed/right-sizing/Spot/consolidation; CA where node-group constraints or other clouds matter.
4. **Cache-aside vs read replica vs sharding — pick for a read-heavy catalog with a hot subset.** *Themes:* cache-aside first (cheap, biggest win), replicas for breadth, sharding only when writes/data size force it.
5. **Why add a circuit breaker if you already have autoscaling?** *Themes:* autoscaling adds capacity; breakers contain failure; different problems.
6. **How do you make scaling cost-aware without hurting reliability?** *Themes:* Spot for stateless, right-size with VPA, scale-to-zero off-hours, headroom for failure (W18).
7. **What must exist before enabling autoscaling in prod?** *Themes:* correct requests, metrics-server/adapter, PDBs, max caps, downstream capacity, alerts, a load test.

---

## 17. Knowledge Check (with Answer Key)

1. **(MC)** HPA's CPU target percentage is measured against: a) node CPU b) the pod's CPU *request* c) the pod's limit. **→ b.**
2. **(T/F)** HPA on CPU works without metrics-server. **→ False.**
3. **(MC)** Which scales *nodes* by provisioning right-sized EC2 directly and is Spot-native? a) HPA b) VPA c) Karpenter d) metrics-server. **→ c.**
4. **(MC)** Best tool to scale a worker on SQS depth (incl. to zero)? a) VPA b) KEDA c) Cluster Autoscaler. **→ b.**
5. **(Short)** Why shouldn't VPA(`Auto`) and CPU-based HPA target the same workload? **→ VPA changes the CPU request that HPA divides by, so they fight.**
6. **(Short)** Name the cache pattern: app reads cache, on miss reads DB and populates it. **→ Cache-aside.**
7. **(MC)** Retries without jitter risk: a) lower latency b) synchronized retry storms c) cache stampede. **→ b.**
8. **(T/F)** Adding read replicas can return stale reads due to replication lag. **→ True.**
9. **(Troubleshooting)** HPA scaled 3→10, app CPU fell, latency still bad, DB connections 100%. Root cause? **→ Scaling shifted load to a saturated DB connection layer.** Fix: cache/replicas/right-size pool/cap replicas, not more pods.
10. **(Troubleshooting)** HPA shows `TARGETS <unknown>` and won't scale. Two likely causes? **→ metrics-server not installed; Deployment has no `resources.requests`.**
11. **(AWS)** Which AWS service is the queue-depth signal for KEDA in this week? **→ Amazon SQS** (`ApproximateNumberOfMessages`).
12. **(C1↔C2)** How does Little's Law (Class 1) inform `maxReplicas` and pool size here? **→ It bounds in-flight concurrency the DB can absorb (`L=λ×W`), so it sets a safe pool and caps how many pods (×pool) the DB can serve.**

---

## 18. Homework Assignment

### Title
**Capacity & Scaling Plan for a Growing Application (validated)**

### Scenario
Your service faces a 2× holiday spike. Leadership needs a plan that won't melt the database and won't overspend.

### Student Tasks
1. Deploy the HPA, run the k6 test, and capture scaling + the DB second-order effect.
2. Write a capacity plan: baseline, forecast (growth × spike), headroom replica math, the **DB-offload strategy** (caching/replicas/pool sizing), an **event-driven** component (KEDA/SQS) for async work, node-scaling choice (Karpenter vs CA with justification), monitoring/alerts, **cost-aware** choices (Spot/right-size/scale-to-zero, W18 link), and a leadership recommendation.
3. Include one architecture diagram and at least two scalability patterns (e.g., cache-aside + circuit breaker) with where they apply.

### Expected Deliverables
- `capacity-plan.md` (1–2 pages) + diagram + the k6 summary + recommended CloudWatch/Prometheus alerts.

### Submission Format
Markdown under `homework/week-22-class-02/`.

### Estimated Time
2–3 hours.

### Grading Criteria
- Real autoscaling deployed & validated by load test — 25%
- Plan fixes the DB bottleneck, not just pod count — 25%
- Correct headroom/forecast math — 15%
- Appropriate scaling tools (HPA/VPA/KEDA/Karpenter) chosen with reasons — 20%
- Cost-awareness + clarity — 15%

### Optional Advanced Challenge
Deploy a **KEDA ScaledObject** on SQS depth that scales a worker to zero; or install **Karpenter** on EKS and show a `Pending` pod provisioning a right-sized Spot node, then a PDB protecting availability during consolidation. Include manifests and `aws sso login`-based, IRSA-scoped IAM. **Tear everything down (Section 23) to avoid charges.**

---

## 19. Common Student Mistakes

1. **HPA with no/incorrect requests** → scales on a wrong ratio. Fix: set realistic requests (VPA to learn them).
2. **Treating autoscaling as the fix** → ignores downstream bottleneck. Fix: offload/right-size the DB first.
3. **Scaling on CPU for a queue worker** → backlog grows at low CPU. Fix: KEDA on queue depth.
4. **No `maxReplicas` cap / no node-capacity plan** → runaway cost or `Pending` pods. Fix: cap replicas; Karpenter/CA + PDB.
5. **Retries without jitter / no timeouts** → retry storms. Fix: timeouts + exponential backoff + jitter.
6. **Cache without invalidation/stampede thought** → stale data or thundering herd. Fix: TTL jitter, coalescing.
7. **Ignoring cost** → big bill, no reliability gain. Fix: Spot, right-size, scale-to-zero (W18).

---

## 20. Real-World Enterprise Scenario

A platform team running EKS for a retailer enters the holiday freeze with HPA already on the checkout service. Last year, scaling pods during the sale drove RDS to 100% connections and checkout p99 to 4 s anyway. This year they: put CloudFront in front of cacheable catalog responses, add ElastiCache cache-aside for hot reads, add an RDS read replica for read-heavy paths, right-size the connection pool with Little's Law, move order-confirmation emails to **SQS + KEDA workers** (scale-to-zero off-peak), adopt **Karpenter** with a Spot node pool and a PDB, and **load-test the whole thing in pre-prod with autoscaling enabled** the week before. Constraints: changes go through change-management during a partial freeze; IAM for Karpenter/KEDA is IRSA-scoped (keyless OIDC); finance caps spend, so Spot + scale-to-zero + right-sizing are required, not optional. The on-call runbook now explicitly says: *if latency rises, check DB saturation before raising `maxReplicas`.*

---

## 21. Instructor Tips

- **Pacing:** if short on time, demo HPA + the second-order DB effect live (highest value); make Karpenter/KEDA a walkthrough + optional lab.
- **Lab support:** pre-install metrics-server; have the in-cluster k6 Job ready (port-forward drops under load).
- **Struggling students:** give them the HPA manifest and just have them watch `kubectl get hpa -w` while k6 runs.
- **Advanced students:** Karpenter on EKS, KEDA scale-to-zero, and a circuit-breaker + retry-with-jitter implementation.

---

## 22. Student Outcome Checklist

**Can explain:** scaling taxonomy; HPA target-vs-request; VPA; Cluster Autoscaler vs Karpenter; KEDA/event-driven; caching patterns; read replicas/sharding/queues/backpressure/circuit breakers/retry+jitter; headroom & cost-aware scaling.
**Can build/configure:** a working HPA (CPU + custom metric), a VPA recommendation, a KEDA ScaledObject; a capacity plan validated by k6.
**Can troubleshoot:** an autoscaling incident where pressure shifts to the DB, and choose offload/right-size fixes over more pods.

---

## 23. Class Completion Checklist & Cleanup

**Instructor before ending:** HPA deployed and shown scaling; second-order DB effect demonstrated; Karpenter vs CA and KEDA covered; caching + ≥2 scalability patterns taught; capacity math + cost-awareness shown.
**Student before leaving:** deployed HPA, ran the load test, captured the DB effect, drafted a capacity plan addressing the bottleneck.

**Cleanup (do this to avoid charges):**
```bash
kubectl -n perf-lab delete -f hpa.yaml
kubectl delete namespace perf-lab
# If you created AWS resources for the optional labs:
# - delete the SQS queue, ElastiCache cluster, and any RDS read replica
# - if you installed Karpenter/created EKS nodes, scale node pools to 0 / delete the NodePool
# - confirm no EC2 nodes, NAT gateways, or RDS instances are left running
aws sqs delete-queue --queue-url <url>            # if created
```

---

## 24. End-of-Week Summary

**What students learned this week:** how to measure performance (latency percentiles, throughput, saturation), apply RED/USE and Little's Law, *generate* load with k6 and *trace* a bottleneck (Class 1); then plan capacity and scale correctly with HPA/VPA, Cluster Autoscaler vs Karpenter, KEDA, caching, and scalability patterns — cost-aware and validated by load testing (Class 2).

**How C1 and C2 connect:** C1 finds the bottleneck and the knee; C2 plans headroom and scales the *right* layer — and shows that scaling the app in front of a saturated DB makes things worse, which is the week's central lesson.

**How this prepares students for the next week:** Week 23 (Capstone Build) reuses the k6 harness and capacity thinking to validate the capstone under load and justify its scaling/caching design.

**Review before the next module:** percentiles vs averages, Little's Law, the HPA target-vs-request relationship, and when caching/replicas beat adding pods.

---

## Class Artifacts & Validation

The hands-on core of this class — deploy a working HPA, drive it with k6, and *watch it scale*, then reason about the second-order DB effect — is the on-disk, operated lab [`labs/performance-scaling/`](../../labs/performance-scaling/). That lab's HPA scales a real Deployment **1 → 5 under live k6 load on `kind`** (captured evidence), which is the runnable form of the §13 demo and §14 lab. The KEDA `ScaledObject`, VPA, and Karpenter manifests in §13 are **teaching excerpts for AWS-only mechanisms** — they are walkthroughs (no on-disk file or local gate), called out honestly below. The capacity-plan and postmortem-style write-ups draw on [`labs/sre-incident-response/`](../../labs/sre-incident-response/).

| # | Path | Type | What it is | Validation command | Result |
|---|------|------|-----------|--------------------|--------|
| 1 | labs/performance-scaling/solution/k8s/hpa.yaml | kubernetes | The HPA students deploy and observe (CPU `Utilization`, min/max, scale-up/down `behavior`) — the on-disk version of the §13 `hpa.yaml` | `kubeconform -strict -summary solution/k8s/{deployment,service,hpa,namespace}.yaml` | PASS — `Valid: 4` |
| 2 | labs/performance-scaling/solution/k8s/deployment.yaml | kubernetes | Deployment with `resources.requests.cpu` — the denominator the HPA target is a percentage of (the §11.3 "target-vs-request" point) | `python3 -c "import yaml; list(yaml.safe_load_all(open('solution/k8s/deployment.yaml')))"` | PASS |
| 3 | labs/performance-scaling/solution/load/load.js | k6 (JS) | The load test that drives the HPA over its 50% CPU target (reused from Class 1) | `k6 inspect solution/load/load.js` | PASS — 3 `stages` |
| 4 | labs/performance-scaling/solution/run-demo.sh | bash | One-command end-to-end: install metrics-server → apply manifests → load → capture scaling → teardown | `shellcheck -x solution/run-demo.sh` | PASS — no findings |
| 5 | labs/performance-scaling/broken/deployment-no-cpu-request.yaml | kubernetes | Reproducible broken state for the §15 troubleshooting drill: HPA `TARGETS <unknown>` (no CPU request → no ratio) | structural test asserts it stays broken: `python3 -m unittest discover -s tests` | PASS — `OK` (12 tests) |
| 6 | labs/performance-scaling/LIVE-DEMO-EVIDENCE.txt | evidence | Captured live `kind` run proving the HPA **scaled 1 → 5 under load** (CPU 108%/50%) then scaled back in — autoscaling *operated*, the heart of this class | `PERF_E2E=1 ./validate.sh` (or `./solution/run-demo.sh`) | PASS — see labs/performance-scaling/LIVE-DEMO-EVIDENCE.txt |
| 7 | labs/sre-incident-response/solution/postmortem-template.md | markdown | Blameless capacity/incident write-up template the homework capacity plan and §15 activity reuse | `test -f` (document artifact; no executable gate) | PASS — exists |
| — | §13 KEDA `ScaledObject` / VPA / Karpenter snippets | (teaching only) | AWS/EKS-only mechanisms shown as fenced excerpts; no on-disk file or local gate in this repo | n/a — walkthrough, not a shipped artifact | DEFERRED — runs on EKS with KEDA/Karpenter installed (see §13 commands) |

All executable commands run from `labs/performance-scaling/` (rows 1–6) or `labs/sre-incident-response/` (row 7). The live scaling gate (#6) is deferred by default in `./validate.sh` (a ~3-min demo); its committed transcript is checked on every run.

## Definition of Done

- [x] Every technology taught ships at least one **runnable file on disk** — the HPA, Deployment, k6 load test, and run-demo orchestrator are real files; KEDA/VPA/Karpenter are **honestly marked teaching-only** (AWS-only, no local gate) rather than passed off as shipped artifacts.
- [x] Each artifact passes (or documents) its **validation gate** — `kubeconform`, `k6 inspect`, `shellcheck -x`, structural unit tests all PASS (captured above); the live HPA scaling is captured in `LIVE-DEMO-EVIDENCE.txt`. The KEDA/Karpenter row is documented as DEFERRED with the exact EKS commands in §13.
- [x] Lab has **starter** (HPA + k6 stages TODO'd) and **solution** (reference) versions — `labs/performance-scaling/{starter,solution}`.
- [x] Lab `README` includes prerequisites, architecture, setup, tasks, **validation commands**, **expected outputs**, troubleshooting, **cleanup**, **security notes**, **cost notes** — see `labs/performance-scaling/README.md`.
- [x] **Cleanup/teardown** is provided and idempotent — `run-demo.sh` tears down on exit; §23 documents AWS teardown (SQS/ElastiCache/RDS/Karpenter) for the optional cloud labs.
- [x] **Instructor answer key** exists for the lab, homework, quiz, and troubleshooting exercise — README "Instructor answer key" + §17 answer key + §15 expected root cause.
- [x] **Troubleshooting exercise** uses a *real, reproducible broken state* — `broken/deployment-no-cpu-request.yaml` (`TARGETS <unknown>`); the §15 "autoscaling shifts pressure to the DB" scenario is grounded in the same operated lab.
- [x] **Expected outputs** are shown for demos and labs — §13 idle/loaded HPA tables and the `LIVE-DEMO-EVIDENCE.txt` 1→5 transcript.
- [x] **Cost & security warnings** present — §4 and §23 cost/security notes (EKS/EC2/SQS cost money; IRSA-scoped IAM, never broad `sqs:*`); local lab is $0.
- [x] **Cross-references** to the module repo and prior/next weeks are correct — §1/§2 link Class 1, Weeks 11/13/16/18, and Week 23 capstone.
- [x] The **artifact manifest** (§4.2) is present and every on-disk path resolves — verified with `ls`; the KEDA/VPA/Karpenter row is explicitly a teaching excerpt, not a claimed file.
