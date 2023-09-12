{ !NAME:      Extract Metadata }
{ !DESC:      Extract Metadata to Columns }
{ !AUTHOR:    GetData }
{ !PARAM:     EXTRACT-METADATA
  EXTRACT-CAMERAS BM-CAMERAS
  EXTRACT-GPS BM-GPS
  EXTRACT-MS-PRINTED }

unit ExtractMetadata;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, DataStreams, DateUtils, Graphics, Math, PropertyList, Regex, SysUtils, Variants;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  // ============================================================================
  // THESE METADATA NODE VALUES ARE TO REMAIN IN ENGLISH - DO NOT TRANSLATE
  // ============================================================================
  NODEBYNAME_Company = 'Company';
  NODEBYNAME_EXIFType = 'Type';
  NODEBYNAME_GPSInfo16GPSImgDirectionRef = 'GPSInfo 16 (GPSImgDirectionRef)'; // noslz
  NODEBYNAME_GPSInfo17GPSImgDirection = 'GPSInfo 17 (GPSImgDirection)'; // noslz
  NODEBYNAME_GPSInfo1GPSLatitudeRef = 'GPSInfo 1 (GPSLatitudeRef)'; // noslz
  NODEBYNAME_GPSInfo29GPSDateStamp = 'GPSInfo 29 (GPSDateStamp)'; // noslz
  NODEBYNAME_GPSInfo2GPSLatitude = 'GPSInfo 2 (GPSLatitude)'; // noslz
  NODEBYNAME_GPSInfo3GPSLongitudeRef = 'GPSInfo 3 (GPSLongitudeRef)'; // noslz
  NODEBYNAME_GPSInfo4GPSLongitude = 'GPSInfo 4 (GPSLongitude)'; // noslz
  NODEBYNAME_GPSInfo6GPSAltitude = 'GPSInfo 6 (GPSAltitude)'; // noslz
  NODEBYNAME_GPSInfo7GPSTimeStamp = 'GPSInfo 7 (GPSTimeStamp)'; // noslz
  NODEBYNAME_JFIFType = 'Type'; // noslz
  NODEBYNAME_LNKAccessTimeUTC = 'Accessed Time (UTC)'; // noslz
  NODEBYNAME_LNKCreationTimeUTC = 'Created Time (UTC)'; // noslz
  NODEBYNAME_LNKDeviceName = 'Device Name'; // noslz
  NODEBYNAME_LNKDriveSerialNumber = 'Drive Serial Number'; // noslz
  NODEBYNAME_LNKDriveType = 'Drive Type'; // noslz
  NODEBYNAME_LNKFileMS = 'LNK File Header'; // noslz
  NODEBYNAME_LNKFileSize = 'File Size'; // noslz
  NODEBYNAME_LNKGUIDMAC = 'GUID MAC'; // noslz
  NODEBYNAME_LNKLinkInfo = 'Link Info'; // noslz
  NODEBYNAME_LNKLocalBasePath = 'Local Base Path'; // noslz
  NODEBYNAME_LNKModifiedTimeUTC = 'Modified Time (UTC)'; // noslz
  NODEBYNAME_LNKNetName = 'Net Name'; // noslz
  NODEBYNAME_LNKTrackerProptertyBlock = 'Tracker Property Block'; // noslz
  NODEBYNAME_LNKVolumeLabel = 'Volume Label'; // noslz
  NODEBYNAME_MSAuthor = 'Author'; // noslz
  NODEBYNAME_MSCompany = 'Company'; // noslz
  NODEBYNAME_MSCreatedUTC = 'Created (UTC)'; // noslz
  NODEBYNAME_MSDocumentSummary = 'OLE Document Summary'; // noslz
  NODEBYNAME_MSEditTime = 'Edit Time'; // noslz
  NODEBYNAME_MSLastSavedby = 'Last Saved by'; // noslz
  NODEBYNAME_MSModifiedUTC = 'Modified (UTC)'; // noslz
  NODEBYNAME_MSPrintedUTC = 'Printed (UTC)'; // noslz
  NODEBYNAME_MSRevision = 'Revision'; // noslz
  NODEBYNAME_MSSubject = 'Subject'; // noslz
  NODEBYNAME_MSSummary = 'OLE Summary'; // DO NOT CHANGE TO MS                 //noslz
  NODEBYNAME_MSTitle = 'Title'; // noslz
  NODEBYNAME_MSWords = 'Words'; // noslz
  NODEBYNAME_NTFS30Filename = '$30 (Filename)'; // noslz
  NODEBYNAME_NTFSAccessedUTC = 'Accessed (UTC)'; // noslz
  NODEBYNAME_NTFSCreatedUTC = 'Created (UTC)'; // noslz
  NODEBYNAME_NTFSModifiedRecordUTC = 'Modified Record (UTC)'; // noslz
  NODEBYNAME_NTFSModifiedUTC = 'Modified (UTC)'; // noslz
  NODEBYNAME_NTFSRecordModifiedUTC = 'Record Modified (UTC)'; // noslz
  NODEBYNAME_PDFAuthor = 'Author'; // noslz
  NODEBYNAME_PDFCreationDate = 'Creation Date'; // noslz
  NODEBYNAME_PDFModificationDate = 'Modification Date'; // noslz
  NODEBYNAME_PDFOwnerPassword = 'Owner Password'; // noslz
  NODEBYNAME_PDFProducer = 'Producer'; // noslz
  NODEBYNAME_PDFTitle = 'Title'; // noslz
  NODEBYNAME_PDFUserPassword = 'User Password'; // noslz
  NODEBYNAME_PrefetchExecutionCount = 'Execution Count'; // noslz
  NODEBYNAME_PrefetchExecutionTimeUTC = 'Execution Time (UTC)'; // noslz
  NODEBYNAME_PrefetchFileName = 'Filename'; // noslz
  NODEBYNAME_PrintSpool_DocumentName = 'Document Name'; // noslz
  NODEBYNAME_PrintSpool_ID = 'SPL ID'; // noslz
  NODEBYNAME_PrintSpool_Size = 'Record Size'; // noslz
  NODEBYNAME_PrintSpoolShadow_ComputerName = 'Computer Name'; // noslz
  NODEBYNAME_PrintSpoolShadow_DevMode = 'Dev Mode'; // noslz
  NODEBYNAME_PrintSpoolShadow_DocumentName = 'Document Name'; // noslz
  NODEBYNAME_PrintSpoolShadow_NotificationName = 'Notification Name'; // noslz
  NODEBYNAME_PrintSpoolShadow_PCName = 'PC Name'; // noslz
  NODEBYNAME_PrintSpoolShadow_PrinterName = 'Printer Name'; // noslz
  NODEBYNAME_PrintSpoolShadow_Signature = 'SHD Signature'; // noslz
  NODEBYNAME_PrintSpoolShadow_SubmitTime = 'Submit Time (UTC)'; // noslz
  NODEBYNAME_PrintSpoolShadow_UserName = 'User Name'; // noslz
  NODEBYNAME_RecycleBinFilename = 'Filename'; // noslz
  NODEBYNAME_RecycleBinFileSize = 'Filesize'; // noslz
  NODEBYNAME_RecycleBinDeletedTimeUTC = 'Deleted time (UTC)'; // noslz
  NODEBYNAME_Tag270Description = 'Tag 270 (Description)'; // noslz
  NODEBYNAME_Tag271Make = 'Tag 271 (Make)'; // noslz
  NODEBYNAME_Tag272DeviceModel = 'Tag 272 (Device Model)'; // noslz
  NODEBYNAME_Tag274Orientation = 'Tag 274 (Orientation)'; // noslz
  NODEBYNAME_Tag282XResolution = 'Tag 282 (X-Resolution)'; // noslz
  NODEBYNAME_Tag283YResolution = 'Tag 283 (Y-Resolution)'; // noslz
  NODEBYNAME_Tag305Software = 'Tag 305 (Software)'; // noslz
  NODEBYNAME_Tag306DateTime = 'Tag 306 (Date/Time)'; // noslz
  NODEBYNAME_Tag315Artist = 'Tag 315 (Artist)'; // noslz
  NODEBYNAME_Tag33432Copyright = 'Tag 33432 (Copyright)'; // noslz
  NODEBYNAME_Tag36867DateTimeOriginal = 'Tag 36867 (DateTimeOriginal)'; // noslz
  NODEBYNAME_TotalTime = 'Total Time'; // noslz
  NODEBYNAME_Words = 'Words'; // noslz
  NODEBYNAME_ZIPNumberItems = 'Number Items'; // noslz
  ROOT_ENTRY_EXIF = 'Marker E1 (EXIF)'; // noslz
  ROOT_ENTRY_HEIF = 'EXIF Data'; // noslz
  ROOT_ENTRY_JFIF = 'Marker E0 (JFIF)'; // noslz
  ROOT_ENTRY_PDF = 'PDF Data'; // noslz
  ROOT_ENTRY_Prefetch = 'PF Data'; // noslz
  ROOT_ENTRY_PrintSpool = 'SPL Data'; // noslz
  ROOT_ENTRY_PrintSpoolShadow = 'SHD Data'; // noslz
  ROOT_ENTRY_RAR = 'RAR Data'; // noslz
  ROOT_ENTRY_RECYCLEBIN = 'Windows Recycle Bin Data'; // noslz
  ROOT_ENTRY_TIFF = 'Image 1'; // noslz
  ROOT_ENTRY_ZIP = 'ZIP Data'; // noslz
  SIG_PRINT_SPOOL = 'PRINT SPOOL'; // noslz
  SIG_PRINT_SPOOL_SHADOW = 'PRINT SPOOL SHADOW'; // noslz
  SIG_WINDOWS_RECYCLE_BIN = 'WINDOWS RECYCLE BIN'; // noslz

  // ============================================================================

  BM_FOLDER_DIGITAL_CAMERAS = 'Digital Cameras';
  BM_FOLDER_GPS_PHOTOS = 'GPS Photos';
  BM_FOLDER_LNK = 'LNK Files By Target Volume';
  BM_FOLDER_MSJUMPLIST = 'MS Jump List Files';
  BM_FOLDER_PDF_AUTHORS = 'PDF Authors';
  BM_FOLDER_PREFTECH = 'Prefetch';
  BM_FOLDER_PRINTSPOOL = 'Print Spool by Document';
  BM_FOLDER_PRINTSPOOLSHADOW = 'Print Spool Shadow by User';
  BM_FOLDER_SCRIPT_OUTPUT = 'FEX-Triage';
  BM_FOLDER_SKINTONE = 'SkinTone';
  BM_MS_AUTHORS = 'MS Authors';
  BM_MS_PRINTED = 'MS Printed';
  CHAR_LENGTH = 80;
  DBS = '\\';
  FINISHED_STR = 'Finished';
  HYPHEN = ' - ';
  RUNNING = '...';
  SCRIPT_NAME = 'Extract Metadata';
  SPACE = ' ';
  STR_BOOKMARK_METADATA = 'Bookmark Metadata';
  STR_EXTRACT_METADATA = 'Extract Metadata';
  TSWT = 'The script will terminate.';

var
  bl_force_extract: boolean = False;
  gbl_Show_About_Tab: boolean;
  gbl_Show_Columns_Tab: boolean;
  gbl_Show_Options_Tab: boolean;
  gbl_Show_results_Tab: boolean;
  gbl_ShowGUI: boolean;
  gbl_Working_Count: integer;
  Progress_Display_Title: string;
  result_StringList: TStringList;

  Param_Bookmark_EXIF: boolean;
  Param_Bookmark_GPS: boolean;
  Param_Bookmark_LNK: boolean;
  Param_Bookmark_MSAuthor: boolean;
  Param_Bookmark_MSJUMPLIST: boolean;
  Param_Bookmark_MSPrinted: boolean;
  Param_Bookmark_PDFAuthor: boolean;
  Param_Bookmark_PREFETCH: boolean;
  Param_Bookmark_PRINTSPOOL: boolean;
  Param_Bookmark_RecycleBinPath: boolean;
  Param_EXIF_Process: boolean;
  Param_GPS_Process: boolean;
  Param_LNK_Process: boolean;
  Param_MessBox_Message: string;
  Param_MessBox_ShowForce: boolean;
  Param_MessBox_Title: string;
  Param_MS_Process: boolean;
  Param_MSJUMPLIST_Process: boolean;
  Param_NTFS_Process: boolean;
  Param_PDF_Process: boolean;
  Param_PF_Process: boolean;
  Param_PrintSpool_Process: boolean;
  Param_RecycleBin_Process: boolean;
  Param_ZIP_Process: boolean;

  // Column Names, also used for reporting
  str_Exif270Description: string;
  str_Exif271Make: string;
  str_Exif272DeviceModel: string;
  str_Exif274Orientation: string;
  str_Exif282XResolution: string;
  str_Exif283YResolution: string;
  str_Exif305Software: string;
  str_Exif306DateTime: string;
  str_Exif315Artist: string;
  str_Exif33432Copyright: string;
  str_Exif36867DateTimeOriginal: string;
  str_EXIFType: string;
  str_GPSInfo16DirectionRef: string;
  str_GPSInfo17Direction: string;
  str_GPSInfo1LatRef: string;
  str_GPSInfo29DateStamp: string;
  str_GPSInfo2Lat: string;
  str_GPSInfo3LongRef: string;
  str_GPSInfo4Long: string;
  str_GPSInfo6Altitude: string;
  str_GPSInfo7TimeStamp: string;
  str_GPSLatcalc: string;
  str_GPSLongcalc: string;
  str_JFifType: string;
  str_LNKTargetAccessedUTC: string;
  str_LNKTargetCreatedUTC: string;
  str_LNKTargetDeviceName: string;
  str_LNKTargetDriveType: string;
  str_LNKGUIDMAC: string;
  str_LNKTargetLocalBasePath: string;
  str_LNKTargetModifiedUTC: string;
  str_LNKTargetNetName: string;
  str_LNKTargetSize: string;
  str_LNKTargetVolumeLabel: string;
  str_LNKTargetVolumeSerial: string;
  str_MSAuthor: string;
  str_MSAuthorName: string; // (not a column name - used to hold temp value of str_MSAuthor for bookmarking)
  str_MSCompany: string;
  str_MSCreated: string;
  str_MSEditTime: string;
  str_MSLastSavedby: string;
  str_MSModified: string;
  str_MSPrinted: string;
  str_MSRevision: string;
  str_MSSubject: string;
  str_MSTitle: string;
  str_MSWordCount: string;
  str_NTFS30AccessedUTC: string;
  str_NTFS30CreatedUTC: string;
  str_NTFS30ModifiedUTC: string;
  str_NTFS30RecordModifiedUTC: string;
  str_PDFAuthor: string;
  str_PDFCreationDate: string;
  str_PDFModificationDate: string;
  str_PDFOwnerPwd: string;
  str_PDFProducer: string;
  str_PDFTitle: string;
  str_PDFUserPwd: string;
  str_PrefetchExecutionCount: string;
  str_PrefetchExecutionTime: string;
  str_PrefetchFilename: string;
  str_PrintSpool_DocumentName: string;
  str_PrintSpoolShadow_ComputerName: string;
  str_PrintSpoolShadow_DevMode: string;
  str_PrintSpoolShadow_DocumentName: string;
  str_PrintSpoolShadow_NotificationName: string;
  str_PrintSpoolShadow_PCName: string;
  str_PrintSpoolShadow_PrinterName: string;
  str_PrintSpoolShadow_Signature: string;
  str_PrintSpoolShadow_SubmitTime: string;
  str_PrintSpoolShadow_UserName: string;
  str_RecycleBinOriginalFilename: string;
  str_RecycleBinOriginalFilesize: string;
  str_RecycleBinDeletedTimeUTC: string;
  str_ZIPNumberItems: string;

  // COUNTING VARIABLES---------------------------------------------------------
  // RunningFoundCount: integer;
  countEXIFType: integer;
  countGPSInfo16DirectionRef: integer;
  countGPSInfo17Direction: integer;
  countGPSInfo1LatitudeRef: integer;
  countGPSInfo29DateStamp: integer;
  countGPSInfo2Latitude: integer;
  countGPSInfo3LongitudeRef: integer;
  countGPSInfo4Longitude: integer;
  countGPSInfo6Altitude: integer;
  countGPSInfo7TimeStamp: integer;
  countGPSPosLatitude: integer;
  countGPSPosLongitude: integer;
  countJFifType: integer;
  countLNKFileAccessed: integer;
  countLNKFileCreated: integer;
  countLNKFileDeviceName: integer;
  countLNKFileDriveSerialNumber: integer;
  countLNKFileDriveType: integer;
  countLNKFileGUIDMAC: integer;
  countLNKFileLocalBasePath: integer;
  countLNKFileModified: integer;
  countLNKFileNetName: integer;
  countLNKFileSize: integer;
  countLNKFileVolumeLabel: integer;
  countMSAuthor: integer;
  countMSCompany: integer;
  countMSCreated: integer;
  countMSEditTime: integer;
  countMSJUMPLISTFileAccessed: integer;
  countMSJUMPLISTFileCreated: integer;
  countMSJUMPLISTFileDeviceName: integer;
  countMSJUMPLISTFileDriveSerialNumber: integer;
  countMSJUMPLISTFileDriveType: integer;
  countMSJUMPLISTFileGUIDMAC: integer;
  countMSJUMPLISTFileLocalBasePath: integer;
  countMSJUMPLISTFileModified: integer;
  countMSJUMPLISTFileNetName: integer;
  countMSJUMPLISTFileSize: integer;
  countMSJUMPLISTFileVolumeLabel: integer;
  countMSLastSavedby: integer;
  countMSModified: integer;
  countMSPrinted: integer;
  countMSRevision: integer;
  countMSSubject: integer;
  countMSTitle: integer;
  countMSWordCount: integer;
  countNTFS30FileNameAccessed: integer;
  countNTFS30FileNameCreated: integer;
  countNTFS30FileNameModified: integer;
  countNTFS30FileNameRecordModified: integer;
  countPDFAuthor: integer;
  countPDFCreationDate: integer;
  countPDFModificationDate: integer;
  countPDFOwnerPassword: integer;
  countPDFProducer: integer;
  countPDFTitle: integer;
  countPDFUserPassword: integer;
  countPFExecutionCount: integer;
  countPFExecutionTime: integer;
  countPFFilename: integer;
  countPrintSpool_DocumentName: integer;
  countPrintSpoolShadow_ComputerName: integer;
  countPrintSpoolShadow_DevMode: integer;
  countPrintSpoolShadow_DocumentName: integer;
  countPrintSpoolShadow_NotificationName: integer;
  countPrintSpoolShadow_PCName: integer;
  countPrintSpoolShadow_PrinterName: integer;
  countPrintSpoolShadow_Signature: integer;
  countPrintSpoolShadow_SubmitTime: integer;
  countPrintSpoolShadow_UserName: integer;
  countRecycleBinDeletedTimeUTC: integer;
  countRecycleBinOriginalFilename: integer;
  countRecycleBinOriginalFileSize: integer;
  countTag270Description: integer;
  countTag271Make: integer;
  countTag272DeviceModel: integer;
  countTag274Orientation: integer;
  countTag282XResolution: integer;
  countTag283YResolution: integer;
  countTag305Software: integer;
  countTag306DateTime: integer;
  countTag315Artist: integer;
  countTag33432Copyright: integer;
  countTag36867DateTimeOriginal: integer;
  countZIPNumberItems: integer;
  TotalFoundCount: integer;

  // VARIABLES FOR COLUMN NAMES-------------------------------------------------
  colEXIFType: TDataStoreField;
  colGPSInfo16DirectionRef: TDataStoreField;
  colGPSInfo17Direction: TDataStoreField;
  colGPSInfo1LatitudeRef: TDataStoreField;
  colGPSInfo29DateStamp: TDataStoreField;
  colGPSInfo2Latitude: TDataStoreField;
  colGPSInfo3LongitudeRef: TDataStoreField;
  colGPSInfo4Longitude: TDataStoreField;
  colGPSInfo6Altitude: TDataStoreField;
  colGPSInfo7TimeStamp: TDataStoreField;
  colGPSPosLatitude: TDataStoreField;
  colGPSPosLongitude: TDataStoreField;
  colJFifType: TDataStoreField;
  colLNKFileAccessed: TDataStoreField;
  colLNKFileCreated: TDataStoreField;
  colLNKFileDeviceName: TDataStoreField;
  colLNKFileDriveSerialNumber: TDataStoreField;
  colLNKFileDriveType: TDataStoreField;
  colLNKFileGUIDMAC: TDataStoreField;
  colLNKFileLocalBasePath: TDataStoreField;
  colLNKFileModified: TDataStoreField;
  colLNKFileNetName: TDataStoreField;
  colLNKFileSize: TDataStoreField;
  colLNKFileVolumeLabel: TDataStoreField;
  colMSAuthor: TDataStoreField;
  colMSCompany: TDataStoreField;
  colMSCreated: TDataStoreField;
  colMSEditTime: TDataStoreField;
  colMSLastSavedby: TDataStoreField;
  colMSModified: TDataStoreField;
  colMSPrinted: TDataStoreField;
  colMSRevision: TDataStoreField;
  colMSSubject: TDataStoreField;
  colMSTitle: TDataStoreField;
  colMSWordCount: TDataStoreField;
  colNTFS30FileNameAccessed: TDataStoreField;
  colNTFS30FileNameCreated: TDataStoreField;
  colNTFS30FileNameModified: TDataStoreField;
  colNTFS30FileNameRecordModified: TDataStoreField;
  colPDFAuthor: TDataStoreField;
  colPDFCreationDate: TDataStoreField;
  colPDFModificationDate: TDataStoreField;
  colPDFOwnerPassword: TDataStoreField;
  colPDFProducer: TDataStoreField;
  colPDFTitle: TDataStoreField;
  colPDFUserPassword: TDataStoreField;
  colPFExecutionCount: TDataStoreField;
  colPFExecutionTime: TDataStoreField;
  colPFFilename: TDataStoreField;
  colPrintSpool_DocumentName: TDataStoreField;
  colPrintSpoolShadow_ComputerName: TDataStoreField;
  colPrintSpoolShadow_DevMode: TDataStoreField;
  colPrintSpoolShadow_DocumentName: TDataStoreField;
  colPrintSpoolShadow_NotificationName: TDataStoreField;
  colPrintSpoolShadow_PCName: TDataStoreField;
  colPrintSpoolShadow_PrinterName: TDataStoreField;
  colPrintSpoolShadow_Signature: TDataStoreField;
  colPrintSpoolShadow_SubmitTime: TDataStoreField;
  colPrintSpoolShadow_Username: TDataStoreField;
  colRecycleBinDeletedTimeUTC: TDataStoreField;
  colRecycleBinOriginalFilename: TDataStoreField;
  colRecycleBinOriginalFileSize: TDataStoreField;
  colTag270Description: TDataStoreField;
  colTag271Make: TDataStoreField;
  colTag272DeviceModel: TDataStoreField;
  colTag274Orientation: TDataStoreField;
  colTag282XResolution: TDataStoreField;
  colTag283YResolution: TDataStoreField;
  colTag305Software: TDataStoreField;
  colTag306DateTime: TDataStoreField;
  colTag315Artist: TDataStoreField;
  colTag33432Copyright: TDataStoreField;
  colTag36867DateTimeOriginal: TDataStoreField;
  colZIPNumberItems: TDataStoreField;

  // Progress Bar Text
  pb_EXIF: string;
  pb_GPS: string;
  pb_LNK: string;
  pb_Metadata: string;
  pb_MS: string;
  pb_MSJUMPLIST: string;
  pb_NTFS: string;
  pb_PDF: string;
  pb_PF: string;
  pb_SPL: string;
  pb_RecycleBin: string;
  pb_ZIP: string;

  PrintSpoolComment: string;
  rpad_value: integer;

