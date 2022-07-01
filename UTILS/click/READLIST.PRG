*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\READLIST.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function readlist()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"

*+--------------------------------------------------------------------
*+
*+    Function readlist()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                ( cmd_list.prg )   3 - function init_list()
*+                ( libread.prg )   1 - procedure libread()
*+
*+--------------------------------------------------------------------
*+
FUNCTION readlist( inifile, category )

   // This reads in a list from disk from an .INI file section and returns
   // it as an array. If you pass in a @ as the category, it reads the
   // entire file into an array. This is buffered for speed and assumes
   // that the .INI text file is less than 32k
LOCAL retarry   := {}
LOCAL cThisLine
LOCAL ini_data  := MEMOREAD( inifile )
LOCAL nPointer
LOCAL CRLF      := CHR( 13 ) + CHR( 10 )
LOCAL lCatFound

   BEGIN SEQUENCE

      category := '[' + UPPER( ALLTRIM( category ) ) + ']'

      lCatFound := category == '[@]'

      IF !lCatFound
         nPointer := AT( category, ini_data )
         IF nPointer > 0
            ini_data := SUBSTR( ini_data, nPointer )
            nPointer := AT( CRLF, ini_data )
            cThisLine := LEFT( ini_data, nPointer - 1 )
            ini_data := SUBSTR( ini_data, nPointer + 2 )
         ELSE
            BREAK
         ENDIF
      ENDIF

      DO WHILE LEN( ini_data ) > 0

         nPointer := AT( CRLF, ini_data )

         IF nPointer > 0
            cThisLine := LEFT( ini_data, nPointer - 1 )
            ini_data := SUBSTR( ini_data, nPointer + 2 )
         ELSE
            cThisLine := ini_data
            ini_data := ''
         ENDIF

         IF EMPTY( cThisLine ) .OR. LEFT( LTRIM( cThisLine ), 2 ) == '//'
            LOOP
         ENDIF

         IF LEFT( cThisLine, 1 ) == '['
            EXIT
         ELSE
            AADD( retarry, cThisLine )
         ENDIF

      ENDDO

   END SEQUENCE

RETURN retarry

*+ EOF: READLIST.PRG
