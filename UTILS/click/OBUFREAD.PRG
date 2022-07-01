*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\OBUFREAD.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function BInit()
*+               Function Bopen()
*+               Function BReadLine()
*+               Function BNextLine()
*+               Static Function BDisk2Buff()
*+               Function BEof()
*+               Function BClose()
*+               Function BPosition()
*+               Function BRelative()
*+               Function BLineNumber()
*+               Function BGetSet()
*+               Function BRestSet()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "FILEIO.CH"
#include "COMMON.CH"

#define cFileName oBuffObj[ 1 ]
#define nAccMode oBuffObj[ 2 ]
#define cLineBuffer oBuffObj[ 3 ]
#define nHandle oBuffObj[ 4 ]
#define nBytesRead oBuffObj[ 5 ]
#define lFullBuff oBuffObj[ 6 ]
#define nTotBytes oBuffObj[ 7 ]
#define lIsOpen oBuffObj[ 8 ]
#define nFileBytes oBuffObj[ 9 ]
#define nFileLines oBuffObj[ 10 ]
#define cDelimiter oBuffObj[ 11 ]

#define BUFFLEN 2560

*+--------------------------------------------------------------------
*+
*+    Function BInit()
*+
*+    Called from ( click.prg )   4 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - function func_text()
*+                ( profile.prg )   1 - static function init_profile()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BInit( xFileName, xAccMode )

   // Function BInit( <cFileName>, [nAccessMode] )
   // Return:  oBuffObj for this file access

RETURN { xFileName, xAccMode, '', - 1, 0, .t., 0, .t., 0, 0, CHR( 13 ) + CHR( 10 ) }

*+--------------------------------------------------------------------
*+
*+    Function Bopen()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - function func_text()
*+                ( profile.prg )   1 - static function init_profile()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION Bopen( oBuffObj )

   // Return:   .t. if file was opened
   // Assumes:  All file access will be done with the B* functions

   DEFAULT nAccMode TO FO_READ                                        // default access mode is Read Only

   nHandle := FOPEN( cFileName, nAccMode )

   nFileBytes := FSEEK( nHandle, 0, FS_END )

   FSEEK( nHandle, 0, FS_SET )

   BDisk2Buff( oBuffObj )

   DO CASE
      CASE CHR( 13 ) + CHR( 10 ) $ cLineBuffer
         cDelimiter := CHR( 13 ) + CHR( 10 )
      CASE CHR( 13 ) $ cLineBuffer
         cDelimiter := CHR( 13 )
      CASE CHR( 10 ) $ cLineBuffer
         cDelimiter := CHR( 10 )
   ENDCASE

RETURN ( nHandle != - 1 )

*+--------------------------------------------------------------------
*+
*+    Function BReadLine()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+                                   1 - static function breadpart()
*+                                   3 - static procedure thealigner()
*+                ( declbust.prg )   4 - procedure declbust()
*+                ( functrak.prg )   1 - function func_text()
*+                ( profile.prg )   1 - static function init_profile()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BReadLine( oBuffObj )

   // Return:   The next line of the file read buffer
   // Assumes:  The file pointer will be moved forward
LOCAL ThisLine
LOCAL nCrLfAt

   DO WHILE .t.

      nCrLfAt := AT( cDelimiter, cLineBuffer )

      IF EMPTY( nCrLfAt ) .AND. lFullBuff
         BDisk2Buff( oBuffObj )
         LOOP
      ENDIF

      IF EMPTY( nCrLfAt )
         ThisLine := STRTRAN( cLineBuffer, CHR( 26 ) )
         cLineBuffer := ''
      ELSE
         ThisLine := LEFT( cLineBuffer, nCrLfAt - 1 )
         cLineBuffer := SUBSTR( cLineBuffer, nCrLfAt + LEN( cDelimiter ) )
      ENDIF

      EXIT

   ENDDO

   nFileLines ++

RETURN ThisLine

