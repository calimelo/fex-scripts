{!NAME:      GoogleMaps.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit GoogleMaps;

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
  //(sql_col: 'DNT_Corpus';            fex_col: 'Corpus';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_key_string';        fex_col: 'Key String';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Timestamp';           fex_col: 'Timestamp';         read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  //(sql_col: 'DNT_merge_key';         fex_col: 'Merge Key';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_feature_fprint';    fex_col: 'Feature Fprint';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Latitude';            fex_col: 'Latitude';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Longitude';           fex_col: 'Longitude';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_local';          fex_col: 'Is Local';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_sync_item';         fex_col: 'Sync Item';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';         fex_col: 'Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_Name';                fex_col: 'Name Col';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_URL';                 fex_col: 'URL';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Address';             fex_col: 'Address';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_GOOGLEMAPCOORDINATES: TSQL_Table_array = (
  (sql_col: 'DNT_ZTOUCHED';            fex_col: 'Last Touched Date'; read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZXCOORD';             fex_col: 'X Coordinate';      read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_ZYCOORD';             fex_col: 'Y Coordinate';      read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_ZZOOM';               fex_col: 'Zoom Level';        read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_ZSIZE';               fex_col: 'Tile Size';         read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
  (sql_col: 'DNT_SQLLOCATION';         fex_col: 'Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'ANDROID'              then Result := Array_Items_Android else
  if Name = 'IOS'                  then Result := Array_Items_IOS else
  if Name = 'GOOGLEMAPCOORDINATES' then Result := Array_Items_GOOGLEMAPCOORDINATES else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
