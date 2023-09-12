{!NAME:      Wifi.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Wifi;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name: string) : TSQL_Table_array;

implementation

function GetTable(const Name: string) : TSQL_Table_array;
const

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_WIFI_CONFIGURATIONS_XML_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_SSID';                                    fex_col: 'SSID';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CONFIGKEY';                               fex_col: 'Securitymode';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_PRESHAREDKEY';                            fex_col: 'Network Password';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CREATORNAME';                             fex_col: 'Creator Name';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_CREATIONTIME';                            fex_col: 'Wifi Creation Time';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_RANDOMIZEDMACADDRESS';                    fex_col: 'MAC Address';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_WIFI_CONFIGURATIONS_SQLITE_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_Networkid';                               fex_col: 'Networkid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),
  (sql_col: 'DNT_Ssid';                                    fex_col: 'SSID';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Macaddress';                              fex_col: 'MAC Address';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Securitymode';                            fex_col: 'Securitymode';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_WIFI_CONFIGURATIONS_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_Lastautojoined';                          fex_col: 'Lastautojoined';              read_as: ftString;      convert_as: 'VARTODT';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Lastjoined';                              fex_col: 'Lastjoined';                  read_as: ftString;      convert_as: 'VARTODT';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SSID_STR';                                fex_col: 'Ssid Str';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Age';                                     fex_col: 'Age';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Securitymode';                            fex_col: 'Securitymode';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Strength';                                fex_col: 'Strength';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Bssid';                                   fex_col: 'Bssid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_80211D_IE';                               fex_col: '80211D Ie';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_AP_MODE';                               fex_col: 'Ap Mode';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ASSOC_FLAGS';                           fex_col: 'Assoc Flags';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Authmode';                              fex_col: 'Authmode';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_BEACON_INT';                            fex_col: 'Beacon Int';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Capabilities';                          fex_col: 'Capabilities';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Captivenetwork';                        fex_col: 'Captivenetwork';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Channel';                               fex_col: 'Channel';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_CHANNEL_FLAGS';                         fex_col: 'Channel Flags';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Disabledbycaptive';                     fex_col: 'Disabledbycaptive';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Enabled';                               fex_col: 'Enabled';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_FT_ENABLED';                            fex_col: 'Ft Enabled';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_HT_CAPS_IE';                            fex_col: 'Ht Caps Ie';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_HT_IE';                                 fex_col: 'Ht Ie';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Ie';                                    fex_col: 'Ie';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Isvalid';                               fex_col: 'Isvalid';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Iswpa';                                 fex_col: 'Iswpa';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Networkchannellistkey';                 fex_col: 'Networkchannellistkey';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Networkusage';                            fex_col: 'Networkusage';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Noise';                                 fex_col: 'Noise';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ORIG_AGE';                              fex_col: 'Orig Age';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_PHY_MODE';                              fex_col: 'Phy Mode';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Rates';                                 fex_col: 'Rates';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_RSN_IE';                                fex_col: 'Rsn Ie';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Rssi';                                  fex_col: 'Rssi';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Scaledrate';                            fex_col: 'Scaledrate';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Scaledrssi';                            fex_col: 'Scaledrssi';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_SCAN_result_FROM_PROBE_RSP';            fex_col: 'Scan Result From Probe Rsp';  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Wepkeylen';                             fex_col: 'Wepkeylen';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Wifinetworkisios';                      fex_col: 'Wifinetworkisios';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Wifinetworkissecure';                   fex_col: 'Wifinetworkissecure';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Wifinetworkrequirespassword';           fex_col: 'Wifinetworkrequirespassword'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_WPA_IE';                                fex_col: 'Wpa Ie';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'WIFI_CONFIGURATIONS_XML_ANDROID'    then Result := Array_Items_WIFI_CONFIGURATIONS_XML_ANDROID else
  if Name = 'WIFI_CONFIGURATIONS_SQLITE_ANDROID' then Result := Array_Items_WIFI_CONFIGURATIONS_SQLITE_ANDROID else
  if Name = 'WIFI_CONFIGURATIONS_IOS'            then Result := Array_Items_WIFI_CONFIGURATIONS_IOS else
  if Name = 'WIFI_FLATTENED_DATA_ANDROID'        then Result := Array_Items_WIFI_CONFIGURATIONS_XML_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
