unit validation_test_email;

interface

uses
  Classes, Clipbrd, Common, DataEntry, DataStorage, Email, Graphics, Math, PropertyList, Regex, SysUtils;

const
  ATRY_EXCEPT_STR = 'TryExcept: '; // noslz
  BS = '\';
  CHAR_LENGTH = 100;
  COMMA = ',';
  DCR = #13#10 + #13#10;
  FIELDBYNAME_HASH_MD5 = 'HASH (MD5)'; // noslz
  FLDR_ERROR = '-- ERROR --';
  FLDR_GLB = '\\Fexlabs\share\Global_Output';
  FLDR_LOC = 'C:\Forensic_Explorer_Testing_Folder';
  FLDR_VALIDATION = 'VALIDATION_EMAIL';
  FLDR_WARNING = '-- WARNING --';
  FORMAT_STR = '%-49s %-41s %-30s';
  HYPHEN = ' - ';
  MAX_DIR_LEVEL_INT = 4;
  NumberOfSearchItems = 1000;
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
  SCRIPT_NAME = 'Email Validation';
  SCRIPT_OUTPUT = 'Script Output';
  SPACE = ' ';
  TESTING_FOLDER_PATH = 'C:\Forensic_Explorer_Testing_Email';
  TSWT = 'The script will terminate.';
  UNALLOCATED_SEARCH = 'Artifact Carve';

type
  Item_Record = class
    RecHash: string;
    RecEntry: TEntry;
    ProcessInt: integer;
  end;

function RPad(const AString: string; AChars: integer): string;
procedure ConsoleLog(AString: string);
procedure MessageUsr(AString: string);

implementation

type
  PSQL_FileSearch = ^TSQL_FileSearch;

  TSQL_FileSearch = record
    Device_Logical_Size: int64;
    Device_Name: string;
    Email_File_Signature: string;
    expected_attachment_count_str: string;
    expected_calendar_count_str: string;
    expected_contact_count_str: string;
    expected_mail_count_str: string;
    expected_EM_ext_avi_count_str: string;
    expected_EM_ext_exe_count_str: string;
    expected_EM_ext_jpg_count_str: string;
    expected_EM_ext_msg_count_str: string;
    expected_EM_ext_txt_count_str: string;
    expected_EM_ext_wmv_count_str: string;
    expected_EM_ext_zip_count_str: string;
    expected_EM_file_size: int64;
    expected_EM_sig_avi_count_str: string;
    expected_EM_sig_edb_count_str: string;
    expected_EM_sig_exe_count_str: string;
    expected_EM_sig_jpg_count_str: string;
    expected_EM_sig_msg_count_str: string;
    expected_EM_sig_pstemail_count_str: string;
    expected_EM_sig_txt_count_str: string;
    expected_EM_sig_wmv_count_str: string;
    expected_EM_sig_zip_count_str: string;
    expected_file_size_str: string;
    expected_folder_count_str: string;
    expected_KW_keyword1: string;
    expected_KW_keyword1_file_count_str: string;
    expected_KW_keyword1_hits_count_str: string;
    expected_KW_keyword1_regex: string;
    expected_KW_keyword1_regex_file_count_str: string;
    expected_KW_keyword1_regex_hits_count_str: string;
    expected_KW_keyword2: string;
    expected_KW_keyword2_file_count_str: string;
    expected_KW_keyword2a_hits_count_str: string;
    expected_module_count_Email: integer;
    expected_sum_total_size_str: string;
    ftk_imager_output_str: string;
    GD_Ref_Name: string;
    GD_Ref_Source: string;
    Hash_Threshold: integer;
    Image_Name: string;
    Item_Number: string;
    KW_keyword1: string;
    KW_keyword1_regex: string;
    KW_keyword2: string;
    MD5_hash: string;
  end;

var
  actual_attachement_count: integer;
  actual_calendar_count: integer;
  actual_contact_count: integer;
  actual_email_file_size: int64;
  actual_ext_avi_count: integer;
  actual_ext_exe_count: integer;
  actual_ext_jpg_count: integer;
  actual_ext_msg_count: integer;
  actual_ext_ost_count: integer;
  actual_ext_plist_count: integer;
  actual_ext_pst_count: integer;
  actual_ext_txt_count: integer;
  actual_ext_wmv_count: integer;
  actual_ext_zip_count: integer;
  actual_folder_count: integer;
  actual_mail_count: integer;
  actual_module_count_Email: integer;
  actual_partition_count: integer;
  actual_partitions_sum_size: int64;
  actual_sig_avi_count: integer;
  actual_sig_edb_count: integer;
  actual_sig_exe_count: integer;
  actual_sig_jpg_count: integer;
  actual_sig_msg_count: integer;
  actual_sig_ost_count: integer;
  actual_sig_plist_count: integer;
  actual_sig_pst_count: integer;
  actual_sig_pstemail_count: integer;
  actual_sig_txt_count: integer;
  actual_sig_wmv_count: integer;
  actual_sig_zip_count: integer;
  actual_sum_total_size_count: int64;
  actual_total_children_count: integer;
  array_of_string: array of string;
  bl_Continue: boolean;
  EmailEntryList: TDataStore;
  Field_BookmarkFolder: TDataStoreField;
  Field_Dir_Level: TDataStoreField;
  Field_Exif271Make: TDataStoreField;
  Field_MD5: TDataStoreField;
  Field_SHA1: TDataStoreField;
  Field_SHA256: TDataStoreField;
  FieldName: string;
  FileItems: array [1 .. NumberOfSearchItems] of PSQL_FileSearch;
  FileSystemEntryList: TDataStore;
  gbl_BM_Signature_Status: boolean;
  gbl_EM_Hash_Status: boolean;
  gbl_EM_Signature_Status: boolean;
  gbl_FS_Hash_Status: boolean;
  gbl_FS_Signature_Status: boolean;
  gbl_open_folder: boolean;
  gbl_print_line: boolean;
  gbl_RG_Hash_Status: boolean;
  gbl_save_file: boolean;
  gcase_name: string;
  gCompare_with_external_bl: boolean;
  gCreateScriptCode_StringList: TStringList;
  gDeviceName_str: string;
  gKnown_File_Process_StringList: TStringList;
  gMemo_StringList: TStringList;
  gPrint_Known_Email_File_StringList: TStringList;
  gPrint_UnKnown_Email_File_StringList: TStringList;
  gsave_file_glb_str: string;
  gsave_file_loc_str: string;
  gSaveFile_str: string;
  gSel_StringList: TStringList;
  gTheCurrentDevice: string;
  gUnKnown_File_Process_StringList: TStringList;
  Item: PSQL_FileSearch;
  KeywordSearchEntryList: TDataStore;
  max_sig_analysis_duration: integer;
  normal_FileSystem_count: integer;
  rpad_value: integer;
  rpad_value2: integer;
  ScriptPath_str: string;

function format_output(trunc_EntryName_str: string; md5_str: string; logical_size_str: string; source_str: string): string;
const
  FORMAT_STR = '%-49s %-33s %-7s %-30s';
  TRUNC_INT = 44;
begin
  Result := '';
  if length(trunc_EntryName_str) > TRUNC_INT then
  begin
    trunc_EntryName_str := copy(trunc_EntryName_str, 1, TRUNC_INT);
  end;
  try
    Result := format(FORMAT_STR, [trunc_EntryName_str, md5_str, logical_size_str, source_str]);
  except
    MessageUsr('Error: function format_output');
  end;
end;

