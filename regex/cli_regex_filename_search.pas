unit cli_regex_filename_search;

interface

uses
  // GUI,
  Classes, Common, DataEntry, DataStorage, Graphics, Math, RegEx, SysUtils;

const
  MAXIMUM_HITS = 500;

  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 80;
  CR = #13#10;
  CLN = ':';
  DCR = #13#10 + #13#10;
  FLDR_FILENAME_SEARCH_REGEX = 'FOLDER_FILENAME_REGEX_SEARCH';
  FLDR_GLB = '\\Fexlabs\share\Global_Output';
  FLDR_GLB2 = '\\192.168.0.24\SHARE\Global_Output';
  FLDR_REPORTS = 'Reports';
  FORMAT_STRING = '%-15s %-15s %-6s %-30s %-50s %-50s';
  FORMAT_STRING_SHORT = '%-70s %-20s';
  HYPHEN = ' - ';
  HYPHEN_NS = '-';
  LB = '(';
  RB = ')';
  RPAD_VALUE = 30;
  RUNNING = '...';
  SAVED_FILE_STR = 'Saved File';
  SCRIPT_NAME = 'Folder and Filename Regex Search';
  SPACE = ' ';
  SUMMARY_RPT = 'Summary Report.txt';
  TSWT = 'The script will terminate.';

var
  BookmarkHits_TList: TList;
  colFilenameSearch: TDataStoreField;
  FileName_Counter: array [0 .. 2000] of integer;
  gCaseName: string;
  gExportDate: string;
  gExportDateTime: string;
  gExportTime: string;
  gDevice_TList: TList;
  gkeywords_str: string;
  gOneBigRegex: string;
  gReport_StringList: TStringList;
  gSearch_StringList: TStringList;
  gStartSummary_str: string;
  gRegex_Words_StringList: TStringList;

procedure ConsoleLog(AString: string);
function RPad(AString: string; AChars: integer): string;

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

// ------------------------------------------------------------------------------
// Procedure: Console Log - Memo and Messages
// ------------------------------------------------------------------------------
procedure ConsoleLog(AString: string);
begin
  Progress.Log(AString);
  if assigned(gReport_StringList) then
    gReport_StringList.Add(AString);
end;

