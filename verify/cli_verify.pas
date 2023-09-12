unit cli_verify;

interface

uses
  Classes, Common, DataEntry, DataStorage, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 80;
  CHAR_LENGTH_SHORT = 40;
  FORMAT_STR = '%-25s %-64s';
  HYPHEN = ' - ';
  RPAD_VALUE = 35;
  RS_NOT_MATCHED = 'Not Matched';
  RS_NOT_PRESENT = 'Not Present';
  RS_VERIFICATION_STR = 'Not Run';
  RUNNING = '...';
  SCRIPT_NAME = 'CLI Verify';

  GLOBAL_FLDR_BL = False;
  FLDR_GLB1 = '\\Fexlabs\share\Global_Output';
  FLDR_GLB2 = '\\192.168.0.24\SHARE\Global_Output';
  FLDR_GLB3 = 'C:\FEXLAB_SERVER\SHARE\Global_Output';

var
  gbl_match: boolean;
  gField_MD5: TDataStoreField;
  gField_MD5_Acquisition: TDataStoreField;
  gField_SHA1: TDataStoreField;
  gField_SHA1_Acquisition: TDataStoreField;
  gField_SHA256: TDataStoreField;
  gField_SHA256_Acquisition: TDataStoreField;
  gResults_StringList: TStringList;
  gsave_file_glb_str: string;

implementation

// ------------------------------------------------------------------------------
// Calculate time taken
// ------------------------------------------------------------------------------
function CalcTimeTaken(starting_tick_count: uint64): string;
var
  time_taken_uint64: uint64;
begin
  Result := '';
  time_taken_uint64 := (GetTickCount64 - starting_tick_count);
  time_taken_uint64 := trunc(time_taken_uint64 / 1000);
  Result := FormatDateTime('hh:nn:ss', time_taken_uint64 / SecsPerDay);
end;

// ------------------------------------------------------------------------------
// procedure: ConsoleLogMemo
// ------------------------------------------------------------------------------
procedure ConsoleLogMemo(AString: string);
begin
  Progress.Log(AString);
  Sleep(100);
  Progress.DisplayMessageNow := AString;
  if assigned(gResults_StringList) then
    gResults_StringList.Add(AString);
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
// function: TCommandTask Verify
// ------------------------------------------------------------------------------
function TCommandTask_VerifyDevice(theEntryList: TList): boolean;
var
  TaskProgress: TPAC;
begin
  Result := False;
  if not Progress.isRunning then
    Exit;
  try
    TaskProgress := Progress.NewChild; // Uses existing progress bar (TaskProgress := NewProgress(True) for separate new progress bar}
    RunTask('TCommandTask_VerifyDevice', '', theEntryList, TaskProgress, ['md5']); // sha1 sha256
    while (TaskProgress.isRunning) and (Progress.isRunning) do
      Sleep(500);
    if not(Progress.isRunning) then
      TaskProgress.Cancel;
    Result := (TaskProgress.CompleteState = pcsSuccess);
  except
    Progress.Log(ATRY_EXCEPT_STR + 'Error');
  end;
end;

// ------------------------------------------------------------------------------
// procedure: Update Device List
// ------------------------------------------------------------------------------
procedure UpdateDeviceList(aList: TList);
var
  EntryList: TDataStore;
  anEntry: TEntry;
begin
  aList.clear;
  EntryList := GetDataStore(DATASTORE_EVIDENCE);
  If not assigned(EntryList) then
    Exit;
  anEntry := EntryList.First;
  while assigned(anEntry) and (Progress.isRunning) do
  begin
    if anEntry.IsDevice then
      aList.Add(anEntry);
    anEntry := EntryList.Next;
  end;
  EntryList.free;
end;

// ------------------------------------------------------------------------------
// procedure: ResultString
// ------------------------------------------------------------------------------
function ResultString(hash1: string; hash2: string): string;
begin
  Result := '';
  if (hash1 = RS_VERIFICATION_STR) or (hash2 = RS_VERIFICATION_STR) or (hash1 = RS_NOT_PRESENT) or (hash2 = RS_NOT_PRESENT) then
  begin
    Result := 'N/A';
    Exit;
  end;
  if hash1 = hash2 then
    Result := 'Matched'
  else
    Result := RS_NOT_MATCHED;
end;

// ------------------------------------------------------------------------------
// procedure: Set Fields
// ------------------------------------------------------------------------------
procedure setfields;
var
  FileSystem_DataStore: TDataStore;
begin
  FileSystem_DataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(FileSystem_DataStore) then
    Exit;
  try
    gField_MD5_Acquisition := FileSystem_DataStore.DataFields.FieldByName['Acquisition Hash (MD5)']; // noslz
    gField_SHA1_Acquisition := FileSystem_DataStore.DataFields.FieldByName['Acquisition Hash (SHA1)']; // noslz
    gField_SHA256_Acquisition := FileSystem_DataStore.DataFields.FieldByName['Acquisition Hash (SHA256)']; // noslz
    gField_MD5 := FileSystem_DataStore.DataFields.FieldByName['Hash (MD5)']; // noslz
    gField_SHA1 := FileSystem_DataStore.DataFields.FieldByName['Hash (SHA1)']; // noslz
    gField_SHA256 := FileSystem_DataStore.DataFields.FieldByName['Hash (SHA256)']; // noslz
  finally
    FileSystem_DataStore.free;
  end;
