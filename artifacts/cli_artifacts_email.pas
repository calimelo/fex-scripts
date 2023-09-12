unit Artifacts_Email;

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
  //Common_Utils      in '..\Common\Common_Utils.pas',
  Icon_List           in 'Common\Icon_List.pas',
  Itunes_Backup_Sig   in 'Common\Itunes_Backup_Signature_Analysis.pas',
  RS_DoNotTranslate   in 'Common\RS_DoNotTranslate.pas',
  //-----
  Aquamail            in 'Common\Column_Arrays\Aquamail.pas',
  Gmail               in 'Common\Column_Arrays\GMail.pas',
  IOS_Mail            in 'Common\Column_Arrays\IOS_Mail.pas',
  ProtonMail          in 'Common\Column_Arrays\ProtonMail.pas';

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
  CATEGORY_NAME             = 'Email';
  CHAR_LENGTH               = 80;
  CHAT                      = 'Chat';
  COLON                     = ':';
  COMMA                     = ',';
  CR                        = #13#10;
  DCR                       = #13#10 + #13#10;
  DUP_FILE                  = '';
  FBN_ITUNES_BACKUP_DOMAIN  = 'iTunes Backup Domain'; //noslz
  FBN_ITUNES_BACKUP_NAME    = 'iTunes Backup Name'; //noslz
  GFORMAT_STR               = '%-1s %-12s %-8s %-15s %-25s %-30s %-20s';
  GROUP_NAME                = 'Artifact Analysis';
  HYPHEN                    = ' - ';
  HYPHEN_NS                 = '-';
  IOS                       = 'iOS'; //noslz
  MAX_CARVE_SIZE            = 1024 * 10;
  MIN_CARVE_SIZE            = 0;
  NUMBEROFSEARCHITEMS       = 7; //*********************************************
  PIPE                      = '|'; //noslz
  PROCESS_AS_CARVE          = 'PROCESSASCARVE'; //noslz
  PROCESS_AS_PLIST          = 'PROCESSASPLIST'; //noslz
  PROCESS_AS_XML            = 'PROCESSASXML'; //noslz
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'Email';
  RPAD_VALUE                = 55;
  RUNNING                   = '...';
  SCRIPT_DESCRIPTION        = 'Extract Email Artifacts';
  SCRIPT_NAME               = 'Email.pas';
  SPACE                     = ' ';
  STR_FILES_BY_PATH         = 'Files by path';
  TSWT                      = 'The script will terminate.';
  USE_FLAGS_BL              = False;
  VERBOSE                   = False;
  WINDOWS                   = 'Windows'; //noslz

