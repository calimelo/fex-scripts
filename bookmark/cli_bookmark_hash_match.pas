unit bookmark_hash_match_with_random_sample;

interface

uses
  // GUI,
  Classes, Common, DataEntry, DataStorage, NoteEntry, RegEx, SysUtils, Math;

// Case Sensitive Parameters:
// BLUR     Applies the hard-coded blur setting.
// EXCLUDE  Runs the hard-coded exclude criteria to exclude files.

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BM_FLDR_EXCLUDED = 'EXCLUDED';
  BM_FLDR_HASH_MATCHED = 'Hash Matched';
  BM_FLDR_HASH_MATCHED_RANDOM_SAMPLE = 'Hash Matched - Random Sample';
  BM_FLDR_ROOT = 'Hash Match';
  BS = '\';
  CHAR_LENGTH = 80;
  CLN = ':';
  CR = #13#10;
  DBS = '\\';
  DCR = #13#10 + #13#10;
  EXCLUDED_BY_STR = 'Excluded by ';
  FLDR_GLB1 = '\\Fexlabs\share\Global_Output';
  FLDR_GLB2 = '\\192.168.0.24\SHARE\Global_Output';
  FLDR_GLB3 = 'C:\FEXLAB_SERVER\SHARE\Global_Output';
  FLDR_HASH_MATCH = 'HASH_MATCH';
  FLDR_REPORTS = 'Reports';
  HASHSET_MATCHES = 'HashSet matches';
  HYPHEN = ' - ';
  HYPHEN_NS = '-';
  LB = '(';
  LB_EXCLUDED_RB = '(excluded files)';
  LB_INCLUDED_RB = '(included files)';
  OSFILENAME = '\\?\'; // This is needed for long file names
  RANDOM_TO_BOOKMARK_INT = 5;
  RB = ')';
  RPAD_VALUE = 35;
  RUNNING = '...';
  SAVED_FILE_STR = 'Saved File';
  SCRIPT_NAME = 'Bookmark Hash Match with Random Sample';
  SPACE = ' ';
  SPECIALCHAR_HLINE: char = #9472; // noslz
  SUMMARY_RPT = 'Hash Match - Summary Report.txt';

  EXCLUDE_EXT_REGEX_STR = '\.(CHK|DB)$';
  EXCLUDE_FILES_UNDER = 5120;
  EXCLUDE_SIG_REGEX_STR = '(icns|Visio|Icon|thumb)$';
  EXCLUDE_PATH_REGEX_STR = '\\*.AppData.*\\' + '|' + '\\*.Installshield.*\\' + '|' + '\\*.NSIS.*\\' + '|' + '\\*.ProgramData.*\\' + '|' + '\\*.Resources.*\\' + '|' + '\\*.Safari.*' + '|' + '\\*.Spotlight.*' + '|' + '\\\$Recycle\.Bin' + '|'
    + '\\cache' + '|' + '\\Chrome' + '|' + '\\com.apple.Safari' + '|' + '\\Cyberlink' + '|' + '\\InfusedApps' + '|' + '\\Microsoft Office' + '|' + '\\Microsoft.Net\\' + '|' + '\\MicrosoftEdge' + '|' + '\\MobileSync\\' + '|' +
    '\\MOZILLA\\FIREFOX' + '|' + '\\Netscape' + '|' + '\\Notifications' + '|' + '\\Orphaned\\' + '|' + '\\Packages' + '|' + '\\RECYCLER' + '|' + '\\SoftwareDistribution\\' + '|' + '\\SWSetup' + '|' + '\\System Volume Information' + '|' +
    '\\SystemApps' + '|' + '\\TEMPORARY INTERNET FILES' + '|' + '\\WebServiceCache\\' + '|' + '\\Windows\\Temp\\' + '|' + '\\Windows\\Web\\' + '|' + '\\WindowsApps' + '|' + '\\WinSxS';

var
  gbl_exclude_files: boolean;
  gblur_pic_int: integer;
  gBlurField: TDataStoreField;
  gCaseName: string;
  gDevice_TList: TList;
  gexclude_count_del: integer;
  gexclude_count_ext: integer;
  gexclude_count_min: integer;
  gexclude_count_pth: integer;
  gexclude_count_sig: integer;
  gExcTList: TList;
  gHashSetName_StringList: TStringList;
  gIncTList: TList;
  gMemo_StringList: TStringList;
  gParams_StringList: TStringList;
  greason_str: string;
  gStartSummary_str: string;
  gstr_lb_included_rb: string;

  // Declare functions and procedures
function GetUniqueFileName(aFileName: string): string;
function RPad(Astring: string; AChars: integer): string;
function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';
function StartingChecks: boolean;
procedure ConsoleLog(Astring: string);
procedure DeleteExistingBookmarkFolders;
procedure GetDeviceTList(dTList: TList);
procedure HashFiles(MAX_FILESIZE: string);
procedure SignatureAnalysis(SigThis_TList: TList);

implementation

