{!NAME:      UserDictionary.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit UserDictionary;

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
  //(sql_col: 'DNT_ZAUXINTVALUE1';                         fex_col: 'Auxintvalue1';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXINTVALUE2';                         fex_col: 'Auxintvalue2';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXINTVALUE3';                         fex_col: 'Auxintvalue3';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXINTVALUE4';                         fex_col: 'Auxintvalue4';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZTIMESTAMP';                            fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT_ZAUXSTRINGVALUE1';                      fex_col: 'Auxstringvalue1';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXSTRINGVALUE2';                      fex_col: 'Auxstringvalue2';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXSTRINGVALUE3';                      fex_col: 'Auxstringvalue3';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXSTRINGVALUE4';                      fex_col: 'Auxstringvalue4';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPARTOFSPEECH';                         fex_col: 'Partofspeech';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZPHRASE';                                 fex_col: 'Phrase';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZSHORTCUT';                               fex_col: 'Shortcut';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZAUXDATAVALUE';                         fex_col: 'Auxdatavalue';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

begin
  if Name = 'IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
