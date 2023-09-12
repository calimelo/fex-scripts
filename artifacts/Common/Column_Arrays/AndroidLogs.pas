{!NAME:      AndroidLogs.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit AndroidLogs;

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

  Array_Items_Android: TSQL_Table_array = (
  (sql_col: 'DNT_Date';                                    fex_col: 'Date';                                       read_as: ftFloat;       convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  //(sql_col: 'DNT__id';                                   fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Number';                                  fex_col: 'Number';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Name';                                    fex_col: 'Name Col';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Duration';                                fex_col: 'Duration';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Type';                                    fex_col: 'Type';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_m_subject';                             fex_col: 'Subject';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_m_content';                             fex_col: 'Content';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sim_id';                                fex_col: 'SIM ID';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Address';                               fex_col: 'Address';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Presentation';                          fex_col: 'Presentation';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_New';                                   fex_col: 'New';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Numbertype';                            fex_col: 'Numbertype';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Numberlabel';                           fex_col: 'Numberlabel';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_voicemail_uri';                         fex_col: 'Voicemail Uri';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_is_read';                               fex_col: 'Is Read';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Countryiso';                              fex_col: 'Country ISO';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_geocoded_location';                       fex_col: 'Geocoded Location';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_lookup_uri';                              fex_col: 'Lookup Uri';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_matched_number';                          fex_col: 'Matched Number';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_normalized_number';                       fex_col: 'Normalized Number';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_photo_id';                              fex_col: 'Photo ID';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_formatted_number';                        fex_col: 'Formatted Number';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Messageid';                               fex_col: 'Message ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Logtype';                                 fex_col: 'Logtype';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_Frequent';                              fex_col: 'Frequent';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Contactid';                               fex_col: 'Contactid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_raw_contact_id';                          fex_col: 'Raw Contact ID';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sns_tid';                               fex_col: 'Sns Tid';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_sns_pkey';                              fex_col: 'Sns Pkey';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_account_name';                            fex_col: 'Account Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_account_id';                              fex_col: 'Account ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_sns_receiver_count';                    fex_col: 'Sns Receiver Count';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_sp_type';                               fex_col: 'Sp Type';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_e164_number';                           fex_col: 'E164 Number';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  //(sql_col: 'DNT_cnap_name';                             fex_col: 'Cnap Name';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_cdnip_number';                          fex_col: 'Cdnip Number';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_service_type';                          fex_col: 'Service Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_country_code';                          fex_col: 'Country Code';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Cityid';                                fex_col: 'Cityid';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Fname';                                 fex_col: 'Fname';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Lname';                                 fex_col: 'Lname';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Bname';                                 fex_col: 'Bname';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_Simnum';                                fex_col: 'Simnum';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_sdn_alpha_id';                          fex_col: 'Sdn Alpha ID';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_real_phone_number';                     fex_col: 'Real Phone Number';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_call_out_duration';                     fex_col: 'Call Out Duration';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_reject_flag';                           fex_col: 'Reject Flag';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_pinyin_name';                           fex_col: 'Pinyin Name';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT__data';                                 fex_col: ' Data';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_has_content';                           fex_col: 'Has Content';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_mime_type';                             fex_col: 'Mime Type';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_source_data';                           fex_col: 'Source Data';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_source_package';                        fex_col: 'Source Package';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_State';                                 fex_col: 'State';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_remind_me_later_set';                   fex_col: 'Remind Me Later Set';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_dormant_set';                           fex_col: 'Dormant Set';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_vvm_id';                                fex_col: 'Vvm ID';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_sec_custom1';                           fex_col: 'Sec Custom1';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_sec_custom2';                           fex_col: 'Sec Custom2';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_sec_custom3';                           fex_col: 'Sec Custom3';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_photoring_uri';                         fex_col: 'Photoring Uri';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  //(sql_col: 'DNT_spam_report';                           fex_col: 'Spam Report';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'ANDROID' then Result := Array_Items_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
