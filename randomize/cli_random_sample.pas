unit Random_Sample;

interface

uses
  Classes, Common, DataEntry, DataStorage, Graphics, Math, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  CHAR_LENGTH = 80;
  HYPHEN = ' - ';
  RPAD_VALUE = 40;
  RUNNING = '...';
  SCRIPT_NAME = 'Random Sample';
  SPACE = ' ';
  TSWT = 'The script will terminate.';

  HASHSET_1 = '1.md5';
  HASHSET_2 = '2.md5';
  HASHSET_3 = '3.md5';
  HASHSET_4 = '4.md5';
  HASHSET_NSRL = 'nsrl.md5';

var
  gRunTimeReport_StringList: TStringList;
  gHashset1_str: string;
  gHashset2_str: string;
  gHashset3_str: string;
  gHashset4_str: string;
  gHashset_nsrl_str: string;
  gField_Classification: TDataStoreField;
  gField_HashSet: TDataStoreField;

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

// ------------------------------------------------------------------------------
// Procedure: Create RunTime Report (PDF or TXT)
// ------------------------------------------------------------------------------
procedure CreateRunTimeReport(aStringList: TStringList; save_name_str: string; DT_In_FileName_bl: boolean; pdf_or_txt_str: string);
const
  HYPHEN = ' - ';
  PDF_FONT_SIZE = 8;
var
  CurrentCaseDir: string;
  ExportDate: string;
  ExportDateTime: string;
  ExportedDir: string;
  ExportTime: string;
  Ext_str: string;
  SaveName: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\'; // '\Run Time Reports\';
  ExportDate := formatdatetime('yyyy-mm-dd', now);
  ExportTime := formatdatetime('hh-nn-ss', now);

  if UpperCase(pdf_or_txt_str) = 'PDF' then
    Ext_str := '.pdf'
  else
    Ext_str := '.txt';

  if DT_In_FileName_bl then
    ExportDateTime := (ExportDate + HYPHEN + ExportTime + HYPHEN)
  else
    ExportDateTime := '';

  SaveName := ExportedDir + ExportDateTime + save_name_str + Ext_str;
  if DirectoryExists(CurrentCaseDir) then
  begin
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        if Ext_str = '.pdf' then
        begin
          if GeneratePDF(SaveName, aStringList, PDF_FONT_SIZE) then
            Progress.Log('Success Creating: ' + SaveName);
        end
        else
        begin
          aStringList.SaveToFile(SaveName);
          Sleep(200);
          if FileExists(SaveName) then
            Progress.Log('Success Creating: ' + SaveName)
          else
            Progress.Log('Error creating runtime report: ' + SaveName);
        end;
      end
      else
        Progress.Log('Error creating runtime report: ' + SaveName);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Exception creating runtime report: ' + SaveName);
    end;
  end
  else
    Progress.Log('There is no current case folder');
end;

