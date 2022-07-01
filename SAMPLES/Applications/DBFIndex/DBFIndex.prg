/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2020 Gilbert Vaillancourt <gilbert.vaillancourt.gv@gmail.com>
 *                Quebec, Canada
 */

#include "MiniGUI.ch"

#define CLR_GETBACK  {{255,255,255}, {255,248,220}, {224,238,224}}

#define J_LEFT       0
#define J_RIGHT      1
#define J_CENTER     2

#define INITMSG      1
#define UPDTMSG      2
#define EXITMSG      3

//-----------------------------------------------------------------------------

static scWorkPath
static slNew

static saDBF := {}
static saFLD := {}
static saNDX := {}
static saKEY := {}

//-----------------------------------------------------------------------------

declare window oWndDBFIndex
declare window oDlgProcess

//-----------------------------------------------------------------------------

procedure Main (cPath)
local nRow
local nCol
local bBackColor := {|| iif(This.CellRowIndex %2 == 0, {255, 255, 255}, {255,255,224})}

request DBFCDX, DBFFPT

set multiple OFF WARNING
set deleted ON
set softseek OFF
set autopen OFF
set language to ENGLISH
set date format "dd/mm/yyyy"
set navigation EXTENDED
set century ON
set epoch to Year(Date())
set tooltip ON
set tooltipballoon ON
set default icon to "DBFINDEX"

_BeginIni(GetStartUpFolder() +"\DBFINDEX.INI")
nRow := Val(_GetIni("COORD", "ROW", "0"))
nCol := Val(_GetIni("COORD", "COL", "0"))
_EndIni()
if CountMonitors() == 1
   nRow := 0
   nCol := 0
endif

scWorkPath := iif(cPath == NIL, GetCurrentFolder(), cPath)
slNew      := .F.

