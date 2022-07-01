#include <hmg.ch>

PROCEDURE edit_ISS

   PUBLIC NewRec := .F. , EditRec := .F. , _qry_exp := ""

   open_iss()

   IssDef()
   
   Use_iss() 
   
   DEFINE WINDOW win_iss ;
      AT 20,20 ;
      WIDTH 800 ;
      HEIGHT 700 ;
      TITLE "Inno setup file" ;
      MODAL ;
      ON RELEASE dbcloseall()
  
	  ON KEY ESCAPE ACTION CancelEdit_7384()
	  
	  ON KEY F4   ACTION ( EditRec := .T., NewRec := .F., If ( RecordStatus_7384(), EnableField_7384(), Nil ))
	  ON KEY F6   ACTION ( NewRec := .T., EditRec = .F., NewRecord_7384() )
	  ON KEY F8   ACTION ( RecordStatus_7384(), DeleteRecord_7384(), Nil )
	  ON KEY F9   ACTION PrintData_7384()
	  ON KEY F10  ACTION win_iss.Release

      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "setup file"
         *KEYBOARD
         *DATE
         *CLOCK
		 STATUSITEM "" WIDTH 50
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER

      BUTTON FIRST_7384 ;
         CAPTION "First" ;
         PICTURE "go_first" ;
         ACTION( dbGotop(), win_iss.Browse_1.Value := RecNo() )

      BUTTON PREV_7384 ;
         CAPTION "Prev" ;
         PICTURE "go_prev" ;
         ACTION( dbSkip( -1 ), win_iss.Browse_1.Value := RecNo() )

      BUTTON NEXT_7384 ;
         CAPTION "Next" ;
         PICTURE "go_next" ;
         ACTION( dbSkip(), if ( Eof(), dbGobottom(), Nil ), win_iss.Browse_1.Value := RecNo() )

      BUTTON LAST_7384 ;
         CAPTION "Last" ;
         PICTURE "go_last" ;
         ACTION( dbGoBottom(), win_iss.Browse_1.Value := RecNo() )   SEPARATOR 
/*
      BUTTON FIND_7384 ;
         CAPTION "Find" ;
         PICTURE "edit_find" ;
         ACTION Find_7384()
*/
      BUTTON EDIT_7384 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION ( EditRec := .T., NewRec := .F., If ( RecordStatus_7384(), EnableField_7384(), Nil ))

      BUTTON NEW_7384 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( NewRec := .T., EditRec = .F., NewRecord_7384() )

      BUTTON DELETE_7384 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_7384(), DeleteRecord_7384(), Nil )

      BUTTON PRINT_7384 ;
         CAPTION "[F9] Print" ;
         PICTURE "edit_print" ;
         ACTION PrintData_7384()

      BUTTON EXIT_7384 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION win_iss.Release

      END TOOLBAR

      PaintDisplay_7384()

      @ 90,10 BROWSE Browse_1 ;
         OF win_iss ;
         WIDTH 750 ;
         HEIGHT 300 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "GROUP","ITEM","TEXT","GNO","INO" } ;
         WIDTHS { 90,270,270,50,50 } ;
         WORKAREA _ISS ;
         FIELDS { "GROUP","ITEM","TEXT","GROUPNO","ITEMNO" } ;
         ON CHANGE LoadData_7384() ;
         ON HEADCLICK { {||head1_7384()}, {||head2_7384()} } ;
         ON DBLCLICK ( EnableField_7384(), If ( ! RecordStatus_7384(), DisableField_7384(), Nil ) ) ;
         JUSTIFY { , , , BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, } 

      @ 580, 50 BUTTON SAVE_7384 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_7384() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,300 BUTTON QUERY_7384 ;
         CAPTION "Query" ;
         PICTURE "edit_find" RIGHT ;
         ACTION QueryRecord_7384() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_7384 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_7384() ;
         WIDTH 100 ;
         HEIGHT 40 
		 
      @ 580,650 BUTTON GENISS_7384 ;
         CAPTION "Generate" ;
         ACTION IssGen() ;
         WIDTH 100 ;
         HEIGHT 40 
		 
   END WINDOW

   DisableField_7384()

   win_iss.Browse_1.SetFocus
   win_iss.Browse_1.Value := _ISS->(RecNo())

   ACTIVATE WINDOW win_iss

