unit OutList;

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
  task_str := '**OutList count**:';

  if assigned(OutList) then
    Progress.Log(outlist.text)
  else
    description_str := 'Not assigned';

  Progress.DisplayTitle := task_str;
  Progress.DisplayMessageNow := description_str;
  Progress.Log(task_str + SPACE + description_str);
end.