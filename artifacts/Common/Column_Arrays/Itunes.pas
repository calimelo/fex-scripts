{!NAME:      Itunes.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Itunes;

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

  Array_Items_IOS_Plist: TSQL_Table_array = (
  (sql_col: 'DNT_Last Backup Date';                fex_col: 'Last Backup Date';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Device Name';                     fex_col: 'Device Name';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Display Name';                    fex_col: 'Display Name';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Phone Number';                    fex_col: 'Phone Number';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Product Name';                    fex_col: 'Product Name';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Product Type';                    fex_col: 'Product Type';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Guid';                            fex_col: 'Guid';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Iccid';                           fex_col: 'Iccid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Imei';                            fex_col: 'Imei';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Product Version';                 fex_col: 'Product Version';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Serial Number';                   fex_col: 'Serial Number';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  (sql_col: 'DNT_Build Version';                   fex_col: 'Build Version';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  );                                                                                   
                                                                                       
  Array_Items_IOS_XML: TSQL_Table_array = (                                           
  (sql_col: 'DNT_Last Backup Date';                fex_col: 'Last Backup Date';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Device Name';                     fex_col: 'Device Name';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Display Name';                    fex_col: 'Display Name';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Phone Number';                    fex_col: 'Phone Number';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Product Name';                    fex_col: 'Product Name';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Product Type';                    fex_col: 'Product Type';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Guid';                            fex_col: 'Guid';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Iccid';                           fex_col: 'Iccid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Imei';                            fex_col: 'Imei';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Product Version';                 fex_col: 'Product Version';         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Serial Number';                   fex_col: 'Serial Number';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Build Version';                   fex_col: 'Build Version';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  );                                                                                   
                                                                                       
  Array_Items_IOS_SQL: TSQL_Table_array = (                                           
  (sql_col: 'DNT_Fileid';                          fex_col: 'File';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  //(sql_col: 'DNT_File';                          fex_col: 'File';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Domain';                          fex_col: 'Domain';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Relativepath';                    fex_col: 'Relative Path';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_Flags';                           fex_col: 'Flags';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                              
  (sql_col: 'DNT_SQLLOCATION';                     fex_col: 'Location';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),                   
  );

begin
  if Name = 'IOS_PLIST' then Result := Array_Items_IOS_PList else
  if Name = 'IOS_XML'   then Result := Array_Items_IOS_XML else
  if Name = 'IOS_SQL'   then Result := Array_Items_IOS_SQL else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
