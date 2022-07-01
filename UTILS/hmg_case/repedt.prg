#include <hmg.ch>

PROCEDURE rep_edt

   PUBLIC New := .F. , _qry_exp := "" , _key, aRepo := {}

   Use _rep_fld INDEX _rep_fld

   if !pre_IzborRep()
      return 
   endif
   
   DEFINE WINDOW Win_4_2 ;
      AT 20,20 ;
      WIDTH 800 ;
      HEIGHT 700 ;
      TITLE "Report's" ; 
      MODAL ;
      ON RELEASE re_order_rep()

      ON KEY ESCAPE ACTION CancelEdit_4520()
	  
	  ON KEY F7     ACTION Find_4520()
	  ON KEY F4     ACTION If ( RecordStatus_4520(), EnableField_4520(), Nil )
      ON KEY F6     ACTION ( New := .T., NewRecord_4520() )
	  ON KEY F8     ACTION ( RecordStatus_4520(), DeleteRecord_4520(), Nil )
      ON KEY F9     ACTION PrintData_4520()
      ON KEY F10    ACTION Win_4_2.Release

      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "Report definition"
         *KEYBOARD
         *DATE
         *CLOCK
		 STATUSITEM "" WIDTH 50
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_4_2 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER

/*
      BUTTON FIRST_4520 ;
         CAPTION "First" ;
         PICTURE "go_first" ;
         ACTION( dbGotop(), Win_4_2.Browse_4_2.Value := RecNo() )

      BUTTON PREV_4520 ;
         CAPTION "Prev" ;
         PICTURE "go_prev" ;
         ACTION( dbSkip( -1 ), Win_4_2.Browse_4_2.Value := RecNo() )

      BUTTON NEXT_4520 ;
         CAPTION "Next" ;
         PICTURE "go_next" ;
         ACTION( dbSkip(), if ( Eof(), dbGobottom(), Nil ), Win_4_2.Browse_4_2.Value := RecNo() )

      BUTTON LAST_4520 ;
         CAPTION "Last" ;
         PICTURE "go_last" ;
         ACTION( dbGoBottom(), Win_4_2.Browse_4_2.Value := RecNo() )   SEPARATOR 
*/

      BUTTON FIND_4520 ;
         CAPTION "[F7] Find" ;
         PICTURE "edit_find" ;
         ACTION Find_4520()

      BUTTON EDIT_4520 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION If ( RecordStatus_4520(), EnableField_4520(), Nil )

      BUTTON NEW_4520 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( New := .T., NewRecord_4520() )
 
      BUTTON DELETE_4520 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_4520(), DeleteRecord_4520(), Nil )

      BUTTON PRINT_4520 ;
         CAPTION "[F9] Print" ;
         PICTURE "edit_print" ;
         ACTION PrintData_4520()

      BUTTON EXIT_4520 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION Win_4_2.Release

      END TOOLBAR

      PaintDisplay_4520()

      @ 90,10 COMBOBOX Combo_repo ;
         WIDTH 140 ;
         HEIGHT 160 ;
         ITEMS aRepo ;
         VALUE 1 ;
         ON CHANGE IzaberiRepo()
         
      @ 130, 10 BROWSE Browse_4_2 ;
         OF Win_4_2 ;
         WIDTH 350 ;
         HEIGHT 420 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "Report","DBF","Seq","Name" } ;
         WIDTHS { 90,90,50,110 } ;
         WORKAREA _REP_FLD ;
         FIELDS { "REPNAME","DBFNAME","FLDSEQ","FLDNAME" } ;
         ON CHANGE LoadData_4520() ;
         ON DBLCLICK ( EnableField_4520(), If ( ! RecordStatus_4520(), DisableField_4520(), Nil ) )

      @ 580, 50 BUTTON SAVE_4520 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_4520() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_4520 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_4520() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,300 BUTTON QUERY_4520 ;
         CAPTION "Query" ;
         PICTURE "edit_find" RIGHT ;
         ACTION QueryRecord_4520() ;
         WIDTH 100 ;
         HEIGHT 40 

   END WINDOW

   DisableField_4520()

   Win_4_2.Browse_4_2.SetFocus
   Win_4_2.Browse_4_2.Value := _REP_FLD->(RecNo())

   ACTIVATE WINDOW Win_4_2

RETURN
*---------------------------------------------*
PROCEDURE DisableField_4520

   Win_4_2.Browse_4_2.Enabled     := .T.

   Win_4_2.Control_1.Enabled    := .F.
   Win_4_2.Control_2.Enabled    := .F.
   Win_4_2.Control_3.Enabled    := .F.
   Win_4_2.Control_4.Enabled    := .F.
   Win_4_2.Control_5.Enabled    := .F.
   Win_4_2.Control_6.Enabled    := .F.
   Win_4_2.Control_7.Enabled    := .F.
   Win_4_2.Control_8.Enabled    := .F.
   Win_4_2.Control_9.Enabled    := .F.
   Win_4_2.Control_11.Enabled    := .F.
   Win_4_2.Control_12.Enabled    := .F.
   Win_4_2.Control_13.Enabled    := .F.
   Win_4_2.Control_14.Enabled    := .F.
   Win_4_2.Control_15.Enabled    := .F.
   Win_4_2.Control_16.Enabled    := .F.
   Win_4_2.Control_17.Enabled    := .F.
   
   Win_4_2.Combo_repo.Enabled    := .T. 
   Win_4_2.Save_4520.Enabled     := .F.
   Win_4_2.Cancel_4520.Enabled   := .F.
   Win_4_2.Query_4520.Enabled    := .F.
   Win_4_2.Toolbar_4_2.Enabled    := .T.
   Win_4_2.Browse_4_2.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE EnableField_4520

   Win_4_2.Browse_4_2.Enabled     := .F.

   Win_4_2.Control_1.Enabled    := .T.
   Win_4_2.Control_2.Enabled    := .T.
   Win_4_2.Control_3.Enabled    := .T.
   Win_4_2.Control_4.Enabled    := .T.
   Win_4_2.Control_5.Enabled    := .T.
   Win_4_2.Control_6.Enabled    := .T.
   Win_4_2.Control_7.Enabled    := .T.
   Win_4_2.Control_8.Enabled    := .T.
   Win_4_2.Control_9.Enabled    := .T.
   Win_4_2.Control_11.Enabled    := .T.
   Win_4_2.Control_12.Enabled    := .T.
   Win_4_2.Control_13.Enabled    := .T.
   Win_4_2.Control_14.Enabled    := .T.
   Win_4_2.Control_15.Enabled    := .T.
   Win_4_2.Control_16.Enabled    := .T.
   Win_4_2.Control_17.Enabled    := .T.
 
   Win_4_2.Combo_repo.Enabled    := .F.
   Win_4_2.Save_4520.Enabled     := .T.
   Win_4_2.Cancel_4520.Enabled   := .T.
   Win_4_2.Query_4520.Enabled    := .F.
   Win_4_2.Toolbar_4_2.Enabled    := .F.
   Win_4_2.Control_2.SetFocus

RETURN
*---------------------------------------------*
FUNCTION RecordStatus_4520()

   Local RetVal

   _REP_FLD->( dbGoTo ( Win_4_2.Browse_4_2.Value ) )

   IF _REP_FLD->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*---------------------------------------------*
PROCEDURE LoadData_4520

   _REP_FLD->( dbGoTo ( Win_4_2.Browse_4_2.Value ) )

   Win_4_2.Control_1.Value     := _REP_FLD->REPNAME   
   Win_4_2.Control_2.Value     := _REP_FLD->DBFNAME   
   Win_4_2.Control_3.Value     := _REP_FLD->FLDSEQ    
   Win_4_2.Control_4.Value     := _REP_FLD->FLDNAME   
   Win_4_2.Control_5.Value     := _REP_FLD->FLDTYPE   
   Win_4_2.Control_6.Value     := _REP_FLD->FLDLEN    
   Win_4_2.Control_7.Value     := _REP_FLD->FLDDEC    
   Win_4_2.Control_8.Value     := _REP_FLD->FLDPICT   
   Win_4_2.Control_9.Value     := _REP_FLD->FLDHEAD   
   Win_4_2.Control_11.Value    := _REP_FLD->FLDATR1   
   Win_4_2.Control_12.Value    := _REP_FLD->FLDATR2   
   Win_4_2.Control_13.Value    := _REP_FLD->FLDATR3   
   Win_4_2.Control_14.Value    := _REP_FLD->FLDATR4   
   Win_4_2.Control_15.Value    := _REP_FLD->FLDATR5   
   Win_4_2.Control_16.Value    := _REP_FLD->FLDATR6   
   Win_4_2.Control_17.Value    := _REP_FLD->FLDDUZ    

RETURN
*---------------------------------------------*
PROCEDURE CancelEdit_4520

   DisableField_4520()
   LoadData_4520()
   UNLOCK
   New := .F.

RETURN
*---------------------------------------------*
PROCEDURE SaveRecord_4520

   Local NewRecNo

   DisableField_4520()

   IF New == .T.
      _REP_FLD->(dbAppend())
      New := .F.
   ELSE
      _REP_FLD->(dbGoto ( Win_4_2.Browse_4_2.Value ) )
   ENDIF
 
   NewRecNo := _REP_FLD->( RecNo() )

   _REP_FLD->REPNAME    := Win_4_2.Control_1.Value
   _REP_FLD->DBFNAME    := Win_4_2.Control_2.Value
   _REP_FLD->FLDSEQ     := Win_4_2.Control_3.Value
   _REP_FLD->FLDNAME    := Win_4_2.Control_4.Value
   _REP_FLD->FLDTYPE    := Win_4_2.Control_5.Value
   _REP_FLD->FLDLEN     := Win_4_2.Control_6.Value
   _REP_FLD->FLDDEC     := Win_4_2.Control_7.Value
   _REP_FLD->FLDPICT    := Win_4_2.Control_8.Value
   _REP_FLD->FLDHEAD    := Win_4_2.Control_9.Value
   _REP_FLD->FLDATR1    := Win_4_2.Control_11.Value
   _REP_FLD->FLDATR2    := Win_4_2.Control_12.Value
   _REP_FLD->FLDATR3    := Win_4_2.Control_13.Value
   _REP_FLD->FLDATR4    := Win_4_2.Control_14.Value
   _REP_FLD->FLDATR5    := Win_4_2.Control_15.Value
   _REP_FLD->FLDATR6    := Win_4_2.Control_16.Value
   _REP_FLD->FLDDUZ     := Win_4_2.Control_17.Value

   if _rep_fld->fldatr2
      _REP_FLD->FLDSEQ = 0
   endif
      
   _REP_FLD->FLDDUZ = max( len(alltrim(_REP_FLD->FLDPICT)), len(alltrim(_REP_FLD->FLDHEAD)) )
         
   if _REP_FLD->FLDTYPE = 'C'
      _REP_FLD->FLDDUZ = max( _REP_FLD->FLDLEN, len(alltrim(_REP_FLD->FLDHEAD)) )
   endif
		 
   Win_4_2.Browse_4_2.Refresh
   IF New == .T.
      Win_4_2.Browse_4_2.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   Win_4_2.StatusBar.Item(1) := "Save Record" 

