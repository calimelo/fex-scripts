unit IMO;

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

  Array_Items_ANDROID_CALLS: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';      fex_col: 'Message Date';  read_as: ftLargeInt;    convert_as: 'UNIX';         col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_CALL_TYPE';      fex_col: 'Call Type';     read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_NAME';           fex_col: 'Contact Name';  read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';    fex_col: 'Location';      read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  );

  Array_Items_ANDROID_CHAT: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';      fex_col: 'Message Date';  read_as: ftLargeInt;    convert_as: 'UNIX';         col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_LAST_MESSAGE';   fex_col: 'Message';       read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';    fex_col: 'Location';      read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  );

  Array_Items_ANDROID_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_NAME';           fex_col: 'Contact Name';   read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_DISPLAY';        fex_col: 'Display';        read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';    fex_col: 'Location';       read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  );

  //----

  Array_Items_IOS_CHAT: TSQL_Table_array = (
  (sql_col: 'DNT_ZSENDERTS';      fex_col: 'Message Date';   read_as: ftLargeInt;    convert_as: 'UNIX';         col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZTEXT';          fex_col: 'Message';        read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_ZA_UID';         fex_col: 'Remote User ID'; read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTYPE';          fex_col: 'Type';           read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHOTO_ID';      fex_col: 'Photo ID';       read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';    fex_col: 'Location';       read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  );

  Array_Items_IOS_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_ZALIAS';         fex_col: 'Alias';          read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDISPLAY';       fex_col: 'Display';        read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHONE';         fex_col: 'Phone';          read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';    fex_col: 'Location';       read_as: ftString;      convert_as: '';             col_type: ftString;     show: True),
  );

begin
  if Name = 'IMO_CALLS_ANDROID'    then Result := Array_Items_ANDROID_CALLS else
  if Name = 'IMO_CHAT_ANDROID'     then Result := Array_Items_ANDROID_CHAT else
  if Name = 'IMO_CONTACTS_ANDROID' then Result := Array_Items_ANDROID_CONTACTS else
  if Name = 'IMO_CHAT_IOS'         then Result := Array_Items_IOS_CHAT else
  if Name = 'IMO_CONTACTS_IOS'     then Result := Array_Items_IOS_CONTACTS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
