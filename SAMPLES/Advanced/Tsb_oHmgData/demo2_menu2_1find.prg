/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Отчёт по базе с помощью SCOPE
 * Расчет итогов при фильтре по базе на "лету"
 * Database report using SCOPE
 * Calculation of totals when filtering by database on the "fly"
*/

#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"
*-----------------------------------------------------------------------------*
FUNCTION Report_2_1(oWnd,oBrw)
*-----------------------------------------------------------------------------*
   LOCAL aList1, aMenu1, aScop1, aMsg, nI, aRpt, cDat, nLine, lDbf, oCol
   LOCAL cAls, dDate, cTime, nSumma, nKolvo, nJ, cTitle, cDbf, cMAls, aRet

   aList1 := oWnd:Cargo:aList1   // список руч.ввода по всей базе
   aMenu1 := aList1[1]
   aScop1 := aList1[2]
   cMAls  := oBrw:cAlias
   nLine  := 0
   IF App.Cargo:cLang == "RU"
      cTitle := "Список: № документов по всей базе"
      aMsg   := { "Расчёт по базе ....", "Отчёт по номеру документов - Форма Д1" }
   ELSE
      cTitle := "List: No. of documents in the entire database"
      aMsg   := { "Calculation based on ....", "Report by document number - Form D1" }
   ENDIF
   // запомнить цвета oBrw
   oCol := oBrw:aColumns[ 3 ]  // 3 колонка с цветом
   oCol:SaveColor()
   oBrw:Cargo:aTsbColor := oCol:aColorsBack
   // блокировка таблицы с закраской
   oBrw:nCLR_Gray  := HMG_RGB2n({184,196,55})
   oBrw:nCLR_HGray := HMG_RGB2n({184,196,55})
   oBrw:nCLR_Lines := CLR_YELLOW
   oBrw:Enabled(.F.)
   //oBrw:lEnabled := .F. не работает

   WaitWindow( aMsg, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )

   // работа с базой
   dbSelectArea(cMAls)
   OrdSetFocus("ULIST2")          // все записи ручного ввода
   // calculate the results
   aRpt := {}
   FOR nI := 1 TO LEN(aMenu1)
      aMsg := {nI, aMenu1[nI], 0, 0.00, CTOD(""), TIME() }
      cDat := aScop1[nI]
      SET SCOPE TO cDat, cDat
      GOTO TOP
      nKolvo := ORDKEYCOUNT()  // общее кол-во записей по индексу
      nSumma := 0
      dDate  := (cMAls)->DATEVVOD2
      cTime  := (cMAls)->TIMEVVOD2
      FOR nJ := 1 TO nKolvo
         ORDKEYGOTO(nJ)
         nSumma += (cMAls)->PRIXOD
      NEXT
      aMsg[3] := nKolvo
      aMsg[4] := nSumma
      aMsg[5] := dDate
      aMsg[6] := cTime
      AADD( aRpt, aMsg )
      DO EVENTS
   NEXT
   //? "=======",ProcNL(), "aRpt=",aRpt ; ?v aRpt
   //31 {31, "мой ввод от 02.05.2024 Неизвестный", 3, 262.00, 0d20240502, "21:42:27"}
   //32 {32, "платежи от 03.05.2024 Петрова", 3, 157.00, 0d20240503, "21:42:27"}
   WaitWindow()
   DO EVENTS

   cDbf := App.Cargo:cPathDbf + "tmp_menu_" + ProcName() + ".dbf"
   cAls := "Menu"
   lDbf := New2Dbf(cDbf,cAls,aRpt)
   DbSelectArea(cAls)

   IF lDbf
      aRet := TsbReport( oWnd, cAls, cTitle )
      ? ProcNL(), "aReturn=", HB_ValToExp(aRet)
      IF LEN(aRet) > 0  ;  nLine := aRet[1]
      ENDIF
      (cAls)->( DbCloseArea() )
   ENDIF

   DbSelectArea(cMAls)
   oBrw:Enabled(.T.)
   //oBrw:lEnabled := .T. - не работает

   DO EVENTS

RETURN nLine

*-----------------------------------------------------------------------------*
STATIC FUNCTION TsbReport( oWnd, cAls, cTitle )
*-----------------------------------------------------------------------------*
   LOCAL oRpt, nY, nX, nW, nH, nG, cTltip, aField, aHead, o, owc
   LOCAL oCel, oBrw, oGet, aReturn, hFont, aFont, cMsg, aHW, aItogo
   LOCAL aFldSum := {"F3", "F4"}  // поля dbf для расчёта итого

   oBrw    := oWnd:Cargo:oBrw  // основная таблица
   // initial columns
   aField  := { "F2", "F3", "F4", "F5", "F6", "F1" }
   IF App.Cargo:cLang == "RU"
      aHead := { "№ документа оплаты", "Кол-во"+CRLF+"квитанций", "Общая"+CRLF+"сумма", "Дата", "Время","ID" }
      cMsg  := "Расчёт ИТОГОВ по dbf-файлу..."
   ELSE
      aHead := { "№ payment document", "Quantity"+CRLF+"receipts", "Total"+CRLF+"amount", "Date", "Time","ID" }
      cMsg  := "Calculation of TOTAL by dbf file..."
   ENDIF
   cTltip  := "" //"Двойной клик по заголовку — сортировка"
   hFont   := GetFontHandle('ComSanMS')
   aFont   := GetFontParam(hFont)

   nG := 10     // отступ слева и между кнопками по ширине/высоте
   nY := nX := nG
   nW := 900 ; nH := 650+GetTitleHeight()+GetBorderHeight()
   DbSelectArea(cAls)
   aItogo := Itogo_Dbf(aFldSum, Alias(), cMsg)

   DEFINE WINDOW Report AT nY,nX WIDTH nW HEIGHT nH TITLE cTitle ;
      MODAL NOSIZE BACKCOLOR oWnd:Cargo:aBColor                  ;
      FONT aFont[1] SIZE aFont[2]                                ;
      ON INIT    _wPost( 0)                                      ;
      ON RELEASE _wSend(90)

      This.Cargo  := oHmgData() ; owc := This.Cargo  // для окна создаем объект без переменных (условно пустой)
      owc:oWin    := This.Object      // объект окна
      owc:cForm   := This.Name        // имя окна
      owc:aReturn := {}               // вернуть массив выбранных значений
      owc:nHIco   := 48               // высота иконки на кнопке
      owc:aFldSum := aFldSum          // для подвала таблицы - итого
      owc:nCount  := aItogo[1]
      owc:aItogo  := aItogo[2]

      /////////////////////// кнопки вверху формы ///////////////////////////////////
      aHW := myTopMenu( nY/2, nX, nG, owc:nHIco )
      nY  := aHW[1]
      nX  := nG
      nW  := This.ClientWidth
      nH  := This.ClientHeight - nY

      DEFINE TBROWSE oRpt OBJ oRpt AT nY, nX ALIAS cAls WIDTH nW-nG*2 HEIGHT nH-nG CELL ;
         FONT    oBrw:Cargo:aFont         ; // все фонты для таблицы
         BRUSH   oBrw:Cargo:aClrBrush     ; // цвет фона под таблицей
         HEADERS aHead                    ; // список шапки колонок таблицы
         COLUMNS aField                   ; // список наименований колонок таблицы
         COLNUMBER { 1 , 50 }             ; // слева таблицы виртуальная колонка с нумерацией
         LOADFIELDS                       ; // автоматическое создание столбцов по полям активной базы данных
         GOTFOCUSSELECT                   ;
         EMPTYVALUE                       ;
         FIXED                            ; // активирует функцию двойного курсора на закрепленных столбцах
         TOOLTIP cTltip                   ;
         ON INIT {|ob| myTsbInit( ob ) }    // настройки таблицы - смотреть ниже

         myTsbTune(oRpt)              // настроить
         myTsbColor(oRpt,oBrw)        // цвета изменить
         myTsbKeys(oRpt)              // обработка клавиш
         // не должно быть нигде, кроме события ! myTsbItogo() // обработка подвала

      END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:SetFocus() }

      This.Cargo:oRpt := oRpt        // положить объект oRpt (таблицу) на окно
      ? ProcNL() , "~~~~~~~>>>", oRpt, This.Cargo

      ON KEY F1     ACTION NIL
      ON KEY ESCAPE ACTION _wPost(98)

      // координаты ячейки в которой GetBox
      oCel := oRpt:GetCellInfo( 2 )
      nX   := oCel:nCol + 2
      nW   := oCel:nWidth - 5
      nH   := oRpt:nHeightCell
      nY   := ( oRpt:nHeightFoot - nH ) / 2
      nY   := This.ClientHeight - oRpt:nHeightFoot + nY
      cMsg := oRpt:aColumns[2]:cFooting             // "Поиск:"
      nX   += GetTextWidth( NIL, cMsg, GetFontHandle('Bold') ) + 10
      nW   -= GetTextWidth( NIL, cMsg, GetFontHandle('Bold') ) + 10
      // GetBox в подвале таблицы
      @ nY-nG, nX+nG GETBOX GB_Find OBJ oGet WIDTH nW-nG HEIGHT nH VALUE space(30) ;
        PICTURE "@K" NOTABSTOP INVISIBLE   ;
        ON LOSTFOCUS {|| This.Cargo := .F., This.Value := space(30), This.Hide } ;
        ON CHANGE    {|| iif( Empty( This.Cargo ), NIL, Search_TSB( ThisWindow.Object, .T. ) ) } ;
        ON INIT      {|| This.Cargo := .T. }

      This.Cargo:oGet := oGet
      This.Cargo:cGet := "GB_Find"    // запомнить для дальнейшего использования

      ///////////////////////////////////
      o := This.Object

      o:Event( 0, {|ow| _wPost(22, ow)  } )  // инициализация после построения окна

      // кнопки вверху формы
      //aPost := { "_2Enter", "_2Prn" , "_2Excel", "_2Exit" }
      o:Event({10, "_2Enter"}, {|ow| // возврат выбранной записи
                                     Local oRpt := ow:Cargo:oRpt
                                     Local cAls := oRpt:cAlias
                                     ow:Cargo:aReturn := {(cAls)->F1,(cAls)->F2}
                                     _wSend(99)           // закрыть Modal окно
                                     Return Nil
                                } )

      o:Event({11, "_2Prn"}, {|ow,ky,cn| ;
                                   AlertInfo('Printing.  This.Name = ' + This.Name, ow:Name) ,;
                                   ky := cn, This.&(cn).Enabled := .T.    } )

      o:Event({12,"_2Excel"}, {|ow,ky,cn| ;
                                MsgBox('Export to MS Excel. This.Name = ' + This.Name, ow:Name) ,;
                                ky := cn, This.&(cn).Enabled := .T.    } )

      o:Event({15,"_2Exit" }, {|ow| _LogFile(.T., ProcNL(),">>> Exit button pressed! Window: "+ow:Name), _wSend(99) } )

      // Работа с таблицей
      o:Event( 22, {|ow| myTsbItogo(ow)                  } )    // итого refresh

      o:Event( 90, {|  | aReturn := (This.Cargo):aReturn  } )    // возврат LOCAL aReturn

      o:Event( 98, {|ow|
                    Local oRpt := ow:Cargo:oRpt
                    Local cGet := ow:Cargo:cGet
                    Local lGet := This.&(cGet).Cargo
                    IF !Empty( lGet )       // mode find
                       oRpt:SetFocus()
                    ELSE                    // no mode
                       _wSend(99)
                    ENDIF
                    Return Nil
                    } )
      o:Event( 99, {|ow| ow:Release()  } )

   END WINDOW

     CENTER WINDOW Report
   ACTIVATE WINDOW Report

RETURN aReturn

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbInit( oRpt )  // настройки тсб  !!!

   WITH OBJECT oRpt
      :Cargo := oHmgData()
      :lNoChangeOrd  := .T.     // отключить сортировку по колонкам
      :nColOrder     :=  0      // убрать значок сортировки по колонке
      :lNoGrayBar    := .F.     // T-НЕ показывать неактивный курсор в таблице
      :lNoLiteBar    := .F.     // при переключении фокуса на другое окно не убирать "легкий" Bar
      :lNoResetPos   := .F.     // предотвращает сброс позиции записи на gotfocus
      :lPickerMode   := .F.     // формат даты нормальный через цифры
      :nStatusItem   :=  0      // в 1-й Item StatusBar не выводить автоматом из тсб
      :lNoKeyChar    := .T.     // .T. - откл. метод KeyChar(...) - ввод от букв, цифр
      :nWheelLines   :=  1      // прокрутка колесом мыши
      :nCellMarginLR :=  1      // отступ от линии ячейки при прижатии влево, вправо на кол-во пробелов
      :lMoveCols     := .F.
      :nMemoHV       :=  1      // показ одной строки мемо-поля
      :nLineStyle := LINES_ALL
      :nClrLine   := COLOR_GRID
      :lCheckBoxAllReturn := .T.
      :lNoVScroll    := .F.
      :lNoHScroll    := .T.
   END WITH

   oRpt:Cargo:cKeyLang := '('+KB_LANG()+')' // -> util_keychar.prg

RETURN Nil

//////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbTune(oRpt)              // настроить
   LOCAL cMsg := IIF( App.Cargo:cLang == "RU", "Поиск:", "Search:")

   WITH OBJECT oRpt

      :HideColumns( {7} ,.t.)   // скрыть колонки
      :nHeightCell  += 6
      :nHeightHead  := :nHeightCell + 2
      :nHeightFoot  := :nHeightCell + 2
      :lDrawFooters := .T.
      :lFooting     := .T.

      :aColumns[ 2 ]:hFont    := GetFontHandle('ComSanMS')
      :aColumns[ 2 ]:nWidth   += 40
      :aColumns[ 2 ]:cFooting := cMsg
      :aColumns[ 2 ]:nFAlign  := DT_LEFT
      :aColumns[ 6 ]:nWidth   += 10

      // Вывод подсказки с использованием внутреннего цикла TBrowse
      :bEvents := { |a,b| myTsbEvents(a,b) }

      :lNoChangeOrd := .F.  // включить сортировку по колонкам
      AEval( :aColumns, {|oc,nc| oc:lFixLite := .T., oc:lIndexCol := nc > 1 })

      :AdjColumns({4, 5, 6})   // :AdjColumns()

      :nFreeze     := oRpt:nColumn("ORDKEYNO") // заморозить таблицу до этого столбца
      :lLockFreeze := .T.                      // избегать прорисовки курсора на замороженных столбцах
      :nCell       := oRpt:nFreeze + 1         // передвинуть курсор на колонку номер

   END WITH

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbItogo( oWnd )  // подвал - ТОЛЬКО показ
   LOCAL aItg := oWnd:Cargo:aItogo
   Local oRpt := oWnd:Cargo:oRpt

   ? ProcNL(), "##", oWnd, oWnd:Cargo, oWnd:Classname
   ? "oWnd:Cargo:aItogo=   aItg=",aItg, HB_ValToExp(aItg)
   ? "oRpt:=", oRpt, oRpt:Classname,oRpt:cAlias

   oRpt:aColumns[1]:cFooting := {|nc,ob| nc := ob:nLen, iif( Empty(nc), "", hb_NtoS(nc) ) }
   oRpt:aColumns[3]:cFooting := {|nc   | nc := aItg[1], iif( Empty(nc), "", hb_NtoS(nc) ) }
   oRpt:aColumns[4]:cFooting := {|nc   | nc := aItg[2], iif( Empty(nc), "", hb_NtoS(nc) ) }

   oRpt:Cargo:cKeyLang := '('+KB_LANG()+')' // -> util_keychar.prg
   oRpt:aColumns[5]:cFooting := oRpt:Cargo:cKeyLang

   oRpt:DrawFooters() ; DO EVENTS

RETURN Nil

//////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbColor(oRpt,oBrw)  // цвета изменить
   LOCAL aColor, nCol, nJ, nClrBC, aBClr

   // берем цвета предыдущей таблицы
   aColor := oBrw:Cargo:aTsbColor
   nClrBC := oBrw:Cargo:nClrBC
   aBClr  := oBrw:Cargo:aClrBrush        // цвет фона под таблицей

   // восстановить цвета с 2-ой колонки
   FOR nCol := 1 TO LEN(oRpt:aColumns)
      FOR nJ := 1 to 15  // меняем цвет по 15
         oRpt:Setcolor( { nJ }, { aColor[nJ] }, nCol  )
      NEXT
      oRpt:SetColor( {  1 }, { { || CLR_BLUE     } } )    // 1 , текста в ячейках таблицы
      oRpt:SetColor( {  2 }, { { || nClrBC       } } )    // 2 , фона в ячейках таблицы
   NEXT
   oRpt:hBrush := CreateSolidBrush(aBClr[1], aBClr[2], aBClr[3])  // цвет фона под таблицей
   oRpt:GetColumn("ORDKEYNO"):nClrBack := oBrw:Cargo:nBtnFace
   oRpt:GetColumn("ORDKEYNO"):nClrFore := CLR_RED
   oRpt:aColumns[7]:nClrFore := CLR_WHITE

RETURN Nil

////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbKeys(oRpt)          // обработка клавиш

   WITH OBJECT oRpt

      :UserKeys( VK_F5, {|ob| _wPost(/*1*/"Print", ob) } )
      :UserKeys( VK_F6, {|ob| _wPost(/*2*/"Excel", ob) } )
      // Двойной клик мышки на МАРКЕРЕ
      :bLDblClick := {|p1,p2,p3,ob| p1:=p2:=p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }
      // обработка клавиши ENTER и ESC
      :UserKeys(VK_RETURN, {|ob| _wPost(10, ob:cParentWnd) })  // возврат выбранной записи
      :UserKeys(VK_ESCAPE, {|ob| _wSend(98, ob:cParentWnd) })
      :UserKeys(         , {|ob,ky,ck| // набор букв для поиска
                             Local oWnd := _WindowObj(ob:cParentWnd)
                             Local cGet := oWnd:Cargo:cGet //"GB_Find"
                             Local oGet := oWnd:GetObj(cGet), cVal
                             SET WINDOW THIS TO oWnd
                             ck := KeyToChar(ky)
                             If len(ck) > 0
                                IF !Empty((ob:cAlias)->( dbFilter() ))
                                   ob:FilterFTS( Nil )
                                   //ob:FilterRow()
                                ENDIF
                                This.&(cGet).Cargo := .T. // find mode
                                oGet:Show()
                                oGet:SetFocus()
                                DO EVENTS
                                cVal := oGet:Get:VarGet()
                                oGet:Get:VarPut(space(len(cVal)))
                                DO EVENTS
                                _PushKey(ky)
                             EndIf
                             SET WINDOW THIS TO
                             Return Nil
                             })
   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbEvents(oRpt, nMsg)
   LOCAL cLang

   IF nMsg != WM_PAINT
      cLang := '('+KB_LANG()+')'
      IF cLang != oRpt:Cargo:cKeyLang
         oRpt:aColumns[5]:cFooting := cLang
         oRpt:Cargo:cKeyLang := cLang
         oRpt:DrawFooters()
      ENDIF
   ENDIF

RETURN 0

//////////////////////////////////////////////////////////////////////
// GetBox в подвале таблицы
STATIC FUNCTION Search_TSB(oWnd, aWait)          // поиск по базе
   LOCAL oRpt, cVal, cGet, aItg
   Default oWnd  := ThisWindow.Object
   Default aWait := .F.

   oRpt := oWnd:Cargo:oRpt
   cGet := oWnd:Cargo:cGet             // это "GB_Find"

   IF !Empty(aWait)
      IF HB_ISLOGICAL(aWait)
         aWait := "Calculation RESULTS..."
      ENDIF
      // нельзя срабатывает LOSGFOCUS getbox
      //WaitWindow( aWait, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )
   ENDIF

   SET WINDOW THIS TO oWnd
   This.&(cGet).Show
   cVal := Trim( This.&(cGet).Value )
   SET WINDOW THIS TO

   oRpt:FilterFTS( cVal, .T. )         // Empty(cVal) обработка внутри метода

   aItg := Itogo_Dbf(oWnd:Cargo:aFldSum, oRpt:cAlias) // расчёты итого

   oWnd:Cargo:nCount  := aItg[1]
   oWnd:Cargo:aItogo  := aItg[2]

   // нельзя срабатывает LOSGFOCUS getbox
   //IF !Empty(aWait) ; WaitWindow()
   //ENDIF

   _wSend( 22, oWnd )                                  // вывод в подвал
   //но можно и
   //_wPost( 22, oWnd )                                // вывод в подвал

RETURN .T.

/////////////////////////////////////////////////////////////////////
STATIC FUNCTION Itogo_Dbf(aFld, cAls, aWait)  // расчёты итого
   LOCAL nLen := 0, nRec, aItg, aPos, nPos
   LOCAL nOld := Select(), nCnt := 0, nSum
   Default cAls := Alias(), aWait := .F.

   IF !Empty(aWait)
      IF HB_ISLOGICAL(aWait)
         aWait := "Wait processing ..."
      ENDIF
      WaitWindow( aWait, .T. , 600, 16, NIL, BLUE, App.Cargo:aBClrMain )
   ENDIF

   dbSelectArea( cAls )

   nRec := RecNo()
   aItg := Array(Len(aFld)) ; aFill(aItg, 0)
   aPos := {} ; AEval(aFld, {|cn| AAdd(aPos, FieldPos(cn)) })

   DO EVENTS
   GO TOP
   DO WHILE ! EOF()
      nCnt++
      DO EVENTS
      FOR EACH nPos IN aPos
          IF nPos > 0 .and. HB_ISNUMERIC( nSum := FieldGet( nPos ) )
             aItg[ hb_EnumIndex(nPos) ] += nSum
          ENDIF
      NEXT
      SKIP
   ENDDO

   DbGoTo( nRec )       ; DO EVENTS

   IF !Empty(aWait)     ; WaitWindow()
   ENDIF

   dbSelectArea( nOld ) ; DO EVENTS

RETURN { nCnt, aItg }

////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION New2Dbf(cDbf,cAls,aRpt)
   LOCAL lUsed, cUsl, cFor, cFor2, aStr := {}, a, i := 0

   //31 {31, "мой ввод от 02.05.2024 Неизвестный", 3, 262.00, 0d20240502, "21:42:27"}
   //32 {32, "платежи от 03.05.2024 Петрова", 3, 157.00, 0d20240503, "21:42:27"}
   hb_FileDelete( cDbf )

   FOR EACH a IN aRpt
      i := MAX( LEN(ALLTRIM(a[2])), i )
   NEXT
   i += 5

   AAdd( aStr, { 'F1', 'N',  6, 0 } )
   AAdd( aStr, { 'F2', 'C',  i, 0 } )
   AAdd( aStr, { 'F3', 'N',  6, 0 } )
   AAdd( aStr, { 'F4', 'N', 12, 2 } )
   AAdd( aStr, { 'F5', 'D',  8, 0 } )
   AAdd( aStr, { 'F6', 'C',  8, 0 } )

   DbCreate( cDbf, aStr )

   // ошибки открытия базы сделать самостоятельно
   USE (cDbf) ALIAS (cAls) NEW CODEPAGE "RU1251"

   FOR EACH a IN aRpt
      (cAls)->( DbAppend() )
      (cAls)->F1 := a[1]
      (cAls)->F2 := a[2]
      (cAls)->F3 := a[3]
      (cAls)->F4 := a[4]
      (cAls)->F5 := a[5]
      (cAls)->F6 := a[6]
   NEXT

   lUsed := Used()
   IF ( lUsed := Used() )
      cUsl  := 'UPPER(F2)'
      cFor  := "!Deleted()"
      cFor2 := "Deleted()"
      //INDEX ON &cUsl TAG DOC FOR &cFor  ADDITIVE
      //INDEX ON &cUsl TAG DEL FOR &cFor2 ADDITIVE
      //INDEX ON &cUsl TAG ALL ADDITIVE
      //SET ORDER TO 3
      GO TOP
   ENDIF

RETURN lUsed

///////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTopMenu( nY, nX, nG, nHIco )
   LOCAL nHeight, nWidth, i, y, x, w, h, nGaps, cObj, aObj, aCEng, nW, nH
   LOCAL aIcon, aBClr, aPost, aCapt, cCap, nWBtn, aFont, nPosWin, nHAlign
   LOCAL aGrad, nHBtn, lIco, aBtnObj, aFntClr, aBlk, nWCap, nWTxt, lVert, lLeft

   ? ProcNL(), nY, nX, nG, nHIco
   nW      := This.ClientWidth
   nH      := This.ClientHeight
   nPosWin := 1         // 1-TopWindow // не делал: 2-BottomWindow, 3-LeftWindow, 4-RightWindow
   nHAlign := DT_CENTER //DT_LEFT   // горизонтальные кнопки: 0-DT_LEFT, 1-DT_CENTER, 2-DT_RIGHT
   aBtnObj := {}
   nHeight := nWTxt := 0
          //     1           2         3         4
   IF App.Cargo:cLang == "RU"
      aCapt := { "Выбор"  , "Печать", "Эксель" , "Выход"  }
   ELSE
      aCapt := { "Select" , "Print" , "Excel" , "Exit" }
   ENDIF
   aCEng := { "Help"   , "Print" , "Excel"  , "Esc"    }
   aPost := { "_2Enter", "_2Prn" , "_2Excel", "_2Exit" }
   aBClr := { { 94, 59 , 185}    ,;   // 1  Выбор
              { 33, 140, 194}    ,;   // 2  Печать
              { 35, 179,  15}    ,;   // 3  Эксель
              {128,   0,   0}       } // 4  Выход

   lIco  := IIF(nHIco==48,.F.,.T.)  // изменять размер, если нужно
   aIcon := { {"iEnter48x1" ,"iEnter48x2" , lIco, nHIco} ,;   // 1  Помощь
              {"iPrint48x1" ,"iPrint48x2" , lIco, nHIco} ,;   // 2  Печать
              {"iExcel48x1" ,"iExcel48x2" , lIco, nHIco} ,;   // 3  Эксель
              {"iExitM48x1" ,"iExitM48x2" , lIco, nHIco} }    // 4  Выход

   aFont   := { "Comic Sans MS", 14, .T., 16, "увеличение фонта кнопки" }  // новое 21.04.24
   aFntClr := {  BLACK, YELLOW }

   FOR i := 1 TO LEN(aCapt)
      cCap  := aCapt[i]
      nWCap := GetTxtWidth(cCap, aFont[4], aFont[1], aFont[3] )
      nWTxt := MAX(nWTxt,nWCap)
   NEXT
   nWBtn := nHIco + nG + nWTxt // ширина кнопки
   nHBtn := nHIco + 4*2       // высота кнопки
   nGaps := nG                // между кнопками
   y     := nY
   x     := nX
   h     := nHBtn
   w     := nWBtn
   //?? "nWBtn=", nWBtn, "nHBtn=",nHBtn,"nGaps=", nGaps

   aObj  := array(Len(aCapt))
   aBlk  := array(Len(aCapt)) ; aFill(aBlk, .T.   )  // блокировать кнопки при нажатии
   aGrad := array(Len(aCapt)) ; aFill(aGrad, WHITE)  //; aGrad[7] := { 0,62, 0 }

   lVert := .F.  // .T.-вертикальный текст для кнопок, .F.- НЕ вертикальный текст
   lLeft := .F.  // .T.-слева текст для кнопок, .F.-справа

   // горизонтальные кнопки: 0-LEFT, 1-CENTER, 2-RIGHT
   IF nHAlign == DT_LEFT
      FOR i := 1 TO LEN(aCapt)
         cObj := "Btn" + aPost[i]  //StrZero(i, 2)
         cCap := StrTran( aCapt[i], ";" , CRLF )
         my2BUTTON(y, x, w, h, cObj, cCap, {aBClr[i], aGrad[i]}, , aIcon[i], aFntClr, aFont, aPost[i], aBlk[i], .F., lVert, lLeft )
         AADD( aBtnObj, { i, cObj, y, x, w, h, cCap, aBClr[i], aGrad[i], aIcon[i], aPost[i], aBlk[i] } )
         x += This.&(cObj).Width + nGaps
         nWidth := x
      NEXT
   ELSEIF nHAlign == DT_RIGHT
      lLeft := .T.  // .T.-слева текст для кнопок, .F.-справа
      nW    := This.ClientWidth
      x     := nW - nG - nWBtn
      FOR i := LEN(aCapt) TO 1 STEP -1
         cObj := "Btn" + aPost[i]  //StrZero(i, 2)
         cCap := StrTran( aCapt[i], ";" , CRLF )
         my2BUTTON(y, x, w, h, cObj, cCap, {aBClr[i], aGrad[i]}, , aIcon[i], aFntClr, aFont, aPost[i], aBlk[i], .F., lVert, lLeft )
         AADD( aBtnObj, { i, cObj, y, x, w, h, cCap, aBClr[i], aGrad[i], aIcon[i], aPost[i], aBlk[i] } )
         x -= (This.&(cObj).Width + nGaps )
         nWidth := x
      NEXT
   ELSE
      lLeft  := .T.  // .T.-слева текст для кнопок, .F.-справа
      nW     := This.ClientWidth
      nWidth := nWBtn * LEN(aCapt) + nGaps * LEN(aCapt) + 1
      x := ( nW - nWidth ) / 2
      FOR i := 1 TO LEN(aCapt)
         cObj := "Btn" + aPost[i]  //StrZero(i, 2)
         cCap := StrTran( aCapt[i], ";" , CRLF )
         my2BUTTON(y, x, w, h, cObj, cCap, {aBClr[i], aGrad[i]}, , aIcon[i], aFntClr, aFont, aPost[i], aBlk[i], .F., lVert, lLeft )
         AADD( aBtnObj, { i, cObj, y, x, w, h, cCap, aBClr[i], aGrad[i], aIcon[i], aPost[i], aBlk[i] } )
         x += This.&(cObj).Width + nGaps
         nWidth := x
      NEXT
   ENDIF

   nHeight := h + nY * 2

RETURN { nHeight, nWidth }

