/* Sudoku Game
   original by Rathi

   edited by Alex Gustow
   (try to use "auto-zoom technique")
*/

#include "minigui.ch"

STATIC aPuzzles
STATIC aSudoku
STATIC aOriginal

***************************
FUNCTION MAIN

   LOCAL bColor
   LOCAL nRandom
   LOCAL nGuess
   LOCAL nArrLen
   LOCAL cTime := Time()
   LOCAL cTitle := "HMG Sudoku"

   // GAL - coefficients for "auto-zooming"
   LOCAL gkoefh := 1, gkoefv := 1
   LOCAL gw   // for grid columns width
   LOCAL nRatio := GetDesktopWidth() / GetDesktopHeight()

   IF nRatio == 4 / 3
      gkoefh := GetDesktopWidth() / 1024
      gkoefv := GetDesktopHeight() / 768
   ELSEIF nRatio == 1.6
      gkoefv := GetDesktopHeight() / 850
   ENDIF
   gw := 50 * gkoefh

   aPuzzles := ImportFromTxt( "sudoku.csv" )
   nArrLen := Len( aPuzzles )

   aSudoku := { ;
      { 0, 0, 0, 2, 0, 3, 8, 0, 1 }, ;
      { 0, 0, 0, 7, 0, 6, 0, 5, 2 }, ;
      { 2, 0, 0, 0, 0, 0, 0, 7, 9 }, ;
      { 0, 2, 0, 1, 5, 7, 9, 3, 4 }, ;
      { 0, 0, 3, 0, 0, 0, 1, 0, 0 }, ;
      { 9, 1, 7, 3, 8, 4, 0, 2, 0 }, ;
      { 1, 8, 0, 0, 0, 0, 0, 0, 6 }, ;
      { 7, 3, 0, 6, 0, 1, 0, 0, 0 }, ;
      { 6, 0, 5, 8, 0, 9, 0, 0, 0 } }

   aOriginal := {}

   // GAL
   IF File( "Help.chm" )
      SET helpfile TO 'Help.chm'
   ENDIF

   IF nArrLen > 0
      nRandom := Val( "0." + SubStr( cTime, 8, 1 ) + SubStr( cTime, 5, 1 ) + SubStr( cTime, 8, 2 ) )
      nGuess := Int( nRandom * ( nArrLen + 1 ) )
      IF nGuess == 0
         nGuess := 1
      ENDIF
      aSudoku := AClone( aPuzzles[ nGuess ] )
      cTitle := "HMG Sudoku" + " Game no: " + hb_ntos( nGuess ) + " of " + hb_ntos( nArrLen )
   ENDIF

   bColor := {|| SudokuBackColor() }

   aOriginal := AClone( aSudoku )

   // GAL
   DEFINE WINDOW Sudoku ;
      WIDTH 486 * gkoefh - iif( IsThemed(), 0, GetBorderWidth() ) ;
      HEIGHT 550 * gkoefv - iif( IsThemed(), 0, GetTitleHeight() ) ;
      MAIN ;
      TITLE cTitle ;
      NOMAXIMIZE ; /* GAL */
      NOSIZE /* GAL */

   DEFINE GRID Square
      ROW 10
      COL 10
      WIDTH 460 * gkoefh - iif( IsThemed(), 0, GetBorderWidth() )
      HEIGHT 445 * gkoefv - iif( IsThemed(), 0, GetTitleHeight() + GetBorderHeight() )
      SHOWHEADERS .F.
      WIDTHS { gw, gw, gw, gw, gw, gw, gw, gw, gw }
      JUSTIFY { 2, 2, 2, 2, 2, 2, 2, 2, 2 }
      CELLNAVIGATION .T.
      ALLOWEDIT .T.
      COLUMNCONTROLS { ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" }, ;
         { "TEXTBOX", "CHARACTER", "9" } }
      FONTNAME "Arial"
      FONTSIZE 30 * gkoefh
      DYNAMICBACKCOLOR { ;
         bColor, bColor, bColor, ;
         bColor, bColor, bColor, ;
         bColor, bColor, bColor }
      COLUMNWHEN { ;
         {|| entergrid() }, {|| entergrid() }, ;
         {|| entergrid() }, {|| entergrid() }, ;
         {|| entergrid() }, {|| entergrid() }, ;
         {|| entergrid() }, {|| entergrid() }, ;
         {|| entergrid() } }
      COLUMNVALID { ;
         {|| checkgrid() }, {|| checkgrid() }, ;
         {|| checkgrid() }, {|| checkgrid() }, ;
         {|| checkgrid() }, {|| checkgrid() }, ;
         {|| checkgrid() }, {|| checkgrid() }, ;
         {|| checkgrid() } }
      ONCHANGE CheckPossibleValues()
   END GRID

   DEFINE LABEL Valid
      ROW 460 * gkoefv - iif( IsThemed(), 0, GetTitleHeight() )
      COL 10
      WIDTH 370 * gkoefh
      HEIGHT 30 * gkoefv
      FONTNAME "Arial"
      FONTSIZE 18 * gkoefv
   END LABEL

   // GAL
   IF File( "help.chm" )
      DEFINE STATUSBAR
         STATUSITEM 'F1 - Help' ACTION DISPLAY HELP MAIN
      END STATUSBAR

      ON KEY F1 ACTION DISPLAY HELP MAIN
   ENDIF

   DEFINE BUTTON Next
      ROW 460 * gkoefv - iif( IsThemed(), 0, GetTitleHeight() )
      COL 400 * gkoefh - iif( IsThemed(), 0, GetBorderWidth() )
      WIDTH 70 * gkoefh
      CAPTION "Next"
      ACTION NextGame()
   END BUTTON

   END WINDOW

   ON KEY ESCAPE OF Sudoku ACTION Sudoku.Release()

   RefreshSudokuGrid()

   Sudoku.Center()
   Sudoku.Activate()

