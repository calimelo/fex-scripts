{!NAME:      Anti_Chat.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Anti_Chat;

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

  Array_Items_IOS: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                                  fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZAVATAR';                               fex_col: 'Avatar';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZBLESSED';                              fex_col: 'Blessed';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOLOR';                                fex_col: 'Color';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCREATEDAT';                              fex_col: 'Createdat';                                  read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZUPDATEDAT';                              fex_col: 'Updatedat';                                  read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZMESSAGE';                                fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDIALOGUE';                               fex_col: 'Dialogue';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZOBJECTID';                               fex_col: 'Objectid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZRECEIVER';                               fex_col: 'Receiver';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSENDER';                                 fex_col: 'Sender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSENDERID';                               fex_col: 'Senderid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHOTO';                                  fex_col: 'Photo';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'ANTICHAT_CHAT_IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.