unit created_md5_hashset_from_hashed_items;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, SysUtils;

const
  BS = '\';
  COL_MD5_HASH = 'Hash (MD5)';
  LB = '(';
  OSFILENAME = '\\?\'; // This is needed for long file names
  RB = ')';
  RPAD_VALUE = 35;
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gCaseName: string;
  gMD5_StringList: TStringList;
  gWorking_TList: TList;

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
// Function: Unique File Name
// ------------------------------------------------------------------------------
function GetUniqueFileName(AFileName: string): string;
var
  fnum: integer;
  fname: string;
  fpath: string;
  fext: string;
begin
  Result := AFileName;
  if FileExists(AFileName) then
  begin
    fext := ExtractFileExt(AFileName);
    fnum := 1;
    fname := ExtractFileName(AFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(AFileName);
    while FileExists(fpath + fname + '_' + IntToStr(fnum) + fext) do
    begin
      fnum := fnum + 1;
    end;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
  end;
end;

var
  anEntry: TEntry;
  DataStore_FS: TdataStore;
  hashset_fldr_str: string;
  MD5_Field: TDataStoreField;
  r: integer;
  savename_str: string;
  savepath_str: string;

begin
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore_FS = nil then
    Exit;

  gMD5_StringList := TStringList.Create;
  gWorking_TList := TList.Create;
  try
    // Get the Case Name
    anEntry := DataStore_FS.First;
    if assigned(anEntry) then
      gCaseName := anEntry.EntryName
    else
    begin
      Progress.Log('There is no current case.' + SPACE + TSWT);
      Exit;
    end;

    gWorking_TList := DataStore_FS.GetEntireList;
    if gWorking_TList.Count <= 1 then
    begin
      Progress.Log('There are no files in the module.' + SPACE + TSWT);
      Exit;
    end;

    // Setup Column
    MD5_Field := DataStore_FS.DataFields.FieldByName(COL_MD5_HASH);
    if MD5_Field = nil then
      Exit;

    // -------------------------------------------------------------------------
    // Create the HashSet StringList
    // -------------------------------------------------------------------------
    MD5_Field := DataStore_FS.DataFields.FieldByName(COL_MD5_HASH);
    while assigned(anEntry) and Progress.isRunning do
    begin
      if assigned(anEntry) then
      begin
        if not MD5_Field.isNull(anEntry) then
        begin
          gMD5_StringList.Add(MD5_Field.AsString[anEntry]);
          // Progress.Log(MD5_Field.AsString[anEntry]);
        end
      end;
      anEntry := DataStore_FS.Next;
    end;

    // Remove blank lines from StringList
    for r := gMD5_StringList.Count - 1 downto 0 do
    begin
      if trim(gMD5_StringList[r]) = '' then
        gMD5_StringList.Delete(r);
    end;

    Progress.Log(RPad('MD5 Hashes found:', RPAD_VALUE) + IntToStr(gMD5_StringList.Count));
    hashset_fldr_str := GetCurrentCaseDir + 'Exported' + BS + 'HashSet';

    if ForceDirectories(OSFILENAME + IncludeTrailingPathDelimiter(hashset_fldr_str)) and DirectoryExists(hashset_fldr_str) then
    begin
      if assigned(gMD5_StringList) and (gMD5_StringList.Count > 0) then
      begin
        if DirectoryExists(hashset_fldr_str) then
        begin
          savename_str := 'MD5_HashSet_' + GetUniqueFileName(gCaseName);
          savepath_str := hashset_fldr_str + BS + savename_str + '.txt';
          gMD5_StringList.SaveToFile(savepath_str);
          if FileExists(savepath_str) then
            Progress.Log(RPad('MD5 HashSet saved' + SPACE + LB + IntToStr(gMD5_StringList.Count) + SPACE + 'hashes' + RB + ':', RPAD_VALUE) + savepath_str)
          else
            Progress.Log(RPad('MD5 HashSet not saved:', RPAD_VALUE) + savepath_str + '.txt');
        end
        else
          Progress.Log(RPad('Could not find folder:', RPAD_VALUE) + hashset_fldr_str);
      end
      else
        Progress.Log('No MD5 hashed files found.');
    end
    else
    begin
      Progress.Log(RPad('Could not create folder:', RPAD_VALUE) + hashset_fldr_str);
    end;

  finally
    DataStore_FS.free;
    gMD5_StringList.free;
    gWorking_TList.free;
  end;
  Progress.Log('Script finished.');

end.
