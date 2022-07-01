*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\QSORT.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function QuickSort()
*+               Static Procedure bSort()
*+               Static Procedure qSort()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

/*
 #: 150 S0/CompuServe Mail
    28-Nov-93 14:46 EST
Sb: Is there a fast ASORT()
Fm: Trevor Dunsford [72074,1263]

Raymond,

The quickSort function just sets up the call to the bsort/qsort functions.
bsort() will handle evaluation of codeblocks and qsort() is
optimized to handle one dimensional arrays.  The codeblock for bsort is
slightly different than asort, instead of the usual { |x,y| x[1]<y[1] },
it is just { |x| x[1] } because of the way it handles comparison.  I
believe, that with a few simple modifications, you could make bsort use
the asort codeblocks...

trev
*/

#include "COMMON.CH"

*+--------------------------------------------------------------------
*+
*+    Function QuickSort()
*+
*+    Called from ( cmd_list.prg )   3 - function init_list()
*+
*+--------------------------------------------------------------------
*+
FUNCTION QuickSort( aList, bBlock )

   //
   // QuickSort(<aList>,[<bBlock>]) --> aList
   //   * <bBlock> format is { |<var>| <var>[<offset>] }
   //

   IF LEN( aList ) > 0
      IF isblock( bBlock )
         bsort( @aList, 1, LEN( aList ), @bBlock )
      ELSE
         qsort( @aList, 1, LEN( aList ) )
      ENDIF
   ENDIF

RETURN aList

*+--------------------------------------------------------------------
*+
*+    Static Procedure bSort()
*+
*+    Called from ( qsort.prg )   1 - function quicksort()
*+                                   2 - static procedure bsort()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE bSort( a, l, r, b )

LOCAL y
LOCAL i := l
LOCAL j := r
LOCAL x := EVAL( b, a[ INT( ( l + r ) / 2 ) ] )

   WHILE EVAL( b, a[ i ] ) < x
      i ++
   END

   WHILE x < EVAL( b, a[ j ] )
      j --
   END

   IF i <= j
      y := a[ i ]
      a[ i ] := a[ j ]
      a[ j ] := y
      i ++
      j --
   ENDIF

   DO WHILE i < j

      WHILE EVAL( b, a[ i ] ) < x
         i ++
      END

      WHILE x < EVAL( b, a[ j ] )
         j --
      END

      IF i <= j
         y := a[ i ]
         a[ i ] := a[ j ]
         a[ j ] := y
         i ++
         j --
      ENDIF

   ENDDO

   IF l < j
      bSort( @a, l, j, @b )
   ENDIF

   IF i < r
      bSort( @a, i, r, @b )
   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Procedure qSort()
*+
*+    Called from ( qsort.prg )   1 - function quicksort()
*+                                   2 - static procedure qsort()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE qSort( a, l, r )

LOCAL y
LOCAL i := l
LOCAL j := r
LOCAL x := a[ INT( ( l + r ) / 2 ) ]

   WHILE a[ i ] < x
      i ++
   END

   WHILE x < a[ j ]
      j --
   END

   IF i <= j
      y := a[ i ]
      a[ i ] := a[ j ]
      a[ j ] := y
      i ++
      j --
   ENDIF

   DO WHILE i < j

      WHILE a[ i ] < x
         i ++
      END

      WHILE x < a[ j ]
         j --
      END

      IF i <= j
         y := a[ i ]
         a[ i ] := a[ j ]
         a[ j ] := y
         i ++
         j --
      ENDIF

   ENDDO

   IF l < j
      qSort( @a, l, j )
   ENDIF

   IF i < r
      qSort( @a, i, r )
   ENDIF

RETURN

*+ EOF: QSORT.PRG
