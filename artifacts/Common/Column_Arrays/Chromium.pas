unit Chromium_Browser;

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

    Array_Items_Chromium_Autofill: TSQL_Table_array = (
    (sql_col: 'DNT_date_created';                  fex_col:  'Date Created';              read_as: ftLargeInt;           convert_as: 'UNIX';            col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_date_last_used';                fex_col:  'Date Last Used';            read_as: ftLargeInt;           convert_as: 'UNIX';            col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_name';                          fex_col:  'Value Name';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_value';                         fex_col:  'Value';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_value_lower';                   fex_col:  'Value Lower';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_count';                         fex_col:  'Count';                     read_as: ftinteger;            convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col:  'Location';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Bookmarks: TSQL_Table_array = (
    (sql_col: 'DNT_date_added';                    fex_col:  'Date Added UTC';            read_as: ftString;             convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                           fex_col:  'URL';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_name';                          fex_col:  'Bookmark Name';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_type';                          fex_col:  'Type';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_guid';                          fex_col:  'GUID';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_id';                            fex_col:  'ID Col';                    read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_sync_transaction_version';      fex_col:  'Sync Transaction Version';  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Cache: TSQL_Table_array = (
    (sql_col: 'DNT_url_dt';                        fex_col: 'URL Date';                   read_as: ftLargeInt;           convert_as: '';                col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                           fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_url_offset';                    fex_col: 'URL Offset';                 read_as: ftString;             convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_url_length';                    fex_col: 'URL Length';                 read_as: ftString;             convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_data_size';                     fex_col: 'Data Size' ;                 read_as: ftString;             convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_reuse_count';                   fex_col: 'Reuse Count';                read_as: ftString;             convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_refetch_count';                 fex_col: 'Refetch Count';              read_as: ftString;             convert_as: '';                col_type: ftinteger;     show: True));

    Array_Items_Chromium_Cookies: TSQL_Table_array = (
    (sql_col: 'DNT_creation_utc';                  fex_col: 'Creation UTC';               read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_last_access_utc';               fex_col: 'Last Access UTC';            read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_expires_utc';                   fex_col: 'Expires UTC';                read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_host_key';                      fex_col: 'Host Key';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_name';                          fex_col: 'Cookie Name';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_value';                       fex_col: 'Value';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_path';                        fex_col: 'Path';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_secure';                      fex_col: 'Secure';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_httponly';                    fex_col: 'HTTP Only';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_has_expires';                 fex_col: 'Has Expires';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_persistent';                  fex_col: 'Persistent';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_priority';                    fex_col: 'Priority';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_encrypted_value';             fex_col: 'Encrypted Value';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Downloads: TSQL_Table_array = (
    (sql_col: 'DNT_start_time';                    fex_col: 'Start Time';                 read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_end_time';                      fex_col: 'End Time';                   read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_last_modified';                 fex_col: 'Last Modified Date';         read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    //(sql_col: 'DNT_id';                          fex_col: 'ID Col';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_current_path';                  fex_col: 'Current Path';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_target_path';                   fex_col: 'Saved To';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_received_bytes';                fex_col: 'Received Bytes';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_total_bytes';                   fex_col: 'Total Bytes';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_state';                         fex_col: 'State';                      read_as: ftString;             convert_as: 'DOWNLOADSTATE';   col_type: ftString;      show: True),
    (sql_col: 'DNT_danger_type';                   fex_col: 'Danger Type';                read_as: ftString;             convert_as: 'DANGERTYPE';      col_type: ftString;      show: True),
    (sql_col: 'DNT_interrupt_reason';              fex_col: 'Interrupt Reason';           read_as: ftString;             convert_as: 'INTERRUPTREASON'; col_type: ftString;      show: True),
    (sql_col: 'DNT_opened';                        fex_col: 'Opened';                     read_as: ftString;             convert_as: 'OPENEDSTATE';     col_type: ftString;      show: True),
    (sql_col: 'DNT_referrer';                      fex_col: 'Referrer';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_by_ext_id';                     fex_col: 'By Ext ID';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_by_ext_name';                   fex_col: 'By Ext Name';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_etag';                          fex_col: 'Etag';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_mime_type';                     fex_col: 'Mime Type';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_original_mime_type';            fex_col: 'Original Mime Type';         read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col:  'Location';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Favicons: TSQL_Table_array = (
    //(sql_col: 'DNT_id';                          fex_col: 'ID Col';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_page_url';                      fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_icon_id';                       fex_col: 'Icon ID';                    read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_History: TSQL_Table_array = (
    //(sql_col: 'DNT_id';                          fex_col: 'ID Col';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: False),
    (sql_col: 'DNT_last_visit_time';               fex_col: 'Last Visit Time';            read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                           fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_title';                         fex_col: 'Title';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_visit_count';                   fex_col: 'Visit Count';                read_as: ftinteger;            convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_typed_count';                   fex_col: 'Typed Count';                read_as: ftinteger;            convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_hidden';                        fex_col: 'Hidden';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: False),
    (sql_col: 'DNT_favicon_id';                    fex_col: 'Favicon ID';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: False),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Keyword_Search_Terms: TSQL_Table_array = (
    //(sql_col: 'DNT_keyword_id';                  fex_col: 'Keyword ID';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_url_id';                      fex_col: 'URL ID';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_lower_term';                  fex_col: 'lower_term';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_term';                          fex_col: 'Term';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Logins: TSQL_Table_array = (
    (sql_col: 'DNT_date_created';                  fex_col: 'Date Created';               read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_origin_url';                    fex_col: 'Origin URL';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_action_url';                    fex_col: 'Action URL';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_username_element';              fex_col: 'Username Element';           read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_username_value';                fex_col: 'Username Value';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_password_element';              fex_col: 'Password Element';           read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_password_value';                fex_col: 'Password Value';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_submit_element';                fex_col: 'Submit Element';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_signon_realm';                  fex_col: 'Signon Realm';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_ssl_valid';                     fex_col: 'SSL Valid';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_preferred';                     fex_col: 'Preferred';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_blacklisted_by_user';           fex_col: 'BlackListed By User';        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_scheme';                        fex_col: 'Scheme';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_password_type';                 fex_col: 'Password Type';              read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_possible_usernames';            fex_col: 'Possible Usernames';         read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_times_used';                    fex_col: 'Times Used';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_form_data';                     fex_col: 'Form Data';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_date_synced';                   fex_col: 'Date Synced';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_display_name';                  fex_col: 'Display Name';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_icon_url';                      fex_col: 'Icon URL';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_federation_url';                fex_col: 'Federation URL';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_skip_zero_click';               fex_col: 'Skip Zero Click';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_generation_upload_status';      fex_col: 'Generation Upload Status';   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_Shortcuts: TSQL_Table_array = (
    //(sql_col: 'DNT_id';                          fex_col:  'ID Col';                    read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_last_access_time';              fex_col:  'Last Access Time';          read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_text';                          fex_col:  'URL';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_fill_into_edit';              fex_col:  'Fill Into Edit';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_url';                           fex_col:  'URL';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_contents';                    fex_col:  'Contents';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_contents_class';              fex_col:  'Contents Class';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_description';                 fex_col:  'Description';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_description_class';           fex_col:  'Description Class';         read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_transition';                    fex_col:  'Transition';                read_as: ftString;             convert_as: 'TRANSITIONTYPE';  col_type: ftString;      show: True),
    //(sql_col: 'DNT_type';                        fex_col:  'Type Col';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_keyword';                     fex_col:  'Keyword';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_number_of_hits';                fex_col:  'Number of Hits';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col:  'Location';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Chromium_SyncData: TSQL_Table_array = (
    //(sql_col: 'DNT_Metahandle';                 fex_col: 'Metahandle';                  read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_base_version';               fex_col: 'Base Version';                read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_version';             fex_col: 'Server Version';              read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_local_external_id';          fex_col: 'Local External Id';           read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_transaction_version';        fex_col: 'Transaction Version';         read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    (sql_col: 'DNT_Mtime';                        fex_col: 'Mtime';                       read_as: ftLargeInt;           convert_as: 'UNIX_MS';         col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_server_mtime';                 fex_col: 'Server Mtime';                read_as: ftLargeInt;           convert_as: 'UNIX_MS';         col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Ctime';                        fex_col: 'Ctime';                       read_as: ftLargeInt;           convert_as: 'UNIX_MS';         col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_server_ctime';                 fex_col: 'Server Ctime';                read_as: ftLargeInt;           convert_as: 'UNIX_MS';         col_type: ftDateTime;   show: True),
    //(sql_col: 'DNT_Id';                         fex_col: 'ID Col';                      read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_parent_id';                  fex_col: 'Parent Id';                   read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_parent_id';           fex_col: 'Server Parent Id';            read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_unsynced';                fex_col: 'Is Unsynced';                 read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_unapplied_update';        fex_col: 'Is Unapplied Update';         read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_del';                     fex_col: 'Is Del';                      read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_is_dir';                     fex_col: 'Is Dir';                      read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_is_dir';              fex_col: 'Server Is Dir';               read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_is_del';              fex_col: 'Server Is Del';               read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    (sql_col: 'DNT_non_unique_name';              fex_col: 'Non Unique Name';             read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    (sql_col: 'DNT_server_non_unique_name';       fex_col: 'Server Non Unique Name';      read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    (sql_col: 'DNT_unique_server_tag';            fex_col: 'Unique Server Tag';           read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_unique_client_tag';          fex_col: 'Unique Client Tag';           read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_unique_bookmark_tag';        fex_col: 'Unique Bookmark Tag';         read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    (sql_col: 'DNT_Specifics';                    fex_col: 'Specifics';                   read_as: ftString;             convert_as: 'SyncData';        col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_specifics';           fex_col: 'Server Specifics';            read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_base_server_specifics';      fex_col: 'Base Server Specifics';       read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_unique_position';     fex_col: 'Server Unique Position';      read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_unique_position';            fex_col: 'Unique Position';             read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_attachment_metadata';        fex_col: 'Attachment Metadata';         read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    //(sql_col: 'DNT_server_attachment_metadata'; fex_col: 'Server Attachment Metadata';  read_as: ftString;             convert_as: '';                col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';                    read_as: ftString;             convert_as: '';                col_type: ftString;     show: True));

    Array_Items_Chromium_TopSites: TSQL_Table_array = (
    (sql_col: 'DNT_last_updated';                  fex_col:  'Last Updated';              read_as: ftLargeInt;           convert_as: 'DTChrome';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                           fex_col:  'URL';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_url_rank';                      fex_col:  'URL Rank';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_title';                         fex_col:  'Title';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_thumbnail';                     fex_col:  'Thumbnail';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_redirects';                     fex_col:  'Redirects';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_boring_score';                fex_col:  'Boring Score';              read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_good_clipping';                 fex_col:  'Good Clipping';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_at_top';                      fex_col:  'At Top';                    read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_load_completed';              fex_col:  'Load Complete';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_last_forced';                 fex_col:  'Last Forced';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col:  'Location';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

begin
  if Name = 'CHROMEAUTOFILL'             then Result := Array_Items_Chromium_Autofill else
  if Name = 'CHROMEBOOKMARKS'            then Result := Array_Items_Chromium_Bookmarks else
  if Name = 'CHROMIUMCACHE'              then Result := Array_Items_Chromium_Cache else
  if Name = 'CHROMIUMCOOKIES'            then Result := Array_Items_Chromium_Cookies else
  if Name = 'CHROMIUMDOWNLOADS'          then Result := Array_Items_Chromium_Downloads else
  if Name = 'CHROMIUMFAVICONS'           then Result := Array_Items_Chromium_Favicons else
  if Name = 'CHROMIUMHISTORY'            then Result := Array_Items_Chromium_History else
  if Name = 'CHROMIUMKEYWORDSEARCHTERMS' then Result := Array_Items_Chromium_Keyword_Search_Terms else
  if Name = 'CHROMIUMLOGINS'             then Result := Array_Items_Chromium_Logins else
  if Name = 'CHROMIUMSHORTCUTS'          then Result := Array_Items_Chromium_Shortcuts else
  if Name = 'CHROMIUMTOPSITES'           then Result := Array_Items_Chromium_TopSites else
  if Name = 'CHROMIUMSYNCDATA'           then Result := Array_Items_Chromium_SyncData else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.