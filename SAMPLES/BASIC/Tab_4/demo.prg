/*
 * HMG Tab demo
 * (c) 2010 Roberto Lopez <mail.box.hmg@gmail.com>
 */

#include "hmg.ch"

FUNCTION Main()

   LOCAL cTabCtl

   DEFINE WINDOW oWindow1 ;
      Row     10 ;
      Col     10 ;
      Width  400 ;
      Height 400 ;
      Title  'Tab Pages Demo' ;
      WindowType Main ;
      OnInit oWindow1.Center()

      DEFINE MAIN MENU

         POPUP 'Page Tests'
            ITEM 'Set Page1 Caption'   ACTION oWindow1.(cTabCtl).Caption( 1 ) := 'New'
            ITEM 'Set Page1 Image'     ACTION oWindow1.(cTabCtl).Image( 1 )   := 'save.png'
            ITEM 'Set Page1 ToolTip'   ACTION oWindow1.(cTabCtl).ToolTip( 1 ) := 'Page ToolTip'
            SEPARATOR
            ITEM 'Set Page1 Disable'   ACTION oWindow1.(cTabCtl).Enabled( 1 ) := .F.
            ITEM 'Set Page1 Enable'    ACTION oWindow1.(cTabCtl).Enabled( 1 ) := .T.
            SEPARATOR
            MENUITEM 'Get Button1 Caption' ACTION MsgInfo ( oWindow1.&cTabCtl.( 1 ).Button1.Caption )
            MENUITEM 'Set Button1 Caption' ACTION oWindow1.&cTabCtl.( 1 ).Button1.Caption := 'New Caption'
            SEPARATOR
            MENUITEM 'Show Button1' ACTION oWindow1.&cTabCtl.( 1 ).Button1.Show()
            MENUITEM 'Hide Button1' ACTION oWindow1.&cTabCtl.( 1 ).Button1.Hide()
         END POPUP

         POPUP 'Tab Tests'
            ITEM 'Set Active Page To 1'        ACTION oWindow1.(cTabCtl).Value := 1
            ITEM 'Set Active Page To 2'        ACTION oWindow1.(cTabCtl).Value := 2
            SEPARATOR
            ITEM 'Set OnChange Event'          ACTION oWindow1.(cTabCtl).OnChange := { || MsgInfo( 'Changed' ) }
            ITEM 'Clear OnChange Event'        ACTION oWindow1.(cTabCtl).OnChange := { || NIL }
            SEPARATOR
            ITEM 'Delete Page 2'               ACTION oWindow1.(cTabCtl).DeletePage( 2 )
            ITEM 'Add Page At Position 2'      ACTION ( oWindow1.(cTabCtl).Image( 1 )   := 'save.png', ;
                                                      oWindow1.(cTabCtl).AddPage( 2, 'New Page', 'open.png' ) )
         END POPUP

      END MENU

      DEFINE TAB NUL AT 20, 10 Width 350 Height 300

         DEFINE PAGE 'One'

            DEFINE BUTTON Button1
               Row     60
               Col     20
               Caption 'Button Caption'
               OnClick MsgInfo( 'Click!' )
            END BUTTON

         END PAGE

         DEFINE PAGE 'Two'

            DEFINE EDITBOX Edit1
               Row        60
               Col        20
               Width      200
               Height     100
               Value      'EditBox Text'
               HScrollBar .F.
            END EDITBOX

         END PAGE

      END TAB

      cTabCtl := HMG_GetFormControls( This.Name, "TAB" )[ 1 ]

   END WINDOW

   ACTIVATE WINDOW oWindow1

RETURN NIL
