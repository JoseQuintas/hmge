/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2019 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2015-2019 Verchenko Andrey <verchenkoag@gmail.com>
 * Many thanks for your help - forum http://clipper.borda.ru
 *
*/
#include "hmg.ch"

*----------------------------------------------------------------------------*
FUNC SetsEnv()
*----------------------------------------------------------------------------*

   SET CODEPAGE TO RUSSIAN
   SET LANGUAGE TO RUSSIAN

   //rddSetDefault( "DBFCDX" )

   SET CENTURY      ON
   SET DATE         GERMAN
   SET DELETED      ON
   SET EXCLUSIVE    ON
   SET EPOCH TO     2000
   SET AUTOPEN      ON
   SET EXACT        ON
   SET SOFTSEEK     ON

   SET NAVIGATION   EXTENDED
   SET FONT         TO "Arial", 14
   SET DEFAULT ICON TO "1MAIN_ICO"

   SET DIALOGBOX CENTER OF PARENT
   SET CENTERWINDOW RELATIVE PARENT                // for HMG_Alert()

   DEFINE FONT FontBold FONTNAME _HMG_DefaultFontName SIZE _HMG_DefaultFontSize BOLD
   DEFINE FONT DlgFont  FONTNAME "Verdana" SIZE 16  // for HMG_Alert()
   DEFINE FONT AgeCard  FONTNAME "Verdana" SIZE  12  BOLD

   // --------------------------------
   SET OOP ON
   // --------------------------------

RETURN NIL

////////////////////////////////////////////////////////////////////
FUNCTION HMG_SetMousePos( nHandle, y1, x1 )
   LOCAL c := _HMG_MouseCol
   LOCAL r := _HMG_MouseRow
   Local y := GetWindowRow(nHandle)
   Local x := GetWindowCol(nHandle)
   Default y1 := 1, x1 := 1

   SetCursorPos( x + x1, y + y1 )

RETURN {c,r}

////////////////////////////////////////////////////////////////////
FUNCTION HMG_MouseGet()
   LOCAL x := _HMG_MouseCol
   LOCAL y := _HMG_MouseRow
RETURN {x,y}

////////////////////////////////////////////////////////////////////
FUNCTION HMG_MouseSet(aXY)
   LOCAL aXYold := HMG_MouseGet()
   SetCursorPos( aXY[1], aXY[2] )
RETURN aXYold

/*
 * MINIGUI - Harbour Win32 GUI library
*/
*----------------------------------------------------------------------------*
FUNCTION GetTxtWidth( cText, nFontSize, cFontName, lBold )  // получить Width текста
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

*----------------------------------------------------------------------------*
FUNCTION GetTxtHeight( cText, nFontSize, cFontName, lBold )  // получить Height текста
*----------------------------------------------------------------------------*
   LOCAL hFont, nHeight
   DEFAULT cText     := "B"                 ,  ;
           cFontName := _HMG_DefaultFontName,  ;   // из MiniGUI.Init()
           nFontSize := _HMG_DefaultFontSize,  ;   // из MiniGUI.Init()
           lBold     := .F.

   hFont := InitFont( cFontName, nFontSize, lBold )
   nHeight := GetTextHeight( 0, cText , hFont )    // высота шрифта
   DeleteObject( hFont )

   RETURN nHeight

//////////////////////////////////////////////////////////////////
// Функция вернет максимальный размер фонта
// для заданной строке по ширине и высоте
FUNCTION GetFontSize4Text( cText, cFontName, nFontSize, lBold, nWmax, nHmax )
   LOCAL hFont, nK := 1, cT := "", nHeig, nWidt
   LOCAL nSize := 6 // App.FontSize

   IF CRLF $ cText
      AEval(hb_ATokens(cText, CRLF), {|t,n| nK := Max( nK, n ), cT := iif( Len( t ) > Len( cT ), t, cT ) })
      cText := cT
   ENDIF

