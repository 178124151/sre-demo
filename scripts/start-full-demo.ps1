$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root ".env"
if (-not (Test-Path -LiteralPath $envFile)) {
    $envFile = Join-Path $root ".env.example"
}

function Get-EnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [string]$DefaultValue = ""
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $DefaultValue
    }

    $pattern = "^\s*" + [Regex]::Escape($Key) + "=(.*)$"
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match $pattern) {
            return $matches[1].Trim()
        }
    }

    return $DefaultValue
}

$grafanaPassword = Get-EnvValue -Path $envFile -Key "GRAFANA_PASSWORD" -DefaultValue "admin123"

foreach ($cmd in @("docker")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "$cmd is required but was not found in PATH."
    }
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
docker info | Out-Null
$dockerInfoExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($dockerInfoExitCode -ne 0) {
    throw "Docker daemon is not available. Please start Docker Desktop and wait until 'docker info' succeeds."
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Description,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Script
    )

    Write-Host $Description
    & $Script
    if ($LASTEXITCODE -ne 0) {
        throw "Step failed: $Description"
    }
}

function Show-ComposeDiagnostics {
    Write-Host ""
    Write-Host "Docker Compose diagnostics:"
    docker compose --env-file $envFile ps
    docker compose --env-file $envFile logs --tail=80 mysql flask1 flask2 nginx prometheus grafana node-exporter nginx-exporter
}

function Get-ContainerState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ContainerName
    )

    $status = docker inspect -f "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}" $ContainerName 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }
    return ($status | Out-String).Trim()
}

function Wait-ContainerState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ContainerName,
        [Parameter(Mandatory = $true)]
        [string]$DesiredState,
        [int]$TimeoutSeconds = 180
    )

    Write-Host "Waiting for container '$ContainerName' to become $DesiredState..."
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $lastState = ""

    while ((Get-Date) -lt $deadline) {
        $state = Get-ContainerState $ContainerName
        if (-not $state) {
            $state = "missing"
        }

        if ($state -ne $lastState) {
            Write-Host "  ${ContainerName}: $state"
            $lastState = $state
        }

        if ($state -eq $DesiredState) {
            Write-Host "  $ContainerName is $DesiredState"
            return
        }

        Start-Sleep -Seconds 5
    }

    Show-ComposeDiagnostics
    throw "Timed out waiting for $ContainerName to become $DesiredState"
}

function Wait-HttpOk {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [int]$TimeoutSeconds = 120
    )

    Write-Host "Checking $Url ..."
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                Write-Host "  $Url is reachable"
                return
            }
        } catch {
        }

        Start-Sleep -Seconds 5
    }

    throw "Timed out waiting for HTTP endpoint: $Url"
}

try {
    Write-Host "Using environment file: $envFile"
    Invoke-Step "Starting full Docker Compose demo..." {
        docker compose --env-file $envFile up -d --build --remove-orphans
    }
} catch {
    Show-ComposeDiagnostics
    throw
}

Wait-ContainerState -ContainerName "mysql" -DesiredState "healthy" -TimeoutSeconds 240
Wait-ContainerState -ContainerName "flask1" -DesiredState "healthy" -TimeoutSeconds 180
Wait-ContainerState -ContainerName "flask2" -DesiredState "healthy" -TimeoutSeconds 180
Wait-ContainerState -ContainerName "nginx" -DesiredState "healthy" -TimeoutSeconds 180
Wait-ContainerState -ContainerName "prometheus" -DesiredState "healthy" -TimeoutSeconds 180
Wait-ContainerState -ContainerName "grafana" -DesiredState "healthy" -TimeoutSeconds 180

Wait-HttpOk -Url "http://localhost:8080/health" -TimeoutSeconds 60
Wait-HttpOk -Url "http://localhost:9090/-/ready" -TimeoutSeconds 60
Wait-HttpOk -Url "http://localhost:3000/api/health" -TimeoutSeconds 60

Write-Host ""
Write-Host "SRE Demo is ready:"
Write-Host "  Web:        http://localhost:8080"
Write-Host "  Prometheus: http://localhost:9090"
Write-Host "  Grafana:    http://localhost:3000"
Write-Host "  Grafana credentials: admin / $grafanaPassword"
