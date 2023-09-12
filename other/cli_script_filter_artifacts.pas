unit script_filter;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Script Filter';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

implementation

function ShellExecute(hWnd: cardinal; lpOperation: PChar; lpFile: PChar; lpParameter: PChar; lpDirectory: PChar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' Name 'ShellExecuteW';

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
// Function: Parameters Received
//------------------------------------------------------------------------------
function params : boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  param_str := '';
  Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
  if (CmdLine.ParamCount > 0) then
  begin
    Result := True;
    Progress.Log(Stringofchar('-', 80));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + cmdline.params[i]);
      param_str := param_str + '"' + cmdline.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
  begin
    Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + (IntToStr(CmdLine.ParamCount)));
    Result := False;
  end;
  Progress.Log(Stringofchar('-', 80));
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
end;

//------------------------------------------------------------------------------
// Start of the script
//------------------------------------------------------------------------------
var
  anEntryList: TDatastore;
  anEntry: TEntry;
  cmdparam_str: string;

begin
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  // Params Received
  if not params then
    Exit;

  // Check that InList and OutList exist and that InList is not empty
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    Exit;

  // InList Count
  if InList.Count <= 0 then
  begin
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Exit;
  end;

  // Protect Datastore
  anEntryList := GetDataStore(DATASTORE_ARTIFACTS);
  if not assigned(anEntryList) then
  begin
    Progress.Log('Not assigned a data store. The script will terminate.');
    Exit;
  end;
  
  // Protect Entry
  anEntry := anEntryList.First;
  if not assigned(anEntry) then
  begin
    Progress.Log('No entries in the data store. The script will terminate.');
    anEntryList.free;
    Exit;
  end;

  // Loop Entries
  try
    Progress.Initialize(anEntryList.Count, 'Processing...');
    while assigned(anEntry) and (Progress.isRunning) do
    begin
      if (CmdLine.ParamCount > 0) then
      begin
        cmdparam_str := trim(cmdline.params[0]);
        cmdparam_str := StringReplace(cmdparam_str,'(','\(',[rfReplaceAll]);
        cmdparam_str := StringReplace(cmdparam_str,')','\)',[rfReplaceAll]);
        if (RegexMatch(anEntry.FullPathName, cmdparam_str, False)) then
          OutList.add(anEntry);
      end;
      Progress.IncCurrentProgress;
      anEntry := anEntryList.Next;
    end;
  finally
    anEntryList.free;
  end;

  Progress.Log(Stringofchar('-', 80));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
  if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
    ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);     
end.