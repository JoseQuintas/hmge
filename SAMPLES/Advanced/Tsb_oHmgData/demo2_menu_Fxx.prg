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

STATIC nStatChoice
/////////////////////////////////////////////////////////////////////////////////////////
FUNCTION Menu_Find(oWnd,ky,cn,oBrw)
   LOCAL nY, nX, nI, nJ, cForm, Font1, Font2, Font3, cTitle, cAls, cRet, cMsk
   LOCAL cDat, cEnd, lBottom, aMenu1, aMenu2, aList1, aList2, aScop1, aScop2, nLen
   LOCAL cMsg, aMonth, aIMnth, a12Doc, a12Scp, nMnth, aScp, aMenu, cMenu, cScop

   ? ProcNL(), oWnd:ClassName,ky,cn,oBrw:ClassName

   cMsg  := ""
   cForm := oWnd:Name            // имя окна
   This.&(cn).Enabled := .F.
   //MsgDebug(oWnd:Name,ky,cn,ob:cAlias)
   Font1  := GetFontHandle( "ComSanMS" )
   Font2  := GetFontHandle( "Bold"     )
   Font3  := GetFontHandle( "ItalBold" )
   aList1 := oWnd:Cargo:aList1   // список руч.ввода по всей базе
   aList2 := oWnd:Cargo:aList2   // список док. по месяцам года + ручной ввод оператора
   IF !IsArray(aList1)
      cMsg += "ERROR ! No array aList1[] !;"
   ENDIF
   IF !IsArray(aList2)
      cMsg += "ERROR ! No array aList2[] !;"
   ENDIF
   IF LEN(cMsg) > 0
      AlertStop(cMsg + ProcNL())
      RETURN NIL
   ENDIF

   aMenu1 := aList1[1]
   aScop1 := aList1[2]
   // вложенное меню
   aMenu2 := aList2[1]
   aScop2 := aList2[2]
   // месяца года
   aIMnth := aList2[3]
   cRet   := ""
   aMonth := {}
   a12Doc := ARRAY(LEN(aIMnth))
   a12Scp := ARRAY(LEN(aIMnth))
   FOR nMnth := 1 TO LEN(aIMnth)
      nJ    := aIMnth[nMnth]
      cMenu := NtoCMONTH(nJ)
      AADD( aMonth , cMenu )    // месяца присутствующие в базе
      a12Doc[nMnth] := {}
      a12Scp[nMnth] := {}
      cRet += HB_NtoS(nJ) + " - " + cMenu + ";"
      FOR nI := 1 TO LEN(aMenu2)
         IF nJ == aMenu2[nI,2]                // номер месяца 
            AADD( a12Doc[nMnth], aMenu2[nI,1] )  // номер документа
            AADD( a12Scp[nMnth], aScop2[nI,1] )  // scope
         ENDIF
      NEXT
   NEXT
   //AlertInfo(cRet + ";" + ProcNL())
   
   cAls  := oBrw:cAlias
   // координаты вывода окна
   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nY    += GetProperty(cForm, cn, "Row") + GetProperty(cForm, cn, "Height") + 5
   nX    := GetProperty(cForm, "Col") + GetBorderWidth()
   nX    += GetProperty(cForm, cn, "Col") //+ GetProperty(cForm, cn, "Width")

   SET MENUSTYLE EXTENDED     // переключить стиль меню на расширенный
   SetMenuBitmapHeight( 32 )  // установить размер иконок 32х32

   nI := nJ := 0
   nStatChoice := -2              // обязательно, первоначальное значение
   DEFINE CONTEXT MENU OF &cForm
      IF App.Cargo:cLang == "RU"
         Popup "Список: № документов по всей базе" NAME mGroup1 IMAGE "bFind32" FONT Font1 // Level 2
           Item "Отчёт по № документов" ACTION {|| nStatChoice := 1 } ICON "iFind48x1"  FONT Font1
            //a2MenuItem(aMenu1,"1",Font1)
         End Popup
         SEPARATOR
         Popup "Список: Ручной ввод по месяцам" NAME mGroup2 IMAGE "bFind32" FONT Font1 // Level 2
            //a2MenuItem(aMenu2,"2",Font1)
            FOR nMnth := 1 TO LEN(aMonth)
               POPUP aMonth[nMnth] IMAGE "bFind32" FONT Font3
                  a2MenuItem(a12Doc[nMnth],"2"+STRZERO(nMnth,2),Font1)
               END POPUP
            NEXT
         End Popup
         SEPARATOR
         Item "Показ удалённых записей" ACTION {|| nStatChoice := 3 } ICON "iFind48x1"  FONT Font1
         SEPARATOR
         Item "Все записи в базе "      ACTION {|| nStatChoice := 4 } ICON "iFind48x1"  FONT Font2
         SEPARATOR
         Item "(1): Ввод № документа оплаты" ACTION {|| nStatChoice := 5 } ICON "iEdit64x2"  FONT Font1
         Item "(2): Переключиться на ввод"   ACTION {|| nStatChoice := 6 } ICON "iEdit64x1"  FONT Font1
      ELSE
         Popup "List: № of documents throughout the entire database" NAME mGroup1 IMAGE "bFind32" FONT Font1 // Level 2
           Item "Report by document number" ACTION {|| nStatChoice := 1 } ICON "iFind48x1" FONT Font1
            //a2MenuItem(aMenu1,"1",Font1)
         End Popup
         SEPARATOR
         Popup "List: Manual entry by month" NAME mGroup2 IMAGE "bFind32" FONT Font1 // Level 2
            //a2MenuItem(aMenu2,"2",Font1)
            FOR nMnth := 1 TO LEN(aMonth)
               POPUP aMonth[nMnth] IMAGE "bFind32" FONT Font3
                  a2MenuItem(a12Doc[nMnth],"2"+STRZERO(nMnth,2),Font1)
               END POPUP
            NEXT
         End Popup
         SEPARATOR
         Item "Show deleted entries" ACTION {|| nStatChoice := 3 } ICON "iFind48x1" FONT Font1
         SEPARATOR
         Item "All records in the database" ACTION {|| nStatChoice := 4 } ICON "iFind48x1" FONT Font2
         SEPARATOR
         Item "(1): Enter payment document number" ACTION {|| nStatChoice := 5 } ICON "iEdit64x2" FONT Font1
         Item "(2): Switch to input" ACTION {|| nStatChoice := 6 } ICON "iEdit64x1" FONT Font1
      ENDIF
   END MENU

   _ShowContextMenu(cForm, nY, nX, .f. ) // ПОКАЗ ВЫПАДАЕЩЕГО МЕНЮ

   InkeyGui(10)  // menu работает через очередь !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS
   ?? "nStatChoice=",nStatChoice // 20500001
   nI    := nStatChoice
   nMnth := 0
   cMenu := cScop := ""
   IF nStatChoice > 200000
      nI := 2       
      nMnth := VAL(SUBST(HB_NtoS(nStatChoice),2,2))
      nJ    := VAL(SUBST(HB_NtoS(nStatChoice),4))
      aScp  := a12Scp[nMnth]
      aMenu := a12Doc[nMnth]
      cMenu := aMenu[nJ]
      cScop := aScp[nJ]
   ELSEIF nStatChoice > 100000 .AND. nStatChoice < 200000
      nI := 1
      nJ := nStatChoice - 100000
   ELSE
      nI := nStatChoice
   ENDIF
   //MsgDebug(nStatChoice, nI, nJ, cMenu, cScop)
   ?? "nI=",nI, "nMnth=", nMnth,"nJ=", nJ, cMenu, "["+cScop+"]"

   lBottom := .F.                    // Scope first
   IF nI == 1  // список руч.ввода по всей базе
      SET WINDOW THIS TO oWnd
      nJ := Report_2_1(oWnd,oBrw)    // -> demo2_menu2_1find.prg
      SET WINDOW THIS TO
      IF nJ > 0
         IF App.Cargo:cLang == "RU"
            cTitle := "Выборка: No документа оплаты = " + ALLTRIM(aScop1[nJ]) 
         ELSE
            cTitle := "Selection: Payment document No. = " + ALLTRIM(aScop1[nJ])
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
         cDat := cEnd := aScop1[nJ]     // условие отбора
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

   ELSEIF nI == 2
      // список док. по месяцам года + ручной ввод оператора ( code = '22' )
      IF nJ > 0
         IF App.Cargo:cLang == "RU"
            cTitle := "Выборка: " + cMenu
         ELSE
            cTitle := "Selection: " + cMenu
         ENDIF
         myMenuButton2SuperHd(.T.,oWnd,oBrw,cTitle,oBrw:Cargo:nClr16New)
         // работа с базой
         dbSelectArea(cAls)
         SET DELETED ON
         // переключение индекса
         OrdSetFocus("V22LIST")
         DbGotop()
         // без этого индекс слетает
         oBrw:uLastTag := (cAls)->( ordName( INDEXORD() ) )
         cDat := cEnd := cScop     // условие отбора
         oBrw:ScopeRec(cDat, cEnd, lBottom)
         oBrw:Reset()
         oBrw:Refresh()
         oBrw:GoTop()
      ENDIF

   ELSEIF nI == 3   // Показ удалённых записей
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

   ELSEIF nI == 4   // Все записи в базе
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
      oBrw:ScopeRec(cDat, cEnd, lBottom)
      oBrw:Reset()
      //oBrw:Refresh(.T., .T.)
      // обязательно перечитать состояние вертикального скролинга - не надо
      //oBrw:ResetVScroll( .T. )
      //oBrw:oHScroll:SetRange( 0, 0 )
      oBrw:GoTop()

   ELSEIF nI == 5   // Ввод № документа оплаты
      oWnd:Cargo:cText2 := ALLTRIM(oBrw:Cargo:cMaska)
      ? ProcNL(), "oWnd:Cargo:cText2=","["+oWnd:Cargo:cText2+"]", LEN(oWnd:Cargo:cText2)
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
         nLen := LEN( (oBrw:cAlias)->DOCUM )                // кол-во символов поля DOCUM
         cMsk := UPPER(PADR(cRet,nLen))                     // № док.оплаты
         oBrw:Cargo:cScopeDat       := HB_ANSITOOEM(cMsk)   // запомнить SCOPE
         oBrw:Cargo:cMaska          := cMsk                 // запомнить maska
         App.Cargo:oIni:MAIN:cMaska := cRet                 // запомним МАСКУ ввода для ини-файла
         App.Cargo:lIniChange := .T.                        // изменена переменная для ини-файла
         cDat   := cEnd := HB_ANSITOOEM(cMsk)               // условие отбора
         lBottom := .F.                                     // Scope first
         oBrw:ScopeRec(cDat, cEnd, lBottom)
         ? ProcNL(), "----- SCOPE ----", "["+cDat+"]", LEN(cEnd), lBottom
         // без этого индекс слетает
         oBrw:uLastTag := (oBrw:cAlias)->( ordName( INDEXORD() ) )
         ? ProcNL(), "oBrw:Cargo:cMaska=","["+oBrw:Cargo:cMaska+"]", LEN(oBrw:Cargo:cMaska)
         cTitle := TitleSuperHider(cRet)
         oBrw:Cargo:TitleSupHd := cTitle                    // запомнить НОВЫЙ
         oBrw:SetColor( {16}, { oBrw:Cargo:ColorSupHd } )   // 16, фона спецхидер
         oBrw:DrawHeaders()                                 // перечитать суперхидер/шапку/нумератор
      ENDIF

   ELSEIF nI == 6   // Переключиться на ввод
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
      oBrw:ScopeRec(cDat, cEnd, lBottom)
      oBrw:Reset()
      oBrw:Refresh()
      oBrw:GoTop()
   ENDIF

   ? ProcNL(), "INDEXORD()=", INDEXORD(), ORDSETFOCUS()
   ?? "_SET_DELETED=", Set(_SET_DELETED)

   This.&(cn).Enabled := .T.

   DO EVENTS

