/*
 * MySQL DBMS classes.
 * These classes try to emulate Cl*pper db*() functions on a SQL query
 *
 * Copyright 2000 Maurilio Longo <maurilio.longo@libero.it>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file LICENSE.txt.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA (or visit https://www.gnu.org/licenses/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"

#include "dbstruct.ch"

#include "mysql.ch"


// Every single row of an answer
CREATE CLASS TMySQLRow

   VAR aRow                                     // a single row of answer
   VAR aDirty                                   // array of booleans set to .T. if corresponding field of aRow has been changed
   VAR aOldValue                                // If aDirty[ n ] is .T. aOldValue[ n ] keeps a copy of changed value if aRow[ n ] is part of a primary key

   VAR aOriValue                                // Original values ( same as TMySQLtable:aOldValue )

   VAR aFieldStruct                             // type of each field
   VAR cTable                                   // Name of table containing this row, empty if TMySQLQuery returned this row

   METHOD New( aRow, aFStruct, cTableName )     // Create a new Row object

   METHOD FieldGet( cnField )                   // Same as Cl*pper ones, but FieldGet() and FieldPut() accept a string as
   METHOD FieldPut( cnField, Value )            // field identifier, not only a number
   METHOD FieldName( nNum )
   METHOD FieldPos( cFieldName )

   METHOD FieldLen( nNum )                      // Length of field N
   METHOD FieldDec( nNum, lFormat )             // How many decimals in field N
   METHOD FieldType( nNum )                     // Cl*pper type of field N

   METHOD MakePrimaryKeyWhere()                 // returns a WHERE x=y statement which uses primary key (if available)

ENDCLASS


METHOD New( aRow, aFStruct, cTableName ) CLASS TMySQLRow

   ::aRow := aRow
   ::aOriValue := AClone( aRow )  // Original values ( same as TMySQLtable:aOldValue )

   ::aFieldStruct := hb_defaultValue( aFStruct, {} )
   ::cTable := hb_defaultValue( cTableName, "" )

   ::aDirty := Array( Len( ::aRow ) )
   ::aOldValue := Array( Len( ::aRow ) )

   AFill( ::aDirty, .F. )

   RETURN Self

METHOD FieldGet( cnField ) CLASS TMySQLRow

   LOCAL nNum := iif( HB_ISSTRING( cnField ), ::FieldPos( cnField ), cnField )

   IF nNum >= 1 .AND. nNum <= Len( ::aRow )

      // Char fields are padded with spaces since a real .dbf field would be
      IF ::FieldType( nNum ) == "C"
         RETURN PadR( ::aRow[ nNum ], ::aFieldStruct[ nNum ][ MYSQL_FS_LENGTH ] )
      ELSEIF ::FieldType( nNum ) == "L"      // elch
         RETURN iif( Asc( Left( ::aRow[ nNum ], 1 ) ) == 0, .F., .T. )
      ELSE
         RETURN ::aRow[ nNum ]
      ENDIF
   ENDIF

   RETURN NIL

METHOD FieldPut( cnField, Value ) CLASS TMySQLRow

   LOCAL nNum := iif( HB_ISSTRING( cnField ), ::FieldPos( cnField ), cnField )

   IF nNum >= 1 .AND. nNum <= Len( ::aRow )

      IF StrTran( ValType( Value ), "M", "C" ) == StrTran( ValType( ::aRow[ nNum ] ), "M", "C" ) .OR. ::aRow[ nNum ] == NIL

         // if it is a char field remove trailing spaces, but not for memos
         IF HB_ISCHAR( Value )
            Value := RTrim( Value )
         ENDIF

         // Save starting value for this field
         IF ! ::aDirty[ nNum ]
            ::aOldValue[ nNum ] := ::aRow[ nNum ]
            ::aDirty[ nNum ] := .T.
         ENDIF

         ::aRow[ nNum ] := Value

         RETURN Value
      ENDIF
   ENDIF

   RETURN NIL

// Given a field name returns it's position
METHOD FieldPos( cFieldName ) CLASS TMySQLRow

   LOCAL cUpperName := Upper( cFieldName )

   RETURN AScan( ::aFieldStruct, {| aItem | Upper( aItem[ MYSQL_FS_NAME ] ) == cUpperName } )

// Returns name of field N
METHOD FieldName( nNum ) CLASS TMySQLRow
   RETURN iif( nNum >= 1 .AND. nNum <= Len( ::aFieldStruct ), ::aFieldStruct[ nNum ][ MYSQL_FS_NAME ], "" )

METHOD FieldLen( nNum ) CLASS TMySQLRow
   RETURN iif( nNum >= 1 .AND. nNum <= Len( ::aFieldStruct ), ::aFieldStruct[ nNum ][ MYSQL_FS_LENGTH ], 0 )

/* lFormat: when .T. method returns number of formatted decimal places from mysql table otherwise _SET_DECIMALS.
   lFormat is useful for copying table structure from mysql to dbf
 */
METHOD FieldDec( nNum, lFormat ) CLASS TMySQLRow

   IF nNum >= 1 .AND. nNum <= Len( ::aFieldStruct )

      IF ! hb_defaultValue( lFormat, .F. ) .AND. ;
         ( ::aFieldStruct[ nNum ][ MYSQL_FS_TYPE ] == MYSQL_TYPE_FLOAT .OR. ;
           ::aFieldStruct[ nNum ][ MYSQL_FS_TYPE ] == MYSQL_TYPE_DOUBLE )
         RETURN Set( _SET_DECIMALS )
      ELSE
         RETURN ::aFieldStruct[ nNum ][ MYSQL_FS_DECIMALS ]
      ENDIF
   ENDIF

   RETURN 0

METHOD FieldType( nNum ) CLASS TMySQLRow

   IF nNum >= 1 .AND. nNum <= Len( ::aFieldStruct )
      RETURN SQLTypeToHarb( ::aFieldStruct[ nNum ] )
   ENDIF

   RETURN "U"

// returns a WHERE x=y statement which uses primary key (if available)
METHOD MakePrimaryKeyWhere() CLASS TMySQLRow

   LOCAL fld, cWhere := "", nI

   FOR EACH fld IN ::aFieldStruct

      // search for fields part of a primary key
      IF hb_bitAnd( fld[ MYSQL_FS_FLAGS ], PRI_KEY_FLAG ) != 0 .OR. ;
         hb_bitAnd( fld[ MYSQL_FS_FLAGS ], MULTIPLE_KEY_FLAG ) != 0 .OR. ;
         hb_bitAnd( fld[ MYSQL_FS_FLAGS ], UNIQUE_KEY_FLAG ) != 0

         IF ! Empty( cWhere )
            cWhere += " AND "
         ENDIF

         nI := fld:__enumIndex()

         // if a part of a primary key has been changed, use original value
         cWhere += fld[ MYSQL_FS_NAME ] + "=" + ;
            HarbValueToSQL( iif( ::aDirty[ nI ], ::aOldValue[ nI ], ::aRow[ nI ] ) )
      ENDIF
   NEXT

   IF ! Empty( cWhere )
      cWhere := " WHERE " + cWhere
   ENDIF

   RETURN cWhere

