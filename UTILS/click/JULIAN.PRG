*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\JULIAN.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function TD2JUL()
*+               Static Function JUL2TIME()
*+               Static Function JUL2DATE()
*+               Function DIFF2JUL()
*+               Static Function JUL_DIFF()
*+               Static Function JUL_BTW()
*+               Static Function JUL_BTWX()
*+               Static Function JUL_SEEK()
*+               Static Function JUL_AVE()
*+               Function TTOS()
*+               Static Function TTOMS()
*+               Static Function TTOM()
*+               Static Function MINS2HUND()
*+               Function PRB_INT()
*+               Static Function JUL_PACK()
*+               Static Function JUL_UNPACK()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"

#define BASE_DATE "1980"

*+--------------------------------------------------------------------
*+
*+    Function TD2JUL()
*+
*+    Called from ( click.prg )   4 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION TD2JUL( cTime, dDate )

   DEFAULT cTime TO TIME()
   DEFAULT dDate TO DATE()

RETURN dDate - CTOD( '01/01/' + BASE_DATE ) + ;
                     ( PRB_INT( TTOS( cTime ) / 100000,, 5 ) )
#if 0
*+--------------------------------------------------------------------
*+
*+    Static Function JUL2TIME()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL2TIME( Jul1 )                                      // unused

LOCAL nTotSecs := VAL( RIGHT( STR( Jul1, 14, 5 ), 5 ) )
LOCAL H
LOCAL M
LOCAL S

   H := PRB_INT( nTotSecs / 3600 )
   nTotSecs := nTotSecs % 3600
   M := PRB_INT( nTotSecs / 60 )
   S := nTotSecs % 60

RETURN STRZERO( H, 2 ) + ':' + ;
                STRZERO( M, 2 ) + ':' + ;
                STRZERO( S, 2 )

*+--------------------------------------------------------------------
*+
*+    Static Function JUL2DATE()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL2DATE( Jul1 )                                      // unused

RETURN CTOD( '01/01/' + BASE_DATE ) + PRB_INT( Jul1 )
#endif
*+--------------------------------------------------------------------
*+
*+    Function DIFF2JUL()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                ( julian.prg )   2 - static function jul_seek()
*+                                   1 - static function jul_ave()
*+
*+--------------------------------------------------------------------
*+
FUNCTION DIFF2JUL( Jul1, Jul2 )

LOCAL M
LOCAL S
LOCAL H
LOCAL retval

LOCAL J1 := MIN( Jul1, Jul2 )
LOCAL J2 := MAX( Jul1, Jul2 )
LOCAL D  := PRB_INT( J2 ) - PRB_INT( J1 )

LOCAL nTotSecs := VAL( RIGHT( STR( J2, 14, 5 ), 5 ) ) - ;
                          VAL( RIGHT( STR( J1, 14, 5 ), 5 ) )

   D -= PRB_INT( ABS( nTotSecs ) / 86400 ) + 1
   nTotSecs := PRB_INT( nTotSecs % 86400 ) + 86400

   H := PRB_INT( nTotSecs / 3600 ) + ( D * 24 )
   nTotSecs := PRB_INT( nTotSecs % 3600 )
   M := PRB_INT( nTotSecs / 60 )
   S := PRB_INT( nTotSecs % 60 )

   IF S > 59
      M ++
      S := 0
      IF M > 59
         H ++
         M := 0
      ENDIF
   ENDIF

   DO CASE
      CASE h > 0
         retval := STRZERO( H, 7 ) + ':' + ;
                            STRZERO( M, 2 ) + ':' + ;
                            STRZERO( S, 2 )
      CASE m > 0
         retval := STRZERO( M, 2 ) + ':' + ;
                            STRZERO( S, 2 )
      OTHERWISE
         retval := LTRIM( STR( S, 2 ) ) + ' Seconds'
   ENDCASE

RETURN retval

#if 0
*+--------------------------------------------------------------------
*+
*+    Static Function JUL_DIFF()
*+
*+    Called from ( julian.prg )   1 - static function jul_ave()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_DIFF( Jul1, OFFSET )

LOCAL D := PRB_INT( Jul1 )
LOCAL S := VAL( RIGHT( STR( Jul1, 14, 5 ), 5 ) ) + ( PRB_INT( OFFSET * 60 ) )

   IF S < 0
      D -= PRB_INT( ABS( S ) / 86400 ) + 1
      S := PRB_INT( ABS( S ) % 86400 )
   ELSEIF S > 86399
      D += PRB_INT( S / 86400 )
      S := PRB_INT( S % 86400 )
   ENDIF

RETURN PRB_INT( D + ( S / 100000 ),, 5 )

*+--------------------------------------------------------------------
*+
*+    Static Function JUL_BTW()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_BTW( Jul1, Jul2, Unk )                            // unused

RETURN ( Jul1 <= Unk ) .AND. ( Unk <= Jul2 )

