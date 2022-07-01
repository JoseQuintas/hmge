/*

  LL_DBU : Low Level DBU.

  Not a real DBU, only an experimental work with very limited DB operations.

  Primary goal of this project is access, detect, inspect and dig a damaged table.

  Reasons of damage may be various, so recovery method too depend on a damage type.

  This program open a table by Low Level file access and read methods.

  A second usage may be inspecting how data recorded into a table; always in the visible form or not.

  I also tried some function to easy using of Virtual Grid. The virtual grid is a very handy control
  (even have more possibilities than standard Grid). But don't have AddItems and Refresh methods.
  This program have two little functions for this purpose ( VGridAddItem() and VGridRefresh() ).

  Another interesting point may be showing how can be implement "returning beginning of procedure" from anywhere
  of that procedure ( procedure : LL_UseTable() ).

  I hope that my friends find useful this humble work.

  Happy HMG'ing :D

  Bicahi Esgici

  2010, 12, 21

*/

/*
 * Adapted for MiniGUI Extended Edition by Grigory Filatov - Dec 2010
*/

#include "minigui.ch"
#include "fileio.ch"

STATIC aTblInfo, ;
      aTableStru, ;
      aTInfGrdItems, ;
      nFileHandle, ;
      nFileLength, ;
      nFilePointr, ;
      nTblHdrLeng, ;
      nTblRecLeng, ;
      aFInfNams, ;
      aRecoData

PROCEDURE Main( cTableNam )

   LOCAL aButtons := ;
    { { "hbprint_top", "Go to first record", 425, 96 }, ;
      { "hbprint_back", "Go to previous record", 425, 212 }, ;
      { "hbprint_next", "Go to next record", 425, 328 }, ;
      { "hbprint_end", "Go to last record", 425, 444 } }

   LOCAL nButton, ;
      cBtnName, ;
      cBtnPict, ;
      cBtnTTip, ;
      nBttnRow, ;
      nBttnCol

   SET CENT ON

   SET DATE GERM

   aTblInfo := {}
   aTableStru := Array( 10 )
   AFill( aTableStru, { '', '', '', '', '' } )

   aTInfGrdItems := {}

   nFileHandle := 0
   nFileLength := 0
   nFilePointr := 0
   nTblHdrLeng := 0
   nTblRecLeng := 0

   aFInfNams := ;
    { { 'Type', 'Table Type' }, ;
      { 'UDat', 'Last Update Date' }, ;
      { 'HLen', 'Header Length' }, ;
      { 'RLen', 'Record Length' }, ;
      { 'RCou', 'Record Count' }, ;
      { 'FCou', 'Field Count' }, ;
      { 'FSzC', 'File Size (Computed)' } }

   AEval( aFInfNams, {| a1 | AAdd( aTInfGrdItems, { a1[ 2 ], '' } ) } )

   aRecoData := {}

   DEFINE WINDOW frmLLDBUMain ;
         AT 0, 0 ;
         WIDTH 630 ;
         HEIGHT 550 ;
         TITLE 'LL DBU ( Low-level DBU )' ;
         ON INIT LL_UseTable( cTableNam ) ;
         MAIN ;
         ICON 'MAIN'

      ON KEY ESCAPE ACTION frmLLDBUMain.RELEASE

      DEFINE TAB tabLLDBUMain ;
            OF frmLLDBUMain ;
            AT 10, 10 ;
            WIDTH 596 ;
            HEIGHT 472 ;
            VALUE 1

         DEFINE PAGE 'Table Info'

            DEFINE GRID grdTblInfo
               PARENT frmLLDBUMain
               ROW 35
               COL 100
               WIDTH 376
               HEADERS { 'Info Name', 'Info Data' }
               WIDTHS { 130, 242 }
               ON QUERYDATA VGridAddItem( aTInfGrdItems )
               AUTOSIZEHEIGHT Len( aTInfGrdItems )

               VIRTUAL .T.

               ITEMCOUNT Len( aTInfGrdItems )

            END GRID // grdTblData

            DEFINE GRID grdTblStru
               PARENT frmLLDBUMain
               ROW 205
               COL 100
               WIDTH 376
               HEADERS { 'No', 'Field Name', 'Type', 'Width', 'Dec' }
               WIDTHS { 30, 100, 105, 60, 60 }
               AUTOSIZEHEIGHT 12

               VIRTUAL .T.

               COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER' }, ;
                  { 'TEXTBOX', 'CHARACTER' }, ;
                  { 'TEXTBOX', 'CHARACTER' }, ;
                  { 'TEXTBOX', 'NUMERIC', '99,9999' }, ;
                  { 'TEXTBOX', 'NUMERIC', '99' } }

               ON QUERYDATA VGridAddItem( aTableStru )

               ITEMCOUNT Len( aTableStru )

            END GRID // grdTblStru

         END PAGE // TabPage&DBInfo

          /*

             Second page of Tab ( record data : fields names and their contents )

          */

         DEFINE PAGE 'Record Data'
            DEFINE GRID grdTblData
               PARENT frmLLDBUMain
               ROW 35
               COL 10
               HEADERS { 'Field Name', 'Field Content' }
               WIDTHS { 80, 490 }
               AUTOSIZEHEIGHT 18
               AUTOSIZEWIDTH .T.

               VIRTUAL .T.

               ON QUERYDATA VGridAddItem( aRecoData )

            END GRID // grdTblData

            FOR nButton := 1 TO Len( aButtons )

               cBtnName := "btnNav_" + LTrim( Str( nButton ) )
               cBtnPict := aButtons[ nButton, 1 ]
               cBtnTTip := aButtons[ nButton, 2 ]
               nBttnRow := aButtons[ nButton, 3 ]
               nBttnCol := aButtons[ nButton, 4 ]

               DEFINE BUTTON &cBtnName
                  PARENT frmLLDBUMain
                  ROW nBttnRow
                  COL nBttnCol
                  PICTURE cBtnPict
                  ONCLICK LL_SKIP( Val( Right( This.NAME, 1 ) ) )
                  WIDTH 25
                  HEIGHT 25
                  TOOLTIP cBtnTTip
               END BUTTON // &cBtnName

            NEXT nButton

         END PAGE // TabPage&Record

      END TAB // tabLLDBUMain

      DEFINE CONTEXT MENU OF frmLLDBUMain
         ITEM 'Open Table' ACTION LL_UseTable()
         SEPARATOR
         ITEM 'About' ACTION MsgAbout()
      END MENU

      DEFINE STATUSBAR FONT 'Verdana' SIZE 8
         STATUSITEM "" WIDTH 400
         STATUSITEM "" WIDTH 47
         DATE WIDTH 83
         CLOCK WIDTH 73
      END STATUSBAR

   END WINDOW

   frmLLDBUMain.CENTER
   frmLLDBUMain.ACTIVATE

