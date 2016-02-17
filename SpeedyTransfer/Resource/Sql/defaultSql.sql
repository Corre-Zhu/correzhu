CREATE TABLE IF NOT EXISTS FileTransfer (
ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
Identifier VARCHAR(64) DEFAULT '',
FriendId Varchar DEFAULT '',
FileType INTEGER DEFAULT 0,
TransferType INTEGER DEFAULT 0,
TransferStatus INTEGER DEFAULT 0,
Url TEXT DEFAULT '',
Vcard TEXT DEFAULT '',
FileName TEXT DEFAULT '',
FileDate Varchar(64) DEFAULT '',
FileSize Double DEFAULT 0,
DownloadSpeed Double DEFAULT 0);

CREATE TABLE IF NOT EXISTS STUserInfo (
ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT DEFAULT 0,
UserId Varchar UNIQUE DEFAULT '',
Nickname Varchar DEFAULT '',
HeadUrl Varchar DEFAULT '');

CREATE TABLE IF NOT EXISTS FeedbackMessages (
ID integer  NOT NULL  PRIMARY KEY AUTOINCREMENT DEFAULT 0,
MESSAGEID Varchar(64) DEFAULT '',
TRANSFERSTATUS integer DEFAULT 0,
MESSAGETYPE integer DEFAULT 0,
CONTENT TEXT DEFAULT '',
TIME Varchar(64) DEFAULT 0);