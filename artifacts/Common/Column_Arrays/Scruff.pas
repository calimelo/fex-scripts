{!NAME:      Scruff.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Scruff;

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
  //(sql_col: 'DNT_thread_id';                             fex_col: 'Thread ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_remote_id';                             fex_col: 'Remote ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Guid';                                  fex_col: 'Guid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_created_at';                              fex_col: 'Created At';                                 read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_updated_at';                              fex_col: 'Updated At';                                 read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Message';                                 fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sender_id';                               fex_col: 'Sender ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_recipient_id';                            fex_col: 'Recipient ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Version';                               fex_col: 'Version';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_message_type';                            fex_col: 'Message Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Unread';                                  fex_col: 'Unread';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_delivery_error';                        fex_col: 'Delivery Error';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_album_image_id';                        fex_col: 'Album Image ID';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_post_success';                          fex_col: 'Post Success';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_fullsize_width';                        fex_col: 'Fullsize Width';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_fullsize_height';                       fex_col: 'Fullsize Height';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Deleted';                               fex_col: 'Deleted Col';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS: TSQL_Table_array = (
  //(sql_col: 'DNT_remote_id';                             fex_col: 'Remote ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Guid';                                  fex_col: 'Guid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_created_at';                              fex_col: 'Created At';                                 read_as: ftFloat;       convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_updated_at';                              fex_col: 'Updated At';                                 read_as: ftFloat;       convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Message';                                 fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_thread_key';                              fex_col: 'Thread Key';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sender_id';                               fex_col: 'Sender ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_recipient_id';                            fex_col: 'Recipient ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Version';                               fex_col: 'Version';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_thumbnail_url';                         fex_col: 'Thumbnail Url';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_fullsize_url';                            fex_col: 'Fullsize Url';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_fullsize_width';                        fex_col: 'Fullsize Width';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_fullsize_height';                       fex_col: 'Fullsize Height';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_full_resolution';                       fex_col: 'Full Resolution';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_message_type';                            fex_col: 'Message Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Unread';                                  fex_col: 'Unread';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Deleted';                               fex_col: 'Deleted Col';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_delivery_error';                        fex_col: 'Delivery Error';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_post_success';                          fex_col: 'Post Success';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_album_image_id';                        fex_col: 'Album Image ID';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_from_apns';                             fex_col: 'From Apns';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_from_query';                            fex_col: 'From Query';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Restricted';                            fex_col: 'Restricted';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_query_matched';                         fex_col: 'Query Matched';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'SCRUFF_CHAT_ANDROID'   then Result := Array_Items_Android else
  if Name = 'SCRUFF_CHAT_IOS'       then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.