unit Artifacts_Mobile;

interface

uses
{$IF DEFINED (ISFEXGUI)}
  GUI, Modules,
{$IFEND}
  ByteStream, Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DateUtils, DIRegex,
  Graphics, PropertyList, ProtoBuf, Regex, SQLite3, SysUtils, Variants,
  //-----
  Artifact_Utils      in 'Common\Artifact_Utils.pas',
  Columns             in 'Common\Column_Arrays\Columns.pas',
  Icon_List           in 'Common\Icon_List.pas',
  Itunes_Backup_Sig   in 'Common\Itunes_Backup_Signature_Analysis.pas',
  Phone_MMC_DB        in 'Common\Phone_MMC_DB.pas',
  RS_DoNotTranslate   in 'Common\RS_DoNotTranslate.pas',
  //-----
  Accounts             in 'Common\Column_Arrays\Accounts.pas',
  AndroidLogs          in 'Common\Column_Arrays\Androidlogs.pas',
  AppleMaps            in 'Common\Column_Arrays\AppleMaps.pas',
  ApplicationState_IOS in 'Common\Column_Arrays\ApplicationState_IOS.pas',
  Aquamail             in 'Common\Column_Arrays\Aquamail.pas',
  Bluetooth            in 'Common\Column_Arrays\Bluetooth.pas',
  CachedLocations      in 'Common\Column_Arrays\CachedLocations.pas',
  Calendar             in 'Common\Column_Arrays\Calendar.pas',
  Calls                in 'Common\Column_Arrays\Calls.pas',
  CellTowerLocations   in 'Common\Column_Arrays\CellTowerLocations.pas',
  Contacts             in 'Common\Column_Arrays\Contacts.pas',
  Dropbox              in 'Common\Column_Arrays\Dropbox.pas',
  DynamicDictionary    in 'Common\Column_Arrays\DynamicDictionary.pas',
  Email                in 'Common\Column_Arrays\Email.pas',
  External_db_Android  in 'Common\Column_Arrays\External_db_Android.pas',
  Gmail                in 'Common\Column_Arrays\Gmail.pas',
  Googlemaps           in 'Common\Column_Arrays\Googlemaps.pas',
  Googlemobile         in 'Common\Column_Arrays\Googlemobile.pas',
  Google_Play          in 'Common\Column_Arrays\Google_Play.pas',
  Installed_Apps       in 'Common\Column_Arrays\Installed_Apps.pas',
  Internal_db_Android  in 'Common\Column_Arrays\Internal_db_Android.pas',
  Itunes               in 'Common\Column_Arrays\Itunes.pas',
  Maps                 in 'Common\Column_Arrays\Maps.pas',
  Notes                in 'Common\Column_Arrays\Notes.pas',
  ParkedCarLocations   in 'Common\Column_Arrays\ParkedCarLocations.pas',
  Picasa               in 'Common\Column_Arrays\Picasa.pas',
  Photos_sqlite_IOS    in 'Common\Column_Arrays\Photos_sqlite_IOS.pas',
  Private_Photo_Vault  in 'Common\Column_Arrays\Private_Photo_Vault.pas',
  ScreenTimeAppUsage   in 'Common\Column_Arrays\ScreenTimeAppUsage.pas',
  SignificantLocations in 'Common\Column_Arrays\SignificantLocations.pas',
  SMS                  in 'Common\Column_Arrays\SMS.pas',
  Uber                 in 'Common\Column_Arrays\Uber.pas',
  UserDictionary       in 'Common\Column_Arrays\UserDictionary.pas',
  Voicemail            in 'Common\Column_Arrays\Voicemail.pas',
  Voicememos           in 'Common\Column_Arrays\Voicememos.pas',
  Wifi                 in 'Common\Column_Arrays\Wifi.pas',
  WifiLocations        in 'Common\Column_Arrays\WifiLocations.pas';

type
  TVarArray = array of variant;
  TDataStoreFieldArray = array of TDataStoreField;
  PSQL_FileSearch = ^TSQL_FileSearch;

  TSQL_FileSearch = record
    fi_Carve_Header               : string;
    fi_Carve_Footer               : string;
    fi_Carve_Adjustment           : integer;
    fi_Icon_Category              : integer;
    fi_Icon_Program               : integer;
    fi_Icon_OS                    : integer;
    fi_Regex_Itunes_Backup_Domain : string;
    fi_Regex_Itunes_Backup_Name   : string;
    fi_Name_Program               : string;
    fi_Name_Program_Type          : string;
    fi_Name_OS                    : string;
    fi_NodeByName                 : string;
    fi_Process_As                 : string;
    fi_Process_ID                 : string;
    fi_Reference_Info             : string;
    fi_Regex_Search               : string;
    fi_RootNodeName               : string;
    fi_Signature_Parent           : string;
    fi_Signature_Sub              : string;
    fi_SQLStatement               : string;
    fi_SQLTables_Required         : array of string;
    fi_SQLPrimary_Tablestr        : string;
    fi_Test_Data                  : string;
  end;

const
  ATRY_EXCEPT_STR           = 'TryExcept: '; //noslz
  ANDROID                   = 'Android'; //noslz
  BS                        = '\';
  BL_PROCEED_LOGGING        = False;
  CANCELED_BY_USER          = 'Canceled by user.';
  CATEGORY_NAME             = 'Mobile';
  CHAR_LENGTH               = 80;
  COLON                     = ':';
  COMMA                     = ',';
  CR                        = #13#10;
  DCR                       = #13#10 + #13#10;
  DUP_FILE                  = '( \d*)?$';
  FBN_ITUNES_BACKUP_DOMAIN  = 'iTunes Backup Domain'; //noslz
  FBN_ITUNES_BACKUP_NAME    = 'iTunes Backup Name'; //noslz
  GFORMAT_STR               = '%-1s %-12s %-8s %-15s %-25s %-30s %-20s';
  GROUP_NAME                = 'Artifact Analysis';
  HYPHEN                    = ' - ';
  HYPHEN_NS                 = '-';
  IOS                       = 'iOS'; //noslz
  MAX_CARVE_SIZE            = 1024 * 10;
  MIN_CARVE_SIZE            = 0;
  NUMBEROFSEARCHITEMS       = 61; //********************************************
  PHOTOS_SQLITE             = 'Photos.Sqlite'; //noslz
  PROCESS_AS_BYTES_STRLST   = 'PROCESS_AS_BYTES_STRLST';
  PROCESS_AS_CARVE          = 'PROCESSASCARVE'; //noslz
  PROCESS_AS_PLIST          = 'PROCESSASPLIST'; //noslz
  PROCESS_AS_XML            = 'PROCESSASXML'; //noslz
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'Mobile';
  RPAD_VALUE                = 55;
  RUNNING                   = '...';
  SCRIPT_DESCRIPTION        = 'Extract Mobile Artifacts';
  SCRIPT_NAME               = 'Mobile.pas';
  SPACE                     = ' ';
  STR_FILES_BY_PATH         = 'Files by path';
  TSWT                      = 'The script will terminate.';
  USE_FLAGS_BL              = False;
  VERBOSE                   = False;
  WINDOWS                   = 'Windows'; //noslz

var
  Arr_ValidatedFiles_TList:       array[1..NUMBEROFSEARCHITEMS] of TList;
  ArtifactConnect_ProgramFolder:  array[1..NUMBEROFSEARCHITEMS] of TArtifactConnectEntry;
  FileItems:                      array[1..NUMBEROFSEARCHITEMS] of PSQL_FileSearch;

  anEntry:                        TEntry;
  ArtifactConnect_CategoryFolder: TArtifactEntry1;
  ArtifactsDataStore:             TDataStore;
  c, n, r:                        integer;
  col_source_created:             TDataStoreField;
  col_source_file:                TDataStoreField;
  //col_source_location:          TDataStoreField;
  col_source_modified:            TDataStoreField;
  col_source_path:                TDataStoreField;
  current_str:                    string;
  Display_str:                    string;
  FileSystemDataStore:            TDataStore;
  gtick_doprocess_i64:            uint64;
  gtick_doprocess_str:            string;
  gtick_foundlist_i64:            uint64;
  gtick_foundlist_str:            string;
  mb_display_str:                 string;
  param:                          string;
  Parameter_Num_StringList:       TStringList;
  previous_str:                   string;
  process_all_bl:                 boolean;
  process_proceed_bl:             boolean;
  Program_Folder_int:             integer;
  progress_program_str:           string;
  Ref_Num:                        integer;
  regex_search_str:               string;
  s:                              integer;
  temp_int:                       integer;
  temp_process_counter:           integer;
  test_param_int:                 integer;

function ColumnValueByNameAsDateTime(Statement: TSQLite3Statement; const colConf: TSQL_Table): TDateTime;
function FileSubSignatureMatch(anEntry: TEntry): boolean;
function GetFullName(Item: PSQL_FileSearch): string;
function HaveIBeenProcessed(SigMatchEntry: TEntry; const a_fldr: string; const b_fldr: string): boolean;
function KeepItems(anEntry: TEntry): boolean;
function LengthArrayTABLE(anArray: TSQL_Table_array): integer;
function RPad(const AString: string; AChars: integer): string;
function SetUpColumnforFolder(aReferenceNumber: integer; anArtifactFolder: TArtifactConnectEntry; out col_DF: TDataStoreFieldArray; ColCount: integer; aItems: TSQL_Table_array): boolean;
function TestForDoProcess(ARefNum: integer): boolean;
function TotalValidatedFileCountInTLists: integer;
procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
procedure DoProcess(anArtifactFolder: TArtifactConnectEntry; Reference_Number: integer; aItems: TSQL_Table_array);
procedure LoadFileItems;

{$IF DEFINED (ISFEXGUI)}

type
  TScriptForm = class(TObject)
  private
    frmMain: TGUIForm;
    FMemo: TGUIMemoBox;
    pnlBottom: TGUIPanel;
    btnOK: TGUIButton;
    btnCancel: TGUIButton;
  public
    ModalResult: boolean;
    constructor Create;
    function ShowModal: boolean;
    procedure OKClick(Sender: TGUIControl);
    procedure CancelClick(Sender: TGUIControl);
    procedure SetText(const Value: string);
    procedure SetCaption(const Value: string);
  end;
{$IFEND}

implementation

{$IF DEFINED (ISFEXGUI)}

constructor TScriptForm.Create;
begin
  inherited Create;
  frmMain := NewForm(nil, SCRIPT_NAME);
  frmMain.Size(500, 480);
  pnlBottom := NewPanel(frmMain, esNone);
  pnlBottom.Size(frmMain.Width, 40);
  pnlBottom.Align(caBottom);
  btnOK := NewButton(pnlBottom, 'OK');
  btnOK.Position(pnlBottom.Width - 170, 4);
  btnOK.Size(75, 25);
  btnOK.Anchor(False, True, True, True);
  btnOK.DefaultBtn := True;
  btnOK.OnClick := OKClick;
  btnCancel := NewButton(pnlBottom, 'Cancel');
  btnCancel.Position(pnlBottom.Width - 88, 4);
  btnCancel.Size(75, 25);
  btnCancel.Anchor(False, True, True, True);
  btnCancel.CancelBtn := True;
  btnCancel.OnClick := CancelClick;
  FMemo := NewMemoBox(frmMain, [eoReadOnly]); // eoNoHScroll, eoNoVScroll
  FMemo.Color := clWhite;
  FMemo.Align(caClient);
  FMemo.FontName('Courier New');
  frmMain.CenterOnParent;
  frmMain.Invalidate;
end;

procedure TScriptForm.OKClick(Sender: TGUIControl);
begin
  // Set variables for use in the main proc. Must do this before closing the main form.
  ModalResult := False;
  ModalResult := True;
  frmMain.Close;
end;

procedure TScriptForm.CancelClick(Sender: TGUIControl);
begin
  ModalResult := False;
  Progress.DisplayMessageNow := CANCELED_BY_USER;
  frmMain.Close;
end;

function TScriptForm.ShowModal: boolean;
begin
  Execute(frmMain);
  Result := ModalResult;
end;

procedure TScriptForm.SetText(const Value: string);
begin
  FMemo.Text := Value;
end;

procedure TScriptForm.SetCaption(const Value: string);
begin
  frmMain.Text := Value;
end;
{$IFEND}

