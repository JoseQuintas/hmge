//===========================================================================//
// Program......: Calculator
// Programmer...: Marcos Antonio Gambeta
// Created at...: 13/01/2004 11:00:00
// Updated at...: 14/01/2004 00:10:47
//===========================================================================//
// This program is an adaptation of an example that follows
// Visual Basic 5. The original program can be found (for those who have the
// VB5) in the folder: C:\Program Files\DevStudio\VB\samples\PGuide\calc.
// If you improve or expand the capabilities of this calculator, be sure to
// Send a copy to the author's original adaptation. In this case, I. :-)
//===========================================================================//
// Last UpDate at : 09/02/2010
// Updated by     : Paulo Sérgio Durço (Vanguarda) - Americana - SP - Brasil
// vanguarda.one@gmail.com
//===========================================================================//
// Cambio de vista y colores nuevos : 19/12/2013
// por Mustafa López  Alicante - España
// mustalopez@gmail.com
//---------------------------------------------------------------------------//
// Change of view and new colors: 19/12/2013
// Update to UTF-8
// by Mustafa López Alicante - Spain
// mustalopez@gmail.com
//---------------------------------------------------------------------------//
// Last UpDate at : 05/05/2018
// Change of view and new colors, changed Function to Procedure, add local
// decimal info, add hotkey for C and CE action, add history, patched input for
// negative numbers,group separator, limited input at 14 digits , add action
// for clear last number entered.
// by Pierpaolo Martinello
//===========================================================================//
// Added new functions: Memory value now avaliable. Now, you can put entry value from
// keyboard. HotKey for operations like "+" "-" "/" "*" and for manager memory.
// Added function that move the result of expression on ClipBoard of windows, when
// the calc is closed.
//===========================================================================//
//Follow the HotKeys
// C or c or Backspace = CancelEntry_Click()
// R or r or Cancel = Cancel_CLick()
// W or w = CancelMemo_Click()
// S or s = ReadMemo_Click()
// M or m = SMemo_Click()
// A or a = AddMemo_Click()                                r
// H or h = Open /close chronology
// ESC to Close
// Right Arrow = Delete the last number entered
//===========================================================================//

#include "Minigui.ch"
#DEFINE MCOLOR { 160, 240, 255 } NOXPSTYLE
#DEFINE CCOLOR { 255, 255, 155 } NOXPSTYLE
#DEFINE OCOLOR { 255, 255, 255 } NOXPSTYLE
#define LOCALE_SDECIMAL  0x0000000e                 //Decimal separator
#define LOCALE_STHOUSAND 0x0000000f                 //Thousand separator

//===========================================================================//
// Statics variables
//===========================================================================//

Static nOp1,nOp2                                    // Store the values entered
Static lDecimalFlag                                 // Indicates whether there is already a decimal point in value
Static nNumOps                                      // Number of values entered
Static cLastInput                                   // Store the last key pressed
Static cOpFlag                                      // Indicates the pending operation
Static cTempReadout
Static nMemo                                        // Memory Calculator
Static state
/*
*/
*-----------------------------------------------------------------------------*
// Form main
*-----------------------------------------------------------------------------*

MEMVAR cDec, cSth
Function ShowCalc(nInput, lRetu_ClipBoard)
LOCAL pColor, cPath := GetStartUpFolder() + "\"
Private cDec, cSth
state := .F.
Default lRetu_ClipBoard := .T.

m->cDec := HMG_GetLocaleInfo( LOCALE_SDECIMAL )
m->cSth := "'"  // Custom cSth

IF !hb_vfExists( cPath+"Lcdn.ttf" )
    hb_MemoWrit( cPath+"Lcdn.ttf", MakeFont() )  // give OS a little time to "see" the newly created file
    hb_IdleSleep( 0.1 )
ENDIF

IF AddFont() == 0
   MsgStop( "An error is occured at installing the font Lcdn.ttf", "Warning" )
EndIf

DEFINE WINDOW Calc           ;
   AT 0,0 WIDTH 260          ;
   HEIGHT iif( _HMG_IsXP, 250, 248 ) ;
   TITLE "Calculator"        ;
   BACKCOLOR { 209,220,231 } ;
   CHILD                     ;
   ICON 'LOGO'               ;
   NOSIZE NOMAXIMIZE         ;
   FONT "Arial" SIZE 10      ;
   ON INIT Form_Load(nInput) ;
   ON RELEASE RemoveCalc()

