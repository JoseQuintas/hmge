/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Общие функции для таблицы. Показ значений полей
 * General functions for the table. Show field values
*/

#include "hmg.ch"
#include "tsbrowse.ch"

///////////////////////////////////////////////////////////////////////////////////////
// построение таблицы
//      oTsb := oHmgData()
//      oTsb:aNumber   := { 1, 60 }
//      Добавить в тсб колонку нумерации строк (80 - ширина в pixel):
//     oTsb:aNumber   := { 1, 80 }
//                         ^ - означает перед первой колонкой сделать вставку
//     oTsb:aNumber   := { Len(aField), 80 }
//                         ^ - означает перед последней колонкой сделать вставку
//     oTsb:aNumber   := { 3, 80 }
//                         ^ - означает перед 3-ей колонкой сделать вставку
///////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////
FUNCTION myRunInfo(cInfo)
   LOCAL cForm, oWnd, oBrw, cMsg, bInit

   oBrw  := App.Cargo:oBrw     // запоминали ранее для внешних функций
   cForm := oBrw:cParentWnd    // имя окна
   // или можно так
   oWnd  := _WindowObj( GetActiveWindow() )  // окно в фокусе
   oBrw  := oWnd:Cargo:oBrw    // запоминали ранее на окне этот объект

   IF App.Cargo:cLang == "RU"   
      cMsg := "Здесь доступны объекты: oWnd и oBrw !;"
   ELSE
      cMsg := "Objects available here: oWnd and oBrw !;"
   ENDIF
   cMsg += oWnd:ClassName + " + " + oBrw:ClassName + ";"
   cMsg += oWnd:Name + " и " + oBrw:cAlias + ";"

   bInit := {|| // уменьшить ширину окна AlertInfo()
                Local ow, nw, nwbtn
                ow := _WindowObj( GetActiveWindow() )  // окно в фокусе
                nw := ow:ClientWidth * 0.75
                IF This.Width > nw
                   This.Width  := nw
                   This.Center
                   //DoMethod( ow:Name, "Center" )
                   nwbtn := This.Btn_01.Width
                   This.Btn_01.Col := nw - nwbtn - 20
                   This.Btn_01.SetFocus
                ENDIF
                DoEvents()
                Return Nil
               }

   AlertInfo(cInfo + cMsg, "INFO", , ,{ ORANGE }, , bInit )

RETURN NIL

/////////////////////////////////////////////////////////////////////
// aSpr = {"Oplata","KOplata","Oplata","Вид оплаты","Name",cFilter}
FUNCTION myGetDbf2Dim(cAlsMain,aSpr)
   LOCAL nOrder, cAls, cFld1, cFld2, cTtl, cOrd, cFltr
   LOCAL a2Ret, nVal, cVal, nI, lAdd

   cAls  := aSpr[1]
   cFld1 := aSpr[2]
   cFld2 := aSpr[3]
   cTtl  := aSpr[4]
   cOrd  := aSpr[5]
   cFltr := aSpr[6]   // фильтр по базе для показа
   a2Ret := {}
   // получаем 2х мерный массив из базы {код поля, наименивание поля}
   DbSelectArea(cAls)
   nOrder := INDEXORD()
   ORDSETFOCUS(cOrd)
   GOTO TOP
   FOR nI := 1 TO  ORDKEYCOUNT()
       ORDKEYGOTO(nI)
       IF !DELETED()
          IF LEN(cFltr)  > 0
             IF &cFltr  // условие отбора
                 nVal := FIELDGET(FIELDNUM(cFld1))
                 cVal := FIELDGET(FIELDNUM(cFld2))
                 lAdd := .T.
                 IF nVal == 0  ; lAdd := .F.
                 ENDIF
                 IF "---" $ cVal ; lAdd := .F.
                 ENDIF
             ENDIF
          ELSE
             nVal := FIELDGET(FIELDNUM(cFld1))
             cVal := FIELDGET(FIELDNUM(cFld2))
             lAdd := .T.
             IF nVal == 0  ; lAdd := .F.
             ENDIF
             IF "---" $ cVal ; lAdd := .F.
             ENDIF
          ENDIF
          IF lAdd
             AADD(a2Ret, { nVal, cVal } )
          ENDIF
       ENDIF
   NEXT
   DbSetOrder(nOrder)
   DbSelectArea(cAlsMain)

