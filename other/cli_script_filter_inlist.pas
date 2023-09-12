unit script_filter;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Script Filter';
  SPACE = ' ';
  THE_InList = 'InList';
  TSWT = 'The script will terminate.';
  
  // TASKLIST must match the exact values in the TXML
  TASKLIST_CASE_SENSITIVE = 'Case Sensitive';
  TASKLIST_EXACT_MATCH = 'Exact Match';

implementation

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
// Function: Parameters Received
//------------------------------------------------------------------------------
function Parameters_Received : boolean;
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
    Progress.Log(Stringofchar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + cmdline.params[i]);
      param_str := param_str + '"' + cmdline.params[i] + '"' + ' ';
    end;
    trim(param_str);
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
    if ListName_str = THE_InList then
      Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));  
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

//------------------------------------------------------------------------------
// Function: Create a PDF
//------------------------------------------------------------------------------
procedure CreatePDF(aStringList: TStringList; FileSaveName_str: string; font_size: integer);
var
  CurrentCaseDir: string;
  SaveDir: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  SaveDir := CurrentCaseDir + 'Reports\Run Time Reports\';
  if assigned(aStringList) and (aStringList.Count > 0) then
  begin
    if ForceDirectories(IncludeTrailingPathDelimiter(SaveDir)) and DirectoryExists(SaveDir) then
      GeneratePDF(SaveDir + FileSaveName_str, aStringList, font_size);
  end;
end;

//------------------------------------------------------------------------------
// Procedure: Build Keywords from LineList                                           
//------------------------------------------------------------------------------
procedure build_keywords_from_linelist(aStringList: TStringList);
var
  i, j: integer;
  LineList: TStringList;
begin
  if (CmdLine.ParamCount > 0) then
  begin
    LineList := TStringList.Create;
    LineList.Delimiter := ','; // Default, but ";" is used with some locales
    LineList.QuoteChar := '"'; // Default
    LineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter
    try
      for i := 0 to CmdLine.ParamCount - 1 do
      begin
        lineList.CommaText := cmdline.params[i];
        for j := 0 to lineList.Count - 1 do
          aStringList.Add(lineList[j]);
      end;
    finally
      LineList.free;
    end;
  end;
end;

//------------------------------------------------------------------------------
// Start of the script
//------------------------------------------------------------------------------
var
  anEntry: TEntry;
  Working_TList: TList;
  i, j: integer;
  Keywords_StringList: TStringList;
  Settings_StringList: TStringList;
  bl_case_sentive: boolean;
  bl_exact_match: boolean;
  bl_tasklist_found: boolean;
  
  // Console Log 
  procedure ConsoleLog(AString: string);
  begin
    Progress.Log(AString);
    if assigned(Settings_StringList) then
      Settings_StringList.Add(AString);
  end;  

begin
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  Working_TList := TList.Create;
  Keywords_StringList := TStringList.Create;
  Settings_StringList := TStringList.Create;
  try
    // Params Received
    if not Parameters_Received then
      Exit;

    build_keywords_from_linelist(Keywords_StringList);
    if assigned(Keywords_StringList) and (Keywords_StringList.Count > 0) then
    begin
      ConsoleLog('Keywords:');
      for i := 0 to Keywords_StringList.Count - 1 do
      begin
        ConsoleLog(RPad('Keyword' + SPACE + IntToStr(i + 1) + ':', RPAD_VALUE) + Keywords_StringList[i]);
      end;
      ConsoleLog(Stringofchar('-', 80));
    end
    else
    begin
      Progress.Log('No keywords received.' + SPACE + TSWT);
      ConsoleLog('No keywords received.');
      Exit;
    end;

    // InList becomes Working TList
    Progress.Log('Working with InList:');
    if (not ListExists(InList, THE_INLIST)) or (not ListExists(OutList, 'OutList')) then
      Exit
    else
    if InList.Count = 0 then
    begin
      Progress.Log('InList count is zero.' + SPACE + TSWT);
      Exit;
    end;
    for i := 0 to InList.Count - 1 do
    begin
      anEntry := TEntry(InList[i]);
      Working_TList.Add(anEntry);
    end;
    Progress.Log(Stringofchar('-', 80));
    
    //--------------------------------------------------------------------------
    // Get ScriptTask Variable: Case Sensitive
    //--------------------------------------------------------------------------
    bl_case_sentive := False;
    if UpperCase(ScriptTask.GetTaskListOption(TASKLIST_CASE_SENSITIVE)) <> '' then
    begin
      bl_tasklist_found := True;
      if RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_CASE_SENSITIVE), 'True', False) then
        bl_case_sentive := True;
      ConsoleLog(RPad('Case Sensitive:', RPAD_VALUE) + BoolToStr(bl_case_sentive, True));
    end;

    //--------------------------------------------------------------------------
    // Get ScriptTask Variable: Exact Match
    //--------------------------------------------------------------------------
    bl_exact_match := False;
    if UpperCase(ScriptTask.GetTaskListOption(TASKLIST_EXACT_MATCH)) <> '' then
    begin
      bl_tasklist_found := True;
      if RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_EXACT_MATCH), 'True', False) then       
        bl_exact_match := True;
      ConsoleLog(RPad('Exact Match:', RPAD_VALUE) + BoolToStr(bl_exact_match, True));        
    end;

    if bl_tasklist_found then
      ConsoleLog(Stringofchar('-', 80));

    // Loop Working TList
    for i := 0 to Working_TList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      anEntry := TEntry(Working_TList[i]);

      if assigned(Keywords_StringList) and (Keywords_StringList.Count > 0) then
        for j := 0 to Keywords_StringList.Count - 1 do
        begin

          // Case Sensitive
          if bl_case_sentive = True then
            if bl_exact_match then
            begin
              if Keywords_StringList[j] = anEntry.EntryName then
              begin
                OutList.add(anEntry);
                //Progress.Log(RPad('1 - Case/Exact:', RPAD_VALUE) + anEntry.EntryName);
              end;
            end
            else
            // Not Exact
            if POS(Keywords_StringList[j], anEntry.EntryName) > 0 then
            begin
              OutList.add(anEntry);
              //Progress.Log(RPad('2 - Case/NotExact:', RPAD_VALUE) + anEntry.EntryName);
            end;

          // Not Case Sensitive
          if bl_case_sentive = False then
            if bl_exact_match then
            begin
              if UpperCase(Keywords_StringList[j]) = UpperCase(anEntry.EntryName) then
              begin
                OutList.add(anEntry);
                //Progress.Log(RPad('3 - NotCase/Exact:', RPAD_VALUE) + anEntry.EntryName);
              end;
            end
            else
            // Not Exact
            if POS(UpperCase(Keywords_StringList[j]), UpperCase(anEntry.EntryName)) > 0 then
            begin
              OutList.add(anEntry);
              //Progress.Log(RPad('4 - NotCase/NotExact:', RPAD_VALUE) + anEntry.EntryName);
            end;

        end;

      Progress.IncCurrentProgress;
    end;

    ConsoleLog(RPad('Files Found:', RPAD_VALUE) + IntToStr(OutList.Count));
    CreatePDF(Settings_StringList, 'Search Settings.pdf', 8);

  finally
    Keywords_StringList.free;
    Working_TList.free;
    Settings_StringList.free;
  end;

  Progress.Log(Stringofchar('-', 80));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

  if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
    ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);
end.