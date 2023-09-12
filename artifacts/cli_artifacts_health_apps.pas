unit Health_Apps;

// References:
// https://www.sciencedirect.com/science/article/pii/S2666281723000057
// https://github.com/mac4n6/APOLLO/blob/master/modules/health_workout_elevation.txt
// https://dfir.pubpub.org/pub/xqvcn3hj/release/1

// Apple Developer Documentation
// hkworkoutactivitytype - https://developer.apple.com/documentation/healthkit/hkworkoutactivitytype
// running = 37
// walking = 52

// SQL Query
// https://github.com/mac4n6/APOLLO/tree/master/modules
// -----------------------------------------------------------------------------
// LICENSE 2 (GNU GPL v3 or later):
// This file is part of APOLLO (Apple Pattern of Life Lazy Outputer).
// APOLLO is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// APOLLO is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with APOLLO.  If not, see <https://www.gnu.org/licenses/>.
// -----------------------------------------------------------------------------

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
  AppleHealth in 'Common\Column_Arrays\AppleHealth.pas',
  Fitbit in 'Common\Column_Arrays\Fitbit.pas',
  Garmin in 'Common\Column_Arrays\Garmin.pas';

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
  CATEGORY_NAME             = 'Health Apps';
  CHAR_LENGTH               = 80;
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
  ICON_ANDROID              = 1017;
  ICON_IOS                  = 1062;
  IOS                       = 'iOS'; //noslz
  NUMBEROFSEARCHITEMS       = 14; //*********************************************
  PROCESS_AS_CARVE          = 'PROCESSASCARVE'; //noslz
  PROCESS_AS_PLIST          = 'PROCESSASPLIST'; //noslz
  PROCESS_AS_XML            = 'PROCESSASXML'; //noslz
  PROCESSALL                = 'PROCESSALL'; //noslz
  PROGRAM_NAME              = 'Health Apps';
  RPAD_VALUE                = 55;
  RUNNING                   = '...';
  SCRIPT_DESCRIPTION        = 'Extract Health Artifacts';
  SCRIPT_NAME               = 'Health_Apps.pas';
  SP                        = ' ';
  SPACE                     = ' ';
  STR_FILES_BY_PATH         = 'Files by path';
  TRIAGE                    = 'TRIAGE'; //noslz
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
  lFileItems: array [1 .. NUMBEROFSEARCHITEMS] of TSQL_FileSearch = (

    ( // ~1~ Apple Health - Heart Rate
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'Heart Rate';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTables_Required:         ['SAMPLES'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    fi_SQLStatement:               'SELECT samples.*,                                                          ' + //noslz
                                   '       quantity_samples.original_quantity,                                 ' + //noslz
                                   '       data_provenances.origin_product_type,                               ' + //noslz
                                   '       unit_strings.unit_string                                            ' + //noslz
                                   'FROM   samples                                                             ' + //noslz
                                   '       LEFT OUTER JOIN quantity_samples                                    ' + //noslz
                                   '                    ON samples.data_id = quantity_samples.data_id          ' + //noslz
                                   '       LEFT OUTER JOIN objects                                             ' + //noslz
                                   '                    ON samples.data_id = objects.data_id                   ' + //noslz
                                   '       LEFT OUTER JOIN data_provenances                                    ' + //noslz
                                   '                    ON objects.provenance = data_provenances.ROWID         ' + //noslz
                                   '       LEFT OUTER JOIN unit_strings                                        ' + //noslz
                                   '                  ON quantity_samples.original_unit = unit_strings.ROWID   ' + //noslz
                                   'WHERE (samples.data_type = 5)                                              ' + //noslz - 5 = Heart Rate
                                   '       AND ( samples.start_date IS NOT NULL )                              ' + //noslz
                                   '       AND ( samples.end_date IS NOT NULL )                                '), //noslz
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    ( // ~2~ Apple Health - Steps
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'Steps';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTables_Required:         ['SAMPLES','WORKOUTS'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    fi_SQLStatement:               'SELECT samples.*,                                                          ' + //noslz
                                   '       quantity_samples.quantity,                                          ' + //noslz
                                   '       data_provenances.origin_product_type                                ' + //noslz
                                   'FROM   samples                                                             ' + //noslz
                                   '       LEFT OUTER JOIN quantity_samples                                    ' + //noslz
                                   '                    ON samples.data_id = quantity_samples.data_id          ' + //noslz
                                   '       LEFT OUTER JOIN objects                                             ' + //noslz
                                   '                    ON samples.data_id = objects.data_id                   ' + //noslz
                                   '       LEFT OUTER JOIN data_provenances                                    ' + //noslz
                                   '                    ON objects.provenance = data_provenances.rowid         ' + //noslz
                                   'WHERE (samples.data_type = 7)                                              ' + //noslz - 7 = Steps
                                   '       AND ( samples.start_date IS NOT NULL )                              ' + //noslz
                                   '       AND ( samples.end_date IS NOT NULL )                                '), //noslz
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    ( // ~3~ Apple Health - Distance
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'Distance';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_HEART;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTables_Required:         ['SAMPLES','WORKOUTS'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    fi_SQLStatement:               'SELECT samples.*,                                                          ' + //noslz
                                   '       quantity_samples.quantity,                                          ' + //noslz
                                   '       data_provenances.origin_product_type                                ' + //noslz
                                   'FROM   samples                                                             ' + //noslz
                                   '       LEFT OUTER JOIN quantity_samples                                    ' + //noslz
                                   '                    ON samples.data_id = quantity_samples.data_id          ' + //noslz
                                   '       LEFT OUTER JOIN objects                                             ' + //noslz
                                   '                    ON samples.data_id = objects.data_id                   ' + //noslz
                                   '       LEFT OUTER JOIN data_provenances                                    ' + //noslz
                                   '                    ON objects.provenance = data_provenances.rowid         ' + //noslz
                                   'WHERE (samples.data_type = 8)                                              ' + //noslz - 8 = Distance
                                   '       AND ( samples.start_date IS NOT NULL )                              ' + //noslz
                                   '       AND ( samples.end_date IS NOT NULL )                                '), //noslz
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    ( // ~4~ Apple Health - Flights Climbed
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'Flights Climbed';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTables_Required:         ['SAMPLES','WORKOUTS'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    //~~~~~~~~~~~~~~
    fi_SQLStatement:               'SELECT samples.*,                                                          ' + //noslz
                                   '       quantity_samples.quantity,                                          ' + //noslz
                                   '       data_provenances.origin_product_type                                ' + //noslz
                                   'FROM   samples                                                             ' + //noslz
                                   '       LEFT OUTER JOIN quantity_samples                                    ' + //noslz
                                   '                    ON samples.data_id = quantity_samples.data_id          ' + //noslz
                                   '       LEFT OUTER JOIN objects                                             ' + //noslz
                                   '                    ON samples.data_id = objects.data_id                   ' + //noslz
                                   '       LEFT OUTER JOIN data_provenances                                    ' + //noslz
                                   '                    ON objects.provenance = data_provenances.rowid         ' + //noslz
                                   'WHERE (samples.data_type = 12)                                             ' + //noslz - 12 = Fights/Floors climbed
                                   '       AND ( samples.start_date IS NOT NULL )                              ' + //noslz
                                   '       AND ( samples.end_date IS NOT NULL )                                '), //noslz
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    ( // ~5~ Apple Health - Height
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'User Height';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_HEART;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTableS_Required:         ['SAMPLES','WORKOUTS'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    //~~~~~~~~~~~~~~
    fi_SQLStatement:               'SELECT samples.*,                                                          ' + //noslz
                                   '       quantity_samples.quantity,                                          ' + //noslz
                                   '       data_provenances.origin_product_type,                               ' + //noslz
                                   '       unit_strings.unit_string                                            ' + //noslz
                                   'FROM   samples                                                             ' + //noslz
                                   '       LEFT OUTER JOIN quantity_samples                                    ' + //noslz
                                   '                    ON samples.data_id = quantity_samples.data_id          ' + //noslz
                                   '       LEFT OUTER JOIN objects                                             ' + //noslz
                                   '                    ON samples.data_id = objects.data_id                   ' + //noslz
                                   '       LEFT OUTER JOIN data_provenances                                    ' + //noslz
                                   '                    ON objects.provenance = data_provenances.rowid         ' + //noslz
                                   '       LEFT OUTER JOIN unit_strings                                        ' + //noslz
                                   '                    ON quantity_samples.original_unit = unit_strings.ROWID ' + //noslz
                                   'WHERE (samples.data_type = 2)                                              ' + //noslz - 2 = Height
                                   '       AND ( samples.start_date IS NOT NULL )                              ' + //noslz
                                   '       AND ( samples.end_date IS NOT NULL )                                '), //noslz
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    ( // ~6~ Apple Health - Weight
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'User Weight';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTables_Required:         ['SAMPLES','SAMPLES'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    //~~~~~~~~~~~~~~
    fi_SQLStatement:               'SELECT samples.*,                                                          ' + //noslz
                                   '       quantity_samples.quantity,                                          ' + //noslz
                                   '       data_provenances.origin_product_type                                ' + //noslz
                                   'FROM   samples                                                             ' + //noslz
                                   '       LEFT OUTER JOIN quantity_samples                                    ' + //noslz
                                   '                    ON samples.data_id = quantity_samples.data_id          ' + //noslz
                                   '       LEFT OUTER JOIN objects                                             ' + //noslz
                                   '                    ON samples.data_id = objects.data_id                   ' + //noslz
                                   '       LEFT OUTER JOIN data_provenances                                    ' + //noslz
                                   '                    ON objects.provenance = data_provenances.rowid         ' + //noslz
                                   'WHERE (samples.data_type = 3)                                              ' + //noslz - 3 = Weight
                                   '       AND ( samples.start_date IS NOT NULL )                              ' + //noslz
                                   '       AND ( samples.end_date IS NOT NULL )                                '), //noslz
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    ( // ~7~ Apple Health - Workout - Latitude
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'Workout' + SPACE + 'Latitude';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_HEART;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTables_Required:         ['SAMPLES','WORKOUTS'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    //~~~~~~~~~~~~~~
      fi_SQLStatement:
      'SELECT                                                                                                   ' + //noslz
      '    WORKOUTS.DATA_ID AS "DATA ID",                                                                       ' + //noslz
      '    SAMPLES.START_DATE AS "STARTY",                                                                      ' + //noslz
      '    SAMPLES.END_DATE AS "ENDY",                                                                          ' + //noslz
      '    METADATA_VALUES.NUMERICAL_VALUE AS "LATITUDE",                                                       ' + //noslz
      '      CASE WORKOUTS.ACTIVITY_TYPE                                                                        ' + //noslz
      '          WHEN 63 THEN "HIGH INTENSITY INTERVAL TRAINING (HIIT)"                                         ' + //noslz
      '          WHEN 37 THEN "INDOOR / OUTDOOR RUN"                                                            ' + //noslz
      '          WHEN 3000 THEN "OTHER"                                                                         ' + //noslz
      '          WHEN 52 THEN "INDOOR / OUTDOOR WALK"                                                           ' + //noslz
      '          WHEN 20 THEN "FUNCTIONAL TRAINING"                                                             ' + //noslz
      '          WHEN 13 THEN "INDOOR CYCLE"                                                                    ' + //noslz
      '          WHEN 16 THEN "ELLIPTICAL"                                                                      ' + //noslz
      '          WHEN 35 THEN "ROWER"                                                                           ' + //noslz
      '      ELSE "UNKNOWN" || "-" || WORKOUTS.ACTIVITY_TYPE                                                    ' + //noslz
      '      END "WORKOUT TYPE",                                                                                ' + //noslz
      '    WORKOUTS.DURATION / 60.00 AS "DURATION (IN MINUTES)",                                                ' + //noslz
      '    WORKOUTS.TOTAL_ENERGY_BURNED AS "CALORIES BURNED",                                                   ' + //noslz
      '    WORKOUTS.TOTAL_DISTANCE AS "DISTANCE_KM",                                                            ' + //noslz
      '    WORKOUTS.TOTAL_BASAL_ENERGY_BURNED AS "TOTAL BASEL ENERGY BURNED",                                   ' + //noslz
      '        CASE WORKOUTS.GOAL_TYPE                                                                          ' + //noslz
      '            WHEN 2 THEN "MINUTES"                                                                        ' + //noslz
      '            WHEN 0 THEN "OPEN"                                                                           ' + //noslz
      '        END "GOAL TYPE",                                                                                 ' + //noslz
      '    WORKOUTS.GOAL AS "GOAL"                                                                              ' + //noslz
      '  FROM                                                                                                   ' + //noslz
      '      SAMPLES                                                                                            ' + //noslz
      '      LEFT OUTER JOIN                                                                                    ' + //noslz
      '          METADATA_VALUES                                                                                ' + //noslz
      '          ON METADATA_VALUES.OBJECT_ID = SAMPLES.DATA_ID                                                 ' + //noslz
      '      LEFT OUTER JOIN                                                                                    ' + //noslz
      '          METADATA_KEYS                                                                                  ' + //noslz
      '          ON METADATA_KEYS.ROWID = METADATA_VALUES.KEY_ID                                                ' + //noslz
      '      LEFT OUTER JOIN                                                                                    ' + //noslz
      '          WORKOUTS                                                                                       ' + //noslz
      '          ON WORKOUTS.DATA_ID = SAMPLES.DATA_ID                                                          ' + //noslz
      '  WHERE                                                                                                  ' + //noslz
      '      WORKOUTS.ACTIVITY_TYPE NOT NULL AND KEY IS "_HKPrivateWorkoutWeatherLocationCoordinatesLatitude"   '), //noslz

    ( // ~8~ Apple Health - Workout - Longitude
    fi_Name_Program:               'Apple' + SPACE + 'Health';
    fi_Name_Program_Type:          'Workout' + SPACE + 'Longitude';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_HEART;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^healthdb_secure\.sqlite*';                                                    //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;                                                                  //noslz
    fi_SQLTableS_Required:         ['SAMPLES','WORKOUTS'];                                                                      //noslz
    fi_SQLPrimary_Tablestr:        'SAMPLES';                                                                     //noslz
    //~~~~~~~~~~~~~~
      fi_SQLStatement:
      'SELECT                                                                                                   ' + //noslz
      '    WORKOUTS.DATA_ID AS "DATA ID",                                                                       ' + //noslz
      '    SAMPLES.START_DATE AS "STARTY",                                                                      ' + //noslz
      '    SAMPLES.END_DATE AS "ENDY",                                                                          ' + //noslz
      '    METADATA_VALUES.NUMERICAL_VALUE AS "LONGITUDE",                                                      ' + //noslz
      '      CASE WORKOUTS.ACTIVITY_TYPE                                                                        ' + //noslz
      '          WHEN 63 THEN "HIGH INTENSITY INTERVAL TRAINING (HIIT)"                                         ' + //noslz
      '          WHEN 37 THEN "INDOOR / OUTDOOR RUN"                                                            ' + //noslz
      '          WHEN 3000 THEN "OTHER"                                                                         ' + //noslz
      '          WHEN 52 THEN "INDOOR / OUTDOOR WALK"                                                           ' + //noslz
      '          WHEN 20 THEN "FUNCTIONAL TRAINING"                                                             ' + //noslz
      '          WHEN 13 THEN "INDOOR CYCLE"                                                                    ' + //noslz
      '          WHEN 16 THEN "ELLIPTICAL"                                                                      ' + //noslz
      '          WHEN 35 THEN "ROWER"                                                                           ' + //noslz
      '      ELSE "UNKNOWN" || "-" || WORKOUTS.ACTIVITY_TYPE                                                    ' + //noslz
      '      END "WORKOUT TYPE",                                                                                ' + //noslz
      '    WORKOUTS.DURATION / 60.00 AS "DURATION (IN MINUTES)",                                                ' + //noslz
      '    WORKOUTS.TOTAL_ENERGY_BURNED AS "CALORIES BURNED",                                                   ' + //noslz
      '    WORKOUTS.TOTAL_DISTANCE AS "DISTANCE_KM",                                                            ' + //noslz
      '    WORKOUTS.TOTAL_BASAL_ENERGY_BURNED AS "TOTAL BASEL ENERGY BURNED",                                   ' + //noslz
      '        CASE WORKOUTS.GOAL_TYPE                                                                          ' + //noslz
      '            WHEN 2 THEN "MINUTES"                                                                        ' + //noslz
      '            WHEN 0 THEN "OPEN"                                                                           ' + //noslz
      '        END "GOAL TYPE",                                                                                 ' + //noslz
      '    WORKOUTS.GOAL AS "GOAL"                                                                              ' + //noslz
      '  FROM                                                                                                   ' + //noslz
      '      SAMPLES                                                                                            ' + //noslz
      '      LEFT OUTER JOIN                                                                                    ' + //noslz
      '          METADATA_VALUES                                                                                ' + //noslz
      '          ON METADATA_VALUES.OBJECT_ID = SAMPLES.DATA_ID                                                 ' + //noslz
      '      LEFT OUTER JOIN                                                                                    ' + //noslz
      '          METADATA_KEYS                                                                                  ' + //noslz
      '          ON METADATA_KEYS.ROWID = METADATA_VALUES.KEY_ID                                                ' + //noslz
      '      LEFT OUTER JOIN                                                                                    ' + //noslz
      '          WORKOUTS                                                                                       ' + //noslz
      '          ON WORKOUTS.DATA_ID = SAMPLES.DATA_ID                                                          ' + //noslz
      '  WHERE                                                                                                  ' + //noslz
      '      WORKOUTS.ACTIVITY_TYPE NOT NULL AND KEY IS "_HKPrivateWorkoutWeatherLocationCoordinatesLongitude"  '), //noslz

    ( // ~9~ Fitbit - Activity Log - IOS
    fi_Name_Program:               'Fitbit';
    fi_Name_Program_Type:          'Activity Log';
    fi_Process_ID:                 'DNT_FITBIT_IOS_ACTIVITY_LOG'; //noslz
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_FITBIT;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^fitbit\.sqlite'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZFBACTIVITYLOG','ZFBUSER']; //noslz
    fi_SQLPrimary_Tablestr:        'ZFBACTIVITYLOG'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZFBACTIVITYLOG'), //noslz

    ( // ~10~ Fitbit - Exercise Event - Android
    fi_Name_Program:               'Fitbit';
    fi_Name_Program_Type:          'Event';
    fi_Process_ID:                 'DNT_FITBIT_EVENT_ANDROID'; //noslz
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_FITBIT;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               'exercise_db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['EXERCISE_EVENT']; //noslz
    fi_SQLPrimary_Tablestr:        'EXCRCISE_EVENT'; //noslz
    fi_SQLStatement:               'SELECT * FROM EXERCISE_EVENT'), //noslz

    ( // ~11~ Fitbit - Profile - Android
    fi_Name_Program:               'Fitbit';
    fi_Name_Program_Type:          'Profile';
    fi_Process_ID:                 'DNT_FITBIT_PROFILE_ANDROID'; //noslz
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_FITBIT;
    fi_Icon_OS:                    ICON_ANDROID;
    fi_Regex_Search:               '^fitbit-db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['PROFILE','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'PROFILE'; //noslz
    fi_SQLStatement:               'SELECT * FROM PROFILE'), //noslz

    ( // ~12~ Fitbit - User - IOS
    fi_Name_Program:               'Fitbit';
    fi_Name_Program_Type:          'User';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               ICON_FITBIT;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^fitbit\.sqlite'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ZFBUSER','ZFBACTIVITYLOG']; //noslz
    fi_SQLPrimary_Tablestr:        'ZFBACTIVITYLOG'; //noslz
    fi_SQLStatement:               'SELECT * FROM ZFBUSER'), //noslz

    ( // ~13~ Garmin - Connect - Android (https://www.mdpi.com/2076-3417/12/19/9747)
    fi_Name_Program:               'Garmin Connect';
    fi_Name_Program_Type:          'Activities';
    fi_Process_ID:                 'DNT_GARMIN_CONNECT';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               1214;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^gcm_cache\.db'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['JSON_ACTIVITIES','ANDROID_METADATA']; //noslz
    fi_SQLPrimary_Tablestr:        'JSON_ACTIVITIES'; //noslz
    fi_SQLStatement:               'SELECT * FROM JSON_ACTIVITIES'), //noslz

    ( // ~14~ Garmin - Activity Details - Android (https://www.mdpi.com/2076-3417/12/19/9747)
    fi_Name_Program:               'Garmin Connect';
    fi_Name_Program_Type:          'Activity Details';
    fi_Process_ID:                 'DNT_GARMIN_CONNECT';
    fi_Icon_Category:              ICON_HEALTH;
    fi_Icon_Program:               1214;
    fi_Icon_OS:                    ICON_IOS;
    fi_Regex_Search:               '^cache-database*'; //noslz
    fi_Signature_Parent:           RS_SIG_SQLITE;
    fi_SQLTables_Required:         ['ACTIVITY_DETAILS']; //noslz
    fi_SQLPrimary_Tablestr:        'ACTIVITY_DETAILS'; //noslz
    fi_SQLStatement:               'SELECT * FROM ACTIVITY_DETAILS'), //noslz

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
  ColCount: integer;
  col_DF: TDataStoreFieldArray;
  Display_Name_str: string;
  DNT_sql_col: string;
  FBStartTime_bytes: Tbytes;
  FBStartTime_double: Double;
  FBStartTime_dt: TDateTime;
  i, g, z: integer;
  Item: PSQL_FileSearch;
  mydb: TSQLite3Database;
  newEntryReader: TEntryReader;
  newJOURNALReader: TEntryReader;
  newWALReader: TEntryReader;
  records_read_int: integer;
  sqlselect: TSQLite3Statement;
  sqlselect_row: TSQLite3Statement;
  sql_row_count: integer;
  sql_tbl_count: integer;
  tempstr: string;
  tmp_garmin_cache_str: string;
  tmp_garmin_lat_str: string;
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
        begin
          if (col_DF[g].FieldType = ftDateTime) then
            col_DF[g].AsDateTime[NEntry] := variant_Array[g];

          if (col_DF[g].FieldType = ftinteger) then
            try
              if trim(variant_Array[g]) = '' then
                variant_Array[g] := null
              else
                col_DF[g].AsInteger[NEntry] := variant_Array[g];
            except
              variant_Array[g] := null;
            end;

          if (col_DF[g].FieldType = ftLargeInt) then
            col_DF[g].AsInt64[NEntry] := variant_Array[g];
          if (col_DF[g].FieldType = ftBytes) then
            col_DF[g].AsBytes[NEntry] := variantToArrayBytes(variant_Array[g]);

          if (col_DF[g].FieldType = ftString) and VarIsStr(variant_Array[g]) and (variant_Array[g] <> '') then
            col_DF[g].AsString(NEntry) := variant_Array[g];

          if (col_DF[g].FieldType = ftFloat) and VarIsStr(variant_Array[g]) and (variant_Array[g] <> '') then
            try
              col_DF[g].AsFloat[NEntry] := StrToFloat(variant_Array[g]);
            except
              Progress.Log('StrToFloat error'); // noslz
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

            if assigned(aArtifactEntry) and newEntryReader.opendata(aArtifactEntry) and (newEntryReader.Size > 0) and Progress.isRunning then
            begin
              if USE_FLAGS_BL then
                aArtifactEntry.Flags := aArtifactEntry.Flags + [Flag8]; // Gray Flag = Process Routine

              // ================================================================
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

                          if (DNT_sql_col = 'ZSTARTTIME') then
                          begin
                            if (aItems[g].read_as = ftFloat) and (aItems[g].col_type = ftDateTime) then
                            begin
                              FBStartTime_bytes := ColumnValueByNameAsBlobBytes(sqlselect, DNT_sql_col);
                              if Length(FBStartTime_bytes) = 8 then
                              begin
                                move(FBStartTime_bytes[0], FBStartTime_double, 8);
                                FBStartTime_double := SwapDouble(FBStartTime_double);
                                FBStartTime_dt := MacAbsoluteTimeToDateTime(Trunc(FBStartTime_double));
                                variant_Array[g] := FBStartTime_dt;
                              end;
                            end;
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

                          // Garmin Android - Read JSON
                          if Item^.fi_Process_ID = 'DNT_GARMIN_CONNECT' then // noslz
                          begin
                            if DNT_sql_col = 'CACHED_VAL' then
                              tmp_garmin_cache_str := ColumnValueByNameAsText(sqlselect, DNT_sql_col);
                            if DNT_sql_col = 'LATITUDE' then // noslz
                            begin
                              tmp_garmin_lat_str := trim(PerlMatch('(?<="startlatitude":)(.*)(?=,)', tmp_garmin_cache_str)); // noslz
                              if trim(tmp_garmin_lat_str) = '' then
                                tmp_garmin_lat_str := trim(PerlMatch('(?<="latitude":)(.*)(?=,)', tmp_garmin_cache_str));
                              variant_Array[g] := tmp_garmin_lat_str;
                            end;
                            if DNT_sql_col = 'LONGITUDE' then // noslz
                            begin
                              tmp_garmin_lat_str := trim(PerlMatch('(?<="startlongitude":)(.*)(?=,)', tmp_garmin_cache_str)); // noslz
                              if trim(tmp_garmin_lat_str) = '' then
                                tmp_garmin_lat_str := trim(PerlMatch('(?<="longitude":)(.*)(?=,)', tmp_garmin_cache_str)); // noslz
                              variant_Array[g] := tmp_garmin_lat_str;
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
              FindEntries_StringList.Add('**\*.sqlite*'); // noslz
              FindEntries_StringList.Add('**\cache-database*'); // noslz
              FindEntries_StringList.Add('**\exercise_db*'); // noslz
              FindEntries_StringList.Add('**\fitbit-db*'); // noslz
              FindEntries_StringList.Add('**\gcm_cache.db*'); // noslz
              FindEntries_StringList.Add('**\MobileSync\**\*'); // noslz - iTunes folder

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

            Ref_Num := 1;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_HEART_RATE_IOS'));
            Ref_Num := 2;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_STEPS_IOS'));
            Ref_Num := 3;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_DISTANCE_IOS'));
            Ref_Num := 4;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_FLIGHTS_CLIMBED_IOS'));
            Ref_Num := 5;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_HEIGHT_IOS'));
            Ref_Num := 6;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_WEIGHT_IOS'));
            Ref_Num := 7;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_LATITUDE_IOS'));
            Ref_Num := 8;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, AppleHealth.GetTable('APPLE_HEALTH_LONGITUDE_IOS'));
            Ref_Num := 9;  if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Fitbit.GetTable('FITBIT_ACTIVITY_LOG_IOS'));
            Ref_Num := 10; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Fitbit.GetTable('FITBIT_EVENT_ANDROID'));
            Ref_Num := 11; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Fitbit.GetTable('FITBIT_PROFILE_ANDROID'));
            Ref_Num := 12; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Fitbit.GetTable('FITBIT_USER_IOS'));
            Ref_Num := 13; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Garmin.GetTable('GARMIN_ACTIVITIES_ANDROID'));
            Ref_Num := 14; if(TestForDoProcess(Ref_Num)) then DoProcess(ArtifactConnect_ProgramFolder[Ref_Num], Ref_Num, Garmin.GetTable('GARMIN_ACTIVITY_DETAILS_ANDROID'));

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
