unit Artifacts_Browsers;

interface

uses
{$IF DEFINED (ISFEXGUI)}
  GUI, Modules,
{$IFEND}
  ESE,
  ByteStream, Classes, Clipbrd, Common, Contnrs, DataEntry, DataStorage, DateUtils, DIRegex,
  Graphics, PropertyList, ProtoBuf, Regex, SQLite3, SysUtils, Variants,
  //-----
  Artifact_Utils      in 'Common\Artifact_Utils.pas',
  Columns             in 'Common\Column_Arrays\Columns.pas',
  Icon_List           in 'Common\Icon_List.pas',
  Itunes_Backup_Sig   in 'Common\Itunes_Backup_Signature_Analysis.pas',
  RS_DoNotTranslate   in 'Common\RS_DoNotTranslate.pas',
  //-----
  Brave_Browser       in 'Common\Column_Arrays\Brave.pas',
  Chrome_Browser      in 'Common\Column_Arrays\Chrome.pas',
  Chromium_Browser    in 'Common\Column_Arrays\Chromium.pas',
  DuckDuckGo_Browser  in 'Common\Column_Arrays\DuckDuckGo.pas',
  Edge_Browser        in 'Common\Column_Arrays\Edge.pas',
  Firefox_Browser     in 'Common\Column_Arrays\Firefox.pas',
  Googlemaps          in 'Common\Column_arrays\Googlemaps.pas',
  IE_Browser          in 'Common\Column_Arrays\Internet_Explorer.pas',
  Opera_Browser       in 'Common\Column_Arrays\Opera.pas',
  Safari_Browser      in 'Common\Column_Arrays\Safari.pas',
  Summary             in 'Common\Column_Arrays\Summary.pas',
  URL_Cache_Generic   in 'Common\Column_Arrays\URL_Cache_Generic.pas';

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
    fi_Recovery_Type              : string;
    fi_ESE_ContainerName          : string;
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
  CATEGORY_NAME             = 'Browsers';
  CHAR_LENGTH               = 120;
  BRAVE                     = 'Brave'; //noslz
  CHROME                    = 'Chrome'; //noslz
  CHROMIUM                  = 'Chromium'; //noslz
  COLON                     = ':';
  COMMA                     = ',';
  CR                        = #13#10;
  DCR                       = #13#10 + #13#10;
  DNT_AccessCount           = 'DNT_AccessCount';
  DNT_AccessedTime          = 'DNT_AccessedTime';
  DNT_ContainerID           = 'DNT_ContainerId';
  DNT_CreationTime          = 'DNT_CreationTime';
  DNT_EntryID               = 'DNT_EntryId';
  DNT_ExpiryTime            = 'DNT_ExpiryTime';
  DNT_Filename              = 'DNT_Filename';
  DNT_FileOffset            = 'DNT_FileOffset';
  DNT_Filesize              = 'DNT_FileSize';
  DNT_Flags                 = 'DNT_Flags';
  DNT_Hostname              = 'DNT_HostName';
  DNT_ModifiedTime          = 'DNT_ModifiedTime';
  DNT_PageTitle             = 'DNT_PageTitle';
  DNT_Port                  = 'DNT_Port';
  DNT_RecoveryType          = 'DNT_RecoveryType';
  DNT_Reference             = 'DNT_Reference';
  DNT_ResponseHeaders       = 'DNT_ResponseHeaders';
  DNT_SyncTime              = 'DNT_SyncTime';
  DNT_Url                   = 'DNT_Url';
  DNT_UrlHash               = 'DNT_UrlHash';
  DNT_UrlSchemaType         = 'DNT_UrlSchemaType';
  DNT_WebCacheFileName      = '^WebCacheV01\.dat';
  DUP_FILE                  = '( \d*)?$';
  EDGE                      = 'Edge';
  FBN_ITUNES_BACKUP_DOMAIN  = 'iTunes Backup Domain'; //noslz
  FBN_ITUNES_BACKUP_NAME    = 'iTunes Backup Name'; //noslz
  FIREFOX                   = 'Firefox';
  GFORMAT_STR               = '%-1s %-12s %-8s %-15s %-25s %-30s %-20s';
  GROUP_NAME                = 'Artifact Analysis';
  HYPHEN                    = ' - ';
  HYPHEN_NS                 = '-';
  IOS                       = 'iOS'; //noslz
  MAX_CARVE_SIZE            = 1024 * 10;
  MIN_CARVE_SIZE            = 0;
  NUMBEROFSEARCHITEMS       = 94; //********************************************
  OPERA                     = 'Opera';
  PROCESS_AS_CARVE          = 'PROCESSASCARVE'; //noslz
  PROCESS_AS_ESE_CARVE_CONTENT              = 'PROCESS_AS_ESE_CARVE_CONTENT';
  PROCESS_AS_ESE_CARVE_COOKIES              = 'PROCESS_AS_ESE_CARVE_COOKIES';
  PROCESS_AS_ESE_CARVE_HISTORY_REF_MARKER   = 'PROCESS_AS_ESE_CARVE_HISTORY_REF_MARKER';
  PROCESS_AS_ESE_CARVE_HISTORY_VISITED      = 'PROCESS_AS_ESE_CARVE_HISTORY_VISITED';
  PROCESS_AS_ESE_TABLES                     = 'PROCESS_AS_ESE_TABLES';
  PROCESS_AS_PLIST          = 'PROCESSASPLIST'; //noslz
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'Browsers';
  RPAD_VALUE                = 65;
  RUNNING                   = '...';
  SAFARI                    = 'Safari';
  SCRIPT_DESCRIPTION        = 'Extract Browser Artifacts';
  SCRIPT_NAME               = 'Browsers.pas';
  SPACE                     = ' ';
  SUM_CHAR                  = '@ ';
  STR_FILES_BY_PATH         = 'Files by path';
  TOP_SITES                 = 'Top Sites'; //noslz
  TSWT                      = 'The script will terminate.';
  USE_FLAGS_BL              = False;
  VERBOSE                   = False;
  WINDOWS                   = 'Windows'; //noslz
  RS_SIG_JSON               = 'JSON';

  REGEX_DATING_URL          = '(adultfriendfinder|ashleymadison|badoo|bumble|eharmony|elitesingles|facebookdating|happon|grinder|match|okcupid|plentyoffish|tinder|zoosk)\.com';
  REGEX_MAPS_QUERY          = 'google\.com\/maps(\?=|\/place\/|\/dir\/)';
  REGEX_SHIPPING_URL        = 'dtdc|(aramex|bluedart|dbschenker|deutschepost|dhl|fedex|jdlogistics|Purolator|royalmail|ups|yrcfreight|zto)\.com';
  REGEX_YOUTUBE_QUERY       = 'https?\:\/\/((www)\.)?youtube\.com\/results\?search_query=';

var
  Arr_ValidatedFiles_TList:       array[1..NUMBEROFSEARCHITEMS] of TList;
  ArtifactConnect_ProgramFolder:  array[1..NUMBEROFSEARCHITEMS] of TArtifactConnectEntry;
  FileItems:                      array[1..NUMBEROFSEARCHITEMS] of PSQL_FileSearch;

  anEntry:                        TEntry;
  ArtifactConnect_CategoryFolder: TArtifactEntry1;
  ArtifactsDataStore:             TDataStore;
  col_query:                      TDataStoreField;
  col_source_created:             TDataStoreField;
  col_source_file:                TDataStoreField;
  //col_source_location:          TDataStoreField;
  col_source_modified:            TDataStoreField;
  col_source_path:                TDataStoreField;
  col_url:                        TDataStoreField;
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
  Program_Folder_int:             integer;
  progress_program_str:           string;
  query_str:                      string;
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
procedure ChromePathCheck(aSigShortDisplayName: string; ccEntry: TEntry; indx: integer; aTList: TList; const biTunes_Name_str: string);
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
  lFileItems: array [1 .. NUMBEROFSEARCHITEMS] of TSQL_FileSearch = (

{1}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'Autofill';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:8; //noslz
fi_Regex_Search:'^web data( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_AUTOFILL+'$'; //noslz
fi_SQLStatement:'SELECT * from AUTOFILL'; //noslz
fi_SQLTables_Required:['AUTOFILL']; // noslz
fi_SQLPrimary_Tablestr:'AUTOFILL'; //noslz
fi_Test_Data:'I2016'),

{2}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:8; //noslz
fi_NodeByName:'roots {}'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_CHROME_BOOKMARKS';
fi_Regex_Search:'^bookmarks$|^bookmarks.bak$( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_JSON; //noslz
fi_Test_Data:'I2016'),

{3}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:1044; //noslz
fi_Regex_Search:'^cookies( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_COOKIES+'$'; //noslz
fi_SQLStatement:'SELECT * FROM COOKIES'; //noslz
fi_SQLTables_Required:['COOKIES']; // noslz
fi_SQLPrimary_Tablestr:'COOKIES'), //noslz

{4}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:1063; //noslz
fi_Regex_Search:'^history( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_HISTORY+'$'; //noslz
fi_SQLStatement:'SELECT * from DOWNLOADS'; //noslz
fi_SQLTables_Required:['DOWNLOADS']; // noslz
fi_SQLPrimary_Tablestr:'DOWNLOADS'), //noslz

{5}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'Favicons';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:1064; //noslz
fi_Regex_Search:'^favicons*|55680ab883d0fdcffd94f959b1632e5fbbb18c5b'; //noslz
fi_Reference_Info:'https://www.filesig.co.uk/sqlitedatabasecatalog/55680ab883d0fdcffd94f959b1632e5fbbb18c5b%20SQLite%20Database%20[00002].html'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_FAVICONS+'$'; //noslz
fi_SQLStatement:'SELECT * from ICON_MAPPING'; //noslz
fi_SQLTables_Required:['ICON_MAPPING','FAVICONS']; // noslz
fi_SQLPrimary_Tablestr:'ICON_MAPPING'), //noslz

{6}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^archived history( \d*)?$|^history( \d*)?$|faf971ce92c3ac508c018dce1bef2a8b8e9838f1'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_HISTORY+'$'; //noslz
fi_SQLStatement:'SELECT * from urls'; //noslz
fi_SQLTables_Required:['URLS']; // noslz
fi_SQLPrimary_Tablestr:'URLS'), //noslz

{7}(fi_Name_Program:BRAVE;
fi_Name_Program_Type:'Tab History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BRAVE; fi_Icon_OS:8; //noslz
fi_Regex_Search:'^Brave\.sqlite'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * from ZTABMO'; //noslz
fi_SQLTables_Required:['ZTABMO','ZBOOKMARK']; // noslz
fi_Test_Data:'Digital Corpa'),

{8}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Autofill';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:8; //noslz
fi_Regex_Search:'^web data( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_AUTOFILL+'$'; //noslz
fi_SQLStatement:'SELECT * from AUTOFILL'; //noslz
fi_SQLTables_Required:['AUTOFILL']; // noslz
fi_SQLPrimary_Tablestr:'AUTOFILL'; //noslz
fi_Test_Data:'I2016'),

{9}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Autofill Profiles';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:8; //noslz
fi_Regex_Search:'^web data( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_AUTOFILL+'$'; //noslz
fi_SQLStatement:'SELECT * FROM autofill_profiles, autofill_profile_names, autofill_profile_emails, autofill_profile_phones' + SPACE +
'WHERE autofill_profiles.guid = autofill_profile_names.guid' + SPACE +
'AND autofill_profiles.guid = autofill_profile_emails.guid' + SPACE +
'AND autofill_profiles.guid = autofill_profile_phones.guid'; //noslz
fi_SQLTables_Required:['AUTOFILL_PROFILES','AUTOFILL_PROFILE_NAMES','AUTOFILL_PROFILE_EMAILS','AUTOFILL_PROFILE_PHONES']; // noslz
fi_Test_Data:'Digital Corpa iOS15'),

{10}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:8; //noslz
fi_NodeByName:'roots {}'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_CHROME_BOOKMARKS';
fi_Regex_Search:'^bookmarks$|^bookmarks.bak$( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_JSON; //noslz
fi_Test_Data:'I2016'),

{11}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Cache';
fi_Carve_Header:'https?:\/\/';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1009; //noslz
fi_Process_As:PROCESS_AS_CARVE; //noslz
fi_Process_ID:'DNT_CHROME_CACHE';
fi_Regex_Search:'^data_[0-3]'; //noslz
fi_Signature_Parent:'Chrome Cache Data'),//noslz

{12}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1044; //noslz
fi_Regex_Search:'^cookies( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_COOKIES+'$'; //noslz
fi_SQLStatement:'SELECT * FROM COOKIES'; //noslz
fi_SQLTables_Required:['COOKIES']; // noslz
fi_SQLPrimary_Tablestr:'COOKIES'), //noslz

{13}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1063; //noslz
fi_Regex_Search:'^history( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_HISTORY+'$'; //noslz
fi_SQLStatement:'SELECT * from DOWNLOADS'; //noslz
fi_SQLTables_Required:['DOWNLOADS']; // noslz
fi_SQLPrimary_Tablestr:'DOWNLOADS'), //noslz

{14}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Favicons';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1064; //noslz
fi_Regex_Search:'^favicons*|55680ab883d0fdcffd94f959b1632e5fbbb18c5b'; //noslz
fi_Reference_Info:'https://www.filesig.co.uk/sqlitedatabasecatalog/55680ab883d0fdcffd94f959b1632e5fbbb18c5b%20SQLite%20Database%20[00002].html'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_FAVICONS+'$'; //noslz
fi_SQLStatement:'SELECT * from ICON_MAPPING'; //noslz
fi_SQLTables_Required:['ICON_MAPPING','FAVICONS']; // noslz
fi_SQLPrimary_Tablestr:'ICON_MAPPING'), //noslz

{15}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^archived history( \d*)?$|^history( \d*)?$|faf971ce92c3ac508c018dce1bef2a8b8e9838f1'; //noslz
fi_Reference_Info:'https://www.filesig.co.uk/sqlitedatabasecatalog/faf971ce92c3ac508c018dce1bef2a8b8e9838f1%20SQLite%20Database%20[00002].html'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_HISTORY+'$'; //noslz
fi_SQLStatement:'SELECT * from urls'; //noslz
fi_SQLTables_Required:['URLS']; // noslz
fi_SQLPrimary_Tablestr:'URLS'), //noslz

{16}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Keyword Search Terms';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:496; //noslz
fi_Regex_Search:'^history( \d*)?$|caf47e54e28f38c93a994ce7e5734f65724f3c1b'; //noslz
fi_Reference_Info:'https://www.filesig.co.uk/sqlitedatabasecatalog/caf47e54e28f38c93a994ce7e5734f65724f3c1b%20SQLite%20Database%20[00002].html'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_HISTORY+'$'; //noslz
fi_SQLStatement:'SELECT * from KEYWORD_SEARCH_TERMS'; //noslz
fi_SQLTables_Required:['KEYWORD_SEARCH_TERMS']; // noslz
fi_SQLPrimary_Tablestr:'KEYWORD_SEARCH_TERMS'), //noslz

{17}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Logins';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:965; //noslz
fi_Regex_Search:'^login data( \d*)?$|eca153e5b0158cc8dcb805d7c08c475a0b820f57'; //noslz
fi_Reference_Info:'https://www.filesig.co.uk/sqlitedatabasecatalog/eca153e5b0158cc8dcb805d7c08c475a0b820f57%20SQLite%20Database%20[00002].html'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome Logins'+'$'; //noslz
fi_SQLStatement:'SELECT * from LOGINS'; //noslz
fi_SQLTables_Required:['LOGINS']; // noslz
fi_SQLPrimary_Tablestr:'LOGINS'), //noslz

{18}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'Shortcuts';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^shortcuts( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome Shortcuts'+'$'; //noslz
fi_SQLStatement:'SELECT * from OMNI_BOX_SHORTCUTS'; //noslz
fi_SQLTables_Required:['OMNI_BOX_SHORTCUTS']; // noslz
fi_SQLPrimary_Tablestr:'OMNI_BOX_SHORTCUTS'), //noslz

{19}(fi_Name_Program:CHROME;
fi_Name_Program_Type:'SyncData';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:3; //noslz
fi_Regex_Search:'^SyncData\.sqlite3( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM METAS'; //noslz
fi_SQLTables_Required:['METAS','SHARE_INFO','MODELS']; // noslz
fi_SQLPrimary_Tablestr:'METAS'), //noslz

{20}(fi_Name_Program:CHROME;
fi_Name_Program_Type:TOP_SITES;
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^top sites( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * from top_sites'; //noslz
fi_SQLTables_Required:['TOP_SITES','META']; // noslz
fi_SQLPrimary_Tablestr:'TOP_SITES'), //noslz

{21}(fi_Name_Program:CHROME;
fi_Name_Program_Type:TOP_SITES + SPACE + '(Thmbs)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROME; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^top sites( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome Topsites'+'$'; //noslz
fi_SQLStatement:'SELECT * from THUMBNAILS'; //noslz
fi_SQLTables_Required:['THUMBNAILS','META']; // noslz
fi_SQLPrimary_Tablestr:'THUMBNAILS'), //noslz

{22}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'Cache';
fi_Carve_Header:'https?:\/\/'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1133; //noslz
fi_Process_As:PROCESS_AS_CARVE; //noslz
fi_Process_ID:'DNT_CHROME_CACHE'; //noslz
fi_Regex_Search:'^data_[0-3]'; //noslz
fi_Signature_Parent:'Chrome Cache Data'), //noslz

{23}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1044; //noslz
fi_Regex_Search:'^cookies( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_COOKIES+'$'; //noslz
fi_SQLStatement:'SELECT * FROM COOKIES'; //noslz
fi_SQLTables_Required:['COOKIES']; // noslz
fi_SQLPrimary_Tablestr:'COOKIES'; //noslz
fi_Test_Data:'I2016'),