end;

// ------------------------------------------------------------------------------
// function: Strip Illegal Characters
// ------------------------------------------------------------------------------
function StripIllegalChars(AString: string): string;
var
  x: integer;
const
  IllegalCharSet: set of char = ['|', '<', '>', '^', '+', '=', '?', '[', ']', '"', ';', ',', '*'];
begin
  for x := 1 to length(AString) do
    if AString[x] in IllegalCharSet then
      AString[x] := '_';
  Result := AString;
end;

// ------------------------------------------------------------------------------
// procedure: Export Results Form Content to a File
// ------------------------------------------------------------------------------
procedure ExportResultsToFile(aStringList: TStringList; aEntry: TEntry);
const
  RS_FILE_NOT_FOUND = 'File not found:';
  RS_FOLDER_NOT_FOUND = 'Folder not found:';
  RS_ERROR_SAVING = 'Error saving:';
  RS_RESULT_SAVED = 'Result saved:';

var
  CurrentCaseDir: string;
  Export_Filename: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportDir_str: string;
  ExportTime: string;
  FEXLABGlobalOutputDir_str: string;
  save_path: string;

begin
  CurrentCaseDir := GetCurrentCaseDir;
  ExportDir_str := CurrentCaseDir + 'Reports\';
  ExportDate := FormatDateTime('yyyy-mm-dd', now);
  ExportTime := FormatDateTime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + ' - ' + ExportTime);
  if gbl_match then
    Progress.Log('gbl_match_warning:' + BoolToStr(gbl_match, True));

  if DirectoryExists(ExportDir_str) then
  begin
    if assigned(aStringList) and (aStringList.Count > 0) then
    begin
      Export_Filename := ExportDateTime + HYPHEN + SCRIPT_NAME + HYPHEN + aEntry.EntryName + '.txt';
      Export_Filename := StripIllegalChars(Export_Filename);

      // Save to Case Reports folder
      save_path := ExportDir_str + Export_Filename;
      try
        aStringList.SaveToFile(save_path);
        Sleep(1000);
        if FileExists(save_path) then
          ConsoleLogMemo(format(FORMAT_STR, [RS_RESULT_SAVED, save_path]));
      except
        ConsoleLogMemo(RS_ERROR_SAVING + save_path);
        Progress.Log(format(FORMAT_STR, [RS_ERROR_SAVING, save_path]));
        Progress.DisplayMessageNow := RS_ERROR_SAVING + save_path;
      end;

      // Save to global output folder
      if GLOBAL_FLDR_BL then
      begin
        if DirectoryExists(FLDR_GLB1) then
        begin
          FEXLABGlobalOutputDir_str := FLDR_GLB1;
          ConsoleLogMemo(format(FORMAT_STR, ['Folder Exists: ' + BoolToStr(DirectoryExists(FEXLABGlobalOutputDir_str), True), FLDR_GLB1]));
        end
        else if DirectoryExists(FLDR_GLB2) then
        begin
          FEXLABGlobalOutputDir_str := FLDR_GLB2;
          ConsoleLogMemo(format(FORMAT_STR, ['Folder Exists: ' + BoolToStr(DirectoryExists(FEXLABGlobalOutputDir_str), True), FLDR_GLB2]));
        end
        else if DirectoryExists(FLDR_GLB3) then
        begin
          FEXLABGlobalOutputDir_str := FLDR_GLB3;
          ConsoleLogMemo(format(FORMAT_STR, ['Folder Exists: ' + BoolToStr(DirectoryExists(FEXLABGlobalOutputDir_str), True), FLDR_GLB3]));
        end
        else
        begin
          FEXLABGlobalOutputDir_str := '';
          ConsoleLogMemo('Could not find Global folder.');
          Exit;
        end;
        gsave_file_glb_str := FEXLABGlobalOutputDir_str + BS + 'VERIFY' + BS + Export_Filename;
        if ForceDirectories(ExtractFileDir(gsave_file_glb_str)) and DirectoryExists(ExtractFileDir(gsave_file_glb_str)) then // Do not use OSFILENAME for network folders
          try
            aStringList.SaveToFile(gsave_file_glb_str);
            Sleep(1000);
            if FileExists(gsave_file_glb_str) then
              ConsoleLogMemo(format(FORMAT_STR, [RS_RESULT_SAVED, gsave_file_glb_str]));
          except
            ConsoleLogMemo(format(FORMAT_STR, [RS_ERROR_SAVING, gsave_file_glb_str]));
            Progress.DisplayMessageNow := RS_ERROR_SAVING + ExtractFileName(Export_Filename);
          end
        else
        begin
          ConsoleLogMemo(format(FORMAT_STR, [RS_FOLDER_NOT_FOUND, FEXLABGlobalOutputDir_str]));
        end;
      end;

    end;
  end
  else
    ConsoleLogMemo(format(FORMAT_STR, [RS_FOLDER_NOT_FOUND, ExportDir_str]));
