/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Gilbert Vaillancourt <gilbert.vaillancourt.gv@gmail.com>
 *                Quebec, Canada
 *
 * NOTE: This is not an IDE but just a small utility to help creating fancy button rapidly.
 *       This utility is based on WBT from «Roberto Sanchez» included in MiniGUI Extended.
 *       It allows to create a BUTTONEX rapidly without having to recompile to see the result.
 *       Once done the parameters can be save as "Sample File" for further use or modification.
 *       You can save as many Sample Files as wanted or needed.
 *       It also allows to create a "Code file" containing the button syntax to be imported in
 *       any MiniGUI «PRG file». Code file can be saved in the two format syntax :
 *       Standard Windows syntax and Alternate syntax.
 *
 */

#include "minigui.ch"

//-----------------------------------------------------------------------------

static slChanged  := .F.
static scCurrFolder

//-----------------------------------------------------------------------------

procedure Main ()
local nRow
local nCol
local cPath := ""
local aColor
local aFont

announce RDDSYS

set multiple OFF WARNING
set navigation EXTENDED
set tooltip ON
set default icon to "BTBuild"

scCurrFolder := GetCurrentFolder()
_BeginIni(GetStartupFolder() +"\BTBUILD.INI")
nRow := Val(_GetIni("COORD", "ROW", "0"))
nCol := Val(_GetIni("COORD", "COL", "0"))
_EndIni()
if CountMonitors() == 1
   nRow := 0
   nCol := 0
endif