RETURN // Main()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
   An example procedure to show how can be implement "returning beginning of procedure" from anywhere of that procedure.
*/
PROCEDURE LL_UseTable( ;                       // Low-level USE (open) table
      cTableNam )

   LOCAL aTGHas := {}, ;
      nFVSnFT // file's validity status and file type

   WHILE .T.

      IF HB_ISNIL( cTableNam )

         cTableNam := GetFile ( { { 'Tables', '*.dbf' }, { 'All Files', '*.*' } }, ;  // acFilter
            'Select Table', ;   // cTitle
            , ;                 // cDefaultPath
            .F., ; // lMultiSelect
            .F. ) // lNoChangeDir
      ENDIF

      IF ! Empty( cTableNam ) .AND. File( cTableNam )

         IF ! Empty( nFileHandle )
            FClose( nFileHandle )
         ENDIF

         aTblInfo := HL_DBInfoLL( cTableNam, .F. )

         nFVSnFT := aTblInfo[ 1 ]

         IF nFVSnFT > 0 // Valid Table

            nFileHandle := aTblInfo[ 2 ]
            nTblHdrLeng := aTblInfo[ 3, 1, 2, 3, 2 ]
            nTblRecLeng := aTblInfo[ 3, 1, 2, 4, 2 ]
            nFileLength := FSeek( nFileHandle, 0, 2 )
            nFilePointr := FSeek( nFileHandle, nTblHdrLeng, 0 )

            aTGHas := aTblInfo[ 3, 1, 2 ]
            frmLLDBUMain.STATUSBAR.Item( 1 ) := aTGHas[ 1, 2 ] // Full file name
            aTGHas[ 1, 1 ] := "Type"
            aTGHas[ 1, 2 ] := HL_TablTypeNam( nFVSnFT )
            AEval( aTInfGrdItems, {| a1, i1 | a1[ 2 ] := aTGHas[ i1, 2 ] } )
            VGridRefresh( "frmLLDBUMain", "grdTblInfo" )

            aTableStru := aTblInfo[ 3, 2, 2 ]
            AEval( aTableStru, {| a1, i1 | ASize( a1, 5 ), AIns( a1, 1 ), a1[ 1 ] := Str( i1, 3 ) } )
            AEval( aTableStru, {| a1 | a1[ 3 ] += " ( " + HL_FldTypC2V( a1[ 3 ] ) + " )" } )

            frmLLDBUMain.grdTblStru.ItemCount := Len( aTableStru )
            VGridRefresh( "frmLLDBUMain", "grdTblStru" )

            /*
               Page - 2
            */

            aRecoData := { { '<Deleted>', '' } }

            AEval( aTableStru, {| a1 | AAdd( aRecoData, { a1[ 2 ], '' } ) } )

            frmLLDBUMain.grdTblData.ItemCount := Len( aTableStru ) + 1 // +1 for "deleted" mark
            VGridRefresh( "frmLLDBUMain", "grdTblData" )

            LL_SKIP( 1 ) // Go Top
            EXIT
         ELSE
            MsgStop( "Can't open (USE). This file probably isn't a table" )
            cTableNam := NIL
            // Here is LOOP point for return beginning of procedure/function. But it's unnecessary in this approach.
         ENDIF nFVSnFT > 0

      ELSE

         EXIT

      ENDIF

   ENDDO .T.

RETURN // LL_UseTable()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE VGridRefresh( ;
      cWindName, ;
      cGridName )

   LOCAL nGrdValue, ;
      nGrdItmCo := GetProperty( cWindName, cGridName, "ItemCount" )

   FOR nGrdValue := 1 TO nGrdItmCo
      SetProperty( cWindName, cGridName, "Value", nGrdValue )
   NEXT nGrdValue

   SetProperty( cWindName, cGridName, "Value", 1 )

RETURN // VGridRefresh()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE VGridAddItem( ;
      aGridItems )

   IF This.QueryRowIndex <= Len( aGridItems )

      This.QueryData := aGridItems[ This.QueryRowIndex, This.QueryColIndex ]

   ENDIF

RETURN // VGridAddItem()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE LL_SKIP( nSkip ) // Low-level skip

   LOCAL nTblRecCnt // Record Count
   LOCAL nCurrRRN := 0 // Current Relative Record Number

   DO CASE

   CASE nSkip == 1 // Go Top
      nFilePointr := FSeek( nFileHandle, nTblHdrLeng, 0 )
   CASE nSkip == 2 // Go Prev
      nFilePointr := FSeek( nFileHandle, nFilePointr - nTblRecLeng, 0 )
   CASE nSkip == 3 // Go Next
      nFilePointr := FSeek( nFileHandle, nFilePointr + nTblRecLeng, 0 )
   CASE nSkip == 4 // Go Bottom
      nFilePointr := FSeek( nFileHandle, nTblRecLeng, 2 )

   END CASE // nSkip

   nFilePointr := Max( Min( nFilePointr, nFileLength - nTblRecLeng - 1 ), nTblHdrLeng )

   FSeek( nFileHandle, nFilePointr, 0 )

   IF nFilePointr > 0

      nTblRecCnt := aTblInfo[ 3, 1, 2, 5, 2 ]

      IF nTblRecCnt > 0

         nCurrRRN := Round( ( nFilePointr - nTblHdrLeng ) / nTblRecLeng, 0 ) + 1

         LL_DispReco()

      ENDIF

   ENDIF

   frmLLDBUMain.STATUSBAR.Item( 2 ) := PadC( hb_ntos( nCurrRRN ), 8 ) // nCurrRRN

