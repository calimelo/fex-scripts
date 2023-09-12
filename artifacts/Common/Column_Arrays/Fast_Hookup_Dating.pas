{!NAME:      Fast_Hookup_Dating.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Fast_Hookup_Dating;

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

    Array_Items_Chat_IOS: TSQL_Table_array = (
    //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Msgsendtime';                             fex_col: 'Msgsendtime';                                read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),           
    (sql_col: 'DNT_msgContent_Text';                         fex_col: 'Msgcontent Text';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Realuserid';                              fex_col: 'Realuserid';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    //(sql_col: 'DNT_Robotuserid';                           fex_col: 'Robotuserid';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_msgContent_Image';                        fex_col: 'Msgcontent Image';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Issender';                                fex_col: 'Issender';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Contenttype';                             fex_col: 'Contenttype';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    );

    Array_Items_User_IOS: TSQL_Table_array = (
    //(sql_col: 'DNT_Id';                                    fex_col: 'ID Col';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Email';                                   fex_col: 'Email';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Gender';                                  fex_col: 'Gender';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Age';                                     fex_col: 'Age';                                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Username';                                fex_col: 'Username';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Location';                                fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Range';                                   fex_col: 'Range';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Marital';                                 fex_col: 'Marital';                                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Smoke';                                   fex_col: 'Smoke';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Drink';                                   fex_col: 'Drink';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Abouts';                                  fex_col: 'Abouts';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Birthday';                                fex_col: 'Birthday';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Password';                                fex_col: 'Password';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_photo_header';                            fex_col: 'Photo Header';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Orientation';                             fex_col: 'Orientation';                                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Lookingfor';                              fex_col: 'Lookingfor';                                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Photos';                                  fex_col: 'Photos';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Userid';                                  fex_col: 'Userid';                                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_Isvip';                                   fex_col: 'Isvip';                                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_vip_start_time';                          fex_col: 'Vip Start Time';                             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
    (sql_col: 'DNT_vip_end_time';                            fex_col: 'Vip End Time';                               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),           
  (sql_col: 'DNT_SQLLOCATION';                             fex_col: 'Location';                                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'FAST_HOOKUP_DATING_CHAT_IOS' then Result := Array_Items_Chat_IOS else
  if Name = 'FAST_HOOKUP_DATING_USER_IOS' then Result := Array_Items_User_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.