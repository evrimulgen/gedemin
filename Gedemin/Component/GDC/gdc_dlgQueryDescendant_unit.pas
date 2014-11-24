unit gdc_dlgQueryDescendant_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, gdcBase, gd_ClassList, Contnrs;

type
  Tgdc_dlgQueryDescendant = class(TForm)
    rgObjects: TRadioGroup;
    ActionList: TActionList;
    acOk: TAction;
    actCancel: TAction;
    btnOK: TButton;
    btnCancel: TButton;
    procedure acOkExecute(Sender: TObject);
    procedure acOkUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
  public
    procedure FillrgObjects(OL: TObjectList);
  end;

var
  gdc_dlgQueryDescendant: Tgdc_dlgQueryDescendant;

implementation
  
{$R *.DFM}

procedure Tgdc_dlgQueryDescendant.FillrgObjects(OL: TObjectList);
var
  I: Integer;
  CE: TgdClassEntry;
begin
  for I := 0 to OL.Count - 1 do
  begin
    CE := TgdClassEntry(OL[I]);
    rgObjects.Items.AddObject(CE.gdcClass.GetDisplayName(CE.SubType), CE);

    if Height < rgObjects.Items.Count * 30 + 30 then
      Height := rgObjects.Items.Count * 30 + 30;
  end;
end;

procedure Tgdc_dlgQueryDescendant.acOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgdc_dlgQueryDescendant.acOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := rgObjects.ItemIndex <> -1;
end;

procedure Tgdc_dlgQueryDescendant.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