define window oWndDBFIndex                                         ;
       at nRow, nCol                                               ;
       width 930 height 750                                        ;
       title "DBF Index Manager"                                   ;
       main nosize nomaximize                                      ;
       on init {|| FetchDBF(), FetchFLD(), FetchNDX(), FetchKey()} ;
       on interactiveclose {|| Quit()}

   define toolbar oTlbMain buttonsize 64, 64 flat border

      button oBtnExit picture "EXIT" ;
      caption "Exit"                 ;
      tooltip "Exit Application"     ;
      action  {|| Quit()}            ;
      separator

   end toolbar

   @  80,  10 label oLblPath width 120 height 20 value "Work folder :" bold
   @ 100,  10 getbox oGetPath                                                                     ;
              width 420  height 25                                                                ;
              value scWorkPath                                                                    ;
              backcolor CLR_GETBACK                                                               ;
              image  "FOLDER"                                                                     ;
              buttonwidth 25                                                                      ;
              on lostfocus {|| scWorkPath := This.Value}                                          ;
              notabstop                                                                           ;
              action {|| scWorkPath := BrowseForFolder("Select files location", This.Value,,.T.), ;
                         This.Value := iif(!Empty(scWorkPath), scWorkPath, This.Value),           ;
                         SetCurrentFolder(scWorkPath),                                            ;
                         FetchDBF(), FetchFLD(), FetchNDX(), FetchKEY(),                          ;
                         UpdtControl(), oWndDBFIndex.oGrdDBF.SetFocus()}

   @ 130,  10 label oLblDBF width 120 height 20 value "Databases :" bold
   @ 150,  10 grid oGrdDBF                                                                  ;
              width 390  height 275                                                         ;
              items saDBF                                                                   ;
              headers {"DBF Name",  "Size",  "Date",  "Time", "Records"}                    ;
              widths  {        90,      80,      75,      60,        65}                    ;
              justify {    J_LEFT, J_RIGHT, J_RIGHT, J_RIGHT,   J_RIGHT}                    ;
              value 1                                                                       ;
              dynamicbackcolor {bBackColor, bBackColor, bBackColor, bBackColor, bBackColor} ;
              on change {|| FetchFLD(), FetchNDX(), FetchKey(), UpdtControl()}

   @ 130, 410 label oLblFLD width 120 height 20 value "Fields :" bold
   @ 150, 410 grid oGrdFLD                                                      ;
              width 240  height 275                                             ;
              items saFLD                                                       ;
              headers {"Field Name",  "Type",  "Size",   "Dec"}                 ;
              widths  {          95,      40,      45,      40}                 ;
              justify {      J_LEFT, J_RIGHT, J_RIGHT, J_RIGHT}                 ;
              value 1                                                           ;
              dynamicbackcolor {bBackColor, bBackColor, bBackColor, bBackColor} ;
              on dblclick {|| AssignKey(0), UpdtControl()}

   @  80, 660 label oLblNDXName width 120 height 20 value "Index Name :" bold
   @ 100, 660 getbox oGetNDXName    ;
              width 120  height 24  ;
              value Space(8)        ;
              picture "@!"          ;
              backcolor CLR_GETBACK ;
              notabstop             ;
              on lostfocus {|| oWndDBFIndex.oGrdFLD.SetFocus()}

   @ 100, 790 buttonex oBtnClearAll                                ;
              width 120 height 24                                  ;
              caption "Clear All Keys"                             ;
              picture "CLRKEYS"                                    ;
              notabstop                                            ;
              action {|| oWndDBFIndex.oGetKey1.Value := Space(30), ;
                         oWndDBFIndex.oGetKey2.Value := Space(30), ;
                         oWndDBFIndex.oGetKey3.Value := Space(30), ;
                         oWndDBFIndex.oGetKey4.Value := Space(30), ;
                         oWndDBFIndex.oGetKey5.Value := Space(30), ;
                         UpdtControl(),                            ;
                         oWndDBFIndex.oGrdFLD.SetFocus()}

   @ 150, 660 label oLblKey1 width 120 height 20 value "Index Key 1" bold
   @ 165, 660 getbox oGetKey1       ;
              width 205 height 24   ;
              value Space(30)       ;
              backcolor CLR_GETBACK ;
              readonly notabstop

   @ 165, 870 buttonex oBtnKey1                                    ;
              width 40 height 24                                   ;
              caption "Clear"                                      ;
              notabstop                                            ;
              action {|| oWndDBFIndex.oGetKey1.Value := Space(30), ;
                         UpdtControl()}

   @ 195, 660 label oLblKey2 width 120 height 20 value "Index Key 2" bold
   @ 210, 660 getbox oGetKey2       ;
              width 205 height 24   ;
              value Space(30)       ;
              backcolor CLR_GETBACK ;
              readonly notabstop

   @ 210, 870 buttonex oBtnKey2                                    ;
              width 40 height 24                                   ;
              caption "Clear"                                      ;
              notabstop                                            ;
              action {|| oWndDBFIndex.oGetKey2.Value := Space(30), ;
                         UpdtControl()}

   @ 240, 660 label oLblKey3 width 120 height 20 value "Index Key 3" bold
   @ 255, 660 getbox oGetKey3       ;
              width 205 height 24   ;
              value Space(30)       ;
              backcolor CLR_GETBACK ;
              readonly notabstop

   @ 255, 870 buttonex oBtnKey3                                    ;
              width 40 height 24                                   ;
              caption "Clear"                                      ;
              notabstop                                            ;
              action {|| oWndDBFIndex.oGetKey3.Value := Space(30), ;
                         UpdtControl()}

   @ 285, 660 label oLblKey4 width 120 height 20 value "Index Key 4" bold
   @ 300, 660 getbox oGetKey4       ;
              width 205 height 24   ;
              value Space(30)       ;
              backcolor CLR_GETBACK ;
              readonly notabstop

   @ 300, 870 buttonex oBtnKey4                                    ;
              width 40 height 24                                   ;
              caption "Clear"                                      ;
              notabstop                                            ;
              action {|| oWndDBFIndex.oGetKey4.Value := Space(30), ;
                         UpdtControl()}

   @ 330, 660 label oLblKey5 width 120 height 20 value "Index Key 5" bold
   @ 345, 660 getbox oGetKey5       ;
              width 205 height 24   ;
              value Space(30)       ;
              backcolor CLR_GETBACK ;
              readonly notabstop

   @ 345, 870 buttonex oBtnKey5                                    ;
              width 40 height 24                                   ;
              caption "Clear"                                      ;
              notabstop                                            ;
              action {|| oWndDBFIndex.oGetKey5.Value := Space(30), ;
                         UpdtControl()}

   @ 385, 660 buttonex oBtnIndex       ;
              width 250 height 40      ;
              caption "Generate Index" ;
              picture "INDEX"          ;
              notabstop                ;
              action {|| BuildIndex(), FetchNDX(), FetchKEY()}

   @ 450,  10 label oLblNDX width 120 height 20 value "Indexes :" bold
   @ 470,  10 grid oGrdNDX                                                                  ;
              width 900  height 185                                                         ;
              items saNDX                                                                   ;
              headers {"CDX Name",  "Index Key",  "Size",  "Date",  "Time"}                 ;
              widths  {        80,          610,      70,      75,      60}                 ;
              justify {    J_LEFT,       J_LEFT, J_RIGHT, J_RIGHT, J_RIGHT}                 ;
              value 1                                                                       ;
              dynamicbackcolor {bBackColor, bBackColor, bBackColor, bBackColor, bBackColor} ;
              on change {|| FetchKey(), UpdtControl()}

   @ 665,  10 buttonex oBtnNewNDX                        ;
              width 100 height 40                        ;
              caption "Create Index"+ CRLF + "(Alt+Ins)" ;
              notabstop                                  ;
              action {|| oWndDBFIndex.oBtnIndex.Enabled := .T., NewKey()}

   @ 665, 120 buttonex oBtnDelNDX                        ;
              width 100 height 40                        ;
              caption "Delete Index"+ CRLF + "(Alt+Del)" ;
              notabstop                                  ;
              action {|| oWndDBFIndex.oBtnIndex.Enabled := .F., DelKey()}

   _DefineHotKey("oWndDBFIndex", MOD_ALT, VK_X, {|| Quit()})
   _DefineHotKey("oWndDBFIndex", MOD_ALT, VK_INSERT, {|| NewKey()})
   _DefineHotKey("oWndDBFIndex", MOD_ALT, VK_DELETE, {|| DelKey()})
   _DefineHotKey("oWndDBFIndex", MOD_CONTROL + MOD_ALT, VK_HOME, {|| ResetCoord()})
   _DefineHotKey("oWndDBFIndex",, VK_F1, {|| MsgInfo("HotKey Ctrl+Alt+Home to recenter application")})

