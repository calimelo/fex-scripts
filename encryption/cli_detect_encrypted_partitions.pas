unit Detect_Encrypted_Partition;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  CHAR_LENGTH = 80;
  COMMA = ',';
  HYPHEN = ' - ';
  RPAD_VALUE = 40;
  RUNNING = '...';
  SCRIPT_NAME = 'Detect Encrypted Partition';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  DeviceList: TList;

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
// Procedure: Create RunTime Report (PDF or TXT)
// ------------------------------------------------------------------------------
procedure CreateRunTimeReport(aStringList: TStringList; save_name_str: string; dt_in_fileName_bl: boolean; shell_execute_open_bl: boolean; pdf_or_txt_str: string);
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

  if dt_in_fileName_bl then
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
          Sleep(500);
          if FileExists(SaveName) then
          begin
            Progress.Log('Success Creating: ' + SaveName);
            if shell_execute_open_bl then
              ShellExecute(0, nil, 'explorer.exe', Pchar(SaveName), nil, 1);
          end
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

// -----------------------------------------------------------------------------
// Function: Get Partitions
// -----------------------------------------------------------------------------
procedure GetPartitions;
var
  FileSystem_DataStore: TDataStore;
  Evidence_DataStore: TDataStore;
  dEntry: TEntry;
  FolderChildren_List: TList;
  cEntry: TEntry;
  i: integer;
begin
  if assigned(DeviceList) then
  begin
    DeviceList.Clear;
    Evidence_DataStore := GetDataStore(DATASTORE_EVIDENCE);
    FileSystem_DataStore := GetDataStore(DATASTORE_FILESYSTEM);
    if not assigned(Evidence_DataStore) then
      Exit; // no datastore available
    try
      dEntry := Evidence_DataStore.First;
      while assigned(dEntry) and (Progress.isRunning) do
      begin
        if dEntry.IsDevice then
        begin
          DeviceList.Add(dEntry);
          FolderChildren_List := TList.Create;
          FolderChildren_List := FileSystem_DataStore.Children(dEntry);
          try
            for i := 0 to FolderChildren_List.Count - 1 do
            begin
              cEntry := TEntry(FolderChildren_List[i]);
              if (dstPartition in cEntry.Status) then
                DeviceList.Add(cEntry);
            end;
          finally
            FolderChildren_List.free;
          end;
        end;
        dEntry := Evidence_DataStore.Next;
      end;
    finally
      Evidence_DataStore.free;
      FileSystem_DataStore.free;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Start of script
// ------------------------------------------------------------------------------
var
  aListEntry: TEntry;
  APFS_FolderChildren_List: TList;
  bl_apfs_found: boolean;
  bl_continue: boolean;
  bl_partition_is_bitlocker: boolean;
  bl_root_found: boolean;
  DecryptedPartition_StringList: TStringList;
  deviceEntry: TEntry;
  EncryptedPartition_StringList: TStringList;
  FolderChildren_List: TList;
  FolderChildrenFull_List: TList;
  FS_DataStore: TDataStore;
  i, j: integer;

procedure log_encrypted_partition(reason_str: string);
begin
  Progress.Log(RPad('Encrypted (' + reason_str + '):' + SPACE + 'Bates ID ' + IntToStr(deviceEntry.ID), RPAD_VALUE) + deviceEntry.EntryName + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]));
  EncryptedPartition_StringList.Add(deviceEntry.FullPathName + #13#10 + SPACE + RPad('Size:', 25) + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)])); // + #13#10 +
  // SPACE + RPad('Partition File Count:', 25) + SPACE + IntToStr(FolderChildrenFull_List.Count));
  EncryptedPartition_StringList.Add(' ');
end;

procedure log_decrypted_partition(reason_str: string);
begin
  Progress.Log(RPad('Decrypted (' + reason_str + '):' + SPACE + 'Bates ID ' + IntToStr(deviceEntry.ID), RPAD_VALUE) + deviceEntry.EntryName + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]));
  DecryptedPartition_StringList.Add(deviceEntry.FullPathName + #13#10 + SPACE + RPad('Size:', 25) + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]) + #13#10 + SPACE + RPad('Partition File Count:', 25) + SPACE +
    IntToStr(FolderChildrenFull_List.Count));
  DecryptedPartition_StringList.Add(' ');
