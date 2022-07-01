#Include "hmg.ch"

Function db2clip  // dbf 2 clipboard

SET navigation extended

read_dir()
use _files
delete for ext != 'DBF'
delete for substr(name,1,1) = '_'
index on name to _files
pack

	DEFINE WINDOW ClipGenForm ;
		AT 0,0 ;
		WIDTH 400 ;  
		HEIGHT 300 ;
		TITLE 'Generate dbf 2 clipboard' ;
		MODAL
	
    ON KEY ESCAPE ACTION ClipGenForm.Release
   
		@ 010,010 COMBOBOX Combo_1 ;
			ITEMSOURCE _files->name ;
			VALUE 1 ;
			WIDTH 200 HEIGHT 100 ;
			FONT "Arial" SIZE 10 ; 
			TOOLTIP "DBF file" 

	@ 150, 120 BUTTON REPORT_111 ; 
		CAPTION " Create program " ;
		WIDTH 140 ;
		ACTION Clip_genn() 

	END WINDOW		 

	CENTER WINDOW   ClipGenForm
	ACTIVATE WINDOW ClipGenForm

Return
*:------------------------------------------
FUNCTION Clip_GENN 

_key := ClipGenForm.Combo_1.Value
select _files
go _key
_dbfname = alltrim(name)

dbcloseall()

use &_dbfname

set device to printer
set printer to dbf2copy.prg

_red = 0
@ _red,0 say '#include "hmg.ch"'
_red++
_red++
@ _red,0 say 'procedure main '
_red++
_red++
@ _red,0 say 'LOCAL Field_sep := chr(9), Line_sep := chr(13)+chr(10), _clipboard := "" '

_red++
_red++
@ _red,0 say 'USE ' + alltrim(_dbfname)
_red++

for i = 1 to fcount()

   if i = fcount()
      _end = 'line_sep'
   else
      _end = 'field_sep'
   endif

   _red++
   @ _red,0 say '_clipboard = _clipboard + "' + field(i) + '" + ' + _end

next
_red++

_red++
@ _red,0 say 'DbGoTop() '
_red++
@ _red,0 say 'DO WHILE .not. eof() '
_red++

for i = 1 to fcount()
   _red++
   _tip = valtype( &(field(i)) )
   
   if i = fcount()
      _end = 'line_sep'
   else
      _end = 'field_sep'
   endif
   
   do case
      case _tip = 'C'
         @ _red,0 say '   _clipboard = _clipboard + ' + alltrim(field(i)) + ' + ' + _end
      
      case _tip = 'N'
         @ _red,0 say '   _clipboard = _clipboard + alltrim(str(' + alltrim(field(i)) + ')) + ' + _end
      
      case _tip = 'D'
         @ _red,0 say '   _clipboard = _clipboard + dtoc(' + alltrim(field(i)) + ') + ' + _end
      	  
      case _tip = 'L'
   
   endcase
   
next
_red++

_red++
@ _red,0 say '   DbSkip()'
_red++
@ _red,0 say 'ENDDO'
_red++

_red++
@ _red,0 say 'DbCloseAll()'
_red++

_red++
@ _red,0 say 'System.Clipboard := _clipboard '
_red++

_red++
@ _red,0 say 'MsgInfo("Data is in Clipboard, just Paste (Ctrl-V) in other aplications ")'
_red++

_red++
@ _red,0 say 'RETURN'
_red++
_red++
@ _red,0 say ''

SET PRINTER TO
SET DEVICE TO SCREEN
SETPRC(0,0)

dbcloseall()

msginfo('Create dbf2copy.prg')

ClipGenForm.Release

RETURN
*:--------------------------------------------------------------------------
/*
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
*/