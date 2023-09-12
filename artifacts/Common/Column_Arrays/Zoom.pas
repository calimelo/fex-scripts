unit Zoom;

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

    Array_Items_ZOOM_CHAT_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_messageTimestamp';         fex_col: 'Timestamp';             read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_senderName';               fex_col: 'Sender Name';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_MESSAGEID';                fex_col: 'Message ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_BODY';                     fex_col: 'Body';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SENTBYME';                 fex_col: 'SentByMe';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SENDERRESOURCE';           fex_col: 'Sender Resource';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_msgType';                  fex_col: 'Message Type';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_msgState';                 fex_col: 'Message State';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_readed';                   fex_col: 'Read';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

    Array_Items_ZOOM_DOWNLOAD_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_web_file_id';              fex_col: 'Web File ID';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_local_path';               fex_col: 'Local Path';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_preview_path';             fex_col: 'Preview Path';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_downloaded';               fex_col: 'Downloaded';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_transferred_size';         fex_col: 'Transfer Size';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'ZOOM_CHAT_IOS'     then Result := Array_Items_ZOOM_CHAT_IOS else
  if Name = 'ZOOM_DOWNLOAD_IOS' then Result := Array_Items_ZOOM_DOWNLOAD_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
