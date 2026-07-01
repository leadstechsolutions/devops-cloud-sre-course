# Runbook: payments-api High Error Rate / Error-Budget Fast Burn

> **Trigger:** Alert `PaymentsAPIErrorBudgetFastBurn` (severity `page`) from
> `slo/burn-rate-alerts.yaml`. The service is burning the 99.9% availability
> error budget at 14.4x (1h) or 6x (6h).
> **Severity:** SEV2 by default; escalate to SEV1 if checkout is fully down or
> revenue impact is confirmed.
> **Owner:** Payments on-call (PagerDuty: `payments-oncall`).

## 0. First 5 minutes (stop the bleeding before you understand it)

1. **Acknowledge** the page so a second responder isn't paged.
2. **Declare an incident** if burn is sustained > 5 min or customer impact is
   visible. Open the incident channel and assume the **Incident Commander** role
   until handed off (see `incident-command.md`).
3. **Check the blast radius** — is this all traffic or one region/version?
   ```
   # error ratio right now (should be < 0.001 when healthy):
   curl -s "$PROM/api/v1/query?query=job:slo_errors_per_request:ratio_rate5m" | jq '.data.result'
   ```
4. **Look for a recent change** — most incidents are change-induced:
   ```
   kubectl -n payments rollout history deploy/payments-api
   ```
   If a deploy landed in the last 30 min and correlates, **roll back first,
   diagnose later** (see §2).

## 1. Diagnose

Work the most-likely-and-cheapest hypotheses first.

| Hypothesis | Quick check | If true → |
|------------|-------------|-----------|
| Bad deploy | `kubectl -n payments rollout history deploy/payments-api`; compare image tag to last-known-good | Roll back (§2.1) |
| Dependency down (DB / card network) | `curl -s $BASE_URL/healthz` shows `db: down`; check upstream status page | Fail over / open vendor ticket (§2.2) |
| Resource saturation | `kubectl -n payments top pods`; CPU/mem at limit, OOMKills in events | Scale out (§2.3) |
| Config / secret rotation | recent secret or ConfigMap change; auth 401/500s spike | Restore prior config (§2.1) |
| Traffic spike / abuse | request rate 5–10x baseline; single client/IP dominates | Rate-limit / shed load (§2.4) |

Useful queries (`$PROM` = Prometheus base URL):
```
# request rate by code, last 15m
curl -s "$PROM/api/v1/query?query=sum%20by(code)(rate(http_requests_total%7Bjob%3D%22payments-api%22%7D%5B5m%5D))"
# p95 latency, last 5m
curl -s "$PROM/api/v1/query?query=histogram_quantile(0.95,sum(rate(http_request_duration_seconds_bucket%7Bjob%3D%22payments-api%22%7D%5B5m%5D))by(le))"
```

## 2. Mitigate

### 2.1 Roll back a bad deploy (most common fix)
```
kubectl -n payments rollout undo deploy/payments-api
kubectl -n payments rollout status deploy/payments-api --timeout=120s
```
Confirm the error ratio drops below 0.001 within ~5 min on the dashboard.

### 2.2 Dependency failure
- If the **database** is the dependency: confirm with the DB on-call, fail over
  to the replica if the primary is unhealthy, and enable the app's read-only /
  degraded mode if available.
- If the **card network** is the dependency: there is no fix on our side. Open a
  vendor ticket, switch to the backup processor if one is configured, and post a
  customer status update. Track as an *external* contributing factor.

### 2.3 Saturation
```
kubectl -n payments scale deploy/payments-api --replicas=<2x current>
```
Verify HPA isn't blocked (check `kubectl -n payments describe hpa payments-api`).

### 2.4 Load shedding / abuse
- Tighten the API gateway rate limit for the offending client.
- If a single IP/token dominates, block it at the edge (WAF / gateway).

## 3. Verify recovery
- Error ratio (`ratio_rate5m`) back **< 0.001** and stable for 15 min.
- p95 latency back **< 300 ms**.
- The `PaymentsAPIErrorBudgetFastBurn` alert resolves (it auto-clears once the
  short window drops below threshold).

## 4. After the incident
- Hand the timeline to the IC for the **blameless postmortem**
  (`postmortem-template.md`). Required for any SEV1/SEV2.
- Re-run `scripts/error_budget.py` with the incident's good/total counts to
  quantify how much of the monthly budget this consumed:
  ```
  python scripts/error_budget.py --target 0.999 --good <good> --total <total>
  ```
- File follow-up action items with owners and due dates.

## Escalation
- Payments on-call → Payments EM → Director of Engineering.
- Dependency owners: `#db-oncall`, `#platform-oncall`, vendor support line.
- If revenue-impacting > 30 min, notify Comms lead to prepare external messaging.
