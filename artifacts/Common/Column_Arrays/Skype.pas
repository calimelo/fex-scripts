{!NAME:      Skype.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Skype;

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

  Array_Items_Android_Contacts: TSQL_Table_array = (
  (sql_col: 'DNT_NSP_DATA';                                fex_col: 'Contacts';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MRI';                                     fex_col: 'Skype Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_FETCHEDDATE';                             fex_col: 'Profile Fetched';                            read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_DISPLAYNAMEOVERRIDE';                     fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_THUMBURL';                                fex_col: 'Thumb URL';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_BIRTHDAY';                                fex_col: 'Birthday';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

//-----

  Array_Items_ACCOUNTS: TSQL_Table_array = (
  (sql_col: 'DNT_profile_timestamp';                       fex_col: 'Profile Timestamp';                          read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_last_online_timestamp';                   fex_col: 'Last Online';                                read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_skypename';                               fex_col: 'Skype Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_fullname';                                fex_col: 'Full Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_displayname';                             fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_emails';                                  fex_col: 'Emails';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_language';                                fex_col: 'Language';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_country';                                 fex_col: 'Country';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_province';                                fex_col: 'Province';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_city';                                    fex_col: 'City';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_ACTIVITY: TSQL_Table_array = (
  (sql_col: 'DNT_ARRIVALTIME';                             fex_col: 'Arrival Time';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGETYPE';                             fex_col: 'Message Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTENT';                                 fex_col: 'Content';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_FROM';                                    fex_col: 'Sender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_DURATION';                                fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONVERSATIONLINK';                        fex_col: 'Conversation Link';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONVERSATIONID';                          fex_col: 'Conversation ID';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_NSP_DATA';                                fex_col: 'NSP Data';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_CALLS: TSQL_Table_array = (
  //(sql_col: 'DNT_id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_start_timestamp';                         fex_col: 'Start Timestamp';                            read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_guid';                                    fex_col: 'GUID';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_identity';                                fex_col: 'Identity';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_dispname';                                fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_CHATSYNC: TSQL_Table_array = (
  (sql_col: 'DNT_DATE';                                    fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_CONVERSATION_PARTNERS';                   fex_col: 'Users';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGE';                                 fex_col: 'Mesage';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_last_online_timestamp';                   fex_col: 'Last Online';                                read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_skypename';                               fex_col: 'Skype Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_fullname';                                fex_col: 'Full Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_displayname';                             fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_emails';                                  fex_col: 'Emails';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_country';                                 fex_col: 'Country';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_province';                                fex_col: 'Province';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_city';                                    fex_col: 'City';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_language';                                fex_col: 'Language';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_CONTACTS_V12: TSQL_Table_array = (
  (sql_col: 'DNT_Mri';                                     fex_col: 'Mri';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_contact_type';                            fex_col: 'Contact Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_display_name';                            fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_full_name';                               fex_col: 'Full Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_avatar_url';                              fex_col: 'Avatar Url';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Mood';                                    fex_col: 'Mood';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_buddy';                                fex_col: 'Is Buddy';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Authorized';                              fex_col: 'Authorized';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Blocked';                                 fex_col: 'Blocked';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_assigned_phonelabel_1';                   fex_col: 'Assigned Phonelabel 1';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_assigned_phonenumber_1';                  fex_col: 'Assigned Phonenumber 1';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_assigned_phonelabel_2';                   fex_col: 'Assigned Phonelabel 2';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_assigned_phonenumber_2';                  fex_col: 'Assigned Phonenumber 2';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_assigned_phonelabel_3';                   fex_col: 'Assigned Phonelabel 3';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_assigned_phonenumber_3';                  fex_col: 'Assigned Phonenumber 3';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_avatar_file_path';                        fex_col: 'Avatar File Path';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_avatar_downloaded_from';                  fex_col: 'Avatar Downloaded From';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_suggested';                            fex_col: 'Is Suggested';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phone_number_mobile';                     fex_col: 'Phone Number Mobile';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phone_number_home';                       fex_col: 'Phone Number Home';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phone_number_office';                     fex_col: 'Phone Number Office';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Birthday';                                fex_col: 'Birthday';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Country';                                 fex_col: 'Country';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Province';                                fex_col: 'Province';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_City';                                    fex_col: 'City';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Homepage';                                fex_col: 'Homepage';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_about_me';                                fex_col: 'About Me';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_favorite';                             fex_col: 'Is Favorite';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_update_version';                          fex_col: 'Update Version';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_unistore_version';                        fex_col: 'Unistore Version';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_recommendation_rank';                     fex_col: 'Recommendation Rank';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_recommendation_json';                     fex_col: 'Recommendation Json';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   );

  Array_Items_CONTACTS_V12_LIVE: TSQL_Table_array = (
  (sql_col: 'DNT_FETCHEDDATE';                             fex_col: 'Profile Fetched';    read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_NSP_DATA';                                fex_col: 'NSP Data';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MRI';                                     fex_col: 'Skype Name';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_DISPLAYNAMEOVERRIDE';                     fex_col: 'Display Name';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_THUMBURL';                                fex_col: 'Thumb URL';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_BIRTHDAY';                                fex_col: 'Birthday';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_GENDER';                                  fex_col: 'Gender';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   );

  Array_Items_MESSAGES: TSQL_Table_array = (
  //(sql_col: 'DNT_id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_timestamp';                               fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_author';                                  fex_col: 'Author';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_chatname';                                fex_col: 'Chatname';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_from_dispname';                           fex_col: 'From Display Name';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_body_xml';                                fex_col: 'Body XML';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_permanent';                          fex_col: 'Is Permanent';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_convo_id';                              fex_col: 'Convo ID';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_author_was_live';                       fex_col: 'Author Was Live';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_guid';                                  fex_col: 'Guid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_dialog_partner';                        fex_col: 'Dialog Partner';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_type';                                  fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_sending_status';                        fex_col: 'Sending Status';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_consumption_status';                    fex_col: 'Consumption Status';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_edited_by';                             fex_col: 'Edited By';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_edited_timestamp';                      fex_col: 'Edited Timestamp';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_param_key';                             fex_col: 'Param Key';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_param_value';                           fex_col: 'Param Value';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_identities';                            fex_col: 'Identities';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_reason';                                fex_col: 'Reason';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_leavereason';                           fex_col: 'Leavereason';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_participant_count';                     fex_col: 'Participant Count';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_error_code';                            fex_col: 'Error Code';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_chatmsg_type';                          fex_col: 'Chatmsg Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_chatmsg_status';                        fex_col: 'Chatmsg Status';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_body_is_rawxml';                        fex_col: 'Body Is Rawxml';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_oldoptions';                            fex_col: 'Oldoptions';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_newoptions';                            fex_col: 'Newoptions';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_newrole';                               fex_col: 'Newrole';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_pk_id';                                 fex_col: 'Pk ID';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_crc';                                   fex_col: 'CRC';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_remote_id';                             fex_col: 'Remote ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_call_guid';                             fex_col: 'Call Guid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_extprop_contact_review_date';           fex_col: 'Extprop Contact Review Date';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_extprop_contact_received_stamp';        fex_col: 'Extprop Contact Received Stamp';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_extprop_contact_reviewed';              fex_col: 'Extprop Contact_Reviewed';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_MESSAGES_V12: TSQL_Table_array = (
  //(sql_col: 'DNT_Convdbid';                              fex_col: 'Convdbid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Dbid';                                  fex_col: 'Dbid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Id';                                      fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Originalarrivaltime';                     fex_col: 'Originalarrivaltime';                        read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Editedtime';                              fex_col: 'Editedtime';                                 read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Author';                                  fex_col: 'Author';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Clientmessageid';                         fex_col: 'Clientmessageid';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Messagetype';                             fex_col: 'Messagetype';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Content';                                 fex_col: 'Content';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Skypeguid';                               fex_col: 'Skypeguid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Version';                                 fex_col: 'Version';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Properties';                              fex_col: 'Properties';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Json';                                    fex_col: 'Json';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Sendingstatus';                           fex_col: 'Sendingstatus';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Smsmessagedbid';                          fex_col: 'Smsmessagedbid';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_preview';                              fex_col: 'Is Preview';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_MESSAGES_V12_LIVE: TSQL_Table_array = (
  (sql_col: 'DNT_NSP_DATA';                    fex_col: 'NSP Data';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ORIGINALARRIVALTIME';         fex_col: 'Arrival Time';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTENT';                     fex_col: 'Message';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SKYPEID';                     fex_col: 'Skype ID';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGETYPE';                 fex_col: 'Message Type';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_VERSION';                     fex_col: 'Version';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_COMPSETTIMIE';                fex_col: 'Compose Time';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CLIENTMESSAGEID';             fex_col: 'Client Message ID';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONVERSATIONLINK';            fex_col: 'Conversation Link';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TYPE';                        fex_col: 'Type';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONVERSATIONID';              fex_col: 'Conversation ID';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_FROM';                        fex_col: 'From';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CUID';                        fex_col: 'CUID';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CREATEDTIME';                 fex_col: 'Skype Created Time';   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CREATOR';                     fex_col: 'Createor';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_COMPOSETIME';                 fex_col: 'Compose Time';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGETYPE';                 fex_col: 'Message Type';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ISEPHEMERAL';                 fex_col: 'Is Ephemeral';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ISMYMESSAGE';                 fex_col: 'Is My Message';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_TRANSFERS: TSQL_Table_array = (
  (sql_col: 'DNT_id';                          fex_col: 'ID Col';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_starttime';                   fex_col: 'Skype Start';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_starttime';                   fex_col: 'Finish Time';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_partner_handle';              fex_col: 'Partner Handle';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_partner_dispname';            fex_col: 'Title';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_filepath';                    fex_col: 'File Path';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_filename';                    fex_col: 'File Name';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_filesize';                    fex_col: 'File Size';            read_as: ftinteger;     convert_as: '';         col_type: ftinteger;    show: True),
  (sql_col: 'DNT_bytestransferred';            fex_col: 'Bytes Transferred';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'SKYPE_CONTACTS_ANDROID'  then Result := Array_Items_Android_Contacts else
  if Name = 'SKYPE_ACCOUNTS'          then Result := Array_Items_ACCOUNTS else
  if Name = 'SKYPE_ACTIVITY'          then Result := Array_Items_ACTIVITY else
  if Name = 'SKYPE_CALLS'             then Result := Array_Items_CALLS else
  if Name = 'SKYPE_CHATSYNC'          then Result := Array_Items_CHATSYNC else
  if Name = 'SKYPE_CONTACTS'          then Result := Array_Items_CONTACTS else
  if Name = 'SKYPE_CONTACTS_V12'      then Result := Array_Items_CONTACTS_V12 else
  if Name = 'SKYPE_CONTACTS_V12_LIVE' then Result := Array_Items_CONTACTS_V12_LIVE else
  if Name = 'SKYPE_MESSAGES'          then Result := Array_Items_MESSAGES else
  if Name = 'SKYPE_MESSAGES_V12'      then Result := Array_Items_MESSAGES_V12 else
  if Name = 'SKYPE_MESSAGES_V12_LIVE' then Result := Array_Items_MESSAGES_V12_LIVE else
  if Name = 'SKYPE_TRANSFERS'         then Result := Array_Items_TRANSFERS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.