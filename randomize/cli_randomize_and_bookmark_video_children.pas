unit bookmark_video_keyframes;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

implementation

const
  BS = '\';
  FORMAT_STR = '%-21s %-20s %-50s';
  KEY_FRAMES = '\Key Frames';
  MAX_SAMPLE_SIZE_INT = 20; // This is the override max. Only used if txml param is greater than this value.
  MY_BOOKMARKS = 'My Bookmarks';
  RANDOM_SAMPLE_STR = 'Random Sample';
  REF = ' - Ref: ';
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Bookmark random sample video key-frames';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

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
// Function: Parameters Received (Exception: [0] = number to random bookmark, [1] = Original bookmark folder
//------------------------------------------------------------------------------
function params : boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  param_str := '';
  Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
  if (CmdLine.ParamCount >= 2) then
  begin
    Result := True;
    
    // Log Params
    Progress.Log(Stringofchar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + cmdline.params[i]);
      param_str := param_str + '"' + cmdline.params[i] + '"' + ' ';
    end;
    trim(param_str);

    // Check to see that param 0 is an integer
    try
      StrToInt(CmdLine.Params[0]);
    except
      Progress.Log('Exception: Could not convert param 0 from str to int.');
      Result := False;
    end;

  end
  else
  begin
    Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + (IntToStr(CmdLine.ParamCount)));
    Result := False;
  end;
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Function: Make sure the InList and OutList exist
//------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string) : boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

//------------------------------------------------------------------------------
// Start of the script
//------------------------------------------------------------------------------
var
  anEntry: TEntry;
  FileSystem_DataStore: TDatastore;
  bm_comment_str: string;
  bmFileFldr: TEntry;
  bm_folder_name_str: string;
  bmFolder: TEntry;
  bmKeyFramesFldr: TEntry;
  bmVideoFldr: TEntry;
  bookmark_this_TList: TList;
  Entry: TEntry;
  EntryChildren_TList: TList;
  Enum: TEntryEnumerator;
  i: integer;
  iRandom: integer;
  iSampleSize: integer;
  iSampleSize_temp: integer;
  iSkipCount: integer;
  PopulationList: TList;
  random_selection_bl: boolean;
  rEntry: TEntry;
  SampleList: TUniqueListOfEntries;
  //theFileDriverInfo: TFileTypeInformation;

begin
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  // Check params received: [0] = number to random bookmark, [1] = Original bookmark folder
  if not params then
    Exit;

  // Locate the bookmark folder. If folder not present, create it. Create it upfront so that it can report 0 if nothing found.
  bm_folder_name_str := CmdLine.Params[1];
  bmFolder := FindBookmarkByName(bm_folder_name_str);
  if bmFolder = nil then
  begin
    bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), bm_folder_name_str, 'Total files found: 0');
    if assigned(bmFolder) then
    begin
      Progress.Log('Bookmark folder created: ' + bmFolder.FullPathName);
    end
    else
    begin
      Progress.Log('Bookmark folder not created');
    end;
    Progress.Log(' ');
  end
  else
  begin
    Progress.Log('Bookmark folder already exists: ' + bmFolder.FullPathName);
    UpdateBookmark(bmFolder, 'Total files found: 0');
    Progress.Log(' ');
  end;

  // Check that InList and OutList exist and that InList is not empty
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    Exit;

  PopulationList := TList.Create;
  FileSystem_DataStore := GetDataStore(DATASTORE_FILESYSTEM);

  // Used for GUI Testing - Add items to InList (MTH as evidence)