procedure LoadFileItems;
const
  lFileItems: array[1..NUMBEROFSEARCHITEMS] of TSQL_FileSearch = (
    ( // ~1~ Accounts - Android
    fi_Name_Program:               'Accounts';
    fi_Name_Program_Type:          '';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_ANDROID;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'Accounts_ce\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ACCOUNTS', 'ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ACCOUNTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM ACCOUNTS'; //noslz
    fi_Test_Data:                  ''),

    ( // ~2~ Accounts - Type - iOS
    fi_Name_Program:               'Accounts';
    fi_Name_Program_Type:          'Type';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_ACCOUNT;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'Accounts3\.sqlite' + DUP_FILE + '|^943624fd13e27b800cc6d9ce1100c22356ee365c' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'HomeDomain';
    fi_Regex_Itunes_Backup_Name:   'Library\/Accounts\/Accounts3\.sqlite';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZACCOUNTTYPE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZACCOUNTTYPE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZACCOUNTTYPE'; //noslz
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~3~ Apple Maps - Searches - iOS
    fi_Name_Program:               'Apple Maps';
    fi_Name_Program_Type:          'Searches';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1208;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'MapsSync_0.0.1' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZHISTORYITEM','ZMIXINMAPITEM']; //noslz
    fi_SQLPrimary_Tablestr:        'ZHISTORYITEM'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZHISTORYITEM'; //noslz
    fi_Test_Data:                  'Digital Corpa 15'),

    ( // ~4~ Application - State - iOS
    fi_Name_Program:               'Application';
    fi_Name_Program_Type:          'State';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               10;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'ApplicationState\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['APPLICATION_IDENTIFIER_TAB','KEY_TAB','KVS']; //noslz
    fi_SQLPrimary_Tablestr:        'APPLICATION_IDENTIFIER_TAB'; //noslz
    fi_SQLStatement:               'SELECT * FROM APPLICATION_IDENTIFIER_TAB'; //noslz
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~5~ Aqua Mail - Email - Android
    fi_Name_Program:               'Aqua Mail';
    fi_Name_Program_Type:          'Email';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_BROWSERS;
    fi_Icon_Program:               ICON_AQUAMAIL;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^Messages\.sqldb' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~6~ BlueTooth - Devices - iOS
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_BLUETOOTH_DEVICES';
    fi_Name_Program:               'Bluetooth';
    fi_Name_Program_Type:          'Devices';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_BLUETOOTH;
    fi_Icon_OS:                    ICON_ITUNES;
    fi_Regex_Search:               'com\.apple\.MobileBluetooth\.devices\.plist' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY;
    fi_NodeByName:                 'PList (Binary)'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~7~ BlueTooth - Seen Devices - iOS
    fi_Name_Program:               'Bluetooth';
    fi_Name_Program_Type:          'Seen Devices';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_BROWSERS;
    fi_Icon_Program:               ICON_BLUETOOTH;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^com\.apple\.MobileBluetooth\.ledevices\.other\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['OTHERDEVICES']; //noslz
    fi_SQLPrimary_Tablestr:        'OTHERDEVICES'; //noslz
    fi_SQLStatement:               'SELECT * FROM OTHERDEVICES'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~8~ Cached - Locations - iOS
    fi_Name_Program:               'Cached';
    fi_Name_Program_Type:          'Locations';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1171;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'com\.apple\.routined\\Cache\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZRTCLLOCATIONMO','ZRTADDRESSMO','ZRTDEVICEMO']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRTCLLOCATIONMO'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZRTCLLOCATIONMO'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~9~ Calendar - Items - Android
    fi_Name_Program:               'Calendar';
    fi_Name_Program_Type:          'Items';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_CALENDAR;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^calendar\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['EVENTS']; //noslz
    fi_SQLPrimary_Tablestr:        'EVENTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM EVENTS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~10~ Calendar - iOS v3 - iOS
    fi_Name_Program:               'Calendar';
    fi_Name_Program_Type:          'Items v3';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_CALENDAR;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'Calendar.*\.sqlitedb' + DUP_FILE + '|^2041457d5fe04d39d0ab481178355df6781e6858' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_CALENDAR_IOS;
    fi_SQLTables_Required:         ['EVENT','CALENDARCHANGES','ALARM']; //noslz
    fi_SQLPrimary_Tablestr:        'EVENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM EVENT'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~11~ Calendar - Items v4 - iOS
    fi_Name_Program:               'Calendar';
    fi_Name_Program_Type:          'Items v4';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_CALENDAR;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'Calendar.*\.sqlitedb' + DUP_FILE + '|^2041457d5fe04d39d0ab481178355df6781e6858' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_CALENDAR_IOS;
    fi_SQLTables_Required:         ['CALENDARITEM','CALENDARCHANGES','ALARM']; //noslz
    fi_SQLPrimary_Tablestr:        'CALENDARITEM'; //noslz
    fi_SQLStatement:               'SELECT * FROM CALENDARITEM'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~12~ Call - Logs - Android
    fi_Name_Program:               'Call';
    fi_Name_Program_Type:          'Logs';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_CALLS;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^logs\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['LOGS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'LOGS'; //noslz
    fi_SQLStatement:               'SELECT * FROM LOGS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~13~ Call - History - iOS {iOS3to13}
    fi_Name_Program:               'Call';
    fi_Name_Program_Type:          'History';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_CALLS;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'call_history\.db' + DUP_FILE + '|2b2b0084a1bc3a5ac8c27afdf14afb42c61a19ca' + DUP_FILE + '|ff1324e6b949111b2fb449ecddb50c89c3699a78' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['CALL']; //noslz
    fi_SQLPrimary_Tablestr:        'CALL'; //noslz
    fi_SQLStatement:               'SELECT * FROM CALL'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~14~ Call - History - iOS {iOS14}
    fi_Name_Program:               'Call';
    fi_Name_Program_Type:          'History';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_CALLS;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'callhistory\.storedata\.*|5a4935c78a5255723f707230a451d79c540d2741' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['ZCALLRECORD']; //noslz
    fi_SQLPrimary_Tablestr:        'ZCALLRECORD'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZCALLRECORD'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~15~ Cell Tower - Locations - iOS
    fi_Name_Program:               'Cell Tower';
    fi_Name_Program_Type:          'Locations';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1170;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'cache_encryptedB\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['LTECELLLOCATION','LTECELLLOCATIONCOUNTS']; //noslz
    fi_SQLPrimary_Tablestr:        'LTECELLLOCATION'; //noslz
    fi_SQLStatement:               'SELECT * FROM LTECELLLOCATION'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~16~ Contacts - Details - Android (Contacts3.db)
    fi_Name_Program:               'Contacts';
    fi_Name_Program_Type:          'Details';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               454;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'contacts3\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['ACQUIRED_CONTACTS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ACQUIRED_CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM ACQUIRED_CONTACTS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~17~ Contacts - Manager - Android (contactsManager.db)
    fi_Name_Program:               'Contacts';
    fi_Name_Program_Type:          'Manager';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               454;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'contactsManager\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['DATA', 'ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'DATA'; //noslz
    fi_SQLStatement:               'SELECT * FROM DATA'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~18~ Contacts - Details - iOS
    fi_Name_Program:               'Contacts';
    fi_Name_Program_Type:          'Details';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               454;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'AddressBook\.sqlitedb' + DUP_FILE + '|^31bb7ba8914766d4ba40d6dfb6113c8b614be442' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_CONTACTS_IOS;
    fi_SQLTables_Required:         ['ABPERSON','ABGROUP']; //noslz
    fi_SQLPrimary_Tablestr:        'ABPERSON'; //noslz
    fi_SQLStatement:               'SELECT p.*, '+
                                   ' CASE when m.label in (select rowid from abmultivaluelabel)'+
                                   ' THEN (select value from abmultivaluelabel'+
                                   ' WHERE m.label = rowid)'+
                                   ' else m.label end as Type, m.value'+
                                   ' FROM abperson p,'+
                                   ' abmultivalue m'+
                                   ' WHERE p.rowid=m.record_id and m.value not null'+
                                   ' order by p.rowid';
    fi_Reference_Info:             'http://linuxsleuthing.blogspot.com.au/2012/10/addressing-ios6-address-book-and-sqlite.html' +
                                   'https://plus.google.com/u/0/+JohnLehr/posts';
    fi_Test_Data:                  ''), //noslz

    ( // ~19~ Contacts - (Recents Table) - iOS
    fi_Name_Program:               'Contacts';
    fi_Name_Program_Type:          '(Recents Table)';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_RECENT;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^75b12106910f0b106f64d72eb75397427884fd5a' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'HomeDomain';
    fi_Regex_Itunes_Backup_Name:   'Library\/Mail\/Recents';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['RECENTS, CONTACTS']; //noslz
    fi_SQLPrimary_Tablestr:        'RECENTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM RECENTS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~20~ Contacts - (Contacts Table) - iOS
    fi_Name_Program:               'Contacts';
    fi_Name_Program_Type:          '(Contacts Table)';
    fi_Name_OS:                    'iOS';
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_RECENT;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^75b12106910f0b106f64d72eb75397427884fd5a' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'HomeDomain';
    fi_Regex_Itunes_Backup_Name:   'Library\/Mail\/Recents';
    fi_Signature_Parent:           'SQLite';
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['CONTACTS', 'RECENTS']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONTACTS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~21~ Dropbox - Metadata Cache - iOS
    fi_Name_Program:               'Dropbox';
    fi_Name_Program_Type:          'Metadata Cache';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_DROPBOX;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '';
    fi_Regex_Itunes_Backup_Domain: 'AppDomain-com.getdropbox.Dropbox';
    fi_Regex_Itunes_Backup_Name:   '^Library\/Application Support\/Dropbox\/.*?\/Files\/cache\.db';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['METADATA_CACHE','ALL_PHOTOS']; //noslz
    fi_SQLPrimary_Tablestr:        'METADATA_CACHE'; //noslz
    fi_SQLStatement:               'SELECT * FROM METADATA_CACHE'; //noslz
    fi_Test_Data:                  ''),

    ( // ~22~ Dropbox - Spotlight Items - iOS
    fi_Name_Program:               'Dropbox';
    fi_Name_Program_Type:          'Spotlight Items';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_DROPBOX;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'spotlight\.db' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'AppDomain-com.getdropbox.Dropbox';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/spotlight\.db';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['SPOTLIGHT_ITEMS']; //noslz
    fi_SQLPrimary_Tablestr:        'SPOTLIGHT_ITEMS'; //noslz
    fi_SQLStatement:               'SELECT * FROM SPOTLIGHT_ITEMS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~23~ Dynamic - Dictionary - iOS
    fi_Process_As:                 PROCESS_AS_BYTES_STRLST;
    fi_Process_ID:                 'DNT_DYNAMIC_DICTIONARY';
    fi_Name_Program:               'Dynamic';
    fi_Name_Program_Type:          'Dictionary';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_DICTIONARY;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '0df474a536db7908bb69cc9b430b94a871ae7752' + DUP_FILE + '|0b68edc697a550c9b977b77cd012fa9a0557dfcb(\.mddata)?( \d*)?$' + DUP_FILE + '|347f791ac895becaa14b58c07ba645d416c21215' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_DYNAMIC_DICTIONARY;
    fi_Signature_Sub:              ''; //noslz
    fi_Test_Data:                  'MTH'), //noslz

    ( // ~24~ Email - Messages - Android
    fi_Name_Program:               'Email';
    fi_Name_Program_Type:          'Message';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_EMAIL;
    fi_Icon_OS:                    ICON_EMAIL;
    fi_Regex_Search:               '^EmailProvider\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'; //noslz
    fi_Reference_info:             'https://www.magnetforensics.com/mobile-forensics/webmail-forensics-part-2-android-and-ios/'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~25~ GMail - Message - Android
    fi_Name_Program:               'GMail';
    fi_Name_Program_Type:          'Message';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_GMAIL;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^mailstore\..*@gmail.com\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM messages'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~26~ Google Maps Saved Places - Android
    fi_Name_Program:               'Google Maps';
    fi_Name_Program_Type:          'Saved Places';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_GOOGLEMAPS;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^gmm_myplaces\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['SYNC_ITEM']; //noslz
    fi_SQLPrimary_Tablestr:        'SYNC_ITEM'; //noslz
    fi_SQLStatement:               'SELECT * FROM sync_item'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~27~ Google - Maps - iOS{7}
    fi_Process_As:                 PROCESS_AS_CARVE;
    fi_Process_ID:                 'DNT_GOOGLE_MAPS';
    fi_Name_Program:               'Google';
    fi_Name_Program_Type:          'Maps';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_GOOGLEMAPS;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'History\.mapsdata' + DUP_FILE + '|^1321e6b74c9dfe411e7e129d6a8ae7cc645af9d0' + DUP_FILE;
    fi_Carve_Header:               '\xAB\xA4\x4B\xB9\x41'; //noslz
    fi_Carve_Footer:               '\xAB\xA4\x4B\xB9\x41'; //noslz
    fi_Carve_Adjustment:           5;
    fi_Test_Data:                  'MTH'), //noslz

    ( // ~28~ Google Mobile - iOS
    fi_Name_Program:               'Google Mobile';
    fi_Name_Program_Type:          'Search History';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_BROWSERS;
    fi_Icon_Program:               ICON_GOOGLE;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'searchhistory\.db' + DUP_FILE + '|^19cb8d89a179d13e45320f9f3965c7ea7454b10d' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'AppDomain-com\.google\.GoogleMobile';
    fi_Regex_Itunes_Backup_Name:   'Library\/GoogleMobile\/searchhistory\.db';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['SEARCH_HISTORY']; //noslz - Use Search History Only.
    fi_SQLPrimary_Tablestr:        'SEARCH_HISTORY';  //noslz
    fi_SQLStatement:               'SELECT * FROM SEARCH_HISTORY'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~29~ Google Play Installed Applications - Android
    fi_Name_Program:               'Google Play';
    fi_Name_Program_Type:          'Installed Applications';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              1205;
    fi_Icon_Program:               1205;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^library\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['OWNERSHIP', 'ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'OWNERSHIP';  //noslz
    fi_SQLStatement:               'SELECT * FROM OWNERSHIP'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~30~ Installed Apps - iOS
    fi_Name_Program:               'Installed';
    fi_Name_Program_Type:          'Applications';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              10;
    fi_Icon_Program:               10;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'applicationState\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['APPLICATION_IDENTIFIER_TAB','KEY_TAB']; //noslz - Use Search History Only.
    fi_SQLPrimary_Tablestr:        'APPLICATION_IDENTIFIER_TAB';  //noslz
    fi_SQLStatement:               'SELECT * FROM APPLICATION_IDENTIFIER_TAB'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~31~ iTunes Backup Details PList - iOS
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_ITUNES_BACKUP_PLIST';
    fi_Name_Program:               'Itunes Backup';
    fi_Name_Program_Type:          'Details';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_ITUNES;
    fi_Icon_OS:                    ICON_ITUNES;
    fi_Regex_Search:               '[0-9a-fA-F-]{40,}\\info.plist' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY;
    fi_Signature_Sub:              'iTunes Backup Info plist'; //noslz
    fi_NodeByName:                 'iTunes Settings'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~32~ iTunes Backup Details XML - iOS
    fi_Process_As:                 PROCESS_AS_XML;
    fi_Process_ID:                 'DNT_ITUNES_BACKUP_XML';
    fi_Name_Program:               'Itunes Backup';
    fi_Name_Program_Type:          'Details';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_ITUNES;
    fi_Icon_OS:                    ICON_ITUNES;
    fi_Regex_Search:               '[0-9a-fA-F-]{40,}\\info.plist' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_XML;
    fi_Signature_Sub:              'iTunes Backup Info XML'; //noslz
    fi_NodeByName:                 'dict'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~33~ iTunes Backup Manifest SQLite
    fi_Name_Program:               'Itunes Backup';
    fi_Name_Program_Type:          'Manifest';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_ITUNES;
    fi_Icon_OS:                    ICON_ITUNES;
    fi_Regex_Search:               '[0-9a-fA-F-]{40,}\\Manifest\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'iTunes Manifest (SQLite)'; //noslz
    fi_SQLTables_Required:         ['FILES']; //noslz
    fi_SQLPrimary_Tablestr:        'FILES'; //noslz
    fi_SQLStatement:               'SELECT * FROM Files'; //noslz
    fi_Test_Data:                  'TGH JAH'), //noslz

    ( // ~34~ Maps
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_MAPS_HISTORY';
    fi_Name_Program:               'Maps';
    fi_Name_Program_Type:          'History';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_MAPS;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^history\.plist' + DUP_FILE + '|^b60c382887dfa562166f099f24797e55c12a94e4' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY; //noslz
    fi_Signature_Sub:              ''; //Maps iOS //noslz
    fi_NodeByName:                 'historyitems'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~35~ Notes - iOS
    fi_Name_Program:               'Note';
    fi_Name_Program_Type:          'Items';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_NOTES;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'notes\.sqlite' + DUP_FILE + '|^ca3bc056d4da0bbf88b5fb3be254f3b7147e639c' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Notes iOS'; //noslz
    fi_SQLTables_Required:         ['ZNOTE','ZACCOUNT','ZNEXTID']; //noslz
    fi_SQLPrimary_Tablestr:        'ZNOTE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZNOTE'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~36~ Notes - iOS (new format)
    fi_Name_Program:               'Note';
    fi_Name_Program_Type:          'Items';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_NOTES;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^NoteStore\.sqlite|^4f98687d8ab0d6d1a371110e6b7300f6e465bef2' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: '^AppDomainGroup-group\.com\.apple\.notes.*'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^NoteStore\.sqlite.*'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE; //noslz
    fi_SQLTables_Required:         ['ZICCLOUDSYNCINGOBJECT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZICCLOUDSYNCINGOBJECT'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZICCLOUDSYNCINGOBJECT'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~37~ Parked Car Locations - iOS
    fi_Name_Program:               'Parked Car Locations';
    fi_Name_Program_Type:          '';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1169;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'com\.apple\.routined\\Local\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE; //noslz
    fi_SQLTables_Required:         ['ZRTVEHICLEEVENTHISTORYMO']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRTVEHICLEEVENTHISTORYMO'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZRTVEHICLEEVENTHISTORYMO'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~38~ Photos (External.db) - Android 12
    fi_Name_Program:               'Photos' + SPACE + 'External';
    fi_Name_Program_Type:          '';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1102;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^External\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['FILES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM FILES'; //noslz
    fi_Reference_info:             'https://thebinaryhick.blog/2020/10/19/androids-external-db-everything-old-is-new-again/'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~39~ Photos (Internal.db) - Android 12
    fi_Name_Program:               'Photos' + SPACE + 'Internal';
    fi_Name_Program_Type:          '';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1102;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^Internal\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['FILES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM FILES'; //noslz
    fi_Reference_info:             'https://thebinaryhick.blog/2020/10/19/androids-external-db-everything-old-is-new-again/'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~40~ Photos.Sqlite - iOS 14
    fi_Name_Program:               PHOTOS_SQLITE;
    fi_Name_Program_Type:          '';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1102;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^Photos\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE; //noslz
    fi_SQLTables_Required:         ['ZASSET','ZPERSON']; //noslz - ZASSET is only in 14 and above
    fi_SQLPrimary_Tablestr:        'ZASSET'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZASSET'; //noslz
    fi_Reference_info:             '';
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~41~ Picasa
    fi_Name_Program:               'Picasa';
    fi_Name_Program_Type:          'Photos';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_PICASA;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^picasa\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PHOTOS','ALBUMS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'PHOTOS'; //noslz
    fi_SQLStatement:               'SELECT * FROM PHOTOS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~42~ Private Photo Vault Albums - iOS
    fi_Name_Program:               'Private Photo Vault';
    fi_Name_Program_Type:          'Albums';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1175;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^PPVCoreData\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZALBUM','ZMEDIAITEM']; //noslz
    fi_SQLPrimary_Tablestr:        'ZALBUM'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZALBUM'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~43~ Private Photo Vault Media - iOS
    fi_Name_Program:               'Private Photo Vault';
    fi_Name_Program_Type:          'Media';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1175;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^PPVCoreData\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMEDIAITEM','ZALBUM']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMEDIAITEM'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMEDIAITEM'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~44~ Screen Time Application Usage - iOS
    fi_Name_Program:               'Screen Time Application';
    fi_Name_Program_Type:          'Usage';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1179;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'RMAdminStore-Local\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZUSAGETIMEDITEM','ZCOREUSER','ZDOWNTIME']; //noslz
    fi_SQLPrimary_Tablestr:        'ZUSAGETIMEDITEM'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZUSAGETIMEDITEM'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~45~ Significant Locations - iOS
    fi_Name_Program:               'Significant';
    fi_Name_Program_Type:          'Locations';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1171;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'com\.apple\.routined\\Local\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZRTLEARNEDLOCATIONOFINTERESTMO','ZRTADDRESSMO','ZRTDEVICEMO']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRTLEARNEDLOCATIONOFINTERESTMO'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZRTLEARNEDLOCATIONOFINTERESTMO'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~46~ Significant Locations - iOS - Cloud v2
    fi_Name_Program:               'Significant';
    fi_Name_Program_Type:          'Locations';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1171;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'com\.apple\.routined\\Cloud\-V2\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZRTADDRESSMO','ZRTVISITMO']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRTADDRESSMO'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZRTADDRESSMO'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~47~ Significant Locations Visits - iOS
    fi_Name_Program:               'Significant';
    fi_Name_Program_Type:          'Locations Visits';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1171;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'com\.apple\.routined\\Local\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZRTLEARNEDLOCATIONOFINTERESTVISITMO','ZRTADDRESSMO','ZRTDEVICEMO']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRTLEARNEDLOCATIONOFINTERESTVISITMO'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZRTLEARNEDLOCATIONOFINTERESTVISITMO'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~48~ SMS - Android
    fi_Name_Program:               'SMS';
    fi_Name_Program_Type:          'MMS';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_SMS;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^mmssms\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_SMS_ANDROID;
    fi_SQLTables_Required:         ['SMS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'SMS'; //noslz
    fi_SQLStatement:               'SELECT * FROM SMS'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~49~ SMS - iOS 3
    fi_Name_Program:               'SMS';
    fi_Name_Program_Type:          'v3';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_SMS;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^sms\.db' + DUP_FILE + '|^3d0d7e5fb2ce288813306e4d4636395e047a3d28' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'SMS iOS v3'; //noslz
    fi_SQLTables_Required:         ['MESSAGE','MSG_PIECES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~50~ SMS - iOS 4 and above
    fi_Name_Program:               'SMS';
    fi_Name_Program_Type:          'v4';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_SMS;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^sms\.db' + DUP_FILE + '|^3d0d7e5fb2ce288813306e4d4636395e047a3d28' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'SMS iOS v4'; //noslz
    fi_SQLTables_Required:         ['MESSAGE','CHAT','HANDLE']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_Reference_Info:             'http://linuxsleuthing.blogspot.com.au/2015/01/getting-attached-apple-messaging.html';
    fi_SQLStatement:               'SELECT m.*, ' +
                                   'CASE m.is_from_me ' +
                                   '        WHEN "0" THEN h.ID ' +
                                   '        WHEN "1" THEN "Local User" ' +
                                   '        ELSE "unknown" ' +
                                   '    END AS "phonenumber", ' +
                                   'CASE m.cache_has_attachments ' +
                                   '        WHEN "1" THEN a.filename ' +
                                   '        ELSE "" ' +
                                   '    END AS "attachment", ' +
                                   'CASE m.is_from_me ' +
                                   '        WHEN "0" THEN "Received" ' +
                                   '        WHEN "1" THEN "Sent" ' +
                                   '        ELSE "unknown" ' +
                                   '    END AS "typea" ' +
                                   'FROM message as m ' +
                                   'LEFT JOIN message_attachment_join AS maj ON maj.message_id = m.rowid ' +
                                   'LEFT JOIN attachment AS a ON a.rowid = maj.attachment_id ' +
                                   'LEFT JOIN handle AS h ON h.rowid = m.handle_id';
    fi_Test_Data:                  ''), //noslz

    ( // ~51~ Uber Accounts
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_UBER_ACCOUNTS';
    fi_Name_Program:               'Uber';
    fi_Name_Program_Type:          'Accounts';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_UBER;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^client$|^822049aa48191952786cefad2d84213cd14da3e0' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'AppDomain-com.ubercab.UberClient';
    fi_Regex_Itunes_Backup_Name:   'Library\/Application Support\/PersistentStorage\/BootstrapStore\/Realtime.*?\.StreamModelKey\/client$';
    fi_Signature_Parent:           'JSON';
    fi_RootNodeName:               'JSON Tree'; //noslz
    fi_NodeByName:                 '{}'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~52~ Uber EyeBall (The number of customers who launch the Uber app looking for vehicles.)
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_UBER_EYEBALL';
    fi_Name_Program:               'Uber';
    fi_Name_Program_Type:          'Eyeball';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_UBER;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^eyeball' + DUP_FILE + '|^e3b061297f486cf3fad3f0d72260049c876689d7' + DUP_FILE + '|^1a498b1290ebe9515248d53cbabf5cd56f64a029' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'AppDomain-com.ubercab.UberClient';
    fi_Regex_Itunes_Backup_Name:   'Library\/Application Support\/PersistentStorage\/BootstrapStore\/Realtime.*?\.StreamModelKey\/eyeball$';
    fi_Signature_Parent:           'JSON'; //noslz
    fi_RootNodeName:               'JSON Tree'; //noslz
    fi_NodeByName:                 '{}'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~53~ Uber Database
    fi_Name_Program:               'Uber';
    fi_Name_Program_Type:          'Database';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_UBER;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'Documents\database\.db' + DUP_FILE + '|^3dfc6a567559f21460c2acaa9bab3ac515691ffa' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.ubercab\.UberClient.*';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/database\.db$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PLACE','FTS_PLACE-TABLE']; //noslz
    fi_SQLPrimary_Tablestr:        'PLACE'; //noslz
    fi_SQLStatement:               'SELECT * FROM PLACE'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~54~ User Shortcut Dictionary
    fi_Name_Program:               'User Shortcut';
    fi_Name_Program_Type:          'Dictionary';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_DICTIONARY;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'UserDictionary\.sqlite' + DUP_FILE + '|ecbed0ccc7570681c0ad104e7b62316b2d04d5d0';
    fi_Regex_Itunes_Backup_Domain: 'KeyboardDomain';
    fi_Regex_Itunes_Backup_Name:   'UserDictionary\.sqlite';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZUSERDICTIONARYENTRY']; //noslz
    fi_SQLPrimary_Tablestr:        'ZUSERDICTIONARYENTRY'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZUSERDICTIONARYENTRY'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~55~ Voice Mail - iOS
    fi_Name_Program:               'Voice';
    fi_Name_Program_Type:          'Mail';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_VOICEMAIL;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^992df473bbb9e132f4b3b6e4d33f72171e97bc7a' + DUP_FILE + '|voicemail\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['VOICEMAIL', 'sqlite_sequence']; //noslz
    fi_SQLPrimary_Tablestr:        'VOICEMAIL'; //noslz
    fi_SQLStatement:               'SELECT * FROM voicemail'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~56~ Voice Memos - iOS
    fi_Name_Program:               'Voice';
    fi_Name_Program_Type:          'Memos';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_BROWSERS;
    fi_Icon_Program:               ICON_VOICENOTES;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^Recordings\.db' + DUP_FILE + '|^303e04f2a5b473c5ca2127d65365db4c3e055c05' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^MediaDomain'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Media\/Recordings\/Recordings\.db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZRECORDING']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRECORDING'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZRECORDING'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~57~ Wifi - Configurations SQLite - Android
    fi_Name_Program:               'Wifi';
    fi_Name_Program_Type:          'Configurations SQLite';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_WIFI;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^wifi\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_WIFI_ANDROID;
    fi_SQLTables_Required:         ['WIFI_CONFIGURATIONS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ZRECORDING'; //noslz
    fi_SQLStatement:               'SELECT * FROM wifi_configurations'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~58~ Wifi - Configurations XML - Android
    fi_Process_As:                 PROCESS_AS_XML;
    fi_Process_ID:                 'DNT_WIFI_ANDROID';
    fi_Name_Program:               'Wifi';
    fi_Name_Program_Type:          'Configurations XML';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_WIFI;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'WifiConfigStore\.xml' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_XML;
    fi_NodeByName:                 'NetworkList'; //noslz
    fi_Test_Data:                  ''), //noslz

    ( // ~59~ Wifi - Flattened Data - Android
    fi_Process_As:                 PROCESS_AS_CARVE;
    fi_Process_ID:                 'DNT_WIFI_FLATTENED_DATA';
    fi_Name_Program:               'Wifi';
    fi_Name_Program_Type:          'Flattened Data';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_WIFI;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^flattened-data$'; //noslz
    fi_Carve_Header:               '\x6E\x65\x74\x77\x6F\x72\x6B\x3D\x7B\x0A\x09'; //noslz
    fi_Carve_Footer:               '\x0A\x7D'; //noslz
    fi_Carve_Adjustment:           0;
    fi_Test_Data:                  'GDH Android'), //noslz

    ( // ~60~ Wifi - Configurations - iOS
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_WIFI_CONFIGURATIONS';
    fi_Name_Program:               'Wifi';
    fi_Name_Program_Type:          'Configurations';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_WIFI;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'wifi\.plist' + DUP_FILE + '|^ade0340f576ee14793c607073bd7e8e409af07a8' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY;
    fi_Signature_Sub:              'WiFi iOS'; //noslz
    fi_NodeByName:                 'List of known networks'; //noslz
    fi_Test_Data:                  'Mary Thomas Hamilton = 234, IEF = 234'), //noslz

    ( // ~61~ Wifi - Locations - IOS
    fi_Name_Program:               'Wifi';
    fi_Name_Program_Type:          'Locations';
    fi_Process_ID:                 'WIFILOCATIONS'; //noslz
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_WIFI;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^cache_encryptedB\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['WIFILOCATION','WIFILOCATIONCOUNTS']; //noslz
    fi_SQLPrimary_Tablestr:        'WIFILOCATION'; //noslz
    fi_SQLStatement:               'SELECT * FROM WIFILOCATION'; //noslz
    fi_Test_Data:                  'Digital Corpa'));

var
  iIdx: integer;
begin
  for iIdx := Low(lFileItems) to High(lFileItems) do
    FileItems[iIdx] := @lFileItems[iIdx];
end;

// ~~~~

function RPad(const AString: string; AChars: integer): string;
begin
  AChars := AChars - Length(AString);
  if AChars > 0 then
    Result := AString + StringOfChar(' ', AChars)
  else
    Result := AString;
end;

// ~~~~

procedure Add40CharFiles(UniqueList: TUniqueListOfEntries);
var
  anEntry: TEntry;
  FileSystemDS: TDataStore;
begin
  FileSystemDS := GetDataStore(DATASTORE_FILESYSTEM);
  if assigned(UniqueList) and assigned(FileSystemDS) then
  begin
    anEntry := FileSystemDS.First;
    while assigned(anEntry) and Progress.isRunning do
    begin
      begin
        if RegexMatch(anEntry.EntryName, '^[0-9a-fA-F]{40}', False) and (anEntry.EntryNameExt = '') then // noslz iTunes Backup files
        begin
          UniqueList.Add(anEntry);
        end;
      end;
      anEntry := FileSystemDS.Next;
    end;
    FreeAndNil(FileSystemDS);
  end;
end;

function ColumnValueByNameAsDateTime(Statement: TSQLite3Statement; const colConf: TSQL_Table): TDateTime;
var
  iCol: integer;
begin
  Result := 0;
  iCol := ColumnByName(Statement, copy(colConf.sql_col, 5, Length(colConf.sql_col)));
  if (iCol > -1) then
  begin
    if colConf.read_as = ftLargeInt then
      Result := IntToDateTime(Statement.Columnint64(iCol), colConf.convert_as)
    else if colConf.read_as = ftFloat then
      Result := GHFloatToDateTime(Statement.Columnint64(iCol), colConf.convert_as);
  end;
end;

procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
var
  DeterminedFileDriverInfo: TFileTypeInformation;
  MatchSignature_str: string;
  NowProceed_bl: boolean;
  i: integer;
  File_Added_bl: boolean;
  Item: PSQL_FileSearch;
  reason_str: string;
  Reason_StringList: TStringList;
  trunc_EntryName_str: string;

begin
  File_Added_bl := False;
  if anEntry.isSystem and ((POS('$I30', anEntry.EntryName) > 0) or (POS('$90', anEntry.EntryName) > 0)) then
  begin
    NowProceed_bl := False;
    Exit;
  end;

  DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
  reason_str := '';
  trunc_EntryName_str := copy(anEntry.EntryName, 1, 25);
  Reason_StringList := TStringList.Create;
  try
    try
      for i := 1 to NUMBEROFSEARCHITEMS do
      begin
        if not Progress.isRunning then
          break;
        NowProceed_bl := False;
        reason_str := '';
        Item := FileItems[i];

        // -------------------------------------------------------------------------------
        // Special validation (these files are still sent here via the Regex match)
        // -------------------------------------------------------------------------------
        if (not NowProceed_bl) then
        begin
          if RegexMatch(anEntry.EntryName, Item^.fi_Regex_Search, False) and (RegexMatch(anEntry.EntryName, 'History.mapsdata', False) or RegexMatch(anEntry.EntryName, '1321e6b74c9dfe411e7e129d6a8ae7cc645af9d0', False) or
            RegexMatch(anEntry.EntryName, 'flattened-data', False)) then
            NowProceed_bl := True;
        end;

        // Proceed if SubDriver has been identified
        if (not NowProceed_bl) then
        begin
          if Item^.fi_Signature_Sub <> '' then
          begin
            if RegexMatch(RemoveSpecialChars(DeterminedFileDriverInfo.ShortDisplayName), RemoveSpecialChars(Item^.fi_Signature_Sub), False) then
            begin
              NowProceed_bl := True;
              reason_str := 'ShortDisplayName = Required SubSig:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ' = ' + Item^.fi_Signature_Sub + ')';
              Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(A)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
            end;
          end;
        end;

        // Set the MatchSignature to the parent
        if (not NowProceed_bl) and not(UpperCase(anEntry.Extension) = '.JSON') then
        begin
          MatchSignature_str := '';
          if Item^.fi_Signature_Sub = '' then
            MatchSignature_str := UpperCase(Item^.fi_Signature_Parent);
          // Proceed if SubDriver is blank, but File/Path Name and Parent Signature match
          if ((RegexMatch(anEntry.EntryName, Item^.fi_Regex_Search, False)) or (RegexMatch(anEntry.FullPathName, Item^.fi_Regex_Search, False))) and
            ((UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = UpperCase(MatchSignature_str)) or (RegexMatch(DeterminedFileDriverInfo.ShortDisplayName, MatchSignature_str, False))) then
          begin
            NowProceed_bl := True;
            reason_str := 'ShortDisplay matches Parent sig:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ' = ' + MatchSignature_str + ')';
            Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(B)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
          end;
        end;

        // Proceed if EntryName is unknown, but iTunes Domain, Name and Sig match
        if (not NowProceed_bl) then
        begin
          if RegexMatch(biTunes_Domain_str, Item^.fi_Regex_Itunes_Backup_Domain, False) and RegexMatch(biTunes_Name_str, Item^.fi_Regex_Itunes_Backup_Name, False) and
            (UpperCase(DeterminedFileDriverInfo.ShortDisplayName) = UpperCase(MatchSignature_str)) then
          begin
            NowProceed_bl := True;
            reason_str := 'Proceed on Sig and iTunes Domain\Name:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ' = ' + MatchSignature_str + ')';
            Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(C)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
          end;
        end;

        if NowProceed_bl then
        begin
          Arr_ValidatedFiles_TList[i].Add(anEntry);
          File_Added_bl := True;
          if USE_FLAGS_BL then
            anEntry.Flags := anEntry.Flags + [Flag5]; // Green Flag
        end;
      end;

      if NOT(File_Added_bl) then
        Reason_StringList.Add(format(GFORMAT_STR, ['', 'Ignored', '', IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]));

    finally
      for i := 0 to Reason_StringList.Count - 1 do
        Progress.Log(Reason_StringList[i]);
    end;

  finally
    Reason_StringList.free;
  end;
