/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * The idea of 2013-23 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Implementation (c) 2023 Sergej Kiselev <bilance@bilance.lv>
*/

// #define _HMG_OUTLOG

#include "minigui.ch"

#define WM_COPYDATA  74

/*
 * Главный модуль. Показ логотипа программы и загрузка основной формы.
 * Список функций проверки при запуске программы.
 * The main module. Logo show program and load the main form.
 * The list of features check at startup.
*/

REQUEST HB_CODEPAGE_RU1251, HB_CODEPAGE_RU866, HB_CODEPAGE_UTF8
REQUEST DBFCDX, DBFFPT

MEMVAR cPubMainFolder, aDirFrom, aDirTo
MEMVAR aBtnColor

FUNCTION MAIN

   LOCAL cTitle := "The MAIN form of the program"

   SET LANGUAGE TO RUSSIAN
   SET CODEPAGE TO RUSSIAN

   SET EPOCH TO 2000
   SET DATE FORMAT "DD.MM.YYYY"
   SET TOOLTIP BALLOON ON
   SET DATE TO GERMAN
   rddSetDefault( 'DBFCDX' )
   SET DELETED ON
   SET OOP ON

   ? ProcName(), ProcLine() ; ?

   FErase( "_MsgLog.txt" )

   PUBLIC aRunCheck

   M->aRunCheck := {}
   AAdd ( M->aRunCheck, { "Start of programm/Запуск программы", "MyStart()", 1 } )
   AAdd ( M->aRunCheck, { "Dummy procedure 1", "Dummy_1()", 0.5 } )
   AAdd ( M->aRunCheck, { "Dummy procedure 2", "Dummy_2()", 0.5 } )
   AAdd ( M->aRunCheck, { "Opening Database:", "MyOpenDbf()", 0.01 } )
   AAdd ( M->aRunCheck, { "Checking / copying files:", "MyCopyFiles()", 2 } )
   AAdd ( M->aRunCheck, { "Starting the main form of the program", "MyStart()", 5 } )

   // Проверка на запуск второй копии программы
   // Check to run a second copy of the program
   OnlyOneInstance( cTitle )

   SET EVENTS FUNCTION TO MyEventsHandler

   DEFINE WINDOW Form_Main AT 0, 0 WIDTH 640 HEIGHT 480 ;
         TITLE cTitle ;
         ICON "1_MAIN" ;
         MAIN NOSHOW ;
         ON INIT ( DoEvents(), _wPost( 0 ) ) ;
         ON INTERACTIVECLOSE {|| MyExit( .F. ) }

      Addition_MainForms()

      ( This.Object ):Event( 0, {||
      LOCAL bRelease := {|| MyInitForm(), DoEvents(), _wPost( 1, "Form_Main" ) }
      _DefineSplashWindow( "Form_Splash",,,,, "DEMO", 0.1, bRelease )
      RETURN NIL
      } )
      ( This.Object ):Event( 1, {| ow | wApi_Sleep( 100 ), ow:Show() } )

   END WINDOW

   ACTIVATE WINDOW Form_Main

RETURN NIL

/*
 * Проверка запуска программы на ВТОРУЮ копию программы
 * Check the start of the program on the second copy of the program
*/
FUNCTION OnlyOneInstance( cAppTitle )

   LOCAL hWnd := FindWindowEx( ,,, cAppTitle )

   IF hWnd # 0
      iif( IsIconic( hWnd ), _Restore( hWnd ), SetForeGroundWindow( hWnd ) )
      ExitProcess( 0 )
   ENDIF

RETURN NIL

/*
 * Показ логотипа программы.
 * Show of program's Logo.
*/
PROCEDURE _DefineSplashWindow( name, row, col, width, height, cbitmap, nTime, Release )

   LOCAL aImgSize := BmpSize( cbitmap )

   DEFAULT row := 0, col := 0, width := aImgSize[ 1 ], height := aImgSize[ 2 ], nTime := 0.1

   DEFINE WINDOW &name ;
         AT ROW, COL ;
         WIDTH width HEIGHT height ;
         CHILD TOPMOST ;
         NOSIZE NOMAXIMIZE NOMINIMIZE NOSYSMENU NOCAPTION ;
         ON INIT _SplashDelay( NAME, nTime, aImgSize[ 1 ] ) ;
         ON RELEASE Eval( Release )

      @ 0, 0 IMAGE Image_1 ;
         PICTURE cbitmap ;
         WIDTH width ;
         HEIGHT height

      // надпись под бегунком / signature on progresbar
      @ 360, 25 LABEL Label_1 ;
         VALUE "" ;
         WIDTH width - 55 ;
         HEIGHT 22 TRANSPARENT ;
         FONT "Arial" SIZE 10 BOLD FONTCOLOR RED

      @ 113, 20 LABEL Label_2 ;
         VALUE "Free open source GUI: " + MiniGUIVersion() ;
         WIDTH width - 30 ;
         HEIGHT 22 CENTERALIGN TRANSPARENT ;
         FONT "Arial" SIZE 12 BOLD FONTCOLOR YELLOW

      @ 245, 20 LABEL Label_3 ;
         VALUE "Free open source: " + Version() ;
         WIDTH width - 30 ;
         HEIGHT 22 CENTERALIGN TRANSPARENT ;
         FONT "Arial" SIZE 12 BOLD FONTCOLOR BLACK

      @ 275, 220 LABEL Label_4 ;
         VALUE hb_Compiler() ;
         WIDTH width - 30 ;
         HEIGHT 22 TRANSPARENT ;
         FONT "Arial" SIZE 12 BOLD FONTCOLOR YELLOW

      DRAW LINE IN WINDOW &name ;
         AT 0, 0 TO 0, width ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      DRAW LINE IN WINDOW &name ;
         AT height, 0 TO height, width ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      DRAW LINE IN WINDOW &name ;
         AT 0, 0 TO height, 0 ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      DRAW LINE IN WINDOW &name ;
         AT 0, width TO height, width ;
         PENCOLOR BLACK ;
         PENWIDTH 2

   END WINDOW

   IF Empty( row ) .AND. Empty( col )
      CENTER WINDOW &NAME
   ENDIF

   ACTIVATE WINDOW Form_Splash

