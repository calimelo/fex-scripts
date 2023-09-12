{!NAME:      Messenger.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Messenger;

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
  (sql_col: 'DNT_timestamp_ms';                            fex_col: 'Timestamp Ms';                               read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Text';                                    fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Sender';                                  fex_col: 'Sender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_msg_id';                                  fex_col: 'Msg ID';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_thread_key';                              fex_col: 'Thread Key';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_not_forwardable';                    fex_col: 'Is Not Forwardable';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_timestamp_sent_ms';                     fex_col: 'Timestamp Sent Ms';                          read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Attachments';                             fex_col: 'Attachments';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Shares';                                fex_col: 'Shares';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_sticker_id';                            fex_col: 'Sticker ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_msg_type';                              fex_col: 'Msg Type';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_affected_users';                        fex_col: 'Affected Users';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Coordinates';                           fex_col: 'Coordinates';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_offline_threading_id';                  fex_col: 'Offline Threading ID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Source';                                fex_col: 'Source';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_channel_source';                        fex_col: 'Channel Source';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_channel';                          fex_col: 'Send Channel';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_non_authoritative';                  fex_col: 'Is Non Authoritative';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_pending_send_media_attachment';         fex_col: 'Pending Send Media Attachment';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_sent_share_attachment';                 fex_col: 'Sent Share Attachment';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_client_tags';                           fex_col: 'Client Tags';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_error';                            fex_col: 'Send Error';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_error_message';                    fex_col: 'Send Error Message';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_error_number';                     fex_col: 'Send Error Number';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_error_timestamp_ms';               fex_col: 'Send Error Timestamp Ms';                    read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  //(sql_col: 'DNT_send_error_error_url';                  fex_col: 'Send Error Error Url';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Publicity';                             fex_col: 'Publicity';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_queue_type';                       fex_col: 'Send Queue Type';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_payment_transaction';                   fex_col: 'Payment Transaction';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_payment_request';                       fex_col: 'Payment Request';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_has_unavailable_attachment';            fex_col: 'Has Unavailable Attachment';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_app_attribution';                       fex_col: 'App Attribution';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_content_app_attribution';               fex_col: 'Content App Attribution';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Xma';                                   fex_col: 'Xma';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_type';                       fex_col: 'Admin Text Type';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_theme_color';                fex_col: 'Admin Text Theme Color';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_icon_emoji';          fex_col: 'Admin Text Thread Icon Emoji';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_nickname';                   fex_col: 'Admin Text Nickname';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_target_id';                  fex_col: 'Admin Text Target ID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_message_lifetime';    fex_col: 'Admin Text Thread Message Lifetime';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_message_lifetime';                      fex_col: 'Message Lifetime';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_rtc_event';           fex_col: 'Admin Text Thread Rtc Event';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_rtc_server_info_data'; fex_col: 'Admin Text Thread Rtc Server Info Data';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_rtc_is_video_call';   fex_col: 'Admin Text Thread Rtc Is Video Call';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_ride_provider_name';  fex_col: 'Admin Text Thread Ride Provider Name';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_sponsored';                          fex_col: 'Is Sponsored';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_ad_properties';       fex_col: 'Admin Text Thread Ad Properties';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_game_score_data';            fex_col: 'Admin Text Game Score Data';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_thread_event_reminder_properties'; fex_col: 'Admin Text Thread Event Reminder Properties'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_commerce_message_type';                 fex_col: 'Commerce Message Type';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_joinable_event_type';        fex_col: 'Admin Text Joinable Event Type';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_metadata_at_text_ranges';               fex_col: 'Metadata At Text Ranges';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_platform_metadata';                     fex_col: 'Platform Metadata';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_is_joinable_promo';          fex_col: 'Admin Text Is Joinable Promo';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_admin_text_agent_intent_id';            fex_col: 'Admin Text Agent Intent ID';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_montage_reply_message_id';              fex_col: 'Montage Reply Message ID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_generic_admin_message_extensible_data'; fex_col: 'Generic Admin Message Extensible Data';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_profile_ranges';                        fex_col: 'Profile Ranges';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_error_detail';                     fex_col: 'Send Error Detail';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_send_error_original_exception';         fex_col: 'Send Error Original Exception';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_montage_reply_action';                  fex_col: 'Montage Reply Action';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_extensible_message_data';               fex_col: 'Extensible Message Data';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_SQLLOCATION';                           fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Call_Log_Android: TSQL_Table_array = (
  (sql_col: 'DNT_last_call_time';                          fex_col: 'Last Call Time';                             read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_user_id';                                 fex_col: 'User ID';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_log_id';                                  fex_col: 'Log ID';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Duration';                                fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Answered';                                fex_col: 'Answered';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Direction';                               fex_col: 'Direction';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_call_type';                               fex_col: 'Call Type';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Acknowledged';                            fex_col: 'Acknowledged';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Seen';                                    fex_col: 'Seen';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_thread_id';                               fex_col: 'Thread ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_on_going';                                fex_col: 'On Going';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Messenger_Contacts_Android: TSQL_Table_array = (
  //(sql_col: 'DNT_internal_id';                           fex_col: 'Internal ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_contact_id';                            fex_col: 'Contact ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_added_time_ms';                           fex_col: 'Added Time Ms';                              read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDatetime;   show: True),
  (sql_col: 'DNT_first_name';                              fex_col: 'First Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_last_name';                               fex_col: 'Last Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_display_name';                            fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Fbid';                                    fex_col: 'Fbid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_small_picture_url';                     fex_col: 'Small Picture Url';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_big_picture_url';                         fex_col: 'Big Picture Url';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_huge_picture_url';                      fex_col: 'Huge Picture Url';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_small_picture_size';                    fex_col: 'Small Picture Size';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_big_picture_size';                      fex_col: 'Big Picture Size';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_huge_picture_size';                     fex_col: 'Huge Picture Size';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_communication_rank';                    fex_col: 'Communication Rank';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_mobile_pushable';                    fex_col: 'Is Mobile Pushable';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_messenger_user';                       fex_col: 'Is Messenger User';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_messenger_install_time_ms';             fex_col: 'Messenger Install Time Ms';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_phonebook_section_key';                 fex_col: 'Phonebook Section Key';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_on_viewer_contact_list';             fex_col: 'Is On Viewer Contact List';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_viewer_connection_status';              fex_col: 'Viewer Connection Status';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Type';                                  fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_link_type';                             fex_col: 'Link Type';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_indexed';                            fex_col: 'Is Indexed';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Data';                                  fex_col: 'Data';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_bday_day';                              fex_col: 'Bday Day';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_bday_month';                            fex_col: 'Bday Month';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_partial';                            fex_col: 'Is Partial';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_memorialized';                       fex_col: 'Is Memorialized';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_messenger_invite_priority';             fex_col: 'Messenger Invite Priority';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_broadcast_recipient_holdout';        fex_col: 'Is Broadcast Recipient Holdout';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_add_source';                            fex_col: 'Add Source';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_last_fetch_time_ms';                    fex_col: 'Last Fetch Time Ms';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_aloha_proxy_confirmed';              fex_col: 'Is Aloha Proxy Confirmed';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  // Messenger - Threads Android
  Array_Items_Threads_Android: TSQL_Table_array = (
  (sql_col: 'DNT_USER_KEY';                     fex_col: 'User Key';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_NAME';                         fex_col: 'Full Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_USERNAME';                     fex_col: 'Username';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_PROFILE_PIC_SQUARE';           fex_col: 'Profile Picture URL';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  // Messenger - iOS
  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_timestamp';                    fex_col: 'Timestamp';                    read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_msg_blob';                     fex_col: 'Message';                      read_as: ftString;      convert_as: 'BlobText'; col_type: ftString;     show: True),
  (sql_col: 'DNT_msg_id';                       fex_col: 'Type Col';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_additional_deduplication_key'; fex_col: 'Additional Deduplication Key'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_collapsed_message_key';        fex_col: 'Collapsed Message Key';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_fbid_from_thread_key';         fex_col: 'Fbid From Thread Key';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'MESSENGER_CHAT_ANDROID'     then Result := Array_Items_Android else
  if Name = 'MESSENGER_CALL_LOG_ANDROID' then Result := Array_Items_Call_Log_Android else
  if Name = 'MESSENGER_CONTACTS_ANDROID' then Result := Array_Items_Messenger_Contacts_Android else
  if Name = 'MESSENGER_THREADS_ANDROID'  then Result := Array_Items_Threads_Android else
  if Name = 'MESSENGER_CHAT_IOS'         then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.