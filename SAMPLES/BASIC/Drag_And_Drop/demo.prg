/*
 * HMG Drag and Drop demo
*/

#include "hmg.ch"

FUNCTION Main()

   DEFINE WINDOW oWindow1;
      ROW    10;
      COL    10;
      WIDTH  500;
      HEIGHT 400;
      TITLE  'Drag and Drop demo';
      WINDOWTYPE MAIN;
      ONINIT oWindow1.Center()

      This.OnDropFiles := {| aFiles | ResolveDrop( "oWindow1", HMG_GetFormControls( "oWindow1" ), aFiles ) }

      DEFINE LABEL NUL 
         ROW 10
         COL 10
         WIDTH 300
         HEIGHT 40
         ALIGNMENT CENTER
         ALIGNMENT VCENTER
         BORDER .T.
         VALUE "Drag one or more files from explorer into the controls."
      END LABEL

      DEFINE CHECKBOX NUL
         Row      10
         Col      350
         Value    .F.
         Caption  'CheckBox!!!'
      END CHECKBOX

      DEFINE COMBOBOX NUL
         Row      40
         Col      350
         Width    100
         Items    { "E - Item 1", "D - Item 2", "C - Item 3", "B - Item 4", "A - Item 5" }
         Value    3
      END COMBOBOX

      DEFINE DATEPICKER NUL
         Row    80
         Col    350
         Value  DATE()
         UpDown .T.
      END DATEPICKER

      DEFINE EDITBOX NUL
         Row        60
         Col        10
         Width      300
         Height     100
         Value      "Checkbox, Combobox, Datepicker, Label, Textbox, " + ;
                    "Editbox, Listbox and Tree work well and accept OnDropFiles event."
         NOHSCROLLBAR .T.
      END EDITBOX

      Define ListBox NUL
         Row        170
         Col        10
         Width      150
         Height      80
         Items      {"Item 1","Item 2","Item 3","Item 4","Item 5"}
         Value      3
      End ListBox
       
      DEFINE TEXTBOX NUL
         Row     260
         Col     10
         Width   300
         Value   'TextBox'
      END TEXTBOX
       
      DEFINE TREE NUL;
         ROW     120;
         COL     350;
         WIDTH   120;
         HEIGHT  200

         NODE "Item1"
            TREEITEM "Item1.1"
            TREEITEM "Item1.2"
         END NODE

         NODE "Item2"
            TREEITEM "Item2.1"

            NODE "Item2.2"
               TREEITEM "Item2.2.1"
            END NODE

            TREEITEM "Item2.3"
         END NODE

      END TREE
     
   END WINDOW

   ACTIVATE WINDOW oWindow1

RETURN NIL

/*..............................................................................
   Drop Event Processing
..............................................................................*/
FUNCTION ResolveDrop( cForm, aCtrl, aFiles )

   LOCAL mx, my, ni, tx, ty, bx, by, ct
   LOCAL aRect := { 0, 0, 0, 0 }, txt := ""
   LOCAL aCtlPos := {}
   LOCAL cTarget := ""

   my := GetCursorRow()  /* Mouse y position on desktop */
   mx := GetCursorCol()  /* Mouse x position on desktop */

   FOR ni = 1 TO Len( aCtrl )
      GetWindowRect( GetControlHandle( aCtrl[ ni ], cForm ), aRect )
      AAdd( aCtlPos, { aCtrl[ ni ], aRect[ 1 ], aRect[ 2 ], aRect[ 3 ], aRect[ 4 ] } )
   NEXT ni

   ni := 0
   DO WHILE ni ++ < Len( aCtlPos )
      tx := aCtlPos[ ni, 2 ] /* Top-Left Corner x */
      ty := aCtlPos[ ni, 3 ] /* Top-Left Corner y */
      bx := aCtlPos[ ni, 4 ] /* Right-Bottom Corner x */
      by := aCtlPos[ ni, 5 ] /* Right-Bottom Corner y */
      IF mx >= tx .AND. mx <= bx .AND. my >= ty .AND. my <= by
         cTarget := aCtlPos[ ni, 1 ]
         EXIT
      ENDIF
   ENDDO

   IF Len( cTarget ) > 0
      ct := GetControlType( cTarget, cForm )
      for ni = 1 to Len(aFiles)
         txt += aFiles[ni] + " received into " + cTarget + " (" + ct + ")" + CRLF
      NEXT ni
      AlertInfo( txt )
   ENDIF

RETURN NIL