implementation

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

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

procedure gdh1(show_bl: boolean; aStringList: TStringList);
var
  i: integer;
begin
  for i := 0 to aStringList.Count - 1 do
  begin
    if POS(str_Exif270Description, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif270Description);
    if POS(str_Exif271Make, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif271Make);
    if POS(str_Exif272DeviceModel, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif272DeviceModel);
    if POS(str_Exif274Orientation, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif274Orientation);
    if POS(str_Exif282XResolution, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif282XResolution);
    if POS(str_Exif283YResolution, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif283YResolution);
    if POS(str_Exif305Software, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif305Software);
    if POS(str_Exif306DateTime, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif306DateTime);
    if POS(str_Exif315Artist, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif315Artist);
    if POS(str_Exif33432Copyright, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif33432Copyright);
    if POS(str_Exif36867DateTimeOriginal, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_Exif36867DateTimeOriginal);
    if POS(str_EXIFType, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_EXIFType);
    if POS(str_GPSInfo16DirectionRef, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo16DirectionRef);
    if POS(str_GPSInfo17Direction, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo17Direction);
    if POS(str_GPSInfo1LatRef, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo1LatRef);
    if POS(str_GPSInfo29DateStamp, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo29DateStamp);
    if POS(str_GPSInfo2Lat, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo2Lat);
    if POS(str_GPSInfo3LongRef, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo3LongRef);
    if POS(str_GPSInfo4Long, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo4Long);
    if POS(str_GPSInfo6Altitude, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo6Altitude);
    if POS(str_GPSInfo7TimeStamp, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSInfo7TimeStamp);
    if POS(str_GPSLatcalc, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSLatcalc);
    if POS(str_GPSLongcalc, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_GPSLongcalc);
    if POS(str_JFifType, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_JFifType);
    if POS(str_LNKTargetAccessedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetAccessedUTC);
    if POS(str_LNKTargetCreatedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetCreatedUTC);
    if POS(str_LNKTargetDeviceName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetDeviceName);
    if POS(str_LNKTargetDriveType, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetDriveType);
    if POS(str_LNKGUIDMAC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKGUIDMAC);
    if POS(str_LNKTargetLocalBasePath, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetLocalBasePath);
    if POS(str_LNKTargetModifiedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetModifiedUTC);
    if POS(str_LNKTargetNetName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetNetName);
    if POS(str_LNKTargetSize, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetSize);
    if POS(str_LNKTargetVolumeLabel, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetVolumeLabel);
    if POS(str_LNKTargetVolumeSerial, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_LNKTargetVolumeSerial);
    if POS(str_MSAuthor, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSAuthor);
    if POS(str_MSCompany, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSCompany);
    if POS(str_MSCreated, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSCreated);
    if POS(str_MSEditTime, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSEditTime);
    if POS(str_MSLastSavedby, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSLastSavedby);
    if POS(str_MSModified, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSModified);
    if POS(str_MSPrinted, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSPrinted);
    if POS(str_MSRevision, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSRevision);
    if POS(str_MSSubject, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSSubject);
    if POS(str_MSTitle, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSTitle);
    if POS(str_MSWordCount, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_MSWordCount);
    if POS(str_NTFS30AccessedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_NTFS30AccessedUTC);
    if POS(str_NTFS30CreatedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_NTFS30CreatedUTC);
    if POS(str_NTFS30ModifiedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_NTFS30ModifiedUTC);
    if POS(str_NTFS30RecordModifiedUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_NTFS30RecordModifiedUTC);
    if POS(str_PDFAuthor, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFAuthor);
    if POS(str_PDFCreationDate, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFCreationDate);
    if POS(str_PDFModificationDate, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFModificationDate);
    if POS(str_PDFOwnerPwd, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFOwnerPwd);
    if POS(str_PDFProducer, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFProducer);
    if POS(str_PDFTitle, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFTitle);
    if POS(str_PDFUserPwd, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PDFUserPwd);
    if POS(str_PrefetchExecutionCount, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrefetchExecutionCount);
    if POS(str_PrefetchExecutionTime, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrefetchExecutionTime);
    if POS(str_PrefetchFilename, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrefetchFilename);
    if POS(str_PrintSpool_DocumentName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpool_DocumentName);
    if POS(str_PrintSpoolShadow_ComputerName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_ComputerName);
    if POS(str_PrintSpoolShadow_DevMode, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_DevMode);
    if POS(str_PrintSpoolShadow_DocumentName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_DocumentName);
    if POS(str_PrintSpoolShadow_NotificationName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_NotificationName);
    if POS(str_PrintSpoolShadow_PCName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_PCName);
    if POS(str_PrintSpoolShadow_PrinterName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_PrinterName);
    if POS(str_PrintSpoolShadow_Signature, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_Signature);
    if POS(str_PrintSpoolShadow_SubmitTime, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_SubmitTime);
    if POS(str_PrintSpoolShadow_UserName, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_PrintSpoolShadow_UserName);
    if POS(str_RecycleBinOriginalFilename, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_RecycleBinOriginalFilename);
    if POS(str_RecycleBinOriginalFilesize, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_RecycleBinOriginalFilesize);
    if POS(str_RecycleBinDeletedTimeUTC, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_RecycleBinDeletedTimeUTC);
    if POS(str_ZIPNumberItems, aStringList[i]) > 0 then
      ProcessCol(show_bl, str_ZIPNumberItems);
  end;
end;

// Procedure: Create Column Names
procedure CreateColumnNames;
begin
  if Param_EXIF_Process then
  begin
    colJFifType := AddMetaDataField(str_JFifType, ftString);
    colEXIFType := AddMetaDataField(str_EXIFType, ftString);
    colTag270Description := AddMetaDataField(str_Exif270Description, ftString);
    colTag271Make := AddMetaDataField(str_Exif271Make, ftString);
    colTag272DeviceModel := AddMetaDataField(str_Exif272DeviceModel, ftString);
    colTag274Orientation := AddMetaDataField(str_Exif274Orientation, ftString);
    colTag282XResolution := AddMetaDataField(str_Exif282XResolution, ftFloat);
    colTag283YResolution := AddMetaDataField(str_Exif283YResolution, ftFloat);
    colTag305Software := AddMetaDataField(str_Exif305Software, ftString);
    colTag306DateTime := AddMetaDataField(str_Exif306DateTime, ftString);
    colTag315Artist := AddMetaDataField(str_Exif315Artist, ftString);
    colTag36867DateTimeOriginal := AddMetaDataField(str_Exif36867DateTimeOriginal, ftString);
    colTag33432Copyright := AddMetaDataField(str_Exif33432Copyright, ftString);
    colGPSPosLatitude := AddMetaDataField(str_GPSLatcalc, ftFloat);
    colGPSPosLongitude := AddMetaDataField(str_GPSLongcalc, ftFloat);
    colGPSInfo1LatitudeRef := AddMetaDataField(str_GPSInfo1LatRef, ftString);
    colGPSInfo2Latitude := AddMetaDataField(str_GPSInfo2Lat, ftString);
    colGPSInfo3LongitudeRef := AddMetaDataField(str_GPSInfo3LongRef, ftString);
    colGPSInfo4Longitude := AddMetaDataField(str_GPSInfo4Long, ftString);
    colGPSInfo6Altitude := AddMetaDataField(str_GPSInfo6Altitude, ftFloat);
    colGPSInfo7TimeStamp := AddMetaDataField(str_GPSInfo7TimeStamp, ftString);
    colGPSInfo16DirectionRef := AddMetaDataField(str_GPSInfo16DirectionRef, ftString);
    colGPSInfo17Direction := AddMetaDataField(str_GPSInfo17Direction, ftFloat);
    colGPSInfo29DateStamp := AddMetaDataField(str_GPSInfo29DateStamp, ftString);
  end;

  if Param_MS_Process then
  begin
    colMSCreated := AddMetaDataField(str_MSCreated, ftDateTime);
    colMSModified := AddMetaDataField(str_MSModified, ftDateTime);
    colMSPrinted := AddMetaDataField(str_MSPrinted, ftDateTime);
    colMSTitle := AddMetaDataField(str_MSTitle, ftString);
    colMSAuthor := AddMetaDataField(str_MSAuthor, ftString);
    colMSLastSavedby := AddMetaDataField(str_MSLastSavedby, ftString);
    colMSSubject := AddMetaDataField(str_MSSubject, ftString);
    colMSCompany := AddMetaDataField(str_MSCompany, ftString);
    colMSWordCount := AddMetaDataField(str_MSWordCount, ftInteger);
    colMSRevision := AddMetaDataField(str_MSRevision, ftInteger);
    colMSEditTime := AddMetaDataField(str_MSEditTime, ftInteger);
  end;

  if Param_PDF_Process then
  begin
    colPDFAuthor := AddMetaDataField(str_PDFAuthor, ftString);
    colPDFTitle := AddMetaDataField(str_PDFTitle, ftString);
    colPDFProducer := AddMetaDataField(str_PDFProducer, ftString);
    colPDFCreationDate := AddMetaDataField(str_PDFCreationDate, ftString);
    colPDFModificationDate := AddMetaDataField(str_PDFModificationDate, ftString);
    colPDFUserPassword := AddMetaDataField(str_PDFUserPwd, ftString);
    colPDFOwnerPassword := AddMetaDataField(str_PDFOwnerPwd, ftString);
  end;

  if Param_NTFS_Process then
  begin
    colNTFS30FileNameCreated := AddMetaDataField(str_NTFS30CreatedUTC, ftDateTime);
    colNTFS30FileNameModified := AddMetaDataField(str_NTFS30ModifiedUTC, ftDateTime);
    colNTFS30FileNameRecordModified := AddMetaDataField(str_NTFS30RecordModifiedUTC, ftDateTime);
    colNTFS30FileNameAccessed := AddMetaDataField(str_NTFS30AccessedUTC, ftDateTime);
  end;

  if Param_LNK_Process or Param_MSJUMPLIST_Process then
  begin
    colLNKFileCreated := AddMetaDataField(str_LNKTargetCreatedUTC, ftDateTime);
    colLNKFileModified := AddMetaDataField(str_LNKTargetModifiedUTC, ftDateTime);
    colLNKFileAccessed := AddMetaDataField(str_LNKTargetAccessedUTC, ftDateTime);
    colLNKFileSize := AddMetaDataField(str_LNKTargetSize, ftLargeInt);
    colLNKFileLocalBasePath := AddMetaDataField(str_LNKTargetLocalBasePath, ftString);
    colLNKFileGUIDMAC := AddMetaDataField(str_LNKGUIDMAC, ftString);
    colLNKFileDriveSerialNumber := AddMetaDataField(str_LNKTargetVolumeSerial, ftString);
    colLNKFileVolumeLabel := AddMetaDataField(str_LNKTargetVolumeLabel, ftString);
    colLNKFileDriveType := AddMetaDataField(str_LNKTargetDriveType, ftString);
    colLNKFileDeviceName := AddMetaDataField(str_LNKTargetDeviceName, ftString);
    colLNKFileNetName := AddMetaDataField(str_LNKTargetNetName, ftString);
  end;

  if Param_PF_Process then
  begin
    colPFFilename := AddMetaDataField(str_PrefetchFilename, ftString);
    colPFExecutionTime := AddMetaDataField(str_PrefetchExecutionTime, ftDateTime);
    colPFExecutionCount := AddMetaDataField(str_PrefetchExecutionCount, ftInteger);
  end;

  if Param_PrintSpool_Process then
  begin
    colPrintSpool_DocumentName := AddMetaDataField(str_PrintSpool_DocumentName, ftString);
    colPrintSpoolShadow_ComputerName := AddMetaDataField(str_PrintSpoolShadow_ComputerName, ftString);
    colPrintSpoolShadow_DevMode := AddMetaDataField(str_PrintSpoolShadow_DevMode, ftString);
    colPrintSpoolShadow_DocumentName := AddMetaDataField(str_PrintSpoolShadow_DocumentName, ftString);
    colPrintSpoolShadow_NotificationName := AddMetaDataField(str_PrintSpoolShadow_NotificationName, ftString);
    colPrintSpoolShadow_PCName := AddMetaDataField(str_PrintSpoolShadow_PCName, ftString);
    colPrintSpoolShadow_PrinterName := AddMetaDataField(str_PrintSpoolShadow_PrinterName, ftString);
    colPrintSpoolShadow_Signature := AddMetaDataField(str_PrintSpoolShadow_Signature, ftString);
    colPrintSpoolShadow_SubmitTime := AddMetaDataField(str_PrintSpoolShadow_SubmitTime, ftDateTime);
    colPrintSpoolShadow_Username := AddMetaDataField(str_PrintSpoolShadow_UserName, ftString);
  end;

  if Param_RecycleBin_Process then
  begin
    colRecycleBinOriginalFilename := AddMetaDataField(str_RecycleBinOriginalFilename, ftString);
    colRecycleBinOriginalFileSize := AddMetaDataField(str_RecycleBinOriginalFilesize, ftLargeInt);
    colRecycleBinDeletedTimeUTC := AddMetaDataField(str_RecycleBinDeletedTimeUTC, ftDateTime);
  end;

  if Param_ZIP_Process then
  begin
    colZIPNumberItems := AddMetaDataField(str_ZIPNumberItems, ftInteger);
  end;
end;

