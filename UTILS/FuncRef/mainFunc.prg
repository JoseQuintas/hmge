#include "funcref.ch"

FUNCTION MainSetProperty( ... )
   SetProperty( ZFORM_MAIN, ... )

RETURN NIL

FUNCTION MainGetProperty( ... )
RETURN( GetProperty( ZFORM_MAIN, ... ) )
/*
FUNCTION StringCompare( cStr1, cStr2 )

   LOCAL nLimit
   LOCAL nI
   LOCAL cChar1, cChar2
   LOCAL c1, c2
   nLimit := Min( Len( cStr1 ), Len( cStr2 ) )
   FOR ni := 1 TO nLimit
      cChar1 := SubStr( cStr1, nI, 1 )
      cChar2 := SubStr( cStr2, nI, 1 )
      IF cChar1 <> cChar2
         c1 := SubStr( cStr1, nI, 30 )
         c2 := SubStr( cStr2, nI, 30 )
         msgDebug( cChar1, cChar2, nI, c1, c2 )
      ENDIF
   NEXT

RETURN NIL
*/
FUNCTION UpdateEditFile( cFile )

   LOCAL cMemoRead
   cMemoRead := ReadFile( cFile )
   cMemoRead := ToAscii( cMemoRead )
   cMemoRead := StrTran( cMemoread, ZCRLF, ZLF )
   MainSetProperty( ZEDIT_FILE, "Value", cMemoRead )
   // - cString := MainGetProperty( ZEDIT_FILE, "Value" )
   // - cString := STRTRAN( cString, ZCR, ZCRLF)
   // -  IF Len( cMemoRead ) <> Len( cString )
      // -  lCheckAscii := MainGetProperty( ZCHECK_ASCII128, "Value" )
      // -  msgDebug( lCheckAscii, cFile, "Memoread Len :", LEN( cMemoRead), "Editbox Value Len : ", LEN( cString))
      // -  StringCompare( cMemoread, cString)
   // -  ENDIF
   // - cMemoread80 := right( cMemoread, 80)
   // - cString80 := right( cString, 80)
   // - cString80 := STRTRAN( cString80, ZCR, HB_EOL())
   // - cString80 := RIGHT( cString80, 80)
   // - if cMemoread80 <> cString80
   // -   msgDebug( cFile, len( cMemoread), len( cstring), cMemoread80, cString80, len( cMemoread80), len( cString80))
   // - endif

RETURN NIL

FUNCTION GetGridItems( cFormname, cGridname )

   LOCAL aItems
   LOCAL nItemCount
   LOCAL nI
   nItemCount := GetProperty( cFormname, cGridname, "ItemCount" )
   aItems := {}
   FOR nI := 1 TO nItemCount
      AAdd( aItems, GetProperty( cFormname, cGridname, "Item", nI ) )
   NEXT

RETURN( aItems )

FUNCTION UpdateGridUDF()

   LOCAL aUDFs
   LOCAL eUDF
   LOCAL aUDF1
   aUDF1 := aGetUDF( 2 )
   aUDFs := {}
   IF .NOT. Empty( aUDF1 )
      FOR EACH eUDF IN aUDF1
         AAdd( aUDFs, { eUDF[ 1 ], '0', eUDF[ 2 ] } )
      NEXT
   ENDIF
   UpdateGrid( ZFORM_MAIN, ZGRID_UDF, aUDFs )

RETURN( aUDFs )

FUNCTION UpdateGridFunc()

   LOCAL aFuncs
   LOCAL eFunc
   LOCAL aGetFuncs
   aGetFuncs := aGetFunc( 2 )
   // - aGridUDFs := GetGridItems( ZFORM_MAIN, ZGRID_UDF )
   aFuncs := {}
   IF .NOT. Empty( aGetFuncs )
      FOR EACH eFunc IN aGetFuncs
         AAdd( aFuncs, { eFunc[ 1 ], AllTrim( Str( eFunc[ 4 ] ) ), '0' } )
      NEXT

      // -   *- update UDF grid
      // -   cFunc := eFunc[ 1]
      // -   nCalled := eFunc[ 4]
      // -   nFound := ASCAN( aGridUDFs, {|x| UPPER( cFunc) $ UPPER( x[ 1])})
      // -   IF nFound > 0
      // -     aGridUDFs[ nFound, 2] := ALLTRIM( STR( nCalled))
      // -     *- MainSetProperty( ZGRID_UDF, "Cell", nFound, 2, nCalled)
      // -     MainSetProperty( ZGRID_UDF, "Item", nFound, aGridUDFs[ nFound])
      // -   ENDIF
      // - NEXT
   ENDIF
   UpdateGrid( ZFORM_MAIN, ZGRID_FUNC, aFuncs )
   UpdateCalled( ZGRID_UDF, ZGRID_FUNC )

