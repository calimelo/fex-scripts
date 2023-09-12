unit Gettr;

interface

uses
  Columns, DataStorage, SysUtils;

const
  SP = ' ';

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
  Array_Items_GETTR_CHAT_ANDROID: TSQL_Table_array = ( // Heart Rate
   (sql_col: 'DNT_created_at';        fex_col: 'Created';          read_as: ftLargeInt;      convert_as: 'UNIX';       col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_user_id';           fex_col: 'User ID';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_message_text';      fex_col: 'Message';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_attachments';       fex_col: 'Attachments';      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_channel_cid';       fex_col: 'Channel ID';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_type';              fex_col: 'Type';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True));

begin
  if Name = 'GETTR_CHAT_ANDROID'      then Result := Array_Items_GETTR_CHAT_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.