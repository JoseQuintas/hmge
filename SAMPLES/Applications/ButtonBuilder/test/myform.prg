#include "minigui.ch"

Procedure Main()

DEFINE WINDOW Template01;
       AT 0,0;
       WIDTH 400;
       HEIGHT 300;
       TITLE 'ButtonEx Test';
       MAIN //MODAL

   ON KEY ESCAPE ACTION thiswindow.RELEASE


define buttonex Btn_1
   parent        thiswindow.name
   row           10
   col           10
   width         160
   height        160
   caption       "Sample"
   action        MsgInfo( 'Click!' )
   vertical      .T.
   uppertext     .T.
   picture       "GENCODE_48"
   fontname      "ARIAL"
   fontsize      12
   fontbold      .T.
   backcolor     {192,192,192}
   gradientfill  {{1, {192,192,192}, {128,128,128}}}
   horizontal    .F.
   noxpstyle     .T.
end buttonex


@   10,  180 buttonex Btn_2                                   ;
             caption "Sample"                                 ;
             width 160 height 160                             ;
             picture "GENCODE_48"                             ;
             action MsgInfo( "Click 2!" )                     ;
             font "ARIAL" size 12                             ;
             bold                                             ;
             vertical uppertext                               ;
             backcolor {192,192,192}                          ;
             gradientfill {{1, {192,192,192}, {128,128,128}}} ;
             noxpstyle


END WINDOW

Template01.CENTER
Template01.ACTIVATE

RETURN
