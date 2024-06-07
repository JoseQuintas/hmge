/*---------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code
---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "TSBrowse.ch"
#include "hbcompat.ch"

// ============================================================================
// FUNCTION SBrowse() Version 9.0 Nov/30/2009
// ============================================================================

FUNCTION SBrowse( uAlias, cTitle, bSetUp, aCols, nWidth, nHeight, lSql, lModal, lNumber, lCenter )

   LOCAL cFormName, oBrw, nSaveSelect, cDbf, cAlias, lEdit, cTable
   LOCAL lbSetUp := ! Empty( bSetUp ), lRec, nY, nX, bAfter, lCellBrw := .F.
   LOCAL oApp := oDlu4Font( _HMG_DefaultFontSize )
   LOCAL nGw := oApp:GapsWidth
   LOCAL nGh := oApp:GapsHeight
   LOCAL uParam, bRecord, nClr, oCol, nWrec, nHrec
   LOCAL aWinType := { "M", "C", "S" }, nWinType, cWinType

   IF HB_ISARRAY( nWidth )
      nWrec := nWidth[ 2 ]
      nWidth := nWidth[ 1 ]
   ENDIF

   IF HB_ISARRAY( nHeight )
      nHrec := nHeight[ 2 ]
      nHeight := nHeight[ 1 ]
   ENDIF

   IF HB_ISARRAY( cTitle )
      uParam := cTitle[ 2 ]
      cTitle := cTitle[ 1 ]
   ENDIF

   IF HB_ISARRAY( bSetUp )
      bRecord := iif( Len( bSetUp ) > 2, bSetUp[ 3 ], NIL )
      bAfter := bSetUp[ 2 ]
      bSetUp := bSetUp[ 1 ]
   ENDIF

   IF HB_ISLOGICAL( bSetUp )
      lCellBrw := bSetUp
      bSetUp := NIL
   ENDIF

   DEFAULT uAlias := Alias(), ;
      cTitle := iif( ValType( uAlias ) == "C", uAlias, "SBrowse" ), ;
      bSetUp := {|| .F. }, ;
      aCols := {}, ;
      nWidth := GetSysMetrics( 0 ) * .75, ;
      nHeight := GetSysMetrics( 1 ) / 2, ;
      lSql := .F., ;
      lModal := .F., ;
      lCenter := .T.

   SWITCH ValType( lModal )
   CASE 'L'
      nWinType := iif( lModal, 1, 2 )
      EXIT
   CASE 'N'
      nWinType := iif( lModal > Len( aWinType ), Len( aWinType ), lModal )
      EXIT
   CASE 'C'
      lModal := Upper( Left( lModal, 1 ) )
      nWinType := AScan( aWinType, lModal )
      nWinType := iif( nWinType == 0, 2, nWinType )
      EXIT
   DEFAULT
      nWinType := 2
   END
   cWinType := aWinType[ nWinType ]
   lModal := ( cWinType == "M" )

   IF ValType( uAlias ) == 'C' .AND. Select( uAlias ) == 0
      nSaveSelect := Select()
      IF lSql
         cTable := HMG_GetUniqueName( "SqlTable" )

         dbUseArea( .T.,, "SELECT * FROM " + uAlias, cTable,,, "UTF8" )
         SELECT &cTable

         cAlias := cTable
         uAlias := cAlias
      ELSE

         cDbf := uAlias
         cAlias := uAlias
         TRY
            dbUseArea( .T., NIL, cDbf, cAlias, .T. )
            uAlias := cAlias
         CATCH
            uAlias := { { uAlias } }
         END
      ENDIF

   ELSEIF ValType( uAlias ) == 'N'
      If ! Empty( Alias( uAlias ) )
         uAlias := Alias( uAlias )
      ELSE
         uAlias := { { uAlias } }
      ENDIF

   ELSEIF ValType( uAlias ) $ 'BDLP'
      uAlias := { { uAlias } }

#ifdef __XHARBOUR__
   ELSEIF ValType( uAlias ) == "H"
      uAlias := aHash2Array( uAlias )

#endif
   ENDIF

   cFormName := HMG_GetUniqueName( "SBrowse" )

   lRec := HB_ISARRAY( uAlias ) .AND. ;
      Len( uAlias[ 1 ] ) == 2 .AND. Len( aCols ) == 2 .AND. ;
      aCols[ 1 ] == "Key" .AND. aCols[ 2 ] == "Value"

   IF lRec .OR. lModal
      _HMG_InplaceParentHandle := GetActiveWindow()

      IF lRec
         nWidth *= .67
      ENDIF
      DEFINE WINDOW &cFormName AT 0, 0 WIDTH nWidth HEIGHT nHeight TITLE cTitle ;
         MODAL ;
         BACKCOLOR RGB( 191, 219, 255 )

   ELSEIF cWinType == 'S'
      DEFINE WINDOW &cFormName AT 0, 0 WIDTH nWidth HEIGHT nHeight TITLE cTitle ;
         WINDOWTYPE STANDARD TOPMOST ;
         BACKCOLOR RGB( 191, 219, 255 ) ;
         ON INIT {|| This.Topmost := .F. }

   ELSE
      DEFINE WINDOW &cFormName AT 0, 0 WIDTH nWidth HEIGHT nHeight TITLE cTitle ;
         CHILD TOPMOST ;
         BACKCOLOR RGB( 191, 219, 255 ) ;
         ON INIT {|| This.Topmost := .F. }

   ENDIF

   This.Cargo := uParam

   nY := nGh
   nX := nGw

   nWidth := This.ClientWidth - nX * 2
   nHeight := This.ClientHeight - nY * 2 - oApp:H1 - nGh

   DEFINE TBROWSE oBrw AT nY, nX Alias ( uAlias ) WIDTH nWidth HEIGHT nHeight HEADER aCols ;
         AUTOCOLS SELECTOR 20 ;
         ON INIT {| ob | ob:nColOrder := 0, ;
         ob:lNoGrayBar := .F., ;
         ob:lNoLiteBar := .F., ;
         ob:lNoResetPos := .F., ;
         ob:nStatusItem := 0, ;
         ob:lNoKeyChar := .T., ;
         ob:nWheelLines := 1, ;
         ob:nCellMarginLR := 1, ;
         ob:nLineStyle := LINES_ALL, ;
         ob:nClrLine := COLOR_GRID, ;
         ob:lCheckBoxAllReturn := .T. }

      oBrw:Cargo := uParam

      lEdit := Eval( bSetUp, oBrw )
      lEdit := iif( ValType( lEdit ) == "L", lEdit, .F. )

      WITH OBJECT oBrw
         :lEditable := lEdit
         :lCellBrw := ( lEdit .OR. lCellBrw )
         :lUpdate := .T.
         :bRClicked := {|| _SetThisFormInfo( oBrw:cParentWnd ), ;
            SBrowse_Record( oBrw, , bRecord, , nWrec, nHrec ), ;
            _SetThisFormInfo() }
         :lRecLockArea := .T.
         IF lEdit
            AEval( :aColumns, {| o | o:lEdit := !( o:cFieldTyp $ "+=^" ) } )
         ENDIF
         nClr := :GetColumn( 1 ):nClrHeadBack
         IF lRec
            :lNoHScroll := .T.
         ELSEIF ! Empty( lNumber )
            :lFooting := .T.
            :lDrawFooters := .T.
            :nHeightFoot := :nHeightHead
            :InsColNumber()
            :GetColumn( "ORDKEYNO" ):cFooting := hb_ntos( :nLen )
            :nFreeze := :nColumn( "ORDKEYNO" )
            :nCell := :nFreeze + 1
            :lLockFreeze := .T.
         ENDIF
      END WITH

   END TBROWSE

   IF oBrw:nColumn( "ORDKEYNO", .T. ) > 0
      oBrw:GetColumn( "SELECTOR" ):nClrBack := nClr
      oBrw:GetColumn( "ORDKEYNO" ):nClrHeadBack := nClr
      oBrw:GetColumn( "ORDKEYNO" ):nClrFocuBack := oBrw:nClrPane
   ENDIF

   nY := This.ClientHeight - nGh - oApp:H1
   nX := nGw

   @ nY, nX BUTTON Btn_1 CAPTION oBrw:aMsg[ 44 ] WIDTH oApp:W1 HEIGHT oApp:H1 ;
      ACTION {|| oBrw:Report( cTitle,,,, .T. ), oBrw:GoTop() }

   nX += oApp:W1 + nGw

   @ nY, nX BUTTON Btn_2 CAPTION "Excel" WIDTH oApp:W1 HEIGHT oApp:H1 ;
      ACTION oBrw:ExcelOle()

   nX := This.ClientWidth - ( oApp:W1 + nGw )

   @ nY, nX BUTTON Btn_3 CAPTION oBrw:aMsg[ 45 ] WIDTH oApp:W1 HEIGHT oApp:H1 ;
      ACTION {|| iif( oBrw:IsEdit, oBrw:SetFocus(), ThisWindow.RELEASE ) }

   ON KEY ESCAPE ACTION {|| iif( oBrw:IsEdit, oBrw:SetFocus(), ThisWindow.RELEASE ) }

   IF lRec
      nY := Len( oBrw:aColumns )
      oBrw:aColumns[ nY - 1 ]:nWidth += 50
      oBrw:aColumns[ nY - 1 ]:cName := "KEY"
      oBrw:aColumns[ nY - 1 ]:lEdit := .F.
      oBrw:aColumns[ nY ]:lEdit := .F.
      oBrw:aColumns[ nY ]:cName := "VALUE"
      oBrw:lPickerMode := .T.
      FOR EACH oCol IN oBrw:aColumns
         oCol:cPicture := NIL
         oCol:nAlign := iif( oCol:cName == "KEY", DT_CENTER, DT_LEFT )
      NEXT
      oBrw:AdjColumns( nY )
      IF HB_ISOBJECT( oBrw:Cargo ) .AND. oBrw:ClassName == "TSBROWSE" .AND. oBrw:Cargo:lIsDbf
         oBrw:Cargo:lRecLockArea := .T.
         oCol := oBrw:GetColumn( "VALUE" )
         oCol:lEdit := .T.
         oCol:bPrevEdit := ;
            < | uv, obr |
         LOCAL lRet := .T., cn, oc, ob, xv
         LOCAL oDlu := oDlu4Font( _HMG_DefaultFontSize )
         LOCAL nLen := oDlu:W( 1.5 )
         cn := obr:GetValue( "KEY" )
         xv := obr:GetValue( "VALUE" )
         obr:GetColumn( "VALUE" ):Cargo := NIL
         ob := obr:Cargo
         IF ! HB_ISOBJECT( ob ) .OR. ! ob:lIsDbf
            RETURN .F.
         ENDIF
         oc := ob:GetColumn( cn )
         IF Empty( oc:cFieldTyp ) .OR. oc:cName == "SELECTOR" .OR. oc:cName == "ORDKEYNO"
            lRet := .F.
         ELSEIF oc:cFieldTyp $ "T=@+^"
            lRet := .F.
         ENDIF
         IF lRet
            IF ValType( xv ) $ "DNL"
               obr:GetColumn( "VALUE" ):nEditWidth := nLen
            ENDIF
            obr:GetColumn( "VALUE" ):Cargo := uv
         ENDIF
         RETURN lRet
         >
         oCol:bPostEdit := ;
            < | uv, obr |
         LOCAL cn, oc, ob, uo, nm
         cn := obr:GetValue( obr:nColumn( "KEY" ) )
         uo := obr:GetColumn( "VALUE" ):Cargo
         obr:GetColumn( "VALUE" ):nEditWidth := 0
         IF uo != NIL .AND. uo == uv
            RETURN NIL
         ENDIF
         ob := obr:Cargo
         IF ! HB_ISOBJECT( ob ) .OR. ! ob:lIsDbf
            RETURN NIL
         ENDIF
         oc := ob:GetColumn( cn )
         nm := oc:nEditMove
         oc:nEditMove := 0
         ob:PostEdit( uv, ob:nColumn( oc:cName ) )
         oc:nEditMove := nm
         RETURN NIL
         >
      ENDIF
   ENDIF

   IF ! lbSetUp .OR. lRec
      oBrw:SetNoHoles()
      oBrw:SetFocus()
      IF lRec
         oBrw:GoRight()
      ENDIF
   ENDIF

   IF HB_ISBLOCK( bAfter ) ; Eval( bAfter, oBrw, .T. )
   ELSE ; Eval( bSetUp, oBrw, .T. )
   ENDIF

   END WINDOW

   IF lCenter
      CENTER WINDOW &cFormName
   ENDIF
   ACTIVATE WINDOW &cFormName

   _HMG_InplaceParentHandle := 0

   IF ! Empty( cAlias )
      ( cAlias )->( dbCloseArea() )
   ENDIF

   IF ! Empty( nSaveSelect )
      Select( nSaveSelect )
   ENDIF

RETURN NIL

// --------------------------------------------------------------------------------------------------------------------//

FUNCTION SBrowse_Record( oBrw, cTitle, bSetUp, aHead, nWidth, nHeight, lNoCrLf, lModal )

   LOCAL oCol, aArr := {}, cHdr
   DEFAULT cTitle := "Record View", bSetUp := .T., aHead := { "Key", "Value" }, lNoCrLf := .F.

   FOR EACH oCol IN oBrw:aColumns
      IF oCol:cName == "SELECTOR" ; LOOP
      ENDIF
      cHdr := oCol:cHeading
      IF lNoCrLf .AND. CRLF $ cHdr
         cHdr := StrTran( cHdr, CRLF, " " )
      ENDIF
      AAdd( aArr, { cHdr, oBrw:GetValue( oCol ) } )
   NEXT

   SBrowse( aArr, { cTitle, oBrw }, bSetUp, aHead, nWidth, nHeight, , lModal )

RETURN NIL

// ============================================================================
// FUNCTION _TBrowse()  by SergKis
// ============================================================================

FUNCTION _TBrowse( oParam, uAlias, cBrw, nY, nX, nW, nH )

   LOCAL oBrw, aTmp, aBrush, aHead, aField, aFoot, aColor
   LOCAL cForm := _HMG_ThisFormName, lSpecHd, bInit, bEnd
   LOCAL hForm := GetFormHandle( cForm )
   LOCAL i, j

   DEFAULT oParam := oHmgData()

   DEFAULT cBrw := oParam:cBrw, uAlias := oParam:uAlias
   DEFAULT cBrw := "oBrw", uAlias := Alias()
   DEFAULT nY := oParam:nRow, nX := oParam:nCol, nW := oParam:nWidth, nH := oParam:nHeight
   DEFAULT nY := oParam:nY, nX := oParam:nX, nW := oParam:nW, nH := oParam:nH
   DEFAULT lSpecHd := oParam:lSpecHd
   DEFAULT lSpecHd := oParam:lSpecHeader
   DEFAULT lSpecHd := oParam:lDrawSpecHd
   DEFAULT lSpecHd := .F.

   IF HB_ISCHAR( uAlias ) ; dbSelectArea( uAlias )
   ENDIF

   IF HB_ISARRAY( oParam:aFont )
      IF Len( oParam:aFont ) < 5
         ASize( oParam:aFont, 5 )
      ENDIF
      FOR i := 1 TO Len( oParam:aFont )
         IF Empty( oParam:aFont ) ; oParam:aFont[ i ] := oParam:aFont[ 1 ]
         ENDIF
      NEXT
   ELSE
      IF Empty( GetFontHandle( "Normal" ) )
         DEFINE FONT Normal FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize
      ENDIF
      IF Empty( GetFontHandle( "Bold" ) )
         DEFINE FONT BOLD FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize BOLD
      ENDIF
      IF Empty( GetFontHandle( "Italic" ) )
         DEFINE FONT Italic FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize ITALIC
      ENDIF
      oParam:aFont := { "Normal", "Bold", "Bold", "Italic", "Bold" }
   ENDIF

   IF _IsControlDefined( cBrw, cForm )
      i := 0
      WHILE _IsControlDefined( j := cBrw + "_" + hb_ntos( ++i ), cForm )
      END
      cBrw := j
   ENDIF

   bInit := oParam:bInit
   bEnd := oParam:bEnd
   aBrush := oParam:aBrush
   aColor := oParam:aColor
   aHead := oParam:aHead ; DEFAULT aHead := oParam:aHeader
   aField := oParam:aField ; DEFAULT aField := oParam:aFields
   aFoot := oParam:aFoot ; DEFAULT aFoot := oParam:aFooter

   DEFAULT aFoot := ! Empty( aFoot ), ;
      nY := 0, ;
      nX := 0, ;
      nW := _GetClientRect( hForm )[ 3 ] - nX * 2, ; // GetClientWidth
      nH := _GetClientRect( hForm )[ 4 ] - nY - 1 - ;     // GetClientHeight
      iif( _IsControlDefined( "StatusBar", cForm ), GetProperty( cForm, "StatusBar", "Height" ), 0 )

   DEFAULT aColor := { ;
      { CLR_FOCUSF, GetSysColor( COLOR_WINDOWTEXT ) }, ;
      { CLR_FOCUSB, {| c, n, b | c := n, iif( b:nCell == n, -CLR_HRED, -RGB( 128, 225, 225 ) ) } }, ;
      { CLR_SELEF, GetSysColor( COLOR_WINDOWTEXT ) }, ;
      { CLR_SELEB, {| c, n, b | c := n, iif( b:nCell == n, -CLR_BLUE, -RGB( 128, 225, 225 ) ) } } }

#ifndef __XHARBOUR__
   DEFAULT oParam:bSpecHdEnum := {|ob, op, cChar|  // ��������� SpecHd �������, ����� ���. � ����� ���� �����
        LOCAL oCol, cCnt, nCnt := 0  // renumbering SpecHeader
        IF ob:lDrawSpecHd
         DEFAULT cChar := op:cSpecHdChar
         DEFAULT cChar := "."
         FOR EACH oCol IN ob:aColumns
           IF oCol:cName == "SELECTOR" ; LOOP
           ENDIF
           cCnt := cChar
           IF oCol:cName != "ORDKEYNO" .AND. oCol:lVisible
            cCnt := hb_ntos( ++nCnt )
           ENDIF
           oCol:cSpcHeading := cCnt
         NEXT
        ENDIF
        RETURN Nil
        }

   DEFAULT oParam:bAdjColumns := {|ob|     // "������������" ������� � �������� ���� ���
        LOCAL aCol, nI, nK
        // � SELECTOR and ORDKEYNO �� ������ width
        nK := Max( ob:nColumn( "SELECTOR", .T. ), ob:nColumn( "ORDKEYNO", .T. ) )
        IF nK > 0
         aCol := {}
         FOR nI := nK TO Len( ob:aColumns )
           IF ob:aColumns[ nI ]:lVisible
            AAdd( aCol, nI )
           ENDIF
         NEXT
        ENDIF
        ob:AdjColumns( aCol )
        RETURN Nil
        }

   DEFAULT bEnd  := {|ob, op|
        // ��� ��������������� HScroll � ���� SELECTOR
        IF op:uSelector != NIL .AND. op:lAdjust == NIL .AND. ob:lNoHScroll
         IF HB_ISBLOCK( op:bAdjColumns )
          EVal( op:bAdjColumns, ob, op )  // :AdjColumns(...)
         ENDIF
        ENDIF
        IF ob:nLen > ob:nRowCount()     // ����� VScroll
         ob:ResetVScroll( .T. )
        ENDIF
        ob:SetNoHoles()
        ob:SetFocus()
        RETURN Nil
        }
#else
   DEFAULT oParam:bSpecHdEnum := <|ob, op, cChar|  // ��������� SpecHd �������, ����� ���. � ����� ���� �����
        LOCAL oCol, cCnt, nCnt := 0  // renumbering SpecHeader
        IF ob:lDrawSpecHd
         DEFAULT cChar := op:cSpecHdChar
         DEFAULT cChar := "."
         FOR EACH oCol IN ob:aColumns
           IF oCol:cName == "SELECTOR" ; LOOP
           ENDIF
           cCnt := cChar
           IF oCol:cName != "ORDKEYNO" .AND. oCol:lVisible
            cCnt := hb_ntos( ++nCnt )
           ENDIF
           oCol:cSpcHeading := cCnt
         NEXT
        ENDIF
        RETURN Nil
        >

   DEFAULT oParam:bAdjColumns := <|ob|     // "������������" ������� � �������� ���� ���
        LOCAL aCol, nI, nK
        // � SELECTOR and ORDKEYNO �� ������ width
        nK := Max( ob:nColumn( "SELECTOR", .T. ), ob:nColumn( "ORDKEYNO", .T. ) )
        IF nK > 0
         aCol := {}
         FOR nI := nK TO Len( ob:aColumns )
           IF ob:aColumns[ nI ]:lVisible
            AAdd( aCol, nI )
           ENDIF
         NEXT
        ENDIF
        ob:AdjColumns( aCol )
        RETURN Nil
        >

   DEFAULT bEnd  := <|ob, op|
        // ��� ��������������� HScroll � ���� SELECTOR
        IF op:uSelector != NIL .AND. op:lAdjust == NIL .AND. ob:lNoHScroll
         IF HB_ISBLOCK( op:bAdjColumns )
          EVal( op:bAdjColumns, ob, op )  // :AdjColumns(...)
         ENDIF
        ENDIF
        IF ob:nLen > ob:nRowCount()     // ����� VScroll
         ob:ResetVScroll( .T. )
        ENDIF
        ob:SetNoHoles()
        ob:SetFocus()
        RETURN Nil
        >
#endif

   DEFINE TBROWSE &cBrw OBJ oBrw AT nY, nX WIDTH nW HEIGHT nH CELL ;
         HEADERS aHead ;
         COLSIZES oParam:aSize ;
         PICTURE oParam:aPict ;
         ALIAS uAlias ;
         JUSTIFY oParam:aAlign ;
         SELECTOR oParam:uSelector ;
         COLUMNS aField ;
         COLNAMES oParam:aName ;
         FOOTERS aFoot ;
         COLNUMBER oParam:aNumber ;
         COLEDIT oParam:aEdit ;
         COLADJUST oParam:lAdjust ;
         VALUE oParam:nValue ;
         FONT oParam:aFont ;
         TOOLTIP oParam:cToolTip ;
         BACKCOLOR oParam:aBColor ;
         FONTCOLOR oParam:aFColor ;
         ON GOTFOCUS oParam:bOnGotFocus ;
         ON CHANGE oParam:bOnChange ;
         ON LOSTFOCUS oParam:bOnLostFocus ;
         ON DBLCLICK oParam:bOnDblClick ;
         COLORS aColor ;
         BRUSH aBrush ;
         ON HEADCLICK oParam:aHeadClick ;
         LOADFIELDS ;
         FIXED COLSEMPTY GOTFOCUSSELECT LOCK ;
         ON INIT {| ob | ob:Cargo := oHmgData(), ;
         ob:nColOrder := 0, ;
         ob:lNoHScroll := .T., ;
         ob:lNoGrayBar := .F., ;
         ob:lNoLiteBar := .F., ;
         ob:lNoResetPos := .F., ;
         ob:lPickerMode := .F., ;
         ob:lNoChangeOrd := .T., ;
         ob:nStatusItem := 0, ;
         ob:lNoKeyChar := .T., ;
         ob:nWheelLines := 1, ;
         ob:nCellMarginLR := 1, ;
         ob:nLineStyle := LINES_ALL, ;
         ob:nClrLine := COLOR_GRID, ;
         ob:lCheckBoxAllReturn := .T. }

      :Cargo:oParam := oParam
      :lEnum := lSpecHd
      :lDrawSpecHd := lSpecHd

      IF lSpecHd .AND. Empty( :nHeightSpecHd )
         :nHeightSpecHd := GetFontHeight( oParam:aFont[ iif( Len( oParam:aFont ) > 3, 4, 1 ) ] )
      ENDIF

      :SetAppendMode( .F. )
      :SetDeleteMode( .F. )

      IF HB_ISBLOCK( bInit ) ; Eval( bInit, oBrw, oParam ) // 1. call your customization functions
      ENDIF

      IF :lDrawSpecHd .AND. ! Empty( oParam:aNumber ) .AND. HB_ISBLOCK( oParam:bSpecHdEnum ) // renumbering SpecHeader
         Eval( oParam:bSpecHdEnum, oBrw, oParam )
      ENDIF

      IF HB_ISBLOCK( oParam:bBody ) ; Eval( oParam:bBody, oBrw, oParam ) // 2. call your customization functions
      ENDIF

      IF HB_ISLOGICAL( oParam:bLDblClick ) .OR. HB_ISLOGICAL( oParam:bDblClick )
         :bLDblClick := {| p1, p2, p3, ob | p1 := p2 := p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }
      ELSEIF HB_ISBLOCK( oParam:bLDblClick ) // :bLDblClick := {|p1,p2,p3,ob| ... }
         :bLDblClick := oParam:bLDblClick
      ELSEIF HB_ISBLOCK( oParam:bDblClick ) // :bLDblClick := {|p1,p2,p3,ob| ... }
         :bLDblClick := oParam:bDblClick
      ENDIF

      IF HB_ISBLOCK( oParam:bRClicked )
         :bRClicked := oParam:bRClicked // :bRClicked := {|p1,p2,p3,ob| ... }
      ENDIF

      IF HB_ISBLOCK( oParam:bLClicked )
         :bLClicked := oParam:bLClicked // :bLClicked := {|p1,p2,p3,ob| ... }
      ENDIF

      IF HB_ISBLOCK( oParam:bGotFocus )
         :bGotFocus := oParam:bGotFocus // :bGotFocus := {|ob,hCtlLost| ... }
      ENDIF

      IF HB_ISBLOCK( oParam:bLostFocus )
         :bGotFocus := oParam:bLostFocus // :bLostFocus := {|hCtlFocus,ob| ... }
      ENDIF

      IF HB_ISBLOCK( oParam:bChange )
         :bChange := oParam:bChange // :bChange := {|ob| ... }
      ENDIF

      IF HB_ISBLOCK( oParam:bKeyDown )
         :bKeyDown := oParam:bKeyDown // :bKeyDown := { |nKey,nFalgs,ob| ... }
      ENDIF

      IF HB_ISNUMERIC( oParam:nFireKey )
         :nFireKey := oParam:nFireKey
      ENDIF

      IF HB_ISARRAY( oParam:aUserKeys )
         FOR EACH aTmp IN oParam:aUserKeys
            i := iif( Len( aTmp ) > 2, aTmp[ 3 ], .F. ) // Ctrl+...
            j := iif( Len( aTmp ) > 3, aTmp[ 4 ], .F. ) // Shift+...
            :UserKeys( aTmp[ 1 ], aTmp[ 2 ], ! Empty( i ), ! Empty( j ) )
         NEXT
      ENDIF

      IF :nLen > 0
         :nRowPos := 1
         :nCell := :nFreeze + 1
      ENDIF

      IF ( :GetAllColsWidth() - 1 ) > ( _GetClientRect( :hWnd )[ 3 ] )
         :lNoHScroll := .F.
         :lMoreFields := ( :nColCount() > 30 )
      ELSEIF oParam:uSelector == NIL .AND. oParam:lAdjust == NIL
         IF HB_ISBLOCK( oParam:bAdjColumns )
            Eval( oParam:bAdjColumns, oBrw, oParam ) // :AdjColumns(...)
         ENDIF
      ENDIF

      :ResetVScroll( .T. )
      :oHScroll:SetRange( 0, 0 )

   END TBROWSE

   IF HB_ISBLOCK( bEnd ) ; Eval( bEnd, oBrw, oParam )
   ENDIF

   IF HB_ISARRAY( oParam:aEvents )
      FOR EACH aTmp IN oParam:aEvents
         ( This.Object ):Event( aTmp[ 1 ], aTmp[ 2 ] )
      NEXT
   ENDIF

   DO EVENTS

RETURN oBrw
