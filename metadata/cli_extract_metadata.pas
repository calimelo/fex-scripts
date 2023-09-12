// Extract Param      Bookmark Param
// EXTRACT-CAMERAS    BM-CAMERAS
// EXTRACT-GPS        BM-GPS
// EXTRACT-MSJUMPLIST BM-MSJUMPLIST
// EXTRACT-MS         BM-MS
// EXTRACT-MS-PRINTED BM-MS-PRINTED
// EXTRACT-PDF        BM-PDF
// EXTRACT-PREFETCH   BM-PREFETCH
// EXTRACT-PRINTSPOOL BM-PRINTSPOOL
// EXTRACT-VIDEO      BM-VIDEO
// EXTRACT-LNK        BM-LNK

// EXTRACT-METADATA {All Metadata}
// SHOWEXTRACTANDBOOKMARK

unit ExtractMetadata;

interface

uses
  ByteStream, Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DataStreams,
  DateUtils, DIRegex, Graphics, Math, PropertyList, Regex, SysUtils, Variants, XML;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  NODEBYNAME_Company = 'Company'; // noslz
  NODEBYNAME_Compressed_Size = 'Compressed Size'; // noslz
  NODEBYNAME_CRC32 = 'CRC 32'; // noslz
  NODEBYNAME_Date_Time = 'Date/Time'; // noslz
  NODEBYNAME_Encrypted = 'Encrypted'; // noslz
  NODEBYNAME_EXIFType = 'Type'; // noslz
  NODEBYNAME_File_CRC = 'File CRC'; // noslz
  NODEBYNAME_File_Date = 'File Date'; // noslz
  NODEBYNAME_Filename = 'Filename'; // noslz
  NODEBYNAME_General_Flag = 'General Flag'; // noslz
  NODEBYNAME_GPSInfo16GPSImgDirectionRef = 'GPSInfo 16 (GPSImgDirectionRef)'; // noslz
  NODEBYNAME_GPSInfo17GPSImgDirection = 'GPSInfo 17 (GPSImgDirection)'; // noslz
  NODEBYNAME_GPSInfo1GPSLatitudeRef = 'GPSInfo 1 (GPSLatitudeRef)'; // noslz
  NODEBYNAME_GPSInfo29GPSDateStamp = 'GPSInfo 29 (GPSDateStamp)'; // noslz
  NODEBYNAME_GPSInfo2GPSLatitude = 'GPSInfo 2 (GPSLatitude)'; // noslz
  NODEBYNAME_GPSInfo3GPSLongitudeRef = 'GPSInfo 3 (GPSLongitudeRef)'; // noslz
  NODEBYNAME_GPSInfo4GPSLongitude = 'GPSInfo 4 (GPSLongitude)'; // noslz
  NODEBYNAME_GPSInfo6GPSAltitude = 'GPSInfo 6 (GPSAltitude)'; // noslz
  NODEBYNAME_GPSInfo7GPSTimeStamp = 'GPSInfo 7 (GPSTimeStamp)'; // noslz
  NODEBYNAME_HFSDateAdded = 'Date Added (UTC)'; // noslz
  NODEBYNAME_HFSFinderInfo = 'Additional Finder'; // noslz
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
  NODEBYNAME_NTFS10Standard = '$10 (Standard)'; // noslz
  NODEBYNAME_NTFS30Filename = '$30 (Filename)'; // noslz
  NODEBYNAME_NTFSAccessedUTC = 'Accessed (UTC)'; // noslz
  NODEBYNAME_NTFSCreatedUTC = 'Created (UTC)'; // noslz
  NODEBYNAME_NTFSModifiedRecordUTC = 'Modified Record (UTC)'; // noslz
  NODEBYNAME_NTFSModifiedUTC = 'Modified (UTC)'; // noslz
  NODEBYNAME_NTFSRecordModifiedUTC = 'Modified Record (UTC)'; // noslz
  NODEBYNAME_Number_Items = 'Number Items'; // noslz
  NODEBYNAME_Packed_Size = 'Packed Size'; // noslz
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
  NODEBYNAME_RAR_File_Header = 'RAR File Header'; // noslz
  NODEBYNAME_RecycleBinDeletedTimeUTC = 'Deleted time (UTC)'; // noslz
  NODEBYNAME_RecycleBinFilename = 'Filename'; // noslz
  NODEBYNAME_RecycleBinFileSize = 'Filesize'; // noslz
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
  NODEBYNAME_TotalTime = 'TotalTime'; // noslz
  NODEBYNAME_True = 'True'; // noslz
  NODEBYNAME_Uncompressed_Size = 'Uncompressed Size'; // noslz
  NODEBYNAME_Unpacked_Size = 'Unpacked Size'; // noslz
  NODEBYNAME_VIDEO_CAME = 'CAME'; // noslz
  NODEBYNAME_VIDEO_CREATED = 'Created'; // noslz
  NODEBYNAME_VIDEO_CREATIONDATE = 'Creationdate'; // noslz
  NODEBYNAME_VIDEO_DURATION = 'Duration'; // noslz
  NODEBYNAME_VIDEO_FIRM = 'FIRM'; // noslz
  NODEBYNAME_VIDEO_GPSALTITUDE = 'GPSAltitude'; // noslz
  NODEBYNAME_VIDEO_GPSLATITUDE = 'GPSLatitude'; // noslz
  NODEBYNAME_VIDEO_GPSLONGITUDE = 'GPSLongitude'; // noslz
  NODEBYNAME_VIDEO_MAKE = 'Make'; // noslz
  NODEBYNAME_VIDEO_MODEL = 'Model'; // noslz
  NODEBYNAME_VIDEO_MODIFIED = 'Modified'; // noslz
  NODEBYNAME_VIDEO_MKVDATEUTC = 'Date (UTC)'; // noslz
  NODEBYNAME_VIDEO_MKVFILEHEADER = 'MKV File Header'; // noslz
  NODEBYNAME_VIDEO_MKVMUXINGAPP = 'MuxingApp'; // noslz
  NODEBYNAME_VIDEO_MKVWRITINGAPP = 'WritingApp'; // noslz
  NODEBYNAME_VIDEO_PLAYDURATION = 'Play Duration'; // noslz
  NODEBYNAME_VIDEO_SENDDURATION = 'Send Duration'; // noslz
  NODEBYNAME_VIDEO_SOFTWARE = 'Software'; // noslz
  NODEBYNAME_VIDEO_LENS = 'LENS'; // noslz
  NODEBYNAME_Volume_Boot_Record = 'Volume Boot Record'; // noslz
  NODEBYNAME_Volume_ID = 'Volume ID'; // noslz
  NODEBYNAME_VolumeLabel = 'Volume Label'; // noslz
  NODEBYNAME_Words = 'Words'; // noslz
  NODEBYNAME_ZIPNumberItems = 'Number Items'; // noslz
  ROOT_ENTRY_AVI = 'AVI Data'; // noslz
  ROOT_ENTRY_EXIF = 'Marker E1 (EXIF)'; // noslz
  ROOT_ENTRY_HEIF = 'EXIF Data'; // noslz
  ROOT_ENTRY_JFIF = 'Marker E0 (JFIF)'; // noslz
  ROOT_ENTRY_MKV = 'MKV Data'; // noslz
  ROOT_ENTRY_MOV = 'MOV Data'; // noslz
  ROOT_ENTRY_PDF = 'PDF Data'; // noslz
  ROOT_ENTRY_Prefetch = 'PF Data'; // noslz
  ROOT_ENTRY_PrintSpool = 'SPL Data'; // noslz
  ROOT_ENTRY_PrintSpoolShadow = 'SHD Data'; // noslz
  ROOT_ENTRY_RAR = 'RAR Data'; // noslz
  ROOT_ENTRY_RECYCLEBIN = 'Windows Recycle Bin Data'; // noslz
  ROOT_ENTRY_TIFF = 'Image 1'; // noslz
  ROOT_ENTRY_WMV = 'WMV Data'; // noslz
  ROOT_ENTRY_ZIP = 'ZIP Data'; // noslz
  SIG_PRINT_SPOOL = 'PRINT SPOOL'; // noslz
  SIG_PRINT_SPOOL_SHADOW = 'PRINT SPOOL SHADOW'; // noslz
  SIG_WINDOWS_RECYCLE_BIN = 'WINDOWS RECYCLE BIN'; // noslz

  gbl_LOGGING = False;
  BM_FOLDER_DIGITAL_CAMERAS = 'Digital Cameras';
  BM_FOLDER_DIGITAL_CAMERAS_VIDEO = 'Digital Cameras - Video';
  BM_FOLDER_GPS_PHOTOS = 'GPS Photos';
  BM_FOLDER_GPS_VIDEOS = 'GPS Videos';
  BM_FOLDER_LNK = 'LNK Files By Target Volume';
  BM_FOLDER_MSJUMPLIST = 'MS Jump List Files';
  BM_FOLDER_MULTIPLEXING = 'Multiplexing';
  BM_FOLDER_PDF_AUTHORS = 'PDF Authors';
  BM_FOLDER_PREFTECH = 'Prefetch';
  BM_FOLDER_PRINTSPOOL = 'Print Spool by Document';
  BM_FOLDER_PRINTSPOOLSHADOW = 'Print Spool Shadow by User';
  BM_FOLDER_SCRIPT_OUTPUT = 'Script Output';
  BM_MS_AUTHORS = 'MS Authors';
  BM_MS_PRINTED = 'MS Printed';
  BS = '\';
  CHAR_LENGTH = 80;
  HYPHEN = ' - ';
  RUNNING = '...';
  SCRIPT_NAME = 'Extract Metadata';
  SPACE = ' ';
  SPECIALCHAR_TICK: char = #10004; // noslz
  STR_BOOKMARK_METADATA = 'Bookmark Metadata';
  STR_EXTRACT_METADATA = 'Extract Metadata';
  TSWT = 'The script will terminate.';
  VIDEO_REGEX = '(3G2|3GP|AVI|MKV|MOV|MP4|WMV)';

  COL_SUMMARY_ALTITUDE = '*Altitude';
  COL_SUMMARY_LATITUDE = '*Latitude*';
  COL_SUMMARY_LONGITUDE = '*Longitude*';
  COL_SUMMARY_MAKE = '*Make';
  COL_SUMMARY_MODEL = '*Model*';
  COL_SUMMARY_SOFTWARE = '*Software*';
  // --------------
  COL_EXIF270DESCRIPTION = 'Exif 270: Description';
  COL_EXIF271MAKE = 'Exif 271: Make';
  COL_EXIF272DEVICEMODEL = 'Exif 272: Device Model';
  COL_EXIF274ORIENTATION = 'Exif 274: Orientation';
  COL_EXIF282XRESOLUTION = 'Exif 282: XResolution';
  COL_EXIF283YRESOLUTION = 'Exif 283: YResolution';
  COL_EXIF305SOFTWARE = 'Exif 305: Software';
  COL_EXIF306DATETIME = 'Exif 306: Date/Time';
  COL_EXIF315ARTIST = 'Exif 315: Artist';
  COL_EXIF33432COPYRIGHT = 'Exif 33432: Copyright';
  COL_EXIF36867DATETIMEORIGINAL = 'Exif 36867: DateTimeOriginal';
  COL_EXIFTYPE = 'EXIF Type';
  COL_GPSINFO16DIRECTIONREF = 'GPS Info16 Direction Ref';
  COL_GPSINFO17DIRECTION = 'GPS Info17 Direction';
  COL_GPSINFO1LATREF = 'GPS Info1 Lat. Ref';
  COL_GPSINFO29DATESTAMP = 'GPS Info29 DateStamp';
  COL_GPSINFO2LAT = 'GPS Info2 Lat.';
  COL_GPSINFO3LONGREF = 'GPS Info3 Long. Ref';
  COL_GPSINFO4LONG = 'GPS Info4 Long.';
  COL_GPSINFO6ALTITUDE = 'GPS Info6 Altitude';
  COL_GPSINFO7TIMESTAMP = 'GPS Info7 TimeStamp';
  COL_GPSLATCALC = 'GPS Lat. (calc)';
  COL_GPSLONGCALC = 'GPS Long. (calc)';
  COL_JFIFTYPE = 'JFif Type';
  COL_LNKGUIDMAC = 'LNK GUID MAC'; // https://macvendorlookup.com/
  COL_LNKTARGETACCESSEDUTC = 'LNK Target Accessed (UTC)';
  COL_LNKTARGETCREATEDUTC = 'LNK Target Created (UTC)';
  COL_LNKTARGETDEVICENAME = 'LNK Target Device Name';
  COL_LNKTARGETDRIVETYPE = 'LNK Target Drive Type';
  COL_LNKTARGETLOCALBASEPATH = 'LNK Target Local Base Path';
  COL_LNKTARGETMODIFIEDUTC = 'LNK Target Modified (UTC)';
  COL_LNKTARGETNETNAME = 'LNK Target Net Name';
  COL_LNKTARGETSIZE = 'LNK Target Size';
  COL_LNKTARGETVOLUMELABEL = 'LNK Target Volume Label';
  COL_LNKTARGETVOLUMESERIAL = 'LNK Target Volume Serial';
  COL_MSAUTHOR = 'MS Author';
  COL_MSCOMPANY = 'MS Company';
  COL_MSCREATED = 'MS Created (UTC)';
  COL_MSEDITTIME = 'MS Edit Time';
  COL_MSLASTSAVEDBY = 'MS Last Saved by';
  COL_MSMODIFIED = 'MS Modified (UTC)';
  COL_MSPRINTED = 'MS Printed (UTC)';
  COL_MSREVISION = 'MS Revision';
  COL_MSSUBJECT = 'MS Subject';
  COL_MSTITLE = 'MS Title';
  COL_MSWORDCOUNT = 'MS Word Count';
  COL_NTFS30ACCESSEDUTC = 'NTFS $30 Accessed (UTC)';
  COL_NTFS30CREATEDUTC = 'NTFS $30 Created (UTC)';
  COL_NTFS30MODIFIEDUTC = 'NTFS $30 Modified (UTC)';
  COL_NTFS30RECORDMODIFIEDUTC = 'NTFS $30 Modified Record (UTC)';
  COL_PDFAUTHOR = 'PDF Author';
  COL_PDFCREATIONDATE = 'PDF Creation Date';
  COL_PDFMODIFICATIONDATE = 'PDF Modification Date';
  COL_PDFOWNERPWD = 'PDF Owner Password';
  COL_PDFPRODUCER = 'PDF Producer';
  COL_PDFTITLE = 'PDF Title';
  COL_PDFUSERPWD = 'PDF User Password';
  COL_PREFETCHEXECUTIONCOUNT = 'Prefetch Execution Count';
  COL_PREFETCHEXECUTIONTIME = 'Prefetch Execution Time';
  COL_PREFETCHFILENAME = 'Prefetch Filename';
  COL_PRINTSPOOL_DOCUMENTNAME = 'Print Spool Document Name';
  COL_PRINTSPOOLSHADOW_COMPUTERNAME = 'Print Spool Shadow Computer Name';
  COL_PRINTSPOOLSHADOW_DEVMODE = 'Print Spool Shadow Dev Mode';
  COL_PRINTSPOOLSHADOW_DOCUMENTNAME = 'Print Spool Shadow Document Name';
  COL_PRINTSPOOLSHADOW_NOTIFICATIONNAME = 'Print Spool Shadow Notification Name';
  COL_PRINTSPOOLSHADOW_PCNAME = 'Print Spool Shadow PC Name';
  COL_PRINTSPOOLSHADOW_PRINTERNAME = 'Print Spool Shadow Printer Name';
  COL_PRINTSPOOLSHADOW_SIGNATURE = 'Print Spool Shadow Signature';
  COL_PRINTSPOOLSHADOW_SUBMITTIME = 'Print Spool Shadow Submit Time';
  COL_PRINTSPOOLSHADOW_USERNAME = 'Print Spool Shadow User Name';
  COL_RECYCLEBINDELETEDTIMEUTC = 'Recycle Bin Deleted Time (UTC)';
  COL_RECYCLEBINORIGINALFILENAME = 'Recycle Bin Original Filename';
  COL_RECYCLEBINORIGINALFILESIZE = 'Recycle Bin Original File Size';
  COL_VIDEOCAMERA = 'Video Camera';
  COL_VIDEOCREATED = 'Video Created';
  COL_VIDEOCREATIONDATE = 'Video Creationdate';
  COL_VIDEODURATION = 'Video Duration';
  COL_VIDEOFIRM = 'Video Firmware';
  COL_VIDEOGPSALTITUDE = 'Video GPS Altitude';
  COL_VIDEOGPSLATITUDE = 'Video GPS Latitude';
  COL_VIDEOGPSLONGITUDE = 'Video GPS Longitude';
  COL_VIDEOLENS = 'Video Lens';
  COL_VIDEOMAKE = 'Video Make';
  COL_VIDEOMKVDATEUTC = 'Video MKV Date (UTC)';
  COL_VIDEOMKVMUXINGAPP = 'Video MKV MuxingApp';
  COL_VIDEOMKVTRACKS = 'Video MKV Tracks';
  COL_VIDEOMKVWRITINGAPP = 'Video MKV WritingApp';
  COL_VIDEOMODEL = 'Video Model';
  COL_VIDEOMODIFIED = 'Video Modified';
  COL_VIDEOPLAYDURATION = 'Video Play Duration';
  COL_VIDEOSENDDURATION = 'Video Send Duration';
  COL_VIDEOSOFTWARE = 'Video Software';
  COL_ZIPNUMBERITEMS = 'ZIP Number Items';

