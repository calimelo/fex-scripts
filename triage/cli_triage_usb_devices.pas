{ !NAME:      CLI Registry Triage - USB Devices }
{ !DESC:      Triage USB Device information from the registry }
{ !AUTHOR:    GetData }
{ !REFERENCE: Reference: Carvey, Harlan A. "Windows Registry Forensics", Syngress 2011' }

unit cli_registry_triage_usb_devices;

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
  FILESIG_REGISTRY = 'Registry'; // noslz
  HIVE_ANY = 'ANY'; // noslz
  HIVE_NTUSER = 'NTUSER.DAT'; // noslz
  HIVE_SAM = 'SAM'; // noslz
  HIVE_SECURITY = 'SECURITY'; // noslz
  HIVE_SOFTWARE = 'SOFTWARE'; // noslz
  HIVE_SYSTEM = 'SYSTEM'; // noslz
  HIVE_UNDETERMINED = 'UNDETERMINED'; // noslz
  HIVE_USER = 'USER'; // noslz
  PARAM_EVIDENCEMODULE = 'EVIDENCEMODULE'; // noslz
  PARAM_FSTRIAGE = 'FSTRIAGE'; // noslz
  PARAM_FSUSBDEVICES = 'FSUSBDEVICES'; // noslz
  PARAM_REGISTRYMODULE = 'REGISTRYMODULE'; // noslz
  PARSE_KEY = '\SYSTEM\ControlSet001\Enum\USBSTOR'; // noslz
  RS_CURRENT = 'Current'; // noslz
  RS_DEFAULT = 'Default'; // noslz
  RS_FAILED = 'Failed'; // noslz
  RS_LAST_KNOWN_GOOD = 'LastKnownGood'; // noslz
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  BMF_MY_BOOKMARKS = 'My Bookmarks';
  BMF_REGISTRY = 'Registry';
  BMF_TRIAGE = 'Triage';
  BMF_USBSTOR_DEVICES = 'USBStor Devices';
  CHAR_LENGTH = 90;
  COLON = ': ';
  COMMA = ',';
  HYPHEN = ' - ';
  PIPE = '|';
  RPAD_VALUE = 40;
  SCRIPT_NAME = 'Triage' + HYPHEN + 'Registry' + HYPHEN + 'USB Devices';
  SHOW_BLANK_BL = False;
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gBookmarkComment_StringList: TStringList;
  gConsoleLog_StringList: TStringList;
  gMemo_StringList: TStringList;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

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

  TUSBDevice = class
    Copies: integer;
    Device: TEntry;
    DeviceClassID: string; // e.g. Disk&Ven_Generic&Prod_USB_xD/SM_Reader&Rev_1.02
    DeviceType: string;
    DriveLetter: string;
    FirstConnected: TDateTime; // Local time from setupapi.dev.log file
    FirstConnectedAfterReboot: TDateTime;
    FriendlyName: string;
    GUID: string;
    LastConnectedByMountPoints2: TDateTime;
    LastConnectedByVIDPID: TDateTime;
    ParentIDPrefix: string;
    ProductID: string;
    ProductName: string;
    Registry: TEntry;
    Revision: string;
    SerialNumber: string;
    USBSTORKey: string;
    User: string;
    VendorID: string;
    VendorName: string;
    VolumeLabel: string;
    VolumeSerialNumber: string;
  end;

  TMountedDevice = class
    Device: TEntry;
    DeviceClassID: string; // e.g. Disk&Ven_Generic&Prod_USB_xD/SM_Reader&Rev_1.02
    LastDriveLetter: string;
    SerialNumber: string;
  end;

  TVolumeInfo = class
    Device: TEntry;
    DeviceClassID: string;
    GUID: string;
    SerialNumber: string;
  end;

  TMountPoints2 = class
    Device: TEntry;
    GUID: string;
    LastConnected: TDateTime;
    User: string;
  end;

  TVidPid = class
    Device: TEntry;
    LastConnected: TDateTime;
    PID: string;
    SerialNumber: string;
    VID: string;
  end;

  TRegSearchKey = class
    BookMarkFolder: string; // Default bookmark folder
    ControlSet: TControlSet;
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
    FFoundResults: TObjectList; // List of results after a scan
    FControlSets: TObjectList; // List of controls sets for each registry file in FRegEntries. Only used for SYSTEM hives.
    function GetRegEntry(Index: integer): TEntry;
    function GetFoundKey(Index: integer): TRegSearchResult;
    function GetControlSetInfo(Index: integer): TControlSetInfo;
    procedure SetControlSetInfo(Index: integer; AValue: TControlSetInfo);
    function GetFoundCount: integer;
    function GetEntryCount: integer;
    function FindKey(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;
    function FindKeyV2(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;

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
procedure BookMark_Create(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);

implementation

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

function UnixTimeToDateTime(UnixTime: integer): TDateTime;
begin
  Result := EncodeDate(1970, 1, 1) + (UnixTime div 86400);
  Result := Result + ((UnixTime mod 86400) / 86400);
end;

procedure ConsoleLog(AString: string); overload;
begin
  Progress.Log(AString);
  if assigned(gConsoleLog_StringList) then
    if gConsoleLog_StringList.Count < 5000 then
      gConsoleLog_StringList.Add(AString);
end;

procedure ConsoleLogMemo(AString: string);
begin
  if assigned(gMemo_StringList) then
    if gMemo_StringList.Count < 5000 then
      gMemo_StringList.Add(AString);
end;

procedure ConsoleLogBM(AString: string);
begin
  if assigned(gBookmarkComment_StringList) then
    if gMemo_StringList.Count < 5000 then
      gBookmarkComment_StringList.Add(AString);
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
  begin
    Abm_Source_str2 := StringReplace(Abm_Source_str, '\', '-', [rfReplaceAll]);
    // Set the next folder to be then device name + registry file path (ensures multiple registry files on the same system are reported) *
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + ADevice + '\' + BMF_REGISTRY + '\' + UpperCase(Abmf_Hive_Name) + '\' + Abmf_Key_Group + '\' + Abm_Source_str2, bCreate);
    if bCreate then
      UpdateBookmark(bmParent, Abm_Source_str);
    // Need to force bookmark every time because identical devices can have different dates and times - use delete bookmark to stop repeats
    bmNew := NewBookmark(bmParent, Abmf_Key_Name, AComment);
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
  Result := -1;
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
    Result := Result + IntToHex(abyte, 2) + ' ';
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
    date1 := anEntry1.Modified;
    date2 := anEntry2.Modified;
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
      Result := HIVE_SOFTWARE;
    hvSAM:
      Result := HIVE_SAM;
    hvSECURITY:
      Result := HIVE_SECURITY;
    hvUSER:
      Result := HIVE_USER;
    hvSYSTEM:
      Result := HIVE_SYSTEM;
    hvUSER9X:
      Result := 'USER98ME';
    hvSYSTEM9X:
      Result := 'SYSTEM98ME';
    hvANY:
      Result := HIVE_ANY;
  else
    Result := HIVE_UNDETERMINED;
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
            if (aDeterminedFileDriverInfo.ShortDisplayName = FILESIG_REGISTRY) then
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
        if Entry.ClassName = 'TSentFromVirtualParent' then
        begin
          AddRegFile(Entry);
          Entry := EntryList.Next;
          Continue;
        end;
        if RegexMatch(Entry.FullPathName, ARegEx, False) then // Only add those that match the regex
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
  Result := 0;
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

          try
            for k := 0 to Value_StringList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              FoundKey := TRegSearchResultKey.Create;
              FFoundResults.Add(FoundKey);
              Result := Result + 1;

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
      for v := 0 to Value_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        // Debug('FindKeys', 'FOUND KEY: '+ Value_StringList[v]);

        if RawReg.OpenKey(strKeyName) and RawReg.GetDataInfo(Value_StringList[v], DataInfo) then
        begin
          FoundValue := TRegSearchResultValue.Create;
          FFoundResults.Add(FoundValue);

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

// Find the registry keys ------------------------------------------------------
function TMyRegistry.FindKeys: integer;
var
  r, k, v: integer;
  RegEntry: TEntry;
  EntryReader: TEntryReader;
  RawReg: TRawRegistry;
  SearchKey: TRegSearchKey;
  HiveType: TRegHiveType;
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

            Result := Result + FindKeyV2(RegEntry, EntryReader, RawReg, r, SearchKey);
          end;
        end;
      finally
        if RawReg <> nil then
          RawReg.free;
      end;
    end;

    Result := FFoundResults.Count;
  finally
    EntryReader.free;

    v := 0;
    k := 0;
    for r := 0 to FFoundResults.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if FFoundResults[r] is TRegSearchResultValue then
        inc(v);
      if FFoundResults[r] is TRegSearchResultKey then
        inc(k);
    end;

    ConsoleLog(RPad('FoundKeys:', RPAD_VALUE) + IntToStr(v));
    ConsoleLog(RPad('FoundValues:', RPAD_VALUE) + IntToStr(k));

    // Debug('FindKeys', 'FoundKeys: '+ IntToStr(v));
    // Debug('FindKeys', 'FoundKeys: '+ IntToStr(k));
  end;
end;

function TMyRegistry.FindKeyV2(RegEntry: TEntry; EntryReader: TEntryReader; RawReg: TRawRegistry; EntryIdx: integer; SearchKey: TRegSearchKey): integer;
var
  bytesread: integer;
  csi: TControlSetInfo;
  DataInfo: TRegDataInfo;
  FoundKey: TRegSearchResultKey;
  FoundValue: TRegSearchResultValue;
  strKeyName: string;
  SubRawReg: TRawRegistry;
  SubSearchKey: TRegSearchKey;
  v, k: integer;
  ValueList, KeyList: TStringList;
begin
  Result := 0;
  strKeyName := SearchKey.Key;
  if (SearchKey.Hive = hvSYSTEM) and (SearchKey.ControlSet <> csNone) then
  begin
    csi := TControlSetInfo(FControlSets[EntryIdx]);
    case csi.ActiveCS of
      csCurrent:
        strKeyName := '\ControlSet00' + IntToStr(csi.GetActiveCSAsInteger) + SearchKey.Key;
    end;
  end;
  ValueList := TStringList.Create;
  KeyList := TStringList.Create;
  try
    if RawReg.OpenKey(strKeyName) then
    begin
      Debug('FindKeysV2', 'OpenKey success: ' + strKeyName);

      // Process the values under this key first
      if RawReg.GetValueNames(ValueList) then
      begin
        Debug('FindKeysV2', 'GetValueNames success: ValueList.Count = ' + IntToStr(ValueList.Count));
        // Check for a match and add values to our results
        for v := 0 to ValueList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          if (ValueList[v] = SearchKey.Value) or (SearchKey.Value = '*') then
          begin
            Debug('FindKeysV2', 'ValueName match: ' + ValueList[v] + ' = ' + SearchKey.Value);
            // Open the value data and create a new Result as a Value
            if RawReg.GetDataInfo(ValueList[v], DataInfo) then
            begin
              Debug('FindKeysV2', 'FoundValue created: ' + ValueList[v]);
              FoundValue := TRegSearchResultValue.Create;
              FFoundResults.Add(FoundValue);
              Result := Result + 1;

              FoundValue.SearchKey := SearchKey;
              FoundValue.Entry := RegEntry;
              FoundValue.KeyPath := strKeyName;
              FoundValue.Name := ValueList[v];
              FoundValue.DataType := DataInfo.RegData;
              FoundValue.DataSize := DataInfo.DataSize;
              FoundValue.Data := nil;
              FoundValue.EntryIdx := EntryIdx;
              GetMem(FoundValue.Data, FoundValue.DataSize);
              FillChar(FoundValue.Data^, FoundValue.DataSize, 0);
              bytesread := RawReg.ReadRawData(ValueList[v], FoundValue.Data^, FoundValue.DataSize);
              Debug('FindKeysV2', 'FoundValue bytesread: ' + IntToStr(bytesread));
            end;
          end;
        end;
      end
      else
      begin
        Debug('FindKeysV2', 'GetValueNames failed');
      end;

      // Process the keys under this key and any child keys if need be
      if RawReg.GetKeyNames(KeyList) then
      begin
        Debug('FindKeysV2', 'GetKeyNames success: KeyList.Count = ' + IntToStr(KeyList.Count));
        SubRawReg := TRawRegistry.Create(EntryReader, False);
        try
          for k := 0 to KeyList.Count - 1 do
          begin
            FoundKey := TRegSearchResultKey.Create;
            FFoundResults.Add(FoundKey);
            FoundKey.SearchKey := SearchKey;
            FoundKey.Entry := RegEntry;
            FoundKey.KeyPath := strKeyName;
            FoundKey.KeyName := KeyList[k];
            if SubRawReg.OpenKey(FoundKey.FullPath) then
              FoundKey.KeyLastModified := SubRawReg.GetCurrentKeyDateTime; // Get the date/time of this key
            FoundKey.EntryIdx := EntryIdx;
            // Process sub keys if child keys are included
            if SearchKey.IncludeChildKeys then
            begin
              SubSearchKey := TRegSearchKey.Create;
              try
                SubSearchKey.Hive := SearchKey.Hive;
                SubSearchKey.ControlSet := csNone;
                SubSearchKey.DataType := SearchKey.DataType;
                SubSearchKey.Key := strKeyName + '\' + FoundKey.KeyName;
                SubSearchKey.IncludeChildKeys := True;
                SubSearchKey.Value := '*'; // Alternative - Match to the value
                SubSearchKey.BookMarkFolder := SearchKey.BookMarkFolder;
                Debug('FindKeysV2', 'Finding Sub Keys: ' + strKeyName + '\' + FoundKey.KeyName);
                // Recurse through sub keys
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
    end
    else
    begin
      Debug('FindKeys', 'OpenKey failed: ' + strKeyName);
    end;
  finally
    Result := FFoundResults.Count;
    ValueList.free;
    KeyList.free;
  end;
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

function InUSBList(AUSBList: TObjectList; AUSBDevice: TUSBDevice): boolean;
var
  z: integer;
  USBUnique: TUSBDevice;
begin
  Result := False;
  for z := 0 to AUSBList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    USBUnique := TUSBDevice(AUSBList[z]);
    if (USBUnique.Device = AUSBDevice.Device) and (USBUnique.DeviceClassID = AUSBDevice.DeviceClassID) and (USBUnique.DeviceType = AUSBDevice.DeviceType) and (USBUnique.VendorName = AUSBDevice.VendorName) and
      (USBUnique.ProductName = AUSBDevice.ProductName) and (USBUnique.Revision = AUSBDevice.Revision) and (USBUnique.VendorID = AUSBDevice.VendorID) and (USBUnique.ProductID = AUSBDevice.ProductID) and
      (USBUnique.FriendlyName = AUSBDevice.FriendlyName) and (USBUnique.SerialNumber = AUSBDevice.SerialNumber) and (USBUnique.FirstConnectedAfterReboot = AUSBDevice.FirstConnectedAfterReboot) and
      (USBUnique.LastConnectedByMountPoints2 = AUSBDevice.LastConnectedByMountPoints2) and (USBUnique.LastConnectedByVIDPID = AUSBDevice.LastConnectedByVIDPID) and (USBUnique.FirstConnected = AUSBDevice.FirstConnected) and
      (USBUnique.GUID = AUSBDevice.GUID) and (USBUnique.ParentIDPrefix = AUSBDevice.ParentIDPrefix) and (USBUnique.DriveLetter = AUSBDevice.DriveLetter) and (USBUnique.User = AUSBDevice.User) and
      (USBUnique.FirstConnected = AUSBDevice.FirstConnected) and (USBUnique.VolumeSerialNumber = AUSBDevice.VolumeSerialNumber) and (USBUnique.VolumeLabel = AUSBDevice.VolumeLabel) then
    begin
      // A match
      Result := True;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
const
  TSWT = 'The script will terminate.';
var
  CaseName: string;
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  // Check Module Exists
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  try
    // Check that the Module has Entries
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      Progress.Log('There is no current case.' + SPACE + TSWT);
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    // Check that Evidence has been added to the module
    if StartCheckDataStore.Count <= 1 then
    begin
      Progress.Log('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;
    Result := True; // If it makes it this far then StartCheck is True
  finally
    FreeAndNil(StartCheckDataStore);
  end;
end;

// ==============================================================================
// Start of Script
// ==============================================================================
var
  // ControlSets
  csActive: TControlSet;
  DefaultControlSet: TControlSet;
  FailedControlSet: TControlSet;
  LastKnownGoodControlSet: TControlSet;

  // DataStores
  anEntryList: TDataStore;
  BookmarksEntryList: TDataStore;
  EvidenceEntryList: TDataStore;

  // Entries
  EntryReader: TEntryReader;
  dEntry: TEntry;
  Entry: TEntry;

  // Integers
  bytesread: int64;
  i, u, v: integer;
  nid, n: integer;
  regfiles, regcount: integer;
  StartingBookmarkFolder_Count: integer;

  // List
  DeviceList: TList;
  USBDevicesList: TObjectList;
  USBUniqueList: TObjectList;
  MountedDevicesList: TObjectList;
  MountPoints2List: TObjectList;
  VolumeInfoList: TObjectList;
  VidPidList: TObjectList;

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
  CurrentCaseDir: string;
  Device_str: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
  mstr: string;
  Param: string;
  str_RegFiles_Regex: string;

  // StringLists
  Temp_StringList: TStringList;
  Value_StringList2: TStringList;

  // MISC
  NewMountedDevice: TMountedDevice;
  NewMountPoints2: TMountPoints2;
  NewUSBDevice, USBDev: TUSBDevice;
  NewVidPid: TVidPid;
  NewVolumeInfo: TVolumeInfo;
  tempstr: AnsiString;
  yr, mt, dy, hr, mn, sc: dword;

begin
  gBookmarkComment_StringList := nil;
  gConsoleLog_StringList := nil;
  gMemo_StringList := nil;
  ConsoleLog(SCRIPT_NAME + ' started...');
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessage := 'Starting...';

  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := ('Processing complete.');
    Exit;
  end;
  // ----------------------------------------------------------------------------
  // Setup Results Header
  // ----------------------------------------------------------------------------
  gMemo_StringList := TStringList.Create;
  gConsoleLog_StringList := TStringList.Create;

  // ----------------------------------------------------------------------------
  // Device List - Add the evidence items
  // ----------------------------------------------------------------------------
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

  // ----------------------------------------------------------------------------
  // Parameters & Logging
  // ----------------------------------------------------------------------------
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

  // ============================================================================
  // ----------------------------------------------------------------------------
  // Log Running Options
  // ----------------------------------------------------------------------------
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog('Options:');

  // ============================================================================
  // ----------------------------------------------------------------------------
  // Count the existing Bookmarks folders
  // ----------------------------------------------------------------------------
  BookmarksEntryList := GetDataStore(DATASTORE_BOOKMARKS);
  StartingBookmarkFolder_Count := BookmarksEntryList.Count;
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog(RPad('Starting Bookmark folders:', 30) + (IntToStr(BookmarksEntryList.Count)));

  // ----------------------------------------------------------------------------
  // Find the registry files in the File System
  // ----------------------------------------------------------------------------
  Reg := TMyRegistry.Create;
  Reg.RegEntries.Clear; // Clear the searchable list of reg files

  str_RegFiles_Regex := '\\(SOFTWARE|SYSTEM|SAM|NTUSER\.DAT)$';

  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog('The Regex search string is:');
  ConsoleLog('  ' + str_RegFiles_Regex);
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));

  Progress.DisplayMessage := 'Finding registry files...';
  ConsoleLog('Finding registry files...');
  regfiles := 0;
  regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex);

  // ============================================================================
  // ----------------------------------------------------------------------------
  // Exit if no Registry files found
  // ----------------------------------------------------------------------------
  ConsoleLog(IntToStr(regfiles) + ' registry files located:');

  if regfiles = 0 then
  begin
    ConsoleLog('No registry files were located.' + SPACE + TSWT);
    EvidenceEntryList.free;
    gMemo_StringList.free;
    gConsoleLog_StringList.free;
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

  // ----------------------------------------------------------------------------
  // Setup the correct control-set info for each of the SYSTEM hives found
  // ----------------------------------------------------------------------------
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

  // ----------------------------------------------------------------------------
  // Add keys to the search list
  // ----------------------------------------------------------------------------
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet001\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet002\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);

  Reg.AddKey(hvSYSTEM, csNone, dtString, '\MountedDevices', False, '*', 'DOS Devices');
  Reg.AddKey(hvUSER, csNone, dtString, '\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2', True, '*', 'MountPoints2');

  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet001\Enum\USB', True, '*', 'USB PID VID');
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet002\Enum\USB', True, '*', 'USB PID VID');

  Reg.AddKey(hvSOFTWARE, csNone, dtString, '\Microsoft\Windows Portable Devices\Devices', True, '*', 'Win7+ Volume Label');

  // ----------------------------------------------------------------------------
  // Search for Keys
  // ----------------------------------------------------------------------------
  ConsoleLog('Searching for registry keys of interest...');
  regcount := Reg.FindKeys;
  ConsoleLog(HYPHEN + 'Found ' + IntToStr(Reg.FoundCount) + ' keys.');

  MountedDevicesList := TObjectList.Create;
  MountedDevicesList.OwnsObjects := True;
  MountPoints2List := TObjectList.Create;
  MountPoints2List.OwnsObjects := True;
  USBDevicesList := TObjectList.Create;
  USBDevicesList.OwnsObjects := True;
  USBUniqueList := TObjectList.Create;
  USBUniqueList.OwnsObjects := True;
  VidPidList := TObjectList.Create;
  VidPidList.OwnsObjects := True;
  VolumeInfoList := TObjectList.Create;
  VolumeInfoList.OwnsObjects := True;

  // ----------------------------------------------------------------------------
  // Iterate Reg results
  // ----------------------------------------------------------------------------
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess];

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
    // Interrogate Keys found
    if RegResult is TRegSearchResultKey then
    begin
      // Process keys
      Re.MatchPattern := '\\Enum\\Usbstor\\(.+?)&Ven_(.*?)&Prod_(.*?)&Rev_([^\\]*)\\*([^\\]*)(.*)';
      Re.SetSubjectStr(TRegSearchResultKey(RegResult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 7) then
        begin
          if (Re.SubStr(5) <> '') and (Re.SubStr(6) = '') then
          begin
            // Create new USB device
            nid := -1;
            for n := 0 to USBDevicesList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              if (TUSBDevice(USBDevicesList[n]).USBSTORKey = TRegSearchResultKey(RegResult).FullPath) and (TUSBDevice(USBDevicesList[n]).Registry = RegResult.Entry) and (TUSBDevice(USBDevicesList[n]).Device = GetDeviceEntry(RegResult.Entry))
              then
              begin
                nid := n;
                break;
              end;
            end;
            if nid >= 0 then
              NewUSBDevice := TUSBDevice(USBDevicesList[nid])
            else
            begin
              NewUSBDevice := TUSBDevice.Create;
              NewUSBDevice.Registry := RegResult.Entry;
              NewUSBDevice.Device := GetDeviceEntry(RegResult.Entry);
              NewUSBDevice.USBSTORKey := TRegSearchResultKey(RegResult).FullPath;
              NewUSBDevice.Copies := 1;
              USBDevicesList.Add(NewUSBDevice);
            end;

            NewUSBDevice.DeviceType := Re.SubStr(1);
            NewUSBDevice.VendorName := Re.SubStr(2);
            NewUSBDevice.ProductName := Re.SubStr(3);
            NewUSBDevice.Revision := Re.SubStr(4);
            NewUSBDevice.SerialNumber := Re.SubStr(5);
            NewUSBDevice.FirstConnectedAfterReboot := TRegSearchResultKey(RegResult).KeyLastModified;

            EntryReader := TEntryReader.Create;
            if EntryReader.OpenData(RegResult.Entry) then
            begin
              RawRegSubKeys := TRawRegistry.Create(EntryReader, False);
              if RawRegSubKeys.OpenKey(RegResult.FullPath) then
              begin
                // Get the values and extract the ones we want like FriendlyName
                Value_StringList2 := TStringList.Create;
                Value_StringList2.Clear;
                RawRegSubKeys.GetValueNames(Value_StringList2);
                for v := 0 to Value_StringList2.Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  if RawRegSubKeys.GetDataInfo(Value_StringList2[v], DataInfo) then
                  begin
                    if UpperCase(Value_StringList2[v]) = 'FRIENDLYNAME' then
                    begin
                      Value := TRegSearchResultValue.Create;
                      Value.Entry := RegResult.Entry;
                      Value.KeyPath := RegResult.FullPath + '\' + NewUSBDevice.SerialNumber;
                      Value.Name := UpperCase(Value_StringList2[v]);
                      Value.DataType := DataInfo.RegData;
                      Value.DataSize := DataInfo.DataSize;
                      Value.Data := nil;
                      GetMem(Value.Data, Value.DataSize);
                      FillChar(Value.Data^, Value.DataSize, 0);
                      bytesread := RawRegSubKeys.ReadRawData(Value_StringList2[v], Value.Data^, Value.DataSize);
                      NewUSBDevice.FriendlyName := Value.DataAsString(False);
                      Value.free;
                    end;
                  end;
                end;
                Value_StringList2.free;
              end;
              RawRegSubKeys.free;
            end; { entryreader }
            EntryReader.free;
          end;
        end;
      end; // USBSTOR processing

      // Process MountPoints2 keys
      Re.MatchPattern := '\\Users\\([^\\]+).*\\NTUSER\.DAT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MountPoints2\\(\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})$';
      Re.SetSubjectStr(TRegSearchResultKey(RegResult).Entry.FullPathName + TRegSearchResultKey(RegResult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 3) then
        begin
          NewMountPoints2 := TMountPoints2.Create;
          NewMountPoints2.Device := GetDeviceEntry(RegResult.Entry);
          NewMountPoints2.GUID := Re.SubStr(2);
          NewMountPoints2.User := Re.SubStr(1);
          NewMountPoints2.LastConnected := TRegSearchResultKey(RegResult).KeyLastModified;
          MountPoints2List.Add(NewMountPoints2);
        end;
      end; { MountPoints2 Processing }

      // Process VID and PID keys
      Re.MatchPattern := '\\Enum\\USB\\VID_([0-9A-Z]{4})&PID_([0-9A-Z]{4}+)\\+([^\\]+)$';
      Re.SetSubjectStr(TRegSearchResultKey(RegResult).Entry.FullPathName + TRegSearchResultKey(RegResult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 4) then
        begin
          NewVidPid := TVidPid.Create;
          NewVidPid.Device := GetDeviceEntry(RegResult.Entry);
          NewVidPid.VID := Re.SubStr(1);
          NewVidPid.PID := Re.SubStr(2);
          NewVidPid.SerialNumber := Re.SubStr(3);
          NewVidPid.LastConnected := TRegSearchResultKey(RegResult).KeyLastModified;
          VidPidList.Add(NewVidPid);
        end;
      end; { VID and PID processing }

      // Process Volume Labels
      Re.MatchPattern := '\\Microsoft\\Windows Portable Devices\\Devices\\  _([0-9A-Z]{4})&PID_([0-9A-Z]{4}+)\\+([^\\]+)$';
      Re.SetSubjectStr(TRegSearchResultKey(RegResult).Entry.FullPathName + TRegSearchResultKey(RegResult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 4) then
        begin
          NewVidPid := TVidPid.Create;
          NewVidPid.Device := GetDeviceEntry(RegResult.Entry);
          NewVidPid.VID := Re.SubStr(1);
          NewVidPid.PID := Re.SubStr(2);
          NewVidPid.SerialNumber := Re.SubStr(3);
          NewVidPid.LastConnected := TRegSearchResultKey(RegResult).KeyLastModified;
          VidPidList.Add(NewVidPid);
        end;
      end; { VID and PID processing }
    end; { Key Processing }

    // Interrogate VALUES found
    if RegResult is TRegSearchResultValue then
    begin
      RegResultValue := TRegSearchResultValue(RegResult);
      // Process DOSDevice and VolumeInfo values
      // Re.MatchPattern := '^\\DosDevices\\(?<DRIVE>[A-Z]):$|^\\\?\?\\Volume(?<GUID>\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})$'; //^\\DosDevices\\([A-Z]):$';
      // ConsoleLog(RegResultValue.KeyPath + ' --> ' + RegResultValue.Name);
      Re.MatchPattern := '^\\DosDevices\\([A-Z]):$|^\\\?\?\\Volume({[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})$'; // ^\\DosDevices\\([A-Z]):$';
      Re.SetSubjectStr(RegResultValue.Name);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) then // and (Re.SubStrCount = 3) then
        begin
          // Process the value data
          Temp_StringList := TStringList.Create;
          Temp_StringList.Delimiter := '#';
          Temp_StringList.StrictDelimiter := True;
          Temp_StringList.DelimitedText := PWideChar(@RegResultValue.DataAsByteArray(RegResultValue.DataSize)[0]);
          // Found DosDevice
          if (Re.SubStrCount = 2) and (Re.SubStr(1) <> '') then
          begin
            NewMountedDevice := TMountedDevice.Create;
            NewMountedDevice.Device := GetDeviceEntry(RegResult.Entry);
            NewMountedDevice.LastDriveLetter := Re.SubStr(1);
            if Temp_StringList.Count = 4 then
            begin
              NewMountedDevice.DeviceClassID := Temp_StringList[1];
              NewMountedDevice.SerialNumber := Temp_StringList[2];
            end;
            MountedDevicesList.Add(NewMountedDevice);
          end;
          // Found VolumeInfo
          if (Re.SubStrCount = 3) and (Re.SubStr(2) <> '') then
          begin
            Temp_StringList.DelimitedText := PWideChar(@RegResultValue.DataAsByteArray(RegResultValue.DataSize)[0]);
            NewVolumeInfo := TVolumeInfo.Create;
            NewVolumeInfo.Device := GetDeviceEntry(RegResult.Entry);
            NewVolumeInfo.GUID := Re.SubStr(2);
            if Temp_StringList.Count = 4 then
            begin
              NewVolumeInfo.DeviceClassID := Temp_StringList[1];
              NewVolumeInfo.SerialNumber := Temp_StringList[2];
            end;
            VolumeInfoList.Add(NewVolumeInfo);
          end;
          Temp_StringList.free;
        end;
      end; { processing }
    end;
  end; { regkeys found }

  // Process setupapi.dev.log
  ConsoleLog(RPad('Searching for:', RPAD_VALUE) + 'setupapi.dev.log');
  anEntryList := GetDataStore(DATASTORE_FILESYSTEM);
  Entry := anEntryList.First;
  EntryReader := TEntryReader.Create;
  try
    while assigned(Entry) and Progress.isRunning do
    begin
      if RegexMatch(Entry.FullPathName, '\\ROOT\\.{1,25}\\INF\\SETUPAPI\.DEV\.LOG$', False) then
      begin
        ConsoleLog(RPad('Found:', RPAD_VALUE) + Entry.FullPathName);
        if EntryReader.OpenData(Entry) then
        begin
          try
            EntryReader.position := 0;
            setlength(tempstr, EntryReader.Size);
            EntryReader.Read(pointer(tempstr)^, EntryReader.Size);
            Re.MatchPattern := 'Usbstor\\(.+?)&Ven_(.*?)&Prod_(.*?)&Rev_([^\\]*)\\*([^\\]*)][\s].{0,10}Section start ([0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})';
            Re.SetSubjectStr(tempstr);
            if Re.Match(0) > 0 then
            begin
              repeat
                mstr := Re.MatchedStrPtr;
                if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 7) then
                  for u := 0 to USBDevicesList.Count - 1 do
                  begin
                    if not Progress.isRunning then
                      break;
                    if (GetDeviceEntry(Entry) = TUSBDevice(USBDevicesList[u]).Device) and (UpperCase(TUSBDevice(USBDevicesList[u]).SerialNumber) = UpperCase(Re.SubStr(5))) then
                    begin
                      yr := StrToInt(copy(Re.SubStr(6), 1, 4));
                      mt := StrToInt(copy(Re.SubStr(6), 6, 2));
                      dy := StrToInt(copy(Re.SubStr(6), 9, 2));
                      hr := StrToInt(copy(Re.SubStr(6), 12, 2));
                      mn := StrToInt(copy(Re.SubStr(6), 15, 2));
                      sc := StrToInt(copy(Re.SubStr(6), 18, 2));
                      TUSBDevice(USBDevicesList[u]).FirstConnected := EncodeDate(yr, mt, dy) + EncodeTime(hr, mn, sc, 00);
                      break; // Use the first instance for each usb device
                    end;
                  end;
              until Re.MatchNext <= 0;
            end;
          except
            ConsoleLog('Exception: ' + Entry.EntryName);
          end;
        end;
      end;
      Entry := anEntryList.Next;
    end;
  finally
    EntryReader.free;
    anEntryList.free;
  end;
  ConsoleLog('Finished searching for setupapi.dev.log');

  // Join lists together
  // Remove Duplicates and add to unique list
  ConsoleLog(RPad('Processing devices located:', RPAD_VALUE) + IntToStr(USBDevicesList.Count));
  for u := 0 to USBDevicesList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    USBDev := TUSBDevice(USBDevicesList[u]);
    // Mounted devices
    for i := 0 to MountedDevicesList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if (USBDev.Device = TMountedDevice(MountedDevicesList[i]).Device) and (UpperCase(TMountedDevice(MountedDevicesList[i]).SerialNumber) = UpperCase(USBDev.SerialNumber)) then
      begin
        USBDev.DriveLetter := TMountedDevice(MountedDevicesList[i]).LastDriveLetter;
        USBDev.DeviceClassID := TMountedDevice(MountedDevicesList[i]).DeviceClassID;
        break;
      end;
    end;
    // Volume info
    for i := 0 to VolumeInfoList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if (USBDev.Device = TVolumeInfo(VolumeInfoList[i]).Device) and (UpperCase(TVolumeInfo(VolumeInfoList[i]).SerialNumber) = UpperCase(USBDev.SerialNumber)) then
      begin
        USBDev.GUID := TVolumeInfo(VolumeInfoList[i]).GUID;
        break;
      end;
    end;
    // Mount points 2
    for i := 0 to MountPoints2List.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if (USBDev.Device = TMountPoints2(MountPoints2List[i]).Device) and (UpperCase(TMountPoints2(MountPoints2List[i]).GUID) = UpperCase(USBDev.GUID)) then
      begin
        USBDev.User := TMountPoints2(MountPoints2List[i]).User;
        USBDev.LastConnectedByMountPoints2 := TMountPoints2(MountPoints2List[i]).LastConnected;
        break;
      end;
    end;
    // VID PID
    for i := 0 to VidPidList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if (USBDev.Device = TVidPid(VidPidList[i]).Device) and (pos(UpperCase(TVidPid(VidPidList[i]).SerialNumber), UpperCase(USBDev.SerialNumber)) > 0) then
      begin
        USBDev.VendorID := TVidPid(VidPidList[i]).VID;
        USBDev.ProductID := TVidPid(VidPidList[i]).PID;
        USBDev.LastConnectedByVIDPID := TVidPid(VidPidList[i]).LastConnected;
        break;
      end;
    end;

    // If not already in unique list and add
    if not InUSBList(USBUniqueList, USBDev) then
      // inc(USBDev.Copies);
      USBUniqueList.Add(USBDev);

  end;

  ConsoleLog(RPad('Unique USB devices:', RPAD_VALUE) + IntToStr(USBUniqueList.Count));
  gBookmarkComment_StringList := TStringList.Create;
  for u := 0 to USBUniqueList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    gBookmarkComment_StringList.Clear;
    USBDev := TUSBDevice(USBUniqueList[u]);

    // --------------------------------------------------------------------------
    // Create the Results
    // --------------------------------------------------------------------------
    BMF_Key_Group := 'USBStor Devices';
    ConsoleLog(ltMessagesMemo, (StringOfChar('-', CHAR_LENGTH)));
    ConsoleLog(ltMessagesMemo, 'USB Device ' + IntToStr(u + 1) + ':');
    ConsoleLog(ltMessagesMemoBM, RPad('Friendly Name:', RPAD_VALUE) + USBDev.FriendlyName);
    ConsoleLog(ltMessagesMemoBM, RPad('Serial Number:', RPAD_VALUE) + USBDev.SerialNumber);

    if (USBDev.DeviceClassID <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Device Class ID:', RPAD_VALUE) + USBDev.DeviceClassID);
    if (USBDev.DeviceType <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Device Type:', RPAD_VALUE) + USBDev.DeviceType);
    if (USBDev.VendorName <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Vendor Name:', RPAD_VALUE) + USBDev.VendorName);
    if (USBDev.VendorID <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Vendor ID:', RPAD_VALUE) + USBDev.VendorID);
    if (USBDev.ProductName <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Product Name:', RPAD_VALUE) + USBDev.ProductName);
    if (USBDev.ProductID <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Product ID:', RPAD_VALUE) + USBDev.ProductID);
    if (USBDev.Revision <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Revision:', RPAD_VALUE) + USBDev.Revision);

    ConsoleLog(ltMessagesMemoBM, RPad('First Connected (setupapi):', RPAD_VALUE) + MyFormatDateTime(USBDev.FirstConnected, False));
    ConsoleLog(ltMessagesMemoBM, RPad('Connected After Reboot (USBSTOR):', RPAD_VALUE) + MyFormatDateTime(USBDev.FirstConnectedAfterReboot, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Last Connected (MountPoints2):', RPAD_VALUE) + MyFormatDateTime(USBDev.LastConnectedByMountPoints2, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Last Connected (VID_&PID_):', RPAD_VALUE) + MyFormatDateTime(USBDev.LastConnectedByVIDPID, True));

    if (USBDev.GUID <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Device GUID:', RPAD_VALUE) + USBDev.GUID);
    if (USBDev.ParentIDPrefix <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Parent ID Prefix:', RPAD_VALUE) + USBDev.ParentIDPrefix);
    if (USBDev.DriveLetter <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Driver Letter:', RPAD_VALUE) + USBDev.DriveLetter);
    if (USBDev.User <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Last User:', RPAD_VALUE) + USBDev.User);
    if (USBDev.VolumeSerialNumber <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Volume Serial Number:', RPAD_VALUE) + USBDev.VolumeSerialNumber);
    if (USBDev.VolumeLabel <> '') or (SHOW_BLANK_BL) then
      ConsoleLog(ltMessagesMemoBM, RPad('Volume Label:', RPAD_VALUE) + USBDev.VolumeLabel);

    // ConsoleLog(ltMessagesMemoBM,' ');
    ConsoleLog(ltMessagesMemoBM, ('~~~~~~~~~~~~~~~'));
    BM_Source_str := TDataEntry(USBDev.Registry).FullPathName;
    ConsoleLog(ltMessagesMemoBM, ('Source: ' + TDataEntry(USBDev.Registry).FullPathName + USBDev.USBSTORKey));
    BMC_Formatted := gBookmarkComment_StringList.Text;

    // --------------------------------------------------------------------------
    // Bookmark Results
    // --------------------------------------------------------------------------
    Device_str := TDataEntry(USBDev.Device).EntryName;
    Device_str := StringReplace(Device_str, '\', '-', [rfReplaceAll]);
    BM_Source_str := TDataEntry(USBDev.Registry).FullPathName;
    BMF_Key_Name := USBDev.FriendlyName + ' - ' + USBDev.SerialNumber;
    BookMark_Create(Device_str, HIVE_SYSTEM, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

  end;

  ConsoleLog(ltMessagesMemo, (StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog(ltMessagesMemo, #13#10 + 'End of results.');

  Progress.DisplayMessageNow := 'Processing complete';

  // ----------------------------------------------------------------------------
  // Export results to a file
  // ----------------------------------------------------------------------------

  if (CmdLine.params.Indexof('SAVEASTXT') > -1) then
  begin
    CurrentCaseDir := GetCurrentCaseDir;
    ExportedDir := CurrentCaseDir + 'Exported\';
    ExportDate := FormatDateTime('yyyy-mm-dd', now);
    ExportTime := FormatDateTime('hh-nn-ss', now);
    ExportDateTime := (ExportDate + '-' + ExportTime);

    if DirectoryExists(ExportedDir) then
    begin
      if assigned(gConsoleLog_StringList) and (gConsoleLog_StringList.Count > 0) then
      begin
        gConsoleLog_StringList.SaveToFile(ExportedDir + ExportDateTime + ' ' + SCRIPT_NAME + '.txt');
        ConsoleLog('Results exported to: ' + ExportedDir + ExportDateTime + ' ' + SCRIPT_NAME + '.txt');
        Progress.DisplayMessageNow := 'Processing complete. Results saved to file.';
      end;
    end;
  end;

  // Finishing bookmark folder count
  ConsoleLog('Finishing Bookmark folder count: ' + (IntToStr(BookmarksEntryList.Count)) + '. There were: ' + (IntToStr(BookmarksEntryList.Count - StartingBookmarkFolder_Count)) + ' new Bookmark folders added.');

  // Free Memory
  BookmarksEntryList.free;
  DeviceList.free;
  EvidenceEntryList.free;
  MountedDevicesList.free;
  MountPoints2List.free;
  Re.free;
  Reg.free;
  USBDevicesList.free;
  VidPidList.free;
  VolumeInfoList.free;

  ConsoleLog(SCRIPT_NAME + ' ' + 'finished.');
  Progress.DisplayMessageNow := 'Processing complete';

  // Must be freed after the last ConsoleLog
  gBookmarkComment_StringList.free;
  gConsoleLog_StringList.free;
  gMemo_StringList.free;

end.