*+--------------------------------------------------------------------
*+
*+    Static Function JUL_BTWX()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_BTWX( Jul1, Jul2, Unk )                           // unused

RETURN ( Jul1 < Unk ) .AND. ( Unk < Jul2 )

*+--------------------------------------------------------------------
*+
*+    Static Function JUL_SEEK()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_SEEK( Jul1, Jul2, Unk )                           // unused

RETURN IIF( DIFF2JUL( Jul1, Unk ) < DIFF2JUL( Jul2, Unk ), 1, 2 )

*+--------------------------------------------------------------------
*+
*+    Static Function JUL_AVE()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_AVE( Jul1, Jul2 )                                 // unused

LOCAL DIFF := DIFF2JUL( MIN( Jul1, Jul2 ), MAX( Jul1, Jul2 ) )
LOCAL H    := VAL( LEFT( DIFF, 7 ) )
LOCAL M    := VAL( SUBSTR( DIFF, 9, 2 ) )
LOCAL S    := VAL( SUBSTR( DIFF, 12, 2 ) )

RETURN JUL_DIFF( MIN( Jul1, Jul2 ), ( ( S / 60 ) + M + ( H * 60 ) ) / 2 )
#endif
*+--------------------------------------------------------------------
*+
*+    Function TTOS()
*+
*+    Called from ( julian.prg )   1 - function td2jul()
*+
*+--------------------------------------------------------------------
*+
FUNCTION TTOS( cTime )

RETURN ( VAL( SUBSTR( cTime, 7, 2 ) ) ) + ;
         ( VAL( SUBSTR( cTime, 4, 2 ) ) * 60 ) + ;
         ( VAL( SUBSTR( cTime, 1, 2 ) ) * 3600 )

#if 0
*+--------------------------------------------------------------------
*+
*+    Static Function TTOMS()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION TTOMS( cTime )                                        // unused

RETURN ( VAL( SUBSTR( cTime, 7, 2 ) ) / 60 ) + ;
         ( VAL( SUBSTR( cTime, 4, 2 ) ) ) + ;
         ( VAL( SUBSTR( cTime, 1, 2 ) ) * 60 )

*+--------------------------------------------------------------------
*+
*+    Static Function TTOM()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION TTOM( cTime )                                         // unused

RETURN ( VAL( SUBSTR( cTime, 4, 2 ) ) ) + ;
         ( VAL( SUBSTR( cTime, 1, 2 ) ) * 60 )

*+--------------------------------------------------------------------
*+
*+    Static Function MINS2HUND()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION MINS2HUND( nMinutes )                                 // unused

RETURN nMinutes / 60
#endif
*+--------------------------------------------------------------------
*+
*+    Function PRB_INT()
*+
*+    Called from ( julian.prg )   1 - function td2jul()
*+                                   2 - static function jul2time()
*+                                   1 - static function jul2date()
*+                                   8 - function diff2jul()
*+                                   7 - static function jul_diff()
*+
*+--------------------------------------------------------------------
*+
FUNCTION PRB_INT( nSomeNumber, nLength, nDecimals )

LOCAL lNegative   := ( nSomeNumber < 0 )
LOCAL cSomeString
LOCAL nDotAt

   DEFAULT nDecimals TO 0
   DEFAULT nLength TO 19

   IF lNegative
      nSomeNumber := ABS( nSomeNumber )
   ENDIF

   nSomeNumber += .0000000000000005

   cSomeString := ALLTRIM( STR( nSomeNumber ) )

   nDotAt := AT( '.', cSomeString )

   IF nDecimals > 0
      IF nDotAt > 0
         cSomeString := LEFT( cSomeString, nDotAt + nDecimals )
      ENDIF
   ELSE
      IF nDotAt > 0
         cSomeString := LEFT( cSomeString, nDotAt - 1 )
      ENDIF
   ENDIF

   IF lNegative
      cSomeString := '-' + cSomeString
   ENDIF

RETURN VAL( cSomeString )

#if 0
*+--------------------------------------------------------------------
*+
*+    Static Function JUL_PACK()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_PACK( nJulian )                                   // unused

LOCAL cJulian  := STRTRAN( STRZERO( nJulian, 11, 5 ), '.' )
LOCAL cPackJul := ''
LOCAL x

   FOR x := 1 TO 10 step 2
      cPackJul += CHR( VAL( SUBSTR( cJulian, x, 2 ) ) )
   NEXT

RETURN cPackJul

*+--------------------------------------------------------------------
*+
*+    Static Function JUL_UNPACK()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION JUL_UNPACK( cPackJul )                                // unused

LOCAL cJulian := ''
LOCAL x

   FOR x := 1 TO 5
      cJulian += STRZERO( ASC( SUBSTR( cPackJul, x, 1 ) ), 2 )
   NEXT

RETURN VAL( LEFT( cJulian, 5 ) + '.' + SUBSTR( cJulian, 6, 5 ) )
#endif
*+ EOF: JULIAN.PRG
