#include <hmg.ch>

PROCEDURE apl_mnu

   PUBLIC New := .F. , _qry_exp := ""
         
   open_mnu()
   Use _apladd index _apladd new
   Use _aplmnu index _aplmnu new
   
   DEFINE WINDOW win_6_3 ;
      AT 30,30 ;
      WIDTH 1000 ;
      HEIGHT 700 ;
      TITLE "Aplication menu" ;
      MODAL ;      
      on release re_order_mnu() 
      
      ON KEY ESCAPE ACTION CancelEdit_8223()
	  
	  ON KEY F4   ACTION If ( RecordStatus_8223(), EnableField_8223(), Nil )
	  ON KEY F6   ACTION ( New := .T., NewRecord_8223() )
	  ON KEY F8   ACTION ( RecordStatus_8223(), DeleteRecord_8223(), Nil )
	  ON KEY F10  ACTION win_6_3.Release
	  
      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "Menu"
		 STATUSITEM "" WIDTH 50
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_3 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER
/*
      BUTTON FIRST_8223 ;
         CAPTION "First" ;
         PICTURE "go_first" ;
         ACTION( dbGotop(), win_6_3.Browse_3.Value := RecNo() )

      BUTTON PREV_8223 ;
         CAPTION "Prev" ;
         PICTURE "go_prev" ;
         ACTION( dbSkip( -1 ), win_6_3.Browse_3.Value := RecNo() )

      BUTTON NEXT_8223 ;
         CAPTION "Next" ;
         PICTURE "go_next" ;
		 ACTION( dbSkip(), if ( Eof(), dbGobottom(), Nil ), win_6_3.Browse_3.Value := RecNo() )

      BUTTON LAST_8223 ;
         CAPTION "Last" ;
         PICTURE "go_last" ;
         ACTION( dbGoBottom(), win_6_3.Browse_3.Value := RecNo() )   SEPARATOR 
*/		 
      BUTTON EDIT_8223 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION If ( RecordStatus_8223(), EnableField_8223(), Nil )

      BUTTON NEW_8223 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( New := .T., NewRecord_8223() )

      BUTTON DELETE_8223 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_8223(), DeleteRecord_8223(), Nil )

      BUTTON EXIT_8223 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION win_6_3.Release

      END TOOLBAR

      PaintDisplay_8223()

      @ 90,10 BROWSE Browse_3 ;
         OF win_6_3 ;
         WIDTH 710 ;
         HEIGHT 300 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "(1)","(2)","ITEM","ACTION","MODUL" } ;
         WIDTHS { 50,50,250,180,180 } ;
         WORKAREA _APLMNU ;
         FIELDS { "LEVEL1","LEVEL2","ITEM","ACTION","MODUL" } ;
         ON CHANGE LoadData_8223() ;
         ON DBLCLICK ( EnableField_8223(), If ( ! RecordStatus_8223(), DisableField_8223(), Nil ) )
		 
      @ 580, 50 BUTTON SAVE_8223 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_8223() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_8223 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_8223() ;
         WIDTH 100 ;
         HEIGHT 40 
		 
      @ 90,750 BROWSE Browse_33 ;
         OF win_6_3 ;
         WIDTH 200 ;
         HEIGHT 300 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "MODUL+ to .HBP" } ;
         WIDTHS { 180 } ;
         WORKAREA _APLADD ;
         FIELDS { "MODUL" } ;
         ON CHANGE LoadData_8223a() ;
         ON DBLCLICK ( EnableField_8223a(), If ( ! RecordStatus_8223a(), DisableField_8223a(), Nil ) )
		 
      @ 400, 900 BUTTON PLUS_8223a ;
	     PICTURE "form_new" ;
         ACTION ( New := .T., NewRecord_8223a() ) ;
		 WIDTH 20 ;
		 HEIGHT 20		 
	   
      *@ 400, 900 IMAGE PLUS_8223a ;
      *   PICTURE "form_new" ;
      *   ACTION ( New := .T., NewRecord_8223a() )
	     
      @ 400, 930 BUTTON MINUS_8223a ;
	     PICTURE "form_del" ;  
         ACTION ( RecordStatus_8223a(), DeleteRecord_8223a(), Nil ) ;
		 WIDTH 20 ;
		 HEIGHT 20  	  

	  *@ 400,930 IMAGE MINUS_8223a ;
      *   PICTURE "form_del" ;
      *   ACTION ( RecordStatus_8223a(), DeleteRecord_8223a(), Nil ) ;
       
      @ 580, 750 BUTTON SAVE_8223a ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_8223a() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580, 850 BUTTON CANCEL_8223a ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_8223() ;
         WIDTH 100 ;
         HEIGHT 40
		 
   END WINDOW

   DisableField_8223()
   DisableField_8223a()

   win_6_3.Browse_3.SetFocus
   win_6_3.Browse_3.Value := _APLMNU->(RecNo())

   ACTIVATE WINDOW win_6_3

