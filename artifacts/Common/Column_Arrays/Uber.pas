{!NAME:      Uber.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Uber;

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

  Array_Items_IOS_Accounts: TSQL_Table_array = (
  (sql_col: 'DNT_originTimeMs';                            fex_col: 'Origin Time';                                read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_lastModifiedTimeMs';                      fex_col: 'Last Modified Time';                         read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_firstName';                               fex_col: 'First Name';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_lastName';                                fex_col: 'Last Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_email';                                   fex_col: 'Email';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_mobileDigits';                            fex_col: 'Mobile';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_pictureurl';                              fex_col: 'Picture URL';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_IOS_Eyeball: TSQL_Table_array = (
  (sql_col: 'DNT_epoch';                                   fex_col: 'Date';                                       read_as: ftString;      convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_longAddress';                             fex_col: 'Address';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_latitude';                                fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_longitude';                               fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  Array_Items_IOS_Database: TSQL_Table_array = (
  //(sql_col: 'DNT_ID';                                   fex_col: 'ID';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_timestamp_ms';                            fex_col: 'Timestamp Ms';                               read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_subtitle_segment';                        fex_col: 'Address';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_title_segment';                           fex_col: 'Title';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_latitude_v2';                             fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_longitude_v2';                            fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_uber_id';                                 fex_col: 'Uber ID';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_reference_id';                            fex_col: 'Reference ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Hash';                                  fex_col: 'Hash';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Tag';                                     fex_col: 'Tag';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_place_result';                            fex_col: 'Place Result';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Relevance';                             fex_col: 'Relevance';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Latitude';                              fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Longitude';                             fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_total_trips';                           fex_col: 'Total Trips';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Ttl';                                   fex_col: 'Ttl';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_city_id';                               fex_col: 'City Id';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Historical';                            fex_col: 'Historical';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

begin
  if Name = 'IOS_ACCOUNTS' then Result := Array_Items_IOS_Accounts else
  if Name = 'IOS_EYEBALL'  then Result := Array_Items_IOS_Eyeball else
  if Name = 'IOS_DATABASE' then Result := Array_Items_IOS_Database else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
