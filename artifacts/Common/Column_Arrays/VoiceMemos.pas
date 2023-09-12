{!NAME:      VoiceMemos.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit VoiceMemos;

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
  //(sql_col: 'DNT_ZITUNESPERSISTENTID';                   fex_col: 'Itunespersistentid';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZLABELPRESET';                          fex_col: 'Labelpreset';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZPENDINGRESTORE';                       fex_col: 'Pendingrestore';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZRECORDINGID';                          fex_col: 'Recordingid';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_ZSYNCED';                               fex_col: 'Synced';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZDATE';                                   fex_col: 'Date Col';                                   read_as: ftfloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZDURATION';                               fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZCUSTOMLABEL';                            fex_col: 'Customlabel';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZPATH';                                   fex_col: 'Path';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

begin
  if Name = 'IOS' then Result := Array_Items_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
