$ErrorActionPreference = "Stop"
Write-Host "=== Integration Test ==="

# 1. Health checks
Write-Host "Checking License Server health..."
$health = Invoke-RestMethod -Uri "http://localhost:9080/health"
if ($health.status -ne "ok") { throw "License Server health failed" }

Write-Host "Checking MinusAI Review health..."
$health = Invoke-RestMethod -Uri "http://localhost:9081/health"
if ($health.status -ne "ok") { throw "MinusAI Review health failed" }

Write-Host "All health checks passed"
Write-Host "=== All tests passed ==="
