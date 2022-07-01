#include <hmg.ch>

PROCEDURE ntx_edit

   PUBLIC New := .F. , _qry_exp := ""

   Use _ntx INDEX _ntx

   DEFINE WINDOW Win_2_1 ;
      AT 20,20 ;
      WIDTH 800 ;
      HEIGHT 700 ;
      TITLE "Indexes" ;
      MODAL ;
      ON RELEASE re_order_ntx()

      ON KEY ESCAPE ACTION CancelEdit_2604()
            
	  ON KEY F7   ACTION Find_2604()
	  ON KEY F4   ACTION If ( RecordStatus_2604(), EnableField_2604(), Nil )
	  ON KEY F6   ACTION ( New := .T., NewRecord_2604() )
	  ON KEY F8   ACTION ( RecordStatus_2604(), DeleteRecord_2604(), Nil )
	  *ON KEY F9   ACTION PrintData_2604()
	  ON KEY F10   ACTION Win_2_1.Release
			
      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "Indexes"
         *KEYBOARD
         *DATE
         *CLOCK
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_2_1 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER
/*
      BUTTON FIRST_2604 ;
         CAPTION "First" ;
         PICTURE "go_first" ;
         ACTION( dbGotop(), Win_2_1.Browse_2_1.Value := RecNo() )

      BUTTON PREV_2604 ;
         CAPTION "Prev" ;
         PICTURE "go_prev" ;
         ACTION( dbSkip( -1 ), Win_2_1.Browse_2_1.Value := RecNo() )

      BUTTON NEXT_2604 ;
         CAPTION "Next" ;
         PICTURE "go_next" ;
         ACTION( dbSkip(), if ( Eof(), dbGobottom(), Nil ), Win_2_1.Browse_2_1.Value := RecNo() )

      BUTTON LAST_2604 ;
         CAPTION "Last" ;
         PICTURE "go_last" ;
         ACTION( dbGoBottom(), Win_2_1.Browse_2_1.Value := RecNo() )   SEPARATOR 

      BUTTON FIND_2604 ;
         CAPTION "[F7 ]Find" ;
         PICTURE "edit_find" ;
         ACTION Find_2604()
*/		 
      BUTTON EDIT_2604 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION If ( RecordStatus_2604(), EnableField_2604(), Nil )

      BUTTON NEW_2604 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( New := .T., NewRecord_2604() )

      BUTTON DELETE_2604 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_2604(), DeleteRecord_2604(), Nil )
/*
      BUTTON PRINT_2604 ;
         CAPTION "[F9 ]Print" ;
         PICTURE "edit_print" ;
         ACTION PrintData_2604()
*/
      BUTTON EXIT_2604 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION Win_2_1.Release

      END TOOLBAR

      PaintDisplay_2604()

      @ 90,10 BROWSE Browse_2_1 ;
         OF Win_2_1 ;
         WIDTH 750 ;
         HEIGHT 250 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "DBF","Ord","NTX","Unique?","Key" } ;
         WIDTHS { 100,50,100,80,400 } ;
         WORKAREA _NTX ;
         FIELDS { "DBF_NAME","ORDER","NTX_NAME","NTX_UNIQ","KEY" } ;
         ON CHANGE LoadData_2604() ;
         ON DBLCLICK ( EnableField_2604(), If ( ! RecordStatus_2604(), DisableField_2604(), Nil ) )

      @ 580, 50 BUTTON SAVE_2604 ;
         CAPTION "Save" ;
         PICTURE "ok" ;
         ACTION SaveRecord_2604() ;
         RIGHT ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_2604 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" ;
         ACTION CancelEdit_2604() ;
         RIGHT ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,300 BUTTON QUERY_2604 ;
         CAPTION "Query" ;
         PICTURE "edit_find" ;
         ACTION QueryRecord_2604() ;
         RIGHT ;
         WIDTH 100 ;
         HEIGHT 40 

   END WINDOW

   DisableField_2604()

   Win_2_1.Browse_2_1.SetFocus
   Win_2_1.Browse_2_1.Value := _NTX->(RecNo())

   ACTIVATE WINDOW Win_2_1

