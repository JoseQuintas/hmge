/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2023 Grigory Filatov <gfilatov@inbox.ru>
 *
 */

#include "minigui.ch"

REQUEST DBFCDX

*--------------------------------------------------------*
FUNCTION Main()
*--------------------------------------------------------*

   rddSetDefault( "DBFCDX" )

   DEFINE WINDOW Form_1 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'DBFCDX Demo' ;
         MAIN NOMAXIMIZE ;
         ON INIT OpenTable() ;
         ON RELEASE CloseTable()

      DEFINE MAIN MENU

         DEFINE POPUP 'Test'
            MENUITEM 'Add record' ACTION AddRecord( 'ARG', 'Argentina', 38740000 )
            SEPARATOR
            ITEM "Exit" ACTION ThisWindow.Release()
         END POPUP

      END MENU

      @ 10, 10 BROWSE Browse_1 ;
         WIDTH 610 ;
         HEIGHT 390 ;
         HEADERS { 'Code', 'Name', 'Residents' } ;
         WIDTHS { 50, 160, 100 } ;
         WORKAREA country ;
         FIELDS { 'Code', 'Name', 'Residents' } ;
         JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT } ;
         EDIT ;
         INPLACE ;
         READONLY { .T., .F., .F. }

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL

*--------------------------------------------------------*
PROCEDURE OpenTable
*--------------------------------------------------------*

   Form_1.Browse_1.VISIBLE := .F.

   CreateTable()

   INDEX ON FIELD->RESIDENTS TAG residents TO country

   GO TOP

   Form_1.Browse_1.VISIBLE := .T.

RETURN

*--------------------------------------------------------*
PROCEDURE CloseTable
*--------------------------------------------------------*

   dbCloseArea( "country" )

RETURN

*--------------------------------------------------------*
FUNCTION CreateTable
*--------------------------------------------------------*

   LOCAL aStruct := { ;
      { "CODE", "C", 3, 0 }, ;
      { "NAME", "C", 50, 0 }, ;
      { "RESIDENTS", "N", 11, 0 } ;
      }

   dbCreate( "country", aStruct, "DBFCDX" )

   USE country /*EXCLUSIVE*/ VIA "DBFCDX"

   dbAppend()
   REPLACE CODE WITH 'LTU', NAME WITH 'Lithuania', RESIDENTS WITH 3369600
   dbAppend()
   REPLACE CODE WITH 'USA', NAME WITH 'United States of America', RESIDENTS WITH 305397000
   dbAppend()
   REPLACE CODE WITH 'POR', NAME WITH 'Portugal', RESIDENTS WITH 10617600
   dbAppend()
   REPLACE CODE WITH 'POL', NAME WITH 'Poland', RESIDENTS WITH 38115967
   dbAppend()
   REPLACE CODE WITH 'AUS', NAME WITH 'Australia', RESIDENTS WITH 21446187
   dbAppend()
   REPLACE CODE WITH 'FRA', NAME WITH 'France', RESIDENTS WITH 64473140
   dbAppend()
   REPLACE CODE WITH 'RUS', NAME WITH 'Russia', RESIDENTS WITH 141900000

RETURN NIL

*--------------------------------------------------------*
PROCEDURE AddRecord( cCode, cName, nResidents )
*--------------------------------------------------------*

   APPEND BLANK

   REPLACE CODE WITH cCode, ;
      NAME WITH cName, ;
      RESIDENTS WITH nResidents

   Form_1.Browse_1.VALUE := country->( RecNo() )
   Form_1.Browse_1.Refresh

RETURN