RETURN NIL

***************************
FUNCTION SudokuBackColor()

   LOCAL rowindex := This.cellrowindex
   LOCAL colindex := This.cellcolindex

   DO CASE

   CASE rowindex <= 3 // first row

      DO CASE
      CASE colindex <= 3 // first col
         RETURN { 200, 100, 100 }
      CASE colindex > 3 .AND. colindex <= 6 // second col
         RETURN { 100, 200, 100 }
      CASE colindex > 6 // third col
         RETURN { 100, 100, 200 }
      ENDCASE

   CASE rowindex > 3 .AND. rowindex <= 6 // second row

      DO CASE
      CASE colindex <= 3 // first col
         RETURN { 100, 200, 100 }
      CASE colindex > 3 .AND. colindex <= 6 // second col
         RETURN { 200, 200, 100 }
      CASE colindex > 6 // third col
         RETURN { 100, 200, 100 }
      ENDCASE

   CASE rowindex > 6 // third row

      DO CASE
      CASE colindex <= 3 // first col
         RETURN { 100, 100, 200 }
      CASE colindex > 3 .AND. colindex <= 6 // second col
         RETURN { 100, 200, 100 }
      CASE colindex > 6 // third col
         RETURN { 200, 100, 100 }
      ENDCASE

   ENDCASE

RETURN NIL

***************************
FUNCTION RefreshSudokuGrid()

   LOCAL aLine := {}
   LOCAL aValue := Sudoku.Square.Value
   LOCAL i
   LOCAL j

   Sudoku.Square.DeleteAllItems()

   IF Len( aSudoku ) == 9
      FOR i := 1 TO Len( aSudoku )
         ASize( aLine, 0 )
         FOR j := 1 TO Len( aSudoku[ i ] )
            IF aSudoku[ i, j ] > 0
               AAdd( aLine, Str( aSudoku[ i, j ], 1, 0 ) )
            ELSE
               AAdd( aLine, '' )
            ENDIF
         NEXT j
         Sudoku.Square.AddItem( aLine )
      NEXT i
   ENDIF

   Sudoku.Square.Value := aValue

RETURN NIL