RETURN NIL

///////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myMenuButton2SuperHd(lOff,oWnd,oBrw,cTitle,aBClrSH)
   LOCAL cForm, aBtnObj, cObj3, cObj4 //, oCol, nI

   //? ProcNL(), lOff,oWnd,oBrw
   oBrw:Cargo:lRecINS := lOff          // блокировка клавиши INS
   oBrw:Cargo:lRecDEL := lOff          // блокировка клавиши DEL

   cForm := oWnd:Name
   aBtnObj := oWnd:Cargo:aBtnObj      // кнопки вверху формы
   //?v aBtnObj
   //3  {"Btn__RecIns", "Ins-новая;запись", 5, 622, 195, 54, {192, 185, 154}, "_RecIns", "iFind48x1"}
   //4  {"Btn__RecDel", "Del-удалить;запись", 5, 827, 195, 54, {192, 185, 154}, "_RecDel", "iInsert48x1"}
   cObj3 := aBtnObj[3,1]
   cObj4 := aBtnObj[4,1]
   IF lOff
      SetProperty(cForm, cObj3, "Enabled", .F.)
      SetProperty(cForm, cObj4, "Enabled", .F.)
      //  блокировать правку колонок 
      //AEval(oBrw:aColumns, {|oc,ni| oBrw:GetColumn(ni):lEdit := .F. })
      AEval(oBrw:aColumns, {|oc| oc:lEdit := .F. })
      // замена в таблице суперхидера
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

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION Menu_Print(oWnd,ky,cn,oBrw)
   LOCAL aMenu, nY, nX, nI, cForm, cMsg

   ? ProcNL(), oWnd,ky,cn,oBrw
   cForm := oWnd:Name

   This.&(cn).Enabled := .F.
   aMenu := {}
   IF App.Cargo:cLang == "RU"
      AADD( aMenu, {"iPrint48x1", "Печать форма А10" } )
      AADD( aMenu, {"", ""                           } )
      AADD( aMenu, {"iPrint48x1", "Печать форма Ф12" } )
      AADD( aMenu, {"", ""                           } )
      AADD( aMenu, {"iExcel48x1", "Экспорт в Эксель - форма Э2" } )
   ELSE
      AADD( aMenu, {"iPrint48x1", "Print form A10" } )
      AADD( aMenu, {"", "" } )
      AADD( aMenu, {"iPrint48x1", "Print form F12" } )
      AADD( aMenu, {"", ""                           } )
      AADD( aMenu, {"iExcel48x1", "Export to Excel - E2 form" } )
   ENDIF

   nY := GetProperty(cForm, cn, "Row") + GetProperty(cForm, cn, "Height")
   nX := GetProperty(cForm, cn, "Col") //+ GetProperty(cForm, cn, "Width")
   nI := myContextMenu(aMenu, nY, nX, "Icon")  // "Bmp"

   cMsg := IIF( App.Cargo:cLang == "RU","нет выбора!", "no choice!" )
   MsgDebug(nI, IIF( nI>0,aMenu[nI],cMsg) )

   This.&(cn).Enabled := .T.

RETURN NIL

////////////////////////////////////////////////////////////////
FUNCTION a2MenuItem(aMenu, cVal, Font, cType)  // один уровень обработки Item-ов меню
   LOCAL cMenu, bAction, cName, cImg, lChk, lDis, nI, lIcon
   DEFAULT cType := "BMP"

   lIcon := IIF( "ICO" $ UPPER(cType), .T., .F. )

   FOR nI := 1 TO LEN(aMenu)
      cMenu := aMenu[nI]
      IF LEN(cMenu) == 0
         SEPARATOR
      ELSE
         cImg    := Nil //IIF( LEN(aMenu[nI,1])==0, Nil, aMenu[nI,1] )
         cName   := cVal + StrZero(nI, 5)
         bAction := {|| nStatChoice := Val( This.Name ) }
         lChk    := .F.
         lDis    := .F.
         IF lIcon
            _DefineMenuItem( cMenu, bAction, cName,     , lChk, lDis, , Font , , .F., .F. , cImg, .F. )
         ELSE
            _DefineMenuItem( cMenu, bAction, cName, cImg, lChk, lDis, , Font , , .F., .F. )
         ENDIF
      ENDIF
   NEXT

RETURN Nil

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
        SIZE nSize-1  VALUE cMsg VCENTERALIGN CENTERALIGN FONTCOLOR RED TRANSPARENT
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
