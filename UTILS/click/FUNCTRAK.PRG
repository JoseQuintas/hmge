*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\FUNCTRAK.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Procedure init_func_text()
*+               Procedure functrak()
*+               Procedure func_call()
*+               Procedure end_func_text()
*+               Function func_text()
*+               Static Function findfunc()
*+               Static Function SubArrySrch()
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "HMG.CH"

STATIC aFuncs     := {}                                               // List of functions in each module
STATIC aThisSrc   := {}                                               // Module Name, sub function list
STATIC aFuncList  := {}                                               // The big collection of how each function gets called
STATIC aTable     := {}                                               // contains table references for the TABLE.TXT file
STATIC aIndex     := {}                                               // contains index references for the INDEX.TXT file
STATIC sFuncText  := ''                                               // contains the function header line
STATIC sModule    := ''                                               // contains the current module name
STATIC cFullPath  := ''                                               // contains a reference to the
STATIC aMyLibFunc := {}                                               // static array of table function names
STATIC aMyIndFunc := {}                                               // static array of index function names

*+--------------------------------------------------------------------
*+
*+    Procedure init_func_text()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE init_func_text( cModule )

   // called at the beginning of each file

LOCAL cMyLibFunc
LOCAL cMyIndFunc
LOCAL nElems
LOCAL x

   IF cFullPath == ''
      cFullPath := IF( FILE( 'CLICK.INI' ), 'CLICK', rootname( ft_origin() ) ) + '.INI'
      cMyLibFunc := UPPER( ProfileString( cFullPath, 'CLICK', 'MY_TABLE_FUNCTION', '' ) )
      cMyIndFunc := UPPER( ProfileString( cFullPath, 'CLICK', 'MY_INDEX_FUNCTION', '' ) )
      IF !EMPTY( cMyLibFunc )
         nElems := numtoken( cMyLibFunc, '|' )
         ASIZE( aMyLibFunc, nElems )
         FOR x := 1 TO nElems
            aMyLibFunc[ x ] := UPPER( token( cMyLibFunc, '|', x ) )
         NEXT
         // add this to the array
         AADD( aMyLibFunc, 'DBUSEAREA' )
      ENDIF
      IF !EMPTY( cMyIndFunc )
         nElems := numtoken( cMyIndFunc, '|' )
         ASIZE( aMyIndFunc, nElems )
         FOR x := 1 TO nElems
            aMyIndFunc[ x ] := UPPER( token( cMyIndFunc, '|', x ) )
         NEXT
         // add this to the array
         AADD( aMyIndFunc, 'DBCREATEIND' )
      ENDIF
   ENDIF

   sModule := cModule

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure functrak()
*+
*+    Called from ( click.prg )   1 - static function func_head()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE functrak( cFuncText )

   // Called as each function header is created
   sFuncText := cFuncText

   IF EMPTY( aThisSrc )
      aThisSrc := { sModule, {} }
   ENDIF

   AADD( aThisSrc[ 2 ], sFuncText )

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure func_call()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE func_call( aLine, aType )

   // called as each line is parsed.
