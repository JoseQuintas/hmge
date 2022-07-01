SendMail2  adapted from: Multiple Mail v1.0 Copyright (c) 2007 Grigory Filatov
================================================================================

  Sendmail2 is 32-bit FREEWARE
program that allows to send a many files to one mailbox.
For example, big foto, music, archives etc.
You select the files for sending and program will create
a mail for each file automatically and send it.

Features:
~~~~~~~~~
· Multiple file selection
· Drag & Drop support
· Save addresses and subjects of messages
· Tuning of smtp-server and port
· Show size for each file, total size and quantity of files
· Portable application

Distribution
~~~~~~~~~~~~
  Distribute it freely, provided that any part of the 
program or files included is not modified.

  Multiple Mail is provided as is, without warranty of any kind.
The author assumes no liability for damages, direct or
indirect, which may result from the use of Multiple Mail.

  To report a bug or to make a suggestion write to:
gfilatov@gmail.com

IMPORTANT: THIS DEMO PROGRAM IS NOT UNICODE

March 2022
Enhanced by Pierpaolo Martinello and supervisioned by Grigory Filatov.
1)  Added the management of comboboxes (desination and subject).
2)  Improved TakeDrop function that now withstands filtering
    of multiple file types and avoids the introduction of duplicate files.
3)  Added sender management (avoid errors for double ">" or "<").
4)  Added sending settings on statusbar
5)  Sending options now include CURL, CDO, TSMTP
6)  In the "about" I changed your address from gfilatov@inbox.ru to gfilatov@gmail.com.
7)  In the CDO section added <pre>MsgBody</pre> clause that normalizes
    text and carriage returns
8)  At program startup, restore of the last choices made and saved.
9)  Added read receipt for all 3 sending modes
10) Optimized error reporting with CURL
11) Disabled the commands and send buttons until the procedure is completed
12) Renamed the config.ini file to MailConfig.ini
13) Now send emails even without attachments
14) Adopted html body by default
15) Added the ability to see and hide the authentication password

February 2022
Revised  by Pierpaolo Martinello
In this version the program's abilities are extended by introducing
the possibility of interact in SSL with mail servers.
NOTE:
This characteristic require Windows 10 build 17063, or later.

NOTE: Not all the features of the original program are functional
