#include "hmg.ch"

Function dbf_view

    DEFINE WINDOW Win_1_1 ;
        AT 0,0 ;
        WIDTH 800 HEIGHT 600 ;
        TITLE 'DBF tables structure' ;
        MODAL ;
        ON INIT OpenTables() ;
        ON RELEASE CloseTables()
 
        ON KEY ESCAPE ACTION Win_1_1.Release
  
        @ 30,30 BROWSE Browse_1_1 ;
           WIDTH  720 ;
           HEIGHT 500 ;
           VALUE 0 ;
           WIDTHS {120,50,150,50,50,50} ;
           HEADERS {'DBF name','Seq','Name','Type','Len','Dec'} ;
           WORKAREA _DBF ;
           FIELDS {'dbf_name','field_seq','field_name','field_type','field_len','field_dec'} ;
           FONT "Arial" ;
           SIZE 10
             
    END WINDOW

    CENTER WINDOW Win_1_1
    ACTIVATE WINDOW Win_1_1

Return Nil
****************************************
Procedure OpenTables()

    Use _DBF Index _dbf
	
Return Nil
****************************************
Procedure CloseTables()

    Use
	
Return Nil
****************************************
* create open_dbf
****************************************
FUNCTION dbf_cre ( _sta )

LOCAL _red, ima_li, oldname, f_name, f_type, fn_len, fn_dec, f_len, f_dec

if pcount() = 0
   _sta = 0
endif

open_folder()
use_folder()
use_dbf_fol()

USE _dbf INDEX _dbf new
dbgotop()

SET DEVICE TO PRINTER
SET PRINTER TO open_dbf.prg

oldname = ""
ima_li = .F.
_red = 0

@ _red,0 SAY '*:***********************'
_red++
@ _red,0 SAY '*: Program OPEN_DBF.PRG '
_red++
@ _red,0 SAY '*: '
_red++
@ _red,0 SAY '*: Created at ' + dtoc(date()) + ' ' + time()
_red++
@ _red,0 SAY '*:***********************'
_red++
@ _red,0 SAY 'PROCEDURE open_dbf'
_red++

_red++
@ _red,0 SAY 'LOCAL alist_fld'
_red++

_fol = .f.

DO WHILE .NOT. EOF()

   IF oldname <> dbf_name
      IF ima_li

	  select _dbf
         _red++
         @ _red,0 SAY '   dbcreate("' + ALLTRIM(oldname) + '",alist_fld)'
         _red++
		 
         @ _red,0 SAY 'endif'
         _red++
		 
		 if _fol
		    _red++
            @ _red,0 SAY 'SET DEFAULT TO '
            _red++
		 endif
	
/* ispituje da li je DBF u drugom folderu */	
			
      _dbf_name = dbf_name
	  
	  select _dbf_fol
	  seek _dbf_name
	  if found()
         _apl = apl
	     if _apl != '.'
	        _fol = .t.
	  
	        select _folder
	        seek _apl
	        _fold = folder
	  
	        _red++
            @ _red,0 SAY 'SET DEFAULT TO ' + _fold
            _red++
			_fol = .t.
        	  
	     endif
	  else 
	     _fol = .f.
	  
	  endif
		
      select _dbf
			
         _red++
         @ _red,0 SAY 'if ! file ("' + ALLTRIM(dbf_name) + '.dbf")'
         _red++
         @ _red,0 SAY '   alist_fld := {} '
      ELSE
         _red++
         @ _red,0 SAY 'if ! file ("' + ALLTRIM(dbf_name) + '.dbf")'
         _red++
         @ _red,0 SAY '   alist_fld := {} '
      ENDIF
      oldname = dbf_name
      ima_li = .T.
   ENDIF
   
   _red++
   f_name = ALLTRIM(field_name)
   f_type = ALLTRIM(field_type)
   fn_len = field_len
   fn_dec = field_dec
   
   IF field_type = 'C'
      fn_len = field_len
      fn_dec = 0
   ENDIF
   
   IF field_type = 'D'
      fn_len = 8
      fn_dec = 0
   ENDIF
   
   IF field_type = 'M'
      fn_len = 10
      fn_dec = 0
   ENDIF
   
   f_len = ALLTRIM(STR(fn_len))
   f_dec = ALLTRIM(STR(fn_dec))
   
   @ _red,0 SAY '   aadd(alist_fld,{"' + f_name + '","' + ;
      f_type + '",' + f_len + ',' + f_dec + '})'
   
   dbskip()
ENDDO

