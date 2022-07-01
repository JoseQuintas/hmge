/*
  Name: SET SHOWDETAILERROR ON | OFF Demo
  Description: Enable/Disable "Show Detail Error"
  Note: The change of the switch on|off function "on the fly"
  Author: Antonio Novo <antonionovo@gmail.com>
  Date Created: 14/11/2005
  Modified: 28/05/2021
*/

#define _HMG_OUTLOG

#include "minigui.ch"

Static NoShowRedAlert := .t.

Function Main
	Local Pepe

	Set ShowDetailError off

	IF NoShowRedAlert
		Set ShowRedAlert off
	ELSE
		_HMG_bOnErrorInit := {|v| v += "A Run-Time Error Has Occured !;", ;
				v += "*** IT IS NECESSARY TO CONTACT THE PROGRAMMER ***;;", v }
		_HMG_bOnErrorExit := hb_MacroBlock( "MyExitError()" )
	ENDIF

	DEFINE WINDOW Form1 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "SET SHOWDETAILERROR ON | OFF Demo" ;
		MAIN ;
		NOMAXIMIZE NOSIZE

	@ 10,10 BUTTON Button1 CAPTION "Set ShowDetailError On" ;
		ACTION { || _lShowDetailError(.T.), Pepe++ } WIDTH 200 HEIGHT 40
	@ 50,10 BUTTON Button2 CAPTION "Set ShowDetailError Off" ;
		ACTION { || _lShowDetailError(.F.), Pepe++ } WIDTH 200 HEIGHT 40
	@ 90,10 BUTTON Button3 CAPTION "Show Detail Error Status" ;
		ACTION { || MsgInfo( "Detail Error is " + iif(_lShowDetailError(), "ON", "OFF") ) } WIDTH 200 HEIGHT 40

	END WINDOW

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil

/////////////////////////////////////////////////////////////////////////////////////
Function MyExitError()   // call my function on program termination error
   LOCAL n

   ? "=====> ERROR program ! MyExitError() <=====" 
   FOR n := 0 TO 9
      ? ProcNL(n)
   NEXT

   DbCloseAll()    // close all bases

Return Nil

///////////////////////////////////////////////////////////////////
Function ProcNL(nVal)
   DEFAULT nVal := 0

Return "Call from: " + ProcName( nVal + 1 ) + "(" + hb_ntos( ProcLine( nVal + 1 ) ) + ") --> " + ProcFile( nVal + 1 ) 
