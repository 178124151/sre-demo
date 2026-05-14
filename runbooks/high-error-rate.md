# Runbook: High HTTP 5xx Rate

## Impact

Users are receiving server errors. This may be caused by database failure, app exceptions, or bad deployment.

## Triage

```bash
kubectl -n sre-demo get pods -o wide
kubectl -n sre-demo logs deploy/sre-demo-web --tail=100
kubectl -n sre-demo logs statefulset/mysql --tail=100
curl -i http://localhost:30080/ready
```

For Docker Compose:

```bash
docker compose ps
docker compose logs --tail=100 flask1 flask2 mysql
curl -i http://localhost:8080/ready
```

## Mitigation

- If `/ready` fails, check MySQL status and credentials.
- If only one web pod is failing, restart or roll back the web deployment.
- If errors started after a release, roll back to the previous image.
- If MySQL disk is full, free disk space or expand the volume before restarting.

## Follow-Up

- Add a regression test for the failed route.
- Attach logs and the Prometheus graph to the incident note.
- Record whether the alert was actionable or noisy.
