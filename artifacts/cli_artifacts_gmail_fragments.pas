unit Carve_GMail_Fragments_From_Unallocated;

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
  RS_DoNotTranslate   in 'Common\RS_DoNotTranslate.pas';
  //-----

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

type
  TSQL_Table = record
    sql_col    : string;
    fex_col    : string;
    col_type   : TDataStorageFieldType;
    show       : boolean;
    read_as    : TDataStorageFieldType;
    convert_as : string;
  end;
  TSQL_Table_array = array[1..100] of TSQL_Table;

const
  ATRY_EXCEPT_STR           = 'TryExcept: '; //noslz
  BS                        = '\';
  BL_LOGGING                = False;
  BL_PROCEED_LOGGING        = False;
  CANCELED_BY_USER          = 'Canceled by user.';
  INI_HEADER                = 'UNALLOCATEDARTIFACTS';

  // JSON
  GMAIL_HDR_JSON           = '\[("([a-zA-Z0-9]){16}",){3}'; // Match for same and use HEADER_MATCH_ADVANCE
  GMAIL_FTR_JSON           = '\[("([a-zA-Z0-9]){16}",){3}'; // Match for same and use HEADER_MATCH_ADVANCE

  GMAIL_HDR_JSON_UNICODE   = '\[\x00("\x00([a-zA-Z0-9]\x00){16}"\x00,\x00){3}'; // Match for same and use HEADER_MATCH_ADVANCE
  GMAIL_FTR_JSON_UNICODE   = '\[\x00("\x00([a-zA-Z0-9]\x00){16}"\x00,\x00){3}'; // Match for same and use HEADER_MATCH_ADVANCE

  // TR
  GMAIL_HDR_TR             = '<TR tabindex=';
  GMAIL_FTR_TR             = '</SPAN></TD></TR>';

  GMAIL_HDR_TR_UNICODE     = '<\x00T\x00R\x00\x20\x00t\x00a\x00b\x00i\x00n\x00d\x00e\x00x\x00=';
  GMAIL_FTR_TR_UNICODE     = '<\x00\/\x00S\x00P\x00A\x00N\x00>\x00<\x00\/\x00T\x00D\x00><\x00\/\x00T\x00R\x00>';

  // Printchar
  GMAIL_HDR_TR_PRINTCHAR   = '<.T.R. .t.a.b.i.n.d.e.x.=';
  GMAIL_HDR_JSON_PRINTCHAR = '\[\.("(\.[a-zA-Z0-9]){16}.".,.){3}';

  FILE_SEARCH_REGEX =      'pagefile\.sys.*' + '|' +
                           'hiberfil\.sys.*' + '|' +
                           '{3808876b-c176-4e48-b7ae-04046e6cc752}' + '|' +
                           'unallocated' + '|' +
                           'swapfile';
                           //'Temporary Internet Files' + '|' +
                           //'INetCache' + '|' +
                           //'MicrosoftEdge\\Cache' + '|' +
                           //'Cache2' + '|' +
                           //'Google\\Chrome\\' + '|' +
                           //'Opera Stable\\cache\\' + '|' +
                           //'Safari\\Cache';

  CATEGORY_NAME             = 'Artifact Carve';
  CHAR_LENGTH               = 80;
  COLON                     = ':';
  COMMA                     = ',';
  CR                        = #13#10;
  DCR                       = #13#10 + #13#10;
  DUP_FILE                  = '';
  GFORMAT_STR               = '%-1s %-12s %-8s %-15s %-25s %-30s %-20s';
  HYPHEN                    = ' - ';
  HYPHEN_NS                 = '-';
  IOS                       = 'iOS'; //noslz
  MAX_CARVE_SIZE            = 1024 * 10;
  MIN_CARVE_SIZE            = 0;
  NUMBEROFSEARCHITEMS       = 1; //************************************************
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'Artifact Carve';
  RPAD_VALUE                = 55;
  RUNNING                   = '...';
  SCRIPT_NAME               = 'Carve GMail Fragments';
  SP                        = ' ';
  SPACE                     = ' ';
  STR_FILES_BY_PATH         = 'Files by path';
  TSWT                      = 'The script will terminate.';
  USE_FLAGS_BL              = False;
  VERBOSE                   = False;

    Array_Items_1: TSQL_Table_array = ( // GMail Fragments
    (sql_col: 'DNT_Date';                 fex_col: 'Date';                      read_as: ftString;       convert_as: '';            col_type: ftDateTime;     show: True),
    (sql_col: 'DNT_Email';                fex_col: 'Email';                     read_as: ftString;       convert_as: '';            col_type: ftString;       show: True),
    (sql_col: 'DNT_Sender';               fex_col: 'Sender';                    read_as: ftString;       convert_as: '';            col_type: ftString;       show: True),
    (sql_col: 'DNT_Subject';              fex_col: 'Subject';                   read_as: ftString;       convert_as: '';            col_type: ftString;       show: True),
    (sql_col: 'DNT_Message';              fex_col: 'Message';                   read_as: ftString;       convert_as: '';            col_type: ftString;       show: True),
    (sql_col: 'DNT_Attachments';          fex_col: 'Attachments';               read_as: ftString;       convert_as: '';            col_type: ftString;       show: True),
    (sql_col: 'DNT_Status';               fex_col: 'Status';                    read_as: ftString;       convert_as: '';            col_type: ftString;       show: True),
    (sql_col: 'DNT_Offset';               fex_col: 'Offset';                    read_as: ftString;       convert_as: '';            col_type: ftString;       show: True));

