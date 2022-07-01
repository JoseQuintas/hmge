#include <hmg.ch>

PROCEDURE FMD_EDT

   PUBLIC NewRec := .F. , EditRec := .F. , _qry_exp := "", _key, aForm := {}
   
   Use _fmd_fld index _fmd_fld
   
   if !pre_Izbormform()
      return 
   endif
  
  DEFINE WINDOW Win_4_2 ;
      AT 20,20 ;
      WIDTH 800 ;
      HEIGHT 700 ;
      TITLE "M/D form edit" ;
      CHILD ; // for test, usually MODAL
      ON INIT fmd_preview_7112() ;
      ON RELEASE at_end_7112()

      ON KEY ESCAPE ACTION CancelEdit_7112()
	  
 	   ON KEY F7   ACTION Find_7112()
	   ON KEY F4   ACTION ( EditRec := .T., NewRec := .F., If ( RecordStatus_7112(), EnableField_7112(), Nil ))
	   ON KEY F6   ACTION ( NewRec := .T., EditRec = .F., NewRecord_7112() )
	   ON KEY F8   ACTION ( RecordStatus_7112(), DeleteRecord_7112(), Nil )
	   *ON KEY F9   ACTION PrintData_7112()
	   ON KEY F10  ACTION Win_4_2.Release
    	  
      ON KEY CONTROL+DOWN    ACTION fmd_mov_down()
      ON KEY CONTROL+UP      ACTION fmd_mov_up() 
      ON KEY CONTROL+LEFT    ACTION fmd_mov_left() 
      ON KEY CONTROL+RIGHT   ACTION fmd_mov_right()
 
      DEFINE STATUSBAR FONT "Arial" SIZE 12
         STATUSITEM "MD form definition"
         STATUSITEM "" WIDTH 50
      END STATUSBAR

      DEFINE TOOLBAR ToolBar_4_2 BUTTONSIZE 50,50 IMAGESIZE 24,24 FLAT BORDER
/*
      BUTTON FIRST_7112 ;
         CAPTION "First" ;
         PICTURE "go_first" ;
         ACTION( dbGotop(), Win_4_2.Browse_4_2.Value := RecNo() )

      BUTTON PREV_7112 ;
         CAPTION "Prev" ;
         PICTURE "go_prev" ;
         ACTION( dbSkip( -1 ), Win_4_2.Browse_4_2.Value := RecNo() )

      BUTTON NEXT_7112 ;
         CAPTION "Next" ;
         PICTURE "go_next" ;
         ACTION( dbSkip(), if ( Eof(), dbGobottom(), Nil ), Win_4_2.Browse_4_2.Value := RecNo() )

      BUTTON LAST_7112 ;
         CAPTION "Last" ;
         PICTURE "go_last" ;
         ACTION( dbGoBottom(), Win_4_2.Browse_4_2.Value := RecNo() )   SEPARATOR 

      BUTTON FIND_7112 ;
         CAPTION "[F7] Find" ;
         PICTURE "edit_find" ;
         ACTION Find_7112()
*/
      BUTTON EDIT_7112 ;
         CAPTION "[F4] Edit" ;
         PICTURE "edit_edit" ;
         ACTION ( EditRec := .T., NewRec := .F., If ( RecordStatus_7112(), EnableField_7112(), Nil ))

      BUTTON NEW_7112 ;
         CAPTION "[F6] New" ;
         PICTURE "edit_new" ;
         ACTION ( NewRec := .T., EditRec = .F., NewRecord_7112() )

      BUTTON DELETE_7112 ;
         CAPTION "[F8] Delete" ;
         PICTURE "edit_delete" ;
         ACTION ( RecordStatus_7112(), DeleteRecord_7112(), Nil )
