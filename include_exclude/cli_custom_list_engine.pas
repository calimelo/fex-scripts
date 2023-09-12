unit Custom_List;

interface

uses
  // GUI,
  Classes, Clipbrd, Common, Container, DataEntry, DataStorage, DateUtils, Graphics,
  Regex, SysUtils;

const
  BS = '\';
  CHAR_LENGTH = 80;
  COLON = ':';
  COLUMN_NAME = 'Custom List';
  CR = #13#10;
  DCR = #13#10 + #13#10;
  DSP = '  ';
  HYPHEN = ' - ';
  LB = '(';
  LOG_LISTS_BL = True;
  PAD = '  ';
  PIPE = '|';
  RB = ')';
  RPAD_VALUE = 35;
  RUNNING = '...';
  SCRIPT_NAME = 'Custom List';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gcolCustomList: TDataStoreField;
  gCaseName: string;
  gchbColSF02: boolean;
  gcol_str: string;
  gExc_Ext_StringList: TStringList;
  gExc_Fnm_StringList: TStringList;
  gInc_Ext_StringList: TStringList;
  gInc_Pth_StringList: TStringList;
  gInc_Sig_StringList: TStringList;
  gResults_StringList: TStringList;
  gScriptFullPath_str: string;
  gStarting_Summary_str: string;
  gtick_start: uint64;

  gImport_StringList: TStringList;
  gInputFileName_str: string;
  gInputFileName_fullpath_str: string;
  gflag_include: TEntryFlag;
  gflag_exclude: TEntryFlag;

