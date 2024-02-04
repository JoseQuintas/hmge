/*

  MySqlCli - MySQLClient written in Harbour/HMG

       (c) 2004 Cristobal Molla <cemese@terra.es>
       (c) 2005 Mitja Podgornik <yamamoto@rocketmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  This application use code from:
  -    Harbour (c) The Harbour project team (https://harbour.github.io)
  -    HMG Harbour Minigui (c) Roberto Lopez (https://sourceforge.net/projects/harbourminigui)

  March 2005: version 2.0 by Mitja Podgornik

   ! rewritten in english
   ! optimized for new Harbour tmysql changes
   + added export/import to/from Dbf
   + dynamic grid fill (only first 1000 records in old version)
   + cosmetic modifications

  October 2023  SQLRDD option, adaption by Grigory Filatov
  November 2023  add port option by Pierpaolo Martinello
*/

#include "hmg.ch"
#include "sqlrdd.ch"

REQUEST SQLRDD
REQUEST SR_MYSQL

#define PROGRAM "MySqlCli"
#define BSL chr(92)

MEMVAR lConnected
MEMVAR nConnection
MEMVAR cServer
MEMVAR cUser
MEMVAR cPaswd
MEMVAR cPort
MEMVAR cDBase
MEMVAR cCryptKey

MEMVAR aDatabases
MEMVAR aTables
MEMVAR lTableSelect
MEMVAR lBaseSelect
MEMVAR cBase
MEMVAR cTable

MEMVAR nScope
MEMVAR nFrom

*------------------------------------------------------------------------------*
PROCEDURE Main()
*------------------------------------------------------------------------------*

   PUBLIC lConnected := .F.
   PUBLIC nConnection := 0
   PUBLIC cServer := "localhost"
   PUBLIC nPort := 3306
   PUBLIC cUser := "root"
   PUBLIC cPaswd := ""
   PUBLIC cDBase := "test"
   PUBLIC cCryptKey := "topsecret"

   PUBLIC aDatabases := {}
   PUBLIC aTables := {}
   PUBLIC lTableSelect := .F.
   PUBLIC lBaseSelect := .F.
   PUBLIC cBase := ""
   PUBLIC cTable := ""

   PUBLIC nScope := 500 // max records for select scope (limit)
   PUBLIC nFrom := 0 // starting pointer for select scope - Don't touch!

   SET DATE GERMAN
   SET CENTURY ON
   SET MULTIPLE OFF WARNING
   SET CODEPAGE TO UNICODE

   IF File( "MySqlCli.ini" )
      BEGIN INI FILE "MySqlCli.ini"
         GET cServer SECTION "Login" ENTRY "server"
         GET nPort SECTION "Login" ENTRY "port"
         GET cUser SECTION "Login" ENTRY "user"
         GET cPaswd SECTION "Login" ENTRY "pass"
         GET cDBase SECTION "Login" ENTRY "database"
      END INI
      cPaswd := hb_decrypt( cPaswd, cCryptKey )
   ELSE
      BEGIN INI FILE "MySqlCli.ini"
         SET SECTION "Login" ENTRY "server" TO cServer
         SET SECTION "Login" ENTRY "port" TO nPort
         SET SECTION "Login" ENTRY "user" TO cUser
         SET SECTION "Login" ENTRY "pass" TO hb_crypt( cPaswd, cCryptKey )
         SET SECTION "Login" ENTRY "database" TO cDBase
      END INI
   ENDIF

   DEFINE WINDOW F_Main ;
         AT 0, 0 ;
         WIDTH 800 ;
         HEIGHT 600 ;
         TITLE PROGRAM ;
         ICON "A_ICO_MAIN" ;
         MAIN ;
         NOMAXIMIZE ;
         NOSIZE ;
         ON INIT {|| UpdateMain() } ;
         ON RELEASE Disconnect()

      DEFINE MAIN MENU

         DEFINE POPUP " &File "
            MENUITEM "  &Connect  " ;
               ACTION {|| Connect() } ;
               NAME mnuConnect
            MENUITEM "  &Disconnect  " ;
               ACTION {|| Disconnect() } ;
               NAME mnuDisconnect
            SEPARATOR