end window


UpdtControl()
oWndDBFIndex.oGetPath.SetFocus()

if nRow == 0 .and. nCol == 0
   oWndDBFIndex.Center()
endif
oWndDBFIndex.Activate()

Return

//-----------------------------------------------------------------------------

function UpdtControl ()

if (Empty(oWndDBFIndex.oGetKey1.Value) .and. ;
    Empty(oWndDBFIndex.oGetKey2.Value) .and. ;
    Empty(oWndDBFIndex.oGetKey3.Value) .and. ;
    Empty(oWndDBFIndex.oGetKey4.Value) .and. ;
    Empty(oWndDBFIndex.oGetKey5.Value))
       oWndDBFIndex.oBtnIndex.Enabled := .F.
else
       oWndDBFIndex.oBtnIndex.Enabled := .T.
endif

Return (NIL)

//-----------------------------------------------------------------------------

function Quit ()

if CountMonitors() > 1
   _BeginIni(GetStartUpFolder() +"\DBFINDEX.INI")
   _SetIni("COORD", "ROW", AllTrim(Str(ThisWindow.Row)))
   _SetIni("COORD", "COL", AllTrim(Str(ThisWindow.Col)))
   _EndIni()
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

function FetchDBF()
local z

saDBF := Directory("*.DBF")
if Len(saDBF) == 0
   saDBF := {{"", "", "", "", ""}}
