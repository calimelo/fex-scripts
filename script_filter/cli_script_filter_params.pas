unit script_filter;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

implementation

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 80;
  DCR = #13#10 + #13#10;
  HYPHEN = ' - ';
  OSFILENAME = '\\?\'; // This is needed for long file names
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Script Filter';
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
// Function: Parameters Received
// ------------------------------------------------------------------------------
function params: string;
var
  i: integer;
begin
  Result := '';
  Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
  if (CmdLine.ParamCount = 1) then
  begin
    Progress.Log(StringOfChar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      if (trim(CmdLine.params[i]) <> '') then
      begin
        Result := Result + CmdLine.params[i];
      end;
    end;
  end
  else
  begin
    Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount) + SPACE + '(Expected 1)');
  end;
  trim(Result);
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Function: Make sure the InList exist
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
// Function: Create a unique filename
// ------------------------------------------------------------------------------
function GetUniqueFileName(AFileName: string): string;
var
  fnum: integer;
  fname: string;
  fpath: string;
  fext: string;
begin
  Result := AFileName;
  if FileExists(AFileName) then
  begin
    fext := ExtractFileExt(AFileName);
    fnum := 1;
    fname := ExtractFileName(AFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(AFileName);
    while FileExists(fpath + fname + '_' + IntToStr(fnum) + fext) do
    begin
      fnum := fnum + 1;
    end;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Export to CSV (TCommandTask)
// ------------------------------------------------------------------------------
procedure ExportResultsToFile(savename_str: string; aTList: TList);
var
  export_dir: string;
  export_pth: string;
  tpac_export_csv: TPAC;
begin
  if not Progress.isRunning then
    Exit;
  Progress.DisplayMessageNow := 'Export CSV' + RUNNING;
  export_dir := GetCurrentCaseDir + 'Reports'; // noslz
  if assigned(aTList) then
  begin
    tpac_export_csv := NewProgress(False);
    if ForceDirectories(OSFILENAME + IncludeTrailingPathDelimiter(export_dir)) and DirectoryExists(export_dir) then
    begin
      export_pth := export_dir + BS + savename_str + '.csv'; // noslz
      if FileExists(export_pth) then
        export_pth := GetUniqueFileName(export_pth);
      try
        RunTask('TCommandTask_ExportEntryList', DATASTORE_FILESYSTEM, aTList, tpac_export_csv, ['filename=' + export_pth]); // noslz
      except
        Progress.Log(ATRY_EXCEPT_STR + HYPHEN + 'Saving CSV');
      end;
      while (tpac_export_csv.isRunning) and (Progress.isRunning) do
        Sleep(500); // Do not proceed until complete
      if not(Progress.isRunning) then
        tpac_export_csv.Cancel;
      if FileExists(export_pth) then
        Progress.Log(RPad('Exported CSV:', RPAD_VALUE) + export_pth)
      else
        Progress.Log(RPad('Error exporting CSV:', RPAD_VALUE) + export_pth);
    end
    else
      Progress.Log(RPad('Error creating folder:', RPAD_VALUE) + export_dir);
  end;
  Sleep(500); // Pause between saving files
end;

// ==============================================================================
// Start of the script
// ==============================================================================
var
  anEntry: TEntry;
  cmdparam_regex_str: string;
  Filtered_TList: TList;
  i: integer;

begin
  Progress.Log(StringOfChar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  // Params Received
  cmdparam_regex_str := params;
  Progress.Log(RPad('cmdparam_regex_str:', RPAD_VALUE) + cmdparam_regex_str);
  if trim(cmdparam_regex_str) = '' then
    Exit;

  // Check that InList is not empty
  if (not ListExists(InList, 'InList')) then
  begin
    Progress.Log('No InList');
    Exit;
  end;

  // InList Count
  if InList.Count <= 0 then
  begin
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Exit;
  end;

  // Loop Entries
  Filtered_TList := TList.Create;
  try
    Progress.Log('Regex string: ' + cmdparam_regex_str);
    if trim(cmdparam_regex_str) <> '' then
    begin
      Progress.Log('Searching' + SPACE + IntToStr(InList.Count));
      Progress.Initialize(InList.Count, 'Processing...');
      for i := 0 to InList.Count - 1 do
      begin
        anEntry := TEntry(InList[i]);
        if (RegexMatch(anEntry.FullPathName, cmdparam_regex_str, False)) then
        begin
          Filtered_TList.add(anEntry);
          Progress.Log(anEntry.EntryName);
        end;
      end;
      Progress.IncCurrentProgress;
    end;
    Progress.DisplayMessageNow := 'Filtered:' + SPACE + IntToStr(Filtered_TList.Count);
    Progress.Log(RPad('Filtered:', RPAD_VALUE) + IntToStr(Filtered_TList.Count));
    Progress.Log(StringOfChar('-', 80));

    ExportResultsToFile('Param_Filter', Filtered_TList);

  finally
    Filtered_TList.free;
  end;

  Progress.Log(StringOfChar('-', 80));

  // Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
end.
