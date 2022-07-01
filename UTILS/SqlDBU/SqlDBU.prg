
#include "minigui.ch"
#include "dbinfo.ch"
#include "hbsqlit3.ch"
#include "TSBrowse.ch"


#define PROGRAM 'SQLITE Browser'
#define VERSION ' Ver. 1.3'
#define COPYRIGHT ' 2012-2016 Janusz Pora'

#define INT_LNG   8
#define FL_LNG   14
#define FL_DEC    5
#define DAT_LNG  10
#define DATTIM_LNG  19
#define BOOL_LNG  1

ANNOUNCE RDDSYS
REQUEST SDDSQLITE3, SQLMIX, DBFNTX


MEMVAR SqlDbuscrwidth, SqlDbuscrheight, SqlDbuwindowwidth, SqlDbuwindowheight
MEMVAR cLastDDir, SqlDbuTableName, SqlDbName, SqlDbulastpath, pDb
MEMVAR DBUgreen, DBUblue

#define SqlDbu_VERSION  '1.3'


#define SQLITE_ENABLE_COLUMN_METADATA


*--------------------------------------------------------*
FUNCTION Main()
*--------------------------------------------------------*

   PUBLIC SqlDbName := ""
   PUBLIC SqlDbuTableName := ""

   PUBLIC SqlDbuscrwidth := Min( 870, getdesktopwidth() )
   PUBLIC SqlDbuscrheight := Min( 600, getdesktopheight() )
   PUBLIC SqlDbuwindowwidth := getdesktopwidth() * 0.85
   PUBLIC SqlDbuwindowheight := getdesktopheight() * 0.85

   PUBLIC DBUgreen := { 200, 255, 200 }
   PUBLIC DBUblue := { 200, 200, 255 }
   PUBLIC pDb := 0

   PUBLIC cLastDDir := ''

   SET DATE TO BRITISH
   SET CENTURY ON
   SET EPOCH TO 1960
   SET DELETED ON
   SET EXCLUSIVE ON

   SET NAVIGATION EXTENDED
   SET BROWSESYNC ON

   rddSetDefault( "SQLMIX" )

   SET    DEFAULT ICON TO GetStartupFolder() + "\sqlite.ico"

   DEFINE WINDOW FrameDbu AT 0, 0 ;
         WIDTH SqlDbuscrwidth HEIGHT SqlDbuscrheight ;
         TITLE "Harbour Minigui DataBase SQLITE Utility" ;
         MAIN ;
         ON INIT GetRegPosWindow( "FrameDbu" ) ;
         ON RELEASE ( FErase( "mru.ini" ), SetRegPosWindow( "FrameDbu" ) )

      DEFINE STATUSBAR
         STATUSITEM "DataBase SQLITE Utility" // action SqlDbuopendbf()
         STATUSITEM "Database:" WIDTH 80
         STATUSITEM SqlDbName WIDTH 260
         STATUSITEM "Table: " WIDTH 80
         STATUSITEM SqlDbuTableName WIDTH 160
      END STATUSBAR

      DEFINE MAIN MENU

         DEFINE POPUP "&File"
            ITEM " Create &New SQL Base" + Chr( 9 ) + 'Ctrl+N' ACTION CreateDatabase() IMAGE 'MENUNEW.bmp'
            ITEM " Create New &Table " ACTION CreateStru() NAME AddTableSql IMAGE 'MENUNEW.bmp'
            SEPARATOR
            ITEM " &Open Database " + Chr( 9 ) + 'Ctrl+O' ACTION OpenDataBase() NAME SqlDbuopen IMAGE 'MENUOPEN.bmp'
            SEPARATOR
            DEFINE POPUP " &Open Table " NAME SqlOpenTable IMAGE 'MENUOPEN.bmp'
               MRU ' (Empty) '
            END POPUP
            ITEM " &Close Database" ACTION CloseDataBase() NAME SqlDbuClose IMAGE 'MENUCLOSE.bmp'
            SEPARATOR
            ITEM " E&xit" + Chr( 9 ) + 'Ctrl+X' ACTION FrameDbu.release() IMAGE 'MENUEXIT.bmp'
         END POPUP

         POPUP "&View"
            ITEM " Browse Mode" ACTION BrowseTable( SqlDbuTableName, FALSE ) NAME SqlDbuBrowse IMAGE 'MENUBROW.bmp'
            ITEM " Edit Mode" ACTION BrowseTable( SqlDbuTableName, TRUE ) NAME SqlDbuEdit IMAGE 'MENUEDIT.bmp'
            SEPARATOR
            ITEM "Table struct (Fields)" ACTION StructInfo( SqlDbuTableName ) NAME SqlDbuStru IMAGE 'MENUBROW.bmp'
         END POPUP


         POPUP "&Edit"
            ITEM " &Insert" ACTION SqlEdit( SqlDbuTableName, pDb ) NAME SqlInsItem IMAGE 'MENUREPL.bmp'
            SEPARATOR
            ITEM " Zap Table" ACTION ZapTable( SqlDbuTableName, pDb ) NAME SqlZapTable IMAGE 'MENUZAP.bmp'
            ITEM " Drop Table" ACTION DropTable( SqlDbuTableName, pDb ) NAME SqlDropTable IMAGE 'MENUZAP.bmp'
         END POPUP
         POPUP "&Tools"
            ITEM " &Create from Dbf" ACTION CreatefromDBF() NAME SqlDbuitem10 IMAGE 'MENUDBFCRE.bmp'
            ITEM " &Add Table from Dbf" ACTION CreatefromDBF(, pDb, SqlDbName ) NAME SqlDbuitem11 IMAGE 'MENUDBFCRE.bmp'
            ITEM " Create &Backup" ACTION BackupDb() NAME SqlBackDB IMAGE 'MENUDBFCRE.bmp'

         END POPUP

         POPUP "&Help"
            ITEM ' Version' ACTION MsgInfo ( "SqlDbu version: " + SqlDbu_VERSION + CRLF + ;
               "GUI Library : " + MiniGuiVersion() + CRLF + ;
               "Compiler     : " + Version(), 'Versions' ) IMAGE 'MENUVER.bmp'

            ITEM ' SQLITE Version' ACTION MsgInfo ( "Version library = " + sqlite3_libversion() + CRLF + ;
               "number version library = " + LTrim( Str( sqlite3_libversion_number() ) ), ;
               "SQLITE INFO" )

         END POPUP

      END MENU

      ON KEY CONTROL + N ACTION CreateDatabase()
      ON KEY CONTROL + O ACTION OpenDataBase()
      ON KEY CONTROL + X ACTION FrameDbu.release()

   END WINDOW

   FrameDbu.SqlDbuClose.Enabled := FALSE
   FrameDbu.SqlOpenTable.Enabled := FALSE
   FrameDbu.SqlDbuBrowse.Enabled := FALSE
   FrameDbu.SqlDbuEdit.Enabled := FALSE
   FrameDbu.SqlDbuStru.Enabled := FALSE
   FrameDbu.AddTableSql.Enabled := FALSE
   FrameDbu.SqlDropTable.Enabled := FALSE
   FrameDbu.SqlZapTable.Enabled := FALSE
   FrameDbu.SqlInsItem.Enabled := FALSE
   FrameDbu.SqlBackDB.Enabled := FALSE
   FrameDbu.SqlDbuitem11.Enabled := FALSE

   CENTER WINDOW FrameDbu
   ACTIVATE WINDOW FrameDbu

