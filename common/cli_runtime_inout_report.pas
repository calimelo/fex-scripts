unit Runtime_InOut_Report;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, DateUtils, DIRegEx, Graphics, Math, RegEx, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  CHAR_LENGTH = 80;
  HYPHEN = ' - ';
  RPAD_VALUE = 40;
  RUNNING = '...';
  SCRIPT_NAME = 'RunTime InOut';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gRunTimeReport_StringList: TStringList;

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
// Procedure: Create RunTime Report (PDF or TXT)
// ------------------------------------------------------------------------------
procedure CreateRunTimeReport(aStringList: TStringList; save_name_str: string; DT_In_FileName_bl: boolean; pdf_or_txt_str: string);
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
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports'; // \Run Time Reports\';
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
            Progress.Log('Success Creating: ' + SaveName);
        end
        else
        begin
          aStringList.SaveToFile(SaveName);
          Sleep(200);
          if FileExists(SaveName) then
            Progress.Log('Success Creating: ' + SaveName)
          else
            Progress.Log('Error creating runtime report: ' + SaveName);
        end;
      end
      else
        Progress.Log('Error creating runtime report: ' + SaveName);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Exception creating runtime report: ' + SaveName);
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

// ==============================================================================
// The start of the script
// ==============================================================================
begin
  begin
    gRunTimeReport_StringList := TStringList.Create;
    try

      if assigned(inList) then
      begin
        Progress.DisplayMessageNow := 'InList = ' + IntToStr(inList.Count);
        gRunTimeReport_StringList.Add('InList count ' + IntToStr(inList.Count))
      end
      else
        gRunTimeReport_StringList.Add('InList: Not assigned');

      if assigned(outList) then
        gRunTimeReport_StringList.Add('OutList count ' + IntToStr(outList.Count))
      else
        gRunTimeReport_StringList.Add('outList: Not assigned');

      CreateRunTimeReport(gRunTimeReport_StringList, SCRIPT_NAME, True, 'txt'); // True = include date in filename

    finally
      gRunTimeReport_StringList.free;
    end;
  end;

end.
