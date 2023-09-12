unit Artifact_Utils;

interface

uses
{$IF DEFINED (ISFEXGUI)}
  GUI, Modules,
{$IFEND}
  ByteStream, Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DateUtils, DIRegex,
  Graphics, PropertyList, ProtoBuf, Regex, SQLite3, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BL_PROCEED_LOGGING = False;
  CR = #13#10;
  DCR = #13#10 + #13#10;
  EXPORT_L01_BL = False;
  HYPHEN = ' - ';
  RPAD_VALUE = 65;
  RUNNING = '...';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

function ArrayBytesToVariant(anArray: TBytes): variant;
function BytesToStr(SomeBytes: TBytes): string;
function BytesToString(H: TBytes; offset, len: integer): string;
function CalcTimeTaken(the_tick: uint64): string;
function CleanUnicode(s: string): string;
function ColumnByName(Statement: TSQLite3Statement; const Name: string): integer;
function ColumnValueByNameAsBlobBytes(Statement: TSQLite3Statement; const Name: string): TBytes;
function ColumnValueByNameAsBlobText(Statement: TSQLite3Statement; const Name: string): ansistring;
function ColumnValueByNameAsInt(Statement: TSQLite3Statement; const Name: string): integer;
function ColumnValueByNameAsint64(Statement: TSQLite3Statement; const Name: string): int64;
function ColumnValueByNameAsText(Statement: TSQLite3Statement; const Name: string): string;
function DateCheck_Unix_10(aDate_int64: int64): boolean;
function FileNameRegExSearch(anEntry: TEntry; const aItunes_Domain_str: string; const aItunes_Name_str: string; regex_search_str: string): boolean;
function GetANSIStr(aStream: TStream; maxchar: integer = 255): string;
function GetJOURNALReader(anEntry: TEntry): TEntryReader;
function GetUniqueFileName(const AFileName: string): string;
function GetWALReader(anEntry: TEntry): TEntryReader;
function GHFloatToDateTime(Value: extended; const convert_as: string): TDateTime;
function int64ToDateTime(Value: int64): TDateTime;
function IntToDateTime(Value: int64; const convert_as: string): TDateTime;
function MacAbsoluteTimeToDateTime(Value: int64): TDateTime;
function PerlMatch(const AMatchPattern: string; const AMatchString: string): string;
function RemoveSpecialChars(const str: string): string;
function RPad(const AString: string; AChars: integer): string;
function StartingChecks: boolean;
function StripIllegalChars(AString: string): string;
function StrippedOfNonAscii(const s: string): string;
function UnixTimeToDateTime(Value: int64): TDateTime;
function VariantToArrayBytes(avariant: variant): TBytes;
procedure Add40CharFiles(UniqueList: TUniqueListOfEntries);
procedure ExportToL01(aTList: TList; aname: string);
procedure Find_Entries_By_Path(aDataStore: TDataStore; const astr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);
procedure MakeButtonHeader(program_name: string; script_name: string; icon_24_int: integer; CreateButton_StringList: TStringList);
procedure MessageUser(AString: string);
procedure SignatureAnalysis(SigThis_TList: TList);

implementation

procedure Add40CharFiles(UniqueList: TUniqueListOfEntries);
var
  anEntry: TEntry;
  count_40char_int: integer;
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
          count_40char_int := count_40char_int + 1;
        end;
      end;
      anEntry := FileSystemDS.Next;
    end;
    FreeAndNil(FileSystemDS);
  end;
  Progress.Log('40 char files: ' + inttostr(count_40char_int));
end;

function ArrayBytesToVariant(anArray: TBytes): variant;
var
  iSize, jj: integer;
begin
  iSize := length(anArray);
  if iSize > 0 then
  begin
    Result := VarArrayCreate([0, iSize - 1], varByte);
    for jj := 0 to iSize - 1 do
      VarArrayPut(Result, anArray[jj], [jj]);
  end;
end;

function BytesToStr(SomeBytes: TBytes): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to length(SomeBytes) - 1 do
  begin
    if SomeBytes[i] <> 0 then
      Result := Result + chr(SomeBytes[i])
    else
      break;
  end;