/*
      BUTTON PRINT_7112 ;
         CAPTION "[F9] Print" ;
         PICTURE "edit_print" ;
         ACTION PrintData_7112()
*/
      BUTTON EXIT_7112 ;
         CAPTION "[F10] Exit" ;
         PICTURE "edit_close" ;
         ACTION Win_4_2.Release

      END TOOLBAR

      PaintDisplay_7112()
     
      @ 90,10 COMBOBOX Combo_form ;
         WIDTH 140 ;
         HEIGHT 160 ;
         ITEMS aForm ;
         VALUE 1 ;
         ON CHANGE IzaberFormu()
      
      @ 130,10 BROWSE Browse_4_2 ;
         OF Win_4_2 ;
         WIDTH 370 ;
         HEIGHT 420 ;
         FONT "Arial" ; 
         SIZE 10 ;
         HEADERS { "Form","Block","DBF","No","Field Name" } ;
         WIDTHS { 80,40,90,40,110 } ;
         WORKAREA _FMD_FLD ;
         FIELDS { "FORMNAME","BLOCK","DBFNAME","FLDSEQ","FLDNAME" } ;
         ON CHANGE LoadData_7112() ;
         ON HEADCLICK { {||head1_7112()}, {||head2_7112()} } ;
         ON DBLCLICK ( EnableField_7112(), If ( ! RecordStatus_7112(), DisableField_7112(), Nil ) ) ;
         JUSTIFY { , BROWSE_JTFY_RIGHT, , BROWSE_JTFY_RIGHT, , } 

      @ 580, 50 BUTTON SAVE_7112 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_7112() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,150 BUTTON CANCEL_7112 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_7112() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,275 BUTTON QUERY_7112 ;
         CAPTION "Query" ;
         PICTURE "edit_find" RIGHT ;
         ACTION QueryRecord_7112() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 580,390 BUTTON PREVIEW_7112 ;
         CAPTION "Preview form" ;
         ACTION fmd_preview_7112 ( _fmd_fld->formname ) ;
         WIDTH 100 ;
         HEIGHT 40 
         
   /*   @ 580,600 BUTTON FRESH_7112 ;
         CAPTION "Refresh" ;
         ACTION Refresh_7112() ;
         WIDTH 100 ;
         HEIGHT 40 */
       
      @ 580, 500 LABEL prevcmd_1 VALUE "Select row with Enter or [F4] Edit than" WIDTH 300
      @ 595, 500 LABEL prevcmd_2 VALUE "Ctrl+Up/Ctlr+Down change field position up/down" WIDTH 300
      @ 610, 500 LABEL prevcmd_3 VALUE "Ctrl+Left/Ctlr+Right cahnge filed position left/right" WIDTH 300	 
       
   END WINDOW

   DisableField_7112()

   Win_4_2.Browse_4_2.SetFocus
   Win_4_2.Browse_4_2.Value := _FMD_FLD->(RecNo())

   ACTIVATE WINDOW Win_4_2

RETURN
*:---------------------------------------------*
FUNCTION at_end_7112()

   if IsWindowActive( FmdPrev )
       DoMethod( 'FmdPrev', "RELEASE" )
   endif

   re_order_fmd()

RETURN

*:---------------------------------------------*
PROCEDURE DisableField_7112

   Win_4_2.Browse_4_2.Enabled      := .T.

   Win_4_2.mFORMNAME.Enabled     := .F.
   Win_4_2.mBLOCK.Enabled        := .F.
   Win_4_2.mDBFNAME.Enabled      := .F.
   Win_4_2.mFLDSEQ.Enabled       := .F.
   Win_4_2.mFLDNAME.Enabled      := .F.
   Win_4_2.mFLDLABEL.Enabled     := .F.
   Win_4_2.mFLDTYPE.Enabled      := .F.
   Win_4_2.mFLDLEN.Enabled       := .F.
   Win_4_2.mFLDDEC.Enabled       := .F.
   Win_4_2.mFLDROW.Enabled       := .F.
   Win_4_2.mFLDCOL.Enabled       := .F.
   Win_4_2.mFLDPICT.Enabled      := .F.
   Win_4_2.mFLDDEF.Enabled       := .F.
   Win_4_2.mFLDATR1.Enabled      := .F.
   Win_4_2.mFLDATR2.Enabled      := .F.
   Win_4_2.mFLDATR3.Enabled      := .F.
   Win_4_2.mFLDATR4.Enabled      := .F.
   Win_4_2.mFLDATR5.Enabled      := .F.
   Win_4_2.mFLDATR6.Enabled      := .F.
   Win_4_2.mFLDATR7.Enabled      := .F.
   Win_4_2.mFLDATR8.Enabled      := .F.
   Win_4_2.mVALID_DBF.Enabled    := .F.
   Win_4_2.mVALID_KEY.Enabled    := .F.
   Win_4_2.mVALID_FLD.Enabled    := .F.
   Win_4_2.mVALID_DSP.Enabled    := .F.

   Win_4_2.Combo_form.Enabled    := .T.  
   Win_4_2.Save_7112.Enabled     := .F.
   Win_4_2.Cancel_7112.Enabled   := .F.
   Win_4_2.Query_7112.Enabled    := .F.
   Win_4_2.Toolbar_4_2.Enabled     := .T.
   Win_4_2.Browse_4_2.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE EnableField_7112

   Win_4_2.Browse_4_2.Enabled      := .F.

   Win_4_2.mFORMNAME.Enabled     := .T.
   Win_4_2.mBLOCK.Enabled        := .T.
   Win_4_2.mDBFNAME.Enabled      := .T.
   Win_4_2.mFLDSEQ.Enabled       := .T.
   Win_4_2.mFLDNAME.Enabled      := .T.
   Win_4_2.mFLDLABEL.Enabled     := .T.
   Win_4_2.mFLDTYPE.Enabled      := .T.
   Win_4_2.mFLDLEN.Enabled       := .T.
   Win_4_2.mFLDDEC.Enabled       := .T.
   Win_4_2.mFLDROW.Enabled       := .T.
   Win_4_2.mFLDCOL.Enabled       := .T.
   Win_4_2.mFLDPICT.Enabled      := .T.
   Win_4_2.mFLDDEF.Enabled       := .T.
   Win_4_2.mFLDATR1.Enabled      := .T.
   Win_4_2.mFLDATR2.Enabled      := .T.
   Win_4_2.mFLDATR3.Enabled      := .T.
   Win_4_2.mFLDATR4.Enabled      := .T.
   Win_4_2.mFLDATR5.Enabled      := .T.
   Win_4_2.mFLDATR6.Enabled      := .T.
   Win_4_2.mFLDATR7.Enabled      := .T.
   Win_4_2.mFLDATR8.Enabled      := .T.
   Win_4_2.mVALID_DBF.Enabled    := .T.
   Win_4_2.mVALID_KEY.Enabled    := .T.
   Win_4_2.mVALID_FLD.Enabled    := .T.
   Win_4_2.mVALID_DSP.Enabled    := .T.

   Win_4_2.Combo_form.Enabled    := .F. 
   Win_4_2.Save_7112.Enabled     := .T.
   Win_4_2.Cancel_7112.Enabled   := .T.
   Win_4_2.Query_7112.Enabled    := .F.
   Win_4_2.Toolbar_4_2.Enabled     := .F.
   Win_4_2.mBLOCK.SetFocus

