/***
*
*  Dbuedit.prg
*
*  DBU Data File Editing Module
*
*/

#include "minigui.ch"
#include "tsbrowse.ch" 
#include "dbinfo.ch"
#include "dbstruct.ch"

#define EM_SETSEL     177


Memvar BRW_1
Memvar cFilter
Memvar cOrder

DECLARE WINDOW MainWin
DECLARE WINDOW _InputBox


/******
*
*       CreateBrowse()
*
*       Cteate Browse
*
*/

Procedure CreateBrowse( cBrw, nR, nC, nW, nH )

  LOCAL oCol
  LOCAL i, lMemo := .F.

  PUBLIC &cBrw

  DEFINE TBROWSE &cBrw ;
       AT nR, nC ;
       OF MainWin;
       WIDTH  nW ;
       HEIGHT nH ;
       ALIAS Alias() ;
       ON INIT {|| DoMethod( 'MainWin', cBrw, 'DisableUpdate' ) } ;
       ON CHANGE Browse_OnChange()

       // load fields with available editing
       :LoadFields( TRUE )

       // set celled navigation
       :lCellBrw := .T.

       // workaround for navigation in multicolumns database
       :lMoreFields := ( FCount() > 45 )

       For i := 1 To FCount()

           // get columns object
           oCol := :aColumns[ i ]
           // Set header title
           oCol:cHeading := FieldName( i )
           // Set header aligning
           oCol:nHAlign := DT_LEFT
           // Forbid moving after editing
           oCol:nEditMove := DT_DONT_MOVE
           // Select all content at editing of a column
           oCol:lOnGotFocusSelect := .T.
           // Status processing
           oCol:bLostFocus := { || Browse_OnChange() }
           // set columns picture
           IF oCol:cFieldTyp == "M"
             oCol:cPicture := Repl( "X", 60 )
             lMemo := .T.
             :aColumns[ i ]:bPrevEdit := { | uVal, oBr | EditMemo( uVal, oBr ) }
           ELSEIF oCol:cFieldTyp == "L"
             oCol:cPicture := " X "
           ELSEIF oCol:cFieldTyp == "D"
             oCol:cPicture := "99/99/9999 "
           ENDIF
           // set columns width
           oCol:nWidth := Max( GetTextWidth( 0, oCol:cField, :hFont ), oCol:ToWidth( iif( oCol:nFieldLen > 60, 60, Nil ), 1.05 ) ) + ;
              iif( oCol:nFieldLen > 19, 0, 4 )

       Next

       // avoids changing active order by double clicking on headers
       :lNoChangeOrd := .T.
       // Correct cell height
       :nHeightCell  += 2
       // Correct cell height for Memo field
       IF lMemo
          :nHeightCell := Min( 18, :nHeightCell )
       ENDIF
       // Correct header height
       :nHeightHead  := :nHeightCell + GetBorderHeight() / 2
       // set lines scrolling
       :nWheelLines  := 1
       // avoids to resize or move columns by mouse drag
       :lNoMoveCols  := .T.
       // prevents to reset record position on gotfocus
       :lNoResetPos  := .F.
       // disable DatePicker mode in an inplace editing
       :lPickerMode  := .F.            // usual date format
       // set grid lines style
       :nLineStyle   := LINES_ALL      // LINES_NONE LINES_ALL LINES_VERT LINES_HORZ LINES_3D LINES_DOTTED
       // <Enter> key processing
       :nFireKey     := VK_F10         // default Edit key
       // <Enter> key switches a logical value
       :lCheckBoxAllReturn := .T.
       // use fast drawing mode
       :lFastDrawCell := .T.
       // <DELETE> key processing
       :SetDeleteMode( .T., .F. )
       :bPostDel := {|o| o:Refresh( .F. ) }

       :bLogicLen := {|| iif( Empty( BRW_1:cAlias ), 0, ;
          iif( ( BRW_1:cAlias )->( OrdKeyCount() ) == 0, ;
          ( BRW_1:cAlias )->( LastRec() ), ;
          ( BRW_1:cAlias )->( OrdKeyCount() ) ) ) }

       :SetColor( { 1, 2, 4, 5, 6, 8 }, { ;
          CLR_BLACK, ;
          { || iif( ( BRW_1:cAlias )->( Deleted() ), RGB(255, 160, 160), CLR_WHITE ) }, ;
          { CLR_WHITE, RGB(210, 210, 220) }, ;
          CLR_WHITE, ;
          { || iif( ( BRW_1:cAlias )->( Deleted() ), CLR_RED, RGB(51, 153, 255) ) }, ;
          { || iif( ( BRW_1:cAlias )->( Deleted() ), RGB(244, 238, 121), RGB(184, 237, 112) ) } }, )

       :SetNoHoles()
       :SetFocus()

  END TBROWSE ON END {|| DoMethod( 'MainWin', cBrw, 'EnableUpdate' ) }

