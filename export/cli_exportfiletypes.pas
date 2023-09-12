{ !NAME: Export_File_Types.pas }
{ !DESC: Export file types by extension. }
{ !AUTHOR: GetData }

unit cli_exportfiletypes;

interface

uses
  Classes, Common, DataEntry, DataStorage, DataStreams, DateUtils, Math, PropertyList, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  // ==============================================================================
  // THESE METADATA NODE VALUES ARE TO REMAIN IN ENGLISH - DO NOT TRANSLATE
  // ==============================================================================
  // Set the Metadata Node Names
  ROOT_ENTRY_EXIF = 'Marker E1 (Exif)';
  NODEBYNAME_Tag271Make = 'Tag 271 (Make)';
  NODEBYNAME_Tag272DeviceModel = 'Tag 272 (Device Model)';
  NODEBYNAME_Tag306DateTime = 'Tag 306 (Date/Time)';

  OSFILENAME = '\\?\'; // This is needed for longfilenames
  SCRIPT_NAME = 'Export Files by Extension';
  CHAR_LENGTH = 80;
  RPAD_VALUE = 30;

var
  OptionsLog_StringList: TStringList;
  ResultsLog_StringList: TStringList;
  ErrorLog_StringList: TStringList;
  gCaseName: String;

implementation

// Console Log
procedure ConsoleLog(AString: string);
begin
  Progress.Log('[' + DateTimeToStr(Now) + '] : ' + AString);
end;

// Console and write to OptionsLog_StringLilst ---------------------------------
procedure Console_And_OptionsLog(AString: string);
var
  s: string;
begin
  s := '[' + DateTimeToStr(Now) + '] : ' + AString;
  Progress.Log(s); // add time and date to the console log messages.
  if assigned(OptionsLog_StringList) then
    OptionsLog_StringList.Add(AString); // no time and date for the results memo
end;

// Console and write to ResultsLog_StringLilst ---------------------------------
procedure Console_And_ResultsLog(AString: string);
var
  s: string;
begin
  s := '[' + DateTimeToStr(Now) + '] : ' + AString;
  Progress.Log(s); // add time and date to the console log messages.
  if assigned(ResultsLog_StringList) then
    ResultsLog_StringList.Add(AString); // no time and date for the results memo
end;

// Console and write to ResultsLog_StringLilst ---------------------------------
procedure Console_And_ErrorLog(AString: string);
var
  s: string;
begin
  s := '[' + DateTimeToStr(Now) + '] : ' + AString;
  Progress.Log(s); // add time and date to the console log messages.
  if assigned(ErrorLog_StringList) then
    ErrorLog_StringList.Add(AString); // no time and date for the results memo
end;

function RPad(AString: string; AChars: Integer): string;
begin
  while length(AString) < AChars do
    AString := AString + ' ';
  Result := AString;
end;

function StripIllegalChars(AString: string): string;
var
  x: Integer;