{24}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1063; //noslz
fi_Regex_Search:'^history( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from DOWNLOADS'; //noslz
fi_SQLTables_Required:['DOWNLOADS']; // noslz
fi_SQLPrimary_Tablestr:'DOWNLOADS'), //noslz

{25}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'Favicons';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1064; //noslz
fi_Regex_Search:'^favicons*'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_FAVICONS+'$'; //noslz
fi_SQLStatement:'SELECT * from ICON_MAPPING'; //noslz
fi_SQLTables_Required:['ICON_MAPPING']; // noslz
fi_SQLPrimary_Tablestr:'ICON_MAPPING'), //noslz

{26}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1133; //noslz
fi_Regex_Search:'^archived history( \d*)?$|^history( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from urls'; //noslz
fi_SQLTables_Required:['URLS']; // noslz
fi_SQLPrimary_Tablestr:'URLS'), //noslz

{27}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'Keyword Search Terms';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:496; //noslz
fi_Regex_Search:'^history( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from KEYWORD_SEARCH_TERMS'; //noslz
fi_SQLTables_Required:['KEYWORD_SEARCH_TERMS']; // noslz
fi_SQLPrimary_Tablestr:'KEYWORD_SEARCH_TERMS'), //noslz

{28}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:'Shortcuts';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^shortcuts( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome Shortcuts'+'$'; //noslz
fi_SQLStatement:'SELECT * from OMNI_BOX_SHORTCUTS'; //noslz
fi_SQLTables_Required:['OMNI_BOX_SHORTCUTS']; // noslz
fi_SQLPrimary_Tablestr:'OMNI_BOX_SHORTCUTS'), //noslz

{29}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:TOP_SITES;
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^top sites( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * from top_sites'; //noslz
fi_SQLTables_Required:['TOP_SITES','META']; // noslz
fi_SQLPrimary_Tablestr:'TOP_SITES'), //noslz

{30}(fi_Name_Program:CHROMIUM;
fi_Name_Program_Type:TOP_SITES + SPACE + '(Thmbs)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_CHROMIUM; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^top sites( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * from top_sites'; //noslz
fi_Signature_Sub:'^'+'Chrome Topsites'+'$'+'$'; //noslz
fi_SQLTables_Required:['TOP_SITES','THUMBNAILS']; // noslz
fi_SQLPrimary_Tablestr:'THUMBNAILS'), //noslz

{31}(fi_Name_Program:'DuckDuckGo';
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1207; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^Bookmarks\.sqlite'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * from ZBOOKMARKENTITY'; //noslz
fi_Signature_Sub:'^'+RS_SIG_SQLITE+'$'; //noslz
fi_SQLTables_Required:['ZBOOKMARKENTITY'];//,'Z_METADATA','ZMODELCACHE','Z_PRIMARYKEY']; // noslz
fi_SQLPrimary_Tablestr:'ZBOOKMARKENTITY'), //noslz

{32}(fi_Name_Program:EDGE;
fi_Name_Program_Type:'Autofill';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_EDGE; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^web data( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_AUTOFILL+'$'; //noslz
fi_SQLStatement:'SELECT * from AUTOFILL'; //noslz
fi_SQLTables_Required:['AUTOFILL']; // noslz
fi_SQLPrimary_Tablestr:'AUTOFILL'; //noslz
fi_Test_Data:''),

{33}(fi_Name_Program:EDGE;
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_EDGE; fi_Icon_OS:1009; //noslz
fi_NodeByName:'roots {}'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_EDGE_BOOKMARKS';
fi_RootNodeName: 'JSON Tree';
fi_Regex_Search:'^Bookmarks( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_JSON; //noslz
fi_Test_Data:'Digital Corpa iOS15'),

{34}(fi_Name_Program:EDGE;
fi_Name_Program_Type:'Favicons';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_EDGE; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^favicons*'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_FAVICONS+'$'; //noslz
fi_SQLStatement:'SELECT * from ICON_MAPPING'; //noslz
fi_SQLTables_Required:['ICON_MAPPING']; // noslz
fi_SQLPrimary_Tablestr:'ICON_MAPPING'), //noslz

{35}(fi_Name_Program:EDGE;
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_EDGE; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'^History*'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_HISTORY+'$'; //noslz
fi_SQLStatement:'SELECT * from URLS'; //noslz
fi_SQLTables_Required:['URLS','DOWNLOADS','VISITS']; // noslz
fi_SQLPrimary_Tablestr:'URLS'), //noslz

{36}(fi_Name_Program:EDGE;
fi_Name_Program_Type:'WebAssistDatabase';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_EDGE; fi_Icon_OS:1009; //noslz
fi_Regex_Search:'WebAssistDatabase'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM NAVIGATION_HISTORY'; //noslz
fi_SQLTables_Required:['NAVIGATION_HISTORY']; // noslz
fi_SQLPrimary_Tablestr:'NAVIGATION_HISTORY'), //noslz

{37}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1006; fi_Icon_OS:1017; //noslz
fi_Regex_Search:'^browser\.db( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM HISTORY'; //noslz
fi_SQLTables_Required:['HISTORY','ANDROID_METADATA']; // noslz
fi_SQLPrimary_Tablestr:'HISTORY'), //noslz

{38}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Search History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1006; fi_Icon_OS:1017; //noslz
fi_Regex_Search:'^browser\.db( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM SEARCHHISTORY'; //noslz
fi_SQLTables_Required:['SEARCHHISTORY','ANDROID_METADATA']; // noslz
fi_SQLPrimary_Tablestr:'SEARCHHISTORY'), //noslz

{39}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1043; //noslz
fi_Regex_Search:'^places\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox History'+'$'; //noslz
fi_SQLStatement:'SELECT * from moz_bookmarks LEFT JOIN moz_places on moz_bookmarks.fk = moz_places.id'; //noslz
fi_SQLTables_Required:['MOZ_BOOKMARKS']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_BOOKMARKS'), //noslz

{40}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Cache';
fi_Process_ID:'DNT_FIREFOX_CACHE';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:89; //noslz
fi_Regex_Search:'^Cache\.db( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'URL Cache'+'$'; //noslz - This is a generic signature
fi_SQLStatement:'SELECT * FROM CFURL_CACHE_RESPONSE'; //noslz
fi_SQLTables_Required:['CFURL_CACHE_RESPONSE']; // noslz
fi_SQLPrimary_Tablestr:'CFURL_CACHE_RESPONSE'), //noslz

{41}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1044; //noslz
fi_Regex_Search:'^cookies\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox Cookies'+'$'; //noslz
fi_SQLStatement:'SELECT * from moz_cookies'; //noslz
fi_SQLTables_Required:['MOZ_COOKIES']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_COOKIES'), //noslz

{42}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1063; //noslz
fi_Regex_Search:'^places\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox History'+'$'; //noslz
fi_SQLStatement:'SELECT * from moz_annos LEFT JOIN moz_places on moz_annos.place_id = moz_places.id WHERE content like ''%file:///%'''; //noslz
fi_SQLTables_Required:['MOZ_ANNOS']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_ANNOS'), //noslz

{43}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Favicons';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1064; //noslz
fi_Regex_Search:'^places\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox History'+'$'; //noslz
fi_SQLStatement:'SELECT * from moz_favicons'; //noslz
fi_SQLTables_Required:['MOZ_FAVICONS']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_FAVICONS'), //noslz

{44}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'Form History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1006; //noslz
fi_Regex_Search:'^formhistory\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox Form History'+'$'; //noslz
fi_SQLStatement:'SELECT * from moz_formhistory'; //noslz
fi_SQLTables_Required:['MOZ_FORMHISTORY']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_FORMHISTORY'), //noslz

{45}(fi_Name_Program:FIREFOX;
fi_Name_Program_Type:'History Visits';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^places\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox History'+'$'; //noslz
fi_SQLStatement:'SELECT h.visit_date as visit_date, p.visit_count, h.visit_type, p.title, p.url FROM moz_historyvisits h, moz_places p WHERE p.id = h.place_id'; //noslz
fi_SQLTables_Required:['MOZ_HISTORYVISITS']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_HISTORYVISITS'), //noslz

{46}(fi_Name_Program:FIREFOX; {!!! 13 table version !!!}
fi_Name_Program_Type:'Places (v32)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^places\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox History'+'$'; //noslz
fi_SQLStatement:'SELECT * FROM MOZ_PLACES'; //noslz
fi_SQLTables_Required:['MOZ_PLACES','MOZ_ANNOS']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_PLACES'), //noslz

{47}(fi_Name_Program:FIREFOX; {!!! 18 table version !!!}
fi_Name_Program_Type:'Places (v35)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_FIREFOX; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^places\.sqlite( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Firefox History'+'$'; //noslz
fi_SQLStatement:'SELECT * FROM MOZ_PLACES'; //noslz
fi_SQLTables_Required:['MOZ_PLACES','MOZ_BOOKMARKS_DELETED','MOZ_HISTORYVISIT_TOMBSTONES']; // noslz
fi_SQLPrimary_Tablestr:'MOZ_PLACES'), //noslz

{48}(fi_Name_Program:'Google';
fi_Name_Program_Type:'Map Coordinates';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1140; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^Tiles\.sqlite'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * from ZGMSCACHEDTILE'; //noslz
fi_SQLTables_Required:['ZGMSCACHEDTILE']; // noslz
fi_SQLPrimary_Tablestr:'ZGMSCACHEDTILE'), //noslz

{49}(fi_Name_Program:'Internet Explorer 4-9';
fi_Name_Program_Type:'URL (Cookie)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1005; fi_Icon_OS:1044; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_4_9';
fi_Regex_Search:'^index\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Plist (Binary)'; //noslz
fi_Signature_Sub:'^'+'Internet Explorer v4-9 History'+'$'), //noslz

{50}(fi_Name_Program:'Internet Explorer 4-9';
fi_Name_Program_Type:'URL (Daily)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1005; fi_Icon_OS:1042; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_4_9'; //noslz
fi_Regex_Search:'^index\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Plist (Binary)'; //noslz
fi_Signature_Sub:'^'+'Internet Explorer v4-9 History'+'$'), //noslz

{51}(fi_Name_Program:'Internet Explorer 4-9';
fi_Name_Program_Type:'URL (History)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1005; fi_Icon_OS:1042; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_4_9'; //noslz
fi_Regex_Search:'^index\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Plist (Binary)'; //noslz
fi_Signature_Sub:'^'+'Internet Explorer v4-9 History'+'$'), //noslz

{52}(fi_Name_Program:'Internet Explorer 4-9';
fi_Name_Program_Type:'URL (Normal)';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_4_9'; //noslz
fi_Regex_Search:'^index\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Plist (Binary)'; //noslz
fi_Signature_Sub:'^'+'Internet Explorer v4-9 History'+'$'), //noslz

{53}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'ESE Content';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_ESE_ContainerName:'Content'; //noslz
fi_Process_As:'PROCESS_AS_ESE_TABLES'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{54}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'ESE Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_ESE_ContainerName:'Cookies'; //noslz
fi_Process_As:'PROCESS_AS_ESE_TABLES'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{55}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'ESE Dependency Entries';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_ESE_ContainerName:'DependencyEntryEx'; //noslz
fi_Process_As:'PROCESS_AS_ESE_TABLES'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{56}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'ESE Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_ESE_ContainerName:'iedownload'; //noslz
fi_Process_As:'PROCESS_AS_ESE_TABLES'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{57}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'ESE History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_ESE_ContainerName:'History';
fi_Process_As:'PROCESS_AS_ESE_TABLES'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{58}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'Carve Content';
fi_Carve_Header:'\xFE\x00\x01.\x00\x01\x01.{0,16}\x68\x00\x74\x00\x74\x00\x70\x00'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Recovery_Type:'Carve Content';
fi_Process_As:'PROCESS_AS_ESE_CARVE_CONTENT'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{59}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'Carve Content (Log Files)';
fi_Carve_Header:'\xFE\x00\x01.\x00\x01\x01.{0,16}\x68\x00\x74\x00\x74\x00\x70\x00'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Recovery_Type:'Carve Content'; //noslz
fi_Process_As:'PROCESS_AS_ESE_CARVE_CONTENT'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^V01.*\.log( \d*)?$'), //noslz

{60}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'Carve Cookies';
fi_Carve_Header:'\xFE\x00\x01\x08\x00.....\x43\x00\x6F\x00\x6F\x00\x6B\x00\x69\x00\x65\x00\x3A\x00'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Recovery_Type:'Carve Cookies';
fi_Process_As:'PROCESS_AS_ESE_CARVE_COOKIES'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{61}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'Carve History - Ref. Marker';
fi_Carve_Header:'\xFE\x00\x01\x04\x00\x01\x3A\x00\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.\d.:.\x20\x00'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Recovery_Type:'Carve Ref. Marker';
fi_Process_As:'PROCESS_AS_ESE_CARVE_HISTORY_REF_MARKER'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{62}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'Carve History - Visited';
fi_Carve_Header:'\xFE\x00\x01\x08\x00.....\x56\x00\x69\x00\x73\x00\x69\x00\x74\x00\x65\x00\x64\x00\x3A\x00\x20\x00'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Recovery_Type:'Carve Visited';
fi_Process_As:'PROCESS_AS_ESE_CARVE_HISTORY_VISITED'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^WebCacheV01\.dat( \d*)?$'; //noslz
fi_Signature_Parent:'Extensible Storage Engine|Web Browser Cache'), //noslz

{63}(fi_Name_Program:'Internet Explorer 10-11';
fi_Name_Program_Type:'Carve History - Visited (Log Files)';
fi_Carve_Header:'\xFE\x00\x01\x08\x00.....\x56\x00\x69\x00\x73\x00\x69\x00\x74\x00\x65\x00\x64\x00\x3A\x00\x20\x00'; //noslz
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_IE; fi_Icon_OS:1042; //noslz
fi_Recovery_Type:'Carve Visited';
fi_Process_As:'PROCESS_AS_ESE_CARVE_HISTORY_VISITED'; //noslz
fi_Process_ID:'DNT_INTERNET_EXPLORER_10_11'; //noslz
fi_Regex_Search:'^V01.*\.log( \d*)?$'), //noslz

{64}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'Autofill';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:8; //noslz
fi_Regex_Search:'^web data( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_AUTOFILL+'$'; //noslz
fi_SQLStatement:'SELECT * from AUTOFILL'; //noslz
fi_SQLTables_Required:['AUTOFILL']; // noslz
fi_SQLPrimary_Tablestr:'AUTOFILL'; //noslz
fi_Test_Data:''),

{65}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:8; //noslz
fi_Regex_Search:'^Bookmarks( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_JSON; //noslz
fi_NodeByName:'speedDial {}'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_OPERA_BOOKMARKS';
fi_RootNodeName: 'JSON Tree';
fi_Test_Data:'Digital Corpa 13'),

{66}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'Cache (carve)';
fi_Carve_Header:'dk_https:\/\/';
fi_Carve_Footer:'\x00\x00\x00\x00';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:1008; //noslz
fi_Process_As:PROCESS_AS_CARVE; //noslz
fi_Process_ID:'DNT_CHROME_CACHE'; //noslz
fi_Regex_Search:'^data_[0-3]'; //noslz
fi_Signature_Parent:'Chrome Cache Data'), //noslz

{67}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:1044; //noslz
fi_Process_ID:'DNT_OPERA_COOKIES'; //noslz
fi_Regex_Search:'app_opera\\cookies( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+RS_SIG_CHROME_COOKIES+'$'; //noslz
fi_SQLStatement:'SELECT * FROM COOKIES'; //noslz
fi_SQLTables_Required:['COOKIES', 'META']; // noslz
fi_SQLPrimary_Tablestr:'COOKIES'), //noslz

{68}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:1008; //noslz
fi_Regex_Search:'\\Opera.*\\History( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from DOWNLOADS'; //noslz
fi_SQLTables_Required:['DOWNLOADS','SQLITE_SEQUENCE','META']; // noslz
fi_SQLPrimary_Tablestr:'DOWNLOADS'), //noslz

{69}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:1008; //noslz
fi_Regex_Search:'\\Opera.*\\History( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from URLS'; //noslz
fi_SQLTables_Required:['URLS','SQLITE_SEQUENCE','META']; // noslz
fi_SQLPrimary_Tablestr:'URLS'), //noslz

{70}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'Keyword Search Terms';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:1060; //noslz
fi_Regex_Search:'\\Opera.*\\History( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from KEYWORD_SEARCH_TERMS'; //noslz
fi_SQLTables_Required:['KEYWORD_SEARCH_TERMS','SQLITE_SEQUENCE','META']; // noslz
fi_SQLPrimary_Tablestr:'KEYWORD_SEARCH_TERMS'), //noslz

{71}(fi_Name_Program:OPERA;
fi_Name_Program_Type:'URLS';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_OPERA; fi_Icon_OS:1060; //noslz
fi_Regex_Search:'\\Opera.*\\History( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Chrome History'+'$'; //noslz
fi_SQLStatement:'SELECT * from URLS'; //noslz
fi_SQLTables_Required:['URLS','SQLITE_SEQUENCE','META']; // noslz
fi_SQLPrimary_Tablestr:'URLS'), //noslz

{72}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1043; //noslz
fi_Regex_Search:'^bookmarks\.db( \d*)?$|d1f062e2da26192a6625d968274bfda8d07821e4( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'Safari Bookmarks'+'$'; //noslz
fi_SQLStatement:'SELECT * FROM BOOKMARKS'; //noslz
fi_SQLTables_Required:['BOOKMARKS']; // noslz
fi_SQLPrimary_Tablestr:'BOOKMARKS'), //noslz

{73}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Bookmarks';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1044; //noslz
fi_NodeByName:'Children'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_BOOKMARKS_PLIST'; //noslz
fi_Regex_Search:'\\Safari\\Bookmarks.plist*'; //noslz
fi_Signature_Parent:'Plist (Binary)'), //noslz