/* --- */

// Every single query submitted to MySQL server
CREATE CLASS TMySQLQuery

   VAR nSocket                          // connection handle to MySQL server
   VAR nResultHandle                    // result handle received from MySQL

   VAR cQuery                           // copy of query that generated this object

   VAR nNumRows                         // number of rows available on answer NOTE MySQL is 0 based
   VAR nCurRow                          // I'm currently over row number

   VAR lBof
   VAR lEof

   VAR lFieldAsData                     // Use fields as object DATA. For compatibility
                                        // Names of fields can match name of TMySQLQuery/Table DATAs,
                                        // and it is dangerous. ::lFieldAsData:=.F. can fix it
   VAR aRow                             // Values of fields of current row

   VAR nNumFields                       // how many fields per row
   VAR aFieldStruct                     // type of each field, a copy is here a copy inside each row

   VAR lError                           // .T. if last operation failed

   METHOD New( nSocket, cQuery )        // New query object
   METHOD Destroy()
   METHOD End() INLINE ::Destroy()
   METHOD Refresh()                     // ReExecutes the query (cQuery) so that changes to table are visible

   METHOD GetRow( nRow )                // return Row n of answer

   METHOD Skip( nRows )                 // Same as Cl*pper ones

   METHOD Bof() INLINE ::lBof
   METHOD Eof() INLINE ::lEof
   METHOD RecNo() INLINE ::nCurRow
   METHOD LastRec() INLINE ::nNumRows
   METHOD GoTop() INLINE ::GetRow( 1 )
   METHOD GoBottom() INLINE ::GetRow( ::nNumRows )
   METHOD GoTo( nRow ) INLINE ::GetRow( nRow )

   METHOD FCount()

   METHOD NetErr() INLINE ::lError      // Returns .T. if something went wrong
   METHOD Error()                       // Returns textual description of last error and clears ::lError

   METHOD FieldName( nNum )
   METHOD FieldPos( cFieldName )
   METHOD FieldGet( cnField )

   METHOD FieldLen( nNum )              // Length of field N
   METHOD FieldDec( nNum, lFormat )     // How many decimals in field N
   METHOD FieldType( nNum )             // Cl*pper type of field N

ENDCLASS


METHOD New( nSocket, cQuery ) CLASS TMySQLQuery

   LOCAL nI

   ::nSocket := nSocket
   ::cQuery := cQuery

   ::lError := .F.
   ::aFieldStruct := {}
   ::nCurRow := 1
   ::nResultHandle := NIL
   ::nNumFields := 0
   ::nNumRows := 0
   ::lBof := .T.
   ::lEof := .T.

   ::lFieldAsData := .T.     // Use fields as object DATA. For compatibility
   ::aRow := {}              // Values of fields of current row

   IF mysql_query( nSocket, cQuery ) == 0

      // save result set
      IF ! Empty( ::nResultHandle := mysql_store_result( nSocket ) )

         ::nNumRows := mysql_num_rows( ::nResultHandle )
         ::nNumFields := mysql_num_fields( ::nResultHandle )
         ::aRow := Array( ::nNumFields )

         FOR nI := 1 TO ::nNumFields
            AAdd( ::aFieldStruct, mysql_fetch_field( ::nResultHandle ) )
            IF ::lFieldAsData
               __objAddData( Self, ::aFieldStruct[ nI ][ MYSQL_FS_NAME ] )
            ENDIF
         NEXT

         ::getRow( ::nCurRow )
      ELSE
         ::nResultHandle := NIL
      ENDIF
   ELSE
      ::lError := .T.
   ENDIF

   RETURN Self

METHOD Refresh() CLASS TMySQLQuery

   // free present result handle
   ::nResultHandle := NIL

   ::lError := .F.

   IF mysql_query( ::nSocket, ::cQuery ) == 0

      // save result set
      ::nResultHandle := mysql_store_result( ::nSocket )
      ::nNumRows := mysql_num_rows( ::nResultHandle )

      // NOTE: I presume that number of fields doesn't change (that is nobody alters this table) between
      // successive refreshes of the same

      // But row number could very well change
      IF ::nCurRow > ::nNumRows
         ::nCurRow := ::nNumRows
      ENDIF

      ::getRow( ::nCurRow )

   ELSE
#if 0
      ::aFieldStruct := {}
      ::nResultHandle := NIL
      ::nNumFields := 0
      ::nNumRows := 0
#endif
      ::lError := .T.

   ENDIF

   RETURN ! ::lError

METHOD PROCEDURE Skip( nRows ) CLASS TMySQLQuery

   LOCAL lBof

   // NOTE: MySQL row count starts from 0
   hb_default( @nRows, 1 )

   ::lBof := ( ::LastRec() == 0 )

   IF nRows == 0
      // No move

   ELSEIF nRows < 0
      // Negative movement
      IF ( ::RecNo() + nRows ) < 1
         nRows := - ::RecNo() + 1
         // Cl*pper: only SKIP movement can set Bof() to .T.
         ::lBof := .T.  // Try to skip before first record
      ENDIF
   ELSE
      // positive movement
      IF ( ::RecNo() + nRows ) > ::LastRec()
         nRows := ::LastRec() - ::RecNo() + 1
      ENDIF
   ENDIF

   ::nCurRow := ::nCurRow + nRows

   // Maintain ::bof() true until next movement
   // Cl*pper: only SKIP movement can set Bof() to .T.
   lBof := ::Bof()

   // mysql_data_seek( ::nResultHandle, ::nCurRow - 1 )
   ::getRow( ::nCurrow )

   IF lBof
      ::lBof := .T.
   ENDIF

   RETURN

