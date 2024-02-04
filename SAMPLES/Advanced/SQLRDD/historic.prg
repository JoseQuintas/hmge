/*
* SQLRDD Test
* Copyright (c) 2003 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "sqlrdd.ch"

#define RECORDS_IN_TEST                   1000
FIELD CODE_ID, DESCR, DAYS, DATE_LIM

/*------------------------------------------------------------------------*/

FUNCTION Main(cRDD, cDSN, lLog)

   /* CODE_IS is the primary key 1st key. See SQLRDD.CH for details about structure array */

   LOCAL aStruct := { ;
                     {"CODE_ID" , "C",  8, 0}, ;
                     {"CARDID"  , "C",  1, 0}, ;
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

   SET LOGFILE TO "historic.txt"

   ? ""
   ? "historic.exe"
   ? ""
   ? "SQLRDD Historic demo"
   ? "(c) 2003 - Marcelo Lombardo"
   ? ""

   DEFAULT cRDD := "SQLRDD"

   Connect(@cRDD, cDSN)    // see connect.prg

   ? "Connected to        :", SR_GetConnectionInfo(, SQL_DBMS_NAME), SR_GetConnectionInfo(, SQL_DBMS_VER)
   ? ""

   IF lLog != NIL
      ? "Starting LOG", SR_GetActiveConnection(), SR_StartLog()
   ENDIF

   SR_SetCreateAsHistoric(.T.)    // Will create a table with HISTORIC atribute

   ? "Creating table      :", dbCreate("TEST_HIST", aStruct, "SQLRDD")

   USE "TEST_HIST" SHARED VIA "SQLRDD"
   ? "Tell SQLRDD 'CODE_ID' is the primary key:", SR_SetColPK("CODE_ID")

   ? "Table opened. Alias :", select(), alias(), RddName()
   ? "Does current workarea has historic ?", SR_IsWAHist()
   ? "Creating 02 indexes..."

   s := seconds()

   INDEX ON CODE_ID + DESCR TO TEST_HIST_IND01
   INDEX ON str(DAYS) + dtos(DATE_LIM) TO TEST_HIST_IND02

   ? "Done, Elapsed time  :", seconds() - s, "seconds"
   ? "Default active historic date is now OS date()", SR_GetActiveDt(), date()
   ? ""
   ? "Let's force actual date to be 2023, jan 1st"

   SR_SetActiveDate(stod("20230101"))

   ? "Now, we will add 3 records at ", SR_GetActiveDt(), " - OS date is", date()
   ? "(note OS date is not related or changed by historic active date)"

   s := seconds()

   FOR i := 1 TO 3
      APPEND BLANK
      REPLACE CODE_ID  WITH strZero(i, 5)
      REPLACE DESCR    WITH dtoc(date()) + " - " + time()
      REPLACE DAYS     WITH (RECORDS_IN_TEST - i)
      REPLACE DATE_LIM WITH date()
      REPLACE ENABLE   WITH .T.
      REPLACE OBS      WITH "This is a memo field. Seconds since midnight : " + alltrim(str(seconds()))
   NEXT i
   dbCommit()

   ? "Done, Elapsed time  :", seconds() - s, "seconds"
   ? ""
   ? "Let's force actual date to be 2024, jan 1st"

   SR_SetActiveDate(stod("20240101"))

   ? "Now, we will add 3 records at ", SR_GetActiveDt()

   s := seconds()

   FOR i := 4 TO 6
      APPEND BLANK
      REPLACE CODE_ID  WITH strZero(i, 5)
      REPLACE DESCR    WITH dtoc(date()) + " - " + time()
      REPLACE DAYS     WITH (RECORDS_IN_TEST - i)
      REPLACE DATE_LIM WITH date()
      REPLACE ENABLE   WITH .T.
      REPLACE OBS      WITH "This is a memo field. Seconds since midnight : " + alltrim(str(seconds()))
   NEXT i
   dbCommit()

   ? "Elapsed time       :", seconds() - s, "seconds"
   ? ""
   ? "Next browse should show all 6 records", SR_SetActiveDate()

   dbGoTop()
   EDIT EXTENDED

   ? "Setting active date to 2023, may 1st - Note each workarea can have an independent " + chr(34) + "Current Date" + chr(34)
   SR_SetActiveDate(stod("20230515"))

   ? "Next browse should show only records 1, 2 and 3. (other records are not visible because they are created 7 months forward..)"

   SR_dbRefresh()
   dbGoTop()
   EDIT EXTENDED

   ? "Now, Let's change something in current date,", SR_SetActiveDate()
   ? "dbSeek(" + chr(34) + "00002" + chr(34) + ")", dbSeek("00002")

   IF found()
      REPLACE DESCR WITH "Changed this in " + dtos(SR_SetActiveDate())
      dbCommit()
   ENDIF

   ? "Next browse should show changed data in 'DESCR' field, record 2"

   dbGoTop()
   EDIT EXTENDED

   SR_SetActiveDate(SR_SetActiveDate() - 1)

   ? "But BEFORE may 15, this record was still not changed. Let's see how it was:"
   ? "Now active date is", SR_SetActiveDate(), "- onde day BEFORE descr field change"

   SR_dbRefresh()
   dbGoTop()
   EDIT EXTENDED

   ? "Let's see all records and versions in table, without any historic control"

   SR_DisableHistoric()    // This is PER WORKAREA.
   SR_dbRefresh()
   dbGoTop()
   EDIT EXTENDED

RETURN NIL

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
