/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

FUNCTION MAIN

   SET TOOLTIPBALLOON ON

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'MiniGUI ToolBar Demo (Based Upon a Contribution Of Janusz Pora)' ;
         ICON 'DEMO.ICO' ;
         MAIN ;
         FONT 'Arial' SIZE 10

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready!'
      END STATUSBAR

      DEFINE MAIN MENU
         DEFINE POPUP '&File'
            ITEM 'Get ToolBar_3 Button_1' ACTION MsgInfo ( if ( Form_1.Button_1c.VALUE, '.T.', '.F.' ), 'Button_1c' )
            ITEM 'Get ToolBar_3 Button_2' ACTION MsgInfo ( if ( Form_1.Button_2c.VALUE, '.T.', '.F.' ), 'Button_2c' )
            ITEM 'Get ToolBar_3 Button_3' ACTION MsgInfo ( if ( Form_1.Button_3c.VALUE, '.T.', '.F.' ), 'Button_3c' )
            ITEM 'Get ToolBar_3 Button_4' ACTION MsgInfo ( if ( Form_1.Button_4c.VALUE, '.T.', '.F.' ), 'Button_4c' )
            SEPARATOR
            ITEM 'Set ToolBar_3 Button_1' ACTION Form_1.Button_1c.VALUE := .T.
            ITEM 'Set ToolBar_3 Button_2' ACTION Form_1.Button_2c.VALUE := .T.
            ITEM 'Set ToolBar_3 Button_3' ACTION Form_1.Button_3c.VALUE := .T.
            ITEM 'Set ToolBar_3 Button_4' ACTION Form_1.Button_4c.VALUE := .T.
            SEPARATOR
            ITEM '&Exit' ACTION Form_1.RELEASE
         END POPUP
         DEFINE POPUP '&Help'
            ITEM '&About' ACTION MsgInfo ( "MiniGUI ToolBar demo" )
         END POPUP
      END MENU

      DEFINE SPLITBOX

         DEFINE TOOLBAR ToolBar_a BUTTONSIZE 45, 40 FONT 'Arial' SIZE 8 FLAT

            BUTTON Button_1a ;
               CAPTION 'Undo' ;
               PICTURE 'button4.bmp' ;
               TOOLTIP 'Undo button' ;
               ACTION MsgInfo( 'Click! 1' )

            BUTTON Button_2a ;
               CAPTION 'Save' ;
               PICTURE 'button5.bmp' ;
               TOOLTIP 'Save button' ;
               WHOLEDROPDOWN

            DEFINE DROPDOWN MENU BUTTON Button_2a
               ITEM 'Exit' ACTION Form_1.RELEASE
               ITEM 'About' ACTION MsgInfo ( "MiniGUI ToolBar Demo" )
            END MENU

            BUTTON Button_3a ;
               CAPTION 'Close' ;
               PICTURE 'button6.bmp' ;
               TOOLTIP 'Close button' ;
               ACTION MsgInfo( 'Click! 3' ) ;
               DROPDOWN

            DEFINE DROPDOWN MENU BUTTON Button_3a
               ITEM 'Disable ToolBar 1 Button 1' ACTION Form_1.Button_1a.Enabled := .F.
               ITEM 'Enable ToolBar 1 Button 1' ACTION Form_1.Button_1a.Enabled := .T.
            END MENU

         END TOOLBAR

         DEFINE TOOLBAR ToolBar_b BUTTONSIZE 45, 40 FONT 'ARIAL' SIZE 8 FLAT

            BUTTON Button_1b ;
               CAPTION 'More ToolBars...' ;
               PICTURE 'button7.bmp' ;
               TOOLTIP 'More ToolBars button' ;
               ACTION MsgInfo( 'Click! 1' ) ;

               BUTTON Button_2b ;
               CAPTION 'Button 2' ;
               PICTURE 'button8.bmp' ;
               TOOLTIP 'This is button 2' ;
               ACTION MsgInfo( 'Click! 2' ) ;
               SEPARATOR

            BUTTON Button_3b ;
               CAPTION 'Button 3' ;
               PICTURE 'button7.bmp' ;
               TOOLTIP 'This is button 3' ;
               ACTION MsgInfo( 'Click! 3' )

         END TOOLBAR

         DEFINE TOOLBAR ToolBar_c BUTTONSIZE 45, 40 FONT 'Arial' SIZE 8 CAPTION 'ToolBar 3' FLAT

            BUTTON Button_1c ;
               CAPTION 'Check 1' ;
               TOOLTIP 'This is button Check 1' ;
               PICTURE 'button4.bmp' ;
               ACTION _dummy() ;
               CHECK GROUP

            BUTTON Button_2c ;
               CAPTION 'Check 2' ;
               PICTURE 'button5.bmp' ;
               TOOLTIP 'This is button Check 2' ;
               ACTION _dummy() ;
               CHECK GROUP

            BUTTON Button_3c ;
               CAPTION 'Check 3' ;
               PICTURE 'button6.bmp' ;
               TOOLTIP 'This is button Check 3' ;
               ACTION _dummy() ;
               SEPARATOR ;
               CHECK GROUP

            BUTTON Button_4c ;
               CAPTION 'Help Check' ;
               PICTURE 'button9.bmp' ;
               ACTION _dummy() ;
               CHECK

         END TOOLBAR

      END SPLITBOX

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL
