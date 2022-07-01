#include <hmg.ch>

PROCEDURE frm_EDT

   PUBLIC NewRec := .F., EditRec := .F., _qry_exp := "", _key, aForm := {}

   dbcloseall()
   
   USE _frm_dbf INDEX _frm_dbf NEW
   USE _frm_fld INDEX _frm_fld NEW
   
   if !pre_Izborform()
      return 
   endif
      
   DEFINE WINDOW Win_3_2 ;
      AT 20,20 ;
      WIDTH 850 ;
      HEIGHT 700 ;
      TITLE "Form edit" ;
      CHILD ; //  MODAL  ;
      ON INIT frm_preview_8611() ;
      ON RELEASE at_end_8611()

      ON KEY ESCAPE ACTION CancelEdit_8611()

      *ON KEY F7   ACTION Find_8611()
      ON KEY F4   ACTION ( NewRec := .F., EditRec := .T.,  If ( RecordStatus_8611(), EnableField_8611(), Nil ))
      ON KEY F6   ACTION ( NewRec := .T., EditRec := .F., NewRecord_8611() )
      ON KEY F8   ACTION ( RecordStatus_8611(), DeleteRecord_8611(), Nil )
      *ON KEY F9   ACTION PrintData_8611()
      ON KEY F10  ACTION Win_3_2.Release
      
      ON KEY CONTROL+DOWN    ACTION fld_mov_down()
      ON KEY CONTROL+UP      ACTION fld_mov_up() 
      ON KEY CONTROL+LEFT    ACTION fld_mov_left() 
      ON KEY CONTROL+RIGHT   ACTION fld_mov_right()
	  
      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "Form definition"
		   STATUSITEM "" WIDTH 50
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_3_2 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER
/*
      BUTTON FIRST_8611 ;
         CAPTION "First" ;
         PICTURE "go_first" ;
         ACTION( dbGotop(), Win_3_2.Browse_3_2.Value := RecNo() )

      BUTTON PREV_8611 ;
         CAPTION "Prev" ;
         PICTURE "go_prev" ;
         ACTION( dbSkip( -1 ), Win_3_2.Browse_3_2.Value := RecNo() )

      BUTTON NEXT_8611 ;
         CAPTION "Next" ;
         PICTURE "go_next" ;
         ACTION( dbSkip(), if ( Eof(), dbGobottom(), Nil ), Win_3_2.Browse_3_2.Value := RecNo() )

      BUTTON LAST_8611 ;
         CAPTION "Last" ;
         PICTURE "go_last" ;
         ACTION( dbGoBottom(), Win_3_2.Browse_3_2.Value := RecNo() )   SEPARATOR 
*/
      *BUTTON FIND_8611 ;
      *   CAPTION "[F7] Find" ;
      *   PICTURE "edit_find" ;
      *   ACTION Find_8611()

      BUTTON EDIT_8611 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION ( EditRec := .T., NewRec := .F., If ( RecordStatus_8611(), EnableField_8611(), Nil ))

      BUTTON NEW_8611 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( EditRec := .F., NewRec := .T., NewRecord_8611() )

      BUTTON DELETE_8611 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_8611(), DeleteRecord_8611(), Nil )

      BUTTON PRINT_8611 ;
         CAPTION "[F9] Print" ;
         PICTURE "edit_print" ;
         ACTION PrintData_8611()

      BUTTON EXIT_8611 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION Win_3_2.Release

      END TOOLBAR

      PaintDisplay_8611()

      @ 90,10 COMBOBOX Combo_form ;
         WIDTH 140 ;
         HEIGHT 160 ;
         ITEMS aForm ;
         VALUE 1 ;
         ON CHANGE IzaberiFormu()
            
      @ 130,10 BROWSE Browse_3_2 ;
         OF Win_3_2 ;
         WIDTH 350 ;
         HEIGHT 420 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "Form","DBF","No","Field Name" } ;
         WIDTHS { 90,90,70,110 } ;
         WORKAREA _FRM_FLD ;
         FIELDS { "FORMNAME","DBFNAME","FLDSEQ","FLDNAME" } ;
         ON CHANGE LoadData_8611() ;
         ON DBLCLICK ( EditRec := .T., NewRec := .F., EnableField_8611(), If ( ! RecordStatus_8611(), DisableField_8611(), Nil ) )

      @ 580, 50 BUTTON SAVE_8611 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_8611() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_8611 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_8611() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,275 BUTTON QUERY_8611 ;
         CAPTION "Query" ;
         PICTURE "edit_find" RIGHT ;
         ACTION QueryRecord_8611() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,400 BUTTON PREVIEW_8611 ;
         CAPTION "Preview form" ;
         ACTION frm_preview_8611 ( _frm_fld->formname ) ;
         WIDTH 100 ;
         HEIGHT 40 
         
      @ 65,650 BUTTON set_grid_8611 ;
         CAPTION "Set" ;
         ACTION set_grid() ;
         WIDTH 50 ;
         HEIGHT 25
		   
      @ 370,710 BUTTON set_label_pos_8611 ;
         CAPTION "Set all" ;
         ACTION set_label() ;
         WIDTH 70 ;
         HEIGHT 25
		 
      *@ 570, 520 LABEL prevcmd_1 VALUE "Izaberite red sa Enter ili [F4] Edit i onda" WIDTH 300
      *@ 590, 520 LABEL prevcmd_2 VALUE "sa Ctrl+Up/Ctlr+Down pomerate polja gore/dole" WIDTH 300
      *@ 610, 520 LABEL prevcmd_3 VALUE "sa Ctrl+Left/Ctlr+Right pomerate levo/desno" WIDTH 300	 

      @ 565, 520 LABEL prevcmd_1 VALUE "Select row with Enter or [F4] Edit than" WIDTH 300
      @ 590, 520 LABEL prevcmd_2 VALUE "Ctrl+Up/Ctlr+Down change field position up/down" WIDTH 300
      @ 615, 520 LABEL prevcmd_3 VALUE "Ctrl+Left/Ctlr+Right cahnge filed position left/right" WIDTH 300	 
	  
   END WINDOW

   DisableField_8611()

   Win_3_2.Browse_3_2.SetFocus
   Win_3_2.Browse_3_2.Value := _FRM_FLD->(RecNo())

   ACTIVATE WINDOW Win_3_2

