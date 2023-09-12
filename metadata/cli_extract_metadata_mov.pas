{ !NAME:      Extract Metadata MOV }
{ !DESC:      Extract Metadata to Columns }
{ !AUTHOR:    GetData }

unit cli_extract_metadata_mov;

interface

uses
  Classes, Common, DataEntry, DataStorage, DataStreams, DateUtils, Graphics, Math, PropertyList, SysUtils, Variants;

const
  // ==============================================================================
  // THESE METADATA NODE VALUES ARE TO REMAIN IN ENGLISH - DO NOT TRANSLATE
  // ==============================================================================
  // Set the Metadata Node Names
  ROOT_ENTRY_MOV = 'MOV Data';
  NODEBYNAME_DURATION = 'Duration';
  NODEBYNAME_CREATED = 'Created';
  NODEBYNAME_MODIFIED = 'Modified';
  NODEBYNAME_FIRM = 'FIRM';
  NODEBYNAME_LENS = 'LENS';
  NODEBYNAME_CAME = 'CAME';
  // ==============================================================================

  SCRIPT_NAME = 'MOV metadata columns';
  SCRIPT_AUTHOR = 'GetData';
  CHAR_LENGTH = 80;

var
  // Data Stores
  EntryList: TDatastore;
  // FileSystemEntryList: TDataStore;

  // Module
  // Module: TGDModule;
  // Viewer: TViewerBase;

  // Entries
  anEntry: TEntry;
  anEntryReader: TEntryReader;

  // Properties
  aPropertyNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aRootEntry: TPropertyNode;

  // File Info
  DeterminedFileDriverInfo: TFileTypeInformation;
  FileDriverInfo: TFileTypeInformation;

  // Counters
  FileOpenErrorCount: integer;
  Metadata_Extractions_Count: integer;
  Processed_Using_Existing_Metadata_Count: integer;
  processedcount: integer;

  proceed_with_extraction: boolean;
  rpad_value: integer;

  // Columns
  colNodeDuration: TDataStoreField;
  colNodeCreated: TDataStoreField;
  colNodeModified: TDataStoreField;
  colNodeFIRM: TDataStoreField;
  colNodeLENS: TDataStoreField;
  colNodeCAME: TDataStoreField;

  // Column Var
  NodeDuration: string;
  NodeCreated: string;
  NodeModified: string;
  NodeFIRM: string; // GoPro
  NodeLENS: string; // GoPro
  NodeCAME: string; // GoPro

  // Starting Checks
  bContinue: boolean;
  CaseName: string;
  StartCheckDataStore: TDatastore;
  StartCheckEntry: TEntry;

implementation

// Right Pad Console Logs ------------------------------------------------------
function RPad(AString: string; AChars: integer): string;
begin
  while length(AString) < AChars do
    AString := AString + ' ';
  Result := AString;
end;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

