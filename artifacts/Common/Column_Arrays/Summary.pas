unit Summary;

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

  Array_Items_Summary_Query: TSQL_Table_array = (
    (sql_col: 'DNT_URL';        fex_col: 'URL';             read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_QUERY';      fex_col: 'Query';           read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_ENTRY_PATH'; fex_col: 'Origin Path';     read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_ENTRY_NAME'; fex_col: 'Origin Filename'; read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_LOCATION';   fex_col: 'Location';        read_as: ftString;    convert_as: '';       col_type: ftString;     show: True));

  Array_Items_Summary_Url_Only: TSQL_Table_array = (
    (sql_col: 'DNT_URL';        fex_col: 'URL';             read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_ENTRY_PATH'; fex_col: 'Origin Path';     read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_ENTRY_NAME'; fex_col: 'Origin Filename'; read_as: ftString;    convert_as: '';       col_type: ftString;     show: True),
    (sql_col: 'DNT_LOCATION';   fex_col: 'Location';        read_as: ftString;    convert_as: '';       col_type: ftString;     show: True));

begin
  if Name = 'SUMMARY_BING'       then Result := Array_Items_Summary_Query else
  if Name = 'SUMMARY_CLOUD'      then Result := Array_Items_Summary_Url_Only else
  if Name = 'SUMMARY_DATING'     then Result := Array_Items_Summary_Url_Only else
  if Name = 'SUMMARY_FACEBOOK'   then Result := Array_Items_Summary_Url_Only else
  if Name = 'SUMMARY_QUERY'      then Result := Array_Items_Summary_Query else
  if Name = 'SUMMARY_SHIPPING'   then Result := Array_Items_Summary_Url_Only else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.