RETURN
*:---------------------------------------------*
PROCEDURE DisableField_7384

   win_iss.Browse_1.Enabled      := .T.
   win_iss.Query_7384.Visible      := .F.

   win_iss.mGROUP.Enabled        := .F.
   win_iss.mITEM.Enabled         := .F.
   win_iss.mTEXT.Enabled         := .F.
   win_iss.mGROUPNO.Enabled      := .F.
   win_iss.mITEMNO.Enabled       := .F.

   win_iss.Save_7384.Enabled     := .F.
   win_iss.Cancel_7384.Enabled   := .F.
   win_iss.Query_7384.Enabled    := .F.
   win_iss.Toolbar_1.Enabled     := .T.
   win_iss.Browse_1.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE EnableField_7384

   win_iss.Browse_1.Enabled      := .F.

   win_iss.mGROUP.Enabled        := .T.
   win_iss.mITEM.Enabled         := .T.
   win_iss.mTEXT.Enabled         := .T.
   win_iss.mGROUPNO.Enabled      := .T.
   win_iss.mITEMNO.Enabled       := .T.

   win_iss.Save_7384.Enabled     := .T.
   win_iss.Cancel_7384.Enabled   := .T.
   win_iss.Query_7384.Enabled    := .F.
   win_iss.Toolbar_1.Enabled     := .F.
   win_iss.mITEM.SetFocus

RETURN
*:---------------------------------------------*
FUNCTION RecordStatus_7384()

   Local RetVal

   _ISS->( dbGoTo ( win_iss.Browse_1.Value ) )

   IF _ISS->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*:---------------------------------------------*
PROCEDURE LoadData_7384

   _ISS->( dbGoTo ( win_iss.Browse_1.Value ) )

   win_iss.mGROUP.Value        := _ISS->GROUP     
   win_iss.mITEM.Value         := _ISS->ITEM      
   win_iss.mTEXT.Value         := _ISS->TEXT      
   win_iss.mGROUPNO.Value      := _ISS->GROUPNO   
   win_iss.mITEMNO.Value       := _ISS->ITEMNO    

RETURN
*:---------------------------------------------*
PROCEDURE CancelEdit_7384

   DisableField_7384()
   LoadData_7384()
   UNLOCK
   NewRec := .F.

RETURN
*:---------------------------------------------*
PROCEDURE SaveRecord_7384

   Local NewRecNo

   DisableField_7384()

   IF NewRec == .T.
      _ISS->(dbAppend())
      NewRec := .F.
   ELSE
      _ISS->(dbGoto ( win_iss.Browse_1.Value ) )
   ENDIF

   NewRecNo := _ISS->( RecNo() )

   _ISS->GROUP      := win_iss.mGROUP.Value
   _ISS->ITEM       := win_iss.mITEM.Value
   _ISS->TEXT       := win_iss.mTEXT.Value
   _ISS->GROUPNO    := win_iss.mGROUPNO.Value
   _ISS->ITEMNO     := win_iss.mITEMNO.Value

   win_iss.Browse_1.Refresh
   IF NewRec == .T.
      win_iss.Browse_1.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   win_iss.StatusBar.Item(1) := "Save Record" 

RETURN
*:---------------------------------------------*
PROCEDURE NewRecord_7384

   win_iss.StatusBar.Item(1) := "Editing" 

   SET ORDER TO 1
   dbGoBottom()

   win_iss.mGROUP.Value        := space(10)
   win_iss.mITEM.Value         := space(30)
   win_iss.mTEXT.Value         := space(30)
   win_iss.mGROUPNO.Value      := 0
   win_iss.mITEMNO.Value       := 0

   EnableField_7384()

   win_iss.mITEM.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE DeleteRecord_7384

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _ISS->(FLock())
         DELETE
         win_iss.Browse_1.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*:---------------------------------------------*