end;

function FileSubSignatureMatch(anEntry: TEntry): boolean;
var
  aName: string;
  i: integer;
  param_num_int: integer;
  aDeterminedFileDriverInfo: TFileTypeInformation;
  Item: PSQL_FileSearch;
begin
  Result := False;
  aName := anEntry.EntryName;
  if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
  begin
    for i := 1 to NUMBEROFSEARCHITEMS do
    begin
      if not Progress.isRunning then
        break;
      Item := FileItems[i];
      if Item^.fi_Signature_Sub <> '' then
      begin
        aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
        if RegexMatch(RemoveSpecialChars(aDeterminedFileDriverInfo.ShortDisplayName), RemoveSpecialChars(Item^.fi_Signature_Sub), False) then // 20-FEB-19 Changed to Regex for multiple sigs
        begin
          if BL_PROCEED_LOGGING then
            Progress.Log(RPad('Proceed' + HYPHEN + 'Identified by SubSig:', RPAD_VALUE) + anEntry.EntryName + SPACE + 'Bates:' + IntToStr(anEntry.ID));
          Result := True;
          break;
        end;
      end;
    end;
  end
  else
  begin
    if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) then
    begin
      for i := 0 to Parameter_Num_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        param_num_int := StrToInt(Parameter_Num_StringList[i]);
        Item := FileItems[param_num_int];
        if Item^.fi_Signature_Sub <> '' then
        begin
          aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
          if RegexMatch(RemoveSpecialChars(aDeterminedFileDriverInfo.ShortDisplayName), RemoveSpecialChars(Item^.fi_Signature_Sub), False) then // 20-FEB-19 Changed to Regex for multiple sigs
          begin
            if BL_PROCEED_LOGGING then
              Progress.Log(RPad('Proceed' + HYPHEN + 'File Sub-Signature Match:', RPAD_VALUE) + anEntry.EntryName + SPACE + 'Bates:' + IntToStr(anEntry.ID));
            Result := True;
            break;
          end;
        end;
      end
    end
  end;
end;

function GetFullName(Item: PSQL_FileSearch): string;
var
  ApplicationName: string;
  TypeName: string;
  OSName: string;
begin
  Result := '';
  ApplicationName := Item^.fi_Name_Program;
  TypeName := Item^.fi_Name_Program_Type;
  OSName := Item^.fi_Name_OS;
  if (ApplicationName <> '') then
  begin
    if (TypeName <> '') then
      Result := format('%0:s %1:s', [ApplicationName, TypeName])
    else if (ApplicationName <> '') then
      Result := ApplicationName
  end
  else
    Result := TypeName;
  if OSName <> '' then
    Result := Result + ' ' + OSName;
end;

function HaveIBeenProcessed(SigMatchEntry: TEntry; const a_fldr: string; const b_fldr: string): boolean;
begin
  Result := False;
  anEntry := ArtifactsDataStore.First;
  while assigned(anEntry) and Progress.isRunning do
  begin
    if (anEntry is TArtifactItem) then
    begin
      if SigMatchEntry = TArtifactItem(anEntry).SourceEntry then
      begin
        if UpperCase(TArtifactItem(anEntry).Parent.EntryName) = UpperCase(a_fldr) + ' ' + UpperCase(b_fldr) then
        begin
          Progress.Log(RPad('Skipped - Keep Artifacts:', RPAD_VALUE) + TArtifactItem(anEntry).FullPathName + TArtifactItem(anEntry).SourceEntry.EntryName + ' (' + IntToStr(TArtifactItem(anEntry).SourceEntry.ID) + ')');
          Result := True;
          break;
        end;
      end;
    end;
    anEntry := ArtifactsDataStore.Next;
  end;
  ArtifactsDataStore.Close;
end;

function KeepItems(anEntry: TEntry): boolean;
var
  i: integer;
