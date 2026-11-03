#!/usr/bin/env bash
# A span sent to the Collector reaches the backend
set -uo pipefail

OTLP_URL="http://otelcol.observability:4318/v1/traces"
shuttle_curl() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 "$@" 2>/dev/null; }
config_text() { kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}' 2>/dev/null; }
send_span() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
    -X POST -H 'Content-Type: application/json' \
    -d "{\"resourceSpans\":[{\"resource\":{\"attributes\":[{\"key\":\"service.name\",\"value\":{\"stringValue\":\"scout\"}}]},\"scopeSpans\":[{\"scope\":{\"name\":\"lab\"},\"spans\":[{\"traceId\":\"$1\",\"spanId\":\"eee19b7ec3c1b174\",\"name\":\"$2\",\"kind\":2,\"startTimeUnixNano\":\"1700000000000000000\",\"endTimeUnixNano\":\"1700000001000000000\"}]}]}]}" \
    "$OTLP_URL" 2>/dev/null
}
new_trace_id() { printf '%08x%08x%08x%08x' "$RANDOM$RANDOM" "$RANDOM$RANDOM" "$RANDOM$RANDOM" "$RANDOM$RANDOM" | cut -c1-32; }
wait_collector() { kubectl -n observability rollout status deploy/otelcol --timeout=120s >/dev/null 2>&1; }
backend_logs() { kubectl -n observability logs deploy/backend --tail=3000 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }
kubectl -n observability rollout status deploy/otelcol --timeout=120s >/dev/null 2>&1
wait_collector
TRACE="$(new_trace_id)"
code="$(send_span "$TRACE" "lab-otlp-$RANDOM")"
if [ "$code" != "200" ]; then fail_with "the Collector answered HTTP '$code' on port 4318, expected 200"; fi
found=0
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if backend_logs | grep -q "$TRACE"; then found=1; break; fi
  sleep 3
done
if [ "$found" -ne 1 ]; then fail_with "the trace id $TRACE did not appear in the log of the backend"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: A span sent to the Collector reaches the backend"; fi
exit "$fail"
