#include "funcref.ch"

FUNCTION ic_Exclude( cString, cExclude )

   LOCAL aString
   LOCAL eString
   LOCAL aExclude
   LOCAL aInclude
   aString := iif( ValType( cString ) == 'C', hb_ATokens( cString, hb_eol() ), cString )
   aExclude := iif( ValType( cExclude ) == 'C', hb_ATokens( cExclude, hb_eol() ), cExclude )
   // -
   aInclude := {}
   FOR EACH eString IN aString
      IF AScan( aExclude, {| x | Upper( eString[ 1 ] ) # Upper( x[ 1 ] ) } ) == 0
         AAdd( aInclude, eString )
      ELSE

      ENDIF
   NEXT

RETURN( aInclude )

FUNCTION ic_SortStr( cString )

   LOCAL aString
   aString := hb_ATokens( cString, hb_eol() )
   aString := ASort( aString )
   cString := AToS( aString )

RETURN( cString )

FUNCTION AddUnique( cPjtFunc, cString )

   LOCAL aString
   LOCAL eString
   IF Empty( cPjtFunc )
      cPjtFunc := cString
   ELSE
      aString := hb_ATokens( cString, hb_eol() )
      FOR EACH eString IN aString
         IF At( eString, cPjtFunc ) == 0 .AND. .NOT. Empty( eString )
            cPjtFunc += eString + hb_eol()
         ENDIF
      NEXT
   ENDIF

RETURN( cPjtFunc )

FUNCTION ic_RegexAll( cRegExStr, cString, cMode )

   LOCAL aRegex
   LOCAL cRegEx
   LOCAL lCase
   LOCAL lNewLine
   aRegex := {}
   cRegEx := hb_regexComp( cRegExStr )
   IF hb_IsRegex( cRegEx )
      lCase := .F.
      lNewLine := .T.
      IF cMode == "hb_Regex()"
         aRegex := hb_regexAll( cRegEx, cString, lCase, lNewLine,,, .F. )
      ELSE
         aRegex := hb_regexAll( cRegEx, cString, lCase, lNewLine,,, .F. )
      ENDIF
   ELSE
      msgDebug( "Incorrect RegEx !", cRegExStr, cRegEx )
   ENDIF

RETURN( aRegex )

// ---

FUNCTION aGetUDF( nIndex )

   LOCAL aRegexResult
   hb_default( @nINDEX, 1 )
   aRegexResult := aGetRegexResult( ZREGEX_UDF, nIndex )
   aRegexResult := ASort( aRegexResult, , , {| x, y | x[ 1 ] < y[ 1 ] } )

RETURN( aRegexResult )

FUNCTION aGetFunc()
   // - LOCAL nI
   LOCAL aRegexResult
   // - aUDF := aGetUDF()
   aRegexResult := aGetRegexResult( ZREGEX_FUNC )
   aRegexResult := ASort( aRegexResult, , , {| x, y | x[ 1 ] < y[ 1 ] } )
   // - aFunc := {}
   // - FOR nI := 1 TO LEN( aRegexResult)
   // -   cFunc := UPPER( ZSPACE + aRegexResult[ nI, 1])
   // -   IF ASCAN( aUDF, {|x| cFunc $ UPPER( x)}) == 0
   // -     AADD( aFunc, aRegexResult[ nI])
   // -   ENDIF
   // - NEXT

RETURN( aRegexResult )

FUNCTION ToAscii( cString )

   LOCAL lCheckAscii
   LOCAL cNString, cChar
   LOCAL nI
   lCheckAscii := MainGetProperty( ZCHECK_ASCII128, "Value" )
   IF lCheckAscii
      cNString := cString
   ELSE
      cNString := ''
      FOR nI := 1 TO Len( cString )
         cChar := SubStr( cString, nI, 1 )
         IF Asc( cChar ) > 127
            cChar := '~'
         ENDIF
         cNString += cChar
      NEXT
   ENDIF

RETURN( cNString )

FUNCTION aGetRegexResult( cRegExStr, nIndex, cMode )

   LOCAL cPathFile, cMemoRead
   LOCAL aRegex, aFuncs, aReturn
   hb_default( @nINDEX, 1 )
   hb_default( @cMode, "FUNC" )
   cPathFile := GetListFileSelected()
   cMemoRead := ReadFile( cPathFile )
   cMemoRead := ToAscii( cMemoRead )
   aRegex := ic_regexAll( cRegExStr, cMemoRead,,,,, .F., cMode )
   aFuncs := aRegexToArray( aRegex, nIndex, cMemoread )
   aReturn := iif( cMode == "FUNC", aFuncs, aRegex )

RETURN( aReturn )

FUNCTION aRegexToArray( aRegex, nIndex, cString )

   LOCAL lAllowDup
   LOCAL aFuncs, aString
   LOCAL eRegex, eFunc, cFunc
   LOCAL nEnd, nFound, cFound
   LOCAL nRow, cRow, cEnd
   hb_default( @nINDEX, 1 )
   lAllowDup := .F.
   aFuncs := {}
   aString := hb_ATokens( cString, hb_eol() )
   FOR EACH eRegex IN aRegex
      eFunc := eRegex[ 1 ] // whole match eRegex[ 2...] is subMatch
      // - FOR EACH eFunc IN eRegex
      cFunc := AllTrim( eFunc[ 1 ] )
      cFunc := StrTran( cFunc, ZCRLF, '' )
      // - cFund := STRTRAN( cFunc, "\r\n", ' ')
      // - cFund := STRTRAN( cFunc, HB_EOL(), ' ')
      cFunc := AllTrim( cFunc )
      IF Empty( cFunc )
         LOOP
      ENDIF
      // - nStart := eFunc[ 2 ]
      nEnd := eFunc[ 3 ]
      nFound := AScan( aString, {| x | cFunc $ x } )
      IF nFound == 0
         // - msgDebug( cFunc, eFunc )
      ELSE
         cFound := AllTrim( aString[ nFound ] )
         IF cFound <> cFunc
            // - commented
            LOOP
         ENDIF
         nRow := nFound
         cRow := AllTrim( Str( nRow ) )
         cEnd := AllTrim( Str( nEnd ) )
         nFound := AScan( aFuncs, {| x | x[ 1 ] == cFunc } )
         IF nFound == 0 .OR. lAllowDup
            AAdd( aFuncs, { cFunc, cRow, cEnd, 1 } )
         ELSE
            aFuncs[ nFound, 4 ] += 1
         ENDIF
      ENDIF
   NEXT
   // - aTmp := {}
   // - DO CASE
   // -   CASE nIndex == 1
   // -     AEVAL( aFuncs, {|x| AADD( aTmp, x[ 1])})
   // -   CASE nIndex == 2
   // -     AEVAL( aFuncs, {|x| AADD( aTmp, { x[ 1], x[ 2]})})
   // -   OTHERWISE
   // -     aTmp := ACLONE( aFuncs)
   // - ENDCASE

RETURN( aFuncs )

FUNCTION Occur( cSearch, cString )

   LOCAL nLenSearch
   LOCAL nOccur, nAt
   nLenSearch := Len( cSearch )
   nOccur := 0
   DO WHILE Len( cString ) > 0
      nAt := At( cSearch, cString )
      IF nAt > 0
         nOccur++
         cString := SubStr( cString, nAt + nLenSearch + 1 )
      ELSE
         cString := ''
      ENDIF
   ENDDO

RETURN( nOccur )

/*
FUNCTION T_UnicodeBoxChar( cLine )

   LOCAL aBoxChar
   LOCAL nI
   aBoxChar := { { LEFT_TOP, UNILEFT_TOP }, ;
      { RIGHT_TOP, UNIRIGHT_TOP }, ;
      { LEFT_BOTTOM, UNILEFT_BOTTOM }, ;
      { RIGHT_BOTTOM, UNIRIGHT_BOTTOM }, ;
      { VER, UNIVER }, ;
      { HOR, UNIHOR }, ;
      { CROSS, UNICROSS }, ;
      { TIE, UNITIE }, ;
      { UTIE, UNIUTIE }, ;
      { LEFT_TIE, UNILEFT_TIE }, ;
      { RIGHT_TIE, UNIRIGHT_TIE } }

   FOR nI := 1 TO Len( aBoxChar )
      cLine := StrTran( cLine, aBoxChar[ nI, 1 ], aBoxChar[ nI, 2 ] )
   NEXT

RETURN( cLine )
*/