/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2023 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"

#include "sqlrdd.ch"

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
	LOCAL cRDD

	DEFAULT cRDD := "SQLRDD"

	Connect( @cRDD ) // see connect.prg

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MYSQL SQLRDD Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTable() ;
		ON RELEASE CloseTable()

		DEFINE MAIN MENU

			DEFINE POPUP 'File'
				ITEM "Is SQL WorkArea ?" ACTION MsgInfo(IsSQLWorkarea(), SR_GetRddName())
				ITEM "Exit"	ACTION ThisWindow.Release()
			END POPUP

		END MENU

		@ 10,10 BROWSE Browse_1	;
			WIDTH 610	;
			HEIGHT 390	;
			HEADERS { 'Country' , 'Capital City' } ;
			WIDTHS { 150 , 150 } ;
			WORKAREA Country ;
			FIELDS { 'Country' , 'Capital_City' }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return NIL

*--------------------------------------------------------*
Procedure OpenTable
*--------------------------------------------------------*
   LOCAL cComm

   RDDSETDEFAULT( "SQLRDD" )

   cComm := [SELECT Country.Name AS Country, City.Name AS Capital_City ] + ;
            [FROM Country, City ] + ;
            [WHERE Country.Capital = City.ID ] + ;
            [ORDER BY Country, Capital_City]

   dbUseArea( .T.,, cComm, "Country" )

Return

*--------------------------------------------------------*
Procedure CloseTable
*--------------------------------------------------------*

   dbCloseAll()

   SR_End()

Return

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
