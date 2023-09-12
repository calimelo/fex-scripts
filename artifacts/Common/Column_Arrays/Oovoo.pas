{!NAME:      Oovoo.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Oovoo;

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

  Array_Items_OOVOO_USER_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_displayName';                             fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_friendCount';                             fex_col: 'Friend Count';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phone';                                   fex_col: 'Phone';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_birthday';                                fex_col: 'Birthday';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_id';                                      fex_col: 'ID Num';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_profilePicURL';                           fex_col: 'Profile Picture URL';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_OOVOO_USER_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_displayName';                             fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_username';                                fex_col: 'User Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_email';                                   fex_col: 'Email';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_birthday';                                fex_col: 'Birthday';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_profilePicURL';                           fex_col: 'Profile Picture URL';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'OOVOO_USER_ANDROID'   then Result := Array_Items_OOVOO_USER_ANDROID else
  if Name = 'OOVOO_USER_IOS'  then Result := Array_Items_OOVOO_USER_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.