/***
*
*  Dbuview.prg
*
*  DBU View Maintenance Module
*
*/

#include "minigui.ch"
#include "tsbrowse.ch" 
#include "dbstruct.ch"

Memvar BRW_1
Memvar cFilter
Memvar cOrder

DECLARE WINDOW MainWin

STATIC cValue := "", nFieldPos := 0


FUNCTION Browse_GotoFirstCol()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  REPEAT
    oBrw:PanLeft()
  UNTIL oBrw:nCell > 1
  oBrw:SetFocus()

Return NIL


FUNCTION Browse_GotoLastCol()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  REPEAT
    oBrw:PanRight()
  UNTIL oBrw:nCell < Len( oBrw:aColumns )
  oBrw:SetFocus()

Return NIL


PROCEDURE AddRecord()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )

  IF _GetFocusedControl( "MainWin" ) == "BRW_1"

    APPEND BLANK

    oBrw:GoToRec( ( oBrw:cAlias )->( RecNo() ), .T. )
    oBrw:SetFocus()

  ENDIF

RETURN


PROCEDURE DuplicateRec()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )
  LOCAL aBuffer := Scatter()

  INSERT BEFORE

  Gather( aBuffer )

  oBrw:GoToRec( ( oBrw:cAlias )->( RecNo() ) )
  oBrw:SetFocus()

RETURN


PROCEDURE GoToRecord()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )
  LOCAL nValue

  nValue := PropertyInputBox ( 'RecNo:', "Go To Record", 0, 1 )

  IF !_HMG_DialogCancelled .AND. nValue > 0

    oBrw:GoToRec( nValue, .T. )
    oBrw:SetFocus()

  ENDIF

RETURN


PROCEDURE ColumnSeek()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )
  LOCAL aStruct

  IF !Used()
     RETURN
  ENDIF

  cValue := PropertyInputBox ( 'Column Name:', "Seek Column", cValue, 2 )

  IF !_HMG_DialogCancelled .AND. !Empty( cValue )

    aStruct := ( oBrw:cAlias )->( dbStruct() )
    nFieldPos := AScan( aStruct, { |x| cValue $ x[DBS_NAME] } )

    IF nFieldPos > 0

      oBrw:GoPos( oBrw:nRowPos, nFieldPos )
      oBrw:SetFocus()

    ELSE

      HMG_Alert( "Column " + cValue + " is not found.", , , ICON_INFORMATION )
      cValue := ""

    ENDIF

  ENDIF

RETURN


PROCEDURE ContinueSeek()

  LOCAL oBrw := GetBrowseObj( "BRW_1", "MainWin" )
  LOCAL aStruct
  LOCAL nPos := -1

  IF !Used()
     RETURN
  ENDIF

  IF Empty( cValue )

     cValue := PropertyInputBox ( 'Column Name:', "Seek Column", cValue, 2 )

  ENDIF

  IF !_HMG_DialogCancelled .AND. !Empty( cValue )

    aStruct := ( oBrw:cAlias )->( dbStruct() )

    WHILE nPos < nFieldPos

      IF nFieldPos > 0 .AND. !Empty( aStruct[ nFieldPos ][ 1 ] )
        aStruct[ nFieldPos ] := { "" }
      ENDIF

      nPos := AScan( aStruct, { |x| cValue $ x[ DBS_NAME ] } )

      IF nPos == 0
        EXIT
      ENDIF

      IF nPos < nFieldPos
        aStruct[ nPos ] := { "" }
      ENDIF

    END

    nFieldPos := nPos

    IF nPos > 0

      oBrw:GoPos( oBrw:nRowPos, nPos )
      oBrw:SetFocus()

    ELSE

      HMG_Alert( "Column " + cValue + " is not found.", , , ICON_INFORMATION )
      cValue := ""

    ENDIF

  ENDIF

RETURN