var
  anEntry:                        TEntry;
  Arr_ValidatedFiles_TList:       array[1..NUMBEROFSEARCHITEMS] of TList;
  ArtifactConnect_CategoryFolder: TArtifactEntry1;
  ArtifactConnect_ProgramFolder:  array[1..NUMBEROFSEARCHITEMS] of TArtifactConnectEntry;
  ArtifactsDataStore:             TDataStore;
  col_source_created:             TDataStoreField;
  col_source_file:                TDataStoreField;
  //col_source_location:          TDataStoreField;
  col_source_modified:            TDataStoreField;
  col_source_path:                TDataStoreField;
  current_str:                    string;
  Display_str:                    string;
  FileItems:                      array[1..NUMBEROFSEARCHITEMS] of PSQL_FileSearch;
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
function ReadEmailAddress(var Buffer: TProtoBufObject): string;
function ReadEmailAddress17(var Buffer: TProtoBufObject): string;
function RPad(const AString: string; AChars: integer): string;
function SetUpColumnforFolder(aReferenceNumber: integer; anArtifactFolder: TArtifactConnectEntry; out col_DF: TDataStoreFieldArray; ColCount: integer; aItems: TSQL_Table_array): boolean;
function TestForDoProcess(ARefNum: integer): boolean;
function TotalValidatedFileCountInTLists: integer;
procedure Attachment_Frog(aNode: TPropertyNode; aStringList: TStringList);
procedure DetermineThenSkipOrAdd(anEntry: TEntry; const biTunes_Domain_str: string; const biTunes_Name_str: string);
procedure DoProcess(anArtifactFolder: TArtifactConnectEntry; Reference_Number: integer; aItems: TSQL_Table_array);
procedure LoadFileItems;
procedure Nodefrog(aNode: TPropertyNode; anint: integer; aStringList: TStringList);

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

    ( // ~1~ Aqua Mail - Email - Android
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

    ( // ~2~ Gmail - Android {BigTop}
    fi_Name_Program:               'Gmail';
    fi_Name_Program_Type:          '';
    fi_Process_ID:                 'GMAIL_ANDROID'; //noslz
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_GMAIL;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'bigTopDataDB\.'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    //fi_Signature_Sub:            'bigTopDataDB Messages'; //noslz
    fi_SQLTables_Required:         ['ITEM_MESSAGES', 'ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ITEM_MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM ITEM_MESSAGES'; //noslz
    fi_Test_Data:                  'Digital Corpa Android_13'), //noslz

    ( // ~3~ Gmail - iOS {sqlitedb}
    fi_Name_Program:               'Gmail';
    fi_Name_Program_Type:          '';
    fi_Process_ID:                 'GMAIL_IOS'; //noslz
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_MOBILE;
    fi_Icon_Program:               ICON_GMAIL;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^sqlitedb'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE; //noslz
    //fi_Signature_Sub:            'bigTopDataDB Messages'; //noslz
    fi_SQLTables_Required:         ['ITEM_MESSAGES']; //noslz
    fi_SQLPrimary_Tablestr:        'ITEM_MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM ITEM_MESSAGES'; //noslz
    fi_Test_Data:                  'Digital Corpa iOS_15'), //noslz

    ( // ~4~ Gmail - Offline - Android
    fi_Name_Program:               'Gmail';
    fi_Name_Program_Type:          'Offline';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_EMAIL;
    fi_Icon_Program:               ICON_GMAIL;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^1$'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['CACHED_MESSAGES', 'CACHED_CONTACTS']; //noslz
    fi_SQLPrimary_Tablestr:        'CACHED_MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM CACHED_MESSAGES'; //noslz
    fi_Test_Data:                  'GreyKey'), //noslz

    ( // ~5~ Mail - Addresses - IOS
    fi_Name_Program:               'Mail';
    fi_Name_Program_Type:          'Addresses';
    fi_Process_ID:                 'DNT_APPLE_MAIL_ADDRESSES';
    fi_Name_OS:                    IOS;
    fi_Icon_Category:              ICON_EMAIL;
    fi_Icon_Program:               1160;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^Protected Index'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ADDRESSES', 'PROTECTED_MESSAGE_DATA']; //noslz
    fi_SQLPrimary_Tablestr:        'ADDRESSES'; //noslz
    fi_SQLStatement:               'SELECT * FROM ADDRESSES'; //noslz
    fi_Test_Data:                  'GreyKey'), //noslz

    ( // ~6~ Mail - IOS
    fi_Name_Program:               'Mail';
    fi_Name_Program_Type:          '';
    fi_Name_OS:                    IOS;
    fi_Process_ID:                 'DNT_APPLE_MAIL';
    fi_Icon_Category:              ICON_EMAIL;
    fi_Icon_Program:               1160;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^Envelope Index'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGES', 'MAILBOXES']; //noslz
    fi_SQLPrimary_Tablestr:        'MESSAGES'; //noslz
    fi_SQLStatement:               'SELECT * FROM messages, mailboxes WHERE messages.mailbox = mailboxes.ROWID';
    fi_Test_Data:                  'Digital Corpa'), //noslz

    ( // ~7~ Proton - Mail - Android
    fi_Name_Program:               'Proton';
    fi_Name_Program_Type:          'Mail';
    fi_Name_OS:                    ANDROID;
    fi_Icon_Category:              ICON_EMAIL;
    fi_Icon_Program:               ICON_PROTONMAIL;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'MessagesDatabase\.db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['MESSAGEV3', 'ATTACHMENTV3']; //noslz
    fi_SQLStatement:               'SELECT * FROM MESSAGEV3'; //noslz
    fi_Test_Data:                  'GreyKey'), //noslz
    );

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

