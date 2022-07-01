/*
 * DrawBoxGradient.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define NONE      0
#define BOX       2
#define PANEL     3

PROCEDURE Main ()

   LOCAL aColor := HMG_n2RGB( GetSysColor( 15 ) )

   SET FONT TO "Arial", 12

   DEFINE WINDOW x ;
         WIDTH 640 ;
         HEIGHT 420 ;
         TITLE "Draw Box and Panel Gradient Sample" ;
         MAIN ;
         NOMAXIMIZE NOSIZE ;
         BACKCOLOR aColor

      DRAW GRADIENT IN WINDOW x AT 20, 20 TO 200, 300 BORDER BOX

      @ 95, 110 LABEL Label_1 VALUE "Gradient Box In" AUTOSIZE TRANSPARENT FONTCOLOR YELLOW

      DRAW GRADIENT IN WINDOW x AT 20, 320 TO 200, 610 ;
         VERTICAL BORDER PANEL

      @ 95, 410 LABEL Label_2 VALUE "Gradient Panel" AUTOSIZE TRANSPARENT FONTCOLOR YELLOW

      DRAW GRADIENT IN WINDOW x AT 250, 20 TO 278, 300 ;
         VERTICAL BORDER BOX ;
         BEGINCOLOR { 255, 255, 255 } ;
         ENDCOLOR { 220, 220, 220 }

      @ 220, 110 LABEL Label_3 VALUE "Gradient Box In" AUTOSIZE TRANSPARENT

      DRAW GRADIENT IN WINDOW x AT 250, 320 TO 278, 610 ;
         VERTICAL BORDER PANEL ;
         BEGINCOLOR { 255, 255, 255 } ;
         ENDCOLOR { 200, 200, 216 }

      @ 220, 410 LABEL Label_4 VALUE "Gradient Panel" AUTOSIZE TRANSPARENT

      DRAW GRADIENT IN WINDOW x AT 300, 20 TO 302, 316 ;
         BORDER NONE ;
         BEGINCOLOR { 250, 0, 0 } ;
         ENDCOLOR { 130, 0, 0 }

      DRAW GRADIENT IN WINDOW x AT 300, 316 TO 302, 610 ;
         BORDER NONE ;
         BEGINCOLOR { 130, 0, 0 } ;
         ENDCOLOR { 250, 0, 0 }

      @ 330, 240 BUTTON Button_1 ;
         CAPTION "&Close" ;
         ACTION ThisWindow.RELEASE ;
         WIDTH 150 HEIGHT 26

   END WINDOW

   CENTER WINDOW x

   ACTIVATE WINDOW x

RETURN
