unit Bookmark_Keyword_Search;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, NoteEntry, Regex, SysUtils;

const
  BM_FOLDER_SCRIPT_OUTPUT = 'FEX-Triage';
  BM_KEYWORD_SEARCH = 'Keyword Search';
  BS = '\';
  DBS = '\\';
  SPACE = ' ';
  TSWT = 'The script will terminate.';
  ARRAY_LENGTH = 50000000;
  RPAD_VALUE = 30;
  CHAR_LENGTH = 80;
  PAD_VALUE = 20;
  
var
  gFinal_StringList: TStringList;  

implementation

type
  Item_Record = class
    minnie : string;
  end;
  
//------------------------------------------------------------------------------
// Procedure: ConsoleLogMemo
//------------------------------------------------------------------------------
procedure ConsoleLogMemo(AString: string);
begin
  Progress.Log(AString);
  if assigned(gFinal_StringList) and (gFinal_StringList.Count < 5000) then
    gFinal_StringList.Add(AString);
end;  

//------------------------------------------------------------------------------
// Function: Parameters Received
//------------------------------------------------------------------------------
function ParametersReceived : boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  Progress.Log(Stringofchar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    param_str := '';
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + cmdline.params[i]);
      param_str := param_str + '"' + cmdline.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
    Progress.Log('No parameters were received.');
  Progress.Log(Stringofchar('-', 80));
end;

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

//------------------------------------------------------------------------------
// Function: Get the expand parent entry
//------------------------------------------------------------------------------
function GetParentExapndedEntry(anEntry: TEntry) : TEntry;
var
   CurrentEntry: TEntry;
begin
  Result := nil;
  CurrentEntry := anEntry;
  while assigned(CurrentEntry) and not (dstExpanded in CurrentEntry.Status) do
  begin
    CurrentEntry := TEntry(CurrentEntry.parent);
  end;
  Result := CurrentEntry;
end;

//------------------------------------------------------------------------------
// Function: Hit Count
//------------------------------------------------------------------------------
function hitcount(aDataStore: TDataStore; hit_Entry: TEntry) : integer;
var
  the_hits_count: integer;
  HitCountDataField: TDataStoreField;
  field_Hits_str: string;
begin
  if aDataStore = nil then
    Exit;
  HitCountDataField := aDataStore.DataFields.FieldbyName['HITCOUNT'];
  if assigned(HitCountDataField) then
  begin
    the_hits_count := 0;
    field_Hits_str := HitCountDataField.AsString[hit_Entry];
    the_hits_count := the_hits_count + StrToInt(field_Hits_str);
    Result := the_hits_count;
  end;
end;

//------------------------------------------------------------------------------
// Function: Sort by Count
//------------------------------------------------------------------------------
function MySortProc(List: TStringList; Index1, Index2: Integer): integer;
var
  Value1, Value2: integer;
begin
  Value1 := StrToInt(List[Index1]);
  Value2 := StrToInt(List[Index2]);
  if Value1 < Value2 then
    Result := -1
  else if Value2 < Value1 then
    Result := 1
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
// Function: Create PDF
//------------------------------------------------------------------------------
procedure CreatePDF(aStringList: TStringList; FileSaveName_str: string; font_size: integer);
var
  CurrentCaseDir: string;
  SaveDir: string;
begin
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  CurrentCaseDir := GetCurrentCaseDir;
  SaveDir := CurrentCaseDir + 'Reports\Run Time Reports\';
  if assigned(aStringList) and (aStringList.Count > 0) then
  begin
    if ForceDirectories(IncludeTrailingPathDelimiter(SaveDir)) and DirectoryExists(SaveDir) then
    begin
      if GeneratePDF(SaveDir + FileSaveName_str, aStringList, font_size) then
        Progress.Log('Saved: ' + SaveDir + FileSaveName_str)
      else
        Progress.Log('Failed to save: ' + SaveDir + FileSaveName_str);
    end
    else
      Progress.Log('Could not find folder: ' + SaveDir);
  end;
end;

//------------------------------------------------------------------------------
// Remove Keyword Bookmark Folders with 0 Hits
//------------------------------------------------------------------------------
function Remove_Empty_Keyword_Bookmark_Folders : string;
var
  Entry: TEntry;
  EntryList: TDataStore;
  res: integer;
  FolderChildren_TList: TList;
  akeyword_str: string;