RETURN
*---------------------------------------------*
FUNCTION at_end_8611()

   if IsWindowActive( FormPrev )
       DoMethod( 'FormPrev', "RELEASE" )
   endif

   re_order_frm()

RETURN
*---------------------------------------------*
PROCEDURE DisableField_8611

   Win_3_2.Browse_3_2.Enabled   := .T.
 
   Win_3_2.Control_w.Enabled    := .F.
   Win_3_2.Control_h.Enabled    := .F.
  
   Win_3_2.Control_1.Enabled    := .F.
   Win_3_2.Control_2.Enabled    := .F.
   Win_3_2.Control_3.Enabled    := .F.
   Win_3_2.Control_4.Enabled    := .F.
   Win_3_2.Control_44.Enabled   := .F.
   Win_3_2.Control_5.Enabled    := .F.
   Win_3_2.Control_6.Enabled    := .F.
   Win_3_2.Control_7.Enabled    := .F.
   Win_3_2.Control_8.Enabled    := .F.
   Win_3_2.Control_9.Enabled    := .F.
   Win_3_2.Control_8a.Enabled    := .F.
   Win_3_2.Control_9a.Enabled    := .F.
   Win_3_2.Control_10.Enabled    := .F.
   Win_3_2.Control_11.Enabled    := .F.
   Win_3_2.Control_12.Enabled    := .F.
   Win_3_2.Control_13.Enabled    := .F.
   Win_3_2.Control_14.Enabled    := .F.
   Win_3_2.Control_15.Enabled    := .F.
   Win_3_2.Control_16.Enabled    := .F.
   Win_3_2.Control_17.Enabled    := .F.
   Win_3_2.Control_18.Enabled    := .F.
   Win_3_2.Control_19.Enabled    := .F.
   Win_3_2.Control_20.Enabled    := .F.
   Win_3_2.Control_21.Enabled    := .F.
   Win_3_2.Control_22.Enabled    := .F.
   Win_3_2.Control_23.Enabled    := .F.

   Win_3_2.prevcmd_1.Visible     := .F.
   Win_3_2.prevcmd_2.Visible     := .F.
   Win_3_2.prevcmd_3.Visible     := .F.
   
   Win_3_2.Combo_form.Enabled    := .T.
   Win_3_2.Save_8611.Enabled     := .F.
   Win_3_2.Cancel_8611.Enabled   := .F.
   Win_3_2.Query_8611.Enabled    := .F.
   Win_3_2.Toolbar_3_2.Enabled    := .T.
   Win_3_2.Browse_3_2.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE EnableField_8611

   Win_3_2.Browse_3_2.Enabled     := .F.

   Win_3_2.Control_1.Enabled    := .T.
   Win_3_2.Control_2.Enabled    := .T.
   Win_3_2.Control_3.Enabled    := .T.
   Win_3_2.Control_4.Enabled    := .T.
   Win_3_2.Control_44.Enabled    := .T.
   Win_3_2.Control_5.Enabled    := .T.
   Win_3_2.Control_6.Enabled    := .T.
   Win_3_2.Control_7.Enabled    := .T.
   Win_3_2.Control_8.Enabled    := .T.
   Win_3_2.Control_9.Enabled    := .T.
   Win_3_2.Control_8a.Enabled    := .T.
   Win_3_2.Control_9a.Enabled    := .T.
   Win_3_2.Control_10.Enabled    := .T.
   Win_3_2.Control_11.Enabled    := .T.
   Win_3_2.Control_12.Enabled    := .T.
   Win_3_2.Control_13.Enabled    := .T.
   Win_3_2.Control_14.Enabled    := .T.
   Win_3_2.Control_15.Enabled    := .T.
   Win_3_2.Control_16.Enabled    := .T.
   Win_3_2.Control_17.Enabled    := .T.
   Win_3_2.Control_18.Enabled    := .T.
   Win_3_2.Control_19.Enabled    := .T.
   Win_3_2.Control_20.Enabled    := .T.
   Win_3_2.Control_21.Enabled    := .T.
   Win_3_2.Control_22.Enabled    := .T.
   Win_3_2.Control_23.Enabled    := .T.
   
   Win_3_2.Combo_form.Enabled    := .F.
   Win_3_2.Save_8611.Enabled     := .T.
   Win_3_2.Cancel_8611.Enabled   := .T.
   Win_3_2.Query_8611.Enabled    := .F.
   Win_3_2.Toolbar_3_2.Enabled    := .F.
   Win_3_2.Control_2.SetFocus

