{!NAME:      Notes.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Notes;

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

  Array_Items_IOS: TSQL_Table_array = (
  (sql_col: 'DNT_ZCREATIONDATE';                           fex_col: 'Creation Date';                              read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZMODIFICATIONDATE';                       fex_col: 'Modification Date';                          read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZTITLE';                                  fex_col: 'Title';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZSUMMARY';                                fex_col: 'Summary';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_ZAUTHOR';                                 fex_col: 'Author';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_Z_PK';                                    fex_col: 'Pk';                                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Z_ENT';                                   fex_col: 'Ent';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_Z_OPT';                                   fex_col: 'Opt';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZCONTAINSCJK';                            fex_col: 'Containscjk';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZCONTENTTYPE';                            fex_col: 'Contenttype';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZDELETEDFLAG';                            fex_col: 'Deletedflag';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZEXTERNALFLAGS';                          fex_col: 'Externalflags';                              read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZEXTERNALSEQUENCENUMBER';                 fex_col: 'Externalsequencenumber';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZEXTERNALSERVERINTID';                    fex_col: 'Externalserverintid';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZINTEGERID';                              fex_col: 'Integerid';                                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZISBOOKKEEPINGENTRY';                     fex_col: 'Isbookkeepingentry';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZBODY';                                   fex_col: 'Body';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZSTORE';                                  fex_col: 'Store';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZGUID';                                   fex_col: 'Guid';                                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_ZSERVERID';                               fex_col: 'Serverid';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: False),          
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  // Notes (New format - this is a cut down table)
  Array_Items_IOS2: TSQL_Table_array = (
  (sql_col: 'DNT_ZCREATIONDATE';                           fex_col: 'Creation Date';                              read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZCREATIONDATE1';                          fex_col: 'Creation Date';                              read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),           
  (sql_col: 'DNT_ZTITLE1';                                 fex_col: 'Title';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  );

  //=========================================================================================================================================================================

begin
  if Name = 'IOS'   then Result := Array_Items_IOS else
  if Name = 'IOS2'  then Result := Array_Items_IOS2 else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