begin
  EntryList := GetDataStore(DATASTORE_BOOKMARKS);
  if not assigned(EntryList) then
    Exit;

  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  Progress.Log('Removing empty keyword folders...');
  Result := '';

  try
    if EntryList.Count = 0 then
      Exit;

    if CmdLine.ParamCount > 0 then
    begin
      akeyword_str := RPad('Keyword', 45) + 'Files Found';
      akeyword_str := akeyword_str + #13#10 + RPad('-------', 45) + '-----------';
      Entry := EntryList.First;
      while assigned(Entry) and Progress.isRunning do
      begin
        if (dstUserCreated in Entry.Status) and RegexMatch(Entry.Directory, BM_FOLDER_SCRIPT_OUTPUT + DBS + BM_KEYWORD_SEARCH + DBS + CmdLine.Params[0], False) then
        begin
          FolderChildren_TList := EntryList.Children(Entry, True); // True sets the .Children to be full recursive
          try
            akeyword_str := akeyword_str + #13#10 + RPad(Entry.EntryName, 45) + IntToStr(FolderChildren_TList.Count);
            if FolderChildren_TList.Count = 0 then
            begin
              res := EntryList.Remove(Entry);
              if res > 0 then
                Progress.Log('Removed ' + IntToStr(res) + ' items: ' + Entry.EntryName)
              else if res = 0 then
                Progress.Log('Nothing removed. Only user created items can be removed.')
              else
                Progress.Log('Nothing removed. Error code = ' + IntToStr(res) + ' ' + Entry.EntryName);
            end;
          finally
            FolderChildren_TList.free;
          end;
        end;
        Entry := EntryList.Next;
      end;
    end
    else
      Progress.Log('Did not receive parameters.');
  finally
    EntryList.free;
  end;
  Progress.Log(akeyword_str);
  Result := akeyword_str;
end;

//------------------------------------------------------------------------------
// Start of Script
//------------------------------------------------------------------------------
var
  anEntry: TEntry;
  anEntryList: TDataStore;
  bmFolder: TEntry;
  childEntry: TEntry;
  FolderChildren_TList: TList;
  HitOffsetDataField: TDataStoreField;
  HitLengthDataField: TDataStoreField;
  HitCountDataField: TDataStoreField;
  i, j: integer;
  TheExpandedEntry: TEntry;
  CountArray: array of integer;
  FilenameArray: array of string;
  TrackArrayPositionsUsed_StringList: TStringList;
  results_StringList: TStringList;
  array_pos_int: integer;
  ARec: Item_Record;
  keyword_count: integer;
  keywords_str: string;