RETURN
*---------------------------------------------*
FUNCTION RecordStatus_8611()

   Local RetVal

   _FRM_FLD->( dbGoTo ( Win_3_2.Browse_3_2.Value ) )

   IF _FRM_FLD->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*---------------------------------------------*
PROCEDURE LoadData_8611

   select _FRM_dbf
   Win_3_2.Control_w.Value    := _FRM_dbf->grid_w
   Win_3_2.Control_h.Value    := _FRM_dbf->grid_h
  
   _FRM_FLD->( dbGoTo ( Win_3_2.Browse_3_2.Value ) )

   Win_3_2.Control_1.Value    := _FRM_FLD->FORMNAME  
   Win_3_2.Control_2.Value    := _FRM_FLD->DBFNAME   
   Win_3_2.Control_3.Value    := _FRM_FLD->FLDSEQ    
   Win_3_2.Control_4.Value    := _FRM_FLD->FLDNAME   
   Win_3_2.Control_44.Value    := _FRM_FLD->FLDLABEL
   Win_3_2.Control_5.Value    := _FRM_FLD->FLDTYPE   
   Win_3_2.Control_6.Value    := _FRM_FLD->FLDLEN    
   Win_3_2.Control_7.Value    := _FRM_FLD->FLDDEC    
   Win_3_2.Control_8.Value    := _FRM_FLD->FLDROW    
   Win_3_2.Control_9.Value    := _FRM_FLD->FLDCOL    
   Win_3_2.Control_8a.Value    := _FRM_FLD->LABROW    
   Win_3_2.Control_9a.Value    := _FRM_FLD->LABCOL    
   Win_3_2.Control_10.Value    := _FRM_FLD->FLDPICT   
   Win_3_2.Control_11.Value    := _FRM_FLD->FLDDEF    
   Win_3_2.Control_12.Value    := _FRM_FLD->FLDATR1   
   Win_3_2.Control_13.Value    := _FRM_FLD->FLDATR2   
   Win_3_2.Control_14.Value    := _FRM_FLD->FLDATR3   
   Win_3_2.Control_15.Value    := _FRM_FLD->FLDATR4   
   Win_3_2.Control_16.Value    := _FRM_FLD->FLDATR5   
   Win_3_2.Control_17.Value    := _FRM_FLD->FLDATR6   
   Win_3_2.Control_18.Value    := _FRM_FLD->FLDATR7   
   Win_3_2.Control_19.Value    := _FRM_FLD->FLDATR8   
   Win_3_2.Control_20.Value    := _FRM_FLD->VALID_DBF 
   Win_3_2.Control_21.Value    := _FRM_FLD->VALID_KEY
   Win_3_2.Control_22.Value    := _FRM_FLD->VALID_FLD 
   Win_3_2.Control_23.Value    := _FRM_FLD->VALID_DSP 

RETURN
*---------------------------------------------*
PROCEDURE CancelEdit_8611

   DisableField_8611()	
   LoadData_8611()
   UNLOCK
   NewRec := .F.