// ------------------------------------------------------------------------------
// Procedure: Right Pad
// ------------------------------------------------------------------------------
function RPad(AString: string; AChars: integer): string;
begin
  while length(AString) < AChars do
    AString := AString + ' ';
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
  ConsoleLog(Stringofchar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := CmdLine.ParamCount;
    ConsoleLog(RPad('Parameters received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      if not Progress.isRunning then
        break;
      ConsoleLog(RPad(' Parameter ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
    end;
  end
  else
    ConsoleLog('No parameters were received.' + SPACE + 'Expecting keywords filename.');
  ConsoleLog(Stringofchar('-', 80));
end;

// ------------------------------------------------------------------------------
// Function: File Name RegEx Search Index
// ------------------------------------------------------------------------------
function FileNameRegExSearchIndex(anEntry: TEntry): boolean;
var
  deleted_status_str: string;
  DeterminedFileDriverInfo: TFileTypeInformation;
  DeviceEntry: TEntry;
  DeviceName_str: string;
  file_signature_str: string;
  FullPathNoComma: string;
  i: integer;
begin
  Result := False;
  for i := 0 to gRegex_Words_StringList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    if (RegexMatch(anEntry.EntryName, gRegex_Words_StringList[i], False)) or (RegexMatch(anEntry.FullPathName, gRegex_Words_StringList[i], False)) then
    begin
      DeviceName_str := '';
      DeviceEntry := GetDeviceEntry(anEntry);
      if assigned(DeviceEntry) then
        DeviceName_str := DeviceEntry.EntryName;
      DetermineFileType(anEntry);
      DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
      file_signature_str := '';
      file_signature_str := DeterminedFileDriverInfo.ShortDisplayName;
      begin
        FileName_Counter[i] := FileName_Counter[i] + 1;
        FullPathNoComma := StringReplace('* ' + anEntry.FullPathName, ',', '_', [rfReplaceAll]);
        if anEntry.isDeleted then
          deleted_status_str := 'Y'
        else
          deleted_status_str := '';
        ConsoleLog(anEntry.FullPathName);
        // ConsoleLog((format(FORMAT_STRING,[IntToStr(anEntry.ID), file_signature_str, deleted_status_str, DeviceName_str, gRegex_Words_StringList[i], anEntry.FullPathName])));
        // ConsoleLog(IntToStr(anEntry.ID) + ',' + file_signature_str + ',' + deleted_status_str + ',' + DeviceName_str + ',' + gRegex_Words_StringList[i] + ',' + FullPathNoComma);
        Result := True;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: File Name RegEx Search - Quick Concatenate Regex Method
// ------------------------------------------------------------------------------
function FileNameRegExSearch(anEntry: TEntry): boolean;
var
  aName: string;
begin
  Result := False;
  aName := anEntry.EntryName;
  if (RegexMatch(aName, gOneBigRegex, False)) then
    Result := FileNameRegExSearchIndex(anEntry);
  // Also match full path if selected
  // if (not Result) then
  // begin
  // aName := anEntry.FullPathName;
  // if (RegexMatch(aName, gOneBigRegex, False)) then
  // Result := FileNameRegExSearchIndex(anEntry);
  // end;
end;

// ------------------------------------------------------------------------------
// Function: Test Valid Regex
// ------------------------------------------------------------------------------
function IsValidRegEx(aStr: string): boolean;
var
  aRegEx: TRegEx;
begin
  Result := False;
  aRegEx := TRegEx.Create;
  try
    aRegEx.SearchTerm := aStr;
    Result := aRegEx.LastError = 0;
  finally
    aRegEx.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Bookmark Files
// ------------------------------------------------------------------------------
procedure BookmarkHits(comment_str: string);
var
  bmFolder: TEntry;
begin
  if assigned(BookmarkHits_TList) then
  begin
    bmFolder := FindBookmarkByName(SCRIPT_NAME);
    if bmFolder = nil then
      bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), SCRIPT_NAME, comment_str);
    if assigned(bmFolder) then
    begin
      AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, BookmarkHits_TList, '');
    end
    else
      Progress.Log('Not assigned bmFolder.');
  end;
end;

// ------------------------------------------------------------------------------
// Function: Create a unique filename
// ------------------------------------------------------------------------------
function GetUniqueFileName(aFileName: string): string;
var
  fext: string;
  fname: string;
  fnum: integer;
  fpath: string;
begin
  Result := aFileName;
  if FileExists(aFileName) then
  begin
    fext := ExtractFileExt(aFileName);
    fnum := 1;
    fname := ExtractFileName(aFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(aFileName);
    while FileExists(fpath + fname + '_' + IntToStr(fnum) + fext) do
      fnum := fnum + 1;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Save FEXLAB Global
// ------------------------------------------------------------------------------
function FexLab_Global_Save(aStringList: TStringList; sum_int: integer): boolean;
var
  ExportDate: string;
  ExportDateTime: string;
  ExportTime: string;
  FexLab_Global_Fnm_str: string;
  FexLab_Global_Fldr_str: string;
  FexLab_Global_Pth_str: string;
  ref_str: string;
  sum_int_str: string;
  the_dev_str: string;

begin
  Result := False;

  // Test for Global folder
  if DirectoryExists(FLDR_GLB) then
  begin
    FexLab_Global_Fldr_str := FLDR_GLB;
    Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(FexLab_Global_Fldr_str), True), RPAD_VALUE) + FLDR_GLB);
  end

  else if DirectoryExists(FLDR_GLB2) then
  begin
    FexLab_Global_Fldr_str := FLDR_GLB2;
    Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(FLDR_GLB2), True), RPAD_VALUE) + FLDR_GLB2);
  end

  else
  begin
    FexLab_Global_Fldr_str := '';
    ConsoleLog('Could not find Global folder.');
    Exit;
  end;

  // Filename - Create date time
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + '-' + ExportTime);

  // Filename - Create device name
  the_dev_str := '';
  if assigned(gDevice_TList) and (gDevice_TList.Count = 1) then
    try
      the_dev_str := TEntry(gDevice_TList[0]).EntryName
    except
      the_dev_str := gCaseName;
    end
  else
    the_dev_str := gCaseName;

  sum_int_str := LB + Format('%.*d', [6, sum_int]) + RB; // Padded with leading 0s

  // Shorten the summary filename if possible
  if gCaseName = the_dev_str then
    ref_str := gCaseName
  else
    ref_str := gCaseName + HYPHEN + the_dev_str;

  FexLab_Global_Fnm_str := GetUniqueFileName(SCRIPT_NAME + SPACE + sum_int_str + HYPHEN + ref_str + '.txt');

  // Create the folder and save the file
  FexLab_Global_Pth_str := FexLab_Global_Fldr_str + BS + FLDR_FILENAME_SEARCH_REGEX;
  if ForceDirectories(IncludeTrailingPathDelimiter(FexLab_Global_Pth_str)) and DirectoryExists(FexLab_Global_Pth_str) then
    try
      aStringList.SaveToFile(FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str);
      Sleep(1000);
    except
      on e: exception do
      begin
        ConsoleLog(RPad(ATRY_EXCEPT_STR + 'A.' + HYPHEN + FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str + CR + ATRY_EXCEPT_STR, RPAD_VALUE) + e.message);
        Result := False;
        Exit;
      end;
    end;

  // Test to see if the file was saved
  if FileExists(FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str) then
  begin
    ConsoleLog(RPad(SAVED_FILE_STR + SPACE + '(FEXLAB Global)' + CLN, RPAD_VALUE) + FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str);
    Result := True;
  end
  else
  begin
    ConsoleLog(RPad('Error saving file' + SPACE + '(FEXLAB Global)' + CLN, RPAD_VALUE) + FexLab_Global_Pth_str + BS + FexLab_Global_Fnm_str);
    Result := False;
  end;
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));
end;

