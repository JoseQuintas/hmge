*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\TOKEN.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function numtoken()
*+               Function token()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"

*+--------------------------------------------------------------------
*+
*+    Function numtoken()
*+
*+    Called from ( click.prg )   1 - function lineparse()
*+                ( filnpath.prg )   1 - function fileinpath()
*+                ( functrak.prg )   2 - procedure init_func_text()
*+                ( libread.prg )   1 - procedure libread()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION numtoken( cString, cDelimiter )

   // This is used to get a count of how many tokens are in a string based
   // on the supplied delimiter. This defaults to the same delimiters as
   // used in the like named function in Clipper Tools III, so it should
   // work identically.

LOCAL x
LOCAL nStrLen    := LEN( cString )
LOCAL nHowMany   := 0
LOCAL lFoundWord := .f.
LOCAL retval     := 0

   DEFAULT cDelimiter TO ' ,.;:!?/\<>()^#&%+-*' + CHR( 0 ) + CHR( 9 ) + ;
           CHR( 10 ) + CHR( 13 ) + ;
           CHR( 26 ) + CHR( 138 ) + ;
           CHR( 141 )

   FOR x := 1 TO nStrLen
      IF SUBSTR( cString, x, 1 ) $ cDelimiter
         IF lFoundWord
            nHowMany ++
         ENDIF
         DO WHILE x < nStrLen .AND. SUBSTR( cString, x + 1, 1 ) $ cDelimiter
            x ++
         ENDDO
      ELSE
         lFoundWord := .t.
      ENDIF
   NEXT

   IF nStrLen > 0
      retval := IIF( RIGHT( cString, 1 ) $ cDelimiter, nHowmany, nHowMany + 1 )
   ENDIF

RETURN retval

*+--------------------------------------------------------------------
*+
*+    Function token()
*+
*+    Called from ( click.prg )   1 - function lineparse()
*+                ( filnpath.prg )   1 - function fileinpath()
*+                ( functrak.prg )   2 - procedure init_func_text()
*+                ( libread.prg )   1 - procedure libread()
*+                ( readlnk.prg )   2 - function readlnk()
*+
*+--------------------------------------------------------------------
*+
FUNCTION token( cString, cDelimiter, nPointer )

   // This is used to extract each token from the string based on the
   // delimiter and the numeric pointer which tells us which token to
   // return.

   // This defaults to the same delimiters as used in the like named
   // function in Clipper Tools III, so it should work identically.
LOCAL x
LOCAL nStrLen      := LEN( cString )
LOCAL nHowMany     := 0
LOCAL nLastPointer := 0
LOCAL cPart
LOCAL lFoundWord   := .f.

   DEFAULT cDelimiter TO ' ,.;:!?/\<>()^#&%+-*' + CHR( 0 ) + CHR( 9 ) + ;
           CHR( 10 ) + CHR( 13 ) + ;
           CHR( 26 ) + CHR( 138 ) + ;
           CHR( 141 )

   FOR x := 1 TO nStrLen
      IF SUBSTR( cString, x, 1 ) $ cDelimiter
         IF lFoundWord
            nHowMany ++
         ENDIF
         IF nHowMany == nPointer
            EXIT
         ENDIF
         DO WHILE x < nStrLen .AND. SUBSTR( cString, x + 1, 1 ) $ cDelimiter
            x ++
         ENDDO
         nLastPointer := x
      ELSE
         lFoundWord := .t.
      ENDIF
   NEXT

   // went all the way without nHowmany == nPointer
   IF x == nStrLen + 1
      // take the last word
      cPart := SUBSTR( cString, nLastPointer + 1 )
   ELSE
      cPart := SUBSTR( cString, nLastPointer + 1, ( x - nLastPointer ) - 1 )
   ENDIF

RETURN cPart

*+ EOF: TOKEN.PRG
