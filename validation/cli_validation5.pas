unit validation_test;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, Email, Graphics, Math, PropertyList, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BL_FEXLAB = True;
  BS = '\';
  CHAR_LENGTH = 100;
  COMMA = ',';
  DCR = #13#10 + #13#10;
  FIELDBYNAME_HASH_MD5 = 'HASH (MD5)'; // noslz
  FLDR_ERROR = '-- ERROR --';
  FLDR_GLB = '\\Fexlabs\share\Global_Output';
  FLDR_LOC = 'C:\Forensic_Explorer_Testing_Folder';
  FLDR_VALIDATION = 'VALIDATION';
  FLDR_WARNING = '-- WARNING --';
  HYPHEN = ' - ';
  LOG_EMAIL_ATTACHMENTS = False;
  NumberOfSearchItems = 11;
  OSFILENAME = '\\?\'; // This is needed for long filenames';
  PC = 'PC';
  PIPE = '|';
  RS_EXT = 'ext.'; // noslz
  RS_NOT_RUN = 'Not Run'; // noslz
  RS_OK = 'OK'; // noslz
  RS_SIG = 'sig.'; // noslz
  RS_WARNING = 'WARNING'; // noslz
  RS_WARNING_EXPECTED = 'WARNING - Expected: '; // noslz
  RUNAS_STR = 'CLI';
  RUNNING = '...';
  SCRIPT_NAME = 'Validation Test';
  SCRIPT_OUTPUT = 'Script Output';
  SPACE = ' ';
  TSWT = 'The script will terminate.';
  UNALLOCATED_SEARCH = 'Artifact Carve';

  ACCOUNTS = 'Accounts';
  BROWSERS = 'Browsers';
  CHAT = 'Chat';
  CHROME = 'Chrome';
  CHROMIUM = 'Chromium';
  FIREFOX = 'FireFox';
  ICLOUD = 'iCloud Preferences';
  IE_1011 = 'Internet Explorer 10-11';
  IE_49 = 'Internet Explorer 4-9';
  IE_SHORT = 'IE';
  IMESSAGE = 'iMessage';
  IOS = ' iOS';
  MAC_OS = 'MAC Operating System';
  MOBILE = 'Mobile';
  OS = 'OS';
  OSX = 'OSX';
  PHOTOBOOTH = 'Recent Photo Booth';
  PRINTERS = 'Installed Printers';
  SAFARI = 'Safari';
  SKINTONE = 'SkinTone';
  SKYPE = 'Skype';
  SNAPCHAT = 'Snapchat';
  TELEGRAM = 'Telegram';
  VIBER = 'Viber';
  VIDEO_KEY_FRAMES = 'Video Key Frames';
  WHATSAPP = 'WhatsApp';
  WIFICON = 'WIFI Configurations';
  WIN_OS = 'Windows Operating System';

  PATH_BROWSERS_CHROME_AUTOFILL = BROWSERS + BS + CHROME + SPACE + 'Autofill' + BS;
  PATH_BROWSERS_CHROME_CACHE = BROWSERS + BS + CHROME + SPACE + 'Cache' + BS;
  PATH_BROWSERS_CHROME_COOKIES = BROWSERS + BS + CHROME + SPACE + 'Cookies' + BS;
  PATH_BROWSERS_CHROME_DOWNLOADS = BROWSERS + BS + CHROME + SPACE + 'Downloads' + BS;
  PATH_BROWSERS_CHROME_FAVICONS = BROWSERS + BS + CHROME + SPACE + 'Favicons' + BS;
  PATH_BROWSERS_CHROME_HISTORY = BROWSERS + BS + CHROME + SPACE + 'History' + BS;
  PATH_BROWSERS_CHROME_KEYWORDSEARCHTERMS = BROWSERS + BS + CHROME + SPACE + 'Keyword Search Terms' + BS;
  PATH_BROWSERS_CHROME_LOGINS = BROWSERS + BS + CHROME + SPACE + 'Logins' + BS;
  PATH_BROWSERS_CHROME_SHORTCUTS = BROWSERS + BS + CHROME + SPACE + 'Shortcuts' + BS;
  PATH_BROWSERS_CHROME_SYNCDATA = BROWSERS + BS + CHROME + SPACE + 'SyncData' + BS;
  PATH_BROWSERS_CHROME_TOPSITES = BROWSERS + BS + CHROME + SPACE + 'Top Sites' + BS;
  PATH_BROWSERS_CHROMIUM_CACHE = BROWSERS + BS + CHROMIUM + SPACE + 'Cache' + BS;
  PATH_BROWSERS_CHROMIUM_COOKIES = BROWSERS + BS + CHROMIUM + SPACE + 'Cookies' + BS;
  PATH_BROWSERS_CHROMIUM_DOWNLOADS = BROWSERS + BS + CHROMIUM + SPACE + 'Downloads' + BS;
  PATH_BROWSERS_CHROMIUM_HISTORY = BROWSERS + BS + CHROMIUM + SPACE + 'History' + BS;
  PATH_BROWSERS_CHROMIUM_KEYWORDSEARCHTERMS = BROWSERS + BS + CHROMIUM + SPACE + 'Keyword Search Terms' + BS;
  PATH_BROWSERS_FIREFOX_BOOKMARKS = BROWSERS + BS + FIREFOX + SPACE + 'Bookmarks' + BS;
  PATH_BROWSERS_FIREFOX_COOKIES = BROWSERS + BS + FIREFOX + SPACE + 'Cookies' + BS;
  PATH_BROWSERS_FIREFOX_DOWNLOADS = BROWSERS + BS + FIREFOX + SPACE + 'Downloads' + BS;
  PATH_BROWSERS_FIREFOX_FAVICONS = BROWSERS + BS + FIREFOX + SPACE + 'Favicons' + BS;
  PATH_BROWSERS_FIREFOX_FORMHISTORY = BROWSERS + BS + FIREFOX + SPACE + 'Form History' + BS;
  PATH_BROWSERS_FIREFOX_HISTORYVISITS = BROWSERS + BS + FIREFOX + SPACE + 'History Visits' + BS;
  PATH_BROWSERS_FIREFOX_PLACES = BROWSERS + BS + FIREFOX + SPACE + 'Places' + BS;
  PATH_BROWSERS_IE1011_CARVE_COOKIES = BROWSERS + BS + IE_1011 + SPACE + 'Carve Cookies' + BS;
  PATH_BROWSERS_IE1011_CARVE_HISTORY_REFMARKER = BROWSERS + BS + IE_1011 + SPACE + 'Carve History - Ref. Marker' + BS;
  PATH_BROWSERS_IE1011_CARVE_HISTORY_VISITED = BROWSERS + BS + IE_1011 + SPACE + 'Carve History - Visited' + BS;
  PATH_BROWSERS_IE1011_CARVE_HISTORY_VISITED_LOGFILES = BROWSERS + BS + IE_1011 + SPACE + 'Carve History - Visited (Log Files)' + BS;
  PATH_BROWSERS_IE1011_CARVECONTENT = BROWSERS + BS + IE_1011 + SPACE + 'Carve Content' + BS;
  PATH_BROWSERS_IE1011_CARVECONTENT_LOGFILES = BROWSERS + BS + IE_1011 + SPACE + 'Carve Content (Log Files)' + BS;
  PATH_BROWSERS_IE1011_ESECONTENT = BROWSERS + BS + IE_1011 + SPACE + 'ESE Content' + BS;
  PATH_BROWSERS_IE1011_ESECOOKIES = BROWSERS + BS + IE_1011 + SPACE + 'ESE Cookies' + BS;
  PATH_BROWSERS_IE1011_ESEDEPENDENCYENTRIES = BROWSERS + BS + IE_1011 + SPACE + 'ESE Dependency Entries' + BS;
  PATH_BROWSERS_IE1011_ESEDOWNLOADS = BROWSERS + BS + IE_1011 + SPACE + 'ESE Downloads' + BS;
  PATH_BROWSERS_IE1011_ESEHISTORY = BROWSERS + BS + IE_1011 + SPACE + 'ESE History' + BS;
  PATH_BROWSERS_IE49_COOKIE = BROWSERS + BS + IE_49 + SPACE + 'URL (Cookie)' + BS;
  PATH_BROWSERS_IE49_DAILY = BROWSERS + BS + IE_49 + SPACE + 'URL (Daily)' + BS;
  PATH_BROWSERS_IE49_HISTORY = BROWSERS + BS + IE_49 + SPACE + 'URL (History)' + BS;
  PATH_BROWSERS_IE49_NORMAL = BROWSERS + BS + IE_49 + SPACE + 'URL (Normal)' + BS;
  PATH_BROWSERS_SAFARI_BOOKMARKS = BROWSERS + BS + SAFARI + SPACE + 'Bookmarks' + BS;
  PATH_BROWSERS_SAFARI_CACHE = BROWSERS + BS + SAFARI + SPACE + 'Cache' + BS;
  PATH_BROWSERS_SAFARI_COOKIES = BROWSERS + BS + SAFARI + SPACE + 'Cookies' + BS;
  PATH_BROWSERS_SAFARI_HISTORY = BROWSERS + BS + SAFARI + SPACE + 'History' + BS;
  PATH_BROWSERS_SAFARI_HISTORY_IOS8 = BROWSERS + BS + SAFARI + SPACE + 'History iOS8' + BS;
  PATH_BROWSERS_SAFARI_RECENTSEARCHES = BROWSERS + BS + SAFARI + SPACE + 'Recent Searches' + BS;
  PATH_CHAT_IMESSAGE_ATTACHMENTS_OSX = CHAT + BS + IMESSAGE + SPACE + 'Attachments OSX' + BS;
  PATH_CHAT_IMESSAGE_MESSAGE_OSX = CHAT + BS + IMESSAGE + SPACE + 'Message OSX' + BS;
  PATH_CHAT_SKYPE_ACCOUNTS = CHAT + BS + SKYPE + SPACE + 'Accounts' + BS;
  PATH_CHAT_SKYPE_CALLS = CHAT + BS + SKYPE + SPACE + 'Calls' + BS;
  PATH_CHAT_SKYPE_CONTACTS = CHAT + BS + SKYPE + SPACE + 'Contacts' + BS;
  PATH_CHAT_SKYPE_MESSAGES = CHAT + BS + SKYPE + SPACE + 'Messages' + BS;
  PATH_CHAT_SKYPE_TRANSFERS = CHAT + BS + SKYPE + SPACE + 'Transfers' + BS;
  PATH_CHAT_SNAPCHAT_USER_IOS = CHAT + BS + SNAPCHAT + SPACE + 'User' + IOS + BS;
  PATH_CHAT_TELEGRAM_CHAT_IOS = CHAT + BS + TELEGRAM + SPACE + 'Chat' + IOS + BS;
  PATH_CHAT_VIBER_CHAT_IOS = CHAT + BS + VIBER + SPACE + 'Chat' + IOS + BS;
  PATH_CHAT_VIBER_CHAT_PC = CHAT + BS + VIBER + SPACE + 'Chat' + PC + BS;
  PATH_CHAT_WHATSAPP_CALLS_IOS = CHAT + BS + WHATSAPP + SPACE + 'Calls' + IOS + BS;
  PATH_CHAT_WHATSAPP_CHAT_IOS = CHAT + BS + WHATSAPP + SPACE + 'Chat' + IOS + BS;
  PATH_CHAT_ZELLO_CHAT_ANDROID = CHAT + BS + 'Zello' + SPACE + 'Chat Android' + BS;
  PATH_MAC_OS_ADDRESSBOOKME_MACOS = MAC_OS + BS + 'AddressBookMe' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_ATTACHED_IDEVICES_MACOS = MAC_OS + BS + 'Attached iDevices' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_BLUETOOTH_MACOS = MAC_OS + BS + 'Bluetooth' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_DOCK_ITEMS_MACOS = MAC_OS + BS + 'Dock Items' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_ICLOUD_PREFERENCES_MACOS = MAC_OS + BS + ICLOUD + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_IMESSAGE_ACCOUNTS_MACOS = MAC_OS + BS + 'iMessage Accounts' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_INSTALLATION_DATE_MACOS = MAC_OS + BS + 'Installation Date' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_INSTALLED_PRINTERS_MACOS = MAC_OS + BS + PRINTERS + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_LAST_SLEEP_MACOS = MAC_OS + BS + 'Last Sleep' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_LOGIN_ITEMS_MACOS = MAC_OS + BS + 'Login Items' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_LOGIN_WINDOW_MACOS = MAC_OS + BS + 'Login Window' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_MAIL_FOLDERS_MACOS = MAC_OS + BS + 'Mail Folders' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_OSX_UPDATE_MACOS = MAC_OS + BS + 'OSX Update' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_RECENT_ITEMS_APPLICATIONS_MACOS = MAC_OS + BS + 'Recent Items (Applications)' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_RECENT_ITEMS_DOCUMENTS_MACOS = MAC_OS + BS + 'Recent Items (Documents)' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_RECENT_ITEMS_HOSTS_MACOS = MAC_OS + BS + 'Recent Items (Hosts)' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_RECENT_PHOTO_BOOTH_MACOS = MAC_OS + BS + PHOTOBOOTH + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_RECENT_SAFARI_SEARCHES_MACOS = MAC_OS + BS + 'Safari Recent' + SPACE + 'Searches MacOS' + BS;
  PATH_MAC_OS_RECENT_VIDEOLAN_MACOS = MAC_OS + BS + 'Recent VideoLan' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_SAFARI_PREFERENCES_MACOS = MAC_OS + BS + 'Safari' + SPACE + 'Preferences MacOS' + BS;
  PATH_MAC_OS_SYSTEM_VERSION_MACOS = MAC_OS + BS + 'System Version' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_TIMEZONE_LOCAL_MACOS = MAC_OS + BS + 'Timezone Local' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_TIMEZONE_MACOS = MAC_OS + BS + 'Timezone' + SPACE + 'MacOS' + BS;
  PATH_MAC_OS_WIFI_MACOS = MAC_OS + BS + 'WIFI' + SPACE + 'MacOS' + BS;
  PATH_MOBILE_ACCOUNTS_TYPE_IOS = MOBILE + BS + 'Accounts' + SPACE + 'Type' + IOS + BS;
  PATH_MOBILE_CALENDAR_ITEMS_V3_IOS = MOBILE + BS + 'Calendar' + SPACE + 'Items v3' + IOS + BS;
  PATH_MOBILE_CALENDAR_ITEMS_V4_IOS = MOBILE + BS + 'Calendar' + SPACE + 'Items v4' + IOS + BS;
  PATH_MOBILE_CALL_HISTORY_IOS = MOBILE + BS + 'Call' + SPACE + 'History' + IOS + BS;
  PATH_MOBILE_CONTACT_DETAILS_IOS = MOBILE + BS + 'Contacts' + SPACE + 'Details' + IOS + BS;
  PATH_MOBILE_CONTACTS_CONTACTSTABLE_IOS = MOBILE + BS + 'Contacts' + SPACE + 'Contacts Table' + IOS + BS;
  PATH_MOBILE_CONTACTS_RECENTSTABLE_IOS = MOBILE + BS + 'Contacts' + SPACE + 'Recents Table' + IOS + BS;
  PATH_MOBILE_DROPBOX_METADATA_CACHE_IOS = MOBILE + BS + 'Dropbox Metadata' + SPACE + 'Cache' + IOS + BS;
  PATH_MOBILE_DYNAMICDICTIONARY_IOS = MOBILE + BS + 'Dynamic' + SPACE + 'Dictionary' + IOS + BS;
  PATH_MOBILE_GOOGLE_MOBILESEARCH_HISTORY_IOS = MOBILE + BS + 'Google Mobile' + SPACE + 'Search History' + IOS + BS;
  PATH_MOBILE_GOOGLEMAPS_IOS = MOBILE + BS + 'Google' + SPACE + 'Maps' + IOS + BS;
  PATH_MOBILE_ITUNESBACKUP_DETAILS = MOBILE + BS + 'iTunes Backup' + SPACE + 'Details' + IOS + BS;
  PATH_MOBILE_MAPS_IOS = MOBILE + BS + 'Maps' + SPACE + 'History' + IOS + BS;
  PATH_MOBILE_NOTE_ITEMS_IOS = MOBILE + BS + 'Note' + SPACE + 'Items' + IOS + BS;
  PATH_MOBILE_SEARCH_HISTORY_IOS = MOBILE + BS + 'Google Mobile' + SPACE + 'Search History' + IOS + BS;
  PATH_MOBILE_SMS_V3_IOS = MOBILE + BS + 'SMS' + SPACE + 'v3' + IOS + BS;
  PATH_MOBILE_SMS_V4_IOS = MOBILE + BS + 'SMS' + SPACE + 'v4' + IOS + BS;
  PATH_MOBILE_USER_SHORTCUT_DICTIONARY_IOS = MOBILE + BS + 'User Shortcut' + SPACE + 'Dictionary' + IOS + BS;
  PATH_MOBILE_VOICE_MAIL_IOS = MOBILE + BS + 'Voice' + SPACE + 'Mail' + IOS + BS;
  PATH_MOBILE_VOICE_MEMOS_IOS = MOBILE + BS + 'Voice' + SPACE + 'Memos' + IOS + BS;
  PATH_MOBILE_WIFI_CONFIGURATIONS_IOS = MOBILE + BS + 'Wifi' + SPACE + 'Configurations' + IOS + BS;
  PATH_UNALLOCATED_SEARCH_GMAILFRAGMENTS = UNALLOCATED_SEARCH + BS + 'GMail' + SPACE + 'Fragments' + BS;
  PATH_WINDOWS_OS_PREFETCH_WINDOWS = WIN_OS + BS + 'Prefetch' + SPACE + 'Windows' + BS;
  PATH_WINDOWS_OS_WIFI_WINDOWS = WIN_OS + BS + 'Wifi' + SPACE + 'Windows' + BS;

implementation

type
  PSQL_FileSearch = ^TSQL_FileSearch;

  TSQL_FileSearch = record
    Device_Logical_Size: int64;
    Device_Name: string;
    expected_AR_browsers_chrome_AUTOFILL_count: integer;
    expected_AR_browsers_chrome_CACHE_count: integer;
    expected_AR_browsers_chrome_COOKIES_count: integer;
    expected_AR_browsers_chrome_DOWNLOADS_count: integer;
    expected_AR_browsers_chrome_FAVICONS_count: integer;
    expected_AR_browsers_chrome_HISTORY_count: integer;
    expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: integer;
    expected_AR_browsers_chrome_LOGINS_count: integer;
    expected_AR_browsers_chrome_SHORTCUTS_count: integer;
    expected_AR_browsers_chrome_SYNCDATA_count: integer;
    expected_AR_browsers_chrome_TOPSITES_count: integer;
    expected_AR_browsers_chromium_CACHE_count: integer;
    expected_AR_browsers_chromium_COOKIES_count: integer;
    expected_AR_browsers_chromium_DOWNLOADS_count: integer;
    expected_AR_browsers_chromium_HISTORY_count: integer;
    expected_AR_browsers_chromium_KEYWORDSEARCHTERMS_count: integer;
    expected_AR_browsers_FIREFOX_BOOKMARKS_count: integer;
    expected_AR_browsers_FIREFOX_COOKIES_count: integer;
    expected_AR_browsers_FIREFOX_DOWNLOADS_count: integer;
    expected_AR_browsers_FIREFOX_FAVICONS_count: integer;
    expected_AR_browsers_FIREFOX_FORMHISTORY_count: integer;
    expected_AR_browsers_FIREFOX_HISTORYVISITS_count: integer;
    expected_AR_browsers_FIREFOX_PLACES_count: integer;
    expected_AR_browsers_IE1011_CARVE_COOKIES_count: integer;
    expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: integer;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: integer;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: integer;
    expected_AR_browsers_IE1011_CARVECONTENT_count: integer;
    expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: integer;
    expected_AR_browsers_IE1011_ESECONTENT_count: integer;
    expected_AR_browsers_IE1011_ESECOOKIES_count: integer;
    expected_AR_browsers_IE1011_ESEDEPENDENCYENTRIES_count: integer;
    expected_AR_browsers_IE1011_ESEDOWNLOADS_count: integer;
    expected_AR_browsers_IE1011_ESEHISTORY_count: integer;
    expected_AR_browsers_IE49_COOKIE_count: integer;
    expected_AR_browsers_IE49_DAILY_count: integer;
    expected_AR_browsers_IE49_HISTORY_count: integer;
    expected_AR_browsers_IE49_NORMAL_count: integer;
    expected_AR_browsers_SAFARI_BOOKMARKS_count: integer;
    expected_AR_browsers_SAFARI_CACHE_count: integer;
    expected_AR_browsers_SAFARI_COOKIES_count: integer;
    expected_AR_browsers_SAFARI_HISTORY_count: integer;
    expected_AR_browsers_SAFARI_HISTORY_IOS8_count: integer;
    expected_AR_browsers_SAFARI_RECENTSEARCHES_count: integer;
    expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: integer;
    expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: integer;
    expected_AR_chat_SKYPE_ACCOUNTS_count: integer;
    expected_AR_chat_SKYPE_CALLS_count: integer;
    expected_AR_chat_SKYPE_CONTACTS_count: integer;
    expected_AR_chat_SKYPE_MESSAGES_count: integer;
    expected_AR_chat_SKYPE_TRANSFERS_count: integer;
    expected_AR_chat_SNAPCHAT_USER_IOS_count: integer;
    expected_AR_chat_TELEGRAM_CHAT_IOS_count: integer;
    expected_AR_chat_VIBER_CHAT_IOS_count: integer;
    expected_AR_chat_VIBER_CHAT_PC_count: integer;
    expected_AR_chat_WHATSAPP_CALLS_IOS_count: integer;
    expected_AR_chat_WHATSAPP_CHAT_IOS_count: integer;
    expected_AR_chat_ZELLO_CHAT_ANDROID_count: integer;
    expected_AR_mac_OS_ADDRESSBOOKME_MACOS_count: integer;
    expected_AR_mac_OS_ATTACHED_IDEVICES_MACOS_count: integer;
    expected_AR_mac_OS_BLUETOOTH_MACOS_count: integer;
    expected_AR_mac_OS_DOCK_ITEMS_MACOS_count: integer;
    expected_AR_mac_OS_ICLOUD_PREFERENCES_MACOS_count: integer;
    expected_AR_mac_OS_IMESSAGE_ACCOUNTS_MACOS_count: integer;
    expected_AR_mac_OS_INSTALLATION_DATE_MACOS_count: integer;
    expected_AR_mac_OS_INSTALLED_PRINTERS_MACOS_count: integer;
    expected_AR_mac_OS_LAST_SLEEP_MACOS_count: integer;
    expected_AR_mac_OS_LOGIN_ITEMS_MACOS_count: integer;
    expected_AR_mac_OS_LOGIN_WINDOW_MACOS_count: integer;
    expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: integer;
    expected_AR_mac_OS_OSX_UPDATE_MACOS_count: integer;
    expected_AR_mac_OS_PHOTO_BOOTH_RECENTS_MACOS_count: integer;
    expected_AR_mac_OS_RECENT_ITEMS_APPLICATIONS_MACOS_count: integer;
    expected_AR_mac_OS_RECENT_ITEMS_DOCUMENTS_MACOS_count: integer;
    expected_AR_mac_OS_RECENT_ITEMS_HOSTS_MACOS_count: integer;
    expected_AR_mac_OS_RECENT_SAFARI_SEARCHES_MACOS_count: integer;
    expected_AR_mac_OS_RECENT_VIDEOLAN_MACOS_count: integer;
    expected_AR_mac_OS_SAFARI_PREFERENCES_MACOS_count: integer;
    expected_AR_mac_OS_SYSTEM_VERSION_MACOS_count: integer;
    expected_AR_mac_OS_TIMEZONE_LOCAL_MACOS_count: integer;
    expected_AR_mac_OS_TIMEZONE_MACOS_count: integer;
    expected_AR_mac_OS_WIFI_MACOS_count: integer;
    expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: integer;
    expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: integer;
    expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: integer;
    expected_AR_mobile_CALL_HISTORY_IOS_count: integer;
    expected_AR_mobile_CONTACT_DETAILS_IOS_count: integer;
    expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: integer;
    expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: integer;
    expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: integer;
    expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: integer;
    expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: integer;
    expected_AR_mobile_GOOGLEMAPS_IOS_count: integer;
    expected_AR_mobile_ITUNESBACKUP_DETAILS_count: integer;
    expected_AR_mobile_MAPS_IOS_count: integer;
    expected_AR_mobile_NOTE_ITEMS_IOS_count: integer;
    expected_AR_mobile_SMS_V3_IOS_count: integer;
    expected_AR_mobile_SMS_V4_IOS_count: integer;
    expected_AR_mobile_USER_SHORTCUT_DICTIONARY_IOS_count: integer;
    expected_AR_mobile_VOICE_MAIL_IOS_count: integer;
    expected_AR_mobile_VOICE_MEMOS_IOS_count: integer;
    expected_AR_mobile_WIFI_CONFIGURATIONS_IOS_count: integer;
    expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: string;
    expected_AR_windows_os_PREFETCH_WINDOWS_count: integer;
    expected_AR_windows_OS_WIFI_WINDOWS_count: integer;
    expected_BM_30to39_count_str: string;
    expected_BM_40to49_count_str: string;
    expected_BM_50to59_count_str: string;
    expected_BM_60to69_count_str: string;
    expected_BM_70to79_count_str: string;
    expected_BM_80to89_count_str: string;
    expected_BM_90to99_count_str: string;
    expected_BM_Triagecount_count_str: string;
    expected_BM_VideoSkintone_count_str: string;
    expected_EM_ext_avi_count_str: string;
    expected_EM_ext_exe_count_str: string;
    expected_EM_ext_jpg_count_str: string;
    expected_EM_ext_wmv_count_str: string;
    expected_EM_ext_zip_count_str: string;
    expected_EM_sig_avi_count_str: string;
    expected_EM_sig_exe_count_str: string;
    expected_EM_sig_jpg_count_str: string;
    expected_EM_sig_wmv_count_str: string;
    expected_EM_sig_zip_count_str: string;
    expected_FS_carved_camera_sig_jpg_count: integer;
    expected_FS_custom_byte_carve_pagefile_jpg_count: integer;
    expected_FS_ext_avi_count_str: string;
    expected_FS_ext_exe_count_str: string;
    expected_FS_ext_jpg_count_str: string;
    expected_FS_ext_ost_count_str: string; // ost
    expected_FS_ext_plist_count_str: string; // plist
    expected_FS_ext_pst_count_str: string; // pst
    expected_FS_ext_wmv_count_str: string;
    expected_FS_ext_zip_count_str: string;
    expected_FS_logical_free_space_on_disk: integer;
    expected_FS_metadata_271Canon_count: integer;
    expected_FS_metadata_271Make_carved_count: integer;
    expected_FS_metadata_271Make_normal_count: integer;
    expected_FS_metadata_271Make_recfld_count: integer;
    expected_FS_number_of_files: integer;
    expected_FS_partition_count: integer;
    expected_FS_partitions_sum_size: int64;
    expected_FS_pictures_zip_count: integer;
    expected_FS_pictures_zip_md5: string;
    expected_FS_recovered_folders: string;
    expected_FS_sig_avi_count_str: string;
    expected_FS_sig_exe_count_str: string;
    expected_FS_sig_jpg_count_str: string;
    expected_FS_sig_maxsigtime: integer;
    expected_FS_sig_ost_count_str: string; // ost
    expected_FS_sig_plist_count_str: string; // plist
    expected_FS_sig_pst_count_str: string; // pst
    expected_FS_sig_wmv_count_str: string;
    expected_FS_sig_zip_count_str: string;
    expected_FS_sum_pictures_zip_size: int64;
    expected_FS_unalloc_ntfs_vol_size: int64;
    expected_FS_verification_MD5: string;
    expected_FS_verification_SHA1: string;
    expected_FS_verification_SHA256: string;
    expected_KW_keyword1: string;
    expected_KW_keyword1_file_count_str: string;
    expected_KW_keyword1_hits_count_str: string;
    expected_KW_keyword1_regex: string;
    expected_KW_keyword1_regex_file_count_str: string;
    expected_KW_keyword1_regex_hits_count_str: string;
    expected_KW_keyword2: string;
    expected_KW_keyword2_file_count_str: string;
    expected_KW_keyword2_hits_count_str: string;
    expected_module_count_Artifacts_str: string;
    expected_module_count_Bookmarks: integer;
    expected_module_count_Email: string;
    expected_module_count_Registry: integer;
    expected_RG_computername: string;
    expected_RG_computername_count: integer;
    expected_volume_ID: string;
    ftk_imager_output_str: string;
    GD_Ref_Name: string;
    Hash_Threshold: integer;
    Image_Name: string;
    Item_Number: string;
  end;

var
  actual_30to39_count: integer;
  actual_40to49_count: integer;
  actual_50to59_count: integer;
  actual_60to69_count: integer;
  actual_70to79_count: integer;
  actual_80to89_count: integer;
  actual_90to99_count: integer;
  actual_BM_Triage_count_str: string;
  actual_BM_VideoSkintone_count: integer;
  actual_carved_sig_jpg_count: integer;
  actual_current_datastore_count: integer;
  actual_custom_byte_carve_jpg_count: integer;
  actual_ext_avi_count: integer;
  actual_ext_exe_count: integer;
  actual_ext_jpg_count: integer;
  actual_ext_ost_count: integer;
  actual_ext_plist_count: integer;
  actual_ext_pst_count: integer;
  actual_ext_wmv_count: integer;
  actual_ext_zip_count: integer;
  actual_FS_recovered_folders_count_str: string;
  actual_keydata_computername_count: integer;
  actual_KW1_file_count: integer;
  actual_KW1_hits_count: integer;
  actual_KW1_regex_file_count: integer;
  actual_KW1_regex_hits_count: integer;
  actual_KW2_file_count: integer;
  actual_KW2_hits_count: integer;
  actual_metadata_271Canon_count: integer;
  actual_metadata_271Make_count: integer;
  actual_module_count_Artifacts: integer;
  actual_module_count_Bookmarks: integer;
  actual_module_count_Email: integer;
  actual_module_count_Registry: integer;
  actual_module_file_count: integer;
  actual_partition_count: integer;
  actual_partitions_sum_size: int64;
  actual_pictures_zip_count: integer;
  actual_pictures_zip_md5: string;
  actual_sig_avi_count: integer;
  actual_sig_exe_count: integer;
  actual_sig_jpg_count: integer;
  actual_sig_ost_count: integer;
  actual_sig_plist_count: integer;
  actual_sig_pst_count: integer;
  actual_sig_wmv_count: integer;
  actual_sig_zip_count: integer;
  actual_sum_pictures_zip_size: integer;
  actual_unalloc_ntfs_vol_size: int64;
  actual_verification_md5: string;
  actual_verification_SHA1: string;
  actual_verification_SHA256: string;
  actual_volume_id: string;
  array_of_string: array of string;
  ArtifactsEntryList: TDataStore;
  bl_Continue: boolean;
  BookmarksEntryList: TDataStore;
  count_browsers_chrome_autofill: integer;
  count_browsers_chrome_cache: integer;
  count_browsers_chrome_cookies: integer;
  count_browsers_chrome_downloads: integer;
  count_browsers_chrome_favicons: integer;
  count_browsers_chrome_history: integer;
  count_browsers_chrome_keywordsearchterms: integer;
  count_browsers_chrome_logins: integer;
  count_browsers_chrome_shortcuts: integer;
  count_browsers_chrome_syncdata: integer;
  count_browsers_chrome_topsites: integer;
  count_browsers_chromium_cache: integer;
  count_browsers_chromium_cookies: integer;
  count_browsers_chromium_downloads: integer;
  count_browsers_chromium_history: integer;
  count_browsers_chromium_keywordsearchterms: integer;
  count_browsers_firefox_bookmarks: integer;
  count_browsers_firefox_cookies: integer;
  count_browsers_firefox_downloads: integer;
  count_browsers_firefox_favicons: integer;
  count_browsers_firefox_formhistory: integer;
  count_browsers_firefox_historyvisits: integer;
  count_browsers_firefox_places: integer;
  count_browsers_ie1011_carve_cookies: integer;
  count_browsers_ie1011_carve_history_refmarker: integer;
  count_browsers_ie1011_carve_history_visited: integer;
  count_browsers_ie1011_carve_history_visited_logfiles: integer;
  count_browsers_ie1011_carvecontent: integer;
  count_browsers_ie1011_carvecontent_logfiles: integer;
  count_browsers_ie1011_esecontent: integer;
  count_browsers_ie1011_esecookies: integer;
  count_browsers_ie1011_esedependencyentries: integer;
  count_browsers_ie1011_esedownloads: integer;
  count_browsers_ie1011_esehistory: integer;
  count_browsers_ie49_cookie: integer;
  count_browsers_ie49_daily: integer;
  count_browsers_ie49_history: integer;
  count_browsers_ie49_normal: integer;
  count_browsers_safari_bookmarks: integer;
  count_browsers_safari_cache: integer;
  count_browsers_safari_cookies: integer;
  count_browsers_safari_history: integer;
  count_browsers_safari_history_ios8: integer;
  count_browsers_safari_recentsearches: integer;
  count_chat_imessage_attachments_osx: integer;
  count_chat_imessage_message_osx: integer;
  count_chat_skype_accounts: integer;
  count_chat_skype_calls: integer;
  count_chat_skype_contacts: integer;
  count_chat_skype_messages: integer;
  count_chat_skype_transfers: integer;
  count_chat_snapchat_user_ios: integer;
  count_chat_telegram_chat_ios: integer;
  count_chat_viber_chat_ios: integer;
  count_chat_viber_chat_pc: integer;
  count_chat_whatsapp_calls_ios: integer;
  count_chat_whatsapp_chat_ios: integer;
  count_chat_zello_chat_android: integer;
  count_mac_os_addressbookme_macos: integer;
  count_mac_os_attached_idevices_macos: integer;
  count_mac_os_bluetooth_macos: integer;
  count_mac_os_dock_items_macos: integer;
  count_mac_os_icloud_preferences_macos: integer;
  count_mac_os_imessage_accounts_macos: integer;
  count_mac_os_installation_date_macos: integer;
  count_mac_os_installed_printers_macos: integer;
  count_mac_os_last_sleep_macos: integer;
  count_mac_os_login_items_macos: integer;
  count_mac_os_login_window_macos: integer;
  count_mac_os_mail_folders_macos: integer;
  count_mac_os_osx_update_macos: integer;
  count_mac_os_recent_items_applications_macos: integer;
  count_mac_os_recent_items_documents_macos: integer;
  count_mac_os_recent_items_hosts_macos: integer;
  count_mac_os_recent_photo_booth_macos: integer;
  count_mac_os_recent_safari_searches_macos: integer;
  count_mac_os_recent_videolan_macos: integer;
  count_mac_os_safari_preferences_macos: integer;
  count_mac_os_system_version_macos: integer;
  count_mac_os_timezone_local_macos: integer;
  count_mac_os_timezone_macos: integer;
  count_mac_os_wifi_macos: integer;
  count_mobile_accounts_type_ios: integer;
  count_mobile_calendar_items_v3_ios: integer;
  count_mobile_calendar_items_v4_ios: integer;
  count_mobile_call_history_ios: integer;
  count_mobile_contact_details_ios: integer;
  count_mobile_contacts_contactstable_ios: integer;
  count_mobile_contacts_recentstable_ios: integer;
  count_mobile_dropbox_metadata_cache_ios: integer;
  count_mobile_dynamicdictionary_ios: integer;
  count_mobile_google_mobilesearch_history_ios: integer;
  count_mobile_googlemaps_ios: integer;
  count_mobile_itunesbackup_details: integer;
  count_mobile_maps_ios: integer;
  count_mobile_note_items_ios: integer;
  count_mobile_sms_v3_ios: integer;
  count_mobile_sms_v4_ios: integer;
  count_mobile_user_shortcut_dictionary_ios: integer;
  count_mobile_voice_mail_ios: integer;
  count_mobile_voice_memos_ios: integer;
  count_mobile_wifi_configurations_ios: integer;
  count_unallocated_search_gmailfragments: integer;
  count_windows_os_prefetch_windows: integer;
  count_windows_os_wifi_windows: integer;
  EmailEntryList: TDataStore;
  Field_BookmarkFolder: TDataStoreField;
  Field_Exif271Make: TDataStoreField;
  Field_MD5: TDataStoreField;
  Field_SHA1: TDataStoreField;
  Field_SHA256: TDataStoreField;
  FieldName: string;
  file_carve_bl: boolean;
  file_carve_custom_byte_bl: boolean;
  FileItems: array [1 .. NumberOfSearchItems] of PSQL_FileSearch;
  FileSystemEntryList: TDataStore;
  gbl_BM_Signature_Status: boolean;
  gbl_bmonly: boolean;
  gbl_EM_Hash_Status: boolean;
  gbl_EM_Signature_Status: boolean;
  gbl_FS_Hash_Status: boolean;
  gbl_FS_Signature_Status: boolean;
  gbl_open_folder: boolean;
  gbl_RG_Hash_Status: boolean;
  gbl_RG_Signature_Status: boolean;
  gbl_SkinToneRunGraphics: boolean;
  gbl_SkinToneRunVideo: boolean;
  gcase_name: string;
  gCompare_TXT: string;
  gCompare_with_external_bl: boolean;
  gDeviceName_str: string;
  gitem_int: integer;
  gMemo_StringList: TStringList;
  gsave_file_glb_str: string;
  gsave_file_loc_str: string;
  gTheCurrentDevice: string;
  identified_image_bl: boolean;
  Item: PSQL_FileSearch;
  KeyData_Field: TDataStoreField;
  KeywordSearchEntryList: TDataStore;
  max_sig_analysis_duration: integer;
  normal_FileSystem_count: integer;
  Recovered_Folders_TList: TList;
  RegistryEntryList: TDataStore;
  rpad_value: integer;
  rpad_value2: integer;
  ScriptPath_str: string;
  VolumeID_StringList: TStringList;

