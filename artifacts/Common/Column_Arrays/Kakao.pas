{!NAME:      Kakao.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Kakao;

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

  Array_Items_Android: TSQL_Table_array = (
  //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_created_at';                              fex_col: 'Created At';                                 read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Type';                                    fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_chat_id';                                 fex_col: 'Chat Id';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_user_id';                                 fex_col: 'User Id';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Message';                                 fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Attachment';                              fex_col: 'Attachment';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_deleted_at';                              fex_col: 'Deleted At';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_client_message_id';                       fex_col: 'Client Message ID';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_prev_id';                                 fex_col: 'Prev Id';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Referer';                                 fex_col: 'Referer';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Supplement';                            fex_col: 'Supplement';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_V';                                       fex_col: 'V';                                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  // Kakao - iOS
  Array_Items_IOS: TSQL_Table_array = (
  //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Referer';                               fex_col: 'Referer';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Digitalitempackid';                     fex_col: 'Digitalitempackid';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Status';                                fex_col: 'Status';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Contactname';                           fex_col: 'Contactname';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Supplement';                            fex_col: 'Supplement';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Type2';                                 fex_col: 'Type2';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Thumbnailheight';                       fex_col: 'Thumbnailheight';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Leavememberuserid';                     fex_col: 'Leavememberuserid';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Emoticonreplacementtext';               fex_col: 'Emoticonreplacementtext';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Sentat';                                  fex_col: 'Sentat';                                     read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT_Extrainfo';                             fex_col: 'Extrainfo';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Updateat';                              fex_col: 'Updateat';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Serverlogid';                           fex_col: 'Serverlogid';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Type';                                  fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Clientmsgid';                           fex_col: 'Clientmsgid';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Joinmembersuserid';                     fex_col: 'Joinmembersuserid';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Readat';                                  fex_col: 'Read At';                                    read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Message';                                 fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Thumbnailurl';                            fex_col: 'Thumbnailurl';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Chatid';                                  fex_col: 'Chatid';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Thumbnailwidth';                        fex_col: 'Thumbnailwidth';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Emoticonsoundname';                     fex_col: 'Emoticonsoundname';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Leavememberids';                        fex_col: 'Leavememberids';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Inviteruserid';                         fex_col: 'Inviteruserid';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Feedtype';                              fex_col: 'Feedtype';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Attachment';                              fex_col: 'Attachment';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Userid';                                  fex_col: 'Userid';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'KAKAO_CHAT_ANDROID' then Result := Array_Items_ANDROID else
  if Name = 'KAKAO_CHAT_IOS'     then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.