RETURN
*:---------------------------------------------*
FUNCTION RecordStatus_7112()

   Local RetVal

   _FMD_FLD->( dbGoTo ( Win_4_2.Browse_4_2.Value ) )

   IF _FMD_FLD->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*:---------------------------------------------*
PROCEDURE LoadData_7112

   _FMD_FLD->( dbGoTo ( Win_4_2.Browse_4_2.Value ) )

   Win_4_2.mFORMNAME.Value     := _FMD_FLD->FORMNAME  
   Win_4_2.mBLOCK.Value        := _FMD_FLD->BLOCK     
   Win_4_2.mDBFNAME.Value      := _FMD_FLD->DBFNAME   
   Win_4_2.mFLDSEQ.Value       := _FMD_FLD->FLDSEQ    
   Win_4_2.mFLDNAME.Value      := _FMD_FLD->FLDNAME   
   Win_4_2.mFLDLABEL.Value     := _FMD_FLD->FLDLABEL  
   Win_4_2.mFLDTYPE.Value      := _FMD_FLD->FLDTYPE   
   Win_4_2.mFLDLEN.Value       := _FMD_FLD->FLDLEN    
   Win_4_2.mFLDDEC.Value       := _FMD_FLD->FLDDEC    
   Win_4_2.mFLDROW.Value       := _FMD_FLD->FLDROW    
   Win_4_2.mFLDCOL.Value       := _FMD_FLD->FLDCOL    
   Win_4_2.mFLDPICT.Value      := _FMD_FLD->FLDPICT   
   Win_4_2.mFLDDEF.Value       := _FMD_FLD->FLDDEF    
   Win_4_2.mFLDATR1.Value      := _FMD_FLD->FLDATR1   
   Win_4_2.mFLDATR2.Value      := _FMD_FLD->FLDATR2   
   Win_4_2.mFLDATR3.Value      := _FMD_FLD->FLDATR3   
   Win_4_2.mFLDATR4.Value      := _FMD_FLD->FLDATR4   
   Win_4_2.mFLDATR5.Value      := _FMD_FLD->FLDATR5   
   Win_4_2.mFLDATR6.Value      := _FMD_FLD->FLDATR6   
   Win_4_2.mFLDATR7.Value      := _FMD_FLD->FLDATR7   
   Win_4_2.mFLDATR8.Value      := _FMD_FLD->FLDATR8   
   Win_4_2.mVALID_DBF.Value    := _FMD_FLD->VALID_DBF 
   Win_4_2.mVALID_KEY.Value    := _FMD_FLD->VALID_KEY 
   Win_4_2.mVALID_FLD.Value    := _FMD_FLD->VALID_FLD 
   Win_4_2.mVALID_DSP.Value    := _FMD_FLD->VALID_DSP 

