{!NAME:      Tango.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Tango;

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
  
  Array_Items_Chat_Android: TSQL_Table_array = (
  (sql_col: 'DNT_create_time';                             fex_col: 'Create Time';                                read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_send_time';                               fex_col: 'Send Time';                                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Payload';                                 fex_col: 'Payload';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_msg_id';                                  fex_col: 'Msg ID';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_conv_id';                                 fex_col: 'Conv ID';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Type';                                    fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_media_id';                              fex_col: 'Media ID';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_share_id';                              fex_col: 'Share ID';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Direction';                               fex_col: 'Direction';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Status';                                fex_col: 'Status';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_del_status';                            fex_col: 'Del Status';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );  

begin
  if Name = 'TANGO_CHAT_ANDROID' then Result := Array_Items_Chat_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.