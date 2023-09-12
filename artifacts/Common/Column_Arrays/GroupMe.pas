{!NAME:      GroupMe.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit GroupMe;

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

   Array_Items_GROUPME_CHAT_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_created_at';         fex_col: 'Created';           read_as: ftLargeInt; convert_as: 'UNIX';    col_type: ftDateTime; show: True),
   (sql_col: 'DNT_message_text';       fex_col: 'Message';           read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_conversation_id';    fex_col: 'Conversation ID';   read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_deleted_at';         fex_col: 'Deleted At';        read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_documents';          fex_col: 'Documents';         read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_groups';             fex_col: 'Groups';            read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_has_image_url';      fex_col: 'Has Image URL';     read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_location_lat';       fex_col: 'Latitude';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_location_lng';       fex_col: 'Longitude';         read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_location_name';      fex_col: 'Location Name';     read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_message_id';         fex_col: 'Message ID';        read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_photo_url';          fex_col: 'Photo URL';         read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_read';               fex_col: 'Read';              read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_send_status';        fex_col: 'Send Status';       read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_sender_id';          fex_col: 'Sender ID';         read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_sender_type';        fex_col: 'Sender Type';       read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_source_guid';        fex_col: 'Source GUID';       read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_user_id';            fex_col: 'User ID';           read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_SQLLOCATION';        fex_col: 'Location';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
  );

    Array_Items_GROUPME_CHAT_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_Zcreatedat';        fex_col: 'Created';           read_as: ftLargeInt; convert_as: 'ABS';     col_type: ftDateTime; show: True),
    (sql_col: 'DNT_ztimestamp';        fex_col: 'GroupMe Timestamp'; read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_zuserid';           fex_col: 'User ID';           read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_zname';             fex_col: 'Username';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_zmessage';          fex_col: 'Text';              read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_zfirstimageurl';    fex_col: 'First Image URL';   read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    );

    Array_Items_GroupMe_JSON: TSQL_Table_array = (
    (sql_col: 'DNT_ID';                fex_col: 'ID Col';            read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_created_at';        fex_col: 'Created At';        read_as: ftLargeInt; convert_as: 'UNIX';    col_type: ftDateTime; show: True),
    (sql_col: 'DNT_name';              fex_col: 'Username';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_text';              fex_col: 'Text';              read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_attachment_count';  fex_col: 'Attachments Count'; read_as: ftString;   convert_as: '';        col_type: ftInteger;  show: True),
    (sql_col: 'DNT_attachment_urls';   fex_col: 'Attachment URLs';   read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_avatar_url';        fex_col: 'Avatar URL';        read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_group_id';          fex_col: 'Group ID';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_id';                fex_col: 'GM ID';             read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_sender_id';         fex_col: 'Sender ID';         read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_sender_type';       fex_col: 'Sender Type';       read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_source_guid';       fex_col: 'Source GUID';       read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_system';            fex_col: 'System';            read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    (sql_col: 'DNT_platform';          fex_col: 'Platform';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
    );

  Array_Items_GROUPME_CONTACTS_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_created_at';          fex_col: 'Created';          read_as: ftLargeInt; convert_as: 'UNIX';    col_type: ftDateTime; show: True),
   (sql_col: 'DNT_name';                fex_col: 'GroupMe Name';     read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_phone_number';        fex_col: 'Phone Number';     read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_avatar_url';          fex_col: 'Avatar URL';       read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_user_id';             fex_col: 'User ID';          read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
   (sql_col: 'DNT_SQLLOCATION';         fex_col: 'Location';         read_as: ftString;   convert_as: '';        col_type: ftString;   show: True),
  );

begin
  if Name = 'GROUPME_CHAT_ANDROID' then Result := Array_Items_GROUPME_CHAT_ANDROID else
  if Name = 'GROUPME_CHAT_JSON' then Result := Array_Items_GroupMe_JSON else
  if Name = 'GROUPME_CHAT_IOS' then Result := Array_Items_GROUPME_CHAT_IOS else
  if Name = 'GROUPME_CONTACTS_ANDROID' then Result := Array_Items_GROUPME_CONTACTS_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