// ------------------------------------------------------------------------------
// Function: Extract Filename
// ------------------------------------------------------------------------------
function ExtractFileNameWithoutExt(const FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

// ------------------------------------------------------------------------------
// procedure: Categorize By HashSet
// ------------------------------------------------------------------------------
procedure CategorizeByHashSet(aTList: TList);
var
  bl_linelist_match: boolean;
  DataStore_FS: TDataStore;
  hashsetclassify_count: integer;
  HashSetField_str: string;
  i, j: integer;
  iClassified: Cardinal;
  lineList: TStringList;
  mEntry: TEntry;
begin
  if assigned(aTList) and (aTList.Count > 0) then
  begin
    hashsetclassify_count := 0;
    gHashset1_str := ExtractFileNameWithoutExt(HASHSET_1);
    gHashset2_str := ExtractFileNameWithoutExt(HASHSET_2);
    gHashset3_str := ExtractFileNameWithoutExt(HASHSET_3);
    gHashset4_str := ExtractFileNameWithoutExt(HASHSET_4);
    gHashset_nsrl_str := ExtractFileNameWithoutExt(HASHSET_NSRL);
    DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
    if assigned(DataStore_FS) and (DataStore_FS.Count > 0) then
      try
        gField_Classification := DataStore_FS.DataFields.FieldByName['CLASSIFICATION'];
        gField_HashSet := DataStore_FS.DataFields.FieldByName['HASHSET'];
        Progress.DisplayMessageNow := ('Auto Categorize' + RUNNING);
        gRunTimeReport_StringList.Add(RPad('Auto Categorize by Hash Match:', RPAD_VALUE) + IntToStr(aTList.Count));
        lineList := TStringList.Create;
        try
          for i := 0 to aTList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            mEntry := TEntry(aTList[i]);
            iClassified := gField_Classification.AsCardinal(mEntry);
            HashSetField_str := (gField_HashSet.asString(mEntry));
            lineList.CommaText := HashSetField_str;
            // If the HashSet column is not blank
            if (HashSetField_str <> '') then
            begin
              if lineList.Count > 0 then
              begin
                bl_linelist_match := False;
                for j := 0 to lineList.Count - 1 do
                begin

                  if RegexMatch(lineList[j], '^(' + gHashset1_str + ')$', True) then
                  begin
                    gField_Classification.AsCardinal(mEntry) := 1; // Classified as 1
                    bl_linelist_match := True;
                  end;

                  if RegexMatch(lineList[j], '^(' + gHashset2_str + ')$', True) then
                  begin
                    gField_Classification.AsCardinal(mEntry) := 2; // Classified as 2
                    bl_linelist_match := True;
                  end;

                  if RegexMatch(lineList[j], '^(' + gHashset3_str + ')$', True) then
                  begin
                    gField_Classification.AsCardinal(mEntry) := 3; // Classified as 3
                    bl_linelist_match := True;
                  end;

                  if RegexMatch(lineList[j], '^(' + gHashset4_str + ')$', True) then
                  begin
                    gField_Classification.AsCardinal(mEntry) := 4; // Classified as 4
                    bl_linelist_match := True;
                  end;

                  if RegexMatch(lineList[j], '^(' + gHashset_nsrl_str + ')$', True) then
                  begin
                    gField_Classification.AsCardinal(mEntry) := 4; // Classified as 4
                    bl_linelist_match := True;
                  end;

                end;

                if bl_linelist_match then
                  hashsetclassify_count := hashsetclassify_count + 1;
              end;
            end;
          end;
          gRunTimeReport_StringList.Add(RPad('Classified from HashSet match:', RPAD_VALUE) + IntToStr(hashsetclassify_count));
          gRunTimeReport_StringList.Add(StringOfChar('-', CHAR_LENGTH));
        finally
          lineList.free;
        end;
      finally
        DataStore_FS.free;
      end;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Make sure the InList and OutList exist
// ------------------------------------------------------------------------------
function ListExists(aList: TListOfEntries; ListName_str: string): boolean;
begin
  Result := False;
  if assigned(aList) then
  begin
    Progress.Log(RPad(ListName_str + SPACE + 'count:', RPAD_VALUE) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', RPAD_VALUE) + ListName_str);
end;

// ------------------------------------------------------------------------------
// Function: Calculate SEEB Sample Size
// ------------------------------------------------------------------------------
function CalculateSEEB99(apopulation_int: integer): integer;
const
  FP_NAME = 'CalcSEEB99';
  CL95 = 1.959964; // Standard deviations required for %95, %99 etc. confidence levels & adjustments.
  CL99 = 2.575829;
  CL99_5 = 2.807034;
  CL99_8 = 3.090232;
  CL99_9 = 3.290527;
  CL99_99 = 3.890592;
  ADJCL95 = 1.64485;
  ADJCL99 = 2.3263469;
  CI = 0.01288; // Confidence Interval for 1% RSE - these values are related.
  PROPORTION = 0.50; // This value is 0.5 if estimation before hand is unknown. Recommended by NSS as 0.5.
var
  confidence_interval: double;
  confidence_level: double;
  n: double;
  p: double;
  q: double;
begin
  if not Progress.isRunning then
    Exit;
  if apopulation_int = 0 then
  begin
    Result := 0;
    Exit;
  end;
  confidence_interval := CI;
  confidence_level := CL99;
  p := PROPORTION;
  q := 1.0 - PROPORTION;
  n := (p * q) / (sqr(confidence_interval) / sqr(confidence_level) + (p * q) / apopulation_int);
  Progress.Log(RPad('Population:' + SPACE + IntToStr(apopulation_int), RPAD_VALUE) + FormatFloat('0.0000000', n));
  Progress.Log(RPad(HYPHEN + 'Format:', RPAD_VALUE) + FormatFloat('0.0000', n)); // Format with decimals
  Progress.Log(RPad(HYPHEN + 'Ceil:', RPAD_VALUE) + IntToStr(ceil(n))); // Round fractions up
  Progress.Log(RPad(HYPHEN + 'Round:', RPAD_VALUE) + IntToStr(round(n))); // Rounds up/down (The rounding uses Bankers rules, where an exact half value causes a rounding to an even number).
  Progress.Log(RPad(HYPHEN + 'Trunc:', RPAD_VALUE) + IntToStr(trunc(n))); // The integer part of a floating point number
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Result := round(n);
end;

// ------------------------------------------------------------------------------
// Procedure: Select Random Sample
// ------------------------------------------------------------------------------
procedure RandomSelection(iSampleSize: integer; PopulationList: TList; SampleList: TUniqueListOfEntries);
var
  Enum: TEntryEnumerator;
  iRandom: integer;
  iSkipCount: integer;
  rEntry: TEntry;
begin
  if not Progress.isRunning then
    Exit;
  if assigned(PopulationList) and (PopulationList.Count > 0) then
  begin
    Randomize; // Set the random seed (results will be different each time)
    Progress.Max := iSampleSize;
    iSkipCount := 0;
    repeat
      if not Progress.isRunning then
        break;
      iRandom := RandomRange(0, PopulationList.Count - 1);
      rEntry := TEntry(PopulationList[iRandom]);
      PopulationList[iRandom] := nil; // Makes the entry nil for the next iteration
      if (rEntry = nil) or SampleList.Contains(rEntry) then
      begin
        inc(iSkipCount);
        if iSkipCount > 3 then
          PopulationList.Pack;
      end
      else // Only selects an entry that is not nil
      begin
        SampleList.Add(rEntry);
        Progress.IncCurrentProgress;
        // Progress.Log(format('%-20s %-20s %-50s',[IntToStr(SampleList.Count)+':', IntToStr(iRandom), rEntry.EntryName]));
      end;
    until (SampleList.Count = iSampleSize) or (PopulationList.Count = 0);
    Enum := SampleList.GetEnumerator;
    // while Enum.MoveNext do
    // begin
    // rEntry := Enum.Current;
    // Progress.Log(rEntry.EntryName);
    // end;
  end;
end;

// ==============================================================================
// The start of the script
// ==============================================================================
const
  BMFLDR_NSW_POLICE_REPORT = 'NSW Police Report';
  BMFLDR_RANDOM_SAMPLE = 'Random Sample';
  BS = '\';

var
  anEntry: TEntry;
  bm_Folder_1: TEntry;
  DeterminedFileDriverInfo: TFileTypeInformation;
  Enum: TEntryEnumerator;
  Graphics_Random_Sample_UniqueList: TUniqueListOfEntries;
  Graphics_Sample_TList: TList;
  graphics_seeb99_sample_size_int: integer;
  Graphics_TList: TList;
  i: integer;
  Video_Random_Sample_UniqueList: TUniqueListOfEntries;
  Video_Sample_TList: TList;
  video_seeb99_sample_size_int: integer;
  Video_TList: TList;

begin
  gRunTimeReport_StringList := TStringList.Create;
  try
    // ----------------------------------------------------------------------------
    // Check that InList and OutList exist and that InList is not empty
    // ----------------------------------------------------------------------------
    if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
    begin
      gRunTimeReport_StringList.Add('Error:' + SPACE + SCRIPT_NAME + SPACE + 'InList/OutList');
      try
        CreateRunTimeReport(gRunTimeReport_StringList, SCRIPT_NAME, False, 'txt');
      except
        Progress.Log(ATRY_EXCEPT_STR + SCRIPT_NAME + SPACE + 'Error creating RunTime Report');
      end;
      Exit;
    end;
    gRunTimeReport_StringList.Add(RPad('Total Graphics and Video files:', RPAD_VALUE) + IntToStr(InList.Count));
    gRunTimeReport_StringList.Add(StringOfChar('-', CHAR_LENGTH));

    // Graphics Lists
    Graphics_TList := TList.Create;
    Graphics_Random_Sample_UniqueList := TUniqueListOfEntries.Create;
    Graphics_Sample_TList := TList.Create;

    // Video Lists
    Video_TList := TList.Create;
    Video_Random_Sample_UniqueList := TUniqueListOfEntries.Create;
    Video_Sample_TList := TList.Create;

    try
      // Graphics -----------------------------------------------------------
      for i := 0 to InList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        anEntry := TEntry(InList[i]);
        DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
        if (dtGraphics in anEntry.DeterminedFileDriverInfo.DriverType) then // Only let determined graphics through to the exclusion testing
          Graphics_TList.Add(anEntry);
      end;

      // Get graphics sample size
      if assigned(Graphics_TList) and (Graphics_TList.Count > 0) then
      begin
        gRunTimeReport_StringList.Add(RPad('Graphics Only:', RPAD_VALUE) + IntToStr(Graphics_TList.Count));
        graphics_seeb99_sample_size_int := CalculateSEEB99(Graphics_TList.Count);
        gRunTimeReport_StringList.Add(RPad('Graphics SEEB sample size:', RPAD_VALUE) + IntToStr(graphics_seeb99_sample_size_int));

        // Get graphics random sample *******
        RandomSelection(graphics_seeb99_sample_size_int, Graphics_TList, Graphics_Random_Sample_UniqueList);
        gRunTimeReport_StringList.Add(RPad('Graphics random selection made:', RPAD_VALUE) + IntToStr(Graphics_Random_Sample_UniqueList.Count));

        // Move graphics random sample to TList
        if assigned(Graphics_Random_Sample_UniqueList) and (Graphics_Random_Sample_UniqueList.Count > 0) then
        begin
          Enum := Graphics_Random_Sample_UniqueList.GetEnumerator;
          while Enum.MoveNext do
          begin
            anEntry := Enum.Current;
            Graphics_Sample_TList.Add(anEntry);
          end;
        end;
        gRunTimeReport_StringList.Add(StringOfChar('-', CHAR_LENGTH));
      end;

      // Video --------------------------------------------------------------
      for i := 0 to InList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        anEntry := TEntry(InList[i]);
        DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
        if (dtVideo in anEntry.DeterminedFileDriverInfo.DriverType) then // Only let determined video through to the exclusion testing
          Video_TList.Add(anEntry);
      end;

      // Get video sample size
      if assigned(Video_TList) and (Video_TList.Count > 0) then
      begin
        gRunTimeReport_StringList.Add(RPad('Video Only:', RPAD_VALUE) + IntToStr(Video_TList.Count));
        video_seeb99_sample_size_int := CalculateSEEB99(Video_TList.Count);
        gRunTimeReport_StringList.Add(RPad('Video SEEB sample size:', RPAD_VALUE) + IntToStr(video_seeb99_sample_size_int));

        // Get video random sample *******
        RandomSelection(video_seeb99_sample_size_int, Video_TList, Video_Random_Sample_UniqueList);
        gRunTimeReport_StringList.Add(RPad('Video random selection made:', RPAD_VALUE) + IntToStr(Video_Random_Sample_UniqueList.Count));

        // Move video random sample to TList
        if assigned(Video_Random_Sample_UniqueList) and (Video_Random_Sample_UniqueList.Count > 0) then
        begin
          Enum := Video_Random_Sample_UniqueList.GetEnumerator;
          while Enum.MoveNext do
          begin
            anEntry := Enum.Current;
            Video_Sample_TList.Add(anEntry);
          end;
        end;
        gRunTimeReport_StringList.Add(StringOfChar('-', CHAR_LENGTH));
      end;

      // ----------------------------------------------------------------------
      // Join Graphics and Video Lists
      // ----------------------------------------------------------------------
      if Progress.isRunning then
      begin
        gRunTimeReport_StringList.Add('Joined Graphics and Video lists' + RUNNING);

        if assigned(Graphics_Sample_TList) and (Graphics_Sample_TList.Count > 0) then
        begin
          gRunTimeReport_StringList.Add(RPad(HYPHEN + 'Graphics: ', RPAD_VALUE) + IntToStr(Graphics_Sample_TList.Count));
          for i := 0 to Graphics_Sample_TList.Count - 1 do
          begin
            anEntry := TEntry(Graphics_Sample_TList[i]);
            OutList.Add(anEntry);
          end;
        end;

        if assigned(Video_Sample_TList) and (Video_Sample_TList.Count > 0) then
        begin
          gRunTimeReport_StringList.Add(RPad(HYPHEN + 'Video:', RPAD_VALUE) + IntToStr(Video_Sample_TList.Count));
          for i := 0 to Video_Sample_TList.Count - 1 do
          begin
            anEntry := TEntry(Video_Sample_TList[i]);
            OutList.Add(anEntry);
          end;
        end;
        gRunTimeReport_StringList.Add(StringOfChar('=', CHAR_LENGTH));
        gRunTimeReport_StringList.Add(RPad('Random Sample Graphics And Video:', RPAD_VALUE) + IntToStr(OutList.Count));
        gRunTimeReport_StringList.Add(StringOfChar('-', CHAR_LENGTH));

      end;

      // Create bookmark folder and bookmark folder comment used in the report
      bm_Folder_1 := FindBookmarkByName(BMFLDR_NSW_POLICE_REPORT + BS + BMFLDR_RANDOM_SAMPLE);
      if not assigned(bm_Folder_1) then
      begin
        bm_Folder_1 := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), (BMFLDR_NSW_POLICE_REPORT + BS + BMFLDR_RANDOM_SAMPLE), (gRunTimeReport_StringList.Text));
      end;

      // Create RunTime Report
      CreateRunTimeReport(gRunTimeReport_StringList, SCRIPT_NAME, False, 'txt');

    finally
      Graphics_Random_Sample_UniqueList.free;
      Graphics_Sample_TList.free;
      Graphics_TList.free;
      Video_Random_Sample_UniqueList.free;
      Video_Sample_TList.free;
      Video_TList.free;
    end;

  finally
    gRunTimeReport_StringList.free;
  end;

end.
