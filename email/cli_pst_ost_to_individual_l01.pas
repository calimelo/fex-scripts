unit PST_OST_to_Individual_L01;

interface

uses
  // GUI, Modules,
  Classes, Common, DataEntry, DataStorage, DateUtils, DIRegex, Graphics,
  Math, Regex, SysUtils, NoteEntry, Variants;

const
  RPAD_VALUE = 31;
  RUNNING = '...';
  SCRIPT_NAME = 'PST + OST to individual L01';
  SPACE = ' ';

var
  gcount_int: integer;

function GetSizeStr(asize: int64): string;
function GetUniqueFileName(AFileName: string): string;
function RPad(const AString: string; AChars: integer): string;
procedure ExportTListToL01(eTList: TList; l01_name_str: string);

implementation

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

function GetSizeStr(asize: int64): string;
begin
  if asize >= 1073741824 then
    Result := (Format('%1.2n GB', [asize / (1024 * 1024 * 1024)]))
  else if (asize < 1073741824) and (asize > 1048576) then
    Result := (Format('%1.2n MB', [asize / (1024 * 1024)]))
  else if asize < 1048576 then
    Result := (Format('%1.0n KB', [asize / (1024)]));
end;

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

procedure ExportTListToL01(eTList: TList; l01_name_str: string);
var
  count_str: string;
  eEntry: TEntry;
  TaskProgress: TPAC;
  save_fullpath_str: string;
begin
  if assigned(eTList) and (eTList.Count = 1) then
  begin
    eEntry := TEntry(eTList[0]);

    if assigned(eEntry) then
    begin
      save_fullpath_str := GetExportedDir + eEntry.SaveName + '.L01';
      if FileExists(save_fullpath_str) then
      begin
        save_fullpath_str := GetUniqueFileName(save_fullpath_str);
      end;
      Progress.Log(Format('%-30s %-50s', ['Exporting to L01:', ExtractFileName(save_fullpath_str)]));
      if Progress.isRunning then
      begin
        TaskProgress := Progress.NewChild; // TaskProgress := NewProgress(True);
        inc(gcount_int);
        count_str := IntToStr(gcount_int);
        RunTask('TCommandTask_ExportFilesL01', DATASTORE_FILESYSTEM, eTList, TaskProgress, ['filename=' + save_fullpath_str, 'segmentsize=5000']);

        // //<task classname="TCommandTask_ExportFilesL01"
        // //caption="Export L01"
        // //description=""
        // //enabled="true"
        // //filename="%CASE_PATH%Exported\CLI_Export.L01"
        // //segmentsize="2000"
        // //md5hash="true"
        // //sha1hash="false"
        // //sha256hash="false"
        // //compression="1"
        // //dirdata="false"
        // //examiner="Investigator"
        // //caseno="CLI Export"
        // //desc=" CLI Export"
        // //evidno=""
        // //notes="L01 Created by Forensic Explorer CLI"/>
        //
        while (TaskProgress.isRunning) and (Progress.isRunning) do
          Sleep(500); // Do not proceed until TCommandTask is complete
        if not(Progress.isRunning) then
          TaskProgress.Cancel;
      end;
    end;
  end
  else
  begin
    Progress.Log('No files found.');
  end;
end;

// ------------------------------------------------------------------------------
// Start of Script
// ------------------------------------------------------------------------------
var
  anEntry: TEntry;
  DataStore_FS: TDataStore;
  determined_file_driver: TFileTypeInformation;
  i: integer;
  mail_TList: TList;
  mEntry: TEntry;
  save_name_str: string;
  short_dispaly_sig_str: string;
  temp_TList: TList;

begin
  gcount_int := 0;
  Progress.Log('Starting' + RUNNING);
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(DataStore_FS) then
  begin
    Progress.Log('Not assigned a data store. The script will terminate.');
    Exit;
  end;

  try
    Progress.Initialize(DataStore_FS.Count, 'Processing' + RUNNING);

    anEntry := DataStore_FS.First;
    if not assigned(anEntry) then
      Exit;

    mail_TList := TList.Create;
    try
      // Collect PST/OST files by extension
      while assigned(anEntry) and (Progress.isRunning) do
      begin
        if (anEntry.LogicalSize > 0) then
        begin
          if RegexMatch(anEntry.Extension, '^\.(PST|OST)$', false) then
          begin
            // Test the signature
            DetermineFileType(anEntry);
            determined_file_driver := anEntry.DeterminedFileDriverInfo;
            short_dispaly_sig_str := determined_file_driver.ShortDisplayName;
            if RegexMatch(short_dispaly_sig_str, 'PST|OST', false) then
            begin
              Progress.Log(Format('%-30s %-50s %-20s', ['Found Email File:', anEntry.EntryName, '(' + GetSizeStr(anEntry.LogicalSize) + ')']));
              mail_TList.Add(anEntry);
            end
            else
              Progress.Log(Format('%-30s %-50s %-20s', ['Invalid File' + SPACE + '(' + short_dispaly_sig_str + ')', anEntry.EntryName, '(' + GetSizeStr(anEntry.LogicalSize) + ')']));
          end;
        end;
        Progress.IncCurrentProgress;
        anEntry := DataStore_FS.Next;
      end;

      Progress.Log(RPad('Email File Count:', RPAD_VALUE) + IntToStr(mail_TList.Count));
      Progress.Log(StringOfChar('-', 80));

      // Write each email file to a separate L01
      if assigned(mail_TList) and (mail_TList.Count > 0) then
      begin
        for i := 0 to mail_TList.Count - 1 do
        begin
          mEntry := TEntry(mail_TList[i]);
          if assigned(mEntry) then
          begin
            temp_TList := TList.Create;
            try
              temp_TList.Add(mEntry);
              save_name_str := mEntry.SaveName;
              ExportTListToL01(temp_TList, save_name_str);
            finally
              temp_TList.free;
            end;
          end;
        end;
      end;

    finally
      mail_TList.free;
    end;
  finally
    DataStore_FS.free;
  end;
  Progress.Log(StringOfChar('-', 80));
  Progress.Log('Script finished.');

end.
