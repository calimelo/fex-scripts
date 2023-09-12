{!NAME:      Coco.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Coco;

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

  Array_Items_Android_Coco_Chat: TSQL_Table_array = (
  (sql_col: 'DNT_Displaytime';              fex_col: 'Display Time';                 read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Msgtime';                  fex_col: 'Msg Time';                     read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_Content';                  fex_col: 'Content';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Srvmsgid';               fex_col: 'Srvmsgid';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Msgtype';                  fex_col: 'Msgtype';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Srvtime';                fex_col: 'Srvtime';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Fromuid';                  fex_col: 'From UID';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Rowid';                  fex_col: 'Rowid';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Touid';                    fex_col: 'To UID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Status';                 fex_col: 'Status';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Relatedpb';              fex_col: 'Relatedpb';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Blobdata';               fex_col: 'Blobdata';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Sessionid';                fex_col: 'Session ID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Remaintime';             fex_col: 'Remaintime';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Android_Coco_FriendModel: TSQL_Table_array = (
  (sql_col: 'DNT_Coconumber';               fex_col: 'Coco Number';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Md5Phone';               fex_col: 'Md5Phone';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Contactname';              fex_col: 'Contact Name';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Cocoid';                   fex_col: 'Coco ID';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Avatarprevurl';            fex_col: 'Avatarprevurl';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Nickname';                 fex_col: 'Nickname';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Memo';                     fex_col: 'Memo';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Note';                     fex_col: 'Note';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Countrycode';              fex_col: 'Countrycode';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Userid';                   fex_col: 'User ID';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Alias';                    fex_col: 'Alias';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Source';                   fex_col: 'Source';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_Android_Coco_UserModel: TSQL_Table_array = (
  (sql_col: 'DNT_Created';                  fex_col: 'Created';                      read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),  
  (sql_col: 'DNT_Snspostcount';             fex_col: 'Snspostcount';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Contactname';              fex_col: 'Contactname';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Facebookexpire';           fex_col: 'Facebookexpire';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Facebookid';               fex_col: 'Facebookid';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Md5Phone';                 fex_col: 'Md5Phone';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Snsprofileimgurls';        fex_col: 'Snsprofileimgurls';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Issilent';                 fex_col: 'Issilent';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Gender';                   fex_col: 'Gender';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Avatarprevurl';            fex_col: 'Avatarprevurl';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Birthdayday';              fex_col: 'Birthdayday';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Nickname';                 fex_col: 'Nickname';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Birthdayyear';             fex_col: 'Birthdayyear';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Snsused';                  fex_col: 'Snsused';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Alias';                    fex_col: 'Alias';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Coconumber';               fex_col: 'Coconumber';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Cocoid';                   fex_col: 'Cocoid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Avatarurl';                fex_col: 'Avatarurl';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Email';                    fex_col: 'Email';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Note';                     fex_col: 'Note';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Userid';                   fex_col: 'Userid';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Background';               fex_col: 'Background';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Birthdaymonth';            fex_col: 'Birthdaymonth';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Facebooktoken';            fex_col: 'Facebooktoken';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Country';                  fex_col: 'Country';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Stat';                     fex_col: 'Stat';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Isstranger';               fex_col: 'Isstranger';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Snscoverurl';              fex_col: 'Snscoverurl';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Updatetime';               fex_col: 'Updatetime';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Jsondata';                 fex_col: 'Jsondata';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_Source';                   fex_col: 'Source';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_iOS_Coco_Chat: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                   fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                  fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                  fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZDISPLAYTIME';             fex_col: 'Display Time';                 read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZCONTENT';                 fex_col: 'Content';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZBLOBDATA';                fex_col: 'Blobdata';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFROMUID';                 fex_col: 'Fromu ID';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZMSGID';                   fex_col: 'Msg ID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZMSGTYPE';                 fex_col: 'Msg Type';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZROWID';                 fex_col: 'Row ID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSTATUS';                  fex_col: 'Status';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZTOUID';                   fex_col: 'To UID';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSESSIONID';               fex_col: 'Session ID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZREPLYMSG';                fex_col: 'Replymsg';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_iOS_Coco_Contact_Entity: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                   fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                  fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                  fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFIRSTNAME';               fex_col: 'First Name';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZLASTNAME';                fex_col: 'Last Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZBLOBDATA';                fex_col: 'BlobData';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCONTACTID';               fex_col: 'Contact ID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

  Array_Items_iOS_Coco_Friend_Entity: TSQL_Table_array = (
  //(sql_col: 'DNT_Z_PK';                   fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_ENT';                  fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_Z_OPT';                  fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZCREATETIME';              fex_col: 'Create Time';                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZUPDATETIME';              fex_col: 'Update Time';                  read_as: ftLargeInt;    convert_as: 'UNIX_MS';  col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_ZUSERNAME';                fex_col: 'Username';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZFRIENDUID';               fex_col: 'Friend UID';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZAVATARPREVURL';           fex_col: 'Avatarprevurl';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  //(sql_col: 'DNT_ZMD5PHONE';              fex_col: 'Md5Phone';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZSIGNATURE';               fex_col: 'Signature';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_ZBLOBDATA';                fex_col: 'Blobdata';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

begin
  if Name = 'COCO_CHAT_ANDROID'    then Result := Array_Items_Android_Coco_Chat else
  if Name = 'COCO_FRIEND_ANDROID'  then Result := Array_Items_Android_Coco_FriendModel else
  if Name = 'COCO_USER_ANDROID'    then Result := Array_Items_Android_Coco_UserModel else
  if Name = 'COCO_CHAT_IOS'        then Result := Array_Items_iOS_Coco_Chat else
  if Name = 'COCO_CONTACT_IOS'     then Result := Array_Items_iOS_Coco_Contact_Entity else
  if Name = 'COCO_FRIEND_IOS'      then Result := Array_Items_iOS_Coco_Friend_Entity else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.