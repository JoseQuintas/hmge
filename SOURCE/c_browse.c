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
    Copyright 1999-2024, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2021 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/
#define _WIN32_IE 0x0501

#ifdef __XCC__
#define _WIN32_WINDOWS  0x0410
#endif
#include <mgdefs.h>

#include <commctrl.h>
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )

// Scrollbar Class Name
#define WC_SCROLLBAR "ScrollBar"

// Static Class Name
#define WC_STATIC "Static"
#endif
LRESULT APIENTRY  SubClassFunc( HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam );
static WNDPROC    lpfnOldWndProc;

HINSTANCE         GetInstance( void );

HB_FUNC( INITBROWSE )
{
   HWND                 hbutton;
   DWORD                style = LVS_SINGLESEL | LVS_SHOWSELALWAYS | WS_CHILD | WS_VISIBLE | LVS_REPORT;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC = ICC_LISTVIEW_CLASSES;
   InitCommonControlsEx( &i );

   if( !hb_parl( 7 ) )
   {
      style |= WS_TABSTOP;
   }

   hbutton = CreateWindowEx
      (
         WS_EX_CLIENTEDGE,
         WC_LISTVIEW,
         TEXT( "" ),
         style,
         hb_parni( 3 ),
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 6 ),
         hmg_par_raw_HWND( 1 ),
         hmg_par_raw_HMENU( 2 ),
         GetInstance(),
         NULL
      );

   lpfnOldWndProc = SubclassWindow1( hbutton, SubClassFunc );

   hmg_ret_raw_HWND( hbutton );
}

LRESULT APIENTRY SubClassFunc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   if( msg == WM_MOUSEWHEEL )
   {
      // sprintf( res,"zDelta: %d", (short) HIWORD (wParam) );
      // MessageBox( GetActiveWindow(), res, "", MB_OK | MB_ICONINFORMATION );
      if( ( short ) HIWORD( wParam ) > 0 )
      {
         keybd_event
         (
            VK_UP,   // virtual-key code
            0,       // hardware scan code
            0,       // flags specifying various function options
            0        // additional data associated with keystroke
         );
      }
      else
      {
         keybd_event
         (
            VK_DOWN, // virtual-key code
            0,       // hardware scan code
            0,       // flags specifying various function options
            0        // additional data associated with keystroke
         );
      }

      return CallWindowProc( lpfnOldWndProc, hWnd, 0, 0, 0 );
   }
   else
   {
      return CallWindowProc( lpfnOldWndProc, hWnd, msg, wParam, lParam );
   }
}

HB_FUNC( INITVSCROLLBAR )
{
   HWND  hscrollbar;

   hscrollbar = CreateWindowEx
      (
         0,
         WC_SCROLLBAR,
         TEXT( "" ),
         WS_CHILD | WS_VISIBLE | SBS_VERT,
         hb_parni( 2 ),
         hb_parni( 3 ),
         hb_parni( 4 ),
         hb_parni( 5 ),
         hmg_par_raw_HWND( 1 ),
         ( HMENU ) NULL,
         GetInstance(),
         NULL
      );

   SetScrollRange
   (
      hscrollbar,    // handle of window with scroll bar
      SB_CTL,        // scroll bar flag
      1,             // minimum scrolling position
      100,           // maximum scrolling position
      1              // redraw flag
   );

   hmg_ret_raw_HWND( hscrollbar );
}

HB_FUNC( GETSCROLLRANGEMAX )
{
   INT   MinPos, MaxPos;

   GetScrollRange( hmg_par_raw_HWND( 1 ), hb_parni( 2 ), &MinPos, &MaxPos );

   hmg_ret_NINT( MaxPos );
}

HB_FUNC( INITVSCROLLBARBUTTON )
{
   hmg_ret_raw_HWND
   (
      CreateWindow
         (
            WC_STATIC,
            TEXT( "" ),
            WS_CHILD | WS_VISIBLE | SS_SUNKEN,
            hb_parni( 2 ),
            hb_parni( 3 ),
            hb_parni( 4 ),
            hb_parni( 5 ),
            hmg_par_raw_HWND( 1 ),
            ( HMENU ) NULL,
            GetInstance(),
            NULL
         )
   );
}

HB_FUNC( SETSCROLLINFO )
{
   SCROLLINFO  lpsi;

   lpsi.cbSize = sizeof( SCROLLINFO );
   lpsi.fMask = SIF_PAGE | SIF_POS | SIF_RANGE;
   lpsi.nMin = 1;
   lpsi.nMax = hb_parni( 2 );
   lpsi.nPage = hb_parni( 4 );
   lpsi.nPos = hb_parni( 3 );

   hmg_ret_NINT( SetScrollInfo( hmg_par_raw_HWND( 1 ), SB_CTL, ( LPSCROLLINFO ) & lpsi, 1 ) );
}
