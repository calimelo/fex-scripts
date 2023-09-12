unit Brave_Browser;

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

  Array_Items_Brave_Autofill: TSQL_Table_array = (
  (sql_col: 'DNT_date_created';           fex_col:  'Date Created';        read_as: ftLargeInt;   convert_as: 'UNIX';            col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_date_last_used';         fex_col:  'Date Last Used';      read_as: ftLargeInt;   convert_as: 'UNIX';            col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_name';                   fex_col:  'Value Name';          read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_value';                  fex_col:  'Value';               read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_value_lower';            fex_col:  'Value Lower';         read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_count';                  fex_col:  'Count';               read_as: ftinteger;    convert_as: '';                col_type: ftinteger;     show: True),
  );

  Array_Items_Brave_Bookmarks: TSQL_Table_array = (
  (sql_col: 'DNT_date_added';             fex_col:  'Date Added UTC';      read_as: ftString;     convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_url';                    fex_col:  'URL';                 read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_name';                   fex_col:  'Bookmark Name';       read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_type';                   fex_col:  'Type';                read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_guid';                   fex_col:  'GUID';                read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_id';                     fex_col:  'ID Col';              read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  );

  Array_Items_Brave_Cache: TSQL_Table_array = (
  (sql_col: 'DNT_url_dt';                 fex_col: 'URL Date';             read_as: ftLargeInt;   convert_as: '';                col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_url';                    fex_col: 'URL';                  read_as: ftString;     convert_as: '';                col_type: ftString;     show: True),
  (sql_col: 'DNT_url_offset';             fex_col: 'URL Offset';           read_as: ftString;     convert_as: '';                col_type: ftinteger;    show: True),
  (sql_col: 'DNT_url_length';             fex_col: 'URL Length';           read_as: ftString;     convert_as: '';                col_type: ftinteger;    show: True),
  (sql_col: 'DNT_data_size';              fex_col: 'Data Size' ;           read_as: ftString;     convert_as: '';                col_type: ftinteger;    show: True),
  (sql_col: 'DNT_reuse_count';            fex_col: 'Reuse Count';          read_as: ftString;     convert_as: '';                col_type: ftinteger;    show: True),
  (sql_col: 'DNT_refetch_count';          fex_col: 'Refetch Count';        read_as: ftString;     convert_as: '';                col_type: ftinteger;    show: True),
  );

  Array_Items_Brave_Cookies: TSQL_Table_array = (
  (sql_col: 'DNT_creation_utc';           fex_col: 'Creation UTC';         read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_last_access_utc';        fex_col: 'Last Access UTC';      read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_expires_utc';            fex_col: 'Expires UTC';          read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_host_key';               fex_col: 'Host Key';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_name';                   fex_col: 'Cookie Name';          read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_value';                fex_col: 'Value';                read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_path';                 fex_col: 'Path';                 read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_secure';               fex_col: 'Secure';               read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_httponly';             fex_col: 'HTTP Only';            read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_has_expires';          fex_col: 'Has Expires';          read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_persistent';           fex_col: 'Persistent';           read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_priority';             fex_col: 'Priority';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  //(sql_col: 'DNT_encrypted_value';      fex_col: 'Encrypted Value';      read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True));

  Array_Items_Brave_Downloads: TSQL_Table_array = (
  (sql_col: 'DNT_start_time';             fex_col: 'Start Time';           read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_end_time';               fex_col: 'End Time';             read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_last_modified';          fex_col: 'Last Modified Date';   read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  //(sql_col: 'DNT_id';                   fex_col: 'ID Col';               read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_current_path';           fex_col: 'Current Path';         read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_target_path';            fex_col: 'Saved To';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_received_bytes';         fex_col: 'Received Bytes';       read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_total_bytes';            fex_col: 'Total Bytes';          read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_state';                  fex_col: 'State';                read_as: ftString;     convert_as: 'DOWNLOADSTATE';   col_type: ftString;      show: True),
  (sql_col: 'DNT_danger_type';            fex_col: 'Danger Type';          read_as: ftString;     convert_as: 'DANGERTYPE';      col_type: ftString;      show: True),
  (sql_col: 'DNT_interrupt_reason';       fex_col: 'Interrupt Reason';     read_as: ftString;     convert_as: 'INTERRUPTREASON'; col_type: ftString;      show: True),
  (sql_col: 'DNT_opened';                 fex_col: 'Opened';               read_as: ftString;     convert_as: 'OPENEDSTATE';     col_type: ftString;      show: True),
  (sql_col: 'DNT_referrer';               fex_col: 'Referrer';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_by_ext_id';              fex_col: 'By Ext ID';            read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_by_ext_name';            fex_col: 'By Ext Name';          read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_etag';                   fex_col: 'Etag';                 read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_mime_type';              fex_col: 'Mime Type';            read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_original_mime_type';     fex_col: 'Original Mime Type';   read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_SQLLOCATION';            fex_col:  'Location';            read_as: ftString;     convert_as: '';                col_type: ftString;      show: True));

  Array_Items_Brave_FavIcons: TSQL_Table_array = (
  //(sql_col: 'DNT_id';                   fex_col: 'ID Col';               read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_page_url';               fex_col: 'URL';                  read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_icon_id';                fex_col: 'Icon ID';              read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True));

  Array_Items_Brave_History: TSQL_Table_array = (
  //(sql_col: 'DNT_id';                   fex_col: 'ID Col';               read_as: ftString;     convert_as: '';                col_type: ftString;      show: False),
  (sql_col: 'DNT_last_visit_time';        fex_col: 'Last Visit Time';      read_as: ftLargeInt;   convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
  (sql_col: 'DNT_url';                    fex_col: 'URL';                  read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_title';                  fex_col: 'Title';                read_as: ftString;     convert_as: '';                col_type: ftString;      show: True),
  (sql_col: 'DNT_visit_count';            fex_col: 'Visit Count';          read_as: ftinteger;    convert_as: '';                col_type: ftinteger;     show: True),
  (sql_col: 'DNT_typed_count';            fex_col: 'Typed Count';          read_as: ftinteger;    convert_as: '';                col_type: ftinteger;     show: True),
  (sql_col: 'DNT_hidden';                 fex_col: 'Hidden';               read_as: ftString;     convert_as: '';                col_type: ftString;      show: False),
  (sql_col: 'DNT_favicon_id';             fex_col: 'Favicon ID';           read_as: ftString;     convert_as: '';                col_type: ftString;      show: False),
  (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';             read_as: ftString;     convert_as: '';                col_type: ftString;      show: True));

  Array_Items_Brave_Tab_History: TSQL_Table_array = (
  (sql_col: 'DNT_ZTITLE';                 fex_col: 'URL Title';            read_as: ftString;      convert_as: '';               col_type: ftString;     show: True),
  (sql_col: 'DNT_ZURL';                   fex_col: 'URL';                  read_as: ftString;      convert_as: '';               col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';            fex_col: 'Location';             read_as: ftString;      convert_as: '';               col_type: ftString;     show: True),
  );

begin
  if Name = 'BRAVEAUTOFILL'   then Result := Array_Items_Brave_AutoFill else
  if Name = 'BRAVEBOOKMARKS'  then Result := Array_Items_Brave_Bookmarks else
  if Name = 'BRAVECACHE'      then Result := Array_Items_Brave_Cache else
  if Name = 'BRAVECOOKIES'    then Result := Array_Items_Brave_Cookies else
  if Name = 'BRAVEDOWNLOADS'  then Result := Array_Items_Brave_Downloads else
  if Name = 'BRAVEFAVICONS'   then Result := Array_Items_Brave_FavIcons else
  if Name = 'BRAVEHISTORY'    then Result := Array_Items_Brave_History else
  if Name = 'BRAVETABHISTORY' then Result := Array_Items_Brave_Tab_History else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.