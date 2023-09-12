unit GoogleChat;

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

  Array_Items_GOOGLE_CHAT_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_create_time';          fex_col: 'Created';         read_as: ftLargeInt;      convert_as: 'UNIX_MicroS'; col_type: ftDateTime;     show: True),
  (sql_col: 'DNT_text_body';            fex_col: 'Message';         read_as: ftString;        convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_creator_id';           fex_col: 'Creator ID';      read_as: ftString;        convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_group_id';             fex_col: 'Group ID';        read_as: ftString;        convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';        read_as: ftString;        convert_as: '';            col_type: ftString;       show: True),
  );

  Array_Items_GOOGLE_CHAT_JSON_TAKEOUT: TSQL_Table_array = (
  (sql_col: 'DNT_created_dt_convert';   fex_col: 'Created Date';                  read_as: ftString;    convert_as: '';            col_type: ftDateTime;     show: True),
  (sql_col: 'DNT_created_date';         fex_col: 'Created Date (Str)';            read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_text';                 fex_col: 'Message';                       read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_name';                 fex_col: 'Username';                      read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_email';                fex_col: 'Email';                         read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_message_id';           fex_col: 'Message ID';                    read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_topic_id';             fex_col: 'Topic ID';                      read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_original_name';        fex_col: 'Attached Files Original Name';  read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_export_name';          fex_col: 'Attached Files Export Name';    read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_meeting_url';          fex_col: 'Meeting URL';                   read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_snippet';              fex_col: 'Snippet';                       read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_url';                  fex_col: 'URL';                           read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_title';                fex_col: 'Title';                         read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  (sql_col: 'DNT_user_type';            fex_col: 'User Type';                     read_as: ftString;    convert_as: '';            col_type: ftString;       show: True),
  );

begin
  if Name = 'GOOGLE_CHAT_ANDROID' then Result := Array_Items_GOOGLE_CHAT_ANDROID else
  if Name = 'DNT_GOOGLE_CHAT_JSON_TAKEOUT' then Result := Array_Items_GOOGLE_CHAT_JSON_TAKEOUT else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