procedure LoadFileItems;
const
  lFileItems: array [1 .. NumberOfSearchItems] of TSQL_FileSearch = (
    // ~1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Item_Number: '1'; Image_Name: 'a2983d341eee1e643f90e5e398c8b688'; GD_Ref_Name: 'MTH'; Hash_Threshold: 85; Device_Logical_Size: 80026361856; expected_AR_browsers_chrome_AUTOFILL_count: 0; expected_AR_browsers_chrome_CACHE_count: 0;
    expected_AR_browsers_chrome_COOKIES_count: 0; expected_AR_browsers_chrome_DOWNLOADS_count: 0; expected_AR_browsers_chrome_FAVICONS_count: 4; expected_AR_browsers_chrome_HISTORY_count: 0;
    expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: 0; expected_AR_browsers_chrome_LOGINS_count: 0; expected_AR_browsers_chrome_SHORTCUTS_count: 2; expected_AR_browsers_chrome_SYNCDATA_count: 0;
    expected_AR_browsers_chrome_TOPSITES_count: 2; expected_AR_browsers_chromium_CACHE_count: 196; expected_AR_browsers_chromium_COOKIES_count: 9; expected_AR_browsers_chromium_DOWNLOADS_count: 0;
    expected_AR_browsers_chromium_HISTORY_count: 99; expected_AR_browsers_chromium_KEYWORDSEARCHTERMS_count: 0; expected_AR_browsers_FIREFOX_BOOKMARKS_count: 74; expected_AR_browsers_FIREFOX_COOKIES_count: 887;
    expected_AR_browsers_FIREFOX_DOWNLOADS_count: 4; expected_AR_browsers_FIREFOX_FAVICONS_count: 67; expected_AR_browsers_FIREFOX_FORMHISTORY_count: 0; expected_AR_browsers_FIREFOX_HISTORYVISITS_count: 311;
    expected_AR_browsers_FIREFOX_PLACES_count: 306; expected_AR_browsers_IE1011_CARVE_COOKIES_count: 813; expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: 376; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: 2571;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: 240; expected_AR_browsers_IE1011_CARVECONTENT_count: 9908; expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: 1201;
    expected_AR_browsers_IE1011_ESECONTENT_count: 6849; expected_AR_browsers_IE1011_ESECOOKIES_count: 541; expected_AR_browsers_IE1011_ESEDEPENDENCYENTRIES_count: 24; expected_AR_browsers_IE1011_ESEDOWNLOADS_count: 14;
    expected_AR_browsers_IE1011_ESEHISTORY_count: 459; expected_AR_browsers_IE49_COOKIE_count: 49; expected_AR_browsers_IE49_DAILY_count: 20; expected_AR_browsers_IE49_HISTORY_count: 50; expected_AR_browsers_IE49_NORMAL_count: 4247;
    expected_AR_browsers_SAFARI_BOOKMARKS_count: 100; expected_AR_browsers_SAFARI_CACHE_count: 0; expected_AR_browsers_SAFARI_COOKIES_count: 297; expected_AR_browsers_SAFARI_HISTORY_count: 48;
    expected_AR_browsers_SAFARI_RECENTSEARCHES_count: 14; expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: 26; expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: 455; expected_AR_chat_SKYPE_ACCOUNTS_count: 3;
    expected_AR_chat_SKYPE_CALLS_count: 68; expected_AR_chat_SKYPE_CONTACTS_count: 161; expected_AR_chat_SKYPE_MESSAGES_count: 570; expected_AR_chat_SKYPE_TRANSFERS_count: 0; expected_AR_chat_SNAPCHAT_USER_IOS_count: 0;
    expected_AR_chat_TELEGRAM_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_PC_count: 0; expected_AR_chat_WHATSAPP_CALLS_IOS_count: 0; expected_AR_chat_WHATSAPP_CHAT_IOS_count: 15;
    expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: 0; expected_AR_mac_OS_TIMEZONE_MACOS_count: 0; expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: 68; expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: 0;
    expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: 99; expected_AR_mobile_CALL_HISTORY_IOS_count: 150; expected_AR_mobile_CONTACT_DETAILS_IOS_count: 116; expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: 0;
    expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: 0; expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: 0; expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: 1389; expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: 3;
    expected_AR_mobile_GOOGLEMAPS_IOS_count: 5; expected_AR_mobile_ITUNESBACKUP_DETAILS_count: 3; expected_AR_mobile_MAPS_IOS_count: 0; expected_AR_mobile_NOTE_ITEMS_IOS_count: 1; expected_AR_mobile_SMS_V3_IOS_count: 0;
    expected_AR_mobile_SMS_V4_IOS_count: 457; expected_AR_mobile_VOICE_MAIL_IOS_count: 0; expected_AR_mobile_VOICE_MEMOS_IOS_count: 3; expected_AR_mobile_WIFI_CONFIGURATIONS_IOS_count: 121;
    expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0|1178|1382'; expected_AR_windows_os_PREFETCH_WINDOWS_count: 129; expected_AR_windows_OS_WIFI_WINDOWS_count: 4; expected_BM_30to39_count_str: '0';
    expected_BM_40to49_count_str: '0'; expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '7'; expected_BM_70to79_count_str: '2'; expected_BM_80to89_count_str: '4'; expected_BM_90to99_count_str: '1';
    expected_BM_Triagecount_count_str: '442'; expected_BM_VideoSkintone_count_str: '3'; expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '114'; expected_EM_ext_wmv_count_str: '0';
    expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '118'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '24';
    expected_FS_carved_camera_sig_jpg_count: 740; expected_FS_custom_byte_carve_pagefile_jpg_count: 78; expected_FS_ext_avi_count_str: '51'; expected_FS_ext_exe_count_str: '2607'; expected_FS_ext_jpg_count_str: '2599';
    expected_FS_ext_ost_count_str: '2'; // ost
    expected_FS_ext_plist_count_str: '423'; // plist
    expected_FS_ext_pst_count_str: '6'; // pst
    expected_FS_ext_wmv_count_str: '137'; expected_FS_ext_zip_count_str: '43'; expected_FS_logical_free_space_on_disk: 0; expected_FS_metadata_271Canon_count: 62; expected_FS_metadata_271Make_carved_count: 20;
    expected_FS_metadata_271Make_normal_count: 803; expected_FS_metadata_271Make_recfld_count: 10; expected_FS_number_of_files: 198443; expected_FS_partition_count: 2; expected_FS_partitions_sum_size: 80024173568;
    expected_FS_pictures_zip_count: 14; expected_FS_pictures_zip_md5: 'fc7b75e7d6ede5183d9a50ece03bd837'; expected_FS_recovered_folders: '13'; expected_FS_sig_avi_count_str: '45'; expected_FS_sig_exe_count_str: '28833';
    expected_FS_sig_jpg_count_str: '3706'; expected_FS_sig_maxsigtime: 360; expected_FS_sig_ost_count_str: '2'; // ost
    expected_FS_sig_plist_count_str: '2483'; // plist
    expected_FS_sig_pst_count_str: '6'; // pst
    expected_FS_sig_wmv_count_str: '136'; expected_FS_sig_zip_count_str: '731'; expected_FS_sum_pictures_zip_size: 37812828; expected_FS_unalloc_ntfs_vol_size: 25323220992; expected_FS_verification_MD5: '1d8321c3727f21b3fd818a2e32b2fb79';
    expected_FS_verification_SHA1: 'd6b5a11a34f4ca35b09d169782b5348f37187ab4'; expected_FS_verification_SHA256: '075e655b147d238b2668fdcee3cd5720c718e2b85f8336c5607216c71af78fe9'; expected_KW_keyword1: 'beckham'; // noslz
    expected_KW_keyword1_file_count_str: '39'; // 1 15/11/2021 keyword change
    expected_KW_keyword1_hits_count_str: '212'; // 15/11/2021 keyword change
    expected_KW_keyword1_regex: 'lowb[a-z]+alarm'; // noslz
    expected_KW_keyword1_regex_file_count_str: '45'; expected_KW_keyword1_regex_hits_count_str: '105'; expected_KW_keyword2: 'billylibby'; // noslz
    expected_KW_keyword2_file_count_str: '18'; // 15/11/2021 keyword change
    expected_KW_keyword2_hits_count_str: '128'; // 15/11/2021 keyword change
    expected_module_count_Artifacts_str: '36624'; expected_module_count_Bookmarks: 0; expected_module_count_Email: '2645'; expected_module_count_Registry: 1737399; expected_RG_computername: 'JTH'; expected_RG_computername_count: 11;
    expected_volume_ID: '7EB8A6DAB8A69067,863EAA8F3EAA7837';

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"4708bbbc9588091f2d26de99d724162d","993961e2cb6f70cb2e90f50fa339e4deaf940c53","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\5fa2f9cb5ad63c4d74ceed003aeb7b4ab00b5dc6"'
    + #13#10 +
    '"4e40a996e6f5eb11c11988959bb7e817","41b112ace08b6a600d8cd30eee8eb7295ca6af37","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\2de85beda64b5ef8c1dc5a99ac776c982218ddee"'
    + #13#10 +
    '"ffe0c8ac7f8c4b52ce0fa4699a0af602","0253e6af3d121e5a8621e53e854eb0c130a7badf","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\997ad87718aa82212add5e88216896194732484e"'
    + #13#10 +
    '"ced8b49b9f23fd72d124023050a488c9","04a58da57f571baf5b1a54da25a74b6bf6ef246d","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\d6027c368417d8c926493eaf9294f6ccc4ecf271"'
    + #13#10 +
    '"b9a701a48740485689f369e9e64c9462","97212a6d9b905d7a27721984f509740b8be3ea1e","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\ee27dc35af241c409681b2c615defa59cc29212a"'
    + #13#10 +
    '"6fe096f215544251df9e5eba0cc4b0fc","7dfe3e4802f6d0b8d09e895f93d68f72d2cace19","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\58c3e907e8ab8d1ffd7fcede7f24019f389ddd9f"'
    + #13#10 +
    '"7d12bf1f03c8ce232806a668d3e0cc12","c3189b7a81dd4b4beffa2a28176788d864f4c834","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\e5ece895523597d82351dd2c3f4c729a4d6c90db"'
    + #13#10 +
    '"c75c842c17381d0d5482f5c1e2f4220f","d855b1e44fd691622d2b4d2cb21301abb857efa4","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\968ea6c3d33c2e11babbd5810ac9530073229314"'
    + #13#10 +
    '"6d89f77ed1ce80344d6b66451f4fc1ac","a83197299fa441e30495e253e46c62fb8507cbe7","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\bbda5d2ab5ced73c0016c6ce4d1943cb68b0ff8f"'
    + #13#10 +
    '"598c0d1d22cc9453832100036088adef","1b251307487ed6d1f0344faa44a85b8cf47b67c4","1801JT01 Dell Laptop.E01\Partition @ 206848\Root\Users\John Thomas Hamilton\AppData\Roaming\Apple Computer\MobileSync\Backup\82a1496e1e92995b1d77406adc2e71dcab0f4a41\d731d32165a98f412765a4cd4ca4d1384b9266b5"'),

    // ~2~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: '08c3b2fb6b0df220e936dff5d8a4c92f'; GD_Ref_Name: 'M'; Device_Logical_Size: 1000204886016; expected_AR_browsers_chrome_AUTOFILL_count: 354; expected_AR_browsers_chrome_CACHE_count: 28;
    expected_AR_browsers_chrome_COOKIES_count: 3137; expected_AR_browsers_chrome_DOWNLOADS_count: 0; expected_AR_browsers_chrome_FAVICONS_count: 1938; expected_AR_browsers_chrome_HISTORY_count: 1947;
    expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: 541; expected_AR_browsers_chrome_LOGINS_count: 41; expected_AR_browsers_chrome_SHORTCUTS_count: 6; expected_AR_browsers_chrome_SYNCDATA_count: 821;
    expected_AR_browsers_chrome_TOPSITES_count: 35; expected_AR_browsers_chromium_CACHE_count: 1119; expected_AR_browsers_chromium_COOKIES_count: 0; expected_AR_browsers_chromium_DOWNLOADS_count: 0;
    expected_AR_browsers_chromium_HISTORY_count: 0; expected_AR_browsers_chromium_KEYWORDSEARCHTERMS_count: 0; expected_AR_browsers_FIREFOX_BOOKMARKS_count: 46; expected_AR_browsers_FIREFOX_COOKIES_count: 821;
    expected_AR_browsers_FIREFOX_DOWNLOADS_count: 10; expected_AR_browsers_FIREFOX_FAVICONS_count: 87; expected_AR_browsers_FIREFOX_FORMHISTORY_count: 178; expected_AR_browsers_FIREFOX_HISTORYVISITS_count: 1978;
    expected_AR_browsers_FIREFOX_PLACES_count: 897; expected_AR_browsers_IE1011_CARVE_COOKIES_count: 509; expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: 646; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: 509;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: 52; expected_AR_browsers_IE1011_CARVECONTENT_count: 7631; expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: 892;
    expected_AR_browsers_IE1011_ESECONTENT_count: 4992; expected_AR_browsers_IE1011_ESECOOKIES_count: 510; expected_AR_browsers_IE1011_ESEDEPENDENCYENTRIES_count: 50; expected_AR_browsers_IE1011_ESEDOWNLOADS_count: 5;
    expected_AR_browsers_IE1011_ESEHISTORY_count: 364; expected_AR_browsers_IE49_COOKIE_count: 0; expected_AR_browsers_IE49_DAILY_count: 0; expected_AR_browsers_IE49_HISTORY_count: 0; expected_AR_browsers_IE49_NORMAL_count: 0;
    expected_AR_browsers_SAFARI_BOOKMARKS_count: 393; expected_AR_browsers_SAFARI_CACHE_count: 0; expected_AR_browsers_SAFARI_COOKIES_count: 188241; expected_AR_browsers_SAFARI_HISTORY_count: 145;
    expected_AR_browsers_SAFARI_HISTORY_IOS8_count: 1111; expected_AR_browsers_SAFARI_RECENTSEARCHES_count: 50; expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: 1470; expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: 74631;
    expected_AR_chat_SKYPE_ACCOUNTS_count: 4; expected_AR_chat_SKYPE_CALLS_count: 3; expected_AR_chat_SKYPE_CONTACTS_count: 250; expected_AR_chat_SKYPE_MESSAGES_count: 24; expected_AR_chat_SKYPE_TRANSFERS_count: 0;
    expected_AR_chat_SNAPCHAT_USER_IOS_count: 6; expected_AR_chat_TELEGRAM_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_IOS_count: 428; expected_AR_chat_VIBER_CHAT_PC_count: 0; expected_AR_chat_WHATSAPP_CALLS_IOS_count: 12;
    expected_AR_chat_WHATSAPP_CHAT_IOS_count: 155491; expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: 0; expected_AR_mac_OS_TIMEZONE_MACOS_count: 0; expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: 484;
    expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: 0; expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: 2007; expected_AR_mobile_CALL_HISTORY_IOS_count: 12083; expected_AR_mobile_CONTACT_DETAILS_IOS_count: 5423;
    expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: 0; expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: 0; expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: 4198; expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: 15240;
    expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: 1629; expected_AR_mobile_GOOGLEMAPS_IOS_count: 0; expected_AR_mobile_ITUNESBACKUP_DETAILS_count: 15; expected_AR_mobile_MAPS_IOS_count: 0;
    expected_AR_mobile_NOTE_ITEMS_IOS_count: 90; expected_AR_mobile_SMS_V3_IOS_count: 0; expected_AR_mobile_SMS_V4_IOS_count: 74851; expected_AR_mobile_USER_SHORTCUT_DICTIONARY_IOS_count: 25; expected_AR_mobile_VOICE_MAIL_IOS_count: 1828;
    expected_AR_mobile_VOICE_MEMOS_IOS_count: 0; expected_AR_mobile_WIFI_CONFIGURATIONS_IOS_count: 462; expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0'; expected_AR_windows_os_PREFETCH_WINDOWS_count: 257;
    expected_AR_windows_OS_WIFI_WINDOWS_count: 7; expected_BM_30to39_count_str: '0'; expected_BM_40to49_count_str: '0'; expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '525'; expected_BM_70to79_count_str: '204';
    expected_BM_80to89_count_str: '111'; expected_BM_90to99_count_str: '55'; expected_BM_Triagecount_count_str: '534'; expected_BM_VideoSkintone_count_str: '1'; expected_EM_ext_avi_count_str: '3'; expected_EM_ext_exe_count_str: '0';
    expected_EM_ext_jpg_count_str: '9455'; expected_EM_ext_wmv_count_str: '67'; expected_EM_ext_zip_count_str: '23'; expected_EM_sig_avi_count_str: '3'; expected_EM_sig_exe_count_str: '1'; expected_EM_sig_jpg_count_str: '9558';
    expected_EM_sig_wmv_count_str: '67'; expected_EM_sig_zip_count_str: '22'; expected_FS_carved_camera_sig_jpg_count: 86869; expected_FS_custom_byte_carve_pagefile_jpg_count: 10000; expected_FS_ext_avi_count_str: '47';
    expected_FS_ext_exe_count_str: '4583'; expected_FS_ext_jpg_count_str: '28273'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '393'; // plist
    expected_FS_ext_pst_count_str: '3'; // pst
    expected_FS_ext_wmv_count_str: '1374'; expected_FS_ext_zip_count_str: '29'; expected_FS_logical_free_space_on_disk: 8068096; expected_FS_metadata_271Canon_count: 5013; expected_FS_metadata_271Make_carved_count: 0;
    expected_FS_metadata_271Make_normal_count: 51893; expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 692952; expected_FS_partition_count: 7; expected_FS_partitions_sum_size: 1000196797952;
    expected_FS_recovered_folders: '6980769'; expected_FS_sig_avi_count_str: '23'; expected_FS_sig_exe_count_str: '43538'; expected_FS_sig_jpg_count_str: '169295'; expected_FS_sig_maxsigtime: 1500; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '9038'; // plist
    expected_FS_sig_pst_count_str: '3'; // pst
    expected_FS_sig_wmv_count_str: '1162'; expected_FS_sig_zip_count_str: '1205'; expected_FS_unalloc_ntfs_vol_size: 269686816768; expected_FS_verification_MD5: 'd7d3f035b60eee6ab6974858a234b460';
    expected_FS_verification_SHA1: '61e9f61b3464d84e96078076517db6c1d4b194be'; expected_FS_verification_SHA256: '425ceba9ddc035d58690d0d22badb289831cf99fe118d7ef21015bcf66ae742b'; expected_KW_keyword1: 'oatley'; // noslz
    expected_KW_keyword1_file_count_str: '74'; expected_KW_keyword1_hits_count_str: '864'; expected_KW_keyword1_regex: 'lowb[a-z]+alarm'; // noslz
    expected_KW_keyword1_regex_file_count_str: '18'; expected_KW_keyword1_regex_hits_count_str: '174'; expected_KW_keyword2: 'kogarah'; // noslz
    expected_KW_keyword2_file_count_str: '150'; expected_module_count_Artifacts_str: '583265|583101'; expected_module_count_Email: '31343'; expected_module_count_Registry: 4074058;

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"9f7e035e6c7e312598575c37a622191d","2ec8f729c0db8429c6436b2e0982e1dbfe93d957","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\PARENT QUESTIONNAIRE FORM 2014.doc"' + #13#10 +
    '"6ac28153ce69d71fcef6289968f897e7","1d05efad8fe708e97670fc83f0b5eeff018a470c","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\Christmas_event_fB_Banner.jpg"' + #13#10 +
    '"0527f4d42d12cf51133f88002d23fed6","995f3a960518873995299642d68b087a5949fece","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\bth_lawn-mower1.png"' + #13#10 +
    '"eeb06f0ed6e92c79e66e1f7578853395","6b01e8a43ac27a89574651009aa58a35bf6b2e8a","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\Thumbs.db"' + #13#10 +
    '"ba28faf55989cef171d8d30dcfcebcaf","19db2fe99bf895958b41873aa8fab2c5e5cdc218","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\LOGO V&C.pdf"' + #13#10 +
    '"605fd573c7194b478a6dcae1190c1240","a23c62964e6dc7620b83c0d56b7b4df5fa3e2696","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\MYOB+Vista.lnk"' + #13#10 +
    '"c85b7ad1203646ac294d90b9ba0647fc","8cee560adf1c0e8a8e7c2f75f1746f869f71fd2a","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\SFB Orange Clutch Pic.JPG"' + #13#10 +
    '"9c07eb2274c75e2890c19c69dbc5fbac","2f43091846f8c4034344842ba997cbde2ede56ea","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\CV  James Anezis.docx"' + #13#10 +
    '"af44433ba761343f6cee1c71dfc32520","adf02c57329e25819bddaf482e4546a708797ecf","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\vandc logo photo.JPG"' + #13#10 +
    '"bb58ae138e1b7d478e90078c610aac10","22ac34a4aa25829af184198fed9f12c6e7bfdda0","1tb_hp_laptop.E01\Basic data partition (EFI 4)\Root\Users\maria\Desktop\Old Firefox Data\feee13mr.default\xulstore.json"'),

    // ~3~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: 'f29f4301f10ab350b4774b14ae654634'; GD_Ref_Name: 'Demo7'; Device_Logical_Size: 6284081152; expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0'; expected_BM_30to39_count_str: '0'; // 15/10/2019 '8';
    expected_BM_40to49_count_str: '0'; // 15/10/2019 '25';
    expected_BM_50to59_count_str: '0'; // 15/10/2019 '31';
    expected_BM_60to69_count_str: '9'; // 26/11/2019 '0';
    expected_BM_70to79_count_str: '5'; // 26/11/2019 '4';
    expected_BM_80to89_count_str: '4'; // 26/11/2019 '3';
    expected_BM_90to99_count_str: '0'; // 15/10/2019 '3';
    expected_BM_Triagecount_count_str: '653'; expected_BM_VideoSkintone_count_str: '0'; // 27/11/2019 '13';
    expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '26'; expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0';
    expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '31'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '0'; expected_FS_carved_camera_sig_jpg_count: 1338;
    expected_FS_custom_byte_carve_pagefile_jpg_count: 0; expected_FS_ext_avi_count_str: '1'; expected_FS_ext_exe_count_str: '0'; expected_FS_ext_jpg_count_str: '641'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '0'; // plist
    expected_FS_ext_pst_count_str: '1'; // pst
    expected_FS_ext_wmv_count_str: '2'; expected_FS_ext_zip_count_str: '2'; expected_FS_logical_free_space_on_disk: 5318692864; expected_FS_metadata_271Canon_count: 14; expected_FS_metadata_271Make_carved_count: 0;
    expected_FS_metadata_271Make_normal_count: 338; expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 930; expected_FS_partition_count: 0; expected_FS_partitions_sum_size: 0;
    expected_FS_recovered_folders: '738|940'; // 15/10/2019 744;
    expected_FS_sig_avi_count_str: '1'; expected_FS_sig_exe_count_str: '1'; expected_FS_sig_jpg_count_str: '647'; expected_FS_sig_maxsigtime: 60; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '0'; // plist
    expected_FS_sig_pst_count_str: '1'; // pst
    expected_FS_sig_wmv_count_str: '2'; expected_FS_sig_zip_count_str: '2'; expected_FS_unalloc_ntfs_vol_size: 5318692864; expected_FS_verification_MD5: '8cec701511cfc88841963c8c19c77947';
    expected_FS_verification_SHA1: '1f694d438470a12726aed8838e26759c64e58031'; expected_FS_verification_SHA256: 'fde47e487819d922092eef4ac1a00c9928eb04f75450ce2d91e1fdeb871c73e3'; expected_KW_keyword1: 'hello'; // noslz
    expected_KW_keyword1_file_count_str: '9'; expected_KW_keyword1_hits_count_str: '35'; expected_KW_keyword1_regex: 'quality = [0-9][0-9]'; // noslz
    expected_KW_keyword1_regex_file_count_str: '36'; expected_KW_keyword1_regex_hits_count_str: '36'; expected_KW_keyword2: 'canon eos'; // noslz
    expected_KW_keyword2_file_count_str: '14'; expected_KW_keyword2_hits_count_str: '26'; expected_module_count_Artifacts_str: '10'; expected_module_count_Email: '645'; expected_module_count_Registry: 767901;

    ftk_imager_output_str: '"3d5a4fd40a2b46f0d4f906e633378183","5dd1a6e42e31759848f1485b63d0ec6fb8d1e6c0","DEMO 7.E01\Root\Aircraft Photos\B24\FLYBY.JPG"' + #13#10 +
    '"ab410feda42fbf59be02e1128cb46b5c","072b1e17a989a8d2c93f08e03b26e0c460d743b7","DEMO 7.E01\Root\Aircraft Photos\B24\COCKPIT.JPG"' + #13#10 +
    '"56695b95c491fbecbf8356cc4476d1d1","aebb936aa4c596c7af0ddb453f2842d294633a07","DEMO 7.E01\Root\Aircraft Photos\B24\BOMBBAY3.JPG"' + #13#10 +
    '"e1a1e0a952e6c2712069fedb37100cf0","f4e6f46a2ccfa4d947d1f92e70fc20ad61e5b1bb","DEMO 7.E01\Root\Aircraft Photos\B24\BOMBBAY2.JPG"' + #13#10 +
    '"89ec51dd637b2dd2d8b5e0724ff2b3c1","339f832842eaaf4964b6dc5537160e5569456428","DEMO 7.E01\Root\Aircraft Photos\B24\BOMBBAY.JPG"' + #13#10 +
    '"80b83f8e0d24f3517dbaf2d264a2ec05","1b9b9588dade5594348ae05fe5ca940cd05a17c2","DEMO 7.E01\Root\Aircraft Photos\B24\all4going.JPG"' + #13#10 +
    '"d268d92866267c0120fbbcf1a8bac837","643e0d8cfeb489a4839cd2e7fbfbfb3c032a2405","DEMO 7.E01\Root\Aircraft Photos\B24\9.JPG"' + #13#10 +
    '"6d49f8f35aeeeac361b9bc5d859f73a6","de908e4ad885de08479a01e68dcc921219a92ff6","DEMO 7.E01\Root\Aircraft Photos\B24\8.JPG"' + #13#10 +
    '"5e8970b6213f3000f64b4d2383fec88f","10a7239a63dce02a01c2bc45572dde33de8c3c26","DEMO 7.E01\Root\Aircraft Photos\B24\7.JPG"' + #13#10 +
    '"a90f8e0ab0560a9f838d792c7a51ca31","810118dbfcce5250f4c10710ae19f913ef17cfc3","DEMO 7.E01\Root\Aircraft Photos\B24\6.JPG"'),

    // ~4~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: '0d8098160d8997a855415040f5bf0774'; GD_Ref_Name: 'J'; Device_Logical_Size: 320072933376; expected_AR_browsers_IE49_DAILY_count: 18; // 10/03/2021 19;
    expected_AR_browsers_IE49_HISTORY_count: 23; // 10/03/2021 23;
    expected_AR_browsers_IE49_NORMAL_count: 1630; // 10/03/2021 1648;
    expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0|121'; expected_AR_windows_os_PREFETCH_WINDOWS_count: 129; expected_BM_30to39_count_str: '0'; // 21/10/2019 '1161';
    expected_BM_40to49_count_str: '0'; // 21/10/2019 '1755';
    expected_BM_50to59_count_str: '0'; // 21/10/2019 '1881';
    expected_BM_60to69_count_str: '178'; // '147'; // 27/11/2019
    expected_BM_70to79_count_str: '113'; // '102'; // 27/11/2019
    expected_BM_80to89_count_str: '57'; // '46'; // 27/11/2019
    expected_BM_90to99_count_str: '16'; // 21/10/2019 '308';
    expected_BM_Triagecount_count_str: '151'; expected_BM_VideoSkintone_count_str: '516'; // 21/10/2019 '1874';
    expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '10'; // 21/10/2019 '24';
    expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '8'; // 21/10/2019 '21';
    expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '0'; expected_FS_carved_camera_sig_jpg_count: 39367; expected_FS_custom_byte_carve_pagefile_jpg_count: 3585; expected_FS_ext_avi_count_str: '78';
    expected_FS_ext_exe_count_str: '3009'; // 21/10/2019 '3011';
    expected_FS_ext_jpg_count_str: '58310'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '0'; // plist
    expected_FS_ext_pst_count_str: '1'; // pst
    expected_FS_ext_wmv_count_str: '131'; expected_FS_ext_zip_count_str: '2364'; expected_FS_logical_free_space_on_disk: 2448896; expected_FS_metadata_271Canon_count: 8688; // 21/10/2019 8511;
    expected_FS_metadata_271Make_carved_count: 0; expected_FS_metadata_271Make_normal_count: 20525; // 21/10/2019 20113;
    expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 0; expected_FS_partition_count: 5; expected_FS_partitions_sum_size: 521541669888; expected_FS_recovered_folders: '27'; expected_FS_sig_avi_count_str: '78';
    expected_FS_sig_exe_count_str: '31778'; expected_FS_sig_jpg_count_str: '57724'; expected_FS_sig_maxsigtime: 600; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '0'; // plist
    expected_FS_sig_pst_count_str: '1'; // pst
    expected_FS_sig_wmv_count_str: '131'; // 21/10/2019 '163';
    expected_FS_sig_zip_count_str: '2839'; // 17/09/21 - 2728
    expected_FS_unalloc_ntfs_vol_size: 165966163968; expected_FS_verification_MD5: '7f681898a029454dcb2868d948f39d19'; expected_FS_verification_SHA1: 'cca4e3262c02de444a5a352ccc9fe93cdac2b3a5';
    expected_FS_verification_SHA256: '8719af3e3baa7e3199762263c7093e9396554c65804aa529cbe5e846495c94df'; expected_KW_keyword1: 'olympus'; // noslz
    expected_KW_keyword1_file_count_str: '468'; expected_KW_keyword1_regex: 'lowb[a-z]+alarm'; // noslz
    expected_KW_keyword1_regex_file_count_str: '29'; expected_KW_keyword1_regex_hits_count_str: '52'; expected_KW_keyword2: 'thailand'; // noslz
    expected_KW_keyword2_file_count_str: '456'; expected_module_count_Artifacts_str: '1811'; expected_module_count_Email: '247'; // 21/10/2019 286;
    expected_module_count_Registry: 837036;

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"3db9bcdd7a666cf3795d573c7cf1a0d3","90e06139622f98a07f55de66461a71598dcc44b8","Jesper Laptop PST.E01\Partition @ 26830848\Root\ProgramData\OberonGameConsole\Acer\assets\115455520\4_elements1.jpg"' + #13#10 +
    '"f9c54533b6aead25266b6f219f0dfb32","4c32c03b573bb153ef9c754ac1c5c2befa176e7c","Jesper Laptop PST.E01\Partition @ 26830848\Root\ProgramData\OberonGameConsole\Acer\assets\115455520\4_elements1t.jpg"' + #13#10 +
    '"824af3c32a9c1b46365ba10b469214d1","4055b20a979b37546cce28bd1de3c6a695051aa2","Jesper Laptop PST.E01\Partition @ 26830848\Root\ProgramData\OberonGameConsole\Acer\assets\115455520\4_elements2.jpg"' + #13#10 +
    '"3164f90a244b4f40a7bbe5215e0876e7","18c0a384a05b22990046ed534aa9460e3cd50e2a","Jesper Laptop PST.E01\Partition @ 26830848\Root\ProgramData\OberonGameConsole\Acer\assets\115455520\4_elements2t.jpg"' + #13#10 +
    '"384b64d2bd77819862a91b58a301942c","a69855ac98921831a4adfb5cacec5695408e6dcd","Jesper Laptop PST.E01\Partition @ 26830848\Root\oem\Preload\Autorun\AutorunX\HowtoUse\Images\menu_arrow_sm.gif"' + #13#10 +
    '"b18e78598c6525431b3ecd8e72bc6e68","2a99b798c1f6a8e4660d3fbd32451efeb4bcd387","Jesper Laptop PST.E01\Partition @ 26830848\Root\oem\Preload\Autorun\AutorunX\HowtoUse\Images\menu_arrow_dn.gif"' + #13#10 +
    '"314723e10875198e67235832fc69997e","cd6a947df1270b53be32f8bef33414e6061f3a81","Jesper Laptop PST.E01\Partition @ 26830848\Root\oem\Preload\Autorun\DRV\LaunchMgr\OSDRC\Vol_000.png"' + #13#10 +
    '"e02ee485207b4f015b0ec098e1ef411c","ca418e7d902ddf03ce56f696e43cf82eab4d4063","Jesper Laptop PST.E01\Partition @ 26830848\Root\oem\Preload\Autorun\DRV\LaunchMgr\OSDRC\Vol_001.png"' + #13#10 +
    '"9fec69f845805862fe1465f3fbe86a3b","6da77ef171b37569c3a5ded70b1eb2ac98fd63f6","Jesper Laptop PST.E01\Partition @ 26830848\Root\oem\Preload\Autorun\DRV\LaunchMgr\OSDRC\Vol_002.png"'),

    // ~5~
    (Image_Name: '13f32554ac0a58024c488a1a441e8ce4'; GD_Ref_Name: 'I2018'; Device_Logical_Size: 1000204886016; expected_AR_browsers_chrome_AUTOFILL_count: 72; expected_AR_browsers_chrome_CACHE_count: 8577;
    expected_AR_browsers_chrome_COOKIES_count: 1064; expected_AR_browsers_chrome_DOWNLOADS_count: 14; expected_AR_browsers_chrome_FAVICONS_count: 207; expected_AR_browsers_chrome_HISTORY_count: 265;
    expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: 35; expected_AR_browsers_chrome_LOGINS_count: 2; expected_AR_browsers_chrome_SHORTCUTS_count: 0; expected_AR_browsers_chrome_SYNCDATA_count: 158;
    expected_AR_browsers_chrome_TOPSITES_count: 7; expected_AR_browsers_FIREFOX_BOOKMARKS_count: 69; expected_AR_browsers_FIREFOX_COOKIES_count: 1494; expected_AR_browsers_FIREFOX_DOWNLOADS_count: 43;
    expected_AR_browsers_FIREFOX_FAVICONS_count: 3; expected_AR_browsers_FIREFOX_FORMHISTORY_count: 22; expected_AR_browsers_FIREFOX_HISTORYVISITS_count: 654; expected_AR_browsers_FIREFOX_PLACES_count: 368;
    expected_AR_browsers_IE1011_CARVE_COOKIES_count: 997; expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: 624; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: 6284;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: 159; expected_AR_browsers_IE1011_CARVECONTENT_count: 35285; expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: 880;
    expected_AR_browsers_IE1011_ESECONTENT_count: 11915; expected_AR_browsers_IE1011_ESECOOKIES_count: 745; expected_AR_browsers_IE1011_ESEDEPENDENCYENTRIES_count: 136; expected_AR_browsers_IE1011_ESEDOWNLOADS_count: 23;
    expected_AR_browsers_IE1011_ESEHISTORY_count: 5575; expected_AR_browsers_IE49_COOKIE_count: 0; expected_AR_browsers_IE49_DAILY_count: 0; expected_AR_browsers_IE49_HISTORY_count: 0; expected_AR_browsers_IE49_NORMAL_count: 0;
    expected_AR_browsers_SAFARI_BOOKMARKS_count: 10; expected_AR_browsers_SAFARI_CACHE_count: 0; expected_AR_browsers_SAFARI_COOKIES_count: 44; expected_AR_browsers_SAFARI_HISTORY_count: 13;
    expected_AR_browsers_SAFARI_RECENTSEARCHES_count: 3; expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: 0; expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: 30; expected_AR_chat_SKYPE_ACCOUNTS_count: 3; expected_AR_chat_SKYPE_CALLS_count: 4;
    expected_AR_chat_SKYPE_CONTACTS_count: 136; expected_AR_chat_SKYPE_MESSAGES_count: 130; expected_AR_chat_SKYPE_TRANSFERS_count: 0; expected_AR_chat_SNAPCHAT_USER_IOS_count: 0; expected_AR_chat_TELEGRAM_CHAT_IOS_count: 13;
    expected_AR_chat_VIBER_CHAT_IOS_count: 1; expected_AR_chat_VIBER_CHAT_PC_count: 0; expected_AR_chat_WHATSAPP_CALLS_IOS_count: 0; expected_AR_chat_WHATSAPP_CHAT_IOS_count: 0; expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: 0;
    expected_AR_mac_OS_TIMEZONE_MACOS_count: 0; expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: 34; expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: 0; expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: 1;
    expected_AR_mobile_CALL_HISTORY_IOS_count: 5; expected_AR_mobile_CONTACT_DETAILS_IOS_count: 4; expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: 0; expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: 0;
    expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: 0; expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: 67; expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: 0; expected_AR_mobile_GOOGLEMAPS_IOS_count: 0;
    expected_AR_mobile_ITUNESBACKUP_DETAILS_count: 1; expected_AR_mobile_MAPS_IOS_count: 0; expected_AR_mobile_NOTE_ITEMS_IOS_count: 0; expected_AR_mobile_SMS_V3_IOS_count: 0; expected_AR_mobile_SMS_V4_IOS_count: 30;
    expected_AR_mobile_VOICE_MAIL_IOS_count: 0; expected_AR_mobile_VOICE_MEMOS_IOS_count: 0; expected_AR_mobile_WIFI_CONFIGURATIONS_IOS_count: 2; expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0';
    expected_AR_windows_os_PREFETCH_WINDOWS_count: 188; expected_AR_windows_OS_WIFI_WINDOWS_count: 13; expected_BM_30to39_count_str: '0'; // 26/11/2019 '215';
    expected_BM_40to49_count_str: '0'; // 26/11/2019 '409';
    expected_BM_50to59_count_str: '0'; // 26/11/2019 '497';
    expected_BM_60to69_count_str: '6'; // 07/11/2019 '156';
    expected_BM_70to79_count_str: '0'; // 07/11/2019 '92';
    expected_BM_80to89_count_str: '0'; // 07/11/2019 '65';
    expected_BM_90to99_count_str: '0'; // 07/11/2019 '48';
    expected_BM_Triagecount_count_str: '527'; expected_BM_VideoSkintone_count_str: '9'; // 07/11/2019 '50';
    expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '0'; expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0';
    expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '0'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '0'; expected_FS_carved_camera_sig_jpg_count: 1995; // 07/11/2019 '0';
    expected_FS_custom_byte_carve_pagefile_jpg_count: 20; expected_FS_ext_avi_count_str: '40'; expected_FS_ext_exe_count_str: '3844'; // 24/9/19 '3849';
    expected_FS_ext_jpg_count_str: '5160'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '323'; // plist
    expected_FS_ext_pst_count_str: '0'; // pst
    expected_FS_ext_wmv_count_str: '12'; expected_FS_ext_zip_count_str: '313'; expected_FS_logical_free_space_on_disk: 134652047360; expected_FS_metadata_271Canon_count: 71; expected_FS_metadata_271Make_carved_count: 1;
    expected_FS_metadata_271Make_normal_count: 149; expected_FS_metadata_271Make_recfld_count: 1; expected_FS_number_of_files: 6888268; expected_FS_partition_count: 4; expected_FS_partitions_sum_size: 201532111872;
    expected_FS_recovered_folders: '900709'; // 07/11/2019 '0';
    expected_FS_sig_avi_count_str: '3'; expected_FS_sig_exe_count_str: '15199'; expected_FS_sig_jpg_count_str: '10026'; expected_FS_sig_maxsigtime: 400; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '2639'; // plist
    expected_FS_sig_pst_count_str: '0'; // pst
    expected_FS_sig_wmv_count_str: '10'; // 24/9/19 '145';
    expected_FS_sig_zip_count_str: '1040'; // 24/9/19 '1040', 17/09/21 '1031';
    expected_FS_unalloc_ntfs_vol_size: 134652047360; expected_FS_verification_MD5: 'abf0760e7fe54ee484b542d410e5a06e'; expected_FS_verification_SHA1: '164bdc0dd090bf97d4da465c69985a24c4ae3394'; expected_FS_verification_SHA256: '';
    expected_KW_keyword1: 'custom chopper'; // noslz
    expected_KW_keyword1_file_count_str: '13'; expected_KW_keyword1_hits_count_str: '62'; expected_KW_keyword1_regex: 'lowb[a-z]+alarm'; // noslz
    expected_KW_keyword1_regex_file_count_str: '16'; expected_KW_keyword1_regex_hits_count_str: '73'; expected_KW_keyword2: 'firearm'; // noslz  // 26 Nov 21 CLI returns 67/245 TokenBrokerCookies.exe~WofCompressedData
    expected_KW_keyword2_file_count_str: '66'; expected_KW_keyword2_hits_count_str: '244'; expected_module_count_Artifacts_str: '76659'; expected_module_count_Email: '0'; expected_module_count_Registry: 2862683;
    expected_RG_computername: 'LAPTOP-P1152C03'; expected_RG_computername_count: 1;

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"07a95f192a8c3eca0e23bf3957cbad43","ad8970e4c57e200a822cae19242322e04958b585","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\Windows\Microsoft.NET\Framework\v4.0.30319\ASP.NETWebAdminFiles\Images\topGradRepeat.jpg"' + #13#10 +
    '"f899f1f6ae635490af9f2d09334312cd","be5a5e151e725aa566002ed1ddddbada735cb9e3","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\Windows\Microsoft.NET\Framework64\v2.0.50727\ASP.NETWebAdminFiles\Images\help.jpg"' + #13#10 +
    '"4a351628c28ba24ffe3c4baeef6381dc","1ddf9cec8888679d2e9ca122dacb1f2025370bed","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\$Recycle.Bin\S-1-5-21-4044153102-3296780963-1271967797-1001\$I114M8E.jpg"' + #13#10 +
    '"37d4335f8f1fa2019149338ec58c7f8e","efbe994f9cf2c552aef55c117b5644933da293ae","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\OEM\CaringCenter\DRV\Realtek LAN_M RTL8111\QUICK_INSTALL_GUIDE\Inst01.jpg"' + #13#10 +
    '"ec9a1e6a51642813108a18d4d3bb53ac","5681d7b47085a7f162a76053eeca50261f45629e","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\OEM\Preload\DPOP\OEMResource\Logo\Founder\FOUNDER.jpg"' + #13#10 +
    '"35cdaafd327812982f714e78404654df","b6a3a4c64bc0497ff7884680222906a096849923","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\Program Files (x86)\Brother\Brmfl08x\BrotherAtYourLogo.jpg"' + #13#10 +
    '"093ac5707ff5ffaab5064cc243052373","cb0dfbe31f0dc62dffdfda0c47f74fc3af94c793","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\Program Files\WindowsApps\9E2F88E3.Twitter_5.8.1.0_x86__wgeqdkkx372wm\Assets\Periscope\trim.mp4"' +
    #13#10 + '"19d51ae4ba2b9fd88c9a04d4436a8a78","9dc20dc34adbe7fd020d664253af92048daf2452","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\Program Files\WindowsApps\A278AB0D.MarchofEmpires_2.7.0.13_x86__h6adky7gbf63m\Assets\GameData\movies\gah_intro.mp4"'
    + #13#10 +
    '"95757f5ec280d1e8d041896b18d3ecfe","806fccd1c08b8e31e9d49fcdc3c4acc18753ec3c","IACIS - SPI 2018.E01\Basic data partition (EFI 2)\Root\Program Files\WindowsApps\Microsoft.MSPaint_3.1709.5027.0_x64__8wekyb3d8bbwe\Assets\Videos\Help\DialRotation.mp4"'),

    // ~6~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: '771e3fe62af2b98d287c68894e09f09e'; GD_Ref_Name: 'A'; Device_Logical_Size: 121332826112; expected_AR_browsers_chrome_AUTOFILL_count: 1793; expected_AR_browsers_chrome_CACHE_count: 2915; // 2918
    expected_AR_browsers_chrome_COOKIES_count: 2678; // 2679
    expected_AR_browsers_chrome_DOWNLOADS_count: 747; expected_AR_browsers_chrome_FAVICONS_count: 2290; expected_AR_browsers_chrome_HISTORY_count: 2211; expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: 316;
    expected_AR_browsers_chrome_LOGINS_count: 8; expected_AR_browsers_chrome_SHORTCUTS_count: 164; expected_AR_browsers_chrome_SYNCDATA_count: 0; expected_AR_browsers_chrome_TOPSITES_count: 20; expected_AR_browsers_chromium_CACHE_count: 3;
    expected_AR_browsers_FIREFOX_BOOKMARKS_count: 15; expected_AR_browsers_FIREFOX_COOKIES_count: 1953; expected_AR_browsers_FIREFOX_DOWNLOADS_count: 3; expected_AR_browsers_FIREFOX_FAVICONS_count: 145;
    expected_AR_browsers_FIREFOX_FORMHISTORY_count: 3; expected_AR_browsers_FIREFOX_HISTORYVISITS_count: 1378; expected_AR_browsers_FIREFOX_PLACES_count: 1039; expected_AR_browsers_IE1011_CARVE_COOKIES_count: 0;
    expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: 0; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: 0; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: 0;
    expected_AR_browsers_IE1011_CARVECONTENT_count: 0; expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: 0; expected_AR_browsers_IE49_COOKIE_count: 0; expected_AR_browsers_IE49_DAILY_count: 0;
    expected_AR_browsers_IE49_HISTORY_count: 0; expected_AR_browsers_IE49_NORMAL_count: 0; expected_AR_browsers_SAFARI_BOOKMARKS_count: 37; expected_AR_browsers_SAFARI_CACHE_count: 2753; expected_AR_browsers_SAFARI_COOKIES_count: 528;
    // 539;
    expected_AR_browsers_SAFARI_HISTORY_count: 2278; // 1612;
    expected_AR_browsers_SAFARI_HISTORY_IOS8_count: 106; expected_AR_browsers_SAFARI_RECENTSEARCHES_count: 0; expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: 4630; expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: 79191;
    expected_AR_chat_SKYPE_ACCOUNTS_count: 2; expected_AR_chat_SKYPE_CALLS_count: 104; expected_AR_chat_SKYPE_CONTACTS_count: 17; expected_AR_chat_SKYPE_MESSAGES_count: 502; expected_AR_chat_SKYPE_TRANSFERS_count: 11;
    expected_AR_chat_SNAPCHAT_USER_IOS_count: 0; expected_AR_chat_TELEGRAM_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_PC_count: 0; expected_AR_chat_WHATSAPP_CALLS_IOS_count: 0;
    expected_AR_chat_WHATSAPP_CHAT_IOS_count: 0; expected_AR_chat_ZELLO_CHAT_ANDROID_count: 0; expected_AR_mac_OS_ADDRESSBOOKME_MACOS_count: 1; expected_AR_mac_OS_ATTACHED_IDEVICES_MACOS_count: 6;
    expected_AR_mac_OS_BLUETOOTH_MACOS_count: 7; expected_AR_mac_OS_DOCK_ITEMS_MACOS_count: 15; expected_AR_mac_OS_ICLOUD_PREFERENCES_MACOS_count: 1; expected_AR_mac_OS_IMESSAGE_ACCOUNTS_MACOS_count: 1;
    expected_AR_mac_OS_INSTALLATION_DATE_MACOS_count: 1; expected_AR_mac_OS_INSTALLED_PRINTERS_MACOS_count: 2; expected_AR_mac_OS_LAST_SLEEP_MACOS_count: 1; expected_AR_mac_OS_LOGIN_ITEMS_MACOS_count: 4;
    expected_AR_mac_OS_LOGIN_WINDOW_MACOS_count: 1; expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: 1; expected_AR_mac_OS_OSX_UPDATE_MACOS_count: 1; expected_AR_mac_OS_PHOTO_BOOTH_RECENTS_MACOS_count: 8;
    expected_AR_mac_OS_RECENT_ITEMS_APPLICATIONS_MACOS_count: 12; expected_AR_mac_OS_RECENT_ITEMS_DOCUMENTS_MACOS_count: 10; expected_AR_mac_OS_RECENT_ITEMS_HOSTS_MACOS_count: 2; expected_AR_mac_OS_RECENT_SAFARI_SEARCHES_MACOS_count: 10;
    expected_AR_mac_OS_RECENT_VIDEOLAN_MACOS_count: 0; expected_AR_mac_OS_SAFARI_PREFERENCES_MACOS_count: 1; expected_AR_mac_OS_SYSTEM_VERSION_MACOS_count: 2; expected_AR_mac_OS_TIMEZONE_LOCAL_MACOS_count: 1;
    expected_AR_mac_OS_TIMEZONE_MACOS_count: 1; expected_AR_mac_OS_WIFI_MACOS_count: 76; expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: 34; expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: 0; expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: 0;
    expected_AR_mobile_CALL_HISTORY_IOS_count: 135; expected_AR_mobile_CONTACT_DETAILS_IOS_count: 0; expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: 0; expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: 0;
    expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: 0; expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: 0; expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: 0; expected_AR_mobile_GOOGLEMAPS_IOS_count: 0;
    expected_AR_mobile_ITUNESBACKUP_DETAILS_count: 0; expected_AR_mobile_MAPS_IOS_count: 0; expected_AR_mobile_NOTE_ITEMS_IOS_count: 0; expected_AR_mobile_SMS_V3_IOS_count: 0; expected_AR_mobile_SMS_V4_IOS_count: 79368;
    expected_AR_mobile_USER_SHORTCUT_DICTIONARY_IOS_count: 0; expected_AR_mobile_VOICE_MAIL_IOS_count: 0; expected_AR_mobile_VOICE_MEMOS_IOS_count: 0; expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0|115|116';
    expected_BM_30to39_count_str: '0'; expected_BM_40to49_count_str: '0'; expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '96'; expected_BM_70to79_count_str: '86'; expected_BM_80to89_count_str: '37';
    expected_BM_90to99_count_str: '114'; expected_BM_Triagecount_count_str: '83'; expected_BM_VideoSkintone_count_str: '8'; expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '0';
    expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '0'; expected_EM_sig_wmv_count_str: '0';
    expected_EM_sig_zip_count_str: '0'; expected_FS_carved_camera_sig_jpg_count: 1395; // 09-Dec-21 2586;
    expected_FS_custom_byte_carve_pagefile_jpg_count: 0; expected_FS_ext_avi_count_str: '0'; expected_FS_ext_exe_count_str: '19'; expected_FS_ext_jpg_count_str: '10527'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '21390'; // plist
    expected_FS_ext_pst_count_str: '502'; // pst
    expected_FS_ext_wmv_count_str: '2'; expected_FS_ext_zip_count_str: '109'; expected_FS_logical_free_space_on_disk: 0; expected_FS_metadata_271Canon_count: 91; expected_FS_metadata_271Make_carved_count: 0;
    expected_FS_metadata_271Make_normal_count: 1460; expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 0; expected_FS_partition_count: 3; expected_FS_partitions_sum_size: 120293572608;
    expected_FS_recovered_folders: '21'; expected_FS_sig_avi_count_str: '0'; expected_FS_sig_exe_count_str: '33'; expected_FS_sig_jpg_count_str: '11559'; expected_FS_sig_maxsigtime: 0; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '26977'; // plist
    expected_FS_sig_pst_count_str: '0'; // pst
    expected_FS_sig_wmv_count_str: '2'; expected_FS_sig_zip_count_str: '240'; expected_FS_unalloc_ntfs_vol_size: 0; expected_FS_verification_MD5: '5114a4796fba9b11cc51c337e84916f5';
    expected_FS_verification_SHA1: '0d3c353096cdbcc548eec64ef7b7b60b13170e5d'; expected_FS_verification_SHA256: '7ad4c5a9bdbc1151e4d7a1faa13a83410e4ae473d00b7463bf409b649b0b3eae'; expected_KW_keyword1: 'aaron'; // noslz
    expected_KW_keyword1_file_count_str: '231'; // 08-Dec-21 '229';
    expected_KW_keyword1_hits_count_str: '647'; // 08-Dec-21 '603';
    expected_KW_keyword1_regex: 'quality = [0-9][0-9]'; // noslz
    expected_KW_keyword1_regex_file_count_str: '262'; // 08-Dec-21 '260';
    expected_KW_keyword1_regex_hits_count_str: '400'; // 08-Dec-21 '271';
    expected_KW_keyword2: 'assignment'; // noslz
    expected_KW_keyword2_file_count_str: '471'; // 08-Dec-21 '466';
    expected_KW_keyword2_hits_count_str: '7259'; // 08-Dec-21 '5247';
    expected_module_count_Artifacts_str: '218845'; // 9-Dec-21 '218874';

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"1329233a958019237a891bf1dd8c3fab","0232e352413894fc2070e534061a6b34d4e20668","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\Library\Preferences\OpenDirectory\opendirectoryd.plist"' + #13#10 +
    '"c0cdca3dff35db05322839afaa6cedab","f60dc778e7b087cfff72d3dc664874de8f80f8f4","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\Library\Desktop Pictures\Abstract.jpg"' + #13#10 +
    '"e7dcabc4303410ccb370a3f3521771a5","d890ae4ea13fec3d6b2cc5da3a89aac0392373bc","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\Library\Desktop Pictures\Eagle & Waterfall.jpg"' + #13#10 +
    '"212da138ddedc0d4cc8630a374888732","01f5b834068baf5585f02492fcc5c31056c04199","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\Library\Desktop Pictures\Hawaiian Print.jpg"' + #13#10 +
    '"5b6f960c7532804e362d65aa6655eba2","c85666d1a60efde6dab44ec3a583536efed6ab58","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\Library\Desktop Pictures\Underwater.jpg"' + #13#10 +
    '"a2f8c44d215405902dfa4f6749b5b285","21c0227a142db7c5789097470bc36d29d96acd81","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\System\Library\PrivateFrameworks\LoginUIKit.framework\Versions\A\Frameworks\LoginUICore.framework\Versions\A\Resources\apple.png"'
    + #13#10 +
    '"2f6ad9d12d1c76c97998ae9bf0a37db9","bb18d615aef6b3a09d3588873f3a9515723c4439","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\System\Library\PrivateFrameworks\LoginUIKit.framework\Versions\A\Frameworks\LoginUICore.framework\Versions\A\Resources\cancel@2x.png"'
    + #13#10 +
    '"f86112da2cf2f7cc0ab15f380ae38c24","7cc63905d5dbf4e4499e071c5a6d797ef1645c93","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\System\Library\PrivateFrameworks\LoginUIKit.framework\Versions\A\Frameworks\LoginUICore.framework\Versions\A\Resources\login@2x.png"'
    + #13#10 + '"60f79d5482d63e8ca6da87e3ea7bbcdc","5566d9a783732e25ea88e060d59f884fd6236316","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\private\var\tmp\systemstats\powerstats.qGMbXc.txt"' + #13#10 +
    '"d42bf5fd99e7107e11ef27080a944c82","f432ecb01c449ee02ea23006dab9ded2ab9b8602","aaron-mac-128gb.E01\Macintosh HD (EFI 2)\Macintosh HD\Users\davisgee\Library\Messages\Attachments\20\00\1C89EB0F-ED3C-4319-8E0F-C36AF7467710\IMG_5079.MOV.mov"'),

    // ~7~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: 'f3addaf7a8141a2916b0a554cb30aa77'; GD_Ref_Name: 'C'; Device_Logical_Size: 160041885696; expected_AR_browsers_chrome_AUTOFILL_count: 585; expected_AR_browsers_chrome_CACHE_count: 4004; // 12 Dec 21 - 1901;
    expected_AR_browsers_chrome_COOKIES_count: 2868; expected_AR_browsers_chrome_DOWNLOADS_count: 103; expected_AR_browsers_chrome_FAVICONS_count: 2529; expected_AR_browsers_chrome_HISTORY_count: 12222;
    expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: 242; expected_AR_browsers_chrome_LOGINS_count: 5; expected_AR_browsers_chrome_SHORTCUTS_count: 0; expected_AR_browsers_chrome_SYNCDATA_count: 0;
    expected_AR_browsers_chrome_TOPSITES_count: 20; expected_AR_browsers_FIREFOX_BOOKMARKS_count: 0; expected_AR_browsers_FIREFOX_COOKIES_count: 0; expected_AR_browsers_FIREFOX_DOWNLOADS_count: 0;
    expected_AR_browsers_FIREFOX_FAVICONS_count: 0; expected_AR_browsers_FIREFOX_FORMHISTORY_count: 0; expected_AR_browsers_FIREFOX_HISTORYVISITS_count: 0; expected_AR_browsers_FIREFOX_PLACES_count: 0;
    expected_AR_browsers_IE1011_CARVE_COOKIES_count: 0; expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: 0; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: 0;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: 0; expected_AR_browsers_IE1011_CARVECONTENT_count: 0; expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: 0; expected_AR_browsers_IE49_COOKIE_count: 0;
    expected_AR_browsers_IE49_DAILY_count: 0; expected_AR_browsers_IE49_HISTORY_count: 0; expected_AR_browsers_IE49_NORMAL_count: 0; expected_AR_browsers_SAFARI_BOOKMARKS_count: 40; expected_AR_browsers_SAFARI_CACHE_count: 0;
    expected_AR_browsers_SAFARI_COOKIES_count: 0; expected_AR_browsers_SAFARI_HISTORY_count: 2; expected_AR_browsers_SAFARI_HISTORY_IOS8_count: 0; expected_AR_browsers_SAFARI_RECENTSEARCHES_count: 0;
    expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: 0; expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: 0; expected_AR_chat_SKYPE_ACCOUNTS_count: 1; expected_AR_chat_SKYPE_CALLS_count: 328; expected_AR_chat_SKYPE_CONTACTS_count: 28;
    expected_AR_chat_SKYPE_MESSAGES_count: 2466; expected_AR_chat_SKYPE_TRANSFERS_count: 26; expected_AR_chat_SNAPCHAT_USER_IOS_count: 0; expected_AR_chat_TELEGRAM_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_IOS_count: 0;
    expected_AR_chat_VIBER_CHAT_PC_count: 0; expected_AR_chat_WHATSAPP_CALLS_IOS_count: 0; expected_AR_chat_WHATSAPP_CHAT_IOS_count: 0; expected_AR_chat_ZELLO_CHAT_ANDROID_count: 0; expected_AR_mac_OS_ADDRESSBOOKME_MACOS_count: 1;
    expected_AR_mac_OS_ATTACHED_IDEVICES_MACOS_count: 8; expected_AR_mac_OS_BLUETOOTH_MACOS_count: 1; expected_AR_mac_OS_DOCK_ITEMS_MACOS_count: 12; expected_AR_mac_OS_ICLOUD_PREFERENCES_MACOS_count: 0;
    expected_AR_mac_OS_IMESSAGE_ACCOUNTS_MACOS_count: 0; expected_AR_mac_OS_INSTALLATION_DATE_MACOS_count: 1; expected_AR_mac_OS_INSTALLED_PRINTERS_MACOS_count: 0; expected_AR_mac_OS_LAST_SLEEP_MACOS_count: 1;
    expected_AR_mac_OS_LOGIN_ITEMS_MACOS_count: 7; expected_AR_mac_OS_LOGIN_WINDOW_MACOS_count: 1; expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: 3; expected_AR_mac_OS_OSX_UPDATE_MACOS_count: 1;
    expected_AR_mac_OS_PHOTO_BOOTH_RECENTS_MACOS_count: 0; expected_AR_mac_OS_RECENT_ITEMS_APPLICATIONS_MACOS_count: 10; expected_AR_mac_OS_RECENT_ITEMS_DOCUMENTS_MACOS_count: 10; expected_AR_mac_OS_RECENT_ITEMS_HOSTS_MACOS_count: 0;
    expected_AR_mac_OS_RECENT_SAFARI_SEARCHES_MACOS_count: 0; expected_AR_mac_OS_RECENT_VIDEOLAN_MACOS_count: 3; expected_AR_mac_OS_SAFARI_PREFERENCES_MACOS_count: 1; expected_AR_mac_OS_SYSTEM_VERSION_MACOS_count: 1;
    expected_AR_mac_OS_TIMEZONE_LOCAL_MACOS_count: 1; expected_AR_mac_OS_TIMEZONE_MACOS_count: 1; expected_AR_mac_OS_WIFI_MACOS_count: 0; expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: 0; expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: 0;
    expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: 0; expected_AR_mobile_CALL_HISTORY_IOS_count: 0; expected_AR_mobile_CONTACT_DETAILS_IOS_count: 0; expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: 0;
    expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: 0; expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: 0; expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: 0; expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: 0;
    expected_AR_mobile_GOOGLEMAPS_IOS_count: 0; expected_AR_mobile_ITUNESBACKUP_DETAILS_count: 0; expected_AR_mobile_MAPS_IOS_count: 0; expected_AR_mobile_NOTE_ITEMS_IOS_count: 0; expected_AR_mobile_SMS_V3_IOS_count: 0;
    expected_AR_mobile_SMS_V4_IOS_count: 0; expected_AR_mobile_USER_SHORTCUT_DICTIONARY_IOS_count: 0; expected_AR_mobile_VOICE_MAIL_IOS_count: 0; expected_AR_mobile_VOICE_MEMOS_IOS_count: 0;
    expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0'; expected_BM_30to39_count_str: '0'; expected_BM_40to49_count_str: '0'; expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '189';
    expected_BM_70to79_count_str: '105'; expected_BM_80to89_count_str: '56'; expected_BM_90to99_count_str: '43'; expected_BM_Triagecount_count_str: '58'; expected_BM_VideoSkintone_count_str: '140'; expected_EM_ext_avi_count_str: '0';
    expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '0'; expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0';
    expected_EM_sig_jpg_count_str: '0'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '0'; expected_FS_carved_camera_sig_jpg_count: 49670; // 10 Dec 21 - 49671;
    expected_FS_custom_byte_carve_pagefile_jpg_count: 0; expected_FS_ext_avi_count_str: '22'; expected_FS_ext_exe_count_str: '22'; expected_FS_ext_jpg_count_str: '48317'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '25657'; // plist
    expected_FS_ext_pst_count_str: '502'; // pst
    expected_FS_ext_wmv_count_str: '0'; expected_FS_ext_zip_count_str: '33'; expected_FS_logical_free_space_on_disk: 0; expected_FS_metadata_271Canon_count: 283; expected_FS_metadata_271Make_carved_count: 0;
    expected_FS_metadata_271Make_normal_count: 14568; expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 0; expected_FS_partition_count: 2; expected_FS_partitions_sum_size: 159907627008;
    expected_FS_recovered_folders: '111'; expected_FS_sig_avi_count_str: '23'; expected_FS_sig_exe_count_str: '81'; expected_FS_sig_jpg_count_str: '48746'; expected_FS_sig_maxsigtime: 0; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '48492'; // plist
    expected_FS_sig_pst_count_str: '0'; // pst
    expected_FS_sig_wmv_count_str: '0'; expected_FS_sig_zip_count_str: '161'; expected_FS_unalloc_ntfs_vol_size: 0; expected_FS_verification_MD5: '702c2ba74d53070d63c17ffea6bdff4d';
    expected_FS_verification_SHA1: '626a83c1d127f570d72bc4761cd1f6c1ee896864'; expected_FS_verification_SHA256: '51a2892f21d7c54844f881373c4eecf3e5a8570162fc24aae580bdae3eb15954'; expected_KW_keyword1: 'catherine'; // noslz
    expected_KW_keyword1_file_count_str: '1619'; expected_KW_keyword1_hits_count_str: '119684'; // 08-Dec-21 '96884';
    expected_KW_keyword1_regex: 'quality = [0-9][0-9]'; // noslz
    expected_KW_keyword1_regex_file_count_str: '10'; expected_KW_keyword1_regex_hits_count_str: '759'; expected_KW_keyword2: 'scott'; // noslz
    expected_KW_keyword2_file_count_str: '2101'; // 08-Dec-21 2100
    expected_KW_keyword2_hits_count_str: '170521'; // 08-Dec-21 '144572';
    expected_module_count_Artifacts_str: '28187'; // 10-Dec-21 '26084';

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"82c1fe7d77ad239a4d57aba57960679c","7533d37b2a5faea5bb7b16a85cbd747ee83b35e0","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Applications\Utilities\RAID Utility.app\Contents\Resources\Battery2.png"' +
    #13#10 + '"af2dd6d0657318fd49a68bf19d864be4","b19d2de8685ce6a7722f6a22b9e6b514293ac3c9","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Applications\Utilities\RAID Utility.app\Contents\Resources\MigrateRAIDSet.png"'
    + #13#10 +
    '"29a2aae268e29fbf7bb47c831e20cb6e","10392da38641b193eec1881cb35bcd9a20285c72","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\System\Library\PrivateFrameworks\CoreUI.framework\Versions\A\Resources\UI.bundle\Contents\Resources\distort1.png"'
    + #13#10 +
    '"4e54f45fb81a9d575a0daf5bb0a34091","3139bd6abebd83b9fb777eca7a7ef0cc944a2fe0","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\System\Library\PrivateFrameworks\CoreUI.framework\Versions\A\Resources\UI.bundle\Contents\Resources\yellowmaterial.png"'
    + #13#10 + '"3e43c95bcda807d178eb6b198b494fab","80c5a1c3232d4b27f42800152525670c53d67016","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\System\Library\WidgetResources\ibutton\black_rollie.png"' + #13#10 +
    '"ef707f5e8cc1aaf1b857ae9199596ab2","5cab99c79527a80c3a4d3d10b1c0376374ef70ea","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Users\CATHERINESCOTT\Pictures\iPhoto Library\Data.noindex\2010\03/09/2010_2\P1010540.jpg"'
    + #13#10 +
    '"88902e87a906556124fa7c9a3037ff98","f98ce3ed3aee3b7ef3dd73c79cdc4891e6e69334","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Users\CATHERINESCOTT\Pictures\iPhoto Library\Data.noindex\2010\05/09/2010\P1010574.jpg"'
    + #13#10 +
    '"5393ff2f0890733dd58d5aae7600b11b","1ead5dbe497bf609db890ad6b8f672fcf1ceb1e3","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Users\CATHERINESCOTT\Pictures\iPhoto Library\Data.noindex\2010\07/07/2010\P1000014.jpg"'
    + #13#10 +
    '"c585057ab9f77f35a0f48070b5f5ffd4","70bf945fa0f412afd5272f1dfe95f2399e6bb138","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Users\CATHERINESCOTT\Pictures\iPhoto Library\Data.noindex\2010\07/07/2010\P1000327.jpg"'
    + #13#10 +
    '"b774628835763a0b1cf2baa767d408af","6be5634c7523343a317ad277377815fb24cb680f","Catherine Scott MAC Laptop - PD - C - FTK.E01\Customer (EFI 2)\Macintosh HD\Users\CATHERINESCOTT\Pictures\iPhoto Library\Data.noindex\2010\07/07/2010\P1000591.jpg"'),

    // ~8~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: '00731bee6e94010ecc4e4645eb19610f'; GD_Ref_Name: 'ATH'; Device_Logical_Size: 15376000000; expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0'; expected_BM_30to39_count_str: '0'; expected_BM_40to49_count_str: '0';
    expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '0'; expected_BM_70to79_count_str: '3'; expected_BM_80to89_count_str: '0'; expected_BM_90to99_count_str: '0'; expected_BM_Triagecount_count_str: '13|15';
    expected_BM_VideoSkintone_count_str: '0'; expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '0'; expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0';
    expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '0'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '0'; expected_FS_carved_camera_sig_jpg_count: 1300;
    expected_FS_custom_byte_carve_pagefile_jpg_count: 0; expected_FS_ext_avi_count_str: '2'; expected_FS_ext_exe_count_str: '0'; expected_FS_ext_jpg_count_str: '2122'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '2'; // plist
    expected_FS_ext_pst_count_str: '0'; // pst
    expected_FS_ext_wmv_count_str: '0'; expected_FS_ext_zip_count_str: '5'; expected_FS_logical_free_space_on_disk: 0; expected_FS_metadata_271Canon_count: 13; expected_FS_metadata_271Make_carved_count: 0;
    expected_FS_metadata_271Make_normal_count: 16; expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 0; expected_FS_partition_count: 3; expected_FS_partitions_sum_size: 15007219712;
    expected_FS_recovered_folders: '0'; expected_FS_sig_avi_count_str: '2'; expected_FS_sig_exe_count_str: '0'; expected_FS_sig_jpg_count_str: '2122'; expected_FS_sig_maxsigtime: 0; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '0'; // plist
    expected_FS_sig_pst_count_str: '0'; // pst
    expected_FS_sig_wmv_count_str: '0'; expected_FS_sig_zip_count_str: '5'; expected_FS_unalloc_ntfs_vol_size: 0; expected_FS_verification_MD5: 'c8ca5a75227c50a19a071ca2685eba6d';
    expected_FS_verification_SHA1: 'a9574c61406956c8e7083b3b1a75cc3a7e4e0698'; expected_FS_verification_SHA256: 'a0637d98874ff5c353e4799d10acf746ec54cffe7e86b91de06eacc59333800a'; expected_KW_keyword1: 'cat'; // noslz
    expected_KW_keyword1_file_count_str: '79'; expected_KW_keyword1_hits_count_str: '981'; expected_KW_keyword1_regex: 'quality = [0-9][0-9]'; // noslz
    expected_KW_keyword1_regex_file_count_str: '30'; expected_KW_keyword1_regex_hits_count_str: '30'; expected_KW_keyword2: 'bmp'; // noslz
    expected_KW_keyword2_file_count_str: '72'; expected_KW_keyword2_hits_count_str: '435'; expected_module_count_Artifacts_str: '10'; // 11/03/2021 '3';

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"ad31668b9e47f87c2ba3d8e351935e9d","ae3ee397900418c33720dd3a675ac891a4aa0bf2","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\Allocation"' + #13#10 +
    '"d60f4dfd9bc63e55ec939e0977ff1df4","d1e33a4479ce0215572e8bd1fcbfa9bafd40e077","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\Attributes"' + #13#10 +
    '"5f1eaaaeb17b51693a4021fe791845cd","e2775cad6e613df522d526d7bffce84ccf82c617","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\Catalog"' + #13#10 +
    '"ac6405f7ca638640445119f03f13d195","ead907429996217127e5a486880412bd805b2c36","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\Extents Overflow"' + #13#10 +
    '"afd6ef1a35762d9c933a6c7a31a26a80","52a1bfaec85b6ad54c1fca69014a730b595e8369","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\HFS+ Volume Header"' + #13#10 +
    '"92c2a7befc58651dade3b1ed05e780dd","fbe14b6ff75ceca9e462dfeb0273083174c2b358","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\Boot OS X\.journal"' + #13#10 +
    '"a4899cb5d685c31cf13bdcab02ff3a00","6cbb09538eccd7dd2c741b71f079699274a4a2d0","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\Booter (EFI 3)\Boot OS X\.journal_info_block"' + #13#10 +
    '"3a99afc6c6cca61d3c5985153a70dfa4","d5c8711d450323c9120d07e3333891c7b68427f7","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\EFI System Partition (EFI 1)\FAT32 Volume Boot Record"' + #13#10 +
    '"d19d974ebd3b5a2def4c01a2d81b1a68","b4c5338ddc7b2b926390882cb93c11444f1871d3","1801JT03 ScanDisk Ultra Fit Thumbdrive.E01\EFI System Partition (EFI 1)\Reserved Sectors"'),

    // ~9~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Image_Name: '114f4c031759ac4756df54720285c5be'; GD_Ref_Name: 'JTH'; Device_Logical_Size: 2014314496; expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0'; expected_BM_30to39_count_str: '0'; expected_BM_40to49_count_str: '0';
    expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '0'; expected_BM_70to79_count_str: '1'; expected_BM_80to89_count_str: '2'; expected_BM_90to99_count_str: '0'; expected_BM_Triagecount_count_str: '11';
    expected_BM_VideoSkintone_count_str: '1'; expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '57'; expected_EM_ext_wmv_count_str: '0'; expected_EM_ext_zip_count_str: '0';
    expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '59'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '12'; expected_FS_carved_camera_sig_jpg_count: 275;
    expected_FS_custom_byte_carve_pagefile_jpg_count: 0; expected_FS_ext_avi_count_str: '8'; expected_FS_ext_exe_count_str: '0'; expected_FS_ext_jpg_count_str: '860'; expected_FS_ext_ost_count_str: '0'; // ost
    expected_FS_ext_plist_count_str: '0'; // plist
    expected_FS_ext_pst_count_str: '3'; // pst
    expected_FS_ext_wmv_count_str: '3'; expected_FS_ext_zip_count_str: '11'; expected_FS_logical_free_space_on_disk: 0; expected_FS_metadata_271Canon_count: 36; expected_FS_metadata_271Make_carved_count: 0;
    expected_FS_metadata_271Make_normal_count: 77; expected_FS_metadata_271Make_recfld_count: 0; expected_FS_number_of_files: 0; expected_FS_partition_count: 0; expected_FS_partitions_sum_size: 0; expected_FS_recovered_folders: '458';
    expected_FS_sig_avi_count_str: '4'; expected_FS_sig_exe_count_str: '0'; expected_FS_sig_jpg_count_str: '743'; expected_FS_sig_maxsigtime: 0; expected_FS_sig_ost_count_str: '0'; // ost
    expected_FS_sig_plist_count_str: '0'; // plist
    expected_FS_sig_pst_count_str: '3'; // pst
    expected_FS_sig_wmv_count_str: '3'; expected_FS_sig_zip_count_str: '5'; expected_FS_unalloc_ntfs_vol_size: 0; expected_FS_verification_MD5: 'b9febcaadf1116f72577b23b162da744';
    expected_FS_verification_SHA1: '08d78be09335803cf9268665e77e4832f391dac6'; expected_FS_verification_SHA256: 'cb42e08015140ebe42ae4425b8f7a9963d5db020db66030511f741531c2d6610'; expected_KW_keyword1: 'canon powershot';
    // noslz - was canon
    expected_KW_keyword1_file_count_str: '36'; expected_KW_keyword1_hits_count_str: '38'; expected_KW_keyword1_regex: 'quality = [0-9][0-9]'; // noslz
    expected_KW_keyword1_regex_file_count_str: '28'; expected_KW_keyword1_regex_hits_count_str: '28'; expected_KW_keyword2: 'trafficking'; // noslz - was blackberry
    expected_KW_keyword2_file_count_str: '5'; expected_KW_keyword2_hits_count_str: '5'; expected_module_count_Artifacts_str: '11'; // 11/03/2021 '3';
    expected_module_count_Email: '1092';

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"ab6ec78e00361ab832ef07855f4ca052","8903ad223b2824fb7a59db3833eeb8f98d2c5f5f","1801JT02 SD Card.E01\Root\Other documents\August 3rd.txt"' + #13#10 +
    '"07ec3a83fc7eb58539d01bb0f22221ca","6920b6c4fec1a83838435711fb935259ff19009b","1801JT02 SD Card.E01\Root\Other documents\Mr Penguin.docx"' + #13#10 +
    '"18963c076ea6afa9aa9a2ef09106ed49","4fc6d87fdcd68036a3d2454df1fe3f860104a51c","1801JT02 SD Card.E01\Root\Pictures\rugby.png"' + #13#10 +
    '"98d033b436374700871f6d7483e47f44","266d2cf3b728aff90f55083020434261ccf46403","1801JT02 SD Card.E01\Root\Pictures\Tree.avi"' + #13#10 +
    '"e17765074478b70494c048b2d2b80f9f","8a5035dc6a3f25bce05297dc9987292b29aab919","1801JT02 SD Card.E01\Root\Pictures\Snake\SL370822 (Medium).zip"' + #13#10 +
    '"b6100955339f4512561c687125d2b514","f2ca706418a8278b6d59f9467d555e635e695fa2","1801JT02 SD Card.E01\Root\Recycled\NEFConfig.xml"' + #13#10 +
    '"decd6048179ae01b0d472a7348aa63b5","606acafd70cbc5a59f51eeefde666eac0cf83a63","1801JT02 SD Card.E01\Root\SkyDrive\Pictures\Men Celebs\Ben_Affleck.JPG"' + #13#10 +
    '"034b34555373a1c0486e0e6d001f02f3","d097ef5d0d93dd67b68a932873edc7fb837926f4","1801JT02 SD Card.E01\Root\Sounds & Ringtones\bbm_end_call.wav"' + #13#10 +
    '"434d3f1eab2495049913cdf0171e0750","8d5efee60aeedf0e1763d10c86712bb4d21322a4","1801JT02 SD Card.E01\Root\Documents\ACCOUNTS.xlsx"' + #13#10 +
    '"9364a29363851d53608334392cddab46","349ef5dcc810945e14fc163f1d7546f5d53f1b34","1801JT02 SD Card.E01\Root\My stuff to sort\letterlegal5.doc"' + #13#10 +
    '"cf4f19c8619a462066b47e8461962443","3ca70a920bd9bbc2eb731d5f4edf46e9088b08f2","1801JT02 SD Card.E01\Root\some stuff.zip"'),

    // ~10~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (Item_Number: '1'; Image_Name: '0bad795d812d45f60bfcb716285953c3'; GD_Ref_Name: 'MTH2020'; Hash_Threshold: 85; Device_Logical_Size: 80026361856; expected_AR_browsers_chrome_AUTOFILL_count: 0; expected_AR_browsers_chrome_CACHE_count: 0;
    expected_AR_browsers_chrome_COOKIES_count: 0; expected_AR_browsers_chrome_DOWNLOADS_count: 0; expected_AR_browsers_chrome_FAVICONS_count: 4; expected_AR_browsers_chrome_HISTORY_count: 0;
    expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count: 0; expected_AR_browsers_chrome_LOGINS_count: 0; expected_AR_browsers_chrome_SHORTCUTS_count: 2; expected_AR_browsers_chrome_SYNCDATA_count: 0;
    expected_AR_browsers_chrome_TOPSITES_count: 2; expected_AR_browsers_chromium_CACHE_count: 196; expected_AR_browsers_chromium_COOKIES_count: 9; expected_AR_browsers_chromium_DOWNLOADS_count: 0;
    expected_AR_browsers_chromium_HISTORY_count: 99; expected_AR_browsers_chromium_KEYWORDSEARCHTERMS_count: 0; expected_AR_browsers_FIREFOX_BOOKMARKS_count: 74; expected_AR_browsers_FIREFOX_COOKIES_count: 887;
    expected_AR_browsers_FIREFOX_DOWNLOADS_count: 4; expected_AR_browsers_FIREFOX_FAVICONS_count: 67; expected_AR_browsers_FIREFOX_FORMHISTORY_count: 0; expected_AR_browsers_FIREFOX_HISTORYVISITS_count: 311;
    expected_AR_browsers_FIREFOX_PLACES_count: 306; expected_AR_browsers_IE1011_CARVE_COOKIES_count: 824; expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count: 398; expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count: 2043;
    expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count: 174; expected_AR_browsers_IE1011_CARVECONTENT_count: 10773; expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count: 2053;
    expected_AR_browsers_IE1011_ESECONTENT_count: 7968; expected_AR_browsers_IE1011_ESECOOKIES_count: 546; expected_AR_browsers_IE1011_ESEDEPENDENCYENTRIES_count: 27; expected_AR_browsers_IE1011_ESEDOWNLOADS_count: 14;
    expected_AR_browsers_IE1011_ESEHISTORY_count: 176; expected_AR_browsers_IE49_COOKIE_count: 49; expected_AR_browsers_IE49_DAILY_count: 20; expected_AR_browsers_IE49_HISTORY_count: 50; expected_AR_browsers_IE49_NORMAL_count: 4247;
    expected_AR_browsers_SAFARI_BOOKMARKS_count: 100; expected_AR_browsers_SAFARI_CACHE_count: 0; expected_AR_browsers_SAFARI_COOKIES_count: 295; expected_AR_browsers_SAFARI_HISTORY_count: 48;
    expected_AR_browsers_SAFARI_RECENTSEARCHES_count: 14; expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count: 26; expected_AR_chat_IMESSAGE_MESSAGE_OSX_count: 455; expected_AR_chat_SKYPE_ACCOUNTS_count: 3;
    expected_AR_chat_SKYPE_CALLS_count: 68; expected_AR_chat_SKYPE_CONTACTS_count: 161; expected_AR_chat_SKYPE_MESSAGES_count: 570; expected_AR_chat_SKYPE_TRANSFERS_count: 0; expected_AR_chat_SNAPCHAT_USER_IOS_count: 0;
    expected_AR_chat_TELEGRAM_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_IOS_count: 0; expected_AR_chat_VIBER_CHAT_PC_count: 0; expected_AR_chat_WHATSAPP_CALLS_IOS_count: 0; expected_AR_chat_WHATSAPP_CHAT_IOS_count: 15;
    expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count: 0; expected_AR_mac_OS_TIMEZONE_MACOS_count: 0; expected_AR_mobile_ACCOUNTS_TYPE_IOS_count: 68; expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count: 0;
    expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count: 99; expected_AR_mobile_CALL_HISTORY_IOS_count: 150; expected_AR_mobile_CONTACT_DETAILS_IOS_count: 116; expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count: 0;
    expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count: 0; expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count: 0; expected_AR_mobile_DYNAMICDICTIONARY_IOS_count: 1389; expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count: 3;
    expected_AR_mobile_GOOGLEMAPS_IOS_count: 5; expected_AR_mobile_ITUNESBACKUP_DETAILS_count: 3; expected_AR_mobile_MAPS_IOS_count: 0; expected_AR_mobile_NOTE_ITEMS_IOS_count: 1; expected_AR_mobile_SMS_V3_IOS_count: 0;
    expected_AR_mobile_SMS_V4_IOS_count: 457; expected_AR_mobile_VOICE_MAIL_IOS_count: 0; expected_AR_mobile_VOICE_MEMOS_IOS_count: 3; expected_AR_mobile_WIFI_CONFIGURATIONS_IOS_count: 121;
    expected_AR_unallocated_search_GMAILFRAGMENTS_count_str: '0|1178|1387'; expected_AR_windows_os_PREFETCH_WINDOWS_count: 129; expected_AR_windows_OS_WIFI_WINDOWS_count: 4; expected_BM_30to39_count_str: '0';
    expected_BM_40to49_count_str: '0'; expected_BM_50to59_count_str: '0'; expected_BM_60to69_count_str: '7'; expected_BM_70to79_count_str: '2'; expected_BM_80to89_count_str: '3'; expected_BM_90to99_count_str: '0';
    expected_BM_Triagecount_count_str: '447'; expected_BM_VideoSkintone_count_str: '33|40'; expected_EM_ext_avi_count_str: '0'; expected_EM_ext_exe_count_str: '0'; expected_EM_ext_jpg_count_str: '114'; expected_EM_ext_wmv_count_str: '0';
    expected_EM_ext_zip_count_str: '0'; expected_EM_sig_avi_count_str: '0'; expected_EM_sig_exe_count_str: '0'; expected_EM_sig_jpg_count_str: '118'; expected_EM_sig_wmv_count_str: '0'; expected_EM_sig_zip_count_str: '24';
    expected_FS_carved_camera_sig_jpg_count: 1780; expected_FS_custom_byte_carve_pagefile_jpg_count: 72; expected_FS_ext_avi_count_str: '51'; expected_FS_ext_exe_count_str: '2620'; expected_FS_ext_jpg_count_str: '3102';
    expected_FS_ext_ost_count_str: '2'; expected_FS_ext_plist_count_str: '422'; expected_FS_ext_pst_count_str: '6'; expected_FS_ext_wmv_count_str: '136'; expected_FS_ext_zip_count_str: '41'; expected_FS_logical_free_space_on_disk: 0;
    expected_FS_metadata_271Canon_count: 57; expected_FS_metadata_271Make_carved_count: 20; expected_FS_metadata_271Make_normal_count: 779; expected_FS_metadata_271Make_recfld_count: 10; expected_FS_number_of_files: 198443;
    expected_FS_partition_count: 2; expected_FS_partitions_sum_size: 64506297344; expected_FS_pictures_zip_count: 14; expected_FS_pictures_zip_md5: 'fc7b75e7d6ede5183d9a50ece03bd837'; expected_FS_recovered_folders: '2149';
    expected_FS_sig_avi_count_str: '45'; expected_FS_sig_exe_count_str: '28810'; expected_FS_sig_jpg_count_str: '4153'; expected_FS_sig_maxsigtime: 360; expected_FS_sig_ost_count_str: '2'; expected_FS_sig_plist_count_str: '2766';
    expected_FS_sig_pst_count_str: '5'; expected_FS_sig_wmv_count_str: '135'; expected_FS_sig_zip_count_str: '727'; expected_FS_sum_pictures_zip_size: 37812828; expected_FS_unalloc_ntfs_vol_size: 9430200320;
    expected_FS_verification_MD5: 'f65f8212b8006b0b4dcc5b6bfc948b68'; expected_FS_verification_SHA1: 'c182df13f5d9c5be424820c6b0463a5711be8a81';
    expected_FS_verification_SHA256: 'bea0296a5e39438ee5c8ec869c27ff4155a50097a25db2d5046c06ae83aa7569'; expected_KW_keyword1: 'beckham'; expected_KW_keyword1_file_count_str: '36'; expected_KW_keyword1_hits_count_str: '207';
    expected_KW_keyword1_regex: 'lowb[a-z]+alarm'; // noslz
    expected_KW_keyword1_regex_file_count_str: '46'; expected_KW_keyword1_regex_hits_count_str: '106'; expected_KW_keyword2: 'billylibby'; // noslz
    expected_KW_keyword2_file_count_str: '20'; expected_KW_keyword2_hits_count_str: '135'; expected_module_count_Artifacts_str: '36569'; expected_module_count_Bookmarks: 0; expected_module_count_Email: '2512';
    expected_module_count_Registry: 1741908; expected_RG_computername: 'JTH'; expected_RG_computername_count: 11; expected_volume_ID: '7EB8A6DAB8A69067,863EAA8F3EAA7837';

    ftk_imager_output_str: // Exported from FTK Imager with path adjusted for FEX comparison
    '"ea1902f44e0860b290c1a3ae656e36b5","e6c31736a9fb2b80c83e3f2a6c5d2d678496eb75","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\My Stuff to sort\Lolita Girls\safe\nice one 1.png"' + #13#10 +
    '"72762641cd1778242b3eb0352fa4043e","7c1a96784c7569b5c559fd920fe50846b04a0a80","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\My Stuff to sort\Lolita Girls\safe\safer\images0ZDOI5FW.jpg"' + #13#10 +
    '"d9a602dd41723baad9eb9a4a0ae98e79","414841b1bc9e1dc088822e5b995ac6a0227a1e15","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\My Stuff to sort\Lolita Girls\safe\safer\cat lady.jpg"' + #13#10 +
    '"46f274f1b9e9dd4082563269904e045c","e0e273cb6dd943a21d6b9f89bc4625c2e1eb0871","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\My Stuff to sort\Android\amrplayer_setup.exe"' + #13#10 +
    '"1e213b93cb8656e99bd2e308f5ca3234","b965aa80daed4d538f68a969ebd66b8fff34838d","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\System Volume Information\tracking.log"' + #13#10 +
    '"ffb8b91bd19e5bc10a3344aaf34880f3","c2ccd3f489b5df1238e85c07160140c05ae2b47a","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\Windows\Professional.xml"' + #13#10 +
    '"fdc988a80bccdb94b04e9a96add35674","a21e5ade49bd54ea62e6706b72f27c8f270a4264","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\Windows\Installer\16ac5e.msi"' + #13#10 +
    '"d2a08d1553edf0b24efafd7724142cfc","1f26a6eba831afa99c901b8e787468a836dbb8fb","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\My Stuff to sort\Lolita Girls\safe\safer\imagesWSOJXYB6.jpg"' + #13#10 +
    '"1f13fb1ae92bc954587e0a5ca3ba4556","848c3f6b22bba5efa4a2d5a7869097eec2e1b44f","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\System Volume Information\WPSettings.dat"' + #13#10 +
    '"42ad672cf967b61e1370585562d7119e","e2bdc37d9cafcd21f2d6de086fb2343ec411df9c","2001JT02 - Dell Laptop.E01\Partition @ 206848\Root\Windows\System32\DriverStore\FileRepository\oem02dev.inf_x86_neutral_6e053d96b092d4ea\OEM002.uns"'),

    // ~11~
    (Device_Name: 'Blank'), );

