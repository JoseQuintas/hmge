/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018-2022 Grigory Filatov <gfilatov@gmail.com>
 *
 * Inspired by EMAG Software DBU https://www.emagsoftware.it
 */

REQUEST DBFCDX

#include "minigui.ch"
#include "tsbrowse.ch" 
#include "dbinfo.ch"

#xtranslate IsMaximized ( <hWnd> )  => IsZoomed ( <hWnd> )
#xtranslate IsWin10()               => hb_osIsWin10()

#define PRG_TITLE 'MiniGUI DataBase Utility'
#define PRG_VERSION '0.82'


Static cIni, cRddName

Memvar BRW_1
Memvar cFilter
Memvar cOrder


/******
*
*       Main()
*
*       Create Application
*
*/

Procedure Main( cDBFName )

  Local lMaximized, nTop, nLeft, nWidth, nHeight
  Local cDBFPath, cFile, nW, nH

  PUBLIC cFilter := "", cOrder := ""

  // Harbour commands
  SET CENTURY ON

  SET DATE BRITISH

  SET EXCLUSIVE ON

  SET AUTOPEN OFF

  // MiniGUI commands
  SET FONT TO "Tahoma", 9

  SET DEFAULT ICON TO "ICONA"

  IF IsVistaOrLater()
    SET CENTERWINDOW RELATIVE PARENT
  ENDIF

  SET AUTOSCROLL OFF

  SET NAVIGATION EXTENDED

  cRddName := "DBFNTX"

  // Global parameters processing
  cIni := ChangeFileExt( Application.ExeName, '.ini' )

  BEGIN INI FILENAME (cIni)
	GET lMaximized SECTION "Parameters" ENTRY "Maximized" DEFAULT .T.
	GET nTop SECTION "Parameters" ENTRY "Top" DEFAULT 0
	GET nLeft SECTION "Parameters" ENTRY "Left" DEFAULT 0
	GET cRddName SECTION "Parameters" ENTRY "RDD" DEFAULT cRddName
	GET nWidth SECTION "Parameters" ENTRY "Width" DEFAULT 0
	GET nHeight SECTION "Parameters" ENTRY "Height" DEFAULT 0
  END INI

  // Input parameter processing
  IF PCount() > 0 .AND. Upper( cDBFName ) == "CDX"
    cRddName := "DBFCDX"
    cDBFName := NIL
  ENDIF

  DEFAULT cDBFName := "test"

  IF Empty( cDBFPath := cFilePath( cDBFName ) )
    cDBFPath := GetCurrentFolder()
  ENDIF
  cDBFPath += "\"

  IF File( cDBFPath + cFileNoExt( cDBFName ) + ".fpt" ) .OR. ;
     File( cDBFPath + cFileNoExt( cDBFName ) + ".cdx" )
    cRddName := "DBFCDX"
  ENDIF

  // Set default RDD and open a data file
  rddSetDefault( cRddName )

  IF File( cDBFPath + cFileNoExt( cDBFName ) + ".dbf" )
    IF !OpenTable( cDBFPath + cFileNoPath( cDBFName ) )
      Return
    ENDIF
    cFile := dbInfo( DBI_FULLPATH )
  ELSE
    cFile := ""
  ENDIF

  // Create Main Window of Application
  DEFINE WINDOW MainWin ;
         MAIN ;
         TITLE PRG_TITLE ;
         ON INIT iif( Empty( cFile ), DisableMainMenu( 'MainWin' ), ;
                     AddMRUItem( cFile, "OpenDataTable( cFile )" )) ;
         ON MAXIMIZE Browse_OnSize( .T. ) ;
         ON SIZE Browse_OnSize( .F. ) ;
         ON RELEASE SaveMRUFileList()

         IF !lMaximized
           IF nTop >= 0
             MainWin.Row := nTop
           ENDIF
           IF nLeft >= 0
             MainWin.Col := nLeft
           ENDIF
           IF nWidth > 0
             MainWin.Width := nWidth
           ENDIF
           IF nHeight > 0
             MainWin.Height := nHeight
           ENDIF
         ENDIF

         // Create Main Menu of Application
         CreateMainMenu()

         // Create Main ToolBar of Application
         CreateToolBar()

         // Create StatusBar of Application
         DEFINE STATUSBAR KEYBOARD
           STATUSITEM cRddName WIDTH 60 ACTION OnRDDchange() FONTCOLOR LGREEN
           STATUSITEM iif( cRddName == "DBFNTX", "DBT", "FPT" ) WIDTH 40 FONTCOLOR MAROON
         END STATUSBAR

         IF lMaximized
           nW := GetDesktopWidth()
           nH := MainWin.ClientHeight - GetToolBarHeight() - GetTitleHeight() + iif( IsWin10(), GetBorderHeight(), GetBorderHeight() + 2 )
         ELSE
           nW := MainWin.ClientWidth
           nH := MainWin.ClientHeight - GetToolBarHeight() - GetTitleHeight() - GetBorderHeight() / 2
         ENDIF

         CreateBrowse( "BRW_1", GetToolBarHeight() + 4, 0, nW, nH )

         SetHotKeys()

  END WINDOW

  IF !Empty( cFile )
    MainWin.Title := PRG_TITLE + " - " + cFile
  ENDIF

  IF lMaximized
    MAXIMIZE WINDOW MainWin
  ENDIF
  ACTIVATE WINDOW MainWin

Return

****** End of Main ******


Static Procedure SetHotKeys()

  // <INSERT> key processing
  ON KEY INSERT ACTION { || AddRecord() }

  ON KEY F2 ACTION { || OpenDataTable() }

  ON KEY F3 ACTION { || ModifyTable() }

  ON KEY F4 ACTION { || ColumnVis() }

  ON KEY F5 ACTION { || Browse_Refresh() }

  ON KEY F6 ACTION { || ReplaceFieldValue() }

  ON KEY F7 ACTION { || ContinueSeek() }

  ON KEY F8 ACTION { || ordFilter() }

  ON KEY F9 ACTION { || ColumnSeek() }

  ON KEY F10 ACTION { || Browse_GotoFirstCol() }

  ON KEY F11 ACTION { || Browse_GotoLastCol() }

  ON KEY CONTROL+Q ACTION { || Closetable() }

  ON KEY CONTROL+D ACTION { || DuplicateRec() }

  ON KEY CONTROL+I ACTION { || OpenIndex() }

  ON KEY CONTROL+R ACTION { || GoToRecord() }

  ON KEY CONTROL+T ACTION { || SelectTag() }

  ON KEY CONTROL+X ACTION { || QuickExit() }

Return


/******
*
*       CreateMainMenu()
*
*       Cteate Main Menu
*
*/

