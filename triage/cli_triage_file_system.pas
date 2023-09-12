unit cli_triage_file_system;

interface

uses
  Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DataStreams, DIRegex, Graphics, NoteEntry, PropertyList, RawRegistry, RegEx, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BMF_FILESYSTEM = 'File System';
  BMF_MY_BOOKMARKS = 'My Bookmarks';
  BMF_TRIAGE = 'Triage';
  CHAR_LENGTH = 90;
  HYPHEN = ' - ';
  HYPHEN_NS = '-';
  ITUNES_BACKUP = 'iTunes Backup';
  MAIN_FORM_AUTHOR = 'GetData';
  MAIN_FORM_DESCRIPTION = 'This script identifies items of interest.';
  NOSPACE = '';
  ORR = '|';
  PLIST_BINARY = 'Plist (Binary)';
  PST = 'PST';
  RUNNING = '...';
  SCRIPT_NAME = 'Triage' + HYPHEN + 'File System';
  SPACE = ' ';
  TSWT = 'The script will terminate.';
  WINDOWS_USER_FOLDERS = 'Windows User Folders';
  WINDOWS_VERSION = 'Windows Version';
  XML = 'XML';

  // Regex
  BROWSERSCHROME_REGEX_STR = '\\CHROME\.EXE$';
  BROWSERSFIREFOX_REGEX_STR = 'FIREFOX\\FIREFOX\.EXE$';
  BROWSERSINTERNETEXPLORER_REGEX_STR = '\\INTERNET EXPLORER\\IEXPLORE\.EXE$';
  BROWSERSOPERA_REGEX_STR = '\\OPERA\\LAUNCHER\.EXE$';
  BROWSERSSAFARI_REGEX_STR = '\\SAFARI\\SAFARI\.EXE$';
  BROWSERSTOR_REGEX_STR = '\\TOR\.EXE$';
  DEVICESUNALLOCATED_REGEX_STR = 'UNALLOCATED CLUSTERS ON'; // noslz
  DEVICESVBR_REGEX_STR = 'VOLUME BOOT RECORD';
  DEVICESVBR_VOLLABEL_STR = 'VOLUME LABEL';
  EMAILOST_REGEX_STR = '\.OST$';
  EMAILOUTLOOK_REGEX_STR = '\.OUTLOOK.EXE$';
  EMAILPST_REGEX_STR = '\.PST$';
  EMAILTHUNDERBIRD_REGEX_STR = '\.THUNDERBIRD.EXE$';
  FILESHAREDROPBOX_REGEX_STR = '\\DROPBOX\\';
  FILESHAREMEDIAFIRE_REGEX_STR = '\\MEDIAFIRE\\';
  ITUNESBACKUP_REGEX_STR = '\\Apple Computer\\MobileSync\\Backup\\[^\\]+$';
  MACADDRESSBOOKME_REGEX_STR = 'ADDRESSBOOKME\.PLIST$';
  MACATTACHEDIDEVICES_REGEX_STR = 'COM\.APPLE\.IPOD\.PLIST$';
  MACBLUETOOTH_REGEX_STR = '\\LIBRARY\\PREFERENCES\\COM\.APPLE\.BLUETOOTH\.PLIST$';
  MACDOCKITEMS_REGEX_STR = '\\LIBRARY\\PREFERENCES\\COM\.APPLE\.DOCK\.PLIST$';
  MACICLOUDPREFERENCES_REGEX_STR = '\\LIBRARY\\PREFERENCES\\MOBILEMEACCOUNTS\.PLIST$';
  MACIMESSAGEACCOUNTS_REGEX_STR = 'COM\.APPLE\.IMSERVICE\.IMESSAGE\.PLIST$';
  MACIMESSAGECHAT_REGEX_STR = '\\LIBRARY\\MESSAGES\\CHAT.DB$';
  MACINSTALLATIONTIME_REGEX_STR = '\.APPLESETUPDONE$';
  MACINSTALLEDPRINTERS_REGEX_STR = '\\LIBRARY\\PRINTERS\\INSTALLEDPRINTERS\.PLIST$';
  MACLASTSLEEP_REGEX_STR = '\\LIBRARY\\PREFERENCES\\SYSTEMCONFIGURATION\\COM\.APPLE\.POWERMANAGEMENT\.PLIST$';
  MACLOGINITEMS_REGEX_STR = 'COM\.APPLE\.LOGINITEMS\.PLIST$';
  MACLOGINWINDOW_REGEX_STR = '\\LIBRARY\\PREFERENCES\\COM.APPLE\.LOGINWINDOW\.PLIST$';
  MACMAILFOLDER_REGEX_STR = '(IMAP|POP)-[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$';
  MACOSXUPDATE_REGEX_STR = '\\LIBRARY\\PREFERENCES\\COM\.APPLE\.SOFTWAREUPDATE\.PLIST$';
  MACRECENTAPPLICATIONS_REGEX_STR = 'COM\.APPLE\.RECENTITEMS\.PLIST$';
  MACRECENTDOCUMENTS_REGEX_STR = 'COM\.APPLE\.RECENTITEMS\.PLIST$|\.LSSHAREDFILELIST\.PLIST$';
  MACRECENTHOSTS_REGEX_STR = 'COM\.APPLE\.RECENTITEMS\.PLIST$';
  MACRECENTPHOTOBOOTH_REGEX_STR = 'PICTURES\\PHOTO BOOTH LIBRARY\\RECENTS.PLIST$';
  MACSAFARIPREFERENCES_REGEX_STR = '\\LIBRARY\\PREFERENCES\\COM\.APPLE\.SAFARI\.PLIST$';
  MACSAFARIRECENTSEARCHES_REGEX_STR = 'COM\.APPLE\.SAFARI\.PLIST$';
  MACSYSTEMVERSION_REGEX_STR = '\\SYSTEM\\LIBRARY\\CORESERVICES\\SYSTEMVERSION\.PLIST$';
  MACTIMEZONE_REGEX_STR = '\\PREFERENCES\\\.GLOBALPREFERENCES\.PLIST$';
  MACTIMEZONELOCAL_REGEX_STR = '\\ETC\\LOCALTIME$';
  MACWIFI_REGEX_STR = 'COM.APPLE\.WIFI\.WIFIAGENT\.PLIST$';
  PASSWORDSROBOFORM_REGEX_STR = 'ROBOFORM\\IDENTITIES.EXE$|\.RFP$';
  PORN_REGEX_STR = '\bANAL\b|BIG.?BLACK|BLOWJOB|CUMSHOT|CUNT|FUCK|LESBIAN|MASTURBAT|MILF|PENIS|PORN|\bRIMMING\b|SEXUAL|SLUT|\bSQUIRT\b|STEP.?MOM|THREESOME|VAGINA|VOYEUR';
  PORNCAM_REGEX_STR = '\bpedo\b|babyshi|bambina|child[\s\S]?[\s]?(love|porn|rape|sex)|childfugga|Childgod|Children Forced|daddy[\s\S]?[\s]?fuck|ddoggporn|early teen|hairless|hard[\s\S]?[\s]?core[\s\S]?[\s]?teen|' +
    'Hussyfan|kdquality|kiddy[\s\S]?[\s]?porn|kinder|kinderkutje|liluplanet|lolita|nabokov|naked[\s\S]?[\s]?(child|boy|girl|kid)|mylola|pedoland|pedophil|pre[\s\S]?[\s]?teen|pre[\s\S]?[\s]?pubescent|' +
    'pretty\s*(boy|girl|kid)|school[\s\S]?(boy|girl)[\s\S]?porn|tinylove|toddlercon|underage[\s\S]?[\s]?(child|boy|girl|kid)|young[\s\S]?[\s]?virgin|zofilia|zoofilia|zoophilia';
  SHADOWCOPY_REGEX_STR = '3808876b-c176-4e48-b7ae-04046e6cc752';
  SOCIALMEDIABYLOCK_REGEX_STR = 'BYLOCK';
  SOCIALMEDIACAMFROG_REGEX_STR = 'CAMFROG VIDEO CHAT\.EXE$';
  SOCIALMEDIADIGSBY_REGEX_STR = 'DIGSBY-APP\.EXE$';
  SOCIALMEDIAICQ_REGEX_STR = 'ICQ\.EXE$';
  SOCIALMEDIAIMESSAGE_REGEX_STR = 'CHAT.DB$';
  SOCIALMEDIAMSNMESSENGER_REGEX_STR = 'MESSENGER\\MSNMSGR\.EXE$';
  SOCIALMEDIAPALTALK_REGEX_STR = 'PALTALK\.EXE$';
  SOCIALMEDIAPIDGIN_REGEX_STR = 'PIDGIN\.EXE$';
  SOCIALMEDIASKYPE_REGEX_STR = 'SKYPE\.EXE$|\\Skype\\.*?\\main\.db$';
  SOCIALMEDIATRILLIAN_REGEX_STR = 'TRILLIAN\TRILLIAN\.EXE$';
  SOCIALMEDIAWHATSAPP_REGEX_STR = 'ChatStorage\.SQlite$|^1b6b187a1b60b9ae8b720c79e2c67f472bab09c0.*|^275ee4a160b7a7d60825a46b0d3ff0dcdb2fbc9d.*|^7c7fba66680ef796b916b067077cc246adacf01d.*';
  SOCIALMEDIAWINDOWSFACEBOOKAPP_REGEX_STR = 'FRIENDREQUESTS\.SQLITE$|FRIENDS\.SQLITE$|MESSAGES\.SQLITE$|FRIENDREQUESTS\.SQLITE$|NOTIFICATIONS\.SQLITE$';
  SOCIALMEDIAYAHOOMESSENGER_REGEX_STR = 'YAHOOMESSENGER\.EXE$';
  WINDOWSUSERS_REGEX_STR = '\\ROOT\\USERS\\[^\\]+$|\\ROOT\\DOCUMENTS AND SETTINGS\\[^\\]+$|\\ROOT\\DOCUMENTS AND SETTINGS\\[^\\]+$';
  WINDOWSVERSION_REGEX_STR = 'Root\\Program Files \(x86\)$';
  WIPINGTOOLS_REGEX_STR = 'bitkiller' + ORR + 'bleachbit' + ORR + 'cbl.?data.?shredder' + ORR + 'ccleaner' + ORR + 'copy.?wipe' + ORR + 'data.?eraser' + ORR + 'data.?shredder' + ORR + 'data.?wiper' + ORR + 'delete.?on.?click' + ORR +
    'disk.?wipe' + ORR + 'drive.?wipe' + ORR + 'eraser\.exe' + ORR + 'file.?secure' + ORR + 'file.?shredder' + ORR + 'freeraser' + ORR + 'hard.?erase' + ORR + 'hard.?drive.?eraser' + ORR + 'hard.?wipe' + ORR + 'hd.?shredder' + ORR +
    'kill.?disk' + ORR + 'mhdd\.exe' + ORR + 'pc.?disk.?eraser' + ORR + 'pc.?shredder' + ORR + 'privazer' + ORR + 'sdelete' + ORR + 'secure.?delete' + ORR + 'secure.?eraser' + ORR + 'secure.?wiper' + ORR + 'wipe.?disk' + ORR +
    'wise.?care.?365';

var
  gnodefrog_str: string;
  aDatastore: TDataStore;

  // Global Boolean
  bl_AutoBookmark_Results: boolean;
  bl_EvidenceModule: boolean;
  bl_FSModule: boolean;
  bl_FSTriage: boolean;
  bl_RegModule: boolean;
  bl_ScriptsModule: boolean;
  bl_error: boolean;

  FoundCount: integer;
  Starting_Tick_Count: uint64;
  Time_Taken_int: uint64;
  FilesByCount_Tick_Count: uint64;

  // String Lists
  BCWipeStringList: TStringList;
  ByLockStringList: TStringList;
  CamFrogStringList: TStringList;
  CCleanerStringList: TStringList;
  ChromeStringList: TStringList;
  DevicePartitionInfoStringList: TStringList;
  DigsbyStringList: TStringList;
  DiskWipeStringList: TStringList;
  DropBoxStringList: TStringList;
  EraserStringList: TStringList;
  File_Comment_StringList: TStringList;
  FireFoxStringList: TStringList;
  ICQStringList: TStringList;
  iMessageStringList: TStringList;
  InternetExplorerStringList: TStringList;
  iTunesBackupStringList: TStringList;
  MACAddressBookMeStringList: TStringList;
  MACAttachediDevicesStringList: TStringList;
  MACBlueToothStringList: TStringList;
  MACDockItemsStringList: TStringList;
  MACiCloudPreferencesStringList: TStringList;
  MACiMessageAccountsStringList: TStringList;
  MACiMessageChatStringList: TStringList;
  MACInstallationTimeStringList: TStringList;
  MACInstalledPrintersStringtList: TStringList;
  MACLastSleepStringList: TStringList;
  MACLoginItemsStringList: TStringList;
  MACLoginWindowStringList: TStringList;
  MACMailFolderStringList: TStringList;
  MACOSXUpdateStringList: TStringList;
  MACRecentApplicationsStringList: TStringList;
  MACRecentDocumentsStringList: TStringList;
  MACRecentHostsStringList: TStringList;
  MACRecentPhotoBoothStringList: TStringList;
  MACSafariPreferencesStringList: TStringList;
  MACSafariRecentSearchesStringList: TStringList;
  MACSystemVersionStringList: TStringList;
  MACTimeZoneLocalStringList: TStringList;
  MACTimeZoneStringList: TStringList;
  MACWifiStringList: TStringList;
  MediaFireStringList: TStringList;
  MSNMessengerStringList: TStringList;
  OperaStringList: TStringList;
  OSTStringList: TStringList;
  OtherWipeStringList: TStringList;
  OutlookStringList: TStringList;
  PaltalkStringList: TStringList;
  PidginStringList: TStringList;
  PornStringList: TStringList;
  PornCAMStringList: TStringList;
  PrivazerStringList: TStringList;
  PSTStringList: TStringList;
  ResultsStringList: TStringList;
  RoboFormPasswordStringList: TStringList;
  RoboFormStringList: TStringList;
  SafariStringList: TStringList;
  ShadowCopyStringList: TStringList;
  SkypeStringList: TStringList;
  ThunderbirdStringList: TStringList;
  TorStringList: TStringList;
  TrillianStringList: TStringList;
  UsersStringList: TStringList;
  WhatsAppStringList: TStringList;
  Windows64bitStringList: TStringList;
  WindowsFacebookAppStringList: TStringList;
  YahooMessengerStringList: TStringList;

  // Global variables for the Select All form checkboxes
  gchbSelectDeselectALL: boolean;
  gchbSelectDeselectAllBrowsers: boolean;
  gchbSelectDeselectALLMAC: boolean;
  gchbSelectDeselectAllSocialMeda: boolean;
  gchbSelectDeselectAllWipingTools: boolean;

  // Global variables for the form checkboxes
  gchbBookmarkResults: boolean;
  gchbBrowsers_Chrome: boolean;
  gchbBrowsers_Firefox: boolean;
  gchbBrowsers_InternetExplorer: boolean;
  gchbBrowsers_Opera: boolean;
  gchbBrowsers_Safari: boolean;
  gchbBrowsers_Tor: boolean;
  gchbDevices_DeviceSizes: boolean;
  gchbEmail_OST: boolean;
  gchbEmail_Outlook: boolean;
  gchbEmail_OutlookExpress: boolean;
  gchbEmail_PST: boolean;
  gchbEmail_Thunderbird: boolean;
  gchbFileShare_Dropbox: boolean;
  gchbFileShare_Mediafire: boolean;
  gchbIdentifyingFiles: boolean;
  gchbiTunesBackup: boolean;
  gchbMACAddressBookMe: boolean;
  gchbMACAttachediDevices: boolean;
  gchbMACBluetooth: boolean;
  gchbMACDockItems: boolean;
  gchbMACiCloudPreferences: boolean;
  gchbMACiMessageAccounts: boolean;
  gchbMACiMessageChat: boolean;
  gchbMACInstallationTime: boolean;
  gchbMACInstalledPrinters: boolean;
  gchbMACLastSleep: boolean;
  gchbMACLoginItems: boolean;
  gchbMACLoginWindow: boolean;
  gchbMACMailFolder: boolean;
  gchbMACOSXUpdate: boolean;
  gchbMACRecentApplications: boolean;
  gchbMACRecentDocuments: boolean;
  gchbMACRecentHosts: boolean;
  gchbMACRecentPhotoBooth: boolean;
  gchbMACSafariPreferences: boolean;
  gchbMACSafariRecentSearches: boolean;
  gchbMACSystemVersion: boolean;
  gchbMACTimeZone: boolean;
  gchbMACTimeZoneLocal: boolean;
  gchbMACWifi: boolean;
  gchbPasswords_RoboForm: boolean;
  gchbPorn: boolean;
  gchbPornCAM: boolean;
  gchbSocialMedia_ByLock: boolean;
  gchbSocialMedia_Camfrog: boolean;
  gchbSocialMedia_Digsby: boolean;
  gchbSocialMedia_ICQ: boolean;
  gchbSocialMedia_iMessage: boolean;
  gchbSocialMedia_MSNMessenger: boolean;
  gchbSocialMedia_PalTalk: boolean;
  gchbSocialMedia_Pidgin: boolean;
  gchbSocialMedia_Skype: boolean;
  gchbSocialMedia_Trillian: boolean;
  gchbSocialmedia_WhatsApp: boolean;
  gchbSocialMedia_WindowsFaceBookApp: boolean;
  gchbSocialMedia_YahooMessenger: boolean;
  gchbWindows_32or64bit: boolean;
  gchbWindows_ShadowCopy: boolean;
  gchbWindows_UserAccounts: boolean;
  gchbWipingTools_BCWipe: boolean;
  gchbWipingTools_CCleaner: boolean;
  gchbWipingTools_DiskWipe: boolean;
  gchbWipingTools_Eraser: boolean;
  gchbWipingTools_Other: boolean;
  gchbWipingTools_Privazer: boolean;

  // Reporting strings
  files_were_located_str: string;
  folders_were_located_str: string;
  is_installed_str: string;
  may_be_present_str: string;
  may_have_been_used_str: string;

  // MISC
  Allocated_percent: double;
  Allocated_Size_Bytes: int64;
  Allocated_Size_GB: double;
  Device_Name: TEntry;
  Device_Size_Bytes: int64;
  Device_Size_GB: double;
  DeviceList: TList;
  DeviceListEntry: TEntry;
  DevicePartition_BM_Folder_Comment_str: string;
  DeviceToSearchList: TList;
  IsBootable_str: string;
  MACDevice_bl: boolean;
  MACDeviceList: TList;
  MACDeviceLisTEntry: TEntry;
  OneBigRegex_str: string;
  Partition_Name: string;
  Partition_Percent: double;
  Partition_Size_Bytes: int64;
  Partition_Size_GB: double;
  Partition_Type: string;
  Unallocated_percent: double;
  Unallocated_Size_Bytes: int64;
  Unallocated_Size_GB: double;

  { endofvar }

