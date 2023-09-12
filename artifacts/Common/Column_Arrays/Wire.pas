unit Wire;

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

  Array_Items_WIRE_CHAT_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_TIME';                         fex_col: 'Time';                read_as: ftFloat;       convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_CONTENT';                      fex_col: 'Content';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONV_ID';                      fex_col: 'Conversation ID';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_USER_ID';                      fex_col: 'User ID';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MSG_TYPE';                     fex_col: 'Msg Type';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MSG_STATE';                    fex_col: 'Msg State';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_WIRE_CHAT_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZSERVERTIMESTAMP';             fex_col: 'Server Date';         read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZNORMALIZEDTEXT';              fex_col: 'Message';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSENDERCLIENTID';              fex_col: 'Sender ID';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDURATION';                    fex_col: 'Duration';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_WIRE_USER_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';                    fex_col: 'Timestamp';           read_as: ftFloat;       convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_NAME';                         fex_col: 'User Name';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_EMAIL';                        fex_col: 'Email';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_PHONE';                        fex_col: 'Phone';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_HANDLE';                       fex_col: 'Handle';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_WIRE_USER_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZEMAILADDRESS';                fex_col: 'Email Address';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZHANDLE';                      fex_col: 'Handle';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZNAME';                        fex_col: 'User Name';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHONENUMBER';                 fex_col: 'Phone Number';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'WIRE_CHAT_ANDROID' then Result := Array_Items_WIRE_CHAT_ANDROID else
  if Name = 'WIRE_CHAT_IOS' then Result := Array_Items_WIRE_CHAT_IOS else
  if Name = 'WIRE_USER_ANDROID' then Result := Array_Items_WIRE_USER_ANDROID else
  if Name = 'WIRE_USER_IOS' then Result := Array_Items_WIRE_USER_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
