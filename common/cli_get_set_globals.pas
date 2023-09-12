{ !NAME:      GetSetGlobals.pas }
{ !AUTHOR:    GetData }

unit GetSetGlobals;

interface

uses
  Classes, Common, SysUtils;

implementation

var
  newvalue: variant;
  origvalue: variant;

  // ==============================================================================================================================================
  // Start of the Script
  // ==============================================================================================================================================
begin
  origvalue := GetGlobalValue('%EXPORT_NAME%');
  newvalue := 'o:\bretts1.l01';
  SetGlobalValue('%EXPORT_NAME%', newvalue);
 
  Progress.log('Original Value is ' + origvalue);
  Progress.log('Set Value is ' + string(newvalue));
end.
