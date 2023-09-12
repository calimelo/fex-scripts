unit Gmail;

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

  Array_Items_GMAIL_PROTOBUF: TSQL_Table_array = ( {Fields are extracted from a compressed Protobuf}
{1}(sql_col: 'DNT_ZIPPED_MESSAGE_PROTO';    fex_col: 'ZIPPED_MESSAGE_PROTO'; read_as: ftString;      convert_as: '';          col_type: ftString;     show: False),
{2}(sql_col: 'DNT_TIMESTAMP';               fex_col: 'Date Received';        read_as: ftString;      convert_as: '';          col_type: ftDateTime;   show: True),
{3}(sql_col: 'DNT_TO';                      fex_col: 'To';                   read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
{4}(sql_col: 'DNT_FROM';                    fex_col: 'From';                 read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
{5}(sql_col: 'DNT_SUBJECT';                 fex_col: 'Subject';              read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
{6}(sql_col: 'DNT_MESSAGEPREVIEW';          fex_col: 'Message Preview';      read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
{7}(sql_col: 'DNT_MESSAGEID';               fex_col: 'Message ID';           read_as: ftString;      convert_as: '';          col_type: ftString;     show: True));
//{8}(sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';             read_as: ftString;      convert_as: '';          col_type: ftString;     show: True));

  Array_Items_GMAIL_OFFLINE_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_RECEIVEDDATEMS';          fex_col: 'Received';              read_as: ftFloat;       convert_as: 'UNIX_MS';   col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SUBJECT';                 fex_col: 'Subject';               read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_ADDRESS_FROM';            fex_col: 'From';                  read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_ADDRESS_TO';              fex_col: 'To';                    read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_SNIPPETHTML';             fex_col: 'Snippet';               read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_BODY';                    fex_col: 'Body';                  read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  (sql_col: 'DNT_CONVERSATIONID';          fex_col: 'Conversation ID';       read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
  );

begin
  if Name = 'GMAIL_ANDROID'         then Result := Array_Items_GMAIL_PROTOBUF else
  if Name = 'GMAIL_IOS'             then Result := Array_Items_GMAIL_PROTOBUF else
  if Name = 'GMAIL_OFFLINE_ANDROID' then Result := Array_Items_GMAIL_OFFLINE_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