// Get row n of a query and return it as a TMySQLRow object
METHOD GetRow( nRow ) CLASS TMySQLQuery

   LOCAL oRow, row, fld

   IF ::nResultHandle != NIL

      IF ! HB_ISNUMERIC( nRow )
         nRow := ::nCurRow
      ENDIF

      ::lBof := ( ::LastRec() == 0 )

      IF nRow < 1 .OR. nRow > ::LastRec()  // Out of range
         // Equal to Cl*pper behaviour
         nRow := ::LastRec() + 1
         ::nCurRow := ::LastRec() + 1
      ENDIF

      IF nRow >= 1 .AND. nRow <= ::nNumRows
         mysql_data_seek( ::nResultHandle, nRow - 1 )  // NOTE: row count starts from 0
         ::nCurRow := nRow
      ENDIF

      ::lEof := ( ::RecNo() > ::LastRec() )

      IF ::Eof()
         // Phantom record with empty fields
         ::aRow := Array( Len( ::aFieldStruct ) )
         AFill( ::aRow, "" )
      ELSE
         ::aRow := mysql_fetch_row( ::nResultHandle )
      ENDIF

      IF ::aRow != NIL

         // Convert answer from text field to correct Cl*pper types
         FOR EACH row, fld IN ::aRow, ::aFieldStruct

            SWITCH fld[ MYSQL_FS_TYPE ]
            CASE MYSQL_TYPE_BLOB  // Memo field
            CASE MYSQL_TYPE_STRING
            CASE MYSQL_TYPE_VAR_STRING  // Char field
               // ; do nothing
               EXIT

            CASE MYSQL_TYPE_TINY
            CASE MYSQL_TYPE_SHORT
            CASE MYSQL_TYPE_LONG
            CASE MYSQL_TYPE_LONGLONG
            CASE MYSQL_TYPE_INT24
            CASE MYSQL_TYPE_NEWDECIMAL
            CASE MYSQL_TYPE_DOUBLE
            CASE MYSQL_TYPE_FLOAT
               row := iif( row == NIL, 0, Val( row ) )
               EXIT

            CASE MYSQL_TYPE_DATE
               row := iif( row == NIL, hb_SToD(), hb_CToD( row, "yyyy-mm-dd" ) )
               EXIT

            CASE MYSQL_TYPE_DATETIME
            CASE MYSQL_TYPE_TIMESTAMP
               row := iif( row == NIL, hb_SToT(), hb_CToT( row, "yyyy-mm-dd", "hh:mm:ss" ) )
               EXIT

            OTHERWISE
#if 0
               ? "Unrecognized type from SQL Server Field: " + hb_ntos( fld:__enumIndex() ) + " is type " + hb_ntos( fld[ MYSQL_FS_TYPE ] )
#endif
            ENDSWITCH

            IF ::lFieldAsData
               __objSetValueList( Self, { { fld[ MYSQL_FS_NAME ], row } } )
            ENDIF
         NEXT

         oRow := TMySQLRow():New( ::aRow, ::aFieldStruct )
      ENDIF
   ENDIF

   RETURN iif( ::aRow == NIL, NIL, oRow )

// Free result handle and associated resources
METHOD Destroy() CLASS TMySQLQuery

   ::nResultHandle := NIL

   RETURN Self

METHOD FCount() CLASS TMySQLQuery
   RETURN ::nNumFields

METHOD Error() CLASS TMySQLQuery

   ::lError := .F.

   RETURN mysql_error( ::nSocket )

// Given a field name returns it's position
METHOD FieldPos( cFieldName ) CLASS TMySQLQuery

   LOCAL cUpperName := Upper( cFieldName )

   RETURN AScan( ::aFieldStruct, {| aItem | Upper( aItem[ MYSQL_FS_NAME ] ) == cUpperName } )

// Returns name of field N
METHOD FieldName( nNum ) CLASS TMySQLQuery

   IF nNum >= 1 .AND. nNum <= Len( ::aFieldStruct )
      RETURN ::aFieldStruct[ nNum ][ MYSQL_FS_NAME ]
   ENDIF

   RETURN ""

METHOD FieldGet( cnField ) CLASS TMySQLQuery

   LOCAL nNum := iif( HB_ISSTRING( cnField ), ::FieldPos( cnField ), cnField )
   LOCAL Value

   IF nNum >= 1 .AND. nNum <= ::nNumfields
      Value := ::aRow[ nNum ]

      // Char fields are padded with spaces since a real .dbf field would be
      IF ::FieldType( nNum ) == "C"
         RETURN PadR( Value, ::aFieldStruct[ nNum ][ MYSQL_FS_LENGTH ] )
      ELSE
         RETURN Value
      ENDIF
   ENDIF

   RETURN NIL

METHOD FieldLen( nNum ) CLASS TMySQLQuery

   IF nNum >= 1 .AND. nNum <= Len( ::aFieldStruct )
      RETURN ::aFieldStruct[ nNum ][ MYSQL_FS_LENGTH ]
   ENDIF

   RETURN 0

/* lFormat: when .T. method returns number of formatted decimal places from mysql table otherwise _SET_DECIMALS.
   lFormat is useful for copying table structure from mysql to dbf */
METHOD FieldDec( nNum, lFormat ) CLASS TMySQLQuery

   IF nNum >= 1 .AND. nNum <= Len( ::aFieldStruct )
      IF ! hb_defaultValue( lFormat, .F. ) .AND. ;
         ( ::aFieldStruct[ nNum ][ MYSQL_FS_TYPE ] == MYSQL_TYPE_FLOAT .OR. ;
           ::aFieldStruct[ nNum ][ MYSQL_FS_TYPE ] == MYSQL_TYPE_DOUBLE )
         RETURN Set( _SET_DECIMALS )
      ELSE
         RETURN ::aFieldStruct[ nNum ][ MYSQL_FS_DECIMALS ]
      ENDIF
   ENDIF

   RETURN 0

METHOD FieldType( nNum ) CLASS TMySQLQuery

   IF nNum >= 1 .AND. nNum <= Len( ::aFieldStruct )
      RETURN SQLTypeToHarb( ::aFieldStruct[ nNum ] )
   ENDIF

   RETURN "U"

/* --- */

// A Table is a query without joins; this way I can Insert() e Delete() rows.
// NOTE: it's always a SELECT result, so it will contain a full table only if
//       SELECT * FROM ... was issued
CREATE CLASS TMySQLTable INHERIT TMySQLQuery

   VAR cTable                                       // name of table
   VAR aOldValue                                    //  keeps a copy of old value

   METHOD New( nSocket, cQuery, cTableName )
   METHOD GetRow( nRow )
   METHOD Skip( nRow )
   METHOD GoTop() INLINE ::GetRow( 1 )
   METHOD GoBottom() INLINE ::GetRow( ::nNumRows )
   METHOD GoTo( nRow ) INLINE ::GetRow( nRow )

   METHOD Update( oRow, lOldRecord, lRefresh )      // Gets an oRow and updates changed fields

   METHOD Save() INLINE ::Update()

   METHOD Delete( oRow, lOldRecord, lRefresh )      // Deletes passed row from table
   METHOD Append( oRow, lRefresh )                  // Inserts passed row into table
   METHOD GetBlankRow( lSetValues )                 // Returns an empty row with all available fields empty
   METHOD SetBlankRow() INLINE ::GetBlankRow( .T. ) // Compatibility

   METHOD Blank() INLINE ::GetBlankRow()
   METHOD FieldPut( cnField, Value )                // field identifier, not only a number
   METHOD Refresh()
   METHOD MakePrimaryKeyWhere()                     // returns a WHERE x=y statement which uses primary key (if available)

ENDCLASS