RETURN
*---------------------------------------------*
PROCEDURE DisableField_8223

   win_6_3.Browse_3.Enabled      := .T.

   win_6_3.mLEVEL1.Enabled       := .F.
   win_6_3.mLEVEL2.Enabled       := .F.
   win_6_3.mITEM.Enabled         := .F.
   win_6_3.mACTION.Enabled       := .F.
   win_6_3.mMODUL.Enabled        := .F.

   win_6_3.Save_8223.Enabled     := .F.
   win_6_3.Cancel_8223.Enabled   := .F.
   // win_6_3.Query_8223.Enabled    := .F.
   win_6_3.Toolbar_3.Enabled     := .T.
   win_6_3.Browse_3.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE DisableField_8223a

   win_6_3.Browse_33.Enabled      := .T.
   win_6_3.mMODULa.Enabled        := .F.

   win_6_3.Save_8223a.Enabled     := .F.
   win_6_3.Cancel_8223a.Enabled   := .F.
   win_6_3.Browse_33.SetFocus
      
RETURN
*---------------------------------------------*
PROCEDURE EnableField_8223

   win_6_3.Browse_3.Enabled      := .F.

   win_6_3.mLEVEL1.Enabled       := .T.
   win_6_3.mLEVEL2.Enabled       := .T.
   win_6_3.mITEM.Enabled         := .T.
   win_6_3.mACTION.Enabled       := .T.
   win_6_3.mMODUL.Enabled        := .T.
   
   win_6_3.Save_8223.Enabled     := .T.
   win_6_3.Cancel_8223.Enabled   := .T.
   win_6_3.Toolbar_3.Enabled     := .F.
   win_6_3.mLEVEL1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE EnableField_8223a

   win_6_3.Browse_33.Enabled      := .F.
   win_6_3.mMODULa.Enabled        := .T.
   win_6_3.mMODULa.SetFocus
   
   win_6_3.Save_8223a.Enabled     := .T.
   win_6_3.Cancel_8223a.Enabled   := .T.
   win_6_3.Save_8223a.Enabled     := .T.
   win_6_3.Cancel_8223a.Enabled   := .T.
   win_6_3.mMODULa.SetFocus
   
RETURN
*---------------------------------------------*
FUNCTION RecordStatus_8223()

   Local RetVal

   _APLMNU->( dbGoTo ( win_6_3.Browse_3.Value ) )

   IF _APLMNU->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*---------------------------------------------*
FUNCTION RecordStatus_8223a()

   Local RetVal

   _APLADD->( dbGoTo ( win_6_3.Browse_33.Value ) )

   IF _APLADD->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*---------------------------------------------*
PROCEDURE LoadData_8223

   _APLMNU->( dbGoTo ( win_6_3.Browse_3.Value ) )

   win_6_3.mLEVEL1.Value       := _APLMNU->LEVEL1    
   win_6_3.mLEVEL2.Value       := _APLMNU->LEVEL2    
   win_6_3.mITEM.Value         := _APLMNU->ITEM      
   win_6_3.mACTION.Value       := _APLMNU->ACTION
   win_6_3.mMODUL.Value        := _APLMNU->MODUL

RETURN
*---------------------------------------------*
PROCEDURE LoadData_8223a

   _APLADD->( dbGoTo ( win_6_3.Browse_33.Value ) )
   win_6_3.mMODULa.Value        := _APLADD->MODUL

RETURN
*---------------------------------------------*
PROCEDURE CancelEdit_8223

   DisableField_8223()
   LoadData_8223()
   UNLOCK
   New := .F.
   win_6_3.Browse_3.SetFocus
   
RETURN
*---------------------------------------------*
PROCEDURE SaveRecord_8223

   Local NewRecNo

   DisableField_8223()

   IF New == .T.
      _APLMNU->(dbAppend())
      New := .F.
   ELSE
      _APLMNU->(dbGoto ( win_6_3.Browse_3.Value ) )
   ENDIF

   NewRecNo := _APLMNU->( RecNo() )

   _APLMNU->LEVEL1     := win_6_3.mLEVEL1.Value
   _APLMNU->LEVEL2     := win_6_3.mLEVEL2.Value
   _APLMNU->ITEM       := win_6_3.mITEM.Value
   _APLMNU->ACTION     := win_6_3.mACTION.Value
   _APLMNU->MODUL      := win_6_3.mMODUL.Value

   win_6_3.Browse_3.Refresh
   IF New == .T.
      win_6_3.Browse_3.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   win_6_3.StatusBar.Item(1) := "Save Record" 