else
   for z = 1 to Len(saDBF)
      dbUseArea(.T., "DBFCDX", AllTrim(saDBF[z, 1]), "DATABASE", .F.)
      if NetErr()
         saDBF[z, 1] := ""
         loop
      endif
      saDBF[z, 1] := Upper(Token(saDBF[z, 1], ".", 1))
      saDBF[z, 2] := Transform(saDBF[z, 2], "99999999")
      saDBF[z, 3] := DtoC(saDBF[z, 3])
      saDBF[z, 5] := Transform(DATABASE->(LastRec()), "999999")
      DATABASE->(dbCloseArea())
   next z
endif

oWndDBFIndex.oGrdDBF.DeleteAllItems()
for z = 1 to Len(saDBF)
   if Empty(saDBF[z, 1])
      loop
   endif
   oWndDBFIndex.oGrdDBF.AddItem({saDBF[z, 1], saDBF[z, 2], saDBF[z, 3], saDBF[z, 4], saDBF[z, 5]})
next z
oWndDBFIndex.oGrdDBF.Value := 1
oWndDBFIndex.oGrdDBF.Refresh()

Return (NIL)

//-----------------------------------------------------------------------------

function FetchFLD ()
local z
local cDBFFile

cDBFFile := oWndDBFIndex.oGrdDBF.Cell(oWndDBFIndex.oGrdDBF.Value, 1)
if Empty(cDBFFile)
   Return (NIL)
endif

dbUseArea(.T., "DBFCDX", cDBFFile, "DATABASE", .F., .F.)
saFLD := DATABASE->(dbStruct())
DATABASE->(dbCloseArea())
for z = 1 to Len(saFLD)
   saFLD[z, 3] := Transform(saFLD[z, 3], "9999")
   saFLD[z, 4] := Transform(saFLD[z, 4], "9999")
next z

oWndDBFIndex.oGrdFLD.DeleteAllItems()
for z = 1 to Len(saFLD)
   oWndDBFIndex.oGrdFLD.AddItem({saFLD[z, 1], saFLD[z, 2], saFLD[z, 3], saFLD[z, 4]})
next z
oWndDBFIndex.oGrdFLD.Value := 1
oWndDBFIndex.oGrdFLD.Refresh()

Return (NIL)

//-----------------------------------------------------------------------------

function FetchNDX ()
local z
local aNDXFile
local nHandle
local cString
local cOrdkey
local cDBFFile

saNDX := {}
cDBFFile := oWndDBFIndex.oGrdDBF.Cell(oWndDBFIndex.oGrdDBF.Value, 1)
aNDXFile := Directory("*.CDX")
if Len(aNDXFile) == 0
   saNDX := {{"", "", "", "", ""}}
else
   for z = 1 to Len(aNDXFile)
      nHandle := FOpen(AllTrim(aNDXFile[z, 1]), 0)
      FSeek(nHandle, 2048, 0)
      cString := AllTrim(FReadStr(nHandle, 255))
      FClose(nHandle)
      if Empty(cString) .or. !cDBFFile $ cString
         loop
      endif
      cOrdKey := AllTrim(cString)
      if Empty(cOrdKey)
         loop
      endif
      AAdd(saNDX, {Upper(Token(aNDXFile[z, 1], ".", 1)), ;
                   cOrdKey,                              ;
                   Transform(aNDXFile[z, 2], "9999999"), ;
                   DtoC(aNDXFile[z, 3]),                 ;
                   aNDXFile[z, 4]})
   next z
endif
oWndDBFIndex.oGrdNDX.DeleteAllItems()
for z = 1 to Len(saNDX)
   oWndDBFIndex.oGrdNDX.AddItem({saNDX[z, 1], saNDX[z, 2], saNDX[z, 3], saNDX[z, 4], saNDX[z, 5]})
next z
oWndDBFIndex.oGrdNDX.Value := 1
oWndDBFIndex.oGrdNDX.Refresh()

Return (NIL)

//-----------------------------------------------------------------------------

function FetchKey ()
local z
local cKey
local nCount

