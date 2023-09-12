unit Private_Photo_Vault;

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

  Array_Items_IOS_ALBUMS: TSQL_Table_array = (
  (sql_col: 'DNT_ZCREATIONDATE';                fex_col: 'Album Created';       read_as: ftFloat;       convert_as: 'ABS';   col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZLASTMODIFICATIONDATE';        fex_col: 'Album Last Modified'; read_as: ftFloat;       convert_as: 'ABS';   col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZTITLE';                       fex_col: 'Album Title';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_ZALBUMTYPE';                   fex_col: 'Album Type';          read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';            read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  );

  Array_Items_IOS_MEDIA: TSQL_Table_array = (
  (sql_col: 'DNT_ZCREATIONDATE';                fex_col: 'Created Date';        read_as: ftFloat;       convert_as: 'ABS';   col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZLASTMODIFICATIONDATE';        fex_col: 'Modified Date';       read_as: ftFloat;       convert_as: 'ABS';   col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZFILETYPE';                    fex_col: 'File Type';           read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLARGEFILE';                   fex_col: 'Large File';          read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTHUMBFILE';                   fex_col: 'Thumb File';          read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';            read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS_ALBUMS' then Result := Array_Items_IOS_ALBUMS else
  if Name = 'IOS_MEDIA' then Result := Array_Items_IOS_MEDIA else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