RETURN a2Ret

////////////////////////////////////////////////////////////////
FUNCTION mySpavContexMenu(a2Dim,cTitle,aIcon,cType)
   LOCAL Font1, Font2, Font3, cForm, nY, nX, oCol, oCell, aRet
   LOCAL oWnd, oBrw, cImg, aItem, nI, nChoice, nSize, aCode
   LOCAL cMenu, bAction, cName, lChk, lDis, lIcon

   aItem := {}
   aCode := {}
   FOR nI := 1 TO LEN(a2Dim)
      AADD( aCode, a2Dim[nI,1] )
      AADD( aItem, a2Dim[nI,2] )
   NEXT
   nSize := aIcon[1]
   cImg  := aIcon[2]
   Font1 := GetFontHandle( "Normal"   )
   Font2 := GetFontHandle( "Bold"     )
   Font3 := GetFontHandle( "ItalBold" )
   lIcon := IIF( "ICO" $ UPPER(cType), .T., .F. )

   oBrw  := App.Cargo:oBrw     // запоминали ранее для внешних функций
   cForm := oBrw:cParentWnd    // имя окна
   // или можно так
   oWnd  := _WindowObj( GetActiveWindow() )  // окно в фокусе
   oBrw  := oWnd:Cargo:oBrw    // запоминали ранее на окне этот объект
   // координаты вывода окна
   oCol  := oBrw:aColumns[ oBrw:nCell ]
   oCell := oBrw:GetCellInfo(oBrw:nRowPos)
   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nY    += oCell:nRow + oBrw:nHeightHead - 5
   nX    := GetProperty(cForm, "Col") + GetBorderWidth()
   nX    += oCell:nCol
   nX    -= 5

   SET MENUSTYLE EXTENDED        // переключить стиль меню на расширенный
   SetMenuBitmapHeight( nSize )  // установить размер иконок 32х32

   nChoice := -2              // обязательно, первоначальное значение
   DEFINE CONTEXT MENU OF &cForm

       MENUITEM  cTitle  DISABLED FONT Font3  ICON "iRHelp48x1"
       SEPARATOR

       FOR nI := 1 TO LEN(aItem)
          cMenu   := aItem[nI]
          cName   := StrZero(nI, 10)
          bAction := {|| nChoice := Val( This.Name ) }
          lChk    := .F.
          lDis    := .F.
          IF lIcon
             _DefineMenuItem( cMenu, bAction, cName,     , lChk, lDis, , Font1 , , .F., .F. , cImg, .F. )
          ELSE
             _DefineMenuItem( cMenu, bAction, cName, cImg, lChk, lDis, , Font1 , , .F., .F. )
          ENDIF
       NEXT

       SEPARATOR
       nI      := LEN(aItem) + 1
       cMenu   := IIF( App.Cargo:cLang == "RU", "удалить значение", "Delete value" )
       cImg    := oBrw:Cargo:aIconDel[2]   // иконка удалить значение
       cName   := StrZero(nI, 10)
       bAction := {|| nChoice := Val( This.Name ) }
       lChk    := .F.
       lDis    := .F.
       _DefineMenuItem( cMenu, bAction, cName, , lChk, lDis, , Font1 , , .F., .F. , cImg, .F. )

       //SEPARATOR
       //MENUITEM  "Exit"           ACTION  {|| nChoice := -1 } FONT Font3
   END MENU

   _PushKey( VK_DOWN )
   _ShowContextMenu(cForm, nY, nX, .f. ) // ПОКАЗ ВЫПАДАЕЩЕГО МЕНЮ

   InkeyGui(10)  // menu работает через очередь !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

   aRet := {}
   IF nChoice > 0
      IF nChoice > LEN(aItem)
         IF App.Cargo:cLang == "RU"
            aRet := {0,"удалить значение"}
         ELSE
            aRet := {0,"Delete value" }
         ENDIF
      ELSE
         aRet := {aCode[nChoice], aItem[nChoice]}
      ENDIF
   ENDIF