procedure LoadFileItems;
const
  lFileItems: array [1 .. NumberOfSearchItems] of TSQL_FileSearch = (
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'Test Outlook.pst'; GD_Ref_Source: 'DEMO 7.E01'; MD5_hash: 'e6c36778320b687c8fbd08f6a49d9278'; expected_file_size_str: '33539072'; expected_sum_total_size_str: '18144637952'; expected_mail_count_str: '525';
    expected_folder_count_str: '15'; expected_attachment_count_str: '100'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '31'; expected_EM_sig_msg_count_str: '23';
    expected_EM_sig_pstemail_count_str: '454';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'johnthomas@yahoo.com.ost'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '075dd9844fd8abcb374c1b8da62c2b6e'; expected_file_size_str: '16818176'; expected_sum_total_size_str: '2943180800';
    expected_mail_count_str: '148'; // '174';
    expected_folder_count_str: '26'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '52' + PIPE + '6'; // 9Jun21+6;
    expected_EM_sig_pstemail_count_str: '46';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tmarythomas@gmail.com.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '07907435840ccf14d40c6179db8fb1b6'; expected_file_size_str: '130802688'; expected_sum_total_size_str: '105165361152';
    expected_mail_count_str: '690'; // '711';
    expected_folder_count_str: '21'; expected_attachment_count_str: '92'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '59'; expected_EM_sig_msg_count_str: '619' + PIPE + '12';
    // 9Jun21+12;
    expected_EM_sig_pstemail_count_str: '607'; expected_EM_sig_zip_count_str: '12';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tmarythomas@gmail.com.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '0e814ea37695afd0a407de186deb6efa'; expected_file_size_str: '143754240'; expected_sum_total_size_str: '126503731200';
    expected_mail_count_str: '753'; // '787';
    expected_folder_count_str: '34'; expected_attachment_count_str: '92'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '59'; expected_EM_sig_msg_count_str: '641' + PIPE + '34';
    // 9Jun21+34
    expected_EM_sig_pstemail_count_str: '607'; expected_EM_sig_zip_count_str: '12';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tjohnthomas@gmail.com (1).ost'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '4b5c883df28e996b20c51cb1aa1d5ccd'; expected_file_size_str: '16818176'; expected_sum_total_size_str: '3044089856';
    expected_mail_count_str: '153'; // '180';
    expected_folder_count_str: '27'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '54|6'; expected_EM_sig_pstemail_count_str: '48';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'OutlDr.Jon.Prepper@gmail.com-00000002.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '4cf235e41d6277812ca44064f5944676'; expected_file_size_str: '779264'; expected_sum_total_size_str: '128578560';
    expected_mail_count_str: '141'; // '164';
    expected_folder_count_str: '23'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '60' + PIPE + '12'; // 9Jun21+12
    expected_EM_sig_pstemail_count_str: '48';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tmarythomas@gmail.com.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '7f53dd2786c061e73d5af4e2b0544310'; expected_file_size_str: '143754240'; expected_sum_total_size_str: '126503731200';
    expected_mail_count_str: '753'; expected_folder_count_str: '34'; expected_attachment_count_str: '92'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '59';
    expected_EM_sig_msg_count_str: '641' + PIPE + '34'; // 9Jun21+34
    expected_EM_sig_pstemail_count_str: '607'; expected_EM_sig_zip_count_str: '12';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'johnthomas@yahoo.com.ost'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '9a9f25f66299e9fec0a5f55b3e90a841'; expected_file_size_str: '16818176'; expected_sum_total_size_str: '2943180800';
    expected_mail_count_str: '148'; expected_folder_count_str: '26'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '52';
    expected_EM_sig_pstemail_count_str: '46';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'OutlDr.Jon.Prepper@gmail.com-00000002.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: '9be6fdda1a6d20a3f08a458becc6fb2e'; expected_file_size_str: '779264'; expected_sum_total_size_str: '116889600';
    expected_mail_count_str: '128'; // '149';
    expected_folder_count_str: '21'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '60' + PIPE + '12'; // 9Jun21+12
    expected_EM_sig_pstemail_count_str: '48';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tjohnthomas@gmail.com.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: 'c2fe08c398e878ff1df4052b7051206c'; expected_file_size_str: '271360'; expected_sum_total_size_str: '39618560';
    expected_mail_count_str: '118'; expected_folder_count_str: '26'; expected_attachment_count_str: '0'; expected_calendar_count_str: '1'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '29' + PIPE + '24';
    // 9Jun21+24 Brett
    expected_EM_sig_pstemail_count_str: '5';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'Outlook.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: 'da694b99dc1716495148b7fc13861034'; expected_file_size_str: '271360'; expected_sum_total_size_str: '35819520'; expected_mail_count_str: '106';
    expected_folder_count_str: '25'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '25'; expected_EM_sig_pstemail_count_str: '8';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tjohnthomas@gmail.com.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: 'db45d399274c6a14dd80965993ef5ee0'; expected_file_size_str: '271360'; expected_sum_total_size_str: '39618560';
    expected_mail_count_str: '118'; expected_folder_count_str: '26'; expected_attachment_count_str: '0'; expected_calendar_count_str: '1'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '29';
    expected_EM_sig_pstemail_count_str: '5';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'OutlDr.Jon.Prepper@gmail.com-00000002.pst'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: 'e3ced4bcb5b243c7369303532d1b1e7f'; expected_file_size_str: '779264'; expected_sum_total_size_str: '128578560';
    expected_mail_count_str: '141'; expected_folder_count_str: '23'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '60';
    expected_EM_sig_pstemail_count_str: '48';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: '0tjohnthomas@gmail.com (1).ost'; GD_Ref_Source: 'Op Payback PST-OST.L01'; MD5_hash: 'e6c3053fe67bf9a36cb3361115d4f59e'; expected_file_size_str: '16818176'; expected_sum_total_size_str: '3044089856';
    expected_mail_count_str: '153'; expected_folder_count_str: '27'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '54';
    expected_EM_sig_pstemail_count_str: '48';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'news-l.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '07c6a76ec9ab3b99bff9386dafab8ac2'; expected_file_size_str: '1042068'; expected_sum_total_size_str: '156310200'; expected_mail_count_str: '148';
    expected_folder_count_str: '0'; expected_attachment_count_str: '2'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'hangcheck-timer-users.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '0a8f40ec1425a23be71d40cb1023c155'; expected_file_size_str: '11997'; expected_sum_total_size_str: '59985'; expected_mail_count_str: '4';
    expected_folder_count_str: '0'; expected_attachment_count_str: '1'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'synckolab.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '182e9e6223dfc715137707a49e522c1a'; expected_file_size_str: '8822500'; expected_sum_total_size_str: '14521835000';

    expected_mail_count_str: '1511'; expected_folder_count_str: '0'; expected_attachment_count_str: '135'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '9';
    expected_EM_sig_zip_count_str: '4';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'rcaus-l.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '1ddc6846e15bfd5274c9c7e32a7e57ae'; expected_file_size_str: '992936'; expected_sum_total_size_str: '49646800'; expected_mail_count_str: '38';
    expected_folder_count_str: '0'; expected_attachment_count_str: '12'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'mozbraille.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '2106024c970936356117ac32d046d786'; expected_file_size_str: '7500'; expected_sum_total_size_str: '30000'; expected_mail_count_str: '4'; expected_folder_count_str: '0';
    expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'webcorpus.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '26a4421c89b9570e12886be137adff5b'; expected_file_size_str: '12416'; expected_sum_total_size_str: '49664'; expected_mail_count_str: '4'; expected_folder_count_str: '0';
    expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'ansol-imprensa.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '3b5e6350dcfd19ce6bc59203a2bf1377'; expected_file_size_str: '6838283'; expected_sum_total_size_str: '1005227601'; expected_mail_count_str: '125';
    expected_folder_count_str: '0'; expected_attachment_count_str: '22'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '2';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'crt.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '3ca600634bba2fe3ec253288a3a69ef8'; expected_file_size_str: '246116494'; expected_sum_total_size_str: '59560191548'; expected_mail_count_str: '121';
    expected_folder_count_str: '0'; expected_attachment_count_str: '121'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'oracleasm-users.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '48b8af7d0600cd65f6c3d1c118656f02'; expected_file_size_str: '578115'; expected_sum_total_size_str: '61280190'; expected_mail_count_str: '104';
    expected_folder_count_str: '0'; expected_attachment_count_str: '2'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'refseq-announce.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '593247b3cb5f9300c937186b065ce511'; expected_file_size_str: '4774994'; expected_sum_total_size_str: '668499160'; expected_mail_count_str: '135';
    expected_folder_count_str: '0'; expected_attachment_count_str: '5'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '4';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'alife-announce.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '5eaa9a3d7372cffa3ea929b5e1d7e277'; expected_file_size_str: '13487384'; expected_sum_total_size_str: '28863001760'; expected_mail_count_str: '2132';
    expected_folder_count_str: '0'; expected_attachment_count_str: '8'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'iptel-l.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '5ecf724a881269096a206d9bd2cb0490'; expected_file_size_str: '12454958'; expected_sum_total_size_str: '7223875640'; expected_mail_count_str: '535';
    expected_folder_count_str: '0'; expected_attachment_count_str: '45'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '1'; expected_EM_sig_zip_count_str: '1';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'middle-l.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '5f0cfb753d6060db52bcbd676e27863c'; expected_file_size_str: '16841412'; expected_sum_total_size_str: '6197639616'; expected_mail_count_str: '281';
    expected_folder_count_str: '0'; expected_attachment_count_str: '87'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '2';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'sympython.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '6fed6a924ed639fbcd1bdad4c7e6dcd7'; expected_file_size_str: '18542'; expected_sum_total_size_str: '129794'; expected_mail_count_str: '7';
    expected_folder_count_str: '0'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'mapserver-ottawa.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '82b877400e9463e423fff1dade53af73'; expected_file_size_str: '139346'; expected_sum_total_size_str: '5991878'; expected_mail_count_str: '43';
    expected_folder_count_str: '0'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'mozplugger.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '8cc6f7481fa83a982e972082c0633b83'; expected_file_size_str: '846228'; expected_sum_total_size_str: '185323932'; expected_mail_count_str: '209';
    expected_folder_count_str: '0'; expected_attachment_count_str: '10'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'gnusto.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: '98612fc2daa545504e0f862d4513c581'; expected_file_size_str: '3883'; expected_sum_total_size_str: '7766'; expected_mail_count_str: '2'; expected_folder_count_str: '0';
    expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'lebanon-events.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'a8fbd9ea334b8f3e3ceb4b4473c7d156'; expected_file_size_str: '190563227'; expected_sum_total_size_str: '226007987222'; expected_mail_count_str: '838';
    expected_folder_count_str: '0'; expected_attachment_count_str: '348'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '137';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'ietab.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'aa2bebb7344a818ee5526cf7e3a31760'; expected_file_size_str: '963399'; expected_sum_total_size_str: '233142558'; expected_mail_count_str: '221';
    expected_folder_count_str: '0'; expected_attachment_count_str: '21'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_zip_count_str: '4';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'modifyheaders.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'acaeb543ea9b75ec8aa092a70c853203'; expected_file_size_str: '797469'; expected_sum_total_size_str: '112443129'; expected_mail_count_str: '140';
    expected_folder_count_str: '0'; expected_attachment_count_str: '1'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'privacyfox.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'c711da7f0163149161f49dc6bfee3a99'; expected_file_size_str: '100772'; expected_sum_total_size_str: '2922388'; expected_mail_count_str: '29';
    expected_folder_count_str: '0'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'discuss.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'd24aaeacd05c5ab071322d082990218d'; expected_file_size_str: '2368928'; expected_sum_total_size_str: '1165512576'; expected_mail_count_str: '474';
    expected_folder_count_str: '0'; expected_attachment_count_str: '18'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '1'; expected_EM_sig_zip_count_str: '1';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'shapelib.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'd2fed6f7b12f3988580577a5e039878d'; expected_file_size_str: '4006105'; expected_sum_total_size_str: '2632010985'; expected_mail_count_str: '644';
    expected_folder_count_str: '0'; expected_attachment_count_str: '13'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '2'; expected_EM_sig_zip_count_str: '3';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'minimizetotray.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'e2e8c690916b620a6c573544fa9af101'; expected_file_size_str: '13072072'; expected_sum_total_size_str: '19425098992'; expected_mail_count_str: '1389';
    expected_folder_count_str: '0'; expected_attachment_count_str: '97'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '15'; expected_EM_sig_zip_count_str: '19';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'deskcut.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'f4a883faa87ac5a04da1fd59f1ef15e7'; expected_file_size_str: '811104'; expected_sum_total_size_str: '94088064'; expected_mail_count_str: '108';
    expected_folder_count_str: '0'; expected_attachment_count_str: '8'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '6';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'greasemonkey.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'f8bb316b5e8a14829c2626833de429da'; expected_file_size_str: '35809520'; expected_sum_total_size_str: '353153486240'; expected_mail_count_str: '9584';
    expected_folder_count_str: '0'; expected_attachment_count_str: '278'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '12'; expected_EM_sig_zip_count_str: '75';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'foxhunt.mbox'; GD_Ref_Source: 'D:\MBOX'; MD5_hash: 'f98ac31fd890db76f800dbce7570a238'; expected_file_size_str: '60618'; expected_sum_total_size_str: '1515450'; expected_mail_count_str: '25';
    expected_folder_count_str: '0'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0';),
    // =================================================================================================================
    (GD_Ref_Name: 'priv1.edb'; GD_Ref_Source: 'priv1.edb'; MD5_hash: '88e5dd1f4540ba7177cc1de0a8d50e4e'; expected_file_size_str: '448929792'; expected_sum_total_size_str: '7119128641536'; expected_mail_count_str: '17810'; // '17886';
    expected_folder_count_str: '432'; expected_attachment_count_str: '3124'; expected_calendar_count_str: '154'; // '78';
    expected_contact_count_str: '265'; expected_EM_sig_msg_count_str: '0'; // '17886';
    ),
    // =================================================================================================================
    (GD_Ref_Name: 'test@test.com.pst'; GD_Ref_Source: 'GDH_Old_Asus_256gb_Jun_2020.E01'; MD5_hash: '9ac358e04d43db38e8bcc95d585b2fe2'; expected_file_size_str: '271360'; expected_sum_total_size_str: '28221440'; expected_mail_count_str: '84';
    expected_folder_count_str: '19'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '12';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'graham@getdata.com (1).ost'; GD_Ref_Source: 'GDH_Old_Asus_256gb_Jun_2020.E01'; MD5_hash: 'c2023b7ccbbb90f14d65c63f7a259f19'; expected_file_size_str: '3536068608'; expected_sum_total_size_str: '352570792697856';
    expected_mail_count_str: '71594'; expected_folder_count_str: '152'; expected_attachment_count_str: '27795'; expected_calendar_count_str: '116'; expected_contact_count_str: '5'; expected_EM_sig_jpg_count_str: '5150';
    expected_EM_sig_msg_count_str: '71238'; expected_EM_sig_zip_count_str: '94';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'Internet Calendar Subscriptions.pst'; GD_Ref_Source: 'GDH_Old_Asus_256gb_Jun_2020.E01'; MD5_hash: 'ccf8394ec2cea2a1fc6e2ed8f1fbfb8f'; expected_file_size_str: '525312'; expected_sum_total_size_str: '29942784';
    expected_mail_count_str: '48'; expected_folder_count_str: '8'; expected_attachment_count_str: '0'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_msg_count_str: '8';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'Test Outlook.pst'; GD_Ref_Source: 'GDH_Old_Asus_256gb_Jun_2020.E01'; MD5_hash: 'e6c36778320b687c8fbd08f6a49d9278'; expected_file_size_str: '33539072'; expected_sum_total_size_str: '21498545152';
    expected_mail_count_str: '525'; expected_folder_count_str: '15'; expected_attachment_count_str: '100'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '31';
    expected_EM_sig_msg_count_str: '23';),
    // =================================================================================================================
    (GD_Ref_Name: 'Outlook.pst'; GD_Ref_Source: '1tb_hp_laptop.E01'; MD5_hash: '485019ae16ab4bf21082a9ec78a834a0'; expected_file_size_str: '271360'; expected_sum_total_size_str: '41518080'; expected_mail_count_str: '123';
    expected_folder_count_str: '26'; expected_attachment_count_str: '0'; expected_calendar_count_str: '1'; expected_contact_count_str: '2'; expected_EM_sig_msg_count_str: '35' + PIPE + '32'; // 9Jun21+32
    ),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'Outlook.pst'; GD_Ref_Source: '1tb_hp_laptop.E01'; MD5_hash: '48c24419fade0ca5363048f3b115cb3a'; expected_file_size_str: '1768031232'; expected_sum_total_size_str: '18019774316544'; expected_mail_count_str: '5062';
    expected_folder_count_str: '51'; expected_attachment_count_str: '4197'; expected_calendar_count_str: '180'; expected_contact_count_str: '694'; expected_EM_sig_avi_count_str: '1'; expected_EM_sig_jpg_count_str: '2595';
    expected_EM_sig_msg_count_str: '4927' + PIPE + '98'; // 9Jun21+98
    expected_EM_sig_wmv_count_str: '1'; expected_EM_sig_zip_count_str: '4';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'archive.pst'; GD_Ref_Source: '1tb_hp_laptop.E01'; MD5_hash: '5c6cf241aad6754b998f46eee6be67c6'; expected_file_size_str: '3634578432'; expected_sum_total_size_str: '76322512493568'; expected_mail_count_str: '8360';
    expected_folder_count_str: '13'; expected_attachment_count_str: '10358'; expected_calendar_count_str: '2197'; expected_contact_count_str: '70'; expected_EM_sig_avi_count_str: '2'; expected_EM_sig_jpg_count_str: '6963';
    expected_EM_sig_msg_count_str: '8309' + PIPE + '13'; // 9Jun21+13
    expected_EM_sig_wmv_count_str: '66'; expected_EM_sig_zip_count_str: '18';),
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (GD_Ref_Name: 'ceannis-mailbackup.pst'; GD_Ref_Source: 'Jesper Laptop PST.E01'; MD5_hash: '7e2b7d51274a6c1a43727d2d7564af65'; expected_file_size_str: '14450688'; expected_sum_total_size_str: '3511517184'; expected_mail_count_str: '220';
    expected_folder_count_str: '6'; expected_attachment_count_str: '16'; expected_calendar_count_str: '0'; expected_contact_count_str: '0'; expected_EM_sig_jpg_count_str: '8'; expected_EM_sig_msg_count_str: '54|1';
    expected_EM_sig_pstemail_count_str: '53';), );

