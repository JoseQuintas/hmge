
*******************************************************************************
* PROGRAMA: HMG TETRIS
* LENGUAJE: HMG
* FECHA:    Julio 2020
* AUTOR:    Dr. CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
* BLOG:     http://srvet.blogspot.com
*******************************************************************************

#include "hmg.ch"

#define _LEFT  1
#define _RIGHT 2
#define ROTATE 3
#define _DOWN  4


MEMVAR aTetromino
MEMVAR nBlockSize
MEMVAR nMaxRow
MEMVAR nMaxCol
MEMVAR nRow
MEMVAR nCol
MEMVAR nIndex
MEMVAR nRot
MEMVAR aBoard
MEMVAR aBuffer
MEMVAR aCurrentTetromino
MEMVAR _aux
MEMVAR nPoints
MEMVAR nRecord
MEMVAR lPause
MEMVAR lGameOver
MEMVAR nInterval
MEMVAR nContTeromino
MEMVAR nMaxTetromino
MEMVAR hBitmapBackground
MEMVAR hBitmapBuffer
MEMVAR hBitmapBlock
MEMVAR nBlockSizePixel
MEMVAR aRGBcolor


FUNCTION MAIN

   CreateVars()

   PUBLIC hBitmapBackground
   PUBLIC hBitmapBuffer
   PUBLIC hBitmapBlock := Array( nMaxTetromino )
   PUBLIC nBlockSizePixel := 25
   PUBLIC aRGBcolor := { CYAN, BLUE, ORANGE, YELLOW, GREEN, PURPLE, RED }

   DEFINE WINDOW Win1 ;
         AT 0, 0 ;
         WIDTH 800 ;
         HEIGHT 600 ;
         TITLE "HMG TETRIS" ;
         MAIN ;
         NOMAXIMIZE ;
         NOSIZE ;
         ON INIT Proc_On_Init () ;
         ON RELEASE Proc_On_Release () ;
         ON PAINT Proc_ON_Paint ()

      DEFINE MAIN MENU
         DEFINE POPUP "Game"
            MENUITEM "New Game" ACTION NewGame()
            SEPARATOR
            MENUITEM "Pause/Resume" ACTION PauseGame()
            SEPARATOR
            MENUITEM "Exit" ACTION Win1.Release()
         END POPUP
         DEFINE POPUP "Help"
            MENUITEM "Keys" ACTION MsgInfo( "Arrows: move tetrominoes" + CRLF + "F2: new game" + CRLF + "F5: pause/resume", "Keys" )
            SEPARATOR
            MENUITEM "Author" ACTION MsgInfo( "HMG TETRIS" + CRLF + "(c) 2020 by Dr. CLAUDIO SOTO" + CRLF + "srvet@adinet.com.uy" + CRLF + "http://srvet.blogspot.com", "About" )
         END POPUP
      END MENU

      ON KEY LEFT ACTION ActionMove( _LEFT )
      ON KEY RIGHT ACTION ActionMove( _RIGHT )
      ON KEY UP ACTION ActionMove( ROTATE )
      ON KEY DOWN ACTION ActionMove( _DOWN )

      ON KEY F2 ACTION NewGame()
      ON KEY F5 ACTION PauseGame()

      DEFINE TIMER Timer1 INTERVAL nInterval ACTION ActionMove( _DOWN )

      DEFINE STATUSBAR
         STATUSITEM ""
         STATUSITEM "" WIDTH 80
         STATUSITEM "" WIDTH 90
      END STATUSBAR

   END WINDOW

   CENTER WINDOW Win1
   ACTIVATE WINDOW Win1

RETURN NIL


PROCEDURE Proc_On_Init

   LOCAL hDC, BTstruct
   LOCAL i, nLine := 2

   FOR i := 1 TO nMaxTetromino
      hBitmapBlock[ i ] := BT_BitmapCreateNew ( nBlockSizePixel, nBlockSizePixel, aRGBcolor[ i ] )
      hDC := BT_CreateDC ( hBitmapBlock[ i ], BT_HDC_BITMAP, @BTstruct )
      BT_DrawRectangle ( hDC, 0, 0, nBlockSizePixel - nLine, nBlockSizePixel - nLine, WHITE, nLine )
      BT_DeleteDC ( BTstruct )
   NEXT

   hBitmapBackground := BT_BitmapCreateNew ( nBlockSizePixel * nMaxCol, nBlockSizePixel * nMaxRow, BLACK )
   hBitmapBuffer := BT_BitmapCreateNew ( nBlockSizePixel * nMaxCol, nBlockSizePixel * nMaxRow, BLACK )
   hDC := BT_CreateDC ( hBitmapBackground, BT_HDC_BITMAP, @BTstruct )
   BT_DrawGradientFillVertical ( hDC, 0, 0, nBlockSizePixel * nMaxCol, nBlockSizePixel * nMaxRow, WHITE, BLACK )
   BT_DeleteDC ( BTstruct )
   DrawBitmapBoard()