end;

// ==============================================================================
// The start of the script
// ==============================================================================
var
  acquisition_md5: string;
  acquisition_sha1: string;
  acquisition_sha256: string;
  alist_Entry: TEntry;
  Device_TList: TList;
  i: integer;
  result_str: string;
  start_tick_verify: uint64;
  temp_TList: TList;
  verification_md5: string;
  verification_sha1: string;
  verification_sha256: string;

begin
  setfields;

  Device_TList := TList.Create;
  gResults_StringList := TStringList.Create;
  try
    UpdateDeviceList(Device_TList);

    if assigned(Device_TList) and (Device_TList.Count > 0) then
    begin
      Progress.Log(Stringofchar('-', CHAR_LENGTH));
      for i := 0 to Device_TList.Count - 1 do
      begin
        alist_Entry := TEntry(Device_TList[i]);
        gbl_match := False;

        if (CmdLine.ParamCount = 0) then
        begin
          temp_TList := TList.Create;
          temp_TList.Add(alist_Entry);
          try
            begin
              ConsoleLogMemo(format(FORMAT_STR, ['Verifying device:', alist_Entry.EntryName + RUNNING]));
              start_tick_verify := GetTickCount64;
              if TCommandTask_VerifyDevice(temp_TList) then
              begin
                ConsoleLogMemo(format(FORMAT_STR, ['Completed:', alist_Entry.EntryName]));
                ConsoleLogMemo(format(FORMAT_STR, ['Time Taken:', CalcTimeTaken(start_tick_verify)]));
              end
              else
              begin
                ConsoleLogMemo(format(FORMAT_STR, ['Error:', alist_Entry.EntryName]));
              end;
            end;
          finally
            temp_TList.free;
          end;
        end;

        // Get field value
        acquisition_md5 := gField_MD5_Acquisition.asString[alist_Entry];
        acquisition_sha1 := gField_SHA1_Acquisition.asString[alist_Entry];
        acquisition_sha256 := gField_SHA256_Acquisition.asString[alist_Entry];
        verification_md5 := gField_MD5.asString[alist_Entry];
        verification_sha1 := gField_SHA1.asString[alist_Entry];
        verification_sha256 := gField_SHA256.asString[alist_Entry];

        // Fix up field values
        if acquisition_md5 = '' then
          acquisition_md5 := RS_NOT_PRESENT;
        if acquisition_sha1 = '' then
          acquisition_sha1 := RS_NOT_PRESENT;
        if acquisition_sha256 = '' then
          acquisition_sha256 := RS_NOT_PRESENT;
        if verification_md5 = '' then
          verification_md5 := RS_VERIFICATION_STR;
        if verification_sha1 = '' then
          verification_sha1 := RS_VERIFICATION_STR;
        if verification_sha256 = '' then
          verification_sha256 := RS_VERIFICATION_STR;

        // Header & results - vertical
        result_str := '';
        ConsoleLogMemo(' ');
        result_str := ResultString(acquisition_md5, verification_md5);
        ConsoleLogMemo(format(FORMAT_STR, ['MD5 Acquisition:', acquisition_md5]));
        ConsoleLogMemo(format(FORMAT_STR, ['MD5 Verification:', verification_md5]));
        ConsoleLogMemo(format(FORMAT_STR, ['MD5 Status:', result_str]));
        if result_str = RS_NOT_MATCHED then
          gbl_match := True;
        ConsoleLogMemo(' ');

        result_str := '';
        result_str := ResultString(acquisition_sha1, verification_sha1);
        ConsoleLogMemo(format(FORMAT_STR, ['SHA1 Acquisition:', acquisition_sha1]));
        ConsoleLogMemo(format(FORMAT_STR, ['SHA1 Verification:', verification_sha1]));
        ConsoleLogMemo(format(FORMAT_STR, ['SHA1 Status:', result_str]));
        if result_str = RS_NOT_MATCHED then
          gbl_match := True;
        ConsoleLogMemo(' ');

        result_str := '';
        result_str := ResultString(acquisition_sha256, verification_sha256);
        ConsoleLogMemo(format(FORMAT_STR, ['SHA256 Acquisition:', acquisition_sha256]));
        ConsoleLogMemo(format(FORMAT_STR, ['SHA256 Verification:', verification_sha256]));
        ConsoleLogMemo(format(FORMAT_STR, ['SHA256 Status:', result_str]));
        if result_str = RS_NOT_MATCHED then
          gbl_match := True;
        ConsoleLogMemo(' ');

        // Export results to file
        ExportResultsToFile(gResults_StringList, alist_Entry);
        ConsoleLogMemo(Stringofchar('-', CHAR_LENGTH));

        // Clear the results for the next pass
        gResults_StringList.clear;
      end;
    end;

  finally
    Device_TList.free;
    gResults_StringList.free;
  end;
  Progress.Log(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := ('Processing complete.');

end.
