*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\FILNPATH.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function fileinpath()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"

*+--------------------------------------------------------------------
*+
*+    Function fileinpath()
*+
*+    Called from ( functrak.prg )   1 - function func_text()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION fileinpath( filename, cEnviron )

LOCAL cDir
LOCAL foundit := .f.
LOCAL cPath
LOCAL x       := 1                                                    // Initialise x
LOCAL y

   // Modifications by Peter Townsend, 12/13/1998

   // This will return the full path of a file name if it is in the environment
   // you may specify the environment variable to other than the default
   // of PATH, so you can get LIB, OBJ, or any other pathlist.

   DEFAULT cEnviron TO 'PATH'

   cPath := GETENV( UPPER( cEnviron ) )
   y := numtoken( cPath, ';' )

   // Change FOR to DO WHILE
   DO WHILE ( !foundit ) .AND. ( x <= y )
      cDir := ALLTRIM( token( cPath, ';', x ) )
      cDir += IIF( RIGHT( cDir, 1 ) <> '\', '\', '' )
      foundit := FILE( cDir + filename )
      x ++                                                            // Increment x
   ENDDO                                                              // Change NEXT to ENDDO

RETURN IF( foundit, cDir + filename, filename )

*+ EOF: FILNPATH.PRG