procedure GetDevices(aDeviceList: TList);
var
  DataStore_EV: TDataStore;
  tempEntry: TEntry;
begin
  if not Progress.isRunning then
    Exit;
  if assigned(aDeviceList) then
  begin
    aDeviceList.Clear;
    DataStore_EV := GetDataStore(DATASTORE_EVIDENCE);
    if not assigned(DataStore_EV) then
      Exit;
    try
      tempEntry := DataStore_EV.First;
      while assigned(tempEntry) and (Progress.isRunning) do
      begin
        if tempEntry.IsDevice then
          aDeviceList.Add(tempEntry);
        tempEntry := DataStore_EV.next;
      end;
      Progress.Log(RPad('Current devices:', RPAD_VALUE) + IntToStr(aDeviceList.Count)); // noslz
    finally
      DataStore_EV.free;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
const
  TSWT = 'The script will terminate.';
var
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
  Start_StringList: TStringList;
begin
  Result := False;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    ConsoleLog(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  try
    Start_StringList := TStringList.Create;
    try
      StartCheckEntry := StartCheckDataStore.First;
      if not assigned(StartCheckEntry) then
      begin
        ConsoleLog('There is no current case.' + SPACE + TSWT);
        Exit;
      end
      else
        gCaseName := StartCheckEntry.EntryName;
      Start_StringList.Add(Stringofchar('-', CHAR_LENGTH));
      Start_StringList.Add(RPad('Case Name' + CLN, RPAD_VALUE) + gCaseName);
      Start_StringList.Add(RPad('Script Name' + CLN, RPAD_VALUE) + SCRIPT_NAME);
      Start_StringList.Add(RPad('Date Run' + CLN, RPAD_VALUE) + DateTimeToStr(now));
      Start_StringList.Add(RPad('FEX Version' + CLN, RPAD_VALUE) + CurrentVersion);
      Start_StringList.Add(Stringofchar('-', CHAR_LENGTH));
      gStartSummary_str := Start_StringList.Text;
      if StartCheckDataStore.Count <= 1 then
      begin
        ConsoleLog('There are no files in the File System module.' + SPACE + TSWT);
        Exit;
      end;
      Result := True; // If it makes it this far then StartCheck is True
    finally
      Start_StringList.free;
    end;
  finally
    FreeAndNil(StartCheckDataStore);
  end;
end;

// ==============================================================================
// Start of the Script
// ==============================================================================
var
  anEntry: TEntry;
  CommentString: string;
  DataStore_FS: TDataStore;
  ExportFolder: string;
  FS_File_Found_Count: integer;
  hits_comment_str: string;
  i, j: integer;
  keyword_txt_filename: string;
  Keyword_Hits_Comment_StringList: TStringList;
  KeywordsPath_str: string;
  lnk_to_pdf_report_str: string;
  ScriptFolder_str: string;
  ScriptPath_str: string;
  tmp_str: string;

begin
  ConsoleLog('Starting script' + RUNNING);

  if not StartingChecks then
    Exit;

  gReport_StringList := TStringList.Create;
  try
    ParametersReceived;

    if CmdLine.ParamCount > 0 then
    begin
      keyword_txt_filename := CmdLine.params[0];
    end;

    // Locate the regex keywords file
    ScriptPath_str := CmdLine.Path;
    ScriptFolder_str := ExtractFilePath(ScriptPath_str);
    KeywordsPath_str := ScriptFolder_str + 'regex_keywords' + BS + keyword_txt_filename;
    if FileExists(KeywordsPath_str) then
    begin
      ConsoleLog(RPad('Found keywords file:', RPAD_VALUE) + KeywordsPath_str);
      ConsoleLog(Stringofchar('-', CHAR_LENGTH));
    end
    else
    begin
      ConsoleLog('Cannot locate keywords file: ' + KeywordsPath_str + '.' + CR + TSWT);
      Exit;
    end;

    // Read the regex keywords file
    gRegex_Words_StringList := TStringList.Create;
    try
      gRegex_Words_StringList.Delimiter := '|';
      gRegex_Words_StringList.StrictDelimiter := True;
      gRegex_Words_StringList.LoadFromFile(KeywordsPath_str);

      // Remove any comment strings
      for i := gRegex_Words_StringList.Count - 1 downto 0 do
      begin
        if not Progress.isRunning then
          break;
        CommentString := copy(gRegex_Words_StringList[i], 1, 1);
        if CommentString = '#' then
          gRegex_Words_StringList.Delete(i);
      end;

      // Log the keywords
      if gRegex_Words_StringList.Count > 0 then
      begin
        ConsoleLog(RPad('Keywords in File:', RPAD_VALUE) + IntToStr(gRegex_Words_StringList.Count));
      end
      else
      begin
        ConsoleLog('No keywords found.' + SPACE + TSWT);
        Exit;
      end;

      gkeywords_str := gRegex_Words_StringList.Text;

      // Convert the keywords into one big regex statement
      gOneBigRegex := gRegex_Words_StringList.DelimitedText;
      if IsValidRegEx(gOneBigRegex) then
      begin
        ConsoleLog(RPad('Is Keywords Regex Valid:', RPAD_VALUE) + 'True');
        // ConsoleLog(gOneBigRegex);
      end
      else
      begin
        ConsoleLog('Invalid regex.' + SPACE + TSWT);
        // ConsoleLog(gOneBigRegex);
        Exit;
      end;

      // Logging
      ConsoleLog(RPad('Maximum Hits:', RPAD_VALUE) + IntToStr(MAXIMUM_HITS));
      ConsoleLog(Stringofchar('-', CHAR_LENGTH));

      // Initialize
      FS_File_Found_Count := 0;
      gExportDate := formatdatetime('yyyy-mm-dd', now);
      gExportTime := formatdatetime('hh-nn-ss', now);
      gExportDateTime := (gExportDate + '-' + gExportTime);
      ExportFolder := 'Export - ' + gExportDateTime;
      colFilenameSearch := AddMetaDataField('HIT', ftString);

      DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
      if not assigned(DataStore_FS) then
        Exit;

      try
        anEntry := DataStore_FS.First;
        if not assigned(anEntry) then
          Exit;

        // Create Lists
        gDevice_TList := TList.Create;
        BookmarkHits_TList := TList.Create;
        gSearch_StringList := TStringList.Create;
        try
          // Get Devices
          GetDevices(gDevice_TList);

          // Set the search string
          gSearch_StringList.Text := gOneBigRegex;

          // Loop File System and search for regex hits --------------------------------
          Progress.Max := DataStore_FS.Count;
          Progress.CurrentPosition := 0;
          while assigned(anEntry) and (Progress.isRunning) do
          begin
            if FileNameRegExSearch(anEntry) then
            begin
              if FS_File_Found_Count < MAXIMUM_HITS then
                BookmarkHits_TList.Add(anEntry);
              if assigned(colFilenameSearch) then
                colFilenameSearch.AsString[anEntry] := 'HIT';
              FS_File_Found_Count := FS_File_Found_Count + 1;
              Progress.DisplayMessages := ('Searching File System - Found: ' + IntToStr(FS_File_Found_Count) + RUNNING);
              if FS_File_Found_Count >= MAXIMUM_HITS then
              begin
                ConsoleLog('MAXIMUM MATCHES REACHED: ' + IntToStr(MAXIMUM_HITS));
                break;
              end;
            end;
            Progress.IncCurrentProgress;
            anEntry := DataStore_FS.next;
          end;
          ConsoleLog(Stringofchar('-', CHAR_LENGTH));

          if FS_File_Found_Count > 0 then
            ConsoleLog(IntToStr(FS_File_Found_Count) + ' files found.')
          else
            ConsoleLog('No files found.');
          ConsoleLog(Stringofchar('-', CHAR_LENGTH));

          // Match Summary ---------------------------------------------------------------
          Keyword_Hits_Comment_StringList := TStringList.Create;
          try
            Keyword_Hits_Comment_StringList.Add(Format(FORMAT_STRING_SHORT, ['RegEx Term', 'Hits']));
            Keyword_Hits_Comment_StringList.Add(Format(FORMAT_STRING_SHORT, ['----------', '----']));
            for j := 0 to gRegex_Words_StringList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              tmp_str := gRegex_Words_StringList(j);
              if length(tmp_str) > 60 then
                tmp_str := copy(tmp_str, 1, 60) + RUNNING;
              if FileName_Counter[j] <> 0 then
                Keyword_Hits_Comment_StringList.Add(Format(FORMAT_STRING_SHORT, [tmp_str, IntToStr(FileName_Counter[j])]))
              else
                Keyword_Hits_Comment_StringList.Add(Format(FORMAT_STRING_SHORT, [tmp_str, '-']));
            end;
            Keyword_Hits_Comment_StringList.Add(Stringofchar('-', CHAR_LENGTH));
            hits_comment_str := Keyword_Hits_Comment_StringList.Text;
          finally
            Keyword_Hits_Comment_StringList.free;
          end;

          // Bookmark the files -----------------------------------------------------------
          if assigned(BookmarkHits_TList) then
            BookmarkHits(hits_comment_str);

        finally
          BookmarkHits_TList.free;
          gDevice_TList.free;
          gSearch_StringList.free;
        end;

      finally
        DataStore_FS.free;
      end;

    finally
      gRegex_Words_StringList.free;
    end;

    lnk_to_pdf_report_str := 'file://' + GetCurrentCaseDir + FLDR_REPORTS + BS + 'Folder and Filename Regex Search.pdf'; // This name is in the TXML
    lnk_to_pdf_report_str := StringReplace(lnk_to_pdf_report_str, ' ', '%20', [rfReplaceAll, rfIgnoreCase]); // Replace spaces with %20
    lnk_to_pdf_report_str := StringReplace(lnk_to_pdf_report_str, '\\', '', [rfReplaceAll, rfIgnoreCase]); // Replace leading double backslash
    ConsoleLog(RPad('Link to PDF Report' + CLN, RPAD_VALUE) + lnk_to_pdf_report_str);
    ConsoleLog(Stringofchar('-', CHAR_LENGTH));

    // ------------------------------------------------------------------------------
    // Save to Local
    // ------------------------------------------------------------------------------
    Progress.Log('Saving summary report to local folder' + RUNNING);
    Progress.DisplayMessageNow := 'Saving summary report to local folder' + RUNNING;
    if DirectoryExists(GetCurrentCaseDir + FLDR_REPORTS) then
    begin
      try
        Progress.Log(RPad('Folder Exists: ' + BoolToStr(DirectoryExists(GetCurrentCaseDir + FLDR_REPORTS), True), RPAD_VALUE) + GetCurrentCaseDir + FLDR_REPORTS);
        gReport_StringList.SaveToFile(GetCurrentCaseDir + FLDR_REPORTS + BS + SCRIPT_NAME + HYPHEN + SUMMARY_RPT);
        Sleep(1000);
        ConsoleLog(RPad('Save summary report to' + CLN, RPAD_VALUE) + GetCurrentCaseDir + FLDR_REPORTS + BS + SCRIPT_NAME + HYPHEN + SUMMARY_RPT);
      except
        on e: exception do
        begin
          ConsoleLog(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + e.message);
        end;
      end;
      Progress.Log(Stringofchar('-', CHAR_LENGTH));
    end;

    // ------------------------------------------------------------------------------
    // Save to Global
    // ------------------------------------------------------------------------------
    Progress.Log('Saving summary report to global folder' + RUNNING);
    Progress.DisplayMessageNow := 'Saving summary report to global folder' + RUNNING;
    FexLab_Global_Save(gReport_StringList, FS_File_Found_Count);

  finally
    gReport_StringList.free;
  end;
  Progress.Log('Script finished.');

end.