RETURN( aFuncs )

FUNCTION UpdateCalled( cGridUdf, cGridFunc )

   LOCAL aGridUDFs, aGridFuncs
   LOCAL eFunc
   LOCAL cFunc
   LOCAL nCalled, nFound
   aGridUDFs := GetGridItems( ZFORM_MAIN, cGridUDF )
   aGridFuncs := GetGridItems( ZFORM_MAIN, cGridFunc )
   FOR EACH eFunc IN aGridFuncs
      cFunc := eFunc[ 1 ]
      nCalled := eFunc[ 2 ]
      nFound := AScan( aGridUDFs, {| x | Upper( cFunc ) $ Upper( x[ 1 ] ) } )
      IF nFound > 0
         aGridUDFs[ nFound, 2 ] := nCalled
         // - MainSetProperty( ZGRID_UDF, "Cell", nFound, 2, nCalled)
         MainSetProperty( cGridUDF, "Item", nFound, aGridUDFs[ nFound ] )
      ENDIF
   NEXT

RETURN NIL

FUNCTION GetPath( cFilename )

   LOCAL nRBSlash
   LOCAL cPath
   nRBSlash := RAt( ZBSLASH, cFilename )
   cPath := ''
   IF nRBSlash > 0
      cPath := Left( cFilename, nRBSlash )
   ENDIF

RETURN( cPath )

FUNCTION UpdateGrid( cFormName, cGridName, aItems )

   LOCAL nI
   DoMethod( cFormName, cGridName, "DeleteAllItems" )

   FOR nI := 1 TO Len( aItems )
      IF .NOT. Empty( aItems[ nI ] )
         DoMethod( cFormName, cGridName, "AddItem", aItems[ nI ] )
      ENDIF
   NEXT

RETURN NIL

FUNCTION UpdateListbox( cFormName, cListName, aItems )

   LOCAL nI
   DoMethod( cFormName, cListName, "DeleteAllItems" )
   FOR nI := 1 TO Len( aItems )
      IF .NOT. Empty( aItems[ nI ] ) .AND. .NOT. Left( aItems[ nI ], 1 ) $ "#-" 
         DoMethod( cFormName, cListName, "AddItem", aItems[ nI ] )
      ENDIF
   NEXT

RETURN NIL

FUNCTION GetListFileSelected()

   LOCAL cFile, cPath
   LOCAL nValue
   nValue := MainGetProperty( ZLIST_FILES, "Value" )
   cFile := MainGetProperty( ZLIST_FILES, "Item", nValue )
   cPath := GetPath( MainGetProperty( ZTEXT_PATH, "Value" ) )
   IF At( ZBSLASH, cFile ) == 0
      cFile := cPath + cFile
   ENDIF

RETURN( cFile )

FUNCTION AToS( aArray, cSep )

   LOCAL cString
   LOCAL eArray
   hb_default( @cSep, hb_eol() )
   cString := ''
   FOR EACH eArray IN aArray
      IF ValType( eArray ) == 'A'
         cString += AToS( eArray, ", " ) + cSep
      ELSE
         // - msgDebug( eArray, VALTYPE( eArray))
         cString += xtoc( eArray ) + cSep
      ENDIF
   NEXT

RETURN( cString )

FUNCTION PrintArray( aArray, nTab )

   LOCAL cTab
   LOCAL cArray, cString
   LOCAL nI, nLenArray
   hb_default( @nTab, 1 )
   cTab := Space( nTab )
   nLenArray := Len( aArray )
   cString := cTab + '{ '
   FOR nI := 1 TO nLenArray
      cArray := aArray[ nI ]
      IF ValType( cArray ) == 'A'
         cString += hb_eol() + " ."
         cString += PrintArray( cArray, nTab + 1 )
      ELSE
         cString += xtoc( cArray )
         cString += iif( nI < nLenArray, ', ', '.' )
      ENDIF
   NEXT
   cString += "}"

RETURN( cString )

FUNCTION ReadFile( cFile )

   LOCAL cMemoRead
   cMemoRead := ''
   IF .NOT. Empty( cFile )
      IF File( cFile )
         cMemoRead := hb_MemoRead( cFile )
      ELSE
         MsgDebug( cFile, ZNOTFOUND )
      ENDIF
   ENDIF

RETURN( cMemoRead )

FUNCTION Control_Pos( cFormName, cCtrlName, aColRow )

   LOCAL nCol, nRow
   nCol := aColRow[ 1 ]
   nRow := aColRow[ 2 ]
   SetProperty( cFormName, cCtrlName, "Col", nCol )
   SetProperty( cFormName, cCtrlName, "Row", nRow )

RETURN NIL

