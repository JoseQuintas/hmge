/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"

REQUEST HB_CODEPAGE_UTF8, HB_CODEPAGE_RU866, HB_CODEPAGE_RU1251
REQUEST DBFNTX, DBFCDX, DBFFPT

#define SHOW_TITLE  "Testing columns + SUMMA in Tsbrowse for a dbf file"
#define LANG_PRG "EN"  // "EN" English interface-lang

FUNCTION Main()
   LOCAL cForm := "wMain", aBColor := ORANGE
   LOCAL cDbf, cAls  := "CUST1", cBrw  := "oBrw"
   LOCAL oBrw, oTsb, nY, nX, nG, nH, nW, o, owc, aClmn

   ? ProcNL(), "_SET_DELETED=", Set(_SET_DELETED) , App.Cargo:cLang
   IF !UseBase(cAls,@cDbf) ;  QUIT                      // -> demos_use.prg
   ENDIF
   DbSelectArea(cAls)
   ? myGetAllUse()     // Список открытых БД  / List of open databases
   ? myGetIndexUse()   // Список открытых индексов / List of open indexes
   // при создании TBrowse надо ставить правильный тэг индекса
   // TBrowse его удерживает, если не использовать привязку тэгов к колонкам
   OrdSetFocus("DOCDTV")   // ставим сразу здесь !!!

   nY := nX := 0   ; nG := 15
   nW := Sys.ClientWidth
   nH := Sys.ClientHeight

   DEFINE WINDOW &cForm AT nY, nX WIDTH nW HEIGHT nH TITLE SHOW_TITLE ;
      MAIN NOSIZE TOPMOST                                             ;
      BACKCOLOR aBColor                                               ;
      ON INIT    _wPost( 0)                                           ;
      ON RELEASE _wSend(90)

      This.Cargo := oHmgData() ; owc := This.Cargo  // для окна создаем объект без переменных (условно пустой)
      owc:aBColor := This.BackColor   // цвет окна
      owc:cDbf    := cDbf
      owc:nG      := nG
      owc:aFldSum := {}          // для подвала таблицы - итого
      owc:nCount  := {}
      owc:aItogo  := {}
      owc:cAls    := cAls

      nY := nX := nG
      nW := This.ClientWidth
      nH := This.ClientHeight

      oTsb := oHmgData()
      oTsb:aNumber   := { 1, 80 }
      oTsb:uSelector := 20
      aClmn          := Column_TSB( oTsb, cAls )    // список колонок таблицы  -> demo_tsb.prg
      owc:aClmn      := aClmn                       // сохраним на окне массив колонок
      // блоки кода для _TBrowse(...) - менять нельзя
      oTsb:bInit := {|ob,op| Column_Init(ob,op) , myTsbInit(ob,op)     }  // подготовка колонок
      oTsb:bBody := {|ob,op| myTsbEdit(ob,op)                          }
      //oTsb:bBody := {|ob,op| myTsbColor(ob,op), myTsbSuperHd(ob,op),;
      //                       myTsbEdit(ob,op), myTsb_Before(ob,op)   }  // другие настройки тсб
      oTsb:bEnd  := {|ob,op| myTsbEnd(ob,op)                           }  // блок кода после END TBROWSE

      // функция в библиотеке \MiniGUI\SOURCE\TsBrowse\h_controlmisc2.prg
      oBrw := _TBrowse( oTsb, cAls, cBrw, nY, nX, nW-nG*2, nH-nY-nG )

      // добавим для удобства доступа к массиву колонок
      IF oBrw:nColumn("ORDKEYNO", .T.) > 0
         aClmn := hb_AIns(aClmn, 1, {"ORDKEYNO"}, .T.)
      ENDIF
      IF oBrw:lSelector   // если есть селектор
         aClmn := hb_AIns(aClmn, 1, {"SELECTOR"}, .T.)
      ENDIF
      oBrw:Cargo:aDim := aClmn           // сохраним на окне массив колонок
      oBrw:Cargo:oWnd := This.Cargo      // Cargo окна запомнили на таблице
      App.Cargo:oBrw  := oBrw            // запомнили для внешних функций
      This.Cargo:oBrw := oBrw
      This.Cargo:cFrmHelp := "Form_Help"
      This.Cargo:lFrmHelp := .F.

      oBrw:SetFocus()

      ON KEY F1     ACTION NIL
      ON KEY ESCAPE ACTION ( iif( oBrw:IsEdit, oBrw:SetFocus(), _wPost(99) ) )

      o := This.Object

      o:Event( 0, {|ow| This.Topmost := .F. , _wSend(2,ow) , ow:Cargo:oBrw:SetFocus()   } )

      o:Event({2, "_ItogGet"}, {|ow| // итого по базе -> demos_use.prg
                                     Local ob := ow:Cargo:oBrw, oCol, cFld
                                     Local aFldSum := ow:Cargo:aFldSum
                                     Local aItog := Itogo_Dbf(aFldSum, ow:Cargo:cAls)
                                     ow:Cargo:nCount := aItog[1]
                                     ow:Cargo:aItogo := aItog[2]
                                     // переносим в колонки
                                     FOR EACH cFld IN aFldSum
                                         oCol := oBrw:GetColumn(cFld)
                                         IF oCol:Cargo:lTotal
                                            oCol:Cargo:nTotal := aItog[2][ hb_enumindex(cFld) ]
                                         ENDIF
                                     NEXT
                                     ? REPL("#",10) + " _ItogGet", ProcNL()
                                     _wPost("_ItogSay", ob:cParentWnd)
                                     Return Nil
                                     } )

      o:Event({3, "_ItogSay"}, {|ow| // итого по базе - перечитать подвал
                                     ow:Cargo:oBrw:DrawFooters()
                                     Return Nil
                                     } )

      o:Event(90, {|  | dbCloseAll()        })
      o:Event(99, {|ow| ow:Release()        })

   END WINDOW

     CENTER WINDOW &cForm
   ACTIVATE WINDOW &cForm

