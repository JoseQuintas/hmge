/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2024 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2024 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Тестирование колонок в Tsbrowse для dbf файла
 * Ввод в таблицу. Проверка до и после ввода.
 * Итоги по числовым полям, автоматический пересчёт при изменении данных в колонке
 * Своё окно редактирования мемо-поля и текстовых колонок с CRLF
 * Отработка клика мышки (правая/левая) на суперхидере/шапке/подвале/ячейки таблицы
 * Работа со SCOPE.
 * Сохранение/восстановление размеров окна в ини-файл.
 * Работа с буфером обмена: копирование/вставка ячеек таблицы разного формата
 * Testing columns in Tsbrowse for a dbf file
 * Entering into a table. Check before and after input.
 * Totals for numeric fields, automatic recalculation when data in a column changes
 * Your own window for editing memo fields and text columns with CRLF 
 * Working out a mouse click (right/left) on a superheader/header/footer/table cell
 * Working with SCOPE.
 * Saving/restoring window sizes to an ini file.
 * Working with the clipboard: copying/pasting table cells of different formats
 */
#define _HMG_OUTLOG

#include "hmg.ch"
#include "tsbrowse.ch"

REQUEST HB_CODEPAGE_UTF8, HB_CODEPAGE_RU866, HB_CODEPAGE_RU1251
REQUEST DBFNTX, DBFCDX, DBFFPT

#define PROGRAM  "Testing columns in Tsbrowse for a dbf file (1)"
#define PROGVER  "Version 0.1 (02.03.2024)"
#define LANG_PRG "EN"  // "EN" English interface-lang

