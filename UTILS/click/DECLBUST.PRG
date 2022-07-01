*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\DECLBUST.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Procedure declbust()
*+               Static Function stripcomnt()
*+               Static Function tab2space()
*+               Static Function nextcomma()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "DIRECTRY.CH"
#include "COMMON.CH"
#include "INKEY.CH"

#include "HMG.CH"

#define CVERSION '2.03'

*+--------------------------------------------------------------------
*+
*+    Procedure declbust()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE declbust( cThisFile, cOutFile )

LOCAL cThisLine
LOCAL cThisCommand
LOCAL cEndOfLine
   // LOCAL CRLF         := CHR( 13 ) + CHR( 10 )
LOCAL y
LOCAL z
LOCAL oOutHandle
LOCAL aLocals
LOCAL nPointer
LOCAL cComment
LOCAL lStatFunc
LOCAL cTempVar
LOCAL aPreCombined
LOCAL nPreCombined
LOCAL oBuffObj3
LOCAL nOldPcntDone
LOCAL nPcntDone
LOCAL nLineLen
LOCAL nLocalLen
LOCAL lWorkDone    := .f.
LOCAL aParts       := {}
LOCAL lClickIgnore := .f.
LOCAL lCommentMode := .f.
LOCAL aLine        := {}
LOCAL aType        := {}
LOCAL aParse       := {}
LOCAL n
LOCAL cStripLine
LOCAL cUStripLine
LOCAL cOutput
LOCAL cFullPath    := IF( FILE( 'CLICK.INI' ), 'CLICK', RootName( ft_origin() ) ) + '.INI'
LOCAL lConvertDo   := ProfileString( cFullPath, 'CLICK', 'CONVERT_OLD_STYLE_FUNCTIONS', 'NO' ) == 'YES'
LOCAL lConvertInc  := ProfileString( cFullPath, 'CLICK', 'CONVERT_TO_INCREMENTOR', 'YES' ) == 'YES'
LOCAL lCleanInc    := ProfileString( cFullPath, 'CLICK', 'CLEAN_UP_INCLUDES', 'YES' ) == 'YES'

   show_out( 'Declaration Buster,  Version ' + CVERSION )

   oBuffObj3 := bInit( cThisFile )

   // create the output file
   FERASE( cOutFile )
   oOutHandle := bo_init( cOutFile )
   IF bo_open( oOutHandle )

      // open the file for buffered reading
      IF bopen( oBuffObj3 )

         nPcntDone := 0
         SetProperty( "ClickForm", "ProgressBar_1", "Value", 0 )
         DO EVENTS

         // work on this file until all lines are read
         DO WHILE !beof( oBuffObj3 )

            // get the next line from the buffered read
            cThisLine := bReadLine( oBuffObj3 )
            // Show_Status( STR( bLineNumber( oBuffObj3 ), 8 ) )
            nOldPcntDone := nPcntDone
            nPcntDone := INT( bRelative( oBuffObj3 ) * 50 )
            IF nOldPcntDone <> nPcntDone
               SetProperty( "ClickForm", "ProgressBar_1", "Value", nPcntDone * 2 )
               DO EVENTS
            ENDIF

            IF EMPTY( cThisLine )
               bo_write( oOutHandle, CRLF )
               LOOP
            ENDIF

            cStripLine := TabSpStrip( cThisLine )
            cUStripLine := UPPER( cStripLine )

            // pay attention to the 'skip me' flags.
            IF cUStripLine == '*+CLICKOFF' .OR. cUStripLine == 'TEXT'
               lClickIgnore := .t.
            ENDIF

            IF lClickIgnore
               bo_write( oOutHandle, cThisLine + CRLF )
               IF cUStripLine == '*+CLICKON' .OR. cUStripLine == 'ENDTEXT' .OR. ;
                          bEof( oBuffObj3 )
                  lClickIgnore := .f.
               ENDIF
               LOOP
            ENDIF

            IF LEFT( cUStripLine, 1 ) == '*'
               IF lCommentMode .AND. AT( '*/', cThisLine ) > 0
                  lCommentMode := .f.
               ENDIF
               bo_write( oOutHandle, cThisLine + CRLF )
               LOOP
            ENDIF

            // write comments directly.
            IF LEFT( cStripLine, 2 ) == '//|&&'
               IF lCommentMode .AND. AT( '*/', cThisLine ) > 0
                  lCommentMode := .f.
               ENDIF
               bo_write( oOutHandle, cThisLine + CRLF )
               LOOP
            ENDIF

            IF !lCommentMode
               aParts := lineparse( cStripLine )
               aLine := aParts[ 1 ]
               aType := aParts[ 2 ]
            ENDIF

            // write # directives and loop

            nLineLen := LEN( aLine )

            IF aLine[ 1 ] == '#'

               IF lCleanInc .AND. nLineLen > 4 .AND. UPPER( aLine[ 3 ] ) == 'INCLUDE'

                  aLine[ 3 ] := LOWER( aLine[ 3 ] )
                  aLine[ 5 ] := STRTRAN( UPPER( aLine[ 5 ] ), "'", '"' )

               ENDIF

               IF aLine[ 2 ] == ' '

                  ADEL( aLine, 2 )
                  ADEL( aType, 2 )

                  ASIZE( aLine, LEN( aLine ) - 1 )
                  ASIZE( aType, LEN( aType ) - 1 )

                  cThisLine := ''

                  nLineLen := LEN( aLine )
                  FOR n := 1 TO nLineLen
                     cThisLine += aLine[ n ]
                  NEXT

               ENDIF

               bo_write( oOutHandle, LTRIM( cThisLine ) + CRLF )
               IF ASCAN( aType, 'LC' ) > 0
                  DO WHILE .t.
                     cThisLine := bReadLine( oBuffObj3 )
                     // Show_Status( STR( bLineNumber( oBuffObj3 ), 8 ) )
                     bo_write( oOutHandle, cThisLine + CRLF )
                     aParse := lineparse( cThisLine )
                     aLine := aParse[ 1 ]
                     aType := aParse[ 2 ]
                     IF ASCAN( aType, 'LC' ) == 0
                        EXIT
                     ENDIF
                  ENDDO
               ENDIF
               LOOP
            ENDIF

            setlinecont( aType )

            // Check for /* and */ comments and skip them

            IF lCommentMode
               IF AT( '*/', cThisLine ) > 0
                  lCommentMode := .f.
               ENDIF
               bo_write( oOutHandle, cThisLine + CRLF )
               LOOP
            ELSE
               IF ATAIL( aType ) == '/*'
                  lCommentMode := .t.
               ENDIF
            ENDIF

            // Strip the tabs out of this line.
            cThisLine := ''
            nLineLen := LEN( aLine )
            FOR n := 1 TO nLineLen
               IF aType[ n ] == 'S'                                   // don't strip tabs from inside of strings.
                  cThisLine += aLine[ n ]
               ELSE
                  cThisLine += tab2space( aLine[ n ] )
               ENDIF
            NEXT

            aParts := stripcomnt( cThisLine )

            cThisLine := aParts[ 1 ]
            cComment := aParts[ 2 ]

            // check to see if the line is a declaration line

            IF PAD( UPPER( ALLTRIM( cThisLine ) ), 4 ) $ ;
                    'LOCA|PRIV|MEMV|STAT|PUBL|FIEL|REPL|METH|CLAS'
            ENDIF

            DO CASE
               CASE nLineLen > 0 .AND. aType[ 1 ] $ 'CT' .AND. ;
                          PAD( UPPER( ALLTRIM( cThisLine ) ), 4 ) $ ;
                          'LOCA|PRIV|MEMV|STAT|PUBL|FIEL|REPL|METH|CLAS'

                  // this checks to see if this line has a continuation -> ;
                  // and if so it grabs the rest of the pieces and
                  // creates a single long line out of them.

                  // it also gathers an array of all the lines before they
                  // get combined, so if there is nothing to do, we can
                  // put them back the way they started.

                  cThisline := ALLTRIM( cThisline )
                  aPreCombined := { cThisLine + ' ' + cComment }
                  nPreCombined := 1
                  DO WHILE RIGHT( cThisLine, 1 ) == ';'

                     cThisLine := LEFT( cThisLine, LEN( cThisLine ) - 1 )
                     cTempVar := bReadLine( oBuffObj3 )
                     // Show_Status( STR( bLineNumber( oBuffObj3 ), 8 ) )
                     AADD( aPreCombined, cTempVar )
                     nPreCombined ++

                     aParts := stripcomnt( cTempVar )
                     cTempVar := aParts[ 1 ]
                     cComment += aParts[ 2 ]

                     cThisLine += ALLTRIM( cTempVar )

                  ENDDO

                  // check for STATIC FUNCTION's, yet another overloaded term!
                  lStatFunc := .f.
                  // find out where second word starts
                  nPointer := AT( ' ', cThisLine )
                  IF UPPER( LEFT( cThisline, 4 ) ) == 'STAT'
                     IF UPPER( LEFT( SUBSTR( cThisline, nPointer + 1 ), 4 ) ) == 'FUNC'
                        lStatFunc := .t.
                     ENDIF
                  ENDIF

                  // check to see if we can skip this declaration
                  // because it only has one part

                  IF AT( ',', cThisLine ) == 0 .OR. ;
                         nextcomma( cThisLine ) == 0 .OR. ;
                         lStatFunc .OR. ;
                         ASCAN( aLine, { | ww | UPPER( ww ) == 'ALL' } ) > 0 .OR. ;
                         ASCAN( aLine, { | ww | UPPER( ww ) == 'NEXT' } ) > 0 .OR. ;
                         ASCAN( aLine, { | ww | UPPER( ww ) == 'WHILE' } ) > 0 .OR. ;
                         ASCAN( aLine, { | ww | UPPER( ww ) == 'FOR' } ) > 0

                     // No need to break this one up, so just write it
                     // from data gathered before it was assembled from
                     // multiple lines.

                     FOR z := 1 TO nPreCombined
                        bo_write( oOutHandle, aPreCombined[ z ] + CRLF )
                     NEXT

                  ELSE

                     // once we get to here, we have found a line which
                     // needs to be broken apart.

                     // first, we grab the declaration command off of the
                     // left end of the line.

                     DO CASE
                        CASE UPPER( LEFT( cThisLine, 9 ) ) == 'CLASS VAR'
                           IF 'READONLY' $ UPPER( cThisLine )
                              cThisCommand := 'CLASS VAR READONLY'
                              cThisLine := SUBSTR( cThisLine, 11 )
                              cThisLine := STUFF( cThisLine, AT( 'READONLY', UPPER( cThisLine ) ), 8, '' )
                           ELSE
                              cThisCommand := LEFT( cThisLine, 9 )
                              cThisLine := SUBSTR( cThisLine, 11 )
                           ENDIF

                        CASE UPPER( LEFT( cThisLine, 12 ) ) == 'CLASS METHOD'
                           cThisCommand := LEFT( cThisLine, 12 )
                           cThisLine := SUBSTR( cThisLine, 14 )
                        OTHERWISE
                           cThisCommand := LEFT( cThisLine, AT( ' ', cThisLine ) - 1 )
                           cThisLine := SUBSTR( cThisLine, LEN( cThisCommand ) + 1 )
                     ENDCASE

                     // now, we go throught the line and seperate each
                     // declaration into the aLocals array
                     aLocals := {}

                     DO WHILE .t.

                        // this gets the next divider comma
                        nPointer := nextcomma( cThisLine )

                        // if nPoiner is still greater than 0, there are still
                        // more parts to seperate

                        IF nPointer > 0
                           // grab off this piece and put it on the array
                           AADD( aLocals, LEFT( cThisLine, nPointer - 1 ) )
                           // then trim it off of the working line
                           cThisLine := SUBSTR( cThisLine, nPointer + 1 )
                        ELSE
                           // this is the last one!
                           AADD( aLocals, cThisLine )
                           EXIT
                        ENDIF

                     ENDDO

                     // now, write the output to the file in seperate pieces

                     nLocalLen := LEN( aLocals )
                     FOR y := 1 TO nLocalLen
                        bo_write( oOutHandle, cThisCommand + ;
                                  ' ' + ;
                                  ALLTRIM( aLocals[ y ] ) + ;
                                  cComment + ;
                                  CRLF )
                     NEXT

                     lWorkDone := .t.

                  ENDIF

               CASE lConvertInc .AND. nLineLen > 8 .AND. ;
                          UPPER( aLine[ 1 ] ) == UPPER( aLine[ 5 ] ) .AND. ;
                          aLine[ 3 ] $ ':='

                  aParts := lineparse( cThisLine )
                  aLine := aParts[ 1 ]
                  aType := aParts[ 2 ]

                  nLineLen := LEN( aLine )

                  DO CASE
                     CASE aLine[ 9 ] == '1' .AND. nLineLen == 9 .AND. aLine[ 7 ] $ '+-'
                        bo_write( oOutHandle, aLine[ 1 ] + aLine[ 7 ] + aLine[ 7 ] + ' ' + cComment + CRLF )
                        lWorkDone := .t.
                     CASE aLine[ 7 ] $ '+-*/^'
                        cEndOfLine := ''
                        FOR y := 9 TO nLineLen
                           cEndOfLine += aLine[ y ]
                        NEXT
                        bo_write( oOutHandle, aLine[ 1 ] + ' ' + aLine[ 7 ] + '= ' + cEndOfLine + ' ' + cComment + CRLF )
                        lWorkDone := .t.
                     OTHERWISE
                        bo_write( oOutHandle, cThisLine + ' ' + cComment + CRLF )
                  ENDCASE

               CASE lConvertDo .AND. nLineLen > 2 .AND. ;
                          UPPER( aLine[ 1 ] ) == 'DO' .AND. ;
                          ! ( PAD( aLine[ 3 ], 4 ) $ 'CASE|WHIL' )

                  cOutput := aLine[ 3 ] + '('

                  IF nLineLen > 5 .AND. UPPER( aline[ 5 ] ) == 'WITH'
                     FOR y := 6 TO nLineLen
                        IF LEFT( aType[ y ], 2 ) $ '//*'
                           cComment := aLine[ y ]
                           EXIT
                        ENDIF
                        IF !( LEFT( aLine[ y ], 1 ) $ ', /()' )
                           cOutput += '@'
                        ENDIF
                        cOutput += aLine[ y ]
                     NEXT
                  ENDIF

                  bo_write( oOutHandle, cOutput + ') ' + cComment + CRLF )
                  lWorkDone := .t.

               OTHERWISE

                  // this line is not a declaration line, write it with no change
                  bo_write( oOutHandle, cThisLine + cComment + CRLF )

                  // and if it is a continuation, write all the lines that follow
                  // the continuation
                  DO WHILE RIGHT( ALLTRIM( cThisLine ), 1 ) == ';'

                     aParts := stripcomnt( bReadLine( oBuffObj3 ) )
                     // Show_Status( STR( bLineNumber( oBuffObj3 ), 8 ))
                     cThisLIne := aParts[ 1 ]
                     cComment := aParts[ 2 ]

                     bo_write( oOutHandle, cThisLine + cComment + CRLF )

                  ENDDO

            ENDCASE

         ENDDO

         // we are done with this file, so close the input and output

         bclose( oBuffObj3 )

      ENDIF

   ENDIF

   bo_close( oOutHandle )

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function stripcomnt()
*+
*+    Called from ( declbust.prg )   3 - procedure declbust()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION stripcomnt( cThisLine )

