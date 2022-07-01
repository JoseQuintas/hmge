/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2021, Verchenko Andrey <verchenkoag@gmail.com>
 * Copyright 2021, Sergej Kiselev <bilance@bilance.lv>
 *
 * Пример построения карточки на базе объекта Tab
 * События на объектах карточки, контейнер на объектах
 * Передача и обработка данных на объектах
 * Запись измененных данных GETBOX'а в файл
 * An example of building a card based on the Tab object
 * Events at card objects, container at objects
 * Transfer and processing of data at objects
 * Writing the changed GETBOX data to a file
*/

#define _HMG_OUTLOG
#include "hmg.ch"

Function Main
   Local nW, /*nH,*/ nG := 20, nWBtn := 150

   SET MSGALERT BACKCOLOR TO { 238, 249, 142 }               // for HMG_Alert()
   DEFINE FONT DlgFont FONTNAME "DejaVu Sans Mono" SIZE 14   // for HMG_Alert()

   //////////
   SET OOP ON
   //////////

   SET FONT TO "Arial", 14

   SET GETBOX FOCUS BACKCOLOR TO {200,255,255}
   SET GETBOX FOCUS FONTCOLOR TO {0  ,0  ,255}

   DEFINE WINDOW Form_1 ;
      AT 0,0 WIDTH 990 HEIGHT 480                      ;
      TITLE 'Harbour MiniGUI Demo: Events on the form + Container' ;
      MAIN                                             ;
      ON SIZE SizeTest(nG)                             ;
      ON RELEASE _wSend(99)

      nW := This.ClientWidth
      //nH := This.ClientHeight

      (This.Object):Cargo := oKeyData()  // создать объект (контейнер) для окна Form_1
      (This.Object):Cargo:nBtn    := 0
      (This.Object):Cargo:nModify := 0

      @ 5, nW - nG*2 - nWBtn*2 BUTTON Btn_Save CAPTION "Save" WIDTH nWBtn HEIGHT 35 ;
        BOLD ACTION { || ThisWindow.Release } ;
        NOTABSTOP

      @ 5, nW - nG - nWBtn BUTTON Btn_Exit CAPTION "Exit" WIDTH nWBtn HEIGHT 35 ;
        BOLD ACTION {|| (ThisWindow.Cargo):nModify := 0 , ThisWindow.Release }  ;
        NOTABSTOP

      SetTab_1(,nG)        // построение Tab / building Tab

      myThisObjectEvent()  // события на объектах формы / events on form objects

      ON KEY ESCAPE ACTION {|| (ThisWindow.Cargo):nModify := 0, ThisWindow.Release }

   END WINDOW

   Form_1.Center
   Form_1.Activate

Return Nil

