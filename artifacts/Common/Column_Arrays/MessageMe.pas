{!NAME:      MessageMe.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit MessageMe;

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
  (sql_col: 'DNT_ZSORTTIME';                               fex_col: 'Sorttime';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFIRSTNAME';                              fex_col: 'First Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLASTNAME';                               fex_col: 'Last Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTEXT';                                   fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSENDER';                                 fex_col: 'Type';                                       read_as: ftString;      convert_as: 'MMES';     col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_PK';                                  fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCLIENTID';                             fex_col: 'Clientid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOMMANDID';                            fex_col: 'Commandid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCREATEDAT';                            fex_col: 'Createdat';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCONVERSATION';                         fex_col: 'Conversation';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSTATE';                                fex_col: 'State';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMEMBER';                               fex_col: 'Member';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZCOVERIMAGECHANGED';                    fex_col: 'Coverimagechanged';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZNAMECHANGED';                          fex_col: 'Namechanged';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZPROFILEIMAGECHANGED';                  fex_col: 'Profileimagechanged';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBHEIGHT';                          fex_col: 'Thumbheight';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBWIDTH';                           fex_col: 'Thumbwidth';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSTICKER';                              fex_col: 'Sticker';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZHASLINKS';                             fex_col: 'Haslinks';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZDURATION';                             fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBHEIGHT1';                         fex_col: 'Thumbheight1';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBWIDTH1';                          fex_col: 'Thumbwidth1';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZDURATION1';                            fex_col: 'Duration1';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZDURATION2';                            fex_col: 'Duration2';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLATITUDE';                             fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLONGITUDE';                            fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZADDRESS';                              fex_col: 'Address';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZLOCATIONID';                           fex_col: 'Locationid';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZIMAGEKEY';                             fex_col: 'Imagekey';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBKEY';                             fex_col: 'Thumbkey';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZARTISTNAME';                           fex_col: 'Artistname';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZARTWORKURL';                           fex_col: 'Artworkurl';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZPREVIEWURL';                           fex_col: 'Previewurl';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTRACKNAME';                            fex_col: 'Trackname';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTRACKURL';                             fex_col: 'Trackurl';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBKEY1';                            fex_col: 'Thumbkey1';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZVIDEOKEY';                             fex_col: 'Videokey';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZSOUNDKEY';                             fex_col: 'Soundkey';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTHUMBURL';                             fex_col: 'Thumburl';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZTITLE';                                fex_col: 'Title';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZVIDEOID';                              fex_col: 'Videoid';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZDATA';                                 fex_col: 'Data';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'MESSAGEME_CHAT_IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
