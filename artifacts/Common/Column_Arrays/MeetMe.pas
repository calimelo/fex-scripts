{!NAME:      MeetMe.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit MeetMe;

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
  //(sql_col: 'DNT_Z_PK';                                  fex_col: ' Pk';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: ' Ent';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: ' Opt';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCONTENTTYPE';                          fex_col: 'Contenttype';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZDOWNLOADSTATE';                        fex_col: 'Downloadstate';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZHASBEENSEEN';                          fex_col: 'Hasbeenseen';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZLINKSOURCE';                           fex_col: 'Linksource';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMEDIAHEIGHT';                          fex_col: 'Mediaheight';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMEDIASIZE';                            fex_col: 'Mediasize';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMEDIAWIDTH';                           fex_col: 'Mediawidth';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPHOTOFORCEEXPIRED';                    fex_col: 'Photoforceexpired';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPHOTOHASBEENVIEWED';                   fex_col: 'Photohasbeenviewed';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPHOTOVIEWINGLIMIT';                    fex_col: 'Photoviewinglimit';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSENDINGSTATE';                         fex_col: 'Sendingstate';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSENTBYCURRENTMEMBER';                  fex_col: 'Sentbycurrentmember';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSENTFIRSTCLASS';                       fex_col: 'Sentfirstclass';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSHOULDSHOWSEEN';                       fex_col: 'Shouldshowseen';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZWASDISPLAYED';                         fex_col: 'Wasdisplayed';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCONVERSATION';                         fex_col: 'Conversation';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZFARMEMBER';                            fex_col: 'Farmember';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPHOTOVIEWEDDATE';                      fex_col: 'Photovieweddate';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTIMESTAMP';                              fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZBODY';                                   fex_col: 'Body';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZFARMEMBERID';                            fex_col: 'Farmemberid';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZLOCALMESSAGEID';                         fex_col: 'Localmessageid';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZMESSAGEID';                              fex_col: 'Messageid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZNEARMEMBERID';                           fex_col: 'Nearmemberid';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPACKAGEID';                            fex_col: 'Packageid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZPHOTOURL';                               fex_col: 'Photourl';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZSENDERID';                               fex_col: 'Senderid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZSOURCEEVENT';                            fex_col: 'Sourceevent';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSTICKERID';                            fex_col: 'Stickerid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTHREADID';                               fex_col: 'Threadid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZMETADATA';                               fex_col: 'Metadata';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'MEETME_CHAT_IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.