var
  gbl_Bookmark_EXIF: boolean;
  gbl_Bookmark_GPS: boolean;
  gbl_Bookmark_LNK: boolean;
  gbl_Bookmark_MSAuthor: boolean;
  gbl_Bookmark_MSJUMPLIST: boolean;
  gbl_Bookmark_MSPrinted: boolean;
  gbl_Bookmark_PDFAuthor: boolean;
  gbl_Bookmark_PREFETCH: boolean;
  gbl_Bookmark_PRINTSPOOL: boolean;
  gbl_Bookmark_RecycleBinPath: boolean;
  gbl_Bookmark_Video: boolean;
  gbl_Bookmark_VideoMKVMuxing: boolean;
  gbl_EXIF_Process: boolean;
  gbl_force_extract: boolean;
  gbl_GPS_Process: boolean;
  gbl_LNK_Process: boolean;
  gbl_MessBox_ShowForce: boolean;
  gbl_MS_Process: boolean;
  gbl_MSJUMPLIST_Process: boolean;
  gbl_NTFS_Process: boolean;
  gbl_PDF_Process: boolean;
  gbl_PF_Process: boolean;
  gbl_PrintSpool_Process: boolean;
  gbl_RecycleBin_Process: boolean;
  gbl_Video_Process: boolean;
  gbl_ZIP_Process: boolean;
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
  colVideoCAME: TDataStoreField;
  colVideoCreated: TDataStoreField;
  colVideoCreationdate: TDataStoreField;
  colVideoDuration: TDataStoreField;
  colVideoFIRM: TDataStoreField;
  colVideoGPSAltitude: TDataStoreField;
  colVideoGPSLatitude: TDataStoreField;
  colVideoGPSLongitude: TDataStoreField;
  colVideoLENS: TDataStoreField;
  colVideoMake: TDataStoreField;
  colVideoMKVDateUTC: TDataStoreField;
  colVideoMKVMuxingApp: TDataStoreField;
  colVideoMKVTracks: TDataStoreField;
  colVideoMKVWritingApp: TDataStoreField;
  colVideoModel: TDataStoreField;
  colVideoModified: TDataStoreField;
  colVideoPlayDuration: TDataStoreField;
  colVideoSendDuration: TDataStoreField;
  colVideoSoftware: TDataStoreField;
  colZIPNumberItems: TDataStoreField;
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
  countVideoCamera: integer;
  countVideoCreated: integer;
  countVideoCreationdate: integer;
  countVideoDuration: integer;
  countVideoFirm: integer;
  countVideoGPSAltitude: integer;
  countVideoGPSLatitude: integer;
  countVideoGPSLongitude: integer;
  countVideoLens: integer;
  countVideoMake: integer;
  countVideoMKVDateUTC: integer;
  countVideoMKVMuxingApp: integer;
  countVideoMKVTracks: integer;
  countVideoMKVWritingApp: integer;
  countVideoModel: integer;
  countVideoModified: integer;
  countVideoPlayDuration: integer;
  countVideoSendDuration: integer;
  countVideoSoftware: integer;
  countZIPNumberItems: integer;
  gbl_DoAll: boolean;
  gbl_DoChecked: boolean;
  gbl_RunSignatureAnalysis: boolean;
  gbl_Show_About_Tab: boolean;
  gbl_Show_Columns_Tab: boolean;
  gbl_Show_Extract_Tab: boolean;
  gbl_Show_Results_Tab: boolean;
  gbl_ShowGUI: boolean;
  gWorking_Count: integer;
  gdirectory_count: integer;
  gencrypted_file_count: integer;
  gErrorLog_StringList: TStringList;
  gstarting_tick_count: uint64;
  gtotal_time_int: uint64;
  gzero_size_count: integer;
  PrintSpoolComment: string;
  Progress_Display_Title: string;
  Result_StringList: TStringList;
  rpad_value: integer;
  str_MessBox_Title: string;
  str_MessBox_Message: string;
  str_MSAuthorName: string; // (not a column name - used to hold temp value of str_MSAuthor for bookmarking)
  str_VideoMake: string;
  str_VideoModel: string;

function TestEntryForProcess(testEntry: TEntry): boolean;
function MKV_NodeFrog(aNode: TPropertyNode; anint: integer): integer;
procedure BookmarkResults(bmEntry: TEntry);
procedure ErrorLog(aStringList: TStringList; aString: string);
procedure gdh1(show_bl: boolean; aStringList: TStringList);
procedure ProcessFiles(process_TList: TList);
procedure SignatureAnalysis(SigThis_TList: TList);

implementation

function RPad(const aString: string; AChars: integer): string;
begin
  AChars := AChars - Length(aString);
  if AChars > 0 then
    Result := aString + StringOfChar(' ', AChars)
  else
    Result := aString;
end;

procedure MessageUser(aString: string);
begin
  Progress.Log(aString);
end;

procedure MessageLog(aString: string);
begin
  if gbl_LOGGING then
    Progress.Log(aString);
end;

procedure ErrorLog(aStringList: TStringList; aString: string);
begin
  if assigned(aStringList) and (aStringList.Count <= 1000) then
    aStringList.Add(aString);
  Progress.Log(aString);
end;

function MKV_NodeFrog(aNode: TPropertyNode; anint: integer): integer;
var
  i: integer;
  theNodeList: TObjectList;
  track_count_int: integer;
  codec_str: string;
  track_type_str: string;
begin
  Result := 0;
  if assigned(aNode) and Progress.isRunning then
  begin
    theNodeList := aNode.PropChildList;
    if assigned(theNodeList) then
    begin
      for i := 0 to theNodeList.Count - 1 do
      begin
        aNode := TPropertyNode(theNodeList.items[i]);
        if assigned(aNode) and (trim(aNode.PropName) = 'CodecID') then // noslz
        begin
          codec_str := trim(aNode.PropDisplayValue);
        end;
        if assigned(aNode) and (trim(aNode.PropName) = 'TrackType') then // noslz
        begin
          track_type_str := trim(aNode.PropDisplayValue);
          if track_type_str = '1' then // noslz
            track_count_int := track_count_int + 1;
        end;
        MKV_NodeFrog(aNode, anint + 1);
      end;
    end;
  end;
  Result := track_count_int;
end;

procedure gdh1(show_bl: boolean; aStringList: TStringList);
var
  i: integer;
begin
  for i := 0 to aStringList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
  end;
end;

