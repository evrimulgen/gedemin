unit gdc_dlgAutoTask_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls,
  gsIBLookupComboBox, ExtCtrls, xDateEdits, ComCtrls;

type
  Tgdc_dlgAutoTask = class(Tgdc_dlgTR)
    gbTimeTables: TGroupBox;
    rbExactDate: TRadioButton;
    xdbeExactDate: TxDateDBEdit;
    rbMonthly: TRadioButton;
    rbWeekly: TRadioButton;
    dbcbWeekly: TDBComboBox;
    odCmdLine: TOpenDialog;
    lbPriority: TLabel;
    rbDaily: TRadioButton;
    Label2: TLabel;
    dbcbMonthly: TDBComboBox;
    Label3: TLabel;
    dbcbPriority: TDBComboBox;
    lbStartTime: TLabel;
    xdbeStartTime: TxDateDBEdit;
    lbEndTime: TLabel;
    xdbeEndTime: TxDateDBEdit;
    Label4: TLabel;
    btnClearTime: TButton;
    Label5: TLabel;
    Label6: TLabel;
    lbName: TLabel;
    lbDescription: TLabel;
    lbUser: TLabel;
    dbcbDisabled: TDBCheckBox;
    dbedName: TDBEdit;
    dbmDescription: TDBMemo;
    pcTask: TPageControl;
    tsFunction: TTabSheet;
    iblkupFunction: TgsIBLookupComboBox;
    tsCmd: TTabSheet;
    Label1: TLabel;
    dbeCmdLine: TDBEdit;
    btnCmdLine: TButton;
    iblkupUser: TgsIBLookupComboBox;
    procedure btnCmdLineClick(Sender: TObject);
    procedure btnClearTimeClick(Sender: TObject);

  public
    procedure SetupRecord; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgAutoTask: Tgdc_dlgAutoTask;

implementation

{$R *.DFM}

uses
  gd_ClassList, gd_security;

procedure Tgdc_dlgAutoTask.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTASK', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if gdcObject.FieldByName('cmdline').AsString > '' then
    pcTask.ActivePage := tsCmd
  else
    pcTask.ActivePage := tsFunction;

  if gdcObject.FieldByName('exactdate').AsDateTime > 0 then
    rbExactDate.Checked := True
  else if gdcObject.FieldByName('monthly').AsInteger <> 0 then
    rbMonthly.Checked := True
  else if gdcObject.FieldByName('weekly').AsInteger <> 0 then
    rbWeekly.Checked := True
  else
    rbDaily.Checked := True;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGAUTOTASK', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGAUTOTASK',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if pcTask.ActivePage = tsFunction then
  begin
    gdcObject.FieldByName('cmdline').Clear;
    gdcObject.FieldByName('autotrkey').Clear;
    gdcObject.FieldByName('reportkey').Clear;
    gdcObject.FieldByName('backupfile').Clear;
  end
  else if pcTask.ActivePage = tsCmd then
  begin
    gdcObject.FieldByName('functionkey').Clear;
    gdcObject.FieldByName('autotrkey').Clear;
    gdcObject.FieldByName('reportkey').Clear;
    gdcObject.FieldByName('backupfile').Clear;
  end;

  if rbExactDate.Checked then
  begin
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('daily').Clear;
    if gdcObject.FieldByName('exactdate').IsNull then
      gdcObject.FieldByName('exactdate').AsDateTime := Date;
  end
  else if rbMonthly.Checked then
  begin
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('daily').Clear;
    if gdcObject.FieldByName('monthly').IsNull then
      gdcObject.FieldByName('monthly').AsInteger := 1;
  end
  else if rbWeekly.Checked then
  begin
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('daily').Clear;
    if gdcObject.FieldByName('weekly').IsNull then
      gdcObject.FieldByName('weekly').AsInteger := 1;
  end
  else if rbDaily.Checked then
  begin
    gdcObject.FieldByName('monthly').Clear;
    gdcObject.FieldByName('weekly').Clear;
    gdcObject.FieldByName('exactdate').Clear;
    gdcObject.FieldByName('daily').AsInteger := 1;
  end;

  if (gdcObject.FieldByName('starttime').AsDateTime > 0)
    and (gdcObject.FieldByName('endtime').AsDateTime <= gdcObject.FieldByName('starttime').AsDateTime) then
  begin
    if gdcObject.FieldByName('starttime').AsDateTime < 23 / 24 then
      gdcObject.FieldByName('endtime').AsDateTime :=
        gdcObject.FieldByName('starttime').AsDateTime + 1 / 24
    else
      gdcObject.FieldByName('endtime').AsDateTime := (MSecsPerDay - 1) / MSecsPerDay;
  end;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGAUTOTASK', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgAutoTask.btnCmdLineClick(Sender: TObject);
begin
  if odCmdLine.Execute then
    dbeCmdLine.Text := odCmdLine.FileName;
end;

procedure Tgdc_dlgAutoTask.btnClearTimeClick(Sender: TObject);
begin
  gdcObject.FieldByName('starttime').Clear;
  gdcObject.FieldByName('endtime').Clear;
end;

initialization
  RegisterFrmClass(Tgdc_dlgAutoTask);

finalization
  UnRegisterFrmClass(Tgdc_dlgAutoTask);
end.