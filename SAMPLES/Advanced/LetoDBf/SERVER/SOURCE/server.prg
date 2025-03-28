/*
 * Leto db server
 *
 * Copyright 2008 Alexander S. Kresin <alex / at / belacy.belgorod.su>
 *
 *           2015-2018 Rolf 'elch' Beckmann
 * removing nearly anything else the pure PRG level server start functions.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"
#include "dbstruct.ch"
#include "rddsys.ch"
#include "common.ch"
#include "dbinfo.ch"
#include "fileio.ch"
#include "error.ch"
#include "rddleto.ch"
#include "hbsocket.ch"

#ifndef HB_HRB_BIND_DEFAULT
   #define HB_HRB_BIND_DEFAULT 0x0
#endif

REQUEST DBFNTX
REQUEST DBFCDX
REQUEST DBFFPT
REQUEST SIXCDX
REQUEST DBFNSX
REQUEST HB_MEMIO
/* REQUEST SDF, Delim */

#ifdef __BM
   REQUEST BMDBFNTX
   REQUEST BMDBFCDX
   REQUEST BMDBFNSX
   REQUEST BM_DBSEEKWILD
#endif

/* NULL as default GT */
ANNOUNCE HB_GTSYS
REQUEST HB_GT_NUL_DEFAULT

#if ! defined( __PLATFORM__WINDOWS )
   #define DEF_SEP      '/'
   #define DEF_CH_SEP   '\'
#else
   #define DEF_SEP      '\'
   #define DEF_CH_SEP   '/'
#endif

/* full command sets for UDF usage */
#ifdef LETO_FULLCMDSET_HB
   REQUEST __HB_EXTERN__
   #include "hbextern.ch"
#endif
#ifdef LETO_FULLCMDSET_CT
   #define __HBEXTERN__HBCT__REQUEST 1
   #include "hbct.hbx"
#endif

/* following selected functions are linked into server executable with REQUEST */
REQUEST OS, VERSION, HB_VERSION
REQUEST ABS, ALLTRIM, AT, CHR, CTOD, CDOW, CMONTH, DATE, DAY, DELETED, DESCEND, DTOC, DTOS, DOW, ;
        EMPTY, I2BIN, L2BIN, LEFT, LEN, LOWER, LTRIM, MAX, MIN, MONTH, OS, PAD, PADC, ;
        PADL, PADR, RAT, RECNO, RIGHT, ROUND, RTRIM, SPACE, STOD, STR, STRZERO, ;
        SUBSTR, REPLICATE, TIME, TRANSFORM, TRIM, UPPER, VAL, VALTYPE, YEAR
REQUEST HB_DATETIME, HB_DTOT, HB_TTOD, HB_NTOT, HB_TTON, HB_CTOT, HB_TTOC, ;
        HB_TTOS, HB_STOT, HB_HOUR, HB_MINUTE, HB_SEC, HB_VALTOEXP, HB_ZCOMPRESS
REQUEST HB_HEXTONUM, HB_NUMTOHEX, HB_NTOS
#ifdef LETO_SMALLCMDSET_CT
   REQUEST DOY, WEEK, BLANK
#endif

REQUEST hb_ATokens, hb_tokenGet, hb_tokenCount, hb_strformat
REQUEST FieldPos, FieldGet, FieldPut, hb_FieldType, hb_FieldLen, hb_FieldDec
REQUEST hb_WildMatch, hb_AtX
REQUEST Deleted, Found, Bof, Eof
#ifdef _STREAMFLEX_  /* enquirer */
   REQUEST hb_HAllocate, hb_HAutoAdd, hb_HBinary, hb_HCaseMatch, hb_HDefault, hb_HKeepOrder
   REQUEST hb_Hash, hb_HClear, hb_HFill, hb_HClone, hb_HCopy, hb_HMerge, hb_HSort, hb_HEval
   REQUEST hb_HHasKey, hb_HPos, hb_HScan, hb_HValueAt, hb_HKeyAt, hb_HPairAt, hb_HKeys, hb_HValues
   REQUEST hb_HSet, hb_HGet, hb_HDel, hb_HDelAt
#endif
REQUEST Array, AClone, ASize, ADel, AIns, AAdd, AEval, AScan, ASort
REQUEST hb_idleSleep, hb_milliSeconds

REQUEST dbGoTop, dbGoBottom, dbSkip, dbGoto, dbSeek, dbEval, dbInfo, dbStruct
REQUEST dbAppend, dbDelete, dbRecall, dbCommit, dbFilter, dbSetFilter
#ifndef __HARBOUR30__
   REQUEST hb_dbGetFilter, HB_WILDMATCHI, hb_RegexHas, hb_RegexLike
#endif
REQUEST ordKeyVal, dbOrderInfo, RDDinfo, OrdSetFocus, Alias, Select, dbSelectArea

