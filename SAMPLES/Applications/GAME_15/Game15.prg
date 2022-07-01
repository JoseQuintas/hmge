/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Game 15'
#define VERSION ' version 2.3'
#define COPYRIGHT ' 2003-2009 Grigory Filatov'

#define IDI_MAIN 1001
// #define DEBUG

STATIC n := 4, aData := {}, cUserName := "NoName", aBase := { { "NAME", "C", 30, 0 }, { "RESULT", "N", 6, 0 } }
STATIC aKeys

FIELD NAME, RESULT
*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
   SET MULTIPLE OFF WARNING

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 317 ;
         HEIGHT 394 ;
         TITLE PROGRAM + VERSION ;
         ICON IDI_MAIN ;
         MAIN ;
         NOMINIMIZE NOMAXIMIZE ;
         NOSIZE NOCAPTION ;
         ON INIT OpenTopTable() ;
         ON RELEASE ( dbCloseAll(), ;
         FErase( "Game1" + IndexExt() ), FErase( "Game2" + IndexExt() ) ) ;
         FONT "Arial" ;
         SIZE 10

      @ 0, 0 IMAGE Main_1 ;
         PICTURE "MAIN" ;
         WIDTH Form_1.WIDTH HEIGHT Form_1.HEIGHT

      @ 10, 8 LABEL Label_1 VALUE Space( 6 ) + PROGRAM + VERSION ;
         WIDTH 266 HEIGHT 16 ;
         ACTION InterActiveMoveHandle( GetFormHandle( "Form_1" ) ) ;
         FONT "Arial" ;
         SIZE 12 ;
         BOLD ;
         FONTCOLOR WHITE ;
         TRANSPARENT ;
         CENTERALIGN

      @ 12, Form_1.WIDTH - 42 BUTTON MINIMIZE ;
         PICTURE "MINBTN" ;
         ACTION Form_1.MINIMIZE ;
         WIDTH 14 HEIGHT 14

      @ 12, Form_1.WIDTH - 26 BUTTON RELEASE ;
         PICTURE "CLOSEBTN" ;
         ACTION Form_1.Release() ;
         WIDTH 14 HEIGHT 14

      LoadData()

      @ 36, 14 BUTTON Button_1 PICTURE "Load" ;
         ACTION LoadGame() ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "Load a game" ;
         FLAT ;
         NOXPSTYLE NOTRANSPARENT

      @ 36, 110 BUTTON Button_2 PICTURE "Start" ;
         ACTION StartAgain() ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "Start of new game" ;
         FLAT ;
         NOXPSTYLE NOTRANSPARENT

      @ 36, 206 BUTTON Button_3 PICTURE "Save" ;
         ACTION SaveGame() ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "Save a game" ;
         FLAT ;
         NOXPSTYLE NOTRANSPARENT

      @ Form_1.HEIGHT - 32, 14 BUTTON Button_4 ;
         PICTURE "About" ;
         ACTION MsgAbout() ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "About" ;
         FLAT ;
         NOXPSTYLE NOTRANSPARENT

      @ Form_1.HEIGHT - 32, 110 BUTTON Button_5 ;
         PICTURE "Top" ;
         ACTION LoadTop() ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "Top Table" ;
         FLAT ;
         NOXPSTYLE NOTRANSPARENT

      @ Form_1.HEIGHT - 32, 206 BUTTON Button_6 ;
         PICTURE "Exit" ;
         ACTION Form_1.Release() ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "Exit" ;
         FLAT ;
         NOXPSTYLE NOTRANSPARENT

      ON KEY ALT + L ACTION LoadGame()
      ON KEY ALT + T ACTION StartAgain()
      ON KEY ALT + S ACTION SaveGame()
      ON KEY ALT + B ACTION MsgAbout()
      ON KEY ALT + 1 ACTION LoadTop()
      ON KEY ALT + X ACTION Form_1.Release()

#ifdef DEBUG
      ON KEY ALT + W ACTION LoadWin()

#endif

   END WINDOW

   Form_1.Button_1.Enabled := ( Len( Directory( "*.sav" ) ) > 0 )
   Form_1.Button_2.SetFocus

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE PressButton()
*--------------------------------------------------------*
   LOCAL cCapt := This.PICTURE, nPress, nFree
   LOCAL row, col, nr, fl := .F.

   nFree := AScan( aData, {| x | x[ 1 ] == "B16" } )
   nPress := AScan( aData, {| x | x[ 1 ] == cCapt } )

   IF Abs( nFree - nPress ) == n .OR. Abs( nFree - nPress ) == 1
      SwapButtons( nPress, nFree )
      FOR row := 1 TO n
         FOR col := 1 TO n
            nr := ( row - 1 ) * n + col
            IF nr == n * n
               EXIT
            ENDIF
            IF Val( SubStr( aData[ nr ][ 1 ], 2 ) ) # ( col - 1 ) * n + row
               fl := .T.
               PlayBeep()
               EXIT
            ENDIF
         NEXT
         IF fl
            EXIT
         ENDIF
      NEXT
      IF ! fl
         SaveResult()
      ENDIF
   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SwapButtons( nPress, nFree )
