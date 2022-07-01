#include "funcref.ch"

FUNCTION Main

   LOAD WINDOW Main
   Main.Center
   Main.Activate

RETURN NIL

// -
FUNCTION Main_List_File_OnChange()

   LOCAL cPathFile
   LOCAL aFuncs, aUDFs
   cPathFile := GetListFileSelected()
   UpdateEditFile( cPathFile )
   aUDFs := UpdateGridUDF( cPathFile )
   aFuncs := UpdateGridFunc( cPathFile )

RETURN( { aUDFs, aFuncs } )

// -
FUNCTION Main_Button_GetFile_Action()

   LOCAL cFile
   LOCAL cPath
   LOCAL aItems
   LOCAL cMemoRead
   cFile := GetFile( { { "HBP", "*.HBP" }, { "PRG", "*.PRG" }, { "HB", "*.HB" }, { "HTM", "*.HTM" } }, "Text", "\TH\KUDA\", .F., .T. )
   // - cPath := GetPath( cFile)
   MainSetProperty( ZTEXT_PATH, "Value", cFile )
   IF "HBP" $ Upper( cFile )
      cMemoRead := ReadFile( cFile )
      aItems := hb_ATokens( cMemoRead, hb_eol() )
   ELSE
      cPath := GetPath( cFile )
      cFile := StrTran( cFile, cPath, '' )
      aItems := { cFile }
   ENDIF
   UpdateListbox( ZFORM_MAIN, ZLIST_FILES, aItems )
   MainSetProperty( ZLIST_FILES, "Value", 1 )

RETURN NIL

FUNCTION Main_Button_hbRegexAll_Action()

   LOCAL aFuncs, cResult
   LOCAL cRegExStr
   cRegExStr := MainGetProperty( ZTEXT_REGEX, "Value" )
   aFuncs := aGetRegexResult( cRegExStr, 3, "hb_RegexAll()" )
   // - aFuncs := ASORT( aFuncs, , , {|x, y| x[ 1] < y[ 1]})
   // - cResult   := AToS( aFuncs)
   cResult := PrintArray( aFuncs )
   MainSetProperty( ZEDIT_REGEX, "Value", cResult )

RETURN NIL

FUNCTION Main_Button_hbRegex_Action()

   LOCAL aFuncs, cResult
   LOCAL cRegExStr
   cRegExStr := MainGetProperty( ZTEXT_REGEX, "Value" )
   aFuncs := aGetRegexResult( cRegExStr, 3, "hb_Regex()" )
   // - aFuncs := ASORT( aFuncs, , , {|x, y| x[ 1] < y[ 1]})
   // - cResult   := AToS( aFuncs)
   cResult := PrintArray( aFuncs )
   MainSetProperty( ZEDIT_REGEX, "Value", cResult )

RETURN NIL


FUNCTION Main_ProjectUDF_Action()

   LOCAL chbmk2, cFunc, aPjtUDF, aPjtFunc
   LOCAL eFunc
   LOCAL nItemCount, nI
   LOCAL aFuncs, aUDFs
   LOCAL nFound
   chbmk2 := ReadFile( "hbmk2find.txt" )
   chbmk2 := StrTran( chbmk2, ZLF, hb_eol() )
   MainSetProperty( ZEDIT_HBFUNC, "Value", chbmk2 )
   // -
   nItemCount := MainGetProperty( ZLIST_FILES, "ItemCount" )
   aPjtUDF := {}
   aPjtFunc := {}
   FOR nI := 1 TO nItemCount
      MainSetProperty( ZLIST_FILES, "Value", nI )
      aUDFs := GetGridItems( ZFORM_MAIN, ZGRID_UDF )
      AEval( aUDFs, {| x | AAdd( aPjtUDF, x ) } )
      // -
      aFuncs := GetGridItems( ZFORM_MAIN, ZGRID_FUNC )
      FOR EACH eFunc IN aFuncs
         cFunc := eFunc[ 1 ]
         nFound := AScan( aPjtFunc, {| x | Upper( x[ 1 ] ) == Upper( cFunc ) } )
         IF nFound == 0
            eFunc[ 2 ] := Val( eFunc[ 2 ] )
            AAdd( aPjtFunc, eFunc )
         ELSE
            aPjtFunc[ nFound, 2 ] := aPjtFunc[ nFound, 2 ] + Val( eFunc[ 2 ] )
         ENDIF
      NEXT
      // - cString1 := MainGetProperty( ZEDIT_FUNC, "Value")
      // - cPjtFunc := AddUnique( cPjtFunc, cString1)
   NEXT
   // - cPjtUDF := ic_SortStr( cPjtUDF)
   WaitWindow( "sorting...UDF", .T. )
   aPjtUDF := ASort( aPjtUDF, , , {| x, y | x[ 1 ] < y[ 1 ] } )
   // - MainSetProperty( ZEDIT_PJT_UDF, "Value", cPjtUDF)
   UpdateGrid( ZFORM_MAIN, ZGRID_PJT_UDF, aPjtUDF )
   // - cPjtFunc := ic_SortStr( cPjtFunc)
   // - cPjtFunc := ic_Exclude( cPjtFunc, aPjtUDF)
   // - cPjtFunc := ic_Exclude( cPjtFunc, chbmk2)
   // - MainSetProperty( ZEDIT_PJT_FUNC, "Value", cPjtFunc)
   // - aPjtFunc := ic_Exclude( aPjtFunc, aPjtUDF)
   WaitWindow( "sorting...Func", .T. )
   aPjtFunc := ASort( aPjtFunc, , , {| x, y | x[ 1 ] < y[ 1 ] } )
   AEval( aPjtFunc, {| x | x[ 2 ] := AllTrim( Str( x[ 2 ] ) ) } )
   UpdateGrid( ZFORM_MAIN, ZGRID_PJT_FUNC, aPjtFunc )
   UpdateCalled( ZGRID_PJT_UDF, ZGRID_PJT_FUNC )
   WaitWindow()

RETURN NIL

FUNCTION Main_Text_File_OnEnter()
RETURN NIL

FUNCTION Main_Grid_UDF_OnChange()

   // - nValue := MainGetProperty( ZGRID_UDF, "Value" )
   // - msgDebug( "Grid on", nValue)

RETURN NIL

FUNCTION Main_OnInit()

   Form_Center( ZFORM_MAIN, "MAX" )
   MainSetProperty( "EDIT_1", "Enabled", .F. )
   MainSetProperty( ZEDIT_UDF, "Enabled", .F. )
   MainSetProperty( ZEDIT_FUNC, "Enabled", .F. )
   MainSetProperty( ZEDIT_PJT_UDF, "Enabled", .F. )
   MainSetProperty( ZEDIT_PJT_FUNC, "Enabled", .F. )
   ArrangeAllCtrl( ZFORM_MAIN )
   MainSetProperty( ZTEXT_REGEX, "Value", ZREGEX_FUNC )
   Main_Button_GetFile_Action()

RETURN NIL
