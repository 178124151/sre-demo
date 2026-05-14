# Kubernetes Deployment

This project keeps Docker Compose as the low-cost single-node deployment, and adds Kubernetes manifests for local demo, resume review, and production-style SRE discussion.

## What Is Included

- `Deployment` for the Flask web service with rolling updates, readiness probes, liveness probes, resource requests, and limits.
- `StatefulSet` for MySQL with persistent storage and startup/readiness/liveness probes.
- `Service` objects for stable in-cluster discovery.
- `PodDisruptionBudget` for the web service.
- Kustomize overlays for local demo and 2C2G low-resource environments.
- Prometheus-compatible alerting rules for error rate and latency.

## Local Demo With kind

```bash
kind create cluster --name sre-demo
docker build -t sre-demo-web:local ./web
kind load docker-image sre-demo-web:local --name sre-demo
kubectl apply -k k8s/overlays/local
kubectl -n sre-demo get pods -w
```

Access through NodePort:

```bash
curl http://localhost:30080/health
curl http://localhost:30080/users
```

If your local Kubernetes runtime does not expose NodePort on `localhost`, use port-forwarding:

```bash
kubectl -n sre-demo port-forward svc/sre-demo-nginx 8080:80
curl http://localhost:8080/health
```

## Low-Resource Aliyun Notes

The `k8s/overlays/aliyun-small` overlay intentionally scales the web layer down to one replica and lowers resource requests. This makes the manifests demonstrable on a small machine, but the recommended production posture is:

- Use at least 2 worker nodes before claiming high availability.
- Move MySQL to RDS or another managed database for backup, failover, and disk isolation.
- Run Prometheus/Grafana on a separate monitoring host or managed service when the app host is only 2C2G.
- Keep Compose as the actual low-cost deployment path when Kubernetes overhead is larger than the app itself.

## Interview Talking Points

- Liveness checks answer "should Kubernetes restart this process?"
- Readiness checks answer "should this pod receive traffic now?"
- `StatefulSet` is used for MySQL because the database needs stable storage identity.
- The web layer is stateless and can be rolled by `Deployment`.
- Resource requests protect scheduling; limits protect the node from noisy workloads.
- The 2C2G decision is documented as an SRE tradeoff, not a missing feature.
