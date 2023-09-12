unit Itunes_Backup_Sig;

interface

uses
  Classes, Common, DataEntry, DataStorage, DIRegex, Graphics, Math, Regex, SysUtils;

const
  FBN_ITUNES_BACKUP_DOMAIN = 'iTunes Backup Domain'; // noslz
  FBN_ITUNES_BACKUP_NAME = 'iTunes Backup Name'; // noslz
  RPAD_VALUE = 55;
  SPACE = ' ';
  TSWT = 'The script will terminate.';

procedure iTunes_Backup_Signature_Analysis;

implementation

// -----------------------------------------------------------------------------
// Function: Right Pad v2
// -----------------------------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

procedure iTunes_Backup_Signature_Analysis;
const
  RUNNING = '...';
  CHAR_LENGTH = 80;
var
  FSDatastore: TDataStore;
  anEntry: TEntry;
  iTunesBackupFiles_TList: TList;
  FieldItunesDomain: TDataStoreField;
  FieldItunesName: TDataStoreField;
  Manifest_File_TList: TList;
  TaskProgress: TPAC;
  DeterminedFileDriverInfo: TFileTypeInformation;

begin
  FSDatastore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(FSDatastore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + #10#13 + #10#13 + TSWT);
    Exit;
  end;

  iTunesBackupFiles_TList := TList.Create;
  Manifest_File_TList := TList.Create;
  try
    FieldItunesDomain := FSDatastore.DataFields.FieldByName(FBN_ITUNES_BACKUP_DOMAIN);
    FieldItunesName := FSDatastore.DataFields.FieldByName(FBN_ITUNES_BACKUP_NAME);

    if (CmdLine.Params.Indexof('NOITUNES') = -1) then
    begin
      // ==========================================================================
      // Locate Manifest and iTunes files
      // ==========================================================================
      Progress.Initialize(FSDatastore.Count, 'Searching for iTunes Backups' + RUNNING);
      Progress.Log('Searching for iTunes Backups' + RUNNING);
      anEntry := FSDatastore.First;
      while assigned(anEntry) and Progress.isRunning do
      begin
        if (anEntry.EntryName = 'Manifest.mbdb') or // Old format
          ((anEntry.EntryName = 'Manifest.db') and // New format
          ((Length(anEntry.Parent.EntryName) >= 40) and (RegexMatch(anEntry.EntryName, '[0-9a-fA-F]+', False)))) then
        begin
          DetermineFileType(anEntry);
          DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
          if (DeterminedFileDriverInfo.ShortDisplayName = 'MBDB') or (DeterminedFileDriverInfo.ShortDisplayName = 'iTunes Manifest (SQLite)') then // Do not translate
          begin
            Manifest_File_TList.Add(anEntry);
            Progress.Log('Found Manifest: ' + anEntry.FullPathName);
          end;
        end;

        // Collect iTunes files ---------------------------------------------------
        if ((Length(anEntry.EntryName) = 40) and ((Length(anEntry.Parent.EntryName) >= 40) or (Length(anEntry.Parent.EntryName) = 2))) then
        begin
          if UpperCase(anEntry.EntryNameExt) = '' then
          begin
            if (RegexMatch(anEntry.EntryName, '[0-9a-fA-F]+', False)) then
            begin
              begin
                if (not anEntry.isDeleted) and (anEntry.PhysicalSize > 0) and (not anEntry.IsSystem) then
                begin
                  iTunesBackupFiles_TList.Add(anEntry);
                end;
              end;
            end;
          end;
        end;
        anEntry := FSDatastore.Next;
        Progress.IncCurrentProgress;
      end;

      // iTunes Signature Analysis
      if assigned(iTunesBackupFiles_TList) and (iTunesBackupFiles_TList.Count > 0) then
      begin
        Progress.Log(RPad('iTunes Backup files found:', RPAD_VALUE) + IntToStr(iTunesBackupFiles_TList.Count));
        Progress.DisplayMessageNow := 'Determining file signatures of iTunes Backup files' + RUNNING;
        Progress.Log('Determining signatures' + RUNNING);
        if Progress.isRunning then
          DetermineFileTypeList(iTunesBackupFiles_TList, [], Progress);
        Progress.Log('Signature analysis complete.');
        Progress.Log(StringOfChar('=', CHAR_LENGTH));
      end;

      // Extract Manifest Data
      if assigned(Manifest_File_TList) and (Manifest_File_TList.Count > 0) then
      begin
        Progress.DisplayMessageNow := 'Extracting iTunes Manifest information to columns' + RUNNING;
        Progress.Log('Extracting iTunes Manifest information to columns' + RUNNING);
        TaskProgress := NewProgress(True);
        RunTask('TCommandTask_AppleBackup', DATASTORE_FILESYSTEM, Manifest_File_TList, TaskProgress);
        while Not TaskProgress.IsFinished do
          Sleep(500); // Do not proceed until TCommandTask_AppleBackup is complete
      end
      else
        Progress.Log('Manifest data has already been extracted.');
      Progress.Log(StringOfChar('=', CHAR_LENGTH));

    end;
  finally
    FSDatastore.free;
    iTunesBackupFiles_TList.free;
    Manifest_File_TList.free;
  end;
end;

end.
