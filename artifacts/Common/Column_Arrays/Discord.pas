unit Discord;

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

  Array_Items_DISCORD_CHAT_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_timestamp';      fex_col: 'Discord Date';   read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_username';       fex_col: 'Author Name';    read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_author_id';      fex_col: 'Author ID';      read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_content';        fex_col: 'Message';        read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_id';             fex_col: 'Discord ID';     read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_channel_id';     fex_col: 'Channel ID';     read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_type';           fex_col: 'Type';           read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_filename';       fex_col: 'Filename';       read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_size';           fex_col: 'Size';           read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_url';            fex_col: 'URL';            read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  );

begin
  if Name = 'DISCORD_CHAT_IOS' then Result := Array_Items_DISCORD_CHAT_IOS
  else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