RETURN aRet

/////////////////////////////////////////////////////////////////////////
FUNCTION CheckDate(aVal)
   LOCAL aDim, cAls, cFld, dDate, cText, cMsg

   aDim  := aVal[4]
   cFld  := aDim[5]
   cAls  := ALIAS()
   dDate := (cAls)->&cFld

   IF M->nPubYear # YEAR(dDate)  // год открытия БД-PLAT20xx
      IF App.Cargo:cLang == "RU"
         cText := "ОШИБКА !;;"
         cText += "Год БД-Оплаты = " + HB_NtoS(M->nPubYear) + ";"
         cText += 'а Год графы "Дата прихода оплаты" = ' + HB_NtoS(YEAR(dDate)) + ";;"
         cText += 'Исправьте "Дата прихода оплаты: '+DTOC(dDate)+'" на правильный год !;'
         cText += 'ИЛИ внесите оплату в другой Год БД-Оплаты !'
         cMsg  := "ВНИМАНИЕ"
      ELSE
         cText := "ERROR!;;"
         cText += "DB-Payment Year = " + HB_NtoS(M->nPubYear) + ";"
         cText += 'a Year of the "Payment Receipt Date" column = ' + HB_NtoS(YEAR(dDate)) + ";;"
         cText += 'Correct "Payment due date: '+DTOC(dDate)+'" to the correct year!;'
         cText += 'OR pay in another DB-Payment Year!'
         cMsg := "ATTENTION"
      ENDIF
      AlertStop( cText, cMsg )
      (cAls)->&cFld := CTOD("")
   ENDIF

RETURN {}

////////////////////////////////////////////////////////////////
FUNCTION myImage()
   LOCAL Font1, Font2, Font3, cForm, nY, nX, oCol, oCell
   LOCAL oWnd, oBrw, aImg8, aBmp, aItem, nI, nChoice
   LOCAL cMenu, bAction, cName, cBmp, lChk, lDis

   oBrw  := App.Cargo:oBrw     // запоминали ранее для внешних функций
   cForm := oBrw:cParentWnd    // имя окна
   // или можно так
   oWnd  := _WindowObj( GetActiveWindow() )  // окно в фокусе
   oBrw  := oWnd:Cargo:oBrw    // запоминали ранее на окне этот объект
   aImg8 := oBrw:Cargo:aBmp6   // колонка 8 с картинками
   aBmp  := aImg8[1]           // картинки
   aItem := aImg8[4]           // меню
   Font1 := GetFontHandle( "Normal"   )
   Font2 := GetFontHandle( "Bold"     )
   Font3 := GetFontHandle( "ItalBold" )

   // координаты вывода окна
   oCol  := oBrw:aColumns[ oBrw:nCell ]
   oCell := oBrw:GetCellInfo(oBrw:nRowPos)
   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nY    += oCell:nRow + oBrw:nHeightHead
   nX    := GetProperty(cForm, "Col") + GetBorderWidth()
   nX    += oCell:nCol
   nX    -= 5

   SET MENUSTYLE EXTENDED     // переключить стиль меню на расширенный
   SetMenuBitmapHeight( 32 )  // установить размер иконок 32х32

   nChoice := -2              // обязательно, первоначальное значение
   DEFINE CONTEXT MENU OF &cForm

       FOR nI := 1 TO LEN(aBmp) - 1
          cMenu   := aItem[nI]
          cBmp    := aBmp[nI]
          cName   := StrZero(nI, 10)
          bAction := {|| nChoice := Val( This.Name ) }
          lChk    := .F.
          lDis    := .F.
          _DefineMenuItem( cMenu, bAction, cName, cBmp, lChk, lDis, , Font1 , , .F., .F. )
       NEXT

       SEPARATOR
       nI      := LEN(aBmp)
       cMenu   := aItem[nI]
       cBmp    := aBmp[nI]
       cName   := StrZero(nI, 10)
       bAction := {|| nChoice := Val( This.Name ) }
       lChk    := .F.
       lDis    := .F.
       _DefineMenuItem( cMenu, bAction, cName, cBmp, lChk, lDis, , Font1 , , .F., .F. )

       SEPARATOR
       MENUITEM  "Exit"           ACTION  {|| nChoice := -1 } FONT Font3
       /*
       MENUITEM  "File OO Calc"   ACTION  {|| nChoice := 1 }  FONT Font1  IMAGE "bFCalc32"
       MENUITEM  "File *.csv"     ACTION  {|| nChoice := 2 }  FONT Font1  IMAGE "bFCSV32"
       MENUITEM  "File *.txt"     ACTION  {|| nChoice := 4 }  FONT Font1  IMAGE "bFText32"
       MENUITEM  "File MS Excel"  ACTION  {|| nChoice := 3 }  FONT Font1  IMAGE "bFExcel32"
       MENUITEM  "File MS Word"   ACTION  {|| nChoice := 5 }  FONT Font1  IMAGE "bFWord32"
       SEPARATOR
       MENUITEM  "Delete value"   ACTION  {|| nChoice := 0 }  FONT Font2 IMAGE "bFZero32"*/
   END MENU

   _ShowContextMenu(cForm, nY, nX, .f. ) // ПОКАЗ ВЫПАДАЕЩЕГО МЕНЮ

   InkeyGui(10)  // menu работает через очередь !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