// ------------------------------------------------------------------------------
// Procedure: Console Log - Memo and Messages
// ------------------------------------------------------------------------------
procedure ConsoleLog(Astring: string);
begin
  Progress.Log(Astring);
  if assigned(gMemo_StringList) then
    gMemo_StringList.Add(Astring);
end;

// ------------------------------------------------------------------------------
// Procedure: Right Pad
// ------------------------------------------------------------------------------
function RPad(Astring: string; AChars: integer): string;
begin
  while length(Astring) < AChars do
    Astring := Astring + ' ';
  Result := Astring;
end;

// ------------------------------------------------------------------------------
// Procedure: GetDevice List
// ------------------------------------------------------------------------------
procedure GetDeviceTList(dTList: TList);
var
  DataStore_EV: TDataStore;
  dEntry: TEntry;
begin
  dTList.clear;
  DataStore_EV := GetDataStore(DATASTORE_EVIDENCE);
  try
    If not assigned(DataStore_EV) then
      Exit;
    dEntry := DataStore_EV.First;
    while assigned(dEntry) and (Progress.isRunning) do
    begin
      if dEntry.IsDevice then
        dTList.Add(dEntry);
      dEntry := DataStore_EV.next;
    end;
  finally
    DataStore_EV.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Hash Files
// ------------------------------------------------------------------------------
procedure HashFiles(MAX_FILESIZE: string);
const
  LAUNCH_STR = 'Launching hash files';
var
  aTLilst: TList;
  bl_Continue: boolean;
  FSDataStore: TDataStore;
  TaskProgress: TPAC;
  tick_count: uint64;
  time_taken_int: uint64;
begin
  if not Progress.isRunning then
    Exit;
  tick_count := GetTickCount64;
  FSDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  aTLilst := FSDataStore.GetEntireList;
  try
    if aTLilst.Count > 0 then
    begin
      Progress.CurrentPosition := Progress.Max;
      Progress.DisplayMessageNow := (LAUNCH_STR + SPACE + '(' + IntToStr(aTLilst.Count) + ' files)' + RUNNING);
      Progress.Log(RPad(LAUNCH_STR + RUNNING, RPAD_VALUE) + IntToStr(aTLilst.Count));
      if Progress.isRunning then
      begin
        TaskProgress := NewProgress(True);
        RunTask('TCommandTask_CreateHash', DATASTORE_FILESYSTEM, aTLilst, TaskProgress, ['md5', 'Maxfilesize=' + MAX_FILESIZE, 'findduplicates=True']); // noslz
        while (TaskProgress.isRunning) and (Progress.isRunning) do
          Sleep(500);
        if not(Progress.isRunning) then
          TaskProgress.Cancel;
        bl_Continue := (TaskProgress.CompleteState = pcsSuccess);
      end;
    end;
    time_taken_int := (GetTickCount64 - tick_count);
    time_taken_int := trunc(time_taken_int / 1000);
    Progress.Log(RPad('Hash files time taken:', RPAD_VALUE) + IntToStr(time_taken_int));
    Progress.Log(stringofchar('-', 80));
  finally
    aTLilst.free;
    FSDataStore.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Signature Analysis
// ------------------------------------------------------------------------------
procedure SignatureAnalysis(SigThis_TList: TList);
const
  RUNNING_SIG_STR = 'Running Signature Analysis';
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
    Progress.Log(RPad('Not assigned Signature TList.', RPAD_VALUE) + 'Signature Analysis not run.');
    Exit;
  end;
  if assigned(SigThis_TList) and (SigThis_TList.Count > 0) then
  begin
    if Progress.isRunning then
    begin
      Progress.Log(RUNNING_SIG_STR + RUNNING);
      Progress.DisplayMessageNow := RUNNING_SIG_STR;
      TaskProgress := Progress.NewChild; // NewProgress(True);
      RunTask('TCommandTask_FileTypeAnalysis', DATASTORE_FILESYSTEM, SigThis_TList, TaskProgress);
      while (TaskProgress.isRunning) and (Progress.isRunning) do
        Sleep(500); // Do not proceed until TCommandTask_FileTypeAnalysis is complete
      if not(Progress.isRunning) then
        TaskProgress.Cancel;
      gbl_Continue := (TaskProgress.CompleteState = pcsSuccess);
    end;
  end;
  Progress.DisplayTitle := SCRIPT_NAME;
end;

// ------------------------------------------------------------------------------
// Procedure: Delete Existing Bookmarked Folders
// ------------------------------------------------------------------------------
procedure DeleteExistingBookmarkFolders;
var
  BmDataStore: TDataStore;
  bmfEntry: TEntry;
  ExistingFolders_StringList: TStringList;
  ExistingFolders_TList: TList;
  FolderDelete_TList: TList;
  r: integer;
  rEntry: TEntry;