Return

****** End of CreateBrowse ******


STATIC FUNCTION EditMemo( uValue, oBrw )

  Local oCol, lDialogCancelled
  Local cField, cType, cEdit

  oCol   := oBrw:aColumns[ oBrw:nCell ]

  cField := Field( oBrw:nCell )

  cType  := iif( Empty( oCol:cDataType ), ValType( uValue ), oCol:cDataType )

  IF cType == "M"

    lDialogCancelled := .F.

    DEFINE TIMER _InputBox PARENT MainWin INTERVAL 50 ONCE ;
      ACTION iif( IsWindowDefined( _InputBox ), ( _InputBox.Width := 780, _InputBox.Height := 600, _InputBox.Center(), ;
      _InputBox._TextBox.FontName := "Courier New", SendMessage( _InputBox._TextBox.Handle, EM_SETSEL, 0, -1 ), ;
      MainWin._InputBox.Release() ), Nil )

    cEdit := InputBox( "Enter a text:", "Modification of a memo field", uValue, , , .T., @lDialogCancelled )

    IF lDialogCancelled == .F.

      REPLACE &cField WITH cEdit

      oBrw:Drawselect()

    ENDIF

  ENDIF

RETURN .F.


STATIC FUNCTION Browse_OnChange

  LOCAL oBrw
  Local cMsg := "", nRows := LastRec()

  oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  cMsg += "Column: " + hb_ntos( oBrw:nCell ) + "/" + hb_ntos( Len( oBrw:aColumns ) ) + space( 4 )
  cMsg += "RecNo: " + hb_ntos( Min( nRows, RecNo() ) ) + "/" + hb_ntos( nRows ) + space( 4 )
  cMsg += "KeyNo: " + hb_ntos( Min( nRows, ordKeyNo() ) ) + "/" + hb_ntos( ordKeyCount() )

  IF !Empty( cFilter )
    cMsg += space( 4 ) + "Filter: " + cFilter
  ENDIF

  IF !Empty( cOrder )
    cMsg += space( 4 ) + "Order: " + cOrder
  ENDIF

  MainWin.StatusBar.Item( 1 ) := cMsg
  // Restore the 1-st status item at a mouse moving
  AEval( oBrw:aColumns, { |o| o:cMsg := cMsg } )

RETURN NIL


FUNCTION Browse_Refresh( lMode )

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  DEFAULT lMode := .F.

  IF !Empty( oBrw:cAlias )
    oBrw:Refresh( lMode )
    oBrw:SetFocus()
  ENDIF

RETURN NIL


FUNCTION Browse_Enter()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  oBrw:PostMsg( WM_KEYDOWN, VK_F10, 0 )
  oBrw:SetFocus()

RETURN NIL


FUNCTION Browse_Delete()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  oBrw:PostMsg( WM_KEYDOWN, VK_DELETE, 0 )
  oBrw:SetFocus()

RETURN NIL


FUNCTION Table_Pack

  Tone( 1000, .5 )
  IF HMG_Alert( "Do you want to PACK a table?", {"Co&nfirm","&Cancel"} ) == 1

    PACK

    BRW_1:GoTop()
    Browse_OnChange()
    Browse_Refresh()

  ENDIF

RETURN NIL


FUNCTION Table_Zap

  Tone( 1000, .5 )
  IF HMG_Alert( "Do you want to ZAP a table?", {"Co&nfirm","&Cancel"} ) == 1

    ZAP

    BRW_1:GoTop()
    Browse_OnChange()
    Browse_Refresh()

  ENDIF

RETURN NIL