LOCAL nPointer  := 0
LOCAL nParen    := 0
LOCAL nBrack    := 0
LOCAL nBrace    := 0
LOCAL nSQuote   := 0
LOCAL nDQuote   := 0
LOCAL inlinecmt := 0
LOCAL x
LOCAL nNumChars := LEN( cThisLine )
LOCAL cThisChar
LOCAL cTwoChars
LOCAL cString
LOCAL cComment

   IF '//' $ cThisLine .OR. '&&' $ cThisLine

      FOR x := 1 TO nNumChars

         cTwoChars := SUBSTR( cThisLine, x, 2 )

         DO CASE
            CASE cTwoChars == '/*'
               inlinecmt ++
            CASE cTwoChars == '*/'
               inlinecmt --
         ENDCASE

         IF inlinecmt == 0

            cThisChar := SUBSTR( cThisLine, x, 1 )

            IF nSQuote == 0 .AND. nDQuote == 0
               DO CASE
                  CASE cThisChar == '('
                     nParen ++
                  CASE cThisChar == ')'
                     nParen --
                  CASE cThisChar == '{'
                     nBrace ++
                  CASE cThisChar == '}'
                     nBrace --
                  CASE cThisChar == '['
                     nBrack ++
                  CASE cThisChar == ']'
                     nBrack --
               ENDCASE
            ENDIF

            DO CASE
               CASE cThisChar == '"'
                  IF nSQuote == 0
                     IF nDQuote == 1
                        nDQuote := 0
                     ELSE
                        nDQuote := 1
                     ENDIF
                  ENDIF
               CASE cThisChar == "'"
                  IF nDQuote == 0
                     IF nSQuote == 1
                        nSQuote := 0
                     ELSE
                        nSQuote := 1
                     ENDIF
                  ENDIF
            ENDCASE

            // if all of this is true, then we just found a comment

            IF ( cTwoChars == '&&' .OR. cTwoChars == '//' ) .AND. ;
                 nParen + nBrack + nBrace + nSQuote + nDQuote == 0

               nPointer := x
               EXIT

            ENDIF

         ENDIF

      NEXT

   ENDIF

   IF nPointer > 0
      cString := LEFT( cThisLine, nPointer - 1 )
      cComment := SUBSTR( cThisLine, nPointer )
   ELSE
      cString := cThisLine
      cComment := ''
   ENDIF

