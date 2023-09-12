unit Email_Results_Search;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, DateUtils, DIRegEx, Email, Graphics, Math, RegEx, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  CHAR_LENGTH = 112; // width of page is 118
  FORMAT_REPORT = '%-10s %-30s %-30s %-30s %-100s';
  COMMA = ',';
  CR = #13#10;
  FORMAT_STRING_SHORT = '%-35s %-35s';
  HYPHEN = ' - ';
  MAX_NUMBER_OF_TERMS = 100;
  OSFILENAME = '\\?\'; // This is needed for long filenames';
  RPAD_VALUE = 35;
  RUNNING = '...';
  SCRIPT_NAME = 'Search Email Columns';
  SPACE = ' ';
  THE_MODULE = 'Email';
  TRUNC_LENGTH = 26;
  TSWT = 'The script will terminate.';

var
  FileName_Counter: array [0 .. MAX_NUMBER_OF_TERMS] of integer;
  FS_File_Found_Count: integer;
  gCaseName: string;
  gmax_messages_reached_bl: boolean;
  grbnInReportMatched: boolean;
  gStart_Check_Header: string;
  Import_StringList: TStringList;
  MaxHits_int: integer;
  Memo_StringList: TStringList;
  OneBigRegex_str: string;
  proceed_bl: boolean;
  ReportName_str: string;
  RunTimeReport_StringList: TStringList;
  Search_StringList: TStringList;
  Summary_StringList: TStringList;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

type
  TArr16 = array [1 .. 16] of integer;

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
function params: boolean;
var
  param_str: string;
  i: integer;

begin
  Result := False;
  param_str := '';
  Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
  if (CmdLine.ParamCount > 0) then
  begin
    Result := True;
    Progress.Log(StringOfChar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      param_str := param_str + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
  begin
    Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + (IntToStr(CmdLine.ParamCount)));
    Result := False;
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
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  if DT_In_FileName_bl then
    ExportDateTime := (ExportDate + HYPHEN + ExportTime + HYPHEN)
  else
    ExportDateTime := '';
  SaveName := ExportedDir + ExportDateTime + save_name_str + '.pdf';
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
// Procedure: Simple PDF
// ------------------------------------------------------------------------------
procedure SimpleRunTimePDF(AString: string; save_name_str: string);
const
  HYPHEN = ' - ';
var
  CurrentCaseDir: string;
  ExportedDir: string;
  SaveName: string;
  aStringList: TStringList;
begin
  aStringList := TStringList.Create;
  try
    aStringList.Add(AString);
    CurrentCaseDir := GetCurrentCaseDir;
    ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
    SaveName := ExportedDir + save_name_str + '.pdf';
    if DirectoryExists(CurrentCaseDir) then
    begin
      try
        if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
        begin
          if GeneratePDF(SaveName, aStringList, 8) then
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
  finally
    aStringList.free;
  end;
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
// Function: Import
// ------------------------------------------------------------------------------
procedure ImportClick;
var
  OpenFilename_str: string;
  r: integer;
  CommentString: string;

begin
  if (CmdLine.params.Count > 0) then
  begin

    try
      if assigned(Import_StringList) then
      begin
        OpenFilename_str := CmdLine.params[0];
        if FileExists(OpenFilename_str) then
        begin
          Import_StringList.LoadFromFile(OpenFilename_str);
          if (Import_StringList.Count > 0) then
          begin
            if (Import_StringList.Count <= MAX_NUMBER_OF_TERMS) then
            begin

              // Remove blank lines
              for r := Import_StringList.Count - 1 downto 0 do
              begin
                Import_StringList[r] := TrimRight(Import_StringList[r]);
                if trim(Import_StringList[r]) = '' then // Remove blank lines from StrList
                  Import_StringList.Delete(r);
              end;

              // Remove any Comment Strings
              for r := Import_StringList.Count - 1 downto 0 do
              begin
                CommentString := copy(Import_StringList(r), 1, 1);
                if CommentString = '#' then
                  Import_StringList.Delete(r);
              end;

              // Log Keywords
              // Memo_StringList.Add('Keywords: (' + IntToStr(Import_StringList.Count) + ')');
              // for r := 0 to Import_StringList.Count - 1 do
              // begin
              // Progress.Log(Import_StringList[r]);
              // Memo_StringList.Add(Import_StringList[r]);
              // end;
              // Memo_StringList.Add(' ');

            end
            else
            begin
              SimpleRunTimePDF('ERROR: To many keywords. Maximum = 1000', 'Error - To many keywords');
              Progress.Log('Too many keywords. Maximum = 1000.');
            end;
          end
          else
            Progress.Log('No strings were read from:');
        end
        else
          Progress.Log(RPad('Could not find file:', RPAD_VALUE) + OpenFilename_str);
      end;
    finally

    end;
  end
  else
    Progress.Log('No parameters were received.');
