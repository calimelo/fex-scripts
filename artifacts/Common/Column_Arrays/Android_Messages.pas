unit Android_Messages;

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

  Array_Items_ANDROID_ACCOUNTS: TSQL_Table_array = (
   (sql_col: 'DNT_account_name';           fex_col: 'Account Name';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_account_type';           fex_col: 'Account Type';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

Array_Items_ANDROID_CALL_LOGS: TSQL_Table_array = (
   (sql_col: 'DNT_date';                   fex_col: 'Call Date';             read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
   (sql_col: 'DNT_number';                 fex_col: 'Number';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_transcription';          fex_col: 'Transcription';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_geocoded_location';      fex_col: 'Geo Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_countryiso';             fex_col: 'Country';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_duration';               fex_col: 'Duration (sec)';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_is_read';                fex_col: 'Is Read';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_type';                   fex_col: 'Type';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_ANDROID_MESSAGES: TSQL_Table_array = (
   (sql_col: 'DNT_SENT_TIMESTAMP';         fex_col: 'Message Sent';          read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
   (sql_col: 'DNT_RECEIVED_TIMESTAMP';     fex_col: 'Message Received';      read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
   //(sql_col: 'DNT_';                     fex_col: 'Message Status';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   //(sql_col: 'DNT_';                     fex_col: 'Message Type';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'ANDROID_ACCOUNTS'  then Result := Array_Items_ANDROID_ACCOUNTS else
  if Name = 'ANDROID_CALL_LOGS' then Result := Array_Items_ANDROID_CALL_LOGS else
  if Name = 'ANDROID_MESSAGES'  then Result := Array_Items_ANDROID_MESSAGES else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.