/*----------------------------------------------------------------------------
 HMG - Harbour Windows GUI library source code

 Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
 http://sites.google.com/site/hmgweb/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of HMG.

 The exception is that, if you link the HMG library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 HMG library code into it.

 Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2020, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#pragma -w3

#include "hmg.ch"

*------------------------------------------------------------------------------*
PROCEDURE CreateScreenSplash ( cFileName )
*------------------------------------------------------------------------------*
   LOCAL Image_Width, Image_Height, Image_BackColor

   IF HMG_GetImageInfo ( cFileName, @Image_Width, @Image_Height, @Image_BackColor ) == .F.
      MsgHMGError ( "File Opening Error." )
   ENDIF

#define IMAGEZOOM 1.5

   DEFINE WINDOW FormSplash ;
         AT 0, 0 ;
         WIDTH Image_Width * IMAGEZOOM ;
         HEIGHT Image_Height * IMAGEZOOM ;
         BACKCOLOR WHITE ;
         NOSYSMENU ;
         NOSIZE ;
         NOMINIMIZE ;
         NOMAXIMIZE ;
         NOCAPTION ;
         TOPMOST ;
         CHILD

      SET WINDOW FormSplash TRANSPARENT TO COLOR WHITE

      @ 0, 0 IMAGE Image_1 PICTURE cFileName WIDTH Image_Width * IMAGEZOOM HEIGHT Image_Height * IMAGEZOOM
   END WINDOW

   CENTER WINDOW FormSplash
   SHOW WINDOW FormSplash

RETURN


*------------------------------------------------------------------------------*
FUNCTION HMG_GetImageInfo ( cPicFile, nPicWidth, nPicHeight )
*------------------------------------------------------------------------------*
   LOCAL hBitmap, aSize

   hBitmap := C_GetResPicture( cPicFile )

   aSize := GetBitmapSize( hBitmap )

   DeleteObject( hBitmap )

   nPicWidth := aSize[ 1 ]
   nPicHeight := aSize[ 2 ]

RETURN ( nPicWidth > 0 )


*------------------------------------------------------------------------------*
FUNCTION GetFileDate ( cFile )
*------------------------------------------------------------------------------*
   LOCAL aFileData
   LOCAL RetVal

   IF File ( cFile )

      aFileData := Directory ( cFile )

      RetVal := aFileData[ 1 ][ 3 ]

   ELSE

      RetVal := 0d00000101

   ENDIF

RETURN RetVal


*------------------------------------------------------------------------------*
FUNCTION GetFileTime ( cFile )
*------------------------------------------------------------------------------*
   LOCAL aFileData
   LOCAL RetVal
   IF File ( cFile )
      aFileData := Directory ( cFile )
      RetVal := aFileData[ 1 ][ 4 ]
   ELSE
      RetVal := '  :  :  '
   ENDIF

RETURN RetVal


*------------------------------------------------------------------------------*
FUNCTION HMG_GetCompileVersion32 ()
*------------------------------------------------------------------------------*

RETURN App.Cargo + ' 32-bits'


*------------------------------------------------------------------------------*
FUNCTION HMG_GetCompileVersion64 ()
*------------------------------------------------------------------------------*

RETURN App.Cargo + ' 64-bits'


*------------------------------------------------------------------------------*
PROCEDURE SaveString ( cFileName, cString )
*------------------------------------------------------------------------------*

   hb_MemoWrit ( cFileName, cString )

RETURN


*------------------------------------------------------------------------------*
FUNCTION MyMemoLine( cString, nLineLength, nLineNumber )
*------------------------------------------------------------------------------*
   LOCAL p
   LOCAL c
   LOCAL q
   LOCAL d

   p := MLCToPos( cString, nLineLength, nLineNumber, 0, 8 )

   c := hb_USubStr ( cString, p, 1024 )

   q := hb_UAt ( Chr( 13 ), c )

   IF q == 0

      d := c

   ELSE

      d := hb_ULeft ( c, q - 1 )

   ENDIF

RETURN d


*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>
#include <commdlg.h>
#include <shlwapi.h>
#include <wingdi.h>
#include <winuser.h>
#include <tchar.h>


HB_FUNC( IDECHOOSEFONT )
{

   CHOOSEFONT cf;
   LOGFONT    lf;
   long       PointSize;
   int        bold;
   HDC        hdc;
   HWND       hwnd;

   lstrcpy( lf.lfFaceName, hb_parc( 1 ) );

   hwnd = GetActiveWindow();
   hdc  = GetDC( hwnd );

   lf.lfHeight = -MulDiv( hb_parnl( 2 ), GetDeviceCaps( hdc, LOGPIXELSY ), 72 );

   if( hb_parl( 3 ) )
   {
      lf.lfWeight = 700;
   }
   else
   {
      lf.lfWeight = 400;
   }

   if( hb_parl( 4 ) )
   {
      lf.lfItalic = TRUE;
   }
   else
   {
      lf.lfItalic = FALSE;
   }

   if( hb_parl( 6 ) )
   {
      lf.lfUnderline = TRUE;
   }
   else
   {
      lf.lfUnderline = FALSE;
   }

   if( hb_parl( 7 ) )
   {
      lf.lfStrikeOut = TRUE;
   }
   else
   {
      lf.lfStrikeOut = FALSE;
   }

   lf.lfCharSet = ( BYTE ) hb_parni( 8 );

   cf.lStructSize = sizeof( CHOOSEFONT );
   cf.hwndOwner   = ( HWND ) GetActiveWindow();
   cf.hDC         = ( HDC ) NULL;
   cf.lpLogFont   = &lf;

   cf.Flags = CF_LIMITSIZE | CF_SCREENFONTS | CF_NOVECTORFONTS | CF_NOSCRIPTSEL | CF_NOVERTFONTS | CF_INITTOLOGFONTSTRUCT;

   cf.rgbColors      = hb_parnl( 5 );
   cf.lCustData      = 0L;
   cf.lpfnHook       = NULL;
   cf.lpTemplateName = NULL;
   cf.hInstance      = NULL;
   cf.lpszStyle      = NULL;
   cf.nFontType      = SCREEN_FONTTYPE;
   cf.nSizeMin       = 8;
   cf.nSizeMax       = 11;

   if( ! ChooseFont( &cf ) )
   {
      hb_reta( 8 );
      hb_storvc( "", -1, 1 );
      hb_storvnl( ( LONG ) 0, -1, 2 );
      hb_storvl( 0, -1, 3 );
      hb_storvl( 0, -1, 4 );
      hb_storvnl( 0, -1, 5 );
      hb_storvl( 0, -1, 6 );
      hb_storvl( 0, -1, 7 );
      hb_storvni( 0, -1, 8 );
      return;
   }

   PointSize = -MulDiv( lf.lfHeight, 72, GetDeviceCaps( GetDC( GetActiveWindow() ), LOGPIXELSY ) );

   if( lf.lfWeight == 700 )
   {
      bold = 1;
   }
   else
   {
      bold = 0;
   }

   hb_reta( 8 );
   hb_storvc( lf.lfFaceName, -1, 1 );
   hb_storvnl( ( LONG ) PointSize, -1, 2 );
   hb_storvl( bold, -1, 3 );
   hb_storvl( lf.lfItalic, -1, 4 );
   hb_storvnl( cf.rgbColors, -1, 5 );
   hb_storvl( lf.lfUnderline, -1, 6 );
   hb_storvl( lf.lfStrikeOut, -1, 7 );
   hb_storvni( lf.lfCharSet, -1, 8 );

   ReleaseDC( hwnd, hdc );
}

HB_FUNC( WINMAJORVERSIONNUMBER )
{

   OSVERSIONINFOEX osvi;

   ZeroMemory( &osvi, sizeof( OSVERSIONINFOEX ) );
   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFOEX );

   GetVersionEx( ( OSVERSIONINFO * ) &osvi );

   hb_retni( osvi.dwMajorVersion );

}

HB_FUNC( WINMINORVERSIONNUMBER )
{

   OSVERSIONINFOEX osvi;

   ZeroMemory( &osvi, sizeof( OSVERSIONINFOEX ) );
   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFOEX );

   GetVersionEx( ( OSVERSIONINFO * ) &osvi );

   hb_retni( osvi.dwMinorVersion );

}

HB_FUNC( SETVIRTUALON )
{
   RECT rect;
   int  x, y, w, h;

   GetWindowRect( ( HWND ) HB_PARNL( 1 ), &rect );

   x = rect.left;
   y = rect.top;
   w = rect.right - rect.left;
   h = rect.bottom - rect.top;

   SetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), GWL_STYLE, WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VSCROLL | WS_HSCROLL | WS_SIZEBOX );

   SetWindowPos(
      ( HWND ) HB_PARNL( 1 ),  // handle to window
      HWND_TOP,                // placement-order handle
      0,                       // horizontal position
      0,                       // vertical position
      0,                       // width
      0,                       // height
      SWP_SHOWWINDOW           // window-positioning flags
      );

   SetWindowPos(
      ( HWND ) HB_PARNL( 1 ),  // handle to window
      HWND_TOP,                // placement-order handle
      x,                       // horizontal position
      y,                       // vertical position
      w,                       // width
      h,                       // height
      SWP_SHOWWINDOW           // window-positioning flags
      );
}

HB_FUNC( SETVIRTUALOFF )
{

   RECT rect;
   int  x, y, w, h;

   GetWindowRect( ( HWND ) HB_PARNL( 1 ), &rect );

   x = rect.left;
   y = rect.top;
   w = rect.right - rect.left;
   h = rect.bottom - rect.top;

   SetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), GWL_STYLE, WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_SIZEBOX );

   SetWindowPos(
      ( HWND ) HB_PARNL( 1 ),  // handle to window
      HWND_TOP,                // placement-order handle
      0,                       // horizontal position
      0,                       // vertical position
      0,                       // width
      0,                       // height
      SWP_SHOWWINDOW           // window-positioning flags
      );

   SetWindowPos(
      ( HWND ) HB_PARNL( 1 ),  // handle to window
      HWND_TOP,                // placement-order handle
      x,                       // horizontal position
      y,                       // vertical position
      w,                       // width
      h,                       // height
      SWP_SHOWWINDOW           // window-positioning flags
      );
}

HB_FUNC( SETWINDOWHELPBUTTON )
{
   LONG_PTR Style = GetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), GWL_STYLE );

   if( hb_parl( 2 ) )
   {
      SetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), GWL_STYLE, Style | WS_TABSTOP );
   }
   else
   {
      SetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), GWL_STYLE, Style - WS_TABSTOP );
   }
}

HB_FUNC( SETWINDOWBACKCOLOR )
{
   HWND hWnd;

   HBRUSH hbrush;

   hWnd = ( HWND ) HB_PARNL( 1 );

   hbrush = CreateSolidBrush( RGB( hb_parvni( 2, 1 ), hb_parvni( 2, 2 ), hb_parvni( 2, 3 ) ) );

   SetClassLongPtr(
      ( HWND ) hWnd,            // handle of window
      GCLP_HBRBACKGROUND,       // index of value to change
      ( LONG_PTR ) hbrush       // new value
      );
}

HB_FUNC( DRAWDESIGNGRID )
{
   int     r, c, rto, cto;
   HWND    hWnd1;
   HDC     hdc1;
   HGDIOBJ hgdiobj1;
   HPEN    hpen;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( ( int ) PS_SOLID, ( int ) 1, ( COLORREF ) RGB( ( int ) 0, ( int ) 0, ( int ) 0 ) );
   hgdiobj1 = SelectObject( ( HDC ) hdc1, hpen );


   rto = hb_parni( 2 );
   cto = hb_parni( 3 );

   for( r = 10; r <= rto; r += 10 )
   {

      for( c = 10; c <= cto; c += 10 )
      {
         MoveToEx( ( HDC ) hdc1, ( int ) c, ( int ) r, NULL );
         LineTo( ( HDC ) hdc1, ( int ) c + 1, ( int ) r + 1 );
      }

   }

   SelectObject( ( HDC ) hdc1, ( HGDIOBJ ) hgdiobj1 );
   DeleteObject( hpen );
   ReleaseDC( hWnd1, hdc1 );
}

//       HMG_StrCmp ( Text1 , Text2 , [ lCaseSensitive ] ) --> CmpValue
HB_FUNC( HMG_STRCMP )
{
   CHAR * Text1 = ( CHAR * ) hb_parc( 1 );
   CHAR * Text2 = ( CHAR * ) hb_parc( 2 );
   BOOL   lCaseSensitive = ( BOOL ) hb_parl( 3 );
   int    CmpValue;

   if( lCaseSensitive == FALSE )
      CmpValue = strcmpi( Text1, Text2 );
   else
      CmpValue = strcmp( Text1, Text2 );

   hb_retni( ( int ) CmpValue );
}

HMG_DEFINE_DLL_FUNC( win_AssocQueryString,                                                                            // user function name
                     "Shlwapi.dll",                                                                                   // dll name
                     HRESULT,                                                                                         // function return type
                     WINAPI,                                                                                          // function type
                     "AssocQueryStringA",                                                                             // dll function name
                     ( ASSOCF flags, ASSOCSTR str, LPCSTR pszAssoc, LPCSTR pszExtra, LPSTR pszOut, DWORD * pcchOut ), // dll function parameters (types and names)
                     ( flags, str, pszAssoc, pszExtra, pszOut, pcchOut ),                                             // function parameters (only names)
                     -1                                                                                               // return value if fail call function of dll
                     )

//        HMG_GetFileAssociatedWithExtension ( cExt )   // Extension with point, e.g. ".TXT"
HB_FUNC( HMG_GETFILEASSOCIATEDWITHEXTENSION )
{
   TCHAR * cExt = ( TCHAR * ) hb_parc( 1 );
   TCHAR   cBuffer[ 2048 ];
   DWORD   nCharOut = sizeof( cBuffer ) / sizeof( TCHAR );

   ZeroMemory( cBuffer, sizeof( cBuffer ) );
   win_AssocQueryString( 0, ASSOCSTR_EXECUTABLE, cExt, NULL, cBuffer, ( DWORD * ) &nCharOut );
   hb_retc( cBuffer );
}

HB_FUNC( REDRAWRECT )
{
   RECT r;

   r.top    = hb_parni( 2 );
   r.left   = hb_parni( 3 );
   r.bottom = hb_parni( 4 );
   r.right  = hb_parni( 5 );

   RedrawWindow(
      ( HWND ) HB_PARNL( 1 ),
      &r,
      NULL,
      RDW_ERASE | RDW_INVALIDATE | RDW_ERASENOW | RDW_UPDATENOW
      );
}

HB_FUNC( DRAWDESIGNGRIDRECT )
{
   int     r, c, rto, cto, rfrom, cfrom;
   HWND    hWnd1;
   HDC     hdc1;
   HGDIOBJ hgdiobj1;
   HPEN    hpen;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( ( int ) PS_SOLID, ( int ) 1, ( COLORREF ) RGB( ( int ) 0, ( int ) 0, ( int ) 0 ) );
   hgdiobj1 = SelectObject( ( HDC ) hdc1, hpen );

   rfrom = hb_parni( 2 );
   cfrom = hb_parni( 3 );

   rto = hb_parni( 4 );
   cto = hb_parni( 5 );

   for( r = rfrom; r <= rto; r += 10 )
   {

      for( c = cfrom; c <= cto; c += 10 )
      {
         MoveToEx( ( HDC ) hdc1, ( int ) c, ( int ) r, NULL );
         LineTo( ( HDC ) hdc1, ( int ) c + 1, ( int ) r + 1 );
      }

   }

   SelectObject( ( HDC ) hdc1, ( HGDIOBJ ) hgdiobj1 );
   DeleteObject( hpen );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( REDRAWALL )
{
   RedrawWindow(
      ( HWND ) HB_PARNL( 1 ),
      NULL,
      NULL,
      RDW_ERASE | RDW_INVALIDATE | RDW_ERASENOW
      );
}

HB_FUNC( GETWINDOWSYSCOLOR )
{
   hb_retnl( GetSysColor( COLOR_3DFACE ) );
}

HB_FUNC( GETCONTROLSYSCOLOR )
{
   hb_retnl( GetSysColor( COLOR_WINDOW ) );
}

#pragma ENDDUMP