procedure InitializeCounters;
begin
  countGPSInfo1LatitudeRef := 0;
  countGPSInfo3LongitudeRef := 0;
  countGPSPosLatitude := 0;
  countGPSPosLongitude := 0;
  countLNKFileAccessed := 0;
  countLNKFileCreated := 0;
  countLNKFileDeviceName := 0;
  countLNKFileDriveSerialNumber := 0;
  countLNKFileDriveType := 0;
  countLNKFileGUIDMAC := 0;
  countLNKFileLocalBasePath := 0;
  countLNKFileModified := 0;
  countLNKFileNetName := 0;
  countLNKFileSize := 0;
  countLNKFileVolumeLabel := 0;
  countMSAuthor := 0;
  countMSCompany := 0;
  countMSCreated := 0;
  countMSEditTime := 0;
  countMSJUMPLISTFileAccessed := 0;
  countMSJUMPLISTFileCreated := 0;
  countMSJUMPLISTFileDeviceName := 0;
  countMSJUMPLISTFileDriveSerialNumber := 0;
  countMSJUMPLISTFileDriveType := 0;
  countMSJUMPLISTFileLocalBasePath := 0;
  countMSJUMPLISTFileModified := 0;
  countMSJUMPLISTFileNetName := 0;
  countMSJUMPLISTFileSize := 0;
  countMSJUMPLISTFileVolumeLabel := 0;
  countMSLastSavedby := 0;
  countMSModified := 0;
  countMSPrinted := 0;
  countMSRevision := 0;
  countMSSubject := 0;
  countMSTitle := 0;
  countMSWordCount := 0;
  countNTFS30FileNameAccessed := 0;
  countNTFS30FileNameCreated := 0;
  countNTFS30FileNameModified := 0;
  countNTFS30FileNameRecordModified := 0;
  countPDFAuthor := 0;
  countPDFCreationDate := 0;
  countPDFModificationDate := 0;
  countPDFOwnerPassword := 0;
  countPDFProducer := 0;
  countPDFTitle := 0;
  countPDFUserPassword := 0;
  countPFExecutionCount := 0;
  countPFExecutionTime := 0;
  countPFFilename := 0;
  countGPSInfo16DirectionRef := 0;
  countGPSInfo17Direction := 0;
  countGPSInfo29DateStamp := 0;
  countGPSInfo2Latitude := 0;
  countGPSInfo4Longitude := 0;
  countGPSInfo6Altitude := 0;
  countGPSInfo7TimeStamp := 0;
  countTag270Description := 0;
  countTag271Make := 0;
  countTag272DeviceModel := 0;
  countTag274Orientation := 0;
  countTag282XResolution := 0;
  countTag283YResolution := 0;
  countTag305Software := 0;
  countTag306DateTime := 0;
  countTag315Artist := 0;
  countTag33432Copyright := 0;
  countTag36867DateTimeOriginal := 0;
  TotalFoundCount := 0;
end;

// ------------------------------------------------------------------------------
// Procedure: Jump List - Locate Jump List files, Expand them, then run a signature check on the expanded files
// ------------------------------------------------------------------------------
procedure ProcessJumpList(aTList: TList);
var
  Expand_TList: TList;
  FileSignatureInfo: TFileTypeInformation;
  jlEntry: TEntry;
  jlFileExt: string;
  jlParentFileExt: string;
  JUMP_Progress: TPAC;
  msjumplist_count: integer;
  Uppername: string;
  i: integer;
begin
  JUMP_Progress := NewProgress(False);
  msjumplist_count := 0;
  if assigned(aTList) and (aTList.Count > 0) then
  begin
    Expand_TList := TList.Create;
    try
      Progress.Initialize(aTList.Count, 'Find and expand MS Jump List files' + RUNNING);
      Progress.CurrentPosition := 0;
      for i := 0 to aTList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        jlEntry := TEntry(aTList[i]);
        Uppername := UpperCase(jlEntry.EntryName);
        FileSignatureInfo := jlEntry.FileDriverInfo;
        jlFileExt := lowercase(jlEntry.EntryNameExt);
        if (jlFileExt = '.automaticdestinations-ms') then
        begin
          if not(dstExpanded in jlEntry.Status) then
          begin
            DetermineFileType(jlEntry);
            Expand_TList.Add(jlEntry);
            msjumplist_count := msjumplist_count + 1;
          end
          else
          begin
            msjumplist_count := msjumplist_count + 1;
          end;
        end;
        Progress.IncCurrentProgress(1);
      end;
      if Expand_TList.Count > 0 then
        ExpandCompoundFiles(Expand_TList, DATASTORE_FILESYSTEM, JUMP_Progress);
      Progress.Log(RPad('MS Jump List files found:', rpad_value) + IntToStr(msjumplist_count));
      if assigned(aTList) and (aTList.Count > 0) then
      begin
        Progress.Initialize(aTList.Count, 'Expanded MS Jump List Signature Analysis' + RUNNING);
        Progress.DisplayMessageNow := 'Expanded MS Jump List Signature Analysis' + RUNNING;
        for i := 0 to aTList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          jlEntry := TEntry(aTList[i]);
          Uppername := UpperCase(jlEntry.EntryName);
          FileSignatureInfo := jlEntry.FileDriverInfo;
          if assigned(jlEntry) then
          begin
            if jlEntry.parent <> nil then
            begin
              jlParentFileExt := lowercase(jlEntry.parent.EntryNameExt);
              if (jlParentFileExt = '.automaticdestinations-ms') then
              begin
                DetermineFileType(jlEntry);
              end;
            end;
            Progress.IncCurrentProgress(1);
          end;
        end;
      end;
    finally
      Expand_TList.free;
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Process NTFS
// ------------------------------------------------------------------------------
procedure process_NTFS(aTList: TList);
var
  anEntryReader: TEntryReader;
  i: integer;
  anEntry: TEntry;
  aPropertyTree: TPropertyParent;
  aRootEntry: TPropertyNode;
  AParentNode: TPropertyNode;
  proceed_with_NTFS_extraction: boolean;
  NTFSFound: boolean;
begin
  anEntryReader := TEntryReader.Create;
  try
    if Param_NTFS_Process then
    begin
      Progress.Initialize(aTList.Count, 'Scanning NTFS records' + RUNNING);
      Progress.Log('Scanning NTFS records' + RUNNING);

      if assigned(aTList) and (aTList.Count > 0) then
      begin
        for i := 0 to aTList.Count - 1 do
        begin
          if not Progress.isRunning then
            Exit;
          anEntry := TEntry(aTList[i]);

          proceed_with_NTFS_extraction := True;
          NTFSFound := False;
          // ====================================================================
          // TEST NTFS COLUMNS FOR Count METADATA
          // ====================================================================
          if (colNTFS30FileNameCreated.isNull(anEntry)) and (colNTFS30FileNameModified.isNull(anEntry)) and (colNTFS30FileNameRecordModified.isNull(anEntry)) and (colNTFS30FileNameAccessed.isNull(anEntry)) then
          begin
            proceed_with_NTFS_extraction := True;
          end
          else
            proceed_with_NTFS_extraction := False;

          if bl_force_extract then
            proceed_with_NTFS_extraction := True;

          if proceed_with_NTFS_extraction = True then
          begin
            if ProcessDisplayProperties(anEntry, aPropertyTree, anEntryReader) then
              try
                if assigned(aPropertyTree) then
                begin
                  aRootEntry := aPropertyTree.RootProperty;
                  if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
                  begin
                    try
                      AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_NTFS30Filename));
                      if assigned(AParentNode) then
                      begin
                        AddFileTimeColumn(AParentNode, anEntry, colNTFS30FileNameCreated, NODEBYNAME_NTFSCreatedUTC, countNTFS30FileNameCreated);
                        AddFileTimeColumn(AParentNode, anEntry, colNTFS30FileNameModified, NODEBYNAME_NTFSModifiedUTC, countNTFS30FileNameModified);
                        AddFileTimeColumn(AParentNode, anEntry, colNTFS30FileNameRecordModified, NODEBYNAME_NTFSModifiedRecordUTC, countNTFS30FileNameRecordModified);
                        AddFileTimeColumn(AParentNode, anEntry, colNTFS30FileNameAccessed, NODEBYNAME_NTFSAccessedUTC, countNTFS30FileNameAccessed);
                      end;
                    finally
                      AParentNode := nil;
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
          Progress.IncCurrentProgress;
        end; { for loop }
        Progress.IncCurrentProgress(1);
        Progress.DisplayMessages := IntToStr(i) + ' files scanned for NTFS metadata';
      end;
    end;
  finally
    anEntryReader.free;
  end;
end;

procedure BookmarkResults(bmEntry: TEntry);
var
  bmGroup: TEntry;
  bmPDFAuthor: string;
  bmPrintSpool_DocumentName: string;
  bmPrintSpoolShadowUsername: string;
  BookmarkFolderName: string;
  DriveType: string;
  dtstr: string;
  FileSignatureInfo: TFileTypeInformation;
  ParentFileExt: string;
  SerialNo: string;
  Tag271Make_str: string;
  Tag272Model_str: string;
  UpperDrv: string;
  VolLabel: string;

begin
  FileSignatureInfo := bmEntry.FileDriverInfo;

  // GPS PHOTOS
  if Param_Bookmark_GPS then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'JPG') or (UpperDrv = 'TIFF') or (UpperDrv = 'HEIF') then
    begin
      if not(colGPSPosLatitude.isNull(bmEntry)) and not(colGPSPosLongitude.isNull(bmEntry)) then
      begin
        // Cater for GPS files that have GPS co-ordinates but do not have a Make or Model tag
        if colTag271Make.AsString[bmEntry] = '' then
          Tag271Make_str := 'No Make'
        else
          Tag271Make_str := colTag271Make.AsString[bmEntry];
        if colTag272DeviceModel.AsString[bmEntry] = '' then
          Tag272Model_str := 'No Model'
        else
          Tag272Model_str := colTag272DeviceModel.AsString[bmEntry];
        BookmarkFolderName := Tag271Make_str + HYPHEN + Tag272Model_str;
        bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_GPS_PHOTOS + '\' + BookmarkFolderName);
        if bmGroup = nil then
          bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_GPS_PHOTOS + '\' + BookmarkFolderName);
        if not IsItemInBookmark(bmGroup, bmEntry) then
          AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, BookmarkFolderName);
      end;
    end;
  end;

  // CAMERA MAKE AND MODEL
  if Param_Bookmark_EXIF then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'JPG') or (UpperDrv = 'TIFF') or (UpperDrv = 'HEIF') then
    begin
      if not(colTag271Make.isNull(bmEntry)) and not(colTag272DeviceModel.isNull(bmEntry)) then
      begin
        OutList.Add(bmEntry);
        BookmarkFolderName := colTag271Make.AsString[bmEntry] + HYPHEN + colTag272DeviceModel.AsString[bmEntry];
        StripIllegalChars(BookmarkFolderName);
        bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_DIGITAL_CAMERAS + '\' + BookmarkFolderName);
        if bmGroup = nil then
          bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_DIGITAL_CAMERAS + '\' + BookmarkFolderName);
        if not IsItemInBookmark(bmGroup, bmEntry) then
          AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, BookmarkFolderName);
      end;
    end;
  end;

  // MS Author
  if Param_Bookmark_MSAuthor then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'WORD') or (UpperDrv = 'POWERPOINT') or (UpperDrv = 'EXCEL') or (UpperDrv = 'DOCX') or (UpperDrv = 'XLSX') or (UpperDrv = 'PPTX') then
    begin
      if not(colMSAuthor.isNull(bmEntry)) then
        str_MSAuthorName := colMSAuthor.AsString[bmEntry]
      else
        str_MSAuthorName := 'No Author';
      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_MS_AUTHORS + '\' + str_MSAuthorName);
      if bmGroup = nil then
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_MS_AUTHORS + '\' + str_MSAuthorName);
      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, str_MSAuthorName);
    end;
  end;

  // MS Printed
  if Param_Bookmark_MSPrinted then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'WORD') or (UpperDrv = 'POWERPOINT') or (UpperDrv = 'EXCEL') or (UpperDrv = 'DOCX') or (UpperDrv = 'XLSX') or (UpperDrv = 'PPTX') then
    begin
      if not(colMSPrinted.isNull(bmEntry)) then
        dtstr := FormatDateTime('yyyy-mm-dd', colMSPrinted.AsDateTime[bmEntry])
      else
        dtstr := 'No Date Printed';
      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_MS_PRINTED + '\' + dtstr);
      if bmGroup = nil then
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_MS_PRINTED + '\' + dtstr);
      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, dtstr);
    end;
  end;

  // Bookmark PDF
  if Param_Bookmark_PDFAuthor then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'PDF') then
    begin
      if not(colPDFAuthor.isNull(bmEntry)) then
        bmPDFAuthor := colPDFAuthor.AsString[bmEntry]
      else
        bmPDFAuthor := 'No Author';

      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_PDF_AUTHORS + '\' + bmPDFAuthor);
      if bmGroup = nil then
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_PDF_AUTHORS + '\' + bmPDFAuthor);
      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, bmPDFAuthor);
    end;
  end;

  // Bookmark PF
  if Param_Bookmark_PREFETCH then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'PREFETCH') then
    begin
      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\Prefetch');
      if bmGroup = nil then
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\Prefetch');
      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark Print Spool
  if Param_Bookmark_PRINTSPOOL then
  begin

    // SPL
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = SIG_PRINT_SPOOL) then // noslz
    begin

      if not(colPrintSpool_DocumentName.isNull(bmEntry)) then
        bmPrintSpool_DocumentName := colPrintSpool_DocumentName.AsString[bmEntry]
      else
        bmPrintSpool_DocumentName := 'Unknown';

      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_PRINTSPOOL + '\' + bmPrintSpool_DocumentName);
      if bmGroup = nil then
      begin
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_PRINTSPOOL + '\' + bmPrintSpool_DocumentName);
      end;

      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, BookmarkFolderName);
    end;

    // SHD
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then // noslz
    begin

      if not(colPrintSpoolShadow_Username.isNull(bmEntry)) then
        bmPrintSpoolShadowUsername := colPrintSpoolShadow_Username.AsString[bmEntry]
      else
        bmPrintSpoolShadowUsername := 'Unknown';

      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_PRINTSPOOLSHADOW + '\' + bmPrintSpoolShadowUsername);
      if bmGroup = nil then
      begin
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_PRINTSPOOLSHADOW + '\' + bmPrintSpoolShadowUsername);
      end;

      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, PrintSpoolComment);
      PrintSpoolComment := '';
    end;

  end;

  // Bookmark LNK by Volume Label / Serial / Type
  if Param_Bookmark_LNK then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'LNK') then
    begin
      OutList.Add(bmEntry);

      if colLNKFileVolumeLabel.isNull(bmEntry) or (colLNKFileVolumeLabel.AsString[bmEntry] = '') then
        VolLabel := '<Empty volume label>'
      else
        VolLabel := colLNKFileVolumeLabel.AsString[bmEntry];

      if colLNKFileDriveSerialNumber.isNull(bmEntry) or (colLNKFileDriveSerialNumber.AsString[bmEntry] = '') then
        SerialNo := '<Empty serial number>'
      else
        SerialNo := colLNKFileDriveSerialNumber.AsString[bmEntry];

      if colLNKFileDriveType.isNull(bmEntry) or (colLNKFileDriveType.AsString[bmEntry] = '') then
        DriveType := '<Empty drive type>'
      else
        DriveType := colLNKFileDriveType.AsString[bmEntry];

      BookmarkFolderName := VolLabel + HYPHEN + SerialNo + HYPHEN + DriveType;
      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_LNK + '\' + BookmarkFolderName);
      if bmGroup = nil then
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_LNK + '\' + BookmarkFolderName);
      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark MS Jump List
  if Param_Bookmark_MSJUMPLIST then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    ParentFileExt := lowercase(bmEntry.parent.EntryNameExt);
    if (UpperDrv = 'LNK') and (ParentFileExt = '.automaticdestinations-ms') then // Exclude the other LNK files
    begin
      BookmarkFolderName := bmEntry.parent.EntryName;
      bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_MSJUMPLIST + '\' + BookmarkFolderName);
      if bmGroup = nil then
        bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + '\' + BM_FOLDER_MSJUMPLIST + '\' + BookmarkFolderName);
      if not IsItemInBookmark(bmGroup, bmEntry) then
        AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, BookmarkFolderName);
    end;
  end;
end;

// ============================================================================
// procedure: Process Files
// ============================================================================
procedure ProcessFiles(process_TList: TList);
var
  afEntry: TEntry;
  afEntryReader: TEntryReader;
  aPropertyTree: TPropertyParent;
  aRootEntry: TPropertyNode;
  FileSignatureInfo: TFileTypeInformation;
  p: integer;
  ParentFileExt: string;
  proceed_with_EXIF_extraction: boolean;
  proceed_with_extraction: boolean;
  proceed_with_LNK_extraction: boolean;
  proceed_with_MS_extraction: boolean;
  proceed_with_MSJUMPLIST_extraction: boolean;
  proceed_with_PDF_extraction: boolean;
  proceed_with_PF_extraction: boolean;
  proceed_with_PrintSpool_extraction: boolean;
  proceed_with_RecycleBin_extraction: boolean;
  proceed_with_ZIP_extraction: boolean;
  UpperDrv: string;
  Uppername: string;