/*
            MENUITEM "  &Export to DBF  " ;
               ACTION {|| SQL2Dbf() } ;
               NAME mnusql2dbf
            MENUITEM "  &Import from DBF  " ;
               ACTION {|| Dbf2Sql( .T. ) } ;
               NAME mnudbf2sql
            SEPARATOR
*/
            MENUITEM "  &Exit  " ;
               ACTION F_Main.RELEASE ;
               NAME mnuEnd
         END POPUP

         DEFINE POPUP " &Help "
            MENUITEM "About" ;
               ACTION ShellAbout( "", PROGRAM + " v.2.0" + CRLF + "Cristobal Molla, Mitja Podgornik" )
         END POPUP

      END MENU

      DEFINE SPLITBOX
         DEFINE TOOLBAR Tbar_1 ;
               BUTTONSIZE 40, 32 ;
               FLAT ;
               RIGHTTEXT

            BUTTON tbbConnect ;
               CAPTION "Connect" ;
               PICTURE "BMP_32_CONNECT" ;
               ACTION {|| Connect() }

            BUTTON tbbDisconnect ;
               CAPTION "Disconnect" ;
               PICTURE "BMP_32_DISCONNECT" ;
               ACTION {|| Disconnect() }
/*
            BUTTON tbbsql2dbf ;
               CAPTION "Export to DBF" ;
               PICTURE "BMP_32_BASE" ;
               ACTION {|| SQL2Dbf() }

            BUTTON tbbdbf2sql ;
               CAPTION "Import from DBF" ;
               PICTURE "BMP_32_TABLE" ;
               ACTION {|| Dbf2Sql( .T. ) }
*/
         END TOOLBAR
      END SPLITBOX

      DEFINE STATUSBAR
         STATUSITEM ""
         STATUSITEM "" WIDTH 200
         STATUSITEM "" ICON "ICO_LEDOFF" WIDTH 035
      END STATUSBAR

      DEFINE TREE TREE_1 ;
            AT 60, 10 ;
            WIDTH 200 ;
            HEIGHT 460 ;
            ON CHANGE {|| TreeChange() } ;
            NODEIMAGES { "BMP_16_SERVER" } ;
            ITEMIMAGES { "BMP_16_ITEMOFF", "BMP_16_ITEMON" } ;
            ITEMIDS

      END TREE

      DEFINE TAB TABInfo ;
            AT 60, 220 ;
            WIDTH 565 ;
            HEIGHT 460 ;
            VALUE 1

         PAGE "&Structure"

            @ 30, 15 FRAME frmTable ;
               CAPTION "Structure" ;
               WIDTH 535 ;
               HEIGHT 415 ;
               BOLD

            @ 50, 30 GRID GRD_Table ;
               WIDTH 505 ;
               HEIGHT 380 ;
               HEADERS { "Name", "Type", ;
               "Len", "Dec", ;
               "Nullable", ;
               "SQL Type" } ;
               WIDTHS { 150, 45, 60, 45, 60, 125 } ;
               ON GOTFOCUS {|| setControl( .T. ) } ;
               ON LOSTFOCUS {|| setControl( .F. ) }

         END PAGE

         PAGE "&Data"

            @ 30, 15 FRAME frmData ;
               CAPTION "Data" ;
               WIDTH 535 ;
               HEIGHT 415 ;
               BOLD

            @ 50, 30 GRID GRD_Data ;
               WIDTH 505 ;
               HEIGHT 380 ;
               HEADERS { "" } ;
               WIDTHS { 100 } ;
               ITEMS { { "" } } ;
               VALUE 1 ;
               ON GOTFOCUS {|| setControl( .T. ) } ;
               ON CHANGE {|| AddData( F_Main.GRD_Data.Value ), ;
                  setMessage( "Record: " + ntrim( F_Main.GRD_Data.Value ) + "/" + nTrim( GetRecCount( cTable ) ), 2 ) } ;
               ON LOSTFOCUS {|| setControl( .F. ) } ;
               COLUMNSORT {}

         END PAGE

      END TAB

   END WINDOW

   setMessage()
   F_main.tabInfo.Enabled := .F.

   CENTER WINDOW F_Main
   ACTIVATE WINDOW F_Main

