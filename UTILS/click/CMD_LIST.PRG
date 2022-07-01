*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\CMD_LIST.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function init_list()
*+               Static Function no_ast()
*+               Function cmd_list()
*+               Function fnc_list()
*+               Function op_list()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

STATIC cmd_list
STATIC cmd_count
STATIC fnc_list
STATIC fnc_count
STATIC op_list
STATIC op_count

*+--------------------------------------------------------------------
*+
*+    Function init_list()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION init_list()

   // this function initializes the static arrays from the CLICK.INI file,
   // and creates several forms of the COMMAND array.
LOCAL retval1
LOCAL retval2
LOCAL ast_list
LOCAL non_upper
LOCAL nPointer
LOCAL cFullPath := IF( FILE( 'CLICK.INI' ), 'CLICK', rootname( ft_origin() ) ) + '.INI'

   /*
Read in the command list, sort it (ignoring *) and develop three arrays.
1 is the command list, forced to upper case.
2 is the command list without case changes.
3 is the logic array for the * marks.
*/

   show_in( 'Reading COMMAND list' )
   cmd_list := readlist( cFullPath, 'CMD_LIST' )
   cmd_count := LEN( cmd_list )
   FOR nPointer := 1 TO cmd_count
      cmd_list[ nPointer ] := ALLTRIM( cmd_list[ nPointer ] )
   NEXT
   show_in( 'Sorting COMMAND List' )
   // cmd_list  := asort( cmd_list,,, { | x, y | no_ast( x ) < no_ast( y ) } )
   cmd_list := quicksort( cmd_list, { | x | no_ast( x ) } )
   non_upper := ACLONE( cmd_list )
   ast_list := ARRAY( LEN( cmd_list ) )
   FOR nPointer := 1 TO cmd_count
      IF LEFT( cmd_list[ nPointer ], 1 ) == '*'
         cmd_list[ nPointer ] := UPPER( SUBSTR( cmd_list[ nPointer ], 2 ) )
         non_upper[ nPointer ] := SUBSTR( non_upper[ nPointer ], 2 )
         ast_list[ nPointer ] := .t.
      ELSE
         cmd_list[ nPointer ] := UPPER( cmd_list[ nPointer ] )
         ast_list[ nPointer ] := .f.
      ENDIF
   NEXT

   retval1 := non_upper

   show_in( 'Reading FUNCTION List' )
   fnc_list := readlist( cFullPath, 'FUNC_LIST' )
   fnc_count := LEN( fnc_list )
   FOR nPointer := 1 TO fnc_count
      IF LEN( fnc_list[ nPointer ] ) < 4
         fnc_list[ nPointer ] := PAD( fnc_list[ nPointer ], 4 )
      ENDIF
   NEXT
   show_in( 'Sorting FUNCTION List' )
   // fnc_list  := asort( fnc_list,,, { | x, y | upper( x ) < upper( y ) } )
   fnc_list := quicksort( fnc_list, { | x | UPPER( x ) } )
   non_upper := ACLONE( fnc_list )
   FOR nPointer := 1 TO fnc_count
      fnc_list[ nPointer ] := UPPER( fnc_list[ nPointer ] )
   NEXT

   retval2 := non_upper

   show_in( 'Reading OPERATOR List' )
   op_list := readlist( cFullPath, 'OP_LIST' )
   op_count := LEN( op_list )
   // op_list  := asort( op_list )
   op_list := quicksort( op_list )

RETURN { retval1, retval2, ast_list }

// function re-instated 13Dec'98 (DJW)
// because version in no_ast.c converts the contents
// of the actual variable passed to upper case
// (no wonder it's faster!)
//

*+--------------------------------------------------------------------
*+
*+    Static Function no_ast()
*+
*+    Called from ( cmd_list.prg )   1 - function init_list()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION no_ast( cWord )

   // This function is for the above function only, and allows the sort
   // to ignore the '*' if it exists as the first letter of a command.
RETURN UPPER( IF( LEFT( cWord, 1 ) == '*', SUBSTR( cWord, 2 ), cWord ) )

