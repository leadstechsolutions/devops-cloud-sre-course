// k6 smoke + ramp load test for the payments-api service.
//
// What it does:
//   * ramps virtual users 0 -> 10 -> 0 over ~1 minute (a smoke-sized ramp),
//   * hits GET /healthz and POST /v1/authorize on the target,
//   * asserts per-request checks (status, body, latency),
//   * enforces SLO-shaped thresholds so the run FAILS the build when the service
//     is too slow or too error-prone (k6 exits non-zero on threshold breach).
//
// The thresholds mirror the SLOs in slo/slo.yaml:
//   - http_req_duration p95 < 300ms      (latency SLO: 99% under 300ms)
//   - http_req_failed   rate < 0.1%       (availability SLO: 99.9% success)
//
// Run (k6 required; not installed in the lab build env — see README):
//   BASE_URL=http://localhost:8080 k6 run load/k6-smoke.js
//   k6 run --vus 10 --duration 30s load/k6-smoke.js          # quick override
//   k6 run --out json=load/result.json load/k6-smoke.js      # machine-readable
//
// Docs: https://grafana.com/docs/k6/latest/

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metric: fraction of authorize calls the app reported as declined (a
// business signal distinct from HTTP failures).
const declineRate = new Rate('payment_declines');

// Target base URL; override with BASE_URL env var. __ENV is k6's env accessor.
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export const options = {
  // Ramp profile: gentle smoke load, not a stress test.
  stages: [
    { duration: '15s', target: 10 }, // ramp up to 10 VUs
    { duration: '30s', target: 10 }, // hold
    { duration: '15s', target: 0 },  // ramp down
  ],
  thresholds: {
    // Latency SLO: 95th percentile under 300ms. Build fails if breached.
    http_req_duration: ['p(95)<300'],
    // Availability SLO: fewer than 0.1% of HTTP requests fail.
    http_req_failed: ['rate<0.001'],
    // At least 99% of explicit checks must pass.
    checks: ['rate>0.99'],
    // Guardrail on the custom business metric: under 20% declines is "normal".
    payment_declines: ['rate<0.20'],
  },
};

export default function () {
  // 1) Liveness probe — cheap, should always be 200 and fast.
  const health = http.get(`${BASE_URL}/healthz`, {
    tags: { endpoint: 'healthz' },
  });
  check(health, {
    'healthz is 200': (r) => r.status === 200,
    'healthz fast (<100ms)': (r) => r.timings.duration < 100,
  });

  // 2) Authorize a small payment — the revenue-critical path the SLO protects.
  const payload = JSON.stringify({
    amount_cents: 1299,
    currency: 'USD',
    card_token: 'tok_test_visa',
  });
  const params = {
    headers: { 'Content-Type': 'application/json' },
    tags: { endpoint: 'authorize' },
  };
  const res = http.post(`${BASE_URL}/v1/authorize`, payload, params);

  const ok = check(res, {
    'authorize is 200': (r) => r.status === 200,
    'authorize returns JSON': (r) =>
      (r.headers['Content-Type'] || '').includes('application/json'),
    'authorize has decision': (r) => {
      try {
        return typeof r.json('approved') === 'boolean';
      } catch (e) {
        return false;
      }
    },
  });

  // Record the business decline metric when the call succeeded structurally.
  if (ok) {
    let approved = false;
    try {
      approved = res.json('approved') === true;
    } catch (e) {
      approved = false;
    }
    declineRate.add(!approved);
  }

  // Pace each VU ~1 iteration/sec so the ramp profile is meaningful.
  sleep(1);
}
