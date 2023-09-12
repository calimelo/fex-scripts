{!NAME:      Snapchat.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Snapchat;

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

{1} Array_Items_SNAPCHAT_CHAT_ANDROID_TCSPAHN: TSQL_Table_array = (
  (sql_col: 'DNT_Timestamp';                fex_col: 'Timestamp';               read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Recipients';               fex_col: 'Recipients';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Sender';                   fex_col: 'Sender';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Text';                     fex_col: 'Text';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_conversation_id';          fex_col: 'Conversation ID';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

{2} Array_Items_SNAPCHAT_FRIENDS_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_Addedmetimestamp';         fex_col: 'Addedmetimestamp';        read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Addedthemtimestamp';       fex_col: 'Addedthemtimestamp';      read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Username';                 fex_col: 'Username';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Displayname';              fex_col: 'Displayname';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Phonenumber';              fex_col: 'Phonenumber';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Bestfriendindex';          fex_col: 'Bestfriendindex';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Userid';                   fex_col: 'Userid';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Isfollowing';              fex_col: 'Isfollowing';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Birthday';                 fex_col: 'Birthday';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

{3}  Array_Items_SNAPCHAT_FRIEND_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_Username';                 fex_col: 'Username';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Displayname';              fex_col: 'Displayname';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_userId';                   fex_col: 'User ID';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ServerDisplayName';        fex_col: 'Server Display Name';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

{4} Array_Items_SNAPCHAT_MEMORIES_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_CREATE_TIME';              fex_col: 'Create Time';             read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_TIME_ZONE_ID';             fex_col: 'Timezone';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MEDIA_TYPE';               fex_col: 'Media Type';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_DURATION';                 fex_col: 'Duration';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LATITUDE';                 fex_col: 'Latitude';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LONGITUDE';                fex_col: 'Longitude';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ENCRYPTED_MEDIA_KEY';      fex_col: 'Encrypted Media Key';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

{5} Array_Items_SNAPCHAT_MESSAGE_ANDROID_ARROYO: TSQL_Table_array = (
   (sql_col: 'DNT_creation_timestamp';      fex_col: 'Creation Date';           read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
   (sql_col: 'DNT_read_timestamp';          fex_col: 'Read Timestamp';          read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
   (sql_col: 'DNT_content_type';            fex_col: 'Content Type'; {bef msg}  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_message_content';         fex_col: 'Message';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_sender_id';               fex_col: 'Sender ID';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_client_message_id';       fex_col: 'Message ID';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_client_conversation_id';  fex_col: 'Conversation ID';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_remote_media_count';      fex_col: 'Remote Media Count';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_server_message_id';       fex_col: 'Server Message ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

{6} Array_Items_SNAPCHAT_MESSAGE_ANDROID_MAIN: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';                fex_col: 'Timestamp';               read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_USERNAME';                 fex_col: 'Sender';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_DISPLAYNAME';              fex_col: 'Sender Name';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_KEY';                      fex_col: 'Message ID';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TYPE';                     fex_col: 'Type';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONTENT';                  fex_col: 'Message';                 read_as: ftString;      convert_as: 'SNAPBLOB'; col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

{7} Array_Items_User_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_UserID';                   fex_col: 'SnapChat User ID';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_UserName';                 fex_col: 'SnapChat User Name';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
{1} if Name = 'SNAPCHAT_CHAT_ANDROID_TCSPAHN'   then Result := Array_Items_SNAPCHAT_CHAT_ANDROID_TCSPAHN else
{2} if Name = 'SNAPCHAT_FRIENDS_ANDROID'        then Result := Array_Items_SNAPCHAT_FRIENDS_ANDROID else
{3} if Name = 'SNAPCHAT_FRIEND_ANDROID'         then Result := Array_Items_SNAPCHAT_FRIEND_ANDROID else
{4} if Name = 'SNAPCHAT_MEMORIES_ANDROID'       then Result := Array_Items_SNAPCHAT_MEMORIES_ANDROID else
{5} if Name = 'SNAPCHAT_MESSAGE_ANDROID_ARROYO' then Result := Array_Items_SNAPCHAT_MESSAGE_ANDROID_ARROYO else
{6} if Name = 'SNAPCHAT_MESSAGE_ANDROID_MAIN'   then Result := Array_Items_SNAPCHAT_MESSAGE_ANDROID_MAIN else
{7} if Name = 'SNAPCHAT_USER_IOS'               then Result := Array_Items_User_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.