function ReadEmailAddress(var Buffer: TProtoBufObject): string;
var
  tag, tagfield: integer;
  AddressCnt: integer;
  sName, sAddress: string;
  iend, iLength: integer;
begin
  Result := '';
  sName := '';
  sAddress := '';
  iLength := Buffer.readRawVarint32;
  iend := Buffer.GetPos + iLength;
  tag := Buffer.ReadTag;
  while (tag <> 0) and (Buffer.GetPos < iend) do
  begin
    tagfield := getTagFieldNumber(tag);
    // Progress.Log('------- tagfield'+inttostr(tagField));
    case tagfield of
      1:
        begin
          if sAddress <> '' then
          begin
            Result := trim(Result + ' ' + sName + ' ' + sAddress);
            sName := '';
            sAddress := '';
          end;
          AddressCnt := Buffer.readRawVarint32; // Unknown (email address, type address, address ID)
        end;
      2: // This is the email address
        begin
          sAddress := Buffer.readString;
        end;
      3: // This is the email name
        begin
          sName := Buffer.readString;
        end;
    else
      begin
        // progress.Log('------- Unknow tag'+inttostr(Tag));
        break;
      end;
    end;
    tag := Buffer.ReadTag;
  end; { while }
  Buffer.SetPos(iend);
  if sName <> '' then
    Result := trim(Result + SPACE + sName + '<' + sAddress + '>')
  else
    Result := trim(Result + SPACE + sAddress);
  // progress.Log('------- Result =' + Result);
end;

function ReadEmailAddress17(var Buffer: TProtoBufObject): string;
var
  iend, iLength: integer;
  sName, sAddress: string;
  tag, tagfield: integer;
begin
  Result := '';
  sName := '';
  sAddress := '';
  iLength := Buffer.readRawVarint32;
  iend := Buffer.GetPos + iLength;
  tag := Buffer.ReadTag;
  while (tag <> 0) and (Buffer.GetPos < iend) do
  begin
    tagfield := getTagFieldNumber(tag);
    // progress.Log('------- tagfield ' + inttostr(tagField));
    case tagfield of
      17: // This is the email address
        begin
          sAddress := Buffer.readString;
        end;
      15: // This is the email name
        begin
          sName := Buffer.readString;
        end;
    else
      begin
        // progress.Log('------- Unknow tag'+inttostr(Tag));
        Buffer.skipField(tag);
      end;
    end;
    tag := Buffer.ReadTag;
  end; // While tag
  Buffer.SetPos(iend);
  if sName <> '' then
    Result := trim(sName + '<' + sAddress + '>')
  else
    Result := trim(sAddress);
  // progress.Log('------- Result 17=' + Result);
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
  ArtifactParent_Children_TList: TList;
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
  g, i, w, z: integer;
  HeaderReader, FooterReader, CarvedEntryReader: TEntryReader;
  HeaderRegex, FooterRegEx: TRegEx;
  h_startpos, h_offset, h_count, f_offset, f_count: int64;
  Item: PSQL_FileSearch;
  mem_strm1: TMemoryStream;
  mydb: TSQLite3Database;
  newEntryReader: TEntryReader;
  newJOURNALReader: TEntryReader;
  newWALReader: TEntryReader;
  Node1: TPropertyNode;
  NodeList1: TObjectList;
  NumberOfNodes: integer;
  offset_str: string;
  parentArtifaceEntry: TEntry;
  Re: TDIPerlRegEx;
  records_read_int: integer;
  relationalArtifactEntry: TEntry;
  r_val_str: string;
  sqlselect: TSQLite3Statement;
  sqlselect_row: TSQLite3Statement;
  sql_row_count: integer;
  sql_tbl_count: integer;
  strm: TBytesStream;
  tempstr: string;
  temp_str: string;
  tmpEntry: TEntry;
  TotalFiles: int64;
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
      if (Item^.fi_Process_ID = 'DNT_INTERNET_EXPLORER_4_9') and populate_bl then
        ADDList.Add(NEntry);
      if not(Item^.fi_Process_ID = 'DNT_INTERNET_EXPLORER_4_9') then
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

  function GetRelationalValue(r_Entry: TEntry; r_sql_statement_str: string; id_str: string): string;
  var
    r_db: TSQLite3Database;
    r_EntryReader: TEntryReader;
    r_sqlselect: TSQLite3Statement;
  begin
    Result := '';
    r_EntryReader := TEntryReader.Create;
    try
      if assigned(r_Entry) and r_EntryReader.opendata(r_Entry) and (r_EntryReader.Size > 0) and Progress.isRunning then
      begin
        newWALReader := GetWALReader(r_Entry);
        newJOURNALReader := GetJOURNALReader(r_Entry);
        r_db := TSQLite3Database.Create;
        try
          if assigned(r_db) then
            try
              r_db.OpenStream(r_EntryReader, newJOURNALReader, newWALReader);
              r_sqlselect := TSQLite3Statement.Create(r_db, r_sql_statement_str);
              while r_sqlselect.Step = SQLITE_ROW do
              begin
                if id_str = r_sqlselect.ColumnText(0) then
                  Result := r_sqlselect.ColumnText(1);
              end;
            finally
              r_sqlselect.Reset;
              r_db.Close;
            end;
        finally
          r_db.free;
        end;
      end;
    finally
      FreeAndNil(r_EntryReader);
    end;
  end;