RETURN
*:---------------------------------------------*
PROCEDURE CancelEdit_7112

   DisableField_7112()
   LoadData_7112()
   UNLOCK
   NewRec := .F.

RETURN
*:---------------------------------------------*
PROCEDURE SaveRecord_7112

   Local NewRecNo

   DisableField_7112()

   IF NewRec == .T.
      _FMD_FLD->(dbAppend())
      NewRec := .F.
   ELSE
      _FMD_FLD->(dbGoto ( Win_4_2.Browse_4_2.Value ) )
   ENDIF

   NewRecNo :=_FMD_FLD->( RecNo() )

   _FMD_FLD->FORMNAME   := Win_4_2.mFORMNAME.Value
   _FMD_FLD->BLOCK      := Win_4_2.mBLOCK.Value
   _FMD_FLD->DBFNAME    := Win_4_2.mDBFNAME.Value
   _FMD_FLD->FLDSEQ     := Win_4_2.mFLDSEQ.Value
   _FMD_FLD->FLDNAME    := Win_4_2.mFLDNAME.Value
   _FMD_FLD->FLDLABEL   := Win_4_2.mFLDLABEL.Value
   _FMD_FLD->FLDTYPE    := Win_4_2.mFLDTYPE.Value
   _FMD_FLD->FLDLEN     := Win_4_2.mFLDLEN.Value
   _FMD_FLD->FLDDEC     := Win_4_2.mFLDDEC.Value
   _FMD_FLD->FLDROW     := Win_4_2.mFLDROW.Value
   _FMD_FLD->FLDCOL     := Win_4_2.mFLDCOL.Value
   _FMD_FLD->FLDPICT    := Win_4_2.mFLDPICT.Value
   _FMD_FLD->FLDDEF     := Win_4_2.mFLDDEF.Value
   _FMD_FLD->FLDATR1    := Win_4_2.mFLDATR1.Value
   _FMD_FLD->FLDATR2    := Win_4_2.mFLDATR2.Value
   _FMD_FLD->FLDATR3    := Win_4_2.mFLDATR3.Value
   _FMD_FLD->FLDATR4    := Win_4_2.mFLDATR4.Value
   _FMD_FLD->FLDATR5    := Win_4_2.mFLDATR5.Value
   _FMD_FLD->FLDATR6    := Win_4_2.mFLDATR6.Value
   _FMD_FLD->FLDATR7    := Win_4_2.mFLDATR7.Value
   _FMD_FLD->FLDATR8    := Win_4_2.mFLDATR8.Value
   _FMD_FLD->VALID_DBF  := Win_4_2.mVALID_DBF.Value
   _FMD_FLD->VALID_KEY  := Win_4_2.mVALID_KEY.Value
   _FMD_FLD->VALID_FLD  := Win_4_2.mVALID_FLD.Value
   _FMD_FLD->VALID_DSP  := Win_4_2.mVALID_DSP.Value

   Win_4_2.Browse_4_2.Refresh
   IF NewRec == .T.
      Win_4_2.Browse_4_2.Value := NewRecNo 
   ENDIF

   UNLOCK
   dbCommitall()
   
   if IsWindowActive( FmdPrev )
      fmd_preview_7112 ( )
   endif
   
   Win_4_2.StatusBar.Item(1) := "Save Record" 

RETURN
*:---------------------------------------------*
PROCEDURE NewRecord_7112

   Win_4_2.StatusBar.Item(1) := "Editing" 

   SET ORDER TO 1
   dbGoBottom()
   _row = fldrow
      
   Win_4_2.mFORMNAME.Value     := _FMD_FLD->formname
   Win_4_2.mBLOCK.Value        := 2
   Win_4_2.mDBFNAME.Value      := '$'
   Win_4_2.mFLDSEQ.Value       := 99
   Win_4_2.mFLDNAME.Value      := space(10)
   Win_4_2.mFLDLABEL.Value     := space(20)
   Win_4_2.mFLDTYPE.Value      := 'C'
   Win_4_2.mFLDLEN.Value       := 10
   Win_4_2.mFLDDEC.Value       := 0
   Win_4_2.mFLDROW.Value       := _row + 30
   Win_4_2.mFLDCOL.Value       := 100
   Win_4_2.mFLDPICT.Value      := space(30)
   Win_4_2.mFLDDEF.Value       := space(30)
   Win_4_2.mFLDATR1.Value      := .F.
   Win_4_2.mFLDATR2.Value      := .F.
   Win_4_2.mFLDATR3.Value      := .F.
   Win_4_2.mFLDATR4.Value      := .F.
   Win_4_2.mFLDATR5.Value      := .F.
   Win_4_2.mFLDATR6.Value      := .F.
   Win_4_2.mFLDATR7.Value      := .T.
   Win_4_2.mFLDATR8.Value      := .F.
   Win_4_2.mVALID_DBF.Value    := space(10)
   Win_4_2.mVALID_KEY.Value    := space(10)
   Win_4_2.mVALID_FLD.Value    := space(10)
   Win_4_2.mVALID_DSP.Value    := space(10)

   EnableField_7112()

   Win_4_2.mBLOCK.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE DeleteRecord_7112

   IF MsgYesNo ( "Are you sure do you want delete record?" )
      IF _FMD_FLD->(FLock())
         DELETE
         Win_4_2.Browse_4_2.Refresh
         UNLOCK
      ENDIF
   ENDIF

