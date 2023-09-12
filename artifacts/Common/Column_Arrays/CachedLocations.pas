unit CachedLocations;

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

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';                  fex_col: 'Timestamp';                 read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZLATITUDE';                   fex_col: 'Latitude';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLONGITUDE';                  fex_col: 'Longitude';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZHORIZONTALACCURACY';         fex_col: 'Horizontal Accuracy (m)';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZALTITUDE';                   fex_col: 'Altitude (m)';              read_as: ftFloat;       convert_as: '';         col_type: ftFloat;      show: True),
  (sql_col: 'DNT_ZVERTICALACCURACY';           fex_col: 'Vertical Accuracy (m)';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.