#!/usr/bin/env bash
# Starting state for Strip Baggage At The Public Edge. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet rollout status deployment/edge --timeout=180s
echo "[lab] Ready."
