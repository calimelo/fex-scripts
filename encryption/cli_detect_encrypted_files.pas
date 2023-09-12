unit Encrypted_Files;

interface

uses
  Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DataStreams, Graphics, Math, PropertyList, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  SHOW_REASON_BL = False;
  REPORT_TIME_TAKEN_BL = True;

  BM_ENCRYPTED_FILES = 'Encrypted Files';
  BM_SCRIPT_OUTPUT_FLDR = 'Script Output';
  BS = '\';
  BUFFERSIZE = 4096 * 4;
  CHAR_LENGTH = 80;
  COMMA = ', ';
  COLON = ':';
  HYPHEN = ' - ';
  MSOFFICE = 'MS Office';
  RPAD_VALUE = 31;
  RUNNING = '...';
  ENCRYPTED_FILES_STR = 'Encrypted files found';
  SCRIPT_DESCRIPTION = 'Find encrypted files.' + #13#10 + 'Files located can be bookmarked from the results screen.' + #13#10 + #13#10 + 'WARNING: This is not an exhaustive search for all encryption types.';
  SCRIPT_NAME = 'Find Encrypted Files';
  SCRIPT_REFERENCES = 'Entropy: http://en.wikipedia.org/wiki/Entropy_%28information_theory%29' + #13#10 + 'RAR v5 Archive Format: https://www.rarlab.com/technote.htm#enchead';
  SPACE = ' ';
  STARTUP_TAB = 1;
  TSWT = 'The script will terminate.';

  STR_UPP_MS_ENCRYPTED = 'MS ENCRYPTED'; // noslz
  STR_UPP_RAR_ENCRYPTED = 'RAR (ENCRYPTED)'; // noslz
  STR_UPP_WORD_ENCRYPTED = 'WORD (ENCRYPTED)'; // noslz
  STR_UPP_EXCEL_ENCRYPTED = 'EXCEL (ENCRYPTED)'; // noslz
  STR_UPP_POWERPOINT_ENCRYPTED = 'POWERPOINT (ENCRYPTED)'; // noslz

  EXCLUDE_ARCHIVE_REGEX_STR = '(accdt|accft|apk|bau|bbfw|cab|dat|deskthemepack|eftx|glox|' + 'gz|gzip|ipa|ipsw|jar|msu|mzz|odb|odg|odp|onepkg|otp|ots|ott|oxt|rbf|rdb|skin|sob|stw|' + 'thmx|thmx|ui|wmz|xpi|xsn|wmf)';

  ENC_IN_ARCHIVES_STR = 'Search inside Archives (RAR, Zip, 7Zip)';

  FORMAT_STR1 = '%-6s %-10s %-11s %-100s';
  FORMAT_STR2 = '%-6s %-10s %-11s %-16s %-100s';

var
  garchive_StringList: TStringList;
  gbl_blowfish: boolean;
  gbl_Continue: boolean;
  gbl_Export_Results: boolean;
  gchb_7zp: boolean;
  gchb_doc: boolean;
  gchb_enc_in_enc: boolean;
  gchb_itn: boolean;
  gchb_ntfs: boolean;
  gchb_odt: boolean;
  gchb_pdf: boolean;
  gchb_rar: boolean;
  gchb_rem: boolean;
  gchb_xml: boolean;
  gchb_zip: boolean;
  gCollection_StringList: TStringList;
  gFieldEntropy: TDataStoreField;
  gfilebuffer: array [0 .. 16383] of byte; // Must be global
  ghigh_entropy_dbl: double;
  gHighEntropy_StringList: TStringList;
  gHighEntropy_TList: TList;
  gMemo_StringList: TStringList;
  gResult_EncFiles_StringList: TStringList;
  gResult_EncInArchive_StringList: TStringList;
  gtotal_entries_int: integer;

type
  Item_Record = class
    Rec_Bates_str: string;
    Rec_Entropy_str: string;
    Rec_Reason_str: string;
    Rec_FilePath_str: string;
    Rec_Extra_str: string;
    Rec_Entry: TEntry;
  end;

function CalculateEntropy(calcEntry: TEntry): extended;
function ParametersReceived: boolean;
function SortBatesStringList(List: TStringList; Index1, Index2: integer): integer;
procedure Add_To_Encrypted_StringList(aEntry: TEntry; aStringList: TStringList; areason_str: string; extra_str: string);
procedure AddToEncryptedInExpanded(eEntry: TEntry; gEncrypted_TUniqueList: TList);
procedure Bookmark_TList(abmFolder: string; aTList: TList);
procedure Encrypted_In_Archives(Received_TStringList: TStringList; FinStringList: TStringList);
procedure ExportResultsToFile;
procedure ProgressLogMemo(AString: string);

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

procedure MessageUser(AString: string);
begin
  Progress.Log(AString);
end;

procedure BookmarkResults;
var
  bmColumn: TDataStoreField;
  bmColumnPosition: integer;
  DataStore_BM: TDataStore;
  bmEntry: TEntry;
  BM_TList: TList;
  i: integer;
begin
  BM_TList := TList.Create;
  try
    if assigned(gResult_EncFiles_StringList) and (gResult_EncFiles_StringList.Count > 0) then
    begin
      for i := 0 to (gResult_EncFiles_StringList.Count) - 1 do
      begin
        if not Progress.isRunning then
          break;
        if gResult_EncFiles_StringList.Objects[i] <> nil then
        begin
          bmEntry := (Item_Record(gResult_EncFiles_StringList.Objects[i]).Rec_Entry);
          if assigned(bmEntry) then
            BM_TList.Add(bmEntry);
        end;
      end;
    end;

    if assigned(gResult_EncInArchive_StringList) and (gResult_EncInArchive_StringList.Count > 0) then
    begin
      for i := 0 to (gResult_EncInArchive_StringList.Count) - 1 do
      begin
        if not Progress.isRunning then
          break;
        if gResult_EncInArchive_StringList.Objects[i] <> nil then
        begin
          bmEntry := (Item_Record(gResult_EncInArchive_StringList.Objects[i]).Rec_Entry);
          if assigned(bmEntry) then
            BM_TList.Add(bmEntry);
        end;
      end;
    end;

    // Bookmark Encrypted
    if assigned(BM_TList) and (BM_TList.Count > 0) then
      Bookmark_TList('Encrypted', BM_TList);

    // Bookmark High Entropy
    if assigned(gHighEntropy_TList) and (gHighEntropy_TList.Count > 0) then
      Bookmark_TList('High Entropy', gHighEntropy_TList);

    // Add Entropy Column to Bookmarks module
    bmColumnPosition := 3;
    DataStore_BM := GetDataStore(DATASTORE_BOOKMARKS);
    try
      bmColumn := DataStore_BM.DataFields.FieldbyName('Entropy'); // noslz
    finally
      DataStore_BM.free;
    end;
  finally
    BM_TList.free;
  end;
end;

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

// ------------------------------------------------------------------------------
// Procedure: Create PDF
// ------------------------------------------------------------------------------
procedure CreateRunTimePDF(aStringList: TStringList; save_name_str: string; font_size_int: integer; DT_In_FileName_bl: boolean);
const
  HYPHEN = ' - ';
var
  CurrentCaseDir: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
  SaveName: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);
  if DT_In_FileName_bl then
    ExportDateTime := (ExportDate + HYPHEN + ExportTime + HYPHEN)
  else
    ExportDateTime := '';
  SaveName := ExportedDir + ExportDateTime + save_name_str + '.pdf';
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if GeneratePDF(SaveName, aStringList, font_size_int) then
          Progress.Log('Success Creating: ' + SaveName);
      end
      else
        Progress.Log('Failed Creating: ' + SaveName);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Exception creating runtime folder');
    end;
  end
  else
    Progress.Log('There is no current case folder');
end;

function CalcTimeTaken(starting_tick_count: uint64; Description_str: string): string;
var
  time_taken_int: uint64;
begin
  Result := '';
  time_taken_int := (GetTickCount - starting_tick_count);
  time_taken_int := trunc(time_taken_int / 1000);
  if REPORT_TIME_TAKEN_BL then
    Result := Description_str + 'Time:' + SPACE + formatdatetime('hh:nn:ss', time_taken_int / SecsPerDay);
end;

function SortBatesStringList(List: TStringList; Index1, Index2: integer): integer;
var
  Value1, Value2: integer;
begin
  Value1 := StrToInt(List[Index1]);
  Value2 := StrToInt(List[Index2]);
  if Value1 < Value2 then
    Result := -1
  else if Value2 < Value1 then
    Result := 1
  else
    Result := 0;
end;

function SortBatesTList(Item1, Item2: Pointer): integer;
var
  anEntry1: TEntry;
  anEntry2: TEntry;
  bates1: integer;
  bates2: integer;
begin
  Result := 0;
  if (Item1 <> nil) and (Item2 <> nil) then
  begin
    anEntry1 := TEntry(Item1);
    anEntry2 := TEntry(Item2);
    bates1 := anEntry1.ID;
    bates2 := anEntry2.ID;
    if bates1 > bates2 then
      Result := 1
    else if bates1 < bates2 then
      Result := -1;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Parameters Received
// ------------------------------------------------------------------------------
function ParametersReceived: boolean;
var
  param_str: string;
  i: integer;
begin
  Result := False;
  Progress.Log(StringOfChar('-', 80));
  if CmdLine.ParamCount > 0 then
  begin
    Result := True;
    param_str := '';
    Progress.Log(RPad('Params received:', RPAD_VALUE) + IntToStr(CmdLine.ParamCount));
    Progress.Log('Params:');
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      Progress.Log(RPad(' Param ' + IntToStr(i) + ':', RPAD_VALUE) + CmdLine.params[i]);
      param_str := param_str + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(param_str);
  end
  else
    Progress.Log('No parameters were received.');
  Progress.Log(StringOfChar('-', 80));
end;

// ------------------------------------------------------------------------------
// Procedure: Export Results To File
// ------------------------------------------------------------------------------
procedure ExportResultsToFile;
var
  CurrentCaseDir: string;
  Export_Filename: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
begin
  if gbl_Export_Results then
  begin
    CurrentCaseDir := GetCurrentCaseDir;
    ExportedDir := CurrentCaseDir + 'Exported\';
    ExportDate := formatdatetime('yyyy-mm-dd', now);
    ExportTime := formatdatetime('hh-nn-ss', now);
    ExportDateTime := (ExportDate + ' - ' + ExportTime);
    if DirectoryExists(ExportedDir) then
    begin
      if assigned(gMemo_StringList) and (gMemo_StringList.Count > 0) then
      begin
        Export_Filename := ExportedDir + ExportDateTime + HYPHEN + SCRIPT_NAME + '.txt';
        gMemo_StringList.SaveToFile(Export_Filename);
      end;
    end
    else
      MessageUser('Export folder not found: ' + ExportedDir);
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Progress.Log to gMemo_StringList
// ------------------------------------------------------------------------------
procedure ProgressLogMemo(AString: string);
begin
  Progress.Log(AString);
  if assigned(gMemo_StringList) then
    gMemo_StringList.Add(AString);
end;

// ------------------------------------------------------------------------------
// Procedure: Find the parent of an Encrypted in Expanded
// ------------------------------------------------------------------------------
procedure AddToEncryptedInExpanded(eEntry: TEntry; gEncrypted_TUniqueList: TList);
var
  e, f: integer;
  InList_Entry: TEntry;
  testEntry: TEntry;
  upper_shortdisplayname_str: string;
begin
  if assigned(gEncrypted_TUniqueList) then
  begin
    if eEntry.isEncrypted and eEntry.inExpanded then
    begin
      testEntry := TEntry(eEntry.parent);
      for f := 0 to 50 do
      begin
        if not Progress.isRunning then
          break;
        if not testEntry.isExpanded then
          testEntry := TEntry(testEntry.parent)
        else
          break;
      end;
      for e := 0 to gEncrypted_TUniqueList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        InList_Entry := TEntry(gEncrypted_TUniqueList[e]);
        if testEntry = InList_Entry then
          Exit;
      end;

      upper_shortdisplayname_str := UpperCase(testEntry.FileDriverInfo.ShortDisplayname);

      if gchb_xml and ((upper_shortdisplayname_str = 'XLSX') or (upper_shortdisplayname_str = 'DOCX') or (upper_shortdisplayname_str = 'PPTX') or (upper_shortdisplayname_str <> STR_UPP_MS_ENCRYPTED)) then
      begin
        gEncrypted_TUniqueList.Add(testEntry);
        gbl_Continue := False;
        Exit;
      end;

      if gchb_ntfs and ((upper_shortdisplayname_str <> 'XLSX') and (upper_shortdisplayname_str <> 'DOCX') and (upper_shortdisplayname_str <> 'PPTX') and (upper_shortdisplayname_str <> STR_UPP_MS_ENCRYPTED)) then
      begin
        gEncrypted_TUniqueList.Add(testEntry);
        gbl_Continue := False;
        Exit;
      end;

    end;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Bookmark TList
// ------------------------------------------------------------------------------
procedure Bookmark_TList(abmFolder: string; aTList: TList);
var
  bmCreate: boolean;
  bmEntry: TEntry;
  bmfolder: TEntry;
  bmpath: string;
  k: integer;