RETURN NIL

STATIC FUNCTION GetRegPosWindow( FormName, cProgName )

   LOCAL hKey := HKEY_CURRENT_USER
   LOCAL cKey
   LOCAL COL, ROW, WIDTH, HEIGHT
   LOCAL actpos := { 0, 0, 0, 0 }
   DEFAULT FormName := _HMG_ThisFormName
   DEFAULT cProgName := SubStr( cFileNoPath( hb_argv( 0 ) ), 1, RAt( '.', cFileNoPath( hb_argv( 0 ) ) ) - 1 )
   cKey := "Software\MiniGui\" + cProgName + "\" + FormName
   GetWindowRect( GetFormHandle( FormName ), actpos )
   IF IsRegistryKey( hKey, cKey )
      COL := GetRegistryValue( hKey, cKey, "col", 'N' )
      ROW := GetRegistryValue( hKey, cKey, "row", 'N' )
      WIDTH := GetRegistryValue( hKey, cKey, "width", 'N' )
      HEIGHT := GetRegistryValue( hKey, cKey, "height", 'N' )
      COL := IFNIL( COL, actpos[ 1 ], col )
      ROW := IFNIL( ROW, actpos[ 2 ], row )
      WIDTH := IFNIL( WIDTH, actpos[ 3 ] - actpos[ 1 ], width )
      HEIGHT := IFNIL( HEIGHT, actpos[ 4 ] - actpos[ 2 ], height )

      MoveWindow ( GetFormHandle( FormName ), COL, ROW, WIDTH, HEIGHT, TRUE )
   ENDIF

RETURN NIL

STATIC FUNCTION SetRegPosWindow( FormName, cProgName )

   LOCAL hKey := HKEY_CURRENT_USER
   LOCAL cKey
   LOCAL actpos := { 0, 0, 0, 0 }
   LOCAL COL, ROW, WIDTH, HEIGHT

   DEFAULT FormName := _HMG_ThisFormName
   DEFAULT cProgName := SubStr( cFileNoPath( hb_argv( 0 ) ), 1, RAt( '.', cFileNoPath( hb_argv( 0 ) ) ) - 1 )

   cKey := "Software\MiniGui\" + cProgName + "\" + FormName
   GetWindowRect( GetFormHandle( FormName ), actpos )
   if ! IsRegistryKey( hKey, cKey )
      if ! CreateRegistryKey( hKey, cKey )
         RETURN NIL
      ENDIF
   ENDIF
   IF IsRegistryKey( hKey, cKey )
      COL := actpos[ 1 ]
      ROW := actpos[ 2 ]
      WIDTH := actpos[ 3 ] - actpos[ 1 ]
      HEIGHT := actpos[ 4 ] - actpos[ 2 ]
      SetRegistryValue( hKey, cKey, "col", col )
      SetRegistryValue( hKey, cKey, "row", row )
      SetRegistryValue( hKey, cKey, "width", width )
      SetRegistryValue( hKey, cKey, "height", height )
   ENDIF

