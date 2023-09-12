unit cli_Check_Case_Log_Files;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 80;
  CR = #13#10;
  HYPHEN = ' - ';
  // OSFILENAME      = '\\?\'; // This is needed for long file names
  OSFILENAME = '';
  PIPE = '|';
  RPAD_VALUE = 35;
  RUNNING = '...';
  SCRIPT_NAME = 'Check Log Files';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gCaseName_str: string;
  gRunTimeReport_StringList: TStringList;

implementation

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

// ------------------------------------------------------------------------------
// Procedure: Create RunTime Report (PDF or TXT)
// ------------------------------------------------------------------------------
procedure CreateRunTimeReport(aStringList: TStringList; export_folder_str: string; save_name_str: string; DT_In_FileName_bl: boolean; pdf_or_txt_str: string);
const
  HYPHEN = ' - ';
  PDF_FONT_SIZE = 8;
var
  CurrentCaseDir: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
  Ext_str: string;
  SaveName: string;
begin
  if export_folder_str = '' then
    export_folder_str := 'Reports\';
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + export_folder_str;
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);

  if UpperCase(pdf_or_txt_str) = 'PDF' then
    Ext_str := '.pdf'
  else
    Ext_str := '.txt';

  if DT_In_FileName_bl then
    ExportDateTime := (ExportDate + HYPHEN + ExportTime + HYPHEN)
  else
    ExportDateTime := '';

  SaveName := ExportedDir + ExportDateTime + save_name_str + Ext_str;
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if Ext_str = '.pdf' then
        begin
          if GeneratePDF(SaveName, aStringList, PDF_FONT_SIZE) then
            Progress.Log(RPad('Success Creating:', RPAD_VALUE) + SaveName);
        end
        else
        begin
          aStringList.SaveToFile(SaveName);
          Sleep(200);
          if FileExists(SaveName) then
            Progress.Log(RPad('Success creating:', RPAD_VALUE) + SaveName)
          else
            Progress.Log(RPad('Error creating runtime report:', RPAD_VALUE) + SaveName);
        end;
      end
      else
        Progress.Log(RPad('Error creating runtime report:', RPAD_VALUE) + SaveName);
    except
      Progress.Log(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + 'Exception creating runtime report: ' + SaveName);
    end;
  end
  else
    Progress.Log('There is no current case folder.');
end;

// ------------------------------------------------------------------------------
// Procedure: Check log files for errors
// ------------------------------------------------------------------------------
procedure CheckLogFiles(aStringList: TStringList);
var
  LogFiles_StringList: TStringList;
  log_fldr_pth: string;
  i, j: integer;
  one_big_regex_str: string;
  script_name_str: string;
  temp_SList: TStringList;
  LineList: TStringList;

begin
  Progress.Log('Starting' + RUNNING);
  if DirectoryExists(GetCurrentCaseDir) then
  begin
    Progress.Log(RPad('Current Case:', RPAD_VALUE) + GetCurrentCaseDir);
    one_big_regex_str := '^Error\:' + PIPE + // noslz
      'Access violation' + PIPE + // noslz
      'An exception occurred' + PIPE + // noslz
      'Command Task FAILED' + PIPE + // noslz
      'Compile Failed' + PIPE + // noslz
      'Error in creating file' + PIPE + // noslz
      'Exception Caught' + PIPE + // noslz
      'Exception:' + PIPE + // noslz
      'expected but' + PIPE + // noslz
      'Floating point division' + PIPE + // noslz
      'Folder does not exist' + PIPE + // noslz
      'have not been freed' + PIPE + // noslz
      'Not Found\?' + PIPE + // noslz
      'Read of address' + PIPE + // noslz
      'The following errors occurred' + PIPE + // noslz
      'tried to compile' + PIPE + // noslz
      'TryExcept' + PIPE + // noslz
    // 'Unable to open file'           + PIPE + //noslz
      'Undeclared identifier' + PIPE + // noslz
      'Unhandled Exception' + PIPE + // noslz
      'Warning: Variable'; // noslz

    LineList := TStringList.Create;
    try
      LineList.Delimiter := '|';
      LineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter
      LineList.DelimitedText := one_big_regex_str;

      // List the Keywords
      // for i := 0 to lineList.Count - 1 do
      // Progress.Log(HYPHEN + LineList[i]);

    finally
      LineList.free;
    end;
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    log_fldr_pth := GetCurrentCaseDir + 'Logs'; // noslz
    if DirectoryExists(log_fldr_pth) then
    begin
      LogFiles_StringList := nil;
      try
        LogFiles_StringList := GetAllFileList(log_fldr_pth, '*.log', False, Progress); // noslz
        Progress.Log(RPad('Log Files Found:', RPAD_VALUE) + IntToStr(LogFiles_StringList.Count));
        for i := 0 to LogFiles_StringList.Count - 1 do
        begin
          if FileExists(OSFILENAME + LogFiles_StringList[i]) then
          begin
            script_name_str := ExtractFileName(CmdLine.Path);
            script_name_str := StringReplace(script_name_str, '.pas', '', [rfReplaceAll, rfIgnoreCase]); // noslz

            if (RegexMatch(LogFiles_StringList[i], script_name_str, True)) or (RegexMatch(LogFiles_StringList[i], 'Root Task', False)) or (RegexMatch(LogFiles_StringList[i], 'Check Log Files', True)) or
              (LogFiles_StringList[i] = 'SCRIPT - Check Log Files.log') then
            begin
              Continue;
            end;
            temp_SList := TStringList.Create;
            try
              try
                temp_SList.LoadFromFile(OSFILENAME + LogFiles_StringList[i]);
              except
                Progress.Log(RPad('Could not open (in use):', RPAD_VALUE) + LogFiles_StringList[i]);
              end;
              if assigned(temp_SList) and (temp_SList.Count > 0) then
              begin
                for j := 0 to temp_SList.Count - 1 do
                begin
                  if RegexMatch(temp_SList[j], one_big_regex_str, False) then
                  begin
                    Progress.Log('ERROR IN LOG: ' + LogFiles_StringList[i] + CR + HYPHEN + temp_SList[j]);
                    aStringList.Add('ERROR IN LOG: ' + LogFiles_StringList[i] + CR + HYPHEN + temp_SList[j]);
                    if FileExists(LogFiles_StringList[i]) then
                      ShellExecute(0, nil, 'explorer.exe', Pchar(LogFiles_StringList[i]), nil, 1)
                    else
                      Progress.Log('Log file not found: ' + LogFiles_StringList[i]);
                  end;
                end;
              end;
            finally
              FreeAndNil(temp_SList);
            end;
          end
          else
            Progress.Log('WARNING: Could not find log file: ' + LogFiles_StringList[i]);
        end;
        Progress.Log(RPad('Errors found:', RPAD_VALUE) + IntToStr(gRunTimeReport_StringList.Count));
      finally
        if assigned(LogFiles_StringList) then
          LogFiles_StringList.free;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Strip Illegal Characters
