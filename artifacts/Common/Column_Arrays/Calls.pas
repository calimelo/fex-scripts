{!NAME:      Calls.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Calls;

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

  // Calls iOS4
  Array_Items_IOS3: TSQL_Table_array = (
  (sql_col: 'DNT_Rowid';                                   fex_col: 'Rowid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Date';                                    fex_col: 'Date';                                       read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_Address';                                 fex_col: 'Number';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Duration';                                fex_col: 'Duration';                                   read_as: ftinteger;     convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Flags';                                   fex_col: 'Call Type';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ID';                                      fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Name';                                    fex_col: 'Name Col';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_country_code';                            fex_col: 'Country Code';                               read_as: ftinteger;     convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_network_code';                            fex_col: 'Network Code';                               read_as: ftinteger;     convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Read';                                    fex_col: 'Read';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Assisted';                                fex_col: 'Assisted';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_face_time_data';                          fex_col: 'Face Time Data';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Originaladdress';                         fex_col: 'Original Address';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS8: TSQL_Table_array = (
  (sql_col: 'DNT_ZDATE';                                   fex_col: 'Date';                                       read_as: ftLargeInt;    convert_as: 'ABS';      col_type:  ftDateTime;  show: True),
  (sql_col: 'DNT_ZADDRESS';                                fex_col: 'Number';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZORIGINATED';                             fex_col: 'Direction';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Z_PK';                                    fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Z_ENT';                                   fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Z_OPT';                                   fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZANSWERED';                               fex_col: 'Answered';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZCALL_CATEGORY';                          fex_col: 'Call Category';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZCALLTYPE';                               fex_col: 'Call Type';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZDISCONNECTED_CAUSE';                     fex_col: 'Disconnected Cause';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZFACE_TIME_DATA';                         fex_col: 'Face Time Data';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZHANDLE_TYPE';                            fex_col: 'Handle Type';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZNUMBER_AVAILABILITY';                    fex_col: 'Number Availability';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZREAD';                                   fex_col: 'Read';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZDURATION';                               fex_col: 'Duration';                                   read_as: ftinteger;     convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDEVICE_ID';                              fex_col: 'Device ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZISO_COUNTRY_CODE';                       fex_col: 'Country Code';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLOCATION';                               fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZNAME';                                   fex_col: 'Name Col';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_ZSERVICE_PROVIDER';                       fex_col: 'Service Provider';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZUNIQUE_ID';                              fex_col: 'Unique ID';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  //=========================================================================================================================================================================

begin
  if Name = 'IOS3'       then Result := Array_Items_IOS3 else
  if Name = 'IOS8'       then Result := Array_Items_IOS8 else
  if Name = 'IOS12'      then Result := Array_Items_IOS8 else //use 8 for 12
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
