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

#include <windowsx.h>
#include <commctrl.h>
#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 )
// Combobox Class Name
#define WC_COMBOBOX            "ComboBox"
#endif

HIMAGELIST  HMG_ImageListLoadFirst( const char * FileName, int cGrow, int Transparent, int * nWidth, int * nHeight );
void        HMG_ImageListAdd( HIMAGELIST himl, char * FileName, int Transparent );

#ifdef UNICODE
LPWSTR      AnsiToWide( LPCSTR );
LPSTR       WideToAnsi( LPWSTR );
#endif
HINSTANCE   GetInstance( void );
HINSTANCE   GetResources( void );

HB_FUNC( INITCOMBOBOX )
{
   DWORD Style = WS_CHILD | WS_VSCROLL | ( hb_parl( 12 ) ? CBS_DROPDOWN : CBS_DROPDOWNLIST );

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
      Style |= CBS_SORT;
   }

   if( hb_parl( 13 ) )
   {
      Style |= CBS_NOINTEGRALHEIGHT;
   }

   if( hb_parl( 6 ) )
   {
      Style |= CBS_UPPERCASE;
   }

   if( hb_parl( 7 ) )
   {
      Style |= CBS_LOWERCASE;
   }

   hmg_ret_raw_HWND
   (
      CreateWindow
      (
         WC_COMBOBOX,
         TEXT( "" ),
         Style,
         hb_parni( 3 ),
         hb_parni( 4 ),
         hb_parni( 5 ),
         hb_parni( 8 ),
         hmg_par_raw_HWND( 1 ),
         hmg_par_raw_HMENU( 2 ),
         GetInstance(),
         NULL
      )
   );
}

HB_FUNC( INITCOMBOBOXEX )
{
   HWND       hCombo;
   PHB_ITEM   hArray;
   HIMAGELIST himl = ( HIMAGELIST ) NULL;
   char *     FileName;

   int   nCount;
   int   s, nWidth, nHeight;
   DWORD Style = WS_CHILD | WS_VSCROLL | ( hb_parl( 12 ) ? CBS_DROPDOWN : CBS_DROPDOWNLIST );

   INITCOMMONCONTROLSEX icex;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_USEREX_CLASSES;
   InitCommonControlsEx( &icex );

   if( ! hb_parl( 9 ) )
   {
      Style |= WS_VISIBLE;
   }

   if( ! hb_parl( 10 ) )
   {
      Style |= WS_TABSTOP;
   }

   if( hb_parl( 13 ) )
   {
      Style |= CBS_NOINTEGRALHEIGHT;
   }

   hCombo = CreateWindowEx
            (
      0,
      WC_COMBOBOXEX,
      TEXT( "" ),
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      hmg_par_raw_HWND( 1 ),
      hmg_par_raw_HMENU( 2 ),
      GetInstance(),
      NULL
            );

   // create ImageList from aImage array
   nCount = ( int ) hb_parinfa( 14, 0 );

   if( nCount > 0 )
   {
      int Transparent = hb_parl( 7 ) ? 0 : 1;
      hArray  = hb_param( 14, HB_IT_ARRAY );
      nWidth  = hb_parni( 16 );
      nHeight = hb_parni( 17 );

      for( s = 1; s <= nCount; s++ )
      {
         FileName = ( char * ) hb_arrayGetCPtr( hArray, s );

         if( himl == NULL )
         {
            himl = HMG_ImageListLoadFirst( FileName, nCount, Transparent, &nWidth, &nHeight );
         }
         else
         {
            HMG_ImageListAdd( himl, FileName, Transparent );
         }
      }
   }

   if( himl == NULL && HB_PARNL( 15 ) > 0 )
   {
      himl = hmg_par_raw_HIMAGELIST( 15 );
   }

   // set imagelist for created ComboEx
   if( himl != NULL )
   {
      SendMessage( hCombo, CBEM_SETIMAGELIST, 0, ( LPARAM ) himl );
   }
   else
   {                                     // extend combo without images
      SendMessage
         (                               // returns LRESULT in lResult
         hCombo,                         // handle to destination control
         CBEM_SETEXTENDEDSTYLE,          // message ID
         ( WPARAM ) 0,                   // = (WPARAM) (DWORD) dwExMask;
         ( LPARAM ) CBES_EX_NOEDITIMAGE  // = (LPARAM) (DWORD) dwExStyle;
         );
   }

   hb_reta( 2 );
   hmg_storvnl_HANDLE( hCombo, -1, 1 );
   hmg_storvnl_HANDLE( himl, -1, 2 );
}

HB_FUNC( COMBOSETITEMHEIGHT )
{
   hmg_ret_LRESULT( ComboBox_SetItemHeight( hmg_par_raw_HWND( 1 ), -1, hb_parni( 2 ) ) );
}

HB_FUNC( COMBOSHOWDROPDOWN )
{
   hb_retl( ComboBox_ShowDropdown( hmg_par_raw_HWND( 1 ), TRUE ) );
}