RETURN
*---------------------------------------------*
PROCEDURE SaveRecord_8611

   Local NewRecNo

   DisableField_8611()

   IF NewRec == .T.
      _FRM_FLD->(dbAppend())
      NewRec := .F.
   ELSE
      _FRM_FLD->(dbGoto ( Win_3_2.Browse_3_2.Value ) )
   ENDIF

   NewRecNo := _FRM_FLD->( RecNo() )

   _FRM_FLD->FORMNAME   := Win_3_2.Control_1.Value
   _FRM_FLD->DBFNAME    := Win_3_2.Control_2.Value
   _FRM_FLD->FLDSEQ     := Win_3_2.Control_3.Value
   _FRM_FLD->FLDNAME    := Win_3_2.Control_4.Value
   _FRM_FLD->FLDLABEL   := Win_3_2.Control_44.Value
   _FRM_FLD->FLDTYPE    := Win_3_2.Control_5.Value
   _FRM_FLD->FLDLEN     := Win_3_2.Control_6.Value
   _FRM_FLD->FLDDEC     := Win_3_2.Control_7.Value
   _FRM_FLD->FLDROW     := Win_3_2.Control_8.Value
   _FRM_FLD->FLDCOL     := Win_3_2.Control_9.Value
   _FRM_FLD->LABROW     := Win_3_2.Control_8a.Value
   _FRM_FLD->LABCOL     := Win_3_2.Control_9a.Value   
   _FRM_FLD->FLDPICT    := Win_3_2.Control_10.Value
   _FRM_FLD->FLDDEF     := Win_3_2.Control_11.Value
   _FRM_FLD->FLDATR1    := Win_3_2.Control_12.Value
   _FRM_FLD->FLDATR2    := Win_3_2.Control_13.Value
   _FRM_FLD->FLDATR3    := Win_3_2.Control_14.Value
   _FRM_FLD->FLDATR4    := Win_3_2.Control_15.Value
   _FRM_FLD->FLDATR5    := Win_3_2.Control_16.Value
   _FRM_FLD->FLDATR6    := Win_3_2.Control_17.Value
   _FRM_FLD->FLDATR7    := Win_3_2.Control_18.Value
   _FRM_FLD->FLDATR8    := Win_3_2.Control_19.Value
   
   if dbfname = '$'
      _FRM_FLD->FLDATR1    := .F.
      _FRM_FLD->FLDATR2    := .T.
      _FRM_FLD->FLDATR3    := .F.
      _FRM_FLD->FLDATR4    := .F.
      _FRM_FLD->FLDATR5    := .F.
      _FRM_FLD->FLDATR6    := .F.
      _FRM_FLD->FLDATR7    := .F.
      _FRM_FLD->FLDATR8    := .F.
   endif
   
   _FRM_FLD->VALID_DBF  := Win_3_2.Control_20.Value
   _FRM_FLD->VALID_KEY  := Win_3_2.Control_21.Value
   _FRM_FLD->VALID_FLD  := Win_3_2.Control_22.Value
   _FRM_FLD->VALID_DSP  := Win_3_2.Control_23.Value
   
   if !empty(Win_3_2.Control_20.Value) .and. !empty(Win_3_2.Control_21.Value) .and. !empty(Win_3_2.Control_22.Value) .and. !empty(Win_3_2.Control_23.Value)
      Win_3_2.Control_19.Value := .T.
   else
      Win_3_2.Control_19.Value := .F.
   endif   
      
   _FRM_FLD->FLDATR8 := Win_3_2.Control_19.Value
      
   Win_3_2.Browse_3_2.Refresh
   IF NewRec == .T.
      Win_3_2.Browse_3_2.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()

   Win_3_2.StatusBar.Item(1) := "Save Record" 
   
   NewRec := .F.
   EditRec := .F.

   if IsWindowActive( FormPrev )
      frm_preview_8611 ( )
   endif
   
   Win_3_2.Browse_3_2.SetFocus
      
RETURN
*---------------------------------------------*
PROCEDURE NewRecord_8611

   Win_3_2.StatusBar.Item(1) := "New" 

   select _frm_fld
      
   SET ORDER TO 1
   dbGoBottom()

   _formname = formname
   _row = fldrow + 30
   _col = fldcol
   
   Win_3_2.Control_1.Value   := _formname
   Win_3_2.Control_2.Value   := '$'
   Win_3_2.Control_3.Value   := 99
   Win_3_2.Control_4.Value   := 'Display'
   Win_3_2.Control_44.Value   := 'Display'
   Win_3_2.Control_5.Value   := 'C'
   Win_3_2.Control_6.Value   := 10
   Win_3_2.Control_7.Value   := 0
   Win_3_2.Control_8.Value   := _row
   Win_3_2.Control_9.Value   := _col
   Win_3_2.Control_8a.Value   := _row
   Win_3_2.Control_9a.Value   := _col
   Win_3_2.Control_10.Value   := space(30)
   Win_3_2.Control_11.Value   := space(30)
   Win_3_2.Control_12.Value   := .F.
   Win_3_2.Control_13.Value   := .F.
   Win_3_2.Control_14.Value   := .F.
   Win_3_2.Control_15.Value   := .F.
   Win_3_2.Control_16.Value   := .F.
   Win_3_2.Control_17.Value   := .F.
   Win_3_2.Control_18.Value   := .T.
   Win_3_2.Control_19.Value   := .F.
   Win_3_2.Control_20.Value   := space(10)
   Win_3_2.Control_21.Value   := space(10)
   Win_3_2.Control_22.Value   := space(10)
   Win_3_2.Control_23.Value   := space(10)
   
   EnableField_8611()

   Win_3_2.Control_2.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE DeleteRecord_8611

   select _frm_fld

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _FRM_FLD->(FLock())
         DELETE
         Win_3_2.Browse_3_2.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*---------------------------------------------*