RETURN


PROCEDURE Proc_On_Release

   LOCAL i

   FOR i := 1 TO nMaxTetromino
      BT_BitmapRelease ( hBitmapBlock[ i ] )
   NEXT
   BT_BitmapRelease ( hBitmapBackground )
   BT_BitmapRelease ( hBitmapBuffer )

RETURN


PROCEDURE Proc_On_Paint

   LOCAL hDC, BTstruct
   LOCAL Width := BT_ClientAreaWidth ( "Win1" )
   LOCAL Height := BT_ClientAreaHeight ( "Win1" )
   LOCAL x := ( Width - nBlockSizePixel * nMaxCol ) / 2
   LOCAL y := ( Height - nBlockSizePixel * nMaxRow ) / 2

   hDC := BT_CreateDC ( "Win1", BT_HDC_INVALIDCLIENTAREA, @BTstruct )
   BT_DrawBitmap ( hDC, y, x, NIL, NIL, BT_COPY, hBitmapBuffer )
   BT_DeleteDC ( BTstruct )

RETURN


PROCEDURE DrawBitmapBoard()

   LOCAL nColor, y, x

   BT_BitmapPaste ( hBitmapBuffer, NIL, NIL, NIL, NIL, BT_COPY, hBitmapBackground )
   FOR y := 1 TO nMaxRow
      FOR x := 1 TO nMaxCol
         nColor := aBuffer[ y ][ x ]
         IF nColor > 0
            BT_BitmapPaste ( hBitmapBuffer, ( y - 1 ) * nBlockSizePixel, ( x - 1 ) * nBlockSizePixel, nBlockSizePixel, nBlockSizePixel, BT_COPY, hBitmapBlock[ nColor ] )
         ENDIF
      NEXT
   NEXT
   IF lGameOver
      DrawGameOver()
   ENDIF
   BT_ClientAreaInvalidateAll ( "Win1" )

   Win1.StatusBar.Item( 1 ) := "Tetrominoes: " + hb_ntos( nContTeromino )
   Win1.StatusBar.Item( 2 ) := "Points: " + hb_ntos( Int ( nPoints ) )
   Win1.StatusBar.Item( 3 ) := "Record: " + hb_ntos( Int ( nRecord ) )

RETURN


PROCEDURE DrawGameOver

   LOCAL hDC, BTstruct
   LOCAL nTypeText
   LOCAL nAlingText
   LOCAL nOrientation

   hDC := BT_CreateDC ( hBitmapBuffer, BT_HDC_BITMAP, @BTstruct )
   nTypeText := BT_TEXT_OPAQUE + BT_TEXT_BOLD
   nAlingText := BT_TEXT_LEFT + BT_TEXT_TOP
   nOrientation := BT_TEXT_NORMAL_ORIENTATION
   BT_DrawText ( hDC, 200, 50, " GAME OVER ", "Times New Roman", 18, RED, BLACK, nTypeText, nAlingText, nOrientation )
   BT_DeleteDC ( BTstruct )

RETURN


*******************************
* My generic Tetris algorithm *
*******************************