begin
  Progress.Initialize(process_TList.Count, 'Scanning files for metadata' + RUNNING);

  aPropertyTree := nil;
  Progress.DisplayMessages := 'Scanning for ' + pb_Metadata + pb_EXIF + pb_GPS + pb_LNK + pb_MSJUMPLIST + pb_MS + pb_NTFS + pb_PDF + pb_PF + pb_RecycleBin + pb_ZIP + ' metadata';
  if assigned(process_TList) and (process_TList.Count > 0) then
    afEntryReader := TEntryReader.Create;
  try
    for p := 0 to process_TList.Count - 1 do
    begin
      if not Progress.isRunning then
        Exit;
      afEntry := TEntry(process_TList[p]);

      if assigned(afEntry) then
      begin
        Uppername := UpperCase(afEntry.EntryName);
        FileSignatureInfo := afEntry.FileDriverInfo;

        proceed_with_extraction := False;
        proceed_with_EXIF_extraction := False;
        proceed_with_MS_extraction := False;
        proceed_with_PDF_extraction := False;
        proceed_with_LNK_extraction := False;
        proceed_with_MSJUMPLIST_extraction := False;
        proceed_with_PF_extraction := False;
        proceed_with_PrintSpool_extraction := False;
        proceed_with_RecycleBin_extraction := False;
        proceed_with_ZIP_extraction := False;

        // ==================================================================
        // FILTER ALL RELEVANT FILE TYPES HERE
        // ==================================================================
        UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);

        if (FileSignatureInfo.FileDriverNumber > 0) and (((Param_EXIF_Process) and (UpperDrv = 'JPG')) or ((Param_EXIF_Process) and (UpperDrv = 'TIFF')) or ((Param_EXIF_Process) and (UpperDrv = 'HEIF')) or
          ((Param_MS_Process) and (UpperDrv = 'WORD')) or ((Param_MS_Process) and (UpperDrv = 'EXCEL')) or ((Param_MS_Process) and (UpperDrv = 'POWERPOINT')) or ((Param_PDF_Process) and (UpperDrv = 'PDF')) or
          ((Param_LNK_Process) and (UpperDrv = 'LNK')) or ((Param_MSJUMPLIST_Process) and (UpperDrv = 'LNK')) or ((Param_PF_Process) and (UpperDrv = 'PREFETCH')) or ((Param_PrintSpool_Process) and (UpperDrv = SIG_PRINT_SPOOL)) or
          ((Param_PrintSpool_Process) and (UpperDrv = SIG_PRINT_SPOOL_SHADOW)) or ((Param_RecycleBin_Process) and ((UpperDrv = SIG_WINDOWS_RECYCLE_BIN) or (RegexMatch(afEntry.EntryName, '^\$I', True)))) or
          ((Param_ZIP_Process) and (UpperDrv = 'ZIP')) or ((Param_ZIP_Process) and (UpperDrv = 'TAR')) or ((Param_ZIP_Process) and (UpperDrv = 'RAR')) or ((Param_MS_Process) and (UpperDrv = 'DOCX')) or
          ((Param_MS_Process) and (UpperDrv = 'PPTX')) or ((Param_MS_Process) and (UpperDrv = 'XLSX'))) then
        begin

          // ================================================================
          // TEST COLUMNS FOR - EXIF (JPG)
          // ================================================================
          if Param_EXIF_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = 'JPG') or (UpperDrv = 'TIFF') or (UpperDrv = 'HEIF') then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colJFifType.isNull(afEntry)) and (colEXIFType.isNull(afEntry)) and (colTag270Description.isNull(afEntry)) and (colTag271Make.isNull(afEntry)) and (colTag272DeviceModel.isNull(afEntry)) and
                  (colTag274Orientation.isNull(afEntry)) and (colTag305Software.isNull(afEntry)) and (colTag306DateTime.isNull(afEntry)) and (colTag315Artist.isNull(afEntry)) and (colTag36867DateTimeOriginal.isNull(afEntry)) and
                  (colTag33432Copyright.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_EXIF_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_EXIF_extraction = False) then
            begin
              if not(colJFifType.isNull(afEntry)) then
                countJFifType := countJFifType + 1;
              if not(colEXIFType.isNull(afEntry)) then
                countEXIFType := countEXIFType + 1;
              if not(colTag270Description.isNull(afEntry)) then
                countTag270Description := countTag270Description + 1;
              if not(colTag271Make.isNull(afEntry)) then
                countTag271Make := countTag271Make + 1;
              if not(colTag272DeviceModel.isNull(afEntry)) then
                countTag272DeviceModel := countTag272DeviceModel + 1;
              if not(colTag274Orientation.isNull(afEntry)) then
                countTag274Orientation := countTag274Orientation + 1;
              if not(colTag282XResolution.isNull(afEntry)) then
                countTag282XResolution := countTag282XResolution + 1;
              if not(colTag283YResolution.isNull(afEntry)) then
                countTag283YResolution := countTag283YResolution + 1;
              if not(colTag305Software.isNull(afEntry)) then
                countTag305Software := countTag305Software + 1;
              if not(colTag306DateTime.isNull(afEntry)) then
                countTag306DateTime := countTag306DateTime + 1;
              if not(colTag315Artist.isNull(afEntry)) then
                countTag315Artist := countTag315Artist + 1;
              if not(colTag36867DateTimeOriginal.isNull(afEntry)) then
                countTag36867DateTimeOriginal := countTag36867DateTimeOriginal + 1;
              if not(colTag33432Copyright.isNull(afEntry)) then
                countTag33432Copyright := countTag33432Copyright + 1;
              // Lets also count the GPS metadata if present--------------------------------------------------------------------------------------------------------------------------------------
              if not(colGPSPosLatitude.isNull(afEntry)) then
                countGPSPosLatitude := countGPSPosLatitude + 1;
              if not(colGPSPosLongitude.isNull(afEntry)) then
                countGPSPosLongitude := countGPSPosLongitude + 1;
              if not(colGPSInfo1LatitudeRef.isNull(afEntry)) then
                countGPSInfo1LatitudeRef := countGPSInfo1LatitudeRef + 1;
              if not(colGPSInfo2Latitude.isNull(afEntry)) then
                countGPSInfo2Latitude := countGPSInfo2Latitude + 1;
              if not(colGPSInfo3LongitudeRef.isNull(afEntry)) then
                countGPSInfo3LongitudeRef := countGPSInfo3LongitudeRef + 1;
              if not(colGPSInfo4Longitude.isNull(afEntry)) then
                countGPSInfo4Longitude := countGPSInfo4Longitude + 1;
              if not(colGPSInfo6Altitude.isNull(afEntry)) then
                countGPSInfo6Altitude := countGPSInfo6Altitude + 1;
              if not(colGPSInfo7TimeStamp.isNull(afEntry)) then
                countGPSInfo7TimeStamp := countGPSInfo7TimeStamp + 1;
              if not(colGPSInfo16DirectionRef.isNull(afEntry)) then
                countGPSInfo16DirectionRef := countGPSInfo16DirectionRef + 1;
              if not(colGPSInfo17Direction.isNull(afEntry)) then
                countGPSInfo17Direction := countGPSInfo17Direction + 1;
              if not(colGPSInfo29DateStamp.isNull(afEntry)) then
                countGPSInfo29DateStamp := countGPSInfo29DateStamp + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - LNK
          // ================================================================
          if Param_LNK_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = 'LNK') then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colLNKFileAccessed.isNull(afEntry)) and (colLNKFileCreated.isNull(afEntry)) and (colLNKFileDriveSerialNumber.isNull(afEntry)) and (colLNKFileDriveType.isNull(afEntry)) and (colLNKFileGUIDMAC.isNull(afEntry)) and
                  (colLNKFileLocalBasePath.isNull(afEntry)) and (colLNKFileModified.isNull(afEntry)) and (colLNKFileSize.isNull(afEntry)) and (colLNKFileVolumeLabel.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_LNK_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_LNK_extraction = False) then
            begin
              if not(colLNKFileAccessed.isNull(afEntry)) then
                countLNKFileAccessed := countLNKFileAccessed + 1;
              if not(colLNKFileCreated.isNull(afEntry)) then
                countLNKFileCreated := countLNKFileCreated + 1;
              if not(colLNKFileDeviceName.isNull(afEntry)) then
                countLNKFileDeviceName := countLNKFileDeviceName + 1;
              if not(colLNKFileDriveSerialNumber.isNull(afEntry)) then
                countLNKFileDriveSerialNumber := countLNKFileDriveSerialNumber + 1;
              if not(colLNKFileDriveType.isNull(afEntry)) then
                countLNKFileDriveType := countLNKFileDriveType + 1;
              if not(colLNKFileGUIDMAC.isNull(afEntry)) then
                countLNKFileGUIDMAC := countLNKFileGUIDMAC + 1;
              if not(colLNKFileLocalBasePath.isNull(afEntry)) then
                countLNKFileLocalBasePath := countLNKFileLocalBasePath + 1;
              if not(colLNKFileModified.isNull(afEntry)) then
                countLNKFileModified := countLNKFileModified + 1;
              if not(colLNKFileNetName.isNull(afEntry)) then
                countLNKFileNetName := countLNKFileNetName + 1;
              if not(colLNKFileSize.isNull(afEntry)) then
                countLNKFileSize := countLNKFileSize + 1;
              if not(colLNKFileVolumeLabel.isNull(afEntry)) then
                countLNKFileVolumeLabel := countLNKFileVolumeLabel + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - MSJUMPLIST
          // ================================================================
          if Param_MSJUMPLIST_Process then
          begin
            if afEntry.parent <> nil then
            begin
              ParentFileExt := lowercase(afEntry.parent.EntryNameExt);
              if (ParentFileExt = '.automaticdestinations-ms') then
              begin
                if (UpperCase(FileSignatureInfo.ShortDisplayName) = 'LNK') then
                begin
                  DetermineFileType(afEntry);
                  FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                  begin
                    if (colLNKFileAccessed.isNull(afEntry)) and (colLNKFileCreated.isNull(afEntry)) and (colLNKFileDriveSerialNumber.isNull(afEntry)) and (colLNKFileDriveType.isNull(afEntry)) and (colLNKFileGUIDMAC.isNull(afEntry)) and
                      (colLNKFileLocalBasePath.isNull(afEntry)) and (colLNKFileModified.isNull(afEntry)) and (colLNKFileSize.isNull(afEntry)) and (colLNKFileVolumeLabel.isNull(afEntry)) then
                    begin
                      proceed_with_extraction := True;
                      proceed_with_MSJUMPLIST_extraction := True;
                    end;
                  end;
                end;
              end;
            end;

            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_MSJUMPLIST_extraction = False) then
            begin
              if afEntry.parent <> nil then
              begin
                ParentFileExt := lowercase(afEntry.parent.EntryNameExt);
                if (ParentFileExt = '.automaticdestinations-ms') then
                begin
                  if (UpperCase(FileSignatureInfo.ShortDisplayName) = 'LNK') then
                  begin
                    DetermineFileType(afEntry);
                    FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                    begin
                      if not(colLNKFileAccessed.isNull(afEntry)) then
                        countMSJUMPLISTFileAccessed := countMSJUMPLISTFileAccessed + 1;
                      if not(colLNKFileCreated.isNull(afEntry)) then
                        countMSJUMPLISTFileCreated := countMSJUMPLISTFileCreated + 1;
                      if not(colLNKFileDeviceName.isNull(afEntry)) then
                        countMSJUMPLISTFileDeviceName := countMSJUMPLISTFileDeviceName + 1;
                      if not(colLNKFileDriveSerialNumber.isNull(afEntry)) then
                        countMSJUMPLISTFileDriveSerialNumber := countMSJUMPLISTFileDriveSerialNumber + 1;
                      if not(colLNKFileDriveType.isNull(afEntry)) then
                        countMSJUMPLISTFileDriveType := countMSJUMPLISTFileDriveType + 1;
                      if not(colLNKFileGUIDMAC.isNull(afEntry)) then
                        countMSJUMPLISTFileGUIDMAC := countMSJUMPLISTFileGUIDMAC + 1;
                      if not(colLNKFileLocalBasePath.isNull(afEntry)) then
                        countMSJUMPLISTFileLocalBasePath := countMSJUMPLISTFileLocalBasePath + 1;
                      if not(colLNKFileModified.isNull(afEntry)) then
                        countMSJUMPLISTFileModified := countMSJUMPLISTFileModified + 1;
                      if not(colLNKFileNetName.isNull(afEntry)) then
                        countMSJUMPLISTFileNetName := countMSJUMPLISTFileNetName + 1;
                      if not(colLNKFileSize.isNull(afEntry)) then
                        countMSJUMPLISTFileSize := countMSJUMPLISTFileSize + 1;
                      if not(colLNKFileVolumeLabel.isNull(afEntry)) then
                        countMSJUMPLISTFileVolumeLabel := countMSJUMPLISTFileVolumeLabel + 1;
                    end;
                  end;
                end;
              end;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - MS
          // ================================================================
          if Param_MS_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = 'WORD') or (UpperDrv = 'POWERPOINT') or (UpperDrv = 'EXCEL') or (UpperDrv = 'DOCX') or (UpperDrv = 'PPTX') or (UpperDrv = 'XLSX') then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colMSAuthor.isNull(afEntry)) and (colMSCreated.isNull(afEntry)) and (colMSLastSavedby.isNull(afEntry)) and (colMSModified.isNull(afEntry)) and (colMSTitle.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_MS_extraction := True;
                end;
              end;
            end;

            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_MS_extraction = False) then
            begin
              if not(colMSAuthor.isNull(afEntry)) then
                countMSAuthor := countMSAuthor + 1;
              if not(colMSCreated.isNull(afEntry)) then
                countMSCreated := countMSCreated + 1;
              if not(colMSLastSavedby.isNull(afEntry)) then
                countMSLastSavedby := countMSLastSavedby + 1;
              if not(colMSModified.isNull(afEntry)) then
                countMSModified := countMSModified + 1;
              if not(colMSSubject.isNull(afEntry)) then
                countMSSubject := countMSSubject + 1;
              if not(colMSCompany.isNull(afEntry)) then
                countMSCompany := countMSCompany + 1;
              if not(colMSTitle.isNull(afEntry)) then
                countMSTitle := countMSTitle + 1;
              if not(colMSPrinted.isNull(afEntry)) then
                countMSPrinted := countMSPrinted + 1;
              if not(colMSWordCount.isNull(afEntry)) then
                countMSWordCount := countMSWordCount + 1;
              if not(colMSRevision.isNull(afEntry)) then
                countMSRevision := countMSRevision + 1;
              if not(colMSEditTime.isNull(afEntry)) then
                countMSEditTime := countMSEditTime + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - PDF
          // ================================================================
          if Param_PDF_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = 'PDF') then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colPDFAuthor.isNull(afEntry)) and (colPDFTitle.isNull(afEntry)) and (colPDFProducer.isNull(afEntry)) and (colPDFCreationDate.isNull(afEntry)) and (colPDFModificationDate.isNull(afEntry)) and
                  (colPDFUserPassword.isNull(afEntry)) and (colPDFOwnerPassword.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_PDF_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_PDF_extraction = False) then
            begin
              if not(colPDFAuthor.isNull(afEntry)) then
                countPDFAuthor := countPDFAuthor + 1;
              if not(colPDFTitle.isNull(afEntry)) then
                countPDFTitle := countPDFTitle + 1;
              if not(colPDFProducer.isNull(afEntry)) then
                countPDFProducer := countPDFProducer + 1;
              if not(colPDFCreationDate.isNull(afEntry)) then
                countPDFCreationDate := countPDFCreationDate + 1;
              if not(colPDFModificationDate.isNull(afEntry)) then
                countPDFModificationDate := countPDFModificationDate + 1;
              if not(colPDFUserPassword.isNull(afEntry)) then
                countPDFUserPassword := countPDFUserPassword + 1;
              if not(colPDFOwnerPassword.isNull(afEntry)) then
                countPDFOwnerPassword := countPDFOwnerPassword + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - PREFETCH
          // ================================================================
          if Param_PF_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = 'PREFETCH') then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colPFFilename.isNull(afEntry)) and (colPFExecutionTime.isNull(afEntry)) and (colPFExecutionCount.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_PF_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_PF_extraction = False) then
            begin
              if not(colPFFilename.isNull(afEntry)) then
                countPFFilename := countPFFilename + 1;
              if not(colPFExecutionTime.isNull(afEntry)) then
                countPFExecutionTime := countPFExecutionTime + 1;
              if not(colPFExecutionCount.isNull(afEntry)) then
                countPFExecutionCount := countPFExecutionCount + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - PRINT SPOOL
          // ================================================================
          if Param_PrintSpool_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = SIG_PRINT_SPOOL) or (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colPrintSpool_DocumentName.isNull(afEntry)) or (colPrintSpoolShadow_ComputerName.isNull(afEntry)) or (colPrintSpoolShadow_DevMode.isNull(afEntry)) or (colPrintSpoolShadow_DocumentName.isNull(afEntry)) or
                  (colPrintSpoolShadow_NotificationName.isNull(afEntry)) or (colPrintSpoolShadow_PCName.isNull(afEntry)) or (colPrintSpoolShadow_PrinterName.isNull(afEntry)) or (colPrintSpoolShadow_Signature.isNull(afEntry)) or
                  (colPrintSpoolShadow_SubmitTime.isNull(afEntry)) or (colPrintSpoolShadow_Username.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_PrintSpool_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_PrintSpool_extraction = False) then
            begin
              if not(colPrintSpool_DocumentName.isNull(afEntry)) then
                countPrintSpool_DocumentName := countPrintSpool_DocumentName + 1;
              if not(colPrintSpoolShadow_ComputerName.isNull(afEntry)) then
                countPrintSpoolShadow_ComputerName := countPrintSpoolShadow_ComputerName + 1;
              if not(colPrintSpoolShadow_DevMode.isNull(afEntry)) then
                countPrintSpoolShadow_DevMode := countPrintSpoolShadow_DevMode + 1;
              if not(colPrintSpoolShadow_DocumentName.isNull(afEntry)) then
                countPrintSpoolShadow_DocumentName := countPrintSpoolShadow_DocumentName + 1;
              if not(colPrintSpoolShadow_NotificationName.isNull(afEntry)) then
                countPrintSpoolShadow_NotificationName := countPrintSpoolShadow_NotificationName + 1;
              if not(colPrintSpoolShadow_PCName.isNull(afEntry)) then
                countPrintSpoolShadow_PCName := countPrintSpoolShadow_PCName + 1;
              if not(colPrintSpoolShadow_PrinterName.isNull(afEntry)) then
                countPrintSpoolShadow_PrinterName := countPrintSpoolShadow_PrinterName + 1;
              if not(colPrintSpoolShadow_Signature.isNull(afEntry)) then
                countPrintSpoolShadow_Signature := countPrintSpoolShadow_Signature + 1;
              if not(colPrintSpoolShadow_SubmitTime.isNull(afEntry)) then
                countPrintSpoolShadow_SubmitTime := countPrintSpoolShadow_SubmitTime + 1;
              if not(colPrintSpoolShadow_Username.isNull(afEntry)) then
                countPrintSpoolShadow_UserName := countPrintSpoolShadow_UserName + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - Recycle bin
          // ================================================================
          if Param_RecycleBin_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = SIG_WINDOWS_RECYCLE_BIN) or (RegexMatch(afEntry.EntryName, '^\$I', True)) then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = SIG_WINDOWS_RECYCLE_BIN) then
              begin
                if (colRecycleBinOriginalFilename.isNull(afEntry)) or (colRecycleBinOriginalFileSize.isNull(afEntry)) or (colRecycleBinDeletedTimeUTC.isNull(afEntry)) then
                begin
                  proceed_with_RecycleBin_extraction := True;
                  proceed_with_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_extraction = False) then
            begin
              if not(colRecycleBinOriginalFilename.isNull(afEntry)) then
                countRecycleBinOriginalFilename := countRecycleBinOriginalFilename + 1;
              if not(colRecycleBinOriginalFileSize.isNull(afEntry)) then
                countRecycleBinOriginalFileSize := countRecycleBinOriginalFileSize + 1;
              if not(colRecycleBinDeletedTimeUTC.isNull(afEntry)) then
                countRecycleBinDeletedTimeUTC := countRecycleBinDeletedTimeUTC + 1;
            end;
          end;

          // ================================================================
          // TEST COLUMNS FOR - ZIP
          // ================================================================
          if Param_ZIP_Process then
          begin
            UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
            if (UpperDrv = 'ZIP') or (UpperDrv = 'RAR') or (UpperDrv = 'TAR') then
            begin
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              begin
                if (colZIPNumberItems.isNull(afEntry)) then
                begin
                  proceed_with_extraction := True;
                  proceed_with_ZIP_extraction := True;
                end;
              end;
            end;
            // Count the metadata in the columns
            if (bl_force_extract = False) and (proceed_with_ZIP_extraction = False) then
            begin
              if not(colZIPNumberItems.isNull(afEntry)) then
                countZIPNumberItems := countZIPNumberItems + 1;
            end;
          end;

          // ================================================================
          // PROCEED WITH EXTRACTION
          // ================================================================
          if bl_force_extract or proceed_with_extraction then
          begin
            // Progress.Log('About to process: ' + afEntry.EntryName + ' Bates#:' + (IntToStr(afEntry.ID)));
            DetermineFileType(afEntry);
            FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
            if ProcessMetadataProperties(afEntry, aPropertyTree, afEntryReader) then
            begin
              if assigned(aPropertyTree) then
                try
                  aRootEntry := aPropertyTree.RootProperty;
                  if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
                  begin
                    // Progress.Log('Proceed with process: '+afEntry.FullPathName);
                    Uppername := UpperCase(afEntry.EntryName);
                    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                    if (FileSignatureInfo.FileDriverNumber > 0) then
                    begin

                      // ---EXIF----------------------------------------------
                      if (UpperDrv = 'JPG') or (UpperDrv = 'TIFF') or (UpperDrv = 'HEIF') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('EXIF OR JFif process - FORCE ON: '+afEntry.FullPathName);
                          ProcessJPG(afEntry, aRootEntry, UpperDrv);
                          ProcessJFif(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_EXIF_Process and (proceed_with_EXIF_extraction) then
                          begin
                            // Progress.Log('EXIF OR JFif process : '+afEntry.FullPathName);
                            ProcessJPG(afEntry, aRootEntry, UpperDrv);
                            ProcessJFif(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---OLE-----------------------------------------------
                      else if (UpperDrv = 'WORD') or (UpperDrv = 'POWERPOINT') or (UpperDrv = 'EXCEL') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('MS process - FORCE ON: '+afEntry.FullPathName);
                          ProcessMS(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_MS_Process and proceed_with_MS_extraction THEN
                          begin
                            // Progress.Log('MS process: '+afEntry.FullPathName);
                            ProcessMS(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---DOCX----------------------------------------------
                      else if (UpperDrv = 'DOCX') or (UpperDrv = 'XLSX') or (UpperDrv = 'PPTX') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('DOCX process - FORCE ON: '+afEntry.FullPathName);
                          ProcessDOCX(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_MS_Process and proceed_with_MS_extraction THEN
                          begin
                            // Progress.Log('MS process: '+afEntry.FullPathName);
                            ProcessDOCX(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---PDF-----------------------------------------------
                      else if (UpperDrv = 'PDF') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('PDF process - FORCE ON: '+afEntry.FullPathName);
                          ProcessPDF(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_PDF_Process and proceed_with_PDF_extraction THEN
                          begin
                            ProcessPDF(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---LNK-----------------------------------------------
                      else if (UpperDrv = 'LNK') and (ParentFileExt <> '.automaticdestinations-ms') then // Exclude the other LNK files
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('LNK process - FORCE ON: '+afEntry.FullPathName);
                          ProcessLNK(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_LNK_Process and proceed_with_LNK_extraction THEN
                          begin
                            // Progress.Log('LNK process: ' + afEntry.FullPathName);
                            ProcessLNK(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---MS JUMP LIST--------------------------------------
                      else if (UpperDrv = 'LNK') and (ParentFileExt = '.automaticdestinations-ms') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('MS Jump List process - FORCE ON: '+afEntry.FullPathName);
                          ProcessMSJUMPLIST(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_MSJUMPLIST_Process and proceed_with_MSJUMPLIST_extraction THEN
                          begin
                            // Progress.Log('MS Jump List process: '+afEntry.FullPathName);
                            ProcessMSJUMPLIST(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---PREFETCH------------------------------------------
                      else if (UpperDrv = 'PREFETCH') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('PF process - FORCE ON: '+afEntry.FullPathName);
                          ProcessPF(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_PF_Process and proceed_with_PF_extraction THEN
                          begin
                            // Progress.Log('PF process: '+afEntry.FullPathName);
                            ProcessPF(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---PRINTSPOOL----------------------------------------
                      else if (UpperDrv = SIG_PRINT_SPOOL) or (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('Print Spool process - FORCE ON: '+afEntry.FullPathName);
                          ProcessPrintSpool(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_PrintSpool_Process and proceed_with_PrintSpool_extraction then
                          begin
                            // Progress.Log('Print Spool process: '+afEntry.FullPathName);
                            ProcessPrintSpool(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---Recycle Bin-------------------------------------------
                      else if (UpperDrv = SIG_WINDOWS_RECYCLE_BIN) then
                      begin
                        if bl_force_extract then
                        begin
                          Progress.Log('RecycleBin process - FORCE ON: ' + afEntry.FullPathName);
                          ProcessRecycleBin(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_RecycleBin_Process and proceed_with_RecycleBin_extraction then
                          begin
                            // Progress.Log('RecycleBin process: '+afEntry.FullPathName);
                            ProcessRecycleBin(afEntry, aRootEntry);
                          end;
                        end;
                      end

                      // ---ZIP-----------------------------------------------
                      else if (UpperDrv = 'ZIP') then
                      begin
                        if bl_force_extract then
                        begin
                          // Progress.Log('ZIP process - FORCE ON: '+afEntry.FullPathName);
                          ProcessZIP(afEntry, aRootEntry);
                        end
                        else
                        begin
                          if Param_ZIP_Process and proceed_with_ZIP_extraction then
                          begin
                            // Progress.Log('ZIP process: '+afEntry.FullPathName);
                            ProcessZIP(afEntry, aRootEntry);
                          end;
                        end;
                      end;

                    end;
                  end
                  else
                  begin
                    // Progress.Log('Could not open file: ' + afEntry.FullPathName);
                  end;
                finally
                  if assigned(aPropertyTree) then
                  begin
                    aPropertyTree.free;
                    aPropertyTree := nil;
                  end;
                end;
            end;
          end; { force extract }

          BookmarkResults(afEntry); // Bookmark the files that do not need extraction

        end; { filter by  file type }
      end;
      Progress.IncCurrentProgress;
    end; { for loop }
  finally
    afEntryReader.free;
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
    Progress.Log(RPad(ListName_str + SPACE + 'count:', rpad_value) + IntToStr(aList.Count));
    Result := True;
  end
  else
    Progress.Log(RPad('Not Assigned:', rpad_value) + ListName_str);
end;

// =========================================================================================================================================================================
// Procedure: Main Proc
// =========================================================================================================================================================================
procedure MainProc;
var
  anEntry: TEntry;
  aPropertyTree: TPropertyParent;
  EntryList: TDataStore;
  Working_TList: TList;
  i, k: integer;
  gbl_UseInList: boolean;

begin
  Progress.DisplayTitle := Progress_Display_Title;

  aPropertyTree := nil;
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if EntryList = nil then
    Exit;

  anEntry := EntryList.First;
  if anEntry = nil then
  begin
    if gbl_ShowGUI then
      Progress.Log('There are no files in the File System module.');
    Progress.Log('No files in the File System module. Script terminated.');
    EntryList.free;
    Exit;
  end;

  if not Progress.isRunning then
  begin
    Progress.Log('Progress is not running. The script will terminate.');
    EntryList.free;
    Exit;
  end;

  gbl_UseInList := False;

  Working_TList := TList.Create;
  try
    if (CmdLine.Params.Indexof('InList') >= 0) then
      gbl_UseInList := True;

    // If InList parameter is received then work with InList
    if gbl_UseInList then
    begin
      if (not ListExists(InList, 'InList')) or (not ListExists(OutList, 'OutList')) then
        Exit
      else
      begin
        if InList.Count = 0 then
        begin
          Progress.Log('InList count is zero.' + SPACE + TSWT);
          Exit;
        end;
      end;
      for i := 0 to InList.Count - 1 do
      begin
        anEntry := TEntry(InList[i]);
        if not anEntry.IsDirectory then // We only want files
          Working_TList.Add(anEntry);
      end;
    end
    else
    // Else work with the entire list
    begin
      Working_TList := EntryList.GetEntireList;
      Progress.Log(RPad('Working with All items:', rpad_value) + IntToStr(Working_TList.Count));
    end;

    Progress.Log(StringOfChar('-', CHAR_LENGTH));
    Progress.Log(RPad('EXIF:', rpad_value) + BoolToStr(Param_EXIF_Process, True));
    Progress.Log(RPad('GPS:', rpad_value) + BoolToStr(Param_GPS_Process, True));
    Progress.Log(RPad('LNK:', rpad_value) + BoolToStr(Param_LNK_Process, True));
    Progress.Log(RPad('MS JumpList:', rpad_value) + BoolToStr(Param_MSJUMPLIST_Process, True));
    Progress.Log(RPad('MS:', rpad_value) + BoolToStr(Param_MS_Process, True));
    Progress.Log(RPad('NTFS:', rpad_value) + BoolToStr(Param_NTFS_Process, True));
    Progress.Log(RPad('PDF:', rpad_value) + BoolToStr(Param_PDF_Process, True));
    Progress.Log(RPad('Prefetch:', rpad_value) + BoolToStr(Param_PF_Process, True));
    Progress.Log(RPad('Print Spool:', rpad_value) + BoolToStr(Param_PrintSpool_Process, True));
    Progress.Log(RPad('Recycle Bin:', rpad_value) + BoolToStr(Param_RecycleBin_Process, True));
    Progress.Log(RPad('ZIP:', rpad_value) + BoolToStr(Param_ZIP_Process, True));
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    if Working_TList.Count > 0 then
    begin

      gbl_Working_Count := 0;
      gbl_Working_Count := Working_TList.Count;

      CreateColumnNames;
      InitializeCounters;

      if Param_MSJUMPLIST_Process then
        ProcessJumpList(Working_TList);

      if Param_NTFS_Process then
        process_NTFS(Working_TList);

      ProcessFiles(Working_TList);

    end;

  finally
    EntryList.free;
    Working_TList.free;
  end;

  // ============================================================================
  // REPORT THE resultS
  // ============================================================================
  Progress.Log('NTFS Metadata Extraction has finished.');
  Progress.Log(StringOfChar('-', CHAR_LENGTH));

  result_StringList := TStringList.Create;
  result_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
  result_StringList.Duplicates := dupIgnore;
  try

    if (CmdLine.Params.Count = 0) then
    begin
      Progress.Log('No parameter received.');
    end;

    if (CmdLine.Params.Indexof('EXTRACT-METADATA') >= 0) then
    begin
    end;

    result_StringList.clear;

    if Param_EXIF_Process then
    begin
      result_StringList.Add(RPad(str_Exif270Description, rpad_value) + IntToStr(countTag270Description));
      result_StringList.Add(RPad(str_Exif271Make, rpad_value) + IntToStr(countTag271Make));
      result_StringList.Add(RPad(str_Exif272DeviceModel, rpad_value) + IntToStr(countTag272DeviceModel));
      result_StringList.Add(RPad(str_Exif274Orientation, rpad_value) + IntToStr(countTag274Orientation));
      result_StringList.Add(RPad(str_Exif282XResolution, rpad_value) + IntToStr(countTag282XResolution));
      result_StringList.Add(RPad(str_Exif283YResolution, rpad_value) + IntToStr(countTag283YResolution));
      result_StringList.Add(RPad(str_Exif305Software, rpad_value) + IntToStr(countTag305Software));
      result_StringList.Add(RPad(str_Exif306DateTime, rpad_value) + IntToStr(countTag306DateTime));
      result_StringList.Add(RPad(str_Exif315Artist, rpad_value) + IntToStr(countTag315Artist));
      result_StringList.Add(RPad(str_Exif36867DateTimeOriginal, rpad_value) + IntToStr(countTag36867DateTimeOriginal));
      result_StringList.Add(RPad(str_Exif33432Copyright, rpad_value) + IntToStr(countTag33432Copyright));
    end;

    if Param_GPS_Process then
    begin
      result_StringList.Add(RPad(str_GPSLatcalc, rpad_value) + IntToStr(countGPSPosLatitude));
      result_StringList.Add(RPad(str_GPSLongcalc, rpad_value) + IntToStr(countGPSPosLongitude));
      result_StringList.Add(RPad(str_GPSInfo1LatRef, rpad_value) + IntToStr(countGPSInfo1LatitudeRef));
      result_StringList.Add(RPad(str_GPSInfo2Lat, rpad_value) + IntToStr(countGPSInfo2Latitude));
      result_StringList.Add(RPad(str_GPSInfo3LongRef, rpad_value) + IntToStr(countGPSInfo3LongitudeRef));
      result_StringList.Add(RPad(str_GPSInfo4Long, rpad_value) + IntToStr(countGPSInfo4Longitude));
      result_StringList.Add(RPad(str_GPSInfo6Altitude, rpad_value) + IntToStr(countGPSInfo6Altitude));
      result_StringList.Add(RPad(str_GPSInfo7TimeStamp, rpad_value) + IntToStr(countGPSInfo7TimeStamp));
      result_StringList.Add(RPad(str_GPSInfo16DirectionRef, rpad_value) + IntToStr(countGPSInfo16DirectionRef));
      result_StringList.Add(RPad(str_GPSInfo17Direction, rpad_value) + IntToStr(countGPSInfo17Direction));
      result_StringList.Add(RPad(str_GPSInfo29DateStamp, rpad_value) + IntToStr(countGPSInfo29DateStamp));
    end;

    if Param_LNK_Process then
    begin
      result_StringList.Add(RPad(str_LNKTargetAccessedUTC, rpad_value) + IntToStr(countLNKFileAccessed));
      result_StringList.Add(RPad(str_LNKTargetCreatedUTC, rpad_value) + IntToStr(countLNKFileCreated));
      result_StringList.Add(RPad(str_LNKTargetDriveType, rpad_value) + IntToStr(countLNKFileDriveType));
      result_StringList.Add(RPad(str_LNKTargetLocalBasePath, rpad_value) + IntToStr(countLNKFileLocalBasePath));
      result_StringList.Add(RPad(str_LNKGUIDMAC, rpad_value) + IntToStr(countLNKFileGUIDMAC));
      result_StringList.Add(RPad(str_LNKTargetModifiedUTC, rpad_value) + IntToStr(countLNKFileModified));
      result_StringList.Add(RPad(str_LNKTargetSize, rpad_value) + IntToStr(countLNKFileSize));
      result_StringList.Add(RPad(str_LNKTargetVolumeLabel, rpad_value) + IntToStr(countLNKFileVolumeLabel));
      result_StringList.Add(RPad(str_LNKTargetVolumeSerial, rpad_value) + IntToStr(countLNKFileDriveSerialNumber));
      result_StringList.Add(RPad(str_LNKTargetNetName, rpad_value) + IntToStr(countLNKFileNetName));
      result_StringList.Add(RPad(str_LNKTargetDeviceName, rpad_value) + IntToStr(countLNKFileDeviceName));
    end;

    if Param_MSJUMPLIST_Process and not Param_LNK_Process then
    begin
      result_StringList.Add(RPad(str_LNKTargetAccessedUTC, rpad_value) + IntToStr(countMSJUMPLISTFileAccessed));
      result_StringList.Add(RPad(str_LNKTargetCreatedUTC, rpad_value) + IntToStr(countMSJUMPLISTFileCreated));
      result_StringList.Add(RPad(str_LNKTargetDriveType, rpad_value) + IntToStr(countMSJUMPLISTFileDriveType));
      result_StringList.Add(RPad(str_LNKTargetLocalBasePath, rpad_value) + IntToStr(countMSJUMPLISTFileLocalBasePath));
      result_StringList.Add(RPad(str_LNKTargetModifiedUTC, rpad_value) + IntToStr(countMSJUMPLISTFileModified));
      result_StringList.Add(RPad(str_LNKTargetSize, rpad_value) + IntToStr(countMSJUMPLISTFileSize));
      result_StringList.Add(RPad(str_LNKTargetVolumeLabel, rpad_value) + IntToStr(countMSJUMPLISTFileVolumeLabel));
      result_StringList.Add(RPad(str_LNKTargetVolumeSerial, rpad_value) + IntToStr(countMSJUMPLISTFileDriveSerialNumber));
      result_StringList.Add(RPad(str_LNKTargetNetName, rpad_value) + IntToStr(countMSJUMPLISTFileNetName));
      result_StringList.Add(RPad(str_LNKTargetDeviceName, rpad_value) + IntToStr(countMSJUMPLISTFileDeviceName));
    end;

    if Param_MS_Process then
    begin
      result_StringList.Add(RPad(str_MSAuthor, rpad_value) + IntToStr(countMSAuthor));
      result_StringList.Add(RPad(str_MSCreated, rpad_value) + IntToStr(countMSCreated));
      result_StringList.Add(RPad(str_MSModified, rpad_value) + IntToStr(countMSModified));
      result_StringList.Add(RPad(str_MSPrinted, rpad_value) + IntToStr(countMSPrinted));
      result_StringList.Add(RPad(str_MSLastSavedby, rpad_value) + IntToStr(countMSLastSavedby));
      result_StringList.Add(RPad(str_MSSubject, rpad_value) + IntToStr(countMSSubject));
      result_StringList.Add(RPad(str_MSCompany, rpad_value) + IntToStr(countMSCompany));
      result_StringList.Add(RPad(str_MSTitle, rpad_value) + IntToStr(countMSTitle));
      result_StringList.Add(RPad(str_MSWordCount, rpad_value) + IntToStr(countMSWordCount));
      result_StringList.Add(RPad(str_MSRevision, rpad_value) + IntToStr(countMSRevision));
      result_StringList.Add(RPad(str_MSEditTime, rpad_value) + IntToStr(countMSEditTime));
    end;

    if Param_MS_Process then
    begin
      result_StringList.Add(RPad(str_MSPrinted, rpad_value) + IntToStr(countMSPrinted));

    end;

    if Param_NTFS_Process then
    begin
      result_StringList.Add(RPad(str_NTFS30CreatedUTC, rpad_value) + IntToStr(countNTFS30FileNameCreated));
      result_StringList.Add(RPad(str_NTFS30RecordModifiedUTC, rpad_value) + IntToStr(countNTFS30FileNameRecordModified));
      result_StringList.Add(RPad(str_NTFS30ModifiedUTC, rpad_value) + IntToStr(countNTFS30FileNameModified));
      result_StringList.Add(RPad(str_NTFS30AccessedUTC, rpad_value) + IntToStr(countNTFS30FileNameAccessed));
    end;

    if Param_PDF_Process then
    begin
      result_StringList.Add(RPad(str_PDFAuthor, rpad_value) + IntToStr(countPDFAuthor));
      result_StringList.Add(RPad(str_PDFCreationDate, rpad_value) + IntToStr(countPDFCreationDate));
      result_StringList.Add(RPad(str_PDFModificationDate, rpad_value) + IntToStr(countPDFModificationDate));
      result_StringList.Add(RPad(str_PDFOwnerPwd, rpad_value) + IntToStr(countPDFOwnerPassword));
      result_StringList.Add(RPad(str_PDFProducer, rpad_value) + IntToStr(countPDFProducer));
      result_StringList.Add(RPad(str_PDFTitle, rpad_value) + IntToStr(countPDFTitle));
      result_StringList.Add(RPad(str_PDFUserPwd, rpad_value) + IntToStr(countPDFUserPassword));
    end;

    if Param_PF_Process then
    begin
      result_StringList.Add(RPad(str_PrefetchFilename, rpad_value) + IntToStr(countPFFilename));
      result_StringList.Add(RPad(str_PrefetchExecutionTime, rpad_value) + IntToStr(countPFExecutionTime));
      result_StringList.Add(RPad(str_PrefetchExecutionCount, rpad_value) + IntToStr(countPFExecutionCount));
    end;

    if Param_PrintSpool_Process then
    begin
      result_StringList.Add(RPad(str_PrintSpool_DocumentName, rpad_value) + IntToStr(countPrintSpool_DocumentName));
      result_StringList.Add(RPad(str_PrintSpoolShadow_ComputerName, rpad_value) + IntToStr(countPrintSpoolShadow_ComputerName));
      result_StringList.Add(RPad(str_PrintSpoolShadow_DevMode, rpad_value) + IntToStr(countPrintSpoolShadow_DevMode));
      result_StringList.Add(RPad(str_PrintSpoolShadow_DocumentName, rpad_value) + IntToStr(countPrintSpoolShadow_DocumentName));
      result_StringList.Add(RPad(str_PrintSpoolShadow_NotificationName, rpad_value) + IntToStr(countPrintSpoolShadow_NotificationName));
      result_StringList.Add(RPad(str_PrintSpoolShadow_PCName, rpad_value) + IntToStr(countPrintSpoolShadow_PCName));
      result_StringList.Add(RPad(str_PrintSpoolShadow_PrinterName, rpad_value) + IntToStr(countPrintSpoolShadow_PrinterName));
      result_StringList.Add(RPad(str_PrintSpoolShadow_Signature, rpad_value) + IntToStr(countPrintSpoolShadow_Signature));
      result_StringList.Add(RPad(str_PrintSpoolShadow_SubmitTime, rpad_value) + IntToStr(countPrintSpoolShadow_SubmitTime));
      result_StringList.Add(RPad(str_PrintSpoolShadow_UserName, rpad_value) + IntToStr(countPrintSpoolShadow_UserName));
    end;

    if Param_RecycleBin_Process then
    begin
      result_StringList.Add(RPad(str_RecycleBinOriginalFilename, rpad_value) + IntToStr(countRecycleBinOriginalFilename));
      result_StringList.Add(RPad(str_RecycleBinOriginalFilesize, rpad_value) + IntToStr(countRecycleBinOriginalFileSize));
      result_StringList.Add(RPad(str_RecycleBinDeletedTimeUTC, rpad_value) + IntToStr(countRecycleBinDeletedTimeUTC));
    end;

    if Param_ZIP_Process then
    begin
      result_StringList.Add(RPad(str_ZIPNumberItems, rpad_value) + IntToStr(countZIPNumberItems));
    end;

    for k := 0 to result_StringList.Count - 1 do
    begin
      Progress.Log(result_StringList(k)); // Print line by line for date time
    end;

    gbl_Show_Columns_Tab := True;
    if assigned(result_StringList) and (result_StringList.Count > 0) then
      for i := 0 to result_StringList.Count - 1 do
      begin
        Progress.Log(result_StringList[i]);
      end;

  finally
    result_StringList.free
  end;

  if bl_force_extract then
  begin
    Progress.Log('');
    Progress.Log('Force process is ON!');
  end;
end;

// FUNCTION TO PROCESS a String Column =========================================
function AddStringColumn(AParentNode: TPropertyNode; AEntry: TEntry; ADataStoreField: TDataStoreField; ANodeByName: string; var ACounter: integer): boolean;
var
  aTempStr: string;
  aPropertyNode: TPropertyNode;
  stringprop: string;
  FileSignatureInfo: TFileTypeInformation;
begin
  Result := False;
  stringprop := '';
  if not(ADataStoreField.isNull(AEntry)) then
    stringprop := ADataStoreField.AsString[AEntry];

  if (stringprop = '') or (bl_force_extract = True) then
  begin
    aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(aPropertyNode) then
    begin
      aTempStr := trim(aPropertyNode.PropDisplayValue);
      if aTempStr <> '' then
      begin
        ADataStoreField.AsString[AEntry] := aTempStr;
        if Param_Bookmark_PRINTSPOOL then
        begin
          FileSignatureInfo := AEntry.FileDriverInfo;
          if (UpperCase(FileSignatureInfo.ShortDisplayName) = SIG_PRINT_SPOOL_SHADOW) then
            PrintSpoolComment := PrintSpoolComment + #13#10 + RPad(ADataStoreField.FieldName + ': ', rpad_value) + aTempStr;
        end;
        Result := True;
        ACounter := ACounter + 1;
      end;
    end;
  end
  else
  begin
    ACounter := (ACounter + 1);
    if Param_Bookmark_PRINTSPOOL then
    begin
      FileSignatureInfo := AEntry.FileDriverInfo;
      if (UpperCase(FileSignatureInfo.ShortDisplayName) = SIG_PRINT_SPOOL_SHADOW) then
        PrintSpoolComment := PrintSpoolComment + #13#10 + RPad(ADataStoreField.FieldName + ': ', rpad_value) + stringprop;
    end;
  end;
end;

// FUNCTION TO PROCESS a Date Column ===========================================
function AddFileTimeColumn(AParentNode: TPropertyNode; AEntry: TEntry; ADataStoreField: TDataStoreField; ANodeByName: string; var ACounter: integer): boolean;
var
  propnode: TPropertyNode;
  aDateTime: TDateTime;
  anint64: int64;
begin
  if (ADataStoreField.isNull(AEntry)) or (bl_force_extract = True) then
  begin
    propnode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(propnode) then
    begin
      aDateTime := 0.0;
      if propnode.PropDataType = 'Date' then
        aDateTime := propnode.PropValue
      else if propnode.PropDataType = 'int64' then
      begin
        anint64 := propnode.PropValue;
        aDateTime := FileTimeToDateTime(anint64);
      end;
      if propnode.PropValue <> 0 then
      begin
        ADataStoreField.AsDateTime[AEntry] := aDateTime;
        if Param_Bookmark_PRINTSPOOL then
          try
            PrintSpoolComment := PrintSpoolComment + #13#10 + RPad(ADataStoreField.FieldName + ': ', rpad_value) + DateTimeToStr(aDateTime);
          except
            Progress.Log(ATRY_EXCEPT_STR + 'Error converting DateTimeToStr');
          end;
        Result := True;
        ACounter := ACounter + 1;
      end;
    end;
  end
  else
    ACounter := (ACounter + 1);
  if Param_Bookmark_PRINTSPOOL then
    try
      PrintSpoolComment := PrintSpoolComment + #13#10 + RPad(ADataStoreField.FieldName + ': ', rpad_value) + ADataStoreField.AsString[AEntry];
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Error converting DateTimeToStr');
    end;
end;

// FUNCTION TO PROCESS an int64 Column =========================================
function Addint64Column(AParentNode: TPropertyNode; AEntry: TEntry; ADataStoreField: TDataStoreField; ANodeByName: string; var ACounter: integer): boolean;
var
  propnode: TPropertyNode;
  aint64: int64;
begin
  if (ADataStoreField.isNull(AEntry)) or (bl_force_extract = True) then
  begin
    propnode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(propnode) then
    begin
      aint64 := propnode.PropValue;
      ADataStoreField.Asint64[AEntry] := aint64;
      Result := True;
      ACounter := ACounter + 1;
    end;
  end
  else
    ACounter := (ACounter + 1);
end;

// FUNCTION TO PROCESS an Int32 Column =========================================
function AddInt32Column(AParentNode: TPropertyNode; AEntry: TEntry; ADataStoreField: TDataStoreField; ANodeByName: string; var ACounter: integer): boolean;
var
  propnode: TPropertyNode;
  aInt32: integer;
begin
  if (ADataStoreField.isNull(AEntry)) or (bl_force_extract = True) then
  begin
    propnode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(propnode) then
    begin
      aInt32 := propnode.PropValue;
      ADataStoreField.AsInteger[AEntry] := aInt32;
      Result := True;
      ACounter := ACounter + 1;
    end;
  end;
end;

// FUNCTION TO PROCESS FLOAT - an Int32 Column =================================
function AddFloatColumn(AParentNode: TPropertyNode; AEntry: TEntry; ADataStoreField: TDataStoreField; ANodeByName: string; var ACounter: integer): boolean;
var
  propnode: TPropertyNode;
  aFloat: double;
  aTempStr: string;
begin
  Result := False;
  if (ADataStoreField.isNull(AEntry)) or (bl_force_extract = True) then
  begin
    propnode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(propnode) then
    begin
      aFloat := propnode.PropValue;
      aTempStr := floattostr(aFloat);
      if aTempStr <> '' then
      begin
        ADataStoreField.AsFloat[AEntry] := aFloat;
        Result := True;
        ACounter := ACounter + 1;
      end;
    end;
  end
  else
    ACounter := ACounter + 1;
end;

// Function - Strip Illegal characters for Valid Folder Name in Bookmarks
function StripIllegalChars(AString: string): string;
var
  x: integer;
const
  IllegalCharSet: set of char = ['|', '<', '>', '\', '^', '+', '=', '?', '/', '[', ']', '"', ';', ',', '*', ':'];
begin
  for x := 1 to Length(AString) do
    if AString[x] in IllegalCharSet then
      AString[x] := '_';
  Result := AString;
end;

// ***PROCESS DOCX**************************************************************
procedure ProcessDOCX(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  anExpandedFileList: TList;
  i: integer;
  aFile: TEntry;
  aReader: TEntryReader;
  aPropertyTree: TPropertyParent;
  AParentNode: TPropertyNode;
  aTempStr: string;
  filestr: string;
  DOCX_Progress: TPAC;
begin
  DOCX_Progress := NewProgress(False);
  aReader := TEntryReader.Create;
  anExpandedFileList := TList.Create;
  ExtractCompoundFile(AEntry, anExpandedFileList, DOCX_Progress);

  // Progress.Initialize(anExpandedFileList.Count, 'Processing DOCX' + RUNNING);
  for i := 0 to anExpandedFileList.Count - 1 do
  begin
    aFile := TEntry(anExpandedFileList.items[i]);
    filestr := lowercase(aFile.EntryName);
    if (filestr = 'core.xml') or (filestr = 'docprops/core.xml') then // was docProps/core.xml
    begin
      if aReader.Opendata(aFile) then
      begin
        aPropertyTree := nil;
        if ProcessMetadataProperties(aFile, aPropertyTree, aReader) then
        begin
          if assigned(aPropertyTree) and assigned(aPropertyTree.RootProperty) then

            // DOCX DATES ======================================================

            // Created UTC
            if (colMSCreated.isNull(AEntry)) or (bl_force_extract = True) then
            begin
              AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dcterms:created')); // noslz
              if assigned(AParentNode) then
              begin
                aTempStr := trim(AParentNode.PropDisplayValue);
                if aTempStr <> '' then
                begin
                  colMSCreated.AsDateTime[AEntry] := ConvertW3CDTFStringToDateTime(aTempStr);
                  countMSCreated := countMSCreated + 1;
                end;
              end;
            end
            else
              countMSCreated := countMSCreated + 1;

          // Modified UTC
          if (colMSModified.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dcterms:modified')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSModified.AsDateTime[AEntry] := ConvertW3CDTFStringToDateTime(aTempStr);
                countMSModified := countMSModified + 1;
              end;
            end;
          end
          else
            countMSModified := countMSModified + 1;

          // Last Printed UTC
          if (colMSPrinted.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('cp:lastprinted')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSPrinted.AsDateTime[AEntry] := ConvertW3CDTFStringToDateTime(aTempStr);
                countMSPrinted := countMSPrinted + 1;
              end;
            end;
          end
          else
            countMSPrinted := countMSPrinted + 1;

          // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

          // Creator (Author in OLE)
          if (colMSAuthor.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dc:creator')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSAuthor.AsString[AEntry] := aTempStr;
                countMSAuthor := countMSAuthor + 1;
              end;
            end;
          end
          else
            countMSAuthor := countMSAuthor + 1;

          // Last Modified By (Last Saved By in OLE)
          if (colMSLastSavedby.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('cp:lastModifiedBy')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSLastSavedby.AsString[AEntry] := aTempStr; // !!!!!! Difference between 'Last Saved and Last Modified"?
                countMSLastSavedby := countMSLastSavedby + 1;
              end;
            end;
          end
          else
            countMSLastSavedby := countMSLastSavedby + 1;

          // Title (Title in OLE)
          if (colMSTitle.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dc:title')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSTitle.AsString[AEntry] := aTempStr;
                countMSTitle := countMSTitle + 1;
              end;
            end;
          end
          else
            countMSTitle := countMSTitle + 1;

          // Subject (Subject in OLE)
          if (colMSSubject.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dc:subject')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSSubject.AsString[AEntry] := aTempStr;
                countMSSubject := countMSSubject + 1;
              end;
            end;
          end
          else
            countMSSubject := countMSSubject + 1;

          // Revision (Revision in OLE)
          if (colMSRevision.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('cp:revision')); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSRevision.AsString[AEntry] := aTempStr;
                countMSRevision := countMSRevision + 1;
              end;
            end;
          end
          else
            countMSRevision := countMSRevision + 1;

        end;
        if assigned(aPropertyTree) then
          aPropertyTree.free;
      end;
    end;

    // AGAIN FOR THE SECOND FILE
    // Second file
    if aFile.EntryName = 'app.xml' then // was docProps/app.xml
    begin
      if aReader.Opendata(aFile) then
      begin
        aPropertyTree := nil;
        if ProcessMetadataProperties(aFile, aPropertyTree, aReader) then
        begin
          if assigned(aPropertyTree) and assigned(aPropertyTree.RootProperty) then

            // Word Count (Word Count in OLE)
            if (colMSWordCount.isNull(AEntry)) or (bl_force_extract = True) then
            begin
              AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName(NODEBYNAME_Words)); // noslz
              if assigned(AParentNode) then
              begin
                aTempStr := trim(AParentNode.PropDisplayValue);
                if aTempStr <> '' then
                begin
                  colMSWordCount.AsString[AEntry] := aTempStr;
                  countMSWordCount := countMSWordCount + 1;
                end;
              end;
            end
            else
              countMSWordCount := countMSWordCount + 1;

          // Total Time (OLE Edit Time)
          if (colMSEditTime.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName(NODEBYNAME_TotalTime)); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSEditTime.AsString[AEntry] := aTempStr;
                countMSEditTime := countMSEditTime + 1;
              end;
            end;
          end
          else
            countMSEditTime := countMSEditTime + 1;

          // Company
          if (colMSCompany.isNull(AEntry)) or (bl_force_extract = True) then
          begin
            AParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName(NODEBYNAME_Company)); // noslz
            if assigned(AParentNode) then
            begin
              aTempStr := trim(AParentNode.PropDisplayValue);
              if aTempStr <> '' then
              begin
                colMSCompany.AsString[AEntry] := aTempStr;
                countMSCompany := countMSCompany + 1;
              end;
            end;
          end
          else
            countMSCompany := countMSCompany + 1;

        end;
        if assigned(aPropertyTree) then
          aPropertyTree.free;
      end;
    end;

  end;
  aReader.free;
  for i := 0 to anExpandedFileList.Count - 1 do
  begin
    aFile := TEntry(anExpandedFileList.items[i]);
    aFile.free;
  end;
  anExpandedFileList.free;
end;

// ***PROCESS JFif**************************************************************
procedure ProcessJFif(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  AParentNode: TPropertyNode;
begin
  AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_JFIF)); // noslz
  if assigned(AParentNode) then
  begin
    AddStringColumn(AParentNode, AEntry, colJFifType, NODEBYNAME_JFIFType, countJFifType);
  end;
end;

// ***PROCESS JPG***************************************************************
procedure ProcessJPG(AEntry: TEntry; aRootEntry: TPropertyNode; AShortDisplayName: string);
var
  aPropertyNode, aPropertyNode1, AParentNode: TPropertyNode;
  info2lat: double;
  info4lat: double;
  info7timestamp: double;
  altitude: double;
  direction: double;
  i: integer;
  aTempStr: string;
  tempvariant: variant;
  calcVal: double;
begin
  if (AShortDisplayName = 'TIFF') then
  begin
    // Progress.Log('Processed as TIFF');
    AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_TIFF)); // noslz
  end
  else if (AShortDisplayName = 'HEIF') then
  begin
    // Progress.Log('Processed as HEIF');
    AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_HEIF)); // noslz
  end
  else
  begin
    // Progress.Log('Processed as JPEG');
    AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_EXIF)); // noslz
  end;

  if assigned(AParentNode) then
  begin
    AddStringColumn(AParentNode, AEntry, colEXIFType, NODEBYNAME_EXIFType, countEXIFType);
    AddStringColumn(AParentNode, AEntry, colTag270Description, NODEBYNAME_Tag270Description, countTag270Description);
    AddStringColumn(AParentNode, AEntry, colTag271Make, NODEBYNAME_Tag271Make, countTag271Make);
    AddStringColumn(AParentNode, AEntry, colTag272DeviceModel, NODEBYNAME_Tag272DeviceModel, countTag272DeviceModel);
    AddStringColumn(AParentNode, AEntry, colTag274Orientation, NODEBYNAME_Tag274Orientation, countTag274Orientation);
    AddStringColumn(AParentNode, AEntry, colTag305Software, NODEBYNAME_Tag305Software, countTag305Software);
    AddStringColumn(AParentNode, AEntry, colTag306DateTime, NODEBYNAME_Tag306DateTime, countTag306DateTime);
    AddStringColumn(AParentNode, AEntry, colTag315Artist, NODEBYNAME_Tag315Artist, countTag315Artist);
    AddStringColumn(AParentNode, AEntry, colTag36867DateTimeOriginal, NODEBYNAME_Tag36867DateTimeOriginal, countTag36867DateTimeOriginal);
    AddStringColumn(AParentNode, AEntry, colTag33432Copyright, NODEBYNAME_Tag33432Copyright, countTag33432Copyright);
    AddFloatColumn(AParentNode, AEntry, colTag282XResolution, NODEBYNAME_Tag282XResolution, countTag282XResolution);
    AddFloatColumn(AParentNode, AEntry, colTag283YResolution, NODEBYNAME_Tag283YResolution, countTag283YResolution);

    // ***PROCESS EXIF for GPS**************************************************
    aTempStr := '';
    AddStringColumn(AParentNode, AEntry, colGPSInfo1LatitudeRef, NODEBYNAME_GPSInfo1GPSLatitudeRef, countGPSInfo1LatitudeRef);
    AddStringColumn(AParentNode, AEntry, colGPSInfo3LongitudeRef, NODEBYNAME_GPSInfo3GPSLongitudeRef, countGPSInfo3LongitudeRef);
    AddStringColumn(AParentNode, AEntry, colGPSInfo16DirectionRef, NODEBYNAME_GPSInfo16GPSImgDirectionRef, countGPSInfo16DirectionRef);
    AddStringColumn(AParentNode, AEntry, colGPSInfo29DateStamp, NODEBYNAME_GPSInfo29GPSDateStamp, countGPSInfo29DateStamp);

    // GPS Pos Latitude - Calculated -------------------------------------------
    if (colGPSPosLatitude.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo2GPSLatitude); // noslz
      aPropertyNode1 := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo1GPSLatitudeRef); // noslz
      if aPropertyNode <> nil then
      begin
        tempvariant := aPropertyNode.PropValue;
        if VarIsArray(tempvariant) then
        begin
          calcVal := VarArrayGet(tempvariant, [0]) + VarArrayGet(tempvariant, [1]) / 60 + VarArrayGet(tempvariant, [2]) / 3600;
          if (aPropertyNode1 <> nil) then
          begin
            if aPropertyNode1.PropValue = 'S' then
            begin
              calcVal := -calcVal;
            end;
          end;
          colGPSPosLatitude.AsDouble(AEntry) := calcVal;
        end
        else
        begin
          colGPSPosLatitude.AsDouble(AEntry) := tempvariant;
        end;
        countGPSPosLatitude := countGPSPosLatitude + 1;
      end;
    end
    else
      countGPSPosLatitude := (countGPSPosLatitude + 1);

    // GPS Pos Longitude - Calculated ------------------------------------------
    if (colGPSPosLongitude.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo4GPSLongitude); // noslz
      aPropertyNode1 := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo3GPSLongitudeRef); // noslz
      if aPropertyNode <> nil then
      begin
        tempvariant := aPropertyNode.PropValue;
        if VarIsArray(tempvariant) then
        begin
          calcVal := VarArrayGet(tempvariant, [0]) + VarArrayGet(tempvariant, [1]) / 60 + VarArrayGet(tempvariant, [2]) / 3600;
          if (aPropertyNode1 <> nil) then
          begin
            if aPropertyNode1.PropValue = 'W' then
            begin
              calcVal := -calcVal;
            end;
          end;
          colGPSPosLongitude.AsDouble(AEntry) := calcVal;
        end
        else
        begin
          colGPSPosLongitude.AsFloat(AEntry) := tempvariant;
        end;
        countGPSPosLongitude := countGPSPosLongitude + 1;
      end;
    end
    else
      countGPSPosLongitude := (countGPSPosLongitude + 1);

    // GPS Info2 Latitude Raw Data ---------------------------------------------
    if (colGPSInfo2Latitude.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo2GPSLatitude)); // noslz
      if assigned(aPropertyNode) then
      begin
        tempvariant := aPropertyNode.PropValue;
        if VarIsArray(tempvariant) then
        begin
          aTempStr := '';
          for i := VarArrayLowBound(tempvariant, 1) to VarArrayHighBound(tempvariant, 1) do
          begin
            if aTempStr = '' then
              aTempStr := VarArrayGet(tempvariant, [i])
            else
              aTempStr := aTempStr + ' ' + VarArrayGet(tempvariant, [i]);
          end;
        end
        else
        begin
          info2lat := aPropertyNode.PropValue;
          aTempStr := floattostr(info2lat);
        end;
        if aTempStr <> '' then
        begin
          colGPSInfo2Latitude.AsString[AEntry] := aTempStr;
          countGPSInfo2Latitude := countGPSInfo2Latitude + 1;
        end;
      end;
    end
    else
      countGPSInfo2Latitude := (countGPSInfo2Latitude + 1);

    // GPS Info4 Longitude Raw Data --------------------------------------------
    if (colGPSInfo4Longitude.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo4GPSLongitude)); // noslz
      if assigned(aPropertyNode) then
      begin
        tempvariant := aPropertyNode.PropValue;
        if VarIsArray(tempvariant) then
        begin
          aTempStr := '';
          for i := VarArrayLowBound(tempvariant, 1) to VarArrayHighBound(tempvariant, 1) do
          begin
            if aTempStr = '' then
              aTempStr := VarArrayGet(tempvariant, [i])
            else
              aTempStr := aTempStr + ' ' + VarArrayGet(tempvariant, [i]);
          end;
        end
        else
        begin
          info4lat := aPropertyNode.PropValue;
          aTempStr := floattostr(info2lat);
        end;
        if aTempStr <> '' then
        begin
          colGPSInfo4Longitude.AsString[AEntry] := aTempStr;
          countGPSInfo4Longitude := countGPSInfo4Longitude + 1;
        end;
      end;
    end
    else
      countGPSInfo4Longitude := (countGPSInfo4Longitude + 1);

    // GPS Info6 Altitude ------------------------------------------------------
    if (colGPSInfo6Altitude.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo6GPSAltitude)); // noslz
      if assigned(aPropertyNode) then
      begin
        altitude := aPropertyNode.PropValue;
        aTempStr := floattostr(altitude);
        if aTempStr <> '' then
        begin
          colGPSInfo6Altitude.AsFloat[AEntry] := altitude;
          countGPSInfo6Altitude := countGPSInfo6Altitude + 1;
        end;
      end;
    end
    else
      countGPSInfo6Altitude := (countGPSInfo6Altitude + 1);

    // GPS Info7 TimeStamp  ----------------------------------------------------
    if (colGPSInfo7TimeStamp.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo7GPSTimeStamp)); // noslz
      if assigned(aPropertyNode) then
      begin
        tempvariant := aPropertyNode.PropValue;
        if VarIsArray(tempvariant) then
        begin
          aTempStr := '';
          for i := VarArrayLowBound(tempvariant, 1) to VarArrayHighBound(tempvariant, 1) do
          begin
            if aTempStr = '' then
              aTempStr := VarArrayGet(tempvariant, [i])
            else
              aTempStr := aTempStr + ' ' + VarArrayGet(tempvariant, [i]);
          end;
        end
        else
        begin
          info7timestamp := aPropertyNode.PropValue;
          aTempStr := floattostr(info7timestamp);
        end;
        if aTempStr <> '' then
        begin
          colGPSInfo7TimeStamp.AsString[AEntry] := aTempStr;
          countGPSInfo7TimeStamp := countGPSInfo7TimeStamp + 1;
        end;
      end;
    end
    else
      countGPSInfo7TimeStamp := (countGPSInfo7TimeStamp + 1);

    // GPS Info17 Direction ----------------------------------------------------
    if (colGPSInfo17Direction.isNull(AEntry)) or (bl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo17GPSImgDirection)); // noslz
      if assigned(aPropertyNode) then
      begin
        direction := aPropertyNode.PropValue;
        aTempStr := floattostr(direction);
        if aTempStr <> '' then
        begin
          colGPSInfo17Direction.AsFloat[AEntry] := direction;
          countGPSInfo17Direction := countGPSInfo17Direction + 1;
        end;
      end;
    end
    else
      countGPSInfo17Direction := (countGPSInfo17Direction + 1);
  end;
end;

// PROCESS LNK******************************************************************
procedure ProcessLNK(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  aLinkMSNode: TPropertyNode;
  aLinkInfoNode: TPropertyNode;
  aLinkTrackerPropertyBlock: TPropertyNode;
  LNKFound: boolean;
begin
  LNKFound := False;
  aLinkInfoNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKLinkInfo)); // noslz
  if assigned(aLinkInfoNode) then
  begin
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileLocalBasePath, NODEBYNAME_LNKLocalBasePath, countLNKFileLocalBasePath);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveSerialNumber, NODEBYNAME_LNKDriveSerialNumber, countLNKFileDriveSerialNumber);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveType, NODEBYNAME_LNKDriveType, countLNKFileDriveType);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileVolumeLabel, NODEBYNAME_LNKVolumeLabel, countLNKFileVolumeLabel);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileNetName, NODEBYNAME_LNKNetName, countLNKFileNetName);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDeviceName, NODEBYNAME_LNKDeviceName, countLNKFileDeviceName);
  end;

  aLinkMSNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKFileMS)); // noslz
  if assigned(aLinkMSNode) then
  begin
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileCreated, NODEBYNAME_LNKCreationTimeUTC, countLNKFileCreated);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileModified, NODEBYNAME_LNKModifiedTimeUTC, countLNKFileModified);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileAccessed, NODEBYNAME_LNKAccessTimeUTC, countLNKFileAccessed);
    Addint64Column(aLinkMSNode, AEntry, colLNKFileSize, NODEBYNAME_LNKFileSize, countLNKFileSize);
  end;

  aLinkTrackerPropertyBlock := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKTrackerProptertyBlock)); // noslz
  if assigned(aLinkTrackerPropertyBlock) then
  begin
    AddStringColumn(aLinkTrackerPropertyBlock, AEntry, colLNKFileGUIDMAC, NODEBYNAME_LNKGUIDMAC, countLNKFileGUIDMAC);
  end;