FUNCTION Main()
   LOCAL cForm := "wMain" , aBColor := {184, 107, 228}
   LOCAL cAls  := "CUST24", cBrw  := "oBrw", cDbf
   LOCAL oBrw, oTsb, nY, nX, nH, nW, nG, o, aClmn, owc

   ? ProcNL(), "_SET_DELETED=", Set(_SET_DELETED)
   IF !UseBase(cAls,@cDbf) ;  QUIT                      // -> demos_use.prg
   ENDIF
   DbSelectArea(cAls)
   ? myGetAllUse()     // Список открытых БД  / List of open databases
   ? myGetIndexUse()   // Список открытых индексов / List of open indexes
   // при создании TBrowse надо ставить правильный тэг индекса
   // TBrowse его удерживает, если не использовать привязку тэгов к колонкам
   OrdSetFocus("DOCDTV")   // ставим сразу здесь !!!

   nY := nX := 0  ; nG := 10
   nW := Sys.ClientWidth
   nH := Sys.ClientHeight

   DEFINE WINDOW &cForm AT nY, nX WIDTH nW HEIGHT nH TITLE PROGRAM ;
      MINWIDTH 500 MINHEIGHT 500                                   ; // блокировка уменьшения размеров окна
      MAIN TOPMOST                                                 ;
      ON MAXIMIZE ( ResizeForm( oBrw ) )                           ;
      ON SIZE     ( ResizeForm( oBrw ) )                           ;
      BACKCOLOR aBColor                                            ;
      ON INIT    _wPost( 0)                                        ;
      ON RELEASE _wSend(90)

      This.Cargo := oHmgData() ; owc := This.Cargo  // для окна создаем объект без переменных (условно пустой)
      owc:aBColor := This.BackColor   // цвет окна
      owc:nG      := nG
      owc:aFldSum := {}               // список полей dbf для расчёта итого
      owc:nCount  := 0                // вывод в подвале таблицы
      owc:aItogo  := {0}              // вывод в подвале таблицы
      owc:cAls    := cAls

      // верхнее меню окна
      myToolBar(owc)
      nY  := owc:nHTBar + nG
      nX  := nG
      nW  := This.ClientWidth
      nH  := This.ClientHeight
            // конец кнопок
      @ 10, owc:nWEndTB LABEL Buff VALUE cDbf AUTOSIZE FONTCOLOR WHITE TRANSPARENT
      This.MinWidth  := owc:nWEndTB  + GetBorderWidth()*2     // блокировка уменьшения размеров окна
      //This.MinHeight := owc:nHBtnEnd + GetBorderHeight()*2  // блокировка уменьшения размеров окна
      @ 32, owc:nWEndTB LABEL Lbl_Index VALUE "Index:" AUTOSIZE FONTCOLOR WHITE TRANSPARENT
      App.Cargo:cLabel := "Lbl_Index"
      App.Cargo:cForm  := cForm
      @ 56, owc:nWEndTB LABEL Lbl_Key VALUE owc:cHelp AUTOSIZE FONTCOLOR YELLOW TRANSPARENT

      // построение таблицы
      oTsb := oHmgData()
      oTsb:aNumber   := { 1, 60 }
      oTsb:uSelector := 20
      aClmn          := Column_TSB( oTsb, cAls )    // список колонок таблицы  -> Column_TSB.prg
      owc:aClmn      := aClmn                       // сохраним на окне массив колонок
      // блоки кода для _TBrowse(...) - менять нельзя // (op=oTsb)
      // отрабатывают после запуска функции _TBrowse(...), т.е. внутри этой функции
      oTsb:bInit := {|ob,op| Column_Init(ob,op) ,;                      // подготовка колонок -> Column_TSB.prg
                             myTsbInit(ob,op) , myTsbFont(ob,op)     }  // настройки тсб  -> demo_tsb.prg
      oTsb:bBody := {|ob,op| myTsbColor(ob,op), myTsbSuperHd(ob,op),;
                             myTsbEdit(ob,op), myTsb_Before(ob,op)   }  // другие настройки тсб  -> demo_tsb.prg
      oTsb:bEnd  := {|ob,op| myTsbClick(ob)  , myTsbEnd(ob,op)       }  // блок кода после END TBROWSE -> demo_tsb.prg

      // функция в библиотеке \MiniGUI\SOURCE\TsBrowse\h_controlmisc2.prg
      oBrw := _TBrowse( oTsb, cAls, cBrw, nY, nX, nW-nG*2, nH-nY-nG )

      oBrw:Cargo:aFldSum := owc:aFldSum     // список полей dbf для расчёта итого -> сделано в Column_TSB.prg
      oBrw:Cargo:oWnd    := This.Cargo      // Cargo окна запомнили на таблице
      App.Cargo:oBrw     := oBrw            // запомнили для внешних функций
      This.Cargo:oBrw    := oBrw

      ON KEY F1     ACTION NIL
      ON KEY ESCAPE ACTION ( iif( oBrw:IsEdit, oBrw:SetFocus(), _wPost(99) ) )

      o := This.Object

      o:Event( 0, {|ow| This.Topmost := .F. , WindowsCoordinat(ow), _wSend(2,ow) , ow:Cargo:oBrw:SetFocus() })

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
                                     ?? "INDEXORD()=",INDEXORD(), ORDSETFOCUS()
                                     _wPost("_ItogSay", ob:cParentWnd)
                                     mySayIndex()  // текущий индекс
                                     Return Nil
                                     } )

      o:Event({3, "_ItogSay"}, {|ow| // итого по базе - перечитать подвал
                                     ow:Cargo:oBrw:DrawFooters()
                                     Return Nil
                                     } )

      o:Event({ 9,"_Help"  }, {|ow,ky,cn| This.&(cn).Enabled := .F. ,;
                                          _SetThisFormInfo(ow), MsgAbout(,,,ky,cn), _SetThisFormInfo(),;
                                          This.&(cn).Enabled := .T. , ow:Cargo:oBrw:SetFocus()           } )

      o:Event({10,"_Find"  }, {|ow,ky,cn,ob| This.&(cn).Enabled := .F. ,;
                                             ob := ow:Cargo:oBrw, _SetThisFormInfo(ow), ;
                                             Menu_Find(ow,ky,cn,ob)   ,;   // F7 -> demo_menu.prg
                                             _SetThisFormInfo(), This.&(cn).Enabled := .T. , ob:Setfocus() } )

      o:Event({11,"_RecIns"}, {|ow,ky,cn,ob| ob := ow:Cargo:oBrw   , _SetThisFormInfo(ow) ,;
                                             RecnoInsert_TSB(ow,ky,cn,ob) , _SetThisFormInfo() ,;       // -> demo_tsb.prg
                                             IIF( ob:Cargo:lRecINS , nil, This.&(cn).Enabled := .T.) ,; // блокировка клавиши INS
                                             ob:Setfocus()  } )                             // VK_INSERT

      o:Event({12,"_RecDel"}, {|ow,ky,cn,ob| ob := This.oBrw.Object, _SetThisFormInfo(ow) ,;
                                             RecnoDelete_TSB(ow,ky,cn,ob) , _SetThisFormInfo() ,;       // -> demo_tsb.prg
                                             IIF( ob:Cargo:lRecDEL , nil, This.&(cn).Enabled := .T.) ,; // блокировка клавиши DEL
                                             ob:Setfocus()  } )                             // VK_DELETE

      o:Event({70,"_Print" }, {|ow,ky,cn,ob| This.&(cn).Enabled := .F. , _SetThisFormInfo(ow) ,;
                                             ob := ow:Cargo:oBrw, Menu_Print(ow,ky,cn,ob)     ,;   // F5 -> demo_print.prg
                                             _SetThisFormInfo(), This.&(cn).Enabled := .T. , ob:Setfocus()  } )

      o:Event({89,"_Exit"  }, {|ow| _LogFile(.T., ProcNL(),">>> Exit button pressed! Window: "+ow:Name), _wSend(99) } )

      o:Event(90, {|ow,ky| // Release
                           Local aWin, oIni
                           ? "---[ "+ow:Name+":Event("+hb_ntos(ky)+") ]---"
                           ?  Repl(".", 10), "=> RELEASE WINDOW <=", ow:Name
                           ?? "... Program running time -", HMG_TimeMS( App.Cargo:tStart )
                           // сохранить размеры окна
                           aWin := { ow:Row, ow:Col, ow:Width, ow:Height }
                           App.Cargo:oIni:MAIN:aWindow := aWin
                           // запомнили последнюю МАСКУ ввода - не нужно
                           // при изменениях этой переменной пишем сразу в этот ини
                           // App.Cargo:oIni:MAIN:cMaska := "????"
                           oIni := App.Cargo:oIni
                           Save_Ini2File( oIni )
                           Return Nil
                           })

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
   SET DATE FORMAT TO "DD.MM.YY"
   SET TOOLTIPSTYLE BALLOON

   SET WINDOW MAIN OFF

   IF !HB_ISOBJECT( App.Cargo ) ; App.Cargo := oHmgData()
   ENDIF
   o := App.Cargo

   o:tStart         := hb_DateTime()   // start time
   o:cFontName      := "DejaVu Sans Mono" //"Arial"
   o:cFontName2     := "Comic Sans MS"
   o:nFontSize      := 13
   o:cLogFile       := "_msg.log"
   o:cIniFile       := cIni
   o:lLogDel        := .T.
   o:cDlgFont       := "DejaVu Sans Mono"
   o:nDlgSize       := o:nFontSize + 2
   o:aDlgBColor     := { 222, 170, 251 }     // Alert* BackColor
   o:aDlgFColor     := {  0 ,  0 ,  0  }     // Alert* FontColor
   o:aBClrMain      := { 127, 189, 228 }
   o:cDefAppIcon    := "1MG"
   o:lDebug         := .T.
   o:nMenuBmpHeight := 32
   o:cLang          := LANG_PRG
   o:cTitle         := PROGRAM
   o:cVersion       := PROGVER
   o:cAvtor         := "Copyright 2024 Verchenko Andrey + Sergej Kiselev"
   o:cEmail         := "<verchenkoag@gmail.com> Dmitrov, Moscow region / <bilance@bilance.lv>"
   o:cPrgInfo1      := "Many thanks for your help: Grigory Filatov <gfilatov@inbox.ru>"
   o:cPrgInfo2      := "Tips and tricks programmers from our forum http://clipper.borda.ru"
   o:cPathTemp      := GetUserTempFolder() + "\"
   o:cPathDbf       := GetStartUpFolder() + "\DBF\"
   //o:aDisplayMode := { System.DesktopWidth , System.DesktopHeight - GetTaskBarHeight() }
   o:aDisplayMode   := { Sys.ClientWidth , Sys.ClientHeight }
   // задание своих параметров, позволяет протестировать на другие разрешения экрана
   // setting your parameters, allows you to test for other screen resolutions
   //o:aDisplayMode   := { 1280 , 1280 }
   o:cDisplayMode   := HB_NtoS(o:aDisplayMode[1]) + "x" + HB_NtoS(o:aDisplayMode[2])

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
   _DefineFont("TsbEdit" , "Times New Roman", o:nFontSize+2, .T., .F. )
   // Menu* font
   _DefineFont("ComSanMS" , o:cFontName2 , o:nFontSize+2 , .F., .F. )
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
   Set ShowRedAlert On        // увеличить фонт для окна "Program Error"

   // Проверка на запуск второй копии программы
   _HMG_MESSAGE[4] := "Попытка запуска второй копии программы:" + CRLF + ;
                      App.ExeName + CRLF + ;
                      "Отказано в запуске." + CRLF + _HMG_MESSAGE[4]
   SET MULTIPLE QUIT WARNING  // окно маленькое

   SetMenuBitmapHeight( o:nMenuBmpHeight )

   PUBLIC nOperat, cOperator, nPubYear
   M->nOperat     := 20
   M->cOperator   := "User-Test"
   M->nPubYear    := YEAR(DATE())

   ? PadC( " Program start - " + HB_TTOC( hb_DateTime() ) + " ", 80, "-" )
   ? " Screen resolution:", HB_NtoS(GetDesktopWidth())+" x "+HB_NtoS(GetDesktopHeight())
   ?? "LargeFontsMode()=", HB_NtoS( LargeFontsMode() )
   ? "Free Open Software:", Version()
   ? "     Free Compiler:", hb_Ccompiler()
   ? "  Free Gui library:", MiniGuiVersion()

   o:cIniFile := cIni
   o:lIni     := hb_FileExists(cIni)
   // доступ к ини-файлу везде в программе - App.Cargo:oIni
   o:oIni := TIniData():New(cIni, .T.):Read()

   Default o:oIni:INFO := oHmgData()
   Default o:oIni:INFO:Developed_in   := MiniGUIVersion()
   Default o:oIni:INFO:xBase_compiler := Version()
   Default o:oIni:INFO:C_compiler     := Hb_Compiler()
   Default o:oIni:INFO:Programm       := o:cTitle
   Default o:oIni:INFO:ProgVers       := o:cVersion
   Default o:oIni:INFO:Avtor          := o:cAvtor
   Default o:oIni:INFO:Email          := o:cEmail

   Default o:oIni:MAIN := oHmgData()
   Default o:oIni:MAIN:aBClrMain    := {215, 166, 0}
   Default o:oIni:MAIN:ComSanMS     := { o:cFontName2 , o:nFontSize+2 , .F., .F. }   // фонт главного верхнего меню
   Default o:oIni:MAIN:aWindow      := {0, 0, 0, 0}
   Default o:oIni:MAIN:cMaska       := "ввод маски документа"
   Default o:oIni:MAIN:cMaskaRU     := "ввод 16.03.24 Иванова"
   Default o:oIni:MAIN:cMaskaEN     := "input 16.03.24 Ivanova"
   IF App.Cargo:cLang == "RU"   // Russian interface-lang
      o:oIni:MAIN:cMaska := o:oIni:MAIN:cMaskaRU
   ELSE
      o:oIni:MAIN:cMaska := o:oIni:MAIN:cMaskaEN
   ENDIF
   // TsBrowse
   Default o:oIni:TsBrowse := oHmgData()
   Default o:oIni:TsBrowse:Normal   := { o:cFontName, o:nFontSize  , .F., .F. }
   Default o:oIni:TsBrowse:Bold     := { o:cFontName, o:nFontSize  , .T., .F. }
   Default o:oIni:TsBrowse:Italic   := { o:cFontName, o:nFontSize-2, .F., .T. }
   Default o:oIni:TsBrowse:ItalBold := { o:cFontName, o:nFontSize-2, .T., .T. }
   Default o:oIni:TsBrowse:SpecHdr  := { o:cFontName, o:nFontSize-2, .T., .T. }
   Default o:oIni:TsBrowse:SuperHdr := { o:cFontName, o:nFontSize-2, .T., .F. }
   Default o:oIni:TsBrowse:Edit     := { o:cFontName, o:nFontSize+2, .F., .F. }
   //                    cell     Head   foot    SpecHider  SuperHider   Edit
   //oTsb:aFont   := { "Normal", "Bold", "Bold", "SpecHdr" , "ItalBold", "DlgFont" }
   //_o2log(o:oIni, 27, ProcNL() + "  o:oIni => ", .T. ) ; ?

   IF !o:lIni
      // если нет файла, то создадим его
      o:oIni:cCommentBegin  := " Modify: " + hb_TtoC( hb_DateTime() )
      o:oIni:Write()  // НЕ UTF8, т.е. нет BOM на выходе
   ENDIF

