unit Garmin;

interface

uses
  Columns, DataStorage, SysUtils;

const
  SP = ' ';

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
  Array_Items_GARMIN_ACTIVITIES_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_SAVED_TIMESTAMP';            fex_col: 'Saved Timestamp';          read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_DATA_TYPE';                  fex_col: 'Data Type';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_CACHED_VAL';                 fex_col: 'Cached Value';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_LATITUDE';                   fex_col: 'Latitude';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_LONGITUDE';                  fex_col: 'Longitude';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_CONCEPT_ID';                 fex_col: 'Concept ID';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True));

  Array_Items_GARMIN_ACTIVITY_DETAILS_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_beginTimestamp';              fex_col: 'Start Timestamp';         read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_startTimeLocal';              fex_col: 'Start Time Local';        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_activityName';                fex_col: 'Activity Name';           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_activityTypeCategory';        fex_col: 'Activity Type';           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_activityId';                  fex_col: 'Activity ID';             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_eventTypeId';                 fex_col: 'Activity Type ID';        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_averageHR';                   fex_col: 'Heart Rate Ave.';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_averageSpeed';                fex_col: 'Speed Ave.';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_avgStrideLength';             fex_col: 'Stride Length Ave.';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_distance';                    fex_col: 'Distance';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_duration';                    fex_col: 'Duration';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_maxSpeed';                    fex_col: 'Max Speed';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_movingDuration';              fex_col: 'Moving Duration';         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ownerDisplayName';            fex_col: 'Owner Name';              read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ownerId';                     fex_col: 'Owner ID';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_ownerProfileImageUrlLarge';   fex_col: 'Owner Profile URL';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_startLatitude';               fex_col: 'Latitude';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_startLongitude';              fex_col: 'Longitude';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_steps';                       fex_col: 'Steps';                   read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';                 fex_col: 'Location';                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

begin
  if Name = 'GARMIN_ACTIVITIES_ANDROID'       then Result := Array_Items_GARMIN_ACTIVITIES_ANDROID else
  if Name = 'GARMIN_ACTIVITY_DETAILS_ANDROID' then Result := Array_Items_GARMIN_ACTIVITY_DETAILS_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.