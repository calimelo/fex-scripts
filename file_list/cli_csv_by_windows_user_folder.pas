unit csv_by_windows_user_folder;

interface

uses
  // GUI,
  Classes, Common, DataEntry, DataStorage, Graphics, Math, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 80;
  DCR = #13#10 + #13#10;
  HYPHEN = ' - ';
  LB = '(';
  OSFILENAME = '\\?\'; // This is needed for long file names
  RB = ')';
  RPAD_VALUE = 35;
  RUNNING = '...';
  // SCRIPT_NAME = 'Script Name';
  SPACE = ' ';

var
  Array_of_TList: Array of TList;

implementation

// ------------------------------------------------------------------------------
// Function: Right Pad
// ------------------------------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

/// /------------------------------------------------------------------------------
/// / Procedure: Message User
/// /------------------------------------------------------------------------------
// procedure MessageUser(aString: string);
// begin
// MessageBox(aString, SCRIPT_NAME, (MB_OK or MB_ICONINFORMATION or MB_SETFOREGROUND or MB_TOPMOST));
// Progress.Log(aString);
// end;

// ------------------------------------------------------------------------------
// Procedure: Find Entries By Path
// ------------------------------------------------------------------------------
procedure Find_Entries_By_Path(aDataStore: TDataStore; astr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);
var
  fEntry: TEntry;
  s: integer;
begin
  if assigned(aDataStore) and (aDataStore.Count > 1) then
  begin
    FoundList.Clear;
    aDataStore.FindEntriesByPath(nil, astr, FoundList);
    for s := 0 to FoundList.Count - 1 do
    begin
      fEntry := TEntry(FoundList[s]);
      AllFoundListUnique.Add(fEntry);
    end;
  end;
end;

procedure ExportResultsToFile(savename_str: string; aTList: TList);
var
  export_dir: string;
  export_pth: string;
  tpac_export_csv: TPAC;
begin
  if not Progress.isRunning then
    Exit;
  Progress.DisplayMessageNow := 'Export CSV' + RUNNING;
  Progress.Initialize(Length(Array_of_TList), 'Exporting CSV' + RUNNING);
  export_dir := GetCurrentCaseDir + 'Reports'; // noslz
  if assigned(aTList) then
  begin
    tpac_export_csv := NewProgress(False);
    if ForceDirectories(OSFILENAME + IncludeTrailingPathDelimiter(export_dir)) and DirectoryExists(export_dir) then
    begin
      export_pth := export_dir + BS + 'Windows_User_' + savename_str + '.csv';
      try
        RunTask('TCommandTask_ExportEntryList', DATASTORE_FILESYSTEM, aTList, tpac_export_csv, ['filename=' + export_pth]); // noslz
      except
        Progress.Log(ATRY_EXCEPT_STR + HYPHEN + 'Saving CSV');
      end;
      while (tpac_export_csv.isRunning) and (Progress.isRunning) do
        Sleep(500); // Do not proceed until complete
      if not(Progress.isRunning) then
        tpac_export_csv.Cancel;
    end
    else
      Progress.Log('Could not create folder: ' + export_dir);
    if FileExists(export_pth) then
      Progress.Log('CSV was exported:' + SPACE + export_pth)
    else
      Progress.Log('CSV not exported:' + SPACE + export_pth);
  end;
  Sleep(500); // Pause between saving files
end;

// ==============================================================================
// Start of Script
// ==============================================================================
var
  AllFoundListUnique: TUniqueListOfEntries;
  anEntry: TEntry;
  DataStore_FS: TDataStore;
  Enum: TEntryEnumerator;
  FindEntries_StringList: TStringList;
  FoundList: TList;
  i: integer;
  savename_str: string;
  WindowsUserFolders_StringList: TStringList;

begin
  Progress.Log('Script started' + RUNNING);
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore_FS = nil then
    Exit;
  try
    AllFoundListUnique := TUniqueListOfEntries.Create;
    WindowsUserFolders_StringList := TStringList.Create;
    try
      FoundList := TList.Create;
      FindEntries_StringList := TStringList.Create;
      try
        FindEntries_StringList.Add('**\Root\Users\*'); // noslz

        // Find the files by path and add to AllFoundListUnique
        Progress.Initialize(FindEntries_StringList.Count, 'Find Windows User folders by path' + RUNNING);
        for i := 0 to FindEntries_StringList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          Find_Entries_By_Path(DataStore_FS, FindEntries_StringList[i], FoundList, AllFoundListUnique);
          Progress.incCurrentProgress;
        end;

        // Move the AllFoundListUnique list into a TList
        if assigned(AllFoundListUnique) and (AllFoundListUnique.Count > 0) then
        begin
          Enum := AllFoundListUnique.GetEnumerator;
          while Enum.MoveNext do
          begin
            anEntry := Enum.Current;
            if anEntry.isDirectory then
            begin
              WindowsUserFolders_StringList.Add(anEntry.FullPathName);
            end;
          end;
        end;
        Progress.Log(RPad('Found Windows User Folders:', RPAD_VALUE) + inttostr(WindowsUserFolders_StringList.Count));
        Progress.Log(StringOfChar('-', CHAR_LENGTH));

        if WindowsUserFolders_StringList.Count > 0 then
        begin

          // Create an Array of StringList equal to the number of Windows User folders
          setlength(Array_of_TList, WindowsUserFolders_StringList.Count);
          for i := 0 to WindowsUserFolders_StringList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            Array_of_TList[i] := TList.Create;
          end;

          // Loop the File System and Create Windows User folder StringLists
          Progress.Log('Collecting files by Windows User path' + RUNNING);
          anEntry := DataStore_FS.First;
          if not assigned(anEntry) then
            Exit;
          Progress.Initialize(DataStore_FS.Count, 'Collecting files by Windows User path' + RUNNING);
          while assigned(anEntry) and (Progress.isRunning) do
          begin
            Progress.incCurrentProgress;

            for i := 0 to WindowsUserFolders_StringList.Count - 1 do
            begin
              if POS(WindowsUserFolders_StringList[i] + BS, anEntry.FullPathName) > 0 then
              begin
                Array_of_TList(i).Add(anEntry);
                break;
              end;
            end;

            Progress.incCurrentProgress;
            anEntry := DataStore_FS.Next;
          end;

          // Log the counts
          for i := 0 to Length(Array_of_TList) - 1 do
          begin
            Progress.Log(inttostr(i + 1) + ': ' + WindowsUserFolders_StringList[i] + SPACE + '= ' + SPACE + inttostr(Array_of_TList(i).Count));
          end;
          Progress.Log(StringOfChar('-', CHAR_LENGTH));

          // Save the StringList to .txt files
          Progress.Log('Saving to CSV' + RUNNING);
          for i := 0 to Length(Array_of_TList) - 1 do
          begin
            if not Progress.isRunning then
              break;
            savename_str := ExtractFileName(WindowsUserFolders_StringList[i]);
            ExportResultsToFile(savename_str, Array_of_TList(i));
          end;
          Progress.Log(StringOfChar('-', CHAR_LENGTH));

        end;
      finally
        FoundList.free;
        FindEntries_StringList.free;
      end;

    finally
      AllFoundListUnique := TUniqueListOfEntries.Create;
      for i := 0 to Length(Array_of_TList) - 1 do
        Array_of_TList[i].free;
      WindowsUserFolders_StringList.free;
    end;

  finally
    DataStore_FS.free;
  end;
  Progress.Log('Script finished.');

end.