// ==============================================================================
// START OF SCRIPT
// ==============================================================================
begin
  Progress.Log(SCRIPT_NAME + ' started.');
  Progress.Log(Stringofchar('-', CHAR_LENGTH));

  // ===========================================================================
  // Starting Checks
  // ===========================================================================
  // Check to see if the FileSystem module is present
  bContinue := True;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      Progress.Log(DATASTORE_FILESYSTEM + ' module not located. The script will terminate.');
      bContinue := False;
      Exit;
    end;

    // Check to see if a case is present
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      Progress.Log('There is no current case. The script will terminate.');
      bContinue := False;
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;

    // Log case details
    rpad_value := 30;
    Progress.Log(Stringofchar('~', CHAR_LENGTH));
    Progress.Log(RPad('Case Name:', rpad_value) + CaseName);
    Progress.Log(RPad('Script Name:', rpad_value) + SCRIPT_NAME);
    Progress.Log(RPad('Date Run:', rpad_value) + DateTimeToStr(now));
    Progress.Log(RPad('FEX Version:', rpad_value) + CurrentVersion);
    Progress.Log(Stringofchar('~', CHAR_LENGTH));

    // Check to see if there are files in the File System Module
    if StartCheckDataStore.Count <= 1 then
    begin
      Progress.Log('There are no files in the File System module. The script will terminate.');
      bContinue := False;
      Exit;
    end;

    // Exit if user cancels
    if not Progress.isRunning then
    begin
      Progress.Log('Canceled by user.');
      bContinue := False;
    end;
  finally
    StartCheckDataStore.free;
  end;

  // Continue?
  if Not bContinue then
    Exit;
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  // Initialize variables ------------------------------------------------------
  FileOpenErrorCount := 0;
  rpad_value := 50;

  // Create columns ------------------------------------------------------------
  colNodeDuration := AddMetaDataField('MOV Duration', ftString);
  colNodeCreated := AddMetaDataField('MOV Created', ftString);
  colNodeModified := AddMetaDataField('MOV Modified', ftString);
  colNodeFIRM := AddMetaDataField('MOV Firmware', ftString);
  colNodeLENS := AddMetaDataField('MOV Lens', ftString);
  colNodeCAME := AddMetaDataField('MOV Camera', ftString);

  // // Show Columns --------------------------------------------------------------
  // Module := ModuleManager.ModuleByName(MODULENAME_FILESYSTEM);
  // if Module <> nil then
  // begin
  // Viewer := Module.ViewerByName('vwFSTable');
  // if (Viewer <> nil) and (Viewer is TColumnViewer) then
  // begin
  // TColumnViewer(Viewer).ShowColumn(colNodeCame, 3);
  // TColumnViewer(Viewer).ShowColumn(colNodeLens, 4);
  // TColumnViewer(Viewer).ShowColumn(colNodeFirm, 5);
  // TColumnViewer(Viewer).ShowColumn(colNodeCreated, 6);
  // TColumnViewer(Viewer).ShowColumn(colNodeModified, 7);
  // TColumnViewer(Viewer).ShowColumn(colNodeDuration, 8);
  // Progress.Log('Columns added to module.');
  // end;
  // end;

  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  anEntry := EntryList.First;
  try
    Progress.Max := EntryList.Count;
    Progress.CurrentPosition := 1;
    anEntryReader := TEntryReader.Create;
    proceed_with_extraction := True;
    Metadata_Extractions_Count := 0;
    Processed_Using_Existing_Metadata_Count := 0;
    processedcount := 0;

    while assigned(anEntry) and (Progress.isRunning) do
    begin

      // Clear these values on each loop *************************************
      NodeDuration := '';
      NodeCreated := '';
      NodeModified := '';

      begin
        FileDriverInfo := anEntry.FileDriverInfo;
        // ==================================================================================================
        if (dtVideo in FileDriverInfo.DriverType) then
        // ==================================================================================================
        begin
          DetermineFileType(anEntry);
          DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
          FileDriverInfo := anEntry.FileDriverInfo;
          // Progress.Log(RPad('Determined Short Display Name:', rpad_value) + DeterminedFileDriverInfo.ShortDisplayName);
          // Progress.Log(RPad('Determined Extensions:', rpad_value) + DeterminedFileDriverInfo.Extensions);
          // Progress.Log(RPad('Extension:', rpad_value) + extractfileext(anEntry.EntryName));
          if (UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = 'MOV') or (UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = 'MP4') then
          begin
            Progress.Log('Processing: ' + anEntry.EntryName);
            proceed_with_extraction := True;
            processedcount := processedcount + 1;

            // Test to see if the existing columns have data
            if not(colNodeDuration.isNull(anEntry)) and not(colNodeCreated.isNull(anEntry)) and not(colNodeModified.isNull(anEntry)) and not(colNodeFIRM.isNull(anEntry)) and not(colNodeLENS.isNull(anEntry)) and
              not(colNodeCAME.isNull(anEntry)) then
            begin
              Processed_Using_Existing_Metadata_Count := (Processed_Using_Existing_Metadata_Count + 1);
              proceed_with_extraction := False; // No need to extract data again
            end;

            // ==============================================================================
            // METADATA EXTRACTION PROCESS STARTS
            // ==============================================================================
            try
              if proceed_with_extraction then
              begin
                if ProcessMetadataProperties(anEntry, aPropertyTree, anEntryReader) then
                begin
                  if assigned(aPropertyTree) then
                  begin
                    Metadata_Extractions_Count := (Metadata_Extractions_Count + 1);

                    // Get the Root Node and check that it has children
                    aRootEntry := aPropertyTree.RootProperty;
                    if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
                    begin

                      // Node Duration -----------------------------------------
                      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_DURATION));
                      if assigned(aPropertyNode) then
                      begin
                        NodeDuration := '';
                        NodeDuration := trim(aPropertyNode.PropValue);
                        if NodeDuration <> '' then
                        begin
                          colNodeDuration.AsString[anEntry] := NodeDuration;
                        end;
                      end;

                      // Node Created ------------------------------------------
                      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_CREATED));
                      if assigned(aPropertyNode) then
                      begin
                        NodeCreated := '';
                        NodeCreated := trim(aPropertyNode.PropValue);
                        if NodeCreated <> '' then
                        begin
                          colNodeCreated.AsString[anEntry] := NodeCreated;
                        end;
                      end;

                      // Node Modified -----------------------------------------
                      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_MODIFIED));
                      if assigned(aPropertyNode) then
                      begin
                        NodeModified := '';
                        NodeModified := trim(aPropertyNode.PropValue);
                        if NodeModified <> '' then
                        begin
                          colNodeModified.AsString[anEntry] := NodeModified;
                        end;
                      end;

                      // Node FIRM ---------------------------------------------
                      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_FIRM));
                      if assigned(aPropertyNode) then
                      begin
                        NodeFIRM := '';
                        NodeFIRM := trim(aPropertyNode.PropValue);
                        if NodeFIRM <> '' then
                        begin
                          colNodeFIRM.AsString[anEntry] := NodeFIRM;
                        end;
                      end;

                      // Node LENS ---------------------------------------------
                      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LENS));
                      if assigned(aPropertyNode) then
                      begin
                        NodeLENS := '';
                        NodeLENS := trim(aPropertyNode.PropValue);
                        if NodeLENS <> '' then
                        begin
                          colNodeLENS.AsString[anEntry] := NodeLENS;
                        end;
                      end;

                      // Node CAME ---------------------------------------------
                      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_CAME));
                      if assigned(aPropertyNode) then
                      begin
                        NodeCAME := '';
                        NodeCAME := trim(aPropertyNode.PropValue);
                        if NodeCAME <> '' then
                        begin
                          colNodeCAME.AsString[anEntry] := NodeCAME;
                        end;
                      end;

                    end
                    else
                      FileOpenErrorCount := FileOpenErrorCount + 1;
                  end;
                end
                else
                  FileOpenErrorCount := FileOpenErrorCount + 1;
              end;

            finally
              if assigned(aPropertyTree) then
              begin
                aPropertyTree.free;
                aPropertyTree := nil;
              end;
            end;
          end;
        end;
      end;
      Progress.IncCurrentProgress;
      anEntry := EntryList.Next;
    end;
    Progress.Log(Stringofchar('-', CHAR_LENGTH));
    Progress.Log(RPad('Files processed:', rpad_value) + IntToStr(processedcount));
    Progress.Log(RPad('Processed using existing metadata:', rpad_value) + IntToStr(Processed_Using_Existing_Metadata_Count));
    Progress.Log(RPad('Processed by extracting metadata:', rpad_value) + IntToStr(Metadata_Extractions_Count));
    if FileOpenErrorCount <> 0 then
      Progress.Log(RPad('File open error count:', rpad_value) + IntToStr(FileOpenErrorCount));
    Progress.Log(Stringofchar('-', CHAR_LENGTH));

  finally
    EntryList.free;
    anEntryReader.free;
  end;
  Progress.Log(SCRIPT_NAME + ' script finished.');
  Progress.DisplayMessageNow := 'Processing complete';

end.
