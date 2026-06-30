unit MF.LicenseManager;

interface

type
  TLicenseTier = (ltFree, ltPro, ltEnterprise);

  TLicenseInfo = record
    Tier: TLicenseTier;
    CustomerName: string;
    CustomerEmail: string;
    ExpiresAt: TDateTime;
    IsValid: Boolean;
    ErrorMessage: string;
  end;

  TLicenseManager = class
  strict private
    class var FCertDer: TBytes;
    class function ExtractPayload(const Key: string; out Payload, Signature: TBytes): Boolean;
    class function DecodePayload(const Payload: TBytes): TLicenseInfo;
    class function VerifyRsaSha256(const Data, Signature: TBytes): Boolean;
    class function GetDefaultCertBytes: TBytes;
  public
    class constructor Create;
    class function Validate(const Key: string): TLicenseInfo;
    class function CanAccess(const Tier, MinimumTier: TLicenseTier): Boolean; static;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  System.JSON,
  System.NetEncoding;

const
  RSA_PUBLIC_KEY_B64 =
    'MIIF...'; { substituir pela saida de generate-keys.js }

function CryptStringToBinaryWrapper(const s: string): TBytes;
var
  dwSkip, dwFlags: DWORD;
  cbBinary: DWORD;
begin
  dwSkip := 0;
  dwFlags := CRYPT_STRING_BASE64_ANY;
  if not CryptStringToBinary(PChar(s), Length(s), dwFlags, nil, @cbBinary, @dwSkip, nil) then
    RaiseLastOSError;
  SetLength(Result, cbBinary);
  if not CryptStringToBinary(PChar(s), Length(s), dwFlags, @Result[0], @cbBinary, @dwSkip, nil) then
    RaiseLastOSError;
end;

{ TLicenseManager }

class constructor TLicenseManager.Create;
begin
  FCertDer := CryptStringToBinaryWrapper(RSA_PUBLIC_KEY_B64);
end;

class function TLicenseManager.ExtractPayload(const Key: string; out Payload, Signature: TBytes): Boolean;
var
  DotPos: Integer;
begin
  Result := False;
  DotPos := Pos('.', Key);
  if DotPos = 0 then Exit;
  Payload := TNetEncoding.Base64URL.DecodeStringToBytes(Copy(Key, 1, DotPos - 1));
  Signature := TNetEncoding.Base64URL.DecodeStringToBytes(Copy(Key, DotPos + 1));
  Result := (Length(Payload) > 0) and (Length(Signature) > 0);
end;

class function TLicenseManager.DecodePayload(const Payload: TBytes): TLicenseInfo;
var
  Json: string;
  Obj: TJSONObject;
  TierStr: string;
begin
  Result.IsValid := False;
  Result.ErrorMessage := '';
  Json := TEncoding.UTF8.GetString(Payload);
  Obj := TJSONObject.ParseJSONValue(Json) as TJSONObject;
  if Obj = nil then
  begin
    Result.ErrorMessage := 'Formato invalido';
    Exit;
  end;
  try
    TierStr := Obj.GetValue('tier', '');
    if TierStr = 'FREE' then Result.Tier := ltFree
    else if TierStr = 'PRO' then Result.Tier := ltPro
    else if TierStr = 'ENTERPRISE' then Result.Tier := ltEnterprise
    else begin
      Result.ErrorMessage := 'Tier desconhecido: ' + TierStr;
      Exit;
    end;
    Result.CustomerName := Obj.GetValue('customer', '');
    Result.CustomerEmail := Obj.GetValue('email', '');
    Result.ExpiresAt := StrToDateDef(Obj.GetValue('expires', ''), 0);
    Result.IsValid := Result.ExpiresAt >= Date;
    if not Result.IsValid then
      Result.ErrorMessage := 'Licenca expirada';
  finally
    Obj.Free;
  end;
end;

class function TLicenseManager.VerifyRsaSha256(const Data, Signature: TBytes): Boolean;
var
  hProv: HCRYPTPROV;
  hKey: HCRYPTKEY;
  hHash: HCRYPTHASH;
  PubKeyInfo: CERT_PUBLIC_KEY_INFO;
  cbPubKeyInfo: DWORD;
  pPubKeyInfo: PCERT_PUBLIC_KEY_INFO;
begin
  Result := False;

  if not CryptAcquireContext(hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
    Exit;
  try
    cbPubKeyInfo := 0;
    CryptDecodeObjectEx(X509_ASN_ENCODING, X509_PUBLIC_KEY_INFO,
      @FCertDer[0], Length(FCertDer), 0, nil, nil, @cbPubKeyInfo);
    if cbPubKeyInfo = 0 then Exit;
    GetMem(pPubKeyInfo, cbPubKeyInfo);
    try
      if not CryptDecodeObjectEx(X509_ASN_ENCODING, X509_PUBLIC_KEY_INFO,
        @FCertDer[0], Length(FCertDer), 0, nil, pPubKeyInfo, @cbPubKeyInfo) then
        Exit;
      if not CryptImportPublicKeyInfo(hProv, X509_ASN_ENCODING, pPubKeyInfo, hKey) then
        Exit;
      try
        if not CryptCreateHash(hProv, CALG_SHA256, 0, 0, hHash) then
          Exit;
        try
          if not CryptHashData(hHash, @Data[0], Length(Data), 0) then
            Exit;
          Result := CryptVerifySignature(hHash, @Signature[0], Length(Signature), hKey, nil, 0);
        finally
          CryptDestroyHash(hHash);
        end;
      finally
        CryptDestroyKey(hKey);
      end;
    finally
      FreeMem(pPubKeyInfo);
    end;
  finally
    CryptReleaseContext(hProv, 0);
  end;
end;

class function TLicenseManager.GetDefaultCertBytes: TBytes;
begin
  Result := FCertDer;
end;

class function TLicenseManager.Validate(const Key: string): TLicenseInfo;
var
  Payload, Signature: TBytes;
begin
  Result.IsValid := False;
  Result.ErrorMessage := '';
  if not ExtractPayload(Key, Payload, Signature) then
  begin
    Result.ErrorMessage := 'Chave invalida';
    Exit;
  end;
  if not VerifyRsaSha256(Payload, Signature) then
  begin
    Result.ErrorMessage := 'Assinatura invalida';
    Exit;
  end;
  Result := DecodePayload(Payload);
end;

class function TLicenseManager.CanAccess(const Tier, MinimumTier: TLicenseTier): Boolean;
begin
  Result := Ord(Tier) >= Ord(MinimumTier);
end;

end.