end;

begin
  EncryptedPartition_StringList := TStringList.Create;
  EncryptedPartition_StringList.Add('WARNING: Partition(s) appear to be encrypted:');
  EncryptedPartition_StringList.Add(StringOfChar('-', CHAR_LENGTH));
  EncryptedPartition_StringList.Add(' ');

  DecryptedPartition_StringList := TStringList.Create;
  DecryptedPartition_StringList.Add('Decrypted Partition(s):');
  DecryptedPartition_StringList.Add(StringOfChar('-', CHAR_LENGTH));
  DecryptedPartition_StringList.Add(' ');

  FS_DataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(FS_DataStore) then
    Exit;

  DeviceList := TList.Create;
  if assigned(DeviceList) then
    GetPartitions;

  // Log Partitions
  for i := 0 to DeviceList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    deviceEntry := TEntry(DeviceList[i]);
    if (dstPartition in deviceEntry.Status) then
      Progress.Log(RPad('Partition - Bates ID: ' + IntToStr(deviceEntry.ID), RPAD_VALUE) + deviceEntry.EntryName);
  end;
  Progress.Log(StringOfChar('-', CHAR_LENGTH));

  try
    if assigned(DeviceList) and (DeviceList.Count > 0) then
    begin
      Progress.Initialize(DeviceList.Count, 'Processing...');
      for i := 0 to DeviceList.Count - 1 do
      begin
        bl_continue := True;
        if not Progress.isRunning then
          break;
        deviceEntry := TEntry(DeviceList[i]);

        if (dstPartition in deviceEntry.Status) then
        begin
          FolderChildren_List := FS_DataStore.Children(deviceEntry, False); // True is fully recursive
          FolderChildrenFull_List := FS_DataStore.Children(deviceEntry, True); // True is fully recursive
          try

            // --------------------------------------------------------------------
            // Bitlocker
            // --------------------------------------------------------------------
            if (deviceEntry.isEncrypted) then
            begin
              // --------------------------------------------------------------------
              // 1 - If partition name has 'Bitlocker' in the name
              // --------------------------------------------------------------------
              if RegexMatch(deviceEntry.EntryName, 'bitlocker', False) then
              begin

                // 1A - 0 contents - Bitlocker Encrypted
                if assigned(FolderChildren_List) and (FolderChildren_List.Count = 0) then
                begin
                  log_encrypted_partition('1A');
                  Continue;
                end
                else

                  // 1B - > 0 contents
                  if assigned(FolderChildren_List) and (FolderChildren_List.Count > 0) then
                  begin
                    bl_root_found := False;
                    for j := 0 to FolderChildren_List.Count - 1 do
                    begin
                      aListEntry := TEntry(FolderChildren_List[j]);
                      if aListEntry.EntryName = 'Root' then
                        bl_root_found := True;
                    end;
                  end;

                if bl_root_found then
                begin
                  log_decrypted_partition('1B');
                  Continue;
                end
                else
                begin
                  log_encrypted_partition('1B');
                  Continue;
                end;

                bl_continue := False;
              end;

              // --------------------------------------------------------------------
              // 2 - No Bitlocker in Name (e.g. 'Partition @ 63)
              // --------------------------------------------------------------------
              if bl_continue then
              begin
                bl_partition_is_bitlocker := False;
                if assigned(FolderChildren_List) and (FolderChildren_List.Count > 0) then
                  for j := 0 to FolderChildren_List.Count - 1 do
                  begin
                    aListEntry := TEntry(FolderChildren_List[j]);
                    if RegexMatch(aListEntry.EntryName, 'bitlocker', False) then
                    begin
                      bl_partition_is_bitlocker := True;
                    end;
                  end;
              end;

              if bl_partition_is_bitlocker then
              begin

                // 2 - > 0 contents
                if assigned(FolderChildren_List) and (FolderChildren_List.Count > 0) then
                begin
                  bl_root_found := False;
                  for j := 0 to FolderChildren_List.Count - 1 do
                  begin
                    aListEntry := TEntry(FolderChildren_List[j]);
                    if aListEntry.EntryName = 'Root' then
                      bl_root_found := True;
                  end;
                end;

                if bl_root_found then
                begin
                  log_decrypted_partition('2A');
                  Continue;
                end
                else
                begin
                  log_encrypted_partition('2B');
                  Continue;
                end;

                bl_continue := False;
              end;
            end;

            // --------------------------------------------------------------------
            // 3 - FileVault
            // --------------------------------------------------------------------
            if bl_continue and deviceEntry.isEncrypted then
            begin
              if assigned(FolderChildren_List) then
              begin
                // FileVault Encrypted
                if (FolderChildren_List.Count <= 1) then
                begin
                  aListEntry := TEntry(FolderChildren_List.First);
                  if assigned(aListEntry) and (aListEntry.isFreeSpace) then
                  begin
                    log_encrypted_partition('3A');
                    bl_continue := False;
                  end;
                end;
                // FileValut Decrypted
                if (FolderChildren_List.Count > 2) then
                begin
                  log_decrypted_partition('3B');
                  bl_continue := False;
                end;
              end;
            end;

            // --------------------------------------------------------------------
            // 4 - APFS - Improve this detection with an entry reader on the encrypted folder
            // --------------------------------------------------------------------
            if bl_continue then
            begin

              // Find APFS Nodes
              if assigned(FolderChildren_List) and (FolderChildren_List.Count > 0) then
              begin
                bl_apfs_found := False;
                for j := 0 to FolderChildren_List.Count - 1 do
                begin
                  aListEntry := TEntry(FolderChildren_List[j]);
                  if (aListEntry.isSystem) and RegexMatch(aListEntry.EntryName, 'APFS', True) then
                    bl_apfs_found := True;
                end;
              end;

              if bl_apfs_found and assigned(FolderChildren_List) then
              begin
                if (FolderChildren_List.Count > 0) then
                begin
                  for j := 0 to FolderChildren_List.Count - 1 do
                  begin
                    aListEntry := TEntry(FolderChildren_List[j]);
                    if assigned(aListEntry) and (aListEntry.IsDirectory) and (aListEntry.isEncrypted) then
                    begin
                      APFS_FolderChildren_List := TList.Create;
                      try
                        APFS_FolderChildren_List := FS_DataStore.Children(aListEntry);
                        if APFS_FolderChildren_List.Count <= 5 then
                        begin
                          log_encrypted_partition('4A');
                          bl_continue := False;
                        end;
                      finally
                        APFS_FolderChildren_List.free;
                      end;
                    end;
                  end;
                end;
                // APFS Decrypted
                if bl_continue and (FolderChildren_List.Count > 5) then
                begin
                  log_decrypted_partition('4B');
                  bl_continue := False;
                end;
              end;
            end;

          finally
            FolderChildren_List.free;
            FolderChildrenFull_List.free;
          end;
        end;
        Progress.IncCurrentProgress;
      end;
    end;
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    if assigned(EncryptedPartition_StringList) and (EncryptedPartition_StringList.Count > 3) then // 3 = Number of lines in the heading
    begin
      CreateRunTimeReport(EncryptedPartition_StringList, 'WARNING - Encrypted Partition', False, True, 'txt'); // aStringList, save_name_str, dt_in_fileName_bl, shell_execute_open_bl, pdf_or_txt_str
      Progress.DisplayMessageNow := ('Encrypted Partitions (Found: ' + IntToStr(EncryptedPartition_StringList.Count - 3) + ')');
    end
    else
      Progress.DisplayMessageNow := ('Encrypted Partitions (Found: 0)');

    if assigned(DecryptedPartition_StringList) and (DecryptedPartition_StringList.Count > 3) then // 3 = Number of lines in the heading
      CreateRunTimeReport(DecryptedPartition_StringList, 'INFORMATION - A partition was decrypted', False, False, 'txt');

  finally
    FS_DataStore.free;
    EncryptedPartition_StringList.free;
    DecryptedPartition_StringList.free;
    DeviceList.free;
  end;
  Progress.Log(SCRIPT_NAME + ' finished.');

end.
