#!/usr/bin/env bash
# A span sent while the backend is down reaches the backend after it returns
set -uo pipefail

OTLP_URL="http://otelcol.observability:4318/v1/traces"

# POST one span to the Collector over OTLP/HTTP JSON from the shuttle pod.
# Arguments: trace id, span name, attributes as a JSON array. Prints the HTTP status code.
send_span() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
    -X POST -H 'Content-Type: application/json' \
    -d "{\"resourceSpans\":[{\"resource\":{\"attributes\":[{\"key\":\"service.name\",\"value\":{\"stringValue\":\"scout\"}}]},\"scopeSpans\":[{\"scope\":{\"name\":\"lab\"},\"spans\":[{\"traceId\":\"$1\",\"spanId\":\"eee19b7ec3c1b174\",\"name\":\"$2\",\"kind\":2,\"startTimeUnixNano\":\"1700000000000000000\",\"endTimeUnixNano\":\"1700000001000000000\",\"attributes\":$3}]}]}]}" \
    "$OTLP_URL" 2>/dev/null
}
attr_str() { printf '{"key":"%s","value":{"stringValue":"%s"}}' "$1" "$2"; }
attr_int() { printf '{"key":"%s","value":{"intValue":"%s"}}' "$1" "$2"; }
new_trace_id() { printf '%08x%08x%08x%08x' "$RANDOM$RANDOM" "$RANDOM$RANDOM" "$RANDOM$RANDOM" "$RANDOM$RANDOM" | cut -c1-32; }
collector_logs() { kubectl -n observability logs deploy/otelcol --tail=3000 2>/dev/null; }
wait_collector() { kubectl -n observability rollout status deploy/otelcol --timeout=120s >/dev/null 2>&1; }
# Prints the debug exporter text of every span of one trace.
spans_for_trace() {
  collector_logs | awk -v tid="$1" '
    /Span #[0-9]+/ { if (hit) print buf; buf=""; hit=0 }
    { buf = buf $0 "\n" }
    index($0, tid) && /Trace ID/ { hit=1 }
    END { if (hit) print buf }'
}
shuttle_curl() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 "$@" 2>/dev/null; }
config_text() { kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}' 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }

wait_collector
kubectl -n observability rollout status deploy/backend --timeout=120s >/dev/null 2>&1
backend_logs() { kubectl -n observability logs deploy/backend --tail=3000 2>/dev/null; }
restore_backend() { kubectl -n observability scale deploy/backend --replicas=1 >/dev/null 2>&1; kubectl -n observability rollout status deploy/backend --timeout=120s >/dev/null 2>&1; }
# Stop the backend, send one span while it is down, start the backend again.
kubectl -n observability scale deploy/backend --replicas=0 >/dev/null 2>&1
kubectl -n observability wait --for=delete pod -l app=backend --timeout=90s >/dev/null 2>&1
TRACE="$(new_trace_id)"
send_span "$TRACE" "outage-$RANDOM" '[]' >/dev/null
sleep 3
restore_backend
found=0
for i in $(seq 1 45); do
  if backend_logs | grep -q "$TRACE"; then found=1; break; fi
  sleep 2
done
if [ "$found" -ne 1 ]; then fail_with "the span sent during the backend outage never reached the backend"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: A span sent during a backend outage reached the backend afterwards"; fi
exit "$fail"