PROCEDURE CopyToFile()

  STATIC cCond, cOrdKey, lUnique := .F., lSDF := .F.

  LOCAL cFileName, lChanges := .F.

  cFileName := PutFile( { {"File DBF (*.DBF)", "*.DBF"} }, 'Copy a table to...' )

  IF Empty( cFileName )
    RETURN
  ENDIF

  DEFINE WINDOW frmCopyTo;
      CLIENTAREA 535,275;
      TITLE "Copy a table";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION frmCopyTo.Release

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

      DEFINE LABEL lblCond
          ROW       80
          COL       15
          VALUE     "Condition:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       100
          COL       15
          WIDTH     410
          HEIGHT    60
          VALUE     iif( ISCHARACTER( cCond ), cCond, "" )
          ONCHANGE  ( lChanges := .T., cCond := AllTrim( frmCopyTo.edtCond.Value ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblOrd
          ROW       175
          COL       15
          VALUE     "Ordered by:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtOrd
          ROW       195
          COL       15
          WIDTH     410
          HEIGHT    60
          VALUE     iif( ISCHARACTER( cOrdKey ), cOrdKey, "" )
          ONCHANGE  ( lChanges := .T., cOrdKey := AllTrim( frmCopyTo.edtOrd.Value ), frmCopyTo.chkUnique.Enabled := !Empty( cOrdKey ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnCopy
          ROW       35
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( CopyTo( cFileName, cCond, cOrdKey, lUnique, lSDF ), frmCopyTo.Release, NIL )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       65
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    iif( lChanges, ( Tone( 1000, .5 ), _HMG_ModalDialogReturn := 2, ;
                    iif( HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1, ;
                    ThisWindow.Release, NIL ) ), ThisWindow.Release )
      END BUTTON

      DEFINE CHECKBOX chkSDF
          ROW       140
          COL       450
          CAPTION   'SDF:'
          VALUE     lSDF
          ONCHANGE  ( lChanges := .T., lSDF := frmCopyTo.chkSDF.Value, cFileName := StrTran( cFileName, iif( lSDF, ".DBF", ".TXT" ), ;
                      iif( lSDF, ".TXT", ".DBF" ) ), frmCopyTo.lblFullPath.Value := cFileName )
          LEFTJUSTIFY .T.
          AUTOSIZE .T.
      END CHECKBOX

      DEFINE CHECKBOX chkUnique
          ROW       195
          COL       450
          CAPTION   'Unique:'
          VALUE     lUnique
          ONCHANGE  ( lChanges := .T., lUnique := frmCopyTo.chkUnique.Value )
          LEFTJUSTIFY .T.
          AUTOSIZE .T.
      END CHECKBOX

  END WINDOW

  _ExtDisableControl( 'lblFullPath', 'frmCopyTo' )
  frmCopyTo.lblFullPath.FontColor := GRAY
  frmCopyTo.chkUnique.Enabled := !Empty( cOrdKey )

  CENTER WINDOW frmCopyTo
  ACTIVATE WINDOW frmCopyTo

RETURN


STATIC FUNCTION CopyTo( cFile, cCond, cOrdKey, lUnique, lSDF )

  LOCAL bOldErr
  LOCAL cIndexName, cTag
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
      frmCopyTo.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
      frmCopyTo.edtCond.BackColor := WHITE
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
      frmCopyTo.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "It should be a logical value.", , , ICON_INFORMATION )
      frmCopyTo.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

    IF !Empty( cOrdKey )
      bOldErr := ErrorBlock({|e| Break(e) })
      BEGIN SEQUENCE
        &cOrdKey
      RECOVER
        lOk := .F.
        frmCopyTo.edtOrd.BackColor := RED
        Tone( 1000, .5 )
        HMG_Alert( "A key no valid.", , , ICON_INFORMATION )
        frmCopyTo.edtOrd.BackColor := WHITE
      END SEQUENCE
      ErrorBlock( bOldErr )
    ENDIF

    IF !lOk
      RETURN lOk
    ENDIF

  ENDIF

  IF !Empty( cOrdKey )

    cIndexName := TempFile( GetTempFolder() )
    cTag := 't' + DTOS( Date() ) + Left( Right( Time(), 4 ), 1 )

    ordListClear()

    ordCreate( cIndexName, cTag, cOrdKey, hb_macroBlock( cOrdKey ), lUnique )
    ordListAdd(  cIndexName )
    ordSetFocus( 1 )

  ENDIF

  IF lSDF
    lOk := __dbSdf( .T., cFile, , hb_macroBlock( cCond ),,,, .F. )
  ELSE
    lOk := __dbCopy( cFile, , hb_macroBlock( cCond ),,,, .F. )
  ENDIF

RETURN lOk


PROCEDURE ImportOfRec

  STATIC cCond

  LOCAL cFileName, lChanges := .F.

  cFileName := GetFile( { {"File DBF (*.DBF)", "*.DBF"} , {"File SDF (*.TXT)", "*.TXT"} }, 'Import a record from...' )

  IF Empty( cFileName )
    RETURN
  ENDIF

  DEFINE WINDOW frmImport;
      CLIENTAREA 535,180;
      TITLE "Import a record";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION frmImport.Release

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

      DEFINE LABEL lblCond
          ROW       80
          COL       15
          VALUE     "Condition:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       100
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     iif( ISCHARACTER( cCond ), cCond, "" )
          ONCHANGE  ( lChanges := .T., cCond := AllTrim( frmImport.edtCond.Value ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnImport
          ROW       35
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( Import( cFileName, cCond ), frmImport.Release, Tone( 1000, .5 ) )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       65
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    iif( lChanges, ( Tone( 1000, .5 ), _HMG_ModalDialogReturn := 2, ;
                    iif( HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1, ;
                    ThisWindow.Release, NIL ) ), ThisWindow.Release )
      END BUTTON

  END WINDOW

  _ExtDisableControl( 'lblFullPath', 'frmImport' )
  frmImport.lblFullPath.FontColor := GRAY

  CENTER WINDOW frmImport
  ACTIVATE WINDOW frmImport

RETURN


STATIC FUNCTION Import( cFile, cCond )

  LOCAL lSDF := ( hb_FNameExt( cFile ) == ".TXT" )
  LOCAL nRecno
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
      frmImport.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
      frmImport.edtCond.BackColor := WHITE
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
      frmImport.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "It should be a logical value.", , , ICON_INFORMATION )
      frmImport.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

  ENDIF

  nRecno := Recno()

  IF lSDF
    lOk := __dbSdf( .F., cFile, , iif( Empty( cCond ), NIL, hb_macroBlock( cCond ) ),,,, .F. )
  ELSE
    lOk := __dbApp( cFile, , iif( Empty( cCond ), NIL, hb_macroBlock( cCond ) ), , , , .F., rddSetDefault() )
  ENDIF

  dbGoTo( nRecno )
  Browse_OnChange()
  Browse_Refresh()

RETURN lOk


PROCEDURE ReplaceFieldValue()

  LOCAL aFields := Array( FCount() ), lChanges := .F.
  LOCAL cField, cFilterCond, cValue := "", cExpr := ""

  IF !Used()
     RETURN
  ENDIF

  AFields( aFields )
  cField := aFields[ 1 ]
  DEFINE WINDOW frmReplace;
      CLIENTAREA 535,325;
      TITLE "Replace a field value";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION iif( ThisWindow.FocusedControl == "cmbFld", frmReplace.edtVal.SetFocus, frmReplace.Release )

      DEFINE LABEL lblFld
          ROW       10
          COL       15
          VALUE     "Field:"
          WIDTH     50
          HEIGHT    23
          VCENTERALIGN .T.
      END LABEL

      DEFINE COMBOBOX cmbFld
          ROW       10
          COL       65
          WIDTH     120
          HEIGHT    230
          ITEMS     aFields
          VALUE     1
          ONCHANGE  ( lChanges := .T., cField := frmReplace.cmbFld.Item( frmReplace.cmbFld.Value ) )
      END COMBOBOX

      DEFINE LABEL lblVal
          ROW       50
          COL       15
          VALUE     "Value:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtVal
          ROW       50
          COL       65
          WIDTH     360
          HEIGHT    65
          VALUE     cValue
          ONCHANGE  ( lChanges := .T., cValue := AllTrim( frmReplace.edtVal.Value ) )
          ONLOSTFOCUS  iif( Empty( cValue ), , frmReplace.edtExpr.Value := "" )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblExpr
          ROW       130
          COL       15
          VALUE     "Expression:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtExpr
          ROW       150
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     cExpr
          ONCHANGE  ( lChanges := .T., cExpr := AllTrim( frmReplace.edtExpr.Value ) )
          NOHSCROLLBAR .T.
          ONLOSTFOCUS  iif( Empty( cExpr ), , frmReplace.edtVal.Value := "" )
      END EDITBOX

      DEFINE LABEL lblCond
          ROW       230
          COL       15
          VALUE     "Condition of a filter:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       250
          COL       15
          WIDTH     410
          HEIGHT    60
          VALUE     cFilterCond
          ONCHANGE  ( lChanges := .T., cFilterCond := AllTrim( frmReplace.edtCond.Value ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnConfirm
          ROW       10
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( ReplaceFor( cField, cFilterCond, cValue, cExpr ), frmReplace.Release, NIL )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       40
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    iif( lChanges, ( Tone( 1000, .5 ), _HMG_ModalDialogReturn := 2, ;
                    iif( HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1, ;
                    ThisWindow.Release, NIL ) ), ThisWindow.Release )
      END BUTTON

  END WINDOW

  CENTER WINDOW frmReplace
  ACTIVATE WINDOW frmReplace

RETURN


STATIC FUNCTION ReplaceFor( cField, cFilterCond, cValue, cExpr )

  LOCAL bExpr, nRecno
  LOCAL bOldErr
  LOCAL lOk := .T.

  IF FieldPos( cField ) > 0 .AND. ( !Empty( cValue ) .OR. !Empty( cExpr ) )

    bOldErr := ErrorBlock({|e| Break(e) })

    IF !Empty( cExpr )

      BEGIN SEQUENCE
        &cExpr
      RECOVER
        lOk := .F.
        frmReplace.edtExpr.BackColor := RED
        Tone( 1000, .5 )
        HMG_Alert( "An expression no valid.", , , ICON_INFORMATION )
        frmReplace.edtExpr.BackColor := WHITE
      END SEQUENCE

    ENDIF

    ErrorBlock( bOldErr )

    IF !lOk
      RETURN lOk
    ENDIF

    IF !Empty( cFilterCond )

      bOldErr := ErrorBlock({|e| Break(e) })

      BEGIN SEQUENCE
        lOk := ( ValType( &cFilterCond ) == "L" )
      RECOVER
        lOk := .F.
        frmReplace.edtCond.BackColor := RED
        Tone( 1000, .5 )
        HMG_Alert( "A condition no valid.", , , ICON_INFORMATION )
        frmReplace.edtCond.BackColor := WHITE
      END SEQUENCE

      ErrorBlock( bOldErr )

      IF !lOk
        RETURN lOk
      ENDIF

    ENDIF

    nRecno := Recno()
    dbGoTop()

    IF !Empty( cValue )

      IF ValType( &cField ) == "C"
        cValue := "["+cValue+"]"
      ENDIF

      bExpr := hb_macroBlock( "_FIELD->"+cField+":="+cValToChar(cValue) )

    ELSE

      IF ValType( &cField ) == "C"
        bExpr := hb_macroBlock( "_FIELD->"+cField+":=["+&cExpr+"]" )
      ELSE
        bExpr := hb_macroBlock( "_FIELD->"+cField+":="+cValToChar(&cExpr) )
      ENDIF

    ENDIF

    IF !Empty( cFilterCond )
      dbEval( bExpr, hb_macroBlock( cFilterCond ) )
    ELSE
      dbEval( bExpr )
    ENDIF

    dbGoTo( nRecno )
    Browse_Refresh()

  ENDIF

RETURN lOk


PROCEDURE DeleteRecord

  STATIC cCond

  DEFINE WINDOW frmDelete;
      CLIENTAREA 535,115;
      TITLE "Delete the records";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION frmDelete.Release

      DEFINE LABEL lblCond
          ROW       15
          COL       15
          VALUE     "Condition:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       35
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     iif( ISCHARACTER( cCond ), cCond, "" )
          ONCHANGE  cCond := AllTrim( frmDelete.edtCond.Value )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON btnConfirm
          ROW       40
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    iif( DeleteFor( cCond ), frmDelete.Release, NIL )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       70
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    ThisWindow.Release
      END BUTTON

  END WINDOW

  CENTER WINDOW frmDelete
  ACTIVATE WINDOW frmDelete

RETURN


STATIC FUNCTION DeleteFor( cCond )

  LOCAL bExpr := { || dbDelete() } 
  LOCAL bOldErr, nRecno
  LOCAL lOk := .T.

  bOldErr := ErrorBlock({|e| Break(e) })

  BEGIN SEQUENCE
    &cCond
  RECOVER
    lOk := .F.
    frmDelete.edtCond.BackColor := RED
    Tone( 1000, .5 )
    HMG_Alert( "A condition no valid.", , , ICON_INFORMATION )
    frmDelete.edtCond.BackColor := WHITE
  END SEQUENCE

  ErrorBlock( bOldErr )

  IF lOk

    nRecno := Recno()
    dbGoTop()

    IF !Empty( cCond )

      dbEval( bExpr, hb_macroBlock( cCond ) )

    ELSE

      dbEval( bExpr )

    ENDIF

    dbGoTo( nRecno )
    Browse_Refresh()

  ENDIF

RETURN lOk


PROCEDURE ModifyTable

  MEMVAR BRW_2

  LOCAL cFileDbf, cMemoExt, nRecno, cFileBak, aStrk := {}, nComp
  LOCAL aStruct, i, ne
  LOCAL nR, nC, nW, nH
  LOCAL aNames := { "Field Name", "Type", "Len", "Dec" }
  LOCAL bOK := {|| _HMG_DialogCancelled := !BRW_2:lHasChanged, aStruct := BRW_2:aArray, DoMethod( 'frmTableChg', 'Release' ) }
  LOCAL bCancel := {||
                   If BRW_2:lHasChanged
                      Tone( 1000, .5 )
                      _HMG_ModalDialogReturn := 2
                      IF HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1
                         _HMG_DialogCancelled := .T.
                         DoMethod( 'frmTableChg', 'Release' )
                      ENDIF
                   Else
                      _HMG_DialogCancelled := .T.
                      DoMethod( 'frmTableChg', 'Release' )
                   EndIf
                   Return Nil
                  }
  LOCAL aTypes := { ;
                 "C" => "Character", ;
                 "N" => "Numeric", ;
                 "I" => "Integer", ;
                 "B" => "Double", ;
                 "D" => "Date", ;
                 "T" => "DateTime", ;
                 "L" => "Logical", ;
                 "M" => "Memo", ;
                 "Y" => "Currency", ;
                 "+" => "AutoInc", ;
                 "=" => "ModTime", ;
                 "^" => "RowVers", ;
                 "@" => "DayTime", ;
                 "V" => "Variant" ;
                }

  aStruct := ( BRW_1:cAlias )->( dbStruct() )
  AEval( aStruct, { |a| a[2] := hb_HGetDef( aTypes, a[2], 'Nil' ) } )
  /* Check if a database is active */
  if Len(aStruct) < 1
     Return
  Endif

  aEval(aStruct ,{|x|aadd(Astrk,x[1])})

  DEFINE WINDOW frmTableChg;
      CLIENTAREA 320,600;
      TITLE "Modifying of the table";
      MODAL NOSIZE

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
         WIDTH  frmTableChg.ClientWidth ;
         HEIGHT frmTableChg.ClientHeight - GetTitleHeight() - GetToolBarHeight( 'TblTools' ) - GetBorderHeight() / 2 ;
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
         :ResetVScroll( .T. )

         :bKeyDown := { |nKey| If( nKey == VK_DELETE, ( BRW_2:Del(), StatusChange( BRW_2:cParentWnd ) ), ;
                               If( nKey == VK_INSERT, AddField( .T., BRW_2:cParentWnd ), Nil ) ) }
         :blDblClick := { || ModifyField() }

         :lHasChanged  := .F.

         :SetNoHoles()
         :SetFocus()

      END TBROWSE

      ON KEY ESCAPE ACTION Eval( bCancel )

  END WINDOW

  CENTER WINDOW frmTableChg
  ACTIVATE WINDOW frmTableChg

  IF !_HMG_DialogCancelled

    cFileDbf := dbInfo( DBI_FULLPATH )
    nRecno := Recno()

    * there is a deleted field?
    FOR EACH nComp IN aStruct
        ne := Ascan( Astrk, nComp[1] )
        IF ne > 0
           HB_ADel( Astrk, ne, .T. )
        ENDIF
    NEXT

    if len( Astrk ) > 0  // Ies found deleted field!
       aeval(Astrk,{|x| Brw_1:DelColumn(x)})
    Endif

    DBCLOSEALL()

    cFileBak := cFileNoExt(cFileDbf)+"_ORIGINAL.dbf"
    FERASE ( cFileBak )
    FRENAME( cFileDbf, cFileBak )

    cMemoExt := iif( MainWin.memo_fpt.Checked, ".fpt", ".dbt" )
    IF FILE( cFileNoExt(cFileDbf)+cMemoExt )
      FERASE ( cFileNoExt(cFileDbf)+"_ORIGINAL"+cMemoExt )
      FRENAME( cFileNoExt(cFileDbf)+cMemoExt, cFileNoExt(cFileDbf)+"_ORIGINAL"+cMemoExt )
    ENDIF

    AEval( aStruct, { |a, i| aStruct[i][2] := iif( Left( a[2], 1 ) == "A", "+", Left( a[2], 1 ) )  } )

    DBCreate( cFileDbf, aStruct, rddSetDefault(),.F.,cFilenoext(cFiledbf) )

    IF __dbApp( cFileBak, , , , , , .F., rddSetDefault() )
      dbGoTo( nRecno )
    ENDIF

    DBCLOSEALL()

    opentable( cFileDbf )

    nR := BRW_1:nTop
    nC := BRW_1:nLeft
    nW := BRW_1:nRight - nC + 1
    nH := BRW_1:nBottom - nR + 1
    DoEvents()
    _ReleaseControl( "BRW_1", "MainWin" )
    DoEvents()

    CreateBrowse( "BRW_1", nR, nC, nW, nH )

    ClearFilter()
    Browse_Refresh()

    if used()
       FERASE ( cFileBak )
       FERASE ( cFileNoExt(cFileDbf)+"_ORIGINAL"+cMemoExt )
    Endif

  ENDIF

RETURN


PROCEDURE ModifyColumn

  LOCAL lChanges := .F.
  LOCAL nColumn := BRW_1:nCell
  LOCAL aStruct, cField, cType, nLen, nDec
  LOCAL nType
  LOCAL aTypes := { ;
                 "Character", ;
                 "Memo", ;
                 "Numeric", ;
                 "Date", ;
                 "Logical", ;
                 "AutoInc" ;
                }

  aStruct := ( BRW_1:cAlias )->( dbStruct() )
  cField  := aStruct[ nColumn ][ DBS_NAME ]
  cType   := aStruct[ nColumn ][ DBS_TYPE ]
  nLen    := aStruct[ nColumn ][ DBS_LEN ]
  nDec    := aStruct[ nColumn ][ DBS_DEC ]
  nType   := AScan( aTypes, cType )
  IF Empty( nType )
    nType := 6
  ENDIF

  DEFINE WINDOW ColumnChg;
      CLIENTAREA 335,100;
      TITLE "Modification of a column properties";
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
          ONCHANGE  ( lChanges := .T., cField := AllTrim( ColumnChg.edtFld.Value ) )
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
                    iif( cType == "A", cType := "+", NIL ), OnTypeChange( This.Value, ThisWindow.Name ) )
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
          ACTION    iif( lChanges, ( Tone( 1000, .5 ), ;
                    iif( HMG_Alert( "Do you want to modify the structure of the table?", {"Co&nfirm","&Cancel"} ) == 1, ;
                    ColumnChg( aStruct, nColumn, cField, cType, nLen, nDec ), NIL ) ), ThisWindow.Release )
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

  ColumnChg.edtLen.Enabled := ( nType == 1 .OR. nType == 3 )
  ColumnChg.edtDec.Enabled := ( cType == 'N' )

  CENTER WINDOW ColumnChg
  ACTIVATE WINDOW ColumnChg

RETURN


STATIC PROCEDURE ColumnChg( aStruct, nColumn, cField, cType, nLen, nDec )

  LOCAL cFile, nRecno, i, b, cMemoExt, lNewName := .F.
  LOCAL nR, nC, nW, nH

  IF Empty( nLen )
      ColumnChg.edtLen.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
      ColumnChg.edtLen.BackColor := WHITE
      RETURN
  ENDIF

  ColumnChg.Release
  DoEvents()

  cFile := dbInfo( DBI_FULLPATH )
  nRecno := Recno()
  CLOSE ( BRW_1:cAlias )

  SELECT B
  CREATE A0_MDF
  USE A0_MDF

  FOR i:=1 TO Len(aStruct)
    APPEND BLANK
    IF i == nColumn
      REPLACE FIELD_NAME WITH cField, FIELD_TYPE WITH cType,;
              FIELD_LEN WITH nLen, FIELD_DEC WITH nDec
    ELSE
      REPLACE FIELD_NAME WITH aStruct[i][DBS_NAME], FIELD_TYPE WITH aStruct[i][DBS_TYPE],;
              FIELD_LEN WITH aStruct[i][DBS_LEN], FIELD_DEC WITH aStruct[i][DBS_DEC]
    ENDIF
  NEXT

  CREATE A0_NEW FROM A0_MDF
  USE A0_NEW
  ERASE A0_MDF.DBF

  SELECT A
  USE ( cFile )
  GO TOP

  DO WHILE .NOT. EOF()

    SELECT B
    APPEND BLANK

    FOR i:=1 TO Len(aStruct)

      IF i == nColumn
        IF !( aStruct[i][DBS_NAME] == cField )
          lNewName := .T.
        ENDIF

        IF cType=aStruct[i][DBS_TYPE].AND.nLen=aStruct[i][DBS_LEN].AND.nDec=aStruct[i][DBS_DEC]
          Fieldput( i, A->( Fieldget(i) ) )
        ELSE
          DO CASE
             CASE cType="N".AND.aStruct[i][DBS_TYPE]="C"
               b := &("{|param|VAL(param)}")
             CASE cType="C".AND.aStruct[i][DBS_TYPE]="N"
               b := &("{|param|LTRIM(STR(param,"+LTRIM(STR(aStruct[i][DBS_LEN],3))+","+LTRIM(STR(aStruct[i][DBS_DEC],2))+"))}")
             OTHERWISE
               b := &("{|param|param}")
          ENDCASE
          Fieldput( i, Eval( b, A->( Fieldget(i) ) ) )
        ENDIF
      ELSE
        Fieldput( i, A->( Fieldget(i) ) )
      ENDIF

    NEXT

    SELECT A
    SKIP

  ENDDO
  USE

  SELECT B
  USE

  IF FILE( cFileNoExt(cFile)+".bak" )
     ERASE ( cFileNoExt(cFile)+".bak" )
  ENDIF
  FRENAME(cFile,cFileNoExt(cFile)+".bak")
  FRENAME("A0_NEW.DBF",cFile)
  cMemoExt := iif( MainWin.memo_fpt.Checked, ".fpt", ".dbt" )
  IF FILE( cFileNoExt(cFile)+cMemoExt )
     ERASE ( cFileNoExt(cFile)+".bk2" )
     FRENAME(cFileNoExt(cFile)+cMemoExt,cFileNoExt(cFile)+".bk2")
     FRENAME("A0_NEW"+cMemoExt,cFileNoExt(cFile)+cMemoExt)
  ENDIF

  IF lNewName

    nR := BRW_1:nTop
    nC := BRW_1:nLeft
    nW := BRW_1:nRight - nC + 1
    nH := BRW_1:nBottom - nR + 1

    OpenTable( cFileNoExt(cFile)+".bak" )
    _ReleaseControl( "BRW_1", "MainWin" )
    DoEvents()
    CLOSE ( BRW_1:cAlias )

    OpenTable( cFile )
    dbGoTo( nRecno )

    CreateBrowse( "BRW_1", nR, nC, nW, nH )

  ELSE

    OpenTable( cFile )
    dbGoTo( nRecno )

    ClearFilter()
    Browse_Refresh()

  ENDIF

  If used()
     FERASE ( cFileNoExt(cFile)+".bk2" )
     FERASE ( cFileNoExt(cFile)+".bak" )
  Endif

RETURN


/* eof dbuedit.prg */