pColor := {|| if( val(this.cellvalue) > 0 ,{0,0,0},{255,0,0 }) }

// visor
@ 008,010 LABEL  UndoDigit VALUE chr(232) ACTION ClearLast() WIDTH  20 HEIGHT 23 FONT "Wingdings" ;
          Fontcolor YELLOW Tooltip "Delete the last number entered" BACKCOLOR BLUE BOLD CENTERALIGN VCENTERALIGN
@ 008,032 LABEL   ReadFunc VALUE " "  WIDTH  15 HEIGHT 23 CENTERALIGN VCENTERALIGN
@ 007,048 TEXTBOX ReadOut  VALUE "0"  WIDTH 200 HEIGHT 25 FONT "LcdD" SIZE 14 BOLD RIGHTALIGN NOTABSTOP
@ 043,120 TEXTBOX ReadHide VALUE " "  WIDTH 15  HEIGHT 25 NOTABSTOP ON CHANGE EvalKeys() ON ENTER Operator_Click("=") INVISIBLE
// 7 8 9 C CE MC
@ 040,008 BUTTONEX BtnN7  CAPTION "7"  WIDTH 32 HEIGHT 32 ACTION Number_Click(7) FONTCOLOR BLUE BOLD
@ 040,048 BUTTONEX BtnN8  CAPTION "8"  ACTION Number_Click(8)     WIDTH 32 HEIGHT 32  FONTCOLOR BLUE BOLD
@ 040,088 BUTTONEX BtnN9  CAPTION "9"  ACTION Number_Click(9)     WIDTH 32 HEIGHT 32  FONTCOLOR BLUE BOLD
@ 040,136 BUTTONEX BtnC   CAPTION "C"  ACTION Cancel_Click()      WIDTH 32 HEIGHT 32 BACKCOLOR CCOLOR  // "C"
@ 040,176 BUTTONEX BtnCE  CAPTION "CE" ACTION CancelEntry_Click() WIDTH 32 HEIGHT 32 BACKCOLOR CCOLOR  // "CE"
@ 040,216 BUTTONEX BtnMC  CAPTION "MC" ACTION CancelMemo_Click()  WIDTH 32 HEIGHT 32 BACKCOLOR MCOLOR  // "MC"
// 4 5 6 + - MR
@ 080,008 BUTTONEX BtnN4  CAPTION "4"  ACTION Number_Click(4)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 080,048 BUTTONEX BtnN5  CAPTION "5"  ACTION Number_Click(5)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 080,088 BUTTONEX BtnN6  CAPTION "6"  ACTION Number_Click(6)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 080,136 BUTTONEX BtnOA  CAPTION "+"  ACTION Operator_Click("+") WIDTH 32 HEIGHT 32 FONTCOLOR BLACK BOLD BACKCOLOR OCOLOR  // "+"
@ 080,176 BUTTONEX BtnOS  CAPTION "-"  ACTION Operator_Click("-") WIDTH 32 HEIGHT 32 FONTCOLOR BLACK BOLD BACKCOLOR OCOLOR  // "-"
@ 080,216 BUTTONEX BtnMR  CAPTION "MR" ACTION ReadMemo_Click()    WIDTH 32 HEIGHT 32 BACKCOLOR MCOLOR  // "MR"
// 1 2 3 X / MS
@ 120,008 BUTTONEX BtnN1  CAPTION "1"  ACTION Number_Click(1)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 120,048 BUTTONEX BtnN2  CAPTION "2"  ACTION Number_Click(2)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 120,088 BUTTONEX BtnN3  CAPTION "3"  ACTION Number_Click(3)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 120,136 BUTTONEX BtnOM  CAPTION "*"  ACTION Operator_Click("*") WIDTH 32 HEIGHT 32 FONTCOLOR BLACK BOLD BACKCOLOR OCOLOR  // "*"
@ 120,176 BUTTONEX BtnOD  CAPTION "/"  ACTION Operator_Click("/") WIDTH 32 HEIGHT 32 FONTCOLOR BLACK BOLD BACKCOLOR OCOLOR  // "/"
@ 120,216 BUTTONEX BtnMS  CAPTION "MS" ACTION SMemo_Click()       WIDTH 32 HEIGHT 32 BACKCOLOR MCOLOR  // "MS"
// 0 . = % M+
@ 160,008 BUTTONEX BtnN0  CAPTION "0"  ACTION Number_Click(0)     WIDTH 72 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 160,088 BUTTONEX BtnDot CAPTION cDec ACTION Decimal_Click()     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD
@ 160,136 BUTTONEX BtnOI  CAPTION "="  ACTION Operator_Click("=") WIDTH 32 HEIGHT 32 FONTCOLOR BLACK BOLD BACKCOLOR OCOLOR  // "="
@ 160,176 BUTTONEX BtnOP  CAPTION "%"  ACTION Percent_Click()     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE BOLD  BACKCOLOR OCOLOR
@ 160,216 BUTTONEX BtnMP  CAPTION "M"  ACTION AddMemo_Click()     WIDTH 32 HEIGHT 32 BACKCOLOR MCOLOR  // "M+"
@ 200,9 GRID HISTORY WIDTH 239 HEIGHT 230 WIDTHS {215} ITEMS {}   DYNAMICFORECOLOR { pColor } ;
   ON GOTFOCUS DOMETHOD("CALC","READHIDE","SETFOCUS")   NOLINES NOHEADERS JUSTIFY { GRID_JTFY_RIGHT } NOTABSTOP