var
  iIdx: integer;
begin
  for iIdx := Low(lFileItems) to High(lFileItems) do
    FileItems[iIdx] := @lFileItems[iIdx];
end;

function ShellExecute(hWnd: cardinal; lpOperation: Pchar; lpFile: Pchar; lpParameter: Pchar; lpDirectory: Pchar; nShowCmd: integer): Thandle; stdcall; external 'Shell32.Dll' name 'ShellExecuteW';

function CalcTimeTaken(starting_tick_count: uint64; Description_str: string): string;
var
  time_taken_int: uint64;
begin
  Result := '';
  time_taken_int := (GetTickCount - starting_tick_count);
  time_taken_int := trunc(time_taken_int / 1000);
  Result := RPad(Description_str + 'Script Time Taken:', rpad_value) + FormatDateTime('hh:nn:ss', time_taken_int / SecsPerDay);
  ConsoleLog(Result);
  ConsoleLog(stringofchar('-', CHAR_LENGTH));
end;

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + stringofchar(' ', AChars)
  else
    Result := AString;
end;

procedure ConsoleLog(AString: string);
begin
  if assigned(gMemo_StringList) then
    gMemo_StringList.Add(AString);
  Progress.Log(AString);
end;

procedure MessageUsr(AString: string);
begin
  Progress.Log(AString);
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
      fnum := fnum + 1;
    Result := fpath + fname + '_' + IntToStr(fnum) + fext;
  end;
