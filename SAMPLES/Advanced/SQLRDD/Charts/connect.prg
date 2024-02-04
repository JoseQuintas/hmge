/* IMPORTANT: THIS FILE IS NOT TO BE USED DIRECTLY. YOU SHOULD INCLUDE IT IN PROPER APPLICATION PRG FILE
              AS SHOWN IN DEMO01.PRG, PARSER2.PRG, MEMO.PRG, ETC., AND CALL CONNECT() FUNCTION.
*/

/*
* SQLRDD connection
* Sample applications connect routine
* Copyright (c) 2005 - Marcelo Lombardo  <lombardo@uol.com.br>
* All Rights Reserved
*/

#include "mysql.ch"        // Needed if you plan to use native connection to MySQL

REQUEST SQLRDD             // SQLRDD should be linked in
REQUEST SQLEX              // SQLRDD Extreme should be linked in

REQUEST SR_MYSQL           // Needed if you plan to use native connection to MySQL

/*------------------------------------------------------------------------*/

FUNCTION Connect(cRDD, cDatabase)

   LOCAL nCnn
   LOCAL nDetected
   LOCAL hIniFile
   LOCAL aKeys
   LOCAL nKey
   LOCAL cConnString
   LOCAL hDsn

   hIniFile := HB_ReadIni("sqlrdd.ini", .F., ,.F.)     // Read ini file in a hash table

   IF hIniFile == NIL
      Alert("Could not read from sqlrdd.ini")
      QUIT
   ENDIF

   IF cDatabase == NIL
      aKeys := HGetKeys(hIniFile)
      IF len(aKeys) == 0
         Alert("No connections available in sqlrdd.ini")
         QUIT
      ELSEIF len(aKeys) == 1
         nKey := 1
      ENDIF

      hDsn := HGetValueAt(hIniFile, nKey)

      IF !("CONNSTRING" $ hDsn)
         Alert("ConnString not found in " + aKeys[nKey])
         QUIT
      ENDIF
   ELSE
      IF !(cDatabase $ hIniFile)
         Alert("Connection [" + cDatabase + "] not found in sqlrdd.ini")
         QUIT
      ENDIF

      hDsn := hIniFile[cDatabase]

      IF !("CONNSTRING" $ hDsn)
         Alert("ConnString not found in " + cDatabase)
         QUIT
      ENDIF
   ENDIF

   cConnString := hDsn["CONNSTRING"]
   nDetected   := DetectDBFromDSN(cConnString)

   IF nDetected > SYSTEMID_UNKNOW
      //msgdebug("Connecting to", cConnString)
      nCnn := SR_AddConnection(nDetected, cConnString)
   ENDIF

   /* returns the connection handle or -1 if it fails */
   IF nCnn < 0
      Alert("Connection error. See sqlerror.log for details.")
      QUIT
   ENDIF

   IF valtype(cRDD) == "C"
      cRDD := alltrim(Upper(cRDD))
   ENDIF

   IF SR_GetConnection():nConnectionType != CONNECT_ODBC .AND. cRDD == "SQLEX"
      SET WINDOW MAIN OFF
      HMG_Alert("SQLRDD Extreme supports only ODBC connections.", {"Quit"})
      QUIT
   ENDIF

RETURN .T.

/*------------------------------------------------------------------------*/