PROCEDURE Find_7384

   win_iss.StatusBar.Item(1) := "Query" 
   win_iss.Query_7384.Visible := .T.

   win_iss.mGROUP.Value        := space(10)
   win_iss.mITEM.Value         := space(30)
   win_iss.mTEXT.Value         := space(30)
   win_iss.mGROUPNO.Value      := 0
   win_iss.mITEMNO.Value       := 0

   EnableField_7384()
   win_iss.Save_7384.Enabled  := .F.
   win_iss.Query_7384.Enabled := .T.
   win_iss.mGROUP.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE PrintData_7384

   Local RecRec 

   RecRec := _ISS->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "ISS" ;
      HEADERS { "","","","","" }, { "GROUP","ITEM","TEXT","GROUPNO","ITEMNO" } ;
      FIELDS { "GROUP","ITEM","TEXT","GROUPNO","ITEMNO" } ;
      WIDTHS { 11,31,31,8,7 } ;
      TOTALS { .F.,.F.,.F.,.F.,.F. } ;
      WORKAREA _ISS ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _ISS->(dbGoTo(RecRec))

RETURN
*:---------------------------------------------*
PROCEDURE PaintDisplay_7384

   @ 400,10 FRAME Frame_1 WIDTH 750 HEIGHT 150

   @ 410,  20 LABEL Label_1 VALUE "GROUP"
   @ 410, 120 LABEL Label_2 VALUE "ITEM"
   @ 410, 380 LABEL Label_3 VALUE "TEXT"
   @ 410, 650 LABEL Label_4 VALUE "GNO"
   @ 410, 690 LABEL Label_5 VALUE "INO"

   @ 430,  20 TEXTBOX  mGROUP       WIDTH 90
   @ 430, 120 TEXTBOX  mITEM        WIDTH 250    
   @ 430, 380 TEXTBOX  mTEXT        WIDTH 250 
   @ 430, 650 TEXTBOX  mGROUPNO     WIDTH 30 NUMERIC INPUTMASK "99"
   @ 430, 690 TEXTBOX  mITEMNO      WIDTH 30 NUMERIC INPUTMASK "99"

RETURN
*:---------------------------------------------*
PROCEDURE Head1_7384

   SELECT _ISS
   SET ORDER TO 1
   dbGotop()
   win_iss.Browse_1.Value := RecNo()
   win_iss.Browse_1.Refresh
   LoadData_7384()

RETURN
*:---------------------------------------------*
PROCEDURE Head2_7384

   SELECT _ISS
   SET ORDER TO 2
   dbGotop()
   win_iss.Browse_1.Value := RecNo()
   win_iss.Browse_1.Refresh
   LoadData_7384()

RETURN
*:---------------------------------------------*
PROCEDURE QueryRecord_7384

   PreQuery_7384()

   SET FILTER TO &_qry_exp
   dbGotop()

   IF ! EMPTY( _qry_exp )
      COUNT TO found_rec FOR &_qry_exp
      dbGotop()

      IF found_rec = 0
         win_iss.Statusbar.Item(1) := "Not found!"
      ELSE
         win_iss.Statusbar.Item(1) := "Found " + ALLTRIM(STR(found_rec)) + " record(s)!"
      ENDIF
   ENDIF

   DisableField_7384()

   win_iss.Browse_1.Refresh
   win_iss.Browse_1.Enabled   := .T.

RETURN
*:---------------------------------------------*
PROCEDURE PreQuery_7384

_qry_exp := ""
_ima_filter := .F.

