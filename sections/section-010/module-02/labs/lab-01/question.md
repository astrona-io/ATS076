# Question

Solve this question on: `terminal`

The `edge` proxy in `starfleet` has two listeners that both forward to the `probe` service. Port 80 is the public listener: callers from outside the organization use it and are not trusted. Port 8081 is the internal listener: only services of the organization use it.

1. Send a request with a `traceparent` header and a `baggage` header (`userId=alice`) to each listener (`http://edge.starfleet/headers` and `http://edge.starfleet:8081/headers`) and read what the `probe` received.
2. Change the public listener so that the `baggage` header never reaches the `probe`, while the `traceparent` header still does.
3. Leave the internal listener as it is: it must still forward `baggage`.

`kubectl` already points at the cluster. The nginx configuration is in the ConfigMap `edge-conf` in `starfleet`. nginx reads its configuration at start, so the pods must restart after a change.
