unit Exclude_Files;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, DateUtils, DIRegEx, Graphics, Math, RegEx, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BM_FLDR_EXCLUDED_FILES = 'Excluded Files';
  BM_FLDR_HASH_MATCH = 'Hash Match';
  BS = '\';
  EXCLUDE_PATH_REGEX_STR = '\\*.AppData.*\\' + '|' + '\\*.Installshield.*\\' + '|' + '\\*.NSIS.*\\' + '|' + '\\*.ProgramData.*\\' + '|' + '\\*.Resources.*\\' + '|' + '\\*.Safari.*' + '|' + '\\*.Spotlight.*' + '|' + '\\\$Recycle\.Bin' + '|'
    + '\\cache' + '|' + '\\Chrome' + '|' + '\\com.apple.Safari' + '|' + '\\Cyberlink' + '|' + '\\InfusedApps' + '|' + '\\Microsoft Office' + '|' + '\\Microsoft.Net\\' + '|' + '\\MicrosoftEdge' + '|' + '\\MobileSync\\' + '|' +
    '\\MOZILLA\\FIREFOX' + '|' + '\\Netscape' + '|' + '\\Notifications' + '|' + '\\Orphaned\\' + '|' + '\\Packages' + '|' + '\\RECYCLER' + '|' + '\\SoftwareDistribution\\' + '|' + '\\SWSetup' + '|' + '\\System Volume Information' + '|' +
    '\\SystemApps' + '|' + '\\TEMPORARY INTERNET FILES' + '|' + '\\WebServiceCache\\' + '|' + '\\Windows\\Temp\\' + '|' + '\\Windows\\Web\\' + '|' + '\\WindowsApps' + '|' + '\\WinSxS';

  EXCLUDE_EXT_REGEX_STR = '\.(CHK|DB)$';
  EXCLUDE_SIG_REGEX_STR = '(icns|Visio|Icon|thumb)$';
  EXCLUDE_FILES_UNDER = 5120;
  FORMAT1 = '%-7s %-40s %-30s %-15s %-15s %-15s %-15s';
  CHAR_LENGTH = 80;
  HYPHEN = ' - ';
  RPAD_VALUE = 40;
  RUNNING = '...';
  SCRIPT_NAME = 'Exclusion Summary';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gExcludeByDel_StringList: TStringList;
  gExcludeByExt_StringList: TStringList;
  gExcludeByPth_StringList: TStringList;
  gExcludeBySig_StringList: TStringList;
  gExcludeBySiz_StringList: TStringList;

  gRunTimeReport_StringList: TStringList;
  gtotal_tested_count: integer;

  gField_HashSet: TDataStoreField;
  gDataStore_FS: TDataStore;
  g_is_hash_matched_int: integer;

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

procedure ConsoleLog(AString: string);
begin
  Progress.Log(AString);
  if assigned(gRunTimeReport_StringList) then
    gRunTimeReport_StringList.Add(AString);
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
  ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
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

procedure RunTimeReport_ExclusionList(aStringList: TStringList; report_name_str: string);
begin
  if assigned(aStringList) and (aStringList.Count > 0) then
  begin
    try
      aStringList.Insert(0, format(FORMAT1, ['--', '----', '---------', '------------', '---------', '---------', '-------']));
      aStringList.Insert(0, format(FORMAT1, ['#.', 'Path', 'File Name', 'Logical Size', 'Signature', 'isDeleted', 'Bates #']));
      aStringList.Insert(0, ' ');
      aStringList.Insert(0, report_name_str);
      CreateRunTimeReport(aStringList, report_name_str, False, 'txt');
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Exclusion Test
// ------------------------------------------------------------------------------
procedure ExcludeTheEntry(iEntry: TEntry);
var
  DeterminedFileDriverInfo: TFileTypeInformation;
  bl_include: boolean;
  filename_str: string;
  directory_str: string;
  dir_length_int: integer;
  del_number_int: integer;
  HashSetField_str: string;

