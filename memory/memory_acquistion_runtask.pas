unit RunTask_AcquireMemory;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, SysUtils;

implementation

var
  TaskProgress: TPac;
begin
  Progress.Log('Acquire Memory...');
  TaskProgress := Progress.NewChild;
  // RunTask('TCommandTask_AcquireMemory', '', nil, TaskProgress, ['output='%CASE_EXPORTED%memory.raw']);
  RunTask('TCommandTask_AcquireMemory', '', nil, TaskProgress, []); // Writes to Case Export folder as 'memory_yyyy_mmm_dd_hhmmss.raw'
  while (TaskProgress.isRunning) and (Progress.isRunning) do
    Sleep(500); // Do not proceed until TCommandTask is complete
  if not(Progress.isRunning) then
    TaskProgress.Cancel;
  Progress.Log('Finished.');

end.
