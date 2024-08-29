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

#include <windowsx.h>
#include <commctrl.h>

#define TOTAL_TABS  10

#ifdef UNICODE
LPWSTR      AnsiToWide( LPCSTR );
LPSTR       WideToAnsi( LPWSTR );
#endif
HINSTANCE   GetInstance( void );

HB_FUNC( INITLISTBOX )
{
   HWND  hbutton;
   DWORD Style = WS_CHILD | WS_VSCROLL | LBS_DISABLENOSCROLL | LBS_NOTIFY | LBS_NOINTEGRALHEIGHT;

   if( ! hb_parl( 9 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( ! hb_parl( 10 ) )
   {
      Style |= WS_TABSTOP;
   }

   if( hb_parl( 11 ) )
   {
      Style |= LBS_SORT;
   }

   if( hb_parl( 13 ) )
   {
      Style |= LBS_USETABSTOPS;
   }

   if( hb_parl( 14 ) )
   {
      Style = Style | LBS_MULTICOLUMN | WS_HSCROLL;
   }

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      WC_LISTBOX,
      TEXT( "" ),
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hmg_par_raw_HWND( 1 ),
      hmg_par_raw_HMENU( 2 ),
      GetInstance(),
      NULL
             );

   if( hb_parl( 12 ) )
   {
      MakeDragList( hbutton );
   }

   if( hb_parl( 14 ) )
   {
      SendMessage( hbutton, LB_SETCOLUMNWIDTH, ( WPARAM ) hb_parni( 5 ) - 20, 0 );
   }

   hmg_ret_raw_HWND( hbutton );
}

HB_FUNC( LISTBOXADDSTRING )
{
#ifndef UNICODE
   LPTSTR lpString = ( LPTSTR ) hb_parc( 2 );
#else
   LPWSTR lpString = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   SendMessage( hmg_par_raw_HWND( 1 ), LB_ADDSTRING, 0, ( LPARAM ) lpString );
#ifdef UNICODE
   hb_xfree( lpString );
#endif
}

HB_FUNC( LISTBOXINSERTSTRING )
{
#ifndef UNICODE
   LPTSTR lpString = ( LPTSTR ) hb_parc( 2 );
#else
   LPWSTR lpString = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   SendMessage( hmg_par_raw_HWND( 1 ), LB_INSERTSTRING, ( WPARAM ) hb_parni( 3 ) - 1, ( LPARAM ) lpString );
#ifdef UNICODE
   hb_xfree( lpString );
#endif
}

/* Modified by P.Ch. 16.10. */
HB_FUNC( LISTBOXGETSTRING )
{
#ifdef UNICODE
   LPSTR lpString;
#endif
   int     iLen = ( int ) SendMessage( hmg_par_raw_HWND( 1 ), LB_GETTEXTLEN, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) 0 );
   TCHAR * cString;

   if( iLen > 0 && NULL != ( cString = ( TCHAR * ) hb_xgrab( ( iLen + 1 ) * sizeof( TCHAR ) ) ) )
   {
      SendMessage( hmg_par_raw_HWND( 1 ), LB_GETTEXT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) cString );
#ifdef UNICODE
      lpString = WideToAnsi( cString );
      hb_retc( lpString );
      hb_xfree( lpString );
#else
      hb_retclen_buffer( cString, iLen );
#endif
   }
   else
   {
      hb_retc_null();
   }
}

