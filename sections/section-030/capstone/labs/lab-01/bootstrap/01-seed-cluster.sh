#!/usr/bin/env bash
# Starting state for Error Handling Capstone. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
kubectl -n observability rollout status deployment/backend --timeout=180s
kubectl -n observability rollout status deployment/otelcol --timeout=180s
echo "[lab] Ready."