RETURN


*------------------------------------------------------------------------------*
FUNCTION Connect()
*------------------------------------------------------------------------------*
   LOCAL nRow, nCol

   IF lConnected
      RETURN NIL
   ENDIF

   nRow := GetProperty( "F_Main", "Row" ) + 200
   nCol := GetProperty( "F_Main", "Col" ) + 230

   DEFINE WINDOW F_Connect ;
         AT nRow, nCol ;
         WIDTH 315 ;
         HEIGHT 265 ;
         TITLE " Connect to MySQL server" ;
         MODAL ;
         NOSIZE ;
         nosysmenu

         ON KEY ESCAPE ACTION f_connect.release

      @ 10, 10 FRAME frm_Data ;
         CAPTION "" ;
         WIDTH 285 ;
         HEIGHT 180 ;
         BOLD

      @ 34, 20 LABEL lblServer ;
         VALUE "Server" ;
         WIDTH 50 ;
         HEIGHT 21

      @ 64, 20 LABEL lport ;
         VALUE "Port" ;
         WIDTH 55 ;
         HEIGHT 21

      @ 94, 20 LABEL lblUser ;
         VALUE "User" ;
         WIDTH 50 ;
         HEIGHT 21

      @ 124, 20 LABEL lblPaswd ;
         VALUE "Password" ;
         WIDTH 55 ;
         HEIGHT 21

      @ 154, 20 LABEL lblDBase ;
         VALUE "Database" ;
         WIDTH 55 ;
         HEIGHT 21

      @ 30, 85 TEXTBOX txtServer ;
         HEIGHT 21 ;
         VALUE cServer ;
         WIDTH 200 ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 60

      @ 60, 85 TEXTBOX txtPort ;
         HEIGHT 21 ;
         VALUE nPort;
         WIDTH 100 ;
         NUMERIC ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         ON ENTER F_Connect.btnConnect.ACTION ;
         MAXLENGTH 5

      @ 90, 85 TEXTBOX txtUser ;
         HEIGHT 21 ;
         VALUE cUser ;
         WIDTH 100 ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 40

      @ 120, 85 TEXTBOX txtPaswd ;
         HEIGHT 21 ;
         VALUE cPaswd ;
         WIDTH 100 ;
         PASSWORD ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         MAXLENGTH 40

      @ 150, 85 TEXTBOX txtDBase ;
         HEIGHT 21 ;
         VALUE cDBase;
         WIDTH 100 ;
         ON GOTFOCUS {|| setControl( .T. ) } ;
         ON LOSTFOCUS {|| setControl( .F. ) } ;
         ON ENTER F_Connect.btnConnect.ACTION ;
         MAXLENGTH 40

      @ 200, 145 BUTTON btnAbort ;
         CAPTION "&Abort" ;
         ACTION {|| f_connect.release } ;
         WIDTH 70 ;
         HEIGHT 25

      @ 200, 225 BUTTON btnConnect ;
         CAPTION "&Connect" ;
         ACTION {|| Login() } ;
         WIDTH 70 ;
         HEIGHT 25

   END WINDOW

   ACTIVATE WINDOW F_Connect

RETURN NIL


