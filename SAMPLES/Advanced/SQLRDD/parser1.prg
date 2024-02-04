/*
* SQL Parser test routine
* Copyright (c) 2003 - Marcelo Lombardo  <marcelo@xharbour.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "sqlrdd.ch"

FUNCTION Main()

   LOCAL cComm
   LOCAL apCode
   LOCAL nErr
   LOCAL nPos

   SET LOGFILE TO "parser.txt"

   cComm := "SELECT TAB1.NAME, 200 AS " + chr(34) + "COL2" + chr(34) + ", 'ABC' AS " + chr(34) + "COL3" + chr(34) + ;
      ", B." + chr(34) + "ID" + chr(34) + " AS " + chr(34) + "VAL1" + chr(34) + ;
      " FROM TAB1, TAB2 B WHERE TAB1.NAME LIKE 'X%' AND TAB1.ID LEFT OUTER JOIN B.ID AND B.ID IS NOT NULL AND B.DUE_DATE > " + "[20021231]"

   ? "-------------------------------------------"
   ? cComm
   ? "-------------------------------------------"

   apCode := SR_SQLParse(cComm, @nErr, @nPos)

   IF len(apCode) > 0

      ? "SYSTEMID_ORACLE"
      ? "-------------------------------------------"
      ? SR_SQLCodeGen(apCode, {}, SYSTEMID_ORACLE)
      ? "-------------------------------------------"
      ? "SYSTEMID_MSSQL7"
      ? "-------------------------------------------"
      ? SR_SQLCodeGen(apCode, {}, SYSTEMID_MSSQL7)
      ? "-------------------------------------------"
      ? "SYSTEMID_IBMDB2"
      ? "-------------------------------------------"
      ? SR_SQLCodeGen(apCode, {}, SYSTEMID_IBMDB2)
      ? "-------------------------------------------"
      ? "SYSTEMID_POSTGR"
      ? "-------------------------------------------"
      ? SR_SQLCodeGen(apCode, {}, SYSTEMID_POSTGR)
      ? "-------------------------------------------"
      ? "SYSTEMID_MYSQL"
      ? "-------------------------------------------"
      ? SR_SQLCodeGen(apCode, {}, SYSTEMID_MYSQL)
      ? "-------------------------------------------"

   ELSE

      ? "Parse error", nErr, " at position ", nPos
      ? "-------------------------------------------"
      ? substr(cComm, nPos)
      ? "-------------------------------------------"

   ENDIF

   MsgInfo("Done.")

RETURN NIL

/*------------------------------------------------------------------------*/
