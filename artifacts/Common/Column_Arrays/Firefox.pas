unit Firefox_Browser;

interface

uses
  Columns, DataStorage, SysUtils;

const
  SP = ' ';

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
    Array_Items_Firefox_Bookmarks: TSQL_Table_array = (
    (sql_col: 'DNT_dateAdded';               fex_col:  'Date Added';             read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_lastModified';            fex_col:  'Last Modified Date';     read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_title';                   fex_col:  'Title';                  read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_url';                     fex_col:  'URL';                    read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_type';                    fex_col:  'Type Col';               read_as: ftString;       convert_as: 'MOZBMTYPE';       col_type: ftString;      show: True),
    (sql_col: 'DNT_fk';                      fex_col:  'FK';                     read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col:  'Location';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Cache: TSQL_Table_array = (
    (sql_col: 'DNT_TIME_STAMP';              fex_col: 'Timestamp';               read_as: ftString;       convert_as: '';                col_type: ftDateTime;    show: True),
    //(sql_col: 'DNT_entry_ID';              fex_col: 'Entry Id';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Version';               fex_col: 'Version';                 read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_hash_value';            fex_col: 'Hash Value';              read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_storage_policy';        fex_col: 'Storage Policy';          read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_request_key';             fex_col: 'URL';                     read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Cookies: TSQL_Table_array = (
    (sql_col: 'DNT_creationTime';            fex_col:  'Creation Time';          read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_lastAccessed';            fex_col:  'Last Accessed';          read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_host';                    fex_col:  'Host';                   read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_name';                    fex_col:  'Name Col';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_baseDomain';              fex_col:  'Base Domain';            read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_expiry';                  fex_col:  'Expiry';                 read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col:  'Location';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Downloads: TSQL_Table_array = (
    (sql_col: 'DNT_dateAdded';               fex_col:  'Date Added';             read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_lastModified';            fex_col:  'Last Modified Date';     read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_title';                   fex_col:  'Title';                  read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_url';                     fex_col:  'URL';                    read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_content';                 fex_col:  'Content';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col:  'DNT_SQLLOCATION';            fex_col:  'Location';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Favicons: TSQL_Table_array = (
    (sql_col: 'DNT_expiration';              fex_col: 'Expiration';              read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                     fex_col: 'URL';                     read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_mime_type';               fex_col: 'Mime Type';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Form_History: TSQL_Table_array = (

    (sql_col: 'DNT_firstused';               fex_col: 'First Used';              read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_lastused';                fex_col: 'Last Used';               read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_fieldname';               fex_col: 'Field Name';              read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_value';                   fex_col: 'Value Col';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_timesused';               fex_col: 'Times Used';              read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_History_Android: TSQL_Table_array = (
    (sql_col: 'DNT_Date';                    fex_col: 'Date';                    read_as: ftLargeInt;     convert_as: 'UNIX_MS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_Created';                 fex_col: 'Created';                 read_as: ftLargeInt;     convert_as: 'UNIX_MS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_Modified';                fex_col: 'Modified';                read_as: ftLargeInt;     convert_as: 'UNIX_MS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_Title';                   fex_col: 'Title';                   read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Url';                     fex_col: 'URL';                     read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Visits';                  fex_col: 'Visits';                  read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_favicon_id';              fex_col: 'Favicon Id';              read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_History_Visits: TSQL_Table_array = (
    (sql_col: 'DNT_visit_date';              fex_col: 'Visit Date';              read_as: ftLargeInt;     convert_as: 'UNIX_MicroS';     col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_title';                   fex_col: 'URL Title';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_url';                     fex_col: 'URL';                     read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_visit_count';             fex_col: 'Visit Count';             read_as: ftinteger;      convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_visit_type';              fex_col: 'Visit Type';              read_as: ftString;       convert_as: 'MOZVISITTYPE';    col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Places_13: TSQL_Table_array = (
    (sql_col: 'DNT_last_visit_date';         fex_col:  'Last Visit Date';        read_as: ftLargeInt;     convert_as: 'UNIX_MS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                     fex_col:  'URL';                    read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_title';                   fex_col:  'Title';                  read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_visit_count';             fex_col:  'Visit Count';            read_as: ftinteger;      convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_typed';                   fex_col:  'Typed';                  read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_favicon_id';              fex_col:  'Favicon ID';             read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_frecency';                fex_col:  'Frequency';              read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col:  'Location';               read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Firefox_Places_18: TSQL_Table_array = (
   (sql_col: 'DNT_last_visit_date_local';    fex_col: 'Last Visit Date';         read_as: ftLargeInt;     convert_as: 'UNIX_MS';         col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_url';                      fex_col: 'URL';                     read_as: ftString;       convert_as: '';                col_type: ftString;       show: True),
   (sql_col: 'DNT_title';                    fex_col: 'Title';                   read_as: ftString;       convert_as: '';                col_type: ftString;       show: True),
   (sql_col: 'DNT_visit_count_local';        fex_col: 'Visit Count';             read_as: ftinteger;      convert_as: '';                col_type: ftinteger;      show: True),
   (sql_col: 'DNT_typed';                    fex_col: 'Typed';                   read_as: ftString;       convert_as: '';                col_type: ftString;       show: True),
   (sql_col: 'DNT_frecency';                 fex_col: 'Frequency';               read_as: ftString;       convert_as: '';                col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;       show: True));

    Array_Items_Firefox_Search_History_Android: TSQL_Table_array = (
    (sql_col: 'DNT_Date';                    fex_col: 'Date';                    read_as: ftLargeInt;     convert_as: 'UNIX_MS';         col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_Query';                   fex_col: 'Query';                   read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Visits';                  fex_col: 'Visits';                  read_as: ftString;       convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';                read_as: ftString;       convert_as: '';                col_type: ftString;      show: True));

begin
  if Name = 'FIREFOXBOOKMARKS'            then Result := Array_Items_Firefox_Bookmarks else
  if Name = 'FIREFOXCACHE'                then Result := Array_Items_Firefox_Cache else
  if Name = 'FIREFOXCOOKIES'              then Result := Array_Items_Firefox_Cookies else
  if Name = 'FIREFOXDOWNLOADS'            then Result := Array_Items_Firefox_Downloads else
  if Name = 'FIREFOXFAVICONS'             then Result := Array_Items_Firefox_Favicons else
  if Name = 'FIREFOXFORMHISTORY'          then Result := Array_Items_Firefox_Form_History else
  if Name = 'FIREFOXHISTORYANDROID'       then Result := Array_Items_Firefox_History_Android else
  if Name = 'FIREFOXHISTORYVISITS'        then Result := Array_Items_Firefox_History_Visits else
  if Name = 'FIREFOXPLACES_13'            then Result := Array_Items_Firefox_Places_13 else
  if Name = 'FIREFOXPLACES_18'            then Result := Array_Items_Firefox_Places_18 else
  if Name = 'FIREFOXSEARCHHISTORYANDROID' then Result := Array_Items_Firefox_Search_History_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.