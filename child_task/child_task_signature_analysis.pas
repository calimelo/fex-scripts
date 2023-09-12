unit child_task_signature_analysis;
                
interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils,
  fex_triage_resource_strings in '..\common\resource_strings.pas';  

const
  TASK = RS_TASKLIST_BL_FILE_SIGNATURE_ALL_FILES;
  RPAD_VALUE = 30;
  SPACE = ' ';
  THE_InList = 'InList';

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

//-----------------------------------------------------------------------------
// Function: Right Pad v2
//-----------------------------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

//-----------------------------------------------------------------------------
// Function: Make sure the InList and OutList exist
//-----------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string): boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    if ListName_str = THE_InList then
      Progress.Log(RPad(ListName_str + SPACE + 'count:', rpad_value) + IntToStr(aList.Count));  
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

//-----------------------------------------------------------------------------
// Start of Script
//-----------------------------------------------------------------------------
begin
  Progress.Log(Stringofchar('-', 80));
  ListExists(InList, THE_INLIST);
  Progress.Log(Stringofchar('-', 80));  

  // File Signature -----------------------------------------------------------
  if UpperCase(ScriptTask.GetTaskListOption(TASK)) <> 'True' then 
  begin
    ScriptTask.SkipChildren := True;
    Progress.Log(RPad('Child task: ' + TASK, RPAD_VALUE) + 'False');    
  end
  else
    Progress.Log(RPad('Child task: ' + TASK, RPAD_VALUE) + 'True');
    
  // InList to OutList --------------------------------------------------------
  if assigned(InList) and (InList.Count > 0) and assigned(OutList) then
    OutList := inList;
  
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
  Progress.Log('Script finished.');
  //ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);
end.