var
  Arr_ValidatedFiles_TList:       array[1..NUMBEROFSEARCHITEMS] of TList;
  ArtifactConnect_ProgramFolder:  array[1..NUMBEROFSEARCHITEMS] of TArtifactConnectEntry;
  FileItems:                      array[1..NUMBEROFSEARCHITEMS] of PSQL_FileSearch;

  anEntry:                        TEntry;
  ArtifactsDataStore:             TDataStore;
  ArtifactConnect_CategoryFolder: TArtifactEntry1;
  col_source_created:             TDataStoreField;
  col_source_file:                TDataStoreField;
  col_source_location:            TDataStoreField;
  col_source_modified:            TDataStoreField;
  col_source_path:                TDataStoreField;
  current_str:                    string;
  Display_str:                    string;
  FileSystemDataStore:            TDataStore;
  footer_regex:                   string;
  gbl_FreeSpace:                  boolean;
  gbl_Hiberfil:                   boolean;
  gbl_PageFile:                   boolean;
  gbl_ShadowCopy:                 boolean;
  gbl_SwapFile:                   boolean;
  gbl_Unallocated:                boolean;
  gStartup_ini_filename:          string;
  gtick_doprocess_i64:            uint64;
  gtick_doprocess_str:            string;
  gtick_foundlist_i64:            uint64;
  gtick_foundlist_str:            string;
  gWrite_Full_String_StringList:  TStringList;
  header_regex:                   string;
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
    ebx_CheckedSize: TGUIEditBox;
    ebx_PageFileSize: TGUIEditBox;
    ebx_HiberfilSize: TGUIEditBox;
    ebx_FreeSpaceSize: TGUIEditBox;
    ebx_ShadowCopySize: TGUIEditBox;
    ebx_SwapFileSize: TGUIEditBox;
    ebx_UnallocatedSize: TGUIEditBox;
    awidth: integer;
    AllItemsCount: integer;
    CheckedItemsCount: integer;
    btnCancel: TGUIButton;
    btnCalculate: TGUIButton;
    btnOK: TGUIButton;
    chb_Checkbox_FreeSpaceOnDisk: TGUICheckbox;
    chb_Checkbox_Hiberfil: TGUICheckbox;
    chb_Checkbox_Pagefile: TGUICheckbox;
    chb_Checkbox_ShadowCopy: TGUICheckbox;
    chb_Checkbox_SwapFile: TGUICheckbox;
    chb_Checkbox_UnallocatedClusters: TGUICheckbox;
    chbSelectAll: TGUICheckbox;
    current_pos: integer;
    increment: integer;
    indent1: integer;
    indent2: integer;
    pnlBottom: TGUIPanel;
    pnlTop: TGUIPanel;
    tpgMainTabs: TGUITabControl;
    tabOptions: TGUIControl;
    tabAbout: TGUIControl;
  public
    ModalResult: boolean;
    constructor Create;
    function ShowModal: boolean;
    procedure CancelClick(Sender: TGUIControl);
    procedure CalculateClick(Sender: TGUIControl);
    procedure SelectAllClick(Sender: TGUIControl);
    procedure OKClick(Sender: TGUIControl);
    procedure UpdateFileCounts;
  end;
{$IFEND}

implementation

{$IF DEFINED (ISFEXGUI)}

