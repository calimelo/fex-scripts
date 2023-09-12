{!NAME:      Contacts.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Contacts;

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

  // Contacts Android - Contacts3.db
  Array_Items_Android3: TSQL_Table_array = (
  (sql_col: 'DNT_ID';                                      fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Lastcontacteddate';                       fex_col: 'Last Contacted Date';                        read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Displayname';                             fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Phonenumbers';                            fex_col: 'Phone Numbers';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Accounts';                                fex_col: 'Accounts';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Emails';                                  fex_col: 'Emails';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Notes';                                   fex_col: 'Notes';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Photo';                                   fex_col: 'Photo';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Timescontacted';                          fex_col: 'Times Contacted';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Starred';                                 fex_col: 'Starred';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  // Contacts Android - contactsManager.db
  Array_Items_Android_Manager: TSQL_Table_array = (
  (sql_col: 'DNT_ID';                                      fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_display_name';                            fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_raw_contact_id';                          fex_col: 'Raw Contact ID';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_contact_id';                              fex_col: 'Contact ID';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Version';                                 fex_col: 'Version';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Mimetype';                                fex_col: 'Mimetype';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data1';                                   fex_col: 'Data1';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data2';                                   fex_col: 'Data2';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data3';                                   fex_col: 'Data3';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data4';                                   fex_col: 'Data4';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data5';                                   fex_col: 'Data5';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data6';                                   fex_col: 'Data6';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data7';                                   fex_col: 'Data7';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data8';                                   fex_col: 'Data8';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Data9';                                   fex_col: 'Data9';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_times_contacted';                         fex_col: 'Times Contacted';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Starred';                                 fex_col: 'Starred';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_phonetic_name';                           fex_col: 'Phonetic Name';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Lookup';                                  fex_col: 'Lookup';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_in_visible_group';                        fex_col: 'In Visible Group';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_original_id';                             fex_col: 'Original ID';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_Rowid';                                   fex_col: 'Rowid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Creationdate';                            fex_col: 'Creationdate';                               read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Modificationdate';                        fex_col: 'Modificationdate';                           read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_First';                                   fex_col: 'First';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Last';                                    fex_col: 'Last';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Middle';                                  fex_col: 'Middle';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Firstphonetic';                           fex_col: 'Firstphonetic';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Middlephonetic';                          fex_col: 'Middlephonetic';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Lastphonetic';                            fex_col: 'Lastphonetic';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Organization';                            fex_col: 'Organization';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Department';                              fex_col: 'Department';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Note';                                    fex_col: 'Note';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Kind';                                    fex_col: 'Kind';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Birthday';                                fex_col: 'Birthday';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Jobtitle';                                fex_col: 'Jobtitle';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Nickname';                                fex_col: 'Nickname';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Prefix';                                  fex_col: 'Prefix';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Suffix';                                  fex_col: 'Suffix';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Firstsort';                               fex_col: 'Firstsort';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Lastsort';                                fex_col: 'Lastsort';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Compositenamefallback';                   fex_col: 'Compositenamefallback';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Externalidentifier';                      fex_col: 'Externalidentifier';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Externalmodificationtag';                 fex_col: 'Externalmodificationtag';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Externaluuid';                            fex_col: 'Externaluuid';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Storeid';                                 fex_col: 'Storeid';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Displayname';                             fex_col: 'Displayname';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Externalrepresentation';                  fex_col: 'Externalrepresentation';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Firstsortsection';                        fex_col: 'Firstsortsection';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Lastsortsection';                         fex_col: 'Lastsortsection';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Firstsortlanguageindex';                  fex_col: 'Firstsortlanguageindex';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Lastsortlanguageindex';                   fex_col: 'Lastsortlanguageindex';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Personlink';                              fex_col: 'Personlink';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Imageuri';                                fex_col: 'Imageuri';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Ispreferredname';                         fex_col: 'Ispreferredname';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Guid';                                    fex_col: 'Guid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Phonemedata';                             fex_col: 'Phonemedata';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Alternatebirthday';                       fex_col: 'Alternatebirthday';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Mapsdata';                                fex_col: 'Mapsdata';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
   );

  Array_Items_IOS_Recents_Recents: TSQL_Table_array = (
  //(sql_col: 'DNT_Rowid';                                 fex_col: 'Rowid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_last_date';                               fex_col: 'Last Date';                                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Dates';                                   fex_col: 'Dates';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_display_name';                            fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_bundle_identifier';                       fex_col: 'Bundle Identifier';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_sending_address';                         fex_col: 'Sending Address';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_original_source';                         fex_col: 'Original Source';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Weight';                                fex_col: 'Weight';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_record_hash';                           fex_col: 'Record Hash';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Count';                                   fex_col: 'Count Col';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_group_kind';                            fex_col: 'Group Kind';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_Recents_Contacts: TSQL_Table_array = (
  //(sql_col: 'DNT_Rowid';                                 fex_col: 'Rowid';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_recent_id';                             fex_col: 'Recent Id';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_display_name';                            fex_col: 'Display Name';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Kind';                                    fex_col: 'Kind';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Address';                                 fex_col: 'Address';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  //=========================================================================================================================================================================

begin
  if Name = 'ANDROID3'             then Result := Array_Items_Android3 else
  if Name = 'ANDROID_MANAGER'      then Result := Array_Items_Android_Manager else
  if Name = 'IOS'                  then Result := Array_Items_IOS else
  if Name = 'IOS_RECENTS_RECENTS'  then Result := Array_Items_IOS_Recents_Recents else
  if Name = 'IOS_RECENTS_CONTACTS' then Result := Array_Items_IOS_Recents_Contacts else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
