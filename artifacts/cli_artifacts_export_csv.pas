unit Export_Artifacts_To_CSV;

interface

uses
  // GUI,
  Classes, Clipbrd, Common, Container, DataEntry, DataStorage, DateUtils, Graphics, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  DCR = #13#10 + #13#10;
  HYPHEN = ' - ';
  LB = '(';
  OSFILENAME = '\\?\'; // This is needed for long file names
  RB = ')';
  RPAD_VALUE = 30;
  RUNNING = '...';
  SCRIPT_NAME = 'Artifacts to CSV';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gListBox_StringList: TStringList;
  gScriptFullPath_str: string;
  gSubFolder_str: string;

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

// ------------------------------------------------------------------------------
// Function: Right Pad
// ------------------------------------------------------------------------------
function RPad(AString: string; AChars: integer): string;
begin
  if AChars > length(AString) then
    Result := AString + StringofChar(' ', AChars - length(AString))
  else
    Result := AString;
end;

// ------------------------------------------------------------------------------
// Export CSV
// ------------------------------------------------------------------------------
procedure ExportCSV(aFolder: string; aFile: string; aTList: TList);
var
  export_dir_str: string;
  export_pth_str: string;
  tpac_export_csv: TPAC;
begin
  if not Progress.isRunning then
    Exit;
  Progress.DisplayMessageNow := 'Export CSV' + RUNNING;
  export_dir_str := GetCurrentCaseDir + 'Reports' + BS + SCRIPT_NAME + BS + aFolder;
  begin
    if assigned(aTList) and (aTList.Count > 0) then
    begin
      tpac_export_csv := NewProgress(False);
      if ForceDirectories(OSFILENAME + IncludeTrailingPathDelimiter(export_dir_str)) and DirectoryExists(export_dir_str) then
      begin
        export_pth_str := export_dir_str + BS + aFile + '.csv';
        Progress.Log('Export:' + SPACE + export_pth_str);
        try
          RunTask('TCommandTask_ExportEntryList', DATASTORE_ARTIFACTS, aTList, tpac_export_csv, ['filename=' + export_pth_str]); // noslz
        except
          Progress.Log(ATRY_EXCEPT_STR);
        end;
        while (tpac_export_csv.isRunning) and (Progress.isRunning) do
          Sleep(500); // Do not proceed until complete
        if not(Progress.isRunning) then
          tpac_export_csv.Cancel;
      end
      else
        Progress.Log('Could not create folder: ' + export_dir_str);
    end;
    Progress.incCurrentProgress;
  end;
end;

// ==============================================================================
// The start of the script
// ==============================================================================
var
  anEntry: TEntry;
  ArtFldr_TList: TList;
  Children_TList: TList;
  Datastore: TDataStore;
  i, p: integer;
  Working_TList: TList;

begin
  Progress.Log(SCRIPT_NAME + ' starting' + RUNNING);
  Progress.DisplayTitle := SCRIPT_NAME;
  gScriptFullPath_str := CmdLine.Path;

  Progress.Log(IntToStr(CmdLine.ParamCount) + ' processing parameters received: ');
  if CmdLine.ParamCount > 0 then
  begin
    for p := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad('Param ' + IntToStr(p) + ':', RPAD_VALUE) + CmdLine.params[p]);
    end;
    gSubFolder_str := CmdLine.params[0] + BS;
  end;

  Datastore := GetDataStore(DATASTORE_ARTIFACTS);
  if not assigned(Datastore) then
  begin
    Progress.Log('Not assigned a data store. The script will terminate.');
    Exit;
  end;

  try
    ArtFldr_TList := TList.Create;
    gListBox_StringList := TStringList.Create;
    Working_TList := TList.Create;
    try
      Working_TList := Datastore.GetEntireList;
      Children_TList := TList.Create;
      for i := 0 to Working_TList.Count - 1 do
      begin
        anEntry := TEntry(Working_TList[i]);
        Children_TList := Datastore.Children(anEntry, False);
        if (anEntry.dirlevel > 1) and anEntry.isDirectory and (Children_TList.Count > 0) then // and RegexMatch(anEntry.Directory, gSubFolder_str, false) then
        begin
          ArtFldr_TList.Add(anEntry);
        end;
        Children_TList.Clear;
      end;

      Progress.Log(RPad('Total Artifact Folders:', RPAD_VALUE) + IntToStr(ArtFldr_TList.Count));

      for i := 0 to ArtFldr_TList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        anEntry := TEntry(ArtFldr_TList[i]);
        Children_TList := TList.Create;
        try
          Children_TList := Datastore.Children(anEntry, False);
          gListBox_StringList.Add(anEntry.FullPathName + SPACE + LB + IntToStr(Children_TList.Count) + RB);
          if assigned(anEntry.Parent) then
            ExportCSV(anEntry.Parent.EntryName, anEntry.EntryName + SPACE + LB + IntToStr(Children_TList.Count) + RB, Children_TList); // folder, file, TList
        finally
          Children_TList.free;
        end;
      end;

    finally
      ArtFldr_TList.free;
      Working_TList.free;
      gListBox_StringList.free;
    end;

  finally
    Datastore.free;
  end;

  Progress.Log(SCRIPT_NAME + ' finished.');

end.
