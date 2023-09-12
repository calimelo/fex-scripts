{!NAME:      Aquamail.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Aquamail;

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
  //(sql_col: 'DNT__id';                                   fex_col: ' Id';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_when_date';                               fex_col: 'When Date';                                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Subject';                                 fex_col: 'Subject';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_preview_utf8';                            fex_col: 'Preview Utf8';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_who_from';                                fex_col: 'Who From';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_who_reply_to';                            fex_col: 'Who Reply To';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_who_to';                                  fex_col: 'Who To';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_who_cc';                                  fex_col: 'Who Cc';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_who_bcc';                                 fex_col: 'Who Bcc';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_msg_id';                                  fex_col: 'Msg Id';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Flags';                                 fex_col: 'Flags';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_del';                                fex_col: 'Op Del';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_flags';                              fex_col: 'Op Flags';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_hide';                               fex_col: 'Op Hide';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_partial_load_done';                     fex_col: 'Partial Load Done';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Priority';                              fex_col: 'Priority';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_refs_list';                             fex_col: 'Refs List';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_full_headers';                          fex_col: 'Full Headers';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_is_unread_cache';                       fex_col: 'Is Unread Cache';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_is_deleted_cache';                      fex_col: 'Is Deleted Cache';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_is_starred_cache';                      fex_col: 'Is Starred Cache';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_is_unread_starred_cache';               fex_col: 'Is Unread Starred Cache';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_linked_folder_id';                      fex_col: 'Linked Folder Id';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_linked_folder_generation';              fex_col: 'Linked Folder Generation';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_misc_flags';                            fex_col: 'Misc Flags';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_size_display';                          fex_col: 'Size Display';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_size_full_message';                     fex_col: 'Size Full Message';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_size_attachments';                      fex_col: 'Size Attachments';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_has_attachments';                       fex_col: 'Has Attachments';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_has_calendars';                         fex_col: 'Has Calendars';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_text_uid';                              fex_col: 'Text Uid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_numeric_uid';                           fex_col: 'Numeric Uid';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_change_key';                            fex_col: 'Change Key';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Generation';                            fex_col: 'Generation';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_pop3_offset';                           fex_col: 'Pop3 Offset';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sync_seed';                             fex_col: 'Sync Seed';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_preview_attachments';                   fex_col: 'Preview Attachments';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_thread_id';                             fex_col: 'Thread Id';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_mime_type';                   fex_col: 'Body Main Mime Type';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_encoding';                    fex_col: 'Body Main Encoding';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_charset';                     fex_col: 'Body Main Charset';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_size';                        fex_col: 'Body Main Size';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_fetched_size';                fex_col: 'Body Main Fetched Size';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_fetch_state';                 fex_col: 'Body Main Fetch State';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_content_utf8';                fex_col: 'Body Main Content Utf8';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_main_imap_id';                     fex_col: 'Body Main Imap Id';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_mime_type';                    fex_col: 'Body Alt Mime Type';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_encoding';                     fex_col: 'Body Alt Encoding';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_charset';                      fex_col: 'Body Alt Charset';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_size';                         fex_col: 'Body Alt Size';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_fetched_size';                 fex_col: 'Body Alt Fetched Size';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_fetch_state';                  fex_col: 'Body Alt Fetch State';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_content_utf8';                 fex_col: 'Body Alt Content Utf8';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_body_alt_imap_id';                      fex_col: 'Body Alt Imap Id';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_new_content';                           fex_col: 'New Content';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_new_content_styling';                   fex_col: 'New Content Styling';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ref_msg_id';                            fex_col: 'Ref Msg Id';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_send';                              fex_col: 'Out Send';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_quote';                             fex_col: 'Out Quote';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_report';                            fex_col: 'Out Report';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_error';                             fex_col: 'Out Error';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_alias';                             fex_col: 'Out Alias';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_ref_msg_id';                        fex_col: 'Out Ref Msg Id';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_out_ref_msg_op';                        fex_col: 'Out Ref Msg Op';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_move_to_folder';                     fex_col: 'Op Move To Folder';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_move_to_folder_done';                fex_col: 'Op Move To Folder Done';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_move_to_folder_time';                fex_col: 'Op Move To Folder Time';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_op_sync_is_needed';                     fex_col: 'Op Sync Is Needed';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_op_sync_error_count';                   fex_col: 'Op Sync Error Count';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_original_folder_id';                    fex_col: 'Original Folder Id';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_when_smart';                            fex_col: 'When Smart';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_liveview_time';                         fex_col: 'Liveview Time';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_search_token';                          fex_col: 'Search Token';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sort_subject';                          fex_col: 'Sort Subject';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sort_sender';                           fex_col: 'Sort Sender';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_folder_id';                             fex_col: 'Folder Id';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'AQUAMAIL_ANDROID' then Result := Array_Items_Android else
  if Name = 'ANDROID' then Result := Array_Items_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
