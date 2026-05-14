$ErrorActionPreference = "Stop"

docker compose config | Out-Null

if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl kustomize k8s/overlays/local | Out-Null
    kubectl kustomize k8s/overlays/aliyun-small | Out-Null
} else {
    Write-Host "kubectl not found; skipped kustomize validation"
}

Write-Host "Validation completed"