LOCAL x
LOCAL nHowmany  := LEN( aType )
LOCAL nPointer
LOCAL nPointer2
LOCAL uFW       := UPPER( aLine[ 1 ] )
LOCAL cLine     := ''

   FOR x := 1 TO nHowMany
      IF aType[ x ] == 'F'
         nPointer := ASCAN( aFuncList, { | y | UPPER( y[ 1 ] ) == UPPER( aLine[ x ] ) } )
         IF EMPTY( nPointer )
            AADD( afunclist, { aLine[ x ], { { sFuncText, sModule, 1 } } } )
         ELSE
            IF ( nPointer2 := ASCAN( aFuncList[ nPointer, 2 ], { | y | y[ 1 ] == sFuncText .AND. y[ 2 ] == sModule } ) ) == 0
               AADD( afunclist[ nPointer, 2 ], { sFuncText, sModule, 1 } )
            ELSE
               aFuncList[ nPointer, 2, nPointer2, 3 ] ++
            ENDIF
         ENDIF
      ENDIF
   NEXT

   // this collects TABLE and INDEX information

   DO CASE
      CASE uFW == 'USE' .OR. SubArrySrch( aMyLibFunc, aLine )

         FOR x := 1 TO nHowMany
            cLine += aLine[ x ]
         NEXT

         nPointer := ASCAN( aTable, { | y | y[ 1 ] == sModule } )

         IF EMPTY( nPointer )
            AADD( aTable, { sModule, { { sFuncText, cLine, 1 } } } )
         ELSE
            IF ( nPointer2 := ASCAN( aTable[ nPointer, 2 ], { | y | y[ 1 ] == sFuncText .AND. UPPER( y[ 2 ] ) == UPPER( cLine ) } ) ) == 0
               AADD( aTable[ nPointer, 2 ], { sFuncText, cLine, 1 } )
            ELSE
               aTable[ nPointer, 2, nPointer2, 3 ] ++
            ENDIF
         ENDIF

      CASE uFW == 'INDEX' .OR. SubArrySrch( aMyIndFunc, aLine )

         FOR x := 1 TO nHowMany
            cLine += aLine[ x ]
         NEXT

         nPointer := ASCAN( aIndex, { | y | y[ 1 ] == sModule } )

         IF EMPTY( nPointer )
            AADD( aIndex, { sModule, { { sFuncText, cLine, 1 } } } )
         ELSE
            IF ( nPointer2 := ASCAN( aIndex[ nPointer, 2 ], { | y | y[ 1 ] == sFuncText .AND. UPPER( y[ 2 ] ) == UPPER( cLine ) } ) ) == 0
               AADD( aIndex[ nPointer, 2 ], { sFuncText, cLine, 1 } )
            ELSE
               aIndex[ nPointer, 2, nPointer2, 3 ] ++
            ENDIF
         ENDIF

   ENDCASE

RETURN

*+--------------------------------------------------------------------
*+
*+    Procedure end_func_text()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE end_func_text()

   // called at the end of each file

   IF !EMPTY( aThisSrc )
      AADD( aFuncs, aThisSrc )
      aThisSrc := {}
   ENDIF

RETURN

*+--------------------------------------------------------------------
*+
*+    Function func_text()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION func_text( aLibList, aFileList )

   // called after all files have been processed
   // Pass 4, with the purple progress meter.
LOCAL cFullPath := IF( FILE( 'CLICK.INI' ), 'CLICK', rootname( ft_origin() ) ) + '.INI'
LOCAL cOutDir   := ProfileString( cFullPath, 'CLICK', 'OUTPUT_DIRECTORY', 'CLICKOUT' )
LOCAL cSrcOut   := ProfileString( cFullPath, 'CLICK', 'SOURCE_XREF_FILE', 'SRC_CROS.TXT' )
LOCAL cFncOut   := ProfileString( cFullPath, 'CLICK', 'FUNCTION_XREF_FILE', 'FNC_CROS.TXT' )
LOCAL cTblOut   := ProfileString( cFullPath, 'CLICK', 'TABLE_XREF_FILE', 'TBL_CROS.TXT' )
LOCAL lSrcAdd   := ProfileString( cFullPath, 'CLICK', 'FUNCTION_REF_INTO_SOURCE', 'YES' ) == 'YES'
LOCAL lFncAdd   := ProfileString( cFullPath, 'CLICK', 'FUNCTION_XREF_INTO_SOURCE', 'YES' ) == 'YES'
LOCAL lTblAdd   := ProfileString( cFullPath, 'CLICK', 'TABLE_XREF_INTO_SOURCE', 'YES' ) == 'YES'
LOCAL lIndAdd   := ProfileString( cFullPath, 'CLICK', 'INDEX_XREF_INTO_SOURCE', 'YES' ) == 'YES'
LOCAL lTimeDate := ProfileString( cFullPath, 'CLICK', 'RETAIN_ORIGINAL_TIME_DATE_ON_OUTPUT_FILES', 'YES' ) == 'YES'
LOCAL cHeadDiv  := ProfileString( cFullPath, 'CLICK', 'HEAD_DIV', '²' )

LOCAL bo_Handle
LOCAL bi_Handle
   //  LOCAL CRLF         := CHR( 13 ) + CHR( 10 )
