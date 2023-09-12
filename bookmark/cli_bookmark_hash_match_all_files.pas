unit bookmark_hash_match;

interface

uses
  Classes, Common, DataEntry, DataStorage, NoteEntry, RegEx, SysUtils, Math;

implementation

const
  RANDOM_TO_BOOKMARK_INT = 500;
  THREE_DOTS = '...';
  BM_FOLDER_SCRIPT_OUTPUT = 'FEX-Triage';
  BM_FOLDER_HASH_MATCH = 'Hash Match Random Selection\All Files';
  CHAR_LENGTH = 80;
  BS = '\';
  DBS = '\\';

var
  anEntry: TEntry;
  bmCount: integer;
  bmFolder: TEntry;
  colResult: string;
  Column: TDataStoreField;
  CurrentComment: string;
  DataStore: TDataStore;
  HashSetName_StringList: TStringList;
  i, idx, rand_idx: integer;
  LineList: TStringList;
  rpad_value: integer;

//------------------------------------------------------------------------------
// Procedure: Right Pad
//------------------------------------------------------------------------------
function RPad(Astring: string; AChars: integer): string;
begin
  while length(Astring) < AChars do
    Astring := Astring + ' ';
  Result := Astring;
end;

//------------------------------------------------------------------------------
// Procedure: Delete Existing Bookmarked Folders
//------------------------------------------------------------------------------
Procedure DeleteExistingBookmarkFolders;
var
  BmDataStore: TDataStore;
  bmfEntry: TEntry;
  ExistingFolders_StringList: TStringList;
  ExistingFolders_TList: TList;
  FolderDelete_TList: TList;
begin
  // Collect a list of the existing Bookmark module folders
  BmDataStore := GetDataStore(DATASTORE_BOOKMARKS);
  ExistingFolders_StringList := TStringList.Create;
  ExistingFolders_TList := TList.Create;
  FolderDelete_TList := TList.Create;
  if BmDataStore.Count > 1 then
  begin
    bmfEntry := BmDataStore.First;
    while assigned(bmfEntry) and Progress.isRunning do
    begin
      if bmfEntry.IsDirectory and
      (RegexMatch(bmfEntry.FullPathName, DBS + BM_FOLDER_SCRIPT_OUTPUT + DBS + BM_FOLDER_HASH_MATCH + DBS, False)) then
      begin
        ExistingFolders_StringList.Add(bmfEntry.EntryName);
        ExistingFolders_TList.Add(bmfEntry);
        FolderDelete_TList.Add(bmfEntry);
      end;
      bmfEntry := BmDataStore.Next;
    end;
    BmDataStore.close;
  end;
  if assigned(FolderDelete_TList) and (FolderDelete_TList.Count > 0) then
  begin
    try
      BmDataStore.Remove(FolderDelete_TList);
    except
      Progress.Log('ERROR: There was an error deleting existing bookmarks.');
    end;
  end;
  BmDataStore.free;
  ExistingFolders_StringList.free;
  ExistingFolders_TList.free;
  FolderDelete_TList.free;
end;

//==============================================================================================================================================
// Start of the Script
//==============================================================================================================================================
begin
  Column := nil;
  DataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore = nil then Exit;
  Column := DataStore.DataFields.FieldByName('HASHSET');
  if Column = nil then
  begin
    DataStore.free;
    Exit;
  end;

  bmCount := 0;
  rpad_value := 40;
  Progress.Log(RPad('Max bookmarks (random selection):', rpad_value) + IntToStr(RANDOM_TO_BOOKMARK_INT));
  Progress.Log(Stringofchar('-', CHAR_LENGTH));

  DeleteExistingBookmarkFolders;

  HashSetName_StringList := TStringList.Create;
  LineList := TStringList.Create;

  HashSetName_StringList.Sorted := True;
  HashSetName_StringList.Duplicates := dupIgnore;

  LineList.Delimiter := ','; // Default, but ";" is used with some locales
  LineList.QuoteChar := '"'; // Default
  LineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter

  try
    Progress.Initialize(DataStore.Count, 'Collecting HashSet names...');
    anEntry := DataStore.First;
    while assigned(anEntry) and assigned(Column) do
    begin
      colResult := Column.AsString[anEntry];
      if colResult <> '' then
      begin
        lineList.CommaText := Column.asString[anEntry];
        for i := 0 to lineList.Count - 1 do
        begin
          idx := HashSetName_StringList.Add(LineList[i]);
          if not assigned(HashSetName_StringList.Objects[idx]) then
            HashSetName_StringList.Objects[idx] := TList.Create;
          TList(HashSetName_StringList.Objects[idx]).Add(anEntry);
        end;
      end;
      anEntry := DataStore.Next;
      Progress.IncCurrentprogress;
    end;
    Progress.Log(RPad('Unique HashSet names:', rpad_value) + IntToStr(HashSetName_StringList.Count));

    // Create bookmark folder using hash set names
    if assigned(HashSetName_StringList) and (HashSetName_StringList.Count > 0) then
    begin
      for i := 0 to HashSetName_StringList.Count - 1 do
      begin
        if not Progress.isRunning then break;

        bmFolder := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + BS + BM_FOLDER_HASH_MATCH);
        if bmFolder = nil then
          bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + BS + BM_FOLDER_HASH_MATCH);
        CurrentComment := '';

        bmFolder := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + BS + BM_FOLDER_HASH_MATCH + BS + HashSetName_StringList[i]);
        if bmFolder = nil then
          bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + BS + BM_FOLDER_HASH_MATCH + BS + HashSetName_StringList[i], {HashSetName_StringList[i] + }'Random selection of up to ' + IntToStr(RANDOM_TO_BOOKMARK_INT) + ' matched files.');

        Randomize;
        if assigned(bmFolder) then
        begin
          if assigned(HashSetName_StringList.Objects[i]) then
          begin
            // If less than our random maximum bookmark all
            if TList(HashSetName_StringList.Objects[i]).Count <= RANDOM_TO_BOOKMARK_INT then
              AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, TList(HashSetName_StringList.Objects[i]), '')
            else
            // Bookmark random selection
            begin
              while NumberItemsinBookmark(bmFolder) < RANDOM_TO_BOOKMARK_INT do
              begin
                rand_idx := RandomRange(0, TList(HashSetName_StringList.Objects[i]).Count - 1);
                if not IsItemInBookmark(bmFolder, TEntry(TList(HashSetName_StringList.Objects[i]).Items[rand_idx])) then
                begin
                  AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, TEntry(TList(HashSetName_StringList.Objects[i]).Items[rand_idx]), '');
                  bmCount := bmCount + 1;
                end;
              end;
            end;
          end;
        end;
        CurrentComment := TNoteEntry(bmFolder).Comment;
        Progress.Log(RPad(HashSetName_StringList[i], rpad_value) + 'Bookmarked: ' + IntToStr(NumberItemsinBookmark(bmFolder)) + ' of ' + IntToStr(TList(HashSetName_StringList.Objects[i]).Count));
      end;
    end;
  finally
    DataStore.free;
    HashSetName_StringList.free;
  end;
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  Progress.DisplayMessageNow := ('Bookmarked ' + IntToStr(bmCount) + ' hash matched files.');
  Progress.Log('Bookmarked ' + IntToStr(bmCount) + ' hash matched files.');
  Progress.Log('Script finished');
end.