define window oWndMain        ;
       at nRow, nCol          ;
       width 975  height 450  ;
       title "Button Builder" ;
       main nosize nomaximize ;
       on interactiveclose {|| Quit()}

   define toolbar oTlbMain buttonsize 64, 64 flat border

      button oBtnExit picture "EXIT" ;
      caption "Exit"                 ;
      tooltip "Exit Application"     ;
      action  {|| Quit()}            ;
      separator

      button oBtnReset picture "RESET"                  ;
      caption "Reset"                                   ;
      tooltip "Reset sample button to default settings" ;
      action  {|| ResetSample(), UpdtSample()}

      button oBtnRefresh picture "REFRESH"           ;
      caption "Refresh"                              ;
      tooltip "Update sample button to last changes" ;
      action  {|| UpdtSample()}                      ;
      separator

      button oBtnCompile picture "GENCODE" ;
      caption "Gen.Code"                   ;
      tooltip "Generate button code file"  ;
      action  {|| iif(ValidBtnName(), GenCode(), NIL)}

      button oBtnSaveAs picture "GENIMG"                ;
      caption "Gen.Image"                               ;
      tooltip "Generate button image file"              ;
      action  {|| iif(ValidBtnName(), GenImage(), NIL)} ;
      separator

      button oBtnLoad picture "LOADSAMPLE"   ;
      caption "Load"                         ;
      tooltip "Load sample button from file" ;
      action  {|| LoadSample(), UpdtSample()}

      button oBtnSave picture "SAVESAMPLE"  ;
      caption "Save"                        ;
      tooltip "Save sample button to file"  ;
      action  {|| iif(ValidBtnName(), SaveSample(), NIL)}

   end toolbar

   // BUTTON NAME AND POSITION
   //-----------------------------------------------------------------------------

   @ 100,  10 label oLblButton width 60 height 20 value "Button:" bold rightalign transparent

   @ 100,  80 label oLblBtnName width 60 height 20 value "Name:" bold rightalign transparent
   @ 100, 145 textbox oTxtBtnName             ;
              width 160 height 20             ;
              value ""                        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 100, 315 label oLblBtnRow width 30 height 20 value "Row:" bold rightalign transparent
   @ 100, 350 textbox oTxtBtnRow              ;
              width 35  height 20             ;
              value 10                        ;
              numeric inputmask "9999"        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 100, 390 label oLblBtnCol width 30 height 20 value "Col:" bold rightalign transparent
   @ 100, 425 textbox oTxtBtnCol              ;
              width 35  height 20             ;
              value 10                        ;
              numeric inputmask "9999"        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   // BUTTON SIZE
   //-----------------------------------------------------------------------------

   @ 125,  10 label oLblSize width 60 height 20 value "Size:" bold rightalign transparent

   @ 125,  80 label oLblWidth width 60 height 20 value "Width:" bold rightalign transparent
   @ 125, 145 spinner oSpnWidth range 10,450                ;
              width 60 height 20                            ;
              value 100                                     ;
              on change {|| slChanged := .T., UpdtSample()} ;
              on lostfocus {|| UpdtSample()}

   @ 125, 215 label oLblHeight width 60 height 20 value "Height:" bold rightalign transparent
   @ 125, 280 spinner oSpnHeight range 10,265               ;
              width 60 height 20                            ;
              value 40                                      ;
              on change {|| slChanged := .T., UpdtSample()} ;
              on lostfocus {|| UpdtSample()}

   // BUTTON CAPTION AND PARAMETERS
   //-----------------------------------------------------------------------------

   @ 150,  10 label oLblCaption width 60 height 20 value "Caption:" bold rightalign transparent

   @ 150,  80 label oLblCaption1 width 60 height 20 value "Line 1:" bold rightalign transparent
   @ 150, 145 textbox oTxtCaption1            ;
              width 200 height 20             ;
              value ""                        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 175,  80 label oLblCaption2 width 60 height 20 value "Line 2:" bold rightalign transparent
   @ 175, 145 textbox oTxtCaption2            ;
              width 200 height 20             ;
              value ""                        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 145, 355 checkbox oChkVertText caption "Vertical" ;
              width 70 height 15                       ;
              value .F.                                ;
              bold                                     ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 160, 355 checkbox oChkLeftText caption "Left text" ;
              width 70 height 15                        ;
              value .F.                                 ;
              bold                                      ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 175, 355 checkbox oChkUpperText caption "Upper text" ;
              width 80 height 15                          ;
              value .F.                                   ;
              bold                                        ;
              on change {|| slChanged := .T., UpdtSample()}

   // BUTTON IMAGE
   //-----------------------------------------------------------------------------

   @ 200,  10 label oLblImg width 60 height 20 value "Image:" bold rightalign transparent

   @ 200,  80 label oLblImgFile width 60 height 20 value "Path:" bold rightalign transparent
   @ 200, 145 textbox oTxtImgFile             ;
              width 300  height 20            ;
              value ""                        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 200, 445 button oBtnImgFile caption "..."                                                                                     ;
              width 20 height 20                                                                                                   ;
              notabstop                                                                                                            ;
              action {|| cPath := GetFile({{"Image files (*.bmp; *.jpg; *.gif; *.tif; *.png; *.ico)",                              ;
                                                         "*.BMP; *.JPG; *.GIF; *.TIF; *.PNG; *.ICO"}}, "Select Image",, .F., .F.), ;
                                  oWndMain.oTxtImgFile.Value := iif(!Empty(cPath), cPath, oWndMain.oTxtImgFile.Value),             ;
                                  oWndMain.oTxtResName.Value := Upper(FileBase(oWndMain.oTxtImgFile.Value)),                       ;
                                  oWndMain.oChkTransparent.Value := .T.,                                                           ;
                                  slChanged := .T., UpdtSample()}

   @ 225,  80 label oLblResName width 60 height 20 value "RC Name:" bold rightalign transparent
   @ 225, 145 textbox oTxtResName  ;
              width 200  height 20 ;
              value ""             ;
              on change {|| slChanged := .T.}

   @ 225, 355 checkbox oChkResName caption "Use RC Name" ;
              width 100 height 20                        ;
              value .F.                                  ;
              bold                                       ;
              on change {|| slChanged := .T., UpdtSample()}

   // BUTTON STYLE
   //-----------------------------------------------------------------------------

   @ 250,  10 label oLblStyle width 60 height 20 value "Style:" bold rightalign transparent

   @ 250, 145 checkbox oChkXPStyle caption "XP Style" ;
              width 70 height 20                      ;
              value .T.                               ;
              bold                                    ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 250, 225 checkbox oChkHotLight caption "Hot Light" ;
              width 70 height 20                        ;
              value .T.                                 ;
              bold                                      ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 250, 305 checkbox oChkFlat caption "Flat" ;
              width 50 height 20               ;
              value .F.                        ;
              bold                             ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 250, 370 checkbox oChkTransparent caption "Transparent " ;
              width 85 height 20                              ;
              value .F.                                       ;
              bold                                            ;
              on change {|| slChanged := .T., UpdtSample()}

   // BUTTON FOREGROUND AND BACKGROUND COLORS
   //-----------------------------------------------------------------------------

   @ 275,  10 label oLblColor width 60 height 20 value "Color:" bold rightalign transparent

   @ 275,  80 label oLblFontClr width 60 height 20 value "Font color:" bold rightalign transparent
   @ 275, 145 textbox oTxtFontClr             ;
              width 80  height 20             ;
              value "{  0,  0,  0}"           ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 275, 230 button oBtnFontClr caption "..."                                     ;
              width 20 height 20                                                   ;
              notabstop                                                            ;
              action {|| aColor := GetColor(StrToRGB(oWndMain.oTxtFontClr.Value)), ;
                                   oWndMain.oTxtFontClr.Value := RGBToStr(aColor), ;
                                   slChanged := .T., UpdtSample()}

   @ 275, 250 label oLblBackClr width 70 height 20 value "Back color:" bold rightalign transparent
   @ 275, 325 textbox oTxtBackClr             ;
              width 80  height 20             ;
              value "{224,224,224}"           ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 275, 410 button oBtnBackClr caption "..."                                     ;
              width 20 height 20                                                   ;
              notabstop                                                            ;
              action {|| aColor := GetColor(StrToRGB(oWndMain.oTxtBackClr.Value)), ;
                                   oWndMain.oTxtBackClr.Value := RGBToStr(aColor), ;
                                   slChanged := .T., UpdtSample()}

   // BUTTON GRADIEANT COLORS
   //-----------------------------------------------------------------------------

   @ 300,  10 label oLblGradient width 60 height 20 value "Gradient:" bold rightalign transparent

   @ 300,  75 label oLblGradFr width 65 height 20 value "From color:" bold rightalign transparent
   @ 300, 145 textbox oTxtGradFr              ;
              width 80  height 20             ;
              value ""                        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 300, 230 button oBtnGradFr caption "..."                                     ;
              width 20 height 20                                                  ;
              notabstop                                                           ;
              action {|| aColor := GetColor(StrToRGB(oWndMain.oTxtGradFr.Value)), ;
                                   oWndMain.oTxtGradFr.Value := RGBToStr(aColor), ;
                                   slChanged := .T., UpdtSample()}

   @ 300, 250 label oLblGradto width 70 height 20 value "To color:" bold rightalign transparent
   @ 300, 325 textbox oTxtGradTo              ;
              width 80  height 20             ;
              value ""                        ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 300, 410 button oBtnGradTo caption "..."                                     ;
              width 20 height 20                                                  ;
              notabstop                                                           ;
              action {|| aColor := GetColor(StrToRGB(oWndMain.oTxtGradTo.Value)), ;
                                   oWndMain.oTxtGradTo.Value := RGBToStr(aColor), ;
                                   slChanged := .T., UpdtSample()}

   @ 325, 145 checkbox oChkHorizontal caption "Horizontal" ;
              width 80 height 20                           ;
              value .F.                                    ;
              bold                                         ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 325, 325 checkbox oChkVertical caption "Vertical" ;
              width 80 height 20                       ;
              value .T.                                ;
              bold                                     ;
              on change {|| slChanged := .T., UpdtSample()}

   // BUTTON FONT AND ATTRIBUTES
   //-----------------------------------------------------------------------------

   @ 350,  10 label oLblFont width 60 height 20 value "Font:" bold rightalign transparent

   @ 350,  80 label oLblFontName width 60 height 20 value "Name:" bold rightalign transparent
   @ 350, 145 textbox oTxtFontName            ;
              width 150 height 20             ;
              value "ARIAL" size 9            ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 350, 300 button oBtnFont caption "..."                                  ;
              width 20 height 20                                             ;
              notabstop                                                      ;
              action {|| aFont := GetFont(oWndMain.oTxtFontName.Value,       ;
                                          oWndMain.oTxtFontSize.Value,       ;
                                          oWndMain.oChkBold.Value,           ;
                                          oWndMain.oChkItalic.Value,,        ;
                                          oWndMain.oChkUnderLine.Value,      ;
                                          oWndMain.oChkStrikeOut.Value),     ;
                                  oWndMain.oTxtFontName.Value := aFont[1],   ;
                                  oWndMain.oTxtFontSize.Value := aFont[2],   ;
                                  oWndMain.oChkBold.Value := aFont[3],       ;
                                  oWndMain.oChkItalic.Value := aFont[4],     ;
                                  oWndMain.oChkUnderLine.Value := aFont[6],  ;
                                  oWndMain.oChkStrikeOut.Value := aFont[7],  ;
                                  slChanged := .T., UpdtSample()}

   @ 350, 330 label oLblFontSize width 60 height 20 value "Size:" bold rightalign transparent
   @ 350, 395 textbox oTxtFontSize            ;
              width 40  height 20             ;
              value 9                         ;
              numeric                         ;
              on change {|| slChanged := .T.} ;
              on lostfocus {|| UpdtSample()}

   @ 375, 145 checkbox oChkBold caption "Bold" ;
              width 70 height 20               ;
              value .F.                        ;
              bold                             ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 375, 225 checkbox oChkItalic caption "Italic" ;
              width 70 height 20                   ;
              value .F.                            ;
              bold                                 ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 375, 305 checkbox oChkUnderLine caption "UnderLine" ;
              width 75 height 20                         ;
              value .F.                                  ;
              bold                                       ;
              on change {|| slChanged := .T., UpdtSample()}

   @ 375, 385 checkbox oChkStrikeOut caption "StrikeOut" ;
              width 70 height 20                         ;
              value .F.                                  ;
              bold                                       ;
              on change {|| slChanged := .T., UpdtSample()}

   // SAMPLE BUTTON
   //-----------------------------------------------------------------------------

   @ 100, 490 label oLblSample width 465 height 20 value "Sample Button" bold centeralign fontcolor {255,255,255} backcolor {0,0,128}
   @ 125, 490 frame oFrmSample width 465 height 275
   @ 130, 495 buttonex oBtnSample caption "Sample" width 0 height 0

   _DefineHotKey("oWndMain", MOD_ALT, VK_X, {|| Quit()})
   _DefineHotKey("oWndMain",, VK_DOWN,      {|| InsertVKey(VK_TAB)})
   _DefineHotKey("oWndMain", MOD_CONTROL + MOD_ALT, VK_HOME, {|| ResetCoord()})

