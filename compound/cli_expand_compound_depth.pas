unit Expand_Sub_Archives;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

implementation

// ------------------------------------------------------------------------------
// Function: Right Pad v2
// ------------------------------------------------------------------------------
function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

// ============================================================================
// Start of the Script
// ============================================================================
const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  ARCHIVE_SUBFOLDER_DEPTH = 10;
  EXCLUDE_ARCHIVE_REGEX_STR = '(accdt|apk|bau|bbfw|cab|dat|deskthemepack|eftx|glox|gz|ipa|ipsw|jar|msu|mzz|odb|odg|odp|onepkg|otp|ots|ott|oxt|rbf|rdb|skin|sob|stw|thmx|thmx|ui|wmz|xpi|xsn|wmf)';
  RPAD_VALUE = 35;
  SCRIPT_NAME = 'SCRIPT - Expand Sub-Archives';

var
  DataStore_FS_SUB: TDataStore;
  i: integer;
  TaskProgress_ExpandSub: TPAC;
  temp_expand_TList: TList;
  xEntry: TEntry;

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  if ARCHIVE_SUBFOLDER_DEPTH > 0 then
  begin
    for i := 1 to ARCHIVE_SUBFOLDER_DEPTH do
    begin
      DataStore_FS_SUB := GetDataStore(DATASTORE_FILESYSTEM);
      if assigned(DataStore_FS_SUB) and (DataStore_FS_SUB.Count > 0) then
        try
          xEntry := DataStore_FS_SUB.First;
          while assigned(xEntry) and (Progress.isRunning) do
          begin
            if xEntry.inExpanded then
            begin
              if (dtArchive in xEntry.FileDriverInfo.DriverType) and not(xEntry.isExpanded) then
              begin
                if not RegexMatch(xEntry.Extension, EXCLUDE_ARCHIVE_REGEX_STR, False) then
                begin
                  DetermineFileType(xEntry);
                  if (dtArchive in xEntry.FileDriverInfo.DriverType) then
                  begin
                    temp_expand_TList := TList.Create;
                    try
                      TaskProgress_ExpandSub := Progress.NewChild;
                      TaskProgress_ExpandSub.Visible := False;
                      temp_expand_TList.Add(xEntry);
                      try
                        ExpandCompoundFiles(temp_expand_TList, DATASTORE_FILESYSTEM, TaskProgress_ExpandSub);
                        Progress.Log('Expanding sub-archive: ' + xEntry.EntryName);
                      except
                        Progress.Log(ATRY_EXCEPT_STR + 'Error: ExpandCompoundFiles');
                      end;
                    finally
                      temp_expand_TList.free;
                    end;
                  end;
                end;
              end;
            end;
            xEntry := DataStore_FS_SUB.next;
          end;
        finally
          FreeAndNil(DataStore_FS_SUB);
        end;
    end;
  end;
  Progress.DisplayTitle := SCRIPT_NAME;

end.
