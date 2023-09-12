unit FacebookMessenger;

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

  Array_Items_FACEBOOK_MESSENGER_CALLS_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_call_time';         fex_col: 'Call Time';              read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_thread_key';        fex_col: 'Thread Key';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_duration';          fex_col: 'Duration (sec)';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_call_role';         fex_col: 'Call Role';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_call_state';        fex_col: 'Call State';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_call_type';         fex_col: 'Call Type';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_message_id';        fex_col: 'Message ID';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_seen_or_played';    fex_col: 'Seen';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

  Array_Items_IOS_Messages: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP_MS';                fex_col: 'Timestamp';               read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_TEXT';                        fex_col: 'Message';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGE_ID';                  fex_col: 'Message ID';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SENDER_ID';                   fex_col: 'Sender ID';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_THREADS: TSQL_Table_array = (
  (sql_col: 'DNT_LAST_ACTIVITY_TIMESTAMP_MS';  fex_col: 'Last Activity Timestamp'; read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SNIPPET_SENDER_CONTACT_ID';   fex_col: 'Sender ID';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SNIPPET';                     fex_col: 'Snippet';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_THREAD_PICTURE_URL';          fex_col: 'Profile Picture';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_NULLSTATE_DESCRIPTION_TEXT2'; fex_col: 'App Status';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'FACEBOOK_MESSENGER_CALLS_ANDROID' then Result := Array_Items_FACEBOOK_MESSENGER_CALLS_ANDROID else
  if Name = 'FACEBOOK_MESSENGER_CHAT_IOS'      then Result := Array_Items_IOS_MESSAGES else
  if Name = 'FACEBOOK_MESSENGER_THREADS_IOS'   then Result := Array_Items_IOS_THREADS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
