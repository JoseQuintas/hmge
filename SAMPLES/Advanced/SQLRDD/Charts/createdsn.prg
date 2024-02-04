/*
* SQLRDD Create Dynamic DSN
* Sample application to create an ODBC panel entry
* Copyright (c) 2006 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "sqlrdd.ch"

REQUEST SR_ODBC

PROCEDURE MAIN()

   Local nDetected, cConnString, cAtributes, cDriver, i

   cConnString := "DSN=MySQL Datasource"
   cAtributes  := cConnString + ";Description=Access to World Database;Server=localhost;User=root;Password=mypass;Database=world;"
   cDriver     := "MySQL ODBC 8.0 ANSI Driver"
   
   If SR_InstallDSN( cDriver, cAtributes )

      Alert( "If you go to ODBC setup panel you should find created DSN. Hit OK to try to connect to data source." )

      nDetected := DetectDBFromDSN( cConnString )
   
      If nDetected > SYSTEMID_UNKNOW
         ? "Connecting to", cConnString
         If SR_AddConnection( nDetected, cConnString ) > 0
            ? "Connected to ", SR_GetConnectionInfo(, SQL_DBMS_NAME ), SR_GetConnectionInfo(, SQL_DBMS_VER )
            Alert( "Connection successful." )
         Else
            ? "Connection failure"
            Alert( "Connection failure." )
         EndIf
      EndIf
   Else
      ? "DSN creation failure:"
      For i = 1 to 8
         ? SR_InstallError( i )
      Next
      MsgStop( "DSN creation failure." )
   EndIf
   
RETURN

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/