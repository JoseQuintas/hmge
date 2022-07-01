/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com
 *
 * Copyright 2005-2019 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "hmg.ch"

#define PROGRAM 'XMas Lights'
#define VERSION ' version 1.0.1.0'
#define COPYRIGHT ' 2005-2019 Grigory Filatov'

#define NTRIM( n ) hb_ntos( n )
#define BMP_SIZE   32

STATIC aHandles := {}, aLights := {}
STATIC nSwitch := 1, lBusy := .F.

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*

   // Left Height
   AAdd( aLights, { "B121", "B115" } )
   AAdd( aLights, { "B120", "B114" } )
   AAdd( aLights, { "B122", "B116" } )
   AAdd( aLights, { "B115", "B121" } )
   AAdd( aLights, { "B114", "B120" } )
   AAdd( aLights, { "B116", "B122" } )
   AAdd( aLights, { "B122", "B116" } )
   AAdd( aLights, { "B115", "B121" } )

   // Top Width
   AAdd( aLights, { "B109", "B107" } )
   AAdd( aLights, { "B105", "B106" } )
   AAdd( aLights, { "B110", "B108" } )
   AAdd( aLights, { "B107", "B109" } )
   AAdd( aLights, { "B106", "B105" } )
   AAdd( aLights, { "B108", "B110" } )
   AAdd( aLights, { "B106", "B105" } )
   AAdd( aLights, { "B108", "B110" } )
   AAdd( aLights, { "B109", "B107" } )
   AAdd( aLights, { "B107", "B109" } )
   AAdd( aLights, { "B106", "B105" } )
   AAdd( aLights, { "B108", "B110" } )

   // Right Height
   AAdd( aLights, { "B112", "B118" } )
   AAdd( aLights, { "B117", "B111" } )
   AAdd( aLights, { "B113", "B119" } )
   AAdd( aLights, { "B118", "B112" } )
   AAdd( aLights, { "B111", "B117" } )
   AAdd( aLights, { "B119", "B113" } )
   AAdd( aLights, { "B111", "B117" } )
   AAdd( aLights, { "B119", "B113" } )

   SET MULTIPLE OFF

   DEFINE WINDOW Form_0 ;
         AT 0, 0 ;
         WIDTH 0 HEIGHT 0 ;
         TITLE PROGRAM ;
         ICON 'MAIN' ;
         MAIN ;
         NOSHOW ;
         ON INIT CreateForms() ;
         ON RELEASE AEval( aHandles, {| e | DeleteObject( e ) } ) ;
         NOTIFYICON 'MAIN' ;
         NOTIFYTOOLTIP PROGRAM ;
         ON NOTIFYCLICK HideShow()

      DEFINE TIMER Timer_0 INTERVAL 250 ACTION SetRegions() ONCE

   END WINDOW

   ACTIVATE WINDOW Form_0

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SetRegions()
*--------------------------------------------------------*
   LOCAL cForm, cResName, RegionHandle
   LOCAL enum

   IF ! lBusy

      lBusy := .T.

      FOR EACH enum IN aLights

         cForm := "Form_" + NTRIM( hb_enumIndex( enum ) )
         cResName := enum[ 1 ]

         DoMethod( cForm, "Show" )

         SET REGION OF &cForm BITMAP &cResName TRANSPARENT COLOR FUCHSIA TO RegionHandle

         AAdd( aHandles, RegionHandle )  // collect the Region handles for deleting on exit

      NEXT

      r_menu()

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE CreateForms()
*--------------------------------------------------------*
   LOCAL aDesk := GetDesktopArea()
   LOCAL nDeskWidth := aDesk[ 3 ] - aDesk[ 1 ], nDeskHeight := aDesk[ 4 ] - aDesk[ 2 ]
   LOCAL n := Int( nDeskHeight / 9 ), n1 := Int( nDeskWidth / 13 )
   LOCAL nTop := 0, nLeft := 0
   LOCAL aForms := {}
   LOCAL cForm, i, cImage

   CLEAN MEMORY

   // Left Height
   FOR i = 1 TO 8

      cForm := "Form_" + Str( i, 1 )
      cImage := "Image_" + Str( i, 1 )
      nTop += n

      DEFINE WINDOW &cForm ;
            AT nTop, nLeft ;
            WIDTH BMP_SIZE HEIGHT BMP_SIZE ;
            CHILD ;
            TOPMOST ;
            NOSHOW ;
            NOCAPTION ;
            NOMINIMIZE NOMAXIMIZE NOSIZE

         @ 0, 0 IMAGE &cImage ;
            PICTURE aLights[ i ][ 1 ] ;
            WIDTH BMP_SIZE HEIGHT BMP_SIZE

      END WINDOW

   NEXT

   // Top Width
   nTop := 0
   nLeft := 0

   FOR i = 9 TO 20

      cForm := "Form_" + NTRIM( i )
      cImage := "Image_" + NTRIM( i )
      nLeft += n1

      DEFINE WINDOW &cForm ;
            AT nTop, nLeft ;
            WIDTH BMP_SIZE HEIGHT BMP_SIZE ;
            CHILD ;
            TOPMOST ;
            NOSHOW ;
            NOCAPTION ;
            NOMINIMIZE NOMAXIMIZE NOSIZE

         @ 0, 0 IMAGE &cImage ;
            PICTURE aLights[ i ][ 1 ] ;
            WIDTH BMP_SIZE HEIGHT BMP_SIZE

      END WINDOW

   NEXT

   // Right Height
   nTop := 0
   nLeft := nDeskWidth - BMP_SIZE

   FOR i = 21 TO 28

      cForm := "Form_" + Str( i, 2 )
      cImage := "Image_" + Str( i, 2 )
      nTop += n

      DEFINE WINDOW &cForm ;
            AT nTop, nLeft ;
            WIDTH BMP_SIZE HEIGHT BMP_SIZE ;
            CHILD ;
            TOPMOST ;
            NOSHOW ;
            NOCAPTION ;
            NOMINIMIZE NOMAXIMIZE NOSIZE

         @ 0, 0 IMAGE &cImage ;
            PICTURE aLights[ i ][ 1 ] ;
            WIDTH BMP_SIZE HEIGHT BMP_SIZE

      END WINDOW

   NEXT

   DEFINE TIMER Timer_1 OF Form_1 INTERVAL 500 ACTION SwitchLights()

   AEval( Array( 28 ), {| x, i | x := NIL, AAdd( aForms, "Form_" + NTRIM( i ) ) } )

   _ActivateWindow ( aForms, .F. )

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE SwitchLights()
*--------------------------------------------------------*
   LOCAL enum, cIdx

   nSwitch := IF( nSwitch == 1, 2, 1 )

   IF lBusy

      FOR EACH enum IN aLights
         cIdx := NTRIM( hb_enumIndex( enum ) )
         SetProperty( "Form_" + cIdx, "Image_" + cIdx, 'Picture', enum[ nSwitch ] )
      NEXT

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE HideShow()
*--------------------------------------------------------*
   LOCAL enum

   IF IsWindowVisible( GetFormHandle( "Form_1" ) )

      lBusy := .F.

      FOR EACH enum IN aLights
         DoMethod( "Form_" + NTRIM( hb_enumIndex( enum ) ), "Hide" )
      NEXT

   ELSE

      lBusy := .T.

      FOR EACH enum IN aLights
         DoMethod( "Form_" + NTRIM( hb_enumIndex( enum ) ), "Show" )
      NEXT

   ENDIF

   r_menu()

RETURN

*--------------------------------------------------------*
STATIC PROCEDURE r_menu()
*--------------------------------------------------------*

   IF IsNotifyMenuDefined( "Form_0" )
      RELEASE NOTIFY MENU OF Form_0
   ENDIF

   DEFINE NOTIFY MENU OF Form_0

      ITEM IF( IsWindowVisible( GetFormHandle( "Form_1" ) ), '&Hide', '&Show' ) ;
         ACTION HideShow() NAME Show_Hide DEFAULT

      ITEM '&About...' ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + VERSION + CRLF + ;
         "Copyright " + Chr( 169 ) + COPYRIGHT, LoadTrayIcon( GetInstance(), "MAIN", 32, 32 ) )

      SEPARATOR

      ITEM '&Exit' ACTION ThisWindow.Release()

   END MENU

RETURN