RETURN
*:---------------------------------------------*
PROCEDURE Find_7112

   Win_4_2.StatusBar.Item(1) := "Query" 

   Win_4_2.mFORMNAME.Value     := space(8)
   Win_4_2.mBLOCK.Value        := 0
   Win_4_2.mDBFNAME.Value      := space(8)
   Win_4_2.mFLDSEQ.Value       := 0
   Win_4_2.mFLDNAME.Value      := space(10)
   Win_4_2.mFLDLABEL.Value     := space(20)
   Win_4_2.mFLDTYPE.Value      := space(1)
   Win_4_2.mFLDLEN.Value       := 0
   Win_4_2.mFLDDEC.Value       := 0
   Win_4_2.mFLDROW.Value       := 0
   Win_4_2.mFLDCOL.Value       := 0
   Win_4_2.mFLDPICT.Value      := space(30)
   Win_4_2.mFLDDEF.Value       := space(30)
   Win_4_2.mFLDATR1.Value      := .T.
   Win_4_2.mFLDATR2.Value      := .T.
   Win_4_2.mFLDATR3.Value      := .T.
   Win_4_2.mFLDATR4.Value      := .T.
   Win_4_2.mFLDATR5.Value      := .T.
   Win_4_2.mFLDATR6.Value      := .T.
   Win_4_2.mFLDATR7.Value      := .T.
   Win_4_2.mFLDATR8.Value      := .T.
   Win_4_2.mVALID_DBF.Value    := space(10)
   Win_4_2.mVALID_KEY.Value    := space(10)
   Win_4_2.mVALID_FLD.Value    := space(10)
   Win_4_2.mVALID_DSP.Value    := space(10)

   EnableField_7112()
   Win_4_2.Save_7112.Enabled  := .F.
   Win_4_2.Query_7112.Enabled := .T.
   Win_4_2.Control_1.SetFocus

RETURN
*:---------------------------------------------*
PROCEDURE PrintData_7112

   Local RecRec 

   RecRec := _FMD_FLD->( RecNo())
   dbGoTop()
   DO REPORT ;
      TITLE "FMD_FLD" ;
      HEADERS { "","","","","","","","","","","","","","","","","","","","","","","","","" }, { "FORMNAME","BLOCK","DBFNAME","FLDSEQ","FLDNAME","FLDLABEL","FLDTYPE","FLDLEN","FLDDEC","FLDROW","FLDCOL","FLDPICT","FLDDEF","FLDATR1","FLDATR2","FLDATR3","FLDATR4","FLDATR5","FLDATR6","FLDATR7","FLDATR8","VALID_DBF","VALID_KEY","VALID_FLD","VALID_DSP" } ;
      FIELDS { "FORMNAME","BLOCK","DBFNAME","FLDSEQ","FLDNAME","FLDLABEL","FLDTYPE","FLDLEN","FLDDEC","FLDROW","FLDCOL","FLDPICT","FLDDEF","FLDATR1","FLDATR2","FLDATR3","FLDATR4","FLDATR5","FLDATR6","FLDATR7","FLDATR8","VALID_DBF","VALID_KEY","VALID_FLD","VALID_DSP" } ;
      WIDTHS { 9,6,9,7,11,21,8,7,7,7,7,31,31,8,8,8,8,8,8,8,8,11,11,11,11 } ;
      TOTALS { .F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F. } ;
      WORKAREA _FMD_FLD ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 5 ;
      PREVIEW
   _FMD_FLD->(dbGoTo(RecRec))

