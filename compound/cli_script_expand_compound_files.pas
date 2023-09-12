unit Expand_Compound_Files;

{ One or more parameters, separated by spaces, can be use:
  COMMON_ARCHIVES (RAR, ZIP, 7ZIP)
  ALL (Open Office, MS Office, MS Office XML, RAR, TAR, Thumbs, Video, Zip, 7Zip)
  GZIP
  MAC
  OFFICE
  OFFICEXML
  OPENOFFICE
  PDF
  RAR
  TAR
  THUMBS
  VIDEO
  ZIP
  7ZIP
  ZIPOTHER ('accdt, apk, bau, bbfw, dat, eftx, glox, ipa, ipsw, jar, odb, odg, odp,
  otp, ots, ott, oxt, rbf, skin, sob, stw, thmx, thmx, ui, wmz, xpi, wmf.) }

interface

uses
  Classes, Common, DataEntry, DataStorage, DataStreams, Graphics, Math,
  PropertyList, Regex, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  CHAR_LENGTH = 80;
  DCR = #13#10 + #13#10;
  HYPHEN = ' - ';
  MAIN_FORM_AUTHOR = 'GetData';
  MAIN_FORM_DESCRIPTION = 'This script expands compound files.';
  RPAD_VALUE: integer = 30;
  RPAD_VALUE2: integer = 40;
  RUNNING = '...';
  SCRIPT_NAME = 'SCRIPT - Expand Compound Files';
  SPACE = ' ';
  STARTUP_TAB = 1;
  TSWT = 'The script will terminate.';

var
  gCaseName: string;
  gchbGZIP: boolean;
  gchbMAC: boolean;
  gchbOFFICE: boolean;
  gchbOFFICEXML: boolean;
  gchbOPENOFFICE: boolean;
  gchbPDF: boolean;
  gchbRAR: boolean;
  gchbTAR: boolean;
  gchbTMB: boolean;
  gchbVID: boolean;
  gchbZIP: boolean;
  gchbZIPOTHER: boolean;
  gchbZIP7: boolean;
  gchbSignatureAnalysis: boolean;
  gDeviceName_str: string;
  gNumberEntries: integer;
  gStart_Check_Header: string;

implementation

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

procedure MessageUser(AString: string);
begin
  Progress.Log(AString);
end;

procedure RunSig(SigThis_TList: TList);
var
  TaskProgress: TPAC;
  bl_Continue: boolean;
begin
  if not Progress.isRunning then
    Exit;
  if not assigned(SigThis_TList) then
  begin
    Progress.Log('Not assigned SigThis_TList.' + SPACE + TSWT);
    bl_Continue := False;
    Exit;
  end;
  if assigned(SigThis_TList) and (SigThis_TList.Count > 0) then
  begin
    // Progress.CurrentPosition := Progress.Max;
    Progress.DisplayMessageNow := ('Launching Signature Analysis' + SPACE + '(' + IntToStr(SigThis_TList.Count) + ' files)' + RUNNING);
    Progress.Log(RPad('Launching Signature Analysis' + RUNNING, RPAD_VALUE2) + IntToStr(SigThis_TList.Count));
    if Progress.isRunning then
    begin
      TaskProgress := NewProgress(False);
      RunTask('TCommandTask_FileTypeAnalysis', DATASTORE_FILESYSTEM, SigThis_TList, TaskProgress);
      while (TaskProgress.isRunning) and (Progress.isRunning) do
        Sleep(500); // Do not proceed until TCommandTask_FileTypeAnalysis is complete
      if not(Progress.isRunning) then
        TaskProgress.Cancel;
      bl_Continue := (TaskProgress.CompleteState = pcsSuccess);
    end;
  end;
end;

procedure DoTickCount;
begin
  Progress.Log('TC = ' + IntToStr(GetTickCount64));
end;

procedure SigChildren(aTList: TList);
var
  aEntry: TEntry;
  aSignature_TList: TList;
  cEntry: TEntry;
  Children_TList: TList;
  DataStore_FS: TDataStore;
  i, j: integer;