procedure CreateColumnNames;
begin
  if gbl_EXIF_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'EXIF');
    colJFifType := AddMetaDataField(COL_JFIFTYPE, ftString);
    colEXIFType := AddMetaDataField(COL_EXIFTYPE, ftString);
    colTag270Description := AddMetaDataField(COL_EXIF270DESCRIPTION, ftString);
    colTag271Make := AddMetaDataField(COL_EXIF271MAKE, ftString);
    colTag272DeviceModel := AddMetaDataField(COL_EXIF272DEVICEMODEL, ftString);
    colTag274Orientation := AddMetaDataField(COL_EXIF274ORIENTATION, ftString);
    colTag282XResolution := AddMetaDataField(COL_EXIF282XRESOLUTION, ftFloat);
    colTag283YResolution := AddMetaDataField(COL_EXIF283YRESOLUTION, ftFloat);
    colTag305Software := AddMetaDataField(COL_EXIF305SOFTWARE, ftString);
    colTag306DateTime := AddMetaDataField(COL_EXIF306DATETIME, ftString);
    colTag315Artist := AddMetaDataField(COL_EXIF315ARTIST, ftString);
    colTag36867DateTimeOriginal := AddMetaDataField(COL_EXIF36867DATETIMEORIGINAL, ftString);
    colTag33432Copyright := AddMetaDataField(COL_EXIF33432COPYRIGHT, ftString);
    colGPSPosLatitude := AddMetaDataField(COL_GPSLATCALC, ftFloat);
    colGPSPosLongitude := AddMetaDataField(COL_GPSLONGCALC, ftFloat);
    colGPSInfo1LatitudeRef := AddMetaDataField(COL_GPSINFO1LATREF, ftString);
    colGPSInfo2Latitude := AddMetaDataField(COL_GPSINFO2LAT, ftString);
    colGPSInfo3LongitudeRef := AddMetaDataField(COL_GPSINFO3LONGREF, ftString);
    colGPSInfo4Longitude := AddMetaDataField(COL_GPSINFO4LONG, ftString);
    colGPSInfo6Altitude := AddMetaDataField(COL_GPSINFO6ALTITUDE, ftFloat);
    colGPSInfo7TimeStamp := AddMetaDataField(COL_GPSINFO7TIMESTAMP, ftString);
    colGPSInfo16DirectionRef := AddMetaDataField(COL_GPSINFO16DIRECTIONREF, ftString);
    colGPSInfo17Direction := AddMetaDataField(COL_GPSINFO17DIRECTION, ftFloat);
    colGPSInfo29DateStamp := AddMetaDataField(COL_GPSINFO29DATESTAMP, ftString);
  end;

  if gbl_MS_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'MS');
    colMSCreated := AddMetaDataField(COL_MSCREATED, ftDateTime);
    colMSModified := AddMetaDataField(COL_MSMODIFIED, ftDateTime);
    colMSPrinted := AddMetaDataField(COL_MSPRINTED, ftDateTime);
    colMSTitle := AddMetaDataField(COL_MSTITLE, ftString);
    colMSAuthor := AddMetaDataField(COL_MSAUTHOR, ftString);
    colMSLastSavedby := AddMetaDataField(COL_MSLASTSAVEDBY, ftString);
    colMSSubject := AddMetaDataField(COL_MSSUBJECT, ftString);
    colMSCompany := AddMetaDataField(COL_MSCOMPANY, ftString);
    colMSWordCount := AddMetaDataField(COL_MSWORDCOUNT, ftInteger);
    colMSRevision := AddMetaDataField(COL_MSREVISION, ftInteger);
    colMSEditTime := AddMetaDataField(COL_MSEDITTIME, ftInteger);
  end;

  if gbl_PDF_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'PDF');
    colPDFAuthor := AddMetaDataField(COL_PDFAUTHOR, ftString);
    colPDFTitle := AddMetaDataField(COL_PDFTITLE, ftString);
    colPDFProducer := AddMetaDataField(COL_PDFPRODUCER, ftString);
    colPDFCreationDate := AddMetaDataField(COL_PDFCREATIONDATE, ftString);
    colPDFModificationDate := AddMetaDataField(COL_PDFMODIFICATIONDATE, ftString);
    colPDFUserPassword := AddMetaDataField(COL_PDFUSERPWD, ftString);
    colPDFOwnerPassword := AddMetaDataField(COL_PDFOWNERPWD, ftString);
  end;

  if gbl_NTFS_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'NTFS');
    colNTFS30FileNameCreated := AddMetaDataField(COL_NTFS30CREATEDUTC, ftDateTime);
    colNTFS30FileNameModified := AddMetaDataField(COL_NTFS30MODIFIEDUTC, ftDateTime);
    colNTFS30FileNameRecordModified := AddMetaDataField(COL_NTFS30RECORDMODIFIEDUTC, ftDateTime);
    colNTFS30FileNameAccessed := AddMetaDataField(COL_NTFS30ACCESSEDUTC, ftDateTime);
  end;

  if gbl_LNK_Process or gbl_MSJUMPLIST_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'LNK');
    colLNKFileCreated := AddMetaDataField(COL_LNKTARGETCREATEDUTC, ftDateTime);
    colLNKFileModified := AddMetaDataField(COL_LNKTARGETMODIFIEDUTC, ftDateTime);
    colLNKFileAccessed := AddMetaDataField(COL_LNKTARGETACCESSEDUTC, ftDateTime);
    colLNKFileSize := AddMetaDataField(COL_LNKTARGETSIZE, ftLargeInt);
    colLNKFileLocalBasePath := AddMetaDataField(COL_LNKTARGETLOCALBASEPATH, ftString);
    colLNKFileGUIDMAC := AddMetaDataField(COL_LNKGUIDMAC, ftString);
    colLNKFileDriveSerialNumber := AddMetaDataField(COL_LNKTARGETVOLUMESERIAL, ftString);
    colLNKFileVolumeLabel := AddMetaDataField(COL_LNKTARGETVOLUMELABEL, ftString);
    colLNKFileDriveType := AddMetaDataField(COL_LNKTARGETDRIVETYPE, ftString);
    colLNKFileDeviceName := AddMetaDataField(COL_LNKTARGETDEVICENAME, ftString);
    colLNKFileNetName := AddMetaDataField(COL_LNKTARGETNETNAME, ftString);
  end;

  if gbl_PF_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'PF');
    colPFFilename := AddMetaDataField(COL_PREFETCHFILENAME, ftString);
    colPFExecutionTime := AddMetaDataField(COL_PREFETCHEXECUTIONTIME, ftDateTime);
    colPFExecutionCount := AddMetaDataField(COL_PREFETCHEXECUTIONCOUNT, ftInteger);
  end;

  if gbl_PrintSpool_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'Print Spool');
    colPrintSpool_DocumentName := AddMetaDataField(COL_PRINTSPOOL_DOCUMENTNAME, ftString);
    colPrintSpoolShadow_ComputerName := AddMetaDataField(COL_PRINTSPOOLSHADOW_COMPUTERNAME, ftString);
    colPrintSpoolShadow_DevMode := AddMetaDataField(COL_PRINTSPOOLSHADOW_DEVMODE, ftString);
    colPrintSpoolShadow_DocumentName := AddMetaDataField(COL_PRINTSPOOLSHADOW_DOCUMENTNAME, ftString);
    colPrintSpoolShadow_NotificationName := AddMetaDataField(COL_PRINTSPOOLSHADOW_NOTIFICATIONNAME, ftString);
    colPrintSpoolShadow_PCName := AddMetaDataField(COL_PRINTSPOOLSHADOW_PCNAME, ftString);
    colPrintSpoolShadow_PrinterName := AddMetaDataField(COL_PRINTSPOOLSHADOW_PRINTERNAME, ftString);
    colPrintSpoolShadow_Signature := AddMetaDataField(COL_PRINTSPOOLSHADOW_SIGNATURE, ftString);
    colPrintSpoolShadow_SubmitTime := AddMetaDataField(COL_PRINTSPOOLSHADOW_SUBMITTIME, ftDateTime);
    colPrintSpoolShadow_Username := AddMetaDataField(COL_PRINTSPOOLSHADOW_USERNAME, ftString);
  end;

  if gbl_Video_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'Video');
    colVideoCAME := AddMetaDataField(COL_VIDEOCAMERA, ftString);
    colVideoCreated := AddMetaDataField(COL_VIDEOCREATED, ftDateTime);
    colVideoCreationdate := AddMetaDataField(COL_VIDEOCREATIONDATE, ftString);
    colVideoDuration := AddMetaDataField(COL_VIDEODURATION, ftFloat);
    colVideoFIRM := AddMetaDataField(COL_VIDEOFIRM, ftString);
    colVideoGPSAltitude := AddMetaDataField(COL_VIDEOGPSALTITUDE, ftString);
    colVideoGPSLatitude := AddMetaDataField(COL_VIDEOGPSLATITUDE, ftString);
    colVideoGPSLongitude := AddMetaDataField(COL_VIDEOGPSLONGITUDE, ftString);
    colVideoLENS := AddMetaDataField(COL_VIDEOLENS, ftString);
    colVideoMake := AddMetaDataField(COL_VIDEOMAKE, ftString);
    colVideoModel := AddMetaDataField(COL_VIDEOMODEL, ftString);
    colVideoModified := AddMetaDataField(COL_VIDEOMODIFIED, ftDateTime);
    colVideoMKVDateUTC := AddMetaDataField(COL_VIDEOMKVDATEUTC, ftString);
    colVideoMKVMuxingApp := AddMetaDataField(COL_VIDEOMKVMUXINGAPP, ftString);
    colVideoMKVTracks := AddMetaDataField(COL_VIDEOMKVTRACKS, ftInteger);
    colVideoMKVWritingApp := AddMetaDataField(COL_VIDEOMKVWRITINGAPP, ftString);
    colVideoPlayDuration := AddMetaDataField(COL_VIDEOPLAYDURATION, ftFloat);
    colVideoSendDuration := AddMetaDataField(COL_VIDEOSENDDURATION, ftFloat);
    colVideoSoftware := AddMetaDataField(COL_VIDEOSOFTWARE, ftString);
  end;

  if gbl_RecycleBin_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'Recycle Bin');
    colRecycleBinOriginalFilename := AddMetaDataField(COL_RECYCLEBINORIGINALFILENAME, ftString);
    colRecycleBinOriginalFileSize := AddMetaDataField(COL_RECYCLEBINORIGINALFILESIZE, ftLargeInt);
    colRecycleBinDeletedTimeUTC := AddMetaDataField(COL_RECYCLEBINDELETEDTIMEUTC, ftDateTime);
  end;

  if gbl_ZIP_Process then
  begin
    MessageLog(RPad('Created columns:', rpad_value) + 'Zip');
    colZIPNumberItems := AddMetaDataField(COL_ZIPNUMBERITEMS, ftInteger);
  end;
  MessageLog(StringOfChar('-', CHAR_LENGTH));
end;

function TestEntryForProcess(testEntry: TEntry): boolean;
begin
  try
    Result := False;
    if not assigned(testEntry) then
    begin
      ErrorLog(gErrorLog_StringList, RPad('Error' + HYPHEN + 'Not assigned', rpad_value) + testEntry.EntryName + SPACE + Format('(%1.2nmb)', [testEntry.LogicalSize / (1024 * 1024)]) + SPACE + 'Bates#:' + SPACE + IntToStr(testEntry.ID));
      Exit;
    end;
    if testEntry.isDirectory then
    begin
      Result := False;
      gdirectory_count := gdirectory_count + 1;
      Exit;
    end;
    if testEntry.LogicalSize <= 0 then
    begin
      Result := False;
      gzero_size_count := gzero_size_count + 1;
      Exit;
    end;
    if testEntry.isEncrypted then
    begin
      Result := False;
      // ErrorLog(gErrorLog_StringList, RPad('Error' + HYPHEN + 'isEncrypted', rpad_value) + testEntry.EntryName + SPACE + Format('(%1.2nmb)',[testEntry.LogicalSize/(1024*1024)]) + SPACE + 'Bates#:' + SPACE + IntToStr(testEntry.ID));
      gencrypted_file_count := gencrypted_file_count + 1;
      Exit;
    end;
    Result := True; // If it makes it here the entry has passed the test.
  finally
    // Progress.Log(TestEntry.EntryName + SPACE + IntToStr(TestEntry.ID) + SPACE + BoolToStr(Result, True));
  end;
end;

// Procedure: Jump List - Locate Jump List files, Expand them, then run a signature check on the expanded files
procedure ProcessJumpList(aTList: TList);
var
  Expand_TList: TList;
  FileSignatureInfo: TFileTypeInformation;
  i: integer;
  jlEntry: TEntry;
  jlFileExt: string;
  jlParentFileExt: string;
  JUMP_Progress: TPAC;
  msjumplist_count: integer;
  Uppername: string;

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
        if TestEntryForProcess(jlEntry) then
        begin
          Uppername := UpperCase(jlEntry.EntryName);
          FileSignatureInfo := jlEntry.FileDriverInfo;
          jlFileExt := lowercase(jlEntry.EntryNameExt);

          // Locate .automaticdestinations-ms files
          if (jlFileExt = '.automaticdestinations-ms') then
          begin
            if not(dstExpanded in jlEntry.Status) then
            begin
              DetermineFileType(jlEntry);
              Expand_TList.Add(jlEntry);
              msjumplist_count := msjumplist_count + 1;
            end
            else
              msjumplist_count := msjumplist_count + 1;
          end;
          Progress.IncCurrentProgress(1);
        end;
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
          if TestEntryForProcess(jlEntry) then
          begin
            Uppername := UpperCase(jlEntry.EntryName);
            FileSignatureInfo := jlEntry.FileDriverInfo;
            if assigned(jlEntry) then
            begin
              if jlEntry.parent <> nil then
              begin
                jlParentFileExt := lowercase(jlEntry.parent.EntryNameExt);
                if (jlParentFileExt = '.automaticdestinations-ms') then
                  DetermineFileType(jlEntry);
              end;
              Progress.IncCurrentProgress(1);
            end;
          end;
        end;
      end;
    finally
      Expand_TList.free;
    end;
  end;
end;

// Procedure: Process NTFS -----------------------------------------------------
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
    if gbl_NTFS_Process then
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
          if TestEntryForProcess(anEntry) then
          begin
            proceed_with_NTFS_extraction := True;
            NTFSFound := False;
            // TEST NTFS COLUMNS FOR Count METADATA
            if (colNTFS30FileNameCreated.isNull(anEntry)) and (colNTFS30FileNameModified.isNull(anEntry)) and (colNTFS30FileNameRecordModified.isNull(anEntry)) and (colNTFS30FileNameAccessed.isNull(anEntry)) then
            begin
              proceed_with_NTFS_extraction := True;
            end
            else
              proceed_with_NTFS_extraction := False;

            if gbl_force_extract then
              proceed_with_NTFS_extraction := True;

            if gbl_DoChecked then
            begin
              if anEntry.IsChecked then
                proceed_with_NTFS_extraction := proceed_with_NTFS_extraction and anEntry.IsChecked
              else
                proceed_with_NTFS_extraction := False;
            end;

            if proceed_with_NTFS_extraction = True then
              try
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
                      try
                        FreeAndNil(aPropertyTree);
                      except
                        Progress.Log(ATRY_EXCEPT_STR + '!!! Exception 1A. !!! - FreeAndNil of aPropertyTree' + SPACE + anEntry.EntryName + SPACE + Format('(%1.2nmb)', [anEntry.LogicalSize / (1024 * 1024)]) + SPACE + 'Bates#:' + SPACE +
                          IntToStr(anEntry.ID));
                      end;
                  end;
              except
                Progress.Log(ATRY_EXCEPT_STR + '!!! Exception 1B. !!! - ProcessDisplayProperties' + SPACE + anEntry.EntryName + SPACE + Format('(%1.2nmb)', [anEntry.LogicalSize / (1024 * 1024)]) + SPACE + 'Bates#:' + SPACE +
                  IntToStr(anEntry.ID));
              end;
            Progress.IncCurrentProgress;
          end;
        end;
        Progress.IncCurrentProgress(1);
        Progress.DisplayMessages := IntToStr(i) + ' files scanned for NTFS metadata';
      end;
    end;
  finally
    anEntryReader.free;
  end;
end;

procedure gdhbm(bmEntry: TEntry; bmFolder_str: string);
var
  bmGroup: TEntry;
begin
  StripIllegalChars(bmFolder_str);
  bmGroup := FindBookmarkByName(BM_FOLDER_SCRIPT_OUTPUT + BS + bmFolder_str);
  if bmGroup = nil then
    bmGroup := NewBookmark(FindDefaultBookmark(MY_BOOKMARKS_INDEX), BM_FOLDER_SCRIPT_OUTPUT + BS + bmFolder_str);
  if not IsItemInBookmark(bmGroup, bmEntry) then
    AddItemsToBookmark(bmGroup, DATASTORE_FILESYSTEM, bmEntry, bmFolder_str);
end;

procedure BookmarkResults(bmEntry: TEntry);
var
  bmPDFAuthor: string;
  bmPrintSpool_DocumentName: string;
  bmPrintSpoolShadowUsername: string;
  BookmarkFolderName: string;
  DriveType: string;
  dtstr: string;
  FileSignatureInfo: TFileTypeInformation;
  mkv_test_int: integer;
  mkv_test_str: string;
  ParentFileExt: string;
  SerialNo: string;
  Tag271Make_str: string;
  Tag272Model_str: string;
  UpperDrv: string;
  video_make_str: string;
  video_model_str: string;
  VolLabel: string;

