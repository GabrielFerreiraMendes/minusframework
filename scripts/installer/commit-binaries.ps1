param(
    [Parameter(Mandatory)][string]$Module
)

$ErrorActionPreference = "Stop"

$ModuleDir = switch ($Module) {
    "minusframework-core"         { "Core" }
    "minusframework-orm"          { "ORM" }
    "minusframework-migrator"     { "Migrator" }
    "minusframework-featureflags" { "FeatureFlags" }
    "minusframework-messaging"    { "Messaging" }
    "minusframework-telemetry"    { "Telemetry" }
    "minusframework-extensions"   { "Extensions" }
    "minusframework-ai"           { "AI" }
    default { throw "Unknown module: $Module" }
}

$repoDir = "C:\Dev\minusframework-$ModuleDir"
if (-not (Test-Path $repoDir)) {
    $repoDir = "C:\Dev\$Module"
}
if (-not (Test-Path $repoDir)) {
    throw "Repo directory not found for $Module"
}

$prebuiltDir = Join-Path $repoDir "Prebuilt"
Write-Host "=== commit-binaries: $Module ==="
Write-Host "Repo: $repoDir"
Write-Host "Prebuilt: $prebuiltDir"

$bplDir = "$env:PUBLIC\Documents\Embarcadero\Studio\23.0\Bpl"
$dcpDir = "$env:PUBLIC\Documents\Embarcadero\Studio\23.0\Dcp"

switch ($Module) {
    "minusframework-core" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bpl", "$prebuiltDir\Dcp" | Out-Null
        Copy-Item "$bplDir\MinusFramework_Runtime.bpl" "$prebuiltDir\Bpl\" -ErrorAction Stop
        Copy-Item "$bplDir\MinusFramework_Design.bpl"  "$prebuiltDir\Bpl\" -ErrorAction Stop
        Copy-Item "$dcpDir\MinusFramework_Runtime.dcp" "$prebuiltDir\Dcp\" -ErrorAction Stop
        Copy-Item "$dcpDir\MinusFramework_Design.dcp"  "$prebuiltDir\Dcp\" -ErrorAction Stop
    }
    "minusframework-telemetry" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bpl", "$prebuiltDir\Dcp" | Out-Null
        Copy-Item "$bplDir\MinusTelemetry_Runtime.bpl" "$prebuiltDir\Bpl\" -ErrorAction Stop
        Copy-Item "$dcpDir\MinusTelemetry_Runtime.dcp" "$prebuiltDir\Dcp\" -ErrorAction Stop
    }
    "minusframework-messaging" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bpl", "$prebuiltDir\Dcp", "$prebuiltDir\Bin" | Out-Null
        Copy-Item "$bplDir\MinusMessaging_Runtime.bpl" "$prebuiltDir\Bpl\" -ErrorAction Stop
        Copy-Item "$bplDir\MinusMessaging_Design.bpl"   "$prebuiltDir\Bpl\" -ErrorAction Stop
        Copy-Item "$dcpDir\MinusMessaging_Runtime.dcp" "$prebuiltDir\Dcp\" -ErrorAction Stop
        Copy-Item "$dcpDir\MinusMessaging_Design.dcp"   "$prebuiltDir\Dcp\" -ErrorAction Stop
        Copy-Item "$repoDir\Win32\Debug\MinusMessaging_CLI.exe" "$prebuiltDir\Bin\" -ErrorAction Stop
    }
    "minusframework-orm" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bin", "$prebuiltDir\Samples" | Out-Null
        Copy-Item "$repoDir\Win32\Debug\MinusORM.dll" "$prebuiltDir\Bin\" -ErrorAction Stop
        Copy-Item "$repoDir\ORM\Samples\MinusDemo\*.pas" "$prebuiltDir\Samples\" -ErrorAction SilentlyContinue
        Copy-Item "$repoDir\ORM\Samples\MinusDemo\*.dfm" "$prebuiltDir\Samples\" -ErrorAction SilentlyContinue
    }
    "minusframework-migrator" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bin" | Out-Null
        Copy-Item "$repoDir\Win32\Debug\MinusMigrator_DLL.dll" "$prebuiltDir\Bin\" -ErrorAction Stop
        Copy-Item "$repoDir\Win32\Debug\MinusMigrator_CLI.exe" "$prebuiltDir\Bin\" -ErrorAction Stop
        Copy-Item "$repoDir\Win32\Debug\MinusMigrator_GUI.exe" "$prebuiltDir\Bin\" -ErrorAction Stop
    }
    "minusframework-featureflags" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bin" | Out-Null
        Copy-Item "$repoDir\Win32\Debug\MinusFeatureFlags.exe"    "$prebuiltDir\Bin\" -ErrorAction Stop
        Copy-Item "$repoDir\Win32\Debug\MinusFeatureFlagsAPI.exe" "$prebuiltDir\Bin\" -ErrorAction Stop
    }
    "minusframework-ai" {
        New-Item -ItemType Directory -Force -Path "$prebuiltDir\Bin" | Out-Null
        Copy-Item "$repoDir\Win32\Debug\MinusAI_MCP.exe" "$prebuiltDir\Bin\" -ErrorAction Stop
    }
    "minusframework-extensions" {
        # Extensions has no build output (source-only wrappers)
        Write-Host "Extensions: no build artifacts to commit."
    }
}

Write-Host "Done. Prebuilt files in $prebuiltDir"
Get-ChildItem -Recurse $prebuiltDir -File | ForEach-Object { Write-Host "  $($_.FullName)" }