////////////////////////////////////////////////////////////////////////////////
Function myThisObjectEvent

   (This.Object):Event( 25, {|ow,ky,cn|  // TabPage is changed
      Local cForm  := ow:Name
      Local nPage  := This.&(cn).Value   // номер активной вкладки
      Local aFocus := This.Cargo:aFocusedGetBox
      Local cFocus := aFocus[ nPage ]
      This.Cargo:nFocusedTabPage := nPage
      This.Cargo:cFocusedTabPage := cn
      IF !Empty(cFocus) .and. _IsControlDefined(cFocus, cForm)
         This.&(cFocus).SetFocus
      ENDIF
      ? "Event("+HB_NtoS(ky)+")  TabPage=" , cForm, cn, nPage, "Focused getbox=", cFocus
      Return Nil
     })

   (This.Object):Event( 100, {|ow,ky,cn|    // обработка кнопок типа "I"
      Local oBtn  := This.&(cn).Cargo
      Local nMod  := ow:Cargo:nModify
      Local cForm := ow:Name
      Local aObjName := oBtn:aObjName    // список наименований объектов на строке карточки
      Local cFocus := This.Cargo:cFocusedGetBox
      ? "Event(100) PressButton=" , cn, oBtn:nObjId, oBtn:nBtn, nMod, HB_ValToExp(oBtn:aDim), HB_ValToExp(aObjName)
      myPressButtonI(ky, cForm, cn, oBtn:nObjId, oBtn:nBtn, nMod, oBtn:aDim, aObjName)
      SetProperty(ow:Name, cn, "Enabled", .T.)
      IF !Empty(cFocus) .and. _IsControlDefined(cFocus, cForm)
         This.&(cFocus).SetFocus
      ENDIF
      Return Nil
     })

   (This.Object):Event( 102, {|ow,ky,am|    // обработка menu кнопоки типа "I"
      Local cn := am[1]                     // имя кнопки
      Local nm := am[2]                     // номер пункта menu
      Local oBtn  := This.&(cn).Cargo
      Local nMod  := ow:Cargo:nModify
      Local cForm := ow:Name
      Local aObjName := oBtn:aObjName    // список наименований объектов на строке карточки
      Local cFocus := This.Cargo:cFocusedGetBox
      ? "Event(102) PressButton=" , cn, nm, oBtn:nObjId, oBtn:nBtn, nMod, HB_ValToExp(oBtn:aDim), HB_ValToExp(aObjName)
      MsgDebug("Context menu=",nm,"   :Event=",ky, cForm, cn, nm, oBtn:nObjId, oBtn:nBtn, nMod, oBtn:aDim, aObjName)
      IF !Empty(cFocus) .and. _IsControlDefined(cFocus, cForm)
         This.&(cFocus).SetFocus
      ENDIF
      Return Nil
     })

   (This.Object):Event( 99, {|ow|    // Завершение работы
      Local nMod  := ow:Cargo:nModify
      Local cForm := ow:Name, cGet, lGet
      Local aGet  := HMG_GetFormControls(cForm, "GETBOX")
      Local xOldGet, xNewGet
      ? "Event(99) GETBOX modification=", nMod
      IF nMod > 0
         FOR EACH cGet IN aGet
             lGet    := This.&(cGet).Cargo:lModify
             xOldGet := This.&(cGet).Cargo:xValue
             xNewGet := This.&(cGet).Value
             ? hb_enumindex(cGet), cGet, lGet
             IF !Empty(lGet)
                //?? "Initial value =", xOldGet
                //?? "New value = ", xNewGet
                myChangeGetBox(xOldGet,xNewGet,cGet)
             ENDIF
         NEXT
      ENDIF
      Return Nil
     })

Return Nil

//////////////////////////////////////////////////
Procedure SizeTest(nG)
   Local nW, nH

   nW := This.ClientWidth
   nH := This.ClientHeight

   Form_1.Tab_1.Width  := nW - nG*2
   Form_1.Tab_1.Height := nH - nG*2

Return


#define COLOR_BTNFACE 15

///////////////////////////////////////////////////////////////////////////////
Procedure SetTab_1( lBottomStyle, nG )
   Local nColor := GetSysColor( COLOR_BTNFACE )
   Local aColor := {GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor )}
   Local nI, nW, nH, aTabBC, aTabName, aRet, aDimCard
   Default lBottomStyle := .f.

   IF IsControlDefined(Tab_1, Form_1)
      Form_1.Tab_1.Release
   ENDIF

   nW       := This.ClientWidth
   nH       := This.ClientHeight
   aTabBC   := {159,191,236}

   aRet     := myListTab()         // list of cards for tabs
   aDimCard := aRet[1]
   aTabName := aRet[2]

   This.Cargo:aFocusedGetBox  := array(LEN( aTabName ))
   This.Cargo:cFocusedGetBox  := ""
   This.Cargo:nFocusedTabPage := 1
   This.Cargo:cFocusedTabPage := aTabName[1]

   DEFINE TAB Tab_1                         ;
      OF Form_1                             ;
      AT nG,nG WIDTH nW-nG*2 HEIGHT nH-nG*2 ;
      VALUE 1                               ;
      HOTTRACK                              ;
      BACKCOLOR aTabBC                      ;
      FONT "Tahona" SIZE 16                 ;
      ON CHANGE _wSend(25,,This.Name)

      _HMG_ActiveTabBottom := lBottomStyle

      FOR nI := 1 TO LEN( aTabName )

          PAGE aTabName[ nI ]  TOOLTIP 'Tooltip ' + aTabName[ nI ]

             // Show a list of cards on a tab
             ShowPageCard( nI, aDimCard[ nI ] )

          END PAGE

      NEXT

   END TAB

   Form_1.Tab_1.BACKCOLOR       := aColor
   Form_1.Tab_1.HTFORECOLOR     := BLACK
   Form_1.Tab_1.HTINACTIVECOLOR := GRAY

