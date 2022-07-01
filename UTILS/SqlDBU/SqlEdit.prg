
#include "i_PropGrid.ch"

*--------------------------------------------------------*
FUNCTION SqlEdit( cTable, db )
*--------------------------------------------------------*
   LOCAL n, aResult, nId, DBUstruct := {}

   aResult := SQLITE_COLUMNS_METADATA( db, cTable )

   AEval( aResult, {| x | AAdd( DBUstruct, { x[ 1 ], x[ 2 ], x[ 4 ], x[ 5 ], x[ 3 ], x[ 8 ] } ) } )

   DEFINE WINDOW Form_Edit ;
         AT 0, 0 ;
         WIDTH 600 ;
         HEIGHT 500 ;
         TITLE 'Record Edit' ;
         CHILD ;
         NOMAXIMIZE NOSIZE

      DEFINE PROPGRID PropEdit ;
         AT 25, 20 ;
         WIDTH 550 HEIGHT 380 ;
         HEADER "Field Name", "Value" ;
         FONTCOLOR { 0, 0, 0 } INDENT 10 DATAWIDTH 400 ;
         BACKCOLOR { 240, 240, 240 } ;
         ITEMHEIGHT 25 ;
         ITEMEXPAND ;
         OKBTN USEROKPROC AddNewRec( cTable, db, DBUstruct ) APPLYBTN ;
         CANCELBTN ;
         ON CHANGEVALUE {|| SetProperty( 'Form_Edit', 'Btn_1', 'Enabled', TRUE ) } ;
         ITEMINFO

      DEFINE CATEGORY 'Record Set'

      FOR n := 1 TO Len( DBUstruct )

         IF ! DBUstruct[ n, 6 ]
            nId := 1000 + n * 10
            DO CASE
            CASE DBUstruct[ n, 2 ] == "SQLITE_TEXT"
               IF DBUstruct[ n, 5 ] = 'TEXT'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + Str( DBUstruct[ n, 3 ] )
               ELSEIF SubStr( DBUstruct[ n, 5 ], 1, 4 ) == 'CHAR'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + Str( DBUstruct[ n, 3 ] )
               ELSEIF DBUstruct[ n, 5 ] == 'DATE'
                  PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'date' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
               ELSEIF DBUstruct[ n, 5 ] == 'DATETIME'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Format: YYYY-MM-DD hh:mm:ss'
               ELSEIF DBUstruct[ n, 5 ] == 'TIME'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Format: hh:mm:ss'
               ELSEIF DBUstruct[ n, 5 ] == 'BLOB'
                  PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'file' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
               ENDIF
            CASE DBUstruct[ n, 2 ] == "SQLITE_INTEGER"
               IF DBUstruct[ n, 5 ] = 'BOOL'
                  PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'check' VALUE 'No' ITEMDATA 'No;Yes' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
               ELSE
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + Str( DBUstruct[ n, 3 ] )
               ENDIF
            CASE DBUstruct[ n, 2 ] == "SQLITE_FLOAT"
               PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + AllTrim( Str( DBUstruct[ n, 3 ] ) ) + ',' + AllTrim( Str( DBUstruct[ n, 4 ] ) )
            CASE DBUstruct[ n, 2 ] == "SQLITE_BLOB"
               PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'file' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
            CASE DBUstruct[ n, 2 ] == "SQLITE_NULL"
               DO CASE
               CASE DBUstruct[ n, 5 ] == 'TEXT'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + Str( DBUstruct[ n, 3 ] )
               CASE SubStr( DBUstruct[ n, 5 ], 1, 4 ) == 'CHAR'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + Str( DBUstruct[ n, 3 ] )
               CASE DBUstruct[ n, 5 ] == 'INTEGER'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + Str( DBUstruct[ n, 3 ] )
               CASE DBUstruct[ n, 5 ] == 'FLOAT'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Size: ' + AllTrim( Str( DBUstruct[ n, 3 ] ) ) + ',' + AllTrim( Str( DBUstruct[ n, 4 ] ) )
               CASE DBUstruct[ n, 5 ] == 'BLOB'
                  PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'file' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
               CASE DBUstruct[ n, 5 ] == 'DATE'
                  PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'date' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
               CASE DBUstruct[ n, 5 ] == 'DATETIME'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Format: YYYY-MM-DD hh:mm:ss'
               CASE DBUstruct[ n, 5 ] == 'TIME'
                  PROPERTYITEM USERFUN DBUstruct[ n, 1 ] ITEMDATA "{|| GetColumnData( '" + DBUstruct[ n, 1 ] + "', '" + DBUstruct[ n, 5 ] + "', " + Str( DBUstruct[ n, 3 ] ) + ", " + Str( DBUstruct[ n, 4 ] ) + " ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ] + CRLF + 'Format: hh:mm:ss'
               CASE DBUstruct[ n, 5 ] = 'BOOL'
                  PROPERTYITEM DBUstruct[ n, 1 ] ITEMTYPE 'check' VALUE 'No' ITEMDATA 'No;Yes' ID nId INFO "Field Type:  " + DBUstruct[ n, 2 ] + CRLF + 'Init type: ' + DBUstruct[ n, 5 ]
               ENDCASE

            ENDCASE
         ENDIF

      NEXT

      END CATEGORY

      END PROPGRID

      @ 420, 20 BUTTON btn_1 ;
         CAPTION "Add Record" ;
         ACTION {|| AddNewRec( cTable, db, DBUstruct ), Form_Edit.release } ;
         WIDTH 100 HEIGHT 24

      @ 420, 220 BUTTON btn_2 ;
         CAPTION "Exit" ;
         ACTION {|| Form_Edit.release } ;
         WIDTH 100 HEIGHT 24

   END WINDOW
   Form_Edit.Btn_1.Enabled := FALSE

   CENTER WINDOW Form_Edit
   ACTIVATE WINDOW Form_Edit