PROCEDURE ColumnVis

  MEMVAR BRW_2

  LOCAL aStruct, i
  LOCAL aNames := { "Field Name", "Type", "Len", "Dec", "" }
  LOCAL bOK := {|| _HMG_DialogCancelled := !BRW_2:lHasChanged, DoMethod( 'ColumnVis', 'Release' ) }
  LOCAL bCancel := {||
                   If BRW_2:lHasChanged
                      Tone( 1000, .5 )
                      _HMG_ModalDialogReturn := 2
                      IF HMG_Alert( "Do you want to discard the changes?", {"Co&nfirm","&Cancel"} ) == 1
                         _HMG_DialogCancelled := .T.
                         DoMethod( 'ColumnVis', 'Release' )
                      ENDIF
                   Else
                      _HMG_DialogCancelled := .T.
                      DoMethod( 'ColumnVis', 'Release' )
                   EndIf
                   Return Nil
                  }
  LOCAL bAll := { || AEval( aStruct, { |a| a[ 5 ] := .T. } ), BRW_2:lHasChanged := .T., BRW_2:Refresh( .F. ) }
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
  IF Empty( aStruct )
    RETURN
  ENDIF
  AEval( aStruct, { |a| AAdd( a, .F. ), a[2] := hb_HGetDef( aTypes, a[2], 'Nil' ) } )

  DEFINE WINDOW ColumnVis;
      CLIENTAREA 340,600;
      TITLE "Visibility of the columns";
      MODAL NOSIZE

      Define Toolbar visTools ButtonSize 16, 16 FLAT
        Button btnOK    Picture 'OK'      Action Eval( bOK )  Tooltip 'Confirm'
        Button btnExit  Picture 'CANCEL'  Action Eval( bCancel )  Tooltip 'Cancel'  Separator
        Button btnAll   Picture 'ALL'     Action Eval( bAll )  Tooltip 'All'
      End Toolbar

      DEFINE STATUSBAR
      END STATUSBAR

      DEFINE TBROWSE BRW_2 ;
         AT GetToolBarHeight( 'visTools' ) + GetBorderHeight() / 2, 0 ;
         WIDTH  ColumnVis.ClientWidth ;
         HEIGHT ColumnVis.ClientHeight - GetTitleHeight() - GetToolBarHeight( 'visTools' ) - GetBorderHeight() / 2 ;
         GRID ;
         ON CHANGE { || StatusChange() }

         :SetArray( aStruct, .T. )

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

         :aColumns[ 5 ]:lEdit := .T.
         :aColumns[ 5 ]:lCheckBox := .T.
         :aColumns[ 5 ]:aCheck := { LoadBitmap( "SELECT" ), LoadBitmap( "NOSELECT" ) }

         :aColumns[ 5 ]:bLClicked := { |p1,p2,p3,o| p1 := aStruct[o:nAt][5], ;
                                     aStruct[o:nAt][5] := !p1, p2 := NIL, p3 := NIL, o:lHasChanged := .T., o:DrawSelect() }

         :aColumns[ 5 ]:nEditMove := DT_MOVE_DOWN
         :UserKeys(VK_SPACE, {|ob|
                             Local lRet
                             If ob:nCell == 5
                                ob:lHasChanged := .T.
                                ob:DrawSelect()
                                lRet := .F.
                             EndIf
                             Return lRet
                           })

         For i := 1 To Len(aStruct[ DBS_NAME ])
           :aColumns[ i ]:cHeading := aNames[ i ]
           :aColumns[ i ]:bLostFocus := { || StatusChange() }
           If i > 2
             :aColumns[ i ]:nHAlign := DT_RIGHT
             :aColumns[ i ]:nAlign  := DT_RIGHT
           Else
             :aColumns[ i ]:nHAlign := DT_LEFT
           EndIf

           :AdjColumns( i )
           If i < 5
             :SetColSize( i, :aColumns[ i ]:nWidth + iif( :aColumns[ i ]:cDataType == "C", 24, -20 ) )
           Else
             :SetColSize( i, :aColumns[ i ]:nWidth / 2 )
           EndIf
         Next

         :ResetVScroll( .T. )
         :GoPos( 1, 5 )

      END TBROWSE

      ON KEY ESCAPE ACTION Eval( bCancel )

  END WINDOW

  CENTER WINDOW ColumnVis
  ACTIVATE WINDOW ColumnVis

  IF !_HMG_DialogCancelled

     For i := 1 To Len(aStruct)

       BRW_1:HideColumns( i, !aStruct[i][5] )

     Next

  ENDIF

RETURN


STATIC PROCEDURE StatusChange()

  MEMVAR BRW_2

  LOCAL cMsg := 'Field ' + hb_ntos(BRW_2:nAt) + "/" + hb_ntos(BRW_2:nLen)

  ColumnVis.StatusBar.Item( 1 ) := cMsg

  AEval( BRW_2:aColumns, { |o| o:cMsg := cMsg } )

RETURN


