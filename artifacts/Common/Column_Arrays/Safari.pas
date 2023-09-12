unit Safari_Browser;

interface

uses
  Columns, DataStorage, SysUtils;
  
const
  SP = ' ';  

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
    Array_Items_Safari_Bookmarks: TSQL_Table_array = (
    // In all examples seen the Last Modified column is always blank.
    //(sql_col: 'DNT_last_modified';               fex_col: 'Last Modified';              read_as: ftString;             convert_as: 'SafariDT';        col_type: ftDateTime;    show: True),
    //(sql_col: 'DNT_Id';                          fex_col: 'ID Col';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Url';                           fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Title';                         fex_col: 'Title';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Type';                        fex_col: 'Type';                       read_as: ftString;             convert_as: 'BMTYPE';          col_type: ftString;      show: True),
    //(sql_col: 'DNT_special_id';                  fex_col: 'Special Id';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Parent';                      fex_col: 'Parent';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_num_children';                fex_col: 'Num Children';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Editable';                    fex_col: 'Editable';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Deletable';                   fex_col: 'Deletable';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Hidden';                      fex_col: 'Hidden';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_hidden_ancestor_count';       fex_col: 'Hidden Ancestor Count';      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_order_index';                 fex_col: 'Order Index';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_external_uuid';               fex_col: 'External Uuid';              read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Read';                        fex_col: 'Read';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_server_id';                   fex_col: 'Server Id';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_sync_key';                    fex_col: 'Sync Key';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_sync_data';                   fex_col: 'Sync Data';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Added';                       fex_col: 'Added';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Deleted';                     fex_col: 'Deleted Col';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_extra_attributes';            fex_col: 'Extra Attributes';           read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_local_attributes';            fex_col: 'Local Attributes';           read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_fetched_icon';                fex_col: 'Fetched Icon';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Icon';                        fex_col: 'Icon';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_dav_generation';              fex_col: 'Dav Generation';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_locally_added';               fex_col: 'Locally Added';              read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_archive_status';              fex_col: 'Archive Status';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Bookmarks_PList: TSQL_Table_array = (
    (sql_col: 'DNT_URLString';                     fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Title';                         fex_col: 'Title';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Cache: TSQL_Table_array = (
    (sql_col: 'DNT_TIME_STAMP';                    fex_col: 'Timestamp';                  read_as: ftString;             convert_as: '';                col_type: ftDateTime;    show: True),
    //(sql_col: 'DNT_entry_ID';                    fex_col: 'Entry Id';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Version';                     fex_col: 'Version';                    read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_hash_value';                  fex_col: 'Hash Value';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_storage_policy';              fex_col: 'Storage Policy';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_request_key';                   fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Cookies: TSQL_Table_array = (
    (sql_col: 'DNT_Create Date (UTC)';             fex_col: 'Safari Created Date (UTC)';  read_as: ftString;             convert_as: 'SafariURL';       col_type: ftString;      show: True),
    (sql_col: 'DNT_Expire Date (UTC)';             fex_col: 'Safari Expire Date (UTC)';   read_as: ftString;             convert_as: 'SafariURL';       col_type: ftString;      show: True),
    (sql_col: 'DNT_URL';                           fex_col: 'URL';                        read_as: ftString;             convert_as: 'SafariURL';       col_type: ftString;      show: True),
    (sql_col: 'DNT_Name';                          fex_col: 'Name Col';                   read_as: ftString;             convert_as: 'SafariURL';       col_type: ftString;      show: True));

    Array_Items_Safari_Downloads_XML: TSQL_Table_array = (
    (sql_col: 'DNT_DownloadEntryURL';                 fex_col: 'Download URL';              read_as: ftString;           convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_DownloadEntryIdentifier';          fex_col: 'Download Identifier';       read_as: ftString;           convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_DownloadEntryPath';                fex_col: 'Saved To Path';             read_as: ftString;           convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_DownloadEntryProgressTotalToLoad'; fex_col: 'Size of Download (Bytes)';  read_as: ftString;           convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_DownloadEntryProgressBytesSoFar';  fex_col: 'Amount Downloaded (Bytes)'; read_as: ftString;           convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Downloads_Plist: TSQL_Table_array = (
    (sql_col: 'DNT_SourceURL';                        fex_col: 'Source URL';                read_as: ftString;           convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_BytesLoaded';                      fex_col: 'Bytes Loaded';              read_as: ftString;           convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_DateAdded';                        fex_col: 'Safari Date Added';         read_as: ftString;           convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_History_Plist: TSQL_Table_array = (
    (sql_col: 'DNT_lastVisitedDate';               fex_col: 'Visit Date';                 read_as: ftString;             convert_as: 'SafariDT';        col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_title';                         fex_col: 'URL Title';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_URL';                           fex_col: 'URL';                        read_as: ftString;             convert_as: 'SafariURL';       col_type: ftString;      show: True),
    (sql_col: 'DNT_visitCount';                    fex_col: 'Visit Count';                read_as: ftinteger;            convert_as: '';                col_type: ftinteger;     show: True));

    Array_Items_Safari_History_db: TSQL_Table_array = (
    //(sql_col: 'DNT_Id';                          fex_col: 'ID Col';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_visit_time';                    fex_col: 'Visit Date';                 read_as: ftFloat;              convert_as: 'ABS';             col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_history_item';                  fex_col: 'History Item';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Title';                         fex_col: 'URL Title';                  read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_load_successful';               fex_col: 'Load Successful';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_http_non_get';                fex_col: 'Http Non Get';               read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Synthesized';                 fex_col: 'Synthesized';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_redirect_source';               fex_col: 'Redirect Source';            read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_redirect_destination';          fex_col: 'Redirect Destination';       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Origin';                      fex_col: 'Origin';                     read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Generation';                  fex_col: 'Generation';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //(sql_col: 'DNT_Attributes';                  fex_col: 'Attributes';                 read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    //at(sql_col: 'DNT_Score';                     fex_col: 'Score';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Recent_Searches_PList: TSQL_Table_array = (
    (sql_col: 'DNT_Date';                          fex_col: 'Search Date';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SearchString';                  fex_col: 'Search Term';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Recent_Searches_XML: TSQL_Table_array = (
    (sql_col: 'DNT_Search Term';                   fex_col: 'Search Term';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Tabs: TSQL_Table_array = (
    (sql_col: 'DNT_last_viewed_time';              fex_col: 'Last Viewed Time';           read_as: ftFloat;              convert_as: 'ABS';             col_type: ftDateTime;    show: True),
   (sql_col:  'DNT_URL';                           fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_UUID';                          fex_col: 'UUID';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Title';                         fex_col: 'Title';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_private_browsing';              fex_col: 'Private Browsing';           read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';                   fex_col: 'Location';                   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_TopSites_Plist: TSQL_Table_array = (
    (sql_col: 'DNT_TopSiteURLString';              fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_TopSiteTitle';                  fex_col: 'Title';                      read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

    Array_Items_Safari_Cached_Conversation_Headers: TSQL_Table_array = (
    (sql_col: 'DNT_Datems';                   fex_col: 'Date';                         read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Subject';                  fex_col: 'Subject';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Snippethtml';              fex_col: 'Snippethtml';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Senderlisthtml';           fex_col: 'Senderlisthtml';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Conversationid';           fex_col: 'Conversationid';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isunread';                 fex_col: 'Isunread';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isstarred';                fex_col: 'Isstarred';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isinbox';                  fex_col: 'Isinbox';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isspam';                   fex_col: 'Isspam';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Istrash';                  fex_col: 'Istrash';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Ismuted';                  fex_col: 'Ismuted';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isphishy';                 fex_col: 'Isphishy';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isdraft';                  fex_col: 'Isdraft';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isactivity';               fex_col: 'Isactivity';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isminbox';                 fex_col: 'Isminbox';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Personallevel';            fex_col: 'Personallevel';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Nummessages';              fex_col: 'Nummessages';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Modifydatems';             fex_col: 'Modifydatems';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Userlabelids';             fex_col: 'Userlabelids';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Hasattachment';            fex_col: 'Hasattachment';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Mostrecentmessageid';      fex_col: 'Mostrecentmessageid';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Activityid';               fex_col: 'Activityid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Modifiedtime';             fex_col: 'Modifiedtime';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Downloadattempts';         fex_col: 'Downloadattempts';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isnotification';           fex_col: 'Isnotification';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Iscalendar';               fex_col: 'Iscalendar';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Issent';                   fex_col: 'Issent';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isunsubscribable';         fex_col: 'Isunsubscribable';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Unsubscribablesenders';    fex_col: 'Unsubscribablesenders';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True));

    Array_Items_Safari_Cached_Messages: TSQL_Table_array = (
    (sql_col: 'DNT_Receiveddatems';           fex_col: 'Received Date';                read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Subject';                  fex_col: 'Subject';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Snippethtml';              fex_col: 'Snippethtml';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_address_from';             fex_col: 'Address From';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_address_to';               fex_col: 'Address To';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_address_cc';               fex_col: 'Address Cc';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_address_bcc';              fex_col: 'Address Bcc';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_address_replyTo';          fex_col: 'Address Replyto';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Messageid';                fex_col: 'Messageid';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Conversationid';           fex_col: 'Conversationid';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Activityid';               fex_col: 'Activityid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isunread';                 fex_col: 'Isunread';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isstarred';                fex_col: 'Isstarred';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isinbox';                  fex_col: 'Isinbox';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isspam';                   fex_col: 'Isspam';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Istrash';                  fex_col: 'Istrash';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Ismuted';                fex_col: 'Ismuted';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Isphishy';               fex_col: 'Isphishy';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Isdraft';                fex_col: 'Isdraft';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Isactivity';             fex_col: 'Isactivity';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Isminbox';                 fex_col: 'Isminbox';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Personallevel';            fex_col: 'Personallevel';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Body';                     fex_col: 'Body';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Isclipped';              fex_col: 'Isclipped';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Attachments';              fex_col: 'Attachments';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Hasexternalimages';      fex_col: 'Hasexternalimages';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Hasstrippedexternalimages';fex_col: 'Hasstrippedexternalimages';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Imagesalwaysdisplayed';  fex_col: 'Imagesalwaysdisplayed';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Uploadedattachments';    fex_col: 'Uploadedattachments';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Localupdate';            fex_col: 'Localupdate';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Lastaction';             fex_col: 'Lastaction';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Originalmessageid';      fex_col: 'Originalmessageid';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Entityrefid';            fex_col: 'Entityrefid';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Spammessagetodisplay';   fex_col: 'Spammessagetodisplay';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Eventcards';             fex_col: 'Eventcards';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Firsteventcardresponse'; fex_col: 'Firsteventcardresponse';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Issent';                 fex_col: 'Issent';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Permanentmessageid';     fex_col: 'Permanentmessageid';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Highencrypted';          fex_col: 'Highencrypted';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Digitallysigned';        fex_col: 'Digitallysigned';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True));

begin
  if Name = 'SAFARIBOOKMARKS'                 then Result := Array_Items_Safari_Bookmarks else
  if Name = 'SAFARIBOOKMARKSPLIST'            then Result := Array_Items_Safari_Bookmarks_Plist else
  if Name = 'SAFARICACHE'                     then Result := Array_Items_Safari_Cache else
  if Name = 'SAFARICOOKIES'                   then Result := Array_Items_Safari_Cookies else
  if Name = 'SAFARIDOWNLOADSXML'              then Result := Array_Items_Safari_Downloads_XML else
  if Name = 'SAFARIDOWNLOADSPLIST'            then Result := Array_Items_Safari_Downloads_PLIST else
  if Name = 'SAFARIHISTORYPLIST'              then Result := Array_Items_Safari_History_Plist else
  if Name = 'SAFARIHISTORYDB'                 then Result := Array_Items_Safari_History_db else
  if Name = 'SAFARIRECENTSEARCHESXML'         then Result := Array_Items_Safari_Recent_Searches_XML else
  if Name = 'SAFARIRECENTSEARCHESPLIST'       then Result := Array_Items_Safari_Recent_Searches_PLIST else
  if Name = 'SAFARITOPSITESPLIST'             then Result := Array_Items_Safari_TopSites_Plist else
  if Name = 'SAFARITABS'                      then Result := Array_Items_Safari_Tabs else
  if Name = 'SAFARICACHEDCONVERSATIONHEADERS' then Result := Array_Items_Safari_Cached_Conversation_Headers else
  if Name = 'SAFARICACHEDMESSAGES'            then Result := Array_Items_Safari_Cached_Messages else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.