end window

UpdtSample()

if nRow == 0 .and. nCol == 0
   oWndMain.Center()
endif
oWndMain.Activate()

return

//-----------------------------------------------------------------------------

function ValidBtnName ()
local lValid := .T.

if Empty(oWndMain.oTxtBtnName.Value)
   MsgInfo("Button Name cannot be left empty !", "ERROR")
   oWndMain.oTxtBtnName.SetFocus()
   lValid := .F.
endif

Return (lValid)

//-----------------------------------------------------------------------------

function Quit ()
local nResponse

if CountMonitors() > 1
   _BeginIni(GetStartUpFolder() +"\BTBUILD.INI")
   _SetIni("COORD", "ROW", AllTrim(Str(ThisWindow.Row)))
   _SetIni("COORD", "COL", AllTrim(Str(ThisWindow.Col)))
   _EndIni()
else
   FErase(GetStartUpFolder() +"\BTBUILD.INI")
endif

if slChanged
   nResponse := MsgYesNoCancel("Some changes have been made to this sample."+ CRLF + ;
                               "Do you wish to save them ?", "Save changes")
   do case
   case nResponse == 1  // YES
      SaveSample()
   case nResponse == -1 // CANCEL
      Return (NIL)
   endcase
endif

ReleaseAllWindows()

Return (NIL)

//-----------------------------------------------------------------------------

function ResetCoord ()

ThisWindow.Row := 0
ThisWindow.Col := 0
ThisWindow.Center()

Return (NIL)

//-----------------------------------------------------------------------------

function ResetSample ()

oWndMain.oTxtBtnName.Value     := ""
oWndMain.oTxtBtnRow.Value      := 10
oWndMain.oTxtBtnCol.Value      := 10
oWndMain.oSpnWidth.Value       := 100
oWndMain.oSpnHeight.Value      := 40
oWndMain.oTxtCaption1.Value    := ""
oWndMain.oTxtCaption2.Value    := ""
oWndMain.oChkVertText.Value    := .F.
oWndMain.oChkLeftText.Value    := .F.
oWndMain.oChkUpperText.Value   := .F.
oWndMain.oTxtImgFile.Value     := ""
oWndMain.oTxtResName.Value     := ""
oWndMain.oTxtFontClr.Value     := "{  0,  0,  0}"
oWndMain.oTxtBackClr.Value     := "{224,224,224}"
oWndMain.oTxtGradFr.Value      := ""
oWndMain.oTxtGradTo.Value      := ""
oWndMain.oTxtFontName.Value    := "ARIAL"
oWndMain.oTxtFontSize.Value    := 9
oWndMain.oChkBold.Value        := .F.
oWndMain.oChkItalic.Value      := .F.
oWndMain.oChkUnderLine.Value   := .F.
oWndMain.oChkStrikeOut.Value   := .F.
oWndMain.oChkXPStyle.Value     := .T.
oWndMain.oChkHotLight.Value    := .T.
oWndMain.oChkFlat.Value        := .F.
oWndMain.oChkTransparent.Value := .F.
oWndMain.oChkHorizontal.Value  := .F.
oWndMain.oChkVertical.Value    := .T.
DoEvents()

oWndMain.oTxtBtnName.SetFocus()
slChanged := .F.

Return (NIL)

//-----------------------------------------------------------------------------

function UpdtSample ()
local cCaption
local aGradientFill := NIL
local lHorizontal   := NIL

do case
case Empty(oWndMain.oTxtCaption1.Value) .and. Empty(oWndMain.oTxtCaption2.Value)
   cCaption := "Sample"
case !Empty(oWndMain.oTxtCaption1.Value) .and. Empty(oWndMain.oTxtCaption2.Value)
   cCaption := AllTrim(oWndMain.oTxtCaption1.Value)
case Empty(oWndMain.oTxtCaption1.Value) .and. !Empty(oWndMain.oTxtCaption2.Value)
   cCaption := AllTrim(oWndMain.oTxtCaption2.Value)
case !Empty(oWndMain.oTxtCaption1.Value) .and. !Empty(oWndMain.oTxtCaption2.Value)
   cCaption := AllTrim(oWndMain.oTxtCaption1.Value) + CRLF + AllTrim(oWndMain.oTxtCaption2.Value)
endcase

if (!oWndMain.oChkXPStyle.Value .and. !Empty(oWndMain.oTxtGradFr.Value) .and. !Empty(oWndMain.oTxtGradTo.Value))
   do case
   case !oWndMain.oChkHorizontal.Value .and. !oWndMain.oChkVertical.Value
      aGradientFill := {{1, StrToRGB(oWndMain.oTxtGradFr.Value), StrToRGB(oWndMain.oTxtGradTo.Value)}}
      lHorizontal   := .T.
   case oWndMain.oChkHorizontal.Value .and. !oWndMain.oChkVertical.Value
      aGradientFill := {{1, StrToRGB(oWndMain.oTxtGradFr.Value), StrToRGB(oWndMain.oTxtGradTo.Value)}}
      lHorizontal   := .T.
   case !oWndMain.oChkHorizontal.Value .and. oWndMain.oChkVertical.Value
      aGradientFill := {{1, StrToRGB(oWndMain.oTxtGradFr.Value), StrToRGB(oWndMain.oTxtGradTo.Value)}}
      lHorizontal   := .F.
   case oWndMain.oChkHorizontal.Value .and. oWndMain.oChkVertical.Value
      aGradientFill := {{StrToRGB(oWndMain.oTxtGradFr.Value), StrToRGB(oWndMain.oTxtGradTo.Value)}}
   endcase
