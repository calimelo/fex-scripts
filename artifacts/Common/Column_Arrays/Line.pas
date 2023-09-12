{!NAME:      Line.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Line;

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
  (sql_col: 'DNT_last_created_time';           fex_col: 'Last Created Time';            read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_last_message_display_time';   fex_col: 'Last Message Display Time';    read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  //(sql_col: 'DNT_chat_name';                 fex_col: 'Chat Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_last_message';                fex_col: 'Last Message';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_name';                        fex_col: 'Username';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_server_name';                 fex_col: 'Server Name';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_chat_id';                     fex_col: 'Chat ID';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_owner_mid';                   fex_col: 'Owner Mid';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_last_from_mid';               fex_col: 'Last From Mid';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_message_count';               fex_col: 'Message Count';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_read_message_count';          fex_col: 'Read Message Count';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Type';                      fex_col: 'Type';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_notification';           fex_col: 'Is Notification';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_skin_key';                  fex_col: 'Skin Key';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_input_text';                fex_col: 'Input Text';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_hide_member';               fex_col: 'Hide Member';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_p_timer';                   fex_col: 'P Timer';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_mid_p';                     fex_col: 'Mid P';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_is_archived';               fex_col: 'Is Archived';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_read_up';                   fex_col: 'Read Up';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Android_Chat_History: TSQL_Table_array = (
  (sql_col: 'DNT_CREATED_TIME';                fex_col: 'Created Time';                 read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_NAME';                        fex_col: 'Username';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTENT';                     fex_col: 'Message';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TYPE';                        fex_col: 'Type';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LOCATION_ADDRESS';            fex_col: 'Location Address';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LOCATION_PHONE';              fex_col: 'Location Phone';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LOCATION_LATITUDE';           fex_col: 'Latitude';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LOCATION_LONGITUDE';          fex_col: 'Longitude';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ATTACHEMENT_LOCAL_URI';       fex_col: 'Attachment Location';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CHAT_ID';                     fex_col: 'Chat ID';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SERVER_ID';                   fex_col: 'Server ID';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CHAT1: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';                  fex_col: 'Timestamp';                    read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZTEXT';                       fex_col: 'Text';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZNAME';                       fex_col: 'Username';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSENDER';                     fex_col: 'Sender';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLATITUDE';                   fex_col: 'Latitude';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLONGITUDE';                  fex_col: 'Longitudet';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCHAT';                       fex_col: 'Chat';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZREADCOUNT';                  fex_col: 'Read Count';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMESSAGETYPE';              fex_col: 'Message Type';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBNAIL';                fex_col: 'Thumbnail';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCONTENTMETADATA';          fex_col: 'Content Metadata';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZID';                       fex_col: 'ZID';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSENDSTATUS';               fex_col: 'Send Status';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_PK';                      fex_col: 'PK';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                     fex_col: 'ENT';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                     fex_col: 'OPT';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_ZNAME';                       fex_col: 'Line Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZMID';                        fex_col: 'Line ID';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'LINE_CONTACTS_ANDROID' then Result := Array_Items_ANDROID_CONTACTS else
  if Name = 'LINE_CHAT_ANDROID'     then Result := Array_Items_ANDROID_CHAT_HISTORY else
  if Name = 'LINE_CHAT_IOS'         then Result := Array_Items_IOS_CHAT1 else
  if Name = 'LINE_TALK_IOS'         then Result := Array_Items_IOS_CHAT1 else
  if Name = 'LINE_CONTACTS_IOS'     then Result := Array_Items_IOS_CONTACTS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.