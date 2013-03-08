unit at_frmDuplicates_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, Db, IBCustomDataSet, IBDatabase, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ActnList, TB2Dock, TB2Toolbar, dmDatabase_unit,
  dmImages_unit, TB2Item;

type
  Tat_frmDuplicates = class(TCreateableForm)
    TBDock: TTBDock;
    tb: TTBToolbar;
    ActionList: TActionList;
    sb: TStatusBar;
    gsIBGrid1: TgsIBGrid;
    ibtr: TIBTransaction;
    ibds: TIBDataSet;
    ds: TDataSource;
    actOpenObject: TAction;
    TBItem1: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    procedure FormCreate(Sender: TObject);
    procedure actOpenObjectUpdate(Sender: TObject);
    procedure actOpenObjectExecute(Sender: TObject);
    procedure dsDataChange(Sender: TObject; Field: TField);

  private
    procedure DoOnClick(Sender: TObject);
    
  public
    { Public declarations }
  end;

var
  at_frmDuplicates: Tat_frmDuplicates;

implementation

{$R *.DFM}

uses
  gd_classlist, gdcBase, gdcBaseInterface, gdcNamespace;

procedure Tat_frmDuplicates.FormCreate(Sender: TObject);
begin
  ibtr.StartTransaction;
  ibds.Open;
end;

procedure Tat_frmDuplicates.actOpenObjectUpdate(Sender: TObject);
begin
  actOpenObject.Enabled := not ibds.EOF;
end;

procedure Tat_frmDuplicates.actOpenObjectExecute(Sender: TObject);
var
  FC: TgdcFullClassName;
  C: CgdcBase;
  Obj: TgdcBase;
begin
  FC.gdClassName := ibds.FieldByName('objectclass').AsString;
  FC.SubType := ibds.FieldByName('subtype').AsString;
  C := gdcClassList.GetGdcClass(FC);
  if C <> nil then
  begin
    Obj := C.Create(nil);
    try
      Obj.SubType := FC.SubType;
      Obj.SubSet := 'ByID';
      Obj.ID := gdcBaseManager.GetIDByRUID(ibds.FieldByName('xid').AsInteger,
        ibds.FieldByName('dbid').AsInteger);
      Obj.Open;
      if not Obj.EOF then
        Obj.EditDialog
      else
        MessageBox(Self.Handle,
          '������ ��� ������ ����� �� ������ � ���� ������.',
          '��������',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    finally
      Obj.Free;
    end;
  end;
end;

procedure Tat_frmDuplicates.dsDataChange(Sender: TObject; Field: TField);
var
  I: Integer;
  SL: TStringList;
  TBI: TTBItem;
begin
  for I := tb.Items.Count - 1 downto 0 do
  begin
    if tb.Items[I].Tag > 0 then
      tb.Items[I].Free;
  end;

  SL := TStringList.Create;
  try
    SL.Text := StringReplace(ibds.FieldByName('ns_list').AsString,
      ',', #13#10, [rfReplaceAll]);
    for I := 0 to Sl.Count - 1 do
    begin
      TBI := TTBItem.Create(nil);
      TBI.Tag := StrToInt(SL.Names[I]);
      TBI.Caption := SL.Values[SL.Names[I]];
      TBI.OnClick := DoOnClick;
      tb.Items.Add(TBI);
    end;
  finally
    SL.Free;
  end;
end;

procedure Tat_frmDuplicates.DoOnClick(Sender: TObject);
var
  Obj: TgdcNamespace;
begin
  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByID';
    Obj.ID := (Sender as TComponent).Tag;
    Obj.Open;
    if not Obj.EOF then
      Obj.EditDialog;
  finally
    Obj.Free;
  end;
end;

end.