end;

function SizeDisplayStirng(asize: int64): string;
begin
  if asize >= 1073741824 then
    Result := (Format('%1.0ngb', [asize / (1024 * 1024 * 1024)]))
  else if (asize < 1073741824) and (asize > 1048576) then
    Result := (Format('%1.0nmb', [asize / (1024 * 1024)]))
  else if asize < 1048576 then
    Result := (Format('%1.0nkb', [asize / (1024)]));
end;

// ------------------------------------------------------------------------------
// Procedure: Hash Files
// ------------------------------------------------------------------------------
procedure HashFiles(hEntryList: TList; MAX_FILESIZE: string);
const
  BUFFER_SIZE = 4096;
var
  Field_MD5: TDataStoreField;
  HashDataStore: TDataStore;
  hash_files_tick_count: uint64;
  TaskProgress: TPAC;
begin
  if (not bl_Continue) or (not Progress.isRunning) then
    Exit;
  hash_files_tick_count := GetTickCount64;
  if assigned(hEntryList) and (hEntryList.Count > 0) then
  begin
    Progress.DisplayMessageNow := ('Launching hash files' + SPACE + '(' + IntToStr(hEntryList.Count) + ' files)' + RUNNING); // noslz
    if hEntryList.Count > 1 then
    begin
      ConsoleLog(Format('%-49s %-41s %-38s', ['Launching hash files:', IntToStr(hEntryList.Count), ''])); // noslz
      HashDataStore := GetDataStore('FileSystem'); // noslz
      try
        Field_MD5 := HashDataStore.DataFields.Add(FIELDBYNAME_HASH_MD5, ftBytes);
        if Progress.isRunning then
        begin
          TaskProgress := Progress.NewChild; // NewProgress(True);
          RunTask('TCommandTask_CreateHash', DATASTORE_FILESYSTEM, hEntryList, TaskProgress, ['md5', 'Maxfilesize=' + MAX_FILESIZE, 'findduplicates=True']); // noslz
          while (TaskProgress.isRunning) and (Progress.isRunning) do
            Sleep(500);
          if not(Progress.isRunning) then
            TaskProgress.Cancel;
          bl_Continue := (TaskProgress.CompleteState = pcsSuccess);
        end;
      finally
        HashDataStore.free;
      end;
    end;
  end;
end;

procedure SigTList(SigThis_TList: TList);
var
  TaskProgress: TPAC;
  gbl_Continue: boolean;
begin
  if (not Progress.isRunning) or (not assigned(SigThis_TList)) then
    Exit;
  if assigned(SigThis_TList) and (SigThis_TList.Count > 0) then
  begin
    Progress.CurrentPosition := Progress.Max;
    Progress.DisplayMessageNow := ('Launching signature analysis' + SPACE + '(' + IntToStr(SigThis_TList.Count) + ' files)' + RUNNING);
    Progress.Log(stringofchar('-', 80));
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
  end;
  stringofchar('-', CHAR_LENGTH);
end;

// ------------------------------------------------------------------------------
// Procedure: Signature Analysis
// ------------------------------------------------------------------------------
procedure SignatureAnalysis(ModuleName: string);
var
  message_str: string;
  sig_DataStore: TDataStore;
  sig_AllFiles_TList: TList;
  sig_Entry: TEntry;
  sig_TaskProgress: TPAC;
  sig_tick_count: uint64;
  sig_time_taken_int: uint64;

begin
  if (not bl_Continue) or (not Progress.isRunning) then
    Exit;
  sig_tick_count := GetTickCount64;

  // Set Datastore
  if ModuleName = 'File System' then
    sig_DataStore := GetDataStore(DATASTORE_FILESYSTEM)
  else if ModuleName = 'Bookmarks' then
    sig_DataStore := GetDataStore(DATASTORE_BOOKMARKS)
  else if ModuleName = 'Email' then
    sig_DataStore := GetDataStore(DATASTORE_EMAIL)
  else if ModuleName = 'Registry' then
    sig_DataStore := GetDataStore(DATASTORE_REGISTRY)
  else
    Exit;

  if sig_DataStore = nil then
  begin
    ConsoleLog('Datastore "' + ModuleName + '" not found.' + SPACE + TSWT); // noslz
    Exit;
  end;

  sig_Entry := sig_DataStore.First;
  if sig_Entry = nil then
  begin
    ConsoleLog('No entries found.' + TSWT); // noslz
    sig_DataStore.free;
    Exit;
  end;

  // Clear existing signatures
  if (CmdLine.Params.Indexof('CLEAR_SIGNATURE') > -1) then // noslz
  begin
    Progress.Initialize(sig_DataStore.Count, 'Clearing signatures' + RUNNING);
    ConsoleLog('Clearing signatures' + RUNNING); // noslz
    while assigned(sig_Entry) and (Progress.isRunning) do
    begin
      sig_Entry.ClearFileTypeDriver;
      sig_Entry := sig_DataStore.Next;
      Progress.IncCurrentProgress;
    end;
  end;

  // Create the TList for signature analysis
  sig_AllFiles_TList := TList.Create;
  sig_AllFiles_TList := sig_DataStore.GetEntireList;
  Progress.CurrentPosition := Progress.Max;
  Progress.DisplayMessageNow := ('Launching signature analysis:' + SPACE + ModuleName + SPACE + '(' + IntToStr(sig_AllFiles_TList.Count) + ' files)' + RUNNING); // noslz
  try
    sig_TaskProgress := Progress.NewChild; // NewProgress(True);
    RunTask('TCommandTask_FileTypeAnalysis', DATASTORE_FILESYSTEM, sig_AllFiles_TList, sig_TaskProgress); // noslz
    while (sig_TaskProgress.isRunning) and (Progress.isRunning) do
      Sleep(500);
    if not(Progress.isRunning) then
      sig_TaskProgress.Cancel;
    bl_Continue := (sig_TaskProgress.CompleteState = pcsSuccess);
  finally
    sig_time_taken_int := (GetTickCount64 - sig_tick_count);
    sig_time_taken_int := trunc(sig_time_taken_int / 1000);
    sig_DataStore.free;
    sig_AllFiles_TList.free;
  end;

  if Item^.expected_FS_sig_maxsigtime > 0 then
  begin
    if Item^.expected_FS_sig_maxsigtime < sig_time_taken_int then
    begin
      message_str := SPACE + RS_WARNING + ': Exceeded maximum time: ' + IntToStr(Item^.expected_FS_sig_maxsigtime);
      ConsoleLog(Format('%-49s %-41s %-38s', ['Signature Analysis' + SPACE + ModuleName, IntToStr(sig_AllFiles_TList.Count), FormatDateTime('hh:nn:ss', sig_time_taken_int / SecsPerDay) + SPACE + '(' + IntToStr(sig_time_taken_int) + ')' +
        message_str])); // noslz
    end
    else
      message_str := SPACE + RS_OK;
  end;
end;

procedure Process_FTK_Results(aStringList: TStringList);
var
  linelist: TStringList;
  i: integer;
  astr: string;
  DataStore_FS: TDataStore;
  anEntry: TEntry;
  lFoundFiles: TList;
  Field_MD5: TDataStoreField;
begin
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  lFoundFiles := TList.Create;
  linelist := TStringList.Create;
  try
    Field_MD5 := DataStore_FS.DataFields.Add(FIELDBYNAME_HASH_MD5, ftBytes);
    linelist.Delimiter := ','; // default, but ";" is used with some locales
    linelist.QuoteChar := '"'; // default
    linelist.StrictDelimiter := True; // required: strings are separated *only* by Delimiter
    for i := 0 to aStringList.Count - 1 do
    begin
      astr := aStringList[i];
      if astr <> '' then
      begin
        linelist.CommaText := astr;
        // Find the file directly by its path
        if linelist.Count >= 3 then
        begin
          anEntry := DataStore_FS.FindByPath(DataStore_FS.First, linelist[2]);
          if anEntry <> nil then
          begin
            aStringList.Objects[i] := anEntry;
            lFoundFiles.Add(anEntry);
          end
          else
            ConsoleLog('ERROR - Not Found: ' + linelist[2]);
        end;
      end;
    end;
    ConsoleLog('FTK Hash Compare:');
    HashFiles(lFoundFiles, '1024');
    for i := 0 to aStringList.Count - 1 do
    begin
      astr := aStringList[i];
      if astr <> '' then
      begin
        linelist.CommaText := astr;
        if linelist.Count >= 3 then
        begin
          anEntry := TEntry(aStringList.Objects[i]);
          if assigned(Field_MD5) and assigned(linelist) and (linelist.Count > 0) then
          begin
            if assigned(anEntry) then
            begin
              if (Field_MD5.AsString[anEntry] = linelist[0]) then // and (LineList[0] <> 'd41d8cd98f00b204e9800998ecf8427e') then
                ConsoleLog(Format('%-49s %-41s %-38s', [anEntry.EntryName, 'Matched', 'OK'])) // noslz
              else
                ConsoleLog(Format('%-49s %-41s %-38s', [anEntry.EntryName, 'FEX: ' + Field_MD5.AsString[anEntry], 'FTK: ' + linelist[0]]));
            end;
          end;
        end;
      end;
    end;
  finally
    DataStore_FS.free;
    lFoundFiles.free;
    linelist.free;
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Has Signature Analysis been run
// ------------------------------------------------------------------------------
procedure Sig_And_Hash_Check(ModuleName: string);
var
  aDataStore: TDataStore;
  anEntry: TEntry;
  Field_FileSignature: TDataStoreField;
  Field_MD5: TDataStoreField;
  FileDriverInfo: TFileTypeInformation;
  md5_count: integer;
  md5_percentage: double;
  md5_str: string;
  sig_count: integer;
  sig_percentage: double;
  sig_str: string;
  sig_msg: string;
  hash_msg: string;
  total_files_count: integer;
  the_sig_string: string;
  the_hash_string: string;
  no_files_str: string;

