# Architecture

```mermaid
flowchart LR
    user["User"] --> nginx["Nginx reverse proxy"]
    nginx --> web1["Flask instance 1"]
    nginx --> web2["Flask instance 2"]
    web1 --> mysql["MySQL"]
    web2 --> mysql
    prometheus["Prometheus"] --> web1
    prometheus --> web2
    prometheus --> nginxExporter["Nginx exporter"]
    prometheus --> nodeExporter["Node exporter"]
    grafana["Grafana"] --> prometheus
```

## Runtime Mode

This project is designed around a single Docker Compose deployment path for stable local demos and interview walkthroughs.

## Reliability Features

- Nginx uses `least_conn` to reduce request pileups on slow instances.
- Flask exposes `/health`, `/ready`, and `/metrics`.
- MySQL data is persisted with a Docker volume.
- Prometheus collects app, host, and Nginx metrics.
- Alerts cover service down, high CPU, high 5xx rate, and p99 latency.