{74}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Cache';
fi_Process_ID:'DNT_SAFARI_CACHE';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:89; //noslz
fi_Regex_Search:'^Cache\.db( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'URL Cache'+'$'; //noslz - This is a generic signature
fi_SQLStatement:'SELECT * FROM CFURL_CACHE_RESPONSE'; //noslz
fi_SQLTables_Required:['CFURL_CACHE_RESPONSE']; // noslz
fi_SQLPrimary_Tablestr:'CFURL_CACHE_RESPONSE'), //noslz

{75}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Cached Conversation Headers';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1062; //noslz
fi_Regex_Itunes_Backup_Domain:'AppDomain-com\.apple\.mobilesafari'; //noslz
fi_Regex_Itunes_Backup_Name:'Library\/WebKit\/WebsiteData\/WebSQL\/https_mail\.google\.com_0\/.*\.db'; //noslz
fi_Name_OS:IOS;
fi_Regex_Search:'^6975a258e7aa62f53cbb090e739926a216106784.*'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM CACHED_CONVERSATION_HEADERS'; //noslz
fi_SQLTables_Required:['CACHED_CONVERSATION_HEADERS','CACHED_LABELS','CACHED_CONTACTS']; // noslz
fi_SQLPrimary_Tablestr:'CACHED_CONVERSATION_HEADERS'), //noslz

{76}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Cached Messages';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1062; //noslz
fi_Regex_Itunes_Backup_Domain:'AppDomain-com\.apple\.mobilesafari'; //noslz
fi_Regex_Itunes_Backup_Name:'Library\/WebKit\/WebsiteData\/WebSQL\/https_mail\.google\.com_0\/.*\.db'; //noslz
fi_Name_OS:IOS;
fi_Regex_Search:'^6975a258e7aa62f53cbb090e739926a216106784.*'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM CACHED_MESSAGES'; //noslz
fi_SQLTables_Required:['CACHED_MESSAGES','CONFIG_TABLE']; // noslz
fi_SQLPrimary_Tablestr:'CACHED_MESSAGES'), //noslz

{77}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Cookies';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1044; //noslz
fi_Regex_Itunes_Backup_Name:'Library\/Cookies\/(.*)?\.binarycookies'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_COOKIES'; //noslz
fi_Regex_Search:'Cookies\.binarycookies( \d*)?$'; //noslz
fi_Signature_Sub:'^'+'Safari Cookie'+'$'), //noslz

{78}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1044; //noslz
fi_NodeByName:'dict'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_DOWNLOADS_XML'; //noslz
fi_Regex_Search:'\\Safari\\Downloads\.plist'; //noslz
fi_Signature_Parent:'XML'), //noslz

{79}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Downloads';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1044; //noslz
fi_NodeByName:'DownloadHistory'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_DOWNLOADS_PLIST'; //noslz
fi_Regex_Search:'Downloads\.plist'; //noslz
fi_Signature_Parent:'Plist (Binary)'), //noslz

{80}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'History';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1042; //noslz
fi_NodeByName:'WebHistoryDates'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_HISTORY_PLIST'; //noslz
fi_Reference_Info:'https://github.com/OSaa/BackupProfiler/blob/master/backupProfiler/iosRecovery.py https://www.syntricate.com/files/MAC%20System%20Artifacts.pdfSuspend State: Contains the Safari web browser history since it was last cleared". (iPhone Forensics, Jonathan Zdziarski, Oreilley 2008)'; //noslz
fi_Regex_Search:'^history.plist( \d*)?$|^suspendstate.plist( \d*)?$|ed50eadf14505ef0b433e0c4a380526ad6656d3a( \d*)?$|1d6740792a2b845f4c1e6220c43906d7f0afe8ab(\.mddata)?( \d*)?$'; //noslz
fi_Signature_Parent:'Plist (Binary)'; //noslz
fi_Signature_Sub:'^'+'Safari History'+'$'), //noslz

{81}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'History iOS8';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'^e74113c185fd8297e140cfcf9c99436c5cc06b57( \d*)?$|history\.db( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM history_visits'; //noslz
fi_SQLTables_Required:['HISTORY_VISITS','HISTORY_ITEMS']; // noslz
fi_SQLPrimary_Tablestr:'HISTORY_VISITS'), //noslz

{82}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Recent Searches';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:997; //noslz
fi_RootNodeName: 'Plist (Binary)';
fi_NodeByName:'RecentWebSearches'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_RECENT_SEARCHES_PLIST'; //noslz
fi_Reference_Info:'https://github.com/OSaa/BackupProfiler/blob/master/backupProfiler/iosRecovery.py'; //noslz
fi_Regex_Search:'com\.apple\.mobilesafari\.plist|37d957bda6d8be85555e7c0a7d30c5a8bc1b5cce( \d*)?$'; fi_Signature_Parent:'Plist (Binary)'), //noslz

{83}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Recent Searches';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:997; //noslz
fi_NodeByName:'RecentSearches'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_RECENT_SEARCHES_XML'; //noslz
fi_Reference_Info:'https://github.com/OSaa/BackupProfiler/blob/master/backupProfiler/iosRecovery.py'; //noslz
fi_Regex_Search:'com\.apple\.mobilesafari\.plist|37d957bda6d8be85555e7c0a7d30c5a8bc1b5cce( \d*)?$'; fi_Signature_Parent:'XML'), //noslz

{84}(fi_Name_Program:'Safari';
fi_Name_Program_Type:'Tabs';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:1042; //noslz
fi_Regex_Search:'BrowserState.db'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_SQLStatement:'SELECT * FROM tabs'; //noslz
fi_SQLTables_Required:['tabs','tab_sessions']; // noslz
fi_SQLPrimary_Tablestr:'tabs'), //noslz

{85}(fi_Name_Program:'Safari';
fi_Name_Program_Type:TOP_SITES;
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_SAFARI; fi_Icon_OS:997; //noslz
fi_NodeByName:'TopSites'; //noslz
fi_Process_As:'PROCESSASPLIST'; //noslz
fi_Process_ID:'DNT_SAFARI_TOPSITES_PLIST'; //noslz
fi_Regex_Search:'\\Safari\\TopSites\.plist*'; //noslz
fi_Signature_Parent:'Plist (Binary)'),

{86}(fi_Name_Program:'URL Cache';
fi_Name_Program_Type:'Generic';
fi_Process_ID:'DNT_URL_CACHE_GENERIC';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_BROWSERS; fi_Icon_OS:89; //noslz
fi_Regex_Search:'^Cache\.db( \d*)?$'; //noslz
fi_Signature_Parent:RS_SIG_SQLITE; //noslz
fi_Signature_Sub:'^'+'URL Cache'+'$'; //noslz - This is a generic signature
fi_SQLStatement:'SELECT * FROM CFURL_CACHE_RESPONSE'; //noslz
fi_SQLTables_Required:['CFURL_CACHE_RESPONSE']; // noslz
fi_SQLPrimary_Tablestr:'CFURL_CACHE_RESPONSE'), //noslz

//----

{87}(fi_Name_Program:SUM_CHAR + 'Bing';
fi_Name_Program_Type:'Query';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1142; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_BING_QUERY'; //noslz
fi_Regex_Search:'https?\:\/\/((www)\.)?bing\.com\/.*search\?'), //noslz

{88}(fi_Name_Program:SUM_CHAR + 'Cloud';
fi_Name_Program_Type:'Services';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:978; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_CLOUD'; //noslz
fi_Regex_Search:'dropbox\.|\.box\.|onedrive\.|drive\.google|pcloud\.|idrive\.'), //noslz

{89}(fi_Name_Program:SUM_CHAR + 'Dating';
fi_Name_Program_Type:'URL';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:ICON_HEART; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_DATING'; //noslz
fi_Regex_Search:REGEX_DATING_URL), //noslz

{90}(fi_Name_Program:SUM_CHAR + 'FaceBook';
fi_Name_Program_Type:'URLs';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1018; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_FACEBOOK_QUERY'; //noslz
fi_Regex_Search:'https?\:\/\/((www)\.)?facebook\.com'), //noslz

{91}(fi_Name_Program:SUM_CHAR + 'Google';
fi_Name_Program_Type:'Maps';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1139; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_GOOGLE_MAPS'; //noslz
fi_Regex_Search:REGEX_MAPS_QUERY),

{92}(fi_Name_Program:SUM_CHAR + 'Google';
fi_Name_Program_Type:'Query';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1139; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_GOOGLE_QUERY'; //noslz
fi_Regex_Search:'(https|http):\/\/(www\.|)google\.[a-z]+[\.a-z]+\/search\?'), //noslz

{93}(fi_Name_Program:SUM_CHAR + 'Shipping';
fi_Name_Program_Type:'URL';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1213; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_REGEX_SHIPPING'; //noslz
fi_Regex_Search:REGEX_SHIPPING_URL),

{94}(fi_Name_Program:SUM_CHAR + 'Youtube';
fi_Name_Program_Type:'Query';
fi_Icon_Category:ICON_BROWSERS; fi_Icon_Program:1141; fi_Icon_OS:997; //noslz
fi_Process_As:'POSTPROCESS'; //noslz
fi_Process_ID:'PROCID_YOUTUBE_QUERY'; //noslz
fi_Regex_Search:REGEX_YOUTUBE_QUERY));

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

procedure ChromePathCheck(aSigShortDisplayName: string; ccEntry: TEntry; indx: integer; aTList: TList; const biTunes_Name_str: string);
const
  BL_PTH_CHECK_LOGGING = False;
var
  Item: PSQL_FileSearch;
begin
  Item := FileItems[indx];

  // Chrome/Chromium
  if (Item^.fi_Name_Program = CHROME) or (Item^.fi_Name_Program = CHROMIUM) then
  begin
    // Chrome
    if (Item^.fi_Name_Program = CHROME) then
    begin
      if (RegexMatch(ccEntry.FullPathName, 'app_chrome\\|\\Chrome\\', False) or RegexMatch(biTunes_Name_str, '\/Chrome\/', False)) and (not RegexMatch(ccEntry.FullPathName, 'Brave|Edge|Opera', False)) then // noslz
      begin
        aTList.Add(anEntry);
        if BL_PTH_CHECK_LOGGING then
          Progress.Log(RPad(HYPHEN + 'B: Chrome:', RPAD_VALUE) + IntToStr(indx) + ' (' + Item^.fi_Name_Program + ')');
      end
    end
    else
    // Chromium
    begin
      if (not RegexMatch(ccEntry.FullPathName, 'app_chrome\\|Brave|Edge|Opera', False)) and (not RegexMatch(biTunes_Name_str, '\/Chrome|Edge|Opera|android\.chrome', False)) then
      begin
        aTList.Add(anEntry);
        if BL_PTH_CHECK_LOGGING then
          Progress.Log(RPad('C: Chromium (Other):', RPAD_VALUE) + IntToStr(indx) + ' (' + Item^.fi_Name_Program + ')');
      end;
    end;
  end
  else
    // Brave
    if (Item^.fi_Name_Program = BRAVE) and (RegexMatch(ccEntry.FullPathName, 'Brave', False) or RegexMatch(biTunes_Name_str, 'Brave', False)) then // noslz
    begin
      aTList.Add(anEntry);
    end
    else
      // Edge
      if (Item^.fi_Name_Program = EDGE) and (RegexMatch(ccEntry.FullPathName, '\\Edge\\', False) or RegexMatch(biTunes_Name_str, '\/Edge\/', False)) then // noslz
      begin
        aTList.Add(anEntry);
        if BL_PTH_CHECK_LOGGING then
          Progress.Log(RPad(HYPHEN + 'D: Edge:', RPAD_VALUE) + IntToStr(indx) + ' (' + Item^.fi_Name_Program + ')');
        Item^.fi_Name_Program := EDGE;
        Item^.fi_Icon_Program := ICON_EDGE;
      end
      else
        // Opera
        if (Item^.fi_Name_Program = OPERA) and (RegexMatch(ccEntry.FullPathName, 'Opera', False) or RegexMatch(biTunes_Name_str, 'Opera', False)) then // noslz
        begin
          aTList.Add(anEntry);
          if BL_PTH_CHECK_LOGGING then
            Progress.Log(RPad(HYPHEN + 'E: Opera:', RPAD_VALUE) + IntToStr(indx) + ' (' + Item^.fi_Name_Program + ')');
        end;
end;