begin
  // Set Datastore
  if ModuleName = 'File System' then
    aDataStore := GetDataStore(DATASTORE_FILESYSTEM)
  else if ModuleName = 'Bookmarks' then
    aDataStore := GetDataStore(DATASTORE_BOOKMARKS)
  else if ModuleName = 'Email' then
    aDataStore := GetDataStore(DATASTORE_EMAIL)
  else if ModuleName = 'Registry' then
    aDataStore := GetDataStore(DATASTORE_REGISTRY)
  else
    Exit;

  if aDataStore = nil then
    Exit;
  try
    total_files_count := aDataStore.Count;
    if total_files_count > 0 then
    begin
      anEntry := aDataStore.First;
      Progress.Initialize(aDataStore.Count, 'Checking signature and hash status' + RUNNING); // noslz
      Field_FileSignature := aDataStore.DataFields.FieldByName('FILE_TYPE'); // noslz

      while assigned(anEntry) and (Progress.isRunning) do
      begin
        // Signature
        FileDriverInfo := anEntry.DeterminedFileDriverInfo;
        sig_str := '';
        if assigned(Field_FileSignature) then
          try
            sig_str := Field_FileSignature.AsString[anEntry];
            if sig_str <> '' then
              sig_count := sig_count + 1;
          except
            ConsoleLog('Error reading signature.'); // noslz
          end;
        // Hash
        Field_MD5 := FileSystemEntryList.DataFields.FieldByName[FIELDBYNAME_HASH_MD5];
        if assigned(Field_MD5) then
          try
            md5_str := Field_MD5.AsString[anEntry];
            if md5_str <> '' then
              md5_count := md5_count + 1;
          except
            ConsoleLog('Error reading MD5.'); // noslz
          end;

        if (anEntry.IsDirectory) and (POS('File Carve', anEntry.EntryName) > 0) then
          file_carve_bl := True;

        if (anEntry.IsDirectory) and (POS('Custom Byte Carve', anEntry.EntryName) > 0) then
          file_carve_custom_byte_bl := True;

        anEntry := aDataStore.Next;
        Progress.IncCurrentProgress;
      end;

      if file_carve_bl = False then
        actual_carved_sig_jpg_count := -1;

      if file_carve_custom_byte_bl = False then
      begin
        actual_custom_byte_carve_jpg_count := -1;
      end;

      sig_percentage := (sig_count / total_files_count) * 100;
      md5_percentage := (md5_count / total_files_count) * 100;

      if sig_percentage > 80 then
      begin
        sig_msg := 'RUN';
        if ModuleName = 'File System' then
          gbl_FS_Signature_Status := True;
        if ModuleName = 'Bookmarks' then
          gbl_BM_Signature_Status := True;
        if ModuleName = 'Email' then
          gbl_EM_Signature_Status := True;
        if ModuleName = 'Registry' then
          gbl_RG_Signature_Status := True;
      end
      else
        sig_msg := RS_NOT_RUN;

      if md5_percentage > 80 then
      begin
        hash_msg := 'RUN';
        if ModuleName = 'File System' then
          gbl_FS_Hash_Status := True;
        if ModuleName = 'Email' then
          gbl_EM_Hash_Status := True;
        if ModuleName = 'Registry' then
          gbl_RG_Hash_Status := True;
      end
      else
        hash_msg := RS_NOT_RUN;

      the_sig_string := (Format('%-5s %-43s %-41s %-9s %-8s', [RS_SIG, ModuleName, IntToStr(sig_count) + '/' + IntToStr(total_files_count), FormatFloat('00.00', sig_percentage) + '%', '' { sig_msg } ])); // noslz
      the_hash_string := (Format('%-5s %-43s %-41s %-9s %-8s', ['Hash ', ModuleName, IntToStr(md5_count) + '/' + IntToStr(total_files_count), FormatFloat('00.00', md5_percentage) + '%', '' { hash_msg } ])); // noslz

      if ModuleName = 'File System' then
      begin
        array_of_string[0] := the_sig_string;
        array_of_string[1] := the_hash_string;
      end
      else if ModuleName = 'Email' then
      begin
        array_of_string[2] := the_sig_string;
        array_of_string[3] := the_hash_string;
      end
      else if ModuleName = 'Registry' then
      begin
        array_of_string[4] := the_sig_string;
        array_of_string[5] := the_hash_string;
      end;

    end
    else
    begin
      no_files_str := (Format('%-43s %-16s', [ModuleName, '0']));

      if ModuleName = 'File System' then
      begin
        array_of_string[0] := 'Sig.  ' + no_files_str;
        array_of_string[1] := 'Hash. ' + no_files_str;
      end
      else if ModuleName = 'Email' then
      begin
        array_of_string[2] := 'Sig.  ' + no_files_str;
        array_of_string[3] := 'Hash. ' + no_files_str;
      end
      else if ModuleName = 'Registry' then
      begin
        array_of_string[4] := 'Sig.  ' + no_files_str;
        array_of_string[5] := 'Hash. ' + no_files_str;
      end;

    end;
  finally
    aDataStore.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Report as integer
// ------------------------------------------------------------------------------
procedure report_as_int(report_on: string; expected_FS_num: int64; actual_num: int64; special_text: string);
var
  message_str: string;
  more_or_less_str: string;
begin
  if POS('Internet Explorer', report_on) > 0 then
  begin
    report_on := StringReplace(report_on, 'Internet Explorer', 'IE', [rfReplaceAll, rfIgnoreCase]);
    report_on := StringReplace(report_on, 'Log Files', 'Logs', [rfReplaceAll, rfIgnoreCase]);
  end;

  if POS('MAC Operating System', report_on) > 0 then
  begin
    report_on := StringReplace(report_on, 'MAC Operating System', 'MAC OS', [rfReplaceAll, rfIgnoreCase]);
  end;

  if actual_num >= 0 then
  begin
    if (identified_image_bl = False) then
      expected_FS_num := 0;
    if expected_FS_num >= 0 then
    begin
      if expected_FS_num <> actual_num then
      begin
        more_or_less_str := '';
        if (actual_num < expected_FS_num) then
          more_or_less_str := 'Less'; // noslz
        if (actual_num > expected_FS_num) then
          more_or_less_str := 'More'; // noslz
        message_str := Format('%-29s %-15s %-15s', [RS_WARNING_EXPECTED + IntToStr(expected_FS_num), ' Got: ' + IntToStr(actual_num), '(Diff: ' + IntToStr(abs(expected_FS_num - actual_num)) + SPACE + more_or_less_str + ')']); // noslz

        // Exceptions
        if (report_on = SAFARI + SPACE + 'Cookies') and (actual_num = 344) then
          message_str := 'OK (Normally ' + IntToStr(expected_FS_num) + ' but Artifacts was run before signature analysis).'; // noslz
        if (report_on = CHROME + SPACE + 'Cookies') and (actual_num = 9) then
          message_str := 'OK (Normally ' + IntToStr(expected_FS_num) + ' but Artifacts was run before signature analysis).'; // noslz
        if (identified_image_bl = False) then
          message_str := 'Not a known image.'; // noslz

        if ((report_on = 'Keyword - "' + Item^.expected_KW_keyword1 + '"') or // noslz
          (report_on = 'Keyword - "' + Item^.expected_KW_keyword2 + '"')) and // noslz
          (actual_num = expected_FS_num + 1) then
          message_str := 'OK (matched +1 - Could be unallocated clusters?)'; // noslz

        // Fix up keywords that have not been run
        if (report_on = 'Keyword - "' + Item^.expected_KW_keyword1 + '"') then // noslz
          if not HashKeywordBeenSearched(Item^.expected_KW_keyword1) then
            actual_num := -1;

        if (report_on = 'Keyword - "' + Item^.expected_KW_keyword2 + '"') then // noslz
          if not HashKeywordBeenSearched(Item^.expected_KW_keyword2) then
            actual_num := -1;

        if (report_on = 'Keyword Regex - "' + Item^.expected_KW_keyword1_regex + '"') then // noslz
          if not HashKeywordBeenSearched(Item^.expected_KW_keyword1_regex) then
            actual_num := -1;

      end
      else
      begin
        message_str := RS_OK + special_text;
        if (identified_image_bl = False) then
          message_str := 'Not a known image.'; // noslz
      end;
    end;
  end;

  if actual_num = -1 then
    ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(RS_NOT_RUN, rpad_value2) + RS_NOT_RUN))
  else
    ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(IntToStr(actual_num), rpad_value2) + message_str));
end;

// ------------------------------------------------------------------------------
// Procedure: Report as String
// ------------------------------------------------------------------------------
procedure report_as_str(report_on: string; expected_FS_str: string; actual_str: string);
var
  message_str: string;
begin
  if actual_str <> '' then
  begin
    if expected_FS_str <> '' then
    begin
      if expected_FS_str <> actual_str then
      begin
        if actual_str = RS_NOT_RUN then
          message_str := RS_NOT_RUN
        else
          message_str := RS_WARNING + ':' + SPACE + report_on + ' Expected: ' + expected_FS_str + ' Got: ' + actual_str; // noslz
      end
      else
        message_str := RS_OK;
    end;
  end;
  ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(actual_str, rpad_value2) + message_str));
end;

// ------------------------------------------------------------------------------
// Procedure: Report as Integer > String Regex
// ------------------------------------------------------------------------------
procedure report_as_rgx(report_on: string; expected_FS_str: string; actual_str: string);
var
  message_str: string;
  more_or_less_str: string;
  expected_FS_int64: int64;
  actual_int64: int64;
  theResult_str: string;

  function MoreOrLess: string;
  begin
    Result := '';
    more_or_less_str := '';
    theResult_str := '';
    // Exit if it is a double value
    if RegexMatch(expected_FS_str, '\|', False) then
      Exit;
    // Test to see if the strings are numbers
    if RegexMatch(trim(actual_str), '^[0-9]*$', False) and RegexMatch(trim(expected_FS_str), '^[0-9]*$', False) then
    begin
      actual_int64 := strtoint64(actual_str);
      expected_FS_int64 := strtoint64(expected_FS_str);
      if (actual_int64 < expected_FS_int64) then
        more_or_less_str := 'Less'; // noslz
      if (actual_int64 > expected_FS_int64) then
        more_or_less_str := 'More'; // noslz
      theResult_str := IntToStr(abs(expected_FS_int64 - actual_int64));
    end;
  end;

begin
  if expected_FS_str = '' then
    Exit;

  MoreOrLess;

  if not(RegexMatch(actual_str, expected_FS_str, False)) then
  begin
    if actual_str = RS_NOT_RUN then
      message_str := RS_NOT_RUN
    else
      message_str := Format('%-29s %-15s %-15s', [RS_WARNING_EXPECTED + expected_FS_str, ' Got: ' + actual_str, '(Diff: ' + theResult_str + SPACE + more_or_less_str + ')']); // noslz
  end
  else
  begin
    if POS(PIPE, expected_FS_str) > 0 then
      message_str := RS_OK + SPACE + '(Regex:' + SPACE + expected_FS_str + ')' // noslz
    else
      message_str := RS_OK;
  end;

  ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(actual_str, rpad_value2) + message_str));
end;

// ------------------------------------------------------------------------------
// Procedure: Report skin-tone bookmarks
// ------------------------------------------------------------------------------
procedure report_as_rgx_bm(report_on: string; expected_FS_str: string; actual_str: string);
var
  message_str: string;
begin
  if (POS('Skin Tone Graphics', report_on) > 0) and (gbl_SkinToneRunGraphics = False) then
  begin
    message_str := RS_NOT_RUN;
    ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(actual_str, rpad_value2) + message_str));
    Exit;
  end;

  if (POS('Skin Tone Video', report_on) > 0) and (gbl_SkinToneRunVideo = False) then
  begin
    message_str := RS_NOT_RUN;
    ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(actual_str, rpad_value2) + message_str));
    Exit;
  end;

  if actual_str <> '' then
  begin
    if expected_FS_str <> '' then
    begin
      if not(RegexMatch(actual_str, expected_FS_str, False)) then
        message_str := RS_WARNING + ':' + SPACE + report_on + ' Expected: ' + expected_FS_str + ' Got ' + actual_str // noslz
      else
      begin
        if POS(PIPE, expected_FS_str) > 0 then
          message_str := RS_OK + SPACE + '(Regex:' + SPACE + expected_FS_str + ')' // noslz
        else
          message_str := RS_OK;
      end;
    end;
  end;
  ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(actual_str, rpad_value2) + message_str));
end;

// ------------------------------------------------------------------------------
// Procedure: Report Volume ID
// ------------------------------------------------------------------------------
procedure report_as_volumeid(report_on: string; expected_FS_str: string);
var
  i: integer;
  bl_found: boolean;
begin
  bl_found := False;
  for i := 0 to VolumeID_StringList.Count - 1 do
    if RegexMatch(expected_FS_str, VolumeID_StringList.strings[i], True) then
      bl_found := True;
  if bl_found then
    ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(expected_FS_str, rpad_value2) + RS_OK));
  if not bl_found then
    ConsoleLog(RPad(report_on + ':', rpad_value) + (RPad(expected_FS_str, rpad_value2) + RS_WARNING + ':' + SPACE + 'NOT FOUND')); // noslz
end;

// ------------------------------------------------------------------------------
// Procedure: Reporting
// ------------------------------------------------------------------------------
procedure Reporting(ModuleName: string);
var
  i: integer;
  expected_str: string;
  linelist: TStringList;
  extra_str: string;
begin
  ConsoleLog(stringofchar('=', CHAR_LENGTH));
  if ModuleName = 'Keyword Search' then
    extra_str := SPACE + '(Excluding File Carve and Recovered Folders)'
  else
    extra_str := '';
  ConsoleLog(RPad('Reporting:', rpad_value) + ModuleName + extra_str); // noslz

  // Report Artifacts
  if ModuleName = 'Artifacts' then
  begin
    ConsoleLog(stringofchar('=', CHAR_LENGTH));
    // report_as_rgx('Artifacts module count',                    Item^.expected_module_count_Artifacts_str,                              IntToStr(actual_module_count_Artifacts));
    report_as_int(PATH_BROWSERS_CHROME_AUTOFILL, Item^.expected_AR_browsers_chrome_AUTOFILL_count, count_browsers_chrome_autofill, '');
    report_as_int(PATH_BROWSERS_CHROME_CACHE, Item^.expected_AR_browsers_chrome_CACHE_count, count_browsers_chrome_cache, '');
    report_as_int(PATH_BROWSERS_CHROME_COOKIES, Item^.expected_AR_browsers_chrome_COOKIES_count, count_browsers_chrome_cookies, '');
    report_as_int(PATH_BROWSERS_CHROME_DOWNLOADS, Item^.expected_AR_browsers_chrome_DOWNLOADS_count, count_browsers_chrome_downloads, '');
    report_as_int(PATH_BROWSERS_CHROME_FAVICONS, Item^.expected_AR_browsers_chrome_FAVICONS_count, count_browsers_chrome_favicons, '');
    report_as_int(PATH_BROWSERS_CHROME_HISTORY, Item^.expected_AR_browsers_chrome_HISTORY_count, count_browsers_chrome_history, '');
    report_as_int(PATH_BROWSERS_CHROME_KEYWORDSEARCHTERMS, Item^.expected_AR_browsers_chrome_KEYWORDSEARCHTERMS_count, count_browsers_chrome_keywordsearchterms, '');
    report_as_int(PATH_BROWSERS_CHROME_LOGINS, Item^.expected_AR_browsers_chrome_LOGINS_count, count_browsers_chrome_logins, '');
    report_as_int(PATH_BROWSERS_CHROME_SHORTCUTS, Item^.expected_AR_browsers_chrome_SHORTCUTS_count, count_browsers_chrome_shortcuts, '');
    report_as_int(PATH_BROWSERS_CHROME_SYNCDATA, Item^.expected_AR_browsers_chrome_SYNCDATA_count, count_browsers_chrome_syncdata, '');
    report_as_int(PATH_BROWSERS_CHROME_TOPSITES, Item^.expected_AR_browsers_chrome_TOPSITES_count, count_browsers_chrome_topsites, '');
    report_as_int(PATH_BROWSERS_CHROMIUM_CACHE, Item^.expected_AR_browsers_chromium_CACHE_count, count_browsers_chromium_cache, '');
    report_as_int(PATH_BROWSERS_CHROMIUM_COOKIES, Item^.expected_AR_browsers_chromium_COOKIES_count, count_browsers_chromium_cookies, '');
    report_as_int(PATH_BROWSERS_CHROMIUM_DOWNLOADS, Item^.expected_AR_browsers_chromium_DOWNLOADS_count, count_browsers_chromium_downloads, '');
    report_as_int(PATH_BROWSERS_CHROMIUM_HISTORY, Item^.expected_AR_browsers_chromium_HISTORY_count, count_browsers_chromium_history, '');
    report_as_int(PATH_BROWSERS_CHROMIUM_KEYWORDSEARCHTERMS, Item^.expected_AR_browsers_chromium_KEYWORDSEARCHTERMS_count, count_browsers_chromium_keywordsearchterms, '');
    report_as_int(PATH_BROWSERS_FIREFOX_BOOKMARKS, Item^.expected_AR_browsers_FIREFOX_BOOKMARKS_count, count_browsers_firefox_bookmarks, '');
    report_as_int(PATH_BROWSERS_FIREFOX_COOKIES, Item^.expected_AR_browsers_FIREFOX_COOKIES_count, count_browsers_firefox_cookies, '');
    report_as_int(PATH_BROWSERS_FIREFOX_DOWNLOADS, Item^.expected_AR_browsers_FIREFOX_DOWNLOADS_count, count_browsers_firefox_downloads, '');
    report_as_int(PATH_BROWSERS_FIREFOX_FAVICONS, Item^.expected_AR_browsers_FIREFOX_FAVICONS_count, count_browsers_firefox_favicons, '');
    report_as_int(PATH_BROWSERS_FIREFOX_FORMHISTORY, Item^.expected_AR_browsers_FIREFOX_FORMHISTORY_count, count_browsers_firefox_formhistory, '');
    report_as_int(PATH_BROWSERS_FIREFOX_HISTORYVISITS, Item^.expected_AR_browsers_FIREFOX_HISTORYVISITS_count, count_browsers_firefox_historyvisits, '');
    report_as_int(PATH_BROWSERS_FIREFOX_PLACES, Item^.expected_AR_browsers_FIREFOX_PLACES_count, count_browsers_firefox_places, '');
    report_as_int(PATH_BROWSERS_IE49_COOKIE, Item^.expected_AR_browsers_IE49_COOKIE_count, count_browsers_ie49_cookie, '');
    report_as_int(PATH_BROWSERS_IE49_DAILY, Item^.expected_AR_browsers_IE49_DAILY_count, count_browsers_ie49_daily, '');
    report_as_int(PATH_BROWSERS_IE49_HISTORY, Item^.expected_AR_browsers_IE49_HISTORY_count, count_browsers_ie49_history, '');
    report_as_int(PATH_BROWSERS_IE49_NORMAL, Item^.expected_AR_browsers_IE49_NORMAL_count, count_browsers_ie49_normal, '');
    report_as_int(PATH_BROWSERS_IE1011_CARVECONTENT, Item^.expected_AR_browsers_IE1011_CARVECONTENT_count, count_browsers_ie1011_carvecontent, '');
    report_as_int(PATH_BROWSERS_IE1011_CARVECONTENT_LOGFILES, Item^.expected_AR_browsers_IE1011_CARVECONTENT_LOGFILES_count, count_browsers_ie1011_carvecontent_logfiles, '');
    report_as_int(PATH_BROWSERS_IE1011_CARVE_COOKIES, Item^.expected_AR_browsers_IE1011_CARVE_COOKIES_count, count_browsers_ie1011_carve_cookies, '');
    report_as_int(PATH_BROWSERS_IE1011_CARVE_HISTORY_REFMARKER, Item^.expected_AR_browsers_IE1011_CARVE_HISTORY_REFMARKER_count, count_browsers_ie1011_carve_history_refmarker, '');
    report_as_int(PATH_BROWSERS_IE1011_CARVE_HISTORY_VISITED, Item^.expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_count, count_browsers_ie1011_carve_history_visited, '');
    report_as_int(PATH_BROWSERS_IE1011_CARVE_HISTORY_VISITED_LOGFILES, Item^.expected_AR_browsers_IE1011_CARVE_HISTORY_VISITED_LOGFILES_count, count_browsers_ie1011_carve_history_visited_logfiles, '');
    report_as_int(PATH_BROWSERS_IE1011_ESECONTENT, Item^.expected_AR_browsers_IE1011_ESECONTENT_count, count_browsers_ie1011_esecontent, '');
    report_as_int(PATH_BROWSERS_IE1011_ESECOOKIES, Item^.expected_AR_browsers_IE1011_ESECOOKIES_count, count_browsers_ie1011_esecookies, '');
    report_as_int(PATH_BROWSERS_IE1011_ESEDEPENDENCYENTRIES, Item^.expected_AR_browsers_IE1011_ESEDEPENDENCYENTRIES_count, count_browsers_ie1011_esedependencyentries, '');
    report_as_int(PATH_BROWSERS_IE1011_ESEDOWNLOADS, Item^.expected_AR_browsers_IE1011_ESEDOWNLOADS_count, count_browsers_ie1011_esedownloads, '');
    report_as_int(PATH_BROWSERS_IE1011_ESEHISTORY, Item^.expected_AR_browsers_IE1011_ESEHISTORY_count, count_browsers_ie1011_esehistory, '');
    report_as_int(PATH_BROWSERS_SAFARI_BOOKMARKS, Item^.expected_AR_browsers_SAFARI_BOOKMARKS_count, count_browsers_safari_bookmarks, '');
    report_as_int(PATH_BROWSERS_SAFARI_CACHE, Item^.expected_AR_browsers_SAFARI_CACHE_count, count_browsers_safari_cache, '');
    report_as_int(PATH_BROWSERS_SAFARI_COOKIES, Item^.expected_AR_browsers_SAFARI_COOKIES_count, count_browsers_safari_cookies, '');
    report_as_int(PATH_BROWSERS_SAFARI_HISTORY, Item^.expected_AR_browsers_SAFARI_HISTORY_count, count_browsers_safari_history, '');
    report_as_int(PATH_BROWSERS_SAFARI_HISTORY_IOS8, Item^.expected_AR_browsers_SAFARI_HISTORY_IOS8_count, count_browsers_safari_history_ios8, '');
    report_as_int(PATH_BROWSERS_SAFARI_RECENTSEARCHES, Item^.expected_AR_browsers_SAFARI_RECENTSEARCHES_count, count_browsers_safari_recentsearches, '');
    report_as_int(PATH_CHAT_SKYPE_ACCOUNTS, Item^.expected_AR_chat_SKYPE_ACCOUNTS_count, count_chat_skype_accounts, '');
    report_as_int(PATH_CHAT_SKYPE_CALLS, Item^.expected_AR_chat_SKYPE_CALLS_count, count_chat_skype_calls, '');
    report_as_int(PATH_CHAT_SKYPE_CONTACTS, Item^.expected_AR_chat_SKYPE_CONTACTS_count, count_chat_skype_contacts, '');
    report_as_int(PATH_CHAT_SKYPE_MESSAGES, Item^.expected_AR_chat_SKYPE_MESSAGES_count, count_chat_skype_messages, '');
    report_as_int(PATH_CHAT_SKYPE_TRANSFERS, Item^.expected_AR_chat_SKYPE_TRANSFERS_count, count_chat_skype_transfers, '');
    report_as_int(PATH_CHAT_ZELLO_CHAT_ANDROID, Item^.expected_AR_chat_ZELLO_CHAT_ANDROID_count, count_chat_zello_chat_android, '');
    report_as_int(PATH_CHAT_WHATSAPP_CHAT_IOS, Item^.expected_AR_chat_WHATSAPP_CHAT_IOS_count, count_chat_whatsapp_chat_ios, '');
    report_as_int(PATH_CHAT_WHATSAPP_CALLS_IOS, Item^.expected_AR_chat_WHATSAPP_CALLS_IOS_count, count_chat_whatsapp_calls_ios, '');
    report_as_int(PATH_CHAT_SNAPCHAT_USER_IOS, Item^.expected_AR_chat_SNAPCHAT_USER_IOS_count, count_chat_snapchat_user_ios, '');
    report_as_int(PATH_CHAT_TELEGRAM_CHAT_IOS, Item^.expected_AR_chat_TELEGRAM_CHAT_IOS_count, count_chat_telegram_chat_ios, '');
    report_as_int(PATH_CHAT_VIBER_CHAT_IOS, Item^.expected_AR_chat_VIBER_CHAT_IOS_count, count_chat_viber_chat_ios, '');
    report_as_int(PATH_CHAT_VIBER_CHAT_PC, Item^.expected_AR_chat_VIBER_CHAT_PC_count, count_chat_viber_chat_pc, '');
    report_as_int(PATH_CHAT_IMESSAGE_MESSAGE_OSX, Item^.expected_AR_chat_IMESSAGE_MESSAGE_OSX_count, count_chat_imessage_message_osx, '');
    report_as_int(PATH_CHAT_IMESSAGE_ATTACHMENTS_OSX, Item^.expected_AR_chat_IMESSAGE_ATTACHMENTS_OSX_count, count_chat_imessage_attachments_osx, '');
    report_as_int(PATH_MOBILE_CALENDAR_ITEMS_V3_IOS, Item^.expected_AR_mobile_CALENDAR_ITEMS_V3_IOS_count, count_mobile_calendar_items_v3_ios, '');
    report_as_int(PATH_MOBILE_CALENDAR_ITEMS_V4_IOS, Item^.expected_AR_mobile_CALENDAR_ITEMS_V4_IOS_count, count_mobile_calendar_items_v4_ios, '');
    report_as_int(PATH_MOBILE_ACCOUNTS_TYPE_IOS, Item^.expected_AR_mobile_ACCOUNTS_TYPE_IOS_count, count_mobile_accounts_type_ios, '');
    report_as_int(PATH_MOBILE_CALL_HISTORY_IOS, Item^.expected_AR_mobile_CALL_HISTORY_IOS_count, count_mobile_call_history_ios, '');
    report_as_int(PATH_MOBILE_CONTACT_DETAILS_IOS, Item^.expected_AR_mobile_CONTACT_DETAILS_IOS_count, count_mobile_contact_details_ios, '');
    report_as_int(PATH_MOBILE_CONTACTS_RECENTSTABLE_IOS, Item^.expected_AR_mobile_CONTACTS_RECENTSTABLE_IOS_count, count_mobile_contacts_recentstable_ios, '');
    report_as_int(PATH_MOBILE_CONTACTS_CONTACTSTABLE_IOS, Item^.expected_AR_mobile_CONTACTS_CONTACTSTABLE_IOS_count, count_mobile_contacts_contactstable_ios, '');
    report_as_int(PATH_MOBILE_DYNAMICDICTIONARY_IOS, Item^.expected_AR_mobile_DYNAMICDICTIONARY_IOS_count, count_mobile_dynamicdictionary_ios, '');
    report_as_int(PATH_MOBILE_GOOGLEMAPS_IOS, Item^.expected_AR_mobile_GOOGLEMAPS_IOS_count, count_mobile_googlemaps_ios, '');
    report_as_int(PATH_MOBILE_GOOGLE_MOBILESEARCH_HISTORY_IOS, Item^.expected_AR_mobile_GOOGLE_MOBILESEARCH_HISTORY_IOS_count, count_mobile_google_mobilesearch_history_ios, '');
    report_as_int(PATH_MOBILE_ITUNESBACKUP_DETAILS, Item^.expected_AR_mobile_ITUNESBACKUP_DETAILS_count, count_mobile_itunesbackup_details, '');
    report_as_int(PATH_MOBILE_MAPS_IOS, Item^.expected_AR_mobile_MAPS_IOS_count, count_mobile_maps_ios, '');
    report_as_int(PATH_MOBILE_NOTE_ITEMS_IOS, Item^.expected_AR_mobile_NOTE_ITEMS_IOS_count, count_mobile_note_items_ios, '');
    report_as_int(PATH_MOBILE_SMS_V3_IOS, Item^.expected_AR_mobile_SMS_V3_IOS_count, count_mobile_sms_v3_ios, '');
    report_as_int(PATH_MOBILE_SMS_V4_IOS, Item^.expected_AR_mobile_SMS_V4_IOS_count, count_mobile_sms_v4_ios, '');
    report_as_int(PATH_MOBILE_VOICE_MAIL_IOS, Item^.expected_AR_mobile_VOICE_MAIL_IOS_count, count_mobile_voice_mail_ios, '');
    report_as_int(PATH_MOBILE_VOICE_MEMOS_IOS, Item^.expected_AR_mobile_VOICE_MEMOS_IOS_count, count_mobile_voice_memos_ios, '');
    report_as_int(PATH_MOBILE_WIFI_CONFIGURATIONS_IOS, Item^.expected_AR_mobile_WIFI_CONFIGURATIONS_IOS_count, count_mobile_wifi_configurations_ios, '');
    report_as_int(PATH_MOBILE_DROPBOX_METADATA_CACHE_IOS, Item^.expected_AR_mobile_DROPBOX_METADATA_CACHE_IOS_count, count_mobile_dropbox_metadata_cache_ios, '');
    report_as_int(PATH_MOBILE_USER_SHORTCUT_DICTIONARY_IOS, Item^.expected_AR_mobile_USER_SHORTCUT_DICTIONARY_IOS_count, count_mobile_user_shortcut_dictionary_ios, '');
    report_as_rgx_bm(PATH_UNALLOCATED_SEARCH_GMAILFRAGMENTS, Item^.expected_AR_unallocated_search_GMAILFRAGMENTS_count_str, IntToStr(count_unallocated_search_gmailfragments));
    report_as_int(PATH_WINDOWS_OS_PREFETCH_WINDOWS, Item^.expected_AR_windows_os_PREFETCH_WINDOWS_count, count_windows_os_prefetch_windows, '');
    report_as_int(PATH_WINDOWS_OS_WIFI_WINDOWS, Item^.expected_AR_windows_OS_WIFI_WINDOWS_count, count_windows_os_wifi_windows, '');
    report_as_int(PATH_MAC_OS_TIMEZONE_MACOS, Item^.expected_AR_mac_OS_TIMEZONE_MACOS_count, count_mac_os_timezone_macos, '');
    report_as_int(PATH_MAC_OS_MAIL_FOLDERS_MACOS, Item^.expected_AR_mac_OS_MAIL_FOLDERS_MACOS_count, count_mac_os_mail_folders_macos, '');
    report_as_int(PATH_MAC_OS_ADDRESSBOOKME_MACOS, Item^.expected_AR_mac_OS_ADDRESSBOOKME_MACOS_count, count_mac_os_addressbookme_macos, '');
    report_as_int(PATH_MAC_OS_ATTACHED_IDEVICES_MACOS, Item^.expected_AR_mac_OS_ATTACHED_IDEVICES_MACOS_count, count_mac_os_attached_idevices_macos, '');
    report_as_int(PATH_MAC_OS_BLUETOOTH_MACOS, Item^.expected_AR_mac_OS_BLUETOOTH_MACOS_count, count_mac_os_bluetooth_macos, '');
    report_as_int(PATH_MAC_OS_DOCK_ITEMS_MACOS, Item^.expected_AR_mac_OS_DOCK_ITEMS_MACOS_count, count_mac_os_dock_items_macos, '');
    report_as_int(PATH_MAC_OS_ICLOUD_PREFERENCES_MACOS, Item^.expected_AR_mac_OS_ICLOUD_PREFERENCES_MACOS_count, count_mac_os_icloud_preferences_macos, '');
    report_as_int(PATH_MAC_OS_IMESSAGE_ACCOUNTS_MACOS, Item^.expected_AR_mac_OS_IMESSAGE_ACCOUNTS_MACOS_count, count_mac_os_imessage_accounts_macos, '');
    report_as_int(PATH_MAC_OS_INSTALLATION_DATE_MACOS, Item^.expected_AR_mac_OS_INSTALLATION_DATE_MACOS_count, count_mac_os_installation_date_macos, '');
    report_as_int(PATH_MAC_OS_INSTALLED_PRINTERS_MACOS, Item^.expected_AR_mac_OS_INSTALLED_PRINTERS_MACOS_count, count_mac_os_installed_printers_macos, '');
    report_as_int(PATH_MAC_OS_LAST_SLEEP_MACOS, Item^.expected_AR_mac_OS_LAST_SLEEP_MACOS_count, count_mac_os_last_sleep_macos, '');
    report_as_int(PATH_MAC_OS_LOGIN_ITEMS_MACOS, Item^.expected_AR_mac_OS_LOGIN_ITEMS_MACOS_count, count_mac_os_login_items_macos, '');
    report_as_int(PATH_MAC_OS_LOGIN_WINDOW_MACOS, Item^.expected_AR_mac_OS_LOGIN_WINDOW_MACOS_count, count_mac_os_login_window_macos, '');
    report_as_int(PATH_MAC_OS_OSX_UPDATE_MACOS, Item^.expected_AR_mac_OS_OSX_UPDATE_MACOS_count, count_mac_os_osx_update_macos, '');
    report_as_int(PATH_MAC_OS_RECENT_PHOTO_BOOTH_MACOS, Item^.expected_AR_mac_OS_PHOTO_BOOTH_RECENTS_MACOS_count, count_mac_os_recent_photo_booth_macos, '');
    report_as_int(PATH_MAC_OS_RECENT_ITEMS_APPLICATIONS_MACOS, Item^.expected_AR_mac_OS_RECENT_ITEMS_APPLICATIONS_MACOS_count, count_mac_os_recent_items_applications_macos, '');
    report_as_int(PATH_MAC_OS_RECENT_ITEMS_DOCUMENTS_MACOS, Item^.expected_AR_mac_OS_RECENT_ITEMS_DOCUMENTS_MACOS_count, count_mac_os_recent_items_documents_macos, '');
    report_as_int(PATH_MAC_OS_RECENT_ITEMS_HOSTS_MACOS, Item^.expected_AR_mac_OS_RECENT_ITEMS_HOSTS_MACOS_count, count_mac_os_recent_items_hosts_macos, '');
    report_as_int(PATH_MAC_OS_RECENT_VIDEOLAN_MACOS, Item^.expected_AR_mac_OS_RECENT_VIDEOLAN_MACOS_count, count_mac_os_recent_videolan_macos, '');
    report_as_int(PATH_MAC_OS_RECENT_SAFARI_SEARCHES_MACOS, Item^.expected_AR_mac_OS_RECENT_SAFARI_SEARCHES_MACOS_count, count_mac_os_recent_safari_searches_macos, '');
    report_as_int(PATH_MAC_OS_SAFARI_PREFERENCES_MACOS, Item^.expected_AR_mac_OS_SAFARI_PREFERENCES_MACOS_count, count_mac_os_safari_preferences_macos, '');
    report_as_int(PATH_MAC_OS_SYSTEM_VERSION_MACOS, Item^.expected_AR_mac_OS_SYSTEM_VERSION_MACOS_count, count_mac_os_system_version_macos, '');
    report_as_int(PATH_MAC_OS_TIMEZONE_LOCAL_MACOS, Item^.expected_AR_mac_OS_TIMEZONE_LOCAL_MACOS_count, count_mac_os_timezone_local_macos, '');
    report_as_int(PATH_MAC_OS_WIFI_MACOS, Item^.expected_AR_mac_OS_WIFI_MACOS_count, count_mac_os_wifi_macos, '');
  end;

  // Report Bookmarks
  if ModuleName = 'Bookmarks' then
  begin
    ConsoleLog(stringofchar('=', CHAR_LENGTH));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '30' + HYPHEN + '39', Item^.expected_BM_30to39_count_str, IntToStr(actual_30to39_count));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '40' + HYPHEN + '49', Item^.expected_BM_40to49_count_str, IntToStr(actual_40to49_count));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '50' + HYPHEN + '59', Item^.expected_BM_50to59_count_str, IntToStr(actual_50to59_count));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '60' + HYPHEN + '69', Item^.expected_BM_60to69_count_str, IntToStr(actual_60to69_count));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '70' + HYPHEN + '79', Item^.expected_BM_70to79_count_str, IntToStr(actual_70to79_count));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '80' + HYPHEN + '89', Item^.expected_BM_80to89_count_str, IntToStr(actual_80to89_count));
    report_as_rgx_bm('Skin Tone Graphics' + SPACE + '90' + HYPHEN + '99', Item^.expected_BM_90to99_count_str, IntToStr(actual_90to99_count));
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    report_as_rgx_bm('Skin Tone Video', Item^.expected_BM_VideoSkintone_count_str, IntToStr(actual_BM_VideoSkintone_count));
  end;

  // Report Email
  if ModuleName = 'Email' then
  begin
    ConsoleLog(stringofchar('=', CHAR_LENGTH));
    report_as_rgx('Email module count', Item^.expected_module_count_Email, IntToStr(actual_module_count_Email));
    report_as_rgx('AVI' + SPACE + RS_EXT, Item^.expected_EM_ext_avi_count_str, IntToStr(actual_ext_avi_count));
    report_as_rgx('EXE' + SPACE + RS_EXT, Item^.expected_EM_ext_exe_count_str, IntToStr(actual_ext_exe_count));
    report_as_rgx('JPG' + SPACE + RS_EXT, Item^.expected_EM_ext_jpg_count_str, IntToStr(actual_ext_jpg_count));
    report_as_rgx('WMV' + SPACE + RS_EXT, Item^.expected_EM_ext_wmv_count_str, IntToStr(actual_ext_wmv_count));
    report_as_rgx('ZIP' + SPACE + RS_EXT, Item^.expected_EM_ext_zip_count_str, IntToStr(actual_ext_zip_count));
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    report_as_rgx('AVI' + SPACE + RS_SIG, Item^.expected_EM_sig_avi_count_str, IntToStr(actual_sig_avi_count));
    report_as_rgx('EXE' + SPACE + RS_SIG, Item^.expected_EM_sig_exe_count_str, IntToStr(actual_sig_exe_count));
    report_as_rgx('JPG' + SPACE + RS_SIG, Item^.expected_EM_sig_jpg_count_str, IntToStr(actual_sig_jpg_count));
    report_as_rgx('WMV' + SPACE + RS_SIG, Item^.expected_EM_sig_wmv_count_str, IntToStr(actual_sig_wmv_count));
    report_as_rgx('ZIP' + SPACE + RS_SIG, Item^.expected_EM_sig_zip_count_str, IntToStr(actual_sig_zip_count));
  end;

  // Report File System
  if ModuleName = 'File System' then
  begin
    ConsoleLog(stringofchar('=', CHAR_LENGTH));
    report_as_int('Partitions', Item^.expected_FS_partition_count, actual_partition_count, ''); // noslz

    // Report Volume ID
    linelist := TStringList.Create;
    try
      linelist.CommaText := Item^.expected_volume_ID;
      for i := 0 to linelist.Count - 1 do
      begin
        expected_str := linelist[i];
        report_as_volumeid('Volume ID', expected_str);
      end;
    finally
      linelist.free;
    end;

    report_as_int('Partitions sum size', Item^.expected_FS_partitions_sum_size, actual_partitions_sum_size, ''); // noslz
    report_as_int('NTFS Unalloc. sum size', Item^.expected_FS_unalloc_ntfs_vol_size, actual_unalloc_ntfs_vol_size, ''); // noslz
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    report_as_str('MD5 Verification Hash', Item^.expected_FS_verification_MD5, actual_verification_md5); // noslz
    report_as_str('SHA1 Verification Hash', Item^.expected_FS_verification_SHA1, actual_verification_SHA1); // noslz
    report_as_str('SHA256 Verification Hash', Item^.expected_FS_verification_SHA256, actual_verification_SHA256); // noslz
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    report_as_rgx('AVI' + SPACE + RS_EXT, Item^.expected_FS_ext_avi_count_str, IntToStr(actual_ext_avi_count));
    report_as_rgx('EXE' + SPACE + RS_EXT, Item^.expected_FS_ext_exe_count_str, IntToStr(actual_ext_exe_count));
    report_as_rgx('JPG' + SPACE + RS_EXT, Item^.expected_FS_ext_jpg_count_str, IntToStr(actual_ext_jpg_count));
    report_as_rgx('WMV' + SPACE + RS_EXT, Item^.expected_FS_ext_wmv_count_str, IntToStr(actual_ext_wmv_count));
    report_as_rgx('ZIP' + SPACE + RS_EXT, Item^.expected_FS_ext_zip_count_str, IntToStr(actual_ext_zip_count));
    report_as_rgx('PLIST' + SPACE + RS_EXT, Item^.expected_FS_ext_plist_count_str, IntToStr(actual_ext_plist_count)); // plist
    report_as_rgx('OST' + SPACE + RS_EXT, Item^.expected_FS_ext_ost_count_str, IntToStr(actual_ext_ost_count)); // ost
    report_as_rgx('PST' + SPACE + RS_EXT, Item^.expected_FS_ext_pst_count_str, IntToStr(actual_ext_pst_count)); // pst

    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    report_as_rgx('AVI' + SPACE + RS_SIG, Item^.expected_FS_sig_avi_count_str, IntToStr(actual_sig_avi_count));
    report_as_rgx('EXE' + SPACE + RS_SIG, Item^.expected_FS_sig_exe_count_str, IntToStr(actual_sig_exe_count));
    report_as_rgx('JPG' + SPACE + RS_SIG, Item^.expected_FS_sig_jpg_count_str, IntToStr(actual_sig_jpg_count));
    report_as_rgx('WMV' + SPACE + RS_SIG, Item^.expected_FS_sig_wmv_count_str, IntToStr(actual_sig_wmv_count));
    report_as_rgx('ZIP' + SPACE + RS_SIG, Item^.expected_FS_sig_zip_count_str, IntToStr(actual_sig_zip_count));
    report_as_rgx('PLIST' + SPACE + RS_SIG, Item^.expected_FS_sig_plist_count_str, IntToStr(actual_sig_plist_count)); // plist
    report_as_rgx('OST' + SPACE + RS_SIG, Item^.expected_FS_sig_ost_count_str, IntToStr(actual_sig_ost_count)); // ost
    report_as_rgx('PST' + SPACE + RS_SIG, Item^.expected_FS_sig_pst_count_str, IntToStr(actual_sig_pst_count)); // pst

    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    if (actual_metadata_271Make_count > -1) then
      actual_metadata_271Make_count := actual_metadata_271Make_count + 1; // update from -1 for no folder
    report_as_int('Metadata Tag271 Make (Normal)', Item^.expected_FS_metadata_271Make_normal_count, actual_metadata_271Make_count, ''); // noslz
    if (actual_metadata_271Canon_count > -1) then
      actual_metadata_271Canon_count := actual_metadata_271Canon_count + 1; // update from -1 for no folder
    report_as_int('Metadata Tag271 Canon Photos', Item^.expected_FS_metadata_271Canon_count, actual_metadata_271Canon_count, ''); // noslz
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    if actual_FS_recovered_folders_count_str <> '' then
      report_as_rgx('Recovered Folders', Item^.expected_FS_recovered_folders, actual_FS_recovered_folders_count_str) // noslz
    else
      report_as_rgx('Recovered Folders', Item^.expected_FS_recovered_folders, RS_NOT_RUN); // noslz;
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    report_as_int('Carved JPG', Item^.expected_FS_carved_camera_sig_jpg_count, actual_carved_sig_jpg_count, ''); // noslz
    report_as_int('Custom Byte Carve Pagefile JPG', Item^.expected_FS_custom_byte_carve_pagefile_jpg_count, actual_custom_byte_carve_jpg_count, ''); // noslz

    if (Item^.Device_Logical_Size = 80026361856) or (Item^.Device_Logical_Size = 80026361856) then
    begin
      ConsoleLog(stringofchar('-', CHAR_LENGTH));
      report_as_int('Pictures.zip', Item^.expected_FS_pictures_zip_count, actual_pictures_zip_count, '');
      report_as_int('Pictures.zip sum size', Item^.expected_FS_sum_pictures_zip_size, actual_sum_pictures_zip_size, '');
      report_as_str('Pictures.zip MD5', Item^.expected_FS_pictures_zip_md5, actual_pictures_zip_md5);
    end;
  end;

  // Report Keyword Search
  if ModuleName = 'Keyword Search' then
  begin
    if (Item^.expected_KW_keyword1 <> '') then
    begin
      report_as_rgx('Keyword - "' + Item^.expected_KW_keyword1 + '" - files', Item^.expected_KW_keyword1_file_count_str, IntToStr(actual_KW1_file_count)); // noslz
      report_as_rgx('Keyword - "' + Item^.expected_KW_keyword1 + '" - hits', Item^.expected_KW_keyword1_hits_count_str, IntToStr(actual_KW1_hits_count)); // noslz
      ConsoleLog('---');
    end;

    if (Item^.expected_KW_keyword2 <> '') then
    begin
      report_as_rgx('Keyword - "' + Item^.expected_KW_keyword2 + '" - files', Item^.expected_KW_keyword2_file_count_str, IntToStr(actual_KW2_file_count)); // noslz
      report_as_rgx('Keyword - "' + Item^.expected_KW_keyword2 + '" - hits', Item^.expected_KW_keyword2_hits_count_str, IntToStr(actual_KW2_hits_count)); // noslz
      ConsoleLog('---');
    end;

    if (Item^.expected_KW_keyword1_regex <> '') then
    begin
      report_as_rgx('Keyword Regex - "' + Item^.expected_KW_keyword1_regex + '" - files', Item^.expected_KW_keyword1_regex_file_count_str, IntToStr(actual_KW1_regex_file_count)); // noslz
      report_as_rgx('Keyword Regex - "' + Item^.expected_KW_keyword1_regex + '" - hits', Item^.expected_KW_keyword1_regex_hits_count_str, IntToStr(actual_KW1_regex_hits_count)); // noslz
      ConsoleLog('---');
    end;
  end;

  // Report Registry
  if ModuleName = 'Registry' then
  begin
    ConsoleLog(stringofchar('=', CHAR_LENGTH));
    report_as_int('Registry module count', Item^.expected_module_count_Registry, actual_module_count_Registry, ''); // noslz
    report_as_int('Registry ComputerName' + Item^.expected_RG_computername, Item^.expected_RG_computername_count, actual_keydata_computername_count, ''); // noslz
  end;
  ConsoleLog(stringofchar('-', CHAR_LENGTH));
