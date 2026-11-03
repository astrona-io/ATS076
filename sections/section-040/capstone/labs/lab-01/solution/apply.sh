#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
observed="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
sed -e "s/OBSERVED_AT/${observed}/" "$DIR/solution.yaml" | kubectl apply -f -
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol --timeout=180s
echo "[solution] Applied."
