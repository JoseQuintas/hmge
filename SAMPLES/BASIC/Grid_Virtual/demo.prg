/*
 * MINIGUI - Harbour Win32 GUI library Demo
 */

#include "hmg.ch"

MEMVAR aHeaders, aWidths, aJust
MEMVAR aSalaries
MEMVAR aValid
MEMVAR aWhen
MEMVAR aControls
MEMVAR aRows

// ------------
FUNCTION Main()

   PRIVATE aHeaders, aWidths, aJust
   PRIVATE aSalaries := {}
   PRIVATE aValid := {}
   PRIVATE aWhen := {}
   PRIVATE aControls := {}

   SET NAVIGATION EXTENDED

   aHeaders := { "Name", "Salary" }
   aWidths := { 200, 100 }
   aJust := { 0, 1 }

   aValid := { {|| DataValidation() }, {|| DataValidation() } }
   aWhen := { {|| .T. }, {|| .T. } }
   aControls := { { "TEXTBOX", "CHARACTER" }, { "TEXTBOX", "NUMERIC", "9999.99" } }

   AAdd( aSalaries, { "Simpson", 65.00 } )
   AAdd( aSalaries, { "Mulder", 41.00 } )
   AAdd( aSalaries, { "Smart Max", 25.00 } )

   DEFINE WINDOW Form_1 ;
         AT 100, 100 ;
         WIDTH 500 ;
         HEIGHT 550 ;
         TITLE 'Editable Virtual Grid Test' ;
         MAIN

      @ 10, 10 GRID Grid_1 ;
         WIDTH 320 ;
         HEIGHT 340 ;
         HEADERS aHeaders ;
         WIDTHS aWidths ;
         VALUE { 1, 1 } ;
         TOOLTIP 'Editable Grid Control' ;
         EDIT ;
         COLUMNCONTROLS aControls ;
         COLUMNVALID aValid ;
         COLUMNWHEN aWhen ;
         VIRTUAL ;
         ITEMCOUNT Len( aSalaries ) ;
         ON QUERYDATA OnQuery( aSalaries ) ;
         JUSTIFY aJust ;
         CELLNAVIGATION

      @ 400, 10 BUTTON B_1 ;
         CAPTION "F6 - Add records from list" ;
         ACTION AddRecordsFromList() ;
         WIDTH 200 ;
         HEIGHT 30

   END WINDOW

   ON KEY F6 OF FORM_1 ACTION AddRecordsFromList()

   ACTIVATE WINDOW Form_1

RETURN NIL
// ----------------
FUNCTION OnQuery( aSource )

   LOCAL nRow, nCol

   nRow := This.QueryRowIndex
   nCol := This.QueryColIndex
   IF nRow > 0 .AND. nCol > 0
      This.QueryData := aSource[ nRow, nCol ]
   ENDIF

RETURN .T.
// -----------------------
FUNCTION DataValidation

   LOCAL nRow, nCol

   nRow := This.Value[ 1 ]
   nCol := This.Value[ 2 ]

   IF Empty( This.CellValue )
      RETURN .F.
   ENDIF
   aSalaries[ nRow, nCol ] := This.CellValue

RETURN .T.
// ------------------------
PROCEDURE AddRecordsFromList

   PRIVATE aHeaders := { "Name", "Preferred salary" }
   PRIVATE aWidths := { 300, 200 }
   PRIVATE aJust := { 0, 1 }

   PRIVATE aRows := {}

   AAdd( aRows, { "Marek", 100.20 } )
   AAdd( aRows, { "Iza", 123.22 } )
   AAdd( aRows, { "Szymon", 321.23 } )
   AAdd( aRows, { "Javier", 143.24 } )
   AAdd( aRows, { "Nico", 154.25 } )
   AAdd( aRows, { "Maxim", 132.26 } )
   AAdd( aRows, { "Reno", 199.77 } )

   DEFINE WINDOW Form_2 ;
         AT 300, 300 ;
         WIDTH 580 ;
         HEIGHT 400 ;
         TITLE 'Salariers' ;
         MODAL

      @ 10, 10 GRID Grid_2 ;
         WIDTH 520 ;
         HEIGHT 240 ;
         HEADERS aHeaders ;
         WIDTHS aWidths ;
         VALUE { 1, 1 } ;
         TOOLTIP 'Press F2 or double click to select name' ;
         COLUMNCONTROLS aControls ;
         COLUMNVALID aValid ;
         COLUMNWHEN aWhen ;
         VIRTUAL ;
         ITEMCOUNT Len( aRows ) ;
         ON QUERYDATA OnQuery( aRows ) ;
         ON DBLCLICK SelectRecordFromList() ;
         JUSTIFY aJust ;
         CELLNAVIGATION

      @ 270, 10 BUTTON B_2 ;
         CAPTION "F2 -select" ;
         ACTION SelectRecordFromList() ;
         WIDTH 200 ;
         HEIGHT 30

   END WINDOW

   ON KEY ESCAPE OF FORM_2 ACTION FORM_2.Release()
   ON KEY F2 OF FORM_2 ACTION SelectRecordFromList()

   ACTIVATE WINDOW Form_2

RETURN
// ---------------------
PROCEDURE SelectRecordFromList

   LOCAL i

   i := Form_2.Grid_2.Value[ 1 ]

   IF i == 0
      RETURN
   ENDIF

   DEFINE WINDOW Form_3 ;
         AT 350, 200 ;
         WIDTH 220 ;
         HEIGHT 160 ;
         TITLE 'Change salary' ;
         MODAL

      @ 10, 10 LABEL L_1 ;
         WIDTH 60 ;
         HEIGHT 18 ;
         VALUE "Name" ;
         RIGHTALIGN

      @ 10, 80 TEXTBOX T_1 ;
         HEIGHT 24 ;
         WIDTH 120 ;
         VALUE aRows[ i, 1 ] ;
         READONLY ;
         NOTABSTOP

      @ 40, 10 LABEL L_2 ;
         WIDTH 60 ;
         HEIGHT 18 ;
         VALUE "Salary" ;
         RIGHTALIGN

      @ 40, 80 TEXTBOX T_2 ;
         HEIGHT 24 ;
         WIDTH 120 ;
         VALUE aRows[ i, 2 ] ;
         NUMERIC ;
         INPUTMASK "9999.99" ;
         RIGHTALIGN

      @ 80, 10 BUTTON B_Save ;
         CAPTION "F2 -Save" ;
         ACTION SaveRecord() ;
         WIDTH 120 ;
         HEIGHT 30

   END WINDOW

   ON KEY ESCAPE OF Form_3 ACTION Form_3.Release()
   ON KEY F2 OF Form_3 ACTION SaveRecord()

   ACTIVATE WINDOW Form_3

RETURN
// -----------
PROCEDURE SaveRecord

   RELEASE KEY F2 OF Form_3

   IF .NOT. IsWindowDefined( "Form_3" )
      RETURN
   ENDIF

   AAdd( aSalaries, { Form_3.T_1.Value, Form_3.T_2.Value } )

   Form_3.RELEASE

   // refresh grid in main windows
   Form_1.Grid_1.ItemCount := 0
   Form_1.Grid_1.ItemCount := Len( aSalaries )
   Form_1.Grid_1.Value := { Len( aSalaries ), 2 }

RETURN
