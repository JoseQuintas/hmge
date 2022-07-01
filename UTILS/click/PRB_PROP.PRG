*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\PRB_PROP.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function proper()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

*+--------------------------------------------------------------------
*+
*+    Function proper()
*+
*+    Called from ( click.prg )   4 - function lineparse()
*+
*+--------------------------------------------------------------------
*+
FUNCTION proper( cString )

   // Syntax: PROPER ( <expC> )
   // Return: capitalizes first letter of each word, all other go to lower case
LOCAL nSrcLen   := LEN( cString )
LOCAL x
LOCAL lSepFlag  := .t.
LOCAL cThisChar
LOCAL lFound

   cString := LOWER( cString )

   FOR x := 1 TO nSrcLen
      cThisChar := SUBSTR( cString, x, 1 )
      lFound := cThisChar $ "abcdefghijklmnopqrstuvwxyz0123456789'"
      IF lFound .AND. lSepFlag
         cString := STUFF( cString, x, 1, UPPER( cThisChar ) )
      ENDIF
      lSepFlag := !lFound
   NEXT

RETURN cString

*+ EOF: PRB_PROP.PRG