procedure ConsoleSection(ASection: string);
procedure Log(AStringList: TStringList; AConsoleStr: string);
procedure BookMark_Create(AGroup_Folder, AItem_Folder, AComment: string; anEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
function RPad(const AString: string; AChars: integer): string;

implementation

procedure ConsoleLog(AString: string);
begin
  if assigned(ResultsStringList) then
    if ResultsStringList.Count < 5000 then
      ResultsStringList.Add(AString); // no time and date for the results memo
end;

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
        aNode := TPropertyNode(theNodeList.items[i]);
        if assigned(aNode) and (UpperCase(aNode.PropName) = UpperCase('Name')) then // noslz
          gnodefrog_str := gnodefrog_str + #13#10 + (aNode.PropDisplayValue);
        nodefrog(aNode, anint + 1);
      end;
    end;
  end;
end;

procedure BookMarkDevice(AGroup_Folder, AItem_Folder, AComment: string; bmdEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
var
  bCreate: boolean;
  bmParent: TEntry;
  DeviceEntry: TEntry;
  device_name_str: string;
begin
  if (assigned(bmdEntry)) and (Progress.isRunning) then
  begin
    DeviceEntry := GetDeviceEntry(bmdEntry);
    device_name_str := DeviceEntry.EntryName;
    device_name_str := StringReplace(device_name_str, '\', '-', [rfReplaceAll]);
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + device_name_str + '\Device', bCreate);
    if assigned(bmParent) and bCreate then
      UpdateBookmark(bmParent, AComment);
    if assigned(bmParent) and ABookmarkEntry and not(IsItemInBookmark(bmParent, bmdEntry)) then
      AddItemsToBookmark(bmParent, DATASTORE_FILESYSTEM, bmdEntry, AFileComment);
  end;
end;

procedure BookMark_Create(AGroup_Folder, AItem_Folder, AComment: string; anEntry: TEntry; AFileComment: string; ABookmarkEntry: boolean);
var
  bCreate: boolean;
  bmParent: TEntry;
  DeviceEntry: TEntry;
  device_str: string;
begin
  if (assigned(anEntry)) and (Progress.isRunning) then
  begin
    DeviceEntry := GetDeviceEntry(anEntry);
    device_str := DeviceEntry.EntryName;
    device_str := StringReplace(device_str, '\', '-', [rfReplaceAll]);
    bCreate := True;
    bmParent := FindBookmarkByName(BMF_TRIAGE + '\' + device_str + '\' + BMF_FILESYSTEM + '\' + AGroup_Folder + AItem_Folder, bCreate);
    if bCreate then
      UpdateBookmark(bmParent, AComment);
    if ABookmarkEntry and not(IsItemInBookmark(bmParent, anEntry)) then
      AddItemsToBookmark(bmParent, DATASTORE_FILESYSTEM, anEntry, AFileComment);
  end;
end;

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

procedure ConsoleSection(ASection: string);
begin
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('*** ' + ASection + ' ***');
end;

// Log found items to results form
procedure Log(AStringList: TStringList; AConsoleStr: string);
var
  i: integer;
begin
  if AStringList = nil then
  begin
    ConsoleLog(AConsoleStr);
  end
  else if assigned(AStringList) and (AStringList.Count > 0) then
  begin
    ConsoleLog(AConsoleStr);
    if gchbIdentifyingFiles then // Lists identifying files in report
    begin
      // do not sort DevicePartitionInfoStringList
      if not(AStringList = DevicePartitionInfoStringList) then
        AStringList.Sort;
      for i := 0 to AStringList.Count - 1 do
        if Progress.isRunning then
          ConsoleLog(AStringList.strings[i])
    end;
    ConsoleLog(' ');
  end;
end;

// Search using POS ------------------------------------------------------------
function POSCheck(const AMatchStr, APath, AFolderStr, AGroupFolder: string; AStringList: TStringList; AEntry: TEntry; AFileComment: string; ABookmark: boolean): boolean;
begin
  Result := False;
  if pos(AMatchStr, APath) > 0 then
  begin
    AStringList.AddObject('     *' + AEntry.FullPathName, AEntry);
    FoundCount := FoundCount + 1;
    if ABookmark then
      BookMark_Create(AGroupFolder, AFolderStr, '', AEntry, AFileComment, True);

    if AGroupFolder <> 'MAC' then
    begin
      if MACDevice_bl and ((AGroupFolder = 'Social Media') or (AGroupFolder = 'Partitions')) then
      begin
        if ABookmark then
          BookMark_Create('MAC\' + AGroupFolder, AFolderStr, '', AEntry, AFileComment, True);
      end;
    end;

    Result := True;
  end;
end;

// Search using RegEx ----------------------------------------------------------
function RegExCheck(const AMatchStr, APath, AFolderStr, AGroupFolder: string; AStringList: TStringList; AEntry: TEntry; AFileComment: string; ABookmark: boolean): boolean;
begin
  Result := False;
  if (RegexMatch(APath, AMatchStr, False)) then
  begin
    AStringList.AddObject('     *' + AEntry.FullPathName, AEntry);
    FoundCount := FoundCount + 1;
    if ABookmark then
      BookMark_Create(AGroupFolder, AFolderStr, '', AEntry, AFileComment, True);

    if AGroupFolder <> 'MAC' then
    begin
      if MACDevice_bl and ((AGroupFolder = 'Social Media') or (AGroupFolder = 'Partitions')) then
      begin
        if ABookmark then
          BookMark_Create('MAC\' + AGroupFolder, AFolderStr, '', AEntry, AFileComment, True);
      end;
    end;

    Result := True;
  end;
end;

type
  TTriageResults = record
    // Categories
    Browsers: boolean;
    Category_DevicePartitionInfo: boolean;
    Category_Windows_Users: boolean;
    Category_Windows_Version: boolean;
    Email: boolean;
    FileShare: boolean;
    iTunesBackup: boolean;
    MACFileSystem: boolean;
    Passwords: boolean;
    SocialMedia: boolean;
    Users: boolean;
    Wiping: boolean;
    // Browsers
    FireFoxInstalled: boolean;
    ChromeInstalled: boolean;
    InternetExplorerInstalled: boolean;
    OperaInstalled: boolean;
    SafariInstalled: boolean;
    TorInstalled: boolean;
    // SocialMedia
    SocialMediaByLock: boolean;
    SocialMediaDigsby: boolean;
    SocialMediaICQ: boolean;
    SocialMediaMSNMessenger: boolean;
    SocialMediaPaltalk: boolean;
    SocialMediaPidgin: boolean;
    SocialMediaTrillian: boolean;
    SocialMediaYahooMessenger: boolean;
    CamfrogInstalled: boolean;
    SkypeInstalled: boolean;
    iMessageInstalled: boolean;
    WhatsApp: boolean;
    WindowsFacebookApp: boolean;
    // Email
    OST: boolean;
    Outlook: boolean;
    PST: boolean;
    Thunderbird: boolean;
    // Fileshare
    Dropbox: boolean;
    Mediafire: boolean;
    // MAC File System
    MACAddressBookMe: boolean;
    MACAttachediDevices: boolean;
    MACBluetooth: boolean;
    MACDockItems: boolean;
    MACiCloudPreferences: boolean;
    MACiMessageAccounts: boolean;
    MACiMessageChat: boolean;
    MACInstallationTime: boolean;
    MACInstalledPrinters: boolean;
    MACLastSleep: boolean;
    MACLoginItems: boolean;
    MACLoginWindow: boolean;
    MACMailFolder: boolean;
    MACOSXUpdate: boolean;
    MACPhotoBoothRecents: boolean;
    MACRecentApplications: boolean;
    MACRecentDocuments: boolean;
    MACRecentHosts: boolean;
    MACSystemVersion: boolean;
    MACSafariPreferences: boolean;
    MACSafariRecentSearches: boolean;
    MACTimeZone: boolean;
    MACTimeZoneLocal: boolean;
    MACWifi: boolean;
    // Passwords
    RoboFormInstalled: boolean;
    RoboFormPasswords: boolean;
    // iTunesBackup
    AppleiTunesBackup: boolean;
    // Pornography
    Porn: boolean;
    PornCAM: boolean;
    // ShadowCopy
    ShadowCopy: boolean;
    // Windows
    Windows64bit: boolean;
    Windows32bit: boolean;
    DevicePartitionInfo: boolean;
    // Wiping Tools
    BCWipeInstalled: boolean;
    CCleanerInstalled: boolean;
    DiskWipe: boolean;
    Eraser: boolean;
    PrivazerInstalled: boolean;
    // Counters
    PornCount: integer;
    PornCAMCount: integer;
  end;

function TriageFileSystemEntry(anEntry: TEntry; var TriageResults: TTriageResults): boolean;
var
  aDeterminedFileDriverInfo: TFileTypeInformation;
  aParentNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aReader: TEntryReader;
  bitlocker_password_str: string;
  bmComment: string;
  BmFolderComment_StringList: TStringList;
  ByteArray: array [1 .. 64] of byte;
  ByteCount: integer;
  cEntry: TEntry;
  ChildEntry: TEntry;
  col_Password: TDataStoreField;
  File_Comment: string;
  fileext: string;
  FileSignatureInfo: TFileTypeInformation;
  filevault_password_str: string;
  FolderChildren_List: TList;
  Group_Folder: string;
  i, m, t, w, x, y, z: integer;
  Item_Folder: string;
  Node1: TPropertyNode;
  Node1Next: TPropertyNode;
  Node2: TPropertyNode;
  Node3: TPropertyNode;
  Node4: TPropertyNode;
  Node5: TPropertyNode;
  NodeLabel: string;
  NodeList1: TObjectList;
  NodeList2: TObjectList;
  NodeList3: TObjectList;
  NodeList4: TObjectList;
  NumberOfNodes: integer;
  rpad_value: integer;
  temp_regex_str: string;
  temp_regex_str2: string;
  temp_regex_StringList: TStringList;
  temp_value: string;
  temp_value2: string;
  tempDatastore: TDataStore;
  UpperDirName: string;
  UpperFilename: string;
  UpperFullname: string;
  Volume_ID: string;
  Volume_Label: string;

  procedure AddToTwoStringLists(AString: string);
  begin
    if assigned(DevicePartitionInfoStringList) then
      DevicePartitionInfoStringList.Add(AString);
    if assigned(BmFolderComment_StringList) then
      BmFolderComment_StringList.Add(AString);
  end;

begin
  Result := True;
  File_Comment := '';
  NodeLabel := '';
  UpperFilename := UpperCase(anEntry.EntryName);
  UpperDirName := UpperCase(anEntry.Directory);
  UpperFullname := UpperCase(anEntry.FullPathName);
  DetermineFileType(anEntry);
  aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
  Device_Name := GetDeviceEntry(anEntry);
  MACDevice_bl := False;
  if assigned(MACDeviceList) and (MACDeviceList.Count > 0) then
  begin
    for m := 0 to MACDeviceList.Count - 1 do
    begin
      MACDeviceLisTEntry := TEntry(MACDeviceList.items[m]);
      if MACDeviceLisTEntry = Device_Name then
      begin
        MACDevice_bl := True;
      end;
    end;
  end;

  // BROWSERS ===============================================================
  Group_Folder := 'Browsers';
  temp_regex_str := '';
  if gchbBrowsers_Firefox then
    temp_regex_str := temp_regex_str + ORR + BROWSERSFIREFOX_REGEX_STR;
  if gchbBrowsers_Chrome then
    temp_regex_str := temp_regex_str + ORR + BROWSERSCHROME_REGEX_STR;
  if gchbBrowsers_InternetExplorer then
    temp_regex_str := temp_regex_str + ORR + BROWSERSINTERNETEXPLORER_REGEX_STR;
  if gchbBrowsers_Opera then
    temp_regex_str := temp_regex_str + ORR + BROWSERSOPERA_REGEX_STR;
  if gchbBrowsers_Safari then
    temp_regex_str := temp_regex_str + ORR + BROWSERSSAFARI_REGEX_STR;
  if gchbBrowsers_Tor then
    temp_regex_str := temp_regex_str + ORR + BROWSERSTOR_REGEX_STR;
  delete(temp_regex_str, 1, 1); // do not have a leading OR '|'
  if (RegexMatch(UpperFullname, temp_regex_str, False)) then
  begin
    if gchbBrowsers_Firefox and RegExCheck(BROWSERSFIREFOX_REGEX_STR, UpperFullname, '\Firefox', Group_Folder, FireFoxStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Browsers := True;
    if gchbBrowsers_Chrome and RegExCheck(BROWSERSCHROME_REGEX_STR, UpperFullname, '\Chrome', Group_Folder, ChromeStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Browsers := True;
    if gchbBrowsers_InternetExplorer and RegExCheck(BROWSERSINTERNETEXPLORER_REGEX_STR, UpperFullname, '\Internet Explorer', Group_Folder, InternetExplorerStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Browsers := True;
    if gchbBrowsers_Opera and RegExCheck(BROWSERSOPERA_REGEX_STR, UpperFullname, '\Opera', Group_Folder, OperaStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Browsers := True;
    if gchbBrowsers_Safari and RegExCheck(BROWSERSSAFARI_REGEX_STR, UpperFullname, '\Safari', Group_Folder, SafariStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Browsers := True;
    if gchbBrowsers_Tor and RegExCheck(BROWSERSTOR_REGEX_STR, UpperFullname, '\Tor', Group_Folder, TorStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Browsers := True;
  end;

  // EMAIL ==================================================================
  Group_Folder := 'Email';
  temp_regex_str := '';
  if gchbEmail_PST then
    temp_regex_str := temp_regex_str + ORR + EMAILPST_REGEX_STR;
  if gchbEmail_OST then
    temp_regex_str := temp_regex_str + ORR + EMAILOST_REGEX_STR;
  if gchbEmail_Thunderbird then
    temp_regex_str := temp_regex_str + ORR + EMAILTHUNDERBIRD_REGEX_STR;
  if gchbEmail_Outlook then
    temp_regex_str := temp_regex_str + ORR + EMAILOUTLOOK_REGEX_STR;
  delete(temp_regex_str, 1, 1); // do not have a leading OR '|'
  if (RegexMatch(UpperFullname, temp_regex_str, False)) then
  begin
    fileext := ExtractFileExt(UpperFilename);
    aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
    if gchbEmail_PST and (fileext = '.PST') then
    begin
      if (aDeterminedFileDriverInfo.ShortDisplayName = PST) then
        if POSCheck('.PST', UpperFullname, '\Outlook', Group_Folder, PSTStringList, anEntry, File_Comment, gchbBookmarkResults) then
          TriageResults.Email := True;
    end;
    if gchbEmail_OST and (fileext = '.OST') then
    begin
      if (aDeterminedFileDriverInfo.ShortDisplayName = 'OST') then
        if POSCheck('.OST', UpperFullname, '\Outlook', Group_Folder, OSTStringList, anEntry, File_Comment, gchbBookmarkResults) then
          TriageResults.Email := True;
    end;
    if gchbEmail_Thunderbird and RegExCheck(EMAILTHUNDERBIRD_REGEX_STR, UpperFullname, '\Thunderbird', Group_Folder, ThunderbirdStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Email := True;
    if gchbEmail_Outlook and RegExCheck(EMAILOUTLOOK_REGEX_STR, UpperFullname, '\Outlook', Group_Folder, OutlookStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Email := True;
  end;

  // DEVICE AND PARTITION INFO==================================================
  Group_Folder := ('Partitions');
  if gchbDevices_DeviceSizes then
  begin
    TriageResults.Category_DevicePartitionInfo := True;
    TriageResults.DevicePartitionInfo := True;
    FoundCount := FoundCount + 1;
    begin
      // Get Partition Info
      if not anEntry.InExpanded and anEntry.IsFreeSpace and (RegexMatch(anEntry.EntryName, '^' + NOSPACE + 'Unallocated clusters on', False)) then // noslz 6-Sep-19 Not translated Delphi
      begin
        Device_Name := GetDeviceEntry(anEntry);
        Device_Size_Bytes := Device_Name.PhysicalSize;
        Device_Size_GB := Device_Size_Bytes / 1024 / 1024 / 1024;

        if assigned(anEntry.Parent) then
        begin
          DetermineFileType(TEntry(anEntry.Parent));
          FileSignatureInfo := TEntry(anEntry.Parent).DeterminedFileDriverInfo;
          Partition_Type := FileSignatureInfo.ShortDisplayName;

          if isPartition(TEntry(anEntry.Parent)) then
            Partition_Name := anEntry.Parent.EntryName
          else
            Partition_Name := 'Logical Image';

          // FileVault Password
          if isPartition(TEntry(anEntry.Parent)) then
          begin
            tempDatastore := GetDataStore(DATASTORE_FILESYSTEM);
            if assigned(tempDatastore) then
              try
                FolderChildren_List := tempDatastore.Children(TEntry(anEntry.Parent));
                for i := 0 to FolderChildren_List.Count - 1 do
                begin
                  cEntry := TEntry(FolderChildren_List[i]);
                  if cEntry.EntryName = 'CLEAN' then // noslz
                  begin
                    col_Password := tempDatastore.DataFields.FieldByName('Password'); // noslz
                    if assigned(col_Password) then
                    begin
                      filevault_password_str := '';
                      filevault_password_str := trim(col_Password.AsString[cEntry]);
                    end;
                  end;
                end;
              finally
                tempDatastore.free;
              end;
          end;

          // Bitlocker Password
          if isPartition(TEntry(anEntry.Parent)) then
          begin
            if anEntry.Parent.EntryName = 'Bitlocker Partition' then // noslz
            begin
              tempDatastore := GetDataStore(DATASTORE_FILESYSTEM);
              if assigned(tempDatastore) then
                try
                  col_Password := aDatastore.DataFields.FieldByName('Password'); // noslz
                  if assigned(col_Password) then
                  begin
                    bitlocker_password_str := '';
                    bitlocker_password_str := trim(col_Password.AsString[anEntry.Parent]);
                  end;
                finally
                  tempDatastore.free;
                end;
            end;
          end
          else
            Partition_Name := 'Logical Image';
        end;

        // Get Volume ID and Volume Label
        Volume_ID := '';
        Volume_Label := '';
        if assigned(anEntry.Parent) then
        begin
          FolderChildren_List := aDatastore.Children(TEntry(anEntry.Parent));
          try
            for i := 0 to FolderChildren_List.Count - 1 do
            begin
              ChildEntry := TEntry(FolderChildren_List[i]);
              if ChildEntry.IsSystem and (RegexMatch(ChildEntry.EntryName, DEVICESVBR_REGEX_STR, False)) then
              begin
                aReader := TEntryReader.Create;
                try
                  if aReader.OpenData(ChildEntry) then
                  begin
                    NodeLabel := '';
                    File_Comment := '';
                    aPropertyTree := nil;
                    if ProcessDisplayProperties(ChildEntry, aPropertyTree, aReader) then
                    begin
                      // Volume ID (Serial)
                      aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Volume ID')); // noslz
                      if assigned(aParentNode) then
                        Volume_ID := trim(aParentNode.PropDisplayValue);
                      // Volume Label
                      aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Volume Label')); // noslz
                      if assigned(aParentNode) then
                        Volume_Label := trim(aParentNode.PropDisplayValue);
                    end;
                    if aPropertyTree <> nil then
                      aPropertyTree.free;
                  end;
                finally
                  aReader.free;
                end;
              end;
            end;
          finally
            FolderChildren_List.free;
          end;
        end;

        if assigned(anEntry.Parent) then
        begin
          if IsBootablePartition(TEntry(anEntry.Parent)) then
            IsBootable_str := 'YES'
          else
            IsBootable_str := 'NO';
        end;

        Partition_Size_Bytes := 0;
        Partition_Size_GB := 0;
        Partition_Percent := 0;
                
        if assigned(anEntry.Parent) then
          Partition_Size_Bytes := anEntry.Parent.LogicalSize;
          
        if Device_Size_Bytes > 0 then
        try        
          Partition_Percent := (Partition_Size_Bytes / Device_Size_Bytes) * 100;
        except
        end;
        
        Partition_Size_GB := Partition_Size_Bytes / 1024 / 1024 / 1024;
        
        Unallocated_Size_Bytes := anEntry.LogicalSize;
        Unallocated_Size_GB := 0;
        Unallocated_percent := 0;
        
        if Partition_Size_Bytes > 0 then
        try        
          Unallocated_percent := (Unallocated_Size_Bytes / Partition_Size_Bytes) * 100;
        except
        end;
        
        try
          Unallocated_Size_GB := anEntry.LogicalSize / 1024 / 1024 / 1024;
        except
        end;
        
        Allocated_Size_Bytes := Partition_Size_Bytes - Unallocated_Size_Bytes;
        Allocated_Size_GB := 0;
        Allocated_percent := 0;
         
        if Partition_Size_Bytes > 0 then
        try
          Allocated_percent := (Allocated_Size_Bytes / Partition_Size_Bytes) * 100;
        except
        end;
        
        try
          Allocated_Size_GB := Allocated_Size_Bytes / 1024 / 1024 / 1024;
        except
        end;
        
        // Output Results to the display and folder comment StringLists
        rpad_value := 35;
        BmFolderComment_StringList := TStringList.Create;
        try
          AddToTwoStringLists(RPad('Device:', rpad_value) + Device_Name.EntryName);
          AddToTwoStringLists(RPad('Partition Name:', rpad_value) + Partition_Name);
          if bitlocker_password_str <> '' then
            AddToTwoStringLists(RPad('Password:', rpad_value) + bitlocker_password_str);
          if filevault_password_str <> '' then
            AddToTwoStringLists(RPad('Password:', rpad_value) + filevault_password_str);
          AddToTwoStringLists(RPad('Volume ID (Serial):', rpad_value) + Volume_ID);
          if Volume_Label <> '' then
            AddToTwoStringLists(RPad('Volume Label:', rpad_value) + trim(Volume_Label));
          AddToTwoStringLists(RPad('Device Size:', rpad_value) + FormatFloat('00.00', Device_Size_GB) + ' GB');
          AddToTwoStringLists(RPad('Partition Type:', rpad_value) + Partition_Type);
          AddToTwoStringLists(RPad('Is Bootable:', rpad_value) + IsBootable_str);
          AddToTwoStringLists(RPad('Partition Size:', rpad_value) + FormatFloat('00.00', Partition_Size_GB) + ' GB ' + '(' + FormatFloat('00.0', Partition_Percent) + '% of device)');
          AddToTwoStringLists(RPad('Allocated Space:', rpad_value) + FormatFloat('00.00', Allocated_Size_GB) + ' GB ' + '(' + FormatFloat('00.0', Allocated_percent) + '%)');
          AddToTwoStringLists(RPad('Unallocated Size:', rpad_value) + FormatFloat('00.00', Unallocated_Size_GB) + ' GB ' + '(' + FormatFloat('00.0', Unallocated_percent) + '%)');
          AddToTwoStringLists(' ');

          if assigned(BmFolderComment_StringList) and (BmFolderComment_StringList.Count > 0) then
          begin
            DevicePartition_BM_Folder_Comment_str := BmFolderComment_StringList.Text;
          end
          else
          begin
            DevicePartition_BM_Folder_Comment_str := '';
          end;
        finally
          FreeAndNil(BmFolderComment_StringList);
        end;

        Item_Folder := '\' + Partition_Name; // Leave blank - no subgroup required

        // Call the BookMark function
        if gchbBookmarkResults then
        begin
          BookMark_Create(Group_Folder, Item_Folder, DevicePartition_BM_Folder_Comment_str, anEntry, File_Comment, False);
          if MACDevice_bl then
            BookMark_Create('MAC\' + Group_Folder, Item_Folder, DevicePartition_BM_Folder_Comment_str, anEntry, File_Comment, False);
          DevicePartition_BM_Folder_Comment_str := '';
        end;
      end;
    end;
  end;

  // FILESHARE ==============================================================
  Group_Folder := 'Fileshare';
  temp_regex_str := '';
  if gchbFileShare_Dropbox then
    temp_regex_str := temp_regex_str + ORR + FILESHAREDROPBOX_REGEX_STR;
  if gchbFileShare_Mediafire then
    temp_regex_str := temp_regex_str + ORR + FILESHAREMEDIAFIRE_REGEX_STR;
  delete(temp_regex_str, 1, 1); // do not have a leading OR '|'
  if (RegexMatch(UpperFullname, temp_regex_str, False)) then
  begin
    if gchbFileShare_Dropbox and POSCheck(FILESHAREDROPBOX_REGEX_STR, UpperDirName, '\DropBox', Group_Folder, DropBoxStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.FileShare := True;
    if gchbFileShare_Mediafire and POSCheck(FILESHAREMEDIAFIRE_REGEX_STR, UpperDirName, '\MediaFire', Group_Folder, MediaFireStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.FileShare := True;
  end;

  // iTunesBackup ================================================================== single so do not need first regex
  Group_Folder := (ITUNES_BACKUP);
  if gchbiTunesBackup then
  begin
    if anEntry.IsDirectory then
    begin
      if (RegexMatch(anEntry.FullPathName, ITUNESBACKUP_REGEX_STR, False)) then
      begin
        FoundCount := FoundCount + 1;
        TriageResults.iTunesBackup := True;
        iTunesBackupStringList.AddObject('     *' + anEntry.FullPathName, anEntry);
        Item_Folder := ''; // Leave blank - no subgroup required
        FoundCount := FoundCount + 1;
        if gchbBookmarkResults then
          BookMark_Create(Group_Folder, Item_Folder, '', anEntry, File_Comment, True);
      end;
    end;
  end;

  // MAC ==================================================================
  Group_Folder := 'MAC';
  temp_regex_str := '';
  bmComment := '';
  if gchbMACAddressBookMe then
    temp_regex_str := temp_regex_str + ORR + MACADDRESSBOOKME_REGEX_STR;
  if gchbMACAttachediDevices then
    temp_regex_str := temp_regex_str + ORR + MACATTACHEDIDEVICES_REGEX_STR;
  if gchbMACBluetooth then
    temp_regex_str := temp_regex_str + ORR + MACBLUETOOTH_REGEX_STR;
  if gchbMACDockItems then
    temp_regex_str := temp_regex_str + ORR + MACDOCKITEMS_REGEX_STR;
  if gchbMACiCloudPreferences then
    temp_regex_str := temp_regex_str + ORR + MACICLOUDPREFERENCES_REGEX_STR;
  if gchbMACiMessageAccounts then
    temp_regex_str := temp_regex_str + ORR + MACIMESSAGEACCOUNTS_REGEX_STR;
  if gchbMACiMessageChat then
    temp_regex_str := temp_regex_str + ORR + MACIMESSAGECHAT_REGEX_STR;
  if gchbMACInstallationTime then
    temp_regex_str := temp_regex_str + ORR + MACINSTALLATIONTIME_REGEX_STR;
  if gchbMACInstalledPrinters then
    temp_regex_str := temp_regex_str + ORR + MACINSTALLEDPRINTERS_REGEX_STR;
  if gchbMACLastSleep then
    temp_regex_str := temp_regex_str + ORR + MACLASTSLEEP_REGEX_STR;
  if gchbMACLoginItems then
    temp_regex_str := temp_regex_str + ORR + MACLOGINITEMS_REGEX_STR;
  if gchbMACLoginWindow then
    temp_regex_str := temp_regex_str + ORR + MACLOGINWINDOW_REGEX_STR;
  if gchbMACMailFolder then
    temp_regex_str := temp_regex_str + ORR + MACMAILFOLDER_REGEX_STR;
  if gchbMACOSXUpdate then
    temp_regex_str := temp_regex_str + ORR + MACOSXUPDATE_REGEX_STR;
  if gchbMACRecentApplications then
    temp_regex_str := temp_regex_str + ORR + MACRECENTAPPLICATIONS_REGEX_STR;
  if gchbMACRecentDocuments then
    temp_regex_str := temp_regex_str + ORR + MACRECENTDOCUMENTS_REGEX_STR;
  if gchbMACRecentHosts then
    temp_regex_str := temp_regex_str + ORR + MACRECENTHOSTS_REGEX_STR;
  if gchbMACRecentPhotoBooth then
    temp_regex_str := temp_regex_str + ORR + MACRECENTPHOTOBOOTH_REGEX_STR;
  if gchbMACSystemVersion then
    temp_regex_str := temp_regex_str + ORR + MACSYSTEMVERSION_REGEX_STR;
  if gchbMACSafariPreferences then
    temp_regex_str := temp_regex_str + ORR + MACSAFARIPREFERENCES_REGEX_STR;
  if gchbMACSafariRecentSearches then
    temp_regex_str := temp_regex_str + ORR + MACSAFARIRECENTSEARCHES_REGEX_STR;
  if gchbMACTimeZone then
    temp_regex_str := temp_regex_str + ORR + MACTIMEZONE_REGEX_STR;
  if gchbMACTimeZoneLocal then
    temp_regex_str := temp_regex_str + ORR + MACTIMEZONELOCAL_REGEX_STR;
  if gchbMACWifi then
    temp_regex_str := temp_regex_str + ORR + MACWIFI_REGEX_STR;
  delete(temp_regex_str, 1, 1); // do not have a leading OR '|'

  // Bookmark MAC Device
  if temp_regex_str <> '' then
  begin
    if anEntry.isDevice or (dstPartition in anEntry.Status) then
    begin
      if (pos('HFS', aDeterminedFileDriverInfo.ShortDisplayName) > 0) or (pos('APFS', aDeterminedFileDriverInfo.ShortDisplayName) > 0) then
      begin
        if anEntry.isDevice then
          BookMark_Create(Group_Folder, '\Device', '', anEntry, '', True);
        if (dstPartition in anEntry.Status) then
          if assigned(anEntry.Parent) then
            BookMark_Create(Group_Folder, '\Device', '', TEntry(anEntry.Parent), '', True);
      end;
    end;
  end;

  if (RegexMatch(UpperFullname, temp_regex_str, False)) then
  begin
    rpad_value := 25;
    fileext := ExtractFileExt(UpperFilename);
    aReader := TEntryReader.Create;
    try
      // AddressBookMe
      if gchbMACAddressBookMe and (RegexMatch(UpperFullname, MACADDRESSBOOKME_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = XML) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dict')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes to extract the bmComment
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and (Node1.PropName = 'key') then // noslz
                begin
                  if x + 1 <= NumberOfNodes - 1 then
                  begin
                    if Not Progress.isRunning then
                      Break;
                    begin
                      NodeLabel := '';
                      NodeLabel := Node1.PropValue;
                      Node1 := TPropertyNode(NodeList1.items[x + 1]);
                      File_Comment := File_Comment + #13#10 + RPad(NodeLabel + ':', rpad_value) + (Node1.PropDisplayValue);
                    end;
                  end;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACAddressBookMe and RegExCheck(MACADDRESSBOOKME_REGEX_STR, UpperFullname, '\AddressBookMe', Group_Folder, MACAddressBookMeStringList, anEntry, File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Attached iDevices
      if gchbMACAttachediDevices and (RegexMatch(UpperFullname, MACATTACHEDIDEVICES_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Devices')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes to extract the bmComment
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) then
                begin
                  // Level 2 List
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                    for y := 0 to NodeList2.Count - 1 do
                    begin
                      Node2 := TPropertyNode(NodeList2.items[y]);
                      if assigned(Node2) then
                      begin
                        if Not Progress.isRunning then
                          Break;
                        NodeLabel := '';
                        NodeLabel := Node2.PropName;
                        File_Comment := File_Comment + #13#10 + RPad(NodeLabel + ':', rpad_value) + (Node2.PropDisplayValue);
                      end;
                    end;
                  File_Comment := File_Comment + #13#10;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACAttachediDevices and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACATTACHEDIDEVICES_REGEX_STR, UpperFullname, '\Attached iDevices', Group_Folder, MACAttachediDevicesStringList, anEntry,
          File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // BlueTooth
      if gchbMACBluetooth and (RegexMatch(UpperFullname, MACBLUETOOTH_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin

            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('DeviceCache')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes to extract the bmComment
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and RegexMatch(Node1.PropName, '^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$', False) then
                begin
                  // Level 2 List
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                    for y := 0 to NodeList2.Count - 1 do
                    begin
                      Node2 := TPropertyNode(NodeList2.items[y]);
                      if assigned(Node2) then
                      begin
                        if Not Progress.isRunning then
                          Break;
                        NodeLabel := '';
                        NodeLabel := Node2.PropName;
                        if (Length(Node2.PropDisplayValue) < 100) then
                          File_Comment_StringList.Add(RPad(NodeLabel + ':', rpad_value) + (Node2.PropDisplayValue));
                      end;
                    end;
                  File_Comment_StringList.Sort;
                  File_Comment := File_Comment + File_Comment_StringList.Text + #13#10;
                  File_Comment_StringList.Clear;
                end;
              end;
            end;

          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACBluetooth and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACBLUETOOTH_REGEX_STR, UpperFullname, '\Bluetooth', Group_Folder, MACBlueToothStringList, anEntry, File_Comment, gchbBookmarkResults)
        then
          TriageResults.MACFileSystem := True;
      end;

      // DockItems
      if gchbMACDockItems and (RegexMatch(UpperFullname, MACDOCKITEMS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('persistent-apps')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node2 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node2) and (Node2.PropName = '') then
                begin
                  NodeList2 := Node2.PropChildList;
                  if assigned(NodeList2) and (Node2.PropChildList.Count > 0) then
                  begin
                    for y := 0 to NodeList2.Count - 1 do
                    begin
                      Node3 := TPropertyNode(NodeList2.items[y]);
                      if assigned(Node3) and (Node3.PropName = 'tile-data') then
                      // Get the children of title-data
                      begin
                        NodeList3 := Node3.PropChildList;
                        if assigned(NodeList3) and (NodeList3.Count > 0) then
                        begin
                          // Process the tile-data nodes
                          for z := 0 to NodeList3.Count - 1 do
                          begin
                            // Collect the Node Label
                            Node4 := TPropertyNode(NodeList3.items[z]);
                            if assigned(Node4) and (Node4.PropName = 'file-label') then
                            begin
                              NodeLabel := Node4.PropDisplayValue;
                            end;
                            // Collect the CFURL String
                            if assigned(Node4) and (Node4.PropName = 'file-data') then
                            begin
                              NodeList4 := Node4.PropChildList;
                              if assigned(NodeList4) then
                              begin
                                for w := 0 to NodeList4.Count - 1 do
                                begin
                                  Node5 := TPropertyNode(NodeList4.items[w]);
                                  if assigned(Node5) and (Node5.PropName = '_CFURLString') then
                                  begin
                                    temp_value := '';
                                    temp_value := Node5.PropDisplayValue;
                                  end;
                                end;
                              end;
                            end;
                          end;
                          // Once tile-data node is processed, create the comment from the values collected
                          File_Comment := File_Comment + #13#10 + RPad(NodeLabel + ':', rpad_value) + (temp_value);
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACDockItems and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACDOCKITEMS_REGEX_STR, UpperFullname, '\Dock Items', Group_Folder, MACDockItemsStringList, anEntry, File_Comment,
          gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // iCloud Preferences
      if gchbMACiCloudPreferences and (RegexMatch(UpperFullname, MACICLOUDPREFERENCES_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        rpad_value := 35;
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Accounts')); // noslz
            if assigned(aParentNode) then
            begin
              // Count the number of nodes
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) then
                begin
                  // Level 2 List
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                    for y := 0 to NodeList2.Count - 1 do
                    begin
                      Node2 := TPropertyNode(NodeList2.items[y]);
                      if assigned(Node2) then
                      begin
                        NodeLabel := '';
                        NodeLabel := Node2.PropName;
                        File_Comment := File_Comment + #13#10 + RPad(NodeLabel + ':', rpad_value) + (Node2.PropDisplayValue);
                      end;
                    end;
                  File_Comment := File_Comment + #13#10;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACiCloudPreferences and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACICLOUDPREFERENCES_REGEX_STR, UpperFullname, '\iCloud Preferences', Group_Folder, MACiCloudPreferencesStringList, anEntry,
          File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
        rpad_value := 25;
      end;

      // iMessage Accounts
      if gchbMACiMessageAccounts and (RegexMatch(UpperFullname, MACIMESSAGEACCOUNTS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Accounts')); // noslz
            if assigned(aParentNode) then
            begin
              // Count the number of nodes
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) then
                begin
                  // Level 2 List
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                    for y := 0 to NodeList2.Count - 1 do
                    begin
                      Node2 := TPropertyNode(NodeList2.items[y]);
                      if assigned(Node2) then
                      begin
                        NodeLabel := '';
                        NodeLabel := Node2.PropName;
                        if (Node2.PropDisplayValue <> '') and (Length(Node2.PropDisplayValue) < 100) then
                          File_Comment := File_Comment + #13#10 + RPad(NodeLabel + ':', rpad_value) + (Node2.PropDisplayValue);
                      end;
                    end;
                  File_Comment := File_Comment + #13#10;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACiMessageAccounts and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACIMESSAGEACCOUNTS_REGEX_STR, UpperFullname, '\iMessage Accounts', Group_Folder, MACiMessageAccountsStringList, anEntry,
          File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Installed Printers
      if gchbMACInstalledPrinters and (RegexMatch(UpperFullname, MACINSTALLEDPRINTERS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = XML) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('array')); // noslz
            if assigned(aParentNode) then
            begin
              // Count the number of nodes
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              // Process the nodes
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and (Node1.PropName = 'string') and (pos('MANUFACTURER', Node1.PropValue) > 0) then // noslz
                begin
                  File_Comment := File_Comment + #13#10 + (Node1.PropDisplayValue);
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACInstalledPrinters and (aDeterminedFileDriverInfo.ShortDisplayName = XML) and RegExCheck(MACINSTALLEDPRINTERS_REGEX_STR, UpperFullname, '\Installed Printers', Group_Folder, MACInstalledPrintersStringtList, anEntry,
          File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Last Sleep
      if gchbMACLastSleep and (RegexMatch(UpperFullname, MACLASTSLEEP_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = XML) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dict')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and (Node1.PropName = 'dict') then // noslz
                begin
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                  begin
                    for z := 0 to NodeList2.Count - 1 do
                    begin
                      Node2 := TPropertyNode(NodeList2.items[z]);
                      if assigned(Node2) and (Node2.PropName = 'date') then // noslz
                      begin
                        File_Comment := File_Comment + #13#10 + (Node2.PropDisplayValue);
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACLastSleep and (aDeterminedFileDriverInfo.ShortDisplayName = XML) and RegExCheck(MACLASTSLEEP_REGEX_STR, UpperFullname, '\Last Sleep', Group_Folder, MACLastSleepStringList, anEntry, File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Login Items
      if gchbMACLoginItems and (RegexMatch(UpperFullname, MACLOGINITEMS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('CustomListItems')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                for x := 0 to NodeList1.Count - 1 do
                begin
                  Node1 := TPropertyNode(NodeList1.items[x]);
                  if assigned(Node1) and (Node1.PropName = '') then
                  begin
                    NodeList2 := Node1.PropChildList;
                    if assigned(NodeList2) then
                    begin
                      for y := 0 to NodeList2.Count - 1 do
                      begin
                        Node2 := TPropertyNode(NodeList2.items[y]);
                        if assigned(Node2) then
                        begin
                          if Node2.PropName = 'Name' then // noslz
                            File_Comment := File_Comment + #13#10 + (Node2.PropDisplayValue);
                        end;
                      end;
                    end;
                  end;
                end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACLoginItems and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACLOGINITEMS_REGEX_STR, UpperFullname, '\Login Items', Group_Folder, MACLoginItemsStringList, anEntry, File_Comment,
          gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Login Window
      if gchbMACLoginWindow and (RegexMatch(UpperFullname, MACLOGINWINDOW_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty);
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) then
                begin
                  if (Node1.PropName) = 'lastUserName' then
                    File_Comment := File_Comment + #13#10 + RPad(Node1.PropName + ':', rpad_value) + (Node1.PropDisplayValue);
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if File_Comment <> '' then { stop junk files being bookmarked }
          if gchbMACLoginWindow and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACLOGINWINDOW_REGEX_STR, UpperFullname, '\Login Window', Group_Folder, MACLoginWindowStringList, anEntry, File_Comment,
            gchbBookmarkResults) then
            TriageResults.MACFileSystem := True;
      end;

      // OSX Update
      if gchbMACOSXUpdate and (RegexMatch(UpperFullname, MACOSXUPDATE_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        rpad_value := 35;
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty);
            if assigned(aParentNode) then
            begin
              for x := 0 to aParentNode.PropChildList.Count - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(aParentNode.PropChildList.items[x]);
                if assigned(Node1) and ((Node1.PropName = 'LastSuccessfulDate') or (Node1.PropName = 'LastAttemptDate') or (Node1.PropName = 'LastResultCode') or (Node1.PropName = 'LastBackgroundCCDSuccessfulDate') or
                  (Node1.PropName = 'LastBackgroundSuccessfulDate')) then
                begin
                  NodeLabel := '';
                  NodeLabel := Node1.PropName;
                  File_Comment := File_Comment + #13#10 + RPad(NodeLabel + ':', rpad_value) + (Node1.PropDisplayValue);
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if File_Comment <> '' then { stop junk files being bookmarked }
          if gchbMACOSXUpdate and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACOSXUPDATE_REGEX_STR, UpperFullname, '\OSX Update', Group_Folder, MACOSXUpdateStringList, anEntry, File_Comment,
            gchbBookmarkResults) then
            TriageResults.MACFileSystem := True;
        rpad_value := 25;
      end;

      // PhotoBoot Recents
      if gchbMACRecentPhotoBooth and (RegexMatch(UpperFullname, MACRECENTPHOTOBOOTH_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = XML) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('array')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and (Node1.PropName = 'string') then // noslz
                begin
                  File_Comment := File_Comment + #13#10 + (Node1.PropDisplayValue);
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACRecentPhotoBooth and (aDeterminedFileDriverInfo.ShortDisplayName = XML) and RegExCheck(MACRECENTPHOTOBOOTH_REGEX_STR, UpperFullname, '\Recent Photo Booth', Group_Folder, MACRecentPhotoBoothStringList, anEntry,
          File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Recent Applications
      if gchbMACRecentApplications and (RegexMatch(UpperFullname, MACRECENTAPPLICATIONS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        gnodefrog_str := '';
        NodeLabel := '';
        File_Comment := '';
        aPropertyTree := nil;
        if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
        begin
          aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('RecentApplications')); // noslz
          if assigned(aParentNode) then
            nodefrog(aParentNode, 0);
        end;
        if gnodefrog_str <> '' then
          if gchbMACRecentApplications and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACRECENTAPPLICATIONS_REGEX_STR, UpperFullname, '\Recent Applications', Group_Folder, MACRecentApplicationsStringList,
            anEntry, gnodefrog_str, gchbBookmarkResults) then
            TriageResults.MACFileSystem := True;
        if aPropertyTree <> nil then
          aPropertyTree.free;
      end;

      // Recent Documents
      if gchbMACRecentDocuments and (RegexMatch(UpperFullname, MACRECENTDOCUMENTS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        gnodefrog_str := '';
        NodeLabel := '';
        File_Comment := '';
        aPropertyTree := nil;
        if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
        begin
          aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('RecentDocuments')); // noslz
          if assigned(aParentNode) then
            nodefrog(aParentNode, 0);
        end;
        if gnodefrog_str <> '' then
          if gchbMACRecentDocuments and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACRECENTDOCUMENTS_REGEX_STR, UpperFullname, '\Recent Documents', Group_Folder, MACRecentDocumentsStringList, anEntry,
            gnodefrog_str, gchbBookmarkResults) then
            TriageResults.MACFileSystem := True;
        if aPropertyTree <> nil then
          aPropertyTree.free;
      end;

      // Recent Hosts
      if gchbMACRecentHosts and (RegexMatch(UpperFullname, MACRECENTHOSTS_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Hosts')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and (Node1.PropName = 'CustomListItems') then
                begin
                  // Level 2 List
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                    for y := 0 to NodeList2.Count - 1 do
                    begin
                      Node2 := TPropertyNode(NodeList2.items[y]);
                      if assigned(Node2) and (Node2.PropName = '') then
                      begin
                        // Level 3 List
                        NodeList3 := Node2.PropChildList;
                        if assigned(NodeList3) then
                          for z := 0 to NodeList3.Count - 1 do
                          begin
                            Node3 := TPropertyNode(NodeList3.items[z]);
                            if assigned(Node3) and (UpperCase(Node3.PropName) = UpperCase('NAME')) then // noslz
                            begin
                              File_Comment := File_Comment + #13#10 + (Node3.PropDisplayValue);
                            end;
                          end;
                      end;
                    end;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if File_Comment <> '' then
          if gchbMACRecentHosts and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACRECENTHOSTS_REGEX_STR, UpperFullname, '\Recent Hosts', Group_Folder, MACRecentHostsStringList, anEntry, File_Comment,
            gchbBookmarkResults) then
            TriageResults.MACFileSystem := True;
      end;

      // System Version
      if gchbMACSystemVersion and (RegexMatch(UpperFullname, MACSYSTEMVERSION_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = XML) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('dict')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              begin
                for x := 0 to NumberOfNodes - 1 do
                begin
                  if Not Progress.isRunning then
                    Break;
                  Node1 := TPropertyNode(NodeList1.items[x]);
                  if assigned(Node1) and (Node1.PropName = 'key') then // noslz
                  begin
                    if x + 1 <= NumberOfNodes - 1 then
                    begin
                      if (Node1.PropValue) = 'ProductBuildVersion' then
                      begin
                        Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                        File_Comment := File_Comment + #13#10 + RPad(Node1.PropValue + ':', rpad_value) + (Node1Next.PropDisplayValue);
                      end;
                      if (Node1.PropValue) = 'ProductCopyright' then
                      begin
                        Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                        File_Comment := File_Comment + #13#10 + RPad(Node1.PropValue + ':', rpad_value) + (Node1Next.PropDisplayValue);
                      end;
                      if (Node1.PropValue) = 'ProductName' then
                      begin
                        Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                        File_Comment := File_Comment + #13#10 + RPad(Node1.PropValue + ':', rpad_value) + (Node1Next.PropDisplayValue);
                      end;
                      if (Node1.PropValue) = 'ProductVersion' then
                      begin
                        Node1Next := TPropertyNode(NodeList1.items[x + 1]);
                        File_Comment := File_Comment + #13#10 + RPad(Node1.PropValue + ':', rpad_value) + (Node1Next.PropDisplayValue);
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACSystemVersion and (aDeterminedFileDriverInfo.ShortDisplayName = XML) and RegExCheck(MACSYSTEMVERSION_REGEX_STR, UpperFullname, '\System Version', Group_Folder, MACSystemVersionStringList, anEntry, File_Comment,
          gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Safari Preferences
      if gchbMACSafariPreferences and (RegexMatch(UpperFullname, MACSAFARIPREFERENCES_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            Node1 := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('DownloadsPath')); // noslz
            if assigned(Node1) then
            begin
              if (Node1.PropName) = 'DownloadsPath' then
              begin
                File_Comment := File_Comment + #13#10 + RPad(Node1.PropName + ':', rpad_value) + (Node1.PropValue);
              end;
            end;
            Node1 := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('HomePage')); // noslz
            if assigned(Node1) then
            begin
              if (Node1.PropName) = 'HomePage' then
              begin
                File_Comment := File_Comment + #13#10 + RPad(Node1.PropName + ':', rpad_value) + (Node1.PropValue);
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACSafariPreferences and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACSAFARIPREFERENCES_REGEX_STR, UpperFullname, '\Safari Preferences', Group_Folder, MACSafariPreferencesStringList, anEntry,
          File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

      // Safari Recent Searches
      if gchbMACSafariRecentSearches and (RegexMatch(UpperFullname, MACSAFARIRECENTSEARCHES_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('RecentWebSearches')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                if assigned(Node1) and (Node1.PropName = '') then
                begin
                  NodeList2 := Node1.PropChildList;
                  if assigned(NodeList2) then
                    if NodeList2.Count = 2 then
                    begin
                      for y := 0 to NodeList2.Count - 1 do
                      begin
                        if Not Progress.isRunning then
                          Break;
                        Node2 := TPropertyNode(NodeList2.items[y]);
                        if assigned(Node2) then
                        begin
                          if Node2.PropName = 'SearchString' then
                          begin
                            temp_value := '';
                            temp_value2 := '';
                            temp_value := Node2.PropValue;
                            temp_value2 := TPropertyNode(NodeList2.items[y + 1]).PropValue;
                            File_Comment := File_Comment + #13#10 + RPad(temp_value2 + ':', rpad_value) + (temp_value);
                          end;
                        end;
                      end;
                    end;
                end;
              end;
            end;
            if File_Comment <> '' then
              if gchbMACSafariRecentSearches and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACSAFARIRECENTSEARCHES_REGEX_STR, UpperFullname, '\Safari Recent Searches', Group_Folder,
                MACSafariRecentSearchesStringList, anEntry, File_Comment, gchbBookmarkResults) then
                TriageResults.MACFileSystem := True;
          end; { recentwebsearches }
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
      end;

      // TimeZone
      if gchbMACTimeZone and (RegexMatch(UpperFullname, MACTIMEZONE_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('com.apple.preferences.timezone.selected_city')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              begin
                for x := 0 to NumberOfNodes - 1 do
                begin
                  if Not Progress.isRunning then
                    Break;
                  Node1 := TPropertyNode(NodeList1.items[x]);
                  if assigned(Node1) then
                  begin
                    if Node1.PropName = 'TimeZoneName' then // noslz
                      File_Comment := File_Comment + #13#10 + RPad(Node1.PropName + ':', rpad_value) + (Node1.PropDisplayValue);
                    if Node1.PropName = 'CountryCode' then
                      File_Comment := File_Comment + #13#10 + RPad(Node1.PropName + ':', rpad_value) + (Node1.PropDisplayValue);
                    if Node1.PropName = 'Name' then // noslz
                      File_Comment := File_Comment + #13#10 + RPad(Node1.PropName + ':', rpad_value) + (Node1.PropDisplayValue);
                  end;
                end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if File_Comment <> '' then
          if gchbMACTimeZone and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACTIMEZONE_REGEX_STR, UpperFullname, '\Time Zone MAC', Group_Folder, MACTimeZoneStringList, anEntry, File_Comment,
            gchbBookmarkResults) then
            TriageResults.MACFileSystem := True;
      end;

      // TimeZoneLocal
      if gchbMACTimeZoneLocal and (RegexMatch(UpperFullname, MACTIMEZONELOCAL_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = 'Text') and (anEntry.LogicalSize < 64) then // noslz
      begin
        if aReader.OpenData(anEntry) then
        begin
          ByteCount := aReader.Read(ByteArray[1], anEntry.LogicalSize);
          if ByteCount > 0 then // We have read at least 1 byte or more.
          begin
            aReader.Position := 0;
            File_Comment := aReader.AsPrintableChar(ByteCount);
          end;
          if gchbMACTimeZoneLocal and (aDeterminedFileDriverInfo.ShortDisplayName = 'Text') and RegExCheck(MACTIMEZONELOCAL_REGEX_STR, UpperFullname, '\Time Local', Group_Folder, MACTimeZoneLocalStringList, anEntry, File_Comment,
            gchbBookmarkResults) then
            TriageResults.MACFileSystem := True; // noslz
        end;
      end;

      // Wifi
      if gchbMACWifi and (RegexMatch(UpperFullname, MACWIFI_REGEX_STR, False)) and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) then
      begin
        if aReader.OpenData(anEntry) then
        begin
          NodeLabel := '';
          File_Comment := '';
          aPropertyTree := nil;
          if ProcessMetadataProperties(anEntry, aPropertyTree, aReader) then
          begin
            aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('values')); // noslz
            if assigned(aParentNode) then
            begin
              NodeList1 := aParentNode.PropChildList;
              if assigned(NodeList1) then
                NumberOfNodes := NodeList1.Count
              else
                NumberOfNodes := 0;
              for x := 0 to NumberOfNodes - 1 do
              begin
                if Not Progress.isRunning then
                  Break;
                if Not Progress.isRunning then
                  Break;
                Node1 := TPropertyNode(NodeList1.items[x]);
                NodeList2 := Node1.PropChildList;
                if assigned(NodeList2) then
                  for y := 0 to NodeList2.Count - 1 do
                  begin
                    if Not Progress.isRunning then
                      Break;
                    Node2 := TPropertyNode(NodeList2.items[y]);
                    if assigned(Node2) and (Node2.PropName = 'value') then // noslz
                    begin
                      NodeList3 := Node2.PropChildList;
                      if assigned(NodeList3) then
                        for z := 0 to NodeList3.Count - 1 do
                        begin
                          if Not Progress.isRunning then
                            Break;
                          // Get the value nodes for each wifi network
                          Node3 := TPropertyNode(NodeList3.items[z]);
                          if assigned(Node3) then
                            try
                              if (Node3.PropValue <> null) then
                                File_Comment_StringList.Add(RPad(Node3.PropName + ':', rpad_value) + (Node3.PropDisplayValue));
                            except
                              Progress.Log(ATRY_EXCEPT_STR + 'Node3');
                            end;
                        end;
                      File_Comment_StringList.Sort;
                      File_Comment := File_Comment + File_Comment_StringList.Text + #13#10;
                      File_Comment_StringList.Clear;
                    end;
                  end;
              end;
            end;
          end;
          if aPropertyTree <> nil then
            aPropertyTree.free;
        end;
        if gchbMACWifi and (aDeterminedFileDriverInfo.ShortDisplayName = PLIST_BINARY) and RegExCheck(MACWIFI_REGEX_STR, UpperFullname, '\Wifi', Group_Folder, MACWifiStringList, anEntry, File_Comment, gchbBookmarkResults) then
          TriageResults.MACFileSystem := True;
      end;

    finally
      aReader.free; { frees for MAC only }
    end;

    // Other
    if gchbMACiMessageChat and (aDeterminedFileDriverInfo.ShortDisplayName = 'SMS iOS v4') and RegExCheck(MACIMESSAGECHAT_REGEX_STR, UpperFullname, '\iMessage Chat', Group_Folder, MACiMessageChatStringList, anEntry, File_Comment,
      gchbBookmarkResults) then
      TriageResults.MACFileSystem := True;
    if gchbMACInstallationTime and (aDeterminedFileDriverInfo.ShortDisplayName = '') and RegExCheck(MACINSTALLATIONTIME_REGEX_STR, UpperFullname, '\Installation Date', Group_Folder, MACInstallationTimeStringList, anEntry,
      datetimetostr(anEntry.Modified), gchbBookmarkResults) then
      TriageResults.MACFileSystem := True;
    if gchbMACMailFolder and (aDeterminedFileDriverInfo.ShortDisplayName = '') and RegExCheck(MACMAILFOLDER_REGEX_STR, UpperFullname, '\Mail Folder', Group_Folder, MACMailFolderStringList, anEntry, anEntry.EntryName, gchbBookmarkResults)
    then
      TriageResults.MACFileSystem := True;
  end;

  // PASSWORDS ==============================================================
  Group_Folder := 'Passwords';
  temp_regex_str := '';
  if gchbPasswords_RoboForm then
    temp_regex_str := temp_regex_str + ORR + PASSWORDSROBOFORM_REGEX_STR;
  delete(temp_regex_str, 1, 1); // do not have a leading OR '|'
  if (RegexMatch(UpperFullname, temp_regex_str, False)) then
  begin
    if gchbPasswords_RoboForm and POSCheck('ROBOFORM\IDENTITIES.EXE', UpperFullname, '\RoboForm', Group_Folder, RoboFormStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Passwords := True;
    if gchbPasswords_RoboForm and POSCheck('.RFP', UpperFullname, '\RoboForm', Group_Folder, RoboFormPasswordStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.Passwords := True;
  end;

  // PORNOGRAPHY ============================================================
  Group_Folder := 'Pornography';
  if gchbPorn and RegExCheck(PORN_REGEX_STR, UpperFullname, '\File Names', Group_Folder, PornStringList, anEntry, File_Comment, gchbBookmarkResults) then
    TriageResults.Porn := True;
  if gchbPornCAM and RegExCheck(PORNCAM_REGEX_STR, UpperFullname, '\File Names', Group_Folder, PornCAMStringList, anEntry, File_Comment, gchbBookmarkResults) then
    TriageResults.PornCAM := True;

  // SocialMedia ===================================================================
  Group_Folder := 'Social Media';
  temp_regex_str := '';
  if gchbSocialMedia_ByLock then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIABYLOCK_REGEX_STR;
  if gchbSocialMedia_Digsby then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIADIGSBY_REGEX_STR;
  if gchbSocialMedia_ICQ then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAICQ_REGEX_STR;
  if gchbSocialMedia_MSNMessenger then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAMSNMESSENGER_REGEX_STR;
  if gchbSocialMedia_PalTalk then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAPALTALK_REGEX_STR;
  if gchbSocialMedia_Pidgin then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAPIDGIN_REGEX_STR;
  if gchbSocialMedia_Trillian then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIATRILLIAN_REGEX_STR;
  if gchbSocialMedia_YahooMessenger then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAYAHOOMESSENGER_REGEX_STR;
  if gchbSocialMedia_Camfrog then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIACAMFROG_REGEX_STR;
  if gchbSocialMedia_Skype then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIASKYPE_REGEX_STR;
  if gchbSocialMedia_iMessage then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAIMESSAGE_REGEX_STR;
  if gchbSocialmedia_WhatsApp then
    temp_regex_str := temp_regex_str + ORR + SOCIALMEDIAWHATSAPP_REGEX_STR;
  if gchbSocialMedia_WindowsFaceBookApp then
    temp_regex_str := temp_regex_str + ORR + 'FRIENDREQUESTS\.SQLITE$';
  if gchbSocialMedia_WindowsFaceBookApp then
    temp_regex_str := temp_regex_str + ORR + 'FRIENDS\.SQLITE$';
  if gchbSocialMedia_WindowsFaceBookApp then
    temp_regex_str := temp_regex_str + ORR + 'MESSAGES\.SQLITE$';
  if gchbSocialMedia_WindowsFaceBookApp then
    temp_regex_str := temp_regex_str + ORR + 'NOTIFICATIONS\.SQLITE$';
  if gchbSocialMedia_WindowsFaceBookApp then
    temp_regex_str := temp_regex_str + ORR + 'STORIES\.SQLITE$';
  delete(temp_regex_str, 1, 1); // do not have a leading OR '|'
  if (RegexMatch(UpperFullname, temp_regex_str, False)) then
  begin
    if gchbSocialMedia_ByLock and POSCheck(SOCIALMEDIABYLOCK_REGEX_STR, UpperFullname, '\ByLock', Group_Folder, ByLockStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_Digsby and POSCheck(SOCIALMEDIADIGSBY_REGEX_STR, UpperFullname, '\Digsby', Group_Folder, DigsbyStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_ICQ and POSCheck(SOCIALMEDIAICQ_REGEX_STR, UpperFullname, '\ICQ', Group_Folder, ICQStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_MSNMessenger and POSCheck(SOCIALMEDIAMSNMESSENGER_REGEX_STR, UpperFullname, '\MSN Messenger', Group_Folder, MSNMessengerStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_PalTalk and POSCheck(SOCIALMEDIAPALTALK_REGEX_STR, UpperFullname, '\Paltalk', Group_Folder, PaltalkStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_Pidgin and POSCheck(SOCIALMEDIAPIDGIN_REGEX_STR, UpperFullname, '\Pidgin', Group_Folder, PidginStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_Trillian and POSCheck(SOCIALMEDIATRILLIAN_REGEX_STR, UpperFullname, '\Trillian', Group_Folder, TrillianStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_YahooMessenger and POSCheck(SOCIALMEDIAYAHOOMESSENGER_REGEX_STR, UpperFullname, '\Yahoo Messenger', Group_Folder, YahooMessengerStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_Camfrog and POSCheck(SOCIALMEDIACAMFROG_REGEX_STR, UpperFullname, '\CamFrog', Group_Folder, CamFrogStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_Skype and RegExCheck(SOCIALMEDIASKYPE_REGEX_STR, UpperFullname, '\Skype', Group_Folder, SkypeStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_iMessage and RegExCheck(SOCIALMEDIAIMESSAGE_REGEX_STR, UpperFullname, '\IMessage', Group_Folder, iMessageStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialmedia_WhatsApp and RegExCheck(SOCIALMEDIAWHATSAPP_REGEX_STR, UpperFullname, '\WhatsApp', Group_Folder, WhatsAppStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_WindowsFaceBookApp and POSCheck('FRIENDREQUESTS.SQLITE', UpperFullname, '\Facebook.Facebook_8xx8rvfyw5nnt', Group_Folder, WindowsFacebookAppStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_WindowsFaceBookApp and POSCheck('FRIENDS.SQLITE', UpperFullname, '\Facebook.Facebook_8xx8rvfyw5nnt', Group_Folder, WindowsFacebookAppStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_WindowsFaceBookApp and POSCheck('MESSAGES.SQLITE', UpperFullname, '\Facebook.Facebook_8xx8rvfyw5nnt', Group_Folder, WindowsFacebookAppStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_WindowsFaceBookApp and POSCheck('NOTIFICATIONS.SQLITE', UpperFullname, '\Facebook.Facebook_8xx8rvfyw5nnt', Group_Folder, WindowsFacebookAppStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
    if gchbSocialMedia_WindowsFaceBookApp and POSCheck('STORIES.SQLITE', UpperFullname, '\Facebook.Facebook_8xx8rvfyw5nnt', Group_Folder, WindowsFacebookAppStringList, anEntry, File_Comment, gchbBookmarkResults) then
      TriageResults.SocialMedia := True;
  end;

  // SHADOW COPY ============================================================
  Group_Folder := 'Shadow Copy';
  if gchbWindows_ShadowCopy then
    TriageResults.ShadowCopy := POSCheck(UpperCase(SHADOWCOPY_REGEX_STR), UpperFullname, '', Group_Folder, ShadowCopyStringList, anEntry, File_Comment, gchbBookmarkResults);

  // WINDOWS USERS ==================================================================
  Group_Folder := (WINDOWS_USER_FOLDERS);
  if gchbWindows_UserAccounts then
  begin
    if anEntry.IsDirectory then
    begin
      if (RegexMatch(anEntry.FullPathName, WINDOWSUSERS_REGEX_STR, False)) then
      begin
        TriageResults.Category_Windows_Users := True;
        UsersStringList.AddObject('     *' + anEntry.FullPathName, anEntry);
        Item_Folder := ''; // Leave blank - no subgroup required
        FoundCount := FoundCount + 1;
        if gchbBookmarkResults then
          BookMark_Create(Group_Folder, Item_Folder, '', anEntry, File_Comment, True);
      end;
    end;
  end;

  // WINDOWS VERSION ===========================================================
  Group_Folder := (WINDOWS_VERSION);
  // 64bit
  if gchbWindows_32or64bit then
  begin
    if anEntry.IsDirectory then
    begin
      if (RegexMatch(anEntry.FullPathName, WINDOWSVERSION_REGEX_STR, False)) then
      begin
        TriageResults.Category_Windows_Version := True;
        if pos('x86', anEntry.FullPathName) > 0 then
        begin
          TriageResults.Windows64bit := True;
          Windows64bitStringList.AddObject('     *' + anEntry.FullPathName, anEntry);
          Item_Folder := ''; // Leave blank - no subgroup required
          FoundCount := FoundCount + 1;
          if gchbBookmarkResults then
            BookMark_Create(Group_Folder, Item_Folder, '', anEntry, File_Comment, True);
        end;
      end;
    end;
  end;

  // WIPING TOOLS ==============================================================
  Group_Folder := ('Wiping Tools');

  if gchbWipingTools_BCWipe or gchbWipingTools_CCleaner or gchbWipingTools_DiskWipe or gchbWipingTools_Eraser or gchbWipingTools_Privazer or gchbWipingTools_Other then
  begin
    temp_regex_str := 'bitkiller' + ORR + 'bleachbit' + ORR + 'cbl.?data.?shredder' + ORR + 'ccleaner' + ORR + 'copy.?wipe' + ORR + 'data.?eraser' + ORR + 'data.?shredder' + ORR + 'data.?wiper' + ORR + 'delete.?on.?click' + ORR +
      'disk.?wipe' + ORR + 'drive.?wipe' + ORR + 'eraser\.exe' + ORR + 'file.?secure' + ORR + 'file.?shredder' + ORR + 'freeraser' + ORR + 'hard.?erase' + ORR + 'hard.?drive.?eraser' + ORR + 'hard.?wipe' + ORR + 'hd.?shredder' + ORR +
      'kill.?disk' + ORR + 'mhdd\.exe' + ORR + 'pc.?disk.?eraser' + ORR + 'pc.?shredder' + ORR + 'privazer' + ORR + 'sdelete' + ORR + 'secure.?delete' + ORR + 'secure.?eraser' + ORR + 'secure.?wiper' + ORR + 'wipe.?disk' + ORR +
      'wise.?care.?365';

    temp_regex_str2 := StringReplace(temp_regex_str, '|', #13#10, [rfReplaceAll]);

    temp_regex_StringList := TStringList.Create;
    temp_regex_StringList.Text := temp_regex_str2;

    if (RegexMatch(UpperFullname, temp_regex_str, False)) then
    begin
      if gchbWipingTools_BCWipe and RegExCheck('\\BCWIPE.EXE$', UpperFullname, '\BCWipe', Group_Folder, BCWipeStringList, anEntry, File_Comment, gchbBookmarkResults) then
        TriageResults.Wiping := True
      else if gchbWipingTools_CCleaner and RegExCheck('\\CCLEANER.EXE$', UpperFullname, '\CCLeaner', Group_Folder, CCleanerStringList, anEntry, File_Comment, gchbBookmarkResults) then
        TriageResults.Wiping := True
      else if gchbWipingTools_DiskWipe and RegExCheck('\\DISKWIPE.EXE$', UpperFullname, '\DiskWipe', Group_Folder, DiskWipeStringList, anEntry, File_Comment, gchbBookmarkResults) then
        TriageResults.Wiping := True
      else if gchbWipingTools_Eraser and RegExCheck('\\ERASER.EXE$', UpperFullname, '\Eraser', Group_Folder, EraserStringList, anEntry, File_Comment, gchbBookmarkResults) then
        TriageResults.Wiping := True
      else if gchbWipingTools_Privazer and RegExCheck('\\PRIVAZER.EXE$', UpperFullname, '\Privazer', Group_Folder, PrivazerStringList, anEntry, File_Comment, gchbBookmarkResults) then
        TriageResults.Wiping := True
      else if gchbWipingTools_Other then
      begin
        for t := 0 to temp_regex_StringList.Count - 1 do
        begin
          aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
          if (aDeterminedFileDriverInfo.ShortDisplayName = 'EXE/DLL') then
          begin
            if (temp_regex_StringList.Count > 1) and RegExCheck(temp_regex_StringList[t], UpperFullname, '\Other Wiping Tool Files', Group_Folder, OtherWipeStringList, anEntry, File_Comment, gchbBookmarkResults) then
              TriageResults.Wiping := True;
          end;
        end;
      end;
    end;
    temp_regex_StringList.free;
  end;
end;

function MakeList(incomingReg: string): TList;
var
  Re: TDIPerlRegEx;
  match_str: string;
  anEntry: TEntry;
  i: integer;
  FoundList, AllFoundList: TList;
  FindEntries_StringList: TStringList;
  AllFoundListUnique: TUniqueListOfEntries;
  Enum: TEntryEnumerator;
  FileSystem_DataStore: TDataStore;
  anEntryList: TDataStore;
begin
  // ============================================================================
  // Find entries by path and add to a list
  // **\*                        Finds all files.
  // **\*.*                      Finds all files with an extension.
  // **\*.jpg                    Finds all .jpg files.
  // **\Penguins.jpg             Finds all files called Penguin.jpg
  // **\Penguins.*               Finds all files called Penguin with any extension.
  // **\*guins*                  Finds all files that contain guins in the filename.
  // **\Pictures\**\*            Finds all files that has folder Pictures in the path.
  // **\Pictures\**\Penguins.jpg Finds all files called Penguin.jpg that has folder Pictures in the path.

  AllFoundList := TList.Create;
  AllFoundListUnique := TUniqueListOfEntries.Create;

  if gchbPorn or gchbPornCAM then
  begin
    anEntryList := GetDataStore(DATASTORE_FILESYSTEM);
    try
      AllFoundList := anEntryList.GetEntireList;
    finally
      anEntryList.free;
    end;
    Progress.Log('Searching the File System' + RUNNING);
  end
  else
    try
      Progress.Log('Finding files by path' + RUNNING);
      FilesByCount_Tick_Count := GetTickCount64;
      FileSystem_DataStore := GetDataStore(DATASTORE_FILESYSTEM);
      FoundList := TList.Create;
      FindEntries_StringList := TStringList.Create;
      try
        FindEntries_StringList.Add('**\CLEAN');
        FindEntries_StringList.Add('**\*.db');
        FindEntries_StringList.Add('**\*.exe');
        FindEntries_StringList.Add('**\*.ost');
        FindEntries_StringList.Add('**\*.plist');
        FindEntries_StringList.Add('**\*.pst');
        FindEntries_StringList.Add('**\*.rfp');
        FindEntries_StringList.Add('**\*.sqlite*');
        FindEntries_StringList.Add('**\*3808876b-c176-4e48-b7ae-04046e6cc752*');
        FindEntries_StringList.Add('**\*cleaner*');
        FindEntries_StringList.Add('**\*delete*');
        FindEntries_StringList.Add('**\*erase*');
        FindEntries_StringList.Add('**\*shred*');
        FindEntries_StringList.Add('**\*UNALLOCATED CLUSTERS*'); // noslz
        FindEntries_StringList.Add('**\*VOLUME BOOT RECORD*'); // noslz
        FindEntries_StringList.Add('**\*wipe*');
        FindEntries_StringList.Add('**\.AppleSetupDone');
        FindEntries_StringList.Add('**\IMAP-*');
        FindEntries_StringList.Add('**\localtime');
        FindEntries_StringList.Add('**\MobileSync\**\*'); // All iTunes folder
        FindEntries_StringList.Add('**\POP-*');
        FindEntries_StringList.Add('**\Root\Program Files (x86)\');
        FindEntries_StringList.Add('**\Root\Users\*'); // Contents of the users folder

        // Find the files by path and add to AllFoundListUnique
        Progress.Initialize(FindEntries_StringList.Count, 'Find files by path' + RUNNING);
        for i := 0 to FindEntries_StringList.Count - 1 do
        begin
          if not Progress.isRunning then
            Break;
          Find_Entries_By_Path(FileSystem_DataStore, FindEntries_StringList[i], FoundList, AllFoundListUnique);
          Progress.Log(RPad('FindEntriesByPath: ' + FindEntries_StringList[i], 80) + IntToStr(FoundList.Count));
          Progress.incCurrentProgress;
        end;

        Time_Taken_int := (GetTickCount64 - FilesByCount_Tick_Count);
        Time_Taken_int := trunc(Time_Taken_int / 1000);
        Progress.Log(StringOfChar('-', CHAR_LENGTH));
        Progress.Log('FindFilesByPath Time taken = ' + IntToStr(Time_Taken_int) + ' sec ' + FormatDateTime('hh:nn:ss', Time_Taken_int / SecsPerDay));

        // Move the AllFoundListUnique list into a TList
        if assigned(AllFoundListUnique) and (AllFoundListUnique.Count > 0) then
        begin
          Enum := AllFoundListUnique.GetEnumerator;
          while Enum.MoveNext do
          begin
            anEntry := Enum.Current;
            AllFoundList.Add(anEntry);
          end;
        end;

        if assigned(AllFoundList) and (AllFoundList.Count > 0) then
        begin
          Progress.Log(StringOfChar('=', CHAR_LENGTH));
          Progress.Log('Files by path: ' + IntToStr(AllFoundList.Count));
          Progress.Log(StringOfChar('=', CHAR_LENGTH));
        end;
      finally
        FoundList.free;
        AllFoundListUnique.free;
        FindEntries_StringList.free;
      end;

    finally
      FileSystem_DataStore.free;
    end;

  // Working with AllFoundList here
  Result := TList.Create;
  if assigned(AllFoundList) and (AllFoundList.Count > 0) then
  begin
    Re := TDIPerlRegEx.Create(nil);
    try
      Progress.Initialize(AllFoundList.Count, 'Searching' + RUNNING);
      Re.CompileOptions := [coCaseLess, coUnGreedy];
      Re.MatchPattern := incomingReg;
      Progress.CurrentPosition := 0;
      Progress.Max := AllFoundList.Count;
      for i := 0 to AllFoundList.Count - 1 do
      begin
        if not Progress.isRunning then
          Break;
        anEntry := TEntry(AllFoundList[i]);
        if anEntry.isDevice or (dstPartition in anEntry.Status) then
          Result.Add(anEntry);
        match_str := UpperCase(anEntry.FullPathName);
        Re.SetSubjectStr(match_str);
        if Re.Match(0) >= 0 then
        begin
          try
            DetermineFileType(anEntry);
            Result.Add(anEntry);
          except
            Progress.Log(ATRY_EXCEPT_STR + 'Function MakeList');
            bl_error := True;
          end;
        end;
        Progress.incCurrentProgress;
      end;
    finally
      FreeAndNil(Re);
    end;
  end;
  if assigned(AllFoundList) then
    FreeAndNil(AllFoundList);
end;

procedure FindMacDrives(aList: TList);
var
  FileSystem_DataStore: TDataStore;
  i, j, k: integer;
  AEntry: TEntry;
  ChildEntry: TEntry;
  aDeterminedFileDriverInfo: TFileTypeInformation;
  DeviceDirectChildren_TList: TList;
  AddThisEntry: TEntry;
  ExistingEntry: TEntry;
  addtolist_bl: boolean;
begin
  FileSystem_DataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    for i := 0 to aList.Count - 1 do
    begin
      AEntry := TEntry(aList[i]);
      if AEntry.isDevice then
      begin
        DeviceDirectChildren_TList := FileSystem_DataStore.Children(AEntry, False); // True sets the .Children to be full recursive
        try
          for j := 0 to DeviceDirectChildren_TList.Count - 1 do
          begin
            ChildEntry := TEntry(DeviceDirectChildren_TList[j]);
            if (dstPartition in ChildEntry.Status) then
            begin
              DetermineFileType(ChildEntry);
              aDeterminedFileDriverInfo := ChildEntry.DeterminedFileDriverInfo;
              if (pos('HFS', aDeterminedFileDriverInfo.ShortDisplayName) > 0) or (pos('APFS', aDeterminedFileDriverInfo.ShortDisplayName) > 0) then
              begin
                AddThisEntry := GetDeviceEntry(ChildEntry);
                if assigned(MACDeviceList) then
                begin
                  addtolist_bl := True;
                  for k := 0 to MACDeviceList.Count - 1 do
                  begin
                    ExistingEntry := TEntry(MACDeviceList[k]);
                    if AddThisEntry = ExistingEntry then
                    begin
                      addtolist_bl := False;
                      Break; // Stops the same entry being added twice
                    end;
                  end;
                  if addtolist_bl then
                    MACDeviceList.Add(AddThisEntry);
                end;
              end;
            end;
          end;
        finally
          DeviceDirectChildren_TList.free;
        end;
      end;
    end;
  finally
    FileSystem_DataStore.free;
  end;
end;

procedure Find_Entries_By_Path(aDatastore: TDataStore; astr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);
var
  s: integer;
  fEntry: TEntry;
begin
  if assigned(aDatastore) and (aDatastore.Count > 1) then
  begin
    FoundList.Clear;
    aDatastore.FindEntriesByPath(nil, astr, FoundList);
    for s := 0 to FoundList.Count - 1 do
    begin
      fEntry := TEntry(FoundList[s]);
      AllFoundListUnique.Add(fEntry);
    end;
  end;
end;

// ******************************************************************************
// This is the main procedure called after the 'Run' button is clicked
// ******************************************************************************
procedure MainProc;
var
  i, j, k, x, y: integer;
  matchedEntry: TEntry; // the individual entry (i.e. file in the filesystem)
  TriageResults: TTriageResults;
  templist: TList;
  Evidence_EntryList: TDataStore;
  aDeviceEntry: TEntry;

begin
  Starting_Tick_Count := GetTickCount64;

  Evidence_EntryList := GetDataStore(DATASTORE_EVIDENCE);
  if not assigned(Evidence_EntryList) then
  begin
    ConsoleLog(DATASTORE_EVIDENCE + ' module not located.' + SPACE + TSWT);
    Exit;
  end;

  // ============================================================================
  // Device List - Add the evidence items
  // ============================================================================
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Device list:');
  DeviceList := TList.Create;
  aDeviceEntry := Evidence_EntryList.First; // Get the first entry
  i := 0;
  while assigned(aDeviceEntry) and Progress.isRunning do
  begin
    inc(i);
    Progress.CurrentPosition := i; // update progress bar
    if aDeviceEntry.isDevice then
    begin
      DeviceList.Add(aDeviceEntry);
      ConsoleLog(RPad(HYPHEN + 'Added to Device List:', 30) + aDeviceEntry.EntryName);
      BookMarkDevice('', '\Device', '', aDeviceEntry, '', True);
    end;
    aDeviceEntry := Evidence_EntryList.Next;
  end;
  ConsoleLog(RPad('Device list count:', 30) + IntToStr(DeviceList.Count));

  // Find the MAC drives
  MACDeviceList := TList.Create;
  if assigned(DeviceList) and (DeviceList.Count > 0) then
    FindMacDrives(DeviceList);

  // ============================================================================
  // Devices to Search List - Add evidence items sent from the triage
  // ============================================================================
  DeviceToSearchList := TList.Create;

  if (CmdLine.ParamCount > 0) and bl_EvidenceModule then
  begin
    ConsoleLog((StringOfChar('-', CHAR_LENGTH)));

    // Create the DeviceToSearchList
    for x := 0 to CmdLine.ParamCount - 1 do
    begin
      if Not Progress.isRunning then
        Break;
      ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
      if assigned(DeviceList) and (DeviceList.Count > 0) then
      begin
        for y := 0 to DeviceList.Count - 1 do
        begin
          DeviceListEntry := TEntry(DeviceList.items[y]);
          if (DeviceListEntry.EntryName = CmdLine.params[x]) then
          begin
            DeviceToSearchList.Add(DeviceListEntry);
            ConsoleLog(RPad('Added to Device Search List:', 30) + DeviceListEntry.EntryName);
            Break;
          end;
        end;
      end;
    end;
  end
  else
  begin
    ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
    ConsoleLog('Searching ALL devices:');
    for y := 0 to DeviceList.Count - 1 do
    begin
      DeviceListEntry := TEntry(DeviceList.items[y]);
      ConsoleLog(RPad(HYPHEN + 'Searching:', 30) + DeviceListEntry.EntryName);
    end;
  end;

  FoundCount := 0;

  if bl_AutoBookmark_Results then
    gchbBookmarkResults := True;

  if gchbBookmarkResults = False then
    bl_AutoBookmark_Results := False;

  if gchbBookmarkResults then
    ConsoleLog(RPad('Bookmark results.', 30) + 'Yes')
  else
    ConsoleLog(RPad('Bookmark results.', 30) + 'No');

  gchbBookmarkResults := True;
  gchbBrowsers_Chrome := True;
  gchbBrowsers_Firefox := True;
  gchbBrowsers_InternetExplorer := True;
  gchbBrowsers_Opera := True;
  gchbBrowsers_Safari := True;
  gchbBrowsers_Tor := True;
  gchbDevices_DeviceSizes := True;
  gchbEmail_OST := True;
  gchbEmail_Outlook := True;
  gchbEmail_OutlookExpress := True;
  gchbEmail_PST := True;
  gchbEmail_Thunderbird := True;
  gchbFileShare_Dropbox := True;
  gchbFileShare_Mediafire := True;
  gchbIdentifyingFiles := True;
  gchbiTunesBackup := True;
  gchbMACAddressBookMe := True;
  gchbMACAttachediDevices := True;
  gchbMACBluetooth := True;
  gchbMACDockItems := True;
  gchbMACiCloudPreferences := True;
  gchbMACiMessageAccounts := True;
  gchbMACiMessageChat := True;
  gchbMACInstallationTime := True;
  gchbMACInstalledPrinters := True;
  gchbMACLastSleep := True;
  gchbMACLoginItems := True;
  gchbMACLoginWindow := True;
  gchbMACMailFolder := True;
  gchbMACOSXUpdate := True;
  gchbMACRecentApplications := True;
  gchbMACRecentDocuments := True;
  gchbMACRecentHosts := True;
  gchbMACRecentPhotoBooth := True;
  gchbMACSafariPreferences := True;
  gchbMACSafariRecentSearches := True;
  gchbMACSystemVersion := True;
  gchbMACTimeZone := True;
  gchbMACTimeZoneLocal := True;
  gchbMACWifi := True;
  gchbPasswords_RoboForm := True;
  gchbPorn := False;
  gchbPornCAM := False;
  gchbSelectDeselectALL := True;
  gchbSelectDeselectAllBrowsers := True;
  gchbSelectDeselectALLMAC := True;
  gchbSelectDeselectAllSocialMeda := True;
  gchbSelectDeselectAllWipingTools := True;
  gchbSocialMedia_ByLock := True;
  gchbSocialMedia_Camfrog := True;
  gchbSocialMedia_Digsby := True;
  gchbSocialMedia_ICQ := True;
  gchbSocialMedia_iMessage := True;
  gchbSocialMedia_MSNMessenger := True;
  gchbSocialMedia_PalTalk := True;
  gchbSocialMedia_Pidgin := True;
  gchbSocialMedia_Skype := True;
  gchbSocialMedia_Trillian := True;
  gchbSocialmedia_WhatsApp := True;
  gchbSocialMedia_WindowsFaceBookApp := True;
  gchbSocialMedia_YahooMessenger := True;
  gchbWindows_32or64bit := True;
  gchbWindows_ShadowCopy := True;
  gchbWindows_UserAccounts := True;
  gchbWipingTools_BCWipe := True;
  gchbWipingTools_CCleaner := True;
  gchbWipingTools_DiskWipe := True;
  gchbWipingTools_Eraser := True;
  gchbWipingTools_Other := True;
  gchbWipingTools_Privazer := True;

  // Create String Lists
  BCWipeStringList := TStringList.Create;
  ByLockStringList := TStringList.Create;
  CamFrogStringList := TStringList.Create;
  CCleanerStringList := TStringList.Create;
  ChromeStringList := TStringList.Create;
  DevicePartitionInfoStringList := TStringList.Create;
  DigsbyStringList := TStringList.Create;
  DiskWipeStringList := TStringList.Create;
  DropBoxStringList := TStringList.Create;
  EraserStringList := TStringList.Create;
  File_Comment_StringList := TStringList.Create;
  FireFoxStringList := TStringList.Create;
  ICQStringList := TStringList.Create;
  iMessageStringList := TStringList.Create;
  InternetExplorerStringList := TStringList.Create;
  iTunesBackupStringList := TStringList.Create;
  iTunesBackupStringList.Duplicates := dupignore;
  MACAddressBookMeStringList := TStringList.Create;
  MACAttachediDevicesStringList := TStringList.Create;
  MACBlueToothStringList := TStringList.Create;
  MACDockItemsStringList := TStringList.Create;
  MACiCloudPreferencesStringList := TStringList.Create;
  MACiMessageAccountsStringList := TStringList.Create;
  MACiMessageChatStringList := TStringList.Create;
  MACInstallationTimeStringList := TStringList.Create;
  MACInstalledPrintersStringtList := TStringList.Create;
  MACLastSleepStringList := TStringList.Create;
  MACLoginItemsStringList := TStringList.Create;
  MACLoginWindowStringList := TStringList.Create;
  MACMailFolderStringList := TStringList.Create;
  MACOSXUpdateStringList := TStringList.Create;
  MACRecentApplicationsStringList := TStringList.Create;
  MACRecentDocumentsStringList := TStringList.Create;
  MACRecentHostsStringList := TStringList.Create;
  MACRecentPhotoBoothStringList := TStringList.Create;
  MACSafariPreferencesStringList := TStringList.Create;
  MACSafariRecentSearchesStringList := TStringList.Create;
  MACSystemVersionStringList := TStringList.Create;
  MACTimeZoneLocalStringList := TStringList.Create;
  MACTimeZoneStringList := TStringList.Create;
  MACWifiStringList := TStringList.Create;
  MediaFireStringList := TStringList.Create;
  MSNMessengerStringList := TStringList.Create;
  OperaStringList := TStringList.Create;
  OSTStringList := TStringList.Create;
  OtherWipeStringList := TStringList.Create;
  OutlookStringList := TStringList.Create;
  PaltalkStringList := TStringList.Create;
  PidginStringList := TStringList.Create;
  PornStringList := TStringList.Create;
  PornCAMStringList := TStringList.Create;
  PrivazerStringList := TStringList.Create;
  PSTStringList := TStringList.Create;
  RoboFormPasswordStringList := TStringList.Create;
  RoboFormStringList := TStringList.Create;
  SafariStringList := TStringList.Create;
  ShadowCopyStringList := TStringList.Create;
  SkypeStringList := TStringList.Create;
  ThunderbirdStringList := TStringList.Create;
  TorStringList := TStringList.Create;
  TrillianStringList := TStringList.Create;
  UsersStringList := TStringList.Create;
  WhatsAppStringList := TStringList.Create;
  Windows64bitStringList := TStringList.Create;
  WindowsFacebookAppStringList := TStringList.Create;
  YahooMessengerStringList := TStringList.Create;

  ZeroMemory(@TriageResults, SizeOf(TTriageResults));

  // update console display
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  Progress.DisplayTitle := SCRIPT_NAME;

  // ============================================================================
  // One Big Regex
  // ============================================================================
  OneBigRegex_str := '';
  // Browsers
  if gchbBrowsers_Firefox then
    OneBigRegex_str := OneBigRegex_str + ORR + BROWSERSFIREFOX_REGEX_STR;
  if gchbBrowsers_Chrome then
    OneBigRegex_str := OneBigRegex_str + ORR + BROWSERSCHROME_REGEX_STR;
  if gchbBrowsers_InternetExplorer then
    OneBigRegex_str := OneBigRegex_str + ORR + BROWSERSINTERNETEXPLORER_REGEX_STR;
  if gchbBrowsers_Opera then
    OneBigRegex_str := OneBigRegex_str + ORR + BROWSERSOPERA_REGEX_STR;
  if gchbBrowsers_Safari then
    OneBigRegex_str := OneBigRegex_str + ORR + BROWSERSSAFARI_REGEX_STR;
  if gchbBrowsers_Tor then
    OneBigRegex_str := OneBigRegex_str + ORR + BROWSERSTOR_REGEX_STR;
  // Devices
  if gchbDevices_DeviceSizes then
    OneBigRegex_str := OneBigRegex_str + ORR + DEVICESVBR_REGEX_STR;
  if gchbDevices_DeviceSizes then
    OneBigRegex_str := OneBigRegex_str + ORR + DEVICESUNALLOCATED_REGEX_STR;
  // Email
  if gchbEmail_PST then
    OneBigRegex_str := OneBigRegex_str + ORR + EMAILPST_REGEX_STR;
  if gchbEmail_OST then
    OneBigRegex_str := OneBigRegex_str + ORR + EMAILOST_REGEX_STR;
  if gchbEmail_Thunderbird then
    OneBigRegex_str := OneBigRegex_str + ORR + EMAILTHUNDERBIRD_REGEX_STR;
  if gchbEmail_Outlook then
    OneBigRegex_str := OneBigRegex_str + ORR + EMAILOUTLOOK_REGEX_STR;
  // File Share
  if gchbFileShare_Dropbox then
    OneBigRegex_str := OneBigRegex_str + ORR + FILESHAREDROPBOX_REGEX_STR;
  if gchbFileShare_Mediafire then
    OneBigRegex_str := OneBigRegex_str + ORR + FILESHAREMEDIAFIRE_REGEX_STR;
  // iTunes Backup
  if gchbiTunesBackup then
    OneBigRegex_str := OneBigRegex_str + ORR + ITUNESBACKUP_REGEX_STR;
  // MAC
  if gchbMACAddressBookMe then
    OneBigRegex_str := OneBigRegex_str + ORR + MACADDRESSBOOKME_REGEX_STR;
  if gchbMACAttachediDevices then
    OneBigRegex_str := OneBigRegex_str + ORR + MACATTACHEDIDEVICES_REGEX_STR;
  if gchbMACBluetooth then
    OneBigRegex_str := OneBigRegex_str + ORR + MACBLUETOOTH_REGEX_STR;
  if gchbMACDockItems then
    OneBigRegex_str := OneBigRegex_str + ORR + MACDOCKITEMS_REGEX_STR;
  if gchbMACiCloudPreferences then
    OneBigRegex_str := OneBigRegex_str + ORR + MACICLOUDPREFERENCES_REGEX_STR;
  if gchbMACiMessageAccounts then
    OneBigRegex_str := OneBigRegex_str + ORR + MACIMESSAGEACCOUNTS_REGEX_STR;
  if gchbMACiMessageChat then
    OneBigRegex_str := OneBigRegex_str + ORR + MACIMESSAGECHAT_REGEX_STR;
  if gchbMACInstallationTime then
    OneBigRegex_str := OneBigRegex_str + ORR + MACINSTALLATIONTIME_REGEX_STR;
  if gchbMACInstalledPrinters then
    OneBigRegex_str := OneBigRegex_str + ORR + MACINSTALLEDPRINTERS_REGEX_STR;
  if gchbMACLastSleep then
    OneBigRegex_str := OneBigRegex_str + ORR + MACLASTSLEEP_REGEX_STR;
  if gchbMACLoginItems then
    OneBigRegex_str := OneBigRegex_str + ORR + MACLOGINITEMS_REGEX_STR;
  if gchbMACLoginWindow then
    OneBigRegex_str := OneBigRegex_str + ORR + MACLOGINWINDOW_REGEX_STR;
  if gchbMACMailFolder then
    OneBigRegex_str := OneBigRegex_str + ORR + MACMAILFOLDER_REGEX_STR;
  if gchbMACOSXUpdate then
    OneBigRegex_str := OneBigRegex_str + ORR + MACOSXUPDATE_REGEX_STR;
  if gchbMACRecentApplications then
    OneBigRegex_str := OneBigRegex_str + ORR + MACRECENTAPPLICATIONS_REGEX_STR;
  if gchbMACRecentDocuments then
    OneBigRegex_str := OneBigRegex_str + ORR + MACRECENTDOCUMENTS_REGEX_STR;
  if gchbMACRecentHosts then
    OneBigRegex_str := OneBigRegex_str + ORR + MACRECENTHOSTS_REGEX_STR;
  if gchbMACRecentPhotoBooth then
    OneBigRegex_str := OneBigRegex_str + ORR + MACRECENTPHOTOBOOTH_REGEX_STR;
  if gchbMACSafariPreferences then
    OneBigRegex_str := OneBigRegex_str + ORR + MACSAFARIPREFERENCES_REGEX_STR;
  if gchbMACSafariRecentSearches then
    OneBigRegex_str := OneBigRegex_str + ORR + MACSAFARIRECENTSEARCHES_REGEX_STR;
  if gchbMACSystemVersion then
    OneBigRegex_str := OneBigRegex_str + ORR + MACSYSTEMVERSION_REGEX_STR;
  if gchbMACTimeZone then
    OneBigRegex_str := OneBigRegex_str + ORR + MACTIMEZONE_REGEX_STR;
  if gchbMACTimeZoneLocal then
    OneBigRegex_str := OneBigRegex_str + ORR + MACTIMEZONELOCAL_REGEX_STR;
  if gchbMACWifi then
    OneBigRegex_str := OneBigRegex_str + ORR + MACWIFI_REGEX_STR;
  // Passwords
  if gchbPasswords_RoboForm then
    OneBigRegex_str := OneBigRegex_str + ORR + PASSWORDSROBOFORM_REGEX_STR;
  // Pornography
  if gchbPorn then
    OneBigRegex_str := OneBigRegex_str + ORR + PORN_REGEX_STR;
  if gchbPornCAM then
    OneBigRegex_str := OneBigRegex_str + ORR + PORNCAM_REGEX_STR;
  // Social Media
  if gchbSocialMedia_ByLock then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIABYLOCK_REGEX_STR;
  if gchbSocialMedia_Digsby then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIADIGSBY_REGEX_STR;
  if gchbSocialMedia_ICQ then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAICQ_REGEX_STR;
  if gchbSocialMedia_MSNMessenger then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAMSNMESSENGER_REGEX_STR;
  if gchbSocialMedia_PalTalk then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAPALTALK_REGEX_STR;
  if gchbSocialMedia_Pidgin then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAPIDGIN_REGEX_STR;
  if gchbSocialMedia_Trillian then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIATRILLIAN_REGEX_STR;
  if gchbSocialMedia_YahooMessenger then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAYAHOOMESSENGER_REGEX_STR;
  if gchbSocialMedia_Camfrog then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIACAMFROG_REGEX_STR;
  if gchbSocialMedia_Skype then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIASKYPE_REGEX_STR;
  if gchbSocialMedia_iMessage then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAIMESSAGE_REGEX_STR;
  if gchbSocialmedia_WhatsApp then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAWHATSAPP_REGEX_STR;
  if gchbSocialMedia_WindowsFaceBookApp then
    OneBigRegex_str := OneBigRegex_str + ORR + SOCIALMEDIAWINDOWSFACEBOOKAPP_REGEX_STR;
  // Shadow Copy
  if gchbWindows_ShadowCopy then
    OneBigRegex_str := OneBigRegex_str + ORR + SHADOWCOPY_REGEX_STR;
  // Windows Users
  if gchbWindows_UserAccounts then
    OneBigRegex_str := OneBigRegex_str + ORR + WINDOWSUSERS_REGEX_STR;
  // Windows Version
  if gchbWindows_32or64bit then
    OneBigRegex_str := OneBigRegex_str + ORR + WINDOWSVERSION_REGEX_STR;
  // Wiping Tools
  if gchbWipingTools_BCWipe or gchbWipingTools_CCleaner or gchbWipingTools_DiskWipe or gchbWipingTools_Eraser or gchbWipingTools_Privazer or gchbWipingTools_Other then
    OneBigRegex_str := OneBigRegex_str + ORR + WIPINGTOOLS_REGEX_STR;

  delete(OneBigRegex_str, 1, 1); // do not have a leading OR '|'
  // ConsoleLog(OneBigRegex_str);
  templist := MakeList(OneBigRegex_str);
  ConsoleLog(IntToStr(templist.Count) + ' files were passed for additional processing.');

  // ============================================================================
  // Process the files
  // ============================================================================
  Progress.DisplayMessageNow := 'Processing files' + RUNNING;
  if assigned(templist) and (templist.Count > 0) then
    try
      if assigned(DeviceToSearchList) and (DeviceToSearchList.Count > 0) then
      begin
        Progress.Max := DeviceToSearchList.Count;
        Progress.CurrentPosition := 0;
        ConsoleLog('Device To Search List Count: ' + IntToStr(DeviceToSearchList.Count));
        for j := 0 to DeviceToSearchList.Count - 1 do
        begin
          Progress.incCurrentProgress;
          // Run procedure for devices in the DevieToSearchList
          // ConsoleLog('Processing: '+TEntry(DeviceToSearchList[j]).EntryName);
          for k := 0 to templist.Count - 1 do
          begin
            matchedEntry := TEntry(templist[k]);
            if assigned(matchedEntry) and Progress.isRunning then
            begin
              if GetDeviceEntry(matchedEntry) = TEntry(DeviceToSearchList[j]) then
                TriageFileSystemEntry(matchedEntry, TriageResults);
            end;
          end;
        end;
      end
      else
      begin
        // Run procedure for ALL devices
        Progress.Max := templist.Count;
        Progress.CurrentPosition := 0;
        ConsoleLog('Processing all devices...');
        for k := 0 to templist.Count - 1 do
        begin
          Progress.incCurrentProgress;
          matchedEntry := TEntry(templist[k]);
          if assigned(matchedEntry) and Progress.isRunning then
          begin
            TriageFileSystemEntry(matchedEntry, TriageResults);
          end;
        end;
      end;
    finally
      templist.free;
    end;

  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // CREATE THE REPORT
  // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  ConsoleLog('A triage of the File System found the following:');
  ConsoleLog(' ');

  is_installed_str := ' is installed.';
  may_be_present_str := ' may be present.';
  may_have_been_used_str := ' may have been used.';
  files_were_located_str := ' files were located.';
  folders_were_located_str := ' folders were located.';

  // REPORT - DEVICE AND PARTITION INFORMATION
  if TriageResults.Category_DevicePartitionInfo then
  begin
    ConsoleSection('DEVICE AND PARTITION INFORMATION');
    if TriageResults.DevicePartitionInfo then
    begin
      Log(DevicePartitionInfoStringList, '');
    end;
  end;

  // REPORT - BROWSERS
  if TriageResults.Browsers then
  begin
    ConsoleSection('BROWSERS');
    Log(FireFoxStringList, 'Firefox' + is_installed_str);
    Log(ChromeStringList, 'Chrome' + is_installed_str);
    Log(InternetExplorerStringList, 'Internet Explorer' + is_installed_str);
    Log(OperaStringList, 'Opera' + is_installed_str);
    Log(SafariStringList, 'Safari for Windows' + is_installed_str);
    Log(TorStringList, 'Tor' + is_installed_str);
  end;

  // REPORT - EMAIL
  If TriageResults.Email then
  begin
    ConsoleSection('EMAIL');
    Log(OutlookStringList, 'Microsoft Outlook' + is_installed_str);
    Log(OSTStringList, 'Microsoft Outlook OST file/s (off-line storage)' + files_were_located_str);
    Log(PSTStringList, 'Microsoft Outlook PST' + files_were_located_str);
    Log(ThunderbirdStringList, 'Mozilla Thunderbird' + is_installed_str);
  end;

  // REPORT - FILE SHARE
  If TriageResults.FileShare then
  begin
    ConsoleSection('FILE SHARING');
    Log(nil, 'DropBox' + may_have_been_used_str);
    Log(nil, 'MediaFire' + may_have_been_used_str);
  end;

  // REPORT - ITUNESBACKUP
  if TriageResults.iTunesBackup then
  begin
    ConsoleSection(UpperCase(ITUNES_BACKUP));
    Log(iTunesBackupStringList, ITUNES_BACKUP + files_were_located_str);
  end;

  // REPORT - MAC
  if TriageResults.MACFileSystem then
  begin
    ConsoleSection('MAC');
    Log(MACAddressBookMeStringList, 'AddressBookMe' + files_were_located_str);
    Log(MACAttachediDevicesStringList, 'Attached iDevices' + files_were_located_str);
    Log(MACBlueToothStringList, 'Bluetooth' + files_were_located_str);
    Log(MACDockItemsStringList, 'Dock Items' + files_were_located_str);
    Log(MACiCloudPreferencesStringList, 'iCloud Preferences' + files_were_located_str);
    Log(MACiMessageAccountsStringList, 'iMessage Accounts' + files_were_located_str);
    Log(MACiMessageChatStringList, 'iMessage Chat' + files_were_located_str);
    Log(MACInstallationTimeStringList, 'Installation Date' + files_were_located_str);
    Log(MACInstalledPrintersStringtList, 'Installed Printers' + files_were_located_str);
    Log(MACLastSleepStringList, 'Last Sleep' + files_were_located_str);
    Log(MACLoginItemsStringList, 'Login Items' + files_were_located_str);
    Log(MACLoginWindowStringList, 'Login Window' + files_were_located_str);
    Log(MACMailFolderStringList, 'Mail Folder' + files_were_located_str);
    Log(MACOSXUpdateStringList, 'OSX Update' + files_were_located_str);
    Log(MACRecentApplicationsStringList, 'Recent Applications' + files_were_located_str);
    Log(MACRecentDocumentsStringList, 'Recent Documents' + files_were_located_str);
    Log(MACRecentHostsStringList, 'Recent Hosts' + files_were_located_str);
    Log(MACRecentPhotoBoothStringList, 'Recent Photo Booth' + files_were_located_str);
    Log(MACSystemVersionStringList, 'System Version' + files_were_located_str);
    Log(MACSafariPreferencesStringList, 'Safari Preferences' + files_were_located_str);
    Log(MACSafariRecentSearchesStringList, 'Safari Recent Searches' + files_were_located_str);
    Log(MACTimeZoneStringList, 'TimeZone' + files_were_located_str);
    Log(MACTimeZoneLocalStringList, 'TimeZone Local' + files_were_located_str);
    Log(MACWifiStringList, 'Wifi' + files_were_located_str);
  end;

  // REPORT - PASSWORDS
  if TriageResults.Passwords then
  begin
    ConsoleSection('PASSWORDS');
    Log(RoboFormStringList, 'RoboForm' + files_were_located_str);
    Log(RoboFormPasswordStringList, '');
  end;

  // REPORT - PORN
  if TriageResults.Porn then
  begin
    ConsoleSection('PORN CHECK');
    Log(PornStringList, 'WARNING:  There may be pornographic material in this case.  A MANUAL VERIFICATION IS REQUIRED.');
  end;

  // REPORT - PORN CAM
  if TriageResults.PornCAM then
  begin
    ConsoleSection('PORN CAM CHECK');
    Log(PornCAMStringList, 'WARNING:  There may be Child Abuse Material in this case.  A MANUAL VERIFICATION IS REQUIRED.');
  end;

  // REPORT - SHADOW COPY
  if TriageResults.ShadowCopy then
  begin
    ConsoleSection('SHADOW COPY');
    Log(ShadowCopyStringList, 'Shadow Copy files' + files_were_located_str);
  end;

  // REPORT - SocialMedia
  if TriageResults.SocialMedia then
  begin
    ConsoleSection('SOCIAL MEDIA');
    Log(ByLockStringList, 'ByLock' + files_were_located_str);
    Log(CamFrogStringList, 'CamFrog' + is_installed_str);
    Log(DigsbyStringList, 'Digsby Chat' + is_installed_str);
    Log(ICQStringList, 'ICQ' + is_installed_str);
    Log(iMessageStringList, 'iMessage' + may_have_been_used_str);
    Log(MSNMessengerStringList, 'MSN Messenger' + is_installed_str);
    Log(PaltalkStringList, 'Paltalk' + is_installed_str);
    Log(PidginStringList, 'Pidgin' + is_installed_str);
    Log(SkypeStringList, 'Skype' + may_have_been_used_str);
    Log(TrillianStringList, 'Trillian Chat' + is_installed_str);
    Log(WhatsAppStringList, 'WhatsApp' + may_have_been_used_str);
    Log(WindowsFacebookAppStringList, 'Windows Facebook App' + is_installed_str);
    Log(YahooMessengerStringList, 'Yahoo Messenger' + is_installed_str);
  end;

  // REPORT - WINDOWS USER ACCOUNTS
  if TriageResults.Category_Windows_Users then
  begin
    ConsoleSection(UpperCase(WINDOWS_USER_FOLDERS));
    Log(UsersStringList, WINDOWS_USER_FOLDERS + files_were_located_str);
  end;

  // REPORT - WINDOWS VERSION
  if TriageResults.Category_Windows_Version then
  begin
    ConsoleSection(UpperCase(WINDOWS_VERSION));
    if TriageResults.Windows64bit then
    begin
      ConsoleLog('Windows 64bit' + is_installed_str);
      Log(Windows64bitStringList, 'Program Files (x86)' + folders_were_located_str);
    end;
  end;

  // REPORT - WIPING TOOLS
  if TriageResults.Wiping then
  begin
    ConsoleSection('WIPING TOOLS');
    Log(BCWipeStringList, 'BCWipe' + may_be_present_str);
    Log(CCleanerStringList, 'CCLeaner' + may_be_present_str);
    Log(DiskWipeStringList, 'DiskWipe' + may_be_present_str);
    Log(EraserStringList, 'Eraser' + may_be_present_str);
    Log(OtherWipeStringList, 'Other Wipe Files' + may_be_present_str);
    Log(PrivazerStringList, 'Privazer' + may_be_present_str);
  end;

  if FoundCount = 0 then
    ConsoleLog('No files of interest were found.');

  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  Time_Taken_int := (GetTickCount64 - Starting_Tick_Count);
  Time_Taken_int := trunc(Time_Taken_int / 1000);
  ConsoleLog('Time taken (from Run to Results screen) = ' + IntToStr(Time_Taken_int) + ' sec ' + FormatDateTime('hh:nn:ss', Time_Taken_int / SecsPerDay));

  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Finished.');

  BCWipeStringList.free;
  ByLockStringList.free;
  CamFrogStringList.free;
  CCleanerStringList.free;
  ChromeStringList.free;
  DevicePartitionInfoStringList.free;
  DigsbyStringList.free;
  DiskWipeStringList.free;
  DropBoxStringList.free;
  EraserStringList.free;
  File_Comment_StringList.free;
  FireFoxStringList.free;
  FreeAndNil(Evidence_EntryList);
  ICQStringList.free;
  iMessageStringList.free;
  InternetExplorerStringList.free;
  iTunesBackupStringList.free;
  MACAddressBookMeStringList.free;
  MACAttachediDevicesStringList.free;
  MACBlueToothStringList.free;
  MACDockItemsStringList.free;
  MACiCloudPreferencesStringList.free;
  MACiMessageAccountsStringList.free;
  MACiMessageChatStringList.free;
  MACInstallationTimeStringList.free;
  MACInstalledPrintersStringtList.free;
  MACLastSleepStringList.free;
  MACLoginItemsStringList.free;
  MACLoginWindowStringList.free;
  MACMailFolderStringList.free;
  MACOSXUpdateStringList.free;
  MACRecentApplicationsStringList.free;
  MACRecentDocumentsStringList.free;
  MACRecentHostsStringList.free;
  MACRecentPhotoBoothStringList.free;
  MACSafariPreferencesStringList.free;
  MACSafariRecentSearchesStringList.free;
  MACSystemVersionStringList.free;
  MACTimeZoneLocalStringList.free;
  MACTimeZoneStringList.free;
  MACWifiStringList.free;
  MediaFireStringList.free;
  MSNMessengerStringList.free;
  OperaStringList.free;
  OSTStringList.free;
  OtherWipeStringList.free;
  OutlookStringList.free;
  PaltalkStringList.free;
  PidginStringList.free;
  PornStringList.free;
  PornCAMStringList.free;
  PrivazerStringList.free;
  PSTStringList.free;
  RoboFormPasswordStringList.free;
  RoboFormStringList.free;
  SafariStringList.free;
  ShadowCopyStringList.free;
  SkypeStringList.free;
  ThunderbirdStringList.free;
  TorStringList.free;
  TrillianStringList.free;
  UsersStringList.free;
  WhatsAppStringList.free;
  Windows64bitStringList.free;
  WindowsFacebookAppStringList.free;
  YahooMessengerStringList.free;
end;

// ******************************************************************************
// The start of the script
// ******************************************************************************
var
  i: integer;
  Param: string;
  rpad_value: integer;

  // Starting Checks
  bContinue: boolean;
  CaseName: string;
  StartCheckEntry: TEntry;
  StartCheckDataStore: TDataStore;

begin
  Progress.DisplayTitle := SCRIPT_NAME;
  Progress.DisplayMessage := 'Starting...';
  ResultsStringList := nil;
  rpad_value := 30;
  bl_error := False;

  // ===========================================================================
  // Starting Checks
  // ===========================================================================
  // Check to see if the FileSystem module is present
  bContinue := True;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  try
    if not assigned(StartCheckDataStore) then
    begin
      ConsoleLog(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
      bContinue := False;
      Exit;
    end;
    // Check to see if a case is present
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case.' + SPACE + TSWT);
      bContinue := False;
      Exit;
    end
    else
      CaseName := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module.' + SPACE + TSWT);
      bContinue := False;
      Exit;
    end;
    // Exit if user cancels
    if not Progress.isRunning then
    begin
      ConsoleLog('Canceled by user.');
      bContinue := False;
    end;
  finally
    StartCheckDataStore.free;
  end;
  // Continue?
  if Not bContinue then
    Exit;
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  aDatastore := GetDataStore(DATASTORE_FILESYSTEM);

  // ============================================================================
  // Setup Results Header
  // ============================================================================
  ResultsStringList := TStringList.Create;
  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('Triage File System');

  // ============================================================================
  // Parameters
  // ============================================================================
  // ConsoleLog(Stringofchar('-', CHAR_LENGTH));
  Param := '';
  if (CmdLine.ParamCount > 0) then
  begin
    ConsoleLog(StringOfChar('-', CHAR_LENGTH));
    ConsoleLog(IntToStr(CmdLine.ParamCount) + ' processing parameters received: ');

    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      ConsoleLog(' - Param ' + IntToStr(i) + ': ' + CmdLine.params[i]);
      Param := Param + '"' + CmdLine.params[i] + '"' + ' ';
    end;
    trim(Param);
  end
  else
    ConsoleLog('No parameters received.');

  bl_EvidenceModule := False;
  bl_FSModule := False;
  bl_FSTriage := False;
  bl_ScriptsModule := False;
  bl_RegModule := False;

  if (CmdLine.params.Indexof('EVIDENCEMODULE') <> -1) then
    bl_EvidenceModule := True;
  if (CmdLine.params.Indexof('FILESYSTEMMODULE') <> -1) then
    bl_FSModule := True;
  if (CmdLine.params.Indexof('FSTRIAGE') <> -1) then
    bl_FSTriage := True;

  if CmdLine.ParamCount = 0 then
    bl_ScriptsModule := True;

  if bl_EvidenceModule then
  begin
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from Evidence module.');
  end;

  if bl_FSModule then
  begin
    bl_AutoBookmark_Results := False;
    ConsoleLog('Running from FileSystem module.');
  end;

  if bl_FSTriage then
  begin
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from FileSystem module Triage.');
  end;

  if bl_ScriptsModule then
  begin
    bl_AutoBookmark_Results := True;
    ConsoleLog('Running from Scripts module.');
  end;

  // ============================================================================
  // Log Running Options
  // ============================================================================
  ConsoleLog((StringOfChar('-', CHAR_LENGTH)));
  ConsoleLog('Options:');

  if bl_RegModule then
    ConsoleLog(RPad(HYPHEN + 'Running from:', 30) + 'Registry module')
  else if bl_FSModule then
    ConsoleLog(RPad(HYPHEN + 'Running from:', 30) + 'FileSystem module');

  if bl_AutoBookmark_Results then
    ConsoleLog(RPad(HYPHEN + 'Auto Bookmark Results:', 30) + 'Yes')
  else
    ConsoleLog(RPad(HYPHEN + 'Auto Bookmark Results:', 30) + 'No');

  MainProc;

  DeviceList.free;
  MACDeviceList.free;
  DeviceToSearchList.free;

  ConsoleLog(StringOfChar('-', CHAR_LENGTH));
  ConsoleLog('  ');
  ConsoleLog(SCRIPT_NAME + ' finished.');

  ResultsStringList.free; // Must be freed after the last ConsoleLog
  aDatastore.free;

  if bl_error then
    Progress.DisplayTitle := SCRIPT_NAME + SPACE + 'Error: Check Results';
  Progress.DisplayMessageNow := 'Processing complete';

end.