REQUEST WAPI_SHELLEXECUTE_WAIT, HB_NTOC, hb_enumIndex, hb_cwd, LtoN
REQUEST hb_hrbRun, hb_hrbLoad, hb_hrbDo, hb_hrbUnLoad, hb_hrbGetFunsym, hb_hrbGetFunList
REQUEST HB_ZIPFILE, HB_UNZIPFILE
REQUEST HB_DIRECTORY, HB_ISARRAY, HB_ISCHAR, HB_ISLOGICAL, HB_ISBLOCK, ;
        HB_ISNUMERIC, HB_ISOBJECT, HB_ISNIL, hb_default, hb_ExecFromArray, ;
        hb_jsonDecode, hb_jsonEncode, hb_DirSepAdd, hb_DirBuild, hb_DirExists, ;
        hb_DefaultValue, hb_DirTemp, hb_DirUnbuild, hb_FileExists, hb_ForNext, ;
        hb_FNameDir, hb_FNameExt, hb_FNameExtSet, hb_FNameExtSetDef, hb_FNameMerge, ;
        hb_FNameName, hb_FNameNameExt, hb_FNameSplit, hb_eol, hb_ps, ;
        hb_Crypt, hb_DeCrypt, hb_CRC32, hb_memoRead, hb_memoWrit, Seconds

REQUEST FSEEK, FREAD, FREADSTR, FWRITE, FCLOSE, FERROR, HB_FEOF, HB_FREADLEN  /* !NO! FOPEN, FCREATE  */
REQUEST LETO_FOPEN, LETO_FCREATE, LETO_FCLOSE, LETO_FRENAME, LETO_FERASE

REQUEST LETO_VARSET, LETO_VARGET, LETO_VARINCR, LETO_VARDECR, LETO_VARDEL, LETO_VARGETLIST
REQUEST LETO_VARGETCACHED, LETO_BVALUE, LETO_BSEARCH

REQUEST LETO_GETUSTRUID, LETO_WUSLOG, LETO_GETAPPOPTIONS
REQUEST LETO_SELECT, LETO_SELECTAREA, LETO_ALIAS, LETO_AREAID, LETO_FTS
REQUEST LETO_RECLOCK, LETO_RECUNLOCK, LETO_TABLELOCK, LETO_TABLEUNLOCK
REQUEST LETO_DBUSEAREA, LETO_DBCLOSEAREA, LETO_ORDLISTADD
REQUEST LETO_DBCREATE, LETO_ORDCREATE
REQUEST LETO_DBEVAL, LETO_DBJOIN, LETO_DBTOTAL, LETO_DBLOCATE, LETO_DBCONTINUE
REQUEST __dbTotal

REQUEST LETO_IDLESLEEP
REQUEST LETO_UDFMUSTQUIT
REQUEST LETO_PROCESSRUN

/* don't !! use, a ToDo to remove elch special ;-) */
REQUEST MIXKEY

#ifdef __BM
REQUEST LBM_DbGetFilterArray, LBM_DbSetFilterArray, LBM_DbSetFilterArrayAdd
REQUEST LBM_DbSetFilterArrayDel, LBM_DbSetFilter
#endif

#ifdef __HB_EXT_CDP__
   /* ! all ! available codepages */
   /* #define __HBEXTERN__HBCDPAGE__REQUEST__
    * #include "hbcpage.hbx" */
   #include "hbextcdp.ch"
#else
   /* only selected codepages */
   #include "letocdp.ch"
#endif

#include "cmdleto.h"

STATIC s_cDirBase
STATIC s_pHrb
STATIC s_cIniName := "letodb.ini"
STATIC s_hMutex   := 0

THREAD STATIC s_hWASet

