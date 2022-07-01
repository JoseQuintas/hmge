*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\READLNK.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function readlnk()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

*+--------------------------------------------------------------------
*+
*+    Function readlnk()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION readlnk( cFileName )

LOCAL hi
LOCAL nx
LOCAL w
LOCAL x
LOCAL y
LOCAL nY
LOCAL nFilePointer
LOCAL nPointer
LOCAL aFileList    := { }
LOCAL aLibList     := { }
LOCAL aLinkList    := { UPPER( cFileName ) }
LOCAL aFileDone    := { .f. }
LOCAL cThisLine
LOCAL cThisFile

   // we start this loop with the .LNK list we specified at runtime as the
   // only entry, and mark it .f. for not processed. As we process this
   // entry, we may come upon one or more references to other link scripts.
   // If this is the case, they are added to the processing array and
   // marked as not processed. When all have been processed, we have a
   // complete list. It's easier than recursion.

   DO WHILE .t.

      nFilePointer := ASCAN( aFileDone, .f. )

      // If 0, we finished finding and processing all .LNK files
      IF nFilePointer == 0
         EXIT
      ENDIF

      hi := binit( aLinkList[ nFilePointer ] )
      IF bopen( hi )

         DO WHILE !beof( hi )

            cThisLine := UPPER( LTRIM( bReadLine( hi ) ) )

            IF LEFT( cThisLine, 1 ) == '@'
               // grab the filename
               cThisLine := SUBSTR( cThisLine, 2 )

               // strip comments
               IF ( nPointer := AT( '#', cThisLine ) ) > 0
                  cThisLine := LEFT( cThisLine, nPointer - 1 )
               ENDIF

               // trim any spaces
               cThisLine := ALLTRIM( cThisLine )

               // check to see if this name is already in the list
               IF ( nPointer := ASCAN( aLinkList, cThisLine ) ) == 0

                  // force the extension
                  cThisFile := rootname( cThisLine ) + '.LNK'

                  // is it in the current directory?
                  IF !FILE( cThisFile )
                     // is it in the LIB= path?
                     cThisFile := fileinpath( cThisFile, 'LIB' )
                  ENDIF

                  // if it was not found in local dir or path, it is empty.
                  IF !EMPTY( cThisFile )
                     AADD( aLinkList, cThisFile )
                     AADD( aFileDone, .f. )
                  ENDIF
               ENDIF

            ENDIF

         ENDDO

         bClose( hi )

      ENDIF

      aFileDone[ nFilePointer ] := .t.

   ENDDO

   // once we have the link scripts all of them need to be scanned for
   // library references and for source references. Library references are
   // checked for validity against the environment, and program files are
   // checked for existance in the local directory.

   nY := LEN( aLinkList )

   FOR y := 1 TO nY
      hi := binit( aLinkList[ y ] )
      IF bopen( hi )
         DO WHILE !beof( hi )
            cThisLine := UPPER( ALLTRIM( bReadLine( hi ) ) )
            IF ( nPointer := AT( '#', cThisLine ) ) > 0
               cThisLine := TRIM( LEFT( cThisLine, nPointer - 1 ) )
            ENDIF
            IF LEFT( cThisLine, 2 ) $ 'LI|AL'
               cThisLine := ALLTRIM( SUBSTR( cThisLine, AT( ' ', cThisLine ) ) )
               IF !EMPTY( cThisLine )
                  nx := numtoken( cThisLine, ',' )
                  FOR x := 1 TO nx
                     cThisFile := UPPER( token( cThisLine, ',', x ) )
                     AADD( aLibList, fileinpath( rootname( cThisFile ) + '.LIB' ) )
                  NEXT
               ENDIF
            ENDIF
            IF LEFT( cThisLine, 2 ) == 'FI'
               cThisLine := ALLTRIM( SUBSTR( cThisLine, AT( ' ', cThisLine ) ) )
               IF !EMPTY( cThisLine )
                  nx := numtoken( cThisLine, ',' )
                  FOR x := 1 TO nx
                     cThisFile := token( cThisLine, ',', x )
                     w := RAT( '\', cThisFile )
                     IF w > 0
                        cThisFile := SUBSTR( cThisFile, w + 1 )
                     ENDIF
                     cThisFile := rootname( cThisFile ) + '.PRG'
                     IF FILE( cThisFile )
                        AADD( aFileList, cThisFile )
                     ENDIF
                  NEXT
               ENDIF
            ENDIF
         ENDDO
         bclose( hi )
      ENDIF
   NEXT

   // Exiting this routine, we have a pair of validated arrays which
   // contain a list of all libraries and all files referred to in the
   // link script being examined.

RETURN { aFileList, aLibList }

*+ EOF: READLNK.PRG
