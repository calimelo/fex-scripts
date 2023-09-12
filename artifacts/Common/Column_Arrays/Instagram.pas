{!NAME:      Instagram.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Instagram;

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
  //(sql_col: 'DNT_ID';                  fex_col: 'ID Col';                     read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_Timestamp';             fex_col: 'Timestamp';                  read_as: ftLargeInt;    convert_as: 'UNIX_MicroS'; col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Text';                  fex_col: 'Text';                       read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_Message';               fex_col: 'User Name';                  read_as: ftString;      convert_as: 'INSTAGRAM';   col_type: ftString;     show: True),
  (sql_col: 'DNT_Message';               fex_col: 'Full Name';                  read_as: ftString;      convert_as: 'INSTAGRAM';   col_type: ftString;     show: True),
  (sql_col: 'DNT_Message';               fex_col: 'Profile Picture URL';        read_as: ftString;      convert_as: 'INSTAGRAM';   col_type: ftString;     show: True),
  //(sql_col: 'DNT_user_id';             fex_col: 'User ID';                    read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  //(sql_col: 'DNT_server_item_id';      fex_col: 'Server Item ID';             read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  //(sql_col: 'DNT_client_item_id';      fex_col: 'Client Item ID';             read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_thread_id';             fex_col: 'Thread ID';                  read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_recipient_ids';         fex_col: 'Recipient IDs';              read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_message_type';          fex_col: 'Message Type';               read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                   read_as: ftString;      convert_as: '';            col_type: ftString;     show: True),
  );

  Array_Items_Users_Android: TSQL_Table_array = (
  (sql_col: 'DNT_User_ID';               fex_col: 'User ID';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_User_Name';             fex_col: 'User Name';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Full_Name';             fex_col: 'Full Name';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Profile_Picture_URL';   fex_col: 'Profile Picture';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );	

  Array_Items_Contacts_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_Instagram Name';        fex_col: 'Instagram Parsed User/Name'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Instagram ID';          fex_col: 'Instagram ID';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Instagram URL';         fex_col: 'Instagram URL';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Direct_Message_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ARCHIVE';               fex_col: 'Archive';                    read_as: ftString;      convert_as: 'IDIRECT';  col_type: ftString;     show: False),
  (sql_col: 'DNT_TIMESTAMP';             fex_col: 'Timestamp';                  read_as: ftString;      convert_as: '';         col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_MESSAGE';               fex_col: 'Message';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SENDER_ID';             fex_col: 'Sender ID';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_THREAD_ID';             fex_col: 'Thread ID';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_TYPE';                  fex_col: 'Type';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_GROUP_MEMBERS_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_THREAD_ID';             fex_col: 'Group Name';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'INSTAGRAM_CHAT_ANDROID'            then Result := Array_Items_Chat_Android else
  if Name = 'INSTAGRAM_USERS_ANDROID'           then Result := Array_Items_Users_Android else
  if Name = 'INSTAGRAM_CONTACTS_IOS'            then Result := Array_Items_Contacts_IOS else
  if Name = 'INSTAGRAM_DIRECT_MESSAGE_CHAT_IOS' then Result := Array_Items_Direct_Message_IOS else
  if Name = 'INSTAGRAM_GROUP_MEMBERS_IOS'       then Result := Array_Items_GROUP_MEMBERS_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.