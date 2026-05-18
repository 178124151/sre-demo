# SLO

## Service

`sre-demo` is a small HTTP service backed by MySQL and fronted by Nginx.

## User-Facing SLIs

| SLI | PromQL | Target |
| --- | --- | --- |
| Availability | `1 - (sum(rate(flask_http_request_total{status=~"5.."}[5m])) / sum(rate(flask_http_request_total[5m])))` | 99.5% monthly |
| Latency | `histogram_quantile(0.99, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le))` | p99 < 1s |
| Database errors | `sum(rate(db_query_errors_total[5m]))` | 0 sustained errors |

## Error Budget

For a 99.5% monthly availability target, the monthly error budget is about 3.6 hours. Any incident that burns more than 25% of the monthly budget should trigger a short postmortem and a follow-up task.

## Alert Policy

- Page when 5xx rate is above 5% for 5 minutes.
- Create a warning when p99 latency is above 1s for 10 minutes.
- Investigate immediately when database query errors are non-zero for more than 5 minutes.

## Non-Goals

This demo does not claim multi-zone high availability or managed-database durability. The goal is to show strong local operational practice on a small service, not to simulate a full production platform.