PROCEDURE CreateVars()

   LOCAL i, k

 /*  e.g. J tetromino := 0x44C0
          0100 := 0x4
          0100 := 0x4
          1100 := 0xC
          0000 := 0x0
 */

   // Rotate      0       90      180     270 degree
   LOCAL _I := { 0x0F00, 0x2222, 0x00F0, 0x4444 }
   LOCAL _J := { 0x44C0, 0x8E00, 0x6440, 0x0E20 }
   LOCAL _L := { 0x4460, 0x0E80, 0xC440, 0x2E00 }
   LOCAL _O := { 0xCC00, 0xCC00, 0xCC00, 0xCC00 }
   LOCAL _S := { 0x06C0, 0x8C40, 0x6C00, 0x4620 }
   LOCAL _T := { 0x0E40, 0x4C40, 0x4E00, 0x4640 }
   LOCAL _Z := { 0x0C60, 0x4C80, 0xC600, 0x2640 }

   PUBLIC aTetromino := { _I, _J, _L, _O, _S, _T, _Z }

   PUBLIC nBlockSize := 4 // array 4x4 elements FOR each tetromino
   PUBLIC nMaxRow := 20
   PUBLIC nMaxCol := 10
   PUBLIC nRow := 0
   PUBLIC nCol := 0
   PUBLIC nIndex := 1
   PUBLIC nRot := 1
   PUBLIC aBoard := createArray2D( nMaxRow, nMaxCol )
   PUBLIC aBuffer := createArray2D( nMaxRow, nMaxCol )
   PUBLIC aCurrentTetromino := createArray2D( nBlockSize, nBlockSize )
   PUBLIC _aux := createArray2D( nBlockSize, nBlockSize )
   PUBLIC nPoints := 0
   PUBLIC nRecord := 0
   PUBLIC lPause := .T.
   PUBLIC lGameOver := .F.
   PUBLIC nInterval := 700
   PUBLIC nContTeromino := 0
   PUBLIC nMaxTetromino := Len( aTetromino )

   // create array with all Tetrominoes ( 7 tetromino x 4 rotation )
   FOR i := 1 TO nMaxTetromino
      FOR k := 1 TO nBlockSize
         BitToArray( _aux, aTetromino[ i ][ k ], i )
         aTetromino[ i ][ k ] := createArray2D( nBlockSize, nBlockSize )
         CopyArray( aTetromino[ i ][ k ], 1, 1, nBlockSize, nBlockSize, _aux )
      NEXT
   NEXT

RETURN


PROCEDURE BitToArray( dest, Value, nColor )

   LOCAL x, y, nBit

   nBit := ( nBlockSize * nBlockSize ) - 1
   FOR y = 1 TO nBlockSize
      FOR x = 1 TO nBlockSize
         dest[ y ][ x ] = iif( hb_bitTest( Value, nBit-- ), nColor, 0 )
      NEXT
   NEXT

RETURN


FUNCTION createArray2D( h, w )

   LOCAL i, aNew

   aNew := Array( h )
   FOR i = 1 TO h
      aNew[ i ] := Array( w )
      AFill( aNew[ i ], 0 )
   NEXT

RETURN aNew


PROCEDURE PasteTetromino( dest, nRow, nCol, src )

   LOCAL y, x, CONT := iif( nRow == 1, 0, 1 )

   FOR y = 1 TO nBlockSize
      FOR x = 1 TO nBlockSize
         IF src[ y ][ x ] > 0
            dest[ nRow + y - 1 ][ nCol + x - 1 ] = src[ y ][ x ]
            CONT++
         ENDIF
      NEXT
      IF CONT == 0
         nRow--
      ENDIF
   NEXT

RETURN


PROCEDURE CopyArray( dest, nRow, nCol, h, w, src )

   LOCAL x, y

   FOR y = 1 TO h
      FOR x = 1 TO w
         dest[ nRow + y - 1 ][ nCol + x - 1 ] := src[ y ][ x ]
      NEXT
   NEXT

RETURN


FUNCTION isOcupped( dest, nRow, nCol, src )

   LOCAL x, y, x2, y2

   FOR y = 1 TO nBlockSize
      FOR x = 1 TO nBlockSize
         IF src[ y ][ x ] > 0
            y2 := nRow + ( y - 1 )
            x2 := nCol + ( x - 1 )
            IF ( ( x2 < 1 ) .OR. ( x2 > nMaxCol ) .OR. ( y2 < 1 ) .OR. ( y2 > nMaxRow ) )
               RETURN .T.
            ENDIF
            IF( dest[ y2 ][ x2 ] > 0 )
               RETURN .T.
            ENDIF
         ENDIF
      NEXT
   NEXT

RETURN .F.


FUNCTION isFinish()

   LOCAL x

   FOR x = 1 TO nMaxCol
      IF aBoard[ 1 ][ x ] > 0
         RETURN .T.
      ENDIF
   NEXT

