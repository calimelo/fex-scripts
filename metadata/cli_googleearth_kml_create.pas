{ !NAME:      cli_GoogleEarth_KML_Create.pas }
{ !DESC:      Create a GoogleEarth KML file using metadata extracted from
  digital camera photos. Plot the location of those photos on the
  GoogleEarth map. }
{ !AUTHOR:    GetData }

unit GoogleEarth_KML_Create;

interface

uses
  Classes, Common, DataEntry, DataStorage, DataStreams, DateUtils, Graphics, Math, PropertyList, RegEx, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz

  // ==============================================================================
  // THESE METADATA NODE VALUES ARE TO REMAIN IN ENGLISH - DO NOT TRANSLATE
  // ==============================================================================
  // Set the Metadata Node Names
  ROOT_ENTRY_EXIF = 'Marker E1 (Exif)'; // noslz
  NODEBYNAME_Tag270Description = 'Tag 270 (Description)'; // noslz
  NODEBYNAME_Tag271Make = 'Tag 271 (Make)'; // noslz
  NODEBYNAME_Tag272DeviceModel = 'Tag 272 (Device Model)'; // noslz
  NODEBYNAME_Tag274Orientation = 'Tag 274 (Orientation)'; // noslz
  NODEBYNAME_Tag282XResolution = 'Tag 282 (X-Resolution)'; // noslz
  NODEBYNAME_Tag283YResolution = 'Tag 283 (Y-Resolution)'; // noslz
  NODEBYNAME_Tag305Software = 'Tag 305 (Software)'; // noslz
  NODEBYNAME_Tag306DateTime = 'Tag 306 (Date/Time)'; // noslz
  NODEBYNAME_Tag315Artist = 'Tag 315 (Artist)'; // noslz
  NODEBYNAME_Tag36867DateTimeOriginal = 'Tag 36867 (DateTimeOriginal)'; // noslz
  NODEBYNAME_Tag33432Copyright = 'Tag 33432 (Copyright)'; // noslz

  NODEBYNAME_GPSInfo1GPSLatitudeRef = 'GPSInfo 1 (GPSLatitudeRef)'; // noslz
  NODEBYNAME_GPSInfo2GPSLatitude = 'GPSInfo 2 (GPSLatitude)'; // noslz
  NODEBYNAME_GPSInfo3GPSLongitudeRef = 'GPSInfo 3 (GPSLongitudeRef)'; // noslz
  NODEBYNAME_GPSInfo4GPSLongitude = 'GPSInfo 4 (GPSLongitude)'; // noslz
  NODEBYNAME_GPSInfo5GPSAltitudeRef = 'GPSInfo 5 (GPSAltitudeRef)'; // noslz
  NODEBYNAME_GPSInfo6GPSAltitude = 'GPSInfo 6 (GPSAltitude)'; // noslz
  NODEBYNAME_GPSInfo7GPSTimeStamp = 'GPSInfo 7 (GPSTimeStamp)'; // noslz
  NODEBYNAME_GPSInfo16GPSImgDirectionRef = 'GPSInfo 16 (ImgDirectionRef)'; // noslz
  NODEBYNAME_GPSInfo17GPSImgDirection = 'GPSInfo 17 (GPSImgDirection)'; // noslz
  NODEBYNAME_GPSInfo29GPSDateStamp = 'GPSInfo 29 (GPSDateStamp)'; // noslz
  // ==============================================================================

  MAX_TO_PRINT = 25000;
  BS = '\';
  CHAR_LENGTH = 80;
  DCR = #10#13 + #10#13;
  RPAD_VALUE = 40;
  SPACE = ' ';
  TSWT = 'The script will terminate.';

var
  gDevice_TList: TList;
  gReport_StringList: TStringList;

const
  SCRIPT_NAME = 'Google Earth KML create';
  MAIN_FORM_TITLE = 'Create a GoogleEarth KML file';
  MAIN_FORM_DESCRIPTION = 'Create a GoogleEarth KML file to show the location of digital camera photos in GoogleEarth or GoogleMaps.' + DCR +
    'The script works with checked files (currently limited to the File System module). It processes JPG files only. If a Signature Analysis has been run, it will include any identified JPEGs that do not have a JPEG extension.' + DCR +
    'The script identifies JPEG files with latitude and longitude data. It then extracts this data and creates the KML. The KML file is given a unique name based on the date and time that it was created.' + DCR +
    'The script includes the ability to export the identified JPEG files into a folder so that they can be previewed in GoogleEarth placemarks.' + DCR +
    'Photos are sorted in order of newest to oldest. Dates and time for sorting are taken from the Exif 306 Date/Time tag of the camera.' + DCR + 'The path option draws a line between photos in the order of date/time.' + DCR +
    'During processing, the script creates columns in the File System module to store the metadata values that it has found. For subsequent searches, a "Use already extracted metadata" selection will speed up the search by first using already available metadata from the columns.'
    + DCR + 'The path option draws a line between photos in the order of date/time.' + DCR + 'For feature requests please contact GetData via https://getdataforensics.com/.';

  MAIN_FORM_AUTHOR = 'GetData';
  MAIN_FORM_FULL_TITLE = MAIN_FORM_TITLE;
  SET_FLAG = True; // Set flag
  SET_FLAG_EXTRACTED = True;
  SET_FLAG_COLOR = clRed; // flag color if set
  STARTUP_TAB = 1; // show options tab when form is display
  MIN_FILE_SIZE = 0; // default min filesize in MB to hash
  MAX_FILE_SIZE = 50; // default max filesize in MB to hash

function GetUniqueFileName(AFileName: string): string;
function BoolToStr(Val: Boolean): string;
procedure ConsoleLog(AString: string);
function RPad(const AString: string; AChars: integer): string;

implementation

// Use SehllExecute to auto run the KML file ====================================
function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

function BoolToStr(Val: Boolean): string;
begin
  if Val then
    Result := 'True' // or 'Yes' or '1'
  else
    Result := 'False'; // or 'No' or '0'
end;

procedure ConsoleLog(AString: string);
var
  s: string;
begin
  s := AString;
  Progress.Log(s);
  if assigned(gReport_StringList) then
    if gReport_StringList.Count < MAX_TO_PRINT then
      gReport_StringList.Add(AString);
end;

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

// Makes a unique filename that does not exist. Requires a full path.
function GetUniqueFileName(AFileName: string): string;
var
  fnum: integer;
  fext: string;
  fname: string;
  fpath: string;
begin
  Result := AFileName;
  if FileExists(AFileName) then
  begin
    fnum := 1;
    fext := ExtractFileExt(AFileName);
    if fext = '' then
      fext := '.jpg';
    fname := ExtractFileName(AFileName);
    fname := ChangeFileExt(fname, '');
    fpath := ExtractFilePath(AFileName);
    ConsoleLog(fpath + fname + '_' + IntToStr(fnum) + fext);
    while FileExists(fpath + fname + '_' + IntToStr(fnum) + fext) do
    begin
      ConsoleLog(fpath + fname + '_' + IntToStr(fnum) + fext + ' exists!');
      fnum := fnum + 1;
    end;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
    ConsoleLog(Result);
  end
  else
  begin
    fext := ExtractFileExt(AFileName); // This was added to handle iTunes backup files that do not have the .jpg extension
    if fext = '' then
    begin
      Result := AFileName + '.jpg'; // Automatically adds the .jpg for exported files that do not have it (iTunes backups)
    end;
  end;
end;

