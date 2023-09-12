unit Fitbit;

interface

uses
  Columns, DataStorage, SysUtils;

const
  SP = ' ';

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
  Array_Items_FITBIT_ACTIVITY_LOG_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_ZSTARTTIME';           fex_col: 'Fitbit'+SP+'Start Time';    read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_ZLASTMODIFIED';        fex_col: 'Fitbit'+SP+'Last Modified'; read_as: ftFloat;     convert_as: 'ABS';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_ZNAME';                fex_col: 'Activity Type';             read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZSTEPS';               fex_col: 'Steps';                     read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZDISTANCE';            fex_col: 'Distance'+SP+'(Km)';        read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZAVERAGEHEARTRATE';    fex_col: 'Heart Rate Av. (BPM)';      read_as: ftInteger;   convert_as: '';        col_type: ftInteger;    show: True),
    (sql_col: 'DNT_ZLOGID';               fex_col: 'Log ID';                    read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

  Array_Items_FITBIT_EVENT_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_TIME';                  fex_col: 'Event Time';                read_as: ftLargeInt;  convert_as: 'UNIX_MS';  col_type: ftDateTime;  show: True),
   (sql_col: 'DNT__id';                   fex_col: 'Record ID';                 read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_ACCURACY';              fex_col: 'Accuracy';                  read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_ALTITUDE';              fex_col: 'Altitude';                  read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_BEARING';               fex_col: 'Bearing';                   read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_LABEL';                 fex_col: 'Label';                     read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_LATITUDE';              fex_col: 'Latitude';                  read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_LONGITUDE';             fex_col: 'Longitude';                 read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_PACE';                  fex_col: 'Pace';                      read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_SESSION_ID';            fex_col: 'Session ID';                read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_SPEED';                 fex_col: 'Speed';                     read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                  read_as: ftString;    convert_as: '';         col_type: ftString;    show: True));

    Array_Items_FITBIT_PROFILE_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_TIME_CREATED';          fex_col: 'Time Created';              read_as: ftLargeInt;  convert_as: 'UNIX_MS';  col_type: ftDateTime;  show: True),
   (sql_col: 'DNT_TIME_UPDATED';          fex_col: 'Time Updated';              read_as: ftLargeInt;  convert_as: 'UNIX_MS';  col_type: ftDateTime;  show: True),
   (sql_col: 'DNT_UUID';                  fex_col: 'UUID';                      read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_FIRST_NAME';            fex_col: 'First Name';                read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_LAST_NAME';             fex_col: 'Last Name';                 read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_FULL_NAME';             fex_col: 'Full Name';                 read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_DISPLAY_NAME';          fex_col: 'Display Name';              read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_GENDER';                fex_col: 'Gender';                    read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_DATE_OF_BIRTH';         fex_col: 'DOB';                       read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_EMAIL';                 fex_col: 'Email';                     read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_HEIGHT';                fex_col: 'Height';                    read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_LOCALE';                fex_col: 'Locale';                    read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_PROFILE_PHOTO_LINK';    fex_col: 'Profile Photo';             read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_STRIDE_LENGTH_RUNNING'; fex_col: 'Stride Length Running';     read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_STRIDE_LENGTH_WALKING'; fex_col: 'Stride Length Walking';     read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_TIME_ZONE';             fex_col: 'Timezone';                  read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_TIME_ZONE_OFFSET';      fex_col: 'Timezone Offset';           read_as: ftString;    convert_as: '';         col_type: ftString;    show: True),
   (sql_col: 'DNT_SQLLOCATION';           fex_col: 'Location';                  read_as: ftString;    convert_as: '';         col_type: ftString;    show: True));

  Array_Items_FITBIT_USER_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_ZDISPLAYNAME';         fex_col: 'Display Name';              read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZFIRSTNAME';           fex_col: 'First Name';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZLASTNAME';            fex_col: 'Last Name';                 read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZAVATAR';              fex_col: 'Avatar';                    read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZENCODEDID';           fex_col: 'Encoded ID';                read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_ZGENDER';              fex_col: 'Gender';                    read_as: ftString;    convert_as: '';        col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';          fex_col: 'Location';                  read_as: ftString;    convert_as: '';        col_type: ftString;     show: True));

begin
  if Name = 'FITBIT_ACTIVITY_LOG_IOS'     then Result := Array_Items_FITBIT_ACTIVITY_LOG_IOS else
  if Name = 'FITBIT_EVENT_ANDROID'        then Result := Array_Items_FITBIT_EVENT_ANDROID else
  if Name = 'FITBIT_PROFILE_ANDROID'      then Result := Array_Items_FITBIT_PROFILE_ANDROID else
  if Name = 'FITBIT_USER_IOS'             then Result := Array_Items_FITBIT_USER_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.