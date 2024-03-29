/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

Function Main

   DEFINE WINDOW Form_1;
      AT 0,0;
      WIDTH 230 HEIGHT 300;
      TITLE "MiniGUI Label Demo";
      MAIN;
      FONT "Arial" SIZE 10 BACKCOLOR YELLOW

      @ 010,10 LABEL Label_1 VALUE "Label_1" WIDTH 200;
         TOOLTIP "Label 1"
      @ 040,10 LABEL Label_2 VALUE "Label_2" CENTERALIGN WIDTH 200;
         TOOLTIP "Label 2 CenterAlign"
      @ 070,10 LABEL Label_3 VALUE "Label_3" RIGHTALIGN WIDTH 200;
         TOOLTIP "Label 3 RightAlign"

      @ 110,10 LABEL Label_4;
         VALUE "Blinking Label";
         WIDTH 200;
         TRANSPARENT BLINK;
         TOOLTIP "Blinking Label"

      @ 140,10 LABEL Label_5 VALUE "Label_5" CENTERALIGN WIDTH 200 TRANSPARENT;
         TOOLTIP "Label 5 CenterAlign Transparent"
      @ 170,10 LABEL Label_6 VALUE "Label_6" RIGHTALIGN WIDTH 200 TRANSPARENT;
         TOOLTIP "Label 6 RightAlign Transparent"

      @ 200,20 LABEL Label_7 VALUE "MiniGUI" TRANSPARENT FONT "ARIAL" SIZE 36;
         FONTCOLOR BLACK BACKCOLOR YELLOW AUTOSIZE
      @ 202,23 LABEL Label_8 VALUE "MiniGUI" TRANSPARENT FONT "ARIAL" SIZE 36;
         FONTCOLOR PINK BACKCOLOR YELLOW AUTOSIZE

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil
