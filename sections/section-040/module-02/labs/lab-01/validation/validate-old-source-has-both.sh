#!/usr/bin/env bash
# A span sent with the legacy names leaves with the legacy and the stable names
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

# Sends a span with attributes and prints the debug exporter text for it.
trace_with() { # name, attributes json array
  wait_collector
  local trace="$(new_trace_id)"
  code="$(send_span "$trace" "$1" "$2")"
  if [ "$code" != "200" ]; then fail_with "the Collector answered HTTP '$code', expected 200"; fi
  sleep 3
  spans_for_trace "$trace"
}
has() { echo "$1" | grep -q -- "-> $2: $3"; }
out="$(trace_with "legacy-$RANDOM" "[$(attr_str http.method GET),$(attr_int http.status_code 200),$(attr_str custom.keep yes)]")"
for pair in 'http.method Str(GET)' 'http.request.method Str(GET)' 'http.status_code Int(200)' 'http.response.status_code Int(200)'; do
  set -- $pair
  has "$out" "$1" "$2" || fail_with "attribute $1 with value $2 is missing"
done

if [ "$fail" -eq 0 ]; then echo "PASS: A span sent with the legacy names leaves with the legacy and the stable names"; fi
exit "$fail"
