unit Google_Duo;

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

  Array_Items_GOOGLE_DUO_CHAT_ANDROID: TSQL_Table_array = ( // https://www.stark4n6.com/2021/08/google-duo-android-ios-forensic-analysis.html
  (sql_col: 'DNT_TIMESTAMP_USEC';                fex_col: 'Date/Time';          read_as: ftLargeInt;    convert_as: 'UNIX_MicroS'; col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SELF_ID';                       fex_col: 'Self ID';            read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_OTHER_ID';                      fex_col: 'Other ID';           read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_ACTIVITY_TYPE';                 fex_col: 'Type';               read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_CALL_STATE';                    fex_col: 'Status';             read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_OUTGOING';                      fex_col: 'Direction';          read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';           read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  );

  Array_Items_GOOGLE_DUO_CHAT_IOS: TSQL_Table_array = ( //https://www.stark4n6.com/2021/08/google-duo-android-ios-forensic-analysis.html
  (sql_col: 'DNT_call_history_timestamp';        fex_col: 'Date/Time';          read_as: ftLargeInt;    convert_as: 'UNIX';        col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_call_history_other_user_id';    fex_col: 'Other User ID';      read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_call_history_is_outgoing_call'; fex_col: 'Direction';          read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_call_history_is_video_call';    fex_col: 'Is Video Call';      read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_call_history_duration';         fex_col: 'Call Duration';      read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';           read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  );

  Array_Items_GOOGLE_DUO_USERS_IOS: TSQL_Table_array = (
   (sql_col: 'DNT_contact_sync_date';            fex_col: 'Contact Sync Date';  read_as: ftLargeInt;    convert_as: 'UNIX_MicroS';        col_type: ftDateTime;   show: True),
   (sql_col: 'DNT_contact_name';                 fex_col: 'Contact Name';       read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
   (sql_col: 'DNT_contact_id';                   fex_col: 'Contact ID';         read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
   (sql_col: 'DNT_contact_id_type';              fex_col: 'Contact Type';       read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
   (sql_col: 'DNT_contact_is_blocked';           fex_col: 'Blocked';            read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
   (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';           read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  );

begin
  if Name = 'GOOGLE_DUO_CHAT_ANDROID' then Result := Array_Items_GOOGLE_DUO_CHAT_ANDROID else
  if Name = 'GOOGLE_DUO_CHAT_IOS' then Result := Array_Items_GOOGLE_DUO_CHAT_IOS else
  if Name = 'GOOGLE_DUO_USERS_IOS' then Result := Array_Items_GOOGLE_DUO_USERS_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
