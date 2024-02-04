/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2023 Grigory Filatov <gfilatov@gmail.com>
 */

#include "minigui.ch"
#include "sqlrdd.ch"

STATIC aSer1, aSer2, aSer3
STATIC aSerName1, aSerName2, aSerName3
STATIC aSerVal1, aSerVal3
STATIC aClrs, nGraphType

PROCEDURE Main()

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
         TITLE "Charts SQLRDD Demo by Grigory Filatov" ;
         MAIN ;
         ICON "Chart.ico" ;
         NOMAXIMIZE NOSIZE ;
         BACKCOLOR iif( ISVISTAORLATER(), { 220, 220, 220 }, Nil ) ;
         FONT "Tahoma" SIZE 9 ;
         ON INIT OpenTable()

      DEFINE BUTTON Button_1
         ROW 510
         COL 30
         CAPTION 'Chart &1'
         ACTION drawchart_1( aser1 )
      END BUTTON

      DEFINE BUTTON Button_2
         ROW 510
         COL 150
         CAPTION 'Chart &2'
         ACTION drawchart_2( aser2 )
      END BUTTON

      DEFINE BUTTON Button_3
         ROW 510
         COL 270
         CAPTION 'Chart &3'
         ACTION drawchart_3( aser3 )
      END BUTTON

      DEFINE BUTTON Button_4
         ROW 510
         COL 390
         CAPTION '&Print'
         ACTION PrintGraph( nGraphType )
      END BUTTON

      DEFINE BUTTON Button_5
         ROW 510
         COL 510
         CAPTION 'E&xit'
         ACTION GraphTest.Release()
      END BUTTON

   END WINDOW

   GraphTest.Center()

   ACTIVATE WINDOW GraphTest

RETURN

PROCEDURE DrawChart_1 ( aSer )

   nGraphType := 1

   ERASE WINDOW GraphTest

   DRAW GRAPH ;
      IN WINDOW GraphTest ;
      AT 20, 20 ;
      TO 500, 610 ;
      TITLE "Population (top 10 values)" ;
      TYPE BARS ;
      SERIES aSer ;
      YVALUES aSerVal1 ;
      DEPTH 12 ;
      BARWIDTH 12 ;
      HVALUES 10 ;
      SERIENAMES aSerName1 ;
      COLORS aClrs ;
      3DVIEW ;
      SHOWXGRID ;
      SHOWXVALUES ;
      SHOWLEGENDS LEGENDSWIDTH 70 DATAMASK "9,999,999"

   GraphTest.Button_1.SetFocus

RETURN

PROCEDURE DrawChart_2 ( aSer )

   nGraphType := 2

   ERASE WINDOW GraphTest

   DRAW GRAPH ;
      IN WINDOW GraphTest ;
      AT 20, 130 ;
      TO 490, 500 ;
      TITLE "Area size (top 10 values)" ;
      TYPE PIE ;
      SERIES aSer ;
      DEPTH 15 ;
      SERIENAMES aSerName2 ;
      COLORS aClrs ;
      3DVIEW ;
      SHOWXVALUES ;
      SHOWLEGENDS

   GraphTest.Button_2.SetFocus

RETURN

PROCEDURE DrawChart_3 ( aSer )

   nGraphType := 3

   ERASE WINDOW GraphTest

   DRAW GRAPH ;
      IN WINDOW GraphTest ;
      AT 20, 0 ;
      TO 500, 590 ;
      TITLE "Population density (top 20 values)" ;
      TYPE BARS ;
      SERIES aSer ;
      YVALUES aSerVal3 ;
      DEPTH 4 ;
      BARWIDTH 8 ;
      HVALUES 5 ;
      SERIENAMES aSerName3 ;
      COLORS aClrs ;
      3DVIEW ;
      SHOWXGRID ;
      SHOWXVALUES ;
      SHOWLEGENDS LEGENDSWIDTH 105 DATAMASK "9 999"

   GraphTest.Button_3.SetFocus

RETURN