// -
FUNCTION ArrangeAllCtrl( cFormname )

   LOCAL nFormWidth, nFormHeight
   LOCAL nDR, nDC
   LOCAL nJC, nJR
   LOCAL nWidth4, nHeight2
   LOCAL aCtrl
   LOCAL nRow, nCol, nHeight, nWidth
   LOCAL nI, nJ
   LOCAL cCtrlName, nCtrlWidth, nCtrlHeight
   nFormWidth := GetProperty( cFormname, "Width" )
   nFormHeight := GetProperty( cFormname, "Height" )
   nDR := 10
   nDC := 10
   nJC := 4
   nJR := 4
   nWidth4 := Int( ( nFormWidth - ( nJC + 2 ) * nDC ) / nJC )
   nHeight2 := Int( ( nFormHeight - ( nJR + 4 ) * nDR - ( 2 * 30 ) ) / 2 )
   aCtrl := { { "Button_1", "Text_1", ZCHECK_ASCII128 }, ;
      { "List_1", "RichEdit_1", ZGRID_UDF, ZGRID_FUNC }, ;
      { "Text_2", ZBUTTON_HB_REGEX_ALL, ZBUTTON_HB_REGEX, ZBUTTON_PROJECTUDF }, ;
      { "Edit_4", "Edit_5", ZGRID_PJT_UDF, ZGRID_PJT_FUNC } }
   nRow := 0
   nHeight := 0
   FOR nI := 1 TO Len( aCtrl )
      nRow += nDR + nHeight
      nCtrlHeight := MainGetProperty( aCtrl[ nI, 1 ], "Height" )
      nHeight := iif( Mod( nI, 2 ) == 0, nHeight2, nCtrlHeight )
      nCol := 0
      nWidth := 0
      FOR nJ := 1 TO Len( aCtrl[ nI ] )
         cCtrlName := aCtrl[ nI, nJ ]
         nCol += nDC + nWidth
         nCtrlWidth := MainGetProperty( cCtrlName, "Width" )
         nWidth := iif( Mod( nI, 2 ) == 0, nWidth4, nCtrlWidth )
         IF cCtrlName $ ZGRID_UDF + ZGRID_PJT_UDF + ZGRID_FUNC + ZGRID_PJT_FUNC
            // - MainSetProperty( ZGRID_UDF, "Widths", aWidth)
            MainSetProperty( cCtrlName, "ColumnWidth", 2, 50 )
            MainSetProperty( cCtrlName, "ColumnWidth", 3, 50 )
            MainSetProperty( cCtrlName, "ColumnWidth", 1, nWidth - 100 )
         ENDIF
         Ctrl_Resize( ZFORM_MAIN, cCtrlName, nRow, nCol, nWidth, nHeight )
      NEXT
   NEXT

RETURN NIL

FUNCTION Ctrl_Resize( cFormName, cCtrlName, nRow, nCol, nWidth, nHeight )

   SetProperty( cFormName, cCtrlName, "Row", nRow )
   SetProperty( cFormName, cCtrlName, "Col", nCol )
   SetProperty( cFormName, cCtrlName, "Width", nWidth )
   SetProperty( cFormName, cCtrlName, "Height", nHeight )

RETURN NIL

FUNCTION Form_Center( cFormName, cSize )

   LOCAL nDesktop_Width, nDesktop_Height
   LOCAL nRatio, nTaskBarHeight
   LOCAL nForm_Width, nForm_Height
   LOCAL nForm_Col, nForm_Row
   nDesktop_Width := GetDesktopWidth()
   nDesktop_Height := GetDesktopHeight()
   IF cSize == "MAX"
      nRatio := 1
      nTaskBarHeight := 50
      nDesktop_Height -= nTaskbarHeight
   ELSE
      nRatio := 2
   ENDIF
   nForm_Width := nDesktop_Width / nRatio
   nForm_Height := ( nDesktop_Height - 50 ) / nRatio
   nForm_Col := ( nDesktop_Width - nForm_Width ) / 2
   nForm_Row := ( nDesktop_Height - nForm_Height ) / 2
   SetProperty( cFormName, "Col", nForm_Col )
   SetProperty( cFormName, "Row", nForm_Row )
   SetProperty( cFormName, "Width", nForm_Width )
   SetProperty( cFormName, "Height", nForm_Height )

RETURN( { nForm_Width, nForm_Height } )

// ---
FUNCTION xToC ( x )

   LOCAL c
   SWITCH ValType ( x )
   CASE 'C'
      c := x
      IF Empty( c )
         c := '"' + c + '"'
      ENDIF
      EXIT
   CASE 'N'
      c := Str( x )
      EXIT
   CASE 'D'
      c := DToC ( x )
      EXIT
   CASE 'L'
      c := if ( x, '.T.', '.F.' )
      EXIT
   CASE 'U'
      c := 'Nil'
   ENDSWITCH

RETURN c