//   nSize := nFontSize
   lBold := !Empty(lBold)
   hFont := InitFont( cFontName, nSize, lBold )
   nHeig := GetTextHeight( 0, cText, hFont ) * nK
   nWidt := GetTextWidth ( 0, cText, hFont )
   DeleteObject( hFont )

   IF     nHeig > nHmax .and. nWidt > nWmax
      DO WHILE .T.
         hFont := InitFont( cFontName, nSize, lBold )
         nHeig := GetTextHeight( 0, cText, hFont ) * nK
         nWidt := GetTextWidth ( 0, cText, hFont )
         DeleteObject( hFont )
         IF nHeig <= nHmax .or. nWidt <= nWmax ; nSize ++ ; EXIT
         ENDIF
         nSize --
      ENDDO
   ELSEIF nHeig < nHmax .and. nWidt < nWmax
      DO WHILE .T.
         hFont := InitFont( cFontName, nSize, lBold )
         nHeig := GetTextHeight( 0, cText, hFont ) * nK
         nWidt := GetTextWidth ( 0, cText, hFont )
         DeleteObject( hFont )
         IF nHeig >= nHmax .or. nWidt >= nWmax ; nSize -- ; EXIT
         ENDIF
         nSize ++
      ENDDO
   ENDIF

RETURN iif( Empty(nFontSize), nSize, Min( nFontSize, nSize ) )

//////////////////////////////////////////////////////////////////
// Функция вернет максимальный размер фонта
// для заданной строке по ширине и высоте
FUNCTION FontSizeMaxAutoFit( cText, cFontName, lBold, nWidth, nHeight )
   LOCAL nTxtWidth, nFSize, lExit := .T.

   cText := cText + "AA" // для отступов слева и справа
   nFSize := 6
   DO WHILE lExit
      nTxtWidth := GetTxtWidth( cText, nFSize, cFontName, lBold )
      IF nTxtWidth >= nWidth
         lExit := .F.
         nFSize--
      ELSE
         nFSize++
      ENDIF
      IF nFSize >= nHeight
         lExit := .F.
         nFSize--
      ENDIF
   ENDDO

RETURN nFSize

*----------------------------------------------------------------------------*
// Функция проверки установлен ли БОЛЬШОЙ фонт в настройках системы
// Пример вызова:        nSizeFont := IIF(Large2Fonts(),9,11)
// для ХР - 120%, для Win7 - 125%
FUNCTION Large2Fonts()
LOCAL hDC, nPixelX, lRet := .F.
hDC := CreateDC( "DISPLAY", "", "" )
nPixelX := GetDevCaps( hDC )
DeleteDC( hDc )
IF nPixelX > 100
   lRet := .T.
ENDIF
RETURN (lRet)

*----------------------------------------------------------------------------*
// Функция проверки установлен ли БОЛЬШОЙ фонт в настройках системы
// Пример вызова:        nSizeFont := IIF(LargeFonts(),9,11)
// для ХР - 120%, для Win7 - 125%
FUNCTION LargeFonts()
LOCAL hDC, nPixelX
hDC := CreateDC( "DISPLAY", "", "" )
nPixelX := GetDevCaps( hDC )
DeleteDC( hDc )
RETURN (nPixelX == 120)

#pragma BEGINDUMP
#include <windows.h>
#include "hbapi.h"
HB_FUNC( CREATEDC )
{
   hb_retnl( ( LONG ) CreateDC( hb_parc( 1 ), hb_parc( 2 ), hb_parc( 3 ), 0 ) );
}
HB_FUNC( DELETEDC )
{
   hb_retl( DeleteDC( ( HDC ) hb_parnl( 1 ) ) );
}
HB_FUNC ( GETDEVCAPS )
{
 INT      ix;
 HDC      hdc;
 hdc = ( HDC ) hb_parnl( 1 );

 ix  = GetDeviceCaps( hdc, LOGPIXELSX );

 hb_retni( (UINT) ix );
}
#pragma ENDDUMP

