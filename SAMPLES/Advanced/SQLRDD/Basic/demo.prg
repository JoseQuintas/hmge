/*
 *
 * MiniGUI MySQL Basic Sample.
 *
*/

#include <minigui.ch>
#include "SQLRDD.Ch"

REQUEST SQLRDD, SR_MYSQL


#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgStop( c ) MsgInfo( c, "Error", , .f. )

MEMVAR oServer
MEMVAR nConnection
MEMVAR cHostName
MEMVAR cUser
MEMVAR cPassWord
MEMVAR cDataBase

*-----------------------------------------------------------------*
PROCEDURE Main()
*-----------------------------------------------------------------*

   PUBLIC oServer := NIL
   PUBLIC nConnection := 0
   PUBLIC cHostName := "localhost"
   PUBLIC cUser := "root"
   PUBLIC cPassWord := "mypass"
   PUBLIC cDataBase := "NAMEBOOK"

   DEFINE WINDOW Form_1 ;
         AT 5, 5 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE "Harbour + MiniGui + MySql" ;
         MAIN ;
         NOMAXIMIZE ;
         NOSIZE ;
         ON INIT My_SQL_Login() ;
         ON RELEASE My_SQL_Logout()

      DEFINE STATUSBAR
         STATUSITEM " "
      END STATUSBAR

      DEFINE MAIN MENU
         POPUP "Actions"
            ITEM "&Connect to MySql server, create Database 'NAMEBOOK' and table 'NAMES', insert records from 'Names.dbf'" ACTION Prepare_data()
            SEPARATOR
            ITEM "&View/Edit data from MySql" ACTION ( My_SQL_Connect(), iif( My_SQL_Database_Connect( "NAMEBOOK" ), ;
               ( dbUseArea( .F., "SQLRDD", "Names", "VIEW" ), ( EDIT EXTENDED ) ), NIL ), My_SQL_Logout() )
            SEPARATOR
            ITEM "&Exit" ACTION ThisWindow.Release()
         END POPUP
         POPUP "Help"
            ITEM "&About" ACTION MsgInfo( "MiniGUI MySQL Basic Sample" )
         END POPUP
      END MENU

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

