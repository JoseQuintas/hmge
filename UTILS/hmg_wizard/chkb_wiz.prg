/*
 * HMG - Harbour Win32 GUI library
*/

#include "hmg.ch"

Function chkb_wizz()

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'checkbox wizard' ;
		modal
		
	@ 50,50 LABEL lab_1 VALUE "START AT                    , "
    @ 45,120 TEXTBOX start_at_row VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 45,170 TEXTBOX start_at_col VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
		
	@ 80,50 LABEL lab_2 VALUE "LABEL"
    @ 75,100 TEXTBOX chkb_label VALUE 'Options' WIDTH 100
    
	@ 110,50 LABEL lab_3 VALUE "WIDTH"
    @ 105,100 TEXTBOX chkb_width VALUE 100  WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 140,50 LABEL lab_4 VALUE "TIMES"
    @ 135,100 TEXTBOX chkb_times VALUE 10 WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 170,50 LABEL lab_5 VALUE "ORIENTATION" WIDTH 300
	@ 165,140 RADIOGROUP Radio_1 ;
			OPTIONS { 'Horizontal', 'Vertical' } ;
			VALUE 2 ;
			WIDTH 70 ;
			HORIZONTAL ;
            SPACING 10

	@ 220,250 BUTTON BUTTON_1 ;
			CAPTION "Generate" ;
			ACTION make_chkb_prog() ;
			WIDTH 100 ;
			HEIGHT 30 

   END WINDOW

   CENTER WINDOW Form_2

   ACTIVATE WINDOW Form_2

Return
*:--------------------------------------------------------
Function make_chkb_prog ()

_start_at_row := Form_2.start_at_row.Value
_start_at_col := Form_2.start_at_col.Value

_label := Form_2.chkb_label.Value

_chkb_width := Form_2.chkb_width.Value

_chkb_times := Form_2.chkb_times.Value

_chkb_orient := Form_2.Radio_1.Value

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
@ _line,0 say '   DEFINE WINDOW checkbox_test ; '
_line++
@ _line,0 say '      AT 0,0 ; '
_line++
@ _line,0 say '      WIDTH 800 ; '
_line++
@ _line,0 say '      HEIGHT 600 ; '
_line++
@ _line,0 say '      MAIN ; '
_line++
@ _line,0 say '      TITLE "checkbox program test" '
_line++
_line++
@ _line,0 say ' *** copy start *** ' 
_line++

_xx = _start_at_row
_yy = _Start_at_col
_chkb = 0

_line++
@ _line,0 say '   @ ' + alltrim(str(_xx)) + ', '  + alltrim(str(_yy)) + ' LABEL lab_' + _time_ + '_0 VALUE "' + alltrim(_label) + '" BOLD'
_line++

if _chkb_orient = 1
   _yy = _yy + _chkb_width
else
   _xx = _xx + 20
endif

for i = 1 to _chkb_times

_text = '   @ ' + alltrim(str(_xx)) + ', ' + alltrim(str(_yy)) + ' CHECKBOX chkb_' + _time_ + '_' + alltrim(str(i)) 
_text = _text + ' CAPTION " ' + chr(64+i) + ' " WIDTH ' + alltrim(str(_chkb_width))

_line++
@ _line,0 say _text


if _chkb_orient = 1
   _yy = _yy + _chkb_width
else
   _xx = _xx + 25
endif

if _xx > 500
   _xx = _start_at_row
   _yy = _yy + _chkb_width*2
endif

if _yy > 700
   _xx = _xx + 25
   _yy = _chkb_width
endif

next

_line++
_line++
@ _line,0 say ' *** copy end *** ' 
_line++

_line++
@ _line,0 say '   END WINDOW ' 
_line++
_line++
@ _line,0 say '   CENTER WINDOW checkbox_test ' 
_line++
_line++
@ _line,0 say '   ACTIVATE WINDOW checkbox_test ' 
_line++
_line++
@ _line,0 say 'RETURN ' 
_line++

set printer to
set device to screen
setprc(0,0)

msginfo('Finish, test.prg')

Form_2.Release

Return 
