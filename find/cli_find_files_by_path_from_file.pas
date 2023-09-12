{!NAME:      cli_find_files_by_path_from_file.pas}
{!DESC:      Find a file, or files, by path from input file.}
{!AUTHOR:    GetData}

unit FindFilesByPathFromFile;

interface

uses
  Classes, Common, DataEntry, DataStorage, DateUtils, Regex, SysUtils, Variants;

const
  CHAR_LENGTH = 80;
  RPAD_VALUE = 30;
  RUNNING = '...';
  SCRIPT_NAME = 'Find Files by Path (Read paths from input file)';
  SPACE = ' ';
  THE_InList = 'InList';
  TSWT = 'The script will terminate.';
  
  // TASKLIST must match the exact values in the TXML
  TASKLIST_BETWEEN_DATES = 'Between Dates';
  TASKLIST_END_DATE = 'End Date:';
  TASKLIST_FILTER_BY_SIZE = 'Filter by Size:';
  TASKLIST_HAS_ATTACHMENT = 'Has Attachment';  
  TASKLIST_MAX_SIZE = 'Max Size:';
  TASKLIST_MIN_SIZE = 'Min Size:';
  TASKLIST_START_DATE = 'Start Date:';

var
  gFindTheseFiles_StringList: TStringList;

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

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
function ListExists(aList: TListOfEntries; ListName_str: string) : boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    if ListName_str = THE_InList then
      Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Function: Parameters Received
//------------------------------------------------------------------------------
function ParametersReceived : integer;
var
  i: integer;
begin
  Result := 0;
  Progress.Log(Stringofchar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := CmdLine.ParamCount;
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + cmdline.params[i]);
    end;
  end
  else
  begin
    Progress.Log('No parameters were received.');
  end;
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Procedure: Create PDF
//------------------------------------------------------------------------------
procedure CreateRunTimePDF(aStringList: TStringList; SaveTitle: string; font_size_int: integer; dtInFileName: boolean);
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
  sleep(1000);  // Required if you create reports in quick succession.
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := ExportDate + ' - ' + ExportTime + HYPHEN;
  if dtInFileName = False then
    ExportDateTime := '';
  SaveName := ExportedDir + ExportDateTime + SaveTitle;
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if GeneratePDF(SaveName, aStringList, font_size_int) then
          Progress.Log(RPad('Success Creating:', RPAD_VALUE) + ExtractFileName(SaveName));
      end
      else
        Progress.Log('Failed Creating: ' + SaveName);
    except
      Progress.Log('Exception creating runtime folder');
    end;
  end
  else
    Progress.Log('There is no current case folder');
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Procedure: Simple PDF
//------------------------------------------------------------------------------
procedure SimpleRunTimePDF(aString: string; save_name_str: string);
const
  HYPHEN = ' - ';
var
  CurrentCaseDir: string;
  ExportedDir: string;
  SaveName: string;
  aStringList: TStringList;
begin
  aStringList := TStringList.Create;
  try
    aStringList.Add(aString);
    CurrentCaseDir := GetCurrentCaseDir;
    ExportedDir := CurrentCaseDir + 'Reports\Run Time Reports\';
    SaveName := ExportedDir + save_name_str + '.pdf';
    if DirectoryExists(CurrentCaseDir) then
    begin
      try
        if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
        begin
          if GeneratePDF(SaveName, aStringList, 8) then
            Progress.Log('Success Creating: ' + SaveName)
        end
        else
          Progress.Log('Failed Creating: ' + SaveName);
      except
        Progress.Log('Exception creating runtime folder');
      end;
    end
    else
      Progress.Log('There is no current case folder');
  finally
    aStringList.free;
  end;
end;

//------------------------------------------------------------------------------
// Function: Load from keywords file
//------------------------------------------------------------------------------
function LoadKeywordsFromFile(keywords_filepath_str: string) : boolean;
var
  i: integer;
  CommentString: string;
