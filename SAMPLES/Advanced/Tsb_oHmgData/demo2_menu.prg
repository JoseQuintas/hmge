/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2021 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2021 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Меню(кнопки) для таблицы / Menu (buttons) for the table
*/

#include "hmg.ch"
#include "tsbrowse.ch"
///////////////////////////////////////////////////////////////////////////////////
FUNCTION CreateDataMenu()   // меню-кнопки вверху окна
   LOCAL oMenu, nKolvo, nWMenu, aCap, cCap, aDim, nWtxt, nWCap, nFSize, cFont
   LOCAL n2Btn, lBold, i, j, nW, nHMenu

   oMenu := oHmgData()
   oMenu:lDebug    := .T.       // отладка, показ ошибок
   oMenu:nPosWin   := 1         // 1-TopWindow, 2-BottomWindow, 3-LeftWindow, 4-RightWindow
   oMenu:nHAlign   := DT_LEFT   // горизонтальные кнопки: 0-LEFT, 1-CENTER, 2-RIGHT
   oMenu:nVAlign   := DT_TOP    // вертикальные кнопки: 0-TOP , 1-CENTER, 2-BOTTOM
   IF App.Cargo:cLang == "RU"   
      oMenu:aCaption := { "Помощь", "F7 Поиск", "Ins-новая;запись", "Del-удалить;запись", "F5 Печать", "Выход" }
   ELSE
      oMenu:aCaption := { "Help", "F7 Search", "Ins-new;entry", "Del-delete;entry", "F5 Print", "Exit" }
   ENDIF
   oMenu:aCaptMin  := { "Help"  , "F7"      , "Ins"             , "Del"               , "F5"       , "Esc"   }
   oMenu:aBtnPost  := { "_Help" , "_Find"   , "_RecIns"         , "_RecDel"           , "_Print"   , "_Exit" }
   oMenu:aBColor   := { { 40,122,237}    ,;   // 1  Помощь
                        { 33,140,194}    ,;   // 2  Поиск
                        {192, 185, 154}  ,;   // 3  новая запись
                        {192, 185, 154}  ,;   // 4  удалить запись
                        { 94,  59, 185}  ,;   // 5  Печать
                        {189, 30, 73}       } // 6  Выход
   oMenu:lBtnIco   := .T.       // F-кнопки без иконок
   oMenu:aIcon     := { {"iRHelp48x1" ,"iRHelp48x2"  ,.F.,48} ,;   // 1  Помощь
                        {"iFind48x1"  ,"iFind48x2"   ,.F.,48} ,;   // 2  Поиск
                        {"iInsert48x1","iInsert48x2" ,.F.,48} ,;   // 3  новая запись
                        {"iDelete48x1","iDelete48x2" ,.F.,48} ,;   // 4  удалить запись
                        {"iPrint48x1" ,"iPrint48x2"  ,.F.,48} ,;   // 5  Печать
                        {"iExit48x1"  ,"iExit48x2"   ,.F.,48} }    // 6  Выход
   oMenu:nIcoSize  := 48
   oMenu:lTextVert := .T.  // .T.-вертикальный текст для кнопок, .F.- НЕ вертикальный текст
   oMenu:lTextLeft := .T.  // .T.-слева текст для кнопок, .F.-справа
   oMenu:aFont     := { "Comic Sans MS", 13, .T., .F. , 14, "увеличение фонта кнопки" }
   oMenu:aFClr     := { BLACK , YELLOW }
   oMenu:aHelp     := {}
   oMenu:nIndent   := 0                  // отступ первой кнопки  - резерв
   oMenu:nHBtn     := 64                 // высота кнопки
   oMenu:nHBtn     := IIF( App.Cargo:aDisplayMode[2] <= 1024, 64, 72 )
   oMenu:nHBtn     := IIF( App.Cargo:aDisplayMode[2] >= 1100, 96, oMenu:nHBtn )
   oMenu:nWBtn     := 220                // ширина кнопки
   oMenu:nGaps     := 5                  // отступ кнопки от края окна
   oMenu:nGapsBtn  := 10                 // между кнопками по ширине/высоте

   // ширина фонта по надписям
   cFont  := oMenu:aFont[1]
   nFSize := oMenu:aFont[5]
   lBold  := oMenu:aFont[3]
   nWtxt  := 0
   n2Btn  := 0
   aCap   := oMenu:aCaption
   FOR i  := 1 TO LEN(aCap)
      cCap := aCap[ i ]
      IF AT(";",cCap) > 0
         aDim  := HB_ATokens(cCap, ";")
         n2Btn := MAX( n2Btn,LEN(aDim) )
         FOR j := 1 TO LEN(aDim)
            nWCap := GetTxtWidth( aDim[j], nFSize, cFont, lBold )
            nWTxt := MAX(nWTxt,nWCap)
         NEXT
      ELSE
         nWCap := GetTxtWidth(cCap, nFSize, cFont, lBold )
         nWTxt := MAX(nWTxt,nWCap)
      ENDIF
   NEXT
   IF !oMenu:lTextVert      // НЕ вертикальный текст для кнопок
      oMenu:nWBtn := oMenu:nIcoSize + 5 + nWTxt // новая ширина кнопки
   ELSE
      oMenu:nWBtn := nWTxt + 5          // новая ширина кнопки
      // высота кнопки
      IF n2Btn == 0
         oMenu:nHBtn := 48 + 2*2 + nFSize
      ELSE
         oMenu:nHBtn := 48 + 4*2 + nFSize * n2Btn + nFSize*n2Btn/2
      ENDIF
   ENDIF

   // проверим ширину всех кнопок
   nKolvo := LEN(oMenu:aCaption)
   nWMenu := oMenu:nWBtn * nKolvo + oMenu:nGapsBtn * (nKolvo + 1)
   nW     := App.Cargo:aDisplayMode[1] //System.ClientWidth
   IF nWMenu > nW
      oMenu:nWBtn := ( nW - oMenu:nGaps*2 - oMenu:nGapsBtn * nKolvo ) / nKolvo

      nWCap := GetTxtWidth("Help0", nFSize, cFont, lBold )
      oMenu:nWBtn := oMenu:nIcoSize + 5 + nWCap  // новая ширина кнопки
      oMenu:aCaption := oMenu:aCaptMin           // другие подписи кнопок
   ENDIF

   IF oMenu:nPosWin == 1 .OR. oMenu:nPosWin == 2
      // для 1-TopWindow, 2-BottomWindow
      nHMenu         := oMenu:nHBtn + oMenu:nGaps * 2      // высота всего меню
      oMenu:nYMenu   := oMenu:nGapsBtn
      oMenu:nXMenu   := oMenu:nGapsBtn
      oMenu:nHMenu   := nHMenu
      oMenu:nWMenu   := oMenu:nGapsBtn         // отступ от начала формы по X
      oMenu:nHBtnEnd := nHMenu + 600           // ширина последней кнопки на форме
   ELSE
      nHMenu := oMenu:nWBtn * nKolvo + oMenu:nGapsBtn * (nKolvo + 1)
      // для  3-LeftWindow, 4-RightWindow
      //oMenu:nHMenu   := oMenu:nWBtn + oMenu:nGaps * 2      // ширина всего меню
      oMenu:nYMenu   := oMenu:nGapsBtn
      oMenu:nXMenu   := oMenu:nGapsBtn                       // ширина меню
      oMenu:nWMenu   := oMenu:nWBtn + oMenu:nGapsBtn
      oMenu:nWBtnEnd := oMenu:nWMenu + 800    // ширина последней кнопки на форме
      oMenu:nHBtnEnd := nHMenu                // высота последней кнопки на форме
      oMenu:nHMenu   := nHMenu
   ENDIF

RETURN oMenu

////////////////////////////////////////////////////////////////////////////////
FUNCTION DRAW_Menu(oMenu,nWGaps,nHGaps,oThis)   // меню кнопок для таблицы
                             // nWGaps,nHGaps - отступы начала ТСБ
   LOCAL aPos, lDebug, nPosWin, lShow, cErr, nHAlign, nVAlign
   LOCAL nHMenu, aObj, nD1, nD2, nD3, nD4

   aPos   := { 0, 0, 0, 0 }
   lDebug := .F.
   lShow  := .T.
   cErr   := ""
   nD1    := nD2 := nD3 := 0

   IF hb_IsLogical(oMenu:lDebug)
      lDebug := oMenu:lDebug   // отладка, показ ошибок
   ENDIF

   IF hb_IsNumeric(oMenu:nPosWin)
      nPosWin := oMenu:nPosWin
   ELSE
      cErr += "Error ! IsNumeric() ! Not - oMenu:nPosWin := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsNumeric(oMenu:nHAlign)
      nHAlign := oMenu:nHAlign
   ELSE
      cErr += "Error ! IsNumeric() ! Not - oMenu:nHAlign := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsNumeric(oMenu:nVAlign)
      nVAlign := oMenu:nVAlign
   ELSE
      cErr += "Error ! IsNumeric() ! Not - oMenu:nVAlign := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsArray(oMenu:aBtnPost)
      nD1 := LEN(oMenu:aBtnPost)
   ELSE
      cErr += "Error ! IsArray() ! Not - oMenu:aBtnPost := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsArray(oMenu:aCaption)
      nD2 := LEN(oMenu:aCaption)
   ELSE
      cErr += "Error ! IsArray() ! Not - oMenu:aCaption := ??? ;"
      lShow := .F.
   ENDIF

   IF hb_IsArray(oMenu:aBColor)
      nD3 := LEN(oMenu:aBColor)
   ELSE
      cErr += "Error ! IsArray() ! Not - oMenu:aBColor := ??? ;"
      lShow := .F.
   ENDIF

   IF nD1 # nD2 .OR. nD1 # nD3
      cErr += "Error ! Arrays are not equal ! ;;"
      cErr += "        Len(oMenu:aBtnPost) = " + HB_NtoS(nD1) + ";"
      cErr += "        Len(oMenu:aCaption) = " + HB_NtoS(nD2) + ";"
      cErr += "        Len(oMenu:aBColor)  = " + HB_NtoS(nD3) + ";"
      lShow := .F.
   ENDIF

   IF hb_IsLogical(oMenu:lBtnIco)
      IF oMenu:lBtnIco
         IF hb_IsArray(oMenu:aIcon)
            nD4 := LEN(oMenu:aIcon)
            IF nD1 # nD4
               cErr  += "Error ! Len(oMenu:aIcon)  = " + HB_NtoS(nD4) + ";"
               lShow := .F.
            ENDIF
         ELSE
            cErr  += "Error ! IsArray() ! Not - oMenu:aIcon := ??? ;"
            lShow := .F.
         ENDIF
      ENDIF
   ENDIF

   // показ меню без ошибок
   IF lShow
      nHMenu  := IIF( hb_IsNumeric(oMenu:nHMenu), oMenu:nHMenu, 45)  // высота всего меню
      nPosWin := IIF( nPosWin == 0, 1, nPosWin )
      nPosWin := IIF( nPosWin > 4 , 1, nPosWin )
      nPosWin := IIF( nPosWin < 1 , 1, nPosWin )
      IF nPosWin == 1          // TopWindow
         aPos[1] := nHMenu - nHGaps
         aPos[4] := -nHMenu + nHGaps
      ELSEIF nPosWin == 2      // BottomWindow
         aPos[4] := -nHMenu + nHGaps
      ELSEIF nPosWin == 3      // LeftWindow
         aPos[2] := nHMenu - nWGaps
         aPos[3] := -nHMenu + nWGaps
      ELSEIF nPosWin == 4      // RightWindow
         aPos[3] := -nHMenu + nWGaps
      ENDIF

      aObj := Show_Button(oMenu,nWGaps,nHGaps,nPosWin)
      oThis:Cargo:aObjBtn := aObj

   ELSE
      IF lDebug
         cErr += ";;" + ProcNL()
         AlertStop(cErr, "Error !")
         ? ATREPL( ";", cErr, CRLF )
      ENDIF
   ENDIF

RETURN aObj

////////////////////////////////////////////////////////////////////////
FUNCTION Show_Button(oMenu,nX,nY,nPosWin)
   LOCAL cForm, nW, nH, aBtnCap, aBtnIco, aBtnClr, aBtnPst, cCapt
   LOCAL cN, cFont, nFSize, lFBold, nJ, aBtnGrd, aGrOver, aGrFill
   LOCAL aFntClr, nwPost, aBtnObj, aFont, aColor, lItalic, nF2Size
   LOCAL lBtnIco, nGBtn, nWBtn, nHBtn, nIndent, nIcoSize, nOnePos
   LOCAL nHAlign, nVAlign, nY2, nX2, nLenBtn, nWBthAll, nHBthAll
   LOCAL lTextVert, lTextLeft, aIco, nWBtnF7

   aBtnObj := {}
   cForm   := ThisWindow.Name
   nW      := This.ClientWidth
   nH      := This.ClientHeight
   nY2     := nY
   nX2     := nX
   // кнопки
   // горизонтальные кнопки: 0-LEFT, 1-CENTER, 2-RIGHT
   nHAlign  := IIF( hb_IsNumeric(oMenu:nHAlign), oMenu:nHAlign, DT_LEFT )
   // вертикальные кнопки: 0-TOP , 1-CENTER, 2-BOTTOM
   nVAlign  := IIF( hb_IsNumeric(oMenu:nVAlign), oMenu:nVAlign, DT_TOP )
   // Отступ первой кнопки - резерв
   nIndent  := IIF( hb_IsNumeric(oMenu:nIndent), oMenu:nIndent, 0 )
   nWBtn    := oMenu:nWBtn         // ширина кнопки
   nHBtn    := oMenu:nHBtn         // высота кнопки
   nOnePos  := oMenu:nGaps         // отступ кнопки от края окна
   nGBtn    := oMenu:nGapsBtn      // между кнопками по ширине/высоте
   // подсчёт для DT_CENTER
   aBtnCap  := oMenu:aCaption
   nLenBtn  := LEN(aBtnCap)
   nWBthAll := ( nW - nWBtn * nLenBtn - nGBtn * ( nLenBtn - 1 ) ) / 2
   nHBthAll := ( nH - nHBtn * nLenBtn - nGBtn * ( nLenBtn - 1 ) ) / 2

   IF nPosWin = 1                  // TopWindow
      nY := nOnePos
      IF nHAlign == DT_LEFT        // горизонтальные кнопки
      ELSEIF nHAlign == DT_CENTER
         nX := nWBthAll
      ELSEIF nHAlign == DT_RIGHT
         nX := nW - nX2 - nWBtn
      ENDIF
   ELSEIF nPosWin = 2              // BottomWindow
      nY := nH - nHBtn - nOnePos
      IF nHAlign == DT_LEFT        // горизонтальные кнопки
      ELSEIF nHAlign == DT_CENTER
         nX := nWBthAll
      ELSEIF nHAlign == DT_RIGHT
         nX := nW - nX2 - nWBtn
      ENDIF
   ELSEIF nPosWin == 3             // LeftWindow
      nX := nOnePos
      IF nVAlign == DT_TOP         // вертикальные кнопки
      ELSEIF nVAlign == DT_CENTER
         nY := nHBthAll
      ELSEIF nVAlign == DT_BOTTOM
         nY := nH - nY2 - nHBtn
      ENDIF
   ELSEIF nPosWin == 4             // RightWindow
      nX := nW - nWBtn - nOnePos
      IF nVAlign == DT_TOP         // вертикальные кнопки
      ELSEIF nVAlign == DT_CENTER
         nY := nHBthAll
      ELSEIF nVAlign == DT_BOTTOM
         nY := nH - nY2 - nHBtn
      ENDIF
   ENDIF

   IF hb_IsLogical(oMenu:lBtnIco)
      lBtnIco := oMenu:lBtnIco
   ELSE
      lBtnIco := .F.       // F-кнопки без иконок
   ENDIF
   nIcoSize  := oMenu:nIcoSize
   aIco      := IIF( hb_IsArray(oMenu:aIcon), oMenu:aIcon, {} )
   aBtnCap   := oMenu:aCaption
   aBtnIco   := oMenu:aIcon
   aBtnClr   := oMenu:aBColor
   aBtnPst   := oMenu:aBtnPost
   // фонты  для кнопок
   aFntClr   := oMenu:aFClr  //{ BLACK , OLIVE }
   aFont     := oMenu:aFont
   cFont     := aFont[1]     //"Comic Sans MS"
   nFSize    := aFont[2]     //16
   lFBold    := aFont[3]     //.T.
   lItalic   := aFont[4]     //.T.
   nF2Size   := aFont[5]     //32
   // текст для кнопок
   lTextVert := IIF( hb_IsLogical(oMenu:lTextVert), oMenu:lTextVert, .F. )
   lTextLeft := IIF( hb_IsLogical(oMenu:lTextLeft), oMenu:lTextLeft, .F. )
   ? ProcNL(), "###### текст для кнопок ######", "lTextVert=",lTextVert, "lTextLeft=", lTextLeft
   FOR nJ := 1 TO LEN(aBtnCap)
      cCapt   := StrTran( aBtnCap[nJ], ";" , CRLF )
      aColor  := aBtnClr[nJ]
      aBtnGrd := { HMG_RGB2n( aColor ), CLR_WHITE }  // градиент кнопки
      aGrOver := { { 0.5, aBtnGrd[2], aBtnGrd[1] }, { 0.5, aBtnGrd[1], aBtnGrd[2] } }
      aGrFill := { { 0.5, aBtnGrd[1], aBtnGrd[2] }, { 0.5, aBtnGrd[2], aBtnGrd[1] } }
      nwPost  := aBtnPst[nJ]
      IF IsNumeric(nwPost)
         cN := 'Btn_' + HB_NtoS(nwPost) //StrZero(nJ, 2)
      ELSEIF IsString(nwPost)
         cN := 'Btn_' + nwPost //StrZero(nJ, 2)
      ELSE
         AlertStop('Error ! Btn_XX - Событие не "N" или "C' + cValToChar(nwPost) )
      ENDIF
      AADD( aBtnObj, { cN, aBtnCap[nJ], nY, nX, nWBtn, nHBtn, aColor, nwPost, IIF( lBtnIco, aIco[1], Nil ) } )

      IF lBtnIco .AND. LEN(aIco) > 0  // кнопки с иконками
         aIco := aBtnIco[nJ]
      ENDIF

      // alt_syntax
      DEFINE BUTTONEX &cN
         ROW           nY
         COL           nX
         WIDTH         nWBtn
         HEIGHT        nHBtn
         CAPTION       cCapt
         ICON          IIF( lBtnIco, aIco[1], Nil )
         FONTNAME      cFont
         FONTSIZE      nFSize
         FONTCOLOR     aFntClr[1]
         FONTBOLD      .F.
         BACKCOLOR     aGrOver
         GRADIENTFILL  aGrFill
         LEFTTEXT      lTextLeft
         VERTICAL      lTextVert
         FLAT          .T.
         NOHOTLIGHT    .F.
         NOXPSTYLE     .T.
         HANDCURSOR    .T.
         NOTABSTOP     .T.
         ONMOUSEHOVER ( myMouseHL(2) )
         ONMOUSELEAVE ( myMouseHL(1) )
         ACTION ( This.Enabled := .F., _wPost(This.Cargo:nPost, ThisWindow.Name, This.Name) )  // 29.06.23
         //ACTION ( This.Enabled := .F., _wPost(This.Cargo:nPost, This.Index) )
         /*ONINIT {|o|   // можно и так делать
                    This.Cargo := oHmgData()  // создать объект (контейнер) для этой кнопки
                    o := This.Cargo
                    // положим на кнопку нужные данные
                    o:nBtn     := nJ
                    o:nPost    := nwPost
                    o:cCapt    := cCapt
                    o:aIco     := aIco
                    o:aBClr    := aColor
                    o:cObj     := cN
                    o:aGrFill  := aGrFill
                    o:aGrOver  := aGrOver
                    o:aFntClr1 := aFntClr[1]
                    o:aFntClr2 := aFntClr[2]
                    o:lBold2   := .T.
                    o:lBold1   := .F.
                    o:nFSize2  := nF2Size       // увеличенный фонт кнопки
                    o:nFSize   := nFSize        // фонт кнопки
                    o:nIcoSize := nIcoSize      // размер иконки
                    o:aIco     := aIco          // 2 иконки кнопки
                    o:lBtnIco  := lBtnIco       // есть/нет иконка на кнопке
                    Return Nil
                   }          // ON INIT надо задавать только блоком кода */
      END BUTTONEX

      IF AT("F7",cCapt) > 0
         nWBtnF7 := nX
      ENDIF


      This.&(cN).Cargo := oHmgData()
      WITH OBJECT This.&(cN).Cargo
         :nBtn     := nJ
         :nPost    := nwPost
         :cCapt    := cCapt
         :aIco     := aIco
         :aBClr    := aColor
         :cObj     := cN
         :aGrFill  := aGrFill
         :aGrOver  := aGrOver
         :aFntClr1 := aFntClr[1]
         :aFntClr2 := aFntClr[2]
         :lBold2   := .T.
         :lBold1   := .F.
         :nFSize2  := nF2Size       // увеличенный фонт кнопки
         :nFSize   := nFSize        // фонт кнопки
         :nIcoSize := nIcoSize      // размер иконки
         :aIco     := aIco          // 2 иконки кнопки
         :lBtnIco  := lBtnIco       // есть/нет иконка на кнопке
      END WITH

      // сдвиг кнопки
      IF nPosWin = 1 .OR. nPosWin = 2   // TopWindow-BottomWindow
         // горизонтальные кнопки
         IF nHAlign == DT_LEFT .OR. nHAlign == DT_CENTER
            nX += nWBtn + nGBtn
         ELSE
            nX -= ( nWBtn + nGBtn )
         ENDIF
      ELSE                             // LeftWindow-RightWindow
         // вертикальные кнопки
         IF nVAlign == DT_TOP .OR. nVAlign == DT_CENTER
            nY += nHBtn + nGBtn
         ELSE
            nY -= ( nHBtn + nGBtn )
         ENDIF
      ENDIF

      IF lBtnIco .AND. LEN(aIco) > 0  // кнопки с иконками
         // при первом построении изменить размеры иконки
         This.&(cN).ImageWidth  := nIcoSize
         This.&(cN).ImageHeight := nIcoSize
         This.&(cN).Icon        := LoadIconByName( aIco[1], nIcoSize, nIcoSize )
      ENDIF

   NEXT

   oMenu:nWBtnEnd := nX           // последняя кнопка на форме
   oMenu:nWBtnF7  := nWBtnF7      // начало кнопки F7