RETURN nChoice

/////////////////////////////////////////////////////////////////////////////////////
FUNCTION myTsbListColumn( oBrw )
   LOCAL oCol, nCol, cCol, cSize, cFld, cMsg, cTitle

   IF App.Cargo:cLang == "RU"
      cTitle := 'Инфо по списку колонок'
   ELSE
      cTitle := 'Info on the list of columns'
   ENDIF
   cMsg   := "Table alias: " + oBrw:cAlias + ";;"
   FOR nCol := 1 TO Len(oBrw:aColumns)
      oCol  := oBrw:aColumns[ nCol ]
      cCol  := oCol:cName
      cFld  := oCol:cField
      cSize := HB_NtoS( INT(oBrw:GetColSizes()[nCol]) )
      cMsg  += HB_NtoS(nCol) + ") " + cCol + " = " + cSize
      cMsg  += ' ( "'+ cFld + '", "'  + oCol:cFieldTyp + '" '
      cMsg  += HB_NtoS(oCol:nFieldLen)
      cMsg  += ',' + HB_NtoS(oCol:nFieldDec) + ' ) ;'
   NEXT
   cMsg += ";"
   FOR nCol := 1 TO Len(oBrw:aColumns)
      oCol  := oBrw:aColumns[ nCol ]
      cCol  := oCol:cName
      cFld  := cValToChar( oCol:cPicture )
      cMsg  += HB_NtoS(nCol) + ") " + cCol + " = "
      cMsg  += ' "'+ cFld + '"  ;'
   NEXT
   cMsg += REPL("; ",20)

   AlertInfo(cMsg , cTitle, , , {RED})

RETURN Nil

///////////////////////////////////////////////////////////////////////////////
FUNCTION myTsbListFont( oBrw )
   LOCAL cMsg, cTitle, aFont, nI, aFPar, hFont, cFont

   IF App.Cargo:cLang == "RU"
      cTitle := 'Инфо по фонтам таблицы'
   ELSE
      cTitle := 'Info on table fonts'
   ENDIF
   cMsg   := "Table alias: " + oBrw:cAlias + ";;"
   cMsg   += "     1-Cell: "+hb_valtoexp(GetFontParam(oBrw:hFont)) + ";"
   cMsg   += "     2-Head: "+hb_valtoexp(GetFontParam(oBrw:hFontHead )) + ";"
   cMsg   += "     3-Foot: "+hb_valtoexp(GetFontParam(oBrw:hFontFoot )) + ";"
   cMsg   += "    4-SpcHd: "+hb_valtoexp(GetFontParam(oBrw:hFontSpcHd)) + ";"
   cMsg   += "     5-Edit: "+hb_valtoexp(GetFontParam(oBrw:hFontEdit )) + ";"
   cMsg   += "  6-SuperHd: "+hb_valtoexp(GetFontParam(oBrw:hFontSupHdGet(1))) + ";;"

   aFont := oBrw:Cargo:aFont
   FOR nI := 1 TO Len(aFont)
      cFont := aFont[nI]
      hFont := GetFontHandle(cFont)
      aFPar := GetFontParam( hFont )
      cMsg  += "  " + HB_NtoS(nI) + ": "
      cMsg  += cFont + " - ["
      cMsg  += hb_ntos(hFont) + "] - "
      cMsg  += hb_valtoexp(aFPar) + ";"
   NEXT
   cMsg   += REPL("; ",10)

   AlertInfo(cMsg , cTitle, , , {RED})