Static Procedure CreateMainMenu

  DEFINE MAIN MENU OF MainWin
          
     POPUP '&File'
        ITEM 'New table...' ACTION NewTable()
        ITEM 'New index...' ACTION NewIndex()
        ITEM 'New TAG...'   ACTION NewTag() NAME fnew_tag DISABLED
        SEPARATOR
        ITEM 'Open table...' + Chr(9) + 'F2' ACTION OpenDataTable() NAME f_odt
        ITEM 'Open index...' + Chr(9) + 'CTRL-I' ACTION OpenIndex()
        ITEM 'Select TAG' + Chr(9) + 'CTRL-T' ACTION SelectTag() NAME fsel_tag DISABLED
        SEPARATOR
        ITEM 'Close Table'     ACTION  Closetable()  NAME fsel_Close
        SEPARATOR
        ITEM 'Copy a table...' ACTION CopyToFile()
        ITEM 'Import a record...' ACTION ImportOfRec()
        SEPARATOR
	DEFINE POPUP 'Recent Files' 
	    MRU ' (Empty) ' INI (cIni) SECTION "Mru" ACTION OpenDataTable( cFile )
	END POPUP 
        SEPARATOR
        ITEM 'E&xit' + Chr(9) + 'CTRL-X' ACTION { || QuickExit() } NAME prg_exit
     END POPUP

     POPUP '&Modification'
        ITEM 'New record' + Chr(9) + 'INS' ACTION AddRecord()
        ITEM 'Delete/recall a record toggle' + Chr(9) + 'DELETE' ACTION Browse_Delete()
        ITEM 'Duplicate a current record' + Chr(9) + 'CTRL-D' ACTION DuplicateRec()
        SEPARATOR
        ITEM 'Modification of a column' + Chr(9) + 'Enter' ACTION Browse_Enter()
        ITEM 'Multiple replace...' + Chr(9) + 'F6' ACTION ReplaceFieldValue()
        ITEM 'Delete the records...' ACTION DeleteRecord()
        ITEM 'Modification of a structure of table...' + Chr(9) + 'F3' ACTION ModifyTable()
        ITEM 'Modification of a column properties...' ACTION ModifyColumn()
        SEPARATOR
        ITEM 'ZAP a table...' ACTION Table_Zap()
        ITEM 'PACK a table...' ACTION Table_Pack()
        SEPARATOR
        ITEM 'DBFNTX' NAME dbfntx CHECKED
        ITEM 'DBFCDX' NAME dbfcdx
        SEPARATOR
        ITEM 'Memo DBT' NAME memo_dbt CHECKED
        ITEM 'Memo FPT' NAME memo_fpt
     END POPUP

     POPUP '&View'
        ITEM 'Go to a record...' + Chr(9) + 'CTRL-R' ACTION GoToRecord()
        ITEM 'Go to a first column' + Chr(9) + 'F10' ACTION Browse_GotoFirstCol()
        ITEM 'Go to a last column' + Chr(9) + 'F11' ACTION Browse_GotoLastCol()
        ITEM 'Seek a column by name...' + Chr(9) + 'F9' ACTION ColumnSeek()
        ITEM 'Continue a seek of column...' + Chr(9) + 'F7' ACTION ContinueSeek()
        ITEM 'Toggle a column visibility...' + Chr(9) + 'F4' ACTION ColumnVis()
        ITEM 'Set a filter...' + Chr(9) + 'F8' ACTION ordFilter()
        SEPARATOR
        ITEM 'Clear a filter' ACTION ClearFilter()
        SEPARATOR
        ITEM 'Refresh' + Chr(9) + 'F5' ACTION Browse_Refresh()
     END POPUP

     POPUP '?'
        ITEM '&Information' ACTION DBU_About() NAME prg_about
     END POPUP

  END MENU

  IF rddSetDefault() == "DBFCDX"
     MainWin.dbfcdx.Checked   := .T.
     MainWin.memo_fpt.Checked := .T.
     MainWin.dbfntx.Checked   := .F.
     MainWin.memo_dbt.Checked := .F.
  ENDIF

Return

****** End of CreateMainMenu ******


/******
*
*       QuickExit()
*
*       Exit from application
*
*/

Static Procedure QuickExit

  BEGIN INI FILENAME (cIni)
	SET SECTION "Parameters" ENTRY "Maximized" TO IsMaximized( MainWin.Handle )
	SET SECTION "Parameters" ENTRY "Top" TO Max( MainWin.Row, 0 )
	SET SECTION "Parameters" ENTRY "Left" TO Max( MainWin.Col, 0 )
	SET SECTION "Parameters" ENTRY "RDD" TO cRddName
	IF !IsMaximized( MainWin.Handle )
		SET SECTION "Parameters" ENTRY "Width" TO MainWin.Width
		SET SECTION "Parameters" ENTRY "Height" TO MainWin.Height
	ENDIF
  END INI

  QUIT

Return

***** End of QuickExit ******


/******
*
*       CreateToolBar()
*
*       Cteate Main Tool Bar
*
*/

Procedure CreateToolBar

   Define Toolbar dbuTools OF MainWin ButtonSize 27, 25 FLAT
       Button btnNew     Picture 'NUOVO'   Action NewTable()  Tooltip 'Create a new table' DROPDOWN
       DEFINE DROPDOWN MENU BUTTON btnNew
          ITEM 'New table...' ACTION NewTable()
          ITEM 'New index...' ACTION NewIndex()
          ITEM 'New TAG...' ACTION NewTag() NAME new_tag DISABLED
          SEPARATOR
          ITEM 'New record' + Chr(9) + 'INS' ACTION AddRecord()
          ITEM 'Duplicate a current record' + Chr(9) + 'CTRL-D' ACTION DuplicateRec()
       END MENU

       Button btnOpen    Picture 'APRI'    Action OpenDataTable() Tooltip 'Load a table' DROPDOWN Separator
       DEFINE DROPDOWN MENU BUTTON btnOpen
          ITEM 'Open table...' + Chr(9) + 'F2' ACTION OpenDataTable() Name ODT
          ITEM 'Open index...' + Chr(9) + 'CTRL-I' ACTION OpenIndex()
          ITEM 'Select TAG'    + Chr(9) + 'CTRL-T' ACTION SelectTag() NAME sel_tag DISABLED
          SEPARATOR
          ITEM 'Close Table'     ACTION  Closetable()  NAME sel_Close DISABLED
       END MENU
       Button btnCopy    Picture 'COPIATAB'    Action CopyToFile()  Tooltip 'Copy a table'
       Button btnImport  Picture 'IMPORTAREC'  Action ImportOfRec()  Tooltip 'Import a record' Separator
       Button btnCol1    Picture 'CERCACOL'    Action ColumnSeek()  Tooltip 'Seek a column by name'
       Button btnCol2    Picture 'VISTACOL'    Action ColumnVis()  Tooltip 'Toggle a column visibility'
       Button btnFilter  Picture 'FILTRO'      Action ordFilter()  Tooltip 'Set a filter'
       Button btnClear   Picture 'CHIUDI'      Action ClearFilter()  Tooltip 'Clear a filter with ordering' Separator
       Button btnRefr    Picture 'AGGIORNA'    Action Browse_Refresh()  Tooltip 'Refresh' Separator
       Button btnExit    Picture 'EXIT'        Action { || QuickExit() }  Tooltip 'Exit'
   End Toolbar

Return

***** End of CreateToolBar ******


