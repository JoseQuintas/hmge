/*
* SQLRDD Test
* Copyright (c) 2003 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "sqlrdd.ch"
#include "msg.ch"

#define RECORDS_IN_TEST       1000

/*------------------------------------------------------------------------*/

FUNCTION Main(cRDD, cDSN, lLog)

   /* CODE_ID is the primary key 1st key. See SQLRDD.CH for details about structure array */

   LOCAL aStruct := { ;
                     {"LI"      , "N",  2, 0}, ;
                     {"CODE_ID" , "C",  8, 0}, ;
                     {"CARDID"  , "C",  1, 0}, ;
                     {"DESCR2"  , "C", 20, 0, , , MULTILANG_FIELD_ON}, ;
                     {"DESCR"   , "C", 50, 0}, ;
                     {"PERCENT" , "N", 10, 2}, ;
                     {"DAYS"    , "N",  8, 0}, ;
                     {"DATE_LIM", "D",  8, 0}, ;
                     {"ENABLE"  , "L",  1, 0}, ;
                     {"OBS"     , "M", 10, 0}, ;
                     {"VALUE"   , "N", 18, 6} ;
                    }
   LOCAL i
   LOCAL s
   LOCAL oSql
   LOCAL nErr

   SET LOGFILE TO "mlang.txt"

   ? ""
   ? "mlang.exe"
   ? ""
   ? "SQLRDD multilanguage demo "
   ? "(c) 2005 - Marcelo Lombardo"
   ? ""

   DEFAULT cRDD := "SQLRDD"

   Connect(@cRDD, cDSN)    // see connect.prg

   ? "Connected to        :", SR_GetConnectionInfo(, SQL_DBMS_NAME), SR_GetConnectionInfo(, SQL_DBMS_VER)

   // Sets engine on, or no magic wll show
   SR_SetMultiLang(.T.)

   IF lLog != NIL
      ? "Starting LOG", SR_GetActiveConnection(), SR_StartLog()
   ENDIF

   ? "Creating table      :", dbCreate("TEST_MLANG", aStruct, "SQLRDD")

   USE "TEST_MLANG" SHARED VIA "SQLRDD"
   INDEX ON FIELD->CODE_ID TO TEST_MLANG_IND01

   ? "Appending " + alltrim(str(RECORDS_IN_TEST)) + " records and pushing 4 languages at same time in DESCR2 field.."

   s := seconds()

   FOR i := 1 TO RECORDS_IN_TEST
      APPEND BLANK

      REPLACE CODE_ID  WITH strZero(i, 5)
      REPLACE DESCR    WITH dtoc(date()) + " - " + time()
      REPLACE DAYS     WITH (RECORDS_IN_TEST - i)
      REPLACE DATE_LIM WITH date()
      REPLACE ENABLE   WITH .T.
      REPLACE OBS      WITH "This is a memo field. Seconds since midnight : " + alltrim(str(seconds()))

      // DESCR2 is setted as MULTILANG in dbCreate() array

      SR_SetBaseLang(LANG_EN_US)
      REPLACE DESCR2 WITH "Hello, friends"

      SR_SetBaseLang(LANG_PT_BR)
      REPLACE DESCR2 WITH "Ola, amigos"

      SR_SetBaseLang(LANG_DE_DE)
      REPLACE DESCR2 WITH "Hallo, Freunde"

      SR_SetBaseLang(LANG_ES_ES)
      REPLACE DESCR2 WITH "Hola, amigos"
   NEXT i

   COMMIT
   dbGoTop()
   ? "Done, Elapsed time  :", seconds() - s, "seconds"

   SR_SetBaseLang(LANG_EN_US)
   alert("Browse in English")
   EDIT EXTENDED

   SR_SetBaseLang(LANG_PT_BR)
   alert("Browse in Portuguese")
   EDIT EXTENDED

   alert("Browse in German")
   SR_SetBaseLang(LANG_DE_DE)
   EDIT EXTENDED

   SR_SetBaseLang(LANG_ES_ES)
   alert("Browse in Spanish")
   EDIT EXTENDED

   USE

   oSql := SR_GetConnection()

   SR_SetBaseLang(LANG_EN_US)
   nErr := oSql:exec("SELECT A.CODE_ID, A.DESCR2 FROM TEST_MLANG A WHERE A.CODE_ID < '00005'", , .T., ,"test.dbf")
   alert("Query in English")
   EDIT EXTENDED
   USE

   SR_SetBaseLang(LANG_PT_BR)
   nErr := oSql:exec("SELECT A.CODE_ID, A.DESCR2 FROM TEST_MLANG A WHERE A.CODE_ID < '00005'", , .T., , "test.dbf")
   alert("Query in Portuguese")
   EDIT EXTENDED
   USE

   SR_SetBaseLang(LANG_DE_DE)
   nErr := oSql:exec("SELECT A.CODE_ID, A.DESCR2 FROM TEST_MLANG A WHERE A.CODE_ID < '00005'", , .T., , "test.dbf")
   alert("Query in German")
   EDIT EXTENDED
   USE

   SR_SetBaseLang(LANG_ES_ES)
   nErr := oSql:exec("SELECT A.CODE_ID, A.DESCR2 FROM TEST_MLANG A WHERE A.CODE_ID < '00005'", , .T., , "test.dbf")
   alert("Query in Spanish")
   EDIT EXTENDED

   DbCloseAll()

RETURN NIL

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