CALC.HISTORY.VISIBLE := .F.

DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8
STATUSITEM "  H = Show History"        ACTION ShowHistory() icon "History"
STATUSITEM " " WIDTH 125               Action ClearHistory()
END STATUSBAR

END WINDOW

_DefineHotKey ( "Calc" , 0 , VK_ESCAPE , {|| DoMethod ( "Calc", "Release" )} )
_DefineHotKey ( "Calc" , 0 , VK_BACK   , {|| CancelEntry_Click()} ) // EMULATE  "CE"
_DefineHotKey ( "Calc" , 0 , VK_DELETE , {|| Cancel_Click()} )      // EMULATE  "C"
_DefineHotKey ( "Calc" , 0 , VK_RIGHT  , {|| ClearLast()} )         // DELETE THE LAST NUMBER ENTERED

_ExtDisableControl ( "ReadOut", "Calc" )

Calc.Center
Calc.Activate

IF lRetu_ClipBoard
   System.Clipboard := Ltrim(Str(nOp1))
endif
release cDec,cSth
Return nOp1
/*
*/
*-----------------------------------------------------------------------------*
// The initialization routine of the form.
// Set the initial values of variables.
*-----------------------------------------------------------------------------*
Static Procedure Form_Load(nInput)

lDecimalFlag := .F.
cLastInput := "NONE"
nNumOps := 0
cOpFlag := " "
nOp1    := 0
nOp2    := 0
Calc.Readout.Value := "0"+cDec
Calc.ReadFunc.Value := " "

IF Valtype(nInput) == "N"
   System.ClipBoard := nInput
   nMemo := nInput
   ReadMemo_Click()
   nMemo := 0
else
   Calc.ReadHide.SetFocus()
endif

Return
/*
*/
*-----------------------------------------------------------------------------*
Static Procedure RemoveCalc()
*-----------------------------------------------------------------------------*
nOp1 := Val( Alltrim( strtran( Calc.Readout.Value,",",".") ) )
Release cDec,cSth
RemoveFont()
Ferase(GetStartUpFolder() + "\Lcdn.ttf")
Return
/*
*/
*-----------------------------------------------------------------------------*
// Event 'click' of BUTTONEX "C" (CANCEL)
// Reset text control ReadOut and clean the variables
*-----------------------------------------------------------------------------*
Static Function Cancel_Click()
Return Form_Load()
/*
*/
*-----------------------------------------------------------------------------*
// Event 'click' of BUTTONEX "CE" (CANCEL ENTRY)   12
// Cancel value on ReadOut (TextBox)
*-----------------------------------------------------------------------------*
Static Procedure CancelEntry_Click()

Calc.Readout.Value := "0"+cDec
lDecimalFlag       := .F.
cLastInput         := "CE"
Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
// Event 'click' of BUTTONEX "." (DECIMAL POINT)
// If the last BUTTONEX pressed, was an operator, show on ReadOut (TextBox)
// the value "0"+cDec. Case not, add a decimal point into ReadOut
*-----------------------------------------------------------------------------*
Static Procedure Decimal_Click()

IF cLastInput = "NEG"
   Calc.Readout.Value := "-0"+cDec
ElseIF cLastInput <> "NUMS"
   Calc.Readout.Value := "0"+cDec
EndIf
lDecimalFlag := .T.
cLastInput   := "NUMS"
Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
// Event 'click' for the BUTTONEXs of 0 to 9 (NUMBERS KEYS)
// Add the new number into ReadOut (TextBox)
*-----------------------------------------------------------------------------*
Static Procedure Number_Click( nIndex )
Local nPos

IF cLastInput <> "NUMS"
   Calc.Readout.Value := cDec
   lDecimalFlag := .F.
EndIf
IF lDecimalFlag
   Calc.Readout.Value := Calc.Readout.Value + Str(nIndex,1)
Else
   Calc.Readout.Value := HB_ULEFT(Calc.Readout.Value,At(cDec,Calc.Readout.Value)-1)+Str(nIndex,1)+cDec
EndIf
IF cLastInput = "NEG"
   Calc.Readout.Value := "-" + Calc.Readout.Value
endif
nPos := at(",",Calc.Readout.Value )-1

IF Len(substr( Calc.Readout.Value,1, nPos ) ) > 14  // There are too many digit
   MessageBoxTimeout (Calc.Readout.Value +CRLF+"Contains too many digits! ( > 14 )";
      +CRLF+"Retry again.", "Input cancelled.", 0 , 3000 )
   CancelEntry_CLick()
Else
   cLastInput := "NUMS"
endif

Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
// Event 'click' for the BUTTONEX "%" (PERCENT KEY)
// Calculate and show, the percentual of first value
*-----------------------------------------------------------------------------*
Static Procedure Percent_Click()
Local cTempReadout
cTempReadout := strtran(Calc.Readout.Value,",",".")

Calc.history.additem( {Calc.Readout.Value+" %"} )

nOp2 := nOp1 * Val(cTempReadout)/100
Calc.Readout.Value := AllTrim(Str(nOp2))

Calc.ReadFunc.Value := "%"
cLastInput := "OPS"
nNumOps ++
lDecimalFlag := .T.
Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
// Event 'click' for the keys "+-*/=" (OPERATOR KEYS)
// IF the last BUTTONEX pressed was a number, or part this.
// Increment the nNumOps. IF a operand be present, define nOp1.
// IF two operand are presenteso, define nOp1 like the result of the
// operation from nOp1 and current value and show the results
*-----------------------------------------------------------------------------*
Static Procedure Operator_Click( cIndex )
Local cTempReadout, nTmp ,cErr := ""

cTempReadout := strtran(Calc.Readout.Value,",",".")

Calc.ReadFunc.Value := cIndex

IF cLastInput = "NUMS"
   nNumOps ++
EndIf

Do Case

Case nNumOps = 0
   IF cIndex = "-" .And. cLastInput <> "NEG"
      Calc.Readout.Value := "-" + Calc.Readout.Value
      cLastInput := "NEG"
   EndIf

Case nNumOps = 1
   nOp1 := TrueVal( cTempReadout )
   Calc.history.additem({ MyTrans( Calc.Readout.Value ) +" "+cIndex })
   IF cIndex = "-" .And. cLastInput <> "NUMS" .And. cOpFlag <> "="
      Calc.Readout.Value := "-"
      cLastInput := "NEG"
   EndIf

Case nNumOps = 2
   nOp2 := TrueVal( cTempReadout )

   Calc.history.additem({MyTrans( Calc.Readout.Value ) +" "+cIndex} )
   Do Case
   Case cOpFlag = "+"
      nOp1 := nOp1 + nOp2
   Case cOpFlag = "-"
      nOp1 := nOp1 - nOp2
   Case cOpFlag = "*"
      nOp1 := nOp1 * nOp2
   Case cOpFlag = "/"
      IF nOp2 = 0
         IF nOp1=0
            cErr := "Undefinited"
         else
            cErr := "Error   "
            MessageBoxTimeout("Division by 0 (zero) not allowed !","Error!", 0 ,2000 )
         Endif
      Else
         nOp1 := nOp1 / nOp2
      EndIf
   Case cOpFlag = "="
      nOp1 := nOp2
   Endcase

   nTmp := hb_ntos(nOp1)
   Calc.Readout.Value := strtran(nTmp,".",cDec )

   nNumOps := 1

   IF Calc.ReadFunc.Value == "="

      IF empty(cErr)
         nTmp := MyTrans( Calc.Readout.Value )
         Calc.history.additem( {"Tot. " + ntmp +"   "} )
         Calc.Readout.Value := nTmp
      Else
         Calc.history.additem( { cErr } )
         Calc.Readout.Value := cErr
      Endif

      calc.history.setfocus
      Calc.history.additem( {" "} )
      IF cErr ="Undefinited"
         Cancel_clicK()
         Return
      Endif
   Endif