begin
  FileSignatureInfo := bmEntry.FileDriverInfo;

  // Bookmark - GPS Photos
  if gbl_Bookmark_GPS then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, '(JPG|TIF|HEIF)', False) then
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
        BookmarkFolderName := BM_FOLDER_GPS_PHOTOS + BS + Tag271Make_str + HYPHEN + Tag272Model_str;
        gdhbm(bmEntry, BookmarkFolderName);
      end;
    end;
  end;

  // Bookmark - GPS Videos
  if gbl_Bookmark_GPS then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, VIDEO_REGEX, False) then
    begin
      if not(colVideoGPSLatitude.isNull(bmEntry)) and not(colVideoGPSLongitude.isNull(bmEntry)) then
      begin
        // Cater for GPS files that have GPS co-ordinates but do not have a Make or Model
        if trim(colVideoMake.AsString[bmEntry]) = '' then
          str_VideoMake := 'No Make'
        else
          str_VideoMake := colVideoMake.AsString[bmEntry];
        if trim(colVideoModel.AsString[bmEntry]) = '' then
          str_VideoModel := 'No Model'
        else
          str_VideoModel := colVideoModel.AsString[bmEntry];
        BookmarkFolderName := BM_FOLDER_GPS_VIDEOS + BS + str_VideoMake + HYPHEN + str_VideoModel;
        gdhbm(bmEntry, BookmarkFolderName);
      end;
    end;
  end;

  // Bookmark - Camera Male and Model
  if gbl_Bookmark_EXIF then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, '(JPG|TIF|HEIF)', False) then
    begin
      if not(colTag271Make.isNull(bmEntry)) and not(colTag272DeviceModel.isNull(bmEntry)) then
      begin
        BookmarkFolderName := BM_FOLDER_DIGITAL_CAMERAS + BS + colTag271Make.AsString[bmEntry] + HYPHEN + colTag272DeviceModel.AsString[bmEntry];
        gdhbm(bmEntry, BookmarkFolderName);
      end;
    end;
  end;

  // Bookmark - MS Author
  if gbl_Bookmark_MSAuthor then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, '(POWERPOINT|EXCEL|DOCX|XLSX|PPTX)', False) then
    begin
      if not(colMSAuthor.isNull(bmEntry)) then
        str_MSAuthorName := colMSAuthor.AsString[bmEntry]
      else
        str_MSAuthorName := 'No Author';
      BookmarkFolderName := BM_MS_AUTHORS + BS + str_MSAuthorName;
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - MS Printed
  if gbl_Bookmark_MSPrinted then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, '(POWERPOINT|EXCEL|DOCX|XLSX|PPTX)', False) then
    begin
      if not(colMSPrinted.isNull(bmEntry)) then
        dtstr := FormatDateTime('yyyy-mm-dd', colMSPrinted.AsDateTime[bmEntry])
      else
        dtstr := 'No Date Printed';
      BookmarkFolderName := BM_MS_PRINTED + BS + dtstr;
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - PDF
  if gbl_Bookmark_PDFAuthor then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'PDF') then
    begin
      if not(colPDFAuthor.isNull(bmEntry)) then
        bmPDFAuthor := colPDFAuthor.AsString[bmEntry]
      else
        bmPDFAuthor := 'No Author';
      BookmarkFolderName := BM_FOLDER_PDF_AUTHORS + BS + bmPDFAuthor;
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - PF
  if gbl_Bookmark_PREFETCH then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'PREFETCH') then
    begin
      BookmarkFolderName := '\Prefetch';
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - Print Spool
  if gbl_Bookmark_PRINTSPOOL then
  begin
    // SPL
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = SIG_PRINT_SPOOL) then // noslz
    begin
      if not(colPrintSpool_DocumentName.isNull(bmEntry)) then
        bmPrintSpool_DocumentName := colPrintSpool_DocumentName.AsString[bmEntry]
      else
        bmPrintSpool_DocumentName := 'Unknown';
      BookmarkFolderName := BM_FOLDER_PRINTSPOOL + BS + bmPrintSpool_DocumentName;
      gdhbm(bmEntry, BookmarkFolderName);
    end;

    // SHD
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then // noslz
    begin
      if not(colPrintSpoolShadow_Username.isNull(bmEntry)) then
        bmPrintSpoolShadowUsername := colPrintSpoolShadow_Username.AsString[bmEntry]
      else
        bmPrintSpoolShadowUsername := 'Unknown';
      BookmarkFolderName := BM_FOLDER_PRINTSPOOLSHADOW + BS + bmPrintSpoolShadowUsername;
      gdhbm(bmEntry, BookmarkFolderName);
      PrintSpoolComment := '';
    end;
  end;

  // Bookmark - LNK by Volume Label / Serial / Type
  if gbl_Bookmark_LNK then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if (UpperDrv = 'LNK') then
    begin
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

      BookmarkFolderName := BM_FOLDER_LNK + BS + VolLabel + HYPHEN + SerialNo + HYPHEN + DriveType;
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - MS Jump List
  if gbl_Bookmark_MSJUMPLIST then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    ParentFileExt := lowercase(bmEntry.parent.EntryNameExt);
    if (UpperDrv = 'LNK') and (ParentFileExt = '.automaticdestinations-ms') then // exclude the other LNK files
    begin
      BookmarkFolderName := BM_FOLDER_MSJUMPLIST + BS + bmEntry.parent.EntryName;
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - Video Make and Model
  if gbl_Bookmark_Video then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, VIDEO_REGEX, False) then
    begin
      if colVideoMake.isNull(bmEntry) or (colVideoMake.AsString[bmEntry] = '') then
        video_make_str := 'Unknown Make'
      else
        video_make_str := colVideoMake.AsString[bmEntry];

      if colVideoModel.isNull(bmEntry) or (colVideoModel.AsString[bmEntry] = '') then
        video_model_str := 'Unknown Model'
      else
        video_model_str := colVideoModel.AsString[bmEntry];

      BookmarkFolderName := BM_FOLDER_DIGITAL_CAMERAS_VIDEO + BS + video_make_str + HYPHEN + video_model_str;
      gdhbm(bmEntry, BookmarkFolderName);
    end;
  end;

  // Bookmark - MKV Tracks > 1
  if gbl_Bookmark_VideoMKVMuxing then
  begin
    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
    if RegexMatch(UpperDrv, 'MKV', False) then
    begin
      if (not colVideoMKVTracks.isNull(bmEntry)) or (not(colVideoMKVTracks.AsString[bmEntry] = '')) then
      begin
        mkv_test_str := colVideoMKVTracks.AsString[bmEntry];
        try
          mkv_test_int := StrToInt(mkv_test_str);
        except
          mkv_test_int := 0;
        end;
        if mkv_test_int > 1 then
        begin
          BookmarkFolderName := 'MKV Multiplex';
          gdhbm(bmEntry, BookmarkFolderName);
        end;
      end;
    end;
  end;
end;

procedure ProcessFiles(process_TList: TList);
var
  afEntry: TEntry;
  afEntryReader: TEntryReader;
  afPropertyTree: TPropertyParent;
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
  proceed_with_Video_extraction: boolean;
  proceed_with_ZIP_extraction: boolean;
  UpperDrv: string;
  Uppername: string;

