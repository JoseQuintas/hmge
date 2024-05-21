/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Работа с таблицей / Working with a table
*/
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION RecnoInsert_TSB(ow,ky,cn,ob)  // VK_INSERT
RETURN RecnoInsert(ow,ky,cn,ob)        // смотреть ниже

FUNCTION RecnoDelete_TSB(ow,ky,cn,ob)  // VK_DELETE
RETURN RecnoDelete(ow,ky,cn,ob)        // смотреть ниже

/////////////////////////////////////////////////////////////////////
FUNCTION Draw_TSB( oTsb, oWnd, cBrw )
   LOCAL cDat, cEnd, lBottom, cAnsOem, nLen, cMaska, cMaska2
   LOCAL oBrw, cForm := oTsb:cForm    // определено выше
   LOCAL cTtl, xSelector := .T.       // первая колонка - селектор

   // строим таблицу по заданным массивам
   DEFINE TBROWSE &cBrw OBJ oBrw OF &cForm           ;
      AT oTsb:nY, oTsb:nX ALIAS oTsb:cAls WIDTH oTsb:nW HEIGHT oTsb:nH CELL   ;
      FONT     oTsb:aFont                            ; // все фонты для таблицы
      BRUSH    oTsb:aClrBrush                        ; // цвет фона под таблицей
      HEADERS  oTsb:aHead                            ; // список шапки колонок таблицы
      COLSIZES oTsb:aSize                            ; // ширина колонок таблицы
      PICTURE  oTsb:aPict                            ; // список формата колонок таблицы
      JUSTIFY  oTsb:aAlign                           ; // список отбивки колонок таблицы
      COLUMNS  oTsb:aField                           ; // список наименований колонок таблицы
      COLNAMES oTsb:aName                            ; // список полей базы колонок таблицы
      FOOTERS  oTsb:aFoot                            ; // список подвала колонок таблицы
      EDITCOLS oTsb:aEdit                            ; // массив данных для редактирования колонок .T.\.F.\Nil>\.T\.F.\NIL
      COLNUMBER oTsb:aNumber                         ; // слева таблицы виртуальная колонка с нумерацией
      FIXED                                          ; // активирует функцию двойного курсора на закрепленных столбцах
      COLSEMPTY                                      ; // ставит свойство колонок в .T. (пустые значения как "") для типов D,N,T,L
      LOADFIELDS                                     ; // автоматическое создание столбцов по полям активной базы данных
      ENUMERATOR                                     ; // нумерация колонок
      SELECTOR xSelector                             ; // первая колонка - селектор записей
      EDIT GOTFOCUSSELECT                            ;
      LOCK                                           ; // автоматическая блокировка записи при вводе в базу данных
      ON INIT  {|ob| ob:Cargo := oHmgData(), ;
                 ob:lNoChangeOrd  := .T., ;     // отключить сортировку
                 ob:nColOrder     :=  0 , ;     // убрать значок сортировки по колонке
                 ob:lNoGrayBar    := .F., ;     // T-НЕ показывать неактивный курсор в таблице
                 ob:lNoLiteBar    := .F., ;     // при переключении фокуса на другое окно не убирать "легкий" Bar
                 ob:lNoResetPos   := .F., ;     // предотвращает сброс позиции записи на gotfocus
                 ob:lPickerMode   := .F., ;     // формат даты нормальный через цифры
                 ob:nStatusItem   :=  0 , ;     // в 1-й Item StatusBar не выводить автоматом из тсб
                 ob:lNoKeyChar    := .T., ;     // .T. - откл. метод KeyChar(...) - ввод от букв, цифр
                 ob:nWheelLines   :=  1 , ;     // прокрутка колесом мыши
                 ob:nCellMarginLR :=  1 , ;     // отступ от линии ячейки при прижатии влево, вправо на кол-во пробелов
                 ob:lMoveCols     := .F., ;
                 ob:nMemoHV       :=  1 , ;     // показ одной строки мемо-поля
                 ob:nLineStyle := LINES_ALL ,;
                 ob:nClrLine   := COLOR_GRID,;
                 ob:lCheckBoxAllReturn := .T. }
      // --------- убрал, т.к. нельзя сделать клик по шапке таблицы
      //  ob:lNoMoveCols   := .T., ;     // .T. - НЕЛЬЗЯ юзерам изменять размер или перемещать столбцы
      // не использую здесь
      //COLORS  aBrwColors              ;   // все цвета таблицы
      //BACKCOLOR aBackColor            ;   // фон таблицы - совпадает с фоном окна
      //SIZES aFSize                    ;   // ширина колонок таблицы
      //EMPTYVALUE                      ;
      //  ob:uLastTag      := NIL, ;     // убрал
      //  ob:bTagOrder     := NIL, ;     // убрал

      :Cargo:nModify := 0                           // изменения в таблице
      :Cargo:nHBmp   := oTsb:nHBmp                  // высота картинки
      :Cargo:nHImg   := oTsb:nHBmp + 2*2            // высота картинки + высота строк в ТСБ
      :Cargo:aFont   := oTsb:aFont                  // запомним фонты
      :Cargo:aSupHd  := oTsb:aSupHd                 // суперхидер таблицы
      // мои доп. данные по колонкам
      :Cargo:aColPrc := oTsb:aColPrc                // тип обработки колонки
      :Cargo:aFunc1  := oTsb:aFunc1                 // функция-1 :bPrevEdit для обработки колонки таблицы
      :Cargo:aFunc2  := oTsb:aFunc2                 // функция-2 :bPostEdit для обработки колонки таблицы
      :Cargo:aTable  := oTsb:aTable                 // положить весь массив таблицы в cargo окна, на всякий случай
      :Cargo:aBlock  := oTsb:aBlock                 // кодовый блок на составные поля и функции
      :Cargo:aDecode := oTsb:aDecode                // для колонки oCol:bDecode
      :Cargo:aCntMnu := oTsb:aCntMnu                // иконки для контекстного меню - тип "S"
      :Cargo:aBmp1   := oTsb:aBmp1                  // колонка 1 с картинками
      :Cargo:aBmp6   := oTsb:aBmp6                  // колонка 8 с картинками
      :Cargo:aIconDel:= oTsb:aIconDel               // удалить значение
      :Cargo:lRecINS := .F.                         // блокировка клавиши INS
      :Cargo:lRecDEL := .F.                         // блокировка клавиши DEL
      :Cargo:cMaska  := App.Cargo:oIni:MAIN:cMaska  // запомним МАСКУ ввода из ини-файла

      Column_Init(oBrw,oTsb)          // подготовка колонок -> Column_TSB.prg

      myTsbInit( oBrw )               // настройки
      myTsbColor( oBrw )              // цвета
      myTsbFont( oBrw )               // фонты в таблице
      //myTsbDelColumn( oBrw )        // убрать колонки из отображения
      myTsbSuperHd( oBrw )            // SuperHeader
      // последней строкой ставить перед END TBROWSE
      myTsb_Before( oBrw )          // обработка клавиш

      ? "===>" + ProcNL(), oBrw:nColumn("ORDKEYNO", .T.) // просто тест

      // включить вертикальный скролинг
      /*IF :nLen > :nRowCount()
         :ResetVScroll( .T. )
         :oHScroll:SetRange( 0, 0 )
      ENDIF */

   END TBROWSE ON END {|ob| ob:SetNoHoles(), ob:SetFocus() }

   ? "===>" + ProcNL(), oBrw:nColumn("ORDKEYNO", .T.) // просто тест

   // последней строкой ставить после END TBROWSE из-за SELECTOR
   myTsbEdit( oBrw, oWnd )         // настройки редактирования
   myTsbClick( oBrw )              // шапка/подвал/колонки - функции обработки

   oBrw:GetColumn("SELECTOR"):nClrFootBack := oBrw:Cargo:nBtnFace    // не работает
   oBrw:aColumns[1]:nClrFootBack := CLR_RED                          // не работает

   oBrw:lNoKeyChar := .F.     // ввод в ячейки от букв, цифр

   //  запомнить какие колонки можно редактировать
   //  ставить после END TBROWSE из-за SELECTOR
   oBrw:Cargo:aEditOriginal := ARRAY(LEN(oBrw:aColumns))
   AEval(oBrw:aColumns, {|oc,ni| oBrw:Cargo:aEditOriginal[ni] := oc:lEdit })

   //  МАСКА ввода - № док.оплаты
   IF IsString( oBrw:Cargo:cMaska )
      cMaska := oBrw:Cargo:cMaska
   ELSE
      cMaska := App.Cargo:oIni:MAIN:cMaska 
   ENDIF
   cMaska  := ALLTRIM(cMaska)                             // № док.оплаты
   IF LEN(cMaska) == 0
      cMaska := App.Cargo:oIni:MAIN:cMaska 
   ENDIF
   // --------- подключаем здесь SCOPE ---------
   nLen    := LEN( (oBrw:cAlias)->DOCUM )                 // кол-во символов поля DOCUM
   cMaska2 := UPPER(PADR(cMaska,nLen))                    // № док.оплаты
   cAnsOem := HB_ANSITOOEM(cMaska2)                       // № док.оплаты
   cDat    := cEnd := cAnsOem                             // условие отбора
   lBottom := .F. // Scope first
   lBottom := .T. // Scope last
   oBrw:Cargo:cScopeDat       := cAnsOem                  // запомнить SCOPE
   oBrw:Cargo:cMaska          := cMaska2                  // запомнить maska
   App.Cargo:oIni:MAIN:cMaska := cMaska                   // запомним МАСКУ ввода для ини-файла
   oBrw:ScopeRec(cDat, cEnd, lBottom)
   ? ProcNL(), "----- SCOPE ----", "["+cDat+"]", LEN(cEnd), lBottom
   // сортировка в таблице по этому индексу
   OrdSetFocus("DOCDTV")      // индекс "маска ввода за день"
   DbGotop()
   // без этого индекс слетает
   oBrw:uLastTag := (oBrw:cAlias)->( ordName( INDEXORD() ) )
   //oBrw:Reset()
   oBrw:GoTop()
   DO EVENTS
   ? SPACE(5) + "INDEXORD()=",INDEXORD(), ORDSETFOCUS(),
   ? SPACE(5) + "oBrw:Cargo:cMaska=","["+oBrw:Cargo:cMaska+"]", LEN(oBrw:Cargo:cMaska)
   ? SPACE(5) + "App.Cargo:oIni:MAIN:cMaska=","["+cMaska+"]", LEN(cMaska)
   // --------- перечитываем суперхидер ---------
   cTtl := TitleSuperHider(cMaska)
   oBrw:Cargo:TitleSupHd   := cTtl              // запомнить НОВЫЙ
   oBrw:aSuperhead[ 1, 3 ] := oBrw:Cargo:TitleSupHd
   oBrw:DrawHeaders()          // перечитать суперхидер/шапку/нумератор