begin
  if assigned(aTList) and (aTList.Count > 0) then
  begin
    // Create bookmark folder
    bmpath := BM_SCRIPT_OUTPUT_FLDR + BS + BM_ENCRYPTED_FILES + BS + abmFolder;
    bmCreate := True;
    bmfolder := FindBookmarkByName(bmpath, bmCreate);
    // Add items to bookmark folder
    if assigned(bmfolder) and (aTList.Count > 0) then
    begin
      for k := 0 to (aTList.Count - 1) do
      begin
        if not Progress.isRunning then
          break;
        bmEntry := TEntry(aTList[k]);
        if not IsItemInBookmark(bmfolder, bmEntry) then
        begin
          AddItemsToBookmark(bmfolder, DATASTORE_FILESYSTEM, bmEntry, '');
        end;
      end;
      MessageUser(IntToStr(aTList.Count) + SPACE + abmFolder + ' files bookmarked');
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Calculate Entropy
// ------------------------------------------------------------------------------
function CalculateEntropy(calcEntry: TEntry): extended;
var
  b: integer;
  byteCounts: array [0 .. 255] of int64;
  bytesRead: integer;
  calcEntropy: extended;
  calcReader: TEntryReader;
  p: double;
  ReadStream: boolean;
begin
  if (calcEntry.LogicalSize > 0) and (calcEntry.PhysicalSize > 0) then
  begin
    calcReader := TEntryReader.Create;
    calcEntropy := 0.0;
    if calcReader.OpenData(calcEntry) then
    begin
      for b := 0 to 255 do
        byteCounts[b] := 0;
      try
        bytesRead := calcReader.Read(gfilebuffer[0], BUFFERSIZE);
        if bytesRead > 0 then
        begin
          for b := 0 to bytesRead - 1 do
            inc(byteCounts[gfilebuffer[b]]);
          for b := 0 to 255 do
          begin
            p := byteCounts[b] / bytesRead;
            if p > 0.0 then
              calcEntropy := calcEntropy - p * Log2(p);
          end;
          calcEntropy := calcEntropy * 0.125;
        end;
      except
        ReadStream := False;
      end;
      gFieldEntropy.AsExtended[calcEntry] := calcEntropy;
    end
    else
      Progress.Log('Could not open data: ' + calcEntry.EntryName);
  end;
  Result := calcEntropy;
  calcReader.free;
end;

// ------------------------------------------------------------------------------
// Procedure: Add_To_Encrypted_StringList
// ------------------------------------------------------------------------------
procedure Add_To_Encrypted_StringList(aEntry: TEntry; aStringList: TStringList; areason_str: string; extra_str: string);
var
  ARec: Item_Record;
  entropy_str: string;
  index: integer;
begin
  CalculateEntropy(aEntry);
  if assigned(aStringList) then
  begin
    if aEntry.IsDirectory and not aEntry.isExpanded then
      entropy_str := 'Folder'
    else if gFieldEntropy.asString[aEntry] <> '' then
      entropy_str := gFieldEntropy.asString[aEntry]
    else
      entropy_str := FormatFloat('0.00', CalculateEntropy(aEntry));

    aStringList.sort;
    if aStringList.Find(IntToStr(aEntry.ID), index) then
    begin
      // Progress.Log('Already in audit list: ' + IntToStr(aEntry.ID));
    end
    else
    begin
      ARec := Item_Record.Create;
      ARec.Rec_Bates_str := IntToStr(aEntry.ID);
      ARec.Rec_Entropy_str := entropy_str;
      ARec.Rec_Reason_str := areason_str;
      ARec.Rec_FilePath_str := aEntry.FullPathName;
      ARec.Rec_Entry := aEntry;
      ARec.Rec_Extra_str := extra_str;
      aStringList.AddObject(IntToStr(aEntry.ID), TObject(ARec));
    end;
  end;
  gbl_Continue := False;
end;

// ------------------------------------------------------------------------------
// Procedure: Signature Analysis
// ------------------------------------------------------------------------------
procedure SignatureAnalysis(SigThis_TList: TList; bl_show_progress: boolean);
var
  bl_Continue: boolean;
  start_tick_signature: uint64;
  TaskProgress: TPAC;
begin
  if not Progress.isRunning then
    Exit;
  start_tick_signature := GetTickCount64;
  if not assigned(SigThis_TList) then
  begin
    Progress.Log(RPad('Not assigned Signature TList.', RPAD_VALUE) + 'Signature Analysis not run.');
    Exit;
  end;
  if assigned(SigThis_TList) and (SigThis_TList.Count > 0) then
  begin
    if Progress.isRunning then
    begin
      if SigThis_TList.Count > 100000 then
        // if bl_show_progress then
        TaskProgress := Progress.NewChild
      else
        TaskProgress := NewProgress(False);
      RunTask('TCommandTask_FileTypeAnalysis', DATASTORE_FILESYSTEM, SigThis_TList, TaskProgress);
      while (TaskProgress.isRunning) and (Progress.isRunning) do
        Sleep(500);
      if not(Progress.isRunning) then
        TaskProgress.Cancel;
      bl_Continue := (TaskProgress.CompleteState = pcsSuccess);
    end;
  end;
  Progress.DisplayTitle := SCRIPT_NAME; // Refresh the title
end;

// ------------------------------------------------------------------------------
// Procedure: Node Frog
// ------------------------------------------------------------------------------
procedure nodefrog(aNode: TPropertyNode; anint: integer);
var
  i: integer;
  theNodeList: TObjectList;
begin
  if assigned(aNode) and Progress.isRunning then
  begin
    theNodeList := aNode.PropChildList;
    if assigned(theNodeList) then
    begin
      for i := 0 to theNodeList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        aNode := TPropertyNode(theNodeList.items[i]);
        if assigned(aNode) then
        begin
          if RegexMatch(aNode.PropDisplayValue, 'blowfish', False) then // noslz
            gbl_blowfish := True;
        end;
        nodefrog(aNode, anint + 1);
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------
// Process - Archive Files (7Zip, Rar, Zip)
// ------------------------------------------------------------------------
procedure ProcessArchive(anEntry: TEntry; aReader: TEntryReader; FSDataStore: TDataStore);
var
  anExpanded7zList: TList;
  aParentNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aRootProperty: TPropertyNode;
  byte_count_int: integer;
  ByteArray: array [1 .. 8] of byte;
  determined_sig_str: string;
  DeterminedFileDriverInfo: TFileTypeInformation;
  file_entropy_extd: extended;
  fileext: string;
  FolderChildren_List: TList;
  hexbytes_str: string;
  starting_byte_int: integer;
  TaskProgress: TPAC;
  upper_shortdisplayname_str: string;