var
  iIdx: integer;
begin
  for iIdx := Low(lFileItems) to High(lFileItems) do
    FileItems[iIdx] := @lFileItems[iIdx];
end;

// ------------------------------------------------------------------------------
// Procedure: Main Proc
// ------------------------------------------------------------------------------
procedure MainProc;
var
  Match_StringList: TStringList;
  Match_Unknown_StringList: TStringList;
begin
  Match_StringList := TStringList.Create;
  Match_Unknown_StringList := TStringList.Create;
  try
    // Copy the Known File Process StringList into the Match List from the Listbox
    Match_StringList.assign(gKnown_File_Process_StringList);

    // Copy the UnKnown File Process StringList into the Match List from the Listbox
    Match_Unknown_StringList.assign(gUnKnown_File_Process_StringList);

    // Run the Signature Analysis before the count -----------------------------
    if (EmailEntryList.Count > 1) then
      SignatureAnalysis('Email')
    else
      ConsoleLog(format('%-49s %-41s', ['Signature Analysis Email', IntToStr(EmailEntryList.Count)]));

    // Process Known - Listbox matches =========================================
    if assigned(Match_StringList) and (Match_StringList.Count > 0) then
    begin
      gbl_save_file := True;
      count_email_messages(Match_StringList)
    end
    else
    begin
      gbl_save_file := False;
    end;

    // Process Unknown - Listbox matches =======================================
    if assigned(Match_Unknown_StringList) and (Match_Unknown_StringList.Count > 0) then
      count_email_messages(Match_Unknown_StringList);

  finally
    FreeAndNil(Match_StringList);
    FreeAndNil(Match_Unknown_StringList);
  end;