RETURN
*:---------------------------------------------*
PROCEDURE PaintDisplay_7112

   @  90,410 FRAME Frame_4_2 WIDTH 375 HEIGHT 490

   @ 100, 420 LABEL Label_1 VALUE "Form"
   @ 130, 420 LABEL Label_4_2 VALUE "Block"
   @ 160, 420 LABEL Label_3 VALUE "DBF"
   @ 190, 420 LABEL Label_4 VALUE "No"
   @ 220, 420 LABEL Label_5 VALUE "Field Name"
   @ 250, 420 LABEL Label_6 VALUE "Label"
   @ 280, 420 LABEL Label_7 VALUE "Field Type"
   @ 310, 420 LABEL Label_8 VALUE "Field Len"
   @ 340, 420 LABEL Label_9 VALUE "Field Dec"
   @ 370, 420 LABEL Label_10 VALUE "Row"
   @ 400, 420 LABEL Label_11 VALUE "Col"
   @ 430, 420 LABEL Label_12 VALUE "Picture"
   @ 460, 420 LABEL Label_13 VALUE "Default"
   @ 490, 620 LABEL Label_4_22 VALUE "DBF"
   @ 510, 620 LABEL Label_4_23 VALUE "Key"
   @ 530, 620 LABEL Label_4_24 VALUE "Valid"
   @ 550, 620 LABEL Label_4_25 VALUE "Display"

   @ 100, 520 TEXTBOX  mFORMNAME    WIDTH 90 INPUTMASK "!!!!!!!!"
   @ 130, 520 TEXTBOX  mBLOCK       WIDTH 30 NUMERIC INPUTMASK "99"
   @ 160, 520 TEXTBOX  mDBFNAME     WIDTH 90 INPUTMASK "!!!!!!!!" on lostfocus CHK_temp_dbf ()
   @ 190, 520 TEXTBOX  mFLDSEQ      WIDTH 30 NUMERIC INPUTMASK "99"
   @ 220, 520 TEXTBOX  mFLDNAME     WIDTH 110 INPUTMASK "!!!!!!!!!!"
   @ 250, 520 TEXTBOX  mFLDLABEL    WIDTH 210 INPUTMASK "!!!!!!!!!!!!!!!!!!!!"
   @ 280, 520 TEXTBOX  mFLDTYPE     WIDTH 20 INPUTMASK "!"
   @ 310, 520 TEXTBOX  mFLDLEN      WIDTH 40 NUMERIC INPUTMASK "999"
   @ 340, 520 TEXTBOX  mFLDDEC      WIDTH 30 NUMERIC INPUTMASK "99"
   @ 370, 520 TEXTBOX  mFLDROW      WIDTH 40 NUMERIC INPUTMASK "9999"
   @ 400, 520 TEXTBOX  mFLDCOL      WIDTH 40 NUMERIC INPUTMASK "9999"
   @ 430, 520 TEXTBOX  mFLDPICT     WIDTH 110 INPUTMASK "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   @ 460, 520 TEXTBOX  mFLDDEF      WIDTH 110 INPUTMASK "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   @ 490, 420 CHECKBOX  mFLDATR1     CAPTION "Browse"
   @ 490, 520 CHECKBOX  mFLDATR2     CAPTION "Display"
   @ 510, 420 CHECKBOX  mFLDATR3     CAPTION "Input"
   @ 510, 520 CHECKBOX  mFLDATR4     CAPTION "Edit"
   @ 530, 420 CHECKBOX  mFLDATR5     CAPTION "Sum"
   @ 530, 520 CHECKBOX  mFLDATR6     CAPTION "Query"
   @ 550, 420 CHECKBOX  mFLDATR7     CAPTION "Display"
   @ 550, 520 CHECKBOX  mFLDATR8     CAPTION "Validate"
   @ 490, 670 TEXTBOX  mVALID_DBF   WIDTH 100 INPUTMASK "!!!!!!!!!!"
   @ 510, 670 TEXTBOX  mVALID_KEY   WIDTH 100 INPUTMASK "!!!!!!!!!!"
   @ 530, 670 TEXTBOX  mVALID_FLD   WIDTH 100 INPUTMASK "!!!!!!!!!!"
   @ 550, 670 TEXTBOX  mVALID_DSP   WIDTH 100 INPUTMASK "!!!!!!!!!!" on lostfocus CHK_validate ()
   
RETURN
*:---------------------------------------------*
FUNCTION chk_temp_dbf()

* msginfo(Win_4_2.mDBFNAME.Value)

   if alltrim(Win_4_2.mDBFNAME.Value) = '$'
      Win_4_2.mFLDATR1.Value := .T.
   endif 
   
RETURN .T.
*:---------------------------------------------*
FUNCTION chk_validate ()

   _c1 := !empty(Win_4_2.mValid_dbf.Value)
   _c2 := !empty(Win_4_2.mValid_key.Value) 
   _c3 := !empty(Win_4_2.mValid_fld.Value)
   _c4 := !empty(Win_4_2.mValid_dsp.Value) 

   if _c1 .and. _c2 .and. _c3 .and. _c4
      Win_4_2.mFLDATR8.Value := .T.
   else   
      Win_4_2.mFLDATR8.Value := .F.
   endif 
   