Endcase

Calc.history.value := Calc.history.itemcount

IF cLastInput  <> "NEG"
   cLastInput := "OPS"
   cOpFlag    := cIndex
EndIf
Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
Static FUNCTION MyTrans(cVl)        // return a correct transform format template
*-----------------------------------------------------------------------------*
local cRval:="" ,cS , nf , dc := 0, isd :=.F. ,cTval:='', nt
Local nLimit := len(cVl) , nPos := at(cDec,cVl) , cIs , isMin := .F.

IF cSth $ cVl
   cVl := strtran(cVl,cSth,"")
Endif
IF nPos > 0
   cIs := substr(cVl,1,nPos-1)
Else
   cIs := cVl
Endif
IF left(cIs,1) == "-"               // check for negative numbers
   isMin := .T.
   cIs := substr(cIs,2)
   cVl := substr(cVl,2)
Endif

for nf = 1 to nLimit
   cS := substr(cIs,nf,1)
   IF isdigit(cS)
      cRval += "9"
      IF ++dc = 3
         cRval += "."
         dc := 0
      Endif
   Else
      isd := .t.
   Endif
next

cRval := CHARMIRR( cRval )
IF Left( cRval, 1 ) = "."
   cRval := SubStr( cRval, 2 )
EndIF

IF isd                              // There are decimals
   cRval += "," + repl( "9", nlimit-npos)
Endif

nt := 1
for nf = 1 to len(crVal)
   cS := substr(cRval,nf,1)         // extract template
   IF cS = "9"                      // IF isdigit
      cTval += substr(cVl,nt,1)     // add the nt° number
      nt ++
   ElseIF cS ="."
      cTval += cSth                 // add the template separator
   Else
      cTval += substr(cVl,nt,1)     // add the nt° number
      nt ++
   Endif
Next

IF isMin
   cTval := "-" + cTval
Endif
*msgdebug(cTval)
IF isd                              // remove exceeded zero
   cRval := CHARMIRR( cTval )
   nPos  := at(",",crval)
   nt    := val ( left ( crval,npos-1) )
   cS    := IF ( nt > 0 ,Hb_ntos( nt ),"")
   cRval := cS + substr(cRval,IF (nt > 0,npos,npos+1 ) )
   cTval := CHARMIRR( cRval )

Endif

Return ctval
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure clean the variable used for add value into memory
*-----------------------------------------------------------------------------*
Static Procedure CancelMemo_Click
nMemo := 0
SetProperty("Calc","BtnMS","FontBold",.F.)          // Error ---- >  "Form1"
Calc.ReadHide.SetFocus()
Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure show the history
*-----------------------------------------------------------------------------*
Static Procedure ShowHistory( )
state := ! State
SetProperty("Calc","Height", GetProperty("Calc","Height")+ if( state,238,-238) )
Calc.history.visible := State
Calc.statusbar.item(1) := IF (state,"   H = Hide","  H = Show")+" History"
Calc.statusbar.item(2) := IF (state," X = Clear History","")
Calc.statusbar.icon(2) := IF (state,"Trash","")
Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure Clear the history
*-----------------------------------------------------------------------------*
Procedure ClearHistory()
IF state
   domethod("Calc","history","deleteallitems")
Else
   ShowHistory( )