end;

// Procedure: Save Results
procedure SaveResults;
begin
  if gbl_save_file then
  begin
    gSaveFile_str := CreateFileName(gDeviceName_str);
    Save_StringList_To_File(gMemo_StringList, gSaveFile_str);
  end;
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
  AChars := AChars - length(AString);
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
    Result := (format('%1.0ngb', [asize / (1024 * 1024 * 1024)]))
  else if (asize < 1073741824) and (asize > 1048576) then
    Result := (format('%1.0nmb', [asize / (1024 * 1024)]))
  else if asize < 1048576 then
    Result := (format('%1.0nkb', [asize / (1024)]));
end;

// ------------------------------------------------------------------------------
// Function: Columns, Create and Show Hash
// ------------------------------------------------------------------------------
function CreateAndShowHashField(aDataStore: TDataStore; const FieldName: string; ModuleName: string): TDataStoreField;
var
  ViewerName: string;
begin
  if (not bl_Continue) or (not Progress.isRunning) then
    Exit;
  ViewerName := '';
  if ModuleName = 'Email' then
    ViewerName := 'vwEmailTable';
  if ModuleName = 'FileSystem' then
    ViewerName := 'vwFSTable';
  Result := aDataStore.DataFields.Add(FieldName, ftBytes);
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
      ConsoleLog(format('%-49s %-41s %-38s', ['Launching hash files:', IntToStr(hEntryList.Count), ''])); // noslz
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
                ConsoleLog(format('%-49s %-41s %-38s', [anEntry.EntryName, 'Matched', 'OK'])) // noslz
              else
                ConsoleLog(format('%-49s %-41s %-38s', [anEntry.EntryName, 'FEX: ' + Field_MD5.AsString[anEntry], 'FTK: ' + linelist[0]]));
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

        anEntry := aDataStore.Next;
        Progress.IncCurrentProgress;
      end;

      sig_percentage := (sig_count / total_files_count) * 100;
      md5_percentage := (md5_count / total_files_count) * 100;

      if sig_percentage > 80 then
      begin
        sig_msg := 'RUN';
        if ModuleName = 'Email' then
          gbl_EM_Signature_Status := True;
      end
      else
        sig_msg := RS_NOT_RUN;

      if md5_percentage > 80 then
      begin
        hash_msg := 'RUN';
        if ModuleName = 'Email' then
          gbl_EM_Hash_Status := True;
      end
      else
        hash_msg := RS_NOT_RUN;

      the_sig_string := (format('%-5s %-43s %-41s %-9s %-8s', [RS_SIG, ModuleName, IntToStr(sig_count) + '/' + IntToStr(total_files_count), FormatFloat('00.00', sig_percentage) + '%', '' { sig_msg } ])); // noslz
      the_hash_string := (format('%-5s %-43s %-41s %-9s %-8s', ['Hash ', ModuleName, IntToStr(md5_count) + '/' + IntToStr(total_files_count), FormatFloat('00.00', md5_percentage) + '%', '' { hash_msg } ])); // noslz

      if ModuleName = 'Email' then
      begin
        array_of_string[2] := the_sig_string;
        array_of_string[3] := the_hash_string;
      end;

    end
    else
    begin
      no_files_str := (format('%-43s %-16s', [ModuleName, '0']));

      if ModuleName = 'Email' then
      begin
        array_of_string[2] := 'Sig.  ' + no_files_str;
        array_of_string[3] := 'Hash. ' + no_files_str;
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
  if actual_num >= 0 then
  begin
    if expected_FS_num >= 0 then
    begin
      if expected_FS_num <> actual_num then
      begin
        more_or_less_str := '';
        if (actual_num < expected_FS_num) then
          more_or_less_str := 'Less'; // noslz
        if (actual_num > expected_FS_num) then
          more_or_less_str := 'More'; // noslz
        message_str := format('%-29s %-15s %-15s', [RS_WARNING_EXPECTED + IntToStr(expected_FS_num), ' Got: ' + IntToStr(actual_num), '(Diff: ' + IntToStr(abs(expected_FS_num - actual_num)) + SPACE + more_or_less_str + ')']); // noslz

        // Exceptions
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
      message_str := format('%-29s %-15s %-15s', [RS_WARNING_EXPECTED + expected_FS_str, ' Got: ' + actual_str, '(Diff: ' + theResult_str + SPACE + more_or_less_str + ')']); // noslz
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
// Procedure: Reporting
// ------------------------------------------------------------------------------
procedure Reporting(ModuleName: string);
begin
  // Report Email
  if ModuleName = 'Email' then
  begin
    Progress.DisplayMessageNow := 'Reporting Email' + RUNNING;
    gbl_print_line := False;

    ConsoleLog(stringofchar('=', CHAR_LENGTH));
    ConsoleLog(RPad(Item^.GD_Ref_Name, rpad_value) + 'MD5: ' + Item^.MD5_hash); // noslz
    report_as_rgx('Email File Size', Item^.expected_file_size_str, IntToStr(actual_email_file_size));
    // ConsoleLog(RPad('---------------', rpad_value) + '-----'); //noslz
    ConsoleLog(RPad(stringofchar('-', 15), rpad_value) + (RPad(stringofchar('-', 7), rpad_value2) + stringofchar('-', 2)));
    report_as_rgx('Total Mail Count', Item^.expected_mail_count_str, IntToStr(actual_mail_count));
    report_as_rgx('Total Folder Count', Item^.expected_folder_count_str, IntToStr(actual_folder_count));
    report_as_rgx('Total Calendar Count', Item^.expected_calendar_count_str, IntToStr(actual_calendar_count));
    report_as_rgx('Total Contact Count', Item^.expected_contact_count_str, IntToStr(actual_contact_count));
    report_as_rgx('Total Other Count', IntToStr(normal_FileSystem_count), IntToStr(normal_FileSystem_count));
    report_as_rgx('Total Attachment Count', Item^.expected_attachment_count_str, IntToStr(actual_attachement_count));

    // Extension
    report_as_rgx('  AVI' + SPACE + RS_EXT, Item^.expected_EM_ext_avi_count_str, IntToStr(actual_ext_avi_count));
    report_as_rgx('  EXE' + SPACE + RS_EXT, Item^.expected_EM_ext_exe_count_str, IntToStr(actual_ext_exe_count));
    report_as_rgx('  JPG' + SPACE + RS_EXT, Item^.expected_EM_ext_jpg_count_str, IntToStr(actual_ext_jpg_count));
    report_as_rgx('  MSG' + SPACE + RS_EXT, Item^.expected_EM_ext_msg_count_str, IntToStr(actual_ext_msg_count));
    report_as_rgx('  TXT' + SPACE + RS_EXT, Item^.expected_EM_ext_txt_count_str, IntToStr(actual_ext_txt_count));
    report_as_rgx('  WMV' + SPACE + RS_EXT, Item^.expected_EM_ext_wmv_count_str, IntToStr(actual_ext_wmv_count));
    report_as_rgx('  ZIP' + SPACE + RS_EXT, Item^.expected_EM_ext_zip_count_str, IntToStr(actual_ext_zip_count));
    // Signature
    report_as_rgx('  AVI' + SPACE + RS_SIG, Item^.expected_EM_sig_avi_count_str, IntToStr(actual_sig_avi_count));
    report_as_rgx('  EDB' + SPACE + RS_SIG, Item^.expected_EM_sig_edb_count_str, IntToStr(actual_sig_edb_count));
    report_as_rgx('  EXE' + SPACE + RS_SIG, Item^.expected_EM_sig_exe_count_str, IntToStr(actual_sig_exe_count));
    report_as_rgx('  JPG' + SPACE + RS_SIG, Item^.expected_EM_sig_jpg_count_str, IntToStr(actual_sig_jpg_count));
    // report_as_rgx('  MSG'       + SPACE + RS_SIG, Item^.expected_EM_sig_msg_count_str,      IntToStr(actual_sig_msg_count));
    report_as_rgx('  PST Email' + SPACE + RS_SIG, Item^.expected_EM_sig_pstemail_count_str, IntToStr(actual_sig_pstemail_count));
    report_as_rgx('  TXT' + SPACE + RS_SIG, Item^.expected_EM_sig_txt_count_str, IntToStr(actual_sig_txt_count));
    report_as_rgx('  WMV' + SPACE + RS_SIG, Item^.expected_EM_sig_wmv_count_str, IntToStr(actual_sig_wmv_count));
    report_as_rgx('  ZIP' + SPACE + RS_SIG, Item^.expected_EM_sig_zip_count_str, IntToStr(actual_sig_zip_count));
    gbl_print_line := False;
  end;