endif

if oWndMain.oChkVertText.Value
   oWndMain.oChkLeftText.Enabled  := .F.
   oWndMain.oChkUpperText.Enabled := .T.
else
   oWndMain.oChkLeftText.Enabled  := .T.
   oWndMain.oChkUpperText.Enabled := .F.
endif

if oWndMain.oChkXPStyle.Value
   oWndMain.oChkFlat.Enabled       := .F.
   oWndMain.oTxtBackClr.Enabled    := .F.
   oWndMain.oBtnBackClr.Enabled    := .F.
   oWndMain.oTxtGradFr.Enabled     := .F.
   oWndMain.oBtnGradFr.Enabled     := .F.
   oWndMain.oTxtGradTo.Enabled     := .F.
   oWndMain.oBtnGradTo.Enabled     := .F.
   oWndMain.oChkHorizontal.Enabled := .F.
   oWndMain.oChkVertical.Enabled   := .F.
else
   oWndMain.oChkFlat.Enabled       := .T.
   oWndMain.oTxtBackClr.Enabled    := .T.
   oWndMain.oBtnBackClr.Enabled    := .T.
   oWndMain.oTxtGradFr.Enabled     := .T.
   oWndMain.oBtnGradFr.Enabled     := .T.
   oWndMain.oTxtGradTo.Enabled     := .T.
   oWndMain.oBtnGradTo.Enabled     := .T.
   oWndMain.oChkHorizontal.Enabled := .T.
   oWndMain.oChkVertical.Enabled   := .T.
endif

oWndMain.oBtnSample.Release()
DoEvents()

define buttonex oBtnSample
   parent        oWndMain
   row           130
   col           495
   width         oWndMain.oSpnWidth.Value
   height        oWndMain.oSpnHeight.Value
   caption       cCaption
   vertical      oWndMain.oChkVertText.Value
   lefttext      oWndMain.oChkLeftText.Value
   uppertext     oWndMain.oChkUpperText.Value
   picture       oWndMain.oTxtImgFile.Value
   fontname      oWndMain.oTxtFontName.Value
   fontsize      oWndMain.oTxtFontSize.Value
   fontbold      oWndMain.oChkBold.Value
   fontitalic    oWndMain.oChkItalic.Value
   fontunderline oWndMain.oChkUnderLine.Value
   fontstrikeout oWndMain.oChkStrikeOut.Value
   fontcolor     StrToRGB(oWndMain.oTxtFontClr.Value)
   backcolor     StrToRGB(oWndMain.oTxtBackClr.Value)
   gradientfill  aGradientFill
   horizontal    lHorizontal
   noxpstyle     !oWndMain.oChkXPStyle.Value
   nohotlight    !oWndMain.oChkHotLight.Value
   flat          oWndMain.oChkFlat.Value
   notransparent !oWndMain.oChkTransparent.Value
   adjust        .F.
end buttonex
DoEvents()

Return (NIL)

//-----------------------------------------------------------------------------

function SaveSample ()
local z
local cFileName
local nHandle
local aSyntax := {}

cFileName := PutFile({{"Sample files (.smp)", "*.SMP"}}, "Save as", GetStartupFolder(), .F., AllTrim(oWndMain.oTxtBtnName.Value) +".smp")
SetCurrentFolder(scCurrFolder)
if Empty(cFileName)
   Return (NIL)
endif
cFileName := AllTrim(cFileName)
if File(cFileName)
   if !MsgYesNo("File already exist."+ CRLF +"Do you wish to overwrite ?", cFileName)
      Return (NIL)
   endif
endif

nHandle := FCreate(cFileName)

AAdd(aSyntax, "oTxtBtnName="+     AllTrim(oWndMain.oTxtBtnName.Value))
AAdd(aSyntax, "oTxtBtnRow="+      AllTrim(Str(oWndMain.oTxtBtnRow.Value)))
AAdd(aSyntax, "oTxtBtnCol="+      AllTrim(Str(oWndMain.oTxtBtnCol.Value)))
AAdd(aSyntax, "oSpnWidth="+       AllTrim(Str(oWndMain.oSpnWidth.Value)))
AAdd(aSyntax, "oSpnHeight="+      AllTrim(Str(oWndMain.oSpnHeight.Value)))
AAdd(aSyntax, "oTxtCaption1="+    AllTrim(oWndMain.oTxtCaption1.Value))
AAdd(aSyntax, "oTxtCaption2="+    AllTrim(oWndMain.oTxtCaption2.Value))
AAdd(aSyntax, "oChkVertText="+    LtoC(oWndMain.oChkVertText.Value))
AAdd(aSyntax, "oChkLeftText="+    LtoC(oWndMain.oChkLeftText.Value))
AAdd(aSyntax, "oChkUpperText="+   LtoC(oWndMain.oChkUpperText.Value))
AAdd(aSyntax, "oTxtImgFile="+     AllTrim(oWndMain.oTxtImgFile.Value))
AAdd(aSyntax, "oTxtResName="+     AllTrim(oWndMain.oTxtResName.Value))
AAdd(aSyntax, "oChkResName="+     LtoC(oWndMain.oChkResName.Value))
AAdd(aSyntax, "oTxtFontName="+    AllTrim(oWndMain.oTxtFontName.Value))
AAdd(aSyntax, "oTxtFontSize="+    AllTrim(Str(oWndMain.oTxtFontSize.Value)))
AAdd(aSyntax, "oChkBold="+        LtoC(oWndMain.oChkBold.Value))
AAdd(aSyntax, "oChkItalic="+      LtoC(oWndMain.oChkItalic.Value))
AAdd(aSyntax, "oChkUnderLine="+   LtoC(oWndMain.oChkUnderLine.Value))
AAdd(aSyntax, "oChkStrikeOut="+   LtoC(oWndMain.oChkStrikeOut.Value))
AAdd(aSyntax, "oTxtFontClr="+     AllTrim(oWndMain.oTxtFontClr.Value))
AAdd(aSyntax, "oTxtBackClr="+     AllTrim(oWndMain.oTxtBackClr.Value))
AAdd(aSyntax, "oTxtGradFr="+      AllTrim(oWndMain.oTxtGradFr.Value))
AAdd(aSyntax, "oTxtGradTo="+      AllTrim(oWndMain.oTxtGradTo.Value))
AAdd(aSyntax, "oChkHorizontal="+  LtoC(oWndMain.oChkHorizontal.Value))
AAdd(aSyntax, "oChkVertical="+    LtoC(oWndMain.oChkVertical.Value))
AAdd(aSyntax, "oChkXPStyle="+     LtoC(oWndMain.oChkXPStyle.Value))
AAdd(aSyntax, "oChkHotLight="+    LtoC(oWndMain.oChkHotLight.Value))
AAdd(aSyntax, "oChkFlat="+        LtoC(oWndMain.oChkFlat.Value))
AAdd(aSyntax, "oChkTransparent="+ LtoC(oWndMain.oChkTransparent.Value))