RETURN NIL

*--------------------------------------------------------*
FUNCTION OpenDataBase( cFileName, lCreate )
*--------------------------------------------------------*

   LOCAL aTable, n
   LOCAL lCreateIfNotExist := FALSE
   DEFAULT lCreate := FALSE
   lCreateIfNotExist := lCreate

   IF Empty( cFileName )
      cFileName := GetFile ( { { "SQLITE3 Files", "*.s3db" }, { "Database Files", "*.db" }, { "All Files", "*.*" } }, ;
         "Open Database", cLastDDir, FALSE, TRUE )
   ENDIF
   If ! Empty( cFileName )

      ClearMRUList()

      pDb := sqlite3_open( cFileName, lCreateIfNotExist )

      IF ! DB_IS_OPEN( pDb )
         pDb := 0
         MsgStop( "Unable open a database!", "Error" )
         RETURN FALSE
      ENDIF

      SqlDbName := cFileName
      aTable := SQLITE_TABLES( pDb )
      FOR n := 1 TO Len( aTable )
         AddMRUItem( aTable[ n ], "SeleTable()" )
      NEXT

      IF rddInfo( RDDI_CONNECT, { "SQLITE3", cFileName } ) == 0
         MsgStop( "Unable connect to the server!", "Error" )
         RETURN FALSE
      ENDIF

      FrameDbu.SqlDbuClose.Enabled := TRUE
      FrameDbu.SqlOpenTable.Enabled := Len( aTable ) > 0
      FrameDbu.AddTableSql.Enabled := TRUE
      FrameDbu.SqlBackDB.Enabled := TRUE
      FrameDbu.SqlDbuitem11.Enabled := TRUE
      SetProperty ( 'FrameDbu', 'StatusBar', 'Item', 3, SqlDbName )
      SetProperty ( 'FrameDbu', 'StatusBar', 'Item', 5, '' )
   ENDIF

RETURN TRUE

*--------------------------------------------------------*
FUNCTION CloseDataBase()
*--------------------------------------------------------*
   ClearMRUList()
   FrameDbu.SqlDbuClose.Enabled := FALSE
   FrameDbu.SqlOpenTable.Enabled := FALSE
   FrameDbu.SqlDbuBrowse.Enabled := FALSE
   FrameDbu.SqlDbuEdit.Enabled := FALSE
   FrameDbu.SqlDbuStru.Enabled := FALSE
   FrameDbu.AddTableSql.Enabled := FALSE
   FrameDbu.SqlDropTable.Enabled := FALSE
   FrameDbu.SqlZapTable.Enabled := FALSE
   FrameDbu.SqlInsItem.Enabled := FALSE
   FrameDbu.SqlBackDB.Enabled := FALSE
   FrameDbu.SqlDbuitem11.Enabled := FALSE
   SqlDbName := ""
   SqlDbuTableName := ''
   pDb := 0
   SetProperty ( 'FrameDbu', 'StatusBar', 'Item', 3, SqlDbName )
   SetProperty ( 'FrameDbu', 'StatusBar', 'Item', 5, SqlDbuTableName )

RETURN NIL

*--------------------------------------------------------*
FUNCTION SeleTable( cTable )
*--------------------------------------------------------*
   IF SQLITE_TABLEEXISTS( cTable, pDb )
      SqlDbuTableName := cTable
      FrameDbu.SqlDbuBrowse.Enabled := TRUE
      FrameDbu.SqlDbuEdit.Enabled := TRUE
      FrameDbu.SqlDbuStru.Enabled := TRUE
      FrameDbu.SqlDropTable.Enabled := TRUE
      FrameDbu.SqlZapTable.Enabled := TRUE
      FrameDbu.SqlInsItem.Enabled := TRUE
      SetProperty ( 'FrameDbu', 'StatusBar', 'Item', 5, SqlDbuTableName )

   ENDIF

RETURN NIL

*--------------------------------------------------------*
PROCEDURE CloseTable
*--------------------------------------------------------*

   dbCloseAll()
   SetProperty ( 'FrameDbu', 'StatusBar', 'Item', 5, '' )

RETURN


*--------------------------------------------------------*
FUNCTION StructInfo( cTable )
*--------------------------------------------------------*
* Shows Information about fields...
*--------------------------------------------------------*
   LOCAL aResult, aInfo := {}
   LOCAL DBUstruct := {}, aSeq := {}, nSeq

   IF ValType( cTable ) != "C" .OR. Empty( cTable ) .OR. cTable == NIL
      RETURN 0
   ELSE
      aSeq := SQLITE_TABLESEQUENCE( pDb, cTable )
      aResult := SQLITE_COLUMNS_METADATA( pDb, cTable )
   ENDIF

   IF Len( aResult ) > 0
      nSeq := if( Len( aSeq ) > 0, aSeq[ 2 ], 0 )
      AEval( aResult, {| x, y | AAdd( DBUstruct, { y, x[ 1 ], x[ 2 ], x[ 3 ], x[ 4 ], x[ 5 ], x[ 6 ], x[ 7 ], x[ 8 ], if( x[ 8 ], nSeq, '' ) } ) } )
      BrowStru( DBUstruct, aResult, cTable, , aSeq )
   ENDIF

