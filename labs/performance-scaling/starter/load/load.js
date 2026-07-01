// k6 ramping load test for the cpu-burner service — STARTER.
//
// TODO(lab): fill in the ramping `stages` and the `thresholds` (see FIXMEs).
//
// The default function and checks are already written for you; you only design
// the load profile and the pass/fail gates.
//
// Run via a port-forward to the in-cluster Service (run-demo.sh does this):
//   kubectl -n lab-perf port-forward svc/cpu-burner 8080:80 &
//   BASE_URL=http://localhost:8080 BURN_MS=80 k6 run starter/load/load.js
import http from "k6/http";
import { check, sleep } from "k6";
import { Trend } from "k6/metrics";

const BASE_URL = __ENV.BASE_URL || "http://localhost:8080";
const BURN_MS = __ENV.BURN_MS || "80";
const PEAK_VUS = parseInt(__ENV.PEAK_VUS || "30", 10);

const burnDuration = new Trend("burn_duration", true);

export const options = {
  // TODO: define a ramping VU profile with THREE stages:
  //   1. ramp UP to PEAK_VUS over ~30s
  //   2. HOLD at PEAK_VUS for ~60s   (long enough for metrics-server + HPA)
  //   3. ramp DOWN to 0 over ~20s
  // Each stage is { duration: "<Ns>", target: <vus> }.
  stages: [
    // FIXME: { duration: "30s", target: PEAK_VUS },
    // FIXME: { duration: "60s", target: PEAK_VUS },
    // FIXME: { duration: "20s", target: 0 },
  ],
  thresholds: {
    // TODO: set real pass/fail gates so a degraded run exits non-zero. Suggested:
    //   - burn_duration p(95) under 1500ms
    //   - http_req_failed rate under 1%
    //   - checks rate over 99%
    // FIXME: burn_duration: ["p(95)<1500"],
    // FIXME: http_req_failed: ["rate<0.01"],
    // FIXME: checks: ["rate>0.99"],
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
  sleep(0.1);
}

export function setup() {
  const res = http.get(`${BASE_URL}/healthz`);
  if (res.status !== 200) {
    throw new Error(
      `target not reachable at ${BASE_URL}/healthz (status ${res.status})`,
    );
  }
}
