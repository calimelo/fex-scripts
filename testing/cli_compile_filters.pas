program cli_compile_filters;

uses
  Classes, SysUtils, Common, Regex;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  CHAR_LENGTH = 80;
  HYPHEN = ' - ';
  LOGGING = 2; // 1 = Low, 2 = Medium, 3 = High, 4 = Everything
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Compile Filters';
  SPACE = ' ';
  SPECIALCHAR_PLUS: char = #10010; // noslz - Cross
  SPECIALCHAR_TICK: char = #10004; // noslz
  SPECIALCHAR_X: char = #10006; // noslz
  TSWT = 'The script will terminate.';

var
  StartDir: string;
  Result_StringList: TStringList;
  compile_error_found_bl: boolean;
  gParams_StringList: TStringList;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

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

// ConsoleLog
procedure ConsoleLog(AString: string);
begin
  Progress.Log(AString);
  if assigned(Result_StringList) then
    Result_StringList.Add(AString);
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
  Progress.Log(StringOfChar('-', 80));
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
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Function: Check Folder
// ------------------------------------------------------------------------------
procedure CheckFolder(foldername: string);
var
  ReturnStr: string;
  FileList: TStringList;
  i, j: integer;
  filename: string;
  CompResult: integer;
  temp_StringList: TStringList;

