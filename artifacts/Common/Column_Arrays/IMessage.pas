{!NAME:      iMessage.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit IMessage;

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

// iMessage Chat - iOS/OSX
    Array_Items_IMessage: TSQL_Table_array = (
    //(sql_col: 'DNT_Rowid';                  fex_col: 'Rowid';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Guid';                     fex_col: 'Guid';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Text';                     fex_col: 'Text';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Replace';                fex_col: 'Replace';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_service_center';         fex_col: 'Service Center';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_handle_id';                fex_col: 'Handle Id';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Subject';                  fex_col: 'Subject';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Country';                  fex_col: 'Country';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Attributedbody';         fex_col: 'Attributedbody';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Version';                  fex_col: 'Version';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Type';                   fex_col: 'Type';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Service';                  fex_col: 'Service';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Account';                  fex_col: 'Account';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_account_guid';             fex_col: 'Account Guid';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Error';                    fex_col: 'Error';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Date';                     fex_col: 'Date';                         read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_date_read';                fex_col: 'Date Read';                    read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_date_delivered';           fex_col: 'Date Delivered';               read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_is_delivered';             fex_col: 'Is Delivered';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_finished';              fex_col: 'Is Finished';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_emote';               fex_col: 'Is Emote';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_from_me';               fex_col: 'Is From Me';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_empty';               fex_col: 'Is Empty';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_delayed';             fex_col: 'Is Delayed';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_auto_reply';          fex_col: 'Is Auto Reply';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_prepared';            fex_col: 'Is Prepared';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_read';                  fex_col: 'Is Read';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_system_message';      fex_col: 'Is System Message';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_sent';                  fex_col: 'Is Sent';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_has_dd_results';         fex_col: 'Has Dd Results';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_service_message';       fex_col: 'Is Service Message';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_forward';               fex_col: 'Is Forward';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_was_downgraded';         fex_col: 'Was Downgraded';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_archive';               fex_col: 'Is Archive';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_cache_has_attachments';    fex_col: 'Cache Has Attachments';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_cache_roomnames';          fex_col: 'Cache Roomnames';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_was_data_detected';      fex_col: 'Was Data Detected';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_was_deduplicated';       fex_col: 'Was Deduplicated';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_audio_message';         fex_col: 'Is Audio Message';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_played';                fex_col: 'Is Played';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_date_played';              fex_col: 'Date Played';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_item_type';              fex_col: 'Item Type';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_other_handle';           fex_col: 'Other Handle';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_group_title';              fex_col: 'Group Title';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_group_action_type';      fex_col: 'Group Action Type';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_share_status';             fex_col: 'Share Status';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_share_direction';          fex_col: 'Share Direction';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_expirable';           fex_col: 'Is Expirable';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_expire_state';           fex_col: 'Expire State';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_message_action_type';    fex_col: 'Message Action Type';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_message_source';         fex_col: 'Message Source';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

// iMessage Attachements - iOS/OSX
    Array_Items_IMessageAttachments: TSQL_Table_array = (
    //(sql_col: 'DNT_Rowid';                  fex_col: 'Rowid';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_created_date';             fex_col: 'Created Date';                 read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_start_date';               fex_col: 'Start Date';                   read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Filename';                 fex_col: 'Filename';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Uti';                      fex_col: 'Uti';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_mime_type';                fex_col: 'Mime Type';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_transfer_state';           fex_col: 'Transfer State';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_is_outgoing';              fex_col: 'Is Outgoing';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_user_info';                fex_col: 'User Info';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_transfer_name';            fex_col: 'Transfer Name';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_total_bytes';              fex_col: 'Total Bytes';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Guid';                     fex_col: 'Guid';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'IMESSAGE_MESSAGE_OSX' then Result := Array_Items_IMessage else
  if Name = 'IMESSAGE_ATTACHMENTS_OSX' then Result := Array_Items_IMessageAttachments else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.