begin
  // Collect a list of the existing Bookmark module folders
  BmDataStore := GetDataStore(DATASTORE_BOOKMARKS);
  if BmDataStore = nil then
    Exit;
  try
    ExistingFolders_StringList := TStringList.Create;
    ExistingFolders_TList := TList.Create;
    FolderDelete_TList := TList.Create;
    try
      if BmDataStore.Count > 1 then
      begin
        bmfEntry := BmDataStore.First;
        while assigned(bmfEntry) and Progress.isRunning do
        begin
          if bmfEntry.IsDirectory and (RegexMatch(bmfEntry.FullPathName, BM_FLDR_ROOT + DBS + BM_FLDR_HASH_MATCHED, False)) then
          begin
            ExistingFolders_StringList.Add(bmfEntry.EntryName);
            ExistingFolders_TList.Add(bmfEntry);
            FolderDelete_TList.Add(bmfEntry);
          end;
          bmfEntry := BmDataStore.next;
        end;
        BmDataStore.close;
      end;

      // Delete these folders
      Progress.Log('Delete these bookmarks:');
      for r := 0 to FolderDelete_TList.Count - 1 do
      begin
        rEntry := TEntry(FolderDelete_TList[r]);
        Progress.Log(HYPHEN + rEntry.EntryName);
      end;

      if assigned(FolderDelete_TList) and (FolderDelete_TList.Count > 0) then
      begin
        try
          BmDataStore.Remove(FolderDelete_TList);
        except
          Progress.Log(ATRY_EXCEPT_STR + 'ERROR: There was an error deleting existing bookmarks.');
        end;
      end;

    finally
      ExistingFolders_StringList.free;
      ExistingFolders_TList.free;
      FolderDelete_TList.free;
    end;
  finally
    BmDataStore.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Random Bookmark from TList
// ------------------------------------------------------------------------------
procedure RandomBookmarkFromTList(InList: TList; SampleCount: integer; bFolder: TEntry);
var
  bEntry: TEntry;
  iRandom: integer;
  iSkipCount: integer;
  Population_TList: TList;
  SampleList: TUniqueListOfEntries;
begin
  iSkipCount := 0;
  Population_TList := TList.Create;
  SampleList := TUniqueListOfEntries.Create;
  try
    repeat
      if not Progress.isRunning then
        Break;
      Population_TList.Assign(InList, laCopy);
      if assigned(Population_TList) and (Population_TList.Count > 0) then
      begin
        iRandom := RandomRange(0, Population_TList.Count - 1);
        bEntry := TEntry(Population_TList[iRandom]);
        Population_TList[iRandom] := nil; // Makes the bEntry nil for the next iteration
        if (bEntry = nil) or SampleList.Contains(bEntry) then
        begin
          inc(iSkipCount);
          if iSkipCount > 3 then
            Population_TList.Pack;
        end
        else // Only selects an bEntry that is not nil
        begin
          SampleList.Add(bEntry);
          Progress.IncCurrentProgress;
          // Progress.Log(format('%-20s %-20s %-50s',[IntToStr(SampleList.Count) + CLN, IntToStr(iRandom), bEntry.EntryName]));
          if not IsItemInBookmark(bFolder, bEntry) then
            AddItemsToBookmark(bFolder, DATASTORE_FILESYSTEM, bEntry, '');
        end;
      end;
    until (SampleList.Count = SampleCount) or (Population_TList.Count = 0);
  finally
    Population_TList.free;
    SampleList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Create a unique filename
// ------------------------------------------------------------------------------
function GetUniqueFileName(aFileName: string): string;
var
  fext: string;
  fname: string;
  fnum: integer;
  fpath: string;