end;

procedure initializeCounters;
begin
  actual_attachement_count := 0;
  actual_calendar_count := 0;
  actual_contact_count := 0;
  actual_ext_avi_count := 0;
  actual_ext_exe_count := 0;
  actual_ext_jpg_count := 0;
  actual_ext_msg_count := 0;
  actual_ext_ost_count := 0;
  actual_ext_plist_count := 0;
  actual_ext_pst_count := 0;
  actual_ext_txt_count := 0;
  actual_ext_wmv_count := 0;
  actual_ext_zip_count := 0;
  actual_folder_count := 0;
  actual_mail_count := 0;
  actual_module_count_Email := 0;
  actual_partition_count := 0;
  actual_partitions_sum_size := 0;
  actual_sig_avi_count := 0;
  actual_sig_edb_count := 0;
  actual_sig_exe_count := 0;
  actual_sig_jpg_count := 0;
  actual_sig_msg_count := 0;
  actual_sig_pstemail_count := 0;
  actual_sig_txt_count := 0;
  actual_sig_wmv_count := 0;
  actual_sig_zip_count := 0;
  actual_sum_total_size_count := 0;
  actual_total_children_count := 0;
  normal_FileSystem_count := 0;
end;

procedure count_email_messages(aStringList: TStringList);
var
  aDataStore: TDataStore;
  anEntry: TEntry;
  childEntry: TEntry;
  ChildCount: integer;
  Children_TList: TList;
  DeterminedFileDriverInfo: TFileTypeInformation;
  DeviceEntry: TEntry;
  fileext: string;
  i, j: integer;
  process_int: integer;
  sig_str: string;

  procedure countfiletypes(aEntry: TEntry);
  begin
    fileext := UpperCase(aEntry.EntryNameExt); // Matches GUI display. This does not: afileext := extractfileext(Entry.EntryName);
    if (fileext = '.JPG') then
      actual_ext_jpg_count := actual_ext_jpg_count + 1
    else if (fileext = '.AVI') then
      actual_ext_avi_count := actual_ext_avi_count + 1
    else if (fileext = '.EXE') then
      actual_ext_exe_count := actual_ext_exe_count + 1
    else if (fileext = '.TXT') then
      actual_ext_txt_count := actual_ext_txt_count + 1
    else if (fileext = '.WMV') then
      actual_ext_wmv_count := actual_ext_wmv_count + 1
    else if (fileext = '.ZIP') then
      actual_ext_zip_count := actual_ext_zip_count + 1
    else if (fileext = '.PLIST') then
      actual_ext_plist_count := actual_ext_plist_count + 1
    else if (fileext = '.OST') then
      actual_ext_ost_count := actual_ext_ost_count + 1
    else if (fileext = '.PST') then
      actual_ext_pst_count := actual_ext_pst_count + 1;

    // Determined
    DetermineFileType(aEntry);
    DeterminedFileDriverInfo := aEntry.DeterminedFileDriverInfo;
    sig_str := UpperCase(DeterminedFileDriverInfo.ShortDisplayName);
    if sig_str <> '' then
    begin
      if (sig_str = 'JPG') then
        actual_sig_jpg_count := actual_sig_jpg_count + 1;
      if (sig_str = 'AVI') then
        actual_sig_avi_count := actual_sig_avi_count + 1;
      if (sig_str = 'EDB Email') then
        actual_sig_edb_count := actual_sig_edb_count + 1;
      if (sig_str = 'EXE/DLL') then
        actual_sig_exe_count := actual_sig_exe_count + 1;
      if (sig_str = 'TXT') then
        actual_sig_txt_count := actual_sig_txt_count + 1;
      if (sig_str = 'WMV') then
        actual_sig_wmv_count := actual_sig_wmv_count + 1;
      if (sig_str = 'ZIP') then
        actual_sig_zip_count := actual_sig_zip_count + 1;
      if (sig_str = 'PLIST (BINARY)') then
        actual_sig_plist_count := actual_sig_plist_count + 1;
      if (sig_str = 'OST') then
        actual_sig_ost_count := actual_sig_ost_count + 1;
      if (sig_str = 'PST') then
        actual_sig_pst_count := actual_sig_pst_count + 1;
      if (sig_str = 'OUTLOOK MSG') then
        actual_sig_msg_count := actual_sig_msg_count + 1;
      if (sig_str = 'PST EMAIL') then
        actual_sig_pstemail_count := actual_sig_pstemail_count + 1;
    end;
  end;

