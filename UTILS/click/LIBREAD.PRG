*+--------------------------------------------------------------------
*+
*+ Source Module => c:\MiniGUI\UTILS\HB_CLICK\LIBREAD.PRG
*+
*+    Functions: Procedure libread()
*+               Static Function findlibs()
*+               Static Function MyHandler()
*+               Static Procedure dir_recurs()
*+
*+       Tables: USE ( cDBFPath ) new ALIAS CLICK
*+
*+      Indexes: INDEX ON fnct + srce TAG funct_src unique
*+
*+    Reformatted by Click! 2.05.29 on Jan-20-2020 at  9:55 am
*+
*+--------------------------------------------------------------------

#include "COMMON.CH"
#include "FILEIO.CH"
#include "DIRECTRY.CH"

STATIC aOutput    := {}
STATIC nLevel     := 0
STATIC nRecursion := 0

*+--------------------------------------------------------------------
*+
*+    Procedure libread()
*+
*+    Called from ( click.prg )   2 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE libread( cDBFPath, cNSXPath )

LOCAL x
LOCAL nHandle
LOCAL cBuffer
LOCAL nBytesRead
LOCAL nDictOffset
LOCAL IDByte        := CHR( 240 )
LOCAL nBucket
LOCAL cBuffer2
LOCAL nDictPages
LOCAL y
LOCAL nCurrPntr
LOCAL nThisDictPage
LOCAL cFunction
LOCAL nPath
LOCAL cPath
LOCAL aPaths        := {}
LOCAL cThisPath
LOCAL cDir
LOCAL aFiles
LOCAL nFile
LOCAL cFileName
LOCAL nMaxPathLen
LOCAL aFileList
LOCAL equ_at
LOCAL cLibRead      := ProfileString( RootName( ft_origin() ) + '.INI', 'CLICK', 'MAKE_CLICK_DBF_FROM', 'ENVIRONMENT' )

   FIELD fnct
   FIELD srce

   nRecursion := ProfileNum( RootName( ft_origin() ) + '.INI', 'CLICK', 'RECURSION_LIMIT', 7 )

   DO CASE
      CASE cLibRead == 'DRIVES'
         cPath := findlibs()
      CASE cLibRead == 'ENVIRONMENT'
         cPath := GETE( 'LIB' )
      OTHERWISE
         cPath := cLibRead
   ENDCASE

   // This section decides how long the longest path is
   nMaxPathLen := 0
   nPath := numtoken( cPath, ';' )
   FOR x := 1 TO nPath
      cDir := ALLTRIM( token( cPath, ';', x ) )
      cDir += IIF( RIGHT( cDir, 1 ) <> '\', '\', '' )
      AADD( aPaths, cDir )
      nMaxPathLen := MAX( nMaxPathLen, LEN( cDir ) )
   NEXT

   // and adds 12 for the max filename length. XXXXXXXX.XXX = 12
   nMaxPathLen += 12

   // erase any existing files before beginning.
   IF FILE( cDBFPath )
      FERASE( cDBFPath )
   ENDIF
   IF FILE( cNSXPath )
      FERASE( cNSXPath )
   ENDIF

   // create the new CLICK.DBF file
   DBCREATE( CDBFPATH, { { 'FNCT', 'C',          30, 0 }, ;
                         { 'SRCE', 'C', nMaxPathLen, 0 } } )

   USE ( cDBFPath ) new ALIAS CLICK

   show_in( 'Creating ' + cDBFPath )

   // cycle through each path.
   FOR nPath := 1 TO LEN( aPaths )

      cThisPath := aPaths[ nPath ]

      aFiles := DIRECTORY( cThisPath + '*.LIB' )

      FOR nFile := 1 TO LEN( aFiles )

         BEGIN SEQUENCE

            cFileName := cThisPath + aFiles[ nFile, F_NAME ]

            show_in( cThisPath + aFiles[ nFile, F_NAME ] )

            nHandle := FOPEN( cFileName, 0 )                          // open read only
            cBuffer := ' '
            nBytesRead := FREAD( nHandle, @cBuffer, 1 )

            // if bad handle, or first byte is not chr( 240 ) (microsoft object)
            // skip this one

            IF nHandle == - 1 .OR. cBuffer <> IDByte
               BREAK
            ENDIF

            // go to the third byte
            FSEEK( nHandle, 3, FS_SET )

            // read in 4 bytes
            cBuffer := SPACE( 4 )
            nBytesRead := FREAD( nHandle, @cBuffer, 4 )
            // This is the start of the library dictionary
            nDictOffset := BIN2L( cBuffer )

            // read in the next 2 bytes
            cBuffer := SPACE( 2 )
            nBytesRead := FREAD( nHandle, @cBuffer, 2 )
            // This is how many 37 entry, 512 byte sections there are
            nDictPages := BIN2I( cBuffer ) - 1                        // 0 offset reference

            FOR y := 0 TO nDictPages

               // get a pointer to the dictionary page
               nThisDictPage := nDictOffset + ( y * 512 )

               // can we go to that offset?
               IF FSEEK( nHandle, nThisDictPage, FS_SET ) <> nThisDictPage
                  BREAK
               ENDIF

               // read in the 37 byte string for 37 buckets
               cBuffer := SPACE( 37 )
               FREAD( nHandle, @cBuffer, 37 )

               FOR x := 1 TO 37

                  // Take the ascii value of the bucket (0 - 255), but since
                  // the dictionary page is 512, this value is multiplied by 2
                  // to get the pointer offset.
                  // the last of the valid buckets is followed by a 0.
                  nBucket := ASC( SUBSTR( cBuffer, x, 1 ) ) * 2

                  IF !EMPTY( nBucket )

                     // we found a good pointer, go to it's location in the file
                     // and read in 30 bytes.
                     nCurrPntr := nThisDictPage + nBucket
                     cBuffer2 := SPACE( 30 )
                     FSEEK( nHandle, nCurrPntr, FS_SET )
                     FREAD( nHandle, @cBuffer2, 30 )

                     // the first byte tells how long the entry is, grab it
                     // and remove it and chop the string off at the endpoint
                     cFunction := SUBSTR( cBuffer2, 2, ASC( LEFT( cBuffer2, 1 ) ) )

                     // Many entries have a ! at the end. I'm sure it means
                     // something, but I have no idea what. In any case, it
                     // gets removed here.
                     IF RIGHT( cFunction, 1 ) == '!'
                        cFunction := LEFT( cFunction, LEN( cFunction ) - 1 )
                     ENDIF

                     // now, we convert to lower case and store it in CLICK.DBF
                     click->( DBAPPEND() )
                     click->fnct := LOWER( cFunction )
                     click->srce := cFileName

                     show_out( cFunction )

                  ENDIF
               NEXT
            NEXT
         END SEQUENCE
         IF nHandle > - 1
            FCLOSE( nHandle )
         ENDIF
      NEXT
   NEXT

   // This section reads in the CLICKFNC.INI file and appends the contents
   // to the CLICK.DBF file.

   IF FILE( rootname( cDBFPath ) + 'FNC.INI' )
      aFileList := readlist( rootname( cDBFPath ) + 'FNC.INI', '@' )
      FOR x := 1 TO LEN( aFileList )
         click->( DBAPPEND() )
         equ_at := AT( '=', aFileList[ x ] )
         IF equ_at > 0
            click->fnct := LOWER( ALLTRIM( LEFT( aFileList[ x ], equ_at - 1 ) ) )
            click->srce := UPPER( ALLTRIM( SUBSTR( aFileList[ x ], equ_at + 1 ) ) )
            click->( DBCOMMIT() )
            click->( DBUNLOCK() )
            show_out( aFileList[ x ] )
         ENDIF
      NEXT
   ENDIF

   // last step is to create the index. Creating the index last creates a
   // smaller index size.

   show_in( 'Creating ' + cNSXPath + ' for ' + cDBFPath )
   INDEX ON fnct + srce TAG funct_src unique

RETURN

*+--------------------------------------------------------------------
*+
*+    Static Function findlibs()
*+
*+    Called from ( libread.prg )   1 - procedure libread()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION findlibs()

LOCAL aDrive    := {}
LOCAL aCapacity := {}
LOCAL cOutPut   := ''
LOCAL X
LOCAL nX
LOCAL Y
LOCAL nY
LOCAL nThisSize
LOCAL bOldError

   // This error block is only for continuing after DISKSPACE() returns
   // an error condition. Returning .f. causes DISKSPACE() to return 0

   bOldError := ERRORBLOCK( { | oErr | MyHandler( oErr ) } )

   // first, scan through the drives and figure out which ones are duplicates...

   FOR x := 3 TO 26

      nThisSize := DISKSPACE( x )

      IF nThisSize > 0 .AND. ASCAN( aCapacity, nThisSize ) == 0
         AADD( aDrive, CHR( x + 64 ) )
         AADD( aCapacity, nThisSize )
      ENDIF

   NEXT

   ERRORBLOCK( bOldError )

   // Then, process each drive via recursion

   nX := LEN( aDrive )
   FOR x := 1 TO nX

      aOutput := {}
      dir_recurs( aDrive[ x ] + ':' )

      nY := LEN( aOutput )
      FOR y := 1 TO nY
         IF !EMPTY( aOutput[ y ] )
            cOutput += aOutput[ y ] + ';'
         ENDIF
      NEXT

   NEXT

RETURN cOutPut

*+--------------------------------------------------------------------
*+
*+    Static Function MyHandler()
*+
*+    Called from ( libread.prg )   1 - static function findlibs()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION MyHandler( oErr )
oErr := NIL
RETURN .f.

*+--------------------------------------------------------------------
*+
*+    Static Procedure dir_recurs()
*+
*+    Called from ( libread.prg )   1 - static function findlibs()
*+                                   1 - static procedure dir_recurs()
*+
*+--------------------------------------------------------------------
*+
STATIC PROCEDURE dir_recurs( cPath )

LOCAL x
LOCAL aFiles    := DIRECTORY( cPath + '\*.*', 'D' )
LOCAL nFilCount := LEN( aFiles )

   FOR x := 1 TO nFilCount

      DO CASE
         CASE aFiles[ X, F_NAME ] == '..' .OR. aFiles[ X, F_NAME ] == '.'

            LOOP

         CASE 'D' $ aFiles[ X, F_ATTR ]

            IF ++ nLevel < nRecursion
               show_in( cPath + '\' + aFiles[ X, F_NAME ] )
               DIR_RECURS( cPath + '\' + aFiles[ X, F_NAME ] )
            ENDIF
            nLevel --

         CASE '.LIB' $ aFiles[ X, F_NAME ]

            IF ASCAN( aOutput, cPath ) == 0
               AADD( aOutput, cPath )
               SHOW_OUT( cPath )
            ENDIF

      ENDCASE

   NEXT

RETURN

*+ EOF: LIBREAD.PRG
