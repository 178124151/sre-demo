# Resume Highlights

## One-Line Summary

Built an SRE-oriented demo service with Nginx, Flask, MySQL, Prometheus, Grafana, Docker Compose, and Kubernetes manifests, focused on observability, health checks, fault isolation, and low-resource deployment tradeoffs.

## Resume Bullets

- Designed and deployed a small web service behind Nginx with multi-instance Flask containers, MySQL persistence, and Prometheus/Grafana monitoring.
- Implemented `/health`, `/ready`, and `/metrics` endpoints to support load balancer checks, Kubernetes probes, and service observability.
- Added structured Nginx access logging, Prometheus alert rules, SLO documentation, and incident runbooks for 5xx errors and high latency.
- Built Kubernetes manifests with `Deployment`, `StatefulSet`, `Service`, `PodDisruptionBudget`, and Kustomize overlays for both local demo and 2C2G resource-constrained scenarios.
- Documented why Docker Compose remained the practical production choice on a single low-spec server and how to evolve the system toward a more production-ready Kubernetes setup.

## Interview Framing

1. Start with the constraint: the original environment was a single 2C2G Aliyun server.
2. Explain the decision: Compose was the lowest-overhead production option under that constraint.
3. Show the SRE thinking: health checks, readiness checks, alert rules, dashboards, runbooks, and resource limits.
4. Show the growth path: local Kubernetes demo today, managed database and multi-node cluster later.

## What This Project Proves

- You can balance engineering idealism with real infrastructure constraints.
- You understand the difference between "can run" and "can operate."
- You can turn a toy web service into an operations-focused demo with measurable reliability signals.