begin
  if (gchbSignatureAnalysis) and Progress.isRunning then
  begin
    Progress.Log(StringOfChar('-', 80));
    aSignature_TList := TList.Create;
    try
      DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
      if assigned(DataStore_FS) and (DataStore_FS.Count > 0) then
        try
          Progress.CurrentPosition := 0;
          Progress.Max := aTList.Count;
          Progress.Log('Collecting children of expanded files' + RUNNING);
          for i := 0 to aTList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            Progress.DisplayMessages := 'Collecting children' + (' (' + IntToStr(i + 1) + ' of ' + IntToStr(aTList.Count) + ')');
            aEntry := TEntry(aTList[i]);
            Children_TList := TList.Create;
            try
              Children_TList := DataStore_FS.Children(aEntry, True); // True is recursive for all child files from the parent
              if assigned(Children_TList) and (Children_TList.Count > 0) then
              begin
                for j := 0 to Children_TList.Count - 1 do
                begin
                  cEntry := TEntry(Children_TList[j]);
                  aSignature_TList.Add(cEntry);
                end;
              end;
            finally
              Children_TList.free;
            end;
            Progress.IncCurrentProgress;
          end;
        finally
          DataStore_FS.free;
        end;
      if assigned(aSignature_TList) and (aSignature_TList.Count > 0) then
      begin
        RunSig(aSignature_TList);
      end;
    finally
      aSignature_TList.free;
    end;
  end;
end;

// ==============================================================================
// This is the main procedure called after the 'Run' button is clicked
// ==============================================================================
procedure MainProc;
const
  FORMAT_STR = '%-8s %-30s';
var
  ExpandProgress: TPAC;
  anEntry: TEntry;
  DataStore_FS: TDataStore;
  CompoundFiles_TList: TList;
  aMACFSEvents_List: TList;
  count_gzip: integer;
  count_macfsevents: integer;
  count_office: integer;
  count_officexml: integer;
  count_pdf: integer;
  count_rar: integer;
  count_tar: integer;
  count_tmb: integer;
  count_vid: integer;
  count_zip: integer;
  count_zip_other: integer;
  count_zip7: integer;
  DeviceEntry: TEntry;
  FileDriver: TFileDriverClass;
  i: integer;
  processedcount: integer;
  running_count: integer;