RETURN // LL_SKIP( nSkip )

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE LL_DispReco()

   LOCAL cRecStr := Space( nTblRecLeng ), ;
      nRBytes

   LOCAL aClTblStru := { { '', '<Deleted>', '', 1, 0 } }

   LOCAL nFldNum, ;
      nFldPos := 1, ;
      nFldLen, ;
      cFldDat, ;
      aRecDat := {}

   AEval( aTableStru, {| a1 | AAdd( aClTblStru, a1 ) } )

   nRBytes := FRead( nFileHandle, @cRecStr, nTblRecLeng )

   IF nRBytes # nTblRecLeng
      MsgAlert( "Low level file read error", "Alert" )
   ELSE
      FOR nFldNum := 1 TO Len( aClTblStru )
         nFldLen := aClTblStru[ nFldNum, 4 ]
         cFldDat := SubStr( cRecStr, nFldPos, nFldLen )
         IF HL_IsIncCtrl( cFldDat )
            cFldDat := '0x' + FT_BYT2HEX( cFldDat ) + '( ' + cFldDat + ' )'
         ENDIF
         AAdd( aRecDat, cFldDat )
         nFldPos += nFldLen
      NEXT nFldNum

      AEval( aRecDat, {| c1, i1 | aRecoData[ i1, 2 ] := c1 } )

      VGridRefresh( "frmLLDBUMain", "grdTblData" )

   ENDIF

RETURN // LL_DispReco()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION MsgAbout()

RETURN MsgInfo( ;
      "Not a real DBU, only an experimental work with very limited DB operations." + CRLF + CRLF + ;
      "Primary goal of this project is access, detect, inspect and dig a damaged table." + CRLF + CRLF + ;
      "Reasons of damage may be various, so recovery method too depend on a damage type." + CRLF + CRLF + ;
      "This program open a table by Low Level file access and read methods." + CRLF + CRLF + ;
      "A second usage may be inspecting how data recorded into a table; always in the visible form or not." + CRLF + CRLF + ;
      "I hope that my friends find useful this humble work." + CRLF + CRLF + ;
      "Happy HMG'ing :D" + CRLF + CRLF + ;
      "Bicahi Esgici", "About Low Level DBU" )

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

#define HEXTABLE "0123456789ABCDEF"

FUNCTION HEX2DEC( cHexNum )

   LOCAL n, nDec := 0, nHexPower := 1

   FOR n := Len( cHexNum ) TO 1 STEP -1
      nDec += ( At( SUBS( Upper(cHexNum ), n, 1 ), HEXTABLE ) - 1 ) * nHexPower
      nHexPower *= 16
   NEXT n

RETURN nDec

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION FT_BYT2HEX( cByte )

   LOCAL xHexString := ""

   IF ValType( cByte ) == "C"
      xHexString += SubStr( HEXTABLE, Int( Asc( cByte ) / 16 ) + 1, 1 ) ;
         +SubStr( HEXTABLE, Int( Asc( cByte ) % 16 ) + 1, 1 )
   ENDIF

RETURN xHexString

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION HL_IsIncCtrl( cByte )

   LOCAL z, x
   LOCAL lRet := .F.

   FOR x := 1 TO Len( cByte )
      z := SubStr( cByte, x, 1 )
      If !( IsDigit( z ) .OR. z == '.' .OR. IsAlpha( z ) .OR. z == ' ' .OR. z == '!' .OR. z == '?' .OR. z == '-' .OR. z == '*' )
         lRet := .T.
         EXIT
      ENDIF
   NEXT x

RETURN lRet

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION HL_FldTypC2V( field_type )

   LOCAL cType := "Unknown"
   LOCAL data_type[ 5 ], ;
      n

   // data types as character strings
   data_type[ 1 ] := "Character"
   data_type[ 2 ] := "Numeric"
   data_type[ 3 ] := "Date"
   data_type[ 4 ] := "Logical"
   data_type[ 5 ] := "Memo"

   IF ( n := At( field_type, "CNDLM" ) ) > 0
      cType := data_type[ n ]
   ENDIF