RETURN oBrw

//////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbInit( oBrw )       // настройки
   LOCAL nI, o := oBrw:Cargo  // берём из контейнера свои переменные

   WITH OBJECT oBrw
     :nHeightCell   := o:nHImg      // высота ячеек = высоте картинки
     //:nHeightCell += 6
     :nHeightSpecHd := 12           // высота спецхидера ENUMERATOR
     :lFooting      := .T.          // использовать подвал
     :lDrawFooters  := .T.          // рисовать  подвалы
     :nFreeze       := 2            // Заморозить столбец
     :lLockFreeze   := .T.          // Избегать прорисовки курсора на замороженных столбцах
     :nCell         := :nFreeze + 1
     // --------- хранилище картинок, удаляется после закрытия объекта автоматом ------
     :aBitMaps      := { Nil, LoadImage("bRecDel16") }

     :aColumns[1]:nWidth   := :Cargo:nHImg  // ширина колонки как у картинки
     :aColumns[2]:nWidth   := :Cargo:nHImg  // ширина колонки как у картинки

     // изменение картинки для удалённых записей в колонке ORDKEYNO
     :aColumns[1]:aBitMaps := :Cargo:aBmp1[2]
     :aColumns[1]:uBmpCell := {|nc,ob| nc:=nil, iif( (ob:cAlias)->(Deleted()), ob:aBitMaps[2], ob:aBitMaps[1] ) }

     // колонка с картинками
     //:aColumns[5]:lCheckBox := .F. - резерв
     /*:aColumns[2]:aBitMaps := { LoadImage("bMinus32",,nHChk,nHChk), LoadImage("bZero32",,nHChk,nHChk),;
                                LoadImage("bPlus32",,nHChk,nHChk) }
     :aColumns[2]:uBmpCell := {|nc,ob|
                                Local ocol := ob:aColumns[nc]
                                Local ni   := 0
                                Local nSum := ob:GetValue("PRIXOD")  // колонка суммы
                                IF !IsNumeric(nSum)
                                   nSum := 0
                                ENDIF
                                IF nSum < 0
                                   ni := 1
                                ELSEIF nSum == 0
                                   ni := 2
                                ELSE
                                   ni := 3
                                ENDIF
                                Return ocol:aBitMaps[ni]                   // картинку с позиции массива
                              }
     */
     :aColumns[2]:aBitMaps := :Cargo:aBmp1[2]
     :aColumns[2]:uBmpCell := :Cargo:aBmp1[3]
     //
     :aColumns[2]:nAlign   := nMakeLong( DT_CENTER, DT_CENTER )
     :aColumns[2]:nHAlign  := DT_CENTER

     nI := oBrw:nColumn("KR1", .T.)
     :aColumns[nI]:lBitMap  := .T.           // убрать показ значений поля из колонки
     :aColumns[nI]:nWidth   := :Cargo:nHImg  // ширина колонки как у картинки
     /*
     :aColumns[nI]:aBitMaps := { LoadImage("bFCalc32",,nHChk,nHChk) , LoadImage("bFCSV32",,nHChk,nHChk)  ,;
                                LoadImage("bFExcel32",,nHChk,nHChk), LoadImage("bFText32",,nHChk,nHChk) ,;
                                LoadImage("bFWord32",,nHChk,nHChk) , LoadImage("bFZero32",,nHChk,nHChk) }
     :aColumns[nI]:uBmpCell := {|nc,ob|
                                Local ocol  := ob:aColumns[nc]
                                Local ni    := 0                      // bFZero32
                                Local nMax  := LEN(ocol:aBitMaps)     // bFZero32
                                Local nCode := ob:GetValue("PRIXOD")  // колонка коды типа файлов
                                //? ProcName(), nCode, ocol:cName, ocol:cField
                                //nCode := FIELDGET(FIELDNUM(ocol:cField))  // можно и так
                                IF !IsNumeric(nCode)
                                   nCode := 0
                                ENDIF
                                IF nCode <= 0 .OR. nCode >= nMax
                                   ni := nMax
                                ELSE
                                   ni := nCode
                                ENDIF
                                Return ocol:aBitMaps[ni]              // картинку с позиции массива
                              } */
     :aColumns[nI]:aBitMaps := :Cargo:aBmp6[2]
     :aColumns[nI]:uBmpCell := :Cargo:aBmp6[3]
     :aColumns[nI]:nAlign   := nMakeLong( DT_CENTER, DT_CENTER )
     :aColumns[nI]:nHAlign  := DT_CENTER
     //:aColumns[nI]:bData    :=  {||Nil}
     //:aColumns[nI]:cData    := '{||Nil}'

   END WITH

RETURN Nil

