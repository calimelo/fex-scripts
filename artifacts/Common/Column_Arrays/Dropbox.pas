{!NAME:      Dropbox.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Dropbox;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
  SP = ' ';

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_IOS_Metadata_Cache: TSQL_Table_array = (
  (sql_col: 'DNT_last_modified';            fex_col: 'Dropbox' +SP+ 'Last Modified'; read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_client_mtime';             fex_col: 'Client Mtime';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Prefix';                   fex_col: 'Prefix';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_file_name';                fex_col: 'File Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Name';                     fex_col: 'Name Col';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Bytes';                    fex_col: 'Bytes';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_is_dir';                   fex_col: 'Is Dir';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Rev';                      fex_col: 'Rev';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Icon';                     fex_col: 'Icon';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_folder_hash';              fex_col: 'Folder Hash';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_thumb_exists';             fex_col: 'Thumb Exists';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_can_stream';               fex_col: 'Can Stream';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_read_only';                fex_col: 'Read Only';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_IOS_Spotlight_Items: TSQL_Table_array = (
  (sql_col: 'DNT_Timestamp';                fex_col: 'Timestamp';                    read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Uid';                      fex_col: 'Uid';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Path';                     fex_col: 'Path';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_user_id';                  fex_col: 'User Id';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Source';                   fex_col: 'Source';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_custom_thumbnail';         fex_col: 'Custom Thumbnail';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Title';                    fex_col: 'Title';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Subtitle';                 fex_col: 'Subtitle';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_uti_type';                 fex_col: 'Uti Type';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS_METADATA_CACHE' then Result := Array_Items_IOS_Metadata_Cache else
  if Name = 'IOS_SPOTLIGHT_ITEMS' then Result := Array_Items_IOS_Spotlight_Items else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