Endif
Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure show in ReadOut (TextBox) the value in memory (nMemo)
*-----------------------------------------------------------------------------*
Static Procedure ReadMemo_Click
// May 2018 path for negative numbers  By Pierpaolo Martinello
Local i ,nv
IF !Empty(nMemo)
   Calc.Readout.Value := ""
   for i := 1 to HMG_LEN(Alltrim(Str(nMemo)))
      nv := Alltrim(HB_USUBSTR(Ltrim(Str(nMemo)),i,1) )
      iif(nv # "." , iIF (nv = "-", Operator_Click("-"), ;
         Number_Click(Val(nv)) ),;
         iif(HMG_LEN(Alltrim(Str(nMemo))) # i, Decimal_Click(),))
   next i
endif
Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure, move to memory (nMemo) the value of ReadOut (TxtBox)
*-----------------------------------------------------------------------------*
Static Procedure SMemo_Click
Local cTempReadout
cTempReadout := Val(strtran(Calc.Readout.Value,",","."))

IF !Empty(Calc.Readout.Value) .and. cTempReadout > 0
   nMemo :=  cTempReadout
   SetProperty("Calc","BtnMS","FontBold",.T.)
   Calc.ReadHide.SetFocus()
endif

Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure add the value from ReadOut (TextBox) into memory
*-----------------------------------------------------------------------------*
Static Procedure AddMemo_Click
Local cTempReadout
cTempReadout := Val(strtran(Calc.Readout.Value,",","."))

IF !Empty(Calc.Readout.Value) .and. cTempReadout > 0
   nMemo += cTempReadout
   SetProperty("Calc","BtnMS","FontBold",.T.)
endif
Calc.ReadHide.SetFocus()

Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure Delete the last number entered
*-----------------------------------------------------------------------------*
Static Procedure ClearLast()
Local cVl := Calc.Readout.Value
Calc.Readout.Value := left(cVl,len(cVl)-1)
cVl := Calc.Readout.Value
IF Right(cVl,1)== cDec
   Calc.Readout.Value := left(cVl,len(cVl)-1)
Endif
IF truevAl(Calc.Readout.Value)=0
   Calc.Readout.Value := "0"
Endif
Return
/*
*/
*-----------------------------------------------------------------------------*
// This Procedure evaluates the keys you type, to perform the functions of
// Calculator keyboard
*-----------------------------------------------------------------------------*
Static Procedure EvalKeys()

Local c_Keys
IF !Empty(Calc.ReadHide.Value)
   c_Keys := Upper( Alltrim(Calc.ReadHide.Value) )
   Do Case
   Case c_Keys == "0" .or. IsDigit(c_Keys)
      Number_Click(Val(c_Keys))
   Case c_Keys == "/"
      Operator_Click("/")
   Case c_Keys == "*"
      Operator_Click("*")
   Case c_Keys == "-"
         Operator_Click("-")
   Case c_Keys == "+"
      Operator_Click("+")
   Case c_Keys == "."
      Decimal_Click()
   Case c_Keys == "C"
      CancelEntry_Click()
   Case c_Keys == "R"
      Cancel_Click()
   Case c_Keys == "W"
      CancelMemo_Click()
   Case c_Keys == "S"
      ReadMemo_Click()
   Case c_Keys == "M"
      SMemo_Click()
   Case c_Keys == "A"
      AddMemo_Click()
   Case c_Keys == "%"
      Percent_Click()
   Case c_Keys == "H"
      ShowHistory()
   Case c_Keys == "X"
      ClearHistory()
      end case
      Calc.ReadHide.Value := ""
endif

Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION HMG_LEN (x)
*-----------------------------------------------------------------------------*
   IF ValType(x) == "C"
      RETURN HB_ULEN (x)
   ELSE
      RETURN LEN (x)
   ENDIF
   RETURN NIL
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Trueval(string)
*-----------------------------------------------------------------------------*
   Local Lenx,I,outval:='',letter
   default string to ''
   Lenx := LEN(string)
   For i = 1 TO Lenx
       letter = SUBST(string,i,1)
       IF letter $ "-0123456789."
          outval += letter
       ENDIF
   NEXT
RETURN VAL(outval)
/*
*/
*-----------------------------------------------------------------------------*
STATIC FUNCTION MakeFont()
*-----------------------------------------------------------------------------*
#pragma __binarystreaminclude "\Res\Lcdn.ttf" | RETURN %s

*-----------------------------------------------------------------------------*

#define FR_PRIVATE   0x10
#define FR_NOT_ENUM  0x20

Static Function AddFont()

Return AddFontResourceEx( "Lcdn.ttf", FR_PRIVATE+FR_NOT_ENUM, 0 )

*-----------------------------------------------------------------------------*

Static Function RemoveFont()

Return RemoveFontResourceEx( "Lcdn.ttf", FR_PRIVATE+FR_NOT_ENUM, 0 )

*-----------------------------------------------------------------------------*

DECLARE DLL_TYPE_INT AddFontResourceEx ( DLL_TYPE_LPCTSTR lpszFilename, DLL_TYPE_DWORD flag, DLL_TYPE_LPVOID pdv ) IN GDI32.DLL
DECLARE DLL_TYPE_BOOL RemoveFontResourceEx ( DLL_TYPE_LPCTSTR lpFileName, DLL_TYPE_DWORD flag, DLL_TYPE_LPVOID pdv ) IN GDI32.DLL

*-----------------------------------------------------------------------------*
