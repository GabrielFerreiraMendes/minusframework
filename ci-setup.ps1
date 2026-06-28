param([string]$Token)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

if ($Token) {
    $escapedToken = [Uri]::EscapeDataString($Token)
    git -C $Root submodule update --init --recursive 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Submodule update failed. Retrying with auth..." -ForegroundColor Yellow
        $configPath = "$Root\.gitmodules"
        $content = Get-Content $configPath -Raw
        $content = $content -replace 'https://github\.com/',"https://GabrielFerreiraMendes:${escapedToken}@github.com/"
        $content | Set-Content $configPath -NoNewline
        git -C $Root submodule update --init --recursive 2>&1
        $exitCode = $LASTEXITCODE
        git -C $Root checkout -- .gitmodules
        if ($exitCode -ne 0) { throw "git submodule update failed" }
    }
} else {
    git -C $Root submodule update --init --recursive
    if ($LASTEXITCODE -ne 0) { throw "git submodule update failed" }
}