end;

// ------------------------------------------------------------------------------
// Procedure: File Count
// ------------------------------------------------------------------------------
procedure CountTheFiles(ModuleName: string; aDataStore: TDataStore);
var
  att_count_int: integer;
  att_total_int: integer;
  attEntry: TEntry;
  att_ext: string;
  bmGroup: TEntry;
  bmGroupFolder: TEntry;
  childEntry: TEntry;
  display_counter: integer;
  Field_Hits: TDataStoreField;
  field_Hits_str: string;
  Field_DIR: TDataStoreField;
  filecount_Entry: TEntry;
  filecount_tick_count: uint64;
  filecount_time_taken_int: uint64;
  FileDriverInfo: TFileTypeInformation;
  DeterminedFileDriverInfo: TFileTypeInformation;
  fileext: string;
  hit_Entry: TEntry;
  j, k, q, x: integer;
  keydata_str: string;
  Keyword_Children_TList: TList;
  sig_str: string;
  bm_folder_str: string;
  jpg_ext_StringList: TStringList;
  jpg_sig_StringList: TStringList;

  // Function in procedure: Keyword Hit count
  function hitcount(aTList: TList): integer;
  var
    the_hits_count: integer;
  begin
    Field_Hits := aDataStore.DataFields.FieldByName['HITCOUNT']; // noslz
    if assigned(Field_Hits) then
    begin
      the_hits_count := 0;
      for k := 0 to aTList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        hit_Entry := TEntry(aTList[k]);
        field_Hits_str := Field_Hits.AsString[hit_Entry];
        if field_Hits_str <> '' then
        begin
          if not RegexMatch(hit_Entry.EntryName, 'Carved_', True) and not RegexMatch(hit_Entry.Directory, 'Recovered Folders', True) then
            the_hits_count := the_hits_count + StrToInt(field_Hits_str);
        end;
      end;
      Result := the_hits_count;
    end;
  end;

  function skintonecount(bracket: string; counter: integer): integer;
  begin
    if (dstLostFile in filecount_Entry.Status) then
    begin
    end
    else if (POS(bracket, bm_folder_str) > 0) then
    begin
      bmGroupFolder := FindBookmarkByName(SCRIPT_OUTPUT + BS + SKINTONE + BS + 'Graphics');
      if assigned(bmGroupFolder) then
        gbl_SkinToneRunGraphics := True;
      bmGroup := FindBookmarkByName(SCRIPT_OUTPUT + BS + SKINTONE + BS + 'Graphics' + BS + bracket);
      if assigned(bmGroup) and IsItemInBookmark(bmGroup, filecount_Entry) then
        counter := counter + 1;
    end;
    Result := counter;
  end;

  function skintonecountvideo(bracket: string; counter: integer): integer;
  begin
    // if (pos('Frames', bm_folder_str) > 0) then
    begin
      bmGroupFolder := FindBookmarkByName(SCRIPT_OUTPUT + BS + SKINTONE + BS + VIDEO_KEY_FRAMES);
      if assigned(bmGroupFolder) then
        gbl_SkinToneRunVideo := True;
      bmGroup := FindBookmarkByName(SCRIPT_OUTPUT + BS + SKINTONE + BS + VIDEO_KEY_FRAMES);
      if assigned(bmGroup) and (filecount_Entry.EntryNameExt = '.bmp') then
        counter := counter + 1;
    end;
    Result := counter;
  end;

// Begin file count
begin
  if (not bl_Continue) or (not Progress.isRunning) then
    Exit;
  actual_current_datastore_count := 0;
  actual_ext_avi_count := 0;
  actual_ext_exe_count := 0;
  actual_ext_jpg_count := 0;
  actual_ext_wmv_count := 0;
  actual_ext_zip_count := 0;
  actual_FS_recovered_folders_count_str := '';
  actual_metadata_271Canon_count := -1;
  actual_metadata_271Make_count := -1;
  actual_module_count_Artifacts := 0;
  actual_module_count_Email := 0;
  actual_module_count_Registry := 0;
  actual_partition_count := 0;
  actual_partitions_sum_size := 0;
  actual_sig_avi_count := 0;
  actual_sig_exe_count := 0;
  actual_sig_jpg_count := 0;
  actual_sig_wmv_count := 0;
  actual_sig_zip_count := 0;
  filecount_tick_count := GetTickCount64;
  j := 0;
  normal_FileSystem_count := 1; // Case Name
  q := 1;
  att_total_int := 0;

  // Set Datastore
  if aDataStore = nil then
    ConsoleLog('Datastore not found.' + SPACE + TSWT); // noslz

  filecount_Entry := aDataStore.First;
  if filecount_Entry = nil then
  begin
    ConsoleLog('No entries found.' + SPACE + TSWT); // noslz
    Exit;
  end;

  jpg_ext_StringList := TStringList.Create;
  jpg_sig_StringList := TStringList.Create;
  try
    actual_module_file_count := aDataStore.Count;
    if actual_module_file_count > 1 then
    begin
      SignatureAnalysis(ModuleName);
      Progress.DisplayTitle := SCRIPT_NAME;
      Progress.Initialize(aDataStore.Count, ModuleName + SPACE + 'file count' + RUNNING); // noslz
      display_counter := 0;

      if ModuleName <> 'Registry' then
        while assigned(filecount_Entry) and (Progress.isRunning) do
        begin
          fileext := UpperCase(filecount_Entry.EntryNameExt); // Matches GUI display. This does not: afileext := extractfileext(Entry.EntryName);
          FileDriverInfo := filecount_Entry.DeterminedFileDriverInfo;
          sig_str := UpperCase(FileDriverInfo.ShortDisplayName);

          // Count Bookmarks
          if ModuleName = 'Bookmarks' then
          begin
            if assigned(Field_BookmarkFolder) then
            begin
              bm_folder_str := Field_BookmarkFolder.AsString[filecount_Entry];
              if bm_folder_str <> '' then
              begin
                actual_30to39_count := skintonecount('30' + HYPHEN + '39', actual_30to39_count);
                actual_40to49_count := skintonecount('40' + HYPHEN + '49', actual_40to49_count);
                actual_50to59_count := skintonecount('50' + HYPHEN + '59', actual_50to59_count);
                actual_60to69_count := skintonecount('60' + HYPHEN + '69', actual_60to69_count);
                actual_70to79_count := skintonecount('70' + HYPHEN + '79', actual_70to79_count);
                actual_80to89_count := skintonecount('80' + HYPHEN + '89', actual_80to89_count);
                actual_90to99_count := skintonecount('90' + HYPHEN + '99', actual_90to99_count);
                actual_BM_VideoSkintone_count := skintonecountvideo('Frames', actual_BM_VideoSkintone_count);
              end;
            end;
          end;

          // Count Keyword Search
          if ModuleName = 'Keyword Search' then
          begin
            Keyword_Children_TList := TList.Create;
            try

              if filecount_Entry.IsDirectory and (lowercase(filecount_Entry.EntryName) = lowercase(Item^.expected_KW_keyword1)) then
              begin
                Keyword_Children_TList := KeywordSearchEntryList.Children(filecount_Entry, True);
                for x := 0 to Keyword_Children_TList.Count - 1 do
                begin
                  childEntry := TEntry(Keyword_Children_TList[x]);
                  if not RegexMatch(childEntry.EntryName, 'Carved_', True) and not RegexMatch(childEntry.Directory, 'Recovered Folders', True) then
                    actual_KW1_file_count := actual_KW1_file_count + 1
                end;
                actual_KW1_hits_count := hitcount(Keyword_Children_TList);
              end;

              if filecount_Entry.IsDirectory and (lowercase(filecount_Entry.EntryName) = lowercase(Item^.expected_KW_keyword2)) then
              begin
                Keyword_Children_TList := KeywordSearchEntryList.Children(filecount_Entry, True);
                for x := 0 to Keyword_Children_TList.Count - 1 do
                begin
                  childEntry := TEntry(Keyword_Children_TList[x]);
                  if not RegexMatch(childEntry.EntryName, 'Carved_', True) and not RegexMatch(childEntry.Directory, 'Recovered Folders', True) then
                    actual_KW2_file_count := actual_KW2_file_count + 1
                end;
                actual_KW2_hits_count := hitcount(Keyword_Children_TList);
              end;

              if filecount_Entry.IsDirectory and (filecount_Entry.EntryName = Item^.expected_KW_keyword1_regex) then
              begin
                Keyword_Children_TList := KeywordSearchEntryList.Children(filecount_Entry, True);
                for x := 0 to Keyword_Children_TList.Count - 1 do
                begin
                  childEntry := TEntry(Keyword_Children_TList[x]);
                  if not RegexMatch(childEntry.EntryName, 'Carved_', True) and not RegexMatch(childEntry.Directory, 'Recovered Folders', True) then
                    actual_KW1_regex_file_count := actual_KW1_regex_file_count + 1
                end;
                actual_KW1_regex_hits_count := hitcount(Keyword_Children_TList);
              end;

            finally
              Keyword_Children_TList.free;
            end;
          end;

          // Count Artifacts
          if ModuleName = 'Artifacts' then
          begin
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_AUTOFILL) then
              count_browsers_chrome_autofill := count_browsers_chrome_autofill + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_CACHE) then
              count_browsers_chrome_cache := count_browsers_chrome_cache + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_COOKIES) then
              count_browsers_chrome_cookies := count_browsers_chrome_cookies + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_DOWNLOADS) then
              count_browsers_chrome_downloads := count_browsers_chrome_downloads + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_FAVICONS) then
              count_browsers_chrome_favicons := count_browsers_chrome_favicons + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_HISTORY) then
              count_browsers_chrome_history := count_browsers_chrome_history + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_KEYWORDSEARCHTERMS) then
              count_browsers_chrome_keywordsearchterms := count_browsers_chrome_keywordsearchterms + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_LOGINS) then
              count_browsers_chrome_logins := count_browsers_chrome_logins + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_SHORTCUTS) then
              count_browsers_chrome_shortcuts := count_browsers_chrome_shortcuts + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_SYNCDATA) then
              count_browsers_chrome_syncdata := count_browsers_chrome_syncdata + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROME_TOPSITES) then
              count_browsers_chrome_topsites := count_browsers_chrome_topsites + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROMIUM_CACHE) then
              count_browsers_chromium_cache := count_browsers_chromium_cache + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROMIUM_COOKIES) then
              count_browsers_chromium_cookies := count_browsers_chromium_cookies + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROMIUM_DOWNLOADS) then
              count_browsers_chromium_downloads := count_browsers_chromium_downloads + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROMIUM_HISTORY) then
              count_browsers_chromium_history := count_browsers_chromium_history + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_CHROMIUM_KEYWORDSEARCHTERMS) then
              count_browsers_chromium_keywordsearchterms := count_browsers_chromium_keywordsearchterms + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_BOOKMARKS) then
              count_browsers_firefox_bookmarks := count_browsers_firefox_bookmarks + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_COOKIES) then
              count_browsers_firefox_cookies := count_browsers_firefox_cookies + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_DOWNLOADS) then
              count_browsers_firefox_downloads := count_browsers_firefox_downloads + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_FAVICONS) then
              count_browsers_firefox_favicons := count_browsers_firefox_favicons + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_FORMHISTORY) then
              count_browsers_firefox_formhistory := count_browsers_firefox_formhistory + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_HISTORYVISITS) then
              count_browsers_firefox_historyvisits := count_browsers_firefox_historyvisits + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_FIREFOX_PLACES) then
              count_browsers_firefox_places := count_browsers_firefox_places + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE49_COOKIE) then
              count_browsers_ie49_cookie := count_browsers_ie49_cookie + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE49_DAILY) then
              count_browsers_ie49_daily := count_browsers_ie49_daily + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE49_HISTORY) then
              count_browsers_ie49_history := count_browsers_ie49_history + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE49_NORMAL) then
              count_browsers_ie49_normal := count_browsers_ie49_normal + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_CARVECONTENT) then
              count_browsers_ie1011_carvecontent := count_browsers_ie1011_carvecontent + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_CARVECONTENT_LOGFILES) then
              count_browsers_ie1011_carvecontent_logfiles := count_browsers_ie1011_carvecontent_logfiles + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_CARVE_COOKIES) then
              count_browsers_ie1011_carve_cookies := count_browsers_ie1011_carve_cookies + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_CARVE_HISTORY_REFMARKER) then
              count_browsers_ie1011_carve_history_refmarker := count_browsers_ie1011_carve_history_refmarker + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_CARVE_HISTORY_VISITED) then
              count_browsers_ie1011_carve_history_visited := count_browsers_ie1011_carve_history_visited + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_CARVE_HISTORY_VISITED_LOGFILES) then
              count_browsers_ie1011_carve_history_visited_logfiles := count_browsers_ie1011_carve_history_visited_logfiles + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_ESECONTENT) then
              count_browsers_ie1011_esecontent := count_browsers_ie1011_esecontent + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_ESECOOKIES) then
              count_browsers_ie1011_esecookies := count_browsers_ie1011_esecookies + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_ESEDEPENDENCYENTRIES) then
              count_browsers_ie1011_esedependencyentries := count_browsers_ie1011_esedependencyentries + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_ESEDOWNLOADS) then
              count_browsers_ie1011_esedownloads := count_browsers_ie1011_esedownloads + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_IE1011_ESEHISTORY) then
              count_browsers_ie1011_esehistory := count_browsers_ie1011_esehistory + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_SAFARI_BOOKMARKS) then
              count_browsers_safari_bookmarks := count_browsers_safari_bookmarks + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_SAFARI_CACHE) then
              count_browsers_safari_cache := count_browsers_safari_cache + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_SAFARI_COOKIES) then
              count_browsers_safari_cookies := count_browsers_safari_cookies + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_SAFARI_HISTORY) then
              count_browsers_safari_history := count_browsers_safari_history + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_SAFARI_HISTORY_IOS8) then
              count_browsers_safari_history_ios8 := count_browsers_safari_history_ios8 + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_BROWSERS_SAFARI_RECENTSEARCHES) then
              count_browsers_safari_recentsearches := count_browsers_safari_recentsearches + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_SKYPE_ACCOUNTS) then
              count_chat_skype_accounts := count_chat_skype_accounts + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_SKYPE_CALLS) then
              count_chat_skype_calls := count_chat_skype_calls + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_SKYPE_CONTACTS) then
              count_chat_skype_contacts := count_chat_skype_contacts + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_SKYPE_MESSAGES) then
              count_chat_skype_messages := count_chat_skype_messages + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_SKYPE_TRANSFERS) then
              count_chat_skype_transfers := count_chat_skype_transfers + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_ZELLO_CHAT_ANDROID) then
              count_chat_zello_chat_android := count_chat_zello_chat_android + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_WHATSAPP_CHAT_IOS) then
              count_chat_whatsapp_chat_ios := count_chat_whatsapp_chat_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_WHATSAPP_CALLS_IOS) then
              count_chat_whatsapp_calls_ios := count_chat_whatsapp_calls_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_SNAPCHAT_USER_IOS) then
              count_chat_snapchat_user_ios := count_chat_snapchat_user_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_TELEGRAM_CHAT_IOS) then
              count_chat_telegram_chat_ios := count_chat_telegram_chat_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_VIBER_CHAT_IOS) then
              count_chat_viber_chat_ios := count_chat_viber_chat_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_VIBER_CHAT_PC) then
              count_chat_viber_chat_pc := count_chat_viber_chat_pc + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_IMESSAGE_MESSAGE_OSX) then
              count_chat_imessage_message_osx := count_chat_imessage_message_osx + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_CHAT_IMESSAGE_ATTACHMENTS_OSX) then
              count_chat_imessage_attachments_osx := count_chat_imessage_attachments_osx + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_CALENDAR_ITEMS_V3_IOS) then
              count_mobile_calendar_items_v3_ios := count_mobile_calendar_items_v3_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_CALENDAR_ITEMS_V4_IOS) then
              count_mobile_calendar_items_v4_ios := count_mobile_calendar_items_v4_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_ACCOUNTS_TYPE_IOS) then
              count_mobile_accounts_type_ios := count_mobile_accounts_type_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_CALL_HISTORY_IOS) then
              count_mobile_call_history_ios := count_mobile_call_history_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_CONTACT_DETAILS_IOS) then
              count_mobile_contact_details_ios := count_mobile_contact_details_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_CONTACTS_RECENTSTABLE_IOS) then
              count_mobile_contacts_recentstable_ios := count_mobile_contacts_recentstable_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_CONTACTS_CONTACTSTABLE_IOS) then
              count_mobile_contacts_contactstable_ios := count_mobile_contacts_contactstable_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_DYNAMICDICTIONARY_IOS) then
              count_mobile_dynamicdictionary_ios := count_mobile_dynamicdictionary_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_GOOGLEMAPS_IOS) then
              count_mobile_googlemaps_ios := count_mobile_googlemaps_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_GOOGLE_MOBILESEARCH_HISTORY_IOS) then
              count_mobile_google_mobilesearch_history_ios := count_mobile_google_mobilesearch_history_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_ITUNESBACKUP_DETAILS) then
              count_mobile_itunesbackup_details := count_mobile_itunesbackup_details + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_MAPS_IOS) then
              count_mobile_maps_ios := count_mobile_maps_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_NOTE_ITEMS_IOS) then
              count_mobile_note_items_ios := count_mobile_note_items_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_SMS_V3_IOS) then
              count_mobile_sms_v3_ios := count_mobile_sms_v3_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_SMS_V4_IOS) then
              count_mobile_sms_v4_ios := count_mobile_sms_v4_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_VOICE_MAIL_IOS) then
              count_mobile_voice_mail_ios := count_mobile_voice_mail_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_VOICE_MEMOS_IOS) then
              count_mobile_voice_memos_ios := count_mobile_voice_memos_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_WIFI_CONFIGURATIONS_IOS) then
              count_mobile_wifi_configurations_ios := count_mobile_wifi_configurations_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_DROPBOX_METADATA_CACHE_IOS) then
              count_mobile_dropbox_metadata_cache_ios := count_mobile_dropbox_metadata_cache_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MOBILE_USER_SHORTCUT_DICTIONARY_IOS) then
              count_mobile_user_shortcut_dictionary_ios := count_mobile_user_shortcut_dictionary_ios + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_UNALLOCATED_SEARCH_GMAILFRAGMENTS) then
              count_unallocated_search_gmailfragments := count_unallocated_search_gmailfragments + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_WINDOWS_OS_PREFETCH_WINDOWS) then
              count_windows_os_prefetch_windows := count_windows_os_prefetch_windows + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_WINDOWS_OS_WIFI_WINDOWS) then
              count_windows_os_wifi_windows := count_windows_os_wifi_windows + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_TIMEZONE_MACOS) then
              count_mac_os_timezone_macos := count_mac_os_timezone_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_MAIL_FOLDERS_MACOS) then
              count_mac_os_mail_folders_macos := count_mac_os_mail_folders_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_ADDRESSBOOKME_MACOS) then
              count_mac_os_addressbookme_macos := count_mac_os_addressbookme_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_ATTACHED_IDEVICES_MACOS) then
              count_mac_os_attached_idevices_macos := count_mac_os_attached_idevices_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_BLUETOOTH_MACOS) then
              count_mac_os_bluetooth_macos := count_mac_os_bluetooth_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_DOCK_ITEMS_MACOS) then
              count_mac_os_dock_items_macos := count_mac_os_dock_items_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_ICLOUD_PREFERENCES_MACOS) then
              count_mac_os_icloud_preferences_macos := count_mac_os_icloud_preferences_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_IMESSAGE_ACCOUNTS_MACOS) then
              count_mac_os_imessage_accounts_macos := count_mac_os_imessage_accounts_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_INSTALLATION_DATE_MACOS) then
              count_mac_os_installation_date_macos := count_mac_os_installation_date_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_INSTALLED_PRINTERS_MACOS) then
              count_mac_os_installed_printers_macos := count_mac_os_installed_printers_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_LAST_SLEEP_MACOS) then
              count_mac_os_last_sleep_macos := count_mac_os_last_sleep_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_LOGIN_ITEMS_MACOS) then
              count_mac_os_login_items_macos := count_mac_os_login_items_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_LOGIN_WINDOW_MACOS) then
              count_mac_os_login_window_macos := count_mac_os_login_window_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_OSX_UPDATE_MACOS) then
              count_mac_os_osx_update_macos := count_mac_os_osx_update_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_RECENT_PHOTO_BOOTH_MACOS) then
              count_mac_os_recent_photo_booth_macos := count_mac_os_recent_photo_booth_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_RECENT_ITEMS_APPLICATIONS_MACOS) then
              count_mac_os_recent_items_applications_macos := count_mac_os_recent_items_applications_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_RECENT_ITEMS_DOCUMENTS_MACOS) then
              count_mac_os_recent_items_documents_macos := count_mac_os_recent_items_documents_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_RECENT_ITEMS_HOSTS_MACOS) then
              count_mac_os_recent_items_hosts_macos := count_mac_os_recent_items_hosts_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_RECENT_VIDEOLAN_MACOS) then
              count_mac_os_recent_videolan_macos := count_mac_os_recent_videolan_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_RECENT_SAFARI_SEARCHES_MACOS) then
              count_mac_os_recent_safari_searches_macos := count_mac_os_recent_safari_searches_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_SAFARI_PREFERENCES_MACOS) then
              count_mac_os_safari_preferences_macos := count_mac_os_safari_preferences_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_SYSTEM_VERSION_MACOS) then
              count_mac_os_system_version_macos := count_mac_os_system_version_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_TIMEZONE_LOCAL_MACOS) then
              count_mac_os_timezone_local_macos := count_mac_os_timezone_local_macos + 1;
            if UpperCase(filecount_Entry.FullPathName) = UpperCase(PATH_MAC_OS_WIFI_MACOS) then
              count_mac_os_wifi_macos := count_mac_os_wifi_macos + 1;
          end;

          // Count File System
          if ModuleName = 'File System' then
          begin
            if filecount_Entry.IsDevice then
            begin
              actual_verification_md5 := Field_MD5.AsString[filecount_Entry];
              actual_verification_SHA1 := Field_SHA1.AsString[filecount_Entry];
              actual_verification_SHA256 := Field_SHA256.AsString[filecount_Entry];
              if actual_verification_md5 = '' then
                actual_verification_md5 := RS_NOT_RUN;
              if actual_verification_SHA1 = '' then
                actual_verification_SHA1 := RS_NOT_RUN;
              if actual_verification_SHA256 = '' then
                actual_verification_SHA256 := RS_NOT_RUN;
            end;

            if (dstPartition in filecount_Entry.Status) and not(dstUserCreated in filecount_Entry.Status) then
            begin
              actual_partition_count := actual_partition_count + 1;
              actual_partitions_sum_size := actual_partitions_sum_size + filecount_Entry.LogicalSize;
            end;

            if (filecount_Entry.EntryName = 'Unallocated clusters on NTFS volume') then // noslz
              actual_unalloc_ntfs_vol_size := actual_unalloc_ntfs_vol_size + filecount_Entry.LogicalSize;

            // Carved File System files
            if (dstLostFile in filecount_Entry.Status) and (POS('Carved_', filecount_Entry.EntryName) > 0) then
              if POS('Carved_JPG_', filecount_Entry.EntryName) > 0 then
                actual_carved_sig_jpg_count := actual_carved_sig_jpg_count + 1;

            if (dstLostFile in filecount_Entry.Status) and (POS('Carved from pagefile.sys', filecount_Entry.EntryName) > 0) then
              if POS('Carved from pagefile.sys', filecount_Entry.EntryName) > 0 then
                actual_custom_byte_carve_jpg_count := actual_custom_byte_carve_jpg_count + 1;

            // Recovered Folders count
            if (filecount_Entry.IsDirectory) and (POS('Recovered Folders', filecount_Entry.EntryName) > 0) then
            begin
              Recovered_Folders_TList := TList.Create;
              try
                if assigned(FileSystemEntryList) and assigned(Recovered_Folders_TList) then
                begin
                  Recovered_Folders_TList := FileSystemEntryList.Children(filecount_Entry, True);
                  if assigned(Recovered_Folders_TList) and (Recovered_Folders_TList.Count > -1) then
                    actual_FS_recovered_folders_count_str := IntToStr(Recovered_Folders_TList.Count);
                end
              finally
                Recovered_Folders_TList.free;
              end;
            end;
          end;

          // Email
          Field_DIR := aDataStore.DataFields.FieldByName('DIR'); // noslz
          if (ModuleName = 'Email') then
          begin
            if isMailEntry(filecount_Entry) then
            begin
              att_count_int := filecount_Entry.ChildrenCount;
              if att_count_int > 0 then
              begin
                for k := 0 to att_count_int - 1 do
                begin
                  inc(att_total_int);
                  attEntry := TEntry(filecount_Entry.Children[k]);
                  att_ext := UpperCase(attEntry.Extension);

                  // Extension
                  if (att_ext = '.JPG') then
                  begin
                    actual_ext_jpg_count := actual_ext_jpg_count + 1;
                    jpg_ext_StringList.Add(Format('%-49s %-41s %-38s', [attEntry.EntryName, IntToStr(attEntry.LogicalSize), Field_DIR.AsString(attEntry)]));
                  end;
                  if (att_ext = '.AVI') then
                    actual_ext_avi_count := actual_ext_avi_count + 1;
                  if (att_ext = '.EXE') then
                    actual_ext_exe_count := actual_ext_exe_count + 1;
                  if (att_ext = '.WMV') then
                    actual_ext_wmv_count := actual_ext_wmv_count + 1;
                  if (att_ext = '.ZIP') then
                    actual_ext_zip_count := actual_ext_zip_count + 1;
                  if (att_ext = '.PLIST') then
                    actual_ext_plist_count := actual_ext_plist_count + 1; // plist
                  if (att_ext = '.OST') then
                    actual_ext_ost_count := actual_ext_ost_count + 1; // ost
                  if (att_ext = '.PST') then
                    actual_ext_pst_count := actual_ext_pst_count + 1; // pst

                  // Determined
                  DetermineFileType(attEntry);
                  DeterminedFileDriverInfo := attEntry.DeterminedFileDriverInfo;
                  sig_str := UpperCase(DeterminedFileDriverInfo.ShortDisplayName);
                  if FileDriverInfo.ShortDisplayName <> '' then
                  begin
                    if (sig_str = 'JPG') then
                    begin
                      actual_sig_jpg_count := actual_sig_jpg_count + 1;
                      jpg_sig_StringList.Add(Format('%-49s %-41s %-38s', [attEntry.EntryName, IntToStr(attEntry.LogicalSize), Field_DIR.AsString(attEntry)]));
                    end;
                    if (sig_str = 'AVI') then
                      actual_sig_avi_count := actual_sig_avi_count + 1;
                    if (sig_str = 'EXE/DLL') then
                      actual_sig_exe_count := actual_sig_exe_count + 1;
                    if (sig_str = 'WMV') then
                      actual_sig_wmv_count := actual_sig_wmv_count + 1;
                    if (sig_str = 'ZIP') then
                      actual_sig_zip_count := actual_sig_zip_count + 1;
                    if (sig_str = 'PLIST (BINARY)') then
                      actual_sig_plist_count := actual_sig_plist_count + 1; // plist
                    if (sig_str = 'OST') then
                      actual_sig_ost_count := actual_sig_ost_count + 1; // ost
                    if (sig_str = 'PST') then
                      actual_sig_pst_count := actual_sig_pst_count + 1; // pst
                  end;
                end;
              end;
            end;
          end
          else

            // Before email update June 2021 - Version 5.4.2.1690 and below
            if (ModuleName = 'Email') then
            begin
              att_ext := UpperCase(filecount_Entry.Extension);

              // Extension
              if (att_ext = '.JPG') then
              begin
                actual_ext_jpg_count := actual_ext_jpg_count + 1;
                jpg_ext_StringList.Add(Format('%-49s %-41s %-38s', [filecount_Entry.EntryName, IntToStr(filecount_Entry.LogicalSize), Field_DIR.AsString(filecount_Entry)]));
              end;
              if (att_ext = '.AVI') then
                actual_ext_avi_count := actual_ext_avi_count + 1;
              if (att_ext = '.EXE') then
                actual_ext_exe_count := actual_ext_exe_count + 1;
              if (att_ext = '.WMV') then
                actual_ext_wmv_count := actual_ext_wmv_count + 1;
              if (att_ext = '.ZIP') then
                actual_ext_zip_count := actual_ext_zip_count + 1;
              if (att_ext = '.PLIST') then
                actual_ext_plist_count := actual_ext_plist_count + 1; // plist
              if (att_ext = '.OST') then
                actual_ext_ost_count := actual_ext_ost_count + 1; // ost
              if (att_ext = '.PST') then
                actual_ext_pst_count := actual_ext_pst_count + 1; // pst

              // Determined
              DeterminedFileDriverInfo := filecount_Entry.DeterminedFileDriverInfo;
              sig_str := UpperCase(DeterminedFileDriverInfo.ShortDisplayName);
              if FileDriverInfo.ShortDisplayName <> '' then
              begin
                if (sig_str = 'JPG') then
                begin
                  actual_sig_jpg_count := actual_sig_jpg_count + 1;
                  jpg_sig_StringList.Add(Format('%-49s %-41s %-38s', [filecount_Entry.EntryName, IntToStr(filecount_Entry.LogicalSize), Field_DIR.AsString(filecount_Entry)]));
                end;

                if (sig_str = 'AVI') then
                  actual_sig_avi_count := actual_sig_avi_count + 1;
                if (sig_str = 'EXE/DLL') then
                  actual_sig_exe_count := actual_sig_exe_count + 1;
                if (sig_str = 'WMV') then
                  actual_sig_wmv_count := actual_sig_wmv_count + 1;
                if (sig_str = 'ZIP') then
                  actual_sig_zip_count := actual_sig_zip_count + 1;
                if (sig_str = 'PLIST (BINARY)') then
                  actual_sig_plist_count := actual_sig_plist_count + 1; // plist
                if (sig_str = 'OST') then
                  actual_sig_ost_count := actual_sig_ost_count + 1; // ost
                if (sig_str = 'PST') then
                  actual_sig_pst_count := actual_sig_pst_count + 1; // pst
              end;
            end;

          // Normal files
          if (ModuleName = 'File System') then
          begin
            if not(dstLostFile in filecount_Entry.Status) and not(dstUserCreated in filecount_Entry.Status) and not(filecount_Entry.InExpanded) and not(POS('Recovered Folders', filecount_Entry.Directory) > 0) then
            begin
              normal_FileSystem_count := normal_FileSystem_count + 1;

              // Extension
              if (fileext = '.JPG') then
                actual_ext_jpg_count := actual_ext_jpg_count + 1;
              if (fileext = '.AVI') then
                actual_ext_avi_count := actual_ext_avi_count + 1;
              if (fileext = '.EXE') then
                actual_ext_exe_count := actual_ext_exe_count + 1;
              if (fileext = '.WMV') then
                actual_ext_wmv_count := actual_ext_wmv_count + 1;
              if (fileext = '.ZIP') then
                actual_ext_zip_count := actual_ext_zip_count + 1;
              if (fileext = '.PLIST') then
                actual_ext_plist_count := actual_ext_plist_count + 1; // plist
              if (fileext = '.OST') then
                actual_ext_ost_count := actual_ext_ost_count + 1; // ost
              if (fileext = '.PST') then
                actual_ext_pst_count := actual_ext_pst_count + 1; // pst

              // Determined
              DeterminedFileDriverInfo := filecount_Entry.DeterminedFileDriverInfo;
              sig_str := UpperCase(DeterminedFileDriverInfo.ShortDisplayName);
              if FileDriverInfo.ShortDisplayName <> '' then
              begin
                if (sig_str = 'JPG') then
                  actual_sig_jpg_count := actual_sig_jpg_count + 1;
                if (sig_str = 'AVI') then
                  actual_sig_avi_count := actual_sig_avi_count + 1;
                if (sig_str = 'EXE/DLL') then
                  actual_sig_exe_count := actual_sig_exe_count + 1;
                if (sig_str = 'WMV') then
                  actual_sig_wmv_count := actual_sig_wmv_count + 1;
                if (sig_str = 'ZIP') then
                  actual_sig_zip_count := actual_sig_zip_count + 1;
                if (sig_str = 'PLIST (BINARY)') then
                  actual_sig_plist_count := actual_sig_plist_count + 1; // plist
                if (sig_str = 'OST') then
                  actual_sig_ost_count := actual_sig_ost_count + 1; // ost
                if (sig_str = 'PST') then
                  actual_sig_pst_count := actual_sig_pst_count + 1; // pst
              end;

              // Count of Canon pictures using metadata field ---------------------------
              if assigned(Field_Exif271Make) then
              begin
                if Field_Exif271Make.AsString[filecount_Entry] <> '' then
                begin
                  actual_metadata_271Make_count := actual_metadata_271Make_count + 1;
                  // ConsoleLog(IntToStr(j) + SPACE + filecount_Entry.EntryName + SPACE + Field_Exif271Make.asString[filecount_Entry]);
                  inc(j);
                end;
                if (POS('Canon', Field_Exif271Make.AsString[filecount_Entry]) > 0) then
                  actual_metadata_271Canon_count := actual_metadata_271Canon_count + 1;
              end
              else
              begin
                actual_metadata_271Make_count := -1;
                actual_metadata_271Canon_count := -1;
              end;
            end;
          end;
          filecount_Entry := aDataStore.Next;
          Progress.IncCurrentProgress;
        end;

      if ModuleName = 'Artifacts' then
        actual_module_count_Artifacts := actual_module_file_count;
      if ModuleName = 'Bookmarks' then
        actual_module_count_Bookmarks := actual_module_file_count;
      if ModuleName = 'Email' then
        actual_module_count_Email := actual_module_file_count;
      if ModuleName = 'Registry' then
      begin
        actual_module_count_Registry := actual_module_file_count;
        while assigned(filecount_Entry) and (Progress.isRunning) do
        begin
          if filecount_Entry.EntryName = 'ComputerName' then
          begin
            if assigned(KeyData_Field) then
              try
                keydata_str := KeyData_Field.AsString[filecount_Entry];
                if keydata_str = Item^.expected_RG_computername then
                  actual_keydata_computername_count := actual_keydata_computername_count + 1;
              except
                ConsoleLog('Error reading registry Key Data.'); // noslz
              end;
          end;
          filecount_Entry := aDataStore.Next;
          Progress.IncCurrentProgress;
        end;
      end;
      filecount_time_taken_int := (GetTickCount64 - filecount_tick_count);
      filecount_time_taken_int := trunc(filecount_time_taken_int / 1000);
      Reporting(ModuleName);
    end
    else
    begin
      ConsoleLog(stringofchar('=', CHAR_LENGTH));
      if (ModuleName = 'Artifacts') and ((Item^.Image_Name = 'f29f4301f10ab350b4774b14ae654634') or (Item^.Image_Name = '114f4c031759ac4756df54720285c5be') or (Item^.Image_Name = '00731bee6e94010ecc4e4645eb19610f')) then
        ConsoleLog(RPad('No files in:', rpad_value) + (RPad(ModuleName, rpad_value2) + 'OK (0 expected)'))
      else
        ConsoleLog(RPad('No files in:', rpad_value) + ModuleName);
      if ModuleName = 'Registry' then
        ConsoleLog(stringofchar('=', CHAR_LENGTH));
    end;

    if (ModuleName = 'Email') then
    begin
      Progress.Log(RPad('Total Attachments:', rpad_value) + IntToStr(att_total_int));
      if LOG_EMAIL_ATTACHMENTS then
      begin
        if jpg_ext_StringList.Count > 0 then
        begin
          jpg_ext_StringList.Sort;
          ConsoleLog(Format('%-49s %-41s %-38s', ['JPG Attachments by Extension:', IntToStr(jpg_ext_StringList.Count), '']));
          ConsoleLog(jpg_ext_StringList.text);
          ConsoleLog(stringofchar('=', CHAR_LENGTH));
        end;
        if jpg_sig_StringList.Count > 0 then
        begin
          jpg_sig_StringList.Sort;
          ConsoleLog(Format('%-49s %-41s %-38s', ['JPG Attachments by Signature:', IntToStr(jpg_sig_StringList.Count), '']));
          ConsoleLog(jpg_sig_StringList.text);
        end;
      end;
    end;
  finally
    jpg_ext_StringList.free;
    jpg_sig_StringList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Volume ID