////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbColor( oBrw )
   LOCAL nCol, oCol, O, aBClr, nBClr, nGrad

   aBClr := { 49, 177, 255 }               // цвет фона таблицы
   nBClr := RGB(49, 177, 255)              // цвет фона под таблицей
   nGrad := RGB(48,29,26)                  // градиент

   WITH OBJECT oBrw:Cargo
      // строки создание переменных
      :nBtnText   :=  GetSysColor( COLOR_BTNTEXT )      // nClrSpecHeadFore
      :nBtnFace   :=  GetSysColor( COLOR_BTNFACE )      // nClrSpecHeadBack
      :nBClrSpH   :=  GetSysColor( COLOR_BTNFACE )      // nClrSpecHeadBack
      // мои цвета в таблице
      :nClrSilver := RGB(207,205,205)                   // светло-серый
      //:nClrBC   := RGB(183,221,232)                   // цвет фона таблицы
      :nClrBC     := nBClr                              // цвет фона таблицы
      :nClrPrc    := RGB(240,240,240)                   // строка % 2
      //:nClrPrc  := RGB(aBClr[1],aBClr[2],aBClr[3])    // строка % 2
      :nClrErr    := RGB(192,0,255)                     // фиолетовый - цвет разницы
      :nClrTxt    := CLR_BLACK                          // цвет текста в ячейке таблицы
      :nClrTxt2   := CLR_WHITE                          // цвет текста в ячейке при ошибке
      :nClrMinus  := CLR_HRED                           // цвет текста в ячейке при ошибке
      :nHead2     := nBClr                              // подвал и шапка таблицы
      :nHead1     := RGB(48,29,26) //RGB(18,236,48)     // подвал и шапка таблицы
      //:nClr16   := {RGB(0,176,240),RGB(60,60,60)}     // 16, фона спецхидер
      //:nClr16   := {RGB(40,110,212),RGB(0,176,240)}   // 16, фона спецхидер
      :nClr16     := {:nHead1,:nHead2}                  // 16, фона спецхидер
      :nClr17     := CLR_YELLOW                         // 17, текста спецхидер
      :nClr16All  := {:nHead1,:nClrErr}                 // 16, фона спецхидер все записи
      :nClr16Del  := {:nHead1,CLR_BLUE}                 // 16, фона спецхидер удалённые записи
      :nClr16New  := {:nHead1,CLR_ORANGE}               // 16, фона спецхидер список по записям
      //:nClrLine   := aStaticLineColorTsb              // строка с "------"
      :aClrBrush  := { 176, 222, 251 }                 // цвет фона под таблицей
  END WITH

   WITH OBJECT oBrw
      O := :Cargo
      :nClrLine              := RGB(180,180,180)                 // COLOR_GRID
      :SetColor( {  1 }, { { || CLR_BLACK               } } )    // 1 , текста в ячейках таблицы
      :SetColor( {  2 }, { { || O:nClrBC                } } )    // 2 , фона в ячейках таблицы
      :SetColor( {  3 }, { { || CLR_YELLOW              } } )    // 3 , текста шапки таблицы
      :SetColor( {  4 }, { { || { O:nHead2, O:nHead1 }  } } )    // 4 , фона шапка таблицы
      :SetColor( {  5 }, { { || RGB(0,0,0)              } } )    // 5 , текста курсора, текст в ячейках с фокусом
      :SetColor( {  6 }, { { |a,b,c| a:=nil, iif( c:nCell == b, -RGB(1,1,1), -CLR_HRED ) } } )  // 6 , фона курсора
      :SetColor( {  9 }, { { || CLR_YELLOW              } } )    // 9 , текста подвала таблицы
      :SetColor( { 10 }, { { || { O:nHead1, O:nHead2 }  } } )    // 10, фона подвала таблицы
      :SetColor( { 11 }, { { || RGB(0,0,0)              } } )    // 11, текста неактивного курсора (selected cell no focused)
      :SetColor( { 12 }, { { |a,b,c| a:=nil, iif( c:nCell == b, -CLR_HRED, -RGB(9,57,16) ) } } ) // 12, фона неактивного курсора (selected cell no focused)
      :hBrush  := CreateSolidBrush(o:aClrBrush[1], o:aClrBrush[2], o:aClrBrush[3])  // цвет фона под таблицей
      // задать цвета суперхидеру
      //:SetColor( {16}, { O:nClr16  } ) // 16, фона спецхидер
      :SetColor( { 16 }, { { || { O:nHead2, O:nHead1 }  } } )
      :SetColor( { 17 }, { O:nClr17  } ) // 17, текста спецхидер
   END WITH

   // изменим цвет колонки - своя виртуальная колонка / own virtual column
   oBrw:GetColumn("ORDKEYNO"):nClrBack     := oBrw:Cargo:nBtnFace
   oBrw:GetColumn("ORDKEYNO"):nClrFootBack := CLR_WHITE
   oBrw:GetColumn("ORDKEYNO"):nClrFootFore := CLR_BLACK
   oBrw:GetColumn("KR2"     ):nClrBack     := CLR_WHITE   // колонка с картинками
   oBrw:GetColumn("KR1"     ):nClrBack     := CLR_WHITE   // колонка с картинками
   oBrw:GetColumn("PUSTO"   ):nClrBack     := CLR_YELLOW  // колонка по scope
   oBrw:GetColumn("DOCUM"   ):nClrBack     := CLR_HGRAY   // колонка № документа оплаты

   FOR EACH oCol IN oBrw:aColumns
      IF oCol:Cargo:lTotal
         oBrw:GetColumn(oCol:cName):nClrFootBack := CLR_WHITE
         oBrw:GetColumn(oCol:cName):nClrFootFore := CLR_BLACK
      ENDIF
      oCol:nClrEditFore := CLR_HBLUE                 // цвет фонта ячейки при редактировании
      oCol:nClrEditBack := HMG_RGB2n(239,247,152)    // цвет фона ячейки при редактировании
   NEXT

   FOR nCol := 1 TO Len(oBrw:aColumns)
       oCol := oBrw:GetColumn(nCol)
       IF oCol:cName $ "ORDKEYNO,KR2,KR1,DOCUM,PUSTO"
          LOOP
       ENDIF
       // закраска всех строк в таблице
       oCol:nClrBack := {|nv,nc,ob|
                          Local oc, nClr
                          Local o := ob:Cargo             // относительная адресация
                          Local nClrPrc := o:nClrPrc        // строка % 2
                          Local nClrBC  := o:nClrBC         // цвет фона таблицы
                          Local nClr_1  := o:nBtnFace
                          Local lDel    := (ob:cAlias)->(DELETED())
                          oc  := ob:GetColumn(nc)
                          nClr := nv
                          // доп.проверка
                          If nc == 1
                             nClr := nClr_1
                          ElseIf nc == 3
                             nClr := CLR_WHITE
                          Else
                             nClr := iif( ob:nAt % 2 == 0, nClrPrc, nClrBC )
                          Endif
                          // это правило действует всегда
                          IF lDel                // удалена ли запись ?
                             nClr := CLR_BLUE
                          ENDIF
                          Return nClr
                          }
       // ставим цвет по условию сравнения
       oCol:nClrFore := {|nv,nc,ob|
                          Local o := oBrw:Cargo        // относительная адресация
                          Local nClr0 := o:nClrTxt     // цвет текста в ячейке таблицы
                          Local nClr2 := o:nClrMinus   // цвет текста при минусе
                          Local lDel  := (ob:cAlias)->(DELETED())
                          Local oc, nClr, nSum
                          oc   := ob:GetColumn(nc)
                          nv   := ob:GetValue(nc)
                          nSum := ob:GetValue("PRIXOD")  // колонка суммы
                          nClr := iif( nSum >= 0 , nClr0, nClr2 )
                          // это правило действует всегда
                          IF lDel                // удалена ли запись ?
                             nClr := CLR_YELLOW
                          ENDIF
                          Return nClr
                          }
   NEXT

RETURN Nil

///////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbFont( oBrw )
   LOCAL hFont, nI, oCol

   hFont := oBrw:aColumns[1]:hFontSpcHd  // 4-special header font
   // установить фонт для 1 колонки таблицы
   oBrw:aColumns[1]:hFont := hFont     // 1-cells font

    // фонты для колонок 3-4 таблицы, остальные не надо
   For nI := 2 To 5  //oBrw:nColCount()
      oCol       := oBrw:aColumns[ nI ]
      oCol:hFont := {|nr,nc,ob| // фонты для строк таблицы
                      Local nGet, xv
                      nGet := ob:GetValue("PRIXOD") // колонка сумма
                      xv   := ob:GetValue(nc)
                      //? "**** ob:aColumns["+HB_NtoS(nc)+"]", nr, nc, xv, nGet
                      //!!! nr := ob:aColumns[ nc ]:hFont   // GetFontHandle( "Normal" )
                      nr := ob:hFont
                      IF nGet < 0   // минусовая сумма
                         nr := oBrw:aColumns[nc]:hFontHead
                      ENDIF
                      //IF "---" $ cval
                      //    nr := ob:Cargo:hTsbBold4 // GetFontHandle( "Bold" )
                      //ENDIF
                      Return nr
                      }
   Next

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsbSuperHd( oBrw )
   LOCAL hFont, nHFont, aSupHd
   LOCAL o := oBrw:Cargo      // использовать из контейнера свои переменные

   hFont  := oBrw:hFontSupHdGet(1)
   nHFont := GetTextHeight( 0, "B", hFont )
   aSupHd := o:aSupHd

   WITH OBJECT oBrw
      // Создаём СУПЕРХИДЕР в таблице размером 0
      :AddSuperHead( 1, :nColCount(), "Super_Header_Table" ) //,,, .F.,,, .F., .F., .F., 0, )
      :aSuperhead[ 1, 3 ] := aSupHd[1]
      :nHeightSuper := nHFont * 3      // 3 строки
      // задать цвета суперхидеру
      :SetColor( {16}, { O:nClr16  } ) // 16, фона спецхидер
      :SetColor( {17}, { O:nClr17  } ) // 17, текста спецхидер
   END WIDTH

   o:TitleSupHd := oBrw:aSuperhead[ 1, 3 ]    // запомнить
   o:ColorSupHd := O:nClr16                   // 16, фона спецхидер

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
// настройки редактирования
STATIC FUNCTION myTsbEdit( oBrw, oWnd )
   LOCAL i, oCol, aColPrc, aFunc1, aFunc2, aDim, nJ, nCol, cCol, nO, nS, nP
   LOCAL o := oBrw:Cargo      // использовать из контейнера свои переменные

   aColPrc := o:aColPrc           // тип обработки колонки
   aFunc1  := o:aFunc1            // функция-1 :bPrevEdit для обработки колонки таблицы
   aFunc2  := o:aFunc2            // функция-2 :bPostEdit для обработки колонки таблицы
   aDim    := o:aTable            // весь массив таблицы в cargo окна

   nP := 0
   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nP ++
      ENDIF
   NEXT
   // можно и так
   nO := IIF( oBrw:nColumn("ORDKEYNO", .T.) > 0, 1, 0) // проверка поля, если нет, то будет 0
   nS := IIF( oBrw:lSelector, 1, 0 )   // если есть/нет селектор
   nJ := nO + nS

   ? "======= " + ProcName() , oWnd:Name, "SELECTOR .OR. ORDKEYNO = ", nJ, "nO=",nO, nS, "nP=", nP
   FOR EACH oCol IN oBrw:aColumns
       i := hb_EnumIndex(oCol)
       IF oCol:cFieldTyp == "D" ; oCol:cPicture := NIL  // ОБЯЗАТЕЛЬНО !!! Иначе не будет ввода в дату
       ENDIF
       //? i, oCol:cName, oBrw:nCell
       //?? oCol:cField, oCol:cFieldTyp
       //?? oCol:nFieldLen
       //?? oCol:nFieldDec
       //?? ":aEdit=",oCol:lEdit
       //?? oCol:cPicture
       IF oCol:cName == "KR2"          // BMP
          oCol:lEdit := .F.
          oCol:nEditMove := DT_DONT_MOVE  // откл. перемещение курсора после :Edit()
       ELSE
          //oCol:nEditMove := DT_MOVE_RIGHT  // вкл. перемещение курсора после :Edit()
          oCol:bPrevEdit := {|xv,ob|
                              Local nc, oc, xGet, nAt, cNm, ni, cPrcs, lRet, cRun, nk, cStr
                              Local o := ob:Cargo     // берем из контейнера свои переменные
                              Local aColProcess := o:aColPrc      // тип обработки колонки
                              Local aRunFunc1   := o:aFunc1       // функция-1 :bPrevEdit
                              Local aDimTsb     := o:aTable       // весь массив таблицы
                              Local aVal, cMsg
                              Local nOrder := INDEXORD()
                              nc  := ob:nCell
                              oc  := ob:GetColumn( nc )
                              cNm := oc:cName
                              xv  := oc:Cargo
                              nAt := ob:nAt
                              nk  := IIF( oBrw:lSelector, 1, 0 )            // проверка селектора
                              nk  += IIF(ob:nColumn("ORDKEYNO", .T.)>0,1,0) // проверка поля
                              ni  := nc - nk            // тек.номер поиска в aColPrc[]
                              ? ":bPrevEdit",ProcNL(), "nc=", nc, "cNm=",cNm,oc:cPicture,"xv=", xv, "nAt=",nAt
                              xGet := ob:GetValue(nc)
                              ? ":bPrevEdit , xGet=", xGet, "INDEXORD()", nOrder
                              //? "   тек.номер поиска в aColPrc=", ni
                              //? "   =", HB_ValToExp(aDim[ni])
                              ////////////// обработка колонок по типам /////////////
                              cStr  := HB_ValToExp(aDimTsb[ni])
                              cPrcs := aColProcess[ni]   // тип обработки колонки
                              aVal  := { cNm, cPrcs, ni, aDimTsb[ni] }  // передать в функции
                              IF (ob:cAlias)->(RLock())      // то делать самому
                                 ob:Cargo:nModify ++  // была модификация таблицы
                                 IF cPrcs $ "CNDLM"
                                    ob:SetValue(cNm , xGet )
                                    lRet := .T.
                                 ELSEIF cPrcs $ "STKB"
                                    SET WINDOW THIS TO ob:cParentWnd  // ОБЯЗАТЕЛЬНО !!!
                                    ColumnEdit_STKB(ob,aVal)          // без параметров возврата
                                    SET WINDOW THIS TO
                                    //_PushKey( VK_RIGHT )   // сдвигаем курсор направо
                                    ob:GoRight()             // передвинуть курсор вправо
                                    lRet := .F.   // не давать редактировать поле в :get
                                 ELSE
                                    // функция для обработки колонки таблицы для типа "J"
                                    cRun := aRunFunc1[ni]
                                    SET WINDOW THIS TO ob:cParentWnd        // ОБЯЗАТЕЛЬНО !!!
                                    ColumnEdit_J(ob,ni,cRun,cNm,aVal,cStr)  // без параметров возврата
                                    SET WINDOW THIS TO
                                    //_PushKey( VK_RIGHT )   // сдвигаем курсор направо
                                    ob:GoRight()             // передвинуть курсор вправо
                                    lRet := .F.              // не давать редактировать поле в :get
                                 ENDIF
                              ELSE
                                 cMsg := "Recording is locked !; Recno="
                                 cMsg += HB_NtoS(RECNO()) + ";;" + ProcNL()
                                 AlertStop( cMsg )
                              ENDIF
                              (ob:cAlias)->(dbUnLock())
                              ob:Skip(0)
                              ob:DrawSelect()             // перерисовать текущую ячейку таблицы
                              DO EVENTS
                              ? ":bPrevEdit .end , lRet=", lRet, "INDEXORD()", nOrder
                              Return lRet
                             }

        oCol:bPostEdit := {|uVal,ob|
                              Local nc, oc, ni, cPrcs, cNm, cRun, xGet, nk
                              Local o := ob:Cargo     // берем из контейнера свои переменные
                              Local aColProcess := o:aColPrc      // тип обработки колонки
                              Local aRunFunc2   := o:aFunc2       // функция-2 :bPostEdit
                              Local aDimTsb     := o:aTable       // весь массив таблицы
                              Local aVal, cStr, lSay, xv
                              nc  := ob:nCell
                              oc  := ob:GetColumn(nc)
                              xv  := oc:Cargo
                              cNm := oc:cName
                              nk  := IIF( oBrw:lSelector, 1, 0 )            // проверка селектора
                              nk  += IIF(ob:nColumn("ORDKEYNO", .T.)>0,1,0) // проверка поля
                              ni  := nc - nk            // тек.номер поиска в aColPrc[]
                              ? ":bPostEdit",ProcNL(), oc:cName, "nc=", nc, "cNm=",cNm, "ni=", ni
                              xGet := ob:GetValue(nc)   // читаем поле
                              ? ":bPostEdit  , xGet=", xGet
                              ////////////// обработка колонок по типам
                              cStr  := HB_ValToExp(aDimTsb[ni])
                              aVal  := { cNm, cPrcs, ni, aDimTsb[ni] }  // передать в функции
                              cPrcs := aColProcess[ni]                  // тип обработки колонки
                              cRun  := aRunFunc2[ni]

                              SET WINDOW THIS TO ob:cParentWnd               // ОБЯЗАТЕЛЬНО !!!
                              ColumnEdit_bPost(ob,ni,cRun,cNm,aVal,cStr,oc)  // без параметров возврата
                              SET WINDOW THIS TO

                              ? ":bPostEdit  ,oc:Cargo:lTotal=",oc:Cargo:lTotal, "oc:xOldEditValue=",oc:xOldEditValue
                              lSay := .F.
                              IF oc:Cargo:lTotal .and. oc:xOldEditValue != uVal
                                 oc:Cargo:nTotal += uVal - oc:xOldEditValue
                                 lSay := .T.
                              ENDIF
                              ?? "oc:Cargo:nTotal=",oc:Cargo:nTotal
                              // послать сообщение на перепоказ ИТОГО в колонках
                              IF lSay ; _wPost("_ItogSay", ob:cParentWnd)
                              ENDIF

                              IF cPrcs $ "CNDLM"
                              ELSE
                                 //_PushKey( VK_RIGHT )   // сдвигаем курсор направо
                                 ob:GoRight()             // передвинуть курсор вправо
                              ENDIF
                              DO EVENTS
                              ? ":bPostEdit  .end", "INDEXORD()=", INDEXORD()
                              Return Nil
                             }
       ENDIF
   NEXT

