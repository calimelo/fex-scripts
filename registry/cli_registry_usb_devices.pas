﻿{!NAME:      CLI Registry Triage - USB Devices}
{!DESC:      Triage USB Device information from the registry}
{!AUTHOR:    GetData}
{!REFERENCE: Reference: Carvey, Harlan A. "Windows Registry Forensics", Syngress 2011'}

unit cli_registry_triage_usb_devices;

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
  // PARAMETERS
  PARAM_InList                  = 'InList';       //noslz
  // OTHER
  PARSE_KEY                     = '\SYSTEM\ControlSet001\Enum\USBSTOR'; //noslz
  FILESIG_REGISTRY              = 'Registry';                           //noslz
  RS_CURRENT                    = 'Current';                            //noslz
  RS_DEFAULT                    = 'Default';                            //noslz
  RS_FAILED                     = 'Failed';                             //noslz
  RS_LAST_KNOWN_GOOD            = 'LastKnownGood';                      //noslz
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  CHAR_LENGTH                 = 90;
  COLON                       = ': ';
  COMMA                       = ',';
  HYPHEN                      = ' - ';
  rpad_value                  = 30;
  SCRIPT_NAME                 = 'Triage' + HYPHEN + 'USB Devices';
  SHOW_BLANK_BL               = False;
  SPACE                       = ' ';
  TSWT                        = 'The script will terminate.';
 
  BMF_USBSTOR_DEVICES         = 'USBStor Devices';  
  BMF_MY_BOOKMARKS            = 'My Bookmarks';
  BMF_TRIAGE                  = 'FEX-Triage';
  BMF_REGISTRY                = 'Registry';

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

  TUSBDevice = class
    Registry: TEntry;
    Device: TEntry;
    USBSTORKey: string;
    DeviceClassID: string; // e.g. Disk&Ven_Generic&Prod_USB_xD/SM_Reader&Rev_1.02
    DeviceType: string;
    VendorName: string;
    ProductName: string;
    Revision: string;
    VendorID: string;
    ProductID: string;
    FriendlyName: string;
    SerialNumber: string;
    FirstConnectedAfterReboot: TDateTime;
    LastConnectedByMountPoints2: TDateTime;
    LastConnectedByVIDPID: TDateTime;
    FirstConnected: TDateTime; // Local time from setupapi.dev.log file
    GUID: string;
    ParentIDPrefix: string;
    DriveLetter: string;
    User: string;
    VolumeSerialNumber: string;
    VolumeLabel: string;
    Copies: integer;
  end;

  TMountedDevice = class
    Device: TEntry;
    DeviceClassID: string; // e.g. Disk&Ven_Generic&Prod_USB_xD/SM_Reader&Rev_1.02
    SerialNumber: string;
    LastDriveLetter: string;
  end;

  TVolumeInfo = class
    Device: TEntry;
    DeviceClassID: string;
    SerialNumber: string;
    GUID: string;
  end;

  TMountPoints2 = class
    Device: TEntry;
    User: string;
    GUID: string;
    LastConnected: TDateTime;
  end;

  TVidPid = class
    Device: TEntry;
    VID: string;
    PID: string;
    SerialNumber: string;
    LastConnected: TDateTime;
  end;

  TRegSearchKey = class
    Hive: TRegHiveType;
    ControlSet: TControlSet;
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
    function FindKey(RegEntry : TEntry; EntryReader : TEntryReader; RawReg : TRawRegistry; EntryIdx : integer; SearchKey : TRegSearchKey) : integer;
    function FindKeyV2(RegEntry : TEntry; EntryReader : TEntryReader; RawReg : TRawRegistry; EntryIdx : integer; SearchKey : TRegSearchKey) : integer;

  public
    constructor Create;
    destructor Destroy; override;
    function AddKey(AHive: TRegHiveType; AControlSet: TControlSet; ADataType : TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir : string = ''): integer;
    function FindKeys: integer;
    function FindRegFilesByDataStore(const ADataStore: string; aRegEx: string): integer; // Locate registry files in a datastore
    function FindRegFilesByDevice(ADevice: TEntry; ARegEx: string): integer; // Locate registry files on a device
    function FindRegFilesByInList(const ADataStore: string; ARegEx: string): integer;
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
    property RegEntries : TList read FRegEntries;
  end;

  function RPad(const AString: string; AChars: integer): string;
  function UnixTimeToDateTime(UnixTime: Integer): TDateTime;
  procedure ConsoleLog(AString: string); overload;
  procedure ConsoleLog(ALogType: TLogType; AString: string); overload;
  procedure ConsoleLogMemo(AString: string);
  procedure ConsoleLogBM(AString: string);
  procedure BookMark(ADevice: string; Abmf_Hive_Name: string; Abmf_Key_Group, Abmf_Key_Name, Abm_Source_str, AComment: string; ABookmarkEntry: boolean);
  procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);

var
  Memo_StringList:              TStringList;
  BookmarkComment_StringList:   TStringList;
  ConsoleLog_StringList:        TStringList;
  csv_StringList:               TStringList;

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
    // Need to force bookmark every time because identical devices can have different dates and times - use delete bookmark to stop repeats
    bmNew := NewBookmark(bmParent, Abmf_Key_Name, AComment);
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

// Returns date time as file time string----------------------------------------
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
function TMyRegistry.AddKey(AHive: TRegHiveType; AControlSet: TControlSet; ADataType : TDataType; AKey: string; AIncludeChildKeys: boolean; AValue: string; BMDir : string = ''): integer;
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
  v, k: integer;
  csi: TControlSetInfo;
begin
  Result := 0;
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
        //Debug('FindKeys', 'GetValueNames: '+ strKeyName + ' - ' + IntToStr(Value_StringList.Count));

        if slValues.Count = 0 then
        begin
          ConsoleLog('No values in: ' + strKeyName);
        end
        else
        begin
          //Debug('FindKeys', 'GetValueNames: '+ IntToStr(Value_StringList.Count));
          SubRawReg := TRawRegistry.Create(EntryReader, False);

          try
            for k := 0 to slValues.Count - 1 do
            begin
              if not Progress.isRunning then break;
              FoundKey := TRegSearchresultKey.Create;
              FFoundresults.Add(FoundKey);
              Result := Result + 1;

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
  HiveType : TRegHiveType;
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

            Result := Result + FindKeyV2(RegEntry, EntryReader, RawReg, r, SearchKey);
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

function TMyRegistry.FindKeyV2(RegEntry : TEntry; EntryReader : TEntryReader; RawReg : TRawRegistry; EntryIdx : integer; SearchKey : TRegSearchKey) : integer;
var
  strKeyName : string;
  SubRawReg : TRawRegistry;
  SubSearchKey: TRegSearchKey;
  FoundKey: TRegSearchresultKey;
  FoundValue: TRegSearchresultValue;
  DataInfo: TRegDataInfo;
  bytesread: integer;
  ValueList, KeyList: TStringList;
  v, k: integer;
  csi: TControlSetInfo;