// ------------------------------------------------------------------------------
procedure VolumeID;
var
  aDeterminedFileDriverInfo: TFileTypeInformation;
  anEntry: TEntry;
  aParentNode: TPropertyNode;
  aPropertyTree: TPropertyParent;
  aReader: TEntryReader;
  aRootProperty: TPropertyNode;
  EntryList: TDataStore;
  Volume_ID: string;
begin
  EntryList := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(EntryList) then
    Exit;
  try
    Progress.Initialize(EntryList.Count, 'Searching for Volume Boot Record' + SPACE + RUNNING); // noslz
    anEntry := EntryList.First;
    while assigned(anEntry) and Progress.isRunning do
    begin
      // Get Volume ID (Serial)
      if anEntry.IsSystem and (RegexMatch(anEntry.EntryName, 'Volume Boot Record', False)) then // noslz
      begin
        DetermineFileType(anEntry);
        aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
        if (aDeterminedFileDriverInfo.ShortDisplayName = 'Volume Boot Record') or (aDeterminedFileDriverInfo.ShortDisplayName = 'NTFS') then
        begin
          aReader := TEntryReader.Create;
          try
            if aReader.OpenData(anEntry) then
            begin
              aPropertyTree := nil;
              if ProcessDisplayProperties(anEntry, aPropertyTree, aReader) then
              begin
                aRootProperty := aPropertyTree.RootProperty;
                if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
                begin
                  aParentNode := TPropertyNode(aPropertyTree.RootProperty.GetFirstNodeByName('Volume ID'));
                  if assigned(aParentNode) then
                  begin
                    Volume_ID := aParentNode.PropDisplayValue;
                    VolumeID_StringList.Add(Volume_ID);
                    actual_volume_id := actual_volume_id + Volume_ID;
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
            aReader.free;
          end;
        end;
      end;
      anEntry := EntryList.Next;
      Progress.IncCurrentProgress;
    end;
  finally
    EntryList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Sort by Name
// ------------------------------------------------------------------------------
function SortbyName(Item1, Item2: Pointer): integer;
var
  anEntry1: TEntry;
  anEntry2: TEntry;
  name1: string;
  name2: string;
begin
  Result := 0;
  if (Item1 <> nil) and (Item2 <> nil) then
  begin
    anEntry1 := TEntry(Item1);
    anEntry2 := TEntry(Item2);
    name1 := anEntry1.EntryName;
    name2 := anEntry2.EntryName;
    if name1 > name2 then
      Result := 1
    else if name1 < name2 then
      Result := -1;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Find Differences
// ------------------------------------------------------------------------------
procedure ProgressLog_Differences(the_attribute: string; the_StringList: TStringList);
var
  t: integer;
  was_version_str: string;
begin
  was_version_str := Copy(CmdLine.Params[1], 1, 12);
  if assigned(the_StringList) and (the_StringList.Count > 0) then
  begin
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    ConsoleLog(the_attribute + ' Difference:');
    ConsoleLog(Format('%-8s %-40s %-42s %-30s', ['BATES', 'FILENAME (trunc)', UpperCase(the_attribute) + ' WAS - ' + was_version_str, UpperCase(the_attribute) + ' IS - ' + CurrentVersion]));
    for t := 0 to the_StringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      ConsoleLog(the_StringList[t]);
    end;
    ConsoleLog('Total: ' + IntToStr(the_StringList.Count));
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Check against external file
// ------------------------------------------------------------------------------
procedure ReadExternalFile;
var
  Different_Extension_StringList: TStringList;
  Different_LogicalSize_StringList: TStringList;
  Different_MD5_StringList: TStringList;
  Different_PhysicalSize_StringList: TStringList;
  Different_Signature_StringList: TStringList;
  External_File_StringList: TStringList;
  FilesAll_TList: TList;
  afileext: string;
  Entry: TEntry;
  EntryName_Trunc_str: string;
  EntryName_Trunc_str2: string;
  external_check_tick_count_display: string;
  external_check_tick_count: uint64;
  Field_FileSignature: TDataStoreField;
  Field_MD5: TDataStoreField;
  FilesAll_TList_Count: integer;
  format_str: string;
  format_str_2: string;
  heading_bl: boolean;
  i, k, t: integer;
  inExpanded_str: string;
  IsCompressed_str: string;
  IsDirectory_str: string;
  isExpanded_str: string;
  linelist: TStringList;
  match_bl: boolean;
  md5_str: string;
  not_found_counter: integer;
  report_str_1_formatted: string;
  sig_str: string;
  time_taken_int: uint64;
  txt_nomatch_header_bl: boolean;

begin
  // Read the external file into a StringList
  External_File_StringList := TStringList.Create;
  Different_Extension_StringList := TStringList.Create;
  Different_LogicalSize_StringList := TStringList.Create;
  Different_MD5_StringList := TStringList.Create;
  Different_PhysicalSize_StringList := TStringList.Create;
  Different_Signature_StringList := TStringList.Create;
  try
    if FileExists(gCompare_TXT) then
    begin
      ConsoleLog(RPad('Reading external file:', rpad_value) + gCompare_TXT); // noslz
      External_File_StringList.LoadFromFile(gCompare_TXT);
      ConsoleLog(RPad('External file read:', rpad_value) + IntToStr(External_File_StringList.Count)); // noslz
      ConsoleLog(stringofchar('-', CHAR_LENGTH));
    end
    else
    begin
      External_File_StringList.free;
      Exit;
    end;

    linelist := TStringList.Create;
    FilesAll_TList := FileSystemEntryList.GetEntireList;
    try
      if assigned(FilesAll_TList) and (FilesAll_TList.Count > 0) then
        if assigned(External_File_StringList) and (External_File_StringList.Count > 0) and assigned(FilesAll_TList) and (FilesAll_TList.Count > 0) then
        begin
          heading_bl := True;
          not_found_counter := 0;
          Progress.DisplayMessageNow := ('Checking external file' + RUNNING); // noslz
          Progress.CurrentPosition := 0;
          Progress.Max := FilesAll_TList.Count;
          FilesAll_TList_Count := FilesAll_TList.Count;
          linelist.Delimiter := PIPE; // must use | as , can appear in file name
          linelist.StrictDelimiter := True;

          // Loop every file in the File System
          for i := 0 to FilesAll_TList.Count - 1 do
          begin
            time_taken_int := 0;
            external_check_tick_count := GetTickCount64;
            Progress.DisplayMessages := ('Checking external file (' + IntToStr(i) + ' of ' + IntToStr(FilesAll_TList_Count) + SPACE + ' - FS Not found: ' + IntToStr(not_found_counter) + ')' + RUNNING); // noslz
            if not Progress.isRunning then
              break;
            Entry := TEntry(FilesAll_TList[i]);

            if Entry.EntryName = gcase_name then
              Continue;

            Field_MD5 := FileSystemEntryList.DataFields.FieldByName[FIELDBYNAME_HASH_MD5];
            if assigned(Field_MD5) then
            begin
              md5_str := Field_MD5.AsString[Entry];
              if md5_str = null then
                md5_str := '';
            end
            else
              md5_str := '';

            Field_FileSignature := FileSystemEntryList.DataFields.FieldByName('FILE_TYPE');
            if assigned(Field_FileSignature) then
            begin
              sig_str := Field_FileSignature.AsString[Entry];
              if sig_str = null then
                sig_str := '';
            end
            else
              sig_str := '';

            // Loop every record in the external file
            match_bl := False;
            for k := 0 to External_File_StringList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;

              linelist.DelimitedText := External_File_StringList[k];
              afileext := Entry.EntryNameExt; // Matches GUI display. This does not: afileext := extractfileext(Entry.EntryName);

              if Entry.IsCompressed then
                IsCompressed_str := 'Y'
              else
                IsCompressed_str := '';
              if Entry.InExpanded then
                inExpanded_str := 'Y'
              else
                inExpanded_str := '';
              if Entry.isExpanded then
                isExpanded_str := 'Y'
              else
                isExpanded_str := '';
              if Entry.IsDirectory then
                IsDirectory_str := 'Y'
              else
                IsDirectory_str := '';

              format_str := '%-49s %-10s %-15s %-15s %-33s %-12s %-5s %-5s %-5s %-5s %-5s';

              EntryName_Trunc_str := Entry.EntryName;
              EntryName_Trunc_str := Copy(EntryName_Trunc_str, 1, 40);

              report_str_1_formatted := Format(format_str, [EntryName_Trunc_str, afileext, IntToStr(Entry.LogicalSize), IntToStr(Entry.PhysicalSize), md5_str, sig_str, IsDirectory_str, IsCompressed_str, isExpanded_str, inExpanded_str,
                IntToStr(Entry.ID)]);

              if MD5HashString(Entry.FullPathName) = linelist[0] then
              begin
                format_str_2 := '%-8s %-40s %-42s %-30s';
                // Check Extension - LineList 2: In stable some folders have extensions. In beta no folders have extensions.
                if afileext <> linelist[2] then
                begin
                  if (Entry.IsDirectory) and (afileext <> '') then
                  begin
                  end
                  else
                    Different_Extension_StringList.Add(Format(format_str_2, [IntToStr(Entry.ID), EntryName_Trunc_str, linelist[2], afileext]));
                end;
                // Check Logical Size - LineList 3
                if IntToStr(Entry.LogicalSize) <> linelist[3] then
                  Different_LogicalSize_StringList.Add(Format(format_str_2, [IntToStr(Entry.ID), EntryName_Trunc_str, linelist[3], IntToStr(Entry.LogicalSize)]));
                // Check Physical Size - LineList 4
                if IntToStr(Entry.PhysicalSize) <> linelist[4] then
                  Different_PhysicalSize_StringList.Add(Format(format_str_2, [IntToStr(Entry.ID), EntryName_Trunc_str, linelist[4], IntToStr(Entry.PhysicalSize)]));
                // Check MD5 - LineList 5
                if md5_str <> linelist[5] then
                  Different_MD5_StringList.Add(Format(format_str_2, [IntToStr(Entry.ID), EntryName_Trunc_str, linelist[5], md5_str]));
                // Check Signature - LineList 6
                if sig_str <> linelist[6] then
                  Different_Signature_StringList.Add(Format(format_str_2, [IntToStr(Entry.ID), EntryName_Trunc_str, linelist[6], sig_str]));
                match_bl := True;
                External_File_StringList.Delete(k);
                break;
              end;
            end;

            // Add the tick count to the unmatched files logging
            external_check_tick_count_display := '';
            Progress.IncCurrentProgress;
            time_taken_int := (GetTickCount64 - external_check_tick_count);
            if time_taken_int > 1000 then // Milliseconds
            begin
              time_taken_int := trunc(time_taken_int / 1000);
              external_check_tick_count_display := (FormatDateTime('hh:nn:ss', time_taken_int / SecsPerDay));
            end;

            // Report UnMatched Files
            if (match_bl = False) then
            begin
              if heading_bl then
              begin
                ConsoleLog(RS_WARNING + ':' + SPACE + 'FS FullPathName did not match:');
                ConsoleLog(Format(format_str, ['FILENAME (trunc)', RS_EXT, 'L-SIZE', 'P-SIZE', 'MD5', RS_SIG, 'IsDIR', 'COMPR', 'IsEXP', 'InEXP', 'BATES']));
                heading_bl := False;
              end;
              ConsoleLog(report_str_1_formatted + SPACE + external_check_tick_count_display);
              not_found_counter := not_found_counter + 1;
            end;
          end;
          ConsoleLog(RPad('Total FS files not matched:', rpad_value) + IntToStr(not_found_counter));

          // Match Summary - Left in external file
          ConsoleLog(stringofchar('-', CHAR_LENGTH));
          if External_File_StringList.Count = 0 then
            ConsoleLog('All files in the external file matched.'); // noslz

          txt_nomatch_header_bl := False;
          if External_File_StringList.Count > 0 then
          begin
            for t := 0 to External_File_StringList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              linelist.DelimitedText := External_File_StringList[t];

              if linelist[11] <> '1' then // Do not include Case Name
              begin
                if txt_nomatch_header_bl = False then // Log heading once
                begin
                  ConsoleLog(RS_WARNING + ':' + SPACE + 'External TXT files did not match:'); // noslz
                  ConsoleLog(Format(format_str, ['FILENAME (trunc)', RS_EXT, 'L-SIZE', 'P-SIZE', 'MD5', RS_SIG, 'IsDIR', 'COMPR', 'IsEXP', 'InEXP', 'BATES']));
                  txt_nomatch_header_bl := True;
                end;

                EntryName_Trunc_str2 := linelist[1];
                EntryName_Trunc_str2 := Copy(EntryName_Trunc_str2, 1, 40);
                ConsoleLog(Format(format_str, [EntryName_Trunc_str2, linelist[2], linelist[3], linelist[4], linelist[5], linelist[6], linelist[7], linelist[8], linelist[9], linelist[10], linelist[11]]));
              end;
            end;
            ConsoleLog(RPad('Total TXT files not matched:', rpad_value) + IntToStr(not_found_counter));
          end;

          ProgressLog_Differences('Extension', Different_Extension_StringList);
          ProgressLog_Differences('Logical Size', Different_LogicalSize_StringList);
          ProgressLog_Differences('Physical Size', Different_PhysicalSize_StringList);
          ProgressLog_Differences('MD5', Different_MD5_StringList);
          ProgressLog_Differences('Signature', Different_Signature_StringList);
        end;
    finally
      FilesAll_TList.free;
      linelist.free;
    end;
  finally
    Different_Extension_StringList.free;
    Different_LogicalSize_StringList.free;
    Different_MD5_StringList.free;
    Different_PhysicalSize_StringList.free;
    Different_Signature_StringList.free;
    External_File_StringList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Create Save Folder
// ------------------------------------------------------------------------------
function CreateFolder(the_Save_Folder: string): boolean;
begin
  Result := False;
  begin
    if ForceDirectories(OSFILENAME + the_Save_Folder) and DirectoryExists(the_Save_Folder) then
      Progress.Log(RPad('Folder created:', rpad_value) + the_Save_Folder) // noslz
    else
      MessageUsr('Create folder failed: ' + the_Save_Folder); // noslz
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Save of StringList to File
// ------------------------------------------------------------------------------
procedure Save_StringList_To_File(aStringList: TStringList; file_path_str: string);
var
  anEncoding: TEncoding;
  file_folder_str: string;
begin
  file_folder_str := ExtractFilePath(file_path_str);
  if assigned(aStringList) and (aStringList.Count > 1) then
  begin
    if not DirectoryExists(file_folder_str) then
      CreateFolder(file_folder_str);
    if DirectoryExists(file_folder_str) then
    begin
      if not FileExists(file_path_str) then
      begin
        anEncoding := TEncoding.Create;
        try
          aStringList.SaveToFile(file_path_str, anEncoding.UTF8);
        except
          Progress.Log(ATRY_EXCEPT_STR + '' + SPACE + file_path_str);
          anEncoding.free;
        end;
        begin
          if FileExists(file_path_str) then
          begin
            gbl_open_folder := False;
            ShellExecute(0, nil, 'explorer.exe', Pchar(file_folder_str), nil, 1);
          end;
        end;
      end;
    end;
  end;
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

// ------------------------------------------------------------------------------
// Procedure: Create TXT File Name
// ------------------------------------------------------------------------------
function CreateFileName(save_fldr_str: string): string;
var
  TXT_fullpath: string;
  TXT_fullpath_plus: string;
  g: integer;
  the_Save_Folder: string;
begin
  the_Save_Folder := save_fldr_str + BS + FLDR_VALIDATION + BS + gTheCurrentDevice; // noslz
  Progress.DisplayTitle := SCRIPT_NAME + SPACE + 'Create TXT File'; // noslz
  TXT_fullpath := (the_Save_Folder + BS + CurrentVersion + '_' + gDeviceName_str + '_Validation_' + RUNAS_STR + '.txt');
  if (FileExists(TXT_fullpath)) then
  begin
    SetLength(TXT_fullpath, Length(TXT_fullpath) - 4);
    TXT_fullpath_plus := TXT_fullpath + '_1';
    for g := 1 to 100 do
    begin
      if FileExists(TXT_fullpath_plus + '.txt') then
        TXT_fullpath_plus := (TXT_fullpath + '_' + IntToStr(g + 1))
      else
      begin
        TXT_fullpath := TXT_fullpath_plus + '.txt';
        break;
      end;
    end;
  end;
  Result := TXT_fullpath;
end;

// ------------------------------------------------------------------------------
// Procedure: Create TXT File
// ------------------------------------------------------------------------------
procedure CreateTXTFile(aModule_str: string);
var
  AllFiles_TList: TList;
  bm_str: string;
  fex_build_type_str: string;
  g: integer;
  the_Save_Folder: string;
  TXT_fullpath: string;
  TXT_fullpath_plus: string;
begin
  the_Save_Folder := FLDR_LOC + BS + gTheCurrentDevice + BS + UpperCase(aModule_str);
  Progress.DisplayTitle := SCRIPT_NAME + SPACE + 'Create TXT File (' + aModule_str + ')'; // noslz
  fex_build_type_str := UpperCase(GetFEXVersion);
  if GetFEXVersion = '' then
    fex_build_type_str := 'R';
  TXT_fullpath := (the_Save_Folder + BS + CurrentVersion + fex_build_type_str + '_' + gDeviceName_str + '_' + aModule_str + '.txt');
  if gbl_bmonly then
    bm_str := '_Bookmarked_'
  else
    bm_str := '';
  if (FileExists(TXT_fullpath)) then
  begin
    SetLength(TXT_fullpath, Length(TXT_fullpath) - 4);
    TXT_fullpath_plus := TXT_fullpath + '_1';
    for g := 1 to 100 do
    begin
      if FileExists(TXT_fullpath_plus + bm_str + '.txt') then
        TXT_fullpath_plus := (TXT_fullpath + bm_str + '_' + IntToStr(g + 1))
      else
      begin
        TXT_fullpath := TXT_fullpath_plus + bm_str + '.txt';
        break;
      end;
    end;
  end;
  ConsoleLog(RPad('Create TXT file: ' + aModule_str, rpad_value) + 'True'); // noslz

  if not DirectoryExists(the_Save_Folder) then
    CreateFolder(the_Save_Folder);

  if DirectoryExists(the_Save_Folder) then
  begin
    if (FileExists(TXT_fullpath)) then
    begin
      MessageUsr(RPad('The file already exists:', rpad_value) + TXT_fullpath); // noslz
    end
    else
    begin
      ConsoleLog(RPad('Creating a compare file for this version:', rpad_value) + TXT_fullpath);
      if aModule_str = 'File_System' then
      begin
        AllFiles_TList := FileSystemEntryList.GetEntireList;
        try
          Sig_And_Hash_Check('File System');
          { if gbl_FS_Signature_Status = False then } SignatureAnalysis('File System');
          { if gbl_FS_Hash_Status = False then } HashFiles(AllFiles_TList, '1024');
          Create_File_List_File_System(TXT_fullpath);
        finally
          AllFiles_TList.free;
        end;
      end;
      if aModule_str = 'Keyword_Search' then
        Create_File_List_Keyword_Search(TXT_fullpath);
      if aModule_str = 'Email' then
        Create_File_List_Email(TXT_fullpath);
    end;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Create File List: File System
// ------------------------------------------------------------------------------
procedure Create_File_List_File_System(file_path_str: string);
var
  afile_ext: string;
  anEntry: TEntry;
  Field_FileSignature: TDataStoreField;
  Field_MD5: TDataStoreField;
  FileDriverInfo: TFileTypeInformation;
  FileList_LostFile_StringList: TStringList;
  FileList_StringList: TStringList;
  FileList_VideoThumbnail_StringList: TStringList;
  flDatastore: TDataStore;
  header_str: string;
  inExpanded_str: string;
  IsCompressed_str: string;
  IsDirectory_str: string;
  isExpanded_str: string;
  MD5_Full_Path_Name: string;
  md5_str: string;
  sig_str: string;
  temp_path_str: string;

  procedure addtostrlist(aStringList: TStringList);
  begin
    aStringList.Add(MD5_Full_Path_Name + PIPE + anEntry.EntryName + PIPE + afile_ext + PIPE + IntToStr(anEntry.LogicalSize) + PIPE + IntToStr(anEntry.PhysicalSize) + PIPE + md5_str + PIPE + sig_str + PIPE + IsCompressed_str + PIPE +
      IsDirectory_str + PIPE + IntToStr(anEntry.ID));
  end;

begin
  flDatastore := GetDataStore(DATASTORE_FILESYSTEM);
  if flDatastore = nil then
    Exit;
  Field_FileSignature := flDatastore.DataFields.FieldByName('FILE_TYPE');
  FileList_StringList := TStringList.Create;
  FileList_LostFile_StringList := TStringList.Create;
  FileList_VideoThumbnail_StringList := TStringList.Create;
  try
    anEntry := flDatastore.First;
    Progress.Initialize(flDatastore.Count, 'Creating a comparison file' + RUNNING);
    header_str := ('MD5 Full Path' + PIPE + 'Filename' + PIPE + RS_EXT + PIPE + 'Logical Size' + PIPE + 'Physical Size' + PIPE + 'Hash (MD5)' + PIPE + 'Signature' + PIPE + 'IsCompressed' + PIPE + 'IsDirectory' + PIPE + 'Bates ID');
    FileList_LostFile_StringList.Add(header_str);
    FileList_StringList.Add(header_str);
    FileList_VideoThumbnail_StringList.Add(header_str);

    while assigned(anEntry) and (Progress.isRunning) do
    begin
      if gbl_bmonly and not(anEntry.isBookmarked) then
      begin
        anEntry := flDatastore.Next;
        Continue;
      end;
      afile_ext := anEntry.EntryNameExt; // Matches GUI display. This does not: afileext := extractfileext(Entry.EntryName);
      FileDriverInfo := anEntry.DeterminedFileDriverInfo;
      sig_str := '';
      if assigned(Field_FileSignature) then
        try
          sig_str := Field_FileSignature.AsString[anEntry];
        except
          ConsoleLog('Error');
        end;
      Field_MD5 := FileSystemEntryList.DataFields.FieldByName[FIELDBYNAME_HASH_MD5];
      if assigned(Field_MD5) then
      begin
        md5_str := Field_MD5.AsString[anEntry];
        if md5_str = null then
          md5_str := '';
      end
      else
        md5_str := '';
      MD5_Full_Path_Name := MD5HashString(anEntry.FullPathName);
      if anEntry.IsCompressed then
        IsCompressed_str := 'Y'
      else
        IsCompressed_str := '';
      if anEntry.InExpanded then
        inExpanded_str := 'Y'
      else
        inExpanded_str := '';
      if anEntry.isExpanded then
        isExpanded_str := 'Y'
      else
        isExpanded_str := '';
      if anEntry.IsDirectory then
        IsDirectory_str := 'Y'
      else
        IsDirectory_str := '';
      // Fix Ups
      if anEntry.IsDirectory then
        afile_ext := ''; // **NOTE** In old version folders like "ko.lproj" get a file extension. Fixed in new version. Updated here for comparison purposes.
      // Add to Lists
      if dstLostFile in anEntry.Status then
        addtostrlist(FileList_LostFile_StringList)
      else if anEntry.InExpanded and (sig_str = 'Bmp') and (POS('Frame', anEntry.EntryName) > 0) then
      begin
        addtostrlist(FileList_VideoThumbnail_StringList);
      end
      else
        addtostrlist(FileList_StringList);
      anEntry := flDatastore.Next;
      Progress.IncCurrentProgress;
    end;
    Save_StringList_To_File(FileList_StringList, file_path_str);
    if FileList_LostFile_StringList.Count > 0 then
    begin
      temp_path_str := file_path_str;
      SetLength(temp_path_str, Length(temp_path_str) - 4);
      Save_StringList_To_File(FileList_LostFile_StringList, temp_path_str + '_LostFiles.txt'); // noslz
    end;
    if FileList_VideoThumbnail_StringList.Count > 0 then
    begin
      temp_path_str := file_path_str;
      SetLength(temp_path_str, Length(temp_path_str) - 4);
      Save_StringList_To_File(FileList_VideoThumbnail_StringList, temp_path_str + '_VideoThumbnails.txt'); // noslz
    end;
  finally
    flDatastore.free;
    FileList_StringList.free;
    FileList_LostFile_StringList.free;
    FileList_VideoThumbnail_StringList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Function: Has Keyword Been Searched
