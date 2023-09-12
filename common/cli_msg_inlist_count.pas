unit inList_Count;

interface

uses
  SysUtils;

implementation

const
  SPACE = '';

var
  task_str: string;
  description_str: string;

begin
  if CmdLine.ParamCount > 0 then
    task_str := CmdLine.params[0]
  else
    task_str := '**InList count**:';

  if assigned(inList) then
    description_str := IntToStr(inList.Count)
  else
    description_str := 'Not assigned';

  Progress.DisplayTitle := task_str;
  Progress.DisplayMessageNow := description_str;
  Progress.Log(task_str + SPACE + description_str);

end.
