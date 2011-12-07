
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    evt_script.sql

  Abstract

    An Interbase script for "universal" report.

  Author

    Andrey Shadevsky (__.__.__)

  Revisions history

    Initial  29.11.01  JKL    Initial version

  Status 
    
    Draft

*/

/****************************************************

   ������� ��� �������� ��������.

*****************************************************/

CREATE TABLE evt_object
(
  id             dintkey,
  name           dgdcname,
  description    dtext180,
  parent         dforeignkey,
  lb               dlb,
  rb               drb,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  objecttype     dsmallint, /* 0-object; 1-class */
  reserved       dinteger,
  macrosgroupkey dforeignkey,
  parentindex    dinteger NOT NULL,
  reportgroupkey dforeignkey,
  classname      dgdcname,
  objectname     dgdcname,
  subtype        dsubtype,
  editiondate    deditiondate,  /* ���� ���������� �������������� */
  editorkey      dintkey        /* ������ �� ������������, ������� ������������ ������*/
);

ALTER TABLE evt_object
  ADD CONSTRAINT evt_pk_object PRIMARY KEY (id);

/* !!! ������� ������ ������ ���� �� ������ !!!*/

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_parent
  FOREIGN KEY (parent) REFERENCES evt_object (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_function ADD CONSTRAINT gd_fk_function_modulecode
  FOREIGN KEY (modulecode) REFERENCES evt_object (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_reportgrkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

/*
ALTER TABLE evt_object ADD CONSTRAINT evt_chk_object_tree_limit
  CHECK ((lb <= rb) or ((rb is NULL) and (lb is NULL)));

CREATE DESC INDEX evt_x_object_rb
  ON evt_object(rb);

CREATE ASC INDEX evt_x_object_lb
  ON evt_object(lb);
*/

CREATE ASC INDEX evt_x_object_objectname_upper
  ON evt_object
  COMPUTED BY (UPPER(objectname));

COMMIT;

CREATE EXCEPTION EVT_E_RECORDFOUND
  'Object or Class with such a parameters is already exist';

CREATE EXCEPTION EVT_E_RECORDINCORRECT
  'Do not insert or update this data.';

CREATE EXCEPTION EVT_E_INCORRECTVERSION
  'Incorrect version Gedemin for insert in evt_object Table.';

COMMIT;

SET TERM ^ ;

CREATE TRIGGER evt_bi_object FOR evt_object
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* ���� ���� �� ��������, ����������� */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.parent IS NULL) THEN
    NEW.parentindex = 1;
  ELSE
    NEW.parentindex = NEW.parent;
END
^

CREATE TRIGGER evt_bi_object1 FOR evt_object
  ACTIVE
  BEFORE INSERT
  POSITION 1
AS
BEGIN
  /* ���� ������ ������ ��������, �� ���������� ������*/
  IF ((NOT NEW.name is NULL) AND
     (NEW.objectname is NULL) AND
     (NEW.classname is NULL) AND
     (NEW.subtype is NULL))
  THEN
    EXCEPTION  EVT_E_INCORRECTVERSION;

  /* ��������� ������������ �������� ������ */

  IF (NEW.objectname is NULL) THEN
    NEW.objectname = '';
  IF (NEW.classname is NULL) THEN
    NEW.classname = '';
  IF (NEW.subtype is NULL) THEN
    NEW.subtype = '';

  /* ��������� ������������ �������� ������ */
  IF
    (
    ((NEW.objectname = '') and (NEW.classname = '')) or
    ((NEW.subtype <> '') and ((NEW.objectname <> '') or
     (NEW.classname = '')))
    ) then
  BEGIN
    EXCEPTION EVT_E_RECORDINCORRECT;
  END

  IF (NEW.classname > '') THEN
  BEGIN
    IF (EXISTS (SELECT * FROM evt_object WHERE UPPER(classname)=UPPER(NEW.classname)
      AND UPPER(subtype)=UPPER(NEW.subtype))) THEN
    BEGIN
      EXCEPTION EVT_E_RECORDINCORRECT;
    END
  END
END
^

CREATE TRIGGER evt_bi_object2 FOR evt_object
  ACTIVE
  BEFORE INSERT
  POSITION 2
AS
BEGIN
  /* ��������� ������������ ������� ��� ������ � ��������*/
  IF
    (EXISTS(SELECT * FROM evt_object
    WHERE
    (UPPER(objectname) = UPPER(NEW.objectname))  AND
    (UPPER(classname) = UPPER(NEW.classname)) AND
    (parentindex = NEW.parentindex) AND
    (UPPER(subtype) = UPPER(NEW.subtype)) AND
    (id <> NEW.id)))
  THEN
  BEGIN
    EXCEPTION EVT_E_RECORDFOUND;
  END

  /* ��������� ���� name, objecttype ��� ��������� */
  /* ������ ������ �������� */
  IF (NEW.classname = '') THEN
  BEGIN
    NEW.objecttype = 0;
    NEW.name = NEW.objectname;
  END ELSE
    BEGIN
      NEW.objecttype = 1;
      IF (NEW.subtype = '') THEN
      BEGIN
        NEW.name = NEW.classname;
      END ELSE
        NEW.name = NEW.classname || NEW.subtype;
    END
END
^

CREATE TRIGGER evt_bu_object FOR evt_object
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.parent IS NULL) THEN
    NEW.parentindex = 1;
  ELSE
    NEW.parentindex = NEW.parent;