for z = 1 to Len(aSyntax)
   FWrite(nHandle, aSyntax[z] + CRLF)
next z

FClose(nHandle)
MsgInfo("Sample file saved", "Saved")
slChanged := .F.

Return (NIL)

//-----------------------------------------------------------------------------

function LoadSample ()
local cFileName
local aSyntax

cFileName := GetFile({{"Sample files (.smp)", "*.SMP"}}, "Select sample file", GetStartupFolder(), .F., .F.)
SetCurrentFolder(scCurrFolder)
if Len(cFileName) == 0
   Return (NIL)
endif

aSyntax := HB_ATokens(MemoRead(cFileName), CRLF)
ResetSample()

oWndMain.oTxtBtnName.Value     := Token(aSyntax[ 1], "=", 2)
oWndMain.oTxtBtnRow.Value      := Val(Token(aSyntax[ 2], "=", 2))
oWndMain.oTxtBtnCol.Value      := Val(Token(aSyntax[ 3], "=", 2))
oWndMain.oSpnWidth.Value       := Val(Token(aSyntax[ 4], "=", 2))
oWndMain.oSpnHeight.Value      := Val(Token(aSyntax[ 5], "=", 2))
oWndMain.oTxtCaption1.Value    := Token(aSyntax[ 6], "=", 2)
oWndMain.oTxtCaption2.Value    := Token(aSyntax[ 7], "=", 2)
oWndMain.oChkVertText.Value    := CtoL(Token(aSyntax[ 8], "=", 2))
oWndMain.oChkLeftText.Value    := CtoL(Token(aSyntax[ 9], "=", 2))
oWndMain.oChkUpperText.Value   := CtoL(Token(aSyntax[10], "=", 2))
oWndMain.oTxtImgFile.Value     := Token(aSyntax[11], "=", 2)
oWndMain.oTxtResName.Value     := Token(aSyntax[12], "=", 2)
oWndMain.oChkResName.Value     := CtoL(Token(aSyntax[13], "=", 2))
oWndMain.oTxtFontName.Value    := Token(aSyntax[14], "=", 2)
oWndMain.oTxtFontSize.Value    := Val(Token(aSyntax[15], "=", 2))
oWndMain.oChkBold.Value        := CtoL(Token(aSyntax[16], "=", 2))
oWndMain.oChkItalic.Value      := CtoL(Token(aSyntax[17], "=", 2))
oWndMain.oChkUnderLine.Value   := CtoL(Token(aSyntax[18], "=", 2))
oWndMain.oChkStrikeOut.Value   := CtoL(Token(aSyntax[19], "=", 2))
oWndMain.oTxtFontClr.Value     := Token(aSyntax[20], "=", 2)
oWndMain.oTxtBackClr.Value     := Token(aSyntax[21], "=", 2)
oWndMain.oTxtGradFr.Value      := Token(aSyntax[22], "=", 2)
oWndMain.oTxtGradTo.Value      := Token(aSyntax[23], "=", 2)
oWndMain.oChkHorizontal.Value  := CtoL(Token(aSyntax[24], "=", 2))
oWndMain.oChkVertical.Value    := CtoL(Token(aSyntax[25], "=", 2))
oWndMain.oChkXPStyle.Value     := CtoL(Token(aSyntax[26], "=", 2))
oWndMain.oChkHotLight.Value    := CtoL(Token(aSyntax[27], "=", 2))
oWndMain.oChkFlat.Value        := CtoL(Token(aSyntax[28], "=", 2))
oWndMain.oChkTransparent.Value := CtoL(Token(aSyntax[29], "=", 2))
DoEvents()

oWndMain.oTxtBtnName.SetFocus()
slChanged := .F.

Return (NIL)

//-----------------------------------------------------------------------------

function GenCode ()
local z
local aSyntax  := {}
local nLineLen
local cLine
local nOption
local cFileName
local nHandle
local cCaption
local cGradientFill
local cHorizontal

oWndMain.oBtnSample.Setfocus()

if !MsgRadio(,, "Options", "Select an option", {"Standard Window Syntax", "Alternate Window Syntax"}, @nOption)
   Return (NIL)
endif
cFileName := PutFile({{"Code files (.cod)", "*.COD"}}, "Save as", GetCurrentFolder(), .F., AllTrim(oWndMain.oTxtBtnName.Value) +".cod")
SetCurrentFolder(scCurrFolder)
if Empty(cFileName)
   Return (NIL)
endif
cFileName := AllTrim(cFileName)
if File(cFileName)
   if !MsgYesNo("File already exist."+ CRLF +"Do you wish to overwrite ?", cFileName)
      Return (NIL)
   endif
endif

do case
case Empty(oWndMain.oTxtCaption1.Value) .and. Empty(oWndMain.oTxtCaption2.Value)
   cCaption := "Sample"
case !Empty(oWndMain.oTxtCaption1.Value) .and. Empty(oWndMain.oTxtCaption2.Value)
   cCaption := '"'+ AllTrim(oWndMain.oTxtCaption1.Value) +'"'
case Empty(oWndMain.oTxtCaption1.Value) .and. !Empty(oWndMain.oTxtCaption2.Value)
   cCaption := '"'+ AllTrim(oWndMain.oTxtCaption2.Value) +'"'
case !Empty(oWndMain.oTxtCaption1.Value) .and. !Empty(oWndMain.oTxtCaption2.Value)
   cCaption := '"'+ AllTrim(oWndMain.oTxtCaption1.Value) +'"+ CRLF +"'+ AllTrim(oWndMain.oTxtCaption2.Value) +'"'
endcase

nHandle := FCreate(cFileName)
FWrite(nHandle, CRLF)

