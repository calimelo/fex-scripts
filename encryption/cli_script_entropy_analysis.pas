{ !NAME:      CLI_Entropy_Analysis.pas }
{ !DESC:      Calculate a file entropy score. }
{ !AUTHOR:    GetData }

unit cli_entropy_analysis;

interface

uses
  Classes, DataEntry, DataStorage, Graphics, Math, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  SCRIPT_NAME = 'Entropy Analyzer';
  CHAR_LENGTH = 80;

implementation

// Right Pad Console Logs ------------------------------------------------------
function RPad(AString: string; AChars: integer): string;
begin
  while length(AString) < AChars do
    AString := AString + ' ';
  Result := AString;
end;

// This is the main procedure called after the 'Run' button is clicked =========
procedure MainProc;
const
  BufferSize = 4096 * 4;
var
  b: integer;
  byteCounts: array [0 .. 255] of int64;
  bytesRead: integer;
  Entry: TEntry;
  EntryList: TDatastore;
  EntryReader: TEntryReader;
  FieldEntropy: TDataStoreField;
  filebuffer: array [0 .. 16383] of byte;
  fileEntropy: extended;
  LogicalSize: int64;
  NumberEntries: integer;
  p: double;
  processed_file_count_int: integer;
  ReadStream: Boolean;
  use_existing_entorpy_bl: Boolean;
  use_existing_entropy_str: string;

begin
  processed_file_count_int := 0;
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if EntryList = nil then
  begin
    Progress.Log('Datastore "' + DATASTORE_FILESYSTEM + '" not found');
    Exit;
  end;
  NumberEntries := EntryList.Count;

  // Update progress bar
  Progress.Initialize(NumberEntries, 'Starting...');
  Progress.DisplayTitle := 'Entropy Analysis';
  Progress.Log('About to scan ' + IntToStr(NumberEntries) + ' items.');

  Entry := EntryList.First;
  if Entry = nil then
  begin
    Progress.Log('No items found.');
    EntryList.free;
    Exit;
  end;

  try
    // Register Metadata Names to be used for the column display
    FieldEntropy := AddMetaDataField('Entropy', ftExtended);

    use_existing_entorpy_bl := True;
    if use_existing_entorpy_bl then
      use_existing_entropy_str := 'True'
    else
      use_existing_entropy_str := 'False';

    Progress.Log('Keep existing entropy values:' + ' ' + use_existing_entropy_str);

    // ==========================================================================
    // Calculate Entropy - Loop
    // ==========================================================================
    Entry := EntryList.First;
    EntryReader := TEntryReader.Create;
    while assigned(Entry) and Progress.isRunning do
    begin
      if (not Entry.IsDirectory) and (Entry.LogicalSize > 0) and (Entry.PhysicalSize > 0) then
      begin
        if (assigned(FieldEntropy)) and (FieldEntropy.AsString[Entry] = '') then
        begin
          LogicalSize := Entry.LogicalSize;
          fileEntropy := 0.0;

          // Progress.Log('Currently Processing: ' + Entry.FullPathName);
          // If the entry is unallocated space then we do the whole lot in chunks
          // If the entry is an allocated file then we check the first 4096 bytes only.
          processed_file_count_int := processed_file_count_int + 1;

          if EntryReader.OpenData(Entry) then
          begin
            for b := 0 to 255 do
              byteCounts[b] := 0; // Initialize the array

            Progress.DisplayMessages := 'Analyzing ' + Entry.EntryName;
            try
              bytesRead := EntryReader.Read(filebuffer[0], BufferSize);
              if bytesRead > 0 then
              begin
                // Form the character distribution
                for b := 0 to bytesRead - 1 do
                  inc(byteCounts[filebuffer[b]]);

                // Calculate the entropy from the character distribution
                for b := 0 to 255 do
                begin
                  p := byteCounts[b] / bytesRead;
                  if p > 0.0 then
                    fileEntropy := fileEntropy - p * Log2(p);
                end;
                fileEntropy := fileEntropy * 0.125; // Divide by 8 to get range between 0 and 1.
              end;
            except
              ReadStream := False;
            end;

            FieldEntropy.AsExtended[Entry] := fileEntropy;
          end
          else
            Progress.Log('Could not open data: ' + Entry.EntryName);
        end;
      end;
      Entry := EntryList.Next;
      Progress.IncCurrentprogress;
    end;
  finally
    EntryReader.free;
    EntryList.free;
    Progress.Log(IntToStr(processed_file_count_int) + ' files analyzed.');
  end;
end;

// ==============================================================================
// The start of the script
// ==============================================================================
var
  // Starting Checks
  bContinue: Boolean;
  CaseName: string;
  rpad_value: integer;
  StartCheckDataStore: TDatastore;
  StartCheckEntry: TEntry;

begin
  Progress.Log(SCRIPT_NAME + ' started');
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessage := 'Starting...';
  rpad_value := 30;

  // ===========================================================================
  // Starting Checks
  // ===========================================================================
  // Check to see if the FileSystem module is present
  bContinue := True;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      Progress.Log(DATASTORE_FILESYSTEM + ' module not located. The script will terminate.');
      bContinue := False;
      Exit;
    end;

    // Check to see if a case is present
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      Progress.Log('There is no current case. The script will terminate.');
      bContinue := False;
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;

    // Log case details
    Progress.Log(Stringofchar('~', CHAR_LENGTH));
    Progress.Log(RPad('Case Name:', rpad_value) + CaseName);
    Progress.Log(RPad('Script Name:', rpad_value) + SCRIPT_NAME);
    Progress.Log(RPad('Date Run:', rpad_value) + DateTimeToStr(now));
    Progress.Log(RPad('FEX Version:', rpad_value) + CurrentVersion);
    Progress.Log(Stringofchar('~', CHAR_LENGTH));

    // Check to see if there are files in the File System Module
    if StartCheckDataStore.Count <= 1 then
    begin
      Progress.Log('There are no files in the File System module. The script will terminate.');
      bContinue := False;
      Exit;
    end;

    // Exit if user cancels
    if not Progress.isRunning then
    begin
      Progress.Log('Canceled by user.');
      bContinue := False;
    end;
  finally
    StartCheckDataStore.free;
  end;

  // Continue?
  if Not bContinue then
    Exit;

  MainProc;
  Progress.Log(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := 'Processing complete';

end.
