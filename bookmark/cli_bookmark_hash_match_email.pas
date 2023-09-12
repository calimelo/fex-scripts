unit bookmark_hash_match_with_random_selection;

interface

uses
  Classes, Common, DataEntry, DataStorage, NoteEntry, RegEx, SysUtils, Math;

implementation

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BM_FLDR_HASH_MATCHED = 'Hash Matched Email';
  BM_FLDR_HASH_MATCHED_RANDOM_SELECTION = 'Hash Matched - Random Selection';
  BM_FLDR_ROOT = 'Hash Match';
  BS = '\';
  CHAR_LENGTH = 80;
  CLN = ':';
  DBS = '\\';
  FLDR_GLB = '\\Fexlabs\share\Global_Output\HASH_MATCH';
  HYPHEN = ' - ';
  HYPHEN_NS = '-';
  RANDOM_TO_BOOKMARK_INT = 5;
  RPAD_VALUE = 35;
  RUNNING = '...';
  SCRIPT_NAME = 'Bookmark Hash Match with Random Selection';
  SPACE = ' ';

var
  gCaseName: string;
  gDevice_TList: TList;
  gHashSetName_StringList: TStringList;
  gMemo_StringList: TStringList;
  gStartSummary_str: string;
  gTheDatastore: string;

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
        dTList.add(dEntry);
      dEntry := DataStore_EV.next;
    end;
  finally
    DataStore_EV.free;
  end;
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
          if bmfEntry.IsDirectory and (RegexMatch(bmfEntry.FullPathName, BM_FLDR_ROOT + DBS + BM_FLDR_HASH_MATCHED + DBS, False)) then
          begin
            ExistingFolders_StringList.add(bmfEntry.EntryName);
            ExistingFolders_TList.add(bmfEntry);
            FolderDelete_TList.add(bmfEntry);
          end;
          bmfEntry := BmDataStore.next;
        end;
        BmDataStore.close;
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
          SampleList.add(bEntry);
          Progress.IncCurrentProgress;
          // Progress.Log(format('%-20s %-20s %-50s',[IntToStr(SampleList.Count) + CLN, IntToStr(iRandom), bEntry.EntryName]));
          if not IsItemInBookmark(bFolder, bEntry) then
            AddItemsToBookmark(bFolder, gTheDatastore, bEntry, '');
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
function FexLab_Global_Save(aStringList: TStringList): boolean;
var
  ExportDate: string;
  ExportDateTime: string;
  ExportTime: string;
  FexLab_Global_Fnm_str: string;
  FexLab_Global_Pth_str: string;
  the_dev_str: string;

begin
  Result := False;
  // Test for Global folder
  if DirectoryExists(FLDR_GLB) then
  begin
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
    FexLab_Global_Fnm_str := GetUniqueFileName('Hash Match' + HYPHEN + gCaseName + HYPHEN + the_dev_str + '.txt');

    // Create the folder and save the file
    FexLab_Global_Pth_str := FLDR_GLB + BS + FexLab_Global_Fnm_str;
    if ForceDirectories(IncludeTrailingPathDelimiter(FLDR_GLB)) and DirectoryExists(FLDR_GLB) then
      aStringList.SaveToFile(FexLab_Global_Pth_str);
    Sleep(1000);

    // Test to see if the file was saved
    if FileExists(FexLab_Global_Pth_str) then
    begin
      Progress.Log(RPad('Saved File (FEXLAB Global)' + CLN, RPAD_VALUE) + FexLab_Global_Pth_str);
      gMemo_StringList.add(FLDR_GLB + BS + 'reports' + BS + FexLab_Global_Fnm_str);
      Result := True;
    end;
  end;
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
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
  StartCheckDataStore := GetDataStore(gTheDatastore);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(gTheDatastore + ' module not located.' + SPACE + TSWT);
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
      Start_StringList.add(Stringofchar('-', CHAR_LENGTH));
      Start_StringList.add(RPad('Case Name' + CLN, RPAD_VALUE) + gCaseName);
      Start_StringList.add(RPad('Script Name' + CLN, RPAD_VALUE) + SCRIPT_NAME);
      Start_StringList.add(RPad('Date Run' + CLN, RPAD_VALUE) + DateTimeToStr(now));
      Start_StringList.add(RPad('FEX Version' + CLN, RPAD_VALUE) + CurrentVersion);
      Start_StringList.add(Stringofchar('-', CHAR_LENGTH));
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

