#include <hmg.ch>

PROCEDURE apl_set

   PUBLIC New := .F. , _qry_exp := ""

   open_mnu()
   Use _aplset

   DEFINE WINDOW win_6_2 ;
      AT 20,20 ;
      WIDTH 800 ;
      HEIGHT 700 ;
      TITLE "Setings " ;
      MODAL

      ON KEY ESCAPE ACTION CancelEdit_6938()
	  
	  ON KEY F4   ACTION If ( RecordStatus_6938(), EnableField_6938(), Nil )
	  ON KEY F6   ACTION ( New := .T., NewRecord_6938() )
	  ON KEY F8   ACTION ( RecordStatus_6938(), DeleteRecord_6938(), Nil )
	  ON KEY F9   ACTION PrintData_6938()
	  ON KEY F10  ACTION win_6_2.Release

      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "Setings"
         *KEYBOARD
         *DATE
         *CLOCK
		 STATUSITEM "" WIDTH 50
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER

      BUTTON EDIT_6938 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION If ( RecordStatus_6938(), EnableField_6938(), Nil )

      BUTTON NEW_6938 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( New := .T., NewRecord_6938() )

      BUTTON DELETE_6938 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_6938(), DeleteRecord_6938(), Nil )

      BUTTON PRINT_6938 ;
         CAPTION "[9] Print" ;
         PICTURE "edit_print" ;
         ACTION PrintData_6938()

      BUTTON EXIT_6938 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION win_6_2.Release

      END TOOLBAR

      PaintDisplay_6938()

      @ 90,10 BROWSE Browse_1 ;
         OF win_6_2 ;
         WIDTH 500 ;
         HEIGHT 300 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "SETING" } ;
         WIDTHS { 410 } ;
         WORKAREA _APLSET ;
         FIELDS { "SETING" } ;
         ON CHANGE LoadData_6938() ;
         ON HEADCLICK { {||head1_6938()}, {||head2_6938()} } ;
         ON DBLCLICK ( EnableField_6938(), If ( ! RecordStatus_6938(), DisableField_6938(), Nil ) )

      @ 580, 50 BUTTON SAVE_6938 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_6938() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_6938 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_6938() ;
         WIDTH 100 ;
         HEIGHT 40 

//      @ 580,300 BUTTON QUERY_6938 ;
//         CAPTION "Query" ;
//         PICTURE "edit_find.bmp" RIGHT ;
//         ACTION QueryRecord_6938() ;
//         WIDTH 100 ;
//         HEIGHT 40 

   END WINDOW

   DisableField_6938()

   win_6_2.Browse_1.SetFocus
   win_6_2.Browse_1.Value := _APLSET->(RecNo())

   ACTIVATE WINDOW win_6_2

RETURN
*---------------------------------------------*
PROCEDURE DisableField_6938

   win_6_2.Browse_1.Enabled      := .T.

   win_6_2.mSETING.Enabled       := .F.

   win_6_2.Save_6938.Enabled     := .F.
   win_6_2.Cancel_6938.Enabled   := .F.
   // win_6_2.Query_6938.Enabled    := .F.
   win_6_2.Toolbar_1.Enabled     := .T.
   win_6_2.Browse_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE EnableField_6938

   win_6_2.Browse_1.Enabled      := .F.

   win_6_2.mSETING.Enabled       := .T.

   win_6_2.Save_6938.Enabled     := .T.
   win_6_2.Cancel_6938.Enabled   := .T.
   // win_6_2.Query_6938.Enabled    := .F.
   win_6_2.Toolbar_1.Enabled     := .F.
   win_6_2.mSETING.SetFocus

RETURN
*---------------------------------------------*
FUNCTION RecordStatus_6938()

   Local RetVal

   _APLSET->( dbGoTo ( win_6_2.Browse_1.Value ) )

   IF _APLSET->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*---------------------------------------------*
PROCEDURE LoadData_6938

   _APLSET->( dbGoTo ( win_6_2.Browse_1.Value ) )

   win_6_2.mSETING.Value       := _APLSET->SETING    