*-----------------------------------------------------------------*
FUNCTION My_SQL_Login()
*-----------------------------------------------------------------*

   DEFINE WINDOW Form_0 ;
         AT 0, 0 ;
         WIDTH 280 HEIGHT 200 ;
         TITLE 'Login MySql' ;
         NOSYSMENU ;
         FONT "Arial" SIZE 09

      @ 24, 30 LABEL Label_HostName ;
         VALUE "HostName/IP" ;
         WIDTH 150 ;
         HEIGHT 35 ;
         BOLD

      @ 59, 30 LABEL Label_User ;
         VALUE "User" ;
         WIDTH 120 ;
         HEIGHT 35 ;
         BOLD

      @ 94, 30 LABEL Label_Password ;
         VALUE "Password" ;
         WIDTH 120 ;
         HEIGHT 35 ;
         BOLD

      @ 20, 120 TEXTBOX p_HostName ;
         HEIGHT 25 ;
         VALUE cHostName ;
         WIDTH 120 ;
         ON ENTER iif( ! Empty( Form_0.p_HostName.Value ), Form_0.p_User.SetFocus, Form_0.p_HostName.SetFocus )

      @ 55, 120 TEXTBOX p_User ;
         HEIGHT 25 ;
         VALUE cUser ;
         WIDTH 120 ;
         ON ENTER iif( ! Empty( Form_0.p_User.Value ), Form_0.p_Password.SetFocus, Form_0.p_user.SetFocus )

      @ 90, 120 TEXTBOX p_password ;
         VALUE cPassWord ;
         PASSWORD ;
         ON ENTER Form_0.Bt_Login.SetFocus

      @ 130, 30 BUTTON Bt_Login ;
         CAPTION '&Login' ;
         ACTION SQL_Connect()

      @ 130, 143 BUTTON Bt_Logoff ;
         CAPTION '&Cancel' ;
         ACTION Form_1.RELEASE

   END WINDOW

   CENTER WINDOW Form_0
   ACTIVATE WINDOW Form_0

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION SQL_Connect()
*-----------------------------------------------------------------*
   LOCAL cConnection

   cHostName := AllTrim( Form_0.p_HostName.Value )
   cUser := AllTrim( Form_0.p_User.Value )
   cPassWord := AllTrim( Form_0.p_password.Value )

   cConnection := "HST=" + cHostName + ";UID=" + cUser + ";PWD=" + cPassword + ";DTB=test"
   nConnection := SR_AddConnection( CONNECT_MYSQL, cConnection )
   IF nConnection <= 0
      MsgInfo( "Error connecting to SQL server. See sqlerror.log for details." )
      RELEASE WINDOW ALL
      QUIT
   ENDIF
   oServer := SR_GetConnection()

   MsgInfo( "The connection to the MySql server is completed!" )

   Form_0.RELEASE

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION Prepare_data()
*-----------------------------------------------------------------*
   My_SQL_Connect()
   My_SQL_Database_Create( "NAMEBOOK" )
   My_SQL_Database_Connect( "NAMEBOOK" )
   My_SQL_Table_Create( "NAMES" )
   My_SQL_Table_Insert( "NAMES" )
   My_SQL_Logout()

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION My_SQL_Connect()
*-----------------------------------------------------------------*
   LOCAL cConnection

   IF oServer != NIL
      RETURN NIL
   ENDIF
   cConnection := "HST=" + cHostName + ";UID=" + cUser + ";PWD=" + cPassword + ";DTB=test"
   nConnection := SR_AddConnection( CONNECT_MYSQL, cConnection )
   IF nConnection <= 0
      MsgInfo( "Error connecting to SQL server. See sqlerror.log for details." )
      RELEASE WINDOW ALL
      QUIT
   ENDIF
   oServer := SR_GetConnection()

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION My_SQL_Database_Create( cDatabase )
*-----------------------------------------------------------------*
   LOCAL aDatabaseList

   IF oServer == NIL
      MsgInfo( "Not connected to SQL server!" )
      RETURN NIL
   ENDIF

   aDatabaseList := SR_ListDatabases()

   IF Len( aDatabaseList ) == 0
      MsgInfo( "Error verifying database list." )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   IF AScan( aDatabaseList, cDatabase ) != 0
      MsgInfo( "Database already exists!" )
      RETURN NIL
   ENDIF

   cDatabase := Lower( cDatabase )

   IF ! SR_CreateDatabase( cDatabase )
      MsgInfo( "Error creating database!" )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION SR_ListDatabases()
*-----------------------------------------------------------------*

   LOCAL oCnn
   LOCAL aRet := {}
   LOCAL aRet2
   LOCAL i

   oCnn := SR_GetConnection()

   SWITCH oCnn:nSystemID

   CASE SYSTEMID_MYSQL
   CASE SYSTEMID_MARIADB
      oCnn:exec( "show databases", .T., .T., @aRet )
      EXIT
   ENDSWITCH

   aRet2 := Array( Len( aRet ) )
   FOR i := 1 TO Len( aRet )
      aRet2[ i ] := Upper( RTrim( aRet[ i, 1 ] ) )
   NEXT i

RETURN aRet2


*-----------------------------------------------------------------*
FUNCTION SR_CreateDatabase( cDatabase )
*-----------------------------------------------------------------*

   LOCAL oCnn
   LOCAL lRet

   oCnn := SR_GetConnection()

   lRet := oCnn:exec( "CREATE DATABASE " + SR_DBQUALIFY( cDatabase, oCnn:nSystemID ) + iif( oCnn:lComments, " /* create database */", "" ), .T. ) == SQL_SUCCESS
   oCnn:Commit()

RETURN lRet


