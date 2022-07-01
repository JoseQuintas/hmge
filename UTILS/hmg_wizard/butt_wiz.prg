/*
 * HMG - Harbour Win32 GUI library
*/

#include "hmg.ch"

Function butt_wizz()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'button wizard' ;
		modal

	@ 50,50 LABEL lab_1 VALUE "START AT                    , "
    @ 45,120 TEXTBOX start_at_row VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 45,170 TEXTBOX start_at_col VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 80,50 LABEL lab_2 VALUE "BUTTON                       ,                 ( WIDTH * HEIGHT )" WIDTH 300
    @ 75,120 TEXTBOX butt_width  VALUE 100 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 75,170 TEXTBOX butt_height VALUE 30  WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 110,50 LABEL lab_3 VALUE "SPACES                      ,                 TIMES" WIDTH 300
    @ 105,120 TEXTBOX butt_space VALUE 30 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 105,170 TEXTBOX butt_times VALUE 5 WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 140,50 LABEL lab_4 VALUE "ORIENTATION" WIDTH 300
	@ 135,140 RADIOGROUP Radio_1 ;
			OPTIONS { 'Horizontal', 'Vertical' } ;
			VALUE 1 ;
			WIDTH 70 ;
			HORIZONTAL ;
            SPACING 10

	@ 170,50 LABEL lab_5 VALUE "PICTURE" WIDTH 300

	@ 165,140 RADIOGROUP Radio_2 ;
			OPTIONS { 'Left', 'Right', 'Top', 'Bottom' } ;
			VALUE 1 ;
			WIDTH 50 ;
			HORIZONTAL ;
            SPACING 5

	@ 220,250 BUTTON BUTTON_1 ;
			CAPTION "Generate" ;
			ACTION make_button_prog() ;
			WIDTH 100 ;
			HEIGHT 30 

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return
*:--------------------------------------------------------
Function make_button_prog ()

_start_at_row = Form_1.start_at_row.Value
_start_at_col = Form_1.start_at_col.Value

_butt_width = Form_1.butt_width.Value
_butt_height = Form_1.butt_height.Value
_butt_space = Form_1.butt_space.Value
_butt_times = Form_1.butt_times.Value

_butt_orient = Form_1.Radio_1.Value
_butt_picture = Form_1.Radio_2.Value

do case 
   case _butt_picture = 3
      _butt_height *= 2
   case _butt_picture = 4
      _butt_height *= 2
endcase	  

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
@ _line,0 say '   DEFINE WINDOW button_test ; '
_line++
@ _line,0 say '      AT 0,0 ; '
_line++
@ _line,0 say '      WIDTH 800 ; '
_line++
@ _line,0 say '      HEIGHT 600 ; '
_line++
@ _line,0 say '      MAIN ; '
_line++
@ _line,0 say '      TITLE "button program test" '
_line++
_line++
@ _line,0 say ' *** copy start *** ' 
_line++
_line++

_xx = _start_at_row
_yy = _Start_at_col
_butt = 0

for i = 1 to _butt_times

_line++
@ _line,0 say '   @ ' + alltrim(str(_xx)) + ', '  + alltrim(str(_yy)) + ' BUTTON butt_' + _time_ + '_' + chr(64+i) + ' ; '
_line++
@ _line,0 say '      CAPTION " ' + chr(64+i) + ' " ; '
_line++
@ _line,0 say '      PICTURE "' + chr(64+i) + '.bmp" ; '
_line++
@ _line,0 say '      ACTION nil ; '

do case 
   case _butt_picture = 1
      set_orient = 'LEFT'
   case _butt_picture = 2
      set_orient = 'RIGHT'
   case _butt_picture = 3
      set_orient = 'TOP'
   case _butt_picture = 4
      set_orient = 'BOTTOM'
endcase	  

_line++
@ _line,0 say '      ' + set_orient + ' ; '

_line++
@ _line,0 say '      WIDTH ' + alltrim(str(_butt_width)) + ' ; '
_line++
@ _line,0 say '      HEIGHT ' + alltrim(str(_butt_height)) + ' '
_line++
			
			
if _butt_orient = 1			
   _yy = _yy + _butt_width + _butt_space
else
   _xx = _xx + _butt_height + _butt_space
endif

if _yy > 700
   _xx = _xx + _butt_height + _butt_height/2
   _yy = _Start_at_col
endif

if _xx > 500
   _xx = _start_at_row
   _yy = _yy + _butt_width + _butt_space
endif

next


_line++
@ _line,0 say ' *** copy end *** ' 
_line++

_line++
@ _line,0 say '   END WINDOW ' 
_line++
_line++
@ _line,0 say '   CENTER WINDOW button_test ' 
_line++
_line++
@ _line,0 say '   ACTIVATE WINDOW button_test ' 
_line++
_line++
@ _line,0 say 'RETURN ' 
_line++

set printer to
set device to screen
setprc(0,0)

msginfo('Finish, test.prg')

Form_1.Release

Return 
