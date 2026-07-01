# Runbook — capstone service

On-call operational guide for the integrated capstone service (the app from
`labs/docker-containers`, deployed via `labs/helm-charts` onto Kubernetes,
observed via `labs/observability`). Keep this open during an incident.

## Service summary

| | |
|---|---|
| **Service** | `capstone-app` (stateless HTTP) |
| **Dependencies** | Redis (cache; loss is survivable), Prometheus (metrics) |
| **Health** | `GET /healthz` → `200 {"status":"ok"}` |
| **Default port** | `8000` |
| **Owner** | platform/SRE |
| **SLO** | see `labs/observability/solution/slo/slo.yaml` (availability + latency) |
| **Error budget tool** | `python3 labs/sre-incident-response/solution/scripts/error_budget.py` |

## How to reach things

```bash
# Local demo stack
docker compose -f docker-compose.demo.yaml --profile metrics up -d
curl -fsS http://127.0.0.1:8000/healthz          # app health
curl -fsS http://127.0.0.1:9090/-/ready          # prometheus ready

# Cluster (cloud profile)
kubectl -n capstone get deploy,po,hpa,svc,ingress
kubectl -n capstone logs deploy/capstone-app --tail=100
kubectl -n capstone rollout status deploy/capstone-app
```

---

## Alert → response playbooks

### 1. `HighErrorBudgetBurn` / availability SLO burning fast

**Symptom:** multi-burn-rate alert firing (`alerting.rules.yml`); error rate up
on the Grafana service-overview dashboard.

1. Confirm scope: is it all replicas or one? `kubectl -n capstone get po -o wide`.
2. Check recent change: `helm history capstone-app -n capstone`. A bad release is
   the most common cause.
3. **If a deploy correlates:** roll back.
   ```bash
   helm rollback capstone-app -n capstone        # to previous good revision
   kubectl -n capstone rollout status deploy/capstone-app
   ```
4. If not deploy-related, check the dependency (Redis) and resource pressure
   (playbooks 3 and 4 below).
5. Record budget impact: `error_budget.py --slo 99.9 --window 30d ...` to decide
   whether to freeze deploys.

### 2. App pods `CrashLoopBackOff` or failing readiness

**Symptom:** pods not `Ready`; `/healthz` returns non-200 or connection refused.

1. `kubectl -n capstone describe po <pod>` — look at `Last State` and `Events`.
2. `kubectl -n capstone logs <pod> --previous` — read the crash reason.
3. Common causes & fixes:
   - **Bad `PORT`/config** → `server.py` exits non-zero on an invalid `PORT`.
     Check the ConfigMap (`labs/kubernetes-fundamentals/solution/base/configmap.yaml`).
   - **OOMKilled** → see playbook 4.
   - **Bad image tag** → `helm rollback` (playbook 1, step 3).
4. Verify recovery: `kubectl -n capstone get po` shows `Running`/`Ready`.

### 3. Redis (cache) unavailable

**Symptom:** Redis pod down; app stays up (Redis is a cache, not system of record).

1. Confirm impact is degraded-not-down: the app's `/healthz` should still be 200.
2. Restart the dependency: `kubectl -n capstone rollout restart deploy/redis`
   (or `docker compose ... restart redis` locally).
3. Because it is a cache, **data loss is acceptable** (per ADR-0002). No restore
   needed; cache repopulates. If this ever becomes false, escalate to a managed,
   backed-up Redis per the ADR.

### 4. OOMKilled / memory pressure

**Symptom:** `kubectl describe po` shows `OOMKilled`; pod restarts.

1. Confirm it is the limit, not a leak: compare usage to the limit
   (`kubectl top po -n capstone`).
2. Short term: raise the memory limit in `values.yaml` and `helm upgrade`.
3. Long term: profile the app; a steadily rising RSS is a leak, not a sizing bug.
   See the `broken/` fixture in `labs/kubernetes-fundamentals` for a reproducible
   OOM to practice on.

### 5. High latency, no errors

**Symptom:** latency SLO burning, error rate flat.

1. Check saturation: CPU near the limit? HPA at max replicas?
   `kubectl -n capstone get hpa`.
2. If HPA is maxed, raise `maxReplicas` (`values.yaml`) and `helm upgrade`.
3. Check the downstream (Redis latency) on the dashboard.

---

## Standard operations

```bash
# Deploy / upgrade (CD does this automatically; manual fallback):
helm upgrade --install capstone-app labs/helm-charts/solution/chart/webapp \
  -n capstone --create-namespace -f <env-values>.yaml

# Roll back to the previous revision:
helm rollback capstone-app -n capstone

# Scale manually (bypassing HPA temporarily):
kubectl -n capstone scale deploy/capstone-app --replicas=4

# Drain for maintenance: cordon node, then rollout restart picks new nodes.
```

## Escalation

1. Primary on-call (this runbook).
2. If unresolved in 30 min or customer-impacting: page secondary / service owner.
3. Open an incident, start a timeline, declare severity. Post-incident: write the
   review using the template in `labs/sre-incident-response`.

## After every incident

- [ ] Timeline captured.
- [ ] Error-budget impact computed (`error_budget.py`).
- [ ] Action items filed (fix the cause, not just the symptom).
- [ ] If a decision changed (e.g. cache → managed Redis), write/supersede an ADR.
