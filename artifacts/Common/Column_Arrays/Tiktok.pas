unit Tiktok;

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

  Array_Items_ANDROID_CHAT: TSQL_Table_array = (
  (sql_col: 'DNT_CREATED_TIME';     fex_col: 'Created Time';      read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SENDER';           fex_col: 'Sender';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTENT';          fex_col: 'Message';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MSG_SERVER_ID';    fex_col: 'Server Message ID'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CHAT: TSQL_Table_array = (
  (sql_col: 'DNT_SERVERCREATEDAT';  fex_col: 'Created Date/Time'; read_as: ftFloat;       convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SENDER';           fex_col: 'Sender';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTENT';          fex_col: 'Message';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_HASREAD';          fex_col: 'Read';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SERVERMESSAGEID';  fex_col: 'Server Message ID'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_CUSTOMID';         fex_col: 'User ID';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_NICKNAME';         fex_col: 'Nickname';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_URL1';             fex_col: 'Profile URL';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'TIKTOK_CHAT_ANDROID'     then Result := Array_Items_ANDROID_CHAT else
  if Name = 'TIKTOK_CONTACTS_IOS'     then Result := Array_Items_IOS_CONTACTS else
  if Name = 'TIKTOK_CHAT_IOS'         then Result := Array_Items_IOS_CHAT else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