METHOD New( nSocket, cQuery, cTableName ) CLASS TMySQLTable

   LOCAL i

   ::super:New( nSocket, AllTrim( cQuery ) )

   ::cTable := Lower( cTableName )
   ::aOldValue := {}

   FOR i := 1 TO ::nNumFields
      AAdd( ::aOldValue, ::FieldGet( i ) )
   NEXT

   RETURN Self

METHOD GetRow( nRow ) CLASS TMySQLTable

   LOCAL oRow := ::super:GetRow( nRow ), i

   IF oRow != NIL
      oRow:cTable := ::cTable
   ENDIF

   ::aOldvalue := Array( ::nNumFields )
   FOR i := 1 TO ::nNumFields
      ::aOldValue[ i ] := ::FieldGet( i )
   NEXT

   RETURN oRow

METHOD PROCEDURE Skip( nRow ) CLASS TMySQLTable

   LOCAL i

   ::super:skip( nRow )

   FOR i := 1 TO ::nNumFields
      ::aOldValue[ i ] := ::FieldGet( i )
   NEXT

   RETURN

/* Creates an update query for changed fields and submits it to server */
METHOD Update( oRow, lOldRecord, lRefresh ) CLASS TMySQLTable

   LOCAL cUpdateQuery := "UPDATE " + ::cTable + " SET "
   LOCAL i

   LOCAL ni, cWhere := " WHERE "

   hb_default( @lOldRecord, .F. )
   // Too many ::refresh() can slow some processes, so we can deactivate it by parameter
   hb_default( @lRefresh, .T. )

   ::lError := .F.

   IF oRow == NIL // default Current row

      FOR i := 1 TO  ::nNumFields
         IF ! ::aOldValue[ i ] == ::FieldGet( i )
            cUpdateQuery += ::aFieldStruct[ i ][ MYSQL_FS_NAME ] + "=" + HarbValueToSQL( ::FieldGet( i ) ) + ","
         ENDIF
      NEXT

      // no Change
      IF Right( cUpdateQuery, 4 ) == "SET "
         RETURN ! ::lError
      ENDIF

      // remove last comma
      cUpdateQuery := hb_StrShrink( cUpdateQuery )

      IF lOldRecord
         // based in matching of ALL fields of old record
         // WARNING: if there are more than one record of ALL fields matching, all of those records will be changed

         FOR nI := 1 TO Len( ::aFieldStruct )
            cWhere += ;
               ::aFieldStruct[ nI ][ MYSQL_FS_NAME ] + "=" + ;
               HarbValueToSQL( ::aOldValue[ nI ] ) + ;
               " AND "
         NEXT
         // remove last " AND "
         cWhere := hb_StrShrink( cWhere, Len( " AND " ) )
         cUpdateQuery += cWhere

      ELSE
         // MakePrimaryKeyWhere is based in fields part of a primary key
         cUpdateQuery += ::MakePrimaryKeyWhere()
      ENDIF

      IF mysql_query( ::nSocket, cUpdateQuery ) == 0
         // Cl*pper maintain same record pointer

         // After refresh(), position of current record is often unpredictable
         IF lRefresh
            ::refresh()
         ELSE
            FOR i := 1 TO ::nNumFields
               ::aOldValue[ i ] := ::FieldGet( i )
            NEXT
         ENDIF
      ELSE
         ::lError := .T.
      ENDIF
   ELSE
      IF oRow:cTable == ::cTable

         FOR i := 1 TO Len( oRow:aRow )
            IF oRow:aDirty[ i ]
               cUpdateQuery += ;
                  oRow:aFieldStruct[ i ][ MYSQL_FS_NAME ] + "=" + ;
                  HarbValueToSQL( oRow:aRow[ i ] ) + ","
            ENDIF
         NEXT

         // remove last comma
         cUpdateQuery := hb_StrShrink( cUpdateQuery )

         IF lOldRecord
            // based in matching of ALL fields of old record
            // WARNING: if there are more than one record of ALL fields matching, all of those records will be changed

            FOR nI := 1 TO Len( oRow:aFieldStruct )
               cWhere += ;
                  oRow:aFieldStruct[ nI ][ MYSQL_FS_NAME ] + "=" + ;
                  HarbValueToSQL( oRow:aOriValue[ nI ] ) + ;
                  " AND "
            NEXT
            // remove last " AND "
            cWhere := hb_StrShrink( cWhere, Len( " AND " ) )
            cUpdateQuery += cWhere

         ELSE
            // MakePrimaryKeyWhere is based in fields part of a primary key
            cUpdateQuery += oRow:MakePrimaryKeyWhere()
         ENDIF

         IF mysql_query( ::nSocket, cUpdateQuery ) == 0

            // All values are committed
            AFill( oRow:aDirty, .F. )
            AFill( oRow:aOldValue, NIL )

            oRow:aOriValue := AClone( oRow:aRow )

            // Cl*pper maintain same record pointer

            // After refresh(), position of current record is often unpredictable
            IF lRefresh
               ::refresh()
            ENDIF
         ELSE
            ::lError := .T.
         ENDIF
      ENDIF
   ENDIF

   RETURN ! ::lError

METHOD Delete( oRow, lOldRecord, lRefresh ) CLASS TMySQLTable

   LOCAL cDeleteQuery := "DELETE FROM " + ::cTable, i

   LOCAL ni, cWhere := " WHERE "

   hb_default( @lOldRecord, .F. )
   // Too many ::refresh() can slow some processes, so we can deactivate it by parameter
   hb_default( @lRefresh, .T. )

   // is this a row of this table ?
   IF oRow == NIL

      IF lOldRecord
         // based in matching of ALL fields of old record
         // WARNING: if there are more than one record of ALL fields matching, all of those records will be changed

         FOR nI := 1 TO Len( ::aFieldStruct )
            cWhere += ;
               ::aFieldStruct[ nI ][ MYSQL_FS_NAME ] + "=" + ;
                HarbValueToSQL( ::aOldValue[ nI ] ) + ;  // use original value
                " AND "
         NEXT
         // remove last " AND "
         cWhere := hb_StrShrink( cWhere, Len( " AND " ) )
         cDeleteQuery += cWhere
      ELSE
         // MakePrimaryKeyWhere is based in fields part of a primary key
         cDeleteQuery += ::MakePrimaryKeyWhere()
      ENDIF

      IF mysql_query( ::nSocket, cDeleteQuery ) == 0
         ::lError := .F.
         // Cl*pper maintain same record pointer

         // After refresh(), position of current record is often unpredictable
         IF lRefresh
            ::refresh()
         ELSE
            FOR i := 1 TO ::nNumFields
               ::aOldValue[ i ] := ::FieldGet( i )
            NEXT
         ENDIF
      ELSE
         ::lError := .T.
      ENDIF
   ELSE

      IF oRow:cTable == ::cTable

         IF lOldRecord
            // based in matching of ALL fields of old record
            // WARNING: if there are more than one record of ALL fields matching, all of those records will be changed

            FOR nI := 1 TO Len( oRow:aFieldStruct )
               cWhere += ;
                  oRow:aFieldStruct[ nI ][ MYSQL_FS_NAME ] + "=" + ;
                  HarbValueToSQL( oRow:aOriValue[ nI ] ) + ;  // use original value
                  " AND "
            NEXT
            // remove last " AND "
            cWhere := hb_StrShrink( cWhere, Len( " AND " ) )
            cDeleteQuery += cWhere

         ELSE
            // MakePrimaryKeyWhere is based in fields part of a primary key
            cDeleteQuery += oRow:MakePrimaryKeyWhere()
         ENDIF

         IF mysql_query( ::nSocket, cDeleteQuery ) == 0
            ::lError := .F.

            // After refresh(), position of current record is often unpredictable
            IF lRefresh
               ::refresh()
            ENDIF
         ELSE
            ::lError := .T.
         ENDIF
      ENDIF
   ENDIF

   RETURN ! ::lError

// Adds a row with values passed into oRow
METHOD Append( oRow, lRefresh ) CLASS TMySQLTable

   LOCAL cInsertQuery := "INSERT INTO " + ::cTable + " ("
   LOCAL i

   // Too many ::refresh() can slow some processes, so we can deactivate it by parameter
   hb_default( @lRefresh, .T. )

   IF oRow == NIL // default Current row

      // field names
      FOR i := 1 TO ::nNumFields
         IF ::aFieldStruct[ i ][ MYSQL_FS_FLAGS ] != AUTO_INCREMENT_FLAG
            cInsertQuery += ::aFieldStruct[ i ][ MYSQL_FS_NAME ] + ","
         ENDIF
      NEXT
      // remove last comma from list
      cInsertQuery := hb_StrShrink( cInsertQuery ) + ") VALUES ("

      // field values
      FOR i := 1 TO ::nNumFields
         IF ::aFieldStruct[ i ][ MYSQL_FS_FLAGS ] != AUTO_INCREMENT_FLAG
            cInsertQuery += HarbValueToSQL( ::FieldGet( i ) ) + ","
         ENDIF
      NEXT

      // remove last comma from list of values and add closing parenthesis
      cInsertQuery := hb_StrShrink( cInsertQuery ) + ")"

      IF mysql_query( ::nSocket, cInsertQuery ) == 0
         ::lError := .F.
         // Cl*pper add record at end
         ::nCurRow := ::LastRec() + 1

         // After refresh(), position of current record is often unpredictable
         IF lRefresh
            ::refresh()
         ELSE
#if 0
            /* was same values from FieldGet( i ) ! */
            FOR i := 1 TO ::nNumFields
               ::aOldValue[ i ] := ::FieldGet( i )
            NEXT
#endif
         ENDIF

         RETURN .T.
      ELSE
         ::lError := .T.
      ENDIF
   ELSE

      IF oRow:cTable == ::cTable

         // field names
         FOR i := 1 TO Len( oRow:aRow )
            IF oRow:aFieldStruct[ i ][ MYSQL_FS_FLAGS ] != AUTO_INCREMENT_FLAG
               cInsertQuery += oRow:aFieldStruct[ i ][ MYSQL_FS_NAME ] + ","
            ENDIF
         NEXT
         // remove last comma from list
         cInsertQuery := hb_StrShrink( cInsertQuery ) + ") VALUES ("

         // field values
         FOR i := 1 TO Len( oRow:aRow )
            IF oRow:aFieldStruct[ i ][ MYSQL_FS_FLAGS ] != AUTO_INCREMENT_FLAG
               cInsertQuery += HarbValueToSQL( oRow:aRow[ i ] ) + ","
            ENDIF
         NEXT

         // remove last comma from list of values and add closing parenthesis
         cInsertQuery := hb_StrShrink( cInsertQuery ) + ")"

         IF mysql_query( ::nSocket, cInsertQuery ) == 0
            ::lError := .F.

            // All values are committed
            AFill( oRow:aDirty, .F. )
            AFill( oRow:aOldValue, NIL )

            oRow:aOriValue := AClone( oRow:aRow )

            // Cl*pper add record at end
            ::nCurRow := ::LastRec() + 1

            // After refresh(), position of current record is often unpredictable
            IF lRefresh
               ::refresh()
            ENDIF

            RETURN .T.
         ELSE
            ::lError := .T.
         ENDIF
      ENDIF
   ENDIF

   RETURN .F.

METHOD GetBlankRow( lSetValues ) CLASS TMySQLTable

   LOCAL i
   LOCAL aRow := Array( ::nNumFields )

   // crate an array of empty fields
   FOR i := 1 TO ::nNumFields

      SWITCH ::aFieldStruct[ i ][ MYSQL_FS_TYPE ]
      CASE MYSQL_TYPE_STRING
      CASE MYSQL_TYPE_TINY_BLOB
      CASE MYSQL_TYPE_VARCHAR
      CASE MYSQL_TYPE_VAR_STRING
      CASE MYSQL_TYPE_BLOB
      CASE MYSQL_TYPE_MEDIUM_BLOB
      CASE MYSQL_TYPE_LONG_BLOB
         aRow[ i ] := ""
         EXIT

      CASE MYSQL_TYPE_SHORT
      CASE MYSQL_TYPE_TINY
      CASE MYSQL_TYPE_INT24
      CASE MYSQL_TYPE_LONG
      CASE MYSQL_TYPE_LONGLONG
      CASE MYSQL_TYPE_NEWDECIMAL
         aRow[ i ] := 0
         EXIT

      CASE MYSQL_TYPE_FLOAT
      CASE MYSQL_TYPE_DOUBLE
         aRow[ i ] := 0.0
         EXIT

      CASE MYSQL_TYPE_DATE
         aRow[ i ] := hb_SToD()
         EXIT

      CASE MYSQL_TYPE_TIME
      CASE MYSQL_TYPE_DATETIME
      CASE MYSQL_TYPE_TIMESTAMP
         aRow[ i ] := hb_SToT()
         EXIT

      CASE MYSQL_TYPE_BIT
         aRow[ i ] := .F.
         EXIT

      OTHERWISE
         aRow[ i ] := NIL

      ENDSWITCH
   NEXT

   // It is not current row, so do not change it
   IF hb_defaultValue( lSetValues, .F. )  // Assign values as current row values
      FOR i := 1 TO ::nNumFields
         ::FieldPut( i, aRow[ i ] )
         ::aOldValue[ i ] := aRow[ i ]
      NEXT
   ENDIF

   RETURN TMySQLRow():New( aRow, ::aFieldStruct, ::cTable )

