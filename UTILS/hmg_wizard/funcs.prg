function load_dbf ()

if ! file ("_DBF.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"DBF_NAME",  "C",  8, 0})
   aadd(alist_fld,{"FIELD_SEQ", "N",  3, 0})
   aadd(alist_fld,{"FIELD_NAME","C", 10, 0})
   aadd(alist_fld,{"FIELD_TYPE","C",  1, 0})
   aadd(alist_fld,{"FIELD_LEN", "N",  3, 0})
   aadd(alist_fld,{"FIELD_DEC", "N",  2, 0})
   dbcreate("_DBF",alist_fld)
endif

if ! file ("_DBF.ntx")
   use _DBF via "dbfntx"
   index on DBF_NAME+STR(FIELD_SEQ,3) to _DBF
   use 
endif

if ! file ("_SELECT.dbf")
   alist_fld := {} 
   aadd(alist_fld,{"DBF_NAME",  "C",  8, 0})
   aadd(alist_fld,{"DBF_DICT",  "C",  1, 0})
   aadd(alist_fld,{"DBF_DISK",  "C",  1, 0})
   dbcreate("_SELECT",alist_fld)
endif

if ! file ("_SEELCT.ntx")
   use _SELECT via "dbfntx"
   index on DBF_NAME to _SELECT
   use 
endif

use _dbf index _dbf
dbf_imp()

dbcloseall()

use _dbf index _dbf new

use _select index _select new
zap

select _dbf

do while .not. eof()

_dbf_name = dbf_name

select _select
seek _dbf_name
if !found()
   dbappend()
   replace dbf_name with _dbf_name
endif

select _dbf
dbskip()
enddo

dbcloseall()

return 0
*:***************************************************
FUNCTION dbf_imp ( )

LOCAL alist_fld, mname, i, ii, _full_dbf, _dbf, _buffer, _dbf_type

_buffer = SPACE(10)

read_dir()

dbcloseall()

SELECT 2
USE _dbf INDEX _dbf
ZAP

SELECT 1
USE _files

DELETE FOR ext != "DBF"
DELETE FOR SUBSTR(name,1,1) = "_"
PACK

dbgotop()
DO WHILE .NOT. EOF()
   
   mname = ALLTRIM(name)
      
   _full_dbf = mname + '.DBF'
   _dbf = FOPEN( _full_dbf, 0 )
   FREAD( _dbf, @_buffer, 10 )
   DO CASE
   CASE SUBSTR(_buffer,1,1) = CHR(3)
      _dbf_type = 'NTX'
   CASE SUBSTR(_buffer,1,1) = CHR(131)
      _dbf_type = 'NTX'
  *CASE SUBSTR(_buffer,1,1) = CHR(245)
  *   _dbf_type = 'CDX'
   ENDCASE
   FCLOSE( _dbf )

   SELECT 3
   use
   USE &mname

   alist_fld := DBSTRUCT()
   ii = LEN( alist_fld )
   
   SELECT 2
   FOR i = 1 TO ii
      APPEND BLANK
      REPLACE dbf_name   WITH mname
      REPLACE field_seq  WITH i
      REPLACE field_name WITH alist_fld[i][1]
      REPLACE field_type WITH alist_fld[i][2]
      REPLACE field_len  WITH alist_fld[i][3]
      REPLACE field_dec  WITH alist_fld[i][4]
   NEXT
   
   SELECT 1
   dbskip()
ENDDO

SELECT 2
DELETE FOR dbf_name = 'HELP'
PACK

dbcloseall()

delete file _files.dbf

RETURN 0
*!*********************************************************************
FUNCTION read_dir

LOCAL afiles, list_dbf, jj, act_sel, i, ii, e_name, w_ext, w_name

IF ! FILE ("_files.dbf")
   list_dbf := {}
   AADD(list_dbf,{"name","c",20,0})
   AADD(list_dbf,{"ext","c",3,0})
   DBCREATE("_files",list_dbf)
ENDIF

afiles = DIRECTORY()
jj = LEN(afiles)

IF jj = 0
   RETURN -1
ENDIF

act_sel = SELECT()

SELECT 0
USE _files
ZAP
dbgotop()

FOR i = 1 TO jj
   e_name = afiles[i][1]
   w_ext = ''
   
   ii = AT(".",e_name)
   IF ii = 0
      w_name = e_name
      w_ext  = ''
   ELSE
      w_name = SUBSTR(e_name,1,ii-1)
      w_ext  = SUBSTR(e_name,ii+1,3)
   ENDIF
   
   dbappend()
   REPLACE name WITH upper(w_name)
   REPLACE ext  WITH upper(w_ext)
NEXT

USE

SELECT(act_sel)

RETURN 0
