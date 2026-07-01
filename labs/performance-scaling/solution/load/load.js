// k6 ramping load test for the cpu-burner service.
//
// It drives the /burn endpoint, which pins a CPU thread per request, so the
// arrival rate maps directly to cluster CPU usage and forces the HPA to scale.
//
// Stages ramp virtual users up, hold at peak, then ramp down — long enough at
// peak (60s) for metrics-server to publish elevated CPU and the HPA to add pods.
//
// Run via a port-forward to the in-cluster Service (see run-demo.sh):
//   kubectl -n lab-perf port-forward svc/cpu-burner 8080:80 &
//   BASE_URL=http://localhost:8080 BURN_MS=80 k6 run solution/load/load.js
//
// Tunables (environment, read with __ENV):
//   BASE_URL  target base URL              (default http://localhost:8080)
//   BURN_MS   per-request CPU burn in ms   (default 80)
//   PEAK_VUS  virtual users at the plateau (default 30)
import http from "k6/http";
import { check, sleep } from "k6";
import { Trend } from "k6/metrics";

const BASE_URL = __ENV.BASE_URL || "http://localhost:8080";
const BURN_MS = __ENV.BURN_MS || "120";
const PEAK_VUS = parseInt(__ENV.PEAK_VUS || "20", 10);

// Custom trend for the /burn latency specifically, separate from k6's built-in
// http_req_duration (which also includes the cheap /healthz warmup requests).
const burnDuration = new Trend("burn_duration", true);

export const options = {
  // Ramping VUs: climb to PEAK over 30s, HOLD at PEAK for 60s (the window the
  // HPA needs to see sustained CPU and scale up), then ramp down over 20s.
  stages: [
    { duration: "30s", target: PEAK_VUS },
    { duration: "60s", target: PEAK_VUS },
    { duration: "20s", target: 0 },
  ],
  // Reuse TCP connections (the default) so the single port-forward isn't churned
  // with a fresh dial per request, and don't abort the whole run if a threshold
  // is crossed mid-test — we still want the scaling captured and the summary.
  noConnectionReuse: false,
  thresholds: {
    // Hard gate: 95th-percentile /burn latency must stay under 1.5s. A breach
    // makes `k6 run` exit non-zero, so the demo fails loudly instead of
    // silently passing a degraded service.
    burn_duration: ["p(95)<1500"],
    // Allow a small failure budget: a single `kubectl port-forward` (how the
    // demo reaches the in-cluster Service) can reset a few connections under
    // high concurrency and while the HPA is adding/removing pods. That is a
    // property of the TEST RIG, not the service — so we tolerate up to 3% here.
    // Through a real LoadBalancer/Ingress you would tighten this back to <1%.
    http_req_failed: ["rate<0.03"],
    checks: ["rate>0.95"],
  },
};

export default function () {
  const res = http.get(`${BASE_URL}/burn?ms=${BURN_MS}`);

  check(res, {
    "status is 200": (r) => r.status === 200,
    "did CPU work (iterations > 0)": (r) => {
      try {
        return JSON.parse(r.body).iterations > 0;
      } catch (_e) {
        return false;
      }
    },
  });

  burnDuration.add(res.timings.duration);

  // Small think time so a VU is not a pure tight loop; arrival rate still scales
  // with VU count, which is what drives CPU and the HPA.
  sleep(0.1);
}

// Optional liveness smoke before the test: fail fast if the target is unreachable.
export function setup() {
  const res = http.get(`${BASE_URL}/healthz`);
  if (res.status !== 200) {
    throw new Error(
      `target not reachable at ${BASE_URL}/healthz (status ${res.status}) — ` +
        "is the port-forward up?",
    );
  }
}