begin
  Result := False;
  if FileExists(keywords_filepath_str) then
  begin
    Result := True;
    gFindTheseFiles_StringList.LoadFromFile(keywords_filepath_str);

    // Remove blank lines from StringList
    for i := gFindTheseFiles_StringList.Count - 1 downto 0 do
    begin
      if Trim(gFindTheseFiles_StringList[i]) = '' then
        gFindTheseFiles_StringList.Delete(i);
    end;

    // Remove comment lines from StringList
    for i := gFindTheseFiles_StringList.Count - 1 downto 0 do
    begin
      CommentString := copy(gFindTheseFiles_StringList(i), 1, 1);
      if CommentString = '#' then
        gFindTheseFiles_StringList.Delete(i);
    end;

  end
  else
  begin
    Progress.Log(RPad('File path not found:', RPAD_VALUE) + keywords_filepath_str);
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
// Start of Script
//------------------------------------------------------------------------------
var
  anEntry: TEntry;
  bl_between_dates: boolean;
  bl_start_date: boolean;
  bl_end_date: boolean;
  bl_filter_by_size: boolean;
  bl_Included: boolean;
  bl_max_size: boolean;
  bl_min_size: boolean;
  dsFileSystem: TDataStore;
  end_date_dt: TDateTime;
  end_date_str: string;  
  Enum: TEntryEnumerator;
  FoundList: TList;
  i: integer;
  max_size_int: int64;
  min_size_int: int64;
  Settings_StringList: TStringList;
  start_date_dt: TDateTime;
  start_date_str: string;
  UniqueList: TUniqueListOfEntries;
  
  // Console Log 
  procedure ConsoleLog(AString: string);
  begin
    Progress.Log(AString);
    if assigned(Settings_StringList) then
      Settings_StringList.Add(AString);
  end;  