RETURN
*---------------------------------------------*
PROCEDURE CancelEdit_6938

   DisableField_6938()
   LoadData_6938()
   UNLOCK
   New := .F.

RETURN
*---------------------------------------------*
PROCEDURE SaveRecord_6938

   Local NewRecNo

   DisableField_6938()

   IF New == .T.
      _APLSET->(dbAppend())
      New := .F.
   ELSE
      _APLSET->(dbGoto ( win_6_2.Browse_1.Value ) )
   ENDIF

   NewRecNo := _APLSET->( RecNo() )

   _APLSET->SETING     := win_6_2.mSETING.Value

   win_6_2.Browse_1.Refresh
   IF New == .T.
      win_6_2.Browse_1.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   win_6_2.StatusBar.Item(1) := "Save Record" 

RETURN
*---------------------------------------------*
PROCEDURE NewRecord_6938

   win_6_2.StatusBar.Item(1) := "Editing" 

   SET ORDER TO 1
   dbGoBottom()

   win_6_2.mSETING.Value       := space(40)

   EnableField_6938()

   win_6_2.mSETING.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE DeleteRecord_6938

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _APLSET->(FLock())
         DELETE
         win_6_2.Browse_1.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*---------------------------------------------*
PROCEDURE Find_6938

   win_6_2.StatusBar.Item(1) := "Query" 

   win_6_2.mSETING.Value       := space(40)

   EnableField_6938()
   win_6_2.Save_6938.Enabled  := .F.
   // win_6_2.Query_6938.Enabled := .T.
   win_6_2.Control_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE PrintData_6938

   Local RecRec 

   RecRec := _APLSET->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "SETINGs" ;
      HEADERS { "" }, { "SETING" } ;
      FIELDS { "SETING" } ;
      WIDTHS { 41 } ;
      TOTALS { .F. } ;
      WORKAREA _APLSET ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _APLSET->(dbGoTo(RecRec))

RETURN
*---------------------------------------------*
PROCEDURE PaintDisplay_6938

   @ 400,  10 FRAME Frame_1 WIDTH 500 HEIGHT 100

   @ 420,  20 LABEL Label_1 VALUE "SET"

   @ 420,  60 TEXTBOX  mSETING      WIDTH 410 INPUTMASK REPLICATE("A",40)

RETURN
*---------------------------------------------*
PROCEDURE Head1_6938

   SELECT _APLSET
   SET ORDER TO 1
   dbGotop()
   win_6_2.Browse_1.Value := RecNo()
   win_6_2.Browse_1.Refresh
   LoadData_6938()

RETURN
*---------------------------------------------*
PROCEDURE Head2_6938

   SELECT _APLSET
   SET ORDER TO 2
   dbGotop()
   win_6_2.Browse_1.Value := RecNo()
   win_6_2.Browse_1.Refresh
   LoadData_6938()

RETURN
*---------------------------------------------*
PROCEDURE QueryRecord_6938

   PreQuery_6938()

   SET FILTER TO 
   dbGotop()

   IF ! EMPTY( _qry_exp )
      COUNT TO found_rec FOR &_qry_exp
      dbGotop()

      IF found_rec = 0
         win_6_2.Statusbar.Item(1) := "Not found!"
      ELSE
         win_6_2.Statusbar.Item(1) := "Found " + ALLTRIM(STR(found_rec)) + " record(s)!"
      ENDIF
   ENDIF

   DisableField_6938()

   win_6_2.Browse_1.Refresh
   win_6_2.Browse_1.Enabled   := .T.

RETURN
*---------------------------------------------*
PROCEDURE PreQuery_6938

_qry_exp := ""
_ima_filter := .F.

IF ! EMPTY ( win_6_2.mSETING.Value )     // SETING
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "SETING = " + chr(34) + win_6_2.mSETING.Value + chr(34)
      _ima_filter := .T.
ENDIF

RETURN
* end of program *