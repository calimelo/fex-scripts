unit Edge_Browser;

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

    Array_Items_EDGEAUTOFILL: TSQL_Table_array = (
    (sql_col: 'DNT_date_created';             fex_col: 'Date Created';          read_as: ftLargeInt;    convert_as: 'UNIX';       col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_date_last_used';           fex_col: 'Date Last Used';        read_as: ftLargeInt;    convert_as: 'UNIX';       col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_name';                     fex_col: 'Value Name';            read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_value';                    fex_col: 'Value';                 read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_value_lower';              fex_col: 'Value Lower';           read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_count';                    fex_col: 'Count';                 read_as: ftinteger;     convert_as: '';           col_type: ftinteger;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';           col_type: ftString;      show: True));

    Array_Items_EDGEBOOKMARKS: TSQL_Table_array = (
    (sql_col: 'DNT_date_added';               fex_col: 'Date Added UTC';        read_as: ftString;      convert_as: 'DTChrome';   col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_url';                      fex_col: 'URL';                   read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_name';                     fex_col: 'Bookmark Name';         read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_type';                     fex_col: 'Type';                  read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_guid';                     fex_col: 'GUID';                  read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_id';                       fex_col: 'ID Col';                read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_sync_transaction_version'; fex_col: 'Sync Transaction Ver';  read_as: ftString;      convert_as: '';           col_type: ftString;      show: True));

    Array_Items_EDGEFAVICONS: TSQL_Table_array = (
    (sql_col: 'DNT_page_url';                 fex_col: 'URL';                   read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_icon_id';                  fex_col: 'Icon ID';               read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';           col_type: ftString;      show: True));

    Array_Items_EDGEHISTORY: TSQL_Table_array = (
    (sql_col: 'DNT_LAST_VISIT_TIME';          fex_col: 'Last Visit Date';       read_as: ftLargeInt;    convert_as: 'DTChrome';   col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_URL';                      fex_col: 'URL';                   read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_VISIT_COUNT';              fex_col: 'Visit Count';           read_as: ftInteger;     convert_as: '';           col_type: ftInteger;     show: True),
    (sql_col: 'DNT_TYPED_COUNT';              fex_col: 'Typed Count';           read_as: ftinteger;     convert_as: '';           col_type: ftinteger;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';           col_type: ftString;      show: True));

    Array_Items_EDGEWEBASSISTANCEDATABASE: TSQL_Table_array = (
    (sql_col: 'DNT_LAST_VISITED_TIME';        fex_col: 'Last Visited';          read_as: ftLargeInt;    convert_as: 'UNIX';       col_type: ftDateTime;    show: True),
    (sql_col: 'DNT_URL';                      fex_col: 'URL';                   read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_title';                    fex_col: 'Title';                 read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_metadata';                 fex_col: 'Metadata';              read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_num_visits';               fex_col: 'Visits';                read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';              read_as: ftString;      convert_as: '';           col_type: ftString;      show: True),
    );

begin
  if Name = 'EDGEAUTOFILL'  then Result := Array_Items_EDGEAUTOFILL else
  if Name = 'EDGEBOOKMARKS' then Result := Array_Items_EDGEBOOKMARKS else
  if Name = 'EDGEFAVICONS'  then Result := Array_Items_EDGEFAVICONS else
  if Name = 'EDGEHISTORY'   then Result := Array_Items_EDGEHISTORY else
  if Name = 'EDGEWEBASSISTANCEDATABASE' then Result := Array_Items_EDGEWEBASSISTANCEDATABASE else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.