RETURN NIL


*--------------------------------------------------------*
FUNCTION CreateDatabase()
*--------------------------------------------------------*
   LOCAL cFileName := ''

   DEFINE WINDOW FrameNewBase ;
         AT 0, 0 WIDTH 500 HEIGHT 300 ;
         TITLE "Create a new SQLITE Database" NOSIZE // nosysmenu

      @ 10, 10 FRAME Frame_1 ;
         WIDTH 550 ;
         HEIGHT 200 ;
         CAPTION "Info"

      @ 40, 40 LABEL Lbl_Path ;
         VALUE "Path" ;
         WIDTH 60 ;
         BACKCOLOR DBUblue


      @ 40, 110 BTNTEXTBOX Text_Path ;
         WIDTH 350 ;
         VALUE "" ;
         BACKCOLOR DBUgreen ;
         Action {|| FrameNewBase.Text_Path.VALUE := GetFolder (, FrameNewBase.Text_Path.value ), cFileName := FileNameCreta() }

      @ 80, 40 LABEL Lbl_Name ;
         VALUE "Name" ;
         WIDTH 60 ;
         BACKCOLOR DBUblue


      @ 80, 110 TEXTBOX Text_Name ;
         WIDTH 150 ;
         UPPERCASE ;
         BACKCOLOR DBUgreen ;
         VALUE "" ;
         ON CHANGE {|| cFileName := FileNameCreta(), FrameNewBase.Btn_Create.Enabled := ! Empty( FrameNewBase.Text_Name.Value ) }

      @ 120, 110 LABEL Lbl_File ;
         VALUE cFileName ;
         AUTOSIZE BOLD

      DEFINE BUTTON Btn_Create
         ROW 160
         COL 75
         CAPTION "Create"
         WIDTH 100
         ACTION OpenDataBase( cFileName, TRUE )
      END BUTTON


   END WINDOW
   FrameNewBase.Btn_Create.Enabled := FALSE
   CENTER WINDOW FrameNewBase

   ACTIVATE WINDOW FrameNewBase

RETURN NIL

*--------------------------------------------------------*
FUNCTION FileNameCreta()
*--------------------------------------------------------*
   LOCAL cFile, cName

   cFile := FrameNewBase.Text_Name.VALUE
   if ! Empty( cFile ) .AND. At( '.', cFile ) == 0
      cFile := cFile + '.s3db'
   ENDIF
   cName := FrameNewBase.Text_Path.VALUE +'\' + cFile
   FrameNewBase.lbl_File.VALUE := cName

RETURN cName

*--------------------------------------------------------*
FUNCTION CreateStru()
*--------------------------------------------------------*
   LOCAL DBUstruct := {}

   BrowStru( DBUstruct, {}, '', TRUE )

RETURN NIL

*--------------------------------------------------------*
FUNCTION CreateNewTable( oGrid, cTable )
*--------------------------------------------------------*
   LOCAL cQuery, i, aTable, aStru
   LOCAL lRet := FALSE

   cQuery := QueryNewTbl( oGrid, cTable )

   IF ! sqlite3_exec( pDb, cQuery ) == SQLITE_OK
      MsgStop( "Can't create " + cTable, "Error" )
   ELSE
      ClearMRUList()
      aTable := SQLITE_TABLES( pDb )
      FOR i := 1 TO Len( aTable )
         AddMRUItem( aTable[ i ], "SeleTable()" )
      NEXT
      MsgStop( "Table " + cTable + " create successful.", "Note" )
      lRet := TRUE
      aStru := {}
      AEval( oGrid:aArray, {| x | AAdd( aStru, { x[ 2 ], x[ 3 ], x[ 4 ], x[ 5 ] } ) } )

   ENDIF

RETURN lRet

