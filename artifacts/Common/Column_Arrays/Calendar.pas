{!NAME:      Calendar.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Calendar;

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
  //(sql_col: 'DNT__id';                                   fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT__sync_id';                              fex_col: 'Sync ID';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Dirty';                                   fex_col: 'Dirty';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Mutators';                                fex_col: 'Mutators';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Lastsynced';                              fex_col: 'Lastsynced';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_calendar_id';                             fex_col: 'Calendar ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Title';                                   fex_col: 'Title';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Eventlocation';                           fex_col: 'Eventlocation';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Description';                             fex_col: 'Description';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Eventcolor';                              fex_col: 'Eventcolor';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_eventColor_index';                        fex_col: 'Eventcolor Index';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Eventstatus';                             fex_col: 'Eventstatus';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Selfattendeestatus';                      fex_col: 'Selfattendeestatus';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Dtstart';                                 fex_col: 'Dtstart';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Dtend';                                   fex_col: 'Dtend';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Eventtimezone';                           fex_col: 'Eventtimezone';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Duration';                                fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Allday';                                  fex_col: 'Allday';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Accesslevel';                             fex_col: 'Accesslevel';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Availability';                            fex_col: 'Availability';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Hasalarm';                                fex_col: 'Hasalarm';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Hasextendedproperties';                   fex_col: 'Hasextendedproperties';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Rrule';                                   fex_col: 'Rrule';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Rdate';                                   fex_col: 'Rdate';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Exrule';                                  fex_col: 'Exrule';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Exdate';                                  fex_col: 'Exdate';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_original_id';                             fex_col: 'Original ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_original_sync_id';                        fex_col: 'Original Sync ID';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Originalinstancetime';                    fex_col: 'Originalinstancetime';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Originalallday';                          fex_col: 'Originalallday';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Lastdate';                                fex_col: 'Lastdate';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Hasattendeedata';                         fex_col: 'Hasattendeedata';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Guestscanmodify';                         fex_col: 'Guestscanmodify';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Guestscaninviteothers';                   fex_col: 'Guestscaninviteothers';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Guestscanseeguests';                      fex_col: 'Guestscanseeguests';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Organizer';                               fex_col: 'Organizer';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Isorganizer';                             fex_col: 'Isorganizer';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Deleted';                                 fex_col: 'Deleted Col';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Eventendtimezone';                        fex_col: 'Eventendtimezone';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Customapppackage';                        fex_col: 'Customapppackage';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Customappuri';                            fex_col: 'Customappuri';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Uid2445';                                 fex_col: 'Uid2445';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data1';                              fex_col: 'Sync Data1';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data2';                              fex_col: 'Sync Data2';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data3';                              fex_col: 'Sync Data3';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data4';                              fex_col: 'Sync Data4';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data5';                              fex_col: 'Sync Data5';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data6';                              fex_col: 'Sync Data6';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data7';                              fex_col: 'Sync Data7';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data8';                              fex_col: 'Sync Data8';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data9';                              fex_col: 'Sync Data9';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sync_data10';                             fex_col: 'Sync Data10';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Latitude';                                fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Longitude';                               fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_contact_data_id';                         fex_col: 'Contact Data ID';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_contact_id';                              fex_col: 'Contact ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Contacteventtype';                        fex_col: 'Contacteventtype';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_contact_account_type';                    fex_col: 'Contact Account Type';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Availabilitystatus';                      fex_col: 'Availabilitystatus';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_schedule_id';                    fex_col: 'Facebook Schedule ID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_service_provider';               fex_col: 'Facebook Service Provider';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_event_type';                     fex_col: 'Facebook Event Type';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_owner';                          fex_col: 'Facebook Owner';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_hostname';                       fex_col: 'Facebook Hostname';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_post_time';                      fex_col: 'Facebook Post Time';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_photo_url';                      fex_col: 'Facebook Photo Url';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_facebook_mem_count';                      fex_col: 'Facebook Mem Count';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phone_number';                            fex_col: 'Phone Number';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sticker_type';                            fex_col: 'Sticker Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sticker_ename';                           fex_col: 'Sticker Ename';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS3: TSQL_Table_array = (
  //(sql_col: 'DNT_Rowid';                    fex_col: 'Rowid';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_start_date';                 fex_col: 'Start Date';                   read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_end_date';                   fex_col: 'End Date';                     read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Summary';                    fex_col: 'Summary';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Location';                   fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Description';                fex_col: 'Description';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_start_tz';                 fex_col: 'Start Tz';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_all_day';                    fex_col: 'All Day';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_calendar_id';                fex_col: 'Calendar Id';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_orig_event_id';              fex_col: 'Orig Event Id';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_orig_start_date';            fex_col: 'Orig Start Date';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_organizer_id';             fex_col: 'Organizer Id';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_organizer_is_self';        fex_col: 'Organizer Is Self';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_organizer_external_id';    fex_col: 'Organizer External Id';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_self_attendee_id';         fex_col: 'Self Attendee Id';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Status';                     fex_col: 'Status';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Availability';               fex_col: 'Availability';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_privacy_level';              fex_col: 'Privacy Level';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Url';                        fex_col: 'URL';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_last_modified';              fex_col: 'Calendar Last Modified';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_sequence_num';             fex_col: 'Sequence Num';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_birthday_id';              fex_col: 'Birthday Id';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_modified_properties';      fex_col: 'Modified Properties';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_external_tracking_status'; fex_col: 'External Tracking Status';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_external_id';              fex_col: 'External Id';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_external_mod_tag';         fex_col: 'External Mod Tag';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_unique_identifier';        fex_col: 'Unique Identifier';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_external_schedule_id';     fex_col: 'External Schedule Id';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_external_rep';             fex_col: 'External Rep';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_response_comment';           fex_col: 'Response Comment';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Hidden';                   fex_col: 'Hidden';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS4: TSQL_Table_array = (
  //(sql_col: 'DNT_Rowid';                                 fex_col: 'Rowid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_start_date';                              fex_col: 'Start Date';                                 read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_end_date';                                fex_col: 'End Date';                                   read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT_start_tz';                              fex_col: 'Start Tz';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_end_tz';                                  fex_col: 'End Tz';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Summary';                                 fex_col: 'Summary';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_location_id';                             fex_col: 'Location ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Description';                             fex_col: 'Description';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_all_day';                                 fex_col: 'All Day';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_calendar_id';                             fex_col: 'Calendar ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_orig_item_id';                            fex_col: 'Orig Item ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_orig_date';                               fex_col: 'Orig Date';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_organizer_id';                            fex_col: 'Organizer ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_self_attendee_id';                        fex_col: 'Self Attendee ID';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Status';                                  fex_col: 'Status';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_invitation_status';                       fex_col: 'Invitation Status';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Availability';                            fex_col: 'Availability';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_privacy_level';                           fex_col: 'Privacy Level';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Url';                                     fex_col: 'URL';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_last_modified';                           fex_col: 'Calendar Last Modified';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_sequence_num';                            fex_col: 'Sequence Num';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_birthday_id';                             fex_col: 'Birthday ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_modified_properties';                     fex_col: 'Modified Properties';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_external_tracking_status';                fex_col: 'External Tracking Status';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_external_id';                             fex_col: 'External ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_external_mod_tag';                        fex_col: 'External Mod Tag';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_unique_identifier';                       fex_col: 'Unique Identifier';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_external_schedule_id';                    fex_col: 'External Schedule ID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_external_rep';                            fex_col: 'External Rep';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_response_comment';                        fex_col: 'Response Comment';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_last_synced_response_comment';            fex_col: 'Last Synced Response Comment';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Hidden';                                  fex_col: 'Hidden';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_has_recurrences';                         fex_col: 'Has Recurrences';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_has_attendees';                           fex_col: 'Has Attendees';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Uuid';                                    fex_col: 'Uuid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_entity_type';                             fex_col: 'Entity Type';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Priority';                                fex_col: 'Priority';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_due_date';                                fex_col: 'Due Date';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_due_tz';                                  fex_col: 'Due Tz';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_due_all_day';                             fex_col: 'Due All Day';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_completion_date';                         fex_col: 'Completion Date';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_creation_date';                           fex_col: 'Creation Date';                              read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: False),          
  (sql_col: 'DNT_Conference';                              fex_col: 'Conference';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_display_order';                           fex_col: 'Display Order';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_created_by_id';                           fex_col: 'Created By ID';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_modified_by_id';                          fex_col: 'Modified By ID';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_shared_item_created_date';                fex_col: 'Shared Item Created Date';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_shared_item_created_tz';                  fex_col: 'Shared Item Created Tz';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_shared_item_modified_date';               fex_col: 'Shared Item Modified Date';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_shared_item_modified_tz';                 fex_col: 'Shared Item Modified Tz';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_invitation_changed_properties';           fex_col: 'Invitation Changed Properties';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_default_alarm_removed';                   fex_col: 'Default Alarm Removed';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_phantom_master';                          fex_col: 'Phantom Master';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_participation_status_modified_date';      fex_col: 'Participation Status Modified Date';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_calendar_scale';                          fex_col: 'Calendar Scale';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_travel_time';                             fex_col: 'Travel Time';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_travel_advisory_behavior';                fex_col: 'Travel Advisory Behavior';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_start_location_id';                       fex_col: 'Start Location ID';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_suggestion_id';                           fex_col: 'Suggestion ID';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  );

begin
  if Name = 'ANDROID'   then Result := Array_Items_Android else
  if Name = 'IOS3'      then Result := Array_Items_IOS3 else
  if Name = 'IOS4'      then Result := Array_Items_IOS4 else
  begin
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
  end;
end;

end.
