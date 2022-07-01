/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * dbview.prg - dbf browsing sample
 *
 * HWGUI - Harbour Win32 and Linux (GTK) GUI library
 * Copyright 2005-2022 Alexander S.Kresin <alex@kresin.ru>
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov - 2014-2022
 */

#include <minigui.ch>
#include "error.ch"
#include "miniprint.ch"
#include "i_rptgen.ch"

REQUEST HB_CODEPAGE_RU866
REQUEST HB_CODEPAGE_RUKOI8

#ifdef __XHARBOUR__
   REQUEST HB_CODEPAGE_RUWIN
#else
   REQUEST HB_CODEPAGE_RU1251
#endif

REQUEST DBFCDX

STATIC aFieldTypes := { "C", "N", "D", "L", "M" }
STATIC dbv_cLocate, dbv_nRec, dbv_cSeek

MEMVAR DataCP, currentCP, currFname

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FUNCTION MAIN

   PRIVATE DataCP, currentCP, currFname

   rddSetDefault( "DBFCDX" )

   SET CENTURY ON
   SET DATE GERMAN

   SET FONT TO "Courier New", 10
   SET DEFAULT ICON TO "demo.ico"

   SET NAVIGATION EXTENDED

   DEFINE WINDOW WndMain ;
         AT 0, 0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE "DBF Browse" ;
         MAIN ;
         ON INIT ( BuildMenu(), ResizeEdit() ) ;
         ON SIZE ResizeEdit() ;
         ON MAXIMIZE ResizeEdit()

      @ 0, 0 EDITBOX Edit_1 ;
         WIDTH 0 ;
         HEIGHT 0 ;
         VALUE '' ;
         BACKCOLOR WHITE

      DEFINE STATUSBAR FONT 'Verdana' SIZE 9
         STATUSITEM "" WIDTH 200
         STATUSITEM "" WIDTH 90
         DATE WIDTH 90
         CLOCK WIDTH 80
      END STATUSBAR

      ON KEY ALT + O ACTION FileOpen()
      ON KEY ALT + A ACTION dbv_AppRec()
      ON KEY F7 ACTION dbv_Continue()
      ON KEY F8 ACTION dbv_DelRec()
      ON KEY ALT + X ACTION WndMain.Release()

   END WINDOW

   CENTER WINDOW WndMain
   ACTIVATE WINDOW WndMain

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC PROCEDURE BuildMenu()

   DEFINE MAIN MENU OF WndMain
      POPUP "&File"
         MENUITEM "&New" ACTION ModiStru( .T. )
         MENUITEM "&Open" + Chr( 9 ) + "Alt+O" ACTION FileOpen()
         SEPARATOR
         MENUITEM "E&xit" ACTION WndMain.Release()
      END POPUP
      POPUP "&Index"
         MENUITEM "&Select order" ACTION SelectIndex() DISABLED
         MENUITEM "&New order" ACTION NewIndex() DISABLED
         MENUITEM "&Open index file" ACTION OpenIndex() DISABLED
         SEPARATOR
         MENUITEM "&Reindex all" ACTION ReIndex() DISABLED
         SEPARATOR
         MENUITEM "&Close all indexes" ACTION CloseIndex() DISABLED
      END POPUP
      POPUP "&Structure"
         MENUITEM "&Modify structure" ACTION ModiStru( .F. ) DISABLED
      END POPUP
      POPUP "&Move"
         MENUITEM "&Go To" ACTION dbv_Goto() DISABLED
         MENUITEM "&Seek" ACTION dbv_Seek() DISABLED
         MENUITEM "&Locate" ACTION dbv_Locate() DISABLED
         MENUITEM "&Continue" + Chr( 9 ) + "F7" ACTION dbv_Continue() DISABLED
      END POPUP
      POPUP "&Command"
         MENUITEM "&Append record" + Chr( 9 ) + "Alt+A" ACTION dbv_AppRec() DISABLED
         MENUITEM "&Delete record" + Chr( 9 ) + "F8" ACTION dbv_DelRec() DISABLED
         MENUITEM "&Pack" ACTION dbv_Pack() DISABLED
         MENUITEM "&Zap" ACTION dbv_Zap() DISABLED
      END POPUP
      POPUP "&View"
         MENUITEM "&Font" ACTION ChangeFont()
         POPUP "&Local codepage"
            MENUITEM "EN" ACTION ( hb_cdpSelect( "EN" ), LocalCheck( 1 ) ) NAME SetLocal_1 CHECKED
            MENUITEM "RUKOI8" ACTION ( hb_cdpSelect( "RUKOI8" ), LocalCheck( 2 ) ) NAME SetLocal_2
            MENUITEM "RU1251" ACTION ( hb_cdpSelect( "RU1251" ), LocalCheck( 3 ) ) NAME SetLocal_3
         END POPUP
         POPUP "&Data's codepage"
            MENUITEM "EN" ACTION SetDataCP( "EN" ) NAME SetData_1 CHECKED
            MENUITEM "RUKOI8" ACTION SetDataCP( "RUKOI8" ) NAME SetData_2
            MENUITEM "RU1251" ACTION SetDataCP( "RU1251" ) NAME SetData_3
            MENUITEM "RU866" ACTION SetDataCP( "RU866" ) NAME SetData_4
         END POPUP
      END POPUP
      POPUP "&Help"
         MENUITEM "&About" ACTION Msginfo( "Dbf Files Browser" + Chr( 10 ) + "2005-2014" )
      END POPUP
   END MENU

