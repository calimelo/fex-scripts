{!NAME:      Tinder.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Tinder;

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
  //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sent_date';                               fex_col: 'Sent Date';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Text';                                    fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_match_id';                                fex_col: 'Match ID';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_to_id';                                   fex_col: 'To Tinder ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_from_id';                                 fex_col: 'From Tinder ID';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_liked';                                fex_col: 'Is Liked';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Type';                                    fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_delivery_status';                         fex_col: 'Delivery Status';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Chat_IOS: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                                  fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZHASERROR';                             fex_col: 'Haserror';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLIKED';                                fex_col: 'Liked';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZVIEWED';                               fex_col: 'Viewed';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMATCH';                                fex_col: 'Match';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMOMENT';                               fex_col: 'Moment';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMOMENTLIKE';                           fex_col: 'Momentlike';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCLIENTCREATED';                        fex_col: 'Clientcreated';                              read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZCREATED';                                fex_col: 'Created';                                    read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  //(sql_col: 'DNT_ZLASTACTIONDATE';                       fex_col: 'Lastactiondate';                             read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZTEXT';                                   fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFROMUSERID';                             fex_col: 'From User ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZGESTUREID';                            fex_col: 'Gestureid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLOCALIMAGEURL';                        fex_col: 'Localimageurl';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZMESSAGEID';                              fex_col: 'Message ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZPHOTOURL';                             fex_col: 'Photourl';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTYPE';                                 fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Match_Android: TSQL_Table_array = (
  (sql_col: 'DNT_Id';                                      fex_col: 'Tinder ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Name';                                    fex_col: 'Name Col';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Bio';                                     fex_col: 'Bio';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_birth_date';                              fex_col: 'Birth Date';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Photos';                                fex_col: 'Photos';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Badges';                                  fex_col: 'Badges';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Jobs';                                    fex_col: 'Jobs';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Schools';                                 fex_col: 'Schools';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Photos_Android: TSQL_Table_array = (
  //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_user_id';                                 fex_col: 'Tinder ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_image_url';                               fex_col: 'Image Url';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_photo_order';                           fex_col: 'Photo Order';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_User_Android: TSQL_Table_array = (
  (sql_col: 'DNT_first_name';                              fex_col: 'First Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Id';                                      fex_col: 'Tinder ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Bio';                                     fex_col: 'Bio';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_birth_date';                              fex_col: 'Birth Date';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_common_friend_count';                   fex_col: 'Common Friend Count';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_common_like_count';                     fex_col: 'Common Like Count';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_distance_miles';                        fex_col: 'Distance Miles';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Downloaded';                            fex_col: 'Downloaded';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_failed_choice';                         fex_col: 'Failed Choice';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Liked';                                 fex_col: 'Liked';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ping_time';                             fex_col: 'Ping Time';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_last_activity_date';                      fex_col: 'Last Activity Date';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Traveling';                             fex_col: 'Traveling';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_verified';                           fex_col: 'Is Verified';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_superlike';                          fex_col: 'Is Superlike';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Badges';                                fex_col: 'Badges';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Username';                              fex_col: 'Username';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Teaser';                                fex_col: 'Teaser';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_placeholder';                        fex_col: 'Is Placeholder';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_already_matched';                       fex_col: 'Already Matched';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_photo_processing';                      fex_col: 'Photo Processing';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_new_user';                           fex_col: 'Is New User';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_spotify_theme_track';                   fex_col: 'Spotify Theme Track';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_spotify_tracks';                        fex_col: 'Spotify Tracks';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_spotify_connected';                     fex_col: 'Spotify Connected';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_spotify_last_updated';                  fex_col: 'Spotify Last Updated';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_spotify_user_type';                     fex_col: 'Spotify User Type';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_spotify_username';                      fex_col: 'Spotify Username';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_more_gender';                           fex_col: 'More Gender';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_show_gender';                           fex_col: 'Show Gender';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_going_out_data';                        fex_col: 'Going Out Data';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Interests';                             fex_col: 'Interests';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_num_common_connections';                fex_col: 'Num Common Connections';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phone_number';                            fex_col: 'Phone Number';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_User_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZUSERID';                                 fex_col: 'User ID';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFIRSTNAME';                              fex_col: 'First Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZGENDER';                                 fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDISTANCEMILES';                          fex_col: 'Distance Miles';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZBIO';                                    fex_col: 'Bio';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_PK';                                  fex_col: ' Pk';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: ' Ent';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: ' Opt';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZALREADYMATCHED';                       fex_col: 'Alreadymatched';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOMMONCONNECTIONCOUNT';                fex_col: 'Commonconnectioncount';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOMMONFRIENDCOUNT';                    fex_col: 'Commonfriendcount';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOMMONLIKECOUNT';                      fex_col: 'Commonlikecount';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZDISPLAYSCHOOLYEAR';                    fex_col: 'Displayschoolyear';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZFAILEDCHOICE';                         fex_col: 'Failedchoice';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZGROUPONLY';                            fex_col: 'Grouponly';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZHIDEAGE';                              fex_col: 'Hideage';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZHIDEDISTANCE';                         fex_col: 'Hidedistance';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINSTAGRAMCOMPLETEDINITIALFETCH';       fex_col: 'Instagramcompletedinitialfetch';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINSTAGRAMMEDIACOUNT';                  fex_col: 'Instagrammediacount';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISBOOSTUSER';                          fex_col: 'Isboostuser';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISBRAND';                              fex_col: 'Isbrand';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISCURRENTUSER';                        fex_col: 'Iscurrentuser';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISFASTMATCHUSER';                      fex_col: 'Isfastmatchuser';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISPLACEHOLDER';                        fex_col: 'Isplaceholder';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISSUPERLIKEUSER';                      fex_col: 'Issuperlikeuser';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZISTRAVELING';                          fex_col: 'Istraveling';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLIKED';                                fex_col: 'Liked';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSEENONSTACK';                          fex_col: 'Seenonstack';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSELECTMEMBER';                         fex_col: 'Selectmember';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSEQUENCENUMBER';                       fex_col: 'Sequencenumber';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSHOULDHIDEDISTANCEAWAY';               fex_col: 'Shouldhidedistanceaway';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSHOULDHIDELASTACTIVE';                 fex_col: 'Shouldhidelastactive';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSHOULDSHOWGENDER';                     fex_col: 'Shouldshowgender';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSPOTIFYCONNECTED';                     fex_col: 'Spotifyconnected';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSPOTIFYLISTENEDTRACK';                 fex_col: 'Spotifylistenedtrack';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSTALE';                                fex_col: 'Stale';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSUPERLIKED';                           fex_col: 'Superliked';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZVERIFIED';                             fex_col: 'Verified';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZGOINGOUTSTATUS';                       fex_col: 'Goingoutstatus';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMATCH';                                fex_col: 'Match';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHEMETRACK';                           fex_col: 'Themetrack';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZBIRTHDATE';                            fex_col: 'Birthdate';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZDOWNLOADED';                           fex_col: 'Downloaded';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINSTAGRAMLASTFETCHTIME';               fex_col: 'Instagramlastfetchtime';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMARKEDFORREWIND';                      fex_col: 'Markedforrewind';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZPING';                                 fex_col: 'Ping';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSPOTIFYLASTUPDATED';                   fex_col: 'Spotifylastupdated';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTRAVELDISTANCEMILES';                  fex_col: 'Traveldistancemiles';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCONTENTHASH';                          fex_col: 'Contenthash';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCUSTOMGENDER';                         fex_col: 'Customgender';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINSTAGRAMNAME';                        fex_col: 'Instagramname';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINSTAGRAMPROFILEPICTURE';              fex_col: 'Instagramprofilepicture';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLASTVIEWEDPHOTOID';                    fex_col: 'Lastviewedphotoid';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZPUBLICUSERNAME';                       fex_col: 'Publicusername';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZREFERRALSTRING';                       fex_col: 'Referralstring';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSNUMBER';                              fex_col: 'Snumber';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSPOTIFYUSERTYPE';                      fex_col: 'Spotifyusertype';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSPOTIFYUSERNAME';                      fex_col: 'Spotifyusername';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTRAVELLOCATIONNAME';                   fex_col: 'Travellocationname';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZUSERLOCATIONNAME';                     fex_col: 'Userlocationname';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZUSERLOCATIONPROXIMITY';                fex_col: 'Userlocationproximity';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZBADGES';                               fex_col: 'Badges';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOMMONCONNECTIONS';                    fex_col: 'Commonconnections';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINSTAGRAMPHOTOS';                      fex_col: 'Instagramphotos';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINTERESTSCOMMONARRAY';                 fex_col: 'Interestscommonarray';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZINTERESTSUNCOMMONARRAY';               fex_col: 'Interestsuncommonarray';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZJOBS';                                 fex_col: 'Jobs';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSCHOOLS';                              fex_col: 'Schools';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTEASER';                               fex_col: 'Teaser';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'TINDER_CHAT_ANDROID'   then Result := Array_Items_Chat_Android else
  if Name = 'TINDER_CHAT_IOS'       then Result := Array_Items_Chat_IOS else
  if Name = 'TINDER_MATCH_ANDROID'  then Result := Array_Items_Match_Android else
  if Name = 'TINDER_PHOTO_ANDROID'  then Result := Array_Items_Photos_Android else
  if Name = 'TINDER_USER_ANDROID'   then Result := Array_Items_User_Android else
  if Name = 'TINDER_USER_IOS'       then Result := Array_Items_User_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.