/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Работа с меню / Working with the menu
*/

#define _HMG_OUTLOG
#include "minigui.ch"

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION Menu_Find(oWnd,ky,cn,oBrw)                  // F7 - поиск / Документы
   LOCAL aMenu, nY, nX, nI, cForm, aBtnObj, aBtn2

   ? ProcNL(), oWnd,ky,cn,oBrw
   cForm   := oWnd:Name
   aBtnObj := oWnd:Cargo:aBtnObj     // массив кнопок на форме
   aBtn2   := aBtnObj[2]

   This.&(cn).Enabled := .F.         // для вызова по клавише F5

   aMenu := {}
   IF App.Cargo:cLang == "RU"
      AADD( aMenu, {"iEdit64x2", "(1) Ввод № документа оплаты" } )           // 1
      AADD( aMenu, {"iEdit64x1", "(2) Переключиться на ввод"   } )           // 2
      AADD( aMenu, {"", ""                                     } )
      AADD( aMenu, {"iFind48x1", "Все записи в базе"           } )           // 4
      AADD( aMenu, {"", ""                                     } )
      AADD( aMenu, {"iFind48x1", "Показ удалённых записей"     } )           // 6
      AADD( aMenu, {"", ""                                     } )
      AADD( aMenu, {"iFind48x1", "Список по № документов по всей базе" } )   // 8
      //  1      2          3             4      5   6    7    8
   ELSE
      AADD( aMenu, {"iEdit64x2", "(1) Enter payment document number" } ) // 1
      AADD( aMenu, {"iEdit64x1", "(2) Switch to input" } ) // 2
      AADD( aMenu, {"", "" } )
      AADD( aMenu, {"iFind48x1", "All records in the database" } ) // 4
      AADD( aMenu, {"", "" } )
      AADD( aMenu, {"iFind48x1", "Show deleted records" } ) // 6
      AADD( aMenu, {"", "" } )
      AADD( aMenu, {"iFind48x1", "List by document number throughout the entire database" } ) // 8
   ENDIF
   // {2, "_Find", "-имя объекта", "Документы", 0, 141, 131, 69, "_Find", "-событие"}
   nY := GetProperty(cForm, cn, "Row") + aBtn2[5] + aBtn2[8] + 2
   nX := GetProperty(cForm, cn, "Col") + aBtn2[6] - 5
   nI := myContextMenu(aMenu, nY, nX, "Icon")  // "Bmp"

   IF nI == 1
      Menu_NewDocum(oWnd,oBrw)
   ELSEIF nI == 2
      Menu_Input(oWnd,oBrw)          // Переключиться на ввод
   ELSEIF nI == 4
      Menu_ViewAllRecno(oWnd,oBrw)   // Все записи в базе
   ELSEIF nI == 6
      Menu_ViewDelete(oWnd,oBrw)     // Показ удалённых записей
   ELSEIF nI == 8
      Menu_ViewList(oWnd,oBrw)       // Список по № документов
   ENDIF
   mySayIndex()                      // текущий индекс

   This.&(cn).Enabled := .T.         // для вызова по клавише F5

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Menu_NewDocum(oWnd,oBrw)        // Ввод № документа оплаты
   LOCAL cRet, cDat, cEnd, lBottom, cAls, nLen, cMsk, cTitle

   ? ProcNL(), oWnd:Classname, oBrw:Classname
   //          VVV - зададим такую переменную
   oWnd:Cargo:cText2 := ALLTRIM(oBrw:Cargo:cMaska)
   cAls := oBrw:cAlias

   myGetNumDoc( oWnd )   // см. внизу
   cRet := ALLTRIM(oWnd:Cargo:cText2)
   IF LEN(cRet) > 0
      myMenuButton2SuperHd(.F.,oWnd,oBrw)
      // работа с базой
      dbSelectArea(cAls)
      SET DELETED ON
      // сортировка в таблице по этому индексу
      OrdSetFocus("DOCDTV")      // индекс "маска ввода за день"
      DbGotop()
      // без этого индекс слетает
      oBrw:uLastTag := (cAls)->( ordName( INDEXORD() ) )
      nLen := LEN( (oBrw:cAlias)->DOCUM )                 // кол-во символов поля DOCUM
      cMsk := UPPER(PADR(cRet,nLen))                      // № док.оплаты
      oBrw:Cargo:cScopeDat       := HB_ANSITOOEM(cMsk)    // запомнить SCOPE
      oBrw:Cargo:cMaska          := cMsk                  // запомнить maska
      App.Cargo:oIni:MAIN:cMaska := cRet                  // запомним МАСКУ ввода для ини-файла
      App.Cargo:lIniChange := .T.                         // изменена переменная для ини-файла

      cDat    := cEnd := HB_ANSITOOEM(cMsk)               // условие отбора
      lBottom := .F.                                      // Scope first
      oBrw:ScopeRec(cDat, cEnd, lBottom)
      ? ProcNL(), "----- SCOPE ----", "["+cDat+"]", LEN(cEnd), lBottom
      // без этого индекс слетает
      //oBrw:uLastTag := (oBrw:cAlias)->( ordName( INDEXORD() ) )
      ? ProcNL(), "oBrw:Cargo:cMaska=","["+oBrw:Cargo:cMaska+"]", LEN(oBrw:Cargo:cMaska)
      cTitle := TitleSuperHider(cRet)
      oBrw:Cargo:TitleSupHd := cTitle                    // запомнить НОВЫЙ
      oBrw:SetColor( {16}, { oBrw:Cargo:ColorSupHd } )   // 16, фона спецхидер
      oBrw:DrawHeaders()                                 // перечитать суперхидер/шапку/нумератор
      _wSend("_ItogGet",oWnd)         // итого по базе
  ENDIF

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Menu_Input(oWnd,oBrw)        // Переключиться на ввод
   LOCAL cAls, cDat, cEnd, lBottom

   cAls := oBrw:cAlias

   myMenuButton2SuperHd(.F.,oWnd,oBrw)
   // работа с базой
   dbSelectArea(cAls)
   SET DELETED ON
   // переключение индекса
   OrdSetFocus("DOCDTV")
   DbGotop()
   // без этого индекс слетает
   oBrw:uLastTag := (cAls)->( ordName( INDEXORD() ) )
   cDat := cEnd := oBrw:Cargo:cScopeDat    // предыдущее условие отбора
   lBottom := .F.                          // Scope first
   oBrw:ScopeRec(cDat, cEnd, lBottom)
   oBrw:Reset()
   oBrw:Refresh()
   oBrw:GoTop()
   _wSend("_ItogGet",oWnd)         // итого по базе

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Menu_ViewAllRecno(oWnd,oBrw)      // Все записи в базе
   LOCAL cAls, cTitle, cDat, cEnd, lBottom

   cAls   := oBrw:cAlias
   IF App.Cargo:cLang == "RU"
      cTitle := "Выборка: ВСЕ записи в базе !"
   ELSE
      cTitle := "Selection: ALL records in the database!"
   ENDIF
   myMenuButton2SuperHd(.T.,oWnd,oBrw,cTitle,oBrw:Cargo:nClr16All)
   // работа с базой
   dbSelectArea(cAls)
   SET DELETED OFF
   OrdSetFocus("ALL")
   SET SCOPE TO
   DbGotop()
   // без этого индекс слетает
   oBrw:uLastTag := (cAls)->( ordName( INDEXORD() ) )
   cDat := cEnd := Nil
   lBottom := .F.                      // Scope first
   oBrw:ScopeRec(cDat, cEnd, lBottom)
   oBrw:Reset()
   //oBrw:Refresh(.T., .T.)
   // обязательно перечитать состояние вертикального скролинга - не надо
   //oBrw:ResetVScroll( .T. )
   //oBrw:oHScroll:SetRange( 0, 0 )
   oBrw:GoTop()
   _wSend("_ItogGet",oWnd)         // итого по базе

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Menu_ViewDelete(oWnd,oBrw)      // Показ удалённых записей
   LOCAL cAls, cTitle

   cAls   := oBrw:cAlias
   IF App.Cargo:cLang == "RU"
      cTitle := "Выборка: ВСЕ УДАЛЁННЫЕ записи ручного ввода операторов !"
   ELSE
      cTitle := "Selection: ALL DELETED records of manual entry of operators!"
   ENDIF
   myMenuButton2SuperHd(.T.,oWnd,oBrw,cTitle,oBrw:Cargo:nClr16Del)
   // работа с базой
   dbSelectArea(cAls)
   SET DELETED OFF
   OrdSetFocus("DEL")
   SET SCOPE TO
   dbGotop()
   // без этого индекс слетает
   oBrw:uLastTag := (cAls)->( ordName( INDEXORD() ) )
   oBrw:Reset()
   oBrw:GoTop()
   _wSend("_ItogGet",oWnd)         // итого по базе

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Menu_ViewList(oWnd,oBrw)  // Список по № документов по всей базе
   LOCAL cAls, cTitle, aRet, cMaska, cScope
   LOCAL cDat, cEnd, lBottom

   cAls    := oBrw:cAlias
   IF App.Cargo:cLang == "RU"
      cTitle  := "Выборка: Список по № документов по всей базе !"
   ELSE
      cTitle := "Selection: List by document number throughout the entire database!"
   ENDIF
   lBottom := .F.
   myMenuButton2SuperHd(.T.,oWnd,oBrw,cTitle,oBrw:Cargo:nClr16Del)

   SET WINDOW THIS TO oWnd

   aRet := Report_1(oWnd,oBrw)    // -> demo_menu_find.prg

   SET WINDOW THIS TO

   IF LEN(aRet) > 0
      cMaska := aRet[1]
      cScope := aRet[2]
      IF App.Cargo:cLang == "RU"
         cTitle := "Выборка: No документа оплаты = " + ALLTRIM(cMaska) 
      ELSE
         cTitle := "Selection: Payment document No. = " + ALLTRIM(cMaska)
      ENDIF
      myMenuButton2SuperHd(.T.,oWnd,oBrw,cTitle,oBrw:Cargo:nClr16New)
      // работа с базой
      dbSelectArea(cAls)
      SET DELETED ON
      // переключение индекса
      OrdSetFocus("DOCDTV")
      DbGotop()
      // без этого индекс слетает
      oBrw:uLastTag := (cAls)->( ordName( INDEXORD() ) )
      cDat := cEnd := cScope               // условие отбора
      oBrw:ScopeRec(cDat, cEnd, lBottom)
      oBrw:Reset()
      oBrw:Refresh()
      oBrw:GoTop()
   ELSE
      cDat := cEnd := oBrw:Cargo:cScopeDat    // предыдущее условие отбора
      oBrw:ScopeRec(cDat, cEnd, lBottom)
      oBrw:Reset()
      oBrw:Refresh()
      oBrw:GoTop()
   ENDIF
   _wSend("_ItogGet",oWnd)         // итого по базе

   DO EVENTS

RETURN NIL

///////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myMenuButton2SuperHd(lOff,oWnd,oBrw,cTitle,aBClrSH)
   LOCAL cForm, aBtnObj, cObj3, cObj4

   //? ProcNL(), lOff,oWnd,oBrw
   oBrw:Cargo:lRecINS := lOff          // блокировка клавиши INS
   oBrw:Cargo:lRecDEL := lOff          // блокировка клавиши DEL

   cForm := oWnd:Name
   aBtnObj := oWnd:Cargo:aBtnObj      // кнопки вверху формы
   //?v aBtnObj
   // {3, "_RecIns", "-имя объекта", "Новая запись", 0, 282, 131, 69, "_RecIns", "-событие"}
   // {4, "_RecDel", "-имя объекта", "Удалить запись", 0, 423, 131, 69, "_RecDel", "-событие"}
   cObj3 := aBtnObj[3,2]
   cObj4 := aBtnObj[4,2]
   IF lOff
      SetProperty(cForm, cObj3, "Enabled", .F.)
      SetProperty(cForm, cObj4, "Enabled", .F.)
      //  блокировать правку колонок
      //AEval(oBrw:aColumns, {|oc,ni| oBrw:GetColumn(ni):lEdit := .F. })
      AEval(oBrw:aColumns, {|oc| oc:lEdit := .F. })
      // замена в таблице суперхидеоа
      cTitle := TitleSuperHider(cTitle,.F.)
      oBrw:aSuperhead[ 1, 3 ] := cTitle                 // новый суперхидер
      oBrw:SetColor( {16}, { aBClrSH } )                // 16, фона спецхидер
      oBrw:DrawHeaders()                                // перечитать суперхидер/шапку/нумератор
   ELSE
      SetProperty(cForm, cObj3, "Enabled", .T.)
      SetProperty(cForm, cObj4, "Enabled", .T.)
      //  восстановить какие колонки можно редактировать
      AEval(oBrw:aColumns, {|oc,ni| oc:lEdit := oBrw:Cargo:aEditOriginal[ni] })
      //FOR EACH oCol IN oBrw:aColumns
      //   nI := hb_EnumIndex(oCol)
      //   oCol:lEdit := oBrw:Cargo:aEditOriginal[nI]
      //NEXT
      // замена в таблице суперхидеоа
      oBrw:aSuperhead[ 1, 3 ] := oBrw:Cargo:TitleSupHd   // восстановить
      oBrw:SetColor( {16}, { oBrw:Cargo:ColorSupHd } )   // 16, фона спецхидер
      oBrw:DrawHeaders()                                 // перечитать суперхидер/шапку/нумератор
   ENDIF

RETURN NIL


////////////////////////////////////////////////////////////////
STATIC FUNCTION myGetNumDoc( oWnd )
   LOCAL cMsg, cTtl, bInit, aBack

   SET MSGALERT BACKCOLOR TO oWnd:Cargo:aBColor STOREIN aBack
   SET MSGALERT FONTCOLOR TO YELLOW

   bInit := {||
      Local cMsg, oDlu, aFont, cFont, nSize
      Local y, x, w, h

      aFont := GetFontParam("DlgFont")
      cFont := aFont[1]
      nSize := aFont[2]
      oDlu  := oDlu4Font(nSize)
      x     := oDlu:Left
      w     := oDlu:W1   // oDlu:W(1.5)  // oDlu:W2  // задаем размер по width для Label
      h     := oDlu:H1 + 6
      y     := This.Say_01.Row + This.Say_01.Height + 2 //oDlu:Top

      This.Topmost := .F.
      IF !HB_ISOBJECT( This.Cargo ) ; This.Cargo := oHmgData()
      ENDIF
      This.Cargo:lClose := .F.
      This.Cargo:o2Wnd  := oWnd:Cargo
      This.OnInterActiveClose := {|| This.Cargo:lClose }    // обязательно !!!
      oWnd:Cargo:cGetValue := "+"

      //@ y,x LABEL Lbl_1 WIDTH oDlu:W1 HEIGHT oDlu:H1 FONT "DlgFont" ;
      //      VALUE '№:' VCENTERALIGN FONTCOLOR WHITE TRANSPARENT
      //  x += This.Lbl_1.Width + oDlu:GapsWidth

      @ y,x TEXTBOX Get_1 WIDTH This.ClientWidth - x * 2 HEIGHT h ;
            VALUE oWnd:Cargo:cText2 FONT "DlgFont" MAXLENGTH 60
        y += This.Get_1.Height + 2 //oDlu:GapsHeight
        x := oDlu:Left

      IF App.Cargo:cLang == "RU"
         cMsg := "Это будет новый № документа оплаты !"
      ELSE
         cMsg := "This will be the new payment document number!"
      ENDIF
      @ y,x LABEL Lbl_2 WIDTH This.ClientWidth - x * 2 HEIGHT h-2 FONT "Comic Sans MS";
        SIZE nSize-1  VALUE cMsg VCENTERALIGN CENTERALIGN FONTCOLOR WHITE TRANSPARENT
        x += This.Lbl_2.Width + oDlu:GapsWidth
      //@ y,x TEXTBOX Get_2 WIDTH This.ClientWidth - x - oDlu:Left HEIGHT h ;
      //                    VALUE "Get Value 2" FONT "DlgFont" MAXLENGTH 30
        y := This.Btn_01.Row + oDlu:Top * 2 + oDlu:GapsHeight
        This.Btn_01.Row := y
        This.Btn_02.Row := y
        This.Height := This.Height + oDlu:Top * 2
        This.Btn_01.Action := {|| _wPost(99,, This.Get_1.Value) }
        This.Btn_02.Action := {|| _wPost(99) }
        This.Get_1.SetFocus
        _PushKey( VK_END )
        (This.Object):Event(99, {|ow,ky,cv|
                      ? ProcNL(), ow:Name,ky,cv
                      IF !Empty(cv)
                         //o2Crg:cGetValue := cv
                         oWnd:Cargo:cGetValue := cv
                         //MsgBox("Get_1 = "+ ky:cGetValue + CRLF + ;
                         //       "Text2 = "+ ky:cText2, "Press OK")
                      ELSE
                         oWnd:Cargo:cGetValue := ""
                      ENDIF
                      DO EVENTS
                      ow:Cargo:lClose := .T.
                      ow:Release()
                      Return Nil
                      })
      Return Nil
     }

   IF App.Cargo:cLang == "RU"
      cMsg := "Ввод № документа оплаты:"
      cTtl := "Замена"
   ELSE
      cMsg := "Input payment document number:"
      cTtl := "Replacement"
   ENDIF
   AlertOKCancel( cMsg + SPACE(20), cTtl, , "iEdit64x2", 64, { LGREEN, RED }, .T., bInit )

   oWnd:Cargo:cText2 := oWnd:Cargo:cGetValue
   //MsgDebug(oWnd:Cargo:cText2)

   SET MSGALERT BACKCOLOR TO aBack[1]
   SET MSGALERT FONTCOLOR TO aBack[2]

RETURN Nil