*------------------------------------------------------------------------------*
FUNCTION Login()
*------------------------------------------------------------------------------*
   cServer := AllTrim( F_Connect.txtServer.Value )
   cUser := AllTrim( F_Connect.txtUser.Value )
   cPaswd := AllTrim( F_Connect.txtPaswd.Value )
   cDBase := AllTrim( F_Connect.txtDBase.Value )
   nPort  := hb_ntos( F_Connect.txtPort.Value )

   IF ! Empty( cServer ) .AND. ! Empty( cUser ) .AND. ! Empty( cDBase )
      setMessage( "Connecting to MySQL server...", 1 )
      nConnection := sr_AddConnection( CONNECT_MYSQL, "MySQL=" + cServer + ";UID=" + cUser + ";PWD=" + cPaswd + ";DTB=" + cDBase + ";PRT=" + nPort )

      IF ( nConnection < 0 )
         MsgExclamation( "Error connecting to database. See sqlerror.log for details.",hb_ntos(nConnection) )
         RETURN NIL
      ELSE
         lConnected := .T.
         F_main.tabInfo.Enabled := .T.
         UpdateTree()
      ENDIF

      setMessage()
      UpdateMain()

      BEGIN INI FILE "MySqlCli.ini"
         SET SECTION "Login" ENTRY "server" TO cServer
         SET SECTION "Login" ENTRY "port" TO nPort
         SET SECTION "Login" ENTRY "user" TO cUser
         SET SECTION "Login" ENTRY "pass" TO hb_crypt( cPaswd, cCryptKey )
         SET SECTION "Login" ENTRY "database" TO cDBase
      END INI
   ENDIF

   F_connect.RELEASE

RETURN NIL


*------------------------------------------------------------------------------*
FUNCTION Disconnect()
*------------------------------------------------------------------------------*
   IF lConnected
      SR_End()
      lConnected := .F.
      F_main.tabinfo.VALUE := 1
      UpdateTree()
      UpdateMain()
      setMessage()
   ENDIF
   F_main.tabInfo.Enabled := .F.
   lBaseSelect := .F.
   lTableSelect := .F.
   F_Main.GRD_Table.DeleteAllItems
   F_Main.GRD_Data.DeleteAllItems

RETURN NIL


*------------------------------------------------------------------------------*
PROCEDURE UpdateTree()
*------------------------------------------------------------------------------*
/*
     Node number format: SBBTT
     where:
     S     node Server         1 - 9
     BB    node DataBases     01 - 99
     TT    item Tables        01 - 999
*/

   LOCAL i
   LOCAL j
   LOCAL nNodeBase
   LOCAL nNodeTable
   LOCAL nNodeSelect

   IF lConnected

      F_Main.TREE_1.DeleteAllItems
      F_Main.TREE_1.AddItem( cUser + "@" + cServer, 0, 1 )

      aDatabases := SR_ListDatabases()
      IF Len( aDatabases ) == 0
         MsgExclamation( "Error verifying database list. See sqlerror.log for details." )
         RETURN
      ENDIF

      FOR i := 1 TO Len( aDatabases )
         nNodeBase := Val( "1" + PadL( i, 2, "0" ) )
         F_Main.TREE_1.AddItem( aDatabases[ i ], 1, nNodeBase )

         SR_EndConnection( nConnection )
         nConnection := sr_AddConnection( CONNECT_MYSQL, "MySQL=" + cServer + ";UID=" + cUser + ";PWD=" + cPaswd + ";DTB=" + aDatabases[ i ] + ";PRT=" + nPort )

         IF nConnection < 0
            MsgExclamation( "Error connecting to database. See sqlerror.log for details." )
            RETURN
         ENDIF

         IF Upper( cDBase ) == aDatabases[ i ]
            nNodeSelect := nNodeBase
         ENDIF

         aTables := ListTables( aDatabases[ i ] )

         FOR j := 1 TO Len( aTables )
            nNodeTable := Val( nTrim( nNodeBase ) + PadL( j, 3, "0" ) )
            F_Main.TREE_1.AddItem( aTables[ j ], nNodeBase, nNodeTable )
         NEXT

      NEXT

      F_Main.TREE_1.Expand( 1 )
      IF nNodeSelect <> NIL
         F_Main.TREE_1.VALUE := nNodeSelect
         F_Main.TREE_1.Expand( nNodeSelect )
      ENDIF
   ELSE
      DoMethod( "F_Main", "TREE_1", "DeleteAllItems" )
   ENDIF

   cBase := ""
   cTable := ""
   lBaseSelect := .F.
   lTableSelect := .F.

RETURN


