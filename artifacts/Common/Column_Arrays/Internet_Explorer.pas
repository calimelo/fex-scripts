unit IE_Browser;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const

  DNT_AccessCount     = 'DNT_AccessCount';      COLNAME_AccessCount     = 'Access Count';
  DNT_AccessedTime    = 'DNT_AccessedTime';     COLNAME_AccessedTime    = 'Accessed Time (UTC)';
  DNT_ContainerID     = 'DNT_ContainerId';      COLNAME_ContainerID     = 'ESE Container ID';
  DNT_CreationTime    = 'DNT_CreationTime';     COLNAME_CreationTime    = 'Creation Time (UTC)';
  DNT_EntryID         = 'DNT_EntryId';          COLNAME_EntryID         = 'ESE Entry ID';
  DNT_ExpiryTime      = 'DNT_ExpiryTime';       COLNAME_ExpiryTime      = 'Expiry Time (UTC)';
  DNT_Filename        = 'DNT_Filename';         COLNAME_Filename        = 'Filename';
  DNT_FileOffset      = 'DNT_FileOffset';       COLNAME_FileOffset      = 'File Offset';
  DNT_Filesize        = 'DNT_FileSize';         COLNAME_Filesize        = 'File Size';
  DNT_Flags           = 'DNT_Flags';            COLNAME_Flags           = 'Flags';
  DNT_Hostname        = 'DNT_HostName';         COLNAME_Hostname        = 'Host Name';
  DNT_ModifiedTime    = 'DNT_ModifiedTime';     COLNAME_ModifiedTime    = 'Modified Time (UTC)';
  DNT_PageTitle       = 'DNT_PageTitle';        COLNAME_PageTitle       = 'Page Title';
  DNT_Port            = 'DNT_Port';             COLNAME_Port            = 'Port';
  DNT_RecoveryType    = 'DNT_RecoveryType';     COLNAME_RecoveryType    = 'Recovery Type';
  DNT_Reference       = 'DNT_Reference';        COLNAME_Reference       = 'Reference';
  DNT_ResponseHeaders = 'DNT_ResponseHeaders';  COLNAME_ResponseHeaders = 'Response Headers (Parsed)';
  DNT_SyncTime        = 'DNT_SyncTime';         COLNAME_SyncTime        = 'Sync Time (UTC)';
  DNT_Url             = 'DNT_Url';              COLNAME_Url             = 'URL';
  DNT_UrlHash         = 'DNT_UrlHash';          COLNAME_UrlHash         = 'URL Hash';
  DNT_UrlSchemaType   = 'DNT_UrlSchemaType';    COLNAME_UrlSchemaType   = 'URL Schema Type';

    // CONTENT_TABLES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Array_Items_IE11_ESE_CONTENT_TABLES: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                  col_type: ftString;      show: True),
    (sql_col: DNT_Filename;                     fex_col: COLNAME_Filename;             col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;         col_type: ftString;      show: True),
    (sql_col: DNT_EntryId;                      fex_col: COLNAME_EntryId;              col_type: ftinteger;     show: True),
    (sql_col: DNT_ContainerId;                  fex_col: COLNAME_ContainerId;          col_type: ftinteger;     show: True),
    (sql_col: DNT_FileSize;                     fex_col: COLNAME_FileSize;             col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_UrlHash;              col_type: ftString;      show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;          col_type: ftinteger;     show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;             col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;           col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;         col_type: ftDateTime;    show: True));

    // COOKIES_TABLES
    Array_Items_IE11_ESE_COOKIES_TABLES: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                  col_type: ftString;      show: True),
    (sql_col: DNT_Filename;                     fex_col: COLNAME_Filename;             col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;         col_type: ftString;      show: True),
    (sql_col: DNT_EntryId;                      fex_col: COLNAME_EntryID;              col_type: ftinteger;     show: True),
    (sql_col: DNT_ContainerId;                  fex_col: COLNAME_ContainerID;          col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_URLHash;              col_type: ftString;      show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;          col_type: ftinteger;     show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;             col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;           col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;         col_type: ftDateTime;    show: True));

    // DEPENDENCY_TABLES
    Array_Items_IE11_ESE_DEPENDENCY_TABLES: TSQL_Table_array = (
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                  col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;         col_type: ftString;      show: True),
    (sql_col: DNT_EntryId;                      fex_col: COLNAME_EntryID;              col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlSchemaType;                fex_col: COLNAME_UrlSchemaType;        col_type: ftString;      show: True),
    (sql_col: DNT_Port;                         fex_col: COLNAME_Port;                 col_type: ftString;      show: True),
    (sql_col: DNT_HostName;                     fex_col: COLNAME_HostName;             col_type: ftString;      show: True));

    // DOWNLOADS_TABLES
    Array_Items_IE11_ESE_DOWNLOADS_TABLES: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                  col_type: ftString;      show: True),
    (sql_col: DNT_ResponseHeaders;              fex_col: COLNAME_ResponseHeaders;      col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;         col_type: ftString;      show: True),
    (sql_col: DNT_EntryId;                      fex_col: COLNAME_EntryID;              col_type: ftinteger;     show: True),
    (sql_col: DNT_ContainerId;                  fex_col: COLNAME_ContainerID;          col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_URLHash;              col_type: ftString;      show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;          col_type: ftinteger;     show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;             col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;           col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;         col_type: ftDateTime;    show: True));

    // HISTORY_TABLES
    Array_Items_IE11_ESE_HISTORY_TABLES: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                  col_type: ftString;      show: True),
    (sql_col: DNT_ResponseHeaders;              fex_col: COLNAME_PageTitle;            col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;         col_type: ftString;      show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;          col_type: ftinteger;     show: True),
    (sql_col: DNT_EntryId;                      fex_col: COLNAME_EntryID;              col_type: ftinteger;     show: True),
    (sql_col: DNT_ContainerId;                  fex_col: COLNAME_ContainerID;          col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_UrlHash;              col_type: ftString;      show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;             col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;         col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;           col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;         col_type: ftDateTime;    show: True));

    // CONTENT_CARVE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Array_Items_IE11_ESE_CONTENT_CARVE: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                   col_type: ftString;      show: True),
    (sql_col: DNT_Filename;                     fex_col: COLNAME_Filename;              col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;          col_type: ftString;      show: True),
    (sql_col: DNT_FileOffset;                   fex_col: COLNAME_FileOffset;            col_type: ftinteger;     show: True),
    (sql_col: DNT_FileSize;                     fex_col: COLNAME_FileSize;              col_type: ftinteger;     show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;           col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_URLHash;               col_type: ftString;      show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                 col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;              col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;            col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;          col_type: ftDateTime;    show: True));

    // COOKIES_CARVE
    Array_Items_IE11_ESE_COOKIES_CARVE: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                   col_type: ftString;      show: True),
    (sql_col: DNT_Filename;                     fex_col: COLNAME_Filename;              col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;          col_type: ftString;      show: True),
    (sql_col: DNT_FileOffset;                   fex_col: COLNAME_FileOffset;            col_type: ftinteger;     show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;           col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_URLHash;               col_type: ftString;      show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                 col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;              col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;            col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;          col_type: ftDateTime;    show: True));

    // HISTORY_CARVE_VISITED
    Array_Items_IE11_ESE_HISTORY_CARVE_VISITED: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                   col_type: ftString;      show: True),
    (sql_col: DNT_PageTitle;                    fex_col: COLNAME_PageTitle;             col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;          col_type: ftString;      show: True),
    (sql_col: DNT_FileOffset;                   fex_col: COLNAME_FileOffset;            col_type: ftinteger;     show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;           col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_URLHash;               col_type: ftString;      show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                 col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;              col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;            col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;          col_type: ftDateTime;    show: True));

    // HISTORY_CARVE_REF_MARKER
    Array_Items_IE11_ESE_HISTORY_CARVE_REF_MARKER: TSQL_Table_array = (
    (sql_col: DNT_AccessedTime;                 fex_col: COLNAME_AccessedTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_Url;                          fex_col: COLNAME_Url;                   col_type: ftString;      show: True),
    (sql_col: DNT_RecoveryType;                 fex_col: COLNAME_RecoveryType;          col_type: ftString;      show: True),
    (sql_col: DNT_FileOffset;                   fex_col: COLNAME_FileOffset;            col_type: ftinteger;     show: True),
    (sql_col: DNT_AccessCount;                  fex_col: COLNAME_AccessCount;           col_type: ftinteger;     show: True),
    (sql_col: DNT_UrlHash;                      fex_col: COLNAME_URLHash;               col_type: ftString;      show: True),
    (sql_col: DNT_Flags;                        fex_col: COLNAME_Flags;                 col_type: ftString;      show: True),
    (sql_col: DNT_SyncTime;                     fex_col: COLNAME_SyncTime;              col_type: ftDateTime;    show: True),
    (sql_col: DNT_CreationTime;                 fex_col: COLNAME_CreationTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_ExpiryTime;                   fex_col: COLNAME_ExpiryTime;            col_type: ftDateTime;    show: True),
    (sql_col: DNT_ModifiedTime;                 fex_col: COLNAME_ModifiedTime;          col_type: ftDateTime;    show: True),
    (sql_col: DNT_Reference;                    fex_col: COLNAME_Reference;             col_type: ftString;      show: True));

    Array_Items_IE_49_COMMON: TSQL_Table_array = (  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (sql_col: 'DNT_Last Accessed (UTC)';           fex_col: 'Last Accessed (UTC)';        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_URL';                           fex_col: 'URL';                        read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Lock Count';                    fex_col: 'Visit Count';                read_as: ftinteger;            convert_as: '';                col_type: ftinteger;     show: True),
    (sql_col: 'DNT_User';                          fex_col: 'User';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Type';                          fex_col: 'Type';                       read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Sub Directory';                 fex_col: 'Sub Directory';              read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Last Modified (UTC)';           fex_col: 'Last Modified Date (UTC)';   read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Last Sync Time';                fex_col: 'Last Sync Time';             read_as: ftString;             convert_as: '';                col_type: ftString;      show: True),
    (sql_col: 'DNT_Expiry Time';                   fex_col: 'Expiry-Time';                read_as: ftString;             convert_as: '';                col_type: ftString;      show: True));

