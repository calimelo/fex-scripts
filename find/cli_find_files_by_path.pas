{!NAME:      cli_find_files_by_path.pas}
{!DESC:      Find a file, or files, by path.}
{!AUTHOR:    GetData}

unit FindFilesByPath;

interface

uses
  Classes, Common, DataEntry, DataStorage, SysUtils;

const
  CHAR_LENGTH = 80;
  RPAD_VALUE = 30;
  RUNNING = '...';
  SCRIPT_NAME = 'Find Entries By Path';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gFindTheseFiles_StringList: TStringList;

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
// Function: Make sure the InList and OutList exist
//------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string) : boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Function: Parameters Received
//------------------------------------------------------------------------------
function ParametersReceived : boolean;
var
  i: integer;
begin
  Result := False;
  Progress.Log(Stringofchar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + cmdline.params[i]);
    end;
  end
  else
  begin
    Progress.Log('No parameters were received.');
  end;
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Function: validate_parameters
//------------------------------------------------------------------------------
procedure validate_parameters;
var
  LineList: TStringList;
  i: integer;
begin
  LineList := TStringList.Create;
  try

    if CmdLine.ParamCount > 0 then
    begin

      // Process INPUTBOX ------------------------------------------------------
      if cmdline.params[0] = 'INPUTBOX' then
      begin
        Progress.Log(RPad('Parameter Type:', RPAD_VALUE) + 'INPUTBOX');
        LineList := TStringList.Create;
        LineList.Delimiter := ',';
        LineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter

        // Start at 1 to skip past INPUTBOX
        for i := 1 to CmdLine.ParamCount - 1 do
        begin
          lineList.CommaText := CmdLine.Params[i];
          Progress.Log(RPad('LineList ' + IntToStr(i) + ', count:' + IntToStr(LineList.Count), RPAD_VALUE) + LineList.CommaText);
          if LineList.Count = 4 then
          begin
            if LineList[2] = UpperCase('True') then
              gFindTheseFiles_StringList.Add(LineList[3]);
          end;
        end;

      end
	  else
      begin
	    for i := 0 to CmdLine.ParamCount - 1 do
	    begin
          gFindTheseFiles_StringList.Add(cmdline.params[i]);
	    end;
      end;		
    end
	else
	  Progress.Log('No parameters received.' + SPACE + TSWT);
  finally
    LineList.free;
  end;
  Progress.Log(Stringofchar('-', 80));
end;

//------------------------------------------------------------------------------
// Start of Script
//------------------------------------------------------------------------------
var
  dsFileSystem: TDataStore;
  FoundList: TList;
  UniqueList: TUniqueListOfEntries;
  i: integer;
  anEntry: TEntry;
  FirstEntry: TEntry;
  Enum: TEntryEnumerator;

begin
  Progress.Log(SCRIPT_NAME + SPACE + 'started' + RUNNING);

  if not ParametersReceived then
  begin
    Progress.Log('No parameters received.' + SPACE + TSWT);
    Exit;
  end;

  // Check that InList and OutList exist, and InList count > 0
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    Exit
  else
  begin
    if InList.Count = 0 then
    begin
      Progress.Log('InList count is zero.' + SPACE + TSWT);
      Exit;
    end;
  end;

  dsFileSystem := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(dsFileSystem) then
    Exit;

  gFindTheseFiles_StringList := TStringList.Create;
  FoundList := TList.Create;
  UniqueList := TUniqueListOfEntries.Create;
  try
    validate_parameters;

    // Log the search terms read
    if assigned(gFindTheseFiles_StringList) and (gFindTheseFiles_StringList.Count > 0 ) then
    begin
      Progress.Log('Search terms read:');
      for i := 0 to gFindTheseFiles_StringList.Count -1 do
      begin
        Progress.Log(RPad(IntToStr(i+1), RPAD_VALUE) + gFindTheseFiles_StringList(i));
      end;
    end;
    
    // Find the files in the paths specified in the parameters received
    for i := 0 to gFindTheseFiles_StringList.Count - 1 do
    begin
      dsFileSystem.FindEntriesByPath(nil, gFindTheseFiles_StringList(i), FoundList);
    end;

    // Add the found list to the unique list
    for i := 0 to FoundList.Count -1 do
    begin
      anEntry := TEntry(FoundList[i]);    
      UniqueList.Add(anEntry);    
    end;
    
    if assigned(UniqueList) and (UniqueList.Count > 0) then
    begin
      Progress.Log(Stringofchar('-', CHAR_LENGTH));    
      Progress.Log(RPad('Unique List Count:', RPAD_VALUE) + IntToStr(UniqueList.Count));
      Enum := UniqueList.GetEnumerator;
      while Enum.MoveNext do
      begin
        anEntry := Enum.Current;
        OutList.Add(anEntry);
      end;
    end
    else
    begin    
      Progress.Log(Stringofchar('-', CHAR_LENGTH));
      Progress.Log('No files found.');  
    end;

  finally
    dsFileSystem.free;
    FoundList.free;
    UniqueList.free;
    gFindTheseFiles_StringList.free;
  end;

  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
end.