if nOption == 1

   AAdd(aSyntax, "@ "+ PadL(AllTrim(Str(oWndMain.oTxtBtnRow.Value)), 4) +", "+ PadL(AllTrim(Str(oWndMain.oTxtBtnCol.Value)), 4) +" buttonex "+ AllTrim(oWndMain.oTxtBtnName.Value))
   AAdd(aSyntax, Space(13) +"caption "+ '"'+ AllTrim(cCaption) +'"')
   AAdd(aSyntax, Space(13) +"width "+ AllTrim(Str(oWndMain.oSpnWidth.Value)) +" height "+ AllTrim(Str(oWndMain.oSpnHeight.Value)))

   do case
   case (!Empty(oWndMain.oTxtImgFile.Value) .and. !oWndMain.oChkResName.Value)
      AAdd(aSyntax, Space(13) +"picture "+ '"'+ AllTrim(oWndMain.oTxtImgFile.Value) +'"')
   case (oWndMain.oChkResName.Value .and. Empty(oWndMain.oTxtResName.Value))
      AAdd(aSyntax, Space(13) +"picture "+ '"'+ AllTrim(oWndMain.oTxtImgFile.Value) +'"')
   case (Empty(oWndMain.oTxtImgFile.Value) .and. !Empty(oWndMain.oTxtResName.Value))
      AAdd(aSyntax, Space(13) +"picture "+ '"'+ AllTrim(oWndMain.oTxtResName.Value) +'"')
   case (oWndMain.oChkResName.Value .and. !Empty(oWndMain.oTxtResName.Value))
      AAdd(aSyntax, Space(13) +"picture "+ '"'+ AllTrim(oWndMain.oTxtResName.Value) +'"')
   endcase

   AAdd(aSyntax, Space(13) +"action «Put Action Here»")

   do case
   case (!Empty(oWndMain.oTxtFontName.Value) .and. oWndMain.oTxtFontSize.Value > 0)
      AAdd(aSyntax, Space(13) +"font "+ '"'+ AllTrim(oWndMain.oTxtFontName.Value) +'"' +" size "+ AllTrim(Str(oWndMain.oTxtFontSize.Value)))
   case (!Empty(oWndMain.oTxtFontName.Value) .and. oWndMain.oTxtFontSize.Value == 0)
      AAdd(aSyntax, Space(13) +"font "+ '"'+ AllTrim(oWndMain.oTxtFontName.Value) +'"')
   case (Empty(oWndMain.oTxtFontName.Value) .and. oWndMain.oTxtFontSize.Value > 0)
      AAdd(aSyntax, Space(13) +"size "+ AllTrim(Str(oWndMain.oTxtFontSize.Value)))
   endcase

   cLine := ""
   if oWndMain.oChkBold.Value
      cLine += "bold "
   endif
   if oWndMain.oChkItalic.Value
      cLine += "italic "
   endif
   if oWndMain.oChkUnderLine.Value
      cLine += "underline "
   endif
   if oWndMain.oChkStrikeOut.Value
      cLine += "strikeout "
   endif
   if (oWndMain.oChkBold.Value .or. oWndMain.oChkItalic.Value .or. oWndMain.oChkUnderLine.Value .or. oWndMain.oChkStrikeOut.Value)
      AAdd(aSyntax, Space(13) + cLine)
   endif

   cLine := ""
   if oWndMain.oChkVertText.Value
      cLine += "vertical "
   endif
   if (oWndMain.oChkLeftText.Value .and. !oWndMain.oChkVertText.Value)
      cLine += "lefttext "
   endif
   if (oWndMain.oChkUpperText.Value .and. oWndMain.oChkVertText.Value)
      cLine += "uppertext "
   endif
   if (oWndMain.oChkVertText.Value .or. oWndMain.oChkLeftText.Value .or. oWndMain.oChkUpperText.Value)
      AAdd(aSyntax, Space(13) + cLine)
   endif

   if (!Empty(oWndMain.oTxtFontClr.Value) .and. oWndMain.oTxtFontClr.Value <> "{  0,  0,  0}")
      AAdd(aSyntax, Space(13) +"fontcolor "+ AllTrim(oWndMain.oTxtFontClr.Value))
   endif
   if (!Empty(oWndMain.oTxtBackClr.Value) .and. oWndMain.oTxtBackClr.Value <> "{224,224,224}" .and. !oWndMain.oChkXPStyle.Value)
      AAdd(aSyntax, Space(13) +"backcolor "+ AllTrim(oWndMain.oTxtBackClr.Value))
   endif

   if (!oWndMain.oChkXPStyle.Value .and. !Empty(oWndMain.oTxtGradFr.Value) .and. !Empty(oWndMain.oTxtGradTo.Value))
      do case
      case !oWndMain.oChkHorizontal.Value .and. !oWndMain.oChkVertical.Value
         cGradientFill := "{{1, "+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal := "horizontal"
      case oWndMain.oChkHorizontal.Value .and. !oWndMain.oChkVertical.Value
         cGradientFill := "{{1, "+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal := "horizontal"
      case !oWndMain.oChkHorizontal.Value .and. oWndMain.oChkVertical.Value
         cGradientFill := "{{1, "+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal := ""
      case oWndMain.oChkHorizontal.Value .and. oWndMain.oChkVertical.Value
         cGradientFill := "{{"+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal := ""
      endcase
      AAdd(aSyntax, Space(13) +"gradientfill "+ cGradientFill)
      if !Empty(cHorizontal)
         AAdd(aSyntax, Space(13) + cHorizontal)
      endif
   endif

   cLine := ""
   if !oWndMain.oChkXPStyle.Value
      cLine += "noxpstyle "
   endif
   if !oWndMain.oChkHotLight.Value
      cLine += "nohotlight "
   endif
   if (oWndMain.oChkFlat.Value .and. !oWndMain.oChkXPStyle.Value)
      cLine += "flat "
   endif
   if !oWndMain.oChkTransparent.Value
      cLine += "notransparent "
   endif
   if (!oWndMain.oChkXPStyle.Value .or. !oWndMain.oChkHotLight.Value .or. oWndMain.oChkFlat.Value .and. !oWndMain.oChkTransparent.Value)
      AAdd(aSyntax, Space(13) + cLine)
   endif

   nLineLen := LonguestLine(aSyntax)
   for z = 1 to Len(aSyntax)
      if z < Len(aSyntax)
         FWrite(nHandle, PadR(RTrim(aSyntax[z]), nLineLen, " ") +" ;"+ CRLF)
      else
         FWrite(nHandle, RTrim(aSyntax[z]) + CRLF)
      endif
   next z

