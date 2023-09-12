{!NAME:      Slack.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Slack;

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

  Array_Items_SLACK_ACCOUNTS_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_LAST_ACCESSED';     fex_col: 'Last Accessed';      read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_USER_ID';           fex_col: 'User ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TEAM_ID';           fex_col: 'Team ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_EMAIL';             fex_col: 'Email';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TEAM_DOMAIN';       fex_col: 'Team Domain';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TOKEN_ENCRYPTED';   fex_col: 'Token';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_SLACK_ACCOUNTS_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZREALNAME';         fex_col: 'User';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZAUTHUSERID';       fex_col: 'User ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZEMAIL';            fex_col: 'Email';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDOMAIN';           fex_col: 'Domain';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZICON88URL';        fex_col: 'Icon URL';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZNAME';             fex_col: 'Group Name';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTSID';             fex_col: 'SID';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_SLACK_DEPRECATED_MESSAGES_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';        fex_col: 'Timestamp';          read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZREALNAME';         fex_col: 'Sender';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTEXT';             fex_col: 'Message';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZNAME';             fex_col: 'Channel Name';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTSID';             fex_col: 'Workspace ID';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSTATUS';           fex_col: 'Status';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_SLACK_DIRECT_MESSAGES_ANDROID : TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';         fex_col: 'Timestamp';          read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_MESSAGE';           fex_col: 'Message';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MESSAGE_JSON';      fex_col: 'Message JSON';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_USER_ID';           fex_col: 'User ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CHANNEL_ID';        fex_col: 'Channel ID';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CLIENT_MSG_ID';     fex_col: 'Client ID';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_LOCAL_ID';          fex_col: 'Local ID';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CALLS_ROOM_ID';     fex_col: 'Room ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_MSG_SEND_STATE';    fex_col: 'State';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SUBTYPE';           fex_col: 'Subtype';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_SLACK_DIRECT_MESSAGES_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';        fex_col: 'Timestamp';          read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZTEXT';             fex_col: 'Message';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCONVERSATIONID';   fex_col: 'Conversation ID';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZUSERID';           fex_col: 'User ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTYPESTRING';       fex_col: 'Type';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_SLACK_USERS_IOS: TSQL_Table_array = (
   (sql_col: 'DNT_ZEMAIL';           fex_col: 'Email';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZFIRSTNAME';       fex_col: 'First Name';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZTITLE';           fex_col: 'User Title';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZTSID';            fex_col: 'User ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZNAME';            fex_col: 'User Name';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZREALNAME';        fex_col: 'Real name';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZPHONE';           fex_col: 'Phone';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZTIMEZONE';        fex_col: 'Timezone';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZTIMEZONEOFFSET';  fex_col: 'Timezone Offset';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_ZTIMEZONETITLE';   fex_col: 'Timezone Title';     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_SQLLOCATION';      fex_col: 'Location';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'SLACK_ACCOUNTS_ANDROID'  then Result := Array_Items_SLACK_ACCOUNTS_ANDROID else
  if Name = 'SLACK_ACCOUNTS_IOS'  then Result := Array_Items_SLACK_ACCOUNTS_IOS else
  if Name = 'SLACK_DEPRECATED_MESSAGES_IOS'  then Result := Array_Items_SLACK_DEPRECATED_MESSAGES_IOS else
  if Name = 'SLACK_DIRECT_MESSAGES_ANDROID'  then Result := Array_Items_SLACK_DIRECT_MESSAGES_ANDROID else
  if Name = 'SLACK_DIRECT_MESSAGES_IOS'  then Result := Array_Items_SLACK_DIRECT_MESSAGES_IOS else
  if Name = 'SLACK_USERS_IOS'  then Result := Array_Items_SLACK_USERS_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.