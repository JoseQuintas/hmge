/*
* MiniGUI Activex Demo
*/

#include "hmg.ch"

Function Main

	SET AUTOADJUST ON NOBUTTONS

	Load Window Demo
	Activate Window Demo

Return Nil

Procedure demo_button_1_action

	Demo.Activex_1.XObject:Navigate("http://hmgextended.com")

Return
