$ErrorActionPreference = "Stop"

Write-Host "=== Telemetry Integration Test ===" -ForegroundColor Cyan

# 1. Health check
Write-Host "Checking health..."
$health = Invoke-RestMethod -Uri "http://localhost:9082/health" -TimeoutSec 5
if ($health.status -ne "ok") { throw "Health check failed" }
Write-Host "  PASS" -ForegroundColor Green

# 2. Get config
Write-Host "Getting config..."
$config = Invoke-RestMethod -Uri "http://localhost:9082/api/v1/config" -TimeoutSec 5
if (-not $config.flush_interval_seconds) { throw "Config missing flush_interval_seconds" }
Write-Host "  PASS" -ForegroundColor Green

# 3. Ingest a trace
Write-Host "Ingesting trace..."
$traceBody = @{
    trace_id = "abc123"
    spans = @(@{
        span_id = "span1"
        parent_span_id = ""
        operation_name = "test.op"
        service_name = "test-svc"
        span_kind = "internal"
        start_time = "2026-07-15T00:00:00Z"
        end_time = "2026-07-15T00:00:01Z"
        status = "ok"
    })
} | ConvertTo-Json
$traceResult = Invoke-RestMethod -Uri "http://localhost:9082/v1/traces" `
    -Method POST `
    -Body $traceBody `
    -ContentType "application/json" `
    -Headers @{"X-API-Key" = "MF-TEST-KEY"} `
    -TimeoutSec 5
if ($traceResult.accepted -ne 1) { throw "Trace not accepted" }
Write-Host "  PASS" -ForegroundColor Green

# 4. Ingest a metric
Write-Host "Ingesting metric..."
$metricBody = @{
    metric_name = "requests_total"
    metric_type = "counter"
    value = 1
    tags = @{method = "GET"}
    timestamp = "2026-07-15T00:00:00Z"
} | ConvertTo-Json
$metricResult = Invoke-RestMethod -Uri "http://localhost:9082/v1/metrics" `
    -Method POST `
    -Body $metricBody `
    -ContentType "application/json" `
    -Headers @{"X-API-Key" = "MF-TEST-KEY"} `
    -TimeoutSec 5
if ($metricResult.accepted -ne $true) { throw "Metric not accepted" }
Write-Host "  PASS" -ForegroundColor Green

# 5. Verify rejection without API key
Write-Host "Verifying auth rejection..."
try {
    $null = Invoke-RestMethod -Uri "http://localhost:9082/v1/traces" `
        -Method POST `
        -Body '{"trace_id":"xyz","spans":[]}' `
        -ContentType "application/json" `
        -TimeoutSec 5
    throw "Expected 401 but got success"
} catch {
    if ($_.Exception.Response.StatusCode -ne 401) { throw "Expected 401, got $($_.Exception.Response.StatusCode)" }
}
Write-Host "  PASS" -ForegroundColor Green

Write-Host "=== All telemetry tests passed ===" -ForegroundColor Cyan
