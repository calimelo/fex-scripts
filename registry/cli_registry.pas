{!NAME:      Triage - Registry}
{!DESC:      Triage Registry}
{!AUTHOR:    GetData}

unit cli_triage_registry;

interface

uses
  Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DataStreams, DIRegex,
  Graphics, Math, NoteEntry, PropertyList, RawRegistry, RegEx, SysUtils;

const
//==============================================================================
// DO NOT TRANSLATE
//==============================================================================
  // HIVES
  ANY_HIVE                      = 'ANY';          //noslz
  NTUSER_HIVE                   = 'NTUSER.DAT';   //noslz
  SAM_HIVE                      = 'SAM';          //noslz
  SECURITY_HIVE                 = 'SECURITY';     //noslz
  SOFTWARE_HIVE                 = 'SOFTWARE';     //noslz
  SYSTEM_HIVE                   = 'SYSTEM';       //noslz
  UNDETERMINED_HIVE             = 'UNDETERMINED'; //noslz
  USER_HIVE                     = 'USER';         //noslz
  // BOOKMARK FOLDERS                             //noslz
  BMF_SAM_HIVE                  = 'SAM';          //noslz
  BMF_SYSTEM_HIVE               = 'SYSTEM';       //noslz
  BMF_SOFTWARE_HIVE             = 'SOFTWARE';     //noslz
  BMF_NTUSER_HIVE               = 'NTUSER';       //noslz
  // FILE SIGNATURE                               //noslz
  FILESIG_REGISTRY              = 'Registry';     //noslz
  // SOFTWARE KEYS
  REGKEY_ALTDEFAULTDOMAINNAME   = 'AltDefaultDomainName';        //noslz
  REGKEY_DEFAULTDOMAINNAME      = 'DefaultDomainName';           //noslz
  REGKEY_DEFAULTUSERNAME        = 'DefaultUserName';             //noslz
  REGKEY_INSTALLDATE            = 'InstallDate';                 //noslz
  REGKEY_PRODUCTID              = 'ProductID';                   //noslz
  REGKEY_PRODUCTNAME            = 'ProductName';                 //noslz
  REGKEY_REGISTEREDORGANIZATION = 'RegisteredOrganization';      //noslz
  REGKEY_REGISTEREDOWNER        = 'RegisteredOwner';             //noslz
  REGKEY_SYSTEMROOT             = 'SystemRoot';                  //noslz
  // SYSTEM KEYS                                                 //noslz
  REGKEY_ACTIVETIMEBIAS         = 'ActiveTimeBias';              //noslz
  REGKEY_BIAS                   = 'Bias';                        //noslz
  REGKEY_COMPUTERNAME           = 'ComputerName';                //noslz
  REGKEY_CURRENT                = 'Current';                     //noslz
  REGKEY_DAYLIGHTBIAS           = 'DaylightBias';                //noslz
  REGKEY_DAYLIGHTNAME           = 'DaylightName';                //noslz
  REGKEY_DAYLIGHTSTART          = 'DaylightStart';               //noslz
  REGKEY_DEFAULT                = 'Default';                     //noslz
  REGKEY_FAILED                 = 'Failed';                      //noslz
  REGKEY_LASTKNOWNGOOD          = 'LastKnownGood';               //noslz
  REGKEY_NTFSDISLASTACCUP       = 'NtfsDisableLastAccessUpdate'; //noslz
  REGKEY_SHUTDOWNTIME           = 'ShutdownTime';                //noslz
  REGKEY_STANDARDBIAS           = 'StandardBias';                //noslz
  REGKEY_STANDARDNAME           = 'StandardName';                //noslz
  REGKEY_STANDARDSTART          = 'StandardStart';               //noslz
  REGKEY_TIMEZONEKEYNAME        = 'TimeZoneKeyName';             //noslz
  // PARAMETERS                                                  //noslz
  PARAM_EVIDENCEMODULE          = 'EVIDENCEMODULE';              //noslz
  PARAM_FSNTFSDISLASTACCUP      = 'FSNTFSDISLASTACCUP';          //noslz
  PARAM_FSRECENTDOCS            = 'FSRECENTDOCS';                //noslz
  PARAM_FSTIMEZONE              = 'FSTIMEZONE';                  //noslz
  PARAM_FSTRIAGE                = 'FSTRIAGE';                    //noslz
  PARAM_FSUNINSTALLPROGRAMS     = 'FSUNINSTALLPROGRAMS';         //noslz
  PARAM_FSWIRELESSNETWORKS      = 'FSWIRELESSNETWORKS';          //noslz
  PARAM_REGISTRYMODULE          = 'REGISTRYMODULE';              //noslz
  PARAM_FSSYSTEMROOT            = 'FSSYSTEMROOT';                //noslz
  PARAM_InList                  = 'InList';                      //noslz
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  CHAR_LENGTH                   = 90;
  COLON                         = ': ';
  HYPHEN                        = ' - ';
  PIPE = '|';  
  rpad_value                    = 30;
  SCRIPT_NAME                   = 'Triage'+HYPHEN+'Registry';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

  BMF_COMPUTER_INFORMATION      = 'Computer Information';
  BMF_COMPUTERNAME              = 'Computer Name';
  BMF_CONNECTED_PRINTERS        = 'Connected Printers';
  BMF_CONTROLSET                = 'Control Sets';
  BMF_EMAIL_CLIENTS             = 'Email Clients';
  BMF_MY_BOOKMARKS              = 'My Bookmarks';
  BMF_NTFSDISLASTACCUP          = 'NTFSDisableLastAccessUpdate';
  BMF_RECENTDOCS                = 'Recent Docs';
  BMF_REGISTRY                  = 'Registry';
  BMF_SHUTDOWNTIME              = 'Shutdown Time';
  BMF_SYSTEMROOT                = 'SystemRoot';
  BMF_TIMEZONEINFORMATION       = 'TimeZone Information';
  BMF_TRIAGE                    = 'FEX-Triage';
  BMF_UNINSTALLPROGRAMS         = 'Uninstall Programs';
  BMF_USBSTOR                   = 'USBStor Friendly Name';
  BMF_WIRELESS_NETWORKS_WIN7    = 'Wireless Networks (Win 7)';

  REG_NONE = 0;
  REG_SZ = 1;
  REG_EXPAND_SZ = 2;
  REG_BINARY = 3;
  REG_DWORD = 4;
  REG_DWORD_BIG_ENDIAN = 5;
  REG_LINK = 6;
  REG_MULTI_SZ = 7;
  REG_RESOURCE_LIST = 8;
  REG_FULL_RESOURCE_DESCRIPTOR = 9;
  REG_RESOURCE_REQUIREMENTS_LIST = 10;
  REG_QWORD_LE = 11;
  rrReg31Sign = 1195725379; // 'CREG';
  rrRegNTSign = 1718052210; // 'regf';

  csNone = 0;
  csAny = 1;
  csCurrent = 2;
  csDefault = 3;
  csFailed = 4;
  csLastKnownGood = 5;



// Global Variables
var
  bl_AutoBookmark_results: boolean;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