*------------------------------------------------------------------------------*
PROCEDURE UpdateMain()
*------------------------------------------------------------------------------*
   IF lConnected
      SetProperty( "F_Main", "TREE_1", "Enabled", .T. )
      SetProperty( "F_Main", "tabInfo", "Enabled", .T. )
      SetProperty( "F_Main", "tbbConnect", "Enabled", .F. )
      SetProperty( "F_Main", "tbbDisconnect", "Enabled", .T. )
      // SetProperty( "F_Main", "tbbSQL2Dbf", "Enabled", .T. )
      // SetProperty( "F_Main", "tbbDbf2SQL", "Enabled", .T. )
      SetProperty( "F_Main", "StatusBar", "Icon", 3, "ICO_LEDON" )
      SetProperty( "F_Main", "mnuConnect", "Enabled", .F. )
      SetProperty( "F_Main", "mnuDisconnect", "Enabled", .T. )
      // SetProperty( "F_Main", "mnusql2dbf", "Enabled", .T. )
      // SetProperty( "F_Main", "mnudbf2sql", "Enabled", .T. )
   ELSE
      SetProperty( "F_Main", "TREE_1", "Enabled", .F. )
      SetProperty( "F_Main", "tabInfo", "Enabled", .F. )
      SetProperty( "F_Main", "tbbConnect", "Enabled", .T. )
      SetProperty( "F_Main", "tbbDisconnect", "Enabled", .F. )
      // SetProperty( "F_Main", "tbbSQL2Dbf", "Enabled", .F. )
      // SetProperty( "F_Main", "tbbDbf2Sql", "Enabled", .F. )
      SetProperty( "F_Main", "StatusBar", "Icon", 3, "ICO_LEDOFF" )
      SetProperty( "F_Main", "mnuConnect", "Enabled", .T. )
      SetProperty( "F_Main", "mnuDisconnect", "Enabled", .F. )
      // SetProperty( "F_Main", "mnusql2dbf", "Enabled", .F. )
      // SetProperty( "F_Main", "mnudbf2sql", "Enabled", .F. )
   ENDIF

RETURN


*------------------------------------------------------------------------------*
PROCEDURE TreeChange()
*------------------------------------------------------------------------------*

   LOCAL nItem

   lTableSelect := .F.
   lBaseSelect := .F.
   nItem := GetProperty( "F_Main", "TREE_1", "Value" )

   DO CASE
   CASE nItem >= 1 .AND. nItem <= 9
      setMessage( "Databases: " + nTrim( Len( aDatabases ) ), 1 )

   CASE nItem >= 100 .AND. nItem <= 999
      cBase := GetProperty( "F_Main", "TREE_1", "Item", nItem )
      SR_EndConnection( nConnection )
      nConnection := sr_AddConnection( CONNECT_MYSQL, "MySQL=" + cServer + ";UID=" + cUser + ";PWD=" + cPaswd + ";DTB=" + cBase + ";PRT=" + nPort )
      aTables := ListTables( cBase )
      setMessage( "Tables in database " + Upper( cBase ) + ": " + nTrim( Len( aTables ) ), 1 )
      lBaseSelect := .T.

   CASE nItem >= 10000 .AND. nItem <= 999999
      cTable := Lower( GetProperty( "F_Main", "TREE_1", "Item", nItem ) )
      nItem := Val( SubStr( nTrim( nItem ), 1, 3 ) )
      cBase := GetProperty( "F_Main", "TREE_1", "Item", nItem )
      SR_EndConnection( nConnection )
      nConnection := sr_AddConnection( CONNECT_MYSQL, "MySQL=" + cServer + ";UID=" + cUser + ";PWD=" + cPaswd + ";DTB=" + cBase+ ";PRT=" + nPort )
      aTables := ListTables( cBase )
      lBaseSelect := .T.
      lTableSelect := .T.

      nFrom := 0

      UpdateTable()

      UpdateData()

      setMessage( "Records in table " + Upper( cTable ) + ": " + nTrim( GetRecCount( cTable ) ), 1 )

   ENDCASE

RETURN