RETURN
*---------------------------------------------*
PROCEDURE NewRecord_4520

   Win_4_2.StatusBar.Item(1) := "Editing" 

   SET ORDER TO 1
   dbGoBottom()
   _fldseq = fldseq

   Win_4_2.Control_1.Value   := _rep_fld->repname
   Win_4_2.Control_2.Value   := '$'
   Win_4_2.Control_3.Value   := _fldseq
   Win_4_2.Control_4.Value   := ''
   Win_4_2.Control_5.Value   := space(1)
   Win_4_2.Control_6.Value   := 0
   Win_4_2.Control_7.Value   := 0
   Win_4_2.Control_8.Value   := space(30)
   Win_4_2.Control_9.Value   := space(30)
   Win_4_2.Control_11.Value   := .T.
   Win_4_2.Control_12.Value   := .T.
   Win_4_2.Control_13.Value   := .T.
   Win_4_2.Control_14.Value   := .T.
   Win_4_2.Control_15.Value   := .T.
   Win_4_2.Control_16.Value   := .T.
   Win_4_2.Control_17.Value   := 0

   EnableField_4520()

   Win_4_2.Control_2.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE DeleteRecord_4520

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _REP_FLD->(FLock())
         DELETE
         Win_4_2.Browse_4_2.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*---------------------------------------------*
PROCEDURE Find_4520

   Win_4_2.StatusBar.Item(1) := "Query" 

   Win_4_2.Control_1.Value   := space(8)
   Win_4_2.Control_2.Value   := space(8)
   Win_4_2.Control_3.Value   := 0
   Win_4_2.Control_4.Value   := space(10)
   Win_4_2.Control_5.Value   := space(1)
   Win_4_2.Control_6.Value   := 0
   Win_4_2.Control_7.Value   := 0
   Win_4_2.Control_8.Value   := space(30)
   Win_4_2.Control_9.Value   := space(30)
   Win_4_2.Control_11.Value   := .T.
   Win_4_2.Control_12.Value   := .T.
   Win_4_2.Control_13.Value   := .T.
   Win_4_2.Control_14.Value   := .T.
   Win_4_2.Control_15.Value   := .T.
   Win_4_2.Control_16.Value   := .T.
   Win_4_2.Control_17.Value   := 0

   EnableField_4520()
   Win_4_2.Save_4520.Enabled  := .F.
   Win_4_2.Query_4520.Enabled := .T.
   Win_4_2.Control_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE PrintData_4520

   Local RecRec 

   RecRec := _REP_FLD->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "Report" ;
      HEADERS { "","","","","","","","","","" }, { "Report","DBF","Seq","Name","Type","Len","Dec","Picture","Header","FLDDUZ" } ;
      FIELDS { "REPNAME","DBFNAME","FLDSEQ","FLDNAME","FLDTYPE","FLDLEN","FLDDEC","FLDPICT","FLDHEAD","FLDDUZ" } ;
      WIDTHS { 9,9,4,11,5,4,4,31,31,7 } ;
      TOTALS { .F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F. } ;
      WORKAREA _REP_FLD ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _REP_FLD->(dbGoTo(RecRec))

