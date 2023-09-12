unit SignificantLocations;

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
  (sql_col: 'DNT_ZCREATIONDATE';                 fex_col: 'Created';           read_as: ftLargeInt;    convert_as: 'ABS';    col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZSUBTHOROUGHFARE';              fex_col: 'Street Number';     read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTHOROUGHFARE';                 fex_col: 'Street';            read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLOCALITY';                     fex_col: 'City';              read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZADMINISTRATIVEAREACODE';       fex_col: 'State';             read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPOSTALCODE';                   fex_col: 'Zip';               read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCOUNTRYCODE';                  fex_col: 'Country';           read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZAREASOFINTEREST';              fex_col: 'Areas Of Interest'; read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLOCATIONLATITUDE';             fex_col: 'Latitude';          read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLOCATIONLONGITUDE';            fex_col: 'Longitude';         read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';          read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPLACECREATIONDATE';            fex_col: 'Created';           read_as: ftLargeInt;    convert_as: 'ABS';    col_type: ftDateTime;   show: True),
  );

  Array_Items_IOS_LOCATIONVISITS: TSQL_Table_array = (
  (sql_col: 'DNT_ZCREATIONDATE';                 fex_col: 'Created';           read_as: ftLargeInt;    convert_as: 'ABS';    col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZENTRYDATE';                    fex_col: 'Date Entry';        read_as: ftLargeInt;    convert_as: 'ABS';    col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZEXITDATE';                     fex_col: 'Date Exit';         read_as: ftLargeInt;    convert_as: 'ABS';    col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZLOCATIONLATITUDE';             fex_col: 'Latitude';          read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLOCATIONLONGITUDE';            fex_col: 'Longitude';         read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLOCATIONOFINTERESTCONFIDENCE'; fex_col: 'Confidence';        read_as: ftString;      convert_as: '';       col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS_LOCAL'   then Result := Array_Items_IOS else
  if Name = 'IOS_CLOUDV2' then Result := Array_Items_IOS else
  if Name = 'IOS_LOCATIONVISITS' then Result := Array_Items_IOS_LOCATIONVISITS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.