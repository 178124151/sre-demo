# Resume Highlights

## One-Line Summary

Built an SRE-oriented demo service with Nginx, Flask, MySQL, Prometheus, Grafana, and Docker Compose, focused on observability, health checks, alerting, and operational troubleshooting.

## Resume Bullets

- Designed and deployed a small web service behind Nginx with multi-instance Flask containers, MySQL persistence, and Prometheus/Grafana monitoring.
- Implemented `/health`, `/ready`, and `/metrics` endpoints to support load balancer checks, service readiness, and observability.
- Added structured Nginx access logging, Prometheus alert rules, SLO documentation, and incident runbooks for 5xx errors and high latency.
- Built a one-command local demo flow with Docker Compose so the full service and observability stack can be shown reliably in interviews.
- Documented deployment assumptions, operational signals, and failure-handling steps to show how the service would be run rather than only how it starts.

## Interview Framing

1. Start with the system shape: Nginx in front, two Flask instances, one MySQL, plus Prometheus and Grafana.
2. Explain the SRE thinking: separate health and readiness checks, observable request flow, and dashboard-backed alerting.
3. Show how incidents would be handled: use Prometheus alerts, Grafana dashboards, and runbooks to narrow down whether failures are in app, proxy, or database.
4. Emphasize delivery quality: one-command startup, repeatable validation, and a repo that is easy to demo live.

## What This Project Proves

- You can balance engineering idealism with real infrastructure constraints.
- You understand the difference between "can run" and "can operate."
- You can turn a toy web service into an operations-focused demo with measurable reliability signals.