*--------------------------------------------------------*
FUNCTION CreatefromDBF( cDBase, db, cSbase )
*--------------------------------------------------------*
   LOCAL cHeader, cQuery := "", NrReg := 0, cTable := cFileNoExt( cDBase )
   LOCAL lCreateIfNotExist := FALSE, cOldRdd, aDbStru

   IF Empty( cDBase )
      cDBase := GetFile ( { { "DBASE Files", "*.dbf" }, { "All Files", "*.*" } }, "Open Database", ;
         cLastDDir, FALSE, FALSE )
   ENDIF
   IF File( cDBase )
      cTable := SubStr( cFileNoPath( cDBase ), 1, RAt( '.', cDBase ) - 1 )
      cTable := cFileNoExt( cTable )
      DEFAULT cSbase := cTable + '.s3db'
      db := sqlite3_open( cSbase, .NOT. File( cSbase ) )
      IF ! DB_IS_OPEN( db )
         MsgStop( "Can't open/create " + cSbase, "Error" )
         RETURN NIL
      ENDIF
      sqlite3_exec( db, "PRAGMA auto_vacuum=0" )
      IF SQLITE_TABLEEXISTS( cTable, db )
         if ! SQLITE_DROPTABLE( cSbase, cTable )
            MsgStop( "Can't drop table " + cTable, "Error" )
            RETURN NIL
         ELSE
            db := sqlite3_open( cSbase, .NOT. File( cSbase ) )
         ENDIF
      ENDIF

      // Create table
      IF ( rddSetDefault() != "DBFNTX" )
         cOldRdd := rddSetDefault( "DBFNTX" )
      ENDIF

      dbUseArea( TRUE, 'DBFNTX', cTable )
      IF ! SQLITE_TABLEEXISTS( cTable, db )

         cHeader := QueryCrea( cTable, 0 )
         IF sqlite3_exec( db, cHeader ) == SQLITE_OK
            aDbStru := dbStruct()
            aDbStru := SetFieldType( aDbStru )
         ENDIF
      ENDIF
      IF SQLITE_TABLEEXISTS( cTable, db )


         GO TOP
         DO While ! Eof()
            cQuery += QueryCrea( cTable, 1 )
            NrReg++
            SKIP
         ENDDO
         USE

         IF sqlite3_exec( db, ;
               "BEGIN TRANSACTION;" + ;
               cQuery + ;
               "COMMIT;" ) == SQLITE_OK

            MsgInfo( AllTrim( Str( NrReg ) ) + " records added to table " + cTable, "Result" )
         ELSE
            MsgInfo( SubStr( cQuery, 1, 300 ) )
         ENDIF

      ENDIF

   ENDIF

   rddSetDefault( cOldRdd )
   IF OpenDataBase( cSbase )
      SeleTable( cTable )
      BrowseTable( cTable, FALSE )
   ENDIF

RETURN 0

*--------------------------------------------------------*
FUNCTION SetFieldType( aDbStru )
*--------------------------------------------------------*
   LOCAL i
   FOR i := 1 TO Len( aDbStru )
      DO CASE
      CASE aDbStru[ i, 2 ] $ "CDT"
         aDbStru[ i, 2 ] := "SQLITE_TEXT"
         aDbStru[ i, 3 ] := 50
      CASE aDbStru[ i, 2 ] = "N"
         IF aDbStru[ i, 4 ] > 0
            aDbStru[ i, 2 ] := "SQLITE_FLOAT"
            aDbStru[ i, 3 ] := 12
            aDbStru[ i, 4 ] := 2
         ELSE
            aDbStru[ i, 2 ] := "SQLITE_INTEGER"
         ENDIF
      CASE aDbStru[ i, 2 ] = "F"
         aDbStru[ i, 2 ] := "SQLITE_FLOAT"
      CASE aDbStru[ i, 2 ] = "I"
         aDbStru[ i, 2 ] := "SQLITE_INTEGER"
      CASE aDbStru[ i, 2 ] = "B"
         aDbStru[ i, 2 ] := "SQLITE_FLOAT"
      CASE aDbStru[ i, 2 ] = "Y"
         aDbStru[ i, 2 ] := "SQLITE_FLOAT"
      CASE aDbStru[ i, 2 ] = "L"
         aDbStru[ i, 2 ] := "SQLITE_INTEGER"
      CASE aDbStru[ i, 2 ] = "M"
         aDbStru[ i, 2 ] := "SQLITE_TEXT"
      CASE aDbStru[ i, 2 ] = "G"
         aDbStru[ i, 2 ] := "SQLITE_BLOB"
      OTHERWISE
         aDbStru[ i, 2 ] := "SQLITE_NULL"
      ENDCASE
   NEXT

RETURN aDbStru

*--------------------------------------------------------*
FUNCTION QueryCrea( cTable, met, cTable2, aDbStru )
*--------------------------------------------------------*
   LOCAL cQuery := "", i
   LOCAL cFldName, cFldType, cFldLen, cFldDec, lNull, lKey, lIncr

   DEFAULT aDbStru := dbStruct(), cTable2 := cTable + "Tmp"
   DO CASE
   CASE met == 0
      cQuery := "CREATE TABLE IF NOT EXISTS " + cTable + " ( "
      FOR i := 1 TO Len( aDbStru )

         cFldName := aDbStru[ i, 1 ]
         cFldType := aDbStru[ i, 2 ]
         cFldLen := aDbStru[ i, 3 ]
         cFldDec := aDbStru[ i, 4 ]
         lNull := aDbStru[ i, 6 ]
         lKey := aDbStru[ i, 7 ]
         lIncr := aDbStru[ i, 8 ]


         IF i > 1
            cQuery += ", "
         ENDIF
         cQuery += AllTrim( cFldName ) + " "

         DO CASE
         CASE cFldType = "C"
            cQuery += "CHAR(" + LTrim( Str( cFldLen ) ) + ")"
         CASE cFldType = "D"
            cQuery += "DATE"
         CASE cFldType = "T"
            cQuery += "DATETIME"
         CASE cFldType = "N"
            IF cFldDec > 0
               cQuery += "FLOAT"
            ELSE
               cQuery += "INTEGER"
            ENDIF
         CASE cFldType = "F"
            cQuery += "FLOAT"
         CASE cFldType = "I"
            cQuery += "INTEGER"
         CASE cFldType = "B"
            cQuery += "DOUBLE"
         CASE cFldType = "Y"
            cQuery += "FLOAT"
         CASE cFldType = "L"
            cQuery += "BOOL"
         CASE cFldType = "M"
            cQuery += "TEXT"
         CASE cFldType = "G"
            cQuery += "BLOB"
         OTHERWISE
            msginfo( "Invalid Field Type: " + cFldType )
            RETURN NIL
         ENDCASE
      NEXT

      cQuery += ")"


   CASE met == 1

      cQuery := "INSERT INTO " + cTable + " VALUES ("
      FOR i := 1 TO Len( aDbStru )
         cFldName := aDbStru[ i, 1 ]
         IF i > 1
            cQuery += ", "
         ENDIF
         cQuery += c2sql( &cFldName )
      NEXT
      cQuery += "); "

   CASE met == 2
      cQuery := "CREATE TEMPORARY TABLE " + cTable2 + " ( "
      FOR i := 1 TO Len( aDbStru )
         cFldName := aDbStru[ i, 1 ]
         IF i > 1
            cQuery += ", "
         ENDIF
         cQuery += AllTrim( cFldName ) + " "

      NEXT
      cQuery += "); "

   CASE met == 3
      cQuery := "INSERT INTO " + cTable2 + "  SELECT "
      FOR i := 1 TO Len( aDbStru )
         cFldName := aDbStru[ i, 1 ]
         IF i > 1
            cQuery += ", "
         ENDIF
         cQuery += AllTrim( cFldName ) + " "

      NEXT
      cQuery += "FROM " + cTable + " ;"

   ENDCASE