PROCEDURE Find_8611

   Win_3_2.StatusBar.Item(1) := "Query" 

   Win_3_2.Control_1.Value   := space(8)
   Win_3_2.Control_2.Value   := space(8)
   Win_3_2.Control_3.Value   := 0
   Win_3_2.Control_4.Value   := space(10)
   Win_3_2.Control_44.Value   := space(10)
   Win_3_2.Control_5.Value   := space(1)
   Win_3_2.Control_6.Value   := 0
   Win_3_2.Control_7.Value   := 0
   Win_3_2.Control_8.Value   := 0
   Win_3_2.Control_9.Value   := 0
   Win_3_2.Control_10.Value   := space(30)
   Win_3_2.Control_11.Value   := space(30)
   Win_3_2.Control_12.Value   := .F.
   Win_3_2.Control_13.Value   := .F.
   Win_3_2.Control_14.Value   := .F.
   Win_3_2.Control_15.Value   := .F.
   Win_3_2.Control_16.Value   := .F.
   Win_3_2.Control_17.Value   := .F.
   Win_3_2.Control_18.Value   := .F.
   Win_3_2.Control_19.Value   := .F.
   Win_3_2.Control_20.Value   := space(10)
   Win_3_2.Control_21.Value   := space(10)
   Win_3_2.Control_22.Value   := space(10)
   Win_3_2.Control_23.Value   := space(10)

   EnableField_8611()
   Win_3_2.Save_8611.Enabled  := .F.
   Win_3_2.Query_8611.Enabled := .T.
   Win_3_2.Control_1.SetFocus

RETURN
*---------------------------------------------*
PROCEDURE PrintData_8611

   Local RecRec 

   RecRec := _FRM_FLD->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "FORMS" ;
      HEADERS { "","","","","","","","" }, { "DBF","No","Field Name","Field Type","Field Len","Field Dec","Row","Col" } ;
      FIELDS { "DBFNAME","FLDSEQ","FLDNAME","FLDTYPE","FLDLEN","FLDDEC","FLDROW","FLDCOL" } ;
      WIDTHS { 9,3,11,11,10,10,4,4 } ;
      TOTALS { .F.,.F.,.F.,.F.,.F.,.F.,.F.,.F. } ;
      WORKAREA _FRM_FLD ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _FRM_FLD->(dbGoTo(RecRec))

RETURN
*---------------------------------------------*
PROCEDURE PaintDisplay_8611

   @  70, 420 LABEL Label_w VALUE "Grid width " 
   @  70, 550 LABEL Label_h VALUE "height " 
   
   @  90, 400 FRAME Frame_3_2 WIDTH 490 HEIGHT 460

   @ 100, 420 LABEL Label_1 VALUE "Form"
   @ 130, 420 LABEL Label_2 VALUE "DBF"
   @ 160, 420 LABEL Label_3 VALUE "No"
   @ 190, 420 LABEL Label_4 VALUE "Field Name"
   @ 220, 420 LABEL Label_44 VALUE "Label"
   @ 250, 420 LABEL Label_5 VALUE "Field Type"
   @ 280, 420 LABEL Label_6 VALUE "Field Len"
   @ 280, 600 LABEL Label_7 VALUE "Dec"
   @ 310, 420 LABEL Label_8 VALUE "Field Row"
   @ 310, 600 LABEL Label_9 VALUE "Col"
   @ 340, 420 LABEL Label_l9 WIDTH 300 VALUE "Label (relative on field position)"
   @ 370, 420 LABEL Label_8a VALUE "Row"
   @ 370, 600 LABEL Label_9a VALUE "Col"
   @ 400, 420 LABEL Label_10 VALUE "Picture"
   @ 430, 420 LABEL Label_11 VALUE "Default"
   @ 460, 620 LABEL Label_22 VALUE "DBF"
   @ 480, 620 LABEL Label_23 VALUE "Key" 
   @ 500, 620 LABEL Label_24 VALUE "Valid"
   @ 520, 620 LABEL Label_25 VALUE "Display"

   @  65, 490 TEXTBOX  Control_w WIDTH 45 NUMERIC INPUTMASK "999" 
   @  65, 590 TEXTBOX  Control_h WIDTH 45 NUMERIC INPUTMASK "999" on lostfocus save_grid()
   
   @ 100, 520 TEXTBOX  Control_1         UPPERCASE // INPUTMASK "!!!!!!!!"
   @ 130, 520 TEXTBOX  Control_2         UPPERCASE // INPUTMASK "!!!!!!!!"
   @ 160, 520 TEXTBOX  Control_3 NUMERIC INPUTMASK "99"
   @ 190, 520 TEXTBOX  Control_4         UPPERCASE // INPUTMASK "!!!!!!!!!!"
   @ 220, 520 TEXTBOX  Control_44        UPPERCASE // INPUTMASK "!!!!!!!!!!"
   @ 250, 520 TEXTBOX  Control_5 WIDTH 30 UPPERCASE
   @ 280, 520 TEXTBOX  Control_6 WIDTH 50 NUMERIC INPUTMASK "999"
   @ 280, 650 TEXTBOX  Control_7 WIDTH 50 NUMERIC INPUTMASK "99"
   @ 310, 520 TEXTBOX  Control_8 WIDTH 50 NUMERIC INPUTMASK "9999"
   @ 310, 650 TEXTBOX  Control_9 WIDTH 50 NUMERIC INPUTMASK "9999"
   @ 370, 520 TEXTBOX  Control_8a WIDTH 50 NUMERIC INPUTMASK "9999"
   @ 370, 650 TEXTBOX  Control_9a WIDTH 50 NUMERIC INPUTMASK "9999"  on lostfocus save_label()
   @ 400, 520 TEXTBOX  Control_10        UPPERCASE // INPUTMASK "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   @ 430, 520 TEXTBOX  Control_11        UPPERCASE // INPUTMASK "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   @ 460, 420 CHECKBOX  Control_12 CAPTION "Browse"
   @ 460, 520 CHECKBOX  Control_13 CAPTION "Display"
   @ 480, 420 CHECKBOX  Control_14 CAPTION "Input"
   @ 480, 520 CHECKBOX  Control_15 CAPTION "Edit"
   @ 500, 420 CHECKBOX  Control_16 CAPTION "Query"
   @ 500, 520 CHECKBOX  Control_17 CAPTION "Print"
   @ 520, 420 CHECKBOX  Control_18 CAPTION "Sum"
   @ 520, 520 CHECKBOX  Control_19 CAPTION "Validate"
   @ 460, 670 TEXTBOX  Control_20         UPPERCASE // INPUTMASK "!!!!!!!!!!"
   @ 480, 670 TEXTBOX  Control_21         UPPERCASE // INPUTMASK "!!!!!!!!!!"
   @ 500, 670 TEXTBOX  Control_22         UPPERCASE // INPUTMASK "!!!!!!!!!!"
   @ 520, 670 TEXTBOX  Control_23         UPPERCASE // INPUTMASK "!!!!!!!!!!"

