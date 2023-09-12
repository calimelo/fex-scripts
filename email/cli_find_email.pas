unit find_email;

interface

uses
  Classes, Common, DataEntry, DataStorage, DateUtils, Regex, SysUtils, Variants;

const

  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BLANK = '<BLANK>';
  CHAR_LENGTH = 80;
  RPAD_VALUE = 30;
  SIZE_GREATER_THAN = 'Filter by Size:';
  SPACE = ' ';
  TASKLIST_BETWEEN_DATES = 'Between Dates:';
  TASKLIST_END_DATE = 'End Date:';
  TASKLIST_HAS_ATTACHMENT = 'Has Attachment:';
  TASKLIST_MAX_SIZE = 'Max Size:';
  TASKLIST_MIN_SIXE = 'Min Size:';
  TASKLIST_REGEX_FROM = 'Email From:';
  TASKLIST_REGEX_SUBJECT = 'Email Subject:';
  TASKLIST_REGEX_TO = 'Email To:';
  TASKLIST_START_DATE = 'Start Date:';
  TSWT = 'The script will terminate.';

var
  gReport_StringList: TStringList;

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
      if not Progress.isRunning then
        break;
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
    end;

    // Add to gReport_StringList
    if assigned(gReport_StringList) then
    begin
      gReport_StringList.Add(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
      gReport_StringList.Add('Params:');
      for i := 0 to CmdLine.ParamCount - 1 do
      begin
        gReport_StringList.Add(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
        if not Progress.isRunning then
          break;
      end;
    end;

  end
  else
    Progress.Log('No parameters were received.');
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Procedure: Create PDF
// ------------------------------------------------------------------------------
procedure CreateRunTimePDF(aStringList: TStringList; SaveTitle: string; font_size_int: integer; dtInFileName: boolean);
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
  sleep(1000); // Required if you create reports in quick succession.
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := ExportDate + ' - ' + ExportTime + HYPHEN;
  if dtInFileName = False then
    ExportDateTime := '';
  SaveName := ExportedDir + ExportDateTime + SaveTitle;
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if GeneratePDF(SaveName, aStringList, font_size_int) then
          Progress.Log(RPad('Success Creating:', RPAD_VALUE) + ExtractFileName(SaveName));
      end
      else
        Progress.Log('Failed Creating: ' + SaveName);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Exception creating runtime folder');
    end;
  end
  else
    Progress.Log('There is no current case folder');
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Procedure: Simple PDF
// ------------------------------------------------------------------------------
procedure SimpleRunTimePDF(AString: string; save_name_str: string);
const
  HYPHEN = ' - ';
var
  aStringList: TStringList;
  CurrentCaseDir: string;
  ExportedDir: string;
  SaveName: string;
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
// Procedure: Find
// ------------------------------------------------------------------------------
function find(cmdparam_pos: integer; AString: string): boolean;
var
  j: integer;
  LineList: TStringList;
begin
  Result := False;
  LineList := TStringList.Create;
  LineList.Delimiter := ',';
  LineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter
  try
    if assigned(LineList) and (CmdLine.ParamCount > cmdparam_pos) then
    begin
      LineList.Clear;
      if (trim(CmdLine.params[cmdparam_pos]) = '') or (trim(CmdLine.params[cmdparam_pos]) = 'NOPARAM') then
      begin
        Result := True;
      end
      else
      begin
        LineList.CommaText := CmdLine.params[cmdparam_pos];
        for j := 0 to LineList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          if trim(UpperCase(LineList[j])) <> 'NOPARAM' then
          begin
            if (POS(UpperCase(LineList[j]), UpperCase(AString)) > 0) then
            begin
              Result := True;
              // gReport_StringList.Add('match: ' + lineList[j] + ' << with >> ' + aString);
            end;
          end;
        end;
      end;
    end
  finally
    LineList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Start of Script
// ------------------------------------------------------------------------------
const
  POS0 = 0;
  POS1 = 1;
  POS2 = 2;

var
  anEntry: TEntry;
  bl_attachments_only: boolean;
  bl_between_dates: boolean;
  bl_Continue: boolean;
  bl_from_match: boolean;
  bl_regex_from: boolean;
  bl_regex_subject: boolean;
  bl_regex_to: boolean;
  bl_subject_match: boolean;
  bl_to_match: boolean;
  Col_Attachments: TDataStoreField;
  col_attachment_str: string;
  Col_Received: TDataStoreField;
  Col_SentFrom: TDataStoreField;
  Col_SentTo: TDataStoreField;
  col_sent_from_str: string;
  col_sent_to_str: string;
  col_subject_str: string;
  dsEmail: TDataStore;
  dt_received: TDateTime;
  end_date_dt: TDateTime;
  end_date_str: string;
  find_email_from_str: string;
  find_email_subject_str: string;
  find_email_to_str: string;
  i: integer;
  regex_from_str: string;
  regex_subject_str: string;
  regex_to_str: string;
  start_date_dt: TDateTime;
  start_date_str: string;

begin
  // Check that InList and OutList exist, and InList count > 0
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
  begin
    Progress.Log(StringOfChar('-', 80));
    Exit
  end
  else if InList.Count = 0 then
  begin
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Progress.Log(StringOfChar('-', 80));
    // Exit;
  end
  else
    Progress.Log(StringOfChar('-', 80));

  dsEmail := GetDataStore(DATASTORE_EMAIL);
  if dsEmail = nil then
  begin
    Progress.Log('Email module returned nil' + SPACE + TSWT);
    Exit;
  end;

  gReport_StringList := TStringList.Create;

  try
    // Set Columns
    Col_Attachments := dsEmail.DataFields.FieldByName('ATTACHMENTS');
    Col_Received := dsEmail.DataFields.FieldByName('RECEIVED'); // noslz
    Col_SentFrom := dsEmail.DataFields.GetFieldByName('FROM'); // noslz
    Col_SentTo := dsEmail.DataFields.GetFieldByName('TO'); // noslz

    // --------------------------------------------------------------------------
    // ScriptTask Variable: Attachments Only
    // --------------------------------------------------------------------------
    bl_attachments_only := False;
    bl_attachments_only := RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_HAS_ATTACHMENT), 'True', False);
    Progress.Log(RPad('Attachments Only:', RPAD_VALUE) + BoolToStr(bl_attachments_only, True));

    // --------------------------------------------------------------------------
    // ScriptTask Variable: Between Dates
    // --------------------------------------------------------------------------
    bl_between_dates := False;
    if RegexMatch(ScriptTask.GetTaskListOption(TASKLIST_BETWEEN_DATES), 'True', False) then
    begin
      // Start Date
      start_date_str := ScriptTask.GetTaskListOption(TASKLIST_START_DATE);
      if trim(start_date_str) = '' then
      begin
        Progress.Log('Error reading input form - Date Start.');
        bl_between_dates := False;
      end
      else
      begin
        try
          start_date_dt := VarToDateTime(start_date_str);
          bl_between_dates := True;
        except
          Progress.Log(ATRY_EXCEPT_STR + 'Error converting Start Date string to DateTime: ' + start_date_str);
          bl_between_dates := False;
        end;
      end;

      // End Date
      end_date_str := ScriptTask.GetTaskListOption(TASKLIST_END_DATE);
      if trim(end_date_str) = '' then
      begin
        Progress.Log('Error reading input form - Date End.');
        bl_between_dates := False;
      end
      else if bl_between_dates = True then
      begin
        try
          end_date_dt := VarToDateTime(end_date_str);
        except
          Progress.Log(ATRY_EXCEPT_STR + 'Error converting End Date string to DateTime: ' + end_date_str);
          bl_between_dates := False;
        end;
      end;
    end;

    // Log the Between Dates Result
    if bl_between_dates then
    begin
      Progress.Log(RPad(TASKLIST_BETWEEN_DATES, RPAD_VALUE) + 'True');
      Progress.Log(RPad(SPACE + TASKLIST_START_DATE, RPAD_VALUE) + start_date_str);
      Progress.Log(RPad(SPACE + TASKLIST_END_DATE, RPAD_VALUE) + end_date_str);
    end
    else
      Progress.Log(RPad(TASKLIST_BETWEEN_DATES, RPAD_VALUE) + 'False');

    // Regex Subject String ----------------------------------------------------
    regex_subject_str := '';
    regex_subject_str := ScriptTask.GetTaskListOption(TASKLIST_REGEX_SUBJECT);
    if trim(regex_subject_str) = '' then
    begin
      Progress.Log('No' + SPACE + 'Regex Subject String');
      bl_regex_subject := False;
    end
    else
    begin
      bl_regex_subject := True;
      Progress.Log(RPad('Regex Subject String:', RPAD_VALUE) + regex_subject_str);
    end;

    // Regex From String -------------------------------------------------------
    regex_from_str := '';
    regex_from_str := ScriptTask.GetTaskListOption(TASKLIST_REGEX_FROM);
    if trim(regex_from_str) = '' then
    begin
      Progress.Log(RPad('Regex From String:', RPAD_VALUE) + BLANK);
      bl_regex_from := False;
    end
    else
    begin
      bl_regex_from := True;
      Progress.Log(RPad('Regex From String:', RPAD_VALUE) + regex_from_str);
    end;

    // Regex To String ---------------------------------------------------------
    regex_to_str := '';
    regex_to_str := ScriptTask.GetTaskListOption(TASKLIST_REGEX_TO);
    if trim(regex_to_str) = '' then
    begin
      Progress.Log(RPad('Regex To String:', RPAD_VALUE) + BLANK);
      bl_regex_to := False;
    end
    else
    begin
      bl_regex_to := True;
      Progress.Log(RPad('Regex To String:', RPAD_VALUE) + regex_to_str);
    end;

    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    // --------------------------------------------------------------------------
    // Loop the InList
    // --------------------------------------------------------------------------
    for i := 0 to InList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;

      // Start each loop as true
      bl_Continue := True;

      // Initialize for each loop
      anEntry := TEntry(InList[i]);
      bl_attachments_only := False;
      bl_from_match := False;
      bl_subject_match := False;
      bl_to_match := False;

      // Get the column data into variables ------------------------------------
      col_attachment_str := UpperCase(Col_Attachments.AsString[anEntry]);
      col_sent_from_str := UpperCase(Col_SentFrom.AsString(anEntry));
      col_sent_to_str := UpperCase(Col_SentTo.AsString(anEntry));
      col_subject_str := UpperCase(anEntry.EntryName);

      // Attachments -----------------------------------------------------------
      if bl_Continue and bl_attachments_only then
      begin
        if assigned(Col_Attachments) then
        begin
          if (col_attachment_str <> 'Y') then
            bl_Continue := False;
        end
        else
          Progress.Log('No attachments column');
      end;

      // Between Dates ---------------------------------------------------------
      if bl_Continue and bl_between_dates then
      begin
        if assigned(Col_Received) then
        begin
          dt_received := (Col_Received.AsDateTime[anEntry]);
          if (CompareDate(dt_received, start_date_dt) = -1) or (CompareDate(dt_received, end_date_dt) = 1) then
            bl_Continue := False;
        end;
      end;

      // Search Email From -----------------------------------------------------
      if bl_Continue and bl_regex_from then
        bl_Continue := RegexMatch(col_sent_from_str, regex_from_str, False);

      // Search Email To -------------------------------------------------------
      if bl_Continue and bl_regex_to then
        bl_Continue := RegexMatch(col_sent_to_str, regex_to_str, False);

      // Search the Message Subject --------------------------------------------
      if bl_Continue and bl_regex_subject then
        bl_Continue := RegexMatch(col_subject_str, regex_subject_str, False);

      if bl_Continue then
        OutList.Add(anEntry);
    end;

    // --------------------------------------------------------------------------
    // LOGGING
    // --------------------------------------------------------------------------
    find_email_subject_str := regex_subject_str;
    if (trim(find_email_subject_str) = '') then
      find_email_subject_str := BLANK;

    find_email_from_str := '';
    if (trim(find_email_from_str) = '') then
      find_email_from_str := BLANK;

    find_email_to_str := '';
    if (trim(find_email_to_str) = '') then
      find_email_to_str := BLANK;

    // Produce the Summary PDF
    gReport_StringList.Add(StringOfChar('-', 80));
    gReport_StringList.Add('Search Settings');
    gReport_StringList.Add(StringOfChar('-', 80));
    gReport_StringList.Add(RPad('Subject contains:', RPAD_VALUE) + find_email_subject_str);
    gReport_StringList.Add(RPad('AND From contains:', RPAD_VALUE) + find_email_from_str);
    gReport_StringList.Add(RPad('AND To contains:', RPAD_VALUE) + find_email_to_str);
    gReport_StringList.Add(RPad('Must have Attachment:', RPAD_VALUE) + BoolToStr(bl_attachments_only, True));
    gReport_StringList.Add(RPad(TASKLIST_BETWEEN_DATES, RPAD_VALUE) + BoolToStr(bl_between_dates, True));
    if bl_between_dates then
    begin
      gReport_StringList.Add(RPad(' Start Date:', RPAD_VALUE) + start_date_str);
      gReport_StringList.Add(RPad(' End Date:', RPAD_VALUE) + end_date_str);
    end;
    gReport_StringList.Add(StringOfChar('-', 80));
    gReport_StringList.Add(RPad('Messages Found:', RPAD_VALUE) + IntToStr(OutList.Count));

    CreateRunTimePDF(gReport_StringList, 'Search Settings.pdf', 8, False); // True = UseDT

  finally
    dsEmail.free;
    gReport_StringList.free;
  end;

  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log('Script finished.');

end.
