#!/usr/bin/env bash
# Bring up a real local Kubernetes cluster for the K8s/Helm/observability/SRE labs.
# Free, local, disposable. Requires docker + kind (see install-toolchain.sh).
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
NAME="${1:-course}"

if kind get clusters 2>/dev/null | grep -qx "$NAME"; then
  echo "cluster '$NAME' already exists"
else
  kind create cluster --name "$NAME" --wait 90s
fi
kubectl --context "kind-$NAME" get nodes
echo
echo "Use it:   kubectl --context kind-$NAME ..."
echo "Tear down: kind delete cluster --name $NAME"