METHOD FieldPut( cnField, Value ) CLASS TMySQLTable

   LOCAL nNum := iif( HB_ISSTRING( cnField ), ::FieldPos( cnField ), cnField )

   IF nNum >= 1 .AND. nNum <= ::nNumFields

      IF ValType( Value ) == ValType( ::aRow[ nNum ] ) .OR. ::aRow[ nNum ] == NIL

         // if it is a char field remove trailing spaces
         IF HB_ISSTRING( Value )
            Value := RTrim( Value )
         ENDIF

         ::aRow[ nNum ] := Value
         IF ::lFieldAsData
            __objSetValueList( Self, { { ::aFieldStruct[ nNum ][ MYSQL_FS_NAME ], Value } } )
         ENDIF

         RETURN Value
      ENDIF
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS TMySQLTABLE

   // free present result handle
   ::nResultHandle := NIL

   ::lError := .F.

   IF mysql_query( ::nSocket, ::cQuery ) == 0

      // save result set
      ::nResultHandle := mysql_store_result( ::nSocket )
      ::nNumRows := mysql_num_rows( ::nResultHandle )

      // NOTE: I presume that number of fields doesn't change (that is nobody alters this table) between
      // successive refreshes of the same

      // But row number could very well change
      IF ::nCurRow > ::nNumRows
         ::nCurRow := ::nNumRows
      ENDIF

      ::getRow( ::nCurRow )

   ELSE
#if 0
      ::aFieldStruct := {}
      ::nResultHandle := NIL
      ::nNumFields := 0
      ::nNumRows := 0

      ::aOldValue := {}
#endif
      ::lError := .T.
   ENDIF

   RETURN ! ::lError

// returns a WHERE x=y statement which uses primary key (if available)
METHOD MakePrimaryKeyWhere() CLASS TMySQLTable

   LOCAL fld, cWhere := ""

   FOR EACH fld IN ::aFieldStruct

      // search for fields part of a primary key
      IF hb_bitAnd( fld[ MYSQL_FS_FLAGS ], PRI_KEY_FLAG ) != 0 .OR. ;
         hb_bitAnd( fld[ MYSQL_FS_FLAGS ], MULTIPLE_KEY_FLAG ) != 0 .OR. ;
         hb_bitAnd( fld[ MYSQL_FS_FLAGS ], UNIQUE_KEY_FLAG ) != 0

         IF ! Empty( cWhere )
            cWhere += " AND "
         ENDIF

         cWhere += fld[ MYSQL_FS_NAME ] + "=" + HarbValueToSQL( ::aOldValue[ fld:__enumIndex() ] )
      ENDIF
   NEXT

   IF ! Empty( cWhere )
      cWhere := " WHERE " + cWhere
   ENDIF

   RETURN cWhere

/* --- */

// Every available MySQL server
CREATE CLASS TMySQLServer

   VAR nSocket                                             // connection handle to server (currently pointer to a MYSQL structure)
   VAR cServer                                             // server name
   VAR nPort                                               // server port
   VAR cDBName                                             // Selected DB
   VAR cUser                                               // user accessing db
   VAR cPassword                                           // his/her password
   VAR lError                                              // .T. if occurred an error
   VAR cCreateQuery

   METHOD New( cServer, cUser, cPassword, nPort, nFlags, hSSL )  // Opens connection to a server, returns a server object
   METHOD Destroy()                                        // Closes connection to server

   METHOD SelectDB( cDBName )                              // Which data base I will use for subsequent queries

   METHOD CreateTable( cTable, aStruct, cPrimaryKey, cUniqueKey, cAuto )  // Create new table using the same syntax of dbCreate()
   METHOD DeleteTable( cTable )                            // delete table
   METHOD TableStruct( cTable )                            // returns a structure array compatible with Cl*pper's dbStruct() ones
   METHOD CreateIndex( cName, cTable, aFNames, lUnique )   // Create an index (unique) on field name(s) passed as an array of strings aFNames
   METHOD DeleteIndex( cName, cTable )                     // Delete index cName from cTable

   METHOD ListDBs()                                        // returns an array with list of data bases available
   METHOD ListTables()                                     // returns an array with list of available tables in current database
   METHOD TableExists( cTable )

   METHOD Query( cQuery )                                  // Gets a textual query and returns a TMySQLQuery or TMySQLTable object

   METHOD NetErr() INLINE ::lError                         // Returns .T. if something went wrong
   METHOD Error()                                          // Returns textual description of last error
   METHOD CreateDatabase( cDataBase )                      // Create an New Mysql Database
   METHOD DeleteDatabase( cDataBase )                      // Delete database

   METHOD sql_commit()                                     // Commits transaction [mitja]
   METHOD sql_rollback()                                   // Rollbacks transaction [mitja]
   METHOD sql_version()                                    // server version as numeric [mitja]
   METHOD ssl_cipher()                                     // check if SSL connection is established [mitja]

ENDCLASS


METHOD New( cServer, cUser, cPassword, nPort, nFlags, hSSL ) CLASS TMySQLServer

   ::cServer := cServer
   ::nPort := nPort
   ::cUser := cUser
   ::cPassword := cPassword
   ::nSocket := mysql_real_connect( cServer, cUser, cPassword, nPort, nFlags, hSSL )
   ::lError := Empty( ::nSocket )

   RETURN Self

METHOD Destroy() CLASS TMySQLServer

   ::nSocket := NIL

   RETURN Self

METHOD sql_commit() CLASS TMySQLServer
   RETURN mysql_commit( ::nSocket ) == 0

METHOD sql_rollback() CLASS TMySQLServer
   RETURN mysql_rollback( ::nSocket ) == 0

METHOD sql_version() CLASS TMySQLServer
   RETURN mysql_get_server_version( ::nSocket )

METHOD ssl_cipher() CLASS TMySQLServer
   RETURN mysql_get_ssl_cipher( ::nSocket )

METHOD SelectDB( cDBName ) CLASS TMySQLServer

   IF mysql_select_db( ::nSocket, cDBName ) == 0  /* Database exists */
      ::cDBName := cDBName
      RETURN ::lError := .F.
   ENDIF

   ::cDBName := ""

   RETURN ::lError := .T.

METHOD CreateDatabase( cDataBase ) CLASS TMySQLServer
   RETURN mysql_query( ::nSocket, "CREATE DATABASE " + Lower( cDatabase ) ) == 0

// NOTE: OS/2 port of MySQL is picky about table names, that is if you create a table with
// an upper case name you cannot alter it (for example) using a lower case name, this violates
// OS/2 case insensibility about names
METHOD CreateTable( cTable, aStruct, cPrimaryKey, cUniqueKey, cAuto ) CLASS TMySQLServer

   /* NOTE: all table names are created with lower case */

   LOCAL fld

   // returns NOT NULL if extended structure has DBS_NOTNULL field to true
   LOCAL cNN := {| aArr | iif( Len( aArr ) > DBS_DEC, iif( aArr[ DBS_NOTNULL ], " NOT NULL ", "" ), "" ) }

   ::cCreateQuery := "CREATE TABLE " + Lower( cTable ) + " ("

   FOR EACH fld IN aStruct

      SWITCH Left( fld[ DBS_TYPE ], 1 )
      CASE "C"
         ::cCreateQuery += fld[ DBS_NAME ] + " char(" + hb_ntos( fld[ DBS_LEN ] ) + ")" + Eval( cNN, fld ) + iif( fld[ DBS_NAME ] == cPrimaryKey, " NOT NULL ", "" ) + ","
         EXIT

      CASE "M"
         ::cCreateQuery += fld[ DBS_NAME ] + " text" + Eval( cNN, fld ) + ","
         EXIT

      CASE "N"
