unit Bookmark_TList;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, NoteEntry, SysUtils;

const
  BS = '\';
  CHAR_LENGTH = 80;
  DCR = #10#13 + #10#13;
  HYPHEN = ' - ';
  RPAD_VALUE = 30;
  SPACE = ' ';
  TSWT = 'The script will terminate.';

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
function ParametersReceived: boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  Progress.Log(StringOfChar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    param_str := '';
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(HYPHEN + 'Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      param_str := param_str + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
    Progress.Log('No parameters were received.');
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Procedure: Bookmark TList
// ------------------------------------------------------------------------------
procedure BookmarkTList(aTList: TList; bm_path_str: string);
var
  bmFolder: TEntry;
begin
  if (assigned(aTList) and (aTList.Count > 0)) then
  begin
    Progress.Log(RPad('Bookmarking:', RPAD_VALUE) + IntToStr(aTList.Count));
    bmFolder := FindBookmarkByName('My Bookmarks' + BS + bm_path_str);
    if bmFolder = nil then
      bmFolder := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), bm_path_str, IntToStr(aTList.Count)); // Item count added as bookmark comment
    if assigned(bmFolder) then
      AddItemsToBookmark(bmFolder, DATASTORE_FILESYSTEM, aTList, IntToStr(aTList.Count)) // Item count added as bookmark comment
    else
      Progress.Log('Bookmark folder not found:' + SPACE + bm_path_str);
  end;
end;

// ==============================================================================
// Start of Script
// ==============================================================================
var
  anEntry: TEntry;
  bm_fldr_str: string;
  i: integer;
  DataStore_FS: TDataStore;
  UseInList_bl: boolean;
  Working_TList: TList;

begin
  UseInList_bl := True; // Use this for GUI testing

  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore_FS = nil then
    Exit;

  ParametersReceived;
  if (CmdLine.ParamCount > 0) then
  begin
    bm_fldr_str := trim(CmdLine.params[0]);

    Working_TList := TList.Create;
    try
      if UseInList_bl = False then
      begin
        Working_TList := DataStore_FS.GetEntireList;
        Progress.Log(RPad('Working with All items:', RPAD_VALUE) + IntToStr(Working_TList.Count));
      end
      // ------------------------------------------------------------------------
      // Else Use InList
      // ------------------------------------------------------------------------
      else
      begin
        if not assigned(inList) then
        begin
          Progress.Log('Not assigned inList.' + SPACE + TSWT);
          Exit;
        end;

        // Move the inList to the Working_TList
        for i := 0 to inList.Count - 1 do
        begin
          anEntry := TEntry(inList[i]);
          Working_TList.Add(anEntry);
        end;
      end;

      // Bookmark Working_TList
      if assigned(Working_TList) and (Working_TList.Count > 0) then
        BookmarkTList(Working_TList, bm_fldr_str);

    finally
      DataStore_FS.free;
      Working_TList.free;
    end;

  end;
  Progress.Log(StringOfChar('-', 80));
  Progress.Log('Script finished');

end.
