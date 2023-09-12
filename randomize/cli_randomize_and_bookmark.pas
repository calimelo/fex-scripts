unit Bookmark_Random_Sample;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

implementation

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  FORMAT_STR = '%-21s %-20s %-50s';
  MAX_SAMPLE_SIZE_INT = 500; // This is the override max. Only used if txml param is greater than this value.
  RANDOM_SAMPLE_STR = 'Random Sample';
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Bookmark random sample';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

  // ------------------------------------------------------------------------------
  // Function: Right Pad v2
  // ------------------------------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

// ------------------------------------------------------------------------------
// Function: Parameters Received (Exception: [0] = number to random bookmark, [1] = Original bookmark folder
// ------------------------------------------------------------------------------
function params: boolean;
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
    Progress.Log(StringOfChar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      param_str := param_str + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(param_str);

    // Check to see that param 0 is an integer
    try
      StrToInt(CmdLine.params[0]);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Could not convert param 0 from str to int.');
      Result := False;
    end;

  end
  else
  begin
    Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + (IntToStr(CmdLine.ParamCount)));
    Result := False;
  end;
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Function: Make sure the InList and OutList exist
// ------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string): boolean;
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

// ------------------------------------------------------------------------------
// Start of the script
// ------------------------------------------------------------------------------
var
  bm_comment_str: string;
  bm_folder_name_str: string;
  bmFolder: TEntry;
  rEntry: TEntry;
  Enum: TEntryEnumerator;
  i: integer;
  iRandom: integer;
  iSampleSize: integer;
  iSkipCount: integer;
  PopulationList: TList;
  random_selection_bl: boolean;
  SampleList: TUniqueListOfEntries;

begin
  Progress.Log(StringOfChar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  // Check params received: [0] = number to random bookmark, [1] = Original bookmark folder
  if not params then
    Exit;

  // Locate the bookmark folder. If folder not present, create it. Create it upfront so that it can report 0 if nothing found.
  bm_folder_name_str := CmdLine.params[1];
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
  if InList.Count <= 0 then
  begin
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Exit;
  end;

  PopulationList := TList.Create;
  SampleList := TUniqueListOfEntries.Create;

  try

    // Because we use Pack we need to convert the InList to a TList
    for i := 0 to InList.Count - 1 do
    begin
      rEntry := TEntry(InList[i]);
      PopulationList.Add(rEntry);
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
      iSampleSize := StrToInt(CmdLine.params[0]);
      if iSampleSize >= MAX_SAMPLE_SIZE_INT then
      begin
        iSampleSize := MAX_SAMPLE_SIZE_INT;
        Progress.Log('Over-ride TXML and set max iSampleSize to: ' + IntToStr(MAX_SAMPLE_SIZE_INT));
      end;

      Progress.Log(RPad('PopulationList:', RPAD_VALUE) + IntToStr(PopulationList.Count));
      Progress.Log(RPad('Sample Size:', RPAD_VALUE) + IntToStr(iSampleSize));

      // Make sure the sample does not exceed the population
      if iSampleSize >= PopulationList.Count then
      begin
        iSampleSize := PopulationList.Count;
        random_selection_bl := False;
        Progress.Log('Sample is greater than population');
      end
      else
      begin
        random_selection_bl := True;
      end;

      // Add summary information to the bookmark folder for use in the report
      if random_selection_bl then
        bm_comment_str := 'This is a random selection of' + SPACE + IntToStr(iSampleSize) + SPACE + 'files from' + SPACE + IntToStr(PopulationList.Count) + SPACE + 'found.'
      else
        bm_comment_str := 'Total files found:' + SPACE + IntToStr(PopulationList.Count);

      // Overwrite the default 0 bookmark comment
      if bmFolder <> nil then
        UpdateBookmark(bmFolder, bm_comment_str);

      // ======================================================================================================

      // Set the random seed (results will be different each time)
      Randomize;

      Progress.Log(format(FORMAT_STR, ['Count', 'Random Selection', 'File Name']));
      Progress.Log(format(FORMAT_STR, ['-----', '----------------', '---------']));

      iSkipCount := 0;
      repeat
        if not Progress.isRunning then
          Break;

        if assigned(PopulationList) and (PopulationList.Count > 0) then
        begin
          iRandom := RandomRange(0, PopulationList.Count - 1);

          rEntry := TEntry(PopulationList[iRandom]);
          PopulationList[iRandom] := nil; // Makes the rEntry nil for the next iteration

          if (rEntry = nil) or SampleList.Contains(rEntry) then
          begin
            Inc(iSkipCount);

            if iSkipCount > 3 then
              PopulationList.Pack;
          end
          else // Only selects an rEntry that is not nil
          begin
            SampleList.Add(rEntry);
            OutList.Add(rEntry);

            Progress.Log(format(FORMAT_STR, [IntToStr(SampleList.Count) + ':', IntToStr(iRandom), rEntry.EntryName]));

            if assigned(bmFolder) and (not IsItemInBookmark(bmFolder, rEntry)) then
              AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, rEntry, '');

          end;
        end;
      until (SampleList.Count = iSampleSize) or (PopulationList.Count = 0);

      Enum := SampleList.GetEnumerator;
    end;

  finally
    PopulationList.free;
    SampleList.free;
  end;
  Progress.Log(StringOfChar('-', 80));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

end.