IF ! EMPTY ( win_iss.mGROUP.Value )     // GROUP
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "GROUP = " + chr(34) + win_iss.mGROUP.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( win_iss.mITEM.Value )     // ITEM
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "ITEM = " + chr(34) + win_iss.mITEM.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( win_iss.mTEXT.Value )     // TEXT
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "TEXT = " + chr(34) + win_iss.mTEXT.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( win_iss.mGROUPNO.Value )     // GROUPNO
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "GROUPNO = " + STR( win_iss.mGROUPNO.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( win_iss.mITEMNO.Value )     // ITEMNO
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "ITEMNO = " + STR( win_iss.mITEMNO.Value )
      _ima_filter := .T.
ENDIF

RETURN
*:*********************************
*function GenIss

dbcloseall()

use _dbf new

use _apl new
_name = alltrim(name)
_title = alltrim(title)

use _iss index _iss new

if reccount() > 0
   dbcloseall()
   return
endif

_no = 1

select _iss

dbappend()
replace group with 'Setup'
replace item with 'AppName'
replace text with _title
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'AppVersion'
replace text with '1.0'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'DefaultDirName'
replace text with '{pf}\' + _name
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'DefaultGroupName'
replace text with 'hmgcase'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'UninstallDisplayIcon'
replace text with '{app}\' + _name + '.exe'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'Compression'
replace text with 'lzma2'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'SolidCompression'
replace text with 'yes'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'OutputDir'
replace text with 'userdocs:Inno Setup'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Files'
replace item with 'Source'
replace text with _name + '.exe'
replace groupno with 2
replace itemno with _no++

_dbfname = ''

select _dbf
do while .not. eof()

if _dbfname = dbf_name
   dbskip()
   loop
endif

_dbfname = dbf_name

select _iss
dbappend()
replace group with 'Files'
replace item with 'Source'
replace text with alltrim(lower(_dbfname)) + '.dbf'
replace groupno with 2
replace itemno with _no++

select _dbf
dbskip()
enddo

dbcloseall()

msginfo('Create initial data')

return 0
*:************************************************************
function IssDef ()

dbcloseall()

use _dbf new

use _apl new
_name = alltrim(name)
_title = alltrim(title)

use _iss index _iss new

if reccount() > 0
   dbcloseall()
   return
endif

_no = 1

select _iss

dbappend()
replace group with 'Setup'
replace item with 'AppName'
replace text with _title
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'AppVersion'
replace text with '1.0'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'DefaultDirName'
replace text with '{pf}\' + _name
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'DefaultGroupName'
replace text with 'hmgcase'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'UninstallDisplayIcon'
replace text with '{app}\' + _name + '.exe'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'Compression'
replace text with 'lzma2'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'SolidCompression'
replace text with 'yes'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Setup'
replace item with 'OutputDir'
replace text with 'userdocs:Inno Setup'
replace groupno with 1
replace itemno with _no++

dbappend()
replace group with 'Files'
replace item with 'Source'
replace text with _name + '.exe'
replace groupno with 2
replace itemno with _no++

_dbfname = ''

select _dbf
do while .not. eof()

if _dbfname = dbf_name
   dbskip()
   loop
endif

_dbfname = dbf_name

select _iss
dbappend()
replace group with 'Files'
replace item with 'Source'
replace text with alltrim(lower(_dbfname)) + '.dbf'
replace groupno with 2
replace itemno with _no++

select _dbf
dbskip()
enddo

dbcloseall()

return 0
*:***********************************************************************
function IssGen ()

dbcloseall()

use _apl new
_name = name

use _iss index _iss new

_iss_file = alltrim(_name) + '.iss'

set device to printer 
set printer to &_iss_file

tek_red = 0
@ tek_red, 0  say '; --- ' + _iss_file + ' --- '
tek_red++
@ tek_red, 0  say '; --- generate by HmgCase --- '

tek_red++
tek_red++
@ tek_red, 0  say '; see documentation for details on creating .ISS script file'

_grup = ''

do while .not. eof()

if _grup != group

   _grup = group
   tek_red++
   tek_red++
   @ tek_red, 0  say '[' + alltrim(_grup) +']'

endif

if groupno = 1
   tek_red++
   @ tek_red, 0  say alltrim(item) + '=' + alltrim(text)
else
   tek_red++
   @ tek_red, 0  say alltrim(item) + ': "' + alltrim(text) + '"; DestDir: "{app}"'
endif

dbskip()
enddo

tek_red++
tek_red++
@ tek_red, 0  say '[Icons]'
tek_red++
@ tek_red, 0  say 'Name:  "{group}\' + alltrim(_name) + '"; Filename: "{app}\' + alltrim(_name) + '.exe"'

set printer to
set device to screen
setprc(0,0)

dbcloseall()

msginfo('Generate ' + _iss_file + ' !' )

win_iss.Release

return 0
*:****************************************************************
PROCEDURE open_iss

LOCAL alist_fld

if ! file ("_ISS.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"GROUP","C",10,0})
   aadd(alist_fld,{"ITEM","C",30,0})
   aadd(alist_fld,{"TEXT","C",30,0})
   aadd(alist_fld,{"GROUPNO","N",2,0})
   aadd(alist_fld,{"ITEMNO","N",2,0})
   dbcreate("_ISS",alist_fld)
endif

if ! file ("_ISS.ntx")
   use _ISS
   index on STR(GROUPNO,2,0)+STR(ITEMNO,2,0) to _ISS
   use 
endif

RETURN
*:***********************************************************
PROCEDURE USE_ISS

   USE _iss INDEX _iss NEW 

RETURN
