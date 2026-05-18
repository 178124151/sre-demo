$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

Push-Location $root
try {
    python -m py_compile web\app.py
    docker compose --env-file .env.example config | Out-Null
    Write-Host "Compose project validation completed"
} finally {
    Pop-Location
}
