unit AppleMaps;

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

  Array_Items_APPLE_MAPS_SEARCHES_IOS: TSQL_Table_array = (
   (sql_col: 'DNT_ZCREATETIME';               fex_col: 'Date Created';          read_as: ftLargeInt;      convert_as: 'ABS';     col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_ZQUERY';                    fex_col: 'Query';                 read_as: ftString;        convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ZLOCATIONDISPLAY';          fex_col: 'Address';               read_as: ftString;        convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ZLONGITUDE';                fex_col: 'Longitude';             read_as: ftString;        convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ZLATITUDE';                 fex_col: 'Latitude';              read_as: ftString;        convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';               fex_col: 'Location';              read_as: ftString;        convert_as: '';        col_type: ftString;       show: True),
  );

begin
  if Name = 'APPLE_MAPS_SEARCHES_IOS' then Result := Array_Items_APPLE_MAPS_SEARCHES_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