LOCAL cOutput
//LOCAL cThisOut
LOCAL v
LOCAL w
LOCAL x
LOCAL y
LOCAL z
LOCAL cFoundIn
LOCAL nV
//LOCAL nW
LOCAL nX
LOCAL nY
LOCAL cThisProg
LOCAL cLastProg
LOCAL cProg
LOCAL cThisFile
LOCAL cOutFile
LOCAL lGotHeader
LOCAL cThisLine
LOCAL cThisFunc
LOCAL spat
LOCAL nOldPcntDone
LOCAL nPcntDone    := 0
LOCAL lStatic
LOCAL lNoLibList   := EMPTY( aLibList )
LOCAL lGotIt
LOCAL cLookFor
LOCAL aLib         := {}
LOCAL aHit         := {}
LOCAL nPointer
LOCAL nPointer1
LOCAL nPointer2
LOCAL nMinPntr
LOCAL aF2F         := {}
LOCAL aTemp        := {}
LOCAL cSource, cDBFDAT                                                // jimmy

   // ------------ override ----------------*
   cSource := TRIM( GetProperty( "ClickForm", "Text_DBF", "Value" ) )
   cDBFDAT := TRIM( GetProperty( "ClickForm", "Text_Source", "Value" ) )
   cOutDir := TRIM( GetProperty( "ClickForm", "Text_Target", "Value" ) )

   IF "\\" $ cSource
      cSource := STRTRAN( cSource, "\\", "\" )
   ENDIF
   IF "\\" $ cDBFDAT
      cDBFDAT := STRTRAN( cDBFDAT, "\\", "\" )
   ENDIF
   IF "\\" $ cOutDir
      cOutDir := STRTRAN( cOutDir, "\\", "\" )
   ENDIF

   // --------------------------------------*

   IF lSrcAdd .OR. lFncAdd .OR. lTblAdd .OR. lIndAdd

      // make copy for Function calls function pass
      // aTemp := ACLONE( aFuncList )
      // nX := LEN( atemp )
      // for x := 1 to nX
      //    y := atemp[ x ]
      // next

      nV := LEN( aFilelist )
      FOR v := 1 TO nV

         cThisFile := cOutDir + '\' + aFileList[ v ]
         cOutFile := cOutDir + '\' + '$tempfil.$$$'

         ResetInfo()
         centertext( 'Current File => ' + cThisFile, 4 )

         // initialize buffered input and output

         bo_handle := bo_init( cOutFile )
         bi_handle := binit( cThisFile )

         bOpen( bi_handle )
         bo_Open( bo_handle )

         lGotHeader := .f.
         nOldPcntDone := 0
         SetProperty( "ClickForm", "ProgressBar_1", "Value", 0 )
         DO EVENTS

         DO WHILE !beof( bi_handle )

            nOldPcntDone := nPcntDone
            nPcntDone := INT( bRelative( bi_handle ) * 50 )
            IF nOldPcntDone <> nPcntDone
               SetProperty( "ClickForm", "ProgressBar_1", "Value", nPcntDone * 2 )
               DO EVENTS
            ENDIF

            cThisLine := bReadLine( bi_handle )

            IF LEFT( cThisLine, 2 ) == '*+'

               DO CASE
                  CASE LEFT( cThisLine, 27 ) == '*+    Reformatted by Click!'
                     // This inserts function data into the FILE HEADER.

                     lGotHeader := .t.

                     IF lSrcAdd
                        w := ASCAN( aFuncs, { | x | x[ 1 ] == cSource + "\" + aFileList[ v ] } )
                        IF w > 0
                           nY := LEN( aFuncs[ w, 2 ] )
                           IF nY > 0
                              FOR y := 1 TO nY
                                 IF y == 1
                                    bo_write( bo_handle, '*+    Functions: ' + aFuncs[ w, 2, y ] + CRLF )
                                 ELSE
                                    bo_write( bo_handle, '*+               ' + aFuncs[ w, 2, y ] + CRLF )
                                 ENDIF
                              NEXT
                              bo_write( bo_handle, '*+' + CRLF )
                           ENDIF
                        ENDIF
                     ENDIF

                     // This inserts table data into the FILE HEADER.

                     IF lTblAdd
                        IF ( nPointer := ASCAN( aTable, { | x | x[ 1 ] == cSource + "\" + aFileList[ v ] } ) ) > 0
                           nY := LEN( aTable[ nPointer, 2 ] )
                           IF lTblAdd .AND. nY > 0
                              FOR y := 1 TO nY
                                 IF y == 1
                                    bo_write( bo_handle, '*+       Tables: ' + aTable[ nPointer, 2, y, 2 ] + CRLF )
                                 ELSE
                                    bo_write( bo_handle, '*+               ' + aTable[ nPointer, 2, y, 2 ] + CRLF )
                                 ENDIF
                              NEXT
                              bo_write( bo_handle, '*+' + CRLF )
                           ENDIF
                        ENDIF
                     ENDIF

                     // This inserts index data into the FILE HEADER.

                     IF lIndAdd
                        IF ( nPointer := ASCAN( aIndex, { | x | x[ 1 ] == cSource + "\" + aFileList[ v ] } ) ) > 0
                           nY := LEN( aIndex[ nPointer, 2 ] )
                           IF lTblAdd .AND. nY > 0
                              FOR y := 1 TO nY
                                 IF y == 1
                                    bo_write( bo_handle, '*+      Indexes: ' + aIndex[ nPointer, 2, y, 2 ] + CRLF )
                                 ELSE
                                    bo_write( bo_handle, '*+               ' + aIndex[ nPointer, 2, y, 2 ] + CRLF )
                                 ENDIF
                              NEXT
                              bo_write( bo_handle, '*+' + CRLF )
                           ENDIF
                        ENDIF
                     ENDIF

                  CASE lFncAdd .AND. lGotHeader .AND. LEFT( cThisLine, 6 ) == '*+    '

                     // This inserts function data into the FUNCTION HEADERS

                     cThisFunc := UPPER( SUBSTR( cThisLine, 7 ) )
                     lStatic := UPPER( LEFT( cThisFunc, 4 ) ) == 'STAT'
                     spat := RAT( ' ', cThisFunc )
                     cThisFunc := SUBSTR( cThisFunc, spat + 1 )
                     cThisFunc := LEFT( cThisFunc, LEN( cThisFunc ) - 2 )

                     x := ASCAN( aFuncList, { | x | UPPER( x[ 1 ] ) == cThisFunc } )

                     IF x > 0
                        bo_write( bo_handle, cThisLine + CRLF )

                        bo_write( bo_handle, '*+' + CRLF )

                        nY := LEN( aFuncList[ x, 2 ] )
                        cLastProg := '________'
                        z := 0
                        FOR y := 1 TO nY
                           IF lStatic                                 // is the function static?

                              // Here, we are scoping the search. If this is
                              // a static function, then there could be several
                              // of the function by the same name, so this
                              // routine figures out if the function is static
                              // and then eliminates impossible calls from other
                              // modules.

                              // if these match, then the call belongs to this
                              // static function in this module

                              IF cSource + "\" + aFileList[ v ] == aFuncList[ x, 2, y, 2 ]
                                 // cThisProg := ' ( ' + PAD( LOWER( STRTRAN( aFuncList[ x, 2, y, 2 ], cSource + "\", "" ) ), 12 ) + ' ) '
                                 cThisProg := ' ( ' + LOWER( STRTRAN( aFuncList[ x, 2, y, 2 ], cSource + "\", "" ) ) + ' ) '                // Jimmy

                                 IF cThisProg <> cLastProg
                                    cProg := cThisProg
                                 ELSE
                                    cProg := SPACE( 18 )
                                 ENDIF
                                 cOutput := IF( ++ z == 1, 'Called from', SPACE( 11 ) ) + ;
                                                cProg + ;
                                                STR( aFuncList[ x, 2, y, 3 ], 3 ) + ' - ' + ;
                                                LOWER( aFuncList[ x, 2, y, 1 ] )
                                 cLastProg := cThisProg
                                 show_out( cOutput )
                                 bo_write( bo_handle, '*+    ' + cOutput + CRLF )
                              ENDIF

                           ELSE

                              // So if we are here, the function was not static.
                              // include ALL calls.

                              // cThisProg := ' ( ' + PAD( LOWER( STRTRAN( aFuncList[ x, 2, y, 2 ], cSource + "\", "" ) ), 12 ) + ' ) '
                              cThisProg := ' ( ' + LOWER( STRTRAN( aFuncList[ x, 2, y, 2 ], cSource + "\", "" ) ) + ' ) '                   // Jimmy

                              IF cThisProg <> cLastProg
                                 cProg := cThisProg
                              ELSE
                                 cProg := SPACE( 18 )
                              ENDIF
                              cOutput := IF( y == 1, 'Called from', SPACE( 11 ) ) + ;
                                             cProg + ;
                                             STR( aFuncList[ x, 2, y, 3 ], 3 ) + ' - ' + ;
                                             LOWER( aFuncList[ x, 2, y, 1 ] )
                              cLastProg := cThisProg
                              show_out( cOutput )
                              bo_write( bo_handle, '*+    ' + cOutput + CRLF )
                           ENDIF
                        NEXT
                        LOOP
                     ENDIF
               ENDCASE
            ENDIF
            bo_write( bo_handle, cThisLine + CRLF )
         ENDDO

         bclose( bi_handle )
         bo_close( bo_handle )

         IF lTimeDate                                                 // From CLICK.INI
            setfdati( cOutFile, filedate( cThisFile ), filetime( cThisFile ) )
         ENDIF

         FERASE( cThisFile )
         FRENAME( cOutFile, cThisFile )

      NEXT
   ENDIF

   IF !EMPTY( cSrcOut )

      // This creates the text file in the output directory which contains
      // the entire function reference for every module.

      // It dumps the multidimensional array to a text file in a pretty format.

      centertext( 'Current File => ' + cOutDir + '\' + cSrcOut, 4 )

      FERASE( cOutDir + '\' + cSrcOut )
      bo_Handle := bo_init( cOutDir + '\' + cSrcOut )
      bo_open( bo_Handle )

      bo_write( bo_handle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )
      bo_write( bo_handle, '*+' + CRLF )
      bo_write( bo_handle, '*+    Created by Click! on ' + nicedate( DATE() ) + ' at ' + am_pm( TIME() ) + CRLF )
      bo_write( bo_handle, '*+' + CRLF )
      bo_write( bo_handle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF + CRLF )

      show_out( 'Sorting Master Function List' )
      aFuncs := ASORT( aFuncs,,, { | x, y | UPPER( x[ 1 ] ) < UPPER( y[ 1 ] ) } )

      show_out( 'Sorting Sub Function List' )
      nX := LEN( aFuncs )
      FOR x := 1 TO nX
         show_out( aFuncs[ x, 1 ] )
         bo_write( bo_handle, aFuncs[ x, 1 ] + CRLF + CRLF )
         AEVAL( aFuncs[ x, 2 ], { | x | bo_write( bo_handle, '  ' + x + CRLF ) } )
         bo_write( bo_handle, CRLF )
      NEXT
      bo_close( bo_handle )
   ENDIF

   IF !EMPTY( cFncOut )
      // This creates the text file in the output directory which contains
      // the function to function reference for every module.

      // It dumps the multidimensional array to a text file in a pretty format.
      centertext( 'Current File => ' + cOutDir + '\' + cFncOut, 4 )

      FERASE( cOutDir + '\' + cFncOut )
      bo_Handle := bo_init( cOutDir + '\' + cFncOut )
      bo_open( bo_Handle )

      bo_write( bo_handle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )
      bo_write( bo_handle, '*+' + CRLF )
      bo_write( bo_handle, '*+    Created by Click! on ' + nicedate( DATE() ) + ' at ' + am_pm( TIME() ) + CRLF )
      bo_write( bo_handle, '*+' + CRLF )
      bo_write( bo_handle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )

      show_out( 'Sorting Called Function List' )
      aFuncList := ASORT( aFuncList,,, { | x, y | UPPER( x[ 1 ] ) < UPPER( y[ 1 ] ) } )

      nX := LEN( aFuncList )
      FOR x := 1 TO nX
         cLookFor := LOWER( aFunclist[ x, 1 ] )
         IF cLookFor == 'if'
            LOOP
         ENDIF
         cOutput := PAD( cLookFor + '()', 15 )
         cFoundIn := findfunc( ' ' + aFunclist[ x, 1 ] + '()' )
         cLookFor += ' '
         IF EMPTY( cFoundIn )
            // Not found in the internal function array
            lGotIt := .f.
            // is it in the CLICK.DBF?
            IF click->( DBSEEK( cLookFor ) )
               // if we weren't passed a .LNK file, we have no LIB list
               IF lNoLibList
                  // show them all
                  DO WHILE cLookFor $ click->fnct
                     IF LEN( cOutPut ) == 15
                        cOutput += ' in ' + TRIM( click->srce ) + CRLF
                     ELSE
                        cOutput += SPACE( 15 ) + ' or ' + TRIM( click->srce ) + CRLF
                     ENDIF
                     show_in( SPACE( 19 ) + click->srce )
                     lGotIt := .t.
                     click->( DBSKIP( 1 ) )
                  ENDDO
               ELSE
                  // aha! we do have a lib list

                  // first, find all the matches in the lib list.

                  aLib := {}
                  aHit := {}
                  nMinPntr := 9999999999
                  DO WHILE cLookFor $ click->fnct
                     IF ( nPointer := ASCAN( aLibList, { | aParm | aParm $ TRIM( click->srce ) } ) ) > 0
                        AADD( aHit, nPointer )
                        AADD( aLib, aLibList[ nPointer ] )
                        nMinPntr := MIN( nMinPntr, nPointer )
                     ENDIF
                     click->( DBSKIP( 1 ) )
                  ENDDO

                  // then, figure out which one is the first one in the current path.

                  IF LEN( aHit ) > 0
                     nPointer := ASCAN( aHit, nMinPntr )
                     cOutput += ' in ' + fileinpath( aLib[ nPointer ], 'LIB' ) + CRLF
                     show_in( SPACE( 19 ) + aLib[ nPointer ] )
                     lGotIt := .t.
                  ENDIF

               ENDIF
            ENDIF

            // never found a match???

            IF !lGotIt
               cOutput += ' <unresolved function>'
               show_in( cOutput )
               cOutput += CRLF
            ENDIF

         ELSE
            // with gull path
            cOutput += ' in ' + LOWER( cFoundIn )
            show_in( cOutput )
            cOutput += CRLF
         ENDIF

         bo_write( bo_Handle, CRLF + cOutput + CRLF )
         cLastProg := '________'

         aFuncList[ x, 2 ] := ASORT( aFuncList[ x, 2 ],,, { | x, y | UPPER( x[ 2 ] + x[ 1 ] ) < UPPER( y[ 2 ] + y[ 1 ] ) } )
         nY := LEN( aFuncList[ x, 2 ] )
         FOR y := 1 TO nY
            // cThisProg := ' ( ' + PAD( LOWER( STRTRAN( aFuncList[ x, 2, y, 2 ], cSource + "\", "" ) ), 12 ) + ' ) '
            cThisProg := ' ( ' + LOWER( STRTRAN( aFuncList[ x, 2, y, 2 ], cSource + "\", "" ) ) + ' ) '                                     // Jimmy

            IF cThisProg <> cLastProg
               cProg := cThisProg
            ELSE
               cProg := SPACE( 18 )
            ENDIF
            cOutput := IF( y == 1, '  Called from', SPACE( 13 ) ) + ;
                           cProg + ;
                           STR( aFuncList[ x, 2, y, 3 ], 3 ) + ' - ' + ;
                           LOWER( aFuncList[ x, 2, y, 1 ] )

            cLastProg := cThisProg
            show_out( cOutput )
            bo_write( bo_handle, cOutput + CRLF )
         NEXT
      NEXT
      bo_close( bo_Handle )
   ENDIF

   IF !EMPTY( cTblOut )

      centertext( 'Current File => ' + cOutDir + '\' + cTblOut, 4 )

      FERASE( cOutDir + '\' + cTBLOut )
      bo_Handle := bo_init( cOutDir + '\' + cTblOut )
      bo_open( bo_Handle )

      bo_write( bo_handle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )
      bo_write( bo_handle, '*+' + CRLF )
      bo_write( bo_handle, '*+    Created by Click! on ' + nicedate( DATE() ) + ' at ' + am_pm( TIME() ) + CRLF )
      bo_write( bo_handle, '*+' + CRLF )
      bo_write( bo_handle, '*+' + REPLICATE( cHeadDiv, 68 ) + CRLF )
      bo_write( bo_handle, CRLF )

      FOR v := 1 TO nV

         nPointer1 := ASCAN( aTable, { | x | x[ 1 ] == cSource + "\" + aFileList[ v ] } )
         nPointer2 := ASCAN( aIndex, { | x | x[ 1 ] == cSource + "\" + aFileList[ v ] } )

         IF nPointer1 > 0 .OR. nPointer2 > 0

            bo_write( bo_handle, cSource + "\" + aFileList[ v ] + CRLF + CRLF )
            show_in( cSource + "\" + aFileList[ v ] )

            IF nPointer1 > 0
               nY := LEN( aTable[ nPointer1, 2 ] )
               IF nY > 0
                  FOR y := 1 TO nY
                     IF y == 1
                        bo_write( bo_handle, '   Tables: ' + aTable[ nPointer1, 2, y, 2 ] + CRLF )
                     ELSE
                        bo_write( bo_handle, '           ' + aTable[ nPointer1, 2, y, 2 ] + CRLF )
                     ENDIF
                     show_out( aTable[ nPointer1, 2, y, 2 ] )
                  NEXT
                  bo_write( bo_handle, CRLF )
               ENDIF
            ENDIF

            IF nPointer2 > 0
               nY := LEN( aIndex[ nPointer2, 2 ] )
               IF lTblAdd .AND. nY > 0
                  FOR y := 1 TO nY
                     IF y == 1
                        bo_write( bo_handle, '  Indexes: ' + aIndex[ nPointer2, 2, y, 2 ] + CRLF )
                     ELSE
                        bo_write( bo_handle, '           ' + aIndex[ nPointer2, 2, y, 2 ] + CRLF )
                     ENDIF
                     show_out( aIndex[ nPointer2, 2, y, 2 ] )
                  NEXT
                  bo_write( bo_handle, CRLF )
               ENDIF
            ENDIF

         ENDIF

      NEXT

      bo_close( bo_Handle )

   ENDIF

RETURN ACLONE( aTable )

*+--------------------------------------------------------------------
*+
*+    Static Function findfunc()
*+
*+    Called from ( functrak.prg )   1 - function func_text()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION findfunc( cThisFunc )

LOCAL x
LOCAL nX
LOCAL y
LOCAL nY
LOCAL lRetVal  := ''
LOCAL nFuncLen
LOCAL cLookIn

   // This function finds a function reference in the master array.

   cThisFunc := UPPER( cThisFunc )
   nFuncLen := LEN( cThisFunc ) + 2

   nX := LEN( aFuncs )
   FOR x := 1 TO nX
      nY := LEN( aFuncs[ x, 2 ] )
      FOR y := 1 TO nY
         cLookIn := RIGHT( UPPER( aFuncs[ x, 2, y ] ), nFuncLen )
         IF cThisFunc $ cLookIn
            lRetVal := aFuncs[ x, 1 ]
         ENDIF
      NEXT
   NEXT

RETURN lRetVal

*+--------------------------------------------------------------------
*+
*+    Static Function SubArrySrch()
*+
*+    Called from ( functrak.prg )   2 - procedure func_call()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION SubArrySrch( aFuncs, aLine )

LOCAL x
LOCAL y
LOCAL lRetVal := .f.

   BEGIN SEQUENCE
      FOR y := 1 TO LEN( aLine )
         FOR x := 1 TO LEN( aFuncs )
            IF aFuncs[ x ] == UPPER( aLine[ y ] )
               lRetVal := .t.
               BREAK
            ENDIF
         NEXT
      NEXT
   END SEQUENCE

RETURN lRetVal

*+ EOF: FUNCTRAK.PRG