HB_FUNC( COMBOEDITSETSEL )
{
   hmg_ret_LRESULT( ComboBox_SetEditSel( hmg_par_raw_HWND( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC( COMBOGETEDITSEL )
{
   DWORD pos = ComboBox_GetEditSel( hmg_par_raw_HWND( 1 ) );

   hb_reta( 2 );

   HB_STORNI( LOWORD( pos ), -1, 1 );
   HB_STORNI( HIWORD( pos ), -1, 2 );
}

HB_FUNC( COMBOSELECTSTRING )
{
#ifndef UNICODE
   LPCTSTR lpText = ( LPCTSTR ) hb_parc( 2 );
#else
   LPCWSTR lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hmg_ret_LRESULT( ComboBox_SelectString( hmg_par_raw_HWND( 1 ), -1, lpText ) );
}

/* Added by P.Ch. 16.10. */
HB_FUNC( COMBOFINDSTRING )
{
#ifndef UNICODE
   LPCTSTR lpText = ( LPCTSTR ) hb_parc( 2 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hmg_ret_LRESULT( ComboBox_FindString( hmg_par_raw_HWND( 1 ), -1, lpText ) + 1 );
#ifdef UNICODE
   hb_xfree( lpText );
#endif
}

HB_FUNC( COMBOFINDSTRINGEXACT )
{
#ifndef UNICODE
   LPCTSTR lpText = ( LPCTSTR ) hb_parc( 2 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hmg_ret_LRESULT( ComboBox_FindStringExact( hmg_par_raw_HWND( 1 ), -1, lpText ) + 1 );
#ifdef UNICODE
   hb_xfree( lpText );
#endif
}

/* Modified by P.Ch. 16.10. */
HB_FUNC( COMBOGETSTRING )
{
#ifdef UNICODE
   LPSTR lpString;
#endif
   int     iLen = ( int ) SendMessage( hmg_par_raw_HWND( 1 ), CB_GETLBTEXTLEN, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) 0 );
   TCHAR * cString;

   if( iLen > 0 && NULL != ( cString = ( TCHAR * ) hb_xgrab( ( iLen + 1 ) * sizeof( TCHAR ) ) ) )
   {
      SendMessage( hmg_par_raw_HWND( 1 ), CB_GETLBTEXT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) cString );
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

HB_FUNC( COMBOADDSTRING )
{
#ifndef UNICODE
   LPCTSTR lpString = ( LPCTSTR ) hb_parc( 2 );
#else
   LPWSTR lpString = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hmg_ret_LRESULT( ComboBox_AddString( hmg_par_raw_HWND( 1 ), lpString ) );
#ifdef UNICODE
   hb_xfree( lpString );
#endif
}

HB_FUNC( COMBOINSERTSTRING )
{
#ifndef UNICODE
   LPCTSTR lpString = ( LPCTSTR ) hb_parc( 2 );
#else
   LPWSTR lpString = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hmg_ret_LRESULT( ComboBox_InsertString( hmg_par_raw_HWND( 1 ), hb_parni( 3 ) - 1, lpString ) );
#ifdef UNICODE
   hb_xfree( lpString );
#endif
}

// extend combo functions  (JK) HMG 1.0 Exp. Build 8
HB_FUNC( COMBOADDSTRINGEX )
{
#ifndef UNICODE
   LPTSTR lpText = ( LPTSTR ) hb_parc( 2 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   int nImage = hb_parni( 3 );
   COMBOBOXEXITEM cbei;

   cbei.mask           = CBEIF_TEXT | CBEIF_INDENT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_OVERLAY;
   cbei.iItem          = -1;
   cbei.pszText        = lpText;
   cbei.cchTextMax     = ( int ) hb_parclen( 2 );
   cbei.iImage         = ( nImage - 1 ) * 3;
   cbei.iSelectedImage = ( nImage - 1 ) * 3 + 1;
   cbei.iOverlay       = ( nImage - 1 ) * 3 + 2;
   cbei.iIndent        = 0;

   SendMessage( hmg_par_raw_HWND( 1 ), CBEM_INSERTITEM, 0, ( LPARAM ) &cbei );
#ifdef UNICODE
   hb_xfree( lpText );
#endif
}

HB_FUNC( COMBOINSERTSTRINGEX )
{
#ifndef UNICODE
   LPTSTR lpText = ( LPTSTR ) hb_parc( 2 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   int nImage = hb_parni( 3 );
   COMBOBOXEXITEM cbei;

   cbei.mask           = CBEIF_TEXT | CBEIF_INDENT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_OVERLAY;
   cbei.iItem          = hb_parni( 4 ) - 1;
   cbei.pszText        = lpText;
   cbei.cchTextMax     = ( int ) hb_parclen( 2 );
   cbei.iImage         = ( nImage - 1 ) * 3;
   cbei.iSelectedImage = ( nImage - 1 ) * 3 + 1;
   cbei.iOverlay       = ( nImage - 1 ) * 3 + 2;
   cbei.iIndent        = 0;

   SendMessage( hmg_par_raw_HWND( 1 ), CBEM_INSERTITEM, 0, ( LPARAM ) &cbei );
#ifdef UNICODE
   hb_xfree( lpText );
#endif
}

HB_FUNC( COMBOADDDATASTRINGEX )
{
#ifndef UNICODE
   LPTSTR lpText = ( LPTSTR ) hb_parc( 2 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   COMBOBOXEXITEM cbei;

   cbei.mask           = CBEIF_TEXT | CBEIF_INDENT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_OVERLAY;
   cbei.iItem          = -1;
   cbei.pszText        = lpText;
   cbei.cchTextMax     = ( int ) hb_parclen( 2 );
   cbei.iImage         = 0;
   cbei.iSelectedImage = 1;
   cbei.iOverlay       = 2;
   cbei.iIndent        = 0;

   SendMessage( hmg_par_raw_HWND( 1 ), CBEM_INSERTITEM, 0, ( LPARAM ) &cbei );
#ifdef UNICODE
   hb_xfree( lpText );
#endif
}
