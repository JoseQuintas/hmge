*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\NICEDATE.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function NiceDate()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

*+--------------------------------------------------------------------
*+
*+    Function NiceDate()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                ( functrak.prg )   3 - function func_text()
*+
*+--------------------------------------------------------------------
*+
FUNCTION NiceDate( dDate )

LOCAL cDateString := "<< Invalid Date >>"

   IF VALTYPE( dDate ) == 'D'
      cDateString := LEFT( CMONTH( dDate ), 3 ) + '-' + ;
                           LTRIM( STR( DAY( dDate ) ) ) + '-' + ;
                           STR( YEAR( dDate ), 4 )
   ENDIF

RETURN ( cDateString )

*+ EOF: NICEDATE.PRG
