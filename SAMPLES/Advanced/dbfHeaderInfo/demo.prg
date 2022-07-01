/*
 * MiniGUI DBF Header Info Test
 * (c) 2010 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#include "dbstruct.ch"
#include "fileio.ch"


PROCEDURE Main()

   LOCAL aResult

   filltable( 100 )

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 450 ;
      HEIGHT 450 ;
      TITLE 'DBF Header Info' ;
      MAIN

   DEFINE MAIN MENU

      DEFINE POPUP "Test"

         MENUITEM 'Get Header Info' ACTION ( aResult := GetHeaderInfo( 'test.dbf' ), ;
            AChoice( ,,,, aResult, "Header Info of TEST.DBF" ) )

         SEPARATOR

         ITEM 'Exit' ACTION Form_1.Release()

      END POPUP

   END MENU

   END WINDOW

   Form_1.Center()
   Form_1.Activate()

RETURN


PROCEDURE filltable ( nCount )

   LOCAL aDbf[ 11 ][ 4 ], i

   IF !File( 'test.dbf' )
      aDbf[ 1 ][ DBS_NAME ] := "First"
      aDbf[ 1 ][ DBS_TYPE ] := "Character"
      aDbf[ 1 ][ DBS_LEN ]  := 20
      aDbf[ 1 ][ DBS_DEC ]  := 0
      //
      aDbf[ 2 ][ DBS_NAME ] := "Last"
      aDbf[ 2 ][ DBS_TYPE ] := "Character"
      aDbf[ 2 ][ DBS_LEN ]  := 20
      aDbf[ 2 ][ DBS_DEC ]  := 0
      //
      aDbf[ 3 ][ DBS_NAME ] := "Street"
      aDbf[ 3 ][ DBS_TYPE ] := "Character"
      aDbf[ 3 ][ DBS_LEN ]  := 30
      aDbf[ 3 ][ DBS_DEC ]  := 0
      //
      aDbf[ 4 ][ DBS_NAME ] := "City"
      aDbf[ 4 ][ DBS_TYPE ] := "Character"
      aDbf[ 4 ][ DBS_LEN ]  := 30
      aDbf[ 4 ][ DBS_DEC ]  := 0
      //
      aDbf[ 5 ][ DBS_NAME ] := "State"
      aDbf[ 5 ][ DBS_TYPE ] := "Character"
      aDbf[ 5 ][ DBS_LEN ]  := 2
      aDbf[ 5 ][ DBS_DEC ]  := 0
      //
      aDbf[ 6 ][ DBS_NAME ] := "Zip"
      aDbf[ 6 ][ DBS_TYPE ] := "Character"
      aDbf[ 6 ][ DBS_LEN ]  := 10
      aDbf[ 6 ][ DBS_DEC ]  := 0
      //
      aDbf[ 7 ][ DBS_NAME ] := "Hiredate"
      aDbf[ 7 ][ DBS_TYPE ] := "Date"
      aDbf[ 7 ][ DBS_LEN ]  := 8
      aDbf[ 7 ][ DBS_DEC ]  := 0
      //
      aDbf[ 8 ][ DBS_NAME ] := "Married"
      aDbf[ 8 ][ DBS_TYPE ] := "Logical"
      aDbf[ 8 ][ DBS_LEN ]  := 1
      aDbf[ 8 ][ DBS_DEC ]  := 0
      //
      aDbf[ 9 ][ DBS_NAME ] := "Age"
      aDbf[ 9 ][ DBS_TYPE ] := "Numeric"
      aDbf[ 9 ][ DBS_LEN ]  := 2
      aDbf[ 9 ][ DBS_DEC ]  := 0
      //
      aDbf[ 10 ][ DBS_NAME ] := "Salary"
      aDbf[ 10 ][ DBS_TYPE ] := "Numeric"
      aDbf[ 10 ][ DBS_LEN ]  := 6
      aDbf[ 10 ][ DBS_DEC ]  := 0
      //
      aDbf[ 11 ][ DBS_NAME ] := "Notes"
      aDbf[ 11 ][ DBS_TYPE ] := "Character"
      aDbf[ 11 ][ DBS_LEN ]  := 70
      aDbf[ 11 ][ DBS_DEC ]  := 0

      dbCreate( "test", aDbf )
   ENDIF

   USE test
   ZAP

   FOR i := 1 TO nCount
      APPEND BLANK

      REPLACE   first      WITH   'first'   + Str( i )
      REPLACE   last       WITH   'last'    + Str( i )
      REPLACE   street     WITH   'street'  + Str( i )
      REPLACE   city       WITH   'city'    + Str( i )
      REPLACE   state      WITH   Chr( hb_RandomInt( 65, 90 ) ) + Chr( hb_RandomInt( 65, 90 ) )
      REPLACE   zip        WITH   AllTrim( Str( hb_RandomInt( 9999 ) ) )
      REPLACE   hiredate   WITH   Date() -20000 + i
      REPLACE   married    WITH   ( hb_RandomInt() == 1 )
      REPLACE   age        WITH   hb_RandomInt( 99 )
      REPLACE   salary     WITH   hb_RandomInt( 10000 )
      REPLACE   notes      WITH   'notes' + Str( i )
   NEXT i

   USE

RETURN


FUNCTION AChoice( t, l, b, r, aInput, cTitle, dummy, nValue )

   LOCAL aItems := {}

   HB_SYMBOL_UNUSED( t )
   HB_SYMBOL_UNUSED( l )
   HB_SYMBOL_UNUSED( b )
   HB_SYMBOL_UNUSED( r )
   HB_SYMBOL_UNUSED( dummy )

   DEFAULT cTitle TO "Please, select", nValue TO 1

   AEval( aInput, {|x| AAdd( aItems, x[ 2 ] + ": " + hb_ValToStr( x[ 1 ] ) ) } )

   DEFINE WINDOW Win_2 ;
      AT 0, 0 ;
      WIDTH 400 HEIGHT 400 + IF( IsXPThemeActive(), 7, 0 ) ;
      TITLE cTitle ;
      TOPMOST ;
      NOMAXIMIZE NOSIZE ;
      ON INIT Win_2.Button_1.SetFocus

   @ 335, 190 BUTTON Button_1 ;
      CAPTION 'OK' ;
      ACTION {|| nValue := Win_2.List_1.Value, Win_2.Release } ;
      WIDTH 80

   @ 335, 295 BUTTON Button_2 ;
      CAPTION 'Cancel' ;
      ACTION {|| nValue := 0, Win_2.Release } ;
      WIDTH 80

   @ 20, 15 LISTBOX List_1 ;
      WIDTH 360 ;
      HEIGHT 300 ;
      ITEMS aItems ;
      VALUE nValue ;
      FONT "Ms Sans Serif" ;
      SIZE 12 ;
      ON DBLCLICK {|| nValue := Win_2.List_1.Value, Win_2.Release }

   ON KEY ESCAPE ACTION Win_2.Button_2.OnClick

   END WINDOW

   CENTER WINDOW Win_2
   ACTIVATE WINDOW Win_2

RETURN nValue


#define FIELD_ENTRY_SIZE  32
#define FIELD_NAME_SIZE   11

FUNCTION GetHeaderInfo( database )

   LOCAL aRet := {}
   LOCAL nHandle
   LOCAL dbfhead
   LOCAL h1, h2, h3, h4
   LOCAL dbftype
   LOCAL headrecs
   LOCAL headsize
   LOCAL recsize
   LOCAL nof
   LOCAL fieldlist
   LOCAL nfield
   LOCAL nPos
   LOCAL cFieldname
   LOCAL cType
   LOCAL cWidth, nWidth
   LOCAL nDec, cDec

   IF .NOT. '.DBF' $ Upper( database )
      database += '.DBF'
   ENDIF
   IF ( nHandle := FOpen( database, FO_READ ) ) == -1
      msgstop( 'Can not open file ' + Upper( database ) + ' for reading!' )
      RETURN aRet
   ENDIF

   dbfhead := Space( 4 )
   FRead( nHandle, @dbfhead, 4 )

   h1 := FT_BYT2HEX( SubStr( dbfhead, 1, 1 ) )   // must be 03h or F5h if .fpt exists
   dbftype := h1
   h2 := FT_BYT2HEX( SubStr( dbfhead, 2, 1 ) )   // yy hex (between 00h and FFh) added to 1900 (decimal)
   h3 := FT_BYT2HEX( SubStr( dbfhead, 3, 1 ) )   // mm hex (between 01h and 0Ch)
   h4 := FT_BYT2HEX( SubStr( dbfhead, 4, 1 ) )   // dd hex (between 01h and 1Fh)
   IF hex2dec( h3 ) > 12 .OR. hex2dec( h4 ) > 31
      MsgInfo( 'Date damage in header!' )
   ENDIF

   AAdd( aRet, { '0x' + dbftype, 'Type of file' } )
   AAdd( aRet, { StrZero( hex2dec( h4 ), 2 ) + '.' + StrZero( hex2dec( h3 ), 2 ) + '.' + StrZero( hex2dec( h2 ) -if( hex2dec( h2 ) > 100, 100, 0 ), 2 ), 'Last update (DD.MM.YY)' } )

   headrecs := Space( 4 ) // number of records in file
   FSeek( nHandle, 4, FS_SET )
   FRead( nHandle, @headrecs, 4 )

   h1 := FT_BYT2HEX( SubStr( headrecs, 1, 1 ) )
   h2 := FT_BYT2HEX( SubStr( headrecs, 2, 1 ) )
   h3 := FT_BYT2HEX( SubStr( headrecs, 3, 1 ) )
   h4 := FT_BYT2HEX( SubStr( headrecs, 4, 1 ) )
   headrecs := Int( hex2dec( h1 ) + 256 * hex2dec( h2 ) + ( 256 ** 2 ) * hex2dec( h3 ) + ( 256 ** 3 ) * hex2dec( h4 ) )

   AAdd( aRet, { headrecs, 'Number of records' } )

   headsize := Space( 2 )
   FRead( nHandle, @headsize, 2 )

   h1 := FT_BYT2HEX( SubStr( headsize, 1, 1 ) )
   h2 := FT_BYT2HEX( SubStr( headsize, 2, 1 ) )
   headsize := hex2dec( h1 ) + 256 * hex2dec( h2 ) // header size

   AAdd( aRet, { headsize, 'Header size' } )

   recsize := Space( 2 )
   FRead( nHandle, @recsize, 2 )

   h1 := FT_BYT2HEX( SubStr( recsize, 1, 1 ) )
   h2 := FT_BYT2HEX( SubStr( recsize, 2, 1 ) )
   recsize := hex2dec( h1 ) + 256 * hex2dec( h2 ) // record size

   AAdd( aRet, { recsize, 'Record size' } )

   nof := Int( headsize / 32 ) - 1  // number of fields

   AAdd( aRet, { nof, 'Fields count' } )

   fieldlist := {}
   FOR nField = 1 TO nof
      nPos := nField * FIELD_ENTRY_SIZE
      FSeek( nHandle, nPos, FS_SET ) // Goto File Offset of the nField-th Field
      cFieldName := Space( FIELD_NAME_SIZE )
      FRead( nHandle, @cFieldName, FIELD_NAME_SIZE )
      cFieldName := StrTran( cFieldName, Chr( 0 ), ' ' )
      cFieldName := RTrim( SubStr( cFieldName, 1, At( ' ', cFieldName ) ) )

      cType := Space( 1 )
      FRead( nHandle, @cType, 1 )

      FSeek( nHandle, 4, FS_RELATIVE )
      IF ctype == 'C'
         cWidth := Space( 2 )
         FRead( nHandle, @cWidth, 2 )
         h1 := FT_BYT2HEX( SubStr( cWidth, 1, 1 ) )
         h2 := FT_BYT2HEX( SubStr( cWidth, 2, 1 ) )
         nWidth := hex2dec( h1 ) + 256 * hex2dec( h2 ) // record size
         nDec := 0
      ELSE
         cWidth := Space( 1 )
         FRead( nHandle, @cWidth, 1 )
         nWidth := hex2dec( FT_BYT2HEX( cWidth ) )
         cDec := Space( 1 )
         FRead( nHandle, @cDec, 1 )
         nDec := hex2dec( FT_BYT2HEX( cDec ) )
      ENDIF
      AAdd( fieldlist, { cFieldName, cType, nWidth, nDec } )
   NEXT

   FClose( nHandle )

   AAdd( aRet, { '', 'Fields structure' } )
   AEval( fieldlist, {|x, i| AAdd( aRet, { x[ 1 ] + " - " + x[ 2 ] + "(" + hb_ntos( x[ 3 ] ) + "," + hb_ntos( x[ 4 ] ) + ")", hb_ntos( i ) } ) } )

RETURN aRet


#define HEXTABLE "0123456789ABCDEF"

FUNCTION HEX2DEC( cHexNum )

   LOCAL n, nDec := 0, nHexPower := 1

   FOR n := Len( cHexNum ) TO 1 STEP -1
      nDec += ( At( subs( Upper( cHexNum ), n, 1 ), HEXTABLE ) - 1 ) * nHexPower
      nHexPower *= 16
   NEXT

RETURN nDec


FUNCTION FT_BYT2HEX( cByte, plusH )

   LOCAL xHexString

   DEFAULT plusH := .F.

   IF ValType( cByte ) == "C"
      xHexString := SubStr( HEXTABLE, Int( Asc( cByte ) / 16 ) + 1, 1 ) ;
         + SubStr( HEXTABLE, Int( Asc( cByte ) % 16 ) + 1, 1 ) ;
         + iif( plusH, "h", '' )
   ENDIF

RETURN xHexString
