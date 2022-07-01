/*
 *
 * Testado.prg
 *
 * Test program sample for ADO Browse.
 * 
 * Copyright 2020 Itamar M. Lins Jr. Junior and Jose Quintas
 *
 */

#include "minigui.ch"
#include "tsbrowse.ch"

Static Font_1, Font_2

Function Main

   DEFINE FONT Font_1 FONTNAME "Arial" SIZE 12
   DEFINE FONT Font_2 FONTNAME "Verdana" SIZE 12

   DEFINE WINDOW MainWindow ;
     AT 200,0 CLIENTAREA 400,150 ;
     TITLE "ADO Example" ;
     MAIN

   END WINDOW

   DEFINE MAIN MENU OF MainWindow
   DEFINE POPUP "&Tests"
      MENUITEM "&Browse ADO" ACTION DlgADO()
      MENUITEM "&Browse DBF" ACTION DlgDBF()
      SEPARATOR
      MENUITEM "&Exit" ACTION MainWindow.Release()
   END POPUP
   END MENU

   CENTER WINDOW MainWindow
   ACTIVATE WINDOW MainWindow

Return Nil


FUNCTION DlgADO()

   LOCAL oBrw, cnSQL

   cnSQL := RecordsetADO()

   SET INTERACTIVECLOSE OFF

   DEFINE WINDOW ModDlg ;
     AT 0,0 CLIENTAREA 730,600 ;
     TITLE "ADO BROWSE";
     MODAL ;
     ON RELEASE iif(hb_IsObject(cnSQL),cnSQL:Close(),)

   @ 20,10 TBROWSE oBrw RECORDSET cnSQL OF ModDlg AUTOCOLS WIDTH 710 HEIGHT 500 FONT "Font_1" ;
           COLUMNS "NAME", "ADRESS" ;
           HEADERS "Name", "Adress" ;
           SIZES 300, 300

   @ 540,540 BUTTONEX BtnEnd CAPTION "Close" ON CLICK {|| ModDlg.Release()} WIDTH 180 HEIGHT 36 FLAT FONT "Font_1"

   oBrw:nHeightCell  := ( oBrw:nHeight / 18 )
   oBrw:nHeightHead  := ( oBrw:nHeight / 18 )
   oBrw:lNoHScroll  := .T.
   oBrw:lNoResetPos := .T.
   oBrw:nLineStyle  := 0

   ON KEY F2 ACTION ;
      Msginfo("Records:  " + hb_ntos(oBrw:nLen) + hb_eol() +;
              "Total:    " + hb_ntos(oBrw:oRSet:RecordCount()) + hb_eol() + ;
              "Recno:    " + hb_ntos(Int(Eval(oBrw:bRecNo))) + hb_eol() + ;
              "AbsPos:   " + hb_ntos(oBrw:oRSet:AbsolutePosition)  )

   END WINDOW

   CENTER WINDOW ModDlg
   ACTIVATE WINDOW ModDlg

   SET INTERACTIVECLOSE ON

Return Nil

// --- Recordset ADO ---

#define AD_VARCHAR     200

FUNCTION RecordsetADO()

   LOCAL nCont, cChar := "A"
   LOCAL cnSQL := CreateObject( "ADODB.Recordset" )

   WITH OBJECT cnSQL
      :Fields:Append( "NAME", AD_VARCHAR, 30 )
      :Fields:Append( "ADRESS", AD_VARCHAR, 30 )
      :Open()
      FOR nCont = 1 TO 10
         :AddNew()
         :Fields( "NAME" ):Value := "ADO_NAME_" + Replicate( cChar, 10 ) + Str( nCont, 6 )
         :Fields( "ADRESS" ):Value := "ADO_ANDRESS_" + Replicate( cChar, 10 ) + Str( nCont, 6 )
         :Update()
         cChar := iif( cChar == "Z", "A", Chr( Asc( cChar ) + 1 ) )
      NEXT
      :MoveFirst()
   ENDWITH

RETURN cnSQL


FUNCTION DlgDBF()

   LOCAL oBrw

   CreateDBF( "test" )
   USE test 

   DEFINE WINDOW ModDlg ;
     AT 0,0 CLIENTAREA 730,600 ;
     TITLE "DBF BROWSE";
     MODAL ;
     ON RELEASE (dbclosearea())

   @ 20,10 TBROWSE oBrw ALIAS "TEST" OF ModDlg WIDTH 710 HEIGHT 500 FONT "Font_2"

   @ 540,540 BUTTONEX BtnEnd CAPTION "Close" ON CLICK {|| ModDlg.Release()} WIDTH 180 HEIGHT 36 FLAT FONT "Font_2"

   ADD COLUMN TO oBrw Header 'Name' ;
       SIZE 300 ;
       DATA FieldWBlock( "NAME", Select() ) ;
       ALIGN DT_LEFT, nMakeLong( DT_CENTER, DT_CENTER )

   ADD COLUMN TO oBrw Header 'Adress' ;
       SIZE 300 ;
       DATA FieldWBlock( "ADRESS", Select() ) ;
       ALIGN DT_LEFT, nMakeLong( DT_CENTER, DT_CENTER )

   oBrw:nHeightCell  := ( oBrw:nHeight / 18 )
   oBrw:nHeightHead  := ( oBrw:nHeight / 18 )
   oBrw:lNoHScroll  := .T.
   oBrw:lNoResetPos := .T.
   oBrw:nLineStyle  := 0

   ON KEY F2 ACTION ;
      Msginfo("Records:  " + hb_ntos(oBrw:nLen) + hb_eol() +;
              "Total:    " + hb_ntos((oBrw:cAlias)->(LastRec())) + hb_eol() + ;
              "Recno:    " + hb_ntos(oBrw:nRowPos) + hb_eol() + ;
              "AbsPos:   " + hb_ntos((oBrw:cAlias)->(RecNo()))  )

   END WINDOW

   CENTER WINDOW ModDlg
   ACTIVATE WINDOW ModDlg

Return Nil

// --- DBF ---

FUNCTION CreateDbf( cName )

   IF hb_vfExists( cName )
      RETURN NIL 
   ENDIF

   dbCreate( cName, { ;
      { "NAME", "C", 30, 0 }, ;
      { "ADRESS", "C", 30, 0 } } )

   USE ( cName )

   APPEND BLANK
   REPLACE test->name WITH "DBF_AAAA", test->adress WITH "DBF_AAAA"
   APPEND BLANK
   REPLACE test->name WITH "DBF_BBBB", test->adress WITH "DBF_BBBB"
   APPEND BLANK
   REPLACE test->name WITH "DBF_CCCC", test->adress WITH "DBF_CCCC"
   USE

RETURN NIL

* ==================== EOF of Testado.prg =======================