IF ima_li
   _red++
   @ _red,0 SAY '   dbcreate("' + ALLTRIM(oldname) + '",alist_fld)'
   _red++
   @ _red,0 SAY 'endif'
   _red++
ENDIF

_red++
@ _red,0 SAY 'SET DEFAULT TO '
_red++

_red++
@ _red,0 SAY 'RETURN '
_red++
@ _red,0 SAY SPACE(0)

SET PRINTER TO
SET DEVICE TO SCREEN
SETPRC(0,0)

dbcloseall()

* readme ('open_dbf.prg')

if _sta > 0
   msginfo( 'Generate OPEN_DBF.PRG' )
endif

cre_use_dbf()

RETURN
************************************************
* import dbf structures
************************************************
FUNCTION dbf_imp ( _sta )

LOCAL alist_fld, mname, i, ii, _full_dbf, _dbf, _buffer, _dbf_type

if pcount() = 0
   _sta = 0
endif

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

if _sta > 0
   msginfo( 'Finish' )
endif

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
****************************************
* create cre_use_dbf
****************************************
PROCEDURE cre_use_dbf

LOCAL _red, _linija

use_folder()
use_dbf_fol()

*select 2
USE _ntx index _ntx new

*select 1
USE _dbf index _dbf new
index on dbf_name to _dbfu unique
dbgotop()

SET DEVICE TO PRINTER
SET PRINTER TO use_dbf.prg

_red = 0

@ _red,0 SAY '*:***************************' 
_red++
@ _red,0 SAY '*: Program USE_DBF.PRG'
_red++
@ _red,0 SAY '*: '
_red++
@ _red,0 SAY '*: Created at ' + dtoc(date()) + ' ' + time()
_red++
@ _red,0 SAY '*:***************************' 
_red++

do while .not. eof()

_apl = ''
_fol = .f.

@ _red,0 SAY 'PROCEDURE USE_' + alltrim(dbf_name)
_red++

_dbf_name = dbf_name

select _dbf_fol
seek _dbf_name
if found()
_apl = apl
if _apl != '.'
   _fol = .t.
endif

select _folder
seek _apl
_fold = folder

if _fol
_red++
@ _red,0 SAY '   SET DEFAULT TO ' + _fold
_red++
endif

endif

select _dbf

_red++
_linija = '   USE ' + lower(alltrim(dbf_name))
_ind = ind_ord( dbf_name )

select _dbf
_linija = _linija + _ind + ' NEW '

@ _red,0 SAY _linija
_red++

if _fol 
_red++
@ _red,0 SAY '   SET DEFAULT TO'
_red++
endif

_red++
@ _red,0 SAY 'RETURN'
_red++

@ _red,0 SAY '*-----------------------------------------------*'
_red++

dbskip()
enddo

@ _red,0 SAY SPACE(0)

SET PRINTER TO
SET DEVICE TO SCREEN
SETPRC(0,0)

dbcloseall()

* msginfo( 'Generate USE_DBF.PRG' )

RETURN 0
*****************************************
function ind_ord ( _dbf )

local _lin, _ima

_lin = ''
_ima = 0

select _ntx
dbgotop()
do while .not. eof()

if dbf_name != _dbf
   dbskip()
   loop
endif

if _ima > 0
_lin = _lin + ', '
endif
_lin = _lin + alltrim(ntx_name)
_ima++

dbskip()
enddo

if _ima > 0
_lin = ' INDEX ' + lower(_lin)
endif

return _lin
***************************************************
FUNCTION ntx_cre ( _sta )

LOCAL _red, _uniq

if pcount() = 0
   _sta = 0
endif

use_folder()
use_dbf_fol()

USE _ntx new
dbgotop()

SET DEVICE TO PRINTER
SET PRINTER TO open_ntx.prg

_red = 0

@ _red,0 SAY '*:**************************'
_red++
@ _red,0 SAY '*: Program OPEN_NTX.PRG '
_red++
@ _red,0 SAY '*: '
_red++
@ _red,0 SAY '*: Created at ' + dtoc(date()) + ' ' + time()
_red++
@ _red,0 SAY '*:**************************'
_red++
@ _red,0 SAY 'PROCEDURE open_ntx '
_red++

DO WHILE .NOT. EOF()

   _fol = .f.
   _dbf_name = dbf_name

      select _dbf_fol
	  seek _dbf_name
	  if found()
         _apl = apl
	     if _apl != '.'
	        _fol = .t.
	  
	        select _folder
	        seek _apl
	        _fold = folder
	  
	        _red++
            @ _red,0 SAY 'SET DEFAULT TO ' + _fold
            _red++
			_fol = .t.
        	  
	     endif
	  else 
	     _fol = .f.
	  
	  endif

   select _ntx
   _red++
   @ _red,0 SAY 'if ! file ("' + RTRIM(ntx_name) + '.ntx")'
   _red++
   @ _red,0 SAY '   use ' + RTRIM(dbf_name) 
   _red++
    
   IF ntx_uniq <> ' '
      _uniq = ' unique'
   ELSE
      _uniq = ''
   ENDIF
   
   @ _red,0 SAY '   index on ' + RTRIM(KEY) + ' to ' + RTRIM(ntx_name) + _uniq
   _red++
   @ _red,0 SAY '   use '
   _red++
   @ _red,0 SAY 'endif'
   _red++

    if _fol    
	   _red++
       @ _red,0 SAY 'SET DEFAULT TO '
       _red++
	endif
    
   dbskip()
ENDDO

_red++
@ _red,0 SAY 'RETURN'
_red++

@ _red,0 SAY '*:**************************'
_red++
@ _red,0 SAY '*: Program RE_INDEX.PRG '
_red++
@ _red,0 SAY '*:**************************'
_red++
@ _red,0 SAY 'PROCEDURE re_index '
_red++

*** select _ntx

dbgotop()
DO WHILE .NOT. EOF()

   _fold = .f.

   _dbf_name = alltrim(dbf_name)
   select _dbf_fol
   seek _dbf_name
   if found()

      _apl = apl
	  
      if _apl != '.'
	  
	     select _folder
	     seek _apl

	     _fold = .t.
	     _fol_name = folder

         _red++
         @ _red,0 SAY 'set default to ' + _fol_name
	  endif
   endif

   select _ntx
   _red++
   @ _red,0 SAY '   DELETE FILE ' + ALLTRIM(ntx_name) + '.ntx'
  
   if _fold 
      _red++
      @ _red,0 SAY 'set default to '
   endif  
   
   select _ntx
   
   dbskip()
ENDDO

   _red++
   _red++
   @ _red,0 SAY '   open_ntx()'
   _red++

_red++
@ _red,0 SAY 'RETURN'
_red++
@ _red,0 SAY SPACE(0)

SET PRINTER TO
SET DEVICE TO SCREEN
SETPRC(0,0)

dbcloseall()

* readme('open_ntx.prg')

if _sta > 0
   msginfo( 'Generate OPEN_NTX.PRG' )
endif

cre_use_dbf()

RETURN 0
*!*********************************************************************
FUNCTION ntx_imp ( _sta )

LOCAL mname, ntx_expr, _full_ntx, _buffer, _open, _u, _uniq
_buffer = SPACE(512)

if pcount() = 0
   _sta = 0
endif

read_dir()

COPY FILE _files.dbf TO _dual.dbf

dbcloseall()

SELECT 3
USE _dual
ZAP

SELECT 2
USE _ntx INDEX _ntx
ZAP

SELECT 1
USE _files

DELETE FOR ext != "NTX"
PACK

DELETE FOR SUBSTR(name,1,1) = "_"
PACK

dbgotop()
DO WHILE .NOT. EOF()
   
   mname = name
   
   _full_ntx = ALLTRIM(mname) + '.ntx'
   _open = FOPEN( _full_ntx )
   FREAD( _open, @_buffer, 300 )
   ntx_expr = SUBSTR( _buffer, 23, 100 )
   _u = SUBSTR( _buffer, 279, 1 )
   IF _u = CHR(1)
      _uniq = .T.
   ELSE
      _uniq = .F.
   ENDIF
   FCLOSE( _open )

   _nema = '*'
   _full_dbf = alltrim(mname) + '.dbf'
   if file ( _full_dbf ) 
      _nema = ''
   endif
   
   _ind_len = at(chr(0),ntx_expr)
   ntx_expr = substr(ntx_expr,1,_ind_len-1)
      
   SELECT 2
   dbappend()
   REPLACE dbf_name WITH alltrim(mname) + _nema
   REPLACE ORDER    WITH 1
   REPLACE ntx_name  WITH mname
   REPLACE ntx_uniq  WITH IIF( _uniq, 'U', ' ' )
   REPLACE KEY      WITH UPPER(ntx_expr)
   
   SELECT 1
   dbskip()
ENDDO

SELECT 2
DELETE FOR dbf_name = 'HELP'
PACK

dbcloseall()

delete file _files.dbf
delete file _dual.dbf

if _sta > 0
   msginfo( 'Finish' )
endif

RETURN 0
*----------------------------------------*
function CRE_SELECT 

