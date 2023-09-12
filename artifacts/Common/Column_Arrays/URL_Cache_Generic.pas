unit URL_CACHE_GENERIC;

interface

uses
  Columns, DataStorage, SysUtils;
  
const
  SP = ' ';  

function GetTable(const Name : string) : TSQL_Table_array;

implementation

function GetTable(const Name : string) : TSQL_Table_array;
const
  Array_Items_URL_CACHE_GENERIC: TSQL_Table_array = (
  (sql_col: 'DNT_TIME_STAMP';              fex_col: 'Timestamp';           read_as: ftString;      convert_as: '';        col_type: ftDateTime;    show: True),
  //(sql_col: 'DNT_entry_ID';              fex_col: 'Entry Id';            read_as: ftString;      convert_as: '';        col_type: ftString;      show: True),
  //(sql_col: 'DNT_Version';               fex_col: 'Version';             read_as: ftString;      convert_as: '';        col_type: ftString;      show: True),
  //(sql_col: 'DNT_hash_value';            fex_col: 'Hash Value';          read_as: ftString;      convert_as: '';        col_type: ftString;      show: True),
  //(sql_col: 'DNT_storage_policy';        fex_col: 'Storage Policy';      read_as: ftString;      convert_as: '';        col_type: ftString;      show: True),
  (sql_col: 'DNT_request_key';             fex_col: 'URL';                 read_as: ftString;      convert_as: '';        col_type: ftString;      show: True),
  (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';            read_as: ftString;      convert_as: '';        col_type: ftString;      show: True));

begin
  if Name = 'URL_CACHE_GENERIC' then Result := Array_Items_URL_CACHE_GENERIC else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;
end.