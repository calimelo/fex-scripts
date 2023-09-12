unit Opera_Browser;

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
    SP = ' ';

    Array_Items_Opera_Autofill: TSQL_Table_array = (
    (sql_col: 'DNT_date_created';             fex_col: 'Date Created';          read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_date_last_used';           fex_col: 'Date Last Used';        read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_name';                     fex_col: 'Value Name';            read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_value';                    fex_col: 'Value';                 read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_value_lower';              fex_col: 'Value Lower';           read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_count';                    fex_col: 'Count';                 read_as: ftinteger;     convert_as: '';         col_type: ftinteger;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;      show: True));

    Array_Items_Opera_Bookmarks: TSQL_Table_array = (
    (sql_col: 'DNT_date_added';               fex_col: 'Date Added';            read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                      fex_col: 'URL';                   read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_name';                     fex_col: 'Bookmark Name';         read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_type';                     fex_col: 'Bookmark Type';         read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_id';                       fex_col: 'Bookmark ID';           read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    (sql_col: 'DNT_guid';                     fex_col: 'GUID';                  read_as: ftString;      convert_as: '';         col_type: ftString;      show: True),
    );

    Array_Items_Opera_Cache: TSQL_Table_array = ( // This is an Opera carve
    (sql_col: 'DNT_url';                      fex_col: 'URL';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

    Array_Items_Opera_Cookies: TSQL_Table_array = (
    (sql_col: 'DNT_creation_utc';             fex_col: 'Creation UTC';          read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_expires_utc';              fex_col: 'Expires UTC';           read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_last_access_utc';          fex_col: 'Last Access UTC';       read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_host_key';                 fex_col: 'Host Key';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_name';                     fex_col: 'Cookie Name';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_path';                     fex_col: 'Path';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_value';                    fex_col: 'Value';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True));

    Array_Items_Opera_Downloads: TSQL_Table_array = (
    //(sql_col: 'DNT_Id';                     fex_col: 'ID Col';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Guid';                   fex_col: 'Guid';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_current_path';             fex_col: 'Current Path';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_target_path';              fex_col: 'Target Path';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_start_time';               fex_col: 'Start Time';            read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_received_bytes';           fex_col: 'Received Bytes';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_total_bytes';              fex_col: 'Total Bytes';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_State';                    fex_col: 'State';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_danger_type';              fex_col: 'Danger Type';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_interrupt_reason';         fex_col: 'Interrupt Reason';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Hash';                     fex_col: 'Hash';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_end_time';                 fex_col: 'End Time';              read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Opened';                   fex_col: 'Opened';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_last_access_time';       fex_col: 'Last Access Time';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Transient';                fex_col: 'Transient';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Referrer';                 fex_col: 'Referrer';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_site_url';                 fex_col: 'Site Url';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_tab_url';                  fex_col: 'Tab Url';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_tab_referrer_url';         fex_col: 'Tab Referrer Url';      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_http_method';              fex_col: 'Http Method';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_by_ext_id';                fex_col: 'By Ext Id';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_by_ext_name';              fex_col: 'By Ext Name';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Etag';                     fex_col: 'Etag';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_last_modified';            fex_col: 'Opera'+SP+'Last Modified'; read_as: ftString;   convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_mime_type';                fex_col: 'Mime Type';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_original_mime_type';       fex_col: 'Original Mime Type';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

  Array_Items_Opera_History: TSQL_Table_array = (
   (sql_col: 'DNT_last_visit_time';           fex_col: 'Last Visit Time';       read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
   (sql_col: 'DNT_url';                       fex_col: 'URL';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_title';                     fex_col: 'Title';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   (sql_col: 'DNT_typed_count';               fex_col: 'Typed Count';           read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
   (sql_col: 'DNT_visit_count';               fex_col: 'Visit Count';           read_as: ftInteger;     convert_as: '';         col_type: ftInteger;    show: True),
   (sql_col: 'DNT_SQLLOCATION';               fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Opera_Keyword_Search_Terms: TSQL_Table_array = (
  //(sql_col: 'DNT_keyword_id';               fex_col: 'Keyword ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_url_id';                   fex_col: 'Url ID';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_lower_term';                 fex_col: 'Lower Term';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Term';                     fex_col: 'Term';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Opera_URLS: TSQL_Table_array = (
  //(sql_col: 'DNT_Id';                       fex_col: 'ID Col';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Url';                        fex_col: 'URL';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Title';                      fex_col: 'Title';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_visit_count';                fex_col: 'Visit Count';           read_as: ftinteger;     convert_as: '';         col_type: ftinteger;    show: True),
  (sql_col: 'DNT_typed_count';                fex_col: 'Typed Count';           read_as: ftinteger;     convert_as: '';         col_type: ftinteger;    show: True),
  (sql_col: 'DNT_last_visit_time';            fex_col: 'Last Visit Time';       read_as: ftLargeInt;    convert_as: 'DTChrome'; col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Hidden';                     fex_col: 'Hidden';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'OPERA_AUTOFILL'             then Result := Array_Items_Opera_Autofill else
  if Name = 'OPERA_BOOKMARKS'            then Result := Array_Items_Opera_Bookmarks else
  if Name = 'OPERA_CACHE'                then Result := Array_Items_Opera_Cache else
  if Name = 'OPERA_COOKIES'              then Result := Array_Items_Opera_Cookies else
  if Name = 'OPERA_DOWNLOADS'            then Result := Array_Items_Opera_Downloads else
  if Name = 'OPERA_HISTORY'              then Result := Array_Items_Opera_History else
  if Name = 'OPERA_KEYWORD_SEARCH_TERMS' then Result := Array_Items_Opera_Keyword_Search_Terms else
  if Name = 'OPERA_URLS'                 then Result := Array_Items_Opera_URLS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.