function CleanString(AString: string): string;
begin
  Result := '';
  AString := StringReplace(AString, '+', ' ', [rfReplaceAll]);
  AString := StringReplace(AString, '%20', ' ', [rfReplaceAll]);
  AString := StringReplace(AString, '%21', '!', [rfReplaceAll]);
  AString := StringReplace(AString, '%22', '"', [rfReplaceAll]);
  AString := StringReplace(AString, '%23', '#', [rfReplaceAll]);
  AString := StringReplace(AString, '%24', '$', [rfReplaceAll]);
  AString := StringReplace(AString, '%25', '%', [rfReplaceAll]);
  AString := StringReplace(AString, '%2520', ' ', [rfReplaceAll]);
  AString := StringReplace(AString, '%26', '&', [rfReplaceAll]);
  AString := StringReplace(AString, '%27', '''', [rfReplaceAll]);
  AString := StringReplace(AString, '%28', '(', [rfReplaceAll]);
  AString := StringReplace(AString, '%29', ')', [rfReplaceAll]);
  AString := StringReplace(AString, '%2A', '*', [rfReplaceAll]);
  AString := StringReplace(AString, '%2B', '+', [rfReplaceAll]);
  AString := StringReplace(AString, '%2C', ',', [rfReplaceAll]);
  AString := StringReplace(AString, '%2D', '-', [rfReplaceAll]);
  AString := StringReplace(AString, '%2E', '.', [rfReplaceAll]);
  AString := StringReplace(AString, '%2F', '/', [rfReplaceAll]);
  AString := StringReplace(AString, '%3A', ':', [rfReplaceAll]);
  AString := StringReplace(AString, '%3B', ';', [rfReplaceAll]);
  AString := StringReplace(AString, '%3C', '<', [rfReplaceAll]);
  AString := StringReplace(AString, '%3D', '=', [rfReplaceAll]);
  AString := StringReplace(AString, '%3E', '>', [rfReplaceAll]);
  AString := StringReplace(AString, '%3F', '?', [rfReplaceAll]);
  AString := StringReplace(AString, '%40', '@', [rfReplaceAll]);
  AString := StringReplace(AString, '%E2%80%93', '-', [rfReplaceAll]);
  AString := StringReplace(AString, '/''/', '', [rfReplaceAll]);
  AString := StringReplace(AString, '''/', '', [rfReplaceAll]);
  Result := AString;
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

function CountNodes(aNode: TPropertyNode): integer;
var
  aNodeList: TObjectList;
begin
  Result := 0;
  aNodeList := aNode.PropChildList;
  if assigned(aNodeList) then
    Result := aNodeList.Count;
  // Progress.Log(RPad('Number of child nodes:', RPAD_VALUE) + IntToStr(Result));
end;

procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
var
  DeterminedFileDriverInfo: TFileTypeInformation;
  MatchSignature_str: string;
  NowProceed_bl: boolean;
  i: integer;
  File_Added_bl: boolean;
  Item: PSQL_FileSearch;
  short_path_str: string;
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
  if assigned(anEntry.Parent.Parent) then
    short_path_str := anEntry.Parent.Parent.EntryName + '\' + anEntry.Parent.EntryName + '\' + anEntry.EntryName
  else
    short_path_str := anEntry.EntryName;

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
          if (Item.fi_Process_As = PROCESS_AS_ESE_CARVE_CONTENT) and RegexMatch(anEntry.EntryName, '^V01.*\.log', False) then
            NowProceed_bl := True;

          if (Item.fi_Process_As = PROCESS_AS_ESE_CARVE_HISTORY_VISITED) and RegexMatch(anEntry.EntryName, '^V01.*\.log', False) then
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
        if (not NowProceed_bl) then
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
          // Chrome path check -----------------------------------------------------

          // Chrome Path Check - Autofill
          if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_AUTOFILL) then
            ChromePathCheck(RS_SIG_CHROME_AUTOFILL, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
          else

            // Chrome Path Check - Bookmarks
            if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_JSON) then
              ChromePathCheck(RS_SIG_JSON, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
            else

              // Chrome Path Check - Cache
              if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_CACHE_DATA) then
                ChromePathCheck(RS_SIG_CHROME_CACHE_DATA, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
              else

                // Chrome Path Check - Chrome Cookies
                if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_COOKIES) then
                  ChromePathCheck(RS_SIG_CHROME_COOKIES, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                else

                  // Chrome Path Check - Fav Icons
                  if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_FAVICONS) then
                    ChromePathCheck(RS_SIG_CHROME_FAVICONS, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                  else

                    // Chrome Path Check - History
                    if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_HISTORY) then
                      ChromePathCheck(RS_SIG_CHROME_HISTORY, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                    else

                      // Chrome Path Check - Logins
                      if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_LOGINS) then
                        ChromePathCheck(RS_SIG_CHROME_LOGINS, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                      else

                        // Chrome Path Check - Shortcuts
                        if (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_CHROME_SHORTCUTS) then
                          ChromePathCheck(RS_SIG_CHROME_SHORTCUTS, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                        else

                          // Chrome Path Check - Top Sites
                          if (Item^.fi_Name_Program_Type = TOP_SITES) and (DeterminedFileDriverInfo.ShortDisplayName = RS_SIG_SQLITE) then
                            ChromePathCheck(RS_SIG_SQLITE, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                          else

                            // Chrome Path Check - Top Sites (Thmbs)
                            if (Item^.fi_Name_Program_Type = TOP_SITES + SPACE + '(Thmbs)') and (DeterminedFileDriverInfo.ShortDisplayName = 'Chrome Topsites') then // noslz
                              ChromePathCheck(RS_SIG_SQLITE, anEntry, i, Arr_ValidatedFiles_TList[i], biTunes_Name_str)
                            else

                              // Firefox Path Check -----------------------------------------------------
                              if Item^.fi_Process_ID = 'DNT_FIREFOX_CACHE' then
                              begin
                                if RegexMatch(anEntry.FullPathName, 'firefox|mozilla', False) and (DeterminedFileDriverInfo.ShortDisplayName = 'URL Cache') then // noslz
                                begin
                                  Arr_ValidatedFiles_TList[i].Add(anEntry);
                                end
                                else
                                  File_Added_bl := False;
                              end
                              else

                                // Safari Path Check -----------------------------------------------------
                                if Item^.fi_Process_ID = 'DNT_SAFARI_CACHE' then
                                begin
                                  if RegexMatch(anEntry.FullPathName, 'Safari', False) and (DeterminedFileDriverInfo.ShortDisplayName = 'URL Cache') then // noslz
                                  begin
                                    Arr_ValidatedFiles_TList[i].Add(anEntry);
                                  end
                                  else
                                    File_Added_bl := False;
                                end

                                // Everything Else Gets Added Here ---------------------------------------
                                else
                                begin
                                  Arr_ValidatedFiles_TList[i].Add(anEntry);
                                end;
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
var
  aArtifactEntry: TEntry;
  aArtifactEntryParent: TEntry;
  AddList2: TList;
  ADDList: TList;
  aPropertyTree: TPropertyParent;
  aRootProperty: TPropertyNode;
  b, i, g, s, x, y, z: integer;
  bl_log_missing_tables: boolean;
  ByteArray: array of byte;
  CarvedData: TByteInfo;
  CarvedEntry: TEntry;
  CarvedEntryReader: TEntryReader;
  carved_str: string;
  ColCount: integer;
  col_DF: TDataStoreFieldArray;
  curpos: integer;
  data_size: int64;
  Display_Name_str: string;
  DNT_sql_col: string;
  dt_str: string;
  end_pos: int64;
  FooterReader: TEntryReader;
  gh_int: integer;
  HeaderReader: TEntryReader;
  HeaderRegex, FooterRegEx: TRegEx;
  h_startpos, h_offset, h_count, f_offset, f_count: int64;
  Item: PSQL_FileSearch;
  Log_ChromeCache_bl: boolean;
  mydb: TSQLite3Database;
  NewEntry: TArtifactItem;
  newEntryReader: TEntryReader;
  newJOURNALReader: TEntryReader;
  newWALReader: TEntryReader;
  Node1, Node2, Node3: TPropertyNode;
  NodeList1, NodeList2: TObjectList;
  NumberOfNodes: integer;
  records_read_int: integer;
  refetch_count: int64;
  reuse_count: int64;
  Size: integer;
  sqlselect: TSQLite3Statement;
  sqlselect_row: TSQLite3Statement;
  sql_row_count: integer;
  sql_tbl_count: integer;
  sSize: integer;
  startpos: integer;
  table_name: string;
  tempstr: string;
  Temp_NodeList: TList;
  temp_TList: TList;
  TestNode1: TPropertyNode;
  TestNode2: TPropertyNode;
  test_bytes: Tbytes;
  tmp_Entry: TEntry;
  tmp_str: string;
  TotalFiles: int64;
  url_dt: TDateTime;
  url_len: dword;
  url_str, title_str, fav_str: string;
  url_unixdt: int64;
  variant_Array: array of variant;

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
          // Special case needed for Internet Explorer 4-9
          try
            if (Item^.fi_Process_ID = 'DNT_INTERNET_EXPLORER_4_9') then
              if UpperCase(Item^.fi_Name_Program_Type) = UpperCase(variant_Array[g]) then
                populate_bl := True;
            if (col_DF[g].FieldType = ftDateTime) then
              col_DF[g].AsDateTime[NEntry] := variant_Array[g];
            if (col_DF[g].FieldType = ftinteger) then
              col_DF[g].AsInteger[NEntry] := variant_Array[g];
            if (col_DF[g].FieldType = ftLargeInt) then
              col_DF[g].AsInteger[NEntry] := variant_Array[g];
            if (col_DF[g].FieldType = ftString) and VarIsStr(variant_Array[g]) and (variant_Array[g] <> '') then
              col_DF[g].AsString(NEntry) := variant_Array[g];
            if (col_DF[g].FieldType = ftBytes) then
              col_DF[g].AsBytes[NEntry] := variantToArrayBytes(variant_Array[g]);
          except
            on e: exception do
              Progress.Log(e.message);
          end;
      end;
      if (Item^.fi_Process_ID = 'DNT_INTERNET_EXPLORER_4_9') and populate_bl then
        ADDList.Add(NEntry);
      if not(Item^.fi_Process_ID = 'DNT_INTERNET_EXPLORER_4_9') then
        ADDList.Add(NEntry);
    end;
    NullTheArray;
  end;

  procedure ProcessAsESE;
  var
    anArray: array of integer;
    ContainerID_name_str: string;
    EntryReader: TEntryReader;
    FESE: TESE; // called per edb entry
    FESEDatabase: TESEDataBase;
    Tbl: TeseTable;
    eseQuery: TESEQuery;
    j, k: integer;

    function ColumnAsDT(col: TEseColumn): TDateTime;
    var
      temp_int64: int64;
    begin
      Result := 0;
      if assigned(col) then
        if col.ColType = ctLongLong then
        begin
          temp_int64 := col.ReadAsUInt64;
          Result := IntToDateTime(temp_int64 div 10, 'DTChrome'); // KVL - Force the conversion type.
        end;
    end;

    function ColumnToInteger(col: TEseColumn): int64;
    begin
      Result := 0;
      if assigned(col) then
        case col.ColType of
          ctBoolean:
            if col.ReadAsBoolean then
              Result := 1
            else
              Result := 0;
          ctByte:
            Result := col.ReadAsbyte;
          ctShort:
            Result := col.ReadAsWord;
          ctLong:
            Result := col.ReadAsinteger;
          ctDatetime:
            Result := col.ReadAsint64;
          ctFloatSingle, ctFloatDouble, ctCurrency, ctBinary, ctLongBinary, ctSLV, ctGUID:
            Result := col.ReadAsint64;
          ctUnsignedLong:
            Result := col.ReadAsDWord;
          ctLongLong:
            Result := col.ReadAsint64;
          ctUnsignedShort:
            Result := col.ReadAsWord;
        end;
    end;

    function ColumnToString(col: TEseColumn): string;
    begin
      Result := '';
      if assigned(col) then
        case col.ColType of
          ctBoolean:
            if col.ReadAsBoolean then
              Result := 'True'
            else
              Result := 'False';
          ctByte:
            Result := col.ReadAsHexString;
          ctShort:
            Result := IntToStr(col.ReadAsWord);
          ctLong:
            Result := IntToStr(col.ReadAsinteger);
          ctDatetime:
            Result := DateTimeToStr(col.ReadAsDateTime);
          ctFloatSingle, ctFloatDouble, ctCurrency, ctBinary, ctLongBinary, ctSLV, ctGUID:
            Result := col.ReadAsHexString;
          ctText, ctLongText:
            Result := col.ReadAsString;
          ctUnsignedLong:
            Result := IntToStr(col.ReadAsDWord);
          ctLongLong:
            Result := IntToStr(col.ReadAsUInt64);
          ctUnsignedShort:
            Result := IntToStr(col.ReadAsWord);
          ctMaxColType:
            Result := 'MaxColType';
        end;
    end;

    procedure ReadESEFields;
    var
      hex_char, hex_str: string;
      t, page_title_length, start_byte, end_byte: integer;
      BytesArray: Tbytes;
      iii: integer;
      new_str: string;
      ese_col: string;
    begin
      for g := 1 to ColCount do
      begin
        if not Progress.isRunning then
          break;
        DNT_sql_col := aItems[g].sql_col;
        ese_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
        if (DNT_sql_col = DNT_AccessedTime) then
          variant_Array[g] := ColumnAsDT(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_ContainerID) then
          variant_Array[g] := ColumnToInteger(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_CreationTime) then
          variant_Array[g] := ColumnAsDT(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_EntryID) then
          variant_Array[g] := ColumnToInteger(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_ExpiryTime) then
          variant_Array[g] := ColumnAsDT(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_Filename) then
          variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_Filesize) then
          variant_Array[g] := ColumnToInteger(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_Flags) then
          variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_AccessCount) then
          variant_Array[g] := ColumnToInteger(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_ModifiedTime) then
          variant_Array[g] := ColumnAsDT(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_RecoveryType) then
          variant_Array[g] := 'ESE Parse';
        if (DNT_sql_col = DNT_SyncTime) then
          variant_Array[g] := ColumnAsDT(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_Url) then
          variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
        if (DNT_sql_col = DNT_UrlHash) then
          variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));

        // ESE History Response Header for Page Title
        if (Item^.fi_ESE_ContainerName = RS_DNT_History) then
        begin
          if (DNT_sql_col = DNT_ResponseHeaders) then
          begin
            if assigned(eseQuery.CurrentRow.ColumnByName(ese_col)) then
            begin
              BytesArray := eseQuery.CurrentRow.ColumnByName(ese_col).ReadAsTBytes;
              if Length(BytesArray) > 64 then
              begin
                for b := 0 to Length(BytesArray) - 1 do
                begin
                  if not Progress.isRunning then
                    break;
                  hex_str := '';
                  new_str := '';
                  hex_char := '';
                  page_title_length := 0;
                  // Create a string of array values in hex
                  hex_char := inttohex(BytesArray[b], 2);
                  hex_str := hex_str + hex_char;
                  // Test to locate start of page title after 1F-00-00-00
                  if hex_char = '1F' then
                  begin
                    hex_char := hex_char + '-' + inttohex(BytesArray[b + 1], 2);
                    hex_char := hex_char + '-' + inttohex(BytesArray[b + 2], 2);
                    hex_char := hex_char + '-' + inttohex(BytesArray[b + 3], 2);
                    // If 1F-00-00-00 found set the start byte
                    if hex_char = '1F-00-00-00' then
                    begin
                      start_byte := b + 8;
                      hex_str := '';
                      hex_char := '';
                      // Read from the start byte
                      for iii := start_byte to high(BytesArray) do
                      begin
                        if not Progress.isRunning then
                          break;
                        hex_char := inttohex(BytesArray[iii], 2);
                        hex_str := hex_str + hex_char;
                        // Test look for the terminator 00-00
                        if hex_char = '00' then
                        begin
                          hex_char := hex_char + '-' + inttohex(BytesArray[iii + 1], 2);
                          // If terminator found set the end byte and Page Title length
                          if hex_char = '00-00' then
                          begin
                            end_byte := iii;
                            page_title_length := end_byte - start_byte;
                            // Read the Page Title into a char string
                            if page_title_length > 0 then
                            begin
                              for t := start_byte to end_byte do
                                if BytesArray[t] <> 0 then
                                  new_str := new_str + chr(BytesArray[t]);
                              if VERBOSE then
                                Progress.Log('ESE History Page Title: Start Byte: ' + IntToStr(start_byte) + SPACE + 'End Byte: ' + IntToStr(end_byte) + SPACE + 'length: ' + IntToStr(page_title_length) + SPACE + new_str);
                              variant_Array[g] := new_str;
                              break; // No further processing of the response header
                            end;
                          end;
                        end;
                      end;
                      break;
                    end;
                  end; { search for 1F marker }
                end; { read full byte array }
              end;
              variant_Array[g] := new_str;
            end;
          end;
        end;

        if (Item^.fi_ESE_ContainerName = RS_DNT_iedownload) then
          if (DNT_sql_col = DNT_ResponseHeaders) and assigned(eseQuery.CurrentRow.ColumnByName(ese_col)) then
          begin
            BytesArray := eseQuery.CurrentRow.ColumnByName(ese_col).ReadAsTBytes;
            new_str := '';
            // Read backwards form the end of the response header to get the file name after the first found terminator
            for iii := high(BytesArray) - 2 downto 1 do
            begin
              hex_char := inttohex(BytesArray[iii], 2);
              hex_str := hex_str + hex_char;
              // Test look for the terminator 00-00
              if hex_char = '00' then
              begin
                hex_char := hex_char + '-' + inttohex(BytesArray[iii - 1], 2);
                if hex_char = '00-00' then
                begin
                  start_byte := iii;
                  // Read the download file into a char string
                  for t := start_byte to high(BytesArray) do
                    if BytesArray[t] <> 0 then
                      new_str := new_str + chr(BytesArray[t]);
                  if VERBOSE then
                    Progress.Log('ESE History Page Title: Start Byte: ' + IntToStr(start_byte) + SPACE + 'End Byte: ' + IntToStr(end_byte) + SPACE + 'length: ' + IntToStr(page_title_length) + SPACE + new_str);
                  variant_Array[g] := new_str;
                  break; // No further processing of the response header
                end;
              end;
            end;
            variant_Array[g] := new_str;
          end; { ieDownload }
      end;
    end;

  var
    ese_col: string;
  begin
    NullTheArray;
    // DetermineFileType(aArtifactEntry);

    // Open the Data Stream;
    EntryReader := TEntryReader.Create;
    EntryReader.OpenData(aArtifactEntry);
    try
      // Create reader and open
      FESE := TESE.Create(Progress); // PacProgress can be nil;
      FESEDatabase := TESEDataBase.Create(FESE);
      try
        // Open ESE Stream
        if VERBOSE then
          Progress.Log('Open ESE stream');
        FESE.open(EntryReader, nil, eomQuickTable);
        FESEDatabase.OpenStream(EntryReader, nil);

        if VERBOSE then
          Progress.Log(StringOfChar('-', CHAR_LENGTH));
        // Find table
        if VERBOSE then
          Progress.Log(RPad('Total Tables:', RPAD_VALUE) + IntToStr(FESE.Tables.Count));
        Tbl := nil;
        for Tbl in FESE.Tables do
        begin
          if not Progress.isRunning then
            break;

          if (Tbl.TableName = 'Containers') then
          begin
            // Open the table found
            if VERBOSE then
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

            eseQuery := FESEDatabase.OpenTable(Tbl);
            if assigned(eseQuery) then
              try
                if VERBOSE then
                  Progress.Log(RPad('Opened Table:', RPAD_VALUE) + Tbl.TableName);
                Progress.DisplayMessages := ('Opened Table:' + SPACE + Tbl.TableName);

                if VERBOSE then
                  Progress.Log(RPad('Unique "Name" col values:', RPAD_VALUE) + IntToStr(Tbl.Coldefslist.Count));
                ContainerID_name_str := Item^.fi_ESE_ContainerName;
                if VERBOSE then
                  Progress.Log(RPad('Search ' + Tbl.TableName + '\Name for:', RPAD_VALUE) + '"' + ContainerID_name_str + '"');
                eseQuery.First;
                setlength(anArray, Tbl.RecordCount);
                k := 0;

                // Loop over 'containers' find all rows with "content" in name column and get the ContainerID from that row and store into array
                while not eseQuery.EOF and Progress.isRunning do
                begin
                  // Get the contents of name column
                  if eseQuery.CurrentRow.ColumnByName(RS_DNT_Name1).ReadAsString = ContainerID_name_str then // name
                  begin
                    // Add item to array
                    if VERBOSE then
                      Progress.Log(RPad('Found "' + eseQuery.CurrentRow.ColumnByName(RS_DNT_Name1).ReadAsString + '"', RPAD_VALUE) + 'ContainerId' + SPACE + IntToStr(eseQuery.CurrentRow.ColumnByName('ContainerId').ReadAsinteger));
                    anArray[k] := ColumnToInteger(eseQuery.CurrentRow.ColumnByName('ContainerId')); // ContainerID
                    Inc(k);
                  end;
                  eseQuery.Next;
                end; { End while }
                setlength(anArray, k);
                break;
              finally
                eseQuery.free;
              end;
          end;
        end;
        if VERBOSE then
          Progress.Log(RPad('Added tables to anArray:', RPAD_VALUE) + IntToStr(high(anArray)));
        if VERBOSE then
          Progress.Log(StringOfChar('-', CHAR_LENGTH));

        // Process IE 10-11 ESE Database Tables (Dependency is processed separately below)
        if not(Item^.fi_ESE_ContainerName = 'DependencyEntryEx') then // !NOT
          for Tbl in FESE.Tables do
          begin

            if not Progress.isRunning then
              break;
            for j := 0 to high(anArray) do
            begin
              if not Progress.isRunning then
                break;

              if VERBOSE then
                Progress.Log('Testing ' + Tbl.TableName + ' =' + 'Container_' + IntToStr(anArray[j]));
              if (Tbl.TableName = 'Container_' + IntToStr(anArray[j])) then
              begin

                if VERBOSE then
                  Progress.Log(RPad('Processing Table:', RPAD_VALUE) + Tbl.TableName);
                // Open the table found

                // Tbl := EseReader.Tablelist[m]; // Check we have a table and that it is opened
                eseQuery := FESEDatabase.OpenTable(Tbl);
                if assigned(eseQuery) then
                  try
                    if VERBOSE then
                      Progress.Log(RPad('Opened:', RPAD_VALUE) + Tbl.TableName);
                    if VERBOSE then
                      Progress.DisplayMessages := 'Opened' + SPACE + Tbl.TableName;
                    eseQuery.First;
                    k := 0;
                    g := 1;

                    while not eseQuery.EOF and Progress.isRunning do
                    begin
                      NullTheArray;
                      if (Item^.fi_ESE_ContainerName = RS_DNT_Content) then
                        ReadESEFields;
                      if (Item^.fi_ESE_ContainerName = RS_DNT_Cookies) then
                        ReadESEFields;
                      if (Item^.fi_ESE_ContainerName = RS_DNT_History) then
                        ReadESEFields;
                      if (Item^.fi_ESE_ContainerName = RS_DNT_iedownload) then
                        ReadESEFields;
                      AddToModule;
                      eseQuery.Next;
                      Inc(k);
                    end; { while }

                    Progress.DisplayMessages := 'Read rows' + SPACE + Tbl.TableName + RUNNING;
                    if VERBOSE then
                      Progress.Log(RPad('Total rows:', RPAD_VALUE) + IntToStr(k));
                  finally
                    eseQuery.free;
                  end
                else if VERBOSE then
                  Progress.Log('Table not found or Not Opened');

                if VERBOSE then
                  Progress.Log(StringOfChar('-', CHAR_LENGTH));
              end; { if table name }
            end; { for array }
          end;

        // Process IE 10-11 ESE Database Tables (Dependency Only)
        if (Item^.fi_ESE_ContainerName = 'DependencyEntryEx') then
          for Tbl in FESE.Tables do
          begin
            if not Progress.isRunning then
              break;

            if RegexMatch(Tbl.TableName, RS_DNT_Dependency, False) then
            begin
              eseQuery := FESEDatabase.OpenTable(Tbl);
              if assigned(eseQuery) then
                try
                  eseQuery.First;
                  k := 0;
                  g := 1;
                  while not eseQuery.EOF and Progress.isRunning do
                  begin
                    NullTheArray;
                    // The Discrepancy table has mostly unique fields
                    for g := 1 to ColCount do
                    begin
                      DNT_sql_col := aItems[g].sql_col;
                      ese_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
                      if (DNT_sql_col = DNT_EntryID) then
                        variant_Array[g] := ColumnToInteger(eseQuery.CurrentRow.ColumnByName(ese_col));
                      if (DNT_sql_col = DNT_Hostname) then
                        variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
                      if (DNT_sql_col = DNT_ModifiedTime) then
                        variant_Array[g] := ColumnAsDT(eseQuery.CurrentRow.ColumnByName(ese_col));
                      if (DNT_sql_col = DNT_Port) then
                        variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
                      if (DNT_sql_col = DNT_RecoveryType) then
                        variant_Array[g] := 'ESE Parse';
                      if (DNT_sql_col = DNT_Url) then
                        variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
                      if (DNT_sql_col = DNT_UrlSchemaType) then
                        variant_Array[g] := ColumnToString(eseQuery.CurrentRow.ColumnByName(ese_col));
                    end;
                    AddToModule;
                    eseQuery.Next;
                    Inc(k);
                  end; { end of table }
                finally
                  eseQuery.free;
                end;
            end; { if table name }
          end { for table list };
      finally
        FreeAndNil(FESE);
      end;
    finally
      FreeAndNil(EntryReader);
    end;
  end; { Procedure: Process as ESE Table }

  function CarveAccessCount(hdr_start_of_regex_match: int64): variant;
  var
    AccessCount_int, AccessCount_offset_end, AccessCount_offset_start: int64;
  begin
    Result := null;
    HeaderReader.Position := hdr_start_of_regex_match - 62;
    AccessCount_offset_start := HeaderReader.Position;
    AccessCount_int := HeaderReader.AsInteger;
    AccessCount_offset_end := HeaderReader.Position;
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + IntToStr(AccessCount_int) + SPACE + '(Bytes read: ' + IntToStr(AccessCount_offset_end - AccessCount_offset_start) + ', starting at: ' + IntToStr(AccessCount_offset_start) + ')');
    if (AccessCount_int > 0) and (AccessCount_int < 10000) then // Sanity check
      Result := AccessCount_int;
  end;

  function SetFileOffset(hdr_start_of_regex_match: int64): variant;
  begin
    Result := null;
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + IntToStr(hdr_start_of_regex_match));
    Result := hdr_start_of_regex_match;
  end;

  function CarveFlags(hdr_start_of_regex_match: int64): variant;
  var
    Flags_int, Flags_offset_end, Flags_offset_start: int64;
    Flags_str: string;
  begin
    Result := null;
    Flags_str := '';
    HeaderReader.Position := hdr_start_of_regex_match - 66;
    Flags_offset_start := HeaderReader.Position;
    Flags_int := HeaderReader.AsInteger;
    Flags_offset_end := HeaderReader.Position;
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + IntToStr(Flags_int) + SPACE + '(Bytes read: ' + IntToStr(Flags_offset_end - Flags_offset_start) + ', starting at: ' + IntToStr(Flags_offset_start) + ')');
    if (Flags_int > 0) and (Flags_int < 200) then // Sanity check
    begin
      Flags_str := IntToStr(Flags_int);
      Result := Flags_str;
    end;
  end;

  function SetRecoveryType(const AString: string): variant;
  begin
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + AString);
    Result := AString;
  end;

  function CarveURL(carve_position: int64): variant;
  var
    printchars: string;
  begin
    HeaderReader.Position := carve_position;
    printchars := HeaderReader.AsNullWideString; // Stops printing when it reaches a null char
    printchars := StringReplace(printchars, '%20', ' ', [rfReplaceAll]);
    // Progress.Log(printchars); // Prints the carved URL
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + printchars);
    Result := printchars;
  end;

  function CarveURLHash(carve_position: int64): variant;
  var
    urlhash_int: int64;
    urlhash_str: string;
  begin
    urlhash_str := '';
    HeaderReader.Position := carve_position - 90;
    urlhash_int := HeaderReader.Asint64; // Stops printing when it reaches a null char
    if (Length(urlhash_int) >= 17) and (Length(urlhash_int) <= 19) then
      urlhash_str := IntToStr(urlhash_int);
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + urlhash_str);
    Result := urlhash_str;
  end;

  function CarveFileName(carve_position: int64): variant;
  var
    printchars: string;
  begin
    HeaderReader.Position := carve_position;
    HeaderReader.AsNullWideString; // Takes header reader to the end of the url
    HeaderReader.Position := HeaderReader.Position + 1;
    printchars := HeaderReader.AsNullWideString;
    printchars := StringReplace(printchars, '%20', ' ', [rfReplaceAll]);
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + printchars);
    Result := printchars;
  end;

  function CarveFileSize(carve_position: int64): variant;
  var
    hex_str, filesize_str: string;
    FileSizeStart_int64, FileSizeEnd_int64, distance_to_terminator: int64;
    m, ndx, FileSize_int, FileSizeBytes_int: integer;
  begin
    Result := null;
    filesize_str := '';
    FileSize_int := 0;
    HeaderReader.Position := carve_position;
    HeaderReader.AsNullWideString; // Takes header reader to the end of the url
    HeaderReader.Position := HeaderReader.Position + 1; // Takes the header reader to the end of the file name
    HeaderReader.AsNullWideString;
    HeaderReader.Position := HeaderReader.Position + 1;
    for m := 1 to 200 do
    begin
      if not Progress.isRunning then
        break;

      hex_str := HeaderReader.AsHexString(16);
      if HeaderReader.Position >= HeaderReader.Size then
      begin
        MessageUser('Error. HeaderReader exceeded HeaderReader size.');
        Exit;
      end;

      if (hex_str = ' 43 6F 6E 74 65 6E 74 2D 4C 65 6E 67 74 68 3A 20') then // "Content-Length: "
      begin
        FileSizeStart_int64 := HeaderReader.Position;

        // Locate the terminator immediately after the file size
        distance_to_terminator := 20;
        for ndx := 1 to distance_to_terminator do
        begin
          if not Progress.isRunning then
            break;
          hex_str := HeaderReader.AsHexString(2);

          if HeaderReader.Position >= HeaderReader.Size then
          begin
            MessageUser('Error. HeaderReader exceeded HeaderReader size.');
            Exit;
          end;

          if hex_str = ' 0D 0A' then
          begin
            FileSizeEnd_int64 := HeaderReader.Position - 2;
            FileSizeBytes_int := FileSizeEnd_int64 - FileSizeStart_int64;
            HeaderReader.Position := FileSizeStart_int64;
            filesize_str := HeaderReader.AsPrintableChar(FileSizeBytes_int);
            if VERBOSE then
              Progress.Log(RPad('File Size:', RPAD_VALUE) + filesize_str + SPACE + '(start: ' + IntToStr(FileSizeStart_int64) + SPACE + 'end: ' + IntToStr(FileSizeEnd_int64) + ')');

            try
              FileSize_int := StrToInt(filesize_str);
              Result := FileSize_int;
            except
              Progress.Log(ATRY_EXCEPT_STR + 'Error converting file size from string.');
            end;

            if VERBOSE then
              Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + IntToStr(FileSize_int));
            break;
          end;
          HeaderReader.Position := HeaderReader.Position - 1;
        end;
        if ndx = distance_to_terminator then
          Progress.Log('Did not find terminator.');
        Exit; // Exit if not terminator found
      end;
      HeaderReader.Position := HeaderReader.Position - 15;
    end;
  end;

