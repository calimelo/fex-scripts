unit fex_training_bookmark_params;

interface

uses
  // GUI, Modules,
  Classes, Common, DataEntry, DataStorage, Math, NoteEntry, RegEx, SysUtils;

implementation

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 80;
  DBS = '\\';
  CR = #13#10;
  DCR = #13#10 + #13#10;
  FORMAT_STR1 = '%-34s %-15s %-15s %-15s';
  HYPHEN = ' - ';
  RANDOM_TO_BOOKMARK_INT = 4;
  RPAD_VALUE = 35;
  RUNNING = '...';
  SCRIPT_NAME = 'FEX Training - Final Practical';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

  STR_BMFLDR_ALL = 'All';
  STR_DOC = 'Documents';
  STR_PIC = 'Pictures';
  STR_RANDOM_SAMPLE = 'Random Sample';
  STR_REGEX_TERMS = 'Bird|Cat|Chicken|Croc|Dog|Face|Fish|Sheep|Snake|Squirrel';
  STR_VID = 'Video';

var
  gArrayOfTList: array of TList;
  gLineList: TStringList;
  gparam_str: string;
  gRunTimeReport_StringList: TStringList;
  gStarting_Summary_str: string;

  // ------------------------------------------------------------------------------
  // Procedure: Message User
  // ------------------------------------------------------------------------------
procedure MessageUser(aString: string);
begin
  // MessageBox(aString, SCRIPT_NAME, (MB_OK or MB_ICONINFORMATION or MB_SETFOREGROUND or MB_TOPMOST));
  Progress.Log(aString);
end;

// ------------------------------------------------------------------------------
// Procedure: Console Log
// ------------------------------------------------------------------------------
procedure ConsoleLog(aString: string);
begin
  if assigned(gRunTimeReport_StringList) then
    gRunTimeReport_StringList.Add(aString);
  Progress.Log(aString);
end;

// ------------------------------------------------------------------------------
// Function: Right Pad v2
// ------------------------------------------------------------------------------
function RPad(const aString: string; AChars: integer): string;
begin
  AChars := AChars - Length(aString);
  if AChars > 0 then
    Result := aString + StringOfChar(' ', AChars)
  else
    Result := aString;
end;

// ------------------------------------------------------------------------------
// Function: Parameters Received
// ------------------------------------------------------------------------------
function ParametersReceived: boolean;
var
  i: integer;