const
  IllegalCharSet: set of char = ['|', '<', '>', '\', '^', '+', '=', '?', '/', '[', ']', '"', ';', ',', '*', ':'];
begin
  for x := 1 to length(AString) do
    if AString[x] in IllegalCharSet then
      AString[x] := '_';
  Result := AString;
end;

function IsValidExtension(anExt: string; FileSig: TFileTypeInformation): boolean;
var
  inExt: string;
  testExts: string;
begin
  Result := False;
  inExt := StringReplace(anExt, '.', '', [rfReplaceAll]);
  inExt := UpperCase(inExt);
  testExts := UpperCase(FileSig.Extensions);
  Result := pos(inExt, testExts) > 0;
end;

function StartingChecks: boolean;
var
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
begin
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessageNow := 'Starting...';
  Result := False;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      ConsoleLog(DATASTORE_FILESYSTEM + ' module not located. The script will terminate.');
      Exit;
    end;
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case. The script will terminate.');
      Exit;
    end
    else
      gCaseName := StartCheckEntry.EntryName;
    ConsoleLog(Stringofchar('~', CHAR_LENGTH));
    ConsoleLog(RPad('Case Name:', RPAD_VALUE) + gCaseName);
    ConsoleLog(RPad('Script Name:', RPAD_VALUE) + SCRIPT_NAME);
    ConsoleLog(RPad('Date Run:', RPAD_VALUE) + DateTimeToStr(Now));
    ConsoleLog(RPad('FEX Version:', RPAD_VALUE) + CurrentVersion);
    ConsoleLog(Stringofchar('~', CHAR_LENGTH));
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module. The script will terminate.');
      Exit;
    end;
    Result := True;
  finally
    StartCheckDataStore.free;
  end;
end;

// The start of the script
var
  EntryList: TDataStore;
  Entry: TEntry;
  blGroupByDevice: boolean;
  blKeepFolders: boolean;
  blCSVLogFile: boolean;
  blExtOnly: boolean;
  blSigThenExt: boolean;
  blKeepTimes: boolean;
  DestinationFolder: string; // folder to export files to
  KeepTimes: boolean; // keep the original MAC times and dates of files
  blAddMetaToFileSavename: boolean;
  ExportToExtFolders: boolean;
  ExportLogHeader_StringList: TStringList;
  ExportLog_StringList: TStringList;
  DeviceEntry: TEntry;
  EntryReader: TEntryReader;
  EntryReader2: TEntryReader;
  Ext: string;
  LogicalSize: int64;
  FilesExported_int, num: Integer;
  Included: boolean;
  ExportFile: TFileStream;
  exportfilename, newname: string;
  fname, fpath, fext: string;
  ExportDate: string;
  ExportTime: string;
  ExportDateTime: string;
  ExportFolder: string;
  fileext: string;
  FileSig: string;
  OutputFolderFullPath: string;
  DeviceName: string;
  FileSignatureInfo: TFileTypeInformation;
  Error_Count: Integer;
  FileSaveName: string;
  newfileext: string;
  Extmatch: boolean;

  // Column name variables
  colTag271Make: TDataStoreField;
  colTag272DeviceModel: TDataStoreField;
  colTag306DateTime: TDataStoreField;
  Tag271Make: string;
  Tag272DeviceModel: string;
  Tag306DateTime: string;

  aPropertyTree: TPropertyParent;
  aRootEntry: TPropertyNode;
  aPropertyNode, aParentNode: TPropertyNode;

  param: string;
  n: Integer;

begin
  if not StartingChecks then
    Exit;
  ConsoleLog(SCRIPT_NAME + ' started...');

  param := '';
  if (CmdLine.ParamCount > 0) then
  begin
    ConsoleLog(RPad('Parameters received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    for n := 0 to CmdLine.ParamCount - 1 do
    begin
      ConsoleLog(RPad('Param ' + IntToStr(n) + ':', RPAD_VALUE) + CmdLine.params[n]);
      param := param + '"' + CmdLine.params[n] + '"' + ' ';
    end;
    trim(param);
  end
  else
  begin
    ConsoleLog('No parameters received.');
    Exit;
  end;
  ConsoleLog(Stringofchar('-', CHAR_LENGTH));

  ExportToExtFolders := CmdLine.params.Indexof('BYEXT') >= 0;
  blGroupByDevice := CmdLine.params.Indexof('BYDEVICE') >= 0;
  blSigThenExt := CmdLine.params.Indexof('USESIG') >= 0;

  blKeepFolders := CmdLine.params.Indexof('KEEPFOLDERS') >= 0;
  blKeepTimes := CmdLine.params.Indexof('KEEPTIMES') >= 0;
  blCSVLogFile := CmdLine.params.Indexof('LOGFILE') >= 0;
  blAddMetaToFileSavename := CmdLine.params.Indexof('JPGMETA') >= 0;

  ErrorLog_StringList := TStringList.Create;
  OptionsLog_StringList := TStringList.Create;
  ResultsLog_StringList := TStringList.Create;

  DestinationFolder := IncludeTrailingPathDelimiter(GetExportedDir);
  OutputFolderFullPath := '';

  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  Entry := EntryList.First;

  // Update progress display
  Progress.Initialize(EntryList.Count, 'Starting...');
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.Max := EntryList.Count;
  Progress.CurrentPosition := 1;

  ExportDate := formatdatetime('yyyy-mm-dd', Now);
  ExportTime := formatdatetime('hh-nn-ss', Now);
  ExportDateTime := (ExportDate + '-' + ExportTime);
  ExportFolder := IncludeTrailingPathDelimiter('Export - ' + ExportDateTime);

  ExportLogHeader_StringList := TStringList.Create;
  ExportLog_StringList := TStringList.Create;

  // Setup Log Header
  ExportLogHeader_StringList.Add('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  ExportLogHeader_StringList.Add(RPad('~ Script:', RPAD_VALUE) + SCRIPT_NAME);
  ExportLogHeader_StringList.Add(RPad('~ Date:', RPAD_VALUE) + ExportDate + ' at ' + ExportTime);
  ExportLogHeader_StringList.Add(RPad('~ FEX Version:', RPAD_VALUE) + CurrentVersion);
  ExportLogHeader_StringList.Add(RPad('~ Case Name:', RPAD_VALUE) + gCaseName);
  ExportLogHeader_StringList.Add('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

  // Setup Error Log Header
  Console_And_ErrorLog('================================================================');
  Console_And_ErrorLog('Logging:');

  Error_Count := 0;
  try
    EntryReader := TEntryReader.Create;
    EntryReader2 := TEntryReader.Create;
    FilesExported_int := 0;
    while assigned(Entry) and Progress.isRunning do
    begin
      fileext := '';
      FileSig := '';
      Extmatch := True;
      LogicalSize := Entry.LogicalSize;
      Ext := UpperCase(ExtractFileExt(Entry.EntryName));
      Included := True;

      // ----------------------------------------------------------------------
      // ALWAYS EXCLUDE ALL OF THESE TYPES
      // ----------------------------------------------------------------------
      if Entry.isFreeSpace then
        Included := False;
      if Entry.isSystem then
        Included := False;
      if Entry.IsDevice then
        Included := False;
      if Entry.EntryName = '$BadClus~$Bad' then
        Included := False;

      // ======================================================================
      // Export file
      // ======================================================================
      if Included then
      begin
        if ExportToExtFolders then
        begin
          // If Extension ----------------------------------------------------
          if not(blSigThenExt) then
          begin
            fileext := ExtractFileExt(UpperCase(Entry.EntryName));
            if fileext = '' then
              fileext := '.NO EXTENSION';
            fileext := StringReplace(fileext, '.', '', [rfReplaceAll]);
          end;
          // If Signature ----------------------------------------------------
          if blSigThenExt then
          begin
            // Get the File Signature
            FileSignatureInfo := Entry.FileDriverInfo;
            FileSig := UpperCase(FileSignatureInfo.Extensions);
            if pos(' ', FileSig) > 0 then
              FileSig := UpperCase(copy(FileSig, 1, pos(' ', FileSig) - 1));
            // Does the Signature Match the Extension?
            fileext := ExtractFileExt(UpperCase(Entry.EntryName));
            fileext := StringReplace(fileext, '.', '', [rfReplaceAll]); // Need to take the leading . off file extension
            if not IsValidExtension(fileext, FileSignatureInfo) then
            begin
              ConsoleLog(RPad('File Signature: ' + UpperCase(FileSig), 30) + (RPad('<-- Does not match -->', RPAD_VALUE) + 'File Ext: ' + UpperCase(fileext)));
              Extmatch := False;
            end;
            // If the Signature is blank then just get the extension
            if (FileSignatureInfo.ShortDisplayName = '') then
              fileext := ExtractFileExt(UpperCase(Entry.EntryName))
            else
              fileext := FileSig;
            if fileext = '' then
              fileext := 'NO EXTENSION';
            fileext := StringReplace(fileext, '.', '', [rfReplaceAll]);
          end;
          trim(fileext);
          fileext := IncludeTrailingPathDelimiter(fileext);
        end
        else
          fileext := ''; // Needs to be empty when added to the path below

        // If Group By Device ------------------------------------------------
        if blGroupByDevice then
        begin
          DeviceEntry := GetDeviceEntry(Entry);
          if assigned(DeviceEntry) then
            DeviceName := IncludeTrailingPathDelimiter(DeviceEntry.EntryName);
        end
        else
          DeviceName := '';

        // Start the Export
        if not Entry.IsDirectory then
        begin
          if EntryReader.OpenData(Entry) then
          begin
            FileSaveName := Entry.SaveName;
            if (not Extmatch) and ((UpperCase(FileSig)) <> '') then
            begin
              if pos(' ', FileSignatureInfo.Extensions) > 0 then
                newfileext := copy(FileSignatureInfo.Extensions, 1, pos(' ', FileSignatureInfo.Extensions) - 1)
              else
                newfileext := FileSignatureInfo.Extensions;
              FileSaveName := FileSaveName + '.' + UpperCase(newfileext);
            end;

            // JPG Metadata
            colTag271Make := AddMetaDataField('Exif 271: Make', ftString);
            colTag272DeviceModel := AddMetaDataField('Exif 272: Device Model', ftString);
            colTag306DateTime := AddMetaDataField('Exif 306: Date/Time', ftString);
            Tag306DateTime := '';
            Tag271Make := '';
            Tag272DeviceModel := '';
            FileSignatureInfo := Entry.FileDriverInfo;
            // Limit to JPG
            if (blAddMetaToFileSavename and (FileSignatureInfo.FileDriverNumber > 0) and (FileSignatureInfo.ShortDisplayName = 'JPG')) then
            begin
              try
                // Test to see if the existing columns have data
                if not(colTag271Make.isNull(Entry)) and not(colTag272DeviceModel.isNull(Entry)) and not(colTag306DateTime.isNull(Entry)) then
                begin
                  // No need to extract data again
                  Tag271Make := (colTag271Make.AsString[Entry]);
                  Tag272DeviceModel := (colTag272DeviceModel.AsString[Entry]);
                  Tag306DateTime := (colTag306DateTime.AsString[Entry]);
                end
                else
                begin
                  if ProcessMetadataProperties(Entry, aPropertyTree, EntryReader2) then
                  begin
                    if assigned(aPropertyTree) then
                    begin
                      aRootEntry := aPropertyTree.RootProperty;
                      if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
                      begin
                        aParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_EXIF));
                        if assigned(aParentNode) then
                        begin
                          // Extract Date Time -----------------------------------------
                          Tag306DateTime := '';
                          aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag306DateTime));
                          if assigned(aPropertyNode) then
                          begin
                            Tag306DateTime := trim(aPropertyNode.PropValue);
                            if Tag306DateTime <> '' then
                              colTag306DateTime.AsString[Entry] := Tag306DateTime;
                          end;
                          // Extract Make ----------------------------------------------
                          Tag271Make := '';
                          aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag271Make));
                          if assigned(aPropertyNode) then
                          begin
                            Tag271Make := trim(aPropertyNode.PropValue);
                            if Tag271Make <> '' then
                              colTag271Make.AsString[Entry] := Tag271Make;
                          end;
                          // Extract Model ---------------------------------------------
                          Tag272DeviceModel := '';
                          aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag272DeviceModel));
                          if assigned(aPropertyNode) then
                          begin
                            Tag272DeviceModel := trim(aPropertyNode.PropValue);
                            if Tag272DeviceModel <> '' then
                              colTag272DeviceModel.AsString[Entry] := Tag272DeviceModel;
                          end;
                        end; // (If a parent node)
                      end;
                    end;
                  end;
                end;
              finally
                if assigned(aPropertyTree) then
                begin
                  aPropertyTree.free;
                  aPropertyTree := nil;
                end;
                // Only rename the file if there is a valid Tag 306 (Date/Time)
                Tag306DateTime := (colTag306DateTime.AsString[Entry]);
                if Tag306DateTime <> '' then
                begin
                  Tag306DateTime := Tag306DateTime + '-';
                  Tag271Make := (colTag271Make.AsString[Entry]);
                  if Tag271Make <> '' then
                    Tag271Make := Tag271Make + '-';
                  Tag272DeviceModel := (colTag272DeviceModel.AsString[Entry]);
                  if Tag272DeviceModel <> '' then
                    Tag272DeviceModel := Tag272DeviceModel + '-';
                  FileSaveName := Tag306DateTime + Tag271Make + Tag272DeviceModel + FileSaveName;
                  FileSaveName := StripIllegalChars(FileSaveName);
                end;
              end; { try/finally }
            end;

            // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

            if blKeepFolders then
              exportfilename := DestinationFolder + ExportFolder + DeviceName + fileext + Entry.SaveDirectory + FileSaveName
            else
              exportfilename := DestinationFolder + ExportFolder + DeviceName + fileext + FileSaveName;

            fname := ExtractFileName(exportfilename);
            fname := ChangeFileExt(fname, ''); // Filename without extension
            fext := ExtractFileExt(exportfilename); // Extension
            fpath := ExtractFilePath(exportfilename); // Full path to the exported file

            // File exist check and rename if needed
            num := 1;
            newname := exportfilename;
            while FileExists(newname) and Progress.isRunning do
            begin
              newname := fpath + fname + '(' + IntToStr(num) + ')' + fext;
              // Similar method as windows explorer
              inc(num);
            end;
            exportfilename := newname;
            Progress.DisplayMessages := 'Exporting: ' + fname;

            if ForceDirectories(OSFILENAME + fpath) then
            begin
              // Export the file
              ExportFile := TFileStream.Create(OSFILENAME + exportfilename, fmOpenWrite or fmCreate);
              try
                try
                  ExportFile.CopyFrom(EntryReader, Entry.LogicalSize);
                  ExportLog_StringList.Add(Entry.FullPathName);
                  // ConsoleLog('Exported: ' + Entry.FullPathName);
                  // ConsoleLog(Format('Exported %0:s of %1:s',[IntToStr(EntryReader.position),IntToStr(Entry.logicalSize)]));
                except
                  Console_And_ErrorLog(RPad('Failed to export file: ', RPAD_VALUE) + exportfilename);
                  Error_Count := Error_Count + 1;
                end;
              finally
                ExportFile.free;
                if blKeepTimes then
                begin
                  // Correct the file times to match that recorded in the data entry
                  if not(SetOrginalTime(exportfilename, Entry)) then
                    ConsoleLog('Failed to set Last Modified Date/Time for: ' + exportfilename);
                end;
              end;
              inc(FilesExported_int);
            end
            else
            begin
              ConsoleLog(RPad('Failed to create folder: ', RPAD_VALUE) + fpath);
              ErrorLog_StringList.Add('ERROR - Failed to create folder: ' + fpath);
              Error_Count := Error_Count + 1;
            end;

          end
          else
          begin
            ConsoleLog(RPad('Could not open data: ', RPAD_VALUE) + Entry.EntryName);
            ErrorLog_StringList.Add('ERROR - Could not open data: ' + Entry.EntryName);
            Error_Count := Error_Count + 1;
          end; { open data }
        end; { is Directory }
      end; { if included }
      Progress.IncCurrentProgress;
      Entry := EntryList.Next;
    end; // assigned an entry
    Console_And_ErrorLog(RPad('Total Errors: ', RPAD_VALUE) + (IntToStr(Error_Count)));
    ErrorLog_StringList.Add('================================================================');

    if FilesExported_int > 0 then
    begin
      Console_And_ResultsLog('================================================================');
      Console_And_ResultsLog(RPad('Export Log file: ', RPAD_VALUE) + DestinationFolder + ExportFolder + ExportDateTime + ' - Export Log.txt');
      OutputFolderFullPath := IncludeTrailingPathDelimiter(DestinationFolder + ExportFolder);
    end
    else
      Console_And_ResultsLog('No files matched the export criteria.');

    Console_And_ResultsLog(RPad('Files Exported:', RPAD_VALUE) + IntToStr(FilesExported_int));
    ResultsLog_StringList.Add(RPad('Total Errors: ', RPAD_VALUE) + IntToStr(Error_Count));
    Console_And_ResultsLog('================================================================');

    // ======OUTPUT THE STRING LIST==============================================
    if (blCSVLogFile) and (ExportLog_StringList.Count > 0) then
    begin
      ExportLog_StringList.Sort;
      // Merge all the String Lists
      ExportLogHeader_StringList.Addstrings(OptionsLog_StringList);
      ExportLogHeader_StringList.Addstrings(ResultsLog_StringList);
      ExportLogHeader_StringList.Add('Files Exported:');
      ExportLogHeader_StringList.Addstrings(ExportLog_StringList);
      if (Error_Count > 0) then
        ExportLogHeader_StringList.Addstrings(ErrorLog_StringList);
      ExportLogHeader_StringList.SaveToFile(DestinationFolder + ExportFolder + ExportDateTime + ' - Export Log.txt');
    end;

  finally
    EntryReader.free;
    EntryReader2.free;
    EntryList.free;
    ExportLog_StringList.free;
    ExportLogHeader_StringList.free;
    Progress.CurrentPosition := Progress.Max;
    ErrorLog_StringList.free;
    OptionsLog_StringList.free;
    ResultsLog_StringList.free;
  end;
  ConsoleLog(SCRIPT_NAME + ' finished.');

end.
