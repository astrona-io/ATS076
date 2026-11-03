#!/usr/bin/env bash
# The sending queue stores its batches with the file_storage/queue extension
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

cfg="$(config_text)"
if ! echo "$cfg" | grep -Eq '^[[:space:]]*storage:[[:space:]]*file_storage/queue[[:space:]]*$'; then fail_with "sending_queue has no storage: file_storage/queue"; fi
if ! echo "$cfg" | grep -E '^[[:space:]]*extensions:[[:space:]]*\[' | grep -q 'file_storage/queue'; then fail_with "file_storage/queue is not in service.extensions"; fi
wait_collector
if [ "$(kubectl -n observability get deployment otelcol -o jsonpath='{.status.availableReplicas}' 2>/dev/null)" != "1" ]; then fail_with "the Collector is not running with the new configuration"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: The sending queue stores its batches with the file_storage/queue extension"; fi
exit "$fail"
