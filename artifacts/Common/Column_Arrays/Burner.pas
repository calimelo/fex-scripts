unit Burner;

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

  Array_Items_BURNER_CONTACTS_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_date_created';       fex_col: 'Date Created';            read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_last_updated_date';  fex_col: 'Last Updated Date';       read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_phone_number';       fex_col: 'Phone Number';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_name';               fex_col: 'Burner Name';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_burner_id';          fex_col: 'Burner ID';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_contact_id';         fex_col: 'Contact ID';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';        fex_col: 'Location';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

  Array_Items_BURNER_CONTACTS_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_RECEIVER_DATA'; {FIRST}    fex_col: 'Receiver Data';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_DATECREATED';              fex_col: 'Created';         read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_CONTACTNAME';              fex_col: 'Contact Name';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTACTID';                fex_col: 'Contact ID';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_PHONENUMBER';              fex_col: 'Phone Number';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_BURNERIDS';                fex_col: 'Burner ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_BURNER_MESSAGES_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_RECEIVER_DATA'; {FIRST}    fex_col: 'Receiver Data';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_DATECREATED';              fex_col: 'Created';         read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_MESSAGETYPE';              fex_col: 'Type';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGE';                  fex_col: 'Message';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTACTPHONENUMBER';       fex_col: 'Contact';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_USERID';                   fex_col: 'User ID';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_BURNERID';                 fex_col: 'Burner ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_DIRECTION';                fex_col: 'Direction';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MEDIAURL';                 fex_col: 'Media URL';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_VOICEURL';                 fex_col: 'Voicemail URL';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGEDURATION';          fex_col: 'Message Duration';read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_BURNER_MESSAGES_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_date_created';          fex_col: 'Date Created';               read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_contact_phone_number';  fex_col: 'Contact Phone Number';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_message';               fex_col: 'Message';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_direction';             fex_col: 'Direction';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_duration';              fex_col: 'Duration';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_asset_url';             fex_col: 'Media URL';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_burner_id';             fex_col: 'Burner ID';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_connected';             fex_col: 'connected';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_message_id';            fex_col: 'Message ID';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_message_type';          fex_col: 'Message Type';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_read';                  fex_col: 'Read';                       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_sid';                   fex_col: 'SID';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_state';                 fex_col: 'State';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_user_id';               fex_col: 'User ID';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                   read_as: ftString;        convert_as: '';           col_type: ftString;     show: True),
  );

  Array_Items_BURNER_NUMBERS_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_date_created';          fex_col: 'Date Created';               read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_phone_number_id';       fex_col: 'Phone Number';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_burner_id';             fex_col: 'Burner ID';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                   read_as: ftString;        convert_as: '';           col_type: ftString;     show: True),
  );

begin
  if Name = 'BURNER_CACHE_IOS'          then Result := Array_Items_BURNER_MESSAGES_IOS else
  if Name = 'BURNER_CONTACTS_ANDROID'   then Result := Array_Items_BURNER_CONTACTS_ANDROID else
  if Name = 'BURNER_CONTACTS_IOS'       then Result := Array_Items_BURNER_CONTACTS_IOS else
  if Name = 'BURNER_MESSAGES_IOS'       then Result := Array_Items_BURNER_MESSAGES_IOS else
  if Name = 'BURNER_MESSAGES_ANDROID'   then Result := Array_Items_BURNER_MESSAGES_ANDROID else
  if Name = 'BURNER_NUMBERS_ANDROID'    then Result := Array_Items_BURNER_NUMBERS_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.