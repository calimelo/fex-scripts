{ !NAME:      CLI Registry Triage - SAM User Accounts }
{ !DESC:      Find and Bookmark User Account details from SAM and SYSTEM registry files }
{ !AUTHOR:    GetData }
{ !REFERENCE: Reference: Carvey, Harlan A. "Windows Registry Forensics", Syngress 2011' }

unit cli_registry_triage_sam_user_accounts;

interface

uses
  Classes,
  Clipbrd,
  Common,
  Contnrs,
  DataEntry,
  DataStorage,
  DataStreams,
  DateUtils,
  DIRegex,
  Graphics,
  Math,
  NoteEntry,
  PropertyList,
  RawRegistry,
  RegEx,
  SysUtils,
  Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  // ==============================================================================
  // DO NOT TRANSLATE
  // ==============================================================================
  SAM_HIVE = 'SAM'; // noslz
  PARAM_EVIDENCEMODULE = 'EVIDENCEMODULE'; // noslz
  PARAM_FSSAMUSERACCOUNTS = 'FSSAMUSERACCOUNTS'; // noslz
  PARAM_FSTRIAGE = 'FSTRIAGE'; // noslz
  PARAM_REGISTRYMODULE = 'REGISTRYMODULE'; // noslz
  PARSE_KEY = '\SAM\Domains\Account\Users'; // noslz
  FILESIG_REGISTRY = 'Registry'; // noslz
  RS_CURRENT = 'Current'; // noslz
  RS_DEFAULT = 'Default'; // noslz
  RS_FAILED = 'Failed'; // noslz
  RS_LAST_KNOWN_GOOD = 'LastKnownGood'; // noslz
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  HYPHEN = ' - ';
  COLON = ': ';
  SCRIPT_NAME = 'Triage' + HYPHEN + 'SAM User Accounts';
  BMF_USER_ACCOUNTS = 'User Accounts';
  BMF_MY_BOOKMARKS = 'My Bookmarks';
  BMF_TRIAGE = 'Triage';
  BMF_REGISTRY = 'Registry';

  CHAR_LENGTH = 90;
  SHOW_BLANK_BL = False;

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

  // Account/Password Flags
  ACB_ACCOUNT_DISABLED = $0001;
  ACB_HOME_DIR_REQURIED = $0002;
  ACB_PASS_NOT_REQURIED = $0004;
  ACB_TEMP_DUP_ACCOUNT = $0008;
  ACB_NORMAL_USER_ACCOUNT = $0010;
  ACB_MNS_LOGON_ACCOUNT = $0020;
  ACB_INTERDOMAIN_ACCOUNT = $0040;
  ACB_WORKSTATION_ACCOUNT = $0080;
  ACB_SERVER_ACCOUNT = $0100;
  ACB_PASS_DOESNOT_EXPIRE = $0200;
  ACB_ACCOUNT_AUTO_LOCKED = $0400;

  SPACE = ' ';
  TSWT = 'The script will terminate.';

  // Global Variables
var
  bl_AutoBookmark_Results: boolean;

type
  TRegHiveType = (hvSOFTWARE, hvSAM, hvSECURITY, hvUSER, hvSYSTEM, hvUSER9X, hvSYSTEM9X, hvANY, hvUNKNOWN);
  TRegDataType = (rdNone, rdString, rdExpandString, rdBinary, rdInteger, rdIntegerBigEndian, rdLink, rdMultiString, rdResourceList, rdFullResourceDescription, rdResourceRequirementsList, rdInt64, rdUnknown);

  TDataType = (dtString, dtUnixTime, dtFileTime, dtNetworkListDate, dtHex, dtMRUValue, dtMRUListEx, dtInteger);
  TControlSet = (csNone, csAny, csCurrent, csDefault, csFailed, csLastKnownGood);

  TControlSetInfo = class
    ActiveCS: TControlSet;
    CurrentCS: integer;
    DefaultCS: integer;
    FailedCS: integer;
    LastKnownGoodCS: integer;
    function GetActiveCSAsInteger: integer;
  end;

  TLogType = (ltMemo, ltBM, ltMessagesMemo, ltMessagesMemoBM);

  TVRecord = record
    Offset: longword;
    Size: longword;
    unknown: longword;
  end;

  TFRecord = packed record
    unknown: uint64;
    LastLogin: int64;
    unknown2: uint64;
    PasswordLastSet: int64;
    AccountExpires: int64;
    LastIncorrectPassword: int64;
    RID: longword;
    unknown3: longword;
    AccountPasswordStatus: word; // offset 56.
    // unknown4: byte;
    unknown5: word;
    CountryCode: word; // Default 0000, US 0001, Canada 0002
    unknown6: word;
    InvalidPasswordCount: word;
    NumberLogins: word;
    unknown7: longword;
    unknown8: uint64;
  end;

  TUserAccount = class
    Registry: TEntry;
    Device: TEntry;
    KeyPath: string;
    UserID: integer;
    AccountLastModified: TDateTime;
    AccountType: integer;
    UserName: string;
    Fullname: string;
    Comment: string;
    UserComment: string;
    HomeDir: string;
    HomeDirConnect: string;
    ScriptPath: string;
    ProfilePath: string;
    Workstations: string;
    LMHashRaw: string;
    NTHashRaw: string;
    LastLogin: TDateTime;
    PasswordLastSet: TDateTime;
    AccountExpires: TDateTime;
    LastPasswordFail: TDateTime;
    CountryCode: integer;
    NumberLogins: integer;
    InvalidPasswordCount: integer;
    AccountStatus: word; // 0=Active,1=inactive, 0=password required,4=password policies not used
    InternetUserName: string;
    InternetProviderGUID: string;
    Surname: string;
    GivenName: string;
    UserPasswordHint: string;
    AccountCreated: TDateTime;
  end;

  TUserName = class // data from the \\Names\\* keys
    Registry: TEntry;
    Device: TEntry;
    KeyPath: string;
    AccountCreated: TDateTime;
    UserName: string;
  end;

  TRegSearchKey = class
    Hive: TRegHiveType;
    ControlSet: TControlSet;
    DataType: TDataType;
    Key: string; // The registry folder name
    IncludeChildKeys: boolean; // Search recursively through child keys also.
    Value: string; // The registry key name
    BookMarkFolder: string; // Default bookmark folder
  end;

  TRegSearchResult = class
    Entry: TEntry;
    SearchKey: TRegSearchKey;
    KeyPath: string; // The registry folder name
    EntryIdx: integer; // Index in the FRegEntries list
    function FullPath: string; abstract; virtual; // Full path of the key and value
  end;

  TRegSearchResultKey = class(TRegSearchResult)
    KeyName: string;
    KeyLastModified: TDateTime;
    function FullPath: string; override; // Full path of the key and value
    function GetChildKeys: TStringList;
  end;

  TRegSearchResultValue = class(TRegSearchResult)
    Name: string; // The registry key name
    DataType: TRegDataType; // Type of data that the key contains
    Data: pointer;
    DataSize: integer;
    constructor Create;
    destructor Destroy; override;
    function FullPath: string; override; // Full path of the key and value
    function DataAsByteArray(ACount: integer): array of byte;
    function DataAsHexStr(ACount: integer): string;
    function DataAsString(ForceBinaryToStr: boolean = True): string; // Returns the "Data" as a string
    function DataAsInteger: integer;
    function DataAsDword: dword;
    function DataAsInt64: int64;
    function DataAsDateTime: TDateTime; // Attempts to convert the "Data" to a DateTime
    function DataAsDateTimeStr: string; // Does AsDateTime then formats as a string
    function DataAsFileTimeStr: string;
  end;

  TMyRegistry = class
  private
    FRegEntries: TList; // List of registry files found in the filesystem or registry module - stored as TEntry
    FSearchKeys: TObjectList; // List of keys to search for during scan
    FFoundKeys: TObjectList; // List of results after a scan
    FControlSets: TObjectList; // List of controls sets for each registry file in FRegEntries. Only used for SYSTEM hives.
    function GetRegEntry(Index: integer): TEntry;
    function GetFoundKey(Index: integer): TRegSearchResult;
    function GetControlSetInfo(Index: integer): TControlSetInfo;
    procedure SetControlSetInfo(Index: integer; AValue: TControlSetInfo);
    function GetFoundCount: integer;
    function GetEntryCount: integer;
    function FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;

  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearKeys;
    procedure ClearResults;
    procedure AddRegFile(ARegEntry: TEntry);
    function FindRegFilesByDevice(ADevice: TEntry; ARegEx: string): integer; // Locate registry files on a device
    function FindRegFilesByDataStore(const ADataStore: string; ARegEx: string): integer; // Locate registry files in a datastore
    function FindKeys: integer;
    function AddKey(AHive: TRegHiveType; AControlSet: TControlSet; ADataType: TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir: string = ''): integer;
    function GetHiveType(AEntry: TEntry): TRegHiveType;
    function HiveTypeToStr(AHive: TRegHiveType): string;
    property GetEntry[Index: integer]: TEntry read GetRegEntry;
    property Found[Index: integer]: TRegSearchResult read GetFoundKey;
    property ControlSetInfo[Index: integer]: TControlSetInfo read GetControlSetInfo write SetControlSetInfo;
    property FoundCount: integer read GetFoundCount;
    property EntryCount: integer read GetEntryCount;
    property RegEntries: TList read FRegEntries;
  end;

function RPad(const AString: string; AChars: integer): string;
function UnixTimeToDateTime(UnixTime: integer): TDateTime;
procedure ConsoleLog(AString: string); overload;
procedure ConsoleLog(ALogType: TLogType; AString: string); overload;
procedure ConsoleLogMemo(AString: string);
procedure ConsoleLogBM(AString: string);
procedure BookMark(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
function MyFileTimeToDateTime(const AInt64: int64): TDateTime;
function MyFormatDateTime(ADateTime: TDateTime; isUTC: boolean): string;
function CountryCodeToStr(ACountryCode: integer): string;
function AccountTypeToStr(AAccountType: integer): string;
function AccountStatusToStrList(AStatus: word): TStringList;
function InternetProviderToStr(AProviderGUID: string): string;

var
  Memo_StringList: TStringList;
  BookmarkComment_StringList: TStringList;
  ConsoleLog_StringList: TStringList;

implementation

{ =========== General Global Functions ============ }

// ------------------------------------------------------------------------------
// Function: Right Pad v2
// ------------------------------------------------------------------------------
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
  Progress.Log('[' + DateTimeToStr(now) + '] : ' + AString);
  if assigned(ConsoleLog_StringList) then
    if ConsoleLog_StringList.Count < 5000 then
      ConsoleLog_StringList.Add(AString);
end;

// Add time and date to the console log messages - Message Log and Results Mem Box
procedure ConsoleLogMemo(AString: string);
begin
  if assigned(Memo_StringList) then
    if Memo_StringList.Count < 5000 then
      Memo_StringList.Add(AString); // no time and date for the results memo
end;

// Add time and date to the console log messages - Message Log, Results Mem Box, Bookmark Comment
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
      UpdateBookmark(bmParent, Abm_Source_str);
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
begin
  if (assigned(bmdEntry)) and (Progress.isRunning) then
  begin
    DeviceEntry := GetDeviceEntry(bmdEntry);
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + DeviceEntry.EntryName + '\Device', bCreate);
    if assigned(bmParent) and bCreate then
      UpdateBookmark(bmParent, AComment);
    if assigned(bmParent) and ABookmarkEntry and not(IsItemInBookmark(bmParent, bmdEntry)) then
      AddItemsToBookmark(bmParent, DATASTORE_FILESYSTEM, bmdEntry, AFileComment);
  end;
end;

function MyFileTimeToDateTime(const AInt64: int64): TDateTime;
begin
  Result := 0;
  if AInt64 = $0000000000000000 then
    Exit;
  if AInt64 = $FFFFFFFFFFFFFFFF then
    Exit;
  if AInt64 = $7FFFFFFFFFFFFFFF then
    Exit;
  // ConsoleLog('Result: ' + IntToStr(int64(Result)));
  Result := FileTimeToDateTime(AInt64);
end;

function MyFormatDateTime(ADateTime: TDateTime; isUTC: boolean): string;
var
  str: string;
begin
  Result := '';
  // ConsoleLog(inttohex(int64(ADateTime),8));
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

function CountryCodeToStr(ACountryCode: integer): string;
begin
  Result := IntToStr(ACountryCode);
  case ACountryCode of
    0:
      Result := Result + ' (Default)';
    1:
      Result := Result + ' (USA)';
    2:
      Result := Result + ' (Canada)';
  end;
end;

function AccountTypeToStr(AAccountType: integer): string;
begin
  Result := '($' + inttohex(AAccountType, 4) + ')';
  case AAccountType of
    $BC:
      Result := 'Default Admin User ' + Result;
    $B0:
      Result := 'Default Guest Account ' + Result;
    $D4:
      Result := 'Custom Limited Account ' + Result;
    // $1C0: Result := 'User Account ' + Result;
  end;
end;

function AccountStatusToStrList(AStatus: word): TStringList;
begin
  Result := TStringList.Create;
  if AStatus and ACB_ACCOUNT_DISABLED = ACB_ACCOUNT_DISABLED then
    Result.Add('Account disabled');
  if AStatus and ACB_HOME_DIR_REQURIED = ACB_HOME_DIR_REQURIED then
    Result.Add('Home directory required');
  if AStatus and ACB_PASS_NOT_REQURIED = ACB_PASS_NOT_REQURIED then
    Result.Add('Password not required');
  if AStatus and ACB_TEMP_DUP_ACCOUNT = ACB_TEMP_DUP_ACCOUNT then
    Result.Add('Temporary duplicate account');
  if AStatus and ACB_NORMAL_USER_ACCOUNT = ACB_NORMAL_USER_ACCOUNT then
    Result.Add('Normal user account');
  if AStatus and ACB_MNS_LOGON_ACCOUNT = ACB_MNS_LOGON_ACCOUNT then
    Result.Add('MNS logon user account');
  if AStatus and ACB_INTERDOMAIN_ACCOUNT = ACB_INTERDOMAIN_ACCOUNT then
    Result.Add('Interdomain trust account');
  if AStatus and ACB_WORKSTATION_ACCOUNT = ACB_WORKSTATION_ACCOUNT then
    Result.Add('Workstation trust account');
  if AStatus and ACB_SERVER_ACCOUNT = ACB_SERVER_ACCOUNT then
    Result.Add('Server trust account');
  if AStatus and ACB_PASS_DOESNOT_EXPIRE = ACB_PASS_DOESNOT_EXPIRE then
    Result.Add('Password does not expire');
  if AStatus and ACB_ACCOUNT_AUTO_LOCKED = ACB_ACCOUNT_AUTO_LOCKED then
    Result.Add('Account auto locked');
end;

function InternetProviderToStr(AProviderGUID: string): string;
begin
  Result := AProviderGUID;
  if AProviderGUID = '{D7F9888F-E3FC-49B0-9EA6-A85B5F392A4F}' then
    Result := 'Microsoft Account ' + Result;
end;

// ------ { TControlSetInfo Class } ---------------------------------------------
function TControlSetInfo.GetActiveCSAsInteger: integer;
begin
  Result := -1;
  case ActiveCS of
    csCurrent:
      Result := CurrentCS;
    csDefault:
      Result := DefaultCS;
    csFailed:
      Result := FailedCS;
    csLastKnownGood:
      Result := LastKnownGoodCS;
    csNone:
      Result := -1;
    csAny:
      Result := -2;
  end;
end;

// ------ { TRegSearchResult Class } --------------------------------------------

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
      Progress.Log(ATRY_EXCEPT_STR + '');
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
          Result := DataAsHexStr(1024 { DataSize } );
      end;
    end;
  except
    Progress.Log(ATRY_EXCEPT_STR + '');
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
    Progress.Log(ATRY_EXCEPT_STR + '');
    Result := -1;
  end;
end;

// Returns a 32 bit unsigned LE double word ------------------------------------
function TRegSearchResultValue.DataAsDword: dword;
begin
  try
    if (DataSize >= 4) then
      move(Data^, Result, 4);
  except
    Progress.Log(ATRY_EXCEPT_STR + '');
    Result := 0;
  end;
end;

// Returns a 64 bit signed LE int64 --------------------------------------------
function TRegSearchResultValue.DataAsInt64: int64;
begin
  try
    if (DataSize >= 8) then
      move(Data^, Result, 8);
  except
    Progress.Log(ATRY_EXCEPT_STR + '');
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
    Result := Result + inttohex(abyte, 2) + ' ';
  end;
end;

// Returns Unix date time ------------------------------------------------------
function TRegSearchResultValue.DataAsDateTime: TDateTime;
begin
  Result := UnixTimeToDateTime(DataAsInteger);
end;

// Returns date time as file time string----------------------------------------
function TRegSearchResultValue.DataAsFileTimeStr: string;
var
  aFileTime: TFileTime;
begin
  try
    if (DataSize >= 8) then
      move(Data^, aFileTime, 8);
    Result := FileTimeToString(aFileTime);
  except
    Progress.Log(ATRY_EXCEPT_STR + '');
    Result := '';
  end;
end;

// Returns date time string-----------------------------------------------------
function TRegSearchResultValue.DataAsDateTimeStr: string;
var
  dt: TDateTime;
begin
  Result := '';
  dt := DataAsDateTime;
  if dt > 0 then
    Result := DateTimeToStr(dt) + ' UTC';
end;

// ------ { TMyRegistry Class } -------------------------------------------------
constructor TMyRegistry.Create;
begin
  inherited Create;
  FRegEntries := TList.Create;
  FFoundKeys := TObjectList.Create;
  FFoundKeys.OwnsObjects := True;
  FSearchKeys := TObjectList.Create;
  FSearchKeys.OwnsObjects := True;
  FControlSets := TObjectList.Create;
  FControlSets.OwnsObjects := True;
end;

destructor TMyRegistry.Destroy;
begin
  FControlSets.free;
  FSearchKeys.free;
  FFoundKeys.free;
  FRegEntries.free;
  inherited Destroy;
end;

// AddKey ----------------------------------------------------------------------
function TMyRegistry.AddKey(AHive: TRegHiveType; AControlSet: TControlSet; ADataType: TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir: string = ''): integer;
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

function TMyRegistry.GetFoundKey(Index: integer): TRegSearchResult;
begin
  Result := TRegSearchResult(FFoundKeys[Index]);
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
  Result := FFoundKeys.Count;
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
  FFoundKeys.Clear;
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
end;

// Hive type to string ---------------------------------------------------------
function TMyRegistry.HiveTypeToStr(AHive: TRegHiveType): string;
begin
  case AHive of
    hvSOFTWARE:
      Result := 'SOFTWARE';
    hvSAM:
      Result := 'SAM';
    hvSECURITY:
      Result := 'SECURITY';
    hvUSER:
      Result := 'USER';
    hvSYSTEM:
      Result := 'SYSTEM';
    hvUSER9X:
      Result := 'USER98ME';
    hvSYSTEM9X:
      Result := 'SYSTEM98ME';
    hvANY:
      Result := 'ANY';
  else
    Result := 'UNDETERMINED';
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

// Locates all registry files
function TMyRegistry.FindRegFilesByDevice(ADevice: TEntry; ARegEx: string): integer;
var
  EntryList: TDataStore;
  Entry: TEntry;
  FileSignatureInfo: TFileTypeInformation;
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
            DetermineFileType(Entry);
            FileSignatureInfo := Entry.DeterminedFileDriverInfo;
            if (FileSignatureInfo.ShortDisplayName = FILESIG_REGISTRY) then
            begin
              AddRegFile(Entry);
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
function TMyRegistry.FindRegFilesByDataStore(const ADataStore: string; ARegEx: string): integer;
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

function TMyRegistry.FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;
var
  strKeyName: string;
  SubRawReg: TRawRegistry;
  SubSearchKey: TRegSearchKey;
  FoundKey: TRegSearchResultKey;
  FoundValue: TRegSearchResultValue;
  DataInfo: TRegDataInfo;
  bytesread: integer;
  Value_StringList: TStringList;
  v, k: integer;
  csi: TControlSetInfo;
begin
  strKeyName := SearchKey.Key;

  if (SearchKey.Hive = hvSYSTEM) and (SearchKey.ControlSet <> csNone) then
  begin
    csi := TControlSetInfo(FControlSets[EntryIdx]);
    case csi.ActiveCS of
      csCurrent:
        strKeyName := '\ControlSet00' + IntToStr(csi.GetActiveCSAsInteger) + SearchKey.Key;
    end;
  end;

  Value_StringList := TStringList.Create;
  try
    if Not RawReg.OpenKey(strKeyName) then
    begin
      // Debug('FindKeys', 'OpenKey Failed: '+ strKeyName);
    end
    else
    begin
      // Debug('FindKeys', 'OpenKey Success: '+ strKeyName);

      if SearchKey.Value <> '*' then
      begin
        // Debug('FindKeys', 'KEY: '+ SearchKey.Value);
        // Add a single value
        Value_StringList.Add(SearchKey.Value);
      end
      else if Not RawReg.GetKeyNames(Value_StringList) then
      begin
        // Debug('FindKeys', 'GetValueNames Failed for: '+ strKeyName)
        // ConsoleLog('GetValueNames Failed for: '+ strKeyName);
      end
      else
      begin
        // Handle the '*'...
        // Debug('FindKeys', 'GetValueNames: '+ strKeyName + ' - ' + IntToStr(Value_StringList.Count));

        if Value_StringList.Count = 0 then
        begin
          ConsoleLog('No values in: ' + strKeyName);
        end
        else
        begin
          // Debug('FindKeys', 'GetValueNames: '+ IntToStr(Value_StringList.Count));
          SubRawReg := TRawRegistry.Create(EntryReader, False);

          // if SubRawReg = nil then
          // ShowMessage('TRawRegistry Failed');

          try
            for k := 0 to Value_StringList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              FoundKey := TRegSearchResultKey.Create;
              FFoundKeys.Add(FoundKey);

              FoundKey.SearchKey := SearchKey;
              FoundKey.Entry := RegEntry;
              FoundKey.KeyPath := strKeyName;
              FoundKey.KeyName := Value_StringList[k];
              if SubRawReg.OpenKey(FoundKey.FullPath) then
                FoundKey.KeyLastModified := SubRawReg.GetCurrentKeyDateTime; // Get the date/time
              FoundKey.EntryIdx := EntryIdx;

              if SearchKey.IncludeChildKeys then
              begin
                SubSearchKey := TRegSearchKey.Create;
                try
                  SubSearchKey.Hive := SearchKey.Hive;
                  SubSearchKey.ControlSet := csNone;
                  SubSearchKey.DataType := SearchKey.DataType;
                  SubSearchKey.Key := strKeyName + '\' + FoundKey.KeyName;
                  SubSearchKey.IncludeChildKeys := True;
                  SubSearchKey.Value := '*';
                  SubSearchKey.BookMarkFolder := SearchKey.BookMarkFolder;

                  // Debug('FindKeys', 'Finding Sub Keys: '+ strKeyName + '\' + FoundKey.KeyName);
                  FindKey(RegEntry, EntryReader, SubRawReg, EntryIdx, SubSearchKey);
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
      for v := 0 to Value_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        // Debug('FindKeys', 'FOUND KEY: '+ Value_StringList[v]);

        if RawReg.OpenKey(strKeyName) and RawReg.GetDataInfo(Value_StringList[v], DataInfo) then
        begin
          FoundValue := TRegSearchResultValue.Create;
          FFoundKeys.Add(FoundValue);

          FoundValue.SearchKey := SearchKey;
          FoundValue.Entry := RegEntry;
          FoundValue.KeyPath := strKeyName;
          FoundValue.Name := Value_StringList[v];
          FoundValue.DataType := DataInfo.RegData;
          FoundValue.DataSize := DataInfo.DataSize;
          FoundValue.Data := nil;
          FoundValue.EntryIdx := EntryIdx;

          GetMem(FoundValue.Data, FoundValue.DataSize);
          FillChar(FoundValue.Data^, FoundValue.DataSize, 0);

          bytesread := RawReg.ReadRawData(Value_StringList[v], FoundValue.Data^, FoundValue.DataSize);
        end;
      end;
    end;

  finally
    Value_StringList.free;
  end;
end;

// Find the registy keys -------------------------------------------------------
function TMyRegistry.FindKeys: integer;
var
  r, k, v: integer;
  RegEntry: TEntry;
  EntryReader: TEntryReader;
  RawReg: TRawRegistry;
  SearchKey: TRegSearchKey;
  HiveType: TRegHiveType;
begin
  // Debug('FindKeys', 'Start');
  Progress.DisplayMessage := 'Finding registry keys...';
  Progress.Max := FRegEntries.Count;
  Progress.CurrentPosition := 1;
  Result := 0;
  FFoundKeys.Clear;
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

      // Debug('FindKeys', 'Reg: ' + RegEntry.FullPathName);

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

    Result := FFoundKeys.Count;
  finally
    // Debug('FindKeys', 'free...');
    EntryReader.free;

    // Debug('FindKeys', 'Calc Values...');

    v := 0;
    k := 0;
    for r := 0 to FFoundKeys.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if FFoundKeys[r] is TRegSearchResultValue then
        inc(v);
      if FFoundKeys[r] is TRegSearchResultKey then
        inc(k);
    end;

    ConsoleLog('FoundKeys : ' + IntToStr(v));
    ConsoleLog('FoundValues : ' + IntToStr(k));

    // Debug('FindKeys', 'FoundKeys: '+ IntToStr(v));
    // Debug('FindKeys', 'FoundKeys: '+ IntToStr(k));
  end;
end;

var
  // Boolean
  bl_EvidenceModule: boolean;
  bl_FSSamUserAccounts: boolean;
  bl_FSTriage: boolean;
  bl_GUIShow: boolean;
  bl_RegModule: boolean;
  bl_ScriptsModule: boolean;

  // ControlSets
  csActive: TControlSet;
  DefaultControlSet: TControlSet;
  FailedControlSet: TControlSet;
  LastKnownGoodControlSet: TControlSet;

  // DataStores
  BookmarksEntryList: TDataStore;
  EvidenceEntryList: TDataStore;

  // Entries
  EntryReader: TEntryReader;
  DeviceListEntry: TEntry;
  dEntry: TEntry;

  // Integers
  bytesread: int64;
  b, i, j, s, u, v, x, y, n: integer;
  regfiles, regcount: integer;
  rpad_value: integer;
  StartingBookmarkFolder_Count: integer;

  // List
  DeviceList: TList;
  DeviceToSearchList: TList;
  UserList: TList;
  NamesList: TList;

  // Registry
  DataInfo: TRegDataInfo;
  RawRegSubKeys: TRawRegistry;
  Reg: TMyRegistry;
  RegResult: TRegSearchResult;
  RegResultValue: TRegSearchResultValue;
  Value: TRegSearchResultValue;

  // RegEx
  Re: TDIPerlRegEx;

  // Strings
  BM_Source_str: string;
  BMC_Formatted: string;
  BMF_Key_Group: string;
  BMF_Key_Name: string;
  Device: string;
  mstr: string;
  Param: string;
  str_RegFiles_Regex: string;
  tempwidestr: string;

  // Starting Checks
  bContinue: boolean;
  CaseName: string;
  StartCheckEntry: TEntry;
  StartCheckDataStore: TDataStore;

  // StringLists
  slist: TStringList;
  ValueList: TStringList;

  // MISC
  User: TUserAccount;
  Name: TUserName;

  ba: array of byte;
  abyte: byte;
  vrec: array [0 .. 16] of TVRecord;
  frec: TFRecord;

  // ==============================================================================
  // Start of Script
  // ==============================================================================
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
  // Check to see if the FileSystem module is present
  bContinue := True;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      ConsoleLog(DATASTORE_FILESYSTEM + ' module not located. The script will terminate.');
      bContinue := False;
      Exit;
    end;
    // Check to see if a case is present
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case. The script will terminate.');
      bContinue := False;
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    // Log case details
    ConsoleLog(StringOfChar('~', CHAR_LENGTH));
    ConsoleLog(RPad('Case Name:', rpad_value) + CaseName);
    ConsoleLog(RPad('Script Name:', rpad_value) + SCRIPT_NAME);
    ConsoleLog(RPad('Date Run:', rpad_value) + DateTimeToStr(now));
    ConsoleLog(RPad('FEX Version:', rpad_value) + CurrentVersion);
    ConsoleLog(StringOfChar('~', CHAR_LENGTH));
    // Check to see if there are files in the File System Module
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module. The script will terminate.');
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
    Exit;
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  // ============================================================================
  // Setup Results Header
  // ============================================================================
  rpad_value := 35;
  Memo_StringList := TStringList.Create;
  ConsoleLog_StringList := TStringList.Create;
  ConsoleLog(ltMessagesMemo, (StringOfChar('-', CHAR_LENGTH)));

  ConsoleLog(RPad('~ Script:', 30) + SCRIPT_NAME);
  ConsoleLog((RPad('~ Parse:', 30) + PARSE_KEY));
  ConsoleLog(ltMemo, (RPad('Parse:', rpad_value) + PARSE_KEY));
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
      BookMarkDevice('', '\Device', '', dEntry, '', True);
    end;
    dEntry := EvidenceEntryList.Next;
  end;
  ConsoleLog(RPad('Device list count:', 30) + IntToStr(DeviceList.Count));

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
    // ShowMessage('Running with Param: ' + Param);
  end
  else
    ConsoleLog('No parameters received.');

  bl_RegModule := False;
  bl_FSSamUserAccounts := False;
  bl_FSTriage := False;
  bl_EvidenceModule := False;
  bl_ScriptsModule := False;

  if (CmdLine.params.Indexof(PARAM_EVIDENCEMODULE) <> -1) then
    bl_EvidenceModule := True;
  if (CmdLine.params.Indexof(PARAM_FSSAMUSERACCOUNTS) <> -1) then
    bl_FSSamUserAccounts := True;
  if (CmdLine.params.Indexof(PARAM_FSTRIAGE) <> -1) then
    bl_FSTriage := True;
  if (CmdLine.params.Indexof(PARAM_REGISTRYMODULE) <> -1) then
    bl_RegModule := True;
  if CmdLine.ParamCount = 0 then
    bl_ScriptsModule := True;

  if bl_EvidenceModule then
  begin
    bl_GUIShow := False;
    bl_AutoBookmark_Results := True;
    // ShowMessage('Running from Evidence module.');
    ConsoleLog('Running from Evidence module.');
  end;

  if bl_FSSamUserAccounts then
  begin
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module.');
  end;

  if bl_FSTriage then
  begin
    bl_GUIShow := False;
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from FileSystem module Triage.');
  end;

  if bl_RegModule = True then
  begin
    bl_GUIShow := True;
    bl_AutoBookmark_Results := False;
    // ShowMessage('Running from Registry Module.');
    ConsoleLog('Running from Registry Module.');
  end;

  if bl_ScriptsModule then
  begin
    bl_GUIShow := True;
    bl_AutoBookmark_Results := True;
    // ShowMessage('Running from Scripts module.');
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

  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog('The Regex search string is:');
  ConsoleLog('  ' + str_RegFiles_Regex);
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));

  Progress.DisplayMessage := 'Finding registry files...';

  regfiles := 0;

  // ============================================================================
  // Start Processing based on the parameter/s received
  // ============================================================================

  if bl_RegModule = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_REGISTRY, str_RegFiles_Regex)
  else if bl_FSSamUserAccounts = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else if bl_FSTriage = True then
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
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
        // ShowMessage('Running from DeviceToSearchList');
      end;
    end;
  end;

  // ============================================================================
  // Exit if no Registry files found
  // ============================================================================
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
      ConsoleLog(HYPHEN + 'Processing Registry File: ' + TEntry(Reg.RegEntries.items[i - 1]).FullPathName);
  end;

  // ============================================================================
  // Setup the correct control-set info for each of the SYSTEM hives found
  // ============================================================================
  csActive := csCurrent;
  DefaultControlSet := csDefault;
  FailedControlSet := csFailed;
  LastKnownGoodControlSet := csLastKnownGood;
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Updating control set info for SYSTEM hives.');
  // ADDKEY  HiveType    Cntrl
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_CURRENT);
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_DEFAULT);
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_FAILED);
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_LAST_KNOWN_GOOD);
  Reg.FindKeys;
  for i := 0 to Reg.FoundCount - 1 do
  begin
    if not Progress.isRunning then
      break;
    RegResult := Reg.Found[i];
    if RegResult is TRegSearchResultValue then
    begin
      RegResultValue := TRegSearchResultValue(RegResult);
      Reg.ControlSetInfo[RegResult.EntryIdx].ActiveCS := csActive;
      if UpperCase(RegResultValue.FullPath) = '\SELECT\CURRENT' then
        Reg.ControlSetInfo[RegResult.EntryIdx].CurrentCS := RegResultValue.DataAsInteger
      else if UpperCase(RegResultValue.FullPath) = '\SELECT\DEFAULT' then
        Reg.ControlSetInfo[RegResult.EntryIdx].DefaultCS := RegResultValue.DataAsInteger
      else if UpperCase(RegResultValue.FullPath) = '\SELECT\FAILED' then
        Reg.ControlSetInfo[RegResult.EntryIdx].FailedCS := RegResultValue.DataAsInteger
      else if UpperCase(RegResultValue.FullPath) = '\SELECT\LASTKNOWNGOOD' then
        Reg.ControlSetInfo[RegResult.EntryIdx].LastKnownGoodCS := RegResultValue.DataAsInteger;
    end;
  end;
  Reg.ClearKeys;
  Reg.ClearResults;
  ConsoleLog('Finished updating SYSTEM control set.');
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));

  // =========================================================================================
  // Add keys to the search list
  // =========================================================================================
  Reg.AddKey(hvSAM, csNone, dtString, PARSE_KEY, True, '*', 'User Accounts'); // add every key in each SAM file

  // ============================================================================
  // Search for Keys
  // ============================================================================
  ConsoleLog('Searching for registry keys of interest...');
  regcount := Reg.FindKeys;
  ConsoleLog(HYPHEN + 'Found ' + IntToStr(Reg.FoundCount) + ' keys.');

  // ============================================================================
  // Iterate Reg results
  // ===========================================================================
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess];

  UserList := TList.Create;
  NamesList := TList.Create;
  Progress.Initialize(Reg.FoundCount, 'Processing Registry Files...');
  Progress.DisplayMessage := 'Processing registry files...';
  Progress.Max := Reg.FoundCount;
  Progress.CurrentPosition := 1;

  for i := 0 to Reg.FoundCount - 1 do
  begin
    if not Progress.isRunning then
      break;
    Progress.IncCurrentProgress;
    RegResult := Reg.Found[i];
    // Interogate Keys found
    if RegResult = nil then
    begin
      continue;
    end;
    if RegResult is TRegSearchResultKey then
    begin
      // Process the \SAM\Domains\Users\* keys
      Re.MatchPattern := '\\SAM\\Domains\\Account\\Users\\([0-9A-F]{8})';
      Re.SetSubjectStr(TRegSearchResultKey(RegResult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount > 0) then
        begin
          // Create new UserAccount
          User := TUserAccount.Create;
          User.Registry := RegResult.Entry;
          User.Device := GetDeviceEntry(RegResult.Entry);
          User.KeyPath := RegResult.FullPath;
          User.UserID := StrToInt('$' + Re.SubStr(1));
          UserList.Add(User);
          // Open this users registry key and get the V, F and other values
          EntryReader := TEntryReader.Create;
          if EntryReader.OpenData(RegResult.Entry) then
          begin
            RawRegSubKeys := TRawRegistry.Create(EntryReader, False);
            if RawRegSubKeys.OpenKey(RegResult.FullPath) then
            begin
              User.AccountLastModified := RawRegSubKeys.GetCurrentKeyDateTime;
              ValueList := TStringList.Create;
              ValueList.Clear;
              RawRegSubKeys.GetValueNames(ValueList);
              for v := 0 to ValueList.Count - 1 do
              begin
                if not Progress.isRunning then
                  break;
                if RawRegSubKeys.GetDataInfo(ValueList[v], DataInfo) then
                begin
                  Value := TRegSearchResultValue.Create;
                  Value.Name := UpperCase(ValueList[v]);
                  Value.DataType := DataInfo.RegData;
                  Value.DataSize := DataInfo.DataSize;
                  Value.Data := nil;
                  GetMem(Value.Data, Value.DataSize);
                  FillChar(Value.Data^, Value.DataSize, 0);
                  bytesread := RawRegSubKeys.ReadRawData(ValueList[v], Value.Data^, Value.DataSize);

                  // process V-Record
                  if Value.Name = 'V' then
                  begin
                    move(Value.Data^, vrec, sizeof(vrec)); // populate the vrecord offset array
                    for j := 0 to 16 do // 17 records - the first record represents the offset records list
                    begin
                      if not Progress.isRunning then
                        break;
                      tempwidestr := '';
                      if (j <> 0) and (vrec[j].Size > 0) and (vrec[j].Size < 256) then
                      begin
                        setlength(tempwidestr, vrec[j].Size div 2);
                        move(pointer(nativeuint(Value.Data) + vrec[j].Offset + 204)^, tempwidestr[1], vrec[j].Size);
                      end
                      else
                      begin
                        // ConsoleLog('Skipping value: '+IntToStr(i)+'   '+IntToStr(j)+'    '+tempwidestr);
                        continue;
                      end;
                      case j of
                        0:
                          User.AccountType := vrec[j].Size; // The account type is stored in the size longword of the first vrec entry.
                        1:
                          User.UserName := tempwidestr;
                        2:
                          User.Fullname := tempwidestr;
                        3:
                          User.Comment := tempwidestr;
                        4:
                          User.UserComment := tempwidestr;
                        6:
                          User.HomeDir := tempwidestr;
                        7:
                          User.HomeDirConnect := tempwidestr;
                        8:
                          User.ScriptPath := tempwidestr;
                        9:
                          User.ProfilePath := tempwidestr;
                        10:
                          User.Workstations := tempwidestr;
                        13 .. 14:
                          // for LM and NT hashes read as byte array
                          begin
                            User.LMHashRaw := '{blank}';
                            User.NTHashRaw := '{blank}';
                            setlength(tempwidestr, vrec[j].Size);
                            move(pointer(nativeuint(Value.Data) + vrec[j].Offset + 204)^, tempwidestr[1], vrec[j].Size);
                            if vrec[j].Size > 4 then
                            begin
                              setlength(ba, vrec[j].Size - 4);
                              move(pointer(nativeuint(Value.Data) + vrec[j].Offset + 208)^, ba[0], vrec[j].Size - 4);
                              tempwidestr := '';
                              for b := 0 to Length(ba) - 1 do
                              begin
                                abyte := ba[b];
                                tempwidestr := tempwidestr + inttohex(abyte, 2) + ' ';
                              end;
                              if j = 13 then
                                User.LMHashRaw := tempwidestr;
                              if j = 14 then
                                User.NTHashRaw := tempwidestr;
                            end;
                          end;
                      end; // case
                    end; // j

                  end; // V-record

                  // process F-Record
                  if Value.Name = 'F' then
                  begin
                    move(Value.Data^, frec, sizeof(frec));
                    User.LastLogin := MyFileTimeToDateTime(frec.LastLogin);
                    User.PasswordLastSet := MyFileTimeToDateTime(frec.PasswordLastSet);
                    User.AccountExpires := MyFileTimeToDateTime(frec.AccountExpires);
                    User.LastPasswordFail := MyFileTimeToDateTime(frec.LastIncorrectPassword);
                    User.AccountStatus := frec.AccountPasswordStatus;
                    User.CountryCode := frec.CountryCode;
                    User.NumberLogins := frec.NumberLogins;
                    User.InvalidPasswordCount := frec.InvalidPasswordCount;
                  end;

                  if Value.Name = 'USERPASSWORDHINT' then
                    User.UserPasswordHint := Value.DataAsString(True); // stored as binary so force ito a string
                  if Value.Name = 'GIVENNAME' then
                    User.GivenName := Value.DataAsString(True); // stored as binary so force ito a string
                  if Value.Name = 'SURNAME' then
                    User.Surname := Value.DataAsString(True); // stored as binary so force ito a string
                  if Value.Name = 'INTERNETUSERNAME' then
                    User.InternetUserName := Value.DataAsString(True); // stored as binary so force ito a string
                  if (Value.Name = 'INTERNETPROVIDERGUID') and (Value.DataSize = 16) then
                    User.InternetProviderGUID := guidtostring(PGUID(Value.DataAsByteArray(16))^);

                  Value.free;
                end;
              end;

              ValueList.free;
            end; // OpenKey
            RawRegSubKeys.free;
          end; // EntryReader
          EntryReader.free;
          // User.free;
        end; // matchstr
      end; // User processing

      // Process the \SAM\Domains\Users\Names\* keys. This is where the account created date is.
      Re.MatchPattern := '\\SAM\\Domains\\Account\\Users\\Names\\(.+)';
      Re.SetSubjectStr(TRegSearchResultKey(RegResult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount > 0) then
        begin
          // add name string and date of key to TUserNames list
          Name := TUserName.Create;
          Name.Registry := RegResult.Entry;
          Name.Device := GetDeviceEntry(RegResult.Entry);
          Name.KeyPath := RegResult.FullPath;
          Name.UserName := Re.SubStr(1);
          NamesList.Add(Name);
          // Open this user name folder so we can get the key date and time
          EntryReader := TEntryReader.Create;
          if EntryReader.OpenData(RegResult.Entry) then
          begin
            RawRegSubKeys := TRawRegistry.Create(EntryReader, False);
            if RawRegSubKeys.OpenKey(RegResult.FullPath) then
              Name.AccountCreated := RawRegSubKeys.GetCurrentKeyDateTime;
            RawRegSubKeys.free;
          end; // EntryReader
          EntryReader.free;
          ConsoleLog(Name.UserName + ' : ' + DateTimeToStr(Name.AccountCreated));
        end; // matchstr
      end; // User names processing
    end;
  end; // regkeys found

  // join UserList and NamesList
  for u := 0 to UserList.Count - 1 do
  begin
    for n := 0 to NamesList.Count - 1 do
    begin
      User := TUserAccount(UserList[u]);
      Name := TUserName(NamesList[n]);
      if (User.Registry = Name.Registry) and (User.Device = Name.Device) and (User.UserName = Name.UserName) then
      begin
        User.AccountCreated := Name.AccountCreated;
        break;
      end;
    end;
  end;

  // ============================================================================
  // SAM User Accounts
  // ============================================================================
  BMF_Key_Group := 'User Accounts';
  BookmarkComment_StringList := TStringList.Create;
  for u := 0 to UserList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    BookmarkComment_StringList.Clear;
    User := TUserAccount(UserList[u]);
    ConsoleLog(ltMessagesMemo, ((StringOfChar('-', CHAR_LENGTH))));
    ConsoleLog(ltMessagesMemoBM, RPad('User Name:', rpad_value) + User.UserName);
    if User.Comment <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Full Name:', rpad_value) + User.Fullname);
    ConsoleLog(ltMessagesMemoBM, RPad('User ID:', rpad_value) + IntToStr(User.UserID) + '($' + inttohex(User.UserID, 4) + ')');
    ConsoleLog(ltMessagesMemoBM, RPad('Account Created:', rpad_value) + MyFormatDateTime(User.AccountCreated, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Account Last Modified:', rpad_value) + MyFormatDateTime(User.AccountLastModified, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Account Expires:', rpad_value) + MyFormatDateTime(User.AccountExpires, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Account Type:', rpad_value) + AccountTypeToStr(User.AccountType));

    slist := AccountStatusToStrList(User.AccountStatus);
    for s := 0 to slist.Count - 1 do
      if s = 0 then
        ConsoleLog(ltMessagesMemoBM, RPad('Account Status:', rpad_value) + slist[s])
      else
        ConsoleLog(ltMessagesMemoBM, RPad('              ', rpad_value) + slist[s]);
    slist.free;
    if User.Comment <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Comment:', rpad_value) + User.Comment);
    if User.UserComment <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('User Comment:', rpad_value) + User.UserComment);
    if User.HomeDir <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Home Dir:', rpad_value) + User.HomeDir);
    if User.HomeDirConnect <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Home Dir Connect:', rpad_value) + User.HomeDirConnect);
    if User.ScriptPath <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Script Path:', rpad_value) + User.ScriptPath);
    if User.ProfilePath <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Profile Path:', rpad_value) + User.ProfilePath);
    if User.Workstations <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Workstations:', rpad_value) + User.Workstations);

    ConsoleLog(ltMessagesMemoBM, RPad('Number Logins:', rpad_value) + IntToStr(User.NumberLogins));
    ConsoleLog(ltMessagesMemoBM, RPad('Last Login:', rpad_value) + MyFormatDateTime(User.LastLogin, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Password Last Set:', rpad_value) + MyFormatDateTime(User.PasswordLastSet, True));

    if User.UserPasswordHint <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Password Hint:', rpad_value) + User.UserPasswordHint);

    ConsoleLog(ltMessagesMemoBM, RPad('Last Password Fail:', rpad_value) + MyFormatDateTime(User.LastPasswordFail, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Invalid Password Count:', rpad_value) + IntToStr(User.InvalidPasswordCount));
    ConsoleLog(ltMessagesMemoBM, RPad('Country Code:', rpad_value) + CountryCodeToStr(User.CountryCode));

    if User.InternetUserName <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Internet User Name:', rpad_value) + User.InternetUserName);
    if User.InternetProviderGUID <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Internet Provider:', rpad_value) + InternetProviderToStr(User.InternetProviderGUID));
    if User.GivenName <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Given Name:', rpad_value) + User.GivenName);
    if User.Surname <> '' then
      ConsoleLog(ltMessagesMemoBM, RPad('Surname:', rpad_value) + User.Surname);

    ConsoleLog(RPad('LM Hash: ', rpad_value) + User.LMHashRaw);
    ConsoleLog(RPad('NT Hash: ', rpad_value) + User.NTHashRaw);

    // ConsoleLog(ltMessagesMemoBM,' ');
    ConsoleLog(ltMessagesMemoBM, ('~~~~~~~~~~~~~~~'));
    BM_Source_str := TDataEntry(User.Registry).FullPathName;
    ConsoleLog(ltMessagesMemoBM, 'Source: ' + BM_Source_str + User.KeyPath);
    BMC_Formatted := BookmarkComment_StringList.Text;

    // ==========================================================================
    // Bookmark Results
    // ==========================================================================
    Device := TDataEntry(User.Device).EntryName;
    BMF_Key_Name := User.UserName + HYPHEN + MyFormatDateTime(User.AccountCreated, True);
    BookMark(Device, SAM_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

  end;

  ConsoleLog(ltMessagesMemo, (StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog(ltMessagesMemo, #13#10 + 'End of results.');

  // Finishing bookmark folder count
  ConsoleLog('Finishing Bookmark folder count: ' + (IntToStr(BookmarksEntryList.Count)) + '. There were: ' + (IntToStr(BookmarksEntryList.Count - StartingBookmarkFolder_Count)) + ' new Bookmark folders added.');

  // Free Memory
  BookmarksEntryList.free;
  DeviceList.free;
  DeviceToSearchList.free;
  EvidenceEntryList.free;
  Re.free;
  Reg.free;
  UserList.free;
  NamesList.free;

  ConsoleLog(SCRIPT_NAME + ' ' + 'Finished.');

  // Must be freed after the last ConsoleLog
  BookmarkComment_StringList.free;
  ConsoleLog_StringList.free;
  Memo_StringList.free;

  Progress.DisplayMessageNow := 'Processing complete';

end.
