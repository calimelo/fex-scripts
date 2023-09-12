unit update_bmfolder_count_comment;

interface

uses
  Classes, Common, DataEntry, DataStorage, NoteEntry, RegEx, SysUtils, Math;

implementation

const
  BS = '\';
  CHAR_LENGTH = 80;
  DBS = '\\';
  HYPHEN = ' - ';
  RPAD_VALUE = 35;
  RUNNING = '...';
  SPACE = ' ';
  TSWT = 'The script will terminate';

  // ------------------------------------------------------------------------------
  // Procedure: Right Pad
  // ------------------------------------------------------------------------------
function RPad(Astring: string; AChars: integer): string;
begin
  while length(Astring) < AChars do
    Astring := Astring + ' ';
  Result := Astring;
end;

// ------------------------------------------------------------------------------
// Function: Parameters Received
// ------------------------------------------------------------------------------
function ParametersReceived: boolean;
var
  i: integer;
begin
  Result := False;
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
    end;
    Progress.Log(Stringofchar('-', 80));
  end
  else
  begin
    Progress.Log('No parameters were received.');
  end;
end;

// ==============================================================================
// Start of the Script
// ==============================================================================
var
  bmFolder: TEntry;
begin
  if not ParametersReceived then
    Exit;
  bmFolder := nil;
  bmFolder := FindBookmarkByName(CmdLine.params[0]);
  if (bmFolder = nil) or not(assigned(bmFolder)) then
  begin
    Progress.Log(RPad('Bookmark Folder not found:', RPAD_VALUE) + CmdLine.params[0]);
    Exit;
  end;
  if (bmFolder <> nil) and (assigned(bmFolder)) then
  begin
    Progress.Log(RPad('NNumberItemsinBookmark:', RPAD_VALUE) + IntToStr(NumberItemsinBookmark(bmFolder)));
    UpdateBookmark(bmFolder, IntToStr(NumberItemsinBookmark(bmFolder)));
  end;
  Progress.Log(Stringofchar('-', CHAR_LENGTH));
  Progress.Log('Script finished.');

end.