RETURN Nil

////////////////////////////////////////////////////////////////
FUNCTION SeekAbonRc()
   LOCAL cMsg, aParams := hb_aParams()
   cMsg := ProcNL(0) + ";" + ProcNL(1) + ";;"
   IF App.Cargo:cLang == "RU"
   cMsg += "Передано: " + HB_ValToExp(aParams)  + ";;"
   cMsg += "Функция поиска по л/счёту в другой БД !;"
   cMsg += "Возврат и запись найденных данных из другой БД !;;"
   ELSE
   cMsg += "Transmitted: " + HB_ValToExp(aParams) + ";;"
   cMsg += "Search function for an account in another database!;"
   cMsg += "Return and write found data from another database!;;"
   ENDIF
   myRunInfo(cMsg)
RETURN {}

FUNCTION SeekAbonRc18()
   LOCAL cMsg, aParams := hb_aParams()
   cMsg := ProcNL(0) + ";" + ProcNL(1) + ";;"
   IF App.Cargo:cLang == "RU"
   cMsg += "Передано: " + HB_ValToExp(aParams)  + ";;"
   cMsg += "Функция поиска по л/счёту в другой БД !;"
   cMsg += "Возврат и запись найденных данных из другой БД !;;"
   ELSE
   cMsg += "Transmitted: " + HB_ValToExp(aParams) + ";;"
   cMsg += "Search function for an account in another database!;"
   cMsg += "Return and write found data from another database!;;"
   ENDIF
   myRunInfo(cMsg)
RETURN {}

FUNCTION myAdres()
   LOCAL cMsg, aParams := hb_aParams()
   cMsg := ProcNL(0) + ";" + ProcNL(1) + ";;"
   IF App.Cargo:cLang == "RU"
   cMsg += "Передано: " + HB_ValToExp(aParams)  + ";;"
   cMsg += "Функция ввода АДРЕСА плательщика !;;"
   ELSE
   cMsg += "Transmitted: " + HB_ValToExp(aParams) + ";;"
   cMsg += "Function for entering payer's ADDRESS!;;"
   ENDIF
   myRunInfo(cMsg)
   cMsg := IIF( App.Cargo:cLang == "RU", "Сделать обработку записи!", "Process the record!" )
RETURN {cMsg}

FUNCTION UserSay(nLen)
   LOCAL cRet, cAls := ALIAS()
   DEFAULT nLen := 20

   cRet := IIF( App.Cargo:cLang == "RU", "Оператор №: ", "User No.: " )
   cRet += HB_NtoS((cAls)->KOperat)
   cRet := PADR( cRet, nLen)

RETURN cRet

////////////////////////////////////////////////////////////
FUNCTION myFldTime()   // Дата/время правки
   LOCAL cAls := ALIAS(), cRet := DTOC((cAls)->DATEVVOD)+' '
   LOCAL cTime := HB_NToS( (cAls)->TIMEVVOD )

   cTime := PADL(cTime,4,"0")
   cTime := SUBSTR(cTime,1,2) + ":" + SUBSTR(cTime,3)
   cRet  += cTime

RETURN cRet

////////////////////////////////////////////////////////////
FUNCTION DimUsluga(nVal)
   LOCAL cRet, aDim

   IF App.Cargo:cLang == "RU"   
      aDim := {"за телефон","за антенну","за уборку","за домофон" }
   ELSE
      aDim := {"for telephone","for antenna","for cleaning","for intercom" }
   ENDIF

   IF nVal == 0
      cRet := "---"
   ELSEIF nVal > LEN(aDim) 
      cRet := "за ??? = " + HB_NtoS(nVal)
   ELSE
      cRet := aDim[nVal]
   ENDIF