dbcloseall()

SELECT 2
USE _SELECT
INDEX ON DBF_NAME TO _SELECT
ZAP

SELECT 1
USE _DBF INDEX _dbfu

DO WHILE .NOT. EOF()

   _dbfname = dbf_name

   select 2
   seek _dbfname
   If !found()
      dbappend()
      replace dbf_name with _dbfname
   endif

   SELECT 1
   DBSKIP()
ENDDO

DBCLOSEALL()

RETURN 0
*---------------------------------------------*
procedure re_order_rep

dbcloseall()

Use _rep_fld index _rep_fld
copy to _work

dbcloseall()

select 2
use _rep_fld index _rep_fld
zap

select 1
use _work 
index on repname + str(fldseq,2) to _work

_rep = repname
_ord = 0

do while .not. eof()

   _repname = repname
   _DBFNAME = DBFNAME
   _fldseq = fldseq
   _fldNAME = fldNAME
   _fldTYPE = fldTYPE
   _fldLEN = fldLEN
   _fldDEC = fldDEC
   _fldPICT = fldPICT
   _fldHEAD = fldHEAD
   _fldATR1 = fldATR1
   _fldATR2 = fldATR2
   _fldATR3 = fldATR3
   _fldATR4 = fldATR4
   _fldATR5 = fldATR5
   _fldATR6 = fldATR6
   _fldDUZ = fldDUZ
   
   IF _rep != _REPNAME
      _ORD = 1
   ELSE
      _ORD++
   ENDIF

   SELECT 2
   DBAPPEND()
   REPLACE REPNAME WITH UPPER(_repname)
   REPLACE DBFNAME WITH UPPER(_DBFNAME)
   REPLACE FLDNAME WITH UPPER(_fldNAME)
   REPLACE FLDSEQ  WITH _ORD
   REPLACE FLDTYPE WITH _fldTYPE
   REPLACE FLDLEN  WITH _fldLEN
   REPLACE FLDDEC  WITH _fldDEC
   REPLACE FLDHEAD WITH _fldHEAD
   REPLACE FLDPICT WITH _fldPICT
   REPLACE FLDATR1 WITH _fldATR1
   REPLACE FLDATR2 WITH _fldATR2
   REPLACE FLDATR3 WITH _fldATR3
   REPLACE FLDATR4 WITH _fldATR4
   REPLACE FLDATR5 WITH _fldATR5
   REPLACE FLDATR6 WITH _fldATR6
   REPLACE FLDDUZ  WITH _fldDUZ
   
   _rep = _REPNAME
   
   SELECT 1 
   DBSKIP()
ENDDO

DBCLOSEALL()

DELETE FILE _WORK.DBF
DELETE FILE _WORK.NTX

RETURN
*---------------------------------------------*
procedure re_order_frm

dbcloseall()

Use _frm_fld 
index on FORMNAME+STR(FLDSEQ,3) to _FRM_FLD
copy to _work

dbcloseall()

select 2
use _frm_fld index _frm_fld
zap

select 1
use _work 
index on formname+str(fldrow,4)+str(fldcol,4) to _work

_form = formname
_ord = 0

do while .not. eof()

   _formname = formname
   _DBFNAME = DBFNAME
   _fldseq  = fldseq
   _fldNAME = fldNAME
   _fldLABEL = fldLABEL
   _fldTYPE = fldTYPE
   _fldLEN  = fldLEN
   _fldDEC  = fldDEC
   _fldROW  = fldROW
   _fldCOL  = fldCOL
   _labROW  = labROW
   _labCOL  = labCOL
   _fldPICT = fldPICT
   _fldDEF  = fldDEF
   _fldATR1 = fldATR1
   _fldATR2 = fldATR2
   _fldATR3 = fldATR3
   _fldATR4 = fldATR4
   _fldATR5 = fldATR5
   _fldATR6 = fldATR6
   _fldATR7 = fldATR7
   _fldATR8 = fldATR8
   _VALID_dbf = valid_dbf
   _VALID_key = valid_key
   _VALID_fld = valid_fld
   _VALID_dsp = valid_dsp
   
   IF _form != _formname
      _ORD = 1
   ELSE
      _ORD++
   ENDIF

   SELECT 2
   DBAPPEND()
   REPLACE FORMNAME WITH UPPER(_formname)
   REPLACE DBFNAME WITH alltrim(UPPER(_DBFNAME))
   REPLACE FLDSEQ  WITH _ORD
   REPLACE FLDNAME WITH UPPER(_fldNAME)
   REPLACE FLDLABEL WITH _fldLabel   
   REPLACE FLDTYPE WITH _fldTYPE
   REPLACE FLDLEN  WITH _fldLEN
   REPLACE FLDDEC  WITH _fldDEC
   REPLACE FLDROW  WITH _fldROW
   REPLACE FLDCOL  WITH _fldCOL
   REPLACE LABROW  WITH _labROW
   REPLACE LABCOL  WITH _labCOL
   REPLACE FLDPICT WITH _fldPICT
   REPLACE FLDDEF  WITH _fldDEF
   REPLACE FLDATR1 WITH _fldATR1
   REPLACE FLDATR2 WITH _fldATR2
   REPLACE FLDATR3 WITH _fldATR3
   REPLACE FLDATR4 WITH _fldATR4
   REPLACE FLDATR5 WITH _fldATR5
   REPLACE FLDATR6 WITH _fldATR6
   REPLACE FLDATR7 WITH _fldATR7
   REPLACE FLDATR8 WITH _fldATR8
   REPLACE VALID_DBF WITH _valid_dbf
   REPLACE VALID_KEY WITH _valid_key
   REPLACE VALID_FLD WITH _valid_fld
   REPLACE VALID_DSP WITH _valid_dsp
   
   _form = _FORMNAME
   
   SELECT 1 
   DBSKIP()
