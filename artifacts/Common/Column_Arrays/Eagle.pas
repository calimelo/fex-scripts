{!NAME:      Eagle.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Eagle;

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

    // Eagle - Android
    Array_Items_Eagle_Android: TSQL_Table_array = (
    (sql_col: 'DNT_ID';                       fex_col: 'ID Col';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Value';                    fex_col: 'Value';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'ANDROID' then Result := Array_Items_Eagle_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.