// Start of Do Process ---------------------------------------------------------
var
  Buffer: TProtoBufObject;
  pb_fieldType: integer;
  pb_tag_int: integer;
  pb_tag_field_int: integer;
  tmp_int64: int64;

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

                          // GMAIL - Compressed ProtoBuffer
                          if (Item^.fi_Process_ID = 'GMAIL_ANDROID') or (Item^.fi_Process_ID = 'GMAIL_IOS') then // noslz
                          begin
                            if (UpperCase(DNT_sql_col) = 'ZIPPED_MESSAGE_PROTO') then // noslz
                            begin
                              CompressedData := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              strm := TBytesStream.Create(CompressedData);
                              try
                                strm.Position := 1;
                                decompstrm := TZDecompressionStream.Create(strm); // Create a decompressed stream
                                decompstrm.Position := 0;
                                mem_strm1 := TMemoryStream.Create; // Create a memory stream
                                Buffer := TProtoBufObject.Create;
                                try
                                  // Progress.Log('sql_row_count: ' + inttostr(records_read_int) + SPACE + UpperCase(aItems[g].sql_col));
                                  mem_strm1.copyfrom(decompstrm, decompstrm.Size); // Copy the decompressed stream into the memory stream
                                  if mem_strm1.Size > 0 then
                                  begin
                                    Buffer.LoadFromStream(mem_strm1);
                                    pb_tag_int := Buffer.ReadTag;
                                    try
                                      variant_Array[4] := ''; // set to blank
                                      while (pb_tag_int <> 0) and (Progress.isRunning) do
                                      begin
                                        pb_tag_field_int := getTagFieldNumber(pb_tag_int);
                                        pb_fieldType := getTagWireType(pb_tag_int);
                                        // Progress.Log(RPad('Tag number:', RPAD_VALUE) + inttostr(pb_tag_int));
                                        // Progress.Log(RPad('Field number:', RPAD_VALUE) + inttostr(pb_tag_field_int));

                                        Case pb_tag_field_int of

                                        1: { Protobuf: To }
                                        begin
                                        variant_Array[3] := ReadEmailAddress(Buffer);
                                        // variant_Array[3] := StrippedOfNonAscii(Buffer.ReadString);
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD1', 'TO', variant_Array[3]])); //noslz
                                        end;

                                        4: { Protobuf: From }
                                        begin
                                        variant_Array[4] := ReadEmailAddress(Buffer);
                                        // variant_Array[4] := StrippedOfNonAscii(Buffer.ReadString);
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD4', 'FROM', variant_Array[4]])); //noslz
                                        end;

                                        5: { Protobuf: Subject }
                                        begin
                                        variant_Array[5] := Buffer.readString;
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD5', 'SUBJECT', variant_Array[5]])); //noslz
                                        end;

                                        7: { Protobuf: Preview }
                                        begin
                                        variant_Array[6] := Buffer.readString;
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD7', 'PREVIEW', variant_Array[6]])); //noslz
                                        end;

                                        8: { Protobuf: Message ID }
                                        begin
                                        variant_Array[7] := Buffer.readString;
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD8', 'MESSAGE ID', variant_Array[7]])); //noslz
                                        end;

                                        11: { Protobuf: To }
                                        begin
                                        if variant_Array[4] = '' then
                                        variant_Array[4] := ReadEmailAddress17(Buffer)
                                        else
                                        Buffer.skipField(pb_tag_int);
                                        // variant_Array[3] := StrippedOfNonAscii(Buffer.ReadString);
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD1', 'TO', variant_Array[3]])); //noslz
                                        end;

                                        17: { Protobuf: Received Date }
                                        begin
                                        variant_Array[2] := Buffer.readInt64;
                                        if (VarType(variant_Array[2]) = 20) then
                                        begin
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD17', 'DATE RECEIVED RAW', variant_Array[2]])); //noslz
                                        try
                                        tmp_int64 := variant_Array[2];
                                        variant_Array[2] := UnixTimeToDateTime(tmp_int64 div 1000);
                                        // Progress.Log(format('%-10s %-30s %-15s', ['FIELD17', 'DATE RECEIVED', DateTimeToStr(variant_Array[2])])); //noslz
                                        except
                                        end;
                                        end;
                                        end
                                        else

                                        begin
                                        // Progress.Log(RPad('SKIP FIELD:', RPAD_VALUE) + inttostr(pb_tag_field_int) + ' Type: ' + inttostr(pb_fieldType)+' Tag: ' + inttostr(pb_tag_int));
                                        Buffer.skipField(pb_tag_int);
                                        end;

                                        end; { Case }
                                        pb_tag_int := Buffer.ReadTag; // Read next Protobuf tag
                                      end;

                                    except
                                      on e: exception do
                                      begin
                                        Progress.Log(e.message);
                                        Progress.Log(RPad('Protobuf_Err:', RPAD_VALUE) + 'Tag: ' + IntToStr(pb_tag_field_int) + SPACE + 'Pos: ' + IntToStr(Buffer.GetPos));
                                        Progress.Log(StringOfChar('-', CHAR_LENGTH));
                                      end;
                                    end;

                                    AddToModule;
                                  end;
                                finally
                                  Buffer.free;
                                  mem_strm1.free;
                                  decompstrm.free;
                                end;
                              finally
                                strm.free;
                              end;
                            end;

                          end;

                          // Apple Mail ----------------------------------------
                          if (UpperCase(Item^.fi_Process_ID) = 'DNT_APPLE_MAIL') and (UpperCase(Item^.fi_Name_OS) = UpperCase(IOS)) then
                          begin
                            if UpperCase(aItems[g].fex_col) = 'READ' then // noslz
                            begin
                              if variant_Array[g] = '1' then
                                variant_Array[g] := 'Yes'
                              else if variant_Array[g] = '0' then
                                variant_Array[g] := 'No'
                              else
                                variant_Array[g] := 'Unknown';
                            end;
                            if UpperCase(aItems[g].fex_col) = 'IS DELETED' then // noslz
                            begin
                              if variant_Array[g] = '1' then
                                variant_Array[g] := 'Yes'
                              else if variant_Array[g] = '0' then
                                variant_Array[g] := 'No'
                              else
                                variant_Array[g] := 'Unknown';
                            end;

                            // Apple Mail - Get Relational Value from Protected Index
                            if (UpperCase(aItems[g].sql_col) = 'DNT_SUBJECT') or (UpperCase(aItems[g].sql_col) = 'DNT_SUMMARY') or (UpperCase(aItems[g].sql_col) = 'DNT_SENDER') then // noslz
                            begin
                              if assigned(aArtifactEntry.Parent) and (aArtifactEntry.Parent.EntryName = 'Mail') then // noslz
                              begin
                                tmpEntry := nil;
                                relationalArtifactEntry := nil;
                                parentArtifaceEntry := TEntry(aArtifactEntry.Parent);
                                ArtifactParent_Children_TList := TList.Create;
                                try
                                  ArtifactParent_Children_TList := FileSystemDataStore.Children(parentArtifaceEntry, False);
                                  for w := 0 to ArtifactParent_Children_TList.Count - 1 do
                                  begin
                                    tmpEntry := TEntry(ArtifactParent_Children_TList[w]);
                                    if tmpEntry.EntryName = 'Protected Index' then // noslz
                                    begin
                                      relationalArtifactEntry := tmpEntry;
                                      break;
                                    end;
                                  end;
                                finally
                                  ArtifactParent_Children_TList.free;
                                end;

                                // Subjects
                                if UpperCase(aItems[g].sql_col) = 'DNT_SUBJECT' then // noslz
                                begin
                                  if assigned(relationalArtifactEntry) and (relationalArtifactEntry <> nil) then
                                  begin
                                    r_val_str := GetRelationalValue(relationalArtifactEntry, 'SELECT * FROM SUBJECTS', variant_Array[g]);
                                    variant_Array[g] := r_val_str;
                                  end;
                                end;

                                // Summaries
                                if UpperCase(aItems[g].sql_col) = 'DNT_SUMMARY' then // noslz
                                begin
                                  if assigned(relationalArtifactEntry) and (relationalArtifactEntry <> nil) then
                                  begin
                                    r_val_str := GetRelationalValue(relationalArtifactEntry, 'SELECT * FROM SUMMARIES', variant_Array[g]);
                                    variant_Array[g] := r_val_str;
                                  end;
                                end;

                                // Address
                                if UpperCase(aItems[g].sql_col) = 'DNT_SENDER' then // noslz
                                begin
                                  if assigned(relationalArtifactEntry) and (relationalArtifactEntry <> nil) then
                                  begin
                                    r_val_str := GetRelationalValue(relationalArtifactEntry, 'SELECT * FROM ADDRESSES', variant_Array[g]);
                                    variant_Array[g] := r_val_str;
                                  end;
                                end;

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
              FindEntries_StringList.Add('**\*.db'); // noslz
              FindEntries_StringList.Add('**\*.db*'); // noslz
              FindEntries_StringList.Add('**\bigTopDataDB*'); // noslz
              FindEntries_StringList.Add('**\Envelope Index'); // noslz
              FindEntries_StringList.Add('**\https_mail.google.com_0\*'); // noslz
              FindEntries_StringList.Add('**\Protected Index'); // noslz
              FindEntries_StringList.Add('**\sqlitedb*'); // noslz

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

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Aquamail.GetTable('AQUAMAIL_ANDROID'));
            Ref_Num := 2;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GMail.GetTable('GMAIL_ANDROID'));
            Ref_Num := 3;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GMail.GetTable('GMAIL_IOS'));
            Ref_Num := 4;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, GMail.GetTable('GMAIL_OFFLINE_ANDROID'));
            Ref_Num := 5;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IOS_Mail.GetTable('IOS_MAIL_ADDRESSES'));
            Ref_Num := 6;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, IOS_Mail.GetTable('IOS_MAIL'));
            Ref_Num := 7;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, ProtonMail.GetTable('PROTONMAIL_ANDROID'));

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
