*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\ERR_LOG.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Procedure err_log()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "FILEIO.CH"

*+--------------------------------------------------------------------
*+
*+    Procedure err_log()
*+
*+    Called from ( click.prg )  22 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE err_log( cTheFile, cTheError )

LOCAL nHandle

   // writes text to the output file and creates the file if it is missing,
   // otherwise appends to the existing file.

   IF FILE( cTheFile )
      nHandle := FOPEN( cTheFile, 2 )
      FSEEK( nHandle, 0, FS_END )
   ELSE
      nHandle := FCREATE( cTheFile, 0 )
   ENDIF

   IF nHandle > - 1
      FWRITE( nHandle, cTheError + CHR( 13 ) + CHR( 10 ) )
      FCLOSE( nHandle )
   ENDIF

RETURN

*+ EOF: ERR_LOG.PRG