RETURN cQuery

*--------------------------------------------------------*
FUNCTION c2Sql( Value )
*--------------------------------------------------------*
   LOCAL cValue := ""
   LOCAL cdate := ""
   IF ValType( value ) == "C" .AND. Len( AllTrim( value ) ) > 0
      VALUE := StrTran( VALUE, "'", "''" )
   ENDIF
   DO CASE
   CASE ValType( Value ) == "N"
      cValue := AllTrim( Str( Value ) )
   CASE ValType( Value ) == "D"
      if ! Empty( Value )
         cdate := DToS( value )
         cValue := "'" + SubStr( cDate, 1, 4 ) + "-" + SubStr( cDate, 5, 2 ) + "-" + SubStr( cDate, 7, 2 ) + "'"
      ELSE
         cValue := "''"
      ENDIF
   CASE ValType( Value ) $ "CM"
      IF Empty( Value )
         cValue = "''"
      ELSE
         cValue := "'" + VALUE +"'"
      ENDIF
   CASE ValType( Value ) == "L"
      cValue := AllTrim( Str( iif( VALUE == FALSE, 0, 1 ) ) )
   OTHERWISE
      cValue := "''" // NOTE: Here we lose values we cannot convert
   ENDCASE

RETURN cValue

*--------------------------------------------------------*
FUNCTION SQLITE_TABLEEXISTS( cTable, db )
*--------------------------------------------------------*
* Uses a (special) master table where the names of all tables are stored
*---------------------------------------------------------------------------
   LOCAL cStatement, lRet := FALSE
   LOCAL lCreateIfNotExist := FALSE

   cStatement := "SELECT name FROM sqlite_master " + ;
      "WHERE type ='table' AND tbl_name='" + ;
      cTable + "'"

   IF DB_IS_OPEN( db )
      lRet := ( Len( SQLITE_QUERY( db, cStatement ) ) > 0 )
   ENDIF

RETURN( lRet )

*--------------------------------------------------------*
FUNCTION SQLITE_TABLESEQUENCE( db, cTable )
*--------------------------------------------------------*
* Uses a (special) sqlite_sequence table where the names of sequence tables are stored
*---------------------------------------------------------------------------
   LOCAL cStatement, aFields := {}
   DEFAULT cTable := ""
   cStatement := "SELECT name,seq FROM sqlite_sequence "
   if ! Empty( cTable )
      cStatement += "WHERE name='" + cTable + "'"
   ENDIF
   IF DB_IS_OPEN( db )
      aFields := SQLITE_QUERY( db, cStatement )
   ENDIF

RETURN( aFields )


*--------------------------------------------------------*
FUNCTION SQLITE_DROPTABLE( cBase, cTable )
*--------------------------------------------------------*
* Deletes a table from current database
* WARNING !!   It deletes forever...
*---------------------------------------------------------------------------
   LOCAL db, lRet := FALSE

   IF ! Empty( cTable )
      IF MsgYesNo( "The  table " + cTable + " will be erased" + CRLF + ;
            "without any choice to recover." + CRLF + CRLF + ;
            "       Continue ?", "Warning!" )

         db := sqlite3_open_v2( cBase, SQLITE_OPEN_READWRITE + SQLITE_OPEN_EXCLUSIVE )
         IF DB_IS_OPEN( db )
            IF sqlite3_exec( db, "drop table " + cTable ) == SQLITE_OK
               IF sqlite3_exec( db, "vacuum" ) == SQLITE_OK
                  lRet := TRUE
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN lRet

