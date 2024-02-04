/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2023 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"

#include "sqlrdd.ch"

STATIC nBrwH

*--------------------------------------------------------*
FUNCTION Main()
*--------------------------------------------------------*
   LOCAL cRDD

   DEFAULT cRDD := "SQLRDD"

   Connect( @cRDD ) // see connect.prg

   rddSetDefault( "SQLRDD" )

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Explore SAKILA Database with SQLRDD Demo' ;
         MAIN NOMAXIMIZE ;
         ON INIT OpenTable() ;
         ON RELEASE CloseTable()

      DEFINE MAIN MENU

         DEFINE POPUP 'Requests'
            ITEM "Busiest Actor" ACTION ( OpenTable( GetSelect( 0 ) ), SetBrowse( 0 ) ) ;
               MESSAGE "Find the full name of the actor who has acted in the maximum number of movies."
            ITEM "Third most Busy Actor" ACTION ( OpenTable( GetSelect( 1 ) ), SetBrowse( 1 ) ) ;
               MESSAGE "Find the full name of the actor who has acted in the third most number of movies."
            ITEM "Highest Grossing Film" ACTION ( OpenTable( GetSelect( 2 ) ), SetBrowse( 2 ) ) ;
               MESSAGE "Find the film which grossed the highest revenue for the video renting organization."
            ITEM "Film-obsessed City" ACTION ( OpenTable( GetSelect( 3 ) ), SetBrowse( 3 ) ) ;
               MESSAGE "Find the city which generated the maximum revenue for the organization."
            ITEM "Analysis of Movie Categories" ACTION ( OpenTable( GetSelect( 4 ) ), SetBrowse( 4 ) ) ;
               MESSAGE "Find out how many times a particular movie category is rented."
            ITEM "Country-wise Analysis of Movies" ACTION ( OpenTable( GetSelect( 5 ) ), SetBrowse( 5 ) ) ;
               MESSAGE "Find the number of movies rented across each country."
            SEPARATOR
            ITEM "Is SQL WorkArea ?" ACTION MsgInfo( IsSQLWorkarea(), SR_GetRddName() )
            SEPARATOR
            ITEM "Exit" ACTION ThisWindow.Release()
         END POPUP

      END MENU

      DEFINE STATUSBAR
         STATUSITEM "Produce a daily list of overdue rentals."
      END STATUSBAR

      nBrwH := Form_1.HEIGHT - Form_1.Statusbar.HEIGHT - 80

      @ 10, 10 BROWSE Browse_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Customer', 'Phone', 'Title' } ;
         WIDTHS { 200, 150, 150 } ;
         WORKAREA Result ;
         FIELDS { 'Customer', 'Phone', 'Title' }

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL

*--------------------------------------------------------*
PROCEDURE OpenTable( cComm )
*--------------------------------------------------------*

   DEFAULT cComm := ;
      [SELECT CONCAT(customer.last_name, ', ', customer.first_name) AS customer, address.phone, film.title ] + ;
      [FROM rental ] + ;
      [INNER JOIN customer ON rental.customer_id = customer.customer_id ] + ;
      [INNER JOIN address ON customer.address_id = address.address_id ] + ;
      [INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id ] + ;
      [INNER JOIN film ON inventory.film_id = film.film_id ] + ;
      [WHERE rental.return_date IS NULL AND rental_date + INTERVAL film.rental_duration DAY < CURRENT_DATE() ] + ;
      [ORDER BY title ] + ;
      [LIMIT 5]

   dbUseArea( .F.,, cComm, "Result" )

RETURN

