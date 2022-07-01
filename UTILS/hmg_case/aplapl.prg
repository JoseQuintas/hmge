#include <hmg.ch>

PROCEDURE apl_APL

   PUBLIC New := .F. , _qry_exp := ""

   open_mnu()
   Use _apl

   DEFINE WINDOW win_6_1 ;
      AT 10,10 ;
      WIDTH 600 ;
      HEIGHT 400 ;
      TITLE "Aplication" ;
      MODAL

      ON KEY ESCAPE ACTION win_6_1.Release

      PaintDisplay_8534()
      LoadData_8534()
      
      @ 300, 180 BUTTON SAVE_8534 ;
         CAPTION "Save" ;
         PICTURE "ok" RIGHT ;
         ACTION SaveRecord_8534() ;
         WIDTH 100 ;
         HEIGHT 40 

      @ 300, 320 BUTTON CANCEL_8534 ;
         CAPTION "Cancel" ;
         PICTURE "cancel" RIGHT ;
         ACTION CancelEdit_8534() ;
         WIDTH 100 ;
         HEIGHT 40 

   END WINDOW

   EnableField_8534()
  
   ACTIVATE WINDOW win_6_1

RETURN
*:---------------------------------------------*
PROCEDURE DisableField_8534

   win_6_1.mNAME.Enabled         := .F.
   win_6_1.mTITLE.Enabled        := .F.
   win_6_1.mWIDTH.Enabled        := .F.
   win_6_1.mHEIGHT.Enabled       := .F.
   win_6_1.mMNUCOL.Enabled       := .F.
   win_6_1.mMNUROW.Enabled       := .F.

   win_6_1.Save_8534.Enabled     := .F.
   win_6_1.Cancel_8534.Enabled   := .F.
  
RETURN
*:---------------------------------------------*
PROCEDURE EnableField_8534

   win_6_1.mNAME.Enabled         := .T.
   win_6_1.mTITLE.Enabled        := .T.
   win_6_1.mWIDTH.Enabled        := .T.
   win_6_1.mHEIGHT.Enabled       := .T.
   win_6_1.mMNUCOL.Enabled       := .T.
   win_6_1.mMNUROW.Enabled       := .T.

   win_6_1.Save_8534.Enabled     := .T.
   win_6_1.Cancel_8534.Enabled   := .T.
   win_6_1.mNAME.SetFocus

RETURN
*:---------------------------------------------*
FUNCTION RecordStatus_8534()

   Local RetVal

   _APL->( dbGoTo (1) )

   IF _APL->(RLock())
      RetVal := .T.
   ELSE
      MsgExclamation ("Record LOCKED, try again later")
      RetVal := .F.
   ENDIF

RETURN RetVal
*:---------------------------------------------*
PROCEDURE LoadData_8534

   _APL->( dbGoTo (1) )

   win_6_1.mNAME.Value         := _APL->NAME      
   win_6_1.mTITLE.Value        := _APL->TITLE     
   win_6_1.mWIDTH.Value        := _APL->WIDTH     
   win_6_1.mHEIGHT.Value       := _APL->HEIGHT    
   win_6_1.mMNUCOL.Value       := _APL->MNUCOL    
   win_6_1.mMNUROW.Value       := _APL->MNUROW    

RETURN
*:---------------------------------------------*
PROCEDURE CancelEdit_8534

   DisableField_8534()
   LoadData_8534()
   UNLOCK
   New := .F.
   win_6_1.Release

RETURN
*:---------------------------------------------*
PROCEDURE SaveRecord_8534

   Local NewRecNo

   DisableField_8534()

   IF New == .T.
      _APL->(dbAppend())
      New := .F.
   ELSE
      _APL->(dbGoto (1) )
   ENDIF

   NewRecNo := _APL->( RecNo() )

   _APL->NAME       := win_6_1.mNAME.Value
   _APL->TITLE      := win_6_1.mTITLE.Value
   _APL->WIDTH      := win_6_1.mWIDTH.Value
   _APL->HEIGHT     := win_6_1.mHEIGHT.Value
   _APL->MNUCOL     := win_6_1.mMNUCOL.Value
   _APL->MNUROW     := win_6_1.mMNUROW.Value
  
   UNLOCK
   dbCommitall()

   dbcloseall()
   win_6_1.Release
   
RETURN
*:---------------------------------------------*
PROCEDURE PaintDisplay_8534

   @  80,  50 FRAME Frame_2 WIDTH 500 HEIGHT 210

   @ 100, 120 LABEL Label_1 VALUE "Aplication"
   @ 130, 120 LABEL Label_2 VALUE "Title"
   @ 160, 120 LABEL Label_3 VALUE "Width"
   @ 190, 120 LABEL Label_4 VALUE "Height"
   @ 220, 120 LABEL Label_5 VALUE "Menu Column"
   @ 250, 120 LABEL Label_6 VALUE "Menu Row"

   @ 100, 200 TEXTBOX  mNAME        WIDTH 210 INPUTMASK replicate("A",20)
   @ 130, 200 TEXTBOX  mTITLE       WIDTH 310 INPUTMASK replicate("A",40)
   @ 160, 200 TEXTBOX  mWIDTH       WIDTH 50 NUMERIC INPUTMASK "9999"
   @ 190, 200 TEXTBOX  mHEIGHT      WIDTH 50 NUMERIC INPUTMASK "9999"
   @ 220, 200 TEXTBOX  mMNUCOL      WIDTH 30 NUMERIC INPUTMASK "99"
   @ 250, 200 TEXTBOX  mMNUROW      WIDTH 30 NUMERIC INPUTMASK "99"

RETURN
* end of program *