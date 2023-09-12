unit Artifacts_Operating_System_MAC;

interface

uses
{$IF DEFINED (ISFEXGUI)}
  GUI, Modules,
{$IFEND}
  ByteStream, Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DateUtils, DIRegex,
  Graphics, PropertyList, ProtoBuf, Regex, SQLite3, SysUtils, Variants,
  //-----
  Artifact_Utils      in 'Common\Artifact_Utils.pas',
  Columns             in 'Common\Column_Arrays\Columns.pas',
  Icon_List           in 'Common\Icon_List.pas',
  Itunes_Backup_Sig   in 'Common\Itunes_Backup_Signature_Analysis.pas',
  RS_DoNotTranslate   in 'Common\RS_DoNotTranslate.pas';
  //-----

type
  TVarArray = array of variant;
  TDataStoreFieldArray = array of TDataStoreField;
  PSQL_FileSearch = ^TSQL_FileSearch;

  TSQL_FileSearch = record
    fi_Carve_Header               : string;
    fi_Carve_Footer               : string;
    fi_Carve_Adjustment           : integer;
    fi_Icon_Category              : integer;
    fi_Icon_Program               : integer;
    fi_Icon_OS                    : integer;
    fi_Regex_Itunes_Backup_Domain : string;
    fi_Regex_Itunes_Backup_Name   : string;
    fi_Name_Program               : string;
    fi_Name_Program_Type          : string;
    fi_Name_OS                    : string;
    fi_NodeByName                 : string;
    fi_Process_As                 : string;
    fi_Process_ID                 : string;
    fi_Reference_Info             : string;
    fi_Regex_Search               : string;
    fi_RootNodeName               : string;
    fi_Signature_Parent           : string;
    fi_Signature_Sub              : string;
    fi_SQLStatement               : string;
    fi_SQLTables_Required         : array of string;
    fi_SQLPrimary_Tablestr        : string;
    fi_Test_Data                  : string;
  end;

const
  ATRY_EXCEPT_STR           = 'TryExcept: '; //noslz
  ANDROID                   = 'Android'; //noslz
  BMF_FILESYSTEM_MAC        = 'File System';
  BMF_MY_BOOKMARKS          = 'My Bookmarks';
  BMF_TRIAGE                = 'Triage';
  BS                        = '\';
  BL_PROCEED_LOGGING        = False;
  CANCELED_BY_USER          = 'Canceled by user.';
  CATEGORY_NAME             = 'MAC Operating System';
  CHAR_LENGTH               = 80;
  COLON                     = ':';
  COMMA                     = ',';
  CR                        = #13#10;
  DCR                       = #13#10 + #13#10;
  DUP_FILE                  = '';
  FBN_ITUNES_BACKUP_DOMAIN  = 'iTunes Backup Domain'; //noslz
  FBN_ITUNES_BACKUP_NAME    = 'iTunes Backup Name'; //noslz
  GFORMAT_STR               = '%-1s %-12s %-8s %-15s %-25s %-30s %-20s';
  GROUP_NAME                = 'Artifact Analysis';
  HYPHEN                    = ' - ';
  HYPHEN_NS                 = '-';
  IOS                       = 'iOS'; //noslz
  NUMBEROFSEARCHITEMS       = 37; //********************************************
  PIPE                      = '|'; //noslz
  PLIST_BINARY_SIG          = 'Plist (Binary)'; //noslz
  PROCESS_AS_CARVE          = 'PROCESSASCARVE'; //noslz
  PROCESS_AS_PLIST          = 'PROCESSASPLIST'; //noslz
  PROCESS_AS_TEXT           = 'PROCESSASTEXT'; //noslz
  PROCESS_AS_XML            = 'PROCESSASXML'; //noslz
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'MAC Operating System';
  RPAD_VALUE                = 55;
  RUNNING                   = '...';
  SCRIPT_DESCRIPTION        = 'Extract MAC Operating System Artifacts';
  SCRIPT_NAME               = 'Operating_System_MAC.pas';
  SIG_SKYPE                 = 'Skype'; //noslz
  SIG_SQLITE                = 'SQLite'; //noslz
  SPACE                     = ' ';
  STR_FILES_BY_PATH         = 'Files by path';
  TRIAGE                    = 'TRIAGE'; //noslz
  TSWT                      = 'The script will terminate.';
  USE_FLAGS_BL              = False;
  VERBOSE                   = False;
  WINDOWS                   = 'Windows'; //noslz
  XML_SIG                   = 'XML'; //noslz