FUNCTION Browse_OnSize( lMax )

  DEFAULT lMax := .F.

  MainWin.BRW_1.Width := MainWin.ClientWidth
  MainWin.BRW_1.Height := MainWin.ClientHeight - GetToolBarHeight( "dbuTools", "MainWin" ) - GetTitleHeight() - GetBorderHeight() / 2

  IF Empty( _HMG_MouseState )
    BRW_1:nHeightHead := BRW_1:nHeightCell + GetBorderHeight() / 2
    BRW_1:SetNoHoles()
  ELSEIF lMax
    BRW_1:Refresh( .F. )
  ENDIF

Return NIL


PROCEDURE NewTable

  MEMVAR BRW_2

  LOCAL aStruct := {}, i, cFileDbf
  LOCAL aNames := { "Field Name", "Type", "Len", "Dec" }
  LOCAL bOK := {|| _HMG_DialogCancelled := !BRW_2:lHasChanged, aStruct := BRW_2:aArray, DoMethod( 'frmTableNew', 'Release' ) }
  LOCAL bCancel := {||
                   If BRW_2:lHasChanged
                      Tone( 1000, .5 )
                      _HMG_ModalDialogReturn := 2
                      IF HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1
                         _HMG_DialogCancelled := .T.
                         DoMethod( 'frmTableNew', 'Release' )
                      ENDIF
                   Else
                      _HMG_DialogCancelled := .T.
                      DoMethod( 'frmTableNew', 'Release' )
                   EndIf
                   Return Nil
                  }

  DEFINE WINDOW frmTableNew;
      CLIENTAREA 320,600;
      TITLE "New table";
      MODAL NOSIZE;
      ON INIT StatusChange( ThisWindow.Name )

      Define Toolbar TblTools ButtonSize 16, 16 FLAT
        Button btnOK    Picture 'OK'        Action Eval( bOK )  Tooltip 'Confirm'
        Button btnExit  Picture 'CANCEL'    Action Eval( bCancel )  Tooltip 'Cancel'  Separator
        Button btnIns   Picture 'INSERT'    Action AddField( .T., ThisWindow.Name )  Tooltip 'Insert a field'
        Button btnAdd   Picture 'APPEND'    Action AddField( .F., ThisWindow.Name )  Tooltip 'Append a field'  Separator
        Button btnEdit  Picture 'EDIT'      Action ModifyField()  Tooltip 'Edit a field'
        Button btnDel   Picture 'DELETE'    Action ( BRW_2:Del(), StatusChange( BRW_2:cParentWnd ) )  Tooltip 'Erase a field'
      End Toolbar

      DEFINE STATUSBAR
      END STATUSBAR

      DEFINE TBROWSE BRW_2 ;
         AT GetToolBarHeight( 'TblTools' ) + GetBorderHeight() / 2, 0 ;
         WIDTH  frmTableNew.ClientWidth ;
         HEIGHT frmTableNew.ClientHeight - GetTitleHeight() - GetToolBarHeight( 'TblTools' ) - GetBorderHeight() / 2 ;
         ARRAY aStruct ;
         HEADERS aNames ;
         ON CHANGE { || StatusChange( BRW_2:cParentWnd ) }

         :lNoHScroll   := .T.
         :lNoGrayBar   := .T.
         :lNoChangeOrd := .T.
         :nHeightCell  += 2
         :nHeightHead  := :nHeightCell + GetBorderHeight() / 2
         :nWheelLines  := 1
         :lNoMoveCols  := .T.
         :lNoResetPos  := .F.

         :SetColor( { 1, 2, 4, 5, 6 }, { ;
              CLR_BLACK, ;
              CLR_WHITE, ;
              { CLR_WHITE, RGB(210, 210, 220) }, ;
              CLR_WHITE, RGB(51, 153, 255) }, )

         For i := 1 To Len( aNames )
           If i > 2
             :aColumns[ i ]:nHAlign := DT_RIGHT
             :aColumns[ i ]:nAlign  := DT_RIGHT
           Else
             :aColumns[ i ]:nHAlign := DT_LEFT
           EndIf
         Next

         :AdjColumns()

         :bKeyDown := { |nKey| If( nKey == VK_DELETE, ( BRW_2:Del(), StatusChange( BRW_2:cParentWnd ) ), ;
                               If( nKey == VK_INSERT, AddField( .T., BRW_2:cParentWnd ), Nil ) ) }
         :blDblClick := { || ModifyField() }

         :lHasChanged  := .F.

      END TBROWSE

      ON KEY ESCAPE ACTION Eval( bCancel )

  END WINDOW

  CENTER WINDOW frmTableNew
  ACTIVATE WINDOW frmTableNew

  IF !_HMG_DialogCancelled .AND. Len( aStruct ) > 0 .AND. !Empty( aStruct[1][1] )

    cFileDbf := PutFile( { {"File DBF (*.DBF)", "*.DBF"} }, 'New table...', GetCurrentFolder() )

    IF Empty( cFileDbf )
      RETURN
    ENDIF

    IF File( cFileDbf )
      FRENAME( cFileDbf, cFileNoExt( cFileDbf ) + ".bak" )
    ENDIF

    AEval( aStruct, { |a, i| aStruct[i][2] := iif( Left( a[2], 1 ) == "A", "+", Left( a[2], 1 ) ) } )

    DBCreate( cFileDbf, aStruct, rddSetDefault() )

    OpenDataTable( cFileDbf )

  ENDIF

RETURN


PROCEDURE StatusChange( cFormName )

  LOCAL oBrw := GetBrowseObj( "BRW_2", cFormName )

  LOCAL cMsg

  IF Len( oBrw:aArray ) > 0 .AND. !Empty( oBrw:aArray[1][1] )
    cMsg := "Field " + hb_ntos(oBrw:nAt) + "/" + hb_ntos(oBrw:nLen)
  ELSE
    cMsg := "Field 0/0"
  ENDIF

  SetProperty( cFormName, "StatusBar", "Item", 1, cMsg )

  oBrw:cMsg := cMsg
  oBrw:SetFocus()

RETURN