RETURN NIL

///////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myTsb_Before( oBrw )
   LOCAL nLen, cBrw, nTsb

   WITH OBJECT oBrw
      // обработка клавиш
      /*
      :UserKeys(VK_SPACE, {|ob|
                           Local lRet := .T., lval, cval
                           ob:Cargo:nModify ++  // была модификация таблицы
                           IF ob:nCell == 2
                              lval := ob:GetValue( ob:nCell )
                              cval := ob:GetValue( ob:nCell + 1 )
                              IF ! "---" $ cval
                                 ob:SetValue( ob:nCell, ! lval )
                                 ob:DrawSelect()
                                 DO EVENTS
                                 lRet := .F.
                              ENDIF
                           ENDIF
                           Return lRet
                           })
      :UserKeys(VK_RETURN, {|ob|
                            Local lRet := .T.
                            ob:Cargo:nModify ++  // была модификация таблицы
                            IF ob:nCell == 2
                               DO EVENTS
                               ob:PostMsg( WM_KEYDOWN, VK_SPACE, 0 )
                               lRet := .F.
                            ENDIF
                            Return lRet
                            })
      // обработка мышки
      :bLDblClick := {|p1,p2,p3,ob| p1:=p2:=p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }

      // колонка с нестандартным чекбоксом
      // т.к. колонка 2 это не CheckBox, выражение логическое, то тсб меняет лог.значение
      //  на текст из массива oBrw:aMsg, там языковые значения {"Да", "Нет" ...}
      IF hb_IsArray( :aMsg ) .and. Len( :aMsg ) > 1
         :aMsg[1] := ""
         :aMsg[2] := ""
      ENDIF
      */
      :SetAppendMode( .F. )    // запрещена вставка записи в конце базы стрелкой вниз
      //oBrw:SetDeleteMode( .T., .F. )
      //oBrw:SetDeleteMode( .T., .T. ) // стандартный запрос на удаление
      // меню для удаления, будет работать и на восстановление
      :SetDeleteMode( .T., .F., {|| // меню для удаления
                                    Local lDel := (oBrw:cAlias)->(Deleted())
                                    Local cDel := "Удалить запись в таблице ?;;Delete a record in a table?"
                                    Local cIns := "Восстановить запись в таблице ?;;Restore a record in a table??"
                                    Local cMsg := "ВНИМАНИЕ / ATTENTION;;" + iif(lDel, cIns, cDel)
                                    Local cTtl := "Подтверждение/Confirmation"
                                    Local lRet, aClrs := { {45,223,70} , ORANGE }
                                    Local aTmp, aBClr, aFClr
                                    aBClr := {248,209,211}      // светло-красный
                                    aFClr := MAROON
                                    aTmp  := _SetMsgAlertColors(aBClr,aFClr)  // новые цвета
                                    lRet  := AlertYesNo( cMsg, cTtl, ,"ZZZ_B_STOP64", 64, aClrs )
                                    _SetMsgAlertColors(aTmp[1],aTmp[2])          // восстановить цвета
                                    Return lRet
                                } )
      // обработка клавиши ESC и других
      :UserKeys(VK_ESCAPE, {|ob| _wSend(99, ob:cParentWnd), .F.                        })
      //oMenu:aBtnPost  := { "_Help", "_Find", "_RecIns", "_RecDel", "_Print", "_Exit" }
      :UserKeys(VK_INSERT, {|ob| DoEvents(), _wPost("_RecIns", ob:cParentWnd, "BTN__RecIns"), .F. })
      :UserKeys(VK_DELETE, {|ob| DoEvents(), _wPost("_RecDel", ob:cParentWnd, "BTN__RecDel"), .F. })
      :UserKeys(VK_F7    , {|ob| DoEvents(), _wPost("_Find"  , ob:cParentWnd, "BTN__Find"  ), .F. })
      :UserKeys(VK_F5    , {|ob| DoEvents(), _wPost("_Print" , ob:cParentWnd, "BTN__Print" ), .F. })

      // инфо по списку колонок
      :UserKeys(VK_F2 ,  {|ob| myTsbListColumn( ob ), ob:Setfocus() })  // инфо по списку колонок
      :UserKeys(VK_F3 ,  {|ob| myTsbListFont( ob )  , ob:Setfocus() })  // инфо по фонтам таблицы
      :UserKeys(VK_F4 ,  {|ob| AlertInfo( myGetIndexUse() )  , ob:Setfocus() })  // инфо по индексам таблицы

      cBrw := :cControlName
      nTsb := This.&(cBrw).ClientWidth
      nLen := :GetAllColsWidth() - 1
      IF nLen > nTsb
         //:lAdjColumn  := .T.
         //:lNoHScroll  := .F.
         //:lMoreFields := ( :nColCount() > 45 )
      ELSE
         //:AdjColumns()
      ENDIF

   END WITH