else

   AAdd(aSyntax, "define buttonex "+ AllTrim(oWndMain.oTxtBtnName.Value))
   AAdd(aSyntax, Space(3) +"parent"+ Space(8) +"thiswindow.name")
   AAdd(aSyntax, Space(3) +"row"+ Space(11) + AllTrim(Str(oWndMain.oTxtBtnRow.Value)))
   AAdd(aSyntax, Space(3) +"col"+ Space(11) + AllTrim(Str(oWndMain.oTxtBtnCol.Value)))
   AAdd(aSyntax, Space(3) +"width"+ Space(9) + AllTrim(Str(oWndMain.oSpnWidth.Value)))
   AAdd(aSyntax, Space(3) +"height"+ Space(8) + AllTrim(Str(oWndMain.oSpnHeight.Value)))
   AAdd(aSyntax, Space(3) +"caption"+ Space(7) + '"'+ AllTrim(cCaption) +'"')
   AAdd(aSyntax, Space(3) +"action"+ Space(8) +"MsgInfo( 'Click!' )")

   if oWndMain.oChkVertText.Value
      AAdd(aSyntax, Space(3) +"vertical"+ Space(6) + ".T.")
   endif
   if oWndMain.oChkLeftText.Value
      AAdd(aSyntax, Space(3) +"lefttext"+ Space(6) + ".T.")
   endif
   if oWndMain.oChkUpperText.Value
      AAdd(aSyntax, Space(3) +"uppertext"+ Space(5) + ".T.")
   endif

   do case
   case (!Empty(oWndMain.oTxtImgFile.Value) .and. !oWndMain.oChkResName.Value)
      AAdd(aSyntax, Space(3) +"picture"+ Space(7) + '"'+ AllTrim(oWndMain.oTxtImgFile.Value) +'"')
   case (oWndMain.oChkResName.Value .and. Empty(oWndMain.oTxtResName.Value))
      AAdd(aSyntax, Space(3) +"picture"+ Space(7) + '"'+ AllTrim(oWndMain.oTxtImgFile.Value) +'"')
   case (Empty(oWndMain.oTxtImgFile.Value) .and. !Empty(oWndMain.oTxtResName.Value))
      AAdd(aSyntax, Space(3) +"picture"+ Space(7) + '"'+ AllTrim(oWndMain.oTxtResName.Value) +'"')
   case (oWndMain.oChkResName.Value .and. !Empty(oWndMain.oTxtResName.Value))
      AAdd(aSyntax, Space(3) +"picture"+ Space(7) + '"'+ AllTrim(oWndMain.oTxtResName.Value) +'"')
   endcase

   if !Empty(oWndMain.oTxtFontName.Value)
      AAdd(aSyntax, Space(3) +"fontname"+ Space(6) +'"'+ AllTrim(oWndMain.oTxtFontName.Value) +'"')
   endif
   if oWndMain.oTxtFontSize.Value > 0
      AAdd(aSyntax, Space(3) +"fontsize"+ Space(6) + AllTrim(Str(oWndMain.oTxtFontSize.Value)))
   endif
   if oWndMain.oChkBold.Value
      AAdd(aSyntax, Space(3) +"fontbold"+ Space(6) + ".T.")
   endif
   if oWndMain.oChkItalic.Value
      AAdd(aSyntax, Space(3) +"fontitalic"+ Space(4) + ".T.")
   endif
   if oWndMain.oChkUnderLine.Value
      AAdd(aSyntax, Space(3) +"fontunderline"+ Space(1) + ".T.")
   endif
   if oWndMain.oChkStrikeOut.Value
      AAdd(aSyntax, Space(3) +"fontstrikeout"+ Space(1) + ".T.")
   endif                       

   if (!Empty(oWndMain.oTxtFontClr.Value) .and. oWndMain.oTxtFontClr.Value <> "{  0,  0,  0}")
      AAdd(aSyntax, Space(3) +"fontcolor"+ Space(5) + AllTrim(oWndMain.oTxtFontClr.Value))
   endif
   if (!Empty(oWndMain.oTxtBackClr.Value) .and. oWndMain.oTxtBackClr.Value <> "{224,224,224}" .and. !oWndMain.oChkXPStyle.Value)
      AAdd(aSyntax, Space(3) +"backcolor"+ Space(5) + AllTrim(oWndMain.oTxtBackClr.Value))
   endif

   if (!oWndMain.oChkXPStyle.Value .and. !Empty(oWndMain.oTxtGradFr.Value) .and. !Empty(oWndMain.oTxtGradTo.Value))
      do case
      case !oWndMain.oChkHorizontal.Value .and. !oWndMain.oChkVertical.Value
         cGradientFill := "{{1, "+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal   := ".T."
      case oWndMain.oChkHorizontal.Value .and. !oWndMain.oChkVertical.Value
         cGradientFill := "{{1, "+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal   := ".T."
      case !oWndMain.oChkHorizontal.Value .and. oWndMain.oChkVertical.Value
         cGradientFill := "{{1, "+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
         cHorizontal   := ".F."
      case oWndMain.oChkHorizontal.Value .and. oWndMain.oChkVertical.Value
         cGradientFill := "{{"+ AllTrim(oWndMain.oTxtGradFr.Value) +", "+ AllTrim(oWndMain.oTxtGradTo.Value) +"}}"
      endcase
      AAdd(aSyntax, Space(3) +"gradientfill"+ Space(2) + cGradientFill)
      if cHorizontal <> NIL
         AAdd(aSyntax, Space(3) +"horizontal"+ Space(4) + cHorizontal)
      endif
   endif

   if !oWndMain.oChkXPStyle.Value
      AAdd(aSyntax, Space(3) +"noxpstyle"+ Space(5) + ".T.")
   endif
   if !oWndMain.oChkHotLight.Value
      AAdd(aSyntax, Space(3) +"nohotlight"+ Space(4) + ".T.")
   endif
   if oWndMain.oChkFlat.Value
      AAdd(aSyntax, Space(3) +"flat"+ Space(10) + ".T.")
   endif
   if !oWndMain.oChkTransparent.Value
      AAdd(aSyntax, Space(3) +"notransparent"+ Space(1) + ".T.")
   endif

   AAdd(aSyntax, "end buttonex")

   for z = 1 to Len(aSyntax)
      FWrite(nHandle, RTrim(aSyntax[z]) + CRLF)
   next z

endif

FClose(nHandle)
MsgInfo("Code file saved", "Saved")
oWndMain.oTxtBtnName.Setfocus()

Return (NIL)

//-----------------------------------------------------------------------------

function GenImage ()
local cFileName
local lSave := .T.

cFileName := PutFile({{"Bitmap", "*.BMP"}}, "Save Button image", GetStartupFolder(), .F., AllTrim(oWndMain.oTxtBtnName.Value) +".bmp")
SetCurrentFolder(scCurrFolder)

if Empty(cFileName)
   PlayExclamation()
   MsgExclamation("Button image was not saved", "Fail")
   Return (NIL)
endif

