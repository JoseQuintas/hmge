/*
 * HMG - Harbour Win32 GUI library
*/

#include "hmg.ch"

Function tool_wizz()

	DEFINE WINDOW Form_5 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'toolbar wizard' ;
		modal

	@ 50,50 LABEL lab_1 VALUE "BUTTON SIZE"
    @ 45,130 TEXTBOX butt_width VALUE 50 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 45,180 TEXTBOX butt_height VALUE 50 WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 80,50 LABEL lab_2 VALUE "IMAGE SIZE"
    @ 75,130 TEXTBOX img_width  VALUE 20 WIDTH 40 NUMERIC INPUTMASK "999" 
    @ 75,180 TEXTBOX img_height VALUE 20  WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 110,50 LABEL lab_3 VALUE "TIMES" 
    @ 105,130 TEXTBOX butt_times VALUE 5 WIDTH 40 NUMERIC INPUTMASK "999" 

	@ 220,250 BUTTON BUTTON_1 ;
			CAPTION "Generate" ;
			ACTION make_tool_prog() ;
			WIDTH 100 ;
			HEIGHT 30 

   END WINDOW

   CENTER WINDOW Form_5

   ACTIVATE WINDOW Form_5

Return
*:--------------------------------------------------------
Function make_tool_prog ()

_butt_width := Form_5.butt_width.Value
_butt_height := Form_5.butt_height.Value

_img_width := Form_5.img_width.Value
_img_height := Form_5.img_height.Value

_butt_times := Form_5.butt_times.Value

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
@ _line,0 say '   DEFINE WINDOW toolbar_test ; '
_line++
@ _line,0 say '      AT 0,0 ; '
_line++
@ _line,0 say '      WIDTH 800 ; '
_line++
@ _line,0 say '      HEIGHT 600 ; '
_line++
@ _line,0 say '      MAIN ; '
_line++
@ _line,0 say '      TITLE "toolbar program test" '
_line++
_line++
@ _line,0 say ' *** copy start *** ' 
_line++

_line++
@ _line,0 say '   DEFINE TOOLBAR Toolbar_' + _time_ + ' BUTTONSIZE ' + alltrim(str(_butt_width)) + ', ' + alltrim(str(_butt_height)) + ' IMAGESIZE ' + alltrim(str(_img_width)) + ', ' + alltrim(str(_img_height)) + ' FLAT BORDER '
_line++

for i = 1 to _butt_times

_line++
@ _line,0 say '   BUTTON TOOL_' + _time_ + '_' + alltrim(str(i)) + ' ; '
_line++
@ _line,0 say '      CAPTION " ' + chr(64+i) + ' " ; '
_line++
@ _line,0 say '      PICTURE "' + chr(64+i) + '.bmp" ; '
_line++
@ _line,0 say '      ACTION nil ; '
_line++

next

_line++
@ _line,0 say '   END TOOLBAR '
_line++

_line++
@ _line,0 say ' *** copy end *** ' 
_line++

_line++
@ _line,0 say '   END WINDOW ' 
_line++
_line++
@ _line,0 say '   CENTER WINDOW toolbar_test ' 
_line++
_line++
@ _line,0 say '   ACTIVATE WINDOW toolbar_test ' 
_line++
_line++
@ _line,0 say 'RETURN ' 
_line++

set printer to
set device to screen
setprc(0,0)

msginfo('Finish, test.prg')

Form_5.Release

Return 
