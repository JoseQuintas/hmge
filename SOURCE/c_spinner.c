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

#include <mgdefs.h>

#include <commctrl.h>
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )

// Edit Class Name
#define WC_EDIT   "Edit"
#endif
#include "hbvm.h"

#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 ) || defined( __XCC__ )
#define ICC_STANDARD_CLASSES  0x00004000
#endif
LRESULT CALLBACK  OwnSpinProc( HWND hedit, UINT Msg, WPARAM wParam, LPARAM lParam );

HINSTANCE         GetInstance( void );

HB_FUNC( INITSPINNER )
{
   HWND                 hedit, hupdown;
   HWND                 hwnd = hmg_par_raw_HWND( 1 );
   DWORD                Style1 = ES_NUMBER | WS_CHILD | ES_AUTOHSCROLL;
   DWORD                Style2 = WS_CHILD | WS_BORDER | UDS_ARROWKEYS | UDS_ALIGNRIGHT | UDS_SETBUDDYINT | UDS_NOTHOUSANDS;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );

   if( !hb_parl( 11 ) )
   {
      Style1 |= WS_VISIBLE;
      Style2 |= WS_VISIBLE;
   }

   if( !hb_parl( 12 ) )
   {
      Style1 |= WS_TABSTOP;
   }

   if( hb_parl( 13 ) )
   {
      Style2 |= UDS_WRAP;
   }

   if( hb_parl( 14 ) )
   {
      Style1 |= ES_READONLY;
   }

   if( hb_parl( 15 ) )
   {
      Style2 |= UDS_HORZ | UDS_ALIGNRIGHT;   /* P.Ch. 10.16. */
   }

   // Create the Buddy Window
   i.dwICC = ICC_STANDARD_CLASSES;
   InitCommonControlsEx( &i );

   hedit = CreateWindowEx
      (
         WS_EX_CLIENTEDGE,
         WC_EDIT,
         NULL,
         Style1,
         hb_parni( 3 ),
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 10 ),
         hwnd,
         hmg_par_raw_HMENU( 2 ),
         GetInstance(),
         NULL
      );

   // Create the Up-Down Control
   i.dwICC = ICC_UPDOWN_CLASS;               /* P.Ch. 10.16. */
   InitCommonControlsEx( &i );

   hupdown = CreateWindowEx
      (
         WS_EX_CLIENTEDGE,
         UPDOWN_CLASS,
         NULL,
         Style2,
         0,
         0,
         0,
         0, // Set to zero to automatically size to fit the buddy window.
         hwnd,
         ( HMENU ) NULL,
         GetInstance(),
         NULL
      );

   SendMessage( hupdown, UDM_SETBUDDY, ( WPARAM ) hedit, ( LPARAM ) NULL );
   SendMessage( hupdown, UDM_SETRANGE32, ( WPARAM ) hb_parni( 8 ), ( LPARAM ) hb_parni( 9 ) );

   // 2006.08.13 JD
   SetProp( ( HWND ) hedit, TEXT( "oldspinproc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SubclassWindow2( hedit, OwnSpinProc );

   hb_reta( 2 );
   hmg_storvnl_HANDLE( hedit, -1, 1 );
   hmg_storvnl_HANDLE( hupdown, -1, 2 );
}

HB_FUNC( SETSPINNERINCREMENT )
{
   UDACCEL  inc;

   inc.nSec = 0;
   inc.nInc = hb_parni( 2 );

   SendMessage( hmg_par_raw_HWND( 1 ), UDM_SETACCEL, ( WPARAM ) 1, ( LPARAM ) &inc );
}

// 2006.08.13 JD
LRESULT CALLBACK OwnSpinProc( HWND hedit, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB   pSymbol = NULL;
   LRESULT           r;
   WNDPROC           OldWndProc;

   OldWndProc = ( WNDPROC ) ( HB_PTRUINT ) GetProp( hedit, TEXT( "oldspinproc" ) );

   switch( Msg )
   {
      case WM_DESTROY:
         SubclassWindow2( hedit, OldWndProc );
         RemoveProp( hedit, TEXT( "oldspinproc" ) );
         break;

      case WM_CONTEXTMENU:
      case WM_GETDLGCODE:
         if( !pSymbol )
         {
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OSPINEVENTS" ) );
         }

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( HB_PTRUINT ) hedit );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hmg_par_LRESULT( -1 ); /* P.Ch. 10.16. */

         return( r != 0 ) ? r : CallWindowProc( OldWndProc, hedit, Msg, wParam, lParam );
   }

   return CallWindowProc( OldWndProc, hedit, Msg, wParam, lParam );
}
