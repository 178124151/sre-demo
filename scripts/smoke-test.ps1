$ErrorActionPreference = "Stop"

$baseUrl = if ($args.Count -gt 0) { $args[0] } else { "http://localhost:8080" }

Write-Host "Checking $baseUrl/health"
Invoke-RestMethod -Uri "$baseUrl/health" | ConvertTo-Json -Depth 3

Write-Host "Checking $baseUrl/users"
Invoke-RestMethod -Uri "$baseUrl/users" | ConvertTo-Json -Depth 3

Write-Host "Smoke test passed"
