/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

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
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2023, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/
#define _WIN32_IE  0x0501

#include <mgdefs.h>

#include <commctrl.h>

#ifdef UNICODE
LPWSTR      AnsiToWide( LPCSTR );
#endif
void pascal DelResource( HANDLE hResource );

#ifndef HMG_LEGACY_OFF
   #if ! defined( __MINGW32__ ) && ! defined( __XHARBOUR__ ) && ( __HARBOUR__ - 0 > 0x020000 ) && ( __HARBOUR__ - 0 < 0x030200 )
HB_FUNC_TRANSLATE( HB_SETCODEPAGE, HB_CDPSELECT )
   #endif
#endif \
\
/* HMG_LEGACY_OFF */

HB_FUNC( MAKELONG )
{
   hmg_ret_LONG( MAKELONG( hb_parni( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( _ENABLESCROLLBARS )
{
   EnableScrollBar( hmg_par_raw_HWND( 1 ), hb_parni( 2 ), hb_parni( 3 ) );
}

HB_FUNC( DELETEOBJECT )
{
   HANDLE hRes = hmg_par_raw_HANDLE( 1 );

   if( hRes )
   {
      DelResource( hRes );
      hb_retl( DeleteObject( ( HGDIOBJ ) hRes ) );
   }
   else
   {
      hb_retl( HB_FALSE );
   }
}

HB_FUNC( IMAGELIST_DESTROY )
{
   HIMAGELIST himl = hmg_par_raw_HIMAGELIST( 1 );

   DelResource( himl );
   hb_retl( ImageList_Destroy( himl ) );
}

HB_FUNC( SETFOCUS )
{
   hmg_ret_raw_HWND( SetFocus( hmg_par_raw_HWND( 1 ) ) );
}

HB_FUNC( INSERTSHIFTTAB )
{
   keybd_event
   (
      VK_SHIFT,         // virtual-key code
      0,                // hardware scan code
      0,                // flags specifying various function options
      0                 // additional data associated with keystroke
   );

   keybd_event
   (
      VK_TAB,           // virtual-key code
      0,                // hardware scan code
      0,                // flags specifying various function options
      0                 // additional data associated with keystroke
   );

   keybd_event
   (
      VK_SHIFT,         // virtual-key code
      0,                // hardware scan code
      KEYEVENTF_KEYUP,  // flags specifying various function options
      0                 // additional data associated with keystroke
   );
}

HB_FUNC( SYSTEMPARAMETERSINFO )
{
   hb_retl( SystemParametersInfoA( hmg_par_UINT( 1 ), hmg_par_UINT( 2 ), ( VOID * ) hb_parc( 3 ), hmg_par_UINT( 4 ) ) );
}

HB_FUNC( GETTEXTWIDTH )   // returns the width of a string in pixels
{
   HDC   hDC        = hmg_par_raw_HDC( 1 );
   HWND  hWnd       = ( HWND ) NULL;
   BOOL  bDestroyDC = FALSE;
   HFONT hFont      = hmg_par_raw_HFONT( 3 );
   HFONT hOldFont   = ( HFONT ) NULL;
   SIZE  sz;

#ifndef UNICODE
   LPCSTR lpString = hb_parc( 2 );
#else
   LPCWSTR lpString = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   if( ! hDC )
   {
      bDestroyDC = TRUE;
      hWnd       = GetActiveWindow();
      hDC        = GetDC( hWnd );
   }

   if( hFont )
   {
      hOldFont = ( HFONT ) SelectObject( hDC, hFont );
   }

   GetTextExtentPoint32( hDC, lpString, ( int ) lstrlen( lpString ), &sz );

   if( hFont )
   {
      SelectObject( hDC, hOldFont );
   }

   if( bDestroyDC )
   {
      ReleaseDC( hWnd, hDC );
   }

   hmg_ret_LONG( sz.cx );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpString );
#endif
}

HB_FUNC( KEYBD_EVENT )
{
   keybd_event
   (
      hmg_par_BYTE( 1 ),                              // virtual-key code
      ( BYTE ) MapVirtualKey( hmg_par_UINT( 1 ), 0 ), // hardware scan code
      hb_parl( 2 ) ? KEYEVENTF_KEYUP : 0,             // flags specifying various function options
      0                                               // additional data associated with keystroke
   );
}

HB_FUNC( INSERTVKEY )
{
   keybd_event( hmg_par_BYTE( 1 ),    // virtual-key code
                0, 0, 0 );
}

HB_FUNC( _HMG_SETVSCROLLVALUE )
{
   SendMessage( hmg_par_raw_HWND( 1 ), WM_VSCROLL, MAKEWPARAM( SB_THUMBPOSITION, hb_parni( 2 ) ), 0 );
}

HB_FUNC( _HMG_SETHSCROLLVALUE )
{
   SendMessage( hmg_par_raw_HWND( 1 ), WM_HSCROLL, MAKEWPARAM( SB_THUMBPOSITION, hb_parni( 2 ) ), 0 );
}

HB_FUNC( SHOWCARET )
{
   hb_retl( ShowCaret( hmg_par_raw_HWND( 1 ) ) );
}

HB_FUNC( HIDECARET )
{
   hb_retl( HideCaret( hmg_par_raw_HWND( 1 ) ) );
}

HB_FUNC( DESTROYCARET )
{
   hb_retl( DestroyCaret() );
}

HB_FUNC( CREATECARET )
{
   hb_retl( CreateCaret( hmg_par_raw_HWND( 1 ), hmg_par_raw_HBITMAP( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

/*
   CHANGESTYLE (hWnd,dwAdd,dwRemove,lExStyle)
   Action: Modifies the basic styles of a window
   Parameters: hWnd - handle to window
               dwAdd - window styles to add
               dwRemove - window styles to remove
               lExStyle - TRUE for Extended style otherwise FALSE
   HMG 1.1 Expermental Build 12a
   (C)Jacek Kubica <kubica@wssk.wroc.pl>
 */
HB_FUNC( CHANGESTYLE )
{
   HWND     hWnd = hmg_par_raw_HWND( 1 );
   LONG_PTR dwAdd = hmg_par_raw_LONG_PTR( 2 );
   LONG_PTR dwRemove = hmg_par_raw_LONG_PTR( 3 );
   int      iStyle = hb_parl( 4 ) ? GWL_EXSTYLE : GWL_STYLE;
   LONG_PTR dwStyle, dwNewStyle;

   dwStyle    = GetWindowLongPtr( hWnd, iStyle );
   dwNewStyle = ( dwStyle & ( ~dwRemove ) ) | dwAdd;

   HB_RETNL( ( LONG_PTR ) SetWindowLongPtr( hWnd, iStyle, dwNewStyle ) );

   SetWindowPos( hWnd, NULL, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER );
}

HB_FUNC( MOVEBTNTEXTBOX )    //MoveBtnTextBox(hEdit, hBtn1, hBtn2, fBtn2, BtnWidth, width, height)
{
   HWND hedit    = hmg_par_raw_HWND( 1 );
   HWND hBtn1    = hmg_par_raw_HWND( 2 );
   HWND hBtn2    = hmg_par_raw_HWND( 3 );
   BOOL fBtn2    = hb_parl( 4 );
   int  BtnWidth = ( int ) hb_parni( 5 );
   int  BtnWidth2;
   int  width  = ( int ) hb_parni( 6 );
   int  height = ( int ) hb_parni( 7 );
   BOOL fBtns  = ( hb_parnl( 2 ) > 0 );

   BtnWidth  = ( BtnWidth >= GetSystemMetrics( SM_CYSIZE ) ? BtnWidth : GetSystemMetrics( SM_CYSIZE ) - 1 );
   BtnWidth  = fBtns ? BtnWidth : 0;
   BtnWidth2 = fBtn2 ? BtnWidth : 0;

   SetWindowPos( hedit, NULL, 0, 0, width, height, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOZORDER );

   if( fBtns )
   {
      SetWindowPos( hBtn1, NULL, width - BtnWidth - 4, -1, BtnWidth, height - 2, SWP_NOACTIVATE | SWP_NOZORDER );

      if( fBtn2 )
      {
         SetWindowPos( hBtn2, NULL, width - BtnWidth - BtnWidth2 - 4, -1, BtnWidth2, height - 2, SWP_NOACTIVATE | SWP_NOZORDER );
      }
   }
}

#if defined( __XHARBOUR__ ) || ( __HARBOUR__ - 0 < 0x030200 )
#include "hbapiitm.h"
#include "hbapicdp.h"
#include "hbapierr.h"

HB_FUNC( HB_DATE )
{
   hb_retd( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ) );
}

#if ! defined( __XHARBOUR__ ) && ( __HARBOUR__ - 0 < 0x030200 )
   #define hb_cdppage  hb_vmCDP
#endif
HB_FUNC( HB_LEFTEQI )
{
   PHB_ITEM pItem1 = hb_param( 1, HB_IT_STRING );
   PHB_ITEM pItem2 = hb_param( 2, HB_IT_STRING );

   if( pItem1 && pItem2 )
   {
      hb_retl( hb_cdpicmp( hb_itemGetCPtr( pItem1 ), hb_itemGetCLen( pItem1 ), hb_itemGetCPtr( pItem2 ), hb_itemGetCLen( pItem2 ), hb_cdppage(), HB_FALSE ) == 0 );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 1071, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
   }
}
#endif
