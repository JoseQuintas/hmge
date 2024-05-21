MINIGUI - Harbour Win32 GUI library Demo
Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
--------------------------------------------------------------------------------------------------------------------
Three examples of working with the Tsbrowse object (TSB):
1) demo.prg - based on the _TBrowse(...) function using oHmgData()
2) demo1.prg - based on the _TBrowse(...) function, a shortened version and another option for editing columns
3) demo2.prg - using regular functions and oHmgData()
--------------------------------------------------------------------------------------------------------------------
 * Testing columns in Tsbrowse for a dbf file
 * Entering into a table. Check before and after input.
 * Totals for numeric fields, automatic recalculation when data in a column changes
 * Your own window for editing memo fields and text columns with CRLF 
 * Working out a mouse click (right/left) on a superheader/header/footer/table cell
 * Working with SCOPE.
 * Saving/restoring window sizes to an ini file.
 * Working with the clipboard: copying/pasting table cells of different formats
--------------------------------------------------------------------------------------------------------------------
Implementation of building totals in the footer of the table:
    We do the initial calculation on the base using numeric columns ( o:Event({2, "_ItogGet"}..... )
    We save the column sum in oCol:Cargo:nTotal
    Changing the data in a column - recalculation is done by column, ONLY this number is added/subtracted:
       ? ":bPostEdit  ,oc:Cargo:lTotal=",oc:Cargo:lTotal, "oc:xOldEditValue=",oc:xOldEditValue
       lSay := .F.
       IF oc:Cargo:lTotal .and. oc:xOldEditValue != uVal
          oc:Cargo:nTotal += uVal - oc:xOldEditValue
          lSay := .T.
       ENDIF
       ?? "oc:Cargo:nTotal=",oc:Cargo:nTotal
       // send a message to redisplay TOTAL in columns
       IF lSay ; _wPost("_ItogSay", ob:cParentWnd)  
       ENDIF
--------------------------------------------------------------------------------------------------------------------
To change the language in the program to English, do this at the beginning of the program code:
    #define LANG_PRG "EN"  // "EN" English interface-lang
--------------------------------------------------------------------------------------------------------------------
Setting table parameters in the list of columns - Column_TSB()
    // Reserve|Edit| type | column names| db/function field| field width | field format |code block|*F function1 |**F function2
    aDim[1] := { 1 , "R","BMP", "*" , "PUSTO" , "XXX" , "999" , "bKey01","inside the code", nil }
    aDim[2] := { 1 , "W", "D" , "Payment date" , "PRIDAT" , "99099099000", "99.99.99" , nil , nil , "CheckDate()" } // check after entering
    aDim[3] := { 1 , "W", "N" , "Amount;(RUB)" , "PRIXOD" , REPL("9",12) , "999 999.99", nil , nil , nil }
    aDim[4] := { 1 , "W", "C" , "L/s;subscriber" , "RC_ABON" , REPL("9",11) , REPL("x",8) , nil , nil , "SeekAbonRc()"} // search after entering
-------------------------------------------------- -------------------------------------------------- ----------------
* Setting your own program window sizes, allows you to test for other screen resolutions
o:aDisplayMode := { 1280 , 1080 } <<--- change here
o:cDisplayMode := HB_NtoS(o:aDisplayMode[1]) + "x" + HB_NtoS(o:aDisplayMode[2])
-------------------------------------------------- -------------------------------------------------- ----------------
Changing the text on the top menu buttons:
   demo2_menu.prg
   oMenu:lTextLeft := .T. // .T. is the text for the buttons on the left, .F. is on the right
   oMenu:lTextVert := .F. // .T. - vertical text for buttons, .F. - NOT vertical text
-------------------------------------------------- -------------------------------------------------- ----------------
Changing the display of buttons and text on buttons - demo2_menu2_1find.prg
    myTopMenu( nY, nX, nG, nHIco )
    ........
    nHAlign := DT_CENTER // horizontal buttons: 0-DT_LEFT, 1-DT_CENTER, 2-DT_RIGHT
    lVert := .F. // .T. - vertical text for buttons, .F. - NOT vertical text
    lLeft := .F. // .T. is the text for the buttons on the left, .F. is on the right
-------------------------------------------------- -------------------------------------------------- ----------------
Menu modes not implemented:
    oMenu:nPosWin := XX // 3-LeftWindow, 4-RightWindow
 