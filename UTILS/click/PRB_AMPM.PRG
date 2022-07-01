*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\PRB_AMPM.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function AM_PM()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"

*+--------------------------------------------------------------------
*+
*+    Function AM_PM()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                ( functrak.prg )   3 - function func_text()
*+
*+--------------------------------------------------------------------
*+
FUNCTION AM_PM( cTime, lShowSecs )

   // my own ampm function with defaults
LOCAL nHour
LOCAL cAmPm := ' am'

   DEFAULT lShowSecs TO .f.
   DEFAULT cTime TO TIME()

   nHour := VAL( LEFT( cTime, 2 ) )

   IF nHour > 11
      cAmPm := ' pm'
      nHour -= 12
   ENDIF

   IF nHour = 0
      nHour := 12
   ENDIF

RETURN STR( nHour, 2 ) + SUBSTR( cTime, 3, IIF( lShowSecs, 6, 3 ) ) + cAmPm

*+ EOF: PRB_AMPM.PRG