begin
  if Name = 'IE_1011_ESE_CONTENT_TABLES'        then Result := Array_Items_IE11_ESE_CONTENT_TABLES else
  if Name = 'IE_1011_ESE_COOKIES_TABLES'        then Result := Array_Items_IE11_ESE_COOKIES_TABLES else
  if Name = 'IE_49_URLCOOKIE'                   then Result := Array_Items_IE_49_COMMON else
  if Name = 'IE_49_URLDAILY'                    then Result := Array_Items_IE_49_COMMON else
  if Name = 'IE_49_URLHISTORY'                  then Result := Array_Items_IE_49_COMMON else
  if Name = 'IE_49_URLNORMAL'                   then Result := Array_Items_IE_49_COMMON else
  if Name = 'IE_ESE_CONTENT_CARVE'              then Result := Array_Items_IE11_ESE_CONTENT_CARVE else
  if Name = 'IE_ESE_COOKIES_CARVE'              then Result := Array_Items_IE11_ESE_COOKIES_CARVE else
  if Name = 'IE_ESE_DEPENDENCY_TABLES'          then Result := Array_Items_IE11_ESE_DEPENDENCY_TABLES else
  if Name = 'IE_ESE_DOWNLOADS_TABLES'           then Result := Array_Items_IE11_ESE_DOWNLOADS_TABLES else
  if Name = 'IE_ESE_HISTORY_CARVE_REF_MARKER'   then Result := Array_Items_IE11_ESE_HISTORY_CARVE_REF_MARKER else
  if Name = 'IE_ESE_HISTORY_CARVE_VISITED'      then Result := Array_Items_IE11_ESE_HISTORY_CARVE_VISITED else
  if Name = 'IE_ESE_HISTORY_TABLES'             then Result := Array_Items_IE11_ESE_HISTORY_TABLES else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.