/// /------------------------------------------------------------------------------
/// / Save to FEXLAB global output folder
/// /------------------------------------------------------------------------------
// function FexLab_Global_Save(path_str: string; aStringList: TStringList) : boolean;
// var
// FexLab_Global_Dir_str: string;
// FexLab_Global_Dnm_str: string;
// FexLab_Global_Fnm_str: string;
// FexLab_Global_Pth_str: string;
//
// begin
// // Initialize
// Result := False;
// FexLab_Global_Fnm_str := ExtractFileName(path_str);
// FexLab_Global_Dnm_str := '';
//
// // Add Device Name in filename after date time
// if RegexMatch(FexLab_Global_Fnm_str, '^\d\d\d\d-\d\d-\d\d-\d\d-\d\d-', False) then
// begin
// if assigned(gDevice_TList) and (gDevice_TList.Count = 1) then
// begin
// if Length(FexLab_Global_Fnm_str) >= 20 then
// insert('-' + TEntry(gDevice_TList[0]).EntryName, FexLab_Global_Fnm_str, 20);
// end;
// end;
//
// FexLab_Global_Dir_str := '\\Fexlabs\share\Global_Output\GOOGLE_EARTH'; //noslz
// FexLab_Global_Pth_str := FexLab_Global_Dir_str + BS + FexLab_Global_Fnm_str;
//
// if ForceDirectories(IncludeTrailingPathDelimiter(FexLab_Global_Dir_str)) and DirectoryExists(FexLab_Global_Dir_str) then
// aStringList.SaveToFile(FexLab_Global_Pth_str);
// Sleep(1000);
//
// if FileExists(FexLab_Global_Pth_str) then
// begin
// Progress.Log(RPad('Saved File (FEXLAB Global):', RPAD_VALUE) + FexLab_Global_Pth_str);
// Result := True;
// end;
// Progress.Log(Stringofchar('-', CHAR_LENGTH));
// end;

// ------------------------------------------------------------------------------
// This is the main procedure called after the 'Run' button is clicked
// ------------------------------------------------------------------------------
procedure MainProc;
var
  // aBitMap: TBitmap;
  accessed: string;
  anEntry: TEntry;
  anEntryReader: TEntryReader;
  aPropertyNode, aParentNode: TPropertyNode;
  aPropertyNode1: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aRootEntry: TPropertyNode;
  bl_chbAutoRunGoogleEarth: Boolean;
  bl_chbBookmarkFiles: Boolean;
  bl_chbCreatePath: Boolean;
  bl_chbExportJpegs: Boolean;
  bl_chbFileName: Boolean;
  bl_chbReportToScreen: Boolean;
  bl_chbTag272DeviceModel: Boolean;
  bl_chbTag306DateTime: Boolean;
  bl_chbTag306DateTime_show: Boolean;
  bl_Continue: Boolean;
  bmGroup: TEntry;
  bmList: TList;
  br: string;
  br_br: string;
  camera_exif_table: String;
  colGPSPosLatitude: TDataStoreField;
  colGPSPosLongitude: TDataStoreField;
  colTag271Make: TDataStoreField;
  colTag272DeviceModel: TDataStoreField;
  colTag305Software: TDataStoreField;
  colTag306DateTime: TDataStoreField;
  created: string;
  dec_fex_case_folder1: string;
  dec_fex_case_folder: string;
  desc_inc_bookmark_status: string;
  desc_inc_deleted_status: string;
  desc_inc_exif_line: string;
  desc_inc_filename: string;
  desc_inc_flags: string;
  desc_inc_line: string;
  desc_inc_logical_size: string;
  desc_inc_mac: string;
  desc_inc_thumbnail: string;
  desc_logical_size: integer;
  DestinationPath: string;
  DoAll: Boolean;
  earliestDateTimeStr: string;
  earliestlatitudeVal: double;
  earliestlongitudeVal: double;
  EntryList: TDatastore;
  EntryReader: TEntryReader;
  ExportEntryReader: TEntryReader;
  ExportFile: TFileStream;
  export_file_count: integer;
  Ext: string;
  Fex_Entries_Table: String;
  FileSignatureInfo: TFileTypeInformation;
  file_ok_to_export: Boolean;
  FoundCount: integer;
  gcmbGoogleEarthAltitudeSelection: integer;
  gcmbPathColor: integer;
  gcmbPinColor: integer;
  gGoogleEarthStartAtlitude: string;
  gGoogleEarthStartLatitude: string;
  gGoogleEarthStartLongitude: string;
  GoogleEarthLaunchPath_str: string;
  gStartGoogleEarthAbove: integer;
  i: integer;
  KMLExportFolder: string;
  KMLFileName: string;
  KMLFileNameDate: string;
  KMLFileNameDateTime: string;
  KMLFileNameTime: string;
  KMLOutputFile: string;
  KMLOutputFile_as_string: string;
  KMLOutputFile_formatted: string;
  KMLOutputFile_no_slash: string;
  kml_created_bl: Boolean;
  kml_date_time: string;
  kml_description: string;
  KML_Export_Loop_Flag: Boolean;
  kml_look_at_StringList: TStringList;
  kml_main_footer_StringList: TStringList;
  kml_main_header_StringList: TStringList;
  kml_main_placemark_StringList: TStringList;
  kml_placemark_name: string;
  kml_placemark_name_model: string;
  kml_snippet: string;
  latitudecalcVal: double;
  latitudecalcVal_str: string;
  lat_long_found: Boolean;
  linestring_data_StringList: TStringList;
  linestring_footer_StringList: TStringList;
  linestring_header_StringList: TStringList;
  LogicalSize: int64;
  longitudecalcVal: double;
  longitudecalcVal_str: string;
  lowercaseEntryName: string;
  LT_Accessed: string;
  LT_Backslash: string;
  LT_Bookmarked: string;
  LT_CaseFolder: string;
  LT_Colon: string;
  LT_Comma: string;
  LT_Created: string;
  LT_Date: string;
  LT_DateTime: string;
  LT_DeletedFile: string;
  LT_Filename: string;
  LT_Flags: string;
  LT_Latitude: string;
  LT_LogicalSize: string;
  LT_Longitude: string;
  LT_Make: string;
  LT_Model: string;
  LT_Modified: string;
  LT_No: string;
  LT_Path: string;
  LT_Software: string;
  LT_Yes: string;
  MaxSize: int64;
  Metadata_Extractions_Count: integer;
  modified: string;
  NumberEntries: integer;
  placemark_name_datetime: string;
  proceed_with_extraction: Boolean;
  Processed_Using_Existing_Metadata_Count: integer;
  style_pin: string;
  Tag271Make: string;
  Tag272DeviceModel: string;
  Tag305Software: string;
  Tag306Date: string;
  Tag306DateFormatted: string;
  Tag306DateTime: string;
  Tag306DateTimeFormattedFinal: string;
  Tag306Time: string;
  tempvariant: variant;
  Uppername: string;

