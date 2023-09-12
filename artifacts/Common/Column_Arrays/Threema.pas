unit Threema;

interface

uses
  Columns, DataStorage, SysUtils;

const
  SP = ' ';

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_THREEMA_CHAT_IOS: TSQL_Table_array = (
   (sql_col: 'DNT_ZDATE';                    fex_col: 'Created';                read_as: ftFloat;         convert_as: 'ABS';        col_type: ftDatetime;     show: True),
   (sql_col: 'DNT_ZDELIVERYDATE';            fex_col: 'Delivered Date';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZTEXT';                    fex_col: 'Content';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZFILENAME';                fex_col: 'Threema'+SP+'Filename';  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZFILESIZE';                fex_col: 'File Size';              read_as: ftInteger;       convert_as: '';           col_type: ftInteger;      show: True),
   (sql_col: 'DNT_ZMIMETYPE';                fex_col: 'Type';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZLATITUDE';                fex_col: 'Latitude';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZLONGITUDE';               fex_col: 'Longitude';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZPOIADDRESS';              fex_col: 'POI Address';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZREAD';                    fex_col: 'Read';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

begin
  if Name = 'THREEMA_CHAT_IOS' then Result := Array_Items_THREEMA_CHAT_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
