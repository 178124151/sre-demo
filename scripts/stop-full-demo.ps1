$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root ".env"
if (-not (Test-Path -LiteralPath $envFile)) {
    $envFile = Join-Path $root ".env.example"
}

docker compose --env-file $envFile down -v --remove-orphans
Write-Host "Stopped Docker Compose demo"