begin
  Result := aFileName;
  if FileExists(aFileName) then
  begin
    fext := ExtractFileExt(aFileName);
    fnum := 1;
    fname := ExtractFileName(aFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(aFileName);
    while FileExists(fpath + fname + '_' + IntToStr(fnum) + fext) do
      fnum := fnum + 1;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Save FEXLAB Global
// ------------------------------------------------------------------------------
function FexLab_Global_Save(aStringList: TStringList; sum_int: integer): boolean;
const
  INC_STR = 'inc.';
  EXC_STR = 'exc.';

var
  ExportDate: string;
  ExportDateTime: string;
  ExportTime: string;
  FexLab_Global_Fnm_str: string;
  FexLab_Global_Fldr_str: string;
  FexLab_Global_Pth_str: string;
  str_inc_exc: string;
  the_dev_str: string;

begin
  Result := False;

  // Test for Global folder
  if DirectoryExists(FLDR_GLB1) then
  begin
    FexLab_Global_Fldr_str := FLDR_GLB1;
    Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(FexLab_Global_Fldr_str), True), RPAD_VALUE) + FLDR_GLB1);
  end

  else if DirectoryExists(FLDR_GLB2) then
  begin
    FexLab_Global_Fldr_str := FLDR_GLB2;
    Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(FLDR_GLB2), True), RPAD_VALUE) + FLDR_GLB2);
  end
  else if DirectoryExists(FLDR_GLB3) then
  begin
    FexLab_Global_Fldr_str := FLDR_GLB3;
    Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(FLDR_GLB3), True), RPAD_VALUE) + FLDR_GLB3);
  end

  else
  begin
    FexLab_Global_Fldr_str := '';
    ConsoleLog('Could not find Global folder.');
    Exit;
  end;

  // Filename - Create date time
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + '-' + ExportTime);

  // Filename - Create device name
  the_dev_str := '';
  if assigned(gDevice_TList) and (gDevice_TList.Count = 1) then
    the_dev_str := TEntry(gDevice_TList[0]).EntryName
  else
    the_dev_str := gCaseName;

  // Global Folder Filename.txt
  if gbl_exclude_files then // Format Global Folder filename with leading 0s
  begin
    str_inc_exc := LB + INC_STR + SPACE + Format('%.*d', [6, sum_int]) + HYPHEN + EXC_STR + SPACE + Format('%.*d', [6, gExcTList.Count]) + RB; // Filename has (inc. 000000 - exc. 000000)
  end
  else
    str_inc_exc := LB + INC_STR + SPACE + IntToStr(sum_int) + RB; // Filename has (inc. 000000)

  FexLab_Global_Fnm_str := GetUniqueFileName('Hash Match' + SPACE + str_inc_exc + HYPHEN + gCaseName + HYPHEN + the_dev_str + '.txt');

  // Create the folder and save the file
  FexLab_Global_Pth_str := FexLab_Global_Fldr_str + BS + FLDR_HASH_MATCH;
  if ForceDirectories(IncludeTrailingPathDelimiter(FexLab_Global_Pth_str)) and DirectoryExists(FexLab_Global_Pth_str) then
    try
      aStringList.SaveToFile(FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str);
      Sleep(1000);
    except
      on e: exception do
      begin
        ConsoleLog(RPad(ATRY_EXCEPT_STR + 'A.' + HYPHEN + FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str + CR + ATRY_EXCEPT_STR, RPAD_VALUE) + e.message);
        Result := False;
        Exit;
      end;
    end;

  // Test to see if the file was saved
  if FileExists(FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str) then
  begin
    ConsoleLog(RPad(SAVED_FILE_STR + SPACE + '(FEXLAB Global)' + CLN, RPAD_VALUE) + FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str);
    Result := True;
  end
  else
  begin
    ConsoleLog(RPad('Error saving file' + SPACE + '(FEXLAB Global)' + CLN, RPAD_VALUE) + FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str);
    Result := False;
  end;
  ConsoleLog(stringofchar('-', CHAR_LENGTH));
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
const
  TSWT = 'The script will terminate.';
var
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
  Start_StringList: TStringList;
begin
  Result := False;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  try
    Start_StringList := TStringList.Create;
    try
      StartCheckEntry := StartCheckDataStore.First;
      if not assigned(StartCheckEntry) then
      begin
        Progress.Log('There is no current case.' + SPACE + TSWT);
        Exit;
      end
      else
        gCaseName := StartCheckEntry.EntryName;
      Start_StringList.Add(stringofchar('-', CHAR_LENGTH));
      Start_StringList.Add(RPad('Case Name' + CLN, RPAD_VALUE) + gCaseName);
      Start_StringList.Add(RPad('Script Name' + CLN, RPAD_VALUE) + SCRIPT_NAME);
      Start_StringList.Add(RPad('Date Run' + CLN, RPAD_VALUE) + DateTimeToStr(now));
      Start_StringList.Add(RPad('FEX Version' + CLN, RPAD_VALUE) + CurrentVersion);
      Start_StringList.Add(stringofchar('-', CHAR_LENGTH));
      gStartSummary_str := Start_StringList.Text;
      if StartCheckDataStore.Count <= 1 then
      begin
        Progress.Log('There are no files in the File System module.' + SPACE + TSWT);
        Exit;
      end;
      Result := True; // If it makes it this far then StartCheck is True
    finally
      Start_StringList.free;
    end;
  finally
    FreeAndNil(StartCheckDataStore);
  end;
end;

function Exclude_Test(iEntry: TEntry): boolean;
var
  DeterminedFileDriverInfo: TFileTypeInformation;
begin
  Result := False;
  greason_str := '';
  DeterminedFileDriverInfo := iEntry.DeterminedFileDriverInfo;

  // Exclude by Deleted
  if (iEntry.isDeleted) then
  begin
    greason_str := EXCLUDED_BY_STR + 'Deleted';
    gexclude_count_del := gexclude_count_del + 1;
    Result := True;
    Exit;
  end
  else

    // Exclude by Minimum Size
    if iEntry.LogicalSize < EXCLUDE_FILES_UNDER then
    begin
      greason_str := EXCLUDED_BY_STR + 'Logical Size < ' + IntToStr(EXCLUDE_FILES_UNDER);
      gexclude_count_min := gexclude_count_min + 1;
      Result := True;
      Exit;
    end
    else

      // Exclude by Extension (regex)
      if RegexMatch(iEntry.Extension, EXCLUDE_EXT_REGEX_STR, False) then
      begin
        greason_str := EXCLUDED_BY_STR + 'Extension ' + EXCLUDE_EXT_REGEX_STR;
        gexclude_count_ext := gexclude_count_ext + 1;
        Result := True;
        Exit;
      end
      else

        // Exclude by Path (regex)
        if RegexMatch(iEntry.FullPathName, EXCLUDE_PATH_REGEX_STR, False) then
        begin
          greason_str := EXCLUDED_BY_STR + 'Path';
          gexclude_count_pth := gexclude_count_pth + 1;
          Result := True;
          Exit;
        end;

  // Exclude by Signature
  if (iEntry.ClassName = 'TMediaFileEntry') or ((DeterminedFileDriverInfo.FileDriverNumber > 0) and (RegexMatch(DeterminedFileDriverInfo.ShortDisplayName, EXCLUDE_SIG_REGEX_STR, False))) then
  begin
    greason_str := EXCLUDED_BY_STR + 'Signature';
    gexclude_count_sig := gexclude_count_sig + 1;
    Result := True;
    Exit;
  end;

