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

extern BOOL Array2Point( PHB_ITEM aPoint, POINT *pt );

HIMAGELIST  HMG_ImageListLoadFirst( const char *FileName, int cGrow, int Transparent, int *nWidth, int *nHeight );
void        HMG_ImageListAdd( HIMAGELIST himl, char *FileName, int Transparent );

#ifdef UNICODE
LPWSTR      AnsiToWide( LPCSTR );
#endif
HINSTANCE   GetInstance( void );
HINSTANCE   GetResources( void );

// Minigui Resources control system
void        RegisterResource( HANDLE hResource, LPCSTR szType );

HB_FUNC( INITTABCONTROL )
{
   PHB_ITEM hArray;
   HWND     hbutton;
   TC_ITEM  tie;
   int      l;
   int      i;

#ifndef UNICODE
   LPSTR    lpText;
#else
   LPWSTR   lpText;
#endif
   DWORD    Style = WS_CHILD | WS_VISIBLE | TCS_TOOLTIPS;

   if( hb_parl( 11 ) )
   {
      Style |= TCS_BUTTONS;
   }

   if( hb_parl( 12 ) )
   {
      Style |= TCS_FLATBUTTONS;
   }

   if( hb_parl( 13 ) )
   {
      Style |= TCS_HOTTRACK;
   }

   if( hb_parl( 14 ) )
   {
      Style |= TCS_VERTICAL;
   }

   if( hb_parl( 15 ) )
   {
      Style |= TCS_BOTTOM;
   }

   if( hb_parl( 16 ) )
   {
      Style |= TCS_MULTILINE;
   }

   if( hb_parl( 17 ) )
   {
      Style |= TCS_OWNERDRAWFIXED;
   }

   if( !hb_parl( 18 ) )
   {
      Style |= WS_TABSTOP;
   }

   l = ( int ) hb_parinfa( 7, 0 ) - 1;
   hArray = hb_param( 7, HB_IT_ARRAY );

   hbutton = CreateWindow
      (
         WC_TABCONTROL,
         NULL,
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

   tie.mask = TCIF_TEXT;
   tie.iImage = -1;

   for( i = l; i >= 0; i = i - 1 )
   {
#ifndef UNICODE
      lpText = ( char * ) hb_arrayGetCPtr( hArray, i + 1 );
#else
      lpText = AnsiToWide( ( char * ) hb_arrayGetCPtr( hArray, i + 1 ) );
#endif
      tie.pszText = lpText;

      TabCtrl_InsertItem( hbutton, 0, &tie );

#ifdef UNICODE
      hb_xfree( ( TCHAR * ) lpText );
#endif
   }

   TabCtrl_SetCurSel( hbutton, hb_parni( 8 ) - 1 );

   hmg_ret_raw_HWND( hbutton );
}

HB_FUNC( TABCTRL_SETCURSEL )
{
   hmg_ret_NINT( TabCtrl_SetCurSel( hmg_par_raw_HWND( 1 ), hb_parni( 2 ) - 1 ) );
}

HB_FUNC( TABCTRL_GETCURSEL )
{
   hmg_ret_NINT( TabCtrl_GetCurSel( hmg_par_raw_HWND( 1 ) ) + 1 );
}

HB_FUNC( TABCTRL_INSERTITEM )
{
   TC_ITEM  tie;

#ifndef UNICODE
   LPSTR    lpText = ( LPSTR ) hb_parc( 3 );
#else
   LPWSTR   lpText = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
   tie.mask = TCIF_TEXT;
   tie.iImage = -1;
   tie.pszText = lpText;

   TabCtrl_InsertItem( hmg_par_raw_HWND( 1 ), hb_parni( 2 ), &tie );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpText );
#endif
}

HB_FUNC( TABCTRL_DELETEITEM )
{
   TabCtrl_DeleteItem( hmg_par_raw_HWND( 1 ), hb_parni( 2 ) );
}

HB_FUNC( SETTABCAPTION )
{
#ifndef UNICODE
   LPSTR    lpText = ( LPSTR ) hb_parc( 3 );
#else
   LPWSTR   lpText = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
   TC_ITEM  tie;

   tie.mask = TCIF_TEXT;
   tie.pszText = lpText;

   TabCtrl_SetItem( hmg_par_raw_HWND( 1 ), hb_parni( 2 ) - 1, &tie );

#ifdef UNICODE
   hb_xfree( ( TCHAR * ) lpText );
#endif
}

HB_FUNC( ADDTABBITMAP )
{
   HWND        hbutton = hmg_par_raw_HWND( 1 );
   TC_ITEM     tie;
   HIMAGELIST  himl = ( HIMAGELIST ) NULL;
   PHB_ITEM    hArray;
   char        *FileName;
   int         nCount, i;
   int         cx = -1;
   int         cy = -1;

   nCount = ( int ) hb_parinfa( 2, 0 );

   if( nCount > 0 )
   {
      int   Transparent = hb_parl( 3 ) ? 0 : 1;
      hArray = hb_param( 2, HB_IT_ARRAY );

      for( i = 1; i <= nCount; i++ )
      {
         FileName = ( char * ) hb_arrayGetCPtr( hArray, i );

         if( himl == NULL )
         {
            himl = HMG_ImageListLoadFirst( FileName, nCount, Transparent, &cx, &cy );
         }
         else
         {
            HMG_ImageListAdd( himl, FileName, Transparent );
         }
      }

      if( himl != NULL )
      {
         SendMessage( hbutton, TCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) himl );
         RegisterResource( himl, "IMAGELIST" );
      }

      for( i = 0; i < nCount; i++ )
      {
         tie.mask = TCIF_IMAGE;
         tie.iImage = i;
         TabCtrl_SetItem( ( HWND ) hbutton, i, &tie );
      }
   }

   hmg_ret_raw_HANDLE( himl );
}

HB_FUNC( WINDOWFROMPOINT )
{
   POINT Point;

   Array2Point( hb_param( 1, HB_IT_ARRAY ), &Point );

   hmg_ret_raw_HWND( WindowFromPoint( Point ) );
}

HB_FUNC( GETMESSAGEPOS )
{
   hmg_ret_DWORD( GetMessagePos() );
}
