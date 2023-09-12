{!NAME:      Picasa.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Picasa;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // DO NOT USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_Android: TSQL_Table_array = (
  (sql_col: 'DNT_ID';                                     fex_col: 'ID Col (Date)';                              read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: False),          
  (sql_col: 'DNT_date_taken';                              fex_col: 'Date Taken';                                 read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_album_id';                                fex_col: 'Album ID';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_cache_pathname';                          fex_col: 'Cache Pathname';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_cache_status';                            fex_col: 'Cache Status';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_comment_count';                           fex_col: 'Comment Count';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_content_type';                            fex_col: 'Content Type';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_content_url';                             fex_col: 'Content Url';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_date_edited';                             fex_col: 'Date Edited';                                read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_date_published';                          fex_col: 'Date Published';                             read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_date_updated';                            fex_col: 'Date Updated';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_display_index';                           fex_col: 'Display Index';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_edit_uri';                                fex_col: 'Edit Uri';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Height';                                  fex_col: 'Height';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_html_page_url';                           fex_col: 'Html Page Url';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Keywords';                                fex_col: 'Keywords';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Latitude';                                fex_col: 'Latitude';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Longitude';                               fex_col: 'Longitude';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Rotation';                                fex_col: 'Rotation';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_screennail_url';                          fex_col: 'Screennail Url';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Size';                                    fex_col: 'Size';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Summary';                                 fex_col: 'Summary';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_sync_account';                            fex_col: 'Sync Account';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_thumbnail_url';                           fex_col: 'Thumbnail Url';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Title';                                   fex_col: 'Title';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Width';                                   fex_col: 'Width';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

begin
  if Name = 'ANDROID' then Result := Array_Items_Android else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