*------------------------------------------------------------------------------*
PROCEDURE UpdateTable()
*------------------------------------------------------------------------------*

   LOCAL oCnn
   LOCAL aRet
   LOCAL aRow
   LOCAL i

   F_Main.GRD_Table.DeleteAllItems

   IF lConnected
      setMessage( "SQL Query: DESCRIBE " + Upper( cTable ) + "...", 1 )

      oCnn := SR_GetConnection()

      SWITCH oCnn:nSystemID

      CASE SYSTEMID_MYSQL
      CASE SYSTEMID_MARIADB
         oCnn:execute( "select * from " + cTable + " limit 1" )
         EXIT
      ENDSWITCH

      oCnn:iniFields( .F. )

      aRet := oCnn:aFields

      F_Main.GRD_Table.DisableUpdate
      FOR i := 1 TO Len( aRet )
         aRow := { aRet[ i, 1 ], aRet[ i, 2 ], aRet[ i, 3 ], aRet[ i, 4 ], aRet[ i, 5 ], SQLType( aRet[ i, 6 ] ) }
         F_Main.GRD_Table.addItem( aRow )
      NEXT i
      F_Main.GRD_Table.EnableUpdate

      setMessage()
   ENDIF

RETURN


*------------------------------------------------------------------------------*
PROCEDURE UpdateData()
*------------------------------------------------------------------------------*

   LOCAL oCnn
   LOCAL aRet := {}
   LOCAL i AS NUMERIC
   LOCAL nColumns
   LOCAL aStruct
   LOCAL aFields
   LOCAL aWidths
   LOCAL aTypes
   LOCAL aLine

   STATIC lBusy := .F.

   IF lBusy
      DO EVENTS
      RETURN
   ELSE
      lBusy := .T.

      setMessage( "SQL Query: SELECT * FROM " + Upper( cTable ), 1 )

      oCnn := SR_GetConnection()

      SWITCH oCnn:nSystemID

      CASE SYSTEMID_MYSQL
      CASE SYSTEMID_MARIADB
         oCnn:exec( "select * from " + cTable + " limit " + ntrim( nFrom ) + "," + ntrim( nScope ), .T., .T., @aRet )
         EXIT
      ENDSWITCH

      oCnn:execute( "select * from " + cTable + " limit 1" )
      oCnn:IniFields( .F. )
      aStruct := oCnn:aFields

      nColumns := Len( aStruct )
      aFields := Array( nColumns )
      aWidths := Array( nColumns )
      aTypes := Array( nColumns )

      FOR i := 1 TO nColumns
         aFields[ i ] := aStruct[ i, 1 ]
         IF aStruct[ i, 2 ] == NIL
            aTypes[ i ] := "N"
            aWidths[ i ] := 100
         ELSE
            aTypes[ i ] := aStruct[ i, 2 ]
            aWidths[ i ] := iif( aStruct[ i, 3 ] > Len( aStruct[ i, 1 ] ), ;
               aStruct[ i, 3 ] * 12, Len( aStruct[ i, 1 ] ) * 12 )
         ENDIF
         aWidths[ i ] := Min( 250, aWidths[ i ] )
      NEXT

      nColumns := GetProperty( "F_Main", "GRD_Data", "ColumnCount" )

      DO WHILE nColumns != 0
         F_Main.GRD_Data.DeleteColumn( nColumns )
         nColumns--
      ENDDO

      FOR i := 1 TO Len( aStruct )
         F_Main.GRD_Data.AddColumn( i, aFields[ i ], aWidths[ i ], iif( aTypes[ i ] == "C", 0, 1 ) )
      NEXT

      nColumns := GetProperty( "F_Main", "GRD_Data", "ColumnCount" )

      i := GetProperty( "F_Main", "GRD_Data", "Index" )
      _HMG_aControlHeadClick[ i ] := Array( nColumns )
      _HMG_aControlRangeMax[ i ] := Array( nColumns )
      AEval( Array( nColumns ), ;
         {| x, k | _HMG_aControlHeadClick[ i ][ k ] := {| n | HMG_SortColumn( n ) }, ;
         _HMG_aControlRangeMax[ i ][ k ] := 1, HB_SYMBOL_UNUSED( x ) } )

      F_Main.GRD_Data.DisableUpdate

      FOR i := 1 TO Len( aRet )
         IF ( i % 100 ) == 0
            DO EVENTS
            setmessage( "Record: " + ntrim( i ), 2 )
         ENDIF

         aLine := aRet[ i ]
         F_Main.GRD_Data.addItem( ItemChar( aLine, aTypes ) )
      NEXT

      F_Main.GRD_Data.EnableUpdate

      setMessage()

      lBusy := .F.
   ENDIF