type
  TRegHiveType = (hvSOFTWARE, hvSAM, hvSECURITY, hvUSER, hvSYSTEM, hvUSER9X, hvSYSTEM9X, hvANY, hvUNKNOWN);
  TRegDataType = (rdNone, rdString, rdExpandString, rdBinary, rdInteger,
    rdIntegerBigEndian, rdLink, rdMultiString, rdResourceList, rdFullResourceDescription,
    rdResourceRequirementsList, rdint64, rdUnknown);

  TDataType = (dtString, dtUnixTime, dtFileTime, dtSystemTime, dtNetworkListDate, dtHex, dtMRUValue,
    dtMRUListEx, dtTimeZoneName, dtInteger);   //the type of data we want back

  TNetworkInfo = class
    Registry: TEntry;
    Device: TEntry;
    GUID: string;
    KeyFullPath: string;
    ProfileName: string;
    Description: string;
    DateCreated: string;
    LastConnected: string;
  end;

  TPrinterInfo = class
    Registry: TEntry;
    Device: TEntry;
    KeyFullPath: string;
    KeyName: string;
    Name: string;
    ShareName: string;
    Description: string;
    Driver: string;
    LastModified: TDateTime;
  end;

  TEmailInfo = class
    Registry: TEntry;
    Device: TEntry;
    Name: string;
    KeyPath: string;
  end;

  TTimeZoneInfo = class
    Device: TEntry;
    KeyName: string;
    KeyPath: string;
    Registry: TEntry;
    tzActiveTimeBias: integer;
    tzBias: integer;
    tzDaylightBias: integer;
    tzDaylightName: string;
    tzStandardBias: integer;
    tzStandardName: string;
    tzTimeZoneKeyName: string;
  end;

  TUninstallProgramsInfo = class
    Device: TEntry;
    KeyName: string;
    KeyPath: string;
    Registry: TEntry;
    Name: string;
  end;

  TUSBStorInfo = class
    Registry: TEntry;
    Device: TEntry;
    Name: string;
    KeyPath: string;
  end;

  TShellBagMRURecord = packed record
    DisplayName: string;
    TypeAsString: string;
    mru_type: byte;
    shortname: string;
    longname: string;
    build_path: string;
    accessed: TDateTime;
    created: TDateTime;
    modified: TDateTime;
  end;

  TRecentDocsInfo = class
    Registry: TEntry;
    Device: TEntry;
    Name: string;
    KeyPath: string;
    ShellBag: TShellBagMRURecord;
  end;

  TTempClassInfo = class
    BookmarkFolder: string;
    TempName: string;
    Device: TEntry;
    HiveType: string;
    KeyFullPath: string;
    KeyName: string;
    KeyPath: string;
    Registry: TEntry;
    RegistryFullPath: string;
  end;

  TControlSetInfo = class
    ActiveCS: integer;
    CurrentCS: integer;
    DefaultCS: integer;
    FailedCS: integer;
    LastKnownGoodCS: integer;
  end;

  TLogType = (ltMemo, ltBM, ltMessagesMemo, ltMessagesMemoBM);

  TRegSearchKey = class
    Hive: TRegHiveType;
    ControlSet: integer;
    DataType : TDataType;
    Key: string; // The registry folder name
    IncludeChildKeys: boolean;  // Search recursively through child keys also.
    Value: string; // The registry key name
    BookMarkFolder : string; // Default bookmark folder
  end;

  TRegSearchresult = class
    Entry : TEntry;
    SearchKey : TRegSearchKey;
    KeyPath: string; // The registry folder name
    EntryIdx: integer; // Index in the FRegEntries list
    function FullPath: string; abstract; virtual; // Full path of the key and value
  end;

  TRegSearchresultKey = class(TRegSearchresult)
    KeyName : string;
    KeyLastModified: TDateTime;
    function FullPath: string; override; // Full path of the key and value
    function GetChildKeys: TStringList;
  end;

  TRegSearchresultValue = class(TRegSearchresult)
    Name : string; // The registry key name
    DataType: TRegDataType; // Type of data that the key contains
    Data: pointer;
    DataSize: integer;
    constructor Create;
    destructor Destroy; override;
    function FullPath: string; override; // Full path of the key and value
    function DataAsByteArray(ACount: integer): array of byte;
    function DataAsHexStr(ACount: integer): string;
    function DataAsString(ForceBinaryToStr: boolean = False): string; // Returns the "Data" as a string
    function DataAsInteger: integer;
    function DataAsDword: dword;
    function DataAsint64: int64;
    function DataAsUnixDateTime: TDateTime; // Attempts to convert the "Data" to a DateTime
    function DataAsUnixDateTimeStr: string; // Does AsDateTime then formats as a string
    function DataAsFileTimeStr: string;
    function DataAsSystemTime: TSystemTime;
    function DataAsSystemTimeStr: string;
    function DataAsNetworkListDate: string;
    function DataAsTimeZoneName: string;
    function ProcessMRUShellBag(var AShellBagRec: TShellBagMRURecord): boolean;
  end;

  TMyRegistry = class
  private
    FRegEntries: TList; // List of registry files found in the filesystem or registry module - stored as TEntry
    FSearchKeys: TObjectList; // List of keys to search for during scan
    FFoundresults: TObjectList;  // List of results after a scan
    FControlSets: TObjectList; // List of controls sets for each registry file in FRegEntries. Only used for SYSTEM hives.
    function GetRegEntry(Index: integer): TEntry;
    function GetFoundKey(Index: integer): TRegSearchresult;
    function GetControlSetInfo(Index: integer): TControlSetInfo;
    procedure SetControlSetInfo(Index: integer; AValue: TControlSetInfo);
    function GetFoundCount: integer;
    function GetEntryCount: integer;
    function FindKey(RegEntry : TEntry; EntryReader : TEntryReader; RawReg : TRawRegistry; EntryIdx : integer; SearchKey : TRegSearchKey) : integer;

  public
    constructor Create;
    destructor Destroy; override;
    function AddKey(AHive: TRegHiveType; AControlSet: integer; ADataType : TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir : string = ''): integer;
    function FindKeys: integer;
    function FindRegFilesByDataStore(const ADataStore: string; aRegEx: string): integer; // Locate registry files in a datastore
    function FindRegFilesByDevice(ADevice: TEntry; ARegEx: string): integer; // Locate registry files on a device
    function FindRegFilesByInList(const ADataStore: string; aRegEx: string): integer; // Locate registry files using the CLI inList
    function GetHiveType(AEntry: TEntry): TRegHiveType;
    function HiveTypeToStr(AHive: TRegHiveType): string;
    procedure AddRegFile(ARegEntry: TEntry);
    procedure ClearKeys;
    procedure Clearresults;
    procedure UpdateControlSets;
    property ControlSetInfo[Index: integer]: TControlSetInfo read GetControlSetInfo write SetControlSetInfo;
    property EntryCount: integer read GetEntryCount;
    property Found[Index: integer]: TRegSearchresult read GetFoundKey;
    property FoundCount: integer read GetFoundCount;
    property GetEntry[Index: integer]: TEntry read GetRegEntry;
    property RegEntries : TList read FRegEntries;

  end;

  function GetTimeZoneName(AID: integer): string;
  function RPad(const AString: string; AChars: integer): string;
  function UnixTimeToDateTime(UnixTime: Integer): TDateTime;
  procedure BookMark(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
  procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
  procedure ConsoleLog(ALogType: TLogType; AString: string); overload;
  procedure ConsoleLog(AString: string); overload;
  procedure ConsoleLogBM(AString: string);
  procedure ConsoleLogMemo(AString: string);
  procedure ConsoleSection(ASection: string);

var
  Memo_StringList:              TStringList;
  BookmarkComment_StringList:   TStringList;
  ConsoleLog_StringList:        TStringList;

implementation

{ =========== General Global Functions ============ }

function GetTimeZoneName(AID: integer): string;
begin
  Result := '';
  case AID of
    460: Result := '(UTC+04:30) Kabul';
    461: Result := 'Afghanistan Daylight Time';
    462: Result := 'Afghanistan Standard Time';
    220: Result := '(UTC-09:00) Alaska';
    221: Result := 'Alaskan Daylight Time';
    222: Result := 'Alaskan Standard Time';
    390: Result := '(UTC+03:00) Kuwait, Riyadh';
    391: Result := 'Arab Daylight Time';
    392: Result := 'Arab Standard Time';
    440: Result := '(UTC+04:00) Abu Dhabi, Muscat';
    441: Result := 'Arabian Daylight Time';
    442: Result := 'Arabian Standard Time';
    400: Result := '(UTC+03:00) Baghdad';
    401: Result := 'Arabic Daylight Time';
    402: Result := 'Arabic Standard Time';
    840: Result := '(UTC-03:00) Buenos Aires';
    841: Result := 'Argentina Daylight Time';
    842: Result := 'Argentina Standard Time';
    80: Result := '(UTC-04:00) Atlantic Time (Canada)';
    81: Result := 'Atlantic Daylight Time';
    82: Result := 'Atlantic Standard Time';
    650: Result := '(UTC+09:30) Darwin';
    651: Result := 'AUS Central Daylight Time';
    652: Result := 'AUS Central Standard Time';
    670: Result := '(UTC+10:00) Canberra, Melbourne, Sydney';
    671: Result := 'AUS Eastern Daylight Time';
    672: Result := 'AUS Eastern Standard Time';
    447: Result := '(UTC+04:00) Baku';
    448: Result := 'Azerbaijan Daylight Time';
    449: Result := 'Azerbaijan Standard Time';
    10: Result := '(UTC-01:00) Azores';
    11: Result := 'Azores Daylight Time';
    12: Result := 'Azores Standard Time';
    140: Result := '(UTC-06:00) Saskatchewan';
    141: Result := 'Canada Central Daylight Time';
    142: Result := 'Canada Central Standard Time';
    20: Result := '(UTC-01:00) Cape Verde Is.';
    21: Result := 'Cape Verde Daylight Time';
    22: Result := 'Cape Verde Standard Time';
    450: Result := '(UTC+04:00) Yerevan';
    451: Result := 'Caucasus Daylight Time';
    452: Result := 'Caucasus Standard Time';
    660: Result := '(UTC+09:30) Adelaide';
    661: Result := 'Cen. Australia Daylight Time';
    662: Result := 'Cen. Australia Standard Time';
    150: Result := '(UTC-06:00) Central America';
    151: Result := 'Central America Daylight Time';
    152: Result := 'Central America Standard Time';
    510: Result := '(UTC+06:00) Astana, Dhaka';
    511: Result := 'Central Asia Daylight Time';
    512: Result := 'Central Asia Standard Time';
    103: Result := '(UTC-04:00) Manaus';
    104: Result := 'Central Brazilian Daylight Time';
    105: Result := 'Central Brazilian Standard Time';
    280: Result := '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague';
    281: Result := 'Central Europe Daylight Time';
    282: Result := 'Central Europe Standard Time';
    290: Result := '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb';
    291: Result := 'Central European Daylight Time';
    292: Result := 'Central European Standard Time';
    720: Result := '(UTC+11:00) Magadan, Solomon Is., New Caledonia';
    721: Result := 'Central Pacific Daylight Time';
    722: Result := 'Central Pacific Standard Time';
    160: Result := '(UTC-06:00) Central Time (US & Canada)';
    161: Result := 'Central Daylight Time';
    162: Result := 'Central Standard Time';
    170: Result := '(UTC-06:00) Guadalajara, Mexico City, Monterrey';
    171: Result := 'Central Daylight Time (Mexico)';
    172: Result := 'Central Standard Time (Mexico)';
    570: Result := '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi';
    571: Result := 'China Daylight Time';
    572: Result := 'China Standard Time';
    250: Result := '(UTC-12:00) International Date Line West';
    251: Result := 'Dateline Daylight Time';
    252: Result := 'Dateline Standard Time';
    410: Result := '(UTC+03:00) Nairobi';
    411: Result := 'E. Africa Daylight Time';
    412: Result := 'E. Africa Standard Time';
    680: Result := '(UTC+10:00) Brisbane';
    681: Result := 'E. Australia Daylight Time';
    682: Result := 'E. Australia Standard Time';
    330: Result := '(UTC+02:00) Minsk';
    331: Result := 'E. Europe Daylight Time';
    332: Result := 'E. Europe Standard Time';
    40: Result := '(UTC-03:00) Brasilia';
    41: Result := 'E. South America Daylight Time';
    42: Result := 'E. South America Standard Time';
    110: Result := '(UTC-05:00) Eastern Time (US & Canada)';
    111: Result := 'Eastern Daylight Time';
    112: Result := 'Eastern Standard Time';
    340: Result := '(UTC+02:00) Cairo';
    341: Result := 'Egypt Daylight Time';
    342: Result := 'Egypt Standard Time';
    470: Result := '(UTC+05:00) Ekaterinburg';
    471: Result := 'Ekaterinburg Daylight Time';
    472: Result := 'Ekaterinburg Standard Time';
    730: Result := '(UTC+12:00) Fiji, Kamchatka, Marshall Is.';
    731: Result := 'Fiji Daylight Time';
    732: Result := 'Fiji Standard Time';
    350: Result := '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius';
    351: Result := 'FLE Daylight Time';
    352: Result := 'FLE Standard Time';
    433: Result := '(UTC+03:00) Tbilisi';
    434: Result := 'Georgian Daylight Time';
    435: Result := 'Georgian Standard Time';
    260: Result := '(UTC) Dublin, Edinburgh, Lisbon, London';
    261: Result := 'GMT Daylight Time';
    262: Result := 'GMT Standard Time';
    50: Result := '(UTC-03:00) Greenland';
    51: Result := 'Greenland Daylight Time';
    52: Result := 'Greenland Standard Time';
    880: Result := '(UTC) Monrovia, Reykjavik';
    271: Result := 'Greenwich Daylight Time';
    272: Result := 'Greenwich Standard Time';
    360: Result := '(UTC+02:00) Athens, Bucharest, Istanbul';
    361: Result := 'GTB Daylight Time';
    362: Result := 'GTB Standard Time';
    230: Result := '(UTC-10:00) Hawaii';
    231: Result := 'Hawaiian Daylight Time';
    232: Result := 'Hawaiian Standard Time';
    490: Result := '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi';
    491: Result := 'India Daylight Time';
    492: Result := 'India Standard Time';
    430: Result := '(UTC+03:30) Tehran';
    431: Result := 'Iran Daylight Time';
    432: Result := 'Iran Standard Time';
    370: Result := '(UTC+02:00) Jerusalem';
    371: Result := 'Jerusalem Daylight Time';
    372: Result := 'Jerusalem Standard Time';
    333: Result := '(UTC+02:00) Amman';
    334: Result := 'Jordan Daylight Time';
    335: Result := 'Jordan Standard Time';
    620: Result := '(UTC+09:00) Seoul';
    621: Result := 'Korea Daylight Time';
    622: Result := 'Korea Standard Time';
    910: Result := '(UTC+04:00) Port Louis';
    911: Result := 'Mauritius Daylight Time';
    912: Result := 'Mauritius Standard Time';
    30: Result := '(UTC-02:00) Mid-Atlantic';
    31: Result := 'Mid-Atlantic Daylight Time';
    32: Result := 'Mid-Atlantic Standard Time';
    363: Result := '(UTC+02:00) Beirut';
    364: Result := 'Middle East Daylight Time';
    365: Result := 'Middle East Standard Time';
    770: Result := '(UTC-03:00) Montevideo';
    771: Result := 'Montevideo Daylight Time';
    772: Result := 'Montevideo Standard Time';
    890: Result := '(UTC) Casablanca';
    891: Result := 'Morocco Daylight Time';
    892: Result := 'Morocco Standard Time';
    190: Result := '(UTC-07:00) Mountain Time (US & Canada)';
    191: Result := 'Mountain Daylight Time';
    192: Result := 'Mountain Standard Time';
    180: Result := '(UTC-07:00) Chihuahua, La Paz, Mazatlan';
    181: Result := 'Mountain Daylight Time (Mexico)';
    182: Result := 'Mountain Standard Time (Mexico)';
    540: Result := '(UTC+06:30) Yangon (Rangoon)';
    541: Result := 'Myanmar Daylight Time';
    542: Result := 'Myanmar Standard Time';
    520: Result := '(UTC+06:00) Almaty, Novosibirsk';
    521: Result := 'N. Central Asia Daylight Time';
    522: Result := 'N. Central Asia Standard Time';
    383: Result := '(UTC+02:00) Windhoek';
    384: Result := 'Namibia Daylight Time';
    385: Result := 'Namibia Standard Time';
    500: Result := '(UTC+05:45) Kathmandu';
    501: Result := 'Nepal Daylight Time';
    502: Result := 'Nepal Standard Time';
    740: Result := '(UTC+12:00) Auckland, Wellington';
    741: Result := 'New Zealand Daylight Time';
    742: Result := 'New Zealand Standard Time';
    70: Result := '(UTC-03:30) Newfoundland';
    71: Result := 'Newfoundland Daylight Time';
    72: Result := 'Newfoundland Standard Time';
    580: Result := '(UTC+08:00) Irkutsk, Ulaan Bataar';
    581: Result := 'North Asia East Daylight Time';
    582: Result := 'North Asia East Standard Time';
    550: Result := '(UTC+07:00) Krasnoyarsk';
    551: Result := 'North Asia Daylight Time';
    552: Result := 'North Asia Standard Time';
    90: Result := '(UTC-04:00) Santiago';
    91: Result := 'Pacific SA Daylight Time';
    92: Result := 'Pacific SA Standard Time';
    210: Result := '(UTC-08:00) Pacific Time (US & Canada)';
    211: Result := 'Pacific Daylight Time';
    212: Result := 'Pacific Standard Time';
    213: Result := '(UTC-08:00) Tijuana, Baja California';
    214: Result := 'Pacific Daylight Time (Mexico)';
    215: Result := 'Pacific Standard Time (Mexico)';
    870: Result := '(UTC+05:00) Islamabad, Karachi';
    871: Result := 'Pakistan Daylight Time';
    872: Result := 'Pakistan Standard Time';
    300: Result := '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris';
    301: Result := 'Romance Daylight Time';
    302: Result := 'Romance Standard Time';
    420: Result := '(UTC+03:00) Moscow, St. Petersburg, Volgograd';
    421: Result := 'Russian Daylight Time';
    422: Result := 'Russian Standard Time';
    830: Result := '(UTC-03:00) Georgetown';
    831: Result := 'SA Eastern Daylight Time';
    832: Result := 'SA Eastern Standard Time';
    120: Result := '(UTC-05:00) Bogota, Lima, Quito, Rio Branco';
    121: Result := 'SA Pacific Daylight Time';
    122: Result := 'SA Pacific Standard Time';
    790: Result := '(UTC-04:00) La Paz';
    791: Result := 'SA Western Daylight Time';
    792: Result := 'SA Western Standard Time';
    240: Result := '(UTC-11:00) Midway Island, Samoa';
    241: Result := 'Samoa Daylight Time';
    242: Result := 'Samoa Standard Time';
    560: Result := '(UTC+07:00) Bangkok, Hanoi, Jakarta';
    561: Result := 'SE Asia Daylight Time';
    562: Result := 'SE Asia Standard Time';
    590: Result := '(UTC+08:00) Kuala Lumpur, Singapore';
    591: Result := 'Malay Peninsula Daylight Time';
    592: Result := 'Malay Peninsula Standard Time';
    380: Result := '(UTC+02:00) Harare, Pretoria';
    381: Result := 'South Africa Daylight Time';
    382: Result := 'South Africa Standard Time';
    530: Result := '(UTC+05:30) Sri Jayawardenepura';
    531: Result := 'Sri Lanka Daylight Time';
    532: Result := 'Sri Lanka Standard Time';
    600: Result := '(UTC+08:00) Taipei';
    601: Result := 'Taipei Daylight Time';
    602: Result := 'Taipei Standard Time';
    690: Result := '(UTC+10:00) Hobart';
    691: Result := 'Tasmania Daylight Time';
    692: Result := 'Tasmania Standard Time';
    630: Result := '(UTC+09:00) Osaka, Sapporo, Tokyo';
    631: Result := 'Tokyo Daylight Time';
    632: Result := 'Tokyo Standard Time';
    750: Result := '(UTC+13:00) Nukualofa';
    751: Result := 'Tonga Daylight Time';
    752: Result := 'Tonga Standard Time';
    130: Result := '(UTC-05:00) Indiana (East)';
    131: Result := 'US Eastern Daylight Time';
    132: Result := 'US Eastern Standard Time';
    200: Result := '(UTC-07:00) Arizona';
    201: Result := 'US Mountain Daylight Time';
    202: Result := 'US Mountain Standard Time';
    930: Result := '(UTC) Coordinated Universal Time';
    931: Result := 'Coordinated Universal Time';
    932: Result := 'Coordinated Universal Time';
    810: Result := '(UTC-04:30) Caracas';
    811: Result := 'Venezuela Daylight Time';
    812: Result := 'Venezuela Standard Time';
    700: Result := '(UTC+10:00) Vladivostok';
    701: Result := 'Vladivostok Daylight Time';
    702: Result := 'Vladivostok Standard Time';
    610: Result := '(UTC+08:00) Perth';
    611: Result := 'W. Australia Daylight Time';
    612: Result := 'W. Australia Standard Time';
    310: Result := '(UTC+01:00) West Central Africa';
    311: Result := 'W. Central Africa Daylight Time';
    312: Result := 'W. Central Africa Standard Time';
    320: Result := '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna';
    321: Result := 'W. Europe Daylight Time';
    322: Result := 'W. Europe Standard Time';
    860: Result := '(UTC+05:00) Tashkent';
    481: Result := 'West Asia Daylight Time';
    482: Result := 'West Asia Standard Time';
    710: Result := '(UTC+10:00) Guam, Port Moresby';
    711: Result := 'West Pacific Daylight Time';
    712: Result := 'West Pacific Standard Time';
    640: Result := '(UTC+09:00) Yakutsk';
    641: Result := 'Yakutsk Daylight Time';
    642: Result := 'Yakutsk Standard Time';
  end;
end;

//------------------------------------------------------------------------------
// Function: Right Pad v2
//------------------------------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
 AChars := AChars - Length(AString);
 if AChars > 0 then
   Result := AString + StringOfChar(' ', AChars)
 else
   Result := AString;
end;

// Unix Time to Date Time ------------------------------------------------------
function UnixTimeToDateTime(UnixTime: Integer): TDateTime;
begin
  Result := EncodeDate(1970, 1, 1) + (UnixTime div 86400);
  Result := Result + ((UnixTime mod 86400) / 86400);
end;

// Add time and date to the console log messages - Message Log Only-------------
procedure ConsoleLog(AString: string); overload;
begin
  Progress.Log(AString);
  if assigned(ConsoleLog_StringList) then
    if ConsoleLog_StringList.Count < 5000 then
      ConsoleLog_StringList.Add(AString);
end;

// Add time and date to the console log messages - Message Log and results Mem Box
procedure ConsoleLogMemo(AString: string);
begin
  if assigned(Memo_StringList) then
    if Memo_StringList.Count < 5000 then
      Memo_StringList.Add(AString); // no time and date for the results memo
end;

// Add time and date to the console log messages - Message Log, results Mem Box, Bookmark Comment
procedure ConsoleLogBM(AString: string);
begin
  if assigned(BookmarkComment_StringList) then
    if Memo_StringList.Count < 5000 then
      BookmarkComment_StringList.Add(AString); // no time and date for the results memo
end;

// Add time and date to the console log messages - Message Log Only-------------
procedure ConsoleLog(ALogType: TLogType; AString: string); overload;
begin
  case ALogType of
    ltMemo:
        ConsoleLogMemo(AString);
    ltBM:
        ConsoleLogBM(AString);
    ltMessagesMemo:
      begin
        ConsoleLog(AString);
        ConsoleLogMemo(AString);
      end;
    ltMessagesMemoBM:
      begin
        ConsoleLog(AString);
        ConsoleLogMemo(AString);
        ConsoleLogBM(AString);
      end;
  else
    ConsoleLog(AString);
  end;
end;

procedure BookMark(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
var
  bCreate: Boolean;
  bmParent, bmNew: TEntry;
  Abm_Source_str2: string;
begin
  if bl_AutoBookmark_results then
  begin
    Abm_Source_str2 := StringReplace(Abm_Source_str, '\', '-', [rfReplaceAll]);
    // Set the next folder to be then device name + registry file path (ensures multiple registry files on the same system are reported) *
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + ADevice + '\' + BMF_REGISTRY + '\' + UpperCase(Abmf_Hive_Name) + '\' + Abmf_Key_Group + '\' + Abm_Source_str2, bCreate);
    if bCreate then 
      UpdateBookmark(bmParent, Abm_Source_str);
    bCreate := True;
    bmNew := FindBookmarkByName(bmParent, Abmf_Key_Name, bCreate);
    UpdateBookmark(bmNew, AComment);
  end;
end;

procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
var
  bCreate: Boolean;
  bmParent: TEntry;
  DeviceEntry: TEntry;
begin
  if (assigned(bmdEntry)) and (Progress.isRunning) then
  begin
    DeviceEntry := GetDeviceEntry(bmdEntry);
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + DeviceEntry.EntryName + '\Device', bCreate);
    if assigned(bmparent) and bCreate then
      UpdateBookmark(bmParent, AComment);
    if assigned(bmparent) and ABookmarkEntry and not(IsItemInBookmark(bmParent,bmdEntry)) then
      AddItemsToBookmark(bmParent, DATASTORE_FILESYSTEM, bmdEntry, AFileComment);
  end;
end;

procedure ConsoleSection(ASection: string);
begin
  //ConsoleLog(ltMessagesMemo, ' ');
  ConsoleLog(ltMessagesMemo, Stringofchar('=', CHAR_LENGTH));
  ConsoleLog(ltMessagesMemo, '*** ' + ASection + ' ***');
end;


//------ { TRegSearchresult Class } --------------------------------------------

function TRegSearchresultKey.FullPath : string;
begin
  Result := '';
  if (length(KeyPath) > 0) and (length(KeyName) > 0) then
  begin
    if KeyPath[length(KeyPath)] = '\' then
      Result := KeyPath + KeyName
    else
      Result := KeyPath + '\' + KeyName;
  end;
end;

function TRegSearchresultKey.GetChildKeys: TStringList;
var
  EntryReader : TEntryReader;
  ChildKeys: TRawRegistry;
begin
  Result := nil;
  if assigned(Entry) then
  begin
    EntryReader:= TEntryReader.Create;
    if EntryReader.OpenData(Entry) then
    begin
      ChildKeys := TRawRegistry.Create(EntryReader, False);
      if ChildKeys.OpenKey(FullPath) then
      begin
        Result := TStringList.Create;
        Result.Clear;
        ChildKeys.GetKeyNames(Result);
      end;
      ChildKeys.free;
    end;
    EntryReader.free;
  end;
end;

constructor TRegSearchresultValue.Create;
begin
  inherited;
  Data := nil;
end;

destructor TRegSearchresultValue.Destroy;
begin
  if Data <> nil then
     FreeMem(Data, DataSize);
  inherited;
end;

function TRegSearchresultValue.FullPath: string;
begin
  Result := '';
  if (length(KeyPath) > 0) and (length(Name) > 0) then
  begin
    if KeyPath[length(KeyPath)] = '\' then
      Result := KeyPath + Name
    else
      Result := KeyPath + '\' + Name;
  end;
end;

// Returns an array of bytes from the Data block, for ACount bytes -------------
function TRegSearchresultValue.DataAsByteArray(ACount: integer): array of byte;
begin
  Result := nil;
  if (DataSize >= ACount) then
  begin
    try
      setlength(Result, ACount);
      move(Data^, Result[0], ACount);
    except
      Result := nil;
    end;
  end;
end;

// Returns key value as a string (tries to convert to str) ---------------------
function TRegSearchresultValue.DataAsString(ForceBinaryToStr: boolean): string;
var
  ba: array of byte;
begin
  Result := '';
  try
    if ForceBinaryToStr then
    begin
      setlength(ba, DataSize + 2); // Add extra two bytes to force binary to be null terminated
                                   // Binary reg values that contin unicode do not always have the terminating bytes
      move(Data^, ba[0], DataSize);
      Result := PWideChar(@ba[0]);
    end
    else
    begin
      case DataType of
        rdString, rdExpandString:
          begin
            setlength(ba, DataSize + 2); // Terminator bytes added just in case
            move(Data^, ba[0], DataSize);
            Result := PWideChar(@ba[0]);
          end;
        rdInteger:
          Result := IntToStr(DataAsInteger);
        rdBinary, rdNone:
          Result := DataAsHexStr(1024 {DataSize});
      end;
    end;
  except
    Result := '';
  end;
end;

// Returns a 32 bit signed LE integer ------------------------------------------
function TRegSearchresultValue.DataAsInteger: integer;
begin
  try
    if (DataSize >= 4) then
      move(Data^, Result, 4);
  except
    Result := -1;
  end;
end;

// Returns a 32 bit unsigned LE double word ------------------------------------
function TRegSearchresultValue.DataAsDword: Dword;
begin
  try
    if (DataSize >= 4) then
      move(Data^, Result, 4);
  except
    Result := 0;
  end;
end;

// Returns a 64 bit signed LE int64 --------------------------------------------
function TRegSearchresultValue.DataAsint64: int64;
begin
  Result := -1;
  try
    if (DataSize >= 8) then
      move(Data^, Result, 8);
  except
    Result := -1;
  end;
end;

// Returns a Hex dump of binary data -------------------------------------------
function TRegSearchresultValue.DataAsHexStr(ACount: integer): string;
var
  ba: array of byte;
  abyte: byte;
  i: integer;
begin
  Result := '';
  ba := DataAsByteArray(min(DataSize, ACount));
  for i := 0 to length(ba) - 1 do
  begin
    if not Progress.isRunning then break;
    aByte := ba[i];
    Result := Result + IntToHex(aByte, 2) + ' ';
  end;
end;

// Returns Unix date time ------------------------------------------------------
function TRegSearchresultValue.DataAsUnixDateTime: TDateTime;
begin
  Result := UnixTimeToDateTime(DataAsInteger);
end;

// Returns Unix Data Time as a string ------------------------------------------
function TRegSearchresultValue.DataAsUnixDateTimeStr: string;
var
  dt: TDateTime;
begin
  Result := '';
  dt := DataAsUnixDateTime;
  if dt > 0 then
    Result := DateTimeToStr(dt) + ' UTC';
end;

// Returns SystemTime  ---------------------------------------------------------
function TRegSearchresultValue.DataAsSystemTime: TSystemTime;
begin
  Result.wYear := 0;
  Result.wMonth := 0;
  Result.wDayOfWeek := 0;
  Result.wDay := 0;
  Result.wHour := 0;
  Result.wMinute := 0;
  Result.wSecond := 0;
  Result.wMillisecond := 0;
  try
    if (DataSize >= sizeof(Result)) then
      move(Data^, Result, sizeof(Result));
  except
    Result.wYear := 0;
    Result.wMonth := 0;
    Result.wDayOfWeek := 0;
    Result.wDay := 0;
    Result.wHour := 0;
    Result.wMinute := 0;
    Result.wSecond := 0;
    Result.wMillisecond := 0;
  end;
end;

// Returns System Time as string -----------------------------------------------
function TRegSearchresultValue.DataAsSystemTimeStr: string;
begin
  try
    Result := DateTimeToStr(SystemTimeToDateTime(DataAsSystemTime));
  except
    Result := '';
  end;
end;

// Returns FileTime as a string ------------------------------------------------
function TRegSearchresultValue.DataAsFileTimeStr: string;
var
  aFileTime : TFileTime;
begin
  try
    if (DataSize >= 8) then
      move(Data^, aFileTime, 8);
    Result := FileTimeToString(aFileTime);
  except
    Result := '';
  end;
end;

function TRegSearchresultValue.DataAsNetworkListDate: string;
var
  ba : array of byte;
begin
  Result := '{not converted}';
  setLength(ba,16);
  try
    if (DataSize = 16) then
    begin
      move(Data^, ba[0], 16);
      Result := IntToStr((ba[1] * 256) + ba[0]) + '-' + IntToStr(ba[2]) + '-' + IntToStr(ba[6]) + ' ' + IntToStr(ba[8]) + ':' + IntToStr(ba[10]) + ':' + IntToStr(ba[12]);
    end;
  except
    Result := '';
  end;
  setLength(ba,0);
end;

// Convert @tzres.dll,-841
function TRegSearchresultValue.DataAsTimeZoneName: string;
var
  tmpstr: string;
  id: integer;
begin
  Result := '';
  tmpstr := DataAsString;
  if length(tmpstr) > 12 then
  begin
    if pos('@tzres.dll,', tmpstr) = 1 then
    begin
      tmpstr := StringReplace(tmpstr, '@tzres.dll,', '', [rfReplaceAll, rfIgnoreCase]);
      id := abs(StrToInt(tmpstr));
      Result := GetTimeZoneName(id);
    end;
  end;
end;

function TRegSearchresultValue.ProcessMRUShellBag(var AShellBagRec: TShellBagMRURecord): boolean;
var
  struct_size: word;
  bagData : array of byte;
  startpos : integer;
begin
  Result := False;
  bagData := DataAsByteArray(DataSize);
  if length(bagData) < 10 then
    Exit;

  AShellBagRec.DisplayName := PWideChar(@bagData[0]);
  startpos := length(AShellBagRec.DisplayName)*2+2;

  // Read length of structure
  struct_size := pword(@bagData[startpos])^;
  // Progress.Log('struc_size = '  + IntToStr(struct_size));
  // ConsoleLog('struct_size: ' + IntToStr(struct_size));
  AShellBagRec.mru_type := pbyte(@bagData[startpos + 2])^;

  case AShellBagRec.mru_type of
    $31:
      AShellBagRec.TypeAsString := 'Folder';
    $C3:
      AShellBagRec.TypeAsString := 'Remote Share';
    $41:
      AShellBagRec.TypeAsString := 'Windows Domain';
    $42:
      AShellBagRec.TypeAsString := 'Computer Name';
    $46:
      AShellBagRec.TypeAsString := 'Microsoft Windows Network';
    $47:
      AShellBagRec.TypeAsString := 'Entire Network';
    $1F:
      AShellBagRec.TypeAsString := 'System Folder';
    $2F:
      AShellBagRec.TypeAsString := 'Volume';
    $32:
      AShellBagRec.TypeAsString := 'File';
    $48:
      AShellBagRec.TypeAsString := 'My Documents';
    $00:
      AShellBagRec.TypeAsString := 'Variable';
    $B1:
      AShellBagRec.TypeAsString := 'File Entry';
    $71:
      AShellBagRec.TypeAsString := 'Control Panel';
    $61:
      AShellBagRec.TypeAsString := 'URI';
    $3A:
      AShellBagRec.TypeAsString := 'File';
    $50:
      AShellBagRec.TypeAsString := 'My Computer';
    $60:
      AShellBagRec.TypeAsString := 'Recycle Bin';
    $78:
      AShellBagRec.TypeAsString := 'Recycle Bin';
    $58:
      AShellBagRec.TypeAsString := 'My Network Places';
  else
    AShellBagRec.TypeAsString := 'Unknown';
  end;

  // mru_type_dict = {'\x31':'Folder','\xc3':'Remote Share','\x41':'Windows Domain','\x42':'Computer Name',
  // '\x46':'Microsoft Windows Network', '\x47':'Entire Network','\x1f':'System Folder',
  // '\x2f':'Volume','\x32':'Zip File', '\x48':'My Documents', '\x00':'Variable',
  // '\xb1':'File Entry', '\x71':'Control Panel', '\x61':'URI'}
  //
  // dict_file_type = {'\x32':'FILE','\x31':'FOLDER','\x3a':'FILE'}           # Known File Type Dictionary
  //
  // dict_sys_type = {'\x50':'My Computer', '\x60':'Recycle Bin', '\x78':'Recycle Bin', '\x58':'My Network Places',
  // '\x48':'My Documents', '\x42':'Application File Dialogue'}

  AShellBagRec.shortname := 'short name here';
  AShellBagRec.longname := 'long name here';
  AShellBagRec.build_path := 'build path here';
  AShellBagRec.accessed := now(); //strtodate('09-09-13');
  AShellBagRec.Created := now(); //strtodate('09-09-13');
  AShellBagRec.modified := now(); //strtodate('09-09-13');
  Result := True;

end;

//------ { TMyRegistry Class } -------------------------------------------------
constructor TMyRegistry.Create;
begin
  inherited Create;
  FRegEntries := TList.Create;
  FFoundresults := TObjectList.Create;
  FFoundresults.OwnsObjects := True;
  FSearchKeys := TObjectList.Create;
  FSearchKeys.OwnsObjects := True;
  FControlSets := TObjectList.Create;
  FControlSets.OwnsObjects := True;
end;

destructor TMyRegistry.Destroy;
begin
  FControlSets.free;
  FSearchKeys.free;
  FFoundresults.free;
  FRegEntries.free;
  inherited Destroy;
end;

// AddKey ----------------------------------------------------------------------
function TMyRegistry.AddKey(AHive: TRegHiveType; AControlSet: integer; ADataType : TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir : string = ''): integer;
var
  newkey: TRegSearchKey;
begin
  newkey := TRegSearchKey.Create;
  newkey.Hive := AHive;
  newkey.ControlSet := AControlSet;
  newkey.DataType := ADataType;
  newkey.Key := AKey;
  newkey.IncludeChildKeys := AIncludeChildKeys;
  newkey.Value := AValue;
  newkey.BookMarkFolder := BMDir;
  Result := FSearchKeys.Add(newkey);
end;

function TMyRegistry.GetRegEntry(Index: integer): TEntry;
begin
  Result := TEntry(FRegEntries[Index]);
end;

function TMyRegistry.GetFoundKey(Index: integer): TRegSearchresult;
begin
  Result := TRegSearchresult(FFoundresults[Index]);
end;

function TMyRegistry.GetControlSetInfo(Index: integer): TControlSetInfo;
begin
  Result := TControlSetInfo(FControlSets[Index]);
end;

procedure TMyRegistry.SetControlSetInfo(Index: integer; AValue: TControlSetInfo);
begin
  TControlSetInfo(FControlSets[Index]).ActiveCS := AValue.ActiveCS;
  TControlSetInfo(FControlSets[Index]).CurrentCS := AValue.CurrentCS;
  TControlSetInfo(FControlSets[Index]).DefaultCS := AValue.DefaultCS;
  TControlSetInfo(FControlSets[Index]).FailedCS := AValue.FailedCS;
  TControlSetInfo(FControlSets[Index]).LastKnownGoodCS := AValue.LastKnownGoodCS;
end;

function TMyRegistry.GetFoundCount: integer;
begin
  Result := FFoundresults.Count;
end;

function TMyRegistry.GetEntryCount: integer;
begin
  Result := FRegEntries.Count;
end;

procedure TMyRegistry.ClearKeys;
begin
  FSearchKeys.Clear;
end;

procedure TMyRegistry.Clearresults;
begin
  FFoundresults.Clear;
end;

function HiveType(const Value : string) : TRegHiveType;
begin
  if RegexMatch(value, '(^|\\)SOFTWARE$', False) then
    Result := hvSOFTWARE
  else if RegexMatch(value, '(^|\\)SYSTEM$', False) then
    Result := hvSYSTEM
  else if RegexMatch(value, '(^|\\)SAM$', False) then
    Result := hvSAM
  else if RegexMatch(value, '(^|\\)SECURITY$', False) then
    Result := hvSECURITY
  else if RegexMatch(value, '(^|\\)NTUSER\.DAT$', False) then
    Result := hvUSER
  else if RegexMatch(value, '(^|\\)USER\.DAT$', False) then
    Result := hvUSER9X
  else if RegexMatch(value, '(^|\\)SYSTEM\.DAT$', False) then
    Result := hvSYSTEM9X
  else
    Result := hvUNKNOWN;
end;

// Determine Hive Type ---------------------------------------------------------
function TMyRegistry.GetHiveType(AEntry: TEntry): TRegHiveType;
var
  aPropertyTree: TPropertyParent;
  aPropertyNode: TPropertyNode;
  aRootEntry: TPropertyNode;
begin
  Result := hvUNKNOWN;

  if ProcessMetadataProperties(AEntry, aPropertyTree) then
  begin
    if assigned(aPropertyTree) then
    begin
      aRootEntry := aPropertyTree.RootProperty;

      if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
      begin
        aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName('Hive File Name')); //noslz
        if assigned(aPropertyNode) then
        begin
          //ConsoleLog(AEntry.EntryName);

          Result := HiveType(Trim(UpperCase(aPropertyNode.PropDisplayValue)));
          //ConsoleLog('Result: ' + HiveTypeToStr(Result));

          if (Result = hvUNKNOWN) then
          begin
            Result := HiveType(Trim(UpperCase(AEntry.EntryName)));
            //ConsoleLog('Result: ' + HiveTypeToStr(Result));
          end;
        end;{assigned aPropertyNode}
      end;{assigned aRootEntry}
    end;{assigned aPropertyTree}
  end;
end;

// Hive type to string ---------------------------------------------------------
function TMyRegistry.HiveTypeToStr(AHive: TRegHiveType): string;
begin
  case AHive of
    hvSOFTWARE: Result := SOFTWARE_HIVE;
    hvSAM:      Result := SAM_HIVE;
    hvSECURITY: Result := SECURITY_HIVE;
    hvUSER:     Result := USER_HIVE;
    hvSYSTEM:   Result := SYSTEM_HIVE;
    hvUSER9X:   Result := 'USER98ME';
    hvSYSTEM9X: Result := 'SYSTEM98ME';
    hvANY:      Result := ANY_HIVE;
  else
    Result := UNDETERMINED_HIVE;
  end;
end;

// Add a single registry file entry to the searchable list
procedure TMyRegistry.AddRegFile(ARegEntry: TEntry);
var
  EntryReader: TEntryReader;
  NewControlSetInfo: TControlSetInfo;
begin
  if assigned(ARegEntry) then
  begin
    EntryReader := TEntryReader.Create;
    if EntryReader.OpenData(ARegEntry) and (ARegEntry.LogicalSize >= 4096) then
    begin
      if GetHiveType(ARegEntry) <> hvUNKNOWN then
      begin
        FRegEntries.Add(ARegEntry);
        NewControlSetInfo := TControlSetInfo.Create;
        NewControlSetInfo.ActiveCS := csNone;
        NewControlSetInfo.CurrentCS := -1;
        NewControlSetInfo.DefaultCS := -1;
        NewControlSetInfo.FailedCS := -1;
        NewControlSetInfo.LastKnownGoodCS := -1;
        FControlSets.Add(NewControlSetInfo);
      end;
    end;
    EntryReader.free;
  end;
end;

//------------------------------------------------------------------------------
// Function: Locates all registry files
//------------------------------------------------------------------------------
function TMyRegistry.FindRegFilesByDevice(ADevice: TEntry; ARegEx: string): integer;
var
  EntryList: TDataStore;
  Entry: TEntry;
  FileSignatureInfo: TFileTypeInformation;
  aDeterminedFileDriverInfo: TFileTypeInformation;
begin
  Result := 0;
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  try
    Progress.Max := EntryList.Count;
    Progress.CurrentPosition := 1;

    if EntryList.Count <= 0 then
      Exit;

    ConsoleLog('Finding Files For: ' + ADevice.EntryName);

    Entry := EntryList.First;
    while assigned(Entry) and Progress.isRunning do
    begin
      Progress.IncCurrentProgress;
      if GetDeviceEntry(Entry) = ADevice then
      begin
        if not Entry.IsDirectory then // We only want files
        begin
          if RegexMatch(Entry.FullPathName, ARegEx, False) then // Only add those that match the regex
          begin
            aDeterminedFileDriverInfo := Entry.DeterminedFileDriverInfo;
            if (aDeterminedFileDriverInfo.ShortDisplayName = FILESIG_REGISTRY) then  //noslz
              AddRegFile(Entry)
            else if (aDeterminedFileDriverInfo.ShortDisplayName = '') then
            begin
              DetermineFileType(Entry);
              FileSignatureInfo := Entry.DeterminedFileDriverInfo;
              if (FileSignatureInfo.ShortDisplayName = FILESIG_REGISTRY) then
              begin
                AddRegFile(Entry);
              end;
            end;
          end;
        end;
      end;
      Entry := EntryList.Next;
    end;
  finally
    EntryList.free;
  end;
  Result := FRegEntries.Count;
end;

//------------------------------------------------------------------------------
// Function: Make sure the InList and OutList exist
//------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string) : boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    Progress.Log(RPad('Assigned' + SPACE + ListName_str + SPACE + 'with count:', rpad_value) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', rpad_value) + ListName_str);
end;

//------------------------------------------------------------------------------
// Add registry file entries to a searchable list. Add using CLI InList
//------------------------------------------------------------------------------
function TMyRegistry.FindRegFilesByInList(const ADataStore: string; ARegEx: string): integer;
var
  Entry: TEntry;
  FileSignatureInfo: TFileTypeInformation;
  i: integer;
begin
  Progress.Log('Finding registry files using CLI InList...');
  Result := 0;
  Progress.DisplayMessage := 'Finding registry files...';

  // Check that InList and OutList exist, and InList count > 0
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    Exit
  else
  begin
    if InList.Count = 0 then
    begin
      Progress.Log('InList count is zero.' + SPACE + TSWT);
      Exit;
    end;
  end;

  for i := 0 to InList.Count -1 do
  begin
    Entry := TEntry(InList[i]);
    if not Entry.IsDirectory then // We only want files
    begin
      if RegexMatch(Entry.FullPathName, ARegEx, False) then // Only add those that match the regex
      begin
        DetermineFileType(Entry);
        FileSignatureInfo := Entry.DeterminedFileDriverInfo;
        if (FileSignatureInfo.ShortDisplayName = FILESIG_REGISTRY) then
        begin
          AddRegFile(Entry);
          Progress.Log(RPad('Added CLI InList:', rpad_value) + Entry.EntryName + SPACE + 'ID: ' + IntToStr(Entry.ID));
        end;
      end;
    end;
  end;
  Result := FRegEntries.Count;
end;

//------------------------------------------------------------------------------
// Add registry file entries to a searchable list.
//------------------------------------------------------------------------------
function TMyRegistry.FindRegFilesByDataStore(const ADataStore: string; ARegEx: string): integer;
var
  EntryList: TDataStore;
  Entry: TEntry;
  FileSignatureInfo: TFileTypeInformation;
begin
  
  if (CmdLine.Params.Indexof('InList') > -1) then
  begin
    FindRegFilesByInList(ADataStore, ARegEx);
    Exit; 
  end;
  
  Result := 0;
  Progress.DisplayMessage := 'Finding registry files...';
  // Process only those in the registry module
  if ADataStore = DATASTORE_REGISTRY then
  begin
    EntryList := GetDataStore(DATASTORE_REGISTRY);
    try
      Progress.Max := EntryList.Count;
      Progress.CurrentPosition := 1;
      Entry := EntryList.First;
      while assigned(Entry) and Progress.isRunning do
      begin
        Progress.IncCurrentProgress;
        if Entry.ClassName = 'TSentFromEntry' then
        begin
          AddRegFile(Entry);
        end;
        Entry := EntryList.Next;
      end;
    finally
      EntryList.free;
    end;
  end
  else if ADataStore = DATASTORE_FILESYSTEM then
  // else process registry files in the File System module
  begin
    EntryList := GetDataStore(DATASTORE_FILESYSTEM);
    try
      Progress.Max := EntryList.Count;
      Progress.CurrentPosition := 1;
      if EntryList.Count <= 0 then
        Exit;
        
      Entry := EntryList.First;
      while assigned(Entry) and Progress.isRunning do
      begin
        Progress.IncCurrentProgress;
        if not Entry.IsDirectory then // We only want files
        begin
          if RegexMatch(Entry.FullPathName, ARegEx, False) then // Only add those that match the regex
          begin
            DetermineFileType(Entry);
            FileSignatureInfo := Entry.DeterminedFileDriverInfo;
            if (FileSignatureInfo.ShortDisplayName = FILESIG_REGISTRY) then
            begin
              AddRegFile(Entry);
            end;
          end;
        end;
        Entry := EntryList.Next;
      end;
    finally
      EntryList.free;
    end;
  end;
  Result := FRegEntries.Count;
end;

function TMyRegistry.FindKey(RegEntry : TEntry; EntryReader : TEntryReader; RawReg : TRawRegistry; EntryIdx : integer; SearchKey : TRegSearchKey) : integer;
var
  strKeyName : string;
  SubRawReg : TRawRegistry;
  SubSearchKey: TRegSearchKey;
  FoundKey: TRegSearchresultKey;
  FoundValue: TRegSearchresultValue;
  DataInfo: TRegDataInfo;
  bytesread: integer;
  slValues: TStringList;
  slSubKeys: TStringList;
  v, k: integer;
  csi: TControlSetInfo;
begin
  Result := 0;
  strKeyName := SearchKey.Key;

  if (SearchKey.Hive = hvSYSTEM) and (SearchKey.ControlSet <> csNone) then
  begin
    csi := TControlSetInfo(FControlSets[EntryIdx]);
    case SearchKey.ControlSet of
       csCurrent: strKeyName := '\ControlSet00' + IntToStr(csi.ActiveCS) + SearchKey.Key;
    end;
  end;

  slValues := TStringList.Create;
  slSubKeys := TStringList.Create;
  try
    if RawReg.OpenKey(strKeyName) then
    begin
      FoundKey := TRegSearchresultKey.Create;
      FFoundresults.Add(FoundKey);
      Inc(Result);

      FoundKey.SearchKey := SearchKey;
      FoundKey.Entry := RegEntry;
      FoundKey.KeyPath := RawReg.CurrentPath;
      FoundKey.KeyName := RawReg.CurrentKey;
      FoundKey.KeyLastModified := RawReg.GetCurrentKeyDateTime;  // Get the date/time
      FoundKey.EntryIdx := EntryIdx;

      if SearchKey.Value = '*' then
        RawReg.GetValueNames(slValues)
      else
        slValues.Add(SearchKey.Value);

      if SearchKey.IncludeChildKeys
        and RawReg.GetKeyNames(slSubKeys)
        and (slSubKeys.Count > 0) then
      begin
        Debug('FindKeys', 'GetKeyNames: '+ strKeyName + ' - ' + IntToStr(slSubKeys.Count));

        SubRawReg := TRawRegistry.Create(EntryReader, False);
        try
          for k := 0 to slSubKeys.Count - 1 do
          begin
            if not Progress.isRunning then break;
            if SearchKey.IncludeChildKeys then
            begin
              SubSearchKey := TRegSearchKey.Create;
              try
                SubSearchKey.Hive := SearchKey.Hive;
                SubSearchKey.ControlSet := csNone;
                SubSearchKey.DataType := SearchKey.DataType;
                SubSearchKey.Key := strKeyName + '\' + slSubKeys[k];
                SubSearchKey.IncludeChildKeys := True;
                SubSearchKey.Value := SearchKey.Value;
                SubSearchKey.BookMarkFolder := SearchKey.BookmarkFolder;

                Debug('FindKeys', 'Finding Sub Keys: '+ strKeyName + '\' + slSubKeys[k]);
                Result := Result + FindKey(RegEntry, EntryReader, SubRawReg, EntryIdx, SubSearchKey);
              finally
                SubSearchKey.free;
              end;
            end;
          end;
        finally
          SubRawReg.free;
        end;
      end;
    end;

    //==================================================================
    // Search for Value List
    // =================================================================
    for v := 0 to slValues.Count - 1 do
    begin
      if not Progress.isRunning then break;
      //Debug('FindKeys', 'FOUND KEY: '+ Value_StringList[v]);

      if RawReg.OpenKey(strKeyName) and RawReg.GetDataInfo(slValues[v], DataInfo) then
      begin
        FoundValue := TRegSearchresultValue.Create;
        FFoundresults.Add(FoundValue);

        FoundValue.SearchKey := SearchKey;
        FoundValue.Entry := RegEntry;
        FoundValue.KeyPath := strKeyName;
        FoundValue.Name := slValues[v];
        FoundValue.DataType := DataInfo.RegData;
        FoundValue.DataSize := DataInfo.DataSize;
        FoundValue.Data := nil;
        FoundValue.EntryIdx := EntryIdx;

        GetMem(FoundValue.Data, FoundValue.DataSize);
        FillChar(FoundValue.Data^, FoundValue.DataSize, 0);

        bytesread := RawReg.ReadRawData(FoundValue.Name, FoundValue.Data^, FoundValue.DataSize);
        Inc(Result);
      end;
    end;

  finally
    slSubKeys.free;
    slValues.free;
  end;
end;

// Find the registry keys -------------------------------------------------------
function TMyRegistry.FindKeys: integer;
var
  r, k, v: integer;
  RegEntry: TEntry;
  EntryReader: TEntryReader;
  RawReg: TRawRegistry;
  SearchKey: TRegSearchKey;
  HiveType : TRegHiveType;
begin
  Progress.DisplayMessage := 'Finding registry keys...';
  Progress.Max := FRegEntries.Count;
  Progress.CurrentPosition := 1;
  Result := 0;
  FFoundresults.Clear;
  RawReg := nil;

  EntryReader := TEntryReader.Create;
  try
    for r := 0 to FRegEntries.Count - 1 do
    begin
      if not Progress.isRunning then break;
      Progress.IncCurrentProgress;

      RegEntry := GetEntry[r];
      HiveType := GetHiveType(RegEntry); // Determine the type of registry hive

      RawReg := nil;
      try
        for k := 0 to FSearchKeys.Count -1 do
        begin
          if Not Progress.isRunning then Break;

          //if k mod 100 = 0 then
            //Debug('FindKeys', 'SearchKey: '+ IntToStr(k));

          SearchKey := TRegSearchKey(FSearchKeys[k]);

          if (SearchKey.Hive = HiveType) or (SearchKey.Hive = hvANY) then
          begin
            if RawReg = nil then
              if EntryReader.OpenData(RegEntry) then
                RawReg := TRawRegistry.Create(EntryReader, False);

            if RawReg = nil then
              Break;

            Result := Result + FindKey(RegEntry, EntryReader, RawReg, r, SearchKey);
          end;
        end;
      finally
        if RawReg <> nil then
          RawReg.free;
      end;
    end;
  finally
    EntryReader.free;

    v := 0;
    k := 0;
    for r := 0 to FFoundresults.Count -1 do
    begin
      if not Progress.isRunning then break;
      if FFoundresults[r] is TRegSearchresultValue then
        Inc(v);
      if FFoundresults[r] is TRegSearchresultKey then
        Inc(k);
    end;

    ConsoleLog(RPad('FoundValues:', rpad_value) + IntToStr(k));
    ConsoleLog(RPad('FoundKeys:', rpad_value) + IntToStr(v));

  end;
end;

// Update Control Sets in and SYSTEM reg files found ---------------------------
procedure TMyRegistry.UpdateControlSets;
var
  i: integer;
  Regresult: TObject;
  RegresultValue: TRegSearchresultValue;
begin
  ClearKeys;
  Clearresults;
  AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, REGKEY_CURRENT);
  AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, REGKEY_DEFAULT);
  AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, REGKEY_FAILED);
  AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, REGKEY_LASTKNOWNGOOD);
  FindKeys;
  for i := 0 to FoundCount - 1 do
  begin
    if not Progress.isRunning then break;
    Regresult := Found[i];
    if Regresult is TRegSearchresultValue then
    begin
      RegresultValue := TRegSearchresultValue(Regresult);
      if UpperCase(RegresultValue.FullPath) = '\SELECT\CURRENT' then
      begin
        ControlSetInfo[RegresultValue.EntryIdx].CurrentCS := RegresultValue.DataAsinteger;
        ControlSetInfo[RegresultValue.EntryIdx].ActiveCS := ControlSetInfo[RegresultValue.EntryIdx].CurrentCS;
      end
      else if UpperCase(RegresultValue.FullPath) = '\SELECT\DEFAULT' then
        ControlSetInfo[RegresultValue.EntryIdx].DefaultCS := RegresultValue.DataAsInteger
      else if UpperCase(RegresultValue.FullPath) = '\SELECT\FAILED' then
        ControlSetInfo[RegresultValue.EntryIdx].FailedCS := RegresultValue.DataAsInteger
      else if UpperCase(RegresultValue.FullPath) = '\SELECT\LASTKNOWNGOOD' then
        ControlSetInfo[RegresultValue.EntryIdx].LastKnownGoodCS := RegresultValue.DataAsinteger;
    end;
  end;
  ClearKeys;
  Clearresults;