// Print 5 dates when in verbose mode ----------------------------------------
  procedure VerboseDate(start_carve_position: int64);
  var
    dt_array: array of TDateTime;
    aNewDateTime: TDateTime;
    aNewDate_int, date_start_int, date_end_int: int64;
    p: integer;
    msg_str, date_str: string;
  begin
    if VERBOSE then
    begin
      setlength(dt_array, 6);
      HeaderReader.Position := start_carve_position - 58; // -18 -8 -8 -8 -8 -8
      Progress.Log((format('%-29s %-20s %-20s %-20s %-20s %-20s', ['Dates Found', 'Start', 'End', 'Total bytes', 'Date Raw', 'Date'])));
      for p := 5 downto 1 do
      begin
        aNewDate_int := 0;
        aNewDateTime := null;
        date_str := '';
        try
          date_start_int := HeaderReader.Position;
          aNewDate_int := HeaderReader.Asint64; // Header reader moves 8 bytes forward
          date_end_int := HeaderReader.Position - date_start_int;
          if DateCheck_Unix_10(aNewDate_int) then
          begin
            aNewDateTime := FileTimeToDateTime(aNewDate_int);
            dt_array[p] := aNewDateTime;
            date_str := DateTimeToStr(aNewDateTime);
          end;
          if p = 5 then
            msg_str := 'Sync Time';
          if p = 4 then
            msg_str := 'Creation Time';
          if p = 3 then
            msg_str := 'Expiry Time';
          if p = 2 then
            msg_str := 'Modified Time';
          if p = 1 then
            msg_str := 'Accessed Time';
          Progress.Log((format('%-29s %-20s %-20s %-20s %-20s %-20s', [IntToStr(p) + ': ' + msg_str, IntToStr(date_start_int), IntToStr(HeaderReader.Position), IntToStr(HeaderReader.Position - date_start_int), IntToStr(aNewDate_int),
            date_str])));
        except
          MessageUser('Error reading date.');
          Exit;
        end;
      end;
      Progress.Log(' ');
    end;
  end;