begin
  // Check to see if the FileSystem module is present
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if DataStore_FS = nil then
  begin
    MessageUser('No datastore found.' + SPACE + TSWT);
    Exit;
  end;

  try
    CompoundFiles_TList := TList.Create;
    aMACFSEvents_List := TList.Create;
    try
      // Check to see if there are files in the FileSystem module
      anEntry := DataStore_FS.First;
      gNumberEntries := DataStore_FS.Count;
      if anEntry = nil then
      begin
        MessageUser('There are no files in the File System module.');
        Exit;
      end;

      if not Progress.isRunning then
      begin
        Progress.Log('Progress is not running.' + SPACE + TSWT);
        Exit;
      end;

      if gNumberEntries = 0 then
      begin
        MessageUser('There are no items to process.');
        Exit;
      end;

      Progress.Initialize(trunc(gNumberEntries * 1.1), 'Expanding compound files' + RUNNING);

      Progress.Log(StringOfChar('=', CHAR_LENGTH));
      Progress.Log('Source:');
      Progress.Log(RPad('All File System items:', RPAD_VALUE2) + 'True');

      if gchbGZIP then
        Progress.Log(RPad('Expand GZIP files:', RPAD_VALUE2) + BoolToStr(gchbGZIP, True));
      if gchbOFFICEXML then
        Progress.Log(RPad('Expand Office XML files:', RPAD_VALUE2) + BoolToStr(gchbOFFICEXML, True));
      if gchbOPENOFFICE then
        Progress.Log(RPad('Expand Open Office:', RPAD_VALUE2) + BoolToStr(gchbOPENOFFICE, True));
      if gchbMAC then
        Progress.Log(RPad('Expand MACFSEvents files:', RPAD_VALUE2) + BoolToStr(gchbMAC, True));
      if gchbOFFICE then
        Progress.Log(RPad('Expand OLE files:', RPAD_VALUE2) + BoolToStr(gchbOFFICE, True));
      if gchbPDF then
        Progress.Log(RPad('Expand PDF files:', RPAD_VALUE2) + BoolToStr(gchbPDF, True));
      if gchbRAR then
        Progress.Log(RPad('Expand RAR files:', RPAD_VALUE2) + BoolToStr(gchbRAR, True));
      if gchbTAR then
        Progress.Log(RPad('Expand TAR files:', RPAD_VALUE2) + BoolToStr(gchbTAR, True));
      if gchbTMB then
        Progress.Log(RPad('Expand Thumbs files:', RPAD_VALUE2) + BoolToStr(gchbTMB, True));
      if gchbVID then
        Progress.Log(RPad('Expand Video files:', RPAD_VALUE2) + BoolToStr(gchbTMB, True));
      if gchbZIP then
        Progress.Log(RPad('Expand ZIP files:', RPAD_VALUE2) + BoolToStr(gchbZIP, True));
      if gchbZIPOTHER then
        Progress.Log(RPad('Expand ZIP (Other) files:', RPAD_VALUE2) + BoolToStr(gchbZIPOTHER, True));
      if gchbZIP7 then
        Progress.Log(RPad('Expand 7Zip files:', RPAD_VALUE2) + BoolToStr(gchbZIP7, True));

      Progress.Log(RPad('Children Signature Analysis:', RPAD_VALUE2) + BoolToStr(gchbSignatureAnalysis, True));

      Progress.Log(StringOfChar('-', CHAR_LENGTH));

      // ==========================================================================
      // Create a List of Compound Files
      // ==========================================================================
      Progress.DisplayMessageNow := 'Searching for compound files' + RUNNING;
      Progress.Log('Searching for compound files' + RUNNING);
      try
        count_gzip := 0;
        count_macfsevents := 0;
        count_office := 0;
        count_officexml := 0;
        count_pdf := 0;
        count_rar := 0;
        count_tar := 0;
        count_tmb := 0;
        count_vid := 0;
        count_zip := 0;
        count_zip_other := 0;
        count_zip7 := 0;
        i := 0;
        processedcount := 0;
        running_count := 0;

        // Find compound files best guess
        while assigned(anEntry) and (Progress.isRunning) do
        begin
          begin
            FileDriver := anEntry.BestFileDriver;
            if fddtCompound in FileDriver.Details.DataInfoType then
            begin
              // Limit to compound files by determined signature
              CompoundFiles_TList.Add(anEntry);
            end;
          end;

          Progress.IncCurrentProgress;
          anEntry := DataStore_FS.Next;
        end;

        // Signature Analysis of Compound Files
        Progress.DisplayMessageNow := 'Signature Analysis of compound files' + RUNNING;
        Progress.Start;
        DetermineFileTypeList(CompoundFiles_TList, [], Progress);
        CompoundFiles_TList.Clear;

        // Loop Compound Files
        Progress.CurrentPosition := 0;
        anEntry := DataStore_FS.First;
        while assigned(anEntry) and (Progress.isRunning) do
        begin
          begin
            FileDriver := anEntry.BestFileDriver;

            // Limit to compound files by determined signature
            if (gDeviceName_str <> '') then
            begin
              DeviceEntry := GetDeviceEntry(anEntry);
              if assigned(DeviceEntry) and (DeviceEntry.isDevice) and (DeviceEntry.EntryName <> gDeviceName_str) then
              begin
                anEntry := DataStore_FS.Next;
                Continue;
              end;
            end;

            if fddtCompound in FileDriver.Details.DataInfoType then
            begin
              // Add 7Zip
              if gchbZIP7 and (FileDriver.ShortDisplayName = '7zip') then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_zip7);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add GZip
              if gchbGZIP and (FileDriver.ShortDisplayName = 'GZIP') then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_gzip);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add MAC FSEvents to the list
              if gchbMAC and (anEntry.LogicalSize > 0) and assigned(anEntry.Parent) and (anEntry.Parent.EntryName = '.fseventsd') then // noslz
              begin
                if (Length(anEntry.EntryName) = 16) and (FileDriver.ShortDisplayName = 'GZIP') then
                begin
                  aMACFSEvents_List.Add(anEntry);
                  inc(running_count);
                  inc(count_macfsevents);
                  Progress.DisplayMessages := 'Searching for compound files (found: ' + IntToStr(running_count) + ')' + RUNNING;
                end;
              end;

              // Add OFFICE
              if gchbOFFICE and ((FileDriver.ShortDisplayName = 'Word') or (FileDriver.ShortDisplayName = 'Excel') or (FileDriver.ShortDisplayName = 'PowerPoint')) then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_office);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add OFFICEXML
              if gchbOFFICEXML and ((FileDriver.ShortDisplayName = 'DocX') or (FileDriver.ShortDisplayName = 'XLSX') or (FileDriver.ShortDisplayName = 'PPTX')) then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_officexml);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add Open Office (.ODT)
              if gchbOPENOFFICE and (FileDriver.ShortDisplayName = 'Odt') then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_tmb);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add PDF
              if gchbPDF and (FileDriver.ShortDisplayName = 'PDF') then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_pdf);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add RAR
              if gchbRAR and (FileDriver.ShortDisplayName = 'Rar') then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_rar);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add TAR
              if gchbTAR and (FileDriver.ShortDisplayName = 'TAR') then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_tar);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add Thumbs
              if gchbTMB and ((FileDriver.ShortDisplayName = 'Thumbnail') or (FileDriver.ShortDisplayName = 'ThumbCache')) then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_tmb);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add ZIP - All Zip signatures other than the ones with the list of extensions
              if (gchbZIP) and ((FileDriver.ShortDisplayName = 'Zip') or (FileDriver.ShortDisplayName = 'Zip (Encrypted)')) // noslz
                and not RegexMatch(anEntry.EntryNameExt, 'accdt|apk|bau|bbfw|dat|eftx|glox|ipa|ipsw|jar|odb|odg|odp|otp|ots|ott|oxt|rbf|skin|sob|stw|thmx|thmx|ui|wmz|xpi|wmf', False) then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_zip);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Add ZIP Other - Only the list of extensions with Zip signatures
              if (gchbZIPOTHER) and ((FileDriver.ShortDisplayName = 'Zip') or (FileDriver.ShortDisplayName = 'Zip (Encrypted)')) // noslz
                and RegexMatch(anEntry.EntryNameExt, 'accdt|apk|bau|dat|eftx|glox|ipa|ipsw|jar|odb|odg|odp|otp|ots|ott|oxt|rbf|skin|sob|stw|thmx|thmx|ui|wmz|xpi|wmf', False) then // noslz
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_zip_other);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              // Video
              if gchbVID and (dtVideo in FileDriver.DriverTypes) then
              begin
                CompoundFiles_TList.Add(anEntry);
                inc(running_count);
                inc(count_vid);
                Progress.Log(format(FORMAT_STR, [HYPHEN + UpperCase(FileDriver.ShortDisplayName), anEntry.FullPathName]));
              end;

              Progress.DisplayMessages := 'Searching for compound files (found: ' + IntToStr(running_count) + ')' + RUNNING;
            end;
          end;

          Progress.IncCurrentProgress;
          anEntry := DataStore_FS.Next;
        end;
      finally
        Progress.Log(RPad('Compound files found:', RPAD_VALUE2) + IntToStr(CompoundFiles_TList.Count));
      end;

      // ------------------------------------------------------------------------
      // Expand the files
      // ------------------------------------------------------------------------
      if Progress.isRunning and (CompoundFiles_TList.Count > 0) then
        try
          Progress.Log(StringOfChar('-', 80));
          Progress.DisplayMessageNow := 'Expanding ' + (IntToStr(CompoundFiles_TList.Count)) + ' files' + RUNNING;
          Progress.Log(RPad('Attempting to expand:', RPAD_VALUE2) + (IntToStr(CompoundFiles_TList.Count)));

          ExpandProgress := TPAC.Create;
          try
            ExpandProgress.Start;
            if assigned(CompoundFiles_TList) and (CompoundFiles_TList.Count > 0) then
              ExpandCompoundFiles(CompoundFiles_TList, DATASTORE_FILESYSTEM, ExpandProgress);
            if assigned(aMACFSEvents_List) and (aMACFSEvents_List.Count > 0) then
              ExpandCompoundFiles(aMACFSEvents_List, DATASTORE_FILESYSTEM, ExpandProgress);
          finally
            ExpandProgress.free;
          end;

        except
          Progress.Log(ATRY_EXCEPT_STR + 'A problem occurred in Expanding Files');
        end;

      // Signature Analysis of Children
      Progress.Start;
      if gchbSignatureAnalysis then
      begin
        if assigned(CompoundFiles_TList) and (CompoundFiles_TList.Count > 0) then
          SigChildren(CompoundFiles_TList);
        if assigned(aMACFSEvents_List) and (aMACFSEvents_List.Count > 0) then
          SigChildren(aMACFSEvents_List);
      end;

    finally
      CompoundFiles_TList.free;
      aMACFSEvents_List.free;
    end;
  finally
    DataStore_FS.free; // Must free here because we have just added to the DataStore
  end;

  Progress.Max;

  // ----------------------------------------------------------------------------
  // Logging
  // ----------------------------------------------------------------------------
  if Progress.isRunning and (CompoundFiles_TList.Count > 0) then
  begin
    Progress.Log('Tried to expand:');
    if gchbGZIP then
      Progress.Log(RPad('GZIP:', RPAD_VALUE2) + IntToStr(count_gzip));
    if gchbMAC then
      Progress.Log(RPad('MACFSEvents:', RPAD_VALUE2) + IntToStr(count_macfsevents));
    if gchbOFFICEXML then
      Progress.Log(RPad('Office XML files:', RPAD_VALUE2) + IntToStr(count_officexml));
    if gchbOFFICE then
      Progress.Log(RPad('Office:', RPAD_VALUE2) + IntToStr(count_office));
    if gchbPDF then
      Progress.Log(RPad('PDF:', RPAD_VALUE2) + IntToStr(count_pdf));
    if gchbRAR then
      Progress.Log(RPad('RAR:', RPAD_VALUE2) + IntToStr(count_rar));
    if gchbTAR then
      Progress.Log(RPad('TAR:', RPAD_VALUE2) + IntToStr(count_tar));
    if gchbTMB then
      Progress.Log(RPad('Thumbs:', RPAD_VALUE2) + IntToStr(count_tmb));
    if gchbVID then
      Progress.Log(RPad('Video:', RPAD_VALUE2) + IntToStr(count_vid));
    if gchbZIP then
      Progress.Log(RPad('ZIP:', RPAD_VALUE2) + IntToStr(count_zip));
    if gchbZIPOTHER then
      Progress.Log(RPad('ZIP Other:', RPAD_VALUE2) + IntToStr(count_zip_other));
    if gchbZIP7 then
      Progress.Log(RPad('7ZIP:', RPAD_VALUE2) + IntToStr(count_zip7));
    Progress.Log(RPad('Total:', RPAD_VALUE2) + (IntToStr(running_count)));
  end;
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
var
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
  Starting_StringList: TStringList;
  procedure StartingSummary(AString: string);
  begin
    if assigned(Starting_StringList) then
      Starting_StringList.Add(AString);
    Progress.Log(AString);
  end;

begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  Starting_StringList := TStringList.Create;
  try
    // Check that the Module has Entries
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      MessageUser('There is no current case.' + SPACE + TSWT);
      Exit;
    end
    else
      gCaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      MessageUser('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;
    Result := True;
    gStart_Check_Header := Starting_StringList.text;
  finally
    StartCheckDataStore.free;
    Starting_StringList.free;
  end;
end;

// ==============================================================================
// Start of Script
// ==============================================================================
const
  DEVICE_NAME_STR = 'DEVICENAME=';

var
  i: integer;

begin
  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := (SCRIPT_NAME + ' finished.');
    Exit;
  end;

  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessageNow := 'Starting' + RUNNING;
  Progress.Log('Expand compound files started');
  Progress.DisplayTitle := 'Expand Compound Files';
  Progress.DisplayMessage := 'Starting' + RUNNING;

  // Initialize
  gchbGZIP := False;
  gchbMAC := False;
  gchbOFFICE := False;
  gchbOFFICEXML := False;
  gchbOPENOFFICE := False;
  gchbPDF := False;
  gchbRAR := False;
  gchbTAR := False;
  gchbTMB := False;
  gchbVID := False;
  gchbZIP := False;
  gchbZIPOTHER := False;
  gchbZIP7 := False;
  gchbSignatureAnalysis := True;
  gDeviceName_str := '';

  Progress.Log(RPad('Parameters Received:', RPAD_VALUE2) + IntToStr(CmdLine.ParamCount));
  if CmdLine.ParamCount > 0 then
  begin
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(HYPHEN + IntToStr(i) + '.' + SPACE + CmdLine.params[i]);
      if RegexMatch(CmdLine.params[i], DEVICE_NAME_STR, True) then
        gDeviceName_str := trim(StringReplace(CmdLine.params[i], DEVICE_NAME_STR, '', [rfReplaceAll]));
    end;
  end;
  Progress.Log(StringOfChar('-', CHAR_LENGTH));

  if CmdLine.ParamCount > 0 then
  begin
    if CmdLine.params.Indexof('COMMON_ARCHIVES') >= 0 then // noslz
    begin
      gchbRAR := True;
      gchbZIP := True;
      gchbZIP7 := True;
    end;

    if CmdLine.params.Indexof('ALL') >= 0 then // noslz
    begin
      gchbOPENOFFICE := True;
      gchbOFFICE := True;
      gchbOFFICEXML := True;
      gchbPDF := True;
      gchbRAR := True;
      gchbTAR := True;
      gchbTMB := True;
      gchbVID := True;
      gchbZIP := True;
      gchbZIP7 := True;
    end;

    if CmdLine.params.Indexof('GZIP') >= 0 then
      gchbGZIP := True; // noslz
    if CmdLine.params.Indexof('MAC') >= 0 then
      gchbMAC := True; // noslz
    if CmdLine.params.Indexof('OFFICE') >= 0 then
      gchbOFFICE := True; // noslz
    if CmdLine.params.Indexof('OFFICEXML') >= 0 then
      gchbOFFICEXML := True; // noslz
    if CmdLine.params.Indexof('OPENOFFICE') >= 0 then
      gchbOPENOFFICE := True; // noslz
    if CmdLine.params.Indexof('PDF') >= 0 then
      gchbPDF := True; // noslz
    if CmdLine.params.Indexof('RAR') >= 0 then
      gchbRAR := True; // noslz
    if CmdLine.params.Indexof('TAR') >= 0 then
      gchbTAR := True; // noslz
    if CmdLine.params.Indexof('THUMBS') >= 0 then
      gchbTMB := True; // noslz
    if CmdLine.params.Indexof('VIDEO') >= 0 then
      gchbVID := True; // noslz
    if CmdLine.params.Indexof('ZIP') >= 0 then
      gchbZIP := True; // noslz
    if CmdLine.params.Indexof('7ZIP') >= 0 then
      gchbZIP7 := True; // noslz
    if CmdLine.params.Indexof('ZIPOTHER') >= 0 then
      gchbZIPOTHER := True; // noslz

    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      if not RegexMatch(CmdLine.params[i], '^(GZIP|MAC|OFFICE|OFFICEXML|OPENOFFICE|PDF|RAR|TAR|THUMBS|VIDEO|ZIP|7ZIP|ZIPOTHER)$', True) then
        MessageUser(RPad('Warning: Unknown param received:', RPAD_VALUE2) + CmdLine.params[i]);
    end;

  end
  else
  begin
    MessageUser('No parameter received.' + SPACE + TSWT);
    Exit;
  end;

  // Force PDF off until component is updated
  gchbPDF := False;

  // Logging after parameters received
  if CmdLine.ParamCount > 0 then
  begin
    Progress.Log('Settings from parameters received:');
    if gchbGZIP then
      Progress.Log(RPad('GZIP', RPAD_VALUE2) + BoolToStr(gchbGZIP, True));
    if gchbMAC then
      Progress.Log(RPad('MAC FS Events', RPAD_VALUE2) + BoolToStr(gchbMAC, True));
    if gchbOFFICE then
      Progress.Log(RPad('Office', RPAD_VALUE2) + BoolToStr(gchbOFFICE, True));
    if gchbOFFICEXML then
      Progress.Log(RPad('Office XML', RPAD_VALUE2) + BoolToStr(gchbOFFICEXML, True));
    if gchbOPENOFFICE then
      Progress.Log(RPad('Open Office', RPAD_VALUE2) + BoolToStr(gchbOPENOFFICE, True));
    if gchbPDF then
      Progress.Log(RPad('PDF', RPAD_VALUE2) + BoolToStr(gchbPDF, True));
    if gchbRAR then
      Progress.Log(RPad('RAR', RPAD_VALUE2) + BoolToStr(gchbRAR, True));
    if gchbTAR then
      Progress.Log(RPad('TAR', RPAD_VALUE2) + BoolToStr(gchbTAR, True));
    if gchbTMB then
      Progress.Log(RPad('Thumbs', RPAD_VALUE2) + BoolToStr(gchbTMB, True));
    if gchbVID then
      Progress.Log(RPad('Video', RPAD_VALUE2) + BoolToStr(gchbVID, True));
    if gchbZIP then
      Progress.Log(RPad('ZIP', RPAD_VALUE2) + BoolToStr(gchbZIP, True));
    if gchbZIPOTHER then
      Progress.Log(RPad('ZIP Other', RPAD_VALUE2) + BoolToStr(gchbZIPOTHER, True));
    if gchbZIP7 then
      Progress.Log(RPad('ZIP7', RPAD_VALUE2) + BoolToStr(gchbZIP7, True));
  end;

  MainProc;

  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Progress.Log(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := (SCRIPT_NAME + ' finished.');

end.
