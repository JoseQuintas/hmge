*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\PROFILE.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function ProfileString()
*+               Function ProfileNum()
*+               Static Function init_profile()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"

STATIC INI_DATA := {}
STATIC INI_NAME := ''

*+--------------------------------------------------------------------
*+
*+    Function ProfileString()
*+
*+    Called from ( click.prg )  39 - static procedure startclick()
*+                                   2 - static procedure thealigner()
*+                ( declbust.prg )   3 - procedure declbust()
*+                ( functrak.prg )   2 - procedure init_func_text()
*+                                  10 - function func_text()
*+                ( libread.prg )   1 - procedure libread()
*+                ( obufwrit.prg )   1 - function bo_init()
*+                ( profile.prg )   1 - function profilenum()
*+
*+--------------------------------------------------------------------
*+
FUNCTION ProfileString( cFile, cSection, cKey, cDefault )

   //
   //  This function reads a string from the specified .INI file.
   //
   //  Parameters: cFile    - The .INI file name to be used
   //              cSection - The section from which to read
   //              cKey     - The key value for which to search
   //              cDefault - The default value if not found (optional)
   //
   //     Returns: cString - The string read from the file.
   //
LOCAL nSPointer := 0
LOCAL nKPointer := 0
LOCAL cString

   DEFAULT cDefault TO ''
   cString := cDefault

   BEGIN SEQUENCE

      IF INI_NAME <> cFile
         IF !init_profile( cFile )
            BREAK
         ENDIF
      ENDIF

      cSection := UPPER( ALLTRIM( cSection ) )
      cKey := UPPER( ALLTRIM( cKey ) )

      IF LEFT( cSection, 1 ) <> '['
         cSection := '[' + cSection
      ENDIF

      IF RIGHT( cSection, 1 ) <> ']'
         cSection += ']'
      ENDIF

      nSPointer := ASCAN( INI_DATA, { | x | x[ 1 ] == cSection } )

      IF !EMPTY( nSPointer )
         nKPointer := ASCAN( INI_DATA[ nSPointer, 2 ], { | x | x[ 1 ] == cKey } )
         IF !EMPTY( nKPointer )
            cString := INI_DATA[ nSPointer, 2, nKPointer, 2 ]
         ENDIF
      ENDIF

   END SEQUENCE

RETURN cString

*+--------------------------------------------------------------------
*+
*+    Function ProfileNum()
*+
*+    Called from ( click.prg )  11 - static procedure startclick()
*+                ( libread.prg )   1 - procedure libread()
*+
*+--------------------------------------------------------------------
*+
FUNCTION ProfileNum( cFile, cSection, cKey, nDefault )

   //
   //  This function reads a number from the specified .INI file.
   //
   //  Parameters: cFile    - The .INI file name to be used
   //              cSection - The section from which to read
   //              cKey     - The key value for which to search
   //              nDefault - The default value if not found (optional)
   //
   //     Returns: nValue - The numeric value read from the file.
   //
LOCAL retval

   DEFAULT nDefault TO 0
   retval := nDefault

   BEGIN SEQUENCE

      IF INI_NAME <> cFile
         IF !init_profile( cFile )
            BREAK
         ENDIF
      ENDIF

      retval := ProfileString( cFile, cSection, cKey, '' )

      IF EMPTY( retval )
         retval := nDefault
      ELSE
         retval := VAL( retval )
      ENDIF

   END SEQUENCE

RETURN retval

*+--------------------------------------------------------------------
*+
*+    Static Function init_profile()
*+
*+    Called from ( profile.prg )   1 - function profilestring()
*+                                   1 - function profilenum()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION init_profile( cFile )

LOCAL oBufObj       := bInit( cFile )
LOCAL retval        := bopen( oBufObj )
LOCAL cThisLine
LOCAL lFoundSection := .f.
LOCAL nLastElement  := 0
LOCAL eqat

   INI_DATA := {}
   INI_NAME := ''

   IF retval
      INI_NAME := cFile
      DO WHILE !bEof( oBufObj )

         cThisLine := ALLTRIM( bReadLine( oBufObj ) )

         IF EMPTY( cThisLine ) .OR. LEFT( cThisLine, 2 ) == '//'
            LOOP
         ENDIF

         IF !lFoundSection
            IF LEFT( cThisLine, 1 ) == '[' .AND. RIGHT( cThisLine, 1 ) == ']'
               lFoundSection := .t.
            ELSE
               LOOP
            ENDIF
         ENDIF

         IF LEFT( cThisLine, 1 ) == '[' .AND. RIGHT( cThisLine, 1 ) == ']'
            AADD( INI_DATA, { UPPER( cThisLine ), {} } )
            nLastElement ++
         ELSE
            eqat := AT( '=', cThisLine )
            IF eqat > 0
               AADD( INI_DATA[ nLastElement, 2 ], ;
                     { UPPER( ALLTRIM( LEFT( cThisLine, eqat - 1 ) ) ), ;
                     SUBSTR( cThisLine, eqat + 1 ) } )
            ENDIF
         ENDIF
      ENDDO
      bClose( oBufObj )
   ENDIF

RETURN retval

*+ EOF: PROFILE.PRG
