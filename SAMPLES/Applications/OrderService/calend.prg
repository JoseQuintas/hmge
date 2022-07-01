/*
  sistema     : ordem de serviço
  programa    : calendário
  compilador  : harbour
  lib gráfica : minigui extended
*/

#include 'minigui.ch'

FUNCTION Calendario()

   DEFINE WINDOW form_calendario ;
         AT 000, 000 ;
         WIDTH 780 ;
         HEIGHT 640 ;
         TITLE 'Calendário' ;
         ICON 'icone' ;
         modal ;
         NOSIZE

      @ 0, 0 monthcalendar month1

      form_calendario.month1.WIDTH := form_calendario.WIDTH
      form_calendario.month1.HEIGHT := form_calendario.HEIGHT

      ON KEY ESCAPE ACTION form_calendario.RELEASE

   END WINDOW

   form_calendario.CENTER
   form_calendario.ACTIVATE

return( nil )
