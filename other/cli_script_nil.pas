unit cli_nil;

interface

uses
  Classes, Common, DataEntry, DataStorage, DateUtils, Regex, SysUtils, Variants;

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

begin
  // InList to OutList --------------------------------------------------------
  if assigned(InList) and (InList.Count > 0) and assigned(OutList) then
  begin
    OutList := InList;
    Progress.Log('InList Count: ' + IntToStr(InList.Count));
    Progress.Log('OutList Count: ' + IntToStr(OutList.Count));
  end
  else
    Progress.Log('No InList');

  if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
    ShellExecute(0, nil, 'explorer.exe', Pchar(Progress.LogFilename), nil, 1);

end.