function CalcTimeTaken(starting_tick_count: uint64; Description_str: string): string;
function GetInvestigatorName: string;
function GetSizeStr(asize: int64): string;
function RPad(AString: string; AChars: integer): string;
procedure ConsoleLog(aStr: string);
procedure ExportResultsToFile(aSringList: TStringList);
procedure Find_Entries_By_Path(aDataStore: TDataStore; aStr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

// ------------------------------------------------------------------------------
// Open the log file (this is set in the TXML)
// ------------------------------------------------------------------------------
procedure OpenLog();
begin
  if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
  begin
    Progress.Log(RPad('OPENLOG:', RPAD_VALUE) + 'True');
    ShellExecute(0, nil, 'explorer.exe', Pchar(Progress.LogFilename), nil, 1);
  end;
end;

// ------------------------------------------------------------------------------
// Set Flag Color
// ------------------------------------------------------------------------------
function LogFlagColor(aFlag: TEntryFlag): string;
begin
  Result := '';
  if aFlag = Flag1 then
    Result := 'Red'
  else if aFlag = Flag2 then
    Result := 'Blue'
  else if aFlag = Flag3 then
    Result := 'Gold'
  else if aFlag = Flag4 then
    Result := 'Orange'
  else if aFlag = Flag5 then
    Result := 'Green'
  else if aFlag = Flag6 then
    Result := 'Pink'
  else if aFlag = Flag7 then
    Result := 'Aqua'
  else if aFlag = Flag8 then
    Result := 'Brown'
  else
    Result := 'No flag color set';
end;

// ------------------------------------------------------------------------------
// Load from settings file
// ------------------------------------------------------------------------------
procedure LoadFromFile(input_fiile_str: string);
var
  i: integer;

begin
  gImport_StringList.Clear;

  if FileExists(input_fiile_str) then
  begin
    gImport_StringList.LoadFromFile(input_fiile_str);
    Progress.Log(RPad('Found Settings File (' + IntToStr(gImport_StringList.Count) + '):', RPAD_VALUE) + input_fiile_str);
    ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  end
  else
  begin
    Progress.Log(RPad('Settings File not found:', RPAD_VALUE) + input_fiile_str);
    ConsoleLog(Stringofchar('-', CHAR_LENGTH));
    Exit;
  end;

  Progress.Log(RPad(RPad('Loaded:', RPAD_VALUE) + input_fiile_str, RPAD_VALUE) + SPACE + LB + IntToStr(gImport_StringList.Count) + RB);

  if (assigned(gImport_StringList) and (gImport_StringList.Count > 0)) then
  begin
    for i := 0 to gImport_StringList.Count - 1 do
    begin
      if (Length(gImport_StringList[i]) >= 1) and (gImport_StringList[i][1] = '#') then
        Continue;
      if POS('!', gImport_StringList[i]) > 0 then
        Continue;
      // ---
      if RegexMatch(gImport_StringList[i], 'INC_EXT:', True) then
        gInc_Ext_StringList.Add(StringReplace(gImport_StringList[i], 'INC_EXT:', '', [rfReplaceAll]));
      if RegexMatch(gImport_StringList[i], 'INC_PTH:', True) then
        gInc_Pth_StringList.Add(StringReplace(gImport_StringList[i], 'INC_PTH:', '', [rfReplaceAll]));
      if RegexMatch(gImport_StringList[i], 'INC_SIG:', True) then
        gInc_Sig_StringList.Add(StringReplace(gImport_StringList[i], 'INC_SIG:', '', [rfReplaceAll]));
      // ---
      if RegexMatch(gImport_StringList[i], 'EXC_EXT:', True) then
        gExc_Ext_StringList.Add(StringReplace(gImport_StringList[i], 'EXC_EXT:', '', [rfReplaceAll]));
      if RegexMatch(gImport_StringList[i], 'EXC_FNM:', True) then
        gExc_Fnm_StringList.Add(StringReplace(gImport_StringList[i], 'EXC_FNM:', '', [rfReplaceAll]));
      // ---
      if RegexMatch(gImport_StringList[i], 'FLG_INC:', True) then
      begin
        if RegexMatch(gImport_StringList[i], 'red', False) then
          gflag_include := Flag1
        else if RegexMatch(gImport_StringList[i], 'blue', False) then
          gflag_include := Flag2
        else if RegexMatch(gImport_StringList[i], 'gold', False) then
          gflag_include := Flag3
        else if RegexMatch(gImport_StringList[i], 'orange', False) then
          gflag_include := Flag4
        else if RegexMatch(gImport_StringList[i], 'green', False) then
          gflag_include := Flag5
        else if RegexMatch(gImport_StringList[i], 'pink', False) then
          gflag_include := Flag6
        else if RegexMatch(gImport_StringList[i], 'aqua', False) then
          gflag_include := Flag7
        else if RegexMatch(gImport_StringList[i], 'brown', False) then
          gflag_include := Flag8;
      end;
      // ---
      if RegexMatch(gImport_StringList[i], 'FLG_EXC:', True) then
      begin
        if RegexMatch(gImport_StringList[i], 'red', False) then
          gflag_exclude := Flag1
        else if RegexMatch(gImport_StringList[i], 'blue', False) then
          gflag_exclude := Flag2
        else if RegexMatch(gImport_StringList[i], 'gold', False) then
          gflag_exclude := Flag3
        else if RegexMatch(gImport_StringList[i], 'orange', False) then
          gflag_exclude := Flag4
        else if RegexMatch(gImport_StringList[i], 'green', False) then
          gflag_exclude := Flag5
        else if RegexMatch(gImport_StringList[i], 'pink', False) then
          gflag_exclude := Flag6
        else if RegexMatch(gImport_StringList[i], 'aqua', False) then
          gflag_exclude := Flag7
        else if RegexMatch(gImport_StringList[i], 'brown', False) then
          gflag_exclude := Flag8;
      end;
    end;
  end;

  // Log the results of the Load From File
  ConsoleLog(RPad(DSP + 'Include Flag:', RPAD_VALUE) + LogFlagColor(gflag_include));
  ConsoleLog(RPad(DSP + 'Include Extensions:', RPAD_VALUE) + IntToStr(gInc_Ext_StringList.Count));
  ConsoleLog(RPad(DSP + 'Include Path:', RPAD_VALUE) + IntToStr(gInc_Pth_StringList.Count));
  ConsoleLog(RPad(DSP + 'Include Signature:', RPAD_VALUE) + IntToStr(gInc_Sig_StringList.Count));
  ConsoleLog(DSP + Stringofchar('-', 40));
  ConsoleLog(RPad(DSP + 'Exclude Flag:', RPAD_VALUE) + LogFlagColor(gflag_exclude));
  ConsoleLog(RPad(DSP + 'Exclude Extensions:', RPAD_VALUE) + IntToStr(gExc_Ext_StringList.Count));
  ConsoleLog(RPad(DSP + 'Exclude Filename:', RPAD_VALUE) + IntToStr(gExc_Fnm_StringList.Count));
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
end;

// ------------------------------------------------------------------------------
// Function: Get Investigator Name
// ------------------------------------------------------------------------------
function GetInvestigatorName: string;
var
  DataStore_Inv: TDataStore;
  anEntry: TEntry;
begin
  Result := '';
  DataStore_Inv := GetDataStore('LocalInvestigator'); // noslz
  if assigned(DataStore_Inv) then
    try
      if DataStore_Inv.Count = 0 then
        Exit;
      anEntry := DataStore_Inv.First;
      Result := anEntry.EntryName;
    finally
      DataStore_Inv.free;
    end;
end;

// ------------------------------------------------------------------------------
// ConsoleLog - Prints to Messages and Results windows
// ------------------------------------------------------------------------------
procedure ConsoleLog(aStr: string);
begin
  Progress.Log(aStr);
  if assigned(gResults_StringList) then
  begin
    if trim(aStr) <> '' then
      gResults_StringList.Add(aStr);
  end;
end;

// ------------------------------------------------------------------------------
// Function: Calculate Time Taken from Tick Count
// ------------------------------------------------------------------------------
function CalcTimeTaken(starting_tick_count: uint64; Description_str: string): string;
var
  time_taken_int: uint64;
begin
  Result := '';
  if trim(Description_str) <> '' then
    Description_str := Description_str + SPACE;
  time_taken_int := (GetTickCount - starting_tick_count);
  time_taken_int := trunc(time_taken_int / 1000);
  Result := Description_str + 'Time Taken:' + SPACE + FormatDateTime('hh:nn:ss', time_taken_int / SecsPerDay);
end;

// ------------------------------------------------------------------------------
// Function: Right Pad
// ------------------------------------------------------------------------------
function RPad(AString: string; AChars: integer): string;
begin
  if AChars > Length(AString) then
    Result := AString + Stringofchar(' ', AChars - Length(AString))
  else
    Result := AString;
end;

// ------------------------------------------------------------------------------
// Function: Get Size String
// ------------------------------------------------------------------------------
function GetSizeStr(asize: int64): string;
begin
  if asize >= 1073741824 then
    Result := (Format('%1.2n GB', [asize / (1024 * 1024 * 1024)]))
  else if (asize < 1073741824) and (asize > 1048576) then
    Result := (Format('%1.2n MB', [asize / (1024 * 1024)]))
  else if asize < 1048576 then
    Result := (Format('%1.0n KB', [asize / (1024)]));
end;

// ------------------------------------------------------------------------------
// Procedure: Export Results to a File
// ------------------------------------------------------------------------------
procedure ExportResultsToFile(aSringList: TStringList);
var
  CurrentCaseDir: string;
  Export_Filename: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
begin

  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Exported\';
  ExportDate := FormatDateTime('yyyy-mm-dd', now);
  ExportTime := FormatDateTime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + ' - ' + ExportTime);
  if DirectoryExists(ExportedDir) then
  begin
    if assigned(aSringList) and (aSringList.Count > 0) then
    begin
      Export_Filename := ExportedDir + ExportDateTime + ' - ' + SCRIPT_NAME + '.txt';
      aSringList.SaveToFile(Export_Filename);
      Sleep(500);
      if FileExists(Export_Filename) then
        ConsoleLog(RPad('Exported Result Log:', RPAD_VALUE) + Export_Filename)
      else
        ConsoleLog(RPad('Export Folder not found:', RPAD_VALUE) + ExportedDir);
    end;
  end
  else
    Progress.Log(RPad('Export folder not found:', RPAD_VALUE) + ExportedDir);
