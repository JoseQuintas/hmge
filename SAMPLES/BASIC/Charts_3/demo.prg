/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016-2018 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "Selector.ch"

STATIC aSer1, aSer2, aSer3
STATIC aSerName1, aSerName2, aSerName3
STATIC aSerVal1, aSerVal3
STATIC aClrs, nGraphType

PROCEDURE Main

   aClrs := { RED, ;
      LGREEN, ;
      YELLOW, ;
      BLUE, ;
      WHITE, ;
      GRAY, ;
      FUCHSIA, ;
      TEAL, ;
      NAVY, ;
      MAROON, ;
      GREEN, ;
      OLIVE, ;
      PURPLE, ;
      SILVER, ;
      AQUA, ;
      BLACK, ;
      RED, ;
      LGREEN, ;
      YELLOW, ;
      BLUE }

   DEFINE WINDOW GraphTest ;
      AT 0, 0 ;
      WIDTH 640 ;
      HEIGHT 580 ;
      TITLE "Charts DBF Demo by Grigory Filatov" ;
      MAIN ;
      ICON "Chart.ico" ;
      NOMAXIMIZE NOSIZE ;
      BACKCOLOR iif( ISVISTAORLATER(), { 220, 220, 220 }, Nil ) ;
      FONT "Tahoma" SIZE 9 ;
      ON INIT OpenTable()

   Define Button Button_1
      Row 510
      Col 30
      Caption 'Chart &1'
      Action  drawchart_1( aser1 )
   End Button

   Define Button Button_2
      Row 510
      Col 150
      Caption 'Chart &2'
      Action  drawchart_2( aser2 )
   End Button

   Define Button Button_3
      Row 510
      Col 270
      Caption 'Chart &3'
      Action  drawchart_3( aser3 )
   End Button

   Define Button Button_4
      Row 510
      Col 390
      Caption '&Print'
      Action  PrintGraph( nGraphType )
   End Button

   Define Button Button_5
      Row 510
      Col 510
      Caption 'E&xit'
      Action  GraphTest.Release
   End Button

   END WINDOW

   GraphTest.Center

   ACTIVATE WINDOW GraphTest

RETURN

PROCEDURE DrawChart_1 ( aSer )

   nGraphType := 1

   ERASE WINDOW GraphTest

   DRAW GRAPH       ;
      IN WINDOW GraphTest     ;
      AT 20, 20      ;
      TO 500, 610      ;
      TITLE "Population (top 10 values)"   ;
      TYPE BARS      ;
      SERIES aSer      ;
      YVALUES aSerVal1     ;
      DEPTH 12      ;
      BARWIDTH 12      ;
      HVALUES 10      ;
      SERIENAMES aSerName1     ;
      COLORS aClrs      ;
      3DVIEW          ;
      SHOWXGRID                           ;
      SHOWXVALUES                        ;
      SHOWLEGENDS LEGENDSWIDTH 70 DATAMASK "9,999,999"

   GraphTest.Button_1.SetFocus

RETURN

PROCEDURE DrawChart_2 ( aSer )

   nGraphType := 2

   ERASE WINDOW GraphTest

   DRAW GRAPH       ;
      IN WINDOW GraphTest     ;
      AT 20, 130      ;
      TO 490, 500      ;
      TITLE "Area size (top 10 values)"   ;
      TYPE PIE      ;
      SERIES aSer      ;
      DEPTH 15      ;
      SERIENAMES aSerName2     ;
      COLORS aClrs      ;
      3DVIEW          ;
      SHOWXVALUES                        ;
      SHOWLEGENDS

   GraphTest.Button_2.SetFocus

RETURN

PROCEDURE DrawChart_3 ( aSer )

   nGraphType := 3

   ERASE WINDOW GraphTest

   DRAW GRAPH       ;
      IN WINDOW GraphTest     ;
      AT 20, 0       ;
      TO 500, 590      ;
      TITLE "Population density (top 20 values)"  ;
      TYPE BARS      ;
      SERIES aSer      ;
      YVALUES aSerVal3     ;
      DEPTH 4       ;
      BARWIDTH 8      ;
      HVALUES 5      ;
      SERIENAMES aSerName3     ;
      COLORS aClrs      ;
      3DVIEW          ;
      SHOWXGRID                           ;
      SHOWXVALUES                        ;
      SHOWLEGENDS LEGENDSWIDTH 105 DATAMASK "9 999"

   GraphTest.Button_3.SetFocus

RETURN