end;

// PROCESS MS JUMP LIST ********************************************************
procedure ProcessMSJUMPLIST(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  aLinkMSNode: TPropertyNode;
  aLinkInfoNode: TPropertyNode;
  LNKFound: boolean;
begin
  LNKFound := False;
  aLinkInfoNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKLinkInfo)); // noslz
  if assigned(aLinkInfoNode) then
  begin
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileLocalBasePath, NODEBYNAME_LNKLocalBasePath, countMSJUMPLISTFileLocalBasePath);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveSerialNumber, NODEBYNAME_LNKDriveSerialNumber, countMSJUMPLISTFileDriveSerialNumber);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveType, NODEBYNAME_LNKDriveType, countMSJUMPLISTFileDriveType);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileVolumeLabel, NODEBYNAME_LNKVolumeLabel, countMSJUMPLISTFileVolumeLabel);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileNetName, NODEBYNAME_LNKNetName, countMSJUMPLISTFileNetName);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDeviceName, NODEBYNAME_LNKDeviceName, countMSJUMPLISTFileDeviceName);
  end;

  aLinkMSNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKFileMS)); // noslz
  if assigned(aLinkMSNode) then
  begin
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileCreated, NODEBYNAME_LNKCreationTimeUTC, countMSJUMPLISTFileCreated);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileModified, NODEBYNAME_LNKModifiedTimeUTC, countMSJUMPLISTFileModified);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileAccessed, NODEBYNAME_LNKAccessTimeUTC, countMSJUMPLISTFileAccessed);
    Addint64Column(aLinkMSNode, AEntry, colLNKFileSize, NODEBYNAME_LNKFileSize, countMSJUMPLISTFileSize);
  end;
