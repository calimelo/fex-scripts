unit GMail_Cached;

interface

uses
  Columns, DataStorage, SysUtils;

function GetTable(const Name: string): TSQL_Table_array;

implementation

function GetTable(const Name: string): TSQL_Table_array;
const

  // DO NOT TRANSLATE SQL_COL. TRANSLATE ONLY FEX_COL.
  // MAKE SURE COL DOES NOT ALREADY EXIST AS A DIFFERENT TYPE.
  // ROW ORDER IS PROCESS ORDER
  // do not USE RESERVED NAMES IN FEX_COL LIKE 'NAME', 'ID'

  Array_Items_ANDROID: TSQL_Table_array = ((sql_col: 'DNT_RECEIVEDDATEMS'; fex_col: 'Received'; read_as: ftFloat; convert_as: 'UNIX_MS'; col_type: ftDateTime; show: True), (sql_col: 'DNT_SUBJECT'; fex_col: 'Subject'; read_as: ftString;
    convert_as: ''; col_type: ftString; show: True), (sql_col: 'DNT_ADDRESS_FROM'; fex_col: 'From'; read_as: ftString; convert_as: ''; col_type: ftString; show: True), (sql_col: 'DNT_ADDRESS_TO'; fex_col: 'To'; read_as: ftString;
    convert_as: ''; col_type: ftString; show: True), (sql_col: 'DNT_SNIPPETHTML'; fex_col: 'Snippet'; read_as: ftString; convert_as: ''; col_type: ftString; show: True), (sql_col: 'DNT_BODY'; fex_col: 'Body'; read_as: ftString;
    convert_as: ''; col_type: ftString; show: True), (sql_col: 'DNT_CONVERSATIONID'; fex_col: 'Conversation ID'; read_as: ftString; convert_as: ''; col_type: ftString; show: True), );

begin
  if Name = 'ANDROID' then
    Result := Array_Items_ANDROID
  else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
