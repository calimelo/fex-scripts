{!NAME:      Tumblr.pas}
{!DESC:      Artifact columns.}
{!AUTHOR:    GetData}

unit Tumblr;

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

    Array_Items_TumblrFollowedBlog: TSQL_Table_array = (
    //(sql_col: 'DNT_Z_PK';                       fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_ENT';                      fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_OPT';                      fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZNAME';                        fex_col: 'Blog Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZPLACEMENTIDENTIFIER';       fex_col: 'Placementidentifier';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZTITLE';                       fex_col: 'Title';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

    Array_Items_TumblrReBlog: TSQL_Table_array = (
    //(sql_col: 'DNT_Z_PK';                       fex_col: 'Pk';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_ENT';                      fex_col: 'Ent';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_OPT';                      fex_col: 'Opt';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZBLOGISACTIVE';              fex_col: 'Blogisactive';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZCURRENTCOMMENT';            fex_col: 'Currentcomment';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZROOTCOMMENT';               fex_col: 'Rootcomment';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZBLOG';                      fex_col: 'Blog';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZPOST';                      fex_col: 'Post';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z32_POST';                   fex_col: '32 Post';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_FOK_POST';                 fex_col: 'Fok Post';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZABSTRACTCONTENT';           fex_col: 'Abstractcontent';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZCONTENT';                     fex_col: 'Content';                      read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZREBLOGID';                    fex_col: 'Reblog ID';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZREBLOGGEDFROMID';             fex_col: 'Reblogged From ID';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZABSTRACTMARKUP';            fex_col: 'Abstractmarkup';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZMARKUP';                    fex_col: 'Markup';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

    Array_Items_TumblrUser_IOS: TSQL_Table_array = (
    (sql_col: 'DNT_ZNAME';                        fex_col: 'User Name';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZFOLLOWINGCOUNT';              fex_col: 'Followingcount';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZLIKESCOUNT';                  fex_col: 'Likescount';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_PK';                       fex_col: ' Pk';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_ENT';                      fex_col: ' Ent';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_OPT';                      fex_col: ' Opt';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZAUTOFBSTATE';               fex_col: 'Autofbstate';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZAUTOTWEETSTATE';            fex_col: 'Autotweetstate';               read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZBLOGSUBSCRIPTION';          fex_col: 'Blogsubscription';             read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZEMAILVERIFIED';             fex_col: 'Emailverified';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZMARKETINGNOTIFICATIONS';    fex_col: 'Marketingnotifications';       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZOWNSCUSTOMIZEDBLOGS';       fex_col: 'Ownscustomizedblogs';          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZPUSHNOTIFICATIONS';         fex_col: 'Pushnotifications';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZSAFESEARCH';                fex_col: 'Safesearch';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZSUBSCRIPTIONNOTIFICATIONS'; fex_col: 'Subscriptionnotifications';    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZDEFAULTPOSTFORMAT';         fex_col: 'Defaultpostformat';            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZKAHUNAID';                  fex_col: 'Kahunaid';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_ZGUIDESTATE';                fex_col: 'Guidestate';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                  fex_col: 'Location';                     read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

// Chat - iOS
    Array_Items_Tumblr_Chat_IOS: TSQL_Table_array = (
    //(sql_col: 'DNT_Z_PK';                     fex_col: ' Pk';                            read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_ENT';                    fex_col: ' Ent';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    //(sql_col: 'DNT_Z_OPT';                    fex_col: ' Opt';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZISBLURREDIMAGE';            fex_col: 'Isblurredimage';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZMESSAGETYPE';               fex_col: 'Messagetype';                    read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZSTATUS';                    fex_col: 'Status';                         read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZCONVERSATION';              fex_col: 'Conversation';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZFROMPARTICIPANT';           fex_col: 'Fromparticipant';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZPOST';                      fex_col: 'Post';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_Z48_POST';                   fex_col: '48 Post';                        read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZBODY';                      fex_col: 'Body';                           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZCLUSTERIDENTIFIER';         fex_col: 'Clusteridentifier';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZSECTIONIDENTIFIER';         fex_col: 'Sectionidentifier';              read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZTIMESTAMP';                 fex_col: 'Timestamp';                      read_as: ftLargeInt;    convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
    (sql_col: 'DNT_ZFORMATTEDBODY';             fex_col: 'Formattedbody';                  read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_ZIMAGE';                     fex_col: 'Image';                          read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    (sql_col: 'DNT_SQLLOCATION';                fex_col: 'Location';                       read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
    );

begin
  if Name = 'DNT_REBLOG'       then Result := Array_Items_TumblrReBlog else
  if Name = 'DNT_FOLLOWEDBLOG' then Result := Array_Items_TumblrFollowedBlog else
  if Name = 'DNT_USER'         then Result := Array_Items_TumblrUser_IOS else
  if Name = 'TUMBLR_CHAT_IOS'  then Result := Array_Items_Tumblr_Chat_IOS else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.