RETURN NIL

*----------------------------------------------------------------------------*
INIT PROCEDURE Sets_ENV()
*----------------------------------------------------------------------------*
   LOCAL o, cIni  := hb_FNameExtSet( App.ExeName, ".ini" )

   SET CODEPAGE TO RUSSIAN
   SET LANGUAGE TO RUSSIAN

   rddSetDefault( "DBFCDX" )

   SET DECIMALS  TO 4
   SET EPOCH     TO 2000
   SET DATE      TO GERMAN
   SET CENTURY   ON
   SET DELETED   OFF
   SET AUTOPEN   OFF
   SET EXACT     ON
   SET EXCLUSIVE ON
   SET SOFTSEEK  ON
   SET OOP ON

   SET WINDOW MAIN OFF

   IF !HB_ISOBJECT( App.Cargo ) ; App.Cargo := oHmgData()
   ENDIF
   o := App.Cargo
   o:tStart       := hb_DateTime()              // start time
   o:cPathTemp    := GetUserTempFolder() + "\"
   o:cPathDbf     := GetStartUpFolder() + "\DBF\"
   //o:cLang      := "EN"
   o:cLang        := LANG_PRG
   o:cDocMaska    := "ввод маски документа"
   o:cDocMaskaRU  := "ввод 16.03.24 Иванова"
   o:cDocMaskaEN  := "input 16.03.24 Ivanova"

   IF App.Cargo:cLang == "RU" ; o:cDocMaska := o:cDocMaskaRU 
   ELSE                       ; o:cDocMaska := o:cDocMaskaEN
   ENDIF

   App.Cargo:cIni := cIni

   IF hb_FileExists( cIni )
      App.Cargo:oIni := TIniData(cIni, .T.):Read()
   ENDIF

   Default App.Cargo:COMMON := oHmgData() ; o := App.Cargo:COMMON

   Default o:cFontName      := "Arial"
   Default o:cFontName2     := "Comic Sans MS"
   Default o:nFontSize      := 12
   Default o:cLogFile       := "_msg1.log"
   Default o:lLogDel        := .T.
   Default o:cDlgFont       := "DejaVu Sans Mono"
   Default o:nDlgSize       := o:nFontSize + 2
   Default o:aDlgBColor     := { 141, 179, 226 }     // Alert* BackColor
   Default o:aDlgFColor     := {  0 ,  0 ,  0  }     // Alert* FontColor
   Default o:cDefAppIcon    := "1MG"
   Default o:lDebug         := .T.
   Default o:nMenuBmpHeight := 32

   _SetGetLogFile( o:cLogFile )

   IF o:lLogDel ; hb_FileDelete( o:cLogFile )
   ENDIF

   IF o:lDebug ; SET LOGERROR ON
   ELSE        ; SET LOGERROR OFF
   ENDIF

   // Default font
   SET FONT TO o:cFontName , o:nFontSize
   // TsBrowse                                       bold italic
   _DefineFont("Normal"  , o:cFontName, o:nFontSize  , .F., .F. )
   _DefineFont("Bold"    , o:cFontName, o:nFontSize  , .T., .F. )
   _DefineFont("Italic"  , o:cFontName, o:nFontSize-2, .F., .T. )
   _DefineFont("ItalBold", o:cFontName, o:nFontSize-2, .T., .T. )
   _DefineFont("SpecHdr" , o:cFontName, o:nFontSize-4, .T., .T. )
   _DefineFont("TsbEdit" , "Times New Roman", o:nFontSize+2, .F., .T. )
   // Menu* font
   _DefineFont("ComSanMS", o:cFontName2 , o:nFontSize+2 , .F., .F. )
   // Alert* font
   _DefineFont("DlgFont" , o:cDlgFont , o:nDlgSize   , .F., .F. )
   // Alert* colors
   SET MSGALERT BACKCOLOR  TO o:aDlgBColor
   SET MSGALERT FONTCOLOR  TO o:aDlgFColor
   //
   SET DEFAULT ICON TO o:cDefAppIcon
   SET WINDOW MODAL PARENT HANDLE ON
   SET TOOLTIPSTYLE BALLOON
   SET NAVIGATION EXTENDED
   SET MENUSTYLE  EXTENDED
   SetMenuBitmapHeight( o:nMenuBmpHeight )

