unit Exclude_Files;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, DateUtils, DIRegEx, Graphics, Math, RegEx, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; //noslz
  EXCLUDE_PATH_REGEX_STR = '\\*.AppData.*\\'             + '|' +
                           '\\*.Installshield.*\\'       + '|' +
                           '\\*.NSIS.*\\'                + '|' +
                           '\\*.ProgramData.*\\'         + '|' +
                           '\\*.Resources.*\\'           + '|' +
                           '\\*.Safari.*'                + '|' +
                           '\\*.Spotlight.*'             + '|' +
                           '\\\$Recycle\.Bin'            + '|' +
                           '\\cache'                     + '|' +
                           '\\Chrome'                    + '|' +
                           '\\com.apple.Safari'          + '|' +
                           '\\Cyberlink'                 + '|' +
                           '\\InfusedApps'               + '|' +
                           '\\Microsoft Office'          + '|' +
                           '\\Microsoft.Net\\'           + '|' +
                           '\\MicrosoftEdge'             + '|' +
                           '\\MobileSync\\'              + '|' +
                           '\\MOZILLA\\FIREFOX'          + '|' +
                           '\\Netscape'                  + '|' +
                           '\\Notifications'             + '|' +
                           '\\Orphaned\\'                + '|' +
                           '\\Packages'                  + '|' +
                           '\\RECYCLER'                  + '|' +
                           '\\SoftwareDistribution\\'    + '|' +
                           '\\SWSetup'                   + '|' +
                           '\\System Volume Information' + '|' +
                           '\\SystemApps'                + '|' +
                           '\\TEMPORARY INTERNET FILES'  + '|' +
                           '\\WebServiceCache\\'         + '|' +
                           '\\Windows\\Temp\\'           + '|' +
                           '\\Windows\\Web\\'            + '|' +
                           '\\WindowsApps'               + '|' +
                           '\\WinSxS';

  EXCLUDE_EXT_REGEX_STR    = '\.(CHK|DB)$';
  EXCLUDE_SIG_REGEX_STR    = '(icns|Visio|Icon|thumb)$';
  EXCLUDE_FILES_UNDER      = 5120;
  FORMAT1                  = '%-7s %-40s %-30s %-15s %-15s %-15s %-15s';
  CHAR_LENGTH              = 80;
  HYPHEN                   = ' - ';
  RPAD_VALUE               = 40;
  RUNNING                  = '...';
  SCRIPT_NAME              = 'Exclusion Test'; 
  SPACE                    = ' ';
  TSWT                     = 'The script will terminate.';

var
  gexclude_del_count: integer;
  gexclude_ext_count: integer;
  gexclude_pth_count: integer;
  gexclude_sdn_count: integer;
  gexclude_sig_count: integer;
  gexclude_siz_count: integer;

  gExcludeByDel_StringList: TStringList;
  gExcludeByExt_StringList: TStringList;
  gExcludeByPth_StringList: TStringList;
  gExcludeBySig_StringList: TStringList;
  gExcludeBySiz_StringList: TStringList;
  gExcludeNoSig_StringList: TStringList;

  gRunTimeReport_StringList: TStringList;
  gtotal_tested_count: integer;

implementation

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
// Procedure: Create RunTime Report (PDF or TXT)
//------------------------------------------------------------------------------
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
  ExportedDir := CurrentCaseDir + 'Reports\'; //'\Run Time Reports\';
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

  SaveName := ExportedDir + ExportDateTime  + save_name_str + Ext_str;
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

//------------------------------------------------------------------------------
// Function: Make sure the InList and OutList exist
//------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string) : boolean;
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
      aStringList.Insert(0, format(FORMAT1,['--', '----', '---------', '------------', '---------', '---------', '-------']));
      aStringList.Insert(0, format(FORMAT1,['#.', 'Path', 'File Name', 'Logical Size', 'Signature', 'isDeleted', 'Bates #']));
      aStringList.Insert(0, ' ');
      aStringList.Insert(0, report_name_str);
      CreateRunTimeReport(aStringList, report_name_str, False, 'pdf');
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
    end;
  end;
end;

//------------------------------------------------------------------------------
// Function: Exclusion Test
//------------------------------------------------------------------------------
function Exclusion_Test(iEntry: TEntry) : boolean;
var
  DeterminedFileDriverInfo : TFileTypeInformation;
  bl_exclude: boolean;
  filename_str: string;
  directory_str: string;
  dir_length_int: integer;
  del_number_int: integer;
