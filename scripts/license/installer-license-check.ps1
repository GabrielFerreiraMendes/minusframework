param(
    [Parameter(Mandatory)]
    [string]$LicenseKey,
    [string]$LicenseServerUrl = "https://license.minusframework.dev"
)

try {
    $body = @{
        license_key = $LicenseKey
        device_id   = "installer-$env:COMPUTERNAME-$([System.Guid]::NewGuid().ToString().Substring(0,8))"
        device_name = $env:COMPUTERNAME
    }
    $response = Invoke-RestMethod `
        -Uri "$LicenseServerUrl/licenses/validate" `
        -Method POST `
        -Body ($body | ConvertTo-Json) `
        -ContentType "application/json" `
        -TimeoutSec 10

    if ($response.valid) {
        Write-Host "License validated: $($response.license_type)" -ForegroundColor Green
        exit 0
    } else {
        Write-Error "License invalid: $($response.error)"
        exit 1
    }
}
catch {
    $localLicensePath = "$env:PROGRAMDATA\MinusFrameWork\license.bin"
    if (Test-Path $localLicensePath) {
        Write-Host "Using offline license file" -ForegroundColor Yellow
        exit 0
    }
    Write-Error "Cannot validate license (offline and no license file): $_"
    exit 2
}
