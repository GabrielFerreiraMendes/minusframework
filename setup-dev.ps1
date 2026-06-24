#==============================================================================
# setup-dev.ps1 — Inicializa os submódulos privados do MinusFrameWork
#==============================================================================
# Uso:
#   1. Clone o meta-repo publicamente:
#      git clone https://github.com/GabrielFerreiraMendes/minusframework-meta.git
#
#   2. Execute este script para inicializar os submódulos privados:
#      .\setup-dev.ps1
#
#   Requer um Personal Access Token (PAT) com acesso aos repositórios privados.
#   O PAT pode ser passado como parâmetro ou via variável de ambiente GH_PAT.
#==============================================================================

param(
    [string]$Token = $env:GH_PAT,
    [string]$Org = "GabrielFerreiraMendes"
)

$ErrorActionPreference = "Stop"

if (-not $Token) {
    Write-Host "ERRO: Informe um PAT ou defina a variável de ambiente GH_PAT." -ForegroundColor Red
    Write-Host "Crie em: https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host "`nUso: .\setup-dev.ps1 -Token ghp_xxxx" -ForegroundColor Yellow
    exit 1
}

$Repos = @(
    "minusframework-core",
    "minusframework-telemetry",
    "minusframework-messaging",
    "minusframework-orm",
    "minusframework-migrator",
    "minusframework-featureflags",
    "minusframework-extensions",
    "MinusAI"
)

$DirMap = @{
    "minusframework-core"          = "Core"
    "minusframework-telemetry"     = "Telemetry"
    "minusframework-messaging"     = "Messaging"
    "minusframework-orm"           = "ORM"
    "minusframework-migrator"      = "Migrator"
    "minusframework-featureflags"  = "FeatureFlags"
    "minusframework-extensions"    = "Extensions"
    "MinusAI"                      = "MinusAI"
}

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RootDir

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MinusFrameWork — Setup Dev Environment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Create .gitmodules
$gitmodules = @()
foreach ($repo in $Repos) {
    $dir = $DirMap[$repo]
    $url = "https://github.com/$Org/$repo.git"
    $gitmodules += "[submodule `"$dir`"]"
    $gitmodules += "`tpath = $dir"
    $gitmodules += "`turl = $url"
    $gitmodules += ""
}
$gitmodulesPath = Join-Path $RootDir ".gitmodules"
$gitmodules -join "`r`n" | Set-Content $gitmodulesPath -Encoding UTF8
Write-Host ".gitmodules criado." -ForegroundColor Green

# Initialize submodules
Write-Host "`nInicializando submódulos..." -ForegroundColor Yellow
$authUrl = "https://x-access-token:${Token}@github.com/$Org"

foreach ($repo in $Repos) {
    $dir = $DirMap[$repo]
    $dirPath = Join-Path $RootDir $dir

    if (Test-Path (Join-Path $dirPath ".git")) {
        Write-Host "  $dir — já inicializado" -ForegroundColor Green
        continue
    }

    Write-Host "  $dir — clonando..." -ForegroundColor Yellow
    $cloneUrl = "https://x-access-token:${Token}@github.com/$Org/$repo.git"
    
    # Remove placeholder files
    Remove-Item "$dirPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    git clone $cloneUrl $dirPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERRO: falha ao clonar $repo" -ForegroundColor Red
        exit 1
    }
    Write-Host "  $dir — OK" -ForegroundColor Green
}

Write-Host "`nAmbiente de desenvolvimento pronto!" -ForegroundColor Green
Write-Host "Execute o setup do Installer manualmente se necessário:" -ForegroundColor Cyan
Write-Host "  .\Installer\download-deps.ps1 -All" -ForegroundColor White