const {column setup}

  Array_Items_1: TSQL_Table_array = ( // AddressBookMe - MAC - "The actual entry for the suspect gathered during the Apple registration of Leopard" Chapter9, 231
    (sql_col: 'DNT_FirstName';                 fex_col: 'First Name';              read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LastName';                  fex_col: 'Last Name';               read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ExistingEmailAddress';      fex_col: 'Existing Email Address';  read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_City';                      fex_col: 'City';                    read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Company';                   fex_col: 'Company';                 read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_CountryName';               fex_col: 'Country Name';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LocalPhoneNumber';          fex_col: 'Local Phone Number';      read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_StateProv';                 fex_col: 'State';                   read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_StreetAddr1';               fex_col: 'Street Address 1';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_StreetAddr2';               fex_col: 'Street Address 2';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ZipPostal';                 fex_col: 'Zip Code';                read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_2: TSQL_Table_array = ( // Attached iDevices - MAC
    (sql_col: 'DNT_Device Class';              fex_col: 'Device Class';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ID';                        fex_col: 'Device ID';               read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Serial Number';             fex_col: 'Serial Number';           read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_IMEI';                      fex_col: 'IMEI';                    read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Firmware Version String';   fex_col: 'Firmware Version String'; read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Use Count';                 fex_col: 'Use Count';               read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Connected';                 fex_col: 'Connected Date';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Family ID';                 fex_col: 'Family ID';               read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Firmware Version';          fex_col: 'Firmware Version';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_3: TSQL_Table_array = ( // Bluetooth - MAC
    (sql_col: 'DNT_MAC Address';               fex_col: 'MAC Address';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Name';                      fex_col: 'Bluetooth Name';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ModelIdentifier';           fex_col: 'Model Identifier';     read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Manufacturer';              fex_col: 'Manufacturer';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LastServicesUpdate';        fex_col: 'Last Services Update'; read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LastNameUpdate';            fex_col: 'Last Name Update';     read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LastInquiryUpdate';         fex_col: 'Last Inquiry Update';  read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ClockOffset';               fex_col: 'Clock Offset';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_4: TSQL_Table_array = ( // DHCP - MAC
    (sql_col: 'DNT_LEASESTARTDATE';            fex_col: 'Lease Start Date';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_IPADDRESS';                 fex_col: 'IP Address';              read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ROUTERHARDWAREADDRESS';     fex_col: 'Router Hardware Address'; read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ROUTERIPADDRESS';           fex_col: 'Router IP Address';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LEASELENGTH';               fex_col: 'Lease Length';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_5: TSQL_Table_array = ( // Dock Items - MAC
    (sql_col: 'DNT__file-label';               fex_col: 'Dock Item';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT__CFURLString';              fex_col: 'Dock File';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_6: TSQL_Table_array = ( // iCloud User Preferences - MAC
    (sql_col: 'DNT_DisplayName';               fex_col: 'Display Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_firstName';                 fex_col: 'First Name';           read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_lastName';                  fex_col: 'Last Name';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_AccountID';                 fex_col: 'Account ID';           read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_AccountUUID';               fex_col: 'Account UUID';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_AccountDescription';        fex_col: 'Account Description';  read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_IsPaidAccount';             fex_col: 'Is Paid Account';      read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LoggedIn';                  fex_col: 'Logged In';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_7: TSQL_Table_array = ( // iMessage Accounts - MAC
    (sql_col: 'DNT_AuthID';                    fex_col: 'AuthID';               read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LoginAs';                   fex_col: 'Login As';             read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_DisplayName';               fex_col: 'Display Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_8: TSQL_Table_array = ( // Installation Time - MAC ("Empty file. Its last modification time represent the date/time the OS was installed")
    (sql_col: 'DNT_InstallationTime';          fex_col: 'Installation Date';    read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_9: TSQL_Table_array = ( // Installed Printers - MAC
    (sql_col: 'DNT_InstalledPrinter';          fex_col: 'Printer';              read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_10: TSQL_Table_array = ( // Last Sleep - MAC
    (sql_col: 'DNT_LastSleep';                 fex_col: 'Last Sleep';           read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_11: TSQL_Table_array = ( // Login Items - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'Item Name';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_12: TSQL_Table_array = ( // Login Window - MAC
    (sql_col: 'DNT_lastUser';                  fex_col: 'Last User';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_RetriesUntilHint';          fex_col: 'Retries Until Hint';   read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_lastUserName';              fex_col: 'Last User Name';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_autoLoginUser';             fex_col: 'Auto Login User';      read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_13: TSQL_Table_array = ( // Mail BackupTOC - MAC
    (sql_col: 'DNT_Type';                      fex_col: 'Type';                 read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Path';                      fex_col: 'Path';                 read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Account-ID';                fex_col: 'Account-ID';           read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Display-Name';              fex_col: 'Display-Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_14: TSQL_Table_array = ( // Mail Folder - MAC
    (sql_col: 'DNT_MailFolder';                fex_col: 'Mail Folder';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_15: TSQL_Table_array = ( // Networks - Known Networks
    (sql_col: 'DNT_SSID_STR';                  fex_col: 'SSID String';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_SecurityType';              fex_col: 'Security Type';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Unique Password ID';        fex_col: 'Unique Password ID';   read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT__timeStamp';                fex_col: 'TimeStamp String';     read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_16: TSQL_Table_array = ( // Networks - Recent Networks
    (sql_col: 'DNT_SSID_STR';                  fex_col: 'SSID String';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_SecurityType';              fex_col: 'Security Type';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Unique Network ID';         fex_col: 'Unique Network ID';    read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Unique Password ID';        fex_col: 'Unique Password ID';   read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_17: TSQL_Table_array = ( // OSX Update - MAC
    (sql_col: 'DNT_LastSuccessfulDate';        fex_col: 'Last Successful Date'; read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LastAttemptDate';           fex_col: 'Last Attempt Date';    read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LastresultCode';            fex_col: 'Last Result Code';     read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_18: TSQL_Table_array = ( // Preferences - MAC
    (sql_col: 'DNT_CURRENTSET';                fex_col: 'Current Set';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_LOCALHOSTNAME';             fex_col: 'Local Host Name';      read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_COMPUTERNAME';              fex_col: 'Computer Name';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_MODEL';                     fex_col: 'Model';                read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_19: TSQL_Table_array = ( // Printers (CUPS) - MAC
    (sql_col: 'DNT_printer-name';              fex_col: 'Printer Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_printer-info';              fex_col: 'Printer Info';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_printer-make-and-model';    fex_col: 'Printer Make/Model';   read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_printer-location';          fex_col: 'Printer Location';     read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_20: TSQL_Table_array = ( // Printers (CUPS - Control) - MAC
    // Use sql_col to store the regex
    (sql_col: 'DNT_(?<!-)time-at-creation';      fex_col: 'Creation Time';            read_as: ftString;  convert_as: '';   col_type: ftDateTime;     show: True),
    (sql_col: 'DNT_job-name';                    fex_col: 'Job Name';                 read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_job-originating-user-name';   fex_col: 'Job Originating Username'; read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_PMJobOwner';                  fex_col: 'Job Owner';                read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_attributes-charset';          fex_col: 'CharSet';                  read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_natural-language';            fex_col: 'Natural Language';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_printer-uri';                 fex_col: 'Printer Uri';              read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_DestinationPrinterID';        fex_col: 'Destination Printer ID';   read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_job-printer-state-message';   fex_col: 'Job Status Message';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_21: TSQL_Table_array = ( // Recent Applications - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'Application';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_22: TSQL_Table_array = ( // Recent Documents - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'Document Name';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_23: TSQL_Table_array = ( // Recent Hosts - MAC
    (sql_col: 'DNT_Url';                       fex_col: 'URL';                  read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Name';                      fex_col: 'Hosts';                read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_24: TSQL_Table_array = ( // Recent iWork Numbers - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'Numbers Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_25: TSQL_Table_array = ( // Recent iWork Pages - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'Pages Name';           read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_26: TSQL_Table_array = ( // Recent Photo Booth - MAC
    (sql_col: 'DNT_FileName';                  fex_col: 'File Name';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_27: TSQL_Table_array = ( // Recent Preview - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'Preview Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_28: TSQL_Table_array = ( // Recent QuickTime - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'QuickTime Name';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_29: TSQL_Table_array = ( // Recent TextEdit - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'TextEdit Name';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_30: TSQL_Table_array = ( // Recent VLC - MAC
    (sql_col: 'DNT_Name';                      fex_col: 'VLC Name';             read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_31: TSQL_Table_array = ( // System Version - MAC
    (sql_col: 'DNT_ProductBuildVersion';       fex_col: 'Product Build Version';read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ProductCopyright';          fex_col: 'Product Copyright';    read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ProductName';               fex_col: 'Product Name';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ProductCopyright';          fex_col: 'Product Version';      read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_32: TSQL_Table_array = ( // Safari - Preferences
    (sql_col: 'DNT_DownloadsPath';             fex_col: 'Downloads Path';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_HomePage';                  fex_col: 'Safari Home Page';     read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_33: TSQL_Table_array = ( // Safari - Recent Web Searches
    (sql_col: 'DNT_SearchString';              fex_col: 'Search String';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Date';                      fex_col: 'Search Date';          read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_34: TSQL_Table_array = ( // Timezone - MAC
    (sql_col: 'DNT_TimeZoneName';              fex_col: 'Time Zone Name';       read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_Name';                      fex_col: 'City Name';            read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_CountryCode';               fex_col: 'Country Code';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_35: TSQL_Table_array = ( // Timezone Local - MAC
    (sql_col: 'DNT_TimeZoneLocal';             fex_col: 'Time Zone Local';      read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_36: TSQL_Table_array = ( // User Accounts Deleted - MAC
    (sql_col: 'DNT_date';                          fex_col: 'Date';             read_as: ftString;  convert_as: '';   col_type: ftDateTime;     show: True),
    (sql_col: 'DNT_dsAttrTypeStandard:RealName';   fex_col: 'RealName';         read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_dsAttrTypeStandard:UniqueID';   fex_col: 'UniqueID';         read_as: ftInteger; convert_as: '';   col_type: ftInteger;      show: True),
    (sql_col: 'DNT_name';                          fex_col: 'User Name';        read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

  Array_Items_37: TSQL_Table_array = ( // Wifi - MAC
    (sql_col: 'DNT_SSID_STR';                  fex_col: 'SSID_STR';             read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_BSSID';                     fex_col: 'BSSID';                read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_WEP';                       fex_col: 'WEP';                  read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ADDED_AT';                  fex_col: 'Added At';             read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ADDED_BY';                  fex_col: 'Added By';             read_as: ftString;  convert_as: '';   col_type: ftString;       show: True),
    (sql_col: 'DNT_ENABLED';                   fex_col: 'Enabled';              read_as: ftString;  convert_as: '';   col_type: ftString;       show: True));

var
  Arr_ValidatedFiles_TList:       array[1..NUMBEROFSEARCHITEMS] of TList;
  ArtifactConnect_ProgramFolder:  array[1..NUMBEROFSEARCHITEMS] of TArtifactConnectEntry;
  FileItems:                      array[1..NUMBEROFSEARCHITEMS] of PSQL_FileSearch;

  anEntry:                        TEntry;
  ArtifactConnect_CategoryFolder: TArtifactEntry1;
  ArtifactsDataStore:             TDataStore;
  col_source_created:             TDataStoreField;
  col_source_file:                TDataStoreField;
  //col_source_location:          TDataStoreField;
  col_source_modified:            TDataStoreField;
  col_source_path:                TDataStoreField;
  current_str:                    string;
  Display_str:                    string;
  FileSystemDataStore:            TDataStore;
  gtick_doprocess_i64:            uint64;
  gtick_doprocess_str:            string;
  gtick_foundlist_i64:            uint64;
  gtick_foundlist_str:            string;
  mb_display_str:                 string;
  n, r:                           integer;
  param:                          string;
  Parameter_Num_StringList:       TStringList;
  previous_str:                   string;
  process_all_bl:                 boolean;
  process_proceed_bl:             boolean;
  Program_Folder_int:             integer;
  progress_program_str:           string;
  Ref_Num:                        integer;
  regex_search_str:               string;
  s:                              integer;
  temp_int:                       integer;
  temp_process_counter:           integer;
  test_param_int:                 integer;

function ColumnValueByNameAsDateTime(Statement: TSQLite3Statement; const colConf: TSQL_Table): TDateTime;
function FileSubSignatureMatch(anEntry: TEntry): boolean;
function GetFullName(Item: PSQL_FileSearch): string;
function HaveIBeenProcessed(SigMatchEntry: TEntry; const a_fldr: string; const b_fldr: string): boolean;
function KeepItems(anEntry: TEntry): boolean;
function LengthArrayTABLE(anArray: TSQL_Table_array): integer;
function RPad(const AString: string; AChars: integer): string;
function SetUpColumnforFolder(aReferenceNumber: integer; anArtifactFolder: TArtifactConnectEntry; out col_DF: TDataStoreFieldArray; ColCount: integer; aItems: TSQL_Table_array): boolean;
function TestForDoProcess(ARefNum: integer): boolean;
function TotalValidatedFileCountInTLists: integer;
procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
procedure DoProcess(anArtifactFolder: TArtifactConnectEntry; Reference_Number: integer; aItems: TSQL_Table_array);
procedure LoadFileItems;

{$IF DEFINED (ISFEXGUI)}

type
  TScriptForm = class(TObject)
  private
    frmMain: TGUIForm;
    FMemo: TGUIMemoBox;
    pnlBottom: TGUIPanel;
    btnOK: TGUIButton;
    btnCancel: TGUIButton;
  public
    ModalResult: boolean;
    constructor Create;
    function ShowModal: boolean;
    procedure OKClick(Sender: TGUIControl);
    procedure CancelClick(Sender: TGUIControl);
    procedure SetText(const Value: string);
    procedure SetCaption(const Value: string);
  end;
{$IFEND}

implementation

{$IF DEFINED (ISFEXGUI)}

constructor TScriptForm.Create;
begin
  inherited Create;
  frmMain := NewForm(nil, SCRIPT_NAME);
  frmMain.Size(500, 480);
  pnlBottom := NewPanel(frmMain, esNone);
  pnlBottom.Size(frmMain.Width, 40);
  pnlBottom.Align(caBottom);
  btnOK := NewButton(pnlBottom, 'OK');
  btnOK.Position(pnlBottom.Width - 170, 4);
  btnOK.Size(75, 25);
  btnOK.Anchor(False, True, True, True);
  btnOK.DefaultBtn := True;
  btnOK.OnClick := OKClick;
  btnCancel := NewButton(pnlBottom, 'Cancel');
  btnCancel.Position(pnlBottom.Width - 88, 4);
  btnCancel.Size(75, 25);
  btnCancel.Anchor(False, True, True, True);
  btnCancel.CancelBtn := True;
  btnCancel.OnClick := CancelClick;
  FMemo := NewMemoBox(frmMain, [eoReadOnly]); // eoNoHScroll, eoNoVScroll
  FMemo.Color := clWhite;
  FMemo.Align(caClient);
  FMemo.FontName('Courier New');
  frmMain.CenterOnParent;
  frmMain.Invalidate;
end;

procedure TScriptForm.OKClick(Sender: TGUIControl);
begin
  // Set variables for use in the main proc. Must do this before closing the main form.
  ModalResult := False;
  ModalResult := True;
  frmMain.Close;
end;

procedure TScriptForm.CancelClick(Sender: TGUIControl);
begin
  ModalResult := False;
  Progress.DisplayMessageNow := CANCELED_BY_USER;
  frmMain.Close;
end;

function TScriptForm.ShowModal: boolean;
begin
  Execute(frmMain);
  Result := ModalResult;
end;

procedure TScriptForm.SetText(const Value: string);
begin
  FMemo.Text := Value;
end;

procedure TScriptForm.SetCaption(const Value: string);
begin
  frmMain.Text := Value;
end;
{$IFEND}

procedure LoadFileItems;
const
  lFileItems: array [1 .. NUMBEROFSEARCHITEMS] of TSQL_FileSearch = (

    ( // ~1~ AddressBookMe - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_ADDRESSBOOKME'; fi_Name_Program: 'AddressBookMe'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 954; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'AddressBookMe\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~2~ Attached iDevices - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_ATTACHEDIDEVICES'; fi_Name_Program: 'Attached iDevices'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_MOBILE; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.iPod\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~3~ Bluetooth - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_BLUETOOTH'; fi_Name_Program: 'Bluetooth'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1104; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\Library\\Preferences\\com\.apple\.bluetooth\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'DeviceCache'), // noslz

    ( // ~4~ DHCP - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_MAC_DHCP'; fi_Name_Program: 'DHCP'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1061; fi_Icon_OS: ICON_APPLE; fi_Regex_Search: '^en\d-\d,.*';
    fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~5~ Dock Preferences - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_DOCK'; fi_Name_Program: 'Dock Items'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1107; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\Library\\Preferences\\com\.apple\.dock\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~6~ iCloud Preferences - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_ICLOUD'; fi_Name_Program: 'iCloud Preferences'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1106; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\Library\\Preferences\\MobileMeAccounts\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~7~ iMessage Accounts - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_IMESSAGE'; fi_Name_Program: 'iMessage Accounts'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1109; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.imservice\.iMessage\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~8~ Installation Time - MAC ("Empty file. Its last modification time represent the date/time the OS was installed")
    fi_Process_ID: 'DNT_INSTALLATIONDATE'; fi_Name_Program: 'Installation Date'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_APPLE; fi_Icon_OS: ICON_APPLE; fi_Regex_Search: '\.AppleSetupDone';
    fi_Reference_Info: 'https://docs.google.com/spreadsheets/d/1X2Hu0NE2ptdRj023OVWIGp5dqZOw-CfxHLOW_GNGpX8/edit#gid=4'),

    ( // ~9~ Installed Printers - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_INSTALLEDPRINTERS'; fi_Name_Program: 'Installed Printers'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 728; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\Library\\Printers\\InstalledPrinters\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~10~ Last Sleep - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_LASTSLEEP'; fi_Name_Program: 'Last Sleep'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1108;
    fi_Regex_Search: '\\Library\\Preferences\\SystemConfiguration\\com\.apple\.PowerManagement\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~11~ Login Items - MAC (Plists listing applications that automatically start when the user is logged in)
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_LOGINITEMS'; fi_Name_Program: 'Login Items'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 954; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.loginitems\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'SessionItems'), // noslz

    ( // ~12~ Login Window - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_LOGINWINDOW'; fi_Name_Program: 'Login Window'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 954; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'Library\\Preferences\\com.apple\.loginwindow\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~13~ Mail BackupTOC - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_MAIL_BACKUPTOC'; fi_Name_Program: 'Mail BackupTOC'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 369; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'BackupTOC\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~14~ Mail Folder - MAC)
    fi_Process_ID: 'DNT_MAILFOLDER'; fi_Name_Program: 'Mail Folders'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_EMAIL; fi_Icon_OS: ICON_APPLE; fi_Regex_Search: '^(IMAP|POP)-[A-Za-z0-9._%+-]+@'),

    ( // ~15~ Networks Known - MAC)
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_KNOWNNETWORKS'; fi_Name_Program: 'Networks Known'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 215; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.airport\.preferences\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~16~ Networks Recent - MAC)
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_RECENTNETWORKS'; fi_Name_Program: 'Networks Recent'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 215; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.airport\.preferences\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~17~ OSX Update - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_OSXUPDATE'; fi_Name_Program: 'OSX Update'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_APPLE; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\Library\\Preferences\\com\.apple\.SoftwareUpdate\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~18~ Preferences - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_MAC_PREFERENCES'; fi_Name_Program: 'Preferences'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1061; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '^preferences\.plist$'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~19~ Printers CUPS - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_PRINTERS_CUPS'; fi_Name_Program: 'Printers CUPS'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 728; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '^org\.cups\.printers\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~20~ Printers CUPS Control - MAC
    fi_Process_As: PROCESS_AS_CARVE; fi_Process_ID: 'DNT_PRINTERS_CUPS_CONTROL'; fi_Name_Program: 'Printers CUPS Control'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 728; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '^c\d\d\d\d\d'),

    ( // ~21~ Recent Items (Applications) - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_RECENTITEMSAPPLICATIONS'; fi_Name_Program: 'Recent Items (Applications)'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 38; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.recentitems\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'RecentApplications'), // noslz

    ( // ~22~ Recent Items (Documents) - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_RECENTITEMSDOCUMENTS'; fi_Name_Program: 'Recent Items (Documents)'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 38; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.recentitems\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'RecentDocuments'), // noslz

    ( // ~23~ Recent Items (Hosts) - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_RECENTITEMSHOSTS'; fi_Name_Program: 'Recent Items (Hosts)'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 38; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.recentitems\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'Hosts'), // noslz

    ( // ~24~ Recent iWork Numbers - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_RECENTIWORKNUMBERS'; fi_Name_Program: 'Recent iWork Numbers'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1138; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.iWork\.Numbers\.LSSharedFileList\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'CustomListItems'), // noslz

    ( // ~25~ Recent iWork Pages - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_RECENTIWORKPAGES'; fi_Name_Program: 'Recent iWork Pages'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1137; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.iWork\.Pages\.LSSharedFileList\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'; fi_NodeByName: 'CustomListItems'), // noslz

    ( // ~26~ Recent PhotoBooth - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_PHOTOBOOTHRECENTS'; fi_Name_Program: 'Recent Photo Booth'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1102; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'Pictures\\Photo Booth Library\\Recents.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~27~ Recent Preview - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_PREVIEWRECENTITEMS'; fi_Name_Program: 'Recent Preview'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 37; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.Preview\.LSSharedFileList\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~28~ Recent QuickTime - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_QUICKTIMERECENTITEMS'; fi_Name_Program: 'Recent QuickTime'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_QUICKTIME; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.QuickTimePlayerX\.LSSharedFileList\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~29~ TextEdit Recent Items - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_TEXTEDITRECENTITEMS'; fi_Name_Program: 'Recent TextEdit'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 36; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.TextEdit\.LSSharedFileList\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~30~ VideoLan (VLC) - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_VIDEOLANRECENTITEMS'; fi_Name_Program: 'Recent VideoLan'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_VLC; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'org\.videolan\.vlc\.LSSharedFileList\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~31~ System Version - MAC
    fi_Process_As: PROCESS_AS_XML; fi_Process_ID: 'DNT_SYSTEMVERSION'; fi_Name_Program: 'System Version'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_APPLE; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\System\\Library\\CoreServices\\SystemVersion\.plist'; fi_Signature_Parent: 'XML'; fi_RootNodeName: 'XML'),

    ( // ~32~ Safari Preferences - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_SAFARIPREFERENCES'; fi_Name_Program: 'Safari Preferences'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1007; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.Safari\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~33~ Safari Recent Web Searches - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_RECENTSAFARIWEBSEARCHES'; fi_Name_Program: 'Safari Recent Searches'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 1007; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.Safari\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~34~ TimeZone - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_TIMEZONE'; fi_Name_Program: 'TimeZone'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 979; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: '\\Library\\Preferences\\\.GlobalPreferences\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~35~ TimeZone Local (etc\localtime) - MAC
    fi_Process_ID: 'DNT_LOCALTIME'; fi_Name_Program: 'TimeZone Local'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 979; fi_Icon_OS: ICON_APPLE; fi_Regex_Search: '\\etc\\localtime$';
    fi_Signature_Parent: 'Text'),

    ( // ~36~ User Accounts Deleted - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_USER_ACCOUNTS_DELETED'; fi_Name_Program: 'User Accounts Deleted'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: 957; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com\.apple\.preferences\.accounts\.plist'; fi_Signature_Parent: 'PList (Binary)'; fi_RootNodeName: 'PList (Binary)'),

    ( // ~37~ Wifi - MAC
    fi_Process_As: PROCESS_AS_PLIST; fi_Process_ID: 'DNT_MAC_WIFI'; fi_Name_Program: 'Wifi'; fi_Name_Program_Type: 'MacOS'; fi_Icon_Category: ICON_APPLE; fi_Icon_Program: ICON_WIFI; fi_Icon_OS: ICON_APPLE;
    fi_Regex_Search: 'com.apple\.wifi\.WiFiAgent\.plist'; fi_Signature_Parent: 'Plist (Binary)'; fi_RootNodeName: 'PList (Binary)'));

var
  iIdx: integer;
begin
  for iIdx := Low(lFileItems) to High(lFileItems) do
  begin
    FileItems[iIdx] := @lFileItems[iIdx];
    if not Progress.isRunning then
      break;
  end;
end;

// ~~~~

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

// ~~~~

procedure Add40CharFiles(UniqueList: TUniqueListOfEntries);
var
  anEntry: TEntry;
  FileSystemDS: TDataStore;
begin
  FileSystemDS := GetDataStore(DATASTORE_FILESYSTEM);
  if assigned(UniqueList) and assigned(FileSystemDS) then
  begin
    anEntry := FileSystemDS.First;
    while assigned(anEntry) and Progress.isRunning do
    begin
      begin
        if RegexMatch(anEntry.EntryName, '^[0-9a-fA-F]{40}', False) and (anEntry.EntryNameExt = '') then // noslz iTunes Backup files
        begin
          UniqueList.Add(anEntry);
        end;
      end;
      anEntry := FileSystemDS.Next;
    end;
    FreeAndNil(FileSystemDS);
  end;
end;

function ColumnValueByNameAsDateTime(Statement: TSQLite3Statement; const colConf: TSQL_Table): TDateTime;
var
  iCol: integer;
begin
  Result := 0;
  iCol := ColumnByName(Statement, copy(colConf.sql_col, 5, Length(colConf.sql_col)));
  if (iCol > -1) then
  begin
    if colConf.read_as = ftLargeInt then
      Result := IntToDateTime(Statement.Columnint64(iCol), colConf.convert_as)
    else if colConf.read_as = ftFloat then
      Result := GHFloatToDateTime(Statement.Columnint64(iCol), colConf.convert_as);
  end;
end;

procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
var
  DeterminedFileDriverInfo: TFileTypeInformation;
  MatchSignature_str: string;
  NowProceed_bl: boolean;
  i: integer;
  File_Added_bl: boolean;
  Item: PSQL_FileSearch;
  reason_str: string;
  Reason_StringList: TStringList;
  trunc_EntryName_str: string;

begin
  File_Added_bl := False;
  if anEntry.isSystem and ((POS('$I30', anEntry.EntryName) > 0) or (POS('$90', anEntry.EntryName) > 0)) then
  begin
    NowProceed_bl := False;
    Exit;
  end;

  DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
  reason_str := '';
  trunc_EntryName_str := copy(anEntry.EntryName, 1, 25);
  Reason_StringList := TStringList.Create;
  try
    try
      for i := 1 to NUMBEROFSEARCHITEMS do
      begin
        if not Progress.isRunning then
          break;
        NowProceed_bl := False;
        reason_str := '';
        Item := FileItems[i];

        // -------------------------------------------------------------------------------
        // Special validation (these files are still sent here via the Regex match)
        // -------------------------------------------------------------------------------
        // Proceed if SubDriver has been identified
        if (not NowProceed_bl) then
        begin
          if Item^.fi_Signature_Sub <> '' then
          begin
            if RegexMatch(RemoveSpecialChars(DeterminedFileDriverInfo.ShortDisplayName), RemoveSpecialChars(Item^.fi_Signature_Sub), False) then
            begin
              NowProceed_bl := True;
              reason_str := 'ShortDisplayName = Required SubSig:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ' = ' + Item^.fi_Signature_Sub + ')';
              Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(A)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
            end;
          end;
        end;

        // Set the MatchSignature to the parent
        if (not NowProceed_bl) then
        begin
          MatchSignature_str := '';
          if Item^.fi_Signature_Sub = '' then
            MatchSignature_str := UpperCase(Item^.fi_Signature_Parent);
          // Proceed if SubDriver is blank, but File/Path Name and Parent Signature match
          if ((RegexMatch(anEntry.EntryName, Item^.fi_Regex_Search, False)) or (RegexMatch(anEntry.FullPathName, Item^.fi_Regex_Search, False))) and
            ((UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = UpperCase(MatchSignature_str)) or (RegexMatch(DeterminedFileDriverInfo.ShortDisplayName, MatchSignature_str, False))) then
          begin
            NowProceed_bl := True;
            reason_str := 'ShortDisplay matches Parent sig:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ' = ' + MatchSignature_str + ')';
            Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(B)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
          end;
        end;

        // Proceed if EntryName is unknown, but iTunes Domain, Name and Sig match
        if (not NowProceed_bl) then
        begin
          if RegexMatch(biTunes_Domain_str, Item^.fi_Regex_Itunes_Backup_Domain, False) and RegexMatch(biTunes_Name_str, Item^.fi_Regex_Itunes_Backup_Name, False) and
            (UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = UpperCase(MatchSignature_str)) then
          begin
            NowProceed_bl := True;
            reason_str := 'Proceed on Sig and iTunes Domain\Name:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ' = ' + MatchSignature_str + ')';
            Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(C)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
          end;
        end;

        if NowProceed_bl then
        begin
          Arr_ValidatedFiles_TList[i].Add(anEntry);
          File_Added_bl := True;
          if USE_FLAGS_BL then
            anEntry.Flags := anEntry.Flags + [Flag5]; // Green Flag
        end;
      end;

      if NOT(File_Added_bl) then
        Reason_StringList.Add(format(GFORMAT_STR, ['', 'Ignored', '', IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]));

    finally
      for i := 0 to Reason_StringList.Count - 1 do
        Progress.Log(Reason_StringList[i]);
    end;

  finally
    Reason_StringList.free;
  end;
end;

function FileSubSignatureMatch(anEntry: TEntry): boolean;
var
  aName: string;
  i: integer;
  param_num_int: integer;
  aDeterminedFileDriverInfo: TFileTypeInformation;
  Item: PSQL_FileSearch;
begin
  Result := False;
  aName := anEntry.EntryName;
  if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
  begin
    for i := 1 to NUMBEROFSEARCHITEMS do
    begin
      if not Progress.isRunning then
        break;
      Item := FileItems[i];
      if Item^.fi_Signature_Sub <> '' then
      begin
        aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
        if RegexMatch(RemoveSpecialChars(aDeterminedFileDriverInfo.ShortDisplayName), RemoveSpecialChars(Item^.fi_Signature_Sub), False) then // 20-FEB-19 Changed to Regex for multiple sigs
        begin
          if BL_PROCEED_LOGGING then
            Progress.Log(RPad('Proceed' + HYPHEN + 'Identified by SubSig:', RPAD_VALUE) + anEntry.EntryName + SPACE + 'Bates:' + IntToStr(anEntry.ID));
          Result := True;
          break;
        end;
      end;
    end;
  end
  else
  begin
    if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) then
    begin
      for i := 0 to Parameter_Num_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        param_num_int := StrToInt(Parameter_Num_StringList[i]);
        Item := FileItems[param_num_int];
        if Item^.fi_Signature_Sub <> '' then
        begin
          aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
          if RegexMatch(RemoveSpecialChars(aDeterminedFileDriverInfo.ShortDisplayName), RemoveSpecialChars(Item^.fi_Signature_Sub), False) then // 20-FEB-19 Changed to Regex for multiple sigs
          begin
            if BL_PROCEED_LOGGING then
              Progress.Log(RPad('Proceed' + HYPHEN + 'File Sub-Signature Match:', RPAD_VALUE) + anEntry.EntryName + SPACE + 'Bates:' + IntToStr(anEntry.ID));
            Result := True;
            break;
          end;
        end;
      end
    end
  end;
end;

function GetFullName(Item: PSQL_FileSearch): string;
var
  ApplicationName: string;
  TypeName: string;
  OSName: string;
begin
  Result := '';
  ApplicationName := Item^.fi_Name_Program;
  TypeName := Item^.fi_Name_Program_Type;
  OSName := Item^.fi_Name_OS;
  if (ApplicationName <> '') then
  begin
    if (TypeName <> '') then
      Result := format('%0:s %1:s', [ApplicationName, TypeName])
    else if (ApplicationName <> '') then
      Result := ApplicationName
  end
  else
    Result := TypeName;
  if OSName <> '' then
    Result := Result + ' ' + OSName;
end;

function HaveIBeenProcessed(SigMatchEntry: TEntry; const a_fldr: string; const b_fldr: string): boolean;
begin
  Result := False;
  anEntry := ArtifactsDataStore.First;
  while assigned(anEntry) and Progress.isRunning do
  begin
    if (anEntry is TArtifactItem) then
    begin
      if SigMatchEntry = TArtifactItem(anEntry).SourceEntry then
      begin
        if UpperCase(TArtifactItem(anEntry).Parent.EntryName) = UpperCase(a_fldr) + ' ' + UpperCase(b_fldr) then
        begin
          Progress.Log(RPad('Skipped - Keep Artifacts:', RPAD_VALUE) + TArtifactItem(anEntry).FullPathName + TArtifactItem(anEntry).SourceEntry.EntryName + ' (' + IntToStr(TArtifactItem(anEntry).SourceEntry.ID) + ')');
          Result := True;
          break;
        end;
      end;
    end;
    anEntry := ArtifactsDataStore.Next;
  end;
  ArtifactsDataStore.Close;
end;

function KeepItems(anEntry: TEntry): boolean;
var
  i: integer;
begin
  Result := False;
  if (CmdLine.Params.Indexof(PROCESSALL) > -1) then // PROCESSALL
  begin
    for i := 1 to NUMBEROFSEARCHITEMS do
    begin
      if not Progress.isRunning then
        break;
      if UpperCase(anEntry.EntryName) = UpperCase(CATEGORY_NAME) then
      begin
        Progress.Log(RPad('Category has been previously processed:', RPAD_VALUE) + 'True');
        Result := True;
        break;
      end;
    end;
  end
  else if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) then // PROCESS INDIVIDUAL
  begin
    for i := 0 to Parameter_Num_StringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      Program_Folder_int := StrToInt(Parameter_Num_StringList[i]);
      if UpperCase(anEntry.EntryName) = UpperCase(GetFullName(FileItems[Program_Folder_int])) then
      begin
        Progress.Log(RPad('Has been previously processed:', RPAD_VALUE) + 'True');
        Result := True;
        break;
      end;
    end;
  end;
end;

function LengthArrayTABLE(anArray: TSQL_Table_array): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to 100 do
  begin
    if anArray[i].sql_col = '' then
      break;
    Result := i;
  end;
end;

{$IF DEFINED (ISFEXGUI)}

function MakeButton: boolean;
var
  concat_str: string;
  CreateButton_StringList: TStringList;
  Item: PSQL_FileSearch;
  n: integer;
  next_str: string;
  unit_name_str: string;
begin
  Result := False;
  LoadFileItems;
  CreateButton_StringList := TStringList.Create;
  try
    unit_name_str := StringReplace(PROGRAM_NAME, ' ', '_', [rfReplaceAll]);
    MakeButtonHeader(PROGRAM_NAME, SCRIPT_NAME, ICON_24_CHAT, CreateButton_StringList);
    concat_str := '';
    for n := 1 to NUMBEROFSEARCHITEMS do
    begin
      Item := FileItems[n];
      current_str := Item^.fi_Name_Program;
      if n <> NUMBEROFSEARCHITEMS then
        next_str := FileItems[n + 1].fi_Name_Program
      else
        next_str := '';
      if current_str <> next_str then
      begin
        concat_str := concat_str + ' ' + IntToStr(n);
        CreateButton_StringList.Add('  Button.AddDropMenu(''' + Item^.fi_Name_Program + ''', GetScriptsDir + ''Artifacts\' + SCRIPT_NAME + ''', ''' + concat_str + ''', ' + IntToStr(Item^.fi_Icon_Program) +
          ', BTNS_SHOWCAPTION or BTNS_DROPDOWN);');
        concat_str := '';
      end
      else
        concat_str := concat_str + ' ' + IntToStr(n);
    end;
    CreateButton_StringList.Add('end;');
    CreateButton_StringList.Add('end.');
  finally
    Progress.Log(CreateButton_StringList.Text);
    if CreateButton_StringList.Count > 0 then
    begin
      CreateButton_StringList.SaveToFile(GetScriptsDir + '\Artifacts\Common\Toolbar\Button_Artifacts_' + unit_name_str + '.pas');
      Result := True;
    end;
    CreateButton_StringList.free;
  end;
end;
{$IFEND}

procedure PostProcess_Remove_Zero;
var
  ArtRem_DataStore: TDataStore;
  caseEntry: TEntry;
  i: integer;
  name_trunc_str: string;
  pp_TList: TList;
  ppEntry: TEntry;
  Direct_Children_TList: TList;
  pp_RemoveBlank_TList: TList;
begin
  Progress.Log('Post Process (remove 0 counts)' + RUNNING);
  ArtRem_DataStore := GetDataStore(DATASTORE_ARTIFACTS);
  if ArtRem_DataStore = nil then
    Exit;
  if assigned(ArtRem_DataStore) and (ArtRem_DataStore.Count > 0) then
    try
      caseEntry := ArtRem_DataStore.First;
      pp_TList := TList.Create;
      pp_RemoveBlank_TList := TList.Create;
      try
        pp_TList := ArtRem_DataStore.GetEntireList;
        for i := 0 to ArtRem_DataStore.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          ppEntry := TEntry(pp_TList[i]);
          if ppEntry.isDirectory then
          begin
            Direct_Children_TList := TList.Create;
            try
              Direct_Children_TList := ArtRem_DataStore.Children(ppEntry);
              if (not ppEntry.isDevice) and (ppEntry <> caseEntry) and (Direct_Children_TList.Count = 0) then
              begin
                if ppEntry.Parent.EntryName = CATEGORY_NAME then
                begin
                  name_trunc_str := copy(ppEntry.EntryName, 1, 50);
                  Progress.Log(RPad(HYPHEN + name_trunc_str, RPAD_VALUE) + IntToStr(Direct_Children_TList.Count));
                  pp_RemoveBlank_TList.Add(ppEntry);
                end;
              end;
            finally
              Direct_Children_TList.free;
            end;
          end;
        end;

        if assigned(pp_RemoveBlank_TList) and (pp_RemoveBlank_TList.Count > 0) then
          try
            Sleep(100);
            Progress.Log('Removing Blank: ' + IntToStr(pp_RemoveBlank_TList.Count));
            ArtifactsDataStore.Remove(pp_RemoveBlank_TList);
          except
            Progress.Log('Could not remove blank item.');
          end;

      finally
        pp_TList.free;
        pp_RemoveBlank_TList.free;
      end;
    finally
      ArtRem_DataStore.free;
    end;
end;

function SetUpColumnforFolder(aReferenceNumber: integer; anArtifactFolder: TArtifactConnectEntry; out col_DF: TDataStoreFieldArray; ColCount: integer; aItems: TSQL_Table_array): boolean;
var
  NumberOfColumns: integer;
  Field: TDataStoreField;
  i: integer;
  column_label: string;
  Item: PSQL_FileSearch;
begin
  Result := True;
  Item := FileItems[aReferenceNumber];
  NumberOfColumns := ColCount;
  setlength(col_DF, ColCount + 1);

  if assigned(anArtifactFolder) then
  begin
    for i := 1 to NumberOfColumns do
    begin
      try
        if not Progress.isRunning then
          Exit;
        Field := ArtifactsDataStore.DataFields.FieldByName(aItems[i].fex_col);
        if assigned(Field) and (Field.FieldType <> aItems[i].col_type) then
        begin
          MessageUser(SCRIPT_NAME + DCR + 'WARNING: New column: ' + DCR + aItems[i].fex_col + DCR + 'already exists as a different type. Creation skipped.');
          Result := False;
        end
        else
        begin
          column_label := '';
          col_DF[i] := ArtifactsDataStore.DataFields.Add(aItems[i].fex_col + column_label, aItems[i].col_type);
          if col_DF[i] = nil then
          begin
            MessageUser(SCRIPT_NAME + DCR + 'Cannot use a fixed field. Please contact support@getdata.com quoting the following error: ' + DCR + SCRIPT_NAME + SPACE + IntToStr(aReferenceNumber) + SPACE + aItems[i].fex_col);
            Result := False;
          end;
        end;
      except
        MessageUser(ATRY_EXCEPT_STR + 'Failed to create column');
      end;
    end;

    // Set the Source Columns --------------------------------------------------
    col_source_file := ArtifactsDataStore.DataFields.GetFieldByName('Source_Name');
    col_source_path := ArtifactsDataStore.DataFields.GetFieldByName('Source_Path');
    col_source_created := ArtifactsDataStore.DataFields.GetFieldByName('Source_Created');
    col_source_modified := ArtifactsDataStore.DataFields.GetFieldByName('Source_Modified');

    // Columns -----------------------------------------------------------------
    if Result then
    begin
      // Enables the change of column headers when switching folders - This is the order of displayed columns
      for i := 1 to NumberOfColumns do
      begin
        if not Progress.isRunning then
          break;
        if aItems[i].Show then
        begin
          // Progress.Log('Add Field Name: ' + col_DF[i].FieldName);
          anArtifactFolder.AddField(col_DF[i]);
        end;
      end;

      if (Item^.fi_Process_As = 'POSTPROCESS') then
        anArtifactFolder.AddField(col_source_path)
      else
      begin
        anArtifactFolder.AddField(col_source_file);
        anArtifactFolder.AddField(col_source_path);
        anArtifactFolder.AddField(col_source_created);
        anArtifactFolder.AddField(col_source_modified);
      end;
    end;
  end;
end;

function TestForDoProcess(ARefNum: integer): boolean;
var
  Item: PSQL_FileSearch;
begin
  Result := False;
  Item := FileItems[ARefNum];
  if Item^.fi_Process_As = 'POSTPROCESS' then
  begin
    Result := True;
    Exit;
  end;
  if (ARefNum <= NUMBEROFSEARCHITEMS) and Progress.isRunning then
  begin
    if (CmdLine.Params.Indexof(IntToStr(ARefNum)) > -1) or (CmdLine.Params.Indexof(PROCESSALL) > -1) then
    begin
      Progress.Log(RPad('Process List #' + IntToStr(ARefNum) + SPACE + '(' + IntToStr(Arr_ValidatedFiles_TList[ARefNum].Count) + '):', RPAD_VALUE) + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type + RUNNING);
      Result := True;
    end;
  end
{$IF DEFINED (ISFEXGUI)}
  else
  begin
    if not Progress.isRunning then
      Exit;
    Progress.Log('Error: RefNum > NUMBEROFSEARCHITEMS'); // noslz
  end;
{$ELSE}
    ;
{$IFEND}
end;

function TotalValidatedFileCountInTLists: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to NUMBEROFSEARCHITEMS do
  begin
    if not Progress.isRunning then
      break;
    Result := Result + Arr_ValidatedFiles_TList[i].Count;
  end;
end;

procedure DoProcess(anArtifactFolder: TArtifactConnectEntry; Reference_Number: integer; aItems: TSQL_Table_array);
var
  aArtifactEntry: TEntry;
  aArtifactEntryParent: TEntry;
  ADDList: TList;
  aPropertyTree: TPropertyParent;
  aRootProperty: TPropertyNode;
  bmComment: string;
  ByteArray: array [1 .. 64] of byte;
  ByteCount: integer;
  col_DF: TDataStoreFieldArray;
  ColCount: integer;
  Display_Name_str: string;
  DNT_sql_col: string;
  i, g, w, x, y, z: integer;
  installation_time_str: string;
  Item: PSQL_FileSearch;
  newEntryReader: TEntryReader;
  Node1: TPropertyNode;
  Node1Next: TPropertyNode;
  Node2: TPropertyNode;
  Node3: TPropertyNode;
  Node4: TPropertyNode;
  Node5: TPropertyNode;
  NodeList1: TObjectList;
  NodeList2: TObjectList;
  NodeList3: TObjectList;
  NodeList4: TObjectList;
  NumberOfNodes: integer;
  printchars: string;
  PropertyList: TObjectList;
  PropertyList2: TObjectList;
  records_read_int: integer;
  TestNode: TPropertyNode;
  TotalFiles: int64;
  variant_Array: array of variant;

  procedure NullTheArray;
  var
    n: integer;
  begin
    for n := 1 to ColCount do
      variant_Array[n] := null;
  end;

  function CountNodes(aNode: TPropertyNode): integer;
  var
    aNodeList: TObjectList;
  begin
    Result := 0;
    aNodeList := aNode.PropChildList;
    if assigned(aNodeList) then
      Result := aNodeList.Count
  end;

  procedure BookMark(AGroup_Folder, AComment: string);
  var
    bCreate: boolean;
    bmParent: TEntry;
    DeviceEntry: TEntry;
  begin
    if (CmdLine.Params.Indexof(TRIAGE) > -1) then
      if (assigned(aArtifactEntry)) and (Progress.isRunning) then
      begin
        DeviceEntry := GetDeviceEntry(aArtifactEntry);
        bCreate := True;
        bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + DeviceEntry.EntryName + '\' + BMF_FILESYSTEM_MAC + '\' + AGroup_Folder { + '\' + aArtifactEntry.EntryName } , bCreate);
        // Overwrite Comment
        UpdateBookmark(bmParent, '' { AComment } ); // Comment for the folder
        if not(IsItemInBookmark(bmParent, aArtifactEntry)) then
          AddItemsToBookmark(bmParent, DATASTORE_FILESYSTEM, aArtifactEntry, AComment); // Comment for the file
      end;
  end;

// procedure in procedure - Concatenate Comment
  procedure Concat_bmComment(s: integer; incLabel_bl: boolean);
  var
    rpad_commentvalue: integer;
  begin
    rpad_commentvalue := 30;
    if (CmdLine.Params.Indexof(TRIAGE) > -1) then
      if bmComment = '' then
      begin
        if incLabel_bl then
          bmComment := RPad(aItems[s].fex_col + ':', rpad_commentvalue) + variant_Array[s]
        else
          bmComment := variant_Array[s];
      end
      else if incLabel_bl then
        bmComment := bmComment + #13#10 + RPad(aItems[s].fex_col + ':', rpad_commentvalue) + variant_Array[s]
      else
        bmComment := bmComment + #13#10 + variant_Array[s];
  end;

  procedure AddToModule;
  var
    NEntry: TArtifactItem;
    h: integer;
    IsAllEmpty: boolean;
    IsAllNull: boolean;
    IsAllBlank: boolean;
  begin
    // Do not add when it is a Triage
    if (CmdLine.Params.Indexof(TRIAGE) = -1) then
    begin
      // Do not add when row is all blank - Need protection here in case the array hold a value other than a string.
      IsAllBlank := True;
      for g := 1 to ColCount do
      begin
        if not Progress.isRunning then
          break;
        if (col_DF[g].FieldType) = ftString then
        begin
          if (variant_Array[g] <> '') then
            IsAllBlank := False;
        end
        else
          IsAllBlank := False;
      end;

      // Do not add when row is all null
      IsAllEmpty := True;
      IsAllNull := True;

      for g := 1 to ColCount do
      begin
        if not VarIsEmpty(variant_Array[g]) then
        begin
          IsAllEmpty := False;
          break;
        end;
      end;

      for g := 1 to ColCount do
      begin
        if not VarIsNull(variant_Array[g]) then
        begin
          IsAllNull := False;
          break;
        end;
      end;

      if (not IsAllNull) and (not IsAllEmpty) then
      begin
        NEntry := TArtifactItem.Create;
        NEntry.SourceEntry := aArtifactEntry;
        NEntry.Parent := anArtifactFolder;
        NEntry.PhysicalSize := 0;
        NEntry.LogicalSize := 0;
        // Populate the columns
        for g := 1 to ColCount do
          if (not VarIsNull(variant_Array[g])) and (not VarIsEmpty(variant_Array[g])) then
          begin
            // Date Time
            if (col_DF[g].FieldType = ftDateTime) then
              col_DF[g].AsDateTime[NEntry] := variant_Array[g];
            // Integer
            if (col_DF[g].FieldType = ftInteger) then
              col_DF[g].AsInteger[NEntry] := variant_Array[g];
            // String
            if (col_DF[g].FieldType = ftString) and VarIsStr(variant_Array[g]) and (variant_Array[g] <> '') then
              col_DF[g].AsString[NEntry] := variant_Array[g];
            // Bytes
            if (col_DF[g].FieldType = ftBytes) then
              col_DF[g].AsBytes[NEntry] := variantToArrayBytes(variant_Array[g]);
          end;
        ADDList.Add(NEntry);
        Sleep(10);
      end;
      // Null the Array
      for h := 1 to ColCount do
        variant_Array[h] := null;
    end;
  end;

  procedure nodefrog(aNode: TPropertyNode; anint: integer);
  var
    i: integer;
    theNodeList: TObjectList;
    pad_str: string;
    bl_found: boolean;
    bl_logging: boolean;
  begin
    bl_logging := False;
    pad_str := (StringOfChar(' ', anint * 3));
    if assigned(aNode) and Progress.isRunning then
    begin
      theNodeList := aNode.PropChildList;
      if assigned(theNodeList) then
      begin
        if bl_logging and (aNode.PropName <> '') then
          Progress.Log(pad_str + aNode.PropName); // only print the header if the node has children
        bl_found := False;
        for i := 0 to theNodeList.Count - 1 do
        begin
          aNode := TPropertyNode(theNodeList.items[i]);
          for g := 1 to ColCount do
          begin
            DNT_sql_col := aItems[g].sql_col;
            Delete(DNT_sql_col, 1, 4);
            if UpperCase(aNode.PropName) = UpperCase(DNT_sql_col) then
            begin
              // Handle a DateTime read as string with type as Date
              if (aItems[g].col_type = ftDateTime) and (aItems[g].convert_as = '') then
              begin
                try
                  variant_Array[g] := vartoDateTime(aNode.PropDisplayValue);
                  bl_found := True;
                except
                  Progress.Log(ATRY_EXCEPT_STR + 'An exception occurred when converting: ' + aNode.PropDisplayValue);
                end;
              end
              else
              begin
                variant_Array[g] := aNode.PropDisplayValue;
                if bl_logging then
                begin
                  if (aNode.PropName <> '') and (aNode.PropDisplayValue <> '') then
                  begin
                    Progress.Log(RPad(pad_str + aNode.PropName, RPAD_VALUE) + aNode.PropDisplayValue);
                  end;
                end;
                bl_found := True;
              end;
            end;
          end;
          nodefrog(aNode, anint + 1);
        end;
        if bl_found then
        begin
          AddToModule;
          if bl_logging then
            Progress.Log(StringOfChar('-', CHAR_LENGTH));
        end;
      end;
    end;
  end;

  procedure nodefrog2(aNode: TPropertyNode; anint: integer; aStringList: TStringList);
  var
    aNodeNext: TPropertyNode;
    i: integer;
    theNodeList: TObjectList;
    pad_str: string;

  begin
    pad_str := (StringOfChar('-', anint * 5));
    if assigned(aNode) and Progress.isRunning then
    begin
      theNodeList := aNode.PropChildList;
      if assigned(theNodeList) then
      begin
        for i := 0 to theNodeList.Count - 1 do
        begin
          aNode := TPropertyNode(theNodeList.items[i]);

          // --------------------------------------------------------------------
          // Loop through the columns and populate the array
          // --------------------------------------------------------------------
          for g := 1 to ColCount do
          begin
            if not Progress.isRunning then
              break;
            DNT_sql_col := aItems[g].sql_col;
            Delete(DNT_sql_col, 1, 4);
            if UpperCase(aNode.PropValue) = UpperCase(DNT_sql_col) then
            begin
              if i < theNodeList.Count - 1 then
              begin
                aNodeNext := TPropertyNode(theNodeList.items[i + 1]);
                if assigned(aNodeNext) and (aNodeNext <> nil) then // noslz
                begin
                  variant_Array[g] := aNodeNext.PropValue;
                end;
              end;
            end;
          end;
          aStringList.Add(RPad(pad_str + aNode.PropName, RPAD_VALUE) + aNode.PropDisplayValue);
          nodefrog2(aNode, anint + 1, aStringList);
        end;
      end;
    end;
  end;

  procedure known_networks(aNode: TPropertyNode; anint: integer);
  var
    i, j: integer;
    theNodeList: TObjectList;
    thedicList: TObjectList;
    adicNode: TPropertyNode;
    ghNode: TPropertyNode;
    nextnode: TPropertyNode;
    remembered_channels_bl: boolean;
  begin
    remembered_channels_bl := False;
    if assigned(aNode) and Progress.isRunning then
    begin
      theNodeList := aNode.PropChildList;
      if assigned(theNodeList) then
      begin
        Progress.Log(StringOfChar('-', CHAR_LENGTH));
        for i := 0 to theNodeList.Count - 1 do
        begin
          ghNode := TPropertyNode(theNodeList.items[i]);
          if ghNode.PropName = 'key' then // noslz
          begin
            Progress.Log(RPad(ghNode.PropName, RPAD_VALUE) + ghNode.PropDisplayValue);
            Continue;
          end;
          if ghNode.PropName = 'dict' then // noslz
          begin
            thedicList := ghNode.PropChildList;
            if assigned(thedicList) then
            begin
              for j := 0 to thedicList.Count - 1 do
              begin
                adicNode := TPropertyNode(thedicList.items[j]);
                if (j = 0) and (adicNode.PropDisplayValue = 'Remembered channels') then // noslz
                begin
                  Progress.Log(RPad(adicNode.PropName, RPAD_VALUE) + adicNode.PropDisplayValue);
                  remembered_channels_bl := True;
                end;
                if remembered_channels_bl then
                begin
                  for g := 1 to ColCount do
                  begin
                    if not Progress.isRunning then
                      break;
                    DNT_sql_col := aItems[g].sql_col;
                    Delete(DNT_sql_col, 1, 4);
                    if UpperCase(adicNode.PropValue) = UpperCase(DNT_sql_col) then
                    begin
                      if (j + 1) <= thedicList.Count then
                      begin
                        nextnode := TPropertyNode(thedicList.items[j + 1]);
                        variant_Array[g] := nextnode.PropDisplayValue;
                        Progress.Log(RPad(adicNode.PropDisplayValue, RPAD_VALUE) + nextnode.PropDisplayValue);
                      end;
                    end;
                  end;
                end;
              end;
              AddToModule;
              Progress.Log(StringOfChar('-', CHAR_LENGTH));
            end;
          end;
        end;
      end;
    end;
  end;

  procedure recent_networks(aNode: TPropertyNode; anint: integer);
  var
    i, j: integer;
    theNodeList: TObjectList;
    thedicList: TObjectList;
    adicNode: TPropertyNode;
    ghNode: TPropertyNode;
    nextnode: TPropertyNode;
  begin
    if assigned(aNode) and Progress.isRunning then
    begin
      theNodeList := aNode.PropChildList;
      if assigned(theNodeList) then
      begin
        Progress.Log(StringOfChar('-', CHAR_LENGTH));
        for i := 0 to theNodeList.Count - 1 do
        begin
          ghNode := TPropertyNode(theNodeList.items[i]);
          if ghNode.PropName = 'key' then // noslz
          begin
            Progress.Log(RPad(ghNode.PropName, RPAD_VALUE) + ghNode.PropDisplayValue);
            Continue;
          end;
          if ghNode.PropName = 'dict' then // noslz
          begin
            thedicList := ghNode.PropChildList;
            if assigned(thedicList) then
            begin
              for j := 0 to thedicList.Count - 1 do
              begin
                adicNode := TPropertyNode(thedicList.items[j]);
                if (j = 0) then
                begin
                  Progress.Log(RPad(adicNode.PropName, RPAD_VALUE) + adicNode.PropDisplayValue);
                end;
                begin
                  for g := 1 to ColCount do
                  begin
                    if not Progress.isRunning then
                      break;
                    DNT_sql_col := aItems[g].sql_col;
                    Delete(DNT_sql_col, 1, 4);
                    if UpperCase(adicNode.PropValue) = UpperCase(DNT_sql_col) then
                    begin
                      if (j + 1) <= thedicList.Count then
                      begin
                        nextnode := TPropertyNode(thedicList.items[j + 1]);
                        variant_Array[g] := nextnode.PropDisplayValue;
                        Progress.Log(RPad(adicNode.PropDisplayValue, RPAD_VALUE) + nextnode.PropDisplayValue);
                      end;
                    end;
                  end;
                end;
              end;
              AddToModule;
              Progress.Log(StringOfChar('-', CHAR_LENGTH));
            end;
          end;
        end;
      end;
    end;
  end;

// ========================================================
// AddressBookMe - MAC
// ========================================================
  procedure AddressBookMe;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_ADDRESSBOOKME') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('dict')); // noslz
      if assigned(Node1) then
      begin
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node1 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node1) and (Node1.PropName = RS_DNT_key) then
            if x + 1 <= NumberOfNodes - 1 then
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                DNT_sql_col := aItems[g].sql_col;
                Delete(DNT_sql_col, 1, 4);
                if UpperCase(Node1.PropValue) = UpperCase(DNT_sql_col) then
                begin
                  Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                  variant_Array[g] := Node1Next.PropDisplayValue;
                  Concat_bmComment(g, True);
                end;
              end;
        end;
        AddToModule;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Attached iDevices - MAC
// ========================================================
  procedure AttachediDevices;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_ATTACHEDIDEVICES') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(RS_DNT_Devices));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          // Level 2 List
          NodeList2 := Node1.PropChildList;
          if assigned(NodeList2) then
            for y := 0 to NodeList2.Count - 1 do
            begin
              Node2 := TPropertyNode(NodeList2.items[y]);
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                DNT_sql_col := aItems[g].sql_col;
                Delete(DNT_sql_col, 1, 4);
                // String
                if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
                begin
                  variant_Array[g] := Node2.PropDisplayValue;
                  Concat_bmComment(g, True);
                end;
              end;
            end;
          AddToModule;
          bmComment := bmComment + #13#10;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Bluetooth - MAC
// ========================================================
  procedure bluetooth;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_BLUETOOTH') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:' + Item^.fi_NodeByName, RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          variant_Array[1] := Node1.PropName;
          Concat_bmComment(1, True);
          PropertyList := Node1.PropChildList;
          if assigned(PropertyList) then
            for y := 0 to PropertyList.Count - 1 do
            begin
              Node2 := TPropertyNode(PropertyList.items[y]);
              if assigned(Node2) then
                if RegexMatch(Node1.PropName, '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$', False) then
                begin
                  variant_Array[1] := Node1.PropName;
                  for g := 1 to ColCount do
                  begin
                    if not Progress.isRunning then
                      break;
                    DNT_sql_col := aItems[g].sql_col;
                    Delete(DNT_sql_col, 1, 4);
                    // String
                    if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
                    begin
                      variant_Array[g] := Node2.PropDisplayValue;
                      Concat_bmComment(g, True);
                    end;
                  end;
                end { Regex };
            end;
          AddToModule;
          bmComment := bmComment + #13#10;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// DHCP - MAC
// ========================================================
  procedure DHCP;
  var
    Node_StringList: TStringList;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_MAC_DHCP') then
    begin
      Node_StringList := TStringList.Create;
      try
        bmComment := '';
        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('dict')); // noslz
        if assigned(Node1) then
        begin
          NumberOfNodes := CountNodes(Node1);
          Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
          NullTheArray;
          nodefrog2(Node1, 0, Node_StringList);
        end;
        // Progress.Log(Node_StringList.Text);
      finally
        Node_StringList.free;
      end;
    end;
    AddToModule;
  end;

// ========================================================
// Dock Items
// ========================================================
  procedure DockItems;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_DOCK') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('persistent-apps')); // noslz
      if assigned(Node1) then
      begin
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node2 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node2) and (Node2.PropName = '') then
          begin
            NullTheArray;
            NodeList2 := Node2.PropChildList;
            if assigned(NodeList2) then
              for y := 0 to NodeList2.Count - 1 do
              begin
                Node3 := TPropertyNode(NodeList2.items[y]);
                if assigned(Node3) and (Node3.PropName = 'tile-data') then
                // Get the children of title-data
                begin
                  NodeList3 := Node3.PropChildList;
                  if assigned(NodeList3) then
                  begin
                    for z := 0 to NodeList3.Count - 1 do
                    begin
                      Node4 := TPropertyNode(NodeList3.items[z]);
                      if assigned(Node4) and (Node4.PropName = 'file-label') then
                        variant_Array[1] := Node4.PropDisplayValue;
                      if assigned(Node4) and (Node4.PropName = 'file-data') then
                      begin
                        NodeList4 := Node4.PropChildList;
                        if assigned(NodeList4) then
                          for w := 0 to NodeList4.Count - 1 do
                          begin
                            Node5 := TPropertyNode(NodeList4.items[w]);
                            if assigned(Node5) and (Node5.PropName = '_CFURLString') then
                              variant_Array[2] := Node5.PropDisplayValue;
                          end;
                      end;
                    end;
                    AddToModule;
                    if bmComment <> '' then
                      BookMark(Item^.fi_Name_Program, bmComment);
                    bmComment := '';
                  end;
                end;
              end;
          end;
        end;
      end;
    end;
  end;

// ========================================================
// Installation Date - MAC
// ========================================================
  procedure InstallationDate;
  begin
    if assigned(aArtifactEntry) and (UpperCase(Item^.fi_Process_ID) = 'DNT_INSTALLATIONDATE') then
    begin
      for g := 1 to ColCount do
        variant_Array[g] := null;
      installation_time_str := DateTimeToStr(aArtifactEntry.Modified);
      variant_Array[1] := installation_time_str;
      Concat_bmComment(1, True);
      AddToModule;
      if bmComment <> '' then
        BookMark(Item^.fi_Name_Program, bmComment);
      bmComment := '';
    end;
  end;

// ========================================================
// Mail - BackupTOC - MAC
// ========================================================
  procedure MailBackupTOC;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_MAIL_BACKUPTOC') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('mailboxes')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Mail Folders - MAC
// ========================================================
  procedure MailFolders;
  begin
    if assigned(aArtifactEntry) and (UpperCase(Item^.fi_Process_ID) = 'DNT_MAILFOLDER') and aArtifactEntry.isDirectory then
    begin
      variant_Array[1] := aArtifactEntry.EntryName;
      Concat_bmComment(1, True);
      AddToModule;
      if bmComment <> '' then
        BookMark(Item^.fi_Name_Program, bmComment);
      bmComment := '';
    end;
  end;

// ========================================================
// Networks - Known Networks - MAC
// ========================================================
  procedure KnownNetworks;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_KNOWNNETWORKS') then
    begin
      bmComment := '';

      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('dict')); // noslz
      if assigned(Node1) then
      begin
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) and (NodeList1.Count > 2) then // looking for 0:key and 1:dict (which holds the records)
        begin
          NumberOfNodes := NodeList1.Count;
          TestNode := TPropertyNode(NodeList1.items[0]);
          if TestNode.PropDisplayValue = 'KnownNetworks' then // Find the display value 'KnownNetworks'
          begin
            TestNode := TPropertyNode(NodeList1.items[1]);
            if (TestNode.PropName = 'dict') then // the next node should be dict
            begin
              Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
              NullTheArray;
              known_networks(TestNode, 0);
            end;
          end;
        end
        else
          NumberOfNodes := 0;
      end;
    end;
  end;

// ========================================================
// Networks - Recent Networks - MAC
// ========================================================
  procedure RecentNetworks;
  var
    FoundNode: TPropertyNode;

    procedure findnode(aNode: TPropertyNode; anint: integer);
    var
      i: integer;
      theNodeList: TObjectList;
    begin
      if assigned(aNode) and Progress.isRunning then
      begin
        theNodeList := aNode.PropChildList;
        if assigned(theNodeList) then
        begin
          for i := 0 to theNodeList.Count - 1 do
          begin
            aNode := TPropertyNode(theNodeList.items[i]);
            if (aNode.PropName = 'key') and (aNode.PropDisplayValue = 'RecentNetworks') then // noslz
            begin
              if theNodeList.Count <= theNodeList.Count + 1 then
              begin
                aNode := TPropertyNode(theNodeList.items[i + 1]);
                if aNode.PropName = 'array' then // noslz
                begin
                  FoundNode := aNode;
                  break;
                end;
              end;
            end
            else
              findnode(aNode, anint + 1);
          end;
        end;
      end;
    end;

  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTNETWORKS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('plist')); // noslz
      if assigned(Node1) then
      begin
        FoundNode := nil;
        findnode(Node1, 0);
        if FoundNode <> nil then
          recent_networks(FoundNode, 0);
      end;
    end;
  end;

// ========================================================
// iCloud Preferences (MobileMeAccounts.plist) - MAC
// ========================================================
  procedure iCloudPreferences;
  begin

    if (UpperCase(Item^.fi_Process_ID) = 'DNT_ICLOUD') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(RS_DNT_Accounts));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          // Level 2 List
          NodeList2 := Node1.PropChildList;
          if assigned(NodeList2) then
            for y := 0 to NodeList2.Count - 1 do
            begin
              Node2 := TPropertyNode(NodeList2.items[y]);
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                DNT_sql_col := aItems[g].sql_col;
                Delete(DNT_sql_col, 1, 4);
                // String
                if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
                begin
                  variant_Array[g] := Node2.PropDisplayValue;
                  Concat_bmComment(g, True);
                end;
              end;
            end;
          AddToModule;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// iMessage Accounts - MAC
// ========================================================
  procedure iMessageAccounts;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_IMESSAGE') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(RS_DNT_Accounts));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          // Level 2 List
          NodeList2 := Node1.PropChildList;
          if assigned(NodeList2) then
            for y := 0 to NodeList2.Count - 1 do
            begin
              Node2 := TPropertyNode(NodeList2.items[y]);
              if assigned(Node2) then
                for g := 1 to ColCount do
                begin
                  if not Progress.isRunning then
                    break;
                  DNT_sql_col := aItems[g].sql_col;
                  Delete(DNT_sql_col, 1, 4);
                  if UpperCase(Node2.PropName) = UpperCase(DNT_sql_col) then
                  begin
                    variant_Array[g] := Node2.PropDisplayValue;
                    Concat_bmComment(g, True);
                  end;
                end;
            end;
        end;
      end;
      AddToModule;
      if bmComment <> '' then
        BookMark(Item^.fi_Name_Program, bmComment);
      bmComment := '';
    end;
  end;

// ========================================================
// Installed Printers - MAC
// ========================================================
  procedure InstalledPrinters;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_INSTALLEDPRINTERS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(RS_DNT_array));
      if assigned(Node1) then
      begin
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node1 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node1) and (Node1.PropName = RS_DNT_string) and (POS('MANUFACTURER', Node1.PropValue) > 0) then
          begin
            variant_Array[1] := Node1.PropValue;
            Concat_bmComment(1, False);
          end;
          AddToModule;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Last Sleep - MAC
// ========================================================
  procedure LastSleep;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_LASTSLEEP') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('plist')); // noslz
      if assigned(Node1) then
      begin
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node2 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node2) and (Node2.PropName = RS_DNT_dict) then
          begin
            // Level 2 List
            NodeList2 := Node1.PropChildList;
            if assigned(NodeList2) then
            begin
              for y := 0 to NodeList2.Count - 1 do
              begin
                if assigned(Node2) and (Node2.PropName = RS_DNT_dict) then
                begin
                  // Level 3 List
                  NodeList3 := Node2.PropChildList;
                  if assigned(NodeList3) then
                  begin
                    for z := 0 to NodeList3.Count - 1 do
                    begin
                      Node3 := TPropertyNode(NodeList3.items[z]);
                      if assigned(Node3) and (Node3.PropName = RS_DNT_dict) then
                      begin
                        NodeList4 := Node3.PropChildList;
                        if assigned(NodeList4) then
                        begin
                          for w := 0 to NodeList4.Count - 1 do
                          begin
                            Node4 := TPropertyNode(NodeList4.items[w]);
                            if assigned(Node4) and (Node4.PropName = RS_DNT_date) then
                            begin
                              variant_Array[1] := Node4.PropValue;
                              bmComment := Node4.PropValue;
                              Sleep(100);
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
          AddToModule;
          if bmComment <> '' then
            BookMark(Item^.fi_Name_Program, bmComment);
          bmComment := '';
        end;
      end;
    end;
  end;

// ========================================================
// Login Items - MAC (Plists listing applications that automatically start when the user is logged in)
// ========================================================
  procedure LoginItems;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_LOGINITEMS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:' + Item^.fi_NodeByName, RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node1) and (Node1.PropName = 'CustomListItems') then
          begin
            // Level 2 List
            NodeList2 := Node1.PropChildList;
            if assigned(NodeList2) then
              for y := 0 to NodeList2.Count - 1 do
              begin
                Node2 := TPropertyNode(NodeList2.items[y]);
                if assigned(Node2) and (Node2.PropName = '') then
                begin
                  // Level 3 List
                  NodeList3 := Node2.PropChildList;
                  if assigned(NodeList3) then
                    for z := 0 to NodeList3.Count - 1 do
                    begin
                      Node3 := TPropertyNode(NodeList3.items[z]);
                      if assigned(Node3) and (UpperCase(Node3.PropName) = UpperCase(RS_DNT_NAME)) then
                        variant_Array[1] := Node3.PropDisplayValue;
                    end;
                  AddToModule;
                  if bmComment <> '' then
                    BookMark(Item^.fi_Name_Program, bmComment);
                  bmComment := '';
                end;
              end;
          end;
        end;
      end;
    end;
  end;

// ==========================================================
// Login Window - MAC
// ==========================================================
  procedure LoginWindow;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_LOGINWINDOW') then
    begin
      NullTheArray;
      for g := 1 to ColCount do
      begin
        if not Progress.isRunning then
          break;
        DNT_sql_col := aItems[g].sql_col;
        Delete(DNT_sql_col, 1, 4);
        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(DNT_sql_col));
        if assigned(Node1) then
        begin
          // Date Time
          if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftDateTime) and (aItems[g].convert_as = '') then
            try
              variant_Array[g] := vartoDateTime(Node1.PropDisplayValue);
            except
              Progress.Log(ATRY_EXCEPT_STR + 'An exception occurred when converting: ' + Node1.PropDisplayValue);
            end;
          // Integer
          if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].read_as = ftInteger) and (aItems[g].col_type = ftInteger) then
            variant_Array[g] := Node1.PropDisplayValue;
          // String
          if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
            variant_Array[g] := Node1.PropDisplayValue;
        end;
      end;
      AddToModule;
    end;
  end;

// ========================================================
// OSX Update - MAC (Plist describing last attempt and last successful attempt at updating OS X software)
// ========================================================
  procedure OSXUpdate;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_OSXUPDATE') then
    begin
      bmComment := '';
      NullTheArray;
      for x := 0 to aRootProperty.PropChildList.Count - 1 do
      begin
        Node1 := TPropertyNode(aRootProperty.PropChildList.items[x]);
        for g := 1 to ColCount do
        begin
          if not Progress.isRunning then
            break;
          DNT_sql_col := aItems[g].sql_col;
          Delete(DNT_sql_col, 1, 4);
          // String
          if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
          begin
            variant_Array[g] := Node1.PropDisplayValue;
            Concat_bmComment(g, True);
          end;
        end;
      end;
      AddToModule;
      if bmComment <> '' then
        BookMark(Item^.fi_Name_Program, bmComment);
      bmComment := '';
    end;
  end;

// ========================================================
// Photo Booth Recents
// ========================================================
  procedure PhotoBoothRecents;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_PHOTOBOOTHRECENTS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(RS_DNT_array));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:' + Item^.fi_NodeByName, RPAD_VALUE) + IntToStr(NumberOfNodes));
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node1 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node1) and (Node1.PropName = RS_DNT_string) then
          begin
            variant_Array[1] := Node1.PropValue;
            Concat_bmComment(1, False); // False = Do not include label
          end;
          AddToModule;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Preferences - MAC
// ========================================================
  procedure Preferences;
  var
    Node_StringList: TStringList;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_MAC_PREFERENCES') then
    begin
      Node_StringList := TStringList.Create;
      try
        bmComment := '';
        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('dict')); // noslz
        if assigned(Node1) then
        begin
          NumberOfNodes := CountNodes(Node1);
          Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
          NullTheArray;
          nodefrog2(Node1, 0, Node_StringList);
        end;
        // Progress.Log(Node_StringList.Text);
      finally
        Node_StringList.free;
      end;
    end;
    AddToModule;
  end;

// ========================================================
// Printers_CUPS - MAC
// ========================================================
  procedure Printers_CUPS;
  var
    FoundNode: TPropertyNode;

    procedure findnode(aNode: TPropertyNode; anint: integer);
    var
      i: integer;
      theNodeList: TObjectList;
    begin
      if assigned(aNode) and Progress.isRunning then
      begin
        theNodeList := aNode.PropChildList;
        if assigned(theNodeList) then
        begin
          for i := 0 to theNodeList.Count - 1 do
          begin
            aNode := TPropertyNode(theNodeList.items[i]);
            if (aNode.PropName = 'key') and (theNodeList.Count <= theNodeList.Count + 1) then // noslz
            begin
              for g := 1 to ColCount do
              begin
                DNT_sql_col := aItems[g].sql_col;
                Delete(DNT_sql_col, 1, 4);
                if UpperCase(aNode.PropDisplayValue) = UpperCase(DNT_sql_col) then
                begin
                  aNode := TPropertyNode(theNodeList.items[i + 1]);
                  variant_Array[g] := aNode.PropDisplayValue;
                end;
              end;
            end
            else
              findnode(aNode, anint + 1);
          end;
          AddToModule;
        end;
      end;
    end;

  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_PRINTERS_CUPS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('array')); // noslz
      if assigned(Node1) then
      begin
        FoundNode := nil;
        findnode(Node1, 0);
        if FoundNode <> nil then
          recent_networks(FoundNode, 0);
      end;
    end;
  end;

// ========================================================
// Printers CUPS Control - MAC
// ========================================================
  procedure Printers_CUPS_Control;
  var
    AString: string;
    EntryReader: TEntryReader;
    curpos, h_offset, h_count: int64;
    HeaderRegex: TRegEx;
    hex_str: string;
    g: integer;
    lgth_i64: int64;

    function HexStrToInt(const str: string): integer;
    begin
      Result := StrToInt('$' + str);
    end;

  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_PRINTERS_CUPS_CONTROL') then
    begin
      EntryReader := TEntryReader.Create;
      try
        AString := '';
        if EntryReader.OpenData(aArtifactEntry) then
        begin
          NullTheArray;
          for g := 1 to ColCount do
          begin
            EntryReader.Position := 0;
            curpos := 0;
            h_offset := 0;
            h_count := 0;
            DNT_sql_col := aItems[g].sql_col;
            Delete(DNT_sql_col, 1, 4);
            if not Progress.isRunning then
              break;

            // Regex Setup -------------------------------------------------------
            HeaderRegex := TRegEx.Create;
            HeaderRegex.Progress := Progress;
            HeaderRegex.CaseSensitive := False;
            HeaderRegex.SearchTerm := DNT_sql_col;
            HeaderRegex.Stream := EntryReader;
            HeaderRegex.Find(h_offset, h_count); // Find the first match, h_offset returned is relative to start pos

            while h_offset <> -1 do // h_offset returned as -1 means no hit
            begin
              if not Progress.isRunning then
                break;
              // Progress.Log(RPad(inttostr(g) + '.' + SPACE + HeaderRegex.SearchTerm, RPAD_VALUE) + '@ ' + inttostr(h_offset) + SPACE + 'for: ' + inttostr(h_count) + SPACE + 'bytes');
              EntryReader.Position := h_offset + h_count;

              // Read the 2 byte marker between header and record to determine the size of the result
              hex_str := EntryReader.AsHexString(2); // Stores the length of the following data
              hex_str := StringReplace(hex_str, ' ', '', [rfReplaceAll]);
              lgth_i64 := HexStrToInt(hex_str);

              // Process the time at creation separately
              if DNT_sql_col = '(?<!-)time-at-creation' then // noslz (stops it hitting on date-time-at-creation
              begin
                hex_str := EntryReader.AsHexString(lgth_i64);
                hex_str := StringReplace(hex_str, ' ', '', [rfReplaceAll]);
                try
                  lgth_i64 := HexStrToInt(hex_str);
                  variant_Array[g] := UnixTimeToDateTime(lgth_i64);
                except
                end;
              end
              else
                variant_Array[g] := EntryReader.AsPrintableChar(lgth_i64);

              HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match for the current file
            end;
            FreeAndNil(HeaderRegex);
          end;
          AddToModule;
        end;
      finally
        EntryReader.free;
      end;
    end;
  end;

// ========================================================
// Recent Applications - MAC
// ========================================================
  procedure RecentItemsApplications;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTITEMSAPPLICATIONS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('RecentApplications')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Recent iWork Numbers - MAC
// ========================================================
  procedure RecentiWorkNumbers;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTIWORKNUMBERS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('CustomListItems')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Recent iWork Pages - MAC
// ========================================================
  procedure RecentiWorkPages;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTIWORKPAGES') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('CustomListItems')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Recent Documents - MAC
// ========================================================
  procedure RecentItemsDocuments;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTITEMSDOCUMENTS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('RecentDocuments')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Recent Hosts - MAC
// ========================================================
  procedure RecentItemsHosts;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTITEMSHOSTS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('Hosts')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// Safari Preferences - MAC
// ========================================================
  procedure SafariPreferences;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARIPREFERENCES') then
    begin
      NullTheArray;

      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('DownloadsPath')); // noslz
      if assigned(Node1) then
        if (Node1.PropName) = 'DownloadsPath' then
        begin
          variant_Array[1] := Node1.PropDisplayValue;
          Concat_bmComment(1, True); // True = include label
        end;

      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('HomePage')); // noslz
      if assigned(Node1) then
        if (Node1.PropName) = 'HomePage' then
        begin
          variant_Array[2] := Node1.PropDisplayValue;
          Concat_bmComment(2, True); // True = include label
        end;
      AddToModule;
      if bmComment <> '' then
        BookMark(Item^.fi_Name_Program, bmComment);
      bmComment := '';
    end;
  end;

// ========================================================
// Safari Searches - MAC
// ========================================================
  procedure SafariSearches;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_RECENTSAFARIWEBSEARCHES') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('RecentWebSearches')); // noslz
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node1) and (Node1.PropName = '') then
          begin
            // Level 2 List
            NodeList2 := Node1.PropChildList;
            if assigned(NodeList2) then
              for y := 0 to NodeList2.Count - 1 do
              begin
                Node2 := TPropertyNode(NodeList2.items[y]);
                for g := 1 to ColCount do
                begin
                  if not Progress.isRunning then
                    break;
                  DNT_sql_col := aItems[g].sql_col;
                  Delete(DNT_sql_col, 1, 4);
                  // String
                  if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
                  begin
                    variant_Array[g] := Node2.PropDisplayValue;
                    Concat_bmComment(g, True); // True = include label
                  end;
                end;
              end;
            AddToModule;
          end;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// System Version - MAC
// ========================================================
  procedure SystemVersion;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_SYSTEMVERSION') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('dict')); // noslz
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node1 := TPropertyNode(NodeList1.items[x]);
          if assigned(Node1) and (Node1.PropName = RS_DNT_key) then
            if x + 1 <= NumberOfNodes - 1 then
            begin
              if (Node1.PropValue) = 'ProductBuildVersion' then // noslz
              begin
                Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                variant_Array[1] := Node1Next.PropDisplayValue;
                Concat_bmComment(1, True); // True = include label
              end;
              if (Node1.PropValue) = 'ProductCopyright' then // noslz
              begin
                Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                variant_Array[2] := Node1Next.PropDisplayValue;
                Concat_bmComment(2, True); // True = include label
              end;
              if (Node1.PropValue) = 'ProductName' then // noslz
              begin
                Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                variant_Array[3] := Node1Next.PropDisplayValue;
                Concat_bmComment(3, True); // True = include label
              end;
              if (Node1.PropValue) = 'ProductVersion' then // noslz
              begin
                Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                variant_Array[4] := Node1Next.PropDisplayValue;
                Concat_bmComment(4, True); // True = include label
              end;
            end;
        end;
        AddToModule;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// TimeZone (LocalTime) - MAC
// ========================================================
  procedure TimeZoneLocalTime;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_LOCALTIME') and (aArtifactEntry.LogicalSize > 0) and (aArtifactEntry.LogicalSize <= 64) then
    begin
      ByteCount := newEntryReader.Read(ByteArray[1], aArtifactEntry.LogicalSize);
      if ByteCount > 0 then // we have read at least 1 byte or more.
      begin
        newEntryReader.Position := 0;
        printchars := newEntryReader.AsPrintableChar(ByteCount);
        variant_Array[1] := printchars;
        Concat_bmComment(1, True);
      end;
      AddToModule;
      if bmComment <> '' then
        BookMark(Item^.fi_Name_Program, bmComment);
      bmComment := '';
    end;
  end;

// ========================================================
// TimeZone - MAC
// ========================================================
  procedure TimeZone;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_TIMEZONE') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('com.apple.preferences.timezone.selected_city')); // noslz
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          Node1 := TPropertyNode(NodeList1.items[x]);
          for g := 1 to ColCount do
          begin
            if not Progress.isRunning then
              break;
            DNT_sql_col := aItems[g].sql_col;
            Delete(DNT_sql_col, 1, 4);
            // String
            if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
            begin
              variant_Array[g] := Node1.PropDisplayValue;
              Concat_bmComment(g, True); // True = include label
            end;
          end;
        end;
        AddToModule;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// User Accounts Deleted - MAC
// ========================================================
  procedure UserAccountsDeleted;
  var
    Node_StringList: TStringList;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_USER_ACCOUNTS_DELETED') then
    begin
      Node_StringList := TStringList.Create;
      try
        bmComment := '';
        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('deletedUsers')); // noslz
        if assigned(Node1) then
        begin
          NumberOfNodes := CountNodes(Node1);
          Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
          NullTheArray;
          nodefrog(Node1, 0); // ,Node_StringList);
        end;
        // MessageUser(Node_StringList.Text);
      finally
        Node_StringList.free;
      end;
    end;
    AddToModule; // data gets added to the columns here.
  end;

// ========================================================
// Wifi - MAC
// ========================================================
  procedure wifi;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_MAC_WIFI') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(RS_DNT_values));
      if assigned(Node1) then
      begin
        // Count the number of nodes
        NodeList1 := Node1.PropChildList;
        if assigned(NodeList1) then
          NumberOfNodes := NodeList1.Count
        else
          NumberOfNodes := 0;
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        // Process the nodes
        for x := 0 to NumberOfNodes - 1 do
        begin
          NullTheArray;
          Node1 := TPropertyNode(NodeList1.items[x]);
          PropertyList := Node1.PropChildList;
          if assigned(PropertyList) then
            for y := 0 to PropertyList.Count - 1 do
            begin
              Node2 := TPropertyNode(PropertyList.items[y]);
              if assigned(Node2) then
                if assigned(Node2) and (Node2.PropName = 'value') then // noslz
                begin
                  PropertyList2 := Node2.PropChildList;
                  if assigned(PropertyList2) then
                    for z := 0 to PropertyList2.Count - 1 do
                    begin
                      // Get the value nodes for each wifi network
                      Node3 := TPropertyNode(PropertyList2.items[z]);
                      if assigned(Node3) then
                        for g := 1 to ColCount do
                        begin
                          if not Progress.isRunning then
                            break;
                          DNT_sql_col := aItems[g].sql_col;
                          Delete(DNT_sql_col, 1, 4);
                          // String
                          // Progress.Log('PropName: ' + UpperCase(Node3.PropName) + ' ' + 'SQL Col: ' + UpperCase(DNT_sql_col));
                          if (UpperCase(Node3.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
                          begin
                            variant_Array[g] := Node3.PropDisplayValue;
                            Concat_bmComment(g, True); // True = include label
                          end;
                        end;
                    end;
                  bmComment := bmComment + #13#10;
                  AddToModule;
                end;
            end;
        end;
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end; { wifi mac }
  end;

// ========================================================
// Preview Recent Items - MAC
// ========================================================
  procedure RecentItemsPreview;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_PREVIEWRECENTITEMS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('CustomListItems')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// QuickTime Recent Items - MAC
// ========================================================
  procedure RecentItemsQuickTime;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_QUICKTIMERECENTITEMS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('CustomListItems')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// TextEdit Recent Items - MAC
// ========================================================
  procedure RecentItemsTextEdit;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_TEXTEDITRECENTITEMS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('CustomListItems')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// ========================================================
// VideoLan Recent Items - MAC
// ========================================================
  procedure RecentItemsVideoLan;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_VIDEOLANRECENTITEMS') then
    begin
      bmComment := '';
      Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('CustomListItems')); // noslz
      if assigned(Node1) then
      begin
        NumberOfNodes := CountNodes(Node1);
        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));
        NullTheArray;
        nodefrog(Node1, 0);
        if bmComment <> '' then
          BookMark(Item^.fi_Name_Program, bmComment);
        bmComment := '';
      end;
    end;
  end;

// Start of Do Process ---------------------------------------------------------
begin
  Item := FileItems[Reference_Number];
  temp_process_counter := 0;
  ColCount := LengthArrayTABLE(aItems);
  bmComment := '';
  if (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) then
  begin
    if assigned(anArtifactFolder) then
    begin
      process_proceed_bl := True;
      SetUpColumnforFolder(Reference_Number, anArtifactFolder, col_DF, ColCount, aItems);
      if process_proceed_bl then
      begin
        setlength(variant_Array, ColCount + 1);
        ADDList := TList.Create;
        newEntryReader := TEntryReader.Create;
        try
          Progress.Max := Arr_ValidatedFiles_TList[Reference_Number].Count;
          Progress.DisplayMessageNow := 'Process' + SPACE + PROGRAM_NAME + ' - ' + Item^.fi_Name_OS + RUNNING;
          Progress.CurrentPosition := 1;

          TotalFiles := Arr_ValidatedFiles_TList[Reference_Number].Count;
          // Loop Validated Files ----------------------------------------------
          for i := 0 to Arr_ValidatedFiles_TList[Reference_Number].Count - 1 do { addList is freed a the end of this loop }
          begin
            if not Progress.isRunning then
              break;
            Progress.IncCurrentprogress;
            temp_process_counter := temp_process_counter + 1;
            Display_Name_str := GetFullName(Item);
            Progress.DisplayMessageNow := 'Processing' + SPACE + Display_Name_str + ' (' + IntToStr(temp_process_counter) + ' of ' + IntToStr(Arr_ValidatedFiles_TList[Reference_Number].Count) + ')' + RUNNING;
            aArtifactEntry := TEntry(Arr_ValidatedFiles_TList[Reference_Number].items[i]);
            if assigned(aArtifactEntry.Parent) then
              aArtifactEntryParent := TEntry(aArtifactEntry.Parent);

            // Read attributes not content
            MailFolders;
            InstallationDate;

            if assigned(aArtifactEntry) and newEntryReader.OpenData(aArtifactEntry) and (newEntryReader.Size > 0) and Progress.isRunning then
            begin
              if USE_FLAGS_BL then
                aArtifactEntry.Flags := aArtifactEntry.Flags + [Flag8]; // Gray Flag = Process Routine

              Printers_CUPS_Control;
              TimeZoneLocalTime;

              // ================================================================
              // NODES - .PropName, .PropDisplayValue, .PropValue, .PropDataType
              // ================================================================
              if ((UpperCase(Item^.fi_Process_As) = PROCESS_AS_PLIST) or (UpperCase(Item^.fi_Process_As) = PROCESS_AS_XML)) and ((UpperCase(Item^.fi_Signature_Parent) = 'PLIST (BINARY)') or (UpperCase(Item^.fi_Signature_Parent) = 'XML'))
              then
              begin
                aPropertyTree := nil;
                try
                  if ProcessMetadataProperties(aArtifactEntry, aPropertyTree, newEntryReader) and assigned(aPropertyTree) then
                  begin
                    // Set Root Property (Level 0)
                    aRootProperty := aPropertyTree.RootProperty;
                    Progress.Log(RPad('Number of root child nodes:', RPAD_VALUE) + IntToStr(aRootProperty.PropChildList.Count) + HYPHEN + 'Bates ID: ' + IntToStr(aArtifactEntry.ID) + ' ' + aArtifactEntry.EntryName);
                    if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
                    begin
                      if not Progress.isRunning then
                        break;

                      if aRootProperty.PropName = (Item^.fi_RootNodeName) then
                      begin
                        AddressBookMe;
                        AttachediDevices;
                        bluetooth;
                        DHCP;
                        DockItems;
                        iCloudPreferences;
                        iMessageAccounts;
                        InstalledPrinters;
                        LastSleep;
                        LoginItems;
                        LoginWindow;
                        MailBackupTOC;
                        KnownNetworks;
                        RecentNetworks;
                        OSXUpdate;
                        PhotoBoothRecents;
                        Preferences;
                        Printers_CUPS;
                        RecentItemsApplications;
                        RecentItemsDocuments;
                        RecentItemsHosts;
                        RecentiWorkNumbers;
                        RecentiWorkPages;
                        RecentItemsPreview;
                        RecentItemsQuickTime;
                        RecentItemsTextEdit;
                        RecentItemsVideoLan;
                        SafariPreferences;
                        SafariSearches;
                        SystemVersion;
                        TimeZone;
                        UserAccountsDeleted;
                        wifi;
                      end;
                    end
                    else
                      Progress.Log((format('%-39s %-10s %-10s', ['Could not open data:', '-', 'Bates: ' + IntToStr(aArtifactEntry.ID) + ' ' + aArtifactEntry.EntryName])));
                  end;
                finally
                  if assigned(aPropertyTree) then
                    FreeAndNil(aPropertyTree);
                end;
              end;
            end;
            // Progress.Log(Stringofchar('-', CHAR_LENGTH));
            Progress.IncCurrentprogress;
          end;

          // Add to the ArtifactsDataStore
          if assigned(ADDList) and Progress.isRunning then
          begin
            if (CmdLine.Params.Indexof(TRIAGE) = -1) then
              ArtifactsDataStore.Add(ADDList);
            Progress.Log(RPad('Total Artifacts:', RPAD_VALUE) + IntToStr(ADDList.Count));

            // Export L01 files where artifacts are found (controlled by Artifact_Utils.pas)
            if (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) and (ADDList.Count > 0) then
              ExportToL01(Arr_ValidatedFiles_TList[Reference_Number], Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type);

            ADDList.Clear;
          end;

          Progress.Log(StringOfChar('-', CHAR_LENGTH));
        finally
          records_read_int := 0;
          FreeAndNil(ADDList);
          FreeAndNil(newEntryReader);
        end;
      end;

    end
    else
      Progress.Log(RPad('', RPAD_VALUE) + 'IMPORTANT: Process failed. Not assigned a tree folder.');

  end
  else
  begin
    Progress.Log(RPad('', RPAD_VALUE) + 'No files to process.');
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
  end;

end;

// ==========================================================================================================================================================
// Start of Script
// ==========================================================================================================================================================
const
  SEARCHING_FOR_ARTIFACT_FILES_STR = 'Searching for Artifact files';

var
  AboutToProcess_StringList: TStringList;
  aDeterminedFileDriverInfo: TFileTypeInformation;
  aFolderEntry: TEntry;
  AllFoundListUnique: TUniqueListOfEntries;
  AllFoundList_count: integer;
  DeleteFolder_display_str: string;
  DeleteFolder_TList: TList;
  Display_StringList: TStringList;
  Enum: TEntryEnumerator;
  ExistingFolders_TList: TList;
  FieldItunesDomain: TDataStoreField;
  FieldItunesName: TDataStoreField;
  FindEntries_StringList: TStringList;
  FoundList, AllFoundList: TList;
  i: integer;
  Item: PSQL_FileSearch;
  iTunes_Domain_str: string;
  iTunes_Name_str: string;
  ResultInt: integer;

{$IF DEFINED (ISFEXGUI)}
  MyScriptForm: TScriptForm;
{$IFEND}

procedure LogExistingFolders(ExistingFolders_TList: TList; DeleteFolder_TList: TList); // Compare About to Process Folders with Existing Artifact Module Folders
const
  LOG_BL = False;
var
  aFolderEntry: TEntry;
  s, t: integer;
begin
  if LOG_BL then
    Progress.Log('Existing Folders:');
  for s := 0 to ExistingFolders_TList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    aFolderEntry := (TEntry(ExistingFolders_TList[s]));
    if LOG_BL then
      Progress.Log(HYPHEN + aFolderEntry.FullPathName);
    for t := 0 to AboutToProcess_StringList.Count - 1 do
    begin
      if aFolderEntry.FullPathName = AboutToProcess_StringList[t] then
        DeleteFolder_TList.Add(aFolderEntry);
    end;
  end;
  if LOG_BL then
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
end;

// Start of script
begin
  LoadFileItems;
  Progress.Log(SCRIPT_NAME + ' started.');

  if (CmdLine.Params.Indexof(TRIAGE) > -1) then
    Progress.DisplayTitle := 'Triage' + HYPHEN + 'File System - MAC'
  else
    Progress.DisplayTitle := 'Artifacts' + HYPHEN + PROGRAM_NAME;
  Progress.LogType := ltVerbose; // ltOff, ltVerbose, ltDebug, ltTechnical

  // MakeButton; Exit;

  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := ('Processing complete.');
    Exit;
  end;

  param := '';
  test_param_int := 0;
  process_all_bl := False;

  Parameter_Num_StringList := TStringList.Create;
  try { Parameter_Num_StringList }
    if (CmdLine.ParamCount > 0) then
    begin
      Progress.Log(IntToStr(CmdLine.ParamCount) + ' processing parameters received: ');
      for n := 0 to CmdLine.ParamCount - 1 do
      begin
        if not Progress.isRunning then
          break;

        param := param + '"' + CmdLine.Params[n] + '"' + ' ';
        // Validate Parameters
        if (RegexMatch(CmdLine.Params[n], '\d{1,2}$', False)) then
        begin
          try
            test_param_int := StrToInt(CmdLine.Params[n]);
            if (test_param_int <= 0) or (test_param_int > NUMBEROFSEARCHITEMS) then
            begin
              MessageUser('Invalid parameter received: ' + (CmdLine.Params[n]) + #13#10 + ('Maximum is: ' + IntToStr(NUMBEROFSEARCHITEMS) + DCR + SCRIPT_NAME + ' will terminate.'));
              Exit;
            end;
            Parameter_Num_StringList.Add(CmdLine.Params[n]);
            Item := FileItems[test_param_int];
            Progress.Log(RPad(HYPHEN + 'Param ' + IntToStr(n) + ' = ' + CmdLine.Params[n], RPAD_VALUE) + format('%-10s %-10s %-25s %-12s', ['Ref#: ' + CmdLine.Params[n], CATEGORY_NAME,
              Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type, Item^.fi_Name_OS]));
          except
            begin
              Progress.Log(ATRY_EXCEPT_STR + 'Error validating parameter. ' + SCRIPT_NAME + ' will terminate.');
              Exit;
            end;
          end;
        end;
      end;
      trim(param);
    end
    else
    begin
      MessageUser('No parameters received.');
      Exit;
    end;
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    // Progress Bar Text
    progress_program_str := '';
    if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
    begin
      progress_program_str := PROGRAM_NAME;
      process_all_bl := True;
    end;

    for n := 1 to NUMBEROFSEARCHITEMS do
    begin
      if not Progress.isRunning then
        break;
      if (CmdLine.Params.Indexof(IntToStr(n)) > -1) then
      begin
        Item := FileItems[n];
        progress_program_str := 'Ref#:' + SPACE + param + SPACE + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type;
        break;
      end;
    end;
    if progress_program_str = '' then
      progress_program_str := 'Other';

    ArtifactsDataStore := GetDataStore(DATASTORE_ARTIFACTS);
    if not assigned(ArtifactsDataStore) then
    begin
      Progress.Log(DATASTORE_ARTIFACTS + ' module not located.' + DCR + TSWT);
      Exit;
    end;

    try { ArtifactsDataStore }
      FileSystemDataStore := GetDataStore(DATASTORE_FILESYSTEM);
      if not assigned(FileSystemDataStore) then
      begin
        Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + DCR + TSWT);
        Exit;
      end;

      try { FileSystemDataStore }
        FieldItunesDomain := FileSystemDataStore.DataFields.FieldByName(FBN_ITUNES_BACKUP_DOMAIN);
        FieldItunesName := FileSystemDataStore.DataFields.FieldByName(FBN_ITUNES_BACKUP_NAME);

        // Create TLists For Valid Files
        for n := 1 to NUMBEROFSEARCHITEMS do
        begin
          if not Progress.isRunning then
            break;
          Arr_ValidatedFiles_TList[n] := TList.Create;
        end;

        try { Arr_ValidatedFiles_TList }
          AboutToProcess_StringList := TStringList.Create;
          AboutToProcess_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
          AboutToProcess_StringList.Duplicates := dupIgnore;
          try
            Display_str := '';
            mb_display_str := '';
            previous_str := '';
            current_str := '';
            if (CmdLine.Params.Indexof('MASTER') = -1) then
            begin
              if (CmdLine.Params.Indexof('NOSHOW') = -1) then
              begin
                Display_StringList := TStringList.Create;
                Display_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
                Display_StringList.Duplicates := dupIgnore;
                try
                  // Process All - Create the AboutToProcess_StringList and the Message Box text
                  if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
                  begin
                    previous_str := '';
                    current_str := '';
                    for n := 1 to NUMBEROFSEARCHITEMS do
                    begin
                      if not Progress.isRunning then
                        break;
                      Item := FileItems[n];
                      current_str := GetFullName(Item);
                      AboutToProcess_StringList.Add(CATEGORY_NAME + '\' + current_str);
                      if current_str <> previous_str then
                      begin
                        Display_StringList.Add(current_str);
                      end;
                      previous_str := current_str;
                    end;
                    Display_str := Display_StringList.Text;
                  end
                  else
                  begin
                    // Process Individual - Create the AboutToProcess_StringList and the Message Box text
                    if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) then
                    begin
                      for n := 0 to Parameter_Num_StringList.Count - 1 do
                      begin
                        if not Progress.isRunning then
                          break;
                        temp_int := StrToInt(Parameter_Num_StringList[n]);
                        Item := FileItems[temp_int];
                        AboutToProcess_StringList.Add(CATEGORY_NAME + '\' + GetFullName(Item));
                      end;
                      Display_str := AboutToProcess_StringList.Text;
                    end;
                  end;
                finally
                  if (Display_StringList.Count > 0) then
                  begin
                    Progress.Log('Extract Artifacts:');
                    Progress.Log(Display_StringList.Text);
                  end;
                  Display_StringList.free;
                end;

                // // Log About to Process
                // Progress.Log('About to Process:');
                // for s := 0 to AboutToProcess_StringList.Count - 1 do
                // Progress.Log(AboutToProcess_StringList[s]);
                // Progress.Log(Stringofchar('-', CHAR_LENGTH));

                // Show the form
                ResultInt := 1; // Continue AboutToProcess

{$IF DEFINED (ISFEXGUI)}
                if AboutToProcess_StringList.Count > 30 then
                begin
                  MyScriptForm := TScriptForm.Create;
                  try
                    MyScriptForm.SetCaption(SCRIPT_DESCRIPTION);
                    MyScriptForm.SetText(trim(Display_str));
                    ResultInt := idCancel;
                    if MyScriptForm.ShowModal then
                      ResultInt := idOk
                  finally
                    FreeAndNil(MyScriptForm);
                  end;
                end
                else
                begin
                  ResultInt := MessageBox('Extract Artifacts?' + DCR + Display_str, 'Extract Artifacts' + HYPHEN + PROGRAM_NAME, (MB_OKCANCEL or MB_ICONQUESTION or MB_DEFBUTTON2 or MB_SETFOREGROUND or MB_TOPMOST));
                end;
{$IFEND}
              end;

              if ResultInt > 1 then // User cancels
              begin
                Progress.Log(CANCELED_BY_USER);
                Progress.DisplayMessageNow := CANCELED_BY_USER;
                Exit;
              end;

            end; { About to process }

            // Deal with Existing Artifact Folders
            ExistingFolders_TList := TList.Create;
            DeleteFolder_TList := TList.Create;
            try
              if ArtifactsDataStore.Count > 1 then
              begin
                anEntry := ArtifactsDataStore.First;
                while assigned(anEntry) and Progress.isRunning do
                begin
                  if anEntry.isDirectory then
                    ExistingFolders_TList.Add(anEntry);
                  anEntry := ArtifactsDataStore.Next;
                end;
                ArtifactsDataStore.Close;
              end;

              LogExistingFolders(ExistingFolders_TList, DeleteFolder_TList);

              // Create the delete folder TList and display string
              if assigned(DeleteFolder_TList) and (DeleteFolder_TList.Count > 0) then
              begin
                for s := 0 to DeleteFolder_TList.Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  aFolderEntry := (TEntry(DeleteFolder_TList[s]));
                  DeleteFolder_display_str := DeleteFolder_display_str + #13#10 + aFolderEntry.FullPathName;
                  Progress.Log('Replace this Artifact folder?: ' + aFolderEntry.FullPathName);
                end;
                Progress.Log(StringOfChar('-', CHAR_LENGTH));
              end;

              // Message Box - When artifact folder is already present ---------------------
              if assigned(DeleteFolder_TList) and (DeleteFolder_TList.Count > 0) then
              begin
                if (CmdLine.Params.Indexof('MASTER') = -1) and (CmdLine.Params.Indexof('NOSHOW') = -1) then
                begin
{$IF DEFINED (ISFEXGUI)}
                  if (CmdLine.Params.Indexof('NOSHOW') = -1) then
                  begin
                    if assigned(DeleteFolder_TList) and (DeleteFolder_TList.Count > 0) then
                    begin
                      ResultInt := MessageBox('Artifacts have already been processed:' + #13#10 + DeleteFolder_display_str + DCR + 'Replace the existing Artifacts?', 'Extract Artifacts' + HYPHEN + PROGRAM_NAME,
                        (MB_OKCANCEL or MB_ICONWARNING or MB_DEFBUTTON2 or MB_SETFOREGROUND or MB_TOPMOST));
                    end;
                  end
                  else
                    ResultInt := idOk;
                  case ResultInt of
                    idOk:
                      begin
                        try
                          ArtifactsDataStore.Remove(DeleteFolder_TList);
                        except
                          MessageBox('ERROR: There was an error deleting existing artifacts.' + #13#10 + 'Save then reopen your case.', SCRIPT_NAME, (MB_OK or MB_ICONINFORMATION or MB_SETFOREGROUND or MB_TOPMOST));
                        end;
                        Progress.Log(RPad('Replace Existing Artifacts:', RPAD_VALUE) + 'True');
                      end;
                    idCancel:
                      begin
                        Progress.Log(CANCELED_BY_USER);
                        Progress.DisplayMessageNow := CANCELED_BY_USER;
                        Exit;
                      end;
                  end;
{$IFEND}
                end;
              end;
            finally
              ExistingFolders_TList.free;
              DeleteFolder_TList.free;
            end;
          finally
            AboutToProcess_StringList.free;
          end;

          // Find iTunes Backups and run Signature Analysis
          if (CmdLine.Params.Indexof('NOITUNES') = -1) then
            Itunes_Backup_Signature_Analysis;

          // Create the RegEx Search String
          regex_search_str := '';
          begin
            for n := 1 to NUMBEROFSEARCHITEMS do
            begin
              if not Progress.isRunning then
                break;
              Item := FileItems[n];
              if (CmdLine.Params.Indexof(IntToStr(n)) > -1) or (CmdLine.Params.Indexof(PROCESSALL) > -1) then
              begin
                if Item^.fi_Regex_Search <> '' then
                  regex_search_str := regex_search_str + '|' + Item^.fi_Regex_Search;
                if Item^.fi_Regex_Itunes_Backup_Domain <> '' then
                  regex_search_str := regex_search_str + '|' + Item^.fi_Regex_Itunes_Backup_Domain;
                if Item^.fi_Regex_Itunes_Backup_Name <> '' then
                  regex_search_str := regex_search_str + '|' + Item^.fi_Regex_Itunes_Backup_Name;
              end;
            end;
          end;
          if (regex_search_str <> '') and (regex_search_str[1] = '|') then
            Delete(regex_search_str, 1, 1);

          AllFoundList := TList.Create;
          try
            AllFoundListUnique := TUniqueListOfEntries.Create;
            FoundList := TList.Create;
            FindEntries_StringList := TStringList.Create;
            try
              FindEntries_StringList.Add('**\*.plist');
              FindEntries_StringList.Add('**\.AppleSetupDone');
              FindEntries_StringList.Add('**\cups\c*');
              FindEntries_StringList.Add('**\IMAP-*');
              FindEntries_StringList.Add('**\localtime');
              FindEntries_StringList.Add('**\MobileSync\**\*'); // All iTunes folder
              FindEntries_StringList.Add('**\POP-*');
              FindEntries_StringList.Add('**\en*-*,*'); // DHCP

              // Find the files by path and add to AllFoundListUnique
              Progress.Initialize(FindEntries_StringList.Count, STR_FILES_BY_PATH + RUNNING);
              Progress.Log('Find files by path' + RUNNING);
              gtick_foundlist_i64 := GetTickCount;
              for i := 0 to FindEntries_StringList.Count - 1 do
              begin
                if not Progress.isRunning then
                  break;
                try
                  Find_Entries_By_Path(FileSystemDataStore, FindEntries_StringList[i], FoundList, AllFoundListUnique);
                except
                  Progress.Log(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + 'Find_Entries_By_Path');
                end;
                Progress.IncCurrentprogress;
              end;

              Progress.Log(StringOfChar('-', CHAR_LENGTH));
              Progress.Log(RPad(STR_FILES_BY_PATH + SPACE + '(Unique)' + COLON, RPAD_VALUE) + IntToStr(AllFoundListUnique.Count));
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

              // Add > 40 char files with no extension to Unique List (possible iTunes backup files)
              Add40CharFiles(AllFoundListUnique);
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

              // Move the AllFoundListUnique list into a TList
              if assigned(AllFoundListUnique) and (AllFoundListUnique.Count > 0) then
              begin
                Enum := AllFoundListUnique.GetEnumerator;
                while Enum.MoveNext do
                begin
                  anEntry := Enum.Current;
                  AllFoundList.Add(anEntry);
                end;
              end;

              // Now work with the TList from now on
              if assigned(AllFoundList) and (AllFoundList.Count > 0) then
              begin
                Progress.Log(StringOfChar('-', CHAR_LENGTH));
                Progress.Log('Unique Files by path: ' + IntToStr(AllFoundListUnique.Count));
                Progress.Log(StringOfChar('-', CHAR_LENGTH));

                // Add flags
                if USE_FLAGS_BL then
                begin
                  Progress.Log('Adding flags' + RUNNING);
                  for i := 0 to AllFoundList.Count - 1 do
                  begin
                    if not Progress.isRunning then
                      break;
                    anEntry := TEntry(AllFoundList[i]);
                    anEntry.Flags := anEntry.Flags + [Flag7];
                  end;
                  Progress.Log('Finished adding flags...');
                  Progress.Log(StringOfChar('-', CHAR_LENGTH));
                end;

                // Determine signature
                if assigned(AllFoundList) and (AllFoundList.Count > 0) then
                  SignatureAnalysis(AllFoundList);

                gtick_foundlist_str := (RPad(STR_FILES_BY_PATH + COLON, RPAD_VALUE) + CalcTimeTaken(gtick_foundlist_i64));
              end;

            finally
              FoundList.free;
              AllFoundListUnique.free;
              FindEntries_StringList.free;
            end;

            // Locate the relevant files in the File System
            if assigned(AllFoundList) and (AllFoundList.Count > 0) then
            begin
              Progress.Log(SEARCHING_FOR_ARTIFACT_FILES_STR + ':' + SPACE + progress_program_str + RUNNING);
              Progress.Log(format(GFORMAT_STR, ['', 'Action', 'Ref#', 'Bates', 'Signature', 'Filename (trunc)', 'Reason'])); // noslz
              Progress.Log(format(GFORMAT_STR, ['', '------', '----', '-----', '---------', '----------------', '------'])); // noslz

              AllFoundList_count := AllFoundList.Count;
              Progress.Initialize(AllFoundList_count, SEARCHING_FOR_ARTIFACT_FILES_STR + ':' + SPACE + progress_program_str + RUNNING);
              for i := 0 to AllFoundList.Count - 1 do
              begin
                Progress.DisplayMessages := SEARCHING_FOR_ARTIFACT_FILES_STR + SPACE + '(' + IntToStr(i) + ' of ' + IntToStr(AllFoundList_count) + ')' + RUNNING;
                if not Progress.isRunning then
                  break;
                anEntry := TEntry(AllFoundList[i]);

                if (i mod 10000 = 0) and (i > 0) then
                begin
                  Progress.Log('Processing: ' + IntToStr(i) + ' of ' + IntToStr(AllFoundList.Count) + RUNNING);
                  Progress.Log(StringOfChar('-', CHAR_LENGTH));
                end;

                // Set the iTunes Domain String
                iTunes_Domain_str := '';
                if assigned(FieldItunesDomain) then
                begin
                  try
                    iTunes_Domain_str := FieldItunesDomain.AsString[anEntry];
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error reading iTunes Domain string');
                  end;
                end;

                // Set the iTunes Name String
                iTunes_Name_str := '';
                if assigned(FieldItunesName) then
                begin
                  try
                    iTunes_Name_str := FieldItunesName.AsString[anEntry];
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error reading iTunes Name string');
                  end;
                end;

                // Run the match
                aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
                if (anEntry.Extension <> 'db-shm') and (anEntry.Extension <> 'db-wal') and (aDeterminedFileDriverInfo.ShortDisplayName <> 'Sqlite WAL') and (aDeterminedFileDriverInfo.ShortDisplayName <> 'Sqlite SHM') then
                begin
                  if RegexMatch(anEntry.EntryName, regex_search_str, False) or RegexMatch(anEntry.FullPathName, regex_search_str, False) or FileSubSignatureMatch(anEntry) or RegexMatch(iTunes_Domain_str, regex_search_str, False) or
                    RegexMatch(iTunes_Name_str, regex_search_str, False) then
                  begin
                    // Sub Signature Match
                    if FileSubSignatureMatch(anEntry) then
                    begin
                      if USE_FLAGS_BL then
                        anEntry.Flags := anEntry.Flags + [Flag2]; // Blue Flag
                      DetermineThenSkipOrAdd(anEntry, iTunes_Domain_str, iTunes_Name_str);
                    end
                    else
                    begin
                      // Regex Name Match
                      if (anEntry.EntryName = '.AppleSetupDone') or (anEntry.EntryName = 'localtime') or (anEntry.isDirectory and RegexMatch(anEntry.EntryName, '(IMAP|POP)-', False)) or ((not anEntry.isDirectory) or (anEntry.isDevice)) and
                        (anEntry.LogicalSize > 0) and (anEntry.PhysicalSize > 0) then
                      begin
                        if FileNameRegexSearch(anEntry, iTunes_Domain_str, iTunes_Name_str, regex_search_str) then
                        begin
                          if USE_FLAGS_BL then
                            anEntry.Flags := anEntry.Flags + [Flag1]; // Red Flag
                          DetermineThenSkipOrAdd(anEntry, iTunes_Domain_str, iTunes_Name_str);
                        end;
                      end;
                    end;
                  end;
                  Progress.IncCurrentprogress;
                end;
              end;
            end;
          finally
            AllFoundList.free;
          end;

          // Check to see if files were found
          if (TotalValidatedFileCountInTLists = 0) then
          begin
            Progress.Log('No ' + PROGRAM_NAME + SPACE + 'files were found.');
            Progress.DisplayTitle := 'Artifacts' + HYPHEN + PROGRAM_NAME + HYPHEN + 'Not found';
            Exit;
          end
          else
          begin
            Progress.Log(StringOfChar('-', CHAR_LENGTH + 80));
            Progress.Log(RPad('Total Validated Files:', RPAD_VALUE) + IntToStr(TotalValidatedFileCountInTLists));
            Progress.Log(StringOfChar('=', CHAR_LENGTH + 80));
          end;

          // Display the content of the TLists for further processing
          if (TotalValidatedFileCountInTLists > 0) and Progress.isRunning then
          begin
            Progress.Log('Lists available to process...');
            for n := 1 to NUMBEROFSEARCHITEMS do
            begin
              if not Progress.isRunning then
                break;
              Item := FileItems[n];
              if Arr_ValidatedFiles_TList[n].Count > 0 then
              begin
                Progress.Log(StringOfChar('-', CHAR_LENGTH));
                Progress.Log(RPad('TList ' + IntToStr(n) + ': ' + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type + HYPHEN + Item^.fi_Name_OS, RPAD_VALUE) + IntToStr(Arr_ValidatedFiles_TList[n].Count));
                for r := 0 to Arr_ValidatedFiles_TList[n].Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  anEntry := (TEntry(TList(Arr_ValidatedFiles_TList[n]).items[r]));
                  if not(Item^.fi_Process_As = 'POSTPROCESS') then
                    Progress.Log(RPad(' Bates: ' + IntToStr(anEntry.ID), RPAD_VALUE) + anEntry.EntryName + SPACE + Item^.fi_Process_As);
                end;
              end;
            end;
            Progress.Log(StringOfChar('-', CHAR_LENGTH + 80));
          end;

          // *** CREATE GUI ***
          if (TotalValidatedFileCountInTLists > 0) and Progress.isRunning then
          begin
            Progress.DisplayTitle := 'Artifacts' + HYPHEN + PROGRAM_NAME + HYPHEN + 'Found';

            // Create the Category Folder to the tree ----------------------------------
            ArtifactConnect_CategoryFolder := AddArtifactCategory(nil, CATEGORY_NAME, -1, FileItems[1].fi_Icon_Category); { Sort index, icon }
            ArtifactConnect_CategoryFolder.Status := ArtifactConnect_CategoryFolder.Status + [dstUserCreated];

            if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
            begin
              for n := 1 to NUMBEROFSEARCHITEMS do
              begin
                if not Progress.isRunning then
                  break;

                Item := FileItems[n];
                if (Arr_ValidatedFiles_TList[n].Count > 0) or (Item^.fi_Process_As = 'POSTPROCESS') then
                begin
                  ArtifactConnect_ProgramFolder[n] := AddArtifactConnect(TEntry(ArtifactConnect_CategoryFolder),
                  Item^.fi_Name_Program,
                  Item^.fi_Name_Program_Type,
                  Item^.fi_Name_OS,
                  Item^.fi_Icon_Program,
                  Item^.fi_Icon_OS);
                  ArtifactConnect_ProgramFolder[n].Status := ArtifactConnect_ProgramFolder[n].Status + [dstUserCreated];
                end;
              end;
            end
            else
            begin
              if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) or (Item^.fi_Process_As = 'POSTPROCESS') then
              begin
                for n := 0 to Parameter_Num_StringList.Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  temp_int := StrToInt(Parameter_Num_StringList[n]); // temp_int becomes the parameter
                  Item := FileItems[temp_int];
                  if Arr_ValidatedFiles_TList[temp_int].Count > 0 then
                  begin
                    ArtifactConnect_ProgramFolder[temp_int] := AddArtifactConnect(TEntry(ArtifactConnect_CategoryFolder),
                    Item^.fi_Name_Program,
                    Item^.fi_Name_Program_Type,
                    Item^.fi_Name_OS,
                    Item^.fi_Icon_Program,
                    Item^.fi_Icon_OS);
                    ArtifactConnect_ProgramFolder[temp_int].Status := ArtifactConnect_ProgramFolder[temp_int].Status + [dstUserCreated];
                  end;
                end;
              end;
            end;
            Progress.Log('Process Lists' + RUNNING);
            Progress.Log(StringOfChar('-', CHAR_LENGTH));

            // *** DO PROCESS ***
            temp_process_counter := 0;
            Progress.CurrentPosition := 0;
            Progress.Max := TotalValidatedFileCountInTLists;
            gtick_doprocess_i64 := GetTickCount;

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_1);
            Ref_Num := 2;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_2);
            Ref_Num := 3;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_3);
            Ref_Num := 4;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_4);
            Ref_Num := 5;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_5);
            Ref_Num := 6;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_6);
            Ref_Num := 7;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_7);
            Ref_Num := 8;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_8);
            Ref_Num := 9;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_9);
            Ref_Num := 10; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_10);
            Ref_Num := 11; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_11);
            Ref_Num := 12; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_12);
            Ref_Num := 13; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_13);
            Ref_Num := 14; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_14);
            Ref_Num := 15; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_15);
            Ref_Num := 16; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_16);
            Ref_Num := 17; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_17);
            Ref_Num := 18; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_18);
            Ref_Num := 19; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_19);
            Ref_Num := 20; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_20);
            Ref_Num := 21; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_21);
            Ref_Num := 22; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_22);
            Ref_Num := 23; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_23);
            Ref_Num := 24; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_24);
            Ref_Num := 25; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_25);
            Ref_Num := 26; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_26);
            Ref_Num := 27; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_27);
            Ref_Num := 28; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_28);
            Ref_Num := 29; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_29);
            Ref_Num := 30; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_30);
            Ref_Num := 31; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_31);
            Ref_Num := 32; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_32);
            Ref_Num := 33; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_33);
            Ref_Num := 34; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_34);
            Ref_Num := 35; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_35);
            Ref_Num := 36; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_36);
            Ref_Num := 37; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_37);

            gtick_doprocess_str := (RPad('DoProcess:', RPAD_VALUE) + CalcTimeTaken(gtick_doprocess_i64));

            // Remove folders with zero
            PostProcess_Remove_Zero;
          end;

          if not Progress.isRunning then
          begin
            Progress.Log(CANCELED_BY_USER);
            Progress.DisplayMessageNow := CANCELED_BY_USER;
          end;

        finally
          for n := 1 to NUMBEROFSEARCHITEMS do
            FreeAndNil(Arr_ValidatedFiles_TList[n]);
        end;

      finally
        if assigned(FileSystemDataStore) then
          FreeAndNil(FileSystemDataStore);
      end;

    finally
      if assigned(ArtifactsDataStore) then
        FreeAndNil(ArtifactsDataStore);
    end;

  finally
    if assigned(Parameter_Num_StringList) then
      FreeAndNil(Parameter_Num_StringList);
  end;

  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Progress.Log(gtick_foundlist_str);
  Progress.Log(gtick_doprocess_str);
  Progress.Log(StringOfChar('-', CHAR_LENGTH));

  Progress.Log(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := ('Processing complete.');

end.
