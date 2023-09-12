unit AppleHealth;

interface

uses
  Columns, DataStorage, SysUtils;

const
  SP = ' ';

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
    Array_Items_APPLE_HEALTH_HEART_RATE_IOS: TSQL_Table_array = ( // Heart Rate
    (sql_col: 'DNT_Start_Date';           fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_End_Date';             fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_original_quantity';    fex_col: 'Heart Rate';                read_as: ftString;    convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_unit_string';          fex_col: 'Unit';                      read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_origin_product_type';  fex_col: 'Provenance';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_data_id';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_STEPS_IOS: TSQL_Table_array = ( // Steps
    (sql_col: 'DNT_Start_Date';           fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_End_Date';             fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_quantity';             fex_col: 'Steps Taken';               read_as: ftString;    convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_origin_product_type';  fex_col: 'Provenance';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_data_id';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_DISTANCE_IOS: TSQL_Table_array = ( // Distance
    (sql_col: 'DNT_Start_Date';           fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_End_Date';             fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_quantity';             fex_col: 'Distance (Meters)';         read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_origin_product_type';  fex_col: 'Provenance';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_data_id';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_FLIGHTS_CLIMBED_IOS: TSQL_Table_array = ( // Flights Climbed
    (sql_col: 'DNT_Start_Date';           fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_End_Date';             fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_quantity';             fex_col: 'Flights Climbed';           read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_origin_product_type';  fex_col: 'Provenance';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_data_id';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_HEIGHT_IOS: TSQL_Table_array = ( // Height
    (sql_col: 'DNT_Start_Date';           fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_End_Date';             fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_quantity';             fex_col: 'User Height';               read_as: ftString;    convert_as: '';        col_type: ftFloat;      show: True),
    (sql_col: 'DNT_unit_string';          fex_col: 'Unit';                      read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_origin_product_type';  fex_col: 'Provenance';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_data_id';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_WEIGHT_IOS: TSQL_Table_array = ( // Weight
    (sql_col: 'DNT_Start_Date';           fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_End_Date';             fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_quantity';             fex_col: 'User Weight (k)';           read_as: ftString;    convert_as: '';        col_type: ftFloat;      show: True),
    (sql_col: 'DNT_origin_product_type';  fex_col: 'Provenance';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_data_id';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_LATITUDE_IOS: TSQL_Table_array = ( // Workout - Latitude
    (sql_col: 'DNT_STARTY';               fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_ENDY';                 fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_LATITUDE';             fex_col: 'Latitude';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_WORKOUT TYPE';         fex_col: 'Workout';                   read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_DISTANCE_KM';          fex_col: 'Distance'+SP+'(Km)';        read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_DATA ID';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

    Array_Items_APPLE_HEALTH_LONGITUDE_IOS: TSQL_Table_array = ( // Workout - Longitude
    (sql_col: 'DNT_STARTY';               fex_col: 'Start Date';                read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_ENDY';                 fex_col: 'End Date';                  read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_LONGITUDE';            fex_col: 'Longitude';                 read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_WORKOUT TYPE';         fex_col: 'Workout';                   read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_DISTANCE_KM';          fex_col: 'Distance'+SP+'(Km)';        read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_DATA ID';              fex_col: 'Data ID';                   read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));


begin
  if Name = 'APPLE_HEALTH_HEART_RATE_IOS'      then Result := Array_Items_APPLE_HEALTH_HEART_RATE_IOS else
  if Name = 'APPLE_HEALTH_STEPS_IOS'           then Result := Array_Items_APPLE_HEALTH_STEPS_IOS else
  if Name = 'APPLE_HEALTH_DISTANCE_IOS'        then Result := Array_Items_APPLE_HEALTH_DISTANCE_IOS else
  if Name = 'APPLE_HEALTH_FLIGHTS_CLIMBED_IOS' then Result := Array_Items_APPLE_HEALTH_FLIGHTS_CLIMBED_IOS else
  if Name = 'APPLE_HEALTH_HEIGHT_IOS'          then Result := Array_Items_APPLE_HEALTH_HEIGHT_IOS else
  if Name = 'APPLE_HEALTH_WEIGHT_IOS'          then Result := Array_Items_APPLE_HEALTH_WEIGHT_IOS else
  if Name = 'APPLE_HEALTH_LATITUDE_IOS'        then Result := Array_Items_APPLE_HEALTH_LATITUDE_IOS else
  if Name = 'APPLE_HEALTH_LONGITUDE_IOS'       then Result := Array_Items_APPLE_HEALTH_LONGITUDE_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.