Return

////////////////////////////////////////////////////////////////////
Function ShowPageCard( nI, aDimLine )
   Local nJ, cObj, nRow, nCol, nWName, cName, nHLine, nWidth
   Local nFSize, nGLine

   nRow   := 20 + 40  // отступ сверху Tab_1
   nCol   := 20
   nHLine := 33      // высота строки в карточке
   nGLine := 20      // расстояние между строками в карточке
   nFSize := 16

   // Определение мах длины по наименованию
   nWName := 0
   FOR nJ := 1 TO LEN( aDimLine )
      cName  := aDimLine[ nJ, 2 ] + ":"
      nWidth := GetTxtWidth( cName, nFSize, "Comic Sans MS" )
      nWName := MAX( nWidth, nWName )
   NEXT

   For nJ := 1 TO LEN( aDimLine )
      cObj  := "Label_Name" + HB_NtoS( nJ ) + "_Page" + HB_NtoS( nI )
      cName := aDimLine[ nJ, 2 ]

      @ nRow, nCol LABEL &cObj VALUE cName + ":" ;
         WIDTH nWName HEIGHT nHLine FONT "Comic Sans MS" SIZE nFSize  ;
         FONTCOLOR BLUE TRANSPARENT RIGHTALIGN VCENTER

      // показать значений полей базы
      myCardFieldGetBox( nI, nJ, cObj, aDimLine[nJ], nRow, nCol + nWName + 5, nHLine, nFSize )

      nRow += nHLine + nGLine

   Next

Return Nil

