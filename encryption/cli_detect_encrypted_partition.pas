unit find_locked_partition;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  CHAR_LENGTH = 80;
  SPACE = ' ';
  HYPHEN = ' - ';
  COMMA = ', ';
  RPAD_VALUE = 30;

var
  DeviceList: TList;

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
// Function: Create a PDF
//------------------------------------------------------------------------------
procedure CreatePDF(aStringList: TStringList; FileSaveName_str: string; font_size: integer);
var
  CurrentCaseDir: string;
  SaveDir: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  SaveDir := CurrentCaseDir + 'Reports\Run Time Reports\';
  if assigned(aStringList) and (aStringList.Count > 0) then
  begin
    if ForceDirectories(IncludeTrailingPathDelimiter(SaveDir)) and DirectoryExists(SaveDir) then
      GeneratePDF(SaveDir + FileSaveName_str, aStringList, font_size);
    if FileExists(SaveDir + FileSaveName_str) then
      Progress.Log('Saved file to: ' + SaveDir + FileSaveName_str);
  end;
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
  FolderChildrenFull_List: TList;
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

//------------------------------------------------------------------------------
// Start of script
//------------------------------------------------------------------------------
var
  FS_DataStore: TDataStore;
  deviceEntry: TEntry;
  FolderChildren_List: TList;
  APFS_FolderChildren_List: TList;
  FolderChildrenFull_List: TList;
  aListEntry: TEntry;
  EncryptedPartition_StringList: TStringList;
  DecryptedPartition_StringList: TStringList;
  i,j: integer;
  bl_continue: boolean;
  bl_partition_is_bitlocker: boolean;
  bl_root_found: boolean;
  bl_apfs_found: boolean;

  procedure log_encrypted_partition(reason_str: string);
  begin
    Progress.Log(RPad('Encrypted (' + reason_str + '):' + SPACE + 'Bates ID ' + IntToStr(deviceEntry.ID), rpad_value) + deviceEntry.EntryName + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]));
    EncryptedPartition_StringList.Add(deviceEntry.FullPathName  + #13#10 +
    SPACE + RPad('Size:', 25) + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]));  // + #13#10 +
    //SPACE + RPad('Partition File Count:', 25) + SPACE + IntToStr(FolderChildrenFull_List.Count));
    EncryptedPartition_StringList.Add(' ');
  end;

  procedure log_decrypted_partition(reason_str: string);
  begin
    Progress.Log(RPad('Decrypted (' + reason_str + '):' + SPACE + 'Bates ID ' + IntToStr(deviceEntry.ID), rpad_value) + deviceEntry.EntryName + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]));
    DecryptedPartition_StringList.Add(deviceEntry.FullPathName + #13#10 +
    SPACE + RPad('Size:', 25) + SPACE + Format('%1.2n GB', [deviceEntry.PhysicalSize / (1024 * 1024 * 1024)]) + #13#10 +
    SPACE + RPad('Partition File Count:', 25) + SPACE + IntToStr(FolderChildrenFull_List.Count));
    DecryptedPartition_StringList.Add(' ');
  end;

begin
  EncryptedPartition_StringList := TStringList.Create;
  EncryptedPartition_StringList.Add('WARNING: Partition(s) appear to be encrypted:');
  EncryptedPartition_StringList.Add(Stringofchar('-', CHAR_LENGTH));
  EncryptedPartition_StringList.Add(' ');

  DecryptedPartition_StringList := TStringList.Create;
  DecryptedPartition_StringList.Add('Decrypted Partition(s):');
  DecryptedPartition_StringList.Add(Stringofchar('-', CHAR_LENGTH));
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
    deviceEntry := TEntry(DeviceList[i]);
    if (dstPartition in deviceEntry.Status) then
      Progress.Log(RPad('Partition - Bates ID: ' + IntToStr(deviceEntry.ID), rpad_value) + deviceEntry.EntryName);
  end;
  Progress.Log(Stringofchar('-', CHAR_LENGTH));

  try
    if assigned(DeviceList) and (DeviceList.Count > 0) then
    begin
      Progress.Initialize(DeviceList.Count, 'Processing...');
      for i := 0 to DeviceList.Count - 1 do
      begin
        bl_continue := True;
        if not Progress.isRunning then break;
        deviceEntry := TEntry(DeviceList[i]);

        if (dstPartition in deviceEntry.Status) then
        begin
          FolderChildren_List := FS_DataStore.Children(deviceEntry, False); // True is fully recursive
          FolderChildrenFull_List := FS_DataStore.Children(deviceEntry, True); // True is fully recursive
          try

            //--------------------------------------------------------------------
            // Bitlocker
            //--------------------------------------------------------------------
            if (deviceEntry.isEncrypted) then
            begin
              //--------------------------------------------------------------------
              // 1 - If partition name has 'Bitlocker' in the name
              //--------------------------------------------------------------------
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

                bl_Continue := False;
              end;

              //--------------------------------------------------------------------
              // 2 - No Bitlocker in Name (e.g. 'Partition @ 63)
              //--------------------------------------------------------------------
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

                bl_Continue := False;
              end;
            end;

            //--------------------------------------------------------------------
            // 3 - FileVault
            //--------------------------------------------------------------------
            if bl_continue and deviceEntry.isEncrypted then
            begin
              if assigned(FolderChildren_List) then
              begin
                // FileVault Encrypted
                if (FolderChildren_List.Count <= 1) then
                begin
                  aListEntry := TEntry(FolderChildren_List.first);
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

            //--------------------------------------------------------------------
            // 4 - APFS - Improve this detection with an entry reader on the encrypted folder
            //--------------------------------------------------------------------
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
                        if APFS_FolderChildren_List.Count <=5 then
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
    Progress.Log(Stringofchar('-', CHAR_LENGTH));

    if assigned(EncryptedPartition_StringList) and (EncryptedPartition_StringList.Count > 3) then // 3 = Number of lines in the heading
      CreatePDF(EncryptedPartition_StringList, 'WARNING - Encrypted Drive.pdf', 8);

    if assigned(DecryptedPartition_StringList) and (DecryptedPartition_StringList.Count > 3) then // 3 = Number of lines in the heading
      CreatePDF(DecryptedPartition_StringList, 'INFORMATION - A drive was decrypted.pdf', 8);

  finally
    FS_DataStore.free;
    EncryptedPartition_StringList.free;
    DecryptedPartition_StringList.free;
    DeviceList.free;
  end;
  Progress.Log('Script finished.');
end.