RETURN cType

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION HL_TablTypeNam( ntype )

   LOCAL cString := ""

   SWITCH ntype
   CASE 1 // 02
      cString := "FoxBASE"
      EXIT
   CASE 2 // 03
      cString := "dBASE III+ or FoxBASE+, no memo"
      EXIT
   CASE 3 // 30
      cString := "Visual FoxPro"
      EXIT
   CASE 4 // 31
      cString := "Visual FoxPro, autoincrement"
      EXIT
   CASE 5 // 32
      cString := "Visual FoxPro, fields VarChar, VarBinary or Blob"
      EXIT
   CASE 6 // 43
      cString := "dBASE IV SQL tables, no memo"
      EXIT
   CASE 7 // 63
      cString := "dBASE IV SQL system, no memo"
      EXIT
   CASE 8 // 83
      cString := "dBASE III+ or FoxBASE+ with memo"
      EXIT
   CASE 9 // 8B
      cString := "dBASE IV, with memo"
      EXIT
   CASE 10 // CB
      cString := "dBASE IV SQL tables with memo"
      EXIT
   CASE 11 // E5
      cString := "SMT"
      EXIT
   CASE 12 // EB
      cString := "dBASE IV SQL system with memo"
      EXIT
   CASE 13 // F5
      cString := "FoxPro 2.x (or earlier) with memo"
      EXIT
   CASE 14 // FB
      cString := "FoxBASE with memo"

   ENDSWITCH

RETURN cString

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION GetTableNum( ctype )

   LOCAL nRet := 0

   SWITCH ctype
   CASE '02'
      nRet := 1
      EXIT
   CASE '03'
      nRet := 2
      EXIT
   CASE '30'
      nRet := 3
      EXIT
   CASE '31'
      nRet := 4
      EXIT
   CASE '32'
      nRet := 5
      EXIT
   CASE '43'
      nRet := 6
      EXIT
   CASE '63'
      nRet := 7
      EXIT
   CASE '83'
      nRet := 8
      EXIT
   CASE '8B'
      nRet := 9
      EXIT
   CASE 'CB'
      nRet := 10
      EXIT
   CASE 'E5'
      nRet := 11
      EXIT
   CASE 'EB'
      nRet := 12
      EXIT
   CASE 'F5'
      nRet := 13
      EXIT
   CASE 'FB'
      nRet := 14

   ENDSWITCH

RETURN nRet

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

#define FIELD_ENTRY_SIZE 32
#define FIELD_NAME_SIZE  11