end;

// ***PROCESS MS****************************************************************
procedure ProcessMS(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  AParentNode: TPropertyNode;
begin
  AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_MSSummary)); // noslz
  if assigned(AParentNode) then
  begin
    AddStringColumn(AParentNode, AEntry, colMSAuthor, NODEBYNAME_MSAuthor, countMSAuthor);
    AddStringColumn(AParentNode, AEntry, colMSSubject, NODEBYNAME_MSSubject, countMSSubject);
    AddStringColumn(AParentNode, AEntry, colMSTitle, NODEBYNAME_MSTitle, countMSTitle);
    AddStringColumn(AParentNode, AEntry, colMSLastSavedby, NODEBYNAME_MSLastSavedby, countMSLastSavedby);
    AddStringColumn(AParentNode, AEntry, colMSCompany, NODEBYNAME_MSCompany, countMSCompany);
    AddFileTimeColumn(AParentNode, AEntry, colMSCreated, NODEBYNAME_MSCreatedUTC, countMSCreated);
    AddFileTimeColumn(AParentNode, AEntry, colMSModified, NODEBYNAME_MSModifiedUTC, countMSModified);
    AddFileTimeColumn(AParentNode, AEntry, colMSPrinted, NODEBYNAME_MSPrintedUTC, countMSPrinted);
    AddInt32Column(AParentNode, AEntry, colMSWordCount, NODEBYNAME_MSWords, countMSWordCount);
    AddInt32Column(AParentNode, AEntry, colMSRevision, NODEBYNAME_MSRevision, countMSRevision);
    AddInt32Column(AParentNode, AEntry, colMSEditTime, NODEBYNAME_MSEditTime, countMSEditTime);
  end;

  // Search for Company for DOC files. It is in a separate node called 'Document Summary'
  AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_MSDocumentSummary)); // noslz
  if assigned(AParentNode) then
  begin
    AddStringColumn(AParentNode, AEntry, colMSCompany, NODEBYNAME_MSCompany, countMSCompany);
  end;
