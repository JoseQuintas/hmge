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
#include <mgdefs.h>

#include <commctrl.h>
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )
// Edit Class Name
   #define WC_EDIT  "Edit"
#endif
#include "hbvm.h"

LRESULT CALLBACK  OwnEditProc( HWND hbutton, UINT msg, WPARAM wParam, LPARAM lParam );

HINSTANCE         GetInstance( void );

HB_FUNC( INITMASKEDTEXTBOX )
{
   HWND  hedit;
   DWORD Style = WS_CHILD | ES_AUTOHSCROLL;

   if( hb_parl( 9 ) )
   {
      Style |= ES_UPPERCASE;
   }
   else if( hb_parl( 10 ) )
   {
      Style |= ES_LOWERCASE;
   }

   if( hb_parl( 12 ) )
   {
      Style |= ES_RIGHT;
   }

   if( hb_parl( 13 ) )
   {
      Style |= ES_READONLY;
   }

   if( ! hb_parl( 14 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( ! hb_parl( 15 ) )
   {
      Style |= WS_TABSTOP;
   }

   hedit = CreateWindowEx
           (
      hb_parl( 16 ) ? 0 : WS_EX_CLIENTEDGE,
      WC_EDIT,
      TEXT( "" ),
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 11 ),
      hmg_par_raw_HWND( 1 ),
      hmg_par_raw_HMENU( 2 ),
      GetInstance(),
      NULL
           );

   SetProp( ( HWND ) hedit, TEXT( "oldeditproc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SubclassWindow2( hedit, OwnEditProc );

   hmg_ret_raw_HWND( hedit );
}

HB_FUNC( INITTEXTBOX )
{
   HWND  hedit;
   DWORD iStyle = WS_CHILD | ES_AUTOHSCROLL | BS_FLAT;

   if( hb_parl( 12 ) )
   {
      // if <lNumeric> is TRUE, then ES_NUMBER style is added.
      iStyle |= ES_NUMBER; // Set to a numeric TEXTBOX, so don't worry about other "textual" styles.
   }
   else
   {
      if( hb_parl( 10 ) )
      {
         // if <lUpper> is TRUE, then ES_UPPERCASE style is added.
         iStyle |= ES_UPPERCASE;
      }
      else if( hb_parl( 11 ) )
      {
         // if <lLower> is TRUE, then ES_LOWERCASE style is added.
         iStyle |= ES_LOWERCASE;
      }
   }

   if( hb_parl( 13 ) )
   {
      // if <lPassword> is TRUE, then ES_PASSWORD style is added.
      iStyle |= ES_PASSWORD;
   }

   if( hb_parl( 14 ) )
   {
      iStyle |= ES_RIGHT;
   }

   if( hb_parl( 15 ) )
   {
      iStyle |= ES_READONLY;
   }

   if( ! hb_parl( 16 ) )
   {
      iStyle |= WS_VISIBLE;
   }

   if( ! hb_parl( 17 ) )
   {
      iStyle |= WS_TABSTOP;
   }

   // Creates the child control.
   hedit = CreateWindowEx
           (
      hb_parl( 18 ) ? 0 : WS_EX_CLIENTEDGE,
      WC_EDIT,
      TEXT( "" ),
      iStyle,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hmg_par_raw_HWND( 1 ),
      hmg_par_raw_HMENU( 2 ),
      GetInstance(),
      NULL
           );

   SendMessage( hedit, EM_LIMITTEXT, hmg_par_WPARAM( 9 ), ( LPARAM ) 0 );

   SetProp( ( HWND ) hedit, TEXT( "oldeditproc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SubclassWindow2( hedit, OwnEditProc );

   hmg_ret_raw_HWND( hedit );
}

HB_FUNC( INITCHARMASKTEXTBOX )
{
   HWND  hedit;
   DWORD Style = WS_CHILD | ES_AUTOHSCROLL;

   if( hb_parl( 9 ) )
   {
      Style |= ES_UPPERCASE;
   }
   else if( hb_parl( 10 ) )
   {
      Style |= ES_LOWERCASE;
   }

   if( hb_parl( 12 ) )
   {
      Style |= ES_RIGHT;
   }

   if( hb_parl( 13 ) )
   {
      Style |= ES_READONLY;
   }

   if( ! hb_parl( 14 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( ! hb_parl( 15 ) )
   {
      Style |= WS_TABSTOP;
   }

   hedit = CreateWindowEx
           (
      hb_parl( 16 ) ? 0 : WS_EX_CLIENTEDGE,
      WC_EDIT,
      TEXT( "" ),
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 11 ),
      hmg_par_raw_HWND( 1 ),
      hmg_par_raw_HMENU( 2 ),
      GetInstance(),
      NULL
           );

   SetProp( ( HWND ) hedit, TEXT( "oldeditproc" ), ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SubclassWindow2( hedit, OwnEditProc );

   hmg_ret_raw_HWND( hedit );
}

LRESULT CALLBACK OwnEditProc( HWND hButton, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   LRESULT         r;
   WNDPROC         OldWndProc;

   OldWndProc = ( WNDPROC ) ( HB_PTRUINT ) GetProp( hButton, TEXT( "oldeditproc" ) );

   switch( Msg )
   {
      case WM_DESTROY:
         SubclassWindow2( hButton, OldWndProc );
         RemoveProp( hButton, TEXT( "oldeditproc" ) );
         break;

      case WM_CONTEXTMENU:
      case WM_CHAR:
         if( ! pSymbol )
         {
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OEDITEVENTS" ) );
         }

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( HB_PTRUINT ) hButton );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hmg_par_LRESULT( -1 );

         return ( r != 0 ) ? r : CallWindowProc( OldWndProc, hButton, Msg, wParam, lParam );
   }

   return CallWindowProc( OldWndProc, hButton, Msg, wParam, lParam );
}
