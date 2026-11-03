#!/usr/bin/env bash
# Runs under `astrona test` after the reference solution: waits for the restarted pods.
set -euo pipefail

kubectl -n observability rollout status deployment/otelcol --timeout=180s
sleep 5
echo "[testing] settled."
