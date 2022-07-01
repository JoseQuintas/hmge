*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\OBUFWRIT.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function bo_init()
*+               Function bo_open()
*+               Procedure bo_write()
*+               Procedure bo_writeNoDupe()
*+               Procedure bo_close()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "FILEIO.CH"
#include "COMMON.CH"

#define cFileName oObjData[ 1 ]
#define nAccMode oObjData[ 2 ]
#define cOutBuffer oObjData[ 3 ]
#define cOutBufLen oObjData[ 4 ]
#define nHandle oObjData[ 5 ]
#define lLastWasEmpty oObjData[ 6 ]
#define lRemoveDups oObjData[ 7 ]

#define BUFFLEN 2560

#define CRLF chr( 13 ) + chr( 10 )

// This is a buffered write (output) routine that keeps the disk from
// thrashing on a bunch of little writes. This speeds up output
// dramatically.

*+--------------------------------------------------------------------
*+
*+    Function bo_init()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   4 - function func_text()
*+
*+--------------------------------------------------------------------
*+
FUNCTION bo_init( xFileName, xAccMode )

LOCAL cFullPath := IF( FILE( 'CLICK.INI' ), 'CLICK', RootName( ft_origin() ) ) + '.INI'

   DEFAULT xAccMode TO FO_WRITE

RETURN { xFileName, ;
         xAccMode, ;
         '', ;
         0, ;
         - 1, ;
         .f., ;
         ProfileString( cFullPath, 'CLICK', 'REMOVE_DUPLICATE_EMPTY_LINES', 'YES' ) == 'YES' ;
         }

*+--------------------------------------------------------------------
*+
*+    Function bo_open()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   4 - function func_text()
*+
*+--------------------------------------------------------------------
*+
FUNCTION bo_open( oObjData )

   BEGIN SEQUENCE

      IF !FILE( cFileName )
         nHandle := FCREATE( cFileName, FC_NORMAL )
         IF nHandle == - 1
            BREAK
         ENDIF
         FCLOSE( nHandle )
      ENDIF

      nHandle := FOPEN( cFileName, nAccMode )

      FSEEK( nHandle, 0, FS_END )

   END SEQUENCE

RETURN nHandle # - 1

*+--------------------------------------------------------------------
*+
*+    Procedure bo_write()
*+
*+    Called from ( click.prg )  22 - static procedure startclick()
*+                                   2 - static function breadpart()
*+                ( declbust.prg )  15 - procedure declbust()
*+                ( functrak.prg )  42 - function func_text()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE bo_write( oObjData, cSomeText )

   cOutBufLen += LEN( cSomeText )

   cOutBuffer += cSomeText

   IF cOutBufLen > BUFFLEN
      FWRITE( nHandle, cOutBuffer )
      cOutBuffer := ''
      cOutBufLen := 0
   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure bo_writeNoDupe()
*+
*+    Called from ( click.prg )  17 - static procedure thealigner()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE bo_writeNoDupe( oObjData, cSomeText )

   IF !lRemoveDups .OR. cSomeText <> CRLF .OR. ( cSomeText == CRLF .AND. !lLastWasEmpty )

      cOutBufLen += LEN( cSomeText )

      cOutBuffer += cSomeText

      IF cOutBufLen > BUFFLEN
         FWRITE( nHandle, cOutBuffer )
         cOutBuffer := ''
         cOutBufLen := 0
      ENDIF

   ENDIF

   lLastWasEmpty := ( cSomeText == CRLF )

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure bo_close()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   4 - function func_text()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE bo_close( oObjData )

   FWRITE( nHandle, cOutBuffer )

   FCLOSE( nHandle )

RETURN

*+ EOF: OBUFWRIT.PRG