*--------------------------------------------------------*
FUNCTION SQLITE_COLUMNS( cTable, db )
*--------------------------------------------------------*
* Returns an 2-dimensional array with field names and types
*---------------------------------------------------------------------------
   LOCAL aCType := { "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_TEXT", "SQLITE_BLOB", "SQLITE_NULL" }
   LOCAL aFields := {}, cStatement := "SELECT * FROM " + cTable
   LOCAL lCreateIfNotExist := FALSE
   LOCAL stmt, nCCount, nI, nCType, cType, cName, aSize

   stmt := sqlite3_prepare( db, cStatement )

   sqlite3_step( stmt )
   nCCount := sqlite3_column_count( stmt )

   IF nCCount > 0
      FOR nI := 1 TO nCCount
         cName := sqlite3_column_name( stmt, nI )
         nCType := sqlite3_column_type( stmt, nI )
         cType := Upper( AllTrim( sqlite3_column_decltype( stmt, nI ) ) )
         aSize := FieldSize( cType, cname, db, cTable )
         AAdd( aFields, { cName, aCType[ nCType ], cType, aSize[ 1 ], aSize[ 2 ] } )
      NEXT nI
   ENDIF

   sqlite3_finalize( stmt )

RETURN( aFields )

*--------------------------------------------------------*
FUNCTION SQLITE_COLUMNS_METADATA( db, cTable )
*--------------------------------------------------------*
* Returns an 2-dimensional array with field names and types
*---------------------------------------------------------------------------
   LOCAL aCType := { "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_TEXT", "SQLITE_BLOB", "SQLITE_NULL" }
   LOCAL aFields := {}, cStatement := "SELECT * FROM " + cTable
   LOCAL stmt, nCCount, nI, nCType, cName, aInfo := { '', '', FALSE, FALSE, FALSE, '' }
   LOCAL cType, aSize
   stmt := sqlite3_prepare( db, cStatement )

   sqlite3_step( stmt )
   nCCount := sqlite3_column_count( stmt )
   IF nCCount > 0
      FOR nI := 1 TO nCCount
         cName := sqlite3_column_name( stmt, nI )
         nCType := sqlite3_column_type( stmt, nI )
         cType := Upper( AllTrim( sqlite3_column_decltype( stmt, nI ) ) )
         aSize := FieldSize( cType, cname, db, cTable )

#ifdef SQLITE_ENABLE_COLUMN_METADATA
         aInfo := sqlite3_table_column_metadata( db,, cTable, cName )

#endif

         // VIEW cTable,cName,aInfo
         AAdd( aFields, { cName, aCType[ nCType ], cType, aSize[ 1 ], aSize[ 2 ], aInfo[ 3 ], aInfo[ 4 ], aInfo[ 5 ] } )

      NEXT nI
   ENDIF

   sqlite3_finalize( stmt )

RETURN( aFields )


*--------------------------------------------------------*
FUNCTION SQLITE_TABLES( db )
*--------------------------------------------------------*
* Uses a (special) master table where the names of all tables are stored
* Returns an array with names of tables inside of the database
*---------------------------------------------------------------------------
   LOCAL aTables, cStatement

   cStatement := "SELECT name FROM sqlite_master " + ;
      "WHERE type IN ('table','view') " + ;
      "AND name NOT LIKE 'sqlite_%' " + ;
      "UNION ALL " + ;
      "SELECT name FROM sqlite_temp_master " + ;
      "WHERE type IN ('table','view') " + ;
      "ORDER BY 1;"

   IF DB_IS_OPEN( db )
      aTables := SQLITE_QUERY( db, cStatement )
   ENDIF

RETURN( aTables )

*--------------------------------------------------------*
FUNCTION SQLITE_QUERY( db, cStatement )
*--------------------------------------------------------*
   LOCAL stmt, nCCount, nI, nCType
   LOCAL aRet := {}

   stmt := sqlite3_prepare( db, cStatement )

   IF STMT_IS_PREPARED( stmt )
      DO WHILE sqlite3_step( stmt ) == SQLITE_ROW
         nCCount := sqlite3_column_count( stmt )

         IF nCCount > 0
            FOR nI := 1 TO nCCount
               nCType := sqlite3_column_type( stmt, nI )

               SWITCH nCType
               CASE SQLITE_NULL
                  AAdd( aRet, "NULL" )
                  EXIT

               CASE SQLITE_FLOAT
               CASE SQLITE_INTEGER
                  AAdd( aRet, LTrim( Str( sqlite3_column_int( stmt, nI ) ) ) )
                  EXIT

               CASE SQLITE_TEXT
                  AAdd( aRet, sqlite3_column_text( stmt, nI ) )
                  EXIT
               END SWITCH
            NEXT nI
         ENDIF
      ENDDO
      sqlite3_finalize( stmt )
   ENDIF

RETURN( aRet )