begin
  if not Progress.isRunning then
    Exit;

  gtotal_tested_count := gtotal_tested_count + 1;
  // DeterminedFileDriverInfo := iEntry.DeterminedFileDriverInfo;
  // if (dtGraphics in DeterminedFileDriverInfo.DriverType) or (dtVideo in DeterminedFileDriverInfo.DriverType) then
  begin
    bl_include := True; // Set the exclusion boolean to False

    // Trunc the filename
    if Length(iEntry.EntryName) > 25 then
      filename_str := copy(iEntry.EntryName, 1, 25) + RUNNING
    else
      filename_str := iEntry.EntryName;

    // Trunc the path from the beginning
    directory_str := iEntry.Directory;
    dir_length_int := Length(iEntry.Directory);
    if dir_length_int > 35 then
    begin
      del_number_int := dir_length_int - 35;
      Delete(directory_str, 1, del_number_int);
      directory_str := RUNNING + directory_str;
    end;

    // Is Hash Matched
    HashSetField_str := (gField_HashSet.asString(iEntry));
    if trim(HashSetField_str) <> '' then
    begin
      g_is_hash_matched_int := g_is_hash_matched_int + 1;
    end
    else
      bl_include := False;

    // Exclude Deleted Files
    if bl_include and (iEntry.isDeleted) then
    begin
      gExcludeByDel_StringList.Add(format(FORMAT1, [IntToStr(gExcludeByDel_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname),
        BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      bl_include := False;
    end;

    // Exclude by Min Size
    if bl_include and (iEntry.LogicalSize < EXCLUDE_FILES_UNDER) then
    begin
      gExcludeBySiz_StringList.Add(format(FORMAT1, [IntToStr(gExcludeBySiz_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname),
        BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      bl_include := False;
    end;

    // Exclude by Specified Extension
    if bl_include and RegexMatch(iEntry.Extension, EXCLUDE_EXT_REGEX_STR, False) then
    begin
      gExcludeByExt_StringList.Add(format(FORMAT1, [IntToStr(gExcludeByExt_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname),
        BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      bl_include := False;
    end;

    // Exclude by Signature
    if bl_include and (iEntry.ClassName = 'TMediaFileEntry') or ((DeterminedFileDriverInfo.FileDriverNumber > 0) and (RegexMatch(DeterminedFileDriverInfo.ShortDisplayname, EXCLUDE_SIG_REGEX_STR, False))) then
    begin
      gExcludeBySig_StringList.Add(format(FORMAT1, [IntToStr(gExcludeBySig_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname),
        BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      bl_include := False;
    end;

    // Exclude by Path EXCLUDE_PATH_REGEX_STR
    if bl_include and (RegexMatch(iEntry.FullPathName, EXCLUDE_PATH_REGEX_STR, False)) then
    begin
      gExcludeByPth_StringList.Add(format(FORMAT1, [IntToStr(gExcludeByPth_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname),
        BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      bl_include := False;
    end;

    // If the status is 'include', add to the OutList
    if bl_include then
      OutList.Add(iEntry);

  end;
end;

// ==============================================================================
// The start of the script
// ==============================================================================
var
  anEntry: TEntry;
  i: integer;
  sum_excluded_int: integer;
  aLineList: TStringList;
  bm_Folder_1: TEntry;

begin
  gRunTimeReport_StringList := TStringList.Create;
  try
    // ----------------------------------------------------------------------------
    // Check that InList and OutList exist and that InList is not empty
    // ----------------------------------------------------------------------------
    if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    begin
      gRunTimeReport_StringList.Add('Error:' + SPACE + SCRIPT_NAME + SPACE + 'InList/OutList');
      try
        CreateRunTimeReport(gRunTimeReport_StringList, SCRIPT_NAME, False, 'txt');
      except
        Progress.Log(ATRY_EXCEPT_STR + SCRIPT_NAME + SPACE + 'Error creating RunTime Report');
      end;
      Exit;
    end;

    gDataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
    if assigned(gDataStore_FS) then
      try
        gField_HashSet := gDataStore_FS.DataFields.FieldByName['HASHSET'];

        // --------------------------------------------------------------------------
        // Process the InList
        // --------------------------------------------------------------------------
        gExcludeByDel_StringList := TStringList.Create;
        gExcludeByExt_StringList := TStringList.Create;
        gExcludeByPth_StringList := TStringList.Create;
        gExcludeBySig_StringList := TStringList.Create;
        gExcludeBySiz_StringList := TStringList.Create;
        try
          Progress.Initialize(InList.Count, 'Processing' + RUNNING);
          for i := 0 to InList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            anEntry := TEntry(InList[i]);
            ExcludeTheEntry(anEntry);
            Progress.incCurrentProgress;
          end;

          // --------------------------------------------------------------------------
          // Create the runtime report
          // --------------------------------------------------------------------------
          ConsoleLog(RPad('1.' + SPACE + 'Exclude by deleted:', RPAD_VALUE) + 'True');
          ConsoleLog(RPad('2.' + SPACE + 'Exclude file size less than:', RPAD_VALUE) + IntToStr(EXCLUDE_FILES_UNDER) + SPACE + 'bytes');
          ConsoleLog(RPad('3.' + SPACE + 'Exclude by extension (regex):', RPAD_VALUE) + EXCLUDE_EXT_REGEX_STR);
          ConsoleLog(RPad('4.' + SPACE + 'Exclude by signature (regex):', RPAD_VALUE) + EXCLUDE_SIG_REGEX_STR);

          aLineList := TStringList.Create;
          try
            aLineList.Delimiter := '|'; // Default, but ";" is used with some locales
            aLineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter
            aLineList.DelimitedText := EXCLUDE_PATH_REGEX_STR;
            if assigned(aLineList) and (aLineList.Count > 0) then
            begin
              ConsoleLog(RPad('5.' + SPACE + 'Exclude by path (regex):', RPAD_VALUE) + aLineList[0]);
              for i := 1 to aLineList.Count - 1 do
              begin
                gRunTimeReport_StringList.Add(RPad(' ', RPAD_VALUE) + aLineList[i]);
              end;
            end;
          finally
            aLineList.free;
          end;

          sum_excluded_int := gExcludeByDel_StringList.Count + gExcludeByExt_StringList.Count + gExcludeByPth_StringList.Count + gExcludeBySig_StringList.Count + gExcludeBySiz_StringList.Count;

          ConsoleLog(' ');
          ConsoleLog(StringOfChar('-', CHAR_LENGTH));
          ConsoleLog(RPad('Total Tested:', RPAD_VALUE) + IntToStr(InList.Count));
          ConsoleLog(RPad('Is Hash Matched:', RPAD_VALUE) + IntToStr(g_is_hash_matched_int));
          ConsoleLog(StringOfChar('-', CHAR_LENGTH));

          ConsoleLog(RPad('Excluded by deleted:', RPAD_VALUE) + IntToStr(gExcludeByDel_StringList.Count));
          ConsoleLog(RPad('Excluded by extension:', RPAD_VALUE) + IntToStr(gExcludeByExt_StringList.Count));
          ConsoleLog(RPad('Excluded by file path:', RPAD_VALUE) + IntToStr(gExcludeByPth_StringList.Count));
          ConsoleLog(RPad('Excluded by signature (specific):', RPAD_VALUE) + IntToStr(gExcludeBySig_StringList.Count));
          ConsoleLog(RPad('Excluded by file size' + SPACE + '(<' + IntToStr(EXCLUDE_FILES_UNDER) + SPACE + 'bytes):', RPAD_VALUE) + IntToStr(gExcludeBySiz_StringList.Count));

          ConsoleLog(StringOfChar('-', CHAR_LENGTH));
          ConsoleLog(RPad('Total Excluded:', RPAD_VALUE) + IntToStr(sum_excluded_int));
          ConsoleLog(RPad('Total Included:', RPAD_VALUE) + IntToStr(OutList.Count));
          ConsoleLog(RPad('', RPAD_VALUE) + '----------');
          ConsoleLog(RPad('Total:', RPAD_VALUE) + IntToStr(OutList.Count + sum_excluded_int));
          ConsoleLog(StringOfChar('=', CHAR_LENGTH));

          if OutList.Count <> (InList.Count - sum_excluded_int) then
            ConsoleLog(RPad('Error, Check Calculations:', RPAD_VALUE) + IntToStr(InList.Count) + SPACE + '(InList) - ' + IntToStr(OutList.Count) + SPACE + '(Outlist) = ' + IntToStr(InList.Count - OutList.Count));

          // Runtime Report - Exclusion Test Results
          try
            CreateRunTimeReport(gRunTimeReport_StringList, SCRIPT_NAME, False, 'txt');
          except
            Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
          end;

          bm_Folder_1 := FindBookmarkByName(BM_FLDR_EXCLUDED_FILES);
          if not assigned(bm_Folder_1) then
            bm_Folder_1 := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), (BM_FLDR_EXCLUDED_FILES), (gRunTimeReport_StringList.Text))
          else
            UpdateBookmark(bm_Folder_1, gRunTimeReport_StringList.Text);

          RunTimeReport_ExclusionList(gExcludeByDel_StringList, 'Exclude By Deleted');
          RunTimeReport_ExclusionList(gExcludeByExt_StringList, 'Exclude By Extension');
          RunTimeReport_ExclusionList(gExcludeByPth_StringList, 'Exclude By Path');
          RunTimeReport_ExclusionList(gExcludeBySig_StringList, 'Exclude By Signature (specific)');
          RunTimeReport_ExclusionList(gExcludeBySiz_StringList, 'Exclude By Size');

        finally
          gExcludeByDel_StringList.free;
          gExcludeByExt_StringList.free;
          gExcludeByPth_StringList.free;
          gExcludeBySig_StringList.free;
          gExcludeBySiz_StringList.free;
        end;
      finally
        gDataStore_FS.free;
      end;
  finally
    gRunTimeReport_StringList.free;
  end;

end.