RETURN .F.


FUNCTION RemoveLines()

   LOCAL nLines, y, y2, x, x2, CONT

   nLines := 0
   FOR y = 1 TO nMaxRow
      cont = 0
      FOR x = 1 TO nMaxCol
         IF aBoard[ y ][ x ] > 0
            CONT++
         ENDIF
      NEXT
      IF CONT == nMaxCol
         FOR y2 = y TO 2 STEP -1
            FOR x2 = 1 TO nMaxCol
               aBoard[ y2 ][ x2 ] := aBoard[ y2 - 1 ][ x2 ]
            NEXT
         NEXT
         nLines++
      ENDIF
   NEXT

RETURN nLines


PROCEDURE NewTetromino()

   nIndex := Int( RANDOM() % nMaxTetromino + 1 )
   nRot := Int( RANDOM() % nBlockSize + 1 )
   CopyArray( aCurrentTetromino, 1, 1, nBlockSize, nBlockSize, aTetromino[ nIndex ][ nRot ] )
   nContTeromino++
   nRow := 1
   nCol := 4

RETURN


PROCEDURE UpdateRecord()

   IF nPoints > nRecord
      nRecord := nPoints
   ENDIF

RETURN


PROCEDURE NewGame()

   LOCAL i

   UpdateRecord()
   nPoints := 0
   nContTeromino := 0
   FOR i = 1 TO nMaxRow
      AFill( aBoard[ i ], 0 )
   NEXT
   NewTetromino()
   lGameOver := .F.
   lPause := .F.
   DrawBoard()

RETURN


PROCEDURE GameOver()

   UpdateRecord()
   lGameOver := .T.
   lPause := .F.

RETURN


PROCEDURE PauseGame()

   IF lGameOver == .F.
      lPause := ! lPause
   ENDIF

RETURN


PROCEDURE ActionMove( n )

   STATIC flagInto := .F.
   LOCAL lRepaint := .F., nRemoveLines

   IF flagInto == .T.
      RETURN // avoid re-entry
   ENDIF
   flagInto := .T.

   IF lGameOver == .T. .OR. lPause == .T.
      flagInto := .F.
      RETURN
   ENDIF

   SWITCH n
   CASE _LEFT
      // move left
      IF ! isOcupped( aBoard, nRow, nCol - 1, aCurrentTetromino )
         nCol--
         lRepaint := .T.
      ENDIF
      EXIT
   CASE _RIGHT
      // move right
      IF ! isOcupped( aBoard, nRow, nCol + 1, aCurrentTetromino )
         nCol++
         lRepaint := .T.
      ENDIF
      EXIT
   CASE ROTATE
      IF ++nRot > nBlockSize
         nRot := 1
      ENDIF
      CopyArray( _aux, 1, 1, nBlockSize, nBlockSize, aTetromino[ nIndex ][ nRot ] )
      IF ! isOcupped( aBoard, nRow, nCol, _aux )
         CopyArray( aCurrentTetromino, 1, 1, nBlockSize, nBlockSize, _aux )
         lRepaint := .T.
      ENDIF
      EXIT
   CASE _DOWN
      // move down
      IF ! isOcupped( aBoard, nRow + 1, nCol, aCurrentTetromino )
         nRow++
         lRepaint := .T.
      ELSE
         lRepaint := .T.
         nRemoveLines := RemoveLines()
         nPoints += nRemoveLines ^ 2 * 100
         IF isFinish()
            GameOver()
         ELSE
            PasteTetromino( aBoard, nRow, nCol, aCurrentTetromino )
            nRemoveLines := RemoveLines()
            nPoints += nRemoveLines ^ 2 * 100
            IF isFinish()
               GameOver()
            ELSE
               NewTetromino()
               IF isOcupped( aBoard, nRow, nCol, aCurrentTetromino )
                  GameOver()
               ENDIF
            ENDIF
         ENDIF
      ENDIF

   ENDSWITCH

   IF lRepaint == .T.
      DrawBoard()
   ENDIF

   flagInto := .F.

RETURN


PROCEDURE DrawBoard()

   CopyArray( aBuffer, 1, 1, nMaxRow, nMaxCol, aBoard )
   PasteTetromino( aBuffer, nRow, nCol, aCurrentTetromino )
   DrawBitmapBoard() // draw current board

RETURN