RETURN Nil

//////////////////////////////////////////////////////////////////////////////
// новая запись в базе добавляется в конец базы и переходим сразу к редактированию
STATIC FUNCTION RecnoInsert(oWnd,nPost,cBtn,oBrw)
   LOCAL nTime := VAL(SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2))
   LOCAL nRecno, cMsg, aTmp, aBColor, aFColor, aColors

   ? ProcName()+"():", "oWnd:", oWnd:Name, nPost, cBtn, oBrw:ClassName

   IF oBrw:Cargo:lRecINS              // блокировка клавиши INS
      RETURN NIL
   ENDIF

   IF LEN(ALLTRIM(oBrw:Cargo:cMaska)) == 0
      cMsg := "ОШИБКА !;;"
      cMsg += "Не заполнена МАСКА-ВВОДА ,;"
      cMsg += "графа: № документа оплаты ;"
      cMsg += 'Необходимо заполнить её !'
      cMsg += "ERROR!;;"
      cMsg += "INPUT-MASK not filled in ,;"
      cMsg += "column: payment document no. ;"
      cMsg += 'You need to fill it in!'
      AlertStop( cMsg, "ВНИМАНИЕ" )
      RETURN NIL
   ENDIF

   cMsg    := "ВНИМАНИЕ !;;Вставить запись в таблицу ? "
   cMsg    += "ATTENTION!;;Insert a record into the table ? "
   aColors := { {45,223,70} , ORANGE }
   aBColor := { 238, 249, 142 }   // светло-жёлтый
   aFColor := BLACK
   aTmp    := _SetMsgAlertColors(aBColor,aFColor)  // новые цвета

   IF AlertYesNo( cMsg, "Добавление записи / Adding recno", , , 64, aColors )
      // срабатывает сразу при добавлении записи
      // добавить в поле дату+время вставки записи
      oBrw:bAddAfter := {|ob,ladd|
                          Local cMaska := App.Cargo:oIni:MAIN:cMaska // МАСКА ввода из ини-файла
                          Local cRecno := HB_NtoS( (ob:cAlias)->( RecNo() ) )
                          If ladd
                             ? "+++ :bAddAfter",ProcNL(), "INDEXORD()=", INDEXORD()
                             ?? "RecNo()= " + cRecno
                             (ob:cAlias)->KOPERAT   := M->nOperat   // кто изменил запись
                             (ob:cAlias)->DATEVVOD  := DATE()       // Дата/время правки
                             (ob:cAlias)->TIMEVVOD  := nTime
                             (ob:cAlias)->KOPERAT0  := M->nOperat   // создатель записи
                             (ob:cAlias)->DATEVVOD2 := DATE()       // Дата/время создания
                             (ob:cAlias)->TIMEVVOD2 := TIME()
                             (ob:cAlias)->CVVOD2    := '22'             // ручной ввод оператора
                             //(ob:cAlias)->DOCUM   := ob:Cargo:cMaska  // No документа оплаты
                             (ob:cAlias)->DOCUM     := cMaska           // No документа оплаты
                             (ob:cAlias)->BOX       := "/"+cRecno       // просто для примера
                             (ob:cAlias)->( dbSkip(0) )
                          EndIf
                          Return Nil
                        }

      // oBrw:bAddAfter  := Nil  // это если не нужен код заполнения полей при создании новой записи

      // встроенный метод для добавления записи
      oBrw:AppendRow(.T.)

      nRecno := (oBrw:cAlias)->( RecNo() )
      IF (oBrw:cAlias)->(RLock())
         // если нужна запись в базу даты+время для этих действий (сделано выше)
         //(oBrw:cAlias)->IM        := hb_DateTime()    // когда изменили запись
         //(oBrw:cAlias)->KOPERAT   := M->nOperat       // кто изменил запись - резерв
         //(oBrw:cAlias)->DATEVVOD  := DATE()
         //(oBrw:cAlias)->TIMEVVOD  := nTime
         (oBrw:cAlias)->(DbCommit())
         (oBrw:cAlias)->(DBUnlock())
         ? "+++ " + ProcNL(), "INDEXORD()=", INDEXORD(), "RecNo()=", nRecno
      ENDIF

      nRecno := (oBrw:cAlias)->( RecNo() )
      ? "+++ " + ProcNL(), hb_DateTime(), "Insert!", "RecNo()=", nRecno

      oBrw:nCell := oBrw:nColumn("PRIDAT", .T.)  // в начало колонок для редактирования
      oBrw:Reset()
      //oBrw:Refresh(.T.,.T.)
      oBrw:GoBottom()     // всегда на новую запись учитывая что делаем: 'DTOS(DATEVVOD2)+TIMEVVOD2'
      DO EVENTS

   ENDIF

   _SetMsgAlertColors(aTmp[1],aTmp[2])      // восстановить цвета

RETURN Nil

