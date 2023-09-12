unit ApplicationState_IOS;

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

  Array_Items_APPLICATIONSTATE_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ID';                            fex_col: 'Application ID';           read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_APPLICATION_IDENTIFIER';        fex_col: 'Application Identifier';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'APPLICATIONSTATE_IOS' then Result := Array_Items_APPLICATIONSTATE_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.