var
  Enum: TEntryEnumerator;
begin
  Progress.DisplayMessageNow := 'Counting email' + RUNNING;
  aDataStore := GetDataStore(DATASTORE_EMAIL);
  if aDataStore = nil then
    Exit;
  try
    for i := 0 to aStringList.Count - 1 do
    begin
      if not Progress.isRunning then
        break;

      process_int := Item_Record(aStringList.Objects[i]).ProcessInt;
      if (process_int >= 0) and (process_int <= NumberOfSearchItems) then
        Item := FileItems[process_int];

      anEntry := Item_Record(aStringList.Objects[i]).RecEntry;
      Children_TList := aDataStore.Children(anEntry, True); // True sets the .Children to be full recursive
      try
        if assigned(Children_TList) and (Children_TList.Count > 0) then
        begin
          actual_total_children_count := Children_TList.Count;
          actual_email_file_size := anEntry.LogicalSize;

          for j := 0 to Children_TList.Count - 1 do
          begin
            actual_sum_total_size_count := actual_sum_total_size_count + anEntry.LogicalSize;
          end;

          ChildCount := Children_TList.Count;
          Progress.Initialize(ChildCount, 'Counting Email' + RUNNING);
          for j := 0 to ChildCount - 1 do
          begin
            Progress.IncCurrentProgress;
            if not Progress.isRunning then
              break;
            childEntry := TEntry(Children_TList[j]);

            if childEntry.isDirectory then
            begin
              actual_folder_count := actual_folder_count + 1;
              continue;
            end;

            countfiletypes(childEntry);

            if isMailEntry(childEntry) then
            begin
              actual_mail_count := actual_mail_count + 1;

              if childEntry.ChildrenCount > 0 then
              begin
                Enum := childEntry.ChildEnumerator;
                while Enum.MoveNext do
                begin
                  actual_attachement_count := actual_attachement_count + 1;
                  countfiletypes(Enum.Current);
                end;
                Enum.free;
              end;
              continue;
            end
            else if isCalendarEvent(childEntry) then
            begin
              actual_calendar_count := actual_calendar_count + 1;
              continue;
            end
            else if isContact(childEntry) then
            begin
              actual_contact_count := actual_contact_count + 1;
              continue;
            end
            else if isMailAttachment(childEntry) or isOrphanedAttachment(childEntry) then
              actual_attachement_count := actual_attachement_count + 1
            else
              normal_FileSystem_count := normal_FileSystem_count + 1;

          end;
        end;
      finally
        Children_TList.free;
      end;

      // Reporting
      if process_int < 1000000 then
        Reporting('Email');

      DeviceEntry := GetDeviceEntry(anEntry);
      if process_int >= 1000000 then
      begin
        gCreateScriptCode_StringList.Add('//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        gCreateScriptCode_StringList.Add('    (GD_Ref_Name:                                                     ''' + anEntry.EntryName + ''';');
        gCreateScriptCode_StringList.Add('    GD_Ref_Source:                                                    ''' + DeviceEntry.EntryName + ''';');
        gCreateScriptCode_StringList.Add('    MD5_hash:                                                         ''' + Field_MD5.AsString[anEntry] + ''';');
        gCreateScriptCode_StringList.Add('    expected_file_size_str:                                           ''' + IntToStr(actual_email_file_size) + ''';');
        gCreateScriptCode_StringList.Add('    expected_sum_total_size_str:                                      ''' + IntToStr(actual_sum_total_size_count) + ''';');
        gCreateScriptCode_StringList.Add('    expected_mail_count_str:                                          ''' + IntToStr(actual_mail_count) + ''';');
        gCreateScriptCode_StringList.Add('    expected_folder_count_str:                                        ''' + IntToStr(actual_folder_count) + ''';');
        gCreateScriptCode_StringList.Add('    expected_attachment_count_str:                                    ''' + IntToStr(actual_attachement_count) + ''';');
        gCreateScriptCode_StringList.Add('    expected_calendar_count_str:                                      ''' + IntToStr(actual_calendar_count) + ''';');
        gCreateScriptCode_StringList.Add('    expected_contact_count_str:                                       ''' + IntToStr(actual_contact_count) + ''';');

        if actual_sig_avi_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_avi_count_str:                                    ''' + IntToStr(actual_sig_avi_count) + ''';');

        if actual_sig_jpg_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_jpg_count_str:                                    ''' + IntToStr(actual_sig_jpg_count) + ''';');

        if actual_sig_msg_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_msg_count_str:                                    ''' + IntToStr(actual_sig_msg_count) + ''';');

        if actual_sig_pstemail_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_pstemamil_count_str:                              ''' + IntToStr(actual_sig_pstemail_count) + ''';');

        if actual_sig_txt_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_txt_count_str:                                    ''' + IntToStr(actual_sig_txt_count) + ''';');

        if actual_sig_wmv_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_wmv_count_str:                                    ''' + IntToStr(actual_sig_wmv_count) + ''';');

        if actual_sig_zip_count <> 0 then
          gCreateScriptCode_StringList.Add('    expected_EM_sig_zip_count_str:                                    ''' + IntToStr(actual_sig_zip_count) + ''';');

        gCreateScriptCode_StringList.Add('    ),');
      end;
      initializeCounters;

    end;
  finally
    FreeAndNil(aDataStore);
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
  was_version_str := copy(CmdLine.Params[1], 1, 12);
  if assigned(the_StringList) and (the_StringList.Count > 0) then
  begin
    ConsoleLog(stringofchar('-', CHAR_LENGTH));
    ConsoleLog(the_attribute + ' Difference:');
    ConsoleLog(format('%-8s %-40s %-42s %-30s', ['BATES', 'FILENAME (trunc)', UpperCase(the_attribute) + ' WAS - ' + was_version_str, UpperCase(the_attribute) + ' IS - ' + CurrentVersion]));
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
  for x := 1 to length(AString) do
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
    SetLength(TXT_fullpath, length(TXT_fullpath) - 4);
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
  bm_str := '';
  if (FileExists(TXT_fullpath)) then
  begin
    SetLength(TXT_fullpath, length(TXT_fullpath) - 4);
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
      if kw_Entry.isDirectory then
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
    Search_StringList.sort;
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
      if anEntry.isDirectory and (anEntry.EntryName = 'Keyword Search') or // noslz
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
    KeywordSearch_StringList.sort;
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

procedure Find_Entries_By_Path(aDataStore: TDataStore; astr: string; FoundList: TList; AllFoundListUnique: TUniqueListOfEntries);
var
  s: integer;
  fEntry: TEntry;
begin
  if assigned(aDataStore) and (aDataStore.Count > 1) then
  begin
    Progress.Log('Find: ' + astr);
    FoundList.Clear;
    aDataStore.FindEntriesByPath(nil, astr, FoundList);
    for s := 0 to FoundList.Count - 1 do
    begin
      fEntry := TEntry(FoundList[s]);
      AllFoundListUnique.Add(fEntry);
    end;
  end;
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
            if RegexMatch(LogFiles_StringList[i], ScriptName_str + '|Root Task', False) then
              continue;
            temp_SList := TStringList.Create;
            try
              try
                temp_SList.LoadFromFile(LogFiles_StringList[i]);
              except
                Progress.Log(ATRY_EXCEPT_STR + RPad('LoadFromFile:', rpad_value) + LogFiles_StringList[i]); // noslz
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

procedure FindEmailFilesByPath();
var
  FoundList, AllFoundList: TList;
  AllFoundListUnique: TUniqueListOfEntries;
  FindEntries_StringList: TStringList;
  i: integer;
  Enum: TEntryEnumerator;
  eEntry: TEntry;
  FileSystemDataStore: TDataStore;
  // TaskProgress: TPAC;
  theFileDriverInfo: TFileTypeInformation;
begin
  AllFoundList := TList.Create;
  AllFoundListUnique := TUniqueListOfEntries.Create;
  FileSystemDataStore := GetDataStore(DATASTORE_FILESYSTEM);

  try
    FoundList := TList.Create;
    FindEntries_StringList := TStringList.Create;
    try
      FindEntries_StringList.Add('**\*.ost');
      FindEntries_StringList.Add('**\*.pst');
      FindEntries_StringList.Add('**\*.mbox');
      FindEntries_StringList.Add('**\*.edb');

      // Find the files by path and add to AllFoundListUnique
      Progress.Initialize(FindEntries_StringList.Count, 'Find files by path' + RUNNING);

      for i := 0 to FindEntries_StringList.Count - 1 do
      begin
        if not Progress.isRunning then
          break;
        Find_Entries_By_Path(FileSystemDataStore, FindEntries_StringList[i], FoundList, AllFoundListUnique);
        Progress.IncCurrentProgress;
      end;

      // Move the AllFoundListUnique list into a TList
      if assigned(AllFoundListUnique) and (AllFoundListUnique.Count > 0) and assigned(AllFoundList) then
      begin
        Enum := AllFoundListUnique.GetEnumerator;
        while Enum.MoveNext do
        begin
          eEntry := Enum.Current;
          AllFoundList.Add(eEntry);
        end;

        SigTList(AllFoundList);

        for i := AllFoundList.Count - 1 downto 0 do
        begin
          eEntry := TEntry(AllFoundList[i]);
          theFileDriverInfo := eEntry.FileDriverInfo;
          if not(dtEmail in theFileDriverInfo.DriverType) then
          begin
            Progress.Log('Not Email (excluded): ' + eEntry.EntryName);
            AllFoundList.delete(i);
          end;
        end;
        Progress.Log(stringofchar('-', CHAR_LENGTH));
        Progress.Log('Email Files Found: ' + IntToStr(AllFoundList.Count));
        for i := 0 to AllFoundList.Count - 1 do
        begin
          eEntry := TEntry(AllFoundList[i]);
          Progress.Log('Email File: ' + eEntry.EntryName);
        end;
        Progress.Log(stringofchar('-', CHAR_LENGTH));
      end;

      // RunTask('TCommandTask_SendTo', DATASTORE_FILESYSTEM, AllFoundList, TaskProgress, ['module=Email']); //noslz

    finally
      FreeAndNil(FindEntries_StringList);
    end;

  finally
    Progress.Log('RunTask does not support TCommandTask_SendTo.');
    MessageUsr('Email Files:' + SPACE + IntToStr(AllFoundList.Count) + #13#10 + #13#10 + 'RunTask does not support TCommandTask_SendTo');
    FreeAndNil(AllFoundList);
  end;
end;

// ------------------------------------------------------------------------------
// Procedure: Get list of devices
// ------------------------------------------------------------------------------
Function GetDevices: string;
var
  Devices_DataStore: TDataStore;
  i: integer;
  Devices_TList: TList;
  Device_Entry: TEntry;
  Temp_TList: TList;
  temp_Entry: TEntry;
  device_count: integer;
begin
  Result := '';
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

    device_count := Devices_TList.Count;
    ConsoleLog(RPad('FEX Version:', rpad_value) + CurrentVersion); // noslz
    ConsoleLog(RPad('Date Run:', rpad_value) + DateTimeToStr(now)); // noslz
    if GetInvestigatorName <> '' then
      ConsoleLog(RPad('Investigator:', rpad_value) + GetInvestigatorName); // noslz
    ConsoleLog(RPad('Case name:', rpad_value) + gcase_name); // noslz
    ConsoleLog(RPad('Number of devices:', rpad_value) + IntToStr(Devices_TList.Count)); // noslz

    for i := 0 to Devices_TList.Count - 1 do
    begin
      Device_Entry := TEntry(Devices_TList[i]);
      ConsoleLog(RPad('Device ' + IntToStr(i) + ':', rpad_value) + Device_Entry.EntryName); // noslz
      Result := Device_Entry.EntryName;
      gTheCurrentDevice := Result;
    end;

    if Devices_TList.Count = 1 then
      Result := Device_Entry.EntryName
    else
      Result := 'Multiple_Devices';

    ConsoleLog(stringofchar('-', CHAR_LENGTH));
  finally
    Devices_TList.free;
    Temp_TList.free;
    Devices_DataStore.free;
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

procedure FexLabSave(aStringList: TStringList);
var
  j: integer;
  tmp_str: string;
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
  added_bl: boolean;
  AllEmailFiles_TList: TList;
  anEntry: TEntry;
  ARec: Item_Record;
  astr: string;
  DeterminedFileDriverInfo: TFileTypeInformation;
  DeviceEntry: TEntry;
  dir_level_int: integer;
  Enum: TEntryEnumerator;
  HashTheseFiles_TList: TList;
  i: integer;
  Level_012_Files_TList: TList;
  Level_012_UniqueListOfEntries: TUniqueListOfEntries;
  Match_StringList: TStringList;
  Match_Unknown_StringList: TStringList;
  md5_hash_str: string;
  n: integer;
  pad_str: string;

begin
  bl_Continue := True;
  gbl_BM_Signature_Status := False;
  gbl_EM_Hash_Status := False;
  gbl_EM_Signature_Status := False;
  gbl_FS_Hash_Status := False;
  gbl_FS_Signature_Status := False;
  gbl_RG_Hash_Status := False;
  gCompare_with_external_bl := False;
  max_sig_analysis_duration := 0;
  rpad_value := 50;
  rpad_value2 := 42;
  ScriptPath_str := CmdLine.Path;
  SetLength(array_of_string, 6);

  LoadFileItems;

  if not StartingChecks then
  begin
    Progress.DisplayMessageNow := ('Processing complete.');
    Exit;
  end;

  gCreateScriptCode_StringList := TStringList.Create;
  gMemo_StringList := TStringList.Create;
  gSel_StringList := TStringList.Create;
  try
    log_parameters_received;

    if (CmdLine.Params.Indexof('OPEN_TXT_FOLDER') > -1) then // noslz
    begin
      OpenFolder(TESTING_FOLDER_PATH + BS + '');
      Exit;
    end;

    // Create Lists
    FileSystemEntryList := GetDataStore(DATASTORE_FILESYSTEM);
    EmailEntryList := GetDataStore(DATASTORE_EMAIL);
    try
      if EmailEntryList.Count <= 1 then
      begin
        begin
          FindEmailFilesByPath;
        end;
        MessageUsr('There are no files in the Email module.' + SPACE + TSWT); // noslz
        Exit;
      end;

      gDeviceName_str := GetDevices;
      SetFieldNames;

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

      FieldName := 'REGDATA';
    finally
      FreeAndNil(EmailEntryList);
      FreeAndNil(FileSystemEntryList);
    end;

    // ----------------------------------------------------------------------------
    // Get a fresh copy of the Datastores to do the file count
    // ----------------------------------------------------------------------------
    EmailEntryList := GetDataStore(DATASTORE_EMAIL);
    if EmailEntryList = nil then
      Exit;
    try
      AllEmailFiles_TList := EmailEntryList.GetEntireList;

      gKnown_File_Process_StringList := TStringList.Create;
      gKnown_File_Process_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
      gKnown_File_Process_StringList.Duplicates := dupIgnore;

      gPrint_Known_Email_File_StringList := TStringList.Create;
      gPrint_UnKnown_Email_File_StringList := TStringList.Create;
      HashTheseFiles_TList := TList.Create;
      KeywordSearchEntryList := GetDataStore(DATASTORE_KEYWORDSEARCH);
      Level_012_Files_TList := TList.Create;
      Level_012_UniqueListOfEntries := TUniqueListOfEntries.Create;
      Match_StringList := TStringList.Create;
      Match_Unknown_StringList := TStringList.Create;

      gUnKnown_File_Process_StringList := TStringList.Create;
      gUnKnown_File_Process_StringList.Sorted := True; // Must be sorted or duplicates in the following line has no effect
      gUnKnown_File_Process_StringList.Duplicates := dupIgnore;

      try
        // Set Fields
        Field_Dir_Level := EmailEntryList.DataFields.FieldByName['DIR_LEVEL']; // noslz
        Field_MD5 := EmailEntryList.DataFields.FieldByName[FIELDBYNAME_HASH_MD5];

        // Locate level 0,1,2, files and put files with no hash in a hash list
        anEntry := EmailEntryList.First;
        while assigned(anEntry) and (Progress.isRunning) do
        begin
          dir_level_int := Field_Dir_Level.AsInteger(anEntry);
          if dir_level_int <= MAX_DIR_LEVEL_INT then
          begin
            DetermineFileType(anEntry);
            DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
            if dtEmail in DeterminedFileDriverInfo.DriverType then
            begin
              md5_hash_str := Field_MD5.AsString[anEntry];
              if md5_hash_str = '' then
                HashTheseFiles_TList.Add(anEntry);
            end;
          end;
          anEntry := EmailEntryList.Next;
        end;

        // Hash the level 0,1,2, files for identification purposes
        if assigned(HashTheseFiles_TList) and (HashTheseFiles_TList.Count > 0) then
        begin
          Progress.Log('Hashing Potential Email Module Source Files...');
          HashFiles(HashTheseFiles_TList, '6442450944');
        end;

        // Create a Unique List of Entries for of 0,1,2,3
        anEntry := EmailEntryList.First;
        while assigned(anEntry) and (Progress.isRunning) do
        begin
          dir_level_int := Field_Dir_Level.AsInteger(anEntry);
          if dir_level_int <= MAX_DIR_LEVEL_INT then
          begin
            DetermineFileType(anEntry);
            DeterminedFileDriverInfo := anEntry.DeterminedFileDriverInfo;
            if dtEmail in DeterminedFileDriverInfo.DriverType then
            begin
              Level_012_UniqueListOfEntries.Add(anEntry);
            end;
          end;
          anEntry := EmailEntryList.Next;
        end;

        // Move the Unique List of Entries for of 0,1,2,3 into a TList
        if assigned(Level_012_UniqueListOfEntries) and (Level_012_UniqueListOfEntries.Count > 0) and assigned(Level_012_Files_TList) then
        begin
          Enum := Level_012_UniqueListOfEntries.GetEnumerator;
          while Enum.MoveNext do
          begin
            anEntry := Enum.Current;
            Level_012_Files_TList.Add(anEntry);
          end;
        end;

        if assigned(Level_012_Files_TList) and (Level_012_Files_TList.Count > 0) then
        begin
          Level_012_Files_TList.sort(@SortbyName);
          // Check to see which items match to known files and create a process list
          for i := 0 to Level_012_Files_TList.Count - 1 do
          begin
            added_bl := False;
            anEntry := TEntry(Level_012_Files_TList[i]);
            md5_hash_str := Field_MD5.AsString[anEntry];

            ARec := Item_Record.Create;
            ARec.RecHash := md5_hash_str;
            ARec.RecEntry := anEntry;

            for n := 1 to NumberOfSearchItems do
            begin
              ARec.ProcessInt := n;
              Item := FileItems[n];
              if (md5_hash_str = Item^.MD5_hash) then
              begin
                astr := format_output(anEntry.EntryName, md5_hash_str, SizeDisplayStirng(anEntry.LogicalSize), Item^.GD_Ref_Source);
                gPrint_Known_Email_File_StringList.Add(astr);
                gKnown_File_Process_StringList.AddObject(md5_hash_str, TObject(ARec));
                added_bl := True;
                break;
              end;
            end;
            if not added_bl then
            begin
              if anEntry.isDirectory or anEntry.IsDevice then
              begin
                ARec.ProcessInt := 1000000;
                DeviceEntry := GetDeviceEntry(anEntry);
                if assigned(DeviceEntry) then
                  astr := format_output(anEntry.EntryName, md5_hash_str, SizeDisplayStirng(anEntry.LogicalSize), DeviceEntry.EntryName)
                else
                  astr := format_output(anEntry.EntryName, md5_hash_str, SizeDisplayStirng(anEntry.LogicalSize), '');
                gPrint_UnKnown_Email_File_StringList.Add(astr);
                gUnKnown_File_Process_StringList.AddObject(md5_hash_str, TObject(ARec));
              end;
            end;
          end;
        end;

        // Print the known files
        if assigned(gPrint_Known_Email_File_StringList) and (gPrint_Known_Email_File_StringList.Count > 0) then
        begin
          pad_str := stringofchar(' ', 9);
          gPrint_Known_Email_File_StringList.sort;
          Progress.Log(format_output('Known email files:', 'MD5', 'Size', 'Source'));
          for i := 0 to gPrint_Known_Email_File_StringList.Count - 1 do
          begin
            Progress.Log(gPrint_Known_Email_File_StringList[i]);
          end;
          Progress.Log(stringofchar('-', CHAR_LENGTH));
        end;

        // Print the Unknown files
        if assigned(gPrint_UnKnown_Email_File_StringList) and (gPrint_UnKnown_Email_File_StringList.Count > 0) then
        begin
          gPrint_UnKnown_Email_File_StringList.sort;
          Progress.Log('Unknown email files:');
          Progress.Log(gPrint_UnKnown_Email_File_StringList.text);
          Progress.Log(stringofchar('-', CHAR_LENGTH));
        end;

        MainProc;

      finally
        FreeAndNil(AllEmailFiles_TList);
        FreeAndNil(gKnown_File_Process_StringList);
        FreeAndNil(gPrint_Known_Email_File_StringList);
        FreeAndNil(gPrint_UnKnown_Email_File_StringList);
        FreeAndNil(gUnKnown_File_Process_StringList);
        FreeAndNil(HashTheseFiles_TList);
        FreeAndNil(KeywordSearchEntryList);
        FreeAndNil(Level_012_Files_TList);
        FreeAndNil(Level_012_UniqueListOfEntries);
      end;
    finally
      FreeAndNil(EmailEntryList);
    end;

    if (not bl_Continue) or (not Progress.isRunning) then
    begin
      ConsoleLog(SCRIPT_NAME + ' canceled by user.'); // noslz
      Exit;
    end
    else
      ConsoleLog(stringofchar('-', CHAR_LENGTH));

    FexLabSave(gMemo_StringList);
    CreateRunTimeTXT(gMemo_StringList, CurrentVersion + '_' + gDeviceName_str + '_Validation_Email_' + RUNAS_STR + '.txt'); // Saves to case Reports folder

  finally
    FreeAndNil(gCreateScriptCode_StringList);
    gMemo_StringList.free;
    FreeAndNil(gSel_StringList);
  end;
  Progress.Log(SCRIPT_NAME + ' end.');

end.
