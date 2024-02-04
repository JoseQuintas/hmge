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
				ITEM "Exit"	ACTION ThisWindow.Release()
			END POPUP

		END MENU

		@ 10,10 BROWSE Browse_1	;
			WIDTH 610	;
			HEIGHT 390	;
			HEADERS { 'Country' , 'Language' } ;
			WIDTHS { 150 , 150 } ;
			WORKAREA Country ;
			FIELDS { 'Country' , 'Language' }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return NIL

*--------------------------------------------------------*
Procedure OpenTable
*--------------------------------------------------------*
   LOCAL cComm

   RDDSETDEFAULT( "SQLRDD" )

   cComm := [SELECT Country.Name AS Country, CountryLanguage.Language AS Language ] + ;
            [FROM Country, CountryLanguage ] + ;
            [WHERE Country.Code = CountryLanguage.CountryCode AND CountryLanguage.IsOfficial = 'T'] + ;
            [ORDER BY Country, Language]

   dbUseArea( .T.,, cComm, "Country" )

Return

*--------------------------------------------------------*
Procedure CloseTable
*--------------------------------------------------------*

   dbCloseAll()

Return

#include "connect.prg"
