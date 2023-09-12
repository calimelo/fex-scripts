{ !NAME:      Is_FEX_Administrator.pas }
{ !DESC:      Determines if Forensic Explorer is running as Administrator }
{ !AUTHOR:    GetData }

unit Is_FEX_Administrator;

interface

uses
  Common, SysUtils;

const
  SCRIPT_NAME = 'Is FEX Administrator';
  TSWT = 'The script will terminate.';
  SPACE = ' ';

var
  Error: string;
  ExitCode: cardinal;
  Output: string;

implementation

function isCMDLaunchedAsAdmin: boolean;
begin
  Result := False;
  CaptureConsoleOutput('C:\WINDOWS\system32\cmd.exe', '/c net session', Output, Error, ExitCode, 0, 3000);
  if ExitCode = 0 then
    Result := True;
end;

// ==============================================================================
// Start of Script
// ==============================================================================
begin
  if isCMDLaunchedAsAdmin then
  begin
    Progress.Log('Forensic Explorer is running as Administrator');
  end
  else
  begin
    Progress.Log('This script requires Administrator privileges.');
    Progress.Log('Not running with Administrator privileges.' + SPACE + TSWT);
    Exit;
  end;

end.