///////////////////////////////////////////////////////////////////////////////
Function myCardFieldGetBox( nI, nJ, cObj, aDim, nRow, nCol, nHLine, nFSize )
   Local cFName := _HMG_DefaultFontName
   Local cTypeLine, xPole, nK, xDopType, /*xDopRun, cRowCardAccess,*/ xRet
   Local aField, cField, cAType, cObjGbx, aDimObjAI, nWCol, nWBtn, nHBtn
   Local cBtnFontI, nBtnFSizeI, cBtnCaptI, nWidth, cMsg
   Local cObjGbxA, nObjId
   Local aFocus := ThisWindow.Cargo:aFocusedGetBox

   cTypeLine      := aDim[1]   // тип построения строки А-массив, CDN-обычный, M-мемополе и т.д.
   xPole          := aDim[3]   // поля базы данных или А-массив
   xDopType       := aDim[4]   // доп.обработка построения поля базы данных
   //xDopRun        := aDim[5]   // вызов функции для кнопки или нет вызова
   //cRowCardAccess := IIF( LEN(aDim) == 6, aDim[6], "?" ) // доступ юзера к строке карточки
                                                         // можно сделать проверку на доступ
   nWBtn := nHBtn := nHLine     // ширина и высота кнопки
   cBtnFontI      := "Wingdings"
   nBtnFSizeI     := nFSize + 6
   cBtnCaptI      := CHR(40)
   cObjGbx        := cObj + "_Gbox"

   IF cTypeLine == "A"

      nWCol     := 0                    // смещение по строке карточки
      aField    := xPole                // список полей - {"RC_abon" ,"?","RC_abon0","?"}
      aDimObjAI := ARRAY( LEN(aField) ) // для типа A - список наименований объектов
                                        // выведенных в этой стоке - передать на кнопку
      FOR nK := 1 TO LEN(aField)

         cField        := ALLTRIM(aField[nK])
         cAType        := xDopType[nK]
         cObjGbxA      := cObj + "_A" + cAType + "_" + HB_NtoS(nK)
         aDimObjAI[nK] := cObjGbxA
         nObjId          := nI*1000 + nJ*100 + nK

         IF cAType == "D" .OR. cAType == "C"  .OR. cAType == "N"

            xRet    := "ALIAS()->" + cField       // FIELDGET(FIELDNUM(cField))
            nWidth  := GetTxtWidth( xRet, nFSize, cFName ) + 10

            @ nRow , nCol + nWCol GETBOX &cObjGbxA VALUE xRet  ;
              WIDTH nWidth HEIGHT nHLine ;
              PICTURE "@K" ;
              ON CHANGE {|| ;
                        _logfile(.t., "  -> Modify:",This.Name, This.Cargo:lModify, ThisWindow.Cargo:nModify), ;
                        (ThisWindow.Cargo):nModify += 1, ;
                        This.Cargo:lModify := .T., ;
                        _logfile(.t., "  -> Modify:",This.Name, This.Cargo:lModify, ThisWindow.Cargo:nModify) } ;
              ON GOTFOCUS {|| ThisWindow.Cargo:aFocusedGetBox[ This.Cargo:nPage ] := This.Name, ;
                              ThisWindow.Cargo:cFocusedGetBox := This.Name } ;
              ON INIT     {|| This.Cargo := oKeyData()  ,;       // создать объект (контейнер) для этого объекта
                              This.Cargo:lModify := .F. ,;
                              This.Cargo:nPage   := nI, ;
                              This.Cargo:xValue  := This.Value } // первоначальное значение GetBox

            IF Empty(aFocus[ nI ])    // GetBox в фокусе
               aFocus[ nI ] := cObjGbxA
            ENDIF

         ELSEIF cAType == "I"

            (This.Cargo):nBtn := nK

            @ nRow, nCol + nWCol BUTTONEX &cObjGbxA WIDTH nWBtn HEIGHT nHBtn ;
              CAPTION cBtnCaptI FONT cBtnFontI SIZE nBtnFSizeI  NOTABSTOP    ;
              NOXPSTYLE HANDCURSOR FONTCOLOR BLACK BACKCOLOR ORANGE          ;
              ACTION  {|| This.Enabled := .F., _wPost(100, , This.Name) }    ;
              ON INIT {|| This.Cargo := oKeyData()  ,;       // создать объект (контейнер) для этой кнопки
                          This.Cargo:nObjId  := nObjId  ,;
                          This.Cargo:nBtn  := (ThisWindow.Cargo):nBtn,;
                          This.Cargo:aDim  := aDim  ,;
                          This.Cargo:nPage := nI, ;
                          This.Cargo:aObjName := aDimObjAI } // ON INIT надо задавать только блоком кода

            DEFINE CONTEXT MENU CONTROL &cObjGbxA
               MENUITEM "Context menu (1) this Button = "+cObjGbxA ACTION _wPost(102, , {cObjGbxA, 1})
               MENUITEM "Context menu (2) this Button = "+cObjGbxA ACTION _wPost(102, , {cObjGbxA, 2})
            END MENU

            nWidth := nWBtn

         ELSE
            cMsg := "Error! No handling type ["+cAType+"] !;" + HB_ValToExp(aDim)
            cMsg += ";;" + ProcNL(0)
            cMsg := AtRepl( ";", cMsg, CRLF )
            MsgStop( cMsg )
         ENDIF

         nWCol += nWidth + 2

         IF nK % 2 = 0
            nWCol += 20
         ENDIF

      NEXT


   ELSEIF cTypeLine == "C" .OR. cTypeLine == "D"

      xRet    := "ALIAS()->" + xPole
      nWidth  := GetTxtWidth( xRet, nFSize, cFName ) + 10

      @ nRow , nCol GETBOX &cObjGbx VALUE xRet  ;
         WIDTH nWidth HEIGHT nHLine ;
         PICTURE "@K" ;
         ON CHANGE {|| ;
                        _logfile(.t., "  -> Modify:", This.Name, This.Cargo:lModify, ThisWindow.Cargo:nModify), ;
                        (ThisWindow.Cargo):nModify += 1, ;
                        This.Cargo:lModify := .T., ;
                        _logfile(.t., "  -> Modify:", This.Name, This.Cargo:lModify, ThisWindow.Cargo:nModify) } ;
         ON GOTFOCUS {|| ThisWindow.Cargo:aFocusedGetBox[ This.Cargo:nPage ] := This.Name, ;
                         ThisWindow.Cargo:cFocusedGetBox := This.Name } ;
         ON INIT     {|| This.Cargo := oKeyData()  ,;        // создать объект (контейнер) для этого объекта
                         This.Cargo:lModify := .F. ,;
                         This.Cargo:nPage   := nI, ;
                         This.Cargo:xValue  := This.Value }  // первоначальное значение GetBox

      IF Empty(aFocus[ nI ])    // GetBox в фокусе
         aFocus[ nI ] := cObjGbx
      ENDIF
   ELSE
      cMsg := "Error! No handling type ["+cTypeLine+"] !;" + HB_ValToExp(aDim)
      cMsg += ";;" + ProcNL(0)
      cMsg := AtRepl( ";", cMsg, CRLF )
      MsgStop( cMsg )
   ENDIF

