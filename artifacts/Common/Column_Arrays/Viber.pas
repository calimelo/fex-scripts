{!NAME:      Viber.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Viber;

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
  //(sql_col: 'DNT_ID';                                   fex_col: '_Id';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_MSG_DATE';                                fex_col: 'Date';                                       read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  //(sql_col: 'DNT_address';                                 fex_col: 'Address';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_BODY';                                    fex_col: 'Body';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
//  (sql_col: 'DNT_read';                                    fex_col: 'Read';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
//  (sql_col: 'DNT_opened';                                  fex_col: 'Opened';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
//  (sql_col: 'DNT_status';                                  fex_col: 'Status';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
//  (sql_col: 'DNT_type';                                    fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
//  (sql_col: 'DNT_location_lat';                            fex_col: 'Location_Lat';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
//  (sql_col: 'DNT_location_lng';                            fex_col: 'Location_Lng';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sync_read';                             fex_col: 'Sync_Read';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_flag';                                  fex_col: 'Flag Col';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_token';                                 fex_col: 'Token';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_has_extras';                            fex_col: 'Has_Extras';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_uri';                             fex_col: 'Extra_Uri';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_mime';                            fex_col: 'Extra_Mime';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_status';                          fex_col: 'Extra_Status';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_seq';                                   fex_col: 'Seq';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_upload_id';                       fex_col: 'Extra_Upload_Id';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_download_id';                     fex_col: 'Extra_Download_Id';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_bucket_name';                     fex_col: 'Extra_Bucket_Name';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_duration';                        fex_col: 'Extra_Duration';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_fb_status';                             fex_col: 'Fb_Status';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_twitter_status';                        fex_col: 'Twitter_Status';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_thumbnail_x';                           fex_col: 'Thumbnail_X';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_thumbnail_y';                           fex_col: 'Thumbnail_Y';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_description';                           fex_col: 'Description';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_deleted';                               fex_col: 'Deleted Col';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_count';                                 fex_col: 'Count';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_group_id';                              fex_col: 'Group_Id';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_conversation_id';                       fex_col: 'Conversation_Id';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_conversation_type';                     fex_col: 'Conversation_Type';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_participant_id';                        fex_col: 'Participant_Id';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_extra_flags';                           fex_col: 'Extra_Flags';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZDATE';                                   fex_col: 'Date';                                       read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZTEXT';                                   fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZSTATE';                                  fex_col: 'State';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),            
  (sql_col: 'DNT_ZCALLDURATION';                           fex_col: 'Call Duration';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZCALLSCOUNT';                             fex_col: 'Calls Count';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZDELIVEREDCOUNT';                         fex_col: 'Delivered Count';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZFORWARDTYPE';                          fex_col: 'Forward Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZLIKESCOUNT';                           fex_col: 'Likes Count';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZLIKESTYPE';                            fex_col: 'Likes Type';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMESSAGEID';                            fex_col: 'Message ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSEQ,ZTOKEN';                           fex_col: 'Seq Token';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZUID';                                  fex_col: 'UID';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCONVERSATION';                         fex_col: 'Conversation';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z4_CONVERSATION';                       fex_col: '4 Conversation';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZLOCATION';                               fex_col: 'Viber Location';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZPHONENUMINDEX';                          fex_col: 'Phone Number Index';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSTATEDATE';                            fex_col: 'State Date';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCALLTYPE';                             fex_col: 'Call Type';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSYSTEMTYPE';                           fex_col: 'System Type';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZEMOTICONSRANGES';                      fex_col: 'Emotions Ranges';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZRANGES';                               fex_col: 'Ranges';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_PK';                                  fex_col: 'Z_PK';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_EN';                                  fex_col: 'Z_EN';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: 'Z_OPT';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_PC: TSQL_Table_array = (
  (sql_col: 'DNT_TextContent';                             fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_PCV11: TSQL_Table_array = (
  (sql_col: 'DNT_TimeStamp';                               fex_col: 'TimeStamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Body';                                    fex_col: 'Body';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ContactID';                               fex_col: 'ContactID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Name';                                    fex_col: 'Contact Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ClientName';                              fex_col: 'Client Name';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ViberContact';                            fex_col: 'ViberContact';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_IsRead';                                  fex_col: 'IsRead';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MessageType';                             fex_col: 'MessageType';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_PayloadPath';                             fex_col: 'PayloadPath';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ThumbnailPath';                           fex_col: 'ThumbnailPath';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'VIBER_CHAT_ANDROID'   then Result := Array_Items_Android else
  if Name = 'VIBER_CHAT_IOS'       then Result := Array_Items_IOS else
  if Name = 'VIBER_CHAT_PC'        then Result := Array_Items_PC else
  if Name = 'VIBER_CHAT_PC_V11'    then Result := Array_Items_PCV11 else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