//  anEntry := FileSystem_DataStore.First;
//  while assigned(anEntry) and (Progress.isRunning) do
//  begin
//    theFileDriverInfo := anEntry.FileDriverInfo;
//    if (dtVideo in theFileDriverInfo.DriverType) then
//    begin
//      Progress.Log(anEntry.EntryName);
//      if RegexMatch(anEntry.EntryName, 'sheep.*\.mov$|carlos.*\.jpg', False) then
//        InList.Add(anEntry);
//    end;
//    anEntry := FileSystem_DataStore.Next;
//  end;

  if InList.Count <= 0 then
  begin
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Exit;
  end;

  try

    // Because we use Pack we need to convert the InList to a TList
    for i := 0 to InList.Count - 1 do
    begin
      Entry := TEntry(InList[i]);
      PopulationList.Add(Entry);
    end;

    // Cannot proceed without a PopulationList
    if PopulationList.Count <= 0 then
    begin
      Progress.Log('PopulationList count is zero.' + SPACE + TSWT);
      Exit;
    end;

    // Make sure the bookmark folder exists
    if assigned(bmFolder) and (CmdLine.ParamCount > 0) then
    begin

      // Over-ride TXML and set hard max
      iSampleSize := StrToInt(CmdLine.Params[0]);
      if iSampleSize >= MAX_SAMPLE_SIZE_INT then
      begin
        iSampleSize := MAX_SAMPLE_SIZE_INT;
        Progress.Log('Over-ride TXML and set max iSampleSize to: ' + IntToStr(MAX_SAMPLE_SIZE_INT));
      end;

      Progress.Log(RPad('PopulationList:', RPAD_VALUE) + IntToStr(PopulationList.Count));
      Progress.Log(RPad('Sample Size:', RPAD_VALUE) + IntToStr(iSampleSize));
      iSampleSize_temp := iSampleSize;

      // Add summary information to the bookmark folder for use in the report
      if random_selection_bl then
        bm_comment_str := 'This is a random selection of' + SPACE + IntToStr(iSampleSize) + SPACE + 'files from' + SPACE + IntToStr(PopulationList.Count) + SPACE + 'found.'
      else
        bm_comment_str := 'Total files found:' + SPACE + IntToStr(PopulationList.Count);      

      // Overwrite the default 0 bookmark comment
      if bmFolder <> nil then
        UpdateBookmark(bmFolder, bm_comment_str);

      if assigned(PopulationList) and (PopulationList.Count > 0) then
      begin
        for i := 0 to PopulationList.Count -1 do
        begin

          if not Progress.isRunning then
            Break;
            
          iSampleSize := iSampleSize_temp;            

          anEntry := TEntry(PopulationList[i]);
          SampleList := TUniqueListOfEntries.Create;

          Progress.Log(anEntry.EntryName);

          // Create the FEX-Triage\Filename Search - Child Protection\Video folder to hold the results
          bmVideoFldr := FindBookmarkByName(bm_folder_name_str);
          if bmVideoFldr = nil then
            bmVideoFldr := NewBookmark(FindBookmarkByName(MY_BOOKMARKS), bm_folder_name_str);

          // Create the entry Folder + Bates: ### to make it unique
          bmKeyFramesFldr := FindBookmarkByName(bmVideoFldr, anEntry.EntryName + REF + (IntToStr(anEntry.ID)) + KEY_FRAMES);
          if bmKeyFramesFldr = nil then
          begin
            bmKeyFramesFldr := NewBookmark(bmVideoFldr, anEntry.EntryName + REF + (IntToStr(anEntry.ID)) + KEY_FRAMES);
            //AddItemsToBookmark(bmKeyFramesFldr, DATASTORE_FILESYSTEM, anEntry, ''); // Add the parent when bmVideoFolder is created
          end;

          bmFileFldr := FindBookmarkByName(bmVideoFldr, anEntry.EntryName + REF + (IntToStr(anEntry.ID)));
          if bmFileFldr <> nil then
          begin
            if not isItemInBookmark(bmFileFldr, anEntry) then
              AddItemsToBookmark(bmFileFldr, DATASTORE_FILESYSTEM, anEntry, ''); // Bookmarks the actual video file
          end;

          if anEntry.IsExpanded then
          begin
            // Get the list of children
            EntryChildren_TList := FileSystem_DataStore.Children(anEntry, True);

            // Make sure the sample does not exceed the number of keyframes
            if iSampleSize >= EntryChildren_TList.Count then
            begin
              iSampleSize := EntryChildren_TList.Count;
              random_selection_bl := False;
              Progress.Log('Sample is greater than key-frame count');
            end
            else
            begin
              random_selection_bl := True;
            end;

            // Set the random seed (results will be different each time)
            Randomize;

            Progress.Log(format(FORMAT_STR,['Count', 'Random Selection', 'File Name']));
            Progress.Log(format(FORMAT_STR,['-----', '----------------', '---------']));

            iSkipCount := 0;
            repeat
              if not Progress.isRunning then
                 Break;

              if assigned(EntryChildren_TList) and (EntryChildren_TList.Count > 0) then
              begin
                iRandom := RandomRange(0, EntryChildren_TList.Count - 1);

                rEntry := TEntry(EntryChildren_TList[iRandom]);
                EntryChildren_TList[iRandom] := nil; // Makes the entry nil for the next iteration

                if (rEntry = nil) or SampleList.Contains(rEntry) then
                begin
                  Inc(iSkipCount);

                  if iSkipCount > 3 then
                    EntryChildren_TList.Pack;
                end
                else // Only selects an entry that is not nil
                begin
                  SampleList.Add(rEntry);
                  OutList.Add(rEntry);
                  Progress.Log(format(FORMAT_STR,[IntToStr(SampleList.Count)+':', IntToStr(iRandom), rEntry.EntryName]));
                end;
              end;
            until (SampleList.Count = iSampleSize) or (EntryChildren_TList.Count = 0);

            Enum := SampleList.GetEnumerator;

            // Bookmark the randomly selected list of children
            bookmark_this_TList := TList.Create;
            try
              Enum := SampleList.GetEnumerator;
              while Enum.MoveNext do
              begin
                bookmark_this_TList.Add(Enum.Current);
              end;
              Progress.Log('bookmark_This_TList: ' + IntToStr(bookmark_This_TList.Count));
              Progress.Log('SampleList.Count: ' + IntToStr(SampleList.Count));
              Progress.Log('iSampleSize ' + IntToStr(iSampleSize));
              AddItemsToBookmark(bmKeyFramesFldr, DATASTORE_FILESYSTEM,  bookmark_this_TList, '');
            finally
              bookmark_this_TList.free;
            end;

          end;
          SampleList.free; // TODO: Clear is not currently exposed so it is created and freed each time

        end;
      end;
    end;
  finally
    FileSystem_DataStore.free;
    if assigned(EntryChildren_TList) then
      EntryChildren_TList.free;
    PopulationList.free;
  end;
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
end.