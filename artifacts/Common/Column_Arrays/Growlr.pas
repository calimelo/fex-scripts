{!NAME:      Growlr.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Growlr;

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

  Array_Items_Android: TSQL_Table_array = (
  (sql_col: 'DNT_Timestamp';                               fex_col: 'Timestamp';                                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT__id';                                   fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Withid';                                fex_col: 'Withid';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Message';                                 fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Fromme';                                  fex_col: 'From Me';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Isread';                                  fex_col: 'Is Read';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Picture';                                 fex_col: 'Picture';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Thumbnail';                               fex_col: 'Thumbnail';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Voice';                                   fex_col: 'Voice';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZTIMESTAMP';                              fex_col: 'Timestamp';                                  read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT_Z_PK';                                  fex_col: ' Pk';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_ENT';                                 fex_col: ' Ent';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Z_OPT';                                 fex_col: ' Opt';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZFROMME';                                 fex_col: 'From Me';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZWITHID';                               fex_col: 'Withid';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZMESSAGE';                                fex_col: 'Message';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZISREAD';                                 fex_col: 'Is Read';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZPICTURE';                                fex_col: 'Picture';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZTHUMBNAIL';                              fex_col: 'Thumbnail';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZVOICE';                                  fex_col: 'Voice';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );
	
begin
  if Name = 'GROWLR_CHAT_ANDROID' then Result := Array_Items_Android else
  if Name = 'GROWLR_CHAT_IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.