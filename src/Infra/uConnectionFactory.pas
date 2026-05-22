unit uConnectionFactory;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.IniFiles,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait;

type
  EConnectionConfigError = class(Exception);

  TConnectionFactory = class
  strict private
    class var FDriverLink: TFDPhysFBDriverLink;
    class function ResolveConfigPath: string;
    class function RequireValue(const AIni: TIniFile; const ASection, AKey: string): string;
    class procedure EnsureDriverLink(const AVendorLib: string);
  public
    class function CreateConnection: TFDConnection;
    class destructor Destroy;
  end;

implementation

const
  CONFIG_FILE_NAME = 'config.ini';
  SECTION_DATABASE = 'Database';

{ TConnectionFactory }

class function TConnectionFactory.ResolveConfigPath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), CONFIG_FILE_NAME);
end;

class function TConnectionFactory.RequireValue(const AIni: TIniFile;
  const ASection, AKey: string): string;
begin
  Result := Trim(AIni.ReadString(ASection, AKey, ''));
  if Result = '' then
    raise EConnectionConfigError.CreateFmt(
      'Parametro obrigatorio ausente em config.ini: [%s] %s', [ASection, AKey]);
end;

class procedure TConnectionFactory.EnsureDriverLink(const AVendorLib: string);
begin
  if FDriverLink = nil then
    FDriverLink := TFDPhysFBDriverLink.Create(nil);
  FDriverLink.VendorLib := AVendorLib;
end;

class function TConnectionFactory.CreateConnection: TFDConnection;
var
  LConfigPath, LDatabase, LUser, LPassword, LServer, LPort, LClientLib: string;
  LIni: TIniFile;
begin
  LConfigPath := ResolveConfigPath;
  if not TFile.Exists(LConfigPath) then
    raise EConnectionConfigError.CreateFmt(
      'Arquivo de configuracao nao encontrado: %s. ' +
      'Copie config.ini.example para config.ini e ajuste os valores.',
      [LConfigPath]);

  LIni := TIniFile.Create(LConfigPath);
  try
    LDatabase  := RequireValue(LIni, SECTION_DATABASE, 'Database');
    LUser      := RequireValue(LIni, SECTION_DATABASE, 'Username');
    LPassword  := LIni.ReadString(SECTION_DATABASE, 'Password', '');
    LServer    := RequireValue(LIni, SECTION_DATABASE, 'Server');
    LPort      := RequireValue(LIni, SECTION_DATABASE, 'Port');
    LClientLib := RequireValue(LIni, SECTION_DATABASE, 'ClientLibrary');
  finally
    LIni.Free;
  end;

  if not TFile.Exists(LClientLib) then
    raise EConnectionConfigError.CreateFmt(
      'fbclient.dll nao encontrado em: %s', [LClientLib]);

  EnsureDriverLink(LClientLib);

  Result := TFDConnection.Create(nil);
  try
    Result.LoginPrompt := False;
    Result.Params.Clear;
    Result.Params.Add('DriverID=FB');
    Result.Params.Add('Database=' + LDatabase);
    Result.Params.Add('User_Name=' + LUser);
    Result.Params.Add('Password=' + LPassword);
    Result.Params.Add('Server=' + LServer);
    Result.Params.Add('Port=' + LPort);
    Result.Params.Add('CharacterSet=UTF8');
    Result.Params.Add('Protocol=TCPIP');
    Result.Connected := True;
  except
    Result.Free;
    raise;
  end;
end;

class destructor TConnectionFactory.Destroy;
begin
  FreeAndNil(FDriverLink);
end;

end.
