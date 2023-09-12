{!NAME:      HelloTalk.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit HelloTalk;

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

  Array_Items_HelloTalk_IOS: TSQL_Table_array = (
    //(sql_col: 'DNT_Id';                       fex_col: 'ID Col';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Time';                       fex_col: 'Time Str';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Messageid';                fex_col: 'Messageid';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Roomid';                   fex_col: 'Roomid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Roomtype';                 fex_col: 'Roomtype';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Nickname';                   fex_col: 'Nickname';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Friendid';                   fex_col: 'Friendid';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Transfertype';             fex_col: 'Transfertype';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Transferstatus';           fex_col: 'Transferstatus';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Messagetype';              fex_col: 'Messagetype';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Extendtype';               fex_col: 'Extendtype';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Extendmessage';            fex_col: 'Extendmessage';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Isread';                   fex_col: 'Isread';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Content';                    fex_col: 'Content';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Sourcelanguage';           fex_col: 'Sourcelanguage';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Originaltargetcontent';    fex_col: 'Originaltargetcontent';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Targetcontent';              fex_col: 'Targetcontent';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Targetlanguage';             fex_col: 'Targetlanguage';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Filename';                 fex_col: 'Filename';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Oob';                      fex_col: 'Oob';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Favoriteid';               fex_col: 'Favoriteid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Sourcetransliteration';    fex_col: 'Sourcetransliteration';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Targettransliteration';    fex_col: 'Targettransliteration';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Sourcetranslitestring';    fex_col: 'Sourcetranslitestring';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Targettranslitestring';    fex_col: 'Targettranslitestring';        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Messagecollapse';          fex_col: 'Messagecollapse';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Confidencevalue';          fex_col: 'Confidencevalue';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Displayconfidencevalue';   fex_col: 'Displayconfidencevalue';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Audiolanguage';            fex_col: 'Audiolanguage';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Receiptreaded';            fex_col: 'Receiptreaded';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Voiproomid';               fex_col: 'Voiproomid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Messagesaparefield';       fex_col: 'Messagesaparefield';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Messagesaparefield2';      fex_col: 'Messagesaparefield2';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Messagesaparefield3';      fex_col: 'Messagesaparefield3';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'HELLOTALK_CHAT_IOS' then Result := Array_Items_HelloTalk_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.