RETURN aBtnObj

///////////////////////////////////////////////////////////////////
FUNCTION myMouseHL(n)
   LOCAL hIco, o := This.Cargo

   IF n == 2
      This.FontColor    := o:aFntClr2
      This.FontSize     := o:nFSize2
      This.FontBold     := o:lBold2
      This.GradientFill := o:aGrFill
   ELSE
      This.FontColor    := o:aFntClr1
      This.FontSize     := o:nFSize
      This.FontBold     := o:lBold1
      This.GradientOver := o:aGrOver
   ENDIF

   IF o:lBtnIco      // кнопки с иконками
      hIco := LoadIconByName( o:aIco[n], o:nIcoSize, o:nIcoSize )
      This.Icon := hIco
   ENDIF

RETURN NIL

//////////////////////////////////////////////////////////////////////////////////
FUNCTION Draw_Icon(owc)  // иконки на форме
   LOCAL nI, nX, nY, hIcon, cForm, nHIco, cMsg := ""
   LOCAL aIcon := { "iMg1x64", "iMg2x64", "iMg3x64" }

   owc:aIcoLogo    := aIcon  // сохраним для дальнейше работы
   owc:ahIcoLogo   := { 0, 0, 0 }
   owc:aIcoLogoYX  := { 0, 0, 0 }
   owc:nYGaps      := 0           // отступ от начала формы по Y
   owc:nXGaps      := owc:nXGIco  // отступ от начала формы по X -> owc:nXGIco = см. главную форму
   cForm           := owc:cForm
   nHIco           := owc:nHIco
   nX              := owc:nXGaps
   nY              := owc:nYGaps

   FOR nI := 1 TO LEN(aIcon)

      hIcon := LoadIconByName( aIcon[nI], nHIco, nHIco )

      IF hIcon == 0
         cMsg += "Error ! No icon " + aIcon[nI]
         cMsg += " in program resources !;"
      ELSE
         DRAW ICON IN WINDOW &cForm AT nY, nX HICON hIcon ;
               WIDTH nHIco HEIGHT nHIco COLOR This.BackColor
      ENDIF

      owc:ahIcoLogo[nI]  := hIcon
      owc:aIcoLogoYX[nI] := { owc:nYGaps, nX }

      nX += nHIco

   NEXT

   owc:nWIcoEnd := owc:nXGaps + nHIco*3  // последняя координата кнопки

   IF LEN(cMsg) > 0
      AlertStop(cMsg)
   ENDIF

RETURN NIL

/*---------------------------------------------------------------------------
 * MINIGUI - Harbour Win32 GUI library
*/
*----------------------------------------------------------------------------*
STATIC FUNCTION GetTxtWidth( cText, nFontSize, cFontName, lBold )  // получить Width текста
*----------------------------------------------------------------------------*
   LOCAL hFont, nWidth
   DEFAULT cText     := REPL('A', 2)        ,  ;
           cFontName := _HMG_DefaultFontName,  ;   // из MiniGUI.Init()
           nFontSize := _HMG_DefaultFontSize,  ;   // из MiniGUI.Init()
           lBold     := .F.

   IF Valtype(cText) == 'N'
      cText := repl('A', cText)
   ENDIF

   hFont  := InitFont(cFontName, nFontSize, lBold)
   nWidth := GetTextWidth(0, cText, hFont)         // ширина текста
   DeleteObject (hFont)

RETURN nWidth

