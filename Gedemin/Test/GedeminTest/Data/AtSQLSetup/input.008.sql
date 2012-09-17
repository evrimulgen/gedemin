SELECT
  IIF(  EXISTS (SELECT 
    RDB$CHARACTER_SET_NAME
  FROM 
    RDB$DATABASE 
  WHERE 
    RDB$CHARACTER_SET_NAME  =  'WIN1251'), 1, 0) AS CHARACTERSET
FROM
  RDB$DATABASE  