*+--------------------------------------------------------------------
*+
*+    Function cmd_list()
*+
*+    Called from ( click.prg )   2 - function lineparse()
*+
*+--------------------------------------------------------------------
*+
FUNCTION cmd_list( cWord, nPointer )

   // This seeks the word in the list and returns the pointer by reference.
   // The function returns whether or not the seek was successful.

   // This is a binary seek into a sorted array.
LOCAL retval   := .f.
LOCAL nWordLen := LEN( cWord )
LOCAL nLo      := 0
LOCAL nHi      := cmd_count + 1
LOCAL lTwoWord := ' ' $ cWord
LOCAL lShort   := nWordLen < 4

   cWord := UPPER( ALLTRIM( cWord ) )

   IF lShort
      cWord += ' '
   ENDIF

   IF nWordLen > 1

      nPointer := INT( cmd_count / 2 )

      DO WHILE nHi > nLo + 1

         IF lShort
            DO CASE
               CASE cWord == cmd_list[ nPointer ] + ' '
                  retval := .t.
                  EXIT
               CASE cWord < cmd_list[ nPointer ] + ' '
                  nHi := nPointer
               CASE cWord > cmd_list[ nPointer ] + ' '
                  nLo := nPointer
            ENDCASE
         ELSE
            DO CASE
               CASE cWord == PAD( cmd_list[ nPointer ], nWordLen )
                  retval := .t.
                  EXIT
               CASE cWord < PAD( cmd_list[ nPointer ], nWordLen )
                  nHi := nPointer
               CASE cWord > PAD( cmd_list[ nPointer ], nWordLen )
                  nLo := nPointer
            ENDCASE
         ENDIF

         nPointer := INT( nLo + ( ( nHi - nLo ) / 2 ) )

      ENDDO

   ENDIF

   IF retval .AND. !lTwoWord .AND. ' ' $ TRIM( cmd_list[ nPointer ] )
      retval := .f.
   ENDIF

RETURN retval

*+--------------------------------------------------------------------
*+
*+    Function fnc_list()
*+
*+    Called from ( click.prg )   2 - function lineparse()
*+
*+--------------------------------------------------------------------
*+
FUNCTION fnc_list( cWord, nPointer )

   // This seeks the word in the list and returns the pointer by reference.
   // The function returns whether or not the seek was successful.

   // This is a binary seek into a sorted array.
LOCAL retval   := .f.
LOCAL nWordLen := LEN( cWord )
LOCAL nLo      := 0
LOCAL nHi      := fnc_count + 1

   IF nWordLen > 1

      cWord := UPPER( cWord )
      IF nWordLen < 4
         cWord := PAD( cWord, 4 )
         nWordLen := 4
      ENDIF

      nPointer := INT( fnc_count / 2 )

      DO WHILE nHi > nLo + 1

         DO CASE
            CASE cWord == PAD( fnc_list[ nPointer ], nWordLen )
               retval := .t.
               EXIT
            CASE cWord < PAD( fnc_list[ nPointer ], nWordLen )
               nHi := nPointer
            CASE cWord > PAD( fnc_list[ nPointer ], nWordLen )
               nLo := nPointer
         ENDCASE

         nPointer := INT( nLo + ( ( nHi - nLo ) / 2 ) )

      ENDDO

   ENDIF

RETURN retval

*+--------------------------------------------------------------------
*+
*+    Function op_list()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                                   1 - function lineparse()
*+
*+--------------------------------------------------------------------
*+
FUNCTION op_list( cWord, nPointer )

   // This seeks the word in the list and returns the pointer by reference.
   // The function returns whether or not the seek was successful.

   // This is a binary seek into a sorted array.
LOCAL retval   := .f.
LOCAL nWordLen := LEN( cWord )
LOCAL nLo      := 0
LOCAL nHi      := op_count + 1

   nPointer := INT( op_count / 2 )

   IF nWordLen > 0

      DO WHILE nHi > nLo + 1

         DO CASE
            CASE cWord == op_list[ nPointer ]
               retval := .t.
               EXIT
            CASE cWord < op_list[ nPointer ]
               nHi := nPointer
            CASE cWord > op_list[ nPointer ]
               nLo := nPointer
         ENDCASE

         nPointer := INT( nLo + ( ( nHi - nLo ) / 2 ) )

      ENDDO

   ENDIF

RETURN retval

*+ EOF: CMD_LIST.PRG
