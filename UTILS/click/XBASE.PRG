*+--------------------------------------------------------------------
*+
*+ Source Module => c:\hmg.3.4.4\0\CLICK\XBASE.PRG
*+
*+    Copyright(C) 1983-2022 by Auge & Ohr
*+
*+    Functions: Function AppFolder()
*+               Function TabSpStrip()
*+               Function TabStrip()
*+               Function FT_MKDIR()
*+               Function ISDIR()
*+               Function FT_ORIGIN()
*+               Function FT_DEFAULT()
*+               Function Createini()
*+               Procedure GetDBFInfo()
*+               Function SetDBE()
*+               Static Function DbeFileType()
*+               Static Function DbfDetail()
*+               Function VAR2CHAR()
*+               Function TNR2STR()
*+               Function CalcPos()
*+               Procedure SnapToCtrl()
*+
*+       Tables: USE (cDBF) VIA "DBFNTX" ALIAS AUGEOHR
*+               USE (cDBF) VIA "DBFCDX" ALIAS AUGEOHR
*+
*+    Reformatted by Click! 2.05.40 on Apr-28-2022 at 12:19 am
*+
*+--------------------------------------------------------------------

#include "HMG.CH"
#include "inkey.ch"

#include "Dbstruct.ch"

*+--------------------------------------------------------------------
*+
*+    Function AppFolder()
*+
*+    Called from ( click.prg )   1 - static procedure saveinipath()
*+                                   1 - static procedure initmain()
*+                                   1 - static procedure cre_iniclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION AppFolder()

LOCAL cFile := FT_ORIGIN()
RETURN STRTRAN( cFile, "CLICK.EXE", "" )

*+--------------------------------------------------------------------
*+
*+    Function TabSpStrip()
*+
*+    Called from ( click.prg )   5 - static function breadpart()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+
*+--------------------------------------------------------------------
*+
FUNCTION TabSpStrip( cString )

LOCAL nPointer := 1
LOCAL TABSPACE := ' ' + CHR( K_TAB )
   // strips tabs and spaces in any combination from left end of string

   DO WHILE SUBSTR( cString, nPointer, 1 ) $ TABSPACE
      nPointer ++
   ENDDO

RETURN SUBSTR( cString, nPointer )

*+--------------------------------------------------------------------
*+
*+    Function TabStrip()
*+
*+    Called from ( click.prg )   1 - static function breadpart()
*+
*+--------------------------------------------------------------------
*+
FUNCTION TabStrip( cString )

LOCAL nPointer := 1
LOCAL TAB      := CHR( K_TAB )
   // strips tabs and spaces in any combination from left end of string

   DO WHILE SUBSTR( cString, nPointer, 1 ) = TAB
      nPointer ++
   ENDDO

RETURN SUBSTR( cString, nPointer )

*+--------------------------------------------------------------------
*+
*+    Function FT_MKDIR()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION FT_MKDIR( cdir )

LOCAL nErr := 0

   nErr := DIRMAKE( cdir )
   IF !EMPTY( nErr )
      MSGInfo( "failed to create directory " + cdir + " with error code " + STR( nErr, 4, 0 ) )
      RETURN nErr
   ENDIF

RETURN 0

*+--------------------------------------------------------------------
*+
*+    Function ISDIR()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
FUNCTION ISDIR( cIn )

