unit cli_set_global_export_name;

interface

uses
  Classes, Common, SysUtils;

const
  RPAD_VALUE = 35;
  RUNNING = '...';
  
implementation

// =============================================================================
// function: Right Pad
// =============================================================================
function RPad(AString: string; AChars: integer): string;
begin
  if AChars > length(AString) then
    Result := AString + StringofChar(' ', AChars - length(AString))
  else
    Result := AString;
end;

// =============================================================================
// function: Get Unique Filename
// =============================================================================
function GetUniqueFileName(AFileName: string): string;
var
  fnum: integer;
  fname: string;
  fpath: string;
  fext: string;
begin
  Result := AFileName;
  if FileExists(AFileName) then
  begin
    fext := ExtractFileExt(AFileName);
    fnum := 1;
    fname := ExtractFileName(AFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(AFileName);
    while FileExists(fpath + fname + '_' + IntToStr(fnum) + fext) do
    begin
      fnum := fnum + 1;
    end;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
  end;
end;


// =============================================================================
// The start of the script
// =============================================================================
var
  origvalue_var: variant;
  newvalue_var: variant;

begin
  Progress.Log('Script started' + RUNNING);
  
  // Set the global value
  SetGlobalValue('%EXPORT_NAME%', 'I set this to be the name.l01');
  
  // Get the global original value as a variant
  origvalue_var := GetGlobalValue('%EXPORT_NAME%');
  
  // Test to make sure the original value is not blank
  if (trim(origvalue_var) = '') or (trim(origvalue_var) = '0') then
    origvalue_var := 'test.l01';
  
  // Set the new value as a variant
  newvalue_var := GetUniqueFileName(origvalue_var);
  
  // Update the global value
  SetGlobalValue('%EXPORT_NAME%', newvalue_var);
  
  // Log the result
  Progress.log(RPad('%EXPORT_NAME% Original:', RPAD_VALUE) + origvalue_var);
  Progress.log(RPad('%EXPORT_NAME% New:', RPAD_VALUE) + string(newvalue_var));
  
  Progress.Log('Script finished.');
end.