begin
  if gbl_Continue and (dtArchive in anEntry.FileDriverInfo.DriverType) then
  begin
    fileext := extractfileext(UpperCase(anEntry.EntryName));
    DetermineFileType(anEntry);
    DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
    determined_sig_str := DeterminedFileDriverInfo.ShortDisplayname;
    if (dtArchive in anEntry.DeterminedFileDriverInfo.DriverType) then
    begin
      if not RegexMatch(fileext, EXCLUDE_ARCHIVE_REGEX_STR, False) then
      begin
        // ----------------------------------------------------------------------
        // 7zip
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_7zp then
        begin
          if (anEntry.FileDriverInfo.ShortDisplayname = '7zip') then
          begin

            // The 7z already expanded test
            if anEntry.isExpanded then
            begin
              FolderChildren_List := TList.Create;
              try
                FolderChildren_List := FSDataStore.Children(anEntry, True);
                if FolderChildren_List.Count = 0 then
                begin
                  Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, '7ZP NOCHILD-A', ''); { Reason - 7z No Child }
                end
              finally
                FolderChildren_List.free;
              end;
            end;

            // The 7z peek inside test
            if gbl_Continue then
            begin
              anExpanded7zList := TList.Create;
              try
                TaskProgress := NewProgress(False);
                try
                  ExtractCompoundFile(anEntry, anExpanded7zList, TaskProgress);
                except
                  Progress.Log(ATRY_EXCEPT_STR + anEntry.EntryName + 'Exception extracting 7zip data: ' + anEntry.EntryName);
                end;
                Sleep(1000);
                Progress.DisplayTitle := SCRIPT_NAME; // Refresh the title after the expand

                if anExpanded7zList.Count = 0 then
                begin
                  Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, '7ZP: NOCHILD-B', ''); { Reason - 7z No Child }
                end;

              finally
                anExpanded7zList.free;
              end;
            end;
          end;
        end;

        // --------------------------------------------------------------
        // RAR - isEncrypted
        // --------------------------------------------------------------
        if gbl_Continue and gchb_rar then
        begin
          upper_shortdisplayname_str := UpperCase(anEntry.FileDriverInfo.ShortDisplayname);
          if (upper_shortdisplayname_str = 'RAR (ENCRYPTED)') then
          begin
            if anEntry.isEncrypted then
            begin
              Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'RAR: ENCRYPTED', ''); { Reason }
            end;
          end;
        end;

        // --------------------------------------------------------------
        // RAR - Node Test
        // --------------------------------------------------------------
        if gbl_Continue and gchb_rar then
        begin
          if (UpperCase(determined_sig_str) = 'RAR') then
          begin
            if aReader.OpenData(anEntry) then
            begin
              aPropertyTree := nil;
              if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
              begin
                try
                  aRootProperty := aPropertyTree.RootProperty;
                  if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
                  begin
                    aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Encrypted')); // noslz
                    if assigned(aParentNode) then
                    begin
                      if gbl_Continue and (UpperCase(determined_sig_str) = 'RAR') then
                        Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'RAR: NODE ENCRYPTED', ''); { Reason }
                    end;
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
        end;

        // ------------------------------------------------------------------
        // RAR - 5.0 Archive Format - https://www.rarlab.com/technote.htm
        // ------------------------------------------------------------------
        if gbl_Continue and gchb_rar then
        begin
          if UpperCase(determined_sig_str) = 'RAR' then
          begin
            starting_byte_int := 13;
            if aReader.OpenData(anEntry) and (anEntry.LogicalSize > starting_byte_int) then
            begin
              byte_count_int := aReader.Read(ByteArray, 1);
              if byte_count_int > 0 then
              begin
                aReader.Position := starting_byte_int;
                hexbytes_str := aReader.AsHexString(byte_count_int);
                hexbytes_str := trim(hexbytes_str);
                if hexbytes_str = '04' then
                begin
                  Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'RAR V5 HEX04', ''); { Reason }
                end;
              end;
            end;
          end;
        end;

        // --------------------------------------------------------------
        // ZIP - isEncrypted
        // --------------------------------------------------------------
        if gbl_Continue and gchb_zip then
        begin
          upper_shortdisplayname_str := UpperCase(anEntry.FileDriverInfo.ShortDisplayname);
          if (upper_shortdisplayname_str = 'ZIP (ENCRYPTED)') then
          begin
            if anEntry.isEncrypted then
            begin
              Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'ZIP: ENCRYPTED', ''); { Reason }
            end;
          end;
        end;

        // --------------------------------------------------------------
        // Zip - Node Text
        // --------------------------------------------------------------
        if gbl_Continue and gchb_zip then
        begin
          if (UpperCase(determined_sig_str) = 'ZIP') or (UpperCase(determined_sig_str) = 'ZIP (ENCRYPTED)') then
          begin
            if aReader.OpenData(anEntry) then
            begin
              aPropertyTree := nil;
              if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
              begin
                try
                  aRootProperty := aPropertyTree.RootProperty;
                  if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
                  begin
                    aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Encrypted')); // noslz
                    if assigned(aParentNode) then
                    begin
                      if gbl_Continue and ((UpperCase(determined_sig_str) = 'ZIP') or (UpperCase(determined_sig_str) = 'ZIP (ENCRYPTED)')) then
                        Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'ZIP NODE ENCRYPTED', ''); { Reason }
                    end;
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
        end;

        file_entropy_extd := CalculateEntropy(anEntry);

        // ------------------------------------------------------------------
        // Other Archives - If aEntry reaches this point then calculate and test entropy
        // ------------------------------------------------------------------
        if gbl_Continue then
        begin
          if file_entropy_extd > ghigh_entropy_dbl then
          begin
            gHighEntropy_TList.Add(anEntry);
          end;
        end;

      end;
    end;
  end;
end;

// -----------------------------------------------------------------------------
// Process - iTunes Backups
// -----------------------------------------------------------------------------
procedure ProcessItunesBackups(anEntry: TEntry; aReader: TEntryReader);
var
  aParentNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aRootProperty: TPropertyNode;
  ChildEntry: TEntry;
  DataStore_FS: TDataStore;
  DeterminedFileDriverInfo: TFileTypeInformation;
  determined_sig_str: string;
  iTunesBackup_Children_TList: TList;
  s: integer;
  TaskProgress: TPAC;
  Temp_TList: TList;