begin
  Result := False;
  if (CmdLine.Params.Indexof(PROCESSALL) > -1) then // PROCESSALL
  begin
    for i := 1 to NUMBEROFSEARCHITEMS do
    begin
      if not Progress.isRunning then
        break;
      if UpperCase(anEntry.EntryName) = UpperCase(CATEGORY_NAME) then
      begin
        Progress.Log(RPad('Category has been previously processed:', RPAD_VALUE) + 'True');
        Result := True;
        break;
      end;
    end;
  end
  else if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) then // PROCESS INDIVIDUAL
  begin
    for i := 0 to Parameter_Num_StringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      Program_Folder_int := StrToInt(Parameter_Num_StringList[i]);
      if UpperCase(anEntry.EntryName) = UpperCase(GetFullName(FileItems[Program_Folder_int])) then
      begin
        Progress.Log(RPad('Has been previously processed:', RPAD_VALUE) + 'True');
        Result := True;
        break;
      end;
    end;
  end;
end;

function LengthArrayTABLE(anArray: TSQL_Table_array): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to 100 do
  begin
    if anArray[i].sql_col = '' then
      break;
    Result := i;
  end;
end;

{$IF DEFINED (ISFEXGUI)}

function MakeButton: boolean;
var
  concat_str: string;
  CreateButton_StringList: TStringList;
  Item: PSQL_FileSearch;
  n: integer;
  next_str: string;
  unit_name_str: string;
begin
  Result := False;
  LoadFileItems;
  CreateButton_StringList := TStringList.Create;
  try
    unit_name_str := StringReplace(PROGRAM_NAME, ' ', '_', [rfReplaceAll]);
    MakeButtonHeader(PROGRAM_NAME, SCRIPT_NAME, ICON_24_CHAT, CreateButton_StringList);
    concat_str := '';
    for n := 1 to NUMBEROFSEARCHITEMS do
    begin
      Item := FileItems[n];
      current_str := Item^.fi_Name_Program;
      if n <> NUMBEROFSEARCHITEMS then
        next_str := FileItems[n + 1].fi_Name_Program
      else
        next_str := '';
      if current_str <> next_str then
      begin
        concat_str := concat_str + ' ' + IntToStr(n);
        CreateButton_StringList.Add('  Button.AddDropMenu(''' + Item^.fi_Name_Program + ''', GetScriptsDir + ''Artifacts\' + SCRIPT_NAME + ''', ''' + concat_str + ''', ' + IntToStr(Item^.fi_Icon_Program) +
          ', BTNS_SHOWCAPTION or BTNS_DROPDOWN);');
        concat_str := '';
      end
      else
        concat_str := concat_str + ' ' + IntToStr(n);
    end;
    CreateButton_StringList.Add('end;');
    CreateButton_StringList.Add('end.');
  finally
    Progress.Log(CreateButton_StringList.Text);
    if CreateButton_StringList.Count > 0 then
    begin
      CreateButton_StringList.SaveToFile(GetScriptsDir + '\Artifacts\Common\Toolbar\Button_Artifacts_' + unit_name_str + '.pas');
      Result := True;
    end;
    CreateButton_StringList.free;
  end;
end;
{$IFEND}

procedure PostProcess_Remove_Zero;
var
  ArtRem_DataStore: TDataStore;
  caseEntry: TEntry;
  i: integer;
  name_trunc_str: string;
  pp_TList: TList;
  ppEntry: TEntry;
  Direct_Children_TList: TList;
  pp_RemoveBlank_TList: TList;
begin
  Progress.Log('Post Process (remove 0 counts)' + RUNNING);
  ArtRem_DataStore := GetDataStore(DATASTORE_ARTIFACTS);
  if ArtRem_DataStore = nil then
    Exit;
  if assigned(ArtRem_DataStore) and (ArtRem_DataStore.Count > 0) then
    try
      caseEntry := ArtRem_DataStore.First;
      pp_TList := TList.Create;
      pp_RemoveBlank_TList := TList.Create;
      try
        pp_TList := ArtRem_DataStore.GetEntireList;
        for i := 0 to ArtRem_DataStore.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          ppEntry := TEntry(pp_TList[i]);
          if ppEntry.isDirectory then
          begin
            Direct_Children_TList := TList.Create;
            try
              Direct_Children_TList := ArtRem_DataStore.Children(ppEntry);
              if (not ppEntry.isDevice) and (ppEntry <> caseEntry) and (Direct_Children_TList.Count = 0) then
              begin
                if ppEntry.Parent.EntryName = CATEGORY_NAME then
                begin
                  name_trunc_str := copy(ppEntry.EntryName, 1, 50);
                  Progress.Log(RPad(HYPHEN + name_trunc_str, RPAD_VALUE) + IntToStr(Direct_Children_TList.Count));
                  pp_RemoveBlank_TList.Add(ppEntry);
                end;
              end;
            finally
              Direct_Children_TList.free;
            end;
          end;
        end;

        if assigned(pp_RemoveBlank_TList) and (pp_RemoveBlank_TList.Count > 0) then
          try
            Sleep(100);
            Progress.Log('Removing Blank: ' + IntToStr(pp_RemoveBlank_TList.Count));
            ArtifactsDataStore.Remove(pp_RemoveBlank_TList);
          except
            Progress.Log('Could not remove blank item.');
          end;

      finally
        pp_TList.free;
        pp_RemoveBlank_TList.free;
      end;
    finally
      ArtRem_DataStore.free;
    end;
end;

function SetUpColumnforFolder(aReferenceNumber: integer; anArtifactFolder: TArtifactConnectEntry; out col_DF: TDataStoreFieldArray; ColCount: integer; aItems: TSQL_Table_array): boolean;
var
  NumberOfColumns: integer;
  Field: TDataStoreField;
  i: integer;
  column_label: string;
  Item: PSQL_FileSearch;
begin
  Result := True;
  Item := FileItems[aReferenceNumber];
  NumberOfColumns := ColCount;
  setlength(col_DF, ColCount + 1);

  if assigned(anArtifactFolder) then
  begin
    for i := 1 to NumberOfColumns do
    begin
      try
        if not Progress.isRunning then
          Exit;
        Field := ArtifactsDataStore.DataFields.FieldByName(aItems[i].fex_col);
        if assigned(Field) and (Field.FieldType <> aItems[i].col_type) then
        begin
          MessageUser(SCRIPT_NAME + DCR + 'WARNING: New column: ' + DCR + aItems[i].fex_col + DCR + 'already exists as a different type. Creation skipped.');
          Result := False;
        end
        else
        begin
          column_label := '';
          col_DF[i] := ArtifactsDataStore.DataFields.Add(aItems[i].fex_col + column_label, aItems[i].col_type);
          if col_DF[i] = nil then
          begin
            MessageUser(SCRIPT_NAME + DCR + 'Cannot use a fixed field. Please contact support@getdata.com quoting the following error: ' + DCR + SCRIPT_NAME + SPACE + IntToStr(aReferenceNumber) + SPACE + aItems[i].fex_col);
            Result := False;
          end;
        end;
      except
        MessageUser(ATRY_EXCEPT_STR + 'Failed to create column');
      end;
    end;

    // Set the Source Columns --------------------------------------------------
    col_source_file := ArtifactsDataStore.DataFields.GetFieldByName('Source_Name');
    col_source_path := ArtifactsDataStore.DataFields.GetFieldByName('Source_Path');
    col_source_created := ArtifactsDataStore.DataFields.GetFieldByName('Source_Created');
    col_source_modified := ArtifactsDataStore.DataFields.GetFieldByName('Source_Modified');

    // Columns -----------------------------------------------------------------
    if Result then
    begin
      // Enables the change of column headers when switching folders - This is the order of displayed columns
      for i := 1 to NumberOfColumns do
      begin
        if not Progress.isRunning then
          break;
        if aItems[i].Show then
        begin
          // Progress.Log('Add Field Name: ' + col_DF[i].FieldName);
          anArtifactFolder.AddField(col_DF[i]);
        end;
      end;

      if (Item^.fi_Process_As = 'POSTPROCESS') then
        anArtifactFolder.AddField(col_source_path)
      else
      begin
        anArtifactFolder.AddField(col_source_file);
        anArtifactFolder.AddField(col_source_path);
        anArtifactFolder.AddField(col_source_created);
        anArtifactFolder.AddField(col_source_modified);
      end;
    end;
  end;
end;

function TestForDoProcess(ARefNum: integer): boolean;
var
  Item: PSQL_FileSearch;
begin
  Result := False;
  Item := FileItems[ARefNum];
  if Item^.fi_Process_As = 'POSTPROCESS' then
  begin
    Result := True;
    Exit;
  end;
  if (ARefNum <= NUMBEROFSEARCHITEMS) and Progress.isRunning then
  begin
    if (CmdLine.Params.Indexof(IntToStr(ARefNum)) > -1) or (CmdLine.Params.Indexof(PROCESSALL) > -1) then
    begin
      Progress.Log(RPad('Process List #' + IntToStr(ARefNum) + SPACE + '(' + IntToStr(Arr_ValidatedFiles_TList[ARefNum].Count) + '):', RPAD_VALUE) + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type + RUNNING);
      Result := True;
    end;
  end
{$IF DEFINED (ISFEXGUI)}
  else
  begin
    if not Progress.isRunning then
      Exit;
    Progress.Log('Error: RefNum > NUMBEROFSEARCHITEMS'); // noslz
  end;
{$ELSE}
    ;
{$IFEND}
end;

function TotalValidatedFileCountInTLists: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to NUMBEROFSEARCHITEMS do
  begin
    if not Progress.isRunning then
      break;
    Result := Result + Arr_ValidatedFiles_TList[i].Count;
  end;
end;

procedure DoProcess(anArtifactFolder: TArtifactConnectEntry; Reference_Number: integer; aItems: TSQL_Table_array);
const
  // DO NOT TRANSLATE - Property Names -----------------------------------------
  PROP_SSID_STR = 'SSID_STR';
  PROP_LAST_JOINED = 'lastJoined';
  PROP_LAST_AUTO_JOINED = 'lastAutoJoined';
  PROP_BSSID = 'BSSID';