Return Nil

////////////////////////////////////////////////////////////////////////////////////
// запись в журнал изменений GETBOX / writing to the GETBOX change log
Function myChangeGetBox(xOld,xNew,cObj)

    IF VALTYPE(xOld) == "C"
       xOld := ALLTRIM(xOld)
       xNew := ALLTRIM(xNew)
    ENDIF
    IF xOld == xNew
       // пропуск записи в журнал
    ELSE
       ?? "Change Getbox:" + cObj + ", [" + xOld + "] # [" + xNew + "]"
    ENDIF

Return Nil

////////////////////////////////////////////////////////////////////////////////////
Function myPressButtonI(nEvent, cForm, cObj, nObjId, nBtn, nMod, aDim, aObjNameLine)
   Local cMsg, cRun, cTtl, cBlock, aFunc, aParam, cRet, aFld, cField, cObjRt

   cTtl   := "nEvent = " + hb_NtoS(nEvent) + ";"
   cTtl   += "cForm  = " + cForm + ";"
   cTtl   += "cObj   = " + cObj + ";"
   cTtl   += "Button code   in line :nObjId = " + hb_NtoS(nObjId) + ";"
   cTtl   += "Button number in line :nBtn   = " + hb_NtoS(nBtn)   + ";"
   cTtl   += "(This.Object):Cargo:nModify   = " + hb_NtoS(nMod)   + ";"
   cTtl   += "Card string array passed: aDim= " + hb_ValToExp(aDim) + ";"
   cTtl   += "The name of the constructed objects of this card line:;"
   cTtl   += hb_ValToExp(aObjNameLine)
   aFunc  := aDim[5]
   aFld   := aDim[3]
   cRun   := aFunc[nBtn]
   cField := aFld[nBtn-1]
   cObjRt := aObjNameLine[nBtn-1]

   IF !hb_IsFunction( cRun )
       cMsg := "Functions  " + cRun + "() not in the EXE file!;"
       cMsg += "call -" + hb_ValToExp(aDim) + ";"
       cMsg := AtRepl( ";", cMsg, CRLF )
       MsgStop( cMsg, "Stop!")
   ELSE
      cTtl   := AtRepl( ";", cTtl, CRLF )
      aParam := { cTtl, cField, cObjRt, nBtn, aDim }
      cBlock := cRun + "(" + hb_ValToExp(aParam) + ")"
      cRet   := Eval( hb_macroBlock( cBlock ) )
      IF LEN(cRet) > 0
         SetProperty(cForm, cObjRt, "Value", cRet)
      ENDIF
   ENDIF