oWndDBFIndex.oGetKey1.Value := Space(30)
oWndDBFIndex.oGetKey2.Value := Space(30)
oWndDBFIndex.oGetKey3.Value := Space(30)
oWndDBFIndex.oGetKey4.Value := Space(30)
oWndDBFIndex.oGetKey5.Value := Space(30)
if Len(saNDX) == 0
   Return (NIL)
endif

cKey     := oWndDBFIndex.oGrdNDX.Cell(oWndDBFIndex.oGrdNDX.Value, 2)
nCount   := Occurs("+", cKey) +1

oWndDBFIndex.oGetNDXName.Value := oWndDBFIndex.oGrdNDX.Cell(oWndDBFIndex.oGrdNDX.Value, 1)

for z = 1 to nCount
   do case
   case z == 1
      oWndDBFIndex.oGetKey1.Value := AllTrim(Token(cKey, "+", z))
   case z == 2
      oWndDBFIndex.oGetKey2.Value := AllTrim(Token(cKey, "+", z))
   case z == 3
      oWndDBFIndex.oGetKey3.Value := AllTrim(Token(cKey, "+", z))
   case z == 4
      oWndDBFIndex.oGetKey4.Value := AllTrim(Token(cKey, "+", z))
   case z == 5
      oWndDBFIndex.oGetKey5.Value := AllTrim(Token(cKey, "+", z))
   endcase
next z

Return (NIL)

//-----------------------------------------------------------------------------

function AssignKey (nAction)
local cDBFFile := oWndDBFIndex.oGrdDBF.Cell(oWndDBFIndex.oGrdDBF.Value, 1)
local cKey     := oWndDBFIndex.oGrdFLD.Cell(oWndDBFIndex.oGrdFLD.Value, 1)
local cType    := oWndDBFIndex.oGrdFLD.Cell(oWndDBFIndex.oGrdFLD.Value, 2)
local cLen     := oWndDBFIndex.oGrdFLD.Cell(oWndDBFIndex.oGrdFLD.Value, 3)
local cDec     := oWndDBFIndex.oGrdFLD.Cell(oWndDBFIndex.oGrdFLD.Value, 4)
local cString

if nAction > 0 .and. ThisWindow.FocusedControl <> "oGrdFLD"
   MsgInfo("You must select a FieldName in the 'Fields' section "+ CRLF + ;
           "in order to use the shortcup keys !", "Error")
   Return (NIL)
endif

do case
case cType == "C"
   cString := AllTrim(cDBFFile) +"->"+ Lower(allTrim(cKey))
case cType == "N"
   cString := "Str("+ AllTrim(cDBFFile) +"->"+ Lower(AllTrim(cKey)) +", "+ AllTrim(cLen) +", "+ AllTrim(cDec) +")"
case cType == "D"
   cString := "DtoS("+ AllTrim(cDBFFile) +"->"+ Lower(AllTrim(cKey)) +")"
case cType == "L"
   cString := "LtoC("+ AllTrim(cDBFFile) +"->"+ Lower(AllTrim(cKey)) +")"
case cType == "M"
   MsgInfo("Cannot index on a Memo field !", "Error")
   oWndDBFIndex.oGrdFLD.SetFocus()
   Return (NIL)
endcase

do case
case Empty(oWndDBFIndex.oGetKey1.Value) .and. nAction == 0
   oWndDBFIndex.oGetKey1.Value := cString
case Empty(oWndDBFIndex.oGetKey2.Value) .and. nAction == 0
   oWndDBFIndex.oGetKey2.Value := cString
case Empty(oWndDBFIndex.oGetKey3.Value) .and. nAction == 0
   oWndDBFIndex.oGetKey3.Value := cString
case Empty(oWndDBFIndex.oGetKey4.Value) .and. nAction == 0
   oWndDBFIndex.oGetKey4.Value := cString
case Empty(oWndDBFIndex.oGetKey5.Value) .and. nAction == 0
   oWndDBFIndex.oGetKey5.Value := cString
case nAction == 1
   if !Empty(oWndDBFIndex.oGetKey1.Value)
      if MsgYesNo("Key value is not empty."+ CRLF +"Do you wish to remplace it ?", "Index Key")
         oWndDBFIndex.oGetKey1.Value := cString
      endif
   else
      oWndDBFIndex.oGetKey1.Value := cString
   endif