*+--------------------------------------------------------------------
*+
*+    Function BNextLine()
*+
*+    Called from ( click.prg )   4 - static procedure thealigner()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BNextLine( oBuffObj )

   // Return:   The next line of the file read buffer
   // Assumes:  The file pointer will be left as last positioned
LOCAL NextLine
LOCAL nCrLfAt

   DEFAULT cDelimiter TO CHR( 13 ) + CHR( 10 )

   DO WHILE .t.

      nCrLfAt := AT( cDelimiter, cLineBuffer )

      IF EMPTY( nCrLfAt ) .AND. lFullBuff
         BDisk2Buff( oBuffObj )
         LOOP
      ENDIF

      IF EMPTY( nCrLfAt )
         NextLine := STRTRAN( cLineBuffer, CHR( 26 ) )
      ELSE
         NextLine := LEFT( cLineBuffer, nCrLfAt - 1 )
      ENDIF

      EXIT

   ENDDO

RETURN NextLine

*+--------------------------------------------------------------------
*+
*+    Static Function BDisk2Buff()
*+
*+    Called from ( obufread.prg )   1 - function bopen()
*+                                   1 - function breadline()
*+                                   1 - function bnextline()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION BDisk2Buff( oBuffObj )

   // Return:   .t. if there was no read error
STATIC cDiskBuffer := ''

   IF LEN( cDiskBuffer ) != BUFFLEN
      cDiskBuffer := SPACE( BUFFLEN )
   ENDIF

   nBytesRead := FREAD( nHandle, @cDiskBuffer, BUFFLEN )

   nTotBytes += nBytesRead

   lFullBuff := ( nBytesRead == BUFFLEN )

   IF lFullBuff
      cLineBuffer += cDiskBuffer
   ELSE
      cLineBuffer += LEFT( cDiskBuffer, nBytesRead )
   ENDIF

RETURN FERROR()

*+--------------------------------------------------------------------
*+
*+    Function BEof()
*+
*+    Called from ( click.prg )   3 - static procedure startclick()
*+                                   2 - static function breadpart()
*+                                   2 - static procedure thealigner()
*+                ( declbust.prg )   2 - procedure declbust()
*+                ( functrak.prg )   1 - function func_text()
*+                ( profile.prg )   1 - static function init_profile()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BEof( oBuffObj )

   // Return:   TRUE  if End of buffered file
   //           FALSE if not
RETURN !lFullBuff .AND. LEN( cLineBuffer ) == 0

*+--------------------------------------------------------------------
*+
*+    Function BClose()
*+
*+    Called from ( click.prg )   3 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - function func_text()
*+                ( profile.prg )   1 - static function init_profile()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BClose( oBuffObj )

   IF lIsOpen
      FCLOSE( nHandle )
      lIsOpen := .f.
   ENDIF

   oBuffObj := nil

RETURN FERROR()

*+--------------------------------------------------------------------
*+
*+    Function BPosition()
*+
*+    Called from ( obufread.prg )   1 - function brelative()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BPosition( oBuffObj )

   // Returns the position of virtual file pointer
RETURN nTotBytes - LEN( cLineBuffer )

*+--------------------------------------------------------------------
*+
*+    Function BRelative()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                                   1 - static function breadpart()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - function func_text()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BRelative( oBuffObj )

   // Returns the percentage of file processed
RETURN BPosition( oBuffObj ) / nFileBytes

*+--------------------------------------------------------------------
*+
*+    Function BLineNumber()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BLineNumber( oBuffObj )

   // Returns the current line number
RETURN nFileLines

*+--------------------------------------------------------------------
*+
*+    Function BGetSet()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BGetSet( oBuffObj )

RETURN ACLONE( oBuffObj )

*+--------------------------------------------------------------------
*+
*+    Function BRestSet()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION BRestSet( oBuffObj )

   FSEEK( nHandle, nTotBytes, FS_SET )

RETURN oBuffObj

*+ EOF: OBUFREAD.PRG
