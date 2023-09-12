{ !NAME:      cli_display_message.pas }
{ !DESC:      Provide feedback in the CLI window }
{ !AUTHOR:    GetDAta }

unit cli_display_message;

interface

uses
  SysUtils;

implementation

var
  i: integer;

begin

  Progress.DisplayTitle := 'Part 1';

  Progress.DisplayMessageNow := ('Step 1');
  Sleep(1000);

  Progress.DisplayMessageNow := ('Step 2');
  Sleep(1000);

  Progress.DisplayMessageNow := ('Step 3');
  Sleep(1000);

  Progress.DisplayMessageNow := ('Step 4');
  Sleep(1000);

  Progress.DisplayMessageNow := ('Step 5');
  Sleep(1000);

  Progress.DisplayTitle := 'Part 2';
  for i := 0 to 5 do
  begin
    Progress.DisplayMessageNow := ('For Loop: ' + IntToStr(i));
    Sleep(1000);
  end;

  Progress.DisplayTitle := 'Display Message Finished';
  Progress.DisplayMessageNow := ('The script reached the end.');

end.
