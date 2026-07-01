#!/usr/bin/env bash
# run-load.sh -- wrapper that runs the k6 smoke/ramp load test against payments-api.
#
# It checks that k6 is installed, points the test at a BASE_URL (default localhost),
# and forwards the SLO thresholds in load/k6-smoke.js. k6 exits non-zero when a
# threshold (p95 latency, error rate) is breached, so this script's exit code is a
# usable CI gate.
#
# Usage:
#   ./run-load.sh                              # against http://localhost:8080
#   BASE_URL=https://staging.example.com ./run-load.sh
#   ./run-load.sh --vus 20 --duration 1m       # extra args pass through to k6
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${HERE}/k6-smoke.js"
BASE_URL="${BASE_URL:-http://localhost:8080}"

if [[ ! -f "$SCRIPT" ]]; then
  echo "error: k6 script not found at $SCRIPT" >&2
  exit 1
fi

if ! command -v k6 >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: k6 is not installed.

Install it (https://grafana.com/docs/k6/latest/set-up/install-k6/):
  # Debian/Ubuntu
  sudo gpg -k
  sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg \
    --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
  echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" \
    | sudo tee /etc/apt/sources.list.d/k6.list
  sudo apt-get update && sudo apt-get install k6

  # macOS
  brew install k6

  # Docker (no install)
  docker run --rm -i grafana/k6 run - < load/k6-smoke.js
EOF
  exit 127
fi

echo "Running k6 smoke/ramp load test against ${BASE_URL}"
echo "Thresholds: http_req_duration p95<300ms, http_req_failed rate<0.1%"
echo

# BASE_URL is read by k6-smoke.js via __ENV.BASE_URL. Any extra CLI args
# ("$@") pass straight through to k6 (e.g. --vus, --duration, --out).
exec env BASE_URL="$BASE_URL" k6 run "$@" "$SCRIPT"
