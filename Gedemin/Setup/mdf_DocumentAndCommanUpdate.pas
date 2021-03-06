unit mdf_DocumentAndCommandUpdate;

interface
uses
  sysutils, IBDatabase, gdModify;
  procedure DocumentAndCommandUpdate(IBDB: TIBDatabase; Log: TModifyLog);

implementation
uses
  IBSQL;

procedure DocumentAndCommandUpdate(IBDB: TIBDatabase; Log: TModifyLog);
var
  FIBTransaction: TIBTransaction;
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  FIBTransaction := TIBTransaction.Create(nil);
  try
    FIBTransaction.DefaultDatabase := IBDB;
    ibsql.Transaction := FIBTransaction;
    try
      if FIBTransaction.InTransaction then
        FIBTransaction.Rollback;
      FIBTransaction.StartTransaction;

      //��������� ������ ���� �� transactionkey � ���������
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT * FROM rdb$relation_constraints c '+
        ' WHERE c.rdb$constraint_name = ''GD_FK_DOC_TRANSACTIONKEY'' ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_transactionkey ' +
          ' FOREIGN KEY (transactionkey) REFERENCES gd_command (id) ON UPDATE CASCADE ';
        Log('GD_DOCUMENT: ���������� ������ ����� �� ���� transactionkey');
        ibsql.ExecQuery;
      end;

      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;

      FIBTransaction.StartTransaction;

      //����������� ����� ��� ������� ���� ����������
      ibsql.SQL.Text := 'SELECT * FROM gd_documenttype WHERE classname IS NULL AND ' +
        ' documenttype = ''D'' AND id < 147000000';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_documenttype t SET classname = ' +
          ' (SELECT tt.classname FROM gd_documenttype tt WHERE tt.id = t.parent) ' +
          ' WHERE classname IS NULL AND documenttype = ''D''';
        Log('GD_DOCUMENTTYPE: ���������� ���� classname');
        ibsql.ExecQuery;
      end;
      if FIBTransaction.InTransaction then
        FIBTransaction.Commit;

      FIBTransaction.StartTransaction;

      //�������� imgindex = 17 �� imgindex = 0
      // ������� �� �������� �������
      ibsql.SQL.Text := 'SELECT * FROM gd_command WHERE imgindex=17 ';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'UPDATE gd_command SET imgindex=0 WHERE imgindex=17';
        Log('GD_COMMAND: ���������� ���� imgindex');
        ibsql.ExecQuery;
      end;

    except
      on E: Exception do
      begin
        if FIBTransaction.InTransaction then
          FIBTransaction.Rollback;
        Log('������: ' + E.Message);
      end;
    end;
  finally
    ibsql.Free;
    FIBTransaction.Free;
  end;
end;

end.