PROCEDURE PrintGraph()

   GraphTest.Button_4.SetFocus

   SWITCH nGraphType
   CASE 1
      PRINT GRAPH ;
         IN WINDOW GraphTest ;
         AT 30, 20 ;
         TO 510, 610 ;
         TITLE "Population (top 10 values)" ;
         TYPE BARS ;
         SERIES aSer1 ;
         YVALUES aSerVal1 ;
         DEPTH 12 ;
         BARWIDTH 12 ;
         HVALUES 10 ;
         SERIENAMES aSerName1 ;
         COLORS aClrs ;
         3DVIEW ;
         SHOWXGRID ;
         SHOWXVALUES ;
         SHOWLEGENDS LEGENDSWIDTH 70 DATAMASK "9,999,999" ;
         LIBRARY HBPRINT
      EXIT
   CASE 2
      PRINT GRAPH ;
         IN WINDOW GraphTest ;
         AT 30, 130 ;
         TO 500, 500 ;
         TITLE "Area size (top 10 values)" ;
         TYPE PIE ;
         SERIES aSer2 ;
         DEPTH 15 ;
         SERIENAMES aSerName2 ;
         COLORS aClrs ;
         3DVIEW ;
         SHOWXVALUES ;
         SHOWLEGENDS ;
         LIBRARY HBPRINT
      EXIT
   CASE 3
      PRINT GRAPH ;
         IN WINDOW GraphTest ;
         AT 30, 0 ;
         TO 510, 590 ;
         TITLE "Population density (top 20 values)" ;
         TYPE BARS ;
         SERIES aSer3 ;
         YVALUES aSerVal3 ;
         DEPTH 4 ;
         BARWIDTH 8 ;
         HVALUES 5 ;
         SERIENAMES aSerName3 ;
         COLORS aClrs ;
         3DVIEW ;
         SHOWXGRID ;
         SHOWXVALUES ;
         SHOWLEGENDS LEGENDSWIDTH 105 DATAMASK "9 999" ;
         LIBRARY HBPRINT
   END

RETURN

PROCEDURE OpenTable

   LOCAL cRDD
   LOCAL cComm
   LOCAL n

   DEFAULT cRDD := "SQLRDD"

   Connect( @cRDD ) // see connect.prg

   // Request data for Chart 1
   //
   cComm := "SELECT * FROM Country ORDER BY Population DESC"

   dbUseArea( .F., "SQLRDD", cComm, "t1" )

   // One serie data
   aSer1 := Array( 10, 1 )
   aSerVal1 := Array( 10 )
   aSerName1 := Array( 10 )

   n := 0
   t1->( dbGoTop() )
   DO WHILE t1->( RecNo() ) <= 10 // top 10 values
      aSer1[ ++n, 1 ] := t1->Population / 1000
      aSerVal1[ n ] := t1->NAME
      aSerName1[ n ] := aSerVal1[ n ]
      t1->( dbSkip() )
   ENDDO
   dbCloseArea()

   // Request data for Chart 2
   //
   cComm := "SELECT * FROM Country ORDER BY SurfaceArea DESC"

   dbUseArea( .F., "SQLRDD", cComm, "t2" )

   // One serie data
   aSer2 := Array( 10 )
   aSerName2 := Array( 10 )

   n := 0
   t2->( dbGoTop() )
   DO WHILE t2->( RecNo() ) <= 10 // top 10 values
      aSer2[ ++n ] := Round( t2->SurfaceArea / 1000, 2 )
      aSerName2[ n ] := Trim( t2->Name )
      t2->( dbSkip() )
   ENDDO
   dbCloseArea()

   // Request data for Chart 3
   //
   cComm := "SELECT Name, Population / SurfaceArea as off FROM Country WHERE SurfaceArea > 250 ORDER BY off DESC"

   dbUseArea( .F., "SQLRDD", cComm, "t3" )

   // One serie data
   aSer3 := Array( 20, 1 )
   aSerVal3 := Array( 20 )
   aSerName3 := Array( 20 )

   n := 0
   t3->( dbGoTop() )
   WHILE t3->( RecNo() ) <= 40 .AND. t3->Off > 5000
      t3->( dbSkip() )
   END
   DO WHILE t3->( RecNo() ) <= 40 // top 40 values
      IF n > 19
         EXIT
      ENDIF
      aSer3[ ++n, 1 ] := Round( t3->OFF, 3 )
      aSerVal3[ n ] := t3->NAME
      aSerName3[ n ] := Transform( aSer3[ n, 1 ], "9 999.999" ) + ' ' + aSerVal3[ n ]
      t3->( dbSkip() )
   ENDDO
   dbCloseArea()

   // First chart drawing
   DrawChart_1( aser1 )

RETURN

#include "connect.prg"
