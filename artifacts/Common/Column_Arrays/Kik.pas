{!NAME:      Kik.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Kik;

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

  Array_Items_KIK_ATTACHMENTS_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_content_id';                     fex_col: 'Content ID';                          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_content_name';                   fex_col: 'Content Name';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_content_string';                 fex_col: 'Content String';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_content_type';                   fex_col: 'Content Type';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';                    fex_col: 'Location';                            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

  Array_Items_KIK_CONTACTS_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_JID';                                     fex_col: 'Contact ID';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_display_name';                            fex_col: 'Display Name';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_user_name';                               fex_col: 'User Name';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_photo_url';                               fex_col: 'Photo URL';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_blocked';                              fex_col: 'Is Blocked';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_KIK_CHAT_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_Timestamp';                               fex_col: 'Date';                      read_as: ftFloat;       convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Body';                                    fex_col: 'Body';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_partner_jid';                             fex_col: 'Partner Jid';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_was_me';                                  fex_col: 'Was Me';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_read_state';                              fex_col: 'Read State';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Uid';                                     fex_col: 'Uid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Length';                                  fex_col: 'Length';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_bin_id';                                  fex_col: 'Bin ID';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_sys_msg';                                 fex_col: 'Sys Msg';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_stat_msg';                                fex_col: 'Stat Msg';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_content_id';                              fex_col: 'Content ID';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_app_id';                                  fex_col: 'App ID';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_message_retry_count';                     fex_col: 'Message Retry Count';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_ATTACHMENTS: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';                             fex_col: 'Timestamp';                  read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZCONTENT';                               fex_col: 'Attachment UUID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_ZJID';                                    fex_col: 'Kik ID';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZUSERNAME';                               fex_col: 'Username';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDISPLAYNAME';                            fex_col: 'Display Name';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCHATUSER';                               fex_col: 'User ID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPPURL';                                  fex_col: 'Image URL';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_MESSAGES: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';                              fex_col: 'Date';                      read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZBODY';                                   fex_col: 'Body';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZUSERNAME';                               fex_col: 'User Name';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZDISPLAYNAME';                            fex_col: 'Display Name';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTYPE';                                   fex_col: 'Type Col';                  read_as: ftString;      convert_as: 'ZTYPE';    col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  // Android
  if Name = 'KIK_ATTACHMENTS_ANDROID' then Result := Array_Items_KIK_ATTACHMENTS_ANDROID else
  if Name = 'KIK_CONTACTS_ANDROID'    then Result := Array_Items_KIK_CONTACTS_ANDROID else
  if Name = 'KIK_CHAT_ANDROID'        then Result := Array_Items_KIK_CHAT_ANDROID else
  // iOS
  if Name = 'KIK_ATTACHMENTS_IOS'     then Result := Array_Items_IOS_ATTACHMENTS else
  if Name = 'KIK_CONTACTS_IOS'        then Result := Array_Items_IOS_CONTACTS else
  if Name = 'KIK_CHAT_IOS'            then Result := Array_Items_IOS_MESSAGES else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.