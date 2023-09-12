unit ProtonMail;

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

  Array_Items_ANDROID: TSQL_Table_array = (
  (sql_col: 'DNT_TIME';                    fex_col: 'Date';                   read_as: ftFloat;       convert_as: 'UNIX';     col_type: ftDateTime;   show: True),
  (sql_col: 'DNT_SUBJECT';                 fex_col: 'Subject';                read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SENDER_SENDERNAME';       fex_col: 'Sender';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SENDER_SENDERSERIALIZED'; fex_col: 'Sender Email';           read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_HEADER';                  fex_col: 'Header';                 read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  (sql_col: 'DNT_SIZE';                    fex_col: 'Size';                   read_as: ftString;      convert_as: '';         col_type: ftString;     show: True),
  );

//  Array_Items_PROTONMAIL_ANDROID: TSQL_Table_array = (
//  (sql_col: 'DNT_Datesentms';              fex_col: 'Date Sent';            read_as: ftLargeInt;    convert_as: 'UNIX_MS';   col_type: ftDateTime;   show: True),
//  (sql_col: 'DNT_Datereceivedms';          fex_col: 'Date Received';        read_as: ftLargeInt;    convert_as: 'UNIX_MS';   col_type: ftDateTime;   show: True),
//  (sql_col: 'DNT_Subject';                 fex_col: 'Subject';              read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Snippet';                 fex_col: 'Snippet';              read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Body';                    fex_col: 'Body';                 read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Fromaddress';             fex_col: 'From Address';         read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Toaddresses';             fex_col: 'To Addresses';         read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Rfcid';                   fex_col: 'RFCID';                read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Ccaddresses';             fex_col: 'CC Addresses';         read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Bccaddresses';            fex_col: 'BCC Addresses';        read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Replytoaddresses';        fex_col: 'Reply To Addresses';   read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Untrustedaddresses';      fex_col: 'Untrusted Addresses';  read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Messageid';               fex_col: 'Message ID';           read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Conversation';            fex_col: 'Conversation';         read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Spf';                     fex_col: 'Spf';                  read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Dkim';                    fex_col: 'Dkim';                 read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_Mailjsbody';              fex_col: 'Mailjsbody';           read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  (sql_col: 'DNT_SQLLOCATION';             fex_col: 'Location';             read_as: ftString;      convert_as: '';          col_type: ftString;     show: True),
//  );


  Array_Items_PROTONMAIL_ANDROID: TSQL_Table_array = (
   (sql_col: 'DNT_TIME';                     fex_col: 'Timestamp';            read_as: ftLargeInt;     convert_as: 'UNIX';    col_type: ftDateTime;     show: True),
   (sql_col: 'DNT_SENDER_SENDERNAME';        fex_col: 'Sender Name';          read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_SENDER_SENDERSERIALIZED';  fex_col: 'Sender Serialized';    read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_SUBJECT';                  fex_col: 'Subject';              read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_MIMETYPE';                 fex_col: 'MIME Type';            read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_SIZE';                     fex_col: 'Size';                 read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_TYPE';                     fex_col: 'Type';                 read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ADDRESSID';                fex_col: 'Address ID';           read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_CONVERSATIONID';           fex_col: 'Conversation ID';      read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_HEADER';                   fex_col: 'Headers';              read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ID';                       fex_col: 'Proton ID';            read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ISDOWNLOADED';             fex_col: 'Is Downloaded';        read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ISENCRYPTED';              fex_col: 'Is Proton Encrypted';  read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ISFORWARDED';              fex_col: 'Is Forwarded';         read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ISREPLIED';                fex_col: 'Is Replied';           read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_ISREPLIEDALL';             fex_col: 'Is Replied All';       read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_LABELIDS';                 fex_col: 'Label IDs';            read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_LOCATION';                 fex_col: 'Proton Location';      read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_NUMATTACHMENTS';           fex_col: 'Attachments';          read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_UNREAD';                   fex_col: 'Unread';               read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
   (sql_col: 'DNT_SQLLOCATION';              fex_col: 'Location';             read_as: ftString;       convert_as: '';        col_type: ftString;       show: True),
  );

begin
  if Name = 'PROTONMAIL_ANDROID' then Result := Array_Items_PROTONMAIL_ANDROID else
    Progress.Log(format('%-54s %-100s', ['Error: Did not locate artifact column layout:', Name]));  
end;

end.