***************************
FUNCTION EnterGrid()

   LOCAL aValue := Sudoku.Square.Value

   IF Len( aValue ) > 0
      IF aOriginal[ aValue[ 1 ], aValue[ 2 ] ] > 0
         RETURN .F.
      ELSE
         RETURN .T.
      ENDIF
   ENDIF

RETURN .F.

***************************
FUNCTION CheckGrid()

   LOCAL nRow := This.cellrowindex
   LOCAL nCol := This.cellcolindex
   LOCAL nValue := Val( AllTrim( This.cellvalue ) )
   LOCAL i
   LOCAL j
   LOCAL nRowStart := Int( ( nRow - 1 ) / 3 ) * 3 + 1
   LOCAL nRowEnd := nRowstart + 2
   LOCAL nColStart := Int( ( nCol - 1 ) / 3 ) * 3 + 1
   LOCAL nColEnd := nColstart + 2

   IF nValue == 0
      This.cellvalue := ''
      Sudoku.Valid.Value := ''
      aSudoku[ nRow, nCol ] := 0
      RETURN .T.
   ENDIF

   IF nValue == aSudoku[ nRow, nCol ]
      RETURN .T.
   ENDIF

   FOR i := 1 TO 9
      IF aSudoku[ nRow, i ] == nValue // row checking
         RETURN .F.
      ENDIF
      IF aSudoku[ i, nCol ] == nValue // col checking
         RETURN .F.
      ENDIF
   NEXT i

   FOR i := nRowStart TO nRowEnd
      FOR j := nColStart TO nColEnd
         IF aSudoku[ i, j ] == nValue
            RETURN .F.
         ENDIF
      NEXT j
   NEXT i

   Sudoku.Valid.Value := ''

   aSudoku[ nRow, nCol ] := nValue

   CheckCompletion()

RETURN .T.

***************************
FUNCTION CheckCompletion()

   LOCAL i
   LOCAL j

   FOR i := 1 TO Len( aSudoku )
      FOR j := 1 TO Len( aSudoku[ i ] )
         IF aSudoku[ i, j ] == 0
            RETURN NIL
         ENDIF
      NEXT j
   NEXT i

   MsgInfo( "Congrats! You won!", "Finish" )

RETURN NIL

***************************
FUNCTION CheckPossibleValues()

   LOCAL aValue := Sudoku.Square.Value
   LOCAL aAllowed := {}
   LOCAL cAllowed := ""
   LOCAL nRowStart := Int( ( aValue[ 1 ] - 1 ) / 3 ) * 3 + 1
   LOCAL nRowEnd := nRowstart + 2
   LOCAL nColStart := Int( ( aValue[ 2 ] - 1 ) / 3 ) * 3 + 1
   LOCAL nColEnd := nColstart + 2
   LOCAL lAllowed
   LOCAL i
   LOCAL j
   LOCAL k

   IF aValue[ 1 ] > 0 .AND. aValue[ 2 ] > 0

      IF aOriginal[ aValue[ 1 ], aValue[ 2 ] ] > 0

         Sudoku.Valid.Value := ""

      ELSE

         FOR i := 1 TO 9

            lAllowed := .T.
            FOR j := 1 TO 9
               IF aSudoku[ aValue[ 1 ], j ] == i
                  lAllowed := .F.
               ENDIF
               IF aSudoku[ j, aValue[ 2 ] ] == i
                  lAllowed := .F.
               ENDIF
            NEXT j

            FOR j := nRowStart TO nRowEnd
               FOR k := nColStart TO nColEnd
                  IF aSudoku[ j, k ] == i
                     lAllowed := .F.
                  ENDIF
               NEXT k
            NEXT j

            IF lAllowed
               AAdd( aAllowed, i )
            ENDIF

         NEXT i

         IF Len( aAllowed ) > 0
            FOR i := 1 TO Len( aAllowed )
               IF i == 1
                  cAllowed := cAllowed + AllTrim( Str( aAllowed[ i ] ) )
               ELSE
                  cAllowed := cAllowed + ", " + AllTrim( Str( aAllowed[ i ] ) )
               ENDIF
            NEXT i
            Sudoku.Valid.Value := "Possible Numbers: " + cAllowed
         ELSE
            Sudoku.Valid.Value := "Possible Numbers: Nil"
         ENDIF

      ENDIF

   ENDIF