RETURN


*------------------------------------------------------------------------------*
FUNCTION setControl( lValue )
*------------------------------------------------------------------------------*
   IF hb_defaultValue( lValue, .F. )
      SetProperty( thisWindow.NAME, this.NAME, "BackColor", { 255, 255, 200 } )
   ELSE
      SetProperty( thisWindow.NAME, this.NAME, "BackColor", { 255, 255, 255 } )
   ENDIF

RETURN NIL


*------------------------------------------------------------------------------*
FUNCTION setMessage( cMessage, nItem )
*------------------------------------------------------------------------------*
   IF cMessage == NIL
      SetProperty( "F_Main", "StatusBar", "Item", 1, " " )
      SetProperty( "F_Main", "StatusBar", "Item", 2, " " )
   ELSE
      SetProperty( "F_Main", "StatusBar", "Item", nItem, " " + cMessage )
   ENDIF

RETURN NIL


*------------------------------------------------------------------------------*
FUNCTION ntrim( nValue )
*------------------------------------------------------------------------------*

RETURN hb_ntos( nValue )


*------------------------------------------------------------------------------*
FUNCTION SR_ListDatabases()
*------------------------------------------------------------------------------*

   LOCAL oCnn
   LOCAL aRet := {}
   LOCAL aRet2 := {}
   LOCAL i, dbname

   oCnn := SR_GetConnection()

   SWITCH oCnn:nSystemID

   CASE SYSTEMID_MYSQL
   CASE SYSTEMID_MARIADB
      oCnn:exec( "show databases", .T., .T., @aRet )
      EXIT
   ENDSWITCH

   FOR i := 1 TO Len( aRet )
      dbname := Upper( RTrim( aRet[ i, 1 ] ) )
      if ! Right( dbname, 6 ) $ "SCHEMA" .AND. dbname <> "MYSQL" .AND. dbname <> "SYS"
         AAdd( aRet2, dbname )
      ENDIF
   NEXT i

RETURN aRet2


*------------------------------------------------------------------------------*
FUNCTION ListTables( dbname )
*------------------------------------------------------------------------------*

   LOCAL aRet
   LOCAL aRet2 := {}
   LOCAL i, tbname

   aRet := SR_ListTables( Lower( dbname ) )

   FOR i := 1 TO Len( aRet )
      tbname := aRet[ i ]
      if ! Left( tbname, 3 ) $ "SR_"
         AAdd( aRet2, Lower( tbname ) )
      ENDIF
   NEXT i

RETURN aRet2


*------------------------------------------------------------------------------*
FUNCTION GetRecCount( tbname )
*------------------------------------------------------------------------------*

   LOCAL oCnn
   LOCAL aRet := {}

   oCnn := SR_GetConnection()

   SWITCH oCnn:nSystemID

   CASE SYSTEMID_MYSQL
   CASE SYSTEMID_MARIADB
      oCnn:exec( "select count(*) from " + tbname, .T., .T., @aRet )
      EXIT
   ENDSWITCH

RETURN aRet[ 1 ][ 1 ]