begin
  if assigned(process_TList) and (process_TList.Count > 0) then
  begin
    Progress.Initialize(process_TList.Count, 'Scanning files for metadata' + RUNNING);
    Progress.DisplayMessages := 'Scanning for metadata';
    afEntryReader := TEntryReader.Create;
    try
      for p := 0 to process_TList.Count - 1 do
      begin
        if not Progress.isRunning then
          Exit;
        afEntry := TEntry(process_TList[p]);
        if TestEntryForProcess(afEntry) then
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
          proceed_with_Video_extraction := False;
          proceed_with_ZIP_extraction := False;

          // FILTER ALL RELEVANT FILE TYPES HERE =================================
          UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
          if (not afEntry.isDirectory) and (afEntry.LogicalSize > 0) and (FileSignatureInfo.FileDriverNumber > 0) and
            (((gbl_EXIF_Process) and (RegexMatch(UpperDrv, '(JPG|TIF|HEIF|PNG)', False))) or ((gbl_LNK_Process) and (UpperDrv = 'LNK')) or ((gbl_MS_Process) and (RegexMatch(UpperDrv, '(WORD|EXCEL|POWERPOINT)', False))) or
            ((gbl_MS_Process) and (RegexMatch(UpperDrv, '(DOCX|PPTX|XLSX)', False))) or ((gbl_MSJUMPLIST_Process) and (UpperDrv = 'LNK')) or ((gbl_PDF_Process) and (UpperDrv = 'PDF')) or ((gbl_PF_Process) and (UpperDrv = 'PREFETCH')) or
            ((gbl_PrintSpool_Process) and (UpperDrv = SIG_PRINT_SPOOL)) or ((gbl_PrintSpool_Process) and (UpperDrv = SIG_PRINT_SPOOL_SHADOW)) or
            ((gbl_RecycleBin_Process) and ((UpperDrv = SIG_WINDOWS_RECYCLE_BIN) or (RegexMatch(afEntry.EntryName, '^\$I', True)))) or ((gbl_Video_Process) and (RegexMatch(UpperDrv, VIDEO_REGEX, False))) or
            ((gbl_ZIP_Process) and (RegexMatch(UpperDrv, '(ZIP|TAR|RAR)', False)))) then

          begin
            // TEST COLUMNS FOR - EXIF (JPG) =====================================
            if gbl_EXIF_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if RegexMatch(UpperDrv, '(JPG|TIF|HEIF)', False) then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if RegexMatch(UpperDrv, '(JPG|TIF|HEIF)', False) then
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
              if (gbl_force_extract = False) and (proceed_with_EXIF_extraction = False) then
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

            // TEST COLUMNS FOR - LNK ============================================
            if gbl_LNK_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = 'LNK') then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if (UpperDrv = 'LNK') then
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
              if (gbl_force_extract = False) and (proceed_with_LNK_extraction = False) then
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

            // TEST COLUMNS FOR - MSJUMPLIST =====================================
            if gbl_MSJUMPLIST_Process then
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
                    UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                    if (UpperDrv = 'LNK') then
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
              if (gbl_force_extract = False) and (proceed_with_MSJUMPLIST_extraction = False) then
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
                      UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                      if (UpperDrv = 'LNK') then
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

            // TEST COLUMNS FOR - MS =============================================
            if gbl_MS_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = 'WORD') or (UpperDrv = 'POWERPOINT') or (UpperDrv = 'EXCEL') or (UpperDrv = 'DOCX') or (UpperDrv = 'PPTX') or (UpperDrv = 'XLSX') then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if RegexMatch(UpperDrv, '(WORD|POWERPOINT|EXCEL|DOCX)', False) then
                begin
                  if (colMSAuthor.isNull(afEntry)) and (colMSCreated.isNull(afEntry)) and (colMSLastSavedby.isNull(afEntry)) and (colMSModified.isNull(afEntry)) and (colMSTitle.isNull(afEntry)) then
                  begin
                    proceed_with_extraction := True;
                    proceed_with_MS_extraction := True;
                  end;
                end;
              end;

              // Count the metadata in the columns
              if (gbl_force_extract = False) and (proceed_with_MS_extraction = False) then
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

            // TEST COLUMNS FOR - PDF ============================================
            if gbl_PDF_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = 'PDF') then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if (UpperDrv = 'PDF') then
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
              if (gbl_force_extract = False) and (proceed_with_PDF_extraction = False) then
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

            // TEST COLUMNS FOR - PREFETCH =======================================
            if gbl_PF_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = 'PREFETCH') then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if (UpperDrv = 'PREFETCH') then
                begin
                  if (colPFFilename.isNull(afEntry)) and (colPFExecutionTime.isNull(afEntry)) and (colPFExecutionCount.isNull(afEntry)) then
                  begin
                    proceed_with_extraction := True;
                    proceed_with_PF_extraction := True;
                  end;
                end;
              end;
              // Count the metadata in the columns
              if (gbl_force_extract = False) and (proceed_with_PF_extraction = False) then
              begin
                if not(colPFFilename.isNull(afEntry)) then
                  countPFFilename := countPFFilename + 1;
                if not(colPFExecutionTime.isNull(afEntry)) then
                  countPFExecutionTime := countPFExecutionTime + 1;
                if not(colPFExecutionCount.isNull(afEntry)) then
                  countPFExecutionCount := countPFExecutionCount + 1;
              end;
            end;

            // TEST COLUMNS FOR - PRINT SPOOL ====================================
            if gbl_PrintSpool_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = SIG_PRINT_SPOOL) or (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if (UpperDrv = SIG_PRINT_SPOOL) or (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then
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
              if (gbl_force_extract = False) and (proceed_with_PrintSpool_extraction = False) then
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

            // TEST COLUMNS FOR - Recycle bin ====================================
            if gbl_RecycleBin_Process then
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
              if (gbl_force_extract = False) and (proceed_with_extraction = False) then
              begin
                if not(colRecycleBinOriginalFilename.isNull(afEntry)) then
                  countRecycleBinOriginalFilename := countRecycleBinOriginalFilename + 1;
                if not(colRecycleBinOriginalFileSize.isNull(afEntry)) then
                  countRecycleBinOriginalFileSize := countRecycleBinOriginalFileSize + 1;
                if not(colRecycleBinDeletedTimeUTC.isNull(afEntry)) then
                  countRecycleBinDeletedTimeUTC := countRecycleBinDeletedTimeUTC + 1;
              end;
            end;

            // TEST COLUMNS FOR - VIDEO ==========================================
            if gbl_Video_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if RegexMatch(UpperDrv, VIDEO_REGEX, False) then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if RegexMatch(UpperDrv, VIDEO_REGEX, False) then
                begin
                  // if (colJFifType.isNull(afEntry)) and (colEXIFType.isNull(afEntry)) and (colTag270Description.isNull(afEntry)) and (colTag271Make.isNull(afEntry)) and (colTag272DeviceModel.isNull(afEntry)) and
                  // (colTag274Orientation.isNull(afEntry)) and (colTag305Software.isNull(afEntry)) and (colTag306DateTime.isNull(afEntry)) and (colTag315Artist.isNull(afEntry)) and
                  // (colTag36867DateTimeOriginal.isNull(afEntry)) and (colTag33432Copyright.isNull(afEntry)) then
                  begin
                    proceed_with_extraction := True;
                    proceed_with_Video_extraction := True;
                  end;
                end;
              end;
              // Count the metadata in the columns
              if (gbl_force_extract = False) and (proceed_with_Video_extraction = False) then
              begin
                if not(colVideoCAME.isNull(afEntry)) then
                  countVideoCamera := countVideoCamera + 1;
                if not(colVideoCreated.isNull(afEntry)) then
                  countVideoCreated := countVideoCreated + 1;
                if not(colVideoCreationdate.isNull(afEntry)) then
                  countVideoCreationdate := countVideoCreationdate + 1;
                if not(colVideoDuration.isNull(afEntry)) then
                  countVideoDuration := countVideoDuration + 1;
                if not(colVideoFIRM.isNull(afEntry)) then
                  countVideoFirm := countVideoFirm + 1;
                if not(colVideoGPSAltitude.isNull(afEntry)) then
                  countVideoGPSAltitude := countVideoGPSAltitude + 1;
                if not(colVideoGPSLatitude.isNull(afEntry)) then
                  countVideoGPSLatitude := countVideoGPSLatitude + 1;
                if not(colVideoGPSLongitude.isNull(afEntry)) then
                  countVideoGPSLongitude := countVideoGPSLongitude + 1;
                if not(colVideoFIRM.isNull(afEntry)) then
                  countVideoFirm := countVideoFirm + 1;
                if not(colVideoLENS.isNull(afEntry)) then
                  countVideoLens := countVideoLens + 1;
                if not(colVideoMake.isNull(afEntry)) then
                  countVideoMake := countVideoMake + 1;
                if not(colVideoModel.isNull(afEntry)) then
                  countVideoModel := countVideoModel + 1;
                if not(colVideoModified.isNull(afEntry)) then
                  countVideoModified := countVideoModified + 1;
                if not(colVideoPlayDuration.isNull(afEntry)) then
                  countVideoPlayDuration := countVideoPlayDuration + 1;
                if not(colVideoSendDuration.isNull(afEntry)) then
                  countVideoSendDuration := countVideoSendDuration + 1;
                if not(colVideoSoftware.isNull(afEntry)) then
                  countVideoSoftware := countVideoSoftware + 1;
              end;
            end;

            // TEST COLUMNS FOR - ZIP ============================================
            if gbl_ZIP_Process then
            begin
              UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
              if (UpperDrv = 'ZIP') or (UpperDrv = 'ZIP (ENCRYPTED)') or (UpperDrv = 'RAR') or (UpperDrv = 'TAR') then
              begin
                DetermineFileType(afEntry);
                FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
                UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                if RegexMatch(UpperDrv, '(ZIP|RAR|TAR)', False) then
                begin
                  if (colZIPNumberItems.isNull(afEntry)) then
                  begin
                    proceed_with_extraction := True;
                    proceed_with_ZIP_extraction := True;
                  end;
                end;
              end;
              // Count the metadata in the columns
              if (gbl_force_extract = False) and (proceed_with_ZIP_extraction = False) then
              begin
                if not(colZIPNumberItems.isNull(afEntry)) then
                  countZIPNumberItems := countZIPNumberItems + 1;
              end;
            end;

            // ====================================================================
            // PROCEED WITH EXTRACTION
            // ====================================================================
            if gbl_force_extract or proceed_with_extraction then
            begin
              // Progress.Log(RPad('About to process:', rpad_value) + afEntry.EntryName + ' Bates#:' + (IntToStr(afEntry.ID)));
              DetermineFileType(afEntry);
              FileSignatureInfo := afEntry.DeterminedFileDriverInfo;
              afPropertyTree := nil;
              if ProcessMetadataProperties(afEntry, afPropertyTree, afEntryReader) and assigned(afPropertyTree) then
              begin
                if assigned(afPropertyTree) then
                  try
                    aRootEntry := afPropertyTree.RootProperty;
                    if assigned(aRootEntry) and assigned(aRootEntry.PropChildList) and (aRootEntry.PropChildList.Count > 0) then
                    begin
                      MessageLog('Proceed with process: ' + afEntry.FullPathName);
                      Uppername := UpperCase(afEntry.EntryName);
                      UpperDrv := UpperCase(FileSignatureInfo.ShortDisplayName);
                      if (FileSignatureInfo.FileDriverNumber > 0) then
                      begin
                        // ---EXIF--------------------------------------------------
                        if RegexMatch(UpperDrv, 'JPG|TIF|HEIF', False) then
                        begin
                          if gbl_force_extract or (gbl_EXIF_Process and proceed_with_EXIF_extraction) then
                          begin
                            ProcessJPG(afEntry, aRootEntry, UpperDrv);
                            ProcessJFif(afEntry, aRootEntry);
                          end
                        end
                        // ---OLE---------------------------------------------------
                        else if (UpperDrv = 'WORD') or (UpperDrv = 'POWERPOINT') or (UpperDrv = 'EXCEL') then
                        begin
                          if gbl_force_extract or (gbl_MS_Process and proceed_with_MS_extraction) then
                            ProcessMS(afEntry, aRootEntry);
                        end
                        // ---DOCX--------------------------------------------------
                        else if (UpperDrv = 'DOCX') or (UpperDrv = 'XLSX') or (UpperDrv = 'PPTX') then
                        begin
                          if gbl_force_extract or (gbl_MS_Process and proceed_with_MS_extraction) then
                            ProcessDOCX(afEntry, aRootEntry);
                        end
                        // ---PDF---------------------------------------------------
                        else if (UpperDrv = 'PDF') then
                        begin
                          if gbl_force_extract or (gbl_PDF_Process and proceed_with_PDF_extraction) then
                            ProcessPDF(afEntry, aRootEntry);
                        end
                        // ---LNK---------------------------------------------------
                        else if (UpperDrv = 'LNK') and (ParentFileExt <> '.automaticdestinations-ms') then // exclude the other LNK files
                        begin
                          if gbl_force_extract or (gbl_LNK_Process and proceed_with_LNK_extraction) then
                            ProcessLNK(afEntry, aRootEntry);
                        end
                        // ---MS JUMP LIST------------------------------------------
                        else if (UpperDrv = 'LNK') and (ParentFileExt = '.automaticdestinations-ms') then
                        begin
                          if gbl_force_extract or (gbl_MSJUMPLIST_Process and proceed_with_MSJUMPLIST_extraction) then
                            ProcessMSJUMPLIST(afEntry, aRootEntry);
                        end
                        // ---Prefetch----------------------------------------------
                        else if (UpperDrv = 'PREFETCH') then
                        begin
                          if gbl_force_extract or (gbl_PF_Process and proceed_with_PF_extraction) then
                            ProcessPF(afEntry, aRootEntry);
                        end
                        // ---PRINTSPOOL--------------------------------------------
                        else if (UpperDrv = SIG_PRINT_SPOOL) or (UpperDrv = SIG_PRINT_SPOOL_SHADOW) then
                        begin
                          if gbl_force_extract and (gbl_PrintSpool_Process and proceed_with_PrintSpool_extraction) then
                            ProcessPrintSpool(afEntry, aRootEntry);
                        end
                        // ---Recycle Bin-------------------------------------------
                        else if (UpperDrv = SIG_WINDOWS_RECYCLE_BIN) then
                        begin
                          if gbl_force_extract or (gbl_RecycleBin_Process and proceed_with_RecycleBin_extraction) then
                            ProcessRecycleBin(afEntry, aRootEntry);
                        end
                        // ---Video-----------------------------------------------
                        else if RegexMatch(UpperDrv, VIDEO_REGEX, False) then
                        begin
                          if gbl_force_extract or (gbl_Video_Process and proceed_with_Video_extraction) then
                            ProcessVideo(afEntry, aRootEntry);
                        end
                        // ---Zip---------------------------------------------------
                        else if (UpperDrv = 'ZIP') or (UpperDrv = 'Zip (Encrypted)') then
                        begin
                          if gbl_force_extract or (gbl_ZIP_Process and proceed_with_ZIP_extraction) then
                            ProcessZIP(afEntry, aRootEntry);
                        end;
                      end;
                    end
                    else
                    begin
                      Progress.Log(RPad('ERROR: Open File - Bates:' + SPACE + IntToStr(afEntry.ID), rpad_value) + afEntry.EntryName + SPACE + Format('(%1.2nmb)', [afEntry.LogicalSize / (1024 * 1024)]));
                    end;
                  finally
                    if assigned(afPropertyTree) then
                      try
                        afPropertyTree.free;
                        afPropertyTree := nil;
                      except
                        Sleep(500);
                        Progress.Log(RPad('ERROR: PropertyTree - Bates:' + SPACE + IntToStr(afEntry.ID), rpad_value) + afEntry.EntryName + SPACE + Format('(%1.2nmb)', [afEntry.LogicalSize / (1024 * 1024)]));
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
end;

procedure SignatureAnalysis(SigThis_TList: TList);
var
  gbl_Continue: boolean;
  sig_time_taken_int: uint64;
  signature_tick_count: uint64;
  TaskProgress: TPAC;
begin
  if not Progress.isRunning then
    Exit;
  signature_tick_count := GetTickCount64;
  if not assigned(SigThis_TList) then
  begin
    Progress.Log('Not assigned SigThis_TList.' + SPACE + TSWT);
    Exit;
  end;
  if assigned(SigThis_TList) and (SigThis_TList.Count > 0) then
  begin
    Progress.CurrentPosition := Progress.Max;
    Progress.DisplayMessageNow := ('Launching signature analysis' + SPACE + '(' + IntToStr(SigThis_TList.Count) + ' files)' + RUNNING);
    Progress.Log(StringOfChar('-', 80));
    Progress.Log(RPad('Launching signature analysis' + RUNNING, rpad_value) + IntToStr(SigThis_TList.Count));
    if Progress.isRunning then
    begin
      TaskProgress := NewProgress(True);
      RunTask('TCommandTask_FileTypeAnalysis', DATASTORE_FILESYSTEM, SigThis_TList, TaskProgress);
      while (TaskProgress.isRunning) and (Progress.isRunning) do
        Sleep(500); // Do not proceed until TCommandTask_FileTypeAnalysis is complete
      if not(Progress.isRunning) then
        TaskProgress.Cancel;
      gbl_Continue := (TaskProgress.CompleteState = pcsSuccess);
    end;
  end
  else
  begin
    MessageUser('No files found.' + #13#10 + #13#10 + TSWT);
    gbl_Continue := False;
  end;
  sig_time_taken_int := (GetTickCount64 - signature_tick_count);
  sig_time_taken_int := trunc(sig_time_taken_int / 1000);
  Progress.Log(RPad('Signature Analysis Time Taken:', rpad_value) + FormatDateTime('hh:nn:ss', sig_time_taken_int / SecsPerDay));
end;

// ==============================================================================
// Procedure: Main Proc
// ==============================================================================
procedure MainProc;
var
  anEntry: TEntry;
  aPropertyTree: TPropertyParent;
  EntryList: TDataStore;
  // Results_ScriptForm: TScriptForm;
  Working_TList: TList;
  k: integer;

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  aPropertyTree := nil;
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if EntryList = nil then
    Exit;

  anEntry := EntryList.First;
  if anEntry = nil then
  begin
    MessageUser('No files in the File System module. Script terminated.');
    EntryList.free;
    Exit;
  end;

  if not Progress.isRunning then
  begin
    Progress.Log('Progress is not running.' + SPACE + TSWT);
    EntryList.free;
    Exit;
  end;

  // For CLI
  gbl_DoChecked := False;
  gbl_DoAll := True;
  gbl_EXIF_Process := True;
  gbl_GPS_Process := True;
  gbl_LNK_Process := True;
  gbl_MSJUMPLIST_Process := True;
  gbl_MS_Process := True;
  gbl_NTFS_Process := True;
  gbl_PDF_Process := True;
  gbl_PF_Process := True;
  gbl_PrintSpool_Process := True;
  gbl_RecycleBin_Process := True;
  gbl_RunSignatureAnalysis := True;
  gbl_Video_Process := True;
  gbl_Bookmark_VideoMKVMuxing := True;
  gbl_ZIP_Process := True;

  Working_TList := TList.Create;
  try
    if gbl_DoAll then
    begin
      Working_TList := EntryList.GetEntireList;
      Progress.Log(RPad('Working with All items:', rpad_value) + IntToStr(Working_TList.Count));
    end
    else if gbl_DoChecked then
    begin
      Working_TList := EntryList.GetCheckedList;
      Progress.Log(RPad('Working with checked items:', rpad_value) + IntToStr(Working_TList.Count));
    end;

    Progress.Log(RPad('Force Extract:', rpad_value) + BoolToStr(gbl_force_extract, True));
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
    Progress.Log(RPad('EXIF:', rpad_value) + BoolToStr(gbl_EXIF_Process, True));
    Progress.Log(RPad('GPS:', rpad_value) + BoolToStr(gbl_GPS_Process, True));
    Progress.Log(RPad('LNK:', rpad_value) + BoolToStr(gbl_LNK_Process, True));
    Progress.Log(RPad('MS JumpList:', rpad_value) + BoolToStr(gbl_MSJUMPLIST_Process, True));
    Progress.Log(RPad('MS:', rpad_value) + BoolToStr(gbl_MS_Process, True));
    Progress.Log(RPad('NTFS:', rpad_value) + BoolToStr(gbl_NTFS_Process, True));
    Progress.Log(RPad('PDF:', rpad_value) + BoolToStr(gbl_PDF_Process, True));
    Progress.Log(RPad('Prefetch:', rpad_value) + BoolToStr(gbl_PF_Process, True));
    Progress.Log(RPad('Print Spool:', rpad_value) + BoolToStr(gbl_PrintSpool_Process, True));
    Progress.Log(RPad('Recycle Bin:', rpad_value) + BoolToStr(gbl_RecycleBin_Process, True));
    Progress.Log(RPad('Video:', rpad_value) + BoolToStr(gbl_Video_Process, True));
    Progress.Log(RPad('ZIP:', rpad_value) + BoolToStr(gbl_ZIP_Process, True));
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    if Working_TList.Count > 0 then
    begin
      gWorking_Count := 0;
      gWorking_Count := Working_TList.Count;
      CreateColumnNames;

      if gbl_RunSignatureAnalysis then
        SignatureAnalysis(Working_TList);

      if gbl_MSJUMPLIST_Process then
        ProcessJumpList(Working_TList);

      if gbl_NTFS_Process then
        process_NTFS(Working_TList);

      ProcessFiles(Working_TList);
    end;
  finally
    EntryList.free;
    Working_TList.free;
  end;

  // ============================================================================
  // REPORT THE RESULTS
  // ============================================================================
  Progress.Log('NTFS Metadata Extraction has finished.');
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Result_StringList := TStringList.Create;
  Result_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
  Result_StringList.Duplicates := dupIgnore;
  try
    Result_StringList.clear;

    if gbl_EXIF_Process then
    begin
      Result_StringList.Add(RPad(COL_EXIF270DESCRIPTION, rpad_value) + IntToStr(countTag270Description));
      Result_StringList.Add(RPad(COL_EXIF271MAKE, rpad_value) + IntToStr(countTag271Make));
      Result_StringList.Add(RPad(COL_EXIF272DEVICEMODEL, rpad_value) + IntToStr(countTag272DeviceModel));
      Result_StringList.Add(RPad(COL_EXIF274ORIENTATION, rpad_value) + IntToStr(countTag274Orientation));
      Result_StringList.Add(RPad(COL_EXIF282XRESOLUTION, rpad_value) + IntToStr(countTag282XResolution));
      Result_StringList.Add(RPad(COL_EXIF283YRESOLUTION, rpad_value) + IntToStr(countTag283YResolution));
      Result_StringList.Add(RPad(COL_EXIF305SOFTWARE, rpad_value) + IntToStr(countTag305Software));
      Result_StringList.Add(RPad(COL_EXIF306DATETIME, rpad_value) + IntToStr(countTag306DateTime));
      Result_StringList.Add(RPad(COL_EXIF315ARTIST, rpad_value) + IntToStr(countTag315Artist));
      Result_StringList.Add(RPad(COL_EXIF36867DATETIMEORIGINAL, rpad_value) + IntToStr(countTag36867DateTimeOriginal));
      Result_StringList.Add(RPad(COL_EXIF33432COPYRIGHT, rpad_value) + IntToStr(countTag33432Copyright));
    end;

    if gbl_GPS_Process then
    begin
      Result_StringList.Add(RPad(COL_GPSLATCALC, rpad_value) + IntToStr(countGPSPosLatitude));
      Result_StringList.Add(RPad(COL_GPSLONGCALC, rpad_value) + IntToStr(countGPSPosLongitude));
      Result_StringList.Add(RPad(COL_GPSINFO1LATREF, rpad_value) + IntToStr(countGPSInfo1LatitudeRef));
      Result_StringList.Add(RPad(COL_GPSINFO2LAT, rpad_value) + IntToStr(countGPSInfo2Latitude));
      Result_StringList.Add(RPad(COL_GPSINFO3LONGREF, rpad_value) + IntToStr(countGPSInfo3LongitudeRef));
      Result_StringList.Add(RPad(COL_GPSINFO4LONG, rpad_value) + IntToStr(countGPSInfo4Longitude));
      Result_StringList.Add(RPad(COL_GPSINFO6ALTITUDE, rpad_value) + IntToStr(countGPSInfo6Altitude));
      Result_StringList.Add(RPad(COL_GPSINFO7TIMESTAMP, rpad_value) + IntToStr(countGPSInfo7TimeStamp));
      Result_StringList.Add(RPad(COL_GPSINFO16DIRECTIONREF, rpad_value) + IntToStr(countGPSInfo16DirectionRef));
      Result_StringList.Add(RPad(COL_GPSINFO17DIRECTION, rpad_value) + IntToStr(countGPSInfo17Direction));
      Result_StringList.Add(RPad(COL_GPSINFO29DATESTAMP, rpad_value) + IntToStr(countGPSInfo29DateStamp));
    end;

    if gbl_LNK_Process then
    begin
      Result_StringList.Add(RPad(COL_LNKTARGETACCESSEDUTC, rpad_value) + IntToStr(countLNKFileAccessed));
      Result_StringList.Add(RPad(COL_LNKTARGETCREATEDUTC, rpad_value) + IntToStr(countLNKFileCreated));
      Result_StringList.Add(RPad(COL_LNKTARGETDRIVETYPE, rpad_value) + IntToStr(countLNKFileDriveType));
      Result_StringList.Add(RPad(COL_LNKTARGETLOCALBASEPATH, rpad_value) + IntToStr(countLNKFileLocalBasePath));
      Result_StringList.Add(RPad(COL_LNKGUIDMAC, rpad_value) + IntToStr(countLNKFileGUIDMAC));
      Result_StringList.Add(RPad(COL_LNKTARGETMODIFIEDUTC, rpad_value) + IntToStr(countLNKFileModified));
      Result_StringList.Add(RPad(COL_LNKTARGETSIZE, rpad_value) + IntToStr(countLNKFileSize));
      Result_StringList.Add(RPad(COL_LNKTARGETVOLUMELABEL, rpad_value) + IntToStr(countLNKFileVolumeLabel));
      Result_StringList.Add(RPad(COL_LNKTARGETVOLUMESERIAL, rpad_value) + IntToStr(countLNKFileDriveSerialNumber));
      Result_StringList.Add(RPad(COL_LNKTARGETNETNAME, rpad_value) + IntToStr(countLNKFileNetName));
      Result_StringList.Add(RPad(COL_LNKTARGETDEVICENAME, rpad_value) + IntToStr(countLNKFileDeviceName));
    end;

    if gbl_MSJUMPLIST_Process and not gbl_LNK_Process then
    begin
      Result_StringList.Add(RPad(COL_LNKTARGETACCESSEDUTC, rpad_value) + IntToStr(countMSJUMPLISTFileAccessed));
      Result_StringList.Add(RPad(COL_LNKTARGETCREATEDUTC, rpad_value) + IntToStr(countMSJUMPLISTFileCreated));
      Result_StringList.Add(RPad(COL_LNKTARGETDRIVETYPE, rpad_value) + IntToStr(countMSJUMPLISTFileDriveType));
      Result_StringList.Add(RPad(COL_LNKTARGETLOCALBASEPATH, rpad_value) + IntToStr(countMSJUMPLISTFileLocalBasePath));
      Result_StringList.Add(RPad(COL_LNKTARGETMODIFIEDUTC, rpad_value) + IntToStr(countMSJUMPLISTFileModified));
      Result_StringList.Add(RPad(COL_LNKTARGETSIZE, rpad_value) + IntToStr(countMSJUMPLISTFileSize));
      Result_StringList.Add(RPad(COL_LNKTARGETVOLUMELABEL, rpad_value) + IntToStr(countMSJUMPLISTFileVolumeLabel));
      Result_StringList.Add(RPad(COL_LNKTARGETVOLUMESERIAL, rpad_value) + IntToStr(countMSJUMPLISTFileDriveSerialNumber));
      Result_StringList.Add(RPad(COL_LNKTARGETNETNAME, rpad_value) + IntToStr(countMSJUMPLISTFileNetName));
      Result_StringList.Add(RPad(COL_LNKTARGETDEVICENAME, rpad_value) + IntToStr(countMSJUMPLISTFileDeviceName));
    end;

    if gbl_MS_Process then
    begin
      Result_StringList.Add(RPad(COL_MSAUTHOR, rpad_value) + IntToStr(countMSAuthor));
      Result_StringList.Add(RPad(COL_MSCREATED, rpad_value) + IntToStr(countMSCreated));
      Result_StringList.Add(RPad(COL_MSMODIFIED, rpad_value) + IntToStr(countMSModified));
      Result_StringList.Add(RPad(COL_MSPRINTED, rpad_value) + IntToStr(countMSPrinted));
      Result_StringList.Add(RPad(COL_MSLASTSAVEDBY, rpad_value) + IntToStr(countMSLastSavedby));
      Result_StringList.Add(RPad(COL_MSSUBJECT, rpad_value) + IntToStr(countMSSubject));
      Result_StringList.Add(RPad(COL_MSCOMPANY, rpad_value) + IntToStr(countMSCompany));
      Result_StringList.Add(RPad(COL_MSTITLE, rpad_value) + IntToStr(countMSTitle));
      Result_StringList.Add(RPad(COL_MSWORDCOUNT, rpad_value) + IntToStr(countMSWordCount));
      Result_StringList.Add(RPad(COL_MSREVISION, rpad_value) + IntToStr(countMSRevision));
      Result_StringList.Add(RPad(COL_MSEDITTIME, rpad_value) + IntToStr(countMSEditTime));
    end;

    if gbl_MS_Process then
    begin
      Result_StringList.Add(RPad(COL_MSPRINTED, rpad_value) + IntToStr(countMSPrinted));
    end;

    if gbl_NTFS_Process then
    begin
      Result_StringList.Add(RPad(COL_NTFS30CREATEDUTC, rpad_value) + IntToStr(countNTFS30FileNameCreated));
      Result_StringList.Add(RPad(COL_NTFS30RECORDMODIFIEDUTC, rpad_value) + IntToStr(countNTFS30FileNameRecordModified));
      Result_StringList.Add(RPad(COL_NTFS30MODIFIEDUTC, rpad_value) + IntToStr(countNTFS30FileNameModified));
      Result_StringList.Add(RPad(COL_NTFS30ACCESSEDUTC, rpad_value) + IntToStr(countNTFS30FileNameAccessed));
    end;

    if gbl_PDF_Process then
    begin
      Result_StringList.Add(RPad(COL_PDFAUTHOR, rpad_value) + IntToStr(countPDFAuthor));
      Result_StringList.Add(RPad(COL_PDFCREATIONDATE, rpad_value) + IntToStr(countPDFCreationDate));
      Result_StringList.Add(RPad(COL_PDFMODIFICATIONDATE, rpad_value) + IntToStr(countPDFModificationDate));
      Result_StringList.Add(RPad(COL_PDFOWNERPWD, rpad_value) + IntToStr(countPDFOwnerPassword));
      Result_StringList.Add(RPad(COL_PDFPRODUCER, rpad_value) + IntToStr(countPDFProducer));
      Result_StringList.Add(RPad(COL_PDFTITLE, rpad_value) + IntToStr(countPDFTitle));
      Result_StringList.Add(RPad(COL_PDFUSERPWD, rpad_value) + IntToStr(countPDFUserPassword));
    end;

    if gbl_PF_Process then
    begin
      Result_StringList.Add(RPad(COL_PREFETCHFILENAME, rpad_value) + IntToStr(countPFFilename));
      Result_StringList.Add(RPad(COL_PREFETCHEXECUTIONTIME, rpad_value) + IntToStr(countPFExecutionTime));
      Result_StringList.Add(RPad(COL_PREFETCHEXECUTIONCOUNT, rpad_value) + IntToStr(countPFExecutionCount));
    end;

    if gbl_PrintSpool_Process then
    begin
      Result_StringList.Add(RPad(COL_PRINTSPOOL_DOCUMENTNAME, rpad_value) + IntToStr(countPrintSpool_DocumentName));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_COMPUTERNAME, rpad_value) + IntToStr(countPrintSpoolShadow_ComputerName));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_DEVMODE, rpad_value) + IntToStr(countPrintSpoolShadow_DevMode));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_DOCUMENTNAME, rpad_value) + IntToStr(countPrintSpoolShadow_DocumentName));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_NOTIFICATIONNAME, rpad_value) + IntToStr(countPrintSpoolShadow_NotificationName));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_PCNAME, rpad_value) + IntToStr(countPrintSpoolShadow_PCName));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_PRINTERNAME, rpad_value) + IntToStr(countPrintSpoolShadow_PrinterName));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_SIGNATURE, rpad_value) + IntToStr(countPrintSpoolShadow_Signature));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_SUBMITTIME, rpad_value) + IntToStr(countPrintSpoolShadow_SubmitTime));
      Result_StringList.Add(RPad(COL_PRINTSPOOLSHADOW_USERNAME, rpad_value) + IntToStr(countPrintSpoolShadow_UserName));
    end;

    if gbl_Video_Process then
    begin
      Result_StringList.Add(RPad(COL_VIDEOCAMERA, rpad_value) + IntToStr(countVideoCamera));
      Result_StringList.Add(RPad(COL_VIDEOCREATED, rpad_value) + IntToStr(countVideoCreated));
      Result_StringList.Add(RPad(COL_VIDEOCREATIONDATE, rpad_value) + IntToStr(countVideoCreationdate));
      Result_StringList.Add(RPad(COL_VIDEODURATION, rpad_value) + IntToStr(countVideoDuration));
      Result_StringList.Add(RPad(COL_VIDEOFIRM, rpad_value) + IntToStr(countVideoFirm));
      Result_StringList.Add(RPad(COL_VIDEOGPSALTITUDE, rpad_value) + IntToStr(countVideoGPSAltitude));
      Result_StringList.Add(RPad(COL_VIDEOGPSLATITUDE, rpad_value) + IntToStr(countVideoGPSLatitude));
      Result_StringList.Add(RPad(COL_VIDEOGPSLONGITUDE, rpad_value) + IntToStr(countVideoGPSLongitude));
      Result_StringList.Add(RPad(COL_VIDEOLENS, rpad_value) + IntToStr(countVideoLens));
      Result_StringList.Add(RPad(COL_VIDEOMAKE, rpad_value) + IntToStr(countVideoMake));
      Result_StringList.Add(RPad(COL_VIDEOMODEL, rpad_value) + IntToStr(countVideoModel));
      Result_StringList.Add(RPad(COL_VIDEOMODIFIED, rpad_value) + IntToStr(countVideoModified));
      Result_StringList.Add(RPad(COL_VIDEOMKVDATEUTC, rpad_value) + IntToStr(countVideoMKVDateUTC));
      Result_StringList.Add(RPad(COL_VIDEOMKVMUXINGAPP, rpad_value) + IntToStr(countVideoMKVMuxingApp));
      Result_StringList.Add(RPad(COL_VIDEOMKVTRACKS, rpad_value) + IntToStr(countVideoMKVTracks));
      Result_StringList.Add(RPad(COL_VIDEOMKVWRITINGAPP, rpad_value) + IntToStr(countVideoMKVWritingApp));
      Result_StringList.Add(RPad(COL_VIDEOPLAYDURATION, rpad_value) + IntToStr(countVideoPlayDuration));
      Result_StringList.Add(RPad(COL_VIDEOSOFTWARE, rpad_value) + IntToStr(countVideoSoftware));
    end;

    if gbl_RecycleBin_Process then
    begin
      Result_StringList.Add(RPad(COL_RECYCLEBINORIGINALFILENAME, rpad_value) + IntToStr(countRecycleBinOriginalFilename));
      Result_StringList.Add(RPad(COL_RECYCLEBINORIGINALFILESIZE, rpad_value) + IntToStr(countRecycleBinOriginalFileSize));
      Result_StringList.Add(RPad(COL_RECYCLEBINDELETEDTIMEUTC, rpad_value) + IntToStr(countRecycleBinDeletedTimeUTC));
    end;

    if gbl_ZIP_Process then
    begin
      Result_StringList.Add(RPad(COL_ZIPNUMBERITEMS, rpad_value) + IntToStr(countZIPNumberItems));
    end;

    for k := 0 to Result_StringList.Count - 1 do
      Progress.Log(Result_StringList[k]); // Print line by line for date time
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    if assigned(gErrorLog_StringList) and (gErrorLog_StringList.Count > 0) then
    begin
      Progress.Log(gErrorLog_StringList.text);
      Progress.Log(StringOfChar('-', CHAR_LENGTH));
    end;

    Progress.Log(RPad('Encrypted Files:', rpad_value) + IntToStr(gencrypted_file_count));
    Progress.Log(RPad('Zero Size Files:', rpad_value) + IntToStr(gzero_size_count));
    Progress.Log(RPad('Is Directory:', rpad_value) + IntToStr(gdirectory_count));
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    gtotal_time_int := (GetTickCount64 - gstarting_tick_count);
    gtotal_time_int := trunc(gtotal_time_int / 1000);
    Progress.Log(RPad('Total Time:', rpad_value) + FormatDateTime('hh:nn:ss', gtotal_time_int / SecsPerDay));
    Progress.Log(StringOfChar('-', 80));

    gbl_Show_Columns_Tab := True;
    // Results_ScriptForm := TScriptForm.Create;
    // try
    // Results_ScriptForm.ShowModal;
    // finally
    // Results_ScriptForm.free;
    // end;
  finally
    Result_StringList.free
  end;

  if gbl_force_extract then
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
  NodePropName_str: string;
