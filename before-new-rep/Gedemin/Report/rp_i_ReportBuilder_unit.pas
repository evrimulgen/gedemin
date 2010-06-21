unit rp_i_ReportBuilder_unit;

interface

uses
  Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL,
  rp_BaseReport_unit, Forms,
  {$IFDEF GEDEMIN}
  gd_createable_form,
  {$ENDIF}
  SysUtils;

type
  TReportEvent = procedure(const AnVarArray: Variant;
   const AnEventFunction: TrpCustomFunction; var AnResult: Boolean) of object;

type

// *********************************************************************//
// Interface: IgsReportBuilder
// Flags:     (0)
// GUID:      {B5CC4034-1ED7-11D5-AECE-006052067F0D}
// *********************************************************************//
  IgsReportBuilder = interface(IUnknown)
    ['{B5CC4034-1ED7-11D5-AECE-006052067F0D}']
    procedure BuildReport;
    procedure PrintReport;
    function IsProcessed: Boolean;
    procedure Set_ReportResult(const AnReportResult: TReportResult);
    function Get_ReportResult: TReportResult;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate);
    function Get_ReportTemplate: TReportTemplate;
    procedure Set_Params(const AnParams: Variant);
    function Get_Params: Variant;
    procedure Set_BuildDate(const AnValue: TDateTime);
    function Get_Preview: Boolean;
    procedure Set_Preview(const AnValue: Boolean);
    function Get_ReportEvent: TReportEvent;
    procedure Set_ReportEvent(Value: TReportEvent);
    function Get_EventFunction: TrpCustomFunction;
    procedure Set_EventFunction(Value: TrpCustomFunction);
    function Get_Caption: String;
    procedure Set_Caption(Value: String);
    function Get_PrinterName: String;
    procedure Set_PrinterName(Value: String);
    function Get_ShowProgress: boolean;
    procedure Set_ShowProgress(Value: boolean);

    property ReportResult: TReportResult read Get_ReportResult write Set_ReportResult;
    property ReportTemplate: TReportTemplate read Get_ReportTemplate write Set_ReportTemplate;
    property Params: Variant read Get_Params write Set_Params;
    property BuildDate: TDateTime write Set_BuildDate;
    property Preview: Boolean read Get_Preview write Set_Preview;
    property OnReportEvent: TReportEvent read Get_ReportEvent write Set_ReportEvent;
    property EventFunction: TrpCustomFunction read Get_EventFunction write Set_EventFunction;
    property Caption: String read Get_Caption write Set_Caption;
    property PrinterName: string read Get_PrinterName write Set_PrinterName;
    property ShowProgress: boolean read Get_ShowProgress write Set_ShowProgress;
  end;

  TCustomReportBuilder = class(TInterfacedObject, IgsReportBuilder)
  private
    FOldClose: TCloseEvent;
    FOldDestroy: TNotifyEvent;
    FPreview: Boolean;
    FCaption: String;
    FPrinterName: String;
    FShowProgress: boolean;

    procedure DoClose(Sender: TObject; var Action: TCloseAction);
    procedure DoDestroy(Sender: TObject);
  protected
    FPreviewForm: TForm;
    FReportEvent: TReportEvent;
    FEventFunction: TrpCustomFunction;

    procedure FreeOldForm;
    procedure CreatePreviewForm; virtual;
    procedure AddParam(const AnName: String; const AnValue: Variant); virtual; abstract;

    procedure BuildReport; virtual;
    procedure PrintReport; virtual; abstract;
    function IsProcessed: Boolean; virtual;
    procedure Set_ReportResult(const AnReportResult: TReportResult);  virtual; abstract;
    function Get_ReportResult: TReportResult;  virtual; abstract;
    procedure Set_ReportTemplate(const AnReportTemplate: TReportTemplate);  virtual; abstract;
    function Get_ReportTemplate: TReportTemplate;  virtual; abstract;
    procedure Set_Params(const AnParams: Variant); virtual;
    function Get_Params: Variant; virtual;
    procedure Set_BuildDate(const AnValue: TDateTime);
    function Get_Preview: Boolean;
    procedure Set_Preview(const AnValue: Boolean);
    function Get_ReportEvent: TReportEvent;
    procedure Set_ReportEvent(Value: TReportEvent);
    function Get_EventFunction: TrpCustomFunction;
    procedure Set_EventFunction(Value: TrpCustomFunction);
    function Get_Caption: String;
    procedure Set_Caption(Value: String);
    function Get_PrinterName: String;
    procedure Set_PrinterName(Value: String);
    function Get_ShowProgress: boolean;
    procedure Set_ShowProgress(Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;

    property ReportResult: TReportResult read Get_ReportResult write Set_ReportResult;
    property ReportTemplate: TReportTemplate read Get_ReportTemplate write Set_ReportTemplate;
    property Params: Variant read Get_Params write Set_Params;
    property BuildDate: TDateTime write Set_BuildDate;
    property Preview: Boolean read Get_Preview write Set_Preview;
    property EventFunction: TrpCustomFunction read Get_EventFunction write Set_EventFunction;
    property PrinterName: string read Get_PrinterName write Set_PrinterName;
    property ShowProgress: boolean read Get_ShowProgress write Set_ShowProgress;
  end;

implementation

{ TRTFReportInterface }

// Method must be override, where calling CustomExecuteReport.
procedure TCustomReportBuilder.BuildReport;
begin
  FreeOldForm;

  // Call abstarct method.
  CreatePreviewForm;

  FOldClose := FPreviewForm.OnClose;
  FOldDestroy := FPreviewForm.OnDestroy;

  FPreviewForm.OnClose := DoClose;
  FPreviewForm.OnDestroy := DoDestroy;
end;

constructor TCustomReportBuilder.Create;
begin
  inherited Create;

  FOldClose := nil;
  FOldDestroy := nil;
  FPreviewForm := nil;
  FPreview := True;
  FReportEvent := nil;
  FEventFunction := TrpCustomFunction.Create;
  InterlockedIncrement(FRefCount);
end;

procedure TCustomReportBuilder.CreatePreviewForm;
begin
  if Assigned(FPreviewForm) then
  begin
    {$IFDEF GEDEMIN}
    if FPreviewForm is TCreateableForm then
      TCreateableForm(FPreviewForm).Caption := FCaption
    else
      FPreviewForm.Caption := FCaption;
    {$ELSE}
    FPreviewForm.Caption := FCaption;
    {$ENDIF}
    //��� ���� ����� ��������� OnDestroy �� �����������
    FPreviewForm.OldCreateOrder := True;
  end;
end;

destructor TCustomReportBuilder.Destroy;
begin
  FreeOldForm;
  FreeAndNil(FEventFunction);

  inherited Destroy;
end;

procedure TCustomReportBuilder.DoClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FOldClose) then
    FOldClose(Sender, Action);
