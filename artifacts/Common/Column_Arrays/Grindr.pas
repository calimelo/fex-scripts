{!NAME:      Grindr.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Grindr;

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
  //(sql_col: 'DNT_Archiveid';                             fex_col: 'Archiveid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Timestamp';                               fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Body';                                    fex_col: 'Body';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Conversationid';                          fex_col: 'Conversationid';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Displayedmarkersent';                   fex_col: 'Displayedmarkersent';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Messageid';                               fex_col: 'Messageid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Orderrecv';                             fex_col: 'Orderrecv';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Receivedmarkersent';                    fex_col: 'Receivedmarkersent';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Recipient';                               fex_col: 'Recipient';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Sender';                                  fex_col: 'Sender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Stanzaid';                              fex_col: 'Stanzaid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Status';                                  fex_col: 'Status';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Type';                                    fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Unread';                                  fex_col: 'Unread';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT__id';                                   fex_col: ' ID';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT__state';                                fex_col: ' State';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_Prefs_Android: TSQL_Table_array = (
  (sql_col: 'DNT_login_email';                             fex_col: 'Login Email';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_explore_recent_searches';                 fex_col: 'Recent Searches';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_latitude';                                fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_logitude';                                fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );	

  Array_Items_Chat_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_Senttimestamp';                           fex_col: 'Senttimestamp';                              read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Text';                                    fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Imagehash';                               fex_col: 'Imagehash';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Exchangedwithprofileid';                fex_col: 'Exchangedwithprofileid';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Senderprofileid';                         fex_col: 'Sender ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Targetprofileid';                         fex_col: 'Target ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Messageid';                               fex_col: 'Messageid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Status';                                  fex_col: 'Status';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Location';                                fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Imagemessagetype';                        fex_col: 'Imagemessagetype';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );
	
begin
  if Name = 'GRINDR_CHAT_ANDROID'        then Result := Array_Items_Chat_Android else
  if Name = 'GRINDR_PREFERENCES_ANDROID' then Result := Array_Items_Prefs_Android else
  if Name = 'GRINDR_CHAT_IOS'            then Result := Array_Items_Chat_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.