begin
  Result := False;
  stringprop := '';
  if not(ADataStoreField.isNull(AEntry)) then
    stringprop := ADataStoreField.AsString[AEntry];
  if (stringprop = '') or (gbl_force_extract = True) then
  begin
    aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(aPropertyNode) then
    begin
      NodePropName_str := aPropertyNode.PropName;
      if ((NodePropName_str = 'Created') or (NodePropName_str = 'Modified')) and (aPropertyNode.PropDataType = 'UString') then // noslz
      begin
        ErrorLog(gErrorLog_StringList, RPad('ERROR' + HYPHEN + 'PropDataType', rpad_value) + AEntry.EntryName + SPACE + Format('(%1.2nmb)', [AEntry.LogicalSize / (1024 * 1024)]) + SPACE + 'Bates#:' + SPACE + IntToStr(AEntry.ID));
        Exit;
      end;
      aTempStr := trim(aPropertyNode.PropDisplayValue);
      if aTempStr <> '' then
      begin
        ADataStoreField.AsString[AEntry] := aTempStr;
        if gbl_Bookmark_PRINTSPOOL then
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
    if gbl_Bookmark_PRINTSPOOL then
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
  anInt64: int64;
begin
  if (ADataStoreField.isNull(AEntry)) or (gbl_force_extract = True) then
  begin
    propnode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(propnode) then
    begin
      aDateTime := 0.0;
      if propnode.PropDataType = 'Date' then // noslz
        aDateTime := propnode.PropValue
      else if propnode.PropDataType = 'Int64' then // noslz
      begin
        anInt64 := propnode.PropValue;
        aDateTime := FileTimeToDateTime(anInt64);
      end;
      if propnode.PropValue <> 0 then
      begin
        ADataStoreField.AsDateTime[AEntry] := aDateTime;
        if gbl_Bookmark_PRINTSPOOL then
          try
            PrintSpoolComment := PrintSpoolComment + #13#10 + RPad(ADataStoreField.FieldName + ': ', rpad_value) + DateTimeToStr(aDateTime);
          except
            ErrorLog(gErrorLog_StringList, 'ERROR: DateTimeToStr');
          end;
        Result := True;
        ACounter := ACounter + 1;
      end;
    end;
  end
  else
    ACounter := (ACounter + 1);
  if gbl_Bookmark_PRINTSPOOL then
    try
      PrintSpoolComment := PrintSpoolComment + #13#10 + RPad(ADataStoreField.FieldName + ': ', rpad_value) + ADataStoreField.AsString[AEntry];
    except
      ErrorLog(gErrorLog_StringList, 'ERROR: DateTimeToStr');
    end;