RETURN

//////////////////////////////////////////////////////////////////
FUNCTION myTsbInit( ob, oTsb )  // настройки
   Local nHImg, nI, oCol

   nHImg := 32 + 2*2                 // высота картинки + высота строк в ТСБ

   WITH OBJECT ob
      :lNoKeyChar := .F.             // ввод в ячейки от букв, цифр
      :nHeightCell   := nHImg        // высота ячеек = высоте картинки
      //:nHeightCell += 6
      :nHeightSpecHd := 12           // высота спецхидера ENUMERATOR
      :lFooting      := .T.          // использовать подвал
      :lDrawFooters  := .T.          // рисовать  подвалы
      :nFreeze       := 2            // Заморозить столбец
      :lLockFreeze   := .T.          // Избегать прорисовки курсора на замороженных столбцах
      :nCell         := :nFreeze + 1
      // --------- хранилище картинок, удаляется после закрытия объекта автоматом ------
      :aBitMaps      := { Nil, LoadImage("bRecDel16") }

      :aColumns[1]:nWidth   := nHImg    // ширина колонки как у картинки
      :aColumns[2]:nWidth   := nHImg    // ширина колонки как у картинки

      // изменение картинки для удалённых записей в колонке ORDKEYNO
      :aColumns[1]:aBitMaps := oTsb:aBmp1[2]
      :aColumns[1]:uBmpCell := {|nc,ob| nc:=nil, iif( (ob:cAlias)->(Deleted()), ob:aBitMaps[2], ob:aBitMaps[1] ) }

      :aColumns[2]:aBitMaps := oTsb:aBmp1[2]
      :aColumns[2]:uBmpCell := oTsb:aBmp1[3]
      :aColumns[2]:nAlign   := nMakeLong( DT_CENTER, DT_CENTER )
      :aColumns[2]:nHAlign  := DT_CENTER

      nI := :nColumn("KR1", .T.)
      :aColumns[nI]:lBitMap  := .T.           // убрать показ значений поля из колонки
      :aColumns[nI]:nWidth   := nHImg         // ширина колонки как у картинки
      :aColumns[nI]:aBitMaps := oTsb:aBmp6[2]
      :aColumns[nI]:uBmpCell := oTsb:aBmp6[3]
      :aColumns[nI]:nAlign   := nMakeLong( DT_CENTER, DT_CENTER )
      :aColumns[nI]:nHAlign  := DT_CENTER
      :aColumns[nI]:bData    :=  {||Nil}
      :aColumns[nI]:cData    := '{||Nil}'

      :Cargo:nModify := 0                           // изменения в таблице
      :Cargo:nHBmp   := nHImg                       // высота картинки
      :Cargo:nHImg   := nHImg                       // высота картинки + высота строк в ТСБ
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
      :Cargo:cMaska  := App.Cargo:cDocMaska         // запомним МАСКУ ввода из ини-файла

      // обработка мышки
      :bLDblClick := {|p1,p2,p3,ob| p1:=p2:=p3, ob:PostMsg( WM_KEYDOWN, VK_RETURN, 0 ) }
      // назначение клавиш
      //:UserKeys(VK_F2 ,  {|ob| myTsbListColumn( ob ), ob:Setfocus() })  // инфо по списку колонок
      //:UserKeys(VK_F3 ,  {|ob| myTsbListFont( ob )  , ob:Setfocus() })  // инфо по фонтам таблицы
      //:UserKeys(VK_F4 ,  {|ob| AlertInfo( myGetIndexUse() )  , ob:Setfocus() })  // инфо по индексам таблицы

      // изменим цвет колонки - своя виртуальная колонка / own virtual column
      :GetColumn("ORDKEYNO"):nClrBack     := GetSysColor( COLOR_BTNFACE )
      :GetColumn("ORDKEYNO"):nClrFootBack := CLR_WHITE
      :GetColumn("ORDKEYNO"):nClrFootFore := CLR_BLACK
      :GetColumn("KR2"     ):nClrBack     := CLR_WHITE   // колонка с картинками
      :GetColumn("KR1"     ):nClrBack     := CLR_WHITE   // колонка с картинками
      :GetColumn("PUSTO"   ):nClrBack     := CLR_YELLOW  // колонка по scope
      :GetColumn("DOCUM"   ):nClrBack     := CLR_HGRAY   // колонка № документа оплаты

      FOR EACH oCol IN :aColumns
         IF oCol:Cargo:lTotal
            :GetColumn(oCol:cName):nClrFootBack := CLR_ORANGE
            :GetColumn(oCol:cName):nClrFootFore := CLR_BLACK
         ENDIF
      NEXT

   END WITH