end;

// ------------------------------------------------------------------------------
// Function: Test Valid Regex
// ------------------------------------------------------------------------------
function IsValidRegEx(aStr: string): boolean;
var
  aRegEx: TRegEx;
begin
  Result := False;
  aRegEx := TRegEx.Create;
  try
    aRegEx.SearchTerm := aStr;
    Result := aRegEx.LastError = 0;
  finally
    aRegEx.free;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Find individual invalid Regex Strings
// ------------------------------------------------------------------------------
function FindInvalidRegexString(aname_str: string; aStringList: TStringList): boolean;
var
  bad_regex_str: string;
  i: integer;
begin
  Result := False;
  if assigned(aStringList) then
  begin
    bad_regex_str := '';
    for i := 0 to aStringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      if not IsValidRegEx(aStringList[i]) then
      begin
        if bad_regex_str = '' then
          bad_regex_str := aStringList[i]
        else
          bad_regex_str := bad_regex_str + CR + aStringList[i];
      end;
    end;
    Progress.Log(RPad('ERROR: Invalid regex:', RPAD_VALUE) + aname_str);
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Main Proc
// ------------------------------------------------------------------------------
procedure MainProc;
var
  AllFoundListUnique: TUniqueListOfEntries;
  anEntry: TEntry;
  by_sig_count: integer;
  col_list_count: integer;
  DataStore_FS: TDataStore;
  Enum: TEntryEnumerator;
  exc_ext_regex_str: string;
  exc_fnm_regex_str: string;
  FileSignature: TFileTypeInformation;
  FindEntries_StringList: TStringList;
  flag_red_count: integer;
  flag_blue_count: integer;
  flag_gold_count: integer;
  flag_orange_count: integer;
  flag_green_count: integer;
  flag_pink_count: integer;
  flag_aqua_count: integer;
  flag_brown_count: integer;
  FoundList, AllFound_TList: TList;
  i: integer;
  logical_sum_int64: int64;
  registry_count: integer;
  remove_ext_count: integer;
  remove_fnm_count: integer;
  inc_sig_regex_str: string;
  Working_TList: TList;

  // Create OneBig Include Signature Regex
  function CreateRegexStr(aStringList: TStringList): string;
  begin
    Result := '';
    if assigned(aStringList) and (aStringList.Count > 0) then
    begin
      for i := 0 to aStringList.Count - 1 do
      begin
        if i <> aStringList.Count - 1 then
          Result := Result + aStringList[i] + '|'
        else
          Result := Result + aStringList[i];
      end;
      if not IsValidRegEx(Result) then
      begin
        ConsoleLog(RPad('WARNING: Regex is Invalid:', RPAD_VALUE) + SPACE + Result);
        FindInvalidRegexString('Filenames', aStringList);
      end;
    end;
  end;