RETURN NIL

*--------------------------------------------------------*
FUNCTION GetColumnData( cName, cType, nSize, nDec )
*--------------------------------------------------------*
   LOCAL nMLines := 0
   LOCAL bCancel := {|| _HMG_DialogCancelled := .T., DoMethod( 'ImputValueBox', 'Release' ) }
   LOCAL RetVal := '', lOk := .F., cMask

   LOCAL cInputPrompt := cName, cDialogCaption := cType, cDefaultValue := ""
   IF cType == 'TEXT'
      nMLines := 150
   ENDIF

   DEFINE WINDOW ImputValueBox ;
         AT 0, 0 ;
         WIDTH 360 ;
         HEIGHT 135 + nMLines ;
         TITLE 'Type of Column: ' + cDialogCaption ;
         MODAL ;
         ON INTERACTIVECLOSE iif( lOk, NIL, Eval( bCancel ) )

      ON KEY ESCAPE ACTION Eval( bCancel )

      @ 07, 10 LABEL _Label VALUE 'Value for Column: ' + cInputPrompt AUTOSIZE

      DO CASE
      CASE cType == 'TEXT'
         @ 30, 10 EDITBOX _TextBox VALUE cDefaultValue HEIGHT 26 + nMLines WIDTH 320

      CASE SubStr( cType, 1, 4 ) == 'CHAR'
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 MAXLENGTH nSize ;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.VALUE, NIL, ImputValueBox._Ok.OnClick )

      CASE cType == 'INTEGER'
         // cMask := "'" + REPLICATE("9", nSize)+"'"
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            NUMERIC MAXLENGTH nSize ;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.VALUE, NIL, ImputValueBox._Ok.OnClick )

      CASE cType == 'FLOAT'
         cMask := "'" + Replicate( "9", nSize - nDec - 1 ) + '.' + Replicate( "9", nDec ) + "'"
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            NUMERIC INPUTMASK &cMask ;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.VALUE, NIL, ImputValueBox._Ok.OnClick )

      CASE cType == 'DATETIME'
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            INPUTMASK '9999-99-99 99:99:99' ;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.VALUE, NIL, ImputValueBox._Ok.OnClick )

      ENDCASE

      @ 67 + nMLines, 120 BUTTON _Ok ;
         CAPTION _HMG_MESSAGE[ 6 ] ;
         ACTION ( lOk := .T., _HMG_DialogCancelled := .F., ;
         RetVal := Num2Char( ImputValueBox._TextBox.VALUE, cType, nSize, nDec ), ImputValueBox.Release )

      @ 67 + nMLines, 230 BUTTON _Cancel ;
         CAPTION _HMG_MESSAGE[ 7 ] ;
         ACTION Eval( bCancel )

   END WINDOW

   ImputValueBox._TextBox.SetFocus

   CENTER WINDOW ImputValueBox
   ACTIVATE WINDOW ImputValueBox

RETURN ( RetVal )

*------------------------------------------------------------------------------*
FUNCTION Num2Char( xValue, cType, nSize, nDec )
*------------------------------------------------------------------------------*
   LOCAL cRet := xValue

   DO CASE
   CASE cType == 'INTEGER'
      cRet := Str( xValue, nSize )
   CASE cType == 'FLOAT'
      cRet := Str( xValue, nSize, nDec )
   ENDCASE