begin
  if gbl_Continue and gchb_itn and (anEntry.EntryName = 'Manifest.plist') then // noslz
  begin
    DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
    if not assigned(DataStore_FS) then
      Exit;
    try
      DetermineFileType(anEntry);
      DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
      determined_sig_str := DeterminedFileDriverInfo.ShortDisplayname;
      if aReader.OpenData(anEntry) then
      begin
        aPropertyTree := nil;
        if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
        begin
          try
            aRootProperty := aPropertyTree.RootProperty;
            if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
            begin
              aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('isEncrypted')); // noslz
              if assigned(aParentNode) then
              begin
                if aParentNode.PropValue = True then
                begin
                  CalculateEntropy(anEntry);
                  if (UpperCase(determined_sig_str) = 'PLIST (BINARY)') then // noslz
                  begin
                    Add_To_Encrypted_StringList(anEntry.ParentEntry, gResult_EncFiles_StringList, 'ITN: PLIST', ''); { Reason }
                    iTunesBackup_Children_TList := DataStore_FS.Children(anEntry.ParentEntry);
                    Temp_TList := TList.Create;
                    try
                      for s := 0 to iTunesBackup_Children_TList.Count - 1 do
                      begin
                        if not Progress.isRunning then
                          break;
                        ChildEntry := TEntry(iTunesBackup_Children_TList[s]);
                        if UpperCase(ChildEntry.EntryName) = 'MANIFEST.MBDB' then // noslz
                        begin
                          Temp_TList.Add(ChildEntry);
                        end;
                      end;

                      if assigned(Temp_TList) and (Temp_TList.Count > 0) then
                      begin
                        TaskProgress := Progress.NewChild;
                        RunTask('TCommandTask_AppleBackup', DATASTORE_FILESYSTEM, Temp_TList, TaskProgress); // noslz
                        while Not TaskProgress.IsFinished do
                        begin
                          Sleep(500);
                        end;
                        Progress.DisplayTitle := SCRIPT_NAME; // Refresh the title

                        for s := 0 to iTunesBackup_Children_TList.Count - 1 do
                        begin
                          if not Progress.isRunning then
                            break;
                          ChildEntry := TEntry(iTunesBackup_Children_TList[s]);
                          if ChildEntry.isEncrypted then
                          begin
                            Add_To_Encrypted_StringList(ChildEntry, gResult_EncFiles_StringList, 'ITN: ENCRYPTED', ''); { Reason }
                            gbl_Continue := False;
                          end;
                        end;

                      end;
                    finally
                      Temp_TList.free;
                      iTunesBackup_Children_TList.free;
                    end;
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
          end;
        end;
      end;
    finally
      DataStore_FS.free;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Process - ODT
// ------------------------------------------------------------------------------
procedure ProcessODT(anEntry: TEntry; aStringList: TStringList; aReader: TEntryReader; FSDataStore: TDataStore);
var
  anExpandedFileList: TList;
  aNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  cEntry: TEntry;
  i: integer;
  TaskProgress: TPAC;

begin
  DetermineFileType(anEntry);
  // ODT - isEncrypted ---------------------------------------------------------
  if gbl_Continue then
  begin
    if (UpperCase(anEntry.FileDriverInfo.ShortDisplayname) = 'ODT (ENCRYPTED)') then
    begin
      if anEntry.isEncrypted then
      begin
        Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'ODT: ENCRYPTED', ''); { Reason }
        Exit;
      end;
    end;
  end;

  // ODT - BlowFish ------------------------------------------------------------
  anExpandedFileList := TList.Create;
  try
    if anEntry.isExpanded then
      anExpandedFileList := FSDataStore.Children(anEntry, True)
    else
    begin
      TaskProgress := NewProgress(False);
      ExtractCompoundFile(anEntry, anExpandedFileList, TaskProgress);
    end;
    if assigned(anExpandedFileList) and (anExpandedFileList.Count > 0) then
    begin
      SignatureAnalysis(anExpandedFileList, False);
      for i := 0 to anExpandedFileList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        cEntry := TEntry(anExpandedFileList.items[i]);
        if UpperCase(cEntry.EntryName) = 'MANIFEST.XML' then // noslz
        begin
          if aReader.OpenData(cEntry) then
          begin
            aPropertyTree := nil;
            if ProcessMetadataProperties(cEntry, aPropertyTree, aReader) then
            begin
              if assigned(aPropertyTree) then
              begin
                aNode := aPropertyTree.RootProperty;
                if assigned(aNode) and assigned(aNode.PropChildList) and (aNode.PropChildList.Count > 0) then
                begin
                  gbl_blowfish := False;
                  nodefrog(aNode, 0);
                  if gbl_blowfish then
                  begin
                    Add_To_Encrypted_StringList(anEntry, aStringList, 'ODT: BLOWFISH', ''); { Reason }
                  end;
                end;
              end;
            end;
            if aPropertyTree <> nil then
              aPropertyTree.free;
          end;
        end;
      end;
    end;
  finally
    anExpandedFileList.free;
  end;
end;

procedure PrintHeader;
begin
  if SHOW_REASON_BL then
  begin
    ProgressLogMemo(SPACE + format(FORMAT_STR2, ['Count', 'Bates', 'Entropy', 'Reason', 'File Name']));
    ProgressLogMemo(SPACE + format(FORMAT_STR2, ['-----', '-----', '-------', '------', '---------']));
  end
  else
  begin
    ProgressLogMemo(SPACE + format(FORMAT_STR1, ['Count', 'Bates', 'Entropy', 'File Name']));
    ProgressLogMemo(SPACE + format(FORMAT_STR1, ['-----', '-----', '-------', '---------']));
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: MainProc
// ------------------------------------------------------------------------------
procedure MainProc;
var
  anEntry: TEntry;
  arcEntry: TEntry;
  aReader: TEntryReader;
  DataStore_FS: TDataStore;
  entropy_str: string;
  fEntry: TEntry;
  file_ext: string;
  FilesAll_TList: TList;
  Final_StringList: TStringList;
  found_count_str: string;
  highEntry: TEntry;
  i: integer;
  script_path_str: string;
  start_tick_encinarc: uint64;
  start_tick_mainproc: uint64;
  Temp_TList: TList;
  total_entries_int: integer;
  u: integer;
  upper_shortdisplayname_str: string;

  bts_str: string;
  rsn_str: string;
  ent_str: string;
  pth_str: string;
  extra_str: string;

  // ------------------------------------------------------------------------------
  // Start of MainProc
  // ------------------------------------------------------------------------------