end;

function MyFormatDateTime(ADateTime: TDateTime; isUTC: boolean): string;
var
  str: string;
begin
  Result := '';
  //ConsoleLog(inttohex(int64(ADateTime),8));
  if ADateTime = 0 then
    Result := '{Never}'
  else
  begin
    if isUTC then
      str := ' [UTC]'
    else
      str := ' [Local]';
    Result := FormatDateTime('dd-mmm-yyyy hh:nn:ss', ADateTime) + str;
  end;
end;

procedure ProcessresultValue(Re: TDIPerlRegEx; RegTerm : string; RegresultValue : TRegSearchresultValue; theName : string; ATList : TList);
var
  TempClass: TTempClassInfo;
begin
  if (not assigned(Re)) or (RegTerm = '') or (not assigned(RegresultValue)) or (not assigned(ATList)) then
     Exit;
  Re.MatchPattern := RegTerm;
  Re.SetSubjectStr(RegresultValue.FullPath);
  if Re.Match(0) >= 0 then
  begin
   TempClass := TTempClassInfo.Create;
   TempClass.TempName         := theName;
   TempClass.Device           := GetDeviceEntry(RegresultValue.Entry);
   TempClass.KeyPath          := RegresultValue.KeyPath;
   TempClass.KeyFullPath      := RegresultValue.FullPath;

   //Progress.Log(RegresultValue.FullPath);

   TempClass.RegistryFullPath := RegresultValue.Entry.FullPathName;
   TempClass.BookmarkFolder   := RegresultValue.SearchKey.BookMarkFolder;
   TempClass.KeyName          := RegresultValue.Name;
   TempClass.HiveType         := RegresultValue.Entry.EntryName;
   ATList.Add(TempClass);
  end;
end;

procedure Outputresult(ATList : TList; AHive_Type: string; ABMF_Key_Group: string; FieldName : string);
var
  BM_Source_str: string;
  BMC_Formatted: string;
  BMF_Key_Name: string;
  BMF_Key_Path: string;
  Device: string;
  n: integer;
  rpad_value: integer;
begin
  if (not assigned(ATList)) then
     Exit;
  if not Progress.isRunning then
     Exit;
  If (assigned(ATList) and (ATList.Count > 0)) then
  begin
    ConsoleSection(ABMF_Key_Group);
    for n := 0 to ATList.Count - 1 do
    begin
      if not Progress.isRunning then Exit;

      Device := '';
      BMF_Key_Path := '';
      BMF_Key_name := '';
      BM_Source_str := '';

      Device        := TDataEntry(TTempClassInfo(ATList[n]).Device).EntryName;
      BMF_Key_Path  := TTempClassInfo(ATList[n]).KeyPath;
      BMF_Key_Name  := TTempClassInfo(ATList[n]).KeyName;
      BM_Source_str := TTempClassInfo(ATList[n]).RegistryFullPath;

      ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemo, RPad('Registry File:', rpad_value) + BM_Source_str);
      ConsoleLog(ltMessagesMemo, RPad('Key:', rpad_value) + BMF_Key_Path + '\' + BMF_Key_Name);

      BookmarkComment_StringList.clear;
      ConsoleLog(ltMessagesMemo, RPad(FieldName, rpad_value) + TTempClassInfo(ATList[n]).Tempname);
      ConsoleLog(ltBM,           RPad('', rpad_value) + TTempClassInfo(ATList[n]).TempName);
      BMC_Formatted := BookmarkComment_StringList.Text;

      if ABMF_Key_Group = BMF_TIMEZONEINFORMATION then BM_Source_str := BM_Source_str + BMF_Key_Path;
      BookMark(Device, AHive_Type, ABMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

    end;
  end;
end;

var
  // Boolean
  bl_EvidenceModule:            boolean;
  bl_FSNtfsDisLastAccUp:        boolean;
  bl_FSRecentDocs:              boolean;
  bl_FSSystemRoot:              boolean;
  bl_FSTimeZone:                boolean;
  bl_FSTriage:                  boolean;
  bl_FSUninstallPrograms:       boolean;
  bl_FSWirelessNetworks:        boolean;
  bl_GUIShow:                   boolean;
  bl_RegModule:                 boolean;
  bl_ScriptsModule:             boolean;
  bl_UseInList:                 boolean;


  // DataStores
  BookmarksEntryList:           TDataStore;
  EvidenceEntryList:            TDataStore;

  // Entries
  CurrentDevice:                TEntry;
  dEntry:                       TEntry;
  DeviceListEntry:              TEntry;
  Entry:                        TEntry;
  EntryReader:                  TEntryReader;

  // Info
  Network:                      TNetworkInfo;
  Printer:                      TPrinterInfo;
  Email:                        TEmailInfo;
  TimeZone:                     TTimeZoneInfo;
  UninstallPrograms:            TUninstallProgramsInfo;
  USBStor:                      TUSBStorInfo;
  RecentDocs:                   TRecentDocsInfo;

  // Integers
  bytesread:                    integer;
  i,k,n,x,y:                    integer;
  nid:                          integer;
  regfiles, regcount:           integer;
  StartingBookmarkFolder_Count: integer;
  tildpos:                      integer;

  // Regex
  Re:                           TDIPerlRegEx;

  // Registry
  DataInfo:                     TRegDataInfo;
  FoundValue:                   TRegSearchresultValue;
  RawRegSubKeyValues:           TRawRegistry;
  Reg:                          TMyRegistry;
  Regresult:                    TRegSearchresult;
  RegresultKey:                 TRegSearchresultKey;
  RegresultValue:               TRegSearchresultValue;

  // Strings
  BM_Source_str:                string;
  BMC_Formatted:                string;
  BMF_Key_Group:                string;
  BMF_Key_Name:                 string;
  BookmarkComment:              string;
  Device:                       string;
  mstr:                         string;
  Param:                        string;
  program_name_str:             string;
  source_str:                   string;
  str_RegFiles_Regex:           string;
  The_Source_Str:               string;
  valname:                      string;

  // Starting Checks
  bContinue:                    boolean;
  CaseName:                     string;
  FEX_Executable:               string;
  FEX_Version:                  string;
  StartCheckEntry:              TEntry;
  StartCheckDataStore:          TDataStore;

  // StringLists
  SubKeyValueList:              TStringList;
  UninstallPrograms_StringList: TStringList;

  // TList
  CompInfDefaultDomaInList:     TList;
  CompInfDefaultUserList:       TList;
  CompInfInstallDateList:       TList;
  CompInfProductIDList:         TList;
  CompInfProductNameList:       TList;
  CompInfRegOrgList:            TList;
  CompInfRegOwnerList:          TList;
  ComputerNameList:             TList;
  ConnectedPrintersList:        TList;
  csCurrentList:                TList;
  csDefaultList:                TList;
  csFailedList:                 TList;
  csLastKnownGoodList:          TList;
  DeviceList:                   TList;
  DeviceToSearchList:           TList;
  EmailList:                    TList;
  NetworkList:                  TList;
  NTFSDisLastAccUpList:         TList;
  ShutdownTimeList:             TList;
  SystemRootList:               TList;
  TempClassList:                TList;
  tzActiveTimeBiasList:         TList;
  tzBiasList:                   TList;
  tzDaylightBiasList:           TList;
  tzDaylightNameList:           TList;
  tzDaylightStartList:          TList;
  tzDynamicList:                TList;
  tzStandardBiasList:           TList;
  tzStandardNameList:           TList;
  tzStandardStartList:          TList;
  tzTimeZoneKeyNameList:        TList;
  RecentDocsList:               TList;
  TimeZoneList:                 TList;
  UninstallProgramsList:        TList;
  USBStorList:                  TList;
  shellbagrec:                  TShellBagMRURecord;
  Registry_Bookmark_Folder_Count: integer;
  bmfolder: TEntry;

label
  Finish;
//==============================================================================
// Start of Script
//==============================================================================
begin
  BookmarkComment_StringList := nil;
  ConsoleLog_StringList := nil;
  Memo_StringList := nil;
  ConsoleLog(SCRIPT_NAME + ' started...');
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessage := 'Starting...';

  // ===========================================================================
  // Starting Checks
  // ===========================================================================
  // 1. Check to see if the FileSystem module is present
  bContinue := True;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      ConsoleLog(DATASTORE_FILESYSTEM + ' module not located. The script will terminate.');
      bContinue := False;
      Exit;
    end;
    // 2. Check to see if a case is present
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case. The script will terminate.');
      bContinue := False;
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    // 3. Log case details
    FEX_Executable := GetApplicationDir + 'forensicexplorer.exe';
    FEX_Version := GetFileVersion(FEX_Executable);
    ConsoleLog(Stringofchar('~', CHAR_LENGTH));
    ConsoleLog(RPad('Case Name:', rpad_value) + CaseName);
    ConsoleLog(RPad('Script Name:', rpad_value) + SCRIPT_NAME);
    ConsoleLog(RPad('Date Run:', rpad_value) + DateTimeToStr(now));
    ConsoleLog(RPad('FEX Version:', rpad_value) + FEX_Version);
    ConsoleLog(Stringofchar('~', CHAR_LENGTH));
    // 4. Check to see if there are files in the File System Module
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module. The script will terminate.');
      bContinue := False;
      Exit;
    end;
    // 5. Exit if user cancels
    if not Progress.isRunning then
    begin
      ConsoleLog('Canceled by user.');
      bContinue := False;
    end;
  finally
    StartCheckDataStore.free;
  end;
  // 6. Continue?
  if Not bContinue then
    Exit;
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  //============================================================================
  // Setup results Header
  //============================================================================
  Memo_StringList := TStringList.Create;
  ConsoleLog_StringList := TStringList.Create;
  FEX_Executable := GetApplicationDir + 'forensicexplorer.exe';
  FEX_Version := GetFileVersion(FEX_Executable);

  ConsoleLog(ltMessagesMemo, (Stringofchar('-', CHAR_LENGTH)));
  
  ConsoleLog(RPad('~ Script:', rpad_value) + SCRIPT_NAME);
  ConsoleLog((RPad('~ Parse:', rpad_value) + 'Registry'));
  ConsoleLog(ltMemo, (RPad('Parse:', rpad_value) + 'Registry'));
  ConsoleLog(RPad('~ Date:', rpad_value) + DateTimeToStr(now));
  ConsoleLog(RPad('~ FEX Version', rpad_value) + FEX_Version);
  ConsoleLog(RPad('~ Case Name:', rpad_value) + CaseName);  

  //============================================================================
  // Device List - Add the evidence items
  //============================================================================
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  ConsoleLog('Device list:');
  DeviceList := TList.Create;
  EvidenceEntryList := GetDataStore(DATASTORE_EVIDENCE);
  dEntry := EvidenceEntryList.First; // Get the first entry
  while assigned(dEntry) and Progress.isRunning do
  begin
    if dEntry.IsDevice then
    begin
      DeviceList.add(dEntry);
      ConsoleLog(RPad(HYPHEN + 'Added to Device List:', rpad_value) + dEntry.EntryName);
      bmFolder := FindBookmarkByName(BMF_TRIAGE + '\Device' + dEntry.EntryName);
      if assigned(bmFolder) and not IsItemInBookmark(bmFolder, dEntry) then
        BookMarkDevice('', '\Device', '', dEntry, '', True);
    end;
    dEntry := EvidenceEntryList.Next;
  end;
  ConsoleLog(RPad('Device list count:', rpad_value) + IntToStr(DeviceList.Count));
  CurrentDevice := nil;

  //============================================================================
  // Parameters & Logging
  //============================================================================
  Param := '';
  if (CmdLine.ParamCount > 0) then
  begin
    ConsoleLog(Stringofchar('-', CHAR_LENGTH));
    ConsoleLog(RPad('Parameters received:', rpad_value) + IntToStr(CmdLIne.ParamCount));

    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      ConsoleLog(RPad(' - Param ' + IntToStr(i) + ':', rpad_value) + cmdline.params[i]);
      Param := Param + '"' + cmdline.params[i] + '"' + ' ';
    end;
    trim(Param);
  end
  else
    ConsoleLog('No parameters received.');

  bl_EvidenceModule := False;
  bl_FSRecentDocs := False;
  bl_FSSystemRoot := False;
  bl_FSNtfsDisLastAccUp := False;
  bl_FSTimeZone := False;
  bl_FSTriage := False;
  bl_FSUninstallPrograms := False;
  bl_FSWirelessNetworks := False;
  bl_RegModule := False;
  bl_ScriptsModule := False;
  bl_UseInList := False;

  if (CmdLine.Params.Indexof(PARAM_EVIDENCEMODULE)      <> -1) then bl_EvidenceModule      := True;
  if (CmdLine.Params.Indexof(PARAM_FSNTFSDISLASTACCUP)  <> -1) then bl_FSNtfsDisLastAccUp  := True;
  if (CmdLine.Params.Indexof(PARAM_FSRECENTDOCS)        <> -1) then bl_FSRecentDocs        := True;
  if (CmdLine.Params.Indexof(PARAM_FSSYSTEMROOT)        <> -1) then bl_FSSystemRoot        := True;
  if (CmdLine.Params.Indexof(PARAM_FSTIMEZONE)          <> -1) then bl_FSTimeZone          := True;
  if (CmdLine.Params.Indexof(PARAM_FSTRIAGE)            <> -1) then bl_FSTriage            := True;
  if (CmdLine.Params.Indexof(PARAM_FSUNINSTALLPROGRAMS) <> -1) then bl_FSUninstallPrograms := True;
  if (CmdLine.Params.Indexof(PARAM_FSWIRELESSNETWORKS)  <> -1) then bl_FSWirelessNetworks  := True;
  if (CmdLine.Params.Indexof(PARAM_REGISTRYMODULE)      <> -1) then bl_RegModule           := True;
  if (CmdLine.Params.Indexof(PARAM_InList)              <> -1) then bl_UseInList           := True;
  if CmdLine.ParamCount = 0 then bl_ScriptsModule := True;
  
  if bl_UseInList then
  begin
    bl_GUIshow := False;
    bl_AutoBookmark_results := True;
    ConsoleLog('Running from CLI.');
  end;  

  if bl_EvidenceModule then
  begin
    bl_GUIshow := False;
    bl_AutoBookmark_results := True;
    //Progress.Log('Running from Evidence module.');
    ConsoleLog('Running from Evidence module.');
  end;

  if bl_FSTriage then
  begin
    bl_GUIshow := False;
    bl_AutoBookmark_results := True;
    //Progress.Log('Running from FileSystem module Triage.');
    ConsoleLog('Running from FileSystem module Triage.');
  end;

  if bl_FSNtfsDisLastAccUp then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN +  'NTFS Disable Last Access Update';
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    //Progress.Log('Running from FileSystem module FSNTFSDisablelastAccessUpdate.');
    ConsoleLog('Running from FileSystem module FSDisalbeLastAccessUpdate.');
  end;

  if bl_FSRecentDocs then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN +  'Recent Docs';
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from FileSystem module FSRecentDocs.');
  end;

  if bl_FSSystemRoot then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN +  'System Root';
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from FileSystem module FSSystemRoot.');
  end;

  if bl_FSTimeZone then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Time Zone';
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from FileSystem module FSTimeZone.');
  end;

  if bl_FSUninstallPrograms then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Uninstall Programs';
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from FileSystem module FSUnisntallPrograms.');
  end;

  if bl_FSWirelessNetworks then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Wireless Networks';
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from FileSystem module FSWirelessNetworks.');
  end;

  if bl_RegModule = True then
  begin
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from Registry Module.');
  end;

  if bl_ScriptsModule then
  begin
    bl_GUIshow := True;
    bl_AutoBookmark_results := True;
    ConsoleLog('Running from Scripts module.');
  end;

  //============================================================================
  // Log Running Options
  //============================================================================
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog('Options:');

  if bl_GUIshow then
    ConsoleLog(RPad(HYPHEN + 'GUI:', rpad_value) + 'Show')
  else ConsoleLog(RPad(HYPHEN + 'GUI:', rpad_value) + 'Hide');

  if bl_AutoBookmark_results then
    ConsoleLog(RPad(HYPHEN + 'Auto Bookmark results:', rpad_value) + 'Yes')
  else ConsoleLog(RPad(HYPHEN + 'Auto Bookmark results:', rpad_value) + 'No');

  //============================================================================
  // Devices to Search List - Add evidence items sent from the triage
  //============================================================================
  DeviceToSearchList := TList.Create;

  if (CmdLine.ParamCount > 0) and bl_EvidenceModule then
  begin
    ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
    // Create the DeviceToSearchList
    for x := 0 to CmdLine.ParamCount - 1 do
    begin
      if assigned(DeviceList) and (DeviceList.Count > 0) then
        begin
        for y := 0 to DeviceList.Count - 1 do
        begin
          DeviceListEntry := TEntry(DeviceList.items[y]);
          if (DeviceListEntry.EntryName = cmdline.params[x]) then
          begin
            DeviceToSearchList.add(DeviceListEntry);
            ConsoleLog(RPad('Added to Device Search List:', rpad_value) + DeviceListEntry.EntryName);
            break;
          end;
        end;
      end;
    end;
  end
  else
  begin
    ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
    ConsoleLog('Searching ALL devices:');
    for y := 0 to DeviceList.Count - 1 do
    begin
      DeviceListEntry := TEntry(DeviceList.items[y]);
      ConsoleLog(RPad(HYPHEN + 'Searching:', rpad_value) + DeviceListEntry.EntryName);
    end;
  end;

  //============================================================================
  // Count the existing Bookmarks folders
  //============================================================================
  BookmarksEntryList := GetDataStore(DATASTORE_BOOKMARKS);
  StartingBookmarkFolder_Count := BookmarksEntryList.Count;
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog(RPad('Starting Bookmark folders:', rpad_value) + (IntToStr(BookmarksEntryList.Count)));

  //============================================================================
  // Find the registry files in the File System
  //============================================================================
  Reg := TMyRegistry.Create;
  Reg.RegEntries.Clear; // Clear the searchable list of reg files

  str_RegFiles_Regex := '\\(SOFTWARE|SYSTEM|SAM|NTUSER\.DAT)$';

  if bl_FSRecentDocs        then str_RegFiles_Regex := 'NTUSER.DAT$';
  if bl_FSTimeZone          or bl_FSNtfsDisLastAccUp then str_RegFiles_Regex := 'SYSTEM$';
  if bl_FSWirelessNetworks  or bl_FSSystemRoot or bl_FSUninstallPrograms then str_RegFiles_Regex := 'SOFTWARE$';

  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog('The Regex search string is:');
  ConsoleLog('  ' + str_RegFiles_Regex);
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));

  Progress.DisplayMessage := 'Finding registry files...';

  regfiles := 0;

  //============================================================================
  // Start Processing based on the parameter/s received
  //============================================================================
  if bl_RegModule           = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_REGISTRY,   str_RegFiles_Regex) else
  if bl_FSTriage            = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FSNtfsDisLastAccUp  = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FSRecentDocs        = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FSSystemRoot        = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FStimeZone          = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FSUninstallPrograms = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FSWirelessNetworks  = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_ScriptsModule       = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_UseInList           = True then regfiles := Reg.FindRegFilesByInList(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else

  if bl_EvidenceModule then
  begin
    if assigned(DeviceToSearchList) and (DeviceToSearchList.Count > 0) then
    begin
      ConsoleLog('Device count: ' + IntToStr(DeviceToSearchList.Count));
      for x := 0 to DeviceToSearchList.Count -1 do
      begin
        regfiles := Reg.FindRegFilesByDevice(TEntry(DeviceToSearchList.items[x]), str_RegFiles_Regex);
        //Progress.Log('Running from DeviceToSearchList');
      end;
    end;
  end;

  //============================================================================
  // Exit if no Registry files found
  //============================================================================
  ConsoleLog(IntToStr(regfiles) + ' registry files located:');
  if regfiles = 0 then
  begin
    ConsoleLog('No registry files were located. The script will terminate.');

    EvidenceEntryList.free;
    Memo_StringList.free;
    ConsoleLog_StringList.free;
    BookmarksEntryList.free;
    DeviceList.free;
    Reg.free;
    Exit;
  end
  else
  begin
    for i := 1 to regfiles do
      ConsoleLog(RPad(HYPHEN + 'Processing Registry File:', rpad_value) + TEntry(Reg.RegEntries.items[i-1]).FullPathName );
  end;
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  ConsoleLog('Updating control set info for SYSTEM hives.');
  Reg.UpdateControlSets; //WARNING - this will clear results and any keys added previously added
  ConsoleLog('Finished updating SYSTEM control set.');
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));

  //============================================================================
  // Add keys to the search list
  //============================================================================
  // These keys are run from the Triage button dropdown. They should be exactly the same as below where all keys are run.
  if bl_FSNtfsDisLastAccUp  then Reg.AddKey(hvSYSTEM,   csCurrent, dtInteger, '\Control\FileSystem',                                            False, REGKEY_NTFSDISLASTACCUP, BMF_NTFSDISLASTACCUP) else
  if bl_FSRecentDocs        then Reg.AddKey(hvUSER,     csNone,    dtString,  '\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs', True,  '*', BMF_RECENTDOCS) else
  if bl_FSSystemRoot        then Reg.AddKey(hvSOFTWARE, csNone,    dtString,  '\Microsoft\Windows NT\CurrentVersion',                           False, REGKEY_SYSTEMROOT, BMF_SYSTEMROOT) else
  if bl_FSTimeZone          then Reg.AddKey(hvSYSTEM,   csCurrent, dtHex,     '\Control\TimeZoneInformation',                                   True,  '*', BMF_TIMEZONEINFORMATION) else
  if bl_FSUninstallPrograms then Reg.AddKey(hvSOFTWARE, csNone,    dtString,  '\Microsoft\Windows\CurrentVersion\Uninstall',                    True,  '*', BMF_UNINSTALLPROGRAMS) else
  if bl_FSWirelessNetworks  then Reg.AddKey(hvSOFTWARE, csNone,    dtString,  '\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles',      True,  '*', BMF_WIRELESS_NETWORKS_WIN7) else
  begin
    // SOFTWARE ------------------------------------------------------------------
    // ADDKEY  HiveType    Cntrl     KeyType         A Key                                          Include Child Keys  Value                          Bookmark Group
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Clients\Mail',                                             True,  '*',                           BMF_EMAIL_CLIENTS);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion',                      True,  REGKEY_PRODUCTID,              BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion',                      True,  REGKEY_PRODUCTNAME,            BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion',                      True,  REGKEY_REGISTEREDORGANIZATION, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion',                      True,  REGKEY_REGISTEREDOWNER,        BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion',                      False, REGKEY_SYSTEMROOT,             BMF_SYSTEMROOT);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles', True,  '*',                           BMF_WIRELESS_NETWORKS_WIN7);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion\Print\Printers',       True,  '*',                           BMF_CONNECTED_PRINTERS);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion\Winlogon',             True,  REGKEY_DEFAULTDOMAINNAME,      BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows NT\CurrentVersion\Winlogon',             True,  REGKEY_DEFAULTUSERNAME,        BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtUnixTime,     '\Microsoft\Windows NT\CurrentVersion',                      True,  REGKEY_INSTALLDATE,            BMF_COMPUTER_INFORMATION);
    //Reg.AddKey(hvSOFTWARE, csNone,   dtString,     '\Microsoft\Windows NT\CurrentVersion\Winlogon',             True,  'AltDefaultDomainName',        BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, csNone,   dtString,       '\Microsoft\Windows\CurrentVersion\Uninstall',               True,  '*',                           BMF_UNINSTALLPROGRAMS);

    // SYSTEM --------------------------------------------------------------------
    Reg.AddKey(hvSYSTEM,   csCurrent, dtString,      '\Control\ComputerName\ComputerName',                        True,  REGKEY_COMPUTERNAME,           BMF_COMPUTERNAME);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtInteger,     '\Control\FileSystem',                                       False, REGKEY_NTFSDISLASTACCUP,       BMF_NTFSDISLASTACCUP);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtFileTime,    '\Control\Windows',                                          True,  REGKEY_SHUTDOWNTIME,           BMF_SHUTDOWNTIME);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtHex,         '\Control\TimeZoneInformation',                              True,  REGKEY_DAYLIGHTSTART,          BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtHex,         '\Control\TimeZoneInformation',                              True,  REGKEY_STANDARDSTART,          BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtInteger,     '\Control\TimeZoneInformation',                              True,  REGKEY_ACTIVETIMEBIAS,         BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtInteger,     '\Control\TimeZoneInformation',                              True,  REGKEY_BIAS,                   BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtInteger,     '\Control\TimeZoneInformation',                              True,  REGKEY_DAYLIGHTBIAS,           BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtInteger,     '\Control\TimeZoneInformation',                              True,  REGKEY_STANDARDBIAS,           BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtString,      '\Control\TimeZoneInformation',                              True,  REGKEY_TIMEZONEKEYNAME,        BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtString,      '\Enum\USBSTOR',                                             True,  'FriendlyName',                BMF_USBSTOR);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtTimeZoneName,'\Control\TimeZoneInformation',                              True,  REGKEY_DAYLIGHTNAME,           BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csCurrent, dtTimeZoneName,'\Control\TimeZoneInformation',                              True,  REGKEY_STANDARDNAME,           BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM,   csNone,    dtInteger,     '\Select',                                                   True,  REGKEY_CURRENT,                BMF_CONTROLSET);
    Reg.AddKey(hvSYSTEM,   csNone,    dtInteger,     '\Select',                                                   True,  REGKEY_DEFAULT,                BMF_CONTROLSET);
    Reg.AddKey(hvSYSTEM,   csNone,    dtInteger,     '\Select',                                                   True,  REGKEY_FAILED,                 BMF_CONTROLSET);
    Reg.AddKey(hvSYSTEM,   csNone,    dtInteger,     '\Select',                                                   True,  REGKEY_LASTKNOWNGOOD,          BMF_CONTROLSET);

    // NTUSER.DAT ----------------------------------------------------------------
    //Reg.AddKey(hvUSER,   csNone,   dtString,       '\Printers\Defaults',                                                                 True, '*',         'Printer Defaults');
    Reg.AddKey(hvUSER,     csNone,   dtString,       '\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs',                     True, '*',          BMF_RECENTDOCS);
    //Reg.AddKey(hvUSER,   csNone,   dtMRUListEx,    '\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery',                 True, '*',         'WordWheelQuery');
    //Reg.AddKey(hvUSER,   csNone,   dtString,       '\NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU', True, 'MRUListEx', 'Last Visited MRU');
    //Reg.AddKey(hvUSER,   csNone,   dtString,       '\Software\Microsoft\Internet Explorer\TypedURLs',                                    True, '*',         'IE Typed URLS');
    //Reg.AddKey(hvUSER,   csNone,   dtString,       '\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU',                         True, 'MRUListEx', 'ExplorerRunMru');
  end;

  //============================================================================
  // Search for Keys
  //============================================================================
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  ConsoleLog('Searching for registry keys of interest...');

  regcount := Reg.FindKeys;
  ConsoleLog(HYPHEN + 'Found ' + IntToStr(Reg.FoundCount) + ' keys.');

  // Progress.Initialize(Reg.FoundCount, 'Processing Registry Files...');
  Progress.DisplayMessageNow := 'Processing registry files...';
  Progress.Max := Reg.FoundCount;
  Progress.CurrentPosition := 1;

  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess];

  CompInfDefaultDomaInList := TList.Create;
  CompInfDefaultUserList := TList.Create;
  CompInfInstallDateList := TList.Create;
  CompInfProductIDList := TList.Create;
  CompInfProductNameList := TList.Create;
  CompInfRegOrgList := TList.Create;
  CompInfRegOwnerList := TList.Create;
  ComputerNameList := TList.Create;
  NTFSDisLastAccUpList := TList.Create;
  ConnectedPrintersList := TList.Create;
  csCurrentList := TList.Create;
  csDefaultList := TList.Create;
  csFailedList := TList.Create;
  csLastKnownGoodList := TList.Create;
  EmailList := TList.Create;
  NetworkList := TList.Create;
  RecentDocsList := TList.Create;
  ShutdownTimeList := TList.Create;
  SystemRootList := TList.Create;
  TempClassList := TList.Create;
  tzActiveTimeBiasList := TList.Create;
  tzBiasList := TList.Create;
  tzDaylightBiasList := TList.Create;
  tzDaylightNameList := TList.Create;
  tzDaylightStartList := TList.Create;
  tzDynamicList := TList.Create;
  tzStandardBiasList := TList.Create;
  tzStandardNameList := TList.Create;
  tzStandardStartList := TList.Create;
  tzTimeZoneKeyNameList := TList.Create;
  TimeZoneList := TList.Create;
  UninstallProgramsList := TList.Create;
  USBStorList := TList.Create;

  //============================================================================
  // Iterate Reg results
  //============================================================================
  for i := 0 to Reg.FoundCount - 1 do
  begin
    if not Progress.isRunning then
      Break;
    Progress.IncCurrentProgress;
    Regresult := Reg.Found[i];

    // =========================================================================
    // Regresult - Process as Values
    // =========================================================================
    if Regresult is TRegSearchresultValue then
    begin

      RegresultValue := TRegSearchresultValue(Regresult);

      Re.MatchPattern := '(\\(Microsoft|Select|Control|Enum|CurrentVersion|Printers)\\)' + // Must start with
      '(' + // Then contain starting bracket

      'ComputerName\\ComputerName\\ComputerName$' + PIPE +
      'Current$' + PIPE +
      'Default$' + PIPE +
      'DEFAULTS\\' + PIPE +
      'Failed$' + PIPE +
      'FileSystem\\NtfsDisableLastAccessUpdate$' + PIPE +
      'LastKnownGood$' + PIPE +
      'Mail\\([^\\]+)$' + PIPE +
      'Explorer\\Recentdocs\\([0-9]*$|..*\\[0-9]*$)' + PIPE +
      'USBSTOR\\.*\\FriendlyName$' + PIPE +
      'Windows NT\\CurrentVersion\\Print\\Printers\\([^\\]+)$' + PIPE +
      'Windows\\CurrentVersion\\Uninstall\\.*\\DisplayName$' + PIPE +
      'Windows\\ShutdownTime$' + PIPE +

      '((Windows NT\\CurrentVersion\\)' + // No pipe here
        '(InstallDate$' + PIPE +
        'ProductID$' + PIPE +
        'ProductName$' + PIPE +
        'RegisteredOrganization$' + PIPE +
        'RegisteredOwner$|SystemRoot$' + PIPE +
        'Winlogon\\DefaultDomainName$' + PIPE +
        'Winlogon\\DefaultUserName$|NetworkList\\Profiles\\(\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})\\([^\\]+)$' + PIPE +
        'Print\\Printers\\([^\\]+)\\([^\\]+)$))' + PIPE +

      '((TimeZoneInformation\\)' +
        '(ActiveTimeBias|Bias|DaylightBias|DaylightName|DaylightStart|DynamicDaylightTimeDisabled|StandardBias|StandardName|StandardStart|TimeZoneKeyName)$)' +

      ')';  // Then contain ending bracket

      Re.SetSubjectStr(RegresultValue.FullPath);
      if Re.Match(0) >= 0 then
      begin
        // -----------------------------------------------------------------------
        // Regresult - Process as Value - Individual Keys
        // -----------------------------------------------------------------------
        // SOFTWARE - Computer Information
        ProcessresultValue(Re,'\\Control\\Windows\\ShutdownTime$',                                    RegresultValue, RegresultValue.DataAsFileTimeStr,      ShutdownTimeList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\InstallDate$',                RegresultValue, RegresultValue.DataAsUnixDateTimeStr,  CompInfInstallDateList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\ProductID$',                  RegresultValue, RegresultValue.DataAsString,           CompInfProductIDList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\ProductName$',                RegresultValue, RegresultValue.DataAsString,           CompInfProductNameList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\RegisteredOrganization$',     RegresultValue, RegresultValue.DataAsString,           CompInfRegOrgList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\RegisteredOwner$',            RegresultValue, RegresultValue.DataAsString,           CompInfRegOwnerList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\SystemRoot$',                 RegresultValue, RegresultValue.DataAsString,           SystemRootList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\DefaultDomainName$',RegresultValue, RegresultValue.DataAsString,           CompInfDefaultDomaInList);
        ProcessresultValue(Re,'\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\DefaultUserName$',  RegresultValue, RegresultValue.DataAsString,           CompInfDefaultUserList);
        // SYSTEM - Control Set
        ProcessresultValue(Re,'\\Select\\Current$',                                                   RegresultValue, IntToStr(RegresultValue.DataAsInteger), csCurrentList);
        ProcessresultValue(Re,'\\Select\\Default$',                                                   RegresultValue, IntToStr(RegresultValue.DataAsInteger), csDefaultList);
        ProcessresultValue(Re,'\\Select\\Failed$',                                                    RegresultValue, IntToStr(RegresultValue.DataAsInteger), csFailedList);
        ProcessresultValue(Re,'\\Select\\LastKnownGood$',                                             RegresultValue, IntToStr(RegresultValue.DataAsInteger), csLastKnownGoodList);
        // SYSTEM - TimeZone
        ProcessresultValue(Re,'\\Control\\ComputerName\\ComputerName\\ComputerName$',                 RegresultValue, RegresultValue.DataAsString,            ComputerNameList);
        // SYSTEM - NTFS Diable Last Access Update
        ProcessresultValue(Re,'\\Control\\FileSystem\\NtfsDisableLastAccessUpdate$',                  RegresultValue, IntToStr(RegresultValue.DataAsInteger), NTFSDisLastAccUpList);

        if not bl_FSTimeZone then
        begin
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\ActiveTimeBias$',                      RegresultValue, IntToStr(RegresultValue.DataAsInteger), tzActiveTimeBiasList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\Bias$',                                RegresultValue, IntToStr(RegresultValue.DataAsInteger), tzBiasList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\DaylightBias$',                        RegresultValue, IntToStr(RegresultValue.DataAsInteger), tzDaylightBiasList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\DaylightName$',                        RegresultValue, RegresultValue.DataAsTimeZoneName,      tzDaylightNameList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\DaylightStart$',                       RegresultValue, RegresultValue.DataAsHexstr(16),        tzDaylightStartList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\DynamicDaylightTimeDisabled$',         RegresultValue, IntToStr(RegresultValue.DataAsInteger), tzDynamicList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\StandardBias$',                        RegresultValue, IntToStr(RegresultValue.DataAsInteger), tzStandardBiasList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\StandardName$',                        RegresultValue, RegresultValue.DataAsTimeZoneName,      tzStandardNameList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\StandardStart$',                       RegresultValue, RegresultValue.DataAsHexstr(16),        tzStandardStartList);
          ProcessresultValue(Re,'\\Control\\TimeZoneInformation\\TimeZoneKeyName$',                     RegresultValue, RegresultValue.DataAsString,            tzTimeZoneKeyNameList);
        end;

        // -----------------------------------------------------------------------
        // Regresult - Process as Value - NetworkList
        // -----------------------------------------------------------------------
        Re.MatchPattern := '^\\Microsoft\\Windows NT\\CurrentVersion\\NetworkList\\Profiles\\(\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})\\([^\\]+)$';
        Re.SetSubjectStr(RegresultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 3) then
          begin
            nid := -1;
            for n := 0 to NetworkList.Count - 1 do
            begin
              if (TNetworkInfo(NetworkList[n]).GUID = UpperCase(Re.Substr(1))) and
                 (TNetworkInfo(NetworkList[n]).Registry = RegresultValue.Entry) and
                 (TNetworkInfo(NetworkList[n]).Device = GetDeviceEntry(RegresultValue.Entry)) then
              begin
                nid := n;
                break;
              end;
            end;
            if nid >= 0 then
              Network := TNetworkInfo(NetworkList[nid])
            else
            begin
              Network := TNetworkInfo.Create;
              Network.GUID := UpperCase(Re.Substr(1));
              Network.Registry := RegresultValue.Entry;
              Network.Device := GetDeviceEntry(RegresultValue.Entry);
              Network.KeyFullPath := RegresultValue.FullPath;
              NetworkList.Add(Network);
            end;
            valname := UpperCase(Re.SubStr(2));
            if valname = 'PROFILENAME' then
              Network.ProfileName := RegresultValue.DataAsString
            else if valname = 'DESCRIPTION' then
              Network.Description := RegresultValue.DataAsString
            else if valname = 'DATECREATED' then
              Network.DateCreated := RegresultValue.DataAsNetworkListDate
            else if valname = 'DATELASTCONNECTED' then
              Network.LastConnected := RegresultValue.DataAsNetworkListDate;
          end;
        end

        else

        // -----------------------------------------------------------------------
        // Regresult - Process as Value - Connected Printers
        // -----------------------------------------------------------------------
        begin
          Re.MatchPattern := '^\\Microsoft\\Windows NT\\CurrentVersion\\Print\\Printers\\([^\\]+)\\([^\\]+)$';
          Re.SetSubjectStr(RegresultValue.FullPath);
          if Re.Match(0) >= 0 then
          begin
            mstr := Re.MatchedStrPtr;
            if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 3) then
            begin
              nid := -1;
              for n := 0 to ConnectedPrintersList.Count - 1 do
              begin
                if not Progress.isRunning then break;
                if (TPrinterInfo(ConnectedPrintersList[n]).Name = UpperCase(Re.Substr(1))) and
                 (TPrinterInfo(ConnectedPrintersList[n]).Registry = RegresultValue.Entry) and
                 (TPrinterInfo(ConnectedPrintersList[n]).Device = GetDeviceEntry(RegresultValue.Entry)) then
                begin
                  nid := n;
                  break;
                end;
              end;
              if nid >= 0 then
                Printer := TPrinterInfo(ConnectedPrintersList[nid])
              else
              begin
                Printer := TPrinterInfo.Create;
                Printer.Name := UpperCase(Re.Substr(1));
                Printer.Registry := RegresultValue.Entry;
                Printer.Device := GetDeviceEntry(RegresultValue.Entry);
                ConnectedPrintersList.Add(Printer);
              end;
              valname := UpperCase(Re.SubStr(2));
              if valname = 'SHARE NAME' then
                Printer.ShareName := RegresultValue.DataAsString
              else if valname = 'PRINTER DRIVER' then
                Printer.Driver := RegresultValue.DataAsString
              else if valname = 'DESCRIPTION' then
                Printer.Description := RegresultValue.DataAsString;
              end;
            end
          else
          begin
            BookmarkComment := '';
            // Process as Value --------------------------------------------------
            RegresultValue := TRegSearchresultValue(Regresult);
            case RegresultValue.SearchKey.DataType of
              dtInteger:
                BookmarkComment := IntToStr(RegresultValue.DataAsInteger);
              dtFileTime:
                BookmarkComment := RegresultValue.DataAsFileTimeStr;
              dtUnixTime:
                BookmarkComment := RegresultValue.DataAsUnixDateTimeStr;
              dtSystemTime:
                BookmarkComment := RegresultValue.DataAsSystemTimeStr;
              dtNetworkListDate:
                BookmarkComment := RegresultValue.DataAsNetworkListDate;
              dtString:
                BookmarkComment := RegresultValue.DataAsString;
              dtHex:
                BookmarkComment := RegresultValue.DataAsHexStr(min(RegresultValue.DataSize, 50));
              dtMRUListEx:
                BookmarkComment := RegresultValue.DataAsString;
              dtMRUValue:
                BookmarkComment := RegresultValue.DataAsString;
              dtTimeZoneName:
                BookmarkComment := RegresultValue.DataAsTimeZoneName;
              else
                BookmarkComment := RegresultValue.DataAsString;
            end;
          end;
        end;

        // -----------------------------------------------------------------------
        // Regresult - Process as Value - USBStor FriendlyName
        // -----------------------------------------------------------------------
        Re.MatchPattern := '\\Enum\\USBSTOR\\.*\\FriendlyName$';
        Re.SetSubjectStr(RegresultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            USBStor := TUSBStorInfo.Create;
            USBStor.Registry := RegresultValue.Entry;
            USBStor.Device := GetDeviceEntry(RegresultValue.Entry);
            USBStor.Name := RegresultValue.DataAsString;
            USBStor.KeyPath := TRegSearchresultKey(Regresult).FullPath;
            USBStorList.Add(USBStor);
          end;
        end;

        // -----------------------------------------------------------------------
        // Regresult - Process as Value - RecentDocs
        // -----------------------------------------------------------------------
        Re.MatchPattern := '\\CurrentVersion\\Explorer\\Recentdocs\\([0-9]*$|..*\\[0-9]*$)';
        Re.SetSubjectStr(RegresultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            RecentDocs := TRecentDocsInfo.Create;
            RecentDocs.Registry := RegresultValue.Entry;
            RecentDocs.Device := GetDeviceEntry(RegresultValue.Entry);
            if RegresultValue.ProcessMRUShellBag(shellbagrec) then
            begin
              RecentDocs.ShellBag := shellbagrec;
            end;

            RecentDocs.Name := RegresultValue.DataAsString(True);
            RecentDocs.KeyPath := TRegSearchresultKey(Regresult).FullPath;
            RecentDocsList.Add(RecentDocs);
          end;
        end;

        // -----------------------------------------------------------------------
        // Regresult - Process as Value - UninstallPrograms
        // -----------------------------------------------------------------------
        Re.MatchPattern := '\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\.*\\DisplayName$';
        Re.SetSubjectStr(RegresultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            UninstallPrograms := TUninstallProgramsInfo.Create;
            UninstallPrograms.Registry := RegresultValue.Entry;
            UninstallPrograms.Device := GetDeviceEntry(RegresultValue.Entry);
            UninstallPrograms.Name := RegresultValue.DataAsString;
            UninstallPrograms.KeyPath := TRegSearchresultKey(Regresult).FullPath;
            UninstallProgramsList.Add(UninstallPrograms);
          end;
        end;

        // -----------------------------------------------------------------------
        // Regresult - Process as Value - TimeZone
        // -----------------------------------------------------------------------
        if bl_FSTimeZone then
        begin
          Re.MatchPattern := '\\Control\\TimeZoneInformation\\(ActiveTimeBias|Bias|DaylightBias|TimeZoneKeyName|StandardName|StandardBias|DaylightName)$';
          Re.SetSubjectStr(RegresultValue.FullPath);
          if Re.Match(0) >= 0 then
          begin
            mstr := Re.MatchedStrPtr;
            if (mstr <> '') and (Re.MatchedStrLength > 0) then
            begin
              TimeZone := TTimeZoneInfo.Create;
              TimeZone.Registry := RegresultValue.Entry;
              TimeZone.Device := GetDeviceEntry(RegresultValue.Entry);

              if POS('StandardName', RegresultValue.FullPath) > 0 then
                Timezone.tzStandardName := RegresultValue.DataAsTimeZoneName;

              if POS('TimeZoneKeyName', RegresultValue.FullPath) > 0 then
                TimeZone.tzTimeZoneKeyname := RegresultValue.DataAsString(True);

              if POS('DaylightName', RegresultValue.FullPath) > 0 then
                TimeZone.tzDaylightName := RegresultValue.DataAsTimeZoneName;

              if POS('StandardBias', RegresultValue.FullPath) > 0 then
                Timezone.tzStandardBias := RegresultValue.DataAsinteger;

              if RegexMatch(RegresultValue.FullPath, '\\Control\\TimeZoneInformation\\Bias$', False) then
                Timezone.tzBias := RegresultValue.DataAsinteger;

              if POS('ActiveTimeBias', RegresultValue.FullPath) > 0 then
                Timezone.tzActiveTimeBias := RegresultValue.DataAsinteger;

              if POS('DaylightBias', RegresultValue.FullPath) > 0 then
                Timezone.tzDaylightBias := RegresultValue.DataAsinteger;

              TimeZone.KeyPath := TRegSearchresultKey(Regresult).FullPath;
              TimeZoneList.Add(TimeZone);
            end;
          end;
        end;
      end;
    end {Regresult Values}
    else

    // =========================================================================
    // Regresult - Process as Key
    // =========================================================================
    if Regresult is TRegSearchresultKey then
    begin
      RegresultKey := TRegSearchresultKey(Regresult);

      // -----------------------------------------------------------------------
      // Regresult - Process as Key - Connected Printers Date Last Modified
      // -----------------------------------------------------------------------
      Re.MatchPattern := '^\\Microsoft\\Windows NT\\CurrentVersion\\Print\\Printers\\([^\\]+)$';    //only want the Key - no values
      Re.SetSubjectStr(RegresultKey.FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 2) then
        begin
          nid := -1;
          for n := 0 to ConnectedPrintersList.Count - 1 do
          begin
            if not Progress.isRunning then break;
            if (TPrinterInfo(ConnectedPrintersList[n]).Name = UpperCase(Re.Substr(1))) and
               (TPrinterInfo(ConnectedPrintersList[n]).Registry = RegresultKey.Entry) and
               (TPrinterInfo(ConnectedPrintersList[n]).Device = GetDeviceEntry(RegresultKey.Entry)) then
            begin
              nid := n;
              break;
            end;
          end;
          if nid >= 0 then
            Printer := TPrinterInfo(ConnectedPrintersList[nid])
          else
          begin
            Printer := TPrinterInfo.Create;
            Printer.Name := UpperCase(Re.Substr(1));
            Printer.Registry := RegresultKey.Entry;
            Printer.Device := GetDeviceEntry(RegresultKey.Entry);
            Printer.KeyName := RegresultKey.KeyName;
            Printer.KeyFullPath := RegresultKey.FullPath;
            ConnectedPrintersList.Add(Printer);
          end;
          Printer.LastModified := RegresultKey.KeyLastModified;
        end;
      end;

      // -----------------------------------------------------------------------
      // Regresult - Process as Key - Printer Defaluts
      // -----------------------------------------------------------------------
      if pos('\PRINTERS\DEFAULTS\', UpperCase(TRegSearchresultKey(Regresult).FullPath)) > 0 then
      begin
        if (length(TRegSearchresultKey(Regresult).KeyName) = 38) and (TRegSearchresultKey(Regresult).KeyName[1] = '{') then     //GUIDs are always 38 chars long and start with {
        begin
          EntryReader:= TEntryReader.Create;
          if EntryReader.OpenData(RegresultKey.Entry) then
          begin
            // Get the sub key values - the first value should be default
            RawRegSubKeyValues := TRawRegistry.Create(EntryReader, False);
            if RawRegSubKeyValues.OpenKey(TRegSearchresultKey(Regresult).FullPath) then
            begin
              SubKeyValueList := TStringList.Create;
              SubKeyValueList.Clear;
              if RawRegSubKeyValues.GetValueNames(SubKeyValueList) then
              begin
                for k := 0 to SubKeyValueList.Count - 1 do
                begin
                  if not Progress.isRunning then break;
                  if SubKeyValueList[k] = '' then // SubKeyValueList[k] := '(default)';
                  begin
                    if RawRegSubKeyValues.GetDataInfo(SubKeyValueList[k], DataInfo) then
                    begin
                      // ConsoleLog(IntToStr(k) + ':' + SubKeyValueList[k]);
                      FoundValue := TRegSearchresultValue.Create;
                      FoundValue.Entry := RegresultKey.Entry;
                      FoundValue.KeyPath := RegresultKey.FullPath + '\' ;
                      FoundValue.Name := SubKeyValueList[k];
                      FoundValue.DataType := DataInfo.RegData;
                      FoundValue.DataSize := DataInfo.DataSize;
                      FoundValue.Data := nil;
                      GetMem(FoundValue.Data, FoundValue.DataSize);
                      FillChar(FoundValue.Data^, FoundValue.DataSize, 0);
                      bytesread := RawRegSubKeyValues.ReadRawData(SubKeyValueList[k], FoundValue.Data^, FoundValue.DataSize);
                      BookmarkComment := (FoundValue.DataAsString);
                      //Progress.Log(FoundValue.KeyPath+ ' ' + BookmarkComment);
                      //ConsoleLog(' - Located: NTUSER.Dat' + TRegSearchresultKey(Regresult).FullPath+'\'+(FoundValue.DataAsString));
                    end;
                  end;
                end;
              end;
              FreeAndNil(SubKeyValueList);
            end;
            FreeAndNil(RawRegSubKeyValues);
          end;
          FreeAndNil(EntryReader);
        end;
      end;{Printer Defaults}

      // -----------------------------------------------------------------------
      // Regresult - Process as Key - Email Clients
      // -----------------------------------------------------------------------
      Re.MatchPattern := '^\\Clients\\Mail\\([^\\]+)$'; // Only want the Key - no values
      Re.SetSubjectStr(RegresultKey.FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) then
        begin
          Email := TEmailInfo.Create;
          Email.Registry := RegresultKey.Entry;
          Email.Device := GetDeviceEntry(RegresultKey.Entry);
          Email.Name := UpperCase(Re.Substr(1));
          Email.KeyPath := (TRegSearchresultKey(Regresult).FullPath);
          EmailList.Add(Email);
        end;
      end;

    end;{Regresult - Process as Key}
  end;{for RegFoundCount}

  //============================================================================
  // OUTPUT AND BOOKMARK
  //============================================================================
  BookmarkComment_StringList := TStringList.Create;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Individual Keys
  // ---------------------------------------------------------------------------
  //          (ATList                      AHive_Type         ABMF_Key_Group            FieldName
  Outputresult(CompInfDefaultDomaInList,   BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_DEFAULTDOMAINNAME);
  Outputresult(CompInfDefaultUserList,     BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_DEFAULTUSERNAME);
  Outputresult(CompInfInstallDateList,     BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_INSTALLDATE);
  Outputresult(CompInfProductIDList,       BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_PRODUCTID);
  Outputresult(CompInfProductNameList,     BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_PRODUCTNAME);
  Outputresult(CompInfRegOrgList,          BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_REGISTEREDORGANIZATION);
  Outputresult(CompInfRegOwnerList,        BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_REGISTEREDOWNER);
  Outputresult(SystemRootList,             BMF_SOFTWARE_HIVE, BMF_SYSTEMROOT,           REGKEY_SYSTEMROOT);
  Outputresult(ComputerNameList,           BMF_SYSTEM_HIVE,   BMF_COMPUTERNAME,         REGKEY_COMPUTERNAME);
  Outputresult(NTFSDisLastAccUpList,       BMF_SYSTEM_HIVE,   BMF_NTFSDISLASTACCUP,     REGKEY_NTFSDISLASTACCUP);
  Outputresult(csCurrentList,              BMF_SYSTEM_HIVE,   BMF_CONTROLSET,           REGKEY_CURRENT);
  Outputresult(csDefaultList,              BMF_SYSTEM_HIVE,   BMF_CONTROLSET,           REGKEY_DEFAULT);
  Outputresult(csFailedList,               BMF_SYSTEM_HIVE,   BMF_CONTROLSET,           REGKEY_FAILED);
  Outputresult(csLastKnownGoodList,        BMF_SYSTEM_HIVE,   BMF_CONTROLSET,           REGKEY_LASTKNOWNGOOD);
  Outputresult(ShutdownTimeList,           BMF_SYSTEM_HIVE,   BMF_SHUTDOWNTIME,         REGKEY_SHUTDOWNTIME);
  Outputresult(tzActiveTimeBiasList,       BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_ACTIVETIMEBIAS);
  Outputresult(tzBiasList,                 BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_BIAS);
  Outputresult(tzDaylightBiasList,         BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_DAYLIGHTBIAS);
  Outputresult(tzDaylightnameList,         BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_DAYLIGHTNAME);
  Outputresult(tzDayLightStartList,        BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_DAYLIGHTSTART);
  Outputresult(tzStandardBiasList,         BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_STANDARDBIAS);
  Outputresult(tzStandardNameList,         BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_STANDARDNAME);
  Outputresult(tzStandardStartList,        BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_STANDARDSTART);
  Outputresult(tzTimeZoneKeyNameList,      BMF_SYSTEM_HIVE,   BMF_TIMEZONEINFORMATION,  REGKEY_TIMEZONEKEYNAME);
  if not Progress.isRunning then
    Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Connected Printers
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_CONNECTED_PRINTERS;
  If (assigned(ConnectedPrintersList) and (ConnectedPrintersList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to ConnectedPrintersList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, (Stringofchar(' ', CHAR_LENGTH)));
      ConsoleLog(ltMessagesMemoBM, RPad('Name:',         rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).Name);
      if TPrinterInfo(ConnectedPrintersList[n]).ShareName <> ''    then ConsoleLog(ltMessagesMemoBM, RPad('Share Name:',    rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).ShareName);
      if TPrinterInfo(ConnectedPrintersList[n]).Description <> ''  then ConsoleLog(ltMessagesMemoBM, RPad('Description:',  rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).Description);
      ConsoleLog(ltMessagesMemoBM, RPad('Driver:',       rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).Driver);
      ConsoleLog(ltMessagesMemoBM, RPad('Last Modified:', rpad_value) + DatetimeToStr(TPrinterInfo(ConnectedPrintersList[n]).LastModified));
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_str := TDataEntry(TPrinterInfo(ConnectedPrintersList[n]).Registry).FullPathName + TPrinterInfo(ConnectedPrintersList[n]).KeyFullPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_str);
      ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device := TDataEntry(TPrinterInfo(ConnectedPrintersList[n]).Device).EntryName;
      BMF_Key_Name := TPrinterInfo(ConnectedPrintersList[n]).Name;
      BM_Source_str := TDataEntry(TPrinterInfo(ConnectedPrintersList[n]).Registry).FullPathName;
      BookMark(Device, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Email
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_EMAIL_CLIENTS;
  If (assigned(EmailList) and (EmailList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to EmailList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemoBM, RPad('Email Client:', rpad_value) + TEmailInfo(EmailList[n]).Name);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_str :=  TDataEntry(TEmailInfo(EmailList[n]).Registry).FullPathName + TEmailInfo(EmailList[n]).KeyPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_str);
      ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device := TDataEntry(TEmailInfo(EmailList[n]).Device).EntryName;
      BMF_Key_Name := TEmailInfo(EmailList[n]).Name;
      BM_Source_str := TDataEntry(TEmailInfo(EmailList[n]).Registry).FullPathName;
      BookMark(Device, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Uninstall Programs
  // ---------------------------------------------------------------------------

  UninstallPrograms_StringList := TStringList.Create;
  BMF_Key_Group := BMF_UNINSTALLPROGRAMS;
  if (assigned(UninstallProgramsList) and (UninstallProgramsList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to UninstallProgramsList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      The_Source_str :=  TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Registry).FullPathName + TUninstallProgramsInfo(UninstallProgramsList[n]).KeyPath;
      BookmarkComment_StringList.Clear;
      //ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog(ltBM, RPad('UninstallPrograms:', rpad_value) + TUninstallProgramsInfo(UninstallProgramsList[n]).Name);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      ConsoleLog(ltBM, 'Source: ' + The_Source_str);
      //ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device := TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Device).EntryName;
      BMF_Key_Name := TUninstallProgramsInfo(UninstallProgramsList[n]).Name;
      BM_Source_str := TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Registry).FullPathName;
      BookMark(Device, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

      UninstallPrograms_StringList.Add(TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Registry).FullPathName+'*'+TUninstallProgramsInfo(UninstallProgramsList[n]).Name);
      UninstallPrograms_StringList.Sort;
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // Use the StringList created above for flexibility of formatting the output
  source_str := '';
  begin
    if UninstallPrograms_StringList.Count > 0 then
    begin
      for i := 0 to UninstallPrograms_StringList.Count-1 do
      begin
       if not Progress.isRunning then break;
       tildpos := Pos('*', UninstallPrograms_StringList.strings[i]);

        // Handle printing of the header row
        if source_str = '' then
        begin
          source_str := copy(UninstallPrograms_StringList.strings[i],1,tildpos-1);
          ConsoleLog(ltMessagesMemo, (Stringofchar(' ', CHAR_LENGTH)));
          ConsoleLog(ltMessagesMemo, RPad('Source:', 10) + source_str);
          ConsoleLog(ltMessagesMemo, (Stringofchar(' ', CHAR_LENGTH)));
        end
        else
        if source_str <> copy(UninstallPrograms_StringList.strings[i],1,tildpos-1) then
        begin
          source_str := copy(UninstallPrograms_StringList.strings[i],1,tildpos-1);
          ConsoleLog(ltMessagesMemo, (Stringofchar(' ', CHAR_LENGTH)));
          ConsoleLog(ltMessagesMemo, RPad('Source:', 10) + source_str);
          ConsoleLog(ltMessagesMemo, (Stringofchar(' ', CHAR_LENGTH)));
        end;{printing of header row}

        program_name_str := Copy(UninstallPrograms_StringList.strings[i], tildpos + 1, Length(UninstallPrograms_StringList.strings[i]));
        ConsoleLog(ltMessagesMemo, RPad('', 15) + program_name_str);
      end;
      ConsoleLog(ltMessagesMemo, (Stringofchar(' ', CHAR_LENGTH)));
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - USBStor
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_USBSTOR;
  if (assigned(USBStorList) and (USBStorList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to USBStorList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemoBM, RPad('Friendly Name:', rpad_value) + TUSBStorInfo(USBStorList[n]).Name);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_str :=  TDataEntry(TUSBStorInfo(USBStorList[n]).Registry).FullPathName + TUSBStorInfo(USBStorList[n]).KeyPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_str);
      ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device := TDataEntry(TUSBStorInfo(USBStorList[n]).Device).EntryName;
      BMF_Key_Name := TUSBStorInfo(USBStorList[n]).Name;
      BM_Source_str := TDataEntry(TUSBStorInfo(USBStorList[n]).Registry).FullPathName;
      BookMark(Device, BMF_SYSTEM_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - RECENTDOCS
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_RECENTDOCS;
  //' Reference: "Windows Registry Forensics: Advanced digital Forensic Analysis of the Windows Registry" Carvey, Harlan. Syngress 2011, Pages 169-178'
  if (assigned(RecentDocsList) and (RecentDocsList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to RecentDocsList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemo, RPad('Recent Docs Name:', 20)         + TRecentDocsInfo(RecentDocsList[n]).ShellBag.DisplayName);
      ConsoleLog(ltBM,           RPad('Recent Docs Name:', rpad_value) + TRecentDocsInfo(RecentDocsList[n]).ShellBag.DisplayName);
      ConsoleLog(ltMessagesMemo, RPad('Recent Docs Type:', 20)         + TRecentDocsInfo(RecentDocsList[n]).ShellBag.TypeAsString);
      ConsoleLog(ltBM,           RPad('Recent Docs Type:', rpad_value) + TRecentDocsInfo(RecentDocsList[n]).ShellBag.TypeAsString);
      ConsoleLog(ltMessagesMemo, RPad('Registry File:',    20)         + TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Registry).FullPathName);
      ConsoleLog(ltMessagesMemo, RPad('Registry Key:',    20)          + TRecentDocsInfo(RecentDocsList[n]).KeyPath);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_str :=  TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Registry).FullPathName + TRecentDocsInfo(RecentDocsList[n]).KeyPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_str);
      ConsoleLog(ltBM,           RPad('Source:', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device := TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Device).EntryName;
      BMF_Key_Name := TRecentDocsInfo(RecentDocsList[n]).Name;
      BM_Source_str := TDataEntry(TRecentdocsInfo(RecentDocsList[n]).Registry).FullPathName;
      BookMark(Device, BMF_NTUSER_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - TimeZone
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_TIMEZONEINFORMATION;
  if (assigned(TimeZoneList) and (TimeZoneList.Count > 0)) then
  begin
    ConsoleSection(BMF_Key_Group);
    ConsoleLog(ltMessagesMemo, Stringofchar(' ', CHAR_LENGTH));
    The_Source_str := '';
    for n := 0 to TimeZoneList.Count - 1 do
    begin
      if not Progress.isRunning then break;

      // Print the source header
      if The_Source_str = '' then
      begin
        The_Source_str :=  TDataEntry(TTimeZoneInfo(TimeZoneList[n]).Registry).FullPathName;
        ConsoleLog(ltMessagesMemo, RPad('Source: ', rpad_value) + The_Source_str);
      end
      else
      if The_Source_str <> TDataEntry(TTimeZoneInfo(TimeZoneList[n]).Registry).FullPathName then
      begin
        The_Source_str :=  TDataEntry(TTimeZoneInfo(TimeZoneList[n]).Registry).FullPathName;
        ConsoleLog(ltMessagesMemo, Stringofchar(' ', CHAR_LENGTH));
        ConsoleLog(ltMessagesMemo, RPad('Source: ', rpad_value) + The_Source_str);
      end;

      if TTimeZoneInfo(TimeZoneList[n]).tzStandardName <> '' then
        ConsoleLog(ltMessagesMemoBM, RPad('StandardName:', rpad_value) + TTimeZoneInfo(TimeZoneList[n]).tzStandardName);

      if TTimeZoneInfo(TimeZoneList[n]).tzTimezoneKeyName <> '' then
        ConsoleLog(ltMessagesMemoBM, RPad('TimeZoneKeyName:', rpad_value) + TTimeZoneInfo(TimeZoneList[n]).tzTimeZoneKeyName);

      if TTimeZoneInfo(TimeZoneList[n]).tzDaylightName <> '' then
        ConsoleLog(ltMessagesMemoBM, RPad('DaylightName:', rpad_value) + TTimeZoneInfo(TimeZoneList[n]).tzDaylightName);

      if (TTimeZoneInfo(TimeZoneList[n]).tzActiveTimeBias) <> 0 then
        ConsoleLog(ltMessagesMemoBM, RPad('ActiveTimeBias:', rpad_value) + IntToStr(TTimeZoneInfo(TimeZoneList[n]).tzActiveTimeBias));

      if (TTimeZoneInfo(TimeZoneList[n]).tzDaylightBias) <> 0 then
        ConsoleLog(ltMessagesMemoBM, RPad('DaylightBias:', rpad_value) + IntToStr(TTimeZoneInfo(TimeZoneList[n]).tzDaylightBias));

      if (TTimeZoneInfo(TimeZoneList[n]).tzBias) <> 0 then
        ConsoleLog(ltMessagesMemoBM, RPad('Bias:', rpad_value) + IntToStr(TTimeZoneInfo(TimeZoneList[n]).tzBias));

      if (TTimeZoneInfo(TimeZoneList[n]).tzStandardBias) <> 0 then
        ConsoleLog(ltMessagesMemoBM, RPad('StandardBias:', rpad_value) + IntToStr(TTimeZoneInfo(TimeZoneList[n]).tzStandardBias));

    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Wireless Networks
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_WIRELESS_NETWORKS_WIN7;
  If (assigned(NetworkList) and (NetworkList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to NetworkList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog('Network #' + IntToStr(n+1));
      ConsoleLog(ltMessagesMemoBM, RPad('GUID:',          rpad_value) + TNetworkInfo(NetworkList[n]).GUID);
      ConsoleLog(ltMessagesMemoBM, RPad('Profile Name:',   rpad_value) + TNetworkInfo(NetworkList[n]).ProfileName);
      ConsoleLog(ltMessagesMemoBM, RPad('Description:',   rpad_value) + TNetworkInfo(NetworkList[n]).Description);
      ConsoleLog(ltMessagesMemoBM, RPad('Date Created:',   rpad_value) + TNetworkInfo(NetworkList[n]).DateCreated);
      ConsoleLog(ltMessagesMemoBM, RPad('Last Connected:', rpad_value) + TNetworkInfo(NetworkList[n]).LastConnected);
      ConsoleLog(ltBM,('~~~~~~~~~~~~~~~'));
      The_Source_str := TDataEntry(TNetworkInfo(NetworkList[n]).Registry).FullPathName + TNetworkInfo(NetworkList[n]).KeyFullPath;
      ConsoleLog(ltBM,'Source: ' + The_Source_str);
      ConsoleLog(ltMessagesMemo, RPad('Source: ', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device        := TDataEntry(TNetworkInfo(NetworkList[n]).Device).EntryName;
      BMF_Key_Name  := TNetworkInfo(NetworkList[n]).GUID;
      BM_Source_str := TDataEntry(TNetworkInfo(NetworkList[n]).Registry).FullPathName;
      BookMark(Device, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
     Goto Finish;

  ConsoleLog(ltMessagesMemo, (Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog(ltMessagesMemo, #13#10+'End of results.');

Finish:

  // Finishing bookmark folder count
  ConsoleLog('Finishing Bookmark folder count: ' + (IntToStr(BookmarksEntryList.Count)) + '. There were: ' + (IntToStr(BookmarksEntryList.Count - StartingBookmarkFolder_Count)) + ' new Bookmark folders added.');

  ConsoleLog('Starting: ' + IntToStr(StartingBookmarkFolder_Count) + ', Finishing: ' + IntToStr(BookmarksEntryList.Count) + ', Difference: ' + IntToStr(BookmarksEntryList.Count - StartingBookmarkFolder_Count));

  // Debugging count of Bookmark folder for Triage\.*\Registry
  Registry_Bookmark_Folder_Count := 0;
  Entry := BookmarksEntryList.First;
  while assigned(Entry) and Progress.isRunning do
  begin
    begin
      if RegexMatch(Entry.FullPathName,'Triage\\.*?\\Registry\\', False) then
        Registry_Bookmark_Folder_Count := Registry_Bookmark_Folder_Count + 1;
    end;
    Entry := BookmarksEntryList.Next;
  end;
  ConsoleLog('Triage\*.*\Registry\ folder count: ' + IntToStr(Registry_Bookmark_Folder_Count));

  // Free Memory
  EvidenceEntryList.free;
  BookmarksEntryList.free;
  CompInfDefaultDomaInList.free;
  CompInfDefaultUserList.free;
  CompInfInstallDateList.free;
  CompInfProductIDList.free;
  CompInfProductNameList.free;
  CompInfRegOrgList.free;
  CompInfRegOwnerList.free;
  ComputerNameList.free;
  ConnectedPrintersList.free;
  csCurrentList.free;
  csDefaultList.free;
  csFailedList.free;
  csLastKnownGoodList.free;
  DeviceList.free;
  DeviceToSearchList.free;
  EmailList.free;
  NetworkList.free;
  NTFSDisLastAccUpList.free;
  RecentDocsList.free;
  Reg.free;
  ShutdownTimeList.free;
  SystemRootList.free;
  TempClassList.free;
  tzActiveTimeBiasList.free;
  tzBiasList.free;
  tzDaylightBiasList.free;
  tzDaylightNameList.free;
  tzDaylightStartList.free;
  tzDynamicList.free;
  tzStandardBiasList.free;
  tzStandardNameList.free;
  tzStandardStartList.free;
  tzTimeZoneKeyNameList.free;
  TimeZoneList.free;
  UninstallProgramsList.free;
  UninstallPrograms_StringList.free;
  USBStorList.free;

  ConsoleLog(SCRIPT_NAME  + ' ' + 'Finished.');

  // Must be freed after the last ConsoleLog
  BookmarkComment_StringList.free;
  ConsoleLog_StringList.free;
  Memo_StringList.free;

  Progress.DisplayMessageNow := 'Processing complete';
end.