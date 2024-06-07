/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */
#define _HMG_OUTLOG

#include "hmg.ch"
#include "dbinfo.ch"

////////////////////////////////////////////////////////////////
FUNCTION ProcNL(nVal, cMsg)
   Default cMsg := ">>> "
   nVal := iif( Empty(nVal), 0, nVal ) + 1
   cMsg += ProcName(nVal) + "(" + hb_ntos( ProcLine(nVal) ) + ")"
   cMsg += " => " + ProcFile(nVal)
RETURN cMsg

//////////////////////////////////////////////////////////////////////////////
// Список открытых БД / List of open databases
FUNCTION myGetAllUse()
   LOCAL nI, cMsg, aAlias := {}, aSelect := {}, aRdd := {}

   hb_waEval( {|| AADD(aAlias, Alias())} )
   hb_waEval( {|| AADD(aSelect, Select())} )
   hb_waEval( {|| AADD(aRdd, RddName())} )

   cMsg := "Список открытых БД / List of open databases:" + CRLF
   FOR nI := 1 TO LEN(aAlias)
       cMsg += "Select: " + HB_NtoS(aSelect[nI])
       cMsg += ",  Alias: " + aAlias[nI]
       cMsg += " ,  RddName: " + aRdd[nI]
       cMsg += " , " + (aAlias[nI])->( DBINFO(DBI_FULLPATH) ) + CRLF
   NEXT

   //AlertInfo( cMsg, "Open databases" )

RETURN cMsg

//////////////////////////////////////////////////////////////////////////////
// Список открытых индексов / List of open indexes
FUNCTION myGetIndexUse()
   LOCAL nI, nTags, cOrd, cFor, nOrder, cOrder, cMsg

   cMsg   := "Список открытых индексов / List of open indexes:" + CRLF
   cMsg   += (ALIAS())->( DBINFO(DBI_FULLPATH) ) + CRLF
   cMsg   += "Alias: " + ALIAS()  + CRLF + CRLF
   nOrder := INDEXORD()
   cOrder := ( ALIAS() )->( ordKey( nOrder ) )
   nTags  := ( ALIAS() )->( ordCount() )
   FOR nI := 1 TO nTags
      cOrd := ( ALIAS() )->( ordName( nI ) )
      cFor := ( ALIAS() )->( ordKey( nI ) )
      cMsg += SPACE(5) + "DbSetOrder(" + HB_NtoS(nI) + ") " + cOrd + " - " + cFor + CRLF
   NEXT
   cMsg += CRLF
   cMsg += "Current index: " + HB_NtoS(nOrder) + " - " + cOrder + CRLF
   DbSetOrder(nOrder)

RETURN cMsg

////////////////////////////////////////////////////////////////
FUNCTION myContextMenu(aMenu, nY2, nX2, cType)
   LOCAL Font1, Font2, Font3, cForm, nY, nX
   LOCAL oWnd, oBrw, nI, nChoice, lIcon
   LOCAL cMenu, bAction, cName, cImg, lChk, lDis

   oBrw   := App.Cargo:oBrw     // запоминали ранее для внешних функций
   cForm  := oBrw:cParentWnd    // имя окна
   // или можно так
   oWnd  := _WindowObj( GetActiveWindow() )  // окно в фокусе
   Font1 := GetFontHandle( "ComSanMS" )
   Font2 := GetFontHandle( "Bold"     )
   Font3 := GetFontHandle( "ItalBold" )
   lIcon := IIF( "ICO" $ UPPER(cType), .T., .F. )

   // координаты вывода окна
   nY    := GetProperty(cForm, "Row") + GetTitleHeight()
   nY    += nY2 + 5
   nX    := GetProperty(cForm, "Col") + GetBorderWidth()
   nX    += nX2

   SET MENUSTYLE EXTENDED     // переключить стиль меню на расширенный
   SetMenuBitmapHeight( 32 )  // установить размер иконок 32х32

   nChoice := -2              // обязательно, первоначальное значение
   DEFINE CONTEXT MENU OF &cForm

       FOR nI := 1 TO LEN(aMenu)
          cMenu := aMenu[nI,2]
          IF LEN(cMenu) == 0
             SEPARATOR
          ELSE
             cImg    := IIF( LEN(aMenu[nI,1])==0, Nil, aMenu[nI,1] )
             cName   := StrZero(nI, 10)
             bAction := {|| nChoice := Val( This.Name ) }
             lChk    := .F.
             lDis    := .F.
             IF lIcon
                _DefineMenuItem( cMenu, bAction, cName,     , lChk, lDis, , Font1 , , .F., .F. , cImg, .F. )
             ELSE
                _DefineMenuItem( cMenu, bAction, cName, cImg, lChk, lDis, , Font1 , , .F., .F. )
             ENDIF
          ENDIF
       NEXT
       /*
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
       */
   END MENU

   _ShowContextMenu(cForm, nY, nX, .f. ) // ПОКАЗ ВЫПАДАЕЩЕГО МЕНЮ

   InkeyGui(10)  // menu работает через очередь !

   DEFINE CONTEXT MENU OF &cForm         // delete menu after exiting
   END MENU

   DO EVENTS