end;

// ConvertW3CDTF Dates for DOCX
function ConvertW3CDTFStringToDateTime(AString: string): TDateTime;
var
  tpos: integer;
  year: integer;
  month: integer;
  day: integer;
  hour: integer;
  minute: integer;
  second: integer;
  didDate: boolean;
  didTime: boolean;
begin
  Result := 0;
  if Length(AString) < 8 then
    Exit;
  tpos := POS('T', AString);
  didTime := False;
  didDate := False;
  didDate := TryStrToInt(copy(AString, 1, 4), year) and TryStrToInt(copy(AString, 6, 2), month) and TryStrToInt(copy(AString, 9, 2), day);
  if Length(AString) >= 15 then
    didTime := TryStrToInt(copy(AString, 12, 2), hour) and TryStrToInt(copy(AString, 15, 2), minute) and TryStrToInt(copy(AString, 18, 2), second);
  if didDate and didTime then
  begin
    try
      Result := EncodeDateTime(year, month, day, hour, minute, second, 0);
    except
      Result := 0;
    end;
  end
  else if didDate then
  begin
    try
      Result := EncodeDate(year, month, day);
    except
      Result := 0;
    end;
  end;
end;

// *** PROCESS PDF *************************************************************
procedure ProcessPDF(AEntry: TEntry; aRootEntry: TPropertyNode);
begin
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_PDF) then
  begin
    AddStringColumn(aRootEntry, AEntry, colPDFAuthor, NODEBYNAME_PDFAuthor, countPDFAuthor);
    AddStringColumn(aRootEntry, AEntry, colPDFTitle, NODEBYNAME_PDFTitle, countPDFTitle);
    AddStringColumn(aRootEntry, AEntry, colPDFProducer, NODEBYNAME_PDFProducer, countPDFProducer);
    AddStringColumn(aRootEntry, AEntry, colPDFCreationDate, NODEBYNAME_PDFCreationDate, countPDFCreationDate);
    AddStringColumn(aRootEntry, AEntry, colPDFModificationDate, NODEBYNAME_PDFModificationDate, countPDFModificationDate);
    AddStringColumn(aRootEntry, AEntry, colPDFUserPassword, NODEBYNAME_PDFUserPassword, countPDFUserPassword);
    AddStringColumn(aRootEntry, AEntry, colPDFOwnerPassword, NODEBYNAME_PDFOwnerPassword, countPDFOwnerPassword);
  end;
end;

// PORCESS PREFETCH ************************************************************
procedure ProcessPF(AEntry: TEntry; aRootEntry: TPropertyNode);
begin
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_Prefetch) then
  begin
    AddStringColumn(aRootEntry, AEntry, colPFFilename, NODEBYNAME_PrefetchFileName, countPFFilename);
    AddFileTimeColumn(aRootEntry, AEntry, colPFExecutionTime, NODEBYNAME_PrefetchExecutionTimeUTC, countPFExecutionTime);
    AddInt32Column(aRootEntry, AEntry, colPFExecutionCount, NODEBYNAME_PrefetchExecutionCount, countPFExecutionCount);
  end;
end;

// PORCESS PRINTSPOOL **********************************************************
procedure ProcessPrintSpool(AEntry: TEntry; aRootEntry: TPropertyNode);
begin
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_PrintSpool) then
  begin
    AddStringColumn(aRootEntry, AEntry, colPrintSpool_DocumentName, NODEBYNAME_PrintSpool_DocumentName, countPrintSpool_DocumentName);
  end;
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_PrintSpoolShadow) then
  begin
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_ComputerName, NODEBYNAME_PrintSpoolShadow_ComputerName, countPrintSpoolShadow_ComputerName);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_DevMode, NODEBYNAME_PrintSpoolShadow_DevMode, countPrintSpoolShadow_DevMode);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_DocumentName, NODEBYNAME_PrintSpoolShadow_DocumentName, countPrintSpoolShadow_DocumentName);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_NotificationName, NODEBYNAME_PrintSpoolShadow_NotificationName, countPrintSpoolShadow_NotificationName);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_PCName, NODEBYNAME_PrintSpoolShadow_PCName, countPrintSpoolShadow_PCName);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_PrinterName, NODEBYNAME_PrintSpoolShadow_PrinterName, countPrintSpoolShadow_PrinterName);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_Signature, NODEBYNAME_PrintSpoolShadow_Signature, countPrintSpoolShadow_Signature);
    AddFileTimeColumn(aRootEntry, AEntry, colPrintSpoolShadow_SubmitTime, NODEBYNAME_PrintSpoolShadow_SubmitTime, countPrintSpoolShadow_SubmitTime);
    AddStringColumn(aRootEntry, AEntry, colPrintSpoolShadow_Username, NODEBYNAME_PrintSpoolShadow_UserName, countPrintSpoolShadow_UserName);
  end;
end;

// *** PROCESS Recycle Bin *****************************************************
procedure ProcessRecycleBin(AEntry: TEntry; aRootEntry: TPropertyNode);
begin
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_RECYCLEBIN) then
  begin
    AddStringColumn(aRootEntry, AEntry, colRecycleBinOriginalFilename, NODEBYNAME_RecycleBinFilename, countRecycleBinOriginalFilename);
    Addint64Column(aRootEntry, AEntry, colRecycleBinOriginalFileSize, NODEBYNAME_RecycleBinFileSize, countRecycleBinOriginalFileSize);
    AddFileTimeColumn(aRootEntry, AEntry, colRecycleBinDeletedTimeUTC, NODEBYNAME_RecycleBinDeletedTimeUTC, countRecycleBinDeletedTimeUTC);
  end;
