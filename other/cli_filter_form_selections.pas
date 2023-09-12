unit script_filter;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils,
  fex_triage_resource_strings in '..\common\resource_strings.pas';

implementation

const
  RPAD_VALUE = 30;
  RUNNING = '...';
  SCRIPT_NAME = 'Script Filter';
  SPACE = ' ';
  THE_InList = 'InList';
  TSWT = 'The script will terminate.';

function ShellExecute(hWnd: cardinal; lpOperation: PChar; lpFile: PChar; lpParameter: PChar; lpDirectory: PChar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' Name 'ShellExecuteW';

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
// Function: Parameters Received
// ------------------------------------------------------------------------------
function params: boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  param_str := '';
  Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
  if (CmdLine.ParamCount > 0) then
  begin
    Result := True;
    Progress.Log(StringOfChar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      param_str := param_str + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
  begin
    // Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + (IntToStr(CmdLine.ParamCount)));
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
    if ListName_str = THE_InList then
      Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

// ------------------------------------------------------------------------------
// Function: Create a PDF
// ------------------------------------------------------------------------------
procedure CreatePDF(aStringList: TStringList; FileSaveName_str: string; font_size: integer);
var
  CurrentCaseDir: string;
  SaveDir: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  SaveDir := CurrentCaseDir + 'Reports\Run Time Reports\';
  if assigned(aStringList) and (aStringList.Count > 0) then
    if ForceDirectories(IncludeTrailingPathDelimiter(SaveDir)) and DirectoryExists(SaveDir) then
      GeneratePDF(SaveDir + FileSaveName_str, aStringList, font_size);
end;

// ------------------------------------------------------------------------------
// Function: Format File Size
// ------------------------------------------------------------------------------
function FormatSize(size_int: integer): string;
begin
  Result := '';
  if (size_int >= 1048576) then // 1 megabyte
  begin
    if (size_int >= 1073741824) then // 1 gigabyte
      Result := Format('%1.0n GB', [size_int / (1024 * 1024 * 1024)])
    else
      Result := Format('%1.0n MB', [size_int / (1024 * 1024)]);
  end
  else
    Result := IntToStr(size_int) + SPACE + 'Bytes';
end;

// ------------------------------------------------------------------------------
// Function: Get ScriptTask - Boolean
// ------------------------------------------------------------------------------
function GetScriptTask_Boolean(aScriptTaskString: string): boolean;
begin
  Result := False;
  if UpperCase(ScriptTask.GetTaskListOption(aScriptTaskString)) <> '' then
  begin
    if RegexMatch(ScriptTask.GetTaskListOption(aScriptTaskString), 'True', False) then
      Result := True;

    if aScriptTaskString = RS_TASKLIST_BL_FILE_SIGNATURE_ALL_FILES then
      ConsoleLog(RPad('File Signature (All Files)', RPAD_VALUE) + BoolToStr(Result, True))

    else if aScriptTaskString = RS_TASKLIST_INT_QTY then
      ConsoleLog(RPad('Max. Sample Size', RPAD_VALUE) + BoolToStr(Result, True))

    else
      ConsoleLog(RPad(aScriptTaskString, RPAD_VALUE) + BoolToStr(Result, True));

  end;
end;

// ------------------------------------------------------------------------------
// Function: Get ScriptTask - Integer
// ------------------------------------------------------------------------------
function GetScriptTask_Integer(aScriptTaskString: string): integer;
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
      ConsoleLog(RPad(aScriptTaskString, RPAD_VALUE) + FormatSize(Result))
    else
      ConsoleLog(RPad(aScriptTaskString, RPAD_VALUE) + IntToStr(Result));
  end;
end;

// ------------------------------------------------------------------------------
// Function: Get ScriptTask - String
// ------------------------------------------------------------------------------
function GetScriptTask_String(aScriptTaskString: string): string;
begin
  Result := '';
  if UpperCase(ScriptTask.GetTaskListOption(aScriptTaskString)) <> '' then
  begin
    Result := ScriptTask.GetTaskListOption(aScriptTaskString);
    ConsoleLog(RPad(aScriptTaskString, RPAD_VALUE) + Result);
  end;
end;

// ------------------------------------------------------------------------------
// Start of the script
// ------------------------------------------------------------------------------
var
  anEntry: TEntry;
  Working_TList: TList;
  i: integer;
  Settings_StringList: TStringList;
  bl_included: boolean;
  bl_tsk_file_signature: boolean;
  bl_tsk_deleted_files: boolean;
  bl_tsk_recycle_bin: boolean;
  bl_tsk_temp_internet: boolean;
  int_tsk_qty: integer;
  int_tsk_minsize: integer;
  str_tsk_path_contains: string;
  Included_TList: TList;

  // Procedure: Console Log
procedure ConsoleLog(AString: string);
begin
  Progress.Log(AString);
  if assigned(Settings_StringList) then
    Settings_StringList.Add(AString);
end;

begin
  Progress.Log(StringOfChar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  Working_TList := TList.Create;
  Settings_StringList := TStringList.Create;
  Included_TList := TList.Create;
  try
    params;

    // InList becomes Working TList
    Progress.Log('Working with InList:');
    if (not ListExists(InList, THE_InList)) or (not ListExists(OutList, 'OutList')) then
      Exit
    else if InList.Count = 0 then
    begin
      Progress.Log('InList count is zero.' + SPACE + TSWT);
      Exit;
    end;
    for i := 0 to InList.Count - 1 do
    begin
      anEntry := TEntry(InList[i]);
      Working_TList.Add(anEntry);
    end;
    Progress.Log(StringOfChar('-', 80));

    // Variables from input form
    bl_tsk_file_signature := GetScriptTask_Boolean(RS_TASKLIST_BL_FILE_SIGNATURE_ALL_FILES);
    int_tsk_qty := GetScriptTask_Integer(RS_TASKLIST_INT_QTY);
    bl_tsk_deleted_files := GetScriptTask_Boolean(RS_TASKLIST_BL_DELETED_FILES);
    bl_tsk_recycle_bin := GetScriptTask_Boolean(RS_TASKLIST_BL_RECYCLE_BIN);
    bl_tsk_temp_internet := GetScriptTask_Boolean(RS_TASKLIST_BL_TEMP_INTERNET_FILES);
    str_tsk_path_contains := GetScriptTask_String(RS_TASKLIST_STR_PATH_CONTAINS);
    int_tsk_minsize := GetScriptTask_Integer(RS_TASKLIST_INT_MINSIZE);

    ConsoleLog(StringOfChar('-', 80));

    // Loop Working TList
    for i := 0 to Working_TList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      bl_included := True;
      anEntry := TEntry(Working_TList[i]);

      // Size -----------------------------------------------------------------
      if bl_included and (int_tsk_minsize > -1) then
      begin
        if (anEntry.LogicalSize >= int_tsk_minsize) then
          bl_included := True
        else
        begin
          bl_included := False;
          // Progress.Log(RPad('Exclude Size:', RPAD_VALUE) + anEntry.EntryName);
        end;
      end;

      // Deleted --------------------------------------------------------------
      if bl_included and (bl_tsk_deleted_files = False) then
      begin
        if anEntry.isDeleted then
        begin
          bl_included := False;
          // Progress.Log(RPad('Exclude Deleted:', RPAD_VALUE) + anEntry.EntryName);
        end;
      end;

      // Recycle Bin ----------------------------------------------------------
      if bl_included and (bl_tsk_recycle_bin = False) then
      begin
        if (RegexMatch(anEntry.FullPathName, '\\RECYCLER|\\\$Recycle\.Bin', False)) then
        begin
          bl_included := False;
          // Progress.Log(RPad('Exclude Recycle Bin:', RPAD_VALUE)  + anEntry.EntryName);
        end;
      end;

      // Temporary Internet Files ---------------------------------------------
      if bl_included and (bl_tsk_temp_internet = False) then
      begin
        if (RegexMatch(anEntry.FullPathName, 'Chrome|INetCache|Mozilla|Safari|Temporary Internet Files', False)) then
        begin
          bl_included := False;
          // Progress.Log(RPad('Exclude Temporary Internet:', RPAD_VALUE) + anEntry.EntryName);
        end;
      end;

      // Path Contains --------------------------------------------------------
      if bl_included and (str_tsk_path_contains <> '') then
      begin
        if not(RegexMatch(anEntry.FullPathName, str_tsk_path_contains, False)) then
        begin
          bl_included := False;
          // Progress.Log(RPad('Exclude Path Contains:', RPAD_VALUE) + anEntry.EntryName);
        end;
      end;

      // Add to the Included TList
      if bl_included then
        Included_TList.Add(anEntry);

      Progress.IncCurrentProgress;
    end;

    // Populate OutList
    if assigned(Included_TList) and (Included_TList.Count > 0) then
    begin
      for i := 0 to Included_TList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        anEntry := TEntry(Included_TList[i]);
        OutList.Add(anEntry);
      end;
    end;

    ConsoleLog(RPad('Files Found:', RPAD_VALUE) + IntToStr(OutList.Count));
    CreatePDF(Settings_StringList, 'Search Settings.pdf', 8);

  finally
    Working_TList.free;
    Settings_StringList.free;
    Included_TList.free;
    Progress.Log(StringOfChar('-', 80));
    Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
    Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

    if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
      ShellExecute(0, nil, 'explorer.exe', PChar(Progress.LogFilename), nil, 1);
  end;

end.