// Function: Carve Date ------------------------------------------------------
// From \xFE.. backwards: (Regex match starts here)
// - 18 back to end of first date  = 18
// - 08 Access Time                = 26
// - 08 Modified Time              = 34
// - 08 Expiry Time                = 42
// - 08 Creation Time              = 50
// - 08 Sync Time                  = 58
// - 04 start of access count      = 62
// - 04 flag                       = 66
// - 24 URLHash                    = 90
// - total

  function CarveDate(start_carve_position: int64; DateToUse_int: integer): variant;
  var
    aNewDateTime: TDateTime;
    aNewDate_int: int64;
    GetDateAtPosition: int64;
  begin
    Result := null;
    if (DateToUse_int >= 1) and (DateToUse_int <= 5) then
    begin
      GetDateAtPosition := start_carve_position - 18 - (DateToUse_int * 8);
      HeaderReader.Position := GetDateAtPosition;
      try
        aNewDate_int := HeaderReader.Asint64; // Header reader moves 8 bytes forward
        if DateCheck_Unix_10(aNewDate_int) then
        begin
          aNewDateTime := FileTimeToDateTime(aNewDate_int);
          Result := aNewDateTime;
        end;
      except
        MessageUser('Error reading date.');
      end;
    end;
  end;

  procedure PrintCarveHeader(hdr_start: int64; hdr_end: int64; hdr_count: int64);
  begin
    if VERBOSE then
      Progress.Log((format('%-29s %-20s %-20s %-20s', ['Regex Match: Visited', 'Start', 'End', 'Total bytes'])));
    if VERBOSE then
      Progress.Log((format('%-29s %-20s %-20s %-20s', ['', IntToStr(hdr_start), IntToStr(hdr_end), IntToStr(hdr_count)])));
    if VERBOSE then
      Progress.Log(' ');
  end;

  function CarveReference(hdr_end: int64): string;
  var
    printchars: string;
  begin
    Result := '';
    HeaderReader.Position := hdr_end - 36;
    try
      printchars := HeaderReader.AsPrintableChar(32);
    except
      MessageUser('Error reading carve of "Reference".');
      Exit;
    end;
    printchars := StringReplace(printchars, '.', '', [rfReplaceAll]);
    Result := printchars;
    if VERBOSE then
      Progress.Log(RPad(DNT_sql_col + COLON, RPAD_VALUE) + Result);
  end;

  procedure ProcessAsESECarveContent;
  var
    hdr_start_of_regex_match: int64;
    hdr_count_of_matched_bytes: int64;
    hdr_last_matched_char: int64;
  begin
    if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_CONTENT) then
    begin
      if HeaderReader.OpenData(aArtifactEntry) then // Open the entry to search
      begin
        try
          HeaderReader.Position := 0;
          HeaderRegex.Stream := HeaderReader;
          HeaderRegex.Find(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          while (hdr_start_of_regex_match <> -1) do
          begin
            if not Progress.isRunning then
              break;
            NullTheArray;
            curpos := HeaderReader.Position; // Save the position

            // Set starting position (do not go past the beginning of the file)
            if hdr_start_of_regex_match < 0 then
              hdr_start_of_regex_match := 0;

            // Set ending position (do not go past the end of the file)
            hdr_last_matched_char := hdr_start_of_regex_match + hdr_count_of_matched_bytes;
            if hdr_last_matched_char >= HeaderReader.Size then
              hdr_last_matched_char := HeaderReader.Size - 1;

            if VERBOSE then
              PrintCarveHeader(hdr_start_of_regex_match, hdr_last_matched_char, hdr_count_of_matched_bytes);
            if VERBOSE then
              VerboseDate(hdr_start_of_regex_match);

            // Put in this loop so that the order of columns positions can be easily changed
            for g := 1 to ColCount do
            begin
              DNT_sql_col := aItems[g].sql_col;
              if not Progress.isRunning then
                break;
              if (DNT_sql_col = DNT_AccessedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 1); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ModifiedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 2); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ExpiryTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 3); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_CreationTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 4); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_SyncTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 5); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_AccessCount) then
                variant_Array[g] := CarveAccessCount(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Filename) then
                variant_Array[g] := CarveFileName(hdr_last_matched_char - 8); // -8 is back from http
              if (DNT_sql_col = DNT_FileOffset) then
                variant_Array[g] := SetFileOffset(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Filesize) then
                variant_Array[g] := CarveFileSize(hdr_last_matched_char);
              if (DNT_sql_col = DNT_Flags) then
                variant_Array[g] := CarveFlags(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_RecoveryType) then
                variant_Array[g] := SetRecoveryType(Item^.fi_Recovery_Type);
              if (DNT_sql_col = DNT_Url) then
                variant_Array[g] := CarveURL(hdr_last_matched_char - 8);
              if (DNT_sql_col = DNT_UrlHash) then
                variant_Array[g] := CarveURLHash(hdr_start_of_regex_match);
            end;
            AddToModule;
            if VERBOSE then
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

            // Restore the position and find the next match
            HeaderReader.Position := curpos;
            HeaderRegex.FindNext(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          end;
        except
          MessageUser('Error processing ' + aArtifactEntry.EntryName);
        end;
      end;
    end;
  end;

  procedure ProcessAsESECarveCookies;
  var
    hdr_start_of_regex_match: int64;
    hdr_count_of_matched_bytes: int64;
    hdr_last_matched_char: int64;
  begin
    if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_COOKIES) then
    begin
      if HeaderReader.OpenData(aArtifactEntry) then // Open the entry to search
      begin
        try
          HeaderReader.Position := 0;
          HeaderRegex.Stream := HeaderReader;
          HeaderRegex.Find(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          while (hdr_start_of_regex_match <> -1) do
          begin
            if not Progress.isRunning then
              break;
            NullTheArray;

            // Save the position
            curpos := HeaderReader.Position;

            // Set starting position (do not go past the beginning of the file)
            if hdr_start_of_regex_match < 0 then
              hdr_start_of_regex_match := 0;

            // Set ending position (do not go past the end of the file)
            hdr_last_matched_char := hdr_start_of_regex_match + hdr_count_of_matched_bytes;
            if hdr_last_matched_char >= HeaderReader.Size then
              hdr_last_matched_char := HeaderReader.Size - 1;

            if VERBOSE then
              PrintCarveHeader(hdr_start_of_regex_match, hdr_last_matched_char, hdr_count_of_matched_bytes);
            if VERBOSE then
              VerboseDate(hdr_start_of_regex_match);

            // Put in this loop so that the order of columns positions can be easily changed
            for g := 1 to ColCount do
            begin
              DNT_sql_col := aItems[g].sql_col;
              if not Progress.isRunning then
                break;
              if (DNT_sql_col = DNT_AccessedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 1); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ModifiedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 2); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ExpiryTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 3); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_CreationTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 4); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_SyncTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 5); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_AccessCount) then
                variant_Array[g] := CarveAccessCount(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Filename) then
                variant_Array[g] := CarveFileName(hdr_last_matched_char - 8); // -8 is back from http
              if (DNT_sql_col = DNT_FileOffset) then
                variant_Array[g] := SetFileOffset(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Flags) then
                variant_Array[g] := CarveFlags(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_RecoveryType) then
                variant_Array[g] := SetRecoveryType(Item^.fi_Recovery_Type);
              if (DNT_sql_col = DNT_Url) then
                variant_Array[g] := CarveURL(hdr_last_matched_char - 14);
              if (DNT_sql_col = DNT_UrlHash) then
                variant_Array[g] := CarveURLHash(hdr_start_of_regex_match);
            end;
            AddToModule;
            if VERBOSE then
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

            // Restore the position and find the next match
            HeaderReader.Position := curpos;
            HeaderRegex.FindNext(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          end;
        except
          MessageUser('Error processing ' + aArtifactEntry.EntryName);
        end;
      end;
    end;
  end;

  procedure ProcessAsESECarveHistoryVisited;
  var
    hdr_start_of_regex_match: int64;
    hdr_count_of_matched_bytes: int64;
    hdr_last_matched_char: int64;
    temp_pos_str: string;
    printchars: string;
    ndx: integer;
    hex_str: string;
  begin
    if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_HISTORY_VISITED) then
    begin
      if HeaderReader.OpenData(aArtifactEntry) then // Open the entry to search
      begin
        try
          HeaderReader.Position := 0;
          HeaderRegex.Stream := HeaderReader;
          HeaderRegex.Find(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          while (hdr_start_of_regex_match <> -1) do
          begin
            if not Progress.isRunning then
              break;
            NullTheArray;

            // Save the position
            curpos := HeaderReader.Position;

            // Set starting position (do not go past the beginning of the file)
            if hdr_start_of_regex_match < 0 then
              hdr_start_of_regex_match := 0;

            // Set ending position (do not go past the end of the file)
            hdr_last_matched_char := hdr_start_of_regex_match + hdr_count_of_matched_bytes;
            if hdr_last_matched_char >= HeaderReader.Size then
              hdr_last_matched_char := HeaderReader.Size - 1;

            if VERBOSE then
              PrintCarveHeader(hdr_start_of_regex_match, hdr_last_matched_char, hdr_count_of_matched_bytes);
            if VERBOSE then
              VerboseDate(hdr_start_of_regex_match);

            // Put in this loop so that the order of columns positions can be easily changed
            for g := 1 to ColCount do
            begin
              DNT_sql_col := aItems[g].sql_col;
              if not Progress.isRunning then
                break;
              printchars := '';

              if (DNT_sql_col = DNT_AccessedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 1); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ModifiedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 2); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ExpiryTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 3); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_CreationTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 4); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_SyncTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 5); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_AccessCount) then
                variant_Array[g] := CarveAccessCount(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_FileOffset) then
                variant_Array[g] := SetFileOffset(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Flags) then
                variant_Array[g] := CarveFlags(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_RecoveryType) then
                variant_Array[g] := SetRecoveryType(Item^.fi_Recovery_Type);
              if (DNT_sql_col = DNT_Url) then
                variant_Array[g] := CarveURL(hdr_last_matched_char - 18); // The URL string is to include "Visited:"
              if (DNT_sql_col = DNT_UrlHash) then
                variant_Array[g] := CarveURLHash(hdr_start_of_regex_match);

              // Carve_History_Visited - Page Title ------------------------------
              if (DNT_sql_col = DNT_PageTitle) then
              begin
                // Set the starting position at the terminator at the end of the URL
                HeaderReader.Position := hdr_start_of_regex_match;
                temp_pos_str := HeaderReader.AsNullWideString; // Stops printing when it reaches a null char
                HeaderReader.Position := HeaderReader.Position + 1; // Takes 1 forward to the 01 of 00 00 00 01.
                // Locate and read the page title
                HeaderReader.Position := HeaderReader.Position + 8;
                printchars := HeaderReader.AsPrintableChar(4);
                if printchars = '1SPS' then
                begin
                  for ndx := 1 to 100 do
                  begin
                    hex_str := HeaderReader.AsHexString(4);
                    if (hex_str = ' 1F 00 00 00') then
                    begin
                      HeaderReader.Position := HeaderReader.Position + 4;
                      printchars := HeaderReader.AsNullWideString;
                      if Length(printchars) > 4 then
                        variant_Array[g] := printchars;
                      break;
                    end;
                    HeaderReader.Position := HeaderReader.Position - 3;
                  end;
                end;
              end; { Page Title }

            end;
            AddToModule;
            if VERBOSE then
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

            // Restore the position and find the next match
            HeaderReader.Position := curpos;
            HeaderRegex.FindNext(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          end;
        except
          MessageUser('Error processing ' + aArtifactEntry.EntryName);
        end;
      end;
    end;
  end;

  procedure ProcessAsESECarveHistoryRefMarker;
  var
    hdr_start_of_regex_match: int64;
    hdr_count_of_matched_bytes: int64;
    hdr_last_matched_char: int64;
  begin
    if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_HISTORY_REF_MARKER) then
    begin
      if HeaderReader.OpenData(aArtifactEntry) then // Open the entry to search
      begin
        try
          HeaderReader.Position := 0;
          HeaderRegex.Stream := HeaderReader;
          HeaderRegex.Find(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          while (hdr_start_of_regex_match <> -1) do
          begin
            if not Progress.isRunning then
              break;
            NullTheArray;

            // Save the position
            curpos := HeaderReader.Position;

            // Set starting position (do not go past the beginning of the file)
            if hdr_start_of_regex_match < 0 then
              hdr_start_of_regex_match := 0;

            // Set ending position (do not go past the end of the file)
            hdr_last_matched_char := hdr_start_of_regex_match + hdr_count_of_matched_bytes;
            if hdr_last_matched_char >= HeaderReader.Size then
              hdr_last_matched_char := HeaderReader.Size - 1;

            if VERBOSE then
              PrintCarveHeader(hdr_start_of_regex_match, hdr_last_matched_char, hdr_count_of_matched_bytes);
            if VERBOSE then
              VerboseDate(hdr_start_of_regex_match);

            // Put in this loop so that the order of columns positions can be easily changed
            for g := 1 to ColCount do
            begin
              DNT_sql_col := aItems[g].sql_col;
              if not Progress.isRunning then
                break;

              if (DNT_sql_col = DNT_AccessedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 1); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ModifiedTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 2); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_ExpiryTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 3); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_CreationTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 4); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_SyncTime) then
                variant_Array[g] := CarveDate(hdr_start_of_regex_match, 5); // Date 1 is the closest to regex match
              if (DNT_sql_col = DNT_AccessCount) then
                variant_Array[g] := CarveAccessCount(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Filename) then
                variant_Array[g] := CarveFileName(hdr_last_matched_char - 8); // -8 is back from http
              if (DNT_sql_col = DNT_FileOffset) then
                variant_Array[g] := SetFileOffset(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_Flags) then
                variant_Array[g] := CarveFlags(hdr_start_of_regex_match);
              if (DNT_sql_col = DNT_RecoveryType) then
                variant_Array[g] := SetRecoveryType(Item^.fi_Recovery_Type);
              if (DNT_sql_col = DNT_Reference) then
                variant_Array[g] := CarveReference(hdr_last_matched_char);
              if (DNT_sql_col = DNT_Url) then
                variant_Array[g] := CarveURL(hdr_last_matched_char);
              if (DNT_sql_col = DNT_UrlHash) then
                variant_Array[g] := CarveURLHash(hdr_start_of_regex_match);
            end;
            AddToModule;
            if VERBOSE then
              Progress.Log(StringOfChar('-', CHAR_LENGTH));

            // Restore the position and find the next match
            HeaderReader.Position := curpos;
            HeaderRegex.FindNext(hdr_start_of_regex_match, hdr_count_of_matched_bytes);
          end;
        except
          MessageUser('Error processing ' + aArtifactEntry.EntryName);
        end;
      end;
    end;
  end;

  procedure nodefrog(const ProcessID: string; aNode: TPropertyNode; anint: integer);
  var
    idx: integer;
    theNodeList: TObjectList;
    pad_str: string;
    bl_found: boolean;
    bl_logging: boolean;
    NumSeconds: integer;
    SafariDateTime: TDateTime;
  begin
    bl_logging := False;
    pad_str := (StringOfChar(' ', anint * 3));
    if assigned(aNode) and Progress.isRunning then
    begin
      theNodeList := aNode.PropChildList;
      if assigned(theNodeList) then
      begin
        if bl_logging then
          Progress.Log(pad_str + aNode.PropName); // only print the header if the node has children
        bl_found := False;

        for idx := 0 to theNodeList.Count - 1 do
        begin
          if not Progress.isRunning then
            break;
          aNode := TPropertyNode(theNodeList.items[idx]);
          for g := 1 to ColCount do
          begin
            DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
            if (UpperCase(aNode.PropName) = UpperCase(DNT_sql_col)) then
            begin
              // Safari
              if ((UpperCase(aNode.PropName) = '') and (aItems[g].col_type = ftString) and (DNT_sql_col = 'URL') and (aItems[g].convert_as = 'SafariURL')) then // Safari History Plist URL - Blank Property name
              begin
                // --------------------------------------------------------------
                if aNode.PropName = 'date_added' then // noslz
                begin
                  try
                    variant_Array[g] := IntToDateTime(StrToInt64(aNode.PropDisplayValue), 'DTChrome'); // KVL - Force the conversion type.
                  except
                    Progress.Log(ATRY_EXCEPT_STR + 'Error converting string to int.');
                  end;
                end;
              end
              else

                // Only DT values
                if (aItems[g].col_type = ftDateTime) then
                begin
                  if (ProcessID = 'DNT_SAFARI_HISTORY_XML') and (UpperCase(aNode.PropName) = 'LASTVISITEDDATE') and (aItems[g].convert_as = 'SafariDT') then
                  begin
                    NumSeconds := trunc(StrToFloatWithDecimalPoint(aNode.PropDisplayValue));
                    SafariDateTime := EncodeDateTime(2001, 1, 1, 0, 0, 0, 0);
                    SafariDateTime := IncSecond(SafariDateTime, NumSeconds);
                    variant_Array[g] := SafariDateTime;
                  end
                  else
                    // --------------------------------------------------------------
                    // Chrome or Edge
                    if ((ProcessID = 'DNT_CHROME_BOOKMARKS') or (ProcessID = 'DNT_EDGE_BOOKMARKS') or (ProcessID = 'DNT_OPERA_BOOKMARKS')) and (aItems[g].convert_as = 'DTChrome') then
                    begin
                      try
                        variant_Array[g] := IntToDateTime(StrToInt64(aNode.PropDisplayValue), aItems[g].convert_as);
                      except
                      end;
                    end
                    else if variant_Array[g] = null then // Once there is a value in the array, do not use one from deeper
                      variant_Array[g] := aNode.PropDisplayValue;
                end
                else

                // ----------------------------------------------------------------
                // The rest...
                begin
                  if variant_Array[g] = null then // Once there is a value in the array, do not use one from deeper
                  begin
                    variant_Array[g] := aNode.PropDisplayValue;
                  end;
                end;

              if bl_logging then
                Progress.Log(RPad(pad_str + aNode.PropName, RPAD_VALUE) + aNode.PropDisplayValue);
              bl_found := True;
            end;
          end;
          nodefrog(ProcessID, aNode, anint + 1);
        end;
      end;
      if bl_found then
      begin
        AddToModule; // Also nulls the array
        if bl_logging then
          Progress.Log(StringOfChar('-', CHAR_LENGTH));
        NullTheArray;
      end;
    end;
  end;

  procedure nodefrog2(const ProcessID: string; aNode: TPropertyNode; anint: integer); // Use for list of key then string, key then string
  var
    idx, k: integer;
    theNodeList: TObjectList;
    pad_str: string;
    nextNode: TPropertyNode;
    nodefollow: boolean;
  begin
    pad_str := (StringOfChar(' ', anint * 3));
    if assigned(aNode) and Progress.isRunning then
    begin
      theNodeList := aNode.PropChildList;
      if assigned(theNodeList) then
      begin
        nodefollow := True;
        for idx := 0 to theNodeList.Count - 1 do
        begin
          aNode := TPropertyNode(theNodeList.items[idx]);
          for k := 1 to ColCount do
          begin
            DNT_sql_col := copy(aItems[k].sql_col, 5, Length(aItems[k].sql_col));
            if aNode.PropName = 'key' then // noslz
            begin
              if UpperCase(aNode.PropDisplayValue) = (UpperCase(DNT_sql_col)) then
              begin
                if idx + 1 <= theNodeList.Count then
                begin
                  nextNode := TPropertyNode(theNodeList.items[idx + 1]);
                  Progress.Log(RPad(pad_str + aNode.PropDisplayValue, RPAD_VALUE) + nextNode.PropDisplayValue);
                  variant_Array[k] := nextNode.PropDisplayValue;
                  nodefollow := False;
                end;
              end;
            end;
          end;
          if nodefollow then
            nodefrog2(ProcessID, aNode, anint + 1);
        end;
        Progress.Log(StringOfChar('-', CHAR_LENGTH));
        AddToModule;
        NullTheArray;
      end;
    end;
  end;

// Start of Do Process ---------------------------------------------------------
var
  v: integer;