RETURN
*:---------------------------------------------*
PROCEDURE QueryRecord_8611

   PreQuery_8611()

   SET FILTER TO &_qry_exp
   dbGotop()

   IF ! EMPTY( _qry_exp )
      COUNT TO found_rec FOR &_qry_exp
      dbGotop()

      IF found_rec = 0
         Win_3_2.Statusbar.Item(1) := "Not found!"
      ELSE
         Win_3_2.Statusbar.Item(1) := "Found " + ALLTRIM(STR(found_rec)) + " record(s)!"
      ENDIF
   ENDIF

   DisableField_8611()

   Win_3_2.Browse_3_2.Refresh
   Win_3_2.Browse_3_2.Enabled   := .T.

RETURN
*:---------------------------------------------*
PROCEDURE PreQuery_8611

_qry_exp := ""
_ima_filter := .F.

IF ! EMPTY ( Win_3_2.Control_1.Value )     // FORMNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FORMNAME = " + chr(34) + Win_3_2.Control_1.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_2.Value )     // DBFNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "DBFNAME = " + chr(34) + Win_3_2.Control_2.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_3.Value )     // FLDSEQ
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDSEQ = " + STR( Win_3_2.Control_3.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_4.Value )     // FLDNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDNAME = " + chr(34) + Win_3_2.Control_4.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_5.Value )     // FLDTYPE
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDTYPE = " + chr(34) + Win_3_2.Control_5.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_6.Value )     // FLDLEN
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDLEN = " + STR( Win_3_2.Control_6.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_7.Value )     // FLDDEC
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDDEC = " + STR( Win_3_2.Control_7.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_8.Value )     // FLDROW
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDROW = " + STR( Win_3_2.Control_8.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_9.Value )     // FLDCOL
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDCOL = " + STR( Win_3_2.Control_9.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_10.Value )     // FLDPICT
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDPICT = " + chr(34) + Win_3_2.Control_10.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_11.Value )     // FLDDEF
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDDEF = " + chr(34) + Win_3_2.Control_11.Value + chr(34)
      _ima_filter := .T.
ENDIF
/*
IF ! EMPTY ( Win_3_2.Control_20.Value )     // RANG_LOW
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "RANG_LOW = " + chr(34) + Win_3_2.Control_20.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_21.Value )     // RANG_HIGH
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "RANG_HIGH = " + chr(34) + Win_3_2.Control_21.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_22.Value )     // VALID_DBF
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_DBF = " + chr(34) + Win_3_2.Control_22.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_23.Value )     // VALID_NTX
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_NTX = " + chr(34) + Win_3_2.Control_23.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_24.Value )     // VALID_FLD
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_FLD = " + chr(34) + Win_3_2.Control_24.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_3_2.Control_25.Value )     // HELP_TXT
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "HELP_TXT = " + chr(34) + Win_3_2.Control_25.Value + chr(34)
      _ima_filter := .T.
ENDIF
*/
RETURN
*:******************************************************
FUNCTION test_grid ( _wind_name )

for x1 = 50 to 1000 step 50
   draw line in window &_wind_name at x1,0 to x1,1000 
next

for x1 = 100 to 1000 step 100
   draw line in window &_wind_name at x1,0 to x1,1000 pencolor {255,0,0}
next

for x2 = 50 to 1000 step 50
   draw line in window &_wind_name at 0,x2 to 1000,x2 
next

for x2 = 100 to 1000 step 100
   draw line in window &_wind_name at 0,x2 to 1000,x2 pencolor {0,255,0} 
next

return 0
*:*****************************************************
FUNCTION pre_izborform ()

_oldform = ''
select _frm_fld

