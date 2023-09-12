unit Artifacts_Chat;

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
  RS_DoNotTranslate   in 'Common\RS_DoNotTranslate.pas',
  //-----
  Android_Messages    in 'Common\Column_Arrays\Android_Messages.pas',
  Anti_Chat           in 'Common\Column_Arrays\Anti_Chat.pas',
  Badoo               in 'Common\Column_Arrays\Badoo.pas',
  Burner              in 'Common\Column_Arrays\Burner.pas',
  ByLock              in 'Common\Column_Arrays\ByLock.pas',
  Coco                in 'Common\Column_Arrays\Coco.pas',
  Couple_Relationship in 'Common\Column_Arrays\Couple_Relationship.pas',
  Discord             in 'Common\Column_Arrays\Discord.pas',
  Eagle               in 'Common\Column_Arrays\Eagle.pas',
  Fast_Hookup_Dating  in 'Common\Column_Arrays\Fast_Hookup_Dating.pas',
  FacebookMessenger   in 'Common\Column_Arrays\FacebookMessenger.pas',
  Gettr               in 'Common\Column_Arrays\Gettr.pas',
  Google_Duo          in 'Common\Column_Arrays\Google_Duo.pas',
  GoogleChat          in 'Common\Column_Arrays\GoogleChat.pas',
  GoogleVoice         in 'Common\Column_Arrays\GoogleVoice.pas',
  Grindr              in 'Common\Column_Arrays\Grindr.pas',
  GroupMe             in 'Common\Column_Arrays\GroupMe.pas',
  Growlr              in 'Common\Column_Arrays\Growlr.pas',
  HelloTalk           in 'Common\Column_Arrays\HelloTalk.pas',
  iMessage            in 'Common\Column_Arrays\iMessage.pas',
  IMO                 in 'Common\Column_Arrays\IMO.pas',
  Instagram           in 'Common\Column_Arrays\Instagram.pas',
  Kakao               in 'Common\Column_Arrays\Kakao.pas',
  Kik                 in 'Common\Column_Arrays\Kik.pas',
  Line                in 'Common\Column_Arrays\Line.pas',
  MeetMe              in 'Common\Column_Arrays\MeetMe.pas',
  MessageMe           in 'Common\Column_Arrays\MessageMe.pas',
  Messenger           in 'Common\Column_Arrays\Messenger.pas',
  MeWe                in 'Common\Column_Arrays\MeWe.pas',
  MSTeams             in 'Common\Column_Arrays\MSTeams.pas',
  Oovoo               in 'Common\Column_Arrays\Oovoo.pas',
  Random_Chat         in 'Common\Column_Arrays\Random_Chat.pas',
  Scruff              in 'Common\Column_Arrays\Scruff.pas',
  Skout               in 'Common\Column_Arrays\Skout.pas',
  Skype               in 'Common\Column_Arrays\Skype.pas',
  Slack               in 'Common\Column_Arrays\Slack.pas',
  Snapchat            in 'Common\Column_Arrays\Snapchat.pas',
  Tango               in 'Common\Column_Arrays\Tango.pas',
  Threema             in 'Common\Column_Arrays\Threema.pas',
  Telegram            in 'Common\Column_Arrays\Telegram.pas',
  TextNow             in 'Common\Column_Arrays\TextNow.pas',
  Tiktok              in 'Common\Column_Arrays\Tiktok.pas',
  Tinder              in 'Common\Column_Arrays\Tinder.pas',
  Touch               in 'Common\Column_Arrays\Touch.pas',
  Tumblr              in 'Common\Column_Arrays\Tumblr.pas',
  Venmo               in 'Common\Column_Arrays\Venmo.pas',
  Viber               in 'Common\Column_Arrays\Viber.pas',
  Whatsapp            in 'Common\Column_Arrays\Whatsapp.pas',
  Whisper             in 'Common\Column_Arrays\Whisper.pas',
  Wire                in 'Common\Column_Arrays\Wire.pas',
  Yahoo               in 'Common\Column_Arrays\Yahoo.pas',
  Zalo                in 'Common\Column_Arrays\Zalo.pas',
  Zello               in 'Common\Column_Arrays\Zello.pas',
  Zoom                in 'Common\Column_Arrays\Zoom.pas';

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
  CATEGORY_NAME             = 'Chat';
  CHAR_LENGTH               = 160;
  CHAT                      = 'Chat';
  COLON                     = ':';
  COMMA                     = ',';
  CONTACTS                  = 'Contacts';
  CR                        = #13#10;
  DCR                       = #13#10 + #13#10;
  DUP_FILE                  = '';
  FBN_ITUNES_BACKUP_DOMAIN  = 'iTunes Backup Domain'; //noslz
  FBN_ITUNES_BACKUP_NAME    = 'iTunes Backup Name'; //noslz
  FORMAT_STR                = '%-2s %-4s %-29s %-20s %-200s';
  FORMAT_STR_HDR            = '%-2s %-34s %-20s %-200s';
  GFORMAT_STR               = '%-1s %-12s %-8s %-15s %-25s %-30s %-20s';
  GROUP_NAME                = 'Artifact Analysis';
  HYPHEN                    = ' - ';
  HYPHEN_NS                 = '-';
  IOS                       = 'iOS'; //noslz
  MAX_CARVE_SIZE            = 1024 * 50;
  MIN_CARVE_SIZE            = 0;
  NUMBEROFSEARCHITEMS       = 155; //*******************************************
  PAD                       = '  ';
  PIPE                      = '|'; //noslz
  PRG_OOVOO                 = 'Oovoo'; //noslz
  PROCESS_AS_CARVE          = 'PROCESSASCARVE'; //noslz
  PROCESS_AS_PLIST          = 'PROCESSASPLIST'; //noslz
  PROCESS_AS_XML            = 'PROCESSASXML'; //noslz
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'Chat';
  RPAD_VALUE                = 65;
  RUNNING                   = '...';
  SCRIPT_DESCRIPTION        = 'Extract Chat Artifacts';
  SCRIPT_NAME               = 'Chat.pas';
  SPACE                     = ' ';
  STR_FILES_BY_PATH         = 'Files by path';
  TSWT                      = 'The script will terminate.';
  USE_FLAGS_BL              = False;
  VERBOSE                   = False;
  WINDOWS                   = 'Windows'; //noslz

  PBUFF_FIELD1 = 1;
  PBUFF_FIELD2 = 2;
  PBUFF_FIELD3 = 3;
  PBUFF_FIELD4 = 4;