PROCEDURE PrintGraph()

   GraphTest.Button_4.SetFocus

   SWITCH nGraphType
   CASE 1
      PRINT GRAPH       ;
         IN WINDOW GraphTest     ;
         AT 20, 20      ;
         TO 500, 610      ;
         TITLE "Population (top 10 values)"   ;
         TYPE BARS      ;
         SERIES aSer1      ;
         YVALUES aSerVal1     ;
         DEPTH 12      ;
         BARWIDTH 12      ;
         HVALUES 10      ;
         SERIENAMES aSerName1     ;
         COLORS aClrs      ;
         3DVIEW          ;
         SHOWXGRID                           ;
         SHOWXVALUES                        ;
         SHOWLEGENDS LEGENDSWIDTH 70 DATAMASK "9,999,999" ;
         LIBRARY HBPRINT
      EXIT
   CASE 2
      PRINT GRAPH       ;
         IN WINDOW GraphTest     ;
         AT 20, 130      ;
         TO 490, 500      ;
         TITLE "Area size (top 10 values)"   ;
         TYPE PIE      ;
         SERIES aSer2      ;
         DEPTH 15      ;
         SERIENAMES aSerName2     ;
         COLORS aClrs      ;
         3DVIEW          ;
         SHOWXVALUES                        ;
         SHOWLEGENDS      ;
         LIBRARY HBPRINT
      EXIT
   CASE 3
      PRINT GRAPH       ;
         IN WINDOW GraphTest     ;
         AT 20, 0       ;
         TO 500, 590      ;
         TITLE "Population density (top 20 values)"  ;
         TYPE BARS      ;
         SERIES aSer3      ;
         YVALUES aSerVal3     ;
         DEPTH 4       ;
         BARWIDTH 8      ;
         HVALUES 5      ;
         SERIENAMES aSerName3     ;
         COLORS aClrs      ;
         3DVIEW          ;
         SHOWXGRID                           ;
         SHOWXVALUES                        ;
         SHOWLEGENDS LEGENDSWIDTH 105 DATAMASK "9 999"  ;
         LIBRARY HBPRINT
   END

RETURN

PROCEDURE OpenTable

   LOCAL n

   MEMVAR SelectList

   FIELD Name, Population, Area, Off

   // Open source database
   //
   USE ( hb_DirBase() + "country" ) EXCLUSIVE

   IF ! Used()
      MsgStop( "Unable connect to the table!", "Error" )
      RETURN
   ENDIF

   // Request data for Chart 1
   //
   @ SELECT Name, Population GROUP FROM Country ALIAS t1

   // One serie data
   aSer1 := Array( 10, 1 )
   aSerVal1 := Array( 10 )
   aSerName1 := Array( 10 )

   // Descending output
   t1->( dbGoBottom() )
   FOR n := 1 TO Len( aSerVal1 )
      aSer1[ n, 1 ] := t1->Population / 1000
      aSerVal1[ n ] := t1->Name
      aSerName1[ n ] := aSerVal1[ n ]
      t1->( dbSkip( -1 ) )
   NEXT

   dbCloseArea()  // close temp table

   // Request data for Chart 2
   //
   @ SELECT Name, Area GROUP FROM Country ALIAS t2

   // One serie data
   aSer2 := Array( 10 )
   aSerName2 := Array( 10 )

   // Descending output
   t2->( dbGoBottom() )
   FOR n := 1 TO Len( aSer2 )
      aSer2[ n ] := Round( t2->Area / 1000, 2 )
      aSerName2[ n ] := AllTrim( t2->Name )
      t2->( dbSkip( -1 ) )
   NEXT

   dbCloseArea()  // close temp table

   // Request data for Chart 3
   //
   @ SELECT Name, Round( Population / Area, 3 ) AS OFF GROUP FROM Country ALIAS t3

   // One serie data
   aSer3 := Array( 20, 1 )
   aSerVal3 := Array( 20 )
   aSerName3 := Array( 20 )

   // Descending output
   t3->( dbGoBottom() )
   FOR n := 1 TO Len( aSerVal3 )
      aSer3[ n, 1 ] := t3->Off
      aSerVal3[ n ] := t3->Name
      aSerName3[ n ] := Transform( aSer3[ n, 1 ], "9 999.999" ) + ' ' + aSerVal3[ n ]
      t3->( dbSkip( -1 ) )
   NEXT

   dbCloseArea()  // close temp table
   dbDrop( "temp" )

   // First chart drawing
   DrawChart_1( aser1 )

RETURN
