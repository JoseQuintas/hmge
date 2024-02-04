/*
* SQLRDD dbf2sql
* Sample application to upload dbf files to SQL databases
* Copyright (c) 2003 - Marcelo Lombardo  <lombardo@uol.com.br>
* All Rights Reserved
*/

#define _HMG_OUTLOG
#include <minigui.ch>
#include "directry.ch"
#include "sqlrdd.ch"       // SQLRDD Main include

REQUEST DBFCDX

/*------------------------------------------------------------------------*/

FUNCTION Main(cRDD, cDSN)

   LOCAL nDrv
   LOCAL cDriver

   SET WINDOW MAIN OFF

   ? ""
   ? "dbf2sql.exe"
   ? ""
   ? "Sample tool to upload dbf files to SQL databases"
   ? "(c) 2004 - Marcelo Lombardo"
   ? ""

   IF Empty(cRDD)
      cRDD := "SQLRDD"
   ENDIF

   IF !Connect(@cRDD, cDSN)
      RETURN NIL
   ENDIF

   nDrv := HMG_Alert("Select source RDD", {"DBF&CDX", "DBF&NTX", "&QUIT"})

   DO CASE
   CASE nDrv == 1
      cDriver := "DBFCDX"
   CASE nDrv == 2
      cDriver := "DBFNTX"
   OTHERWISE
      RETURN NIL
   ENDCASE

   RddSetDefault(cDriver)

   SET DELETED ON

   ? "RDD in use          :", cRDD
   ? "RDD in source       :", cDriver

   upload(".\", "", cDriver, cRDD)

   MsgInfo("Done.")

RETURN NIL

/*------------------------------------------------------------------------*/

PROCEDURE upload(cBaseDir, cPrefix, cDriver, cRDD)

   LOCAL aFiles
   LOCAL aStruct
   LOCAL aFile
   LOCAL cFile
   LOCAL n

   /* upload files */

   aFiles := directory(cBaseDir + "*.dbf")

   FOR EACH aFile IN aFiles
      cFile := strtran(lower(alltrim(cPrefix + aFile[F_NAME])), ".dbf", "")
      dbUseArea(.T., cDriver, cBaseDir + aFile[F_NAME], "ORIG")
      ? "   Uploading...", cFile, "(" + hb_ntos(ORIG->(lastrec())), "records)"
      aStruct := ORIG->(dbStruct())
      ORIG->(dbCloseArea())

      IF sr_ExistTable( cFile )
         sr_DropTable( cFile )
      ENDIF
      dbCreate(cFile, aStruct, cRDD)
      dbUseArea(.T., cRDD, cFile, "DEST", .F.)
      APPEND FROM (cBaseDir + aFile[F_NAME]) VIA cDriver

      dbUseArea(.T., cDriver, cBaseDir + aFile[F_NAME], "ORIG")

      IF !empty(ordname(1))
         ? "   Creating indexes:", cFile
      ENDIF

      n := 1
      DO WHILE .T.
         IF empty(ordname(n))
            EXIT
         ENDIF
         ? "      =>", ordname(n), ",", ordkey(n), ",", ordfor(n)
         DEST->(ordCondSet(orig->(ordfor(n)), , .T., , , , NIL, NIL, NIL, NIL,, NIL, .F., .F., .F., .F.))
         DEST->(dbGoTop())
         DEST->(ordCreate(, orig->(OrdName(n)), orig->(ordKey(n)), &("{||" + orig->(OrdKey(n)) + "}")))
         ++n
      ENDDO

      dbSelectArea("DEST")
      DbCommit()
      DbUnlock()
      ORIG->( dbCloseArea() )
      DEST->( dbCloseArea() )
   NEXT

   /* recursive directories scan */

   aFiles := directory(cBaseDir + "*.*", "D")

   FOR EACH aFile IN aFiles
      IF left(aFile[F_NAME], 1) != "." .AND. "D" $ aFile[F_ATTR]
         cFile := cBaseDir + aFile[F_NAME] + HB_OsPathSeparator()
         ? "   Subdir......", cFile
         upload(cFile, cPrefix + lower(alltrim(aFile[F_NAME])) + "_", cDriver, cRDD)
      ENDIF
   NEXT

RETURN

/*------------------------------------------------------------------------*/

#include "connect.prg"

/*------------------------------------------------------------------------*/