var
  Arr_ValidatedFiles_TList:       array[1..NUMBEROFSEARCHITEMS] of TList;
  ArtifactConnect_ProgramFolder:  array[1..NUMBEROFSEARCHITEMS] of TArtifactConnectEntry;
  FileItems:                      array[1..NUMBEROFSEARCHITEMS] of PSQL_FileSearch;

  anEntry:                        TEntry;
  ArtifactConnect_CategoryFolder: TArtifactEntry1;
  ArtifactsDataStore:             TDataStore;
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
  n, r:                           integer;
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
    ( // ~1~ Android - Accounts - Android
    fi_Name_Program:               ANDROID;
    fi_Name_OS:                    'Accounts';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_ANDROID; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'contacts2\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ACCOUNTS','CONTACTS','DATA']; //noslz                                    1
    fi_SQLPrimary_Tablestr:        'ACCOUNTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM ACCOUNTS';
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~2~ Android - Call Logs - Android
    fi_Name_Program:               ANDROID;
    fi_Name_OS:                    'Call Logs';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_ANDROID; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'calllog\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CALLS','ANDROID_METADATA','PROPERTIES']; //noslz
    fi_SQLPrimary_Tablestr:        'CALLS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CALLS';
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~3~ Android - Messages - Android
    fi_Name_Program:               ANDROID;
    fi_Name_OS:                    'Messages';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_ANDROID; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'bugle_db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','PARTS','PARTICIPANTS']; //noslz
    fi_SQLPrimary_Tablestr:        'messages'; //noslz
    fi_SQLStatement:               'SELECT * FROM messages';
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~4~ AntiChat - Chat - iOS
    fi_Name_Program:               'AntiChat';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: ICON_ANTICHAT; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'Secret_Messenger\.sqlite' + DUP_FILE + '|^48f650054c84eea30ec425ca313d27fdd9a628c5' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.NH\.Secret-Messenger$';
    fi_Regex_Itunes_Backup_Name:   '^Library\/Application Support\/Stores\/Secret_Messenger\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMESSAGES';
    fi_Test_Data:                  ''),

    ( // ~5~ Badoo - Chat - Android
    fi_Name_Program:               'Badoo';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_BADOO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^Chaton\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGESCACHE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGESCACHE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGESCACHE'),

    ( // ~6~ Burner - Cache - iOS
    fi_Name_Program:               'Burner';
    fi_Name_Program_Type:          'Cache';
    fi_Process_ID:                 'DNT_BURNER_IOS_MESSAGES';
    fi_Name_OS:                    IOS; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: 1165; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'burner\\Cache\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CFURL_CACHE_RECEIVER_DATA','CFURL_CACHE_RESPONSE']; //noslz
    fi_SQLPrimary_Tablestr:        'cfurl_cache_receiver_data'; //noslz
    fi_SQLStatement:               'SELECT * FROM cfurl_cache_receiver_data';
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~7~ Burner - Contacts - Android
    fi_Name_Program:               'Burner';
    fi_Name_Program_Type:          'Contacts';
    fi_Process_ID:                 'DNT_BURNER_MESSAGES_ANDROID';
    fi_Name_OS:                    ANDROID; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: 1165; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^burners\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CONTACTS','MESSAGES','BURNERS']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONTACTS';
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~8~ Burner - Contacts - iOS
    fi_Name_Program:               'Burner';
    fi_Name_Program_Type:          CONTACTS;
    fi_Process_ID:                 'DNT_BURNER_IOS_CONTACTS';
    fi_Name_OS:                    IOS; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: 1165; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'burner\\Cache\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CFURL_CACHE_RECEIVER_DATA','CFURL_CACHE_RESPONSE']; //noslz
    fi_SQLPrimary_Tablestr:        'cfurl_cache_receiver_data'; //noslz
    fi_SQLStatement:               'SELECT * FROM cfurl_cache_receiver_data';
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~9~ Burner - Messages - Android
    fi_Name_Program:               'Burner';
    fi_Name_Program_Type:          'Messages';
    fi_Process_ID:                 'DNT_BURNER_MESSAGES_ANDROID';
    fi_Name_OS:                    ANDROID; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: 1165; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^burners\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','CONTACTS', 'BURNERS']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES';
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~10~ Burner - Messages - iOS
    fi_Name_Program:               'Burner';
    fi_Name_Program_Type:          'Messages';
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_BURNER_IOS_CACHE_MESSAGES';
    fi_Name_OS:                    IOS; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: 1165; fi_Icon_OS: ICON_IOS;
    fi_NodeByName:                 '[]';
    fi_Regex_Search:               'com\.adhoclabs\.burner\\fsCachedData\\' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_JSON;
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~11~ Burner - Numbers - Android
    fi_Name_Program:               'Burner';
    fi_Name_Program_Type:          'Numbers';
    fi_Process_ID:                 'DNT_BURNER_NUMBERS_ANDROID';
    fi_Name_OS:                    ANDROID; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: 1165; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^burners\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['BURNERS','CONTACTS','MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'BURNERS'; //noslz
    fi_SQLStatement:               'SELECT * FROM BURNERS';
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~12~ ByLock - AppPrefFile - Android
    fi_Process_As:                 PROCESS_AS_XML;
    fi_Process_ID:                 'DNT_BYLOCK_APPPREFFILE';
    fi_Name_Program:               'ByLock';
    fi_Name_Program_Type:          'AppPrefFile';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_BYLOCK; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'by\.lock.*\\AppPrefFile.xml' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_XML;
    fi_NodeByName:                 RS_DNT_MAP),

    ( // ~13~ Coco - Chat - Android
    fi_Name_Program:               'Coco';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_COCO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'CoCo\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'CoCo Android';
    fi_SQLTables_Required:         ['CHATMESSAGEMODEL','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'CHATMESSAGEMODEL'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHATMESSAGEMODEL'),

    ( // ~14~ Coco - Chat - iOS
    fi_Name_Program:               'Coco';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_COCO; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'CoCo\.db' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.instanza\.CoCo$';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/52291408\/CoCo\.db$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'CoCo iOS';
    fi_SQLTables_Required:         ['ZCHATMESSAGEENTITY','ZCONTACTENTITY']; //noslz
    fi_SQLPrimary_Tablestr:        'ZCHATMESSAGEENTITY'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZCHATMESSAGEENTITY'),

    ( // ~15~ Coco - Contact - iOS
    fi_Name_Program:               'Coco';
    fi_Name_Program_Type:          'Contact';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_COCO; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'CoCo\.db' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.instanza\.CoCo$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/52291408\/CoCo\.db$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'CoCo iOS'; //noslz
    fi_SQLTables_Required:         ['ZCONTACTENTITY','ZCHATMESSAGEENTITY']; //noslz
    fi_SQLPrimary_Tablestr:        'ZCONTACTENTITY'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZCONTACTENTITY'), //noslz

    ( // ~16~ Coco - Friend - Android
    fi_Name_Program:               'Coco';
    fi_Name_Program_Type:          'Friend';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_COCO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'coco\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'CoCo Android';
    fi_SQLTables_Required:         ['FRIENDMODEL','CHATMESSAGEMODEL','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'FRIENDMODEL'; //noslz
    fi_SQLStatement:               'SELECT * FROM FRIENDMODEL'),

    ( // ~17~ Coco - Friend - iOS
    fi_Name_Program:               'Coco';
    fi_Name_Program_Type:          'Friend';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_COCO; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'CoCo\.db' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.instanza\.CoCo$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/52291408\/CoCo\.db$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'CoCo iOS'; //noslz
    fi_SQLTables_Required:         ['ZFRIENDENTITY','ZCONTACTENTITY','ZCHATMESSAGEENTITY']; //noslz
    fi_SQLPrimary_Tablestr:        'ZFRIENDENTITY'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZFRIENDENTITY'), //noslz

    ( // ~18~ Coco - User - Android
    fi_Name_Program:               'Coco';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_COCO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'coco\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'CoCo Android';
    fi_SQLTables_Required:         ['USERMODEL','CHATMESSAGEMODEL','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'USERMODEL'; //noslz
    fi_SQLStatement:               'SELECT * FROM USERMODEL'),

    ( // ~19~ Couple Relationship - Chat - iOS
    fi_Name_Program:               'Couple Relationship'; //https://itunes.apple.com/us/app/couple-relationship-app-for-two/id503663173?mt=8
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT;
    fi_Icon_Program: ICON_COUPLE_RELATIONSHIP;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               'Juliet\.sqlite' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.tenthbit\.Juliet$';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/Juliet\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZJUEVENT','ZJUUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZJUEVENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZJUEVENT'), //noslz

    ( // ~20~ Discord - Chat - iOS
    fi_Name_Program:               'Discord';
    fi_Name_Program_Type:          CHAT;
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_DISCORD_JSON';
    fi_Name_OS:                    IOS; fi_Icon_Category: ICON_CHAT; fi_Icon_Program: ICON_DISCORD; fi_Icon_OS: ICON_IOS;
    fi_NodeByName:                 '[]'; //noslz
    fi_Regex_Search:               '\.discord\\fsCachedData\\.{8}\-.{4}\-.{4}\-.{4}\-.{12}'; //noslz
    fi_Signature_Parent:           RS_SIG_JSON;
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~21~ Facebook Messenger - Chat
    fi_Name_Program:               'Facebook Messenger';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1174; fi_Icon_OS: ICON_IOS; //noslz
    fi_Regex_Search:               '^lightspeed-.*\.db|\\lightspeed-userDatabases\\.*\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','APPOINTMENTS','ATTACHMENTS']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'; //noslz
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~22~ Facebook Messenger - Calls - Android
    fi_Name_Program:               'Facebook Messenger';
    fi_Name_Program_Type:          'Calls';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1174; fi_Icon_OS: ICON_ANDROID; //noslz
    fi_Process_ID:                 'DNT_FACEBOOK_MESSENGER_CALL_LOGS_DB';
    fi_Regex_Search:               '^call_logs_db_.*' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['USER_TABLE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'USER_TABLE'; //noslz
    fi_SQLStatement:               'SELECT * FROM USER_TABLE'; //noslz
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~23~ Facebook Messenger - Threads - iOS
    fi_Name_Program:               'Facebook Messenger';
    fi_Name_Program_Type:          'Threads';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1174; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^lightspeed-.*\.db|lightspeed-userDatabases\\.*\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['THREADS','APPOINTMENTS','ATTACHMENTS']; //noslz
    fi_SQLPrimary_Tablestr:        'THREADS'; //noslz
    fi_SQLStatement:               'SELECT * FROM THREADS'; //noslz
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~24~ Fast Hookup Dating - Chat - iOS
    fi_Name_Program:               'Fast Hookup Dating';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_FASTHOOKUPDATING; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'swidating\.sqlite' + DUP_FILE + '|^38205aeab9a92aab612bea82cb344ad6a3d506f9' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.wdys\.fasthookupdating$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/swidating\.sqlite$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              '';
    fi_SQLTables_Required:         ['KFMDB_TABLENAME_CHATINGRECORD']; //noslz
    fi_SQLPrimary_Tablestr:        'KFMDB_TABLENAME_CHATINGRECORD'; //noslz
    fi_SQLStatement:               'SELECT * FROM kFMDB_Tablename_ChatingRecord'), //noslz

    ( // ~25~ Fast Hookup Dating - User - iOS
    fi_Name_Program:               'Fast Hookup Dating';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_FASTHOOKUPDATING; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'swidating\.sqlite' + DUP_FILE + '|^38205aeab9a92aab612bea82cb344ad6a3d506f9' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.wdys\.fasthookupdating$';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/swidating\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['KFMDB_TABLENAME_ALLSIGNINUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'KFMDB_TABLENAME_ALLSIGNINUSER'; //noslz
    fi_SQLStatement:               'SELECT * FROM KFMDB_TABLENAME_ALLSIGNINUSER'), //noslz

    ( // ~26~ Gettr - Chat - Android
    fi_Name_Program:               'Gettr';
    fi_Process_ID:                 'DNT_GETTR';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1210; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^db_.*\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MEMBERS','MESSAGES','USERS','CHANNELS']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES';
    fi_Test_Data:                  'Digital Corpa 13'),

    ( // ~27~ Google Duo - Chat - Android
    fi_Name_Program:               'Google Duo';
    fi_Process_ID:                 'DNT_GOOGLE_DUO';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1164; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tachyon\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ACTIVITY_HISTORY','ANDROID_METADATA','MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'ACTIVITY_HISTORY'; //noslz
    fi_SQLStatement:               'SELECT * FROM ACTIVITY_HISTORY';
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~28~ Google Duo - Chat - iOS
    fi_Name_Program:               'Google Duo';
    fi_Process_ID:                 'DNT_GOOGLE_DUO';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1164; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '\\Application Support\\DataStore' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CALL_HISTORY','CONTACT','INBOX_MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'CALL_HISTORY'; //noslz
    fi_SQLStatement:               'SELECT * FROM CALL_HISTORY';
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~29~ Google Duo - Users - iOS
    fi_Name_Program:               'Google Duo';
    fi_Process_ID:                 'DNT_GOOGLE_DUO_USERS';
    fi_Name_Program_Type:          'Users';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1164; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '\\Application Support\\DataStore' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CONTACT','CALL_HISTORY','INBOX_MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACT'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONTACT';
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~30~ Google - Chat - {Android & iOS}
    fi_Name_Program:               'Google';
    fi_Process_ID:                 'DNT_GOOGLE_CHAT';
    fi_Name_Program_Type:          'Chat';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1211; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'dynamite\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['TOPIC_MESSAGES','USERS']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACT'; //noslz
    fi_SQLStatement:               'SELECT * FROM TOPIC_MESSAGES';
    fi_Test_Data:                  'Digital Corpa 15'),

    ( // ~31~ Google - Chat - JSON Takeout
    fi_Name_Program:               'Google';
    fi_Name_Program_Type:          'Chat (JSON Takeout)';
    fi_Process_ID:                 'DNT_GOOGLE_CHAT_JSON_TAKEOUT';
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1211; fi_Icon_OS: ICON_GOOGLE;
    fi_Regex_Search:               'messages\.json' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_JSON;
    fi_RootNodeName:               'JSON Tree'; //noslz
    fi_NodeByName:                 'messages []'), //noslz

    ( // ~32~ Google - Voice - Android
    fi_Name_Program:               'Google';
    fi_Name_Program_Type:          'Voice';
    fi_Name_OS:                    ANDROID;
    fi_Process_ID:                 'GOOGLE_VOICE_ANDROID';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1215; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^LegacyMsgDbInstance\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE_T','ANDROID_METADATA','LABEL_T']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE_T'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE_T'), //noslz

    ( // ~33~ Grindr - Chat - Android
    fi_Name_Program:               'Grindr';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GRINDR; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^grindr3\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHATTABLE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'CHATTABLE'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHATTABLE'), //noslz

    ( // ~34~ Grindr - Chat - iOS
    fi_Name_Program:               'Grindr';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GRINDR; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'grindr\.sqlite' + DUP_FILE + '|^fa203d03ede5bf6e39a7425de0a77bd785494281' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHATMESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'CHATMESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHATMESSAGES'), //noslz

    ( // ~35~ Grindr - Preferences - Android
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_GRINDR_PREFERENCES';
    fi_Name_Program:               'Grindr';
    fi_Name_Program_Type:          'Preferences';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GRINDR; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'grindrapp.*\\shared_preferences\.xml' + DUP_FILE;
    fi_Signature_Parent:           'XML';
    fi_NodeByName:                 RS_DNT_MAP), //noslz

    ( // ~36~ GroupMe - Chat - JSON
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_GROUPME_JSON';
    fi_Name_Program:               'GroupMe';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    'JSON'; //noslz
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GROUPME; fi_Icon_OS: ICON_CHAT;
    fi_Regex_Search:               'groupme'; //noslz
    fi_Signature_Parent:           RS_SIG_JSON;
    fi_RootNodeName:               'JSON Tree'; //noslz
    fi_NodeByName:                 '[]'), //noslz

    ( // ~37~ GroupMe - Chat - Android
    fi_Name_Program:               'GroupMe';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GROUPME; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'groupme\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','MEMBERS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~38~ GroupMe - Chat - iOS
    fi_Name_Program:               'GroupMe';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GROUPME; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'groupme\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZGMMESSAGE','ZGMCHAT','ZGMATTACHMENT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZGMMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZGMMESSAGE'), //noslz

    ( // ~39~ GroupMe - Contacts - Android
    fi_Name_Program:               'GroupMe';
    fi_Name_Program_Type:          'Contacts';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GROUPME; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'groupme\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['RELATIONSHIPS','MESSAGES','MEMBERS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'RELATIONSHIPS'; //noslz
    fi_SQLStatement:               'SELECT * FROM RELATIONSHIPS'), //noslz

    ( // ~40~ Growlr - Chat - Android
    fi_Name_Program:               'Growlr';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GROWLR; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^growlr\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHATMESSAGE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'CHATMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHATMESSAGE'), //noslz

    ( // ~41~ Growlr - Chat - iOS
    fi_Name_Program:               'Growlr';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_GROWLR; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'Documents\\db\.sqlite' + DUP_FILE + '|^184a40886306f67d58870851860d68b2b62e985c' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.initechapps.growlr$';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/db\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZCHATMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZCHATMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZCHATMESSAGE'), //noslz

    ( // ~42~ HelloTalk - Chat - iOS
    fi_Name_Program:               'HelloTalk';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_HELLOTALK; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'HelloTalk\.sqlite' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.helloTalk\.helloTalk$';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/2531974\/Backup\/HelloTalk\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['HTMESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'HTMESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM HTMESSAGES'), //noslz

    ( // ~43~ iMessage - Attachments - OSX
    fi_Name_Program:               'iMessage';
    fi_Name_Program_Type:          'Attachments';
    fi_Name_OS:                    'OSX';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1109; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^chat\.db' + DUP_FILE + '|3d0d7e5fb2ce288813306e4d4636395e047a3d28';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'SMS iOS v4';
    fi_SQLTables_Required:         ['ATTACHMENT','CHAT','MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ATTACHMENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM ATTACHMENT'), //noslz

    ( // ~44~ iMessage - Message - OSX
    fi_Name_Program:               'iMessage';
    fi_Name_Program_Type:          'Message';
    fi_Name_OS:                    'OSX';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1109; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^chat\.db' + DUP_FILE + '|3d0d7e5fb2ce288813306e4d4636395e047a3d28';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'SMS iOS v4';
    fi_SQLTables_Required:         ['MESSAGE','CHAT','ATTACHMENT']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'), //noslz

    ( // ~45~ IMO - Calls - Android
    fi_Name_Program:               'IMO';
    fi_Name_Program_Type:          'Calls';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1163; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'imofriends\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CALLS_ONLY','MESSAGES','FRIENDS']; //noslz
    fi_SQLPrimary_Tablestr:        'CALLS_ONLY'; //noslz
    fi_SQLStatement:               'SELECT * FROM CALLS_ONLY'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~46~ IMO - Chat - Android
    fi_Name_Program:               'IMO';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1163; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'imofriends\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','CALLS_ONLY','FRIENDS']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~47~ IMO - Chat - iOS
    fi_Name_Program:               'IMO'; //https://www.scribd.com/document/515580424/Network-Forensic-of-Imo
    fi_Name_Program_Type:          CHAT;
    fi_Process_ID:                 'DNT_IMO_CHAT_IOS';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1163; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'IMODb2\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZIMOCHATMSG','ZIMOCONTACT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZIMOCHATMSG'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZIMOCHATMSG'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~48~ IMO - Contacts - Android
    fi_Name_Program:               'IMO';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1163; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'imofriends\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['FRIENDS','CALLS_ONLY','MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'FRIENDS'; //noslz
    fi_SQLStatement:               'SELECT * FROM FRIENDS'), //noslz

    ( // ~49~ IMO - Contacts - iOS
    fi_Name_Program:               'IMO';
    fi_Name_Program_Type:          CONTACTS;
    fi_Process_ID:                 'DNT_IMO_CONTACTS_IOS';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1163; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'IMODb2\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZIMOCONTACT','ZIMOCHATMSG']; //noslz
    fi_SQLPrimary_Tablestr:        'ZIMOCONTACT'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZIMOCONTACT';
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~50~ Instagram - Chat - Android
    fi_Name_Program:               'Instagram';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_INSTAGRAM; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '\\com.instagram\.android\\databases\\direct\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'; //noslz
    fi_Test_Data:                  'GDH-ANDROID'), //noslz

    ( // ~51~ Instagram - Contacts - iOS
    fi_Process_As:                 PROCESS_AS_CARVE;
    fi_Process_ID:                 'DNT_INSTAGRAM_CONTACTS';
    fi_Name_Program:               'Instagram';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE; fi_Icon_Program: ICON_INSTAGRAM; fi_Icon_OS: ICON_IOS;
    fi_Regex_Itunes_Backup_Domain: '^AppDomainGroup-group\.com\.burbn\.instagram$';
    fi_Regex_Itunes_Backup_Name:   '^shared_bootstraps\/bootstrap-';
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY;
    fi_Carve_Header:               '\x08\x80\x0D\x08\x80\x00\x08\x08\x08\x80\x00\x08\x08\x80\x00\x80\x00\x80\x00\x80\x00\x09\x08\x08\x80\x00\x08\x80\x00';
    fi_Carve_Footer:               '\x08\x80\x0D\x08\x80\x00\x08\x08\x08\x80\x00\x08\x08\x80\x00\x80\x00\x80\x00\x80\x00\x09\x08\x08\x80\x00\x08\x80\x00';
    fi_Carve_Adjustment:           29; //noslz
    fi_Test_Data:                  'TGH-JAH'), //noslz

    ( // ~52~ Instagram Direct Messages - Chat - iOS
    fi_Process_ID:                 'DNT_INSTAGRAM_DIRECT';
    fi_Name_Program:               'Instagram';
    fi_Name_Program_Type:          'Direct Message' + SPACE + CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1146; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'DirectSQLiteDatabase\\.*\.db|a7956a96ecd77d922d2450f08a99eb645147e86e' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.burbn\.instagram$'; //noslz
    fi_Regex_Itunes_Backup_Name:   'Library\/Application Support\/DirectSQLiteDatabase\/.*\.db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','THREADS']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'; //noslz
    fi_Test_Data:                  'TGH-WHITE'), //noslz

    ( // ~53~ Instagram - Group Members - iOS
    fi_Process_ID:                 'DNT_INSTAGRAM_GROUPS';
    fi_Name_Program:               'Instagram';
    fi_Name_Program_Type:          ' Group Members' + SPACE + CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1146; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'DirectSQLiteDatabase\\.*\.db|a7956a96ecd77d922d2450f08a99eb645147e86e' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.burbn\.instagram$'; //noslz
    fi_Regex_Itunes_Backup_Name:   'Library\/Application Support\/DirectSQLiteDatabase\/.*\.db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['THREADS','MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM THREADS'; //noslz
    fi_Test_Data:                  'TGH-WHITE, Digital Corpa 15'), //noslz

    ( // ~54~ Instagram - Users - Android
    fi_Process_As:                 PROCESS_AS_XML;
    fi_Process_ID:                 'DNT_INSTAGRAM_USERS';
    fi_Name_Program:               'Instagram';
    fi_Name_Program_Type:          'Users';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_INSTAGRAM; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'com.instagram\.android_preferences\.xml' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_XML;
    fi_NodeByName:                 RS_DNT_MAP;
    fi_Test_Data:                  'The Android Test Folder'), //noslz

    ( // ~55~ Kakao - Chat - Android
    fi_Name_Program:               'Kakao';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KAKAO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'KakaoTalk\.db';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHAT_LOGS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'CHAT_LOGS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHAT_LOGS'), //noslz

    ( // ~56~ Kakao - Chat - iOS
    fi_Name_Program:               'Kakao';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KAKAO; fi_Icon_OS: ICON_IOS;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.iwilab.KakaoTalk$';
    fi_Regex_Itunes_Backup_Name:   '^Library\/PrivateDocuments\/Message\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE','DECRYPTINGMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'), //noslz

    ( // ~57~ Kik - Attachments - iOS
    fi_Name_Program:               'Kik';
    fi_Name_Program_Type:          'Attachments';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KIK; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'kikdatabase\.db' + DUP_FILE + 'kik\.sqlite' + DUP_FILE + '|^8e281be6657d4523710d96341b6f86ba89b56df7' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Kik iOS'; //noslz
    fi_SQLTables_Required:         ['ZKIKATTACHMENT','ZKIKMESSAGE','ZKIKCHAT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZKIKATTACHMENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZKIKATTACHMENT'), //noslz

    ( // ~58~ Kik - Attachments - Android
    fi_Name_Program:               'Kik';
    fi_Name_Program_Type:          'Attachments';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KIK; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'kikdatabase\.db' + DUP_FILE + 'kik\.sqlite' + DUP_FILE + '|^8e281be6657d4523710d96341b6f86ba89b56df7' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Kik Android'; //noslz
    fi_SQLTables_Required:         ['KIKContentTable','KIKContactsTable']; //noslz
    fi_SQLPrimary_Tablestr:        'KIKContentTable'; //noslz
    fi_SQLStatement:               'SELECT * FROM KIKContentTable'), //noslz

    ( // ~59~ Kik - Chat - Android
    fi_Name_Program:               'Kik';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KIK; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'kikdatabase\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Kik Android';
    fi_SQLTables_Required:         ['MESSAGESTABLE','KIKCONTACTSTABLE']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGESTABLE'; //noslz
    fi_SQLStatement:               'SELECT messagesTable.*, KIKcontactsTable.display_name FROM messagesTable LEFT OUTER JOIN KIKcontactsTable ON KIKcontactsTable.jid = messagesTable.partner_jid'),  // Android

    ( // ~60~ Kik - Chat - iOS
    fi_Name_Program:               'Kik';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KIK; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'kikdatabase\.db' + DUP_FILE + 'kik\.sqlite' + DUP_FILE + '|^8e281be6657d4523710d96341b6f86ba89b56df7' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Kik iOS'; //noslz
    fi_SQLTables_Required:         ['ZKIKUSER','ZKIKMESSAGE','ZKIKCHAT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZKIKUSER'; //noslz
    fi_SQLStatement:               'SELECT ZKIKUSER.Z_PK, ZKIKUSER.ZDISPLAYNAME, ZKIKUSER.ZUSERNAME, ZKIKMESSAGE.ZBODY, ZKIKMESSAGE.ZTIMESTAMP, ZKIKMESSAGE.ZTYPE FROM ZKIKUSER, ZKIKMESSAGE WHERE ZCHATUSER >=1 AND ZKIKUSER.Z_PK = ZKIKMESSAGE.ZUSER'),

    ( // ~61~ Kik - Contacts - Android // Kik - https://researchonline.gcu.ac.uk/ws/files/24282895/K.Ovens_revisedKMOvensManuscript3_2.pdf
    fi_Name_Program:               'Kik';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KIK; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'kikdatabase\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Kik Android';
    fi_SQLTables_Required:         ['KIKCONTACTSTABLE']; //noslz
    fi_SQLPrimary_Tablestr:        'KIKCONTACTSTABLE'; //noslz
    fi_SQLStatement:               'SELECT * FROM KIKCONTACTSTABLE'),  //noslz Android

    ( // ~62~ Kik - Contacts - iOS
    fi_Name_Program:               'Kik';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_KIK; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'kikdatabase\.db' + DUP_FILE + 'kik\.sqlite' + DUP_FILE + '|^8e281be6657d4523710d96341b6f86ba89b56df7' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Kik iOS'; //noslz
    fi_SQLTables_Required:         ['ZKIKUSER','ZKIKMESSAGE','ZKIKCHAT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZKIKUSER'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZKIKUSER'), //noslz

    ( // ~63~ Line - Chat - Android
    fi_Name_Program:               'Line';
    fi_Name_Program_Type:          CHAT;
    fi_Process_ID:                 'DNT_LINE_ANDROID_CHAT';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_LINE; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^naver_line' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHAT_HISTORY','CONTACTS']; //noslz
    fi_SQLPrimary_Tablestr:        'CHAT_HISTORY'; //noslz
    fi_SQLStatement:               'SELECT chat_history.*, contacts.m_id, contacts.name FROM chat_history left outer JOIN contacts ON chat_history.from_mid = contacts.m_id';
    fi_Reference_Info:             'https://www.researchgate.net/publication/287997487_LINE_IM_app_Forensic_Analysis';
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~64~ Line - Chat - iOS = #2
    fi_Name_Program:               'Line';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_LINE; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Line\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Line iOS'; //noslz
    fi_SQLTables_Required:         ['ZMESSAGE','ZCONTACT','ZGROUP','ZMESSAGEMETADATA','ZUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT ZMESSAGE.*, ZUSER.ZNAME FROM ZMESSAGE LEFT OUTER JOIN ZUSER ON ZUSER.Z_PK = ZMESSAGE.ZSENDER';
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~65~ Line - Contacts - Android
    fi_Name_Program:               'Line';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_LINE; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^naver_line' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHAT','CONTACTS']; //noslz
    fi_SQLPrimary_Tablestr:         CATEGORY_NAME; //noslz
    fi_SQLStatement:               'SELECT chat.*, contacts.name,contacts.server_name from chat left join contacts on chat.last_from_mid = contacts.m_id';
    fi_Reference_Info:             'https://www.researchgate.net/publication/287997487_LINE_IM_app_Forensic_Analysis'),

    ( // ~66~ Line - Contacts - iOS
    fi_Name_Program:               'Line';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_LINE; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Line\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Line iOS'; //noslz
    fi_SQLTables_Required:         ['ZUSER','ZMESSAGE','ZCONTACT','ZGROUP','ZMESSAGEMETADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ZUSER'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZUSER'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~67~ Line - Talk - iOS
    fi_Name_Program:               'Line';
    fi_Name_Program_Type:          'Talk';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_LINE; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Talk\.SQlite' + DUP_FILE + '|534a7099b474f4fb3f2cd006f8e59578d58fb44a' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Line iOS'; //noslz
    fi_SQLTables_Required:         ['ZMESSAGE','ZUSER','ZCONTACT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT ZMESSAGE.*, ZUSER.ZNAME FROM ZMESSAGE LEFT OUTER JOIN ZUSER ON ZUSER.Z_PK = ZMESSAGE.ZSENDER'),

    ( // ~68~ MeetMe - Chat - iOS
    fi_Name_Program:               'MeetMe';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_MEETME; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'MeetMeChat\.sqlite' + DUP_FILE + '|^a9acfd3f452d866c560408954eefb7c699386e09' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.myYearbook\.MyYearbook$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Library\/Database\/MeetMeChat\.sqlite$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZCHATMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZCHATMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZCHATMESSAGE'), //noslz

    ( // ~69~ MessageMe - Chat - iOS
    fi_Name_Program:               'MessageMe';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_MESSAGEME; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^MessageMe\.SQlite' + DUP_FILE + '|^8c625842c0b74fefff30d92eece44a1da30d2e8e' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'MessageMe iOS'; //noslz
    fi_SQLTables_Required:         ['ZMMMESSAGE','ZCONTACT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMMMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT ZMMMESSAGE.*, ZCONTACT.ZFIRSTNAME, ZCONTACT.ZLASTNAME, ZCONTACT.ZPIN FROM ZMMMESSAGE LEFT OUTER JOIN ZCONTACT ON ZCONTACT.Z_PK = ZMMMESSAGE.ZSENDER ORDER BY ZMMMESSAGE.ZSORTTIME'),

    ( // ~70~ Messenger - Call Log - Android
    fi_Name_Program:               'Messenger';
    fi_Name_Program_Type:          'Call Log';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE; fi_Icon_Program: ICON_MESSENGER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^call_log\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PERSON_SUMMARY','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'PERSON_SUMMARY'; //noslz
    fi_SQLStatement:               'SELECT * FROM PERSON_SUMMARY'), //noslz

    ( // ~71~ Messenger - Chat - Android
    fi_Name_Program:               'Messenger';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE; fi_Icon_Program: ICON_MESSENGER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^threads_db2' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~72~ Messenger - Chat - iOS and PC
    fi_Name_Program:               'Messenger';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_MESSENGER; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^orca.\.db' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomainGroup-group\.com\.facebook\.Messenger';
    fi_Regex_Itunes_Backup_Name:   '\/messenger_messages.v.\/orca.\.db$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Messenger iOS'; //noslz
    fi_SQLTables_Required:         ['MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'; //noslz
    fi_Test_Data:                  'TGHNF'), //noslz

    ( // ~73~ Messenger - Contacts - Android
    fi_Name_Program:               'Messenger';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE; fi_Icon_Program: ICON_MESSENGER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^contacts_db2' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CONTACTS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONTACTS'), //noslz

    ( // ~74~ Messenger - Threads - Android
    fi_Name_Program:               'Messenger';
    fi_Name_Program_Type:          'Threads';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE; fi_Icon_Program: ICON_MESSENGER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^threads_db2' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['THREAD_USERS','ANDROID_METADATA','THREAD_PARTICIPANTS']; //noslz
    fi_SQLPrimary_Tablestr:        'THREAD_USERS'; //noslz
    fi_SQLStatement:               'SELECT * FROM THREAD_USERS'), //noslz

    ( // ~75~ MeWe - Chat - Android
    fi_Name_Program:               'MeWe';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1181; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^app_database' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHAT_MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'CHAT_MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHAT_MESSAGE'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~76~ Microsoft Teams - Chat - Android - https://onlinelibrary.wiley.com/doi/pdf/10.1111/1556-4029.15208
    fi_Name_Program:               'Microsoft Teams';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Process_ID:                 'DNT_MSTEAMS_CHAT';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_MSTEAMS; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^SkypeTeams\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE','USER','CONTACT']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'; //noslz
    fi_Test_Data:                  'Digital Corpa Android 13'), //noslz

    ( // ~77~ Microsoft Teams - Chat - iOS - https://onlinelibrary.wiley.com/doi/full/10.1111/1556-4029.15208
    fi_Name_Program:               'Microsoft Teams';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Process_ID:                 'DNT_MSTEAMS_CHAT_IOS';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_MSTEAMS; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^SkypeSpacesDogfood-.*\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZSMESSAGE','ZUSER','ZCONTACT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZSMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZSMESSAGE'; //noslz
    fi_Test_Data:                  'Digital Corpa Android 15'), //noslz

    ( // ~78~ Microsoft Teams - User - Android - https://onlinelibrary.wiley.com/doi/pdf/10.1111/1556-4029.15208
    fi_Name_Program:               'Microsoft Teams';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_MSTEAMS; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^SkypeTeams\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['USER','CONTACT','MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'USER'; //noslz
    fi_SQLStatement:               'SELECT * FROM USER'; //noslz
    fi_Test_Data:                  'Digital Corpa Android 13'), //noslz

    ( // ~79~ ooVoo - User - Android
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_OOVOO_USER';
    fi_Name_Program:               PRG_OOVOO;
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_OOVOO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'com\.oovoo_preferences\.xml'; //noslz
    fi_Signature_Parent:           RS_SIG_XML;
    fi_NodeByName:                 RS_DNT_MAP;
    fi_Test_Data:                  'JT'), //noslz

    ( // ~80~ ooVoo - User - iOS
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_OOVOO_USER';
    fi_Name_Program:               PRG_OOVOO;
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_OOVOO; fi_Icon_OS: ICON_IOS;
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.oovoo\.iphone\.free$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Library\/Preferences\/com.oovoo\.iphone\.free\.plist$'; //noslz
    fi_NodeByName:                 'cachedUser'; //noslz
    fi_Test_Data:                  'JT'), //noslz

    ( // ~81~ Random Chat - iOS (https://itunes.apple.com/au/app/random-chat-quick-dating-with-people-nearby/id1281183612?mt=8)
    fi_Name_Program:               'RandomChat';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_RANDOMCHAT; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'dating_12412186\.sqlite3' + DUP_FILE + '|^b16f7d38d9839f9d34b5a556216df0b4cb61e136' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-baiyang\.randomchat\.funapp$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/dating_12412186\.sqlite3$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'), //noslz

    ( // ~82~ Scruff - Chat - Android
    fi_Name_Program:               'Scruff';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SCRUFF; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^scruff\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~83~ Scruff - Chat - iOS
    fi_Name_Program:               'Scruff';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SCRUFF; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^datastore\.sqlite' + DUP_FILE + '|^416eb6473b20becad464662bf0410f0d2a40fcc0' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.appspot\.scruffapp$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/datastore\.sqlite$'; //noslz
    fi_SQLTables_Required:         ['MESSAGES']; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~84~ Skout - Chat - Android
    fi_Name_Program:               'Skout';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKOUT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^skoutDatabase' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['SKOUTMESSAGESTABLE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'skoutMessagesTable'; //noslz
    fi_SQLStatement:               'SELECT * FROM skoutMessagesTable'), //noslz

    ( // ~85~ Skout - Chat - iOS
    fi_Name_Program:               'Skout';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKOUT; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'SKCache\.sqlite' + DUP_FILE + '|^b57ee2d4db422f4da63d5c57a420c4afd88962c4' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.skout\.SKOUT';
    fi_Regex_Itunes_Backup_Name:   '^Library\/Application Support\/SKOUT_SDK4\/SKCache\.sqlite$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZSKCACHEDCHATMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZSKCACHEDCHATMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZSKCACHEDCHATMESSAGE'; //noslz
    //fi_SQLStatement:               'SELECT ZSKCACHEDCHATMESSAGE.*, ZSKCACHEDUSER.ZSKOUTUSERNAME FROM ZSKCACHEDCHATMESSAGE LEFT OUTER JOIN ZSKCACHEDUSER ON ZSKCACHEDCHATMESSAGE.ZSKOUTUSERID = ZSKCACHEDUSER.ZSKOUTUSERID';
    fi_Test_Data:                  ''),

    ( // ~86~ Skype - Accounts
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Accounts';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_SKYPE;
    fi_SQLTables_Required:         ['ACCOUNTS']; //noslz
    fi_SQLPrimary_Tablestr:        'ACCOUNTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM ACCOUNTS'), //noslz

    ( // ~87~ Skype - Activity Android
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Activity';
    fi_Process_ID:                 'DNT_SKYPE_ACTIVITY';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^s4l-live_.*\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGESV12']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGESV12'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGESV12'), //noslz

    ( // ~88~ Skype - Calls
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Calls';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_SKYPE;
    fi_SQLTables_Required:         ['CALLMEMBERS']; //noslz
    fi_SQLPrimary_Tablestr:        'CALLMEMBERS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CALLMEMBERS'), //noslz

    ( // ~89~ Skype - ChatSync
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'ChatSync';
    fi_Process_As:                 PROCESS_AS_CARVE;
    fi_Process_ID:                 'DNT_SKYPE_CHATSYNC';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '\\chatsync\\.*\\*\.dat' + DUP_FILE;
    fi_Carve_Header:               '\x02\x03\x02';
    fi_Carve_Footer:               '\x00'),

    ( // ~90~ Skype - Contacts
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          CONTACTS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_SKYPE;
    fi_SQLTables_Required:         ['CONTACTS']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONTACTS'), //noslz

    ( // ~91~ Skype - Contacts V12 Live
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Contacts v12 Live';
    fi_Process_ID:                 'DNT_SKYPE_CONTACTS_IOS_V12LIVE';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '\\.*live:\..*\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PROFILECACHEV8','MESSAGESV12']; //noslz
    fi_SQLPrimary_Tablestr:        'PROFILECACHEV8' + DUP_FILE; //noslz
    fi_SQLStatement:               'SELECT * FROM PROFILECACHEV8'), //noslz

    ( // ~92~ Skype - Contacts v12
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Contacts v12';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^skype.db.*'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CONTACTS','PENDING_SEND_MESSAGES','SMS_MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONTACTS'), //noslz

    ( // ~93~ Skype - Contacts - Android
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          CONTACTS;
    fi_Process_ID:                 'DNT_SKYPE_CONTACTS_ANDROID';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '\\com\.skype\.raider\\.*\.*live.*\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PROFILECACHEV8','ANDROID_METADATA','CALLLOGS']; //noslz
    fi_SQLPrimary_Tablestr:        'PROFILECACHEV8' + DUP_FILE; //noslz
    fi_SQLStatement:               'SELECT * FROM PROFILECACHEV8'), //noslz

    ( // ~94~ Skype - Messages
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Messages';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_SKYPE;
    fi_SQLTables_Required:         ['MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~95~ Skype - Messages - V12 (Live)
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Messages v12 Live';
    fi_Process_ID:                 'DNT_SKYPE_MESSAGES_IOS_V12LIVE';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '\\.*live:\..*\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGESV12','PROFILECACHEV8']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGESV12' + DUP_FILE; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGESV12'), //noslz

    ( // ~96~ Skype - v12 Messages
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Messages v12';
    fi_Name_OS:                    '';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^skype.db.*';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','PENDING_SEND_MESSAGES','SMS_MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~97~ Skype - Transfers
    fi_Name_Program:               'Skype';
    fi_Name_Program_Type:          'Transfers';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SKYPE; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              RS_SIG_SKYPE;
    fi_SQLTables_Required:         ['TRANSFERS']; //noslz
    fi_SQLPrimary_Tablestr:        'TRANSFERS'; //noslz
    fi_SQLStatement:               'SELECT * FROM TRANSFERS'), //noslz

    ( // ~98~ Slack - Accounts - Android
    fi_Name_Program:               'Slack';
    fi_Name_Program_Type:          'Accounts';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SLACK; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^account_manager' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ACCOUNTS','ANDROID_METADATA']; //noslz
    fi_SQLStatement:               'SELECT * from ACCOUNTS'),

    ( // ~99~ Slack - Accounts - iOS
    fi_Name_Program:               'Slack';
    fi_Name_Program_Type:          'Accounts';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SLACK; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^main_db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZCOREDATAWORKSPACE','ZCOREDATACONVERSATION','ZCOREDATAUSER']; //noslz
    fi_SQLStatement:               'SELECT * FROM ZCOREDATAWORKSPACE, ZCOREDATAUSER WHERE ZCOREDATAWORKSPACE.ZAUTHUSERID = ZCOREDATAUSER.ZTSID'),

    ( // ~100~ Slack - Deprecated Messages
    fi_Name_Program:               'Slack';
    fi_Name_Program_Type:          'Deprecated Messages';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SLACK; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main_db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZSLKDEPRECATEDMESSAGE'];       //noslz
    fi_SQLStatement:               'SELECT                      ' + //noslz
    '  ZSTEAM.ZTSID,                                            ' + //noslz
    '  ZSUSER.ZREALNAME,                                        ' + //noslz
    '  ZSCHANNEL.ZNAME,                                         ' + //noslz
    '  ZSMESSAGE.ZTEXT,                                         ' + //noslz
    '  ZSMESSAGE.ZTIMESTAMP,                                    ' + //noslz
    '  ZSMESSAGE.ZSTATUS                                        ' + //noslz
    'FROM                                                       ' + //noslz
    '  ZSLKDEPRECATEDTEAM AS ZSTEAM,                            ' + //noslz
    '  ZSLKDEPRECATEDMESSAGE AS ZSMESSAGE                       ' + //noslz
    '  LEFT OUTER JOIN ZSLKDEPRECATEDCOREDATAUSER AS ZSUSER     ' + //noslz
    '    ON ZSMESSAGE.ZUSERID = ZSUSER.ZTSID                    ' + //noslz
    '  LEFT OUTER JOIN ZSLKDEPRECATEDBASECHANNEL AS ZSCHANNEL   ' + //noslz
    '    ON ZSMESSAGE.ZCHANNELID = ZSCHANNEL.ZTSID1             ' + //noslz
    'ORDER BY ZSMESSAGE.ZTIMESTAMP'),                               //noslz

    ( // ~101~ Slack - Direct Messages - Android
    fi_Name_Program:               'Slack';
    fi_Name_Program_Type:          'Direct Messages';
    fi_Process_ID:                 'DNT_SLACK_DIRECT_MESSAGES_ANDROID';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SLACK; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '\\databases\\org_.*' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','CONVERSATION','ANDROID_METADATA']; //noslz
    fi_SQLStatement:               'SELECT * from MESSAGES'),

    ( // ~102~ Slack - Direct Messages - iOS
    fi_Name_Program:               'Slack';
    fi_Name_Program_Type:          'Direct Messages';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SLACK; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^main_db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZCOREDATAMESSAGE','ZCOREDATACONVERSATION','ZCOREDATAUSER']; //noslz
    fi_SQLStatement:               'SELECT * from ZCOREDATAMESSAGE'),

    ( // ~103~ Slack - Users - iOS
    fi_Name_Program:               'Slack';
    fi_Name_Program_Type:          'Users';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SLACK; fi_Icon_OS: ICON_SKYPE;
    fi_Regex_Search:               '^main_db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZCOREDATAUSER','ZCOREDATACONVERSATION','ZCOREDATAMESSAGE']; //noslz
    fi_SQLStatement:               'SELECT * from ZCOREDATAUSER'),

    ( // ~104~ SnapChat - Chat - Android
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tcspahn\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHAT','ANDROID_METADATA','FRIENDS']; //noslz
    fi_SQLPrimary_Tablestr:         CHAT; //noslz
    fi_SQLStatement:               'SELECT * FROM CHAT'),

    ( // ~105~ SnapChat - Friend - Android
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          'Friend';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'snapchat\.android\\databases\\main\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['FRIEND','ANDROID_METADATA','CHAT']; //noslz
    fi_SQLPrimary_Tablestr:        'FRIEND'; //noslz
    fi_SQLStatement:               'SELECT * FROM FRIEND';
    fi_Test_Data:                  'GreyKey'), //noslz

    ( // ~106~ SnapChat - Friends - Android
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          'Friends';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tcspahn\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['FRIENDS','ANDROID_METADATA','CHAT']; //noslz
    fi_SQLPrimary_Tablestr:        'FRIENDS'; //noslz
    fi_SQLStatement:               'SELECT * FROM FRIENDS'), //noslz

    ( // ~107~ SnapChat - Memories - Android
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          'Memories';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^memories\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MEMORIES_SNAP','ANDROID_METADATA','MEMORIES_ENTRY']; //noslz
    fi_SQLPrimary_Tablestr:        'MEMORIES_SNAP'; //noslz
    fi_SQLStatement:               'SELECT * FROM MEMORIES_SNAP'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~108~ SnapChat - Message - Android {main}
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          'Message (main.db)';
    fi_Process_ID:                 'DNT_SNAPCHAT_MESSAGE_ANDROID_MAIN';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'snapchat\.android\\databases\\main\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE','ANDROID_METADATA','FRIEND']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM Message, Friend WHERE MESSAGE.senderId = FRIEND._id'; //noslz
    fi_Test_Data:                  'GreyKey'), //noslz

    ( // ~109~ SnapChat - Message - Android {Arryo}
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          'Message (arroyo.db)';
    fi_Process_ID:                 'SNAPCHAT_MESSAGE_ANDROID_ARRYO';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'arroyo\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CONVERSATION_MESSAGE','FEED_ENTRY']; //noslz
    fi_SQLPrimary_Tablestr:        'CONVERSATION_MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM CONVERSATION_MESSAGE'; //noslz
    fi_Test_Data:                  'Digital Corpa 13'), //noslz

    ( // ~110~ SnapChat - User - iOS
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Process_ID:                 'DNT_SNAPCHAT_USER';
    fi_Name_Program:               'SnapChat';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_SNAPCHAT; fi_Icon_OS: ICON_IOS;
    fi_NodeByName:                 RS_DNT_USERNAME;
    fi_Regex_Itunes_Backup_Domain: '^AppDomainGroup-group\.snapchat\.picaboo$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Library\/Preferences\/group\.snapchat\.picaboo\.plist$'; //noslz
    fi_Signature_Parent:           RS_SIG_PLIST_BINARY;
    fi_Test_Data:                  'TGH-JAH'), //noslz

    ( // ~111~ Tango - Chat - Android
    fi_Name_Program:               'Tango';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TANGO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tc\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~112~ Telegram - Chat - Android
    fi_Name_Program:               'Telegram';
    fi_Process_ID:                 'DNT_TELEGRAM_ANDROID';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TELEGRAM; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^cache4\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','BOT_INFO']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM messages'), //noslz

    ( // ~113~ Telegram - Chat - Android {V2}
    fi_Name_Program:               'Telegram';
    fi_Process_ID:                 'DNT_TELEGRAM_ANDROID_V2';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TELEGRAM; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^cache4\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES_V2','BOT_INFO_V2']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM messages_v2, users WHERE MESSAGES_V2.uid = USERS.uid'), //noslz

    ( // ~114~ Telegram - Chat - iOS v29
    fi_Name_Program:               'Telegram';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TELEGRAM; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'tgdata_index\.db' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-ph\.telegra\.Telegraph$';
    fi_Regex_Itunes_Backup_Name:   '^Documents\/tgdata_index\.db$';
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGEINDEX_V29_CONTENT','MESSAGEINDEX_V29_SEGDIR']; //noslz81
    fi_SQLPrimary_Tablestr:        'MESSAGEINDEX_V29_CONTENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGEINDEX_V29_CONTENT';
    fi_Test_Data:                  'SPI 2018'), //http://www.incide.es/en/blog-incide-en/about-the-myth-of-telegrams-messaging-encryption/

    ( // ~115~ Telegram - Chat - iOS
    fi_Name_Program:               'Telegram';
    fi_Name_Program_Type:          'T7' + SPACE + CHAT;
    fi_Process_ID:                 'DNT_TELEGRAM_IOS_CHAT'; //noslz
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TELEGRAM; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^db_sqlite' + DUP_FILE; //noslz
    fi_SQLTables_Required:         ['T7','T0','T2']; //noslz
    fi_SQLPrimary_Tablestr:        'T7'; //noslz
    fi_SQLStatement:               'SELECT * FROM T7'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~116~ Telegram - User - iOS
    fi_Name_Program:               'Telegram';
    fi_Name_Program_Type:          'User';
    fi_Process_As:                 PROCESS_AS_CARVE;
    fi_Carve_Header:               '\x01\x5F\x05\x2B\xA5\x68\x9E';
    fi_Carve_Footer:               '\x02\x66\x6C';
    fi_Process_ID:                 'DNT_TELEGRAM_IOS_USER'; //noslz
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TELEGRAM; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^db_sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~117~ TextNow - Chat - Android
    fi_Name_Program:               'TextNow';
    fi_Name_Program_Type:          'Chat';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1161; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'textnow_data.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA','CONTACTS']; //noslz                             82
    fi_SQLPrimary_Tablestr:        'messages'; //noslz
    fi_SQLStatement:               'SELECT * FROM messages'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~118~ TextNow - Chat - iOS
    fi_Name_Program:               'TextNow';
    fi_Name_Program_Type:          'Chat';
    fi_Process_ID:                 'DNT_TEXTNOW_CHAT'; //noslz
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1173; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '2C0EA118-A71B-4CFD-AF2E-7FE132AC59DF\\Documents\\\d{10,}|\\Documents\\\d{20}' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZTMOINTERACTION','ZTMOCONTACTVALUE','ZTMOCONVERSATION']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM ZTMOINTERACTION';//noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~119~ TextNow - Contacts - Android
    fi_Name_Program:               'TextNow';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1161; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'textnow_data.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CONTACTS','ANDROID_METADATA','MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'contacts'; //noslz
    fi_SQLStatement:               'SELECT * FROM contacts'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~120~ TextNow - Contacts - iOS
    fi_Name_Program:               'TextNow';
    fi_Name_Program_Type:          'Contacts';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1173; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '2C0EA118-A71B-4CFD-AF2E-7FE132AC59DF\\Documents\\\d{10,}' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZTMOCONTACTVALUE','ZTMOCONVERSATION','ZTMOINTERACTION']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM ZTMOCONTACTVALUE'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~121~ TextNow - Profile - iOS
    fi_Name_Program:               'TextNow';
    fi_Name_Program_Type:          'Profile';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1173; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '2C0EA118-A71B-4CFD-AF2E-7FE132AC59DF\\Documents\\\d{10,}' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZTMOACCOUNTINFO','ZTMOCONTACTVALUE','ZTMOCONVERSATION','ZTMOINTERACTION']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM ZTMOACCOUNTINFO'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~122~ Threema - Chat - iOS
    fi_Name_Program:               'Threema';
    fi_Name_Program_Type:          'Chat';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1212; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'ThreemaData\.sqlite' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMESSAGE','ZCONTACT','ZCALL']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMESSAGE'; //noslz
    fi_Test_Data:                  'Digital Corpa iOS15'), //noslz

    ( // ~123~ Tiktok - Chat - Android
    fi_Name_Program:               'Tiktok';
    fi_Name_Program_Type:          CHAT;
    fi_Process_ID:                 'DNT_TIKTOK_CHAT_ANDROID';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1172; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '\\.*_im\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MSG','ATTCHMENT','PARTICIPANT']; //noslz
    fi_SQLPrimary_Tablestr:        'MSG'; //noslz
    fi_SQLStatement:               'SELECT * FROM MSG'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~124~ Tiktok - Chat - IOS
    fi_Name_Program:               'Tiktok';
    fi_Name_Program_Type:          CHAT;
    fi_Process_ID:                 'DNT_TIKTOK_CHAT_IOS';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1172; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '\\ChatFiles\\.*\\db\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['TIMMESSAGEORM','TIMCONVERSATIONORM']; //noslz
    fi_SQLPrimary_Tablestr:        'TIMMESSAGEORM'; //noslz
    fi_SQLStatement:               'SELECT * FROM TIMMESSAGEORM'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~125~ Tiktok - Contacts - iOS
    fi_Name_Program:               'Tiktok';
    fi_Name_Program_Type:          'Contacts';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               1172;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^AwemeIM\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['AwemeContacts']; //noslz
    fi_SQLPrimary_Tablestr:        'AwemeContacts'; //noslz
    fi_SQLStatement:               'SELECT * FROM AwemeContacts'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~126~ Tinder - Chat - Android
    fi_Name_Program:               'Tinder';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TINDER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tinder-?\d?\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'), //noslz

    ( // ~127~ Tinder - Chat - iOS
    fi_Name_Program:               'Tinder';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TINDER; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'tinder\d\.sqlite' + DUP_FILE + '|^bd881d082294367de00a97791cbf3741481c3466' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.cardify\.tinder$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Tinder\d\.sqlite$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMESSAGE'), //noslz

    ( // ~128~ Tinder - Match - Android
    fi_Name_Program:               'Tinder';
    fi_Name_Program_Type:          'Match';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TINDER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tinder-?\d?\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MATCH_PERSON','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'MATCH_PERSON'; //noslz
    fi_SQLStatement:               'SELECT * FROM MATCH_PERSON'), //noslz

    ( // ~129~ Tinder - Photo - Android
    fi_Name_Program:               'Tinder';
    fi_Name_Program_Type:          'Photo';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TINDER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tinder-?\d?\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PHOTOS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_PHOTOS; //noslz
    fi_SQLStatement:               'SELECT * FROM PHOTOS'), //noslz

    ( // ~130~ Tinder - User - Android
    fi_Name_Program:               'Tinder';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TINDER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^tinder\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['USERS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_USERS; //noslz
    fi_SQLStatement:               'SELECT * FROM USERS'), //noslz

    ( // ~131~ Tinder - User - iOS
    fi_Name_Program:               'Tinder';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TINDER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^bd881d082294367de00a97791cbf3741481c3466' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-com\.cardify\.tinder$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Tinder\d\.sqlite$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZUSER'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZUSER'), //noslz

    ( // ~132~ Touch - Chat - iOS
    fi_Name_Program:               'Touch';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TOUCH; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Touch\.SQlite' + DUP_FILE + '|^b18a30bf72824a7d024a95178ae42d8339f83633' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Touch iOS'; //noslz
    fi_SQLTables_Required:         ['ZENTMESSAGE','ZUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZENTMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT ZENTMESSAGE.*, ZUSER.ZFULLNAME, ZUSER.ZAVATARURL FROM ZENTMESSAGE LEFT OUTER JOIN ZUSER ON ZUSER.Z_PK = ZENTMESSAGE.ZAUTHOR ORDER BY ZENTMESSAGE.ZTIMESTAMP'), //noslz

    ( // ~133~ Tumblr - Chat - IOS
    fi_Name_Program:               'Tumblr';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_TUMBLR; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Tumblr\.sqlite|^4390940efc48507511e28cd8345b966d7007a4b2' + DUP_FILE;
    fi_Regex_Itunes_Backup_Domain: 'AppDomainGroup-group\.Tumblr'; //noslz
    fi_Regex_Itunes_Backup_Name:   'CoreData\/Tumblr\.sqlite'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMESSAGE','ZMESSAGEDRAFT','ZFOLLOWER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMESSAGE'), //noslz

    ( // ~134~ Venmo - Chat - Android
    fi_Name_Program:               'Venmo';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1182; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^venmo\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['COMMENTS','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'COMMENTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM COMMENTS'), //noslz

    ( // ~135~ Viber - Chat - Android
    fi_Name_Program:               'Viber';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_VIBER; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^viber_messages' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES', 'PARTICIPANTS', 'STICKERS']; //noslz
    fi_SQLPrimary_Tablestr:         RS_DNT_MESSAGES; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'; //noslz
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~136~ Viber - Chat - iOS
    fi_Name_Program:               'Viber';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_VIBER; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Contacts\.data' + DUP_FILE + '|^b39bac0d347adfaf172527f97c3a5fa3df726a3a' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'Viber iOS'; //noslz
    fi_SQLTables_Required:         ['ZVIBERMESSAGE','ZABCONTACT']; //noslz
    fi_SQLPrimary_Tablestr:        'ZVIBERMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZVIBERMESSAGE'; //noslz
    fi_Test_Data:                  'Maria'), //noslz

    ( // ~137~ Viber - Chat - PC
    fi_Name_Program:               'Viber';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    'PC';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_VIBER; fi_Icon_OS: ICON_WINDOWS;
    fi_Regex_Search:               '^viber\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['TEXTMESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'TEXTMESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM TEXTMESSAGES'; //noslz
    fi_Test_Data:                  'ASUS'), //noslz

    ( // ~138~ Viber - Chat - PC v11
    fi_Name_Program:               'Viber';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    'PC v11';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_VIBER; fi_Icon_OS: ICON_WINDOWS;
    fi_Regex_Search:               '^viber\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT MESSAGEINFO.*, Contact.Name, Contact.ViberContact, Contact.ClientName ' + //noslz
                                   'FROM MESSAGEINFO ' + //noslz
                                   '  LEFT OUTER JOIN Contact ' + //noslz
                                   '    ON MESSAGEINFO.ContactID = Contact.ContactID '; //noslz
    fi_Test_Data:                  'ASUS'), //noslz

    ( // ~139~ WhatsApp - Calls - iOS
    fi_Process_ID:                 'DNT_WHATSAPP_CALLS';
    fi_Process_As:                 PROCESS_AS_PLIST;
    fi_Name_Program:               'WhatsApp';
    fi_Name_Program_Type:          'Calls';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHATSAPP; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^21ae65d600415978a2e08e7969270e078247c1b5' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-net\.whatsapp\.WhatsApp$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/calls.log$'; //noslz
    fi_Signature_Parent:           'Plist (Binary)'; //noslz
    fi_NodeByName:                 '$objects'), //noslz

    ( // ~140~ WhatsApp - Chat - Android
    fi_Name_Program:               'WhatsApp';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHATSAPP; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^msgstore\.db' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGE','JID']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGE'),

    ( // ~141~ WhatsApp - Chat - iOS
    fi_Name_Program:               'WhatsApp';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHATSAPP; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^ChatStorage\.SQlite' + DUP_FILE + '|^1b6b187a1b60b9ae8b720c79e2c67f472bab09c0' + DUP_FILE + '|^275ee4a160b7a7d60825a46b0d3ff0dcdb2fbc9d' + DUP_FILE + '|^7c7fba66680ef796b916b067077cc246adacf01d' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_Signature_Sub:              'WhatsApp iOS'; //noslz
    fi_SQLTables_Required:         ['ZWAMESSAGE','ZWAMEDIAITEM','ZWAMESSAGEINFO']; //noslz
    fi_SQLPrimary_Tablestr:        'ZWAMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT ZWAMESSAGE.*, ZWAMEDIAITEM.ZMEDIAURL, ZWAMEDIAITEM.ZMEDIALOCALPATH, ZWAMEDIAITEM.ZXMPPTHUMBPATH FROM ZWAMESSAGE LEFT OUTER JOIN ZWAMEDIAITEM ON ZWAMEDIAITEM.Z_PK = ZWAMESSAGE.ZMEDIAITEM ORDER BY ZWAMESSAGE.ZMESSAGEDATE'),

    ( // ~142~ WhatsApp - Contacts - Android
    fi_Name_Program:               'WhatsApp';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHATSAPP; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^wa\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['WA_CONTACTS']; //noslz
    fi_SQLPrimary_Tablestr:        'WA_CONTACTS'; //noslz
    fi_SQLStatement:               'SELECT * FROM WA_CONTACTS'), //noslz

    ( // ~143~ WhatsApp - Contacts - iOS
    fi_Name_Program:               'WhatsApp';
    fi_Name_Program_Type:          CONTACTS;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHATSAPP; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^ContactsV2\.sqlite' + DUP_FILE + '|^b8548dc30aa1030df0ce18ef08b882cf7ab5212f' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: 'AppDomainGroup-group\.net\.whatsapp\.WhatsApp\.shared'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^ContactsV2\.sqlite' + DUP_FILE;
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZWAADDRESSBOOKCONTACT','Z_MODELCACHE','Z_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ZWAADDRESSBOOKCONTACT'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZWAADDRESSBOOKCONTACT'), //noslz

    ( // ~144~ WhatsApp - Messages - Android
    fi_Name_Program:               'WhatsApp';
    fi_Process_ID:                 'DNT_WHATSAPP_ANDROID_MESSAGES';
    fi_Name_Program_Type:          'Messages';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHATSAPP; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^msgstore.*\.db' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~145~ Whisper - Chat - iOS
    fi_Name_Program:               'Whisper';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_WHISPER; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^Messaging\.sqlite' + DUP_FILE + '|^6ca1507fc55bc201a552cc982bab77b74452fb44' + DUP_FILE; //noslz
    fi_Regex_Itunes_Backup_Domain: '^AppDomain-sh\.whisper\.whisperapp-urban$'; //noslz
    fi_Regex_Itunes_Backup_Name:   '^Documents\/Messaging\.sqlite$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMESSAGE'), //noslz

    ( // ~146~ Wire - Chat - Android
    fi_Name_Program:               'Wire';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Process_ID:                 'DNT_WIRE_CHAT_ANDROID';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1176; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^.{8}\-.{4}\-.{4}\-.{4}\-.{12}$' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA','USERS']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGES'), //noslz

    ( // ~147~ Wire - Chat - iOS
    fi_Name_Program:               'Wire';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1176; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^store\.wiredatabase' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZMESSAGE','ZACTION','ZUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZMESSAGE'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZMESSAGE'), //noslz

    ( // ~148~ Wire - User - Android
    fi_Name_Program:               'Wire';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1176; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^.{8}\-.{4}\-.{4}\-.{4}\-.{12}$' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES','ANDROID_METADATA','USERS']; //noslz
    fi_SQLPrimary_Tablestr:        'USERS'; //noslz
    fi_SQLStatement:               'SELECT * FROM USERS'), //noslz

    ( // ~149~ Wire - User - iOS
    fi_Name_Program:               'Wire';
    fi_Name_Program_Type:          'User';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1176; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '^store\.wiredatabase' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZUSER','ZACTION','ZMESSAGE']; //noslz
    fi_SQLPrimary_Tablestr:        'ZUSER'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZUSER'), //noslz

    ( // ~150~ Yahoo Messenger - Chat - PC
    fi_Process_ID:                 'DNT_YAHOO_MESSENGER'; //noslz
    fi_Name_Program:               'Yahoo Messenger'; //noslz
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    WINDOWS;
    fi_Icon_Category:              ICON_WINDOWS; fi_Icon_Program: ICON_YAHOO; fi_Icon_OS: ICON_WINDOWS;
    fi_Regex_Search:               '\\yahoo!\\Messenger\\.*\.dat' + DUP_FILE; //noslz
    fi_Signature_Parent:           'Yahoo'; //noslz
    fi_Test_Data:                  'Z'),

    ( // ~151~ Zalo - Chat - Android
    fi_Name_Program:               'Zalo';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: ICON_ZALO; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               '^zalo' + DUP_FILE; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CHAT_CONTENT','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'CHAT_CONTENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM CHAT_CONTENT'), //noslz

    ( // ~152~ Zello - Chat - Android
    fi_Name_Program:               'Zello';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    'Android';
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1111; fi_Icon_OS: ICON_ANDROID;
    fi_Regex_Search:               'zello.*\\db$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ITEMS']; //noslz
    fi_SQLPrimary_Tablestr:        'ITEMS'; //noslz
    fi_SQLStatement:               'SELECT * FROM ITEMS'), //noslz

    ( // ~153~ Zello - Chat - IOS
    fi_Name_Program:               'Zello';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1111; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               'zello\.sqlite.*|^939e5c39ca2fe607ff26e54f9fcb24f309f08a95.*'; //noslz
    fi_Regex_Itunes_Backup_Domain: 'AppDomain-com\.zello\.client\.main'; //noslz
    fi_Regex_Itunes_Backup_Name:   'Documents\/Zello\/history\/6795bed8e9e6eb6f29ed78ab3b3b119c\/zello\.sqlite'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['HISTORY','CODEC','DURATION']; //noslz
    fi_SQLPrimary_Tablestr:        'HISTORY'; //noslz
    fi_SQLStatement:               'SELECT * FROM HISTORY'), //noslz

    ( // ~154~ Zoom - Chat - iOS
    fi_Name_Program:               'Zoom';
    fi_Name_Program_Type:          CHAT;
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1166; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '.*@xmpp\.zoom\.us\.(asyn\.db|db|idx.db|sync\.db)'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MSG_T_JTA0QSDYSN2HPYPNPE_MINUS_REPLACE_0YQ','ZOOM_MM_FILE_DOWNLOAD_TABLE']; //noslz107
    fi_SQLPrimary_Tablestr:        'msg_t_jta0qsdysn2hpypnpe_minus_replace_0yq'; //noslz
    fi_SQLStatement:               'SELECT * FROM msg_t_jta0qsdysn2hpypnpe_minus_replace_0yq'; //noslz
    fi_Test_Data:                  'Digital Corpa'),

    ( // ~155~ Zoom - Download - iOS
    fi_Name_Program:               'Zoom';
    fi_Name_Program_Type:          'Download';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_CHAT; fi_Icon_Program: 1166; fi_Icon_OS: ICON_IOS;
    fi_Regex_Search:               '.*@xmpp\.zoom\.us\.asyn\.db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZOOM_MM_FILE_DOWNLOAD_TABLE','MSG_T_JTA0QSDYSN2HPYPNPE_MINUS_REPLACE_0YQ']; //noslz108
    fi_SQLPrimary_Tablestr:        'zoom_mm_file_download_table'; //noslz
    fi_SQLStatement:               'SELECT * FROM zoom_mm_file_download_table'; //noslz
    fi_Test_Data:                  'Digital Corpa')); //noslz

var
  iIdx: integer;
begin
  for iIdx := Low(lFileItems) to High(lFileItems) do
  begin
    FileItems[iIdx] := @lFileItems[iIdx];
    if not Progress.isRunning then
      break;
  end;
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

procedure Attachment_Frog(aNode: TPropertyNode; aStringList: TStringList);
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
        if (aNode.PropName = 'url') or (aNode.PropName = 'type') then // noslz
          aStringList.Add(aNode.PropDisplayValue);
        Attachment_Frog(aNode, aStringList);
      end;
    end;
  end;
end;

function BlobText(const strBlob: string): string;
var
  iStart: integer;
  iIdx: integer;
begin
  Result := '';
  iStart := POS('RAW_CONTENT_VALUE_ONLY_TO_BE_VISIBLE_TO_USER', strBlob);
  if iStart <= 0 then
    Exit;
  iIdx := iStart + Length('RAW_CONTENT_VALUE_ONLY_TO_BE_VISIBLE_TO_USER') + 2;
  if Ord(strBlob[iIdx + 1]) = $1 then
    Inc(iIdx, 2);
  while iIdx < Length(strBlob) - 1 do
  begin
    if (Ord(strBlob[iIdx]) = $DA) and (Ord(strBlob[iIdx + 1]) = $0) then
      break;
    Result := Result + strBlob[iIdx];
    Inc(iIdx);
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

        // Google Takeout JSON
        if (not NowProceed_bl) and (UpperCase(Item^.fi_Process_ID) = 'DNT_GOOGLE_CHAT_JSON_TAKEOUT') and (DeterminedFileDriverInfo.ShortDisplayName = 'JSON') then
        begin
          NowProceed_bl := True;
          reason_str := 'Google Takeout JSON:' + SPACE + '(' + DeterminedFileDriverInfo.ShortDisplayName + ')';
          Reason_StringList.Add(format(GFORMAT_STR, ['', 'Added(T)', IntToStr(i), IntToStr(anEntry.ID), DeterminedFileDriverInfo.ShortDisplayName, trunc_EntryName_str, reason_str]))
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

function isGroupMe: boolean var aReader: TEntryReader;
aRegEx:
TRegEx;
h_offset, h_count: int64;
begin
  Result := False;
  if (anEntry.Extension = '.json') then // noslz
  begin
    aReader := TEntryReader.Create;
    try
      aRegEx := TRegEx.Create;
      try
        aRegEx.CaseSensitive := True; // Should be True for most binary regex terms. Must come before setting search term.
        aRegEx.SearchTerm := 'groupme'; // noslz
        aRegEx.Stream := aReader;
        aRegEx.Progress := Progress;
        if aReader.OpenData(anEntry) then // Open the entry to search
          try
            aReader.Position := 0;
            aRegEx.Find(h_offset, h_count);
            while (h_offset <> -1) do
            begin
              Result := True;
              Exit;
            end;
          except
            Progress.Log(ATRY_EXCEPT_STR + 'Error processing ' + anEntry.EntryName);
          end;
      finally
        aRegEx.free;
      end;
    finally
      aReader.free;
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

procedure Nodefrog(aNode: TPropertyNode; anint: integer; aStringList: TStringList);
var
  i: integer;
  theNodeList: TObjectList;
  pad_str: string;
begin
  pad_str := (StringOfChar(' ', anint * 3));
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
        aStringList.Add(RPad(pad_str + aNode.PropName, RPAD_VALUE) + aNode.PropDisplayValue);
        Nodefrog(aNode, anint + 1, aStringList);
      end;
    end;
  end;
end;

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

function ReadField4(var Buffer: TProtoBufObject): string;
var
  pbtag_int: integer;
  pbtag_typ_int: integer;
  pbtag_fld_int: integer;
  shorttemp: ShortInt;
begin
  Result := '';
  shorttemp := Buffer.readRawVarint32;
  pbtag_int := Buffer.ReadTag;
  while (pbtag_int <> 0) and (Progress.isRunning) do
  begin
    pbtag_typ_int := GetTagWireType(pbtag_int);
    pbtag_fld_int := GetTagFieldNumber(pbtag_int);
    if pbtag_fld_int = PBUFF_FIELD4 then
    begin
      shorttemp := Buffer.readRawVarint32;
      pbtag_int := Buffer.ReadTag;
      pbtag_typ_int := GetTagWireType(pbtag_int);
      pbtag_fld_int := GetTagFieldNumber(pbtag_int);
      if pbtag_fld_int = PBUFF_FIELD2 then
      begin
        shorttemp := Buffer.readRawVarint32;
        pbtag_int := Buffer.ReadTag;
        pbtag_typ_int := GetTagWireType(pbtag_int);
        pbtag_fld_int := GetTagFieldNumber(pbtag_int);
        if pbtag_fld_int = PBUFF_FIELD1 then
        begin
          Result := Buffer.ReadString;
        end; // PBUFF_FIELD1
      end; // PBUFF_FIELD2
    end // PBUFF_FIELD4
    else
    begin
      Buffer.skipField(pbtag_int);
    end;
    pbtag_int := Buffer.ReadTag;
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
var
  aArtifactEntry: TEntry;
  aArtifactEntryParent: TEntry;
  ADDList: TList;
  aPropertyTree: TPropertyParent;
  aRootProperty: TPropertyNode;
  blob_stream: TBytesStream;
  burner_direct_bytes: Tbytes;
  carved_str: string;
  CarvedData: TByteInfo;
  CarvedEntry: TEntry;
  cbyte: integer;
  chatsync_beg_int64, chatsync_end_int64: int64;
  chatsync_char: string;
  chatsync_HdrDate_dt: TDateTime;
  chatsync_HdrDate_hex: string;
  chatsync_HdrDate_int64: int64;
  chatsync_HdrDate_str: string;
  chatsync_message_found_count: integer;
  chatsync_msg_str: string;
  chatsync_MsgDate_dt: TDateTime;
  chatsync_MsgDate_int64: int64;
  chatsync_MsgDate_str: string;
  chatsync_users_str: string;
  ChildNodeList: TObjectList;
  col_DF: TDataStoreFieldArray;
  ColCount: integer;
  cypherbyte: byte;
  Display_Name_str: string;
  DNT_sql_col: string;
  duration_int: double;
  end_pos: int64;
  end_pos_max: int64;
  FooterProgress: TPAC;
  g, h, i, j, iii, k, kk, kkk, p, q, x, y, z, p_int: integer;
  google_voice_blob_bytes: Tbytes;
  h_startpos, h_offset, h_count, f_offset, f_count: int64;
  HeaderReader, FooterReader, CarvedEntryReader: TEntryReader;
  HeaderRegex, FooterRegEx: TRegEx;
  hexbytes_str: string;
  instagram_array_of_str: array of string;
  instagram_direct_bytes: Tbytes;
  instagram_direct_date_dt: TDateTime;
  instagram_direct_direction_str: string;
  instagram_direct_message_str: string;
  instagram_direct_recipient_int: integer;
  instagram_direct_sender_int: integer;
  instagram_direct_StringList: TStringList;
  instagram_direct_type_str: string;
  instaProp: TPropertyParent;
  Item: PSQL_FileSearch;
  LineList: TStringList;
  test_bytes_length: integer;
  mydb: TSQLite3Database;
  newJOURNALReader, newEntryReader: TEntryReader;
  newstr: string;
  newWALReader: TEntryReader;
  Node1, Node2, Node3, NextNode, PrevNode: TPropertyNode;
  NodeList1, NodeList2: TObjectList;
  nsp_data_str: string;
  NumberOfNodes: integer;
  offset_str: string;
  PropertyList, Node2_PropertyList: TObjectList;
  Re: TDIPerlRegEx;
  record_count: integer;
  records_read_int: integer;
  skip_bl: boolean;
  snapchat_message_type_str: string;
  SomeBytes: Tbytes;
  sql_tbl_count: integer;
  sqlselect, sqlselect_row: TSQLite3Statement;
  sql_row_count: integer;
  sSize: integer;
  stPos: integer;
  Telegram_bytes: Tbytes;
  telegram_data_str: string;
  Telegram_DT: TDateTime;
  Telegram_int64: int64;
  Telegram_msgLen: integer;
  Telegram_msgoffset: integer;
  Telegram_UserID: Dword;
  temp_day, temp_month, temp_year: string;
  temp_dt: TDateTime;
  temp_int_str: string;
  temp_flt: double;
  temp_int64: int64;
  temp_str, tempstr, test_str: string;
  temp_StringList: TStringList;
  test_bytes: Tbytes;
  theTFileDriveClass: TFileDriverClass;
  TotalFiles: int64;
  type_str: string;
  variant_Array: array of variant;
  walk_back_pos: integer;
  whatsapp_call_date: string;
  YahooConfUser_str: string;
  YahooConfUserBytes: array [1 .. 1000] of byte;
  YahooDateTime: TDateTime;
  YahooDecodedMsg: string;
  YahooDword: Dword;
  YahooMsgBytes: array [1 .. 1000] of byte;
  YahooMsgLength: Dword;
  YahooName: string;
  YahooTermLength: Dword;
  YahooType: Dword;
  YahooUser: Dword;
  yn: integer;

  Buffer: TProtoBufObject;
  pb_tag_int: integer;
  pb_tag_field_int: integer;

  tmp_telegram_int64: int64;

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

// Burner Cache - IOS (Node by Name Method) ----------------------------------
  procedure Process_Burner_Cache_IOS;
  var
    y: integer;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_CACHE_MESSAGES') or (UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_MESSAGES') then
    begin
      PropertyList := Node1.PropChildList;
      if assigned(PropertyList) then
      begin
        for x := 0 to PropertyList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          Node2 := TPropertyNode(PropertyList.items[x]);
          if assigned(Node2) then
          begin
            Node2_PropertyList := Node2.PropChildList;
            for y := 0 to Node2_PropertyList.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              Node3 := TPropertyNode(Node2_PropertyList.items[y]);
              if assigned(Node3) then
              begin
                for g := 1 to ColCount do
                begin
                  if not Progress.isRunning then
                    break;
                  if (UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_CACHE_MESSAGES') or (UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_MESSAGES') then
                  begin
                    if (aItems[g].sql_col = 'DNT_DATECREATED') and (Node3.PropName = 'dateCreated') then // noslz
                      try
                        temp_int_str := Node3.PropValue;
                        if Length(temp_int_str) = 13 then
                        begin
                          temp_int64 := StrToInt64(temp_int_str);
                          temp_dt := UnixTimeToDateTime(temp_int64 div 1000);
                          variant_Array[g] := temp_dt;
                        end;
                      except
                        Progress.Log(ATRY_EXCEPT_STR);
                      end;
                    if (aItems[g].sql_col = 'DNT_MESSAGETYPE') and (Node3.PropName = 'messageType') then // noslz
                      if Node3.PropValue = '1' then
                        variant_Array[g] := 'Call/Voice (1)'
                      else if Node3.PropValue = '2' then
                        variant_Array[g] := 'Text/Picture (2)'
                      else
                        variant_Array[g] := 'Unknown';
                    if (aItems[g].sql_col = 'DNT_CONTACTPHONENUMBER') and (Node3.PropName = 'contactPhoneNumber') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_USERID') and (Node3.PropName = 'userId') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_BURNERID') and (Node3.PropName = 'burnerId') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_MESSAGE') and (Node3.PropName = 'message') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_DIRECTION') and (Node3.PropName = 'direction') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_MEDIAURL') and (Node3.PropName = 'mediaUrl') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_VOICEURL') and (Node3.PropName = 'voiceUrl') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
                    if (aItems[g].sql_col = 'DNT_MESSAGEDURATION') and (Node3.PropName = 'messageDuration') then // noslz
                      variant_Array[g] := Node3.PropValue; // noslz
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

// ByLock Android ------------------------------------------------------------
  procedure Process_ByLock;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_BYLOCK_APPPREFFILE') and (UpperCase(Item^.fi_Name_OS) = UpperCase(ANDROID)) then
    begin
      for g := 1 to ColCount do
      begin
        if not Progress.isRunning then
          break;
        DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(DNT_sql_col));
        if assigned(Node1) then
          if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
            variant_Array[g] := Node1.PropDisplayValue;
      end;
      AddToModule;
    end;
  end;

// Discord - Node by Name Method ----------------------------------------------
  procedure Process_Discord;
  var
    username_str: string;
    userid_str: string;
    filename_str: string;
    size_str: string;
    url_str: string;

    function NodeFinder(base_node: TPropertyNode; astr: string): string;
    var
      FoundNode: TPropertyNode;
    begin
      Result := '';
      FoundNode := nil;
      FoundNode := TPropertyNode(base_node.GetFirstNodeByName(astr));
      if assigned(FoundNode) then
        Result := FoundNode.PropDisplayValue;
    end;

  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_DISCORD_JSON') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
    begin
      for x := 0 to NumberOfNodes - 1 do
      begin
        if not Progress.isRunning then
          break;
        for g := 1 to ColCount do
          variant_Array[g] := null; // Null the array
        Node1 := TPropertyNode(NodeList1.items[x]);
        PropertyList := Node1.PropChildList;
        if assigned(PropertyList) then
        begin
          for y := 0 to PropertyList.Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            Node2 := TPropertyNode(PropertyList.items[y]);
            if assigned(Node2) then
            begin
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
                if Node2.PropName = DNT_sql_col then
                begin
                  variant_Array[g] := Node2.PropDisplayValue;
                  if (UpperCase(DNT_sql_col) = 'TYPE') then
                  begin
                    // https://discord.com/developers/docs/resources/channel#message-object-message-types
                    if (variant_Array[g] = '0') then
                      variant_Array[g] := 'Message'
                    else if (variant_Array[g] = '3') then
                      variant_Array[g] := 'Call'
                    else if (variant_Array[g] = '7') then
                      variant_Array[g] := 'User Join';
                  end;
                  break;
                end;
              end;

              if Node2.PropName = 'author {}' then // noslz
              begin
                username_str := NodeFinder(Node2, 'username'); // noslz
                userid_str := NodeFinder(Node2, 'id'); // noslz
                for g := 1 to ColCount do
                begin
                  if not Progress.isRunning then
                    break;
                  DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
                  if DNT_sql_col = 'username' then // noslz
                    variant_Array[g] := username_str; // noslz
                  if DNT_sql_col = 'author_id' then // noslz
                    variant_Array[g] := userid_str; // noslz
                end;
              end;

              if Node2.PropName = 'attachments []' then // noslz
              begin
                filename_str := NodeFinder(Node2, 'filename'); // noslz
                size_str := NodeFinder(Node2, 'size'); // noslz
                url_str := NodeFinder(Node2, 'url'); // noslz
                for g := 1 to ColCount do
                begin
                  if not Progress.isRunning then
                    break;
                  DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
                  if DNT_sql_col = 'filename' then // noslz
                    variant_Array[g] := filename_str; // noslz
                  if DNT_sql_col = 'size' then // noslz
                    variant_Array[g] := size_str; // noslz
                  if DNT_sql_col = 'url' then // noslz
                    variant_Array[g] := url_str; // noslz
                end;
              end;
            end;
          end;
        end;
        AddToModule;
      end;
    end;
  end;

// Google Chat - JSON Takeout ------------------------------------------------
  procedure Process_Google_Chat_JSON_Takeout;

    procedure TakeoutNodeFrog(aNode: TPropertyNode; anint: integer; aItems: TSQL_Table_array; ColCount: integer);
    var
      DNT_sql_col: string;
      g, i: integer;
      msg_id_str: string;
      theNodeList: TObjectList;
      dt_tmp_str: string;
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
            msg_id_str := '';
            aNode := TPropertyNode(theNodeList.items[i]);

            if (anint = 2) and RegexMatch(aNode.PropName, '^\[\d+]  {}$', True) then // noslz
            begin
              msg_id_str := aNode.PropName;
              msg_id_str := StringReplace(msg_id_str, '{', '', [rfReplaceAll]);
              msg_id_str := StringReplace(msg_id_str, '}', '', [rfReplaceAll]);
              msg_id_str := StringReplace(msg_id_str, '[', '', [rfReplaceAll]);
              msg_id_str := StringReplace(msg_id_str, ']', '', [rfReplaceAll]);
              msg_id_str := trim(msg_id_str);
            end;

            for g := 1 to ColCount do
            begin
              if not Progress.isRunning then
                break;
              DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));

              // Message ID
              if (msg_id_str <> '') and (UpperCase(DNT_sql_col) = 'MESSAGE_ID') then // noslz
                variant_Array[g] := msg_id_str;

              // Create Date String and Date Time
              if UpperCase(aNode.PropName) = (UpperCase(DNT_sql_col)) then
              begin
                if DNT_sql_col = 'created_date' then // noslz
                begin
                  dt_tmp_str := aNode.PropDisplayValue;
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Monday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Tuesday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Wednesday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Thursday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Friday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Saturday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, 'Sunday,' + SPACE, '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, ' at', '', [rfReplaceAll]); // noslz
                  dt_tmp_str := StringReplace(dt_tmp_str, ' UTC', '', [rfReplaceAll]); // noslz
                  try
                    variant_Array[1] := VarToDateTime(dt_tmp_str);
                    variant_Array[2] := aNode.PropDisplayValue;
                  except
                    Progress.Log('exception'); // noslz
                  end;
                end
                else
                  variant_Array[g] := aNode.PropDisplayValue;
                TakeoutNodeFrog(aNode, anint + 1, aItems, ColCount);
              end;
            end;
            TakeoutNodeFrog(aNode, anint + 1, aItems, ColCount);
          end;
          if (anint = 3) then
          begin
            AddToModule;
          end;
        end;
      end;
    end;

  begin
    Progress.Log('Process_Google_Chat_JSON_Takeout: ' + IntToStr(ColCount)); // noslz
    TakeoutNodeFrog(aRootProperty, 0, aItems, ColCount);
  end;

// Grindr - Node by Name Method ----------------------------------------------
  procedure Process_Grindr;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_GRINDR_PREFERENCES') and (UpperCase(Item^.fi_Name_OS) = UpperCase(ANDROID)) then
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
            if not Progress.isRunning then
              break;
            Node2 := TPropertyNode(PropertyList.items[y]);
            if assigned(Node2) then
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                // LOGIN_EMAIL -----------------------------
                if variant_Array[1] = null then
                  if assigned(Node2) and (UpperCase(Node2.PropDisplayValue) = UpperCase('LOGIN_EMAIL')) then
                  begin
                    variant_Array[1] := Node1.PropDisplayValue;
                    break;
                  end;
                // EXPLORER_RECENT_SEARCHES ----------------
                if variant_Array[2] = null then
                  if assigned(Node2) and (UpperCase(Node2.PropDisplayValue) = UpperCase('EXPLORE_RECENT_SEARCHES')) then
                  begin
                    variant_Array[2] := Node1.PropDisplayValue;
                    break;
                  end;
                // LONGITUDE -------------------------------
                if variant_Array[3] = null then
                  if assigned(Node2) and (UpperCase(Node2.PropDisplayValue) = UpperCase('LONGITUDE')) then
                    if y + 1 <= PropertyList.Count - 1 then
                    begin
                      Node3 := TPropertyNode(PropertyList.items[y + 1]);
                      variant_Array[3] := Node3.PropDisplayValue;
                      break;
                    end;
                // LATITUDE --------------------------------
                if variant_Array[1] = null then
                  if assigned(Node2) and (UpperCase(Node2.PropDisplayValue) = UpperCase('LATITUDE')) then
                    if y + 1 <= PropertyList.Count - 1 then
                    begin
                      Node3 := TPropertyNode(PropertyList.items[y + 1]);
                      variant_Array[4] := Node3.PropDisplayValue;
                      break;
                    end; { latitude }
              end;
          end;
      end;
      AddToModule;
    end;
  end;

// GroupMe - Node by Name Method ---------------------------------------------
  procedure Process_GroupMe;
  var
    AttachmentList: TObjectList;
    Attachment_StringList: TStringList;
    PlatformNode: TPropertyNode;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_GROUPME_JSON') then
    begin
      PlatformNode := TPropertyNode(aRootProperty.GetFirstNodeByName('platform')); // noslz
      if assigned(PlatformNode) and (UpperCase(PlatformNode.PropDisplayValue) = 'GM') then // noslz  - extra check for GroupMe JSON files
      begin
        Progress.Log('Processing GroupMe');
        Attachment_StringList := TStringList.Create;
        Attachment_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
        Attachment_StringList.Duplicates := dupIgnore;
        try
          for g := 1 to ColCount do
            variant_Array[g] := null; // Null the array
          for x := 0 to NumberOfNodes - 1 do
          begin
            if not Progress.isRunning then
              break;
            Attachment_StringList.Clear;
            Node1 := TPropertyNode(NodeList1.items[x]);
            PropertyList := Node1.PropChildList;
            if assigned(PropertyList) then
            begin
              for g := 1 to ColCount do
                variant_Array[g] := null; // Null the array
              for y := 0 to PropertyList.Count - 1 do
              begin
                Node2 := TPropertyNode(PropertyList.items[y]);
                if assigned(Node2) then
                begin
                  for g := 1 to ColCount do
                  begin
                    if not Progress.isRunning then
                      break;
                    DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));

                    // ID
                    if (UpperCase(DNT_sql_col) = 'ID') and (aItems[g].col_type = ftString) then // noslz
                      variant_Array[g] := IntToStr(x)

                    else // Attachment Count
                      if (UpperCase(DNT_sql_col) = 'ATTACHMENT_COUNT') and (Node2.PropName = 'attachments []') then // noslz
                      begin
                        AttachmentList := Node2.PropChildList;
                        if assigned(AttachmentList) and (AttachmentList.Count > 0) then
                          variant_Array[g] := IntToStr(AttachmentList.Count);
                      end

                      else // Attachment URLs
                        if (UpperCase(DNT_sql_col) = 'ATTACHMENT_URLS') and (Node2.PropName = 'attachments []') then // noslz
                        begin
                          Attachment_StringList.Clear;
                          Attachment_Frog(Node2, Attachment_StringList);
                          variant_Array[g] := Attachment_StringList.CommaText;
                        end

                        else // Column Match
                          if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
                            variant_Array[g] := Node2.PropDisplayValue

                          else // Date Time
                            if (UpperCase(Node2.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].read_as = ftLargeInt) then
                              try
                                if aItems[g].col_type = ftDateTime then
                                  variant_Array[g] := UnixTimeToDateTime(StrToInt(Node2.PropDisplayValue))
                                else
                                  variant_Array[g] := StrToInt(Node2.PropDisplayValue);
                              except
                                Progress.Log(ATRY_EXCEPT_STR + 'GroupMe');
                              end;

                  end;
                end;
              end;
            end;
            AddToModule;
          end;
        finally
          Attachment_StringList.free;
        end;
      end;
    end;
  end;

// Instagram Users - Node by Name Method -------------------------------------
  procedure Process_InstagramUsers;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_INSTAGRAM_USERS') and (UpperCase(Item^.fi_Name_OS) = UpperCase(ANDROID)) then
    begin
      tempstr := '';
      PropertyList := Node1.PropChildList;
      if assigned(PropertyList) then
        for x := 0 to PropertyList.Count - 1 do
        begin
          Node2 := TPropertyNode(PropertyList.items[x]);
          if assigned(Node2) and (Node2.PropName = 'string') and (POS('"user_info"', Node2.PropValue) > 0) then
          begin
            tempstr := Node2.PropValue;
            begin
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                if aItems[g].sql_col = 'DNT_User_ID' then
                  variant_Array[g] := PerlMatch('(?<="id":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_User_Name' then
                  variant_Array[g] := PerlMatch('(?<="username":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_Full_Name' then
                  variant_Array[g] := PerlMatch('(?<="full_name":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_Profile_Picture_URL' then
                  variant_Array[g] := PerlMatch('(?<="profile_pic_url":")([^"]*)(?=",")', tempstr);
              end;
            end;
          end;
        end;
      AddToModule;
    end;
  end;

// ooVoo User - Android (Node by Name Method) --------------------------------
  procedure Process_OovooUser_Android;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_OOVOO_USER') and (UpperCase(Item^.fi_Name_OS) = UpperCase(ANDROID)) then
    begin
      tempstr := '';
      PropertyList := Node1.PropChildList;
      if assigned(PropertyList) then
        for x := 0 to PropertyList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          Node2 := TPropertyNode(PropertyList.items[x]);
          if assigned(Node2) and (Node2.PropName = 'string') then
          begin
            tempstr := Node2.PropValue;
            begin
              for g := 1 to ColCount do
              begin
                if not Progress.isRunning then
                  break;
                if aItems[g].sql_col = 'DNT_birthday' then
                  variant_Array[g] := PerlMatch('(?<="birthday":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_displayName' then
                  variant_Array[g] := PerlMatch('(?<="displayName":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_friendCount' then
                  variant_Array[g] := PerlMatch('(?<="friendCount":)([^"]*)(?=,")', tempstr);
                if aItems[g].sql_col = 'DNT_gender' then
                  variant_Array[g] := PerlMatch('(?<="gender":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_id' then
                  variant_Array[g] := PerlMatch('(?<="id":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_phone' then
                  variant_Array[g] := PerlMatch('(?<="phone":")([^"]*)(?=",")', tempstr);
                if aItems[g].sql_col = 'DNT_profilePicURL' then
                  variant_Array[g] := PerlMatch('(?<="profilePicURL":")([^"]*)(?=",")', tempstr);
              end;
            end;
          end;
        end;
      AddToModule;
    end;
  end;

// ooVoo User - iOS (Node by Name Method) ------------------------------------
  procedure Process_OovooUser_IOS;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_OOVOO_USER') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
    begin
      for g := 1 to ColCount do
        variant_Array[g] := null; // Null the array
      for x := 0 to NumberOfNodes - 1 do
        for g := 1 to ColCount do
        begin
          if not Progress.isRunning then
            break;
          DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
          Node1 := TPropertyNode(NodeList1.items[x]);
          if DNT_sql_col = Node1.PropName then
            variant_Array[g] := Node1.PropDisplayValue;
        end;
      AddToModule;
    end;
  end;

// SnapChat User iOS - Node by Name Method -----------------------------------
  procedure Process_SnapChatUser_IOS;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_SNAPCHAT_USER') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
    begin
      for g := 1 to ColCount do
      begin
        if not Progress.isRunning then
          break;
        DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(DNT_sql_col));
        if assigned(Node1) then
          if (UpperCase(Node1.PropName) = UpperCase(DNT_sql_col)) and (aItems[g].col_type = ftString) then
            variant_Array[g] := Node1.PropDisplayValue;
      end;
      AddToModule;
    end;
  end;

// procedure - WhatsAppCalls -------------------------------------------------
  procedure Process_WhatsAppCalls;
  begin
    if (UpperCase(Item^.fi_Process_ID) = 'DNT_WHATSAPP_CALLS') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
    begin
      skip_bl := False;
      for g := 1 to ColCount do
        variant_Array[g] := null; // Null the array
      // Outer x loop
      for x := 0 to NodeList1.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        // Initialize
        temp_day := '';
        temp_month := '';
        temp_year := '';
        whatsapp_call_date := '';
        if not Progress.isRunning then
          break;
        Node2 := TPropertyNode(NodeList1.items[x]);
        if assigned(Node2) then
        begin
          if Node2.PropDisplayValue = '$null' then
            continue;
          NodeList2 := Node2.PropChildList;
          if assigned(NodeList2) then
          begin
            // Loop - Node List 2
            for y := 0 to NodeList2.Count - 1 do
            begin
              if not Progress.isRunning then
                break;
              // Skip if Node List 2 is not Call Detail
              Node3 := TPropertyNode(NodeList2.items[0]);
              if assigned(Node3) and (Node3.PropName = 'NS.objects') or (Node3.PropName = '$classname') then
              begin
                skip_bl := True;
                continue;
              end;
              // Process Node List 2 is Call Detail
              if assigned(Node3) and (Node3.PropName = 'peerJID') then
              begin
                if not Progress.isRunning then
                  break;
                Node3 := TPropertyNode(NodeList2.items[y]);
                if assigned(Node3) then
                begin
                  if Node3.PropName = RS_DNT_incoming then
                    if Node3.PropDisplayValue = RS_DNT_false then
                      variant_Array[6] := 'Outgoing'
                    else if Node3.PropDisplayValue = RS_DNT_true then
                      variant_Array[6] := 'Incoming';
                  if Node3.PropName = RS_DNT_duration then
                    try
                      duration_int := strtofloat(Node3.PropDisplayValue);
                      variant_Array[5] := FormatDateTime('hh:mm:ss', duration_int / secsperday);
                    except
                      Progress.Log(ATRY_EXCEPT_STR + 'Failed to convert string to hh:mm:ss');
                    end;
                  if Node3.PropName = RS_DNT_day then
                    temp_day := Node3.PropValue;
                  if Node3.PropName = RS_DNT_month then
                    temp_month := Node3.PropValue;
                  if Node3.PropName = RS_DNT_year then
                    temp_year := Node3.PropValue;
                end;
                whatsapp_call_date := temp_month + '\' + temp_day + '\' + temp_year;
                variant_Array[3] := whatsapp_call_date;
              end;
              // Process the Time node
              if (variant_Array[3] <> null) and (variant_Array[5] <> null) and (variant_Array[6] <> null) then // Don't do it if the call record was not previously found
              begin
                if assigned(Node3) and (Node3.PropName = 'NS.time') then
                begin
                  variant_Array[1] := MacAbsoluteTimeToDateTime(Trunc(strtofloat(Node3.PropDisplayValue))); // Converted Time
                  variant_Array[2] := (Node3.PropDisplayValue); // RAW Time
                end
                else
                  continue;
              end
              else
                continue;
            end;
            if skip_bl then
              continue;
          end;
          // THIS IS THE CALL AT NODE 2 LEVEL
          if (POS('whatsapp', Node2.PropValue) > 0) then
            variant_Array[4] := (Node2.PropDisplayValue);
          // Add to module only if a value for each column was collected
          if (variant_Array[1] <> null) and (variant_Array[2] <> null) and (variant_Array[3] <> null) and (variant_Array[4] <> null) and (variant_Array[5] <> null) and (variant_Array[6] <> null) then
            AddToModule;
          for g := 1 to ColCount do
            variant_Array[g] := null; // Null the array
          continue; // Move to the next iteration of x
        end;
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
                        Process_Burner_Cache_IOS;
                        Process_ByLock;
                        Process_Discord;
                        Process_Google_Chat_JSON_Takeout;
                        Process_Grindr;
                        Process_GroupMe;
                        Process_InstagramUsers;
                        Process_OovooUser_Android;
                        Process_OovooUser_IOS;
                        Process_SnapChatUser_IOS;
                        Process_WhatsAppCalls;
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

                          // Instagram Message - iOS
                          if (aItems[g].read_as = ftString) and (aItems[g].convert_as = UpperCase('Instagram')) then // noslz
                          begin
                            tempstr := ColumnValueByNameAsText(sqlselect, DNT_sql_col);
                            if aItems[g].fex_col = 'User Name' then
                              variant_Array[g] := PerlMatch('(?<="username":")([^"]*)(?=",")', tempstr);
                            if aItems[g].fex_col = 'Full Name' then
                              variant_Array[g] := PerlMatch('(?<="full_name":")([^"]*)(?=",")', tempstr);
                            if aItems[g].fex_col = 'Profile Picture URL' then
                              variant_Array[g] := PerlMatch('(?<="profile_pic_url":")([^"]*)(?=",")', tempstr);
                          end

                          else if aItems[g].read_as = ftString then
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

                          // Burner Contacts - iOS =============================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_CONTACTS') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'RECEIVER_DATA') then // If the column is Receiver_Data then get the entire blob data as bytes
                            begin
                              If (UpperCase(DNT_sql_col) = 'RECEIVER_DATA') then
                                nsp_data_str := variant_Array[g]; // Must read this first to perlmatch the data
                              burner_direct_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              blob_stream := TBytesStream.Create(burner_direct_bytes);
                              theTFileDriveClass := DetermineFileTypeStream(blob_stream);
                              if assigned(theTFileDriveClass) and (theTFileDriveClass.ClassName = 'TJSONDriver') then // Only process if it is a JSON blob
                              begin
                                temp_StringList := TStringList.Create;
                                try
                                  test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col); // Now get the JSON blob as text
                                  if trim(test_str) <> '' then
                                  begin
                                    temp_StringList.Add(test_str); // Put the text blob into a stringlist
                                    if assigned(temp_StringList) and (temp_StringList.Count = 1) and (trim(temp_StringList[0]) <> '') then
                                    begin
                                      if RegexMatch(temp_StringList[0], '"muted":', True) and RegexMatch(temp_StringList[0], '"dateCreated":', True) then
                                      begin
                                        for q := 0 to temp_StringList.Count - 1 do
                                        begin
                                        for h := 1 to ColCount do // Match each column with a line in the JSON record
                                        begin
                                        if (aItems[h].sql_col = 'DNT_DATECREATED') then // noslz
                                        begin
                                        temp_int_str := trim(PerlMatch('(?<="dateCreated":)(.*)(?=,)', temp_StringList[q]));
                                        if Length(temp_int_str) = 13 then
                                        try
                                        temp_int64 := StrToInt64(temp_int_str);
                                        temp_dt := UnixTimeToDateTime(temp_int64 div 1000);
                                        variant_Array[h] := temp_dt;
                                        except
                                        Progress.Log(ATRY_EXCEPT_STR);
                                        end
                                        else
                                        break; // Only add records with a date
                                        end;
                                        if (aItems[h].sql_col = 'DNT_CONTACTNAME') then
                                        variant_Array[h] := PerlMatch('(?<="name":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_PHONENUMBER') then
                                        variant_Array[h] := PerlMatch('(?<="phoneNumber":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_CONTACTID') then
                                        variant_Array[h] := PerlMatch('(?<="id":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_BLOCKED') then
                                        variant_Array[h] := PerlMatch('(?<="blocked":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_NOTES') then
                                        variant_Array[h] := PerlMatch('(?<="notes":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_USERID') then
                                        variant_Array[h] := PerlMatch('(?<="userId":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_BURNERIDS') then
                                        variant_Array[h] := PerlMatch('(?<="burnerId":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_IMAGES') then
                                        variant_Array[h] := PerlMatch('(?<="images":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_VERIFIED') then
                                        variant_Array[h] := PerlMatch('(?<="verified":")(.*)(?=")', temp_StringList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_MUTED') then
                                        variant_Array[h] := PerlMatch('(?<="muted":")(.*)(?=")', temp_StringList[q]); // noslz
                                        end;
                                        AddToModule;
                                        end;
                                      end;
                                    end;
                                  end;
                                finally
                                  temp_StringList.free;
                                end;
                              end;
                            end;
                          end;

                          // Burner Messages - iOS =============================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_MESSAGES') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'RECEIVER_DATA') then // If the column is Receiver_Data then get the entire blob data as bytes
                            begin
                              If (UpperCase(DNT_sql_col) = 'RECEIVER_DATA') then
                                nsp_data_str := variant_Array[g]; // Must read this first to perlmatch the data
                              burner_direct_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              blob_stream := TBytesStream.Create(burner_direct_bytes);
                              theTFileDriveClass := DetermineFileTypeStream(blob_stream);
                              if assigned(theTFileDriveClass) and (theTFileDriveClass.ClassName = 'TJSONDriver') then // Only process if it is a JSON blob
                              begin
                                temp_StringList := TStringList.Create;
                                try
                                  test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col); // Now get the JSON blob as text
                                  if trim(test_str) <> '' then
                                  begin
                                    temp_StringList.Add(test_str); // Put the text blob into a stringlist
                                    if assigned(temp_StringList) and (temp_StringList.Count = 1) and (trim(temp_StringList[0]) <> '') then
                                    begin
                                      if RegexMatch(temp_StringList[0], '"message":', True) then // noslz
                                      begin
                                        LineList := TStringList.Create;
                                        LineList.Delimiter := '}';
                                        LineList.StrictDelimiter := True; // More than one record in the blob
                                        try
                                        LineList.DelimitedText := temp_StringList[0]; // Now we can process each separate JSON record in the LineList
                                        for q := 0 to LineList.Count - 1 do
                                        begin
                                        if RegexMatch(LineList[0], '"dateCreated":', True) then // noslz
                                        begin
                                        for h := 1 to ColCount do // Match each column with a line in the JSON record
                                        begin
                                        if (aItems[h].sql_col = 'DNT_DATECREATED') then // noslz
                                        begin
                                        temp_int_str := trim(PerlMatch('(?<="dateCreated":)(.*)(?=,)', LineList[q]));
                                        if Length(temp_int_str) = 13 then
                                        try
                                        temp_int64 := StrToInt64(temp_int_str);
                                        temp_dt := UnixTimeToDateTime(temp_int64 div 1000);
                                        variant_Array[h] := temp_dt;
                                        except
                                        Progress.Log(ATRY_EXCEPT_STR);
                                        end
                                        else
                                        break; // Only add records with a date
                                        end;
                                        if (aItems[h].sql_col = 'DNT_MESSAGETYPE') then
                                        begin
                                        temp_str := trim(PerlMatch('(?<="messageType":)(.*)(?=,)', LineList[q]));
                                        if temp_str = '1' then
                                        variant_Array[h] := 'Call/Voice (1)'
                                        else if temp_str = '2' then
                                        variant_Array[h] := 'Text/Picture (2)'
                                        else
                                        variant_Array[h] := 'Unknown';
                                        end;
                                        if (aItems[h].sql_col = 'DNT_CONTACTPHONENUMBER') then
                                        variant_Array[h] := PerlMatch('(?<="contactPhoneNumber": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_USERID') then
                                        variant_Array[h] := PerlMatch('(?<="userId": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_BURNERID') then
                                        variant_Array[h] := PerlMatch('(?<="burnerId": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_MESSAGE') then
                                        variant_Array[h] := PerlMatch('(?<="message": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_DIRECTION') then
                                        variant_Array[h] := PerlMatch('(?<="direction": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_MEDIAURL') then
                                        variant_Array[h] := PerlMatch('(?<="mediaUrl": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_VOICEURL') then
                                        variant_Array[h] := PerlMatch('(?<="voiceUrl": ")(.*)(?=")', LineList[q]); // noslz
                                        if (aItems[h].sql_col = 'DNT_MESSAGEDURATION') then
                                        variant_Array[h] := PerlMatch('(?<="messageDuration": ")(.*)(?=")', LineList[q]); // noslz
                                        end;
                                        AddToModule;
                                        end;
                                        end;
                                        finally
                                        LineList.free;
                                        end;
                                      end;
                                    end;
                                  end;
                                finally
                                  temp_StringList.free;
                                end;
                              end;
                            end;
                          end;

                          // Google Voice - Android ============================
                          if (UpperCase(Item^.fi_Process_ID) = 'GOOGLE_VOICE_ANDROID') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'MESSAGE_BLOB') then // Get the blob data as bytes
                            begin
                              variant_Array[g] := '';
                              google_voice_blob_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              test_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              if Length(test_bytes) > 2 then
                              begin
                                if (test_bytes[0] = $0A) and (test_bytes[1] = $28) then
                                begin
                                  test_bytes_length := Length(test_bytes);
                                  for kk := 1 to test_bytes_length do
                                  begin
                                    if (test_bytes[kk] = $30) and (test_bytes[kk + 1] = $01) and (test_bytes[kk + 2] = $52) then
                                    begin
                                      sSize := test_bytes[kk + 3];
                                      test_str := '';
                                      for kkk := kk + 4 to (kk + 4 + sSize - 1) do
                                        test_str := test_str + chr(test_bytes[kkk]);
                                    end;
                                  end;
                                  if test_str <> '' then
                                    variant_Array[g] := test_str
                                end;
                              end;
                            end
                          end;

                          // Facebook Messenger Call Logs - Android ============
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_FACEBOOK_MESSENGER_CALL_LOGS_DB') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'CALL_TYPE') then
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Audio (1)'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Video (2)';

                            if (UpperCase(DNT_sql_col) = 'CALL_ROLE') then
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Outgoing (1)'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Incoming (2)';
                          end;

                          // Google Duo - Android ============================== //https://www.stark4n6.com/2021/08/google-duo-android-ios-forensic-analysis.html
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_GOOGLE_DUO') then
                          begin
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'OUTGOING') then
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := 'Incoming (0)'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Outgoing (1)'
                              else
                                variant_Array[g] := 'Unknown';

                            if (UpperCase(DNT_sql_col) = 'CALL_STATE') then
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := 'Left Message (0)'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Missed Call (1)'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Answered (2)'
                              else
                                variant_Array[g] := 'Unknown';

                            if (UpperCase(DNT_sql_col) = 'ACTIVITY_TYPE') then
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Call (1)'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Note (2)'
                              else if (variant_Array[g] = '4') then
                                variant_Array[g] := 'Reaction (4)'
                              else
                                variant_Array[g] := 'Unknown';
                          end;

                          // IMO Chat - iOS ====================================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_IMO_CHAT_IOS') then
                          begin
                            if (variant_Array[g] = '0') then
                              variant_Array[g] := 'Message'
                          end;

                          // Instagram Direct Message - iOS ====================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_INSTAGRAM_DIRECT') then // noslz
                          begin
                            instagram_direct_StringList := TStringList.Create;
                            try
                              if (DNT_sql_col = 'ARCHIVE') and (aItems[g].convert_as = 'IDIRECT') then // noslz
                              begin
                                Inc(z);
                                // Instagram Direct As Bytes
                                instagram_direct_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);

                                instagram_direct_direction_str := '';
                                instagram_direct_message_str := '';
                                instagram_direct_recipient_int := 0;
                                instagram_direct_sender_int := 0;
                                instagram_direct_type_str := '';

                                blob_stream := TBytesStream.Create(instagram_direct_bytes); // Get the blob
                                try
                                  try
                                    // Progress.Log(RPad('Instagram Blob Stream Size:', RPAD_VALUE) + IntToStr(blob_stream.size));
                                    theTFileDriveClass := DetermineFileTypeStream(blob_stream);
                                    if assigned(theTFileDriveClass) then
                                    begin
                                      instaProp := nil;
                                      if ProcessMetadataStream(blob_stream, instaProp, theTFileDriveClass) and assigned(instaProp) then
                                      begin
                                        aRootProperty := instaProp.RootProperty;
                                        Nodefrog(aRootProperty, 0, instagram_direct_StringList);

                                        // Instagram Direct - Date
                                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('NS.time'));
                                        if assigned(Node1) then
                                        begin
                                        instagram_direct_date_dt := MacAbsoluteTimeToDateTime(Trunc(strtofloat(Node1.PropDisplayValue)));
                                        end;

                                        // Instagram Direct - Sent or Received
                                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('NSString*senderPk')); // Sent or Received from Node
                                        if assigned(Node1) then
                                        begin
                                        instagram_direct_direction_str := Node1.PropDisplayValue; // https://seguridadyredes.wordpress.com/2019/09/23/breve-introduccion-a-las-sqlite-de-instagram/, 7 = Received, 8 = Sent
                                        end;

                                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName('$objects')); // Read only the $object children
                                        if assigned(Node1) then
                                        begin
                                        ChildNodeList := Node1.PropChildList;
                                        if assigned(ChildNodeList) then
                                        begin
                                        for k := 0 to ChildNodeList.Count - 1 do
                                        begin
                                        Node2 := TPropertyNode(ChildNodeList.items[k]);
                                        if Node2.PropDataType = 'UString' then
                                        begin
                                        if RegexMatch(Node2.PropDisplayValue, 'SUBTYPE_', False) then
                                        begin
                                        instagram_direct_type_str := Node2.PropDisplayValue;
                                        for p_int := 1 to 4 do
                                        begin
                                        PrevNode := TPropertyNode(ChildNodeList.items[k - p_int]);
                                        if assigned(PrevNode) and (PrevNode.PropDataType = 'UString') then
                                        begin
                                        if instagram_direct_type_str = 'SUBTYPE_TEXT' then
                                        instagram_direct_message_str := PrevNode.PropDisplayValue;
                                        end
                                        end;
                                        end;

                                        // Locate the ID numbers (Can be 3 or 4 numbers in a row)
                                        setlength(instagram_array_of_str, 4);
                                        if (Length(Node2.PropDisplayValue) = 35) and RegexMatch(Node2.PropDisplayValue, '^\d{35}$', False) then // Message ID = 35 digits
                                        begin
                                        instagram_array_of_str[0] := Node2.PropDisplayValue;
                                        if ChildNodeList.Count >= (k + 3) then
                                        for p := 1 to 3 do
                                        begin
                                        NextNode := TPropertyNode(ChildNodeList.items[k + p]);
                                        if RegexMatch(NextNode.PropDisplayValue, '^.{19,36}$', False) then
                                        instagram_array_of_str[1] := NextNode.PropDisplayValue; // Unknown = 19 to 36 and can be alpha-numeric
                                        if RegexMatch(NextNode.PropDisplayValue, '^\d{38,40}$', False) then
                                        instagram_array_of_str[2] := NextNode.PropDisplayValue; // Thread ID = 30 or 39 digits
                                        if RegexMatch(NextNode.PropDisplayValue, '^\d{8,12}$', False) then
                                        instagram_array_of_str[3] := NextNode.PropDisplayValue; // Instagram Sender ID = Between 8 and 12 digits
                                        end;
                                        end;
                                        end;
                                        end;
                                        end;
                                        end;
                                      end;
                                    end;
                                  finally
                                    blob_stream.free;
                                  end;
                                except
                                  Progress.Log(ATRY_EXCEPT_STR + 'Instagram Direct error');
                                end;
                              end;
                              for g := 1 to ColCount do
                                try
                                  if not Progress.isRunning then
                                    break;
                                  DNT_sql_col := aItems[g].sql_col;
                                  if UpperCase(DNT_sql_col) = 'DNT_TIMESTAMP' then
                                    variant_Array[g] := instagram_direct_date_dt;
                                  if UpperCase(DNT_sql_col) = 'DNT_MESSAGE' then
                                    variant_Array[g] := instagram_direct_message_str;
                                  if UpperCase(DNT_sql_col) = 'DNT_MESSAGE_ID' then
                                    variant_Array[g] := 'Message ID';
                                  if UpperCase(DNT_sql_col) = 'DNT_THREAD_ID' then
                                    variant_Array[g] := instagram_array_of_str[2];
                                  if UpperCase(DNT_sql_col) = 'DNT_SENDER_ID' then
                                    variant_Array[g] := instagram_array_of_str[3];
                                  if UpperCase(DNT_sql_col) = 'DNT_TYPE' then
                                    variant_Array[g] := instagram_direct_type_str; // SUBTYPE_
                                  if UpperCase(DNT_sql_col) = 'DNT_SQLLOCATION' then
                                    variant_Array[g] := 'Table: ' + lowercase(Item^.fi_SQLPrimary_Tablestr) + ' (row ' + format('%.*d', [4, records_read_int]) + ')'; // noslz
                                except
                                  Progress.Log(ATRY_EXCEPT_STR + 'Error populating instagram direct variant array');
                                end;

                            finally
                              instagram_direct_StringList.free;
                            end;
                          end;

                          // Line Chat - Android ===============================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_LINE_ANDROID_CHAT') then
                          begin
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'TYPE') then
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Message (1)'
                              else if (variant_Array[g] = '4') then
                                variant_Array[g] := 'Call (4)'
                              else if (variant_Array[g] = '5') then
                                variant_Array[g] := 'Sticker (5)'
                              else
                                variant_Array[g] := 'Unknown';
                          end;

                          // Messenger iOS - Blob Text =========================
                          if (DNT_sql_col = 'msg_blob') and (aItems[g].convert_as = 'BlobText') then
                            variant_Array[g] := BlobText(ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col));

                          // MSTeams Chat ======================================
                          if UpperCase(Item^.fi_Process_ID) = 'DNT_MSTEAMS_CHAT' then
                          begin
                            if UpperCase(aItems[g].sql_col) = 'DNT_CONTENT' then // noslz
                            begin
                              variant_Array[g] := StringReplace(variant_Array[g], '<div>', '', [rfReplaceAll]); // noslz
                              variant_Array[g] := trim(StringReplace(variant_Array[g], '</div>', '', [rfReplaceAll])); // noslz
                            end;
                          end;

                          // Slack Android - Direct Message ====================
                          if UpperCase(Item^.fi_Process_ID) = 'DNT_SLACK_DIRECT_MESSAGES_ANDROID' then
                          begin
                            tempstr := '';
                            tempstr := ColumnValueByNameAsText(sqlselect, 'message_json');
                            if aItems[g].sql_col = 'DNT_MESSAGE' then
                              variant_Array[g] := PerlMatch('(?<="text":")([^"]*)(?=",")', tempstr);
                            if aItems[g].sql_col = 'DNT_TIMESTAMP' then
                              try
                                temp_flt := strtofloat(PerlMatch('(?<="ts":")([^"]*)(?=",")', tempstr));
                                variant_Array[g] := GHFloatToDateTime(temp_flt, 'UNIX');
                              except
                              end;
                          end;

                          // Skype Activity ====================================
                          if UpperCase(Item^.fi_Process_ID) = 'DNT_SKYPE_ACTIVITY' then
                          begin
                            if aItems[g].sql_col = 'DNT_NSP_DATA' then
                              tempstr := variant_Array[g];
                            if aItems[g].sql_col = 'DNT_ARRIVALTIME' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<="originalarrivaltime":")([^"]*)(?=",")', tempstr));
                            if aItems[g].sql_col = 'DNT_FROM' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<="from":")([^"]*)(?=")', tempstr));
                            if aItems[g].sql_col = 'DNT_MESSAGETYPE' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<="messagetype":")([^"]*)(?=",")', tempstr));
                            if aItems[g].sql_col = 'DNT_CONTENT' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<="content":")([^"]*)(?=",")', tempstr));
                            if aItems[g].sql_col = 'DNT_DURATION' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<=\<duration\>)([^"]*)(?=\<\/duration\>)', tempstr));
                            if aItems[g].sql_col = 'DNT_CONVERSATIONID' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<="conversationId":")([^"]*)(?=",")', tempstr));
                            if aItems[g].sql_col = 'DNT_CONVERSATIONLINK' then
                              variant_Array[g] := CleanUnicode(PerlMatch('(?<="conversationLink":")([^"]*)(?=",")', tempstr));
                          end;

                          // Skype Contacts ====================================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_SKYPE_CONTACTS_ANDROID') or (UpperCase(Item^.fi_Process_ID) = 'DNT_SKYPE_CONTACTS_IOS_V12LIVE') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'NSP_DATA') then
                              nsp_data_str := variant_Array[g]; // Must read this first to perlmatch the data
                            if aItems[g].sql_col = 'DNT_MRI' then
                              variant_Array[g] := PerlMatch('(?<={"MRI":"8:)([^"]*)(?=",")', nsp_data_str);
                            if (aItems[g].sql_col = 'DNT_FETCHEDDATE') and (aItems[g].read_as = ftLargeInt) and (aItems[g].col_type = ftDateTime) then
                            begin
                              temp_int_str := PerlMatch('(?<="fetchedDate":)([^"]*)(?=,)', nsp_data_str);
                              try
                                temp_int64 := StrToInt64(temp_int_str);
                                temp_dt := UnixTimeToDateTime(temp_int64 div 1000);
                                variant_Array[g] := temp_dt;
                              except
                                Progress.Log('Could not convert Android Skype Contact date/time.');
                              end;
                            end;
                            if aItems[g].sql_col = 'DNT_DISPLAYNAMEOVERRIDE' then
                              variant_Array[g] := PerlMatch('(?<="DISPLAYNAMEOVERRIDE":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_THUMBURL' then
                              variant_Array[g] := PerlMatch('(?<="THUMBURL":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_BIRTHDAY' then
                              variant_Array[g] := PerlMatch('(?<="BIRTHDAY":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_GENDER' then
                              variant_Array[g] := PerlMatch('(?<="gender":")([^"]*)(?=,)', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_ISBLOCKED' then
                              variant_Array[g] := PerlMatch('(?<="isBlocked":)([^"]*)(?=,)', nsp_data_str);
                          end;

                          // Skype Messages v12 Live ---------------------------
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_SKYPE_MESSAGES_IOS_V12LIVE') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'NSP_DATA') then
                              nsp_data_str := variant_Array[g]; // Must read this first to perlmatch the data
                            if aItems[g].sql_col = 'DNT_SKYPEID' then
                              variant_Array[g] := PerlMatch('(?<="id":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_ORIGINALARRIVALTIME' then
                              variant_Array[g] := PerlMatch('(?<="originalarrivaltime":")([^"]*)([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_MESSAGETYPE' then
                              variant_Array[g] := PerlMatch('(?<="messagetype":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_VERSION' then
                              variant_Array[g] := PerlMatch('(?<="version":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_COMPSETTIMIE' then
                              variant_Array[g] := PerlMatch('(?<="composetime":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CLIENTMESSAGEID' then
                              variant_Array[g] := PerlMatch('(?<="clientmessageid":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CONVERSATIONLINK' then
                              variant_Array[g] := PerlMatch('(?<="conversationLink":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CONTENT' then
                              variant_Array[g] := PerlMatch('(?<="content":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_TYPE' then
                              variant_Array[g] := PerlMatch('(?<="type":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CONVERSATIONID' then
                              variant_Array[g] := PerlMatch('(?<="conversationid":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_FROM' then
                              variant_Array[g] := PerlMatch('(?<="from":"}])(.*)(?=")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CUID' then
                              variant_Array[g] := PerlMatch('(?<="cuid":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CONVERSATIONID' then
                              variant_Array[g] := PerlMatch('(?<="conversationId":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CREATEDTIME' then
                              variant_Array[g] := PerlMatch('(?<="createdTime":)(.*)(?=,)', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CREATOR' then
                              variant_Array[g] := PerlMatch('(?<="creator":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_COMPOSETIME' then
                              variant_Array[g] := PerlMatch('(?<="composeTime")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_CONTENT' then
                              variant_Array[g] := PerlMatch('(?<="content":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_MESSAGETYPE' then
                              variant_Array[g] := PerlMatch('(?<="messagetype":")([^"]*)(?=",")', nsp_data_str);
                            if aItems[g].sql_col = 'DNT_ISMYMESSAGE' then
                              variant_Array[g] := PerlMatch('(?<="_isMyMessage":)(.*)(?=})', nsp_data_str);
                          end;

                          // SnapChat Android - Blob2 Text =====================
                          if (UpperCase(Item^.fi_Process_ID) = 'SNAPCHAT_MESSAGE_ANDROID_ARRYO') then
                          begin
                            if (DNT_sql_col = 'content_type') then
                            begin
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Text'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Media'
                              else
                                variant_Array[g] := 'Unknown';
                              snapchat_message_type_str := variant_Array[g];
                            end;
                            if (DNT_sql_col = 'message_content') then
                            begin
                              if (snapchat_message_type_str = 'Text') then // noslz
                              begin
                                Buffer := TProtoBufObject.Create;
                                try
                                  test_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                                  if Length(test_bytes) > 50 then
                                  begin
                                    Buffer.LoadFromBytes(test_bytes);
                                    pb_tag_int := Buffer.ReadTag;
                                    while (pb_tag_int <> 0) and (Progress.isRunning) do
                                    begin
                                      pb_tag_field_int := GetTagFieldNumber(pb_tag_int);
                                      case pb_tag_field_int of
                                        PBUFF_FIELD4:
                                        variant_Array[g] := ReadField4(Buffer);
                                      else
                                        Buffer.skipField(pb_tag_int);
                                      end;
                                      pb_tag_int := Buffer.ReadTag; // Read next Protobuf tag
                                    end;
                                  end;
                                finally
                                  Buffer.free;
                                end;
                              end
                              else
                                variant_Array[g] := '';
                            end;
                          end;

                          // SnapChat Android - Blob Text ======================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_SNAPCHAT_MESSAGE_ANDROID_MAIN') then
                          begin
                            if (DNT_sql_col = 'CONTENT') and (aItems[g].convert_as = 'SNAPBLOB') then
                            begin
                              test_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              if Length(test_bytes) > 0 then
                              begin
                                if (test_bytes[0] = $10) then
                                begin
                                  test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                                  test_str := trim(StrippedOfNonAscii(test_str));
                                  variant_Array[g] := test_str;
                                end
                                else
                                  variant_Array[g] := '';
                              end;
                            end;
                          end;

                          // Tango Direction ===================================  {Learning Android Forensics, 2015, Packt Publishing, Tango Analysis, Page 244}
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TANGO_CHAT') then
                          begin
                            // Direction
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'DIRECTION') then
                              if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Sent'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Received'
                              else
                                variant_Array[g] := 'Unknown';
                          end;

                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TANGO_CHAT') then
                          begin
                            // Payload
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'PAYLOAD') then
                            begin
                              tempstr := variant_Array[g];
                              SomeBytes := Decode64StringToBytes(tempstr);
                              newstr := '';
                              if high(SomeBytes) > 26 then
                                for iii := (26 + low(SomeBytes)) to high(SomeBytes) do
                                  if ((SomeBytes[iii] < $20) or (SomeBytes[iii] > $7F)) then
                                  begin
                                    if (SomeBytes[iii] = $0D) or (SomeBytes[iii] = $0A) then
                                      newstr := newstr + ' ';
                                  end
                                  else
                                    newstr := newstr + chr(SomeBytes[iii]);
                              // Progress.Log(IntToStr(length(SomeBytes)));
                              Progress.Log('');
                              Progress.Log(newstr);
                              variant_Array[g] := newstr;
                            end;
                          end;

                          // Tango Type ----------------------------------------
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TANGO_CHAT') then
                          begin
                            // Direction
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'TYPE') then
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := 'Plain Text'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Video Message'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Audio Message'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := 'Image'
                              else if (variant_Array[g] = '4') then
                                variant_Array[g] := 'Coordinates'
                              else if (variant_Array[g] = '5') then
                                variant_Array[g] := 'Voice Call'
                              else if (variant_Array[g] = '36') then
                                variant_Array[g] := 'Missed Call';
                          end;

                          // Telegram Android - Blob Bytes =====================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TELEGRAM_ANDROID') then
                          begin
                            if (DNT_sql_col = 'Data') and (aItems[g].convert_as = 'BlobBytes') then // noslz
                            begin
                              test_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              if (Length(test_bytes) >= 29) and (test_bytes[0] = $11) and (test_bytes[27] = $59) then
                              begin
                                sSize := test_bytes[28];
                                test_str := '';
                                for kk := 1 to sSize do
                                begin
                                  if ((kk + 28) > Length(test_bytes)) or (test_bytes[28 + kk] = 0) then
                                    break;
                                  test_str := test_str + chr(test_bytes[28 + kk]);
                                end;
                              end
                              else
                              begin
                                test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                                test_str := PerlMatch('(?<=\x38\x5E)([\x00-\x7F]+)(?=\x00\x00)', test_str);
                                test_str := StrippedOfNonAscii(test_str);
                                if trim(test_str) <> '' then
                                  variant_Array[g] := test_str;
                              end;
                              variant_Array[g] := test_str;
                            end; { Blob Bytes }
                          end;

                          // Telegram Android - Blob Bytes =====================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TELEGRAM_ANDROID_V2') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'DATE') and (aItems[g].read_as = ftLargeInt) then // noslz
                            begin
                              tmp_telegram_int64 := 0;
                              // This date from SQLite will match in the blob directly before the string size
                              tmp_telegram_int64 := ColumnValueByNameAsint64(sqlselect, DNT_sql_col);
                            end;

                            if (DNT_sql_col = 'Data') and (aItems[g].convert_as = 'BlobBytes') then // noslz
                            begin
                              test_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              if (Length(test_bytes) > 0) and (test_bytes[0] = $E0) then
                              begin
                                telegram_data_str := '';
                                for kk := 0 to Length(test_bytes) - 4 do
                                begin
                                  if pcardinal(@test_bytes[kk])^ = tmp_telegram_int64 then
                                  begin
                                    sSize := test_bytes[kk + 4];
                                    stPos := kk + 4;
                                    if (sSize > 0) and ((stPos + sSize) < Length(test_bytes)) then
                                    begin
                                      // telegram_data_str := anEncoding.UTF8.GetString(test_bytes,kk+5,sSize);
                                      // Progress.Log(telegram_data_str);
                                      for kk := 1 to sSize do
                                        telegram_data_str := telegram_data_str + chr(test_bytes[stPos + kk]);
                                    end;
                                    break;
                                  end;
                                end;
                                variant_Array[g] := telegram_data_str;
                              end;
                            end; { Blob Bytes }

                          end;

                          // Telegram iOS Chat - Blob Bytes ====================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TELEGRAM_IOS_CHAT') then
                          begin
                            if (DNT_sql_col = 'KEY1') and (aItems[g].convert_as = 'BlobBytes') then
                            begin
                              Telegram_bytes := ColumnValueByNameAsBlobBytes(sqlselect, 'KEY'); // noslz
                              // Date ------------------------------------------
                              try
                                Telegram_DT := GHFloatToDateTime(SwapInteger(pinteger(@Telegram_bytes[12])^), 'UNIX');
                                variant_Array[1] := Telegram_DT;
                              except
                                Progress.Log(RPad(ATRY_EXCEPT_STR, RPAD_VALUE) + 'Converting DateTime');
                              end;
                              // Chat ID ---------------------------------------
                              Telegram_int64 := SwapInt64(pint64(@Telegram_bytes[0])^); // Read 8 in reverse then swap
                              variant_Array[2] := IntToStr(Telegram_int64);
                              // Message ID ------------------------------------
                              Telegram_int64 := SwapInt64(pint64(@Telegram_bytes[16])^); // Read 8 in reverse then swap
                              variant_Array[3] := IntToStr(Telegram_int64);
                            end;
                            // Message Text ------------------------------------
                            if (DNT_sql_col = 'VALUE') and (aItems[g].convert_as = 'BlobBytes') then
                            begin
                              Telegram_bytes := ColumnValueByNameAsBlobBytes(sqlselect, 'VALUE'); // noslz
                              Telegram_msgLen := (pcardinal(@Telegram_bytes[5])^);
                              if Telegram_msgLen = 2 then // ?
                                Telegram_msgoffset := 36
                              else
                                Telegram_msgoffset := 28;
                              Telegram_msgLen := (pcardinal(@Telegram_bytes[Telegram_msgoffset])^);
                              if (Telegram_msgLen > Length(Telegram_bytes) - Telegram_msgoffset) then
                              begin
                                Telegram_msgoffset := 36;
                                Telegram_msgLen := (pcardinal(@Telegram_bytes[Telegram_msgoffset])^);
                              end;
                              if (Telegram_msgLen > Length(Telegram_bytes) - Telegram_msgoffset) then
                                Telegram_msgLen := 0;
                              if Telegram_msgLen > 0 then
                                variant_Array[4] := (BytesToString(Telegram_bytes, Telegram_msgoffset + 4, Telegram_msgLen));
                            end;
                          end;

                          // TextNow Chat - IOS ================================
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TEXTNOW_CHAT') then
                          begin
                            test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                            if (UpperCase(DNT_sql_col) = 'ZREAD') then // noslz
                              if test_str = '1' then
                                variant_Array[g] := 'No'
                              else
                                variant_Array[g] := 'Yes';
                            if (UpperCase(DNT_sql_col) = 'ZDIRECTION') then // noslz
                            begin
                              if test_str = '1' then
                                variant_Array[g] := 'Incoming'
                              else if test_str = '2' then
                                variant_Array[g] := 'Outgoing'
                              else
                                variant_Array[g] := 'Unknown';
                            end;
                          end;

                          // Tiktok Chat - Android
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TIKTOK_CHAT_ANDROID') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'CONTENT') then // noslz
                            begin
                              test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                              test_str := CleanUnicode(PerlMatch('(?<="text":")(.*)(?=")', test_str)); // noslz
                              variant_Array[g] := test_str;
                            end;
                          end;

                          // Tiktok Chat - IOS
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_TIKTOK_CHAT_IOS') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'HASREAD') then // noslz
                            begin
                              test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                              if test_str = '1' then
                                variant_Array[g] := 'Yes'
                              else
                                variant_Array[g] := 'No';
                            end;
                            if (UpperCase(DNT_sql_col) = 'CONTENT') then // noslz
                            begin
                              test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                              test_str := trim(StrippedOfNonAscii(test_str));
                              if test_str <> '' then
                              begin
                                test_str := PerlMatch('(?<="text":")(.*)(?=")', test_str); // noslz
                                if trim(test_str) <> '' then
                                  variant_Array[g] := CleanUnicode(test_str);
                              end;
                            end;
                          end;

                          // WhatsApp Android Direction ------------------------ //https://blog.group-ib.com/whatsapp_forensic_artifacts, https://www.academia.edu/31798603/Forensic_Analysis_of_WhatsApp_Messenger_on_Android_Smartphones
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_WHATSAPP_ANDROID_MESSAGES') then
                          begin
                            type_str := '';
                            if (UpperCase(DNT_sql_col) = 'KEY_FROM_ME') then
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := 'Incoming (0)'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Outgoing (1)'
                              else
                                variant_Array[g] := 'Unknown';

                            if (UpperCase(DNT_sql_col) = 'MEDIA_WA_TYPE') then
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := 'Text (0)'
                              else if (variant_Array[g] = '1') then
                                variant_Array[g] := 'Image (1)'
                              else if (variant_Array[g] = '2') then
                                variant_Array[g] := 'Audio (2)'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := 'Video (3)'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := 'Contact Card (4)'
                              else if (variant_Array[g] = '3') then
                                variant_Array[g] := 'Geo Position (5)'
                              else
                                variant_Array[g] := 'Unknown';

                            if (UpperCase(DNT_sql_col) = 'STATUS') then // https://arxiv.org/pdf/1507.07739.pdf 4.2.1
                              if (variant_Array[g] = '0') then
                                variant_Array[g] := 'Received (0)'
                              else if (variant_Array[g] = '4') then
                                variant_Array[g] := 'Waiting on the server (4)'
                              else if (variant_Array[g] = '5') then
                                variant_Array[g] := 'Received at the destination (5)'
                              else if (variant_Array[g] = '6') then
                                variant_Array[g] := 'Control Message (6)'
                              else
                                variant_Array[g] := 'Unknown';
                          end;

                          // Wire - Chat - Android
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_WIRE_CHAT_ANDROID') then
                          begin
                            if (UpperCase(DNT_sql_col) = 'CONTENT') then // noslz
                            begin
                              test_str := ColumnValueByNameAsBlobText(sqlselect, DNT_sql_col);
                              test_str := CleanUnicode(PerlMatch('(?<="content":")(.*)(?=")', test_str)); // noslz
                              variant_Array[g] := test_str;
                            end;
                          end;

                        end;
                        if not(UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_MESSAGES') and not(UpperCase(Item^.fi_Process_ID) = 'DNT_BURNER_IOS_CONTACTS') then
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

              // REGEX CARVE
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_CARVE) then
              begin
                if HeaderReader.OpenData(aArtifactEntry) and FooterReader.OpenData(aArtifactEntry) then
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
                          if CarvedEntryReader.OpenData(CarvedEntry) then
                          begin
                            CarvedEntryReader.Position := 0;
                            carved_str := CarvedEntryReader.AsPrintableChar(CarvedEntryReader.Size);
                            for g := 1 to ColCount do
                              variant_Array[g] := null; // Null the array
                            // Setup the PerRegex Searches
                            Re := TDIPerlRegEx.Create(nil);
                            Re.CompileOptions := [coCaseLess, coUnGreedy];
                            Re.SetSubjectStr(carved_str);

                            // Process DNT_SKYPE_CHATSYNC ========================
                            if (UpperCase(Item^.fi_Process_ID) = 'DNT_SKYPE_CHATSYNC') then
                            begin
                              Progress.Log(format(FORMAT_STR_HDR, [IntToStr(i + 1) + '.', 'Filename:', aArtifactEntry.EntryName, '', '']));
                              if assigned(aArtifactEntry.Parent.Parent) then
                              begin
                                Progress.Log(format(FORMAT_STR_HDR, ['', 'Folder Name:', aArtifactEntry.Parent.Parent.Parent.EntryName, '']));
                              end;
                              Progress.Log(format(FORMAT_STR_HDR, ['', 'Bates ID:', IntToStr(anEntry.ID), '']));

                              if HeaderReader.OpenData(aArtifactEntry) and FooterReader.OpenData(aArtifactEntry) then // Open the entry to search
                                try
                                  // Test ChatSync file signature
                                  HeaderReader.Position := 0;
                                  hexbytes_str := trim(HeaderReader.AsHexString(5));
                                  if hexbytes_str = '73 43 64 42 07' then
                                  begin
                                    Progress.Log(format(FORMAT_STR_HDR, ['', 'ChatSync File Header Valid:', hexbytes_str, '']));
                                    // Get the date from the header
                                    HeaderReader.Position := 5;
                                    chatsync_HdrDate_hex := trim(HeaderReader.AsHexString(4));
                                    HeaderReader.Position := 5;
                                    chatsync_HdrDate_int64 := HeaderReader.AsInteger;

                                    if DateCheck_Unix_10(chatsync_HdrDate_int64) then
                                    begin
                                      chatsync_HdrDate_dt := UnixTimeToDateTime(chatsync_HdrDate_int64);
                                      if (trim(DateTimeToStr(chatsync_HdrDate_dt)) <> '') then
                                      begin
                                        chatsync_HdrDate_str := (DateTimeToStr(chatsync_HdrDate_dt));
                                        Progress.Log(format(FORMAT_STR_HDR, ['', 'Header Date:', chatsync_HdrDate_hex, chatsync_HdrDate_str, '']));
                                      end
                                      else
                                        chatsync_HdrDate_str := '';
                                    end
                                    else
                                    begin
                                      Progress.Log(StringOfChar('-', CHAR_LENGTH));
                                      continue;
                                    end;

                                    // Conversation Partners
                                    HeaderReader.Position := 52;
                                    chatsync_users_str := '';
                                    for j := 1 to 100 do
                                    begin
                                      chatsync_char := HeaderReader.AsPrintableChar(1);
                                      chatsync_users_str := chatsync_users_str + chatsync_char;
                                      if chatsync_char = ';' then
                                        break;
                                    end;
                                    if j < 100 then
                                      Progress.Log(format(FORMAT_STR_HDR, ['', 'Conversation Partners:', chatsync_users_str, '']));

                                    // Record Count
                                    h_startpos := 0;
                                    HeaderReader.Position := 0;
                                    HeaderRegex.Stream := HeaderReader;
                                    HeaderRegex.Find(h_offset, h_count); // Find the first match, h_offset returned is relative to start pos
                                    while h_offset <> -1 do // h_offset returned as -1 means no hit
                                      try
                                        if not Progress.isRunning then
                                        break;
                                        HeaderReader.Position := h_startpos + h_offset + 3;
                                        record_count := record_count + 1;
                                        HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match for the current file
                                      except
                                        Progress.Log(ATRY_EXCEPT_STR + RPad('!!!!!!!ERROR!!!!!!! - IN RECORD COUNT:', RPAD_VALUE) + anEntry.EntryName);
                                      end;
                                    Progress.Log(format(FORMAT_STR_HDR, ['', 'Expected Record Count:', IntToStr(record_count), '']));
                                    Progress.Log(StringOfChar('-', CHAR_LENGTH));

                                    Progress.Initialize(anEntry.PhysicalSize, 'Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ' + anEntry.EntryName);
                                    chatsync_message_found_count := 0;
                                    h_startpos := 0;
                                    HeaderReader.Position := 0;
                                    HeaderRegex.Stream := HeaderReader;
                                    FooterRegEx.Stream := FooterReader;
                                    HeaderRegex.Find(h_offset, h_count); // Find the first match, h_offset returned is relative to start pos
                                    while h_offset <> -1 do // h_offset returned as -1 means no hit
                                      try
                                        // Found a Regex Header ========================================
                                        if not Progress.isRunning then
                                        break;
                                        HeaderReader.Position := h_startpos + h_offset + 3;

                                        // Now look for Regex Footer -----------------------------------------
                                        FooterRegEx.Stream.Position := HeaderReader.Position;
                                        end_pos_max := HeaderReader.Position + 512; // Limit looking for the footer to our max size
                                        if end_pos_max >= HeaderRegex.Stream.Size then
                                        end_pos_max := HeaderRegex.Stream.Size - 1; // Don't go past the end!
                                        FooterRegEx.Stream.Size := end_pos_max;
                                        FooterRegEx.Find(f_offset, f_count);

                                        if (f_offset <> -1) and (f_offset + f_count >= 0) then // Found a footer and the size was at least our minimum
                                        begin
                                        // Found Footer ==============================================
                                        chatsync_beg_int64 := HeaderReader.Position;
                                        chatsync_end_int64 := chatsync_beg_int64 + f_offset + f_count - 1; // -1 is the length of the footer search term

                                        // Read the message as printable char ************************
                                        chatsync_msg_str := HeaderReader.AsPrintableChar(chatsync_end_int64 - HeaderReader.Position); // Header reader is now at the end of the message.
                                        if trim(chatsync_msg_str) <> '' then
                                        begin

                                        // Walk back to the marker to work out the position of the record date/time
                                        walk_back_pos := HeaderReader.Position;
                                        for j := 1 to 10000 do
                                        begin
                                        walk_back_pos := walk_back_pos - 1;
                                        HeaderReader.Position := walk_back_pos;
                                        if HeaderReader.Position < 0 then
                                        break; // Do not go past the beginning of the file
                                        hexbytes_str := trim(HeaderReader.AsHexString(4));
                                        if hexbytes_str = '41 01 05 02' then
                                        begin
                                        HeaderReader.Position := HeaderReader.Position - 16;
                                        break;
                                        end;
                                        end;

                                        chatsync_MsgDate_int64 := HeaderReader.AsInteger;
                                        if DateCheck_Unix_10(chatsync_MsgDate_int64) then
                                        begin
                                        chatsync_MsgDate_str := '';
                                        chatsync_MsgDate_dt := UnixTimeToDateTime(chatsync_MsgDate_int64);
                                        if (trim(DateTimeToStr(chatsync_MsgDate_dt)) <> '') then
                                        chatsync_MsgDate_str := (DateTimeToStr(chatsync_MsgDate_dt));
                                        end;

                                        // Print the header only for first found record
                                        chatsync_message_found_count := chatsync_message_found_count + 1;
                                        if chatsync_message_found_count = 1 then
                                        begin
                                        Progress.Log(format(FORMAT_STR, ['', '#', 'Date/Time', 'Message Offset', 'Message']));
                                        Progress.Log(format(FORMAT_STR, ['', '-', '---------', '--------------', '-------']));
                                        end;

                                        // Print the record !!!
                                        Progress.Log(format(FORMAT_STR, ['', IntToStr(chatsync_message_found_count) + '.', chatsync_MsgDate_str, IntToStr(chatsync_beg_int64) + HYPHEN_NS + IntToStr(chatsync_end_int64), chatsync_msg_str]));

                                        try
                                        variant_Array[1] := chatsync_MsgDate_dt;
                                        except
                                        variant_Array[1] := 0;
                                        end;

                                        try
                                        variant_Array[2] := chatsync_users_str;
                                        except
                                        variant_Array[2] := '';
                                        end;

                                        try
                                        variant_Array[3] := chatsync_msg_str;
                                        except
                                        variant_Array[3] := '';
                                        end;

                                        AddToModule;

                                        end;
                                        end;

                                        HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match for the current file
                                      except
                                        Progress.Log(ATRY_EXCEPT_STR + RPad('!!!!!!!ERROR!!!!!!! - IN PROCESS LOOP:', RPAD_VALUE) + anEntry.EntryName);
                                      end;
                                  end;
                                except
                                  Progress.Log(ATRY_EXCEPT_STR + RPad('!!!!!!!ERROR!!!!!!! - COULD NOT OPEN:', RPAD_VALUE) + anEntry.EntryName);
                                end;
                              if chatsync_message_found_count = 0 then
                                Progress.Log(PAD + 'No messages.');
                              Progress.Log(StringOfChar('=', CHAR_LENGTH));
                            end;

                            // Process DNT_TELEGRAM_IOS_USER =====================
                            if (UpperCase(Item^.fi_Process_ID) = 'DNT_TELEGRAM_IOS_USER') then
                            begin
                              // User ID -----------------------------------------
                              CarvedEntryReader.Position := 12;
                              if trim(CarvedEntryReader.AsHexString(1)) = '69' then // noslz - Finds 'i' for Telegram ID
                              begin
                                CarvedEntryReader.Position := 14; // Gets the ID from position 14 + 4 bytes
                                CarvedEntryReader.Read(Telegram_UserID, 4);
                                variant_Array[1] := IntToStr(Telegram_UserID);
                              end;
                              // First Name --------------------------------------
                              Re.MatchPattern := '(?<=\.fn\.)(.*)(?=(\.ln\.|\.p\.|\.un\.))'; // noslz - regex carved_str
                              if Re.Match(0) >= 0 then
                              begin
                                temp_str := StringReplace(Re.matchedstr, '..', '', [rfReplaceAll]);
                                variant_Array[2] := trim(temp_str);
                              end;
                              // Last Name ---------------------------------------
                              Re.MatchPattern := '(?<=\.ln\.)(.*)(?=\.p\.|\.un\.)'; // noslz - regex carved_str
                              if Re.Match(0) >= 0 then
                              begin
                                temp_str := StringReplace(Re.matchedstr, '..', '', [rfReplaceAll]);
                                variant_Array[3] := trim(temp_str);
                              end;
                              // User Name ---------------------------------------
                              Re.MatchPattern := '(?<=\.un\.)(.*)(?=\.p\.|\.ph\.)'; // noslz - regex carved_str
                              if Re.Match(0) >= 0 then
                              begin
                                temp_str := StringReplace(Re.matchedstr, '..', '', [rfReplaceAll]);
                                variant_Array[4] := trim(temp_str);
                              end;
                              // Phone Number ------------------------------------
                              Re.MatchPattern := '(?<=\.p\.)(.*)(?=\.ph\.)'; // noslz - regex carved_str
                              if Re.Match(0) >= 0 then
                              begin
                                temp_str := StringReplace(Re.matchedstr, '..', '', [rfReplaceAll]);
                                variant_Array[5] := trim(temp_str);
                              end;
                              variant_Array[6] := 'carved sql'; // noslz
                            end;
                            if assigned(Re) then
                              FreeAndNil(Re);
                            AddToModule;

                            // Process Instagram =================================
                            if (UpperCase(Item^.fi_Process_ID) = 'DNT_INSTAGRAM_CONTACTS') then
                            begin
                              // ID ----------------------------------------------
                              Re.MatchPattern := '(?<=\.{29}[A-Z])(\d{5,10})(?=\xD3)'; // noslz
                              if Re.Match(0) >= 0 then
                                variant_Array[2] := Re.matchedstr;
                              // URL----------------------------------------------
                              Re.MatchPattern := 'https:(\/\/instagram).*(\d{8}_).*_[a-z]\.jpg';
                              if Re.Match(0) >= 0 then
                                variant_Array[3] := Re.matchedstr;
                              // NAME---------------------------------------------
                              temp_str := '';
                              Re.MatchPattern := '\d{19}.' + variant_Array[2] + '.*\.\.\.\.\.\.';
                              if Re.Match(0) >= 0 then
                              begin
                                temp_str := Re.matchedstr;
                                Delete(temp_str, 1, 19);
                                temp_str := StringReplace(temp_str, '_' + variant_Array[2], '', [rfReplaceAll]);
                                Delete(temp_str, 1, 1);
                                StripIllegalChars(temp_str);
                                temp_str := StringReplace(temp_str, '..', '', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '\', ' ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '[', ' ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, ']', ' ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '^', ' ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '#@', ' ', [rfReplaceAll]);
                                temp_str := StringReplace(temp_str, '_.J', ' ', [rfReplaceAll]);
                                if temp_str[1] = '_' then
                                  Delete(temp_str, 1, 1);
                                if (temp_str[Length(temp_str)]) = '_' then
                                  setlength(temp_str, Length(temp_str) - 1);
                                trim(temp_str);
                                variant_Array[1] := temp_str;
                              end;
                            end;
                            if assigned(Re) then
                              FreeAndNil(Re);
                            AddToModule;
                          end;
                        end;
                      end;
                      HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match
                    end;
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error processing ' + aArtifactEntry.EntryName);
                  end; { Regex Carve }
              end;

              // ================================================================
              // YAHOO MESSENGER DAT
              // ================================================================
              // https://cryptome.org/isp-spy/yahoo-chat-spy.pdf
              // http://www.0xcafefeed.com/2007/12/yahoo-messenger-archive-file-format/

              if (UpperCase(Item^.fi_Process_ID) = 'DNT_YAHOO_MESSENGER') then
              begin
                newEntryReader.Position := 0;

                Progress.Log('Processing: ' + aArtifactEntry.EntryName);

                // Get the Archive Name from the folder ------------------------
                YahooName := '';
                if Length(aArtifactEntry.EntryName) > 13 then
                  YahooName := copy(aArtifactEntry.EntryName, 10, Length(aArtifactEntry.EntryName) - 13);

                while Progress.isRunning and (newEntryReader.Position < newEntryReader.Size) do
                begin
                  for g := 1 to ColCount do
                    variant_Array[g] := null; // Null the array

                  // Yahoo Date ------------------------------------------------
                  newEntryReader.Read(YahooDword, 4);
                  YahooDateTime := UnixTimeToDateTime(int64(YahooDword));
                  variant_Array[1] := YahooDateTime;

                  // Local User
                  variant_Array[2] := YahooName;

                  // Yahoo Type (06 = Searchable) ------------------------------
                  newEntryReader.Read(YahooType, 4);
                  if YahooType = 6 then
                    variant_Array[3] := 'Searchable'
                  else
                    variant_Array[3] := IntToStr(YahooType);

                  // Yahoo Sent/Received ---------------------------------------
                  newEntryReader.Read(YahooUser, 4);
                  if (YahooUser = 1) then
                    variant_Array[5] := 'Received'
                  else if (YahooUser = 0) then
                    variant_Array[5] := 'Sent'
                  else
                    variant_Array[5] := 'Unknown';

                  // Yahoo Message Length --------------------------------------
                  newEntryReader.Read(YahooMsgLength, 4);

                  // Decode Yahoo Message --------------------------------------
                  if (YahooMsgLength > 0) and (YahooMsgLength < 1000) then
                  begin
                    FillChar(YahooMsgBytes, 1000, 0);
                    newEntryReader.Read(YahooMsgBytes[1], YahooMsgLength);
                    if Length(YahooName) > 0 then
                    begin
                      cbyte := 1;
                      YahooDecodedMsg := '';
                      for yn := 1 to YahooMsgLength do
                      begin
                        cypherbyte := Ord(YahooName[cbyte]);
                        YahooMsgBytes[yn] := YahooMsgBytes[yn] xor cypherbyte;
                        Inc(cbyte);
                        if cbyte > Length(YahooName) then
                          cbyte := 1;
                        if YahooMsgBytes[yn] <> 0 then
                          YahooDecodedMsg := YahooDecodedMsg + chr(YahooMsgBytes[yn]);
                      end;
                      variant_Array[4] := (YahooDecodedMsg);
                    end;
                  end
                  else if YahooMsgLength <> 0 then
                    break;

                  // Yahoo Terminator Length -----------------------------------
                  newEntryReader.Read(YahooTermLength, 4);

                  // Get Conference User ---------------------------------------
                  YahooConfUser_str := '';
                  if (YahooTermLength > 0) and (YahooTermLength <= 255) then
                  begin
                    FillChar(YahooConfUserBytes[1], 1000, 0);
                    newEntryReader.Read(YahooConfUserBytes[1], YahooTermLength);
                    for g := 1 to YahooTermLength do
                      YahooConfUser_str := YahooConfUser_str + chr(YahooConfUserBytes[g]);
                  end;

                  // Other User ------------------------------------------------
                  if YahooConfUser_str <> '' then
                    variant_Array[6] := YahooConfUser_str
                  else
                    variant_Array[6] := (aArtifactEntry.Parent.EntryName);

                  // Archive Folder --------------------------------------------
                  variant_Array[7] := aArtifactEntry.Parent.EntryName;

                  // Archive Type ----------------------------------------------
                  variant_Array[8] := aArtifactEntry.Parent.Parent.EntryName;

                  AddToModule;
                end; { while }
              end; { Yahoo Messenger.dat }

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
              FindEntries_StringList.Add('**\.oovoo_preferences\**\*');
              FindEntries_StringList.Add('**\account_manager*');
              FindEntries_StringList.Add('**\arroyo*');
              FindEntries_StringList.Add('**\Application\**\Documents\*');
              FindEntries_StringList.Add('**\app_database');
              FindEntries_StringList.Add('**\bugle_db*');
              FindEntries_StringList.Add('**\burner\fsCachedData\*');
              FindEntries_StringList.Add('**\call_logs_db_*');
              FindEntries_StringList.Add('**\chatsync\**\*.dat');
              FindEntries_StringList.Add('**\com.adhoclabs.burner\fsCachedData\*');
              FindEntries_StringList.Add('**\com.hammerandchisel.discord\fsCachedData\*');
              FindEntries_StringList.Add('**\com.instagram\**\*');
              FindEntries_StringList.Add('**\com.wire\databases\**\*');
              FindEntries_StringList.Add('**\Contacts*');
              FindEntries_StringList.Add('**\contacts_db2*');
              FindEntries_StringList.Add('**\D3650B29-0CAA-4560-B736-D92803B8A2B2'); // Discord
              FindEntries_StringList.Add('**\DataStore');
              FindEntries_StringList.Add('**\db*');
              FindEntries_StringList.Add('**\db_sqlite');
              FindEntries_StringList.Add('**\discord\fsCachedData\*');
              FindEntries_StringList.Add('**\grindrapp*');
              FindEntries_StringList.Add('**\LegacyMsgDbInstance*');
              FindEntries_StringList.Add('**\main_db');
              FindEntries_StringList.Add('**\messages.json*');
              FindEntries_StringList.Add('**\group_info.json*');
              FindEntries_StringList.Add('**\MobileSync\**\*'); // All iTunes folder
              FindEntries_StringList.Add('**\naver_line*');
              FindEntries_StringList.Add('**\orca*');
              FindEntries_StringList.Add('**\skout*');
              FindEntries_StringList.Add('**\com.Slack\databases\*');
              FindEntries_StringList.Add('**\store.wiredatabase*');
              FindEntries_StringList.Add('**\threads_db2*');
              FindEntries_StringList.Add('**\viber*');
              FindEntries_StringList.Add('**\yahoo!\Messenger\\**\*');
              FindEntries_StringList.Add('**\zalo*');

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

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Android_Messages.GetTable('ANDROID_ACCOUNTS'));
            Ref_Num := 2;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Android_Messages.GetTable('ANDROID_CALL_LOGS'));
            Ref_Num := 3;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Android_Messages.GetTable('ANDROID_MESSAGES'));
            Ref_Num := 4;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Anti_Chat.GetTable('ANTICHAT_CHAT_IOS'));
            Ref_Num := 5;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Badoo.GetTable('BADOO_CHAT_ANDROID'));
            Ref_Num := 6;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Burner.GetTable('BURNER_CACHE_IOS'));
            Ref_Num := 7;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Burner.GetTable('BURNER_CONTACTS_ANDROID'));
            Ref_Num := 8;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Burner.GetTable('BURNER_CONTACTS_IOS'));
            Ref_Num := 9;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Burner.GetTable('BURNER_MESSAGES_ANDROID'));
            Ref_Num := 10;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Burner.GetTable('BURNER_MESSAGES_IOS'));
            Ref_Num := 11;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Burner.GetTable('BURNER_NUMBERS_ANDROID'));
            Ref_Num := 12;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, ByLock.GetTable('BYLOCK_APPPREFFILE_ANDROID'));
            Ref_Num := 13;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Coco.GetTable('COCO_CHAT_ANDROID'));
            Ref_Num := 14;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Coco.GetTable('COCO_CHAT_IOS'));
            Ref_Num := 15;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Coco.GetTable('COCO_CONTACT_IOS'));
            Ref_Num := 16;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Coco.GetTable('COCO_FRIEND_ANDROID'));
            Ref_Num := 17;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Coco.GetTable('COCO_FRIEND_IOS'));
            Ref_Num := 18;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Coco.GetTable('COCO_USER_ANDROID'));
            Ref_Num := 19;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Couple_Relationship.GetTable('COUPLE_RELATIONSHIP_CHAT_IOS'));
            Ref_Num := 20;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Discord.GetTable('DISCORD_CHAT_IOS'));
            Ref_Num := 21;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, FacebookMessenger.GetTable('FACEBOOK_MESSENGER_CHAT_IOS'));
            Ref_Num := 22;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, FacebookMessenger.GetTable('FACEBOOK_MESSENGER_CALLS_ANDROID'));
            Ref_Num := 23;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, FacebookMessenger.GetTable('FACEBOOK_MESSENGER_THREADS_IOS'));
            Ref_Num := 24;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Fast_Hookup_Dating.GetTable('FAST_HOOKUP_DATING_CHAT_IOS'));
            Ref_Num := 25;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Fast_Hookup_Dating.GetTable('FAST_HOOKUP_DATING_USER_IOS'));
            Ref_Num := 26;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Gettr.GetTable('GETTR_CHAT_ANDROID'));
            Ref_Num := 27;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Google_Duo.GetTable('GOOGLE_DUO_CHAT_ANDROID'));
            Ref_Num := 28;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Google_Duo.GetTable('GOOGLE_DUO_CHAT_IOS'));
            Ref_Num := 29;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Google_Duo.GetTable('GOOGLE_DUO_USERS_IOS'));
            Ref_Num := 30;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GoogleChat.GetTable('GOOGLE_CHAT_ANDROID'));
            Ref_Num := 31;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GoogleChat.GetTable('DNT_GOOGLE_CHAT_JSON_TAKEOUT'));
            Ref_Num := 32;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GoogleVoice.GetTable('GOOGLE_VOICE_ANDROID'));
            Ref_Num := 33;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Grindr.GetTable('GRINDR_CHAT_ANDROID'));
            Ref_Num := 34;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Grindr.GetTable('GRINDR_CHAT_IOS'));
            Ref_Num := 35;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Grindr.GetTable('GRINDR_PREFERENCES_ANDROID'));
            Ref_Num := 36;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GroupMe.GetTable('GROUPME_CHAT_JSON'));
            Ref_Num := 37;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GroupMe.GetTable('GROUPME_CHAT_ANDROID'));
            Ref_Num := 38;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GroupMe.GetTable('GROUPME_CHAT_IOS'));
            Ref_Num := 39;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GroupMe.GetTable('GROUPME_CONTACTS_ANDROID'));
            Ref_Num := 40;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Growlr.GetTable('GROWLR_CHAT_ANDROID'));
            Ref_Num := 41;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Growlr.GetTable('GROWLR_CHAT_IOS'));
            Ref_Num := 42;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, HelloTalk.GetTable('HELLOTALK_CHAT_IOS'));
            Ref_Num := 43;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, iMessage.GetTable('IMESSAGE_ATTACHMENTS_OSX'));
            Ref_Num := 44;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, iMessage.GetTable('IMESSAGE_MESSAGE_OSX'));
            Ref_Num := 45;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IMO.GetTable('IMO_CALLS_ANDROID'));
            Ref_Num := 46;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IMO.GetTable('IMO_CHAT_ANDROID'));
            Ref_Num := 47;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IMO.GetTable('IMO_CHAT_IOS'));
            Ref_Num := 48;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IMO.GetTable('IMO_CONTACTS_ANDROID'));
            Ref_Num := 49;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IMO.GetTable('IMO_CONTACTS_IOS'));
            Ref_Num := 50;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Instagram.GetTable('INSTAGRAM_CHAT_ANDROID'));
            Ref_Num := 51;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Instagram.GetTable('INSTAGRAM_CONTACTS_IOS'));
            Ref_Num := 52;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Instagram.GetTable('INSTAGRAM_DIRECT_MESSAGE_CHAT_IOS'));
            Ref_Num := 53;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Instagram.GetTable('INSTAGRAM_GROUP_MEMBERS_IOS'));
            Ref_Num := 54;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Instagram.GetTable('INSTAGRAM_USERS_ANDROID'));
            Ref_Num := 55;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kakao.GetTable('KAKAO_CHAT_ANDROID'));
            Ref_Num := 56;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kakao.GetTable('KAKAO_CHAT_IOS'));
            Ref_Num := 57;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kik.GetTable('KIK_ATTACHMENTS_IOS'));
            Ref_Num := 58;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kik.GetTable('KIK_ATTACHMENTS_ANDROID'));
            Ref_Num := 59;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kik.GetTable('KIK_CHAT_ANDROID'));
            Ref_Num := 60;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kik.GetTable('KIK_CHAT_IOS'));
            Ref_Num := 61;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kik.GetTable('KIK_CONTACTS_ANDROID'));
            Ref_Num := 62;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Kik.GetTable('KIK_CONTACTS_IOS'));
            Ref_Num := 63;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Line.GetTable('LINE_CHAT_ANDROID'));
            Ref_Num := 64;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Line.GetTable('LINE_CHAT_IOS'));
            Ref_Num := 65;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Line.GetTable('LINE_CONTACTS_ANDROID'));
            Ref_Num := 66;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Line.GetTable('LINE_CONTACTS_IOS'));
            Ref_Num := 67;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Line.GetTable('LINE_TALK_IOS'));
            Ref_Num := 68;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, MeetMe.GetTable('MEETME_CHAT_IOS'));
            Ref_Num := 69;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, MessageMe.GetTable('MESSAGEME_CHAT_IOS'));
            Ref_Num := 70;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Messenger.GetTable('MESSENGER_CALL_LOG_ANDROID'));
            Ref_Num := 71;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Messenger.GetTable('MESSENGER_CHAT_ANDROID'));
            Ref_Num := 72;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Messenger.GetTable('MESSENGER_CHAT_IOS'));
            Ref_Num := 73;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Messenger.GetTable('MESSENGER_CONTACTS_ANDROID'));
            Ref_Num := 74;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Messenger.GetTable('MESSENGER_THREADS_ANDROID'));
            Ref_Num := 75;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, MeWe.GetTable('MEWE_CHAT_ANDROID'));
            Ref_Num := 76;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, MSTeams.GetTable('MSTEAMS_MESSAGE_ANDROID'));
            Ref_Num := 77;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, MSTeams.GetTable('MSTEAMS_MESSAGES_IOS'));
            Ref_Num := 78;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, MSTeams.GetTable('MSTEAMS_USER_ANDROID'));
            Ref_Num := 79;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Oovoo.GetTable('OOVOO_USER_ANDROID'));
            Ref_Num := 80;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Oovoo.GetTable('OOVOO_USER_IOS'));
            Ref_Num := 81;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Random_Chat.GetTable('RANDOMCHAT_CHAT_IOS'));
            Ref_Num := 82;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Scruff.GetTable('SCRUFF_CHAT_ANDROID'));
            Ref_Num := 83;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Scruff.GetTable('SCRUFF_CHAT_IOS'));
            Ref_Num := 84;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skout.GetTable('SKOUT_CHAT_ANDROID'));
            Ref_Num := 85;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skout.GetTable('SKOUT_CHAT_IOS'));
            Ref_Num := 86;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_ACCOUNTS'));
            Ref_Num := 87;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_ACTIVITY'));
            Ref_Num := 88;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_CALLS'));
            Ref_Num := 89;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_CHATSYNC'));
            Ref_Num := 90;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_CONTACTS'));
            Ref_Num := 91;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_CONTACTS_V12_LIVE'));
            Ref_Num := 92;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_CONTACTS_V12'));
            Ref_Num := 93;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_CONTACTS_ANDROID'));
            Ref_Num := 94;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_MESSAGES'));
            Ref_Num := 95;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_MESSAGES_V12_LIVE'));
            Ref_Num := 96;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_MESSAGES_V12'));
            Ref_Num := 97;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Skype.GetTable('SKYPE_TRANSFERS'));
            Ref_Num := 98;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Slack.GetTable('SLACK_ACCOUNTS_ANDROID'));
            Ref_Num := 99;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Slack.GetTable('SLACK_ACCOUNTS_IOS'));
            Ref_Num := 100;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Slack.GetTable('SLACK_DEPRECATED_MESSAGES_IOS'));
            Ref_Num := 101;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Slack.GetTable('SLACK_DIRECT_MESSAGES_ANDROID'));
            Ref_Num := 102;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Slack.GetTable('SLACK_DIRECT_MESSAGES_IOS'));
            Ref_Num := 103;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Slack.GetTable('SLACK_USERS_IOS'));
            Ref_Num := 104;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_CHAT_ANDROID_TCSPAHN'));
            Ref_Num := 105;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_FRIEND_ANDROID'));
            Ref_Num := 106;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_FRIENDS_ANDROID'));
            Ref_Num := 107;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_MEMORIES_ANDROID'));
            Ref_Num := 108;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_MESSAGE_ANDROID_MAIN'));
            Ref_Num := 109;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_MESSAGE_ANDROID_ARROYO'));
            Ref_Num := 110;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, SnapChat.GetTable('SNAPCHAT_USER_IOS'));
            Ref_Num := 111;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tango.GetTable('TANGO_CHAT_ANDROID'));
            Ref_Num := 112;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Telegram.GetTable('TELEGRAM_CHAT_ANDROID'));
            Ref_Num := 113;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Telegram.GetTable('TELEGRAM_CHAT_ANDROID')); {V2}
            Ref_Num := 114;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Telegram.GetTable('TELEGRAM_CHAT_IOS'));
            Ref_Num := 115;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Telegram.GetTable('TELEGRAM_T7_CHAT_IOS'));
            Ref_Num := 116;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Telegram.GetTable('TELEGRAM_USER_IOS'));
            Ref_Num := 117;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, TextNow.GetTable('TEXTNOW_CHAT_ANDROID'));
            Ref_Num := 118;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, TextNow.GetTable('TEXTNOW_CHAT_IOS'));
            Ref_Num := 119;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, TextNow.GetTable('TEXTNOW_CONTACTS_ANDROID'));
            Ref_Num := 120;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, TextNow.GetTable('TEXTNOW_CONTACTS_IOS'));
            Ref_Num := 121;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, TextNow.GetTable('TEXTNOW_PROFILE_IOS'));
            Ref_Num := 122;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Threema.GetTable('THREEMA_CHAT_IOS'));
            Ref_Num := 123;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tiktok.GetTable('TIKTOK_CHAT_ANDROID'));
            Ref_Num := 124;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tiktok.GetTable('TIKTOK_CHAT_IOS'));
            Ref_Num := 125;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tiktok.GetTable('TIKTOK_CONTACTS_IOS'));
            Ref_Num := 126;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tinder.GetTable('TINDER_CHAT_ANDROID'));
            Ref_Num := 127;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tinder.GetTable('TINDER_CHAT_IOS'));
            Ref_Num := 128;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tinder.GetTable('TINDER_MATCH_ANDROID'));
            Ref_Num := 129;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tinder.GetTable('TINDER_PHOTO_ANDROID'));
            Ref_Num := 130;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tinder.GetTable('TINDER_USER_ANDROID'));
            Ref_Num := 131;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tinder.GetTable('TINDER_USER_IOS'));
            Ref_Num := 132;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Touch.GetTable('TOUCH_CHAT_IOS'));
            Ref_Num := 133;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Tumblr.GetTable('TUMBLR_CHAT_IOS'));
            Ref_Num := 134;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Venmo.GetTable('VENMO_CHAT_ANDROID'));
            Ref_Num := 135;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Viber.GetTable('VIBER_CHAT_ANDROID'));
            Ref_Num := 136;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Viber.GetTable('VIBER_CHAT_IOS'));
            Ref_Num := 137;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Viber.GetTable('VIBER_CHAT_PC'));
            Ref_Num := 138;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Viber.GetTable('VIBER_CHAT_PC_V11'));
            Ref_Num := 139;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WhatsApp.GetTable('WHATSAPP_CALLS_IOS'));
            Ref_Num := 140;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WhatsApp.GetTable('WHATSAPP_CHAT_ANDROID'));
            Ref_Num := 141;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WhatsApp.GetTable('WHATSAPP_CHAT_IOS'));
            Ref_Num := 142;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WhatsApp.GetTable('WHATSAPP_CONTACTS_ANDROID'));
            Ref_Num := 143;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WhatsApp.GetTable('WHATSAPP_CONTACTS_IOS'));
            Ref_Num := 144;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, WhatsApp.GetTable('WHATSAPP_MESSAGES_ANDROID'));
            Ref_Num := 145;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Whisper.GetTable('WHISPER_CHAT_IOS'));
            Ref_Num := 146;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wire.GetTable('WIRE_CHAT_ANDROID'));
            Ref_Num := 147;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wire.GetTable('WIRE_CHAT_IOS'));
            Ref_Num := 148;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wire.GetTable('WIRE_USER_ANDROID'));
            Ref_Num := 149;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Wire.GetTable('WIRE_USER_IOS'));
            Ref_Num := 150;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Yahoo.GetTable('YAHOO_MESSENGER_CHAT_WINDOWS'));
            Ref_Num := 151;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Zalo.GetTable('ZALO_CHAT_ANDROID'));
            Ref_Num := 152;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Zello.GetTable('ZELLO_CHAT_ANDROID'));
            Ref_Num := 153;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Zello.GetTable('ZELLO_CHAT_IOS'));
            Ref_Num := 154;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Zoom.GetTable('ZOOM_CHAT_IOS'));
            Ref_Num := 155;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Zoom.GetTable('ZOOM_DOWNLOAD_IOS'));

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
