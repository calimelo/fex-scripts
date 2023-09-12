Unit Bluetooth;

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

  Array_Items_IOS_BLUETOOTH_DEVICES: TSQL_Table_array = (
  (sql_col: 'DNT_MACADDRESS';        fex_col: 'MAC ADDRESS';        read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_NAME';              fex_col: 'Device Name';        read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_USERNAMEKEY';       fex_col: 'User Name';          read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  (sql_col: 'DNT_DEFAULTNAME';       fex_col: 'Default Name';       read_as: ftString;      convert_as: '';     col_type: ftString;     show: True),
  );

  Array_Items_IOS_BLUETOOTH_SEEN: TSQL_Table_array = (
  (sql_col: 'DNT_LASTSEEN';          fex_col: 'Last Seen';         read_as: ftLargeInt;    convert_as: 'ABX';   col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_NAME';              fex_col: 'Device Name';       read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_UUID';              fex_col: 'UUID';              read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_ADDRESS';           fex_col: 'Address';           read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';       fex_col: 'Location';          read_as: ftString;      convert_as: '';      col_type: ftString;     show: True),
  );

begin
  if Name = 'IOS_BLUETOOTH_DEVICES'   then Result := Array_Items_IOS_BLUETOOTH_DEVICES else
  if Name = 'IOS_BLUETOOTH_SEEN'   then Result := Array_Items_IOS_BLUETOOTH_SEEN else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));
end;

end.