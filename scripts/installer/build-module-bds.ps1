param(
    [Parameter(Mandatory)][string]$Module,
    [Parameter(Mandatory)][string]$RootDir,
    [string]$Define = ""
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

$Projects = switch ($Module) {
    "minusframework-core" {
        "Core\Packages\MinusFramework_Runtime.dproj",
        "Core\Packages\MinusFramework_Design.dproj",
        "Cli\Source\MinusCLI.dproj"
    }
    "minusframework-orm" {
        "ORM\MinusORM.dproj"
    }
    "minusframework-migrator" {
        "Migrator\MinusMigrator_DLL.dproj",
        "Migrator\MinusMigrator_CLI.dproj",
        "Migrator\MinusMigrator_GUI.dproj"
    }
    "minusframework-featureflags" {
        "FeatureFlags\FeatureFlags\MinusFeatureFlags.dproj",
        "FeatureFlags\FeatureFlags\API\MinusFeatureFlagsAPI.dproj"
    }
    "minusframework-messaging" {
        "Messaging\Packages\MinusMessaging_Runtime.dproj",
        "Messaging\Packages\MinusMessaging_Design.dproj",
        "Messaging\MinusMessaging_CLI.dproj"
    }
    "minusframework-telemetry" {
        "Telemetry\Packages\MinusTelemetry_Runtime.dproj"
    }
    "minusframework-extensions" {
        @()
    }
    "minusframework-ai" {
        "AI\Source\MinusAI_MCP.dproj"
    }
    default { throw "Unknown module: $Module" }
}

$bdsPath = "${env:ProgramFiles(x86)}\Embarcadero\Studio\23.0\bin\bds.exe"

if (-not (Test-Path -LiteralPath $bdsPath)) {
    throw "bds.exe not found at: $bdsPath"
}

if ($Projects.Count -eq 0) {
    Write-Host "Module '$Module' has no projects to build. Skipping."
    exit 0
}

Write-Host "=== Building $Module ==="
Write-Host "Module directory : $ModuleDir"
Write-Host "Root directory   : $RootDir"
Write-Host "bds.exe path     : $bdsPath"
Write-Host "Projects:"
foreach ($proj in $Projects) {
    $fullPath = Join-Path -Path $RootDir -ChildPath $proj
    Write-Host "  - $fullPath"
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Project file not found: $fullPath"
    }
}

$localFiles = @()
if ($Define) {
    Write-Host "Injecting define(s): $Define" -ForegroundColor Cyan
    foreach ($proj in $Projects) {
        $fullPath = Join-Path -Path $RootDir -ChildPath $proj
        $localPath = $fullPath + ".local"
        $localContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <DCC_Define>$Define;`$(DCC_Define)</DCC_Define>
  </PropertyGroup>
</Project>
"@
        Set-Content -Path $localPath -Value $localContent -Encoding UTF8
        $localFiles += $localPath
        Write-Host "  Created: $localPath"
    }
}

$tempDir = Join-Path -Path $RootDir -ChildPath "tmp_bds_$ModuleDir"
[void](New-Item -ItemType Directory -Force -Path $tempDir)

$groupProjPath = Join-Path -Path $tempDir -ChildPath "build.groupproj"

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine('<?xml version="1.0" encoding="utf-8"?>')
[void]$sb.AppendLine('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
[void]$sb.AppendLine('  <ItemGroup>')
foreach ($proj in $Projects) {
    $includePath = (Join-Path -Path $RootDir -ChildPath $proj)
    [void]$sb.AppendLine("    <Projects Include=`"$includePath`"/>")
}
[void]$sb.AppendLine('  </ItemGroup>')
[void]$sb.AppendLine('</Project>')

Set-Content -Path $groupProjPath -Value $sb.ToString() -Encoding UTF8
Write-Host "Created temporary project group: $groupProjPath"

$bdsArgs = @($groupProjPath, "-b", "-ns", "-pDelphi")
Write-Host "Command: `"$bdsPath`" $($bdsArgs -join ' ')"

Write-Host "Starting build via bds.exe (this may take a while)..."
$proc = Start-Process -FilePath $bdsPath -ArgumentList $bdsArgs -Wait -PassThru
$exitCode = $proc.ExitCode

Write-Host "bds.exe exit code: $exitCode"

$hasErrors = $exitCode -ne 0

$errFiles = Get-ChildItem -Path $RootDir -Filter "*.err" -Recurse -ErrorAction SilentlyContinue
if ($errFiles) {
    $hasErrors = $true
    Write-Host "=== Delphi .err Files Found ===" -ForegroundColor Red
    foreach ($errFile in $errFiles) {
        Write-Host "  $($errFile.FullName)" -ForegroundColor Red
        $errContent = Get-Content -Path $errFile.FullName -Raw
        if ($errContent.Trim()) {
            Write-Host $errContent -ForegroundColor Red
        }
    }
}

if ($localFiles) {
    foreach ($localFile in $localFiles) {
        Remove-Item -Path $localFile -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Cleaned up .dproj.local files."
}

Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Cleaned up temporary files."

if ($hasErrors) {
    Write-Host "Build FAILED for $Module" -ForegroundColor Red
    if ($exitCode -ne 0) { exit $exitCode }
    exit 1
}

Write-Host "Build SUCCEEDED for $Module" -ForegroundColor Green
exit 0
