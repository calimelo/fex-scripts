{!NAME:      Couuple_Relationship.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Couple_Relationship;

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

    Array_Items_Couple_Relationship_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_ZCREATEDAT';                 fex_col: 'Create Date';                  read_as: ftFloat;       convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_ZTEXT';                      fex_col: 'Text';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_PK';                     fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_ENT';                    fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_OPT';                    fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZITEMDELETED';             fex_col: 'Itemdeleted';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZLOCALID';                   fex_col: 'Localid';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZMEDIAHEIGHT';             fex_col: 'Mediaheight';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZMEDIAWIDTH';              fex_col: 'Mediawidth';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZREAD';                    fex_col: 'Read';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZSECRET';                  fex_col: 'Secret';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZSENDFAILED';              fex_col: 'Sendfailed';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZSENT';                    fex_col: 'Sent';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZTIMELINE';                fex_col: 'Timeline';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZMEDIALENGTH';             fex_col: 'Medialength';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZEVENTTYPE';                 fex_col: 'Eventtype';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZFROMID';                    fex_col: 'Fromid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZITEMID';                    fex_col: 'Itemid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZLOCALURL';                  fex_col: 'Localurl';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZMAPDATAJASONSTRING';      fex_col: 'Mapdatajasonstring';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZMEDIATYPE';                 fex_col: 'Mediatype';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZOUTGOINGURL';             fex_col: 'Outgoingurl';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZREMOTEURL';                 fex_col: 'Remoteurl';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZSECRETMETA';              fex_col: 'Secretmeta';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZTHUMBNAILURL';              fex_col: 'Thumbnailurl';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'COUPLE_RELATIONSHIP_CHAT_IOS' then Result := Array_Items_Couple_Relationship_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.