RETURN .T.
*:---------------------------------------------*
PROCEDURE Head1_7112

   SELECT _FMD_FLD
   SET ORDER TO 1
   dbGotop()
   Win_4_2.Browse_4_2.Value := RecNo()
   Win_4_2.Browse_4_2.Refresh
   LoadData_7112()

RETURN
*:---------------------------------------------*
PROCEDURE Head2_7112

   SELECT _FMD_FLD
   SET ORDER TO 2
   dbGotop()
   Win_4_2.Browse_4_2.Value := RecNo()
   Win_4_2.Browse_4_2.Refresh
   LoadData_7112()

RETURN
*:---------------------------------------------*
PROCEDURE QueryRecord_7112

   PreQuery_7112()

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

   DisableField_7112()

   Win_4_2.Browse_4_2.Refresh
   Win_4_2.Browse_4_2.Enabled   := .T.

RETURN
*:---------------------------------------------*
PROCEDURE PreQuery_7112

_qry_exp := ""
_ima_filter := .F.

IF ! EMPTY ( Win_4_2.mFORMNAME.Value )     // FORMNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FORMNAME = " + chr(34) + Win_4_2.mFORMNAME.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mBLOCK.Value )     // BLOCK
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "BLOCK = " + STR( Win_4_2.mBLOCK.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mDBFNAME.Value )     // DBFNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "DBFNAME = " + chr(34) + Win_4_2.mDBFNAME.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDSEQ.Value )     // FLDSEQ
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDSEQ = " + STR( Win_4_2.mFLDSEQ.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDNAME.Value )     // FLDNAME
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDNAME = " + chr(34) + Win_4_2.mFLDNAME.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDLABEL.Value )     // FLDLABEL
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDLABEL = " + chr(34) + Win_4_2.mFLDLABEL.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDTYPE.Value )     // FLDTYPE
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDTYPE = " + chr(34) + Win_4_2.mFLDTYPE.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDLEN.Value )     // FLDLEN
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDLEN = " + STR( Win_4_2.mFLDLEN.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDDEC.Value )     // FLDDEC
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDDEC = " + STR( Win_4_2.mFLDDEC.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDROW.Value )     // FLDROW
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDROW = " + STR( Win_4_2.mFLDROW.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDCOL.Value )     // FLDCOL
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDCOL = " + STR( Win_4_2.mFLDCOL.Value )
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDPICT.Value )     // FLDPICT
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDPICT = " + chr(34) + Win_4_2.mFLDPICT.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mFLDDEF.Value )     // FLDDEF
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "FLDDEF = " + chr(34) + Win_4_2.mFLDDEF.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mVALID_DBF.Value )     // VALID_DBF
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_DBF = " + chr(34) + Win_4_2.mVALID_DBF.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mVALID_KEY.Value )     // VALID_KEY
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_KEY = " + chr(34) + Win_4_2.mVALID_KEY.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mVALID_FLD.Value )     // VALID_FLD
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_FLD = " + chr(34) + Win_4_2.mVALID_FLD.Value + chr(34)
      _ima_filter := .T.
ENDIF

IF ! EMPTY ( Win_4_2.mVALID_DSP.Value )     // VALID_DSP
   IF _ima_filter
      _qry_exp = _qry_exp + " .AND. "
   ENDIF
      _qry_exp = _qry_exp + "VALID_DSP = " + chr(34) + Win_4_2.mVALID_DSP.Value + chr(34)
      _ima_filter := .T.
ENDIF

RETURN
*:*********************************
FUNCTION pre_izbormform ()

_oldform = ''
select _fmd_fld

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

return .t.
*:*****************************************
FUNCTION IzaberFormu () 

_red := win_4_2.combo_form.value 
_key := aForm [ _red ] 

select _fmd_fld
set filter to formname = _key
dbgotop()

Win_4_2.Browse_4_2.Refresh

return 0
*:---------------------------------------------------
function fmd_mov_down()

   if EditRec
      Win_4_2.mFLDROW.Value := Win_4_2.mFLDROW.Value + 10
   endif
   
   SaveRecord_7112()
   LoadData_7112()
   EnableField_7112()
   EditRec := .T.
   
   Win_4_2.mFLDROW.SetFocus
   
return 0
*:---------------------------------------------------
function fmd_mov_up()

   if EditRec
      Win_4_2.mFLDROW.Value := Win_4_2.mFLDROW.Value - 10
   endif
   
   SaveRecord_7112()
   LoadData_7112()
   EnableField_7112()
   EditRec := .T.
   
   Win_4_2.mFLDROW.SetFocus
   