//////////////////////////////////////////////////////////////////////////
STATIC FUNCTION RecnoDelete(oWnd,nPost,cBtn,oBrw)
   LOCAL lChange, nAt, lDelete, nRecno, nCell, nMetod, nRec
   LOCAL aSumm, oCol, nCol, nSum, cFld

   ? " -Del- "+ProcNL(), "oWnd:", oWnd:Name, nPost, cBtn, oBrw:ClassName
   ?? ":nLen=", oBrw:nLen //,":lIsXXX=", oBrw:lIsDbf, oBrw:lIsArr
   ?? ":nRowPos=", oBrw:nRowPos

   IF oBrw:nLen == 0        // нет записей в таблице
      RETURN Nil
   ENDIF

   IF oBrw:Cargo:lRecDEL    // блокировка клавиши DEL
      RETURN NIL
   ENDIF

   // сохраним сумму для колонок итого
   aSumm := ARRAY( LEN(oBrw:aColumns) )
   AFILL( aSumm, 0 )
   FOR EACH oCol IN oBrw:aColumns
      nCol := hb_EnumIndex(oCol)
      //? nCol, oCol:cName
      IF oCol:cName == "SELECTOR"     ; LOOP
      ELSEIF oCol:cName == "ORDKEYNO" ; LOOP
      ENDIF
      IF oCol:Cargo:lTotal
         //?? oCol:Cargo:lTotal, oCol:Cargo:nTotal
         cFld := oCol:cName
         //aSumm[nCol] := (oBrw:cAlias)->&cFld
         aSumm[nCol] := oBrw:GetValue(oCol:cName)
      ENDIF
   NEXT

   // срабатывает сразу при удалении записи
   oBrw:bDelAfter := {|nr,ob|
                             Local cAls := ob:cAlias
                             Local nOld := (cAls)->( RecNo() )
                             Local cVal := SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2)
                             Local nTime := VAL( cVal )
                             //If (cAls)->( deleted() )
                             ? " -Del-  :bDelAfter" + ProcNL(), "nRecno=", nOld
                             ?? "INDEXORD()=", INDEXORD()
                             If (cAls)->( RLock() )
                                // если нужна запись в базу даты+время для этих действий
                                //If lDel ; (cAls)->DT_DEL  := hb_DateTime()
                                //Else    ; (cAls)->DT_REST := hb_DateTime()
                                //EndIf
                                (cAls)->KOPERAT  := M->nOperat  // кто удалил запись
                                (cAls)->DATEVVOD := DATE()      // когда удалили запись
                                (cAls)->TIMEVVOD := nTime
                                (cAls)->( DbUnLock() )
                                ?? "Write field: ", DATE(), nTime, M->nOperat
                                (cAls)->( dbSkip(0) )
                             EndIf
                             //EndIf
                             Return nr
                            }

   lDelete := (oBrw:cAlias)->( Deleted() )
   nRecno  := (oBrw:cAlias)->( RecNo() )
   nCell   := oBrw:nCell    // маркер на колонке таблицы
   nAt     := oBrw:nAt      // для массива - строка курсора на экране
   nAt     := oBrw:nRowPos  // для dbf     - строка курсора на экране
   ? " -Del-  lDelete=", lDelete, "nRecno=",nRecno

   nMetod := 0
   IF oBrw:lIsArr                 //  для массива
      ? " -Del- :nLen == :nAt", oBrw:nLen, oBrw:nAt
      IF oBrw:nLen == oBrw:nAt
         nMetod := 1  // это последняя запись
      ENDIF
   ELSEIF oBrw:lIsDbf            //  для dbf
      ? " -Del- ordKeyNo() == ordKeyCount()"
      ?? ordKeyNo(), ordKeyCount()
      IF ordKeyNo() == ordKeyCount()
         nMetod := 1  // это последняя запись
      ENDIF
      ?? ":nRowPos=", oBrw:nRowPos
   ENDIF
   ?? "nMetod=",nMetod

   // удаление/восстановление записи разрешена !!!
   // встроенный метод для удаления текущей записи
   lChange := oBrw:DeleteRow(.F., .T.)

   IF lChange                              // изменение было
      ? " -Del- " + ProcNL(), "lChange="+cValToChar(lChange), "переход! новая запись!"
      ?? "-> nMetod=" + HB_NtoS(nMetod)
      IF nMetod == 1        // это последняя запись в базе и таблице
         IF oBrw:lIsArr                   // для массива
            oBrw:Refresh(.T., .T.)
            nRec := oBrw:nLen
            oBrw:GoPos(nRec, nCell)
            ?? "переход :GoPos(:nLen=", nRec
         ELSEIF oBrw:lIsDbf               // для dbf
            (oBrw:cAlias)->( dbSkip(0) )
            oBrw:Reset()
            oBrw:Refresh(.T., .T.)
            oBrw:GoBottom()               // на последнюю запись
            nRec   := oBrw:nRowPos        // номер записи в таблице
            nRecno := (oBrw:cAlias)->( RecNo() )
            oBrw:GoToRec( nRecno )
            DO EVENTS
            ?? "переход :GoToRec()=", nRecno, ":nRowPos=",nRec
         ENDIF
      ELSE
         IF nAt == 1
            oBrw:Reset()
            oBrw:Refresh()
            nRecno += 1
         ENDIF
         oBrw:GoToRec( nRecno )
         ?? "GoToRec()=", nRecno
      ENDIF
      // минусуем итого удалённой записи
      FOR EACH oCol IN oBrw:aColumns
         nCol := hb_EnumIndex(oCol)
         //? nCol, oCol:cName
         IF oCol:cName == "SELECTOR"     ; LOOP
         ELSEIF oCol:cName == "ORDKEYNO" ; LOOP
         ENDIF
         IF oCol:Cargo:lTotal
            nSum := oCol:Cargo:nTotal
            oCol:Cargo:nTotal := nSum - aSumm[nCol]
            //?? oCol:Cargo:lTotal, oCol:Cargo:nTotal, "|"
            //?? nSum,"-",aSumm[nCol], "=", oCol:Cargo:nTotal
         ENDIF
      NEXT

      oBrw:DrawFooters()   // перересуем подвал
      DO EVENTS
      //запись в журнал-действий-пользователей-программы
      //write to the program-user-actions-log
   ELSE
      ?? "отмена удаления", lChange
   ENDIF

   DO EVENTS
   ? " -Del-  .end"

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
//  назначаем на шапку и подвал отдельную функцию и колонки таблицы
STATIC FUNCTION myTsbClick( oBrw )
   LOCAL oCol

   //  назначаем на суперхидер отдельную функцию ЭТО ДЕЛАЕМ ПОСЛЕ END TBROWSE
   FOR EACH oCol IN oBrw:aColumns
      // левая и правая кнопка мышки для шапки таблицы
      oCol:bHLClicked := {|Ypix,Xpix,nAt,ob| iif( Ypix > ob:nHeightSuper, ;
                           Tsb_Header(1,"Header!",Ypix,Xpix,nAt,ob) ,;
                           Tsb_SuperHd(1,"Super!",Ypix,Xpix,nAt,ob) ) }
      oCol:bHRClicked := {|Ypix,Xpix,nAt,ob| iif( Ypix > ob:nHeightSuper, ;
                           Tsb_Header(2,"Header!",Ypix,Xpix,nAt,ob) ,;
                           Tsb_SuperHd(2,"Super!",Ypix,Xpix,nAt,ob) ) }
      // левая и правая кнопка мышки для подвала и колонки таблицы
      oCol:bFLClicked := {|nrp,ncp,nat,obr| Tsb_Foot(1,obr,nrp,ncp,nat) }
      oCol:bFRClicked := {|nrp,ncp,nat,obr| Tsb_Foot(2,obr,nrp,ncp,nat) }
      //oCol:bLClicked:= {|nrp,ncp,nat,obr| Tsb_Cell(1,obr,nrp,ncp,nat) }
      oCol:bRClicked  := {|nrp,ncp,nat,obr| Tsb_Cell(2,obr,nrp,ncp,nat) }
      // настройка для SpecHd таблицы
      oCol:bSLClicked := {|nrp,ncp,nat,obr| Tsb_SpcHd(1,nrp,ncp,nat,obr) }
      oCol:bSRClicked := {|nrp,ncp,nat,obr| Tsb_SpcHd(2,nrp,ncp,nat,obr) }
   NEXT

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_Foot( nClick, oBrw, nRowPix, nColPix, nAt )
   LOCAL nRow  := oBrw:GetTxtRow(nRowPix)       // номер строки курсора в таблице
   LOCAL nCol  := Max(oBrw:nAtCol(nColPix), 1)  // номер колонки курсора в таблице
   LOCAL nCell := oBrw:nCell                    // номер ячейки в таблице
   LOCAL cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   LOCAL cMs, cRW, cCV, xVal, cMsg, cCol

   cMs  := "Mouse y:x = " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix)
   cRW  := "Cell position row/column: " + hb_ntos(nAt) + '/' + hb_ntos(nCell)
   xVal := oBrw:GetValue(nCell)
   cCV  := "Get cell value: [" + cValToChar(xVal) + "]"
   cCol := "Columns: " + oBrw:aColumns[nCol]:cName
   cMsg := cNam + ";" + cMs + ";" + cRW + ";" + cCV + ";" + cCol
   AlertInfo(cMsg,"Footer Table")

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_Cell( nClick, oBrw, nRowPix, nColPix )
   LOCAL cNam, cForm, Font1, Font2, Font3, cStr, nRow2, nCol, cVal, cNmCol, cFldTp
   LOCAL cCel1, cCel2, cCel3, cCel4, cMsg, cType, xVal, nRow, nI, aDim, cField

   Font1  := GetFontHandle( "ComSanMS" )
   Font2  := GetFontHandle( "Bold"     )
   Font3  := GetFontHandle( "ItalBold" )
   cForm  := oBrw:cParentWnd
   nRow   := oBrw:GetTxtRow(nRowPix)        // номер строки курсора в таблице
   nCol   := Max(oBrw:nAtCol(nColPix), 1)   // номер колонки курсора в таблице
   nRow2  := oBrw:nAt                       // номер строки в таблице
   cMsg   := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cNam   := {'Left mouse', 'Right mouse'}[ nClick ]
   xVal   := oBrw:GetValue(nCol)
   cType  :=  ValType(xVal)
   cCel1  := "Cell position row/column: " + hb_ntos(nRow2) + '/' + hb_ntos(nCol)
   cCel2  := "Type Cell: " + cType
   IF cType == "C"
      cCel3 := "Get Cell value: [" + ALLTRIM(xVal) + "]"
      cVal  := xVal
   ELSE
      cCel3 := "Get Cell value: [" + ALLTRIM(cValToChar(xVal)) + "]"
      cVal  := cValToChar(xVal)
   ENDIF
   cNmCol := oBrw:aColumns[nCol]:cName
   cCel4  = "Columns: " + cNmCol
   // получаем имя поля БД
   aDim   := oBrw:Cargo:aTable              // весь массив колонок таблицы в cargo окна
   nI     := nCol - IIF( oBrw:nColumn("ORDKEYNO", .T.) > 0, 1, 0)  // проверка поля, если нет, то будет 0
   nI     := nI   - IIF( oBrw:lSelector, 1, 0 )                    // если есть/нет селектор
   // {1, "R", "+", "ID recno", "IDP", "999999999", "99999999", NIL, NIL, NIL}
   cField := aDim[nI,5]  // поле бд для колонки
   cFldTp := aDim[nI,3]  // тип для колонки

   cStr := cNam + CRLF + cMsg  + CRLF + cCel1 + CRLF
   cStr += cCel2 + CRLF + cCel3 + CRLF + cCel4
   DEFINE CONTEXT MENU OF &cForm
      IF App.Cargo:cLang == "RU"
      Item "Показать значение ячейки"           ACTION {|| AlertInfo(cVal,"Значение ячейки")                    } ICON "iEdit64x2"  FONT Font1
      Item "Скопировать в буфер обмена"         ACTION {|| System.Clipboard := cVal /*xVal-нельзя!!!*/          } ICON "iEdit64x1"  FONT Font1
      Item "Вставить в ячейку из буфера обмена" ACTION {|| Cell_Clipboard(oBrw,cType,nCol,cNmCol,cField,cFldTp) } ICON "iEdit64x1"  FONT Font1
      Item "Очистить ячейку"                    ACTION {|| Cell_Delete(oBrw,cType,xVal,nCol,cField)             } ICON "iEdit64x1"  FONT Font1
      SEPARATOR
      Item "Показать инфо об ячейке"    ACTION {|| AlertInfo(cStr,"Инфо об ячейки")  } ICON "iEdit64x2"  FONT Font1
      Item "Скопировать в буфер обмена" ACTION {|| System.Clipboard := cStr          } ICON "iEdit64x1"  FONT Font1
      ELSE
      Item "Show cell value"              ACTION {|| AlertInfo(cVal,"Cell value")                         } ICON "iEdit64x2" FONT Font1
      Item "Copy to clipboard"            ACTION {|| System.Clipboard := cVal /*xVal-impossible!!!*/      } ICON "iEdit64x1" FONT Font1
      Item "Paste to cell from clipboard" ACTION {|| Cell_Clipboard(oBrw,cType,nCol,cNmCol,cField,cFldTp) } ICON "iEdit64x1" FONT Font1
      Item "Clear cell"                   ACTION {|| Cell_Delete(oBrw,cType,xVal,nCol,cField)             } ICON "iEdit64x1" FONT Font1
      SEPARATOR
      Item "Show cell info"    ACTION {|| AlertInfo(cStr,"Cell info") } ICON "iEdit64x2" FONT Font1
      Item "Copy to clipboard" ACTION {|| System.Clipboard := cStr    } ICON "iEdit64x1" FONT Font1
      ENDIF
   END MENU

   _ShowContextMenu(cForm, , , .f. ) // ПОКАЗ ВЫПАДАЕЩЕГО МЕНЮ

   InkeyGui(100)  // menu работает через очередь !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

RETURN Nil

//////////////////////////////////////////////////////////////////
STATIC FUNCTION Cell_Delete(oBrw,cType,xVal,nCol,cField)
   LOCAL nTime := VAL( SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) )
   LOCAL cFType, cMsg

   IF cType == "C"
      xVal := ""
   ELSEIF cType == "N"
      xVal := 0
   ELSEIF cType == "D"
      xVal := CTOD("")
   ELSEIF cType == "T" .OR. cType == "@"
      xVal := hb_CToT("")
   ELSEIF cType == "L"
      xVal := .F.
   ENDIF

   cFType := FieldType( FieldNum(cField) )
   IF cFType $ "+=^"   // Type field: [+] [=] [^]
      cMsg := "It is forbidden to edit this type of field: "
      cMsg += cField + " !;;"+ProcNL()
      AlertStop(cMsg)
   ELSE
      IF (oBrw:cAlias)->( RLock() )
         oBrw:SetValue(nCol, xVal)
         (oBrw:cAlias)->KOPERAT   := M->nOperat  // кто правил запись
         (oBrw:cAlias)->DATEVVOD  := DATE()      // дата правки
         (oBrw:cAlias)->TIMEVVOD  := nTime       // 9999 время правки
         (oBrw:cAlias)->( DbUnlock() )
         (oBrw:cAlias)->( DbCommit() )
      ELSE
         AlertStop("Recording is locked!")
      ENDIF
   ENDIF

   oBrw:DrawSelect()
   oBrw:SetFocus()

RETURN Nil

//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Cell_Clipboard(oBrw,cType,nCol,cNmCol,cField,cFldTp)
   LOCAL cFType, cMsg, xWrt, nTime, cClpb

   nTime  := VAL( SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) )
   xWrt   := System.Clipboard
   cClpb  := VALTYPE(xWrt)
   cFType := FieldType( FieldNum(cField) )
   //MsgDebug(cType,nCol,cField,"|",xWrt,"|",cFType,"cClpb=",cClpb)

   cMsg := "Не поддерживаемый формат при вставке !"
   cMsg += ";  Колонка: " + cNmCol + " тип: " + cFldTp
   cMsg += ";Поле в БД: " + cField + " тип: " + cFType
   cMsg += ";;Unsupported format when pasting! ;"
   cMsg += ";  Column: " + cNmCol + " type: " + cFldTp
   cMsg += ";Field DB: " + cField + " type: " + cFType
   cMsg += ";;"+ProcNL()
   IF cFldTp $ "SJKB"
      AlertStop(cMsg)
      RETURN NIL
   ELSEIF cFldTp == "BMP"
      AlertStop(cMsg)
      RETURN NIL
   ENDIF

   IF cFType == "L"
      xWrt := IIF(UPPER(xWrt)=="T",.T.,.F.)
   ELSE
      IF cType == cClpb
         // типы совпадают
      ELSEIF cType == "C" .AND. cClpb # "C"
         xWrt := cValToChar(xWrt)
      ELSEIF cType == "N" .AND. cClpb == "C"
         xWrt := VAL(xWrt)
      ELSEIF cType == "D" .AND. cClpb == "C"
         xWrt := CTOD(xWrt)
      ELSEIF cClpb # "T" .OR. cClpb == "@"
         xWrt := hb_CToT(xWrt)
      ELSE
         cMsg := "Не соответствие типов данных при вставке !"
         cMsg += ";  Колонка: " + cNmCol + " тип: " + cType
         cMsg += ";Поле в БД: " + cField + " тип: " + cFType
         cMsg += ";;Data type mismatch when inserting!"
         cMsg += "; Column: " + cNmCol + " type: " + cType
         cMsg += ";Field in the database: " + cField + " type: " + cFType
         cMsg += ";;"+ProcNL()
         AlertStop(cMsg)
         RETURN NIL
      ENDIF
   ENDIF

   IF cFType $ "M"
      // не трогаем
   ELSEIF cFType $ "C" .AND. CRLF $ xWrt
      xWrt := ATREPL( CRLF, xWrt, "|" )
      xWrt := ALLTRIM( xWrt )
   ENDIF

   IF cFType $ "+=^"   // Type field: [+] [=] [^]
      cMsg := "It is forbidden to edit this type of field: "
      cMsg += cField + " !;;"+ProcNL()
      AlertStop(cMsg)
   ELSE
      IF (oBrw:cAlias)->( RLock() )
         oBrw:SetValue(nCol, xWrt)
         (oBrw:cAlias)->KOPERAT   := M->nOperat  // кто правил запись
         (oBrw:cAlias)->DATEVVOD  := DATE()      // дата правки
         (oBrw:cAlias)->TIMEVVOD  := nTime       // 9999 время правки
         (oBrw:cAlias)->( DbUnlock() )
         (oBrw:cAlias)->( DbCommit() )
      ELSE
         AlertStop("Recording is locked!")
      ENDIF
   ENDIF

   oBrw:DrawSelect()
   oBrw:SetFocus()

RETURN Nil

/////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_Header(nClick,cMenu,nRowPix,nColPix,nAt,oBrw)
   LOCAL nCol, oCol, cName, cMouse, cPix, cCell, nCell, cMsg

   nCol   := Max(oBrw:nAtColActual( nColPix ), 1 )  // номер активной колонки курсора в таблице
   oCol   := oBrw:aColumns[ nCol ]
   nCell  := oBrw:nCell                              // номер ячейки в таблице
   cName  := "Columns: " + oCol:cName
   cMouse := {'Left mouse', 'Right mouse'}[ nClick ]
   cPix   := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cCell  := "nCell: " + HB_NtoS(nCell) + " nLine: " + HB_NtoS(nAt)
   cMsg   := cMouse + ";" + cMenu + ";" + cPix + ";" + cName + ";" + cCell

   AlertInfo(cMsg,"Header Table")

   oBrw:SetFocus()

RETURN NIL

////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Tsb_SuperHd(nClick,cMenu,nRowPix,nColPix,nAt,oBrw)
   LOCAL cForm, nCell, cCell, nCol, oCol, nRow, cName, cMouse, cPix, cMsg

   cForm  := oBrw:cParentWnd
   nRow   := oBrw:GetTxtRow(nRowPix)                 // НЕ ТО ! номер строки курсора в таблице
   nCol   := Max(oBrw:nAtColActual( nColPix ), 1 )   // номер активной колонки курсора в таблице
   nCell  := oBrw:nCell                              // номер ячейки в таблице
   oCol   := oBrw:aColumns[ nCol ]
   cName  := "Columns: " + oCol:cName
   cMouse := {'Left mouse', 'Right mouse'}[ nClick ]
   cPix   := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cCell  := "nCell: " + HB_NtoS(nCell) + " nLine: " + HB_NtoS(nAt)
   cMsg   := cMouse + ";" + cMenu + ";" + cPix + ";" + cName + ";" + cCell

   AlertInfo(cMsg,"Super Header Table")

   oBrw:SetFocus()

RETURN NIL

////////////////////////////////////////////////////////////////////////////
FUNCTION TitleSuperHider(cMaska,lSay)
   LOCAL cTtl
   DEFAULT lSay := .T.

   IF lSay 
      IF App.Cargo:cLang == "RU"
         cTtl := "Выборка: No документа оплаты = " + cMaska + CRLF
         cTtl += "Редактирование колонок - разрешено" + CRLF
         cTtl += "Сортировка по колонкам: Дата и время создания записи"
      ELSE
         cTtl := "Selection: Payment document No. = " + cMaska + CRLF
         cTtl += "Editing columns is allowed" + CRLF
         cTtl += "Sort by columns: Date and time of record creation"
      ENDIF
   ELSE
      IF App.Cargo:cLang == "RU"
         cTtl := cMaska + CRLF + "редактирование колонок - ЗАПРЕЩЕНО" + CRLF
         cTtl += "Внимание ! Для возврата ввода в таблицу: F7-поиск,"
         cTtl += " далее пунк меню: Переключиться на ввод"
      ELSE
         cTtl := cMaska + CRLF + "editing columns is PROHIBITED" + CRLF
         cTtl += "Attention! To return input to the table: F7-search,"
         cTtl += "next menu item: Switch to input"
      ENDIF
   ENDIF

RETURN cTtl

//////////////////////////////////////////////////////////////////////////////////
// обработка нумератора(спецхидера) таблицы
STATIC FUNCTION Tsb_SpcHd( nClick, nRowPix, nColPix, nAt, oBrw )
   LOCAL cForm, nRPos, nAtCol, cNam, cName, cMsg, cCnr, nCnr, cMsg0
   LOCAL oCol, nY, nX, cMsg1, cMsg2, cMsg3, cMsg4, nVirt, cCol, nCol
   LOCAL nClickRow := oBrw:GetTxtRow( nRowPix )

   cForm  := oBrw:cParentWnd
   nRPos  := oBrw:nRowPos
   nAtCol := Max( oBrw:nAtCol( nColPix ), 1 )  // номер колонки
   oCol   := oBrw:aColumns[ nAtCol ]
   cName  := oCol:cName
   nVirt  := 0
   cCnr   := ""
   nCnr   := 0
   nY     := GetProperty(cForm, "Row") + GetTitleHeight()
   nX     := GetProperty(cForm, "Col") + GetBorderWidth() - 4
   // возмём координаты от шапки таблицы
   nY     += GetMenuBarHeight() + oBrw:nTop + 2
   nY     += IIF( oBrw:lDrawSuperHd, oBrw:nHeightSuper , 0 )
   nY     += IIF( oBrw:lDrawHeaders, oBrw:nHeightHead  , 0 )
   nY     -= 1   //IIF( oBrw:lDrawSpecHd , oBrw:nHeightSpecHd, 0 )
   nX     += oCol:oCell:nCol
   nX     += IIF( oBrw:lSelector, oBrw:aColumns[1]:nWidth , 0 )  // если есть селектор
   nX     -= 5
   nX     := INT(nX)
   nY     := INT(nY)

   FOR nCol := 1 TO 3
      cCol := oBrw:aColumns[ nCol ]:cName
      IF cCol == "SELECTOR" .OR. cCol == "ORDKEYNO"
         nVirt ++
      ENDIF
   NEXT

   cMsg  := "Special Header - "
   cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   cMsg0 := cMsg + cNam
   cMsg1 := "Mouse  y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix)
   cMsg2 := "Head position y/x: " + hb_ntos(nY) + '/' + hb_ntos(nX)
   // номера колонок не совпадают с номерами полей в базе,
   // т.к. есть скрытые/удалённые колонки из таблицы см.функцию myBrwDelColumn()
   // нумерацию берем из нумератора таблицы
   //cCnr := oBrw:aColumns[ oBrw:nCell ]:cSpcHeading - так нельзя
   cCnr := oBrw:aColumns[ nAtCol ]:cSpcHeading
   nCnr := Val( cCnr )

   cMsg3 := "Column header: " + hb_ntos(nCnr) + "  [" + cName + "]"
   cMsg4 := "nAt=" + hb_ntos(nAt) + ", nAtCol=" + hb_ntos(nAtCol)
   cMsg4 += ", nClickRow=" + hb_ntos(nClickRow)
   cMsg  := cMsg0 + ";" + cMsg1 + ";" + cMsg2 + ";" + cMsg3 + ";" + cMsg4

   IF     cName == "SELECTOR"
   ELSEIF cName == "ORDKEYNO"
   ENDIF
   AlertInfo( cMsg, "Special Header Table" )

