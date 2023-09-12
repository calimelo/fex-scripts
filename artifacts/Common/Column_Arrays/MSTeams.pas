unit MSTeams;

interface

uses
  Columns, DataStorage, SysUtils;
  
const
  SPACE = ' ';  

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_MSTEAMS_MESSAGE_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_composeTime';                   fex_col: 'Created';                      read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_userDisplayName';               fex_col: 'User';                         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_messageType';                   fex_col: 'Message Type';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_CONTENT';                       fex_col: 'Content';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_from';                          fex_col: 'From';                         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_contentLanguageId';             fex_col: 'Language';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_deleteTime';                    fex_col: 'Delete Time';                  read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_conversationId';                fex_col: 'Conversation ID';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_messageClientID';               fex_col: 'Message Client ID';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_parentMessageId';               fex_col: 'Parent Message ID';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_messageId';                     fex_col: 'Message ID';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_version';                       fex_col: 'Version';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

  Array_Items_MSTEAMS_MESSAGES_IOS: TSQL_Table_array = (
   (sql_col: 'DNT_ZARRIVALTIME';                  fex_col: 'Created';                      read_as: ftLargeInt;      convert_as: 'ABS';        col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_ZCOMPOSETIME';                  fex_col: 'Compose Time';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZCONTENT';                      fex_col: 'Message';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZCLIENTID';                     fex_col: 'Client ID';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZFROM';                         fex_col: 'From';                         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZIMDISPLAYNAME';                fex_col: 'Display Name';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZTS_MESSAGEBASETYPE';           fex_col: 'Message Base Type';            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZTS_MESSAGECONTENTTYPE';        fex_col: 'Message Content Type';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZTS_ROOTMESSAGEID';             fex_col: 'Message ID';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZTHREADID';                     fex_col: 'Thread ID';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZTSID';                         fex_col: 'SID';                          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ZVERSION';                      fex_col: 'Version';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

  Array_Items_MSTEAMS_USER_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_lastSyncTime';                  fex_col: 'Teams' + SPACE + 'Sync Time';  read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_displayName';                   fex_col: 'User Name';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_givenName';                     fex_col: 'Given Name';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_surname';                       fex_col: 'Surname';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_email';                         fex_col: 'Email';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_imageUri';                      fex_col: 'Image URL';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_jobTitle';                      fex_col: 'Job Title';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_mri';                           fex_col: 'MRI';                          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_telephoneNumber';               fex_col: 'Telephone';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_Mobile';                        fex_col: 'Mobile';                       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_homeNumber';                    fex_col: 'Home Number';                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_type';                          fex_col: 'User Type';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_userPrincipalName';             fex_col: 'User Principal Name';          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_visibleAliases';                fex_col: 'Aliases';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

begin
  if Name = 'MSTEAMS_MESSAGE_ANDROID' then Result := Array_Items_MSTEAMS_MESSAGE_ANDROID else
  if Name = 'MSTEAMS_MESSAGES_IOS' then Result := Array_Items_MSTEAMS_MESSAGES_IOS else
  if Name = 'MSTEAMS_USER_ANDROID' then Result := Array_Items_MSTEAMS_USER_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.