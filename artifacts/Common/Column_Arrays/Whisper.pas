{!NAME:      Whisper.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Whisper;

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

  Array_Items_iOS: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                                  fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCONTAINSBLOCKINGCOMMANDS';             fex_col: 'Containsblockingcommands';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZDIDCOMPLETEBLOCKINGCOMMANDS';          fex_col: 'Didcompleteblockingcommands';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZFAILED';                               fex_col: 'Failed';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZHASIMAGE';                             fex_col: 'Hasimage';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMINE';                                 fex_col: 'Mine';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZREAD';                                 fex_col: 'Read';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSENT';                                 fex_col: 'Sent';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZTRUSTED';                              fex_col: 'Trusted';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZCONVERSATION';                         fex_col: 'Conversation';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTIMESTAMP';                              fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT_ZLOCALMID';                             fex_col: 'Localmid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZMID';                                  fex_col: 'Mid';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTEXT';                                   fex_col: 'Text';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

begin
  //if Name = 'ANDROID'   then Result := Array_Items_Android;
  if Name = 'WHISPER_CHAT_IOS'       then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
  //if Name = 'PC'        then Result := Array_Items_PC;
end;

end.
