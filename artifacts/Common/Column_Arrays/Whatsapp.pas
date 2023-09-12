{!NAME:      Whatsapp.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Whatsapp;

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

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZMESSAGEDATE';                            fex_col: 'Message Date';                               read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZSENTDATE';                               fex_col: 'Sentdate';                                   read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZTEXT';                                   fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_PK';                                  fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCHILDMESSAGESDELIVEREDCOUNT';          fex_col: 'Childmessagesdeliveredcount';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCHILDMESSAGESPLAYEDCOUNT';             fex_col: 'Childmessagesplayedcount';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCHILDMESSAGESREADCOUNT';               fex_col: 'Childmessagesreadcount';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZDOCID';                                fex_col: 'Docid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZENCRETRYCOUNT';                        fex_col: 'Encretrycount';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZFILTEREDRECIPIENTCOUNT';               fex_col: 'Filteredrecipientcount';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZFLAGS';                                fex_col: 'Flags';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZGROUPEVENTTYPE';                       fex_col: 'Groupeventtype';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZISFROMME';                             fex_col: 'Isfromme';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMESSAGEERRORSTATUS';                   fex_col: 'Messageerrorstatus';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMESSAGESTATUS';                        fex_col: 'Messagestatus';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMESSAGETYPE';                          fex_col: 'Messagetype';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSORT';                                 fex_col: 'Sort';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCHATSESSION';                          fex_col: 'Chatsession';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZGROUPMEMBER';                          fex_col: 'Groupmember';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZLASTSESSION';                          fex_col: 'Lastsession';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMEDIAITEM';                            fex_col: 'Mediaitem';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMESSAGEINFO';                          fex_col: 'Messageinfo';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPARENTMESSAGE';                        fex_col: 'Parentmessage';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZFROMJID';                                fex_col: 'Fromjid';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTOJID';                                  fex_col: 'Tojid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMEDIASECTIONID';                       fex_col: 'Mediasectionid';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZPUSHNAME';                               fex_col: 'Pushname';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSTANZAID';                             fex_col: 'Stanzaid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_IOS_CALLS: TSQL_Table_array = (
  (sql_col: 'DNT_NS.Time';                                 fex_col: 'Date';                                       read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_RAW_Date';                                fex_col: 'Raw Date';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Text_Date';                               fex_col: 'Text Date';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Number';                                  fex_col: 'Number';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_duration';                                fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_incoming';                                fex_col: 'Incoming';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_WHATSAPP_CHAT_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';                              fex_col: 'TimeStamp';                                   read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_text_data';                              fex_col: 'Message';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                            fex_col: 'Location';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_CONTACTS: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                   fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                  fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                  fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZABRECORDID';            fex_col: 'Abrecordid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZPHONESTATUS';           fex_col: 'Phonestatus';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSECTIONSORT';           fex_col: 'Sectionsort';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSORT';                  fex_col: 'Sort';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSPOTLIGHTSTATUS';       fex_col: 'Spotlightstatus';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFULLNAME';                fex_col: 'Fullname';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZGIVENNAME';               fex_col: 'Givenname';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZHIGHLIGHTEDNAME';         fex_col: 'Highlightedname';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHONENUMBER';             fex_col: 'Phonenumber';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZPHONENUMBERLABEL';        fex_col: 'Phonenumberlabel';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZABOUTTIMESTAMP';          fex_col: 'Abouttimestamp';               read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZABOUTTEXT';               fex_col: 'Abouttext';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZIDENTIFIER';              fex_col: 'Identifier';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLOCALIZEDPHONENUMBER';  fex_col: 'Localizedphonenumber';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSEARCHTOKENLIST';       fex_col: 'Searchtokenlist';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSECTIONTITLE';          fex_col: 'Sectiontitle';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZWHATSAPPID';              fex_col: 'Whatsappid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  // https://blog.group-ib.com/whatsapp_forensic_artifacts
  Array_Items_ANDROID_CONTACTS: TSQL_Table_array = (
  (sql_col: 'DNT_JID';                      fex_col: 'WhatsApp ID';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_DISPLAY_NAME';             fex_col: 'Display Name';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_NUMBER';                   fex_col: 'Number';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_WA_NAME';                  fex_col: 'WhatsApp Name';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_IS_WHATSAPP_USER';         fex_col: 'Is WhatsApp User';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_STATUS';                   fex_col: 'Status';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_STATUS_TIMESTAMP';         fex_col: 'Status TimeStamp';             read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  // https://blog.group-ib.com/whatsapp_forensic_artifacts
  Array_Items_ANDROID_MESSAGES: TSQL_Table_array = (
  (sql_col: 'DNT_TIMESTAMP';                fex_col: 'Sent TimeStamp';               read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_RECEIVED_TIMESTAMP';       fex_col: 'Received TimeStamp';           read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_key_remote_jid';           fex_col: 'Sender';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_key_from_me';              fex_col: 'Direction';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_key_id';                   fex_col: 'Message ID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_data';                     fex_col: 'Data';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_media_wa_type';            fex_col: 'Media Type';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_media_mime_type';          fex_col: 'Media Mime Type';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_media_caption';            fex_col: 'Media Caption';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_media_name';               fex_col: 'Media Name';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_media_url';                fex_col: 'Media URL';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_media_duration';           fex_col: 'Media Duration (sec)';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_latitude';                 fex_col: 'Latitude';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_longitude';                fex_col: 'Longitude';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_STATUS';                   fex_col: 'Status';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'WHATSAPP_CHAT_ANDROID'     then Result := Array_Items_WHATSAPP_CHAT_ANDROID else
  if Name = 'WHATSAPP_CONTACTS_ANDROID' then Result := Array_Items_Android_Contacts else
  if Name = 'WHATSAPP_MESSAGES_ANDROID' then Result := Array_Items_Android_Messages else
  if Name = 'WHATSAPP_CHAT_IOS'         then Result := Array_Items_IOS else
  if Name = 'WHATSAPP_CALLS_IOS'        then Result := Array_Items_IOS_CALLS else
  if Name = 'WHATSAPP_CONTACTS_IOS'     then Result := Array_Items_IOS_CONTACTS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