RETURN
*---------------------------------------------*
PROCEDURE PaintDisplay_4520

   @  90,410 FRAME Frame_4_2 WIDTH 300 HEIGHT 460

   @ 100, 420 LABEL Label_1 VALUE "Report"
   @ 130, 420 LABEL Label_2 VALUE "DBF"
   @ 160, 420 LABEL Label_3 VALUE "Seq"
   @ 190, 420 LABEL Label_4 VALUE "Name"
   @ 220, 420 LABEL Label_5 VALUE "Type"
   @ 250, 420 LABEL Label_6 VALUE "Len"
   @ 280, 420 LABEL Label_7 VALUE "Dec"
   @ 310, 420 LABEL Label_8 VALUE "Picture"
   @ 340, 420 LABEL Label_9 VALUE "Header"
   @ 370, 420 LABEL Label_17 VALUE "Width"

   @ 100, 520 TEXTBOX  Control_1         INPUTMASK "!!!!!!!!"
   @ 130, 520 TEXTBOX  Control_2         INPUTMASK "!!!!!!!!"
   @ 160, 520 TEXTBOX  Control_3 NUMERIC INPUTMASK "99"
   @ 190, 520 TEXTBOX  Control_4         INPUTMASK "!!!!!!!!!!"
   @ 220, 520 TEXTBOX  Control_5         INPUTMASK "!"
   @ 250, 520 TEXTBOX  Control_6 NUMERIC INPUTMASK "99"
   @ 280, 520 TEXTBOX  Control_7 NUMERIC INPUTMASK "99"
   @ 310, 520 TEXTBOX  Control_8         INPUTMASK "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   @ 340, 520 TEXTBOX  Control_9         INPUTMASK "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   @ 370, 520 TEXTBOX  Control_17 NUMERIC INPUTMASK "99"
   @ 400, 420 CHECKBOX  Control_11 CAPTION "Print"
   @ 400, 520 CHECKBOX  Control_12 CAPTION "Break"
   @ 430, 420 CHECKBOX  Control_13 CAPTION "Sum on Break"
   @ 430, 520 CHECKBOX  Control_14 CAPTION "Sum on Report"
   @ 460, 420 CHECKBOX  Control_15 CAPTION "Parameter"
   @ 460, 520 CHECKBOX  Control_16 CAPTION "Not use"

RETURN
*---------------------------------------------*
PROCEDURE QueryRecord_4520

   PreQuery_4520()

   SET FILTER TO &_qry_exp
   dbGotop()

   IF ! EMPTY( _qry_exp )
      COUNT TO found_rec FOR &_qry_exp
      dbGotop()

      IF found_rec = 0
         Win_4_2.Statusbar.Item(1) := "Not found!"
      ELSE
         Win_4_2.Statusbar.Item(1) := "Found " + ALLTRIM(STR(found_rec)) + " record(s)!"
      ENDIF
   ENDIF

   DisableField_4520()

   Win_4_2.Browse_4_2.Refresh
   Win_4_2.Browse_4_2.Enabled   := .T.

RETURN
*---------------------------------------------*
PROCEDURE PreQuery_4520

_qry_exp := ""
_ima_filter := .F.

IF ! EMPTY ( Win_4_2.Control_1.Value )     // REPNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "REPNAME = " + chr(34) + Win_4_2.Control_1.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_2.Value )     // DBFNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "DBFNAME = " + chr(34) + Win_4_2.Control_2.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_3.Value )     // FLDSEQ
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDSEQ = " + STR( Win_4_2.Control_3.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_4.Value )     // FLDNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDNAME = " + chr(34) + Win_4_2.Control_4.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_5.Value )     // FLDTYPE
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDTYPE = " + chr(34) + Win_4_2.Control_5.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_6.Value )     // FLDLEN
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDLEN = " + STR( Win_4_2.Control_6.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_7.Value )     // FLDDEC
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDDEC = " + STR( Win_4_2.Control_7.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_8.Value )     // FLDPICT
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDPICT = " + chr(34) + Win_4_2.Control_8.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_9.Value )     // FLDHEAD
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDHEAD = " + chr(34) + Win_4_2.Control_9.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.Control_17.Value )     // FLDDUZ
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDDUZ = " + STR( Win_4_2.Control_17.Value )
      _ima_filter := .T.
ENDIF

RETURN
*:*****************************************************
FUNCTION pre_izborRep()

_oldrep = ''
select _rep_fld

if reccount() = 0
   msginfo('Nothing, first create Report')
   return .f.
endif

do while .not. eof()
   if _oldrep != repname
      aadd( aRepo, repname)
   endif
   _oldrep = repname

   dbskip()
enddo

_key = aRepo[1]
set filter to repname = _key
dbgotop()

return .t.
*:*****************************************************
FUNCTION IzaberiRepo () 

_red := win_4_2.combo_repo.value 
_key := aRepo [ _red ] 

select _rep_fld
set filter to dbfname = _key
dbgotop()

Win_4_2.Browse_4_2.Refresh

return 0
