/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Load/Save Items into VIRTUAL GRID
 * Demo was contributed to HMG forum by Edward 18/Jun/2021
 */

#include "hmg.ch"

#define ARRAY_FILENAME  'Items.Array'

FUNCTION MAIN

   LOCAL aItems := {}

   IF ! File ( ARRAY_FILENAME )
      StrFile ( hb_Serialize( { { 'Simpson', 'Homer', '555-5555' }, ;
         { 'Mulder', 'Fox', '324-6432' }, ;
         { 'Smart', 'Max', '432-5892' }, ;
         { 'Grillo', 'Pepe', '894-2332' }, ;
         { 'Kirk', 'James', '346-9873' }, ;
         { 'Barriga', 'Carlos', '394-9654' }, ;
         { 'Flanders', 'Ned', '435-3211' }, ;
         { 'Smith', 'John', '123-1234' }, ;
         { 'Pedemonti', 'Flavio', '000-0000' }, ;
         { 'Gomez', 'Juan', '583-4832' }, ;
         { 'Fernandez', 'Raul', '321-4332' }, ;
         { 'Borges', 'Javier', '326-9430' }, ;
         { 'Alvarez', 'Alberto', '543-7898' }, ;
         { 'Gonzalez', 'Ambo', '437-8473' }, ;
         { 'Batistuta', 'Gol', '485-2843' }, ;
         { 'Vinazzi', 'Amigo', '394-5983' }, ;
         { 'Pedemonti', 'Flavio', '534-7984' }, ;
         { 'Samarbide', 'Armando', '854-7873' }, ;
         { 'Pradon', 'Alejandra', '???-????' }, ;
         { 'Reyes', 'Monica', '432-5836' } } ), ARRAY_FILENAME )
   ENDIF

   DEFINE WINDOW Form_1 ;
         AT 0, 0 ;
         WIDTH 550 ;
         HEIGHT 400 ;
         TITLE 'Hello World!' ;
         MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Load Items' ACTION ( aItems := hb_Deserialize ( FileStr ( ARRAY_FILENAME ) ), Form_1.Grid_1.ItemCount := Len ( aItems ), Form_1.Grid_1.Refresh, MsgInfo ( "Items Loaded" ) )
            MENUITEM 'Save Items' ACTION ( StrFile ( hb_Serialize( aItems ), ARRAY_FILENAME ), MsgInfo ( "Items Saved" ) )
            MENUITEM 'Clear Items' ACTION ( aItems := {}, Form_1.Grid_1.ItemCount := Len ( aItems ), Form_1.Grid_1.Refresh )
         END POPUP
      END MENU

      @ 10, 10 GRID Grid_1 ;
         WIDTH 400 ;
         HEIGHT 330 ;
         HEADERS { 'Last Name', 'First Name', 'Phone' } ;
         WIDTHS { 140, 140, 90 } ;
         VIRTUAL ;
         ITEMCOUNT Len ( aItems ) ;
         ON QUERYDATA QueryTest( aItems ) ;
         CELLNAVIGATION ;
         VALUE { 1, 1 }

      @ 10, 440 BUTTON bUp CAPTION "Move Up" ACTION aItems := moveUp( aItems ) WIDTH 80
      @ 40, 440 BUTTON bDown CAPTION "Move Down" ACTION aItems := moveDown( aItems ) WIDTH 80
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL

PROCEDURE QueryTest( aItems )

   LOCAL i := This.QueryRowIndex
   LOCAL j := This.QueryColIndex

   This.QueryData := aItems[ i ][ j ]

RETURN

FUNCTION moveUp( aItems )

   LOCAL nPos := Form_1.Grid_1.VALUE[ 1 ]
   LOCAL nCol := Form_1.Grid_1.VALUE[ 2 ]
   LOCAL aRow
   IF Len ( aItems ) > 0 .AND. nPos > 1
      aRow := aItems[ nPos ]
      hb_ADel( aItems, nPos, .T. )
      hb_AIns( aItems, nPos - 1, aRow, .T. )
      Form_1.Grid_1.Refresh
      Form_1.Grid_1.VALUE := { nPos - 1, nCol }
   ENDIF

RETURN aItems

FUNCTION moveDown( aItems )

   LOCAL nPos := Form_1.Grid_1.VALUE[ 1 ]
   LOCAL nCol := Form_1.Grid_1.VALUE[ 2 ]
   LOCAL aRow
   IF Len ( aItems ) > 0 .AND. nPos < Len ( aItems )
      aRow := aItems[ nPos ]
      hb_ADel( aItems, nPos, .T. )
      hb_AIns( aItems, nPos + 1, aRow, .T. )
      Form_1.Grid_1.Refresh
      Form_1.Grid_1.VALUE := { nPos + 1, nCol }
   ENDIF

RETURN aItems