#if 0
         IF fld[ DBS_DEC ] == 0
            ::cCreateQuery += fld[ DBS_NAME ] + " int(" + hb_ntos( fld[ DBS_LEN ] ) + ")" + Eval( cNN, fld ) + iif( fld[ DBS_NAME ] == cPrimaryKey, " NOT NULL ", "" ) + iif( fld[ DBS_NAME ] == cAuto, " auto_increment ", "" ) + ","
         ELSE
            ::cCreateQuery += fld[ DBS_NAME ] + " real(" + hb_ntos( fld[ DBS_LEN ] ) + "," + hb_ntos( fld[ DBS_DEC ] ) + ")" + Eval( cNN, fld ) + ","
         ENDIF
#endif
         IF fld[ DBS_DEC ] == 0 .AND. fld[ DBS_LEN ] <= 18
            DO CASE
            CASE fld[ DBS_LEN ] <= 2
               ::cCreateQuery += fld[ DBS_NAME ] + " tinyint(" + hb_ntos( fld[ DBS_LEN ] ) + ")"
            CASE fld[ DBS_LEN ] <= 4
               ::cCreateQuery += fld[ DBS_NAME ] + " smallint(" + hb_ntos( fld[ DBS_LEN ] ) + ")"
            CASE fld[ DBS_LEN ] <= 6
               ::cCreateQuery += fld[ DBS_NAME ] + " mediumint(" + hb_ntos( fld[ DBS_LEN ] ) + ")"
            CASE fld[ DBS_LEN ] <= 9
               ::cCreateQuery += fld[ DBS_NAME ] + " int(" + hb_ntos( fld[ DBS_LEN ] ) + ")"
            OTHERWISE
               ::cCreateQuery += fld[ DBS_NAME ] + " bigint(" + hb_ntos( fld[ DBS_LEN ] ) + ")"
            ENDCASE
            ::cCreateQuery += Eval( cNN, fld ) + iif( fld[ DBS_NAME ] == cPrimaryKey, " NOT NULL ", "" ) + iif( fld[ DBS_NAME ] == cAuto, " auto_increment ", "" ) + ","
         ELSE
            ::cCreateQuery += fld[ DBS_NAME ] + " real(" + hb_ntos( fld[ DBS_LEN ] ) + "," + hb_ntos( fld[ DBS_DEC ] ) + ")" + Eval( cNN, fld ) + ","
         ENDIF
         EXIT

      CASE "D"
         ::cCreateQuery += fld[ DBS_NAME ] + " date " + Eval( cNN, fld ) + ","
         EXIT

      CASE "B"
         ::cCreateQuery += fld[ DBS_NAME ] + " mediumblob "  + Eval( cNN, fld ) + ","
         EXIT

      CASE "I"
         ::cCreateQuery += fld[ DBS_NAME ] + " mediumint " + Eval( cNN, fld ) + ","
         EXIT

      CASE "L"
         ::cCreateQuery += fld[ DBS_NAME ] + " bit "  + Eval( cNN, fld ) + ","
         EXIT

      CASE "W"
         ::cCreateQuery += fld[ DBS_NAME ] + " longblob " + Eval( cNN, fld ) + ","
         EXIT

      OTHERWISE
         ::cCreateQuery += fld[ DBS_NAME ] + " char(" + hb_ntos( fld[ DBS_LEN ] ) + ")" + Eval( cNN, fld ) + ","

      ENDSWITCH
   NEXT

   IF HB_ISSTRING( cPrimarykey )
      ::cCreateQuery += " PRIMARY KEY (" + cPrimaryKey + "),"
   ENDIF
   IF HB_ISSTRING( cUniquekey )
      ::cCreateQuery += " UNIQUE " + cUniquekey + " (" + cUniqueKey + "),"
   ENDIF

   // remove last comma from list
   ::cCreateQuery := hb_StrShrink( ::cCreateQuery ) + ");"
   IF mysql_query( ::nSocket, ::cCreateQuery ) == 0
      RETURN .T.
   ENDIF

   ::lError := .T.

   RETURN .F.

METHOD CreateIndex( cName, cTable, aFNames, lUnique ) CLASS TMySQLServer

   LOCAL cCreateQuery := "CREATE "
   LOCAL i

   IF hb_defaultValue( lUnique, .F. )
      cCreateQuery += "UNIQUE "
   ENDIF
   cCreateQuery += "INDEX " + cName + " ON " + Lower( cTable ) + " ("

   FOR EACH i IN aFNames
      cCreateQuery += i + ","
   NEXT

   // remove last comma from list
   cCreateQuery := hb_StrShrink( cCreateQuery ) + ")"

   RETURN mysql_query( ::nSocket, cCreateQuery ) == 0

METHOD DeleteIndex( cName, cTable ) CLASS TMySQLServer
   RETURN mysql_query( ::nSocket, "DROP INDEX " + cName + " FROM " + Lower( cTable ) ) == 0

METHOD DeleteTable( cTable ) CLASS TMySQLServer
   RETURN mysql_query( ::nSocket, "DROP TABLE " + Lower( cTable ) ) == 0

METHOD DeleteDatabase( cDataBase ) CLASS TMySQLServer
   RETURN mysql_query( ::nSocket, "DROP DATABASE " + Lower( cDataBase ) ) == 0

METHOD Query( cQuery ) CLASS TMySQLServer

   LOCAL oQuery, cTableName, i, cUpperQuery, nNumTables, cToken

   hb_default( @cQuery, "" )

   cUpperQuery := Upper( AllTrim( cQuery ) )
   i := 1
   nNumTables := 1

   DO WHILE ! ( cToken := hb_tokenGet( cUpperQuery, i++, " " ) ) == "FROM" .AND. ! Empty( cToken )
   ENDDO

   // first token after "FROM" is a table name
   // NOTE: SubSelects ?
   cTableName := hb_tokenGet( cUpperQuery, i++, " " )

   DO WHILE ! ( cToken := hb_tokenGet( cUpperQuery, i++, " " ) ) == "WHERE" .AND. ! Empty( cToken )
      // do we have more than one table referenced ?
      IF cToken == "," .OR. cToken == "JOIN"
         nNumTables++
      ENDIF
   ENDDO

   IF nNumTables == 1
      oQuery := TMySQLTable():New( ::nSocket, cQuery, cTableName )
   ELSE
      oQuery := TMySQLQuery():New( ::nSocket, cQuery )
   ENDIF

   IF oQuery:NetErr()
      ::lError := .T.
   ENDIF

   RETURN oQuery