constructor TScriptForm.Create;
begin
  inherited Create;
  frmMain := NewForm(nil, SCRIPT_NAME);
  frmMain.Size(340 { width } , 380 { height } );
  pnlBottom := NewPanel(frmMain, esNone);
  pnlBottom.Size(frmMain.Width, 40);
  pnlBottom.Align(caBottom);
  btnOK := NewButton(pnlBottom, 'Search');
  btnOK.Position(pnlBottom.Width - 170, 6);
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
  pnlTop := NewPanel(frmMain, esRaised);
  pnlTop.Size(frmMain.Width, 400);
  pnlTop.Align(caClient);
  tpgMainTabs := NewTabEmpty(pnlTop, [], nil);
  tpgMainTabs.Color := clWhite;
  tpgMainTabs.Align(caClient);

  current_pos := 30;
  indent1 := 40;
  indent2 := 120;
  increment := 20;

  UpdateFileCounts;

  // TScriptForm - Insert the Options tab
  tabOptions := tpgMainTabs.TabInsert(1, 'Options', -1);
  tabAbout := tpgMainTabs.TabInsert(2, 'About', -1);
  NewLabel(tabAbout, SCRIPT_NAME).Position(10, 10).Size(180, 20).FontStyle(TFontStyle([fsBold]));
  NewWordWrapLabel(tabAbout, 'This script will carve GMail fragments from the files selected in the Options window.' + #10#13 + #10#13 +
    'Carve data is converted to text for display purposes. Original carve data should be validated on disk:' + #10#13 + #10#13 + '1. Select the source file in the File System module;' + #10#13 +
    '2. In Hex View, right click and select GoTo;' + #10#13 + '3. Enter File Offset to GoTo the start of the data.').Position(10, 40).Size(tabAbout.Width - 30, 320);

  current_pos := 30;
  indent1 := 40;
  increment := 19;
  awidth := 120;

  NewLabel(tabOptions, 'Carve GMail From:').Position(20, 20).Size(150, 20).FontStyle(TFontStyle([fsBold]));
  current_pos := current_pos + increment;

  chb_Checkbox_FreeSpaceOnDisk := NewCheckBox(tabOptions, 'Free Space on Disk');
  chb_Checkbox_FreeSpaceOnDisk.Position(indent1, current_pos).Size(awidth, 20);
  if gbl_FreeSpace then
    chb_Checkbox_FreeSpaceOnDisk.Checked := True;
  ebx_FreeSpaceSize := NewEditBox(tabOptions, []);
  ebx_FreeSpaceSize.Text := '';
  ebx_FreeSpaceSize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment;

  chb_Checkbox_Hiberfil := NewCheckBox(tabOptions, 'Hiberfil.sys');
  chb_Checkbox_Hiberfil.Position(indent1, current_pos).Size(awidth, 20);
  if gbl_Hiberfil then
    chb_Checkbox_Hiberfil.Checked := True;
  ebx_HiberfilSize := NewEditBox(tabOptions, []);
  ebx_HiberfilSize.Text := '';
  ebx_HiberfilSize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment;

  chb_Checkbox_Pagefile := NewCheckBox(tabOptions, 'Pagefile.sys');
  chb_Checkbox_Pagefile.Position(indent1, current_pos).Size(awidth, 20);
  if gbl_PageFile then
    chb_Checkbox_Pagefile.Checked := True;
  ebx_PageFileSize := NewEditBox(tabOptions, []);
  ebx_PageFileSize.Text := '';
  ebx_PageFileSize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment;

  chb_Checkbox_ShadowCopy := NewCheckBox(tabOptions, 'Shadow Copy files');
  chb_Checkbox_ShadowCopy.Position(indent1, current_pos).Size(awidth, 20);
  if gbl_ShadowCopy then
    chb_Checkbox_ShadowCopy.Checked := True;
  ebx_ShadowCopySize := NewEditBox(tabOptions, []);
  ebx_ShadowCopySize.Text := '';
  ebx_ShadowCopySize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment;

  chb_Checkbox_SwapFile := NewCheckBox(tabOptions, 'Swapfile');
  chb_Checkbox_SwapFile.Position(indent1, current_pos).Size(awidth, 20);
  if gbl_SwapFile then
    chb_Checkbox_SwapFile.Checked := True;
  ebx_SwapFileSize := NewEditBox(tabOptions, []);
  ebx_SwapFileSize.Text := '';
  ebx_SwapFileSize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment;

  chb_Checkbox_UnallocatedClusters := NewCheckBox(tabOptions, 'Unallocated clusters');
  chb_Checkbox_UnallocatedClusters.Position(indent1, current_pos).Size(awidth, 20);
  if gbl_Unallocated then
    chb_Checkbox_UnallocatedClusters.Checked := True;
  ebx_UnallocatedSize := NewEditBox(tabOptions, []);
  ebx_UnallocatedSize.Text := '';
  ebx_UnallocatedSize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment + increment;

  NewLabel(tabOptions, 'Total Selected:').Position(180, current_pos + 3).Size(120, 20).FontStyle(TFontStyle([]));
  current_pos := current_pos + increment + 5;
  ebx_CheckedSize := NewEditBox(tabOptions, []);
  ebx_CheckedSize.Text := '';
  ebx_CheckedSize.Position(180, current_pos).Size(75, 20);
  current_pos := current_pos + increment;

  chbSelectAll := NewCheckBox(tabOptions, 'Select All');
  chbSelectAll.Position(indent1, current_pos).Size(120, 20).Anchor(True, True, False, False);
  current_pos := current_pos + increment;
  chbSelectAll.Visible := False;
  chbSelectAll.OnClick := SelectAllClick;
  current_pos := current_pos + increment;

  // Calculate
  current_pos := 10;
  btnCalculate := NewButton(tabOptions, 'Calc. Size');
  btnCalculate.Position(180, current_pos);
  btnCalculate.Size(75, 25);
  btnCalculate.CancelBtn := True;
  btnCalculate.OnClick := CalculateClick;

  tpgMainTabs.CurIndex := 0;
  frmMain.CenterOnParent;
  frmMain.Invalidate;
end;

function TScriptForm.UpdateFileCounts;
var
  UpdateEntryList: TDataStore;
begin
  UpdateEntryList := GetDataStore(DATASTORE_FILESYSTEM);
  AllItemsCount := UpdateEntryList.Count;
  CheckedItemsCount := UpdateEntryList.CheckedCount;
  UpdateEntryList.free;
end;

procedure TScriptForm.OKClick(Sender: TGUIControl);
begin
  // Set variables for use in the main proc. Must do this before closing the main form.
  ModalResult := False;
  gbl_FreeSpace := chb_Checkbox_FreeSpaceOnDisk.Checked;
  gbl_Hiberfil := chb_Checkbox_Hiberfil.Checked;
  gbl_PageFile := chb_Checkbox_Pagefile.Checked;
  gbl_ShadowCopy := chb_Checkbox_ShadowCopy.Checked;
  gbl_SwapFile := chb_Checkbox_SwapFile.Checked;
  gbl_Unallocated := chb_Checkbox_UnallocatedClusters.Checked;

  if not gbl_FreeSpace and not gbl_Hiberfil and not gbl_PageFile and not gbl_ShadowCopy and not gbl_SwapFile and not gbl_Unallocated then
  begin
    MessageBox('Select an option.', SCRIPT_NAME, (MB_OK or MB_ICONINFORMATION or MB_SETFOREGROUND or MB_TOPMOST));
    Exit;
  end;

  ModalResult := True;
  frmMain.Close;
end;

procedure TScriptForm.CancelClick(Sender: TGUIControl);
begin
  ModalResult := False;
  Progress.DisplayMessageNow := CANCELED_BY_USER;
  frmMain.Close;
end;

procedure TScriptForm.SelectAllClick(Sender: TGUIControl);
var
  SelectDeselectAllchk: boolean;
begin
  SelectDeselectAllchk := chbSelectAll.Checked;
  chb_Checkbox_FreeSpaceOnDisk.Checked := SelectDeselectAllchk;
  chb_Checkbox_Hiberfil.Checked := SelectDeselectAllchk;
  chb_Checkbox_Pagefile.Checked := SelectDeselectAllchk;
  chb_Checkbox_ShadowCopy.Checked := SelectDeselectAllchk;
  chb_Checkbox_SwapFile.Checked := SelectDeselectAllchk;
  chb_Checkbox_UnallocatedClusters.Checked := SelectDeselectAllchk;
end;

procedure TScriptForm.CalculateClick(Sender: TGUIControl);
var
  asize_dbl: double;
  calcDataStore: TDataStore;
  dbl_FreeSpaceSize: double;
  dbl_HiberfilSize: double;
  dbl_PageFileSize: double;
  dbl_ShadowCopySize: double;
  dbl_SwapFileSize: double;
  dbl_TotalCheckedSize: double;
  dbl_UnallocatedSize: double;
  FoundList: TList;

begin
  calcDataStore := GetDataStore(DATASTORE_FILESYSTEM);
  FoundList := TList.Create;

  asize_dbl := 0;
  try
    dbl_FreeSpaceSize := Find_Entries_By_Path_Return_Size(calcDataStore, '**\Free Space on Disk', FoundList); // noslz
    ebx_FreeSpaceSize.Text := FormatFloat('0.00', dbl_FreeSpaceSize) + ' GB';

    dbl_HiberfilSize := Find_Entries_By_Path_Return_Size(calcDataStore, '**\hiberfil.sys', FoundList); // noslz
    ebx_HiberfilSize.Text := FormatFloat('0.00', dbl_HiberfilSize) + ' GB';

    dbl_PageFileSize := Find_Entries_By_Path_Return_Size(calcDataStore, '**\pagefile.sys', FoundList); // noslz
    ebx_PageFileSize.Text := FormatFloat('0.00', dbl_PageFileSize) + ' GB';

    dbl_ShadowCopySize := Find_Entries_By_Path_Return_Size(calcDataStore, '**\*3808876b-c176-4e48-b7ae-04046e6cc752*', FoundList); // noslz
    ebx_ShadowCopySize.Text := FormatFloat('0.00', dbl_ShadowCopySize) + ' GB';

    dbl_SwapFileSize := Find_Entries_By_Path_Return_Size(calcDataStore, '**\swapfile*', FoundList); // noslz
    ebx_SwapFileSize.Text := FormatFloat('0.00', dbl_SwapFileSize) + ' GB';

    dbl_UnallocatedSize := Find_Entries_By_Path_Return_Size(calcDataStore, '**\unallocated*', FoundList); // noslz
    ebx_UnallocatedSize.Text := FormatFloat('0.00', dbl_UnallocatedSize) + ' GB';

    dbl_SwapFileSize := 0;
    if chb_Checkbox_FreeSpaceOnDisk.Checked then
      dbl_TotalCheckedSize := dbl_TotalCheckedSize + dbl_FreeSpaceSize;
    if chb_Checkbox_Hiberfil.Checked then
      dbl_TotalCheckedSize := dbl_TotalCheckedSize + dbl_HiberfilSize;
    if chb_Checkbox_Pagefile.Checked then
      dbl_TotalCheckedSize := dbl_TotalCheckedSize + dbl_PageFileSize;
    if chb_Checkbox_ShadowCopy.Checked then
      dbl_TotalCheckedSize := dbl_TotalCheckedSize + dbl_ShadowCopySize;
    if chb_Checkbox_SwapFile.Checked then
      dbl_TotalCheckedSize := dbl_TotalCheckedSize + dbl_SwapFileSize;
    if chb_Checkbox_UnallocatedClusters.Checked then
      dbl_TotalCheckedSize := dbl_TotalCheckedSize + dbl_UnallocatedSize;
    ebx_CheckedSize.Text := FormatFloat('0.00', dbl_TotalCheckedSize) + ' GB';

  finally
    FoundList.free;
    calcDataStore.free;
  end;
end;

function TScriptForm.ShowModal: boolean;
begin
  Execute(frmMain);
  Result := ModalResult;
end;

{$IFEND}

procedure LoadFileItems;
const
  lFileItems: array [1 .. NUMBEROFSEARCHITEMS] of TSQL_FileSearch = (

    ( // ~1~ GMAIL Fragments
    fi_Name_Program: 'GMail'; fi_Name_Program_Type: 'Fragments'; fi_Process_ID: 'DNT_GMAIL-FRAGMENTS'; fi_Icon_Category: ICON_OTHER; fi_Icon_Program: ICON_GMAIL; fi_Icon_OS: ICON_WINDOWS; fi_Regex_Search: FILE_SEARCH_REGEX));

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

procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
var
  NowProceed_bl: boolean;
  i: integer;
  File_Added_bl: boolean;
  Item: PSQL_FileSearch;
begin
  File_Added_bl := False;
  if anEntry.isSystem and ((POS('$I30', anEntry.EntryName) > 0) or (POS('$90', anEntry.EntryName) > 0)) then
  begin
    NowProceed_bl := False;
    Exit;
  end;

  for i := 1 to NUMBEROFSEARCHITEMS do
  begin
    if not Progress.isRunning then
      break;
    NowProceed_bl := False;
    Item := FileItems[i];

    // -------------------------------------------------------------------------------
    // Special validation (these files are still sent here via the Regex match)
    // -------------------------------------------------------------------------------
    if not NowProceed_bl then
      if RegexMatch(anEntry.EntryName, 'swapfile', False) then
        NowProceed_bl := True; // noslz
    if not NowProceed_bl then
      if RegexMatch(anEntry.EntryName, 'pagefile\.sys', False) then
        NowProceed_bl := True; // noslz
    if not NowProceed_bl then
      if RegexMatch(anEntry.EntryName, 'hiberfil\.sys', False) then
        NowProceed_bl := True; // noslz
    if not NowProceed_bl then
      if RegexMatch(anEntry.EntryName, 'unallocated', False) then
        NowProceed_bl := True; // noslz
    if not NowProceed_bl then
      if RegexMatch(anEntry.EntryName, 'Free Space on Disk', False) then
        NowProceed_bl := True; // noslz
    if not NowProceed_bl then
      if anEntry.isFreeSpace then
        NowProceed_bl := True; // noslz
    if (anEntry.Parent.EntryName = 'System Volume Information') and (POS(UpperCase('}{3808876b-c176-4e48-b7ae-04046e6cc752}'), UpperCase(anEntry.FullPathName)) > 0) then
      NowProceed_bl := True; // noslz

    if NowProceed_bl then
    begin
      Progress.Log(RPad('B: Added to Validated List:', RPAD_VALUE) + IntToStr(i) + ' (' + Item^.fi_Name_Program + ')');
      Arr_ValidatedFiles_TList[i].Add(anEntry);
      File_Added_bl := True;
      if USE_FLAGS_BL then
        anEntry.Flags := anEntry.Flags + [Flag5]; // Green Flag
    end;
  end;
  if (File_Added_bl = False) then
    Progress.Log('File ignored.');
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
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

function Find_Entries_By_Path_Return_Size(aDataStore: TDataStore; astr: string; FoundList: TList): double;
var
  s: integer;
  fEntry: TEntry;
  asize: double;
begin
  Result := 0;
  asize := 0;
  if assigned(aDataStore) and (aDataStore.Count > 1) then
  begin
    FoundList.Clear;
    aDataStore.FindEntriesByPath(nil, astr, FoundList);
    for s := 0 to FoundList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;
      fEntry := TEntry(FoundList[s]);
      asize := asize + fEntry.LogicalSize;
    end;
    asize := asize / 1024 / 1024 / 1024;
    Result := asize;
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

// -----------------------------------------------------------------------------
// Function:  Parse GMail Data
// -----------------------------------------------------------------------------
function ParseGmailDate(s: string): TDateTime;
const
  mth: array [1 .. 12] of string = ('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'); // noslz
var
  Re: TDIPerlRegEx;
  match_str: string;
  i, m, d, y, hr, mi: integer;
begin
  Result := 0;
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess, coUnGreedy];
  Re.MatchPattern := '(?:Sun|Mon|Tue|Wed|Thu|Fri|Sat), (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d+), (\d\d\d\d) at (\d+):(\d\d) ([A|P]M)'; // noslz
  Re.SetSubjectStr(s);
  if Re.Match(0) >= 0 then
  begin
    match_str := Re.MatchedStrPtr;
    if (match_str <> '') and (Re.MatchedStrLength > 0) and (Re.SubStrCount = 7) then
    begin
      m := 0;
      for i := low(mth) to high(mth) do
        if mth[i] = UpperCase(Re.SubStr(1)) then
          m := i;
      d := StrToInt(Re.SubStr(2));
      y := StrToInt(Re.SubStr(3));
      hr := StrToInt(Re.SubStr(4));
      mi := StrToInt(Re.SubStr(5));
      if hr = 12 then
        hr := hr - 12;
      if UpperCase(Re.SubStr(6)) = 'PM' then
        hr := hr + 12;
      try
        Result := EncodeDateTime(y, m, d, hr, mi, 0, 0);
      except
        Result := 0;
      end;
    end;
  end;
  FreeAndNil(Re);
