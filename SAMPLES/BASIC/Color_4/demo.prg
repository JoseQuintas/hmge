/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * (c) 2020 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"
#include "winprint.ch"

STATIC nLabelObj := 1


FUNCTION MAIN

   LOCAL aSymbol, aSymbol2, aSymbol3, y, x, cSymbol

   aSymbol := { 'WHITE', 'BLUE', 'GREEN', 'FUCHSIA', 'RED', 'PURPLE', 'YELLOW', 'OLIVE', 'SILVER', 'GRAY' }
   aSymbol2 := { 'PINK', 'BROWN', 'greenyellow', 'ORANGE', 'MAROON', 'AQUA', 'NAVY', 'TEAL', 'thistle', 'tomato' }
   aSymbol3 := { 'antiquewhite', 'blueviolet', 'goldenrod', 'royalblue', 'rosybrown', 'aquamarine', 'blanchedalmond', 'burlywood', 'honeydew', 'powderblue' }

   DEFINE WINDOW Form_1 ;
         WIDTH 400 ;
         HEIGHT 380 ;
         TITLE 'Character Colors Demo' ;
         MAIN

      y := 20
      x := 20

      FOR EACH cSymbol IN aSymbol
         @ y, x LABEL ( 'Lbl_' + hb_ntos( nLabelObj++ ) ) WIDTH 100 HEIGHT 24 ;
            VALUE cSymbol CENTERALIGN VCENTERALIGN BACKCOLOR cColorToArray( cSymbol )

         y += 30
      NEXT

      y := 20
      x += 120

      FOR EACH cSymbol IN aSymbol2
         @ y, x LABEL ( 'Lbl_' + hb_ntos( nLabelObj++ ) ) WIDTH 100 HEIGHT 24 ;
            VALUE cSymbol CENTERALIGN VCENTERALIGN BACKCOLOR cColorToArray( cSymbol )

         y += 30
      NEXT

      y := 20
      x += 120

      FOR EACH cSymbol IN aSymbol3
         @ y, x LABEL ( 'Lbl_' + hb_ntos( nLabelObj++ ) ) WIDTH 100 HEIGHT 24 ;
            VALUE cSymbol CENTERALIGN VCENTERALIGN BACKCOLOR cColorToArray( cSymbol )

         y += 30
      NEXT

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION cColorToArray( gr )

   LOCAL data, hexNumber, r

   INIT PRINTSYS
   data := HBPRNCOLOR( gr )
   RELEASE PRINTSYS

   hexNumber := DECTOHEXA( data )
   r := Rgb( HEXATODEC( SubStr( HexNumber, -2 ) ), HEXATODEC( SubStr( HexNumber, 5, 2 ) ), HEXATODEC( SubStr( HexNumber, 3, 2 ) ) )

RETURN HMG_n2RGB( r )