end;

function BytesToString(H: TBytes; offset, len: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := offset to length(H) - 1 do
  begin
    if i >= (len + offset) then
      break;
    Result := Result + char(H[i]);
  end;
end;

function CalcTimeTaken(the_tick: uint64): string;
var
  time_taken_int: uint64;
begin
  Result := '';
  time_taken_int := trunc((GetTickCount - the_tick) / 1000);
  Result := FormatDateTime('hh:mm:ss', time_taken_int / SecsPerDay);
end;

function CleanUnicode(s: string): string;
begin
  Result := '';
  s := StringReplace(s, '&apos;', '''', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '&gt;', '>', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '&laquo;', '«', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '&lt;', '<', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '&raquo;', '»', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '</b>', '', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '<b>', '', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '\u0026#39;', '''', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '\u0027', '''', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '\u003b', ';', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '\u003c', '<', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '\u003d', '=', [rfReplaceAll, rfIgnoreCase]); // noslz
  s := StringReplace(s, '\u003e', '>', [rfReplaceAll, rfIgnoreCase]); // noslz
  Result := s;
end;

function ColumnByName(Statement: TSQLite3Statement; const Name: string): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Statement.ColumnCount do
  begin
    if SameText(Statement.ColumnName(i), Name) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function ColumnValueByNameAsBlobBytes(Statement: TSQLite3Statement; const Name: string): TBytes;
var
  iCol, iSize: integer;
  pSrc: Pointer;
begin
  setlength(Result, 0); // default to zero
  iCol := ColumnByName(Statement, Name);
  if iCol > -1 then
  begin
    iSize := Statement.ColumnBytes(iCol);
    setlength(Result, iSize);
    if iSize <= 0 then
      Exit;
    pSrc := Statement.ColumnBlob(iCol);
    Move(pSrc^, Result[0], iSize);
  end;
end;

function ColumnValueByNameAsBlobText(Statement: TSQLite3Statement; const Name: string): ansistring;
var
  iCol, iSize: integer;
  pSrc: Pointer;
begin
  Result := '';
  iCol := ColumnByName(Statement, Name);
  if iCol > -1 then
  begin
    iSize := Statement.ColumnBytes(iCol);
    setlength(Result, iSize);
    if iSize <= 0 then
      Exit;
    pSrc := Statement.ColumnBlob(iCol);
    Move(pSrc^, Result[1], iSize);
  end;
end;

function ColumnValueByNameAsInt(Statement: TSQLite3Statement; const Name: string): integer;
var
  iCol: integer;
begin
  Result := -1;
  iCol := ColumnByName(Statement, Name);
  if iCol > -1 then
    Result := Statement.ColumnInt(iCol);
end;

function ColumnValueByNameAsint64(Statement: TSQLite3Statement; const Name: string): int64;
var
  iCol: integer;
begin
  Result := -1;
  iCol := ColumnByName(Statement, Name);
  if iCol > -1 then
    Result := Statement.Columnint64(iCol);
end;

function ColumnValueByNameAsText(Statement: TSQLite3Statement; const Name: string): string;
var
  iCol: integer;
begin
  Result := '';
  iCol := ColumnByName(Statement, Name);
  if iCol > -1 then
    Result := Statement.ColumnText(iCol);
end;

function DateCheck_Unix_10(aDate_int64: int64): boolean;
begin
  Result := False;
  if (aDate_int64 > 1250000000) and (aDate_int64 < 1600000000) then
    Result := True;
end;

procedure ExportToL01(aTList: TList; aname: string);
var
  TaskProgress: TPAC;
  bl_Continue: boolean;
  tick_export_l01: uint64;
begin
  if not Progress.isRunning then
    Exit;
  if EXPORT_L01_BL then
  begin
    Progress.Log(RPad('Launching ExportToL01:', RPAD_VALUE) + inttostr(aTList.Count) + ' files' + RUNNING);
    if not assigned(aTList) then
      Exit;
    tick_export_l01 := GetTickCount64;
    if assigned(aTList) and (aTList.Count > 0) then
    begin
      if Progress.isRunning then
      begin
        TaskProgress := NewProgress(True);
        RunTask('TCommandTask_ExportFilesL01', DATASTORE_FILESYSTEM, aTList, TaskProgress, ['filename=' + GetExportedDir + aname + '.L01']); // noslz
        while (TaskProgress.isRunning) and (Progress.isRunning) do
          Sleep(500); // Do not proceed until TCommandTask_FileTypeAnalysis is complete
        if not(Progress.isRunning) then
          TaskProgress.Cancel;
        bl_Continue := (TaskProgress.CompleteState = pcsSuccess);
      end;
    end;
  end;
end;

function FileNameRegExSearch(anEntry: TEntry; const aItunes_Domain_str: string; const aItunes_Name_str: string; regex_search_str: string): boolean;
begin
  Result := False;
  if RegexMatch(anEntry.EntryName, regex_search_str, False) then
  begin
    if BL_PROCEED_LOGGING then
    begin
      Progress.Log(RPad(HYPHEN + 'Proceed' + HYPHEN + 'Identified by anEntry.EntryName:', RPAD_VALUE) + anEntry.EntryName + SPACE + 'Bates:' + inttostr(anEntry.ID));
      Progress.Log(regex_search_str);
    end;
    Result := True;
    Exit;
  end;
  if RegexMatch(anEntry.FullPathName, regex_search_str, False) then
  begin
    if BL_PROCEED_LOGGING then
      Progress.Log(RPad(HYPHEN + 'Proceed' + HYPHEN + 'Identified by anEntry.FullPathName:', RPAD_VALUE) + anEntry.EntryName + SPACE + 'Bates:' + inttostr(anEntry.ID));
    Result := True;
    Exit;
  end;
  if (RegexMatch(aItunes_Domain_str, regex_search_str, False) and RegexMatch(aItunes_Name_str, regex_search_str, False)) then
  begin
    if BL_PROCEED_LOGGING then
      Progress.Log(RPad(HYPHEN + 'Proceed' + HYPHEN + 'Identified by iTunes Domain and Name:', RPAD_VALUE) + aItunes_Domain_str + '\' + aItunes_Name_str + SPACE + 'Bates:' + inttostr(anEntry.ID));
    Result := True;
    Exit;
  end;
  if (aItunes_Domain_str <> '') and (aItunes_Name_str <> '') then
  begin
    if (RegexMatch(aItunes_Domain_str, regex_search_str, False) and RegexMatch(aItunes_Name_str, regex_search_str, False)) then
    begin
      if BL_PROCEED_LOGGING then
        Progress.Log(RPad(HYPHEN + 'Proceed' + HYPHEN + 'Identified by iTunes Domain/Name:', RPAD_VALUE) + aItunes_Domain_str + '\' + aItunes_Name_str + SPACE + 'Bates:' + inttostr(anEntry.ID));
      Result := True;
      Exit;
    end;
  end;
end;

procedure Find_Entries_By_Path(aDataStore: TDataStore; const astr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);
var
  s: integer;
  fEntry: TEntry;
begin
  if assigned(aDataStore) and (aDataStore.Count > 1) then
  begin
    FoundList.Clear;
    aDataStore.FindEntriesByPath(nil, astr, FoundList);
    for s := 0 to FoundList.Count - 1 do
      try
        if not Progress.isRunning then
          break;
        fEntry := TEntry(FoundList[s]);
        AllFoundListUnique.Add(fEntry);
      except
        Progress.Log(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + 'Find_Entries_By_Path');
      end;
    Progress.Log(RPad(HYPHEN + 'FilesByPath:' + SPACE + astr, RPAD_VALUE) + format('%-6s %-20s', [inttostr(FoundList.Count), '(' + inttostr(AllFoundListUnique.Count) + ')']));
  end;
end;

function GHFloatToDateTime(Value: extended; const convert_as: string): TDateTime;
var
  TempLargeInt: int64;
  TempDateTime: TDateTime;
begin
  if convert_as = 'UNIX' then
    Result := UnixTimeToDateTime(trunc(Value))
  else if convert_as = 'UNIX_MS' then
    Result := UnixTimeToDateTime(trunc(Value / 1000))
  else if convert_as = 'UNIX_MicroS' then
    Result := UnixTimeToDateTime(trunc(Value / 1000000))
  else if convert_as = 'ABS' then
    Result := MacAbsoluteTimeToDateTime(trunc(Value))
  else if convert_as = 'DTChrome' then
  begin
    TempDateTime := EncodeDateTime(1601, 1, 1, 0, 0, 0, 1);
    TempLargeInt := (trunc(Value) div 1000);
    Result := IncMillisecond(TempDateTime, TempLargeInt);
  end
  else
    Result := VarToDateTime(trunc(Value));
end;

function GetANSIStr(aStream: TStream; maxchar: integer = 255): string;
var
  i: integer;
  aByte: byte;
  done: boolean;
begin
  Result := '';
  done := False;
  i := 0;
  while not done do
  begin
    inc(i);
    done := (aStream.read(aByte, 1) <> 1) or (aByte <= 9) or (i > maxchar);
    if not done then
      Result := Result + chr(aByte);
  end;
end;

function GetJOURNALReader(anEntry: TEntry): TEntryReader;
var
  tempEntry: TEntry;
  FileSystemDS: TDataStore;
  testname: string;
begin
  Result := nil;
  FileSystemDS := GetDataStore(DATASTORE_FILESYSTEM);
  testname := anEntry.EntryName + '-journal';
  tempEntry := FileSystemDS.First(TEntry(anEntry.Parent));
  while assigned(tempEntry) and Progress.isRunning do
  begin
    if (anEntry.Parent = tempEntry.Parent) and (tempEntry.EntryName = testname) then
    begin
      Result := TEntryReader.Create;
      Result.Opendata(tempEntry);
      break;
    end;
    tempEntry := FileSystemDS.Next;
  end;
  FreeAndNil(FileSystemDS);
end;

function GetUniqueFileName(const AFileName: string): string;
var
  fext, fname, fpath: string;
  fnum: integer;
begin
  Result := AFileName;
  if FileExists(AFileName) then
  begin
    fext := ExtractFileExt(AFileName);
    fnum := 1;
    fname := ExtractFileName(AFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(AFileName);
    while FileExists(fpath + fname + '_' + inttostr(fnum) + fext) do
      fnum := fnum + 1;
    Result := fpath + fname + '_' + inttostr(fnum) + fext;
  end;
end;

function GetWALReader(anEntry: TEntry): TEntryReader;
var
  tempEntry: TEntry;
  FileSystemDS: TDataStore;
  testname1: string;
  testname2: string;
  testname3: string;
begin
  Result := nil;
  FileSystemDS := GetDataStore(DATASTORE_FILESYSTEM);
  testname1 := anEntry.EntryName + '-wal';
  testname2 := anEntry.EntryName + '-wal000644';
  testname3 := anEntry.EntryName + 'db-wal';
  tempEntry := FileSystemDS.First(TEntry(anEntry.Parent)); // The actual SQLite file
  while assigned(tempEntry) and Progress.isRunning do
  begin
    if (anEntry.Parent = tempEntry.Parent) and ((trim(tempEntry.EntryName) = trim(testname1)) or (trim(tempEntry.EntryName) = trim(testname2)) or (trim(tempEntry.EntryName) = trim(testname3))) then
    begin
      Result := TEntryReader.Create;
      Result.Opendata(tempEntry);
      break;
    end;
    tempEntry := FileSystemDS.Next;
  end;
  FreeAndNil(FileSystemDS);
end;

function IntToDateTime(Value: int64; const convert_as: string): TDateTime;
var
  TempLargeInt: int64;
  TempDateTime: TDateTime;
  tmp_str: string;
begin
  if convert_as = 'UNIX' then
  begin
    if length(Value) = 19 then // Force fix for IMO
    begin
      tmp_str := inttostr(Value);
      setlength(tmp_str, 10);
      tmp_str := trim(tmp_str);
      Value := StrToInt(tmp_str);
    end;
    Result := UnixTimeToDateTime(Value)
  end
  else if convert_as = 'UNIX_MS' then
    Result := UnixTimeToDateTime(Value div 1000)
  else if convert_as = 'UNIX_MicroS' then
    Result := UnixTimeToDateTime(Value div 1000000)
  else if convert_as = 'ABS' then
    Result := MacAbsoluteTimeToDateTime(Value)
  else if convert_as = 'DTChrome' then
  begin
    TempDateTime := EncodeDateTime(1601, 1, 1, 0, 0, 0, 1);
    TempLargeInt := (Value div 1000);
    Result := IncMillisecond(TempDateTime, TempLargeInt);
  end
  else
    Result := VarToDateTime(Value);
end;

function int64ToDateTime(Value: int64): TDateTime;
var
  TempLargeInt: int64;
  TempDateTime: TDateTime;
begin
  Result := 0.0;
  if Value > 0 then
  begin
    try
      TempDateTime := EncodeDateTime(1601, 1, 1, 0, 0, 0, 1);
      TempLargeInt := (Value div 1000);
      Result := IncMillisecond(TempDateTime, TempLargeInt);
    except
      Progress.Log(ATRY_EXCEPT_STR);
    end;
  end;
end;

function MacAbsoluteTimeToDateTime(Value: int64): TDateTime;
begin
  if Value = 0 then
  begin
    Result := 0;
    Exit;
  end;
  if length(Value) = 18 then
    Result := ((Value / 1000000000 + 978307200.0) / 86400.0) + 25569.0 // RFC822: Standard for ARPA Internet Text Messages
  else if length(Value) = 9 then
    Result := ((Value + 978307200.0) / 86400.0) + 25569.0 // RFC822: Standard for ARPA Internet Text Messages
  else
    Result := 0;
end;

procedure MakeButtonHeader(program_name: string; script_name: string; icon_24_int: integer; CreateButton_StringList: TStringList);
var
  unit_name_str: string;
begin
  icon_24_int := 103;
  unit_name_str := StringReplace(program_name, ' ', '_', [rfReplaceAll]);
  CreateButton_StringList.Add('unit Button_Artifacts_' + unit_name_str + ';');
  CreateButton_StringList.Add('');
  CreateButton_StringList.Add('interface');
  CreateButton_StringList.Add('');
  CreateButton_StringList.Add('uses');
  CreateButton_StringList.Add('  Modules, GUI, SysUtils;');
  CreateButton_StringList.Add('');
  CreateButton_StringList.Add('procedure OnStartup(Module : TGDModule);');
  CreateButton_StringList.Add('');
  CreateButton_StringList.Add('implementation');
  CreateButton_StringList.Add('');
  CreateButton_StringList.Add('procedure OnStartup(Module : TGDModule);');
  CreateButton_StringList.Add('const');
  CreateButton_StringList.Add('  HYPHEN = '' - '';');
  CreateButton_StringList.Add('  SPACE = '' '';');
  CreateButton_StringList.Add('var');
  CreateButton_StringList.Add('  ToolBar: TGDToolBar;');
  CreateButton_StringList.Add('  Button: TGDToolBarButton;');
  CreateButton_StringList.Add('');
  CreateButton_StringList.Add('begin');
  CreateButton_StringList.Add('  ToolBar := Module.FindToolbar(''Artifacts'');');
  CreateButton_StringList.Add('  if Toolbar = nil then');
  CreateButton_StringList.Add('    ToolBar := Module.AddToolbar(''Artifacts'');');
  CreateButton_StringList.Add('  Button := ToolBar.AddButton(''' + program_name + ''' + #10#13 + '''', '''', '''', ' + inttostr(icon_24_int) + ', 74, 64, BTNS_SHOWCAPTION or BTNS_DROPDOWN);');
  CreateButton_StringList.Add('  Button.AddDropMenu(''' + program_name + ' - Process ALL'', GetScriptsDir + ''Artifacts\' + script_name + ''', ''PROCESSALL'', 1050, BTNS_SHOWCAPTION);');
  CreateButton_StringList.Add('  Button.AddDropMenu(''-'', '''', '''', -1, BTNS_SHOWCAPTION or BTNS_DROPDOWN); //Blank line in menu');
end;

procedure MessageUser(AString: string);
begin
{$IF DEFINED (ISFEXGUI)}
  MessageBox(AString, '', (MB_OK or MB_ICONINFORMATION or MB_SETFOREGROUND or MB_TOPMOST));
{$IFEND}
  Progress.Log(AString);
end;

function PerlMatch(const AMatchPattern: string; const AMatchString: string): string;
var
  Re: TDIPerlRegEx;
begin
  Result := '';
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess, coUnGreedy];
  Re.SetSubjectStr(AMatchString);
  Re.MatchPattern := AMatchPattern;
  if Re.Match(0) >= 0 then
    Result := Re.matchedstr;
  FreeAndNil(Re);
