unit TextNow;

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

  Array_Items_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_DATE';             fex_col: 'Date/Time';        read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_CONTACT_NAME';     fex_col: 'Contact ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGE_TEXT';     fex_col: 'Message';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_ANDROID_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_CONTACT_NAME';     fex_col: 'Contact Name';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTACT_VALUE';    fex_col: 'Contact ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTACT_TYPE';     fex_col: 'Contact Type';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CHAT: TSQL_Table_array = (
  (sql_col: 'DNT_ZREMOTETIMESTAMP'; fex_col: 'Server Date/Time'; read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZLOCALTIMESTAMP';  fex_col: 'Device Date/Time'; read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZAUTHORNAME';      fex_col: 'Author';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCONTENT';         fex_col: 'Message';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDIRECTION';       fex_col: 'Direction';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZREAD';            fex_col: 'Read';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDIRECTION';       fex_col: 'Message Status';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZMESSAGEID';       fex_col: 'Message ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_ZCONTACTNAME';     fex_col: 'Contact Name';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCONTACTVALUE';    fex_col: 'Contact Value';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCONTACTLABEL';    fex_col: 'Contact Label';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Z_ENT';            fex_col: 'Contact Type';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_PROFILE: TSQL_Table_array = (
  (sql_col: 'DNT_ZLOCALTIMESTAMP'; fex_col: 'Last Updated';     read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZUSERNAME';       fex_col: 'Username';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFIRSTNAME';      fex_col: 'Contact Name';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLASTNAME';       fex_col: 'Contact Value';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZEMAIL';          fex_col: 'Contact Label';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHONENUMBER';    fex_col: 'Phone Number';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';     fex_col: 'Location';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'TEXTNOW_CHAT_ANDROID'     then Result := Array_Items_ANDROID else
  if Name = 'TEXTNOW_CONTACTS_ANDROID' then Result := Array_Items_ANDROID_CONTACTS else
  if Name = 'TEXTNOW_CHAT_IOS'         then Result := Array_Items_IOS_CHAT else
  if Name = 'TEXTNOW_CONTACTS_IOS'     then Result := Array_Items_IOS_CONTACTS else
  if Name = 'TEXTNOW_PROFILE_IOS'      then Result := Array_Items_IOS_PROFILE else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