PROCEDURE ModifyField

  MEMVAR BRW_2

  LOCAL lChanges := .F.
  LOCAL nColumn := BRW_2:nAt
  LOCAL cField, cType, nLen, nDec
  LOCAL nType
  LOCAL aTypes := { ;
                 "Character", ;
                 "Memo", ;
                 "Numeric", ;
                 "Date", ;
                 "Logical", ;
                 "AutoInc" ;
                }
  LOCAL aHTypes := { ;
                 "C" => "Character", ;
                 "M" => "Memo", ;
                 "N" => "Numeric", ;
                 "D" => "Date", ;
                 "L" => "Logical", ;
                 "+" => "AutoInc" ;
                }

  IF Empty( nColumn ) .OR. ( nColumn == 1 .AND. Empty( BRW_2:aArray[ nColumn ][ 1 ] ) )
    RETURN
  ENDIF

  cField  := BRW_2:aArray[ nColumn ][ 1 ]
  cType   := BRW_2:aArray[ nColumn ][ 2 ]
  nLen    := BRW_2:aArray[ nColumn ][ 3 ]
  nDec    := BRW_2:aArray[ nColumn ][ 4 ]
  nType   := AScan( aTypes, cType )
  IF Empty( nType )
    nType := 6
  ENDIF

  DEFINE WINDOW ColumnChg;
      CLIENTAREA 335,100;
      TITLE "Modification of a field";
      MODAL NOSIZE ;
      ON INIT ColumnChg.edtFld.Setfocus

      ON KEY ESCAPE ACTION ColumnChg.Release

      DEFINE LABEL lblFld
          ROW       15
          COL       15
          VALUE     "Field name:"
          AUTOSIZE .T.
      END LABEL

      DEFINE TEXTBOX edtFld
          ROW       35
          COL       15
          WIDTH     85
          HEIGHT    23
          VALUE     cField
          UPPERCASE .T.
          ONCHANGE  iif( Left( ColumnChg.edtFld.Value, 1 ) $ "0123456789", ColumnChg.edtFld.Value := "", ;
                    ( lChanges := .T., cField := AllTrim( ColumnChg.edtFld.Value ) ) )
      END TEXTBOX

      DEFINE LABEL lblTyp
          ROW       15
          COL       110
          VALUE     "Type:"
          AUTOSIZE .T.
      END LABEL

      DEFINE COMBOBOX cmbTyp
          ROW       35
          COL       110
          WIDTH     105
          HEIGHT    180
          ITEMS     aTypes
          VALUE     nType
          ONCHANGE  ( lChanges := .T., cType := Left( ColumnChg.cmbTyp.Item( ColumnChg.cmbTyp.Value ), 1 ), ;
                    OnTypeChange( This.Value, ThisWindow.Name ) )
      END COMBOBOX

      DEFINE LABEL lblLen
          ROW       15
          COL       225
          VALUE     "Len.:"
          AUTOSIZE .T.
      END LABEL

      DEFINE TEXTBOX edtLen
          ROW        35
          COL        225
          WIDTH      45
          HEIGHT     23
          VALUE      nLen
          ONCHANGE   ( lChanges := .T., nLen := ColumnChg.edtLen.Value )
          NUMERIC    .T.
          RIGHTALIGN .T.
      END TEXTBOX

      DEFINE LABEL lblDec
          ROW       15
          COL       280
          VALUE     "Dec.:"
          AUTOSIZE .T.
      END LABEL

      DEFINE TEXTBOX edtDec
          ROW        35
          COL        280
          WIDTH      35
          HEIGHT     23
          VALUE      nDec
          ONCHANGE   ( lChanges := .T., nDec := ColumnChg.edtDec.Value )
          NUMERIC    .T.
          RIGHTALIGN .T.
      END TEXTBOX

      DEFINE BUTTON btnConfirm
          ROW       70
          COL       15
          WIDTH     70
          HEIGHT    23
          CAPTION   '&OK'
          ACTION    iif( nLen == 0, ( ;
                       ColumnChg.edtLen.BackColor := RED, ;
                       Tone( 1000, .5 ), ;
                       HMG_Alert( "A field no valid.", , , ICON_INFORMATION ), ;
                       ColumnChg.edtLen.BackColor := WHITE, ;
                       ColumnChg.edtLen.SetFocus ), ;
                       ( BRW_2:lHasChanged := .T., ;
                       cType := hb_HGetDef( aHTypes, iif( cType == "A", "+", cType ), 'C' ), ;
                       BRW_2:aArray[nColumn] := { cField, cType, nLen, nDec }, ThisWindow.Release ) )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       70
          COL       95
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    iif( lChanges, ( Tone( 1000, .5 ), _HMG_ModalDialogReturn := 2, ;
                    iif( HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1, ;
                    ThisWindow.Release, NIL ) ), ThisWindow.Release )
      END BUTTON

  END WINDOW

  ColumnChg.edtLen.Enabled := ( nType == 1 .OR. nType == 3 )
  ColumnChg.edtDec.Enabled := ( nType == 3 )

  CENTER WINDOW ColumnChg
  ACTIVATE WINDOW ColumnChg

RETURN


PROCEDURE AddField( lMode, cFormName )

  MEMVAR BRW_2

  LOCAL lChanges := .F.
  LOCAL cField, cType, nLen, nDec
  LOCAL nType
  LOCAL aTypes := { ;
                 "Character", ;
                 "Memo", ;
                 "Numeric", ;
                 "Date", ;
                 "Logical", ;
                 "AutoInc" ;
                }
  LOCAL aHTypes := { ;
                 "C" => "Character", ;
                 "M" => "Memo", ;
                 "N" => "Numeric", ;
                 "D" => "Date", ;
                 "L" => "Logical", ;
                 "+" => "AutoInc" ;
                }

  cField  := ""
  cType   := "C"
  nLen    := 10
  nDec    := 0
  nType   := AScan( aTypes, cType )

  DEFINE WINDOW FieldNew;
      CLIENTAREA 335,100;
      TITLE iif( lMode, "Insert", "Append" ) + " field";
      MODAL NOSIZE ;
      ON INIT FieldNew.edtFld.Setfocus

      ON KEY ESCAPE ACTION FieldNew.Release

      DEFINE LABEL lblFld
          ROW       15
          COL       15
          VALUE     "Field name:"
          AUTOSIZE .T.
      END LABEL

      DEFINE TEXTBOX edtFld
          ROW       35
          COL       15
          WIDTH     85
          HEIGHT    23
          VALUE     cField
          UPPERCASE .T.
          ONCHANGE  iif( Left( FieldNew.edtFld.Value, 1 ) $ "0123456789", FieldNew.edtFld.Value := "", ;
                    ( lChanges := .T., cField := AllTrim( FieldNew.edtFld.Value ) ) )
      END TEXTBOX

      DEFINE LABEL lblTyp
          ROW       15
          COL       110
          VALUE     "Type:"
          AUTOSIZE .T.
      END LABEL

      DEFINE COMBOBOX cmbTyp
          ROW       35
          COL       110
          WIDTH     105
          HEIGHT    180
          ITEMS     aTypes
          VALUE     nType
          ONCHANGE  ( lChanges := .T., cType := Left( FieldNew.cmbTyp.Item( FieldNew.cmbTyp.Value ), 1 ), ;
                    OnTypeChange( This.Value, ThisWindow.Name ) )
      END COMBOBOX

      DEFINE LABEL lblLen
          ROW       15
          COL       225
          VALUE     "Len.:"
          AUTOSIZE .T.
      END LABEL

      DEFINE TEXTBOX edtLen
          ROW        35
          COL        225
          WIDTH      45
          HEIGHT     23
          VALUE      nLen
          ONCHANGE   ( lChanges := .T., nLen := FieldNew.edtLen.Value )
          NUMERIC    .T.
          RIGHTALIGN .T.
      END TEXTBOX

      DEFINE LABEL lblDec
          ROW       15
          COL       280
          VALUE     "Dec.:"
          AUTOSIZE .T.
      END LABEL

      DEFINE TEXTBOX edtDec
          ROW        35
          COL        280
          WIDTH      35
          HEIGHT     23
          VALUE      nDec
          ONCHANGE   ( lChanges := .T., nDec := FieldNew.edtDec.Value )
          NUMERIC    .T.
          RIGHTALIGN .T.
      END TEXTBOX

      DEFINE BUTTON btnConfirm
          ROW       70
          COL       15
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( lChanges, ;
                    iif( AScan( BRW_2:aArray, { |a| a[1] == cField } ) > 0, ;
                    ( MsgInfo( "This field name is exists.", "Attention" ), FieldNew.edtFld.SetFocus ), ;
                    iif( nLen == 0, ( ;
                       FieldNew.edtLen.BackColor := RED, ;
                       Tone( 1000, .5 ), ;
                       HMG_Alert( "A field no valid.", , , ICON_INFORMATION ), ;
                       FieldNew.edtLen.BackColor := WHITE, ;
                       FieldNew.edtLen.SetFocus ), ;
                    ( cType := hb_HGetDef( aHTypes, iif( cType == "A", "+", cType ), 'C' ), ;
                    AddNewFld( lMode, cField, cType, nLen, nDec, cFormName ), ThisWindow.Release ) ) ), ThisWindow.Release )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       70
          COL       95
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    ThisWindow.Release
      END BUTTON

  END WINDOW

  FieldNew.edtLen.Enabled := ( nType == 1 .OR. nType == 3 )
  FieldNew.edtDec.Enabled := ( nType == 3 )

  CENTER WINDOW FieldNew
  ACTIVATE WINDOW FieldNew