end;

// ------------------------------------------------------------------------------
// Function - Strip Illegal characters for Valid Folder Name in Bookmarks
// ------------------------------------------------------------------------------
function StripIllegalChars(AString: string): string;
var
  x: integer;
const
  IllegalCharSet: set of char = ['|', '<', '>', '\', '^', '+', '=', '?', '/', '[', ']', '"', ';', ',', '*', ':'];
begin
  for x := 1 to Length(AString) do
    if AString[x] in IllegalCharSet then
      AString[x] := '_';
  Result := AString;
end;

procedure btnOK_OnClick;
var
  i: integer;
  CommentString: string;
  bad_regex_str: string;

begin
  // Set our user variables for use in the main proc
  OneBigRegex_str := StringReplace(Import_StringList.text, #13#10, '|', [rfReplaceAll]);

  // Add keywords to Search_StringList
  Search_StringList.AddStrings(Import_StringList);

  // Remove any Comment Strings from the Search StringList
  for i := Search_StringList.Count - 1 downto 0 do
  begin
    CommentString := copy(Search_StringList[i], 1, 1);
    if CommentString = '#' then
      Search_StringList.Delete(i);
  end;

  begin
    ReportName_str := ' - ' + ReportName_str;
  end;

  // Validate the Regex
  if IsValidRegEx(OneBigRegex_str) then
  begin
    Progress.Log(RPad('OneBigRegex_str is valid:', RPAD_VALUE) + OneBigRegex_str);
  end
  else
  begin
    proceed_bl := False;
    // Find the bad RegEx strings
    if assigned(Search_StringList) then
    begin
      bad_regex_str := '';
      for i := 0 to Search_StringList.Count - 1 do
      begin
        if not IsValidRegEx(Search_StringList[i]) then
        begin
          if bad_regex_str = '' then
            bad_regex_str := Search_StringList[i]
          else
            bad_regex_str := bad_regex_str + #13#10 + Search_StringList[i];
        end;
      end;
      Progress.Log(RPad('ERROR: Invalid regex format:', RPAD_VALUE) + bad_regex_str);
      SimpleRunTimePDF('ERROR: A keyword has an invalid regex format: ' + bad_regex_str, 'Error - Invalid Regex');
    end;
    Exit; // Exit if the regex is not valid
  end;

  // Logging
  if assigned(Search_StringList) then
  begin
    Progress.Log(RPad('Keyword Count:', RPAD_VALUE) + IntToStr(Search_StringList.Count));
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
  end;

  proceed_bl := True;
end;

// ------------------------------------------------------------------------------
// Function: File Name RegEx Search Index
// ------------------------------------------------------------------------------
function FileNameRegExSearchIndex(aEmailDS: TDataStore; anEntry: TEntry; AFieldList: TList): boolean;
var
  deleted_status_str: string;
  Field: TDataStoreField;
  FullPathNoComma: string;
  i, j: integer;
  prevEntry: TEntry;
  trunc_matchtext_str: string;
  trunc_parentfldr_str: string;
  trunc_source_str: string;
  trunc_subject_str: string;

begin
  Result := False;
  for i := 0 to AFieldList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    Field := TDataStoreField(AFieldList[i]);
    if assigned(Field) and not(Field.isNull(anEntry)) then // and (field.asString[anEntry] <> '') then
    begin
      for j := 0 to Search_StringList.Count - 1 do
      begin
        // Initialize var
        trunc_source_str := '';
        trunc_parentfldr_str := '';
        trunc_subject_str := '';
        trunc_matchtext_str := '';

        if (RegexMatch(Field.asString[anEntry], Search_StringList[j], False)) then
        begin
          FileName_Counter[j] := FileName_Counter[j] + 1;
          FullPathNoComma := StringReplace(anEntry.FullPathName, ',', '_', [rfReplaceAll]);
          if anEntry.isDeleted then
            deleted_status_str := 'Y'
          else
            deleted_status_str := '';

          // Trunc Source
          trunc_source_str := copy(Search_StringList[j], 1, TRUNC_LENGTH);
          if Length(trunc_source_str) > (TRUNC_LENGTH - 3) then
            trunc_source_str := trunc_source_str + '...';

          // Trunc Parent Folder (protect the parent)
          if assigned(anEntry.Parent) then
          begin
            trunc_parentfldr_str := copy(anEntry.Parent.EntryName, 1, TRUNC_LENGTH);
            if Length(trunc_parentfldr_str) > (TRUNC_LENGTH - 3) then
              trunc_parentfldr_str := trunc_parentfldr_str + '...';
          end;

          // Trunc Match Text
          trunc_matchtext_str := copy(Field.asString[anEntry], 1, TRUNC_LENGTH);
          if Length(trunc_matchtext_str) > (TRUNC_LENGTH - 3) then
            trunc_matchtext_str := trunc_matchtext_str + '...';

          // Trunc Subject
          trunc_subject_str := copy(anEntry.EntryName, 1, TRUNC_LENGTH);
          if Length(trunc_subject_str) > (TRUNC_LENGTH - 3) then
            trunc_subject_str := trunc_subject_str + '...';

          // Logging
          if anEntry <> prevEntry then
            Memo_StringList.Add((format(FORMAT_REPORT, [IntToStr(anEntry.ID), trunc_source_str, trunc_parentfldr_str, trunc_matchtext_str, trunc_subject_str]))); // not trunced

          prevEntry := anEntry;

          Result := True;
        end;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: File Name RegEx Search - Quick Concatenate Regex Method
// ------------------------------------------------------------------------------
function FileNameRegExSearch(aEmailDS: TDataStore; anEntry: TEntry; AFieldList: TList): boolean;
var
  Field: TDataStoreField;
  i: integer;
  subjectstr: string;
  Re: TDIPerlRegEx;
begin
  if isCalendarEvent(anEntry) then
  begin
    Progress.Log(RPad('Ignored Calendar Entry:', RPAD_VALUE) + anEntry.EntryName);
    Exit;
  end;

  if isContact(anEntry) then
  begin
    Progress.Log(RPad('Ignored Contact Entry:', RPAD_VALUE) + anEntry.EntryName);
    Exit;
  end;

  if isMailEntry(anEntry) then
  begin
    Result := False;
    subjectstr := '';
    Re := TDIPerlRegEx.Create(nil);
    try
      Re.CompileOptions := [coCaseLess];
      Re.MatchPattern := OneBigRegex_str;
      for i := 0 to AFieldList.Count - 1 do
      begin
        Field := TDataStoreField(AFieldList[i]);
        if assigned(Field) and not(Field.isNull(anEntry)) and (Field.asString[anEntry] <> '') then
        begin
          subjectstr := subjectstr + Field.asString[anEntry];
        end;
      end;
      if subjectstr <> '' then
      begin
        Re.SetSubjectStr(subjectstr);
        if Re.Match(0) >= 0 then
        begin
          Result := FileNameRegExSearchIndex(aEmailDS, anEntry, AFieldList);
        end;
      end;
    finally
      Re.free;
    end;
  end;
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
// Main Proc = This is the main procedure called after the 'Run' button is clicked
// ------------------------------------------------------------------------------
procedure MainProc;
var
  anEntry: TEntry;
  DataStore_EM: TDataStore;
  ExportDate: string;
  ExportDateTime: string;
  ExportFolder: string;
  ExportTime: string;
  Field: TDataStoreField;
  Field_TList: TList;
  Header_str: string;
  Header_str2: string;
  i: integer;
  ParentEntry: TEntry;

begin
  // Initialize
  Progress.DisplayTitle := SCRIPT_NAME;
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + '-' + ExportTime);
  ExportFolder := 'Export - ' + ExportDateTime;

  // Report Heading Strings ----------------------------------------------------
  Header_str := (format(FORMAT_REPORT, ['Bates ID', 'RegEx Search Term', 'Folder', 'Match Text', 'Subject']));
  Header_str2 := (format(FORMAT_REPORT, ['--------', '-----------------', '------', '----------', '-------']));

  // FileSystem Module - Heading -----------------------------------------------
  Memo_StringList.Add('Match Summary (Display columns are truncated):');
  Memo_StringList.Add(' ');
  Memo_StringList.Add(Header_str);
  Memo_StringList.Add(Header_str2);

  // Search --------------------------------------------------------
  DataStore_EM := GetDataStore(DATASTORE_EMAIL);
  if DataStore_EM = nil then
    Exit;

  if DataStore_EM.Count > 1 then
  begin
    Field_TList := TList.Create;
    try
      anEntry := DataStore_EM.First;
      if anEntry = nil then
      begin
        SimpleRunTimePDF('ERROR: No emails found.', 'Error - No emails found'); // string, filename(.pdf)
        Exit;
      end;

      ParentEntry := nil;
      Progress.Max := DataStore_EM.Count;
      Progress.CurrentPosition := 1;
      Progress.DisplayMessageNow := ('Searching ' + THE_MODULE + RUNNING);
      Progress.Log('Column count = ' + IntToStr(Field_TList.Count));

      // Loop Module -------------------------------------------------
      while assigned(anEntry) and (Progress.isRunning) do
      begin

        // Collect the list of Module Fields
        if assigned(anEntry.Parent) and (anEntry.Parent <> ParentEntry) then
        begin
          if isMailEntry(anEntry) and (not anEntry.isSystem) then
          begin
            Field_TList.Clear;
            for i := 0 to DataStore_EM.DataFields.Count - 1 do
            begin
              Field := DataStore_EM.DataFields[i];
              if (Field.FieldName <> 'EMAIL_BODY_TEXT') and (Field.FieldName <> 'EMAIL_HEADER') then // KVL
              begin
                if assigned(Field) and not VarIsEmpty(Field.Value[anEntry]) then // This assumes that each entry will have all non null fields
                  Field_TList.Add(Field);
              end;
            end;
            ParentEntry := TEntry(anEntry.Parent);
          end;
        end;

        // Run Regex Match
        if FileNameRegExSearch(DataStore_EM, anEntry, Field_TList) then
        begin
          OutList.Add(anEntry);
          FS_File_Found_Count := FS_File_Found_Count + 1;
          Progress.DisplayMessages := ('Searching ' + THE_MODULE + ' - Found: ' + IntToStr(FS_File_Found_Count) + RUNNING);
          if FS_File_Found_Count >= MaxHits_int then
          begin
            Memo_StringList.Add(StringOfChar('-', CHAR_LENGTH));
            Memo_StringList.Add('Maximum messages reached: ' + IntToStr(MaxHits_int));
            Memo_StringList.Add(StringOfChar('=', CHAR_LENGTH));
            gmax_messages_reached_bl := True;
            break;
          end;
        end;

        if not proceed_bl then
          break;

        Progress.IncCurrentProgress;
        anEntry := DataStore_EM.Next;
      end;

    finally
      DataStore_EM.free;
      Field_TList.free;
    end;
  end;
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
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
  Starting_StringList: TStringList;
  procedure StartingSummary(AString: string);
  begin
    if assigned(Starting_StringList) then
      Starting_StringList.Add(AString);
    Progress.Log(AString);
  end;

begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  Starting_StringList := TStringList.Create;
  try
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      Progress.Log('There is no current case.' + SPACE + TSWT);
      Exit;
    end
    else
      gCaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      Progress.Log('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;
    Result := True;
    gStart_Check_Header := Starting_StringList.text;
  finally
    StartCheckDataStore.free;
    Starting_StringList.free;
  end;
end;

// ==============================================================================
// The start of the script
// ==============================================================================
var
  j: integer;
  trunc_search_str: string;
  max_warn_str: string;

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessage := 'Starting...';
  proceed_bl := False;
  MaxHits_int := 2000;

  // ----------------------------------------------------------------------------
  // Starting Check
  // ----------------------------------------------------------------------------
  if not StartingChecks then
    Exit;

  params;

  // Check that InList and OutList exist and that InList is not empty
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
  begin
    // RunTime Report - InList/OutList Error
    RunTimeReport_StringList := TStringList.Create;
    try
      RunTimeReport_StringList.Add('Error - No InList/OutList');
      try
        CreateRunTimePDF(RunTimeReport_StringList, 'No InList/OutList', 8, False); // (aMessage, aStringList, atilte, font, DTinFilename)
      except
        Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
      end;
    finally
      RunTimeReport_StringList.free;
    end;
    Exit;
  end;

  // InList Count
  if InList.Count <= 0 then
  begin
    // RunTime Report - InList is empty
    RunTimeReport_StringList := TStringList.Create;
    try
      RunTimeReport_StringList.Add('No email files were found:');
      RunTimeReport_StringList.Add('Supported formats are PST, OST.');
      try
        CreateRunTimePDF(RunTimeReport_StringList, 'No email files found', 8, False); // True is DT in Filename.PDF
      except
        Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
      end;
    finally
      RunTimeReport_StringList.free;
    end;
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Exit;
  end;

  // Create String Lists -------------------------------------------------------
  Memo_StringList := TStringList.Create;
  Summary_StringList := TStringList.Create;
  Search_StringList := TStringList.Create;
  Import_StringList := TStringList.Create;
  try

    // Launch
    ImportClick; // Fills up Import_StringList with words
    btnOK_OnClick; // Search StringList is populated
    MainProc;

    // Output
    if { proceed_bl and } assigned(Memo_StringList) then
    begin

      // -------------------------------------------------------------------------
      // Summary Part of Report
      // -------------------------------------------------------------------------
      Summary_StringList.Add(' ');
      Summary_StringList.Add(format(FORMAT_STRING_SHORT, ['RegEx Term', 'Hits']));
      Summary_StringList.Add(format(FORMAT_STRING_SHORT, ['----------', '----']));

      if assigned(Search_StringList) and (Search_StringList.Count > 0) then
        for j := 0 to Search_StringList.Count - 1 do
        begin
          // Initialize
          trunc_search_str := '';

          // Trunc Source
          trunc_search_str := Search_StringList[j]; // copy(Search_StringList[j], 1, FORMAT_SEARCH_TERM - 4);
          // if Length(trunc_search_str) + 4 >= (FORMAT_SEARCH_TERM) then
          // trunc_search_str := trunc_search_str + '...';

          grbnInReportMatched := False; // False will display keywords with 0 hits
          if grbnInReportMatched then
          begin
            if FileName_Counter[j] <> 0 then
              Summary_StringList.Add(format(FORMAT_STRING_SHORT, [trunc_search_str, IntToStr(FileName_Counter[j])]));
          end
          else
          begin
            if FileName_Counter[j] = 0 then
            begin
              Summary_StringList.Add(format(FORMAT_STRING_SHORT, [trunc_search_str, '-']));
            end
            else
            begin
              Summary_StringList.Add(format(FORMAT_STRING_SHORT, [trunc_search_str, IntToStr(FileName_Counter[j])]));
            end;
          end;
        end
      else
        Progress.Log(RPad('Search_StringList Count:', RPAD_VALUE) + '0');

      Summary_StringList.Add(StringOfChar('-', CHAR_LENGTH));
      Summary_StringList.Add(format(FORMAT_STRING_SHORT, ['Messages' { + SPACE + THE_MODULE } + ':', IntToStr(FS_File_Found_Count)]));
      Summary_StringList.Add(StringOfChar('-', CHAR_LENGTH));
      Summary_StringList.Add(' ');

      Memo_StringList.Add(SCRIPT_NAME + ' finished.');

      // If no files found ---------------------------------------------------------
      if (FS_File_Found_Count = 0) then
      begin
        Progress.DisplayMessageNow := 'Displaying message window...';
        Progress.Log('No' { + SPACE + THE_MODULE } + ' matching the search criteria were located.');
      end;

      Summary_StringList.AddStrings(Memo_StringList);
      // RunTime Report  -----------------------------------------------------------
      if gmax_messages_reached_bl then
        max_warn_str := HYPHEN + 'Maximum Messages Reached' + HYPHEN + IntToStr(MaxHits_int)
      else
        max_warn_str := '';
      try
        if assigned(Summary_StringList) and (Summary_StringList.Count > 0) then
          CreateRunTimePDF(Summary_StringList, 'Search Settings' + max_warn_str, 8, False); // True is DT in Filename.PDF
      except
        Progress.Log(ATRY_EXCEPT_STR + 'Unknown error creating RunTime Report');
      end;

    end;

  finally
    Memo_StringList.free;
    Search_StringList.free;
    Import_StringList.free;
    Summary_StringList.free;
  end;

  Progress.Log(StringOfChar('-', 80));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

end.
