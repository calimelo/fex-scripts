{!NAME:      Random_Chat.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Random_Chat;

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
  //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Time';                                    fex_col: 'Time Col';                                       read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Content';                                 fex_col: 'Content';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Messageid';                               fex_col: 'Message ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Userid';                                  fex_col: 'User ID';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Contenttype';                             fex_col: 'Contenttype';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Behaviortype';                          fex_col: 'Behaviortype';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Touserid';                              fex_col: 'Touserid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Othersideuserid';                       fex_col: 'Othersideuserid';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Readed';                                  fex_col: 'Readed';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Sendstatus';                            fex_col: 'Sendstatus';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  //if Name = 'ANDROID' then Result := Array_Items_Android;
  if Name = 'RANDOMCHAT_CHAT_IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.