RETURN cRet

////////////////////////////////////////////////////////////////////////
FUNCTION Vvod_Usluga()
   LOCAL Font1, Font2, Font3, cForm, nY, nX, oCol, oCell, aVal, cFld
   LOCAL oWnd, oBrw, nChoice, aDim, cAls, cMsg, aParams := hb_aParams()

   // ? ProcNL(), "aParams=",aParams ; ?v aParams
   // {"NAME_17", "J", 17, {1, "W", "J", "Оплата услуги", "KDMFANT", "aaa..a", "xxx..", "bKey17", "Vvod_Usluga()", NIL}}
   aVal  := aParams[1]         // массив колонки из Column_TSB()
   aDim  := aVal[4]            // массив значений
   cFld  := aDim[5]            // поле записи выбора
   cMsg  := aDim[4]

   oBrw  := App.Cargo:oBrw     // запоминали ранее для внешних функций
   cForm := oBrw:cParentWnd    // имя окна
   // или можно так
   oWnd  := _WindowObj( GetActiveWindow() )  // окно в фокусе
   oBrw  := oWnd:Cargo:oBrw    // запоминали ранее на окне этот объект
   cAls  := oBrw:cAlias
   Font1 := GetFontHandle( "Normal"   )
   Font2 := GetFontHandle( "Bold"     )
   Font3 := GetFontHandle( "ItalBold" )

   // координаты вывода окна
   oCol  := oBrw:aColumns[ oBrw:nCell ]
   oCell := oBrw:GetCellInfo(oBrw:nRowPos)
   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nY    += oCell:nRow + oBrw:nHeightHead - 5
   nX    := GetProperty(cForm, "Col") + GetBorderWidth()
   nX    += oCell:nCol

   SET MENUSTYLE EXTENDED     // переключить стиль меню на расширенный
   SetMenuBitmapHeight( 48 )  // установить размер иконок 32х32

   _PushKey( VK_DOWN )
   nChoice := -2              // обязательно, первоначальное значение
   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  cMsg                 DISABLED FONT Font3  ICON "iRHelp48x1"
       SEPARATOR
       IF App.Cargo:cLang == "RU"   
       MENUITEM  "За телефон"         ACTION  {|| nChoice := 1 }  FONT Font1  ICON "iVOTelef48"
       MENUITEM  "За антенну"         ACTION  {|| nChoice := 2 }  FONT Font1  ICON "iVOAnten48"
       MENUITEM  "Уборка территории"  ACTION  {|| nChoice := 3 }  FONT Font1  ICON "iVOMetla48"
       MENUITEM  "За домофон"         ACTION  {|| nChoice := 4 }  FONT Font1  ICON "iVODmfn48"
       SEPARATOR
       MENUITEM  "удалить значение"   ACTION  {|| nChoice := 0 }  FONT Font2  ICON "iDelVal48"
       ELSE
       MENUITEM  "for telephone"      ACTION  {|| nChoice := 1 }  FONT Font1  ICON "iVOTelef48"
       MENUITEM  "for antenna"        ACTION  {|| nChoice := 2 }  FONT Font1  ICON "iVOAnten48"
       MENUITEM  "for cleaning"       ACTION  {|| nChoice := 3 }  FONT Font1  ICON "iVOMetla48"
       MENUITEM  "for intercom"       ACTION  {|| nChoice := 4 }  FONT Font1  ICON "iVODmfn48"
       SEPARATOR
       MENUITEM  "remove value"   ACTION  {|| nChoice := 0 }  FONT Font2  ICON "iDelVal48"
       ENDIF
   END MENU

   _PushKey( VK_DOWN )
   _ShowContextMenu(cForm, nY, nX, .f. ) // ПОКАЗ ВЫПАДАЕЩЕГО МЕНЮ

   InkeyGui(10)  // menu работает через очередь !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   IF nChoice >= 0
      (cAls)->&cFld := nChoice
   ENDIF

   DO EVENTS

RETURN nChoice
