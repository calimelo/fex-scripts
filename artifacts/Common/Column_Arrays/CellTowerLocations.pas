unit CellTowerLocations;

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

  Array_Items_IOS_CELLTOWER: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';            fex_col: 'Timestamp';               read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_CI';                   fex_col: 'Cell ID';                 read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_TAC';                  fex_col: 'Location Area Code';      read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_MCC';                  fex_col: 'Mobile Country Code';     read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_MNC';                  fex_col: 'Mobile Network Code';     read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_LATITUDE';             fex_col: 'Latitude';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LONGITUDE';            fex_col: 'Longitude';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONFIDENCE';           fex_col: 'Confidence';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  //=========================================================================================================================================================================

begin
  if Name = 'IOS_CELLTOWER' then Result := Array_Items_IOS_CELLTOWER else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