if reccount() = 0
   msginfo('Nothing, first create Form')
   return .f.
endif

do while .not. eof()
   if _oldform != formname
      aadd( aForm, formname)
   endif
   _oldform = formname

   dbskip()
enddo

_key = aForm[1]
set filter to formname = _key
dbgotop()

select _frm_dbf
set filter to formname = _key
dbgotop()

return .t.
*:*****************************************************
FUNCTION IzaberiFormu () 

_red := win_3_2.combo_form.value 
_key := aForm [ _red ] 

select _frm_fld
set filter to formname = _key
dbgotop()

select _frm_dbf
set filter to formname = _key
dbgotop()

Win_3_2.Browse_3_2.Refresh

return 0
*:*****************************************************
/*
FUNCTION frm_test 

DEFINE WINDOW FromTest ;
		AT 10,10 ;
		WIDTH 800 ;  
		HEIGHT 700 ;
      TITLE 'Preview Form' ;
		MODAL
		
      ON KEY ESCAPE ACTION FromTest.Release

      @ 560, 700 LABEL label1 ; 
         VALUE " LEGENDA "
   
      @ 580, 700 LABEL label2 ; 
         VALUE " BROWSE "
      
      @ 600, 700 LABEL label3 ; 
         VALUE " LABEL "
         
      @ 620, 700 LABEL label4 ; 
         VALUE " FIELD "
         
	END WINDOW		 

   frmTest()
   
	CENTER WINDOW   FromTest
	ACTIVATE WINDOW FromTest
   
Return
*:******************************************************
function frmTest

// da podvucemo
 
DRAW LINE IN WINDOW FromTest AT 550,10 TO 550,785

// legenda

DRAW RECTANGLE IN WINDOW FromTest AT 580,680 TO 590,690 pencolor { 128,128,255 } FILLCOLOR { 128,128,255 }
DRAW RECTANGLE IN WINDOW FromTest AT 600,680 TO 610,690 pencolor { 55,201,48 } FILLCOLOR { 55,201,48 }
DRAW RECTANGLE IN WINDOW FromTest AT 620,680 TO 630,690 pencolor { 255,102,10 } FILLCOLOR { 255,102,10 }

// browse 

DRAW RECTANGLE IN WINDOW FromTest AT 90,10 TO 540,360 pencolor { 128,128,255 } FILLCOLOR { 128,128,255 }

dbgotop()
do while .not. eof()

   _row1 = fldrow
   _col1 = fldcol
   _row2 = fldrow + 20
   _col2 = fldcol + fldlen*10

   // label 
   
   DRAW RECTANGLE IN WINDOW FromTest AT _row1, _col1-100 TO _row2, _col1-5 pencolor { 55,201,48 } FILLCOLOR { 55,201,48 }
   
   // field
   
   DRAW RECTANGLE IN WINDOW FromTest AT _row1, _col1 TO _row2, _col2 pencolor { 255,102,10 } FILLCOLOR { 255,102,10 }

   dbskip()
enddo

*FromTest.Release

RETURN 0
*/
*:---------------------------------------------------
function fld_mov_down()

   if EditRec
      Win_3_2.Control_8.Value := Win_3_2.Control_8.Value + 10
   endif
   
   SaveRecord_8611()
   LoadData_8611()
   EnableField_8611()
   EditRec := .T.
   
   Win_3_2.Control_8.SetFocus
   
return 0
*:---------------------------------------------------
function fld_mov_up()

   if EditRec
      Win_3_2.Control_8.Value := Win_3_2.Control_8.Value - 10
   endif
   
   SaveRecord_8611()
   LoadData_8611()
   EnableField_8611()
   EditRec := .T.
   
   Win_3_2.Control_8.SetFocus
   
return 0
*:---------------------------------------------------
function fld_mov_left()

   if EditRec
      Win_3_2.Control_9.Value := Win_3_2.Control_9.Value - 10
   endif
   
   SaveRecord_8611()
   LoadData_8611()
   EnableField_8611()
   EditRec := .T.
   
   Win_3_2.Control_9.SetFocus
   
return 0
*:---------------------------------------------------
function fld_mov_right()

   if EditRec
      Win_3_2.Control_9.Value := Win_3_2.Control_9.Value + 10
   endif
   
   SaveRecord_8611()
   LoadData_8611()
   EnableField_8611()
   EditRec := .T.
   
   Win_3_2.Control_9.SetFocus
   
return 0
*:---------------------------------------------------
FUNCTION frm_preview_8611 ( )