*--------------------------------------------------------*
PROCEDURE SetBrowse( n )
*--------------------------------------------------------*

   Form_1.Browse_1.RELEASE
   DO EVENTS

   SWITCH n
   CASE 1

      @ 10, 10 BROWSE Browse_1 ;
         PARENT Form_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Third most Busy Actor' } ;
         WIDTHS { 200 } ;
         WORKAREA Result ;
         FIELDS { 'Full_name' }

      EXIT

   CASE 2

      @ 10, 10 BROWSE Browse_1 ;
         PARENT Form_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Highest Grossing Film' } ;
         WIDTHS { 300 } ;
         WORKAREA Result ;
         FIELDS { 'Title' }

      EXIT

   CASE 3

      @ 10, 10 BROWSE Browse_1 ;
         PARENT Form_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Film-obsessed City' } ;
         WIDTHS { 200 } ;
         WORKAREA Result ;
         FIELDS { 'City' }

      EXIT

   CASE 4

      @ 10, 10 BROWSE Browse_1 ;
         PARENT Form_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Category', 'Rental count' } ;
         WIDTHS { 100, 85 } ;
         WORKAREA Result ;
         FIELDS { 'Name', 'Rental_count' }

      EXIT

   CASE 5

      @ 10, 10 BROWSE Browse_1 ;
         PARENT Form_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Country', 'Rental count' } ;
         WIDTHS { 230, 85 } ;
         WORKAREA Result ;
         FIELDS { 'Country', 'Rental_count' }

      EXIT

   OTHERWISE

      @ 10, 10 BROWSE Browse_1 ;
         PARENT Form_1 ;
         WIDTH 610 ;
         HEIGHT nBrwH ;
         HEADERS { 'Busiest Actor' } ;
         WIDTHS { 200 } ;
         WORKAREA Result ;
         FIELDS { 'Full_name' }

   END

   Form_1.Browse_1.Setfocus

RETURN

*--------------------------------------------------------*
FUNCTION GetSelect( n )
*--------------------------------------------------------*
   LOCAL cComm

   SWITCH n
   CASE 1
      cComm := ;
         [SELECT CONCAT(first_name, " ", last_name) AS Full_name ] + ;
         [FROM ACTOR ] + ;
         [LEFT JOIN FILM_ACTOR USING(ACTOR_ID) ] + ;
         [GROUP BY Full_name ] + ;
         [ORDER BY Count(film_id) DESC LIMIT 2, 1]

      EXIT

   CASE 2
      cComm := ;
         [SELECT Title ] + ;
         [FROM FILM ] + ;
         [INNER JOIN inventory USING(FILM_ID) ] + ;
         [INNER JOIN RENTAL USING(INVENTORY_ID) ] + ;
         [INNER JOIN PAYMENT USING(RENTAL_ID) ] + ;
         [GROUP BY Title ] + ;
         [ORDER BY SUM(amount) LIMIT 1]

      EXIT

   CASE 3
      cComm := ;
         [SELECT City ] + ;
         [FROM CITY ] + ;
         [INNER JOIN address USING(CITY_ID) ] + ;
         [INNER JOIN CUSTOMER USING(ADDRESS_ID) ] + ;
         [INNER JOIN PAYMENT USING(CUSTOMER_ID) ] + ;
         [GROUP BY City ] + ;
         [ORDER BY SUM(AMOUNT) DESC LIMIT 1]

      EXIT

   CASE 4
      cComm := ;
         [SELECT Name, COUNT(Name) AS Rental_count ] + ;
         [FROM category ] + ;
         [INNER JOIN film_category USING(CATEGORY_ID) ] + ;
         [INNER JOIN FILM USING(FILM_ID) ] + ;
         [INNER JOIN inventory USING(FILM_ID) ] + ;
         [INNER JOIN rental USING(INVENTORY_ID) ] + ;
         [GROUP BY Name ] + ;
         [ORDER BY Rental_count DESC]

      EXIT

   CASE 5
      cComm := ;
         [SELECT Country, COUNT(Rental_id) AS Rental_count ] + ;
         [FROM Country ] + ;
         [INNER JOIN city USING(COUNTRY_ID) ] + ;
         [INNER JOIN ADDRESS USING(CITY_ID) ] + ;
         [INNER JOIN CUSTOMER USING(ADDRESS_ID) ] + ;
         [INNER JOIN RENTAL USING(CUSTOMER_ID) ] + ;
         [GROUP BY Country ] + ;
         [ORDER BY Country ]

      EXIT

   OTHERWISE

      cComm := ;
         [SELECT CONCAT(first_name, " ", last_name) AS Full_name ] + ;
         [FROM ACTOR ] + ;
         [LEFT JOIN FILM_ACTOR USING(ACTOR_ID) ] + ;
         [GROUP BY Full_name ] + ;
         [ORDER BY Count(film_id) DESC LIMIT 1]

   END

RETURN cComm

*--------------------------------------------------------*
PROCEDURE CloseTable
*--------------------------------------------------------*

   dbCloseAll()

   SR_End()

RETURN

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