RETURN


PROCEDURE OnTypeChange( nType, cWin )

  SetProperty( cWin, "edtLen", "Enabled", ( nType == 1 .OR. nType == 3 ) )
  SetProperty( cWin, "edtDec", "Enabled", ( nType == 3 ) )

  DO CASE
     CASE nType == 1 .OR. nType == 2 .OR. nType == 6
       SetProperty( cWin, "edtLen", "Value", 10 )
     CASE nType == 4
       SetProperty( cWin, "edtLen", "Value", 8 )
     CASE nType == 5
       SetProperty( cWin, "edtLen", "Value", 1 )
     OTHERWISE
       SetProperty( cWin, "edtLen", "Value", 0 )
  ENDCASE

  SetProperty( cWin, "edtDec", "Value", 0 )

RETURN


PROCEDURE AddNewFld( lMode, cField, cType, nLen, nDec, cFormName )

  LOCAL oBrw := GetBrowseObj( "BRW_2", cFormName )

  IF lMode
    oBrw:Insert( { cField, cType, nLen, nDec } )
  ELSE
    oBrw:AddItem( { cField, cType, nLen, nDec } )
    oBrw:GoBottom()
  ENDIF

  StatusChange( cFormName )
  oBrw:lHasChanged := .T.

RETURN


PROCEDURE NewIndex

  LOCAL cBagName
  LOCAL lUnique := .F.
  LOCAL cCond := "", cKey := "", cTagName

  LOCAL cIndexExt := Upper( IndexExt() )

  cBagName := PutFile( { {"File " + SubStr( cIndexExt, 2 ) + " (*" + cIndexExt + ")", "*" + cIndexExt } }, 'New index...', ;
                       GetCurrentFolder() )

  IF Empty( cBagName )
    RETURN
  ENDIF

  cTagName := cFileNoExt( cBagName )

  DEFINE WINDOW frmNewIdx;
      CLIENTAREA 535,300;
      TITLE "New Index";
      MODAL NOSIZE;
      ON INIT frmNewIdx.edtTag.Setfocus

      ON KEY ESCAPE ACTION frmNewIdx.Release

      DEFINE LABEL lblFile
          ROW       15
          COL       15
          VALUE     "File name:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX lblFullPath
          ROW       35
          COL       15
          VALUE     cBagName
          WIDTH     410
          HEIGHT    30
          BACKCOLOR WHITE
          NOVSCROLLBAR .T.
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblTag
          ROW       80
          COL       300
          VALUE     "TAG:"
          WIDTH     40
          HEIGHT    23
          VCENTERALIGN .T.
      END LABEL

      DEFINE TEXTBOX edtTag
          ROW       80
          COL       340
          WIDTH     85
          HEIGHT    23
          VALUE     cTagName
          ONCHANGE  cTagName := AllTrim( frmNewIdx.edtTag.Value )
          UPPERCASE .T.
          ONLOSTFOCUS  iif( Empty( cTagName ), ( ;
                       frmNewIdx.edtTag.BackColor := RED, ;
                       Tone( 1000, .5 ), ;
                       HMG_Alert( "A tag name no valid.", , , ICON_INFORMATION ), ;
                       frmNewIdx.edtTag.BackColor := WHITE, ;
                       frmNewIdx.edtTag.SetFocus ), NIL )
      END TEXTBOX

      DEFINE LABEL lblKey
          ROW       105
          COL       15
          VALUE     "Key:"
          AUTOSIZE  .T.
      END LABEL

      DEFINE EDITBOX edtKey
          ROW       125
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cKey
          ONCHANGE  ( cKey := AllTrim( frmNewIdx.edtKey.Value ), frmNewIdx.chkUnique.Enabled := !Empty( cKey ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblCond
          ROW       200
          COL       15
          VALUE     "Condition FOR:"
          AUTOSIZE  .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       220
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cCond
          ONCHANGE  ( cCond := AllTrim( frmNewIdx.edtCond.Value ), frmNewIdx.chkUnique.Enabled := !Empty( cCond ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnConfirm
          ROW       35
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( AddIdx( cBagName, cTagName, cKey, cCond, lUnique ), frmNewIdx.Release, NIL )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       80
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    ThisWindow.Release
      END BUTTON

      DEFINE CHECKBOX chkUnique
          ROW       220
          COL       450
          CAPTION   'Unique:'
          VALUE     lUnique
          LEFTJUSTIFY .T.
          AUTOSIZE  .T.
      END CHECKBOX

  END WINDOW

  _ExtDisableControl( 'lblFullPath', 'frmNewIdx' )
  frmNewIdx.lblFullPath.FontColor := GRAY
  frmNewIdx.chkUnique.Enabled := .F.

  CENTER WINDOW frmNewIdx
  ACTIVATE WINDOW frmNewIdx

RETURN


STATIC FUNCTION AddIdx( cBagName, cTagName, cOrdKey, cCond, lUnique )

  LOCAL bOldErr
  LOCAL lOk := .T.

  IF !Empty( cCond )

    bOldErr := ErrorBlock({|e| Break(e) })

    BEGIN SEQUENCE
      &cCond
    RECOVER
      lOk := .F.
    END SEQUENCE

    ErrorBlock( bOldErr )

    IF !lOk
      frmNewIdx.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
      frmNewIdx.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

    bOldErr := ErrorBlock({|e| Break(e) })

    BEGIN SEQUENCE
      lOk := ( ValType( &cCond ) == "L" )
    RECOVER
      lOk := .F.
    END SEQUENCE

    ErrorBlock( bOldErr )

    IF !lOk
      frmNewIdx.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "It should be a logical value.", , , ICON_INFORMATION )
      frmNewIdx.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

    ordCondSet( cCond, hb_macroBlock( cCond ), .T. /*All*/, , , , RecNo(), , , , , , , , , , , .F. )

  ENDIF

  IF !Empty( cOrdKey )
    bOldErr := ErrorBlock({|e| Break(e) })
    BEGIN SEQUENCE
      &cOrdKey
    RECOVER
      lOk := .F.
      frmNewIdx.edtKey.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A key no valid.", , , ICON_INFORMATION )
      frmNewIdx.edtKey.BackColor := WHITE
    END SEQUENCE
    ErrorBlock( bOldErr )
  ENDIF

  IF !lOk
    RETURN lOk
  ENDIF

  ordCreate( cBagName, cTagName, cOrdKey, hb_macroBlock( cOrdKey ), lUnique )

  SetNewIndex( cBagName )

RETURN lOk


PROCEDURE SetNewIndex( cBagName )

  LOCAL oBrw, yIndex

  OrdListAdd( cBagName )
  OrdSetFocus( OrdCount() )

  yindex := ( ordNumber() > 0 )

  MainWin.fnew_tag.Enabled := yindex
  MainWin.fsel_tag.Enabled := yindex
  MainWin.sel_tag.Enabled  := yindex
  MainWin.new_tag.Enabled  := yindex

  DbClearFilter()
  cFilter := ""

  oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  oBrw:bFilter := NIL
  oBrw:lInitGoTop := .T.
  oBrw:Reset()
  oBrw:uLastTag := ordNumber()

RETURN


PROCEDURE OpenDataTable( cFile )

  LOCAL lDbfCdx

  IF Empty( cFile )

    cFile := GetFile( { {"File DBF (*.DBF)", "*.DBF"} }, 'Open table...' )

    IF Empty( cFile )
      RETURN
    ENDIF

  ENDIF

  IF File( ChangeFileExt( cFile, ".fpt" ) ) .OR. ;
     File( ChangeFileExt( cFile, ".cdx" ) )
    cRddName := "DBFCDX"
  ENDIF

  // Set default RDD and open a data file
  rddSetDefault( cRddName )

  IF !OpenTable( cFile )
    RETURN
  ENDIF

  MainWin.Title := PRG_TITLE + " - " + dbInfo( DBI_FULLPATH )

  EnableMainMenu( 'MainWin' )

  lDbfCdx := ( rddSetDefault() == "DBFCDX" )
  MainWin.StatusBar.Item( 5 ) := iif( lDbfCdx, "DBFCDX", "DBFNTX" )
  MainWin.StatusBar.Item( 6 ) := iif( lDbfCdx, "FPT", "DBT" )

  MainWin.dbfcdx.Checked   := lDbfCdx
  MainWin.memo_fpt.Checked := lDbfCdx
  MainWin.dbfntx.Checked   := ! lDbfCdx
  MainWin.memo_dbt.Checked := ! lDbfCdx

  AddMRUItem( cFile, "OpenDataTable( cFile )" )

  CloseTable()

RETURN
/*
 * 27/4/2018 add by Pierpaolo Martinello
 */
PROCEDURE CloseTable()

  LOCAL cAlias
  LOCAL cMsg := PRG_TITLE
  LOCAL nR, nC, nW, nH

  nR := BRW_1:nTop
  nC := BRW_1:nLeft
  nW := BRW_1:nRight - nC + 1
  nH := BRW_1:nBottom - nR + 1

  cAlias := BRW_1:cAlias
  _ReleaseControl( "BRW_1", "MainWin" )
  DoEvents()
  CLOSE ( cAlias )

  DisableMainMenu( 'MainWin' )

  MainWin.f_Odt.Enabled      := .T.
  MainWin.Odt.Enabled        := .T.
  MainWin.fsel_Close.Enabled := Used()
  MainWin.sel_Close.Enabled  := Used()

  CreateBrowse( "BRW_1", nR, nC, nW, nH )
  Browse_OnSize()
  SetProperty( "MainWin", "StatusBar", "Item", 1, cMsg )

  BRW_1:cMsg := cMsg
  BRW_1:SetFocus()

RETURN

PROCEDURE OpenIndex

  LOCAL cIndexName
  LOCAL cIndexExt := Upper( IndexExt() )

  cIndexName := GetFile( { {"File " + SubStr( cIndexExt, 2 ) + " (*" + cIndexExt + ")", "*" + cIndexExt } }, 'Open index...', ;
                       GetCurrentFolder() )

  IF Empty( cIndexName )
    RETURN
  ENDIF

  ordListClear()

  SetNewIndex( cIndexName )

RETURN


PROCEDURE NewTag

  LOCAL cFileName
  LOCAL cCond := "", cKey := "", cTagName := ""
  LOCAL lChanges := .F., lUnique := .F.

  IF ordBagName() == 'Memory'
    cFileName := ''
  ELSE
    cFileName := dbOrderInfo( DBOI_FULLPATH,, IndexOrd() )
  ENDIF

  DEFINE WINDOW frmNewTag;
      CLIENTAREA 535,300;
      TITLE "New TAG";
      MODAL NOSIZE;
      ON INIT frmNewTag.edtTag.Setfocus

      ON KEY ESCAPE ACTION frmNewTag.Release

      DEFINE LABEL lblFile
          ROW       15
          COL       15
          VALUE     "File name:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX lblFullPath
          ROW       35
          COL       15
          VALUE     cFileName
          WIDTH     410
          HEIGHT    30
          BACKCOLOR WHITE
          NOVSCROLLBAR .T.
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblTag
          ROW       80
          COL       300
          VALUE     "TAG:"
          WIDTH     40
          HEIGHT    23
          VCENTERALIGN .T.
      END LABEL

      DEFINE TEXTBOX edtTag
          ROW       80
          COL       340
          WIDTH     85
          HEIGHT    23
          VALUE     cTagName
          ONCHANGE  ( lChanges := .T., cTagName := AllTrim( frmNewTag.edtTag.Value ) )
          UPPERCASE .T.
          ONLOSTFOCUS  iif( Empty( cTagName ) .AND. lChanges, ( ;
                       frmNewTag.edtTag.BackColor := RED, ;
                       Tone( 1000, .5 ), ;
                       HMG_Alert( "A tag name no valid.", , , ICON_INFORMATION ), ;
                       frmNewTag.edtTag.BackColor := WHITE, ;
                       frmNewTag.edtTag.SetFocus ), NIL )
      END TEXTBOX

      DEFINE LABEL lblKey
          ROW       105
          COL       15
          VALUE     "Key:"
          AUTOSIZE  .T.
      END LABEL

      DEFINE EDITBOX edtKey
          ROW       125
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cKey
          ONCHANGE  ( lChanges := .T., cKey := AllTrim( frmNewTag.edtKey.Value ), frmNewTag.chkUnique.Enabled := !Empty( cKey ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblCond
          ROW       200
          COL       15
          VALUE     "Condition FOR:"
          AUTOSIZE  .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       220
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cCond
          ONCHANGE  ( lChanges := .T., cCond := AllTrim( frmNewTag.edtCond.Value ), frmNewTag.chkUnique.Enabled := !Empty( cCond ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnConfirm
          ROW       35
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( AddTag( cFileName, cTagName, cKey, cCond, lUnique ), frmNewTag.Release, NIL )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       80
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    ThisWindow.Release
      END BUTTON

      DEFINE CHECKBOX chkUnique
          ROW       220
          COL       450
          CAPTION   'Unique:'
          VALUE     lUnique
          LEFTJUSTIFY .T.
          AUTOSIZE  .T.
      END CHECKBOX

  END WINDOW

  _ExtDisableControl( 'lblFullPath', 'frmNewTag' )
  frmNewTag.lblFullPath.FontColor := GRAY
  frmNewTag.chkUnique.Enabled := .F.

  CENTER WINDOW frmNewTag
  ACTIVATE WINDOW frmNewTag

RETURN


STATIC FUNCTION AddTag( cBagName, cTagName, cOrdKey, cCond, lUnique )

  LOCAL bOldErr
  LOCAL lOk := .T.

  IF Empty( cTagName )
    lOk := .F.
    frmNewTag.edtTag.BackColor := RED
    Tone( 1000, .5 )
    HMG_Alert( "A tag no valid.", , , ICON_INFORMATION )
    frmNewTag.edtTag.BackColor := WHITE
    RETURN lOk
  ENDIF

  IF Empty( cOrdKey )
    lOk := .F.
    frmNewTag.edtKey.BackColor := RED
    Tone( 1000, .5 )
    HMG_Alert( "A key no valid.", , , ICON_INFORMATION )
    frmNewTag.edtKey.BackColor := WHITE
    RETURN lOk
  ENDIF

  IF Empty( cBagName )
    cBagName := ChangeFileExt( dbInfo( DBI_FULLPATH ), IndexExt() )
  ENDIF

  IF !Empty( cCond )

    bOldErr := ErrorBlock({|e| Break(e) })

    BEGIN SEQUENCE
      &cCond
    RECOVER
      lOk := .F.
    END SEQUENCE

    ErrorBlock( bOldErr )

    IF !lOk
      frmNewTag.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
      frmNewTag.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

    bOldErr := ErrorBlock({|e| Break(e) })

    BEGIN SEQUENCE
      lOk := ( ValType( &cCond ) == "L" )
    RECOVER
      lOk := .F.
    END SEQUENCE

    ErrorBlock( bOldErr )

    IF !lOk
      frmNewTag.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "It should be a logical value.", , , ICON_INFORMATION )
      frmNewTag.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

    ordCondSet( cCond, hb_macroBlock( cCond ), .T. /*All*/, , , , RecNo(), , , , , , , , , , , .F. )

  ENDIF

  bOldErr := ErrorBlock({|e| Break(e) })
  BEGIN SEQUENCE
    &cOrdKey
  RECOVER
    lOk := .F.
    frmNewTag.edtKey.BackColor := RED
    Tone( 1000, .5 )
    HMG_Alert( "A key no valid.", , , ICON_INFORMATION )
    frmNewTag.edtKey.BackColor := WHITE
  END SEQUENCE
  ErrorBlock( bOldErr )

  IF !lOk
    RETURN lOk
  ENDIF

  ordCreate( cBagName, cTagName, cOrdKey, hb_macroBlock( cOrdKey ), lUnique )

  SetNewIndex( cBagName )

RETURN lOk


PROCEDURE SelectTag()

  Local aTags := {}, aIndexes := {}
  Local indname, nOrder, cKey := "", cCond := "", lUnique := .F.
  Local i := 0

  IF !Used()
     RETURN
  ENDIF

  WHILE !Empty( indname := ordName( ++i ) )
     AAdd( aTags, { indname, ordKey( i ), ordFor( i ) } )
  END

  IF OrdCount() > 0

    AEval( aTags, { |t| AAdd( aIndexes, t[1] ) } )

    nOrder := Max( 1, IndexOrd() )

    IF nOrder > 0
      cKey    := aTags[nOrder][2]
      cCond   := aTags[nOrder][3]
      lUnique := dbOrderInfo( DBOI_UNIQUE,, nOrder )
    ENDIF

    DEFINE WINDOW frmSelTag;
      CLIENTAREA 535,265;
      TITLE "Select TAG";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION frmSelTag.Release

      DEFINE LABEL lblTag
          ROW       15
          COL       15
          VALUE     "TAG:"
          WIDTH     40
          HEIGHT    23
          VCENTERALIGN .T.
      END LABEL

      DEFINE COMBOBOX cmbTag
          ROW       15
          COL       55
          WIDTH     105
          HEIGHT    180
          ITEMS     aIndexes
          VALUE     nOrder
          ONCHANGE  ( nOrder := frmSelTag.cmbTag.Value, frmSelTag.edtKey.Value := aTags[nOrder][2], ;
                    frmSelTag.edtCond.Value := aTags[nOrder][3] )
      END COMBOBOX

      DEFINE LABEL lblKey
          ROW       60
          COL       15
          VALUE     "Key:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtKey
          ROW       80
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cKey
          BACKCOLOR WHITE
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblCond
          ROW       160
          COL       15
          VALUE     "Condition FOR:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       180
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cCond
          BACKCOLOR WHITE
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnConfirm
          ROW       15
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    ( ordSetFocus( nOrder ), BRW_1:Reset(), BRW_1:uLastTag := nOrder, frmSelTag.Release )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       45
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    ThisWindow.Release
      END BUTTON

      DEFINE CHECKBOX chkUnique
          ROW       180
          COL       450
          CAPTION   'Unique:'
          VALUE     lUnique
          LEFTJUSTIFY .T.
          AUTOSIZE .T.
      END CHECKBOX

    END WINDOW

    _ExtDisableControl( 'edtKey', 'frmSelTag' )
    _ExtDisableControl( 'edtCond', 'frmSelTag' )
    frmSelTag.chkUnique.Enabled := .F.

    CENTER WINDOW frmSelTag
    ACTIVATE WINDOW frmSelTag

  ENDIF

RETURN


PROCEDURE DBU_About()

   DEFINE WINDOW frmAbout;
      WIDTH  486 ;
      HEIGHT 278 ;
      MODAL ;
      NOCAPTION NOSIZE ;
      BACKCOLOR {240, 240, 240} ;
      ON INIT frmAbout.cmdClose.Setfocus

      ON KEY ESCAPE ACTION frmAbout.Release

      DEFINE IMAGE imgLogo
          ROW       24
          COL       23
          WIDTH     100
          HEIGHT    100
          PICTURE   "EMAG"
      END IMAGE

      DEFINE LABEL msgAbout_1
          ROW       24
          COL       165
          VALUE     PRG_TITLE
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE LABEL msgAbout_2
          ROW       52
          COL       165
          VALUE     "Version: " + PRG_VERSION
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE LABEL msgAbout_3
          ROW       80
          COL       165
          VALUE     "Copyright " + CHR(169) + " 2018-2022 MiniGUI Team"
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE LABEL msgAbout_4
          ROW       108
          COL       165
          VALUE     "Serial Number: FreeWare"
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DRAW LINE IN WINDOW frmAbout ;
	AT 135,165 TO 135,460 ;
	PENCOLOR WHITE

      DRAW LINE IN WINDOW frmAbout ;
	AT 136,165 TO 136,460 ;
	PENCOLOR GRAY

      DRAW LINE IN WINDOW frmAbout ;
	AT 137,165 TO 137,460 ;
	PENCOLOR WHITE

      DEFINE LABEL msgAbout_5
          ROW       150
          COL       165
          VALUE     "Inspired by EMAG Software DBU"
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE LABEL msgAbout_6
          ROW       178
          COL       165
          VALUE     "Via Trionfale 125 - 00136 Roma"
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE LABEL msgAbout_7
          ROW       206
          COL       165
          VALUE     "Telephone: 063972861"
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE LABEL msgAbout_8
          ROW       234
          COL       165
          VALUE     "Email: e.m.giordano@emagsoftware.it"
          AUTOSIZE .T.
          TRANSPARENT .T.
      END LABEL

      DEFINE BUTTON cmdClose
         ROW      215
         COL      36
         CAPTION  'Close'
         TOOLTIP  'Close'
         WIDTH    88
         HEIGHT   34
         ACTION   frmAbout.Release
         DEFAULT .T.
      END BUTTON
      
   END WINDOW

   CENTER   WINDOW frmAbout
   ACTIVATE WINDOW frmAbout

RETURN


STATIC FUNCTION OnRDDchange()

  LOCAL lDbfCdx

  lDbfCdx := ( cRddName == "DBFCDX" )
  lDbfCdx := ! lDbfCdx

  cRddName := iif( lDbfCdx, "DBFCDX", "DBFNTX" )

  MainWin.StatusBar.Item( 5 ) := cRddName
  MainWin.StatusBar.Item( 6 ) := iif( lDbfCdx, "FPT", "DBT" )

RETURN NIL


*============================================================================*
*                          Auxiliary Functions
*============================================================================*

FUNCTION OpenTable( cDBF )

  LOCAL bOldHandler
  LOCAL lOpen := .T.
  LOCAL cAlias

  bOldHandler := ErrorBlock( {|o| Break(o)} )

  cAlias := Upper( Left( cFileNoExt( cDBF ), 4 ) )

  BEGIN SEQUENCE

    USE ( cDBF ) ALIAS ( GetNewAlias( cAlias ) ) NEW

  RECOVER

    lOpen := .F.

    MsgStop( "Unable to open file:" + CRLF + cDBF )

  END

  ErrorBlock( bOldHandler )

RETURN lOpen


STATIC FUNCTION GetNewAlias( cAlias )

   LOCAL nArea := 1
   LOCAL cNewAlias

   IF Select( cAlias ) != 0
      REPEAT
      UNTIL Select( cNewAlias := ( cAlias + StrZero( nArea++, 3 ) ) ) != 0
   ELSE
      cNewAlias := cAlias
   ENDIF

RETURN cNewAlias


FUNCTION PropertyInputBox ( cInputPrompt , cDialogCaption , cDefaultValue , nType )

   Local lIsVistaOrLater := IsVistaOrLater()
   Local nBordW  := iif(lIsVistaOrLater, GetBorderWidth() / 2 + 2, 0)
   Local nTitleH := GetTitleHeight() + iif(lIsVistaOrLater, GetBorderHeight() / 2 + 2, 0)
   Local RetVal  := ''
   Local bCancel := {|| _HMG_DialogCancelled := .T., DoMethod( '_PropertyInputBox', 'Release' ) }

   DEFAULT cInputPrompt TO "", cDialogCaption TO "Property Edit", cDefaultValue TO ""

   DEFINE WINDOW _PropertyInputBox ;
      WIDTH 310 + nBordW ;
      HEIGHT 115 + nTitleH ;
      TITLE cDialogCaption ;
      MODAL ;
      NOSIZE

      ON KEY ESCAPE ACTION Eval( bCancel )

      @ 20, 20 LABEL _Label VALUE cInputPrompt HEIGHT 26 VCENTERALIGN

      If nType == 1
         ON KEY RETURN ACTION _PropertyInputBox._Ok.Action

         @ 20, 90 TEXTBOX _Input ;
		VALUE cDefaultValue ;
		HEIGHT 26 ;
		WIDTH 195 ;
                NUMERIC RIGHTALIGN
      Else

         @ 20, 115 TEXTBOX _Input ;
		VALUE cDefaultValue ;
		HEIGHT 26 ;
		WIDTH 170 ;
                UPPERCASE ;
                ON ENTER _PropertyInputBox._Ok.Action
      EndIf

      @ 67, 80 BUTTON _Ok ;
         CAPTION _HMG_MESSAGE [6] ;
         ACTION ( _HMG_DialogCancelled := .F., RetVal := _PropertyInputBox._Input.Value, ;
		_PropertyInputBox.Release )

      @ 67, 190 BUTTON _Cancel ;
         CAPTION _HMG_MESSAGE [7] ;
         ACTION Eval( bCancel )

   END WINDOW

   CENTER WINDOW _PropertyInputBox
   ACTIVATE WINDOW _PropertyInputBox

RETURN ( RetVal )


FUNCTION GetBrowseObj( cBrw, cParent )          

  LOCAL oBrw, i

  If ( i := GetControlIndex( cBrw, cParent ) ) > 0
     oBrw := _HMG_aControlIds [ i ]
  EndIf

RETURN oBrw


FUNCTION GetToolBarHeight( cTBName, cFormName )

  DEFAULT cTBName := "dbuTools", cFormName := ThisWindow.Name

RETURN LoWord( GetSizeToolBar( GetControlHandle( cTBName, cFormName ) ) )


FUNCTION Scatter()

  LOCAL aRecord[ fcount() ]

RETURN AEval( aRecord, {|x,n| aRecord[n] := FieldGet( n ), x := NIL } )


FUNCTION Gather( paRecord )

RETURN AEval( paRecord, {|x,n| FieldPut( n, x ) } )


FUNCTION DisableMainMenu( cFormName )

   LOCAL nFormHandle, i, nControlCount

   IF !Used()

      nFormHandle   := GetFormHandle ( cFormName )
      nControlCount := Len ( _HMG_aControlHandles )

      FOR i := 1 TO nControlCount

         IF _HMG_aControlParentHandles[ i ] ==  nFormHandle
            IF ValType ( _HMG_aControlHandles[ i ] ) == 'N'
               IF _HMG_aControlType[ i ] == 'MENU' .AND. _HMG_aControlEnabled[ i ] == .T. .AND. !Empty( _HMG_aControlNames[ i ] )
                  _DisableMenuItem ( _HMG_aControlNames[ i ], cFormName )
               ENDIF
            ENDIF
         ENDIF

      NEXT i

      SetProperty( "MainWin", "f_Odt"    , "Enabled", .T. )
      SetProperty( "MainWin", "Odt"      , "Enabled", .T. )
      SetProperty( "MainWin", "prg_exit" , "Enabled", .T. )
      SetProperty( "MainWin", "prg_about", "Enabled", .T. )

   ENDIF

RETURN NIL


FUNCTION EnableMainMenu( cFormName )

   LOCAL nFormHandle, i, nControlCount

   nFormHandle   := GetFormHandle ( cFormName )
   nControlCount := Len ( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount

      IF _HMG_aControlParentHandles[ i ] ==  nFormHandle
         IF ValType ( _HMG_aControlHandles[ i ] ) == 'N'
            IF _HMG_aControlType[i ] == 'MENU' .AND. _HMG_aControlEnabled[ i ] == .T. .AND. !Empty( _HMG_aControlNames[ i ] )
               _EnableMenuItem ( _HMG_aControlNames[ i ], cFormName )
            ENDIF
         ENDIF
      ENDIF

   NEXT i

RETURN NIL