// ------------------------------------------------------------------------------
Function HashKeywordBeenSearched(keyword: string): boolean;
var
  kw_EntryList: TDataStore;
  kw_Entry: TEntry;
begin
  Result := False;
  kw_EntryList := GetDataStore(DATASTORE_KEYWORDSEARCH);
  if kw_EntryList = nil then
    Exit;
  try
    kw_Entry := kw_EntryList.First;
    if kw_Entry = nil then
    begin
      ConsoleLog('No entries found.' + TSWT); // noslz
      Exit;
    end;
    while assigned(kw_Entry) and (Progress.isRunning) do
    begin
      if kw_Entry.IsDirectory then
      begin
        if (lowercase(kw_Entry.EntryName) = lowercase(keyword)) then
        begin
          Result := True;
          break;
        end;
      end;
      kw_Entry := kw_EntryList.Next;
    end;
  finally
    kw_EntryList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Create Email Message List
// ------------------------------------------------------------------------------
procedure Create_File_List_Email(file_path_str: string);
var
  anEntry: TEntry;
  bcc_str: string;
  cc_str: string;
  col_BCC: TDataStoreField;
  col_CC: TDataStoreField;
  col_SentFrom: TDataStoreField;
  col_SentTo: TDataStoreField;
  EntryList: TDataStore;
  Header_StringList: TStringList;
  process_count_int: integer;
  Search_StringList: TStringList;
  sent_from_str: string;
  sent_to_str: string;
  total_entries_int: integer;
  use_short_report_str_bl: boolean;

begin
  EntryList := GetDataStore(DATASTORE_EMAIL);
  if EntryList = nil then
    Exit;
  Header_StringList := TStringList.Create;
  Search_StringList := TStringList.Create;
  try
    col_SentTo := EntryList.DataFields.GetFieldByName('TO'); // noslz
    col_SentFrom := EntryList.DataFields.GetFieldByName('FROM'); // noslz
    col_BCC := EntryList.DataFields.GetFieldByName('BCC'); // noslz
    col_CC := EntryList.DataFields.GetFieldByName('CC'); // noslz
    anEntry := EntryList.First;
    Progress.Initialize(EntryList.Count, 'Processing' + RUNNING); // noslz
    total_entries_int := EntryList.Count;
    Header_StringList.Add('Filename' + COMMA + 'MD5_FULL_PATH' + COMMA + 'LOGICAL_SIZE' + COMMA + 'PHYSICAL_SIZE' + COMMA + 'TO' + COMMA + 'FROM' + COMMA + 'CC' + COMMA + 'BCC'); // noslz
    while assigned(anEntry) and (Progress.isRunning) do
    begin
      process_count_int := process_count_int + 1;
      sent_to_str := col_SentTo.AsString(anEntry);
      sent_from_str := col_SentFrom.AsString(anEntry);
      if sent_to_str = '' then
        sent_to_str := '<>';
      if sent_from_str = '' then
        sent_from_str := '<>';
      if cc_str = '' then
        cc_str := '<>';
      if bcc_str = '' then
        bcc_str := '<>';
      use_short_report_str_bl := False;
      if use_short_report_str_bl then
        Search_StringList.Add('FN:' + (anEntry.EntryName) + PIPE + 'LS:' + IntToStr(anEntry.LogicalSize) + PIPE + 'PS:' + IntToStr(anEntry.PhysicalSize)) // noslz
      else
        Search_StringList.Add('FN:' + (anEntry.EntryName) + PIPE + 'FP:' + (anEntry.FullPathName) + PIPE + 'LS:' + IntToStr(anEntry.LogicalSize) + PIPE + 'PS:' + IntToStr(anEntry.PhysicalSize) + PIPE + 'TO:' + (sent_to_str) + PIPE + 'FR:' +
          (sent_from_str) + PIPE + 'CC:' + (cc_str) + PIPE + 'BC:' + (bcc_str)); // noslz
      Progress.IncCurrentProgress;
      Progress.DisplayMessages := 'Processed: ' + IntToStr(process_count_int) + ' of ' + IntToStr(total_entries_int); // noslz
      anEntry := EntryList.Next;
    end;
    Search_StringList.Sort;
    Header_StringList.AddStrings(Search_StringList);
    file_path_str := file_path_str;
    if Header_StringList.Count > 1 then
      Save_StringList_To_File(Header_StringList, file_path_str)
    else
      MessageUsr('No entries in the Email Search module.');
  finally
    EntryList.free;
    Header_StringList.free;
    Search_StringList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Create Keyword Search File List
// ------------------------------------------------------------------------------
procedure Create_File_List_Keyword_Search(file_path_str: string);
var
  anEntry: TEntry;
  EntryList: TDataStore;
  Field_Hits: TDataStoreField;
  field_Hits_str: string;
  KewywordHeader_StringList: TStringList;
  KeywordSearch_StringList: TStringList;
  process_count_int: integer;
  total_entries_int: integer;
begin
  EntryList := GetDataStore(DATASTORE_KEYWORDSEARCH);
  if EntryList = nil then
    Exit;
  KewywordHeader_StringList := TStringList.Create;
  KeywordSearch_StringList := TStringList.Create;
  try
    anEntry := EntryList.First;
    Progress.Initialize(EntryList.Count, 'Processing' + RUNNING); // noslz
    total_entries_int := EntryList.Count;
    Field_Hits := EntryList.DataFields.FieldByName['HITCOUNT']; // noslz
    while assigned(anEntry) and (Progress.isRunning) do
    begin
      process_count_int := process_count_int + 1;
      if anEntry.IsDirectory and (anEntry.EntryName = 'Keyword Search') or // noslz
        (lowercase(anEntry.EntryName) = lowercase(Item^.expected_KW_keyword1)) or (lowercase(anEntry.EntryName) = lowercase(Item^.expected_KW_keyword2)) or (lowercase(anEntry.EntryName) = lowercase(Item^.expected_KW_keyword1_regex)) then
      begin
      end
      else
      begin
        if assigned(Field_Hits) then
        begin
          field_Hits_str := Field_Hits.AsString[anEntry];
          { PIPE delimited } KeywordSearch_StringList.Add(anEntry.EntryName + PIPE + field_Hits_str + PIPE + MD5HashString(anEntry.FullPathName) + PIPE + IntToStr(anEntry.LogicalSize) + PIPE + IntToStr(anEntry.PhysicalSize));
          { TAB delimited }// KeywordSearch_StringList.Add(anEntry.EntryName + #9 + field_Hits_str + #9 + MD5HashString(anEntry.FullPathName) + #9 + IntToStr(anEntry.LogicalSize) + #9 + IntToStr(anEntry.PhysicalSize));
        end;
      end;
      Progress.IncCurrentProgress;
      Progress.DisplayMessages := 'Processed: ' + IntToStr(process_count_int) + ' of ' + IntToStr(total_entries_int); // noslz
      anEntry := EntryList.Next;
    end;
    KeywordSearch_StringList.Sort;
    KewywordHeader_StringList.AddStrings(KeywordSearch_StringList);
    file_path_str := file_path_str;
    if KewywordHeader_StringList.Count > 1 then
      Save_StringList_To_File(KewywordHeader_StringList, file_path_str)
    else
      MessageUsr('No entries in the Keyword Search module.');
  finally
    EntryList.free;
    KewywordHeader_StringList.free;
    KeywordSearch_StringList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Compare File List
// ------------------------------------------------------------------------------
procedure CompareFileList;
var
  Attr: integer;
  i: integer;
  MyFileList: TStringList;
begin
  Attr := $00000080; // faNormal;
  Attr := faDirectory;
  Try
    ConsoleLog(FLDR_LOC + BS + gTheCurrentDevice);
    MyFileList := GetFileList(FLDR_LOC + BS + gTheCurrentDevice + '*.txt', Attr); // noslz
    if assigned(MyFileList) then
    begin
      for i := 0 to MyFileList.Count - 1 do
      begin
        if POS(gDeviceName_str, MyFileList[i]) > 0 then
          ConsoleLog(MyFileList[i]);
      end;
    end;
  finally
    MyFileList.free;
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Log Parameters Received
// ------------------------------------------------------------------------------
procedure log_parameters_received;
var
  i: integer;
  param: string;
begin
  param := '';
  if (CmdLine.ParamCount > 0) then
  begin
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    ConsoleLog(RPad('Processing parameters received:', rpad_value) + IntToStr(CmdLine.ParamCount)); // noslz
    for i := 0 to CmdLine.ParamCount - 1 do
    begin
      ConsoleLog(' - Param ' + IntToStr(i) + ': ' + CmdLine.Params[i]); // noslz
      param := param + '"' + CmdLine.Params[i] + '"' + ' '; // noslz
    end;
    trim(param);
  end
  else
    ConsoleLog(RPad('Processing parameters received:', rpad_value) + 'None'); // noslz
  ConsoleLog(stringofchar('-', CHAR_LENGTH));
end;

// ------------------------------------------------------------------------------
// Procedure: Open Folder
// ------------------------------------------------------------------------------
procedure OpenFolder(aFolder: string);
begin
  if DirectoryExists(aFolder) then
    ShellExecute(0, nil, 'explorer.exe', Pchar(aFolder), nil, 1)
  else
    MessageUsr('Export folder not found:' + SPACE + aFolder); // noslz
end;

// ------------------------------------------------------------------------------
// Procedure: Set Field Names
// ------------------------------------------------------------------------------
procedure SetFieldNames;
begin
  Field_MD5 := FileSystemEntryList.DataFields.FieldByName['Hash (MD5)']; // noslz
  Field_SHA1 := FileSystemEntryList.DataFields.FieldByName['Hash (SHA1)']; // noslz
  Field_SHA256 := FileSystemEntryList.DataFields.FieldByName['Hash (SHA256)']; // noslz
  Field_Exif271Make := FileSystemEntryList.DataFields.FieldByName['Exif 271: Make']; // noslz
  Field_BookmarkFolder := FileSystemEntryList.DataFields.FieldByName['BOOKMARK_GROUP']; // noslz
end;

// ------------------------------------------------------------------------------
// Procedure: Compare to External File
// ------------------------------------------------------------------------------
function TestExternalCompareFile: boolean;
begin
  Result := False;
  ConsoleLog(RPad('Compare to external file:', rpad_value) + 'True'); // noslz
  if FileExists(gCompare_TXT) then
  begin
    ConsoleLog(RPad('Compare file found:', rpad_value) + gCompare_TXT); // noslz
    Result := True;
    gCompare_with_external_bl := True;
  end
  else
  begin
    ConsoleLog(RPad('ERROR: Could not find compare file:', rpad_value) + gCompare_TXT); // noslz
    Exit;
  end;
  if POS(gDeviceName_str, gCompare_TXT) > 0 then
  begin
    Progress.DisplayTitle := SCRIPT_NAME + ' - Compare: ' + ExtractFileName(gCompare_TXT); // noslz
    Result := True;
  end
  else
  begin
    ConsoleLog('Compare file does not match device. Refresh the button.'); // noslz
    MessageUsr('The compare file:' + #10#13 + #10#13 + gCompare_TXT + #10#13 + #10#13 + 'does not match the device:' + #10#13 + #10#13 + gDeviceName_str + #10#13 + #10#13 + 'Refresh the button.' + SPACE + TSWT);
  end;
  ConsoleLog(stringofchar('-', CHAR_LENGTH));
end;

// ------------------------------------------------------------------------------
// Procedure - count Triage in Bookmarks folder
// ------------------------------------------------------------------------------
procedure count_of_Triage_in_Bookmarks_folder;
var
  anEntryList: TDataStore;
  anEntry: TEntry;
  bl_triagefolderfound: boolean;
begin
  actual_BM_Triage_count_str := '';
  bl_triagefolderfound := False;
  anEntryList := GetDataStore(DATASTORE_BOOKMARKS);
  if not assigned(anEntryList) then
  begin
    Progress.Log('Not assigned a data store.' + SPACE + TSWT);
    Exit;
  end;
  anEntry := anEntryList.First;
  if not assigned(anEntry) then
  begin
    Progress.Log('No entries in the data store.' + SPACE + TSWT);
    anEntryList.free;
    Exit;
  end;
  try
    Progress.Initialize(anEntryList.Count, 'Processing...');
    while assigned(anEntry) and (Progress.isRunning) do
    begin
      actual_BM_Triage_count_str := IntToStr(anEntryList.Children(anEntry, True).Count);
      if anEntry.IsDirectory and (anEntry.EntryName = 'Triage') then
      begin
        bl_triagefolderfound := True;
        report_as_rgx('Triage', Item^.expected_BM_Triagecount_count_str, actual_BM_Triage_count_str);
        Exit;
      end;
      Progress.IncCurrentProgress;
      anEntry := anEntryList.Next;
    end;
  finally
    anEntryList.free;
  end;
  if bl_triagefolderfound = False then
    ConsoleLog(RPad('No files in:', rpad_value) + 'Triage bookmarks');
end;

procedure CheckLogFiles;
const
  PROC_NAME = 'CheckLogFiles';
var
  LogFiles_StringList: TStringList;
  log_fldr_pth: string;
  i, j: integer;
  temp_SList: TStringList;
  bl_error_found: boolean;
  ScriptName_str: string;
begin
  bl_error_found := False;
  if DirectoryExists(GetCurrentCaseDir) then
  begin
    log_fldr_pth := GetCurrentCaseDir + 'Logs';
    if DirectoryExists(log_fldr_pth) then
    begin
      LogFiles_StringList := TStringList.Create;
      try
        LogFiles_StringList := GetAllFileList(log_fldr_pth, '*.*', False, Progress);
        for i := 0 to LogFiles_StringList.Count - 1 do
        begin
          if FileExists(LogFiles_StringList[i]) then
          begin
            ScriptName_str := ExtractFileName(CmdLine.Path);
            ScriptName_str := ChangeFileExt(ScriptName_str, '');
            if RegexMatch(LogFiles_StringList[i], ScriptName_str + 'FileSystem|Root Task', False) then
              Continue;
            temp_SList := TStringList.Create;
            try
              try
                temp_SList.LoadFromFile(LogFiles_StringList[i]);
              except
                // Progress.Log(ATRY_EXCEPT_STR + RPad('LoadFromFile:', rpad_value) + LogFiles_StringList[i]); //noslz
              end;
              for j := 0 to temp_SList.Count - 1 do
              begin
                if RegexMatch(temp_SList[j], 'Access violation' + PIPE + // noslz
                  'An exception occurred' + PIPE + // noslz
                  ATRY_EXCEPT_STR + PIPE + // noslz
                  'Error in creating file' + PIPE + // noslz
                  'Exception:' + PIPE + // noslz
                  'Read of address' + PIPE + // noslz
                  // 'Unable to open file'  + PIPE + //noslz
                  'Unhandled Exception' + PIPE + // noslz
                  'Warning: Variable', False) then // noslz
                begin
                  ConsoleLog(RPad('ERROR IN LOG:', rpad_value) + LogFiles_StringList[i]); // noslz
                  ConsoleLog(RPad(HYPHEN + 'Line ' + IntToStr(j) + ':', rpad_value) + temp_SList[j]);
                  bl_error_found := True;
                end;
              end;
            finally
              FreeAndNil(temp_SList);
            end;
          end;
        end;
      finally
        LogFiles_StringList.free;
      end;
    end;
    if bl_error_found then
      ConsoleLog(stringofchar('-', CHAR_LENGTH));
  end;
  Progress.Log('Leaving ' + PROC_NAME);
end;

// ------------------------------------------------------------------------------
// Procedure: Get list of devices
// ------------------------------------------------------------------------------
Function GetDevices: string;
var
  Devices_DataStore: TDataStore;
  i, n: integer;
  Devices_TList: TList;
  Device_Entry: TEntry;
  Temp_TList: TList;
  temp_Entry: TEntry;
begin
  Result := '';
  file_carve_bl := False;
  file_carve_custom_byte_bl := False;
  Devices_DataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if Devices_DataStore = nil then
    Exit;
  temp_Entry := Devices_DataStore.First;
  Temp_TList := Devices_DataStore.Children(temp_Entry);
  Devices_TList := TList.Create;
  try
    Progress.Initialize(Devices_DataStore.Count, 'Getting device list' + RUNNING);

    for i := 0 to Temp_TList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      temp_Entry := TEntry(Temp_TList[i]);
      if temp_Entry.IsDevice then
        Devices_TList.Add(temp_Entry);
    end;

    ConsoleLog(RPad('FEX Version:', rpad_value) + CurrentVersion); // noslz
    ConsoleLog(RPad('Date Run:', rpad_value) + DateTimeToStr(now)); // noslz
    if GetInvestigatorName <> '' then
      ConsoleLog(RPad('Investigator:', rpad_value) + GetInvestigatorName); // noslz
    ConsoleLog(RPad('Case name:', rpad_value) + gcase_name); // noslz
    ConsoleLog(RPad('Number of devices:', rpad_value) + IntToStr(Devices_TList.Count)); // noslz
    if Devices_TList.Count <> 1 then
    begin
      ConsoleLog('Device count is ' + IntToStr(Devices_TList.Count) + '. This test should be run on a single device.'); // noslz
      bl_Continue := False;
    end
    else
    begin
      Device_Entry := TEntry(Devices_TList[0]);
      ConsoleLog(RPad('Device ' + IntToStr(i) + ':', rpad_value) + Device_Entry.EntryName); // noslz
      Result := Device_Entry.EntryName;
      gTheCurrentDevice := Result;
    end;

    // Set the item number based on the device
    if bl_Continue and (Result <> '') then
    begin
      Device_Entry := TEntry(Devices_TList[0]);
      identified_image_bl := False;
      for n := 1 to NumberOfSearchItems do
      begin
        Item := FileItems[n];
        gitem_int := n;
        if (MD5HashString(Device_Entry.EntryName) = Item^.Image_Name) and (Device_Entry.LogicalSize = Item^.Device_Logical_Size) then
        begin
          identified_image_bl := True;
          break;
        end;
      end;
      if identified_image_bl then
        ConsoleLog(RPad('Known Image:', rpad_value) + 'YES') // noslz
      else
        ConsoleLog(RPad('Known Image:', rpad_value) + 'NO'); // noslz
    end;

    ConsoleLog(stringofchar('-', CHAR_LENGTH));
  finally
    Devices_TList.free;
    Temp_TList.free;
    Devices_DataStore.free;
  end;
end;

procedure GetPicturesZip_TList(aTList: TList);
var
  anEntry: TEntry;
  DataStore_FS: TDataStore;
  DeterminedFileDriverInfo: TFileTypeInformation;
begin
  if not assigned(aTList) then
    Exit;
  DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(DataStore_FS) then
    Exit;
  anEntry := DataStore_FS.First;
  if not assigned(anEntry) then
    Exit;
  try
    while assigned(anEntry) and (Progress.isRunning) do
    begin
      if anEntry.EntryName = 'Pictures.zip' then
      begin
        DetermineFileType(anEntry);
        DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
        if UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = 'ZIP' then
          aTList.Add(anEntry);
      end;
      anEntry := DataStore_FS.Next;
    end;
  finally
    DataStore_FS.free;
  end;
end;

procedure CreateRunTimeTXT(aStringList: TStringList; save_name_str: string);
const
  HYPHEN = ' - ';
  PDF_FONT_SIZE = 8;
var
  CurrentCaseDir: string;
  SaveName: string;
  ExportedDir: string;
begin
  CurrentCaseDir := GetCurrentCaseDir;
  ExportedDir := CurrentCaseDir + 'Reports\';
  SaveName := GetUniqueFileName(ExportedDir + save_name_str);
  if DirectoryExists(CurrentCaseDir) then
    try
      if ForceDirectories(IncludeTrailingPathDelimiter(ExportedDir)) and DirectoryExists(ExportedDir) then
      begin
        aStringList.SaveToFile(SaveName);
        Sleep(500);
      end;
    except
      Progress.Log(ATRY_EXCEPT_STR + 'Creating runtime report: ' + SaveName);
    end;
end;

function GetInvestigatorName: string;
var
  DataStore_Inv: TDataStore;
  anEntry: TEntry;
begin
  Result := '';
  DataStore_Inv := GetDataStore('LocalInvestigator'); // noslz
  if assigned(DataStore_Inv) then
    try
      if DataStore_Inv.Count = 0 then
        Exit;
      anEntry := DataStore_Inv.First;
      Result := anEntry.EntryName;
    finally
      DataStore_Inv.free;
    end;
end;

procedure SaveResult(aStringList: TStringList);
var
  j: integer;
  tmp_str: string;
begin
  if BL_FEXLAB then
  begin
    // Save Result to global folder
    Progress.DisplayMessageNow := 'Searching for FEXLAB save folder' + RUNNING;
    if DirectoryExists(FLDR_GLB) then
    begin
      gsave_file_glb_str := CreateFileName(FLDR_GLB);
      ConsoleLog(RPad('Save to:', rpad_value) + gsave_file_glb_str);

      // Save to Global
      if ForceDirectories(ExtractFileDir(gsave_file_glb_str)) and DirectoryExists(ExtractFileDir(gsave_file_glb_str)) then // Do not use OSFILENAME for network folders
      begin
        Save_StringList_To_File(aStringList, gsave_file_glb_str);
        Sleep(500);
        if not FileExists(gsave_file_glb_str) then
          ConsoleLog(RPad('Error saving to global:', rpad_value) + gsave_file_glb_str);
      end
      else
        ConsoleLog(RPad('Could not create:', rpad_value) + ExtractFileDir(gsave_file_glb_str));

      // Save to Warnings
      tmp_str := FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_WARNING + BS + ExtractFileName(gsave_file_glb_str);
      for j := 0 to aStringList.Count - 1 do
      begin
        // Search log for Warnings
        if POS('WARNING', aStringList[j]) > 0 then
        begin
          if ForceDirectories(FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_WARNING) and DirectoryExists(FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_WARNING) then // Do not use OSFILENAME for network folders
            aStringList.SaveToFile(tmp_str)
          else
          begin
            ConsoleLog(RPad('Warning in log:', rpad_value) + 'True');
            ConsoleLog(RPad('Did not locate:', rpad_value) + FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_WARNING);
          end;
          break;
        end;
      end;

      // Save to Errors
      tmp_str := FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_ERROR + ExtractFileName(gsave_file_glb_str);
      for j := 0 to aStringList.Count - 1 do
      begin
        // Search log for Errors
        if POS('ERROR IN LOG', aStringList[j]) > 0 then // noslz
        begin
          if ForceDirectories(FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_ERROR) and DirectoryExists(FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_ERROR) then // Do not use OSFILENAME for network folders
            aStringList.SaveToFile(tmp_str)
          else
          begin
            ConsoleLog(RPad('Error in log:', rpad_value) + 'True');
            ConsoleLog(RPad('Did not locate:', rpad_value) + FLDR_GLB + BS + FLDR_VALIDATION + BS + FLDR_ERROR);
          end;
          break;
        end;
      end;

    end
    else
      ConsoleLog(RPad('Did not locate:', rpad_value) + gsave_file_glb_str);
  end;

  // Save Result to local folder
  gsave_file_loc_str := CreateFileName(FLDR_LOC);
  ConsoleLog(RPad('Save to:', rpad_value) + gsave_file_loc_str);
  if ForceDirectories(OSFILENAME + ExtractFileDir(gsave_file_loc_str)) and DirectoryExists(ExtractFileDir(gsave_file_loc_str)) then
    Save_StringList_To_File(aStringList, gsave_file_loc_str);
  Sleep(500);
  if not FileExists(gsave_file_loc_str) then
    ConsoleLog(RPad('Error saving:', rpad_value) + gsave_file_loc_str);
end;

// ------------------------------------------------------------------------------
// Function: Starting Checks
// ------------------------------------------------------------------------------
function StartingChecks: boolean;
var
  StartCheckDataStore: TDataStore;
  StartCheckEntry: TEntry;
begin
  Result := False;
  Progress.DisplayTitle := SCRIPT_NAME;
  StartCheckDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  if not assigned(StartCheckDataStore) then
  begin
    ConsoleLog(DATASTORE_FILESYSTEM + ' module not located.' + SPACE + TSWT);
    Exit;
  end;
  try
    StartCheckEntry := StartCheckDataStore.First;
    if not assigned(StartCheckEntry) then
    begin
      ConsoleLog('There is no current case.' + SPACE + TSWT); // noslz
      MessageUsr('There is no current case.' + DCR + TSWT);
      Exit;
    end
    else
      gcase_name := StartCheckEntry.EntryName;
    if StartCheckDataStore.Count <= 1 then
    begin
      ConsoleLog('There are no files in the File System module.' + SPACE + TSWT); // noslz
      MessageUsr('There are no files in the File System module.');
      Exit;
    end;
    Result := True; // If this point is reached StartCheck is True
  finally
    StartCheckDataStore.free;
  end;
end;

// ==============================================================================================================================================
// Start of the Script
// ==============================================================================================================================================
var
  AllFiles_TList: TList;
  anEntry: TEntry;
  DataStore_FS: TDataStore;
  FTK_Output_StringList: TStringList;
  i: integer;
  Pictures_zip_Children_TList: TList;
  Pictures_zip_TList: TList;
  start_tick_begining: uint64;

begin
  bl_Continue := True;
  gbl_BM_Signature_Status := False;
  gbl_EM_Hash_Status := False;
  gbl_EM_Signature_Status := False;
  gbl_FS_Hash_Status := False;
  gbl_FS_Signature_Status := False;
  gbl_open_folder := True;
  gbl_RG_Hash_Status := False;
  gbl_RG_Signature_Status := False;
  gbl_SkinToneRunGraphics := False;
  gbl_SkinToneRunVideo := False;
  gCompare_with_external_bl := False;
  max_sig_analysis_duration := 0;
  Progress.DisplayTitle := SCRIPT_NAME;
  rpad_value := 50;
  rpad_value2 := 42;
  ScriptPath_str := CmdLine.Path;
  SetLength(array_of_string, 6);
  start_tick_begining := GetTickCount64;

  LoadFileItems;

  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := ('Processing complete.');
    Exit;
  end;

  gMemo_StringList := TStringList.Create;
  try
    log_parameters_received;

    if (CmdLine.Params.Indexof('OPEN_TXT_FOLDER') > -1) and (DirectoryExists(FLDR_LOC + BS + gTheCurrentDevice)) then // noslz
    begin
      OpenFolder(FLDR_LOC + BS + gTheCurrentDevice);
      Exit;
    end;

    // Create Lists
    FileSystemEntryList := GetDataStore(DATASTORE_FILESYSTEM);
    if not assigned(FileSystemEntryList) then
      Exit;

    // Set the TXT full path (after getting the device name)
    gDeviceName_str := GetDevices;
    if gDeviceName_str = '' then
    begin
      MessageUsr('Device Name is blank.' + SPACE + TSWT); // noslz
      FileSystemEntryList.free;
      Exit;
    end;

    // Print keywords
    if (Item^.expected_KW_keyword1 <> '') and (Item^.expected_KW_keyword1_regex <> '') then
    begin
      ConsoleLog('Keywords (item ' + IntToStr(gitem_int) + ')'); // noslz
      ConsoleLog(Item^.expected_KW_keyword1);
      ConsoleLog(Item^.expected_KW_keyword2);
      ConsoleLog(Item^.expected_KW_keyword1_regex + ',' + Item^.expected_KW_keyword1_regex + ',RegEx,-'); // noslz
      ConsoleLog(stringofchar('-', CHAR_LENGTH));
    end;

    SetFieldNames;

    If (CmdLine.Params.Indexof('COMPARE_TO_EXTERNAL_FILE') > -1) then // noslz
    begin
      gCompare_TXT := FLDR_LOC + BS + gTheCurrentDevice + BS + 'FILE_SYSTEM' + BS + CmdLine.Params[1]; // noslz
      if not TestExternalCompareFile then
      begin
        FileSystemEntryList.free;
        Exit;
      end;
    end;

    if (CmdLine.Params.Indexof('PARAM_CREATE_KEYWORDSEARCH_TXT') > -1) then // noslz
    begin
      CreateTXTFile('Keyword_Search');
      FileSystemEntryList.free;
      Exit;
    end;

    if (CmdLine.Params.Indexof('PARAM_CREATE_EMAIL_TXT') > -1) then // noslz
    begin
      CreateTXTFile('Email');
      FileSystemEntryList.free;
      Exit;
    end;

    if (CmdLine.Params.Indexof('PARAM_CREATE_TXT') > -1) then // noslz
    begin
      CreateTXTFile('File_System'); // noslz
      FileSystemEntryList.free;
      Exit;
    end;

    if (CmdLine.Params.Indexof('PARAM_CREATE_BM_TXT') > -1) then // noslz
    begin
      gbl_bmonly := True;
      CreateTXTFile('File_System'); // noslz
      FileSystemEntryList.free;
      Exit;
    end;

    // ----------------------------------------------------------------------------
    // FTK Imager Hash Compare
    // ----------------------------------------------------------------------------
    FTK_Output_StringList := TStringList.Create;
    try
      FTK_Output_StringList.text := Item^.ftk_imager_output_str;
      Process_FTK_Results(FTK_Output_StringList);
    finally
      FTK_Output_StringList.free;
    end;

    ArtifactsEntryList := GetDataStore(DATASTORE_ARTIFACTS);
    EmailEntryList := GetDataStore(DATASTORE_EMAIL);
    RegistryEntryList := GetDataStore(DATASTORE_REGISTRY);
    VolumeID_StringList := TStringList.Create;
    try
      FieldName := 'REGDATA';
      KeyData_Field := RegistryEntryList.DataFields.FieldByName[FieldName];

      Sig_And_Hash_Check('File System');
      Sig_And_Hash_Check('Email');
      Sig_And_Hash_Check('Registry');

      ConsoleLog(array_of_string[0]);
      ConsoleLog(array_of_string[2]);
      ConsoleLog(array_of_string[4]);
      ConsoleLog(stringofchar('-', CHAR_LENGTH));
      ConsoleLog(array_of_string[1]);
      ConsoleLog(array_of_string[3]);
      ConsoleLog(array_of_string[5]);
      ConsoleLog(stringofchar('-', CHAR_LENGTH));

      if (FileSystemEntryList.Count > 1) then
        SignatureAnalysis('File System');
      if (EmailEntryList.Count > 1) then
        SignatureAnalysis('Email');
      if (RegistryEntryList.Count > 1) then
        SignatureAnalysis('Registry');

    finally
      ArtifactsEntryList.free;
      BookmarksEntryList.free;
      EmailEntryList.free;
      FileSystemEntryList.free;
      RegistryEntryList.free;
    end;

    if (Item^.Device_Logical_Size = 80026361856) or (Item^.Device_Logical_Size = 80026361856) then
    begin
      Pictures_zip_TList := TList.Create;
      try
        GetPicturesZip_TList(Pictures_zip_TList);
        if assigned(Pictures_zip_TList) and (Pictures_zip_TList.Count = 1) then
        begin
          HashFiles(Pictures_zip_TList, '1024');
          anEntry := TEntry(Pictures_zip_TList[0]);
          actual_pictures_zip_md5 := Field_MD5.AsString[anEntry];
          if actual_pictures_zip_md5 = '' then
            actual_pictures_zip_md5 := RS_NOT_RUN;
          ExpandCompoundfile(anEntry, DATASTORE_FILESYSTEM);
          Sleep(1000);
        end;
      finally
        FreeAndNil(Pictures_zip_Children_TList);
      end;

      Pictures_zip_TList := TList.Create;
      DataStore_FS := GetDataStore(DATASTORE_FILESYSTEM);
      try
        GetPicturesZip_TList(Pictures_zip_TList);
        if assigned(Pictures_zip_TList) and (Pictures_zip_TList.Count = 1) then
        begin
          anEntry := TEntry(Pictures_zip_TList[0]);
          Pictures_zip_Children_TList := TList.Create;
          Pictures_zip_Children_TList := DataStore_FS.Children(anEntry, True);
          actual_pictures_zip_count := Pictures_zip_Children_TList.Count;
          for i := 0 to Pictures_zip_Children_TList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            actual_sum_pictures_zip_size := actual_sum_pictures_zip_size + TEntry(Pictures_zip_Children_TList[i]).LogicalSize;
          end;
        end;
      finally
        FreeAndNil(Pictures_zip_Children_TList);
        FreeAndNil(DataStore_FS);
      end;
    end;

    // ----------------------------------------------------------------------------
    // Get a fresh copy of the Datastores to do the count
    // ----------------------------------------------------------------------------
    ArtifactsEntryList := GetDataStore(DATASTORE_ARTIFACTS);
    BookmarksEntryList := GetDataStore(DATASTORE_BOOKMARKS);
    EmailEntryList := GetDataStore(DATASTORE_EMAIL);
    FileSystemEntryList := GetDataStore(DATASTORE_FILESYSTEM);
    KeywordSearchEntryList := GetDataStore(DATASTORE_KEYWORDSEARCH);
    RegistryEntryList := GetDataStore(DATASTORE_REGISTRY);
    AllFiles_TList := FileSystemEntryList.GetEntireList;
    try
      // ----------------------------------------------------------------------------
      // Other Processing
      // ----------------------------------------------------------------------------
      VolumeID;
      CountTheFiles('File System', FileSystemEntryList);
      CountTheFiles('Artifacts', ArtifactsEntryList);
      CountTheFiles('Bookmarks', FileSystemEntryList);
      CountTheFiles('Email', EmailEntryList);
      CountTheFiles('Keyword Search', KeywordSearchEntryList);
      CountTheFiles('Registry', RegistryEntryList);

      if gCompare_with_external_bl then
      begin
        if (gbl_FS_Hash_Status = False) then
          HashFiles(AllFiles_TList, '1024');
        ReadExternalFile;
      end;

    finally
      AllFiles_TList.free;
      ArtifactsEntryList.free;
      BookmarksEntryList.free;
      EmailEntryList.free;
      FileSystemEntryList.free;
      KeywordSearchEntryList.free;
      RegistryEntryList.free;
      VolumeID_StringList.free;
    end;

    count_of_Triage_in_Bookmarks_folder;

    if (not bl_Continue) or (not Progress.isRunning) then
    begin
      ConsoleLog(SCRIPT_NAME + ' canceled by user.'); // noslz
      Exit;
    end
    else
      ConsoleLog(stringofchar('-', CHAR_LENGTH));

    CheckLogFiles;

    CalcTimeTaken(start_tick_begining, '');
    ConsoleLog(RPad(SCRIPT_NAME, rpad_value) + 'Finished.');
    ConsoleLog(stringofchar('-', CHAR_LENGTH));

    SaveResult(gMemo_StringList);
    CreateRunTimeTXT(gMemo_StringList, CurrentVersion + '_' + gDeviceName_str + '_Validation_' + RUNAS_STR + '.txt'); // Saves to case Reports folder

  finally
    gMemo_StringList.free;
  end;
  Progress.Log(SCRIPT_NAME + ' end.');

end.
