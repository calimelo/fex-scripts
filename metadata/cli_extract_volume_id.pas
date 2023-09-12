{ !NAME:      Extract_Volume_ID.pas }
{ !DESC:      Extract VBR Volume ID }
{ !AUTHOR:    GetData }

unit Extract_Volume_ID;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, PropertyList, Regex, SysUtils;

const
  RUNNING = '...';
  SCRIPT_NAME = 'Extract VBR Volume ID';
  SPACE = ' ';

var
  aDeterminedFileDriverInfo: TFileTypeInformation;
  anEntry: TEntry;
  aParentNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aReader: TEntryReader;
  aRootProperty: TPropertyNode;
  CurrentCaseDir: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
  EntryList: TDataStore;
  Results_StringList: TStringList;
  Volume_ID: string;

implementation

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(EntryList) then
    Exit;

  Results_StringList := TStringList.Create;
  Progress.Initialize(EntryList.Count, 'Searching for Volume Boot Record' + SPACE + RUNNING);
  anEntry := EntryList.First;
  while assigned(anEntry) and Progress.isRunning do
  begin
    if anEntry.IsSystem and (RegexMatch(anEntry.EntryName, 'Volume Boot Record', False)) then
    begin
      DetermineFileType(anEntry);
      aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
      if (aDeterminedFileDriverInfo.ShortDisplayName = 'Volume Boot Record') or (aDeterminedFileDriverInfo.ShortDisplayName = 'NTFS') then
      begin
        aReader := TEntryReader.Create;
        try
          if aReader.OpenData(anEntry) then
          begin
            aPropertyTree := nil;
            if ProcessDisplayProperties(anEntry, aPropertyTree, aReader) then
            begin
              aRootProperty := aPropertyTree.RootProperty;
              if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
              begin
                aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Volume ID'));
                if assigned(aParentNode) then
                begin
                  Volume_ID := aParentNode.PropDisplayValue;
                  Progress.Log(anEntry.FullPathName + ' (Volume ID:' + Volume_ID + ')');
                  Results_StringList.Add(anEntry.FullPathName + ' (Volume ID:' + Volume_ID + ')');
                end;
              end;
            end;
          end;
        finally
          aReader.free;
        end;
      end;
    end;
    anEntry := EntryList.Next;
    Progress.IncCurrentprogress;
  end;

  // ============================================================================
  // Export results to a file
  // ============================================================================
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Exported\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  ExportDateTime := (ExportDate + '-' + ExportTime);
  if DirectoryExists(ExportedDir) then
  begin
    if assigned(Results_StringList) and (Results_StringList.Count > 0) then
    begin
      Results_StringList.SaveToFile(ExportedDir + ExportDateTime + ' ' + SCRIPT_NAME + '.txt');
      Progress.Log('Results exported to: ' + ExportedDir + ExportDateTime + ' ' + SCRIPT_NAME + '.txt');
    end;
  end;

  EntryList.free;
  Results_StringList.free;
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

end.