*--------------------------------------------------------*
FUNCTION SQLITE_SET_BLOB( cTable, cField, db, cFile )
*--------------------------------------------------------*
   LOCAL stmt, nI, cQuery, aFields
   LOCAL Buff, lRet := FALSE
   // sqlite3_exec( db, "PRAGMA auto_vacuum=0" )
   // sqlite3_exec( db, "PRAGMA page_size=8192" )

   aFields := SQLITE_COLUMNS( cTable, db )
   IF ( nI := AScan( aFields, {| x | x[ 1 ] == cField .AND. x[ 3 ] == 'BLOB' } ) ) == 0
      RETURN lRet
   ENDIF
   cQuery := "INSERT INTO " + cTable + " (" + cField + ') VALUES ( :' + cField + ');'

   stmt := sqlite3_prepare( db, cQuery )

   IF STMT_IS_PREPARED( stmt )
      buff := sqlite3_file_to_buff( cFile )

      IF sqlite3_bind_blob( stmt, 1, @buff ) == SQLITE_OK
         IF sqlite3_step( stmt ) == SQLITE_DONE
            lRet := TRUE
         ENDIF
      ENDIF
      buff := NIL
      sqlite3_clear_bindings( stmt )
      sqlite3_finalize( stmt )

   ENDIF

RETURN( lRet )

*--------------------------------------------------------*
FUNCTION SQLITE_GET_BLOB( cTable, cField, db, cFile )
*--------------------------------------------------------*
   LOCAL stmt, nI, cQuery, aFields, i, cFldName
   LOCAL Buff, lRet := FALSE

   aFields := SQLITE_COLUMNS( cTable, db )
   IF ( nI := AScan( aFields, {| x | x[ 1 ] == cField .AND. x[ 3 ] == 'BLOB' } ) ) == 0
      RETURN lRet
   ENDIF
   cQuery := "SELECT " + cField + " FROM " + cTable + " WHERE "
   FOR i := 1 TO Len( aFields )
      IF aFields[ i, 3 ] != 'BLOB'
         cFldName := aFields[ i, 1 ]
         IF i > 1
            cQuery += " AND "
         ENDIF
         cQuery += cFldName + " = " + c2sql( &cFldName )
      ENDIF
   NEXT

   stmt := sqlite3_prepare( db, cQuery )

   IF STMT_IS_PREPARED( stmt )
      IF sqlite3_step( stmt ) == SQLITE_ROW
         buff := sqlite3_column_blob( stmt, 1 )

         IF ( sqlite3_buff_to_file( cFile, @buff ) == SQLITE_OK )
            MsgInfo( "Save BLOB into " + cFile + "- Done" )
            lRet := TRUE
         ENDIF
         buff := NIL
      ENDIF
      sqlite3_clear_bindings( stmt )
      sqlite3_finalize( stmt )

   ENDIF

RETURN( lRet )

*--------------------------------------------------------*
FUNCTION FieldSize( cType, cFieldName, db, cTable )
*--------------------------------------------------------*
   LOCAL aSize := { 0, 0 }, cQuery, aLength

   DO CASE
   CASE SubStr( ctype, 1, 4 ) == 'CHAR'
      aSize[ 1 ] := Val( CHARONLY ( "0123456789", cType ) )
   CASE ctype == 'TEXT'
      aSize[ 1 ] := 0
      cQuery := 'select max( length( ' + cFieldName + ' ) ) from ' + cTable
      aLength := SQLITE_QUERY( db, cQuery )
      IF Len( aLength ) > 0
         aSize[ 2 ] := Val( AllTrim( aLength[ 1 ] ) )
      ENDIF
   CASE ctype == "INTEGER"
      aSize[ 1 ] := INT_LNG // 8
   CASE ctype == "REAL" .OR. ctype == "FLOAT" .OR. ctype == "DOUBLE"
      aSize[ 1 ] := FL_LNG // 14
      aSize[ 2 ] := FL_DEC // 5
   CASE ctype == "DATE" .OR. ctype == "TIME"
      aSize[ 1 ] := DAT_LNG // 10
   CASE ctype == "DATETIME"
      aSize[ 1 ] := DATTIM_LNG // 19
   CASE ctype == "BOOL"
      aSize[ 1 ] := BOOL_LNG // 1
   ENDCASE

RETURN aSize

*--------------------------------------------------------*
FUNCTION BackupDb()
*--------------------------------------------------------*
   LOCAL cFileDest, pDbDest, nDbFlags, pBackup

   cFileDest := cFileNoExt( SqlDbName ) + '.s3bac'

   IF sqlite3_libversion_number() < 3006011
      RETURN 0
   ENDIF

   IF Empty( pDb )
      RETURN 0
   ENDIF

   nDbFlags := SQLITE_OPEN_CREATE + SQLITE_OPEN_READWRITE + ;
      SQLITE_OPEN_EXCLUSIVE
   pDbDest := sqlite3_open_v2( cFileDest, nDbFlags )

   IF Empty( pDbDest )
      MsgInfo( "Can't open database : " + cFileDest )

      RETURN 0
   ENDIF

   pBackup := sqlite3_backup_init( pDbDest, "main", pDb, "main" )
   IF Empty( pBackup )
      MsgInfo( "Can't initialize backup" )
      RETURN 0
   ENDIF

   IF MsgYesNo( "Backup File " + SqlDbName + " to " + cFileDest + CRLF + "Start backup ?", "Backup Database" )

      IF sqlite3_backup_step( pBackup, -1 ) == SQLITE_DONE
         MsgInfo( "Backup successful." + CRLF + 'File created : ' + cFileDest )
      ENDIF
      sqlite3_backup_finish( pBackup )
   ENDIF

RETURN 1

#include 'SqlEdit.Prg'
#include 'SqlBrowse.Prg'
