unit GoogleVoice;

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

  Array_Items_GOOGLE_VOICE_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_MESSAGE_TS';            fex_col: 'Timestamp';         read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
  (sql_col: 'DNT_MESSAGE_BLOB';          fex_col: 'Message';           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  (sql_col: 'DNT_CONVERSATION_ID';       fex_col: 'Conversation ID';   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  (sql_col: 'DNT_MESSAGE_ID';            fex_col: 'Message ID';        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

begin
  if Name = 'GOOGLE_VOICE_ANDROID' then Result := Array_Items_GOOGLE_VOICE_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