var
  aArtifactEntry: TEntry;
  aArtifactEntryParent: TEntry;
  abyte: byte;
  ADDList: TList;
  ansi_str: ansiString;
  aPropertyTree: TPropertyParent;
  aRootProperty: TPropertyNode;
  b: int64;
  BytesToStrings_StringList: TStringList;
  CarvedData: TByteInfo;
  CarvedEntry: TEntry;
  carved_str: string;
  ColCount: integer;
  col_DF: TDataStoreFieldArray;
  CompressedData: TBytes;
  decompstrm: TZDecompressionStream;
  Display_Name_str: string;
  DNT_sql_col: string;
  end_pos: int64;
  FooterProgress: TPAC;
  HeaderReader, FooterReader, CarvedEntryReader: TEntryReader;
  HeaderRegex, FooterRegEx: TRegEx;
  h_startpos, h_offset, h_count, f_offset, f_count: int64;
  i, g, x, y, z: integer;
  Item: PSQL_FileSearch;
  mem_strm1: TMemoryStream;
  mydb: TSQLite3Database;
  newEntryReader: TEntryReader;
  newJOURNALReader: TEntryReader;
  newWALReader: TEntryReader;
  Node1, Node2, Node3, Name_Node: TPropertyNode;
  NodeList1: TObjectList;
  NumberOfNodes: integer;
  offset_str: string;
  PropertyList: TObjectList;
  PropertyList_WifiConfig: TObjectList;
  Re: TDIPerlRegEx;
  records_read_int: integer;
  sqlselect: TSQLite3Statement;
  sqlselect_row: TSQLite3Statement;
  sql_row_count: integer;
  sql_tbl_count: integer;
  strm: TBytesStream;
  tempstr: string;
  tempstr_header: string;
  temp_str: string;
  TotalFiles: int64;
  variant_Array: array of variant;

  // Special Conversions
  aduration_str: string;
  countrycode_int: integer;
  countrycode_str: string;
  Direction_str: string;
  duration_int: integer;
  mac_address_str: string;
  mac_address_int64: int64;
  networkcode_int: integer;
  networkcode_str: string;
  phonenumber_str: string;
  phonenumber_trunc_str: string;
  SSIDSTR: string;
  type_str: string;

  procedure NullTheArray;
  var
    n: integer;
  begin
    for n := 1 to ColCount do
      variant_Array[n] := null;
  end;

  procedure AddToModule;
  var
    NEntry: TArtifactItem;
    populate_bl, IsAllEmpty, IsAllNull: boolean;
  begin
    populate_bl := False;
    IsAllEmpty := True;
    IsAllNull := True;

    for g := 1 to ColCount do
    begin
      if not VarIsEmpty(variant_Array[g]) then
      begin
        IsAllEmpty := False;
        break;
      end;
    end;

    for g := 1 to ColCount do
    begin
      if not VarIsNull(variant_Array[g]) then
      begin
        IsAllNull := False;
        break;
      end;
    end;

    if (not IsAllNull) and (not IsAllEmpty) then
    begin
      NEntry := TArtifactItem.Create;
      NEntry.SourceEntry := aArtifactEntry;
      NEntry.Parent := anArtifactFolder;
      NEntry.PhysicalSize := 0;
      NEntry.LogicalSize := 0;

      // Populate the columns
      for g := 1 to ColCount do
      begin
        if not Progress.isRunning then
          break;
        if (not VarIsNull(variant_Array[g])) and (not VarIsEmpty(variant_Array[g])) then
          try
            if (col_DF[g].FieldType = ftDateTime) then
              col_DF[g].AsDateTime[NEntry] := variant_Array[g];
            if (col_DF[g].FieldType = ftinteger) then
              col_DF[g].AsInteger[NEntry] := variant_Array[g];
            if (col_DF[g].FieldType = ftLargeInt) then
              col_DF[g].AsInt64[NEntry] := variant_Array[g];
            if (col_DF[g].FieldType = ftString) and VarIsStr(variant_Array[g]) and (variant_Array[g] <> '') then
              col_DF[g].AsString(NEntry) := variant_Array[g];
            if (col_DF[g].FieldType = ftBytes) then
              col_DF[g].AsBytes[NEntry] := variantToArrayBytes(variant_Array[g]);
          except
            on e: exception do
            begin
              Progress.Log(e.message);
              Progress.Log(ATRY_EXCEPT_STR + 'Error adding to columns in Procedure AddToModule');
            end;
          end;
      end;
      ADDList.Add(NEntry);
    end;
    NullTheArray;
  end;

  function Test_SQL_Tables: boolean;
  var
    table_name: string;
  begin
    Result := True;

    // ==========================================================
    // Table count check to eliminate corrupt SQL files with no tables
    sql_tbl_count := 0;
    try
      sqlselect := TSQLite3Statement.Create(mydb, 'SELECT name FROM sqlite_master WHERE type=''table''');
      while sqlselect.Step = SQLITE_ROW do
      begin
        if not Progress.isRunning then
          break;
        sql_tbl_count := sql_tbl_count + 1;
        table_name := ColumnValueByNameAsText(sqlselect, RS_DNT_NAME);
      end;
      FreeAndNil(sqlselect);
    except
      Progress.Log(ATRY_EXCEPT_STR + 'An exception has occurred (usually means that the SQLite file is corrupt).');
      sql_tbl_count := 0;
      Result := False;
      Exit;
    end;

    // ========================================================== SL
    // Table count check to eliminate SQL files without required tables
    if (sql_tbl_count > 0) and (Length(Item^.fi_SQLTables_Required) > 0) then
    begin
      sql_tbl_count := 0;
      tempstr := 'select count(*) from sqlite_master where type = ''table'' and ((upper(name) = upper(''' + Item^.fi_SQLTables_Required[0] + '''))';
      for s := 1 to Length(Item^.fi_SQLTables_Required) - 1 do
        tempstr := tempstr + ' or (upper(name) = upper(''' + Item^.fi_SQLTables_Required[s] + '''))';
      tempstr := tempstr + ')';
      try
        sqlselect_row := TSQLite3Statement.Create(mydb, tempstr);
        try
          if (sqlselect_row.Step = SQLITE_ROW) and (sqlselect_row.ColumnInt(0) = Length(Item^.fi_SQLTables_Required)) then
            sql_tbl_count := 1
          else
          begin
            Progress.Log(RPad(HYPHEN + 'Bates:' + SPACE + IntToStr(aArtifactEntry.ID) + HYPHEN + aArtifactEntry.EntryName, RPAD_VALUE) + 'Ignored (Found ' + IntToStr(sqlselect_row.ColumnInt(0)) + ' of ' +
              IntToStr(Length(Item^.fi_SQLTables_Required)) + ' required tables).');
            Result := False;
          end;
        finally
          sqlselect_row.free;
        end;
      except
        Progress.Log(ATRY_EXCEPT_STR + 'An exception has occurred (usually means that the SQLite file is corrupt).');
        Result := False;
      end;
    end;

    // Log the missing required tables
    for s := 0 to Length(Item^.fi_SQLTables_Required) - 1 do
    begin
      tempstr := 'select count(*) from sqlite_master where type = ''table'' and ((upper(name) = upper(''' + Item^.fi_SQLTables_Required[s] + ''')))';
      try
        sqlselect_row := TSQLite3Statement.Create(mydb, tempstr);
        try
          if (sqlselect_row.Step = SQLITE_ROW) then
          begin
            if sqlselect_row.ColumnInt(0) = 0 then
            begin
              Progress.Log(RPad('', RPAD_VALUE) + HYPHEN + 'Missing table:' + SPACE + Item^.fi_SQLTables_Required[s]);
              Result := False;
            end;
          end;
        finally
          sqlselect_row.free;
        end;
      except
        Progress.Log(ATRY_EXCEPT_STR + 'An exception has occurred (usually means that the SQLite file is corrupt).');
        Result := False;
      end;
    end;

    // ==========================================================
    // Row Count the matched table
    if sql_tbl_count > 0 then
    begin
      sql_row_count := 0;
      sqlselect_row := TSQLite3Statement.Create(mydb, 'SELECT COUNT(*) FROM ' + (Item^.fi_SQLPrimary_Tablestr));
      try
        while sqlselect_row.Step = SQLITE_ROW do
        begin
          sql_row_count := sqlselect_row.ColumnInt(0);
          break;
        end;
      finally
        sqlselect_row.free;
      end;
    end;

  end;

// Start of Do Process ---------------------------------------------------------
begin
  Item := FileItems[Reference_Number];
  temp_process_counter := 0;
  ColCount := LengthArrayTABLE(aItems);
  if (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) then
  begin
    if assigned(anArtifactFolder) then
    begin
      process_proceed_bl := True;
      SetUpColumnforFolder(Reference_Number, anArtifactFolder, col_DF, ColCount, aItems);
      if process_proceed_bl then
      begin
        setlength(variant_Array, ColCount + 1);
        ADDList := TList.Create;
        newEntryReader := TEntryReader.Create;
        try
          Progress.Max := Arr_ValidatedFiles_TList[Reference_Number].Count;
          Progress.DisplayMessageNow := 'Process' + SPACE + PROGRAM_NAME + ' - ' + Item^.fi_Name_OS + RUNNING;
          Progress.CurrentPosition := 1;

          // Regex Setup -------------------------------------------------------
          CarvedEntryReader := TEntryReader.Create;
          FooterProgress := TPAC.Create;
          FooterProgress.Start;
          FooterReader := TEntryReader.Create;
          FooterRegEx := TRegEx.Create;
          FooterRegEx.CaseSensitive := True;
          FooterRegEx.Progress := FooterProgress;
          FooterRegEx.SearchTerm := Item^.fi_Carve_Footer;
          HeaderReader := TEntryReader.Create;
          HeaderRegex := TRegEx.Create;
          HeaderRegex.CaseSensitive := True;
          HeaderRegex.Progress := Progress;
          HeaderRegex.SearchTerm := Item^.fi_Carve_Header;

          if HeaderRegex.LastError <> 0 then
          begin
            Progress.Log('HeaderRegex Error: ' + IntToStr(HeaderRegex.LastError));
            aArtifactEntry := nil;
            Exit;
          end;

          if FooterRegEx.LastError <> 0 then
          begin
            Progress.Log(RPad('!!!!!!! FOOTER REGEX ERROR !!!!!!!:', RPAD_VALUE) + IntToStr(FooterRegEx.LastError));
            aArtifactEntry := nil;
            Exit;
          end;

          TotalFiles := Arr_ValidatedFiles_TList[Reference_Number].Count;
          // Loop Validated Files ----------------------------------------------
          for i := 0 to Arr_ValidatedFiles_TList[Reference_Number].Count - 1 do { addList is freed a the end of this loop }
          begin
            if not Progress.isRunning then
              break;
            Progress.IncCurrentprogress;
            temp_process_counter := temp_process_counter + 1;
            Display_Name_str := GetFullName(Item);
            Progress.DisplayMessageNow := 'Processing' + SPACE + Display_Name_str + ' (' + IntToStr(temp_process_counter) + ' of ' + IntToStr(Arr_ValidatedFiles_TList[Reference_Number].Count) + ')' + RUNNING;
            aArtifactEntry := TEntry(Arr_ValidatedFiles_TList[Reference_Number].items[i]);
            if assigned(aArtifactEntry.Parent) then
              aArtifactEntryParent := TEntry(aArtifactEntry.Parent);

            if assigned(aArtifactEntry) and newEntryReader.OpenData(aArtifactEntry) and (newEntryReader.Size > 0) and Progress.isRunning then
            begin
              if USE_FLAGS_BL then
                aArtifactEntry.Flags := aArtifactEntry.Flags + [Flag8]; // Gray Flag = Process Routine

              // ================================================================
              // NODES - .PropName, .PropDisplayValue, .PropValue, .PropDataType
              // ================================================================
              if ((UpperCase(Item^.fi_Process_As) = PROCESS_AS_PLIST) or (UpperCase(Item^.fi_Process_As) = PROCESS_AS_XML)) and
                ((UpperCase(Item^.fi_Signature_Parent) = 'PLIST (BINARY)') or (UpperCase(Item^.fi_Signature_Parent) = 'JSON') or (UpperCase(Item^.fi_Signature_Parent) = 'XML')) then
              begin
                aPropertyTree := nil;
                try
                  if ProcessMetadataProperties(aArtifactEntry, aPropertyTree, newEntryReader) and assigned(aPropertyTree) then
                  begin
                    // Set Root Property (Level 0)
                    aRootProperty := aPropertyTree.RootProperty;
                    Progress.Log(RPad('Number of root child nodes:', RPAD_VALUE) + IntToStr(aRootProperty.PropChildList.Count) + HYPHEN + 'Bates ID: ' + IntToStr(aArtifactEntry.ID) + ' ' + aArtifactEntry.EntryName);
                    if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
                    begin
                      if not Progress.isRunning then
                        break;
                      // Locate NodeByName
                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_BLUETOOTH_DEVICES') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        Node1 := TPropertyNode(aRootProperty.PropChildList.items[0])
                      else
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                      if assigned(Node1) then
                      begin
                        // Count the number of nodes
                        NodeList1 := Node1.PropChildList;
                        if assigned(NodeList1) then
                          NumberOfNodes := NodeList1.Count
                        else
                          NumberOfNodes := 0;
                        Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(NumberOfNodes));

                        // BlueTool Devices PList - Process the nodes ----------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_BLUETOOTH_DEVICES') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          if (UpperCase(Item^.fi_Signature_Parent) = 'PLIST (BINARY)') then
                          begin
                            for x := 0 to aRootProperty.PropChildList.Count - 1 do
                            begin
                              if not Progress.isRunning then
                                break;
                              Node1 := TPropertyNode(aRootProperty.PropChildList.items[x]);
                              if assigned(Node1) then
                              begin
                                PropertyList := Node1.PropChildList;
                                if assigned(PropertyList) then
                                  for y := 0 to PropertyList.Count - 1 do
                                  begin
                                    Node2 := TPropertyNode(PropertyList.items[y]);
                                    if assigned(Node2) then
                                    begin
                                      variant_Array[1] := Node1.PropName;
                                      for g := 1 to ColCount do
                                      begin
                                        DNT_sql_col := aItems[g].sql_col;
                                        delete(DNT_sql_col, 1, 4);
                                        if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) then
                                        begin
                                        variant_Array[g] := Node2.PropDisplayValue;
                                        end;
                                      end;
                                    end;
                                  end;
                                AddToModule;
                              end;
                            end;
                          end;
                        end;

                        // Uber - JSON Accounts ---------------------------------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_UBER_ACCOUNTS') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          if assigned(aRootProperty) and (aRootProperty.PropName = 'JSON Tree') then
                          begin
                            for g := 1 to ColCount do
                              variant_Array[g] := null; // Null the array
                            for g := 1 to ColCount do
                            begin
                              DNT_sql_col := aItems[g].sql_col;
                              delete(DNT_sql_col, 1, 4);
                              Node2 := TPropertyNode(aRootProperty.GetFirstNodeByName(DNT_sql_col));
                              if assigned(Node2) then
                              begin
                                // String
                                if aItems[g].read_as = ftString then
                                  variant_Array[g] := Node2.PropDisplayValue;
                                // Date Time
                                if (aItems[g].col_type = ftDateTime) and (Node2.PropDataType = 'UString') then
                                  variant_Array[g] := IntToDateTime(StrToInt64(Node2.PropValue), aItems[g].convert_as);
                              end;
                            end;
                            AddToModule;
                          end;
                        end;

                        // Uber - JSON EyeBall ---------------------------------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_UBER EYEBALL') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          for g := 1 to ColCount do
                            variant_Array[g] := null; // Null the array
                          for g := 1 to ColCount do
                          begin
                            DNT_sql_col := aItems[g].sql_col;
                            delete(DNT_sql_col, 1, 4);
                            Node2 := TPropertyNode(aRootProperty.GetFirstNodeByName(DNT_sql_col));
                            if assigned(Node2) then
                            begin

                              // String
                              if aItems[g].read_as = ftString then
                                variant_Array[g] := Node2.PropDisplayValue;
                              // Date Time
                              if (aItems[g].col_type = ftDateTime) and (Node2.PropDataType = 'UString') then
                                variant_Array[g] := IntToDateTime(StrToInt64(Node2.PropValue), aItems[g].convert_as);
                            end;
                          end;
                          AddToModule;
                        end;

                        // iTunes Backup Details - XML - Process the nodes -----
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_ITUNES_BACKUP_XML') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          for g := 1 to ColCount do
                            variant_Array[g] := null; // Null the array
                          if (UpperCase(Item^.fi_Signature_Parent) = 'XML') then
                          begin
                            for x := 0 to NumberOfNodes - 1 do
                            begin
                              if not Progress.isRunning then
                                break;
                              Node1 := TPropertyNode(NodeList1.items[x]);
                              for g := 1 to ColCount do
                              begin
                                DNT_sql_col := aItems[g].sql_col;
                                delete(DNT_sql_col, 1, 4);
                                if assigned(Node1) and (UpperCase(Node1.PropDisplayValue) = UpperCase(DNT_sql_col)) then
                                begin
                                  Node1 := TPropertyNode(NodeList1.items[x + 1]);
                                  if assigned(Node1) then
                                  begin
                                    Progress.Log(RPad(' ' + Node1.PropName + ': ', RPAD_VALUE) + Node1.PropDisplayValue);
                                    variant_Array[g] := Node1.PropDisplayValue;
                                  end;
                                end;
                              end;
                            end;
                            AddToModule;
                          end;
                        end;

                        // iTunes PList - Process the nodes --------------------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_ITUNES_BACKUP_PLIST') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          for g := 1 to ColCount do
                            variant_Array[g] := null; // Null the array
                          if (UpperCase(Item^.fi_Signature_Parent) = 'PLIST (BINARY)') then
                          begin
                            for x := 0 to aRootProperty.PropChildList.Count - 1 do
                            begin
                              if not Progress.isRunning then
                                break;
                              Node1 := TPropertyNode(aRootProperty.PropChildList.items[x]);
                              if assigned(Node1) then
                              begin
                                for g := 1 to ColCount do
                                begin
                                  DNT_sql_col := aItems[g].sql_col;
                                  delete(DNT_sql_col, 1, 4);
                                  if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) then
                                  begin
                                    // Progress.Log(RPad(' ' + Node1.PropName + ': ', RPAD_VALUE) + Node1.PropDisplayValue);
                                    variant_Array[g] := Node1.PropDisplayValue;
                                  end;
                                end;
                              end;
                            end;
                            AddToModule;
                          end;
                        end;

                        // MAPS - Process the Nodes ----------------------------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_MAPS_HISTORY') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          for g := 1 to ColCount do
                            variant_Array[g] := null; // Null the array
                          for x := 0 to NumberOfNodes - 1 do
                          begin
                            if not Progress.isRunning then
                              break;

                            Node1 := TPropertyNode(NodeList1.items[x]);
                            PropertyList := Node1.PropChildList;
                            if assigned(PropertyList) then
                              for y := 0 to PropertyList.Count - 1 do
                              begin
                                Node2 := TPropertyNode(PropertyList.items[y]);
                                if assigned(Node2) then
                                begin
                                  for g := 1 to ColCount do
                                  begin
                                    if Not Progress.isRunning then
                                      break;
                                    DNT_sql_col := aItems[g].sql_col;
                                    delete(DNT_sql_col, 1, 4);
                                    if assigned(Node2) and (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) then
                                    begin
                                      // Progress.Log(RPad(' ' + Node2.PropName + ': ', RPAD_VALUE) + Node2.PropDisplayValue);
                                      variant_Array[g] := Node2.PropDisplayValue;
                                    end;
                                  end;
                                end;
                              end;
                            AddToModule;
                          end;
                        end;

                        // WIFI ANDROID XML - Process the Nodes ----------------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_WIFI_ANDROID') and (UpperCase(Item^.fi_Name_OS) = UpperCase(ANDROID)) then
                        begin
                          for g := 1 to ColCount do
                            variant_Array[g] := null; // Null the array
                          for x := 0 to NumberOfNodes - 1 do
                          begin
                            Progress.Log(StringOfChar('-', CHAR_LENGTH));
                            Progress.Log('Processing' + SPACE + IntToStr(x + 1) + ':');
                            if not Progress.isRunning then
                              break;
                            Node1 := TPropertyNode(NodeList1.items[x]);
                            if assigned(Node1) and (Node1.PropName = 'Network') then // noslz
                            begin
                              PropertyList := Node1.PropChildList;
                              if assigned(PropertyList) then
                                for y := 0 to PropertyList.Count - 1 do
                                begin
                                  Node2 := TPropertyNode(PropertyList.items[y]);
                                  if assigned(Node2) and (Node2.PropName = 'WifiConfiguration') then // noslz
                                  begin
                                    PropertyList_WifiConfig := Node2.PropChildList;
                                    if assigned(PropertyList_WifiConfig) then
                                    begin
                                      for z := 0 to PropertyList_WifiConfig.Count - 1 do
                                      begin
                                        Node3 := TPropertyNode(PropertyList_WifiConfig.items[z]);
                                        if Node3.PropName = 'string' then // noslz
                                        begin
                                        Name_Node := Node3.GetFirstNodeByName('name'); // noslz
                                        if assigned(Name_Node) then
                                        begin
                                        Progress.Log(RPad(Name_Node.PropValue, RPAD_VALUE) + Node3.PropDisplayValue);
                                        for g := 1 to ColCount do
                                        begin
                                        DNT_sql_col := aItems[g].sql_col;
                                        delete(DNT_sql_col, 1, 4);
                                        if DNT_sql_col = UpperCase(Name_Node.PropValue) then
                                        begin
                                        variant_Array[g] := Node3.PropDisplayValue;
                                        Progress.Log(RPad(Name_Node.PropValue, RPAD_VALUE) + Node3.PropDisplayValue);
                                        end;
                                        end;
                                        end;
                                        end;
                                      end;
                                      AddToModule;
                                    end;
                                  end;
                                end;
                            end;

                          end; { number of nodes }
                        end; { wifi }

                        // WIFI iOS - Process the Nodes ----------------------------
                        if (UpperCase(Item^.fi_Process_ID) = 'DNT_WIFI_CONFIGURATIONS') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                        begin
                          for g := 1 to ColCount do
                            variant_Array[g] := null; // Null the array
                          for x := 0 to NumberOfNodes - 1 do
                          begin
                            if not Progress.isRunning then
                              break;
                            SSIDSTR := '';
                            Node1 := TPropertyNode(NodeList1.items[x]);
                            PropertyList := Node1.PropChildList;
                            if assigned(PropertyList) then
                              for y := 0 to PropertyList.Count - 1 do
                              begin
                                Node2 := TPropertyNode(PropertyList.items[y]);
                                if assigned(Node2) then
                                begin
                                  for g := 1 to ColCount do
                                  begin
                                    if not Progress.isRunning then
                                      break;
                                    DNT_sql_col := aItems[g].sql_col;
                                    delete(DNT_sql_col, 1, 4);
                                    if assigned(Node2) and (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) then
                                    begin
                                      if (Node2.PropName = PROP_LAST_JOINED) and (aItems[g].convert_as = 'VARTODT') and (aItems[g].col_type = ftDateTime) then
                                        try
                                        variant_Array[g] := vartodatetime(Node2.PropValue);
                                        except
                                        Progress.Log(ATRY_EXCEPT_STR + 'An exception occurred for PROP_LAST_JOINED:      ' + Node2.PropDisplayValue);
                                        end
                                      else if (Node2.PropName = PROP_LAST_AUTO_JOINED) and (aItems[g].convert_as = 'VARTODT') and (aItems[g].col_type = ftDateTime) then
                                        try
                                        variant_Array[g] := vartodatetime(Node2.PropValue);
                                        except
                                        Progress.Log(ATRY_EXCEPT_STR + 'An exception occurred for PROP_LAST_AUTO_JOINED: ' + Node2.PropDisplayValue);
                                        end
                                      else
                                        variant_Array[g] := Node2.PropDisplayValue;
                                    end;
                                  end;
                                end;
                              end;
                            AddToModule;
                          end; { number of nodes }
                        end; { wifi }

                      end; { assigned Node1 }
                    end
                    else
                      Progress.Log((format('%-39s %-10s %-10s', ['Could not open data:', '-', 'Bates: ' + IntToStr(aArtifactEntry.ID) + ' ' + aArtifactEntry.EntryName])));
                  end;
                finally
                  if assigned(aPropertyTree) then
                    FreeAndNil(aPropertyTree);
                end;
              end;

              // SQL
              if RegexMatch(Item^.fi_Signature_Parent, RS_SIG_SQLITE, False) then
              begin
                newWALReader := GetWALReader(aArtifactEntry);
                newJOURNALReader := GetJOURNALReader(aArtifactEntry);
                try
                  mydb := TSQLite3Database.Create;
                  try
                    mydb.OpenStream(newEntryReader, newJOURNALReader, newWALReader);

                    if Test_SQL_Tables then
                    begin
                      z := 0;
                      records_read_int := 0;

                      // ***************************************************************************************************************************
                      sqlselect := TSQLite3Statement.Create(mydb, (Item^.fi_SQLStatement));
                      // ***************************************************************************************************************************

                      // Log large file processing
                      if sql_row_count > 50000 then
                        Progress.Log(RPad(HYPHEN + 'Bates:' + SPACE + IntToStr(aArtifactEntry.ID) + HYPHEN + aArtifactEntry.EntryName, RPAD_VALUE) + 'Total row count:' + SPACE + IntToStr(sql_row_count));

                      while sqlselect.Step = SQLITE_ROW do
                      begin
                        if not Progress.isRunning then
                          break;
                        records_read_int := records_read_int + 1;

                        // Progress for large files
                        if sql_row_count > 50000 then
                        begin
                          Progress.DisplayMessages := 'Processing' + SPACE + Display_Name_str + ' (' + IntToStr(temp_process_counter) + ' of ' + IntToStr(Arr_ValidatedFiles_TList[Reference_Number].Count) + ')' + SPACE +
                            IntToStr(records_read_int) + '/' + IntToStr(sql_row_count) + RUNNING;
                        end;

                        // Read the values from the SQL tables -----------------
                        for g := 1 to ColCount do
                        begin
                          if not Progress.isRunning then
                            break;
                          DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));

                          // String
                          if aItems[g].read_as = ftString then
                            variant_Array[g] := ColumnValueByNameAsText(sqlselect, DNT_sql_col)

                          else if (aItems[g].read_as = ftinteger) and (aItems[g].col_type = ftinteger) then
                            variant_Array[g] := ColumnValueByNameAsInt(sqlselect, DNT_sql_col)

                          else if (aItems[g].read_as = ftinteger) and (aItems[g].col_type = ftString) then
                            variant_Array[g] := ColumnValueByNameAsInt(sqlselect, DNT_sql_col)

                          else if (aItems[g].read_as = ftLargeInt) and (aItems[g].col_type = ftLargeInt) then
                            variant_Array[g] := ColumnValueByNameAsint64(sqlselect, DNT_sql_col)

                          else if (aItems[g].col_type = ftDateTime) then
                            if ColumnValueByNameAsDateTime(sqlselect, aItems[g]) > 0 then
                              variant_Array[g] := ColumnValueByNameAsDateTime(sqlselect, aItems[g]);

                          // Add the table name and row location
                          if DNT_sql_col = 'SQLLOCATION' then
                            variant_Array[g] := 'Table: ' + lowercase(Item^.fi_SQLPrimary_Tablestr) + ' (row ' + format('%.*d', [4, records_read_int]) + ')'; // noslz

                          // SPECIAL CONVERSIONS FOLLOW ========================

                          // BIGTOP_GMAIL_ANDROID
                          if (Item^.fi_Process_ID = 'BIGTOP_GMAIL_ANDROID') then // noslz
                          begin
                            if (UpperCase(DNT_sql_col) = 'ZIPPED_MESSAGE_PROTO') then // noslz
                            begin
                              CompressedData := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              strm := TBytesStream.Create(CompressedData);
                              try
                                strm.Position := 1;

                                decompstrm := TZDecompressionStream.Create(strm); // Create a decompressed stream
                                decompstrm.Position := 0;

                                ansi_str := '';
                                mem_strm1 := TMemoryStream.Create; // Create a memory stream

                                mem_strm1.copyfrom(decompstrm, decompstrm.Size); // Copy the decompressed stream into the memory stream

                                if mem_strm1.Size > 30 then
                                begin
                                  for b := 0 to 30 do
                                  begin
                                    mem_strm1.read(abyte, 1);
                                    tempstr_header := tempstr_header + ' ' + inttohex(abyte, 2);
                                  end;
                                  mem_strm1.Position := 0;
                                end;

                                Progress.Log(IntToStr(records_read_int) + '>' + IntToStr(Length(CompressedData)) + StringOfChar('=', CHAR_LENGTH) + '<' + IntToStr(records_read_int));
                                Progress.Log(tempstr_header);
                                tempstr_header := '';

                                setlength(ansi_str, mem_strm1.Size);
                                mem_strm1.read(ansi_str[1], mem_strm1.Size);

                                // Export result to HTML
                                mem_strm1.SaveToFile(GetUniqueFileName(GetExportedDir + '\str' + IntToStr(records_read_int) + '.html'))

                              finally
                                strm.free;
                                decompstrm.free;
                                mem_strm1.free;
                              end;
                              // Output the result ----------------------------
                              // Progress.Log(String(ansi_str));
                              // if length(temp_str) > 0 then
                              // variant_Array[g] := string(ansi_str);
                            end;
                          end;

                          // Photos Android 12 ---------------------------------
                          // https://thebinaryhick.blog/2020/10/19/androids-external-db-everything-old-is-new-again/
                          if (Item^.fi_Name_Program = 'Photos' + SPACE + ANDROID) and (Item^.fi_Name_Program_Type = '12') then // noslz
                          begin
                            if (UpperCase(DNT_sql_col) = 'FORMAT') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0 = data (file or folder)'
                              else if (variant_Array[g] = '12288') then
                                variant_Array[g] := '12288 = file'
                              else if (variant_Array[g] = '12289') then
                                variant_Array[g] := '12289 = folder'
                              else if (variant_Array[g] = '14336') then
                                variant_Array[g] := '14336 = picture'
                              else if (variant_Array[g] = '47360') then
                                variant_Array[g] := '47360 = audio'
                              else if (variant_Array[g] = '47488') then
                                variant_Array[g] := '14336 = video'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'IS_DOWNLOAD') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0 = No'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1 = Yes'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'MEDIA_TYPE') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0 = data (file or folder)'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1 = picture'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := '2 = auido'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := '3 = video'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                          end;

                          // Photos iOS 14 -------------------------------------
                          // https://github.com/ScottKjr3347/iOS_Local_PL_Photos.sqlite_Queries/blob/main/iOS14/iOS14_LPL_Phsql_Locations.txt
                          if Item^.fi_Name_Program = PHOTOS_SQLITE then // noslz
                          begin
                            if (UpperCase(DNT_sql_col) = 'ZCLOUDDELETESTATE') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0-Not deleted'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1-Deleted'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'ZFAVORITE') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0-No'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1-Yes'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'ZHIDDEN') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0-Asset Not Hidden'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1-Asset Hidden'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'ZKIND') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0-Photo'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1-Video'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'ZKINDSUBTYPE') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0-Still-Photo'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := '2-Live-Photo'
                              else if (variant_Array[g] = '10') then
                                variant_Array[g] := '10-SpringBoard-Screenshot'
                              else if (variant_Array[g] = '100') then
                                variant_Array[g] := '100-Video'
                              else if (variant_Array[g] = '101') then
                                variant_Array[g] := '101-Slow-Mo-Video'
                              else if (variant_Array[g] = '102') then
                                variant_Array[g] := '102-Time-lapse-Video'
                              else if (variant_Array[g] = '103') then
                                variant_Array[g] := '103-Replay_Screen_Recording'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'ZLATITUDE') then // noslz
                              if (variant_Array[g] = '-180.0') then
                                variant_Array[g] := '';

                            if (UpperCase(DNT_sql_col) = 'ZLONGITUDE') then // noslz
                              if (variant_Array[g] = '-180.0') then
                                variant_Array[g] := '';

                            if (UpperCase(DNT_sql_col) = 'ZORIENTATION') then // noslz
                            begin
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := '1-Video-Default_Adjustment_Horizontal-Camera-(left)'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := '2-Horizontal-Camera-(right)'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := '3-Horizontal-Camera-(right)'
                              else if (variant_Array[g] = '4') then
                                variant_Array[g] := '4-Horizontal-Camera-(left)'
                              else if (variant_Array[g] = '5') then
                                variant_Array[g] := '5-Vertical-Camera-(top)'
                              else if (variant_Array[g] = '6') then
                                variant_Array[g] := '6-Vertical-Camera-(top)'
                              else if (variant_Array[g] = '7') then
                                variant_Array[g] := '7-Vertical-Camera-(bottom)'
                              else if (variant_Array[g] = '8') then
                                variant_Array[g] := '8-Vertical-Camera-(bottom)'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                            if (UpperCase(DNT_sql_col) = 'ZTRASHEDSTATE') then // noslz
                            begin
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := '0-Not In Trash or Recently Deleted'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := '1-In Trash or Recently Deleted'
                              else
                                variant_Array[g] := 'unknown';
                            end;

                          end;

                          // Android Call Logs ---------------------------------
                          if UpperCase(Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type) = 'CALL LOGS' then
                          begin
                            // Direction
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'TYPE') then
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Incoming'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Outgoing'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := 'Missed'
                              else
                                variant_Array[g] := 'Unknown';
                          end;

                          // Calls ---------------------------------------------
                          if UpperCase(Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type) = 'CALLS' then
                          begin
                            // Clean up Number
                            if ((DNT_sql_col = 'Address') or (DNT_sql_col = 'ZADDRESS')) and (aItems[g].fex_col = 'Number') and (aItems[g].col_type = ftString) then
                            begin
                              phonenumber_str := '';
                              phonenumber_trunc_str := '';
                              phonenumber_str := trim(variant_Array[g]);
                              phonenumber_trunc_str := phonenumber_str;
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, '#', '', [rfReplaceAll]);
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, '+', '', [rfReplaceAll]);
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, '-', '', [rfReplaceAll]);
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, '(', '', [rfReplaceAll]);
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, '}', '', [rfReplaceAll]);
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, ' ', '', [rfReplaceAll]);
                              phonenumber_trunc_str := StringReplace(phonenumber_trunc_str, ' ', '', [rfReplaceAll]);
                              variant_Array[g] := phonenumber_trunc_str;
                            end;

                            // Duration
                            if ((DNT_sql_col = 'ZDURATION')) and (aItems[g].read_as = ftinteger) and (aItems[g].col_type = ftString) then
                            begin
                              duration_int := variant_Array[g];
                              aduration_str := '';
                              aduration_str := FormatDateTime('hh:mm:ss', duration_int / secsperday);
                              variant_Array[g] := aduration_str;
                            end;

                            // Direction
                            Direction_str := '';
                            if (DNT_sql_col = 'ZORIGINATED') then
                              if (variant_Array[g] = '0') then
                              begin
                                variant_Array[g] := 'Incoming';
                                Direction_str := 'Incoming';
                              end
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Outgoing'
                              else
                                variant_Array[g] := 'Unknown';
                            // Type of Call
                            if (DNT_sql_col = 'Flags') then
                              if (variant_Array[g] = '0') or (variant_Array[g] = '4') then
                                variant_Array[g] := 'Incoming'
                              else if (variant_Array[g] = '8') then
                                variant_Array[g] := 'Blocked'
                              else if (variant_Array[g] = '16') then
                                variant_Array[g] := 'Incoming - Facetime'
                              else if (variant_Array[g] = '1') or (variant_Array[g] = '5') or (variant_Array[g] = '9') or (variant_Array[g] = '17') or (variant_Array[g] = '21') then
                                variant_Array[g] := 'Outgoing'
                              else
                                variant_Array[g] := '-';
                            // Country Code
                            if (DNT_sql_col = 'country_code') // noslz
                              and (aItems[g].read_as = ftinteger) and (aItems[g].col_type = ftString) then
                            begin
                              countrycode_str := '';
                              countrycode_int := variant_Array[g];
                              countrycode_str := MMC_Loookup_Country(countrycode_int);
                              variant_Array[g] := countrycode_str;
                            end;
                            // Network Code
                            if (DNT_sql_col = 'network_code') // noslz
                              and (aItems[g].read_as = ftinteger) and (aItems[g].col_type = ftString) then
                            begin
                              networkcode_str := '';
                              networkcode_int := variant_Array[g];
                              networkcode_str := MMC_Loookup_Network(countrycode_int, networkcode_int);
                              variant_Array[g] := networkcode_str;
                            end;
                          end; { Calls }

                          // Wifi Locations ------------------------------------
                          if UpperCase(Item^.fi_Process_ID) = 'WIFILOCATIONS' then // noslz
                          begin
                            if (DNT_sql_col = 'MAC') then // noslz
                            begin
                              mac_address_str := trim(variant_Array[g]);
                              if Length(mac_address_str) >= 12 then
                                try
                                  mac_address_int64 := StrToInt64(mac_address_str);
                                  variant_Array[g] := inttohex(mac_address_int64, 12);
                                except
                                  Progress.Log(ATRY_EXCEPT_STR + 'creating MAC address.');
                                end;
                            end;
                          end;

                        end;
                        AddToModule;
                      end;
                      if assigned(sqlselect) then
                        sqlselect.free;
                      Progress.Log(RPad(HYPHEN + 'Bates:' + SPACE + IntToStr(aArtifactEntry.ID) + HYPHEN + copy(aArtifactEntry.EntryName, 1, 40), RPAD_VALUE) + IntToStr(records_read_int) + SPACE + '(SQL)');
                    end;
                  finally
                    FreeAndNil(mydb);
                    if assigned(newWALReader) then
                      FreeAndNil(newWALReader);
                    if assigned(newJOURNALReader) then
                      FreeAndNil(newJOURNALReader);
                  end;
                except
                  Progress.Log(ATRY_EXCEPT_STR + RPad('WARNING:', RPAD_VALUE) + 'ERROR DOING SQL QUERY!');
                end;
              end;

              // ================================================================
              // BYTES TO StringList
              // ================================================================
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_BYTES_STRLST) then
              begin
                // Process Dynamic Dictionary ==================================
                if (UpperCase(Item^.fi_Process_ID) = 'DNT_DYNAMIC_DICTIONARY') then
                begin
                  if HeaderReader.opendata(aArtifactEntry) then
                    try
                      Progress.Initialize(aArtifactEntry.PhysicalSize, 'Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ' + aArtifactEntry.EntryName);
                      HeaderReader.Position := 24;
                      BytesToStrings_StringList := BytesToStringList(HeaderReader, HeaderReader.Size, 10000);
                      for c := 0 to BytesToStrings_StringList.Count - 1 do
                      begin
                        variant_Array[1] := BytesToStrings_StringList[c];
                        AddToModule;
                      end;
                      BytesToStrings_StringList.free;
                    except
                      Progress.Log(ATRY_EXCEPT_STR + 'Error processing ' + aArtifactEntry.EntryName);
                    end;
                end;
              end;

              // REGEX CARVE
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_CARVE) then
              begin
                if HeaderReader.opendata(aArtifactEntry) and FooterReader.opendata(aArtifactEntry) then
                  try
                    Progress.Initialize(aArtifactEntry.PhysicalSize, 'Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ' + aArtifactEntry.EntryName);
                    h_startpos := 0;
                    HeaderReader.Position := 0;
                    HeaderRegex.Stream := HeaderReader;
                    FooterRegEx.Stream := FooterReader;
                    // Find the first match, h_offset returned is relative to start pos
                    HeaderRegex.Find(h_offset, h_count);
                    while h_offset <> -1 do // h_offset returned as -1 means no hit
                    begin
                      // Now look for a footer
                      FooterRegEx.Stream.Position := h_startpos + h_offset + Item^.fi_Carve_Adjustment;
                      // Limit looking for the footer to our max size
                      end_pos := h_startpos + h_offset + MAX_CARVE_SIZE;
                      if end_pos >= HeaderRegex.Stream.Size then
                        end_pos := HeaderRegex.Stream.Size - 1; // Don't go past the end!
                      FooterRegEx.Stream.Size := end_pos;
                      FooterRegEx.Find(f_offset, f_count);
                      // Found a footer and the size was at least our minimum
                      if (f_offset <> -1) and (f_offset + f_count >= MIN_CARVE_SIZE) then
                      begin
                        // Footer found - Create an Entry for the data found
                        CarvedEntry := TEntry.Create;
                        offset_str := IntToStr(h_offset + h_startpos);
                        // ByteInfo is data described as a list of byte runs, usually just one run
                        CarvedData := TByteInfo.Create;
                        // Point to the data of the file
                        CarvedData.ParentInfo := aArtifactEntry.DataInfo;
                        // Adds the block of data
                        CarvedData.RunLstAddPair(h_offset + h_startpos, f_offset + f_count);
                        CarvedEntry.DataInfo := CarvedData;
                        CarvedEntry.LogicalSize := CarvedData.Datasize;
                        CarvedEntry.PhysicalSize := CarvedData.Datasize;
                        begin
                          if CarvedEntryReader.opendata(CarvedEntry) then
                          begin
                            CarvedEntryReader.Position := 0;
                            carved_str := CarvedEntryReader.AsPrintableChar(CarvedEntryReader.Size);
                            for g := 1 to ColCount do
                              variant_Array[g] := null; // Null the array
                            // Setup the PerRegex Searches
                            Re := TDIPerlRegEx.Create(nil);
                            Re.CompileOptions := [coCaseLess];
                            Re.SetSubjectStr(carved_str);

                            // Process Android Wifi Flattened Data ===============
                            if (UpperCase(Item^.fi_Process_ID) = 'DNT_WIFI_FLATTEMED_DATA') then
                            begin
                              // SSID --------------------------------------------
                              Re.MatchPattern := '(?<=ssid=")(.*?)(?=")';
                              if Re.Match(0) >= 0 then
                              begin
                                variant_Array[2] := Re.matchedstr;
                                AddToModule;
                              end;
                            end;

                            // Process Google Maps ===============================
                            if (UpperCase(Item^.fi_Process_ID) = 'DNT_GOOGLE_MAPS') then
                            begin
                              // NAME --------------------------------------------
                              Re.MatchPattern := '(?<=\"\.)(\w.*?)(?=\*\$)';
                              if Re.Match(0) >= 0 then
                                variant_Array[1] := Re.matchedstr;

                              // URL ---------------------------------------------
                              Re.MatchPattern := '(?<=5\.{6}[a-zA-Z0-9])(.*?)(?=\.{2}\xFF\xFF\xFF)';
                              if Re.Match(0) >= 0 then
                                variant_Array[2] := Re.matchedstr;

                              // ADDRESS -----------------------------------------
                              Re.MatchPattern := '(?<="R.|Z\.)(.*?)(?=J\.\.\.\.)';
                              if Re.Match(0) >= 0 then
                              begin
                                temp_str := Re.matchedstr;
                                temp_str := StringReplace(temp_str, 'z(..', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, 'z,..', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, 'z5..', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, ':.', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '..', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '2.', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, 'Z.', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, 'B.', ', ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, 'R.', ', ', [rfReplaceAll]);
                                variant_Array[3] := temp_str;
                              end;
                              if (variant_Array[1] <> '') or (variant_Array[2] <> '') or (variant_Array[3] <> '') then
                                AddToModule;
                            end;
                            if assigned(Re) then
                              FreeAndNil(Re);
                            FreeAndNil(Re);
                          end;
                        end;
                      end;
                      HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match
                    end;
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error processing ' + aArtifactEntry.EntryName);
                  end; { Regex Carve }
              end;
            end;
            // Progress.Log(Stringofchar('-', CHAR_LENGTH));
            Progress.IncCurrentprogress;
          end;

          // Add to the ArtifactsDataStore
          if assigned(ADDList) and Progress.isRunning then
          begin
            ArtifactsDataStore.Add(ADDList);
            Progress.Log(RPad('Total Artifacts:', RPAD_VALUE) + IntToStr(ADDList.Count));

            // Export L01 files where artifacts are found (controlled by Artifact_Utils.pas)
            if (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) and (ADDList.Count > 0) then
              ExportToL01(Arr_ValidatedFiles_TList[Reference_Number], Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type);

            ADDList.Clear;
          end;

          Progress.Log(StringOfChar('-', CHAR_LENGTH));
        finally
          records_read_int := 0;
          FreeAndNil(CarvedEntryReader);
          FreeAndNil(FooterProgress);
          FreeAndNil(FooterReader);
          FreeAndNil(FooterRegEx);
          FreeAndNil(HeaderReader);
          FreeAndNil(HeaderRegex);
          FreeAndNil(ADDList);
          FreeAndNil(newEntryReader);
        end;
      end;

    end
    else
      Progress.Log(RPad('', RPAD_VALUE) + 'IMPORTANT: Process failed. Not assigned a tree folder.');

  end
  else
  begin
    Progress.Log(RPad('', RPAD_VALUE) + 'No files to process.');
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
  end;

end;

// ==========================================================================================================================================================
// Start of Script
// ==========================================================================================================================================================
const
  SEARCHING_FOR_ARTIFACT_FILES_STR = 'Searching for Artifact files';

var
  AboutToProcess_StringList: TStringList;
  aDeterminedFileDriverInfo: TFileTypeInformation;
  aFolderEntry: TEntry;
  AllFoundListUnique: TUniqueListOfEntries;
  AllFoundList_count: integer;
  DeleteFolder_display_str: string;
  DeleteFolder_TList: TList;
  Display_StringList: TStringList;
  Enum: TEntryEnumerator;
  ExistingFolders_TList: TList;
  FieldItunesDomain: TDataStoreField;
  FieldItunesName: TDataStoreField;
  FindEntries_StringList: TStringList;
  FoundList, AllFoundList: TList;
  i: integer;
  Item: PSQL_FileSearch;
  iTunes_Domain_str: string;
  iTunes_Name_str: string;
  ResultInt: integer;

{$IF DEFINED (ISFEXGUI)}
  MyScriptForm: TScriptForm;
{$IFEND}

procedure LogExistingFolders(ExistingFolders_TList: TList; DeleteFolder_TList: TList); // Compare About to Process Folders with Existing Artifact Module Folders
const
  LOG_BL = False;
var
  aFolderEntry: TEntry;
  s, t: integer;
begin
  if LOG_BL then
    Progress.Log('Existing Folders:');
  for s := 0 to ExistingFolders_TList.Count - 1 do
  begin
    if not Progress.isRunning then
      break;
    aFolderEntry := (TEntry(ExistingFolders_TList[s]));
    if LOG_BL then
      Progress.Log(HYPHEN + aFolderEntry.FullPathName);
    for t := 0 to AboutToProcess_StringList.Count - 1 do
    begin
      if aFolderEntry.FullPathName = AboutToProcess_StringList[t] then
        DeleteFolder_TList.Add(aFolderEntry);
    end;
  end;
  if LOG_BL then
    Progress.Log(StringOfChar('-', CHAR_LENGTH));
end;

// Start of script
begin
  LoadFileItems;
  Progress.Log(SCRIPT_NAME + ' started.');
  Progress.DisplayTitle := 'Artifacts' + HYPHEN + PROGRAM_NAME;
  Progress.LogType := ltVerbose; // ltOff, ltVerbose, ltDebug, ltTechnical

  // MakeButton; Exit;

  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := ('Processing complete.');
    Exit;
  end;

  param := '';
  test_param_int := 0;
  process_all_bl := False;

  Parameter_Num_StringList := TStringList.Create;
  try { Parameter_Num_StringList }
    if (CmdLine.ParamCount > 0) then
    begin
      Progress.Log(IntToStr(CmdLine.ParamCount) + ' processing parameters received: ');
      for n := 0 to CmdLine.ParamCount - 1 do
      begin
        if not Progress.isRunning then
          break;

        param := param + '"' + CmdLine.Params[n] + '"' + ' ';
        // Validate Parameters
        if (RegexMatch(CmdLine.Params[n], '\d{1,2}$', False)) then
        begin
          try
            test_param_int := StrToInt(CmdLine.Params[n]);
            if (test_param_int <= 0) or (test_param_int > NUMBEROFSEARCHITEMS) then
            begin
              MessageUser('Invalid parameter received: ' + (CmdLine.Params[n]) + #13#10 + ('Maximum is: ' + IntToStr(NUMBEROFSEARCHITEMS) + DCR + SCRIPT_NAME + ' will terminate.'));
              Exit;
            end;
            Parameter_Num_StringList.Add(CmdLine.Params[n]);
            Item := FileItems[test_param_int];
            Progress.Log(RPad(HYPHEN + 'Param ' + IntToStr(n) + ' = ' + CmdLine.Params[n], RPAD_VALUE) + format('%-10s %-10s %-25s %-12s', ['Ref#: ' + CmdLine.Params[n], CATEGORY_NAME,
              Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type, Item^.fi_Name_OS]));
          except
            begin
              Progress.Log(ATRY_EXCEPT_STR + 'Error validating parameter. ' + SCRIPT_NAME + ' will terminate.');
              Exit;
            end;
          end;
        end;
      end;
      trim(param);
    end
    else
    begin
      MessageUser('No parameters received.');
      Exit;
    end;
    Progress.Log(StringOfChar('-', CHAR_LENGTH));

    // Progress Bar Text
    progress_program_str := '';
    if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
    begin
      progress_program_str := PROGRAM_NAME;
      process_all_bl := True;
    end;

    for n := 1 to NUMBEROFSEARCHITEMS do
    begin
      if not Progress.isRunning then
        break;
      if (CmdLine.Params.Indexof(IntToStr(n)) > -1) then
      begin
        Item := FileItems[n];
        progress_program_str := 'Ref#:' + SPACE + param + SPACE + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type;
        break;
      end;
    end;
    if progress_program_str = '' then
      progress_program_str := 'Other';

    ArtifactsDataStore := GetDataStore(DATASTORE_ARTIFACTS);
    if not assigned(ArtifactsDataStore) then
    begin
      Progress.Log(DATASTORE_ARTIFACTS + ' module not located.' + DCR + TSWT);
      Exit;
    end;

    try { ArtifactsDataStore }
      FileSystemDataStore := GetDataStore(DATASTORE_FILESYSTEM);
      if not assigned(FileSystemDataStore) then
      begin
        Progress.Log(DATASTORE_FILESYSTEM + ' module not located.' + DCR + TSWT);
        Exit;
      end;

      try { FileSystemDataStore }
        FieldItunesDomain := FileSystemDataStore.DataFields.FieldByName(FBN_ITUNES_BACKUP_DOMAIN);
        FieldItunesName := FileSystemDataStore.DataFields.FieldByName(FBN_ITUNES_BACKUP_NAME);

        // Create TLists For Valid Files
        for n := 1 to NUMBEROFSEARCHITEMS do
        begin
          if not Progress.isRunning then
            break;
          Arr_ValidatedFiles_TList[n] := TList.Create;
        end;

        try { Arr_ValidatedFiles_TList }
          AboutToProcess_StringList := TStringList.Create;
          AboutToProcess_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
          AboutToProcess_StringList.Duplicates := dupIgnore;
          try
            Display_str := '';
            mb_display_str := '';
            previous_str := '';
            current_str := '';
            if (CmdLine.Params.Indexof('MASTER') = -1) then
            begin
              if (CmdLine.Params.Indexof('NOSHOW') = -1) then
              begin
                Display_StringList := TStringList.Create;
                Display_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
                Display_StringList.Duplicates := dupIgnore;
                try
                  // Process All - Create the AboutToProcess_StringList and the Message Box text
                  if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
                  begin
                    previous_str := '';
                    current_str := '';
                    for n := 1 to NUMBEROFSEARCHITEMS do
                    begin
                      if not Progress.isRunning then
                        break;
                      Item := FileItems[n];
                      current_str := GetFullName(Item);
                      AboutToProcess_StringList.Add(CATEGORY_NAME + '\' + current_str);
                      if current_str <> previous_str then
                      begin
                        Display_StringList.Add(current_str);
                      end;
                      previous_str := current_str;
                    end;
                    Display_str := Display_StringList.Text;
                  end
                  else
                  begin
                    // Process Individual - Create the AboutToProcess_StringList and the Message Box text
                    if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) then
                    begin
                      for n := 0 to Parameter_Num_StringList.Count - 1 do
                      begin
                        if not Progress.isRunning then
                          break;
                        temp_int := StrToInt(Parameter_Num_StringList[n]);
                        Item := FileItems[temp_int];
                        AboutToProcess_StringList.Add(CATEGORY_NAME + '\' + GetFullName(Item));
                      end;
                      Display_str := AboutToProcess_StringList.Text;
                    end;
                  end;
                finally
                  if (Display_StringList.Count > 0) then
                  begin
                    Progress.Log('Extract Artifacts:');
                    Progress.Log(Display_StringList.Text);
                  end;
                  Display_StringList.free;
                end;

                // // Log About to Process
                // Progress.Log('About to Process:');
                // for s := 0 to AboutToProcess_StringList.Count - 1 do
                // Progress.Log(AboutToProcess_StringList[s]);
                // Progress.Log(Stringofchar('-', CHAR_LENGTH));

                // Show the form
                ResultInt := 1; // Continue AboutToProcess

{$IF DEFINED (ISFEXGUI)}
                if AboutToProcess_StringList.Count > 30 then
                begin
                  MyScriptForm := TScriptForm.Create;
                  try
                    MyScriptForm.SetCaption(SCRIPT_DESCRIPTION);
                    MyScriptForm.SetText(trim(Display_str));
                    ResultInt := idCancel;
                    if MyScriptForm.ShowModal then
                      ResultInt := idOk
                  finally
                    FreeAndNil(MyScriptForm);
                  end;
                end
                else
                begin
                  ResultInt := MessageBox('Extract Artifacts?' + DCR + Display_str, 'Extract Artifacts' + HYPHEN + PROGRAM_NAME, (MB_OKCANCEL or MB_ICONQUESTION or MB_DEFBUTTON2 or MB_SETFOREGROUND or MB_TOPMOST));
                end;
{$IFEND}
              end;

              if ResultInt > 1 then // User cancels
              begin
                Progress.Log(CANCELED_BY_USER);
                Progress.DisplayMessageNow := CANCELED_BY_USER;
                Exit;
              end;

            end; { About to process }

            // Deal with Existing Artifact Folders
            ExistingFolders_TList := TList.Create;
            DeleteFolder_TList := TList.Create;
            try
              if ArtifactsDataStore.Count > 1 then
              begin
                anEntry := ArtifactsDataStore.First;
                while assigned(anEntry) and Progress.isRunning do
                begin
                  if anEntry.isDirectory then
                    ExistingFolders_TList.Add(anEntry);
                  anEntry := ArtifactsDataStore.Next;
                end;
                ArtifactsDataStore.Close;
              end;

              LogExistingFolders(ExistingFolders_TList, DeleteFolder_TList);

              // Create the delete folder TList and display string
              if assigned(DeleteFolder_TList) and (DeleteFolder_TList.Count > 0) then
              begin
                for s := 0 to DeleteFolder_TList.Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  aFolderEntry := (TEntry(DeleteFolder_TList[s]));
                  DeleteFolder_display_str := DeleteFolder_display_str + #13#10 + aFolderEntry.FullPathName;
                  Progress.Log('Replace this Artifact folder?: ' + aFolderEntry.FullPathName);
                end;
                Progress.Log(StringOfChar('-', CHAR_LENGTH));
              end;

              // Message Box - When artifact folder is already present ---------------------
              if assigned(DeleteFolder_TList) and (DeleteFolder_TList.Count > 0) then
              begin
                if (CmdLine.Params.Indexof('MASTER') = -1) and (CmdLine.Params.Indexof('NOSHOW') = -1) then
                begin
{$IF DEFINED (ISFEXGUI)}
                  if (CmdLine.Params.Indexof('NOSHOW') = -1) then
                  begin
                    if assigned(DeleteFolder_TList) and (DeleteFolder_TList.Count > 0) then
                    begin
                      ResultInt := MessageBox('Artifacts have already been processed:' + #13#10 + DeleteFolder_display_str + DCR + 'Replace the existing Artifacts?', 'Extract Artifacts' + HYPHEN + PROGRAM_NAME,
                        (MB_OKCANCEL or MB_ICONWARNING or MB_DEFBUTTON2 or MB_SETFOREGROUND or MB_TOPMOST));
                    end;
                  end
                  else
                    ResultInt := idOk;
                  case ResultInt of
                    idOk:
                      begin
                        try
                          ArtifactsDataStore.Remove(DeleteFolder_TList);
                        except
                          MessageBox('ERROR: There was an error deleting existing artifacts.' + #13#10 + 'Save then reopen your case.', SCRIPT_NAME, (MB_OK or MB_ICONINFORMATION or MB_SETFOREGROUND or MB_TOPMOST));
                        end;
                        Progress.Log(RPad('Replace Existing Artifacts:', RPAD_VALUE) + 'True');
                      end;
                    idCancel:
                      begin
                        Progress.Log(CANCELED_BY_USER);
                        Progress.DisplayMessageNow := CANCELED_BY_USER;
                        Exit;
                      end;
                  end;
{$IFEND}
                end;
              end;
            finally
              ExistingFolders_TList.free;
              DeleteFolder_TList.free;
            end;
          finally
            AboutToProcess_StringList.free;
          end;

          // Find iTunes Backups and run Signature Analysis
          if (CmdLine.Params.Indexof('NOITUNES') = -1) then
            Itunes_Backup_Signature_Analysis;

          // Create the RegEx Search String
          regex_search_str := '';
          begin
            for n := 1 to NUMBEROFSEARCHITEMS do
            begin
              if not Progress.isRunning then
                break;
              Item := FileItems[n];
              if (CmdLine.Params.Indexof(IntToStr(n)) > -1) or (CmdLine.Params.Indexof(PROCESSALL) > -1) then
              begin
                if Item^.fi_Regex_Search <> '' then
                  regex_search_str := regex_search_str + '|' + Item^.fi_Regex_Search;
                if Item^.fi_Regex_Itunes_Backup_Domain <> '' then
                  regex_search_str := regex_search_str + '|' + Item^.fi_Regex_Itunes_Backup_Domain;
                if Item^.fi_Regex_Itunes_Backup_Name <> '' then
                  regex_search_str := regex_search_str + '|' + Item^.fi_Regex_Itunes_Backup_Name;
              end;
            end;
          end;
          if (regex_search_str <> '') and (regex_search_str[1] = '|') then
            Delete(regex_search_str, 1, 1);

          AllFoundList := TList.Create;
          try
            AllFoundListUnique := TUniqueListOfEntries.Create;
            FoundList := TList.Create;
            FindEntries_StringList := TStringList.Create;
            try
              FindEntries_StringList.Add('**\*.db*');
              FindEntries_StringList.Add('**\*.sqlite*');
              FindEntries_StringList.Add('**\MapsSync_0.0.1*');
              FindEntries_StringList.Add('**\*.mapsdata*');
              FindEntries_StringList.Add('**\\client*');
              FindEntries_StringList.Add('**\\eyeball*');
              FindEntries_StringList.Add('**\\flattened-data*');
              FindEntries_StringList.Add('**\callhistory*');
              FindEntries_StringList.Add('**\MobileSync\**\*'); // All iTunes folder
              FindEntries_StringList.Add('**\*.xml');

              // Find the files by path and add to AllFoundListUnique
              Progress.Initialize(FindEntries_StringList.Count, STR_FILES_BY_PATH + RUNNING);
              Progress.Log('Find files by path' + RUNNING);
              gtick_foundlist_i64 := GetTickCount;
              for i := 0 to FindEntries_StringList.Count - 1 do
              begin
                if not Progress.isRunning then
                  break;
                try
                  Find_Entries_By_Path(FileSystemDataStore, FindEntries_StringList[i], FoundList, AllFoundListUnique);
                except
                  Progress.Log(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + 'Find_Entries_By_Path');
                end;
                Progress.IncCurrentprogress;
              end;

              Progress.Log(StringOfChar('-', CHAR_LENGTH));
              Progress.Log(RPad(STR_FILES_BY_PATH + SPACE + '(Unique)' + COLON, RPAD_VALUE) + IntToStr(AllFoundListUnique.Count));
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

              // Add > 40 char files with no extension to Unique List (possible iTunes backup files)
              Add40CharFiles(AllFoundListUnique);
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

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

              // Now work with the TList from now on
              if assigned(AllFoundList) and (AllFoundList.Count > 0) then
              begin
                Progress.Log(StringOfChar('-', CHAR_LENGTH));
                Progress.Log('Unique Files by path: ' + IntToStr(AllFoundListUnique.Count));
                Progress.Log(StringOfChar('-', CHAR_LENGTH));

                // Add flags
                if USE_FLAGS_BL then
                begin
                  Progress.Log('Adding flags' + RUNNING);
                  for i := 0 to AllFoundList.Count - 1 do
                  begin
                    if not Progress.isRunning then
                      break;
                    anEntry := TEntry(AllFoundList[i]);
                    anEntry.Flags := anEntry.Flags + [Flag7];
                  end;
                  Progress.Log('Finished adding flags...');
                  Progress.Log(StringOfChar('-', CHAR_LENGTH));
                end;

                // Determine signature
                if assigned(AllFoundList) and (AllFoundList.Count > 0) then
                  SignatureAnalysis(AllFoundList);

                gtick_foundlist_str := (RPad(STR_FILES_BY_PATH + COLON, RPAD_VALUE) + CalcTimeTaken(gtick_foundlist_i64));
              end;

            finally
              FoundList.free;
              AllFoundListUnique.free;
              FindEntries_StringList.free;
            end;

            // Locate the relevant files in the File System
            if assigned(AllFoundList) and (AllFoundList.Count > 0) then
            begin
              Progress.Log(SEARCHING_FOR_ARTIFACT_FILES_STR + ':' + SPACE + progress_program_str + RUNNING);
              Progress.Log(format(GFORMAT_STR, ['', 'Action', 'Ref#', 'Bates', 'Signature', 'Filename (trunc)', 'Reason'])); // noslz
              Progress.Log(format(GFORMAT_STR, ['', '------', '----', '-----', '---------', '----------------', '------'])); // noslz

              AllFoundList_count := AllFoundList.Count;
              Progress.Initialize(AllFoundList_count, SEARCHING_FOR_ARTIFACT_FILES_STR + ':' + SPACE + progress_program_str + RUNNING);
              for i := 0 to AllFoundList.Count - 1 do
              begin
                Progress.DisplayMessages := SEARCHING_FOR_ARTIFACT_FILES_STR + SPACE + '(' + IntToStr(i) + ' of ' + IntToStr(AllFoundList_count) + ')' + RUNNING;
                if not Progress.isRunning then
                  break;
                anEntry := TEntry(AllFoundList[i]);

                if (i mod 10000 = 0) and (i > 0) then
                begin
                  Progress.Log('Processing: ' + IntToStr(i) + ' of ' + IntToStr(AllFoundList.Count) + RUNNING);
                  Progress.Log(StringOfChar('-', CHAR_LENGTH));
                end;

                // Set the iTunes Domain String
                iTunes_Domain_str := '';
                if assigned(FieldItunesDomain) then
                begin
                  try
                    iTunes_Domain_str := FieldItunesDomain.AsString[anEntry];
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error reading iTunes Domain string');
                  end;
                end;

                // Set the iTunes Name String
                iTunes_Name_str := '';
                if assigned(FieldItunesName) then
                begin
                  try
                    iTunes_Name_str := FieldItunesName.AsString[anEntry];
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error reading iTunes Name string');
                  end;
                end;

                // Run the match
                aDeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
                if (anEntry.Extension <> 'db-shm') and (anEntry.Extension <> 'db-wal') and (aDeterminedFileDriverInfo.ShortDisplayName <> 'Sqlite WAL') and (aDeterminedFileDriverInfo.ShortDisplayName <> 'Sqlite SHM') then
                begin
                  if RegexMatch(anEntry.EntryName, regex_search_str, False) or RegexMatch(anEntry.FullPathName, regex_search_str, False) or FileSubSignatureMatch(anEntry) or RegexMatch(iTunes_Domain_str, regex_search_str, False) or
                    RegexMatch(iTunes_Name_str, regex_search_str, False) then
                  begin
                    // Sub Signature Match
                    if FileSubSignatureMatch(anEntry) then
                    begin
                      if USE_FLAGS_BL then
                        anEntry.Flags := anEntry.Flags + [Flag2]; // Blue Flag
                      DetermineThenSkipOrAdd(anEntry, iTunes_Domain_str, iTunes_Name_str);
                    end
                    else
                    begin
                      // Regex Name Match
                      if ((not anEntry.isDirectory) or (anEntry.isDevice)) and (anEntry.LogicalSize > 0) and (anEntry.PhysicalSize > 0) then
                      begin
                        if FileNameRegexSearch(anEntry, iTunes_Domain_str, iTunes_Name_str, regex_search_str) then
                        begin
                          if USE_FLAGS_BL then
                            anEntry.Flags := anEntry.Flags + [Flag1]; // Red Flag
                          DetermineThenSkipOrAdd(anEntry, iTunes_Domain_str, iTunes_Name_str);
                        end;
                      end;
                    end;
                  end;
                  Progress.IncCurrentprogress;
                end;
              end;
            end;
          finally
            AllFoundList.free;
          end;

          // Check to see if files were found
          if (TotalValidatedFileCountInTLists = 0) then
          begin
            Progress.Log('No ' + PROGRAM_NAME + SPACE + 'files were found.');
            Progress.DisplayTitle := 'Artifacts' + HYPHEN + PROGRAM_NAME + HYPHEN + 'Not found';
            Exit;
          end
          else
          begin
            Progress.Log(StringOfChar('-', CHAR_LENGTH + 80));
            Progress.Log(RPad('Total Validated Files:', RPAD_VALUE) + IntToStr(TotalValidatedFileCountInTLists));
            Progress.Log(StringOfChar('=', CHAR_LENGTH + 80));
          end;

          // Display the content of the TLists for further processing
          if (TotalValidatedFileCountInTLists > 0) and Progress.isRunning then
          begin
            Progress.Log('Lists available to process...');
            for n := 1 to NUMBEROFSEARCHITEMS do
            begin
              if not Progress.isRunning then
                break;
              Item := FileItems[n];
              if Arr_ValidatedFiles_TList[n].Count > 0 then
              begin
                Progress.Log(StringOfChar('-', CHAR_LENGTH));
                Progress.Log(RPad('TList ' + IntToStr(n) + ': ' + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type + HYPHEN + Item^.fi_Name_OS, RPAD_VALUE) + IntToStr(Arr_ValidatedFiles_TList[n].Count));
                for r := 0 to Arr_ValidatedFiles_TList[n].Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  anEntry := (TEntry(TList(Arr_ValidatedFiles_TList[n]).items[r]));
                  if not(Item^.fi_Process_As = 'POSTPROCESS') then
                    Progress.Log(RPad(' Bates: ' + IntToStr(anEntry.ID), RPAD_VALUE) + anEntry.EntryName + SPACE + Item^.fi_Process_As);
                end;
              end;
            end;
            Progress.Log(StringOfChar('-', CHAR_LENGTH + 80));
          end;

          // *** CREATE GUI ***
          if (TotalValidatedFileCountInTLists > 0) and Progress.isRunning then
          begin
            Progress.DisplayTitle := 'Artifacts' + HYPHEN + PROGRAM_NAME + HYPHEN + 'Found';

            // Create the Category Folder to the tree ----------------------------------
            ArtifactConnect_CategoryFolder := AddArtifactCategory(nil, CATEGORY_NAME, -1, FileItems[1].fi_Icon_Category); { Sort index, icon }
            ArtifactConnect_CategoryFolder.Status := ArtifactConnect_CategoryFolder.Status + [dstUserCreated];

            if (CmdLine.Params.Indexof(PROCESSALL) > -1) then
            begin
              for n := 1 to NUMBEROFSEARCHITEMS do
              begin
                if not Progress.isRunning then
                  break;

                Item := FileItems[n];
                if (Arr_ValidatedFiles_TList[n].Count > 0) or (Item^.fi_Process_As = 'POSTPROCESS') then
                begin
                  ArtifactConnect_ProgramFolder[n] := AddArtifactConnect(TEntry(ArtifactConnect_CategoryFolder),
                  Item^.fi_Name_Program,
                  Item^.fi_Name_Program_Type,
                  Item^.fi_Name_OS,
                  Item^.fi_Icon_Program,
                  Item^.fi_Icon_OS);
                  ArtifactConnect_ProgramFolder[n].Status := ArtifactConnect_ProgramFolder[n].Status + [dstUserCreated];
                end;
              end;
            end
            else
            begin
              if assigned(Parameter_Num_StringList) and (Parameter_Num_StringList.Count > 0) or (Item^.fi_Process_As = 'POSTPROCESS') then
              begin
                for n := 0 to Parameter_Num_StringList.Count - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  temp_int := StrToInt(Parameter_Num_StringList[n]); // temp_int becomes the parameter
                  Item := FileItems[temp_int];
                  if Arr_ValidatedFiles_TList[temp_int].Count > 0 then
                  begin
                    ArtifactConnect_ProgramFolder[temp_int] := AddArtifactConnect(TEntry(ArtifactConnect_CategoryFolder),
                    Item^.fi_Name_Program,
                    Item^.fi_Name_Program_Type,
                    Item^.fi_Name_OS,
                    Item^.fi_Icon_Program,
                    Item^.fi_Icon_OS);
                    ArtifactConnect_ProgramFolder[temp_int].Status := ArtifactConnect_ProgramFolder[temp_int].Status + [dstUserCreated];
                  end;
                end;
              end;
            end;
            Progress.Log('Process Lists' + RUNNING);
            Progress.Log(StringOfChar('-', CHAR_LENGTH));

            // *** DO PROCESS ***
            temp_process_counter := 0;
            Progress.CurrentPosition := 0;
            Progress.Max := TotalValidatedFileCountInTLists;
            gtick_doprocess_i64 := GetTickCount;

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Accounts.GetTable('ACCOUNTS_ANDROID'));
            Ref_Num := 2;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Accounts.GetTable('ACCOUNTS_IOS'));
            Ref_Num := 3;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleMaps.GetTable('APPLE_MAPS_SEARCHES_IOS'));
            Ref_Num := 4;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, ApplicationState_IOS.GetTable('APPLICATIONSTATE_IOS'));
            Ref_Num := 5;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Aquamail.GetTable('ANDROID'));
            Ref_Num := 6;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Bluetooth.GetTable('IOS_BLUETOOTH_DEVICES'));
            Ref_Num := 7;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Bluetooth.GetTable('IOS_BLUETOOTH_SEEN'));
            Ref_Num := 8;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, CachedLocations.GetTable('IOS'));
            Ref_Num := 9;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Calendar.GetTable('ANDROID'));
            Ref_Num := 10; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Calendar.GetTable('IOS3'));
            Ref_Num := 11; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Calendar.GetTable('IOS4'));
            Ref_Num := 12; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AndroidLogs.GetTable('ANDROID'));
            Ref_Num := 13; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Calls.GetTable('IOS3'));
            Ref_Num := 14; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Calls.GetTable('IOS12'));
            Ref_Num := 15; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, CellTowerLocations.GetTable('IOS_CELLTOWER'));
            Ref_Num := 16; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Contacts.GetTable('ANDROID3'));
            Ref_Num := 17; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Contacts.GetTable('ANDROID_MANAGER'));
            Ref_Num := 18; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Contacts.GetTable('IOS'));
            Ref_Num := 19; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Contacts.GetTable('IOS_RECENTS_RECENTS'));
            Ref_Num := 20; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Contacts.GetTable('IOS_RECENTS_CONTACTS'));
            Ref_Num := 21; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Dropbox.GetTable('IOS_METADATA_CACHE'));
            Ref_Num := 22; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Dropbox.GetTable('IOS_SPOTLIGHT_ITEMS'));
            Ref_Num := 23; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, DynamicDictionary.GetTable('IOS'));
            Ref_Num := 24; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Email.GetTable('ANDROID'));
            Ref_Num := 25; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Gmail.GetTable('ANDROID'));
            Ref_Num := 26; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GoogleMaps.GetTable('ANDROID'));
            Ref_Num := 27; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GoogleMaps.GetTable('IOS'));
            Ref_Num := 28; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GoogleMobile.GetTable('IOS'));
            Ref_Num := 29; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Google_Play.GetTable('GOOGLE_PLAY_INSTALLED_APPLICATIONS'));
            Ref_Num := 30; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Installed_Apps.GetTable('IOS_INSTALLED_APPS'));
            Ref_Num := 31; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Itunes.GetTable('IOS_PLIST'));
            Ref_Num := 32; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Itunes.GetTable('IOS_XML'));
            Ref_Num := 33; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Itunes.GetTable('IOS_SQL'));
            Ref_Num := 34; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Maps.GetTable('IOS'));
            Ref_Num := 35; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Notes.GetTable('IOS'));
            Ref_Num := 36; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Notes.GetTable('IOS2'));
            Ref_Num := 37; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, ParkedCarLocations.GetTable('IOS'));
            Ref_Num := 38; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, External_db_Android.GetTable('EXTERNAL_DB_ANDROID'));
            Ref_Num := 39; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Internal_db_Android.GetTable('INTERNAL_DB_ANDROID'));
            Ref_Num := 40; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Photos_sqlite_IOS.GetTable('PHOTOS_SQLITE_IOS'));
            Ref_Num := 41; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Picasa.GetTable('ANDROID'));
            Ref_Num := 42; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Private_Photo_Vault.GetTable('IOS_ALBUMS'));
            Ref_Num := 43; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Private_Photo_Vault.GetTable('IOS_MEDIA'));
            Ref_Num := 44; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, ScreenTimeAppUsage.GetTable('IOS'));
            Ref_Num := 45; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SignificantLocations.GetTable('IOS_LOCAL'));
            Ref_Num := 46; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SignificantLocations.GetTable('IOS_CLOUDV2'));
            Ref_Num := 47; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SignificantLocations.GetTable('IOS_LOCATIONVISITS'));
            Ref_Num := 48; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SMS.GetTable('ANDROID'));
            Ref_Num := 49; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SMS.GetTable('IOS3'));
            Ref_Num := 50; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SMS.GetTable('IOS4'));
            Ref_Num := 51; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Uber.GetTable('IOS_ACCOUNTS'));
            Ref_Num := 52; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Uber.GetTable('IOS_EYEBALL'));
            Ref_Num := 53; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Uber.GetTable('IOS_DATABASE'));
            Ref_Num := 54; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, UserDictionary.GetTable('IOS'));
            Ref_Num := 55; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, VoiceMail.GetTable('IOS'));
            Ref_Num := 56; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, VoiceMemos.GetTable('IOS'));
            Ref_Num := 57; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wifi.GetTable('WIFI_CONFIGURATIONS_SQLITE_ANDROID'));
            Ref_Num := 58; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wifi.GetTable('WIFI_CONFIGURATIONS_XML_ANDROID'));
            Ref_Num := 59; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wifi.GetTable('WIFI_FLATTENED_DATA_ANDROID'));
            Ref_Num := 60; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wifi.GetTable('WIFI_CONFIGURATIONS_IOS'));
            Ref_Num := 61; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WifiLocations.GetTable('IOS'));

            gtick_doprocess_str := (RPad('DoProcess:', RPAD_VALUE) + CalcTimeTaken(gtick_doprocess_i64));

            // Remove folders with zero
            PostProcess_Remove_Zero;
          end;

          if not Progress.isRunning then
          begin
            Progress.Log(CANCELED_BY_USER);
            Progress.DisplayMessageNow := CANCELED_BY_USER;
          end;

        finally
          for n := 1 to NUMBEROFSEARCHITEMS do
            FreeAndNil(Arr_ValidatedFiles_TList[n]);
        end;

      finally
        if assigned(FileSystemDataStore) then
          FreeAndNil(FileSystemDataStore);
      end;

    finally
      if assigned(ArtifactsDataStore) then
        FreeAndNil(ArtifactsDataStore);
    end;

  finally
    if assigned(Parameter_Num_StringList) then
      FreeAndNil(Parameter_Num_StringList);
  end;

  Progress.Log(StringOfChar('-', CHAR_LENGTH));
  Progress.Log(gtick_foundlist_str);
  Progress.Log(gtick_doprocess_str);
  Progress.Log(StringOfChar('-', CHAR_LENGTH));

  Progress.Log(SCRIPT_NAME + ' finished.');
  Progress.DisplayMessageNow := ('Processing complete.');

end.
