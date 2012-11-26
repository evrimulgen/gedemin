
unit gd_GlobalParams_unit;

interface

uses
  Classes, Windows, IniFiles;

type
  Tgd_GlobalParams = class(TObject)
  private
    FLocalAddDataDir: String;
    FNetworkDrive: Boolean;
    FCDROMDrive: Boolean;
    FSecondaryInstance: Boolean;
    FUpdateToken: String;
    FIniFileName: String;
    FIniFile: TIniFile;

    procedure ReadFromIniFile;

  public
    constructor Create;
    destructor Destroy; override;

    function GetServerBindings: String;
    function GetRemoteServer: String;
    function GetWebServerActive: Boolean;

    property LocalAppDataDir: String read FLocalAddDataDir;
    property NetworkDrive: Boolean read FNetworkDrive;
    property CDROMDrive: Boolean read FCDROMDrive;
    property SecondaryInstance: Boolean read FSecondaryInstance write FSecondaryInstance;
    property UpdateToken: String read FUpdateToken;

    property IniFileName: String read FIniFileName;
  end;

var
  gd_GlobalParams: Tgd_GlobalParams;

implementation

uses
  Forms, SysUtils, FileCtrl, jclShell,
  gd_directories_const, gd_CmdLineParams_unit;

{ Tgd_GlobalParams }

constructor Tgd_GlobalParams.Create;
const
  CSIDL_LOCAL_APPDATA = $001c;
var
  DriveType: Integer;
begin
  inherited;
  FLocalAddDataDir := IncludeTrailingBackslash(
    GetSpecialFolderLocation(CSIDL_LOCAL_APPDATA)) + 'Gedemin';
  if not DirectoryExists(FLocalAddDataDir) then
    CreateDir(FLocalAddDataDir);
  DriveType := GetDriveType(PChar(
    IncludeTrailingBackslash(ExtractFileDrive(Application.ExeName))));
  FNetworkDrive := DriveType = DRIVE_REMOTE;
  FCDROMDrive := DriveType = DRIVE_CDROM;
  if FNetworkDrive or FCDROMDrive then
    FIniFileName := IncludeTrailingBackslash(FLocalAddDataDir)
  else
    FIniFileName := ExtractFilePath(Application.EXEName);
  FIniFileName := FIniFileName + 'gedemin.ini';
  ReadFromIniFile;
end;

destructor Tgd_GlobalParams.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function Tgd_GlobalParams.GetRemoteServer: String;
begin
  if gd_CmdLineParams.RemoteServer > '' then
    Result := gd_CmdLineParams.RemoteServer
  else if FIniFile <> nil then
    Result := FIniFile.ReadString('GEDEMIN UPDATE', 'RemoteServer', '')
  else
    Result := '';
end;

function Tgd_GlobalParams.GetServerBindings: String;
begin
  if FIniFile <> nil then
    Result := FIniFile.ReadString('WEB SERVER', 'Bindings', '')
  else
    Result := '';  
end;

function Tgd_GlobalParams.GetWebServerActive: Boolean;
begin
  if FIniFile <> nil then
    Result := FIniFile.ReadBool('WEB SERVER', 'Active', False)
  else
    Result := False;  
end;

procedure Tgd_GlobalParams.ReadFromIniFile;
begin
  if FileExists(FIniFileName) then
  begin
    if FIniFile = nil then
      FIniFile := TIniFile.Create(FIniFileName);
    FUpdateToken := FIniFile.ReadString('GEDEMIN UPDATE', 'Token', '');
  end;
end;

initialization
  gd_GlobalParams := Tgd_GlobalParams.Create;

finalization
  FreeAndNil(gd_GlobalParams);
end.