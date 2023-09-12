unit IOS_Mail;

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

  Array_Items_IOS_MAIL_ADDRESSES: TSQL_Table_array = (
  (sql_col: 'DNT_ADDRESS';          fex_col: 'Address';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_COMMENT';          fex_col: 'Comment';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';        read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  );

  Array_Items_IOS_MAIL: TSQL_Table_array = (
  (sql_col: 'DNT_DATE_SENT';        fex_col: 'Date Sent';       read_as: ftFloat;       convert_as: 'UNIX';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_DATE_RECEIVED';    fex_col: 'Date Received';   read_as: ftFloat;       convert_as: 'UNIX';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SENDER';           fex_col: 'Sender';          read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SUBJECT';          fex_col: 'Subject';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SUMMARY';          fex_col: 'Summary';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGE_ID';       fex_col: 'Message ID';      read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_URL';              fex_col: 'Mailbox';         read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SIZE';             fex_col: 'Size';            read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_READ';             fex_col: 'Read';            read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_DELETED';          fex_col: 'Is Deleted';      read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';        read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS_MAIL' then Result := Array_Items_IOS_MAIL else
  if Name = 'IOS_MAIL_ADDRESSES' then Result := Array_Items_IOS_MAIL_ADDRESSES else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.