RETURN NIL

***************************
FUNCTION ImportFromTxt( cFilename )

   LOCAL aLines := {}
   LOCAL handle := FOpen( cFilename, 0 )
   LOCAL size1
   LOCAL sample
   LOCAL lineno
   LOCAL eof1
   LOCAL linestr := ""
   LOCAL c := ""
   LOCAL x
   LOCAL finished
   LOCAL m
   LOCAL aPuzzles := {}
   LOCAL aPuzzle := {}
   LOCAL aRow := {}
   LOCAL i
   LOCAL j
   LOCAL k

   IF handle == -1
      RETURN aPuzzles
   ENDIF

   size1 := FSeek( handle, 0, 2 )

   IF size1 > 65000
      sample := 65000
   ELSE
      sample := size1
   ENDIF

   FSeek( handle, 0 )
   lineno := 1
   AAdd( aLines, "" )
   c := Space( sample )
   eof1 := .F.
   linestr := ""

   DO WHILE .NOT. eof1
      x := FRead( handle, @c, sample )

      IF x < 1

         eof1 := .T.
         aLines[ lineno ] := linestr

      ELSE

         finished := .F.

         DO WHILE .NOT. finished

            m := At( Chr( 13 ), c )

            IF m > 0

               IF m == 1

                  linestr := ""
                  lineno += 1
                  AAdd( aLines, "" )
                  IF Asc( SubStr( c, m + 1, 1 ) ) == 10
                     c := SubStr( c, m + 2, Len( c ) )
                  ELSE
                     c := SubStr( c, m + 1, Len( c ) )
                  ENDIF

               ELSE

                  IF Len( AllTrim( linestr ) ) > 0
                     linestr += SubStr( c, 1, m - 1 )
                  ELSE
                     linestr := SubStr( c, 1, m - 1 )
                  ENDIF

                  IF Asc( SubStr( c, m + 1, 1 ) ) == 10
                     c := SubStr( c, m + 2, Len( c ) )
                  ELSE
                     c := SubStr( c, m + 1, Len( c ) )
                  ENDIF

                  aLines[ lineno ] := linestr
                  linestr := ""
                  lineno += 1
                  AAdd( aLines, "" )

               ENDIF

            ELSE

               linestr := c
               finished := .T.

            ENDIF

         ENDDO

         c := Space( sample )

      ENDIF

   ENDDO

   FClose( handle )

   FOR i := 1 TO Len( aLines )
      x := 1
      ASize( aPuzzle, 0 )

      FOR j := 1 TO 9
         ASize( aRow, 0 )
         FOR k := 1 TO 9
            AAdd( aRow, Val( AllTrim( SubStr( aLines[ i ], x, 1 ) ) ) )
            x += 2
         NEXT k
         IF Len( aRow ) == 9
            AAdd( aPuzzle, AClone( aRow ) )
         ENDIF
      NEXT j

      IF Len( aPuzzle ) == 9
         AAdd( aPuzzles, AClone( aPuzzle ) )
      ENDIF

   NEXT i

RETURN aPuzzles

***************************
FUNCTION NextGame()

   LOCAL cTime := Time()
   LOCAL nRandom
   LOCAL nGuess
   LOCAL nArrLen := Len( aPuzzles )

   IF nArrLen > 0
      nRandom := Val( "0." + SubStr( cTime, 8, 1 ) + SubStr( cTime, 5, 1 ) + SubStr( cTime, 8, 2 ) )
      nGuess := Int( nRandom * ( nArrLen + 1 ) )
      IF nGuess == 0
         nGuess := 1
      ENDIF
      aSudoku := AClone( aPuzzles[ nGuess ] )
      aOriginal := AClone( aSudoku )
      Sudoku.Title := "HMG Sudoku" + " Game no: " + hb_ntos( nGuess ) + " of " + hb_ntos( nArrLen )
   ENDIF

   RefreshSudokuGrid()

RETURN NIL
