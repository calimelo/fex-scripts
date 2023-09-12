{!NAME:      Yahoo.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Yahoo;

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

  // https://cryptome.org/isp-spy/yahoo-chat-spy.pdf
  //  http://www.0xcafefeed.com/2007/12/yahoo-messenger-archive-file-format/

  // Columns are hard coded so do not change the order

  Array_Items_Windows: TSQL_Table_array = (
  {1}(sql_col: 'DNT_Yahoo_Date';           fex_col: 'Date (UTC)';      read_as: ftString;          convert_as: '';          col_type: ftDateTime;   show: True),
  {2}(sql_col: 'DNT_Local_User';           fex_col: 'Local User';      read_as: ftString;          convert_as: '';          col_type: ftString;     show: True),
  {3}(sql_col: 'DNT_Yahoo_Type';           fex_col: 'Yahoo Type';      read_as: ftString;          convert_as: '';          col_type: ftString;     show: False),
  {4}(sql_col: 'DNT_Yahoo_message';        fex_col: 'Message';         read_as: ftString;          convert_as: '';          col_type: ftString;     show: True),
  {5}(sql_col: 'DNT_SentReceived';         fex_col: 'Sent/Received';   read_as: ftString;          convert_as: '';          col_type: ftString;     show: True),
  {6}(sql_col: 'DNT_Yahoo_User';           fex_col: 'Other User';      read_as: ftString;          convert_as: '';          col_type: ftString;     show: True),
  {7}(sql_col: 'DNT_Yahoo_Archive_Folder'; fex_col: 'Archive Folder';  read_as: ftBytes;           convert_as: '';          col_type: ftString;     show: True),
  {8}(sql_col: 'DNT_Yahoo_Archive_Type';   fex_col: 'Archive Type';    read_as: ftString;          convert_as: '';          col_type: ftString;     show: True),
  );

begin
  if Name = 'YAHOO_MESSENGER_CHAT_WINDOWS' then Result := Array_Items_Windows else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.
