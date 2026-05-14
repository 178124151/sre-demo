# Runbook: High Latency

## Impact

Requests are still succeeding, but users may see slow responses.

## Triage

```bash
kubectl -n sre-demo top pods
kubectl -n sre-demo get endpoints sre-demo-web
kubectl -n sre-demo logs deploy/sre-demo-web --tail=100
```

For Docker Compose:

```bash
docker stats
docker compose logs --tail=100 nginx flask1 flask2 mysql
```

## Common Causes

- CPU throttling on the web container.
- Slow MySQL queries or disk pressure.
- One unhealthy instance still receiving traffic.
- Host load is too high for 2C2G capacity.

## Mitigation

- Reduce traffic or scale web replicas if capacity is available.
- Restart a single bad instance only after confirming it is isolated.
- Move MySQL to RDS if database and app compete for the same small host.
- Increase resource requests/limits when throttling is confirmed.
