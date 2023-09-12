unit cli_calculate_export_size;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  HYPHEN = ' - ';
  RPAD_VALUE = 30;
  SPACE = ' ';

implementation

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
function ParametersReceived: integer;
var
  i: integer;
begin
  Result := 0;
  Progress.Log(StringOfChar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := CmdLine.ParamCount;
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
    end;
  end
  else
  begin
    Progress.Log(RPad('Parameters received:', RPAD_VALUE) + '0');
  end;
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Procedure: Create PDF
// ------------------------------------------------------------------------------
procedure CreateRunTimePDF(aStringList: TStringList; save_name_str: string; font_size_int: integer; DT_In_FileName_bl: boolean);
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
  sleep(1000);
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  if DT_In_FileName_bl then
    ExportDateTime := (ExportDate + HYPHEN + ExportTime + HYPHEN)
  else
    ExportDateTime := '';
  SaveName := ExportedDir + ExportDateTime + save_name_str;
  if ExtractFileExt(SaveName) = '' then
    SaveName := SaveName + '.pdf';
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if GeneratePDF(SaveName, aStringList, font_size_int) then
          Progress.Log('Success Creating: ' + SaveName)
      end
      else
        Progress.Log('Failed Creating: ' + SaveName);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Exception creating runtime folder');
    end;
  end
  else
    Progress.Log('There is no current case folder');
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
// Start of script
// ------------------------------------------------------------------------------
var
  i: integer;
  anEntry: TEntry;
  total_logical_size: int64;
  RunTime_Report_StringList: TStringList;
  display_size_str: string;
  type_str: string;
  filename_size_str: string;

begin

  ParametersReceived;
  ListExists(InList, 'InList');

  if assigned(InList) and (InList.Count > 0) then
  begin
    for i := 0 to InList.Count - 1 do
    begin
      anEntry := TEntry(InList[i]);
      total_logical_size := total_logical_size + anEntry.LogicalSize;
    end;
  end;

  // ----------------------------------------------------------------------------
  // RunTime Report
  // ----------------------------------------------------------------------------
  filename_size_str := '';
  type_str := '';
  if CmdLine.ParamCount > 0 then
    type_str := SPACE + CmdLine.params[0];

  RunTime_Report_StringList := TStringList.Create;
  try

    if trim(type_str) <> '' then
    begin
      RunTime_Report_StringList.Add(trim(type_str));
      RunTime_Report_StringList.Add(StringOfChar('-', 80));
    end;

    if assigned(InList) then
      RunTime_Report_StringList.Add(Format('%-20s %-20s', ['Total items:', IntToStr(InList.Count)]));

    if (total_logical_size >= 1048576) then // 1 megabyte
    begin
      if (total_logical_size >= 1073741824) then // 1 gigabyte
      begin
        display_size_str := Format('%-20s %1.2n GB', ['Total Size:', total_logical_size / (1024 * 1024 * 1024)]);
        filename_size_str := Format('%1.0n GB', [total_logical_size / (1024 * 1024 * 1024)]);
        RunTime_Report_StringList.Add(display_size_str);
      end
      else
      begin
        display_size_str := (Format('%-20s %1.2n MB', ['Total Size:', total_logical_size / (1024 * 1024)]));
        filename_size_str := Format('%1.0n MB', [total_logical_size / (1024 * 1024)]);
        RunTime_Report_StringList.Add(display_size_str);
      end
    end
    else
    begin
      display_size_str := Format('%-20s %-20s bytes', ['Total Size:', IntToStr(total_logical_size)]);
      RunTime_Report_StringList.Add(display_size_str);
      filename_size_str := IntToStr(total_logical_size) + SPACE + 'Bytes';
    end;

    filename_size_str := HYPHEN + filename_size_str;
    CreateRunTimePDF(RunTime_Report_StringList, type_str + filename_size_str, 10, False); // True is DT in Filename.PDF
    Progress.Log(RunTime_Report_StringList.text);

  finally
    RunTime_Report_StringList.free;
  end;

  Progress.Log('Script finished.');

end.