RETURN NIL

////////////////////////////////////////////////////////////////////////////
// ЭТО ДЕЛАЕМ ПОСЛЕ END TBROWSE
FUNCTION myTsbEnd( oBrw )
   LOCAL cMaska, cMaska2, nLen, cAnsOem, cDat, lBottom, cEnd
   LOCAL owc := oBrw:Cargo:oWnd // Cargo окна запомнили на таблице

   //  МАСКА ввода - № док.оплаты
   IF IsString( oBrw:Cargo:cMaska )
      cMaska := oBrw:Cargo:cMaska
   ELSE
      cMaska := App.Cargo:cDocMaska
   ENDIF
   cMaska  := ALLTRIM(cMaska)                             // № док.оплаты
   IF LEN(cMaska) == 0
      cMaska := App.Cargo:cDocMaska
   ENDIF
   ? ProcNL(), "cMaska=", cMaska
   // --------- подключаем здесь SCOPE ---------
   nLen    := LEN( (oBrw:cAlias)->DOCUM )                 // кол-во символов поля DOCUM
   cMaska2 := UPPER(PADR(cMaska,nLen))                    // № док.оплаты
   cAnsOem := HB_ANSITOOEM(cMaska2)                       // № док.оплаты
   cDat    := cEnd := cAnsOem                             // условие отбора
   lBottom := .F. // Scope first
   //lBottom := .T. // Scope last
   oBrw:Cargo:cScopeDat  := cAnsOem                       // запомнить SCOPE
   oBrw:Cargo:cMaska     := cMaska                        // запомнить maska
   ? ProcNL(), "----- SCOPE ----", "["+cDat+"]", LEN(cEnd), lBottom
   // сортировка в таблице по этому индексу
   OrdSetFocus("DOCDTV")      // индекс "маска ввода за день"
   //DbGotop()
   oBrw:ScopeRec(cDat, cEnd, lBottom)
   //oBrw:Reset()
   //oBrw:GoTop()
   DO EVENTS
   ? SPACE(5) + "INDEXORD()=",INDEXORD(), ORDSETFOCUS(),
   ? SPACE(5) + "oBrw:Cargo:cMaska=","["+oBrw:Cargo:cMaska+"]", LEN(oBrw:Cargo:cMaska)
   ? SPACE(5) + "App.Cargo:oIni:MAIN:cMaska=","["+cMaska+"]", LEN(cMaska)

   oBrw:SetNoHoles()
   oBrw:SetFocus()
   DO EVENTS

RETURN NIL