begin
  Progress.Log(SCRIPT_NAME + SPACE + 'started' + RUNNING);

  if ParametersReceived <> 1 then
  begin
    Progress.Log('Expected 1 parameter for keyword file path. Received: ' + IntToStr(CmdLine.ParamCount) + SPACE + TSWT);
    Exit;
  end;

  // Check that InList and OutList exist, and InList count > 0
  if (not ListExists(InList, THE_INLIST)) or (not ListExists(OutList, 'OutList')) then
    Exit
  else
  begin
    if InList.Count = 0 then
    begin
      Progress.Log('InList count is zero.' + SPACE + TSWT);
      Exit;
    end;
  end;

  dsFileSystem := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(dsFileSystem) then
    Exit;

  gFindTheseFiles_StringList := TStringList.Create;
  FoundList := TList.Create;
  UniqueList := TUniqueListOfEntries.Create;
  Settings_StringList := TStringList.Create;
  try
  
    if (CmdLine.ParamCount > 0) and (not LoadKeywordsFromFile(cmdline.params[0])) then
    begin
      Progress.Log('Could not load keywords from file.' + SPACE + TSWT);
      Exit;
    end;  

    // Find the files in the paths specified in the parameters received
    for i := 0 to gFindTheseFiles_StringList.Count - 1 do
    begin
      dsFileSystem.FindEntriesByPath(nil, gFindTheseFiles_StringList(i), FoundList);
    end;

    //--------------------------------------------------------------------------
    // Get ScriptTask Variable: Between Dates
    //--------------------------------------------------------------------------
    if RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_BETWEEN_DATES), 'True', False) then    
    begin
      bl_between_dates := True;
      
      // Get Start Date
      start_date_str := ScriptTask.GetTaskListOption(TASKLIST_START_DATE);
      if trim(start_date_str) = '' then
      begin      
        Progress.Log('Error reading input form - Date Start.');
        bl_start_date := False;
      end
      else
      begin
        try
          start_date_dt := VarToDateTime(start_date_str);
          bl_start_date := True;          
        except
          Progress.Log('Error converting Start Date string to DateTime: ' + start_date_str);
          bl_start_date := False;
        end;
      end;

      // Get End Date
      end_date_str := ScriptTask.GetTaskListOption(TASKLIST_END_DATE);
      if trim(end_date_str) = '' then
      begin      
        Progress.Log('Error reading input form - Date End.');
        bl_end_date := False;        
      end
      else if bl_end_date = True then
      begin
        try
          end_date_dt := VarToDateTime(end_date_str);
        except
          Progress.Log('Error converting End Date string to DateTime: ' + end_date_str);
          bl_end_date := False;
        end;
      end;

    end;
    
    //--------------------------------------------------------------------------
    // Get ScriptTask Variable: Min Size
    //--------------------------------------------------------------------------    
    bl_min_size := False;
    if RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_FILTER_BY_SIZE), 'True', False) then    
    begin
      bl_filter_by_size := True;
      if (ScriptTask.GetTaskListOption(TASKLIST_MIN_SIZE) <> '') or (ScriptTask.GetTaskListOption(TASKLIST_MIN_SIZE) <> '0') then
      begin
        try
          min_size_int := StrToInt64(ScriptTask.GetTaskListOption(TASKLIST_MIN_SIZE));
          bl_min_size := True;
        except
          Progress.Log('Error setting minimum size:' + SPACE + ScriptTask.GetTaskListOption(TASKLIST_MIN_SIZE));
          bl_min_size := False;
        end
      end;
    end;
    
    //--------------------------------------------------------------------------
    // Get ScriptTask Variable: Max Size
    //--------------------------------------------------------------------------    
    bl_max_size := False;
    if RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_FILTER_BY_SIZE), 'True', False) then
    begin
      bl_filter_by_size := True;
      if (ScriptTask.GetTaskListOption(TASKLIST_MAX_SIZE) <> '') then //or (ScriptTask.GetTaskListOption(TASKLIST_MAX_SIZE) <> '0') then
      begin
        try
          max_size_int := StrToInt64(ScriptTask.GetTaskListOption(TASKLIST_MAX_SIZE));
          bl_max_size := True;
        except
          Progress.Log('Error setting maximum size:' + SPACE + ScriptTask.GetTaskListOption(TASKLIST_MAX_SIZE));
          bl_max_size := False;
        end;
      end;
    end;    
    
    //--------------------------------------------------------------------------
    // Add the found list to the unique list
    //--------------------------------------------------------------------------    
    for i := 0 to FoundList.Count -1 do
    begin
      bl_included := True;
      anEntry := TEntry(FoundList[i]);

      // Exclude Between Dates
      if bl_between_dates and bl_start_date and bl_end_date then
      begin    
        if (CompareDate(anEntry.Created, start_date_dt) = -1) or (CompareDate(anEntry.Created, end_date_dt) = 1) then
          bl_Included := False;
        if (CompareDate(anEntry.Modified, start_date_dt) = -1) or (CompareDate(anEntry.Modified, end_date_dt) = 1) then
          bl_Included := False;
        if (CompareDate(anEntry.Accessed, start_date_dt) = -1) or (CompareDate(anEntry.Accessed, end_date_dt) = 1) then
          bl_Included := False;
      end;
      
      // Exclude < Min Size
      if bl_filter_by_size and bl_min_size and ((anEntry.LogicalSize < 0) or (anEntry.LogicalSize < min_size_int)) then 
        bl_Included := False;

      // Exclude > Max Size
      if bl_filter_by_size and bl_max_size and ((anEntry.LogicalSize < 0) or (anEntry.LogicalSize > max_size_int)) then 
        bl_Included := False;

      // Add to Unique List
      if bl_Included then
        UniqueList.Add(anEntry);
   
    end;
    
    //--------------------------------------------------------------------------
    // Unique List > OutList
    //--------------------------------------------------------------------------     
    if assigned(UniqueList) and (UniqueList.Count > 0) then
    begin
      Progress.Log(RPad('Unique List Count:', RPAD_VALUE) + IntToStr(UniqueList.Count));
      Enum := UniqueList.GetEnumerator;
      while Enum.MoveNext do
      begin
        anEntry := Enum.Current;
        OutList.Add(anEntry);
      end;
    end
    else
    begin    
      Progress.Log(Stringofchar('-', CHAR_LENGTH));
      Progress.Log('No files found.');  
    end;
    
    //--------------------------------------------------------------------------
    // Produce the Settings PDF
    //--------------------------------------------------------------------------    
    ConsoleLog(Stringofchar('-', 80));
    ConsoleLog('Search Settings');
    ConsoleLog(Stringofchar('-', 80));
    
    // Log search terms
    if assigned(gFindTheseFiles_StringList) and (gFindTheseFiles_StringList.Count > 0 ) then
    begin
      ConsoleLog('Search terms:');
      for i := 0 to gFindTheseFiles_StringList.Count -1 do
      begin
        ConsoleLog(RPad(SPACE + IntToStr(i+1) + '.', RPAD_VALUE) + gFindTheseFiles_StringList(i));
      end;
      ConsoleLog(Stringofchar('-', 80)); 
    end;
    
    // Log between dates
    if UpperCase(ScriptTask.GetTaskListOption(TASKLIST_BETWEEN_DATES)) <> '' then
    begin
      if bl_between_dates then
      begin
        ConsoleLog(RPad(TASKLIST_BETWEEN_DATES, RPAD_VALUE) + BoolToStr(bl_between_dates, True)); 
        ConsoleLog(RPad(' Start Date:', RPAD_VALUE) + start_date_str);
        ConsoleLog(RPad(' End Date:', RPAD_VALUE) + end_date_str);
        ConsoleLog(Stringofchar('-', 80)); 
      end
      else
      begin
        ConsoleLog(RPad(TASKLIST_BETWEEN_DATES, RPAD_VALUE) + BoolToStr(bl_between_dates, True));
        ConsoleLog(Stringofchar('-', 80)); 
      end;
    end;  
      
    // Log size
    if UpperCase(ScriptTask.GetTaskListOption(TASKLIST_FILTER_BY_SIZE)) <> '' then
    begin      
      if bl_filter_by_size then
      begin
        ConsoleLog(RPad(TASKLIST_FILTER_BY_SIZE, RPAD_VALUE) + BoolToStr(bl_filter_by_size, True));
        if bl_min_size then
          ConsoleLog(RPad(' Min Size (bytes):', RPAD_VALUE) + IntToStr(min_size_int))
        else
          ConsoleLog(RPad(' Invalid Min Size:', RPAD_VALUE) + 'Ignored');      
        if bl_max_size then
          ConsoleLog(RPad(' Max Size (bytes):', RPAD_VALUE) + IntToStr(max_size_int))
        else
          ConsoleLog(RPad(' Invalid Max Size:', RPAD_VALUE) + 'Ignored');    
        ConsoleLog(Stringofchar('-', 80));
      end
      else
      begin
        ConsoleLog(RPad(TASKLIST_FILTER_BY_SIZE, RPAD_VALUE) + BoolToStr(bl_filter_by_size, True));
        ConsoleLog(Stringofchar('-', 80));
      end;  
    end;
    
    // Log items found count
    ConsoleLog(RPad('Items Found:', RPAD_VALUE) + IntToStr(OutList.Count));

    CreateRunTimePDF(Settings_StringList, 'Search Settings.pdf', 8, False); // True = UseDT    

  finally
    dsFileSystem.free;
    FoundList.free;
    UniqueList.free;
    gFindTheseFiles_StringList.free;
  end;

  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

  if RegexMatch(ScriptTask.GetTaskListOption('Auto Open Log'), 'True', False) then  
    ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);   
end.