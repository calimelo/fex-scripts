{!NAME:      CLI Registry Triage - SAM User Accounts}
{!DESC:      Find and Bookmark User Account details from SAM and SYSTEM registry files}
{!AUTHOR:    GetData}
{!REFERENCE: Reference: Carvey, Harlan A. "Windows Registry Forensics", Syngress 2011'}

unit cli_registry_triage_sam_user_accounts;

interface

uses
  Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DataStreams, DateUtils, DIRegex, 
  Graphics, Math, NoteEntry, PropertyList, RawRegistry, RegEx, SysUtils, Variants; 

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
  // PARAMETERS                                                  //noslz
  PARAM_EVIDENCEMODULE          = 'EVIDENCEMODULE';              //noslz
  PARAM_FSSAMUSERACCOUNTS       = 'FSSAMUSERACCOUNTS';           //noslz
  PARAM_FSTRIAGE                = 'FSTRIAGE';                    //noslz
  PARAM_REGISTRYMODULE          = 'REGISTRYMODULE';              //noslz
  PARAM_InList                  = 'InList';                      //noslz
  // OTHER
  PARSE_KEY                     = '\SAM\Domains\Account\Users';  //noslz
  FILESIG_REGISTRY              = 'Registry';                    //noslz
  RS_CURRENT                    = 'Current';                     //noslz
  RS_DEFAULT                    = 'Default';                     //noslz
  RS_FAILED                     = 'Failed';                      //noslz
  RS_LAST_KNOWN_GOOD            = 'LastKnownGood';               //noslz
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  CHAR_LENGTH                   = 90;
  COLON                         = ': ';
  HYPHEN                        = ' - ';
  rpad_value                    = 30;
  SCRIPT_NAME                   = 'Triage' + HYPHEN + 'SAM User Accounts';
  SHOW_BLANK_BL                 = False;
  SPACE                         = ' ';
  TSWT                          = 'The script will terminate.';

  BMF_USER_ACCOUNTS             = 'User Accounts';
  BMF_MY_BOOKMARKS              = 'My Bookmarks';
  BMF_TRIAGE                    = 'FEX-Triage';
  BMF_REGISTRY                  = 'Registry';

  REG_NONE                      = 0;
  REG_SZ                        = 1;
  REG_EXPAND_SZ                 = 2;
  REG_BINARY                    = 3;
  REG_DWORD                     = 4;
  REG_DWORD_BIG_ENDIAN          = 5;
  REG_LINK                      = 6;
  REG_MULTI_SZ                  = 7;
  REG_RESOURCE_LIST             = 8;
  REG_FULL_RESOURCE_DESCRIPTOR  = 9;
  REG_RESOURCE_REQUIREMENTS_LIST = 10;
  REG_QWORD_LE                  = 11;
  rrReg31Sign                   = 1195725379; // 'CREG';
  rrRegNTSign                   = 1718052210; // 'regf';

  //Account/Password Flags
  ACB_ACCOUNT_DISABLED          = $0001;
  ACB_HOME_DIR_REQURIED         = $0002;
  ACB_PASS_NOT_REQURIED         = $0004;
  ACB_TEMP_DUP_ACCOUNT          = $0008;
  ACB_NORMAL_USER_ACCOUNT       = $0010;
  ACB_MNS_LOGON_ACCOUNT         = $0020;
  ACB_INTERDOMAIN_ACCOUNT       = $0040;
  ACB_WORKSTATION_ACCOUNT       = $0080;
  ACB_SERVER_ACCOUNT            = $0100;
  ACB_PASS_DOESNOT_EXPIRE       = $0200;
  ACB_ACCOUNT_AUTO_LOCKED       = $0400;
  
// Global Variables
var
  bl_AutoBookmark_results: boolean;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

type
  TRegHiveType = (hvSOFTWARE, hvSAM, hvSECURITY, hvUSER, hvSYSTEM, hvUSER9X, hvSYSTEM9X, hvANY, hvUNKNOWN);
  TRegDataType = (rdNone, rdString, rdExpandString, rdBinary, rdInteger,
    rdIntegerBigEndian, rdLink, rdMultiString, rdResourceList, rdFullResourceDescription,
    rdResourceRequirementsList, rdint64, rdUnknown);

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
    AccountPasswordStatus: word;  //offset 56.
    //unknown4: byte;
    unknown5: word;
    CountryCode: word;      //Default 0000, US 0001, Canada 0002
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
    AccountStatus: word;  //0=Active,1=inactive, 0=password required,4=password policies not used
    InternetUserName: string;
    InternetProviderGUID: string;
    Surname: string;
    GivenName: string;
    UserPasswordHint: string;
    AccountCreated: TDateTime;
  end;

  TUserName = class                //data from the \\Names\\* keys
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
    IncludeChildKeys: boolean;  // Search recursively through child keys also.
    Value: string; // The registry key name
    BookMarkFolder: string; // Default bookmark folder
  end;

  TRegSearchresult = class
    Entry: TEntry;
    SearchKey: TRegSearchKey;
    KeyPath: string; // The registry folder name
    EntryIdx: integer; // Index in the FRegEntries list
    function FullPath: string; abstract; virtual; // Full path of the key and value
  end;

  TRegSearchresultKey = class(TRegSearchresult)
    KeyName: string;
    KeyLastModified: TDateTime;
    function FullPath: string; override; // Full path of the key and value
    function GetChildKeys: TStringList;
  end;

  TRegSearchresultValue = class(TRegSearchresult)
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
    function DataAsint64: int64;
    function DataAsUnixDateTime: TDateTime; // Attempts to convert the "Data" to a DateTime
    function DataAsUnixDateTimeStr: string; // Does AsDateTime then formats as a string
    function DataAsFileTimeStr: string;
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
    function FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey) : integer;

  public
    constructor Create;
    destructor Destroy; override;
    function AddKey(AHive: TRegHiveType; AControlSet: TControlSet; ADataType: TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir: string = ''): integer;
    function FindKeys: integer;
    function FindRegFilesByDataStore(const ADataStore: string; aRegEx: string): integer; // Locate registry files in a datastore
    function FindRegFilesByDevice(ADevice: TEntry; ARegEx: string): integer; // Locate registry files on a device
    function FindRegFilesByInList(const ADataStore: string; aRegEx: string): integer; // Locate registry files using the CLI inList
    function GetHiveType(AEntry: TEntry): TRegHiveType;
    function HiveTypeToStr(AHive: TRegHiveType): string;
    procedure AddRegFile(ARegEntry: TEntry);
    procedure ClearKeys;
    procedure Clearresults;
    property ControlSetInfo[Index: integer]: TControlSetInfo read GetControlSetInfo write SetControlSetInfo;
    property EntryCount: integer read GetEntryCount;
    property Found[Index: integer]: TRegSearchresult read GetFoundKey;
    property FoundCount: integer read GetFoundCount;
    property GetEntry[Index: integer]: TEntry read GetRegEntry;
    property RegEntries: TList read FRegEntries;

  end;

  function AccountStatusToStrList(AStatus: word): TStringList;
  function AccountTypeToStr(AAccountType: integer): string;
  function CountryCodeToStr(ACountryCode: integer): string;
  function InternetProviderToStr(AProviderGUID: string): string;
  function MyFileTimeToDateTime(const Aint64: int64): TDateTime;
  function MyFormatDateTime(ADateTime: TDateTime; isUTC: boolean): string;
  function RPad(const AString: string; AChars: integer): string;
  function UnixTimeToDateTime(UnixTime: Integer): TDateTime;
  procedure BookMark(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
  procedure ConsoleLog(ALogType: TLogType; AString: string); overload;
  procedure ConsoleLog(AString: string); overload;
  procedure ConsoleLogBM(AString: string);
  procedure ConsoleLogMemo(AString: string);

var
  Memo_StringList:              TStringList;
  BookmarkComment_StringList:   TStringList;
  ConsoleLog_StringList:        TStringList;

implementation

{ =========== General Global Functions ============ }

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

function MyFileTimeToDateTime(const Aint64: int64): TDateTime;
begin
  Result := 0;
  if Aint64 = $0000000000000000 then Exit;
  if Aint64 = $FFFFFFFFFFFFFFFF then Exit;
  if Aint64 = $7FFFFFFFFFFFFFFF then Exit;
 // ConsoleLog('Result: ' + IntToStr(int64(Result)));
  Result := FileTimeToDateTime(Aint64);
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

function CountryCodeToStr(ACountryCode: integer): string;
begin
  Result := IntToStr(ACountryCode);
  case ACountryCode of
    0: Result := Result + ' (Default)';
    1: Result := Result + ' (USA)';
    2: Result := Result + ' (Canada)';
  end;
end;

function AccountTypeToStr(AAccountType: integer): string;
begin
  Result := '($' + inttohex(AAccountType,4) + ')';
  case AAccountType of
    $BC: Result :=  'Default Admin User ' + Result;
    $B0: Result :=  'Default Guest Account ' + Result;
    $D4: Result :=  'Custom Limited Account ' + Result;
  //  $1C0: Result := 'User Account ' + Result;
  end;
end;

function AccountStatusToStrList(AStatus: word): TStringList;
begin
  Result := TStringList.Create;
  if AStatus and ACB_ACCOUNT_DISABLED    = ACB_ACCOUNT_DISABLED    then Result.Add('Account disabled');
  if AStatus and ACB_HOME_DIR_REQURIED   = ACB_HOME_DIR_REQURIED   then Result.Add('Home directory required');
  if AStatus and ACB_PASS_NOT_REQURIED   = ACB_PASS_NOT_REQURIED   then Result.Add('Password not required');
  if AStatus and ACB_TEMP_DUP_ACCOUNT    = ACB_TEMP_DUP_ACCOUNT    then Result.Add('Temporary duplicate account');
  if AStatus and ACB_NORMAL_USER_ACCOUNT = ACB_NORMAL_USER_ACCOUNT then Result.Add('Normal user account');
  if AStatus and ACB_MNS_LOGON_ACCOUNT   = ACB_MNS_LOGON_ACCOUNT   then Result.Add('MNS logon user account');
  if AStatus and ACB_INTERDOMAIN_ACCOUNT = ACB_INTERDOMAIN_ACCOUNT then Result.Add('Interdomain trust account');
  if AStatus and ACB_WORKSTATION_ACCOUNT = ACB_WORKSTATION_ACCOUNT then Result.Add('Workstation trust account');
  if AStatus and ACB_SERVER_ACCOUNT      = ACB_SERVER_ACCOUNT      then Result.Add('Server trust account');
  if AStatus and ACB_PASS_DOESNOT_EXPIRE = ACB_PASS_DOESNOT_EXPIRE then Result.Add('Password does not expire');
  if AStatus and ACB_ACCOUNT_AUTO_LOCKED = ACB_ACCOUNT_AUTO_LOCKED then Result.Add('Account auto locked');
end;

function InternetProviderToStr(AProviderGUID: string): string;
begin
  Result := AProviderGUID;
  if AProviderGUID = '{D7F9888F-E3FC-49B0-9EA6-A85B5F392A4F}' then
    Result := 'Microsoft Account ' + Result;
end;

//------ { TControlSetInfo Class } ---------------------------------------------
function TControlSetInfo.GetActiveCSAsInteger: integer;
begin
  Result := -1;
  case ActiveCS of
    csCurrent:       Result := CurrentCS;
    csDefault:       Result := DefaultCS;
    csFailed:        Result := FailedCS;
    csLastKnownGood: Result := LastKnownGoodCS;
    csNone:          Result := -1;
    csAny:           Result := -2;
  end;
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
  EntryReader: TEntryReader;
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

// Returns date time string-----------------------------------------------------
function TRegSearchresultValue.DataAsUnixDateTimeStr: string;
var
  dt: TDateTime;
begin
  Result := '';
  dt := DataAsUnixDateTime;
  if dt > 0 then
     Result := DateTimeToStr(dt) + ' UTC';
end;

// Returns FileTime as a string ------------------------------------------------
function TRegSearchresultValue.DataAsFileTimeStr: string;
var
  aFileTime: TFileTime;
begin
  try
    if (DataSize >= 8) then
      move(Data^, aFileTime, 8);
    Result := FileTimeToString(aFileTime);
  except
    Result := '';
  end;
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
function TMyRegistry.AddKey(AHive: TRegHiveType; AControlSet: TControlSet; ADataType: TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir : string = ''): integer;
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
// Function: Find registry files by device
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
// Function: Find registry files by InList
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
// Function: Find registry files by datastore
//------------------------------------------------------------------------------
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

function TMyRegistry.FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey) : integer;
var
  strKeyName: string;
  SubRawReg: TRawRegistry;
  SubSearchKey: TRegSearchKey;
  FoundKey: TRegSearchresultKey;
  FoundValue: TRegSearchresultValue;
  DataInfo: TRegDataInfo;
  bytesread: integer;
  slValues: TStringList;
  v, k: integer;
  csi: TControlSetInfo;