HB_FUNC( INITMULTILISTBOX )
{
   HWND  hbutton;
   DWORD Style = LBS_EXTENDEDSEL | WS_CHILD | WS_VSCROLL | LBS_DISABLENOSCROLL | LBS_NOTIFY | LBS_MULTIPLESEL | LBS_NOINTEGRALHEIGHT;

   if( ! hb_parl( 9 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( ! hb_parl( 10 ) )
   {
      Style |= WS_TABSTOP;
   }

   if( hb_parl( 11 ) )
   {
      Style |= LBS_SORT;
   }

   if( hb_parl( 13 ) )
   {
      Style |= LBS_USETABSTOPS;
   }

   if( hb_parl( 14 ) )
   {
      Style |= LBS_MULTICOLUMN;
   }

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      WC_LISTBOX,
      TEXT( "" ),
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hmg_par_raw_HWND( 1 ),
      hmg_par_raw_HMENU( 2 ),
      GetInstance(),
      NULL
             );

   if( hb_parl( 12 ) )
   {
      MakeDragList( hbutton );
   }

   hmg_ret_raw_HWND( hbutton );
}

HB_FUNC( LISTBOXGETMULTISEL )
{
   HWND hwnd = hmg_par_raw_HWND( 1 );
   int  i;
   int  buffer[ 32768 ];
   int  n;

   n = ( int ) SendMessage( hwnd, LB_GETSELCOUNT, 0, 0 );

   SendMessage( hwnd, LB_GETSELITEMS, ( WPARAM ) n, ( LPARAM ) buffer );

   hb_reta( n );

   for( i = 0; i < n; i++ )
   {
      HB_STORNI( buffer[ i ] + 1, -1, i + 1 );
   }
}

HB_FUNC( LISTBOXSETMULTISEL )
{
   PHB_ITEM wArray;
   HWND     hwnd = hmg_par_raw_HWND( 1 );
   int      i, n, l;

   wArray = hb_param( 2, HB_IT_ARRAY );

   l = ( int ) hb_parinfa( 2, 0 ) - 1;

   n = ( int ) SendMessage( hwnd, LB_GETCOUNT, 0, 0 );

   // Clear current selections
   for( i = 0; i < n; i++ )
   {
      SendMessage( hwnd, LB_SETSEL, ( WPARAM ) 0, ( LPARAM ) i );
   }

   // Set new selections
   for( i = 0; i <= l; i++ )
   {
      SendMessage( hwnd, LB_SETSEL, ( WPARAM ) 1, ( LPARAM ) hb_arrayGetNI( wArray, i + 1 ) - 1 );
   }
}

HB_FUNC( LISTBOXSETMULTITAB )
{
   PHB_ITEM wArray;
   int      nTabStops[ TOTAL_TABS ];
   int      l, i;
   DWORD    dwDlgBase = GetDialogBaseUnits();
   int      baseunitX = LOWORD( dwDlgBase );

   wArray = hb_param( 2, HB_IT_ARRAY );

   l = ( int ) hb_parinfa( 2, 0 ) - 1;

   for( i = 0; i <= l; i++ )
   {
      nTabStops[ i ] = MulDiv( hb_arrayGetNI( wArray, i + 1 ), 4, baseunitX );
   }

   hb_retl( ListBox_SetTabStops( hmg_par_raw_HWND( 1 ), l, nTabStops ) );
}

HB_FUNC( _GETDDLMESSAGE )
{
   UINT g_dDLMessage;

   g_dDLMessage = RegisterWindowMessage( DRAGLISTMSGSTRING );

   hmg_ret_UINT( g_dDLMessage );
}

HB_FUNC( GET_DRAG_LIST_NOTIFICATION_CODE )
{
   LPARAM lParam        = hmg_par_raw_LPARAM( 1 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   hmg_ret_UINT( lpdli->uNotification );
}

HB_FUNC( GET_DRAG_LIST_DRAGITEM )
{
   LPARAM lParam        = hmg_par_raw_LPARAM( 1 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   hmg_ret_NINT( LBItemFromPt( lpdli->hWnd, lpdli->ptCursor, TRUE ) );
}

HB_FUNC( DRAG_LIST_DRAWINSERT )
{
   HWND   hwnd          = hmg_par_raw_HWND( 1 );
   LPARAM lParam        = hmg_par_raw_LPARAM( 2 );
   int    nItem         = hb_parni( 3 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   int nItemCount = ( int ) SendMessage( ( HWND ) lpdli->hWnd, LB_GETCOUNT, 0, 0 );

   DrawInsert( hwnd, lpdli->hWnd, ( nItem < nItemCount ) ? nItem : -1 );
}

HB_FUNC( DRAG_LIST_MOVE_ITEMS )
{
   LPARAM lParam        = hmg_par_raw_LPARAM( 1 );
   LPDRAGLISTINFO lpdli = ( LPDRAGLISTINFO ) lParam;

   char string[ 1024 ];
   int  result;

   result = ListBox_GetText( lpdli->hWnd, hb_parni( 2 ), string );
   if( result != LB_ERR )
   {
      result = ListBox_DeleteString( lpdli->hWnd, hb_parni( 2 ) );
   }

   if( result != LB_ERR )
   {
      result = ListBox_InsertString( lpdli->hWnd, hb_parni( 3 ), string );
   }

   if( result != LB_ERR )
   {
      result = ListBox_SetCurSel( lpdli->hWnd, hb_parni( 3 ) );
   }

   hmg_ret_L( result != LB_ERR );
}