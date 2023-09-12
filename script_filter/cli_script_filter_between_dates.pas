unit Between_Dates;

interface

uses
  // GUI,
  Classes, Common, DataEntry, DataStorage, DateUtils, Graphics, Math, SysUtils, Variants;

const
  CHAR_LENGTH = 80;
  RPAD_VALUE = 35;
  SPACE = ' ';

implementation

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
// Start of Script
// ------------------------------------------------------------------------------
var
  anEntry: TEntry;
  btw_endng_var: variant;
  btw_start_var: variant;
  end_dt: TDateTime;
  i: integer;
  in_range_count: integer;
  out_range_count: integer;
  start_dt: TDateTime;
  Param: string;

begin
  Progress.Log(stringofchar('-', CHAR_LENGTH));
  if assigned(inList) then
    Progress.Log(RPad('InList Count:', RPAD_VALUE) + inttostr(inList.Count))
  else
  begin
    Progress.Log('No inList');
  end;

  // ----------------------------------------------------------------------------
  // Parameters Received
  // ----------------------------------------------------------------------------
  Param := '';
  if (CmdLine.ParamCount > 0) then
  begin
    Progress.Log(stringofchar('-', CHAR_LENGTH));
    Progress.Log(inttostr(CmdLine.ParamCount) + ' processing parameters received: ');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(' - Param ' + inttostr(i) + ': ' + CmdLine.params[i]);
      Param := Param + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(Param);
  end
  else
    Progress.Log('No parameters received.');
  if CmdLine.ParamCount <> 2 then
    Exit;

  // ----------------------------------------------------------------------------
  // Convert String to Start Date/Time
  // ----------------------------------------------------------------------------
  btw_start_var := CmdLine.params[0];
  try
    start_dt := VarToDateTime(btw_start_var);
  except
    Progress.Log(RPad('Exception:', RPAD_VALUE) + 'btw_start_var');
    Exit;
  end;
  Progress.Log(RPad('Start Date:', RPAD_VALUE) + DateTimeToStr(start_dt));

  // ----------------------------------------------------------------------------
  // Convert String to End Date/Time
  // ----------------------------------------------------------------------------
  btw_endng_var := CmdLine.params[1];
  try
    end_dt := VarToDateTime(btw_endng_var);
  except
    Progress.Log(RPad('Exception:', RPAD_VALUE) + 'btw_endng_var');
    Exit;
  end;
  Progress.Log(RPad('End Date:', RPAD_VALUE) + DateTimeToStr(end_dt));

  Progress.Log(stringofchar('-', CHAR_LENGTH));

  // ----------------------------------------------------------------------------
  // Compare Dates
  // ----------------------------------------------------------------------------
  Progress.Log(RPad('All Files:', RPAD_VALUE) + inttostr(inList.Count));
  for i := 0 to inList.Count - 1 do
  begin
    anEntry := TEntry(inList[i]);
    if assigned(anEntry) then
    begin
      if (CompareDate(anEntry.Created, start_dt) = -1) or (CompareDate(anEntry.Created, end_dt) = 1) then
      begin
        // Progress.Log(DateTimeToStr(start_dt) + ' >>> ' + DateTimeToStr(anEntry.Created) + ' >>> ' + DateTimeToStr(end_dt) + SPACE + 'No');
        out_range_count := out_range_count + 1;
      end
      else
      begin
        // Progress.Log(DateTimeToStr(start_dt) + ' >>> ' + DateTimeToStr(anEntry.Created) + ' >>> ' + DateTimeToStr(end_dt) + SPACE + 'Yes');
        in_range_count := in_range_count + 1;
        OutList.add(anEntry);
      end;
    end;
  end;
  Progress.Log(stringofchar('-', CHAR_LENGTH));
  Progress.Log(RPad('In Range:', RPAD_VALUE) + inttostr(in_range_count));
  Progress.Log(RPad('Out of Range:', RPAD_VALUE) + inttostr(out_range_count));
  Progress.Log(stringofchar('-', CHAR_LENGTH));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + inttostr(OutList.Count));
  Progress.Log('Finished.');

end.