begin
  Result := -1;
  strKeyName := SearchKey.Key;

  if (SearchKey.Hive = hvSYSTEM) and (SearchKey.ControlSet <> csNone) then
  begin
    csi := TControlSetInfo(FControlSets[EntryIdx]);
    case csi.ActiveCS of
       csCurrent:  strKeyName := '\ControlSet00' + IntToStr(csi.GetActiveCSAsInteger) + SearchKey.Key;
    end;
  end;

  slValues := TStringList.Create;
  try
    if Not RawReg.OpenKey(strKeyName) then
    begin
      //Debug('FindKeys', 'OpenKey Failed: '+ strKeyName);
    end
    else
    begin
      //Debug('FindKeys', 'OpenKey Success: '+ strKeyName);

      if SearchKey.Value <> '*' then
      begin
        //Debug('FindKeys', 'KEY: '+ SearchKey.Value);
        // Add a single value
        slValues.Add(SearchKey.Value);
      end
      else if Not RawReg.GetKeyNames(slValues) then
      begin
        //Debug('FindKeys', 'GetValueNames Failed for: '+ strKeyName)
        //ConsoleLog('GetValueNames Failed for: '+ strKeyName);
      end
      else
      begin
        // Handle the '*'...
        //Debug('FindKeys', 'GetValueNames: '+ strKeyName + ' - ' + IntToStr(slValues.Count));

        if slValues.Count = 0 then
        begin
          ConsoleLog('No values in: ' + strKeyName);
        end
        else
        begin
          //Debug('FindKeys', 'GetValueNames: '+ IntToStr(slValues.Count));
          SubRawReg := TRawRegistry.Create(EntryReader, False);

          //if SubRawReg = nil then
            //Progress.Log('TRawRegistry Failed');

          try
            for k := 0 to slValues.Count - 1 do
            begin
              if not Progress.isRunning then break;
              FoundKey := TRegSearchresultKey.Create;
              FFoundresults.Add(FoundKey);

              FoundKey.SearchKey := SearchKey;
              FoundKey.Entry := RegEntry;
              FoundKey.KeyPath := strKeyName;
              FoundKey.KeyName := slValues[k];
              if SubRawReg.OpenKey(FoundKey.FullPath) then
                FoundKey.KeyLastModified := SubRawReg.GetCurrentKeyDateTime;  // Get the date/time
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
                  SubSearchKey.BookMarkFolder := SearchKey.BookmarkFolder;

                  //Debug('FindKeys', 'Finding Sub Keys: '+ strKeyName + '\' + FoundKey.KeyName);
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

      //==================================================================
      // Search for Value List
      // =================================================================
      for v := 0 to slValues.Count - 1 do
      begin
        if not Progress.isRunning then break;
        //Debug('FindKeys', 'FOUND KEY: '+ slValues[v]);

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

          bytesread := RawReg.ReadRawData(slValues[v], FoundValue.Data^, FoundValue.DataSize);
        end;
      end;
    end;

  finally
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
  HiveType: TRegHiveType;