case nAction == 2
   if !Empty(oWndDBFIndex.oGetKey2.Value)
      if MsgYesNo("Key value is not empty."+ CRLF +"Do you wish to remplace it ?", "Index Key")
         oWndDBFIndex.oGetKey2.Value := cString
      endif
   else
      oWndDBFIndex.oGetKey2.Value := cString
   endif
case nAction == 3
   if !Empty(oWndDBFIndex.oGetKey3.Value)
      if MsgYesNo("Key value is not empty."+ CRLF +"Do you wish to remplace it ?", "Index Key")
         oWndDBFIndex.oGetKey3.Value := cString
      endif
   else
      oWndDBFIndex.oGetKey3.Value := cString
   endif
case nAction == 4
   if !Empty(oWndDBFIndex.oGetKey4.Value)
      if MsgYesNo("Key value is not empty."+ CRLF +"Do you wish to remplace it ?", "Index Key")
         oWndDBFIndex.oGetKey4.Value := cString
      endif
   else
      oWndDBFIndex.oGetKey4.Value := cString
   endif
case nAction == 5
   if !Empty(oWndDBFIndex.oGetKey5.Value) 
      if MsgYesNo("Key value is not empty."+ CRLF +"Do you wish to remplace it ?", "Index Key")
         oWndDBFIndex.oGetKey5.Value := cString
      endif
   else
      oWndDBFIndex.oGetKey5.Value := cString
   endif
otherwise
   MsgInfo("A maximum of 5 keys can be selected !", "Error")
   oWndDBFIndex.oGrdFLD.SetFocus()
   Return (NIL)
endcase

oWndDBFIndex.oGrdFLD.SetFocus()

Return (NIL)

//-----------------------------------------------------------------------------

function NewKey ()

if oWndDBFIndex.oGrdNDX.ItemCount == 10
   MsgInfo("Cannot create more than 10 Index file !", "Error")
   Return (NIL)
endif
oWndDBFIndex.oGetNDXName.Value := Space(8)
oWndDBFIndex.oGetKey1.Value := Space(30)
oWndDBFIndex.oGetKey2.Value := Space(30)
oWndDBFIndex.oGetKey3.Value := Space(30)
oWndDBFIndex.oGetKey4.Value := Space(30)
oWndDBFIndex.oGetKey5.Value := Space(30)

oWndDBFIndex.oGetNDXName.SetFocus()
slNew := .T.

Return (NIL)

//-----------------------------------------------------------------------------

function DelKey ()
local nValue := oWndDBFIndex.oGrdNDX.Value

// MsgInfo(oWndDBFIndex.oGrdNDX.Cell(nValue, 1))
if MsgYesNo("Do you realy wish to delete this Index file ?"+ CRLF + ;
            Space(15) +"« "+ oWndDBFIndex.oGrdNDX.Cell(nValue, 1) +".CDX »", "Delete Index")
   FileDelete(oWndDBFIndex.oGrdNDX.Cell(nValue, 1) +".CDX")
   oWndDBFIndex.oGrdNDX.DeleteItem(nValue)
   if oWndDBFIndex.oGrdNDX.Value < nValue
      nValue := oWndDBFIndex.oGrdNDX.Value
   endif
   oWndDBFIndex.oGrdNDX.Value := nValue
   FetchKey()
   oWndDBFIndex.oGrdNDX.SetFocus()
   oWndDBFIndex.oGrdNDX.Refresh()
endif

Return (NIL)

//-----------------------------------------------------------------------------

function BuildIndex ()
local cMessage := ""
local cDBFName := AllTrim(oWndDBFIndex.oGrdDBF.Cell(oWndDBFIndex.oGrdDBF.Value, 1))
local cNDXName := AllTrim(oWndDBFIndex.oGetNDXName.Value)
local cOrdKey  := ""
local nInterval

do case
case Empty(cDBFName)
   cMessage := "Database name is empty !"
case Empty(cNDXName)
   cMessage := "Index name is empty !"
