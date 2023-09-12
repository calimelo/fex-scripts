{!NAME:      ByLock.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit ByLock;

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

  Array_Items_Android: TSQL_Table_array = (
  (sql_col: 'DNT_Version';                                 fex_col: 'Version';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Encoding';                                fex_col: 'Encoding';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_StandAlone';                              fex_col: 'Stand Alone';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),  );

begin
  if Name = 'BYLOCK_APPPREFFILE_ANDROID' then Result := Array_Items_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.