begin
  start_tick_mainproc := GetTickCount64;
  found_count_str := '0';
  u := 0;

  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(DataStore_FS) then
  begin
    Progress.Log('Not assigned datastore.' + SPACE + TSWT);
    Exit;
  end;

  anEntry := DataStore_FS.First;
  if not assigned(anEntry) then
  begin
    DataStore_FS.free;
    Progress.Log('No current case.' + SPACE + TSWT);
    Exit;
  end;

  try
    aReader := TEntryReader.Create;
    try
      total_entries_int := DataStore_FS.Count;
      script_path_str := CmdLine.Path;
      gFieldEntropy := AddMetaDataField('Entropy', ftExtended);

      // Progress
      Progress.Log(SCRIPT_NAME + ' starting' + RUNNING);
      Progress.Initialize(DataStore_FS.Count, SCRIPT_NAME + ' starting' + RUNNING);
      Progress.CurrentPosition := 1;
      Progress.Max := DataStore_FS.Count;

      // CLI
      gchb_7zp := True;
      gchb_rem := True;
      gchb_itn := True;
      gchb_ntfs := True;
      gchb_doc := True;
      gchb_xml := True;
      gchb_odt := True;
      gchb_pdf := True;
      gchb_rar := True;
      gchb_zip := True;
      gchb_enc_in_enc := True;

      // ==========================================================================
      // Log Results
      // ==========================================================================
      ProgressLogMemo('');
      ProgressLogMemo(RPad('7Zip:', RPAD_VALUE) + booltostr(gchb_7zp, True));
      ProgressLogMemo(RPad('Blackberry REM:', RPAD_VALUE) + booltostr(gchb_rem, True));
      ProgressLogMemo(RPad('iTunes Backup:', RPAD_VALUE) + booltostr(gchb_itn, True));
      ProgressLogMemo(RPad('Other NTFS:', RPAD_VALUE) + booltostr(gchb_ntfs, True));
      ProgressLogMemo(RPad('Office OLE:', RPAD_VALUE) + booltostr(gchb_doc, True));
      ProgressLogMemo(RPad('Office XML:', RPAD_VALUE) + booltostr(gchb_xml, True));
      ProgressLogMemo(RPad('OpenOffice:', RPAD_VALUE) + booltostr(gchb_odt, True));
      ProgressLogMemo(RPad('PDF:', RPAD_VALUE) + booltostr(gchb_pdf, True));
      ProgressLogMemo(RPad('RAR:', RPAD_VALUE) + booltostr(gchb_rar, True));
      ProgressLogMemo(RPad('Zip:', RPAD_VALUE) + booltostr(gchb_zip, True));
      ProgressLogMemo(RPad('Search in Archives:', RPAD_VALUE) + booltostr(gchb_enc_in_enc, True));
      ProgressLogMemo(StringOfChar('-', 80));

      // --------------------------------------------------------------------------
      // Signature Analysis of All Files
      // --------------------------------------------------------------------------
      FilesAll_TList := TList.Create;
      try
        FilesAll_TList := DataStore_FS.GetEntireList;
        SignatureAnalysis(FilesAll_TList, True);
      finally
        FilesAll_TList.free;
      end;

      // Use a single reader for speed purposes
      anEntry := DataStore_FS.First;
      while assigned(anEntry) and Progress.isRunning do
      begin
        inc(u);
        gbl_Continue := True;

        // Skip small files
        if anEntry.PhysicalSize < 500 then
        begin
          anEntry := DataStore_FS.Next;
          Progress.IncCurrentprogress;
          Continue;
        end;

        // Exclude these file types
        file_ext := UpperCase(anEntry.EntryNameExt);
        if (file_ext = '.ACCDT') or (file_ext = '.CAB') or (file_ext = '.EFTX') or (file_ext = '.GLOX') or (file_ext = '.GZ') or (file_ext = '.IPA') or (file_ext = '.JAR') or (file_ext = '.MSHC') or (file_ext = '.THMX') or
          (file_ext = '.XLT') or (file_ext = '.XAP') then
        begin
          anEntry := DataStore_FS.Next;
          Progress.IncCurrentprogress;
          Continue;
          Progress.Log('Skipped: ' + anEntry.EntryName);
        end;

        // ----------------------------------------------------------------------
        // Archives (7Zip, Rar, Zip)
        // ----------------------------------------------------------------------
        if gbl_Continue and (gchb_7zp or gchb_rar or gchb_zip) then
        begin
          if dtArchive in anEntry.FileDriverInfo.DriverType then
            ProcessArchive(anEntry, aReader, DataStore_FS);
        end;

        // ----------------------------------------------------------------------
        // Blackberry REM (these files are always encrypted)
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_rem then
        begin
          if (UpperCase(anEntry.EntryNameExt) = '.REM') then
          begin
            Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'REM: SIGNATURE', ''); { Reason }
          end;
        end;

        // ----------------------------------------------------------------------
        // Documents - DOC, PPT, XLS
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_doc then
        begin
          upper_shortdisplayname_str := UpperCase(anEntry.FileDriverInfo.ShortDisplayname);
          if RegexMatch(upper_shortdisplayname_str, '^(WORD|POWERPOINT|EXCEL)$', False) or // noslz
            (upper_shortdisplayname_str = STR_UPP_WORD_ENCRYPTED) or (upper_shortdisplayname_str = STR_UPP_EXCEL_ENCRYPTED) or (upper_shortdisplayname_str = STR_UPP_POWERPOINT_ENCRYPTED) then
          begin
            DetermineFileType(anEntry);
            if (upper_shortdisplayname_str = STR_UPP_WORD_ENCRYPTED) or (upper_shortdisplayname_str = STR_UPP_EXCEL_ENCRYPTED) or (upper_shortdisplayname_str = STR_UPP_POWERPOINT_ENCRYPTED) then
            begin
              if anEntry.isEncrypted then
              begin
                Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'OLE: ENCRYPTED', ''); { Reason }
              end;
            end;
          end;
        end;

        // ------------------------------------------------------------------------
        // Documents - DOCX, PPTX, XLSX
        // ------------------------------------------------------------------------
        if gbl_Continue and gchb_xml then
        begin
          upper_shortdisplayname_str := UpperCase(anEntry.FileDriverInfo.ShortDisplayname);
          if (upper_shortdisplayname_str = 'XLSX') or (upper_shortdisplayname_str = 'DOCX') or (upper_shortdisplayname_str = 'PPTX') or (upper_shortdisplayname_str = STR_UPP_MS_ENCRYPTED) then
          begin
            DetermineFileType(anEntry);
            if gchb_xml and anEntry.isEncrypted then
            begin
              Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'XML: ENCRYPTED', ''); { Reason }
            end;
          end;
        end;

        // ----------------------------------------------------------------------
        // iTunes Backup
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_itn then
        begin
          if anEntry.EntryName = 'Manifest.plist' then // noslz
            ProcessItunesBackups(anEntry, aReader);
        end;

        // ----------------------------------------------------------------------
        // ODT
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_odt and ((UpperCase(anEntry.FileDriverInfo.ShortDisplayname) = 'ODT') or (UpperCase(anEntry.FileDriverInfo.ShortDisplayname) = 'ODT (ENCRYPTED)')) then // noslz
        begin
          ProcessODT(anEntry, gResult_EncFiles_StringList, aReader, DataStore_FS);
        end;

        // ----------------------------------------------------------------------
        // PDF
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_pdf and (UpperCase(anEntry.FileDriverInfo.ShortDisplayname) = 'PDF (ENCRYPTED)') then // noslz
        begin
          Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'PDF: ENCRYPTED', ''); { Reason }
        end;

        // ----------------------------------------------------------------------
        // isEncrypted - Other
        // ----------------------------------------------------------------------
        if gbl_Continue and gchb_ntfs then
        begin
          upper_shortdisplayname_str := UpperCase(anEntry.FileDriverInfo.ShortDisplayname);
          if anEntry.isEncrypted then
          begin
            Add_To_Encrypted_StringList(anEntry, gResult_EncFiles_StringList, 'OTH: ENCRYPTED', ''); { Reason }
          end;
        end;

        found_count_str := IntToStr(gResult_EncFiles_StringList.Count);

        Progress.DisplayMessages := found_count_str + SPACE + ENCRYPTED_FILES_STR + SPACE + '(' + IntToStr(u) + '/' + IntToStr(total_entries_int) + ')' + RUNNING;
        anEntry := DataStore_FS.Next;
        Progress.IncCurrentprogress;
      end;

      // ------------------------------------------------------------------------
      // Encrypted in Archives
      // ------------------------------------------------------------------------
      if gchb_enc_in_enc and assigned(garchive_StringList) then
      begin
        start_tick_encinarc := GetTickCount64;
        // ----------------------------------------------------------------------
        // Collect 7z, RAR, ZIP Archive Files in Separate Loop
        // ----------------------------------------------------------------------
        arcEntry := DataStore_FS.First;
        Progress.Initialize(DataStore_FS.Count, 'Finding 7zip, Rar, Zip' + RUNNING);
        while assigned(arcEntry) and (Progress.isRunning) do
        begin
          if (arcEntry.FileDriverInfo.ShortDisplayname = 'Zip') or (arcEntry.FileDriverInfo.ShortDisplayname = '7zip') or (arcEntry.FileDriverInfo.ShortDisplayname = 'Rar') then
          begin
            if not RegexMatch(arcEntry.Extension, EXCLUDE_ARCHIVE_REGEX_STR, False) then
            begin
              garchive_StringList.AddObject(arcEntry.FullPathName, arcEntry);
            end;
          end;
          Progress.IncCurrentprogress;
          arcEntry := DataStore_FS.Next;
        end;
        // ProgressLogMemo(RPad('Archives Found:', RPAD_VALUE) + IntToStr(gArchive_StringList.Count) + SPACE + '(7Zip, RAR, Zip)');

        // ----------------------------------------------------------------------
        // Work with collected Archive files
        // ----------------------------------------------------------------------
        if assigned(garchive_StringList) and (garchive_StringList.Count > 0) then
        begin
          Temp_TList := TList.Create;
          Final_StringList := TStringList.Create;
          gCollection_StringList := TStringList.Create;
          try
            // Check archives for encryption
            Encrypted_In_Archives(garchive_StringList, Final_StringList);

            // Add the Final files to the Encrypted StringList
            if (Final_StringList.Count > 0) and assigned(gResult_EncInArchive_StringList) then
            begin
              for i := 0 to Final_StringList.Count - 1 do
              begin
                if not Progress.isRunning then
                  break;
                fEntry := TEntry(Final_StringList.Objects[i]);
                Add_To_Encrypted_StringList(fEntry, gResult_EncInArchive_StringList, 'ARC: INARCHIVE', Final_StringList[i]); { Reason Archive - In Archive }
              end;
              gtotal_entries_int := gtotal_entries_int + gResult_EncInArchive_StringList.Count;
            end;

          finally
            Final_StringList.free;
            gCollection_StringList.free;
            Temp_TList.free;
          end;
        end;
      end;

    finally
      aReader.free;
    end;
  finally
    DataStore_FS.free;
  end;

  // Encrypted Files =========================================================
  if assigned(gResult_EncFiles_StringList) and (gResult_EncFiles_StringList.Count > 0) then
  begin
    ProgressLogMemo('');
    ProgressLogMemo('Encrypted files (or contain encrypted files):');
    ProgressLogMemo('');
    PrintHeader;

    gResult_EncFiles_StringList.CustomSort(SortBatesStringList);
    for i := 0 to (gResult_EncFiles_StringList.Count) - 1 do
    begin
      if gResult_EncFiles_StringList.Objects[i] <> nil then
      begin
        bts_str := gResult_EncFiles_StringList[i];
        rsn_str := (Item_Record(gResult_EncFiles_StringList.Objects[i]).Rec_Reason_str);
        ent_str := (Item_Record(gResult_EncFiles_StringList.Objects[i]).Rec_Entropy_str);
        extra_str := (Item_Record(gResult_EncFiles_StringList.Objects[i]).Rec_Extra_str);
        if extra_str <> '' then
          pth_str := extra_str
        else
          pth_str := (Item_Record(gResult_EncFiles_StringList.Objects[i]).Rec_FilePath_str);
        if SHOW_REASON_BL then
          ProgressLogMemo(SPACE + format(FORMAT_STR2, [IntToStr(i + 1) + '.', bts_str, ent_str, rsn_str, pth_str]))
        else
          ProgressLogMemo(SPACE + format(FORMAT_STR1, [IntToStr(i + 1) + '.', bts_str, ent_str, pth_str]));
      end;
    end;
  end;

  // Encrypted in Archive ====================================================
  if assigned(gResult_EncInArchive_StringList) and (gResult_EncInArchive_StringList.Count > 0) then
  begin
    ProgressLogMemo('');
    ProgressLogMemo('Encrypted in Archives (7zip, RAR, ZIP):');
    ProgressLogMemo('');
    PrintHeader;
    gResult_EncFiles_StringList.CustomSort(SortBatesStringList);

    for i := 0 to (gResult_EncInArchive_StringList.Count) - 1 do
    begin
      if gResult_EncInArchive_StringList.Objects[i] <> nil then
      begin
        bts_str := gResult_EncInArchive_StringList[i];
        rsn_str := (Item_Record(gResult_EncInArchive_StringList.Objects[i]).Rec_Reason_str);
        ent_str := (Item_Record(gResult_EncInArchive_StringList.Objects[i]).Rec_Entropy_str);
        extra_str := (Item_Record(gResult_EncInArchive_StringList.Objects[i]).Rec_Extra_str);
        if extra_str <> '' then
          pth_str := extra_str
        else
          pth_str := (Item_Record(gResult_EncInArchive_StringList.Objects[i]).Rec_FilePath_str);
        if SHOW_REASON_BL then
          ProgressLogMemo(SPACE + format(FORMAT_STR2, [IntToStr(i + 1) + '.', bts_str, ent_str, rsn_str, pth_str]))
        else
          ProgressLogMemo(SPACE + format(FORMAT_STR1, [IntToStr(i + 1) + '.', bts_str, ent_str, pth_str]));
      end;
    end;
  end;

  // High Entropy ============================================================
  if assigned(gHighEntropy_TList) and (gHighEntropy_TList.Count > 0) then
  begin
    gHighEntropy_TList.sort(@SortBatesTList);
    for i := 0 to gHighEntropy_TList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      highEntry := TEntry(gHighEntropy_TList[i]);
      entropy_str := gFieldEntropy.asString[highEntry];
      if assigned(gHighEntropy_StringList) then
        gHighEntropy_StringList.Add(format(FORMAT_STR2, [IntToStr(i + 1) + '.', IntToStr(highEntry.ID), entropy_str, 'HIGH ENTROPY', highEntry.FullPathName]));
    end;
    gtotal_entries_int := gtotal_entries_int + gHighEntropy_TList.Count;
  end;

  // Put into a StringList for sorting purposes
  if assigned(gHighEntropy_StringList) and (gHighEntropy_StringList.Count > 0) then
  begin
    ProgressLogMemo('');
    ProgressLogMemo(StringOfChar('-', 80));
    ProgressLogMemo('');
    ProgressLogMemo('High entropy ' + SPACE + '(>=' + FloatToStr(ghigh_entropy_dbl) + ').' + SPACE + 'Test for encryption:');
    ProgressLogMemo('');
    PrintHeader;
    for i := 0 to (gHighEntropy_StringList.Count) - 1 do
      ProgressLogMemo(SPACE + gHighEntropy_StringList[i]);
  end;

  gtotal_entries_int := gtotal_entries_int + gResult_EncFiles_StringList.Count;

  ProgressLogMemo('');
  ProgressLogMemo(StringOfChar('-', 80));

  BookmarkResults;

  if REPORT_TIME_TAKEN_BL then
    ProgressLogMemo(CalcTimeTaken(start_tick_mainproc, ''));

  // Cli Reporting
  gbl_Export_Results := True;
  CreateRunTimePDF(gMemo_StringList, 'Encrypted Files', 8, True); // StringList, Name, Font Size, DTinHeader