endcase
if !Empty(cMessage)
   MsgInfo(cMessage, "Error")
   Return (NIL)
endif

if !slNew
   FileDelete(oWndDBFIndex.oGrdNDX.Cell(oWndDBFIndex.oGrdNDX.Value, 1) +".CDX")
endif

if !Empty(oWndDBFIndex.oGetKey1.Value)
   cOrdKey += AllTrim(oWndDBFIndex.oGetKey1.Value)
endif
if !Empty(oWndDBFIndex.oGetKey2.Value)
   cOrdKey += " + "+ AllTrim(oWndDBFIndex.oGetKey2.Value)
endif
if !Empty(oWndDBFIndex.oGetKey3.Value)
   cOrdKey += " + "+ AllTrim(oWndDBFIndex.oGetKey3.Value)
endif
if !Empty(oWndDBFIndex.oGetKey4.Value)
   cOrdKey += " + "+ AllTrim(oWndDBFIndex.oGetKey4.Value)
endif
if !Empty(oWndDBFIndex.oGetKey5.Value)
   cOrdKey += " + "+ AllTrim(oWndDBFIndex.oGetKey5.Value)
endif
if Empty(cOrdKey)
   MsgInfo("Index key is empty !", "Error")
   Return (NIL)
endif

dbUseArea(.T., "DBFCDX", cDBFName,, .F., .F.)
nInterval := NdxProgress(1,, cDBFName, cNDXName)
OrdCondSet(,,,, {|| NdxProgress()}, nInterval)
OrdCreate(cNDXName,, cOrdKey)
NdxProgress(3)
dbCloseAll()
slNew := .F.
MsgInfo("Index created")

Return (NIL)

//-----------------------------------------------------------------------------

function NdxProgress (nAction, cHeader, cDatabase, cIndex, nRecords)
local nRow
local nCol
static snCount

nAction := iif(nAction == NIL, 0, nAction)

do case
case nAction == 0       // DISPLAY PROGRESSION
   ++snCount
   oDlgProcess.oProgress.Value := (snCount *2)
   InKeyGUI(25)

case nAction == 1       // INIT DIALOG
   cHeader   := iif(cHeader  == NIL, "Restructuration en cours...", AllTrim(cHeader))
   cDatabase := iif(cDatabase == NIL, "", AllTrim(cDatabase))
   cIndex    := iif(cIndex == NIL, "", AllTrim(cIndex))
   nRecords  := iif(nRecords == NIL, LastRec(), nRecords)
   snCount   := 0

   nRow := ThisWindow.Row + Int(ThisWindow.Height /2) - Int(100 /2)
   nCol := ThisWindow.Col + Int(ThisWindow.Width /2) - Int(400 /2)

   define window oDlgProcess    ;
          at nRow, nCol         ;
          width 400  height 100 ;
          title cHeader         ;
          modal nosysmenu nosize

      @  5,  50 label oLabel1 value "Fichier : " width 50 height 20
      @  5, 110 label oLblDBF value cDatabase width 200 height 20 bold
      @ 20,  50 label oLabel2 value "  Index : " width 50 height 20
      @ 20, 110 label oLblNDX value cIndex width 200 height 20 bold
      @ 40,  50 progressbar oProgress  range 0, 100  width 300  height 24  smooth

   end window
   oDlgProcess.oProgress.Value := 0
   
   activate window oDlgProcess nowait

   Return (Int(Max(1, nRecords /100)))

case nAction == 2       // UPDATE DIALOG
   cHeader   := iif(cHeader  == NIL, "Restructuration en cours...", AllTrim(cHeader))
   cDatabase := iif(cDatabase == NIL, "", AllTrim(cDatabase))
   cIndex    := iif(cIndex == NIL, "", AllTrim(cIndex))
   nRecords  := iif(nRecords == NIL, LastRec(), nRecords)
   snCount   := 0
   oDlgProcess.Title           := cHeader
   oDlgProcess.oLblDBF.Value   := cDatabase
   oDlgProcess.oLblNDX.Value   := cIndex
   oDlgProcess.oProgress.Value := 0
   Return (Int(Max(1, nRecords /100)))