end;

// FUNCTION TO PROCESS an Int64 Column =========================================
function AddInt64Column(AParentNode: TPropertyNode; AEntry: TEntry; ADataStoreField: TDataStoreField; ANodeByName: string; var ACounter: integer): boolean;
var
  propnode: TPropertyNode;
  aInt64: int64;
begin
  if (ADataStoreField.isNull(AEntry)) or (gbl_force_extract = True) then
  begin
    propnode := TPropertyNode(AParentNode.GetFirstNodeByName(ANodeByName));
    if assigned(propnode) then
    begin
      aInt64 := propnode.PropValue;
      ADataStoreField.AsInt64[AEntry] := aInt64;
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
  if (ADataStoreField.isNull(AEntry)) or (gbl_force_extract = True) then
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
  if (ADataStoreField.isNull(AEntry)) or (gbl_force_extract = True) then
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
function StripIllegalChars(aString: string): string;
var
  x: integer;
const
  IllegalCharSet: set of char = ['|', '<', '>', '^', '+', '=', '?', '/', '[', ']', '"', ';', ',', '*', ':'];
begin
  for x := 1 to Length(aString) do
    if aString[x] in IllegalCharSet then
      aString[x] := '_';
  Result := aString;
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
  for i := 0 to anExpandedFileList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    aFile := TEntry(anExpandedFileList.items[i]);
    if TestEntryForProcess(aFile) then
    begin
      filestr := lowercase(aFile.EntryName);
      if (filestr = 'core.xml') or (filestr = 'docprops/core.xml') then // noslz
      begin
        if aReader.Opendata(aFile) then
        begin
          aPropertyTree := nil;
          if ProcessMetadataProperties(aFile, aPropertyTree, aReader) then
            try
              if assigned(aPropertyTree) and assigned(aPropertyTree.RootProperty) then
                // DOCX DATES ======================================================
                // Created UTC
                if (colMSCreated.isNull(AEntry)) or (gbl_force_extract = True) then
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
              if (colMSModified.isNull(AEntry)) or (gbl_force_extract = True) then
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
              if (colMSPrinted.isNull(AEntry)) or (gbl_force_extract = True) then
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

              // Creator (Author in OLE)
              if (colMSAuthor.isNull(AEntry)) or (gbl_force_extract = True) then
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
              if (colMSLastSavedby.isNull(AEntry)) or (gbl_force_extract = True) then
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
              if (colMSTitle.isNull(AEntry)) or (gbl_force_extract = True) then
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
              if (colMSSubject.isNull(AEntry)) or (gbl_force_extract = True) then
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
              if (colMSRevision.isNull(AEntry)) or (gbl_force_extract = True) then
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

            finally
              if assigned(aPropertyTree) then
                try
                  FreeAndNil(aPropertyTree);
                except
                  Progress.Log(ATRY_EXCEPT_STR + '!!! Exception 3A. !!! - FreeAndNil of aPropertyTree');
                end;
            end;
        end;
      end;
    end;

    // Second file
    if aFile.EntryName = 'app.xml' then // was docProps/app.xml
    begin
      if aReader.Opendata(aFile) then
      begin
        aPropertyTree := nil;
        if ProcessMetadataProperties(aFile, aPropertyTree, aReader) then
          try
            if assigned(aPropertyTree) and assigned(aPropertyTree.RootProperty) then
            begin
              // Word Count (Word Count in OLE)
              if (colMSWordCount.isNull(AEntry)) or (gbl_force_extract = True) then
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
            end;

            // Total Time (OLE Edit Time)
            if (colMSEditTime.isNull(AEntry)) or (gbl_force_extract = True) then
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
            if (colMSCompany.isNull(AEntry)) or (gbl_force_extract = True) then
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

          finally
            if assigned(aPropertyTree) then
              try
                FreeAndNil(aPropertyTree);
              except
                Progress.Log(ATRY_EXCEPT_STR + '!!! Exception 4. !!! - FreeAndNil of aPropertyTree');
              end;
          end;
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
    AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_TIFF));
  end
  else if (AShortDisplayName = 'HEIF') then
  begin
    // Progress.Log('Processed as HEIF');
    AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_HEIF));
  end
  else
  begin
    // Progress.Log('Processed as JPEG');
    AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(ROOT_ENTRY_EXIF));
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
    if (colGPSPosLatitude.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo2GPSLatitude);
      aPropertyNode1 := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo1GPSLatitudeRef);
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
    if (colGPSPosLongitude.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo4GPSLongitude);
      aPropertyNode1 := aRootEntry.GetFirstNodeByName(NODEBYNAME_GPSInfo3GPSLongitudeRef);
      if aPropertyNode <> nil then
      begin
        tempvariant := aPropertyNode.PropValue;
        if VarIsArray(tempvariant) then
        begin
          calcVal := VarArrayGet(tempvariant, [0]) + VarArrayGet(tempvariant, [1]) / 60 + VarArrayGet(tempvariant, [2]) / 3600;
          if (aPropertyNode1 <> nil) then
          begin
            if aPropertyNode1.PropValue = 'W' then
              calcVal := -calcVal;
          end;
          colGPSPosLongitude.AsDouble(AEntry) := calcVal;
        end
        else
          colGPSPosLongitude.AsFloat(AEntry) := tempvariant;
        countGPSPosLongitude := countGPSPosLongitude + 1;
      end;
    end
    else
      countGPSPosLongitude := (countGPSPosLongitude + 1);

    // GPS Info2 Latitude Raw Data ---------------------------------------------
    if (colGPSInfo2Latitude.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo2GPSLatitude));
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
    if (colGPSInfo4Longitude.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo4GPSLongitude));
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
    if (colGPSInfo6Altitude.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo6GPSAltitude));
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
    if (colGPSInfo7TimeStamp.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo7GPSTimeStamp));
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
    if (colGPSInfo17Direction.isNull(AEntry)) or (gbl_force_extract = True) then
    begin
      aPropertyNode := TPropertyNode(AParentNode.GetFirstNodeByName(NODEBYNAME_GPSInfo17GPSImgDirection));
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
  aLinkInfoNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKLinkInfo));
  if assigned(aLinkInfoNode) then
  begin
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileLocalBasePath, NODEBYNAME_LNKLocalBasePath, countLNKFileLocalBasePath);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveSerialNumber, NODEBYNAME_LNKDriveSerialNumber, countLNKFileDriveSerialNumber);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveType, NODEBYNAME_LNKDriveType, countLNKFileDriveType);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileVolumeLabel, NODEBYNAME_LNKVolumeLabel, countLNKFileVolumeLabel);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileNetName, NODEBYNAME_LNKNetName, countLNKFileNetName);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDeviceName, NODEBYNAME_LNKDeviceName, countLNKFileDeviceName);
  end;

  aLinkMSNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKFileMS));
  if assigned(aLinkMSNode) then
  begin
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileCreated, NODEBYNAME_LNKCreationTimeUTC, countLNKFileCreated);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileModified, NODEBYNAME_LNKModifiedTimeUTC, countLNKFileModified);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileAccessed, NODEBYNAME_LNKAccessTimeUTC, countLNKFileAccessed);
    AddInt64Column(aLinkMSNode, AEntry, colLNKFileSize, NODEBYNAME_LNKFileSize, countLNKFileSize);
  end;

  aLinkTrackerPropertyBlock := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKTrackerProptertyBlock));
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
  aLinkInfoNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKLinkInfo));
  if assigned(aLinkInfoNode) then
  begin
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileLocalBasePath, NODEBYNAME_LNKLocalBasePath, countMSJUMPLISTFileLocalBasePath);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveSerialNumber, NODEBYNAME_LNKDriveSerialNumber, countMSJUMPLISTFileDriveSerialNumber);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDriveType, NODEBYNAME_LNKDriveType, countMSJUMPLISTFileDriveType);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileVolumeLabel, NODEBYNAME_LNKVolumeLabel, countMSJUMPLISTFileVolumeLabel);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileNetName, NODEBYNAME_LNKNetName, countMSJUMPLISTFileNetName);
    AddStringColumn(aLinkInfoNode, AEntry, colLNKFileDeviceName, NODEBYNAME_LNKDeviceName, countMSJUMPLISTFileDeviceName);
  end;

  aLinkMSNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_LNKFileMS));
  if assigned(aLinkMSNode) then
  begin
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileCreated, NODEBYNAME_LNKCreationTimeUTC, countMSJUMPLISTFileCreated);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileModified, NODEBYNAME_LNKModifiedTimeUTC, countMSJUMPLISTFileModified);
    AddFileTimeColumn(aLinkMSNode, AEntry, colLNKFileAccessed, NODEBYNAME_LNKAccessTimeUTC, countMSJUMPLISTFileAccessed);
    AddInt64Column(aLinkMSNode, AEntry, colLNKFileSize, NODEBYNAME_LNKFileSize, countMSJUMPLISTFileSize);
  end;
end;

// ***PROCESS MS****************************************************************
procedure ProcessMS(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  AParentNode: TPropertyNode;
begin
  AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_MSSummary));
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
  AParentNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_MSDocumentSummary));
  if assigned(AParentNode) then
  begin
    AddStringColumn(AParentNode, AEntry, colMSCompany, NODEBYNAME_MSCompany, countMSCompany);
  end;
end;

// ConvertW3CDTF Dates for DOCX
function ConvertW3CDTFStringToDateTime(aString: string): TDateTime;
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
  if Length(aString) < 8 then
    Exit;
  tpos := pos('T', aString);
  didTime := False;
  didDate := False;
  didDate := TryStrToInt(copy(aString, 1, 4), year) and TryStrToInt(copy(aString, 6, 2), month) and TryStrToInt(copy(aString, 9, 2), day);
  if Length(aString) >= 15 then
    didTime := TryStrToInt(copy(aString, 12, 2), hour) and TryStrToInt(copy(aString, 15, 2), minute) and TryStrToInt(copy(aString, 18, 2), second);
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

function PerlMatch(AMatchPattern: string; AMatchString: string): string;
var
  Re: TDIPerlRegEx;
begin
  Result := '';
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess, coUnGreedy];
  Re.SetSubjectStr(AMatchString);
  Re.MatchPattern := AMatchPattern;
  if Re.Match(0) >= 0 then
    Result := Re.matchedstr;
  FreeAndNil(Re);
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
    AddStringColumn(aRootEntry, AEntry, colPrintSpool_DocumentName, NODEBYNAME_PrintSpool_DocumentName, countPrintSpool_DocumentName);
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
    AddInt64Column(aRootEntry, AEntry, colRecycleBinOriginalFileSize, NODEBYNAME_RecycleBinFileSize, countRecycleBinOriginalFileSize);
    AddFileTimeColumn(aRootEntry, AEntry, colRecycleBinDeletedTimeUTC, NODEBYNAME_RecycleBinDeletedTimeUTC, countRecycleBinDeletedTimeUTC);
  end;