return 0
*:---------------------------------------------------
function fmd_mov_left()

   if EditRec
      Win_4_2.mFLDCOL.Value := Win_4_2.mFLDCOL.Value - 10
   endif
   
   SaveRecord_7112()
   LoadData_7112()
   EnableField_7112()
   EditRec := .T.
   
   Win_4_2.mFLDCOL.SetFocus
   
return 0
*:---------------------------------------------------
function fmd_mov_right()

   if EditRec
      Win_4_2.mFLDCOL.Value := Win_4_2.mFLDCOL.Value + 10
   endif
   
   SaveRecord_7112()
   LoadData_7112()
   EnableField_7112()
   EditRec := .T.
   
   Win_4_2.mFLDCOL.SetFocus
   
return 0
*:------------------------------------------------------------
FUNCTION fmd_preview_7112 ( )

private desk_pozx := getDesktopWidth() - 1020

   if IsWindowActive( FmdPrev )
       DoMethod( 'FmdPrev', "RELEASE" )
   endif
   
   DEFINE WINDOW FmdPrev ;
      AT 20, desk_pozx ;
      WIDTH 1000 ; 
      HEIGHT 800 ;
      TITLE 'Preview Form' ;
      CHILD
      
      ON KEY ESCAPE ACTION FmdPrev.Release

      @ 730, 10 LABEL label1x ;  
         VALUE " LEGEND " TRANSPARENT 
   
      *@ 730, 120 LABEL label2x ; 
      *   VALUE " GRID " TRANSPARENT  
     
      @ 730, 120 LABEL label3x ; 
         VALUE " LABEL " TRANSPARENT 
         
      @ 730, 220 LABEL label4x ; 
         VALUE " FIELD " TRANSPARENT 
   
   END WINDOW      
   
   Win_4_2.prevcmd_1.Visible     := .T.
   Win_4_2.prevcmd_2.Visible     := .T.
   Win_4_2.prevcmd_3.Visible     := .T.
   
   fmdPrev( )
   
   *CENTER WINDOW   FromTest
   ACTIVATE WINDOW FmdPrev
      
Return
*:-----------------------------------------------------------
function fmdPrev ( )

// make line
 
DRAW LINE IN WINDOW FmdPrev AT 710,5 TO 710,795

// show legenda

*DRAW RECTANGLE IN WINDOW FmdPrev AT 730,100 TO 740,110 pencolor { 128,128,255 } FILLCOLOR { 128,128,255 }
DRAW RECTANGLE IN WINDOW FmdPrev AT 730,100 TO 740,110 pencolor { 55,201,48 } FILLCOLOR { 55,201,48 }
DRAW RECTANGLE IN WINDOW FmdPrev AT 730,200 TO 740,210 pencolor { 255,102,10 } FILLCOLOR { 255,102,10 }

// show grid

select _fmd_fld
*set filter to formname = _tab_name
dbgotop()

do while .not. eof()

   _pomak = 0
   if block = 2
      _pomak = 400
   endif

   _row1 = fldrow
   _col1 = fldcol + _pomak
   _row2 = fldrow + 20
   _col2 = fldcol + (fldlen * 10) + _pomak
   _rowl = fldrow 
   _coll = fldcol + _pomak
   _labx = 'label' + alltrim(str(recno()))
   _labxx = 'label' + alltrim(str(recno()+100))
   _labv = fldlabel   
   _labf = fldname
   
   // labels

   if !empty(fldlabel)
      DRAW RECTANGLE IN WINDOW FmdPrev AT _rowl, _coll TO _rowl+15, _coll+50 pencolor { 55,201,48 } FILLCOLOR { 55,201,48 }
      @ _rowl, _coll LABEL &(_labx) VALUE _labv OF FmdPrev transparent           // << tranparent if you want see rectangle
   endif
         
   // fields

if dbfname != '$'
   
   DRAW RECTANGLE IN WINDOW FmdPrev AT _row1, _col1+100 TO _row2, _col2+100 pencolor { 255,102,10 } FILLCOLOR { 255,102,10 }
    @ _row1, _col1+100 LABEL &(_labxx) VALUE _labf OF FmdPrev transparent          // << tranparent if you want see rectangle
   
else
   
   DRAW RECTANGLE IN WINDOW FmdPrev AT _row1, _col1+100 TO _row2, _col2+100 pencolor { 255,155,10 } FILLCOLOR { 255,155,10 }
    @ _row1, _col1+100 LABEL &(_labxx) VALUE _labf OF FmdPrev transparent          // << tranparent if you want see rectangle

endif
  
   dbskip()
enddo

Win_4_2.Browse_4_2.SetFocus

RETURN 0