RETURN
*---------------------------------------------*
PROCEDURE DisableField_2604

   Win_2_1.Browse_2_1.Enabled     := .T.

   Win_2_1.Control_1.Enabled    := .F.
   Win_2_1.Control_2.Enabled    := .F.
   Win_2_1.Control_3.Enabled    := .F.
   Win_2_1.Control_4.Enabled    := .F.
   Win_2_1.Control_5.Enabled    := .F.

   Win_2_1.Save_2604.Enabled     := .F.
   Win_2_1.Cancel_2604.Enabled   := .F.
   Win_2_1.Query_2604.Enabled    := .F.
   Win_2_1.Toolbar_2_1.Enabled    := .T.
   Win_2_1.Browse_2_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE EnableField_2604

   Win_2_1.Browse_2_1.Enabled     := .F.

   Win_2_1.Control_1.Enabled    := .T.
   Win_2_1.Control_2.Enabled    := .T.
   Win_2_1.Control_3.Enabled    := .T.
   Win_2_1.Control_4.Enabled    := .T.
   Win_2_1.Control_5.Enabled    := .T.

   Win_2_1.Save_2604.Enabled     := .T.
   Win_2_1.Cancel_2604.Enabled   := .T.
   Win_2_1.Query_2604.Enabled    := .F.
   Win_2_1.Toolbar_2_1.Enabled    := .F.
   Win_2_1.Control_1.SetFocus

RETURN
*---------------------------------------------*
FUNCTION RecordStatus_2604()

   Local RetVal

   _NTX->( dbGoTo ( Win_2_1.Browse_2_1.Value ) )

   IF _NTX->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*---------------------------------------------*
PROCEDURE LoadData_2604

   _NTX->( dbGoTo ( Win_2_1.Browse_2_1.Value ) )

   Win_2_1.Control_1.Value    := _NTX->DBF_NAME  
   Win_2_1.Control_2.Value    := _NTX->ORDER     
   Win_2_1.Control_3.Value    := _NTX->NTX_NAME  
   Win_2_1.Control_4.Value    := _NTX->NTX_UNIQ  
   Win_2_1.Control_5.Value    := _NTX->KEY       

RETURN
*---------------------------------------------*
PROCEDURE CancelEdit_2604

   DisableField_2604()
   LoadData_2604()
   UNLOCK
   New := .F.

RETURN
*---------------------------------------------*
PROCEDURE SaveRecord_2604

   Local NewRecNo

   DisableField_2604()

   IF New == .T.
      _NTX->(dbAppend())
      New := .F.
   ELSE
      _NTX->(dbGoto ( Win_2_1.Browse_2_1.Value ) )
   ENDIF

   NewRecNo := _NTX->( RecNo() )

   _NTX->DBF_NAME   := Win_2_1.Control_1.Value
   _NTX->ORDER      := Win_2_1.Control_2.Value
   _NTX->NTX_NAME    := Win_2_1.Control_3.Value
   _NTX->NTX_UNIQ    := Win_2_1.Control_4.Value
   _NTX->KEY        := Win_2_1.Control_5.Value

   Win_2_1.Browse_2_1.Refresh
   IF New == .T.
      Win_2_1.Browse_2_1.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   Win_2_1.StatusBar.Item(1) := "Save Record" 

RETURN
*---------------------------------------------*
PROCEDURE NewRecord_2604

   Win_2_1.StatusBar.Item(1) := "Editing" 

   SET ORDER TO 1
   dbGoBottom()

   Win_2_1.Control_1.Value   := space(8)
   Win_2_1.Control_2.Value   := 0
   Win_2_1.Control_3.Value   := space(8)
   Win_2_1.Control_4.Value   := space(1)
   Win_2_1.Control_5.Value   := space(80)

   EnableField_2604()

   Win_2_1.Control_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE DeleteRecord_2604

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _NTX->(FLock())
         DELETE
         Win_2_1.Browse_2_1.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*---------------------------------------------*
PROCEDURE Find_2604

   Win_2_1.StatusBar.Item(1) := "Query" 

   Win_2_1.Control_1.Value   := space(10)
   Win_2_1.Control_2.Value   := 0
   Win_2_1.Control_3.Value   := space(10)
   Win_2_1.Control_4.Value   := space(1)
   Win_2_1.Control_5.Value   := space(80)

   EnableField_2604()
   Win_2_1.Save_2604.Enabled  := .F.
   Win_2_1.Query_2604.Enabled := .T.
   Win_2_1.Control_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE PrintData_2604

   Local RecRec 

   RecRec := _NTX->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "INDEX" ;
      HEADERS { "","","","","" }, { "DBF","Ord","NTX","Unique?","Key" } ;
      FIELDS { "DBF_NAME","ORDER","NTX_NAME","NTX_UNIQ","KEY" } ;
      WIDTHS { 9,4,9,8,81 } ;
      TOTALS { .F.,.F.,.F.,.F.,.F. } ;
      WORKAREA _NTX ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _NTX->(dbGoTo(RecRec))

