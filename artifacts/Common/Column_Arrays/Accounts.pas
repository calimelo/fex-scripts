unit Accounts;

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

  Array_Items_ACCOUNTS_ANDROID: TSQL_Table_array = (
  //(sql_col: 'DNT__id';                            fex_col: '_id';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True), 
  (sql_col: 'DNT_name';                             fex_col: 'User Name';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_password';                         fex_col: 'Password';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_type';                             fex_col: 'Account Type';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                      fex_col: 'Location';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_ACCOUNTS_IOS: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                           fex_col: ' Pk';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                          fex_col: ' Ent';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                          fex_col: ' Opt';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSUPPORTSAUTHENTICATION';        fex_col: 'Supportsauthentication';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSUPPORTSMULTIPLEACCOUNTS';      fex_col: 'Supportsmultipleaccounts';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZVISIBILITY';                    fex_col: 'Visibility';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZACCOUNTTYPEDESCRIPTION';          fex_col: 'Account Type Description';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCREDENTIALPROTECTIONPOLICY';      fex_col: 'Credential Protection Policy';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCREDENTIALTYPE';                  fex_col: 'Credential Type';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZIDENTIFIER';                      fex_col: 'Identifier';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                      fex_col: 'Location';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'ACCOUNTS_IOS' then Result := Array_Items_ACCOUNTS_IOS else
  if Name = 'ACCOUNTS_ANDROID' then Result := Array_Items_ACCOUNTS_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
