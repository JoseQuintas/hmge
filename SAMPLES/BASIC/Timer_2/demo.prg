/*
 * HMG Timer demo
 * (c) 2010 Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include "hmg.ch"

STATIC lChange := .T.


FUNCTION Main

   DEFINE WINDOW oWindow;
      ROW    10;
      COL    10;
      WIDTH  500;
      HEIGHT 550;
      TITLE  'HMG Timer Demo';
      WINDOWTYPE MAIN;
      ONINIT { || oWindow.Center(), ShowStatus() }

      @ 20 , 10 LABEL oLabel1 ;
         VALUE '' ;
         AUTOSIZE ;
         FONT "Arial" ;
         SIZE 24

      @ 20, 250 LABEL oLabel2 ;
         AUTOSIZE ;
         VALUE '' ;
         FONT "Arial" ;
         SIZE 24

      @ 230, 10 EDITBOX oEdit1 ;
         WIDTH 480 ;
         HEIGHT 300 ;
         SIZE 12 ;
         VALUE ''

      DEFINE BUTTON oButton1
         ROW     90
         COL     10
         CAPTION 'Stop'
         ONCLICK ( oWindow.oTimerBlink.Enabled := .F., ShowStatus() )
      END BUTTON

      DEFINE BUTTON oButton2
         ROW     90
         COL     250
         CAPTION 'Start'
         ONCLICK ( oWindow.oTimerBlink.Enabled := .T., ShowStatus() )
      END BUTTON

      DEFINE BUTTON oButton3
         ROW     120
         COL     10
         CAPTION 'Interval 700'
         ONCLICK ( oWindow.oTimerBlink.Interval := 700, ShowStatus() )
      END BUTTON

      DEFINE BUTTON oButton4
         ROW     120
         COL     250
         CAPTION 'Interval 250'
         ONCLICK ( oWindow.oTimerBlink.Interval := 250, ShowStatus() )
      END BUTTON

      DEFINE BUTTON oButton5
         ROW     150
         COL     10
         CAPTION 'Action 2'
         ONCLICK ( oWindow.oTimerBlink.Action := { || testtimer2(), ShowStatus() } )
      END BUTTON

      DEFINE BUTTON oButton6
         ROW     150
         COL     250
         CAPTION 'Action 1'
         ONCLICK ( oWindow.oTimerBlink.Action := { || testtimer1(), ShowStatus() } )
      END BUTTON

      DEFINE BUTTON oButton7
         ROW     180
         COL     10
         CAPTION 'Toggle One Shot'
         ONCLICK ( oWindow.oTimerBlink.Once := ! (oWindow.oTimerBlink.Once), ShowStatus() )
      END BUTTON

     DEFINE TIMER oTimerBlink
        INTERVAL 250
        ACTION   { || testtimer1() }
     END TIMER

     DEFINE TIMER oTimerColor
        INTERVAL 4000
        ONCE     .T.
        ACTION   { || oWindow.oLabel1.FontColor := { 255, 0, 0 }, ShowStatus() }
     END TIMER

   END WINDOW

   ACTIVATE WINDOW oWindow

   RETURN NIL

/*----------------------------------------------------------------------*/

FUNCTION testtimer2()

   lchange := ! lchange

   oWindow.oLabel2.Value := IF( lchange, ':)', ':D' )

   RETURN 0

/*----------------------------------------------------------------------*/

FUNCTION testtimer1()

   lchange := ! lchange

   oWindow.oLabel1.Value := IF( lchange, 'HMG is great', '' )

   RETURN 0

/*----------------------------------------------------------------------*/

FUNCTION ShowStatus()

   DoEvents()

   oWindow.oEdit1.Value := 'oTimerBlink  ---------' + HB_EOL() +;
                           '  Interval = ' + hb_NToS( oWindow.oTimerBlink.Interval ) + HB_EOL() +;
                           '  One Shot = ' + HB_ValToSTR( oWindow.oTimerBlink.Once ) + HB_EOL() +;
                           '  IsActive = ' + HB_ValToSTR( oWindow.oTimerBlink.Enabled ) + HB_EOL() +;
                           '  Action = ' + cValToChar( GetProperty( 'oWindow', 'oTimerBlink', 'Action' ) ) + HB_EOL() + HB_EOL() +;
                           'oTimerColor  ---------' + HB_EOL() +;
                           '  Interval = ' + hb_NToS( oWindow.oTimerColor.Interval ) + HB_EOL() +;
                           '  One Shot = ' + HB_ValToSTR( oWindow.oTimerColor.Once ) + HB_EOL() +;
                           '  IsActive = ' + HB_ValToSTR( oWindow.oTimerColor.Enabled ) + HB_EOL() +;
                           '  Action = ' + cValToChar( GetProperty( 'oWindow', 'oTimerColor', 'Action' ) )

   RETURN 0
