/*
 * MiniGUI Window events Demo
 * (c) 2006 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"

#define NTRIM( n ) hb_ntos( n )

PROCEDURE Main()

   LOCAL lMaximize := .F.

   DEFINE WINDOW Form_1 ;
         AT 100, 100 ;
         WIDTH 400 ;
         HEIGHT 200 ;
         TITLE 'Hello World!' ;
         MAIN ;
         ON MAXIMIZE ( lMaximize := .T., ThisWindow.TITLE := ;
            "Row = " + NTRIM( ThisWindow.Row ) + ;
            "   Col = " + NTRIM( ThisWindow.Col ) ) ;
         ON SIZE ( lMaximize := .F., ThisWindow.TITLE := ;
            "Row = " + NTRIM( ThisWindow.Row ) + ;
            "   Col = " + NTRIM( ThisWindow.Col ) ) ;
         ON MOVE if( lMaximize, , ThisWindow.TITLE := ;
            "Row = " + NTRIM( _HMG_MouseRow - GetTitleHeight() - GetBorderWidth() ) + ;
            "   Col = " + NTRIM( _HMG_MouseCol - GetBorderWidth() ) ) ;
         ON INTERACTIVECLOSE MsgYesNo ( 'Are You Sure ?', 'Exit', , , .F. )

      DEFINE BUTTON Button_1
         ROW 10
         COL 10
         CAPTION 'Change size'
         ACTION ( ThisWindow.WIDTH := 640, ThisWindow.HEIGHT := 480 )
      DEFAULT .T.
      END BUTTON

      DEFINE BUTTON Button_2
         ROW 40
         COL 10
         CAPTION 'Form Center'
         ACTION ( ThisWindow.CENTER, ;
            ThisWindow.TITLE := ;
            "Row = " + NTRIM( ThisWindow.Row ) + ;
            "   Col = " + NTRIM( ThisWindow.Col ) )
      END BUTTON

      DEFINE BUTTON Button_3
         ROW 70
         COL 10
         CAPTION 'Cancel'
         ACTION ThisWindow.RELEASE
      END BUTTON

   END WINDOW

   ACTIVATE WINDOW Form_1

RETURN
