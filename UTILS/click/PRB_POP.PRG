*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\PRB_POP.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Procedure POP_MSG()
*+               Procedure ATTENTION()
*+               Function c()
*+               Function VERIFY()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"
#include "BOX.CH"
#include "SET.CH"

#define CRLF      CHR(13)+CHR(10)

STATIC THISSCRN
STATIC TL
STATIC BOXHIGH

*+--------------------------------------------------------------------
*+
*+    Procedure POP_MSG()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE POP_MSG( SOME_TXT, MSG_LOGIC, BORDCOLOR, MAINCOLOR )

//LOCAL MAXLEN
LOCAL x
LOCAL ARLEN
//LOCAL INCOLOR
//LOCAL CROW
//LOCAL CCOL
//LOCAL LC
LOCAL cDummy  := ""

   DEFAULT MSG_LOGIC TO .t.
   DEFAULT BORDCOLOR TO 'B+/W'
   DEFAULT MAINCOLOR TO 'N/W,W+/B'

   IF !ISARRAY( SOME_TXT )
      SOME_TXT := { SOME_TXT }
   ENDIF
   ARLEN := LEN( SOME_TXT )
   FOR x := 1 TO ARLEN
      cDummy += SOME_TXT[ x ] + CRLF
   NEXT
   MsgInfo( cDummy )
RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure ATTENTION()
*+
*+    Called from ( xbase.prg )   1 - function createini()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE ATTENTION( CSTRING, NLINENUM, CCOLOR )

//LOCAL COLDCOLOR

   DEFAULT NLINENUM TO 24
   DEFAULT CCOLOR TO 'GR+/R'

   msgInfo( CSTRING )

RETURN

*+--------------------------------------------------------------------
*+
*+    Function c()
*+
*+--------------------------------------------------------------------
*+
FUNCTION c( CSTRING )

RETURN MAX( ( MAXCOL() / 2 ) - INT( LEN( CSTRING ) / 2 ), 0 )

*+--------------------------------------------------------------------
*+
*+    Function VERIFY()
*+
*+    Called from ( click.prg )   1 - static procedure doesc()
*+                                  10 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION VERIFY( SOME_TXT, LNORMANS, YES_PRMPT, NO_PRMPT, BORDCOLOR, MAINCOLOR )

//LOCAL INCOLOR
LOCAL nVERI
LOCAL ARLEN
LOCAL x, cDummy := ""
//LOCAL nButton

   DEFAULT BORDCOLOR TO 'W+/R'
   DEFAULT MAINCOLOR TO 'W+/R,W+/B'

   LNORMANS := IIF( ISLOGIC( LNORMANS ), LNORMANS, .t. )
   YES_PRMPT := IIF( YES_PRMPT = NIL, ' YES ', ' ' + ALLTRIM( YES_PRMPT ) + ' ' )
   NO_PRMPT := IIF( NO_PRMPT = NIL, ' NO ', ' ' + ALLTRIM( NO_PRMPT ) + ' ' )

   IF !ISARRAY( SOME_TXT )
      SOME_TXT := { SOME_TXT }
   ENDIF

   ARLEN := LEN( SOME_TXT ) + 2

   ASIZE( SOME_TXT, ARLEN )

   SOME_TXT[ ARLEN - 1 ] := ''
   SOME_TXT[ ARLEN ] := ''

   //  POP_MSG( SOME_TXT, .f., BORDCOLOR, MAINCOLOR )

   nVERI := IIF( LNORMANS, 1, 2 )

   FOR x := 1 TO ARLEN
      cDummy += SOME_TXT[ x ] + CRLF
   NEXT
   cDummy += YES_PRMPT + " .or. " + NO_PRMPT
   IF MSGYESNO( cDummy )
      nVERI := 1
   ELSE
      nVERI := 2
   ENDIF

RETURN ( nVERI == 1 )

*+ EOF: PRB_POP.PRG