begin
  if not Progress.isRunning then Exit;
  Result := False;

  gtotal_tested_count := gtotal_tested_count + 1;
  DeterminedFileDriverInfo := iEntry.DeterminedFileDriverInfo;
  if (dtGraphics in DeterminedFileDriverInfo.DriverType) or (dtVideo in DeterminedFileDriverInfo.DriverType) then
  begin
    bl_exclude := False; // Set the exclusion boolean to False

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

    // Exclude Deleted Files
    if (iEntry.isDeleted) then
    begin
      gExcludeByDel_StringList.Add(format(FORMAT1,[IntToStr(gExcludeByDel_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname), BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      gexclude_del_count := gexclude_del_count + 1;
      bl_exclude := True;
      Exit;
    end;

    // Exclude by Min Size
    if iEntry.LogicalSize < EXCLUDE_FILES_UNDER then
    begin
      gExcludeBySiz_StringList.Add(format(FORMAT1,[IntToStr(gExcludeBySiz_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname), BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      gexclude_siz_count := gexclude_siz_count + 1;
      bl_exclude := True;
      Exit;
    end;

    // Exclude by Specified Extension
    if RegexMatch(iEntry.Extension, EXCLUDE_EXT_REGEX_STR, False) then
    begin
      gExcludeByExt_StringList.Add(format(FORMAT1,[IntToStr(gExcludeByExt_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname), BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      gexclude_ext_count := gexclude_ext_count + 1;
      bl_exclude := True;
      Exit;
    end;

    // Exclude Files with No Signature
    if (DeterminedFileDriverInfo.FileDriverNumber <= 0) or (DeterminedFileDriverInfo.ShortDisplayName = '') then // Test two different ways for no signature
    begin
      gExcludeNoSig_StringList.Add(format(FORMAT1,[IntToStr(gExcludeNoSig_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname), BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      gexclude_sig_count := gexclude_sig_count + 1;
      bl_exclude := True;
      Exit;
    end;

    // Exclude by Signature
    if (iEntry.ClassName = 'TMediaFileEntry') or ((DeterminedFileDriverInfo.FileDriverNumber > 0) and (RegexMatch(DeterminedFileDriverInfo.ShortDisplayName, EXCLUDE_SIG_REGEX_STR, False))) then
    begin
      gExcludeBySig_StringList.Add(format(FORMAT1,[IntToStr(gExcludeBySig_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname), BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      gexclude_sdn_count := gexclude_sdn_count + 1;
      bl_exclude := True;
      Exit;
    end;

    // Exclude by Path EXCLUDE_PATH_REGEX_STR
    if (RegexMatch(iEntry.FullPathName, EXCLUDE_PATH_REGEX_STR, False)) then
    begin
      gExcludeByPth_StringList.Add(format(FORMAT1,[IntToStr(gExcludeByPth_StringList.Count + 1), directory_str, filename_str, IntToStr(iEntry.LogicalSize), (iEntry.DeterminedFileDriverInfo.ShortDisplayname), BoolToStr(iEntry.isDeleted, True), IntToStr(iEntry.ID)]));
      gexclude_pth_count := gexclude_pth_count + 1;
      bl_exclude := True;
      Exit;
    end;

    if bl_exclude = True then
    begin
      Result := False;
      Exit;
    end;

    Result := True; // File gets added to the TList
  end;
end;

//==============================================================================
// The start of the script
//==============================================================================
const
  BMFLDR_EXCLUDED_FILES = 'Excluded Files';
  BS = '\';
  PINT = 3;
var
  anEntry: TEntry;
  i: integer;
  sum_excluded_int: integer;
  aLineList: TStringList;
  bm_Folder_1: TEntry;

begin
  gRunTimeReport_StringList := TStringList.Create;
  try
    //----------------------------------------------------------------------------
    // Check that InList and OutList exist and that InList is not empty
    //----------------------------------------------------------------------------
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

    //--------------------------------------------------------------------------
    // Process the InList
    //--------------------------------------------------------------------------
    gExcludeByDel_StringList := TStringList.Create;
    gExcludeByExt_StringList := TStringList.Create;
    gExcludeByPth_StringList := TStringList.Create;
    gExcludeBySig_StringList := TStringList.Create;
    gExcludeBySiz_StringList := TStringList.Create;
    gExcludeNoSig_StringList := TStringList.Create;

    try
      for i := 0 to InList.Count - 1 do
      begin
        if not Progress.isRunning then break;
        anEntry := TEntry(InList[i]);
        if Exclusion_Test(anEntry) then
          OutList.Add(anEntry);
      end;

      //--------------------------------------------------------------------------
      // Create the runtime report
      //--------------------------------------------------------------------------
      gRunTimeReport_StringList.Add('1.' + StringOfChar(' ', PINT) + 'Exclude by deleted.');
      gRunTimeReport_StringList.Add(' ');
      gRunTimeReport_StringList.Add(RPad('2.' + StringOfChar(' ', PINT) + 'Exclude file size less than:',  RPAD_VALUE) + IntToStr(EXCLUDE_FILES_UNDER) + SPACE + 'bytes');
      gRunTimeReport_StringList.Add(' ');
      gRunTimeReport_StringList.Add(RPad('3.' + StringOfChar(' ', PINT) + 'Exclude by extension (regex):', RPAD_VALUE) + EXCLUDE_EXT_REGEX_STR);
      gRunTimeReport_StringList.Add(' ');
      gRunTimeReport_StringList.Add(RPad('4.' + StringOfChar(' ', PINT) + 'Exclude by signature (regex):', RPAD_VALUE) + EXCLUDE_SIG_REGEX_STR);

      aLineList := TStringList.Create;
      try
        aLineList.Delimiter := '|'; // Default, but ";" is used with some locales
        aLineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter
        aLineList.DelimitedText := EXCLUDE_PATH_REGEX_STR;
        if assigned(aLineList) and (aLineList.Count > 0) then
        begin
          gRunTimeReport_StringList.Add(' ');
          gRunTimeReport_StringList.Add(RPad('6.' + StringOfChar(' ', PINT) + 'Exclude by path (regex):',      RPAD_VALUE) + aLineList[0]);
          for i := 1 to aLineList.Count - 1 do
          begin
            gRunTimeReport_StringList.Add(RPad(' ', RPAD_VALUE) + aLineList[i]);
          end;
        end;
      finally
        aLineList.free;
      end;

      sum_excluded_int := gexclude_del_count + gexclude_ext_count + gexclude_pth_count + gexclude_sig_count + gexclude_sdn_count + gexclude_siz_count;
      gRunTimeReport_StringList.Add(' ');
      gRunTimeReport_StringList.Add(Stringofchar('-', CHAR_LENGTH));
      gRunTimeReport_StringList.Add(RPad('Total Graphics and Video Tested:', RPAD_VALUE) + IntToStr(gtotal_tested_count));
      gRunTimeReport_StringList.Add(Stringofchar('-', CHAR_LENGTH));

      gRunTimeReport_StringList.Add(RPad('Excluded by deleted:',         RPAD_VALUE) + IntToStr(gexclude_del_count));
      gRunTimeReport_StringList.Add(RPad('Excluded by extension:',       RPAD_VALUE) + IntToStr(gexclude_ext_count));
      gRunTimeReport_StringList.Add(RPad('Excluded by file path:',       RPAD_VALUE) + IntToStr(gexclude_pth_count));
      gRunTimeReport_StringList.Add(RPad('Excluded by signature:',       RPAD_VALUE) + IntToStr(gexclude_sig_count));
      //gRunTimeReport_StringList.Add(RPad('Excluded by blank signature:', RPAD_VALUE) + IntToStr(gexclude_sdn_count));
      gRunTimeReport_StringList.Add(RPad('Excluded by file size:'        + SPACE + '(<' + IntToStr(EXCLUDE_FILES_UNDER) + SPACE + 'bytes)', RPAD_VALUE) + IntToStr(gexclude_siz_count));

      gRunTimeReport_StringList.Add(Stringofchar('-', CHAR_LENGTH));
      gRunTimeReport_StringList.Add(RPad('Total Excluded:', RPAD_VALUE) + IntToStr(sum_excluded_int));
      gRunTimeReport_StringList.Add(Stringofchar('=', CHAR_LENGTH));
      gRunTimeReport_StringList.Add(RPad('Total Included:', RPAD_VALUE) + IntToStr(OutList.Count));
      gRunTimeReport_StringList.Add(Stringofchar('=', CHAR_LENGTH));

      if OutList.Count <> (gtotal_tested_count - sum_excluded_int) then
        gRunTimeReport_StringList.Add(RPad('Error:', RPAD_VALUE) + 'Check Calculations');

      // Runtime Report - Exclusion Test Results
      try
        CreateRunTimeReport(gRunTimeReport_StringList, SCRIPT_NAME, False, 'txt');
      except
        Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
      end;

      bm_Folder_1 := FindBookmarkByName(BMFLDR_EXCLUDED_FILES);
      if not assigned (bm_Folder_1) then
        bm_Folder_1 := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), (BMFLDR_EXCLUDED_FILES), (gRunTimeReport_StringList.Text))
      else
        UpdateBookmark(bm_Folder_1, gRunTimeReport_StringList.Text);

      //RunTimeReport_ExclusionList(gExcludeByDel_StringList, 'Exclude By Deleted');
      //RunTimeReport_ExclusionList(gExcludeByExt_StringList, 'Exclude By Extension');
      //RunTimeReport_ExclusionList(gExcludeByPth_StringList, 'Exclude By Path');
      //RunTimeReport_ExclusionList(gExcludeBySig_StringList, 'Exclude By Signature');
      //RunTimeReport_ExclusionList(gExcludeBySiz_StringList, 'Exclude By Size');
      //RunTimeReport_ExclusionList(gExcludeNoSig_StringList, 'Exclude By No Signature');

    finally
      gExcludeByDel_StringList.free;
      gExcludeByExt_StringList.free;
      gExcludeByPth_StringList.free;
      gExcludeBySig_StringList.free;
      gExcludeBySiz_StringList.free;
      gExcludeNoSig_StringList.free;
    end;

  finally
    gRunTimeReport_StringList.free;
  end;
end.