begin
  Result := 0;
  strKeyName := SearchKey.Key;
  if (SearchKey.Hive = hvSYSTEM) and (SearchKey.ControlSet <> csNone) then
  begin
    csi := TControlSetInfo(FControlSets[EntryIdx]);
    case csi.ActiveCS of
       csCurrent:  strKeyName := '\ControlSet00' + IntToStr(csi.GetActiveCSAsInteger) + SearchKey.Key;
    end;
  end;
  ValueList := TStringList.Create;
  KeyList := TStringList.Create;
  try
    if RawReg.OpenKey(strKeyName) then
    begin
      Debug('FindKeysV2', 'OpenKey success: '+ strKeyName);

      //process the values under this key first
      if RawReg.GetValueNames(ValueList) then
      begin
        Debug('FindKeysV2', 'GetValueNames success: ValueList.Vount = '+ IntToStr(ValueList.Count));
        //check for a match and add values to our results
        for v := 0 to ValueList.Count - 1 do
        begin
          if not Progress.isRunning then break;
          if (ValueList[v] = SearchKey.Value) or (SearchKey.Value = '*') then
          begin
            Debug('FindKeysV2', 'ValueName match: ' + ValueList[v] + ' = ' + SearchKey.Value);
            //open the value data and create a new Result as a Value
            if RawReg.GetDataInfo(ValueList[v], DataInfo) then
            begin
              Debug('FindKeysV2', 'FoundValue created: ' + ValueList[v]);
              FoundValue := TRegSearchresultValue.Create;
              FFoundresults.Add(FoundValue);
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
        Debug('FindKeysV2', 'GetKeyNames success: KeyList.Count = '+ IntToStr(KeyList.Count));
        SubRawReg := TRawRegistry.Create(EntryReader, False);
        try
          for k := 0 to KeyList.Count - 1 do
          begin
            FoundKey := TRegSearchresultKey.Create;
            FFoundresults.Add(FoundKey);
            FoundKey.SearchKey := SearchKey;
            FoundKey.Entry := RegEntry;
            FoundKey.KeyPath := strKeyName;
            FoundKey.KeyName := KeyList[k];
            if SubRawReg.OpenKey(FoundKey.FullPath) then
                FoundKey.KeyLastModified := SubRawReg.GetCurrentKeyDateTime;  // Get the date/time of this key
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
                SubSearchKey.Value := '*'; //??? maybe should be a match to the value
                SubSearchKey.BookMarkFolder := SearchKey.BookmarkFolder;
                Debug('FindKeysV2', 'Finding Sub Keys: '+ strKeyName + '\' + FoundKey.KeyName);
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
      Debug('FindKeys', 'OpenKey failed: '+ strKeyName);
    end;
  finally
    Result := FFoundresults.Count;
    ValueList.free;
    KeyList.free;
  end;

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

function InUSBList(AUSBList: TObjectList; AUSBDevice: TUSBDevice): boolean;
  var
    z: integer;
    USBUnique: TUSBDevice;
  begin
    Result := False;
    for z := 0 to AUSBList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      USBUnique := TUSBDevice(AUSBList[z]);
      if (USBUnique.Device = AUSBDevice.Device) and
         (USBUnique.DeviceClassID = AUSBDevice.DeviceClassID) and
         (USBUnique.DeviceType = AUSBDevice.DeviceType) and
         (USBUnique.VendorName = AUSBDevice.VendorName) and
         (USBUnique.ProductName = AUSBDevice.ProductName) and
         (USBUnique.Revision = AUSBDevice.Revision) and
         (USBUnique.VendorID = AUSBDevice.VendorID) and
         (USBUnique.ProductID = AUSBDevice.ProductID) and
         (USBUnique.FriendlyName = AUSBDevice.FriendlyName) and
         (USBUnique.SerialNumber = AUSBDevice.SerialNumber) and
         (USBUnique.FirstConnectedAfterReboot = AUSBDevice.FirstConnectedAfterReboot) and
         (USBUnique.LastConnectedByMountPoints2 = AUSBDevice.LastConnectedByMountPoints2) and
         (USBUnique.LastConnectedByVIDPID = AUSBDevice.LastConnectedByVIDPID) and
         (USBUnique.FirstConnected = AUSBDevice.FirstConnected) and
         (USBUnique.GUID = AUSBDevice.GUID) and
         (USBUnique.ParentIDPrefix = AUSBDevice.ParentIDPrefix) and
         (USBUnique.DriveLetter = AUSBDevice.DriveLetter) and
         (USBUnique.User = AUSBDevice.User) and
         (USBUnique.FirstConnected = AUSBDevice.FirstConnected) and
         (USBUnique.VolumeSerialNumber = AUSBDevice.VolumeSerialNumber) and
         (USBUnique.VolumeLabel = AUSBDevice.VolumeLabel) then
       begin
         // A match
         Result := True;
       end;
     end;
   end;

var
  // Boolean
  bl_UseInList:                 boolean;

  // ControlSets
  csActive:                     TControlSet;
  DefaultControlSet:            TControlSet;
  FailedControlSet:             TControlSet;
  LastKnownGoodControlSet:      TControlSet;

  // DataStores
  anEntryList:                  TDataStore;
  BookmarksEntryList:           TDataStore;
  EvidenceEntryList:            TDataStore;

  // Entries
  EntryReader:                  TEntryReader;
  dEntry:                       TEntry;
  Entry:                        TEntry;

  // Integers
  bytesread:                    int64;
  i,u,v:                        integer;
  nid, n:                       integer;
  regfiles, regcount:           integer;
  StartingBookmarkFolder_Count: integer;

  // List
  DeviceList:                   TList;
  USBDevicesList:               TObjectList;
  USBUniqueList:                TObjectList;
  MountedDevicesList:           TObjectList;
  MountPoints2List:             TObjectList;
  VolumeInfoList:               TObjectList;
  VidPidList:                   TObjectList;

  // Registry
  DataInfo:                     TRegDataInfo;
  RawRegSubKeys:                TRawRegistry;
  Reg:                          TMyRegistry;
  Regresult:                    TRegSearchresult;
  RegresultValue:               TRegSearchresultValue;
  Value:                        TRegSearchresultValue;

  // RegEx
  Re:                           TDIPerlRegEx;

  // Strings
  BM_Source_str:                string;
  BMC_Formatted:                string;
  BMF_Key_Group:                string;
  BMF_Key_Name:                 string;
  CurrentCaseDir:               string;
  Device:                       string;
  ExportDate:                   string;
  ExportDateTime:               string;
  ExportedDir:                  string;
  ExportTime:                   string;
  mstr:                         string;
  Param:                        string;
  str_RegFiles_Regex:           string;

  // Starting Checks
  bContinue:                  boolean;
  CaseName:                   string;
  FEX_Executable:             string;
  FEX_Version:                string;
  StartCheckEntry:            TEntry;
  StartCheckDataStore:        TDataStore;

  // StringLists
  Temp_StringList:              TStringList;
  Value_StringList2:            TStringList;

  // MISC
  NewMountedDevice:             TMountedDevice;
  NewMountPoints2:              TMountPoints2;
  NewUSBDevice,USBDev:          TUSBDevice;
  NewVidPid:                    TVidPid;
  NewVolumeInfo:                TVolumeInfo;
  tempstr:                      ansistring;
  yr,mt,dy,hr,mn,sc:            dword;


//==============================================================================
// Start of Script
//==============================================================================
begin
  BookmarkComment_StringList := nil;
  ConsoleLog_StringList := nil;
  Memo_StringList := nil;
  CSV_StringList := nil;
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
  csv_StringList := TStringList.Create;
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

  bl_UseInList := False;
  if (CmdLine.Params.Indexof(PARAM_InList) <> -1) then
    bl_UseInList := True;

  //============================================================================
  // Log Running Options
  //============================================================================
  ConsoleLog((Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog('Options:');

  bl_AutoBookmark_results := True;
  if bl_AutoBookmark_results then
    ConsoleLog(RPad(HYPHEN + 'Auto Bookmark results:', rpad_value) + 'Yes')
  else ConsoleLog(RPad(HYPHEN + 'Auto Bookmark results:', rpad_value) + 'No');

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
  if bl_UseInList then
    regfiles := Reg.FindRegFilesByInList(DATASTORE_FILESYSTEM, str_RegFiles_Regex)
  else
    regfiles := Reg.FindRegFilesByDataStore(DATASTORE_FILESYSTEM, str_RegFiles_Regex);

  //============================================================================
  // Exit if no Registry files found
  //============================================================================
  ConsoleLog(IntToStr(regfiles) + ' registry files located:');
  if regfiles = 0 then
  begin
    ConsoleLog('No registry files were located. The script will terminate.');

    EvidenceEntryList.free;
    Memo_StringList.free;
    CSV_StringList.free;
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

  //=========================================================================================
  // Add keys to the search list
  //=========================================================================================
 // Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet000\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet001\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet002\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);
 // Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet003\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);
 // Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet004\Enum\USBSTOR', True, '*', BMF_USBSTOR_DEVICES);
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\MountedDevices', False, '*', 'DOS Devices');
  Reg.AddKey(hvUSER,   csNone, dtString, '\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2', True, '*', 'MountPoints2');
 // Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet000\Enum\USB', True, '*', 'USB PID VID');
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet001\Enum\USB', True, '*', 'USB PID VID');
  Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet002\Enum\USB', True, '*', 'USB PID VID');
 // Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet003\Enum\USB', True, '*', 'USB PID VID');
 // Reg.AddKey(hvSYSTEM, csNone, dtString, '\ControlSet004\Enum\USB', True, '*', 'USB PID VID');
  Reg.AddKey(hvSOFTWARE, csNone, dtString, '\Microsoft\Windows Portable Devices\Devices', True, '*', 'Win7+ Volume Label');

  //============================================================================
  // Search for Keys
  //============================================================================
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
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

  //============================================================================
  // Iterate Reg results
  // ===========================================================================
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess];
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
    if Regresult is TRegSearchresultKey then
    begin
      // Process keys
      Re.MatchPattern := '\\Enum\\Usbstor\\(.+?)&Ven_(.*?)&Prod_(.*?)&Rev_([^\\]*)\\*([^\\]*)(.*)';
      Re.SetSubjectStr(TRegSearchresultKey(Regresult).FullPath);
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
              if not Progress.isRunning then break;
              if (TUSBDevice(USBDevicesList[n]).USBSTORKey = TRegSearchresultKey(Regresult).FullPath) and
                 (TUSBDevice(USBDevicesList[n]).Registry = Regresult.Entry) and
                 (TUSBDevice(USBDevicesList[n]).Device = GetDeviceEntry(Regresult.Entry)) then
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
              NewUSBDevice.Registry := Regresult.Entry;
              NewUSBDevice.Device := GetDeviceEntry(Regresult.Entry);
              NewUSBDevice.USBSTORKey := TRegSearchresultKey(Regresult).FullPath;
              NewUSBDevice.Copies := 1;
              USBDevicesList.Add(NewUSBDevice);
            end;

            NewUSBDevice.DeviceType := Re.SubStr(1);
            NewUSBDevice.VendorName := Re.SubStr(2);
            NewUSBDevice.ProductName := Re.SubStr(3);
            NewUSBDevice.Revision := Re.SubStr(4);
            NewUSBDevice.SerialNumber := Re.SubStr(5);
            NewUSBDevice.FirstConnectedAfterReboot := TRegSearchresultKey(Regresult).KeyLastModified;

            EntryReader:= TEntryReader.Create;
            if EntryReader.OpenData(Regresult.Entry) then
            begin
              RawRegSubKeys := TRawRegistry.Create(EntryReader, False);
              if RawRegSubKeys.OpenKey(Regresult.FullPath) then
              begin
                // Get the values and extract the ones we want like FriendlyName
                Value_StringList2 := TStringList.Create;
                Value_StringList2.Clear;
                RawRegSubKeys.GetValueNames(Value_StringList2);
                for v := 0 to Value_StringList2.Count - 1 do
                begin
                  if not Progress.isRunning then break;
                  if RawRegSubKeys.GetDataInfo(Value_StringList2[v], DataInfo) then
                  begin
                    if UpperCase(Value_StringList2[v]) = 'FRIENDLYNAME' then
                    begin
                      Value := TRegSearchresultValue.Create;
                      Value.Entry := Regresult.Entry;
                      Value.KeyPath := Regresult.FullPath + '\' + NewUSBDevice.SerialNumber;
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
            end;{entryreader}
            EntryReader.free;
          end;
        end;
      end; //USBSTOR processing

      // Process MountPoints2 keys
      Re.MatchPattern := '\\Users\\([^\\]+).*\\NTUSER\.DAT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MountPoints2\\(\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})$';
      Re.SetSubjectStr(TRegSearchresultKey(Regresult).Entry.FullPathName + TRegSearchresultKey(Regresult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 3) then
        begin
          NewMountPoints2 := TMountPoints2.Create;
          NewMountPoints2.Device := GetDeviceEntry(Regresult.Entry);
          NewMountPoints2.GUID := Re.SubStr(2);
          NewMountPoints2.User := Re.SubStr(1);
          NewMountPoints2.LastConnected := TRegSearchresultKey(Regresult).KeyLastModified;
          MountPoints2List.Add(NewMountPoints2);
        end;
      end;{MountPoints2 Processing}

      // Process VID and PID keys
      Re.MatchPattern := '\\Enum\\USB\\VID_([0-9A-Z]{4})&PID_([0-9A-Z]{4}+)\\+([^\\]+)$';
      Re.SetSubjectStr(TRegSearchresultKey(Regresult).Entry.FullPathName + TRegSearchresultKey(Regresult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 4) then
        begin
          NewVidPid := TVidPid.Create;
          NewVidPid.Device := GetDeviceEntry(Regresult.Entry);
          NewVidPid.VID := Re.SubStr(1);
          NewVidPid.PID := Re.SubStr(2);
          NewVidPid.SerialNumber := Re.SubStr(3);
          NewVidPid.LastConnected := TRegSearchresultKey(Regresult).KeyLastModified;
          VidPidList.Add(NewVidPid);
        end;
      end;{VID and PID processing}

      // Process Volume Labels
      Re.MatchPattern := '\\Microsoft\\Windows Portable Devices\\Devices\\  _([0-9A-Z]{4})&PID_([0-9A-Z]{4}+)\\+([^\\]+)$';
      Re.SetSubjectStr(TRegSearchresultKey(Regresult).Entry.FullPathName + TRegSearchresultKey(Regresult).FullPath);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 4) then
        begin
          NewVidPid := TVidPid.Create;
          NewVidPid.Device := GetDeviceEntry(Regresult.Entry);
          NewVidPid.VID := Re.SubStr(1);
          NewVidPid.PID := Re.SubStr(2);
          NewVidPid.SerialNumber := Re.SubStr(3);
          NewVidPid.LastConnected := TRegSearchresultKey(Regresult).KeyLastModified;
          VidPidList.Add(NewVidPid);
        end;
      end;{VID and PID processing}
    end;{Key Processing}

    // Interogate VALUES found
    if Regresult is TRegSearchresultValue then
    begin
      RegresultValue := TRegSearchresultValue(Regresult);
      // Process DOSDevice and VolumeInfo values
      //Re.MatchPattern := '^\\DosDevices\\(?<DRIVE>[A-Z]):$|^\\\?\?\\Volume(?<GUID>\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})$'; //^\\DosDevices\\([A-Z]):$';
      //ConsoleLog(RegresultValue.KeyPath + ' --> ' + RegresultValue.Name);
      Re.MatchPattern := '^\\DosDevices\\([A-Z]):$|^\\\?\?\\Volume({[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\})$'; //^\\DosDevices\\([A-Z]):$';
      Re.SetSubjectStr(RegresultValue.Name);
      if Re.Match(0) >= 0 then
      begin
        mstr := Re.MatchedStrPtr;
        if (mstr <> '') and (Re.MatchedStrLength > 0) then // and (Re.SubStrCount = 3) then
        begin
          // Process the value data
          Temp_StringList := TStringList.Create;
          Temp_StringList.Delimiter := '#';
          Temp_StringList.StrictDelimiter := True;
          Temp_StringList.DelimitedText := PWideChar(@RegresultValue.DataAsByteArray(RegresultValue.DataSize)[0]);
          // Found DosDevice
          if (Re.SubStrCount = 2) and (Re.Substr(1) <> '') then
          begin
            NewMountedDevice := TMountedDevice.Create;
            NewMountedDevice.Device := GetDeviceEntry(Regresult.Entry);
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
            Temp_StringList.DelimitedText := PWideChar(@RegresultValue.DataAsByteArray(RegresultValue.DataSize)[0]);
            NewVolumeInfo := TVolumeInfo.Create;
            NewVolumeInfo.Device := GetDeviceEntry(Regresult.Entry);
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
      end;{processing}
    end;
  end;{regkeys found}

  // Process setupapi.dev.log
  ConsoleLog('Searching for: setupapi.dev.log');
  anEntryList := GetDataStore(DATASTORE_FILESYSTEM);
  Entry := anEntryList.First;
  EntryReader:= TEntryReader.Create;
  try
    while assigned(Entry) and Progress.isRunning do
    begin
      if RegexMatch(Entry.FullPathName, '\\ROOT\\.{1,25}\\INF\\SETUPAPI\.DEV\.LOG$', False) then
      begin
        ConsoleLog('found ' + Entry.FullPathName);
        if EntryReader.OpenData(Entry) then
        begin
          try
            EntryReader.position := 0;
            SetLength(tempstr, EntryReader.Size);
            EntryReader.Read(Pointer(tempstr)^, EntryReader.Size);
            Re.MatchPattern := 'Usbstor\\(.+?)&Ven_(.*?)&Prod_(.*?)&Rev_([^\\]*)\\*([^\\]*)][\s].{0,10}Section start ([0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})';
            Re.SetSubjectStr(tempstr);
            if Re.Match(0) > 0 then
            begin
              repeat
                mstr := Re.MatchedStrPtr;
                if (mstr <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 7) then
                  for u := 0 to USBDevicesList.Count - 1 do
                  begin
                    if not Progress.isRunning then break;
                    if (GetDeviceEntry(Entry) = TUSBDevice(USBDevicesList[u]).Device) and
                       (UpperCase(TUSBDevice(USBDevicesList[u]).SerialNumber) = UpperCase(Re.SubStr(5))) then
                    begin
                      yr := StrToInt(copy(Re.SubStr(6), 1, 4));
                      mt := StrToInt(copy(Re.SubStr(6), 6, 2));
                      dy := StrToInt(copy(Re.SubStr(6), 9, 2));
                      hr := StrToInt(copy(Re.SubStr(6), 12, 2));
                      mn := StrToInt(copy(Re.SubStr(6), 15, 2));
                      sc := StrToInt(copy(Re.SubStr(6), 18, 2));
                      TUSBDevice(USBdevicesList[u]).FirstConnected := EncodeDate(yr, mt, dy) + EncodeTime(hr, mn, sc, 00);
                      break;  // Use the first instance for each usb device
                    end;
                  end;
              until Re.MatchNext <= 0;
            end;
          except
            ConsoleLog('Error processing ' + Entry.EntryName);
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
  ConsoleLog('Processing ' + IntToStr(USBDevicesList.Count) + ' devices located.');
  for u := 0 to USBDevicesList.Count - 1 do
  begin
    if not Progress.isRunning then break;
    USBDev := TUSBDevice(USBDevicesList[u]);
    // Mounted devices
    for i := 0 to MountedDevicesList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      if (USBDev.Device = TMountedDevice(MountedDevicesList[i]).Device) and
         (UpperCase(TMountedDevice(MountedDevicesList[i]).SerialNumber) = UpperCase(USBDev.SerialNumber)) then
      begin
        USBDev.DriveLetter := TMountedDevice(MountedDevicesList[i]).LastDriveLetter;
        USBDev.DeviceClassID := TMountedDevice(MountedDevicesList[i]).DeviceClassID;
        break;
      end;
    end;
    // Volume info
    for i := 0 to VolumeInfoList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      if (USBDev.Device = TVolumeInfo(VolumeInfoList[i]).Device) and
         (UpperCase(TVolumeInfo(VolumeInfoList[i]).SerialNumber) = UpperCase(USBDev.SerialNumber)) then
      begin
        USBDev.GUID := TVolumeInfo(VolumeInfoList[i]).GUID;
        break;
      end;
    end;
    // Mount points 2
    for i := 0 to MountPoints2List.Count - 1 do
    begin
      if not Progress.isRunning then break;
      if (USBDev.Device = TMountPoints2(MountPoints2List[i]).Device) and
         (UpperCase(TMountPoints2(MountPoints2List[i]).GUID) = UpperCase(USBDev.GUID)) then
      begin
        USBDev.User := TMountPoints2(MountPoints2List[i]).User;
        USBDev.LastConnectedByMountPoints2 := TMountPoints2(MountPoints2List[i]).LastConnected;
        break;
      end;
    end;
    // VID PID
    for i := 0 to VidPidList.Count - 1 do
    begin
      if not Progress.isRunning then break;
      if (USBDev.Device = TVidPid(VidPidList[i]).Device) and
         (pos(UpperCase(TVidPid(VidPidList[i]).SerialNumber), UpperCase(USBDev.SerialNumber)) > 0) then
      begin
        USBDev.VendorID := TVidPid(VidPidList[i]).VID;
        USBDev.ProductID := TVidPid(VidPidList[i]).PID;
        USBDev.LastConnectedByVIDPID := TVidPid(VidPidList[i]).LastConnected;
        break;
      end;
    end;

    // If not already in unique list and add
    if not InUSBList(USBUniqueList, USBDev) then
      //Inc(USBDev.Copies);
      USBUniqueList.Add(USBDev);

  end;

  csv_StringList.add(
  '1Record' + COMMA +
  '2Device Class ID' + COMMA +
  '3Serial Number' + COMMA +
  '4Friendly Name' + COMMA +
  '5Associated User Accounts' + COMMA +
  '6Last Assigned Drive Letter' + COMMA +
  '7Last Connected Date/Time' + COMMA +
  '8First Connected Date/Time' + COMMA +
  '9First Connect Since Reboot Date/Time' + COMMA +
  '10Install Date/Time' + COMMA +
  '11First Install Date/Time' + COMMA +
  '12Last Insertion Date/Time' + COMMA +
  '13Last Removal Date/Time' + COMMA +
  '14Class' + COMMA +
  '15Device Description' + COMMA +
  '16Manufacturer' + COMMA +
  '17Volume GUID' + COMMA +
  '18VSN Decimal' + COMMA +
  '19VSN HEX' + COMMA +
  '20Source' + COMMA +
  '21Located At');

  ConsoleLog('Unique USB devices: ' + IntToStr(USBUniqueList.Count));
  BookmarkComment_StringList := TStringList.Create;
  for u := 0 to USBUniqueList.Count - 1 do
  begin
    if not Progress.isRunning then break;
    BookmarkComment_StringList.Clear;
    USBDev := TUSBDevice(USBUniqueList[u]);

    //============================================================================
    // Create the results
    //============================================================================
    BMF_Key_Group := 'USBStor Devices';
    ConsoleLog(ltMessagesMemo,(Stringofchar('-', CHAR_LENGTH)));
    ConsoleLog(ltMessagesMemo, 'USB Device ' + IntToStr(u + 1) + ':');
    ConsoleLog(ltMessagesMemoBM, RPad('Friendly Name:',rpad_value) + USBDev.FriendlyName);
    ConsoleLog(ltMessagesMemoBM, RPad('Serial Number:',rpad_value) + USBDev.SerialNumber);

    if (USBDev.DeviceClassID      <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Device Class ID:',rpad_value) + USBDev.DeviceClassID);
    if (USBDev.DeviceType         <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Device Type:',rpad_value) + USBDev.DeviceType);
    if (USBDev.VendorName         <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Vendor Name:',rpad_value) + USBDev.VendorName);
    if (USBDev.VendorID           <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Vendor ID:',rpad_value) + USBDev.VendorID);
    if (USBDev.ProductName        <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Product Name:',rpad_value) + USBDev.ProductName);
    if (USBDev.ProductID          <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Product ID:',rpad_value) + USBDev.ProductID);
    if (USBDev.Revision           <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Revision:',rpad_value) + USBDev.Revision);

    ConsoleLog(ltMessagesMemoBM, RPad('First Connected (setupapi):',rpad_value) + MyFormatDateTime(USBDev.FirstConnected, False));
    ConsoleLog(ltMessagesMemoBM, RPad('Connected After Reboot (USBSTOR):',rpad_value) + MyFormatDateTime(USBDev.FirstConnectedAfterReboot, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Last Connected (MountPoints2):',rpad_value) + MyFormatDateTime(USBDev.LastConnectedByMountPoints2, True));
    ConsoleLog(ltMessagesMemoBM, RPad('Last Connected (VID_&PID_):',rpad_value) + MyFormatDateTime(USBDev.LastConnectedByVIDPID, True));

    if (USBDev.GUID               <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Device GUID:',rpad_value) + USBDev.GUID);
    if (USBDev.ParentIDPrefix     <> '') or (show_blank_bl) then ConsoleLog(ltmessagesMemoBM, RPad('Parent ID Prefix:',rpad_value) + USBDev.ParentIDPrefix);
    if (USBDev.DriveLetter        <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Driver Letter:',rpad_value) + USBDev.DriveLetter);
    if (USBDev.User               <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Last User:',rpad_value) + USBDev.User);
    if (USBDev.VolumeSerialNumber <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Volume Serial Number:',rpad_value) + USBDev.VolumeSerialNumber);
    if (USBDev.VolumeLabel        <> '') or (show_blank_bl) then ConsoleLog(ltMessagesMemoBM, RPad('Volume Label:',rpad_value) + USBDev.VolumeLabel);

    //Log to CSV
    csv_StringList.add(
    {01 - Record} IntToStr(u + 1) + COMMA +
    {02 - Device Class ID} USBDev.DeviceClassID + COMMA +
    {03 - Serial Number} USBDev.SerialNumber + COMMA +
    {04 - Friendly Name} USBDev.FriendlyName + COMMA +
    {05 - Associated User Accounts} USBDev.User + COMMA +
    {06 - Last Assigned Drive Letter}USBDev.DriveLetter + COMMA +
    {07 - Last Connected Date/Time - (UTC+0:00) (yyyy-MM-dd)} MyFormatDateTime(USBDev.LastConnectedByMountPoints2, True) + COMMA +
    {08 - First Connected Date/Time - Local Time (yyyy-mm-dd)} MyFormatDateTime(USBDev.FirstConnected, False) + COMMA +
    {09 - First Connect Since Reboot Date/Time - (UTC+0:00) (yyyy-MM-dd)}MyFormatDateTime(USBDev.FirstConnectedAfterReboot, True) + COMMA +
    {10 - Install Date/Time - (UTC+0:00) (yyyy-MM-dd)} 'Install Date/Time' + COMMA +
    {11 - First Install Date/Time - (UTC+0:00) (yyyy-MM-dd)} 'First Install Date/Time' + COMMA +
    {12 - Last Insertion Date/Time - (UTC+0:00) (yyyy-MM-dd)} 'Last Insertion Date/Time' + COMMA +
    {13 - Last Removal Date/Time - (UTC+0:00) (yyyy-MM-dd)} 'Last Removal Date/Time' + COMMA +
    {14 - Class} 'Class' + COMMA +
    {15 - Device Description} USBDev.DeviceType + COMMA +
    {16 - Manufacturer} USBDev.VendorName + COMMA +
    {17 - Volume GUID}'Volume GUID' + COMMA +
    {18 - VSN Decimal} 'VSN Decimal' + COMMA +
    {19 - VSN Hex} 'VSN HEX' + COMMA +
    {20 - Source} USBDev.USBSTORKey + COMMA +
    {21 - Location} TDataEntry(USBDev.Registry).FullPathName);

    //ConsoleLog(ltMessagesMemoBM,' ');
    ConsoleLog(ltMessagesMemoBM,('~~~~~~~~~~~~~~~'));
    BM_Source_str := TDataEntry(USBDev.Registry).FullPathName;
    ConsoleLog(ltmessagesMemoBM,('Source: ' + TDataEntry(USBDev.Registry).FullPathName + USBDev.USBSTORKey));
    BMC_Formatted := BookmarkComment_StringList.Text;

    //==========================================================================
    // Bookmark results
    //==========================================================================
    Device := TDataEntry(USBDev.Device).EntryName;
    BM_Source_str := TDataEntry(USBDev.Registry).FullPathName;
    BMF_Key_Name := USBDev.FriendlyName+' - '+ USBDev.SerialNumber;
    BookMark(Device, SYSTEM_HIVE, BMF_Key_Group, BMF_Key_Name, BM_Source_str, BMC_Formatted, True);

  end;

  ConsoleLog(ltMessagesMemo, (Stringofchar('-', CHAR_LENGTH)));
  ConsoleLog(ltMessagesMemo, #13#10+'End of results.');

  Progress.DisplayMessageNow := 'Processing complete';   
  
  //============================================================================
  // Export results to a file
  //============================================================================

  if (CmdLine.Params.Indexof('SAVEASTXT') > -1) then
  begin
    CurrentCaseDir := GetCurrentCaseDir;
    ExportedDir := CurrentCaseDir + 'Exported\';
    ExportDate := formatdatetime('yyyy-mm-dd', now);
    ExportTime := formatdatetime('hh-nn-ss', now);
    ExportDateTime := (ExportDate + '-' + ExportTime);

    if DirectoryExists(ExportedDir) then
    begin
      if assigned(ConsoleLog_StringList) and (ConsoleLog_StringList.Count > 0) then
      begin
        ConsoleLog_StringList.SaveToFile(ExportedDir + ExportDateTime + ' ' + SCRIPT_NAME + '.txt');
        ConsoleLog('results exported to: ' +  ExportedDir  + ExportDateTime + ' ' + SCRIPT_NAME + '.txt');
        Progress.DisplayMessageNow := 'Processing complete. results saved to file.'; 
      end;
    end;
  end;

  //============================================================================
  // Export results to a file
  //============================================================================
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Exported\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + '-' + ExportTime);
  if DirectoryExists(ExportedDir) then
  begin
    if assigned(CSV_StringList) and (CSV_StringList.Count > 0) then
    begin
      CSV_StringList.SaveToFile(ExportedDir + ExportDateTime + ' ' + SCRIPT_NAME + '.csv');
      Progress.Log('results exported to: ' +  ExportedDir  + ExportDateTime + ' ' + SCRIPT_NAME + '.csv');
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
  VolumeinfoList.free;

  ConsoleLog(SCRIPT_NAME  + ' ' + 'finished.');

  Progress.Log(CSV_StringList.text);
  
  // Must be freed after the last ConsoleLog
  BookmarkComment_StringList.free;
  ConsoleLog_StringList.free;
  Memo_StringList.free;
  csv_StringList.free;
  Progress.DisplayMessageNow := 'Processing complete';
end.