PROCEDURE Main( cCommand, cData )

   LOCAL oApp
   LOCAL cMutex := Upper( hb_ProgName() ), lMutex 

   IF Empty( cCommand )
      AEval( { ".", "\", ":", "/", " " }, {|cs| cMutex := StrTran( cMutex, cs, "_" ) } )
      s_hMutex := wapi_CreateMutex( NIL, NIL, cMutex )
      lMutex   := ( ! Empty( s_hMutex ) .AND. wapi_GetLastError() == 0 )
      IF ! lMutex
         WrLog( "LetoDBF Server is running. Error " + hb_ntos( wapi_GetLastError() ) + " mutex " + cMutex )
         RETURN
      ENDIF
   ENDIF

   s_cDirBase := hb_DirBase()
   leto_setDirBase( s_cDirBase )

   IF cCommand != NIL .AND. Lower( cCommand ) == "stop"

      IF ! Empty( cData )
         cData := Lower( cData )
         IF .NOT. ".ini" $ cData
            cData += ".ini"
         ENDIF
         s_cIniName := cData
      ENDIF

      /* connect and send QUIT */
      oApp := HApp():New()

      IF leto_SendMessage( oApp:nPort, LETOCMD_stop, oApp:cAddr )
         IF oApp:nDebugMode > 0
            WrLog( "Have send STOP to server at port " + hb_ntos( oApp:nPort ) + " , should soon go down ..." )
         ENDIF
      ELSE
         WrLog( "Can't STOP the server at port " + hb_ntos( oApp:nPort ) + " ( not started ? )" )
      ENDIF

      IF ! Empty( s_hMutex )
         wapi_ReleaseMutex( s_hMutex )
         s_hMutex := 0
      ENDIF

   ELSEIF cCommand != NIL .AND. Left( Lower( cCommand ), 6 ) == "reload"

      IF ! EMPTY( cData )
         cData := LOWER( cData )
         IF .NOT. ".hrb" $ cData
            IF .NOT. ".ini" $ cData
               cData += ".ini"
            ENDIF
            s_cIniName := cData
            cData := NIL
         ENDIF
      ENDIF
      /* send message to reload letoudf.hrb */
      oApp := HApp():New()
      IF ! leto_SendMessage( oApp:nPort, LETOCMD_udf_rel, oApp:cAddr, cData )
         WrLog( "Can't reload letoudf.hrb at port " + hb_ntos( oApp:nPort ) )
      ENDIF

   ELSE  /* start the server */

#ifdef __WIN_SERVICE__

      IF cCommand != NIL
         IF Lower( cCommand ) $ "config|install|uninstall|test" .AND. ! EMPTY( cData )
            cData := LOWER( cData )
            IF .NOT. ".ini" $ cData
               cData += ".ini"
            ENDIF
            s_cIniName := cData
         ENDIF
         oApp := HApp():New()

         IF Lower( cCommand ) == "install"
            IF leto_serviceInstall( "The famous LetoDBf database server for data in DBF tables", oApp:cSvcName, s_cIniName )
               WrLog( "LetoDB service has been successfully installed" )
               __RUN( "net start " + oApp:cSvcName )
            ELSE
               WrLog( "Error installing LetoDB service: " + Str( letowin_GetLastError() ) )
               IF letowin_GetLastError() == 1073
                  WrLog( "LetoDBf service is already installed, uninstall before" )
               ENDIF
            ENDIF
            RETURN
         ELSEIF Lower( cCommand ) == "uninstall"
            IF leto_serviceDelete( oApp:cSvcName )
               WrLog( "LetoDB service has been deleted" )
            ELSE
               WrLog( "Error deleting LetoDB service: " + Str( letowin_GetLastError() ) )
            ENDIF
            RETURN
         ELSEIF Lower( cCommand ) == "test"
            StartServer()
            RETURN
         ELSEIF Lower( cCommand ) != "config"
            ? "LetoDB { install | uninstall }"
            RETURN
         ENDIF
      ELSE
         oApp := HApp():New()
      ENDIF

      IF ! leto_serviceStart( "StartServer", oApp:cSvcName )
         WrLog( "LetoDB service have had some problems: " + Str( letowin_GetLastError() ) )
         ErrorLevel( 1 )
      ENDIF

#else

      IF cCommand != NIL .AND. Lower( cCommand ) == "config" .AND. ! EMPTY( cData )
         cData := Lower( cData )
         IF .NOT. ".ini" $ cData
            cData += ".ini"
         ENDIF
         s_cIniName := cData
      ENDIF

   #ifdef __LINUX_DAEMON__

      oApp := HApp():New()
      IF ! leto_Daemon( oApp:nSUserID, oApp:nSGroupID, oApp:cSUser )
         WrLog( "Error: server can't become a daemon" )
         ErrorLevel( 2 )
      ELSE
         StartServer()
      ENDIF

   #else  /* __CONSOLE__ || __WIN_DAEMON__ */

      StartServer()

   #endif

#endif

   ENDIF

   RETURN

PROCEDURE StartServer()

   LOCAL oApp := HApp():New()

   /* verify datapath */
   IF ! Empty( oApp:DataPath )
      IF ! hb_DirExists( oApp:DataPath )
         WrLog( "LetoDBf Server: DataPath '" + oApp:DataPath + "' does not exists .." )
         ErrorLevel( 2 )
         RETURN
      ENDIF
   ENDIF
   IF ( oApp:lPass4L .OR. oApp:lPass4M .OR. oApp:lPass4D ) .AND. ! hb_FileExists( oApp:cPassFile )
      WrLog( "LetoDBf Server: user credentials '" + oApp:cPassFile + "' does not exists .." )
      ErrorLevel( 2 )
      RETURN
   ENDIF

   leto_SetAppOptions( oApp:DataPath, oApp:nDriver, oApp:lFileFunc, oApp:lAnyExt,;
         oApp:lPass4L, oApp:lPass4M, oApp:lPass4D, oApp:cPassFile, oApp:lCryptTraffic,;
         oApp:lShare, oApp:lNoSaveWA,;
         oApp:nMaxVars, oApp:nMaxVarSize, oApp:nCacheRecords, oApp:nTables_max, oApp:nUsers_max,;
         oApp:nDebugMode, oApp:lOptimize, oApp:nAutOrder, oApp:nMemoType, oApp:lForceOpt, oApp:nBigLock,;
         oApp:lUDFEnabled, oApp:nMemoBlkSize, oApp:lLower, oApp:cTrigger, oApp:lHardCommit,;
         oApp:lSMBServer, oApp:cSMBPath, oApp:lBackupInfo, oApp:cDataLogFile )

   IF oApp:nDebugMode > 1
      WrLog( "LetoDBf Server at port " + ALLTRIM( STR( oApp:nPort ) ) + " try to start ..." )
   ENDIF
   leto_InitSet()
   leto_HrbLoad()
   leto_CreateData( oApp:cAddr, oApp:nPort, oApp:cAddrSpace, oApp:cServer, oApp:lCryptTraffic, oApp:cBackupInfo )

   IF ! leto_Server( oApp:nPort, oApp:cAddr, oApp:nTimeOut, oApp:nZombieCheck, oApp:cBCService, oApp:cBCInterface, oApp:nBCPort )
      WrLog( "Socket error " + hb_socketErrorString( hb_socketGetError() ) )
      ErrorLevel( 1 )
   ELSE
      WrLog( "Server at port " + ALLTRIM( STR( oApp:nPort ) ) + " have shutdown." )
   ENDIF

   RETURN

STATIC PROCEDURE leto_hrbLoad( cData )

   LOCAL lUdfEnabled := leto_GetAppOptions( LETOOPT_UDFENABLED )
   LOCAL nDebugMode := leto_GetAppOptions( LETOOPT_DEBUGLEVEL )
   LOCAL cHrbName, pHrb, pInit, aFunc
   MEMVAR oErr

   IF VALTYPE( cData ) != "C" .OR. EMPTY( cData )
      cHrbName := s_cDirBase + "letoudf.hrb"
   ELSE
      cHrbName := s_cDirBase + cData
   ENDIF

   BEGIN SEQUENCE
      IF File( cHrbName )
         IF lUdfEnabled
            pHrb := hb_hrbLoad( HB_HRB_BIND_DEFAULT, cHrbName )
            IF ! Empty( pHrb )
               WrLog( "UDF file: " + cHrbName + " have been loaded." )

               s_pHrb = pHrb
               IF ! Empty( pInit := hb_hrbGetFunSym( s_pHrb, 'UDF_Init' ) )
                  hb_ExecFromArray( pInit )
               ELSE
                  aFunc := hb_hrbGetFunList( s_pHrb )
                  IF ! EMPTY( aFunc )
                     hb_hrbGetFunSym( s_pHrb, aFunc[ 1 ] )
                  ENDIF
               ENDIF
            ENDIF
         ELSE
            WrLog( "UDF Error: using remote functions is disabled." )
         ENDIF
      ELSEIF nDebugMode > 0 .AND. lUdfEnabled
         WrLog( "UDF file: " + cHrbName + " not present." )
      ENDIF

   RECOVER USING oErr
       WrLog( "UDF file : " + cHrbName + " contains error, not loaded." )
       WrLog( "UDF Error: " + Leto_ErrorMessage( oErr ) )
   END SEQUENCE

   RETURN


PROCEDURE leto_UdfReload( cData )

   LOCAL lUdfEnabled := leto_GetAppOptions( LETOOPT_UDFENABLED )

   IF lUdfEnabled
      IF ! Empty( s_pHrb )
         hb_hrbUnload( s_pHrb )
         s_pHrb := NIL
         WrLog( "UDF file have been unloaded." )
      ENDIF
      IF VALTYPE( cData ) == "C" .AND. RIGHT( cData, 1 ) == ";"
         cData := LEFT( cData, LEN( cData ) - 1 )
      ENDIF
      leto_hrbLoad( cData )
   ELSE
      WrLog( "UDF Error: using remote functions is disabled." )
   ENDIF

   RETURN


EXIT PROCEDURE EXITP

   LOCAL pExit

   IF ! Empty( s_pHrb ) .AND. ! Empty( pExit := hb_hrbGetFunSym( s_pHrb, 'UDF_Exit' ) )
      hb_ExecFromArray( pExit )
   ENDIF

   leto_ReleaseData()

   RETURN

CLASS HApp

   DATA cServer       INIT NIL
   DATA cAddr         INIT NIL
   DATA nPort         INIT 2812
   DATA nTimeOut      INIT -1
   DATA DataPath      INIT ""
   DATA LogFile       INIT ""
   DATA lLower        INIT .F.
   DATA lFileFunc     INIT .F.
   DATA lAnyExt       INIT .F.
   DATA lShare        INIT .T.
   DATA lNoSaveWA     INIT .T.
   DATA nDriver       INIT 0
   DATA nBigLock      INIT 0
   DATA lPass4M       INIT .F.
   DATA lPass4L       INIT .F.
   DATA lPass4D       INIT .F.
   DATA cPassFile     INIT "leto_users"
   DATA nSUserID      INIT 0
   DATA nSGroupID     INIT 0
   DATA cSUser        INIT NIL
   DATA lCryptTraffic INIT .F.
   DATA cTrigger
   DATA nZombieCheck  INIT 0
   DATA cBCService
   DATA cBCInterface
   DATA nBCPort
   DATA nDebugMode    INIT 1
   DATA nMaxVars
   DATA nMaxVarSize
   DATA nCacheRecords INIT 10
   DATA nTables_max
   DATA nUsers_max
   DATA lOptimize     INIT .T.
   DATA nAutOrder
   DATA nMemoType     INIT 0
   DATA lForceOpt     INIT .F.
   DATA lUDFEnabled   INIT .F.
   DATA nMemoBlkSize  INIT 0
   DATA lHardCommit   INIT .F.
   DATA lSMBServer    INIT .F.
   DATA cSMBPath      INIT ""
   DATA cAddrSpace
   DATA cSvcName      INIT "LetoDBf_Service"
   DATA lBackupInfo   INIT .T.
   DATA cBackupInfo   INIT "BACK-UP,WAITING,ESC-> GO ,ESC->QUIT"
   DATA cDataLogFile  INIT ""

   METHOD New()

ENDCLASS

METHOD New() CLASS HApp

   LOCAL aIni, i, j, cValue
   LOCAL cTmp, nTmp, cPath, nDriver

#if ! defined( __PLATFORM__WINDOWS )

   IF File( "/etc/" + s_cIniName )
      aIni := rdIni( "/etc/" + s_cIniName )
   ELSEIF File( s_cDirBase + s_cIniName )
      aIni := rdIni( s_cDirBase + s_cIniName )
   ENDIF

#else

   IF File( s_cDirBase + s_cIniName )
      aIni := rdIni( s_cDirBase + s_cIniName )
   ENDIF

#endif

   IF ! Empty( aIni )
      FOR i := 1 TO Len( aIni )
         IF aIni[ i, 1 ] == "MAIN"
            FOR j := 1 TO Len( aIni[ i, 2 ] )
               cValue := aIni[ i, 2, j, 2 ]

               SWITCH aIni[ i, 2, j, 1 ]
               CASE "SERVER"
                  ::cServer := cValue
                  EXIT
               CASE "PORT"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp >= 1024
                     ::nPort := nTmp
                  ENDIF
                  EXIT
               CASE "IP"
                  IF ! EMPTY( cValue )
                     ::cAddr := cValue
                     IF ! leto_isValidIP4( ::cAddr )
                        ::cAddr := IPForInterface( ::cAddr )
                     ENDIF
                  ENDIF
                  EXIT
               CASE "TIMEOUT"
                  ::nTimeOut := INT( Val( cValue ) )
                  EXIT
               CASE "DATAPATH"
                  ::DataPath := StrTran( cValue, DEF_CH_SEP, DEF_SEP )
                  IF Right( ::DataPath, 1 ) $ DEF_SEP
                     ::DataPath := Left( ::DataPath, Len( ::DataPath ) - 1 )
                  ENDIF
                  EXIT
               CASE "LOGPATH"
                  ::LogFile := StrTran( cValue, DEF_CH_SEP, DEF_SEP )
                  IF ! Empty( ::LogFile )
                     IF Right( ::LogFile, 1 ) != DEF_SEP
                        ::LogFile += DEF_SEP
                     ENDIF
                     leto_setDirBase( ::LogFile )
                  ENDIF
                  EXIT
               CASE "LOWER_PATH"
                  ::lLower := ( cValue == '1' )
                  EXIT
               CASE "ENABLEFILEFUNC"
                  ::lFileFunc := ( cValue == '1' )
                  EXIT
               CASE "ENABLEANYEXT"
                  ::lAnyExt := ( cValue == '1' )
                  EXIT
               CASE "SHARE_TABLES"
                  ::lShare := ( cValue == '1' )
                  EXIT
               CASE "NO_SAVE_WA"
                  ::lNoSaveWA := ( cValue == '1' )
                  EXIT
               CASE "DEFAULT_DRIVER"
                  ::nDriver := iif( Lower( cValue ) == "ntx", LETO_NTX, 0 )
                  EXIT
               CASE "LOCK_SCHEME"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp >= 0 .AND. nTmp <= 6
                     ::nBigLock := nTmp
                  ENDIF
                  EXIT
               CASE "PASS_FOR_LOGIN"
                  ::lPass4L := ( cValue == '1' )
                  EXIT
               CASE "PASS_FOR_MANAGE"
                  ::lPass4M := ( cValue == '1' )
                  EXIT
               CASE "PASS_FOR_DATA"
                  ::lPass4D := ( cValue == '1' )
                  EXIT
               CASE "PASS_FILE"
                  ::cPassFile := cValue
                  EXIT
               CASE "SERVER_USER"
                  ::cSUser := cValue
                  EXIT
               CASE "SERVER_UID"
                  ::nSUserID := INT( Val( cValue ) )
                  EXIT
               CASE "SERVER_GID"
                  ::nSGroupID := INT( Val( cValue ) )
                  EXIT
               CASE "CRYPT_TRAFFIC"
                  ::lCryptTraffic := ( cValue == '1' )
                  EXIT
               CASE "MAX_VARS_NUMBER"
                  ::nMaxVars := INT( Val( cValue ) )
                  EXIT
               CASE "MAX_VAR_SIZE"
                  ::nMaxVarSize := INT( Val( cValue ) )
                  EXIT
               CASE "CACHE_RECORDS"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp > 0
                     ::nCacheRecords := nTmp
                  ENDIF
                  EXIT
               CASE "TABLES_MAX"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp > 100 .AND. nTmp <= 1000000
                     ::nTables_max := nTmp
                  ENDIF
                  EXIT
               CASE "USERS_MAX"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp >= 9 .AND. nTmp < 65535
                     ::nUsers_max := nTmp
                  ENDIF
                  EXIT
               CASE "DEBUG"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp >= 0
                     ::nDebugMode := nTmp
                  ENDIF
                  EXIT
               CASE "HARDCOMMIT"
                  ::lHardCommit := ( cValue == '1' )
                  EXIT
               CASE "OPTIMIZE"
                  ::lOptimize := ( cValue == '1' )
                  EXIT
               CASE "AUTORDER"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp >= 0 .AND. nTmp < 65535
                     ::nAutOrder := nTmp
                  ENDIF
                  EXIT
               CASE "MEMO_BSIZE"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp > 65536
                     nTmp := 65536
                  ELSEIF nTmp < 32
                     nTmp := 0  /* default size for memotype */
                  ELSE
                     nTmp := Int( nTmp / 32 ) * 32
                  ENDIF
                  ::nMemoBlkSize := nTmp
                  EXIT
               CASE "MEMO_TYPE"
                  IF Lower( cValue ) $ 'dbt'
                     ::nMemoType := DB_MEMO_DBT
                  ELSEIF Lower( cValue ) $ 'fpt'
                     ::nMemoType := DB_MEMO_FPT
                  ELSEIF Lower( cValue ) $ 'smt'
                     ::nMemoType := DB_MEMO_SMT
                  ENDIF
                  EXIT
               CASE "FORCEOPT"
                  ::lForceOpt := ( cValue == '1' )
                  EXIT
               CASE "ALLOW_UDF"
                  ::lUDFEnabled := ( cValue == '1' )
                  EXIT
               CASE "TRIGGER"
                  ::cTrigger := cValue
                  EXIT
               CASE "ZOMBIE_CHECK"
                  ::nZombieCheck := INT( Val( cValue ) )
                  EXIT
               CASE "BC_SERVICES"
                  ::cBCService := cValue
                  IF Right( ::cBCService, 1 ) != ";"
                     ::cBCService += ";"
                  ENDIF
                  EXIT
               CASE "BC_INTERFACE"
                  ::cBCInterface := cValue
                  IF ! leto_isValidIP4( ::cBCInterface )
                     ::cBCInterface := IPForInterface( ::cBCInterface )
                  ENDIF
                  EXIT
               CASE "BC_PORT"
                  nTmp := INT( Val( cValue ) )
                  IF nTmp >= 1024
                     ::nBCPort := nTmp
                  ENDIF
                  EXIT
               CASE "SMB_SERVER"
                  ::lSMBServer := ( cValue == '1' )
                  EXIT
               CASE "SMB_PATH"
                  cTmp := StrTran( cValue, DEF_CH_SEP, DEF_SEP )
                  IF AT( ":", cTmp ) < 2 .OR. Right( cTmp, 1 ) == ":"
                     cTmp := ""
                  ENDIF
                  ::cSMBPath := cTmp
                  EXIT
               CASE "IP_SPACE"
                  ::cAddrSpace := cValue
                  IF Right( ::cAddrSpace, 1 ) != ";"
                     ::cAddrSpace += ";"
                  ENDIF
                  EXIT
               CASE "SVC_NAME"
                  cTmp := AllTrim( cValue )
                  IF ! Empty( cTmp ) .AND. Len( cTmp ) < 236  /* 256, but config to add */
                     ::cSvcName := cTmp
                  ENDIF
                  EXIT
               CASE "BACKUP_INFO"
                  cTmp := LEFT( AllTrim( cValue ), 255 )
                  IF LEN( cTmp ) > 2
                     ::lBackupInfo := .T.
                     ::cBackupInfo := StrTran( cTmp, ";", "," )
                  ELSE
                     ::lBackupInfo := .F.
                     ::cBackupInfo := ""
                  ENDIF
                  EXIT
               CASE "DATA_LOGFILE"
                  cTmp := LEFT( AllTrim( cValue ), 255 )
                  ::cDataLogFile := cTmp
                  EXIT
               ENDSWITCH

            NEXT
         ELSEIF aIni[ i, 1 ] == "DATABASE"
            cPath := nDriver := Nil
            FOR j := 1 TO Len( aIni[ i, 2 ] )
               IF aIni[ i, 2, j, 1 ] == "DATAPATH"
                  cPath := StrTran( aIni[ i, 2, j, 2 ], DEF_CH_SEP, DEF_SEP )
                  IF Right( cPath, 1 ) $ DEF_SEP
                     cPath := Left( cPath, Len( cPath ) - 1 )
                  ENDIF
               ELSEIF aIni[ i, 2, j, 1 ] == "DRIVER"
                  nDriver := iif( ( cTmp := Lower( aIni[ i, 2, j, 2 ] ) ) == "cdx", ;
                     0, iif( cTmp == "ntx", LETO_NTX, Nil ) )
               ENDIF
            NEXT
            IF cPath != Nil
               cPath := StrTran( cPath, DEF_CH_SEP, DEF_SEP )
               IF Left( cPath, 1 ) != DEF_SEP
                  cPath := DEF_SEP + cPath
               ENDIF
               IF Right( cPath, 1 ) != DEF_SEP
                  cPath += DEF_SEP
               ENDIF
               leto_AddDataBase( cPath, iif( nDriver == Nil, ::nDriver, nDriver ) )
            ENDIF
         ENDIF
      NEXT
   ENDIF

   IF ::lLower
      SET( _SET_FILECASE, 1 )
      SET( _SET_DIRCASE, 1 )
   ENDIF

   RETURN Self

/* NEW: called with non argument all relevant states are saved */
FUNCTION Leto_SetEnv( xScope, xScopeBottom, xOrder, cFilter, lDeleted )

   LOCAL cWA := ALIAS(), i

   IF EMPTY( cWA )
      RETURN NIL
   ENDIF
   IF VALTYPE( s_hWASet ) != "H"
      s_hWASet := hb_Hash()
   ENDIF
   IF hb_HPos( s_hWASet, cWA ) < 1
      s_hWASet[ cWA ] := hb_Hash()
      s_hWASet[ cWA ][ "nRecNo" ] := RECNO()
   ENDIF

   IF PCount() == 0 .AND. LEN( s_hWASet[ cWA ] ) == 1
      s_hWASet[ cWA ][ "nOldOrder" ] := OrdNumber()
      s_hWASet[ cWA ][ "cOldFilter" ] := DbFilter()
      s_hWASet[ cWA ][ "lOldDeleted" ] := SET( _SET_DELETED )
      IF OrdCount() > 0
         s_hWASet[ cWA ][ "aScopes" ] := {}
         FOR i := 1 TO OrdCount()
            ordSetFocus( i )
            AADD( s_hWASet[ cWA ][ "aScopes" ],;
                  { i, dbOrderInfo( DBOI_SCOPETOP ), dbOrderInfo( DBOI_SCOPEBOTTOM ) } )
         NEXT i
         ordSetFocus( s_hWASet[ cWA ][ "nOldOrder" ] )
      ENDIF
   ELSE
      IF hb_HPos( s_hWASet[ cWA ], "nOldOrder" ) < 1
         s_hWASet[ cWA ][ "nOldOrder" ] := OrdNumber()
      ENDIF
      IF ValType( xOrder) $ "CN"
         ordSetFocus( xOrder )
      ENDIF
      IF ValType( cFilter ) == "C"
         IF hb_HPos( s_hWASet[ cWA ], "lOldDeleted" ) < 1
            s_hWASet[ cWA ][ "cOldFilter" ] := DbFilter()
         ENDIF
         IF ! Empty( cFilter )
            dbSetFilter( &( "{||" + cFilter + "}" ), cFilter )
         ELSE
            dbClearFilter()
         ENDIF
      ENDIF
      IF VALTYPE( lDeleted ) == "L"
         IF hb_HPos( s_hWASet[ cWA ], "lOldDeleted" ) < 1
            s_hWASet[ cWA ][ "lOldDeleted" ] := SET( _SET_DELETED )
         ENDIF
         SET( _SET_DELETED, lDeleted )
      ENDIF
      IF IndexOrd() > 0 .AND. ! EMPTY( IndexKey() ) .AND. VALTYPE( xScope ) == VALTYPE( &( IndexKey() ) )
         IF hb_HPos( s_hWASet[ cWA ], "aScopes" ) < 1
            s_hWASet[ cWA ][ "aScopes" ] := {}
         ENDIF
         IF ASCAN( s_hWASet[ cWA ][ "aScopes" ], { | aItem | aItem[ 1 ] == OrdNumber() } ) < 1
            AADD( s_hWASet[ cWA ][ "aScopes" ],;
                  { OrdNumber(), dbOrderInfo( DBOI_SCOPETOP ), dbOrderInfo( DBOI_SCOPEBOTTOM ) } )
         ENDIF
         dbOrderInfo( DBOI_SCOPETOP, /*filename*/, /*iOrder*/, xScope )
      ENDIF
      IF IndexOrd() > 0 .AND. ! EMPTY( IndexKey() ) .AND. VALTYPE( xScopeBottom ) == VALTYPE( &( IndexKey() ) )
         IF hb_HPos( s_hWASet[ cWA ], "aScopes" ) < 1
            s_hWASet[ cWA ][ "aScopes" ] := {}
         ENDIF
         IF ASCAN( s_hWASet[ cWA ][ "aScopes" ], { | aItem | aItem[ 1 ] == OrdNumber() } ) < 1
            AADD( s_hWASet[ cWA ][ "aScopes" ],;
                  { OrdNumber(), dbOrderInfo( DBOI_SCOPETOP ), dbOrderInfo( DBOI_SCOPEBOTTOM ) } )
         ENDIF
         dbOrderInfo( DBOI_SCOPEBOTTOM,,, xScopeBottom )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION Leto_ClearEnv()

   LOCAL nWA := SELECT(), cWA, i

   IF VALTYPE( s_hWASet ) == "H"
      DO WHILE LEN( s_hWASet ) > 0
         cWA := hb_HKeyAt( s_hWASet, 1 )
         IF SELECT( cWA ) > 0
            SELECT ( cWA )
         ELSE
            hb_HDel( s_hWASet, cWA )
            LOOP
         ENDIF

         IF hb_HPos( s_hWASet[ cWA ], "lOldDeleted" ) > 0
            SET( _SET_DELETED, s_hWASet[ cWA ][ "lOldDeleted" ] )
            hb_HDel( s_hWASet[ cWA ], "lOldDeleted" )
         ENDIF

         /* done before restoring ordSetFocus */
         IF hb_HPos( s_hWASet[ cWA ], "aScopes" ) > 0 .AND. VALTYPE( s_hWASet[ cWA ][ "aScopes" ] ) == "A"
            i := LEN( s_hWASet[ cWA ][ "aScopes" ] )
            DO WHILE i > 0
               ordSetFocus( s_hWASet[ cWA ][ "aScopes" ][ i ][ 1 ] )
               IF VALTYPE( s_hWASet[ cWA ][ "aScopes" ][ i ][ 2 ] ) != "U"
                  dbOrderInfo( DBOI_SCOPETOP,,, s_hWASet[ cWA ][ "aScopes" ][ i ][ 2 ] )
               ELSE
                  dbOrderInfo( DBOI_SCOPETOPCLEAR )
               ENDIF
               IF VALTYPE( s_hWASet[ cWA ][ "aScopes" ][ i ][ 3 ] ) != "U"
                  dbOrderInfo( DBOI_SCOPEBOTTOM,,, s_hWASet[ cWA ][ "aScopes" ][ i ][ 3 ] )
               ELSE
                  dbOrderInfo( DBOI_SCOPEBOTTOMCLEAR )
               ENDIF
               i--
            ENDDO
            hb_HDel( s_hWASet[ cWA ], "aScopes" )
         ENDIF
         IF hb_HPos( s_hWASet[ cWA ], "nOldOrder" ) > 0
            ordSetFocus( s_hWASet[ cWA ][ "nOldOrder" ] )
            hb_HDel( s_hWASet[ cWA ], "nOldOrder" )
         ENDIF
         IF hb_HPos( s_hWASet[ cWA ], "cOldFilter" ) > 0
            IF ! Empty( s_hWASet[ cWA ][ "cOldFilter" ] )
               dbSetFilter( &( "{||" + s_hWASet[ cWA ][ "cOldFilter" ] + "}" ), s_hWASet[ cWA ][ "cOldFilter" ] )
            ELSE
               dbClearFilter()
            ENDIF
            hb_HDel( s_hWASet[ cWA ], "cOldFilter" )
         ENDIF

         IF hb_HPos( s_hWASet[ cWA ], "nRecNo" ) > 0
            DbGoto( s_hWASet[ cWA ][ "nRecNo" ] )
            hb_HDel( s_hWASet[ cWA ], "nRecNo" )
         ENDIF

         hb_HDel( s_hWASet, cWA )
      ENDDO

      IF LEN( s_hWASet ) < 1
         s_hWASet := NIL
      ENDIF
   ENDIF

   SELECT ( nWA )

   RETURN NIL

FUNCTION leto_Set( nSet, xPar1, xPar2 )
   RETURN Set( nSet, xPar1, xPar2 )

/* try to find IP address for an interface name -- or return the first found with a MAC */
STATIC FUNCTION IPForInterface( cName )

   LOCAL aIFace := hb_socketGetIFaces( HB_SOCKET_AF_INET, .T. )
   LOCAL nIFace := 0
   LOCAL cIP    := ""

   IF LEN( aIFace ) > 0
      IF ! EMPTY( cName )
         cName := UPPER( cName )
         nIFace := ASCAN( aIFace, { | aItm | UPPER( aItm[ HB_SOCKET_IFINFO_NAME ] ) == cName } )
      ELSE
         /* first interface with guilty MAC address */
         nIFace := ASCAN( aIFace, { | aItm | ! EMPTY( aItm[ HB_SOCKET_IFINFO_HWADDR ] ) .AND.;
                                             ! aItm[ HB_SOCKET_IFINFO_HWADDR ] == "00:00:00:00:00:00" } )
      ENDIF
   ENDIF
   IF nIFace > 0
      cIP := aIFace[ nIFace, HB_SOCKET_IFINFO_ADDR ]
   ENDIF

   RETURN cIP


/* don't ! use, elch historical needed mixkey */
#pragma BEGINDUMP
#include <extend.h>

HB_FUNC( MIXKEY )
{
   const char * ptr    = hb_parc( 1 );
   unsigned int iNLen  = hb_parni( 2 );
   unsigned int iZLen  = hb_parni( 3 );
   char pcRet[ 16 ], pNPart[ 16 ], pZPart[ 16 ];
   unsigned int iNPart = 0, iZPart = 0;
   unsigned int i, y, z = hb_parclen( 1 );

   if( iNLen > 16 )
      iNLen = 16;
   if( iZLen > 16 )
      iZLen = 16;
   memset( pcRet, ' ', iZLen );
   while( z > 0 )
   {
      switch( ptr[ 0 ] )
      {
         case '1':
         case '2':
         case '3':
         case '4':
         case '5':
         case '6':
         case '7':
         case '8':
         case '9':
            if( iNPart < iNLen )
               pNPart[ iNPart++ ] = ptr[ 0 ];
            break;

         case '0':
            if( iNPart < iNLen && iNPart > 0 )
               pNPart[ iNPart++ ] = ptr[ 0 ];
            break;

         case ' ':
            break;

         default :
            if( iZPart < iZLen )
               pZPart[ iZPart++ ] = ptr[ 0 ];
            break;
      }
      ptr++;
      z--;
   }

   if( iNPart > 0 )
   {
      y = 0;
      i = iNLen - iNPart;
      while( i < iNLen )
         pcRet[ i++ ] = pNPart[ y++ ];
   }
   else
      pcRet[ iNLen - 1 ] = '0';

   if( iZPart > 0 )
   {
      y = 0;
      i = iNLen;
      while( i < iZLen )
         pcRet[ i++ ] = pZPart[ y++];
   }

   hb_retclen( pcRet, iZLen );
}

#pragma ENDDUMP

