inherited gdc_frmNamespace: Tgdc_frmNamespace
  Left = 622
  Top = 190
  Width = 1090
  Height = 742
  Caption = '������������ ����'
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 685
    Width = 1074
  end
  inherited TBDockTop: TTBDock
    Width = 1074
    inherited tbMainCustom: TTBToolbar
      object TBItem1: TTBItem
        Action = actSetObjectPos
      end
      object TBItem2: TTBItem
        Action = actCompareWithData
      end
      object TBItem3: TTBItem
        Action = actShowDuplicates
      end
      object TBItem4: TTBItem
        Action = actShowRecursion
      end
      object TBItem6: TTBItem
        Action = actNSObjects
      end
      object TBItem7: TTBItem
        Action = actViewNS
        Caption = '����������� ������ ����������� ����'
        Hint = '�������� ����������� ����� ������� ����������� ����'
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 625
  end
  inherited TBDockRight: TTBDock
    Left = 1065
    Height = 625
  end
  inherited TBDockBottom: TTBDock
    Top = 676
    Width = 1074
  end
  inherited pnlWorkArea: TPanel
    Width = 1056
    Height = 625
    inherited sMasterDetail: TSplitter
      Width = 1056
    end
    inherited spChoose: TSplitter
      Top = 520
      Width = 1056
    end
    inherited pnlMain: TPanel
      Width = 1056
      inherited ibgrMain: TgsIBGrid
        Width = 896
      end
    end
    inherited pnChoose: TPanel
      Top = 526
      Width = 1056
      inherited pnButtonChoose: TPanel
        Left = 951
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 951
      end
      inherited pnlChooseCaption: TPanel
        Width = 1056
      end
    end
    inherited pnlDetail: TPanel
      Width = 1056
      Height = 347
      inherited TBDockDetail: TTBDock
        Width = 1056
        inherited tbDetailCustom: TTBToolbar
          Images = dmImages.il16x16
          object TBItem5: TTBItem
            Action = actShowObject
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 321
        inherited sbSearchDetail: TScrollBox
          Height = 283
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 283
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 896
        Height = 321
      end
    end
  end
  inherited alMain: TActionList
    object actSetObjectPos: TAction
      Caption = '���������� ����������� ��������'
      Hint = '���������� ����������� ��������'
      ImageIndex = 206
      OnExecute = actSetObjectPosExecute
      OnUpdate = actSetObjectPosUpdate
    end
    object actCompareWithData: TAction
      Caption = '�������� � ������'
      Hint = '�������� � ������'
      ImageIndex = 131
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
    end
    object actShowDuplicates: TAction
      Caption = '�������� ���������'
      Hint = '�������� ���������'
      ImageIndex = 100
      OnExecute = actShowDuplicatesExecute
      OnUpdate = actShowDuplicatesUpdate
    end
    object actShowRecursion: TAction
      Caption = '�������� ����������� �����������'
      Hint = '�������� ����������� �����������'
      ImageIndex = 203
      OnExecute = actShowRecursionExecute
      OnUpdate = actShowRecursionUpdate
    end
    object actNSObjects: TAction
      Caption = '������ ��������'
      Hint = '������ ��������'
      ImageIndex = 181
      OnExecute = actNSObjectsExecute
      OnUpdate = actNSObjectsUpdate
    end
    object actShowObject: TAction
      Category = 'Detail'
      Caption = '������� ������'
      Hint = '������� ������'
      ImageIndex = 131
      OnExecute = actShowObjectExecute
      OnUpdate = actShowObjectUpdate
    end
    object actViewNS: TAction
      Caption = '�������� ����� ����������� ����'
      Hint = '�������� ����� ����������� ����'
      ImageIndex = 80
      OnExecute = actViewNSExecute
    end
  end
  object gdcNamespace: TgdcNamespace
    Left = 425
    Top = 129
  end
  object gdcNamespaceObject: TgdcNamespaceObject
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'namespacekey'
    SubSet = 'ByNamespace'
    Left = 337
    Top = 161
  end
end
