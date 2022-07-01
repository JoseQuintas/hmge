/*
 * HMG - Harbour Win32 GUI library
*/

#include "hmg.ch"

Function radio_wizz()

	DEFINE WINDOW Form_3 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'radio group wizard' ;
		modal
		
	@ 50,50 LABEL lab_1 VALUE "START AT                    , "
    @ 45,120 TEXTBOX start_at_row VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 45,170 TEXTBOX start_at_col VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
    
	@ 80,50 LABEL lab_2 VALUE "WIDTH"
    @ 75,120 TEXTBOX radio_width VALUE 40  WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 110,50 LABEL lab_3 VALUE "TIMES"
    @ 105,120 TEXTBOX radio_times VALUE 10 WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 140,50 LABEL lab_5 VALUE "ORIENTATION" WIDTH 300
	@ 135,140 RADIOGROUP Radio_1 ;
			OPTIONS { 'Horizontal', 'Vertical' } ;
			VALUE 1 ;
			WIDTH 70 ;
			HORIZONTAL ;
            SPACING 10

	@ 220,250 BUTTON BUTTON_1 ;
			CAPTION "Generate" ;
			ACTION make_radio_prog() ;
			WIDTH 100 ;
			HEIGHT 30 

   END WINDOW

   CENTER WINDOW Form_3

   ACTIVATE WINDOW Form_3

Return
*:--------------------------------------------------------
Function make_radio_prog ()

_start_at_row := Form_3.start_at_row.Value
_start_at_col := Form_3.start_at_col.Value

_radio_width := Form_3.radio_width.Value

_radio_times := Form_3.radio_times.Value

_radio_orient := Form_3.Radio_1.Value

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
@ _line,0 say '   DEFINE WINDOW radio_test ; '
_line++
@ _line,0 say '      AT 0,0 ; '
_line++
@ _line,0 say '      WIDTH 800 ; '
_line++
@ _line,0 say '      HEIGHT 600 ; '
_line++
@ _line,0 say '      MAIN ; '
_line++
@ _line,0 say '      TITLE "radio group program test" '
_line++
_line++
@ _line,0 say ' *** copy start *** ' 
_line++

_xx = _start_at_row
_yy = _Start_at_col

_text = '   @ ' + alltrim(str(_xx)) + ', ' + alltrim(str(_yy)) + ' RADIOGROUP radio_' + _time_ + ' ; '
_text1 = '      OPTIONS {' 

for i = 1 to _radio_times

_text1 = _text1 + chr(34) + ' ' + chr(64+i) + ' ' + chr(34)

if i < _radio_times
   _text1 = _text1 + ', '
endif

next

_text1 = _text1 + ' } ;'

_text2 = '      WIDTH ' + alltrim(str( _radio_width )) + ' ; '

if _radio_orient = 1
   _text3 = '      HORIZONTAL '
else
   _text3 = ' '
endif

_line++
@ _line,0 say _text
_line++
@ _line,0 say _text1
_line++
@ _line,0 say _text2
_line++
@ _line,0 say _text3

_line++
_line++
@ _line,0 say ' *** copy end *** ' 
_line++

_line++
@ _line,0 say '   END WINDOW ' 
_line++
_line++
@ _line,0 say '   CENTER WINDOW radio_test ' 
_line++
_line++
@ _line,0 say '   ACTIVATE WINDOW radio_test ' 
_line++
_line++
@ _line,0 say 'RETURN ' 
_line++

set printer to
set device to screen
setprc(0,0)

msginfo('Finish, test.prg')

Form_3.Release

Return 
