/*

 BadaSystem
 Program       : nextnumber
 Modulo        : demo
 Compilador    : MINIGUI - Harbour Win32 GUI
 Link          : BCC 32 bit
 Autor         : Marcos Jarrín
 email         : marvijarrin@gmail.com
 website       : badasystem.org
 Date          : 29/07/2022
 Update        : 30/07/2022

*/

REQUEST DBFCDX

#include "minigui.ch"
#include "dbstruct.ch"

REQUEST DBFCDX

PROCEDURE Main()

   rddSetDefault( "DBFCDX" )

   DEFINE WINDOW test ;
         AT 0, 0 ;
         WIDTH 400 ;
         HEIGHT 580 ;
         TITLE "TEST NEXT NUMBER" ;
         MAIN ;
         NOMAXIMIZE ;
         FONT 'ARIAL' SIZE 9 ;
         ON INIT OpenTable() ;
         ON RELEASE CloseTable()


      @ 10, 10 BROWSE Browse_1 ;
         WIDTH 380 ;
         HEIGHT 480 ;
         HEADERS { 'Numeric code', 'Character code' } ;
         WIDTHS { 170, 170 } ;
         WORKAREA test ;
         FIELDS { 'test->codigo_n', 'test->codigo_c' }


      @ 500, 70 BUTTON PROCESO CAPTION '&Process' ACTION Proceso()
      @ 500, 240 BUTTON EXIT_ALL CAPTION '&Exit' ACTION test.RELEASE


   END WINDOW

   CENTER WINDOW test

   ACTIVATE WINDOW test

RETURN

//
//
//
PROCEDURE OpenTable()

   FIELD codigo_n, codigo_c IN test
   LOCAL aStructure := {}

   IF File( "test.dbf" )
      dbUseArea( .T., , "test", "test", .T. )
      SET ORDER TO TAG codigo_n
   ELSE
      AAdd( aStructure, { "codigo_n", "N", 4, 0 } )
      AAdd( aStructure, { "codigo_c", "C", 4, 0 } )

      dbCreate( "test", aStructure )
      USE test ALIAS test NEW shared
      INDEX ON codigo_n TAG codigo_n
      INDEX ON codigo_c TAG codigo_c
      SET ORDER TO TAG codigo_n
   ENDIF

RETURN

//
//
//
PROCEDURE CloseTable()

   dbCloseAll()

RETURN

//
// Increases a value of 1 to each field, be it numeric or character
//
PROCEDURE Proceso()

   LOCAL aStructure := {}
   LOCAL nValor1, nValor2

   aStructure := test->( dbStruct() )

   test->( dbAppend() )
   nValor1 := NextNumber( "test", "codigo_n", 1 )
   nValor2 := NextNumber( "test", "codigo_c", 2 )

   IF Len( nValor2 ) > aStructure[ 2 ][ DBS_LEN ]
      msgbox( "Value is larger than the maximum allowed" )
   ELSE
      test->codigo_n := NextNumber( "test", "codigo_n", 1 )
      test->codigo_c := NextNumber( "test", "codigo_c", 2 )
   ENDIF

   _BrowseEnd( "browse_1", "test" )
   test.browse_1.Setfocus

RETURN
