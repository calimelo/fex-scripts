unit NIST_Hacking_Case_Validation;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Regex, SysUtils;

const
  SCRIPT_NAME = 'NIST Hacking Case Validation';
  CHAR_LENGTH = 80;

  // NIST Hacking Case Expected Results
  EXPECTED_AVI_Ext_Count = 1;
  EXPECTED_DELETED_COUNT = 3;
  EXPECTED_DIRECTORY_Count = 773;
  EXPECTED_EXE_Ext_Count = 1009;
  EXPECTED_FILESYSTEM_COUNT = 23022;
  EXPECTED_GRAPHICS_COUNT = 1428; // was 1454
  EXPECTED_HASHSETKNOWN_COUNT = 8270;
  EXPECTED_INTERNET_COUNT = 421; // was 447;
  EXPECTED_JPG_Ext_Count = 253;
  EXPECTED_MD5_MAC_APP_STORE = 18;
  EXPECTED_MD5_US_GOVT = 46;
  EXPECTED_MD5_WHITEHASH_1OF2 = 448;
  EXPECTED_MD5_WHITEHASH_20F2 = 393;
  EXPECTED_VIDEO_COUNT = 34; // was 38;
  EXPECTED_WINTER_LOGICALSIZE = 105542;
  EXPECTED_WINTER_MD5 = 'B44A59383B3123A747D139BD0E71D2DF';
  EXPECTED_WINTER_PHYSICALSIZE = 105984;
  EXPECTED_WMV_Ext_Count = 6;
  EXPECTED_ZIP_Ext_Count = 43;

var
  aFileSystemEntry: TEntry;
  DeterminedFileDriverInfo: TFileTypeInformation;
  Directory_Count: integer;
  File_System_Count: integer;
  FileDriverInfo: TFileTypeInformation;
  FileExt: string;
  FileSystemEntryList: TDataStore;
  final_message_str: string;
  HashSetIdentifiedAs_Column: TDataStoreField;
  HashSetIdentifiedAs_str: string;
  MD5_Column: TDataStoreField;
  rpad_value: integer;
  starting_tick_Count: uint64;
  Winter_JPG_MD5_str: string;
  Winter_Logical_Size_int: integer;
  Winter_Physical_Size_int: integer;

  // Counters
  AVI_Ext_Count: integer;
  Deleted_Count: integer;
  EXE_Ext_Count: integer;
  Graphics_Count: integer;
  HashSetKnown_Count: integer;
  Internet_Count: integer;
  JPG_Ext_Count: integer;
  Video_Count: integer;
  WMV_Ext_Count: integer;
  ZIP_Ext_Count: integer;

implementation

function RPad(AString: string; AChars: integer): string;
begin
  while length(AString) < AChars do
    AString := AString + ' ';
  Result := AString;
end;

function CalcTimeTaken(starting_tick_Count: uint64): string;
var
  time_taken_uint64: uint64;
begin
  Result := '';
  time_taken_uint64 := (GetTickCount64 - starting_tick_Count);
  time_taken_uint64 := trunc(time_taken_uint64 / 1000);
  Result := FormatDateTime('hh:nn:ss', time_taken_uint64 / SecsPerDay);
end;

function StartingChecks: boolean;
var
  CaseName: string;
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
begin
  rpad_value := 26;
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessageNow := 'Starting test...';
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      Progress.Log(DATASTORE_FILESYSTEM + ' module not located. The script will terminate.');
      Exit;
    end;
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      Progress.Log('There is no current case. The script will terminate.');
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      Progress.Log('There are no files in the File System module. The script will terminate.');
      Exit;
    end;
    Result := True; // If it makes it this far then StartCheck is True
  finally
    StartCheckDataStore.free;
  end;
end;

procedure print_result_str(the_name: string; the_string: string; expected_string: string);
begin
  if the_string = expected_string then
    Progress.Log((format('%-25s %-13s %-10s %-10s', [the_name, 'OK', the_string, ''])))
  else
  begin
    Progress.Log((format('%-25s %-13s %-10s %-10s', [the_name, 'FAIL', the_string, '(Expected: ' + expected_string + ')'])));
    final_message_str := 'FAIL - Check logs';
  end;
end;

procedure print_result_int(the_name: string; the_Count: integer; expected_Count: integer);
begin
  if the_Count = expected_Count then
    Progress.Log((format('%-25s %-13s %-10s %-10s', [the_name, 'OK', IntToStr(the_Count), ''])))
  else
  begin
    Progress.Log((format('%-25s %-13s %-10s %-10s', [the_name, 'FAIL', IntToStr(the_Count), '(Expected: ' + IntToStr(expected_Count) + ')'])));
    final_message_str := 'FAIL - Check logs';
  end;
end;

