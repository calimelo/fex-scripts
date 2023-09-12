{!NAME:      Artifact Array Columns.pas}
{!DESC:      Artifact Array Columns}
{!AUTHOR:    GetData}

unit Columns;

interface

uses
  Columns, DataStorage, SysUtils;

type
  TSQL_Table = record
    sql_col    : string;
    fex_col    : string;
    col_type   : TDataStorageFieldType;
    show       : boolean;
    read_as    : TDataStorageFieldType;
    convert_as : string;
  end;

  TSQL_Table_array = array[1..100] of TSQL_Table;

implementation

end.