Return Nil

//////////////////////////////////////////////////////////////////////////
Function BtnTestRC(aPar)
   Local cTtl, cFld, aDim, aClr, nI, nRet, cRet, aBtn, cMsg, /*nBtn,*/ cObj
   Default aPar := {}

   cTtl := aPar[1]
   cFld := aPar[2]
   cObj := aPar[3]
   //nBtn := aPar[4]
   aDim := aPar[5]
   aClr := { YELLOW, RED, GREEN, ORANGE }
   aBtn := {}
   cRet := ""

   FOR nI := 1 TO 4
      AADD(aBtn, "0"+hb_ntoS(nI)+"00000"+hb_ntoS(nI) )
   NEXT

   cMsg  := cTtl + ";;"
   cMsg  += "Select the desired value for the entry!;"
   cMsg  += "Выберите нужное значение для записи !;"
   cMsg  += "Запись в поле: " + cFld + " и объект: " + cObj

   nRet  := HMG_Alert( cMsg, aBtn, aDim[2], NIL, NIL, NIL, aClr, NIL )
   IF nRet > 0
      cRet := aBtn[nRet]
   ENDIF

Return cRet

//////////////////////////////////////////////////////////////////
Function myListTab()
   Local i, aTabName, aDim, aRetDim := {}

   // TabPage 1
   aDim := {}
   AADD( aDim, { "A", "Personal account  / Personal account-2", {"RC_abon"  ,"?","RC_abon0","?"} , {"C","I","C","I"}, {NIL,"BtnTestRC",NIL,"BtnTestRC" } , "2Card:(RC+RC0)" } )
   AADD( aDim, { "A", "Personal account-3/ Personal account-4", {"RC_abon3" ,"?","RC_abon4","?"} , {"C","I","C","I"}, {NIL,"BtnTestRC",NIL,"BtnTestRC" } , "2Card:(RC34)"   } )
   AADD( aDim, { "C", "Name of the subscriber"                , "FIO"                            , nil              , nil                                , ""               } )
   AADD( aRetDim, aDim )

   // TabPage 2
   aDim := {}
   AADD( aDim, { "D", "Date of Birth"                         , "DBirth"                         , nil              , nil                                   , ""               } )
   AADD( aRetDim, aDim )

   // TabPage 3
   aDim := {}
   For i := 1 To 5
      AADD( aDim, { "C", "Example of row "+hb_NtoS(i)+" of tab 3", "CTEXT_"+hb_NtoS(i)          , nil              , nil                                   , ""               } )
   Next
   AADD( aDim, { "A", "Example of an event on a button", {"TEST22" ,"?"} , {"C","I"}, {NIL,"MyTest22"} , "3Card:Test22"   } )
   AADD( aRetDim, aDim )

   aTabName := { "TabPage-1", "TabPage-2","TabPage-3" }

Return { aRetDim, aTabName }

///////////////////////////////////////////////////////////////////////////////
FUNCTION GetTxtWidth( cText, nFontSize, cFontName, lBold )  // получить Width текста
   Local hFont, nWidth
   Default cText     := REPL('A', 2)
   Default cFontName := _HMG_DefaultFontName   // из MiniGUI.Init()
   Default nFontSize := _HMG_DefaultFontSize   // из MiniGUI.Init()
   Default lBold     := .F.

   IF Valtype(cText) == 'N'
      cText := repl('A', cText)
   ENDIF

   hFont  := InitFont(cFontName, nFontSize, lBold)
   nWidth := GetTextWidth(0, cText, hFont)         // ширина текста
   DeleteObject (hFont)

RETURN nWidth

//////////////////////////////////////////////////
FUNCTION ProcNL(nVal)
   Default nVal := 0
RETURN "Call from: " + ProcName(nVal+1) + "(" + hb_ntos(ProcLine(nVal+1)) + ") --> " + ProcFile(nVal+1)