*------------------------------------------------------------------------------*
FUNCTION AddData( nPos )
*------------------------------------------------------------------------------*

   LOCAL oCnn
   LOCAL aRet := {}
   LOCAL i
   LOCAL nColumns
   LOCAL aStruct
   LOCAL aTypes
   LOCAL aLine

   IF lConnected .AND. lTableSelect .AND. nPos == F_Main.GRD_Data.ItemCount

      nFrom += nScope

      setMessage( "SQL Query: SELECT * FROM " + Upper( cTable ), 1 )

      oCnn := SR_GetConnection()

      SWITCH oCnn:nSystemID

      CASE SYSTEMID_MYSQL
      CASE SYSTEMID_MARIADB
         oCnn:exec( "select * from " + cTable + " limit " + ntrim( nFrom ) + "," + ntrim( nScope ), .T., .T., @aRet )
         EXIT
      ENDSWITCH

      oCnn:execute( "select * from " + cTable + " limit 1" )
      oCnn:IniFields( .F. )
      aStruct := oCnn:aFields

      nColumns := Len( aStruct )
      aTypes := Array( nColumns )

      FOR i := 1 TO nColumns
         IF aStruct[ i, 2 ] == NIL
            aTypes[ i ] := "N"
         ELSE
            aTypes[ i ] := aStruct[ i, 2 ]
         ENDIF
      NEXT

      F_Main.GRD_Data.DisableUpdate

      FOR i := 1 TO Len( aRet )
         IF ( i % 100 ) == 0
            setmessage( "Record: " + ntrim( i ), 2 )
         ENDIF

         aLine := aRet[ i ]
         F_Main.GRD_Data.addItem( ItemChar( aLine, aTypes ) )
      NEXT

      F_Main.GRD_Data.EnableUpdate

      setMessage()

      F_Main.GRD_Data.VALUE := nPos

   ENDIF

RETURN NIL


*------------------------------------------------------------------------------*
FUNCTION ItemChar( aLine, aType )
*------------------------------------------------------------------------------*
   LOCAL aRet, i, l := Len( aLine )

   aRet := Array( l )
   FOR i := 1 TO l
      DO CASE
      CASE aType[ i ] == "N"
         aRet[ i ] := ntrim( aLine[ i ] )
      CASE aType[ i ] == "D"
         aRet[ i ] := DToC( aLine[ i ] )
      CASE aType[ i ] == "L"
         aRet[ i ] := iif( iif( ISLOGICAL( aLine[ i ] ), aLine[ i ], Asc( Left( aLine[ i ], 1 ) ) != 0 ), ".T.", ".F." )
      OTHERWISE
         aRet[ i ] := aLine[ i ]
      ENDCASE
   NEXT

RETURN aRet


*------------------------------------------------------------------------------*
FUNCTION SQLType( nType )
*------------------------------------------------------------------------------*

   LOCAL cType := "U"

   DEFAULT nType := 13

   SWITCH nType
   CASE SQL_CHAR
   CASE SQL_VARCHAR
   CASE SQL_NVARCHAR
   CASE SQL_GUID
      cType := "SQL_CHAR"
      EXIT
   CASE SQL_SMALLINT
   CASE SQL_TINYINT
      cType := "SQL_TINYINT"
      EXIT
   CASE SQL_BIT
      cType := "SQL_BIT"
      EXIT
   CASE SQL_NUMERIC
   CASE SQL_DECIMAL
   CASE SQL_INTEGER
   CASE SQL_BIGINT
   CASE SQL_FLOAT
   CASE SQL_REAL
   CASE SQL_DOUBLE
      cType := "SQL_NUMERIC"
      EXIT
   CASE SQL_DATE
   CASE SQL_TYPE_DATE
      cType := "SQL_DATE"
      EXIT
   CASE SQL_TIME
      cType := "SQL_TIME"
      EXIT
   CASE SQL_LONGVARCHAR
   CASE SQL_DB2_CLOB
   CASE SQL_FAKE_LOB
   CASE SQL_LONGVARBINARY
      cType := "SQL_LONGVARCHAR"
      EXIT
   CASE SQL_VARBINARY
      cType := "SQL_VARBINARY"
      EXIT
   CASE SQL_TIMESTAMP
   CASE SQL_TYPE_TIMESTAMP
   CASE SQL_DATETIME
      cType := "SQL_DATETIME"
   ENDSWITCH

   IF cType == "U"
      cType := "SQL_UNDEFINED"
   ENDIF

RETURN cType