private desk_pozx := getDesktopWidth() - 1020

   if IsWindowActive( FormPrev )
       DoMethod( 'FormPrev', "RELEASE" )
   endif
   
   DEFINE WINDOW FormPrev ;
      AT 20, desk_pozx ;
      WIDTH 1000 ; 
      HEIGHT 800 ;
      TITLE 'Preview Form' ;
      CHILD
      
      ON KEY ESCAPE ACTION FormPrev.Release

      @ 730, 10 LABEL label1x ;  
         VALUE " LEGEND " TRANSPARENT 
   
      @ 730, 120 LABEL label2x ; 
         VALUE " GRID " TRANSPARENT  
     
      @ 730, 220 LABEL label3x ; 
         VALUE " LABEL " TRANSPARENT 
         
      @ 730, 320 LABEL label4x ; 
         VALUE " FIELD " TRANSPARENT 
   
   END WINDOW      
   
   Win_3_2.prevcmd_1.Visible     := .T.
   Win_3_2.prevcmd_2.Visible     := .T.
   Win_3_2.prevcmd_3.Visible     := .T.
   
   fmPrev( )
   
   *CENTER WINDOW   FromTest
   ACTIVATE WINDOW FormPrev
      
Return
*:******************************************************
function fmPrev ( )

// make line
 
DRAW LINE IN WINDOW FormPrev AT 710,5 TO 710,795

// show legenda

DRAW RECTANGLE IN WINDOW FormPrev AT 730,100 TO 740,110 pencolor { 128,128,255 } FILLCOLOR { 128,128,255 }
DRAW RECTANGLE IN WINDOW FormPrev AT 730,200 TO 740,210 pencolor { 55,201,48 } FILLCOLOR { 55,201,48 }
DRAW RECTANGLE IN WINDOW FormPrev AT 730,300 TO 740,310 pencolor { 255,102,10 } FILLCOLOR { 255,102,10 }

select _frm_dbf
*set filter to formname = _tab_name
*dbgotop()

_grid_h = grid_h + 90
_grid_w = grid_w + 10

// show grid

DRAW RECTANGLE IN WINDOW FormPrev AT 90,10 TO _grid_h,_grid_w pencolor { 128,128,255 } FILLCOLOR { 128,128,255 }
select _frm_fld
*set filter to formname = _tab_name
dbgotop()

do while .not. eof()

   _row1 = fldrow
   _col1 = fldcol
   _row2 = fldrow + 20
   _col2 = fldcol + fldlen * 10
   _rowl = fldrow + labrow
   _coll = fldcol + labcol
   _labx = 'label' + alltrim(str(recno()))
   _labxx = 'label' + alltrim(str(recno()+100))
   _labv = fldlabel   
   _labf = fldname
   
   // labels

   if !empty(fldlabel)
      DRAW RECTANGLE IN WINDOW FormPrev AT _rowl, _coll TO _rowl+15, _coll+50 pencolor { 55,201,48 } FILLCOLOR { 55,201,48 }
      @ _rowl, _coll LABEL &(_labx) VALUE _labv OF FormPrev transparent           // << tranparent if you want see rectangle
   endif
         
   // fields

if dbfname != '$'
   
   DRAW RECTANGLE IN WINDOW FormPrev AT _row1, _col1 TO _row2, _col2 pencolor { 255,102,10 } FILLCOLOR { 255,102,10 }
    @ _row1, _col1 LABEL &(_labxx) VALUE _labf OF FormPrev transparent          // << tranparent if you want see rectangle
   
else
   
   DRAW RECTANGLE IN WINDOW FormPrev AT _row1, _col1 TO _row2, _col2 pencolor { 255,155,10 } FILLCOLOR { 255,155,10 }
    @ _row1, _col1 LABEL &(_labxx) VALUE _labf OF FormPrev transparent          // << tranparent if you want see rectangle

endif
  
   dbskip()
enddo

Win_3_2.Browse_3_2.SetFocus

RETURN 0
*:-----------------------------------------
function set_grid ()

   CancelEdit_8611()

   Win_3_2.Control_w.Enabled    := .T.
   Win_3_2.Control_h.Enabled    := .T.
  
   Win_3_2.Control_w.SetFocus
  
return
*:-----------------------------------------
function save_grid ()
      
   select _frm_dbf
      
   _FRM_DBF->grid_w   := Win_3_2.Control_w.Value
   _FRM_DBF->grid_h   := Win_3_2.Control_h.Value
   dbcommit()  

   *msginfo( formname ) 
   
   select _frm_fld
   
   Win_3_2.Control_w.Enabled    := .F.
   Win_3_2.Control_h.Enabled    := .F.

   if IsWindowActive( FormPrev )
      frm_preview_8611 ( )
   endif
   
   Win_3_2.Browse_3_2.SetFocus
  
return
*:-----------------------------------------
function set_label ()

   CancelEdit_8611()

   Win_3_2.Control_8a.Enabled    := .T.
   Win_3_2.Control_9a.Enabled    := .T.
  
   Win_3_2.Control_8a.SetFocus
  
return
*:-----------------------------------------
function save_label ()

   _labrow := Win_3_2.Control_8a.Value 
   _labcol := Win_3_2.Control_9a.Value 
   
   select _frm_fld
   dbgotop()
   replace labrow with _labrow all
   replace labcol with _labcol all
   dbcommit()  

   Win_3_2.Control_8a.Enabled    := .F.
   Win_3_2.Control_9a.Enabled    := .F.

   if IsWindowActive( FormPrev )
      frm_preview_8611 ( )
   endif
   
   Win_3_2.Browse_3_2.SetFocus
  
return
