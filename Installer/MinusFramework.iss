;==============================================================================
; MinusFramework Installer
; Copyright (c) 2026 MinusFramework
; https://minusframework.com.br
;
; Build: rode .\build-installer.ps1 para preparar o staging e compilar
;==============================================================================

#define AppName "MinusFramework"
#define AppVersion "0.1.0"
#define AppPublisher "MinusFramework"
#define AppURL "https://minusframework.com.br"
#define AppSupportURL "https://minusframework.com.br/suporte"

[Setup]
AppId={{B4F2A3D1-7C8E-4F9A-B2D3-E5F6A7B8C9D0}}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppSupportURL}
DefaultDirName={code:GetDefaultInstallDir}
DefaultGroupName={#AppName}
AllowNoIcons=yes
LicenseFile=Staging\Docs\LICENSE
OutputDir=..\Dist
OutputBaseFilename=MinusFramework-{#AppVersion}-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
DisableWelcomePage=no
PrivilegesRequired=admin

[Types]
Name: "full";    Description: "Instalacao completa (todos os componentes)"
Name: "custom";  Description: "Instalacao customizada"; Flags: iscustom

[Components]
Name: "runtime"; Description: "Runtime (BPLs e DCPs)"; Types: full custom; Flags: fixed
Name: "sources"; Description: "Codigo fonte (Source\*.pas)"; Types: full
Name: "ide";     Description: "Componentes de Design-Time (IDE)"; Types: full
Name: "docs";    Description: "Documentacao e exemplos"; Types: full
Name: "cli";     Description: "Ferramentas de linha de comando (CLI)"; Types: full

[Files]

; --- Runtime BPLs ---
Source: "Staging\Bpl\*_Runtime.bpl";   DestDir: "{code:GetBplDir|23.0}"; Components: runtime; Flags: ignoreversion skipifsourcedoesntexist

; --- Design BPLs ---
Source: "Staging\Bpl\*_Design.bpl";    DestDir: "{code:GetBplDir|23.0}"; Components: ide; Flags: ignoreversion skipifsourcedoesntexist

; --- DCPs ---
Source: "Staging\Dcp\*.dcp";           DestDir: "{code:GetDcpDir|23.0}"; Components: runtime; Flags: ignoreversion skipifsourcedoesntexist

; --- Source files ---
Source: "Staging\Source\*";            DestDir: "{app}\Source"; Components: sources; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; --- CLI tools ---
Source: "Staging\Bin\*";               DestDir: "{app}\Bin";    Components: cli; Flags: ignoreversion skipifsourcedoesntexist

; --- Documentation ---
Source: "Staging\Docs\*";              DestDir: "{app}\Docs";   Components: docs; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

; --- Samples ---
Source: "Staging\Samples\*";           DestDir: "{app}\Samples"; Components: docs; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

[Code]

// License validation constants
const
  LicenseServerUrl = 'https://license.minusframework.dev';
  TrialDays = 30;

var
  LicenseKeyPage: TInputQueryWizardPage;
  LicenseKeyValue: string;

function GetBplDir(Version: string): string;
begin
  Result := ExpandConstant('{commonappdata}\Embarcadero\Studio\' + Version + '\Bpl');
end;

function GetDcpDir(Version: string): string;
begin
  Result := ExpandConstant('{commonappdata}\Embarcadero\Studio\' + Version + '\Dcp');
end;

function GetDefaultInstallDir(Param: string): string;
begin
  Result := ExpandConstant('{pf}\MinusFramework');
end;

function ValidateLicense(Key: string): Boolean;
var
  ResultCode: Integer;
  TempFile: string;
  ScriptPath: string;
begin
  Result := True;

  if Key = '' then
  begin
    MsgBox('No license key entered. A 30-day trial will begin after installation.',
      mbInformation, MB_OK);
    Exit;
  end;

  ScriptPath := ExpandConstant('{src}\scripts\installer-license-check.ps1');
  if not FileExists(ScriptPath) then
  begin
    MsgBox('License validation script not found. Proceeding without validation.',
      mbError, MB_OK);
    Exit;
  end;

  TempFile := ExpandConstant('{tmp}\license_result.txt');
  if Exec('powershell.exe',
    '-NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '" ' +
    '-LicenseKey "' + Key + '" -LicenseServerUrl "' + LicenseServerUrl + '" > "' +
    TempFile + '" 2>&1',
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  then
  begin
    if ResultCode = 0 then
    begin
      Result := True;
    end
      else
    begin
      MsgBox('License validation failed (code ' + IntToStr(ResultCode) +
        '). Please check your license key and try again.', mbError, MB_OK);
      Result := False;
    end;
  end
    else
  begin
    MsgBox('Unable to run license validation. Proceeding with offline mode.',
      mbError, MB_OK);
    Result := True;
  end;
end;

procedure InitializeWizard;
begin
  LicenseKeyPage := CreateInputQueryPage(
    wpLicense,
    'License Key',
    'Enter your MinusFramework license key',
    'If you have a license key, enter it below. Leave blank to start a 30-day trial.'#13#10 +
    'Your license key can be found in your MinusFramework account at ' +
    LicenseServerUrl + '.'
  );
  LicenseKeyPage.Add('License Key:', False);
  LicenseKeyPage.Values[0] := '';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = LicenseKeyPage.ID then
  begin
    LicenseKeyValue := LicenseKeyPage.Values[0];
    Result := ValidateLicense(LicenseKeyValue);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LicensePath: string;
begin
  if CurStep = ssPostInstall then
  begin
    LicensePath := ExpandConstant('{app}\license.key');
    if LicenseKeyValue <> '' then
      SaveStringToFile(LicensePath, LicenseKeyValue, False);
  end;
end;

[Icons]
Name: "{group}\Documentacao";      Filename: "{app}\Docs"
Name: "{group}\Site do Produto";   Filename: "{#AppURL}"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