RETURN cRet

*------------------------------------------------------------------------------*
FUNCTION AddNewRec( cTable, db, DBUstruct )
*------------------------------------------------------------------------------*
   LOCAL aValue, n, nId, cQuery, buff, Stmt, cType, cData
   LOCAL aFields := {}
   LOCAL lOk := SQLITE_OK

   cQuery := "INSERT INTO " + cTable + " ("

   FOR n := 1 TO Len( DBUstruct )
      if ! DBUstruct[ n, 6 ]
         nId := 1000 + n * 10
         GET INFO PROPERTYITEM PropEdit OF Form_Edit ID nId TO aValue
         IF ValType( aValue ) != 'A'
            MsgInfo( " ERROR by read Property Info! " )
         ELSE
            IF aValue[ PGI_ID ] >= 1000
               AAdd ( aFields, { aValue[ PGI_NAME ], aValue[ PGI_VALUE ], DBUstruct[ n, 5 ] } )
            ENDIF
         ENDIF
      ENDIF
   NEXT
   FOR n := 1 TO Len( aFields )
      IF n > 1
         cQuery += ", "
      ENDIF
      cQuery += aFields[ n, 1 ]
   NEXT
   cQuery += ") VALUES ( "
   FOR n := 1 TO Len( aFields )
      IF n > 1
         cQuery += ", "
      ENDIF
      cQuery += ':' + aFields[ n, 1 ]
   NEXT
   cQuery += "); "
   stmt := sqlite3_prepare( db, cQuery )
   IF ! Empty( stmt )
      FOR n := 1 TO Len( aFields )
         cType := aFields[ n, 3 ]
         cData := aFields[ n, 2 ]
         DO CASE
         CASE SubStr( ctype, 1, 4 ) == 'CHAR' .OR. ctype == 'TEXT'
            lOk := sqlite3_bind_text( stmt, n, cData )
         CASE ctype == "INTEGER"
            lOk := sqlite3_bind_int( stmt, n, Val( cData ) )
         CASE ctype == "REAL" .OR. ctype == "FLOAT" .OR. ctype == "DOUBLE"
            lOk := sqlite3_bind_double( stmt, n, Val( cData ) )
         CASE ctype == "DATE" .OR. ctype == "DATETIME" .OR. ctype == "TIME"
            if ! Empty( cData )
               lOk := sqlite3_bind_text( stmt, n, cData )
            ENDIF
         CASE ctype == "BOOL"
            cData := if( cData == 'Yes', 1, 0 )
            lOk := sqlite3_bind_int( stmt, n, cData )
         CASE ctype == "BLOB"
            buff := sqlite3_file_to_buff( aFields[ n, 2 ] )
            lOk := sqlite3_bind_blob( stmt, n, @buff )
            buff := NIL
         ENDCASE
         IF lOk != SQLITE_OK
            EXIT
         ENDIF
      NEXT
      IF lOk == SQLITE_OK
         IF sqlite3_step( stmt ) == SQLITE_DONE
            sqlite3_clear_bindings( stmt )
            sqlite3_finalize( stmt )
            MsgInfo( " Record added to table " + cTable, "Result" )
         ENDIF
      ELSE
         sqlite3_reset( stmt )
         MsgInfo( "Error by binding record " + cQuery, 'Error' )
      ENDIF

   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION ZapTable( cTable )
*--------------------------------------------------------*
   LOCAL lRet

   // if MsgYesNo("Deleted All records in table "+cTable+" ?", "Warning")

   lRet := SqlDelete( cTable, TRUE )
   IF lRet
      MsgInfo( "All records were removed from table " + cTable, "Result" )
   ENDIF
   // endif

RETURN lRet

*--------------------------------------------------------*
FUNCTION DropTable( cTable, db )
*--------------------------------------------------------*
   LOCAL i, aTable, lRet := FALSE
   DEFAULT cTable := SqlDbuTableName

   IF MsgYesNo( "Droped Table " + cTable + " from Database ?", "Warning" )
      IF SQLITE_TABLEEXISTS( cTable, db )
         IF SQLITE_DROPTABLE( SqlDbName, cTable )
            ClearMRUList()
            aTable := SQLITE_TABLES( db )
            FOR i := 1 TO Len( aTable )
               AddMRUItem( aTable[ i ], "SeleTable()" )
            NEXT
            MsgStop( "Table " + cTable + " droped successful.", "Note" )
            lRet := TRUE
         ELSE
            MsgStop( "Can't droped " + cTable, "Error" )
         ENDIF
      ENDIF
   ENDIF

RETURN lRet