////////////////////////////////////////////////////////////////////////////
// настройки редактирования, редактирование колонок
FUNCTION myTsbEdit( oBrw )
   LOCAL oCol

   ? "*** =>", ProcNL(), Alias(), IndexOrd(), OrdSetFocus(), oBrw:uLastTag
   FOR EACH oCol IN oBrw:aColumns
      IF oCol:cName == "SELECTOR" .OR. oCol:cName == "ORDKEYNO"  ; LOOP
      ENDIF
      IF oCol:cFieldTyp $ "+=@T"
         oCol:lEdit := .F.
      ENDIF
      //IF "NAME" $ oCol:cName
         oCol:bPrevEdit := {|val, brw| Prev( val, brw ) }
         oCol:bPostEdit := {|val, brw| Post( val, brw ) }
      //ENDIF
      //? hb_enumindex(oCol), oCol:cName, oCol:bPrevEdit, oCol:bPostEdit, oCol:lIndexCol, oCol:cOrder
   NEXT

RETURN NIL

*-----------------------------------*
STATIC FUNCTION Prev( uVal, oBrw )
*-----------------------------------*
   LOCAL nCol, oCol, cNam, cAls, uOld, cFTyp, lRet
   LOCAL aDim, aVal, cTyp, cMsg, cRun, cRet, lWrtUDT, cStr

   WITH OBJECT oBrw
      // {0, "W", "D", "Дата;оплаты", "PRIDAT", "99..", "99.99.99", NIL, NIL, "CheckDate()"}
      // {1, "W", "N", "Сумма;(руб.)", "PRIXOD", "999999999999", "999 999.99", NIL, NIL, NIL}
      // {0, "W", "BMP", "Тип;файла", "KR1", "999", "999", NIL, "myImage()", NIL}
      // {0, "W", "J", "Адрес плательщика", "ADRESPRN", "xx..", "AA..", NIL, "myAdres()", NIL}
      aDim  := :Cargo:aDim       // весь массив таблицы -> сделано выше
      nCol  := :nCell
      oCol  := :aColumns[ nCol ]
      cAls  := :cAlias
      cFTyp := oCol:cFieldTyp    // доп.проверка на тип поля
      cNam  := oCol:cName
   END WITH
   uOld := uVal
   ? nCol, cFTyp, ProcNL() //, (cAls)->(IndexOrd()), (cAls)->(OrdSetFocus()), oBrw:uLastTag
   aVal := aDim[nCol]                    // текущая строка данных в колонке
   cTyp := aVal[3]                       // тип обработки колонки
   cRun := aVal[9]                       // функция-1 обработки
   lWrtUDT := .F.                        // не записывать User+Date+Time
   lRet    := .T.                        // давать редактировать поле в :get
   cStr    := "Передано/Transferred: " + oBrw:ClassName + ";"
   cStr    += 'Тип обработки колонки/Column processing type: "' + cTyp + '" ;'
   cStr    += 'oCol:bPrevEdit !;;'
   cStr    += 'Обработка массива/Array Processing:;' + HB_ValToExp(aVal)

   IF cTyp $ "NDL"
      // стандартная обработка
      oCol:nClrEditFore := CLR_YELLOW
      oCol:nClrEditBack := CLR_BLACK
   ELSEIF cTyp $ "CM"
      oCol:nClrEditFore := CLR_BLUE
      oCol:nClrEditBack := CLR_HGRAY
      cRet := ""
      IF AT(CRLF,uVal) > 0
         cRet    := CellEditMemo(uVal, oBrw)
         lWrtUDT := .T.     // записывать User+Date+Time
         lRet    := .F.     // не давать редактировать поле в :get
      ELSEIF cFTyp == "M"
         cRet    := CellEditMemo(uVal, oBrw)
         lWrtUDT := .T.     // записывать User+Date+Time       
         lRet    := .F.     // не давать редактировать поле в :get
      ENDIF
   ELSE
      cMsg := ProcNL(0) + ";" + ProcNL(1) + ";;"
      AlertInfo(cMsg + cStr)
      lRet    := .F.     // не давать редактировать поле в :get
   ENDIF

   IF lWrtUDT                                 // записывать User+Date+Time
      IF (oBrw:cAlias)->(RLock())             // делать самому
         IF LEN(cRet) > 0   // для ("C" + CRLF) и ("M")
           oBrw:SetValue(nCol,cRet) 
         ENDIF
         (oBrw:cAlias)->KOPERAT  := 555       // кто правил запись
         (oBrw:cAlias)->DATEVVOD := DATE()    // дата правки
         (oBrw:cAlias)->TIMEVVOD := 9999      // время правки
         (oBrw:cAlias)->( DbUnlock() )
         (oBrw:cAlias)->( DbCommit() )
      ELSE
         cMsg := "Recording is locked !; Recno="
         cMsg += HB_NtoS(RECNO()) + ";;" + ProcNL()
         AlertStop( cMsg )
      ENDIF
   ENDIF
   oBrw:DrawSelect()    // перерисовать текущую ячейку таблицы

   DO EVENTS