RETURN

/*
* Показ бегунка и надписи. Запуск функции из списка функций проверки при запуске программы.
* Show the slider and labels. Running function from the function test is started.
*/
#define WM_PAINT  15

PROCEDURE _SplashDelay( NAME, nTime, nWidthImg )

   LOCAL i, n, cRun

   SendMessage( GetFormHandle( name ), WM_PAINT, 0, 0 )

   FOR i := 1 TO Len( M->aRunCheck )

      n := 100 / Len( M->aRunCheck )

      SetProperty( NAME, "Label_1", "Value", M->aRunCheck[ i, 1 ] )

      cRun := Left( M->aRunCheck[ i, 2 ], Len( M->aRunCheck[ i, 2 ] ) - 1 ) + iif( M->aRunCheck[ i, 3 ] == NIL, "", hb_ntos( M->aRunCheck[ i, 3 ] ) ) + ")"
      IF ! Eval( hb_macroBlock( cRun ) )
         MsgStop( "Error" )
         QUIT
      ENDIF

      custom_progress_bar( NAME, 335, 25, nWidthImg - 55, 25, { 255, 0, 0 }, n * i, 100 )
      Inkey( nTime )
      SendMessage( GetFormHandle( name ), WM_PAINT, 0, 0 )

   NEXT

   // Удаление окна Form_Splash / Removing window Form_Splash
   DoMethod( NAME, 'Release' )

   ? ProcName(), ProcLine(), NAME, 'Release'

RETURN

/*
*  Функция рисования бегунка на логотипе программы
* The drawing slider on the logo program
*/
FUNCTION custom_progress_bar( cWindowName, nRow, nCol, nWidth, nHeight, aColor, nValue, nMax )

   LOCAL nStartRow, nStartCol, nFinishRow, nFinishCol

   // progress bar
   IF nWidth > nHeight // Horizontal Progress Bar
      nStartRow := nRow + 1
      nStartCol := nCol + 1
      nFinishRow := nRow + nHeight - 1
      nFinishCol := nCol + 1 + ( ( nWidth - 2 ) * nValue / nMax )
   ELSE // Vertical Progress Bar
      nStartRow := nRow + nHeight - 1
      nStartCol := nCol + 1
      nFinishRow := nStartRow - ( ( nHeight - 2 ) * nValue / nMax )
      nFinishCol := nCol + nWidth - 1
   ENDIF

   DRAW RECTANGLE IN WINDOW &cWindowName AT nStartRow, nStartCol TO nFinishRow, nFinishCol PENCOLOR aColor FILLCOLOR aColor

RETURN NIL

///////////////////////////////////////////////////////////////////
// Инициализация моих переменных для программы (пример)
// Initialize variables for my program (example)
INIT PROCEDURE MyInitWin()

   LOCAL cFileIni, cPath

   SET LANGUAGE TO RUSSIAN
   SET CODEPAGE TO RUSSIAN

   SET EPOCH TO 2000
   SET DATE FORMAT "DD.MM.YYYY"
   SET TOOLTIP BALLOON ON
   SET DATE TO GERMAN
   rddSetDefault( 'DBFCDX' )
   SET DELETED ON
   SET OOP ON

   ? ProcName(), ProcLine() ; ?

   PUBLIC cPubMainFolder, aDirFrom := {}, aDirTo := {}
   PUBLIC aBtnColor := WHITE

   // SET TOOLTIP BALLOON ON
   // SET LANGUAGE TO RUSSIAN
   // SET CODEPAGE TO RUSSIAN
   rddSetDefault( 'DBFCDX' )

   // Узнаём текущий путь программы / Know the current path of the program
   cPath := GetStartUpFolder() + "\"
   M->cPubMainFolder := cPath

   cFileIni := ChangeFileExt( Application.ExeName, ".ini" )
   M->cPubFileIni := cFileIni

   // Чтение параметров из INI-файла / Reading of INI-file
   // ReadIniFile( cFileIni, cPath )

   ? ProcName(), ProcLine(), cFileIni ; ?

RETURN

//////////////////////////////////////////////////////////
// Меню выхода из программы - Exit programm
FUNCTION MyExit( lClose )

   LOCAL cMess, lExit

   cMess := ';  Do you really want to exit? ' + Space( 20 ) + ' ; ;'
   cMess := AtRepl( ";", cMess, CRLF )
   lExit := MsgYesNo( cMess, "Exit", .F.,, .F. )
   IF lExit .AND. lClose
      Form_Main.RELEASE
   ENDIF

RETURN lExit

///////////////////////////////////////////////////////////////////
FUNCTION MyEventsHandler( hWnd, nMsg, wParam, lParam )

   LOCAL cData, nDataID, oWnd
   ? ProcName(), ProcLine(), hWnd, nMsg, wParam, lParam

   IF nMsg == WM_COPYDATA

      // cData := GetMessageData( lParam, @nDataID ) ; DO EVENTS
      cData := "111 | ABCDEFG"
      nDataId := 12345
      ?? nDataID, cData

      oWnd := _WindowObj( _HMG_MainHandle )

      IF HB_ISOBJECT( oWnd ) ; _wPost( 111, oWnd, cData )
      ENDIF

      RETURN 1

   ENDIF

RETURN Events( hWnd, nMsg, wParam, lParam )