//!!! JKL ������� ���� ���. ���� Action ��������� caFree �� ���� ���������
//����������� ������ �������������� ���� ���� ������������ ������ ������� ����

// ��� ����������� ���� OnClose ���������� �� ������, � ��� �� ���������� ��������� �����
// ��������� � ����� (����� ������������ �� createableform).
// � ���� ���� ��� ����������������, ������������� ���� �� �����.
// � ����� ������ ����� OnClose ��� minimize - ��� ������. JKL

//!!!TipTop Action = caFree ������ ���� ���� ����������� � ������� Shift-��
//� ����  ���������������� �� ��� �������� ���������
//  Action := caFree;

end;

procedure TCustomReportBuilder.DoDestroy(Sender: TObject);
begin
  if Assigned(FOldDestroy) then
    FOldDestroy(Sender);
  FPreviewForm := nil;
  _Release;
end;

procedure TCustomReportBuilder.FreeOldForm;
begin
  if Assigned(FPreviewForm) then
  begin
    FPreviewForm.OnClose := FOldClose;
    FPreviewForm.OnDestroy := FOldDestroy;
    FreeAndNil(FPreviewForm);
  end;
end;

function TCustomReportBuilder.Get_Caption: String;
begin
  Result := FCaption;
end;

function TCustomReportBuilder.Get_EventFunction: TrpCustomFunction;
begin
  Result := FEventFunction;
end;

function TCustomReportBuilder.Get_Params: Variant;
begin
  Result := Unassigned;
end;

function TCustomReportBuilder.Get_Preview: Boolean;
begin
  Result := FPreview;
end;

function TCustomReportBuilder.Get_PrinterName: String;
begin
  Result := FPrinterName;
end;

function TCustomReportBuilder.Get_ReportEvent: TReportEvent;
begin
  Result := FReportEvent;
end;

function TCustomReportBuilder.Get_ShowProgress: boolean;
begin
  Result := FShowProgress;
end;

function TCustomReportBuilder.IsProcessed: Boolean;
begin
  Result := FPreviewForm <> nil;
end;

procedure TCustomReportBuilder.Set_BuildDate(const AnValue: TDateTime);
const
  BuildDateName = 'BuildDate';
begin
  AddParam(BuildDateName, AnValue);
end;

procedure TCustomReportBuilder.Set_Caption(Value: String);
begin
  if Assigned(FPreviewForm) then
    FPreviewForm.Caption := Value;
  FCaption := Value;
end;

procedure TCustomReportBuilder.Set_EventFunction(Value: TrpCustomFunction);
begin
  FEventFunction.Assign(Value);
end;

procedure TCustomReportBuilder.Set_Params(const AnParams: Variant);
const
  cParamName = 'PARAM';
  cSeparator = 's';

  procedure SetParam(const AnParamName: String; const Param: Variant);
  var
    I: Integer;
    PP: OleVariant;
  begin
    if VarIsArray(Param) then
      for I := VarArrayLowBound(Param, 1) to VarArrayHighBound(Param, 1) do
      begin
        case VarType(Param[I]) of
          varDispatch:
            PP := 'Object';
          varEmpty:
            PP := ''
          else
          PP := Param[I];
        end;
        
        if Length(AnParamName) > Length(cParamName) then
          SetParam(AnParamName + cSeparator + IntToStr(I), PP)
        else
          // Call abstract method.
          SetParam(AnParamName + IntToStr(I), PP)
      end
    else
      AddParam(AnParamName, Param);
  end;
begin
  SetParam(cParamName, AnParams);
end;

procedure TCustomReportBuilder.Set_Preview(const AnValue: Boolean);
begin
  FPreview := AnValue;
end;

procedure TCustomReportBuilder.Set_PrinterName(Value: String);
begin
  FPrinterName := Value;
end;

procedure TCustomReportBuilder.Set_ReportEvent(Value: TReportEvent);
begin
  FReportEvent := Value;
end;

procedure TCustomReportBuilder.Set_ShowProgress(Value: boolean);
begin
  FShowProgress:= Value;
end;

end.