// ==============================================================================
// START OF SCRIPT
// ==============================================================================
begin
  // Starting Check ------------------------------------------------------------
  if not StartingChecks then
    Exit;

  // Initialize Variables ------------------------------------------------------
  AVI_Ext_Count := 0;
  EXE_Ext_Count := 0;
  Graphics_Count := 0;
  HashSetKnown_Count := 0;
  Internet_Count := 0;
  JPG_Ext_Count := 0;
  Winter_JPG_MD5_str := '';
  rpad_value := 40;
  starting_tick_Count := GetTickCount64;
  Winter_Logical_Size_int := 0;
  Winter_Physical_Size_int := 0;
  WMV_Ext_Count := 0;
  ZIP_Ext_Count := 0;

  // Setup DataStores ----------------------------------------------------------
  FileSystemEntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(FileSystemEntryList) then
    Exit;

  try
    HashSetIdentifiedAs_Column := FileSystemEntryList.DataFields.FieldByName('HASHSET_IDENT');
    MD5_Column := FileSystemEntryList.DataFields.FieldByName('Hash (MD5)');

    // Loop ----------------------------------------------------------------------
    File_System_Count := FileSystemEntryList.Count;
    aFileSystemEntry := FileSystemEntryList.First; // Get the first entry

    while assigned(aFileSystemEntry) and Progress.isRunning do
    begin
      FileDriverInfo := aFileSystemEntry.FileDriverInfo;

      // Count Extensions - But not carved files
      FileExt := extractFileExt(UpperCase(aFileSystemEntry.EntryName));
      if not(dstLostFile in aFileSystemEntry.Status) then
      begin
        if FileExt = '.AVI' then
          AVI_Ext_Count := AVI_Ext_Count + 1;
        if FileExt = '.EXE' then
          EXE_Ext_Count := EXE_Ext_Count + 1;
        if FileExt = '.JPG' then
          JPG_Ext_Count := JPG_Ext_Count + 1;
        if FileExt = '.WMV' then
          WMV_Ext_Count := WMV_Ext_Count + 1;
        if FileExt = '.ZIP' then
          ZIP_Ext_Count := ZIP_Ext_Count + 1;
        if aFileSystemEntry.isDeleted then
          Deleted_Count := Deleted_Count + 1;
        if aFileSystemEntry.isDirectory then
          Directory_Count := Directory_Count + 1;
      end;

      if (dtGraphics in FileDriverInfo.DriverType) or (dtVideo in FileDriverInfo.DriverType) or (dtInternet in FileDriverInfo.DriverType) then
      begin
        // DetermineFileType(aFileSystemEntry);  // Should have been already been done (manually in GUI and automatically in CLI)
        DeterminedFileDriverInfo := aFileSystemEntry.DeterminedFileDriverInfo;
        if (dtGraphics in DeterminedFileDriverInfo.DriverType) then
          Graphics_Count := Graphics_Count + 1;
        if (dtInternet in DeterminedFileDriverInfo.DriverType) then
          Internet_Count := Internet_Count + 1;
        if (dtVideo in DeterminedFileDriverInfo.DriverType) then
          Video_Count := Video_Count + 1;
      end;

      if aFileSystemEntry.EntryName = 'Winter.jpg' then
      begin
        Winter_Logical_Size_int := aFileSystemEntry.LogicalSize;
        Winter_Physical_Size_int := aFileSystemEntry.PhysicalSize;
        if assigned(HashSetIdentifiedAs_Column) then
          Winter_JPG_MD5_str := UpperCase(MD5_Column.AsString[aFileSystemEntry]);
      end;

      if assigned(HashSetIdentifiedAs_Column) then
      begin
        HashSetIdentifiedAs_str := lowercase(HashSetIdentifiedAs_Column.AsString[aFileSystemEntry]);
        if (RegexMatch(HashSetIdentifiedAs_str, 'known', False)) then
          HashSetKnown_Count := HashSetKnown_Count + 1;
      end;

      aFileSystemEntry := FileSystemEntryList.Next;
    end;
  finally
    FreeAndNil(FileSystemEntryList);
  end;
  final_message_str := 'Processing Complete - Passed';

  // Results -------------------------------------------------------------------
  print_result_int('Total Entries:', File_System_Count, EXPECTED_FILESYSTEM_COUNT);
  print_result_int('Deleted Count:', Deleted_Count, EXPECTED_DELETED_COUNT);
  print_result_int('Directory Count:', Directory_Count, EXPECTED_DIRECTORY_Count);

  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  print_result_int('AVI Count:', AVI_Ext_Count, EXPECTED_AVI_Ext_Count);
  print_result_int('EXE Count:', EXE_Ext_Count, EXPECTED_EXE_Ext_Count);
  print_result_int('JPG Count:', JPG_Ext_Count, EXPECTED_JPG_Ext_Count);
  print_result_int('WMV Count:', WMV_Ext_Count, EXPECTED_WMV_Ext_Count);
  print_result_int('ZIP Count:', ZIP_Ext_Count, EXPECTED_ZIP_Ext_Count);

  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  print_result_int('Graphics Count:', Graphics_Count, EXPECTED_GRAPHICS_COUNT);
  print_result_int('Internet Count:', Internet_Count, EXPECTED_INTERNET_COUNT);
  print_result_int('Video Count:', Video_Count, EXPECTED_VIDEO_COUNT);

  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  print_result_int('Winter.jpg Logical Size:', Winter_Logical_Size_int, EXPECTED_WINTER_LOGICALSIZE);
  print_result_int('Winter.jpg Physical Size:', Winter_Physical_Size_int, EXPECTED_WINTER_PHYSICALSIZE);
  print_result_str('Winter MD5 Hash:', Winter_JPG_MD5_str, EXPECTED_WINTER_MD5);

  Progress.Log(RPad('Time Taken:', rpad_value) + CalcTimeTaken(starting_tick_Count));
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  Progress.Log(SCRIPT_NAME + ' finished.');

  Progress.DisplayMessageNow := final_message_str;
  Progress.Log(final_message_str);

end.