// ==============================================================================
// Start of the Script
// ==============================================================================
var
  anEntry: TEntry;
  bmFolder: TEntry;
  colResult: string;
  Column: TDataStoreField;
  CurrentComment: string;
  DataStore: TDataStore;
  devEntry: TEntry;
  i, j, idx: integer;
  LineList: TStringList;
  lnk_to_file_str: string;
  rnd_bm_int: integer;
  tot_bm_int: integer;

begin
  gTheDatastore := DATASTORE_EMAIL;

  if not StartingChecks then
    Exit;

  Column := nil;
  DataStore := GetDataStore(gTheDatastore);
  if DataStore = nil then
    Exit;

  try
    Column := DataStore.DataFields.FieldByName('HASHSET'); // noslz
    if Column = nil then
      Exit;

    Progress.Log(RPad('Max random selection' + CLN, RPAD_VALUE) + IntToStr(RANDOM_TO_BOOKMARK_INT));
    Progress.Log(Stringofchar('-', CHAR_LENGTH));

    DeleteExistingBookmarkFolders;

    gMemo_StringList := TStringList.Create;
    gHashSetName_StringList := TStringList.Create;
    gHashSetName_StringList.Sorted := True;
    gHashSetName_StringList.Duplicates := dupIgnore;
    LineList := TStringList.Create;
    LineList.Delimiter := ',';
    LineList.QuoteChar := '"';
    LineList.StrictDelimiter := True;
    gDevice_TList := TList.Create;

    try
      GetDeviceTList(gDevice_TList);

      Progress.Initialize(DataStore.Count, 'Collecting HashSet names' + RUNNING);
      anEntry := DataStore.First;
      while assigned(anEntry) and assigned(Column) do
      begin
        colResult := Column.AsString[anEntry];
        if colResult <> '' then
        begin
          LineList.CommaText := Column.AsString[anEntry];
          for i := 0 to LineList.Count - 1 do
          begin
            idx := gHashSetName_StringList.add(LineList[i]);
            if not assigned(gHashSetName_StringList.Objects[idx]) then
              gHashSetName_StringList.Objects[idx] := TList.Create;
            TList(gHashSetName_StringList.Objects[idx]).add(anEntry);
          end;
        end;
        anEntry := DataStore.next;
        Progress.IncCurrentProgress;
      end;
      Progress.Log(RPad('Unique HashSet names' + CLN, RPAD_VALUE) + IntToStr(gHashSetName_StringList.Count));

      // Create bookmark folder using hash set names
      if assigned(gHashSetName_StringList) and (gHashSetName_StringList.Count > 0) then
      begin
        for i := 0 to gHashSetName_StringList.Count - 1 do
        begin
          if not Progress.isRunning then
            Break;

          rnd_bm_int := RANDOM_TO_BOOKMARK_INT;
          tot_bm_int := TList(gHashSetName_StringList.Objects[i]).Count;
          if tot_bm_int < rnd_bm_int then
            rnd_bm_int := tot_bm_int;

          // --------------------------------------------------------------------
          // Create bookmark folders for all hash matched files
          // --------------------------------------------------------------------
          // Create the Hash Match parent bookmark folder
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED);
          CurrentComment := '';

          // Create the hash set name bookmark folders
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + BS + gHashSetName_StringList[i]);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED + BS + gHashSetName_StringList[i], ''); // 'Hash Set Name: ' + gHashSetName_StringList[i]);

          AddItemsToBookmark(bmFolder, gTheDatastore, TList(gHashSetName_StringList.Objects[i]), '');

          // --------------------------------------------------------------------
          // Create bookmark folders for reporting purposes
          // --------------------------------------------------------------------
          // Create the reporting bookmark parent folder
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SELECTION);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SELECTION, IntToStr(RANDOM_TO_BOOKMARK_INT));
          CurrentComment := '';

          // Create the hash set name reporting bookmark folders
          bmFolder := FindBookmarkByName(BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SELECTION + BS + gHashSetName_StringList[i]);
          if bmFolder = nil then
            bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FLDR_ROOT + BS + BM_FLDR_HASH_MATCHED_RANDOM_SELECTION + BS + gHashSetName_StringList[i], IntToStr(rnd_bm_int) + '/' + IntToStr(tot_bm_int));

          if tot_bm_int > 0 then
            gMemo_StringList.add(RPad(gHashSetName_StringList[i] + CLN, RPAD_VALUE) + IntToStr(tot_bm_int));

          // --------------------------------------------------------------------
          // Bookmark the files
          // --------------------------------------------------------------------
          Randomize; // Set the random seed (results will be different each time)
          if assigned(bmFolder) then
          begin
            if assigned(gHashSetName_StringList.Objects[i]) then
            begin
              if TList(gHashSetName_StringList.Objects[i]).Count <= RANDOM_TO_BOOKMARK_INT then // If < random maximum bookmark all
                AddItemsToBookmark(bmFolder, gTheDatastore, TList(gHashSetName_StringList.Objects[i]), '')
              else
                RandomBookmarkFromTList(TList(gHashSetName_StringList.Objects[i]), RANDOM_TO_BOOKMARK_INT, bmFolder); // Bookmark random selection
            end;
          end;
          CurrentComment := TNoteEntry(bmFolder).Comment;
        end;
      end;

      if gMemo_StringList.Count > 0 then
      begin
        gMemo_StringList.Insert(0, 'Hash Match' + CLN);
        gMemo_StringList.Insert(0, Stringofchar('-', CHAR_LENGTH));
        for j := 0 to gDevice_TList.Count - 1 do
        begin
          devEntry := TEntry(gDevice_TList[j]);
          gMemo_StringList.Insert(0, RPad(IntToStr(j + 1) + '.', RPAD_VALUE) + devEntry.EntryName);
        end;
        gMemo_StringList.Insert(0, 'Devices' + CLN);
        gMemo_StringList.Insert(0, trim(gStartSummary_str));
        gMemo_StringList.add(Stringofchar('-', CHAR_LENGTH));

        // lnk_to_file_str := 'file://' + GetCurrentCaseDir + 'Reports' + BS + 'Hash Match' + HYPHEN + gCaseName + '.pdf'; // If %CASE_NAME% is used in the TXML
        lnk_to_file_str := 'file://' + GetCurrentCaseDir + 'Reports' + BS + 'Hash Match - Random Selection.pdf'; // This name is in the TXML
        lnk_to_file_str := StringReplace(lnk_to_file_str, ' ', '%20', [rfReplaceAll, rfIgnoreCase]); // Replace spaces with %20
        lnk_to_file_str := StringReplace(lnk_to_file_str, '\\', '', [rfReplaceAll, rfIgnoreCase]); // Replace leading double backslash

        gMemo_StringList.add(RPad('Link to PDF Report' + CLN, RPAD_VALUE) + lnk_to_file_str);
        gMemo_StringList.add(Stringofchar('-', CHAR_LENGTH));
        gMemo_StringList.add('Finished.');
        Progress.Log(gMemo_StringList.Text);

        // Save to Global Folder
        FexLab_Global_Save(gMemo_StringList);
      end;

    finally
      gDevice_TList.free;
      gHashSetName_StringList.free;
      gMemo_StringList.free;
    end;

    Progress.Log('Script finished');
  finally
    DataStore.free;
  end;

end.
