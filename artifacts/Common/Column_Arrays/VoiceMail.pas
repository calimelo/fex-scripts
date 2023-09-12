{!NAME:      VoiceMail.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit VoiceMail;

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
  (sql_col: 'DNT_Rowid';                                   fex_col: 'Rowid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_remote_uid';                              fex_col: 'Remote Uid';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Date';                                    fex_col: 'Date';                                       read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Token';                                   fex_col: 'Token';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Sender';                                  fex_col: 'Sender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_callback_num';                            fex_col: 'Callback Num';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Duration';                                fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Expiration';                              fex_col: 'Expiration';                                 read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_trashed_date';                            fex_col: 'Trashed Date';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Flags';                                   fex_col: 'Flags';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

begin
  if Name = 'IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