begin
  Result := False;
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    ConsoleLog(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      ConsoleLog(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
    end;
  end
  else
  begin
    ConsoleLog(RPad('Params received:', RPAD_VALUE) + '0');
  end;
  ConsoleLog(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Function: Add Button
// ------------------------------------------------------------------------------
// function Button_Add : string;
// const
// ATOOLBAR = 'Training';
// var
// Button: TGDToolBarButton;
// Module: TGDModule;
// module_name_str: string;
// ScriptPath_str: string;
// ToolBar: TGDToolBar;
// begin
// Result := '';
// module_name_str := MODULENAME_BOOKMARKS;
// Module := ModuleManager.ModuleByName(module_name_str);
// ToolBar := Module.FindToolbar(ATOOLBAR);
// ScriptPath_str := CmdLine.Path;
// if Toolbar = nil then // Only create if it does not already exist
// begin
// ToolBar := Module.AddToolbar(ATOOLBAR,24);
// Button := ToolBar.AddButton('FEX' + #13#10 + 'Training', '', '', 50, 74, 74, BTNS_SHOWCAPTION or BTNS_DROPDOWN);
// Button.AddDropMenu('Operation Payback' + HYPHEN + 'Final Practical', ScriptPath_str, 'GUI_BUTTON', 17, BTNS_SHOWCAPTION or BTNS_DROPDOWN);
// Result := module_name_str;
// end;
// end;

// ------------------------------------------------------------------------------
// Procedure: Bookmark This TList
// ------------------------------------------------------------------------------
procedure BookmarkThisTList(here_str: string; type_str: string; abmFolder: string; aTList: TList);
var
  bmCreate: boolean;
  bmEntry: TEntry;
  bmfolder: TEntry;
  bmpath: string;
  i: integer;
begin
  if assigned(aTList) and (aTList.Count > 0) then
  begin
    bmpath := 'Op Payback Final Practical' + BS + here_str + BS + type_str + BS + abmFolder;
    bmCreate := True;
    bmfolder := FindBookmarkByName(bmpath, bmCreate);
    // if assigned(bmFolder) and (aTList.Count > 0) then
    // AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, aTList, '');
    for i := 0 to aTList.Count - 1 do
    begin
      bmEntry := TEntry(aTList[i]);
      if here_str = STR_RANDOM_SAMPLE then
      begin
        if (NumberItemsinBookmark(bmfolder) < RANDOM_TO_BOOKMARK_INT) and (not isItemInBookmark(bmfolder, bmEntry)) then
          AddItemsToBookmark(bmfolder, DATASTORE_FILESYSTEM, bmEntry, '');
      end
      else if not isItemInBookmark(bmfolder, bmEntry) then
        AddItemsToBookmark(bmfolder, DATASTORE_FILESYSTEM, bmEntry, '');
    end;
    UpdateBookmark(bmfolder, IntToStr(NumberItemsinBookmark(bmfolder)));
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Select Random Sample
// ------------------------------------------------------------------------------
procedure RandomSelection(iSampleSize: integer; PopulationList: TList; Sample_TList: TList);
var
  Enum: TEntryEnumerator;
  iRandom: integer;
  iSkipCount: integer;
  rEntry: TEntry;
  Sample_UniqueList: TUniqueListOfEntries;
begin
  Sample_UniqueList := TUniqueListOfEntries.Create;
  try
    Randomize;
    if not Progress.isRunning then
      Exit;
    if assigned(PopulationList) and (PopulationList.Count > 0) then
    begin
      Randomize; // Set the random seed (results will be different each time)
      Progress.Max := iSampleSize;
      iSkipCount := 0;
      repeat
        if not Progress.isRunning then
          Break;
        iRandom := RandomRange(0, PopulationList.Count - 1);
        rEntry := TEntry(PopulationList[iRandom]);
        PopulationList[iRandom] := nil; // Makes the entry nil for the next iteration
        if (rEntry = nil) or Sample_UniqueList.Contains(rEntry) then
        begin
          inc(iSkipCount);
          if iSkipCount > 3 then
            PopulationList.Pack;
        end
        else // Only selects an entry that is not nil
        begin
          Sample_UniqueList.Add(rEntry);
          Progress.IncCurrentProgress;
          // ConsoleLog(format('%-20s %-20s %-50s',[IntToStr(SampleList.Count)+':', IntToStr(iRandom), rEntry.EntryName]));
        end;
      until (Sample_UniqueList.Count = iSampleSize) or (PopulationList.Count = 0);
      Enum := Sample_UniqueList.GetEnumerator;
      while Enum.MoveNext do
      begin
        rEntry := Enum.Current;
        Sample_TList.Add(rEntry);
      end;
    end;
  finally
    Sample_UniqueList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Select Random Sample
// ------------------------------------------------------------------------------
procedure BookmarkRandomSample(astr1: string; astr2: string; astr3: string; aTList: TList);
var
  RandomSample_TList: TList;
begin
  RandomSample_TList := TList.Create;
  try
    RandomSelection(RANDOM_TO_BOOKMARK_INT, aTList, RandomSample_TList);
    if RandomSample_TList.Count > 0 then
    begin
      BookmarkThisTList(astr1, astr2, astr3, RandomSample_TList);
    end;
  finally
    RandomSample_TList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Create_TLists
// ------------------------------------------------------------------------------
procedure Create_TLists(astr1: string; aTList: TList);
var
  anEntry: TEntry;
  i, j: integer;

begin
  if assigned(aTList) and (aTList.Count > 0) then
  begin
    ConsoleLog(format(FORMAT_STR1, ['Creating TList:', astr1, 'LSize', 'LSize']));
    for i := 0 to aTList.Count - 1 do
    begin
      if not Progress.isRunning then
        Break;
      anEntry := TEntry(aTList[i]);

      if RegexMatch(anEntry.EntryName, gparam_str, False) then
      begin
        for j := 0 to gLineList.Count - 1 do
        begin
          if RegexMatch(anEntry.EntryName, gLineList[j], False) then
            gArrayOfTList(j).Add(anEntry);
        end;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Log the TList totals and size
// ------------------------------------------------------------------------------
procedure Log_Pic_TLists;
var
  j, k: integer;
  kEntry: TEntry;
  ls_int64: int64;
begin
  for j := 0 to gLineList.Count - 1 do
  begin
    if gArrayOfTList(j).Count > 0 then
    begin
      ls_int64 := 0;
      for k := 0 to gArrayOfTList(j).Count - 1 do
      begin
        kEntry := TEntry(gArrayOfTList(j)[k]);
        ls_int64 := ls_int64 + kEntry.LogicalSize;
      end;
    end;
    ConsoleLog(format(FORMAT_STR1, [HYPHEN + gLineList[j], IntToStr(gArrayOfTList(j).Count), IntToStr(ls_int64), GetSizeStr(ls_int64)]));
    // ConsoleLog(RPad(HYPHEN + gLineList[j], RPAD_VALUE) + inttostr(gArrayOfTList(j).Count) + inttostr(ls_int64) + SPACE + GetSizeStr(ls_int64));
  end;
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
const
  TSWT = 'The script will terminate.';
  SPACE = ' ';
var
  CaseName: string;
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
  Starting_StringList: TStringList;
  procedure StartingSummary(aString: string);
  begin
    if assigned(Starting_StringList) then
      Starting_StringList.Add(aString);
  end;
  function RPad(aString: string; AChars: integer): string;
  begin
    while Length(aString) < AChars do
      aString := aString + ' ';
    Result := aString;
  end;

begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    ConsoleLog(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  Starting_StringList := TStringList.Create;
  try
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case.' + SPACE + TSWT);
      MessageUser('There is no current case.' + DCR + TSWT);
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module.' + SPACE + TSWT);
      MessageUser('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;
    Result := True;
    gStarting_Summary_str := Starting_StringList.text;
  finally
    StartCheckDataStore.free;
    Starting_StringList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Get Size String
// ------------------------------------------------------------------------------
function GetSizeStr(asize: int64): string;
begin
  if asize >= 1073741824 then
    Result := (format('%1.1n gb', [asize / (1024 * 1024 * 1024)]))
  else if (asize < 1073741824) and (asize > 1048576) then
    Result := (format('%1.1n mb', [asize / (1024 * 1024)]))
  else if asize < 1048576 then
    Result := (format('%1.0n kb', [asize / (1024)]));
end;

// ------------------------------------------------------------------------------
// Function: Calculate Logical Size
// ------------------------------------------------------------------------------
function CalculateLogicalSize(aTList: TList): int64;
var
  anEntry: TEntry;
  i: integer;
begin
  Result := 0;
  for i := 0 to aTList.Count - 1 do
  begin
    anEntry := TEntry(aTList[i]);
    Result := Result + anEntry.LogicalSize;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Calculate Physical Size
// ------------------------------------------------------------------------------
function CalcPhySize(aTList: TList): int64;
var
  anEntry: TEntry;
  i: integer;
begin
  Result := 0;
  for i := 0 to aTList.Count - 1 do
  begin
    anEntry := TEntry(aTList[i]);
    Result := Result + anEntry.PhysicalSize;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Create PDF
// ------------------------------------------------------------------------------
procedure CreateRunTimePDF(aStringList: TStringList; save_name_str: string; font_size_int: integer; DT_In_FileName_bl: boolean);
const
  HYPHEN = ' - ';
var
  CurrentCaseDir: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
  SaveName: string;
begin
  sleep(1000);
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  if DT_In_FileName_bl then
    ExportDateTime := (ExportDate + HYPHEN + ExportTime + HYPHEN)
  else
    ExportDateTime := '';
  SaveName := ExportedDir + ExportDateTime + save_name_str;
  if ExtractFileExt(SaveName) = '' then
    SaveName := SaveName + '.pdf';
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if GeneratePDF(SaveName, aStringList, font_size_int) then
          Progress.Log('Success Creating: ' + SaveName)
      end
      else
        Progress.Log('Failed Creating: ' + SaveName);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Exception creating runtime folder');
    end;
  end
  else
    Progress.Log('There is no current case folder');
end;

// ==============================================================================
// Start of the Script
// ==============================================================================
var
  anEntry: TEntry;
  bl_include: boolean;
  bm_RS_Folder: TEntry;
  // button_str: string;
  DataStore_FS: TDataStore;
  Doc_TList: TList;
  i: integer;
  ls_doc_i64: int64;
  ls_pic_i64: int64;
  ls_vid_i64: int64;
  Param_StringList: TStringList;
  Pic_TList: TList;
  psize_documents_int64: int64;
  psize_pictures_int64: int64;
  psize_video_int64: int64;
  sheep_count: integer;
  theFileDriverInfo: TFileTypeInformation;
  Vid_TList: TList;
  Working_TList: TList;

begin
  Progress.DisplayTitle := SCRIPT_NAME;

  gRunTimeReport_StringList := TStringList.Create;
  try

    if not StartingChecks then
      Exit;

    if not ParametersReceived then
    begin
      gparam_str := STR_REGEX_TERMS;
      ConsoleLog(RPad('Set param string as:', RPAD_VALUE) + gparam_str);
      ConsoleLog(StringOfChar('-', CHAR_LENGTH));
    end
    else
      gparam_str := CmdLine.params[0];

    ConsoleLog(RPad('Random Sample Size:', RPAD_VALUE) + IntToStr(RANDOM_TO_BOOKMARK_INT));
    ConsoleLog(StringOfChar('-', CHAR_LENGTH));

    // button_str := Button_Add;
    // if button_str <> '' then
    // begin
    // MessageUser('A button was added to module:' + SPACE + button_str);
    // Exit;
    // end;

    DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
    if DataStore_FS = nil then
      Exit;

    try
      Working_TList := TList.Create;

      Param_StringList := TStringList.Create;
      Param_StringList.Sorted := True;
      Param_StringList.Duplicates := dupIgnore;

      gLineList := TStringList.Create;
      gLineList.Delimiter := '|';
      gLineList.StrictDelimiter := True;

      try
        if (gparam_str = 'GUI_BUTTON') then
        begin
          gparam_str := STR_REGEX_TERMS;
          Working_TList := DataStore_FS.GetEntireList;
          ConsoleLog(RPad('Running from:', RPAD_VALUE) + 'Toolbar Button');
          ConsoleLog(RPad('Working_TList:', RPAD_VALUE) + IntToStr(Working_TList.Count));
        end
        else
        begin
          if assigned(inList) and (inList.Count > 0) then
          begin
            for i := 0 to inList.Count - 1 do
            begin
              anEntry := TEntry(inList[i]);
              Working_TList.Add(anEntry);
            end;
            ConsoleLog(format(FORMAT_STR1, ['InList Count:', IntToStr(inList.Count), 'LSize', 'LSize']));
          end
          else
          begin
            gparam_str := STR_REGEX_TERMS;
            Working_TList := DataStore_FS.GetEntireList;
            ConsoleLog(RPad('Running from:', RPAD_VALUE) + 'Scripts module');
            ConsoleLog(format(FORMAT_STR1, ['Working_TList:', IntToStr(Working_TList.Count), 'LSize', 'LSize']));
          end;
        end;

        gLineList.DelimitedText := gparam_str;
        setlength(gArrayOfTList, gLineList.Count);

        // Create a TList for each parameter received
        for i := 0 to gLineList.Count - 1 do
          gArrayOfTList[i] := TList.Create;

        // Create TLists for Documents, Pictures, Video
        Doc_TList := TList.Create;
        Pic_TList := TList.Create;
        Vid_TList := TList.Create;

        try
          if assigned(gLineList) and (gLineList.Count > 0) then
          begin

            // Process Working TList
            Progress.Initialize(DataStore_FS.Count, 'Processing' + RUNNING);
            for i := 0 to Working_TList.Count - 1 do
            begin
              if not Progress.isRunning then
                Break;
              anEntry := TEntry(Working_TList[i]);
              theFileDriverInfo := anEntry.FileDriverInfo; // anEntry.DeterminedFileDriverInfo;
              bl_include := False;

              // Graphics Filter
              if dtGraphics in theFileDriverInfo.DriverType then
              begin
                if RegexMatch(anEntry.EntryName, gparam_str, False) and (anEntry.Extension <> '') then
                  bl_include := True;

                if RegexMatch(anEntry.EntryName, 'sheep', False) and (anEntry.Extension <> '') then
                  sheep_count := sheep_count + 1;

              end
              else
                // Documents Filter
                if dtDocument in theFileDriverInfo.DriverType then
                begin
                  if (theFileDriverInfo.ShortDisplayName = 'DocX') or // noslz
                    (theFileDriverInfo.ShortDisplayName = 'XLSX') or // noslz
                    (theFileDriverInfo.ShortDisplayName = 'Excel') or // noslz
                    (theFileDriverInfo.ShortDisplayName = 'Word') then // noslz
                    bl_include := True;
                end
                else
                  // Video Filter
                  if dtVideo in theFileDriverInfo.DriverType then
                  begin
                    bl_include := True;
                  end;

              // Add Included ----------------------------------------------------
              if bl_include then
              begin
                // Add to Documents TList
                if dtDocument in theFileDriverInfo.DriverType then
                  Doc_TList.Add(anEntry);

                // Add to Pictures TList
                if dtGraphics in theFileDriverInfo.DriverType then
                  Pic_TList.Add(anEntry);

                // Add to Videos TList
                if dtVideo in theFileDriverInfo.DriverType then
                  Vid_TList.Add(anEntry);
              end;

              Progress.IncCurrentProgress;
            end;

            // Calculate TList Sizes
            ls_doc_i64 := CalculateLogicalSize(Doc_TList);
            psize_documents_int64 := CalcPhySize(Doc_TList);

            ls_pic_i64 := CalculateLogicalSize(Pic_TList);
            psize_pictures_int64 := CalcPhySize(Pic_TList);

            ls_vid_i64 := CalculateLogicalSize(Vid_TList);
            psize_video_int64 := CalcPhySize(Vid_TList);

            // Logging
            ConsoleLog(format(FORMAT_STR1, [HYPHEN + 'Found' + SPACE + STR_DOC + ':', IntToStr(Doc_TList.Count), IntToStr(ls_doc_i64), GetSizeStr(ls_doc_i64)]));
            ConsoleLog(format(FORMAT_STR1, [HYPHEN + 'Found' + SPACE + STR_PIC + ':', IntToStr(Pic_TList.Count), IntToStr(ls_pic_i64), GetSizeStr(ls_pic_i64)]));
            ConsoleLog(format(FORMAT_STR1, [HYPHEN + 'Found' + SPACE + STR_VID + ':', IntToStr(Vid_TList.Count), IntToStr(ls_vid_i64), GetSizeStr(ls_vid_i64)]));
            // ConsoleLog(RPad(HYPHEN + 'Found' + SPACE + 'Sheep Count' + ':', RPAD_VALUE) + inttostr(sheep_count));
            ConsoleLog(StringOfChar('=', 80));

            // Bookmark Documents-------------------------------------------------
            if assigned(Doc_TList) and (Doc_TList.Count > 0) then
            begin
              ConsoleLog(format(FORMAT_STR1, ['Bookmarking Documents:', IntToStr(Doc_TList.Count), IntToStr(ls_doc_i64), GetSizeStr(ls_doc_i64)]));
              BookmarkThisTList(STR_BMFLDR_ALL, STR_DOC, '', Doc_TList);
              BookmarkRandomSample(STR_RANDOM_SAMPLE, STR_DOC, '', Doc_TList);
              ConsoleLog(StringOfChar('-', CHAR_LENGTH));
            end;

            // Bookmark Pictures -------------------------------------------------
            if assigned(Pic_TList) and (Pic_TList.Count > 0) then
            begin
              ConsoleLog(RPad('Bookmarking Pictures:', RPAD_VALUE) + IntToStr(Pic_TList.Count));
              Create_TLists(STR_PIC, Pic_TList);

              // Log Picture TList Counts
              Log_Pic_TLists;

              // Bookmarks the TList ---------------------------------------------
              for i := 0 to gLineList.Count - 1 do
                BookmarkThisTList(STR_BMFLDR_ALL, STR_PIC, gLineList[i], gArrayOfTList(i));

              for i := 0 to gLineList.Count - 1 do
                BookmarkRandomSample(STR_RANDOM_SAMPLE, STR_PIC, gLineList[i], gArrayOfTList(i));

              // Clear TLists
              for i := 0 to gLineList.Count - 1 do
                gArrayOfTList(i).Clear;
              ConsoleLog(StringOfChar('-', CHAR_LENGTH));
            end;

            // Bookmark Video ----------------------------------------------------
            if assigned(Vid_TList) and (Vid_TList.Count > 0) then
            begin
              ConsoleLog(format(FORMAT_STR1, ['Bookmarking Video:', IntToStr(Vid_TList.Count), IntToStr(ls_vid_i64), GetSizeStr(ls_vid_i64)]));
              BookmarkThisTList(STR_BMFLDR_ALL, STR_VID, '', Vid_TList);
              BookmarkRandomSample(STR_RANDOM_SAMPLE, STR_VID, '', Vid_TList);
              ConsoleLog(StringOfChar('-', CHAR_LENGTH));
            end;

            bm_RS_Folder := FindBookmarkByName(STR_RANDOM_SAMPLE);
            if assigned(bm_RS_Folder) then
              UpdateBookmark(bm_RS_Folder, IntToStr(RANDOM_TO_BOOKMARK_INT));

          end;

        finally
          for i := 0 to gLineList.Count - 1 do
            gArrayOfTList[i].free;
          Doc_TList.free;
          Pic_TList.free;
          Vid_TList.free;
        end;

        CreateRunTimePDF(gRunTimeReport_StringList, SCRIPT_NAME, 10, False); // True is DT in Filename.PDF

      finally
        gLineList.free;
        Param_StringList.free;
        Working_TList.free;
      end;

    finally
      DataStore_FS.free;
    end;

  finally
    gRunTimeReport_StringList.free;
  end;

  Progress.Log('Script finished.');

end.
