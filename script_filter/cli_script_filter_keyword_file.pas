unit script_filter;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  RPAD_VALUE = 22;
  RUNNING = '...';
  SCRIPT_NAME = 'Script Filter';
  SPACE = ' ';
  THE_InList = 'InList';
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
// Function: Get Keyword File from params
//------------------------------------------------------------------------------
function get_keyword_file_param : string;
begin
  Result := '';
  Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
  if (CmdLine.ParamCount = 1) then
  begin
    Progress.Log(Stringofchar('-', 80));
    Progress.Log(RPad(' Param ' + IntToStr(0) + ':', RPAD_VALUE) + CmdLine.params[0]);
    Result := CmdLine.params[0];
  end
  else
  begin
    Progress.Log(RPad('Invalid param count:', RPAD_VALUE) + (IntToStr(CmdLine.ParamCount)));
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
    if ListName_str = THE_InList then
      Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

//------------------------------------------------------------------------------
// Function: Test Valid Regex
//------------------------------------------------------------------------------
function IsValidRegEx(aStr : string) : boolean;
var
  aRegEx : TRegEx;
begin
  Result := False;
  aRegEx := TRegEx.Create;
  try
    aRegEx.SearchTerm := aStr;
    Result := aRegEx.LastError = 0;
  finally
    aRegEx.free;
  end;
end;

//------------------------------------------------------------------------------
// Read file, collect keywords, and Regex Escape for searching
//------------------------------------------------------------------------------
Procedure EscapeRegexKeywordsFromFile(KeywordFile_str: string; aKeywords_StringList: TStringList);
var
  i: integer;
  CommentString: string;
  aBigRegex: string;

begin
  if FileExists(KeywordFile_str) then
  begin
    try
      aKeywords_StringList.LoadFromFile(KeywordFile_str);
    except
      Progress.Log('There was an error reading the keyword file: ' + KeywordFile_str);
    end;
    Progress.Log(Rpad('Contains keywords:', RPAD_VALUE) + IntToStr(aKeywords_StringList.Count));

    // Remove blank lines from StringList
    for i := aKeywords_StringList.Count - 1 downto 0 do
    begin
      aKeywords_StringList[i] := TrimRight(aKeywords_StringList[i]);
      if Trim(aKeywords_StringList[i]) = '' then
        aKeywords_StringList.Delete(i);
    end;

    // Remove comment lines from StringList
    for i := aKeywords_StringList.Count - 1 downto 0 do
    begin
      CommentString := copy(aKeywords_StringList(i), 1, 1);
      if CommentString = '#' then
        aKeywords_StringList.Delete(i);
    end;

    // Remove comment lines from StringList
    for i := aKeywords_StringList.Count - 1 downto 0 do
    begin
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '\', '\\', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '*', '\*', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '+', '\+', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '?', '\?', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '|', '\|', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '{', '\{', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '}', '\}', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '[', '\[', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), ']', '\]', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '(', '\(', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), ')', '\)', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '^', '\^', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '.', '\.', [rfReplaceAll]);
      aKeywords_StringList(i) := StringReplace(aKeywords_StringList(i), '!', '\!', [rfReplaceAll]);
    end;

    for i := 0 to aKeywords_StringList.Count - 1 do
    begin
      Progress.Log(RPad('Keyword ' + IntToStr(i) + ':', RPAD_VALUE) + aKeywords_StringList(i));
    end;

  end
  else
  begin
    Progress.Log('Did not find: ' + KeywordFile_str);
  end;

  // Test the regex
  aBigRegex := aKeywords_StringList.DelimitedText;
  if IsValidRegEx(aBigRegex) then
  begin
    Progress.Log(RPad('Regex Validation:', RPAD_VALUE) + 'Passed');
  end
  else
    Progress.Log(RPad('Regex Validation:', RPAD_VALUE) + 'Failed');
end;

//------------------------------------------------------------------------------
// Start of the script
//------------------------------------------------------------------------------
var
  anEntry: TEntry;
  aKeywords_StringList: TStringList;
  i: integer;
  keywords_file_path: string;
  OneBigRegex: string;

begin
  Progress.Log(Stringofchar('-', 80));
  Progress.Log(SCRIPT_NAME + RUNNING);

  // Check that InList and OutList exist and that InList is not empty
  if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    Exit;

  // InList Count
  if InList.Count <= 0 then
  begin
    Progress.Log('InList count is zero.' + SPACE + TSWT);
    Exit;
  end
  else
    Progress.Log('InList Count: ' + IntToStr(InList.Count));
 
  aKeywords_StringList := TStringList.Create;
  aKeywords_StringList.Delimiter := '|';
  aKeywords_StringList.StrictDelimiter := True;
  
  try
  
    // Get Keyword File From Param 0
    keywords_file_path := get_keyword_file_param;
    if not FileExists(keywords_file_path) then
    begin
      Progress.Log(RPad('Could not find file:', RPAD_VALUE) + keywords_file_path);
      Exit;
    end
    else
      Progress.Log(RPad('Found keyword file:', RPAD_VALUE) + keywords_file_path);   
  
    EscapeRegexKeywordsFromFile(keywords_file_path, aKeywords_StringList);    

    OneBigRegex := aKeywords_StringList.DelimitedText;    
    
    Progress.Log(Stringofchar('=', 80));      
    Progress.Log(OneBigRegex);
    Progress.Log(Stringofchar('=', 80));  

    Progress.Initialize(InList.Count, 'Processing...');  
    for i := 0 to InList.Count -1 do
    begin
      if not Progress.isRunning then
        break;
      anEntry := TEntry(InList[i]);

      if (RegexMatch(anEntry.EntryName, OneBigRegex, False)) then
        OutList.add(anEntry);

      Progress.IncCurrentProgress;
    end;
    
  finally
    aKeywords_StringList.free;
    Progress.Log(Stringofchar('-', 80));
    Progress.Log(RPad('OutList on finish:', RPAD_VALUE) + IntToStr(OutList.Count));
    Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
    if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
      ShellExecute(0, nil, 'explorer.exe', pchar(Progress.LogFilename), nil, 1);     
  end;
end.