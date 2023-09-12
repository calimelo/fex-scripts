{!NAME:      Telegram.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Telegram;

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
  
  Array_Items_TELEGRAM_CHAT_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_Date';                     fex_col: 'Date';           read_as: ftLargeInt;    convert_as: 'UNIX';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_name';                     fex_col: 'Partner';        read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_Data';                     fex_col: 'Data';           read_as: ftBytes;       convert_as: 'BlobBytes'; col_type: ftString;     show: True),
  (sql_col: 'DNT_Mid';                      fex_col: 'MID';            read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_Uid';                      fex_col: 'UID';            read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_read_state';               fex_col: 'Read';           read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_Out';                      fex_col: 'Direction';      read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';       read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  );

  Array_Items_TELEGRAM_CHAT_V29_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_Docid';                    fex_col: 'Docid';          read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_C0Text';                   fex_col: 'C0Text';         read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';       read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  );
  
  Array_Items_TELEGRAM_CHAT_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_KEY1';                     fex_col: 'Date';           read_as: ftBytes;       convert_as: 'BlobBytes'; col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_KEY2';                     fex_col: 'Chat ID';        read_as: ftBytes;       convert_as: 'BlobBytes'; col_type: ftString;     show: True),
  (sql_col: 'DNT_KEY3';                     fex_col: 'Message ID';     read_as: ftBytes;       convert_as: 'BlobBytes'; col_type: ftString;     show: True),
  (sql_col: 'DNT_VALUE';                    fex_col: 'Message';        read_as: ftString;      convert_as: 'BlobBytes'; col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';       read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  );

  Array_Items_TELEGRAM_USER_IOS: TSQL_Table_array = (
{1}(sql_col: 'DNT_CARVE';                   fex_col: 'User ID';        read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
{2}(sql_col: 'DNT_CARVE';                   fex_col: 'First Name';     read_as: ftBytes;       convert_as: '';          col_type: ftString;     show: True),
{3}(sql_col: 'DNT_CARVE';                   fex_col: 'Last Name';      read_as: ftBytes;       convert_as: '';          col_type: ftString;     show: True),
{4}(sql_col: 'DNT_CARVE';                   fex_col: 'User Name';      read_as: ftBytes;       convert_as: '';          col_type: ftString;     show: True),
{5}(sql_col: 'DNT_CARVE';                   fex_col: 'Phone Number';   read_as: ftBytes;       convert_as: '';          col_type: ftString;     show: True),
{6}(sql_col: 'DNT_CARVE';                   fex_col: 'Recovery Type';  read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  );

begin
  if Name = 'TELEGRAM_CHAT_ANDROID' then Result := Array_Items_TELEGRAM_CHAT_ANDROID else
  if Name = 'TELEGRAM_CHAT_V29_IOS' then Result := Array_Items_TELEGRAM_CHAT_V29_IOS else
  if Name = 'TELEGRAM_CHAT_IOS'     then Result := Array_Items_TELEGRAM_CHAT_IOS else
  if Name = 'TELEGRAM_USER_IOS'     then Result := Array_Items_TELEGRAM_USER_IOS else
  if Name = 'TELEGRAM_T7_CHAT_IOS'  then Result := Array_Items_TELEGRAM_CHAT_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.