begin
  //Debug('FindKeys', 'Start');
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

      //Debug('FindKeys', 'Reg: ' + RegEntry.FullPathName);

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

    Result := FFoundresults.Count;
  finally
    //Debug('FindKeys', 'free...');
    EntryReader.free;

    //Debug('FindKeys', 'Calc Values...');

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

    ConsoleLog(RPad('FoundValues: ', rpad_value) + IntToStr(k));
    ConsoleLog(RPad('FoundKeys:', rpad_value) + IntToStr(v));

    //Debug('FindKeys', 'FoundKeys: '+ IntToStr(v));
    //Debug('FindKeys', 'FoundKeys: '+ IntToStr(k));
  end;
end;

var
  // Boolean
  bl_EvidenceModule:            boolean;
  bl_FSSamUserAccounts:         boolean;
  bl_FSTriage:                  boolean;
  bl_GUIShow:                   boolean;
  bl_RegModule:                 boolean;
  bl_ScriptsModule:             boolean;
  bl_UseInList:                 boolean;

  // ControlSets
  csActive:                     TControlSet;
  DefaultControlSet:            TControlSet;
  FailedControlSet:             TControlSet;
  LastKnownGoodControlSet:      TControlSet;

  // DataStores
  BookmarksEntryList:           TDataStore;
  EvidenceEntryList:            TDataStore;

  // Entries
  dEntry:                       TEntry;
  DeviceListEntry:              TEntry;
  EntryReader:                  TEntryReader;

  // Integers
  b,i,j,s,u,v,x,y,n:            integer;
  bytesread:                    int64;
  regfiles, regcount:           integer;
  StartingBookmarkFolder_Count: integer;

  // List
  DeviceList:                   TList;
  DeviceToSearchList:           TList;
  UserList:                     TList;
  NamesList:                    TList;
  
  // Regex
  Re:                           TDIPerlRegEx;

  // Registry
  DataInfo:                     TRegDataInfo;
  RawRegSubKeys:                TRawRegistry;
  Reg:                          TMyRegistry;
  Regresult:                    TRegSearchresult;
  RegresultValue:               TRegSearchresultValue;
  Value:                        TRegSearchresultValue;

  // Strings
  BM_Source_str:                string;
  BMC_Formatted:                string;
  BMF_Key_Group:                string;
  BMF_Key_Name:                 string;
  Device:                       string;
  mstr:                         string;
  Param:                        string;
  str_RegFiles_Regex:           string;
  tempwidestr:                  string;

  // Starting Checks
  bContinue:                    boolean;
  CaseName:                     string;
  FEX_Executable:               string;
  FEX_Version:                  string;
  StartCheckEntry:              TEntry;
  StartCheckDataStore:          TDataStore;

  // StringLists
  slist:                        TStringList;
  ValueList:                    TStringList;

  // MISC
  User:                         TUserAccount;
  Name:                         TUserName;

  ba: array of byte;
  abyte: byte;
  vrec: array[0..16] of TVRecord;
  frec: TFRecord;

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

  //============================================================================
  // Setup results Header
  //============================================================================
  Memo_StringList := TStringList.Create;
  ConsoleLog_StringList := TStringList.Create;
  FEX_Executable := GetApplicationDir + 'forensicexplorer.exe';
  FEX_Version := GetFileVersion(FEX_Executable);

  ConsoleLog(ltMessagesMemo, (Stringofchar('-', CHAR_LENGTH)));

  ConsoleLog(RPad('~ Script:', rpad_value) + SCRIPT_NAME);
  ConsoleLog((RPad('~ Parse:', rpad_value) + PARSE_KEY));
  ConsoleLog(ltMemo, (RPad('Parse:', rpad_value) + PARSE_KEY));
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
      BookMarkDevice('', '\Device', '', dEntry, '', True);
    end;
    dEntry := EvidenceEntryList.Next;
  end;
  ConsoleLog(RPad('Device list count:', rpad_value) + IntToStr(DeviceList.Count));

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
  bl_FSSamUserAccounts := False;
  bl_FSTriage := False;
  bl_UseInList := False;
  bl_RegModule := False;
  bl_ScriptsModule := False;

  if (CmdLine.Params.Indexof(PARAM_EVIDENCEMODULE)      <> -1) then bl_EvidenceModule      := True;
  if (CmdLine.Params.Indexof(PARAM_FSSAMUSERACCOUNTS)   <> -1) then bl_FSSamUserAccounts   := True;
  if (CmdLine.Params.Indexof(PARAM_FSTRIAGE)            <> -1) then bl_FSTriage            := True;
  if (CmdLine.Params.Indexof(PARAM_InList)              <> -1) then bl_UseInList           := True;
  if (CmdLine.Params.Indexof(PARAM_REGISTRYMODULE)      <> -1) then bl_RegModule           := True;
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
    ConsoleLog('Running from Evidence module.');
  end;

  if bl_FSSamUserAccounts then
  begin
    bl_GUIshow := True;
    bl_AutoBookmark_results := False;
    ConsoleLog('Running from FileSystem module.');
  end;

  if bl_FSTriage then
  begin
    bl_GUIshow := False;
    bl_AutoBookmark_results := True;
    ConsoleLog('Running from FileSystem module Triage.');
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

  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog('The Regex search string is:');
  ConsoleLog('  ' + str_RegFiles_Regex);
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));

  Progress.DisplayMessage := 'Finding registry files...';

  regfiles := 0;

  //============================================================================
  // Start Processing based on the parameter/s received
  //============================================================================

  if bl_RegModule           = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_REGISTRY, str_RegFiles_Regex) else
  if bl_FSSamUserAccounts   = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
  if bl_FSTriage            = True then regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex) else
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

  //============================================================================
  // Setup the correct control-set info for each of the SYSTEM hives found
  //============================================================================
  csActive := csCurrent;
  DefaultControlSet := csDefault;
  FailedControlSet := csFailed;
  LastKnownGoodControlSet := csLastKnownGood;
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  ConsoleLog('Updating control set info for SYSTEM hives.');
  // ADDKEY  HiveType    Cntrl
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_CURRENT);
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_DEFAULT);
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_FAILED);
  Reg.AddKey(hvSYSTEM, csNone, dtInteger, '\Select', False, RS_LAST_KNOWN_GOOD);
  Reg.FindKeys;
  for i := 0 to Reg.FoundCount - 1 do
  begin
    if not Progress.isRunning then break;
    Regresult := Reg.Found[i];
    if Regresult is TRegSearchresultValue then
    begin
      RegresultValue := TRegSearchresultValue(Regresult);
      Reg.ControlSetInfo[Regresult.EntryIdx].ActiveCS := csActive;
      if UpperCase(RegresultValue.FullPath) = '\SELECT\CURRENT' then
        Reg.ControlSetInfo[Regresult.EntryIdx].CurrentCS := RegresultValue.DataAsInteger
      else if UpperCase(RegresultValue.FullPath) = '\SELECT\DEFAULT' then
        Reg.ControlSetInfo[Regresult.EntryIdx].DefaultCS := RegresultValue.DataAsInteger
      else if UpperCase(RegresultValue.FullPath) = '\SELECT\FAILED' then
        Reg.ControlSetInfo[Regresult.EntryIdx].FailedCS := RegresultValue.DataAsInteger
      else if UpperCase(RegresultValue.FullPath) = '\SELECT\LASTKNOWNGOOD' then
        Reg.ControlSetInfo[Regresult.EntryIdx].LastKnownGoodCS := RegresultValue.DataAsinteger;
    end;
  end;
  Reg.ClearKeys;
  Reg.Clearresults;
  ConsoleLog('Finished updating SYSTEM control set.');
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));

  //============================================================================
  // Add keys to the search list
  //============================================================================
  Reg.AddKey(hvSAM, csNone, dtString, PARSE_KEY, True, '*', 'User Accounts');  //add every key in each SAM file

  //============================================================================
  // Search for Keys
  //============================================================================
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  ConsoleLog('Searching for registry keys of interest...');

  regcount := Reg.FindKeys;
  ConsoleLog(HYPHEN + 'Found ' + IntToStr(Reg.FoundCount) + ' keys.');

  //============================================================================
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

  //============================================================================
  // Iterate Reg results
  //============================================================================
  for i := 0 to Reg.FoundCount - 1 do
  begin
    if not Progress.isRunning then
      Break;
    Progress.IncCurrentProgress;
    Regresult := Reg.Found[i];
	
    // Interogate Keys found
    if Regresult = nil then
    begin
      continue;
    end;
    if Regresult is TRegSearchresultKey then
    begin
      // Process the \SAM\Domains\Users\* keys
      Re.MatchPattern := '\\SAM\\Domains\\Account\\Users\\([0-9A-F]{8})';
      Re.SetSubjectStr(TRegSearchresultKey(Regresult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount > 0) then
        begin
          // Create new UserAccount
          User := TUserAccount.Create;
          User.Registry := Regresult.Entry;
          User.Device := GetDeviceEntry(Regresult.Entry);
          User.KeyPath := Regresult.FullPath;
          User.UserID := StrToInt('$' + Re.SubStr(1));
          UserList.Add(User);
          // Open this users registry key and get the V, F and other values
          EntryReader:= TEntryReader.Create;
          if EntryReader.OpenData(Regresult.Entry) then
          begin
            RawRegSubKeys := TRawRegistry.Create(EntryReader, False);
            if RawRegSubKeys.OpenKey(Regresult.FullPath) then
            begin
              User.AccountLastModified := RawRegSubKeys.GetCurrentKeyDateTime;
              ValueList := TStringList.Create;
              ValueList.Clear;
              RawRegSubKeys.GetValueNames(ValueList);
              for v := 0 to ValueList.Count - 1 do
              begin
                if not Progress.isRunning then break;
                if RawRegSubKeys.GetDataInfo(ValueList[v], DataInfo) then
                begin
                  Value := TRegSearchresultValue.Create;
                  Value.Name := UpperCase(ValueList[v]);
                  Value.DataType := DataInfo.RegData;
                  Value.DataSize := DataInfo.DataSize;
                  Value.Data := nil;
                  GetMem(Value.Data, Value.DataSize);
                  FillChar(Value.Data^, Value.DataSize, 0);
                  bytesread := RawRegSubKeys.ReadRawData(ValueList[v], Value.Data^, Value.DataSize);

                  //process V-Record
                  if Value.Name = 'V' then
                  begin
                    move(Value.Data^, vrec, sizeof(vrec));     //populate the vrecord offset array
                    for j := 0 to 16 do // 17 records - the first record represents the offset records list
                    begin
                      if not Progress.isRunning then break;
                      tempwidestr := '';
                      if (j <> 0) and (vrec[j].Size > 0) and (vrec[j].Size < 256) then
                      begin
                        setlength(tempwidestr, vrec[j].Size div 2);
                        move(pointer(nativeuint(Value.Data) + vrec[j].Offset + 204)^, tempwidestr[1], vrec[j].Size);
                      end
                      else
                      begin
 //                       ConsoleLog('Skipping value: '+IntToStr(i)+'   '+IntToStr(j)+'    '+tempwidestr);
                        continue;
                      end;
                      case j of
                        0: User.AccountType := vrec[j].Size;  //The account type is stored in the size longword of the first vrec entry.
                        1: User.Username := tempwidestr;
                        2: User.Fullname := tempwidestr;
                        3: User.Comment := tempwidestr;
                        4: User.UserComment := tempwidestr;
                        6: User.HomeDir := tempwidestr;
                        7: User.HomeDirConnect := tempwidestr;
                        8: User.ScriptPath := tempwidestr;
                        9: User.ProfilePath := tempwidestr;
                       10: User.Workstations := tempwidestr;
                       13..14:
                           //for LM and NT hashes read as byte array
                           begin
                             User.LMHashRaw := '{blank}';
                             User.NTHashRaw := '{blank}';
                             setlength(tempwidestr, vrec[j].Size);
                             move(pointer(nativeuint(Value.Data) + vrec[j].Offset + 204)^, tempwidestr[1], vrec[j].Size);
                             if vrec[j].Size > 4 then
                             begin
                               setlength(ba, vrec[j].Size - 4);
                               move(pointer(nativeuint(Value.Data) + vrec[j].Offset + 208)^, ba[0], vrec[j].size - 4);
                               tempwidestr := '';
                               for b := 0 to length(ba) - 1 do
                               begin
                                 abyte := ba[b];
                                 tempwidestr := tempwidestr + IntToHex(abyte, 2) + ' ';
                               end;
                               if j = 13 then User.LMHashRaw := tempwidestr;
                               if j = 14 then User.NTHashRaw := tempwidestr;
                             end;
                           end;
                      end; // case
                    end; //j

                  end;  //V-record

                  //process F-Record
                  if Value.Name = 'F' then
                  begin
                    move(Value.Data^, frec, sizeof(frec));
                    User.LastLogin := MyFileTimeToDateTime(frec.LastLogin);
                    User.PasswordLastSet := MyFileTimeToDateTime(frec.PasswordLastSet);
                    User.AccountExpires := MyFileTimeToDateTime(frec.AccountExpires);
                    User.LastPasswordFail := MyFileTimeToDateTime(frec.LastIncorrectPassword);
                    User.AccountStatus := frec.AccountPasswordStatus;
                    User.CountryCode := frec.CountryCode;
                    User.NumberLogins :=  frec.NumberLogins;
                    User.InvalidPasswordCount := frec.InvalidPasswordCount;
                  end;

                  if Value.Name = 'USERPASSWORDHINT' then
                    User.UserPasswordHint := Value.DataAsString(True);    //stored as binary so force ito a string
                  if Value.Name = 'GIVENNAME' then
                    User.GivenName := Value.DataAsString(True);           //stored as binary so force ito a string
                  if Value.Name = 'SURNAME' then
                    User.Surname := Value.DataAsString(True);           //stored as binary so force ito a string
                  if Value.Name = 'INTERNETUSERNAME' then
                    User.InternetUserName := Value.DataAsString(True);    //stored as binary so force ito a string
                  if (Value.Name = 'INTERNETPROVIDERGUID') and (Value.DataSize = 16) then
                    User.InternetProviderGUID := guidtostring(PGUID(Value.DataAsByteArray(16))^);

                  Value.free;
                end;
              end;

              ValueList.free;
            end; //OpenKey
            RawRegSubKeys.free;
          end; //EntryReader
          EntryReader.free;
         // User.free;
        end; //matchstr
      end; //User processing

      // Process the \SAM\Domains\Users\Names\* keys. This is where the account created date is.
      Re.MatchPattern := '\\SAM\\Domains\\Account\\Users\\Names\\(.+)';
      Re.SetSubjectStr(TRegSearchresultKey(Regresult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount > 0) then
        begin
          //add name string and date of key to TUserNames list
          Name := TUserName.Create;
          Name.Registry := Regresult.Entry;
          Name.Device := GetDeviceEntry(Regresult.Entry);
          Name.KeyPath := Regresult.FullPath;
          Name.UserName := Re.SubStr(1);
          NamesList.Add(Name);
          // Open this user name folder so we can get the key date and time
          EntryReader:= TEntryReader.Create;
          if EntryReader.OpenData(Regresult.Entry) then
          begin
            RawRegSubKeys := TRawRegistry.Create(EntryReader, False);
            if RawRegSubKeys.OpenKey(Regresult.FullPath) then
              Name.AccountCreated := RawRegSubKeys.GetCurrentKeyDateTime;
            RawRegSubKeys.free;
          end; //EntryReader
          EntryReader.free;
          ConsoleLog(RPad(Name.UserName + ':', rpad_value) + datetimetostr(Name.AccountCreated));
        end; //matchstr
      end; //User names processing
    end;
  end; //regkeys found

  //join UserList and NamesList
  for u := 0 to UserList.Count - 1 do
  begin
    for n := 0 to NamesList.Count - 1 do
    begin
      User := TUserAccount(UserList[u]);
      Name := TUserName(NamesList[n]);
      if (User.Registry = Name.Registry) and
         (User.Device = Name.Device) and
         (User.UserName = Name.UserName) then
      begin
        User.AccountCreated := Name.AccountCreated;
        break;
      end;
    end;
  end;

  //============================================================================
  // SAM User Accounts
  //============================================================================
  BMF_Key_Group := 'User Accounts';
  BookmarkComment_StringList := TStringList.Create;
  for u := 0 to UserList.Count - 1 do
  begin
    if not Progress.isRunning then break;
    BookmarkComment_StringList.Clear;
    User := TUserAccount(UserList[u]);
    ConsoleLog(ltMessagesMemo, ((Stringofchar('-', CHAR_LENGTH))));
    ConsoleLog(ltMessagesMemoBM, RPad('User Name:',                                                 rpad_value) + User.Username);
    if User.Comment        <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Full Name:',               rpad_value) + User.Fullname);
    ConsoleLog(ltMessagesMemoBM, RPad('User ID:',                                                   rpad_value) + IntToStr(User.UserID) + '($' + inttohex(User.UserID, 4) + ')');
    ConsoleLog(ltMessagesMemoBM, RPad('Account Created:',                                           rpad_value) + MyFormatDateTime(User.AccountCreated, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Account Last Modified:',                                     rpad_value) + MyFormatDateTime(User.AccountLastModified, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Account Expires:',                                           rpad_value) + MyFormatDateTime(User.AccountExpires, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Account Type:',                                              rpad_value) + AccountTypeToStr(User.AccountType));

    slist := AccountStatusToStrList(User.AccountStatus);
    for s := 0 to slist.Count - 1 do
      if s = 0 then ConsoleLog(ltMessagesMemoBM, RPad('Account Status:',                            rpad_value) + slist[s])
               else ConsoleLog(ltMessagesMemoBM, RPad('              ',                             rpad_value) + slist[s]);
    slist.free;
    if User.Comment        <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Comment:',                 rpad_value) + User.Comment);
    if User.UserComment    <> '' then ConsoleLog(ltMessagesMemoBM, RPad('User Comment:',            rpad_value) + User.UserComment);
    if User.HomeDir        <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Home Dir:',                rpad_value) + User.HomeDir);
    if User.HomeDirConnect <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Home Dir Connect:',        rpad_value) + User.HomeDirConnect);
    if User.ScriptPath     <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Script Path:',             rpad_value) + User.ScriptPath);
    if User.ProfilePath    <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Profile Path:',            rpad_value) + User.ProfilePath);
    if User.Workstations   <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Workstations:',            rpad_value) + User.Workstations);

    ConsoleLog(ltMessagesMemoBM, RPad('Number Logins:',                                             rpad_value) + IntToStr(User.NumberLogins));
    ConsoleLog(ltMessagesMemoBM, RPad('Last Login:',                                                rpad_value) + MyFormatDateTime(User.LastLogin, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Password Last Set:',                                         rpad_value) + MyFormatDateTime(User.PasswordLastSet, True));

    if User.UserPasswordhint <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Password Hint:',         rpad_value) + User.UserPasswordHint);

    ConsoleLog(ltMessagesMemoBM, RPad('Last Password Fail:',                                        rpad_value) + MyFormatDateTime(User.LastPasswordFail, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Invalid Password Count:',                                    rpad_value) + IntToStr(User.InvalidPasswordCount));
    ConsoleLog(ltMessagesMemoBM, RPad('Country Code:',                                              rpad_value) + CountryCodeToStr(User.CountryCode));

    if User.InternetUserName <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Internet User Name:',    rpad_value) + User.InternetUserName);
    if User.InternetProviderGUID <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Internet Provider:', rpad_value) + InternetProviderToStr(User.InternetProviderGUID));
    if User.GivenName        <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Given Name:',            rpad_value) + User.GivenName);
    if User.Surname          <> '' then ConsoleLog(ltMessagesMemoBM, RPad('Surname:',               rpad_value) + User.Surname);

    ConsoleLog(RPad('LM Hash: ',                                                                  rpad_value) + User.LMHashRaw);
    ConsoleLog(RPad('NT Hash: ',                                                                  rpad_value) + User.NTHashRaw);

    //ConsoleLog(ltMessagesMemoBM,' ');
    ConsoleLog(ltMessagesMemoBM,('~~~~~~~~~~~~~~~'));
    BM_Source_str := TDataEntry(User.Registry).FullPathName;
    ConsoleLog(ltMessagesMemoBM, 'Source: ' +  BM_Source_str + User.KeyPath);
    BMC_Formatted := BookmarkComment_StringList.Text;

    //==========================================================================
    // Bookmark results
    //==========================================================================
    Device := TDataEntry(User.Device).EntryName;
    BMF_Key_Name := User.Username +  HYPHEN  + MyFormatDateTime(User.AccountCreated, True);
    BookMark(Device, SAM_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

  end;

  ConsoleLog(ltMessagesMemo, (Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog(ltMessagesMemo, #13#10+'End of results.');

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

  ConsoleLog(SCRIPT_NAME  + ' ' + 'Finished.');

  // Must be freed after the last ConsoleLog
  BookmarkComment_StringList.free;
  ConsoleLog_StringList.free;
  Memo_StringList.free;

  Progress.DisplayMessageNow := 'Processing complete';
end.