end;

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

function RemoveSpecialChars(const str: string): string;
const
  InvalidChars: set of char = [',', '.', '/', '!', '@', '#', '$', '%', '^', '&', '*', '''', '"', ';', '_', '(', ')', ':', { '|', } '[', ']'];
var
  i, Count: integer;
begin
  setlength(Result, length(str));
  Count := 0;
  for i := 1 to length(str) do
  begin
    if not(str[i] in InvalidChars) then
    begin
      inc(Count);
      Result[Count] := str[i];
    end;
  end;
  setlength(Result, Count);
end;

procedure SignatureAnalysis(SigThis_TList: TList);
var
  TaskProgress: TPAC;
  signature_tick_count: uint64;
  gbl_Continue: boolean;
begin
  if not Progress.isRunning then
    Exit;
  signature_tick_count := GetTickCount64;
  if not assigned(SigThis_TList) then
  begin
    Progress.Log(RPad('Not assigned Signature TList.', 65) + 'Signature Analysis not run.');
    Exit;
  end;
  if assigned(SigThis_TList) and (SigThis_TList.Count > 0) then
  begin
    if Progress.isRunning then
    begin
      TaskProgress := NewProgress(False);
      RunTask('TCommandTask_FileTypeAnalysis', DATASTORE_FILESYSTEM, SigThis_TList, TaskProgress);
      while (TaskProgress.isRunning) and (Progress.isRunning) do
        Sleep(500); // Do not proceed until TCommandTask_FileTypeAnalysis is complete
      if not(Progress.isRunning) then
        TaskProgress.Cancel;
      gbl_Continue := (TaskProgress.CompleteState = pcsSuccess);
    end;
  end;
end;

function StartingChecks: boolean;
var
  CaseName: string;
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
begin
  Result := False;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  try
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      MessageUser('There is no current case.' + SPACE + TSWT);
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      MessageUser('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;
    Result := True; // If this point is reached StartCheck is True
  finally
    FreeAndNil(StartCheckDataStore);
  end;
end;

function StripIllegalChars(AString: string): string;
var
  x: integer;
begin
  for x := 1 to length(AString) do
    if not((AString[x] >= #32) and (AString[x] <= #127)) or (AString[x] in [#10, #13]) then
      AString[x] := '_';
  Result := AString;
end;

function StrippedOfNonAscii(const s: string): string;
var
  i, Count: integer;
begin
  setlength(Result, length(s));
  Count := 0;
  for i := 1 to length(s) do
  begin
    if ((s[i] >= #32) and (s[i] <= #127)) or (s[i] in [#10, #13]) then
    begin
      inc(Count);
      Result[Count] := s[i];
    end;
  end;
  setlength(Result, Count);
end;

function UnixTimeToDateTime(Value: int64): TDateTime;
begin
  if Value = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := EncodeDate(1970, 1, 1) + (Value div 86400);
  Result := Result + ((Value mod 86400) / 86400);
end;

function VariantToArrayBytes(avariant: variant): TBytes;
var
  iSize, jj: integer;
begin
  setlength(Result, 0);
  if VarIsNull(avariant) or VarIsEmpty(avariant) or not VarIsArray(avariant) then
    Exit;
  iSize := VarArrayHighBound(avariant, 1);
  if iSize > 0 then
  begin
    setlength(Result, iSize);
    for jj := 0 to iSize - 1 do
    begin
      if not Progress.isRunning then
        break;
      Result[jj] := VarArrayGet(avariant, [jj]);
    end;
  end;
end;

end.