if At(".", cFileName) == 0
   cFileName := cFileName +".bmp"
endif

if File(cFileName)
   PlayExclamation()
   if !MsgYesNo("File already exist."+ CRLF +"Do you wish to overwrite ?", cFileName)
      lSave := .F.
   endif
endif

if lSave
   oWndMain.oBtnSample.Setfocus()
   oWndMain.oBtnSample.SaveAs(cFileName)
   MsgInfo("Image file saved", "Saved")
endif

Return (NIL)

//-----------------------------------------------------------------------------

function LonguestLine (aSyntax)
local z
local nLenght  := 0
local nElement := Len(aSyntax)

for z = 1 to nElement
   nLenght := Max(Len(aSyntax[z]), nLenght)
next z

Return (nLenght)

//-----------------------------------------------------------------------------

function StrToRGB (cColor)
local nRed
local nGreen
local nBlue
local cTemp

cTemp  := Token(cColor, ",", 1)
cTemp  := CharRepl("{}", cTemp, " ")
nRed   := Val(AllTrim(cTemp))
cTemp  := Token(cColor, ",", 2)
cTemp  := CharRepl("{}", cTemp, " ")
nGreen := Val(AllTrim(cTemp))
cTemp  := Token(cColor, ",", 3)
cTemp  := CharRepl("{}", cTemp, " ")
nBlue  := Val(AllTrim(cTemp))

Return ({nRed, nGreen, nBlue})

//-----------------------------------------------------------------------------

function RGBToStr (aColor)
local cColor := ""

if IsArrayRGB (aColor)
   cColor := "{"+ PadL(AllTrim(Str(aColor[1])), 3) +","+ ;
                  PadL(AllTrim(Str(aColor[2])), 3) +","+ ;
                  PadL(AllTrim(Str(aColor[3])), 3) +"}"
endif

Return (cColor)

//-----------------------------------------------------------------------------

function FileBase (cFile)
local nSlashPos
local cFileBase := AllTrim(cFile)

cFile := AllTrim(cFile)
do case
case RAt("\", cFile) != 0
   nSlashPos := RAt("\", cFile)
   cFileBase := SubStr(cFile, nSlashPos +1)
case At(":", cFile ) != 0
   nSlashPos := At(":", cFile)
   cFileBase := SubStr(cFile, nSlashPos +1)
endcase
if At(".", cFileBase) != 0
   nSlashPos := At(".", cFileBase)
   cFileBase := SubStr(cFileBase, 1, nSlashPos -1)
endif

Return (cFileBase)

//-----------------------------------------------------------------------------

function FileExt (cFile)
local nDotPos
local cFileExt := ""

cFile   := Upper(AllTrim(cFile))
nDotPos := RAt(".", cFile)
if nDotPos != 0
   cFileExt := SubStr(cFile, nDotPos +1)
endif

Return (cFileExt)

//-----------------------------------------------------------------------------

function CtoL (cValue)
Return (iif(cValue == "T", .T., .F.))


//---------------------------------------------------------------------------
//
// MsgRadio (nRow, nCol, cTitle, cCaption, aOptions, @nOption)
//
// Purpose:  Display radio button for user selection
//
//  Params:    <nRow>   Topmost row where window will be displayed
//                       -> Default to 0 (Centered)
//             <nCol>   Leftmost column where window will be displayed
//                       -> Default to 0 (Centered)
//           <cTitle>   Header title to be displayed
//                       -> Default to "Available options"
//         <cCaption>   Text to be displayed beside the capture field
//                       -> Default to "Select"
//         <aOptions>   Array of options to be selected from
//          <nOption>   Default selected option
//                       -> Default to 1
//                          Must be passed as reference
//
//    Note: Result is stored to nOption
//
//  Return: Logical expression
//          -> .T. if Accept button has been pressed
//             .F. if Cancel button has been pressed
//
//  Sample:
//          local nOption   := 1
//          local aOptions  := {"Printer", "Screen", "Text File", "PDF File"}
//
//          if !MsgRadio(,, "Report Options", "Select an option", aOptions, @nOption)
//             Return (NIL)
//          endif
//
//---------------------------------------------------------------------------

function MsgRadio (nRow, nCol, cTitle, cCaption, aOptions, nOption)
local z
local nWidth
local nHeight
local nRadWidth := 0
local lReturn   := .F.

cTitle   := iif(cTitle == NIL, "Available options", cTitle)
cCaption := iif(cCaption == NIL, "Select", cCaption)
nOption  := iif(nOption == NIL, 1, nOption)
nOption  := iif(nOption <= 0, 1, nOption)
nOption  := iif(nOption > Len(aOptions), 1, nOption)
nRow     := iif(nRow == NIL, 0, nRow)
nCol     := iif(nCol == NIL, 0, nCol)

for z = 1 to Len(aOptions)
   aOptions[z] := Alltrim(aOptions[z])
   nRadWidth   := Max(Len(aOptions[z]) *8, nRadWidth)
next z
nRadWidth += 5

nWidth  := Max((nRadWidth +25), 230)
nHeight := (Len(aOptions) *24) +115

if nRow == 0
   nRow := ThisWindow.Row + Int(ThisWindow.Height /2) - Int(nHeight /2)
endif

if nCol == 0
   nCol := ThisWindow.Col + Int(ThisWindow.Width /2) - Int(nWidth /2)
endif

define window oDlgMsgRadio ;
       at nRow, nCol       ;
       width  nWidth       ;
       height nHeight      ;
       title cTitle        ;
       modal nosize

   @ 15, 10 label oLblMsgGet value cCaption width (nWidth -20) height 20 bold centeralign transparent

   @ 35, 10 radiogroup oRadio options aOptions     ;
                       value nOption               ;
                       width nRadWidth spacing 24  ;
                       transparent                 ;
                       on change {|| nOption := oDlgMsgRadio.oRadio.Value}

   @ (nHeight -65), (nWidth -225) button oBtnCancel caption "Cancel" width 100 height 24 ;
                                         action {|| lReturn := .F., oDlgMsgRadio.Release()}

   @ (nHeight -65), (nWidth -115) button oBtnAccept caption "Accept" width 100 height 24 default ;
                                         action {|| lReturn := .T., oDlgMsgRadio.Release()}

   oDlgMsgRadio.oRadio.SetFocus()

   _DefineHotKey("oDlgMsgRadio",,             VK_ESCAPE, {|| oDlgMsgRadio.oBtnCancel.Action()})
   _DefineHotKey("oDlgMsgRadio", MOD_CONTROL, VK_RETURN, {|| oDlgMsgRadio.oBtnAccept.Action()})

end window

oDlgMsgRadio.Activate()

Return (lReturn)