*--------------------------------------------------------*
   LOCAL cPress := aData[ nPress ][ 2 ], cFree := aData[ nFree ][ 2 ]
   LOCAL swap, nOnRow, nOnCol, nToRow, nToCol

   swap := aData[ nFree ][ 1 ]

   aData[ nFree ][ 1 ] := aData[ nPress ][ 1 ]
   aData[ nFree ][ 2 ] := cPress

   aData[ nPress ][ 1 ] := swap
   aData[ nPress ][ 2 ] := cFree

   nOnRow := GetProperty( "Form_1", cPress, "Row" )
   nOnCol := GetProperty( "Form_1", cPress, "Col" )
   nToRow := GetProperty( "Form_1", cFree, "Row" )
   nToCol := GetProperty( "Form_1", cFree, "Col" )

   SetProperty( "Form_1", cPress, "Row", nToRow )
   SetProperty( "Form_1", cPress, "Col", nToCol )
   SetProperty( "Form_1", cFree, "Row", nOnRow )
   SetProperty( "Form_1", cFree, "Col", nOnCol )

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE StartAgain()
*--------------------------------------------------------*
   LOCAL nr, cButton

   FOR nr := 1 TO n * n
      cButton := "Number_" + StrZero( nr, 2 )
      DoMethod( "Form_1", cButton, "Release" )
   NEXT

   aData := {}
   LoadData()

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SaveGame()
*--------------------------------------------------------*
   LOCAL cCurDir := CurDrive() + ":\" + CurDir()
   LOCAL cSaveFile := PutFile ( { { "Save files (*.sav)", "*.sav" } }, ;
      'Save a Game To File', cCurDir, .T. )

   IF ! Empty( cSaveFile )

      DirChange( cCurDir )

      cSaveFile := cFileNoExt( cSaveFile ) + ".sav"

      BEGIN INI FILE cSaveFile
         SET SECTION "Game" ENTRY "Save" TO aData
      END INI

      Form_1.Button_1.Enabled := .T.

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE LoadGame()
*--------------------------------------------------------*
   LOCAL cCurDir := CurDrive() + ":\" + CurDir()
   LOCAL row, col, nr, cButton, cCaption
   LOCAL cSaveFile

   IF Form_1.Button_1.Enabled == .T.

      cSaveFile := GetFile ( { { "Save files (*.sav)", "*.sav" } }, ;
         'Load a Game From File', cCurDir, , .T. )

      IF ! Empty( cSaveFile )

         DirChange( cCurDir )

         aData := {}
         cSaveFile := cFileNoExt( cSaveFile ) + ".sav"

         BEGIN INI FILE cSaveFile
            GET aData SECTION "Game" ENTRY "Save"
         END INI

         FOR nr := 1 TO n * n
            cButton := "Number_" + StrZero( nr, 2 )
            DoMethod( "Form_1", cButton, "Release" )
         NEXT

         FOR row := 1 TO n
            FOR col := 1 TO n
               nr := ( row - 1 ) * n + col
               cCaption := aData[ nr ][ 1 ]
               cButton := aData[ nr ][ 2 ]
               @ (col - 1 ) * 72 + 64, ( row - 1 ) * 72 + 15 BUTTON &cButton ;
                  OF Form_1 ;
                  PICTURE cCaption ;
                  ACTION PressButton() ;
                  WIDTH 72 HEIGHT 72
            NEXT
         NEXT

      ENDIF

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE LoadData()
*--------------------------------------------------------*
   LOCAL row, col, nr, cButton, cCaption, aBtn := LoadArray()

   FOR row := 1 TO n
      FOR col := 1 TO n
         nr := ( row - 1 ) * n + col
         cCaption := "B" + LTrim( Str( aBtn[ nr ], 2 ) )
         cButton := "Number_" + StrZero( aBtn[ nr ], 2 )
         @ (col - 1 ) * 72 + 64, ( row - 1 ) * 72 + 15 BUTTON &cButton ;
            OF Form_1 ;
            PICTURE cCaption ;
            ACTION PressButton() ;
            WIDTH 72 HEIGHT 72
         AAdd( aData, { cCaption, cButton } )
      NEXT
   NEXT

RETURN

*--------------------------------------------------------*
STATIC FUNCTION LoadArray()
*--------------------------------------------------------*
   LOCAL x, i := 1, aArr := {}

   DO WHILE i <= n * n
      x := Round( Random( 32767 ) / 32767 * n * n, 0 )
      IF AScan( aArr, x ) == 0 .AND. x > 0
         AAdd( aArr, x )
         i++
      ENDIF
   ENDDO

RETURN aArr

#ifdef DEBUG
*--------------------------------------------------------*
STATIC PROCEDURE LoadWin()
*--------------------------------------------------------*
   LOCAL row, col, nr, nBtn, cButton, cCaption

   FOR nr := 1 TO n * n
      cButton := "Number_" + StrZero( nr, 2 )
      DoMethod( "Form_1", cButton, "Release" )
   NEXT

   FOR row := 1 TO n
      FOR col := 1 TO n
         nr := ( row - 1 ) * n + col
         nBtn := ( col - 1 ) * n + row
         cButton := "Number_" + StrZero( nBtn, 2 )
         cCaption := "B" + LTrim( Str( nBtn, 2 ) )
         @ (col - 1 ) * 72 + 64, ( row - 1 ) * 72 + 15 BUTTON &cButton ;
            OF Form_1 ;
            PICTURE cCaption ;
            ACTION PressButton() ;
            WIDTH 72 HEIGHT 72
         aData[ nr ][ 1 ] := cCaption
         aData[ nr ][ 2 ] := cButton
      NEXT
   NEXT

RETURN

#endif

*--------------------------------------------------------*
PROCEDURE OpenTopTable()
*--------------------------------------------------------*
   LOCAL cDataBase := "Game15.dat", lFirst := .F.

   IF ! File( cDataBase )
      dbCreate( cDataBase, aBase )
      lFirst := .T.
   ENDIF

   USE ( cDataBase ) NEW EXCLUSIVE

   IF ! NetErr()
      IF ! File( "Game2" + IndexExt() )
         INDEX ON Upper( FIELD->NAME ) TO Game2
      ENDIF
      IF ! File( "Game1" + IndexExt() )
         INDEX ON Descend( FIELD->RESULT ) TO Game1
      ENDIF
      SET INDEX TO Game1, Game2
   ELSE
      MsgStop( "Data file is locked", "Please, try again" )
      RETURN
   ENDIF

   IF lFirst
      APPEND BLANK
      NAME := "Author"
      RESULT := 100
      APPEND BLANK
      NAME := "NoName"
      RESULT := 0
   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SaveResult()
*--------------------------------------------------------*
   LOCAL cName := cUserName, n

   PlayOK()
   cName := LTrim( InputBox( 'Enter your name:', 'Save Result', cName, 15000, cName ) )

   IF Empty( cName )
      cName := "NoName"
   ELSE
      cUserName := cName
   ENDIF

   SET ORDER TO 2
   SEEK Upper( cName )
   IF Found()
      n := RESULT
      RESULT := ++n
   ELSE
      APPEND BLANK
      NAME := cName
      RESULT := 1
   ENDIF
   SET ORDER TO 1

   StartAgain()

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE LoadTop()
*--------------------------------------------------------*
   LOCAL aResult := {}, nr, cButton, cLabel

   If ! IsControlDefined( Button_7, Form_1 )

      aKeys := SAVEONKEY()

      GO TOP
      DO WHILE RecNo() <= 10 .AND. ! Eof()
         AAdd( aResult, PadR( AllTrim( NAME ), 50, '.' ) + " " + ;
            LTrim( Str( RESULT ) ) )
         SKIP
      ENDDO

      FOR nr := 1 TO 6
         cButton := "Button_" + LTrim( Str( nr, 2 ) )
         DoMethod( "Form_1", cButton, "Hide" )
      NEXT

      FOR nr := 1 TO n * n
         cButton := "Number_" + StrZero( nr, 2 )
         DoMethod( "Form_1", cButton, "Hide" )
      NEXT

      @ Form_1.HEIGHT - 32, 62 BUTTON Button_7 ;
         OF Form_1 ;
         PICTURE "OK" ;
         ACTION ClearTop() ;
         WIDTH 96 HEIGHT 24 FLAT ;
         NOXPSTYLE NOTRANSPARENT

      @ Form_1.HEIGHT - 32, 164 BUTTON Button_8 ;
         OF Form_1 ;
         PICTURE "Clear" ;
         ACTION ClearTop( .T. ) ;
         WIDTH 96 HEIGHT 24 ;
         TOOLTIP "Clear Top Table" FLAT ;
         NOXPSTYLE NOTRANSPARENT

      FOR nr := 1 TO Len( aResult )

         cLabel := "Label_" + StrZero( nr, 2 )
         @ (nr - 1 ) * 32 + 42, 16 LABEL &cLabel ;
            OF Form_1 ;
            VALUE aResult[ nr ] ;
            WIDTH 280 HEIGHT 16 ;
            FONT "Arial" ;
            SIZE 12 ;
            BOLD ;
            FONTCOLOR WHITE ;
            TRANSPARENT
      NEXT

      Form_1.Button_7.SetFocus

      RedrawWindow( _HMG_MainHandle )

      ON KEY ALT + O OF Form_1 ACTION ClearTop()
      ON KEY ALT + C OF Form_1 ACTION ClearTop( .T. )

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE ClearTop( lClear )
*--------------------------------------------------------*
   LOCAL nr, cButton, cLabel

