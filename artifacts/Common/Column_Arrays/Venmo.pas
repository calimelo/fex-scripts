unit Venmo;

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

  Array_Items_Chat_Android: TSQL_Table_array = (
  (sql_col: 'DNT_CREATED_TIME';               fex_col: 'Created Time String';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_COMMENT_MESSAGE';            fex_col: 'Body';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_COMMENT_ID';                 fex_col: 'Comment ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'VENMO_CHAT_ANDROID'   then Result := Array_Items_Chat_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