RETURN lRet

*-----------------------------------*
STATIC FUNCTION Post( uVal, oBrw )
*-----------------------------------*
   LOCAL nCol, oCol, cNam, uOld, cAls, lMod, lSay
   LOCAL oWnd  := _WindowObj(oBrw:cParentWnd)
   LOCAL aItog := oWnd:Cargo:aItogo
   LOCAL aDim, aVal, cTyp, cMsg, cRun, cStr

   WITH OBJECT oBrw
      // {0, "W", "D", "Дата;оплаты", "PRIDAT", "99..", "99.99.99", NIL, NIL, "CheckDate()"}
      // {0, "W", "C", "Л/с;абонента", "RC_ABON", "AAA..", "xxxxxxxx", NIL, NIL, "SeekAbonRc()"}
      // {0, "W", "J", "Оплата услуги", "KDMFANT", "aa..", "xxx..xx", "bKey17", "Vvod_Usluga()", NIL}
      // {0, "W", "S", "Кем введено", "KOPERAT0", "AA..A", "xxx...x", "bKey18", {"Operat", "KOperat", "Operat", "Операторы", "Name", ""}, NIL}
      aDim := :Cargo:aDim     // весь массив таблицы -> сделано выше
      nCol := :nCell
      oCol := :aColumns[ nCol ]
      cNam := oCol:cName
      uOld := oCol:xOldEditValue    // old value
      lMod := ! uVal == uOld        // .T. - modify value
      cAls := :cAlias
   END WITH

   ? nCol, ProcNL(), cNam //, (cAls)->(IndexOrd()), (cAls)->(OrdSetFocus()), oBrw:uLastTag
   aVal := aDim[nCol]                       // текущая строка данных в колонке
   cTyp := aVal[3]                          // тип обработки колонки
   cRun := aVal[10]   ; Default cRun := ""  // функция-2 обработки
   ?? "cRun=", cRun
   ?? HB_ValToExp(aVal)
   cStr := "Передано/Transferred: " + oBrw:ClassName + ";"
   cStr += 'Тип обработки колонки/Column processing type: "' + cTyp + '" ;'
   cStr += 'Функция обработки/Processing function oCol:bPostEdit - "' + cRun + '" ;;'
   cStr += 'Обработка массива/Array Processing:;' + HB_ValToExp(aVal)

   IF cTyp $ "CNDL"
      // стандартная обработка
   ELSE
      cMsg := ProcNL(0) + ";" + ProcNL(1) + ";;"
      AlertInfo(cMsg + cStr)
      RETURN .F.
   ENDIF

   //IF cRun == NIL
   //   cRun := ""
   //ENDIF
   IF LEN(cRun) > 0
      cMsg := ProcNL(0) + ";" + ProcNL(1) + ";;"
      AlertInfo(cMsg + cStr)
   ENDIF

   // для всех колонок итогов
   lSay := .F.
   ? "   uVal - oCol:xOldEditValue = ", uVal , oCol:xOldEditValue
   IF oCol:Cargo:lTotal .and. oCol:xOldEditValue != uVal
      ?? "oCol:Cargo:nTotal=",oCol:Cargo:nTotal
      oCol:Cargo:nTotal += uVal - oCol:xOldEditValue
      lSay := .T.
      ?? "=>", oCol:Cargo:nTotal
   ENDIF

   IF lSay ; _wPost("_ItogSay", oBrw:cParentWnd)
   ENDIF
   DO EVENTS

RETURN .T.

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

////////////////////////////////////////////////////////////
FUNCTION myFldTime()   // Дата/время правки
   LOCAL cAls := ALIAS(), cRet := DTOC((cAls)->DATEVVOD)+' '
   LOCAL cTime := HB_NToS( (cAls)->TIMEVVOD )

   cTime := PADL(cTime,4,"0")
   cTime := SUBSTR(cTime,1,2) + ":" + SUBSTR(cTime,3)
   cRet  += cTime

RETURN cRet