begin
  Progress.DisplayMessageNow := 'Processing' + RUNNING;
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore_FS = nil then
  begin
    Progress.Log('Not assigned a data store.' + SPACE + TSWT);
    Exit;
  end;

  try
    anEntry := DataStore_FS.First;
    if not assigned(anEntry) then
    begin
      Progress.Log('No entries in the data store.' + SPACE + TSWT);
      Exit;
    end;

    Working_TList := TList.Create;
    AllFound_TList := TList.Create;
    AllFoundListUnique := TUniqueListOfEntries.Create;
    try
      // Columns ----------------------------------------------------------------
      gcolCustomList := AddMetaDataField(COLUMN_NAME, ftString);
      if assigned(gcolCustomList) then
      begin
        ConsoleLog(RPad('Column added:', RPAD_VALUE) + COLUMN_NAME);
        ConsoleLog(RPad('Column text:', RPAD_VALUE) + gcol_str);
      end
      else
        ConsoleLog(RPad('Column NOT added:', RPAD_VALUE) + COLUMN_NAME);
      ConsoleLog(Stringofchar('-', CHAR_LENGTH));

      // ------------------------------------------------------------------------
      // Create Working TList
      // ------------------------------------------------------------------------
      Working_TList := DataStore_FS.GetEntireList;
      if assigned(Working_TList) then
        Progress.Log(RPad('Processing All Files:', RPAD_VALUE) + IntToStr(Working_TList.Count))
      else
      begin
        Progress.Log(RPad('Error:', RPAD_VALUE) + 'Could not create Working_TList.');
        Exit;
      end;

      // ------------------------------------------------------------------------
      // Find Files by Path
      // ------------------------------------------------------------------------
      FoundList := TList.Create;
      FindEntries_StringList := TStringList.Create;
      try

        // Extensions
        if assigned(gInc_Ext_StringList) and (gInc_Ext_StringList.Count > 0) then
        begin
          for i := 0 to gInc_Ext_StringList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            FindEntries_StringList.Add('**\*' + gInc_Ext_StringList[i]);
          end;
        end;

        // Path
        if assigned(gInc_Pth_StringList) and (gInc_Pth_StringList.Count > 0) then
        begin
          for i := 0 to gInc_Pth_StringList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            FindEntries_StringList.Add(gInc_Pth_StringList[i]);
          end;
        end;

        // Find the files by path and add to AllFoundListUnique
        if assigned(FindEntries_StringList) and (FindEntries_StringList.Count > 0) then
        begin
          ConsoleLog(RPad('Find By Path:', RPAD_VALUE) + IntToStr(FindEntries_StringList.Count));
          ConsoleLog(Format('%-10s %10s %12s %-70s', [DSP + '#', 'Found', ' ', 'Search Path']));
          ConsoleLog(Format('%-10s %10s %12s %-70s', [DSP + '-', '-----', ' ', '-----------']));
          Progress.Initialize(FindEntries_StringList.Count, 'Find files by path' + RUNNING);
          for i := 0 to FindEntries_StringList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            Progress.DisplayMessages := 'Find files by path' + SPACE + LB + IntToStr(i) + ' of ' + IntToStr(FindEntries_StringList.Count) + RB + RUNNING;
            if not Progress.isRunning then
              break;
            Find_Entries_By_Path(DataStore_FS, FindEntries_StringList[i], FoundList, AllFoundListUnique);

            ConsoleLog(Format('%-10s %10s %12s %-70s', [DSP + IntToStr(i + 1) + '.', IntToStr(FoundList.Count), ' ', FindEntries_StringList[i]]));
            Progress.incCurrentProgress;
          end;
          ConsoleLog(Stringofchar('-', CHAR_LENGTH));
          ConsoleLog(RPad('Unique Files by Path:', RPAD_VALUE) + IntToStr(AllFoundListUnique.Count));
          ConsoleLog(Stringofchar('-', CHAR_LENGTH));
        end;

        // ----------------------------------------------------------------------
        // Loop the File System for additional searching
        // ----------------------------------------------------------------------
        if assigned(Working_TList) and (Working_TList.Count > 0) then
        begin
          Progress.Initialize(Working_TList.Count, 'Searching File System for Additional files' + RUNNING);
          // ConsoleLog('Searching File System' + RUNNING);

          inc_sig_regex_str := CreateRegexStr(gInc_Sig_StringList);
          exc_ext_regex_str := CreateRegexStr(gExc_Ext_StringList);
          exc_fnm_regex_str := CreateRegexStr(gExc_Fnm_StringList);

          for i := 0 to Working_TList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            anEntry := TEntry(Working_TList[i]);

            // If the AllFoundListUnique already contains the entry then no need to test it again
            if AllFoundListUnique.Contains(anEntry) then
            begin
              Progress.incCurrentProgress;
              Continue;
            end;

            // Include - Registry
            if (not anEntry.IsDirectory) and RegexMatch(anEntry.EntryName, '^(SOFTWARE|SYSTEM|SAM|SECURITY|NTUSER\.DAT|USRCLASS\.DAT)$', False) then // noslz
            begin
              DetermineFileType(anEntry);
              FileSignature := anEntry.DeterminedFileDriverInfo;
              if (uppercase(FileSignature.ShortDisplayName) = 'REGISTRY') then // noslz
              begin
                registry_count := registry_count + 1;
                AllFoundListUnique.Add(anEntry);
              end;
            end;

            // Include - Determined Signature
            FileSignature := anEntry.DeterminedFileDriverInfo;
            if RegexMatch(FileSignature.ShortDisplayName, inc_sig_regex_str, False) then
            begin
              AllFoundListUnique.Add(anEntry);
              by_sig_count := by_sig_count + 1;
            end;

            Progress.incCurrentProgress;
          end;
          ConsoleLog(RPad('Add Registry by Signature:', RPAD_VALUE) + IntToStr(registry_count));
          ConsoleLog(RPad('Add Files by Signature:', RPAD_VALUE) + IntToStr(by_sig_count));
        end;

        // Move the AllFoundListUnique list into a TList
        if assigned(AllFoundListUnique) and (AllFoundListUnique.Count > 0) then
        begin
          Enum := AllFoundListUnique.GetEnumerator;
          while Enum.MoveNext do
          begin
            anEntry := Enum.Current;
            AllFound_TList.Add(anEntry);
          end;
        end;

        // ----------------------------------------------------------------------
        // Exclude specific Extensions from the AllFound_TList
        // ----------------------------------------------------------------------
        if assigned(AllFound_TList) and (AllFound_TList.Count > 0) then
        begin
          remove_ext_count := 0;
          for i := AllFound_TList.Count - 1 downto 0 do
          begin
            if not Progress.isRunning then
              break;
            anEntry := TEntry(AllFound_TList[i]);
            if RegexMatch(anEntry.Extension, exc_ext_regex_str, False) then
            begin
              anEntry.Flags := anEntry.Flags + [gflag_exclude]; // Add exclude flag
              AllFound_TList.Delete(i);
              remove_ext_count := remove_ext_count + 1;
            end;
          end;
          ConsoleLog(RPad('Excluded by Extension:', RPAD_VALUE) + '-' + IntToStr(remove_ext_count));
        end;

        // ----------------------------------------------------------------------
        // Exclude specific Files from the AllFound_TList
        // ----------------------------------------------------------------------
        if assigned(AllFound_TList) and (AllFound_TList.Count > 0) then
        begin
          remove_fnm_count := 0;
          for i := AllFound_TList.Count - 1 downto 0 do
          begin
            if not Progress.isRunning then
              break;
            anEntry := TEntry(AllFound_TList[i]);
            if RegexMatch(anEntry.EntryName, exc_fnm_regex_str, False) then
            begin
              anEntry.Flags := anEntry.Flags + [gflag_exclude]; // Add exclude flag
              AllFound_TList.Delete(i);
              remove_fnm_count := remove_fnm_count + 1;
            end;
          end;
          ConsoleLog(RPad('Excluded by Filename:', RPAD_VALUE) + '-' + IntToStr(remove_fnm_count));
        end;

        // ----------------------------------------------------------------------
        // Now work with the AllFound_TList from now on
        // ----------------------------------------------------------------------
        if assigned(AllFound_TList) and (AllFound_TList.Count > 0) then
        begin
          for i := 0 to AllFound_TList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            anEntry := TEntry(AllFound_TList[i]);
            anEntry.Flags := anEntry.Flags + [gflag_include]; // Add include flag
            if assigned(gcolCustomList) then
              gcolCustomList.AsString[anEntry] := gcol_str;
            logical_sum_int64 := logical_sum_int64 + anEntry.LogicalSize;
            OutList.Add(anEntry);
          end;
          ConsoleLog(Stringofchar('=', CHAR_LENGTH));
          ConsoleLog(RPad('Unique Files:', RPAD_VALUE) + IntToStr(AllFound_TList.Count));
          ConsoleLog(RPad('Logical Size:', RPAD_VALUE) + GetSizeStr(logical_sum_int64));
          ConsoleLog(Stringofchar('=', CHAR_LENGTH));
        end;

        // ----------------------------------------------------------------------
        // Now work with the Entire List
        // ----------------------------------------------------------------------
        if assigned(Working_TList) and (Working_TList.Count > 0) then
        begin
          for i := 0 to Working_TList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            anEntry := TEntry(Working_TList[i]);
            // Count result column
            if assigned(gcolCustomList) then
            begin
              if gcolCustomList.AsString[anEntry] <> '' then
                col_list_count := col_list_count + 1;
            end;
            // Count Flags
            if Flag1 in anEntry.Flags then
              flag_red_count := flag_red_count + 1;
            if Flag2 in anEntry.Flags then
              flag_blue_count := flag_blue_count + 1;
            if Flag3 in anEntry.Flags then
              flag_gold_count := flag_gold_count + 1;
            if Flag4 in anEntry.Flags then
              flag_orange_count := flag_orange_count + 1;
            if Flag5 in anEntry.Flags then
              flag_green_count := flag_green_count + 1;
            if Flag6 in anEntry.Flags then
              flag_pink_count := flag_pink_count + 1;
            if Flag7 in anEntry.Flags then
              flag_aqua_count := flag_aqua_count + 1;
            if Flag8 in anEntry.Flags then
              flag_brown_count := flag_brown_count + 1;
          end;
        end;

      finally
        FoundList.free;
        AllFoundListUnique.free;
        FindEntries_StringList.free;
      end;

      ConsoleLog('Flag count:');
      ConsoleLog(RPad(PAD + 'Flag 1' + HYPHEN + 'Red', RPAD_VALUE) + IntToStr(flag_red_count));
      ConsoleLog(RPad(PAD + 'Flag 2' + HYPHEN + 'Blue', RPAD_VALUE) + IntToStr(flag_blue_count));
      ConsoleLog(RPad(PAD + 'Flag 3' + HYPHEN + 'Gold', RPAD_VALUE) + IntToStr(flag_gold_count));
      ConsoleLog(RPad(PAD + 'Flag 4' + HYPHEN + 'Orange', RPAD_VALUE) + IntToStr(flag_orange_count));
      ConsoleLog(RPad(PAD + 'Flag 5' + HYPHEN + 'Green', RPAD_VALUE) + IntToStr(flag_green_count));
      ConsoleLog(RPad(PAD + 'Flag 6' + HYPHEN + 'Pink', RPAD_VALUE) + IntToStr(flag_pink_count));
      ConsoleLog(RPad(PAD + 'Flag 7' + HYPHEN + 'Aqua', RPAD_VALUE) + IntToStr(flag_aqua_count));
      ConsoleLog(RPad(PAD + 'Flag 8' + HYPHEN + 'Brown', RPAD_VALUE) + IntToStr(flag_brown_count));
      ConsoleLog(Stringofchar('-', CHAR_LENGTH));

      ConsoleLog(RPad('Column:' + SPACE + COLUMN_NAME, RPAD_VALUE) + IntToStr(col_list_count));
      ConsoleLog(Stringofchar('-', CHAR_LENGTH));

      ConsoleLog(CalcTimeTaken(gtick_start, ''));
      ConsoleLog('Finished.');

    finally
      AllFound_TList.free;
      Working_TList.free;
    end;
  finally
    DataStore_FS.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Find Entries By Path