begin
  // CLI settings
  DoAll := True;
  bl_chbAutoRunGoogleEarth := False;
  bl_chbBookmarkFiles := True;
  bl_chbCreatePath := True;
  bl_chbExportJpegs := True;
  bl_chbFileName := True;
  bl_chbReportToScreen := False;
  bl_chbTag272DeviceModel := False;
  bl_chbTag306DateTime := True;
  bl_chbTag306DateTime_show := False;
  gcmbGoogleEarthAltitudeSelection := 0;
  gcmbPathColor := 0;
  gcmbPinColor := 0;
  gStartGoogleEarthAbove := 0;

  // Setup words for translation purposes
  LT_Accessed := 'Accessed';
  LT_Backslash := '\';
  LT_Bookmarked := 'Bookmarked';
  LT_CaseFolder := 'Case Folder';
  LT_Comma := ',';
  LT_Colon := ':';
  LT_Created := 'Created';
  LT_Date := 'Date';
  LT_DateTime := 'Date/Time';
  LT_DeletedFile := 'Deleted File';
  LT_Filename := 'Filename';
  LT_Flags := 'Flags';
  LT_LogicalSize := 'Logical Size';
  LT_Latitude := 'Latitude';
  LT_Longitude := 'Longitude';
  LT_Make := 'Make';
  LT_Model := 'Model';
  LT_Modified := 'Modified';
  LT_No := 'No';
  LT_Path := 'Path';
  LT_Software := 'Software';
  LT_Yes := 'Yes';

  FoundCount := 0;
  export_file_count := 0;
  aPropertyTree := nil;
  KML_Export_Loop_Flag := False;

  // Check to see if the FileSystem module is present
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if EntryList = nil then
  begin
    MessageUser('No entries found.' + SPACE + TSWT);
    Exit;
  end;

  // Check to see if there are files in the FileSystem module
  anEntry := EntryList.First;
  NumberEntries := EntryList.Count;
  if anEntry = nil then
  begin
    // If we can not get the first DataEntry then we have not data entries to process
    MessageUser('There are no files in the File System module.');
    ConsoleLog('No Entries selected');
    EntryList.free;
    Exit;
  end;

  if not Progress.isRunning then
  Begin
    ConsoleLog('Progress is not running.' + SPACE + TSWT);
    EntryList.free;
    Exit;
  End;

  Progress.Initialize(NumberEntries, 'Extracting metadata...'); // Initialize the progress bar

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Create column names
  colTag271Make := AddMetaDataField('Exif 271: Make', ftString);
  colTag272DeviceModel := AddMetaDataField('Exif 272: Device Model', ftString);
  colTag305Software := AddMetaDataField('Exif 305: Software', ftString);
  colTag306DateTime := AddMetaDataField('Exif 306: Date/Time', ftString);
  colGPSPosLatitude := AddMetaDataField('GPS Lat. (calc)', ftFloat);
  colGPSPosLongitude := AddMetaDataField('GPS Long. (calc)', ftFloat);
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConsoleLog(StringOfChar('-', 80));

  KMLFileNameDate := formatdatetime('yyyy-mm-dd', now);
  KMLFileNameTime := formatdatetime('hh-nn-ss', now);
  KMLFileNameDateTime := (KMLFileNameDate + '-' + KMLFileNameTime);

  KMLFileName := 'GoogleEarth.kml';
  KMLExportFolder := 'GoogleEarth_Images';

  // Bookmark
  if bl_chbBookmarkFiles then
  begin
    bmGroup := FindBookmarkByName('Google Earth');
    if bmGroup = nil then
    begin
      bmGroup := NewBookmark(FindBookmarkByName('My Bookmarks'), 'Google Earth');
    end;
    bmList := TList.Create;
  end;
  DestinationPath := GetExportedDir + 'GoogleEarth' + BS;
  KMLOutputFile := DestinationPath + KMLFileName;
  KMLOutputFile_no_slash := DestinationPath + KMLFileName; // Cannot use the above slash for the auto run kml file option

  // Create StringLists
  kml_look_at_StringList := TStringList.Create;
  kml_main_footer_StringList := TStringList.Create;
  kml_main_header_StringList := TStringList.Create;
  kml_main_placemark_StringList := TStringList.Create;
  linestring_data_StringList := TStringList.Create;
  linestring_footer_StringList := TStringList.Create;
  linestring_header_StringList := TStringList.Create;
  gReport_StringList := TStringList.Create;

  try
    ConsoleLog('Source:');
    // ConsoleLog(RPad('Checked Files:', RPAD_VALUE) + IntToStr(FileSystemCheckedItemsCount));
    if DoAll then
      ConsoleLog(RPad('Operating on All File System items:', 40) + 'True');
    ConsoleLog(StringOfChar('-', 80));
    ConsoleLog('Placemark Options:');

    // Log the Placemark Pin Color===============================================
    if gcmbPinColor = 0 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'Yellow');
    if gcmbPinColor = 1 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'Red');
    if gcmbPinColor = 2 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'White');
    if gcmbPinColor = 3 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'Blue');
    if gcmbPinColor = 4 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'Green');
    if gcmbPinColor = 5 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'Purple');
    if gcmbPinColor = 6 then
      ConsoleLog(RPad('The placemark pin color is:', 40) + 'Pink');

    ConsoleLog(RPad('Show Filename:', 40) + BoolToStr(bl_chbFileName));
    ConsoleLog(RPad('Show Camera Model:', 40) + BoolToStr(bl_chbTag272DeviceModel));
    ConsoleLog(RPad('Show Date/Time:', 40) + BoolToStr(bl_chbTag306DateTime));
    ConsoleLog(RPad('Thumbnail (Export JPGs to Disk):', 40) + BoolToStr(bl_chbExportJpegs));

    ConsoleLog(StringOfChar('-', 80));
    ConsoleLog('Path Options:');
    ConsoleLog(RPad('Create Path (Date/Time):', 40) + BoolToStr(bl_chbCreatePath));

    // Log the Path Color========================================================
    if gcmbPathColor = 0 then
      ConsoleLog(RPad('The path color is:', 40) + 'Yellow');
    if gcmbPathColor = 1 then
      ConsoleLog(RPad('The path color is:', 40) + 'Red');
    if gcmbPathColor = 2 then
      ConsoleLog(RPad('The path color is:', 40) + 'White');
    if gcmbPathColor = 3 then
      ConsoleLog(RPad('The path color is:', 40) + 'Blue');
    if gcmbPathColor = 4 then
      ConsoleLog(RPad('The path color is:', 40) + 'Green');
    if gcmbPathColor = 5 then
      ConsoleLog(RPad('The path color is:', 40) + 'Purple');
    if gcmbPathColor = 6 then
      ConsoleLog(RPad('The path color is:', 40) + 'Pink');

    ConsoleLog(StringOfChar('-', 80));
    ConsoleLog('GoogleEarth Startup:');

    // Log Altitude==============================================================
    If gcmbGoogleEarthAltitudeSelection = 1 then
    begin
      gGoogleEarthStartAtlitude := '4000000'; // 4km
      ConsoleLog(RPad('GoogleEarth start altitude set to' + LT_Colon, 40) + '4km');
    end;

    If gcmbGoogleEarthAltitudeSelection = 2 then
    begin
      gGoogleEarthStartAtlitude := '5000000'; // 5km
      ConsoleLog(RPad('GoogleEarth start altitude set to' + LT_Colon, 40) + '5km');
    end;

    // Set the starting position in Google Earth=================================
    case gStartGoogleEarthAbove of
      0:
        begin
          gGoogleEarthStartLatitude := IntToStr(0);
          gGoogleEarthStartLongitude := IntToStr(0);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'The location of the first photo');
        end;
      1:
        begin
          // Africa - Congo: -4.316667, 15.316667
          gGoogleEarthStartLatitude := IntToStr(-4.316667);
          gGoogleEarthStartLongitude := IntToStr(15.316667);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'Africa');
        end;
      2:
        begin
          // Asia - Singapore: 1.3, 103.8
          gGoogleEarthStartLatitude := IntToStr(1.3);
          gGoogleEarthStartLongitude := IntToStr(103.8);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'Asia');
        end;
      3:
        begin
          // Australia - Sydney: -33.859972, 151.211111
          gGoogleEarthStartLatitude := IntToStr(-33.859972);
          gGoogleEarthStartLongitude := IntToStr(151.211111);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'Australia');
        end;
      4:
        begin
          // Europe - Berlin: 52.516667, 13.383333
          gGoogleEarthStartLatitude := IntToStr(52.516667);
          gGoogleEarthStartLongitude := IntToStr(13.383333);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'Europe');
        end;
      5:
        begin
          // Middle East - Baghdad: 33.325, 44.422
          gGoogleEarthStartLatitude := IntToStr(33.325);
          gGoogleEarthStartLongitude := IntToStr(44.422);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'Middle East');
        end;
      6:
        begin
          // South America - Brasilia: -15.798889, -47.866667
          gGoogleEarthStartLatitude := IntToStr(-15.798889);
          gGoogleEarthStartLongitude := IntToStr(-47.866667);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'South America');
        end;
      7:
        begin
          // Great Brittan - London: 51.507222, -0.1275
          gGoogleEarthStartLatitude := IntToStr(51.507222);
          gGoogleEarthStartLongitude := IntToStr(-0.1275);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'UK');
        end;
      8:
        begin
          // USA East Coast - Tennessee: 36, -86
          gGoogleEarthStartLatitude := IntToStr(36);
          gGoogleEarthStartLongitude := IntToStr(-86);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'USA East');
        end;
      9:
        begin
          // USA West Coast - Los Angeles: 34.05, -118.25,
          gGoogleEarthStartLatitude := IntToStr(34.05);
          gGoogleEarthStartLongitude := IntToStr(-118.25);
          ConsoleLog(RPad('GoogleEarth start location set to' + LT_Colon, 40) + 'USA West');
        end;
    end; { case }

    // Set the starting altitude in GoogleEarth==================================
    case gcmbGoogleEarthAltitudeSelection of
      0:
        begin
          gGoogleEarthStartAtlitude := '3000000'; // 3km
          ConsoleLog(RPad('GoogleEarth start altitude set to' + LT_Colon, 40) + '3km');
        end;
      1:
        begin
          gGoogleEarthStartAtlitude := '4000000'; // 4km
          ConsoleLog(RPad('GoogleEarth start altitude set to' + LT_Colon, 40) + '4km');
        end;
      2:
        begin
          gGoogleEarthStartAtlitude := '5000000'; // 5km
          ConsoleLog(RPad('GoogleEarth start altitude set to' + LT_Colon, 40) + '5km');
        end;
    end;

    // Progress Log =============================================================
    ConsoleLog(StringOfChar('-', 80));
    ConsoleLog('Destination:');
    ConsoleLog(RPad('The KML file destination is' + LT_Colon, 40) + KMLOutputFile_no_slash);

    if bl_chbReportToScreen then
    begin
      ConsoleLog(RPad('Show a summary report' + LT_Colon, 40) + 'True');
    end
    else
    begin
      ConsoleLog(RPad('Show a summary report' + LT_Colon, 40) + 'False');
    end;

    if bl_chbAutoRunGoogleEarth then
    begin
      ConsoleLog(RPad('Automatically Launch in GoogleEarth' + LT_Colon, 40) + 'True');
    end
    else
    begin
      ConsoleLog(RPad('Automatically Launch in GoogleEarth' + LT_Colon, 40) + 'False');
    end;

    if bl_chbTag306DateTime_show then
    begin
      ConsoleLog(RPad('Time Stamp for historical maps' + LT_Colon, 40) + 'True');
    end
    else
    begin
      ConsoleLog(RPad('Time Stamp for historical maps' + LT_Colon, 40) + 'False');
    end;

    // Create the KML file header ===============================================
    kml_main_header_StringList.Add('<?xml version="1.0" encoding="UTF-8"?>');
    kml_main_header_StringList.Add('<kml xmlns="http://earth.google.com/kml/2.0">');
    kml_main_header_StringList.Add('<Document>');
    kml_main_header_StringList.Add('<Style id="myDefaultStyles">');
    // Line Style
    kml_main_header_StringList.Add('<LineStyle>');
    if gcmbPathColor = 0 then
      kml_main_header_StringList.Add('<color>5014F0FF</color>'); // Yellow
    if gcmbPathColor = 1 then
      kml_main_header_StringList.Add('<color>7f0000ff</color>'); // Red
    if gcmbPathColor = 2 then
      kml_main_header_StringList.Add('<color>50FFFFFF</color>'); // White
    if gcmbPathColor = 3 then
      kml_main_header_StringList.Add('<color>50780000</color>'); // Blue
    if gcmbPathColor = 4 then
      kml_main_header_StringList.Add('<color>5014F000</color>'); // Green
    if gcmbPathColor = 5 then
      kml_main_header_StringList.Add('<color>50780078</color>'); // Purple
    if gcmbPathColor = 6 then
      kml_main_header_StringList.Add('<color>507800F0</color>'); // Pink
    kml_main_header_StringList.Add('<width>4</width>');
    kml_main_header_StringList.Add('<gx:labelVisibility>1</gx:labelVisibility>');
    kml_main_header_StringList.Add('</LineStyle>');
    // Balloon Style
    kml_main_header_StringList.Add('<BalloonStyle>');
    kml_main_header_StringList.Add('<bgColor>ffffff</bgColor>');
    kml_main_header_StringList.Add('<text><![CDATA[<b><font color="#CC0000" size="+2">$[name]</font></b><br/><br/><font face="Courier">$[description]</font><br/><br/><br/><br/>]]></text>');
    kml_main_header_StringList.Add('</BalloonStyle>');
    // Label Style
    kml_main_header_StringList.Add('<LabelStyle>');
    if (bl_chbFileName = False) and (bl_chbTag306DateTime_show = False) and (bl_chbTag272DeviceModel = False) then
    begin
      kml_main_header_StringList.Add('<scale>0</scale>');
    end;
    kml_main_header_StringList.Add('</LabelStyle>');
    kml_main_header_StringList.Add('</Style>');

    // Write the line-string header
    if bl_chbCreatePath then
    begin
      linestring_header_StringList.Add('<Placemark>');
      linestring_header_StringList.Add('<Name>' + LT_Path + '</Name>');
      linestring_header_StringList.Add('<styleUrl>#myDefaultStyles</styleUrl>');
      linestring_header_StringList.Add('<MultiGeometry>');
      linestring_header_StringList.Add('<LineString>');
      linestring_header_StringList.Add('<tessellate>1</tessellate>');
      linestring_header_StringList.Add('<coordinates>');
    end;

    // Process the loop to extract the metadata===================================
    ConsoleLog(StringOfChar('-', 80));
    ConsoleLog('Processing commenced...');

    // DATA PROCESSING LOOP =========================================================================================================================================================================================
    try
      anEntryReader := TEntryReader.Create;
      ExportEntryReader := TEntryReader.Create;
      EntryReader := TEntryReader.Create;
      i := 0;
      earliestlatitudeVal := 0.0;
      earliestlongitudeVal := 0.0;
      earliestDateTimeStr := '';
      proceed_with_extraction := True;
      Metadata_Extractions_Count := 0;
      Processed_Using_Existing_Metadata_Count := 0;
      Metadata_Extractions_Count := 0;

      while assigned(anEntry) and (Progress.isRunning) do
      begin
        if DoAll then
        begin
          bl_Continue := True;

          if bl_Continue then
          begin
            // Clear variables used in loop
            latitudecalcVal := 0;
            longitudecalcVal := 0;
            lat_long_found := False;
            Uppername := UpperCase(anEntry.EntryName);
            FileSignatureInfo := anEntry.FileDriverInfo;
            proceed_with_extraction := True;
            if ((FileSignatureInfo.FileDriverNumber > 0) and (FileSignatureInfo.ShortDisplayName = 'JPG')) or ((pos('.JPG', Uppername) > 0)) then
            begin
              if not(colGPSPosLatitude.isNull(anEntry)) and not(colGPSPosLongitude.isNull(anEntry)) and not(colTag271Make.isNull(anEntry)) and not(colTag272DeviceModel.isNull(anEntry)) and not(colTag305Software.isNull(anEntry)) and
                not(colTag306DateTime.isNull(anEntry)) then
              begin
                latitudecalcVal := colGPSPosLatitude.AsFloat[anEntry];
                longitudecalcVal := colGPSPosLongitude.AsFloat[anEntry];
                Tag271Make := colTag271Make.AsString[anEntry];
                Tag272DeviceModel := colTag272DeviceModel.AsString[anEntry];
                Tag305Software := colTag305Software.AsString[anEntry];
                Tag306DateTime := colTag306DateTime.AsString[anEntry];
                // Progress.Log('data was found in each column for: ' + anEntry.EntryName);
                Processed_Using_Existing_Metadata_Count := (Processed_Using_Existing_Metadata_Count + 1);
                proceed_with_extraction := False;
              end;
            end // (UseAlreadyExtracted)
            else
              proceed_with_extraction := False;

            try
              if proceed_with_extraction and ProcessMetadataProperties(anEntry, aPropertyTree, anEntryReader) then
              Begin
                if assigned(aPropertyTree) then
                begin
                  // METADATA EXTRACTION PROCESS STARTS
                  Metadata_Extractions_Count := (Metadata_Extractions_Count + 1);
                  // ConsoleLog('Extracting metadata for file: ' + anEntry.EntryName);
                  aRootEntry := aPropertyTree.RootProperty;
                  if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
                  begin
                    aParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_EXIF));
                    if assigned(aParentNode) then
                    begin
                      // Extract Latitude
                      aRootEntry := aPropertyTree.RootProperty;
                      aPropertyNode := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo2GPSLatitude);
                      aPropertyNode1 := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo1GPSLatitudeRef);
                      if aPropertyNode <> nil then
                      begin
                        tempvariant := aPropertyNode.PropValue;
                        if VarIsArray(tempvariant) then
                        begin
                          latitudecalcVal := VarArrayGet(tempvariant, [0]) + VarArrayGet(tempvariant, [1]) / 60 + VarArrayGet(tempvariant, [2]) / 3600;
                          if (aPropertyNode1 <> nil) then
                          begin
                            if aPropertyNode1.PropValue = 'S' then
                              latitudecalcVal := -latitudecalcVal;
                          end;
                          colGPSPosLatitude.AsDouble(anEntry) := latitudecalcVal;
                        end
                        else
                          colGPSPosLatitude.AsDouble(anEntry) := tempvariant;
                      end;

                      // Extract Longitude
                      aPropertyNode := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo4GPSLongitude);
                      aPropertyNode1 := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo3GPSLongitudeRef);
                      if aPropertyNode <> nil then
                      begin
                        tempvariant := aPropertyNode.PropValue;
                        if VarIsArray(tempvariant) then
                        begin
                          longitudecalcVal := VarArrayGet(tempvariant, [0]) + VarArrayGet(tempvariant, [1]) / 60 + VarArrayGet(tempvariant, [2]) / 3600;
                          if (aPropertyNode1 <> nil) then
                          begin
                            if aPropertyNode1.PropValue = 'W' then
                              longitudecalcVal := -longitudecalcVal;
                          end;
                          colGPSPosLongitude.AsDouble(anEntry) := longitudecalcVal;
                        end
                        else
                          colGPSPosLongitude.AsFloat(anEntry) := tempvariant;
                      end;

                      // Extract Date Time
                      Tag306DateTime := '';
                      aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag306DateTime));
                      if assigned(aPropertyNode) then
                      begin
                        Tag306DateTime := trim(aPropertyNode.PropValue); // Set the variable
                        if Tag306DateTime <> '' then // Check to see if variable is blank
                        begin
                          colTag306DateTime.AsString[anEntry] := Tag306DateTime; // If not blank, write the variable to the column
                        end;
                        // Needs to be in this format: <TimeStamp><when>1997-07-16T07:30:15Z</when></TimeStamp>
                        // Reformat the date
                        Tag306Date := Tag306DateTime;
                        Delete(Tag306Date, 11, 19);
                        Tag306DateFormatted := StringReplace(Tag306Date, ':', '-', [rfReplaceAll, rfIgnoreCase]);
                        // Reformat the time
                        Tag306Time := Tag306DateTime;
                        Delete(Tag306Time, 1, 10);
                        Tag306Time := trim(Tag306Time);
                        // Reset Tag306DateTime
                        Tag306DateTimeFormattedFinal := Tag306DateFormatted + 'T' + Tag306Time + 'Z';
                      end;

                      // Extract Make
                      Tag271Make := '';
                      aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag271Make));
                      if assigned(aPropertyNode) then
                      begin
                        Tag271Make := trim(aPropertyNode.PropValue); // Set the variable
                        if Tag271Make <> '' then // Check to see if variable is blank
                        begin
                          colTag271Make.AsString[anEntry] := Tag271Make; // If not blank, write the variable to the column
                        end;
                      end;

                      // Extract Model
                      Tag272DeviceModel := '';
                      aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag272DeviceModel));
                      if assigned(aPropertyNode) then
                      begin
                        Tag272DeviceModel := trim(aPropertyNode.PropValue);
                        if Tag272DeviceModel <> '' then
                          colTag272DeviceModel.AsString[anEntry] := Tag272DeviceModel;
                      end;

                      // Extract Software
                      Tag305Software := '';
                      aPropertyNode := TPropertyNode(aParentNode.GetFirstNodeByName(NODEBYNAME_Tag305Software));
                      if assigned(aPropertyNode) then
                      begin
                        Tag305Software := trim(aPropertyNode.PropValue);
                        if Tag305Software <> '' then
                        begin
                          colTag305Software.AsString[anEntry] := Tag305Software;
                        end;
                      end;
                    end;
                  end;
                end; // (Assigned a property tree)
              end; // (Proceed with extraction)
              // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^END OF DATA PROCESSING

              // Valid latitude and longitude found
              if (latitudecalcVal <> 0) and (longitudecalcVal <> 0) then
              begin

                // Add Entry to our Bookmark list
                if bl_chbBookmarkFiles then
                begin
                  bmList.Add(anEntry);
                end;

                if earliestlatitudeVal = 0.0 then
                  earliestlatitudeVal := latitudecalcVal;

                if earliestlongitudeVal = 0.0 then
                  earliestlongitudeVal := longitudecalcVal;

                FoundCount := (FoundCount + 1);
                Progress.DisplayMessageNow := IntToStr(FoundCount) + ' GPS files found.';

                // PLACEMARK CONTENT=======================================
                kml_placemark_name := '';

                if (bl_chbFileName = False) and (bl_chbTag306DateTime_show = False) and (bl_chbTag272DeviceModel = False) then // If nothing ticked, use the name (it is hidden with line style)
                  kml_placemark_name := anEntry.EntryName;

                // Show Filename in placemark if selected
                if bl_chbFileName then
                  kml_placemark_name := anEntry.EntryName;

                // Show model in placemark if selected
                kml_placemark_name_model := '';

                if bl_chbTag272DeviceModel then
                begin
                  kml_placemark_name_model := Tag272DeviceModel;
                end;

                if bl_chbFileName and bl_chbTag272DeviceModel then
                begin
                  kml_placemark_name_model := ' - ' + Tag272DeviceModel;
                end;

                // Show date and time in placemark if selected
                placemark_name_datetime := '';
                if bl_chbTag306DateTime_show then
                begin
                  placemark_name_datetime := Tag306DateTime;
                end;

                if bl_chbFileName and bl_chbTag306DateTime_show then
                begin
                  placemark_name_datetime := ' - ' + Tag306DateTime;
                end;

                if bl_chbTag272DeviceModel and bl_chbTag306DateTime_show then
                begin
                  placemark_name_datetime := ' - ' + Tag306DateTime;
                end;

                // TIMESTAMP CONTENT=======================================
                // Set date and time kml code here
                kml_date_time := '';
                if bl_chbTag306DateTime then
                begin
                  kml_date_time := '<TimeStamp><when>' + Tag306DateTimeFormattedFinal + '</when></TimeStamp>';
                end;

                // SNIPPET CONTENT=========================================
                // Snippet kml code here
                kml_snippet := '<Snippet>' + LT_Date + ': ' + Tag306DateTime + ',' + LT_Model + ': ' + Tag272DeviceModel + '</Snippet>';

                // DESCRIPTION CONTENT=====================================
                // Line spacing in the description
                br_br := '' + '<br /><br />';
                br := '' + '<br />';

                // Thumbnail from exported JPEG
                desc_inc_thumbnail := '';
                if bl_chbExportJpegs then
                begin
                  lowercaseEntryName := IncludeTrailingPathDelimiter(DestinationPath + KMLExportFolder) + lowercase(anEntry.SaveName); // GoogleEarth requires lower case file extension to show pictures in placemarks
                  lowercaseEntryName := GetUniqueFileName(lowercaseEntryName);
                  // Progress.Log(lowercaseEntryName);
                  desc_inc_thumbnail := '<img src="file:///' + lowercaseEntryName + '" width="400" />' + br_br;

                  // Export JPEGs to disk to use as placemark thumbnails=======
                  LogicalSize := anEntry.LogicalSize;
                  Ext := UpperCase(ExtractFileExt(anEntry.EntryName));
                  MaxSize := 20 * 1024 * 1024;
                  file_ok_to_export := True;

                  if (LogicalSize <= 0) or (LogicalSize > MaxSize) then
                    file_ok_to_export := False; // Cull by file size limits

                  if file_ok_to_export then
                  begin
                    if DirectoryExists(DestinationPath + KMLExportFolder) then
                    begin
                      if KML_Export_Loop_Flag = False then
                      begin
                        ConsoleLog('The export JPEGs folder already exists: ' + DestinationPath + KMLExportFolder);
                        KML_Export_Loop_Flag := True;
                      end;
                    end
                    else
                    begin
                      if KML_Export_Loop_Flag = False then
                      begin
                        ConsoleLog(RPad('Creating the JPG export folder:', RPAD_VALUE) + DestinationPath + KMLExportFolder);
                      end;
                      try
                        ForceDirectories(IncludeTrailingPathDelimiter(DestinationPath + KMLExportFolder));
                      except
                        ConsoleLog('Exception creating folder: ' + DestinationPath + KMLExportFolder);
                        Exit;
                      end;
                      KML_Export_Loop_Flag := True;
                    end;

                    if DirectoryExists(DestinationPath + KMLExportFolder) then
                    begin
                      if ExportEntryReader.OpenData(anEntry) then
                      begin

                        // // Process at 8 x 8 ----------------------------------------------------------
                        // aBitMap := nil;
                        // Progress.Log('8x8-1: ' + anEntry.EntryName);
                        // if EntryReader.OpenData(anEntry) then
                        // begin
                        // Progress.Log('8x8-2: ' + anEntry.EntryName);
                        // try
                        // try
                        // aBitMap := CreateBitMapFromDataEntry(EntryReader, anEntry, 8, 8, False);
                        // if aBitMap = nil then
                        // begin
                        // Progress.Log(RPad(anEntry.EntryName + ':', RPAD_VALUE) + SPACE + 'CreateBitMapFromCacheOrDataEntry(8) failed?');
                        // Exit;
                        // end
                        // else
                        // Progress.Log('created bitmap');
                        // except
                        // Progress.Log(ATRY_EXCEPT_STR + RPad(anEntry.EntryName + ':', RPAD_VALUE) + 'CreateBitMapFromCacheOrDataEntry(8) Raised an Exception?');
                        // Exit;
                        // end;
                        // finally
                        // if aBitMap <> nil then aBitMap.free;
                        // end;
                        // end;

                        ExportFile := nil;
                        try
                          ExportFile := TFileStream.Create(lowercaseEntryName, fmOpenWrite or fmCreate);
                        except
                          ConsoleLog('Error in Exporting file: ' + anEntry.EntryName);
                          ExportFile := nil;
                        end;
                        if ExportFile <> nil then
                        begin
                          try
                            ExportFile.CopyFrom(ExportEntryReader, anEntry.LogicalSize);
                            // ConsoleLog('Exporting file: '+anEntry.EntryName);
                          finally
                            ExportFile.free;
                          end;
                        end;
                        export_file_count := export_file_count + 1;
                      end;
                    end
                    else
                    begin
                      ConsoleLog('The folder: "' + DestinationPath + KMLExportFolder + ' could not be created.');
                    end; // (if directory exists)
                  end; // (if file OK to export)
                end;

                // Header and Table of Exif values
                desc_inc_exif_line := '<hr><b>JPEG EXIF DATA</b><hr>';
                camera_exif_table := '<table><tr><td width="100"><b>' + LT_DateTime + '</b>:</td><td>' + Tag306DateTime + '</td></tr><tr><td><b>' + LT_Make + '</b>:</td><td>' + Tag271Make + '</td></tr><tr><td><b>' + LT_Model +
                  '</b>:</td><td>' + Tag272DeviceModel + '</td></tr><tr><td><b>' + LT_Software + '</b>:</td><td>' + Tag305Software + '</td></tr><tr><td><b>' + LT_Latitude + '</b>:</td><td>' + floattostr(latitudecalcVal) +
                  '</td></tr><tr><td><b>' + LT_Longitude + '</b>:</td><td>' + floattostr(longitudecalcVal) + '</td></tr></table>';

                // Header and Table of values from FEX
                desc_inc_line := '<hr><b>FORENSIC EXPLORER</b><hr>';
                dec_fex_case_folder1 := '<b>' + 'FEX' + LT_CaseFolder + '</b>: ' + anEntry.Directory; // Cannot have & as it will break Google maps - must be replaced by &amp;
                dec_fex_case_folder := StringReplace(dec_fex_case_folder1, '&', '&amp;', [rfReplaceAll, rfIgnoreCase]); // Replace & for html

                // The following values are wrapped in the "FEX Entries Table"
                // Filename
                desc_inc_filename := '<tr><td width="100"><b>' + LT_Filename + '</b>:</td><td>' + anEntry.EntryName + '</td></tr>';
                // Flags
                desc_inc_flags := '';
                if Flag1 in anEntry.Flags then
                  desc_inc_flags := 'Red' + LT_Comma;
                if Flag2 in anEntry.Flags then
                  desc_inc_flags := 'Blue' + LT_Comma + desc_inc_flags;
                if Flag3 in anEntry.Flags then
                  desc_inc_flags := 'Yellow' + LT_Comma + desc_inc_flags;
                if Flag4 in anEntry.Flags then
                  desc_inc_flags := 'Orange' + LT_Comma + desc_inc_flags;
                if Flag5 in anEntry.Flags then
                  desc_inc_flags := 'Green' + LT_Comma + desc_inc_flags;
                if Flag6 in anEntry.Flags then
                  desc_inc_flags := 'Pink' + LT_Comma + desc_inc_flags;
                if Flag7 in anEntry.Flags then
                  desc_inc_flags := 'Aqua' + LT_Comma + desc_inc_flags;
                if Flag8 in anEntry.Flags then
                  desc_inc_flags := 'Brown' + LT_Comma + desc_inc_flags;
                if Length(desc_inc_flags) > 0 then
                  desc_inc_flags := copy(desc_inc_flags, 1, Length(desc_inc_flags) - 1)
                else
                  desc_inc_flags := 'No Flags';

                desc_inc_flags := '<tr><td><b>' + LT_Flags + '</b>:</td><td>' + desc_inc_flags + '</td></tr>';
                // Bookmark Status
                If anEntry.IsBookmarked then
                begin
                  desc_inc_bookmark_status := '<tr><td><b>' + LT_Bookmarked + '</b>:</td><td>' + LT_Yes + '</td></tr>';
                end
                else
                begin
                  desc_inc_bookmark_status := '<tr><td><b>' + LT_Bookmarked + '</b>:</td><td>' + LT_No + '</td></tr>';
                end;
                // Deleted Status
                If anEntry.isDeleted then
                begin
                  desc_inc_deleted_status := '<tr><td><b>' + LT_DeletedFile + '</b>:</td><td>' + LT_Yes + '</td></tr>';
                end
                else
                begin
                  desc_inc_deleted_status := '<tr><td><b>' + LT_DeletedFile + '</b>:</td><td>' + LT_No + '</td></tr>';
                end;
                // MAC Times from the File System
                created := (DateTimeToStr(anEntry.created));
                modified := (DateTimeToStr(anEntry.modified));
                accessed := (DateTimeToStr(anEntry.accessed));
                desc_inc_mac := '<tr><td><b>' + LT_Created + '</b>:</td><td>' + created + '</td></tr><tr><td><b>' + LT_Modified + '</b>:</td><td>' + modified + '</td></tr><tr><td><b>' + LT_Accessed + '</b>:</td><td>' + accessed +
                  '</td></tr><tr><td></td><td></td></tr>';
                // Logical file size from the File System
                desc_logical_size := anEntry.LogicalSize;
                desc_inc_logical_size := '<tr><td><b>' + LT_LogicalSize + '</b>:</td><td>' + IntToStr(desc_logical_size) + '</td></tr>';

                // FEX Entries Table
                Fex_Entries_Table := '<table>' + desc_inc_filename + desc_inc_logical_size + desc_inc_deleted_status + desc_inc_bookmark_status + desc_inc_flags + desc_inc_mac + '</table>';

                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // Put the pieces of the KML Description together
                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                kml_description := '';
                kml_description := '<description><![CDATA[' + desc_inc_thumbnail + desc_inc_exif_line + camera_exif_table + br_br + desc_inc_line + dec_fex_case_folder + br_br + Fex_Entries_Table +
                  ']]></description><styleUrl>#myDefaultStyles</styleUrl>';

                // Pin Style
                case gcmbPinColor of
                  0: // Yellow
                    begin
                      style_pin := '';
                    end;
                  1: // Red
                    begin
                      style_pin := '<Style id="redpin"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/red-pushpin.png</href></Icon></IconStyle></Style>';
                    end;
                  2: // White
                    begin
                      style_pin := '<Style id="whitepin"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/wht-pushpin.png</href></Icon></IconStyle></Style>';
                    end;
                  3: // Blue
                    begin
                      style_pin := '<Style id="bluepin"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/blue-pushpin.png</href></Icon></IconStyle></Style>';
                    end;
                  4: // Green
                    begin
                      style_pin := '<Style id="greenpin"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/grn-pushpin.png</href></Icon></IconStyle></Style>';
                    end;
                  5: // Purple
                    begin
                      style_pin := '<Style id="purplepin"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/purple-pushpin.png</href></Icon></IconStyle></Style>';
                    end;
                  6: // Pink
                    begin
                      style_pin := '<Style id="pinkpin"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/pink-pushpin.png</href></Icon></IconStyle></Style>';
                    end;
                end; // case

                // Set the earliest photo from the Exif 306 tag
                if (earliestDateTimeStr = '') and (Tag306DateTime <> '') then
                  earliestDateTimeStr := Tag306DateTime;

                if earliestDateTimeStr > Tag306DateTime then
                begin
                  earliestDateTimeStr := Tag306DateTime;
                  earliestlatitudeVal := latitudecalcVal;
                  earliestlongitudeVal := longitudecalcVal;
                end;

                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // Write the collected data into the StringList
                // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                // Patch for any language that uses , instead of .
                longitudecalcVal_str := floattostr(longitudecalcVal);
                longitudecalcVal_str := StringReplace(longitudecalcVal_str, ',', '.', [rfReplaceAll]);

                latitudecalcVal_str := floattostr(latitudecalcVal);
                latitudecalcVal_str := StringReplace(latitudecalcVal_str, ',', '.', [rfReplaceAll]);

                kml_main_placemark_StringList.Add('<!--' + Tag306DateTime + '--><Placemark><name>' + kml_placemark_name + kml_placemark_name_model + placemark_name_datetime + '</name>' + kml_snippet + kml_description + style_pin + '<Point>'
                  + kml_date_time + '<coordinates>' + longitudecalcVal_str + ',' + latitudecalcVal_str + '</coordinates></Point></Placemark>');
                linestring_data_StringList.Add('<!--' + Tag306DateTime + '-->' + longitudecalcVal_str + ',' + latitudecalcVal_str + ' ');

              end; // (if calc values are not zero)
            finally
              if assigned(aPropertyTree) then
              begin
                aPropertyTree.free;
                aPropertyTree := nil;
              end;
            end;
          end;
        end;

        Progress.IncCurrentProgress;
        anEntry := EntryList.Next;
      end;

      // Add our Bookmark list
      if bl_chbBookmarkFiles then
        if bmList.Count > 0 then
          NewBookmark(bmGroup, KMLFileName, 'Added to KML', '', DATASTORE_FILESYSTEM, bmList);
      // NewBookmark(bmGroup, 'Jpeg ' + IntToStr(i), 'First 100 bytes bookmarked', DATASTORE_FILESYSTEM, andEntry, 0, 100);

      if bl_chbCreatePath then
      begin
        linestring_footer_StringList.Add('</coordinates>');
        linestring_footer_StringList.Add('</LineString>');
        linestring_footer_StringList.Add('</MultiGeometry>');
        linestring_footer_StringList.Add('</Placemark>');
        linestring_footer_StringList.Add('</Document>');
        linestring_footer_StringList.Add('</kml>');
      end;

      if bl_chbCreatePath = False then
      begin
        kml_main_footer_StringList.Add('</Document>');
        kml_main_footer_StringList.Add('</kml>');
      end;

    finally
      EntryList.free;
      anEntryReader.free;
      ExportEntryReader.free;
      EntryReader.free;
    end;

    // Need to build this string list after the loop so that the earlies 306 Date Time tag is known
    kml_look_at_StringList.Add('<LookAt>');
    if gStartGoogleEarthAbove = 0 then
    begin
      kml_look_at_StringList.Add('<latitude>' + floattostr(earliestlatitudeVal) + '</latitude><longitude>' + floattostr(earliestlongitudeVal) + '</longitude>');
    end
    else
    begin
      kml_look_at_StringList.Add('<latitude>' + gGoogleEarthStartLatitude + '</latitude><longitude>' + gGoogleEarthStartLongitude + '</longitude>');
    end;
    kml_look_at_StringList.Add('<range>' + gGoogleEarthStartAtlitude + '</range><tilt>0</tilt><heading>0</heading>');
    kml_look_at_StringList.Add('</LookAt>');

    // SORT THEN MERGE StringLists ==============================================
    kml_main_placemark_StringList.Sort; // Sorts the placemarks by Tag306 date in the comment field
    kml_main_header_StringList.Addstrings(kml_look_at_StringList);
    kml_main_header_StringList.Addstrings(kml_main_placemark_StringList);
    kml_main_header_StringList.Addstrings(kml_main_footer_StringList);

    linestring_data_StringList.Sort; // Sorts the co-ordinates used to draw the path
    if bl_chbCreatePath then
      linestring_header_StringList.Addstrings(linestring_data_StringList); // Adds the data below the header
    if bl_chbCreatePath then
      linestring_header_StringList.Addstrings(linestring_footer_StringList); // Adds the footer below the data

    if bl_chbCreatePath then
      kml_main_header_StringList.Addstrings(linestring_header_StringList); // Add the StringList used to draw the Path

    if kml_main_header_StringList.Count > 35 then
    begin
      kml_main_header_StringList.SaveToFile(KMLOutputFile); // Write the final StringList to the output file
      Sleep(1000);
      if FileExists(KMLOutputFile) then
      begin
        Progress.Log(RPad('Saved File (Case):', RPAD_VALUE) + KMLOutputFile);
        kml_created_bl := True;
      end;
      // FexLab_Global_Save(KMLOutputFile, kml_main_header_StringList);
    end
    else
    begin
      MessageUser('No GPS files found.');
    end;

    ConsoleLog(RPad('Processed using existing metadata:', RPAD_VALUE) + IntToStr(Processed_Using_Existing_Metadata_Count));
    ConsoleLog(RPad('Files examined for metadata:', RPAD_VALUE) + IntToStr(Metadata_Extractions_Count));
    ConsoleLog(StringOfChar('=', CHAR_LENGTH));
    ConsoleLog('Results:');
    ConsoleLog(RPad('Files with latitude/longitude metadata:', RPAD_VALUE) + (IntToStr(FoundCount)));

    if kml_created_bl then
    begin
      if FileExists(KMLOutputFile) then
      begin
        // MessageUser(RPad('KML created:', RPAD_VALUE) + KMLOutputFile_no_slash);
      end
      else
        MessageUser(RPad('KML creation error:', RPAD_VALUE) + KMLOutputFile);

      if bl_chbExportJpegs then
        ConsoleLog(RPad('JPG files exported:', RPAD_VALUE) + IntToStr(export_file_count));

      // Automatically launch the created KML file in GoogleEarth
      KMLOutputFile_as_string := pwidechar(KMLOutputFile_no_slash);
      KMLOutputFile_formatted := '"' + KMLOutputFile_as_string + '"';

      GoogleEarthLaunchPath_str := '';
      if bl_chbAutoRunGoogleEarth then
      begin
        if FileExists('C:\Program Files (x86)\Google\Google Earth\client\googleearth.exe') then // noslz
          GoogleEarthLaunchPath_str := 'C:\Program Files (x86)\Google\Google Earth\client\googleearth.exe' // noslz
        else if FileExists('C:\Program Files (x86)\Google\Google Earth Pro\client\googleearth.exe') then // noslz
          GoogleEarthLaunchPath_str := 'C:\Program Files (x86)\Google\Google Earth Pro\client\googleearth.exe' // noslz
        else if FileExists('C:\Program Files\Google\Google Earth\client\googleearth.exe') then // noslz
          GoogleEarthLaunchPath_str := 'C:\Program Files\Google\Google Earth\client\googleearth.exe' // noslz
        else if FileExists('C:\Program Files\Google\Google Earth Pro\client\googleearth.exe') then // noslz
          GoogleEarthLaunchPath_str := 'C:\Program Files\Google\Google Earth Pro\client\googleearth.exe' // noslz
        else
          MessageUser('A GoogleEarth installation could not be found. Auto launch is not possible.'); // noslz

        ConsoleLog(RPad('GoogleEarth path:', RPAD_VALUE) + GoogleEarthLaunchPath_str);
      end;
    end;

    if bl_chbAutoRunGoogleEarth then
    begin
      If GoogleEarthLaunchPath_str <> '' then
        ShellExecute(0, nil, GoogleEarthLaunchPath_str, pwidechar(KMLOutputFile_formatted), nil, 1);
    end;

  finally
    gReport_StringList.free;
    kml_look_at_StringList.free;
    kml_main_footer_StringList.free;
    kml_main_header_StringList.free;
    kml_main_placemark_StringList.free;
    linestring_data_StringList.free;
    linestring_footer_StringList.free;
    linestring_header_StringList.free;
  end;