RETURN
*---------------------------------------------*
PROCEDURE SaveRecord_8223a

   Local NewRecNo

   DisableField_8223a()

   IF New == .T.
      _APLADD->(dbAppend())
      New := .F.
   ELSE
      _APLADD->(dbGoto ( win_6_3.Browse_33.Value ) )
   ENDIF

   NewRecNo := _APLMNU->( RecNo() )

   _APLADD->MODUL      := win_6_3.mMODULa.Value

   win_6_3.Browse_33.Refresh
   IF New == .T.
      win_6_3.Browse_33.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   win_6_3.StatusBar.Item(1) := "Save Record" 

RETURN
*---------------------------------------------*
PROCEDURE NewRecord_8223

   win_6_3.StatusBar.Item(1) := "Inserting" 

   SET ORDER TO 1
   *dbGoBottom()
   
   win_6_3.mLEVEL1.Value       := level1
   win_6_3.mLEVEL2.Value       := level2 + 1
   win_6_3.mITEM.Value         := '.'
   win_6_3.mACTION.Value       := 'nil'
   win_6_3.mMODUL.Value        := space(10)

   EnableField_8223()

   win_6_3.mLEVEL1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE NewRecord_8223a

   win_6_3.StatusBar.Item(1) := "Inserting" 

   win_6_3.mMODULa.Value     := "program"

   EnableField_8223a()

   win_6_3.mMODULa.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE DeleteRecord_8223

   select _aplmnu

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _APLMNU->(FLock())
         DELETE
         win_6_3.Browse_3.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*---------------------------------------------*
PROCEDURE DeleteRecord_8223a

   select _apladd
   
   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _APLADD->(FLock())
         DELETE
         win_6_3.Browse_33.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*---------------------------------------------*
PROCEDURE Find_8223

   win_6_3.StatusBar.Item(1) := "Query" 

   win_6_3.mLEVEL1.Value       := 0
   win_6_3.mLEVEL2.Value       := 0
   win_6_3.mITEM.Value         := space(30)
   win_6_3.mACTION.Value       := space(20)

   EnableField_8223()
   win_6_3.Save_8223.Enabled  := .F.
   // win_6_3.Query_8223.Enabled := .T.
   win_6_3.Control_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE PrintData_8223

   Local RecRec 

   RecRec := _APLMNU->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "MENU" ;
      HEADERS { "","","","","" }, { "LEVEL1","LEVEL2","ITEM","ACTION","MODUL" } ;
      FIELDS { "LEVEL1","LEVEL2","ITEM","ACTION","MODUL" } ;
      WIDTHS { 7,7,31,21,21 } ;
      TOTALS { .F.,.F.,.F.,.F.,.F. } ;
      WORKAREA _APLMNU ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _APLMNU->(dbGoTo(RecRec))

RETURN
*---------------------------------------------*
PROCEDURE PaintDisplay_8223

   @ 400, 10 FRAME Frame_3 WIDTH 710 HEIGHT 100

   @ 420,  20 LABEL Label_1 VALUE "L1"
   @ 420,  60 LABEL Label_2 VALUE "L2"
   @ 420, 100 LABEL Label_3 VALUE "ITEM"
   @ 420, 360 LABEL Label_4 VALUE "ACTION"
   @ 420, 540 LABEL Label_5 VALUE "MODUL"
   @ 420, 750 LABEL Label_55 VALUE "MODUL"
      
   @ 450,  20 TEXTBOX  mLEVEL1      WIDTH 30 NUMERIC INPUTMASK "99"
   @ 450,  60 TEXTBOX  mLEVEL2      WIDTH 30 NUMERIC INPUTMASK "99"
   @ 450, 100 TEXTBOX  mITEM        WIDTH 250 
   @ 450, 360 TEXTBOX  mACTION      WIDTH 170 
   @ 450, 540 TEXTBOX  mMODUL       WIDTH 170 
   @ 450, 750 TEXTBOX  mMODULa      WIDTH 170  on lostfocus( win_6_3.SAVE_8223a.SetFocus )
   
RETURN
*---------------------------------------------*
