/*
* SQLRDD Test
* Copyright (c) 2008 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "sqlrdd.ch"
#include "dbinfo.ch"

#define RECORDS_IN_TEST                   1000
FIELD CODE_ID, DESCR, DAYS, DATE_LIM

/*------------------------------------------------------------------------*/

FUNCTION Main(cRdd, cDSN)

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
   LOCAL s
   LOCAL i

   IF Empty(cRdd)
      cRDD := "SQLRDD"
   ENDIF

   ? ""
   ? "filter.exe"
   ? ""
   ? "Smart SET FILTER demo"
   ? "(c) 2008 - Marcelo Lombardo"
   ? ""

   ? "Connecting to database..."

   Connect(cDSN)    // see connect.prg

   ? "Connected to        :", SR_GetConnectionInfo(, SQL_DBMS_NAME), SR_GetConnectionInfo(, SQL_DBMS_VER)
   ? "Creating table      :", dbCreate("TEST_FILTER", aStruct, cRDD)

   USE "TEST_FILTER" EXCLUSIVE VIA (cRDD)

   ? "Creating 02 indexes..."

   INDEX ON CODE_ID + DESCR TO TEST_FILTER_IND01
   INDEX ON str(DAYS) + dtos(DATE_LIM) TO TEST_FILTER_IND02

   ? "Appending " + alltrim(str(RECORDS_IN_TEST)) + " records.."

   s := seconds()

   FOR i := 1 TO RECORDS_IN_TEST
      APPEND BLANK
      REPLACE CODE_ID  WITH strZero(i, 5)
      REPLACE DESCR    WITH dtoc(date()) + " - " + time()
      REPLACE DAYS     WITH (RECORDS_IN_TEST - i)
      REPLACE DATE_LIM WITH date()
      REPLACE ENABLE   WITH .T.
      REPLACE OBS      WITH "This is a memo field. Seconds since midnight : " + alltrim(str(seconds()))
   NEXT i

   ? "dbCloseArea()      :", dbCloseArea()
   ? "Elapsed time       :", seconds() - s, "seconds"

   USE "TEST_FILTER" SHARED VIA (cRDD)

   ? "Opening Indexes"
   SET INDEX TO TEST_FILTER_IND01
   SET INDEX TO TEST_FILTER_IND02 ADDITIVE

   SET FILTER TO DAYS < 10    // Very fast and optimized back end filter

   ? "Set Filter DAYS < 10:", dbFilter()     // Returning filter expression is translated to SQL

   EDIT EXTENDED

   SET FILTER TO

   ? "Removing filter    :", dbFilter()

   dbGoTop()
   EDIT EXTENDED

   SET FILTER TO MyFunc()    // Slow and non optimized filter

   ? "Set Filter MyFunc()  ", dbFilter()     // Returning filter expression is translated to SQL
   ? " "
   ? "Note this is pretty slower!"

   EDIT EXTENDED

   SET FILTER TO
   ? "OrdKeyCount() ->" + Str(OrdKeyCount())

   SET SCOPE TO strZero(10, 5), strZero(20, 5)
   ? "SET SCOPE TO '" + strZero(10, 5) + "', '" + strZero(20, 5) + "'"
   DBGOTOP()

   ? "OrdKeyCount() ->" + Str(OrdKeyCount())

   dbGoTop()
   EDIT EXTENDED

   DbCloseAll()

RETURN NIL

/*------------------------------------------------------------------------*/

FUNCTION MyFunc()

RETURN DAYS < 10

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