// ------------------------------------------------------------------------------
function StripIllegalChars(AString: string): string;
var
  x: integer;
const
  IllegalCharSet: set of char = ['|', '<', '>', '^', '+', '=', '?', '[', ']', '"', ';', ',', '*'];
begin
  for x := 1 to Length(AString) do
    if AString[x] in IllegalCharSet then
      AString[x] := '_';
  Result := AString;
end;

// ------------------------------------------------------------------------------
// Export to Global Folder
// ------------------------------------------------------------------------------
procedure CreateGlobalErrorRepport(aStringList: TStringList; case_name_str: string);
const
  RS_FOLDER_NOT_FOUND = 'Folder not found:';
  RS_ERROR_SAVING = 'Error saving:';
  RS_RESULT_SAVED = 'Result saved:';
  FLDR_ERROR = '-- ERROR --';
  FLDR_GLB = '\\Fexlabs\share\Global_Output';
var
  CurrentCaseDir: string;
  Export_Filename: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportDir_str: string;
  ExportTime: string;
  save_path: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  ExportDir_str := CurrentCaseDir + 'Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + ' - ' + ExportTime);
  if DirectoryExists(ExportDir_str) then
  begin
    if assigned(aStringList) and (aStringList.Count > 0) then
    begin
      Export_Filename := ExportDateTime + HYPHEN + SCRIPT_NAME + HYPHEN + case_name_str + '.txt';
      Export_Filename := StripIllegalChars(Export_Filename);
      save_path := FLDR_GLB + BS + FLDR_ERROR + BS + Export_Filename;
      if ForceDirectories(ExtractFileDir(save_path)) and DirectoryExists(ExtractFileDir(save_path)) then // Do not use OSFILENAME for network folders
        try
          aStringList.SaveToFile(save_path);
          Sleep(1000);
          if FileExists(save_path) then
            Progress.Log(RPad(RS_RESULT_SAVED, RPAD_VALUE) + save_path);
        except
          Progress.Log(RPad(RS_ERROR_SAVING, RPAD_VALUE) + save_path);
          Progress.DisplayMessageNow := RS_ERROR_SAVING + ExtractFileName(Export_Filename);
        end
      else
        Progress.Log(RPad(RS_FOLDER_NOT_FOUND, RPAD_VALUE) + FLDR_GLB);
    end;
  end
  else
    Progress.Log(RPad(RS_FOLDER_NOT_FOUND, RPAD_VALUE) + ExportDir_str);
end;

// ==============================================================================
// The start of the script
// ==============================================================================
const
  TEXT_STR = 'Log File Errors Found';
  OUTPUT_FLDR = 'Reports\'; // \Run Time Reports\';

var
  DataStore_FS: TDataStore;
  firstEntry: TEntry;

begin
  // Get Case Name
  DataStore_FS := GetDataStore('FileSystem'); // noslz
  if DataStore_FS = nil then
    Exit;
  try
    firstEntry := DataStore_FS.First;
    if firstEntry = nil then
      Exit;
    gCaseName_str := firstEntry.EntryName;
  finally
    DataStore_FS.free;
  end;

  // Report
  gRunTimeReport_StringList := TStringList.Create;
  try
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
    Sleep(5000); // Extra time for log files to finish writing
    CheckLogFiles(gRunTimeReport_StringList);
    if assigned(gRunTimeReport_StringList) and (gRunTimeReport_StringList.Count > 0) then
    begin
      Progress.DisplayMessageNow := IntToStr(gRunTimeReport_StringList.Count) + SPACE + 'errors';
      CreateRunTimeReport(gRunTimeReport_StringList, OUTPUT_FLDR, '!!! ERROR - ' + TEXT_STR, False, 'txt'); // Reports Folder - Error Found
      CreateGlobalErrorRepport(gRunTimeReport_StringList, gCaseName_str); // Global Folder - Error Found
    end
    else
    begin
      Progress.DisplayMessageNow := IntToStr(gRunTimeReport_StringList.Count) + SPACE + 'errors';
      gRunTimeReport_StringList.Add('No' + SPACE + TEXT_STR + '.');
      CreateRunTimeReport(gRunTimeReport_StringList, OUTPUT_FLDR, 'No ' + TEXT_STR, False, 'txt'); // Reports Folder - No Error Found
    end;
  finally
    gRunTimeReport_StringList.free;
  end;

  Progress.Log(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := (SCRIPT_NAME + ' finished.');

end.