end;

// *** PROCESS ZIP *************************************************************
procedure ProcessZIP(AEntry: TEntry; aRootEntry: TPropertyNode);
begin
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_ZIP) then
  begin
    AddInt32Column(aRootEntry, AEntry, colZIPNumberItems, NODEBYNAME_ZIPNumberItems, countZIPNumberItems);
  end;
end;

// ------------------------------------------------------------------------------
// procedure: Process Columns
// ------------------------------------------------------------------------------
procedure ProcessCol(Action_bl: boolean; AColName: string);
begin
end;

// *** ADD COLUMN **************************************************************
procedure AddColumn(ColumnName: TDataStoreField; ColumnPosition: integer);
begin
end;

// *** HIDE COLUMN *************************************************************
procedure HideColumn(ColumnName: TDataStoreField);
begin
end;

// ------------------------------------------------------------------------------
// procedure: Bookmark Count
// ------------------------------------------------------------------------------
procedure BookmarkCount(TheBMFolder_str: string);
var
  bmEntryList: TDataStore;
  bmEntry: TEntry;
  num_of_bookmarks_int: integer;
begin
  bmEntryList := GetDataStore(DATASTORE_BOOKMARKS);
  if not assigned(bmEntryList) then
  begin
    Progress.Log('Not assigned a data store. The script will terminate.');
    Exit;
  end;
  bmEntry := bmEntryList.First;
  if not assigned(bmEntry) then
  begin
    Progress.Log('No entries in the data store. The script will terminate.');
    bmEntryList.free;
    Exit;
  end;
  try
    Progress.Initialize(bmEntryList.Count, 'Processing...');
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
    Progress.Log('Summary:');
    while assigned(bmEntry) and (Progress.isRunning) do
    begin
      num_of_bookmarks_int := 0;
      if bmEntry.IsDirectory and (RegexMatch(bmEntry.FullPathName, 'My Bookmarks' + DBS + BM_FOLDER_SCRIPT_OUTPUT + DBS + TheBMFolder_str + DBS, False)) then
      begin
        num_of_bookmarks_int := bmEntryList.Children(bmEntry, True).Count;
        Progress.Log(RPad(bmEntry.EntryName, 60) + IntToStr(num_of_bookmarks_int));
        if bmEntry <> nil then
        begin
          UpdateBookmark(bmEntry, IntToStr(num_of_bookmarks_int));
        end;
      end;
      Progress.IncCurrentProgress;
      bmEntry := bmEntryList.Next;
    end;
  finally
    bmEntryList.free;
  end;
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
end;

// ==============================================================================
// The start of the script
// ==============================================================================
begin
  rpad_value := 40;
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.Log(SCRIPT_NAME + ' started' + RUNNING);

  Progress.Log(RPad('The command received is:', rpad_value) + CmdLine.Params.Text);
  Progress.DisplayMessageNow := 'Processing' + RUNNING;

  // CLI Settings
  gbl_ShowGUI := False;
  gbl_Show_About_Tab := False;
  gbl_Show_Options_Tab := False;
  gbl_Show_results_Tab := False;
  gbl_Show_Columns_Tab := False;

  str_Exif270Description := 'Exif 270: Description';
  str_Exif271Make := 'Exif 271: Make';
  str_Exif272DeviceModel := 'Exif 272: Device Model';
  str_Exif274Orientation := 'Exif 274: Orientation';
  str_Exif282XResolution := 'Exif 282: XResolution';
  str_Exif283YResolution := 'Exif 283: YResolution';
  str_Exif305Software := 'Exif 305: Software';
  str_Exif306DateTime := 'Exif 306: Date/Time';
  str_Exif315Artist := 'Exif 315: Artist';
  str_Exif33432Copyright := 'Exif 33432: Copyright';
  str_Exif36867DateTimeOriginal := 'Exif 36867: DateTimeOriginal';
  str_EXIFType := 'EXIF Type';
  str_GPSInfo16DirectionRef := 'GPS Info16 Direction Ref';
  str_GPSInfo17Direction := 'GPS Info17 Direction';
  str_GPSInfo1LatRef := 'GPS Info1 Lat. Ref';
  str_GPSInfo29DateStamp := 'GPS Info29 DateStamp';
  str_GPSInfo2Lat := 'GPS Info2 Lat.';
  str_GPSInfo3LongRef := 'GPS Info3 Long. Ref';
  str_GPSInfo4Long := 'GPS Info4 Long.';
  str_GPSInfo6Altitude := 'GPS Info6 Altitude';
  str_GPSInfo7TimeStamp := 'GPS Info7 TimeStamp';
  str_GPSLatcalc := 'GPS Lat. (calc)';
  str_GPSLongcalc := 'GPS Long. (calc)';
  str_JFifType := 'JFif Type';
  str_LNKTargetAccessedUTC := 'LNK Target Accessed (UTC)';
  str_LNKTargetCreatedUTC := 'LNK Target Created (UTC)';
  str_LNKTargetDeviceName := 'LNK Target Device Name';
  str_LNKTargetDriveType := 'LNK Target Drive Type';
  str_LNKGUIDMAC := 'LNK GUID MAC'; // Not target MAC? https://macvendorlookup.com/
  str_LNKTargetLocalBasePath := 'LNK Target Local Base Path';
  str_LNKTargetModifiedUTC := 'LNK Target Modified (UTC)';
  str_LNKTargetNetName := 'LNK Target Net Name';
  str_LNKTargetSize := 'LNK Target Size';
  str_LNKTargetVolumeLabel := 'LNK Target Volume Label';
  str_LNKTargetVolumeSerial := 'LNK Target Volume Serial';
  str_MSAuthor := 'MS Author';
  str_MSCompany := 'MS Company';
  str_MSCreated := 'MS Created (UTC)';
  str_MSEditTime := 'MS Edit Time';
  str_MSLastSavedby := 'MS Last Saved by';
  str_MSModified := 'MS Modified (UTC)';
  str_MSPrinted := 'MS Printed (UTC)';
  str_MSRevision := 'MS Revision';
  str_MSSubject := 'MS Subject';
  str_MSTitle := 'MS Title';
  str_MSWordCount := 'MS Word Count';
  str_NTFS30AccessedUTC := 'NTFS $30 Accessed (UTC)';
  str_NTFS30CreatedUTC := 'NTFS $30 Created (UTC)';
  str_NTFS30ModifiedUTC := 'NTFS $30 Modified (UTC)';
  str_NTFS30RecordModifiedUTC := 'NTFS $30 Modified Record (UTC)';
  str_PDFAuthor := 'PDF Author';
  str_PDFCreationDate := 'PDF Creation Date';
  str_PDFModificationDate := 'PDF Modification Date';
  str_PDFOwnerPwd := 'PDF Owner Password';
  str_PDFProducer := 'PDF Producer';
  str_PDFTitle := 'PDF Title';
  str_PDFUserPwd := 'PDF User Password';
  str_PrefetchExecutionCount := 'Prefetch Execution Count';
  str_PrefetchExecutionTime := 'Prefetch Execution Time';
  str_PrefetchFilename := 'Prefetch Filename';
  str_PrintSpool_DocumentName := 'Print Spool Document Name';
  str_PrintSpoolShadow_ComputerName := 'Print Spool Shadow Computer Name';
  str_PrintSpoolShadow_DevMode := 'Print Spool Shadow Dev Mode';
  str_PrintSpoolShadow_DocumentName := 'Print Spool Shadow Document Name';
  str_PrintSpoolShadow_NotificationName := 'Print Spool Shadow Notification Name';
  str_PrintSpoolShadow_PCName := 'Print Spool Shadow PC Name';
  str_PrintSpoolShadow_PrinterName := 'Print Spool Shadow Printer Name';
  str_PrintSpoolShadow_Signature := 'Print Spool Shadow Signature';
  str_PrintSpoolShadow_SubmitTime := 'Print Spool Shadow Submit Time';
  str_PrintSpoolShadow_UserName := 'Print Spool Shadow User Name';
  str_RecycleBinOriginalFilename := 'Recycle Bin Original Filename';
  str_RecycleBinOriginalFilesize := 'Recycle Bin Original File Size';
  str_RecycleBinDeletedTimeUTC := 'Recycle Bin Deleted Time (UTC)';
  str_ZIPNumberItems := 'ZIP Number Items';

  // STARTUP ========

  // Progress Bar Text
  pb_EXIF := '';
  pb_GPS := '';
  pb_LNK := '';
  pb_MSJUMPLIST := '';
  pb_MS := '';
  pb_NTFS := '';
  pb_PDF := '';
  pb_PF := '';
  pb_RecycleBin := '';
  pb_ZIP := '';

  Param_EXIF_Process := False;
  Param_GPS_Process := False;
  Param_LNK_Process := False;
  Param_MS_Process := False;
  Param_MSJUMPLIST_Process := False;
  Param_NTFS_Process := False;
  Param_PDF_Process := False;
  Param_PF_Process := False;
  Param_PrintSpool_Process := False;
  Param_RecycleBin_Process := False;
  Param_ZIP_Process := False;

  // Bookmark Params
  Param_Bookmark_PDFAuthor := False;
  Param_Bookmark_PREFETCH := False;
  Param_Bookmark_PRINTSPOOL := False;
  Param_Bookmark_MSAuthor := False;
  Param_Bookmark_MSPrinted := False;
  Param_Bookmark_EXIF := False;
  Param_Bookmark_GPS := False;
  Param_Bookmark_MSJUMPLIST := False;
  Param_Bookmark_RecycleBinPath := False;

  gbl_ShowGUI := CmdLine.Params.Indexof('NOSHOW') = -1;

  if (CmdLine.Params.Indexof('EXTRACT-METADATA') >= 0) or (CmdLine.ParamCount = 0) then
  begin
    Param_EXIF_Process := True;
    Param_GPS_Process := True;
    Param_LNK_Process := True;
    Param_MS_Process := True;
    Param_MSJUMPLIST_Process := True;
    Param_NTFS_Process := True;
    Param_PDF_Process := True;
    Param_PF_Process := True;
    Param_PrintSpool_Process := True;
    Param_RecycleBin_Process := True;
    Param_ZIP_Process := True;

    Param_Bookmark_EXIF := CmdLine.Params.Indexof('BM-CAMERAS') >= 0;
    Param_Bookmark_GPS := CmdLine.Params.Indexof('BM-GPS') >= 0;
    Param_Bookmark_MSPrinted := CmdLine.Params.Indexof('BM-MS-PRINTED') >= 0;
    Param_Bookmark_MSAuthor := CmdLine.Params.Indexof('BM-MS') >= 0;
    Param_Bookmark_PDFAuthor := CmdLine.Params.Indexof('BM-PDF') >= 0;
    Param_Bookmark_PREFETCH := CmdLine.Params.Indexof('BM-PREFETCH') >= 0;
    Param_Bookmark_PRINTSPOOL := CmdLine.Params.Indexof('BM-PRINTSPOOL') >= 0;
    Param_Bookmark_LNK := CmdLine.Params.Indexof('BM-LNK') >= 0;
    Param_Bookmark_MSJUMPLIST := CmdLine.Params.Indexof('BM-MSJUMPLIST') >= 0;
    Param_Bookmark_RecycleBinPath := CmdLine.Params.Indexof('BM-RECYCLEBINPATH') >= 0;

    Param_MessBox_Message := 'Extract All Metadata To Columns';

    Param_MessBox_Title := STR_EXTRACT_METADATA;
    Param_MessBox_ShowForce := True;
    Progress_Display_Title := STR_EXTRACT_METADATA;
    pb_Metadata := '';

    if Param_EXIF_Process then
      pb_Metadata := 'EXIF ';
    if Param_LNK_Process then
      pb_Metadata := pb_Metadata + 'LNK ';
    if Param_MS_Process then
      pb_Metadata := pb_Metadata + 'MS ';
    if Param_NTFS_Process then
      pb_Metadata := pb_Metadata + 'NTFS ';
    if Param_PDF_Process then
      pb_Metadata := pb_Metadata + 'PDF ';
    if Param_PF_Process then
      pb_Metadata := pb_Metadata + 'PREFETCH ';
    if Param_PrintSpool_Process then
      pb_Metadata := pb_Metadata + 'PRINTSPOOL ';
    if Param_Bookmark_LNK then
      pb_Metadata := pb_Metadata + 'LNK ';
    if Param_MSJUMPLIST_Process then
      pb_Metadata := pb_Metadata + 'JMPLST';
    pb_Metadata := trim(pb_Metadata);
  end;

  // EXIF
  if (CmdLine.Params.Indexof('EXTRACT-CAMERAS') >= 0) then
  begin
    Param_EXIF_Process := True;
    Param_Bookmark_EXIF := CmdLine.Params.Indexof('BM-CAMERAS') >= 0;

    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_EXIF then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark Cameras by Make/Model';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract Camera Exif Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_EXIF := 'Exif ';
  end;

  // GPS
  if (CmdLine.Params.Indexof('EXTRACT-GPS') >= 0) then
  begin
    Param_EXIF_Process := True;
    Param_GPS_Process := True;
    Param_Bookmark_GPS := CmdLine.Params.Indexof('BM-GPS') >= 0;

    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_GPS then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark GPS Photos';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract Camera GPS Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_GPS := 'GPS ';
  end;

  // MS Office by Printed
  if (CmdLine.Params.Indexof('EXTRACT-MS-PRINTED') >= 0) then
  begin
    Param_MS_Process := True;
    Param_Bookmark_MSPrinted := CmdLine.Params.Indexof('BM-MS-PRINTED') >= 0;
    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_MSPrinted then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark MS Office by Date Printed';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract MS Office Date Printed to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_MS := 'MS ';
  end;

  // MS
  if (CmdLine.Params.Indexof('EXTRACT-MS') >= 0) then
  begin
    Param_MS_Process := True;
    Param_Bookmark_MSAuthor := CmdLine.Params.Indexof('BM-MS') >= 0;
    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_MSAuthor then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark MS Office by Author';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract MS Office Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_MS := 'MS ';
  end;

  // NTFS
  if (CmdLine.Params.Indexof('EXTRACT-NTFS') >= 0) then
  begin
    Param_NTFS_Process := True;
    Param_MessBox_Title := STR_EXTRACT_METADATA;
    Param_MessBox_Message := 'Extract NTFS $30 Metadata to Columns';
    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_MS := 'NTFS ';
  end;

  // PDF
  if (CmdLine.Params.Indexof('EXTRACT-PDF') >= 0) then
  begin
    Param_PDF_Process := True;
    Param_Bookmark_PDFAuthor := CmdLine.Params.Indexof('BM-PDF') >= 0;
    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_PDFAuthor then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark PDF by Author';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract PDF Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_PDF := 'PDF ';
  end;

  // PREFTECH
  if (CmdLine.Params.Indexof('EXTRACT-PREFETCH') >= 0) then
  begin
    Param_PF_Process := True;
    Param_Bookmark_PREFETCH := CmdLine.Params.Indexof('BM-PREFETCH') >= 0;
    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_PREFETCH then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark Prefetch';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract Prefetch Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_PF := 'PF ';
  end;

  // PRINTSPOOL
  if (CmdLine.Params.Indexof('EXTRACT-PRINTSPOOL') >= 0) then
  begin
    Param_PrintSpool_Process := True;
    Param_Bookmark_PRINTSPOOL := CmdLine.Params.Indexof('BM-PRINTSPOOL') >= 0;
    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_PRINTSPOOL then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark Print Spool';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract Print Spool Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_SPL := 'SPL + SHD';
  end;

  // LNK
  if (CmdLine.Params.Indexof('EXTRACT-LNK') >= 0) then
  begin
    Param_LNK_Process := True;
    Param_Bookmark_LNK := CmdLine.Params.Indexof('BM-LNK') >= 0;

    if Param_Bookmark_LNK then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark LNK by Target Volume';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract LNK Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_LNK := 'LNK ';
  end;

  // MSJUMPLIST
  if (CmdLine.Params.Indexof('EXTRACT-MSJUMPLIST') >= 0) then
  begin
    Param_MSJUMPLIST_Process := True;
    Param_Bookmark_MSJUMPLIST := CmdLine.Params.Indexof('BM-MSJUMPLIST') >= 0;

    if Param_Bookmark_MSJUMPLIST then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark MS Jump List LNK';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract MS Jump List LNK Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_MSJUMPLIST := 'MS Jump List LNK ';
  end;

  // Recycle Bin
  if (CmdLine.Params.Indexof('EXTRACT-RECYCLEBIN') >= 0) then
  begin
    Param_RecycleBin_Process := True;
    Param_Bookmark_RecycleBinPath := CmdLine.Params.Indexof('BM-RECYCLEBINPATH') >= 0;
    Param_MessBox_Title := STR_EXTRACT_METADATA;

    if Param_Bookmark_RecycleBinPath then
    begin
      Param_MessBox_Title := STR_BOOKMARK_METADATA;
      Param_MessBox_Message := 'Bookmark Recycle Bin path';
    end
    else
    begin
      Param_MessBox_Title := STR_EXTRACT_METADATA;
      Param_MessBox_Message := 'Extract Recycle Bin Metadata to Columns';
    end;

    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_RecycleBin := 'RecycleBin ';
  end;

  // Extract Zip
  if (CmdLine.Params.Indexof('EXTRACT-ZIP') >= 0) then
  begin
    Param_ZIP_Process := True;
    Param_MessBox_Message := 'Bookmark ZIP by Item Count';
    Param_MessBox_Title := STR_EXTRACT_METADATA;
    Param_MessBox_ShowForce := False;
    Progress_Display_Title := Param_MessBox_Title + HYPHEN + Param_MessBox_Message;
    pb_ZIP := 'ZIP ';
  end;

  // Force the extraction of Metadata on each run
  bl_force_extract := False;

  MainProc;

  if Param_Bookmark_EXIF then
    BookmarkCount(BM_FOLDER_DIGITAL_CAMERAS);

  if Param_Bookmark_LNK then
    BookmarkCount(BM_FOLDER_LNK);

  Progress.CurrentPosition := Progress.Max;
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Progress.Log(RPad('OutList on finish:', rpad_value) + IntToStr(OutList.Count));
  Progress.Log(SCRIPT_NAME + ' finished.');

  if RegexMatch(ScriptTask.GetTaskListOption('OPENLOG'), 'True', False) then
    ShellExecute(0, nil, 'explorer.exe', Pchar(Progress.LogFilename), nil, 1);

end.