DEFAULT lClear := .F.

   IF lClear
      GO 2
      DELETE NEXT ( LastRec() - 1 )
      PACK
   ENDIF

   RELEASE KEY ALT + O OF Form_1
   RELEASE KEY ALT + C OF Form_1

   Form_1.Button_7.Release()
   Form_1.Button_8.Release()

   FOR nr := 1 TO 6
      cButton := "Button_" + LTrim( Str( nr, 2 ) )
      DoMethod( "Form_1", cButton, "Show" )
   NEXT

   FOR nr := 1 TO n * n
      cButton := "Number_" + StrZero( nr, 2 )
      DoMethod( "Form_1", cButton, "Show" )
   NEXT

   FOR nr := 1 TO 10
      cLabel := "Label_" + StrZero( nr, 2 )
      IF IsControlDefined( &cLabel, Form_1 )
         DoMethod( "Form_1", cLabel, "Release" )
      ELSE
         EXIT
      ENDIF
   NEXT

   RESTONKEY( aKeys )

   RedrawWindow( _HMG_MainHandle )

RETURN

*--------------------------------------------------------*
STATIC FUNCTION MsgAbout()
*--------------------------------------------------------*

RETURN MsgInfo( PadC( PROGRAM + VERSION, 38 ) + CRLF + ;
      PadC( "Copyright " + Chr( 169 ) + COPYRIGHT, 40 ) + CRLF + CRLF + ;
      hb_Compiler() + CRLF + ;
      Version() + CRLF + ;
      SubStr( MiniGuiVersion(), 1, 38 ) + CRLF + CRLF + ;
      PadC( "This program is Freeware!", 38 ) + CRLF + ;
      PadC( "Copying is allowed!", 42 ), "About", IDI_MAIN, .F. )

*--------------------------------------------------------*
STATIC FUNCTION SAVEONKEY()
*--------------------------------------------------------*
   LOCAL bKeyBlock, abSaveKeys := {}

   STORE KEY ALT + L OF Form_1 TO bKeyBlock
   AAdd( abSaveKeys, bKeyBlock )
   RELEASE KEY ALT + L OF Form_1

   STORE KEY ALT + T OF Form_1 TO bKeyBlock
   AAdd( abSaveKeys, bKeyBlock )
   RELEASE KEY ALT + T OF Form_1

   STORE KEY ALT + S OF Form_1 TO bKeyBlock
   AAdd( abSaveKeys, bKeyBlock )
   RELEASE KEY ALT + S OF Form_1

   STORE KEY ALT + B OF Form_1 TO bKeyBlock
   AAdd( abSaveKeys, bKeyBlock )
   RELEASE KEY ALT + B OF Form_1

   AAdd( abSaveKeys, Form_1.FocusedControl )

RETURN abSaveKeys

*--------------------------------------------------------*
STATIC PROCEDURE RESTONKEY( abSaveKeys )
*--------------------------------------------------------*
   LOCAL cBtnFocus

   ON KEY ALT + L OF Form_1 ACTION Eval ( abSaveKeys[ 1 ] )
   ON KEY ALT + T OF Form_1 ACTION Eval ( abSaveKeys[ 2 ] )
   ON KEY ALT + S OF Form_1 ACTION Eval ( abSaveKeys[ 3 ] )
   ON KEY ALT + B OF Form_1 ACTION Eval ( abSaveKeys[ 4 ] )

   cBtnFocus := abSaveKeys[ 5 ]
   Form_1.&( cBtnFocus ).SetFocus

RETURN

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( INTERACTIVEMOVEHANDLE )
{
   keybd_event(
     VK_RIGHT, // virtual-key code
           0,  // hardware scan code
           0,  // flags specifying various function options
           0   // additional data associated with keystroke
      );
   keybd_event(
      VK_LEFT, // virtual-key code
           0,  // hardware scan code
           0,  // flags specifying various function options
           0   // additional data associated with keystroke
      );

   SendMessage( ( HWND ) hb_parnl(1), WM_SYSCOMMAND, SC_MOVE, 10 );
}

#pragma ENDDUMP
