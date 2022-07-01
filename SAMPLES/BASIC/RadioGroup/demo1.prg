/*
 * HMG RadioGroup Demo
 * (c) 2010 Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include "minigui.ch"

FUNCTION Main()

   DEFINE WINDOW Win1 ;
         ROW 10 ;
         COL 10 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'HMG RadioGroup Demo' ;
         WINDOWTYPE MAIN ;
         ON INIT Win1.Center()

      DEFINE MAIN MENU
         DEFINE POPUP "&Properties"
            MENUITEM "Change Value" ACTION Win1.RadioGroup2.Value := 3
            MENUITEM "Get Value" ACTION Msginfo( Win1.RadioGroup2.Value )
            SEPARATOR
            MENUITEM "Change Options" ACTION Win1.RadioGroup2.Options := { "New Item 1", "New Item 2", "New Item 3", "New Item 4" }
            MENUITEM "Get Options value" ACTION MsgDebug( Win1.RadioGroup2.Options )
            SEPARATOR
            MENUITEM "Change Spacing" ACTION SetProperty( 'Win1', 'RadioGroup2', 'Spacing', 32 )
            MENUITEM "Get Spacing value" ACTION Msginfo( Win1.RadioGroup2.Spacing, 'RadioGroup2 Spacing' )
            SEPARATOR
            MENUITEM "Set Horizontal orientation" ACTION SetHorizontal( 'RadioGroup2', 'Win1' )
            MENUITEM "Get Horizontal style" ACTION Msginfo( Win1.RadioGroup2.Horizontal, 'Is Horizontal?' )
         END POPUP
      END MENU

      @ 40, 10 RADIOGROUP RadioGroup1 ;
         OPTIONS { "Item 1", "Item 2", "Item 3" } ;
         WIDTH 60 ;
         SPACING 20 ;
         VALUE 2 ;
         HORIZONTAL ;
         TOOLTIP 'Horizontal Radiogroup' ;
         ON CHANGE MsgInfo( "Radiogroup 1 Value Changed!" )

      @ 110, 10 RADIOGROUP Radiogroup2 ;
         OPTIONS { "Option 1", "Option 2", "Option 3", "Option 4" } ;
         WIDTH 240 ;
         TOOLTIP 'Vertical Radiogroup' ;
         ON CHANGE {|| MsgInfo( "Radiogroup 2 Value Changed!" ) }

   END WINDOW

   ACTIVATE WINDOW Win1

RETURN NIL


PROCEDURE SetHorizontal( control, form )

   LOCAL i := GetControlIndex( control, form )
   LOCAL aoptions := _HMG_aControlCaption[ i ]
   LOCAL nvalue := _HMG_aControlValue[ i ]

   IF ! GetProperty( Form, Control, 'horizontal' )
      DoMethod( Form, Control, 'release' )
      DO EVENTS

      @ 110, 10 RADIOGROUP (Control) OF &form ;
         OPTIONS aoptions ;
         HORIZONTAL ;
         WIDTH 80 ;
         SPACING 12 ;
         VALUE nvalue ;
         TOOLTIP 'Horizontal Radiogroup' ;
         ON CHANGE {|| MsgInfo( "Radiogroup 2 Value Changed!" ) }
   ENDIF

RETURN
