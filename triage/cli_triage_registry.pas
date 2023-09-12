{ !NAME:      Triage - Registry }
{ !DESC:      Triage Registry }
{ !AUTHOR:    GetData }
{ !REFERENCE: Reference: Carvey, Harlan A. "Windows Registry Forensics", Syngress 2011' }

unit cli_triage_registry;

interface

uses
  Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DataStreams, DIRegex, Graphics,
  Math, NoteEntry, PropertyList, RawRegistry, RegEx, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  // ==============================================================================
  // DO NOT TRANSLATE
  // ==============================================================================
  ANY_HIVE = 'ANY'; // noslz
  BMF_NTUSER_HIVE = 'NTUSER'; // noslz
  BMF_SAM_HIVE = 'SAM'; // noslz
  BMF_SOFTWARE_HIVE = 'SOFTWARE'; // noslz
  BMF_SYSTEM_HIVE = 'SYSTEM'; // noslz
  FILESIG_REGISTRY = 'Registry'; // noslz
  NTUSER_HIVE = 'NTUSER.DAT'; // noslz
  PARAM_EVIDENCEMODULE = 'EVIDENCEMODULE'; // noslz
  PARAM_FSNTFSDISLASTACCUP = 'FSNTFSDISLASTACCUP'; // noslz
  PARAM_FSPROFILEIMAGEPATH = 'FSPROFILEIMAGEPATH'; // noslz
  PARAM_FSRECENTDOCS = 'FSRECENTDOCS'; // noslz
  PARAM_FSSYSTEMROOT = 'FSSYSTEMROOT'; // noslz
  PARAM_FSTIMEZONE = 'FSTIMEZONE'; // noslz
  PARAM_FSTRIAGE = 'FSTRIAGE'; // noslz
  PARAM_FSUNINSTALLPROGRAMS = 'FSUNINSTALLPROGRAMS'; // noslz
  PARAM_FSWIRELESSNETWORKS = 'FSWIRELESSNETWORKS'; // noslz
  PARAM_REGISTRYMODULE = 'REGISTRYMODULE'; // noslz
  REGKEY_ACTIVETIMEBIAS = 'ActiveTimeBias'; // noslz
  REGKEY_ALTDEFAULTDOMAINNAME = 'AltDefaultDomainName'; // noslz
  REGKEY_BIAS = 'Bias'; // noslz
  REGKEY_COMPUTERNAME = 'ComputerName'; // noslz
  REGKEY_CURRENT = 'Current'; // noslz
  REGKEY_DAYLIGHTBIAS = 'DaylightBias'; // noslz
  REGKEY_DAYLIGHTNAME = 'DaylightName'; // noslz
  REGKEY_DAYLIGHTSTART = 'DaylightStart'; // noslz
  REGKEY_DEFAULT = 'Default'; // noslz
  REGKEY_DEFAULTDOMAINNAME = 'DefaultDomainName'; // noslz
  REGKEY_DEFAULTUSERNAME = 'DefaultUserName'; // noslz
  REGKEY_FAILED = 'Failed'; // noslz
  REGKEY_INSTALLDATE = 'InstallDate'; // noslz
  REGKEY_LASTKNOWNGOOD = 'LastKnownGood'; // noslz
  REGKEY_NTFSDISLASTACCUP = 'NtfsDisableLastAccessUpdate'; // noslz
  REGKEY_PRODUCTID = 'ProductID'; // noslz
  REGKEY_PRODUCTNAME = 'ProductName'; // noslz
  REGKEY_PROFILEIMAGEPATH = 'ProfileImagePath'; // noslz
  REGKEY_REGISTEREDORGANIZATION = 'RegisteredOrganization'; // noslz
  REGKEY_REGISTEREDOWNER = 'RegisteredOwner'; // noslz
  REGKEY_SHUTDOWNTIME = 'ShutdownTime'; // noslz
  REGKEY_STANDARDBIAS = 'StandardBias'; // noslz
  REGKEY_STANDARDNAME = 'StandardName'; // noslz
  REGKEY_STANDARDSTART = 'StandardStart'; // noslz
  REGKEY_SYSTEMROOT = 'SystemRoot'; // noslz
  REGKEY_TIMEZONEKEYNAME = 'TimeZoneKeyName'; // noslz
  SAM_HIVE = 'SAM'; // noslz
  SECURITY_HIVE = 'SECURITY'; // noslz
  SOFTWARE_HIVE = 'SOFTWARE'; // noslz
  SYSTEM_HIVE = 'SYSTEM'; // noslz
  UNDETERMINED_HIVE = 'UNDETERMINED'; // noslz
  USER_HIVE = 'USER'; // noslz
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  HYPHEN = ' - ';
  COLON = ': ';
  SCRIPT_NAME = 'Triage' + HYPHEN + 'Registry';
  CHAR_LENGTH = 90;

  BMF_COMPUTER_INFORMATION = 'Computer Information';
  BMF_COMPUTERNAME = 'Computer Name';
  BMF_CONNECTED_PRINTERS = 'Connected Printers';
  BMF_CONTROLSET = 'Control Sets';
  BMF_EMAIL_CLIENTS = 'Email Clients';
  BMF_MY_BOOKMARKS = 'My Bookmarks';
  BMF_NTFSDISLASTACCUP = 'NTFSDisableLastAccessUpdate';
  BMF_PROFILEIMAGEPATH = 'ProfileImagePath';
  BMF_RECENTDOCS = 'Recent Docs';
  BMF_REGISTRY = 'Registry';
  BMF_SHUTDOWNTIME = 'Shutdown Time';
  BMF_SYSTEMROOT = 'SystemRoot';
  BMF_TIMEZONEINFORMATION = 'TimeZone Information';
  BMF_TRIAGE = 'Triage';
  BMF_UNINSTALLPROGRAMS = 'Uninstall Programs';
  BMF_USBSTOR = 'USBStor Friendly Name';
  BMF_WIRELESS_NETWORKS_WIN7 = 'Wireless Networks (Win 7)';

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
  RRREG31SIGN = 1195725379; // 'creg';
  RRREGNTSIGN = 1718052210; // 'regf';

  CSNONE = 0;
  CSANY = 1;
  CSCURRENT = 2;
  CSDEFAULT = 3;
  CSFAILED = 4;
  CSLASTKNOWNGOOD = 5;

  SPACE = ' ';
  TSWT = 'The script will terminate.';
  PIPE = '|';

  // Global Variables
var
  bl_AutoBookmark_Results: boolean;
  bl_Export_Results_List: boolean;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

type
  TRegHiveType = (hvSOFTWARE, hvSAM, hvSECURITY, hvUSER, hvSYSTEM, hvUSER9X, hvSYSTEM9X, hvANY, hvUNKNOWN);
  TRegDataType = (rdNone, rdString, rdExpandString, rdBinary, rdInteger, rdIntegerBigEndian, rdLink, rdMultiString, rdResourceList, rdFullResourceDescription, rdResourceRequirementsList, rdInt64, rdUnknown);

  TDataType = (dtString, dtUnixTime, dtFileTime, dtSystemTime, dtNetworkListDate, dtHex, dtMRUValue, dtMRUListEx, dtTimeZoneName, dtInteger);

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
    Description: string;
    Device: TEntry;
    Driver: string;
    KeyFullPath: string;
    KeyName: string;
    LastModified: TDateTime;
    Name: string;
    Registry: TEntry;
    ShareName: string;
  end;

  TEmailInfo = class
    Device: TEntry;
    KeyPath: string;
    Name: string;
    Registry: TEntry;
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

  TProfileImagePathInfo = class
    Device: TEntry;
    KeyFullPath: string;
    KeyName: string;
    KeyPath: string;
    KeyData: string;
    Name: string;
    Registry: TEntry;
    UserSID: string;
  end;

  TUninstallProgramsInfo = class
    Device: TEntry;
    KeyName: string;
    KeyPath: string;
    Name: string;
    Registry: TEntry;
  end;

  TUSBStorInfo = class
    Device: TEntry;
    KeyPath: string;
    Name: string;
    Registry: TEntry;
  end;

  TShellBagMRURecord = packed record
    accessed: TDateTime;
    build_path: string;
    created: TDateTime;
    DisplayName: string;
    longname: string;
    modified: TDateTime;
    mru_type: byte;
    shortname: string;
    TypeAsString: string;
  end;

  TRecentDocsInfo = class
    Device: TEntry;
    KeyPath: string;
    Name: string;
    Registry: TEntry;
    ShellBag: TShellBagMRURecord;
  end;

  TTempClassInfo = class
    BookmarkFolder: string;
    Device: TEntry;
    HiveType: string;
    KeyFullPath: string;
    KeyName: string;
    KeyPath: string;
    Registry: TEntry;
    RegistryFullPath: string;
    TempName: string;
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
    BookmarkFolder: string; // Default bookmark folder
    ControlSet: integer;
    DataType: TDataType;
    Hive: TRegHiveType;
    IncludeChildKeys: boolean; // Search recursively through child keys also.
    Key: string; // The registry folder name
    Value: string; // The registry key name
  end;

  TRegSearchResult = class
    Entry: TEntry;
    EntryIdx: integer; // Index in the FRegEntries list
    KeyPath: string; // The registry folder name
    SearchKey: TRegSearchKey;
    function FullPath: string; abstract; virtual; // Full path of the key and value
  end;

  TRegSearchResultKey = class(TRegSearchResult)
    KeyName: string;
    KeyLastModified: TDateTime;
    function FullPath: string; override; // Full path of the key and value
    function GetChildKeys: TStringList;
  end;

  TRegSearchResultValue = class(TRegSearchResult)
    Name: string;
    DataType: TRegDataType;
    Data: pointer;
    DataSize: integer;
    constructor Create;
    destructor Destroy; override;
    function DataAsByteArray(ACount: integer): array of byte;
    function DataAsDword: dword;
    function DataAsFileTimeStr: string;
    function DataAsHexStr(ACount: integer): string;
    function DataAsHexString: string;
    function DataAsInt64: int64;
    function DataAsInteger: integer;
    function DataAsNetworkListDate: string;
    function DataAsString(ForceBinaryToStr: boolean = False): string; // Returns the "Data" as a string
    function DataAsSystemTime: TSystemTime;
    function DataAsSystemTimeStr(full_path_str: string): string;
    function DataAsTimeZoneName: string;
    function DataAsUnixDateTime: TDateTime; // Attempts to convert the "Data" to a DateTime
    function DataAsUnixDateTimeStr: string; // Does AsDateTime then formats as a string
    function FullPath: string; override; // Full path of the key and value
    function ProcessMRUShellBag(var AShellBagRec: TShellBagMRURecord): boolean;
  end;

  TMyRegistry = class
  private
    FControlSets: TObjectList; // List of controls sets for each registry file in FRegEntries. Only used for SYSTEM hives.
    FFoundResults: TObjectList; // List of results after a scan
    FRegEntries: TList; // List of registry files found in the filesystem or registry module - stored as TEntry
    FSearchKeys: TObjectList; // List of keys to search for during scan
    function FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;
    function GetControlSetInfo(Index: integer): TControlSetInfo;
    function GetEntryCount: integer;
    function GetFoundCount: integer;
    function GetFoundKey(Index: integer): TRegSearchResult;
    function GetRegEntry(Index: integer): TEntry;
    procedure SetControlSetInfo(Index: integer; AValue: TControlSetInfo);
  public
    constructor Create;
    destructor Destroy; override;
    function AddKey(AHive: TRegHiveType; AControlSet: integer; ADataType: TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir: string = ''): integer;
    function FindKeys: integer;
    function FindRegFilesByDataStore(const ADataStore: string; aRegEx: string): integer; // Locate registry files in a datastore
    function FindRegFilesByDevice(ADevice: TEntry; aRegEx: string): integer; // Locate registry files on a device
    function GetHiveType(AEntry: TEntry): TRegHiveType;
    function HiveTypeToStr(AHive: TRegHiveType): string;
    procedure AddRegFile(ARegEntry: TEntry);
    procedure ClearKeys;
    procedure ClearResults;
    procedure UpdateControlSets;
    property ControlSetInfo[Index: integer]: TControlSetInfo read GetControlSetInfo write SetControlSetInfo;
    property EntryCount: integer read GetEntryCount;
    property Found[Index: integer]: TRegSearchResult read GetFoundKey;
    property FoundCount: integer read GetFoundCount;
    property GetEntry[Index: integer]: TEntry read GetRegEntry;
    property RegEntries: TList read FRegEntries;

  end;

function GetTimeZoneName(AID: integer): string;
function RPad(const AString: string; AChars: integer): string;
function UnixTimeToDateTime(UnixTime: integer): TDateTime;
procedure BookMark_Create(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
procedure ConsoleLog(ALogType: TLogType; AString: string); overload;
procedure ConsoleLog(AString: string); overload;
procedure ConsoleLogBM(AString: string);
procedure ConsoleLogMemo(AString: string);
procedure ConsoleSection(ASection: string);

var
  BookmarkComment_StringList: TStringList;
  ConsoleLog_StringList: TStringList;
  Memo_StringList: TStringList;

implementation

function GetTimeZoneName(AID: integer): string;
begin
  Result := '';
  case AID of
    460:
      Result := '(UTC+04:30) Kabul';
    461:
      Result := 'Afghanistan Daylight Time';
    462:
      Result := 'Afghanistan Standard Time';
    220:
      Result := '(UTC-09:00) Alaska';
    221:
      Result := 'Alaskan Daylight Time';
    222:
      Result := 'Alaskan Standard Time';
    390:
      Result := '(UTC+03:00) Kuwait, Riyadh';
    391:
      Result := 'Arab Daylight Time';
    392:
      Result := 'Arab Standard Time';
    440:
      Result := '(UTC+04:00) Abu Dhabi, Muscat';
    441:
      Result := 'Arabian Daylight Time';
    442:
      Result := 'Arabian Standard Time';
    400:
      Result := '(UTC+03:00) Baghdad';
    401:
      Result := 'Arabic Daylight Time';
    402:
      Result := 'Arabic Standard Time';
    840:
      Result := '(UTC-03:00) Buenos Aires';
    841:
      Result := 'Argentina Daylight Time';
    842:
      Result := 'Argentina Standard Time';
    80:
      Result := '(UTC-04:00) Atlantic Time (Canada)';
    81:
      Result := 'Atlantic Daylight Time';
    82:
      Result := 'Atlantic Standard Time';
    650:
      Result := '(UTC+09:30) Darwin';
    651:
      Result := 'AUS Central Daylight Time';
    652:
      Result := 'AUS Central Standard Time';
    670:
      Result := '(UTC+10:00) Canberra, Melbourne, Sydney';
    671:
      Result := 'AUS Eastern Daylight Time';
    672:
      Result := 'AUS Eastern Standard Time';
    447:
      Result := '(UTC+04:00) Baku';
    448:
      Result := 'Azerbaijan Daylight Time';
    449:
      Result := 'Azerbaijan Standard Time';
    10:
      Result := '(UTC-01:00) Azores';
    11:
      Result := 'Azores Daylight Time';
    12:
      Result := 'Azores Standard Time';
    140:
      Result := '(UTC-06:00) Saskatchewan';
    141:
      Result := 'Canada Central Daylight Time';
    142:
      Result := 'Canada Central Standard Time';
    20:
      Result := '(UTC-01:00) Cape Verde Is.';
    21:
      Result := 'Cape Verde Daylight Time';
    22:
      Result := 'Cape Verde Standard Time';
    450:
      Result := '(UTC+04:00) Yerevan';
    451:
      Result := 'Caucasus Daylight Time';
    452:
      Result := 'Caucasus Standard Time';
    660:
      Result := '(UTC+09:30) Adelaide';
    661:
      Result := 'Cen. Australia Daylight Time';
    662:
      Result := 'Cen. Australia Standard Time';
    150:
      Result := '(UTC-06:00) Central America';
    151:
      Result := 'Central America Daylight Time';
    152:
      Result := 'Central America Standard Time';
    510:
      Result := '(UTC+06:00) Astana, Dhaka';
    511:
      Result := 'Central Asia Daylight Time';
    512:
      Result := 'Central Asia Standard Time';
    103:
      Result := '(UTC-04:00) Manaus';
    104:
      Result := 'Central Brazilian Daylight Time';
    105:
      Result := 'Central Brazilian Standard Time';
    280:
      Result := '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague';
    281:
      Result := 'Central Europe Daylight Time';
    282:
      Result := 'Central Europe Standard Time';
    290:
      Result := '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb';
    291:
      Result := 'Central European Daylight Time';
    292:
      Result := 'Central European Standard Time';
    720:
      Result := '(UTC+11:00) Magadan, Solomon Is., New Caledonia';
    721:
      Result := 'Central Pacific Daylight Time';
    722:
      Result := 'Central Pacific Standard Time';
    160:
      Result := '(UTC-06:00) Central Time (US & Canada)';
    161:
      Result := 'Central Daylight Time';
    162:
      Result := 'Central Standard Time';
    170:
      Result := '(UTC-06:00) Guadalajara, Mexico City, Monterrey';
    171:
      Result := 'Central Daylight Time (Mexico)';
    172:
      Result := 'Central Standard Time (Mexico)';
    570:
      Result := '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi';
    571:
      Result := 'China Daylight Time';
    572:
      Result := 'China Standard Time';
    250:
      Result := '(UTC-12:00) International Date Line West';
    251:
      Result := 'Dateline Daylight Time';
    252:
      Result := 'Dateline Standard Time';
    410:
      Result := '(UTC+03:00) Nairobi';
    411:
      Result := 'E. Africa Daylight Time';
    412:
      Result := 'E. Africa Standard Time';
    680:
      Result := '(UTC+10:00) Brisbane';
    681:
      Result := 'E. Australia Daylight Time';
    682:
      Result := 'E. Australia Standard Time';
    330:
      Result := '(UTC+02:00) Minsk';
    331:
      Result := 'E. Europe Daylight Time';
    332:
      Result := 'E. Europe Standard Time';
    40:
      Result := '(UTC-03:00) Brasilia';
    41:
      Result := 'E. South America Daylight Time';
    42:
      Result := 'E. South America Standard Time';
    110:
      Result := '(UTC-05:00) Eastern Time (US & Canada)';
    111:
      Result := 'Eastern Daylight Time';
    112:
      Result := 'Eastern Standard Time';
    340:
      Result := '(UTC+02:00) Cairo';
    341:
      Result := 'Egypt Daylight Time';
    342:
      Result := 'Egypt Standard Time';
    470:
      Result := '(UTC+05:00) Ekaterinburg';
    471:
      Result := 'Ekaterinburg Daylight Time';
    472:
      Result := 'Ekaterinburg Standard Time';
    730:
      Result := '(UTC+12:00) Fiji, Kamchatka, Marshall Is.';
    731:
      Result := 'Fiji Daylight Time';
    732:
      Result := 'Fiji Standard Time';
    350:
      Result := '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius';
    351:
      Result := 'FLE Daylight Time';
    352:
      Result := 'FLE Standard Time';
    433:
      Result := '(UTC+03:00) Tbilisi';
    434:
      Result := 'Georgian Daylight Time';
    435:
      Result := 'Georgian Standard Time';
    260:
      Result := '(UTC) Dublin, Edinburgh, Lisbon, London';
    261:
      Result := 'GMT Daylight Time';
    262:
      Result := 'GMT Standard Time';
    50:
      Result := '(UTC-03:00) Greenland';
    51:
      Result := 'Greenland Daylight Time';
    52:
      Result := 'Greenland Standard Time';
    880:
      Result := '(UTC) Monrovia, Reykjavik';
    271:
      Result := 'Greenwich Daylight Time';
    272:
      Result := 'Greenwich Standard Time';
    360:
      Result := '(UTC+02:00) Athens, Bucharest, Istanbul';
    361:
      Result := 'GTB Daylight Time';
    362:
      Result := 'GTB Standard Time';
    230:
      Result := '(UTC-10:00) Hawaii';
    231:
      Result := 'Hawaiian Daylight Time';
    232:
      Result := 'Hawaiian Standard Time';
    490:
      Result := '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi';
    491:
      Result := 'India Daylight Time';
    492:
      Result := 'India Standard Time';
    430:
      Result := '(UTC+03:30) Tehran';
    431:
      Result := 'Iran Daylight Time';
    432:
      Result := 'Iran Standard Time';
    370:
      Result := '(UTC+02:00) Jerusalem';
    371:
      Result := 'Jerusalem Daylight Time';
    372:
      Result := 'Jerusalem Standard Time';
    333:
      Result := '(UTC+02:00) Amman';
    334:
      Result := 'Jordan Daylight Time';
    335:
      Result := 'Jordan Standard Time';
    620:
      Result := '(UTC+09:00) Seoul';
    621:
      Result := 'Korea Daylight Time';
    622:
      Result := 'Korea Standard Time';
    910:
      Result := '(UTC+04:00) Port Louis';
    911:
      Result := 'Mauritius Daylight Time';
    912:
      Result := 'Mauritius Standard Time';
    30:
      Result := '(UTC-02:00) Mid-Atlantic';
    31:
      Result := 'Mid-Atlantic Daylight Time';
    32:
      Result := 'Mid-Atlantic Standard Time';
    363:
      Result := '(UTC+02:00) Beirut';
    364:
      Result := 'Middle East Daylight Time';
    365:
      Result := 'Middle East Standard Time';
    770:
      Result := '(UTC-03:00) Montevideo';
    771:
      Result := 'Montevideo Daylight Time';
    772:
      Result := 'Montevideo Standard Time';
    890:
      Result := '(UTC) Casablanca';
    891:
      Result := 'Morocco Daylight Time';
    892:
      Result := 'Morocco Standard Time';
    190:
      Result := '(UTC-07:00) Mountain Time (US & Canada)';
    191:
      Result := 'Mountain Daylight Time';
    192:
      Result := 'Mountain Standard Time';
    180:
      Result := '(UTC-07:00) Chihuahua, La Paz, Mazatlan';
    181:
      Result := 'Mountain Daylight Time (Mexico)';
    182:
      Result := 'Mountain Standard Time (Mexico)';
    540:
      Result := '(UTC+06:30) Yangon (Rangoon)';
    541:
      Result := 'Myanmar Daylight Time';
    542:
      Result := 'Myanmar Standard Time';
    520:
      Result := '(UTC+06:00) Almaty, Novosibirsk';
    521:
      Result := 'N. Central Asia Daylight Time';
    522:
      Result := 'N. Central Asia Standard Time';
    383:
      Result := '(UTC+02:00) Windhoek';
    384:
      Result := 'Namibia Daylight Time';
    385:
      Result := 'Namibia Standard Time';
    500:
      Result := '(UTC+05:45) Kathmandu';
    501:
      Result := 'Nepal Daylight Time';
    502:
      Result := 'Nepal Standard Time';
    740:
      Result := '(UTC+12:00) Auckland, Wellington';
    741:
      Result := 'New Zealand Daylight Time';
    742:
      Result := 'New Zealand Standard Time';
    70:
      Result := '(UTC-03:30) Newfoundland';
    71:
      Result := 'Newfoundland Daylight Time';
    72:
      Result := 'Newfoundland Standard Time';
    580:
      Result := '(UTC+08:00) Irkutsk, Ulaan Bataar';
    581:
      Result := 'North Asia East Daylight Time';
    582:
      Result := 'North Asia East Standard Time';
    550:
      Result := '(UTC+07:00) Krasnoyarsk';
    551:
      Result := 'North Asia Daylight Time';
    552:
      Result := 'North Asia Standard Time';
    90:
      Result := '(UTC-04:00) Santiago';
    91:
      Result := 'Pacific SA Daylight Time';
    92:
      Result := 'Pacific SA Standard Time';
    210:
      Result := '(UTC-08:00) Pacific Time (US & Canada)';
    211:
      Result := 'Pacific Daylight Time';
    212:
      Result := 'Pacific Standard Time';
    213:
      Result := '(UTC-08:00) Tijuana, Baja California';
    214:
      Result := 'Pacific Daylight Time (Mexico)';
    215:
      Result := 'Pacific Standard Time (Mexico)';
    870:
      Result := '(UTC+05:00) Islamabad, Karachi';
    871:
      Result := 'Pakistan Daylight Time';
    872:
      Result := 'Pakistan Standard Time';
    300:
      Result := '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris';
    301:
      Result := 'Romance Daylight Time';
    302:
      Result := 'Romance Standard Time';
    420:
      Result := '(UTC+03:00) Moscow, St. Petersburg, Volgograd';
    421:
      Result := 'Russian Daylight Time';
    422:
      Result := 'Russian Standard Time';
    830:
      Result := '(UTC-03:00) Georgetown';
    831:
      Result := 'SA Eastern Daylight Time';
    832:
      Result := 'SA Eastern Standard Time';
    120:
      Result := '(UTC-05:00) Bogota, Lima, Quito, Rio Branco';
    121:
      Result := 'SA Pacific Daylight Time';
    122:
      Result := 'SA Pacific Standard Time';
    790:
      Result := '(UTC-04:00) La Paz';
    791:
      Result := 'SA Western Daylight Time';
    792:
      Result := 'SA Western Standard Time';
    240:
      Result := '(UTC-11:00) Midway Island, Samoa';
    241:
      Result := 'Samoa Daylight Time';
    242:
      Result := 'Samoa Standard Time';
    560:
      Result := '(UTC+07:00) Bangkok, Hanoi, Jakarta';
    561:
      Result := 'SE Asia Daylight Time';
    562:
      Result := 'SE Asia Standard Time';
    590:
      Result := '(UTC+08:00) Kuala Lumpur, Singapore';
    591:
      Result := 'Malay Peninsula Daylight Time';
    592:
      Result := 'Malay Peninsula Standard Time';
    380:
      Result := '(UTC+02:00) Harare, Pretoria';
    381:
      Result := 'South Africa Daylight Time';
    382:
      Result := 'South Africa Standard Time';
    530:
      Result := '(UTC+05:30) Sri Jayawardenepura';
    531:
      Result := 'Sri Lanka Daylight Time';
    532:
      Result := 'Sri Lanka Standard Time';
    600:
      Result := '(UTC+08:00) Taipei';
    601:
      Result := 'Taipei Daylight Time';
    602:
      Result := 'Taipei Standard Time';
    690:
      Result := '(UTC+10:00) Hobart';
    691:
      Result := 'Tasmania Daylight Time';
    692:
      Result := 'Tasmania Standard Time';
    630:
      Result := '(UTC+09:00) Osaka, Sapporo, Tokyo';
    631:
      Result := 'Tokyo Daylight Time';
    632:
      Result := 'Tokyo Standard Time';
    750:
      Result := '(UTC+13:00) Nukualofa';
    751:
      Result := 'Tonga Daylight Time';
    752:
      Result := 'Tonga Standard Time';
    130:
      Result := '(UTC-05:00) Indiana (East)';
    131:
      Result := 'US Eastern Daylight Time';
    132:
      Result := 'US Eastern Standard Time';
    200:
      Result := '(UTC-07:00) Arizona';
    201:
      Result := 'US Mountain Daylight Time';
    202:
      Result := 'US Mountain Standard Time';
    930:
      Result := '(UTC) Coordinated Universal Time';
    931:
      Result := 'Coordinated Universal Time';
    932:
      Result := 'Coordinated Universal Time';
    810:
      Result := '(UTC-04:30) Caracas';
    811:
      Result := 'Venezuela Daylight Time';
    812:
      Result := 'Venezuela Standard Time';
    700:
      Result := '(UTC+10:00) Vladivostok';
    701:
      Result := 'Vladivostok Daylight Time';
    702:
      Result := 'Vladivostok Standard Time';
    610:
      Result := '(UTC+08:00) Perth';
    611:
      Result := 'W. Australia Daylight Time';
    612:
      Result := 'W. Australia Standard Time';
    310:
      Result := '(UTC+01:00) West Central Africa';
    311:
      Result := 'W. Central Africa Daylight Time';
    312:
      Result := 'W. Central Africa Standard Time';
    320:
      Result := '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna';
    321:
      Result := 'W. Europe Daylight Time';
    322:
      Result := 'W. Europe Standard Time';
    860:
      Result := '(UTC+05:00) Tashkent';
    481:
      Result := 'West Asia Daylight Time';
    482:
      Result := 'West Asia Standard Time';
    710:
      Result := '(UTC+10:00) Guam, Port Moresby';
    711:
      Result := 'West Pacific Daylight Time';
    712:
      Result := 'West Pacific Standard Time';
    640:
      Result := '(UTC+09:00) Yakutsk';
    641:
      Result := 'Yakutsk Daylight Time';
    642:
      Result := 'Yakutsk Standard Time';
  end;
end;

// Function: Right Pad v2 ------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

// Unix Time to Date Time ------------------------------------------------------
function UnixTimeToDateTime(UnixTime: integer): TDateTime;
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

procedure ConsoleLogMemo(AString: string);
begin
  if assigned(Memo_StringList) then
    if Memo_StringList.Count < 5000 then
      Memo_StringList.Add(AString);
end;

procedure ConsoleLogBM(AString: string);
begin
  if assigned(BookmarkComment_StringList) then
  begin
    if Memo_StringList.Count < 5000 then
      BookmarkComment_StringList.Add(AString);
  end;
end;

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

procedure BookMark_Create(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
var
  bCreate: boolean;
  bmParent, bmNew: TEntry;
  Abm_Source_str2: string;
begin
  if bl_AutoBookmark_Results then
  begin
    Abm_Source_str2 := StringReplace(Abm_Source_str, '\', '-', [rfReplaceAll]);
    // Set the next folder to be then device name + registry file path (ensures multiple registry files on the same system are reported) *
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + ADevice + '\' + BMF_REGISTRY + '\' + UpperCase(Abmf_Hive_Name) + '\' + Abmf_Key_Group + '\' + Abm_Source_str2, bCreate);
    if bCreate then
    begin
      UpdateBookmark(bmParent, Abm_Source_str);
    end;
    bCreate := True;
    bmNew := FindBookmarkByName(bmParent, Abmf_Key_Name, bCreate);
    UpdateBookmark(bmNew, AComment);
  end;
end;

procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
var
  bCreate: boolean;
  bmParent: TEntry;
  DeviceEntry: TEntry;
  device_name_str: string;
begin
  if (assigned(bmdEntry)) and (Progress.isRunning) then
  begin
    DeviceEntry := GetDeviceEntry(bmdEntry);
    device_name_str := DeviceEntry.EntryName;
    device_name_str := StringReplace(device_name_str, '\', '-', [rfReplaceAll]);
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + device_name_str + '\Device', bCreate);
    if assigned(bmParent) and bCreate then
      UpdateBookmark(bmParent, AComment);
    if assigned(bmParent) and ABookmarkEntry and not(IsItemInBookmark(bmParent, bmdEntry)) then
      AddItemsToBookmark(bmParent, DATASTORE_FILESYSTEM, bmdEntry, AFileComment);
  end;
end;

procedure ConsoleSection(ASection: string);
begin
  ConsoleLog(ltMessagesMemo, StringOfChar('=', CHAR_LENGTH));
  ConsoleLog(ltMessagesMemo, '*** ' + ASection + ' ***');
end;

function TRegSearchResultKey.FullPath: string;
begin
  Result := '';
  if (Length(KeyPath) > 0) and (Length(KeyName) > 0) then
  begin
    if KeyPath[Length(KeyPath)] = '\' then
      Result := KeyPath + KeyName
    else
      Result := KeyPath + '\' + KeyName;
  end;
end;

function TRegSearchResultKey.GetChildKeys: TStringList;
var
  EntryReader: TEntryReader;
  ChildKeys: TRawRegistry;
begin
  Result := nil;
  if assigned(Entry) then
  begin
    EntryReader := TEntryReader.Create;
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

constructor TRegSearchResultValue.Create;
begin
  inherited;
  Data := nil;
end;

destructor TRegSearchResultValue.Destroy;
begin
  if Data <> nil then
    FreeMem(Data, DataSize);
  inherited;
end;

function TRegSearchResultValue.FullPath: string;
begin
  Result := '';
  if (Length(KeyPath) > 0) and (Length(Name) > 0) then
  begin
    if KeyPath[Length(KeyPath)] = '\' then
      Result := KeyPath + Name
    else
      Result := KeyPath + '\' + Name;
  end;
end;

// Returns an array of bytes from the Data block, for ACount bytes -------------
function TRegSearchResultValue.DataAsByteArray(ACount: integer): array of byte;
begin
  Result := nil;
  if (DataSize >= ACount) then
  begin
    try
      setlength(Result, ACount);
      move(Data^, Result[0], ACount);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsByteArray'); // noslz
      Result := nil;
    end;
  end;
end;

// Returns key value as a string (tries to convert to str) ---------------------
function TRegSearchResultValue.DataAsString(ForceBinaryToStr: boolean): string;
var
  ba: array of byte;
begin
  Result := '';
  try
    if ForceBinaryToStr then
    begin
      setlength(ba, DataSize + 2); // Add extra two bytes to force binary to be null terminated. Binary reg values that contain Unicode do not always have the terminating bytes
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
          Result := DataAsHexStr(1024 { DataSize } );
      end;
    end;
  except
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsString'); // noslz
    Result := '';
  end;
end;

// Returns a 32 bit signed LE integer ------------------------------------------
function TRegSearchResultValue.DataAsInteger: integer;
begin
  try
    if (DataSize >= 4) then
      move(Data^, Result, 4);
  except
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsInteger');
    Result := -1;
  end;
end;

function TRegSearchResultValue.DataAsHexString: string;
var
  anInt: cardinal;
begin
  anInt := DataAsInteger and $FFFFFFFF;
  Result := '0x' + IntToHex(anInt, 4);
end;

// Returns a 32 bit unsigned LE double word ------------------------------------
function TRegSearchResultValue.DataAsDword: dword;
begin
  try
    if (DataSize >= 4) then
      move(Data^, Result, 4);
  except
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsDword'); // noslz
    Result := 0;
  end;
end;

// Returns a 64 bit signed LE int64 --------------------------------------------
function TRegSearchResultValue.DataAsInt64: int64;
begin
  Result := -1;
  try
    if (DataSize >= 8) then
      move(Data^, Result, 8);
  except
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsInt64'); // noslz
    Result := -1;
  end;
end;

// Returns a Hex dump of binary data -------------------------------------------
function TRegSearchResultValue.DataAsHexStr(ACount: integer): string;
var
  ba: array of byte;
  abyte: byte;
  i: integer;
begin
  Result := '';
  ba := DataAsByteArray(min(DataSize, ACount));
  for i := 0 to Length(ba) - 1 do
  begin
    if not Progress.isRunning then
      break;
    abyte := ba[i];
    Result := Result + IntToHex(abyte, 2) + ' ';
  end;
end;

// Returns Unix date time ------------------------------------------------------
function TRegSearchResultValue.DataAsUnixDateTime: TDateTime;
begin
  Result := UnixTimeToDateTime(DataAsInteger);
end;

// Returns Unix Data Time as a string ------------------------------------------
function TRegSearchResultValue.DataAsUnixDateTimeStr: string;
var
  dt: TDateTime;
begin
  Result := '';
  dt := DataAsUnixDateTime;
  if dt > 0 then
    Result := DateTimeToStr(dt);
end;

// Returns SystemTime  ---------------------------------------------------------
function TRegSearchResultValue.DataAsSystemTime: TSystemTime;
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
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsSystemTime'); // noslz
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
function TRegSearchResultValue.DataAsSystemTimeStr(full_path_str: string): string;
var
  aSysTime: TSystemTime;
  aDateTime: TDateTime;
begin
  try
    aSysTime := DataAsSystemTime;
    aDateTime := SystemTimeToDateTime(aSysTime);
    Result := DateTimeToStr(aDateTime);
  except
    Progress.Log(ATRY_EXCEPT_STR + full_path_str);
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsSystemTimeStr');
    Progress.Log(ATRY_EXCEPT_STR + 'Y:' + IntToStr(aSysTime.wYear) + 'M:' + IntToStr(aSysTime.wMonth) + 'D:' + IntToStr(aSysTime.wDay) + 'H:' + IntToStr(aSysTime.wHour) + 'M:' + IntToStr(aSysTime.wMinute) + 'S:' +
      IntToStr(aSysTime.wSecond)); // noslz
    Progress.Log(ATRY_EXCEPT_STR + FloatToStr(double(aDateTime)));
    Result := '';
  end;
end;

// Returns FileTime as a string ------------------------------------------------
function TRegSearchResultValue.DataAsFileTimeStr: string;
var
  aFileTime: TFileTime;
begin
  try
    if (DataSize >= 8) then
      move(Data^, aFileTime, 8);
    Result := FileTimeToString(aFileTime);
  except
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsFileTimeStr'); // noslz
    Result := '';
  end;
end;

function TRegSearchResultValue.DataAsNetworkListDate: string;
var
  ba: array of byte;
begin
  Result := '{not converted}';
  setlength(ba, 16);
  try
    if (DataSize = 16) then
    begin
      move(Data^, ba[0], 16);
      Result := IntToStr((ba[1] * 256) + ba[0]) + '-' + IntToStr(ba[2]) + '-' + IntToStr(ba[6]) + ' ' + IntToStr(ba[8]) + ':' + IntToStr(ba[10]) + ':' + IntToStr(ba[12]);
    end;
  except
    Progress.Log(ATRY_EXCEPT_STR + 'TRegSearchResultValue.DataAsNetworkListDate'); // noslz
    Result := '';
  end;
  setlength(ba, 0);
end;

// Convert @tzres.dll,-841
function TRegSearchResultValue.DataAsTimeZoneName: string;
var
  tmpstr: string;
  id: integer;
begin
  Result := '';
  tmpstr := DataAsString;
  if Length(tmpstr) > 12 then
  begin
    if pos('@tzres.dll,', tmpstr) = 1 then
    begin
      tmpstr := StringReplace(tmpstr, '@tzres.dll,', '', [rfReplaceAll, rfIgnoreCase]);
      id := abs(StrToInt(tmpstr));
      Result := GetTimeZoneName(id);
    end;
  end;
end;

function TRegSearchResultValue.ProcessMRUShellBag(var AShellBagRec: TShellBagMRURecord): boolean;
var
  struct_size: word;
  bagData: array of byte;
  startpos: integer;
begin
  Result := False;
  bagData := DataAsByteArray(DataSize);
  if Length(bagData) < 10 then
    Exit;

  AShellBagRec.DisplayName := PWideChar(@bagData[0]);
  startpos := Length(AShellBagRec.DisplayName) * 2 + 2;

  // Read length of structure
  struct_size := pword(@bagData[startpos])^;
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
  AShellBagRec.accessed := now(); // strtodate('09-09-13');
  AShellBagRec.created := now(); // strtodate('09-09-13');
  AShellBagRec.modified := now(); // strtodate('09-09-13');
  Result := True;

end;

// Sort by Entry Modified date in descending order
function SortByModifiedDateDesc(Item1, Item2: pointer): integer;
var
  anEntry1: TEntry;
  anEntry2: TEntry;
  date1: TDateTime;
  date2: TDateTime;
begin
  Result := 0;
  if (Item1 <> nil) and (Item2 <> nil) then
  begin
    anEntry1 := TEntry(Item1);
    anEntry2 := TEntry(Item2);
    date1 := anEntry1.modified;
    date2 := anEntry2.modified;
    if date1 < date2 then
      Result := 1
    else if date1 > date2 then
      Result := -1;
  end;
end;

// ------ { TMyRegistry Class } -------------------------------------------------
constructor TMyRegistry.Create;
begin
  inherited Create;
  FRegEntries := TList.Create;
  FFoundResults := TObjectList.Create;
  FFoundResults.OwnsObjects := True;
  FSearchKeys := TObjectList.Create;
  FSearchKeys.OwnsObjects := True;
  FControlSets := TObjectList.Create;
  FControlSets.OwnsObjects := True;
end;

destructor TMyRegistry.Destroy;
begin
  FControlSets.free;
  FSearchKeys.free;
  FFoundResults.free;
  FRegEntries.free;
  inherited Destroy;
end;

// AddKey ----------------------------------------------------------------------
function TMyRegistry.AddKey(AHive: TRegHiveType; AControlSet: integer; ADataType: TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir: string = ''): integer;
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
  newkey.BookmarkFolder := BMDir;
  Result := FSearchKeys.Add(newkey);
end;

function TMyRegistry.GetRegEntry(Index: integer): TEntry;
begin
  Result := TEntry(FRegEntries[Index]);
end;

function TMyRegistry.GetFoundKey(Index: integer): TRegSearchResult;
begin
  Result := TRegSearchResult(FFoundResults[Index]);
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
  Result := FFoundResults.Count;
end;

function TMyRegistry.GetEntryCount: integer;
begin
  Result := FRegEntries.Count;
end;

procedure TMyRegistry.ClearKeys;
begin
  FSearchKeys.Clear;
end;

procedure TMyRegistry.ClearResults;
begin
  FFoundResults.Clear;
end;

function HiveType(const Value: string): TRegHiveType;
begin
  if RegexMatch(Value, '(^|\\)SOFTWARE$', False) then
    Result := hvSOFTWARE
  else if RegexMatch(Value, '(^|\\)SYSTEM$', False) then
    Result := hvSYSTEM
  else if RegexMatch(Value, '(^|\\)SAM$', False) then
    Result := hvSAM
  else if RegexMatch(Value, '(^|\\)SECURITY$', False) then
    Result := hvSECURITY
  else if RegexMatch(Value, '(^|\\)NTUSER\.DAT$', False) then
    Result := hvUSER
  else if RegexMatch(Value, '(^|\\)USER\.DAT$', False) then
    Result := hvUSER9X
  else if RegexMatch(Value, '(^|\\)SYSTEM\.DAT$', False) then
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
  aPropertyTree := nil;
  if ProcessMetadataProperties(AEntry, aPropertyTree) then
  begin
    if assigned(aPropertyTree) then
    begin
      aRootEntry := aPropertyTree.RootProperty;

      if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
      begin
        aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName('Hive File Name')); // noslz
        if assigned(aPropertyNode) then
        begin
          // ConsoleLog(AEntry.EntryName);

          Result := HiveType(Trim(UpperCase(aPropertyNode.PropDisplayValue)));
          // ConsoleLog('Result: ' + HiveTypeToStr(Result));

          if (Result = hvUNKNOWN) then
          begin
            Result := HiveType(Trim(UpperCase(AEntry.EntryName)));
            // ConsoleLog('Result: ' + HiveTypeToStr(Result));
          end;
        end; { assigned aPropertyNode }
      end; { assigned aRootEntry }
    end; { assigned aPropertyTree }
  end;
  if aPropertyTree <> nil then
    aPropertyTree.free;
end;

// Hive type to string ---------------------------------------------------------
function TMyRegistry.HiveTypeToStr(AHive: TRegHiveType): string;
begin
  case AHive of
    hvSOFTWARE:
      Result := SOFTWARE_HIVE;
    hvSAM:
      Result := SAM_HIVE;
    hvSECURITY:
      Result := SECURITY_HIVE;
    hvUSER:
      Result := USER_HIVE;
    hvSYSTEM:
      Result := SYSTEM_HIVE;
    hvUSER9X:
      Result := 'USER98ME';
    hvSYSTEM9X:
      Result := 'SYSTEM98ME';
    hvANY:
      Result := ANY_HIVE;
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
        NewControlSetInfo.ActiveCS := CSNONE;
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

// Locates all registry files
function TMyRegistry.FindRegFilesByDevice(ADevice: TEntry; aRegEx: string): integer;
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
          if RegexMatch(Entry.FullPathName, aRegEx, False) then // Only add those that match the regex
          begin
            aDeterminedFileDriverInfo := Entry.DeterminedFileDriverInfo;
            if (aDeterminedFileDriverInfo.ShortDisplayName = FILESIG_REGISTRY) then // noslz
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

// Add registry file entries to a searchable list
function TMyRegistry.FindRegFilesByDataStore(const ADataStore: string; aRegEx: string): integer;
var
  EntryList: TDataStore;
  Entry: TEntry;
  FileSignatureInfo: TFileTypeInformation;
begin
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
        if Entry.ClassName = 'TSentFromVirtualParent' then
        begin
          AddRegFile(Entry);
          Entry := EntryList.Next;
          Continue;
        end;
        if RegexMatch(Entry.FullPathName, aRegEx, False) then // Only add those that match the regex
        begin
          DetermineFileType(Entry);
          FileSignatureInfo := Entry.DeterminedFileDriverInfo;
          if (FileSignatureInfo.ShortDisplayName = FILESIG_REGISTRY) then
          begin
            AddRegFile(Entry);
            Progress.Log(Entry.EntryName);
          end;
        end;
        Entry := EntryList.Next;
      end;

      if RegexMatch(Entry.FullPathName, aRegEx, False) then // Only add those that match the regex
      begin
        DetermineFileType(Entry);
        FileSignatureInfo := Entry.DeterminedFileDriverInfo;
        if (FileSignatureInfo.ShortDisplayName = FILESIG_REGISTRY) then
        begin
          AddRegFile(Entry);
          Progress.Log(Entry.EntryName);
        end;
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
          if RegexMatch(Entry.FullPathName, aRegEx, False) then // Only add those that match the regex
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

function TMyRegistry.FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;
var
  bytesread: integer;
  csi: TControlSetInfo;
  DataInfo: TRegDataInfo;
  FoundKey: TRegSearchResultKey;
  FoundValue: TRegSearchResultValue;
  slSubKeys: TStringList;
  slValues: TStringList;
  strKeyName: string;
  SubRawReg: TRawRegistry;
  SubSearchKey: TRegSearchKey;
  v, k: integer;
begin
  Result := 0;

  strKeyName := SearchKey.Key;

  if (SearchKey.Hive = hvSYSTEM) and (SearchKey.ControlSet <> CSNONE) then
  begin
    csi := TControlSetInfo(FControlSets[EntryIdx]);
    case SearchKey.ControlSet of
      CSCURRENT:
        strKeyName := '\ControlSet00' + IntToStr(csi.ActiveCS) + SearchKey.Key;
    end;
  end;

  slValues := TStringList.Create;
  slSubKeys := TStringList.Create;
  try
    if RawReg.OpenKey(strKeyName) then
    begin
      FoundKey := TRegSearchResultKey.Create;
      FFoundResults.Add(FoundKey);
      Inc(Result);

      FoundKey.SearchKey := SearchKey;
      FoundKey.Entry := RegEntry;
      FoundKey.KeyPath := RawReg.CurrentPath;
      FoundKey.KeyName := RawReg.CurrentKey;
      FoundKey.KeyLastModified := RawReg.GetCurrentKeyDateTime; // Get the date/time
      FoundKey.EntryIdx := EntryIdx;

      if SearchKey.Value = '*' then
        RawReg.GetValueNames(slValues)
      else
        slValues.Add(SearchKey.Value);

      if SearchKey.IncludeChildKeys and RawReg.GetKeyNames(slSubKeys) and (slSubKeys.Count > 0) then
      begin
        Debug('FindKeys', 'GetKeyNames: ' + strKeyName + ' - ' + IntToStr(slSubKeys.Count));

        SubRawReg := TRawRegistry.Create(EntryReader, False);
        try
          for k := 0 to slSubKeys.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            if SearchKey.IncludeChildKeys then
            begin
              SubSearchKey := TRegSearchKey.Create;
              try
                SubSearchKey.Hive := SearchKey.Hive;
                SubSearchKey.ControlSet := CSNONE;
                SubSearchKey.DataType := SearchKey.DataType;
                SubSearchKey.Key := strKeyName + '\' + slSubKeys[k];
                SubSearchKey.IncludeChildKeys := True;
                SubSearchKey.Value := SearchKey.Value;
                SubSearchKey.BookmarkFolder := SearchKey.BookmarkFolder;

                Debug('FindKeys', 'Finding Sub Keys: ' + strKeyName + '\' + slSubKeys[k]);
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

    // ==================================================================
    // Search for Value List
    // =================================================================
    for v := 0 to slValues.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      // Debug('FindKeys', 'FOUND KEY: '+ Value_StringList[v]);

      if RawReg.OpenKey(strKeyName) and RawReg.GetDataInfo(slValues[v], DataInfo) then
      begin
        FoundValue := TRegSearchResultValue.Create;
        FFoundResults.Add(FoundValue);

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
  EntryReader: TEntryReader;
  HiveType: TRegHiveType;
  r, k, v: integer;
  RawReg: TRawRegistry;
  RegEntry: TEntry;
  SearchKey: TRegSearchKey;

begin
  Progress.DisplayMessage := 'Finding registry keys...';
  Progress.Max := FRegEntries.Count;
  Progress.CurrentPosition := 1;
  Result := 0;
  FFoundResults.Clear;
  RawReg := nil;

  EntryReader := TEntryReader.Create;
  try
    for r := 0 to FRegEntries.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      Progress.IncCurrentProgress;

      RegEntry := GetEntry[r];
      HiveType := GetHiveType(RegEntry); // Determine the type of registry hive

      RawReg := nil;
      try
        for k := 0 to FSearchKeys.Count - 1 do
        begin
          if Not Progress.isRunning then
            break;

          // if k mod 100 = 0 then
          // Debug('FindKeys', 'SearchKey: '+ IntToStr(k));

          SearchKey := TRegSearchKey(FSearchKeys[k]);

          if (SearchKey.Hive = HiveType) or (SearchKey.Hive = hvANY) then
          begin
            if RawReg = nil then
              if EntryReader.OpenData(RegEntry) then
                RawReg := TRawRegistry.Create(EntryReader, False);

            if RawReg = nil then
              break;

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
    for r := 0 to FFoundResults.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if FFoundResults[r] is TRegSearchResultValue then
        Inc(v);
      if FFoundResults[r] is TRegSearchResultKey then
        Inc(k);
    end;

    ConsoleLog('  FoundKeys:   ' + IntToStr(k));
    ConsoleLog('  FoundValues: ' + IntToStr(v));
  end;
end;

// Update Control Sets in and SYSTEM reg files found ---------------------------
procedure TMyRegistry.UpdateControlSets;
var
  i: integer;
  RegResult: TObject;
  RegResultValue: TRegSearchResultValue;
begin
  ClearKeys;
  ClearResults;
  AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', False, REGKEY_CURRENT);
  AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', False, REGKEY_DEFAULT);
  AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', False, REGKEY_FAILED);
  AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', False, REGKEY_LASTKNOWNGOOD);
  FindKeys;
  for i := 0 to FoundCount - 1 do
  begin
    if not Progress.isRunning then
      break;
    RegResult := Found[i];
    if RegResult is TRegSearchResultValue then
    begin
      RegResultValue := TRegSearchResultValue(RegResult);
      if UpperCase(RegResultValue.FullPath) = '\SELECT\CURRENT' then
      begin
        ControlSetInfo[RegResultValue.EntryIdx].CurrentCS := RegResultValue.DataAsInteger;
        ControlSetInfo[RegResultValue.EntryIdx].ActiveCS := ControlSetInfo[RegResultValue.EntryIdx].CurrentCS;
      end
      else if UpperCase(RegResultValue.FullPath) = '\SELECT\DEFAULT' then
        ControlSetInfo[RegResultValue.EntryIdx].DefaultCS := RegResultValue.DataAsInteger
      else if UpperCase(RegResultValue.FullPath) = '\SELECT\FAILED' then
        ControlSetInfo[RegResultValue.EntryIdx].FailedCS := RegResultValue.DataAsInteger
      else if UpperCase(RegResultValue.FullPath) = '\SELECT\LASTKNOWNGOOD' then
        ControlSetInfo[RegResultValue.EntryIdx].LastKnownGoodCS := RegResultValue.DataAsInteger;
    end;
  end;
  ClearKeys;
  ClearResults;
end;

function MyFormatDateTime(aDateTime: TDateTime; isUTC: boolean): string;
var
  str: string;
begin
  Result := '';
  // ConsoleLog(inttohex(int64(ADateTime),8));
  if aDateTime = 0 then
    Result := '{Never}'
  else
  begin
    if isUTC then
      str := ' [UTC]'
    else
      str := ' [Local]';
    Result := FormatDateTime('dd-mmm-yyyy hh:nn:ss', aDateTime) + str;
  end;
end;

procedure ProcessResultValue(Re: TDIPerlRegEx; RegTerm: string; RegResultValue: TRegSearchResultValue; theName: string; ATList: TList);
var
  TempClass: TTempClassInfo;
begin
  if (not assigned(Re)) or (RegTerm = '') or (not assigned(RegResultValue)) or (not assigned(ATList)) then
    Exit;
  Re.MatchPattern := RegTerm;
  Re.SetSubjectStr(RegResultValue.FullPath);
  if Re.Match(0) >= 0 then
  begin
    TempClass := TTempClassInfo.Create;
    TempClass.TempName := theName;
    TempClass.Device := GetDeviceEntry(RegResultValue.Entry);
    TempClass.KeyPath := RegResultValue.KeyPath;
    TempClass.KeyFullPath := RegResultValue.FullPath;

    TempClass.RegistryFullPath := RegResultValue.Entry.FullPathName;
    TempClass.BookmarkFolder := RegResultValue.SearchKey.BookmarkFolder;
    TempClass.KeyName := RegResultValue.Name;
    TempClass.HiveType := RegResultValue.Entry.EntryName;
    ATList.Add(TempClass);
  end;
end;

procedure OutputResult(ATList: TList; AHive_Type: string; Abmf_Key_Group: string; FieldName: string);
var
  BM_Source_str: string;
  BMC_Formatted: string;
  BMF_Key_Name: string;
  BMF_Key_Path: string;
  Device_str: string;
  n: integer;
  rpad_value: integer;

begin
  if (not assigned(ATList)) then
    Exit;

  if not Progress.isRunning then
    Exit;

  If (assigned(ATList) and (ATList.Count > 0)) then
  begin
    ConsoleSection(Abmf_Key_Group);
    rpad_value := 20;
    for n := 0 to ATList.Count - 1 do
    begin
      if not Progress.isRunning then
        Exit;

      Device_str := '';
      BMF_Key_Path := '';
      BMF_Key_Name := '';
      BM_Source_str := '';

      Device_str := TDataEntry(TTempClassInfo(ATList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);

      BMF_Key_Path := TTempClassInfo(ATList[n]).KeyPath;
      BMF_Key_Name := TTempClassInfo(ATList[n]).KeyName;
      BM_Source_str := TTempClassInfo(ATList[n]).RegistryFullPath;

      ConsoleLog(ltMessagesMemo, ((StringOfChar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemo, RPad('Registry File:', rpad_value) + BM_Source_str);
      ConsoleLog(ltMessagesMemo, RPad('Key:', rpad_value) + BMF_Key_Path + '\' + BMF_Key_Name);

      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, RPad(FieldName, rpad_value) + TTempClassInfo(ATList[n]).TempName);
      ConsoleLog(ltBM, RPad('', rpad_value) + TTempClassInfo(ATList[n]).TempName);
      BMC_Formatted := BookmarkComment_StringList.Text;

      if Abmf_Key_Group = BMF_TIMEZONEINFORMATION then
        BM_Source_str := BM_Source_str + BMF_Key_Path;
      BookMark_Create(Device_str, AHive_Type, Abmf_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

    end;
  end;
end;

function GetParentDirectory(const aFilename: string): string;
begin
  Result := extractFileName(ExtractFileDir(aFilename));
end;

// ==============================================================================
// Start of Script
// ==============================================================================
var
  // Boolean
  bl_EvidenceModule: boolean;
  bl_FSNtfsDisLastAccUp: boolean;
  bl_FSProfileImagePath: boolean;
  bl_FSRecentDocs: boolean;
  bl_FSSystemRoot: boolean;
  bl_FSTimeZone: boolean;
  bl_FSTriage: boolean;
  bl_FSUninstallPrograms: boolean;
  bl_FSWirelessNetworks: boolean;
  bl_GUIShow: boolean;
  bl_RegModule: boolean;
  bl_ScriptsModule: boolean;

  // DataStores
  BookmarksEntryList: TDataStore;
  EvidenceEntryList: TDataStore;

  // Entries
  CurrentDevice: TEntry;
  DeviceListEntry: TEntry;
  Entry: TEntry;
  EntryReader: TEntryReader;
  dEntry: TEntry;

  // Info
  Network: TNetworkInfo;
  Printer: TPrinterInfo;
  Email: TEmailInfo;
  TimeZone: TTimeZoneInfo;
  ProfileImagePath: TProfileImagePathInfo;
  UninstallPrograms: TUninstallProgramsInfo;
  USBStor: TUSBStorInfo;
  RecentDocs: TRecentDocsInfo;

  // Integers
  i, k, n, x, y: integer;
  nid: integer;
  regfiles, regcount: integer;
  StartingBookmarkFolder_Count: integer;
  rpad_value: integer;
  bytesread: integer;
  tildpos: integer;

  // Regex
  Re: TDIPerlRegEx;

  // Registry
  DataInfo: TRegDataInfo;
  FoundValue: TRegSearchResultValue;
  RawRegSubKeyValues: TRawRegistry;
  Reg: TMyRegistry;
  RegResult: TRegSearchResult;
  RegResultKey: TRegSearchResultKey;
  RegResultValue: TRegSearchResultValue;

  // Strings
  BM_Source_str: string;
  BMC_Formatted: string;
  BMF_Key_Group: string;
  BMF_Key_Name: string;
  BookmarkComment: string;
  CurrentCaseDir: string;
  Device_str: string;
  ExportDate: string;
  ExportDateTime: string;
  Export_Description: string;
  ExportedDir: string;
  ExportTime: string;
  mstr: string;
  Param: string;
  program_name_str: string;
  source_str: string;
  str_RegFiles_Regex: string;
  The_Source_Str: string;
  valname: string;

  // Starting Checks
  bContinue: boolean;
  CaseName: string;
  StartCheckEntry: TEntry;
  StartCheckDataStore: TDataStore;

  // StringLists
  SubKeyValueList: TStringList;
  UninstallPrograms_StringList: TStringList;

  // TList
  CompInfDefaultDomainList: TList;
  CompInfDefaultUserList: TList;
  CompInfInstallDateList: TList;
  CompInfProductIDList: TList;
  CompInfProductNameList: TList;
  CompInfRegOrgList: TList;
  CompInfRegOwnerList: TList;
  ComputerNameList: TList;
  ConnectedPrintersList: TList;
  csCurrentList: TList;
  csDefaultList: TList;
  csFailedList: TList;
  csLastKnownGoodList: TList;
  DeviceList: TList;
  DeviceToSearchList: TList;
  EmailList: TList;
  NetworkList: TList;
  NTFSDisLastAccUpList: TList;
  ProfileImagePathList: TList;
  RecentDocsList: TList;
  ShutdownTimeList: TList;
  SystemRootList: TList;
  TempClassList: TList;
  TimeZoneList: TList;
  tzActiveTimeBiasList: TList;
  tzBiasList: TList;
  tzDaylightBiasList: TList;
  tzDaylightNameList: TList;
  tzDaylightStartList: TList;
  tzDynamicList: TList;
  tzStandardBiasList: TList;
  tzStandardNameList: TList;
  tzStandardStartList: TList;
  tzTimeZoneKeyNameList: TList;
  UninstallProgramsList: TList;
  USBStorList: TList;

  shellbagrec: TShellBagMRURecord;
  Registry_BM_Fldr_Count: integer;
  bmfolder: TEntry;

label
  Finish;

begin
  BookmarkComment_StringList := nil;
  ConsoleLog_StringList := nil;
  Memo_StringList := nil;
  ConsoleLog(SCRIPT_NAME + ' started...');
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessageNow := 'Starting...';

  // ===========================================================================
  // Starting Checks
  // ===========================================================================
  // Check to see if the FileSystem module is present
  bContinue := True;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      ConsoleLog(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
      bContinue := False;
      Exit;
    end;
    // Check to see if a case is present
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case.' + SPACE + TSWT);
      bContinue := False;
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    // Check to see if there are files in the File System Module
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module.' + SPACE + TSWT);
      bContinue := False;
      Exit;
    end;
    // Exit if user cancels
    if not Progress.isRunning then
    begin
      ConsoleLog('Canceled by user.');
      bContinue := False;
    end;
  finally
    StartCheckDataStore.free;
  end;
  // Continue?
  if Not bContinue then
  begin
    Progress.DisplayMessageNow := SCRIPT_NAME + ' finished.';
    Exit;
  end;
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  // ============================================================================
  // Setup Results Header
  // ============================================================================
  rpad_value := 20;
  Memo_StringList := TStringList.Create;
  ConsoleLog_StringList := TStringList.Create;
  ConsoleLog(ltMessagesMemo, (StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog(RPad('~ Script:', 30) + SCRIPT_NAME);
  ConsoleLog((RPad('~ Parse:', 30) + 'Registry'));
  ConsoleLog(ltMemo, (RPad('Parse:', rpad_value) + 'Registry'));
  ConsoleLog(RPad('~ Date:', 30) + DateTimeToStr(now));
  ConsoleLog(RPad('~ FEX Version', 30) + CurrentVersion);
  ConsoleLog(RPad('~ Case Name:', 30) + CaseName);

  // ============================================================================
  // Device List - Add the evidence items
  // ============================================================================
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Device list:');
  DeviceList := TList.Create;
  EvidenceEntryList := GetDataStore(DATASTORE_EVIDENCE);
  dEntry := EvidenceEntryList.First; // Get the first entry
  while assigned(dEntry) and Progress.isRunning do
  begin
    if dEntry.isDevice then
    begin
      DeviceList.Add(dEntry);
      ConsoleLog(RPad(HYPHEN + 'Added to Device List:', 30) + dEntry.EntryName);
      bmfolder := FindBookmarkByName(BMF_TRIAGE + '\Device' + dEntry.EntryName);
      if assigned(bmfolder) and not IsItemInBookmark(bmfolder, dEntry) then
        BookMarkDevice('', '\Device', '', dEntry, '', True);
    end;
    dEntry := EvidenceEntryList.Next;
  end;
  ConsoleLog(RPad('Device list count:', 30) + IntToStr(DeviceList.Count));
  CurrentDevice := nil;

  // ============================================================================
  // Parameters & Logging
  // ============================================================================
  Param := '';
  if (CmdLine.ParamCount > 0) then
  begin
    ConsoleLog(StringOfChar('-', CHAR_LENGTH));
    ConsoleLog(IntToStr(CmdLine.ParamCount) + ' processing parameters received: ');

    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      ConsoleLog(' - Param ' + IntToStr(i) + ': ' + CmdLine.params[i]);
      Param := Param + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    Trim(Param);
  end
  else
    ConsoleLog('No parameters received.');

  bl_EvidenceModule := False;
  bl_FSNtfsDisLastAccUp := False;
  bl_FSProfileImagePath := False;
  bl_FSRecentDocs := False;
  bl_FSSystemRoot := False;
  bl_FSTimeZone := False;
  bl_FSTriage := False;
  bl_FSUninstallPrograms := False;
  bl_FSWirelessNetworks := False;
  bl_RegModule := False;
  bl_ScriptsModule := False;

  if (CmdLine.params.Indexof(PARAM_EVIDENCEMODULE) <> -1) then
    bl_EvidenceModule := True;
  if (CmdLine.params.Indexof(PARAM_FSNTFSDISLASTACCUP) <> -1) then
    bl_FSNtfsDisLastAccUp := True;
  if (CmdLine.params.Indexof(PARAM_FSPROFILEIMAGEPATH) <> -1) then
    bl_FSProfileImagePath := True;
  if (CmdLine.params.Indexof(PARAM_FSRECENTDOCS) <> -1) then
    bl_FSRecentDocs := True;
  if (CmdLine.params.Indexof(PARAM_FSSYSTEMROOT) <> -1) then
    bl_FSSystemRoot := True;
  if (CmdLine.params.Indexof(PARAM_FSTIMEZONE) <> -1) then
    bl_FSTimeZone := True;
  if (CmdLine.params.Indexof(PARAM_FSTRIAGE) <> -1) then
    bl_FSTriage := True;
  if (CmdLine.params.Indexof(PARAM_FSUNINSTALLPROGRAMS) <> -1) then
    bl_FSUninstallPrograms := True;
  if (CmdLine.params.Indexof(PARAM_FSWIRELESSNETWORKS) <> -1) then
    bl_FSWirelessNetworks := True;
  if (CmdLine.params.Indexof(PARAM_REGISTRYMODULE) <> -1) then
    bl_RegModule := True;
  if CmdLine.ParamCount = 0 then
    bl_ScriptsModule := True;

  if bl_EvidenceModule then
  begin
    bl_GUIShow := False;
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from Evidence module.');
  end;

  if bl_FSTriage then
  begin
    bl_GUIShow := False;
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from FileSystem module Triage.');
  end;

  if bl_FSNtfsDisLastAccUp then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'NTFS Disable Last Access Update';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSDisalbeLastAccessUpdate.');
  end;

  if bl_FSProfileImagePath then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'ProfileImagePath';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSProfileImagePath.');
  end;

  if bl_FSRecentDocs then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Recent Docs';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSRecentDocs.');
  end;

  if bl_FSSystemRoot then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'System Root';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSSystemRoot.');
  end;

  if bl_FSTimeZone then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Time Zone';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSTimeZone.');
  end;

  if bl_FSUninstallPrograms then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Uninstall Programs';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSUnisntallPrograms.');
  end;

  if bl_FSWirelessNetworks then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + HYPHEN + 'Wireless Networks';
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module FSWirelessNetworks.');
  end;

  if bl_RegModule = True then
  begin
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from Registry Module.');
  end;

  if bl_ScriptsModule then
  begin
    bl_GUIShow := True;
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from Scripts module.');
  end;

  // ============================================================================
  // Log Running Options
  // ============================================================================
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog('Options:');

  if bl_GUIShow then
    ConsoleLog(RPad(HYPHEN + 'GUI:', 30) + 'Show')
  else
    ConsoleLog(RPad(HYPHEN + 'GUI:', 30) + 'Hide');

  if bl_AutoBookmark_Results then
    ConsoleLog(RPad(HYPHEN + 'Auto Bookmark Results:', 30) + 'Yes')
  else
    ConsoleLog(RPad(HYPHEN + 'Auto Bookmark Results:', 30) + 'No');

  // ============================================================================
  // Devices to Search List - Add evidence items sent from the triage
  // ============================================================================
  DeviceToSearchList := TList.Create;

  if (CmdLine.ParamCount > 0) and bl_EvidenceModule then
  begin
    ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
    // Create the DeviceToSearchList
    for x := 0 to CmdLine.ParamCount - 1 do
    begin
      if assigned(DeviceList) and (DeviceList.Count > 0) then
      begin
        for y := 0 to DeviceList.Count - 1 do
        begin
          DeviceListEntry := TEntry(DeviceList.items[y]);
          if (DeviceListEntry.EntryName = CmdLine.params[x]) then
          begin
            DeviceToSearchList.Add(DeviceListEntry);
            ConsoleLog(RPad('Added to Device Search List:', 30) + DeviceListEntry.EntryName);
            break;
          end;
        end;
      end;
    end;
  end
  else
  begin
    ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
    ConsoleLog('Searching ALL devices:');
    for y := 0 to DeviceList.Count - 1 do
    begin
      DeviceListEntry := TEntry(DeviceList.items[y]);
      ConsoleLog(RPad(HYPHEN + 'Searching:', 30) + DeviceListEntry.EntryName);
    end;
  end;

  // ============================================================================
  // Count the existing Bookmarks folders
  // ============================================================================
  BookmarksEntryList := GetDataStore(DATASTORE_BOOKMARKS);
  StartingBookmarkFolder_Count := BookmarksEntryList.Count;
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog(RPad('Starting Bookmark folders:', 30) + (IntToStr(BookmarksEntryList.Count)));

  // ============================================================================
  // Find the registry files in the File System
  // ============================================================================
  Reg := TMyRegistry.Create;
  Reg.RegEntries.Clear; // Clear the searchable list of reg files

  str_RegFiles_Regex := '\\(SOFTWARE|SYSTEM|SAM|NTUSER\.DAT)$';

  if bl_FSRecentDocs then
    str_RegFiles_Regex := 'NTUSER.DAT$';
  if bl_FSTimeZone or bl_FSNtfsDisLastAccUp then
    str_RegFiles_Regex := 'SYSTEM$';
  if bl_FSWirelessNetworks or bl_FSSystemRoot or bl_FSUninstallPrograms or bl_FSProfileImagePath then
    str_RegFiles_Regex := 'SOFTWARE$';

  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog('The Regex search string is:');
  ConsoleLog('  ' + str_RegFiles_Regex);
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));

  Progress.DisplayMessage := 'Finding registry files...';
  ConsoleLog('Finding registry files...');
  regfiles := 0;

  // ============================================================================
  // Start Processing based on the parameter/s received
  // ============================================================================
  if bl_FSNtfsDisLastAccUp = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSProfileImagePath = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSRecentDocs = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSSystemRoot = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSTimeZone = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSTriage = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSUninstallPrograms = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSWirelessNetworks = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_RegModule = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_REGISTRY, str_RegFiles_Regex)
  else if bl_ScriptsModule = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else

    if bl_EvidenceModule then
  begin
    if assigned(DeviceToSearchList) and (DeviceToSearchList.Count > 0) then
    begin
      ConsoleLog('Device count: ' + IntToStr(DeviceToSearchList.Count));
      for x := 0 to DeviceToSearchList.Count - 1 do
      begin
        regfiles := Reg.FindRegFilesByDevice(TEntry(DeviceToSearchList.items[x]), str_RegFiles_Regex);
      end;
    end;
  end;
  Reg.RegEntries.Sort(@SortByModifiedDateDesc);

  // ============================================================================
  // Exit if no Registry files found
  // ============================================================================
  ConsoleLog(IntToStr(regfiles) + ' registry files located:');

  if regfiles = 0 then
  begin
    ConsoleLog('No registry files were located.' + SPACE + TSWT);

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
      ConsoleLog(HYPHEN + 'Processing Registry File: ' + TEntry(Reg.RegEntries.items[i - 1]).FullPathName);
  end;
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Updating control set info for SYSTEM hives.');
  Reg.UpdateControlSets; // WARNING - this will clear results and any keys added previously added
  ConsoleLog('Finished updating SYSTEM control set.');

  // ============================================================================
  // Add keys to the search list
  // ============================================================================
  // These keys are run from the Triage button dropdown. They should be exactly the same as below where all keys are run.                       //child keys
  if bl_FSNtfsDisLastAccUp then
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtInteger, '\Control\FileSystem', False, REGKEY_NTFSDISLASTACCUP, BMF_NTFSDISLASTACCUP)
  else if bl_FSProfileImagePath then
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\ProfileList', True, REGKEY_PROFILEIMAGEPATH, BMF_PROFILEIMAGEPATH)
  else if bl_FSRecentDocs then
    Reg.AddKey(hvUSER, CSNONE, dtString, '\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs', True, '*', BMF_RECENTDOCS)
  else if bl_FSSystemRoot then
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion', False, REGKEY_SYSTEMROOT, BMF_SYSTEMROOT)
  else if bl_FSTimeZone then
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtHex, '\Control\TimeZoneInformation', True, '*', BMF_TIMEZONEINFORMATION)
  else if bl_FSUninstallPrograms then
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows\CurrentVersion\Uninstall', True, '*', BMF_UNINSTALLPROGRAMS)
  else if bl_FSWirelessNetworks then
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles', True, '*', BMF_WIRELESS_NETWORKS_WIN7)
  else
  begin
    // SOFTWARE ------------------------------------------------------------------
    // ADDKEY  HiveType    Cntrl     KeyType         A Key                                          Include Child Keys  Value                          Bookmark Group
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Clients\Mail', True, '*', BMF_EMAIL_CLIENTS);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion', False, REGKEY_SYSTEMROOT, BMF_SYSTEMROOT);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion', True, REGKEY_PRODUCTID, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion', True, REGKEY_PRODUCTNAME, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion', True, REGKEY_REGISTEREDORGANIZATION, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion', True, REGKEY_REGISTEREDOWNER, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles', True, '*', BMF_WIRELESS_NETWORKS_WIN7);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\Print\Printers', True, '*', BMF_CONNECTED_PRINTERS);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\ProfileList', True, REGKEY_PROFILEIMAGEPATH, BMF_PROFILEIMAGEPATH);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\Winlogon', True, REGKEY_DEFAULTDOMAINNAME, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\Winlogon', True, REGKEY_DEFAULTUSERNAME, BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows\CurrentVersion\Uninstall', True, '*', BMF_UNINSTALLPROGRAMS);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtString, '\Microsoft\Windows NT\CurrentVersion\Winlogon', True, 'AltDefaultDomainName', BMF_COMPUTER_INFORMATION);
    Reg.AddKey(hvSOFTWARE, CSNONE, dtUnixTime, '\Microsoft\Windows NT\CurrentVersion', True, REGKEY_INSTALLDATE, BMF_COMPUTER_INFORMATION);

    // SYSTEM --------------------------------------------------------------------
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtString, '\Control\ComputerName\ComputerName', True, REGKEY_COMPUTERNAME, BMF_COMPUTERNAME);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtInteger, '\Control\FileSystem', False, REGKEY_NTFSDISLASTACCUP, BMF_NTFSDISLASTACCUP);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtFileTime, '\Control\Windows', True, REGKEY_SHUTDOWNTIME, BMF_SHUTDOWNTIME);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtHex, '\Control\TimeZoneInformation', True, REGKEY_DAYLIGHTSTART, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtHex, '\Control\TimeZoneInformation', True, REGKEY_STANDARDSTART, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtInteger, '\Control\TimeZoneInformation', True, REGKEY_ACTIVETIMEBIAS, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtInteger, '\Control\TimeZoneInformation', True, REGKEY_BIAS, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtInteger, '\Control\TimeZoneInformation', True, REGKEY_DAYLIGHTBIAS, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtInteger, '\Control\TimeZoneInformation', True, REGKEY_STANDARDBIAS, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtString, '\Control\TimeZoneInformation', True, REGKEY_TIMEZONEKEYNAME, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtString, '\Enum\USBSTOR', True, 'FriendlyName', BMF_USBSTOR);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtTimeZoneName, '\Control\TimeZoneInformation', True, REGKEY_DAYLIGHTNAME, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSCURRENT, dtTimeZoneName, '\Control\TimeZoneInformation', True, REGKEY_STANDARDNAME, BMF_TIMEZONEINFORMATION);
    Reg.AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', True, REGKEY_CURRENT, BMF_CONTROLSET);
    Reg.AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', True, REGKEY_DEFAULT, BMF_CONTROLSET);
    Reg.AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', True, REGKEY_FAILED, BMF_CONTROLSET);
    Reg.AddKey(hvSYSTEM, CSNONE, dtInteger, '\Select', True, REGKEY_LASTKNOWNGOOD, BMF_CONTROLSET);

    // NTUSER.DAT ----------------------------------------------------------------
    // Reg.AddKey(hvUSER,   CSNONE,   dtString,       '\Printers\Defaults',                                                                 True, '*',         'Printer Defaults');
    Reg.AddKey(hvUSER, CSNONE, dtString, '\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs', True, '*', BMF_RECENTDOCS);
    // Reg.AddKey(hvUSER,   CSNONE,   dtMRUListEx,    '\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery',                 True, '*',         'WordWheelQuery');
    // Reg.AddKey(hvUSER,   CSNONE,   dtString,       '\NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU', True, 'MRUListEx', 'Last Visited MRU');
    // Reg.AddKey(hvUSER,   CSNONE,   dtString,       '\Software\Microsoft\Internet Explorer\TypedURLs',                                    True, '*',         'IE Typed URLS');
    // Reg.AddKey(hvUSER,   CSNONE,   dtString,       '\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU',                         True, 'MRUListEx', 'ExplorerRunMru');
  end;

  // ============================================================================
  // Search for Keys
  // ============================================================================
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Searching for registry keys of interest...');

  regcount := Reg.FindKeys;
  // ConsoleLog('Total: ' + IntToStr(Reg.FoundCount));

  // Progress.Initialize(Reg.FoundCount, 'Processing Registry Files...');
  Progress.DisplayMessageNow := 'Processing registry files...';
  Progress.Max := Reg.FoundCount;
  Progress.CurrentPosition := 1;

  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess];

  CompInfDefaultDomainList := TList.Create;
  CompInfDefaultUserList := TList.Create;
  CompInfInstallDateList := TList.Create;
  CompInfProductIDList := TList.Create;
  CompInfProductNameList := TList.Create;
  CompInfRegOrgList := TList.Create;
  CompInfRegOwnerList := TList.Create;
  ComputerNameList := TList.Create;
  ConnectedPrintersList := TList.Create;
  csCurrentList := TList.Create;
  csDefaultList := TList.Create;
  csFailedList := TList.Create;
  csLastKnownGoodList := TList.Create;
  EmailList := TList.Create;
  NetworkList := TList.Create;
  NTFSDisLastAccUpList := TList.Create;
  ProfileImagePathList := TList.Create;
  RecentDocsList := TList.Create;
  ShutdownTimeList := TList.Create;
  SystemRootList := TList.Create;
  TempClassList := TList.Create;
  TimeZoneList := TList.Create;
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
  UninstallProgramsList := TList.Create;
  USBStorList := TList.Create;

  // ============================================================================
  // Iterate Reg results
  // ============================================================================
  for i := 0 to Reg.FoundCount - 1 do
  begin
    if not Progress.isRunning then
      break;
    Progress.IncCurrentProgress;
    RegResult := Reg.Found[i];

    // =========================================================================
    // RegResult - Process as Values
    // =========================================================================
    if RegResult is TRegSearchResultValue then
    begin
      RegResultValue := TRegSearchResultValue(RegResult);
      Re.MatchPattern := '(\\(Microsoft|Select|Control|Enum|CurrentVersion|Printers)\\)' + // Must start with
        '(' + // Then contain starting bracket

        'ComputerName\\ComputerName\\ComputerName$' + PIPE + 'Current$' + PIPE + 'Default$' + PIPE + 'DEFAULTS\\' + PIPE + 'Failed$' + PIPE + 'FileSystem\\NtfsDisableLastAccessUpdate$' + PIPE + 'LastKnownGood$' + PIPE + 'Mail\\([^\\]+)$' +
        PIPE + 'Explorer\\Recentdocs\\([0-9]*$|..*\\[0-9]*$)' + PIPE + 'USBSTOR\\.*\\FriendlyName$' + PIPE + 'Windows NT\\CurrentVersion\\Print\\Printers\\([^\\]+)$' + PIPE + 'Windows\\CurrentVersion\\Uninstall\\.*\\DisplayName$' + PIPE +
        'Windows\\ShutdownTime$' + PIPE +

        '((Windows NT\\CurrentVersion\\)' + // No pipe here
        '(InstallDate$' + PIPE + 'ProductID$' + PIPE + 'ProductName$' + PIPE + 'RegisteredOrganization$' + PIPE + 'RegisteredOwner$|SystemRoot$' + PIPE + 'ProfileList\\.*\\ProfileImagePath$' + PIPE + 'Winlogon\\DefaultDomainName$' + PIPE +
        'Winlogon\\DefaultUserName$|NetworkList\\Profiles\\(\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})\\([^\\]+)$' + PIPE + 'Print\\Printers\\([^\\]+)\\([^\\]+)$))' + PIPE +

        '((TimeZoneInformation\\)' + '(ActiveTimeBias|Bias|DaylightBias|DaylightName|DaylightStart|DynamicDaylightTimeDisabled|StandardBias|StandardName|StandardStart|TimeZoneKeyName)$)' +

        ')'; // Then contain ending bracket

      Re.SetSubjectStr(RegResultValue.FullPath);
      if Re.Match(0) >= 0 then
      begin
        // -----------------------------------------------------------------------
        // RegResult - Process as Value - Individual Keys
        // -----------------------------------------------------------------------
        // SOFTWARE - Computer Information
        ProcessResultValue(Re, '\\Control\\Windows\\ShutdownTime$', RegResultValue, RegResultValue.DataAsFileTimeStr, ShutdownTimeList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\InstallDate$', RegResultValue, RegResultValue.DataAsUnixDateTimeStr, CompInfInstallDateList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\ProductID$', RegResultValue, RegResultValue.DataAsString, CompInfProductIDList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\ProductName$', RegResultValue, RegResultValue.DataAsString, CompInfProductNameList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\RegisteredOrganization$', RegResultValue, RegResultValue.DataAsString, CompInfRegOrgList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\RegisteredOwner$', RegResultValue, RegResultValue.DataAsString, CompInfRegOwnerList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\SystemRoot$', RegResultValue, RegResultValue.DataAsString, SystemRootList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\DefaultDomainName$', RegResultValue, RegResultValue.DataAsString, CompInfDefaultDomainList);
        ProcessResultValue(Re, '\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\\DefaultUserName$', RegResultValue, RegResultValue.DataAsString, CompInfDefaultUserList);
        // SYSTEM - Control Set
        ProcessResultValue(Re, '\\Select\\Current$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), csCurrentList);
        ProcessResultValue(Re, '\\Select\\Default$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), csDefaultList);
        ProcessResultValue(Re, '\\Select\\Failed$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), csFailedList);
        ProcessResultValue(Re, '\\Select\\LastKnownGood$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), csLastKnownGoodList);
        // SYSTEM - TimeZone
        ProcessResultValue(Re, '\\Control\\ComputerName\\ComputerName\\ComputerName$', RegResultValue, RegResultValue.DataAsString, ComputerNameList);
        // SYSTEM - NTFS Disable Last Access Update
        ProcessResultValue(Re, '\\Control\\FileSystem\\NtfsDisableLastAccessUpdate$', RegResultValue, RegResultValue.DataAsHexString, NTFSDisLastAccUpList);

        if not bl_FSTimeZone then
        begin
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\ActiveTimeBias$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), tzActiveTimeBiasList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\Bias$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), tzBiasList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\DaylightBias$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), tzDaylightBiasList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\DaylightName$', RegResultValue, RegResultValue.DataAsTimeZoneName, tzDaylightNameList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\DaylightStart$', RegResultValue, RegResultValue.DataAsHexStr(16), tzDaylightStartList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\DynamicDaylightTimeDisabled$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), tzDynamicList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\StandardBias$', RegResultValue, IntToStr(RegResultValue.DataAsInteger), tzStandardBiasList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\StandardName$', RegResultValue, RegResultValue.DataAsTimeZoneName, tzStandardNameList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\StandardStart$', RegResultValue, RegResultValue.DataAsHexStr(16), tzStandardStartList);
          ProcessResultValue(Re, '\\Control\\TimeZoneInformation\\TimeZoneKeyName$', RegResultValue, RegResultValue.DataAsString, tzTimeZoneKeyNameList);
        end;

        // -----------------------------------------------------------------------
        // RegResult - ProfileImagePath
        // -----------------------------------------------------------------------
        Re.MatchPattern := 'Windows NT\\CurrentVersion\\ProfileList\\.*\\ProfileImagePath$';
        Re.SetSubjectStr(RegResultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            ProfileImagePath := TProfileImagePathInfo.Create;
            ProfileImagePath.Device := GetDeviceEntry(RegResultValue.Entry);
            ProfileImagePath.Registry := RegResultValue.Entry; // Entry is the Hive
            ProfileImagePath.KeyPath := TRegSearchResultKey(RegResult).FullPath;
            ProfileImagePath.UserSID := GetParentDirectory(ProfileImagePath.KeyPath);
            ProfileImagePath.Name := TRegSearchResultKey(RegResult).KeyName;
            ProfileImagePath.KeyName := TRegSearchResultKey(RegResult).KeyName;
            ProfileImagePath.KeyData := RegResultValue.DataAsString;
            ProfileImagePathList.Add(ProfileImagePath);
          end;
        end

        else

          // -----------------------------------------------------------------------
          // RegResult - Process as Value - NetworkList
          // -----------------------------------------------------------------------
          Re.MatchPattern := '^\\Microsoft\\Windows NT\\CurrentVersion\\NetworkList\\Profiles\\(\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})\\([^\\]+)$';
        Re.SetSubjectStr(RegResultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 3) then
          begin
            nid := -1;
            for n := 0 to NetworkList.Count - 1 do
            begin
              if (TNetworkInfo(NetworkList[n]).GUID = UpperCase(Re.Substr(1))) and (TNetworkInfo(NetworkList[n]).Registry = RegResultValue.Entry) and (TNetworkInfo(NetworkList[n]).Device = GetDeviceEntry(RegResultValue.Entry)) then
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
              Network.Registry := RegResultValue.Entry;
              Network.Device := GetDeviceEntry(RegResultValue.Entry);
              Network.KeyFullPath := RegResultValue.FullPath;
              NetworkList.Add(Network);
            end;
            valname := UpperCase(Re.Substr(2));
            if valname = 'PROFILENAME' then
              Network.ProfileName := RegResultValue.DataAsString
            else if valname = 'DESCRIPTION' then
              Network.Description := RegResultValue.DataAsString
            else if valname = 'DATECREATED' then
              Network.DateCreated := RegResultValue.DataAsNetworkListDate
            else if valname = 'DATELASTCONNECTED' then
              Network.LastConnected := RegResultValue.DataAsNetworkListDate;
          end;
        end

        else

        // -----------------------------------------------------------------------
        // RegResult - Process as Value - Connected Printers
        // -----------------------------------------------------------------------
        begin
          Re.MatchPattern := '^\\Microsoft\\Windows NT\\CurrentVersion\\Print\\Printers\\([^\\]+)\\([^\\]+)$';
          Re.SetSubjectStr(RegResultValue.FullPath);
          if Re.Match(0) >= 0 then
          begin
            mstr := Re.MatchedStrPtr;
            if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 3) then
            begin
              nid := -1;
              for n := 0 to ConnectedPrintersList.Count - 1 do
              begin
                if not Progress.isRunning then
                  break;
                if (TPrinterInfo(ConnectedPrintersList[n]).Name = UpperCase(Re.Substr(1))) and (TPrinterInfo(ConnectedPrintersList[n]).Registry = RegResultValue.Entry) and
                  (TPrinterInfo(ConnectedPrintersList[n]).Device = GetDeviceEntry(RegResultValue.Entry)) then
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
                Printer.Registry := RegResultValue.Entry;
                Printer.Device := GetDeviceEntry(RegResultValue.Entry);
                ConnectedPrintersList.Add(Printer);
              end;
              valname := UpperCase(Re.Substr(2));
              if valname = 'SHARE NAME' then
                Printer.ShareName := RegResultValue.DataAsString
              else if valname = 'PRINTER DRIVER' then
                Printer.Driver := RegResultValue.DataAsString
              else if valname = 'DESCRIPTION' then
                Printer.Description := RegResultValue.DataAsString;
            end;
          end
          else
          begin
            BookmarkComment := ''; // GDH
            // // Process as Value --------------------------------------------------
            // RegResultValue := TRegSearchResultValue(RegResult);
            // case RegResultValue.SearchKey.DataType of
            // dtInteger:
            // BookmarkComment := IntToStr(RegResultValue.DataAsInteger);
            // dtFileTime:
            // BookmarkComment := RegResultValue.DataAsFileTimeStr;
            // dtUnixTime:
            // BookmarkComment := RegResultValue.DataAsUnixDateTimeStr;
            // dtSystemTime:
            // BookmarkComment := RegResultValue.DataAsSystemTimeStr(RegResultValue.FullPath);
            // dtNetworkListDate:
            // BookmarkComment := RegResultValue.DataAsNetworkListDate;
            // dtString:
            // BookmarkComment := RegResultValue.DataAsString;
            // dtHex:
            // BookmarkComment := RegResultValue.DataAsHexStr(min(RegResultValue.DataSize, 50));
            // dtMRUListEx:
            // BookmarkComment := RegResultValue.DataAsString;
            // dtMRUValue:
            // BookmarkComment := RegResultValue.DataAsString;
            // dtTimeZoneName:
            // BookmarkComment := RegResultValue.DataAsTimeZoneName;
            // else
            // BookmarkComment := RegResultValue.DataAsString;
            // end;
          end;
        end;

        // -----------------------------------------------------------------------
        // RegResult - Process as Value - USBStor FriendlyName
        // -----------------------------------------------------------------------
        Re.MatchPattern := '\\Enum\\USBSTOR\\.*\\FriendlyName$';
        Re.SetSubjectStr(RegResultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            USBStor := TUSBStorInfo.Create;
            USBStor.Registry := RegResultValue.Entry;
            USBStor.Device := GetDeviceEntry(RegResultValue.Entry);
            USBStor.Name := RegResultValue.DataAsString;
            USBStor.KeyPath := TRegSearchResultKey(RegResult).FullPath;
            USBStorList.Add(USBStor);
          end;
        end;

        // -----------------------------------------------------------------------
        // RegResult - Process as Value - RecentDocs
        // -----------------------------------------------------------------------
        Re.MatchPattern := '\\CurrentVersion\\Explorer\\Recentdocs\\([0-9]*$|..*\\[0-9]*$)';
        Re.SetSubjectStr(RegResultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            RecentDocs := TRecentDocsInfo.Create;
            RecentDocs.Registry := RegResultValue.Entry;
            RecentDocs.Device := GetDeviceEntry(RegResultValue.Entry);
            if RegResultValue.ProcessMRUShellBag(shellbagrec) then
            begin
              RecentDocs.ShellBag := shellbagrec;
            end;

            RecentDocs.Name := RegResultValue.DataAsString(True);
            RecentDocs.KeyPath := TRegSearchResultKey(RegResult).FullPath;
            RecentDocsList.Add(RecentDocs);
          end;
        end;

        // -----------------------------------------------------------------------
        // RegResult - Process as Value - UninstallPrograms
        // -----------------------------------------------------------------------
        Re.MatchPattern := '\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\.*\\DisplayName$';
        Re.SetSubjectStr(RegResultValue.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            UninstallPrograms := TUninstallProgramsInfo.Create;
            UninstallPrograms.Registry := RegResultValue.Entry;
            UninstallPrograms.Device := GetDeviceEntry(RegResultValue.Entry);
            UninstallPrograms.Name := RegResultValue.DataAsString;
            UninstallPrograms.KeyPath := TRegSearchResultKey(RegResult).FullPath;
            UninstallProgramsList.Add(UninstallPrograms);
          end;
        end;

        // -----------------------------------------------------------------------
        // RegResult - Process as Value - TimeZone
        // -----------------------------------------------------------------------
        if bl_FSTimeZone then
        begin
          Re.MatchPattern := '\\Control\\TimeZoneInformation\\(ActiveTimeBias|Bias|DaylightBias|TimeZoneKeyName|StandardName|StandardBias|DaylightName)$';
          Re.SetSubjectStr(RegResultValue.FullPath);
          if Re.Match(0) >= 0 then
          begin
            mstr := Re.MatchedStrPtr;
            if (mstr <> '') and (Re.MatchedStrLength > 0) then
            begin
              TimeZone := TTimeZoneInfo.Create;
              TimeZone.Registry := RegResultValue.Entry;
              TimeZone.Device := GetDeviceEntry(RegResultValue.Entry);

              if pos('StandardName', RegResultValue.FullPath) > 0 then
                TimeZone.tzStandardName := RegResultValue.DataAsTimeZoneName;

              if pos('TimeZoneKeyName', RegResultValue.FullPath) > 0 then
                TimeZone.tzTimeZoneKeyName := RegResultValue.DataAsString(True);

              if pos('DaylightName', RegResultValue.FullPath) > 0 then
                TimeZone.tzDaylightName := RegResultValue.DataAsTimeZoneName;

              if pos('StandardBias', RegResultValue.FullPath) > 0 then
                TimeZone.tzStandardBias := RegResultValue.DataAsInteger;

              if RegexMatch(RegResultValue.FullPath, '\\Control\\TimeZoneInformation\\Bias$', False) then
                TimeZone.tzBias := RegResultValue.DataAsInteger;

              if pos('ActiveTimeBias', RegResultValue.FullPath) > 0 then
                TimeZone.tzActiveTimeBias := RegResultValue.DataAsInteger;

              if pos('DaylightBias', RegResultValue.FullPath) > 0 then
                TimeZone.tzDaylightBias := RegResultValue.DataAsInteger;

              TimeZone.KeyPath := TRegSearchResultKey(RegResult).FullPath;
              TimeZoneList.Add(TimeZone);
            end;
          end;
        end;
      end;
    end { Regresult Values }
    else

      // =========================================================================
      // RegResult - Process as Key
      // =========================================================================
      if RegResult is TRegSearchResultKey then
      begin
        RegResultKey := TRegSearchResultKey(RegResult);

        // -----------------------------------------------------------------------
        // RegResult - Process as Key - Connected Printers Date Last Modified
        // -----------------------------------------------------------------------
        Re.MatchPattern := '^\\Microsoft\\Windows NT\\CurrentVersion\\Print\\Printers\\([^\\]+)$'; // only want the Key - no values
        Re.SetSubjectStr(RegResultKey.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 2) then
          begin
            nid := -1;
            for n := 0 to ConnectedPrintersList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              if (TPrinterInfo(ConnectedPrintersList[n]).Name = UpperCase(Re.Substr(1))) and (TPrinterInfo(ConnectedPrintersList[n]).Registry = RegResultKey.Entry) and
                (TPrinterInfo(ConnectedPrintersList[n]).Device = GetDeviceEntry(RegResultKey.Entry)) then
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
              Printer.Registry := RegResultKey.Entry;
              Printer.Device := GetDeviceEntry(RegResultKey.Entry);
              Printer.KeyName := RegResultKey.KeyName;
              Printer.KeyFullPath := RegResultKey.FullPath;
              ConnectedPrintersList.Add(Printer);
            end;
            Printer.LastModified := RegResultKey.KeyLastModified;
          end;
        end;

        // -----------------------------------------------------------------------
        // RegResult - Process as Key - Printer Defaults
        // -----------------------------------------------------------------------
        if pos('\PRINTERS\DEFAULTS\', UpperCase(TRegSearchResultKey(RegResult).FullPath)) > 0 then
        begin
          if (Length(TRegSearchResultKey(RegResult).KeyName) = 38) and (TRegSearchResultKey(RegResult).KeyName[1] = '{') then // GUIDs are always 38 chars long and start with {
          begin
            EntryReader := TEntryReader.Create;
            if EntryReader.OpenData(RegResultKey.Entry) then
            begin
              // Get the sub key values - the first value should be default
              RawRegSubKeyValues := TRawRegistry.Create(EntryReader, False);
              if RawRegSubKeyValues.OpenKey(TRegSearchResultKey(RegResult).FullPath) then
              begin
                SubKeyValueList := TStringList.Create;
                SubKeyValueList.Clear;
                if RawRegSubKeyValues.GetValueNames(SubKeyValueList) then
                begin
                  for k := 0 to SubKeyValueList.Count - 1 do
                  begin
                    if not Progress.isRunning then
                      break;
                    if SubKeyValueList[k] = '' then // SubKeyValueList[k] := '(default)';
                    begin
                      if RawRegSubKeyValues.GetDataInfo(SubKeyValueList[k], DataInfo) then
                      begin
                        // ConsoleLog(IntToStr(k) + ':' + SubKeyValueList[k]);
                        FoundValue := TRegSearchResultValue.Create;
                        FoundValue.Entry := RegResultKey.Entry;
                        FoundValue.KeyPath := RegResultKey.FullPath + '\';
                        FoundValue.Name := SubKeyValueList[k];
                        FoundValue.DataType := DataInfo.RegData;
                        FoundValue.DataSize := DataInfo.DataSize;
                        FoundValue.Data := nil;
                        GetMem(FoundValue.Data, FoundValue.DataSize);
                        FillChar(FoundValue.Data^, FoundValue.DataSize, 0);
                        bytesread := RawRegSubKeyValues.ReadRawData(SubKeyValueList[k], FoundValue.Data^, FoundValue.DataSize);
                        BookmarkComment := (FoundValue.DataAsString);
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
        end; { Printer Defaults }

        // -----------------------------------------------------------------------
        // RegResult - Process as Key - Email Clients
        // -----------------------------------------------------------------------
        Re.MatchPattern := '^\\Clients\\Mail\\([^\\]+)$'; // Only want the Key - no values
        Re.SetSubjectStr(RegResultKey.FullPath);
        if Re.Match(0) >= 0 then
        begin
          mstr := Re.MatchedStrPtr;
          if (mstr <> '') and (Re.MatchedStrLength > 0) then
          begin
            Email := TEmailInfo.Create;
            Email.Registry := RegResultKey.Entry;
            Email.Device := GetDeviceEntry(RegResultKey.Entry);
            Email.Name := UpperCase(Re.Substr(1));
            Email.KeyPath := (TRegSearchResultKey(RegResult).FullPath);
            EmailList.Add(Email);
          end;
        end;

      end; { Regresult - Process as Key }
  end; { for RegFoundCount }

  // ============================================================================
  // OUTPUT AND BOOKMARK
  // ============================================================================
  BookmarkComment_StringList := TStringList.Create;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Individual Keys
  // ---------------------------------------------------------------------------
  // (ATList                      AHive_Type         ABMF_Key_Group            FieldName
  OutputResult(CompInfDefaultDomainList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_DEFAULTDOMAINNAME);
  OutputResult(CompInfDefaultUserList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_DEFAULTUSERNAME);
  OutputResult(CompInfInstallDateList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_INSTALLDATE);
  OutputResult(CompInfProductIDList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_PRODUCTID);
  OutputResult(CompInfProductNameList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_PRODUCTNAME);
  OutputResult(CompInfRegOrgList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_REGISTEREDORGANIZATION);
  OutputResult(CompInfRegOwnerList, BMF_SOFTWARE_HIVE, BMF_COMPUTER_INFORMATION, REGKEY_REGISTEREDOWNER);
  OutputResult(SystemRootList, BMF_SOFTWARE_HIVE, BMF_SYSTEMROOT, REGKEY_SYSTEMROOT);
  OutputResult(ComputerNameList, BMF_SYSTEM_HIVE, BMF_COMPUTERNAME, REGKEY_COMPUTERNAME);
  OutputResult(NTFSDisLastAccUpList, BMF_SYSTEM_HIVE, BMF_NTFSDISLASTACCUP, REGKEY_NTFSDISLASTACCUP);
  OutputResult(csCurrentList, BMF_SYSTEM_HIVE, BMF_CONTROLSET, REGKEY_CURRENT);
  OutputResult(csDefaultList, BMF_SYSTEM_HIVE, BMF_CONTROLSET, REGKEY_DEFAULT);
  OutputResult(csFailedList, BMF_SYSTEM_HIVE, BMF_CONTROLSET, REGKEY_FAILED);
  OutputResult(csLastKnownGoodList, BMF_SYSTEM_HIVE, BMF_CONTROLSET, REGKEY_LASTKNOWNGOOD);
  OutputResult(ShutdownTimeList, BMF_SYSTEM_HIVE, BMF_SHUTDOWNTIME, REGKEY_SHUTDOWNTIME);
  OutputResult(tzActiveTimeBiasList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_ACTIVETIMEBIAS);
  OutputResult(tzBiasList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_BIAS);
  OutputResult(tzDaylightBiasList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_DAYLIGHTBIAS);
  OutputResult(tzDaylightNameList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_DAYLIGHTNAME);
  OutputResult(tzDaylightStartList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_DAYLIGHTSTART);
  OutputResult(tzStandardBiasList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_STANDARDBIAS);
  OutputResult(tzStandardNameList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_STANDARDNAME);
  OutputResult(tzStandardStartList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_STANDARDSTART);
  OutputResult(tzTimeZoneKeyNameList, BMF_SYSTEM_HIVE, BMF_TIMEZONEINFORMATION, REGKEY_TIMEZONEKEYNAME);
  if not Progress.isRunning then
    Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - ProfileImagePath
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_PROFILEIMAGEPATH;
  if (assigned(ProfileImagePathList) and (ProfileImagePathList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to ProfileImagePathList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
      The_Source_Str := TDataEntry(TProfileImagePathInfo(ProfileImagePathList[n]).Registry).FullPathName + TProfileImagePathInfo(ProfileImagePathList[n]).KeyFullPath;
      ConsoleLog(ltMessagesMemoBM, RPad('UserSID:', rpad_value) + TProfileImagePathInfo(ProfileImagePathList[n]).UserSID);
      ConsoleLog(ltMessagesMemoBM, RPad('UserFolder:', rpad_value) + TProfileImagePathInfo(ProfileImagePathList[n]).KeyData);
      ConsoleLog(ltMessagesMemoBM, '~~~~~~~~~~~~~~~');
      ConsoleLog(ltMessagesMemoBM, 'Source: ' + TProfileImagePathInfo(ProfileImagePathList[n]).KeyPath);
      ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
      ConsoleLog(ltMessagesMemo, StringOfChar('-', CHAR_LENGTH));
      Device_str := TDataEntry(TProfileImagePathInfo(ProfileImagePathList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMC_Formatted := BookmarkComment_StringList.Text;
      BMF_Key_Name := TProfileImagePathInfo(ProfileImagePathList[n]).UserSID;
      BM_Source_str := TDataEntry(TProfileImagePathInfo(ProfileImagePathList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end
  end;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - Connected Printers
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_CONNECTED_PRINTERS;
  if (assigned(ConnectedPrintersList) and (ConnectedPrintersList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to ConnectedPrintersList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
      ConsoleLog(ltMessagesMemoBM, RPad('Name:', rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).Name);
      if TPrinterInfo(ConnectedPrintersList[n]).ShareName <> '' then
        ConsoleLog(ltMessagesMemoBM, RPad('Share Name:', rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).ShareName);
      if TPrinterInfo(ConnectedPrintersList[n]).Description <> '' then
        ConsoleLog(ltMessagesMemoBM, RPad('Description:', rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).Description);
      ConsoleLog(ltMessagesMemoBM, RPad('Driver:', rpad_value) + TPrinterInfo(ConnectedPrintersList[n]).Driver);
      if TPrinterInfo(ConnectedPrintersList[n]).LastModified <> 0 then
        ConsoleLog(ltMessagesMemoBM, RPad('Last Modified:', rpad_value) + DateTimeToStr(TPrinterInfo(ConnectedPrintersList[n]).LastModified));
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_Str := TDataEntry(TPrinterInfo(ConnectedPrintersList[n]).Registry).FullPathName + TPrinterInfo(ConnectedPrintersList[n]).KeyFullPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_Str);
      ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_Str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device_str := TDataEntry(TPrinterInfo(ConnectedPrintersList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMF_Key_Name := TPrinterInfo(ConnectedPrintersList[n]).Name;
      BM_Source_str := TDataEntry(TPrinterInfo(ConnectedPrintersList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
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
      if not Progress.isRunning then
        break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((StringOfChar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemoBM, RPad('Email Client:', rpad_value) + TEmailInfo(EmailList[n]).Name);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_Str := TDataEntry(TEmailInfo(EmailList[n]).Registry).FullPathName + TEmailInfo(EmailList[n]).KeyPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_Str);
      ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_Str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device_str := TDataEntry(TEmailInfo(EmailList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMF_Key_Name := TEmailInfo(EmailList[n]).Name;
      BM_Source_str := TDataEntry(TEmailInfo(EmailList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
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
      if not Progress.isRunning then
        break;
      The_Source_Str := TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Registry).FullPathName + TUninstallProgramsInfo(UninstallProgramsList[n]).KeyPath;
      BookmarkComment_StringList.Clear;
      // ConsoleLog(ltMessagesMemo, ((Stringofchar(' ', CHAR_LENGTH))));
      ConsoleLog(ltBM, RPad('UninstallPrograms:', rpad_value) + TUninstallProgramsInfo(UninstallProgramsList[n]).Name);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      ConsoleLog(ltBM, 'Source: ' + The_Source_Str);
      // ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device_str := TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMF_Key_Name := TUninstallProgramsInfo(UninstallProgramsList[n]).Name;
      BM_Source_str := TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

      UninstallPrograms_StringList.Add(TDataEntry(TUninstallProgramsInfo(UninstallProgramsList[n]).Registry).FullPathName + '*' + TUninstallProgramsInfo(UninstallProgramsList[n]).Name);
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
      for i := 0 to UninstallPrograms_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        tildpos := pos('*', UninstallPrograms_StringList.strings[i]);

        // Handle printing of the header row
        if source_str = '' then
        begin
          source_str := copy(UninstallPrograms_StringList.strings[i], 1, tildpos - 1);
          ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
          ConsoleLog(ltMessagesMemo, RPad('Source:', 10) + source_str);
          ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
        end
        else if source_str <> copy(UninstallPrograms_StringList.strings[i], 1, tildpos - 1) then
        begin
          source_str := copy(UninstallPrograms_StringList.strings[i], 1, tildpos - 1);
          ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
          ConsoleLog(ltMessagesMemo, RPad('Source:', 10) + source_str);
          ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
        end; { printing of header row }

        program_name_str := copy(UninstallPrograms_StringList.strings[i], tildpos + 1, Length(UninstallPrograms_StringList.strings[i]));
        ConsoleLog(ltMessagesMemo, RPad('', 15) + program_name_str);
      end;
      ConsoleLog(ltMessagesMemo, (StringOfChar(' ', CHAR_LENGTH)));
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
      if not Progress.isRunning then
        break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((StringOfChar(' ', CHAR_LENGTH))));
      ConsoleLog(ltMessagesMemoBM, RPad('Friendly Name:', rpad_value) + TUSBStorInfo(USBStorList[n]).Name);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');
      The_Source_Str := TDataEntry(TUSBStorInfo(USBStorList[n]).Registry).FullPathName + TUSBStorInfo(USBStorList[n]).KeyPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_Str);
      ConsoleLog(ltMessagesMemo, RPad('Source:', rpad_value) + The_Source_Str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device_str := TDataEntry(TUSBStorInfo(USBStorList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMF_Key_Name := TUSBStorInfo(USBStorList[n]).Name;
      BM_Source_str := TDataEntry(TUSBStorInfo(USBStorList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_SYSTEM_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
    Goto Finish;

  // ---------------------------------------------------------------------------
  // Output and Bookmark - RECENTDOCS
  // ---------------------------------------------------------------------------
  BMF_Key_Group := BMF_RECENTDOCS;
  // ' Reference: "Windows Registry Forensics: Advanced digital Forensic Analysis of the Windows Registry" Carvey, Harlan. Syngress 2011, Pages 169-178'
  if (assigned(RecentDocsList) and (RecentDocsList.Count > 0)) and assigned(BookmarkComment_StringList) then
  begin
    ConsoleSection(BMF_Key_Group);
    for n := 0 to RecentDocsList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      BookmarkComment_StringList.Clear;

      ConsoleLog(ltMessagesMemo, ((StringOfChar(' ', CHAR_LENGTH))));

      ConsoleLog(ltMessagesMemo, RPad('Recent Docs Name:', 20) + TRecentDocsInfo(RecentDocsList[n]).ShellBag.DisplayName);
      ConsoleLog(ltBM, RPad('Recent Docs Name:', rpad_value) + TRecentDocsInfo(RecentDocsList[n]).ShellBag.DisplayName);

      ConsoleLog(ltMessagesMemo, RPad('Recent Docs Type:', 20) + TRecentDocsInfo(RecentDocsList[n]).ShellBag.TypeAsString);
      ConsoleLog(ltBM, RPad('Recent Docs Type:', rpad_value) + TRecentDocsInfo(RecentDocsList[n]).ShellBag.TypeAsString);

      ConsoleLog(ltMessagesMemo, RPad('Registry File:', 20) + TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Registry).FullPathName);
      ConsoleLog(ltMessagesMemo, RPad('Registry Key:', 20) + TRecentDocsInfo(RecentDocsList[n]).KeyPath);
      ConsoleLog(ltBM, '~~~~~~~~~~~~~~~');

      The_Source_Str := TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Registry).FullPathName + TRecentDocsInfo(RecentDocsList[n]).KeyPath;
      ConsoleLog(ltMessagesMemo, RPad('Source:', 20) + The_Source_Str);
      ConsoleLog(ltBM, RPad('Source:', rpad_value) + The_Source_Str);

      BMC_Formatted := BookmarkComment_StringList.Text;
      Device_str := TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMF_Key_Name := TRecentDocsInfo(RecentDocsList[n]).Name;
      BM_Source_str := TDataEntry(TRecentDocsInfo(RecentDocsList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_NTUSER_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
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
    ConsoleLog(ltMessagesMemo, StringOfChar(' ', CHAR_LENGTH));
    The_Source_Str := '';
    for n := 0 to TimeZoneList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;

      // Print the source header
      if The_Source_Str = '' then
      begin
        The_Source_Str := TDataEntry(TTimeZoneInfo(TimeZoneList[n]).Registry).FullPathName;
        ConsoleLog(ltMessagesMemo, RPad('Source: ', rpad_value) + The_Source_Str);
      end
      else if The_Source_Str <> TDataEntry(TTimeZoneInfo(TimeZoneList[n]).Registry).FullPathName then
      begin
        The_Source_Str := TDataEntry(TTimeZoneInfo(TimeZoneList[n]).Registry).FullPathName;
        ConsoleLog(ltMessagesMemo, StringOfChar(' ', CHAR_LENGTH));
        ConsoleLog(ltMessagesMemo, RPad('Source: ', rpad_value) + The_Source_Str);
      end;

      if TTimeZoneInfo(TimeZoneList[n]).tzStandardName <> '' then
        ConsoleLog(ltMessagesMemoBM, RPad('StandardName:', rpad_value) + TTimeZoneInfo(TimeZoneList[n]).tzStandardName);

      if TTimeZoneInfo(TimeZoneList[n]).tzTimeZoneKeyName <> '' then
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
      if not Progress.isRunning then
        break;
      BookmarkComment_StringList.Clear;
      ConsoleLog(ltMessagesMemo, ((StringOfChar(' ', CHAR_LENGTH))));
      ConsoleLog('Network #' + IntToStr(n + 1));
      ConsoleLog(ltMessagesMemoBM, RPad('GUID:', rpad_value) + TNetworkInfo(NetworkList[n]).GUID);
      ConsoleLog(ltMessagesMemoBM, RPad('Profile Name:', rpad_value) + TNetworkInfo(NetworkList[n]).ProfileName);
      ConsoleLog(ltMessagesMemoBM, RPad('Description:', rpad_value) + TNetworkInfo(NetworkList[n]).Description);
      ConsoleLog(ltMessagesMemoBM, RPad('Date Created:', rpad_value) + TNetworkInfo(NetworkList[n]).DateCreated);
      ConsoleLog(ltMessagesMemoBM, RPad('Last Connected:', rpad_value) + TNetworkInfo(NetworkList[n]).LastConnected);
      ConsoleLog(ltBM, ('~~~~~~~~~~~~~~~'));
      The_Source_Str := TDataEntry(TNetworkInfo(NetworkList[n]).Registry).FullPathName + TNetworkInfo(NetworkList[n]).KeyFullPath;
      ConsoleLog(ltBM, 'Source: ' + The_Source_Str);
      ConsoleLog(ltMessagesMemo, RPad('Source: ', rpad_value) + The_Source_Str);
      BMC_Formatted := BookmarkComment_StringList.Text;
      Device_str := TDataEntry(TNetworkInfo(NetworkList[n]).Device).EntryName;
      Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
      BMF_Key_Name := TNetworkInfo(NetworkList[n]).GUID;
      BM_Source_str := TDataEntry(TNetworkInfo(NetworkList[n]).Registry).FullPathName;
      BookMark_Create(Device_str, BMF_SOFTWARE_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);
    end;
  end;
  if not Progress.isRunning then
    Goto Finish;

  ConsoleLog(ltMessagesMemo, (StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog(ltMessagesMemo, #13#10 + 'End of results.');

  // ============================================================================
  // Export results to a file
  // ============================================================================
  bl_Export_Results_List := False;
  If bl_Export_Results_List then
  begin
    CurrentCaseDir := GetCurrentCaseDir;
    ExportedDir := CurrentCaseDir + 'Exported\';
    ExportDate := FormatDateTime('yyyy-mm-dd', now);
    ExportTime := FormatDateTime('hh-nn-ss', now);
    ExportDateTime := (ExportDate + '-' + ExportTime);

    Export_Description := SCRIPT_NAME;

    if DirectoryExists(ExportedDir) then
    begin
      if assigned(ConsoleLog_StringList) then
      begin
        ConsoleLog_StringList.SaveToFile(ExportedDir + ExportDateTime + ' ' + Export_Description + '.txt');
        begin
          Progress.DisplayMessageNow := 'Exporting Report...';
          if DirectoryExists(ExportedDir) then
          begin
            ShellExecute(0, nil, 'explorer.exe', Pchar(ExportedDir), nil, 1); // Opens the folder
          end
          else
            ConsoleLog('Folder not found: ' + ExportedDir);
        end;
      end;
    end
    else
      ConsoleLog('Export folder not found.');
  end;

Finish:

  // Finishing bookmark folder count
  ConsoleLog('Finishing Bookmark folder count: ' + (IntToStr(BookmarksEntryList.Count)) + '. There were: ' + (IntToStr(BookmarksEntryList.Count - StartingBookmarkFolder_Count)) + ' new Bookmark folders added.');

  ConsoleLog('Starting: ' + IntToStr(StartingBookmarkFolder_Count) + ', Finishing: ' + IntToStr(BookmarksEntryList.Count) + ', Difference: ' + IntToStr(BookmarksEntryList.Count - StartingBookmarkFolder_Count));

  // Debugging count of Bookmark folder for Triage\.*\Registry
  Registry_BM_Fldr_Count := 0;
  Entry := BookmarksEntryList.First;
  while assigned(Entry) and Progress.isRunning do
  begin
    begin
      if RegexMatch(Entry.FullPathName, 'Triage\\.*?\\Registry\\', False) then
        Registry_BM_Fldr_Count := Registry_BM_Fldr_Count + 1;
    end;
    Entry := BookmarksEntryList.Next;
  end;
  ConsoleLog('Triage\*.*\Registry\ folder count: ' + IntToStr(Registry_BM_Fldr_Count));

  // Free Memory
  BookmarksEntryList.free;
  CompInfDefaultDomainList.free;
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
  EvidenceEntryList.free;
  NetworkList.free;
  NTFSDisLastAccUpList.free;
  ProfileImagePathList.free;
  RecentDocsList.free;
  Reg.free;
  ShutdownTimeList.free;
  SystemRootList.free;
  TempClassList.free;
  TimeZoneList.free;
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
  UninstallPrograms_StringList.free;
  UninstallProgramsList.free;
  USBStorList.free;
  Re.free;

  ConsoleLog(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := ('Processing complete.');

  // Must be freed after the last ConsoleLog
  BookmarkComment_StringList.free;
  ConsoleLog_StringList.free;
  Memo_StringList.free;

  Progress.DisplayMessageNow := 'Processing complete';

end.
