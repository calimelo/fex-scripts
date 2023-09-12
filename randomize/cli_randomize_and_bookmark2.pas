unit Bookmark_Random_Sample;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils,
  fex_triage_resource_strings in '..\common\resource_strings.pas';

implementation

const
  BS = '\';
  FORMAT_STR = '%-8s %-20s %-50s';
  MAX_SAMPLE_SIZE_INT = 500; // This is the override max. Only used if txml param is greater than this value.
  RANDOM_SAMPLE_STR = 'Random Sample';
  RPAD_VALUE = 30;
  RUNNING = '...';
  SCRIPT_NAME = 'Bookmark random sample';
  SPACE = ' ';
  TSWT = 'The script will terminate.';
  THE_InList = 'InList';
  
var
  bmComment_StringList: TStringList;
  
function ShellExecute(hWnd: cardinal; lpOperation: PChar; lpFile: PChar; lpParameter: PChar; lpDirectory: PChar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' Name 'ShellExecuteW';  

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
// Function: Make sure the InList and OutList exist
//------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string): boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    if ListName_str = THE_InList then
      Progress.Log(RPad(ListName_str + SPACE + 'count:', rpad_value) + IntToStr(aList.Count));  
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

//------------------------------------------------------------------------------
// Function: Format File Size
//------------------------------------------------------------------------------
function FormatSize (size_int: integer) : string;
begin
  Result := '';
  if (size_int >= 1048576) then // 1 megabyte
  begin
    if (size_int >= 1073741824) then // 1 gigabyte
      Result := Format('%1.0n GB',[size_int/(1024*1024*1024)])
    else
      Result := Format('%1.0n MB',[size_int/(1024*1024)]);
  end
  else
    Result := IntToStr(size_int) + SPACE + 'Bytes';
end;

//------------------------------------------------------------------------------
// Get ScriptTask - Boolean
//------------------------------------------------------------------------------
function GetScriptTask_Boolean(aScriptTaskString: string; aStringList: TStringList) : boolean;
begin
  Result := False;
  if UpperCase(ScriptTask.GetTaskListOption(aScriptTaskString)) <> '' then
  begin
    if RegexMatch(ScriptTask.GetTaskListOption(aScriptTaskString), 'True', False) then
      Result := True;
      
    if aScriptTaskString = RS_TASKLIST_BL_FILE_SIGNATURE_ALL_FILES then
      aStringList.Add(RPad('File Signature (All Files)', RPAD_VALUE) + BoolToStr(Result, True))

    else    
      aStringList.Add(RPad(aScriptTaskString, RPAD_VALUE) + BoolToStr(Result, True));
      
  end;
end;

//------------------------------------------------------------------------------
// Get ScriptTask - Integer
//------------------------------------------------------------------------------
function GetScriptTask_Integer(aScriptTaskString: string; aStringList: TStringList) : integer;
begin
  Result := 0;
  if UpperCase(ScriptTask.GetTaskListOption(aScriptTaskString)) <> '' then
  begin
    if (ScriptTask.GetTaskListOption(aScriptTaskString) <> '') or (ScriptTask.GetTaskListOption(aScriptTaskString) <> '0') then
    begin
      try
        Result := StrToInt64(ScriptTask.GetTaskListOption(aScriptTaskString));
      except
        Progress.Log('IntToStr Exception:' + SPACE + ScriptTask.GetTaskListOption(aScriptTaskString));
      end
    end;
    
    if aScriptTaskString = RS_TASKLIST_INT_MINSIZE then    
      aStringList.Add(RPad('Min Size', RPAD_VALUE) + FormatSize(Result))
    
    else if aScriptTaskString = RS_TASKLIST_INT_QTY then
      aStringList.Add(RPad('Max. Sample Size', RPAD_VALUE) + IntToStr(Result))    
    
    else
      aStringList.Add(RPad(aScriptTaskString, RPAD_VALUE) + IntToStr(Result));     
  
  end;
end;

//------------------------------------------------------------------------------
// Get ScriptTask - String
//------------------------------------------------------------------------------
function GetScriptTask_String(aScriptTaskString: string; aStringList: TStringList) : string;
begin
  Result := '';
  if UpperCase(ScriptTask.GetTaskListOption(aScriptTaskString)) <> '' then
  begin
    Result := ScriptTask.GetTaskListOption(aScriptTaskString);
    aStringList.Add(RPad(aScriptTaskString, RPAD_VALUE) + Result);
  end;
end;

//------------------------------------------------------------------------------
// Start of the script
//------------------------------------------------------------------------------
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
  random_sample_bl: boolean;
  SampleList: TUniqueListOfEntries;
  
  bl_tsk_file_signature: boolean;
  bl_tsk_deleted_files: boolean;
  bl_tsk_recycle_bin: boolean;  
  bl_tsk_temp_internet: boolean;   
  int_tsk_qty: integer;
  int_tsk_minsize: integer;
  str_tsk_path_contains: string;

  bmComment_str: string;
  bl_process_graphics: boolean;
  bl_process_video: boolean;

begin
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);
  
  bmComment_str := '';
  bmComment_StringList := TStringList.Create;
  try
    // Variables from input form
    bl_tsk_file_signature := GetScriptTask_Boolean(RS_TASKLIST_BL_FILE_SIGNATURE_ALL_FILES, bmComment_StringList);
    int_tsk_qty           := GetScriptTask_Integer(RS_TASKLIST_INT_QTY, bmComment_StringList);
    bl_tsk_deleted_files  := GetScriptTask_Boolean(RS_TASKLIST_BL_DELETED_FILES, bmComment_StringList);
    bl_tsk_recycle_bin    := GetScriptTask_Boolean(RS_TASKLIST_BL_RECYCLE_BIN, bmComment_StringList);
    bl_tsk_temp_internet  := GetScriptTask_Boolean(RS_TASKLIST_BL_TEMP_INTERNET_FILES, bmComment_StringList);
    str_tsk_path_contains := GetScriptTask_String(RS_TASKLIST_STR_PATH_CONTAINS, bmComment_StringList);
    int_tsk_minsize       := GetScriptTask_Integer(RS_TASKLIST_INT_MINSIZE, bmComment_StringList);
    
    if assigned(bmComment_StringList) and (bmComment_StringList.Count > 0) then
    begin
      bmComment_str := bmComment_StringList.text;
      for i := 0 to bmComment_StringList.Count - 1 do
      begin
        Progress.Log(bmComment_StringList[i]);
      end;      
      Progress.Log(Stringofchar('-', 80));
    end;  

  finally
    bmComment_StringList.free;
  end;

  if (CmdLine.ParamCount > 0) then
  begin
    if (UpperCase(CmdLine.Params[0]) = 'GRAPHICS') then
    begin
      bl_process_graphics := True;
      Progress.Log('Processing Graphics');
      bm_folder_name_str := 'FEX-Triage\Graphics Random Sample';    
    end;
    if (UpperCase(CmdLine.Params[0]) = 'VIDEO') then
    begin    
      bl_process_video := True;
      Progress.Log('Processing Video');      
      bm_folder_name_str := 'FEX-Triage\Video Random Sample';
    end;
  end;

  if not bl_process_graphics and not bl_process_video then
  begin
    Progress.Log('Something went wrong.' + SPACE + TSWT);
    if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
      ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);
    Exit;
  end;
  
  // Locate the bookmark folder. If folder not present, create it. Create it upfront so that it can report 0 if nothing found.
  bmFolder := FindBookmarkByName(bm_folder_name_str);
  if bmFolder = nil then
  begin
    bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), bm_folder_name_str, 'Total files found: 0');
    if assigned(bmFolder) then
    begin
      Progress.Log(RPad('Bookmark folder created:', RPAD_VALUE) + bmFolder.FullPathName);
    end
    else
    begin
      Progress.Log(RPad('Bookmark folder not created:', RPAD_VALUE) + bmFolder.FullPathName);
    end;
    Progress.Log(Stringofchar('-', 80));
  end
  else
  begin
    Progress.Log('Bookmark folder already exists: ' + bmFolder.FullPathName);
    UpdateBookmark(bmFolder, 'Total files found: 0');
    Progress.Log(Stringofchar('-', 80));
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
    if assigned(bmFolder) then
    begin

      // Over-ride TXML and set hard max
      iSampleSize := 1000;
      if iSampleSize >= MAX_SAMPLE_SIZE_INT then
      begin
        iSampleSize := MAX_SAMPLE_SIZE_INT;
        Progress.Log(RPad('Max Over-ride iSampleSize:', RPAD_VALUE) + IntToStr(MAX_SAMPLE_SIZE_INT));
      end;

      Progress.Log(RPad('PopulationList:', RPAD_VALUE) + IntToStr(PopulationList.Count));
      Progress.Log(RPad('Sample Size:', RPAD_VALUE) + IntToStr(iSampleSize));

      // Make sure the sample does not exceed the population
      if iSampleSize >= PopulationList.Count then
      begin
        iSampleSize := PopulationList.Count;
        random_sample_bl := False;
        Progress.Log('Sample > Population');
      end
      else
      begin
        random_sample_bl := True;
      end;
      Progress.Log(Stringofchar('-', 80));      

      // Add summary information to the bookmark folder for use in the report
      //if random_sample_bl then
        //bm_comment_str := bmComment_str + #13#10 + 'This is a random sample of' + SPACE + IntToStr(iSampleSize) + SPACE + 'files from' + SPACE + IntToStr(PopulationList.Count) + SPACE + 'found.';
      //else
        //bm_comment_str := 'Total files found:' + SPACE + IntToStr(PopulationList.Count);

      // Overwrite the default 0 bookmark comment
      if bmFolder <> nil then
        UpdateBookmark(bmFolder, bmcomment_str);

      //======================================================================================================

      // Set the random seed (results will be different each time)
      Randomize;

      Progress.Log(format(FORMAT_STR,['Count', 'Random Sample', 'File Name']));
      Progress.Log(format(FORMAT_STR,['-----', '-------------', '---------']));

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

            Progress.Log(format(FORMAT_STR,[IntToStr(SampleList.Count)+':', IntToStr(iRandom), rEntry.EntryName]));

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
    
    Progress.Log(Stringofchar('-', 80));
    Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
    Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
    
    if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
      ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);
  end;
end.