end;

// *** PROCESS VIDEO ***********************************************************
procedure ProcessVideo(AEntry: TEntry; aRootEntry: TPropertyNode);
var
  num_mkv_tracks_int: integer;
  aPropertyNode: TPropertyNode;
begin
  if assigned(aRootEntry) and ((aRootEntry.PropName = ROOT_ENTRY_MOV) or (aRootEntry.PropName = ROOT_ENTRY_AVI) or (aRootEntry.PropName = ROOT_ENTRY_WMV) or (aRootEntry.PropName = ROOT_ENTRY_MKV)) then
  begin
    AddFileTimeColumn(aRootEntry, AEntry, colVideoCreated, NODEBYNAME_VIDEO_CREATED, countVideoCreated);
    AddFileTimeColumn(aRootEntry, AEntry, colVideoModified, NODEBYNAME_VIDEO_MODIFIED, countVideoModified);
    AddFloatColumn(aRootEntry, AEntry, colVideoDuration, NODEBYNAME_VIDEO_DURATION, countVideoDuration);
    AddFloatColumn(aRootEntry, AEntry, colVideoPlayDuration, NODEBYNAME_VIDEO_PLAYDURATION, countVideoPlayDuration);
    AddFloatColumn(aRootEntry, AEntry, colVideoSendDuration, NODEBYNAME_VIDEO_SENDDURATION, countVideoSendDuration);
    AddStringColumn(aRootEntry, AEntry, colVideoCAME, NODEBYNAME_VIDEO_CAME, countVideoCamera);
    AddStringColumn(aRootEntry, AEntry, colVideoCreationdate, NODEBYNAME_VIDEO_CREATIONDATE, countVideoCreationdate);
    AddStringColumn(aRootEntry, AEntry, colVideoFIRM, NODEBYNAME_VIDEO_FIRM, countVideoFirm);
    AddStringColumn(aRootEntry, AEntry, colVideoGPSAltitude, NODEBYNAME_VIDEO_GPSALTITUDE, countVideoGPSAltitude);
    AddStringColumn(aRootEntry, AEntry, colVideoGPSLatitude, NODEBYNAME_VIDEO_GPSLATITUDE, countVideoGPSLatitude);
    AddStringColumn(aRootEntry, AEntry, colVideoGPSLongitude, NODEBYNAME_VIDEO_GPSLONGITUDE, countVideoGPSLongitude);
    AddStringColumn(aRootEntry, AEntry, colVideoLENS, NODEBYNAME_VIDEO_LENS, countVideoLens);
    AddStringColumn(aRootEntry, AEntry, colVideoMake, NODEBYNAME_VIDEO_MAKE, countVideoMake);
    AddStringColumn(aRootEntry, AEntry, colVideoMKVDateUTC, NODEBYNAME_VIDEO_MKVDATEUTC, countVideoMKVDateUTC);
    AddStringColumn(aRootEntry, AEntry, colVideoMKVMuxingApp, NODEBYNAME_VIDEO_MKVMUXINGAPP, countVideoMKVMuxingApp);
    AddStringColumn(aRootEntry, AEntry, colVideoMKVWritingApp, NODEBYNAME_VIDEO_MKVWRITINGAPP, countVideoMKVWritingApp);
    AddStringColumn(aRootEntry, AEntry, colVideoModel, NODEBYNAME_VIDEO_MODEL, countVideoModel);
    AddStringColumn(aRootEntry, AEntry, colVideoSoftware, NODEBYNAME_VIDEO_SOFTWARE, countVideoSoftware);

    if (aRootEntry.PropName = ROOT_ENTRY_MKV) then // noslz
    begin
      aPropertyNode := TPropertyNode(aRootEntry.GetFirstNodeByName(NODEBYNAME_VIDEO_MKVFILEHEADER));
      num_mkv_tracks_int := MKV_NodeFrog(aPropertyNode, 0);
      colVideoMKVTracks.AsInteger[AEntry] := num_mkv_tracks_int;
      countVideoMKVTracks := countVideoMKVTracks + 1;
    end;

  end;
end;

// *** PROCESS ZIP *************************************************************
procedure ProcessZIP(AEntry: TEntry; aRootEntry: TPropertyNode);
begin
  if assigned(aRootEntry) and (aRootEntry.PropName = ROOT_ENTRY_ZIP) then
    AddInt32Column(aRootEntry, AEntry, colZIPNumberItems, NODEBYNAME_ZIPNumberItems, countZIPNumberItems);
end;

// ------------------------------------------------------------------------------
// procedure: Process Columns
// ------------------------------------------------------------------------------
// procedure ProcessCol(Action_bl: boolean; AColName: string);
// var
// Field : TDataStoreField;
// TheDataStore: TDataStore;
// TheModule: TGDModule;
// TheViewer: TViewerBase;
// begin
// TheDataStore := GetDataStore(DATASTORE_FILESYSTEM);
// TheModule := ModuleManager.ModuleByName(MODULENAME_FILESYSTEM);
// TheViewer := TheModule.ViewerByName('vwFSTable');
// if (TheDataStore <> nil) and (TheModule <> nil) and (TheViewer <> nil) then
// begin
// if (TheViewer is TColumnViewer) then
// begin
// Field := TheDataStore.DataFields.FieldByName[AColName];
// if Field = nil then
// begin
// Progress.Log ('The column name "' + AColName + '" does not exist.');
// TheDataStore.free;
// Exit;
// end
// else
// begin
// if Action_bl then
// begin
// TColumnViewer(TheViewer).HideColumn(Field); // Need to hide before show so that column headings are not mixed up
// TColumnViewer(TheViewer).ShowColumn(Field, 3);
// Progress.Log(RPad('Show Column:', rpad_value) + AColName);
// end;
// if not Action_bl then
// begin
// TColumnViewer(TheViewer).HideColumn(Field);
// Progress.Log(RPad('Hide Column:', rpad_value) + AColName);
// end;
// end;
// end;
// end;
// TheDataStore.free;
// end;

/// / *** ADD COLUMN **************************************************************
// procedure AddColumn(ColumnName: TDataStoreField; ColumnPosition: integer);
// var
// Module: TGDModule;
// Viewer: TViewerBase;
// begin
// if assigned(ColumnName) then
// begin
// Module := ModuleManager.ModuleByName(MODULENAME_FILESYSTEM);
// if Module <> nil then
// begin
// Viewer := Module.ViewerByName('vwFSTable');
// if (Viewer <> nil) and (Viewer is TColumnViewer) then
// begin
// TColumnViewer(Viewer).HideColumn(ColumnName);
// TColumnViewer(Viewer).ShowColumn(ColumnName, ColumnPosition);
// end;
// end;
// end;
// end;

/// / *** HIDE COLUMN *************************************************************
// procedure HideColumn(ColumnName: TDataStoreField);
// var
// Module: TGDModule;
// Viewer: TViewerBase;
// begin
// if assigned(ColumnName) then
// begin
// Module := ModuleManager.ModuleByName(MODULENAME_FILESYSTEM);
// if Module <> nil then
// begin
// Viewer := Module.ViewerByName('vwFSTable');
// if (Viewer <> nil) and (Viewer is TColumnViewer) then
// TColumnViewer(Viewer).HideColumn(ColumnName);
// end;
// end;
// end;

// ==============================================================================
// The start of the script
// ==============================================================================
// var
// MyScriptForm: TScriptForm;
begin
  gstarting_tick_count := GetTickCount64;
  rpad_value := 40;
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.Log(SCRIPT_NAME + ' started' + RUNNING);
  gErrorLog_StringList := TStringList.Create;
  try
    if (CmdLine.Params.Count = 0) then
      Progress.Log(RPad('Parameters received:', rpad_value) + '0')
    else
      Progress.Log(RPad('Parameters received:', rpad_value) + CmdLine.Params.text);
    Progress.DisplayMessageNow := 'Displaying GUI' + RUNNING;

    gbl_Show_About_Tab := True;
    gbl_Show_Columns_Tab := False;
    gbl_Show_Extract_Tab := True;
    gbl_Show_Results_Tab := False;

    gbl_Bookmark_EXIF := False;
    gbl_Bookmark_GPS := False;
    gbl_Bookmark_MSAuthor := False;
    gbl_Bookmark_MSJUMPLIST := False;
    gbl_Bookmark_MSPrinted := False;
    gbl_Bookmark_PDFAuthor := False;
    gbl_Bookmark_PREFETCH := False;
    gbl_Bookmark_PRINTSPOOL := False;
    gbl_Bookmark_RecycleBinPath := False;
    gbl_Bookmark_Video := False;

    gbl_EXIF_Process := False;
    gbl_GPS_Process := False;
    gbl_LNK_Process := False;
    gbl_MS_Process := False;
    gbl_MSJUMPLIST_Process := False;
    gbl_NTFS_Process := False;
    gbl_PDF_Process := False;
    gbl_PF_Process := False;
    gbl_PrintSpool_Process := False;
    gbl_RecycleBin_Process := False;
    gbl_Video_Process := False;
    gbl_ZIP_Process := False;

    gbl_ShowGUI := CmdLine.Params.Indexof('NOSHOW') = -1;

    if (gbl_ShowGUI = False) then
    begin
      gbl_EXIF_Process := True;
      gbl_GPS_Process := True;
      gbl_LNK_Process := True;
      gbl_MS_Process := True;
      gbl_MSJUMPLIST_Process := True;
      gbl_NTFS_Process := True;
      gbl_PDF_Process := True;
      gbl_PF_Process := True;
      gbl_PrintSpool_Process := True;
      gbl_RecycleBin_Process := True;
      gbl_Video_Process := True;
      gbl_ZIP_Process := True;

      gbl_Bookmark_EXIF := CmdLine.Params.Indexof('BM-CAMERAS') >= 0;
      gbl_Bookmark_GPS := CmdLine.Params.Indexof('BM-GPS') >= 0;
      gbl_Bookmark_MSPrinted := CmdLine.Params.Indexof('BM-MS-PRINTED') >= 0;
      gbl_Bookmark_MSAuthor := CmdLine.Params.Indexof('BM-MS') >= 0;
      gbl_Bookmark_PDFAuthor := CmdLine.Params.Indexof('BM-PDF') >= 0;
      gbl_Bookmark_PREFETCH := CmdLine.Params.Indexof('BM-PREFETCH') >= 0;
      gbl_Bookmark_PRINTSPOOL := CmdLine.Params.Indexof('BM-PRINTSPOOL') >= 0;
      gbl_Bookmark_LNK := CmdLine.Params.Indexof('BM-LNK') >= 0;
      gbl_Bookmark_MSJUMPLIST := CmdLine.Params.Indexof('BM-MSJUMPLIST') >= 0;
      gbl_Bookmark_RecycleBinPath := CmdLine.Params.Indexof('BM-RECYCLEBINPATH') >= 0;
      gbl_Bookmark_Video := CmdLine.Params.Indexof('BM-VIDEO') >= 0;

      str_MessBox_Message := 'Extract All Metadata To Columns';

      str_MessBox_Title := STR_EXTRACT_METADATA;
      gbl_MessBox_ShowForce := True;
      Progress_Display_Title := STR_EXTRACT_METADATA;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-CAMERAS') >= 0) then
    begin
      gbl_EXIF_Process := True;
      gbl_GPS_Process := True;
      gbl_Bookmark_EXIF := CmdLine.Params.Indexof('BM-CAMERAS') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-GPS') >= 0) then
    begin
      gbl_EXIF_Process := True;
      gbl_GPS_Process := True;
      gbl_Bookmark_GPS := CmdLine.Params.Indexof('BM-GPS') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-MS-PRINTED') >= 0) then
    begin
      gbl_MS_Process := True;
      gbl_Bookmark_MSPrinted := CmdLine.Params.Indexof('BM-MS-PRINTED') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-MS') >= 0) then
    begin
      gbl_MS_Process := True;
      gbl_Bookmark_MSAuthor := CmdLine.Params.Indexof('BM-MS') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-NTFS') >= 0) then
      gbl_NTFS_Process := True;

    if (CmdLine.Params.Indexof('EXTRACT-PDF') >= 0) then
    begin
      gbl_PDF_Process := True;
      gbl_Bookmark_PDFAuthor := CmdLine.Params.Indexof('BM-PDF') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-PREFETCH') >= 0) then
    begin
      gbl_PF_Process := True;
      gbl_Bookmark_PREFETCH := CmdLine.Params.Indexof('BM-PREFETCH') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-PRINTSPOOL') >= 0) then
    begin
      gbl_PrintSpool_Process := True;
      gbl_Bookmark_PRINTSPOOL := CmdLine.Params.Indexof('BM-PRINTSPOOL') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-LNK') >= 0) then
    begin
      gbl_LNK_Process := True;
      gbl_Bookmark_LNK := CmdLine.Params.Indexof('BM-LNK') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-MSJUMPLIST') >= 0) then
    begin
      gbl_MSJUMPLIST_Process := True;
      gbl_Bookmark_MSJUMPLIST := CmdLine.Params.Indexof('BM-MSJUMPLIST') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-RECYCLEBIN') >= 0) then
    begin
      gbl_RecycleBin_Process := True;
      gbl_Bookmark_RecycleBinPath := CmdLine.Params.Indexof('BM-RECYCLEBINPATH') >= 0;
    end;

    if (CmdLine.Params.Indexof('EXTRACT-VIDEO') >= 0) then
      gbl_Video_Process := True;

    if (CmdLine.Params.Indexof('EXTRACT-ZIP') >= 0) then
      gbl_ZIP_Process := True;

    if (CmdLine.Params.Indexof('FORCE_EXTRACT') >= 0) then
      gbl_force_extract := True
    else
      gbl_force_extract := False;

    // Force the extraction of Metadata on each run
    // gbl_force_extract := False;

    begin
      gbl_DoAll := True;
      MainProc;
    end;
  finally
    gErrorLog_StringList.free;
  end;
  Progress.Log('');
  Progress.Log(SCRIPT_NAME + SPACE + 'finished.');

end.
