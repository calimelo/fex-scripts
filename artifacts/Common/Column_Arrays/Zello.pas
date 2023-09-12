{!NAME:      Zello.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Zello;

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

// Chat - iOS
    Array_Items_ZELLO_CHAT_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_Time';                     fex_col: 'Date';                         read_as: ftLargeInt;    convert_as: 'ABS';      col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Author';                   fex_col: 'Author';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Read';                     fex_col: 'Read';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Codec';                    fex_col: 'Codec';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Size';                     fex_col: 'Size';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Duration';                 fex_col: 'Duration';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),

    (sql_col: 'DNT_Data';                     fex_col: 'Data';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Historyid';                fex_col: 'Historyid';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Userfrom';                 fex_col: 'Userfrom';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Userto';                   fex_col: 'Userto';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Type';                     fex_col: 'Type';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),

    //(sql_col: 'DNT_Subchannel';             fex_col: 'Subchannel';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Channeluser';            fex_col: 'Channeluser';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Alertmessage';           fex_col: 'Alertmessage';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String1';                fex_col: 'String1';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String2';                fex_col: 'String2';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int1';                   fex_col: 'Int1';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int2';                   fex_col: 'Int2';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String3';                fex_col: 'String3';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String4';                fex_col: 'String4';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int3';                   fex_col: 'Int3';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int4';                   fex_col: 'Int4';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int5';                   fex_col: 'Int5';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int6';                   fex_col: 'Int6';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String5';                fex_col: 'String5';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String6';                fex_col: 'String6';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String7';                fex_col: 'String7';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String8';                fex_col: 'String8';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String9';                fex_col: 'String9';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String10';               fex_col: 'String10';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int7';                   fex_col: 'Int7';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int8';                   fex_col: 'Int8';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Int9';                   fex_col: 'Int9';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String11';               fex_col: 'String11';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String12';               fex_col: 'String12';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_String13';               fex_col: 'String13';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

// Chat - Android
    Array_Items_ZELLO_CHAT_ANDROID: TSQL_Table_array = (
    (sql_col: 'DNT_Ts';                       fex_col: 'Date';                         read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_Author';                   fex_col: 'Author';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Read';                     fex_col: 'Read';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Codec';                    fex_col: 'Codec';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Size';                     fex_col: 'Size';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Duration';                 fex_col: 'Duration';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Offset';                   fex_col: 'Offset';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Id';                     fex_col: 'ID Col';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Type';                     fex_col: 'Type';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Incoming';                 fex_col: 'Incoming';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_contact_name';             fex_col: 'Contact Name';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_contact_type';             fex_col: 'Contact Type';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_author_full_name';         fex_col: 'Author Full Name';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_crosslink_id';           fex_col: 'Crosslink Id';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_crosslink_company_name'; fex_col: 'Crosslink Company Name';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_crosslink_sender_name';  fex_col: 'Crosslink Sender Name';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Subchannel';             fex_col: 'Subchannel';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_channel_user';             fex_col: 'Channel User';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Text';                     fex_col: 'Text';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_St';                     fex_col: 'St';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Tr';                     fex_col: 'Tr';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Rc';                     fex_col: 'Rc';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I3';                     fex_col: 'I3';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I4';                     fex_col: 'I4';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I5';                     fex_col: 'I5';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I6';                     fex_col: 'I6';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I7';                     fex_col: 'I7';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I8';                     fex_col: 'I8';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_I9';                     fex_col: 'I9';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Sts';                    fex_col: 'Sts';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Tts';                    fex_col: 'Tts';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_L2';                     fex_col: 'L2';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Srv';                    fex_col: 'Srv';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Sid';                    fex_col: 'Sid';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_S2';                     fex_col: 'S2';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_S3';                     fex_col: 'S3';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_S4';                     fex_col: 'S4';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_S5';                     fex_col: 'S5';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Rsh';                    fex_col: 'Rsh';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Emg';                    fex_col: 'Emg';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_D0';                     fex_col: 'D0';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_D1';                     fex_col: 'D1';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_D2';                     fex_col: 'D2';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'ZELLO_CHAT_IOS'     then Result := Array_Items_ZELLO_CHAT_IOS else
  if Name = 'ZELLO_CHAT_ANDROID' then Result := Array_Items_ZELLO_CHAT_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