END
^

CREATE TRIGGER evt_bu_object1 FOR evt_object
ACTIVE BEFORE UPDATE POSITION 1
AS
BEGIN
  /* ���� ������ ������ ��������, �� ���������� ������*/
  IF ((NOT NEW.name is NULL) AND
     (NEW.objectname is NULL) AND
     (NEW.classname is NULL) AND
     (NEW.subtype is NULL))
  THEN
    EXCEPTION  EVT_E_INCORRECTVERSION;

  /* ��������� ������������ �������� ������ */

  IF (NEW.objectname is NULL) THEN
    NEW.objectname = '';
  IF (NEW.classname is NULL) THEN
    NEW.classname = '';
  IF (NEW.subtype is NULL) THEN
    NEW.subtype = '';

  /* ��������� ������������ �������� ������ */
  IF
    (
    ((NEW.objectname = '') and (NEW.classname = '')) or
    ((NEW.subtype <> '') and ((NEW.objectname <> '') or
     (NEW.classname = '')))
    ) then
  BEGIN
    EXCEPTION EVT_E_RECORDINCORRECT;
  END

  IF (NEW.classname > '') THEN
  BEGIN
    IF (EXISTS (SELECT * FROM evt_object WHERE UPPER(classname)=UPPER(NEW.classname)
      AND UPPER(subtype)=UPPER(NEW.subtype) AND NEW.id <> id)) THEN
    BEGIN
      EXCEPTION EVT_E_RECORDINCORRECT;
    END
  END
END
^

CREATE TRIGGER evt_bu_object2 FOR evt_object
  ACTIVE
  BEFORE UPDATE
  POSITION 2
AS
BEGIN
  /* ��������� ������������ ������� ��� ������ � ��������*/
  IF
    (EXISTS(SELECT * FROM evt_object
    WHERE
    (UPPER(objectname) = UPPER(NEW.objectname))  AND
    (UPPER(classname) = UPPER(NEW.classname)) AND
    (parentindex = NEW.parentindex) AND
    (UPPER(subtype) = UPPER(NEW.subtype)) AND
    (id <> NEW.id)))
  THEN
  BEGIN
    EXCEPTION EVT_E_RECORDFOUND;
  END

  /* ��������� ���� name, objecttype ��� ��������� */
  /* ������ ������ �������� */
  IF (NEW.classname = '') THEN
  BEGIN
    NEW.objecttype = 0;
    NEW.name = NEW.objectname;
  END ELSE
    BEGIN
      NEW.objecttype = 1;
      IF (NEW.subtype = '') THEN
      BEGIN
        NEW.name = NEW.classname;
      END ELSE
        NEW.name = NEW.classname || NEW.subtype;
    END
END
^

CREATE TRIGGER evt_bi_object5 FOR evt_object
  BEFORE INSERT
  POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;

  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER evt_bu_object5 FOR evt_object
  BEFORE UPDATE
  POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

/****************************************************

   ������� ��� ������� � ������ �� �������.

*****************************************************/