// ------------------------------------------------------------------------------
procedure Find_Entries_By_Path(aDataStore: TDataStore; aStr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);
var
  fEntry: TEntry;
  s: integer;
begin
  if assigned(aDataStore) and (aDataStore.Count > 1) then
  begin
    FoundList.Clear;
    aDataStore.FindEntriesByPath(nil, aStr, FoundList);
    for s := 0 to FoundList.Count - 1 do
    begin
      fEntry := TEntry(FoundList[s]);
      AllFoundListUnique.Add(fEntry);
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Find Files By Path
// ------------------------------------------------------------------------------
procedure FindFilesByPath(AllFound_TList: TList);
var
  AllFoundListUnique: TUniqueListOfEntries;
  eEntry: TEntry;
  Enum: TEntryEnumerator;
  FileSystemDataStore: TDataStore;
  FindEntries_StringList: TStringList;
  FoundList: TList;
  i: integer;
begin
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  Progress.Log(RPad('Procedure:', RPAD_VALUE) + 'FindFilesByPath' + RUNNING);
  FileSystemDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if FileSystemDataStore = nil then
    Exit;
  try
    AllFoundListUnique := TUniqueListOfEntries.Create;
    FoundList := TList.Create;
    FindEntries_StringList := TStringList.Create;
    try
      Progress.Initialize(FindEntries_StringList.Count, 'Find files by path' + RUNNING);
      if assigned(FileSystemDataStore) and (FileSystemDataStore.Count > 1) then
      begin
        if assigned(FindEntries_StringList) and (FindEntries_StringList.Count > 0) then
        begin
          for i := 0 to FindEntries_StringList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            Find_Entries_By_Path(FileSystemDataStore, FindEntries_StringList[i], FoundList, AllFoundListUnique);
            Progress.incCurrentProgress;
          end;
        end;
      end
      else
        Progress.Log('There are no files in the File System module.');

      // Move the AllFoundListUnique list into a TList
      if assigned(AllFoundListUnique) and (AllFoundListUnique.Count > 0) then
      begin
        Enum := AllFoundListUnique.GetEnumerator;
        while Enum.MoveNext do
        begin
          eEntry := Enum.Current;
          AllFound_TList.Add(eEntry);
        end;
      end;

      // Add to AllFound_TList
      if assigned(AllFound_TList) and (AllFound_TList.Count > 0) then
      begin
        for i := 0 to AllFound_TList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          eEntry := TEntry(AllFound_TList[i]);
          Progress.Log(RPad(IntToStr(i + 1) + '. ' + 'Found:' + SPACE + GetSizeStr(eEntry.LogicalSize), RPAD_VALUE) + eEntry.FullPathName);
        end;
      end;

    finally
      FreeAndNil(FindEntries_StringList);
      FreeAndNil(AllFoundListUnique);
    end;
  finally
    FreeAndNil(FileSystemDataStore);
  end;
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
const
  TSWT = 'The script will terminate.';
  SPACE = ' ';
