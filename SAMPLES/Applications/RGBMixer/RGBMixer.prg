/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007-2009 Grigory Filatov <gfilatov@gmail.com>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'RGBMixer'
#define VERSION ' version 1.0'
#define COPYRIGHT ' Grigory Filatov, 2007'

#define MsgAlert( c ) MsgExclamation( c, "Error" )
#define NTRIM( n )    hb_ntos( n )

#define IDI_MAIN 1001

STATIC cIniFile, cRGBHexColor := "#7D7D7D", nStepping := 5

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
   LOCAL r, g, b

   SET MULTIPLE OFF WARNING
   SET DECIMAL TO

   cIniFile := GetStartupFolder() + "\" + PROGRAM + ".ini"

   IF File( cIniFile )

      BEGIN INI FILE cIniFile

         GET cRGBHexColor SECTION PROGRAM ENTRY "RGBHexColor" DEFAULT cRGBHexColor
         GET nStepping SECTION PROGRAM ENTRY "Stepping" DEFAULT nStepping

      END INI

   ENDIF

   r := HEXATODEC( SubStr( cRGBHexColor, 2, 2 ) )
   g := HEXATODEC( SubStr( cRGBHexColor, 4, 2 ) )
   b := HEXATODEC( Right( cRGBHexColor, 2 ) )

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 375 ;
         HEIGHT iif( _HMG_IsXP, 290, 282 ) ;
         TITLE PROGRAM ;
         ICON IDI_MAIN ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         ON RELEASE SaveConfig() ;
         FONT 'MS Sans Serif' SIZE 8

      DEFINE MAIN MENU

         POPUP "&File"

            ITEM '&Copy to Clipboard' + Chr( 9 ) + 'Enter' ACTION CopyToClipboard( cRGBHexColor )
            SEPARATOR
            ITEM 'E&xit' + Chr( 9 ) + 'Alt+X' ACTION ThisWindow.Release()

         END POPUP

         POPUP "&Options"

            ITEM 'Stepping: &1' + Chr( 9 ) + 'F2' ACTION ChangeStepping( 1 ) NAME f2
            ITEM 'Stepping: &5' + Chr( 9 ) + 'F3' ACTION ChangeStepping( 5 ) NAME f3
            ITEM 'Stepping: 51 (&216 colors)' + Chr( 9 ) + 'F4' ACTION ChangeStepping( 51 ) NAME f4

         END POPUP

         POPUP "&?"

            ITEM 'A&bout' ACTION MsgAbout()

         END POPUP

      END MENU

      Form_1.f2.Checked := ( nStepping == 1 )
      Form_1.f3.Checked := ( nStepping == 5 )
      Form_1.f4.Checked := ( nStepping == 51 )

      DRAW RECTANGLE IN WINDOW Form_1 AT 4, 15 TO 204, 215 ;
         FILLCOLOR { r, g, b }

      @ 0, 245 LABEL Label_1 VALUE NTRIM( r ) ;
         WIDTH 32 ;
         HEIGHT 12

      @ 0, 290 LABEL Label_2 VALUE NTRIM( g ) ;
         WIDTH 32 ;
         HEIGHT 12

      @ 0, 335 LABEL Label_3 VALUE NTRIM( b ) ;
         WIDTH 32 ;
         HEIGHT 12

      @ 20, 235 SLIDER Slider_1 ;
         RANGE 0, 255 / nStepping ;
         VALUE r / nStepping ;
         WIDTH 32 ;
         HEIGHT 170 ;
         VERTICAL ;
         TOP ;
         ON CHANGE ChangeColor( 1, Form_1.Slider_1.Value ) ;
         TOOLTIP "Red"

      @ 20, 280 SLIDER Slider_2 ;
         RANGE 0, 255 / nStepping ;
         VALUE g / nStepping ;
         WIDTH 32 ;
         HEIGHT 170 ;
         VERTICAL ;
         TOP ;
         ON CHANGE ChangeColor( 2, Form_1.Slider_2.Value ) ;
         TOOLTIP "Green"

      @ 20, 325 SLIDER Slider_3 ;
         RANGE 0, 255 / nStepping ;
         VALUE b / nStepping ;
         WIDTH 32 ;
         HEIGHT 170 ;
         VERTICAL ;
         TOP ;
         ON CHANGE ChangeColor( 3, Form_1.Slider_3.Value ) ;
         TOOLTIP "Blue"

      @ 197, 245 IMAGE Image_1 PICTURE "RED" ;
         WIDTH 20 HEIGHT 8 ;
         ACTION Form_1.Slider_1.VALUE := IF( Form_1.Slider_1.VALUE == 255 / nStepping, 0, 255 / nStepping )

      @ 197, 290 IMAGE Image_2 PICTURE "GREEN" ;
         WIDTH 20 HEIGHT 8 ;
         ACTION Form_1.Slider_2.VALUE := IF( Form_1.Slider_2.VALUE == 255 / nStepping, 0, 255 / nStepping )

      @ 197, 335 IMAGE Image_3 PICTURE "BLUE" ;
         WIDTH 20 HEIGHT 8 ;
         ACTION Form_1.Slider_3.VALUE := IF( Form_1.Slider_3.VALUE == 255 / nStepping, 0, 255 / nStepping )

      DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8 KEYBOARD

      END STATUSBAR

      Form_1.StatusBar.Item( 1 ) := 'COLOR="' + cRGBHexColor + "'"

      DRAW BOX IN WINDOW Form_1 ;
         AT Form_1.Image_1.ROW - 1, Form_1.Image_1.COL - 1 ;
         TO Form_1.Image_1.ROW + 8, Form_1.Image_1.COL + 20

      DRAW BOX IN WINDOW Form_1 ;
         AT Form_1.Image_2.ROW - 1, Form_1.Image_2.COL - 1 ;
         TO Form_1.Image_2.ROW + 8, Form_1.Image_2.COL + 20

      DRAW BOX IN WINDOW Form_1 ;
         AT Form_1.Image_3.ROW - 1, Form_1.Image_3.COL - 1 ;
         TO Form_1.Image_3.ROW + 8, Form_1.Image_3.COL + 20

      ON KEY ALT + X ACTION ThisWindow.Release()
      ON KEY RETURN ACTION CopyToClipboard( cRGBHexColor )
      ON KEY F2 ACTION ChangeStepping( 1 )
      ON KEY F3 ACTION ChangeStepping( 5 )
      ON KEY F4 ACTION ChangeStepping( 51 )

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
PROCEDURE ChangeColor( n, color )
*--------------------------------------------------------*
   LOCAL r, g, b

   r := SubStr( cRGBHexColor, 2, 2 )
   g := SubStr( cRGBHexColor, 4, 2 )
   b := Right( cRGBHexColor, 2 )

   SetProperty( 'Form_1', 'Label_' + NTRIM( n ), 'Value', NTRIM( color * nStepping ) )
   color := DECTOHEXA( color * nStepping )
   color := iif( Len( color ) < 1, '00', iif( Len( color ) < 2, '0' + color, color ) )

   SWITCH n
   CASE 1
      cRGBHexColor := '#' + color + g + b
      EXIT
   CASE 2
      cRGBHexColor := '#' + r + color + b
      EXIT
   CASE 3
      cRGBHexColor := '#' + r + g + color
   END

   Form_1.StatusBar.Item( 1 ) := 'COLOR="' + cRGBHexColor + "'"

   r := HEXATODEC( SubStr( cRGBHexColor, 2, 2 ) )
   g := HEXATODEC( SubStr( cRGBHexColor, 4, 2 ) )
   b := HEXATODEC( Right( cRGBHexColor, 2 ) )

   ERASE WINDOW Form_1

   DRAW RECTANGLE IN WINDOW Form_1 ;
      AT 4, 15 TO 204, 215 ;
      FILLCOLOR { r, g, b }

   DRAW BOX IN WINDOW Form_1 ;
      AT Form_1.Image_1.ROW - 1, Form_1.Image_1.COL - 1 ;
      TO Form_1.Image_1.ROW + 8, Form_1.Image_1.COL + 20

   DRAW BOX IN WINDOW Form_1 ;
      AT Form_1.Image_2.ROW - 1, Form_1.Image_2.COL - 1 ;
      TO Form_1.Image_2.ROW + 8, Form_1.Image_2.COL + 20

   DRAW BOX IN WINDOW Form_1 ;
      AT Form_1.Image_3.ROW - 1, Form_1.Image_3.COL - 1 ;
      TO Form_1.Image_3.ROW + 8, Form_1.Image_3.COL + 20

RETURN

*--------------------------------------------------------*
PROCEDURE ChangeStepping( n )
*--------------------------------------------------------*
   LOCAL aColor := {}, i

   AAdd( aColor, HEXATODEC( SubStr( cRGBHexColor, 2, 2 ) ) )
   AAdd( aColor, HEXATODEC( SubStr( cRGBHexColor, 4, 2 ) ) )
   AAdd( aColor, HEXATODEC( Right( cRGBHexColor, 2 ) ) )

   nStepping := n
   Form_1.f2.Checked := ( nStepping == 1 )
   Form_1.f3.Checked := ( nStepping == 5 )
   Form_1.f4.Checked := ( nStepping == 51 )

   FOR i = 1 TO 3
      SetProperty( 'Form_1', 'Slider_' + NTRIM( i ), 'RangeMax', 255 / nStepping )
      SetProperty( 'Form_1', 'Slider_' + NTRIM( i ), 'Value', aColor[ i ] / nStepping )
   NEXT

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SaveConfig()
*--------------------------------------------------------*

   BEGIN INI FILE cIniFile

      SET SECTION PROGRAM ENTRY "RGBHexColor" TO cRGBHexColor
      SET SECTION PROGRAM ENTRY "Stepping" TO nStepping

   END INI

RETURN

*--------------------------------------------------------*
STATIC FUNCTION MsgAbout()
*--------------------------------------------------------*

RETURN MsgInfo( PadC( PROGRAM + VERSION, 40 ) + CRLF + ;
      "Copyright " + Chr( 169 ) + COPYRIGHT + CRLF + CRLF + ;
      hb_Compiler() + CRLF + ;
      Version() + CRLF + ;
      Left( MiniGuiVersion(), 38 ) + CRLF + CRLF + ;
      PadC( "This program is Freeware!", 38 ) + CRLF + ;
      PadC( "Copying is allowed!", 40 ), "About " + PROGRAM, IDI_MAIN, .F. )

#ifdef __XHARBOUR__
#include <hex.prg>
#endif