case nAction == 3       // REMOVE DIALOG
   oDlgProcess.Release()

endcase
DoEvents()

Return (.T.)

//-----------------------------------------------------------------------------

function BrowseForFolder (cTitle, cInitPath, nStyle, lCenter)
local nFlag

do case
case nStyle == 1   // BFF_SD
   nFlag := 5
case nStyle == 2   // BFF_SF
   nFlag := 16388
case nStyle == 3   // BFF_CD
   nFlag := 64
case nStyle == 4   // BFF_CDSF
   nFlag := 16448
endcase

Return (HB_BrowseForFolder(NIL, cTitle, nFlag, NIL, cInitPath, lCenter))




//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//  HARBOUR CODE
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>
#include <shlobj.h>
#include "hbapiitm.h"
#include "hbvm.h"

static BOOL s_bCntrDialog = FALSE;

//-----------------------------------------------------------------------------

void CenterDialog( HWND hwnd )
{
   RECT  rect;
   int   w, h, x, y;

   GetWindowRect( hwnd, &rect );
   w = rect.right - rect.left;
   h = rect.bottom - rect.top;
   x = GetSystemMetrics( SM_CXSCREEN );
   y = GetSystemMetrics( SM_CYSCREEN );
   MoveWindow( hwnd, (x - w) / 2, (y - h) / 2, w, h, TRUE );
}

int CALLBACK BrowseCallbackProc( HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM lpData )
{
   TCHAR szPath[MAX_PATH];
   switch( uMsg )
   {
      case BFFM_INITIALIZED:  if( lpData ){ SendMessage( hWnd, BFFM_SETSELECTION, TRUE, lpData ); if( s_bCntrDialog ) CenterDialog( hWnd );} break;
      case BFFM_SELCHANGED:   SHGetPathFromIDList( (LPITEMIDLIST) lParam, szPath ); SendMessage( hWnd, BFFM_SETSTATUSTEXT, NULL, (LPARAM) szPath ); break;
      case BFFM_VALIDATEFAILED:  MessageBeep( MB_ICONHAND ); SendMessage( hWnd, BFFM_SETSTATUSTEXT, NULL, (LPARAM) "Bad Directory" ); return 1;
   }

   return 0;
}

//-----------------------------------------------------------------------------

HB_FUNC( HB_BROWSEFORFOLDER )  // Syntax: HB_BROWSEFORFOLDER([<hWnd>],[<cTitle>],<nFlags>,[<nFolderType>],[<cInitPath>],[<lCenter>])
{
   HWND           hWnd = HB_ISNIL(1) ? GetActiveWindow() : ( HWND ) hb_parnl( 1 );
   BROWSEINFO     BrowseInfo;
   char           *lpBuffer = ( char * ) hb_xgrab( MAX_PATH + 1 );
   LPITEMIDLIST   pidlBrowse;

   SHGetSpecialFolderLocation( hWnd, HB_ISNIL(4) ? CSIDL_DRIVES : hb_parni(4), &pidlBrowse );

   BrowseInfo.hwndOwner = hWnd;
   BrowseInfo.pidlRoot = pidlBrowse;
   BrowseInfo.pszDisplayName = lpBuffer;
   BrowseInfo.lpszTitle = HB_ISNIL(2) ? "Select a Folder" : hb_parc( 2 );
   BrowseInfo.ulFlags = hb_parni(3);
   BrowseInfo.lpfn = BrowseCallbackProc;
   BrowseInfo.lParam = HB_ISCHAR(5) ? (LPARAM) (char *) hb_parc( 5 ) : 0;
   BrowseInfo.iImage = 0;

   s_bCntrDialog = HB_ISNIL(6) ? FALSE : hb_parl( 6 );

   pidlBrowse = SHBrowseForFolder( &BrowseInfo );

   if( pidlBrowse )
   {
      SHGetPathFromIDList( pidlBrowse, lpBuffer );
      hb_retc( lpBuffer );
   }
   else
   {
      hb_retc( "" );
   }

   hb_xfree( lpBuffer );
}

#pragma ENDDUMP