RETURN

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION ResizeForm( oBrw, oWnd )
   Local nG, owc, nTsbY, nTsbX, cBrw
   DEFAULT oWnd := _WindowObj( GetActiveWindow() )

   IF !ISOBJECT(oBrw)
      AlertStop("Not an oBrw object !;" + ProcNL())
      RETURN NIL
   ENDIF

   owc   := oWnd:Cargo
   nTsbY := owc:nTsbY
   nTsbX := owc:nTsbX
   nG    := owc:nG

   cBrw  := oBrw:cControlName
   This.&(cBrw).Enabled := .F. // блокировать область таблицы (Строки не отображаются)

   // По методу Move() запускается ReSize() - описание параметров см. TControl.prg
   oBrw:Move( oBrw:nLeft, oBrw:nTop, This.ClientWidth - oBrw:nLeft - nG, This.ClientHeight - oBrw:nTop - nG, .T. )

   This.&(cBrw).Enabled := .T. // разблокировать область таблицы (Строки отображаются)

   oBrw:Paint()
   oBrw:Refresh(.T.)
   oBrw:SetNoHoles()
   oBrw:SetFocus()

   DO EVENTS

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION myToolBar(oWC)
   LOCAL nW, nH, nX, hFont, aFont, cFont, nFSize, lBold, nHImg, aImg
   LOCAL aImg1, aObj, aCap, hIco, hBmp, aFrmt, cFile, cPath, aBtnObj
   LOCAL nWBtn, nHBtn, cCap, aTip, nWtxt, nWCap, cObj, cForm, i, o

   ? ProcNL(), "oWC=", oWC

   cForm  := oWC:cForm                   // имя окна
   hFont  := GetFontHandle('ItalBold')
   aFont  := GetFontParam(hFont)
   cFont  := aFont[1]
   nFSize := aFont[2]
   lBold  := aFont[3]
   nHImg  := 48          // 32,55  - задаём размер картинки на кнопке

   // преобразуем ICO -> XXX так как нет в TOOLBAR поддержи .ico
   cPath  := App.Cargo:cPathTemp              // путь, куда выгружаются картинки
   aFrmt  := { "BMP", "PNG", "GIF" }
   aImg   := { "i1Help48" , "i1Find48", "i1Insert48", "i1Delete48", "i1Print48", "i1Exit48" }
   aImg1  := ARRAY(LEN(aImg))
   aBtnObj := {}

   FOR i := 1 TO LEN(aImg)
      hIco  := LoadIconByName( aImg[i], nHImg, nHImg )
      hBmp  := BmpFromIcon( hIco )          // вернет хендл bmp
      cFile := cPath + aImg[i] + ".png"
      HMG_SaveImage( hBmp, cFile, "png" )
      aImg1[i] := cFile
      DestroyIcon(hIco)
      DO EVENTS
   NEXT

   aObj   := { "_Help"   , "_Find"    , "_RecIns"     , "_RecDel"       , "_Print"   , "_Exit"  }
   IF App.Cargo:cLang == "RU"
   aCap   := { "Помощь"  , "Документы", "Новая запись", "Удалить запись", "Печать"   , "Выход"  }
   ELSE
   aCap   := { "Help"    , "Documents", "New recno"   , "Delete recno"  , "Print"    , "Exit"   }
   ENDIF
   aTip   := { "Помощь по программе" + CRLF + "Program assistance"  ,;
               "F7 - Документы: поиск, работа с записями" + CRLF + "F7 - Documents: search, work with records" ,;
               "Ins - новая запись"   + CRLF + "Ins - new recno"    ,;
               "Del - удалить запись" + CRLF + "Del - delete recno" ,;
               "F5 - Печать"  + CRLF  + "F5 - Print"                ,;
               "Выход из программы"   + CRLF + "Exit the program"}
   /*
   aCap   := { "Help"        , "Documents"  , "Add recno"    , "Delete recno" , "Print"       , "Exit"        }
   aTip   := { "Help" , ;
                "F7 - Documents: search, work with records" , ;
                "Ins - add recno", ;
                "Del - delete recno", ;
                "F5 - Print", ;
                "Exit the program" } */

   // расчёт по тексту
   nWtxt  := nW := nH := 0
   FOR i := 1 TO LEN(aCap)
      cCap := aCap[ i ]
      //nWCap := GetTxtWidth(cMenu, nFSize, cFont, lBold )
      nWCap := GetTextWidth( NIL, cCap, hFont )
      nWTxt := MAX(nWTxt,nWCap)
   NEXT
   nWTxt := IIF(nWTxt < nHImg, nHImg, nWTxt )   // nHImg-высота bmp
   nWBtn := nWTxt + 5                           // ширина кнопки
   nHBtn := nHImg + 5 + nFSize + 5              // высота кнопки

   IF lBold
      DEFINE TOOLBAREX ToolBar_1 CAPTION "Menu: - not displayed" BUTTONSIZE nWBtn, nHBtn FLAT ;
         FONT cFont SIZE nFSize BOLD /*TOOLTIP "Double Clik for customizing"*/ CUSTOMIZE
   ELSE
      DEFINE TOOLBAREX ToolBar_1 CAPTION "Menu: - not displayed" BUTTONSIZE nWBtn, nHBtn FLAT ;
         FONT cFont SIZE nFSize  /*TOOLTIP "Double Clik for customizing"*/ CUSTOMIZE
   ENDIF

      nW := nX := 0
      FOR i := 1 TO LEN(aCap)

         cObj := aObj[i]    // контрол на окне

         BUTTON &cObj CAPTION aCap[i] PICTURE aImg1[i] TOOLTIP aTip[i]   ;
           ACTION _wPost(This.Name, ,This.Name) SEPARATOR  //AUTOSIZE

         This.&(cObj).Cargo := oHmgData() ; o := This.&(cObj).Cargo
         o:nBtn := i   ; o:cImage := aImg[i]   // пример

         //IF i % 5 == 0 .AND. i # LEN(aImg)
         //  cObj += "_Dop"
         //  BUTTON &cObj CAPTION " " PICTURE "TB_empty32" ACTION NIL SEPARATOR
         //ENDIF

         AADD( aBtnObj, { i, cObj, "-имя объекта", aCap[i], 0, nW, This.&(cObj).Width, nHBtn, cObj, "-событие" } )

         nW += This.&(cObj).Width + 10

      NEXT

   END TOOLBAR

   nH := This.ToolBar_1.Height + 5 + owc:nG

   owc:cHelp   := "F2/F3/F4, Right mouse,  Cell+Right mouse, Ins/Del"
   owc:nWEndTB := nW + owc:nG    // конец кнопок
   owc:nHTBar  := nH             // высота ToolBar
   owc:aBtnObj := aBtnObj        // массив кнопок на форме
   ?v aBtnObj

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION WindowsCoordinat(ow)
   // считать параметры из ини-файла
   Local aWin := App.Cargo:oIni:MAIN:aWindow

   IF IsArray(aWin)
      IF aWin[1] < 0 .OR. aWin[2] < 0
         // это скрытие окна
      ELSEIF aWin[3] <= 0 .OR. aWin[4] <= 0
         // это сбой координат окна
      ELSE
         ow:Row    := aWin[1]
         ow:Col    := aWin[2]

         ow:Width  := aWin[3]
         ow:Height := aWin[4]
      ENDIF
      // проверка на размер тек.экрана
      IF aWin[3] > App.Cargo:aDisplayMode[1]
         ow:Width  := aWin[3] := App.Cargo:aDisplayMode[1]
      ENDIF
      IF aWin[4] > App.Cargo:aDisplayMode[2]
         ow:Height := aWin[4] := App.Cargo:aDisplayMode[2]
      ENDIF
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION Save_Ini2File( oIni )  // запись в ини-файл

   oIni:cCommentBegin  := " Modify: " + hb_TtoC( hb_DateTime() )
   oIni:Write()  // НЕ UTF8, т.е. нет BOM на выходе

RETURN NIL

/////////////////////////////////////////////////////////////////////////////////////
FUNCTION mySayIndex()  // текущий индекс
   LOCAL cVal, cObj, nI, cAls, cForm

   cObj  := App.Cargo:cLabel
   cForm := App.Cargo:cForm
   cAls  := Alias()
   nI    := (cAls)->( INDEXORD() )
   cVal  := "Index: " + HB_NtoS( nI ) + " (" + (cAls)->( ORDSETFOCUS(nI) ) + ")"

   SetProperty(cForm, cObj, "Value", cVal)
   DO EVENTS

RETURN Nil