end;

procedure ParseGmail(s, str_offset: string; out variant_Array: TVarArray; Entry: TEntry);
var
  Re: TDIPerlRegEx;
  temp_str: string;
  g: integer;
  subject_message_str: string;
  dt: TDateTime;
begin
  setlength(variant_Array, LengthArrayTABLE(Array_Items_1) + 1);

  // Null the Array
  for g := 1 to LengthArrayTABLE(Array_Items_1) do
    variant_Array[g] := null;

  // Clean Print Char
  if RegexMatch(s, GMAIL_HDR_TR_PRINTCHAR, False) or RegexMatch(s, GMAIL_HDR_JSON_PRINTCHAR, False) then
  begin
    s := StringReplace(s, '.', '', [rfReplaceAll]);
  end;

  // Clean Unicode
  s := StringReplace(s, '\u0026#39;', '''', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '&gt;', '>', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '&laquo;', '«', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '&lt;', '<', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '&raquo;', '»', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '\u003b', ';', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '\u003c', '<', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '\u003d', '=', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '\u003e', '>', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '</b>', '', [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '<b>', '', [rfReplaceAll, rfIgnoreCase]);

  // Setup the PerRegex Searches
  Re := TDIPerlRegEx.Create(nil);
  Re.CompileOptions := [coCaseLess];
  Re.SetSubjectStr(s);

  // Gmail Date ----------------------------------------------------------------
  dt := ParseGmailDate(s);
  variant_Array[1] := dt;
  // variant_Array[1] := (ParseGmailDate(s));

  // Gmail Email ---------------------------------------------------------------
  Re.MatchPattern := '(?<=email=\\")(.*?)(?=\\")';
  if Re.Match(0) >= 0 then
    variant_Array[2] := Re.matchedstr;

  // Gmail Name ----------------------------------------------------------------
  Re.MatchPattern := '(?<=name=\\")(.*?)(?=\\")';
  if Re.Match(0) >= 0 then
    variant_Array[3] := Re.matchedstr;

  // Gmail Attachments ---------------------------------------------------------
  Re.MatchPattern := '(?<=<IMG title=\\")(.*?)(?=\\")';
  if Re.Match(0) >= 0 then
    variant_Array[6] := Re.matchedstr;

  // Gmail Message Status ------------------------------------------------------
  Re.MatchPattern := '>unread, ';
  if Re.Match(0) >= 0 then
    variant_Array[7] := 'unread'
  else
    variant_Array[7] := 'read';

  // Gmail Offset --------------------------------------------------------------
  variant_Array[8] := str_offset;

  // Gmail TR - Subject --------------------------------------------------------
  Re.MatchPattern := '(?<=<DIV class=\\"..\\"><SPAN id=\\":..\\">)(.*?)(?=<\/SPAN>)';
  if Re.Match(0) >= 0 then
  begin
    temp_str := '';
    temp_str := Re.matchedstr;
    temp_str := StringReplace(temp_str, '<B>', '', [rfReplaceAll, rfIgnoreCase]);
    temp_str := StringReplace(temp_str, '</B>', '', [rfReplaceAll, rfIgnoreCase]);
    variant_Array[4] := temp_str;
  end;

  // Gmail TR - MESSAGE --------------------------------------------------------
  Re.MatchPattern := '(?<=<SPAN class=\\"..\\">&nbsp;-&nbsp;)(.*?)(?=<\/SPAN><\/DIV>)';
  if Re.Match(0) >= 0 then
    variant_Array[5] := Re.matchedstr;

  // Gmail JSON - Subject ------------------------------------------------------
  Re.MatchPattern := '(?<=nbsp;",")(.*?)(?=",")'; // This is Subject
  if Re.Match(0) >= 0 then
    variant_Array[4] := Re.matchedstr;

  // Gmail JSON - Subject + Message --------------------------------------------
  subject_message_str := '';
  Re.MatchPattern := '(?<=nbsp;",")(.*?)(?=",(0|1),")'; // This is Subject + Message
  if Re.Match(0) >= 0 then
    subject_message_str := Re.matchedstr;

  // Gmail JSON MESSAGE ONLY ---------------------------------------------------
  subject_message_str := subject_message_str + '--END--';
  Re.CompileOptions := [coCaseLess];
  Re.SetSubjectStr(subject_message_str);
  Re.MatchPattern := '(?<=",")(.*?)(?=--END--)'; // This is Subject + Message
  if Re.Match(0) >= 0 then
    variant_Array[5] := Re.matchedstr;
  FreeAndNil(Re);
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
    col_source_location := ArtifactsDataStore.DataFields.GetFieldByName('Location');
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
        anArtifactFolder.AddField(col_source_location);
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

procedure UpdateCheckbox(line_list_str: string);
begin
  if POS('FSOD', line_list_str) > 0 then
    gbl_FreeSpace := True;
  if POS('HBFL', line_list_str) > 0 then
    gbl_Hiberfil := True;
  if POS('PGFL', line_list_str) > 0 then
    gbl_PageFile := True;
  if POS('SHAD', line_list_str) > 0 then
    gbl_ShadowCopy := True;
  if POS('SWFL', line_list_str) > 0 then
    gbl_SwapFile := True;
  if POS('UCLU', line_list_str) > 0 then
    gbl_Unallocated := True;
end;

procedure LogCheckBox(AString: string);
begin
  Progress.Log(RPad(AString, RPAD_VALUE) + gStartup_ini_filename);
  Progress.Log(RPad('Free Space:', RPAD_VALUE) + booltostr(gbl_FreeSpace, True));
  Progress.Log(RPad('Hiberfil:', RPAD_VALUE) + booltostr(gbl_Hiberfil, True));
  Progress.Log(RPad('Pagefile:', RPAD_VALUE) + booltostr(gbl_PageFile, True));
  Progress.Log(RPad('Shadow Copy:', RPAD_VALUE) + booltostr(gbl_ShadowCopy, True));
  Progress.Log(RPad('Swap File:', RPAD_VALUE) + booltostr(gbl_SwapFile, True));
  Progress.Log(RPad('Unallocated:', RPAD_VALUE) + booltostr(gbl_Unallocated, True));
  Progress.Log(StringOfChar('-', CHAR_LENGTH));
end;

function VariantToArrayBytes(avariant: variant): TBytes;
var
  iSize, jj: integer;
begin
  setlength(Result, 0);
  if VarIsNull(avariant) or VarIsEmpty(avariant) or not VarIsArray(avariant) then
    Exit;
  iSize := VarArrayHighBound(avariant, 1);
  if iSize > 0 then
  begin
    setlength(Result, iSize);
    for jj := 0 to iSize - 1 do
    begin
      if not Progress.isRunning then
        break;
      Result[jj] := VarArrayGet(avariant, [jj]);
    end;
  end;
end;

procedure DoProcess(anArtifactFolder: TArtifactConnectEntry; Reference_Number: integer; aItems: TSQL_Table_array);
var
  aArtifactEntry: TEntry;
  aArtifactEntryParent: TEntry;
  ADDList: TList;
  carved_str: string;
  CarvedData: TByteInfo;
  CarvedEntry: TEntry;
  col_DF: TDataStoreFieldArray;
  ColCount: integer;
  Display_Name_str: string;
  end_pos: int64;
  FooterProgress: TPAC;
  h_startpos, h_offset, h_count, f_offset, f_count: int64;
  HeaderReader, FooterReader, CarvedEntryReader: TEntryReader;
  HeaderRegex, FooterRegEx: TRegEx;
  i: integer;
  Item: PSQL_FileSearch;
  newEntryReader: TEntryReader;
  offset_str: string;
  TotalFiles: int64;
  variant_Array: array of variant;

  procedure NullTheArray;
  var
    n: integer;
  begin
    for n := 1 to ColCount do
      variant_Array[n] := null;
  end;

  function CarveURL(aReader: TEntryReader; carve_position: int64): variant;
  var
    printchars: string;
  begin
    printchars := '';
    aReader.Position := carve_position;
    printchars := aReader.AsNullWideString; // Stops printing when it reaches a null char
    Result := printchars;
  end;

  procedure AddToModule(process_id: integer; addArtifactEntry: TEntry; anArtifactFolder: TArtifactConnectEntry; aColCount: integer);
  var
    NEntry: TArtifactItem;
    IsAllEmpty, IsAllNull: boolean;
    g: integer;
  begin
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
      for g := 1 to aColCount do
      begin
        if not Progress.isRunning then
          break;
        if (not VarIsNull(variant_Array[g])) and (not VarIsEmpty(variant_Array[g])) then
          try
            if (col_DF[g].FieldType = ftDateTime) then
              col_DF[g].AsDateTime[NEntry] := variant_Array[g];
            try
              if (col_DF[g].FieldType = ftInteger) then
                col_DF[g].AsInteger[NEntry] := variant_Array[g]
            except
              Progress.Log('ftInteger fail')
            end;
            try
              if (col_DF[g].FieldType = ftLargeInt) then
                col_DF[g].AsInt64[NEntry] := variant_Array[g]
            except
              Progress.Log('ftLargeInt fail')
            end;
            try
              if (col_DF[g].FieldType = ftString) and VarIsStr(variant_Array[g]) and (variant_Array[g] <> '') then
                col_DF[g].AsString(NEntry) := variant_Array[g]
            except
              Progress.Log('ftString fail')
            end;
            try
              if (col_DF[g].FieldType = ftBytes) then
                col_DF[g].AsBytes[NEntry] := VariantToArrayBytes(variant_Array[g])
            except
              Progress.Log('ftBytes fail')
            end;
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

// Start of Do Process ---------------------------------------------------------
begin
  try
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
            Progress.DisplayMessageNow := 'Process' + SPACE + PROGRAM_NAME + ' - ' + Item^.fi_Name_Program_Type + RUNNING;
            Progress.CurrentPosition := 1;

            // Regex Setup -------------------------------------------------------
            HeaderRegex := TRegEx.Create;
            HeaderRegex.Progress := Progress;
            FooterRegEx := TRegEx.Create;
            FooterRegEx.CaseSensitive := True;
            FooterProgress := TPAC.Create;
            FooterProgress.Start;
            FooterRegEx.Progress := FooterProgress;
            HeaderReader := TEntryReader.Create;
            FooterReader := TEntryReader.Create;
            CarvedEntryReader := TEntryReader.Create;
            HeaderRegex.CaseSensitive := True; // Should be True for most binary regex terms. Must come before setting search term.

            // ====================================================================
            // Regex Search Terms
            // ====================================================================
            HeaderRegex.SearchTerm := header_regex;
            FooterRegEx.SearchTerm := footer_regex;
            Progress.Log(RPad('Regex Header SearchTerm:', RPAD_VALUE) + HeaderRegex.SearchTerm);
            Progress.Log(RPad('Regex Footer SearchTerm:', RPAD_VALUE) + FooterRegEx.SearchTerm);
            Progress.Log(StringOfChar('-', CHAR_LENGTH));
            // ====================================================================

            if HeaderRegex.LastError <> 0 then
            begin
              Progress.Log(RPad('!!!!!!! HEADER REGEX ERROR !!!!!!!:', RPAD_VALUE) + IntToStr(HeaderRegex.LastError));
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

              // Counters
              temp_process_counter := temp_process_counter + 1;
              Display_Name_str := GetFullName(Item);
              Progress.DisplayMessageNow := 'Processing' + SPACE + Display_Name_str + ' (' + IntToStr(temp_process_counter) + ' of ' + IntToStr(Arr_ValidatedFiles_TList[Reference_Number].Count) + ')' + RUNNING;
              aArtifactEntry := TEntry(Arr_ValidatedFiles_TList[Reference_Number].items[i]);
              if assigned(aArtifactEntry.Parent) then
                aArtifactEntryParent := TEntry(aArtifactEntry.Parent);
              if assigned(aArtifactEntry) and newEntryReader.opendata(aArtifactEntry) and (newEntryReader.Size > 0) and Progress.isRunning then
              begin
                if USE_FLAGS_BL then
                  aArtifactEntry.Flags := aArtifactEntry.Flags + [Flag8]; // Gray Flag = Process Routine

                // ==============================================================
                // PROCESS HERE
                // ==============================================================
                Progress.Log(RPad('Processing File:', RPAD_VALUE) + IntToStr(i) + ' of ' + IntToStr(Arr_ValidatedFiles_TList[1].Count));
                Progress.Log(RPad('Filename:', RPAD_VALUE) + Format('%s (%1.2n GB', [aArtifactEntry.EntryName, aArtifactEntry.LogicalSize / (1024 * 1024 * 1024)]) + ', Bates' + SPACE + IntToStr(aArtifactEntry.ID) + ')');

                if (UpperCase(Item^.fi_Process_ID) = 'DNT_GMAIL-FRAGMENTS') then
                begin
                  if HeaderReader.opendata(aArtifactEntry) and FooterReader.opendata(aArtifactEntry) then // Open the entry to search
                    try
                      Progress.Initialize(aArtifactEntry.PhysicalSize, 'Searching ' + IntToStr(i + 1) + ' of ' + IntToStr(TotalFiles) + ' files: ' + aArtifactEntry.EntryName);
                      h_startpos := 0;
                      HeaderReader.Position := 0;
                      HeaderRegex.Stream := HeaderReader;
                      FooterRegEx.Stream := FooterReader;
                      HeaderRegex.Find(h_offset, h_count); // Find the first match, h_offset returned is relative to start pos
                      while h_offset <> -1 do // h_offset returned as -1 means no hit
                      begin
                        // Progress.Log(RPad('Start of Header:', rpad_value) + IntToStr(h_offset));         // Header found, now look for a footer
                        // Progress.Log(RPad('Header Length:', rpad_value) + IntToStr(h_count));
                        FooterRegEx.Stream.Position := h_offset + h_count; // Advance so it does not match itself
                        end_pos := h_offset + h_count + MAX_CARVE_SIZE; // Limit looking for the footer to our max size
                        if end_pos >= HeaderRegex.Stream.Size then
                          end_pos := HeaderRegex.Stream.Size - 1; // Don't go past the end!
                        FooterRegEx.Stream.Size := end_pos;
                        FooterRegEx.Find(f_offset, f_count);
                        if (f_offset <> -1) and (f_offset + f_count >= MIN_CARVE_SIZE) then // Found a footer and the size was at least our minimum
                        begin
                          // Progress.Log('Footer found'); // Footer found - Create an Entry for the data found
                          // MessageLog(RPad('Footer Found at FileOffset:', rpad_value) + IntToStr(f_offset + f_count)); // Footer found
                          // MessageLog('---');
                          CarvedEntry := TEntry.Create;
                          offset_str := IntToStr(h_offset);
                          CarvedData := TByteInfo.Create; // ByteInfo is data described as a list of byte runs, usually just one run
                          CarvedData.ParentInfo := aArtifactEntry.DataInfo; // Point to the data of the file
                          CarvedData.RunLstAddPair(h_offset, f_offset + f_count); // Adds the block of data
                          CarvedEntry.DataInfo := CarvedData;
                          CarvedEntry.LogicalSize := CarvedData.Datasize;
                          CarvedEntry.PhysicalSize := CarvedData.Datasize;
                          if CarvedEntryReader.opendata(CarvedEntry) then
                          begin
                            CarvedEntryReader.Position := 0;
                            carved_str := '';
                            carved_str := CarvedEntryReader.AsPrintableChar(CarvedEntryReader.Size);
                            // Progress.Log('Carved String: ' + carved_str);
                            // Progress.Log(Stringofchar('-', CHAR_LENGTH));
                            if RegexMatch(carved_str, GMAIL_HDR_TR + '|' + GMAIL_HDR_TR_UNICODE + '|' + GMAIL_HDR_TR_PRINTCHAR + '|' + GMAIL_HDR_JSON + '|' + GMAIL_HDR_JSON_UNICODE + '|' + GMAIL_HDR_JSON_PRINTCHAR, False) then
                              ParseGmail(carved_str, offset_str, variant_Array, aArtifactEntry);
                            AddToModule(Ref_Num, aArtifactEntry, ArtifactConnect_ProgramFolder[Ref_Num], ColCount);
                          end;
                          CarvedEntryReader.CloseData;
                          CarvedEntry.free;
                        end;
                        HeaderRegex.FindNext(h_offset, h_count); // Find each subsequent header match for the current file
                      end;
                    except
                      Progress.Log(ATRY_EXCEPT_STR + 'Error processing ' + aArtifactEntry.EntryName);
                    end;

                  // Add to the ArtifactsDataStore
                  if assigned(ADDList) and Progress.isRunning then
                  begin
                    ArtifactsDataStore.Add(ADDList);
                    Progress.Log(RPad('Total Artifacts:', RPAD_VALUE) + IntToStr(ADDList.Count) + SPACE + aArtifactEntry.EntryName);
                    // Export L01 files where artifacts are found (controlled by Artifact_Utils.pas)
                    if (Arr_ValidatedFiles_TList[Reference_Number].Count > 0) and (ADDList.Count > 0) then
                      ExportToL01(Arr_ValidatedFiles_TList[Reference_Number], Item^.fi_Name_Program + SPACE + Item^.fi_Name_Program_Type);
                    ADDList.Clear;
                  end;
                  Progress.Log(StringOfChar('-', CHAR_LENGTH));

                end;
              end;
            end; { validated files loop }
          finally
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
    end
  except
    Progress.Log(ATRY_EXCEPT_STR + 'Exception in DoProcess');
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
  i,j: integer;
  Item: PSQL_FileSearch;
  iTunes_Domain_str: string;
  iTunes_Name_str: string;
  LineList: TStringList;
  ResultInt: integer;
  Startup_ini_StringList: TStringList;
  temp_str: string;

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
  footer_regex := GMAIL_FTR_TR + '|' + GMAIL_FTR_TR_UNICODE + '|' + GMAIL_FTR_JSON + '|' + GMAIL_FTR_JSON_UNICODE;
  header_regex := GMAIL_HDR_TR + '|' + GMAIL_HDR_TR_UNICODE + '|' + GMAIL_HDR_JSON + '|' + GMAIL_HDR_JSON_UNICODE;
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

{$IF DEFINED (ISFEXGUI)}
  // Check for startup.ini -----------------------------------------------------
  gStartup_ini_filename := (GetStartupDir + 'Startup.ini');
  Startup_ini_StringList := TStringList.Create;
  LineList := TStringList.Create;
  gWrite_Full_String_StringList := TStringList.Create; // free after write of new list
  try
    LineList.Delimiter := ','; // Default, but ";" is used with some locales
    LineList.QuoteChar := '"'; // Default
    LineList.StrictDelimiter := True; // Required: strings are separated *only* by Delimiter
    if FileExists(gStartup_ini_filename) then
    begin
      Startup_ini_StringList.LoadFromFile(gStartup_ini_filename);
    end
    else
    begin
      Progress.Log(RPad('Startup.ini:', RPAD_VALUE) + 'Not found.');
      gbl_FreeSpace := True;
      gbl_Hiberfil := True;
      gbl_PageFile := True;
      gbl_ShadowCopy := True;
      gbl_SwapFile := True;
      gbl_Unallocated := True;
    end;
    if assigned(Startup_ini_StringList) and (Startup_ini_StringList.Count > 0) then
    begin
      for i := 0 to Startup_ini_StringList.Count - 1 do
      begin
        if POS(INI_HEADER, Startup_ini_StringList[i]) > 0 then
        begin
          LineList.CommaText := Startup_ini_StringList.Strings[i];
          for j := 0 to LineList.Count - 1 do
          begin
            UpdateCheckbox(LineList[j]);
          end
        end
        else
        begin
          // If it does not relate put the full string into the list so that it can be written later
          gWrite_Full_String_StringList.Add(Startup_ini_StringList[i])
        end;
      end;
    end;
    LogCheckBox('Reading strings from:');
  finally
    Startup_ini_StringList.free;
    LineList.free;
  end;
{$IFEND}

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
      progress_program_str := 'Unallocated Search';

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

        if (CmdLine.Params.Indexof('MASTER') = -1) then
        begin
          ResultInt := 0;
{$IF DEFINED (ISFEXGUI)}
          if (CmdLine.Params.Indexof('NOSHOW') = -1) then
          begin
            Progress.DisplayMessageNow := 'Displaying Options Window';
            MyScriptForm := TScriptForm.Create;
            try
              ResultInt := idCancel;
              if MyScriptForm.ShowModal then
                ResultInt := idOk
            finally
              FreeAndNil(MyScriptForm);
            end;
          end
          else
            ResultInt := idOk;
{$IFEND}

          if ResultInt > 1 then
          begin
            Progress.Log('Canceled by user.');
            Progress.DisplayMessageNow := 'Canceled by user.';
            Exit;
          end;
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
            end;
          end; { About to process }

          // Write the new statup_ini file -------------------------------------------
          LogCheckBox('New Strings for:');
          temp_str := INI_HEADER + COMMA;
          if gbl_FreeSpace then
            temp_str := temp_str + 'FSOD' + COMMA;
          if gbl_Hiberfil then
            temp_str := temp_str + 'HBFL' + COMMA;
          if gbl_PageFile then
            temp_str := temp_str + 'PGFL' + COMMA;
          if gbl_ShadowCopy then
            temp_str := temp_str + 'SHAD' + COMMA;
          if gbl_SwapFile then
            temp_str := temp_str + 'SWFL' + COMMA;
          if gbl_Unallocated then
            temp_str := temp_str + 'UCLU' + COMMA;
          if assigned(gWrite_Full_String_StringList) then
          begin
            try
              for r := gWrite_Full_String_StringList.Count - 1 downto 0 do
              begin
                if trim(gWrite_Full_String_StringList[r]) = '' then // Remove blank lines from StrList
                  gWrite_Full_String_StringList.Delete(r);
              end;
              temp_str := trim(temp_str);
              if temp_str <> '' then
                gWrite_Full_String_StringList.Add(temp_str);
              if assigned(gWrite_Full_String_StringList) and (gWrite_Full_String_StringList.Count > 0) then
                try
{$IF DEFINED (ISFEXGUI)}
                  gWrite_Full_String_StringList.SaveToFile(gStartup_ini_filename);
                  Progress.Log(RPad('Wrote file:', RPAD_VALUE) + gStartup_ini_filename);
{$IFEND}
                except
                  Progress.Log(ATRY_EXCEPT_STR + RPad('Error writing:', RPAD_VALUE) + gStartup_ini_filename);
                end;
            finally
              gWrite_Full_String_StringList.free;
            end; { About to process }
          end;

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
              if gbl_FreeSpace then FindEntries_StringList.Add('**\Free Space on Disk');
              if gbl_Hiberfil then FindEntries_StringList.Add('**\hiberfil.sys');
              if gbl_PageFile then FindEntries_StringList.Add('**\pagefile.sys');
              if gbl_ShadowCopy then FindEntries_StringList.Add('**\*3808876b-c176-4e48-b7ae-04046e6cc752*');
              if gbl_SwapFile then FindEntries_StringList.Add('**\swapfile*');
              if gbl_Unallocated then FindEntries_StringList.Add('**\unallocated*');

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

                if anEntry.isFreeSpace then
                  DetermineThenSkipOrAdd(anEntry, iTunes_Domain_str, iTunes_Name_str)
                else
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

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Array_Items_1);

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