PROCEDURE ordFilter()

  STATIC cCond, cOrdKey, lUnique := .F.

  IF !Used()
     RETURN
  ENDIF

  DEFINE WINDOW frmFilter;
      CLIENTAREA 535,210;
      TITLE "Set a filter";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION frmFilter.Release

      DEFINE LABEL lblCond
          ROW       15
          COL       15
          VALUE     "Filter condition:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtCond
          ROW       35
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     iif( ISCHARACTER( cCond ), cCond, "" )
          ONCHANGE  cCond := AllTrim( frmFilter.edtCond.Value )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE LABEL lblOrd
          ROW       110
          COL       15
          VALUE     "Ordered by:"
          AUTOSIZE .T.
      END LABEL

      DEFINE EDITBOX edtOrd
          ROW       130
          COL       15
          WIDTH     410
          HEIGHT    65
          VALUE     iif( ISCHARACTER( cOrdKey ), cOrdKey, "" )
          ONCHANGE  ( cOrdKey := AllTrim( frmFilter.edtOrd.Value ), frmFilter.chkUnique.Enabled := !Empty( cOrdKey ) )
          NOHSCROLLBAR .T.
      END EDITBOX

      DEFINE BUTTON SetFilter
          ROW       35
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   'Co&nfirm'
          ACTION    SetNewFilter( cCond, cOrdKey, lUnique )
      END BUTTON

      DEFINE BUTTON Cancel
          ROW       65
          COL       450
          WIDTH     70
          HEIGHT    23
          CAPTION   '&Cancel'
          ACTION    ThisWindow.Release
      END BUTTON

      DEFINE CHECKBOX chkUnique
          ROW       130
          COL       450
          CAPTION   'Unique'
          VALUE     lUnique
          ONCHANGE  lUnique := frmFilter.chkUnique.Value
          LEFTJUSTIFY .T.
          AUTOSIZE .T.
      END CHECKBOX

  END WINDOW

  frmFilter.chkUnique.Enabled := !Empty( cOrdKey )

  CENTER WINDOW frmFilter
  ACTIVATE WINDOW frmFilter

RETURN


STATIC FUNCTION SetNewFilter( cCond, cOrdKey, lUnique )

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
      frmFilter.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
      frmFilter.edtCond.BackColor := WHITE
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
      frmFilter.edtCond.BackColor := RED
      Tone( 1000, .5 )
      HMG_Alert( "It should be a logical value.", , , ICON_INFORMATION )
      frmFilter.edtCond.BackColor := WHITE
      RETURN lOk
    ENDIF

    IF !Empty( cOrdKey )
      bOldErr := ErrorBlock({|e| Break(e) })
      BEGIN SEQUENCE
        &cOrdKey
      RECOVER
        lOk := .F.
        frmFilter.edtOrd.BackColor := RED
        Tone( 1000, .5 )
        HMG_Alert( "A key no valid.", , , ICON_INFORMATION )
        frmFilter.edtOrd.BackColor := WHITE
      END SEQUENCE
      ErrorBlock( bOldErr )
    ENDIF

    IF !lOk
      RETURN lOk
    ENDIF

    ordListClear()

    ordCondSet( cCond, hb_macroBlock( cCond ), .T. /*All*/, , , , RecNo(), , , , , , , , , , , .T. /*Memory*/ )

    cIndexName := 'Memory'
    cTag := 't' + DTOS( Date() ) + Left( Right( Time(), 4 ), 1 )

    IF Empty( cOrdKey )
      cOrdKey := "RECNO()"
    ELSE
      cOrder := cOrdKey
    ENDIF

    ThisWindow.Release
    DoEvents()

    ordCreate( cIndexName, cTag, cOrdKey, hb_macroBlock( cOrdKey ), lUnique )
    ordListAdd( cIndexName )
    ordSetFocus( OrdCount() )

    IF ordKeyCount() > 0
      MainWin.fnew_tag.Enabled := .T.
      MainWin.fsel_tag.Enabled := .T.
      MainWin.new_tag.Enabled := .T.
      MainWin.sel_tag.Enabled := .T.
    ENDIF

    cFilter := cCond
    dbSetFilter( hb_macroBlock( cFilter ), cFilter )

    BRW_1:bFilter := hb_macroBlock( cFilter )
    BRW_1:lInitGoTop := .T.
    BRW_1:Reset()
    BRW_1:uLastTag := ordNumber()

  ELSE

    lOk := .F.
    frmFilter.edtCond.BackColor := RED
    Tone( 1000, .5 )
    HMG_Alert( "A field no valid.", , , ICON_INFORMATION )
    frmFilter.edtCond.BackColor := WHITE
    frmFilter.edtCond.SetFocus

  ENDIF

RETURN lOk


PROCEDURE ClearFilter()

  IF !Empty( cFilter )

    ordSetFocus( 0 )
    ordListClear()
    MainWin.fnew_tag.Enabled := .F.
    MainWin.fsel_tag.Enabled := .F.
    MainWin.sel_tag.Enabled := .F.
    MainWin.new_tag.Enabled := .F.

    DbClearFilter()
    cFilter := ""
    cOrder := ""

    BRW_1:bFilter := NIL
    BRW_1:lInitGoTop := .F.
    BRW_1:Reset()
    BRW_1:uLastTag := 0

  ENDIF

RETURN


/* eof dbuview.prg */