RETURN NIL

//////////////////////////////////////////////////////////////////////////////////
FUNCTION ColumnEdit_STKB(oBrw,aVal)
   LOCAL cMsg, aTyp, aDim, cFld, cAls, nClmn, aCntMn, aIcon, a2Dim, aSpr, aRet

   //{"NAME_14", "S", 14, {1, "W", "S", "Вид оплаты", "KOPLATA", "aaa..", "xxx...", "bKey12", {"Oplata", "KOplata", "Oplata", "Вид оплаты"}, NIL}}
   aTyp   := aVal[2]   // тип обработки
   nClmn  := aVal[3]   // номер колонки в массиве колонок Column_TSB()
   aDim   := aVal[4]   // полный массив колонки из Column_TSB()
   aCntMn := oBrw:Cargo:aCntMnu    // иконки для контекстного меню - тип "S"
   aIcon  := aCntMn[nClmn]
   cFld   := aDim[5]   // код поля для записи
   aSpr   := aDim[9]   // массив для базы
   cAls   := ALIAS()
   cMsg   := ProcNL(0) + ";" + ProcNL(1) + ";;"
   cMsg   += "Передано: " + oBrw:ClassName + " и "
   cMsg   += HB_ValToExp(aVal)  + ";;"
   cMsg   += 'Функция обработки типов: "S", "T", "K", "B" !;;'
   cMsg   += 'Type processing function: "S", "T", "K", "B" !;;'

   IF FIELDNUM(cFld) == 0
      cMsg := "ОШИБКА ! Нет поля [" + cFld + "] в БД-"
      cMsg += cAls + ";;"
      cMsg += "ERROR! There is no field [" + cFld + "] in DB-"
      cMsg += cAls + ";;"
      cMsg += ProcNL(0) + ";" + ProcNL(1)
      AlertStop(cMsg)
      RETURN NIL
   ENDIF

   IF aTyp == "S"
      // aSpr = {"Oplata","KOplata","Oplata","Вид оплаты","Name","cFilter"}
      a2Dim := myGetDbf2Dim(cAls,aSpr)
      aRet  := mySpavContexMenu(a2Dim,aSpr[4],aIcon,"ICO")
      IF LEN(aRet) > 0
         (cAls)->&cFld := aRet[1] // код в базу
      ENDIF
   ELSE
      myRunInfo(cMsg)
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ColumnEdit_J(ob,ni,cRun,cNm,aVal,cStr)  // без параметров возврата
   LOCAL cBlock, cMsg, xv, aRet

   IF IsArray(cRun)
      cRun := HB_ValToExp(cRun)
   ENDIF
   IF ! IsString(cRun)
      cRun := cValToChar(cRun)
   ENDIF
   //
   cRun   := SUBSTR(cRun,1,AT("(",cRun)-1)
   cBlock := cRun + "(" + HB_ValToExp(aVal) + ")"
   IF !hb_IsFunction( cRun )
      cMsg := ":bPrevEdit - колонка/column " + cNm + ";;"
      cMsg += "Функции: " + cRun + "()  нет в EXE-файле !;;"
      cMsg += "Строка: aDim[" + HB_NtoS(ni) + "];"
      cMsg += "Functions: " + cRun + "() not in the EXE file!;;"
      cMsg += "Line: aDim[" + HB_NtoS(ni) + "];"
      cMsg += cStr + ";;"
      cMsg += ProcNL( 0 ) + ";" + ProcNL( 1 )
      AlertStop( cMsg, "Ошибка запуска / Startup error !" )
   ELSE
      aRet := Eval( hb_macroBlock( cBlock ) )
      // Запись уже заблокирована
      // делаем обработку записи в базу
      cMsg := ":bPrevEdit - колонка/column " + cNm + ";;"
      cMsg += "Function: " + cRun + "() !;;"
      IF IsNumeric(aRet)
         xv := aRet
         IF xv >= 0  // изменения есть !
            ob:SetValue(cNm , xv )
            ?? " -->>  cNm=",cNm, "Write=", xv
         ENDIF
      ELSEIF IsArray(aRet)
         cMsg += "Возврат/Return = " + HB_ValToExp(aRet) + " !;;"
         cMsg += ProcNL( 0 ) + ";" + ProcNL( 1 )
         AlertInfo( cMsg, "Успех запуска / Launch success !" )
         ?? " -->>  cNm=",cNm, "Write=", xv
       ELSE
         cMsg += "ОШИБКА - возврат не массив {} !;"
         cMsg += "ERROR - return is not an array {} !;"
         cMsg += "aRet = " + cValToChar(aRet) + ";;"
         cMsg += ProcNL( 0 ) + ";" + ProcNL( 1 )
         AlertStop( cMsg, "Ошибка запуска / Startup error !" )
      ENDIF
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ColumnEdit_bPost(ob,ni,cRun,cNm,aVal,cStr,oc)  // без параметров возврата
   LOCAL cBlock, cMsg, aRet, lModify, xGet
   LOCAL nTime := VAL( SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2) )

   IF IsArray(cRun)
      cRun := HB_ValToExp(cRun)
   ENDIF
   IF ! IsString(cRun)
      cRun := cValToChar(cRun)
   ENDIF
   IF LEN(cRun) > 0
      cRun   := SUBSTR(cRun,1,AT("(",cRun)-1)
      cBlock := cRun + "(" + HB_ValToExp(aVal) + ")"
      IF !hb_IsFunction( cRun )
         cMsg := ":bPostEdit - колонка " + cNm + ";;"
         cMsg += "Функции: " + cRun + "()  нет в EXE-файле !;;"
         cMsg += "Строка: aDim[" + HB_NtoS(ni) + "];"
         cMsg += "Functions: " + cRun + "() not in the EXE file!;;"
         cMsg += "Line: aDim[" + HB_NtoS(ni) + "];"
         cMsg += cStr + ";;"
         cMsg += ProcNL(0) + ";" + ProcNL(1)
         AlertStop( cMsg, "Ошибка запуска / Startup error !" )
         aRet := {}
      ELSE
         aRet := Eval( hb_macroBlock( cBlock ) )
         // Запись уже заблокирована
         // делаем обработку записи в базу
         cMsg := ":bPrevEdit - колонка/column " + cNm + ";;"
         cMsg += "Function: " + cRun + "() !;;"
         IF IsArray(aRet)
            cMsg += "Возврат/Return = " + HB_ValToExp(aRet) + " !;;"
            cMsg += ProcNL(0) + ";" + ProcNL(1)
            //AlertInfo( cMsg, "Успех запуска !" )
          ELSE
            cMsg += "ОШИБКА - возврат не массив {} !;"
            cMsg += "ERROR - return is not an array {} !;"
            cMsg += "aRet = " + cValToChar(aRet) + ";;"
            cMsg += ProcNL(0) + ";" + ProcNL(1)
            AlertStop( cMsg, "Ошибка запуска / Startup error !" )
            aRet := {}
         ENDIF
      ENDIF
      IF LEN(aRet) > 0
         xGet := aRet[1]
         IF (ob:cAlias)->(RLock())      // то делать самому
            //?? " -->>  cNm=",cNm, "Write=", HB_ValToExp(aRet)
            ob:SetValue(cNm , xGet )    // запись в поле
            IF ( lModify := oc:xOldEditValue != xGet )  // modify value
               ob:Cargo:nModify ++  // была модификация таблицы
               //запись в журнал-действий-пользователей-программы
               //write to the program-user-actions-log
            ENDIF
         ELSE
            cMsg := "Запись заблокирована !;"
            cMsg += "Recno blocked !; Recno="
            cMsg += HB_NtoS(RECNO()) + ";;" + ProcNL()
            AlertStop( cMsg )
         ENDIF
         (ob:cAlias)->KOPERAT   := M->nOperat // кто правил запись
         (ob:cAlias)->DATEVVOD  := DATE()     // дата правки
         (ob:cAlias)->TIMEVVOD  := nTime      // 9999 время правки
         (ob:cAlias)->(dbUnLock())
         ob:Skip(0)
         ob:DrawSelect()    // перерисовать текущую ячейку таблицы
      ENDIF
   ENDIF

RETURN NIL