end;

procedure Encrypted_In_Archives(Received_TStringList: TStringList; FinStringList: TStringList);
var
  arcEntry: TEntry;
  collectEntry: TEntry;
  extractEntry: TEntry;
  Extraction_StringList: TStringList;
  Extraction_TList: TList;
  fileext: string;
  i, j, s: integer;
  mytemp_StringList: TStringList;
  TaskProgress: TPAC;
begin
  Extraction_TList := TList.Create;
  Extraction_StringList := TStringList.Create;
  mytemp_StringList := TStringList.Create;
  try
    // Receives a list of archive files
    Progress.Initialize(Received_TStringList.Count, 'Processing Archive Files' + RUNNING);
    for i := 0 to Received_TStringList.Count - 1 do
    begin
      Progress.IncCurrentprogress;
      if not Progress.isRunning then
        break;
      arcEntry := TEntry(Received_TStringList.Objects[i]);
      TaskProgress := NewProgress(False);

      // Extract each archive into the Extraction TList
      Extraction_TList.Clear;
      Extraction_StringList.Clear;
      ExtractCompoundFile(arcEntry, Extraction_TList, TaskProgress);
      // Perform the signature analysis on the extraction to identify the encrypted files
      SignatureAnalysis(Extraction_TList, False);

      // Go thorough the extraction TList
      for j := 0 to Extraction_TList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        extractEntry := TEntry(Extraction_TList[j]);
        fileext := extractfileext(UpperCase(extractEntry.EntryName));

        // Put into an Extraction StringList so that the path can be kept
        Extraction_StringList.AddObject(Received_TStringList[i] + BS + extractEntry.EntryName, extractEntry);

        // If any of the extracted files are 7zip, RAR, or Zip then add to a temp StringList
        if (extractEntry.FileDriverInfo.ShortDisplayname = 'Zip') or (extractEntry.FileDriverInfo.ShortDisplayname = '7zip') or (extractEntry.FileDriverInfo.ShortDisplayname = 'Rar') then
        begin
          if not RegexMatch(fileext, EXCLUDE_ARCHIVE_REGEX_STR, False) then
            mytemp_StringList.AddObject(Received_TStringList[i] + BS + extractEntry.EntryName, extractEntry);
        end;
      end;

      // Add the extraction to the collection StringList
      for s := 0 to Extraction_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        gCollection_StringList.AddObject(Extraction_StringList[s], TEntry(Extraction_StringList.Objects[s]));
      end;
    end;

    // Clear the existing received StringList
    Received_TStringList.Clear;

    // Add the temp files to a new Received StringList
    for i := 0 to mytemp_StringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      Received_TStringList.AddObject(mytemp_StringList[i], mytemp_StringList.Objects[i]);
    end;

    mytemp_StringList.Clear;

    // Repeat the collection
    if Received_TStringList.Count > 0 then
    begin
      Encrypted_In_Archives(Received_TStringList, FinStringList);
    end;

    // Now test the collect everything for encryption and add to the finish list
    for i := 0 to gCollection_StringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      collectEntry := TEntry(gCollection_StringList.Objects[i]);
      if assigned(collectEntry) then
      begin
        if collectEntry.isEncrypted then
        begin
          FinStringList.AddObject(gCollection_StringList[i], collectEntry);
        end;
      end;
    end;

  finally
    mytemp_StringList.free;
    Extraction_StringList.free;
    Extraction_TList.free;
  end;
end;

// ==============================================================================
// Start of the Script
// ==============================================================================
begin
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessageNow := ('Starting' + RUNNING);
  Progress.Log(SCRIPT_NAME + SPACE + 'started' + RUNNING);
  ghigh_entropy_dbl := 0.9985;

  garchive_StringList := TStringList.Create;
  gHighEntropy_StringList := TStringList.Create;
  gHighEntropy_TList := TList.Create;
  gMemo_StringList := TStringList.Create;

  gResult_EncFiles_StringList := TStringList.Create;
  gResult_EncFiles_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
  gResult_EncFiles_StringList.Duplicates := dupIgnore;

  gResult_EncInArchive_StringList := TStringList.Create;
  gResult_EncInArchive_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
  gResult_EncInArchive_StringList.Duplicates := dupIgnore;

  try
    MainProc;
  finally
    garchive_StringList.free;
    gHighEntropy_StringList.free;
    gHighEntropy_TList.free;
    gMemo_StringList.free;
    gResult_EncFiles_StringList.free;
    gResult_EncInArchive_StringList.free;
  end;

  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');
  Progress.DisplayMessageNow := ('Processing complete.');

end.
