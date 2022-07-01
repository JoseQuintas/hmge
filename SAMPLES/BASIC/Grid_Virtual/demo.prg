/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "hmg.ch"

memvar aHeaders, aWidths, aJust
memvar aSalaries
memvar aValid
memvar aWhen
memvar aControls
memvar aRows

Function Main

   private aHeaders, aWidths, aJust
   private aSalaries := {}
   private aValid := {}
   private aWhen := {}
   private aControls := {}

   SET NAVIGATION EXTENDED

   aHeaders  := {"Name", "Salary"}
   aWidths   := {200, 100}
   aJust     := { 0, 1}

   aValid    := { {|| DataValidation()},  {|| DataValidation()} }
   aWhen     := { {|| .t.}, {|| .t.} }
   aControls := { {"TEXTBOX","CHARACTER"}, {"TEXTBOX","NUMERIC","9999.99"} }

   aADD(aSalaries, {"Simpson", 65.00 } )
   aADD(aSalaries, {"Mulder",41.00 } )
   aADD(aSalaries, {"Smart Max", 25.00} )

   DEFINE WINDOW Form_1 ;
      AT 100,100 ;
      WIDTH 500 ;
      HEIGHT 550 ;
      TITLE 'Editable Virtual Grid Test' ;
      MAIN 

      @ 10,10 GRID Grid_1 ;
         WIDTH 320 ;
         HEIGHT 340 ;
         HEADERS aHeaders ;
         WIDTHS aWidths;
         VALUE {1,1} ;
         TOOLTIP 'Editable Grid Control' ;
         EDIT ;
         COLUMNCONTROLS aControls;
         COLUMNVALID aValid;
         COLUMNWHEN aWhen;
         VIRTUAL ;
         ITEMCOUNT len(aSalaries) ;
         ON QUERYDATA OnQuery(aSalaries) ;        
         JUSTIFY aJust;
         CELLNAVIGATION 

      @ 400, 10 BUTTON B_1 ;
         CAPTION "F6 - Add records from list";
         ACTION AddRecordsFromList() ;
         WIDTH 200 ;
         HEIGHT 30

   END WINDOW

   ON KEY F6 OF FORM_1 ACTION AddRecordsFromList()

   ACTIVATE WINDOW Form_1

Return Nil
*----------------
function OnQuery( aSource )
   local nRow, nCol

   nRow := This.QueryRowIndex
   nCol := This.QueryColIndex
   if nRow > 0 .and. nCol > 0
      This.QueryData := aSource[nRow,nCol]
   endif
return .t.   
*-----------------------
function DataValidation
   local nRow, nCol

   nRow := This.Value[1]
   nCol := This.Value[2]

   if empty(This.CellValue)
      return .f.
   endif
   aSalaries[nRow,nCol] := This.CellValue
return .t.
*------------------------
procedure AddRecordsFromList

   private aHeaders := {"Name","Preferred salary"}
   private aWidths  := {300,200}
   private aJust := {0,1}

   private aRows := {}

   aAdd(aRows, {"Marek",100.20})
   aAdd(aRows, {"Iza",123.22})
   aAdd(aRows, {"Szymon",321.23})
   aAdd(aRows, {"Javier",143.24})
   aAdd(aRows, {"Nico",154.25})
   aAdd(aRows, {"Maxim",132.26})
   aAdd(aRows, {"Reno",199.77})
   
   DEFINE WINDOW Form_2 ;
      AT 300,300 ;
      WIDTH 580 ;
      HEIGHT 400 ;
      TITLE 'Salariers' ;
      MODAL

      @ 10,10 GRID Grid_2 ;
         WIDTH 520 ;
         HEIGHT 240 ;
         HEADERS aHeaders ;
         WIDTHS aWidths;
         VALUE {1,1} ;
         TOOLTIP 'Press F2 or double click to select name' ;
         COLUMNCONTROLS aControls;
         COLUMNVALID aValid;
         COLUMNWHEN aWhen;
         VIRTUAL ;
         ITEMCOUNT len(aRows) ;
         ON QUERYDATA OnQuery(aRows) ;        
         ON DBLCLICK SelectRecordFromList() ;
         JUSTIFY aJust;
         CELLNAVIGATION 

      @ 270, 10 BUTTON B_2 ;
         CAPTION "F2 -select";
         ACTION SelectRecordFromList() ;
         WIDTH 200 ;
         HEIGHT 30

   END WINDOW

   ON KEY ESCAPE OF FORM_2 ACTION FORM_2.Release()
   ON KEY F2 OF FORM_2 ACTION SelectRecordFromList()

   activate window Form_2

return
*---------------------
procedure SelectRecordFromList

   local i

   i := Form_2.Grid_2.Value[1]

   if i == 0
      return
   endif

   DEFINE WINDOW Form_3 ;
      AT 350,200 ;
      WIDTH 220 ;
      HEIGHT 160 ;
      TITLE 'Change salary' ;
      MODAL

      @ 10,10 LABEL L_1 ;
         WIDTH 60 ;
         HEIGHT 18;
         VALUE "Name";
         RIGHTALIGN

      @ 10,80 TEXTBOX T_1 ;
         HEIGHT 24;
         WIDTH 120 ;
         VALUE aRows[i,1];
         READONLY;
         NOTABSTOP

      @ 40,10 LABEL L_2 ;
         WIDTH 60 ;
         HEIGHT 18;
         VALUE "Salary";
         RIGHTALIGN

      @ 40,80 TEXTBOX T_2 ;
         HEIGHT 24;
         WIDTH 120 ;
         VALUE aRows[i,2];
         NUMERIC ;
         INPUTMASK "9999.99";
         RIGHTALIGN

      @ 80, 10 BUTTON B_Save ;
         CAPTION "F2 -Save";
         ACTION SaveRecord() ;
         WIDTH 120 ;
         HEIGHT 30

   END WINDOW

   ON KEY ESCAPE OF FORM_3 ACTION FORM_3.Release()
   ON KEY F2 OF FORM_3 ACTION SaveRecord()

   activate window Form_3
   
return
*-----------
procedure SaveRecord
   
   Release Key F2 of Form_3
   
   if .not. IsWindowDefined("Form_3") 
      return
   endif
   
   aAdd(aSalaries, {Form_3.T_1.Value, Form_3.T_2.Value})

   Form_3.Release
   
   // refresh grid in main windows
   Form_1.Grid_1.ItemCount := 0
   Form_1.Grid_1.ItemCount := len(aSalaries)
   Form_1.Grid_1.VALUE := {len(aSalaries),2}
   
return
*------------