RETURN { cString, cComment }

*+--------------------------------------------------------------------
*+
*+    Static Function tab2space()
*+
*+    Called from ( declbust.prg )   1 - procedure declbust()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION tab2space( aString )

RETURN STRTRAN( aString, CHR( K_TAB ), ' ' )

*+--------------------------------------------------------------------
*+
*+    Static Function nextcomma()
*+
*+    Called from ( declbust.prg )   2 - procedure declbust()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION nextcomma( cThisLine )

   /*

Realistically, this is the heartbeat of this entire process.
Without this function, it is impossible to determine where a multiple declaration begins
and ends, since Clipper language allows overloading of symbols in the
language. In this case, the comma is overloaded. It means more than
one thing.

Rules:

Anything inside an inline comment is bypassed

Any comma inside a function should be bypassed

Comma, Parenthesis, Braces and Brackets should be bypassed if they are
inside a string declaration.

Single quotes are bypassed if they are inside
a double quote string declaration

Double quotes are bypassed if they are inside
a single quote string declaration

Note:

This routine does not consider [ ] characters to be string declaration.
Although they can legally be used that way, I have not found it to be
common. It also difficult to determine when they are being used in this
manner.

*/

LOCAL nPointer  := 0
LOCAL nParen    := 0
LOCAL nBrack    := 0
LOCAL nBrace    := 0
LOCAL nSQuote   := 0
LOCAL nDQuote   := 0
LOCAL inlinecmt := 0
LOCAL x
LOCAL nNumChars := LEN( cThisLine )
LOCAL cThisChar
LOCAL cTwoChars

   IF ',' $ cThisLine
      FOR x := 1 TO nNumChars
         cTwoChars := SUBSTR( cThisLine, x, 2 )

         DO CASE
            CASE cTwoChars == '/*'
               inlinecmt ++
            CASE cTwoChars == '*/'
               inlinecmt --
         ENDCASE

         IF inlinecmt == 0

            cThisChar := SUBSTR( cThisLine, x, 1 )

            IF nSQuote == 0 .AND. nDQuote == 0
               DO CASE
                  CASE cThisChar == '('
                     nParen ++
                  CASE cThisChar == ')'
                     nParen --
                  CASE cThisChar == '{'
                     nBrace ++
                  CASE cThisChar == '}'
                     nBrace --
                  CASE cThisChar == '['
                     nBrack ++
                  CASE cThisChar == ']'
                     nBrack --
               ENDCASE
            ENDIF

            DO CASE
               CASE cThisChar == '"'
                  IF nSQuote == 0
                     IF nDQuote == 1
                        nDQuote := 0
                     ELSE
                        nDQuote := 1
                     ENDIF
                  ENDIF
               CASE cThisChar == "'"
                  IF nDQuote == 0
                     IF nSQuote == 1
                        nSQuote := 0
                     ELSE
                        nSQuote := 1
                     ENDIF
                  ENDIF
            ENDCASE

            // if all of this is true, then we just found a comma worth dividing on!
            IF cThisChar == ',' .AND. ;
                       nParen + nBrack + nBrace + nSQuote + nDQuote == 0

               nPointer := x
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF

RETURN nPointer

*+ EOF: DECLBUST.PRG