begin
  ParametersReceived;
  SetLength(CountArray, ARRAY_LENGTH);
  SetLength(FilenameArray, ARRAY_LENGTH);

  anEntryList := GetDataStore(DATASTORE_KEYWORDSEARCH);
  if not assigned(anEntryList) then
  begin
    Progress.Log('Not assigned a data store.' + SPACE + TSWT);
    Exit;
  end;

  anEntry := anEntryList.First;
  if not assigned(anEntry) then
  begin
    Progress.Log('No entries in the data store.' + SPACE + TSWT);
    anEntryList.free;
    Exit;
  end;

  // Set Fields
  HitOffsetDataField := anEntryList.DataFields.FieldByName['HITOFFSET'];
  HitLengthDataField := anEntryList.DataFields.FieldByName['HITLENGTH'];
  HitCountDataField := anEntryList.DataFields.FieldByName['HITCOUNT'];

  FolderChildren_TList := TList.Create;
  results_StringList := TStringList.Create;
  gFinal_StringList := TStringList.Create;
  TrackArrayPositionsUsed_StringList := TStringList.Create;
  TrackArrayPositionsUsed_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
  TrackArrayPositionsUsed_StringList.Duplicates := dupIgnore;

  try

    anEntry := anEntryList.First;    
    while assigned(anEntry) and (Progress.isRunning) do
    begin
      if anEntry.IsDirectory and (anEntry.dirlevel >= 2) then
        keyword_count := keyword_count + 1;
      anEntry := anEntryList.Next;
    end;
    
    if keyword_count = 0 then
    begin
      gFinal_StringList.Add('No keywords were located.');
      gFinal_StringList.Add('In FEX-Triage, go to the Select Profile window and "Edit" this profile to add keywords.');      
      CreatePDF(gFinal_StringList, 'Error - No Keywords Were Entered.pdf', 8);
      Exit;
    end;

    anEntry := anEntryList.First;
    Progress.Initialize(keyword_count, 'Processing...');
    ConsoleLogMemo('Number of keyword hits found per file (sorted high to low, max 100 files listed per keyword):');
    ConsoleLogMemo(' ');
    ConsoleLogMemo(Stringofchar('-', CHAR_LENGTH));

    // Work on each keyword (identified by the keyword folder) - Brett
    while assigned(anEntry) and (Progress.isRunning) do
    begin

      if anEntry.IsDirectory and (anEntry.dirlevel >= 2) then
      begin
        ConsoleLogMemo(RPad('Located Keyword:', PAD_VALUE) + anEntry.EntryName);
        FolderChildren_TList := anEntryList.Children(anEntry, True); // True sets the .Children to be full recursive

        // Need to create the Bookmark folder using the Search Term, not just the 'Display' name of the folder
        bmFolder := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + BS + BM_KEYWORD_SEARCH + BS + anEntry.Parent.EntryName + BS + anEntry.EntryName);
        if bmFolder = nil then
          bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + BS + BM_KEYWORD_SEARCH + BS + anEntry.Parent.EntryName + BS + anEntry.EntryName);

        // Work on the Children ------------------------------------------------
        for i := 0 to FolderChildren_TList.Count -1 do
        begin
          if not Progress.isRunning then
            Break;

          childEntry := TEntry(FolderChildren_TList[i]);

          // If the child is inExpanded then bookmark the compound parent only
          if TEntry(childEntry.BaseEntry).InExpanded then
          begin
            TheExpandedEntry := GetParentExapndedEntry(TEntry(childEntry.BaseEntry));
            if assigned(TheExpandedEntry) then
            begin

              // Add to the Arrays
              CountArray(TheExpandedEntry.ID) := CountArray(TheExpandedEntry.ID) + hitcount(anEntryList, childEntry);
              FileNameArray(TheExpandedEntry.ID) := TheExpandedEntry.EntryName;
              TrackArrayPositionsUsed_StringList.Add(IntToStr(TheExpandedEntry.ID));

              // Bookmark the expanded file
              if not IsItemInBookmark(bmFolder, TheExpandedEntry) then
                AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, TheExpandedEntry, '')

            end;
          end
          else
          begin
            // If the child is not not inExpanded then just bookmark the file
            if not IsItemInBookmark(bmFolder, childEntry) then
              AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, childEntry, '');

            // Add to the Arrays
            CountArray(childEntry.ID) := hitcount(anEntryList, childEntry);
            FileNameArray(childEntry.ID) := childEntry.EntryName;
            TrackArrayPositionsUsed_StringList.Add(IntToStr(childEntry.ID));
          end;
        end; {work on children}


        // Add the used array locations to the results StringList
        for i := 0 to TrackArrayPositionsUsed_StringList.Count -1 do
        begin
          if not Progress.isRunning then
            Break;

          array_pos_int := -1;
          try
            array_pos_int := StrToInt(TrackArrayPositionsUsed_StringList[i]);
          except
            ConsoleLogMemo('Error: Could not convert str to int');
            Exit;
          end;
          if (array_pos_int >= low(CountArray)) and (array_pos_int <= high(CountArray)) then
          begin
            ARec := Item_Record.Create;
            ARec.minnie := (FilenameArray(array_pos_int));
            results_StringList.AddObject(IntToStr(CountArray(array_pos_int)), TObject(ARec));
          end;
        end;

        // Sort the results by the highest number of hits
        results_StringList.CustomSort(MySortProc);

        j := 0;
        if results_StringList.Count > 100 then
        begin
          for i := results_StringList.Count -1 downto (results_StringList.Count - 100) do
          begin
            ConsoleLogMemo(RPad({IntToStr(j) + ':' + SPACE + }results_StringList(i) + ' times in:', PAD_VALUE) + Item_Record(results_StringList.Objects[i]).minnie);
            Inc(j);
          end;
        end
        else
        for i := results_StringList.Count -1 downto 0 do
        begin
          ConsoleLogMemo(RPad({IntToStr(j) + ':' + SPACE + }results_StringList(i) + ' times in:', PAD_VALUE) + Item_Record(results_StringList.Objects[i]).minnie);
          Inc(j);
        end;

        if results_StringList.Count = 0 then
        begin
          ConsoleLogMemo({IntToStr(j) + ':' + SPACE + }'0 times.');
        end;

        results_StringList.Clear;

        // Get the used array locations from the StringList. Convert them to int and use them to null the used array positions.
        for i := 0 to TrackArrayPositionsUsed_StringList.Count -1 do
        begin
          if not Progress.isRunning then Break;

          array_pos_int := 0;
          try
            array_pos_int := StrToInt(TrackArrayPositionsUsed_StringList[i]);
          except
            ConsoleLogMemo('Error: Could not convert str to int');
          end;

          if (array_pos_int >= low(CountArray)) and (array_pos_int <= high(CountArray)) then
            CountArray(array_pos_int) := null;

        end;

        // Clear the array positions StringList
        TrackArrayPositionsUsed_StringList.Clear;

        ConsoleLogMemo(' ');
        ConsoleLogMemo(Stringofchar('-', CHAR_LENGTH));

      end;
      Progress.IncCurrentProgress;
      anEntry := anEntryList.Next;

    end; {end work on each keyword}

    CreatePDF(gFinal_StringList, 'Report - Keywords by Count.pdf', 8);

    keywords_str := Remove_Empty_Keyword_Bookmark_Folders;

    if CmdLine.ParamCount > 0 then
    begin
      bmFolder := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + BS + BM_KEYWORD_SEARCH + BS + CmdLine.Params[0]);
      if bmFolder <> nil then
        UpdateBookmark(bmFolder, trim(keywords_str))
      else
        Progress.Log('Could not locate bookmark folder to update bookmark comment.');
    end;

  finally
    anEntryList.free;
    FolderChildren_TList.free;
    TrackArrayPositionsUsed_StringList.free;
    results_StringList.free;
    gFinal_StringList.free;
  end;

  Progress.Log(' ');
  Progress.Log('Script finished');
end.