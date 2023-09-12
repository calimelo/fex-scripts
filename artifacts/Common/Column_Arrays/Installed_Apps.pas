unit Installed_Apps;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_IOS_INSTALLED_APPS: TSQL_Table_array = (
  (sql_col: 'DNT_APPLICATION_IDENTIFIER';   fex_col: 'Application';   read_as: ftString;    convert_as: '';  col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';      read_as: ftString;    convert_as: '';  col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS_INSTALLED_APPS'   then Result := Array_Items_IOS_INSTALLED_APPS;
end;

end.