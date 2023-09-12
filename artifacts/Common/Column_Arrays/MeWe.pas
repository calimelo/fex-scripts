unit MeWe;

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

  Array_Items_MEWE_CHAT_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_CREATEDAT';                  fex_col: 'Created';          read_as: ftLargeInt;    convert_as: 'UNIX';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_THREADID';                   fex_col: 'Thread ID';        read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_TEXTPLAIN';                  fex_col: 'Text';             read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_OWNERNAME';                  fex_col: 'Owner Name';       read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_OWNERID';                    fex_col: 'Owner ID';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_ATTACHMENTNAME';             fex_col: 'Attachment Name';  read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_OWNERID';                    fex_col: 'Owner ID';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  );

begin
  if Name = 'MEWE_CHAT_ANDROID' then
    Result := Array_Items_MEWE_CHAT_ANDROID
  else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.