var
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
  Starting_StringList: TStringList;
  procedure StartingSummary(AString: string);
  begin
    if assigned(Starting_StringList) then
      Starting_StringList.Add(AString);
  end;
  function RPad(AString: string; AChars: integer): string;
  begin
    while Length(AString) < AChars do
      AString := AString + ' ';
    Result := AString;
  end;

begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  Starting_StringList := TStringList.Create;
  try
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      Progress.Log('There is no current case.' + SPACE + TSWT);
      Exit;
    end
    else
      gCaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      Progress.Log('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;

    Starting_StringList.Add(Stringofchar('~', CHAR_LENGTH));
    Starting_StringList.Add(RPad('Script Name:', RPAD_VALUE) + SCRIPT_NAME);
    Starting_StringList.Add(RPad('Case Name:', RPAD_VALUE) + gCaseName);
    if GetInvestigatorName <> '' then
      Starting_StringList.Add(RPad('Investigator:', RPAD_VALUE) + GetInvestigatorName);
    Starting_StringList.Add(RPad('Date Run:', RPAD_VALUE) + DateTimeToStr(now));
    Starting_StringList.Add(RPad('FEX Version:', RPAD_VALUE) + CurrentVersion);
    Starting_StringList.Add(RPad('Script:', RPAD_VALUE) + ExtractFileName(gScriptFullPath_str));
    Starting_StringList.Add(Stringofchar('~', CHAR_LENGTH));

    Result := True;
    gStarting_Summary_str := trim(Starting_StringList.text);
  finally
    StartCheckDataStore.free;
    Starting_StringList.free;
  end;
end;

procedure LogList(listname_str: string; aStringList: TStringList);
const
  LOG_AS_TEXT = False;
var
  j: integer;
begin
  if LOG_LISTS_BL then
  begin
    ConsoleLog(listname_str + SPACE + LB + IntToStr(aStringList.Count) + RB);
    if LOG_AS_TEXT then
      Progress.Log(aStringList.text)
    else
      for j := 0 to gInc_Pth_StringList.Count - 1 do
        Progress.Log(DSP + aStringList[j]);
    ConsoleLog(Stringofchar('4', CHAR_LENGTH));
  end;
end;

// ==============================================================================
// The start of the script
// ==============================================================================
begin
  gtick_start := GetTickCount64;
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.Log('Starting' + RUNNING);
  Progress.Log(gStarting_Summary_str);
  Progress.DisplayMessageNow := ('Starting' + RUNNING);
  gScriptFullPath_str := CmdLine.Path;
  gchbColSF02 := True;
  gcol_str := 'Include';

  if not StartingChecks then
    Exit;

  // Exclude
  gExc_Ext_StringList := TStringList.Create;
  gExc_Ext_StringList.Sorted := True;
  gExc_Ext_StringList.Duplicates := dupIgnore;
  gExc_Ext_StringList.Delimiter := '|';
  gExc_Ext_StringList.StrictDelimiter := True;

  gExc_Fnm_StringList := TStringList.Create;
  gExc_Fnm_StringList.Sorted := True;
  gExc_Fnm_StringList.Duplicates := dupIgnore;
  gExc_Fnm_StringList.Delimiter := '|';
  gExc_Fnm_StringList.QuoteChar := '"';
  gExc_Fnm_StringList.StrictDelimiter := True;

  // Include
  gInc_Ext_StringList := TStringList.Create;
  gInc_Ext_StringList.Sorted := True;
  gInc_Ext_StringList.Duplicates := dupIgnore;
  gInc_Ext_StringList.Delimiter := '|';
  gInc_Ext_StringList.StrictDelimiter := True;

  gInc_Pth_StringList := TStringList.Create;
  gInc_Pth_StringList.Sorted := True;
  gInc_Pth_StringList.Duplicates := dupIgnore;
  gInc_Pth_StringList.Delimiter := '|';
  gInc_Pth_StringList.StrictDelimiter := True;

  gInc_Sig_StringList := TStringList.Create;
  gInc_Sig_StringList.Sorted := True;
  gInc_Sig_StringList.Duplicates := dupIgnore;
  gInc_Sig_StringList.Delimiter := '|';
  gInc_Sig_StringList.StrictDelimiter := True;

  gImport_StringList := TStringList.Create;

  gResults_StringList := TStringList.Create;
  try
    gResults_StringList.Add(gStarting_Summary_str);

    // Read the INPUTFILE (set in the TXML)
    gInputFileName_str := ScriptTask.GetTaskListOption('INPUTFILE');
    gInputFileName_fullpath_str := ExtractFilePath(gScriptFullPath_str) + 'Settings' + BS + gInputFileName_str;

    if not FileExists(gInputFileName_fullpath_str) then
    begin
      Progress.Log(RPad('Did not find:', RPAD_VALUE) + gInputFileName_fullpath_str);
      OpenLog;
      Exit;
    end
    else
      LoadFromFile(gInputFileName_fullpath_str);

    MainProc;

    ExportResultsToFile(gResults_StringList);

  finally
    gExc_Ext_StringList.free;
    gExc_Fnm_StringList.free;
    gInc_Ext_StringList.free;
    gInc_Sig_StringList.free;
    gInc_Pth_StringList.free;
    gResults_StringList.free;
    gImport_StringList.free;
  end;
  OpenLog;

end.