RETURN nChoice

/*---------------------------------------------------------------------------
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

///////////////////////////////////////////////////////////////////////////////////////////
// Функция проверки установлен ли БОЛЬШОЙ фонт в настройках системы
// Пример вызова:        nModeLF := LargeFontsMode()
FUNCTION LargeFontsMode()
LOCAL hDC, nPixelX, lRet := .F.
hDC := CreateDC( "DISPLAY", "", "" )
nPixelX := GetDevCaps( hDC )
DeleteDC( hDc )
RETURN nPixelX

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


*-----------------------------------------------------------------------------*
// Показ иконок ассоциации файлов / Icon associated with the file type

#pragma BEGINDUMP

#include "hbapi.h"
#include "windows.h"
#include <shellapi.h>

extern HBITMAP Icon2Bmp( HICON hIcon );

HB_FUNC( EXTRACTASSICON )
{
HICON hIcon;
LONG hInstance = hb_parnl( 1 );
char * lpIconPath = ( char * ) hb_parc( 2 );
WORD lpiIcon = hb_parnl( 3 );

hIcon = ExtractAssociatedIcon(
( HINSTANCE ) hInstance,
lpIconPath,
&lpiIcon );

hb_stornl( lpiIcon, 3 );
hb_retnl( ( LONG ) hIcon );

}

HB_FUNC( NEXTRACTASSICON )
{
HICON hIcon;
LONG hInstance = hb_parnl( 1 );
char * lpIconPath = ( char * ) hb_parc( 2 );
WORD lpiIcon = hb_parnl( 3 );

hIcon = ExtractAssociatedIcon(
( HINSTANCE ) hInstance,
lpIconPath,
&lpiIcon );

hb_retnl( ( LONG ) Icon2Bmp( hIcon ) );
DestroyIcon(hIcon);
}

HB_FUNC( ICON_EXEREAD )
{
SHFILEINFO sfi;

ZeroMemory(&sfi, sizeof(SHFILEINFO));

/*SHGetFileInfo(hb_parc(1), 0, &sfi, sizeof(SHFILEINFO), SHGFI_ICON | SHGFI_SHELLICONSIZE | SHGFI_USEFILEATTRIBUTES ); */
SHGetFileInfo(hb_parc(1), 0, &sfi, sizeof(SHFILEINFO), SHGFI_ICON | SHGFI_USEFILEATTRIBUTES );

hb_retnl( ( LONG ) sfi.hIcon );

}

HB_FUNC( BMPFROMICON )
{
HICON hIcon = ( HICON ) hb_parnl( 1 );

hb_retnl( ( LONG ) Icon2Bmp( hIcon ) );
}

#pragma ENDDUMP