METHOD Error() CLASS TMySQLServer

   ::lError := .F.

   RETURN iif( Empty( ::nSocket ), "No connection to server", mysql_error( ::nSocket ) )

METHOD ListDBs() CLASS TMySQLServer
   RETURN mysql_list_dbs( ::nSocket )

METHOD ListTables() CLASS TMySQLServer
   RETURN mysql_list_tables( ::nSocket )

METHOD TableExists( cTable ) CLASS TMySQLServer
   RETURN hb_AScan( mysql_list_tables( ::nSocket ), cTable,,, .T. ) > 0

/* FIXME: Conversion creates a .dbf with fields of wrong dimension (often) */
METHOD TableStruct( cTable ) CLASS TMySQLServer

   LOCAL aStruct := {}

   LOCAL aField, aSField, i
   LOCAL res := mysql_list_fields( ::nSocket, cTable )

   IF ! Empty( res )

      FOR i := 1 TO mysql_num_fields( res )

         aField := mysql_fetch_field( res )
         aSField := Array( DBS_DEC )

         aSField[ DBS_NAME ] := aField[ MYSQL_FS_NAME ]
         aSField[ DBS_DEC ]  := 0
         aSField[ DBS_LEN ]  := aField[ MYSQL_FS_LENGTH ]

         SWITCH aField[ MYSQL_FS_TYPE ]
         CASE MYSQL_TYPE_STRING
            aSField[ DBS_TYPE ] := "C"
            aSField[ DBS_LEN ] := aField[ MYSQL_FS_LENGTH ]
            EXIT

         CASE MYSQL_TYPE_TINY_BLOB  // max 2^8 char
         CASE MYSQL_TYPE_VARCHAR    // max 2^16 char
         CASE MYSQL_TYPE_VAR_STRING
            IF aField[ MYSQL_FS_LENGTH ] <= 255
               aSField[ DBS_TYPE ] := "C"
            ELSE
               aSField[ DBS_TYPE ] := "M"
               aSField[ DBS_LEN ] := 10
            ENDIF
            EXIT

         CASE MYSQL_TYPE_BLOB         // 2^16 char
         CASE MYSQL_TYPE_MEDIUM_BLOB  // 2^24 char
            aSField[ DBS_TYPE ] := "M"
            aSField[ DBS_LEN ] := 10
            EXIT

         CASE MYSQL_TYPE_LONG_BLOB  // 2^32 char
            aSField[ DBS_TYPE ] := "W"
            aSField[ DBS_LEN ] := 10
            EXIT

         CASE MYSQL_TYPE_DATE
            aSField[ DBS_TYPE ] := "D"
            aSField[ DBS_LEN ] := 8
            EXIT

         CASE MYSQL_TYPE_TIME
         CASE MYSQL_TYPE_DATETIME
         CASE MYSQL_TYPE_TIMESTAMP  // '9999-12-31 23:59:59'
            aSField[ DBS_TYPE ] := "T"
            aSField[ DBS_LEN ] := 8
            EXIT

         CASE MYSQL_TYPE_BIT
            aSField[ DBS_TYPE ] := "L"
            aSField[ DBS_LEN ] := 1
            EXIT

         CASE MYSQL_TYPE_SHORT  // INT_TYPE
         CASE MYSQL_TYPE_TINY   // UINT_TYPE
         CASE MYSQL_TYPE_INT24  // 3 BYTE INT
         CASE MYSQL_TYPE_LONG   // 4 BYTE INT
            aSField[ DBS_TYPE ] := "N"
            EXIT

         CASE MYSQL_TYPE_LONGLONG  // 8 BYTE INT
            aSField[ DBS_TYPE ] := "N"
            aSField[ DBS_LEN ] := Min( aField[ MYSQL_FS_LENGTH ], 16 )
            EXIT

         CASE MYSQL_TYPE_FLOAT  // with decimals
         CASE MYSQL_TYPE_DOUBLE
            aSField[ DBS_TYPE ] := "N"
            aSField[ DBS_LEN ] := Min( aField[ MYSQL_FS_LENGTH ], 16 )
            aSFIeld[ DBS_DEC ] := Min( aField[ MYSQL_FS_DECIMALS ], 14 )
            EXIT

         ENDSWITCH

         IF aSField[ DBS_TYPE ] != NIL
            AAdd( aStruct, aSField )
         ENDIF
      NEXT
   ENDIF

   RETURN aStruct

// Returns an SQL string with Cl*pper value converted
STATIC FUNCTION HarbValueToSQL( Value )

   SWITCH ValType( Value )
   CASE "N" ; RETURN hb_ntos( Value )
   CASE "D" ; RETURN iif( Empty( Value ), "''", "'" + hb_DToC( Value, "yyyy-mm-dd" ) + "'" )
   CASE "T" ; RETURN iif( Empty( Value ), "''", "'" + hb_TToC( Value, "yyyy-mm-dd", "hh:mm:ss" ) + "'" )
   CASE "C"
   CASE "M"
   CASE "W" ; RETURN iif( Empty( Value ), "''", "'" + mysql_escape_string( value ) + "'" )
   CASE "L" ; RETURN iif( Value, "1", "0" )
   CASE "U" ; RETURN "NULL"
   ENDSWITCH

   RETURN "''"  // NOTE: Here we lose values we cannot convert

STATIC FUNCTION SQLTypeToHarb( aField )

   SWITCH aField[ MYSQL_FS_TYPE ]
   CASE MYSQL_TYPE_STRING
      RETURN "C"

   CASE MYSQL_TYPE_TINY_BLOB
   CASE MYSQL_TYPE_VARCHAR
   CASE MYSQL_TYPE_VAR_STRING
      RETURN iif( aField[ MYSQL_FS_LENGTH ] <= 255, "C", "M" )

   CASE MYSQL_TYPE_BLOB
   CASE MYSQL_TYPE_MEDIUM_BLOB
      RETURN "M"

   CASE MYSQL_TYPE_LONG_BLOB
      RETURN "W"

   CASE MYSQL_TYPE_DATE
      RETURN "D"

   CASE MYSQL_TYPE_TIME
   CASE MYSQL_TYPE_DATETIME
   CASE MYSQL_TYPE_TIMESTAMP
      RETURN "T"

   CASE MYSQL_TYPE_BIT
      RETURN "L"

   CASE MYSQL_TYPE_SHORT
   CASE MYSQL_TYPE_TINY
   CASE MYSQL_TYPE_INT24
   CASE MYSQL_TYPE_LONG
   CASE MYSQL_TYPE_LONGLONG
   CASE MYSQL_TYPE_FLOAT
   CASE MYSQL_TYPE_DOUBLE
   CASE MYSQL_TYPE_NEWDECIMAL
      RETURN "N"

   ENDSWITCH

   RETURN "U"