begin
  FileList := TStringList.Create;
  try
    if LOGGING >= 2 then
    begin
      if not RegexMatch(foldername, '\.bin', False) then
        ConsoleLog(#13#10 + '------- Checking folder ' + foldername + ' -------');
    end;

    begin
      GetFileNames(foldername, FileList);
      if not RegexMatch(foldername, '\.bin', False) then
        Progress.Initialize(FileList.Count, 'Checking folder ...\' + StringReplace(foldername, StartDir, '', [rfReplaceAll, rfIgnoreCase]));

      if FileList.Count = 0 then
      begin
        ConsoleLog('No scripts were found in folder: ' + foldername);
      end
      else
      begin
        for i := 0 to FileList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;

          if (FileList.Strings[i] = '.') or (FileList.Strings[i] = '..') then
            continue;

          filename := FileList.Strings[i];

          if POS('.bin', foldername) = 0 then
          begin
            if not DirectoryExists(filename) then
            begin
              if (POS('.pas', (FileList.Strings[i])) > 0) then
              begin
                if LOGGING >= 3 then
                  ConsoleLog(format('%12s %-100s', ['Compiling:', filename]));
                try
                  CompResult := CompileScript(filename, ReturnStr);
                  if CompResult <> 0 then
                  begin
                    ConsoleLog('Error Compiling: ' + filename);
                  end;
                except
                  ConsoleLog(filename);
                end;
                if CompResult <> 0 then
                begin
                  ConsoleLog('!!!!!!!!!! - Compiled NOT OK: - ' + filename + ' - !!!!!!!!!!');
                  if ReturnStr <> '' then
                  begin
                    ConsoleLog(StringOfChar('-', CHAR_LENGTH));
                    temp_StringList := TStringList.Create;
                    try
                      temp_StringList.text := ReturnStr;
                      for j := 0 to temp_StringList.Count - 1 do
                      begin
                        ConsoleLog(temp_StringList[j])
                      end;
                    finally
                      temp_StringList.free;
                    end;
                    compile_error_found_bl := True;
                    ConsoleLog(StringOfChar('-', CHAR_LENGTH));
                  end;
                end
                else
                begin
                  if LOGGING >= 3 then
                    ConsoleLog(format('%12s %-100s', [SPECIALCHAR_TICK + ' Compiled:', filename])); // noslz
                end;
              end;
            end
            else
            begin
              CheckFolder(filename + '\');
            end;
          end
          else
          begin
            if LOGGING >= 4 then
              ConsoleLog('Skipped: ' + foldername);
          end;
          Progress.IncCurrentProgress;
        end;
      end;
    end;
  finally
    FileList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Remove Last Part of Folder
// ------------------------------------------------------------------------------
function RemoveLastPart(var s: string): string;
begin
  repeat
    delete(s, Length(s), 1)
  until (s[Length(s)] = '\') or (s = '');
  Result := s;
end;

// ------------------------------------------------------------------------------
// Procedure: Export Results Window content to a File
// ------------------------------------------------------------------------------
procedure ExportResultsToFile;
var
  CurrentCaseDir: string;
  Export_Filename: string;
  ExportDate: string;
  ExportDateTime: string;
  ReportsDir: string;
  ExportTime: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  ReportsDir := CurrentCaseDir + 'Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + ' - ' + ExportTime);
  if DirectoryExists(ReportsDir) then
  begin

    // if assigned(Result_StringList) and (Result_StringList.Count > 0) then
    begin
      Export_Filename := ReportsDir + ExportDateTime + HYPHEN + SCRIPT_NAME + '.txt';
      Result_StringList.SaveToFile(Export_Filename);
      if FileExists(Export_Filename) then
      begin
        ConsoleLog('Exported to: ' + Export_Filename);
        ShellExecute(0, nil, 'explorer.exe', Pchar(ReportsDir), nil, 1);
      end
      else
        ConsoleLog('Export file not found: ' + Export_Filename);
    end;
  end
  else
    ConsoleLog('Export folder not found: ' + ReportsDir);
end;

// ==============================================================================
// Start of Script
// ==============================================================================
var
  astr: string;

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.Log('Starting' + RUNNING);
  gParams_StringList := TStringList.Create;
  try
    StartDir := '';
    ParametersReceived;
    if (CmdLine.ParamCount > 0) then
      astr := CmdLine.params[0];

    while (Length(astr) > 8) do
    begin
      astr := RemoveLastPart(astr);
      Progress.Log(astr);
      if DirectoryExists(astr + 'Filters') then
      begin
        astr := astr + 'Filters';
        break;
      end;
    end;

    StartDir := astr;

    if (trim(StartDir) = '') or (not RegexMatch(astr, '\\Filters\\?$', False)) then
    begin
      ConsoleLog('Start directory is blank.' + SPACE + TSWT);
      ConsoleLog(StringOfChar('-', CHAR_LENGTH));
      ConsoleLog('Finished.');
      Exit;
    end;

    if not DirectoryExists(StartDir) then
    begin
      ConsoleLog('Did not locate Filters folder: ' + StartDir + '.' + SPACE + TSWT);
      ConsoleLog(StringOfChar('-', CHAR_LENGTH));
      ConsoleLog('Finished.');
      Exit;
    end;

    Result_StringList := TStringList.Create;
    try
      ConsoleLog(StringOfChar('-', CHAR_LENGTH));
      ConsoleLog(RPad('Filters StartDir:', RPAD_VALUE) + StartDir);
      ConsoleLog(RPad('Logging Level:', RPAD_VALUE) + IntToStr(LOGGING) + SPACE + '(1=Low, 2=Medium, 3=High, 4=All)');
      ConsoleLog(StringOfChar('-', CHAR_LENGTH));
      CheckFolder(StartDir);
      // Pass/Fail message
      ConsoleLog(StringOfChar('-', CHAR_LENGTH));
      if not Progress.isRunning then
        ConsoleLog('Canceled by user.')
      else
      begin
        if compile_error_found_bl = True then
          ConsoleLog('WARNING: Compile errors were found.')
        else
          ConsoleLog('Compile passed.');
      end;
      ConsoleLog(SCRIPT_NAME + ' finished.');
      Progress.DisplayMessageNow := ('Processing complete.');
      ExportResultsToFile;
    finally
      Result_StringList.free;
    end;
  finally
    gParams_StringList.free;
  end;

  // ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1); // FEXLAB can be a remote machine
end.