end;

Procedure GetDeviceTList(dTList: TList);
var
  DataStore_EV: TDatastore;
  dEntry: TEntry;
begin
  dTList.clear;
  DataStore_EV := GetDataStore(DATASTORE_EVIDENCE);
  try
    if not assigned(DataStore_EV) then
      Exit;
    dEntry := DataStore_EV.First;
    while assigned(dEntry) and (Progress.isRunning) do
    begin
      if dEntry.IsDevice then
        dTList.Add(dEntry);
      dEntry := DataStore_EV.Next;
    end;
  finally
    DataStore_EV.free;
  end;
end;

function StartingChecks: Boolean;
const
  TSWT = 'The script will terminate.';
var
  CaseName: string;
  StartCheckDataStore: TDatastore;
  StartCheckEntry: TEntry;
begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  try
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      MessageUser('There is no current case.' + SPACE + TSWT);
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      MessageUser('There are no files in the File System module.' + SPACE + TSWT);
      Exit;
    end;
    Result := True; // If this point is reached StartCheck is True
  finally
    FreeAndNil(StartCheckDataStore);
  end;
end;

// ==============================================================================
// Start of the script
// ==============================================================================
begin
  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := (SCRIPT_NAME + ' finished.');
    Exit;
  end;
  gDevice_TList := TList.Create;
  try
    GetDeviceTList(gDevice_TList);
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
    Progress.Log(SCRIPT_NAME + ' started');
    Progress.DisplayTitle := MAIN_FORM_TITLE;
    Progress.DisplayMessage := 'Starting...';
    MainProc;
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
    Progress.Log(SCRIPT_NAME + ' finished.');
    Progress.DisplayMessageNow := (SCRIPT_NAME + ' finished.');
  finally
    gDevice_TList.free;
  end;

end.