CREATE TABLE evt_objectevent
(
  id               dintkey,
  objectkey             dintkey,
  eventname           dname,
  functionkey    dforeignkey,
  afull          dsecurity,
  reserved       dinteger,
  disable        dboolean,
  editiondate    deditiondate,  /* ���� ���������� �������������� */
  editorkey      dintkey        /* ������ �� ������������, ������� ������������ ������*/
);

/* Primary keys definition */

ALTER TABLE EVT_OBJECTEVENT ADD CONSTRAINT EVT_PK_OBJECTEVENT_ID PRIMARY KEY (ID);

/* ��� ���� ������������� ����������� ������ �������     DELETE CASCADE */
ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_object_fk
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_object_objectkey
  FOREIGN KEY (objectkey) REFERENCES evt_object(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_objectevent_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

/* Indices definition */

CREATE UNIQUE INDEX evt_idx_objectevent ON evt_objectevent (eventname, objectkey);

COMMIT;

SET TERM ^ ;
CREATE TRIGGER evt_bi_objectevent5 FOR evt_objectevent
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER evt_bu_objectevent5 FOR evt_objectevent
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

COMMIT;


/****************************************************/
/**                                                **/
/**   ������� ��� �������� ������ ��������         **/
/**                                                **/
/****************************************************/
CREATE TABLE evt_macrosgroup (
  id             dintkey,      /* ���������� ���� */
  parent      dforeignkey,      /* ������ �� �������� */
  lb             dlb,          /* ����� (�������) �������. ������������ ����� �������������� */
                               /* ��� ������ ���������� ������, ���� ������ � ������ */
                               /* ��������� � ������ �������� */
  rb               drb,        /* ������ (������) ������� */

  name          dname,         /* ������������ ���� ��� ������� */

  isglobal      dboolean,

  description dblobtext80, /*  �������� ������ */
  editiondate     deditiondate,  /* ���� ���������� �������������� */
  editorkey       dintkey,       /* ������ �� ������������, ������� ������������ ������*/

  reserved     dblob         /*����������������*/
);

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_pk_macrosgroup_id
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_mrsgroupkey
  FOREIGN KEY (macrosgroupkey) REFERENCES evt_macrosgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_fk_macrosgroup_parent
  FOREIGN KEY (parent) REFERENCES evt_macrosgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_fk_macrosgroup_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

/*
ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_chk_macrosgroup_tree_limit
  CHECK (lb <= rb);

CREATE DESC INDEX evt_x_macrosgroup_rb
  ON evt_macrosgroup(rb);
*/

COMMIT;

SET TERM ^ ;

CREATE TRIGGER evt_bi_macrosgroup5 FOR evt_macrosgroup
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER evt_bu_macrosgroup5 FOR evt_macrosgroup
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

/****************************************************/
/**                                                **/
/**    ������� ��� �������� ��������               **/
/**                                                **/
/****************************************************/

CREATE TABLE evt_macroslist (
  id              dintkey,      /* ���������� ���� */
  macrosgroupkey  dforeignkey, /*  ���� ������ �������� */
  functionkey     dforeignkey,    /*  ���� ������� */
  name            dname,         /* ������������ ���� ��� ������� */
  serverkey       dforeignkey,
  islocalexecute  dboolean,
  isrebuild       dboolean,
  executedate     dtext254,
  shortcut        dinteger,
  editiondate     deditiondate,  /* ���� ���������� �������������� */
  editorkey       dintkey,        /* ������ �� ������������, ������� ������������ ������*/
  displayinmenu   dboolean DEFAULT 1,     /* ���������� � ���� ����� */
  achag           dsecurity,
  afull           dsecurity,
  aview           dsecurity
);

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_pk_macroslist_id
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_mrsgroupkey
  FOREIGN KEY (macrosgroupkey) REFERENCES evt_macrosgroup(id)
  ON UPDATE CASCADE;

/* ��� ���� ������������� ����������� ������ �������     DELETE CASCADE */
ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macros_functionkey
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_rpserver
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE UNIQUE INDEX EVT_MACROSLIST_IDX
  ON EVT_MACROSLIST
  (NAME, MACROSGROUPKEY);

CREATE UNIQUE INDEX EVT_X_MACROSLIST_FUNCTIONKEY
  ON EVT_MACROSLIST
  (FUNCTIONKEY);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER evt_bi_macroslist5 FOR evt_macroslist
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER evt_bu_macroslist5 FOR evt_macroslist
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

COMMIT;