*-----------------------------------------------------------------*
FUNCTION ListTables( dbname )
*-----------------------------------------------------------------*

   LOCAL aRet
   LOCAL aRet2 := {}
   LOCAL i, tbname

   aRet := SR_ListTables( Lower( dbname ) )

   FOR i := 1 TO Len( aRet )
      tbname := aRet[ i ]
      IF ! Left( tbname, 3 ) $ "SR_"
         AAdd( aRet2, Lower( tbname ) )
      ENDIF
   NEXT i

RETURN aRet2


*-----------------------------------------------------------------*
FUNCTION My_SQL_Database_Connect( cDatabase )
*-----------------------------------------------------------------*
   LOCAL cConnection
   LOCAL aDatabaseList

   IF oServer == NIL
      MsgInfo( "Not connected to SQL server!" )
      RETURN .F.
   ENDIF

   aDatabaseList := SR_ListDatabases()
   IF Len( aDatabaseList ) == 0
      MsgInfo( "Error verifying database list!" )
      RELEASE WINDOW ALL
      QUIT
   ENDIF

   IF AScan( aDatabaseList, cDatabase ) == 0
      MsgInfo( "Database " + cDatabase + " doesn't exist!" )
      RETURN .F.
   ENDIF
   SR_EndConnection( nConnection )
   oServer := NIL

   cDatabase := Lower( cDatabase )
   cConnection := "HST=" + cHostName + ";UID=" + cUser + ";PWD=" + cPassword + ";DTB=" + cDatabase
   nConnection := SR_AddConnection( CONNECT_MYSQL, cConnection )
   IF nConnection <= 0
      MsgInfo( "Error connecting to SQL server. See sqlerror.log for details." )
      RELEASE WINDOW ALL
      QUIT
   ENDIF
   oServer := SR_GetConnection()

RETURN .T.


*-----------------------------------------------------------------*
FUNCTION My_SQL_Table_Create( cTable )
*-----------------------------------------------------------------*
   LOCAL aTableList
   LOCAL aStruct

   IF oServer == NIL
      MsgInfo( "Not connected to SQL Server..." )
      RETURN NIL
   ENDIF

   aTableList := ListTables( oServer:cDTB )

   IF AScan( aTableList, Lower( cTable ) ) != 0
      MsgInfo( "Table " + cTable + " allready exists!" )
      // Return Nil
   ENDIF

   If ! File( "NAMES.DBF" )
      MsgStop( "File Names.dbf doesn't exist!" )
      RETURN NIL
   ENDIF

   USE NAMES SHARED
   aStruct := dbStruct()
   CLOSE DATA

   SR_UseDeleteds( .F. )

   IF SR_file( cTable )
      sr_droptable( cTable )
   ENDIF

   dbCreate( cTable, aStruct, "SQLRDD" )

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION My_SQL_Table_Insert( cTable )
*-----------------------------------------------------------------*
   LOCAL aData
   LOCAL NrReg

   If ! MsgYesNo( "Import data from NAMES.DBF to table Names(MySql) ?", "Question", , , .F. )
      RETURN NIL
   ENDIF

   Form_1.StatusBar.Item( 1 ) := "Exporting from Names.DBF to Names(MySql) ..."

   If ! File( "NAMES.DBF" )
      MsgStop( "File Names.dbf doesn't exist!" )
      RETURN NIL
   ENDIF

   USE Names ALIAS Names NEW
   aData := hmg_DbfToArray()
   CLOSE DATA

   USE ( cTable ) EXCLUSIVE NEW VIA "SQLRDD"
   hmg_ArrayToDBF( aData )
   CLOSE DATA

   NrReg := Len( aData )
   Form_1.StatusBar.Item( 1 ) := " "
   MsgInfo( AllTrim( Str( NrReg ) ) + " records added to table " + cTable )

RETURN NIL


*-----------------------------------------------------------------*
FUNCTION My_SQL_Logout()
*-----------------------------------------------------------------*
   IF oServer != NIL
      dbCloseAll()
      SR_end()
      oServer := NIL
   ENDIF

RETURN NIL