begin
  Item := FileItems[Reference_Number];
  temp_process_counter := 0;
  ColCount := LengthArrayTABLE(aItems);

  if Item^.fi_Process_As = 'POSTPROCESS' then
  begin
    temp_TList := TList.Create;
    try
      temp_TList := ArtifactsDataStore.GetEntireList;
      for v := 0 to ArtifactsDataStore.Count - 1 do
      begin
        tmp_Entry := TEntry(temp_TList[v]);
        Arr_ValidatedFiles_TList[Reference_Number].Add(tmp_Entry);
      end;
    finally
      temp_TList.free;
    end;
  end;

  // Add artifact program sub-folder
  if (Item^.fi_Process_As = 'POSTPROCESS') and (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) then
  begin
    if assigned(anArtifactFolder) then
    begin
      if SetUpColumnforFolder(Reference_Number, anArtifactFolder, col_DF, ColCount, aItems) then
      begin
        setlength(variant_Array, ColCount + 1);
        AddList2 := TList.Create;
        try
          ArtifactConnect_ProgramFolder[Reference_Number] := AddArtifactConnect(TEntry(ArtifactConnect_CategoryFolder), Item^.fi_Name_Program, Item^.fi_Name_Program_Type, Item^.fi_Name_OS, Item^.fi_Icon_Program, Item^.fi_Icon_OS);
          ArtifactConnect_ProgramFolder[Reference_Number].Status := ArtifactConnect_ProgramFolder[Reference_Number].Status + [dstUserCreated];

          // Add artifact summary records
          for i := 0 to Arr_ValidatedFiles_TList[Reference_Number].Count - 1 do
          begin
            if not Progress.isRunning then
              break;
            tmp_Entry := TEntry(Arr_ValidatedFiles_TList[Reference_Number][i]);
            tmp_str := col_url.AsString(tmp_Entry);

            query_str := '';

            if RegexMatch(tmp_str, REGEX_DATING_URL, False) then
              query_str := tmp_str
            else if RegexMatch(tmp_str, REGEX_MAPS_QUERY, False) then
              query_str := trim(PerlMatch('(?<=\/place\/|\/dir\/)(.*)(?=\/@|\/data)', tmp_str))
            else if RegexMatch(tmp_str, REGEX_SHIPPING_URL, False) then
              query_str := tmp_str
            else if RegexMatch(tmp_str, REGEX_YOUTUBE_QUERY, False) then
              query_str := trim(PerlMatch('(?<=search_query\=)(.*)(?=&|$)', tmp_str)) // noslz
            else
              query_str := trim(PerlMatch('(?<=\q=)(.*)(?=&|$)', tmp_str));

            query_str := trim(CleanString(query_str));

            if RegexMatch(tmp_str, Item^.fi_Regex_Search, False) then
            begin
              if assigned(tmp_Entry) then
              begin
                NewEntry := TArtifactItem.Create;
                NewEntry.SourceEntry := tmp_Entry;
                NewEntry.Parent := ArtifactConnect_ProgramFolder[Reference_Number];
                NewEntry.PhysicalSize := 0;
                NewEntry.LogicalSize := 0;

                NullTheArray;
                for g := 1 to ColCount do
                begin
                  if not Progress.isRunning then
                    break;
                  DNT_sql_col := aItems[g].sql_col;
                  if DNT_sql_col = 'DNT_URL' then
                    variant_Array[g] := tmp_str;
                  if DNT_sql_col = 'DNT_QUERY' then
                    variant_Array[g] := query_str;
                  if DNT_sql_col = 'DNT_ENTRY_PATH' then
                    variant_Array[g] := col_source_path.AsString(tmp_Entry);
                  if DNT_sql_col = 'DNT_ENTRY_NAME' then
                    variant_Array[g] := col_source_file.AsString(tmp_Entry);
                  // if DNT_sql_col = 'DNT_LOCATION' then variant_Array[g] := col_source_location.asString(tmp_Entry);
                end;
              end;

              for g := 1 to ColCount do
                col_DF[g].AsString(NewEntry) := variant_Array[g];
              AddList2.Add(NewEntry);
            end;
          end;

          // Add to the ArtifactsDataStore
          if assigned(AddList2) and Progress.isRunning then
          begin
            ArtifactsDataStore.Add(AddList2);
            Progress.Log(RPad('Process List #' + IntToStr(Reference_Number) + SPACE + '(' + IntToStr(Arr_ValidatedFiles_TList[Reference_Number].Count) + '):', RPAD_VALUE) + Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type
              + RUNNING);
            Progress.Log(RPad('Total Artifacts:', RPAD_VALUE) + IntToStr(AddList2.Count));
            Progress.Log(StringOfChar('-', CHAR_LENGTH));
            AddList2.Clear;
          end;
        finally
          AddList2.free;
        end;
      end;
    end;
  end
  else

  if (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) then
  begin
    if assigned(anArtifactFolder) then
    begin
      if SetUpColumnforFolder(Reference_Number, anArtifactFolder, col_DF, ColCount, aItems) then
      begin
        setlength(variant_Array, ColCount + 1);
        ADDList := TList.Create;
        newEntryReader := TEntryReader.Create;
        try
          // Regex Setup -------------------------------------------------------

          FooterReader := TEntryReader.Create;
          FooterRegEx := TRegEx.Create;
          FooterRegEx.CaseSensitive := True;
          FooterRegEx.Progress := Progress;
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
          col_url := ArtifactsDataStore.DataFields.GetFieldByName('URL');
          col_query := ArtifactsDataStore.DataFields.GetFieldByName('Query');

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
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_TABLES) then
                ProcessAsESE;
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_CONTENT) then
                ProcessAsESECarveContent;
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_COOKIES) then
                ProcessAsESECarveCookies;
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_HISTORY_VISITED) then
                ProcessAsESECarveHistoryVisited;
              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_ESE_CARVE_HISTORY_REF_MARKER) then
                ProcessAsESECarveHistoryRefMarker;

              if (UpperCase(Item^.fi_Process_As) = PROCESS_AS_PLIST) then
              begin
                aPropertyTree := nil;
                try
                  if ProcessMetadataProperties(aArtifactEntry, aPropertyTree, newEntryReader) and assigned(aPropertyTree) then
                  begin
                    // Set Root Property (Level 0)
                    aRootProperty := aPropertyTree.RootProperty;
                    // Progress.Log(format('%-21s %-26s %-10s %-10s %-20s ',['Number of root child nodes:',IntToStr(aRootProperty.PropChildList.Count),'Bates:',IntToStr(aArtifactEntry.ID),aArtifactEntry.EntryName]));
                    if assigned(aRootProperty) and assigned(aRootProperty.PropChildList) and (aRootProperty.PropChildList.Count >= 1) then
                    begin
                      if not Progress.isRunning then
                        break;

                      // Chrome Bookmarks
                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_CHROME_BOOKMARKS') and RegexMatch(aArtifactEntry.FullPathName, 'Chrome', False) then // noslz
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      // Edge Bookmarks
                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_EDGE_BOOKMARKS') and RegexMatch(aArtifactEntry.FullPathName, 'Edge', False) then // noslz
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      // Opera Bookmarks
                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_OPERA_BOOKMARKS') and RegexMatch(aArtifactEntry.FullPathName, 'Opera', False) then // noslz
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_INTERNET_EXPLORER_4_9') and ((UpperCase(Item^.fi_Name_Program_Type) = 'URL (COOKIE)') or (UpperCase(Item^.fi_Name_Program_Type) = 'URL (DAILY)') or
                        (UpperCase(Item^.fi_Name_Program_Type) = 'URL (HISTORY)') or (UpperCase(Item^.fi_Name_Program_Type) = 'URL (NORMAL)')) then
                      begin
                        for x := 0 to aRootProperty.PropChildList.Count - 1 do
                        begin
                          if not Progress.isRunning then
                            break;
                          Node1 := TPropertyNode(aRootProperty.PropChildList.items[x]);
                          if assigned(Node1) then
                          begin
                            NodeList1 := Node1.PropChildList;
                            NumberOfNodes := NodeList1.Count;
                            // Cycle Through Child List - Level 2
                            for y := 0 to NumberOfNodes - 1 do
                            begin
                              Node2 := TPropertyNode(NodeList1.items[y]);
                              if assigned(Node2) then
                                for g := 1 to ColCount do
                                begin
                                  if not Progress.isRunning then
                                    break;
                                  // Add to the Array
                                  DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col));
                                  if UpperCase(Node2.PropName) = UpperCase(DNT_sql_col) then
                                    variant_Array[g] := Node2.PropDisplayValue;
                                end;
                            end;
                          end;
                          AddToModule;
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_BOOKMARKS_PLIST') then
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          NullTheArray;
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_COOKIES') then
                      begin
                        if aRootProperty.PropName = RS_DNT_SAFARI_COOKIE_DATA then
                        begin
                          for x := 0 to aRootProperty.PropChildList.Count - 1 do
                          begin
                            if not Progress.isRunning then
                              break;
                            Node1 := TPropertyNode(aRootProperty.PropChildList.items[x]);
                            // Get the 2nd Node
                            if assigned(Node1) and Progress.isRunning then
                            begin
                              NodeList1 := Node1.PropChildList;
                              if assigned(NodeList1) then
                              begin
                                for y := 0 to NodeList1.Count - 1 do
                                begin
                                  Node2 := TPropertyNode(NodeList1.items[y]);
                                  // Get the 3rd Node
                                  if assigned(Node2) and Progress.isRunning then
                                  begin
                                    NodeList2 := Node2.PropChildList;
                                    if assigned(NodeList2) then
                                    begin
                                      for z := 0 to NodeList2.Count - 1 do
                                      begin
                                        Node3 := TPropertyNode(NodeList2.items[z]);
                                        // Populate
                                        if assigned(Node3) and Progress.isRunning then
                                        begin
                                        if not Progress.isRunning then
                                        break;
                                        if assigned(Node3) then
                                        begin
                                        for g := 1 to ColCount do
                                        begin
                                        if not Progress.isRunning then
                                        break;
                                        DNT_sql_col := copy(aItems[g].sql_col, 5, Length(aItems[g].sql_col)); // Add to the Array
                                        if UpperCase(Node3.PropName) = UpperCase(DNT_sql_col) then
                                        variant_Array[g] := Node3.PropDisplayValue;
                                        end;
                                        end;
                                        end;
                                      end;
                                    end;
                                  end;
                                end;
                              end;
                            end;
                            AddToModule;
                          end;
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_DOWNLOADS_XML') then
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          NullTheArray;
                          nodefrog2(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_DOWNLOADS_PLIST') then
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          NullTheArray;
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_HISTORY_PLIST') then
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          NullTheArray;
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_RECENT_SEARCHES_PLIST') then
                      begin
                        TestNode1 := aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName); // noslz
                        if assigned(TestNode1) then
                        begin
                          Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                          if assigned(Node1) then
                          begin
                            NumberOfNodes := CountNodes(Node1);
                            nodefrog(Item^.fi_Process_ID, Node1, 0);
                          end;
                        end;
                      end; { Safari Recent Searches PList }

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_RECENT_SEARCHES_XML') then
                      begin
                        TestNode1 := aRootProperty.GetFirstNodeByName(RS_DNT_KEY);
                        TestNode2 := aRootProperty.GetFirstNodeByName('plist');
                        if assigned(TestNode2) and assigned(TestNode1) and (UpperCase(TestNode1.PropValue) = 'RECENTSEARCHES') then // This is the test for whether it is a Safari Recent Searches
                        begin
                          Temp_NodeList := TList.Create;
                          try
                            aRootProperty.FindNodesByName(RS_DNT_STRING, Temp_NodeList);
                            for x := 0 to Temp_NodeList.Count - 1 do
                            begin
                              Node1 := TPropertyNode(Temp_NodeList.items[x]);
                              if assigned(Node1) and (Node1.PropName = RS_DNT_STRING) then
                                for g := 1 to ColCount do
                                  variant_Array[g] := Node1.PropValue;
                              AddToModule;
                            end;
                          finally
                            if assigned(Temp_NodeList) then
                              FreeAndNil(Temp_NodeList);
                          end;
                        end;
                      end; { Safari Recent Searches XML }

                      if (UpperCase(Item^.fi_Process_ID) = 'DNT_SAFARI_TOPSITES_PLIST') then
                      begin
                        Node1 := TPropertyNode(aRootProperty.GetFirstNodeByName(Item^.fi_NodeByName));
                        if assigned(Node1) then
                        begin
                          NumberOfNodes := CountNodes(Node1);
                          NullTheArray;
                          nodefrog(Item^.fi_Process_ID, Node1, 0);
                        end;
                      end;
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
                    end;

                    // ========================================================== SL
                    // Table count check to eliminate SQL files without required tables
                    if (sql_tbl_count > 0) and (Length(Item^.fi_SQLTables_Required) > 0) then
                    begin
                      bl_log_missing_tables := False;
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
                            bl_log_missing_tables := True;
                            Progress.Log(RPad(HYPHEN + 'Bates:' + SPACE + IntToStr(aArtifactEntry.ID) + HYPHEN + aArtifactEntry.EntryName, RPAD_VALUE) + 'Ignored (Found ' + IntToStr(sqlselect_row.ColumnInt(0)) + ' of ' +
                              IntToStr(Length(Item^.fi_SQLTables_Required)) + ' required tables).');
                          end;
                        finally
                          sqlselect_row.free;
                        end;
                      except
                        Progress.Log(ATRY_EXCEPT_STR + 'An exception has occurred (usually means that the SQLite file is corrupt).');
                      end;
                    end;

                    // Log the missing required tables
                    if bl_log_missing_tables then
                    begin
                      for s := 0 to Length(Item^.fi_SQLTables_Required) - 1 do
                      begin
                        tempstr := 'select count(*) from sqlite_master where type = ''table'' and ((upper(name) = upper(''' + Item^.fi_SQLTables_Required[s] + ''')))';
                        try
                          sqlselect_row := TSQLite3Statement.Create(mydb, tempstr);
                          try
                            if (sqlselect_row.Step = SQLITE_ROW) then
                            begin
                              if sqlselect_row.ColumnInt(0) = 0 then
                                Progress.Log(RPad('', RPAD_VALUE) + HYPHEN + 'Missing table:' + SPACE + Item^.fi_SQLTables_Required[s]);
                            end;
                          finally
                            sqlselect_row.free;
                          end;
                        except
                          Progress.Log(ATRY_EXCEPT_STR + 'An exception has occurred (usually means that the SQLite file is corrupt).');
                        end;
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

                    if sql_tbl_count > 0 then
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

                          // Chrome SyncData - Specifics Blob Bytes
                          url_str := '';
                          title_str := '';
                          fav_str := '';
                          if (DNT_sql_col = 'Specifics') and (aItems[g].convert_as = 'SyncData') then
                          begin
                            variant_Array[g] := '';
                            test_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                            sSize := Length(test_bytes);

                            // Chrome SyncData Standard URL
                            if (Length(test_bytes) >= 10) and (test_bytes[0] = $C2) and (test_bytes[1] = $88) and (test_bytes[2] = $10) then
                            begin
                              startpos := 6;
                              if (test_bytes[3] >= $80) then
                              begin
                                Inc(startpos);
                                if (test_bytes[4] >= $01) then
                                  Inc(startpos);
                              end;
                              if (test_bytes[startpos - 2] = $0A) then
                              begin
                                Size := test_bytes[startpos - 1];
                                for b := 1 to Size do
                                  url_str := url_str + chr(test_bytes[startpos + b - 1]);

                                startpos := startpos + Size;
                                if (test_bytes[startpos] = $1A) then
                                begin
                                  startpos := startpos + 2;
                                  Size := test_bytes[startpos - 1];
                                  for b := 1 to Size do
                                    title_str := title_str + chr(test_bytes[startpos + b - 1]);
                                end;
                              end;
                              if url_str <> '' then
                                variant_Array[g] := url_str + ' ' + title_str;
                            end
                            else
                            begin // Chrome SyncData FavIcon
                              if (Length(test_bytes) >= 10) and (test_bytes[0] = $9A) and (test_bytes[1] = $F0) and (test_bytes[2] = $58) then
                              begin
                                startpos := 6;
                                if (test_bytes[3] >= $80) then
                                  Inc(startpos);
                                if (test_bytes[startpos - 2] = $0A) then
                                begin
                                  Size := test_bytes[startpos - 1];
                                  for b := 1 to Size do
                                    fav_str := fav_str + chr(test_bytes[startpos + b - 1]);
                                end;
                              end;
                              if fav_str <> '' then
                                variant_Array[g] := fav_str;
                            end;
                          end
                          else if aItems[g].read_as = ftString then
                            variant_Array[g] := ColumnValueByNameAsText(sqlselect, DNT_sql_col)
                          else if (aItems[g].read_as = ftinteger) and ((aItems[g].col_type = ftinteger) or (aItems[g].col_type = ftString)) then
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

                          // Convert Cache.db url_cache_response from string to date time
                          if (UpperCase(DNT_sql_col) = 'TIME_STAMP') and (aItems[g].read_as = ftString) and (col_DF[g].FieldType = ftDateTime) then
                            try
                              variant_Array[g] := VarToDateTime(variant_Array[g]);
                            except
                              MessageUser('Could not covert Cache.db url_cahce_response from string to datetime.'); // noslz
                            end;

                          if aItems[g].convert_as = 'DOWNLOADSTATE' then
                          begin
                            // Source: https://github.com/sans-dfir/sift-files/blob/master/scripts/hindsight.py
                            if variant_Array[g] = '0' then
                              variant_Array[g] := 'In Progress';
                            if variant_Array[g] = '1' then
                              variant_Array[g] := 'Complete';
                            if variant_Array[g] = '2' then
                              variant_Array[g] := 'Canceled';
                            if variant_Array[g] = '2' then
                              variant_Array[g] := 'Interrupted';
                          end;

                          if aItems[g].convert_as = 'OPENEDSTATE' then
                          begin
                            if variant_Array[g] = '1' then
                              variant_Array[g] := 'Yes';
                            if variant_Array[g] = '0' then
                              variant_Array[g] := 'No';
                          end;

                          if aItems[g].convert_as = 'INTERRUPTREASON' then
                          begin
                            // Source: https://github.com/sans-dfir/sift-files/blob/master/scripts/hindsight.py - April 2017
                            if variant_Array[g] = '0' then variant_Array[g] := '';
                            if variant_Array[g] = '1' then variant_Array[g] := 'File Error';
                            if variant_Array[g] = '2' then variant_Array[g] := 'Access Denied';
                            if variant_Array[g] = '3' then variant_Array[g] := 'Disk Full';
                            if variant_Array[g] = '5' then variant_Array[g] := 'Path Too Long';
                            if variant_Array[g] = '6' then variant_Array[g] := 'File Too Large';
                            if variant_Array[g] = '7' then variant_Array[g] := 'Virus';
                            if variant_Array[g] = '10' then variant_Array[g] := 'Temporary Problem';
                            if variant_Array[g] = '11' then variant_Array[g] := 'Blocked';
                            if variant_Array[g] = '12' then variant_Array[g] := 'Security Check Failed';
                            if variant_Array[g] = '13' then variant_Array[g] := 'Resume Error';
                            if variant_Array[g] = '20' then variant_Array[g] := 'Network Error';
                            if variant_Array[g] = '21' then variant_Array[g] := 'Operation Timed Out';
                            if variant_Array[g] = '22' then variant_Array[g] := 'Connection Lost';
                            if variant_Array[g] = '23' then variant_Array[g] := 'Server Down';
                            if variant_Array[g] = '30' then variant_Array[g] := 'Server Error';
                            if variant_Array[g] = '31' then variant_Array[g] := 'Range Request Error';
                            if variant_Array[g] = '32' then variant_Array[g] := 'Server Precondition Error';
                            if variant_Array[g] = '33' then variant_Array[g] := 'Unable to get file';
                            if variant_Array[g] = '40' then variant_Array[g] := 'Canceled';
                            if variant_Array[g] = '41' then variant_Array[g] := 'Browser Shutdown';
                            if variant_Array[g] = '50' then variant_Array[g] := 'Browser Crashed';
                          end;

                          if aItems[g].convert_as = 'TRANSITIONTYPE' then
                          // Run a conversion in this loop if required ---------------
                          begin
                            // Source: https://github.com/sans-dfir/sift-files/blob/master/scripts/hindsight.py - April 2017
                            //developer.chrome.com/extensions/history
                            if variant_Array[g] = '0' then variant_Array[g] := 'link';
                            if variant_Array[g] = '1' then variant_Array[g] := 'typed';
                            if variant_Array[g] = '2' then variant_Array[g] := 'auto bookmark';
                            if variant_Array[g] = '3' then variant_Array[g] := 'auto subframe';
                            if variant_Array[g] = '4' then variant_Array[g] := 'manual subframe';
                            if variant_Array[g] = '5' then variant_Array[g] := 'generated';
                            if variant_Array[g] = '6' then variant_Array[g] := 'start page';
                            if variant_Array[g] = '7' then variant_Array[g] := 'form submit';
                            if variant_Array[g] = '8' then variant_Array[g] := 'reload';
                            if variant_Array[g] = '9' then variant_Array[g] := 'keyword';
                            if variant_Array[g] = '10' then variant_Array[g] := 'keyword generated';
                          end;

                          if aItems[g].convert_as = 'DANGERTYPE' then
                          begin
                            if variant_Array[g] = '0' then variant_Array[g] := 'Not Dangerous';
                            if variant_Array[g] = '1' then variant_Array[g] := 'Dangerous';
                            if variant_Array[g] = '2' then variant_Array[g] := 'Dangerous URL';
                            if variant_Array[g] = '3' then variant_Array[g] := 'Dangerous Content';
                            if variant_Array[g] = '4' then variant_Array[g] := 'Content May Be Malicious';
                            if variant_Array[g] = '5' then variant_Array[g] := 'Uncommon Content';
                            if variant_Array[g] = '6' then variant_Array[g] := 'Dangerous But User Validated';
                            if variant_Array[g] = '7' then variant_Array[g] := 'Dangerous Host';
                            if variant_Array[g] = '8' then variant_Array[g] := 'Potentially Unwanted';
                          end;

                        end;
                        AddToModule;
                      end;
                      if assigned(sqlselect) then
                        sqlselect.free;
                    end;
                    Progress.Log(RPad(' ', RPAD_VALUE) + 'Bates:' + SPACE + IntToStr(aArtifactEntry.ID) + HYPHEN + aArtifactEntry.EntryName + SPACE + IntToStr(records_read_int));
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
                if HeaderReader.OpenData(aArtifactEntry) then // Open the entry to search
                begin
                  try
                    Progress.Initialize(aArtifactEntry.PhysicalSize, 'Carving ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ' + aArtifactEntry.EntryName);
                    h_startpos := 0;
                    curpos := 0;
                    HeaderReader.Position := 0;
                    HeaderRegex.Stream := HeaderReader;

                    // Opera
                    if Item^.fi_Name_Program = OPERA then
                    begin
                      gh_int := 0;
                      if HeaderReader.OpenData(aArtifactEntry) and FooterReader.OpenData(aArtifactEntry) then // Open the entry to search
                        try
                          Progress.Initialize(aArtifactEntry.PhysicalSize, 'Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ' + aArtifactEntry.EntryName);
                          h_startpos := 0;
                          HeaderReader.Position := 0;
                          HeaderRegex.Stream := HeaderReader;
                          FooterRegEx.Stream := FooterReader;
                          HeaderRegex.Find(h_offset, h_count); // Find the first match, h_offset returned is relative to start pos
                          while h_offset <> -1 do // h_offset returned as -1 means no hit
                          begin
                            FooterRegEx.Stream.Position := h_offset + h_count; // Advance so it does not match itself
                            end_pos := h_offset + h_count + 10000; // Limit looking for the footer to our max size
                            if end_pos >= HeaderRegex.Stream.Size then
                              end_pos := HeaderRegex.Stream.Size - 1; // Don't go past the end!
                            FooterRegEx.Stream.Size := end_pos;
                            FooterRegEx.Find(f_offset, f_count);
                            if (f_offset <> -1) and (f_offset + f_count >= 1) then // Found a footer and the size was at least our minimum
                            begin
                              CarvedEntry := TEntry.Create;
                              try
                                CarvedData := TByteInfo.Create; // ByteInfo is data described as a list of byte runs, usually just one run
                                CarvedData.ParentInfo := aArtifactEntry.DataInfo; // Point to the data of the file
                                CarvedData.RunLstAddPair(h_offset, f_offset + f_count); // Adds the block of data
                                CarvedEntry.DataInfo := CarvedData;
                                CarvedEntry.LogicalSize := CarvedData.Datasize;
                                CarvedEntry.PhysicalSize := CarvedData.Datasize;
                                CarvedEntryReader := TEntryReader.Create;
                                try
                                  if CarvedEntryReader.OpenData(CarvedEntry) then
                                  begin
                                    CarvedEntryReader.Position := 0;
                                    carved_str := '';
                                    carved_str := CarvedEntryReader.AsPrintableChar(CarvedEntryReader.Size);
                                    // Progress.Log(RPad(inttostr(gh_int) + SPACE + 'Carved Str:', 20) + carved_str);
                                    Inc(gh_int);
                                    if carved_str <> '' then
                                    begin
                                      variant_Array[1] := carved_str;
                                      AddToModule;
                                    end;
                                  end;
                                finally
                                  CarvedEntryReader.free;
                                end;
                              finally
                                CarvedEntry.free;
                              end;
                            end;
                            HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match for the current file
                          end;
                        except
                          Progress.Log(ATRY_EXCEPT_STR + 'Error processing ' + aArtifactEntry.EntryName);
                        end;
                    end
                    else
                      // Chrome
                      if (Item^.fi_Name_Program = CHROME) or (Item^.fi_Name_Program = CHROMIUM) then
                      begin
                        // Chrome Cache ----------------------------------------------
                        // Chrome Cache entry - http://forensicswiki.org/wiki/Chrome_Disk_Cache_Format
                        // Back from URL   // The first cache entry is at offset 8192. The cache entry (struct EntryStore) is 256 bytes in size and consists of:
                        // 96              // 0  4 - Hash - The hash of the key
                        // 92              // 4  4 - Next entry cache address - The next entry with the same hash or bucket
                        // 88              // 8  4 - Rankings node cache address
                        // 84              // 12 4 - Reuse count - Value that indicates how often this entry was (re-)used
                        // 80              // 16 4 - Refetch count - Value that indicates how often this entry was (re-)fetched (or downloaded)
                        // 76              // 20 4 - Cache entry state
                        // 72              // 24 8 - Creation datetime
                        // 64              // 32 4 - Key data size (key length)
                        // 60              // 36 4 - Long key data cache address. The value is 0 if no long key data is present
                        // 56              // 40 4 - Data Size Headers
                        // 52              // 44 4 - Data Size Payload
                        // 48              // 48 4 - Data Size
                        // 44              // 52 4 - Data Size
                        // 40              // 56 4 - Cache Address - HTTP Headers
                        // 36              // 60 4 - Cache Address -
                        // 32              // 64 4 - Cache Address
                        // 28              // 68 4 - Cache Address
                        // 24              // 72 4           Cache entry flags
                        // 20              // 76 4 x 4 = 16  Padding
                        // 4               // 92 4           Self hash. The hash of the first 92 bytes of the cache entry is this used as a checksum?
                        // 0               // 96 160         Key data - Contains an UTF-8 encoded string with an end-of-string character with the original URL
                        // --------------------------------------------------------------------------

                        Log_ChromeCache_bl := False;
                        Progress.Log(RPad('Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ', RPAD_VALUE) + aArtifactEntry.EntryName);
                        HeaderRegex.Find(h_offset, h_count);

                        // Find the first match, h_offset returned is relative to start pos
                        while h_offset <> -1 do // h_offset returned as -1 means no hit
                        begin
                          variant_Array[1] := null;
                          variant_Array[2] := null;
                          curpos := HeaderReader.Position;

                          if Log_ChromeCache_bl then
                            Progress.Log(RPad('Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ', RPAD_VALUE) + aArtifactEntry.EntryName);
                          if Log_ChromeCache_bl then
                            Progress.Log(RPad('Found http at offset: ', RPAD_VALUE) + IntToStr(h_offset));

                          if (h_startpos + h_offset - 72) < 0 then // 72 is DateTime + URL length
                          begin
                            Progress.Log('Error: Start position cannot be before file start.');
                            break;
                          end
                          else
                          begin
                            // Get the URL datetime ----------------------------------
                            HeaderReader.Position := (h_startpos + h_offset - 72);
                            url_dt := 0.0;
                            if HeaderReader.read(url_unixdt, 8) = 8 then
                              try
                                url_dt := int64ToDateTime(url_unixdt);
                                dt_str := DateTimeToStr(url_dt);
                              except
                                Progress.Log(ATRY_EXCEPT_STR);
                              end;
                            if Log_ChromeCache_bl then
                              Progress.Log(RPad('Date Time: ', RPAD_VALUE) + dt_str);

                            // Get DataSize ------------------------------------------
                            HeaderReader.Position := (h_startpos + h_offset - 52);
                            data_size := 0;
                            if Log_ChromeCache_bl then
                              Progress.Log(RPad('Data Size: ', RPAD_VALUE) + IntToStr(data_size));

                            // Get Reuse Count ---------------------------------------
                            HeaderReader.Position := (h_startpos + h_offset - 84);
                            reuse_count := 0;
                            if Log_ChromeCache_bl then
                              Progress.Log(RPad('Reuse Count: ', RPAD_VALUE) + IntToStr(reuse_count));

                            // Get Refetch Count ---------------------------------------
                            HeaderReader.Position := (h_startpos + h_offset - 80);
                            refetch_count := 0;
                            if Log_ChromeCache_bl then
                              Progress.Log(RPad('Refetch Count: ', RPAD_VALUE) + IntToStr(refetch_count));

                            // Get the url length -----------------------------------
                            HeaderReader.Position := (h_startpos + h_offset - 64);
                            // URL length is stored in 4 bytes 64 bytes before the URL
                            url_str := '';
                            if HeaderReader.read(url_len, 4) = 4 then
                            begin
                              if (url_len >= 10) and (url_len <= 1024) then
                              begin
                                if Log_ChromeCache_bl then
                                  Progress.Log(RPad('URL Length: ', RPAD_VALUE) + IntToStr(url_len));

                                HeaderReader.Position := (h_startpos + h_offset); // Go back to the start of the URL
                                setlength(ByteArray, url_len);

                                if HeaderReader.read(ByteArray[0], url_len) = url_len then
                                  for b := 0 to url_len - 1 do
                                    url_str := url_str + chr(ByteArray[b]);
                                if Log_ChromeCache_bl then
                                  Progress.Log(RPad('URL: ', RPAD_VALUE) + url_str);
                              end;
                            end
                            else
                              Progress.Log('Failed to read stream at position: ' + IntToStr(HeaderReader.Position));

                            // Add results to Array
                            if url_str <> '' then
                            begin
                              if (trunc(url_dt) >= 37622) and (trunc(url_dt) < 80000) then // 2003 to 2118 approx.
                              begin
                                variant_Array[1] := url_dt;
                                variant_Array[2] := url_str;
                                variant_Array[3] := h_offset;
                                variant_Array[4] := url_len;
                                variant_Array[5] := data_size;
                                variant_Array[6] := reuse_count;
                                variant_Array[7] := refetch_count;
                                AddToModule;
                              end;
                            end;

                          end;
                          HeaderReader.Position := curpos;
                          HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match
                          if Log_ChromeCache_bl then
                            Progress.Log(StringOfChar('-', CHAR_LENGTH));
                        end;
                      end;
                  except
                    MessageUser('Error processing ' + aArtifactEntry.EntryName);
                  end; { Regex Carve }
                end;
              end;
            end;
            if Log_ChromeCache_bl then
              Progress.Log(StringOfChar('-', CHAR_LENGTH));
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
              FindEntries_StringList.Add('**\*.binarycookies*');

              { *** Reduce the number of plists found *** }
              // FindEntries_StringList.Add('**\*.plist*');
              { *** } FindEntries_StringList.Add('**\*bookmarks.plist');
              { *** } FindEntries_StringList.Add('**\*downloads.plist');
              { *** } FindEntries_StringList.Add('**\*history.plist');
              { *** } FindEntries_StringList.Add('**\*mobilesafari.plist');
              { *** } FindEntries_StringList.Add('**\*suspendstate.plist');
              { *** } FindEntries_StringList.Add('**\*topsites.plist');

              FindEntries_StringList.Add('**\archived history*');
              FindEntries_StringList.Add('**\bookmarks*');
              FindEntries_StringList.Add('**\Brave.sqlite*');
              FindEntries_StringList.Add('**\browser.db*');
              FindEntries_StringList.Add('**\BrowserState.db*');
              FindEntries_StringList.Add('**\Cache.db*');
              FindEntries_StringList.Add('**\cookies*');
              FindEntries_StringList.Add('**\data_*');
              FindEntries_StringList.Add('**\favicons');
              FindEntries_StringList.Add('**\formhistory.sqlite*');
              FindEntries_StringList.Add('**\history*');
              FindEntries_StringList.Add('**\index.dat*');
              FindEntries_StringList.Add('**\login data*');
              FindEntries_StringList.Add('**\MobileSync\**\*'); // All iTunes folder
              FindEntries_StringList.Add('**\Opera.*\History*');
              FindEntries_StringList.Add('**\places.sqlite*');
              FindEntries_StringList.Add('**\shortcuts*');
              FindEntries_StringList.Add('**\suspendstate*');
              FindEntries_StringList.Add('**\SyncData.sqlite3*');
              FindEntries_StringList.Add('**\Tiles.sqlite*');
              FindEntries_StringList.Add('**\top sites*');
              FindEntries_StringList.Add('**\V01*.log*');
              FindEntries_StringList.Add('**\WebAssistDatabase');
              FindEntries_StringList.Add('**\web data*');
              FindEntries_StringList.Add('**\WebCacheV01*');

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

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVEAUTOFILL'));
            Ref_Num := 2;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVEBOOKMARKS'));
            Ref_Num := 3;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVECOOKIES'));
            Ref_Num := 4;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVEDOWNLOADS'));
            Ref_Num := 5;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVEFAVICONS'));
            Ref_Num := 6;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVEHISTORY'));
            Ref_Num := 7;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Brave_Browser.GetTable('BRAVETABHISTORY'));
            Ref_Num := 8;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEAUTOFILL'));
            Ref_Num := 9;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEAUTOFILLPROFILES'));
            Ref_Num := 10;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEBOOKMARKS'));
            Ref_Num := 11; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMECACHE'));
            Ref_Num := 12; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMECOOKIES'));
            Ref_Num := 13; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEDOWNLOADS'));
            Ref_Num := 14; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEFAVICONS'));
            Ref_Num := 15; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEHISTORY'));
            Ref_Num := 16; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMEKEYWORDSEARCHTERMS'));
            Ref_Num := 17; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMELOGINS'));
            Ref_Num := 18; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMESHORTCUTS'));
            Ref_Num := 19; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMESYNCDATA'));
            Ref_Num := 20; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMETOPSITES'));
            Ref_Num := 21; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chrome_Browser.GetTable('CHROMETOPSITES')); // Thumbnails table
            Ref_Num := 22; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMCACHE'));
            Ref_Num := 23; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMCOOKIES'));
            Ref_Num := 24; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMDOWNLOADS'));
            Ref_Num := 25; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMFAVICONS'));
            Ref_Num := 26; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMHISTORY'));
            Ref_Num := 27; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMKEYWORDSEARCHTERMS'));
            Ref_Num := 28; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMSHORTCUTS'));
            Ref_Num := 29; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMTOPSITES'));
            Ref_Num := 30; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Chromium_Browser.GetTable('CHROMIUMTOPSITES')); // Thumbnails table
            Ref_Num := 31; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, DuckDuckGo_Browser.GetTable('DUCKDUCKGOBOOKMARKS'));
            Ref_Num := 32; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Edge_Browser.GetTable('EDGEAUTOFILL'));
            Ref_Num := 33; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Edge_Browser.GetTable('EDGEBOOKMARKS'));
            Ref_Num := 34; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Edge_Browser.GetTable('EDGEFAVICONS'));
            Ref_Num := 35; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Edge_Browser.GetTable('EDGEHISTORY'));
            Ref_Num := 36; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Edge_Browser.GetTable('EDGEWEBASSISTANCEDATABASE'));
            Ref_Num := 37; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXHISTORYANDROID'));
            Ref_Num := 38; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXSEARCHHISTORYANDROID'));
            Ref_Num := 39; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXBOOKMARKS'));
            Ref_Num := 40; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXCACHE'));
            Ref_Num := 41; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXCOOKIES'));
            Ref_Num := 42; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXDOWNLOADS'));
            Ref_Num := 43; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXFAVICONS'));
            Ref_Num := 44; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXFORMHISTORY'));
            Ref_Num := 45; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXHISTORYVISITS'));
            Ref_Num := 46; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXPLACES_13')); //table count
            Ref_Num := 47; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Firefox_Browser.GetTable('FIREFOXPLACES_18')); //table count
            Ref_Num := 48; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Googlemaps.GetTable('GOOGLEMAPCOORDINATES'));
            Ref_Num := 49; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_49_URLCOOKIE'));
            Ref_Num := 50; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_49_URLDAILY'));
            Ref_Num := 51; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_49_URLHISTORY'));
            Ref_Num := 52; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_49_URLNORMAL'));
            Ref_Num := 53; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_1011_ESE_CONTENT_TABLES'));
            Ref_Num := 54; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_1011_ESE_COOKIES_TABLES'));
            Ref_Num := 55; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_DEPENDENCY_TABLES'));
            Ref_Num := 56; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_DOWNLOADS_TABLES'));
            Ref_Num := 57; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_HISTORY_TABLES'));
            Ref_Num := 58; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_CONTENT_CARVE'));
            Ref_Num := 59; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_CONTENT_CARVE'));
            Ref_Num := 60; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_COOKIES_CARVE'));
            Ref_Num := 61; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_HISTORY_CARVE_REF_MARKER'));
            Ref_Num := 62; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_HISTORY_CARVE_VISITED'));
            Ref_Num := 63; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IE_Browser.GetTable('IE_ESE_HISTORY_CARVE_VISITED'));
            Ref_Num := 64; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_AUTOFILL'));
            Ref_Num := 65; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_BOOKMARKS'));
            Ref_Num := 66; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_CACHE'));
            Ref_Num := 67; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_COOKIES'));
            Ref_Num := 68; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_DOWNLOADS'));
            Ref_Num := 69; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_HISTORY'));
            Ref_Num := 70; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_KEYWORD_SEARCH_TERMS'));
            Ref_Num := 71; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Opera_Browser.GetTable('OPERA_URLS'));
            Ref_Num := 72; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIBOOKMARKS'));
            Ref_Num := 73; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIBOOKMARKSPLIST'));
            Ref_Num := 74; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARICACHE'));
            Ref_Num := 75; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARICACHEDCONVERSATIONHEADERS'));
            Ref_Num := 76; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARICACHEDMESSAGES'));
            Ref_Num := 77; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARICOOKIES'));
            Ref_Num := 78; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIDOWNLOADSXML'));
            Ref_Num := 79; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIDOWNLOADSPLIST'));
            Ref_Num := 80; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIHISTORYPLIST'));
            Ref_Num := 81; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIHISTORYDB'));
            Ref_Num := 82; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIRECENTSEARCHESPLIST'));
            Ref_Num := 83; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARIRECENTSEARCHESXML'));
            Ref_Num := 84; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARITABS'));
            Ref_Num := 85; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Safari_Browser.GetTable('SAFARITOPSITESPLIST'));
            Ref_Num := 86; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, URL_Cache_Generic.GetTable('URL_CACHE_GENERIC'));
            //-----------
            Ref_Num := 87; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_BING'));
            Ref_Num := 88; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_CLOUD'));
            Ref_Num := 89; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_DATING'));
            Ref_Num := 90; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_FACEBOOK'));
            Ref_Num := 91; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_QUERY'));
            Ref_Num := 92; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_QUERY'));
            Ref_Num := 93; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_QUERY'));
            Ref_Num := 94; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Summary.GetTable('SUMMARY_SHIPPING'));

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
