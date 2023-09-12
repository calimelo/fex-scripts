unit Google_Play;

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

  Array_Items_GOOGLE_PLAY_INSTALLED_APPLICATIONS: TSQL_Table_array = (
   (sql_col: 'DNT_purchase_time';                       fex_col: 'Purchase Time';                            read_as: ftLargeInt;      convert_as: 'UNIX_MS';    col_type: ftDateTime;       show: True),
   (sql_col: 'DNT_account';                             fex_col: 'Account';                                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_android_metadata';                    fex_col: 'android_metadata';                         read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_app_certificate_hash';                fex_col: 'app_certificate_hash';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_app_refund_post_delivery_window_ms';  fex_col: 'app_refund_post_delivery_window_ms';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_app_refund_pre_delivery_endtime_ms';  fex_col: 'app_refund_pre_delivery_endtime_ms';       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_backend';                             fex_col: 'backend';                                  read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
   (sql_col: 'DNT_doc_id';                              fex_col: 'Package Name';                             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_doc_type';                            fex_col: 'doc_type';                                 read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_document_hash';                       fex_col: 'document_hash';                            read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_inapp_purchase_data';                 fex_col: 'inapp_purchase_data';                      read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_inapp_signature';                     fex_col: 'inapp_signature';                          read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_library_id';                          fex_col: 'library_id';                               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_licensing_data';                      fex_col: 'licensing_data';                           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_offer_type';                          fex_col: 'offer_type';                               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_owned_via_license';                   fex_col: 'owned_via_license';                        read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_ownership';                           fex_col: 'ownership';                                read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_preordered';                          fex_col: 'preordered';                               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_shareability';                        fex_col: 'shareability';                             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_shared_by_me';                        fex_col: 'shared_by_me';                             read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_sharer_gaia_id';                      fex_col: 'sharer_gaia_id';                           read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_subs_auto_renewing';                  fex_col: 'subs_auto_renewing';                       read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_subs_initiation_time';                fex_col: 'subs_initiation_time';                     read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_subs_trial_until_time';               fex_col: 'subs_trial_until_time';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_subs_valid_until_time';               fex_col: 'subs_valid_until_time';                    read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
// (sql_col: 'DNT_subscription_library_state';          fex_col: 'subscription_library_state';               read_as: ftString;        convert_as: '';           col_type: ftString;       show: True),
  );

begin
  if Name = 'GOOGLE_PLAY_INSTALLED_APPLICATIONS' then Result := Array_Items_GOOGLE_PLAY_INSTALLED_APPLICATIONS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