RETURN

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC PROCEDURE ResizeEdit

   WndMain.Edit_1.WIDTH := WndMain.WIDTH - 2 * GetBorderWidth()
   WndMain.Edit_1.HEIGHT := WndMain.HEIGHT - ( GetTitleHeight() + 2 * GetBorderHeight() + GetMenuBarHeight() + GetStatusBarHeight() )

RETURN

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION FileOpen( fname )

   LOCAL mypath := "\" + CurDir() + iif( Empty( CurDir() ), "", "\" )

   IF Empty( fname )
      fname := Getfile( { { "xBase files (*.dbf)", "*.dbf" } }, "Open a Dbf", mypath )
   ENDIF

   IF ! Empty( fname )
      CLOSE ALL

      IF DataCP != NIL
         USE ( fname ) NEW CodePage ( DataCP )
         currentCP := DataCP
      ELSE
         USE ( fname ) NEW
      ENDIF
      currFname := Left( fname, RAt( ".", fname ) - 1 )

      SetBrowse( Alias() )

      WndMain.StatusBar.Item( 1 ) := "Records: " + LTrim( Str( LastRec() ) )
      WndMain.StatusBar.Item( 2 ) := ""

      dbv_cLocate := dbv_cSeek := ""
      dbv_nRec := 0

      EnableMainMenu( "WndMain" )
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FUNCTION EnableMainMenu( cFormName )

   LOCAL nFormHandle, i, nControlCount

   nFormHandle := GetFormHandle( cFormName )
   nControlCount := Len( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount

      IF _HMG_aControlParentHandles[ i ] == nFormHandle
         IF ValType( _HMG_aControlHandles[ i ] ) == 'N'
            IF _HMG_aControlType[ i ] == 'MENU' .AND. _HMG_aControlEnabled[ i ] == .F.
               _EnableMenuItem( _HMG_aControlNames[ i ], cFormName )
            ENDIF
         ENDIF
      ENDIF

   NEXT i

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC PROCEDURE LocalCheck( nCheck )

   WndMain.SetLocal_1.Checked := ( nCheck == 1 )
   WndMain.SetLocal_2.Checked := ( nCheck == 2 )
   WndMain.SetLocal_3.Checked := ( nCheck == 3 )

RETURN

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC PROCEDURE SetBrowse( cAlias )

   LOCAL i, SIZE, size1
   LOCAL astruct
   LOCAL anames := { "iif(deleted(), '*', ' ')" }
   LOCAL aheaders := { "*" }
   LOCAL asizes := { 18 + iif( IsXPThemeActive(), 4, 0 ) }
   LOCAL ajustify := { 0 }, areadonly := { .T. }

   astruct := ( cAlias )->( dbStruct( cAlias ) )

   FOR i := 1 TO Len( astruct )
      AAdd( anames, astruct[ i, 1 ] )
      AAdd( aheaders, astruct[ i, 1 ] )
      SIZE := Len( Trim( astruct[ i, 1 ] ) ) * 15
      size1 := astruct[ i, 3 ] * iif( astruct[ i, 2 ] == 'L', 50, iif( astruct[ i, 2 ] == 'D', 15, 10 ) )
      AAdd( asizes, Max( size1, size ) )
      AAdd( ajustify, LtoN( astruct[ i, 2 ] == 'N' ) )
      AAdd( areadonly, .F. )
   NEXT

   IF IsControlDefined( Edit_1, WndMain ) == .T.
      WndMain.Edit_1.Release()
   ENDIF

   DEFINE BROWSE Edit_1
      ROW 0
      COL 0
      WIDTH WndMain.WIDTH - 2 * GetBorderWidth()
      HEIGHT WndMain.HEIGHT - ( GetTitleHeight() + 2 * GetBorderHeight() + GetMenuBarHeight() + GetStatusBarHeight( 'WndMain' ) )
      PARENT WndMain
      HEADERS aheaders
      WIDTHS asizes
      FIELDS anames
      JUSTIFY ajustify
      WORKAREA &cAlias
      VALUE ( cAlias )->( RecNo() )
      VSCROLLBAR ( cAlias )->( LastRec() ) > 0
      ALLOWEDIT .T.
      INPLACEEDIT .T.
      READONLYFIELDS areadonly
      FONTNAME _HMG_DefaultFontName
      FONTSIZE _HMG_DefaultFontSize
   END BROWSE

   WndMain.Edit_1.SetFocus()

RETURN

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION ChangeFont()

   LOCAL aNewFont := GetFont( _HMG_DefaultFontName, _HMG_DefaultFontSize )

   IF ! Empty( aNewFont[ 1 ] )
      _HMG_DefaultFontName := aNewFont[ 1 ]
      _HMG_DefaultFontSize := aNewFont[ 2 ]
      IF ! Empty( Alias() )
         dbGoto( WndMain.Edit_1.Value )
         SetBrowse( Alias() )
      ENDIF
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION SetDataCP( cp )

   DataCP := cp

   WndMain.SetData_1.Checked := ( DataCP == "EN" )
   WndMain.SetData_2.Checked := ( DataCP == "RUKOI8" )
   WndMain.SetData_3.Checked := ( DataCP == "RU1251" )
   WndMain.SetData_4.Checked := ( DataCP == "RU866" )

   IF ! Empty( Alias() )
      FileOpen( currFname + ".dbf" )
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION SelectIndex()

   LOCAL aIndex := { { "None", "   ", "   " } }, i, indname, iLen := 0
   LOCAL WIDTH, HEIGHT, nChoice := 0, nOrder := ordNumber() + 1

   IF Empty( Alias() )
      RETURN NIL
   ENDIF

   i := 1
   DO WHILE ! Empty( indname := ordName( i ) )
      AAdd( aIndex, { indname, ordKey( i ), ordBagName( i ) } )
      iLen := Max( iLen, Len( ordKey( i ) ) )
      i++
   ENDDO

   WIDTH := 14 * ( iLen + 20 )
   HEIGHT := 20 * ( Len( aIndex ) + 2 ) + GetBorderHeight()

   DEFINE WINDOW SelectIndex ;
         AT 0, 0 ;
         WIDTH WIDTH + GetBorderWidth() HEIGHT HEIGHT + GetBorderHeight() ;
         TITLE "Select Order" ;
         MODAL ;
         NOSIZE

      @ 0, 0 GRID Grid_1 ;
         WIDTH WIDTH ;
         HEIGHT HEIGHT ;
         HEADERS { "OrdName", "Order key", "Filename" } ;
         WIDTHS { 100, Max( iLen * 10, WIDTH - 210 ), 100 } ;
         ITEMS aIndex ;
         VALUE nOrder ;
         ON DBLCLICK ( nChoice := SelectIndex.Grid_1.VALUE, SelectIndex.Release() )

      ON KEY ESCAPE ACTION SelectIndex.Release()

   END WINDOW
   CENTER WINDOW SelectIndex
   ACTIVATE WINDOW SelectIndex

   IF nChoice > 0
      nChoice--
      SET ORDER TO nChoice
      UpdBrowse()
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION NewIndex()

   LOCAL cName := "", lMulti := .T., lUniq := .F., cTag := "", cExpr := "", cCond := ""
   LOCAL lResult := .F.

   IF Empty( Alias() )
      RETURN NIL
   ENDIF

   DEFINE WINDOW NewIndex ;
         AT 0, 0 ;
         WIDTH 310 HEIGHT 270 ;
         TITLE "Create Order" ;
         MODAL ;
         NOSIZE

      DEFINE LABEL Label_1
         ROW 10
         COL 10
         WIDTH 100
         HEIGHT 22
         VALUE "Order name:"
         VCENTERALIGN .T.
      END LABEL

      DEFINE TEXTBOX Text_1
         ROW 10
         COL 110
         WIDTH 100
         HEIGHT 22
         VALUE cName
         ON LOSTFOCUS cName := NewIndex.Text_1.VALUE
      END TEXTBOX

      DEFINE CHECKBOX Check_1
         ROW 40
         COL 10
         WIDTH 100
         HEIGHT 22
         CAPTION "Multibag"
         VALUE lMulti
         ON LOSTFOCUS lMulti := NewIndex.Check_1.VALUE
      END CHECKBOX

      DEFINE TEXTBOX Text_2
         ROW 40
         COL 110
         WIDTH 100
         HEIGHT 22
         VALUE cTag
         ON LOSTFOCUS cTag := NewIndex.Text_2.VALUE
      END TEXTBOX

      DEFINE CHECKBOX Check_2
         ROW 65
         COL 10
         WIDTH 100
         HEIGHT 22
         CAPTION "Unique"
         VALUE lUniq
         ON LOSTFOCUS lUniq := NewIndex.Check_2.VALUE
      END CHECKBOX

      DEFINE LABEL Label_2
         ROW 85
         COL 10
         WIDTH 100
         HEIGHT 22
         VALUE "Expression:"
         VCENTERALIGN .T.
      END LABEL

      DEFINE TEXTBOX Text_3
         ROW 107
         COL 10
         WIDTH 280
         HEIGHT 22
         VALUE cExpr
         ON LOSTFOCUS cExpr := NewIndex.Text_3.VALUE
      END TEXTBOX

      DEFINE LABEL Label_3
         ROW 135
         COL 10
         WIDTH 100
         HEIGHT 22
         VALUE "Condition:"
         VCENTERALIGN .T.
      END LABEL

      DEFINE TEXTBOX Text_4
         ROW 157
         COL 10
         WIDTH 280
         HEIGHT 22
         VALUE cCond
         ON LOSTFOCUS cCond := NewIndex.Text_4.VALUE
      END TEXTBOX

      @ 195, 40 BUTTON _Ok CAPTION "Ok" WIDTH 100 HEIGHT 28 ON CLICK {|| lResult := .T., NewIndex.Release() }
      @ 195, 160 BUTTON _Cancel CAPTION "Cancel" WIDTH 100 HEIGHT 28 ON CLICK {|| NewIndex.Release() }

      ON KEY ESCAPE ACTION NewIndex._Cancel.OnClick()

   END WINDOW
   CENTER WINDOW NewIndex
   ACTIVATE WINDOW NewIndex

   IF lResult
      IF ! Empty( cName ) .AND. ( ! Empty( cTag ) .OR. ! lMulti ) .AND. ! Empty( cExpr )
         DlgWait( "Indexing" )
         IF lMulti
            IF Empty( cCond )
               ordCreate( cName, cTag, cExpr, &( "{||" + cExpr + "}" ), iif( lUniq, .T., Nil ) )
            ELSE
               ordCondSet( cCond, &( "{||" + cCond + "}" ),,,,, RecNo(),,,, )
               ordCreate( cName, cTag, cExpr, &( "{||" + cExpr + "}" ), iif( lUniq, .T., Nil ) )
            ENDIF
         ELSE
            IF Empty( cCond )
               dbCreateIndex( cName, cExpr, &( "{||" + cExpr + "}" ), iif( lUniq, .T., Nil ) )
            ELSE
               ordCondSet( cCond, &( "{||" + cCond + "}" ),,,,, RecNo(),,,, )
               ordCreate( cName, cTag, cExpr, &( "{||" + cExpr + "}" ), iif( lUniq, .T., Nil ) )
            ENDIF
         ENDIF
         DlgWait()
         WndMain.Edit_1.Refresh()
      ELSE
         Msgstop( "Fill necessary fields" )
      ENDIF
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION OpenIndex()

   LOCAL mypath := "\" + CurDir() + iif( Empty( CurDir() ), "", "\" )
   LOCAL fname := Getfile( { { "index files (*.cdx)", "*.cdx" } }, "Open an index", mypath )

   IF Empty( Alias() )
      RETURN NIL
   ENDIF

   IF ! Empty( fname )
      SET INDEX To ( fname )
      UpdBrowse()
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION ReIndex()

   IF Empty( Alias() )
      RETURN NIL
   ENDIF

   DlgWait( "Reindexing" )
   REINDEX
   DlgWait()
   WndMain.Edit_1.Refresh()

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION CloseIndex()

   IF Empty( Alias() )
      RETURN NIL
   ENDIF

   ordListClear()
   SET ORDER TO 0
   UpdBrowse()

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION UpdBrowse()

   WndMain.Edit_1.Refresh()
   WndMain.StatusBar.Item( 1 ) := "Records: " + LTrim( Str( LastRec() ) )
   WndMain.StatusBar.Item( 2 ) := ""

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION DlgWait( cTitle )

   IF ! IsWindowDefined( WaitWin )
      DEFINE WINDOW WaitWin ;
            AT 0, 0 ;
            WIDTH 220 HEIGHT 80 ;
            TITLE cTitle ;
            TOPMOST ;
            NOMAXIMIZE NOMINIMIZE NOSIZE NOSYSMENU ;
            BACKCOLOR { 0, 74, 168 }

         DEFINE LABEL WaitLabel
            ROW 10
            COL 10
            WIDTH 200
            HEIGHT 30
            VALUE "Wait, please ..."
            FONTNAME "Lucida Console"
            FONTSIZE 14
            CENTERALIGN .T.
            VCENTERALIGN .T.
            TRANSPARENT .T.
            FONTCOLOR { 255, 255, 0 }
         END LABEL

      END WINDOW
      CENTER WINDOW WaitWin
      ACTIVATE WINDOW WaitWin NOWAIT
   ENDIF

   IF ! Empty( cTitle )
      WaitWin.TITLE := cTitle
      SHOW WINDOW WaitWin
      DO EVENTS
   ELSE
      WaitWin.Hide
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION ModiStru( lNew )

   LOCAL af0 := {}, cName := "", nType := 1, cLen := "10", cDec := "0"
   LOCAL aTypes := { "Character", "Numeric", "Date", "Logical", "Memo" }
   LOCAL fname, cAlias, nRec, nOrd, lOverFlow := .F., xValue
   LOCAL lResult := .F., i, STRU
   MEMVAR af
   PRIVATE af

   IF lNew
      af0 := { { "", "", 10, 0 } }
      af := af0
   ELSE
      FOR EACH STRU IN dbStruct()
         AAdd( af0, { STRU[ 1 ], STRU[ 2 ], STRU[ 3 ], STRU[ 4 ] } )
      NEXT
      cName := af0[ 1, 1 ]
      nType := AScan( aFieldTypes, af0[ 1, 2 ] )
      cLen := hb_ntos( af0[ 1, 3 ] )
      cDec := hb_ntos( af0[ 1, 4 ] )
      af := dbStruct()
      FOR i := 1 TO Len( af )

#ifdef __XHARBOUR__
         af[ i, 5 ] := i

#else
         AAdd( af[ i ], i )

#endif
      NEXT
   ENDIF

   DEFINE WINDOW ModiStru ;
         AT 0, 0 ;
         WIDTH 400 + GetBorderWidth() ;
         HEIGHT 340 + GetBorderHeight() ;
         TITLE "Modify structure" ;
         MODAL ;
         NOSIZE

      @ 10, 10 GRID Grid_1 ;
         WIDTH 250 ;
         HEIGHT 200 ;
         HEADERS { "Name", "Type", "Length", "Dec" } ;
         WIDTHS { 88, 46, 60, 36 } ;
         ITEMS af0 ;
         VALUE 1 ;
         COLUMNCONTROLS {, , { 'TEXTBOX', 'NUMERIC', '9999' }, { 'TEXTBOX', 'NUMERIC', '999' } } ;
         ON CHANGE grd_onPosChg( ModiStru.Grid_1.Value )

      DEFINE TEXTBOX Text_1
         ROW 230
         COL 10
         WIDTH 100
         HEIGHT 22
         VALUE cName
      END TEXTBOX

      DEFINE COMBOBOX Combo_2
         ROW 230
         COL 120
         WIDTH 100
         HEIGHT 120
         ITEMS aTypes
         VALUE nType
      END COMBOBOX

      DEFINE TEXTBOX Text_3
         ROW 230
         COL 230
         WIDTH 50
         HEIGHT 22
         VALUE cLen
      END TEXTBOX

      DEFINE TEXTBOX Text_4
         ROW 230
         COL 290
         WIDTH 40
         HEIGHT 22
         VALUE cDec
      END TEXTBOX

      @ 270, 20 BUTTON _Add CAPTION "Add" WIDTH 80 HEIGHT 28 ON CLICK {|| UpdStru( 1 ) }
      @ 270, 110 BUTTON _Insert CAPTION "Insert" WIDTH 80 HEIGHT 28 ON CLICK {|| UpdStru( 2 ) }
      @ 270, 200 BUTTON _Change CAPTION "Change" WIDTH 80 HEIGHT 28 ON CLICK {|| UpdStru( 3 ) }
      @ 270, 290 BUTTON _Remove CAPTION "Remove" WIDTH 80 HEIGHT 28 ON CLICK {|| UpdStru( 4 ) }

      @ 10, 280 BUTTON _Ok CAPTION "Ok" WIDTH 100 HEIGHT 28 ON CLICK {|| lResult := .T., ModiStru.Release() }
      @ 50, 280 BUTTON _Cancel CAPTION "Cancel" WIDTH 100 HEIGHT 28 ON CLICK {|| ModiStru.Release() }
      @ 90, 280 BUTTON _Print CAPTION "Print" WIDTH 100 HEIGHT 28 ON CLICK {|| PrintStru() }
      @ 130, 280 BUTTON _SaveAs CAPTION "Save As PDF" WIDTH 100 HEIGHT 28 ON CLICK {|| SaveStru() }

      ON KEY ESCAPE ACTION ModiStru._Cancel.OnClick()

   END WINDOW
   CENTER WINDOW ModiStru
   ACTIVATE WINDOW ModiStru

   IF lResult

      DlgWait( "Restructuring" )
      IF lNew
         CLOSE ALL
         DlgWait()
         fname := InputBox( "Input new file name", "File creation" )
         IF Empty( fname )
            RETURN NIL
         ENDIF
         DlgWait( "Restructuring" )
         dbCreate( fname, af )
         FileOpen( fname )
      ELSE
         cAlias := Alias()
         nOrd := ordNumber()
         nRec := RecNo()
         SET ORDER TO 0
         GO TOP

         fname := "a0_new"
         dbCreate( fname, af )
         IF currentCP != NIL
            USE ( fname ) NEW codepage ( currentCP )
         ELSE
            USE ( fname ) NEW
         ENDIF
         dbSelectArea( cAlias )

         DO WHILE ! Eof()
            dbSelectArea( fname )
            APPEND BLANK
            FOR i := 1 TO Len( af )
               IF Len( af[ i ] ) > 4
                  xValue := ( cAlias )->( FieldGet( af[ i, 5 ] ) )
                  IF af[ i, 2 ] == af0[ af[ i, 5 ], 2 ] .AND. af[ i, 3 ] == af0[ af[ i, 5 ], 3 ]
                     FieldPut( i, xValue )
                  ELSE
                     IF af[ i, 2 ] != af0[ af[ i, 5 ], 2 ]
                        IF af[ i, 2 ] == "C" .AND. af0[ af[ i, 5 ], 2 ] == "N"
                           xValue := Str( xValue, af0[ af[ i, 5 ], 3 ], af0[ af[ i, 5 ], 4 ] )
                        ELSEIF af[ i, 2 ] == "N" .AND. af0[ af[ i, 5 ], 2 ] == "C"
                           xValue := Val( LTrim( xValue ) )
                        ELSE
                           LOOP
                        ENDIF
                     ENDIF
                     IF af[ i, 3 ] >= af0[ af[ i, 5 ], 3 ]
                        FieldPut( i, xValue )
                     ELSE
                        IF af[ i, 2 ] == "C"
                           FieldPut( i, Left( xValue, af[ i, 3 ] ) )
                        ELSEIF af[ i, 2 ] == "N"
                           FieldPut( i, 0 )
                           lOverFlow := .T.
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF
            NEXT
            IF ( cAlias )->( Deleted() )
               DELETE
            ENDIF
            dbSelectArea( cAlias )
            SKIP
         ENDDO
         IF lOverFlow
            Msgalert( "There was overflow in Numeric field", "Warning!" )
         ENDIF

         CLOSE ALL
         FErase( currFname + ".bak" )
         FRename( currFname + ".dbf", currFname + ".bak" )
         FRename( "a0_new.dbf", currFname + ".dbf" )
         IF File( "a0_new.fpt" )
            FErase( currFname + ".bk2" )
            FRename( currFname + ".fpt", currFname + ".bk2" )
            FRename( "a0_new.fpt", currFname + ".fpt" )
         ENDIF

         IF currentCP != NIL
            USE ( currFname ) NEW codepage ( currentCP )
         ELSE
            USE ( currFname ) NEW
         ENDIF
         IF nOrd > 0
            SET ORDER TO nOrd
            REINDEX
         ENDIF

         GO nRec
      ENDIF
      DlgWait()
      SetBrowse( Alias() )

   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION grd_onPosChg( nItem )

   LOCAL aArray := ModiStru.Grid_1.Item( nItem )

   ModiStru.Text_1.VALUE := aArray[ 1 ]
   ModiStru.Combo_2.VALUE := AScan( aFieldTypes, aArray[ 2 ] )
   ModiStru.Text_3.VALUE := hb_ntos( aArray[ 3 ] )
   ModiStru.Text_4.VALUE := hb_ntos( aArray[ 4 ] )

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION UpdStru( nOperation )

   LOCAL cName, cType, nLen, nDec, i
   LOCAL nCurrent := ModiStru.Grid_1.VALUE
   MEMVAR af

   IF nOperation == 4
      ADel( af, nCurrent )
      ASize( af, Len( af ) - 1 )
      ModiStru.Grid_1.DeleteItem( nCurrent )
      IF nCurrent <= Len( af ) .AND. nCurrent > 1
         ModiStru.Grid_1.VALUE := nCurrent - 1
      ELSE
         ModiStru.Grid_1.VALUE := ( ModiStru.Grid_1.ItemCount )
      ENDIF
   ELSE
      cName := ModiStru.Text_1.VALUE
      cType := aFieldTypes[ ModiStru.Combo_2.Value ]
      nLen := Val( ModiStru.Text_3.Value )
      nDec := Val( ModiStru.Text_4.Value )
      IF nOperation == 1
         AAdd( af, { cName, cType, nLen, nDec } )
         ModiStru.Grid_1.AddItem( { cName, cType, nLen, nDec } )
         ModiStru.Grid_1.VALUE := ( ModiStru.Grid_1.ItemCount )
      ELSE
         IF nOperation == 2
            IF nCurrent == 0
               nCurrent := 1
            ENDIF
            AAdd( af, Nil )
            AIns( af, nCurrent )
            af[ nCurrent ] := Array( 4 )
         ENDIF
         IF nCurrent > 0
            af[ nCurrent, 1 ] := cName
            af[ nCurrent, 2 ] := cType
            af[ nCurrent, 3 ] := nLen
            af[ nCurrent, 4 ] := nDec
         ENDIF
         ModiStru.Grid_1.DisableUpdate
         ModiStru.Grid_1.DeleteAllItems()
         FOR i := 1 TO Len( af )
            ModiStru.Grid_1.AddItem( { af[ i, 1 ], af[ i, 2 ], af[ i, 3 ], af[ i, 4 ] } )
         NEXT
         ModiStru.Grid_1.VALUE := nCurrent
         ModiStru.Grid_1.EnableUpdate
      ENDIF
   ENDIF
   ModiStru.Grid_1.Refresh()
   ModiStru.Grid_1.SetFocus()

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION PrintStru()

   MEMVAR aStruct, i, af
   PUBLIC aStruct := af, i := 1

   LOAD REPORT Demo
   EXECUTE REPORT Demo PREVIEW SELECTPRINTER

   RELEASE aStruct, i

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION SaveStru()

   MEMVAR aStruct, i, af
   PUBLIC aStruct := af, i := 1

   LOAD REPORT Demo
   EXECUTE REPORT Demo ;
      FILE PutFile( { { 'PDF files', '*.pdf' } }, 'Save As...', GetStartUpFolder(), .F., "struct.pdf" )

   RELEASE aStruct, i

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_Goto()

   LOCAL nRec := Val( GetData( LTrim( Str(dbv_nRec ) ), "Go to ...", "Input record number:" ) )

   IF nRec != 0
      dbv_nRec := nRec
      dbGoto( nRec )
      IF Eof()
         dbGoBottom()
      ENDIF
      IF IndexOrd() == 0 .AND. nRec == LastRec()
         _BrowseEnd( 'Edit_1', 'WndMain' )
      ENDIF
      WndMain.Edit_1.VALUE := RecNo()
      WndMain.Edit_1.Refresh()
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_Seek()

   LOCAL cKey, nRec, xType

   IF ordNumber() == 0
      Msgstop( "No active order!", "Seek record" )
   ELSE
      cKey := GetData( dbv_cSeek, "Seek record", "Input key:" )
      IF ! Empty( cKey )
         dbv_cSeek := cKey
         xType := &( ordKey( ordNumber() ) )
         IF ValType( xType ) == 'N'
            cKey := Val( cKey )
         ELSEIF ValType( xType ) == 'D'
            cKey := CToD( cKey )
         ENDIF
         dbGoto( WndMain.Edit_1.Value )
         nRec := RecNo()
         IF dbSeek( cKey )
            WndMain.StatusBar.Item( 2 ) := "Found"
            WndMain.Edit_1.VALUE := RecNo()
            WndMain.Edit_1.Refresh()
         ELSE
            WndMain.StatusBar.Item( 2 ) := "Not Found"
            dbGoto( nRec )
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_Locate()

   LOCAL cLocate := dbv_cLocate
   LOCAL bOldError, cType, nRec

   DO WHILE .T.

      cLocate := GetData( cLocate, "Locate", "Input condition:" )
      IF Empty( cLocate )
         RETURN NIL
      ENDIF

      bOldError := ErrorBlock( {| e | MacroError( e ) } )
      BEGIN SEQUENCE
         cType := ValType( &cLocate )
      RECOVER
         ErrorBlock( bOldError )
         LOOP
      END SEQUENCE
      ErrorBlock( bOldError )

      IF cType != "L"
         Msgstop( "Wrong expression" )
      ELSE
         EXIT
      ENDIF
   ENDDO

   dbv_cLocate := cLocate
   dbGoto( WndMain.Edit_1.Value )
   nRec := RecNo()
   LOCATE FOR &cLocate
   IF Found()
      WndMain.StatusBar.Item( 2 ) := "Found"
      WndMain.Edit_1.VALUE := RecNo()
      WndMain.Edit_1.Refresh()
   ELSE
      WndMain.StatusBar.Item( 2 ) := "Not Found"
      dbGoto( nRec )
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_Continue()

   LOCAL nRec

   IF ! Empty( dbv_cLocate )
      dbGoto( WndMain.Edit_1.Value )
      nRec := RecNo()
      CONTINUE
      IF Found()
         WndMain.StatusBar.Item( 2 ) := "Found"
         WndMain.Edit_1.VALUE := RecNo()
         WndMain.Edit_1.Refresh()
      ELSE
         WndMain.StatusBar.Item( 2 ) := "Not Found"
         dbGoto( nRec )
      ENDIF
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION GetData( cRes, cTitle, cText )

   cRes := InputBox( cText, cTitle, cRes )

RETURN iif( _HMG_DialogCancelled, "", cRes )

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION MacroError( e )

   IF HB_ISOBJECT( e )
      Msgstop( ErrMessage( e ), "Expression error" )
      BREAK
   ENDIF

RETURN .T.

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION ErrMessage( oError )
   // start error message
   LOCAL cMessage := iif( oError:severity > ES_WARNING, "Error", "Warning" ) + " "

   // add subsystem name if available
   IF ISCHARACTER( oError:subsystem )
      cMessage += oError:subsystem()
   ELSE
      cMessage += "???"
   ENDIF

   // add subsystem's error code if available
   IF ISNUMBER( oError:subCode )
      cMessage += "/" + hb_ntos( oError:subCode )
   ELSE
      cMessage += "/???"
   ENDIF

   // add error description if available
   IF ISCHARACTER( oError:description )
      cMessage += "  " + oError:description
   ENDIF

   // add either filename or operation
   DO CASE
   CASE ! Empty( oError:filename )
      cMessage += ": " + oError:filename
   CASE ! Empty( oError:operation )
      cMessage += ": " + oError:operation
   ENDCASE

   // add OS error code if available
   IF ! Empty( oError:osCode )
      cMessage += " (DOS Error " + hb_ntos( oError:osCode ) + ")"
   ENDIF

RETURN cMessage

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_AppRec()

   IF Empty( Alias() )
      RETURN .F.
   ENDIF

   APPEND BLANK

   IF IndexOrd() == 0
      _BrowseEnd( 'Edit_1', 'WndMain' )
   ENDIF
   WndMain.Edit_1.VALUE := RecNo()
   WndMain.StatusBar.Item( 1 ) := "Records: " + LTrim( Str( LastRec() ) )
   WndMain.StatusBar.Item( 2 ) := ""

RETURN .T.

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_Pack()

   LOCAL cTitle := "Packing database"

   IF Msgyesno( "Are you sure ?", cTitle )
      DlgWait( cTitle )
      PACK
      DlgWait()
      WndMain.Edit_1.VALUE := 1
      WndMain.StatusBar.Item( 1 ) := "Records: " + LTrim( Str( LastRec() ) )
      WndMain.StatusBar.Item( 2 ) := ""
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_Zap()

   LOCAL cTitle := "Zap database"

   IF Msgyesno( "ALL DATA WILL BE LOST !!! Are you sure ?", cTitle )
      DlgWait( cTitle )
      ZAP
      DlgWait()
      WndMain.Edit_1.VALUE := 0
      WndMain.StatusBar.Item( 1 ) := "Records: " + LTrim( Str( LastRec() ) )
      WndMain.StatusBar.Item( 2 ) := ""
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STATIC FUNCTION dbv_DelRec()

   IF ! Empty( Alias() )
      dbGoto( WndMain.Edit_1.Value )
      IF Deleted()
         RECALL
      ELSE
         DELETE
      ENDIF
      WndMain.Edit_1.Refresh()
      WndMain.Edit_1.SetFocus()
   ENDIF

RETURN NIL

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FUNCTION GetStatusBarHeight( cForm ) // Height StatusBar

   DEFAULT cForm := ThisWindow.NAME

RETURN GetWindowHeight( GetControlHandle( 'STATUSBAR', cForm ) )

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