RETURN
*---------------------------------------------*
PROCEDURE PaintDisplay_2604

   @ 400,10 FRAME Frame_2_1 WIDTH 750 HEIGHT 150

   @ 430,  20 LABEL Label_1 VALUE "DBF"
   @ 430, 150 LABEL Label_2 VALUE "Ord"
   @ 430, 280 LABEL Label_3 VALUE "NTX"
   @ 430, 410 LABEL Label_4 VALUE "Unique?"
   @ 480,  20 LABEL Label_5 VALUE "Key"

   @ 450,  20 TEXTBOX  Control_1           UPPERCASE
   @ 450, 150 TEXTBOX  Control_2 WIDTH  50 NUMERIC INPUTMASK "99"
   @ 450, 280 TEXTBOX  Control_3           UPPERCASE
   @ 450, 410 TEXTBOX  Control_4 WIDTH  50 INPUTMASK "!"
   @ 500,  20 TEXTBOX  Control_5 WIDTH 500 UPPERCASE

RETURN
*---------------------------------------------*
PROCEDURE QueryRecord_2604

   PreQuery_2604()

   SET FILTER TO &_qry_exp
   dbGotop()

   IF ! EMPTY( _qry_exp )
      COUNT TO found_rec FOR &_qry_exp
      dbGotop()

      IF found_rec = 0
         Win_2_1.Statusbar.Item(1) := "Not found!"
      ELSE
         Win_2_1.Statusbar.Item(1) := "Found " + ALLTRIM(STR(found_rec)) + " record(s)!"
      ENDIF
   ENDIF

   DisableField_2604()

   Win_2_1.Browse_2_1.Refresh
   Win_2_1.Browse_2_1.Enabled   := .T.

RETURN
*---------------------------------------------*
PROCEDURE PreQuery_2604

_qry_exp := ""
_ima_filter := .F.

IF ! EMPTY ( Win_2_1.Control_1.Value )     // DBF_NAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "DBF_NAME = " + chr(34) + Win_2_1.Control_1.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_2_1.Control_2.Value )     // ORDER
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "ORDER = " + STR( Win_2_1.Control_2.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_2_1.Control_3.Value )     // NTX_NAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "NTX_NAME = " + chr(34) + Win_2_1.Control_3.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_2_1.Control_4.Value )     // NTX_UNIQ
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "NTX_UNIQ = " + chr(34) + Win_2_1.Control_4.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_2_1.Control_5.Value )     // KEY
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "KEY = " + chr(34) + Win_2_1.Control_5.Value + chr(34)
      _ima_filter := .T.
ENDIF

RETURN
*-------------------------------------*
procedure re_order_ntx

dbcloseall()

Use _ntx index _ntx
copy to _work

dbcloseall()

select 2
use _ntx index _ntx
zap

select 1
use _work 
index on dbf_name + str(order,2) to _work

_dbf = dbf_name
_ord = 0

do while .not. eof()

   _DBF_NAME = DBF_NAME
   _ORDER = ORDER
   _NTX_NAME = NTX_NAME
   _NTX_UNIQ = NTX_UNIQ
   _KEY = KEY

   IF _DBF != _DBF_NAME
      _ORD = 1
   ELSE
      _ORD++
   ENDIF

   SELECT 2
   DBAPPEND()
   REPLACE DBF_NAME WITH UPPER(_DBF_NAME)
   REPLACE ORDER WITH _ORD
   REPLACE NTX_NAME WITH UPPER(_NTX_NAME)
   REPLACE NTX_UNIQ WITH _NTX_UNIQ
   REPLACE KEY WITH UPPER(_KEY)
   
   _DBF = _DBF_NAME
   
   SELECT 1 
   DBSKIP()
ENDDO

DBCLOSEALL()

DELETE FILE _WORK.DBF
DELETE FILE _WORK.NTX

RETURN