ENDDO

DBCLOSEALL()

DELETE FILE _WORK.DBF
DELETE FILE _WORK.NTX

RETURN
*---------------------------------------------*
procedure re_order_fmd

dbcloseall()

Use _fmd_fld index _fmd_fld
copy to _work

dbcloseall()

select 2
use _fmd_fld index _fmd_fld
zap

select 1
use _work 
index on formname + str(block,2) + str(fldseq,2) to _work

_form = formname
_ord = 0

do while .not. eof()

   _formname = formname
   _DBFNAME = DBFNAME
   _BLOCK = block
   _fldseq  = fldseq
   _fldNAME = fldNAME
   _fldLABEL = fldLABEL
   _fldTYPE = fldTYPE
   _fldLEN  = fldLEN
   _fldDEC  = fldDEC
   _fldROW  = fldROW
   _fldCOL  = fldCOL
   _fldPICT = fldPICT
   _fldDEF  = fldDEF
   _fldATR1 = fldATR1
   _fldATR2 = fldATR2
   _fldATR3 = fldATR3
   _fldATR4 = fldATR4
   _fldATR5 = fldATR5
   _fldATR6 = fldATR6
   _fldATR7 = fldATR7
   _fldATR8 = fldATR8
   _VALID_dbf = valid_dbf
   _VALID_key = valid_key
   _VALID_fld = valid_fld
   _VALID_dsp = valid_dsp
   
   IF _form != _formname .or. _block != block
      _ORD = 1
   ELSE
      _ORD++
   ENDIF

   SELECT 2
   DBAPPEND()
   REPLACE FORMNAME WITH UPPER(_formname)
   REPLACE DBFNAME WITH alltrim(UPPER(_DBFNAME))
   REPLACE BLOCK   WITH _block
   REPLACE FLDSEQ  WITH _ORD
   REPLACE FLDNAME WITH UPPER(_fldNAME)
   REPLACE FLDLABEL WITH _fldLabel   
   REPLACE FLDTYPE WITH _fldTYPE
   REPLACE FLDLEN  WITH _fldLEN
   REPLACE FLDDEC  WITH _fldDEC
   REPLACE FLDROW  WITH _fldROW
   REPLACE FLDCOL  WITH _fldCOL
   REPLACE FLDPICT WITH _fldPICT
   REPLACE FLDDEF  WITH _fldDEF
   REPLACE FLDATR1 WITH _fldATR1
   REPLACE FLDATR2 WITH _fldATR2
   REPLACE FLDATR3 WITH _fldATR3
   REPLACE FLDATR4 WITH _fldATR4
   REPLACE FLDATR5 WITH _fldATR5
   REPLACE FLDATR6 WITH _fldATR6
   REPLACE FLDATR7 WITH _fldATR7
   REPLACE FLDATR8 WITH _fldATR8
   REPLACE VALID_DBF WITH _valid_dbf
   REPLACE VALID_KEY WITH _valid_key
   REPLACE VALID_FLD WITH _valid_fld
   REPLACE VALID_DSP WITH _valid_dsp
   
   _form = _FORMNAME
   
   SELECT 1 
   DBSKIP()
ENDDO

DBCLOSEALL()

DELETE FILE _WORK.DBF
DELETE FILE _WORK.NTX

RETURN
