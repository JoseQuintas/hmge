/*
* SQLRDD Test
* Copyright (c) 2003 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "sqlrdd.ch"

FIELD D1, D2, D3, D4

/*------------------------------------------------------------------------*/

FUNCTION Main(cRDD, cDSN)

   /* CODE_ID is the primary key 1st key. See SQLRDD.CH for details about structure array */

   LOCAL aStruct := { ;
                     {"CODE_ID", "C",  8, 0, .F., , , , , 1}, ;
                     {"CARDID" , "C",  1, 0}, ;
                     {"D1"     , "M", 10, 0}, ;
                     {"D2"     , "M", 10, 0}, ;
                     {"D3"     , "M", 10, 0}, ;
                     {"D4"     , "M", 10, 0} ;
                    }

   ? ""
   ? "memo.exe"
   ? ""
   ? "Small SQLRDD MEMO test"
   ? "(c) 2003 - Marcelo Lombardo"
   ? ""

   DEFAULT cRDD := "SQLRDD"

   Connect(@cRDD, cDSN)    // see connect.prg

   ? "Connected to        :", SR_GetConnectionInfo(, SQL_DBMS_NAME), SR_GetConnectionInfo(, SQL_DBMS_VER)
   ? "RDD in use          :", cRDD
   ? "Creating table      :", dbCreate("TEST_TABLE_MEMO", aStruct, cRDD)

   USE "TEST_TABLE_MEMO" SHARED VIA cRDD

   ? "Appending "

   APPEND BLANK
   REPLACE CODE_ID WITH "aaaaa"
   REPLACE D1      WITH date()
   REPLACE D2      WITH 1000
   REPLACE D3      WITH "aaaa"
   REPLACE D4      WITH {9999999, 2, 3, 4, 5, 6, date(), "a"}

   COMMIT
   dbCloseArea()

   USE "TEST_TABLE_MEMO" SHARED VIA cRDD

   ? "D1", valtype(d1), d1
   ? "D2", valtype(d2), d2
   ? "D3", valtype(d3), d3
   ? "D4", valtype(d4), d4
   ? "D4", valtype(d4), sr_showvector(d4)

   dbCloseAll()

   MsgInfo( "Done")

RETURN NIL

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