FUNCTION HL_DBInfoLL( cTable, lMessage )

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
   LOCAL aInfo

   aInfo := Array( 3 )
   aInfo[ 3 ] := Array( 2 )
   aInfo[ 3 ][ 1 ] := Array( 2 )
   aInfo[ 3 ][ 1 ][ 2 ] := Array( 7, 2 )

   aInfo[ 1 ] := 0
   aInfo[ 2 ] := 0

   IF .NOT. '.DBF' $ Upper( cTable )
      cTable += '.DBF'
   ENDIF

   IF ( nHandle := FOpen( cTable, FO_READ ) ) == -1
      IF lMessage
         MsgStop( 'Can not open file ' + cTable + ' for reading!' )
      ENDIF
      RETURN aInfo
   ENDIF

   dbfhead := Space( 4 )
   FRead( nHandle, @dbfhead, 4 )

   h1 := FT_BYT2HEX( SubStr( dbfhead, 1, 1 ) ) // must be 03h or F5h if .fpt exists
   dbftype := h1
   h2 := FT_BYT2HEX( SubStr( dbfhead, 2, 1 ) ) // yy hex (between 00h and FFh) added to 1900 (decimal)
   h3 := FT_BYT2HEX( SubStr( dbfhead, 3, 1 ) ) // mm hex (between 01h and 0Ch)
   h4 := FT_BYT2HEX( SubStr( dbfhead, 4, 1 ) ) // dd hex (between 01h and 1Fh)

   aInfo[ 1 ] := GetTableNum( dbftype )
   aInfo[ 2 ] := nHandle

   IF aInfo[ 1 ] == 0
      IF lMessage
         MsgStop( 'Can not detect type of file ' + cTable )
      ENDIF
      FClose( nHandle )
      RETURN aInfo
   ENDIF

   aInfo[ 3 ][ 1 ][ 2 ][ 1 ][ 1 ] := 'Full File Name'
   aInfo[ 3 ][ 1 ][ 2 ][ 1 ][ 2 ] := cTable

   aInfo[ 3 ][ 1 ][ 2 ][ 2 ][ 1 ] := 'Last update (DD.MM.YY)'
   aInfo[ 3 ][ 1 ][ 2 ][ 2 ][ 2 ] := StrZero( hex2dec( h4 ), 2 ) + '.' + StrZero( hex2dec( h3 ), 2 ) + '.' + StrZero( hex2dec( h2 ) - if( hex2dec( h2 ) > 100, 100, 0 ), 2 )

   headrecs := Space( 4 ) // number of records in file
   FSeek( nHandle, 4, FS_SET )
   FRead( nHandle, @headrecs, 4 )

   h1 := FT_BYT2HEX( SubStr( headrecs, 1, 1 ) )
   h2 := FT_BYT2HEX( SubStr( headrecs, 2, 1 ) )
   h3 := FT_BYT2HEX( SubStr( headrecs, 3, 1 ) )
   h4 := FT_BYT2HEX( SubStr( headrecs, 4, 1 ) )
   headrecs := Int( hex2dec( h1 ) + 256 * hex2dec( h2 ) + ( 256 ** 2 ) * hex2dec( h3 ) + ( 256 ** 3 ) * hex2dec( h4 ) )

   aInfo[ 3 ][ 1 ][ 2 ][ 5 ][ 1 ] := 'Record Count'
   aInfo[ 3 ][ 1 ][ 2 ][ 5 ][ 2 ] := headrecs

   headsize := Space( 2 )
   FRead( nHandle, @headsize, 2 )

   h1 := FT_BYT2HEX( SubStr( headsize, 1, 1 ) )
   h2 := FT_BYT2HEX( SubStr( headsize, 2, 1 ) )
   headsize := hex2dec( h1 ) + 256 * hex2dec( h2 ) // header size

   aInfo[ 3 ][ 1 ][ 2 ][ 3 ][ 1 ] := 'Header Length'
   aInfo[ 3 ][ 1 ][ 2 ][ 3 ][ 2 ] := headsize

   recsize := Space( 2 )
   FRead( nHandle, @recsize, 2 )

   h1 := FT_BYT2HEX( SubStr( recsize, 1, 1 ) )
   h2 := FT_BYT2HEX( SubStr( recsize, 2, 1 ) )
   recsize := hex2dec( h1 ) + 256 * hex2dec( h2 ) // record size

   aInfo[ 3 ][ 1 ][ 2 ][ 4 ][ 1 ] := 'Record Length'
   aInfo[ 3 ][ 1 ][ 2 ][ 4 ][ 2 ] := recsize

   nof := Int( headsize / 32 ) - 1 // number of fields

   aInfo[ 3 ][ 1 ][ 2 ][ 6 ][ 1 ] := 'Fields Count'
   aInfo[ 3 ][ 1 ][ 2 ][ 6 ][ 2 ] := nof

   aInfo[ 3 ][ 1 ][ 2 ][ 7 ][ 1 ] := 'File Size'
   aInfo[ 3 ][ 1 ][ 2 ][ 7 ][ 2 ] := recsize * headrecs + headsize + 1

   // Fields Structure
   fieldlist := {}
   FOR nField = 1 TO nof
      nPos := nField * FIELD_ENTRY_SIZE
      FSeek( nHandle, nPos, FS_SET ) // Goto File Offset of the nField-th Field
      cFieldName := Space( FIELD_NAME_SIZE )
      FRead( nHandle, @cFieldName, FIELD_NAME_SIZE )
      cFieldName := StrTran( cFieldName, Chr( 0 ), ' ' )
      cFieldName := RTrim( SubStr( cFieldName, 1, At( ' ', cFieldName ) ) )

      cType := Space( 1 )
      FRead( nHandle, @cTYPE, 1 )

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

   aInfo[ 3 ][ 2 ] := Array( 2 )
   aInfo[ 3 ][ 2 ][ 2 ] := fieldlist

RETURN aInfo
