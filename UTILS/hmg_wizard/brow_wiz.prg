/*
 * HMG - Harbour Win32 GUI library
*/

#include "hmg.ch"

Function brow_wizz()

   load_dbf()   
   use _select
   
	DEFINE WINDOW Form_4 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'browse wizard' ;
		modal
		
	@ 50,50 LABEL lab_1 VALUE "START AT                    , "
    @ 45,120 TEXTBOX start_at_row VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 45,170 TEXTBOX start_at_col VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
		
	@ 80,50 LABEL lab_2 VALUE "DIMENS                      , "
    @ 75,120 TEXTBOX width_dim  VALUE 600 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 75,170 TEXTBOX height_dim VALUE 400 WIDTH 40 NUMERIC INPUTMASK "999" 
		
	@ 110,50 LABEL lab_3 VALUE "DBF"
	@ 110,120 COMBOBOX Combo_1 ;
         ITEMSOURCE _SELECT->DBF_NAME ;
         VALUE 1 ;
         WIDTH 150 HEIGHT 100 ;
         FONT "Arial" SIZE 10 
         	
	@ 220,250 BUTTON BUTTON_1 ;
			CAPTION "Generate" ;
			ACTION make_brow_prog() ;
			WIDTH 100 ;
			HEIGHT 30 

   END WINDOW

   CENTER WINDOW Form_4

   ACTIVATE WINDOW Form_4

Return
*:--------------------------------------------------------
Function make_brow_prog ()

_start_at_row = Form_4.start_at_row.Value
_start_at_col = Form_4.start_at_col.Value

_width_dim = Form_4.width_dim.Value
_height_dim = Form_4.height_dim.Value

_rec = Form_4.Combo_1.Value

use _select
go _rec
_dbff = dbf_name

_time_ := alltrim(substr( time(),1,2) + substr( time(),4,2))

_line = 0

set device to printer
set printer to test.prg

@ _line,0 say '#include "hmg.ch"'
_line++
_line++
@ _line,0 say 'FUNCTION main'
_line++

_line++
@ _line,0 say '   USE ' + _dbff
_line++

_line++
@ _line,0 say '   DEFINE WINDOW browse_test ; '
_line++
@ _line,0 say '      AT 0,0 ; '
_line++
@ _line,0 say '      WIDTH 800 ; '
_line++
@ _line,0 say '      HEIGHT 600 ; '
_line++
@ _line,0 say '      MAIN ; '
_line++
@ _line,0 say '      TITLE "browse program test" '
_line++

_field = ''
_width = ''
_just  = ''

dbcloseall()

use _dbf index _dbf

do while .not. eof()

if dbf_name != _dbff
   dbskip()
   loop
endif

*msginfo ( _dbff + ' ' + field_name )

if field_seq > 1
   _field = _field + ', '
   _width = _width + ', '
   _just  = _just + ', '
endif

_field = _field + chr(34) + alltrim(field_name) + chr(34)

_len = field_len
if _len < 5
   _len = 5
endi

_width = _width + alltrim(str(_len*10))
_just_ = '0'

if field_type = 'N'
   _just_ = '1'
endif

_just = _just + _just_

dbskip()
enddo

_line++
@ _line,0 say ' *** copy start *** ' 
_line++

_line++
@ _line,0 say '   @ ' + alltrim(str(_start_at_row)) + ', ' + alltrim(str(_start_at_col)) + ' BROWSE Browse_1 ; '
_line++
@ _line,0 say '      WIDTH ' + alltrim(str(_width_dim)) + ' ; '
_line++
@ _line,0 say '      HEIGHT ' + alltrim(str(_height_dim)) + ' ; '
_line++
@ _line,0 say '      FONT "Arial" ; '
_line++
@ _line,0 say '      SIZE 10 ; '
_line++
@ _line,0 say '      EDIT ; '
_line++
@ _line,0 say '      HEADERS { ' + _field + ' } ; '
_line++
@ _line,0 say '      WIDTHS { ' + _width + ' } ; '
_line++
@ _line,0 say '      WORKAREA ' + alltrim(_dbff) + ' ; '
_line++
@ _line,0 say '      FIELDS { ' + _field + ' } ; '
_line++
@ _line,0 say '      JUSTIFY { ' + _just + ' } '
_line++

_line++
@ _line,0 say ' *** copy end *** ' 
_line++

_line++
@ _line,0 say '   END WINDOW ' 
_line++
_line++
@ _line,0 say '   CENTER WINDOW browse_test ' 
_line++
_line++
@ _line,0 say '   ACTIVATE WINDOW browse_test ' 
_line++
_line++
@ _line,0 say 'RETURN ' 
_line++

set printer to
set device to screen
setprc(0,0)

msginfo('Finish, test.prg')

Form_4.Release

Return 