end;

// ------------------------------------------------------------------------------
// Function: Parameters Received
// ------------------------------------------------------------------------------
function ParametersReceived: boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  Progress.Log(stringofchar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    param_str := '';
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(HYPHEN + 'Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      gParams_StringList.Add(trim(CmdLine.params[i]));
      param_str := param_str + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
    Progress.Log('No parameters were received.');
  Progress.Log(stringofchar('-', 80));
end;

// ==============================================================================
// Start of the Script
// ==============================================================================
const
  LINE_LENGTH = 20;

var
  anEntry: TEntry;
  bmFolder: TEntry;
  colResult: string;
  Column: TDataStoreField;
  CurrentComment: string;
  DataStore_FS: TDataStore;
  DataStore_FS_TList: TList;
  devEntry: TEntry;
  eEntry: TEntry;
  etEntry: TEntry;
  exc_count: integer;
  excluded_file_count: integer;
  hdr_str: string;
  i, j, k, idx: integer;
  inc_count: integer;
  index: integer;
  LineList: TStringList;
  lnk_to_pdf_report_str: string;
  Path_StringList: TStringList;
  rnd_bm_int: integer;
  sum_bm_int: integer;
  sum_ex_int: integer;
  tot_bm_int: integer;

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessageNow := 'Script starting' + RUNNING;
  // Initialize variables
  gbl_exclude_files := False;
  gblur_pic_int := 0;
  gstr_lb_included_rb := '';

  // Starting Checks
  if not StartingChecks then
    Exit;

  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore_FS = nil then
    Exit;

  try
    gBlurField := AddMetaDataField('BlurValue', ftByte); // noslz

    // Sett the HashSet column
    Column := nil;
    Column := DataStore_FS.DataFields.FieldByName('HASHSET'); // noslz
    if Column = nil then
      Exit;

    // Run a Signature Analysis - CLI will already have done this from TXML
    DataStore_FS_TList := TList.Create;
    try
      DataStore_FS_TList := DataStore_FS.GetEntireList;
      SignatureAnalysis(DataStore_FS_TList);
    finally
      FreeAndNil(DataStore_FS_TList);
    end;

    // Remove the existing bookmarks from previous run
    Progress.DisplayMessageNow := 'Removing previous bookmark folders' + RUNNING;
    DeleteExistingBookmarkFolders;

    // Create Lists
    gDevice_TList := TList.Create;
    gExcTList := TList.Create;
    gHashSetName_StringList := TStringList.Create;
    // gHashSetName_StringList.Duplicates := dupIgnore; // This will exclude duplicate items from the bookmark folder.
    gHashSetName_StringList.Sorted := True;
    gMemo_StringList := TStringList.Create;
    gParams_StringList := TStringList.Create;

    LineList := TStringList.Create;
    LineList.Delimiter := ',';
    LineList.QuoteChar := '"';
    LineList.StrictDelimiter := True;

    try
      // Test for BLUR parameter received
      ParametersReceived;
      if (CmdLine.ParamCount > 0) then
      begin
        if gParams_StringList.Find('BLUR', index) then
          gblur_pic_int := 5
        else if gParams_StringList.Find('BLUR1', index) then
          gblur_pic_int := 1
        else if gParams_StringList.Find('BLUR2', index) then
          gblur_pic_int := 2
        else if gParams_StringList.Find('BLUR3', index) then
          gblur_pic_int := 3
        else if gParams_StringList.Find('BLUR4', index) then
          gblur_pic_int := 4
        else if gParams_StringList.Find('BLUR5', index) then
          gblur_pic_int := 5
        else if gParams_StringList.Find('BLUR6', index) then
          gblur_pic_int := 6
        else if gParams_StringList.Find('BLUR7', index) then
          gblur_pic_int := 7
        else if gParams_StringList.Find('BLUR8', index) then
          gblur_pic_int := 8
        else if gParams_StringList.Find('BLUR9', index) then
          gblur_pic_int := 9
        else if gParams_StringList.Find('BLUR10', index) then
          gblur_pic_int := 10;
      end
      else
        gblur_pic_int := 0;

      // Test for EXCLUDE parameter received
      if (CmdLine.ParamCount > 0) and (gParams_StringList.Find('EXCLUDE', index)) then
      begin
        gbl_exclude_files := True;
        gstr_lb_included_rb := LB_INCLUDED_RB;
      end;

      // Log Settings
      ConsoleLog('Settings' + CLN);
      ConsoleLog(RPad('Max random sample' + CLN, RPAD_VALUE) + IntToStr(RANDOM_TO_BOOKMARK_INT));
      ConsoleLog(RPad('Blur Images' + CLN, RPAD_VALUE) + 'True' + SPACE + LB + 'Blur Setting: ' + IntToStr(gblur_pic_int) + '/10' + RB);

      if gbl_exclude_files then
      begin
        ConsoleLog(RPad('Exclude Files:', RPAD_VALUE) + BoolToStr(gbl_exclude_files, True));
        ConsoleLog(RPad(HYPHEN + 'Minimum Size (bytes)' + CLN, RPAD_VALUE) + IntToStr(EXCLUDE_FILES_UNDER));
        ConsoleLog(RPad(HYPHEN + 'Extensions (regex)' + CLN, RPAD_VALUE) + EXCLUDE_EXT_REGEX_STR);
        ConsoleLog(RPad(HYPHEN + 'Signatures (regex)' + CLN, RPAD_VALUE) + EXCLUDE_SIG_REGEX_STR);

        Path_StringList := TStringList.Create;
        Path_StringList.Delimiter := '|';
        Path_StringList.StrictDelimiter := True;
        try
          Path_StringList.DelimitedText := EXCLUDE_PATH_REGEX_STR;
          for i := 0 to Path_StringList.Count - 1 do
          begin
            if not Progress.isRunning then
              Break;
            if i = 0 then
              hdr_str := HYPHEN + 'Path'
            else
              hdr_str := '';
            ConsoleLog(RPad(hdr_str, RPAD_VALUE) + Path_StringList[i]);
          end;
        finally
          Path_StringList.free;
        end;

      end
      else
        ConsoleLog(RPad('Exclude Files:', RPAD_VALUE) + BoolToStr(gbl_exclude_files, True));
      ConsoleLog(stringofchar('-', CHAR_LENGTH));

      GetDeviceTList(gDevice_TList);

      // Collect the HashSet names
      Progress.Initialize(DataStore_FS.Count, 'Collecting HashSet names' + RUNNING);
      anEntry := DataStore_FS.First;
      while assigned(anEntry) and assigned(Column) do
      begin
        colResult := '';
        if assigned(Column) then
          colResult := Column.AsString[anEntry];
        if colResult <> '' then
        begin
          LineList.CommaText := Column.AsString[anEntry];
          for i := 0 to LineList.Count - 1 do
          begin
            idx := gHashSetName_StringList.Add(LineList[i]);
            if not assigned(gHashSetName_StringList.Objects[idx]) then
              gHashSetName_StringList.Objects[idx] := TList.Create;
            TList(gHashSetName_StringList.Objects[idx]).Add(anEntry);
          end;
        end;
        anEntry := DataStore_FS.next;
        Progress.IncCurrentProgress;
      end;

      if gHashSetName_StringList.Count > 0 then
      begin
        ConsoleLog(RPad('Unique matched HashSet names' + CLN, RPAD_VALUE) + IntToStr(gHashSetName_StringList.Count));
        for i := 0 to gHashSetName_StringList.Count - 1 do
        begin
          ConsoleLog(RPad(SPACE + IntToStr(i + 1) + '.', RPAD_VALUE) + gHashSetName_StringList[i]);
        end;
        ConsoleLog(stringofchar('-', CHAR_LENGTH));
      end
      else
      begin
        ConsoleLog('No hashset matches were located.');
        ConsoleLog(stringofchar('-', CHAR_LENGTH));
      end;

      // Create bookmark folder using hash set names
      if assigned(gHashSetName_StringList) and (gHashSetName_StringList.Count > 0) then
      begin
        ConsoleLog(Format('%-34s %5s %1s %5s', ['Items Bookmarked (Inc. Only)', 'Inc.', HYPHEN, 'Exc.']));
        ConsoleLog(RPad(stringofchar(SPECIALCHAR_HLINE, RPAD_VALUE - 5), RPAD_VALUE) + stringofchar(SPECIALCHAR_HLINE, LINE_LENGTH));
        for i := 0 to gHashSetName_StringList.Count - 1 do
        begin
          if not Progress.isRunning then
            Break;
          inc_count := 0;
          exc_count := 0;

          rnd_bm_int := RANDOM_TO_BOOKMARK_INT;
          tot_bm_int := TList(gHashSetName_StringList.Objects[i]).Count;
          if tot_bm_int < rnd_bm_int then
            rnd_bm_int := tot_bm_int;

          // --------------------------------------------------------------------
          // Create bookmark folders for all hash matched files
          // --------------------------------------------------------------------

          // Create the Hash Match parent bookmark folder
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT, 'Blur Setting:' + SPACE + IntToStr(gblur_pic_int) + '/10' + SPACE)
          else
            UpdateBookmark(bmFolder, 'Blur Setting:' + SPACE + IntToStr(gblur_pic_int) + '/10' + SPACE);

          // Add the Hash Matched parent bookmark folder
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED, '');

          if gbl_exclude_files then
          begin
            // Create the hash set name bookmark folders for EXCLUDED items ("Hash Matched - EXCLUDED").
            bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + HYPHEN + BM_FLDR_EXCLUDED + BS + gHashSetName_StringList[i]);
            if bmFolder = nil then
              bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + HYPHEN + BM_FLDR_EXCLUDED + BS + gHashSetName_StringList[i], '');
          end;

          // Create the hash set name bookmark folders
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + HYPHEN + BS + gHashSetName_StringList[i]);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + BS + gHashSetName_StringList[i], ''); // 'Hash Set Name: ' + gHashSetName_StringList[i]);

          // Process
          gIncTList := TList.Create;
          try
            gIncTList.Assign(TList(gHashSetName_StringList.Objects[i]), laCopy);

            Progress.DisplayMessageNow := 'Processing' + RUNNING;
            for j := TList(gHashSetName_StringList.Objects[i]).Count - 1 downto 0 do
            begin
              if not Progress.isRunning then
                Break;
              eEntry := TEntry(TList(gHashSetName_StringList.Objects[i])[j]);

              // Set the Blur Setting
              if assigned(gBlurField) then
                gBlurField.AsByte[eEntry] := gblur_pic_int;

              // If running Exclude
              if gbl_exclude_files then
              begin
                if Exclude_Test(eEntry) then
                begin
                  bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + HYPHEN + BM_FLDR_EXCLUDED + BS + gHashSetName_StringList[i]);
                  AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, eEntry, greason_str);
                  exc_count := exc_count + 1;
                  gExcTList.Add(eEntry);
                  gIncTList.Delete(j); // Delete the excluded files from the TList
                end
                else
                begin
                  bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + BS + gHashSetName_StringList[i]);
                  excluded_file_count := excluded_file_count + 1;
                  AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, eEntry, '');
                  inc_count := inc_count + 1;
                  if assigned(OutList) then
                    OutList.Add(eEntry);
                end;
              end
              else
              // If not running Exclude
              begin
                bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + BS + gHashSetName_StringList[i]);
                AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, eEntry, '');
                inc_count := inc_count + 1;
                if assigned(OutList) then
                  OutList.Add(eEntry);
              end;
            end;

            // ------------------------------------------------------------------
            // Create bookmark folders for reporting purposes
            // ------------------------------------------------------------------
            // Create the reporting bookmark parent folder
            bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SAMPLE);
            if bmFolder = nil then
              bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SAMPLE, IntToStr(RANDOM_TO_BOOKMARK_INT));
            CurrentComment := '';

            ConsoleLog(Format('%-34s %5s %1s %5s', [HYPHEN + gHashSetName_StringList[i] + CLN, IntToStr(inc_count), HYPHEN, IntToStr(exc_count)]));
            sum_bm_int := sum_bm_int + inc_count;
            sum_ex_int := sum_ex_int + exc_count;

            if gIncTList.Count > 0 then
            begin
              // Create the hash set name reporting bookmark folders
              bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SAMPLE + BS + gHashSetName_StringList[i]);
              if bmFolder = nil then
                bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SAMPLE + BS + gHashSetName_StringList[i], IntToStr(rnd_bm_int) + '/' + IntToStr(gIncTList.Count));

              // ----------------------------------------------------------------
              // Bookmark the files
              // ----------------------------------------------------------------
              Randomize; // Set the random seed (results will be different each time)
              if assigned(bmFolder) then
              begin
                if assigned(gIncTList) then
                begin
                  if gIncTList.Count <= RANDOM_TO_BOOKMARK_INT then // If < random maximum bookmark all
                  begin
                    if not IsItemInBookmark(eEntry, eEntry) then
                      for k := 0 to gIncTList.Count - 1 do
                      begin
                        etEntry := TEntry(gIncTList[k]);
                        if not IsItemInBookmark(etEntry, etEntry) then
                          AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, etEntry, '')
                      end;
                  end
                  else
                    RandomBookmarkFromTList(gIncTList, RANDOM_TO_BOOKMARK_INT, bmFolder); // Bookmark random sample
                end;
              end;
              CurrentComment := TNoteEntry(bmFolder).Comment;
            end;

          finally
            gIncTList.free;
          end;
        end;
        ConsoleLog(RPad(stringofchar(SPECIALCHAR_HLINE, RPAD_VALUE - 5), RPAD_VALUE) + stringofchar(SPECIALCHAR_HLINE, LINE_LENGTH));
        ConsoleLog(Format('%-34s %5s %1s %5s', [HASHSET_MATCHES + CLN, IntToStr(sum_bm_int), HYPHEN, IntToStr(sum_ex_int)]));
        ConsoleLog(stringofchar('-', CHAR_LENGTH));
      end;

      // Add exclusions to summary report
      if assigned(gMemo_StringList) and (gHashSetName_StringList.Count > 0) then
      begin
        if gbl_exclude_files then
        begin
          ConsoleLog(RPad(HASHSET_MATCHES + SPACE + LB_EXCLUDED_RB + CLN, RPAD_VALUE) + LB + IntToStr(gExcTList.Count) + RB);
          ConsoleLog(RPad(HYPHEN + EXCLUDED_BY_STR + 'Deleted' + CLN, RPAD_VALUE) + IntToStr(gexclude_count_del));
          ConsoleLog(RPad(HYPHEN + EXCLUDED_BY_STR + 'Extension' + CLN, RPAD_VALUE) + IntToStr(gexclude_count_ext));
          ConsoleLog(RPad(HYPHEN + EXCLUDED_BY_STR + 'Min Size' + CLN, RPAD_VALUE) + IntToStr(gexclude_count_min));
          ConsoleLog(RPad(HYPHEN + EXCLUDED_BY_STR + 'Path' + CLN, RPAD_VALUE) + IntToStr(gexclude_count_pth));

          // Sum the above for check purposes
          ConsoleLog(RPad(stringofchar(SPECIALCHAR_HLINE, RPAD_VALUE - 5), RPAD_VALUE) + stringofchar(SPECIALCHAR_HLINE, LINE_LENGTH));
          ConsoleLog(RPad(HASHSET_MATCHES + SPACE + LB_EXCLUDED_RB + CLN, RPAD_VALUE) + IntToStr(gexclude_count_del + gexclude_count_ext + gexclude_count_min + gexclude_count_pth) + SPACE + LB + 'sum' + RB);
          ConsoleLog(stringofchar('-', CHAR_LENGTH));
        end;
      end;

      if assigned(gMemo_StringList) then
      begin
        gMemo_StringList.Insert(0, stringofchar('-', CHAR_LENGTH));
        for j := 0 to gDevice_TList.Count - 1 do
        begin
          devEntry := TEntry(gDevice_TList[j]);
          gMemo_StringList.Insert(0, RPad(SPACE + IntToStr(j + 1) + '.', RPAD_VALUE) + devEntry.EntryName);
        end;
        gMemo_StringList.Insert(0, 'Devices' + CLN);
        gMemo_StringList.Insert(0, trim(gStartSummary_str));

        lnk_to_pdf_report_str := 'file:///' + GetCurrentCaseDir + FLDR_REPORTS + BS + 'Hash Match - Random Sample.pdf'; // This name is in the TXML
        lnk_to_pdf_report_str := StringReplace(lnk_to_pdf_report_str, ' ', '%20', [rfReplaceAll, rfIgnoreCase]); // Replace spaces with %20
        lnk_to_pdf_report_str := StringReplace(lnk_to_pdf_report_str, '\\', '', [rfReplaceAll, rfIgnoreCase]); // Replace leading double backslash
        ConsoleLog(RPad('Link to PDF Report' + CLN, RPAD_VALUE) + lnk_to_pdf_report_str);
        ConsoleLog(stringofchar('-', CHAR_LENGTH));
        if assigned(OutList) then
          Progress.Log(RPad('OutList Count:', RPAD_VALUE) + IntToStr(OutList.Count));
        gMemo_StringList.Add('Finished.');

        // Add the summary.txt as a comment so that it can be used in the report
        bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED);
        if bmFolder <> nil then
          UpdateBookmark(bmFolder, gMemo_StringList.Text);

      end;

      // Save to global
      Progress.Log('Saving summary report to global folder' + RUNNING);
      Progress.DisplayMessageNow := 'Saving summary report to global folder' + RUNNING;
      FexLab_Global_Save(gMemo_StringList, sum_bm_int);

      // Save to local
      Progress.Log('Saving summary report to local folder' + RUNNING);
      Progress.DisplayMessageNow := 'Saving summary report to local folder' + RUNNING;
      if DirectoryExists(GetCurrentCaseDir + FLDR_REPORTS) then
      begin
        try
          Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(GetCurrentCaseDir + FLDR_REPORTS), True), RPAD_VALUE) + GetCurrentCaseDir + FLDR_REPORTS);
          gMemo_StringList.SaveToFile(GetCurrentCaseDir + FLDR_REPORTS + BS + SUMMARY_RPT);
          Sleep(1000);
          ConsoleLog(RPad(SAVED_FILE_STR + SPACE + 'Case Folder' + CLN, RPAD_VALUE) + GetCurrentCaseDir + FLDR_REPORTS + BS + SUMMARY_RPT);
        except
          on e: exception do
          begin
            ConsoleLog(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + e.message);
          end;
        end;
      end;

    finally
      gDevice_TList.free;
      gHashSetName_StringList.free;
      gMemo_StringList.free;
      gParams_StringList.free;
      gExcTList.free;
    end;

    Progress.DisplayMessageNow := 'Script finished.';
    Progress.Log('Script finished.');
  finally
    DataStore_FS.free;
  end;

end.
