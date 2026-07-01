#!/usr/bin/env bash
# check_references.sh — verify every labs/<module> path the capstone references
# actually exists on disk. The capstone is an INTEGRATION module: if a referenced
# module or file has been renamed/moved, the capstone is silently broken. This
# checker makes that failure loud.
#
# It checks two things:
#   1. Every sibling module directory the capstone wires together exists.
#   2. Every concrete file path referenced by the demo stack / docs exists
#      (the app build context, the configmap we mirror, etc.).
#
# Exits 0 only if ALL referenced paths resolve; non-zero (and prints the misses)
# otherwise. Run from anywhere; paths are resolved relative to the repo's labs/.
set -euo pipefail

# Resolve labs/ root from this script's location: tests/ -> capstone/ -> labs/
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
labs_root="$(cd "$here/../.." && pwd)"

# --- The integration contract -------------------------------------------------
# Sibling modules the capstone wires together (must all be present).
modules=(
  terraform-aws-foundations
  docker-containers
  kubernetes-fundamentals
  helm-charts
  cicd-pipelines
  observability
  sre-incident-response
)

# Concrete files the capstone depends on by exact path. If any of these move,
# the demo build / docs cross-references break — so we assert them explicitly.
files=(
  # The app image the demo + k8s + helm all ship comes from here:
  docker-containers/solution/Dockerfile
  docker-containers/app/server.py
  docker-containers/app/healthcheck.py
  # The env contract (REDIS_HOST/PORT, PORT) the demo mirrors:
  kubernetes-fundamentals/solution/base/configmap.yaml
  kubernetes-fundamentals/solution/base/deployment.yaml
  # The Helm chart the capstone deploys with:
  helm-charts/solution/chart/webapp/Chart.yaml
  helm-charts/solution/chart/webapp/values.yaml
  # The infra foundation the capstone provisions on:
  terraform-aws-foundations/solution/main.tf
  # The pipeline that builds + deploys:
  cicd-pipelines/solution/.github/workflows/ci.yml
  cicd-pipelines/solution/.github/workflows/cd.yml
  # The observability assets the capstone operates with:
  observability/solution/prometheus/prometheus.yml
  observability/solution/prometheus/rules/alerting.rules.yml
  observability/solution/slo/slo.yaml
  # The SRE operate-it assets:
  sre-incident-response/solution/scripts/error_budget.py
  sre-incident-response/solution/scripts/nines_downtime.py
)

miss=0
echo "== checking referenced module directories =="
for m in "${modules[@]}"; do
  if [ -d "$labs_root/$m" ]; then
    printf '  [OK]   labs/%s\n' "$m"
  else
    printf '  [MISS] labs/%s  (directory not found)\n' "$m"
    miss=$((miss + 1))
  fi
done

echo "== checking referenced files =="
for f in "${files[@]}"; do
  if [ -f "$labs_root/$f" ]; then
    printf '  [OK]   labs/%s\n' "$f"
  else
    printf '  [MISS] labs/%s  (file not found)\n' "$f"
    miss=$((miss + 1))
  fi
done

echo "== $((${#modules[@]} + ${#files[@]} - miss)) found, $miss missing =="
if [ "$miss" -gt 0 ]; then
  echo "FAIL: capstone references paths that do not exist." >&2
  exit 1
fi
echo "PASS: every referenced labs/ path resolves."