LOCAL aDir  := DIRECTORY( cIn, "D" )
LOCAL i, iMax
LOCAL nPosi, cDir, lRet := .F.

   iMax := LEN( aDir )
   nPosi := RAT( "\", cIn )
   IF nPosi > 0
      cDir := SUBSTR( cIn, nPosi + 1 )
      FOR i := 1 TO iMax
         IF aDir[ i ] [ 1 ] = cDir .AND. "D" $ aDir[ i ] [ 5 ]
            lRet := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF
RETURN lRet

*+--------------------------------------------------------------------
*+
*+    Function FT_ORIGIN()
*+
*+    Called from ( click.prg )   1 - static procedure initmain()
*+                                   5 - static procedure startclick()
*+                                   1 - static procedure thealigner()
*+                ( cmd_list.prg )   1 - function init_list()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - procedure init_func_text()
*+                                   1 - function func_text()
*+                ( libread.prg )   2 - procedure libread()
*+                ( obufwrit.prg )   1 - function bo_init()
*+                ( xbase.prg )   1 - function appfolder()
*+
*+--------------------------------------------------------------------
*+
FUNCTION FT_ORIGIN()

LOCAL cOSCRLF := HB_OSNEWLINE()
LOCAL dirsep, drivesep, cFullPath
LOCAL cDisk   := DISKNAME()

   IF CHR( 13 ) + CHR( 10 ) = cOSCRLF                                 //must be ms based
      dirsep := '\'
      drivesep := DISKNAME() + ':'
   ELSE                                                               //must be linux,chr(10) or mac chr(13)
      dirsep := '/'
      drivesep := ''
      //  SET PATH '.;/home/paul/click')
   ENDIF
   cFullPath := drivesep + dirsep + CURDIR( drivesep ) + dirsep       //10/03 local copy in startup directory

   // Problem with "c:\hmg.3.4.4\" and function RootName( FILE_NAME )
   // add like Xbase++
   cFullPath += "CLICK.EXE"

RETURN cFullPath

*+--------------------------------------------------------------------
*+
*+    Function FT_DEFAULT()
*+
*+--------------------------------------------------------------------
*+
FUNCTION FT_DEFAULT( cIn )

   IF EMPTY( cIn )
      RETURN DISKNAME()
   ELSE
      RETURN DISKNAME()
   ENDIF

RETURN NIL

*+--------------------------------------------------------------------
*+
*+    Function Createini()
*+
*+    Called from ( click.prg )   1 - static procedure initmain()
*+
*+--------------------------------------------------------------------
*+
FUNCTION Createini( cfullpath )

LOCAL cclick := '', ccmd_list := '', cfunc_list := '', cop_list := '', cr
LOCAL nfopen, lfclose, cferror
LOCAL cHDR

   cr := HB_OSNEWLINE()                                               //CHR(13)+CHR(10) 2/09

   cHDR := STRTRAN( cfullpath, ".INI", ".HDR" )
   nfopen := FCREATE( cHDR, 0 )                                       //open w/r
   FWRITE( nfopen, "Copyright(C) 1983-2020 by Auge & Ohr" )
   lfclose := FCLOSE( nfopen )                                        //if we fail on close

   cclick := cclick + '[CLICK]' + cr + 'INDENT_IF=3' + cr + 'INDENT_FOR=3' + cr
   cclick := cclick + 'INDENT_CASE=3' + cr + 'INDENT_FUNC=3' + cr + 'INDENT_BEGIN=3' + cr
   cclick := cclick + 'INDENT_WHILE=3' + cr + 'INDENT_CLASS=3' + cr
   cclick := cclick + 'INDENT_CONTINUE_LINE=1' + cr + cr + 'DEFAULT_INDENT=8' + cr
   cclick := cclick + 'COMMENTTAB=70' + cr + cr + 'HEAD_DIV=-' + cr + 'FUNC_DIV=-' + cr + cr
   cclick := cclick + '// the options are: NOCHANGE, UPPER, LOWER, PROPER, LIKEINFILE' + cr
   cclick := cclick + 'CASE_OF_COMMANDS=UPPER' + cr + 'CASE_OF_FUNCTIONS=UPPER' + cr + cr
   cclick := cclick + '// the options are: NOCHANGE, UPPER, LOWER' + cr
   cclick := cclick + 'CASE_OF_BOOLEAN=UPPER' + cr + cr + '// options are S87, 5.X' + cr
   cclick := cclick + '// selecting S87:' + cr + '//   Stops the = to := conversion' + cr
   cclick := cclick + '//   Turns off the Declaration Buster' + cr
   cclick := cclick + '//   Stops the STORE to := converter' + cr
   cclick := cclick + '//   The Aligner uses = != instead of := += -= *= /= ^= !=' + cr + cr
   cclick := cclick + 'RUNMODE=S87' + cr + '//RUNMODE=5.X' + cr
   cclick := cclick + '// Convert && to // when && is starting a comment' + cr
   cclick := cclick + 'CONVERT_&&_TO_//=YES' + cr + cr
   cclick := cclick + '// Convert * to // when && is starting a line' + cr
   cclick := cclick + 'CONVERT_*_TO_//=YES' + cr + cr
   cclick := cclick + '// Convert ][ to ,' + cr
   cclick := cclick + '// when set to yes, x[ 1 ][ 2 ] becomes x[ 1, 2 ]' + cr
   cclick := cclick + 'CONVERT_][_TO_//,=YES' + cr + cr
   cclick := cclick + '// Make #includes uniform (lower case #include, upper case "FILENAME"' + cr
   cclick := cclick + 'CLEAN_UP_INCLUDES=YES' + cr + cr
   cclick := cclick + '// options are ENVIRONMENT, (specified path), DRIVES' + cr
   cclick := cclick + 'MAKE_CLICK_DBF_FROM=ENVIRONMENT' + cr
   cclick := cclick + '//MAKE_CLICK_DBF_FROM=G:\EXPAND52;F:\JAMES\GANG\FUNK49' + cr
   cclick := cclick + '//MAKE_CLICK_DBF_FROM=DRIVES' + cr + cr
   cclick := cclick + '// This is only used if you select DRIVES above.' + cr
   cclick := cclick + '// It limits the directory depth that recursion will traverse.' + cr
   cclick := cclick + 'RECURSION_LIMIT=7' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'INDENT_FUNCTIONS=YES' + cr
   cclick := cclick + 'INDENT_DO_CASE=YES' + cr + cr
   cclick := cclick + '// This has an effect only if INDENT_FUNCTIONS=YES' + cr
   cclick := cclick + '// It left justifies any line starting with LOCA PRIV MEMV STAT PUBL FIEL' + cr
   cclick := cclick + '// options are YES, NO' + cr + 'INDENT_LOCALS=NO' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'VERBOSE=YES' + cr + cr
   cclick := cclick + 'OUTPUT_EXTENSION=.PRG' + cr
   cclick := cclick + '//Realtive to current directory' + cr + 'OUTPUT_DIRECTORY=clickout' + cr
   cclick := cclick + 'CLICK_LOG=CLICK.LOG' + cr + 'CLICK_LOG_ERASE=NO' + cr
   cclick := cclick + 'NOTIFY_OF_ERROR_ON_SCREEN=YES' + cr + cr
   cclick := cclick + '// The options are: ALWAYS, ASK, NEVER' + cr + 'OUTPUT_OVERWRITE=ALWAYS' + cr
   cclick := cclick + 'SOURCE_XREF_FILE=Src_cros.TXT' + cr + 'FUNCTION_XREF_FILE=Fnc_cros.txt' + cr
   cclick := cclick + 'TABLE_XREF_FILE=Tbl_cros.TXT' + cr + 'FIELD_XREF_FILE=Fld_cros.txt' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr
   cclick := cclick + '// please note that you must set ADD_CLICK_HEADER=YES' + cr
   cclick := cclick + 'FUNCTION_REF_INTO_SOURCE=YES' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr
   cclick := cclick + '// please note that you must set ADD_FUNCTION_HEADERS=YES' + cr
   cclick := cclick + 'FUNCTION_XREF_INTO_SOURCE=YES' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr
   cclick := cclick + '// please note that you must set ADD_CLICK_HEADER=YES' + cr
   cclick := cclick + 'TABLE_XREF_INTO_SOURCE=YES' + cr + cr
   cclick := cclick + '// Use this if you have a dictionary function that opens files' + cr
   cclick := cclick + '// This will allow Click! to track file openings via this function' + cr
   cclick := cclick + '// You can define multiple functions here by using | as a delimiter' + cr
   cclick := cclick + 'MY_TABLE_FUNCTION=D_OPEN|D_CLOSE|D_ZAP' + cr
   cclick := cclick + 'MY_INDEX_FUNCTION=D_INDEX|D_ORDER' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr
   cclick := cclick + '// please note that you must set ADD_CLICK_HEADER=YES' + cr
   cclick := cclick + 'INDEX_XREF_INTO_SOURCE=YES' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr
   cclick := cclick + '//Time stamp option not implemented in (x)Harbour' + cr
   cclick := cclick + 'RETAIN_ORIGINAL_TIME_DATE_ON_OUTPUT_FILES=YES' + cr
   cclick := cclick + 'SKIP_FILES_WITH_NO_CHANGES=NO' + cr
   cclick := cclick + 'REMOVE_DUPLICATE_EMPTY_LINES=YES' + cr
   cclick := cclick + 'CONVERT_OLD_STYLE_FUNCTIONS=NO' + cr + 'CONVERT_TO_INCREMENTOR=NO' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'RESTORE_SCREEN_ON_EXIT=YES' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'PREPROCESS_WITH_DECLARATION_BUSTER=NO' + cr
   cclick := cclick + 'POSTPROCESS_WITH_THE_ALIGNER=YES' + cr + 'ALIGN_DBCREATE_IN_THE_ALIGNER=YES' + cr
   cclick := cclick + 'ALIGN_CLASS_IN_THE_ALIGNER=NO' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'CHANGE_REPLACE_WITH_TO_ASSIGNMENT=NO' + cr
   cclick := cclick + 'CHANGE_STORE_TO_ASSIGNMENT=YES' + cr + cr
   cclick := cclick + '@_SAY_GET_ALIGNMENT_METHOD=2' + cr
   cclick := cclick + '// options are 0, no alignment' + cr
   cclick := cclick + '//             1, each element type in its own aligned column' + cr
   cclick := cclick + '//             2, Columns aligned, but not by type' + cr
   cclick := cclick + '//             3, Each element in its own row.' + cr
   cclick := cclick + '// If you use option 3, there is no reverse process.' + cr
   cclick := cclick + '// Review the output before you commit to method 3.' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'REMOVE_SNAP_HEADERS=NO' + cr
   cclick := cclick + 'REMOVE_MULTIEDIT_HEADERS=NO' + cr + 'REMOVE_CLICK_HEADERS=YES' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + 'ADD_CLICK_HEADER=YES' + cr
   cclick := cclick + 'ADD_FUNCTION_HEADERS=YES' + cr + 'ADD_EOF_MARKER=YES' + cr + cr
   cclick := cclick + 'SMART_ALIGN_MAX_ELEMENTS=11' + cr + cr
   cclick := cclick + '// options are YES, NO' + cr + '// deflate mode removes spaces' + cr
   cclick := cclick + '// following ({[ and preceding ]})' + cr + '// following ,' + cr
   cclick := cclick + '// both sides of +' + cr + 'DEFLATE_(=YES' + cr + 'DEFLATE_{=YES' + cr
   cclick := cclick + 'DEFLATE_[=YES' + cr + 'DEFLATE_,=YES' + cr + 'DEFLATE_+=YES' + cr + cr

   ccmd_list := ccmd_list + '[CMD_LIST]' + cr + cr
   ccmd_list := ccmd_list + '// Commands beginning with * never make sense when used as a function, so' + cr
   ccmd_list := ccmd_list + '// when they are followed by a (, they are NOT considered to be functions.' + cr
   ccmd_list := ccmd_list + '// THIS ALLOWS YOU TO DEFINE WHICH COMMANDS WILL NOT BE CONSIDERED TO BE' + cr
   ccmd_list := ccmd_list + '// FUNCTIONS. If you prefer for Click! to treat all commands as if they' + cr
   ccmd_list := ccmd_list + '// cannot be functions, then place a * before each command.' + cr
   ccmd_list := ccmd_list + '// Good programming practices never allow key words to be used as' + cr
   ccmd_list := ccmd_list + '// functions or functions and commands to be used as variables.' + cr + cr
   ccmd_list := ccmd_list + 'ACCEPT' + cr + 'ADDITIVE' + cr + '*ALL' + cr + '*APPEND BLANK' + cr
   ccmd_list := ccmd_list + '*APPEND FROM' + cr + 'AVERAGE' + cr + '*BEGIN SEQUENCE' + cr
   ccmd_list := ccmd_list + 'BOTTOM' + cr + '*BOX' + cr + 'BREAK' + cr + 'CALL' + cr + 'CANCEL' + cr
   ccmd_list := ccmd_list + '*CASE' + cr + '*CLASS' + cr + '*CLASS METHOD' + cr + 'CLEAR' + cr
   ccmd_list := ccmd_list + '*CLEAR ALL' + cr + '*CLEAR GETS' + cr + '*CLEAR MEMORY' + cr
   ccmd_list := ccmd_list + '*CLEAR SCREEN' + cr + '*CLEAR TYPEAHEAD' + cr + 'CLOSE' + cr
   ccmd_list := ccmd_list + 'CLS' + cr + 'COLOR' + cr + 'COMMIT' + cr + 'CONTINUE' + cr + '*COPY FILE' + cr
   ccmd_list := ccmd_list + '*COPY STRUCTURE EXTENDED' + cr + '*COPY STRUCTURE' + cr
   ccmd_list := ccmd_list + '*COPY TO' + cr + 'COUNT' + cr + '*CREATE' + cr + '*CREATE FROM' + cr
   ccmd_list := ccmd_list + 'DEFAULT' + cr + 'DELETE' + cr + '*DELETE FILE' + cr
   ccmd_list := ccmd_list + '*DELETE TAG' + cr + 'DIR' + cr + cr + 'DO' + cr + '*DO CASE' + cr
   ccmd_list := ccmd_list + '*DO WHILE' + cr + 'EJECT' + cr + '*ELSE' + cr + '*ELSEIF' + cr + '*END' + cr
   ccmd_list := ccmd_list + '*END CASE' + cr + '*ENDCASE' + cr + '*END CLASS' + cr + '*ENDCLASS' + cr
   ccmd_list := ccmd_list + '*END DO' + cr + '*ENDDO' + cr + '*END IF' + cr + '*ENDIF' + cr
   ccmd_list := ccmd_list + '*END SEQUENCE' + cr + '*ENDSEQUENCE' + cr + '*END WHILE' + cr
   ccmd_list := ccmd_list + '*ENDWHILE' + cr + '*ENDFOR' + cr + 'ERASE' + cr + 'EXCEPT' + cr
   ccmd_list := ccmd_list + 'EXCLUSIVE' + cr + '*EXPORTED:' + cr + 'EXIT' + cr + 'FIELD' + cr
   ccmd_list := ccmd_list + 'FIND' + cr + '*FOR' + cr + '*FROM' + cr + '*FUNCTION' + cr + '*GET' + cr
   ccmd_list := ccmd_list + 'GO' + cr + 'GOTO' + cr + '*IF' + cr + 'INDEX' + cr + 'INIT' + cr + 'INPUT' + cr
   ccmd_list := ccmd_list + 'JOIN' + cr + '*KEYBOARD' + cr + 'LABEL' + cr + '*LABEL FORM' + cr
   ccmd_list := ccmd_list + '*LIKE' + cr + 'LIST' + cr + 'LOCAL' + cr + 'LOCATE' + cr + 'LOOP' + cr
   ccmd_list := ccmd_list + 'MEMVAR' + cr + '*METHOD' + cr + '*MENU TO' + cr + '*NEXT' + cr + 'NOTE' + cr
   ccmd_list := ccmd_list + '*ON' + cr + 'OTHERWISE' + cr + 'PACK' + cr + 'PARAMETERS' + cr
   ccmd_list := ccmd_list + 'PICTURE' + cr + 'PRINT' + cr + 'PRIVATE' + cr + '*PROCEDURE' + cr
   ccmd_list := ccmd_list + 'PROMPT' + cr + '*PROTECTED:' + cr + 'PUBLIC' + cr + 'QUIT' + cr + 'RANGE' + cr
   ccmd_list := ccmd_list + 'READ' + cr + 'READONLY' + cr + 'RECALL' + cr + 'RECORD' + cr
   ccmd_list := ccmd_list + 'RECOVER' + cr + 'REINDEX' + cr + 'RELEASE' + cr + 'RENAME' + cr
   ccmd_list := ccmd_list + 'REPLACE' + cr + '*REPORT FORM' + cr + 'REST' + cr + 'RESTORE' + cr
   ccmd_list := ccmd_list + '*RESTORE SCREEN' + cr + '*RETURN' + cr + '*RUN' + cr + 'SAVE' + cr
   ccmd_list := ccmd_list + '*SAVE SCREEN' + cr + '*SAY' + cr + 'SCREEN' + cr + 'SEEK' + cr
   ccmd_list := ccmd_list + '*SELECT' + cr + 'SEND' + cr + '*SET ALTERNATE' + cr + '*SET BELL' + cr
   ccmd_list := ccmd_list + '*SET CENTURY' + cr + '*SET COLOR' + cr + '*SET CONFIRM' + cr
   ccmd_list := ccmd_list + '*SET CONSOLE' + cr + '*SET CURSOR' + cr + '*SET DATE' + cr
   ccmd_list := ccmd_list + '*SET DECIMALS' + cr + '*SET DEFAULT' + cr + '*SET DELETED' + cr
   ccmd_list := ccmd_list + '*SET DELIMITERS' + cr + '*SET DEVICE' + cr + '*SET EPOCH' + cr
   ccmd_list := ccmd_list + '*SET ESCAPE' + cr + '*SET EVENTMASK' + cr + '*SET EXACT' + cr + '*SET EXCLUSIVE' + cr
   ccmd_list := ccmd_list + '*SET FILTER' + cr + '*SET FIXED' + cr + '*SET FORMAT' + cr
   ccmd_list := ccmd_list + '*SET FUNCTION' + cr + '*SET INDEX' + cr + '*SET INTENSITY' + cr
   ccmd_list := ccmd_list + '*SET KEY' + cr + '*SET MARGIN' + cr + '*SET MESSAGE' + cr
   ccmd_list := ccmd_list + '*SET ORDER' + cr + '*SET PATH' + cr + '*SET PRINT' + cr
   ccmd_list := ccmd_list + '*SET PRINTER' + cr + '*SET PROCEDURE' + cr + '*SET RELATION' + cr
   ccmd_list := ccmd_list + '*SET SCOREBOARD' + cr + '*SET SOFTSEEK' + cr + '*SET TYPEAHEAD' + cr
   ccmd_list := ccmd_list + '*SET UNIQUE' + cr + '*SET WRAP' + cr + 'SKIP' + cr + 'SORT' + cr
   ccmd_list := ccmd_list + 'STATIC' + cr + 'STORE' + cr + 'SUM' + cr + 'TAG' + cr + 'TEXT' + cr
   ccmd_list := ccmd_list + 'THEN' + cr + '*TO' + cr + 'TOP' + cr + 'TOTAL' + cr + 'UNLOCK' + cr
   ccmd_list := ccmd_list + 'UPDATE' + cr + '*USE' + cr + '*VAR' + cr + '*VALID' + cr + 'WAIT' + cr
   ccmd_list := ccmd_list + '*WHEN' + cr + '*WHILE' + cr + '*WITH' + cr + 'ZAP' + cr + cr

   cfunc_list := cfunc_list + '[FUNC_LIST]' + cr + cr
   cfunc_list := cfunc_list + '// Thanks to Jo W. French for the 5.3 Function listing!' + cr + cr
   cfunc_list := cfunc_list + 'AADD' + cr + 'ABS' + cr + 'ACHOICE' + cr + 'ACLONE' + cr + 'ACOPY' + cr
   cfunc_list := cfunc_list + 'ADEL' + cr + 'ADIR' + cr + 'ADDITEM' + cr + 'AEVAL' + cr + 'AFIELDS' + cr + 'AFILL' + cr
   cfunc_list := cfunc_list + 'AINS' + cr + 'ALERT' + cr + 'ALIAS' + cr + 'ALLTRIM' + cr + 'ALTD' + cr
   cfunc_list := cfunc_list + 'AMPM' + cr + 'APPLYDEFAULT' + cr + 'ARRAY' + cr + 'ASC' + cr + 'ASCAN' + cr
   cfunc_list := cfunc_list + 'ASIZE' + cr + 'ASORT' + cr + 'AT' + cr + 'ATAIL' + cr + 'BIN2I' + cr + 'BIN2L' + cr
   cfunc_list := cfunc_list + 'BIN2W' + cr + 'BOF' + cr + 'BREAK' + cr + 'BROWSE' + cr + 'BUTTONDEFCOLOR' + cr
   cfunc_list := cfunc_list + 'CDOW' + cr + 'CHECKBOX' + cr + 'CHECKDEFCOLOR' + cr + 'CHR' + cr + '*CLOSE' + cr + 'CLOSEMEMO' + cr
   cfunc_list := cfunc_list + 'CMONTH' + cr + 'COL' + cr + 'COLORSELECT' + cr + 'COMBODEFCOLOR' + cr + 'CTOD' + cr
   cfunc_list := cfunc_list + 'CURDIR' + cr + 'DATE' + cr + 'DAY' + cr + 'DAYS' + cr + 'DBAPPEND' + cr + 'DBCLEARFILTER' + cr
   cfunc_list := cfunc_list + 'DBCLEARINDEX' + cr + 'DBCLEARRELATION' + cr + 'DBCLOSEALL' + cr
   cfunc_list := cfunc_list + 'DBCLOSEAREA' + cr + 'DBCOMMIT' + cr + 'DBCOMMITALL' + cr + 'DBCREATE' + cr
   cfunc_list := cfunc_list + 'DBCREATEINDEX' + cr + 'DBDELETE' + cr + 'DBEDIT' + cr + 'DBEVAL' + cr + 'DBF' + cr
   cfunc_list := cfunc_list + 'DBFIELDINFO' + cr + 'DBFILEGET' + cr + 'DBFILEPUT' + cr + 'DBFILTER' + cr
   cfunc_list := cfunc_list + 'DBFONLY' + cr + 'DBGOBOTTOM' + cr + 'DBGOTO' + cr + 'DBGOTOP' + cr + 'DBGSHADOW' + cr
   cfunc_list := cfunc_list + 'DBINFO' + cr + 'DBORDERINFO' + cr + 'DBRECALL' + cr + 'DBRECORDINFO' + cr
   cfunc_list := cfunc_list + 'DBREINDEX' + cr + 'DBRELATION' + cr + 'DBRLOCK' + cr + 'DBRLOCKLIST' + cr
   cfunc_list := cfunc_list + 'DBRSELECT' + cr + 'DBRUNLOCK' + cr + 'DBSEEK' + cr + 'DBSELECTAREA' + cr
   cfunc_list := cfunc_list + 'DBSETDRIVER' + cr + 'DBSETFILTER' + cr + 'DBSETINDEX' + cr + 'DBSETORDER' + cr
   cfunc_list := cfunc_list + 'DBSETRELATION' + cr + 'DBSKIP' + cr + 'DBSTRUCT' + cr + 'DBUNLOCK' + cr + 'DBUNLOCKALL' + cr
   cfunc_list := cfunc_list + 'DBUSEAREA' + cr + 'DBCONVERT' + cr + 'DEFPATH' + cr + 'DELETED' + cr
   cfunc_list := cfunc_list + 'DESCEND' + cr + 'DEVOUT' + cr + 'DEVOUTPICT' + cr + 'DEVPOS' + cr + 'DIRCHANGE' + cr
   cfunc_list := cfunc_list + 'DIRECTORY' + cr + 'DIRREMOVE' + cr + 'DISKCHANGE' + cr + 'DISKNAME' + cr
   cfunc_list := cfunc_list + 'DISKSPACE' + cr + 'DISPBEGIN' + cr + 'DISPBOX' + cr + 'DISPCOUNT' + cr + 'DISPEND' + cr
   cfunc_list := cfunc_list + 'DISPOUT' + cr + 'DISPOUTAT' + cr + 'DOSERROR' + cr + 'DOW' + cr + 'DRAWMEMOAREA' + cr
   cfunc_list := cfunc_list + 'DTOC' + cr + 'DTOS' + cr + 'EDITMEMO' + cr + 'ELAPTIME' + cr + 'EMPTY' + cr + 'EOF' + cr
   cfunc_list := cfunc_list + 'ERRORBLOCK' + cr + 'ERRORINHANDLER' + cr + 'ERRORLEVEL' + cr + 'ERRORSYS' + cr
   cfunc_list := cfunc_list + 'EVAL' + cr + 'EXP' + cr + 'EXPON' + cr + 'FCLOSE' + cr + 'FCOUNT' + cr + 'FCREATE' + cr
   cfunc_list := cfunc_list + 'FERASE' + cr + 'FERROR' + cr + 'FIELDBLOCK' + cr + 'FIELDGET' + cr + 'FIELDNAME' + cr
   cfunc_list := cfunc_list + 'FIELDPOS' + cr + 'FIELDPUT' + cr + 'FIELDNBLOCK' + cr + 'FIELDNPUT' + cr + 'FIELDWBLOCK' + cr
   cfunc_list := cfunc_list + 'FILE' + cr + 'FKLABEL' + cr + 'FKMAX' + cr + 'FLOCK' + cr + 'FOPEN' + cr + 'FOUND' + cr
   cfunc_list := cfunc_list + 'FREAD' + cr + 'FREADSTR' + cr + 'FRENAME' + cr + 'FSEEK' + cr + 'FSETDEVMODE' + cr + 'FWRITE' + cr
   cfunc_list := cfunc_list + 'GBMPDISP' + cr + 'GBMPLOAD' + cr + 'GELLIPSE' + cr + 'GETACTIVE' + cr + 'GETAPPLYKEY' + cr
   cfunc_list := cfunc_list + 'GETCLRBACK' + cr + 'GETCLRFORE' + cr + 'GETCLRPAIR' + cr + 'GETDOSETKEY' + cr
   cfunc_list := cfunc_list + 'GETENV' + cr + 'GETHITTEST' + cr + 'GETNEW' + cr + 'GETPAIRLEN' + cr + 'GETPAIRPOS' + cr
   cfunc_list := cfunc_list + 'GETPOSTVALID' + cr + 'GETPREVALID' + cr + 'GETREADER' + cr + 'GFNTERASE' + cr + 'GFNTLOAD' + cr
   cfunc_list := cfunc_list + 'GFNTSET' + cr + 'GFRAME' + cr + 'GGETPIXEL' + cr + 'GLINE' + cr + 'GMODE' + cr + 'GPOLYGON' + cr
   cfunc_list := cfunc_list + 'GPUTPIXEL' + cr + 'GRECT' + cr + 'GSETCLIP' + cr + 'GSETEXCL' + cr + 'GSETPAL' + cr
   cfunc_list := cfunc_list + 'GUIAPPLYKEY' + cr + 'GUIPOSTVALIDATE' + cr + 'GUIPREVALIDATE' + cr + 'GUIREADER' + cr
   cfunc_list := cfunc_list + 'GWRITEAT' + cr + 'HARDCR' + cr + 'HB_OSNEWLINE' + cr + 'HEADER' + cr + 'I2BIN' + cr + 'IF' + cr
   cfunc_list := cfunc_list + 'IIF' + cr + 'INDEXEXT' + cr
   cfunc_list := cfunc_list + 'INDEXKEY' + cr + 'INDEXORD' + cr + 'INSPECTCOL' + cr + 'INKEY' + cr + 'INT' + cr
   cfunc_list := cfunc_list + 'ISAFFIRM' + cr + 'ISALPHA' + cr + 'ISARRAY' + cr + 'ISCHARACTER' + cr + 'ISCOLOR' + cr
   cfunc_list := cfunc_list + 'ISDATE' + cr + 'ISDEFCOLOR' + cr + 'ISDIGIT' + cr + 'ISDISK' + cr + 'ISLOGIC' + cr
   cfunc_list := cfunc_list + 'ISLOWER' + cr + 'ISNEGATIVE' + cr + 'ISNUMBER' + cr + 'ISPRINTER' + cr + 'ISSHORTCUT' + cr
   cfunc_list := cfunc_list + 'ISUPPER' + cr + 'L2BIN' + cr + 'LASTKEY' + cr + 'LASTREC' + cr + 'LEFT' + cr + 'LEN' + cr
   cfunc_list := cfunc_list + 'LENNUM' + cr + 'LISTBDEFCOLOR' + cr + 'LISTBOX' + cr + 'LOG' + cr + 'LOWER' + cr + 'LTRIM' + cr
   cfunc_list := cfunc_list + 'LUPDATE' + cr + 'MAKEDIR' + cr + 'MAX' + cr + 'MAXCOL' + cr + 'MAXROW' + cr + 'MCOL' + cr
   cfunc_list := cfunc_list + 'MDBLCLK' + cr + 'MEMOEDIT' + cr + 'MEMOLINE' + cr + 'MEMOREAD' + cr + 'MEMORY' + cr
   cfunc_list := cfunc_list + 'MEMOSETSUPER' + cr + 'MEMOTRAN' + cr + 'MEMOWRIT' + cr + 'MEMVARBLOCK' + cr
   cfunc_list := cfunc_list + 'MENUDEFCOLOR' + cr + 'MENUITEM' + cr + 'MENUMODAL' + cr + 'MHIDE' + cr + 'MIN' + cr
   cfunc_list := cfunc_list + 'MLCOUNT' + cr + 'MLCTOPOS' + cr + 'MLEFTDOWN' + cr + 'MLPOS' + cr + 'MOD' + cr + 'MODULUS' + cr
   cfunc_list := cfunc_list + 'MONTH' + cr + 'MPOSTOLC' + cr + 'MPRESENT' + cr + 'MRESTSTATE' + cr + 'MRIGHTDOWN' + cr
   cfunc_list := cfunc_list + 'MROW' + cr + 'MSAVESTATE' + cr + 'MSETBOUNDS' + cr + 'MSETCLIP' + cr + 'MSETCURSOR' + cr
   cfunc_list := cfunc_list + 'MSETPOS' + cr + 'MSHOW' + cr + 'MSTATE' + cr + 'NATIONMSG' + cr + 'NETERR' + cr
   cfunc_list := cfunc_list + 'NETNAME' + cr + 'NEWLOCKS' + cr + 'NEXTKEY' + cr + 'NOSNOW' + cr + 'OPENMEMO' + cr
   cfunc_list := cfunc_list + 'ORDBAGEXT' + cr + 'ORDBAGNAME' + cr + 'ORDCONDSET' + cr + 'ORDCREATE' + cr + 'ORDDESCEND' + cr
   cfunc_list := cfunc_list + 'ORDDESTROY' + cr + 'ORDFOR' + cr + 'ORDISUNIQUE' + cr + 'ORDKEY' + cr + 'ORDKEYADD' + cr
   cfunc_list := cfunc_list + 'ORDKEYCOUNT' + cr + 'ORDKEYDEL' + cr + 'ORDKEYGOTO' + cr + 'ORDKEYNO' + cr + 'ORDKEYVAL' + cr
   cfunc_list := cfunc_list + 'ORDLISTADD' + cr + 'ORDLISTCLEAR' + cr + 'ORDLISTREBUILD' + cr + 'ORDNAME' + cr
   cfunc_list := cfunc_list + 'ORDNUMBER' + cr + 'ORDSCOPE' + cr + 'ORDSETFOCUS' + cr + 'ORDSETRELATION' + cr
   cfunc_list := cfunc_list + 'ORDSKIPUNIQUE' + cr + 'OS' + cr + 'OUTERR' + cr + 'OUTSTD' + cr + 'PAD' + cr + 'PADC' + cr
   cfunc_list := cfunc_list + 'PADL' + cr + 'PADR' + cr + 'PARSEHEADER' + cr + 'POPUP' + cr + 'PCOL' + cr + 'PCOUNT' + cr
   cfunc_list := cfunc_list + 'PROCFILE' + cr + 'PROCLINE' + cr + 'PROCNAME' + cr + 'PROW' + cr + 'PUSHBUTTON' + cr
   cfunc_list := cfunc_list + 'QEXP' + cr + 'QOUT' + cr + 'QQOUT' + cr + 'RADGRPDEFCOLOR' + cr + 'RADIOBUTTON' + cr
   cfunc_list := cfunc_list + 'RADIOGROUP' + cr + 'RADITDEFCOLOR' + cr + 'RANGECHECK' + cr + 'RAT' + cr + 'RDDDBFINFO' + cr
   cfunc_list := cfunc_list + 'RDDLIST' + cr + 'RDDNAME' + cr + 'RDDORDINFO' + cr + 'RDDREGISTER' + cr + 'RDDSETDEFAULT' + cr
   cfunc_list := cfunc_list + 'RDDSYS' + cr + 'READEXIT' + cr + 'READFORMAT' + cr + 'READINSERT' + cr + 'READKEY' + cr
   cfunc_list := cfunc_list + 'READKILL' + cr + 'READMODAL' + cr + 'READUPDATED' + cr + 'READVAR' + cr + 'RECCOUNT' + cr
   cfunc_list := cfunc_list + 'RECNO' + cr + 'RECSIZE' + cr + 'REPLICATE' + cr + 'RESTOREMEMO' + cr + 'RESTSCREEN' + cr
   cfunc_list := cfunc_list + 'RIGHT' + cr + 'RLOCK' + cr + 'ROUND' + cr + 'ROW' + cr + 'RTRIM' + cr + 'RUN' + cr + 'SAVESCREEN' + cr
   cfunc_list := cfunc_list + 'SCROLL' + cr + 'SCROLLBAR' + cr + 'SECONDS' + cr + 'SELECT' + cr + 'SET' + cr + 'SETBLINK' + cr
   cfunc_list := cfunc_list + 'SETCANCEL' + cr + 'SETCLRPAIR' + cr + 'SETCOLOR' + cr + 'SETCURSOR' + cr + 'SETKEY' + cr
   cfunc_list := cfunc_list + 'SETMODE' + cr + 'SETPOS' + cr + 'SETPRC' + cr + 'SETTYPEAHEAD' + cr + 'SOUNDEX' + cr
   cfunc_list := cfunc_list + 'SPACE' + cr + 'SQRT' + cr + 'STR' + cr + 'STRTRAN' + cr + 'STRZERO' + cr + 'STUFF' + cr
   cfunc_list := cfunc_list + 'SUBSTR' + cr + 'SYSINIT' + cr + 'TAPPLYKEY' + cr + 'TBADDCOL' + cr + 'TBAPPLYKEY' + cr
   cfunc_list := cfunc_list + 'TBBLOCK' + cr + 'TBCLOSE' + cr + 'TBCOLUMNNEW' + cr + 'TBCREATE' + cr + 'TBDELCOL' + cr
   cfunc_list := cfunc_list + 'TBDISPLAY' + cr + 'TBEDITCELL' + cr + 'TBFBLOCK' + cr + 'TBGOBOT' + cr + 'TBGOTOP' + cr
   cfunc_list := cfunc_list + 'TBINSCOL' + cr + 'TBMODAL' + cr + 'TBMOUSE' + cr + 'TBREADER' + cr + 'TBROWSEDB' + cr
   cfunc_list := cfunc_list + 'TBROWSENEW' + cr + 'TBSBLOCK' + cr + 'TBSKIP' + cr + 'TIME' + cr + 'TONE' + cr + 'TOPBAR' + cr
   cfunc_list := cfunc_list + 'TRANSFORM' + cr + 'TRIM' + cr + 'TSTRING' + cr + 'TYPE' + cr + 'UPDATED' + cr + 'UPPER' + cr
   cfunc_list := cfunc_list + 'USED' + cr + 'VAL' + cr + 'VALTYPE' + cr + 'VERSION' + cr + 'WORD' + cr + 'YEAR' + cr + cr

   cop_list := cop_list + '[OP_LIST]' + cr + cr
   cop_list := cop_list + '-' + cr + '--' + cr + '!' + cr + '!=' + cr + '#' + cr + '*' + cr + '*=' + cr
   cop_list := cop_list + '**' + cr + '/' + cr + '/=' + cr + ':' + cr + ':=' + cr + '@' + cr + '^' + cr
   cop_list := cop_list + '^=' + cr + '+' + cr + '++' + cr + '+=' + cr + '<' + cr + '<=' + cr + '<>' + cr
   cop_list := cop_list + '=' + cr + '-=' + cr + '==' + cr + '>' + cr + '->' + cr + '>=' + cr + cr

   nfopen := FCREATE( cfullpath, 0 )                                  //open w/r
   FWRITE( nfopen, cclick )
   FWRITE( nfopen, ccmd_list )
   FWRITE( nfopen, cfunc_list )
   FWRITE( nfopen, cop_list )
   lfclose := FCLOSE( nfopen )                                        //if we fail on close
   IF !lfclose
      cferror := STR( FERROR(), 2, 0 )                                //convert error to two digit string for display
      attention( 'cannot create click.ini, the ferror() error is ' + cferror )
      QUIT
   ENDIF
RETURN lfclose                                                        //eof function createini

*+--------------------------------------------------------------------
*+
*+    Procedure GetDBFInfo()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE GetDBFInfo( cOutDir, cDataPath )

LOCAL aDir
LOCAL i, iMax
LOCAL j, jMax
LOCAL cDBF, aStru
LOCAL nHandle
LOCAL cLine      := ""
LOCAL lRunOnce   := .F.
LOCAL bSaveError, oError
LOCAL cError     := ""
LOCAL cVia       := ""

   cOutDir := TRIM( cOutDir )
   IF .NOT. RAT( "\", cOutDir ) = LEN( cOutDir )
      cOutDir += "\"
   ENDIF

   cDataPath := TRIM( cDataPath )
   IF .NOT. RAT( "\", cDataPath ) = LEN( cDataPath )
      cDataPath += "\"
   ENDIF

   IF FILE( cOutDir + "DBFTABLE.TXT" )
      FERASE( cOutDir + "DBFTABLE.TXT" )
   ENDIF
   nHandle := FCREATE( cOutDir + "DBFTABLE.TXT" )

   aDir := DIRECTORY( cDataPath + "*.DBF" )
   iMax := LEN( aDir )
   FOR i := 1 TO iMax
      cDBF := cDataPath + aDir[ i ] [ DBS_NAME ]

      Show_Status( "File " + LTRIM( STR( i ) ) + " of " + LTRIM( STR( iMax ) ) )
      Show_in( cDBF )

      SetProperty( "ClickForm", "ProgressBar_1", "Value", CalcPos( i, iMax ) )
      DO EVENTS

      cVia := ""
      SELECT 99
      bSaveError := ERRORBLOCK()
      // set new Errorblock
      ERRORBLOCK( { | e | BREAK( e ) } )
      BEGIN SEQUENCE
         FWRITE( nHandle, CRLF )
         FWRITE( nHandle, cDBF )
         IF SetDBE( cDBF, nHandle, @cVia )
            FWRITE( nHandle, " via " + cVia + CRLF )
            aStru := DBSTRUCT()
            j := 1
            jMax := LEN( aStru )
            FOR j := 1 TO jMax
               cLine := SUBSTR( aStru[ j ] [ DBS_NAME ] + SPACE( 10 ), 1, 10 )
               cLine += CHR( 9 )
               cLine += aStru[ j ] [ DBS_TYPE ]
               cLine += CHR( 9 )
               cLine += STR( aStru[ j ] [ DBS_LEN ] )
               cLine += CHR( 9 )
               cLine += STR( aStru[ j ] [ DBS_DEC ] )
               Show_out( STRTRAN( cLine, CRLF, "" ) )
               FWRITE( nHandle, cLine + CRLF )
            NEXT
            CLOSE
         ELSE
            FWRITE( nHandle, " Error" + CRLF )
         ENDIF
         FWRITE( nHandle, CRLF )
         FWRITE( nHandle, REPLICATE( "_", 80 ) + CRLF )
      RECOVER USING oError

         cError += HB_OSNEWLINE()
         cError += "ERROR: " + oError:description + ;
                 IIF( EMPTY( oError:operation ), "", ;
                 HB_OSNEWLINE() + oError:operation ) + ;
                 HB_OSNEWLINE()

         cError += oError:subsystem + "/" + ALLTRIM( STR( oError:subcode ) ) + ;
                 " (generic code " + ALLTRIM( STR( oError:genCode ) ) + ;
                 ", os code " + ALLTRIM( STR( oError:osCode ) ) + ")" + ;
                 HB_OSNEWLINE()
         FWRITE( nHandle, cError + CRLF )

         cError := "Error " + cDBF + " " + ( cLine ) + ;
                   HB_OSNEWLINE()
         FWRITE( nHandle, cError + CRLF )

      END SEQUENCE
      ERRORBLOCK( bSaveError )
   NEXT

   FCLOSE( nHandle )

   SELECT 1

RETURN

*+--------------------------------------------------------------------
*+
*+    Function SetDBE()
*+
*+    Called from ( xbase.prg )   1 - procedure getdbfinfo()
*+
*+--------------------------------------------------------------------
*+
FUNCTION SetDBE( cDbf, nHandle, cVia )

LOCAL aType
LOCAL nType
LOCAL cDriver
LOCAL lRet    := .T.

   IF .NOT. FILE( cDbf )
      FWRITE( nHandle, "File " + cDBF + " not found" + CRLF )
      RETURN .F.
   ENDIF

   aType := DbeFileType( cDbf )                                       //  {nType,cDbfType,cDriver,cInxExt}
   nType := aType[ 1 ]
   cDriver := aType[ 3 ]

   IF EMPTY( nType )
      FWRITE( nHandle, "File " + cDBF + " exclusive used" + CRLF )
      RETURN .F.
   ENDIF

   // to avoid ALIAS Problem
   DO CASE
      CASE nType = 3                                                  //  03h   FoxBASE+/Dbase III plus, no memo
         cVia := "DBFNTX"
         USE (cDBF) VIA "DBFNTX" ALIAS AUGEOHR

      CASE nType = 7                                                  //* 07h   VO - dBASE III files w/o memo file
         cVia := "DBFNTX"
         //          MSGInfo( VAR2CHAR( aType ), "Warning DBF Type" )
         USE (cDBF) VIA "DBFNTX" ALIAS AUGEOHR

      CASE nType = 48 .OR. nType = 49                                 //  30h   Visual FoxPro - 31h   Visual FoxPro, autoincrement enabled
         cVia := "DBFCDX"
         USE (cDBF) VIA "DBFCDX" ALIAS AUGEOHR

      CASE nType = 131                                                //  83h   FoxBASE+/dBASE III PLUS, with memo
         cVia := "DBFNTX"
         USE (cDBF) VIA "DBFNTX" ALIAS AUGEOHR

      CASE nType = 245                                                //  F5h   FoxPro 2.x (or earlier) with memo
         cVia := "DBFCDX"
         //          // using Cl*pper Comix/SixDrive
         USE (cDBF) VIA "DBFCDX" ALIAS AUGEOHR

      OTHERWISE
         MSGInfo( VAR2CHAR( aType ), "DBF Type unknown" )

         IF aType[ 4 ] = "NTX"
            cVia := "DBFNTX"
            USE (cDBF) VIA "DBFNTX" ALIAS AUGEOHR
         ELSEIF aType[ 4 ] = "CDX"
            cVia := "DBFCDX"
            USE (cDBF) VIA "DBFCDX" ALIAS AUGEOHR
         ELSE
            cVia := "DBFNTX"
            USE (cDBF) VIA "DBFNTX" ALIAS AUGEOHR
         ENDIF

         lRet := .F.
   ENDCASE

RETURN lRet

*+--------------------------------------------------------------------
*+
*+    Static Function DbeFileType()
*+
*+    Called from ( xbase.prg )   1 - function setdbe()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION DbeFileType( cDbf )

LOCAL nHandle, cBuffer := SPACE( 1 ), nType, aRetVal //, cDbe

   cDbf := IF( RAT( ".", cDbf ) == 0, cDbf + ".DBF", cDbf )
   cDbf := UPPER( cDbf )

   IF !FILE( cDbf )
      RETURN ( { 0, 'File not found', '???', '???' } )
   ENDIF

   IF ( nHandle := FOPEN( cDbf ) ) < 0                                // file is in exclusive use at this time
      // cDbe := DbeInfo( COMPONENT_DATA, DBE_NAME )
      // IF LEFT( cDbe, 3 ) == "FOX"
      //    aRetVal := { nType, 'Foxbase', 'FOXCDX', 'CDX' }
      // ELSE
      //    aRetVal := { nType, 'Foxbase/Foxpro/dBASEIII/IV no memo', 'DBFNTX', 'NTX' }
      // ENDIF
      aRetVal := { 0, '', '', '' }

      FCLOSE( nHandle )
      MsgInfo( "file is in exclusive use at this time" )
      RETURN aRetVal
   ENDIF

   FSEEK( nHandle, 0, 0 )                                             // Move pointer to first byte
   FREAD( nHandle, @cBuffer, 1 )
   FCLOSE( nHandle )
   nType := ASC( cBuffer )

RETURN DbfDetail( nType, cDbf )

*+--------------------------------------------------------------------
*+
*+    Static Function DbfDetail()
*+
*+    Called from ( xbase.prg )   1 - static function dbefiletype()
*+
*+--------------------------------------------------------------------
*+
STATIC FUNCTION DbfDetail( nType, cDbf )

LOCAL cDbfType, cDriver, cInxExt, lIsCdx

   lIsCdx := FILE( STRTRAN( cDbf, '.DBF', '.CDX' ) )

   DO CASE
      CASE nType = 2                                                  //  02h   FoxBASE
         cDbfType = 'Foxbase'
         cDriver := "FOXCDX"
         cInxExt := "CDX"
      CASE nType = 3                                                  //  03h   FoxBASE+/Dbase III plus, no memo
         cDbfType = 'Foxpro/dBASEIII/Ads/Clipper no memo'
         IF lIsCdx
            cDriver := 'DBFCDX/ADSDBE'
            cInxExt := 'CDX'
         ELSE
            cDriver := "DBFNTX/ADSDBE"
            cInxExt := "NTX"
         ENDIF
      CASE nType = 4                                                  //* 04h
         cDbfType = "dBASE IV w/o memo file"
      CASE nType = 5                                                  //* 05h
         cDbfType = "dBASE  V w/o memo file"
      CASE nType = 7                                                  //* 07h
         cDbfType = "VISUAL OBJECTS (first 1.0 versions) for the dBASE III files w/o memo file"
         cDriver := "DBFNTX/ADSDBE"
         cInxExt := "NTX"

      CASE nType = 48                                                 //  30h   Visual FoxPro
         cDbfType = 'Visual Foxpro/Ads'
         cDriver := "FOXCDX/ADSDBE"
         cInxExt := "CDX"
      CASE nType = 49                                                 //  31h   Visual FoxPro, autoincrement enabled
         cDbfType = 'Visual Foxpro AutoIncr'
         cDriver := "FOXCDX"
         cInxExt := "CDX"

         // 0x32 Visual FoxPro with field type Varchar or Varbinary

      CASE nType = 67                                                 //  43h   dBASE IV SQL table files, no memo
         cDbfType = 'dBASE IV SQL table no memo'

         // 0x63 dBASE IV SQL system files, no memo

      CASE nType = 99                                                 //  ???
         cDbfType = 'dBASE IV SQL system file no memo'
      CASE nType = 123                                                //* 7Bh
         cDbfType = "dBASE IV with memo"
      CASE nType = 131                                                //  83h   FoxBASE+/dBASE III PLUS, with memo
         cDbfType = 'FoxPro/dBASEIII/Ads/Clipper with memo'
         IF lIsCdx
            cDriver := 'DBFCDX/ADSDBE'
            cInxExt := 'CDX'
         ELSE
            cDriver := "DBFNTX/ADSDBE"
            cInxExt := "NTX"
         ENDIF
         // 0x8B dBASE IV with memo
      CASE nType = 135                                                //* 87h
         cDbfType = "VISUAL OBJECTS (first 1.0 versions) for the dBASE III files (NTX clipper driver) with memo file"
      CASE nType = 139                                                //  8Bh
         cDbfType = 'dBASE IV with memo'
         cDriver := "DBFNTX"
         cInxExt := "NTX"
      CASE nType = 142                                                //* 8Eh
         cDbfType = "dBASE IV w. SQL table"
      CASE nType = 179                                                //* B3h
         cDbfType = ".dbv and .dbt memo (Flagship)"
      CASE nType = 203                                                //  0xCB  dBASE IV SQL table files, with memo
         cDbfType = 'dBASE IV SQL table with memo'
      CASE nType = 229                                                //* E5h   HiPer-Six format with SMT memo file
         cDbfType = "Clipper SIX driver w. SMT memo file."
      CASE nType = 245                                                //  F5h   FoxPro 2.x (or earlier) with memo
         cDbfType = 'Foxpro 2.x/Ads with memo'
         cDriver := "FOXCDX/ADSDBE"
         cInxExt := "CDX"
      CASE nType = 251                                                //  FBh   FoxBASE
         cDbfType = 'Foxbase'
         cDriver := "FOXCDX"
         cInxExt := "CDX"

      OTHERWISE
         cDbfType = 'Unknown or invalid type'
   ENDCASE

RETURN ( { nType, cDbfType, cDriver, cInxExt } )

*+--------------------------------------------------------------------
*+
*+    Function VAR2CHAR()
*+
*+    Called from ( xbase.prg )   1 - function setdbe()
*+
*+--------------------------------------------------------------------
*+
FUNCTION VAR2CHAR( cIn )

LOCAL cOut := hb_valToExp( cIn )
RETURN STRTRAN( cOut, '"', '' )

*+--------------------------------------------------------------------
*+
*+    Function TNR2STR()
*+
*+--------------------------------------------------------------------
*+
FUNCTION TNR2STR( value )                                             // used in UDF-Index

LOCAL RETVAR := ""
LOCAL nLen   := LEN( value )
LOCAL nSoll  := nLen
LOCAL i, nDiff
LOCAL cStr

   FOR i = 1 TO nLen
      cStr := SUBSTR( value, i, 1 )
      IF cStr == CHR( 32 )
      ELSE
         RETVAR := RETVAR + cStr
      ENDIF
   NEXT

   nDiff := nSoll - LEN( RETVAR )
   FOR i = 1 TO nDiff
      RETVAR := RETVAR + CHR( 32 )
   NEXT

RETURN RETVAR

*+--------------------------------------------------------------------
*+
*+    Function CalcPos()
*+
*+    Called from ( click.prg )   1 - static procedure startclick()
*+                                   1 - static function breadpart()
*+                                   1 - static procedure thealigner()
*+                ( xbase.prg )   1 - procedure getdbfinfo()
*+
*+--------------------------------------------------------------------
*+
FUNCTION CalcPos( nValue, iMax )

LOCAL nRet   := 0
LOCAL nEvery
LOCAL xScale

   IF iMax < 100
      nEvery := INT( 100 / iMax )
      xScale := iMax / nEvery                                         // Scale to 100%
      nRet := iMax / xScale * nValue
   ELSE
      nEvery := INT( iMax / 100 )
      xScale := iMax * nEvery                                         // Scale to 100%
      nRet := iMax / xScale * nValue
   ENDIF

RETURN nRet

*+--------------------------------------------------------------------
*+
*+    Procedure SnapToCtrl()
*+
*+    Called from ( click.prg )   1 - static procedure initmain()
*+                                   1 - static procedure startclick()
*+
*+--------------------------------------------------------------------
*+
PROCEDURE SnapToCtrl( cForm, cControl )

LOCAL hWnd, nRowCtrl, nColCtrl, nHeightCtrl, nWidthCtrl, nColPointer, nRowPointer

   //   IF !( IsWindowActive( &cForm ) ) .OR. !( IsControlDefined( &cControl, &cForm ) )
   IF !( IsControlDefined( &cControl, &cForm ) )
      RETURN
   ENDIF

   hWnd := GetProperty( cForm, 'Handle' )

   nRowCtrl := GetProperty( cForm, cControl, 'Row' )
   nColCtrl := GetProperty( cForm, cControl, 'Col' )
   nHeightCtrl := GetProperty( cForm, cControl, 'Height' )
   nWidthCtrl := GetProperty( cForm, cControl, 'Width' )

   //Center of control
   nRowPointer := nRowCtrl + ( nHeightCtrl / 2 )
   nColPointer := nColCtrl + ( nWidthCtrl / 2 )

   HMG_SetCursorPos( hWnd, nRowPointer, nColPointer )
   DoMethod( cForm, cControl, "Setfocus" )
RETURN

*+ EOF: XBASE.PRG
